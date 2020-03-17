////////////////////////////////////////////////////////////////////////////////
//                                                                            //
// Copyright (c) 2008-2020 Alliance for Sustainable Energy.                   //
// All rights reserved.                                                       //
//                                                                            // 
////////////////////////////////////////////////////////////////////////////////

unit XMLproc;

interface

uses
  SysUtils,
  RegExpr,
  StrUtils,
  NativeXml,
  Contnrs,
  EnergyPlusCore,
  EnergyPlusBuilding,
  EnergyPlusZones,
  EnergyPlusEndUseComponents,
  EnergyPlusSystems,
  EnergyPlusSystemComponents,
  EnergyPlusPerformanceCurves;

procedure ProcessXML(Building: T_EP_Building; RootNode: TXmlNode);
procedure ProcessZoneProcessLoadInfo(aNode:TXmlNode; zone:T_EP_Zone; var SWHComponents:TObjectList;
  var RefCaseComponents: TObjectList; var RefWalkinComponents: TObjectList);
function HVACAirSystemName(RootNode: TXmlNode; ZoneEndEquipmentNode: TXmlNode) : string;

implementation

uses classes, PreprocSettings, EnergyPlusSettings, EnergyPlusGeometry, Globals,
  EnergyPlusConstructions, EnergyPlusLibGrab, EnergyPlusSchedules,
  EnergyPlusSurfaces, EnergyPlusElectricLoadCenter, EnergyPlusInternalGains,
  EnergyPlusExteriorLoads, Math, EnergyPlusSizing, GlobalFuncs,
  PlatformDepFunctions, xmlProcessing, EnergyPlusPPErrorMessages;

procedure ProcessXML(Building: T_EP_Building; RootNode: TXmlNode);
var
  ParentNode: TXmlNode;
  Node: TXmlNode;
  Node2: TXmlNode;
  Node3: TXmlNode;
  DaughterNode: TXmlNode;
  ChildNode: TXmlNode;
  ChildNode2: TXmlNode;
  GrandChildNode: TXmlNode;
  GreatGrandChildNode: TXmlNode;
  Great2GrandChildNode: TXmlNode;
  Great3GrandChildNode: TXmlNode;
  InstanceStr: string;
  i: integer;
  j: integer;
  k: integer;
  L: integer;
  m: integer;
  n: integer;
  jj: integer;
  kk: integer;
  mm: integer;
  nn: integer;
  testDistributionType: string;
  Scope: string;
  zoneScope: string;
  AirEndUses: TObjectList;
  LiquidHeatingDemandComponents: TObjectList;
  LiquidCoolingDemandComponents: TObjectList;
  thisName: string;
  tempName: string;
  Zone: T_EP_Zone;
  PreprocSettings: T_Preproc_Settings;
  Component: THVACComponent;
  UTPComponent: T_EP_UnitaryPackage;
  ZoneHPComponent: T_EP_HeatPumpWaterToAir;
  ChildComponent: THVACComponent;
  AirSystem: T_EP_AirSystem;
  NumAirSystems: integer;
  LiquidHeatingSystem: T_EP_LiquidSystem;
  LiquidCoolingSystem: T_EP_LiquidSystem;
  OaUnit: T_EP_OutdoorAirUnit;
  CondenserSystem: T_EP_LiquidSystem;
  GroundHXSystem: T_EP_LiquidSystem;
  HotWaterSystem: T_EP_LiquidSystem;
  HeatRecoverySystem: T_EP_LiquidSystem;
  aLiquidSystem: T_EP_LiquidSystem;
  ColdWaterSupplyComponents: TObjectList;
  thisAirSys: integer;
  econRequested: boolean;
  AncillaryOAEquip: boolean;
  NewSystem: boolean;
  OAEquipNode: TXmlNode;
  ERVNode: TXmlNode;
  FloorCount: integer;
  xmlZoneInfo: TNativeXml;
  aList: TList;
  iZone: Integer;
  sZoneName: string;
  slZones: TList;
  iList: integer;
  iName: integer;
  iRack: integer;
  iRefrigSys: integer;
  iCase: integer;
  iWalkin: integer;
  IndirectWaterHeaterObj: T_EP_WaterHeater;
  HeatRecoveryWaterHeaterObj: T_EP_Waterheater;
  Geometry: T_EP_Geometry;
  aNode: txmlnode;
  x1: double;
  y1: double;
  valr: double;
  sMacroPath: string;
  sTemp: string;
  bTemp: boolean;
  aSchedule: T_EP_Schedule;
  aCustomList: TList;
  iCL: Integer;
  aFootPrint: T_EP_FootPrint;
  ndFloor: TXmlnode;
  aCustomNode: TXmlnode;
  aFloorList: TList;
  iFloor: Integer;
  aZoningList: TList;
  iZoning: Integer;
  aPointList: TList;
  aZoning: T_EP_Zoning;
  sSubText: string;
  vali: Integer;
  ndFootprint: txmlnode;
  PVMode: string;
  iSurf: Integer;
  aSurf: t_EP_Surface;
  iShade: Integer;
  ndShade: TXmlNode;
  z1: double;
  sConstructName: string;
  aZone: T_EP_Zone;
  curve_cubic: T_Curve_Cubic;
  numCount: Integer;
  valr2: double;
  valr3: double;
  vals: string;
  vals2: string;
  iCnt: Integer;
  flrIndex: Integer;
  ParkingArea: double;
  WPerCFM: double;
  iConditionedCount: Integer;
  costVal: double;
  fanpd: double;
  bSimpleNamesForConst: boolean;
  bUseExtFileForConst: boolean;
  sExtFileNameForConst: string;
  sExtFileDefForConst: string;
  tmpVal:double;
  HotWaterDemandComponents: TObjectList;
  RefrigCaseComponents: TObjectList;
  RefrigWalkinComponents: TObjectList;
  thisRack: T_EP_RefrigerationCompressorRack;
  RefrigerationSystem: T_EP_RefrigerationSystem;
  RefrigCompressorRack: TObjectList;
  RefrigSystems: TObjectList;
  HeatRecoveryRecipientComponents: TObjectList;
  HeatingDemandServedByHotWater: boolean;
  NightCycleNode: TXmlNode;
  plenumNode: TXmlNode;
  OAResetNode: TXmlNode;
  szNode: TXmlNode;
  radiantSurfaceGroup: T_EP_LowTempRadiantSurfaceGroup;
  aSurface: T_EP_Surface;
  // where should these go?
  SimplePV_Params: T_EP_SimplePV_Params;
  ElectricLoadCenter_Params: T_EP_ElectricLoadCenter_Params;
  ndCustomXYZ: TXmlNode;
  lZones: TList;
  ndZone: TXmlNode;
  newSurf: T_EP_Surface;
  addZone: T_EP_Zone;
  iVert: Integer;
  aConstruct: T_EP_Construction;
  // ksb: related to oa system
  motorizedDamper: boolean;
  OASystem: T_EP_OutsideAirSystem;
  ERV: T_EP_HeatRecoveryAirToAir;
  aOAEquipNode: TXmlNode;
  EvaporativeCooler: T_EP_EvaporativeCooler;
  aString: String;
  bString: String;
  aFloat: double;
  ACH: double;
  // ejb: related to total air flow rate for single duct variable flow terminal box
  MaxAirFlowRate: double;
  MaxAirFlowACH: double;
  MaxAirFlowRateACH: double;
  // ksb: related to the erv
  NominalSupplyAirFlowRate: double;
  LatentEffectiveness: double;
  SensEffectiveness: double;
  ParasiticPower: double;
  EconomizerBypass: boolean;
  AvailabilitySchedule: string;
  SetPtMgrName: string;
  // version checking
  fileHpbXmlVersion: string;
  fileFullHpbXmlVersion: string;
  preprocHpbXmlVersion: string;
  preprocFullHpbXmlVersion: string;
  dotCnt: Integer;
  strLen: Integer;
  ventilationSimple: T_EP_VentilationSimple;
  ExhaustFanID: integer;
  ClgCoilID: integer;
  HtgCoilID: integer;
  OaClgCoilID: integer;
  OaHtgCoilID: integer;
  RcClgCoilID: integer;
  RcHtgCoilID: integer;
  CompressorID: integer;
  DualDuct: boolean;

label
  MultiZone;

begin
  gloTDDIndex := 0;
  RefrigerantList := TStringList.Create;
  TranspiredSolarCollectorSurfaces := TStringList.Create;
  TranspiredSolarCollectorArea := TStringList.Create;
  TranspiredSolarCollectorMaxZ := TStringList.Create;
  TranspiredSolarCollectorMinZ := TStringList.Create;
  // ksb: dont assume the compiler is doing this for you
  // ksb: fpc seems to run into trouble when using the assigned() function
  IndirectWaterHeaterObj := nil;
  Node := RootNode.FindNode('/HPBParametization/HVACSystem');
  if Assigned(Node) then
  begin
    if Node.HasAttribute('instance') then
    begin
      Raise Exception.Create('Old Version of XML file');
    end;
  end
  else
  begin
    Raise Exception.Create('no hvac system in XML file');
  end;
  slZones := TList.Create;
  AirEndUses := TObjectList.Create;
  LiquidHeatingDemandComponents := TObjectList.Create;
  LiquidCoolingDemandComponents := TObjectList.Create;
  HotWaterDemandComponents := TObjectList.Create;
  RefrigCaseComponents := TObjectList.Create;
  RefrigWalkinComponents := TObjectList.Create;
  RefrigCompressorRack := TObjectList.Create;
  RefrigSystems := TObjectList.Create;
  HeatRecoveryRecipientComponents := TObjectList.Create;
  HeatingDemandServedByHotWater := false;
  // TODO: DLM, Kyle can you check that this is a same way to do versioning
  // get the preprocessor's version information
  writeln('Checking Preproc Compatibility');
  preprocFullHpbXmlVersion := GetAppVersion;
  // get the file's version information
  Node := RootNode.FindNode('/HPBParametization/HPBXmlSettings');
  if Assigned(Node) then
  begin
    fileFullHpbXmlVersion := StringValueFromPath(Node, 'HPBXmlVersion', false, 'Unknown');
  end;
  // get only the first 3 elements of the version.
  dotCnt := 0;
  strLen := length(preprocFullHpbXmlVersion);
  for i := 1 to length(preprocFullHpbXmlVersion) do
  begin
    if preprocFullHpbXmlVersion[i] = '.' then inc(dotCnt);
    if dotCnt >= 3 then
    begin
      strLen := i;
      break;
    end;
  end;
  preprocHpbXmlVersion := copy(preprocFullHpbXmlVersion, 1, strLen-1);
  dotCnt := 0;
  strLen := length(fileFullHpbXmlVersion);
  for i := 1 to length(fileFullHpbXmlVersion) do
  begin
    if fileFullHpbXmlVersion[i] = '.' then inc(dotCnt);
    if dotCnt >= 3 then
    begin
      strLen := i;
      break;
    end;
  end;
  fileHPBXmlVersion := copy(fileFullHpbXmlVersion, 1, strLen-1);
  if (not AnsiContainsText(fileHPBXmlVersion, preprocHpbXmlVersion)) then
  begin
    T_EP_PPErrorMessage.AddErrorMessage(esWarning, 'File''s HPBXml Version (' + fileFullHpbXmlVersion +
                             ') incompatible with Preprocessor Version ' + preprocFullHpbXmlVersion ) ;
    T_EP_PPErrorMessage.AddErrorMessage(esWarning,'Please update your file.');
  end;
  // ksb: memory leak alert, I have not destroyed this object
  // ksb: not sure where that should happen
  PreprocSettings := T_Preproc_Settings.Create;
  Node := RootNode.FindNode('/HPBParametization/PreprocControl');
  if Assigned(Node) then
  begin
    writeln('Reading Preproc Settings');
  end;
  //load building geometry - if defined
  Node := RootNode.FindNode('/HPBParametization/SimSettings');
  if Assigned(Node) then
  begin
    writeln('Reading Sim Settings');
    EPSettings := T_EP_Settings.Create;
    EPSettings.TimeStepInHour := IntegerValueFromPath(Node, 'TimeStepInHour', 4);
    EPSettings.TimeStepsInAveragingWindow := IntegerValueFromPath(Node, 'TimeStepsInAveragingWindow', -9999);
    EPSettings.RunStartMonth := IntegerValueFromPath(Node, 'RunStartMonth', 1);
    EPSettings.RunStartDay := IntegerValueFromPath(Node, 'RunStartDay', 1);
    EPSettings.RunStopMonth := IntegerValueFromPath(Node, 'RunStopMonth', 12);
    EPSettings.RunStopDay := IntegerValueFromPath(Node, 'RunStopDay', 31);
    EPSettings.MaxNumWarmupDays := IntegerValueFromPath(Node, 'MaxNumWarmupDays', 25);
    EPSettings.LoadConvergeTolerance := FloatValueFromPath(Node, 'LoadConvergeTolerance', 0.04);
    EPSettings.TempConvergeTolerance := FloatValueFromPath(Node, 'TempConvergeTolerance', 0.2);
    EPSettings.UpdateShadowInterval := IntegerValueFromPath(Node, 'UpdateShadowInterval', 7);
    EPSettings.BenchmarkHeader := BooleanValueFromPath(Node, 'BenchmarkHeader', False);
    EPSettings.RunWeatherFile := BooleanValueFromPath(Node, 'RunWeatherFile', True);
    EPSettings.DoPlantSizingCalc := BooleanValueFromPath(Node, 'DoPlantSizingCalc', True);
    EPSettings.SQLiteOutput := BooleanValueFromPath(Node, 'SQLiteOutput', False);
    EPSettings.Costs := BooleanValueFromPath(Node, 'Costs', True);
    EPSettings.MinSystemTimeStep := IntegerValueFromPath(Node, 'MinSystemTimeStep', 5);
    EPSettings.MaxHVACIterations := IntegerValueFromPath(Node, 'MaxHVACIterations', 5);
    EPSettings.VersionOfEnergyPlus := StringValueFromPath(Node,'EnergyPlusVersion',True,'8.1');
    EPSettings.SizingFactor := FloatValueFromPath(Node,'SizingFactor',1.2);
  end;
  //CONSTRUCTIONS
  Node := RootNode.FindNode('/HPBParametization/SpecificConstructs');
  if Assigned(Node) then
  begin
    bSimpleNamesForConst := BooleanValueFromPath(Node, 'UseSimpleNamesForConstructions', false);
    bUseExtFileForConst := BooleanValueFromPath(Node, 'UseExternalFileForConstructions', false);
    sExtFileNameForConst := StringValueFromPath(Node, 'ExternalFileName', false);
    sExtFileDefForConst := StringValueFromPath(Node, 'ExternalFileConstructionDef', false);
  end;
  if not bUseExtFileForConst then
  begin
    writeln('Creating constructions');
    //load typical fenestration constructions
    Node := RootNode.FindNode('/HPBParametization/SpecificConstructs/FenestrationSystem');
    if Assigned(Node) then
    begin
      for i := 0 to Node.NodeCount - 1 do
      begin
        //find construction name
        ChildNode := node.nodes[i].FindNode('ConstructionName');
        if Assigned(ChildNode) then
        begin
          if not bSimpleNamesForConst then
            sConstructName := StringValueFromAttribute(ChildNode, 'instance')
          else
          begin
            sConstructName := 'window_' + node.nodes[i].Name;
          end;
          if BldgConstructions.AddToBldgConstructions(sConstructName, Node.Nodes[i].Name, aConstruct) then
          begin
            aConstruct.Typ := 'Fenestration';
            aConstruct.AddCost(FloatValueFromAttribute(ChildNode, 'CostPer', 1), Node.Nodes[i].Name);
            aConstruct.InfiltrationPerArea := FloatValueFromPath(Node.Nodes[i], 'InfiltrationPerArea');
            aConstruct.AddLayers(node.nodes[i]);
            aConstruct.CheckElectrochromic(node.nodes[i]); //find if electrochromic
            aConstruct.CheckShadingControl(Node.Nodes[i]);
            grandChildNode := Node.Nodes[i].FindNode('ShadingControl');
            if Assigned(grandChildNode) then
            begin
              aConstruct.WindowShade.Typ := StringValueFromPath(grandChildNode, 'Type', False, '');
              aConstruct.WindowShade.ControlType := StringValueFromPath(grandChildNode, 'ControlType', False, '');
              aConstruct.WindowShade.Setpoint := FloatValueFromPath(grandChildNode, 'Setpoint', -9999.0);
              aConstruct.WindowShade.ShadingIsScheduled := BooleanValueFromPath(grandChildNode, 'ShadingIsScheduled', False);
              aConstruct.WindowShade.ScheduleName := StringValueFromPath(grandChildNode, 'ScheduleName', False, '');
              aConstruct.WindowShade.GlareControl := BooleanValueFromPath(grandChildNode, 'GlareControl', False);
              aConstruct.WindowShade.MaterialName := StringValueFromPath(grandChildNode, 'MaterialName', False);
              aConstruct.WindowShade.SlatAngleControl := StringValueFromPath(grandChildNode, 'SlatAngleControl', False, '');
              aConstruct.WindowShade.SlatAngleSchedule := StringValueFromPath(grandChildNode, 'SlatAngleSchedule', False, '');
            end;
          end;
        end;
      end;
    end;
    //load daylight fenestration constructions
    Node := RootNode.FindNode('/HPBParametization/SpecificConstructs/DaylightFenestrationSystem');
    if Assigned(Node) then
    begin
      for i := 0 to Node.NodeCount - 1 do
      begin
        //find construction name
        ChildNode := node.nodes[i].FindNode('ConstructionName');
        if Assigned(ChildNode) then
        begin
          if not bSimpleNamesForConst then
            sConstructName := StringValueFromAttribute(ChildNode, 'instance')
          else
          begin
            sConstructName := 'dl_window_' + node.nodes[i].Name;
          end;
          if BldgConstructions.AddToBldgConstructions(sConstructName, Node.Nodes[i].Name, aConstruct) then
          begin
            aConstruct.Typ := 'DaylightFenestration';
            aConstruct.AddCost(FloatValueFromAttribute(ChildNode, 'CostPer', 1), Node.Nodes[i].Name);
            aConstruct.InfiltrationPerArea := FloatValueFromPath(Node.Nodes[i], 'InfiltrationPerArea');
            aConstruct.AddLayers(node.nodes[i]);
            aConstruct.CheckElectrochromic(node.nodes[i]); //find if electrochromic
            aConstruct.CheckShadingControl(Node.Nodes[i]);
            grandChildNode := Node.Nodes[i].FindNode('ShadingControl');
            if Assigned(grandChildNode) then
            begin
              aConstruct.WindowShade.Typ := StringValueFromPath(ChildNode, 'Type', False, '');
              aConstruct.WindowShade.ControlType := StringValueFromPath(ChildNode, 'ControlType', False, '');
              aConstruct.WindowShade.Setpoint := FloatValueFromPath(ChildNode, 'Setpoint', -9999.0);
              aConstruct.WindowShade.ShadingIsScheduled := BooleanValueFromPath(ChildNode, 'ShadingIsScheduled', False);
              aConstruct.WindowShade.ScheduleName := StringValueFromPath(ChildNode, 'ScheduleName', False, '');
              aConstruct.WindowShade.GlareControl := BooleanValueFromPath(ChildNode, 'GlareControl', False);
              aConstruct.WindowShade.SlatAngleControl := StringValueFromPath(ChildNode, 'SlatAngleControl', False, '');
              aConstruct.WindowShade.SlatAngleSchedule := StringValueFromPath(ChildNode, 'SlatAngleSchedule', False, '');
            end;            
          end;
        end;
      end;
    end;
    //load typical opaque constructions
    Node := RootNode.FindNode('/HPBParametization/SpecificConstructs/OpaqueConstructs');
    if Assigned(Node) then
    begin
      for i := 0 to Node.NodeCount - 1 do
      begin
        ChildNode := node.nodes[i].FindNode('ConstructionName');
        if Assigned(ChildNode) then
        begin
          if not bSimpleNamesForConst then
            sConstructName := StringValueFromAttribute(ChildNode, 'instance')
          else
          begin
            sConstructName := node.nodes[i].Name;
          end;
          if BldgConstructions.AddToBldgConstructions(sConstructName, Node.Nodes[i].Name, aConstruct) then
          begin
            aConstruct.Typ := 'Opaque';
            aConstruct.AddCost(FloatValueFromAttribute(ChildNode, 'CostPer', 1), Node.Nodes[i].Name);
            aConstruct.HighAlbedo := BooleanValueFromPath(Node.Nodes[i], 'HighAlbedo');
            aConstruct.InfiltrationPerArea := FloatValueFromPath(Node.Nodes[i], 'InfiltrationPerArea');
            grandChildNode := Node.Nodes[i].FindNode('LowTemperatureRadiantProperties');
            if Assigned(grandChildNode) then
            begin
              aConstruct.LowTemperatureRadiantProperties.SourcePresentAfterLayerNumber := IntegerValueFromPath(grandChildNode, 'SourcePresentAfterLayerNumber');
              aConstruct.LowTemperatureRadiantProperties.TempCalcAfterLayerNumber := IntegerValueFromPath(grandChildNode, 'TempCalcAfterLayerNumber');
              aConstruct.LowTemperatureRadiantProperties.DimensionsForCTFCalculation := IntegerValueFromPath(grandChildNode, 'DimensionsForCTFCalculation');
              aConstruct.LowTemperatureRadiantProperties.TubeSpacing := FloatValueFromPath(grandChildNode, 'TubeSpacing');
            end;
            aConstruct.AddLayers(node.nodes[i]);
          end;
        end;
      end;
    end;
  end
  else //use external file for constructions
  begin
    //the file names are already going to be simple but set flag nonetheless.
    bSimpleNamesForConst := true;
    BldgConstructions.UseExternalFileForConstructions := true;
    //create the constructions with the simple names
    sConstructName := 'window_south';
    // ksb: I think this is a memory leak.
    // ksb: where is this object being destroyed?
    aConstruct := T_EP_Construction.Create;
    if BldgConstructions.AddToBldgConstructions(sConstructName, 'south', aConstruct) then
    begin
      aConstruct.Typ := 'Fenestration';
    end;
    sConstructName := 'window_east';
    if BldgConstructions.AddToBldgConstructions(sConstructName, 'east', aConstruct) then
    begin
      aConstruct.Typ := 'Fenestration';
    end;
    sConstructName := 'window_north';
    if BldgConstructions.AddToBldgConstructions(sConstructName, 'north', aConstruct) then
    begin
      aConstruct.Typ := 'Fenestration';
    end;
    sConstructName := 'window_west';
    if BldgConstructions.AddToBldgConstructions(sConstructName, 'west', aConstruct) then
    begin
      aConstruct.Typ := 'Fenestration';
    end;
    sConstructName := 'window_skylightconst';
    if BldgConstructions.AddToBldgConstructions(sConstructName, 'SkylightConst', aConstruct) then
    begin
      aConstruct.Typ := 'Fenestration';
    end;
    sConstructName := 'dl_window_south';
    if BldgConstructions.AddToBldgConstructions(sConstructName, 'south', aConstruct) then
    begin
      aConstruct.Typ := 'DaylightFenestration';
    end;
    sConstructName := 'dl_window_east';
    if BldgConstructions.AddToBldgConstructions(sConstructName, 'east', aConstruct) then
    begin
      aConstruct.Typ := 'DaylightFenestration';
    end;
    sConstructName := 'dl_window_north';
    if BldgConstructions.AddToBldgConstructions(sConstructName, 'north', aConstruct) then
    begin
      aConstruct.Typ := 'DaylightFenestration';
    end;
    sConstructName := 'dl_window_west';
    if BldgConstructions.AddToBldgConstructions(sConstructName, 'west', aConstruct) then
    begin
      aConstruct.Typ := 'DaylightFenestration';
    end;
    sConstructName := 'roofs';
    if BldgConstructions.AddToBldgConstructions(sConstructName, sConstructName, aConstruct) then
    begin
      aConstruct.Typ := 'Opaque';
      //todo: infiltration per area?
    end;
    sConstructName := 'int-walls';
    if BldgConstructions.AddToBldgConstructions(sConstructName, sConstructName, aConstruct) then
    begin
      aConstruct.Typ := 'Opaque';
      //todo: infiltration per area?
    end;
    sConstructName := 'ext-walls';
    if BldgConstructions.AddToBldgConstructions(sConstructName, sConstructName, aConstruct) then
    begin
      aConstruct.Typ := 'Opaque';
      //todo: infiltration per area?
    end;
    sConstructName := 'ext-slab';
    if BldgConstructions.AddToBldgConstructions(sConstructName, sConstructName, aConstruct) then
    begin
      aConstruct.Typ := 'Opaque';
      //todo: infiltration per area?
    end;
    sConstructName := 'attic-floor';
    if BldgConstructions.AddToBldgConstructions(sConstructName, sConstructName, aConstruct) then
    begin
      aConstruct.Typ := 'Opaque';
      //todo: infiltration per area?
    end;
    sConstructName := 'exposed-floor';
    if BldgConstructions.AddToBldgConstructions(sConstructName, sConstructName, aConstruct) then
    begin
      aConstruct.Typ := 'Opaque';
      //todo: infiltration per area?
    end;
  end;
  Node := RootNode.FindNode('/HPBParametization/Building');
  if Assigned(Node) then
  begin
    writeln('Creating geometry');
    Geometry := T_EP_Geometry.Create; //store the globals into the EP geometry object
    Building.Name := StringValueFromPath(Node, 'Name', false);
    Building.HeaderInformation := StringValueFromPath(Node, 'HeaderInformation', false);
    Building.LegalNoticeType := StringValueFromPath(Node, 'LegalNoticeType', True, 'EEFG');
    EPSettings.BuildingName := Building.Name;
    EPSettings.BuildingTerrain := StringValueFromPath(Node,'Terrain',False,'City');
    EPSettings.SolarDistribution := StringValueFromPath(Node,'SolarDistribution',False,'FullInteriorAndExterior');
    Geometry.Rotation := FloatValueFromPath(Node, 'Rotation');
    //also save this in the settings to write it out
    EPSettings.Rotation := Geometry.Rotation;
    BldgRotation := Geometry.Rotation;
    Geometry.NumFloors := IntegerValueFromPath(Node, 'NumFloors');
    Geometry.TmpNumFloors := Geometry.NumFloors;
    Geometry.TotalArea := FloatValueFromPath(Node, 'Area');
    Geometry.AtticHeight := FloatValueFromPath(Node, 'AtticHeight', 0);
    Geometry.RoofTiltAngle := FloatValueFromPath(Node, 'RoofTiltAngle', 0);
    Geometry.PerimDepth := FloatValueFromPath(Node, 'PerimDepth', 2.57);
    Geometry.FloortoFloorHeight := FloatValueFromPath(Node, 'FloortoFloorHeight', 3.8);
    Geometry.PlenumHeight := FloatValueFromPath(Node, 'PlenumHeight', 0.0);
    Geometry.RaisedFloorHeight := FloatValueFromPath(Node, 'RaisedFloorHeight', 0.0);
    Geometry.DivideVertWallFactor := FloatValueFromPath(Node, 'DivideVertWallFactor', 0);
    Geometry.UseReturnPlenum := BooleanValueFromPath(Node, 'UseReturnPlenum');
    Geometry.UseVirtualPlenum := BooleanValueFromPath(Node, 'UseVirtualPlenum', False);
    Geometry.SuppressFloorMultipliers := BooleanValueFromPath(Node, 'SuppressFloorMultipliers', False);
    Geometry.SuppressRoofMultipliers := BooleanValueFromPath(Node, 'SuppressRoofMultipliers');
    Geometry.UseRelativeAngles := BooleanValueFromPath(Node, 'UseRelativeAngles');
    Geometry.BuildingFootprint := BooleanValueFromPath(Node, 'Footprint');
    aFloorList := TList.Create;
    try
      Node.FindNodes('Floor', aFloorList);
      if (not Geometry.BuildingFootPrint) and (aFloorList.Count > 0) then
      begin
        Geometry.NumFloors := aFloorList.Count;
        Geometry.TmpNumFloors := Geometry.NumFloors;
      end;
      for iFloor := 0 to aFloorList.Count - 1 do
      begin
        if (Geometry.BuildingFootPrint) and (iFloor > 0) then
        begin
          T_EP_PPErrorMessage.AddErrorMessage(esWarning, 'Only expecting one floor for the building footprint');
          continue;
        end;
        ndFloor := TXmlNode(aFloorList[iFloor]);
        ndFootprint := ndFloor.FindNode(StringValueFromPath(ndFloor, 'FootprintType', False));
        if Assigned(ndFootprint) then
        begin
          //get the geometry values
          if ndFootprint.Name <> 'Custom' then
          begin
            //create a single footprint
            aFootPrint := Geometry.AddFootPrint(ndFootprint.Name);
            aFootPrint.ZoneLayout := StringValueFromPath(ndFootprint, 'ZoneLayout');
            aFootPrint.ZoneNameMoniker := StringValueFromPath(ndFootprint, 'ZoneMoniker', False);
            aFootPrint.ZoneDescription := StringValueFromPath(ndFootprint, 'SectionDescription', False);
            aFootPrint.FloorNum := iFloor + 1;
            aFootPrint.FloorToFloorHeight := Geometry.FloortoFloorHeight;
            aFootPrint.Length1 := FloatValueFromAttribute(ndFootprint, 'Length1', 0);
            aFootPrint.Length2 := FloatValueFromAttribute(ndFootprint, 'Length2', 0);
            aFootPrint.Width1 := FloatValueFromAttribute(ndFootprint, 'Width1', 0);
            aFootPrint.Width2 := FloatValueFromAttribute(ndFootprint, 'Width2', 0);
            aFootPrint.Offset1 := FloatValueFromAttribute(ndFootprint, 'Offset1', 0);
            aFootPrint.Offset2 := FloatValueFromAttribute(ndFootprint, 'Offset2', 0);
            aFootPrint.Offset3 := FloatValueFromAttribute(ndFootprint, 'Offset3', 0);
            aFootPrint.End1 := FloatValueFromAttribute(ndFootprint, 'End1', 0);
            aFootPrint.End2 := FloatValueFromAttribute(ndFootprint, 'End2', 0);
            aFootPrint.X1 := FloatValueFromAttribute(ndFootprint, 'X1', 0);
            aFootPrint.X2 := FloatValueFromAttribute(ndFootprint, 'X2', 0);
            aFootPrint.X3 := FloatValueFromAttribute(ndFootprint, 'X3', 0);
            aFootPrint.Y1 := FloatValueFromAttribute(ndFootprint, 'Y1', 0);
            aFootPrint.Y2 := FloatValueFromAttribute(ndFootprint, 'Y2', 0);
            aFootPrint.Y3 := FloatValueFromAttribute(ndFootprint, 'Y3', 0);
          end
          else if ndFootprint.Name = 'Custom' then
          begin
            //get all custom
            aCustomList := TList.Create;
            aList := TList.Create;
            try
              ndFloor.FindNodes('Custom', aCustomList);
              if aCustomList.Count > 0 then
                for iCL := 0 to aCustomList.Count - 1 do
                begin
                  aCustomNode := TXmlNode(aCustomList[iCL]);
                  aFootPrint := Geometry.AddFootPrint(ndFootprint.Name);
                  aFootPrint.ZoneLayout := StringValueFromPath(ndFootprint, 'ZoneLayout');
                  aFootPrint.ZoneNameMoniker := StringValueFromPath(ndFootprint, 'ZoneMoniker', False);
                  aFootPrint.ZoneDescription := StringValueFromPath(ndFootprint, 'SectionDescription', False);
                  aFootPrint.FloorNum := iFloor + 1;
                  aCustomNode.NodesByName('Point', aList);
                  if aList.Count > 0 then
                    for i := 0 to aList.Count - 1 do
                    begin
                      aNode := TXmlNode(aList[i]);
                      x1 := FloatValueFromAttribute(aNode, 'X1', 0.0);
                      y1 := FloatValueFromAttribute(aNode, 'Y1', 0.0);
                      z1 := Geometry.FloortoFloorHeight;
                      aFootPrint.AddPoint(x1, y1, z1);
                    end;
                end; //if aCustomList
            finally
              aCustomList.Free;
              aList.Free;
            end; //try
          end; //if ndFootprint.name
        end;
      end;
    finally
      aFloorList.Free;
    end;
    Geometry.DetermineZones;
    //read in the customXYZ values
    lZones := TList.Create;
    Node.FindNodes('Zone',lZones);
    try
      for iZone := 0 to lZones.Count-1 do
      begin
        ndZone := TXmlNode(lZones[iZone]);
        ndCustomXYZ := ndZone.FindNode('CustomXYZ');
        if assigned(ndCustomXYZ) then
        begin
          //pass the Zone node because it has props that need to be copied
          //to the zone object.
          Geometry.ProcessCustomXYZ(ndZone);
        end;
      end;
    finally
      lZones.Free;
    end;
    //go through all the zones and surfaces and check if need to
    //create adjacent wall because of "unenteredotherzonesurface" flag
    for iZone := 0 to Zones.Count - 1 do
    begin
      Zone := T_EP_Zone(zones[iZone]);
      for iSurf := 0 to Zone.Surfaces.Count-1 do
      begin
        aSurf := T_EP_Surface(Zone.Surfaces[iSurf]);
        if (aSurf.OutsideEnvironment = oeUnenteredOtherZoneSurface) then
        begin
          newSurf := T_EP_Surface.Create;
          newSurf.Name := aSurf.Name + '-PPAutoCreateOther';
          newSurf.ZoneName := aSurf.OutsideObject;
          //writeln('Autocreated other surface ' + newSurf.Name);
          if aSurf.Typ = stCeiling then
            newSurf.SetType(stFloor)
          else if aSurf.Typ = stFloor then
            newSurf.SetType(stCeiling)
          else
            newSurf.SetType(aSurf.Typ);
          //assume symmetric construction when auto-create other
          newSurf.SetConstruction(aSurf.Construction);
          for iVert := aSurf.Verts.Count-1 downto 0 do
          begin
            newSurf.Verts.Add(aSurf.Verts[iVert]);
          end;
          newSurf.Verts.Finalize();
          newSurf.FindWallProperties;
          addZone := GetZone(aSurf.OutsideObject);
          addZone.AddSurface(newSurf);
        end;
      end;
    end;
    //Get the zone properties for all the zones
    //get zone areas and volumes and number of wallturns
    Geometry.TotalArea := 0;
    for iZone := 0 to Zones.Count - 1 do
    begin
      zone := T_EP_Zone(zones[iZone]);
      Zone.GetZoneArea;
      Zone.GetZoneVolume;
      Zone.GetWallTurns;
      //if virtual plenums
      if Geometry.UseVirtualPlenum then
      begin
        Zone.AirVolume := Zone.AirVolume -
          (Zone.Area * (Zone.CeilingHeight - Geometry.PlenumHeight));
      end;
      if not Zone.ExcludeInTotalBuildingArea then
        Geometry.TotalArea := Geometry.TotalArea + (Zone.Area * Zone.ZoneMultiplier);
    end;
  end;
  //apply floor multipliers to seperate zones, set adiabatic surfaces
  //zone multipliers will be processed later
  Building.ApplyFloorMultipliers;
  //go through and find all the zones and surfaces to find the
  //adiabatic walls and assign the correct specific surface types
  Building.FinalizeBoundaryConditions;
  //processing zone info will read zone multipliers, loads, and set surface specific types due to floor multipliers
  aList := TList.Create;
  try
    RootNode.FindNodes('/HPBParametization/Building/Zone', aList);
    if aList.Count <> 0 then
      for iZone := 0 to aList.Count - 1 do
      begin
        aNode := TXmlNode(aList.Items[iZone]);
        sZoneName := StringValueFromPath(aNode, 'Name');
        if SameText(sZoneName, 'All') then
        begin
          for i := 0 to Zones.Count - 1 do
          begin
            zone := T_EP_Zone(zones[i]);
            Zone.ProcessZoneInfo(aNode);  //calculate zone windows, overhands, loads, etc
          end;
        end
        else if SameText(sZoneName, 'All-Other') then
        begin
          for i := 0 to Zones.Count - 1 do
          begin
            zone := T_EP_Zone(zones[i]);
            if not Zone.ZoneIntGainsProcessed then
              zone.ProcessZoneInfo(aNode); //calculate zone windows, overhands, loads, etc
          end;
        end
        else
        begin
          for i := 0 to Zones.Count - 1 do
          begin
            zone := T_EP_Zone(zones[i]);
            if SameText(zone.Name, sZoneName) then
            begin
              zone.ProcessZoneInfo(aNode); //calculate zone windows, overhands, loads, etc
            end;
          end;
        end;
      end;
  finally
    aList.free;
  end;
  Node := RootNode.FindNode('/HPBParametization/PerformanceCurves');
  if assigned(Node) then
  begin
    aList := TList.Create;
    Node.FindNodes('CurveCubic', aList);
   for i := 0 to aList.Count - 1 do
   begin
      aNode := TXmlNode(aList.Items[i]);
      curve_cubic := T_Curve_Cubic.create;
      curve_cubic.name := StringValueFromPath(aNode, 'Name', False, '-9999');
      curve_cubic.Coeff1 := FloatValueFrompath(aNode, 'Coeff1', -9999);
      curve_cubic.Coeff2 := FloatValueFrompath(aNode, 'Coeff2', -9999);
      curve_cubic.Coeff3 := FloatValueFrompath(aNode, 'Coeff3', -9999);
      curve_cubic.Coeff4 := FloatValueFrompath(aNode, 'Coeff4', -9999);
      curve_cubic.minimum_value_of_x := FloatValueFrompath(aNode, 'MinimumValueOfX', -9999);
      curve_cubic.maximum_value_of_x := FloatValueFrompath(aNode, 'MaximumValueOfX', -9999);
    end;
    aList.Free;
  end;
  // ElectricLoadCenter
  // TODO: add other generator types, 'wind', 'hydro', etc
  // TODO: attractive layout of generation, fenestration, etc
  //PV-Simple
  Node := RootNode.FindNode('/HPBParametization/Building/PV-Simple');
  if assigned(Node) then
  begin
    //create electric load center, if not already created
    if not Assigned(ElectricLoadCenter) then
      ElectricLoadCenter := T_EP_ElectricLoadCenter.Create;
    SimplePV_Params.PVMode := StringValueFromPath(Node, 'Mode', True, 'ROOF ONLY');
    SimplePV_Params.PVAreaFraction := FloatValueFromPath(Node, 'PVAreaFraction');
    SimplePV_Params.PVInstalledCap := FloatValueFromPath(Node, 'PVInstalledCap');
    SimplePV_Params.PVEfficiency := FloatValueFromPath(Node, 'PVEfficiency');
    SimplePV_Params.PVInverterEff := FloatValueFromPath(Node, 'PVInverterEff');
    SimplePV_Params.IntegrationMode := StringValueFromPath(Node, 'IntegrationMode', True, 'DECOUPLED');
    SimplePV_Params.OrientationAngle := FloatValueFromPath(Node, 'OrientationAngle', 0.0);
    SimplePV_Params.TiltAngle := FloatValueFromPath(Node, 'TiltAngle', 0.0);
    aList := TList.Create;
    SimplePV_Params.ExistingSurfaces := TStringList.Create;
    try
      Node.FindNodes('ExistingSurfaces', aList);
      for i := 0 to aList.Count-1 do
      begin
        aNode := TXmlNode(aList[i]);
        SimplePV_Params.ExistingSurfaces.Add(StringValueFromPath(aNode, 'SurfaceName', False));
      end;
    finally
      aList.Free;
    end;
    ElectricLoadCenter_Params.HasSimplePV := true;
    ElectricLoadCenter_Params.SimplePV_Params := SimplePV_Params;
  end;
  // detached shading
  Node := RootNode.FindNode('/HPBParametization/Building/DetachedShading');
  if Assigned(Node) then
  begin
    aList := TList.Create;
    Node.FindNodes('CustomXYZSurfaces',aList);
    try
      for iShade := 0 to aList.Count-1 do
      begin
        ndShade := TXmlNode(aList[iShade]);
        Geometry.ProcessDetachedShadingCustomXYZ(ndShade);
      end;
    finally
        aList.Free;
    end;
  end;
  //add exterior lights
  aNode := RootNode.FindNode('/HPBParametization/ExteriorLoads/ExteriorFacadeLights');
  if Assigned(aNode) then
  begin
    valr := FloatValueFromAttribute(aNode, 'instance', 0);
    vali := IntegerValueFromPath(aNode, 'FloorNumber', 1);
    valr2 := FloatValueFromPath(aNode, 'TotalPower', 0);
    valr3 := FloatValueFromPath(aNode, 'PowerDensity', 0);
    vals := StringValueFromPath(aNode, 'ScheduleName', False, 'ALWAYS_ON');
    vals2 := StringValueFromPath(aNode, 'ControlOption', False, 'AstronomicalClock');
    if (valr <> 0) or (valr2 <> 0) or (valr3 <> 0) then
    begin
      Building.AddExteriorLights(valr, vali, valr2, valr3, vals, vals2);
    end;
  end;
  Node := RootNode.FindNode('/HPBParametization/ExteriorLoads/RefrigerationSimpleIntensity');
  if Assigned(Node) then
  begin
    valr := FloatValueFromAttribute(node, 'instance');
    costVal := FloatValueFromAttribute(node, 'CostPer');
    if valr <> 0 then
    begin
      Building.AddSimpleRefrigeration(valr, costVal);
    end;
  end;
  //grab the macro libraries needed - schedules, etc
  sMacroPath := '';
  //add exterior lights
  Node := RootNode.FindNode('/HPBParametization/MacroControl');
  if Assigned(Node) then
  begin
    sMacroPath := StringValueFromAttribute(node, 'path', false);
  end;
  //schedules
  Node := RootNode.FindNode('/HPBParametization/ScheduleSet');
  if Assigned(Node) then
  begin
    aSchedule := T_EP_Schedule.Create;
    sTemp := StringValueFromAttribute(Node, 'instance', False);
    //also grab sched types
    GrabTextFromFile(sMacroPath + '/HPBScheduleSets.imf', 'ScheduleTypes', aSchedule.SchedTypeLibrary);
    if sTemp <> 'Substitution' then
      GrabTextFromFile(sMacroPath + '/HPBScheduleSets.imf', sTemp, aSchedule.SchedLibrary);
    //add costs
  end;
  //design days and utility costs
  Node := RootNode.FindNode('/HPBParametization/SiteParams');
  if Assigned(Node) then
  begin
    ChildNode := Node.FindNode('WeatherFile');
    if Assigned(ChildNode) then
    begin
      sTemp := StringValueFromAttribute(ChildNode, 'filename', false);
      Building.SimMetaData.Values['WeatherFileName'] := sTemp;
    end;
    ChildNode := Node.FindNode('DesignDays');
    if assigned(childnode) then
    begin
      sTemp := StringValueFromAttribute(ChildNode, 'instance', false);
      GrabTextFromFile(sMacroPath + '/HPBLocationDependSets.imf', sTemp,
        Building.DesignDayLibrary);
      //add costs
    end;
    ChildNode := Node.FindNode('UtilityCosts');
    if assigned(childnode) then
    begin
      sTemp := StringValueFromAttribute(ChildNode, 'instance', false);
      GrabTextFromFile(sMacroPath + '/HPBUtilityRateSets.imf', sTemp,
        Building.UtilityRatesLibrary);
      //add costs
    end;
  end;
  //just grab the US holidays if not purposely omitted
  Node := RootNode.FindNode('/HPBParametization/SimSettings');
  bTemp := true;
  bTemp := BooleanValueFromPath(Node, 'Holidays', true);
  if bTemp then
    GrabTextFromFile(sMacroPath + '/USHolidays-DST.imf', 'USA_Holidays_DST',
      Building.USHolidaysLibrary);
  //standard constructions
  Node := RootNode.FindNode('/HPBParametization/SpecificConstructs');
  if Assigned(Node) then
  begin
    sTemp := StringValueFromAttribute(node, 'StaticObjectsFile', false);
    if EPSettings.Costs then
      GrabTextFromFile(sMacroPath + '/' + sTemp, 'Static_Constructions',
        BldgConstructions.StaticLibrary)
    else
      GrabTextFromFile(sMacroPath + '/' + sTemp, 'Static_Constructions_No_Costs',
        BldgConstructions.StaticLibrary)
  end;
  //external file for consturcitons
  if bUseExtFileForConst then
  begin
    GrabTextFromFile(sMacroPath + '/' + sExtFileNameForConst, sExtFileDefForConst,
      BldgConstructions.ExternalConstructionFile);
  end;
  //report vars
  Node := RootNode.FindNode('/HPBParametization/MacroControl');
  if Assigned(Node) then
  begin
    sTemp := StringValueFromAttribute(node, 'ReportVarSetKey', false);
    if sTemp = 'Substitution' then
    begin
      //do nothing
    end
    else
    begin
    GrabTextFromFile(sMacroPath + '/HPBReportVariableSets.imf', sTemp,
      Building.ReportVariables.VariableLibrary);
    end;
  end;
  //direct substitution
  Node := RootNode.FindNode('/HPBParametization/TextInput');
  if Assigned(Node) then
  begin
    aList := TList.Create;
    try
      Node.FindNodes('DirectSubstitution', aList);
      for i := 0 to aList.count - 1 do
      begin
        aNode := TxmlNode(aList[i]).FindNode('SubCategory');
        if assigned(aNode) then
        begin
          //if aNode.HasAttribute('instance') then
          //    sCatName := ChildNode_2.AttributeByName['instance'];
          //if ChildNode_2.HasAttribute('CostPer') then
          //    sMatCost := ChildNode_2.AttributeByName['CostPer'];
        end;
        sSubText := TxmlNode(aList.Items[i]).FindNode('SubText').ValueAsString;
        //Replace XML escape characters for EnergyPlus EMS code
        sSubText := ReplaceRegExpr('&lt;', sSubText, '<', false);
        sSubText := ReplaceRegExpr('&gt;', sSubText, '>', false);
        sSubText := ReplaceRegExpr('&amp;', sSubText, '&', false);
        sSubText := ReplaceRegExpr('&quot;', sSubText, '"', false);
        sSubText := ReplaceRegExpr('&apos;', sSubText, '''', false);
        Building.DirectSubText.Add(sSubText);
      end;
    finally
      aList.Free;
    end;
  end;
  //add sim meta data
  Node := RootNode.FindNode('/HPBParametization/CodeStandardSettings');
  if Assigned(Node) then
  begin
    //todo: grab all the standards that have been applied
    Building.SimMetaData.Values['CodeStandard'] :=
      StringValueFromPath(Node, 'CodeStandard', False);
    Building.SimMetaData.Values['RoofConstruction'] :=
      StringValueFromPath(Node, 'RoofConstruction', False);
    Building.SimMetaData.Values['ExtWallConstruction'] :=
      StringValueFromPath(Node, 'ExtWallConstruction', False);
    Building.SimMetaData.Values['ExtWallSlabConstruction'] :=
      StringValueFromPath(Node, 'ExtWallSlabConstruction', False);
  end;
  //add webinterface input ids if available
  Node := RootNode.FindNode('/HPBParametization/WebInterfaceSettings');
  if Assigned(Node) then
  begin
    Building.WebInterfaceParameters.CommaText := StringValueFromPath(Node, 'InputIDs', False);
    Building.WebInterfaceBldgDescription := StringValueFromPath(Node, 'BuildingDescription', False);
    //clean string to be compatible with EnergyPlus IDF
    Building.WebInterfaceBldgDescription :=
      StringReplace(Building.WebInterfaceBldgDescription, '!', '', [rfReplaceAll]);
    Building.WebInterfaceBldgDescription :=
      StringReplace(Building.WebInterfaceBldgDescription, ',', '', [rfReplaceAll]);
    Building.WebInterfaceBldgDescription :=
      StringReplace(Building.WebInterfaceBldgDescription, ';', '', [rfReplaceAll]);
    //rename building
    EPSettings.BuildingName := Building.WebInterfaceBldgDescription;
  end;
  WriteLn('Reading HVAC');
  // Determine system connection scope
  Node := RootNode.FindNode('/HPBParametization/HVACSystem/DetailedHVAC/SystemScope');
  if Assigned(Node) then
    Scope := Node.ValueAsString
  else
    Scope := 'Building';
  Scope := 'Building'; // only BUILDING works for now
  if Scope = 'Building' then
  begin
    //get zone scope
    //either all the zones get a similar treatment, or each zone is described seperately
    //If the geometry configuration isn't hardwired (currently on 101, 201, 501, 503, 521, and 523)
    //then the zones need to be defined individually (and you probably want it that way)
    Node := RootNode.FindNode('/HPBParametization/HVACSystem/DetailedHVAC');
    if Assigned(Node) then
    begin
      zoneScope := StringValueFromPath(Node, 'ZoneScope');
    end;
    // get hvac values for all zones
    // this might be moved to a method in T_EP_Building
    Node := RootNode.FindNode('/HPBParametization/HVACSystem/DetailedHVAC');
    if Assigned(Node) then
    begin
      aList := TList.Create;
      try
        Node.FindNodes('Zone', aList);
        for iList := 0 to aList.Count-1 do
        begin
          ChildNode := TXmlNode(aList[iList]);
          sZoneName := StringValuefromPath(ChildNode, 'ZoneName');
          for iZone := 0 to zones.Count - 1 do
          begin
            Zone := T_EP_Zone(Zones[iZone]);
            if (sZoneName = 'ALL') or
               (sZoneName = UpperCase(Zone.Name)) or
               (sZoneName = 'ALL-OTHER') or
               (SameText(zoneScope, 'UNIFORM ZONES FROM CONFIGURATION')) then     //for backward compatibility
            begin
              if zone.HoursPerDay = 0 then
                Zone.HoursPerDay := FloatValuefromPath(ChildNode, 'TypicalHoursPerDay');
            end;
          end;
        end;
      finally
        aList.Free;
      end;
    end; //if assigned
    // Set zone details
    for i := 0 to Zones.Count - 1 do
    begin
      Zone := T_EP_Zone(Zones[i]);
      if (not Zone.OccupiedConditioned) then
      begin
        continue;
      end;
      // loop through zone xml nodes to find the one that matches Zone.name
      ParentNode := RootNode.FindNode('/HPBParametization/HVACSystem/DetailedHVAC');
      if Assigned(ParentNode) then
      begin
        slZones.Clear;
        ParentNode.FindNodes('Zone', slZones);
        for j := 0 to slZones.Count-1 do
        begin
          ChildNode := TXmlNode(slZones[j]);
          tempName := StringValuefromPath(ChildNode, 'ZoneName');
          if (tempName = 'ALL') or
             (SameText(Zone.Name, tempName)) or
             (tempName = 'ALL-OTHER') or
             (SameText(zoneScope, 'UNIFORM ZONES FROM CONFIGURATION')) then  //for backward compatibility
          begin
            if not Zone.ZoneHVACProcessed then
            begin
              zone.ZoneHVACProcessed := true;
              Node := ChildNode;
            end;
            break;
          end; // if ZoneName.
        end; // nodes below zone
      end; // zone node
      // "Node" is the Zone xml element for this Zone
      // search the children, grand children, etc of this Zone xml Node
      if ((Node.NodeCount > 0) and (Zone.ZoneHVACProcessed)) then
      begin
        for j := 0 to Node.NodeCount - 1 do
        begin
          childNode := Node.Nodes[J];
          if childNode.Name = 'SpaceConditioning' then
          begin
            if ChildNode.NodeCount > 0 then
            begin
              for k := 0 to ChildNode.NodeCount - 1 do
              begin
                grandChildNode := ChildNode.Nodes[k];
                if GrandChildNode.Name = 'Sizing' then
                begin
                  Zone.OAPerArea := FloatValueFromPath(GrandChildNode, 'OAPerArea', 0.0);
                  Zone.OAPerPerson := FloatValueFromPath(GrandChildNode, 'OAPerPerson', 0.0);
                  Zone.OAPerZone := FloatValueFromPath(GrandChildNode, 'OAPerZone', 0.0);
                  Zone.OAPerACH := FloatValueFromPath(GrandChildNode, 'OAPerACH', 0.0);
                  Zone.ZoneSizingFactor := FloatValueFromPath(GrandChildNode, 'ZoneSizingFactor', 0.0);
                  GreatGrandChildNode := GrandChildNode.FindNode('CoolingDesignAirFlowMethod');
                  if Assigned(GreatGrandChildNode) then
                    Zone.CoolingDesignAirFlowMethod := StringValueFromPath(GreatGrandChildNode,'Type', false, 'DesignDayWithLimit');
                  if Assigned(GreatGrandChildNode) then
                    Zone.CoolingDesignAirFlowRate := FloatValueFromPath(GreatGrandChildNode,'CoolingDesignAirFlowRate', -999.0);
                  GreatGrandChildNode := GrandChildNode.FindNode('CoolingMinAirFlow');
                  if Assigned(GreatGrandChildNode) then
                    Zone.CoolingMinAirFlowPerArea := FloatValueFromPath(GreatGrandChildNode,'CoolingMinAirFlowPerArea', -999.0);
                  if Assigned(GreatGrandChildNode) then
                    Zone.CoolingMinAirFlowPerZone := FloatValueFromPath(GreatGrandChildNode,'CoolingMinAirFlowPerZone', -999.0);
                  if Assigned(GreatGrandChildNode) then
                    Zone.CoolingMinAirFlowACH := FloatValueFromPath(GreatGrandChildNode,'CoolingMinAirFlowACH', -999.0);
                  if Assigned(GreatGrandChildNode) then
                    Zone.CoolingMinAirFlowFraction := FloatValueFromPath(GreatGrandChildNode,'CoolingMinAirFlowFraction', -999.0);
                  GreatGrandChildNode := GrandChildNode.FindNode('AirDistributionEffectiveness');
                  if Assigned(GreatGrandChildNode) then
                    Zone.AirDistributionEffectivenessCooling := FloatValueFromPath(GreatGrandChildNode,'AirDistributionEffectivenessCooling', 1.0);
                  if Assigned(GreatGrandChildNode) then
                    Zone.AirDistributionEffectivenessHeating := FloatValueFromPath(GreatGrandChildNode,'AirDistributionEffectivenessHeating', 1.0);
                  if Assigned(GreatGrandChildNode) then
                    Zone.AirDistributionEffectivenessSchedule := StringValueFromPath(GreatGrandChildNode,'AirDistributionEffectivenessSchedule', False, '');
                  GreatGrandChildNode := GrandChildNode.FindNode('DesignSupplyAirConditions');
                  if Assigned(GreatGrandChildNode) then
                    Zone.CoolingDesignSupplyAirTemperature := FloatValueFromPath(GreatGrandChildNode, 'CoolingDesignSupplyAirTemperature', 14.0);
                  if Assigned(GreatGrandChildNode) then
                    Zone.HeatingDesignSupplyAirTemperature := FloatValueFromPath(GreatGrandChildNode, 'HeatingDesignSupplyAirTemperature', 40.0);
                  if Assigned(GreatGrandChildNode) then
                    Zone.CoolingDesignSupplyAirHumidityRatio := FloatValueFromPath(GreatGrandChildNode, 'CoolingDesignSupplyAirHumidityRatio', 0.0085);
                  if Assigned(GreatGrandChildNode) then
                    Zone.HeatingDesignSupplyAirHumidityRatio := FloatValueFromPath(GreatGrandChildNode, 'HeatingDesignSupplyAirHumidityRatio', 0.008);
                end
                else if GrandChildNode.Name = 'Thermostat' then
                begin
                  // Determine zone thermostat settings
                  Zone.UsePrecooling := BooleanValueFromPath(Node, 'UsePrecooling');
                  Zone.HeatSP_Sch := StringValueFromPath(GrandChildNode, 'HeatingSetpointSchedule', False, 'HtgSetP_Sch');
                  Zone.CoolSP_Sch := StringValueFromPath(GrandChildNode, 'CoolingSetpointSchedule', False, 'ClgSetP_Sch');
                end
                else if GrandChildNode.Name = 'Humidistat' then
                begin
                  //determine humidistat settings for zone
                  Zone.UseHumidistat := true;
                  Zone.MinRelHumSetSch := StringValueFromPath(GrandChildNode, 'MinRelHumSetSch',false,'MinRelHumSetSch');
                  Zone.MaxRelHumSetSch := StringValueFromPath(GrandChildNode, 'MaxRelHumSetSch',false,'MaxRelHumSetSch');
                end
                else if GrandChildNode.Name = 'DemandControlVentilation' then
                begin
                  zone.DemandControlVentilation := true;
                end
                else if GrandChildNode.Name = 'VentilationSimple' then
                begin
                  ventilationSimple := T_EP_VentilationSimple.Create;
                  if GrandChildNode.NodeCount > 0 then
                  begin
                    for l := 0 to GrandChildNode.NodeCount - 1 do
                    begin
                      ventilationSimple.ZoneName := zone.Name;
                      ventilationSimple.Name := zone.Name + '_' + IntToStr(l + 1) + '_Ventilation';
                      GreatGrandChildNode := GrandChildNode.Nodes[l];
                      if GreatGrandChildNode.Name = 'FanPressureDrop' then
                      begin
                        ventilationSimple.FanPressureDrop := FloatValueFromPath(GrandChildNode, 'FanPressureDrop', -999.0);
                      end
                      else if GreatGrandChildNode.Name = 'FanEfficiency' then
                      begin
                        ventilationSimple.FanEfficiency := FloatValueFromPath(GrandChildNode, 'FanEfficiency', -999.0);
                      end
                      else if GreatGrandChildNode.Name = 'MotorizedDamper' then
                      begin
                        ventilationSimple.MotorizedDamper := BooleanValueFromPath(GrandChildNode, 'MotorizedDamper', false);
                      end
                      else if GreatGrandChildNode.Name = 'DesignFlowRate' then
                      begin
                        ventilationSimple.DesignFlowRate := FloatValueFromPath(GrandChildNode, 'DesignFlowRate', -999.0);
                      end
                      else if GreatGrandChildNode.Name = 'Type' then
                      begin
                        ventilationSimple.VentilationType := StringValueFromPath(GrandChildNode, 'Type', False, '');
                      end
                      else if GreatGrandChildNode.Name = 'MinOASchedule' then
                      begin
                        ventilationSimple.MinOASchedule := StringValueFromPath(GrandChildNode, 'MinOASchedule');
                      end
                      else if GreatGrandChildNode.Name = 'MinimumIndoorTemp' then
                      begin
                        ventilationSimple.MinimumIndoorTemp := FloatValueFromPath(GrandChildNode, 'MinimumIndoorTemp', 5.0);
                      end
                      else if GreatGrandChildNode.Name = 'MaximumIndoorTemp' then
                      begin
                        ventilationSimple.MaximumIndoorTemp := FloatValueFromPath(GrandChildNode, 'MaximumIndoorTemp', 35.0);
                      end
                      else if GreatGrandChildNode.Name = 'MinimumOutdoorTemp' then
                      begin
                        ventilationSimple.MinimumOutdoorTemp := FloatValueFromPath(GrandChildNode, 'MinimumOutdoorTemp', -30.0);
                      end
                      else if GreatGrandChildNode.Name = 'MaximumOutdoorTemp' then
                      begin
                        ventilationSimple.MaximumOutdoorTemp := FloatValueFromPath(GrandChildNode, 'MaximmumOutdoorTemp', 50.0);
                      end
                      else if GreatGrandChildNode.Name = 'DeltaTemp' then
                      begin
                        ventilationSimple.DeltaTemp := FloatValueFromPath(GrandChildNode, 'DeltaTemp', -30.0);
                      end;
                    end; //for
                    zone.VentilationSimpleObjects.Add(ventilationSimple);
                  end;
                end
                else if GrandChildNode.Name = 'HasHPWH' then
                begin
                  Zone.HasHPWH := true;
                end
                else if GrandChildNode.Name = 'Equipment' then
                begin
                  ExhaustFanID := 1;
                  if GrandChildNode.NodeCount > 0 then
                  begin
                    for l := 0 to GrandChildNode.NodeCount - 1 do
                    begin
                      GreatGrandChildNode := GrandChildNode.Nodes[l];
                      if GreatGrandChildNode.Name = 'ExhaustFan' then
                      begin
                        Component := T_EP_ExhaustFan.Create;
                        T_EP_ExhaustFan(Component).ExhaustFanID := ExhaustFanID;
                        Zone.AddSpaceConditioning(Component);
                        Zone.ExhaustFanComponent := Component;
                        T_EP_ExhaustFan(Component).MakeupTransferZoneList := TStringList.create;
                        for m := 0 to   GreatGrandChildNode.NodeCount -1 do
                        begin
                          Great2GrandChildNode := GreatGrandChildNode.Nodes[m];
                          if Great2GrandChildNode.Name = 'ExhaustFlowPerArea' then begin
                             T_EP_ExhaustFan(Component).ExhaustFlowPerArea := FloatValueFromPath( GreatGrandChildNode,  'ExhaustFlowPerArea',-999.0);
                          end;
                          Great2GrandChildNode := GreatGrandChildNode.Nodes[m];
                          if Great2GrandChildNode.Name = 'ExhaustFlow' then begin
                             T_EP_ExhaustFan(Component).ExhaustFlowRate := FloatValueFromPath( GreatGrandChildNode,  'ExhaustFlow',-999.0);
                          end;
                          Great2GrandChildNode := GreatGrandChildNode.Nodes[m];
                          if Great2GrandChildNode.Name = 'ExhaustFlowACH' then begin
                             T_EP_ExhaustFan(Component).ExhaustFlowACH := FloatValueFromPath( GreatGrandChildNode,  'ExhaustFlowACH',-999.0);
                          end;
                          if Great2GrandChildNode.Name = 'ExhaustFanEfficiency' then begin
                             T_EP_ExhaustFan(Component).FanEfficiency := FloatValueFromPath( GreatGrandChildNode,  'ExhaustFanEfficiency');
                          end;
                          if Great2GrandChildNode.Name = 'ExhaustFanPressureDrop' then begin
                             T_EP_ExhaustFan(Component).FanPressureDrop := FloatValueFromPath( GreatGrandChildNode,  'ExhaustFanPressureDrop');
                          end;
                          if Great2GrandChildNode.Name = 'MakeupInfiltrationFraction' then begin
                             T_EP_ExhaustFan(Component).DrawFromInfiltrationFraction := FloatValueFromPath( GreatGrandChildNode,  'MakeupInfiltrationFraction');
                          end;
                          if Great2GrandChildNode.Name = 'MakeupTransferAir' then begin
                             T_EP_ExhaustFan(Component).MakeupTransferZoneList.Add(StringValueFromPath( Great2GrandChildNode, 'ZoneFrom' ));
                             setlength(T_EP_ExhaustFan(Component).MakeupTransferZoneFractions, T_EP_ExhaustFan(Component).MakeupTransferZoneList.count);
                             setlength(T_EP_ExhaustFan(Component).MakeupTransferFlowRates, T_EP_ExhaustFan(Component).MakeupTransferZoneList.count);
                             T_EP_ExhaustFan(Component).MakeupTransferZoneFractions[ T_EP_ExhaustFan(Component).MakeupTransferZoneList.count -1] :=
                               FloatValueFromPath( Great2GrandChildNode, 'FlowFraction',-999);
                             T_EP_ExhaustFan(Component).MakeupTransferFlowRates[ T_EP_ExhaustFan(Component).MakeupTransferZoneList.count -1] :=
                               FloatValueFromPath( Great2GrandChildNode, 'FlowRate',-999);
                          end;
//                          if Great2GrandChildNode.Name = 'ZoneMakeupFromName' then begin
//                              T_EP_ExhaustFan(Component).MakeupZoneList.add(StringValueFromPath( GreatGrandChildNode,  'ZoneMakeupFromName'));
//                          end;
                          if Great2GrandChildNode.Name = 'Schedule' then
                          begin
                             if StringValueFromPath(GreatGrandChildNode, 'Schedule', false) = '' then
                                T_EP_ExhaustFan(Component).ScheduleName := 'Hours_of_operation'
                             else
                                T_EP_ExhaustFan(Component).ScheduleName := StringValueFromPath(GreatGrandChildNode, 'Schedule', false);
                          end;
                          if Great2GrandChildNode.Name = 'OverrideOA' then
                          begin
                             T_EP_ExhaustFan(Component).OverrideOA := BooleanValueFromPath( GreatGrandChildNode,  'OverrideOA', true);
                          end;
                        end;
                        inc(ExhaustFanID);
                      end
                      else if GreatGrandChildNode.Name = 'DirectAir' then
                      begin
                        Component := T_EP_DirectAir.Create;
                        Component.ZoneServedName := Zone.Name;
                        Component.AirSystemName := HVACAirSystemName(RootNode, GreatGrandChildNode);
                        Node := RootNode.FindNode('/HPBParametization/HVACSystem/DetailedHVAC');
                        Component.DetailedReporting := BooleanValueFromPath(Node, 'DetailedReporting', False);
                        T_EP_DirectAir(Component).airFlowRate := StringValueFromPath(GreatGrandChildNode, 'AirFlowRate', true, 'AUTOSIZE');
                        T_EP_DirectAir(Component).MinSupplyAirTemp := FloatValueFromPath(GreatGrandChildNode, 'MinSupplyAirTemp', -9999.0);
                        T_EP_DirectAir(Component).MaxSupplyAirTemp := FloatValueFromPath(GreatGrandChildNode, 'MaxSupplyAirTemp', -9999.0);
                        Zone.AddSpaceConditioning(Component);
                        AirEndUses.Add(Component);
                      end
                      else if GreatGrandChildNode.Name = 'DualDuctOutdoorAir' then
                      begin
                        Component := T_EP_DualDuctOutdoorAir.Create;
                        Component.ZoneServedName := Zone.Name;
                        Component.AirSystemName := HVACAirSystemName(RootNode, GreatGrandChildNode);
                        Zone.AddSpaceConditioning(Component); // sets zone
                        AirEndUses.Add(Component);
                        for m := 0 to GreatGrandChildNode.NodeCount - 1 do
                        begin
                          T_EP_DualDuctOutdoorAir(Component).RecircBranch := BooleanValueFromPath(GreatGrandChildNode, 'RecircBranch', true);
                        end;
                      end
                      else if GreatGrandChildNode.Name = 'SingleDuctVariableFlow' then
                      begin
                        Component := T_EP_SingleDuctVariableFlow.Create;
                        Component.ZoneServedName := Zone.Name;
                        Component.AirSystemName := HVACAirSystemName(RootNode, GreatGrandChildNode);
                        Zone.AddSpaceConditioning(Component);  // sets zone
                        AirEndUses.Add(Component);
                        // get type of reheat coil
                        // HPBParametization/HVACSystem/DetailedHVAC/Zone/SpaceConditioning/Equipment/SingleDuctVariableFlow'
                        for m := 0 to GreatGrandChildNode.NodeCount - 1 do
                        begin
                          ChildNode2 := GreatGrandChildNode.Nodes[m];
                          if SameText(ChildNode2.Name, 'ReheatCoilType') then
                          begin
                            T_EP_SingleDuctVariableFlow(Component).ReheatCoilType := StringValueFromPath(GreatGrandChildNode, 'ReheatCoilType');
                            if SameText(T_EP_SingleDuctVariableFlow(Component).ReheatCoilType, 'HOT WATER') then
                            begin
                              ChildComponent := T_EP_Coil.Create;
                              ChildComponent.Name := Component.Name + ' Reheat Coil';
                              T_EP_Coil(ChildComponent).Typ := 'HEATING';
                              T_EP_Coil(ChildComponent).Fuel := 'WATER';
                              //AirEndUses.Add(Component);
                              LiquidHeatingDemandComponents.Add(ChildComponent);
                              T_EP_SingleDuctVariableFlow(Component).HotWaterReheatCoilObject := T_EP_Coil(ChildComponent);
                            end;
                          end
                          else if SameText(ChildNode2.Name, 'ReheatCoilEfficiency') then
                          begin
                            T_EP_SingleDuctVariableFlow(Component).ReheatCoilEfficiency := FloatValueFromPath(GreatGrandChildNode, 'ReheatCoilEfficiency');
                          end
                          else if SameText(ChildNode2.Name, 'MinFlowFraction') then
                          begin
                            T_EP_SingleDuctVariableFlow(Component).MinFlowFraction := FloatValueFromPath(GreatGrandChildNode, 'MinFlowFraction', 0.3);
                          end
                          else if SameText(ChildNode2.Name, 'MinFlowFractionSchedule') then
                          begin
                            T_EP_SingleDuctVariableFlow(Component).MinFlowFractionSchedule := StringValueFromPath(GreatGrandChildNode, 'MinFlowFractionSchedule');
                          end
                          else if SameText(ChildNode2.Name, 'MinAirFlowRate') then
                          begin
                            T_EP_SingleDuctVariableFlow(Component).MinAirFlowRate := FloatValueFromPath(GreatGrandChildNode, 'MinAirFlowRate', -9999.0);
                          end
                          else if SameText(ChildNode2.Name, 'MaxAirFlow') then
                          begin
                            T_EP_SingleDuctVariableFlow(Component).SetMaxAirFlowComponents(ChildNode2);
                          end
                          else if SameText(ChildNode2.Name, 'AvailabilitySchedule') then
                          begin
                            T_EP_SingleDuctVariableFlow(Component).AvailSchedule := StringValueFromPath(GreatGrandChildNode, 'AvailabilitySchedule');
                          end
                          else if SameText(ChildNode2.Name, 'CoilAvailabilitySchedule') then
                          begin
                            T_EP_SingleDuctVariableFlow(Component).CoilAvailSch := StringValueFromPath(GreatGrandChildNode, 'CoilAvailabilitySchedule', False, '');
                          end
                          else if SameText(ChildNode2.Name, 'LeakageFraction') then
                          begin
                            T_EP_SingleDuctVariableFlow(Component).LeakageFraction := FloatValueFromPath(GreatGrandChildNode, 'LeakageFraction', 0.0);
                          end
                          else if SameText(ChildNode2.Name, 'DamperHeatingAction') then
                          begin
                            T_EP_SingleDuctVariableFlow(Component).DamperHeatingAction := StringValueFromPath(GreatGrandChildNode, 'DamperHeatingAction', False, 'Reverse');
                          end
                          else if SameText(ChildNode2.Name, 'SuppressOA') then
                          begin
                            T_EP_SingleDuctVariableFlow(Component).SuppressOA := BooleanValueFromPath(GreatGrandChildNode, 'SuppressOA', false);
                          end
                          else if SameText(ChildNode2.Name, 'SuppressDesignSpecOA') then
                          begin
                            T_EP_SingleDuctVariableFlow(Component).SuppressDesignSpecOA := BooleanValueFromPath(GreatGrandChildNode, 'SuppressDesignSpecOA', false);
                          end;
                        end; // for
                      end
                      else if GreatGrandChildNode.Name = 'FanPoweredTerminal' then
                      begin
                        Component := T_EP_FanPoweredTerminal.Create;
                        Component.ZoneServedName := Zone.Name;
                        Component.AirSystemName := HVACAirSystemName(RootNode, GreatGrandChildNode);
                        Zone.AddSpaceConditioning(Component);
                        AirEndUses.Add(Component);
                        for m := 0 to GreatGrandChildNode.NodeCount - 1 do
                        begin
                          ChildNode2 := GreatGrandChildNode.Nodes[m];
                          if ChildNode2.Name = 'ReheatCoilType' then
                          begin
                            T_EP_FanPoweredTerminal(Component).ReheatCoilType := StringValueFromPath(GreatGrandChildNode, 'ReheatCoilType');
                            if SameText(T_EP_FanPoweredTerminal(Component).ReheatCoilType, 'HOT WATER') then
                            begin
                              ChildComponent := T_EP_Coil.Create;
                              ChildComponent.Name := Component.Name + ' reheat coil';
                              T_EP_Coil(ChildComponent).Typ := 'HEATING';
                              T_EP_Coil(ChildComponent).Fuel := 'WATER';
                              //AirEndUses.Add(Component);
                              LiquidHeatingDemandComponents.Add(ChildComponent);
                              T_EP_FanPoweredTerminal(Component).HotWaterReheatCoilObject := T_EP_Coil(ChildComponent);
                            end;
                          end;
                          if ChildNode2.Name = 'ReheatCoilEfficiency' then
                          begin
                            T_EP_FanPoweredTerminal(Component).ReheatCoilEfficiency
                              := FloatValueFromPath(GreatGrandChildNode, 'ReheatCoilEfficiency');
                          end;
                          if ChildNode2.Name = 'FanEfficiency' then
                          begin
                            T_EP_FanPoweredTerminal(Component).FanEfficiency
                              := FloatValueFromPath(GreatGrandChildNode, 'FanEfficiency');
                          end;
                          if childNode2.Name = 'FanPressureDrop' then
                          begin
                            T_EP_FanPoweredTerminal(Component).FanPressureDrop
                              := FloatValueFromPath(GreatGrandChildNode, 'FanPressureDrop');
                          end;
                          if childNode2.Name = 'FanOperationSchedule' then
                          begin
                            T_EP_FanPoweredTerminal(Component).FanOperationSchedule
                              := StringValueFromPath(GreatGrandChildNode, 'FanOperationSchedule');
                          end;
                        end; // for
                      end
                      else if GreatGrandChildNode.Name = 'BaseboardHeaterWater' then
                      begin
                        Component := T_EP_BaseboardHeaterConvectiveWater.Create;
                        Zone.AddSpaceConditioning(Component);
                        LiquidHeatingDemandComponents.Add(Component);
                      end
                      else if GreatGrandChildNode.Name = 'BaseboardHeaterElectric' then
                      begin
                        Component := T_EP_BaseboardHeaterConvectiveElectric.Create;
                        Zone.AddSpaceConditioning(Component);
                      end
                      else if GreatGrandChildNode.Name = 'LowTempRadiantVariableFlow' then
                      begin
                        Component := T_EP_LowTempRadiantVariableFlow.Create;
                        T_EP_LowTempRadiantVariableFlow(Component).UserProvidedName := StringValueFromPath(GreatGrandChildNode, 'Name', true, '');
                        T_EP_LowTempRadiantVariableFlow(Component).coldWaterComponent.LiquidSystemName := StringValueFromPath(GreatGrandChildNode, 'LiquidSystemCoolingName', true, '');
                        T_EP_LowTempRadiantVariableFlow(Component).hotWaterComponent.LiquidSystemName := StringValueFromPath(GreatGrandChildNode, 'LiquidSystemHeatingName', true, '');
                        for m := 0 to GreatGrandChildNode.NodeCount - 1 do
                        begin
                          childNode2 := GreatGrandChildNode.Nodes[m];
                          if childNode2.Name = 'Surfaces' then
                          begin
                            radiantSurfaceGroup := T_EP_LowTempRadiantSurfaceGroup.Create;
                            for n := 0 to childNode2.NodeCount -1 do
                            begin
                              if childNode2.Nodes[n].Name = 'Surface' then
                              begin
                                aSurface := T_EP_Surface.Create;
                                aSurface.Name := childNode2.Nodes[n].ValueAsString;
                                radiantSurfaceGroup.AddSurface(aSurface);
                              end;
                            end;
                            T_EP_LowTempRadiantVariableFlow(Component).LowTempRadiantSurfaceGroup := radiantSurfaceGroup;
                          end
                          else if childNode2.Name = 'AvailabilitySchedule' then
                          begin
                            T_EP_LowTempRadiantVariableFlow(Component).AvailabilitySchedule := StringValueFromPath(GreatGrandChildNode,'AvailabilitySchedule');
                          end
                          else if childNode2.Name = 'TubingInsideDiameter' then
                          begin
                            T_EP_LowTempRadiantVariableFlow(Component).TubingInsideDiameter := FloatValueFromPath(GreatGrandChildNode,'TubingInsideDiameter');
                          end
                          else if childNode2.Name = 'TubingLength' then
                          begin
                            T_EP_LowTempRadiantVariableFlow(Component).TubingLength := FloatValueFromPath(GreatGrandChildNode,'TubingLength');
                          end
                          else if childNode2.Name = 'TempControlType' then
                          begin
                            T_EP_LowTempRadiantVariableFlow(Component).TempControlType := StringValueFromPath(GreatGrandChildNode,'TempControlType');
                          end
                          else if childNode2.Name = 'MaxHotWaterFlow' then
                          begin
                            T_EP_LowTempRadiantVariableFlow(Component).MaxHotWaterFlow := FloatValueFromPath(GreatGrandChildNode,'MaxHotWaterFlow');
                          end
                          else if childNode2.Name = 'HeatingThrottlingRange' then
                          begin
                            T_EP_LowTempRadiantVariableFlow(Component).HeatingThrottlingRange := FloatValueFromPath(GreatGrandChildNode,'HeatingThrottlingRange');
                          end
                          else if childNode2.Name = 'HeatingTempSchedule' then
                          begin
                            T_EP_LowTempRadiantVariableFlow(Component).HeatingTempSchedule := StringValueFromPath(GreatGrandChildNode,'HeatingTempSchedule');
                          end
                          else if childNode2.Name = 'MaxChilledWaterFlow' then
                          begin
                            T_EP_LowTempRadiantVariableFlow(Component).MaxChilledWaterFlow := FloatValueFromPath(GreatGrandChildNode,'MaxChilledWaterFlow');
                          end
                          else if childNode2.Name = 'CoolingThrottlingRange' then
                          begin
                            T_EP_LowTempRadiantVariableFlow(Component).CoolingThrottlingRange := FloatValueFromPath(GreatGrandChildNOde, 'CoolingThrottlingRange');
                          end
                          else if childNode2.Name = 'CoolingTempSchedule' then
                          begin
                            T_EP_LowTempRadiantVariableFlow(Component).CoolingTempSchedule := StringValueFromPath(GreatGrandChildNode,'CoolingTempSchedule');
                          end
                          else if childNode2.Name = 'CondensationControlType' then
                          begin
                            T_EP_LowTempRadiantVariableFlow(Component).CondensationControlType := StringValueFromPath(GreatGrandChildNode,'CondensationControlType');
                          end
                          else if childNode2.Name = 'CondensationControlDewpointOffset' then
                          begin
                            T_EP_LowTempRadiantVariableFlow(Component).CondensationControlDewpointOffset := FloatValueFromPath(GreatGrandChildNode,'CondensationControlDewpointOffset');
                          end;
                        end;
                        Zone.AddSpaceConditioning(Component);
                        if not SameText(T_EP_LowTempRadiantVariableFlow(Component).coldWaterComponent.LiquidSystemName, 'NONE') then
                          LiquidCoolingDemandComponents.Add(T_EP_LowTempRadiantVariableFlow(Component).coldWaterComponent);
                        if not SameText(T_EP_LowTempRadiantVariableFlow(Component).hotWaterComponent.LiquidSystemName, 'NONE') then
                          LiquidHeatingDemandComponents.Add(T_EP_LowTempRadiantVariableFlow(Component).hotWaterComponent);
                      end
                      else if GreatGrandChildNode.Name = 'UnitHeater' then
                      begin
                        Component := T_EP_UnitHeater.Create;
                        Zone.AddSpaceConditioning(Component);
                        // get type of coil and fan
                        // HPBParametization/HVACSystem/DetailedHVAC/Zone/SpaceConditioning/Equipment/UnitHeater'
                        for m := 0 to GreatGrandChildNode.NodeCount - 1 do
                        begin
                          ChildNode2 := GreatGrandChildNode.Nodes[m];
                          if ChildNode2.Name = 'CoilType' then
                          begin
                            T_EP_UnitHeater(Component).CoilType := StringValueFromPath(GreatGrandChildNode, 'CoilType');
                            if SameText(T_EP_UnitHeater(Component).CoilType, 'Coil:Heating:Water') then
                            begin
                              ChildComponent := T_EP_Coil.Create;
                              ChildComponent.Name := Component.Name + ' Coil';
                              T_EP_Coil(ChildComponent).Typ := 'HEATING';
                              T_EP_Coil(ChildComponent).Fuel := 'WATER';
                              LiquidHeatingDemandComponents.Add(ChildComponent);
                              T_EP_UnitHeater(Component).HWcoil := T_EP_Coil(ChildComponent);
                            end;
                          end; // if
                          if ChildNode2.Name = 'CoilEfficiency' then
                          begin
                            T_EP_UnitHeater(Component).CoilEfficiency := FloatValueFromPath(GreatGrandChildNode, 'CoilEfficiency');
                          end;
                          if ChildNode2.Name = 'FanType' then
                          begin
                            T_EP_UnitHeater(Component).FanType := StringValueFromPath(GreatGrandChildNode, 'FanType');
                          end;
                          if ChildNode2.Name = 'FanEfficiency' then
                          begin
                            T_EP_UnitHeater(Component).FanEfficiency := FloatValueFromPath(GreatGrandChildNode, 'FanEfficiency');
                          end;
                          if ChildNode2.Name = 'FanPressureDrop' then
                          begin
                            T_EP_UnitHeater(Component).FanPressureDrop := FloatValueFromPath(GreatGrandChildNode, 'FanPressureDrop');
                          end;
                        end; // for
                      end
                      else if GreatGrandChildNode.Name = 'UnitVentilator' then
                      begin
                        Component := T_EP_UnitVentilator.Create;
                        Zone.AddSpaceConditioning(Component);
                        // get type of coil and fan
                        for m := 0 to GreatGrandChildNode.NodeCount - 1 do
                        begin
                          ChildNode2 := GreatGrandChildNode.Nodes[m];
                          if ChildNode2.Name = 'CoilOption' then
                          begin
                            T_EP_UnitVentilator(Component).CoilOption := StringValueFromPath(GreatGrandChildNode, 'CoilOption');
                            if  T_EP_UnitVentilator(Component).CoilOption = '' then
                              T_EP_UnitVentilator(Component).CoilOption := 'HEATING';
                          end; //if
                          if ChildNode2.Name = 'HeatCoilType' then
                          begin
                            T_EP_UnitVentilator(Component).HeatCoilType := StringValueFromPath(GreatGrandChildNode, 'HeatCoilType');
                            if SameText(T_EP_UnitVentilator(Component).HeatCoilType, 'Coil:Heating:Water') then
                            begin
                              ChildComponent := T_EP_Coil.Create;
                              ChildComponent.Name := Component.Name + 'Heat Coil';
                              T_EP_Coil(ChildComponent).Typ := 'HEATING';
                              T_EP_Coil(ChildComponent).Fuel := 'WATER';
                              LiquidHeatingDemandComponents.Add(ChildComponent);
                              T_EP_UnitVentilator(Component).HWcoil := T_EP_Coil(ChildComponent);
                              if ((T_EP_UnitVentilator(Component).CoilOption = 'None') or
                                  (T_EP_UnitVentilator(Component).CoilOption = 'COOLING')) then
                              begin
                                T_EP_Coil(ChildComponent).Disabled := true;
                              end;
                            end;
                          end; // if
                          if ChildNode2.Name = 'HeatCoilEfficiency' then
                          begin
                            T_EP_UnitVentilator(Component).HeatCoilEfficiency := FloatValueFromPath(GreatGrandChildNode, 'HeatCoilEfficiency');
                          end;
                          if ChildNode2.Name = 'FanType' then
                          begin
                            T_EP_UnitVentilator(Component).FanType := StringValueFromPath(GreatGrandChildNode, 'FanType');
                          end;
                          if ChildNode2.Name = 'FanEfficiency' then
                          begin
                            T_EP_UnitVentilator(Component).FanEfficiency := FloatValueFromPath(GreatGrandChildNode, 'FanEfficiency');
                          end;
                          if ChildNode2.Name = 'FanPressureDrop' then
                          begin
                            T_EP_UnitVentilator(Component).FanPressureDrop := FloatValueFromPath(GreatGrandChildNode, 'FanPressureDrop');
                          end;
                          if childNode2.Name = 'MotorizedDamper' then
                          begin
                            T_EP_UnitVentilator(Component).MotorizedDamper := BooleanValueFromPath(GreatGrandChildNode, 'MotorizedDamper');
                          end;
                          if ChildNode2.Name = 'AvailabilitySchedule' then
                          begin
                            T_EP_UnitVentilator(Component).AvailSch := StringValueFromPath(GreatGrandChildNode, 'AvailabilitySchedule', false, '');
                          end;
                          if ChildNode2.Name = 'OAControlType' then
                          begin
                            T_EP_UnitVentilator(Component).OaCtrlType := StringValueFromPath(GreatGrandChildNode, 'OAControlType', false, '');
                          end;
                        end; // for
                        if ((T_EP_UnitVentilator(Component).CoilOption = 'COOLING')
                          or (T_EP_UnitVentilator(Component).CoilOption = 'HeatingAndCooling')) then
                        begin
                          //set up coldwater coil
                          ChildComponent := T_EP_Coil.Create;
                          ChildComponent.Name := Component.Name + 'Cool Coil';
                          T_EP_Coil(ChildComponent).Typ := 'COOLING';
                          T_EP_Coil(ChildComponent).Fuel := 'WATER';
                          LiquidCoolingDemandComponents.Add(ChildComponent);
                          T_EP_UnitVentilator(Component).coolingCoil := T_EP_Coil(ChildComponent);
                          T_EP_UnitVentilator(Component).coolingAvail := true;
                        end;
                      end
                      else if GreatGrandChildNode.Name = 'WindowAirConditioner' then
                      begin
                        Component := T_EP_WindowAC.Create;
                        Zone.AddSpaceConditioning(Component);
                        // '/HPBParametization/HVACSystem/DetailedHVAC/Zone/SpaceConditioning/Equipment/WindowAirConditioner')
                        for m := 0 to GreatGrandChildNode.NodeCount - 1 do
                        begin
                          ChildNode2 := GreatGrandChildNode.Nodes[m];
                          if ChildNode2.Name = 'COP' then
                          begin
                            T_EP_WindowAC(Component).COP := FloatValueFromPath(GreatGrandChildNode, 'COP');
                          end;
                          if ChildNode2.Name = 'Mode' then
                          begin
                            T_EP_WindowAC(Component).ControlMode := StringValueFromPath(GreatGrandChildNode, 'Mode');
                          end;
                          if ChildNode2.Name = 'FanEfficiency' then
                          begin
                            T_EP_WindowAC(Component).FanEfficiency := FloatValueFromPath(GreatGrandChildNode, 'FanEfficiency');
                          end;
                          if ChildNode2.Name = 'FanPressureDrop' then
                          begin
                            T_EP_WindowAC(Component).FanPressureDrop := FloatValueFromPath(GreatGrandChildNode, 'FanPressureDrop');
                          end;
                          if ChildNode2.Name = 'DataSetKey' then
                          begin
                            T_EP_WindowAC(Component).DataSetKey := StringValueFromPath(GreatGrandChildNode, 'DataSetKey', False, 'DefaultWindowAC');
                          end;
                          if ChildNode2.Name = 'SuppressLatDeg' then
                          begin
                             T_EP_WindowAC(Component).SuppressLatDeg := BooleanValueFromPath(GreatGrandChildNode, 'SuppressLatDeg', False);
                          end;
                          if ChildNode2.Name = 'EvaporativeCondenserEffectiveness' then
                          begin
                            T_EP_WindowAC(Component).EvapCondEff := FloatValueFromPath(GreatGrandChildNode, 'EvaporativeCondenserEffectiveness', -9999.0);
                          end;
                        end;
                      end
                      else if GreatGrandChildNode.Name = 'FanCoil' then
                      begin
                        Component := T_EP_FanCoil.Create;
                        Zone.AddSpaceConditioning(Component);
                        T_EP_FanCoil(Component).FanEff := FloatValueFromPath(GreatGrandChildNode, 'FanEfficiency');
                        T_EP_FanCoil(Component).FanPresDrop := FloatValueFromPath(GreatGrandChildNode, 'FanPressureDrop');
                        T_EP_FanCoil(Component).Typ := StringValueFromPath(GreatGrandChildNode, 'Type', False, '');
                        T_EP_FanCoil(Component).Kind := StringValueFromPath(GreatGrandChildNode, 'Kind', False, '');
                        T_EP_FanCoil(Component).SuppressOA := BooleanValueFromPath(GreatGrandChildNode, 'SuppressOA', false);
                        //set up hotwater coil
                        ChildComponent := T_EP_Coil.Create;
                        ChildComponent.Name := Component.Name + ' Heat Coil';
                        T_EP_Coil(ChildComponent).Typ := 'HEATING';
                        T_EP_Coil(ChildComponent).Fuel := 'WATER';
                        LiquidHeatingDemandComponents.Add(ChildComponent);
                        T_EP_FanCoil(Component).HtgCoil := T_EP_Coil(ChildComponent);
                        //now if fan coil doesn't have heating, disable heating coil
                        if SameText(T_EP_FanCoil(Component).Kind, 'CoolOnly') then
                          T_EP_Coil(ChildComponent).Disabled := true;
                        T_EP_Coil(ChildComponent).SupplyInletNode := T_EP_FanCoil(Component).Name + ' Cool Coil Air Outlet Node';
                        T_EP_Coil(ChildComponent).SupplyOutletNode := T_EP_FanCoil(Component).DemandOutletNode;
                        //set up coldwater coil
                        ChildComponent := T_EP_Coil.Create;
                        ChildComponent.Name := Component.Name + ' Cool Coil';
                        T_EP_Coil(ChildComponent).Typ := 'COOLING';
                        T_EP_Coil(ChildComponent).Fuel := 'WATER';
                        LiquidCoolingDemandComponents.Add(ChildComponent);
                        T_EP_FanCoil(Component).ClgCoil := T_EP_Coil(ChildComponent);
                        //now if fan coil doesn't have cooling disable cooling coil
                        if SameText(T_EP_FanCoil(Component).Kind, 'HeatOnly') then
                          T_EP_Coil(ChildComponent).Disabled := true;
                        T_EP_Coil(ChildComponent).SupplyInletNode := T_EP_FanCoil(Component).Name + ' Fan Outlet Node';
                        T_EP_Coil(ChildComponent).SupplyOutletNode := T_EP_FanCoil(Component).Name + ' Cool Coil Air Outlet Node';
                      end
                      else if GreatGrandChildNode.Name = 'ZoneERV' then
                      begin
                        Component := T_EP_ZoneERV.Create;
                        T_EP_ZoneERV(Component).SupFanEfficiency := FloatValueFromPath(GreatGrandChildNode, 'SupplyFanEfficiency');
                        T_EP_ZoneERV(Component).SupFanPressureDrop := FloatValueFromPath(GreatGrandChildNode, 'SupplyFanPressureDrop');
                        T_EP_ZoneERV(Component).ExhFanEfficiency := FloatValueFromPath(GreatGrandChildNode, 'ExhaustFanEfficiency');
                        T_EP_ZoneERV(Component).ExhFanPressureDrop := FloatValueFromPath(GreatGrandChildNode, 'ExhaustFanPressureDrop');
                        T_EP_ZoneERV(Component).SensibleEffectiveness := FloatValueFromPath(GreatGrandChildNode, 'SensibleEffectiveness');
                        T_EP_ZoneERV(Component).LatentEffectiveness := FloatValueFromPath(GreatGrandChildNode, 'LatentEffectiveness');
                        T_EP_ZoneERV(Component).ParasiticPower := FloatValueFromPath(GreatGrandChildNode, 'ParasiticPower');
                        T_EP_ZoneERV(Component).UseEconomizer := BooleanValueFromPath(GreatGrandChildNode, 'UseEconomizer');
                        Zone.AddSpaceConditioning(Component);
                      end
                      else if GreatGrandChildNode.Name = 'PackagedTerminalAC' then
                      begin
                        Component := T_EP_PTAC.Create;
                        Zone.AddSpaceConditioning(Component);
                        T_EP_PTAC(Component).CoolCOP := FloatValueFromPath(GreatGrandChildNode, 'CoolingCOP');
                        T_EP_PTAC(Component).FanEfficiency := FloatValueFromPath(GreatGrandChildNode, 'FanEfficiency');
                        T_EP_PTAC(Component).FanPressureDrop := FloatValueFromPath(GreatGrandChildNode, 'FanPressureDrop');
                        T_EP_PTAC(Component).ControlMode := StringValueFromPath(GreatGrandChildNode, 'Mode');
                        T_EP_PTAC(Component).HeatCoilType := StringValueFromPath(GreatGrandChildNode, 'HeatCoilType');
                        T_EP_PTAC(Component).SuppressOA := BooleanValueFromPath(GreatGrandChildNode,  'SuppressOA', False );
                        if SameText(T_EP_PTAC(Component).HeatCoilType, 'Coil:Heating:Water') then
                        begin
                          ChildComponent := T_EP_Coil.Create;
                          ChildComponent.Name := Component.Name + ' heat coil';
                          T_EP_Coil(ChildComponent).Typ := 'HEATING';
                          T_EP_Coil(ChildComponent).Fuel := 'WATER';
                          LiquidHeatingDemandComponents.Add(ChildComponent);
                          T_EP_PTAC(Component).HWcoil := T_EP_Coil(ChildComponent);
                        end;
                        T_EP_PTAC(Component).HeatCoilEfficiency := FloatValueFromPath(GreatGrandChildNode, 'HeatCoilEfficiency');
                        T_EP_PTAC(Component).DataSetKey := StringValueFromPath(GreatGrandChildNode, 'DataSetKey', False, 'DefaultPTAC');
                        T_EP_PTAC(Component).SuppressLatDeg := BooleanValueFromPath(GreatGrandChildNode, 'SuppressLatDeg', False);
                        T_EP_PTAC(Component).EvapCondEff := FloatValueFromPath(GreatGrandChildNode, 'EvaporativeCondenserEffectiveness', -9999.0);
                        T_EP_PTAC(Component).AvailSch := StringValueFromPath(GreatGrandChildNode, 'AvailabilitySchedule', false, 'ALWAYS_ON');
                      end
                      else if GreatGrandChildNode.Name = 'HeatPumpAirToAir' then
                      begin
                        Component := T_EP_PTHP.Create;
                        Zone.AddSpaceConditioning(Component);
                        T_EP_PTHP(Component).Typ := StringValueFromPath(GreatGrandChildNode, 'Type');
                        T_EP_PTHP(Component).HeatCOP := FloatValueFromPath(GreatGrandChildNode, 'HeatingCOP');
                        T_EP_PTHP(Component).CoolCOP := FloatValueFromPath(GreatGrandChildNode, 'CoolingCOP');
                        T_EP_PTHP(Component).FanEfficiency := FloatValueFromPath(GreatGrandChildNode, 'FanEfficiency');
                        T_EP_PTHP(Component).FanPressureDrop := FloatValueFromPath(GreatGrandChildNode, 'FanPressureDrop');
                        T_EP_PTHP(Component).ControlMode := StringValueFromPath(GreatGrandChildNode, 'Mode');
                        T_EP_PTHP(Component).DataSetKey := StringValueFromPath(GreatGrandChildNode, 'DataSetKey', False, 'DefaultPTHP');
                        T_EP_PTHP(Component).SuppressLatDeg := BooleanValueFromPath(GreatGrandChildNode, 'SuppressLatDeg', False);
                        T_EP_PTHP(Component).EvapCondEff := FloatValueFromPath(GreatGrandChildNode, 'EvaporativeCondenserEffectiveness', -9999.0);
                      end
                      else if GreatGrandChildNode.Name = 'HeatPumpWaterToAir' then
                      begin
                        Component := T_EP_HeatPumpWaterToAir.Create;
                        Zone.AddSpaceConditioning(Component);
                        T_EP_HeatPumpWaterToAir(Component).CoolCOP := FloatValueFromPath(GreatGrandChildNode, 'CoolingCOP', 5.0);
                        T_EP_HeatPumpWaterToAir(Component).HeatCOP := FloatValueFromPath(GreatGrandChildNode, 'HeatingCOP', 4.5);
                        T_EP_HeatPumpWaterToAir(Component).FanEfficiency := FloatValueFromPath(GreatGrandChildNode, 'FanEfficiency', 0.4);
                        T_EP_HeatPumpWaterToAir(Component).FanPressureDrop := FloatValueFromPath(GreatGrandChildNode, 'FanPressureDrop', 250);
                        T_EP_HeatPumpWaterToAir(Component).FanMotorEfficiency := FloatValueFromPath(GreatGrandChildNode, 'FanMotorEfficiency', 0.9);
                        T_EP_HeatPumpWaterToAir(Component).FanPlacement := StringValueFromPath(GreatGrandChildNode, 'FanPlacement', False, 'BlowThrough');
                        T_EP_HeatPumpWaterToAir(Component).FanScheduleName := StringValueFromPath(GreatGrandChildNode, 'FanScheduleName', False, 'HVACOperationSchd');
                        T_EP_HeatPumpWaterToAir(Component).SupHeatCoilType := StringValueFromPath(GreatGrandChildNode, 'SupHeatCoilType', False, 'Gas');
                        T_EP_HeatPumpWaterToAir(Component).SupHeatCoilEfficiency := FloatValueFromPath(GreatGrandChildNode, 'SupHeatCoilEfficiency', 0.8);
                        T_EP_HeatPumpWaterToAir(Component).SuppressOA := BooleanValueFromPath(GreatGrandChildNode, 'SuppressOA', False);
                        T_EP_HeatPumpWaterToAir(Component).DataSetKey := StringValueFromPath(GreatGrandChildNode, 'DataSetKey', False, 'DefaultWaterToAirHeatPump');
                        T_EP_HeatPumpWaterToAir(Component).FanControl := StringValueFromPath(GreatGrandChildNode, 'FanControl', False, 'Cycle');
                        T_EP_HeatPumpWaterToAir(Component).LiqSysCondName := StringValueFromPath(GreatGrandChildNode, 'LiqSysCondName', False, '');
                      end
                      else if GreatGrandChildNode.Name = 'OutdoorAirUnit' then
                      begin
                        OaUnit := T_EP_OutdoorAirUnit.Create;
                        Zone.AddSpaceConditioning(OaUnit);
                        OaUnit.OaRate := FloatValueFromPath(GreatGrandChildNode, 'OutdoorAirFlowRate', -9999.0);
                        OaUnit.OaSch := StringValueFromPath(GreatGrandChildNode, 'OutdoorAirSchedule', False, '');
                        OaUnit.CtrlType := StringValueFromPath(GreatGrandChildNode, 'ControlType', False, '');
                        OaUnit.HighAirTempSch := StringValueFromPath(GreatGrandChildNode, 'HighAirTempSchedule', False, '');
                        OaUnit.LowAirTempSch := StringValueFromPath(GreatGrandChildNode, 'LowAirTempSchedule', False, '');
                        OaUnit.AvailSch := StringValueFromPath(GreatGrandChildNode, 'AvailabilitySchedule', False, 'ALWAYS_ON');
                        Great2GrandChildNode := GreatGrandChildNode.FindNode('Equipment');
                        if Assigned(Great2GrandChildNode) then
                        begin
                          if Great2GrandChildNode.NodeCount > 0 then
                          begin
                            for m := 0 to Great2GrandChildNode.NodeCount - 1 do
                            begin
                              Great3GrandChildNode := Great2GrandChildNode.Nodes[m];
                              if Great3GrandChildNode.Name = 'Fan' then
                              begin
                                ChildComponent := T_EP_Fan.Create;
                                T_EP_Fan(ChildComponent).Typ := StringValueFromPath(Great3GrandChildNode, 'Type', False, '');
                                T_EP_Fan(ChildComponent).Kind := StringValueFromPath(Great3GrandChildNode, 'Kind', False, '');
                                T_EP_Fan(ChildComponent).Efficiency := FloatValueFromPath(Great3GrandChildNode, 'Efficiency', -9999.0);
                                T_EP_Fan(ChildComponent).PressureDrop := FloatValueFromPath(Great3GrandChildNode, 'PressureDrop', -9999.0);
                                T_EP_Fan(ChildComponent).Schedule := StringValueFromPath(Great3GrandChildNode, 'Schedule', False, 'ALWAYS_ON');
                                if SameText(T_EP_Fan(ChildComponent).Kind, 'Supply') then
                                begin
                                  ChildComponent.Name := OaUnit.Name + ' Supply Fan';
                                  OaUnit.AddEquip(ChildComponent);
                                end
                                else if SameText(T_EP_Fan(ChildComponent).Kind, 'Exhaust') then
                                begin
                                  ChildComponent.Name := OaUnit.Name + ' Exhaust Fan';
                                  OaUnit.HasExhFan := true;
                                  OaUnit.ExhFan := T_EP_Fan(ChildComponent);
                                end
                              end
                              else if Great3GrandChildNode.Name = 'Coil' then
                              begin
                                ChildComponent := T_EP_Coil.Create;
                                T_EP_Coil(ChildComponent).Fuel := StringValueFromPath(Great3GrandChildNode, 'Fuel', False, '');
                                T_EP_Coil(ChildComponent).Typ := StringValueFromPath(Great3GrandChildNode, 'Type', False, '');
                                T_EP_Coil(ChildComponent).Efficiency := FloatValueFromPath(Great3GrandChildNode, 'Efficiency', -9999.0);
                                T_EP_Coil(ChildComponent).COP := FloatValueFromPath(Great3GrandChildNode, 'COP', -9999.0);
                                ChildComponent.Name := OaUnit.Name + ' ' + T_EP_Coil(ChildComponent).Typ + ' Coil';
                                if SameText(T_EP_Coil(ChildComponent).Fuel, 'Water') or SameText(T_EP_Coil(ChildComponent).Fuel, 'WaterDetailed') then
                                begin
                                  if SameText(T_EP_Coil(ChildComponent).Typ, 'Heating') then
                                    LiquidHeatingDemandComponents.Add(ChildComponent)
                                  else if SameText(T_EP_Coil(ChildComponent).Typ, 'Cooling') then
                                    LiquidCoolingDemandComponents.Add(ChildComponent);
                                end;
                                OaUnit.AddEquip(ChildComponent);
                              end
                              else if Great3GrandChildNode.Name = 'ERV' then
                              begin
                                ChildComponent := T_EP_HeatRecoveryAirToAir.Create;
                                T_EP_HeatRecoveryAirToAir(ChildComponent).Name := OaUnit.Name + ' ERV';
                                T_EP_HeatRecoveryAirToAir(ChildComponent).SensEff := FloatValueFromPath(Great3GrandChildNode, 'SensibleEffectiveness', -9999.0);
                                T_EP_HeatRecoveryAirToAir(ChildComponent).LatEff := FloatValueFromPath(Great3GrandChildNode, 'LatentEffectiveness', -9999.0);
                                T_EP_HeatRecoveryAirToAir(ChildComponent).HxType := StringValueFromPath(Great3GrandChildNode, 'HeatExchangerType', False, 'Plate');
                                T_EP_HeatRecoveryAirToAir(ChildComponent).FrostCtrlType := StringValueFromPath(Great3GrandChildNode, 'FrostControlType', False, 'None');
                                T_EP_HeatRecoveryAirToAir(ChildComponent).ThresholdTemp := FloatValueFromPath(Great3GrandChildNode, 'ThresholdTemp', 1.7);
                                T_EP_HeatRecoveryAirToAir(ChildComponent).InitialDefrostTime := FloatValueFromPath(Great3GrandChildNode, 'InitialDefrostTime', 0.083);
                                T_EP_HeatRecoveryAirToAir(ChildComponent).RateDefrostTimeIncrease := FloatValueFromPath(Great3GrandChildNode, 'RateDefrostTimeIncrease', 0.012);
                                OaUnit.ERV := T_EP_HeatRecoveryAirToAir(ChildComponent);
                                OaUnit.AddEquip(ChildComponent);
                              end
                            end;
                          end;
                        end;
                      end
                      else if GreatGrandChildNode.Name = 'PurchasedAir' then
                      begin
                        Component := T_EP_PurchasedAir.Create;
                        Zone.AddSpaceConditioning(Component);
                        T_EP_PurchasedAir(Component).OutdoorAir := BooleanValueFromPath(GreatGrandChildNode, 'OutdoorAir', True );
                      end
                      else
                        WriteLn('Error:  Unhandled Space Conditioning child element = ' + GreatGrandChildNode.Name);
                    end;
                  end
                  else
                  begin
                    // do nothing
                  end; // if .. else if block
                end; // for
              end; //if node count > 0
            end;
          end
          else
          begin
            // throw error
          end;
        end; // for over nodes
      end; // if node count > 0
      //zone process loads
      for iList := 0 to slZones.Count - 1 do   //zone objects in xml
      begin
        childNode := TXmlNode(slZones.Items[iList]);
        tempName := StringValuefromPath(ChildNode, 'ZoneName');
        if (SameText(Zone.Name, tempName)) or
           (tempName = 'ALL') or
           (tempName = 'ALL-OTHER') or
           ((tempName <> 'ALL') and (SameText(zoneScope, 'UNIFORM ZONES FROM CONFIGURATION')))  then
        begin
          if not Zone.ZoneProcessLoadInfoProcessed then
            ProcessZoneProcessLoadInfo(ChildNode, zone, HotWaterDemandComponents, RefrigCaseComponents, RefrigWalkinComponents);
        end;
      end; //if slZones
    end; // Determine zones
    // ksb: a test to see what AirEndUses we have
    writeLn('the AirEndUse system names are');
    writeLn('******************************');
    for k := 0 to AirEndUses.Count - 1 do
    begin
      writeLn(THVACComponent(AirEndUses[k]).AirSystemName + '     ' + THVACComponent(AirEndUses[k]).ZoneServedName);
    end;
    writeLn('******************************');
    // Create air systems
    if AirEndUses.Count > 0 then
    begin // ksb: AirEndUses greater than 0
      node := RootNode.FindNode('/HPBParametization/HVACSystem/DetailedHVAC/Systems/HVACSystems');
      for k := 0 to AirEndUses.Count - 1 do
      begin // ksb: loop through every AirEndUse
        for n := 0 to Node.NodeCount - 1 do
        begin // ksb: loop through every node in HVACSystems
          ChildNode := Node.Nodes[n];
          if ChildNode.Name = 'AirSystem' then
          begin // ksb: Node under HVACSystems is an air system
            if StringValueFromPath(ChildNode, 'Name') = THVACComponent(AirEndUses[k]).AirSystemName then
            begin // ksb: AirEndUse air system name matches an air system that is defined in xml
              // ejb: test for dual duct
              if SameText(StringValueFromPath(ChildNode, 'DistributionType'), 'DualDuct') then
              begin
                DualDuct := true;
                Goto MultiZone;
              end
              else
              begin
                DualDuct := false;
              end;
              // ksb: ***************** create new system if it does not exist ***********************
              // ksb: ***************** or assign AirSystem to the existing system referred to by the air end use ****************
              if StringValueFromPath(ChildNode, 'DistributionType') = 'SINGLEZONE' then
              begin // ksb: single zone system
                AirSystem := T_EP_AirSystem.Create;
                NewSystem := True;
                AirSystem.Name := StringValueFromPath(ChildNode, 'Name') + ':' + IntToStr(systems.Count);
                AirSystem.DistributionType := StringValueFromPath(ChildNode, 'DistributionType');
                AirSystem.OperationSchedule := StringValueFromPath(ChildNode, 'OperationSchedule', False, 'HVACOperationSchd');
                AirSystem.UseNightCycle := BooleanValueFromPath(ChildNode, 'UseNightCycle', False);
                NightCycleNode := ChildNode.FindNode('NightCycle');
                if Assigned(NightCycleNode) then
                begin
                  AirSystem.NightCycleAvailabiltySchedule := StringValueFromPath(NightCycleNode, 'AvailabilitySchedule', False, '');
                  AirSystem.NightCycleFanSchedule := StringValueFromPath(NightCycleNode, 'FanSchedule', False, '');
                  AirSystem.NightCycleControlType := StringValueFromPath(NightCycleNode, 'ControlType', False, '');
                  AirSystem.NightCycleThermostatTolerance := FloatValueFromPath(NightCycleNode, 'ThermostatTolerance', -9999.0);
                  AirSystem.NightCycleCyclingRunTime := FloatValueFromPath(NightCycleNode, 'CyclingRunTime', -9999.0);
                end;
                plenumNode := ChildNode.FindNode('ReturnPlenum');
                if Assigned(plenumNode) then
                begin
                  AirSystem.UseReturnPlenum := true;
                  AirSystem.ReturnPlenumZoneName := StringValueFromPath(plenumNode,'ZoneName');
                end;
                AirSystem.SATManagerType := StringValueFromPath(Node, 'SATManagerType', False, 'Scheduled');
                AirSystem.SATManagerScheduleName := StringValueFromPath(ChildNode, 'SATManagerScheduleName', False);
                AirSystem.DualDuctSatMgrSchName := StringValueFromPath(ChildNode, 'DualDuctSatMgrSchName', False, 'Seasonal-Reset-Supply-Air-Temp-Sch');
                OAResetNode := ChildNode.FindNode('SATManagerOAResetInputs');
                if Assigned(OAResetNode) then
                begin
                  AirSystem.SATSetpointAtOutdoorLowTemp := FloatValueFromPath(OAResetNode, 'SetpointAtOutdoorLowTemp');
                  AirSystem.SATOutdoorLowTemp := FloatValueFromPath(OAResetNode, 'OutdoorLowTemp');
                  AirSystem.SATSetpointAtOutdoorHighTemp := FloatValueFromPath(OAResetNode, 'SetpointAtOutdoorHighTemp');
                  AirSystem.SATOutdoorHighTemp := FloatValueFRomPath(OAResetNode, 'OutdoorHighTemp');
                end;
                szNode := ChildNode.FindNode('Sizing');
                if Assigned(szNode) then
                begin
                  AirSystem.MinSystemAirFlowRatio := FloatValueFromPath(szNode, 'MinSystemAirFlowRatio', -999.0);
                  tmpVal := FloatValueFromPath(szNode, 'CoolingSupplyAirTemperature');
                  if tmpVal <> 0.0 then
                    AirSystem.CoolingSATTemperature := tmpVal;
                  tmpVal := FloatValueFromPath(szNode, 'HeatingSupplyAirTemperature');
                  if tmpVal <> 0.0 then
                    AirSystem.HeatingSATTemperature := tmpVal;
                  AirSystem.SysSizingCoincidence := StringValueFromPath(szNode, 'Coincidence', false, 'NonCoincident');
                  AirSystem.SysSizingCooling100pcntOA := StringValueFromPath(szNode, 'Cooling100pcntOutdoorAir', false, 'No');
                  AirSystem.SysSizingHeating100pcntOA := StringValueFromPath(szNode, 'Heating100pcntOutdoorAir', false, 'No');
                  tmpVal := FloatValueFromPath(szNode, 'CoolingSupplyAirHumidityRatio');
                  if tmpVal <> 0.0 then
                    AirSystem.SysSizingCoolingSupAirHumidityRatio := tmpVal;
                  tmpVal := FloatValueFromPath(szNode, 'HeatingSupplyAirHumidityRatio');
                  if tmpVal <> 0.0 then
                    AirSystem.SysSizingHeatingSupAirHumidityRatio := tmpVal;
                  AirSystem.DesignSysAirFlowRate := StringValueFromPath(szNode, 'DesignAirFlowRate', true, 'AUTOSIZE');
                  AirSystem.TypeOfLoadToSizeOn := StringValueFromPath(szNode, 'TypeOfLoadToSizeOn', true, 'Sensible');
                  AirSystem.SysOaMethod := StringValueFromPath(szNode, 'OutdoorAirMethod', false, 'ZoneSum');
                  AirSystem.SuppressOA := BooleanValueFromPath(szNode, 'SuppressOA', false);
                end;
                AirSystem.EmsDataSetKey := StringValueFromPath(ChildNode, 'EmsDataSetKey', False, '');
                AirSystem.EMSTurnDownRatio := StringValueFromPath(ChildNode, 'EMSTurnDownRatio', False, '');
              end // ksb: end if single zone system
              else if SameText(StringValueFromPath(ChildNode, 'DistributionType'), 'MultiZone') then
              begin // ksb: multi zone system
                MultiZone: // ejb: label from dual duct check
                // ksb: check to see if the system already exists
                NewSystem := True;  // ksb: this will be set to false if we find the system already exists
                for m := 0 to Systems.Count - 1 do
                begin // ksb: loop through existing systems to see if AirEndUses[k] airsystem has already been created
                  if Systems[m].ClassNameIs('T_EP_AirSystem') then
                  begin // ksb: Systems[m] is a T_EP_AirSystem
                    if T_EP_AirSystem(Systems[m]).Name = THVACComponent(AirEndUses[k]).AirSystemName then
                    begin // ksb: Systems[m] name and the end use air system are a match
                      // ksb: air system already exists
                      AirSystem := T_EP_AirSystem(Systems[m]);
                      NewSystem := False;
                      Break;
                    end; // ksb: end Systems[m] name and end use air system are a match
                  end; // ksb: end Systems[m] is a T_EP_AirSystem
                end; // ksb: end loop through existing systems
                if NewSystem = True then
                begin
                  AirSystem := T_EP_AirSystem.Create;
                  // ejb: set dual duct
                  if DualDuct then
                    AirSystem.DualDuct := true
                  else
                    AirSystem.DualDuct := false;
                  AirSystem.Name := StringValueFromPath(ChildNode, 'Name');
                  AirSystem.DistributionType := StringValueFromPath(ChildNode, 'DistributionType');
                  AirSystem.OperationSchedule := StringValueFromPath(ChildNode, 'OperationSchedule', False, 'HVACOperationSchd');
                  AirSystem.UseNightCycle := BooleanValueFromPath(ChildNode, 'UseNightCycle', False);
                  NightCycleNode := ChildNode.FindNode('NightCycle');
                  if Assigned(NightCycleNode) then
                  begin
                    AirSystem.NightCycleAvailabiltySchedule := StringValueFromPath(NightCycleNode, 'AvailabilitySchedule', False, '');
                    AirSystem.NightCycleFanSchedule := StringValueFromPath(NightCycleNode, 'FanSchedule', False, '');
                    AirSystem.NightCycleControlType := StringValueFromPath(NightCycleNode, 'ControlType', False, '');
                    AirSystem.NightCycleThermostatTolerance := FloatValueFromPath(NightCycleNode, 'ThermostatTolerance', -9999.0);
                    AirSystem.NightCycleCyclingRunTime := FloatValueFromPath(NightCycleNode, 'CyclingRunTime', -9999.0);
                  end;
                  plenumNode := ChildNode.FindNode('ReturnPlenum');
                  if Assigned(plenumNode) then
                  begin
                    AirSystem.UseReturnPlenum := true;
                    AirSystem.ReturnPlenumZoneName := StringValueFromPath(plenumNode,'ZoneName');
                  end;
                  AirSystem.SATManagerType := StringValueFromPath(ChildNode, 'SATManagerType', False, 'Scheduled');
                  AirSystem.SATManagerScheduleName := StringValueFromPath(ChildNode, 'SATManagerScheduleName', False, '');
                  AirSystem.DualDuctSatMgrSchName := StringValueFromPath(ChildNode, 'DualDuctSatMgrSchName', False, 'Seasonal-Reset-Supply-Air-Temp-Sch');
                  OAResetNode := ChildNode.FindNode('SATManagerOAResetInputs');
                  if Assigned(OAResetNode) then
                  begin
                    AirSystem.SATSetpointAtOutdoorLowTemp := FloatValueFromPath(OAResetNode, 'SetpointAtOutdoorLowTemp');
                    AirSystem.SATOutdoorLowTemp := FloatValueFromPath(OAResetNode, 'OutdoorLowTemp');
                    AirSystem.SATSetpointAtOutdoorHighTemp := FloatValueFromPath(OAResetNode, 'SetpointAtOutdoorHighTemp');
                    AirSystem.SATOutdoorHighTemp := FloatValueFRomPath(OAResetNode, 'OutdoorHighTemp');
                  end;
                  szNode := ChildNode.FindNode('Sizing');
                  if Assigned(szNode) then
                  begin
                    AirSystem.MinSystemAirFlowRatio := FloatValueFromPath(szNode, 'MinSystemAirFlowRatio', -999.0);
                    tmpVal := FloatValueFromPath(szNode, 'CoolingSupplyAirTemperature');
                    if tmpVal <> 0.0 then
                      AirSystem.CoolingSATTemperature := tmpVal;
                    tmpVal := FloatValueFromPath(szNode, 'HeatingSupplyAirTemperature');
                    if tmpVal <> 0.0 then
                      AirSystem.HeatingSATTemperature := tmpVal;
                    AirSystem.SysSizingCoincidence := StringValueFromPath(szNode, 'Coincidence', false, 'NonCoincident');
                    AirSystem.SysSizingCooling100pcntOA := StringValueFromPath(szNode, 'Cooling100pcntOutdoorAir', false, 'No');
                    AirSystem.SysSizingHeating100pcntOA := StringValueFromPath(szNode, 'Heating100pcntOutdoorAir', false, 'No');
                    tmpVal := FloatValueFromPath(szNode, 'CoolingSupplyAirHumidityRatio');
                    if tmpVal <> 0.0 then
                      AirSystem.SysSizingCoolingSupAirHumidityRatio := tmpVal;
                    tmpVal := FloatValueFromPath(szNode, 'HeatingSupplyAirHumidityRatio');
                    if tmpVal <> 0.0 then
                      AirSystem.SysSizingHeatingSupAirHumidityRatio := tmpVal;
                    AirSystem.DesignSysAirFlowRate := StringValueFromPath(szNode, 'DesignAirFlowRate', true, 'AUTOSIZE');
                    AirSystem.TypeOfLoadToSizeOn := StringValueFromPath(szNode, 'TypeOfLoadToSizeOn', true, 'Sensible');
                    AirSystem.SysOaMethod := StringValueFromPath(szNode, 'OutdoorAirMethod', false, 'ZoneSum');
                    AirSystem.SuppressOA := BooleanValueFromPath(szNode, 'SuppressOA', false);
                  end;
                  AirSystem.HumidityMinControlZone := StringValueFromPath(ChildNode.FindNode('HumidityControl'), 'HumidityMinControlZone', True,'');
                  AirSystem.HumidityMaxControlZone := StringValueFromPath(ChildNode.FindNode('HumidityControl'), 'HumidityMaxControlZone', True,'');
                  AirSystem.EmsDataSetKey := StringValueFromPath(ChildNode, 'EmsDataSetKey', False, '');
                  AirSystem.EMSTurnDownRatio := StringValueFromPath(ChildNode, 'EMSTurnDownRatio', False, '');
                end;
              end // ksb: end multizone system
              else
              begin
                WriteLn('Error: Unhandled Distribution type');
                RunError;
              end;
              // ksb: ********** done creating new systems *************************************************
              // ksb: ********** if we have a new system, we need to populate the supply side **************
              if NewSystem then
              begin // ksb: populate supply side of NewSystem
                GrandChildNode := ChildNode.FindNode('Equipment');
                if Assigned(GrandChildNode) then // ksb: if assignmed equimpment to the air system
                begin
                  ClgCoilID := 1;
                  HtgCoilID := 1;
                  if GrandChildNode.NodeCount > 0 then
                  begin
                    for j := 0 to GrandChildNode.NodeCount - 1 do // ksb: for each of the nodes under equipment
                    begin
                      GreatGrandChildNode := GrandChildNode.Nodes[j]; // GreatGrandChildNodes are the nodes of equipment
                      if GreatGrandChildNode.Name = 'Fan' then  // ksb: if equipment is a fan
                      begin
                        Component := T_EP_Fan.Create;
                        // ejb: set branch name if dual duct
                        if AirSystem.DualDuct then
                          T_EP_Fan(Component).BranchName := '_OA'
                        else
                          T_EP_Fan(Component).BranchName := '';
                        AirSystem.AddSupplyComponent(Component);
                        T_EP_Fan(Component).Typ := StringValueFromPath(GreatGrandChildNode, 'Type');
                        T_EP_Fan(Component).Efficiency := FloatValueFromPath(GreatGrandChildNode, 'Efficiency');
                        T_EP_Fan(Component).MotorEfficiency := FloatValueFromPath(GreatGrandChildNode, 'MotorEfficiency');
                        T_EP_Fan(Component).MotorInAirstreamFraction := FloatValueFromPath(GreatGrandChildNode, 'MotorInAirstreamFraction', 1.0);
                        T_EP_Fan(Component).PressureDrop := FloatValueFromPath(GreatGrandChildNode, 'PressureDrop');
                        T_EP_Fan(Component).FanPwrMinFlowMethod := StringValueFromPath(GreatGrandChildNode, 'FanPwrMinFlowMethod', False, 'Fraction');
                        T_EP_Fan(Component).FanPwrMinFlowFrac := FloatValueFromPath(GreatGrandChildNode, 'FanPwrMinFlowFrac', 0.6);
                        T_EP_Fan(Component).FanPwrMinFlowRate := FloatValueFromPath(GreatGrandChildNode, 'FanPwrMinFlowRate', 0.0);
                        T_EP_Fan(Component).CurveCoeff1 := FloatValueFromPath(GreatGrandChildNode, 'CurveCoeff1', -9999.0);
                        T_EP_Fan(Component).CurveCoeff2 := FloatValueFromPath(GreatGrandChildNode, 'CurveCoeff2', -9999.0);
                        T_EP_Fan(Component).CurveCoeff3 := FloatValueFromPath(GreatGrandChildNode, 'CurveCoeff3', -9999.0);
                        T_EP_Fan(Component).CurveCoeff4 := FloatValueFromPath(GreatGrandChildNode, 'CurveCoeff4', -9999.0);
                        T_EP_Fan(Component).CurveCoeff5 := FloatValueFromPath(GreatGrandChildNode, 'CurveCoeff5', -9999.0);
                        T_EP_Fan(Component).Schedule := StringValueFromPath(GreatGrandChildNode, 'Schedule', False, '');
                        // ejb: if MinSystemAirFlowRatio is not specified in the XML, then set based on fan type
                        if AirSystem.MinSystemAirFlowRatio = -999.0 then
                        begin
                          // ejb: if fan is constant then set MinSystemAirFlowRatio to 1.0
                          if SameText(T_EP_Fan(Component).Typ, 'Constant') then
                            AirSystem.MinSystemAirFlowRatio := 1.0;
                          // ejb: if fan is variable then set MinSystemAirFlowRatio to 0.3
                          if SameText(T_EP_Fan(Component).Typ, 'Variable') then
                            AirSystem.MinSystemAirFlowRatio := 0.3;
                        end;
                      end
                      else if GreatGrandChildNode.Name = 'Coil' then // if equipment is a coil
                      begin
                        Component := T_EP_Coil.Create;
                        // ejb: set branch name if dual duct
                        if AirSystem.DualDuct then
                          T_EP_Coil(Component).BranchName := '_OA'
                        else
                          T_EP_Coil(Component).BranchName := '';
                        T_EP_Coil(Component).ClgCoilID := ClgCoilID;
                        T_EP_Coil(Component).HtgCoilID := HtgCoilID;
                        T_EP_Coil(Component).Fuel := StringValueFromPath(GreatGrandChildNode, 'Fuel');
                        T_EP_Coil(Component).Typ := StringValueFromPath(GreatGrandChildNode, 'Type');
                        //increment coil IDs
                        if SameText(T_EP_Coil(Component).Typ, 'Cooling') or
                          SameText(T_EP_Coil(Component).Typ, 'DXCoolingTwoStageWithHumidityControl') or
                          SameText(T_EP_Coil(Component).Typ, 'DXSingleSpeed') then inc(ClgCoilID);
                        if SameText(T_EP_Coil(Component).Typ, 'Heating') then inc(HtgCoilID);
                        //T_EP_Coil(Component).System := AirSystem;    // why commented out?
                        T_EP_Coil(Component).Efficiency := FloatValueFromPath(GreatGrandChildNode, 'Efficiency');
                        T_EP_Coil(Component).COP := FloatValueFromPath(GreatGrandChildNode, 'COP',3.0);
                        T_EP_Coil(Component).DataSetKey := StringValueFromPath(GreatGrandChildNode, 'DataSetKey', False, 'LennoxTGA120S2B');
                        AirSystem.AddSupplyComponent(Component); // kind of bug that this must be last
                        if (SameText(T_EP_Coil(Component).Fuel, 'Water')) or (SameText(T_EP_Coil(Component).Fuel, 'WaterDetailed')) then
                        begin
                          if SameText(T_EP_Coil(Component).Typ, 'Heating') then
                            LiquidHeatingDemandComponents.Add(Component)
                          else if SameText(T_EP_Coil(Component).Typ, 'Cooling') then
                            LiquidCoolingDemandComponents.Add(Component);
                        end;
                        T_EP_Coil(Component).Schedule := StringValueFromPath(GreatGrandChildNode, 'Schedule', False, '');
                        T_EP_Coil(Component).SetPtMgrName := StringValueFromPath(GreatGrandChildNode, 'SetPtMgrName', False, '');
                        T_EP_Coil(Component).SuppressLatDeg := BooleanValueFromPath(GreatGrandChildNode, 'SuppressLatDeg', False);
                        T_EP_Coil(Component).EvapCondEff := FloatValueFromPath(GreatGrandChildNode, 'EvaporativeCondenserEffectiveness', -9999.0);
                        T_EP_Coil(Component).EvapCondPumpPwr := FloatValueFromPath(GreatGrandChildNode, 'EvaporativeCondenserPumpPower', -9999.0);
                        T_EP_Coil(Component).BasinHeaterCap := FloatValueFromPath(GreatGrandChildNode, 'BasinHeaterCapacity', -9999.0);
                      end
                      else if GreatGrandChildNode.Name = 'EvaporativeCooler' then // ksb: if equipment is Evaporative Cooler
                      begin
                        Component := T_EP_EvaporativeCooler.Create;
                        T_EP_EvaporativeCooler(Component).Typ := StringValueFromPath(GreatGrandChildNode, 'Type');
                        if  (SameText(T_EP_EvaporativeCooler(Component).Typ , 'INDIRECT:RDDSPECIAL')) or
                            (SameText(T_EP_EvaporativeCooler(Component).Typ , 'INDIRECT:RESEARCHSPECIAL')) then
                        begin
                          T_EP_EvaporativeCooler(Component).WetBulbEffectiveness := FloatValueFromPath(GreatGrandChildNode, 'WetBulbEffectiveness');
                          T_EP_EvaporativeCooler(Component).SecondaryFanFlowRate := FloatValueFromPath(GreatGrandChildNode, 'SecondaryFanFlowRate', -99999.0 );
                          T_EP_EvaporativeCooler(Component).SecondaryFanEfficiency := FloatValueFromPath(GreatGrandChildNode, 'SecondaryFanEfficiency');
                          T_EP_EvaporativeCooler(Component).SecondaryFanPressure := FloatValueFromPath(GreatGrandChildNode, 'SecondaryFanPressureDrop');
                          T_EP_EvaporativeCooler(Component).DewpointEffectiveness := FloatValueFromPath(GreatGrandChildNode, 'DewpointEffectiveness');
                          T_EP_EvaporativeCooler(Component).SecondaryAirType := STringValueFromPath(GreatGrandChildNode, 'SecondaryAirType');
                          T_EP_EvaporativeCooler(Component).WaterRecircPumpPower := FloatValueFromPath(GreatGrandChildNode, 'WaterRecircPumpPower');
                          T_EP_EvaporativeCooler(Component).PressureDrop := FloatValueFromPath(GreatGrandChildNode, 'PressureDrop');
                          AirSystem.ComponentFanPressureDrop := AirSystem.ComponentFanPressureDrop + T_EP_EvaporativeCooler(Component).PressureDrop;
                          T_EP_EvaporativeCooler(Component).DriftFraction := FloatValueFromPath(GreatGrandChildNode, 'DriftFraction', 0.0);
                          T_EP_EvaporativeCooler(Component).BlowdownRatio := FloatValueFromPath(GreatGrandChildNode, 'BlowdownRatio', 3.0);
                          T_EP_EvaporativeCooler(Component).AvailabilitySchedule := StringValueFromPath(GreatGrandChildNode, 'AvailabilitySchedule', False, 'NotSet');
                        end;
                        if SameText(T_EP_EvaporativeCooler(Component).Typ , 'DIRECT:RESEARCHSPECIAL')  then
                        begin
                          T_EP_EvaporativeCooler(Component).WetBulbEffectiveness := FloatValueFromPath(GreatGrandChildNode, 'WetBulbEffectiveness');
                          T_EP_EvaporativeCooler(Component).WaterRecircPumpPower := FloatValueFromPath(GreatGrandChildNode, 'WaterRecircPumpPower');
                          T_EP_EvaporativeCooler(Component).DriftFraction := FloatValueFromPath(GreatGrandChildNode,  'DriftFraction', 0.0);
                          T_EP_EvaporativeCooler(Component).BlowdownRatio := FloatValueFromPath(GreatGrandChildNode,  'BlowdownRatio', 3.0);
                          T_EP_EvaporativeCooler(Component).AvailabilitySchedule := StringValueFromPath(GreatGrandChildNode, 'AvailabilitySchedule', False, 'NotSet');
                        end;
                        AirSystem.AddSupplyComponent(Component);
                      end
                      else if GreatGrandChildNode.Name = 'OutsideAirSystem' then // ksb: if equipment is Outside air system
                      begin
                        econRequested := BooleanValueFromPath(GreatGrandChildNode, 'UseEconomizer');
                        motorizedDamper := BooleanValueFromPath(GreatGrandChildNode, 'MotorizedDamper');
                        OAEquipNode := GreatGrandChildNode.FindNode('Equipment');
                        //is ERV requested
                        ERV := nil;
                        if Assigned(OAEquipNode) then
                        begin
                          ERVNode := GreatGrandChildNode.FindNode('HeatRecoveryAirToAir');
                          if Assigned(ERVNode) then
                          begin
                            if ERVNode.NodeCount > 0 then
                            begin
                              ERV := T_EP_HeatRecoveryAirToAir.Create;
                              T_EP_HeatRecoveryAirToAir(ERV).AirFlowRate := FloatValueFromPath(ERVNode, 'NominalSupplyAirFlowRate', -9999.0);
                              T_EP_HeatRecoveryAirToAir(ERV).SensEff := FloatValueFromPath(ERVNode, 'SensibleEffectiveness', -9999.0);
                              T_EP_HeatRecoveryAirToAir(ERV).LatEff := FloatValueFromPath(ERVNode, 'LatentEffectiveness', -9999.0);
                              T_EP_HeatRecoveryAirToAir(ERV).ParaPower := FloatValueFromPath(ERVNode, 'ParasiticPower', -9999.0);
                              T_EP_HeatRecoveryAirToAir(ERV).EconBypass := BooleanValueFromPath(ERVNode, 'EconomizerByPass', True);
                              T_EP_HeatRecoveryAirToAir(ERV).AvailSch := StringValueFromPath(ERVNode, 'AvailabilitySchedule', False, 'NotSet');
                              T_EP_HeatRecoveryAirToAir(ERV).SetPtMgrName := StringValueFromPath(ERVNode, 'SetPtMgrName', False, '');
                              T_EP_HeatRecoveryAirToAir(ERV).HxType := StringValueFromPath(ERVNode, 'HeatExchangerType', False, 'Plate');
                              T_EP_HeatRecoveryAirToAir(ERV).FrostCtrlType := StringValueFromPath(ERVNode, 'FrostControlType', False, 'None');
                              T_EP_HeatRecoveryAirToAir(ERV).ThresholdTemp := FloatValueFromPath(ERVNode, 'ThresholdTemp', 1.7);
                              T_EP_HeatRecoveryAirToAir(ERV).InitialDefrostTime := FloatValueFromPath(ERVNode, 'InitialDefrostTime', 0.083);
                              T_EP_HeatRecoveryAirToAir(ERV).RateDefrostTimeIncrease := FloatValueFromPath(ERVNode, 'RateDefrostTimeIncrease', 0.012);
                              //pressure drop
                              AirSystem.ComponentFanPressureDrop := AirSystem.ComponentFanPressureDrop + FloatValueFromPath(ERVNode,'PressureDrop');
                            end;
                          end;
                        end;
                        // ksb: create the oa system;
                        OASystem := T_EP_OutsideAirSystem.Create(AirSystem,econRequested,motorizedDamper,ERV);
                        OASystem.MinOAFraction := FloatValueFromPath(GreatGrandChildNode, 'MinOAFraction',  -999);
                        OASystem.DesignOAFraction := FloatValueFromPath(GreatGrandChildNode, 'DesignOAFraction',  -999);
                        OASystem.UseControllerMechVent := BooleanValueFromPath(GreatGrandChildNode, 'UseControllerMechVent', true);
                        OASystem.ZoneOutdoorAirMethod := StringValueFromPath(GreatGrandChildNode, 'ZoneOutdoorAirMethod' , false, 'Sum' );
                        OASystem.SystemOutdoorAirMethod := StringValueFromPath(GreatGrandChildNode,'SystemOutdoorAirMethod' ,false, 'VRP');
                        OASystem.SystemVentilationEffectiveness := FloatValueFromPath(GreatGrandChildNode, 'SystemVentilationEffectiveness', -999);
                        OASystem.SuppressOA := BooleanValueFromPath(GreatGrandChildNode, 'SuppressOA', false);
                        OASystem.SetPtMgrName := StringValueFromPath(GreatGrandChildNode, 'SetPtMgrName', False, '');
                        OASystem.MinOAMultiplierSchedule := StringValueFromPath(GreatGrandChildNode, 'MinOAMultiplierSchedule', false, '');
                        OASystem.MinOAFractionSchedule := StringValueFromPath(GreatGrandChildNode, 'MinOAFractionSchedule', false, '');
                        OASystem.MaxOAFractionSchedule := StringValueFromPath(GreatGrandChildNode, 'MaxOAFractionSchedule', false, '');
                        OASystem.EconomizerControlSchedule := StringValueFromPath(GreatGrandChildNode, 'EconomizerControlSchedule', false, '');
                        OASystem.EconomizerControlType := StringValueFromPath(GreatGrandChildNode, 'EconomizerControlType', false, '');
                        OASystem.EconomizerMaxLimitDBT := FloatValueFromPath(GreatGrandChildNode, 'EconomizerMaxLimitDBT', -999.0);
                        OASystem.EconomizerMaxLimitEnthalpy := FloatValueFromPath(GreatGrandChildNode, 'EconomizerMaxLimitEnthalpy', -999.0);
                        // how many ancillary peices of OA equipment are there?
                        OAEquipNode := GreatGrandChildNode.FindNode('Equipment');
                        if Assigned(OAEquipNode) then
                        begin
                          OaClgCoilID := 1;
                          OaHtgCoilID := 1;
                          if OAEquipNode.NodeCount > 0 then
                          begin
                            for m := 0 to OAEquipNode.NodeCount - 1 do
                            begin
                              aOAEquipNode := OAEquipNode.Nodes[m];
                              if SameText(aOAEquipNode.Name, 'EvaporativeCooler') then
                              begin
                                EvaporativeCooler := T_EP_EvaporativeCooler.Create;
                                aString := StringValueFromPath(aOAEquipNode,'Type', True, 'IndirectRDDSpecial');
                                EvaporativeCooler.Typ := aString;
                                aFloat := FloatValueFromPath(aOAEquipNode, 'WetBulbEffectiveness', 0.75);
                                EvaporativeCooler.WetBulbEffectiveness := aFloat;
                                aFloat := FloatValueFromPath(aOAEquipNode, 'DewpointEffectiveness', 0.90);
                                EvaporativeCooler.DewpointEffectiveness := aFloat;
                                aFloat := FloatValueFromPath(aOAEquipNode, 'SecondaryFanFlowRate', -99999.0); //default to E+'s autosize number
                                EvaporativeCooler.SecondaryFanFlowRate := aFloat;
                                aFloat := FloatValueFromPath(aOAEquipNode, 'SecondaryFanEfficiency', 0.6);
                                EvaporativeCooler.SecondaryFanEfficiency := aFloat;
                                aFloat := FloatValueFromPath(aOAEquipNode, 'SecondaryFanPressureDrop', 124.6);
                                EvaporativeCooler.SecondaryFanPressure := aFloat;
                                aString := StringValueFromPath(aOAEquipNode,'SecondaryAirType', True, 'OUTSIDE');
                                EvaporativeCooler.SecondaryAirType := aString;
                                aFloat := FloatValueFromPath(aOAEquipNode, 'WaterRecircPumpPower', 0.0);
                                EvaporativeCooler.WaterRecircPumpPower := aFloat;
                                aFloat := FloatValueFromPath(aOAEquipNode, 'DriftFraction', 0.0);
                                EvaporativeCooler.DriftFraction := aFloat;
                                aFloat := FloatValueFromPath(aOAEquipNode, 'BlowdownRatio', 3.0);
                                EvaporativeCooler.BlowdownRatio := aFloat;
                                aString := StringValueFromPath(aOAEquipNode, 'AvailabilitySchedule', False, 'NotSet');
                                EvaporativeCooler.AvailabilitySchedule := aString;
                                aString := StringValueFromPath(aOAEquipNode, 'SetPtMgrName', False, '');
                                EvaporativeCooler.SetPtMgrName := aString;
                                UseEvapCoolerEmsCode := BooleanValueFromPath(aOAEquipNode, 'UseEmsCode', True);
                                OASystem.AddSupplyComponent(EvaporativeCooler);
                              end
                              else if SameText(aOAEquipNode.Name, 'TranspiredSolarCollector') then
                              begin
                                Component := T_EP_TranspiredSolarCollector.Create;
                                with T_EP_TranspiredSolarCollector(Component) do
                                begin
                                  FreeHtgSetptSch := StringValueFromPath(aOAEquipNode, 'FreeHtgSetptSch', False, '');
                                  PerforationDiameter := FloatValueFromPath(aOAEquipNode, 'PerforationDiameter', 0.0016);
                                  PerforationDistance := FloatValueFromPath(aOAEquipNode, 'PerforationDistance', 0.01689);
                                  CollectorEmissivity := FloatValueFromPath(aOAEquipNode, 'CollectorEmissivity', 0.9);
                                  CollectorAbsorbtivity := FloatValueFromPath(aOAEquipNode, 'CollectorAbsorbtivity', 0.9);
                                  GapThickness := FloatValueFromPath(aOAEquipNode, 'GapThickness', 0.1);
                                  HoleLayoutPattern := StringValueFromPath(aOAEquipNode, 'HoleLayoutPattern', False, 'Triangle');
                                  EffectivenessCorrelation := StringValueFromPath(aOAEquipNode, 'EffectivenessCorrelation', False, 'Kutscher1994');
                                  ActualToProjectedAreaRatio := FloatValueFromPath(aOAEquipNode, 'ActualToProjectedAreaRatio', 1.165);
                                  CollectorRoughness := StringValueFromPath(aOAEquipNode, 'CollectorRoughness', False, 'MediumRough');
                                  CollectorThickness := FloatValueFromPath(aOAEquipNode, 'CollectorThickness', 0.001);
                                  WindEffectiveness := FloatValueFromPath(aOAEquipNode, 'WindEffectiveness', 0.25);
                                  DischargeCoefficient := FloatValueFromPath(aOAEquipNode, 'DischargeCoefficient', 0.5);
                                end;
                                OASystem.AddSupplyComponent(Component);
                              end
                              else if SameText(aOAEquipNode.Name, 'Coil') then
                              begin
                                Component := T_EP_Coil.Create;
                                T_EP_Coil(Component).BranchName := '';
                                T_EP_Coil(Component).ClgCoilID := OaClgCoilID;
                                T_EP_Coil(Component).HtgCoilID := OaHtgCoilID;
                                T_EP_Coil(Component).Fuel := StringValueFromPath(aOAEquipNode, 'Fuel');
                                T_EP_Coil(Component).Typ := StringValueFromPath(aOAEquipNode, 'Type');
                                if SameText(T_EP_Coil(Component).Typ, 'Cooling') or
                                  SameText(T_EP_Coil(Component).Typ, 'DXCoolingTwoStageWithHumidityControl') or
                                  SameText(T_EP_Coil(Component).Typ, 'DXSingleSpeed') then inc(OaClgCoilID);
                                if SameText(T_EP_Coil(Component).Typ, 'Heating') then inc(OaHtgCoilID);
                                T_EP_Coil(Component).Efficiency := FloatValueFromPath(aOAEquipNode, 'Efficiency');
                                T_EP_Coil(Component).COP := FloatValueFromPath(aOAEquipNode, 'COP',3.0);
                                OASystem.AddSupplyComponent(Component);
                                if (SameText(T_EP_Coil(Component).Fuel, 'Water')) or (SameText(T_EP_Coil(Component).Fuel, 'WaterDetailed')) then
                                begin
                                  if SameText(T_EP_Coil(Component).Typ, 'Heating') then
                                    LiquidHeatingDemandComponents.Add(Component)
                                  else if SameText(T_EP_Coil(Component).Typ, 'Cooling') then
                                    LiquidCoolingDemandComponents.Add(Component);
                                end;
                                T_EP_Coil(Component).Schedule := StringValueFromPath(aOAEquipNode, 'Schedule', False, '');
                                T_EP_Coil(Component).SetPtMgrName := StringValueFromPath(aOAEquipNode, 'SetPtMgrName', False, '');
                              end;
                            end;
                          end;
                        end;
                      end
                      else if GreatGrandChildNode.Name = 'UnitaryPackage' then // ksb: if equipment is a unitary package
                      begin
                        Component := T_EP_UnitaryPackage.Create;
                        T_EP_UnitaryPackage(Component).Typ := StringValueFromPath(GreatGrandChildNode, 'Type');
                        if SameText(T_EP_UnitaryPackage(Component).Typ,'WATERTOAIRHEATPUMP') then
                          T_EP_UnitaryPackage(Component).LiquidSystemCondenserName := StringValueFromPath(GreatGrandChildNode, 'LiquidSystemCondenserName');
                        T_EP_UnitaryPackage(Component).CoolCOP := FloatValueFromPath(GreatGrandChildNode, 'CoolingCOP');
                        if Assigned(GreatGrandChildNode.FindNode('HeatingCOP')) then
                          T_EP_UnitaryPackage(Component).HeatCOP := FloatValueFromPath(GreatGrandChildNode, 'HeatingCOP')
                        else if Assigned(GreatGrandChildNode.FindNode('HeatingEfficiency')) then
                          T_EP_UnitaryPackage(Component).HeatEff := FloatValueFromPath(GreatGrandChildNode, 'HeatingEfficiency');
                        if Assigned(GreatGrandChildNode.FindNode('FanOperation')) then
                          T_EP_UnitaryPackage(Component).FanOperation := StringValueFromPath(GreatGrandChildNode, 'FanOperation', True, 'ContinuousFan');
                        if Assigned(GreatGrandChildNode.FindNode('DataSetKey')) then
                          T_EP_UnitaryPackage(Component).DataSetKey := StringValueFromPath(GreatGrandChildNode, 'DataSetKey', True, 'DefaultUnitaryPackage');
                        if Assigned(GreatGrandChildNode.FindNode('DXCoilType')) then
                          T_EP_UnitaryPackage(Component).DXCoilType := StringValueFromPath(GreatGrandChildNode, 'DXCoilType', True, 'DX');
                        if Assigned(GreatGrandChildNode.FindNode('HeatingCoilType')) then
                          T_EP_UnitaryPackage(Component).HtgCoilType := StringValueFromPath(GreatGrandChildNode, 'HeatingCoilType', false, 'NaturalGas');
                        if Assigned(GreatGrandChildNode.FindNode('ReheatCoilType')) then
                          T_EP_UnitaryPackage(Component).ReheatCoilType := StringValueFromPath(GreatGrandChildNode, 'ReheatCoilType',true,'gas');
                        if Assigned(GreatGrandChildNode.FindNode('SuppressLatDeg')) then
                          T_EP_UnitaryPackage(Component).SuppressLatDeg := BooleanValueFromPath(GreatGrandChildNode, 'SuppressLatDeg', False);
                        if Assigned(GreatGrandChildNode.FindNode('EvaporativeCondenserEffectiveness')) then
                          T_EP_UnitaryPackage(Component).EvapCondEff := FloatValueFromPath(GreatGrandChildNode, 'EvaporativeCondenserEffectiveness', -9999.0);
                        if Assigned(GreatGrandChildNode.FindNode('EvaporativeCondenserPumpPower')) then
                          T_EP_UnitaryPackage(Component).EvapCondPumpPwr := FloatValueFromPath(GreatGrandChildNode, 'EvaporativeCondenserPumpPower', -9999.0);
                        if Assigned(GreatGrandChildNode.FindNode('BasinHeaterCapacity')) then
                          T_EP_UnitaryPackage(Component).BasinHeaterCap := FloatValueFromPath(GreatGrandChildNode, 'BasinHeaterCapacity', -9999.0);
                        T_EP_UnitaryPackage(Component).System := AirSystem;
                        AirSystem.AddSupplyComponent(Component);
                        for m := 0 to GreatGrandChildNode.NodeCount - 1 do
                        begin
                          Great2GrandChildNode := GreatGrandChildNode.Nodes[m];
                          if Great2GrandChildNode.Name = 'Fan' then
                          begin
                            T_EP_UnitaryPackage(Component).FanType := StringValueFromPath(Great2GrandChildNode, 'Type');
                            T_EP_UnitaryPackage(Component).FanEfficiency := FloatValueFromPath(Great2GrandChildNode, 'Efficiency');
                            T_EP_UnitaryPackage(Component).FanPressureDrop := FloatValueFromPath(Great2GrandChildNode, 'PressureDrop');
                          end;
                        end;
                        T_EP_DirectAir(AirEndUses[k]).unitary_control := true;
                      end // unitary package
                      else if GreatGrandChildNode.Name = 'Humidifier' then
                      begin
                        Component := T_EP_Humidifier.Create;
                        T_EP_Humidifier(Component).HumidifierType := StringValueFromPath(GreatGrandChildNode, 'Type');
                        T_EP_Humidifier(Component).RatedCapacity := FloatValueFromPath(GreatGrandChildNode,'RatedCapacity');
                        T_EP_Humidifier(Component).RatedPower := FloatValueFromPath(GreatGrandChildNode,'RatedPower');
                        T_EP_Humidifier(Component).RatedFanPower := FloatValueFromPath(GreatGrandChildNode,'RatedFanPower');
                        T_EP_Humidifier(Component).StandbyPower := FloatValueFromPath(GreatGrandChildNode,'StandbyPower');
                        T_EP_Humidifier(Component).WaterStorageTankName := StringValueFromPath(GreatGrandChildNode,'WaterStorageTankName',false,'');
                        AirSystem.AddSupplyComponent(Component);
                      end
                      else if GreatGrandChildNode.Name = 'DesiccantSystem' then
                      begin
                        Component := T_EP_DesiccantSystem.Create;
                        AirSystem.AddSupplyComponent(T_EP_DesiccantSystem(Component).dxCoil);
                        AirSystem.AddSupplyComponent(Component);
                      end
                      else
                      begin
                        WriteLn('Error:  Unhandled Air Equipment child element = ' + GreatGrandChildNode.Name);
                      end;
                    end; // ksb: end for each of the nodes under equipment
                  end; // ksb: end if there are nodes under equipment
                end; // ksb: end if there is equipment
                GrandChildNode := ChildNode.FindNode('DualDuctEquip');
                if Assigned(GrandChildNode) then
                begin
                  RcClgCoilID := 1;
                  RcHtgCoilID := 1;
                  if GrandChildNode.NodeCount > 0 then
                  begin
                    for j := 0 to GrandChildNode.NodeCount - 1 do
                    begin
                      GreatGrandChildNode := GrandChildNode.Nodes[j];
                      if GreatGrandChildNode.Name = 'Fan' then
                      begin
                        Component := T_EP_Fan.Create;
                        // ejb: set branch name if dual duct
                        if AirSystem.DualDuct then
                          T_EP_Fan(Component).BranchName := '_RC'
                        else
                          T_EP_Fan(Component).BranchName := '';
                        AirSystem.AddRecircSupplyComponent(Component);
                        T_EP_Fan(Component).Typ := StringValueFromPath(GreatGrandChildNode, 'Type');
                        T_EP_Fan(Component).Efficiency := FloatValueFromPath(GreatGrandChildNode, 'Efficiency');
                        T_EP_Fan(Component).MotorEfficiency := FloatValueFromPath(GreatGrandChildNode, 'MotorEfficiency');
                        T_EP_Fan(Component).PressureDrop := FloatValueFromPath(GreatGrandChildNode, 'PressureDrop');
                        T_EP_Fan(Component).FanPwrMinFlowMethod := StringValueFromPath(GreatGrandChildNode, 'FanPwrMinFlowMethod', False, 'Fraction');
                        T_EP_Fan(Component).FanPwrMinFlowFrac := FloatValueFromPath(GreatGrandChildNode, 'FanPwrMinFlowFrac', 0.6);
                        T_EP_Fan(Component).FanPwrMinFlowRate := FloatValueFromPath(GreatGrandChildNode, 'FanPwrMinFlowRate', 0.0);
                        T_EP_Fan(Component).Schedule := StringValueFromPath(GreatGrandChildNode, 'Schedule', False, '');
                      end
                      else if GreatGrandChildNode.Name = 'Coil' then
                      begin
                        Component := T_EP_Coil.Create;
                        // ejb: set branch name if dual duct
                        if AirSystem.DualDuct then
                          T_EP_Coil(Component).BranchName := '_RC'
                        else
                          T_EP_Coil(Component).BranchName := '';
                        T_EP_Coil(Component).ClgCoilID := RcClgCoilID;
                        T_EP_Coil(Component).HtgCoilID := RcHtgCoilID;
                        T_EP_Coil(Component).Fuel := StringValueFromPath(GreatGrandChildNode, 'Fuel');
                        T_EP_Coil(Component).Typ := StringValueFromPath(GreatGrandChildNode, 'Type');
                        //increment coil IDs
                        if SameText(T_EP_Coil(Component).Typ, 'Cooling') or
                          SameText(T_EP_Coil(Component).Typ, 'DXCoolingTwoStageWithHumidityControl') or
                          SameText(T_EP_Coil(Component).Typ, 'DXSingleSpeed') then inc(RcClgCoilID);
                        if SameText(T_EP_Coil(Component).Typ, 'Heating') then inc(RcHtgCoilID);
                        T_EP_Coil(Component).Efficiency := FloatValueFromPath(GreatGrandChildNode, 'Efficiency');
                        T_EP_Coil(Component).COP := FloatValueFromPath(GreatGrandChildNode, 'COP', 3.0);
                        T_EP_Coil(Component).DataSetKey := StringValueFromPath(GreatGrandChildNode, 'DataSetKey', False, 'LennoxTGA120S2B');
                        AirSystem.AddRecircSupplyComponent(Component);
                        if (SameText(T_EP_Coil(Component).Fuel, 'Water')) or (SameText(T_EP_Coil(Component).Fuel, 'WaterDetailed')) then
                        begin
                          if SameText(T_EP_Coil(Component).Typ, 'Heating') then
                            LiquidHeatingDemandComponents.Add(Component)
                          else if SameText(T_EP_Coil(Component).Typ, 'Cooling') then
                            LiquidCoolingDemandComponents.Add(Component);
                        end;
                        T_EP_Coil(Component).Schedule := StringValueFromPath(GreatGrandChildNode, 'Schedule', False, '');
                        T_EP_Coil(Component).SetPtMgrName := StringValueFromPath(GreatGrandChildNode, 'SetPtMgrName', False, '');
                        T_EP_Coil(Component).SuppressLatDeg := BooleanValueFromPath(GreatGrandChildNode, 'SuppressLatDeg', False);
                        T_EP_Coil(Component).EvapCondEff := FloatValueFromPath(GreatGrandChildNode, 'EvaporativeCondenserEffectiveness', -9999.0);
                        T_EP_Coil(Component).EvapCondPumpPwr := FloatValueFromPath(GreatGrandChildNode, 'EvaporativeCondenserPumpPower', -9999.0);
                        T_EP_Coil(Component).BasinHeaterCap := FloatValueFromPath(GreatGrandChildNode, 'BasinHeaterCapacity', -9999.0);
                      end
                      else
                      begin
                        WriteLn('Error: Unhandled Air Equipment Child Element = ' + GreatGrandChildNode.Name);
                      end;
                    end;
                  end;
                end;
              end; // ksb: end populate supply side of new system
              // ksb: ********** end of populate the supply side ***************
              // ksb: ********** populate the demand side **********************
              AirSystem.AddDemandComponent(THVACComponent(AirEndUses[k]));
              // ksb: ********** end poupluate the demand side *****************
              // ksb: ******* set the zone AirSystem name to E+ name of the system serving the zone ***********
              // ksb: note that for singleZone sytems this is based on the xml name but with the zone name appended
              for iZone := 0 to Zones.Count -1 do
              begin // ksb: zone iteration
                zone := T_EP_Zone(Zones[iZone]);
                if zone.Name = THVACComponent(AirEndUses[k]).ZoneServedName then
                begin
                  zone.AirSystemName := AirSystem.Name;
                end;
              end; // ksb: end zone iteration
            end; // ksb: end AirEndUse air system name matches an air system that is defined in xml
          end; // ksb: end Node under HVACSystems is an air system
        end; // ksb: end loop through every node in HVACSystems
      end; // ksb: end loop through every AirEndUse
    end; // ksb: end AirEndUses greater than 0
    // ksb: ****************** syncronize zone and air systems *****************
    // ksb: first finalize the Air Systems so that outletNode is available
    if Systems.Count > 0 then
    begin
      for k := 0 to Systems.Count - 1 do
      begin
        if Systems[k].ClassNameIs('T_EP_AirSystem') then
          begin
            T_EP_AirSystem(Systems[k]).Finalize;
        end;
      end;
      // ksb: now do the matching
      for k := 0 to Zones.Count -1 do
      begin
       if T_EP_Zone(Zones[k]).OccupiedConditioned then
        begin
          zone := T_EP_Zone(Zones[k]);
          for n := 0 to Systems.Count - 1 do
          begin
            if Systems[n].ClassNameIs('T_EP_AirSystem') then
            begin
              if zone.AirSystemName = T_EP_AirSystem(Systems[n]).Name then
              begin
                zone.AirSysSupplySideOutletNode := T_EP_AirSystem(Systems[n]).OutletNode;
                T_EP_AirSystem(Systems[n]).AddZoneServed(zone);
              end;
            end;
          end;
        end;
      end;
    end;
    // ksb: hot water systems
    // bg:  if no SWH but heat recovery with tanks being used for heating, then still want HotWaterSystem
    // so first test for existance of systems.
    Node := RootNode.FindNode('/HPBParametization/HVACSystem/DetailedHVAC/Systems/HVACSystems/LiquidSystemHeating');
    if not Assigned(Node) then
    begin
      //create hot water system if there are any LiquidHeatingDemandComponents
      HeatingDemandServedByHotWater :=  true;
    end;
    //if HotWaterDemandComponents.Count > 0 then
    //begin
    if ((HotWaterDemandComponents.Count > 0 )
      or ((LiquidHeatingDemandComponents.Count > 0 )
      and (HeatingDemandServedByHotWater) )) then
    begin
      HotWaterSystem := T_EP_LiquidSystem.Create;
      HotWaterSystem.Name := 'SWHSys1'; // Service Hot water Plant loop
      HotWaterSystem.SystemType := cSystemTypeHotWater;
      HotWaterSystem.SetPointSchedule := 'SWHSys1-Loop-Temp-Schedule';
      // Populate demand side
      for i := 0 to HotWaterDemandComponents.Count - 1 do
      begin
        Component := THVACComponent(HotWaterDemandComponents[i]);
        HotWaterSystem.AddDemandComponent(Component);
      end;
      // get loop temp setpoint
      Node := RootNode.FindNode('/HPBParametization/HVACSystem/DetailedHVAC/Systems/HVACSystems/LiquidSystemHotWater');
      if Assigned(Node) then
      begin
        T_EP_LiquidSystem(HotWaterSystem).LoopTempSetpoint := FloatValueFromPath(Node, 'SWHTargetTemp', 54.0);
      end; //if
      // Populate supply side
      Node := RootNode.FindNode('/HPBParametization/HVACSystem/DetailedHVAC/Systems/HVACSystems/LiquidSystemHotWater/Equipment');
      if Assigned(Node) then
      begin
        if Node.NodeCount > 0 then
        begin
		      for j := 0 to Node.NodeCount - 1 do
          begin
            ChildNode := Node.Nodes[j];
            if ChildNode.Name = 'Pump' then
            begin
              Component := T_EP_Pump.Create;
              HotWaterSystem.AddSupplyComponent(Component);
              T_EP_Pump(Component).Typ := StringValueFromPath(ChildNode, 'Type');
              T_EP_Pump(Component).RatedFlowRate := FloatValueFromPath(ChildNode, 'FlowRate', -9999.0);
              T_EP_Pump(Component).PressureDrop := FloatValueFromPath(ChildNode, 'Head', 179352);
              T_EP_Pump(Component).RatedPower := FloatValueFromPath(ChildNode, 'Power', -9999.0);
              T_EP_Pump(Component).Efficiency := FloatValueFromPath(ChildNode, 'Efficiency');
              T_EP_Pump(Component).CurveCoeff1 := FloatValueFromPath(ChildNode, 'CurveCoeff1', -9999.0);
              T_EP_Pump(Component).CurveCoeff2 := FloatValueFromPath(ChildNode, 'CurveCoeff2', -9999.0);
              T_EP_Pump(Component).CurveCoeff3 := FloatValueFromPath(ChildNode, 'CurveCoeff3', -9999.0);
              T_EP_Pump(Component).CurveCoeff4 := FloatValueFromPath(ChildNode, 'CurveCoeff4', -9999.0);
              T_EP_Pump(Component).PumpControlType := StringValueFromPath(ChildNode, 'ControlType', False, '');
            end
            else if ChildNode.Name = 'Boiler' then
            begin
              Component := T_EP_Boiler.Create;
              HotWaterSystem.AddSupplyComponent(Component);
              T_EP_Boiler(Component).ComponentType := 'Boiler:' + StringValueFromPath(ChildNode, 'Type', False, 'HotWater');
              T_EP_Boiler(Component).Efficiency := FloatValueFromPath(ChildNode, 'Efficiency');
              T_EP_Boiler(Component).Fuel := StringValueFromPath(ChildNode, 'Fuel');
            end
            else if ChildNode.Name = 'WaterHeater' then
            begin
              Component := T_EP_WaterHeater.Create;
              HotWaterSystem.AddSupplyComponent(Component);
              T_EP_WaterHeater(Component).Typ := StringValueFromPath(ChildNode, 'Type');
              T_EP_WaterHeater(Component).Fuel := StringValueFromPath(ChildNode, 'Fuel');
              T_EP_WaterHeater(Component).Efficiency := FloatValueFromPath(ChildNode, 'Efficiency', 0.8);
              T_EP_WaterHeater(Component).Volume := FloatValueFromPath(ChildNode, 'Volume', 3);
              T_EP_WaterHeater(Component).Capacity := FloatValueFromPath(ChildNode, 'Capacity');
              T_EP_WaterHeater(Component).TankUValue := FloatValueFromPath(ChildNode, 'EffectiveUValue', 0.846 );
              T_EP_WaterHeater(Component).HeightAspectRatio := FloatValueFromPath(ChildNode, 'HeightAspectRatio', 2.0);
              T_EP_WaterHeater(Component).NumNodes := IntegerValueFromPath(ChildNode, 'NumberNodes', 8);
              T_EP_WaterHeater(Component).HPWHZone := StringValueFromPath(ChildNode, 'HPWHZone', False, '');
              T_EP_WaterHeater(Component).COP := FloatValueFromPath(ChildNode, 'COP', 2.8);
              T_EP_WaterHeater(Component).System := HotWaterSystem;
              if T_EP_WaterHeater(Component).Typ = 'Indirect' then
              begin
                LiquidHeatingDemandComponents.Add(Component);
                // store object reference for later connecting to LiquicHeatingSystme.
                IndirectWaterHeaterObj := T_EP_WaterHeater(Component);
              end;
              if T_EP_WaterHeater(Component).Typ = 'HEATRECOVERYELECTRICFOLLOW' then
              begin
                HeatRecoveryRecipientComponents.Add(Component);
                // store object reference for later connecting to HeatRecoverySystem.
                HeatRecoveryWaterHeaterObj := T_EP_WaterHeater(Component);
                T_EP_WaterHeater(HeatRecoveryWaterHeaterObj).SetUseSideSupplySystem(HotWaterSystem);
                T_EP_WaterHeater(HeatRecoveryWaterHeaterObj).UseSideOnSupply := true;
              end;
              if T_EP_WaterHeater(Component).Typ = 'HEATRECOVERYELECTRICFOLLOWSTRATIFIED' then
              begin
                HeatRecoveryRecipientComponents.Add(Component);
                // store object reference for later connecting to HeatRecoverySystem.
                HeatRecoveryWaterHeaterObj := T_EP_WaterHeater(Component);
                T_EP_WaterHeater(HeatRecoveryWaterHeaterObj).SetUseSideSupplySystem(HotWaterSystem);
                T_EP_WaterHeater(HeatRecoveryWaterHeaterObj).UseSideOnSupply := true;
                T_EP_WaterHeater(HeatRecoveryWaterHeaterObj).ComponentType := 'WaterHeater:Stratified';
              end;
              if T_EP_WaterHeater(Component).Typ = 'HEATRECOVERYTHERMALFOLLOW' then
              begin
                HeatRecoveryRecipientComponents.Add(Component);
                // store object reference for later connecting to HeatRecoverySystem.
                HeatRecoveryWaterHeaterObj := T_EP_WaterHeater(Component);
                T_EP_WaterHeater(HeatRecoveryWaterHeaterObj).SetUseSideSupplySystem(HotWaterSystem);
                T_EP_WaterHeater(HeatRecoveryWaterHeaterObj).UseSideOnSupply := true;
                //IndirectWaterHeaterObj := T_EP_WaterHeater(Component);
              end;
              if T_EP_WaterHeater(Component).Typ = 'HEATRECOVERYTHERMALFOLLOWSTRATIFIED' then
              begin
                HeatRecoveryRecipientComponents.Add(Component);
                // store object reference for later connecting to HeatRecoverySystem.
                HeatRecoveryWaterHeaterObj := T_EP_WaterHeater(Component);
                T_EP_WaterHeater(HeatRecoveryWaterHeaterObj).SetUseSideSupplySystem(HotWaterSystem);
                T_EP_WaterHeater(HeatRecoveryWaterHeaterObj).UseSideOnSupply := true;
                T_EP_WaterHeater(HeatRecoveryWaterHeaterObj).ComponentType := 'WaterHeater:Stratified';
              end;
              if T_EP_WaterHeater(Component).Typ = 'HEAT PUMP' then
              begin
                HasHeatPumpHotWaterHeater := true;
              end;
            end  // water heater
            else if ChildNode.Name = 'HeatPumpWaterToWater' then
            begin
              Component := T_EP_HeatPumpWaterToWater.Create;
              HotWaterSystem.AddSupplyComponent(Component);
              T_EP_HeatPumpWaterToWater(Component).Typ := 'HEATING';
              GroundHXSystem := T_EP_LiquidSystem.Create;
              GroundHXSystem.Name := 'Ground Source HX System'; // can expand name
              GroundHXSystem.SystemType := cSystemTypeCoolHeat;
              GroundHXSystem.SetPointSchedule := 'Seasonal-Reset-Supply-Air-Temp-Sch'; // this is not right
              GroundHXSystem.AddDemandComponent(Component);
              GroundHXSystem.AddSupplyComponent(T_EP_Pump.Create);
              GroundHXSystem.AddSupplyComponent(T_EP_GroundSourceHeatExchanger.Create);
            end
            else if ChildNode.Name = 'ThermalStorageHotWater' then
            begin
              // Component := T_EP_HeatPumpWaterToWater.Create;
              HotWaterSystem.AddSupplyComponent(Component);
              // T_EP_HeatPumpWaterToWater(Component).Typ := 'HEATING';
            end
            else if ChildNode.Name = 'PurchasedHotWater' then
            begin
              Component := T_EP_PurchHotWater.Create;
              HotWaterSystem.AddSupplyComponent(Component);
            end
            else
              WriteLn('Error:  Unhandled Liquid Hot Water Equipment child element = ' + ChildNode.Name);
          end;
        end;
      end;
    end;
    if ((LiquidHeatingDemandComponents.Count > 0) and (HeatRecoveryRecipientComponents.Count = 0)) then
    begin
      // ksb: loop through HVACSystems and find LiquidSystemHeating
      Node := RootNode.FindNode('/HPBParametization/HVACSystem/DetailedHVAC/Systems/HVACSystems');
      if Assigned(Node) then
      begin
        for i := 0 to Node.NodeCount - 1 do
        begin
          ChildNode := Node.Nodes[i];
          if SameText(ChildNode.Name,'LiquidSystemHeating') then
          begin
            LiquidHeatingSystem := T_EP_LiquidSystem.Create;
            if Assigned(ChildNode.FindNode('Name')) then
              LiquidHeatingSystem.Name := StringValueFromPath(ChildNode,'Name')
            else // ksb: assign the default name.  There can only be one unnamed liquid system heating
              LiquidHeatingSystem.Name := 'HeatSys1'; // Central Heating Plant
              LiquidHeatingSystem.SystemType := cSystemTypeHeat;
              LiquidHeatingSystem.SetPointSchedule := 'HW-Loop-Temp-Schedule';
            // Populate demand side
            for j := 0 to LiquidHeatingDemandComponents.Count - 1 do
            begin
              Component := THVACComponent(LiquidHeatingDemandComponents[j]);
              // ksb: check to see if the component is on this system
              // ksb: if the system has the default name and the component is
              // ksb: unamed, consider that a match
              if SameText(Component.LiquidSystemName,LiquidHeatingSystem.Name) then
                LiquidHeatingSystem.AddDemandComponent(Component)
              else if ((SameText(Component.LiquidSystemName,''))
                and (SameText(LiquidHeatingSystem.Name,'HeatSys1'))) then
                  LiquidHeatingSystem.AddDemandComponent(Component);
            end;
            if Assigned(ChildNode.NodeByName('SetpointManagerType')) then
              LiquidHeatingSystem.HHWSetpointManagerType := StringValueFromPath(ChildNode, 'SetpointManagerType', False, '');
            // ejb: get HHW loop OA reset custom inputs
            if Assigned(ChildNode.NodeByName('SetpointManagerOAResetInputs')) then
            begin
              GrandChildNode := ChildNode.NodeByName('SetpointManagerOAResetInputs');
              LiquidHeatingSystem.HHWSetpointAtOutdoorLowTemp := FloatValueFromPath(GrandChildNode, 'SetpointAtOutdoorLowTemp');
              LiquidHeatingSystem.HHWOutdoorLowTemp := FloatValueFromPath(GrandChildNode, 'OutdoorLowTemp');
              LiquidHeatingSystem.HHWSetpointAtOutdoorHighTemp := FloatValueFromPath(GrandChildNode, 'SetpointAtOutdoorHighTemp');
              LiquidHeatingSystem.HHWOutdoorHighTemp := FloatValueFromPath(GrandChildNode, 'OutdoorHighTemp');
            end;
            // ejb: get HHW loop sizing information
            if Assigned(ChildNode.NodeByName('Sizing')) then
            begin
              GrandChildNode := ChildNode.NodeByName('Sizing');
              T_EP_System(LiquidHeatingSystem).HHWLoopExitTemp := FloatValueFromPath(GrandChildNode, 'HHWLoopExitTemp', -9999.0);
              T_EP_System(LiquidHeatingSystem).HHWLoopTempDifference := FloatValueFromPath(GrandChildNode, 'HHWLoopTempDifference', -9999.0);
            end;
            // Populate supply side
            GrandChildNode := ChildNode.FindNode('Equipment');
            if Assigned(Node) then
            begin
              if GrandChildNode.NodeCount > 0 then
              begin
                for j := 0 to GrandChildNode.NodeCount - 1 do
                begin
                  GreatGrandChildNode := GrandChildNode.Nodes[j];
                  if GreatGrandChildNode.Name = 'Pump' then
                  begin
                    Component := T_EP_Pump.Create;
                    LiquidHeatingSystem.AddSupplyComponent(Component);
                    T_EP_Pump(Component).Typ := StringValueFromPath(GreatGrandChildNode, 'Type');
                    T_EP_Pump(Component).RatedFlowRate := FloatValueFromPath(GreatGrandChildNode, 'FlowRate', -9999.0);
                    T_EP_Pump(Component).PressureDrop := FloatValueFromPath(GreatGrandChildNode, 'Head', 179352);
                    T_EP_Pump(Component).RatedPower := FloatValueFromPath(GreatGrandChildNode, 'Power', -9999.0);
                    T_EP_Pump(Component).Efficiency := FloatValueFromPath(GreatGrandChildNode, 'Efficiency');
                    T_EP_Pump(Component).CurveCoeff1 := FloatValueFromPath(GreatGrandChildNode, 'CurveCoeff1', -9999.0);
                    T_EP_Pump(Component).CurveCoeff2 := FloatValueFromPath(GreatGrandChildNode, 'CurveCoeff2', -9999.0);
                    T_EP_Pump(Component).CurveCoeff3 := FloatValueFromPath(GreatGrandChildNode, 'CurveCoeff3', -9999.0);
                    T_EP_Pump(Component).CurveCoeff4 := FloatValueFromPath(GreatGrandChildNode, 'CurveCoeff4', -9999.0);
                    T_EP_Pump(Component).PumpControlType := StringValueFromPath(GreatGrandChildNode, 'ControlType', False, '');
                  end
                  else if GreatGrandChildNode.Name = 'Boiler' then
                  begin
                    Component := T_EP_Boiler.Create;
                    LiquidHeatingSystem.AddSupplyComponent(Component);
                    T_EP_Boiler(Component).ComponentType := 'Boiler:' + StringValueFromPath(GreatGrandChildNode, 'Type', False, 'HotWater');
                    T_EP_Boiler(Component).Efficiency := FloatValueFromPath(GreatGrandChildNode, 'Efficiency');
                    T_EP_Boiler(Component).Fuel := StringValueFromPath(GreatGrandChildNode, 'Fuel');
                    T_EP_Boiler(Component).OutletTemperature := FloatValueFromPath(GreatGrandChildNode, 'OutletTemperature', 82.2);
                    T_EP_Boiler(Component).SizingFactor := FloatValueFromPath(GreatGrandChildNode, 'SizingFactor', 1.0);
                    T_EP_Boiler(Component).PerformanceCurve := StringValueFromPath(GreatGrandChildNode, 'PerformanceCurve', False, '');
                    T_EP_Boiler(Component).PerfCurveName := StringValueFromPath(GreatGrandChildNode, 'PerformanceCurveName', False, '');
                  end
                  else if GreatGrandChildNode.Name = 'WaterHeater' then
                  begin
                    Component := T_EP_WaterHeater.Create;
                    LiquidHeatingSystem.AddSupplyComponent(Component);
                    T_EP_WaterHeater(Component).Typ := StringValueFromPath(GreatGrandChildNode, 'Type');
                    T_EP_WaterHeater(Component).Fuel := StringValueFromPath(GreatGrandChildNode, 'Fuel');
                    T_EP_WaterHeater(Component).Efficiency := FloatValueFromPath(GreatGrandChildNode, 'Efficiency');
                  end
                  else if GreatGrandChildNode.Name = 'HeatPumpWaterToWater' then
                  begin
                    Component := T_EP_HeatPumpWaterToWater.Create;
                    LiquidHeatingSystem.AddSupplyComponent(Component);
                    T_EP_HeatPumpWaterToWater(Component).Typ := 'HEATING';
                    GroundHXSystem := T_EP_LiquidSystem.Create;
                    GroundHXSystem.Name := 'Ground Source HX System'; // can expand name
                    GroundHXSystem.SystemType := cSystemTypeCoolHeat;
                    GroundHXSystem.SetPointSchedule := 'Seasonal-Reset-Supply-Air-Temp-Sch'; // this is not right
                    GroundHXSystem.AddDemandComponent(Component);
                    GroundHXSystem.AddSupplyComponent(T_EP_Pump.Create);
                    GroundHXSystem.AddSupplyComponent(T_EP_GroundSourceHeatExchanger.Create);
                  end
                  else if GreatGrandChildNode.Name = 'ThermalStorageHotWater' then
                  begin
                    LiquidHeatingSystem.AddSupplyComponent(Component);
                  end
                  else if GreatGrandChildNode.Name = 'PurchasedHotWater' then
                  begin
                    Component := T_EP_PurchHotWater.Create;
                    LiquidHeatingSystem.AddSupplyComponent(Component);
                  end
                  else
                    WriteLn('Error:  Unhandled Liquid Heating Equipment child element = ' + ChildNode.Name);
                end;
              end;
            end;
          end;
        end;
      end; // assigned node
    end;
    if (Assigned(LiquidHeatingSystem) and Assigned(IndirectWaterHeaterObj)) then
    begin // add to existing liquid heating system
      // this only works if there is only the default heat system HeatSys1
      if (LiquidHeatingSystem.Name = 'HeatSys1') then
      begin
        T_EP_WaterHeater(IndirectWaterHeaterObj).DemandSystem := LiquidHeatingSystem;
        LiquidHeatingDemandComponents.Add(IndirectWaterHeaterObj);
        T_EP_WaterHeater(IndirectWaterHeaterObj).SourceSideOnSupply := False;
      end;
    end;
    if LiquidCoolingDemandComponents.Count > 0 then
    begin
      // ksb: loop through HVACSystems and find LiquidSystemCooling
      Node := RootNode.FindNode('/HPBParametization/HVACSystem/DetailedHVAC/Systems/HVACSystems');
      if Assigned(Node) then
      begin
        for i := 0 to Node.NodeCount - 1 do
        begin
          ChildNode := Node.Nodes[i];
          if SameText(ChildNode.Name,'LiquidSystemCooling') then
          begin
            LiquidCoolingSystem := T_EP_LiquidSystem.Create;
            if Assigned(ChildNode.FindNode('Name')) then
              LiquidCoolingSystem.Name := StringValueFromPath(ChildNode,'Name')
            else // ksb: assign the default name.  There can only be one unnamed liquid system heating
              LiquidCoolingSystem.Name := 'CoolSys1'; // Central Cooling Plant
              LiquidCoolingSystem.SystemType := cSystemTypeCool;
              LiquidCoolingSystem.SetPointSchedule := 'CW-Loop-Temp-Schedule';
            // Populate demand side
            for j := 0 to LiquidCoolingDemandComponents.Count - 1 do
            begin
              // ksb: check to see if the component is on this system
              // ksb: if the system has the default name and the component is unamed, consider that a match
              Component := THVACComponent(LiquidCoolingDemandComponents[j]);
              if SameText(Component.LiquidSystemName,LiquidCoolingSystem.Name) then
              begin
                LiquidCoolingSystem.AddDemandComponent(Component);
                if (TSystemComponent(Component).ComponentType <> 'ZoneHVAC:LowTemperatureRadiant:VariableFlow') then
                begin
                  TSystemComponent(Component).System :=  T_EP_System(LiquidCoolingSystem);
                end;
              end
              else if ((SameText(Component.LiquidSystemName,''))
              and (SameText(LiquidCoolingSystem.Name,'CoolSys1'))) then
              begin
                LiquidCoolingSystem.AddDemandComponent(Component);
                if (TSystemComponent(Component).ComponentType <> 'ZoneHVAC:LowTemperatureRadiant:VariableFlow') then
                begin
                  TSystemComponent(Component).System :=  T_EP_System(LiquidCoolingSystem);
                end;
              end;
              // ejb: get CHW loop sizing information
              if Assigned(ChildNode.NodeByName('Sizing')) then
              begin
                GrandChildNode := ChildNode.NodeByName('Sizing');
                T_EP_System(LiquidCoolingSystem).CHWLoopExitTemp := FloatValueFromPath(GrandChildNode, 'CHWLoopExitTemp', -9999.0);
                T_EP_System(LiquidCoolingSystem).CHWLoopTempDifference := FloatValueFromPath(GrandChildNode, 'CHWLoopTempDifference', -9999.0);
              end;
            end;
            // Populate supply side
            GrandChildNode := ChildNode.FindNode('Equipment');
            if Assigned(Node) then
            begin
              if GrandChildNode.NodeCount > 0 then
              begin
                for j := 0 to GrandChildNode.NodeCount - 1 do
                begin
                  GreatGrandChildNode := GrandChildNode.Nodes[j];
                  if GreatGrandChildNode.Name = 'Pump' then
                  begin
                    Component := T_EP_Pump.Create;
                    LiquidCoolingSystem.AddSupplyComponent(Component);
                    T_EP_Pump(Component).Typ := StringValueFromPath(GreatGrandChildNode, 'Type');
                    T_EP_Pump(Component).RatedFlowRate := FloatValueFromPath(GreatGrandChildNode, 'FlowRate', -9999.0);
                    T_EP_Pump(Component).PressureDrop := FloatValueFromPath(GreatGrandChildNode, 'Head', 179352);
                    T_EP_Pump(Component).RatedPower := FloatValueFromPath(GreatGrandChildNode, 'Power', -9999.0);
                    T_EP_Pump(Component).Efficiency := FloatValueFromPath(GreatGrandChildNode, 'Efficiency');
                    T_EP_Pump(Component).CurveCoeff1 := FloatValueFromPath(GreatGrandChildNode, 'CurveCoeff1', -9999.0);
                    T_EP_Pump(Component).CurveCoeff2 := FloatValueFromPath(GreatGrandChildNode, 'CurveCoeff2', -9999.0);
                    T_EP_Pump(Component).CurveCoeff3 := FloatValueFromPath(GreatGrandChildNode, 'CurveCoeff3', -9999.0);
                    T_EP_Pump(Component).CurveCoeff4 := FloatValueFromPath(GreatGrandChildNode, 'CurveCoeff4', -9999.0);
                    T_EP_Pump(Component).PumpControlType := StringValueFromPath(GreatGrandChildNode, 'ControlType', False, '');
                  end
                  else if GreatGrandChildNode.Name = 'Chiller' then
                  begin
                    //check for water cooled chiller and create condenser loop if true
                    for k := 0 to GreatGrandChildNode.NodeCount - 1 do
                    begin
                      if GreatGrandChildNode[k].Name = 'HeatRejection' then
                      begin
                        aString := StringValueFromPath(GreatGrandChildNode, 'HeatRejection', False, '');
                        bString := StringValueFromPath(GreatGrandChildNode, 'Type', False, '');
                        if ((AnsiContainsText(aString, 'WaterCooled')) and not (SameText(bString, 'HeatRecovery'))) then
                          CreateChillerCondenserLoop := True
                        else
                          CreateChillerCondenserLoop := False;
                      end;
                    end;
                    Component := T_EP_Chiller.Create;
                    LiquidCoolingSystem.AddSupplyComponent(Component);
                    //check for waterside economizer
                    for k := 0 to GrandChildNode.NodeCount - 1 do
                    begin
                      if GrandChildNode[k].Name = 'WatersideEconomizer' then
                      begin
                        T_EP_Chiller(Component).UseWatersideEconomizer := True;
                        T_EP_Chiller(Component).ControlType := 'Passive';
                      end;
                    end;
                    T_EP_Chiller(Component).Typ := StringValueFromPath(GreatGrandChildNode, 'Type', False, '');
                    T_EP_Chiller(Component).Capacity := FloatValueFromPath(GreatGrandChildNode, 'Capacity', -9999.0);
                    T_EP_Chiller(Component).COP := FloatValueFromPath(GreatGrandChildNode, 'COP', 2.7);
                    T_EP_Chiller(Component).HeatRejection := StringValueFromPath(GreatGrandChildNode, 'HeatRejection', False, 'AirCooled');
                    if SameText(T_EP_Chiller(Component).Typ, 'HeatRecovery') then
                    begin
                      HasHeatRecoveryChiller := true;
                      T_EP_Chiller(Component).Name := StringReplace(T_EP_Chiller(Component).Name, 'Chiller', 'Heat Recovery Chiller', [rfReplaceAll]);
                    end;
                    T_EP_Chiller(Component).DataSetKey := StringValueFromPath(GreatGrandChildNode, 'DataSetKey', False, 'DOE2');
                    //get condenser loop temperatures
                    Node2 := RootNode.FindNode('/HPBParametization/HVACSystem/DetailedHVAC/Systems/HVACSystems/LiquidSystemCooling/CondenserLoop');
                    if Assigned(Node2) and not SameText(T_EP_Chiller(Component).Typ, 'HeatRecovery') and not SameText(T_EP_Chiller(Component).HeatRejection, 'AirCooled') then
                    begin
                      T_EP_Chiller(Component).HeatRejectionLoop.CondLoopDesignExitTemp := FloatValueFromPath(Node2, 'DesignExitTemp', -9999.0);
                      T_EP_Chiller(Component).HeatRejectionLoop.CondLoopDesignDeltaTemp := FloatValueFromPath(Node2, 'DesignDeltaTemp', -9999.0);
                      //get condenser loop pump information
                      Node3 := RootNode.FindNode('/HPBParametization/HVACSystem/DetailedHVAC/Systems/HVACSystems/LiquidSystemCooling/CondenserLoop/Pump');
                      if Assigned(Node3) then
                      begin
                        T_EP_Chiller(Component).UserDefCondPump := True;
                        T_EP_Chiller(Component).HeatRejectionLoop.CondLoopPumpType := StringValueFromPath(Node3, 'Type', False, '');
                        T_EP_Chiller(Component).HeatRejectionLoop.CondLoopPumpFlowRate := FloatValueFromPath(Node3, 'FlowRate', -9999.0);
                        T_EP_Chiller(Component).HeatRejectionLoop.CondLoopPumpHead := FloatValueFromPath(Node3, 'Head', -9999.0);
                        T_EP_Chiller(Component).HeatRejectionLoop.CondLoopPumpPower := FloatValueFromPath(Node3, 'Power', -9999.0);
                        T_EP_Chiller(Component).HeatRejectionLoop.CondLoopPumpEfficiency := FloatValueFromPath(Node3, 'Efficiency', -9999.0);
                        T_EP_Chiller(Component).HeatRejectionLoop.CondLoopPumpCurveCoeff1 := FloatValueFromPath(Node3, 'CurveCoeff1', -9999.0);
                        T_EP_Chiller(Component).HeatRejectionLoop.CondLoopPumpCurveCoeff2 := FloatValueFromPath(Node3, 'CurveCoeff2', -9999.0);
                        T_EP_Chiller(Component).HeatRejectionLoop.CondLoopPumpCurveCoeff3 := FloatValueFromPath(Node3, 'CurveCoeff3', -9999.0);
                        T_EP_Chiller(Component).HeatRejectionLoop.CondLoopPumpCurveCoeff4 := FloatValueFromPath(Node3, 'CurveCoeff4', -9999.0);
                        T_EP_Chiller(Component).HeatRejectionLoop.CondLoopPumpControlType := StringValueFromPath(Node3, 'ControlType', False, '');
                      end;
                    end;
                    T_EP_Chiller(Component).OutletTemperature := FloatValueFromPath(GreatGrandChildNode, 'OutletTemperature', 6.67);
                    T_EP_Chiller(Component).OptimumPartLoadRatio := FloatValueFromPath(GreatGrandChildNode, 'OptimumPartLoadRatio', 1.0);
                    T_EP_Chiller(Component).MinimumUnloadingRatio := FloatValueFromPath(GreatGrandChildNode, 'MinimumUnloadingRatio', 0.25);
                    T_EP_Chiller(Component).FlowMode := StringValueFromPath(GreatGrandChildNode, 'FlowMode', False, 'NotModulated');
                    T_EP_Chiller(Component).SizingFactor := FloatValueFromPath(GreatGrandChildNode, 'SizingFactor', 1.0);
                  end
                  else if GreatGrandChildNode.Name = 'HeatPumpWaterToWater' then
                  begin
                    Component := T_EP_HeatPumpWaterToWater.Create;
                    LiquidCoolingSystem.AddSupplyComponent(Component);
                    T_EP_HeatPumpWaterToWater(Component).Typ := 'COOLING';
                    if Assigned(GroundHXSystem) then
                    begin
                      GroundHXSystem.AddDemandComponent(Component);
                    end
                    else
                    begin
                      GroundHXSystem := T_EP_LiquidSystem.Create;
                      GroundHXSystem.Name := 'Ground Source HX System'; // can expand name
                      GroundHXSystem.SystemType := cSystemTypeCoolHeat;
                      GroundHXSystem.SetPointSchedule := 'Seasonal-Reset-Supply-Air-Temp-Sch'; // this is not right
                      GroundHXSystem.AddDemandComponent(Component);
                      GroundHXSystem.AddSupplyComponent(T_EP_Pump.Create);
                      GroundHXSystem.AddSupplyComponent(T_EP_GroundSourceHeatExchanger.Create);
                    end;
                  end
                  else if GreatGrandChildNode.Name = 'ThermalStorageIce' then
                  begin
                    Component := T_EP_IceStorage.Create;
                    LiquidCoolingSystem.AddSupplyComponent(Component);
                    T_EP_IceStorage(Component).Typ := StringValueFromPath(ChildNode, 'Type');
                    T_EP_IceStorage(Component).Capacity := FloatValueFromPath(ChildNode, 'Capacity');
                  end
                  else if GreatGrandChildNode.Name = 'PurchasedChilledWater' then
                  begin
                    Component := T_EP_PurchChilledWater.Create;
                    LiquidCoolingSystem.AddSupplyComponent(Component);
                  end
                  else if GreatGrandChildNode.Name = 'WatersideEconomizer' then
                  begin
                    Component := T_EP_WatersideEconomizer.Create;
                    LiquidCoolingSystem.AddSupplyComponent(Component);
                    LiquidCoolingSystem.UseWatersideEconomizer := True;
                    T_EP_WatersideEconomizer(Component).HeatExchangerType := StringValueFromPath(GreatGrandChildNode, 'HeatExchangerType', False, '');
                    T_EP_WatersideEconomizer(Component).ControlType := 'Passive';
                  end
                  else
                    WriteLn('Error:  Unhandled Liquid Cooling Equipment child element = ' + ChildNode.Name);
                end;
              end;
            end;
          end;
        end;
      end;
    end;
    if HeatRecoveryRecipientComponents.Count > 0 Then
    begin
      HeatRecoverySystem := T_EP_LiquidSystem.Create;
      HeatRecoverySystem.name := 'HeatRecv1'; // central heat recovery loop
      HeatRecoverySystem.SystemType :=  cSystemHeatRecovery;
      //HeatRecoverySystem.SetPointSchedule :=   ?? need dynamic ??
      Node := RootNode.FindNode('/HPBParametization/HVACSystem/DetailedHVAC/Systems/HVACSystems/LiquidSystemHeatRecovery');
      If Assigned(Node) then
      begin
        for j := 0 to Node.NodeCount - 1 do
        begin
          ChildNode := Node.Nodes[j];
          if ChildNode.Name = 'Name' then
          begin
            HeatRecoverySystem.name := StringValueFromPath(Node, 'Name');
          end;
          if ChildNode.Name = 'LoopSetpointTemperature' then
          begin
            HeatRecoverySystem.LoopTempSetpoint := FloatValueFromPath(Node, 'LoopSetpointTemperature');
          end;
        end;
      end;
      //populate heat rocovery equipment (mix of both supply and demand side)
      Node := RootNode.FindNode('/HPBParametization/HVACSystem/DetailedHVAC/Systems/HVACSystems/LiquidSystemHeatRecovery/Equipment');
      if Assigned(Node) then
      begin
        if Node.NodeCount > 0 then
        begin
          for j := 0 to Node.NodeCount - 1 do
          begin
            ChildNode := Node.Nodes[j];
            if ChildNode.Name = 'Pump' then
            begin
              Component := T_EP_Pump.Create;
              HeatRecoverySystem.AddSupplyComponent(Component);
              T_EP_Pump(Component).Typ := StringValueFromPath(ChildNode, 'Type');
              T_EP_Pump(Component).RatedFlowRate := FloatValueFromPath(ChildNode, 'FlowRate', -9999.0);
              T_EP_Pump(Component).PressureDrop := FloatValueFromPath(ChildNode, 'Head', 179352);
              T_EP_Pump(Component).RatedPower := FloatValueFromPath(ChildNode, 'Power', -9999.0);
              T_EP_Pump(Component).Efficiency := FloatValueFromPath(ChildNode, 'Efficiency');
              T_EP_Pump(Component).CurveCoeff1 := FloatValueFromPath(ChildNode, 'CurveCoeff1', -9999.0);
              T_EP_Pump(Component).CurveCoeff2 := FloatValueFromPath(ChildNode, 'CurveCoeff2', -9999.0);
              T_EP_Pump(Component).CurveCoeff3 := FloatValueFromPath(ChildNode, 'CurveCoeff3', -9999.0);
              T_EP_Pump(Component).CurveCoeff4 := FloatValueFromPath(ChildNode, 'CurveCoeff4', -9999.0);
              T_EP_Pump(Component).PumpControlType := StringValueFromPath(ChildNode, 'ControlType', False, '');
            end
            else if ChildNode.Name = 'Boiler' then
            begin
              Component := T_EP_Boiler.Create;
              HeatRecoverySystem.AddSupplyComponent(Component);
              T_EP_Boiler(Component).ComponentType := 'Boiler:' + StringValueFromPath(ChildNode, 'Type', False, 'HotWater');
              T_EP_Boiler(Component).Efficiency := FloatValueFromPath(ChildNode, 'Efficiency');
              T_EP_Boiler(Component).Fuel := StringValueFromPath(ChildNode, 'Fuel');
            end
            else if childNode.Name = 'CoGeneratorMicroCHP' then
            begin
              if not Assigned(ElectricLoadCenter) then
                ElectricLoadCenter := T_EP_ElectricLoadCenter.Create;
              Component := T_EP_MicroCHP.create;
              If (T_EP_WaterHeater(HeatRecoveryWaterHeaterObj).Typ = 'HEATRECOVERYELECTRICFOLLOW') then
              begin
                HeatRecoverySystem.AddDemandComponent(Component);
              end
              else if  ( T_EP_WaterHeater(HeatRecoveryWaterHeaterObj).Typ = 'HEATRECOVERYELECTRICFOLLOWSTRATIFIED') then
              begin
                HeatRecoverySystem.AddDemandComponent(Component);
              end
              else if  (T_EP_WaterHeater(HeatRecoveryWaterHeaterObj).Typ = 'HEATRECOVERYTHERMALFOLLOW') then
              begin
                HeatRecoverySystem.AddSupplyComponent(Component);
              end
              else if  (T_EP_WaterHeater(HeatRecoveryWaterHeaterObj).Typ = 'HEATRECOVERYTHERMALFOLLOWSTRATIFIED') then
              begin
                HeatRecoverySystem.AddSupplyComponent(Component);
              end;
              T_EP_MicroCHP(Component).CombustionType :=  StringValueFromPath(ChildNode, 'Type');
              T_EP_MicroCHP(Component).ControlMode  :=  StringValueFromPath(ChildNode, 'ControlMode');
              T_EP_MicroCHP(Component).A42inputsetKey := StringValueFromPath(childNode, 'DataSet');
              T_EP_MicroCHP(Component).FuelType    := StringValueFromPath(childNode, 'Fuel');
              T_EP_MicroCHP(Component).RatedOutput := FloatValueFromPath(ChildNode, 'RatedOutput');
              T_EP_MicroCHP(Component).RatedThermElecRatio  := FloatValueFromPath(ChildNode, 'RatedThermalElectricalRatio');
              T_EP_MicroCHP(Component).ZoneName    := StringValueFromPath(ChildNode, 'ZoneName');
              T_EP_MicroCHP(Component).Name     := 'MicroCoGen1';
              if (T_EP_WaterHeater(HeatRecoveryWaterHeaterObj).Typ = 'HEATRECOVERYELECTRICFOLLOW') then
              begin
                T_EP_MicroCHP(Component).DemandSystem := HeatRecoverySystem;
              end
              else If (T_EP_WaterHeater(HeatRecoveryWaterHeaterObj).Typ = 'HEATRECOVERYELECTRICFOLLOWSTRATIFIED') then
              begin
                T_EP_MicroCHP(Component).DemandSystem := HeatRecoverySystem;
              end
              else if  (T_EP_WaterHeater(HeatRecoveryWaterHeaterObj).Typ = 'HEATRECOVERYTHERMALFOLLOW') then
              begin
                T_EP_MicroCHP(Component).System := HeatRecoverySystem;
                T_EP_MicroCHP(Component).DemandSidePosition := false ;
              end
              else if  (T_EP_WaterHeater(HeatRecoveryWaterHeaterObj).Typ = 'HEATRECOVERYTHERMALFOLLOWSTRATIFIED') then
              begin
                T_EP_MicroCHP(Component).System := HeatRecoverySystem;
                T_EP_MicroCHP(Component).DemandSidePosition := false ;
              end;
              if  T_EP_MicroCHP(Component).ZoneName <> ' ' then
              begin
                //find zone object with this name.
                for i := 0 to Zones.Count - 1 do
                begin
                  Zone := T_EP_Zone(Zones[i]);
                  if Zone.Name = T_EP_MicroCHP(Component).ZoneName then //found it
                  begin
                     T_EP_MicroCHP(Component).ZoneObj := Zone;
                     Zone.AirExhaustNodes.Add(T_EP_MicroCHP(Component).Name + ' Air Inlet Node Name');
                  end;
                end;
              end;
            end
            else
              WriteLn('Error:  Unhandled Heat Recovery Equipment child element = ' + ChildNode.Name);
          end;
        end;
      end;
       // Populate recipient side  (supply side)
      if ( Assigned(HeatRecoveryWaterHeaterObj) and (T_EP_WaterHeater(HeatRecoveryWaterHeaterObj).Typ = 'HEATRECOVERYELECTRICFOLLOW')) then
      begin //
        T_EP_WaterHeater(HeatRecoveryWaterHeaterObj).SetSourceSideSupplySystem(HeatRecoverySystem);
        T_EP_WaterHeater(HeatRecoveryWaterHeaterObj).SourceSideOnSupply := true;
        HeatRecoverySystem.AddSupplyComponent(HeatRecoveryWaterHeaterObj);
      end;
      if ( Assigned(HeatRecoveryWaterHeaterObj) and (T_EP_WaterHeater(HeatRecoveryWaterHeaterObj).Typ = 'HEATRECOVERYELECTRICFOLLOWSTRATIFIED')) then
      begin //
        T_EP_WaterHeater(HeatRecoveryWaterHeaterObj).SetSourceSideSupplySystem(HeatRecoverySystem);
        T_EP_WaterHeater(HeatRecoveryWaterHeaterObj).SourceSideOnSupply := true;
        HeatRecoverySystem.AddSupplyComponent(HeatRecoveryWaterHeaterObj);
      end;
      if ( Assigned(HeatRecoveryWaterHeaterObj) and (T_EP_WaterHeater(HeatRecoveryWaterHeaterObj).Typ = 'HEATRECOVERYTHERMALFOLLOW')) then
      begin //
        T_EP_WaterHeater(HeatRecoveryWaterHeaterObj).SetSourceSideSupplySystem(HeatRecoverySystem);
        T_EP_WaterHeater(HeatRecoveryWaterHeaterObj).SourceSideOnSupply := false;
        HeatRecoverySystem.AddDemandComponent(HeatRecoveryWaterHeaterObj);
        HeatRecoveryWaterHeaterObj.DemandSystem:= HeatRecoverySystem;
      end;
      if ( Assigned(HeatRecoveryWaterHeaterObj) and (T_EP_WaterHeater(HeatRecoveryWaterHeaterObj).Typ = 'HEATRECOVERYTHERMALFOLLOWSTRATIFIED')) then
      begin //
        T_EP_WaterHeater(HeatRecoveryWaterHeaterObj).SetSourceSideSupplySystem(HeatRecoverySystem);
        T_EP_WaterHeater(HeatRecoveryWaterHeaterObj).SourceSideOnSupply := false;
        HeatRecoverySystem.AddDemandComponent(HeatRecoveryWaterHeaterObj);
        HeatRecoveryWaterHeaterObj.DemandSystem:= HeatRecoverySystem;
      end;
      // now Populate demand side of water heater loop (these would normally go to LiquidHeatingSystem but don't here
      if LiquidHeatingDemandComponents.Count > 0 then
      begin
        for i := 0 to LiquidHeatingDemandComponents.Count - 1 do
        begin
          Component := THVACComponent(LiquidHeatingDemandComponents[i]);
          HotWaterSystem.AddDemandComponent(Component);
        end;
      end;
    end;
    // ksb: find condenser loops
    Node := RootNode.FindNode('/HPBParametization/HVACSystem/DetailedHVAC/Systems/HVACSystems');
    if Assigned(Node) then
    begin
      if Node.NodeCount > 0 then
      begin
        for kk := 0 to Node.NodeCount - 1 do
        begin
          ChildNode := Node.Nodes[kk];
          if (ChildNode.Name = 'LiquidSystemCondenser') then
          begin
            aLiquidSystem := T_EP_LiquidSystem.Create;
            aLiquidSystem.Name := StringValueFromPath(ChildNode, 'Name', False);
            aLiquidSystem.DesignFlowRate := FloatValueFromPath(ChildNode, 'DesignFlowRate', -9999.0);
            aLiquidSystem.ExitTemp := FloatValueFromPath(ChildNode, 'ExitTemp', 21.0);
            aLiquidSystem.DeltaTemp := FloatValueFromPath(ChildNode, 'DeltaTemp', 5.0);
            aLiquidSystem.SystemType := cSystemTypeGroundLoop;
            GrandChildNode := ChildNode.FindNode('Equipment');
            if Assigned(GrandChildNode) then
            begin
              if GrandChildNode.NodeCount > 0 then
              begin
                for jj := 0 to GrandChildNode.NodeCount - 1 do
                begin
                  GreatGrandChildNode := GrandChildNode.Nodes[jj];
                  if GreatGrandChildNode.Name = 'Pump' then
                  begin
                    Component := T_EP_Pump.Create;
                    T_EP_Pump(Component).Typ := StringValueFromPath(GreatGrandChildNode, 'Type');
                    T_EP_Pump(Component).RatedFlowRate := FloatValueFromPath(GreatGrandChildNode, 'FlowRate', -9999.0);
                    T_EP_Pump(Component).PressureDrop := FloatValueFromPath(GreatGrandChildNode, 'Head', 179352);
                    T_EP_Pump(Component).RatedPower := FloatValueFromPath(GreatGrandChildNode, 'Power', -9999.0);
                    T_EP_Pump(Component).Efficiency := FloatValueFromPath(GreatGrandChildNode, 'Efficiency');
                    T_EP_Pump(Component).CurveCoeff1 := FloatValueFromPath(GreatGrandChildNode, 'CurveCoeff1', -9999.0);
                    T_EP_Pump(Component).CurveCoeff2 := FloatValueFromPath(GreatGrandChildNode, 'CurveCoeff2', -9999.0);
                    T_EP_Pump(Component).CurveCoeff3 := FloatValueFromPath(GreatGrandChildNode, 'CurveCoeff3', -9999.0);
                    T_EP_Pump(Component).CurveCoeff4 := FloatValueFromPath(GreatGrandChildNode, 'CurveCoeff4', -9999.0);
                    T_EP_Pump(Component).PumpControlType := StringValueFromPath(GreatGrandChildNode, 'ControlType', False, '');
                    if aLiquidSystem.DesignFlowRate > 0 then
                      T_EP_Pump(Component).RatedFlowRate := aLiquidSystem.DesignFlowRate
                    else
                      T_EP_Pump(Component).RatedFlowRate := -9999.0;
                    aLiquidSystem.AddSupplyComponent(Component);
                  end
                  else if GreatGrandChildNode.Name = 'GroundHX' then
                  begin
                    Component := T_EP_GroundSourceHeatExchanger.Create;
                    T_EP_GroundSourceHeatExchanger(Component).IMFDef := StringValueFromPath(GreatGrandChildNode, 'IMFDef');
                    T_EP_GroundSourceHeatExchanger(Component).GroundTemp := FloatValueFromPath(GreatGrandChildNode, 'GroundTemp', 13.33);
                    aLiquidSystem.AddSupplyComponent(Component);
                  end
                  else if GreatGrandChildNode.Name = 'FluidCooler' then
                  begin
                    Component := T_EP_FluidCooler.Create;
                    T_EP_FluidCooler(Component).Typ := StringValueFromPath(GreatGrandChildNode, 'Type', False, 'Dry');
                    T_EP_FluidCooler(Component).Capacity := FloatValueFromPath(GreatGrandChildNode, 'Capacity', -9999.0);
                    aLiquidSystem.AddSupplyComponent(Component);
                  end
                  else if GreatGrandChildNode.Name = 'Boiler' then
                  begin
                    Component := T_EP_Boiler.Create;
                    T_EP_Boiler(Component).ComponentType := 'Boiler:' + StringValueFromPath(ChildNode, 'Type', False, 'HotWater');
                    T_EP_Boiler(Component).Efficiency := FloatValueFromPath(GreatGrandChildNode, 'Efficiency');
                    T_EP_Boiler(Component).Fuel := StringValueFromPath(GreatGrandChildNode, 'Fuel');
                    T_EP_Boiler(Component).Capacity := FloatValueFromPath(GreatGrandChildNode, 'Capacity', -9999.0);
                    // ksb: perhaps this should go in a finalize routine
                    // but then would have to detect what type of system
                    // the boiler is on
                    T_EP_Boiler(Component).SizingFactor := FloatValueFromPath(GreatGrandChildNode, 'SizingFactor', 1.0);
                    T_EP_Boiler(Component).OutletTemperature := FloatValueFromPath(GreatGrandChildNode, 'OutletTemp', 7.0);
                    T_EP_Boiler(Component).PerformanceCurve := StringValueFromPath(GreatGrandChildNode, 'PerformanceCurve', False);
                    T_EP_Boiler(Component).PerfCurveName := StringValueFromPath(GreatGrandChildNode, 'PerformanceCurveName', False, '');
                    T_EP_Boiler(Component).ControlType := 'Passive';
                    aLiquidSystem.AddSupplyComponent(Component);
                  end
                  else if GreatGrandChildNode.Name = 'Chiller' then
                  begin
                    Component := T_EP_Chiller.Create;
                    aLiquidSystem.AddSupplyComponent(Component);
                    T_EP_Chiller(Component).Typ := StringValueFromPath(GreatGrandChildNode, 'Type', False, '');
                    T_EP_Chiller(Component).COP := FloatValueFromPath(GreatGrandChildNode, 'COP', 2.7);
                    //check for waterside economizer
                    for i := 0 to GrandChildNode.NodeCount - 1 do
                    begin
                      if GrandChildNode[i].Name = 'WatersideEconomizer' then
                        T_EP_Chiller(Component).UseWatersideEconomizer := True;
                    end;
                    T_EP_Chiller(Component).HeatRejection := StringValueFromPath(GreatGrandChildNode, 'HeatRejection', False, 'AirCooled');
                    T_EP_Chiller(Component).DataSetKey := StringValueFromPath(GreatGrandChildNode, 'DataSetKey', False, 'DOE2');
                    T_EP_Chiller(Component).OutletTemperature := FloatValueFromPath(GreatGrandChildNode, 'OutletTemperature', 6.67);
                    T_EP_Chiller(Component).OptimumPartLoadRatio := FloatValueFromPath(GreatGrandChildNode, 'OptimumPartLoadRatio', 1.0);
                    T_EP_Chiller(Component).MinimumUnloadingRatio := FloatValueFromPath(GreatGrandChildNode, 'MinimumUnloadingRatio', 0.25);
                    T_EP_Chiller(Component).FlowMode := StringValueFromPath(GreatGrandChildNode, 'FlowMode', False, 'NotModulated');
                    T_EP_Chiller(Component).SizingFactor := FloatValueFromPath(GreatGrandChildNode, 'SizingFactor', 1.0);
                    if AnsiContainsStr(T_EP_Chiller(Component).HeatRejection, 'WaterCooled') then
                      T_EP_Chiller(Component).HeatRejectionLoop.CondLoopDesignExitTemp := FloatValueFromPath(GreatGrandChildNode, 'TowerLoopTemp', -9999.0);
                    T_EP_Chiller(Component).ControlType := 'Passive';
                  end
                  else if GreatGrandChildNode.Name = 'WatersideEconomizer' then
                  begin
                    Component := T_EP_WatersideEconomizer.Create;
                    aLiquidSystem.AddSupplyComponent(Component);
                    aLiquidSystem.UseWatersideEconomizer := True;
                    T_EP_WatersideEconomizer(Component).HeatExchangerType := StringValueFromPath(GreatGrandChildNode, 'HeatExchangerType', False, '');
                    T_EP_WatersideEconomizer(Component).ControlType := 'Passive';
                  end;
                end;
              end;
            end;
            // ksb: add demand components
            // ksb: some air system supply components are demand components on the condenser system
            for j := 0 to Systems.Count - 1 do
            begin
              if Systems.Items[j] is T_EP_AirSystem then
              with T_EP_AirSystem(Systems.Items[j]) do
              begin
                for i := 0 to SupplyComponents.Count - 1 do
                begin
                  if SupplyComponents.Items[i] is T_EP_UnitaryPackage then
                  begin
                    UTPComponent := T_EP_UnitaryPackage(SupplyComponents.Items[i]);
                    if SameText(UTPComponent.LiquidSystemCondenserName, aLiquidSystem.Name) then
                    begin
                      aLiquidSystem.AddDemandComponent(UTPComponent);
                    end;
                  end;
                end;
              end;
            end;
            for mm := 0 to Zones.Count - 1 do
            begin
              Zone := T_EP_Zone(Zones[mm]);
              for nn := 0 to Zone.SpaceConditioning.Count - 1 do
              begin
                if SameText(T_EP_HeatPumpWaterToAir(Zone.SpaceConditioning[nn]).ComponentType, 'ZoneHVAC:WaterToAirHeatPump') then
                begin
                  ZoneHPComponent := T_EP_HeatPumpWaterToAir(Zone.SpaceConditioning[nn]);
                  if SameText(ZoneHPComponent.LiqSysCondName, aLiquidSystem.Name) then
                  begin
                    aLiquidSystem.AddDemandComponent(ZoneHPComponent)
                  end;
                end;
              end;
            end;
          end;
        end;
      end;
    end;
  end;
  WriteLn('Finished Reading HVAC');
  //now process refrigeration compressor rack system.
  aList := TList.Create;
  try
    RootNode.FindNodes('/HPBParametization/HVACSystem/DetailedHVAC/Systems/RefrigerationCompressorRack', aList);
    if aList.Count <> 0 then
    begin
      for iRack := 0 to aList.Count - 1 do
      begin
        thisRack := T_EP_RefrigerationCompressorRack.Create;
        RefrigCompressorRack.Add(thisRack);
        aNode := TXmlNode(aList.Items[iRack]);
        T_EP_RefrigerationCompressorRack(RefrigCompressorRack.Items[iRack]).Name := StringValueFromPath(aNode, 'Name', False, 'NotSet');
        T_EP_RefrigerationCompressorRack(RefrigCompressorRack.Items[iRack]).DataSetKey := StringValueFromPath(aNode, 'DataSetKey', False, 'NotSet');
        T_EP_RefrigerationCompressorRack(RefrigCompressorRack.Items[iRack]).COP := FloatValueFromPath(aNode, 'COP', -9999.0 );
        T_EP_RefrigerationCompressorRack(RefrigCompressorRack.Items[iRack]).HeatRejection := StringValueFromPath(aNode, 'CondenserType', False, 'AirCooled');
        T_EP_RefrigerationCompressorRack(RefrigCompressorRack.Items[iRack]).EvapEffectiveness := FloatValueFromPath(aNode, 'EffectivenessEvapCooled', -9999.0);
        T_EP_RefrigerationCompressorRack(RefrigCompressorRack.Items[iRack]).FanPower := FloatValueFromPath(aNode, 'FanPower', -9999.0);
        T_EP_RefrigerationCompressorRack(RefrigCompressorRack.Items[iRack]).HeatRejectionLocation := StringValueFromPath(aNode, 'HeatRejectionLocation', False, 'Outdoors');
        T_EP_RefrigerationCompressorRack(RefrigCompressorRack.Items[iRack]).HeatRejectionZone := StringValueFromPath(aNode, 'HeatRejectionZone', False, 'NotSet');
      end;
    end;
  finally
    aList.free;
  end;
  // check and setup racks and cases
  if (RefrigCaseComponents.Count > 0) or (RefrigWalkinComponents.Count > 0) then
  begin
    for iCase := 0 to  RefrigCaseComponents.Count - 1 do
    begin
      for iRack := 0 to RefrigCompressorRack.Count - 1 do
      begin
        if SameText(T_EP_RefrigeratedCase(RefrigCaseComponents.Items[iCase]).CompressorRackName,
             T_EP_RefrigerationCompressorRack(RefrigCompressorRack.Items[iRack]).Name) then
        begin
          T_EP_RefrigeratedCase(RefrigCaseComponents[iCase]).CompressorRackObj := T_EP_RefrigerationCompressorRack(RefrigCompressorRack.Items[iRack]);
          T_EP_RefrigeratedCase(RefrigCaseComponents[iCase]).Finalize;
          T_EP_RefrigerationCompressorRack(RefrigCompressorRack.Items[iRack]).RefrigeratedCase.Add(T_EP_RefrigeratedCase(RefrigCaseComponents.Items[iCase]));
        end; // if match
      end; // for
    end; // for
    for iWalkin := 0 to RefrigWalkinComponents.Count - 1 do
    begin
      for iRack := 0 to RefrigCompressorRack.Count - 1 do
      begin
        if SameText(T_EP_RefrigeratedWalkin(RefrigWalkinComponents.Items[iWalkin]).CompressorRackName,
             T_EP_RefrigerationCompressorRack(RefrigCompressorRack.Items[iRack]).Name) then
        begin
          T_EP_RefrigeratedWalkin(RefrigWalkinComponents[iWalkin]).CompressorRackObj := T_EP_RefrigerationCompressorRack(RefrigCompressorRack.Items[iRack]);
          T_EP_RefrigeratedWalkin(RefrigWalkinComponents[iWalkin]).Finalize;
          T_EP_RefrigerationCompressorRack(RefrigCompressorRack.Items[iRack]).RefrigeratedWalkin.Add(T_EP_RefrigeratedWalkin(RefrigWalkinComponents.Items[iWalkin]));
        end;
      end;
    end;
  end;
  //now process refrigeration system
  if (RefrigCaseComponents.Count > 0) or (RefrigWalkinComponents.Count > 0) then
  begin
    CompressorID := 1;
    //loop though systems and find refrigeration systems
    Node := RootNode.FindNode('/HPBParametization/HVACSystem/DetailedHVAC/Systems');
    if Assigned(Node) then
    begin
      for i := 0 to Node.NodeCount - 1 do
      begin
        ChildNode := Node.Nodes[i];
        if SameText(ChildNode.Name, 'RefrigerationSystem') then
        begin
          RefrigerationSystem := T_EP_RefrigerationSystem.Create;
          RefrigSystems.Add(RefrigerationSystem);
          if Assigned(ChildNode.FindNode('Name')) then
          begin
            RefrigerationSystem.Name := StringValueFromPath(ChildNode, 'Name', False, 'NotSet');
            RefrigerationSystem.Refrigerant := StringValueFromPath(ChildNode, 'Refrigerant', False, 'R22');
            RefrigerationSystem.MinCondensingTemp := FloatValueFromPath(ChildNode, 'MinCondensingTemp', -9999.0);
            with RefrigerantList do
            begin
               Sorted := true;
               Duplicates := dupIgnore;
               Add(RefrigerationSystem.Refrigerant);
            end;
          end;
          //populate demand side (refrigerated cases)
          for iCase := 0 to  RefrigCaseComponents.Count - 1 do
          begin
            for iRefrigSys := 0 to RefrigSystems.Count - 1 do
            begin
              if SameText(T_EP_RefrigerationSystem(RefrigSystems.Items[iRefrigSys]).Name,
                T_EP_RefrigeratedCase(RefrigCaseComponents.Items[iCase]).RefrigSystemName) then
              begin
                T_EP_RefrigeratedCase(RefrigCaseComponents[iCase]).RefrigSysObj := T_EP_RefrigerationSystem(RefrigSystems.Items[iRefrigSys]);
                T_EP_RefrigeratedCase(RefrigCaseComponents[iCase]).Finalize;
                T_EP_RefrigerationSystem(RefrigSystems.Items[iRefrigSys]).RefrigeratedCase.Add(T_EP_RefrigeratedCase(RefrigCaseComponents[iCase]));
              end;
            end;
          end;
          for iWalkin := 0 to RefrigWalkinComponents.Count - 1 do
          begin
            for iRefrigSys := 0 to RefrigSystems.Count - 1 do
            begin
              if SameText(T_EP_RefrigerationSystem(RefrigSystems.Items[iRefrigSys]).Name,
                T_EP_RefrigeratedWalkin(RefrigWalkinComponents.Items[iWalkin]).RefrigSystemName) then
              begin
                T_EP_RefrigeratedWalkin(RefrigWalkinComponents[iWalkin]).RefrigSysObj := T_EP_RefrigerationSystem(RefrigSystems.Items[iRefrigSys]);
                T_EP_RefrigeratedWalkin(RefrigWalkinComponents[iWalkin]).Finalize;
                T_EP_RefrigerationSystem(RefrigSystems.Items[iRefrigSys]).RefrigeratedWalkin.Add(T_EP_RefrigeratedWalkin(RefrigWalkinComponents[iWalkin]));
              end;
            end;
          end;
          //populate supply side (refrigeration system components)
          GrandChildNode := ChildNode.FindNode('Equipment');
          if Assigned(GrandChildNode) then
          begin
            if GrandChildNode.NodeCount > 0 then
            begin
              for j := 0 to GrandChildNode.NodeCount - 1 do
              begin
                GreatGrandChildNode := GrandChildNode[j];
                if SameText(GreatGrandChildNode.Name, 'Compressor') then
                begin
                  Component := T_EP_RefrigerationCompressor.Create;
                  RefrigerationSystem.AddRefrigSystemComponent(Component);
                  T_EP_RefrigerationCompressor(Component).CompressorID := CompressorID;
                  T_EP_RefrigerationCompressor(Component).DataSetKey := StringValueFromPath(GreatGrandChildNode, 'DataSetKey', False, 'NotSet');
                  inc(CompressorID);
                end
                else if SameText(GreatGrandChildNode.Name, 'Condenser') then
                begin
                  Component := T_EP_RefrigerationCondenser.Create;
                  RefrigerationSystem.AddRefrigSystemComponent(Component);
                  T_EP_RefrigerationCondenser(Component).DataSetKey := StringValueFromPath(GreatGrandChildNode, 'DataSetKey', False, 'NotSet');
                  T_EP_RefrigerationCondenser(Component).HeatRejection := StringValueFromPath(GreatGrandChildNode, 'Type', False, 'AirCooled');
                  T_EP_RefrigerationCondenser(Component).FanType := StringValueFromPath(GreatGrandChildNode, 'FanType', False, 'NotSet');
                  T_EP_RefrigerationCondenser(Component).FanPower := FloatValueFromPath(GreatGrandChildNode, 'FanPower', -9999.0);
                end;
              end;
            end;
          end;
        end;
      end;
    end;
  end;
  // Design the ElectricLoadCenter if we have one
  if Assigned(ElectricLoadCenter) then
    ElectricLoadCenter.DesignElectricLoadCenter(ElectricLoadCenter_Params);
    //now process cold water service "system"
  { CondLoop := T_EP_CondenserSystem.Create;
    PlantLoop.SystemType := cSystemTypeCool;
    PlantLoop.SetPointSchedule := 'Seasonal-Reset-Supply-Air-Temp-Sch';
    // Add components to systems
    Coil := AirLoop.AddSupplyComponent(T_EP_Coil.Create); // this pattern is kind of not fair:  systems can't do this; obfuscates the Create a bit
    PlantLoop.AddDemandComponent(Coil);
    HP := T_EP_HeatPumpWaterToWater.Create;
    PlantLoop.AddSupplyComponent(HP);
    CondLoop.AddDemandComponent(HP);     // another paradigm is:  HP.ConnectDemandSystem(CondLoop);
    GSHX := T_EP_GroundSourceHeatExchanger.Create;
    CondLoop.AddSupplyComponent(GSHX);
    Sol := T_EP_SolarCollector.Create;
    PlantLoop.AddDemandComponent(Sol); }
  slZones.Free;
end;

procedure ProcessZoneProcessLoadInfo(aNode:TXmlNode; zone:T_EP_Zone; var SWHComponents:TObjectList;
  var RefCaseComponents: TObjectList; var RefWalkinComponents: TObjectList);
var
  i: Integer;
  CaseID: integer;
  WalkinID: integer;
  childNode: TXmlNode;
  k: Integer;
  grandChildNode: TXmlNode;
  WaterSysComponent: THVACComponent;
  Component: THVACComponent;
  l: Integer;
  GreatGrandChildNode: TXmlNode;
  m: Integer;
  hvacComponent: THVACComponent;
  WaterUseObj: T_EP_WaterUse;
  Great2GrandChildNode: txmlNode;
begin
  CaseID := 1;
  WalkinID := 1;
  if aNode.NodeCount > 0 then
  begin
    for i := 0 to aNode.NodeCount - 1 do
    begin
      childNode := aNode.Nodes[i];
      //now do process loads
      if ChildNode.Name = 'ProcessLoads' then
      begin
        if ChildNode.NodeCount > 0 then
        begin
          for k := 0 to ChildNode.NodeCount - 1 do
          begin
            grandChildNode := ChildNode.Nodes[k];
            if GrandChildNode.Name = 'WaterSystems' then
            begin
              // '/HPBParametization/HVACSystem/DetailedHVAC/Zone/ProcessLoads');
              WaterSysComponent := T_EP_WaterSystems.Create;
              if GrandChildNode.NodeCount > 0 then
              begin
                for l := 0 to GrandChildNode.NodeCount - 1 do
                begin
                  GreatGrandChildNode := GrandChildNode.Nodes[l];
                  if GreatGrandChildNode.Name = 'Uses' then
                  begin
                    hvacComponent := T_EP_WaterUseConnection.Create;
                    Zone.AddProcessLoad(hvacComponent);
                    SWHComponents.Add(hvacComponent);
                    //WaterSysComponent.UseConnection :=  T_EP_WaterUseConnection(component);
                    WaterUseObj := T_EP_WaterUse.Create;
                    T_EP_WaterUseConnection(hvacComponent).WaterUseObject := WaterUseObj;
                    WaterUseObj.ZoneObj := Zone;
                    for m := 0 to GreatGrandChildNode.NodeCount - 1 do
                    begin
                      Great2GrandChildNode := GreatGrandChildNode.Nodes[m];
                      if (Great2GrandChildNode.Name = 'PerType') then
                      begin
                        WaterUseObj.Typ := StringValueFromPath(GreatGrandChildNode, 'PerType');
                      end
                      else if Great2GrandChildNode.Name = 'UseRatePer' then
                      begin
                        WaterUseObj.InputUseRatePer := FloatValueFromPath(GreatGrandChildNode, 'UseRatePer');
                      end
                      else if Great2GrandChildNode.Name = 'TemperatureTarget' then
                      begin
                        WaterUseObj.TargetTemperature := FloatValueFromPath(GreatGrandChildNode, 'TemperatureTarget');
                      end
                      else if Great2GrandChildNode.Name = 'SupplyTemp' then
                      begin
                        WaterUseObj.HotServiceTargetTemp := FloatValueFromPath(GreatGrandChildNode, 'SupplyTemp');
                      end
                      else if Great2GrandChildNode.Name = 'ScheduleName' then
                      begin
                        WaterUseObj.FlowSchedule := StringValueFromPath(GreatGrandChildNode, 'ScheduleName');
                      end
                      else if Great2GrandChildNode.Name = 'StorageRequiredPer' then
                      begin
                        WaterUseObj.InputStorageRequiredPer := FloatValueFromPath(GreatGrandChildNode, 'StorageRequiredPer');
                      end
                      else if Great2GrandChildNode.Name = 'MaxDemandPer' then
                      begin
                        WaterUseObj.InputMaxDemandPer := FloatValueFromPath(GreatGrandChildNode, 'MaxDemandPer');
                      end
                      else if Great2GrandChildNode.Name = 'SubCategory' then
                      begin
                        WaterUseObj.SubCategory := StringValueFromPath(GreatGrandChildNode, 'SubCategory', False);
                      end
                      else if Great2GrandChildNode.Name = 'RecoveryRatePer' then
                      begin
                        WaterUseObj.InputRecoveryRatePer := FloatValueFromPath(GreatGrandChildNode, 'RecoveryRatePer');
                      end
                      else if Great2GrandChildNode.NAme = 'DrainHeatRecovery' then
                      begin
                        // not yet
                        writeln('DrainHeatRecovery not yet implemented');
                      end
                      else if Great2GrandChildNode.NAme = 'LatentFraction' then
                      begin
                        WaterUseObj.LatentFraction := FloatValueFromPath(GreatGrandChildNode, 'LatentFraction');
                      end
                      else if Great2GrandChildNode.NAme = 'SensibleFraction' then
                      begin
                        WaterUseObj.SensibleFraction := FloatValueFromPath(GreatGrandChildNode, 'SensibleFraction');
                      end
                      else
                      begin
                        //do nothing
                      end;
                    end; // for m loop
                  end
                  else
                  begin
                    // throw error
                  end;
                end;
              end;
            end
            else if GrandChildNode.Name = 'RefrigeratedCases' then
            begin
             Component := T_EP_RefrigeratedCase.Create;
             Zone.AddProcessLoad(Component);
             RefCaseComponents.Add(Component);
             T_EP_RefrigeratedCase(Component).CaseID := CaseID;
             T_EP_RefrigeratedCase(Component).CaseType := StringValueFromPath(GrandChildNode, 'CaseType', False, 'NotSet');
             T_EP_RefrigeratedCase(Component).DataSetKey := StringValueFromPath(GrandChildNode, 'DataSetKey', False, 'NotSet');
             T_EP_RefrigeratedCase(Component).CompressorRackName := StringValueFromPath(GrandChildNode, 'NameOfCompressorRack', False, 'NotSet');
             T_EP_RefrigeratedCase(Component).RefrigSystemName := StringValueFromPath(GrandChildNode, 'NameOfRefrigerationSystem', False, 'NotSet');
             T_EP_RefrigeratedCase(Component).CaseLength := FloatValueFromPath(GrandChildNode, 'Length', -9999.0);
             T_EP_RefrigeratedCase(Component).CoolingCapPerLength := FloatValueFromPath(GrandChildNode, 'CoolingCapacityPerLength', -9999.0);
             T_EP_RefrigeratedCase(Component).OperatingTemp := FloatValueFromPath(GrandChildNode, 'OperatingTemperature', -9999.0);
             T_EP_RefrigeratedCase(Component).CaseFanPowerPerLength := FloatValueFromPath(GrandChildNode, 'FanPowerPerLength', -9999.0);
             T_EP_RefrigeratedCase(Component).OperatingCaseFanPowerPerLength := FloatValueFromPath(GrandChildNode, 'OperatingFanPowerPerLength', -9999.0);
             T_EP_RefrigeratedCase(Component).CaseLightingPowerPerLength := FloatValueFromPath(GrandChildNode, 'LightingPowerPerLength', -9999.0);
             T_EP_RefrigeratedCase(Component).InstalledLightingPowerPerLength := FloatValueFromPath(GrandChildNode, 'InstalledLightingPowerPerLength', -9999.0);
             T_EP_RefrigeratedCase(Component).CaseLightingSchedule := StringValueFromPath(GrandChildNode, 'LightingScheduleName', False, 'NotSet');
             T_EP_RefrigeratedCase(Component).FractionLightsToCase := FloatValueFromPath(GrandChildNode, 'FractionLightsToCase', -9999.0);
             T_EP_RefrigeratedCase(Component).AntiSweatHeaterPowerPerLength := FloatValueFromPath(GrandChildNode, 'AntiSweatHeaterPowerPerLength', -9999.0);
             T_EP_RefrigeratedCase(Component).AntiSweatHeaterControlType := StringValueFromPath(GrandChildNode, 'AntiSweatHeaterControlType', False, 'NotSet');
             T_EP_RefrigeratedCase(Component).DefrostPowerPerLength := FloatValueFromPath(GrandChildNode, 'DefrostPowerPerLength', -9999.0);
             T_EP_RefrigeratedCase(Component).DefrostType := StringValueFromPath(GrandChildNode, 'DefrostType', False, 'NotSet');
             T_EP_RefrigeratedCase(Component).DefrostSchedule := StringValueFromPath(GrandChildNode, 'DefrostScheduleName', False, 'NotSet');
             T_EP_RefrigeratedCase(Component).DefrostDripDownSchedule := StringValueFromPath(GrandChildNode, 'DefrostDripDownScheduleName', False, 'NotSet');
             T_EP_RefrigeratedCase(Component).DefrostEnergyCorrectionCurveType := StringValueFromPath(GrandChildNode, 'DefrostEnergyCorrectionCurveType', False, 'NotSet');
             T_EP_RefrigeratedCase(Component).DefrostEnergyCorrectionCurveName := StringValueFromPath(GrandChildNode, 'DefrostEnergyCorrectionCurveName', False, 'NotSet');
             T_EP_RefrigeratedCase(Component).RestockSchedule := StringValueFromPath(GrandChildNode, 'RestockScheduleName', False, 'NotSet');
             T_EP_RefrigeratedCase(Component).CaseCreditSchedule := StringValueFromPath(GrandChildNode, 'CaseCreditSchedule', False, 'NotSet');
             inc(CaseID);
            end
            else if GrandChildNode.Name = 'RefrigeratedWalkins' then
            begin
             Component := T_EP_RefrigeratedWalkin.Create;
             Zone.AddProcessLoad(Component);
             RefWalkinComponents.Add(Component);
             T_EP_RefrigeratedWalkin(Component).WalkinID := WalkinID;
             T_EP_RefrigeratedWalkin(Component).DataSetKey := StringValueFromPath(GrandChildNode, 'DataSetKey', False, 'NotSet');
             T_EP_RefrigeratedWalkin(Component).CompressorRackName := StringValueFromPath(GrandChildNode, 'NameOfCompressorRack', False, 'NotSet');
             T_EP_RefrigeratedWalkin(Component).RefrigSystemName := StringValueFromPath(GrandChildNode, 'NameOfRefrigerationSystem', False, 'NotSet');
             T_EP_RefrigeratedWalkin(Component).CoolingCapacity := FloatValueFromPath(GrandChildNode, 'CoolingCapacityPerLength', -9999.0);
             T_EP_RefrigeratedWalkin(Component).OperatingTemp := FloatValueFromPath(GrandChildNode, 'OperatingTemp', -9999.0);
             T_EP_RefrigeratedWalkin(Component).SourceTemp := FloatValueFromPath(GrandChildNode, 'SourceTemp', -9999.0);
             T_EP_RefrigeratedWalkin(Component).HeatingPower := FloatValueFromPath(GrandChildNode, 'HeatingPower', -9999.0);
             T_EP_RefrigeratedWalkin(Component).HeatingPowerSchedule := StringValueFromPath(GrandChildNode, 'HeatingPowerSchedule', False, 'NotSet');
             T_EP_RefrigeratedWalkin(Component).CoolingCoilFanPower := FloatValueFromPath(GrandChildNode, 'CoolingCoilFanPower', -9999.0);
             T_EP_RefrigeratedWalkin(Component).LightingPower := FloatValueFromPath(GrandChildNode, 'LightingPower', -9999.0);
             T_EP_RefrigeratedWalkin(Component).LightingSchedule := StringValueFromPath(GrandChildNode, 'LightingSchedule', False, 'NotSet');
             T_EP_RefrigeratedWalkin(Component).DefrostType := StringValueFromPath(GrandChildNode, 'DefrostType', False, 'NotSet');
             T_EP_RefrigeratedWalkin(Component).DefrostControlType := StringValueFromPath(GrandChildNode, 'DefrostControlType', False, 'NotSet');
             T_EP_RefrigeratedWalkin(Component).DefrostSchedule := StringValueFromPath(GrandChildNode, 'DefrostSchedule', False, 'NotSet');
             T_EP_RefrigeratedWalkin(Component).DefrostDripDownSchedule := StringValueFromPath(GrandChildNode, 'DefrostDripDownSchedule', False, 'NotSet');
             T_EP_RefrigeratedWalkin(Component).DefrostPower := FloatValueFromPath(GrandChildNode, 'DefrostPower', -9999.0);
             T_EP_RefrigeratedWalkin(Component).RestockSchedule := StringValueFromPath(GrandChildNode, 'RestockSchedule', False, 'NotSet');
             T_EP_RefrigeratedWalkin(Component).FloorSurfaceArea := FloatValueFromPath(GrandChildNode, 'FloorSurfaceArea', -9999.0);
             T_EP_RefrigeratedWalkin(Component).SurfaceAreaFacingZone := FloatValueFromPath(GrandChildNode, 'SurfaceAreaFacingZone', -9999.0);
             T_EP_RefrigeratedWalkin(Component).ReachInDoorSchedule := StringValueFromPath(GrandChildNode, 'ReachInDoorSchedule', False, 'NotSet');
             T_EP_RefrigeratedWalkin(Component).StockingDoorSchedule := StringValueFromPath(GrandChildNode, 'StockingDoorSchedule', False, 'NotSet');
             inc(WalkinID);
            end
            else
            begin
              //do nothing
            end; //   if .. else if block
          end; // for
        end; //if node count >0
      end
      else
      begin
        // throw error
      end;
    end; // for over nodes
  end; //if nodecount > 0
  Zone.ZoneProcessLoadInfoProcessed := true;
end;

function HVACAirSystemName(RootNode: TXmlNode; ZoneEndEquipmentNode: TXmlNode) : string;
// ksb: this function returns the name of an air system to be associated with an airEndUse component
var
  ChildNode: TXmlNode;
  HVACSystemsNode: TXmlNode;
  m: integer;
begin
  HVACSystemsNode := RootNode.FindNode('/HPBParametization/HVACSystem/DetailedHVAC/Systems/HVACSystems');
  // ksb: if zone equipment is assigned an AirSystemName, then make sure the
  // ksb: named system is defined and return the name in a character string
  if Assigned(ZoneEndEquipmentNode.FindNode('AirSystemName')) then
  begin
    for m := 0 to HVACSystemsNode.NodeCount - 1 do
    begin
      ChildNode := HVACSystemsNode.Nodes[m];
      if ChildNode.Name = 'AirSystem' then
      begin
        if StringValueFromPath(ZoneEndEquipmentNode, 'AirSystemName') =
           StringValueFromPath(ChildNode, 'Name') then
        begin
          result := StringValueFromPath(ZoneEndEquipmentNode, 'AirSystemName');
          Exit;
        end;
      end;
    end;
    // ksb: if we are at this point the AirSystemName given for the zone is not defined in the systems
    // ksb: return an error
    writeln('zone AirSystem name is not defined in the HVAC systems');
    RunError;
  end
  else
  // ksb: if zone equipment is not assigned an AirSystemName then return the first AirSystem
  // ksb: this is used for backward compatibility
  begin
    for m := 0 to HVACSystemsNode.NodeCount - 1 do
    begin
      ChildNode := HVACSystemsNode.Nodes[m];
      if ChildNode.Name = 'AirSystem' then
      begin
        result := StringValueFromPath(ChildNode, 'Name');
        Exit;
      end;
    end;
  end;
end;

end.
