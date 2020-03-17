////////////////////////////////////////////////////////////////////////////////
//                                                                            //
// Copyright (c) 2008-2020 Alliance for Sustainable Energy.                   //
// All rights reserved.                                                       //
//                                                                            // 
////////////////////////////////////////////////////////////////////////////////

unit EnergyPlusConstructions;

interface

uses
  SysUtils,
  Contnrs,
  classes,
  EnergyPlusCore,
  EnergyPlusEconomics,
  NativeXML;

type
  //TGasType = (gtAir, gtArgon, gtKrypton, gtXenon);
  //TRoughnessType = (rtSmooth, rtMediumSmooth, rtMediumRough, rtRough, mtVeryRough);
  TMaterialType = (mtWindowGas, mtWindowGlass, mtRegular, mtRegular_R, mtAir, mtSimpleWindow, mtWindowShade);
  //TConstructionType = (ctRoof, ctIntWalls, ctExtWalls, ctExtSlab, ctFenSouth, ctFenNorth, ctFenEast, ctFenWest, ctFenSkylight);

  T_LowTemperatureRadiantProperties = class(TObject)
  public
    SourcePresentAfterLayerNumber: integer;
    TempCalcAfterLayerNumber: integer;
    DimensionsForCTFCalculation: integer;
    TubeSpacing: double;
    constructor Create; reintroduce;
  end;

  T_EP_WindowShade = class(TObject)
  public
    Typ: string;
    ControlType: string;
    Setpoint: double;
    ShadingIsScheduled: boolean;
    ScheduleName: string;
    GlareControl: boolean;
    MaterialName: string;
    SlatAngleControl: string;
    SlatAngleSchedule: string;
    constructor Create; reintroduce;
  end;

  T_EP_Material_WindowGas = class(TEnergyPlusGroup)
  public
    GasType: string;
    Thickness: double;
    constructor Create; reintroduce;
    procedure Finalize; override;
    procedure ToIDF; override;
  end;

  T_EP_Material_WindowGlass = class(TEnergyPlusGroup)
  public
    Conductivity: double;
    IREmmBack: double;
    IREmmFront: double;
    IRTrans: double;
    SolarReflectBack: double;
    SolarReflectFront: double;
    SolarTrans: double;
    Thickness: double;
    VisibleReflectBack: double;
    VisibleReflectFront: double;
    VisibleTrans: double;
    constructor Create; reintroduce;
    procedure Finalize; override;
    procedure ToIDF; override;
  end;

  T_EP_Material_WindowShade = class(TEnergyPlusGroup)
  public
    SolarTrans: double;
    SolarReflect: double;
    VisibleTrans: double;
    VisibleReflect: double;
    IREmm: double;
    IRTrans: double;
    Thickness: double;
    Conductivity: double;
    ShadeToGlassDistance: double;
    TopOpenMult: double;
    BottomOpenMult: double;
    LeftOpenMult: double;
    RightOpenMult: double;
    AirPermeability: double;
    constructor Create; reintroduce;
    procedure Finalize; override;
    procedure ToIDF; override;
  end;

  T_EP_Material_SimpleWindow = class(TEnergyPlusGroup)
  public
    UValue: double;
    SHGC: double;
    VT: double;
    constructor Create; reintroduce;
    procedure Finalize; override;
    procedure ToIDF; override;
  end;

  T_EP_Material_Regular = class(TEnergyPlusGroup)
  public
    AbsorSolar: double;
    AbsorThermal: double;
    AbsorVis: double;
    Conductivity: double;
    Density: double;
    Roughness: string;
    SpecificHeat: double;
    Thickness: double;
    procedure ToIDF; override;
    constructor Create; reintroduce;
    procedure Finalize; override;
  end;

  T_EP_Material_Regular_R = class(TEnergyPlusGroup)
  public
    AbsorSolar: double;
    AbsorThermal: double;
    AbsorVis: double;
    Roughness: string;
    ThermalRes: double;
    procedure ToIDF; override;
    constructor Create; reintroduce;
    procedure Finalize; override;
  end;

  T_EP_Material_Air = class(TEnergyPlusGroup)
  public
    ThermalRes: double;
    procedure ToIDF; override;
    constructor Create; reintroduce;
    procedure Finalize; override;
  end;

  T_EP_Construction = class(TEnergyPlusGroup)
  public
    Cost: T_EP_Economics;
    Facade: string;  //the same construction can be valid for only one facade --
    HighAlbedo: boolean;
    InfiltrationPerArea: Double;
    Layers: TObjectList;
    SwitchableGlazing: boolean;
    SwitchableGlazingControlMode: string;
    WindowShaded: boolean;
    WindowShade: T_EP_WindowShade;
    LowTemperatureRadiantProperties: T_LowTemperatureRadiantProperties;
    Typ: string;
    constructor Create; reintroduce;
    destructor Destroy; override;
    procedure AddCost(CostPer: double; Facade:String);
    procedure AddLayers(aNode: TxmlNode);
    procedure CheckElectrochromic(aNode: TXmlNode);
    procedure CheckShadingControl(aNode: TXmlNode);
    procedure Finalize; override;
    procedure ToIDF; override;
  end;

  T_EP_Constructions = class(TObjectList)
  public
    ExternalConstructionFile: TStringList;
    StaticLibrary: TStringList;
    UseExternalFileForConstructions: Boolean;
    constructor Create; reintroduce;
    function AddToBldgConstructions(ConstName: string; Facade:String; var AConstruction:T_EP_Construction): boolean;
    function GetConstruction(ConstructionName: string): T_EP_Construction; overload;
    function GetConstruction(Typ, Facade: string): T_EP_Construction; overload;
    function GetIndex(Typ, Facade: string): Integer;
  end;

procedure ReadMaterialStruct(var inMatReg: T_EP_Material_Regular; Child_Node: TXmlNode);
procedure ReadMaterial_AirStruct(var inMat_Air: T_EP_Material_Air; Child_Node: TXmlNode);
procedure ReadMaterial_RStruct(var inMat_R: T_EP_Material_Regular_R; Child_Node: TXmlNode);
procedure ReadWindowGasStruct(var inWindow_Gas: T_EP_Material_WindowGas; Child_Node: TXmlNode);
procedure ReadWindowGlassStruct(var inWindow_Glass: T_EP_Material_WindowGlass; Child_Node: TXmlNode);
procedure ReadWindowShadeStruct(var inWindow_Shade: T_EP_Material_WindowShade; Child_Node: TXmlNode);
procedure ReadSimpleWindowStruct(var inWindow_SimpleSystem: T_EP_Material_SimpleWindow; Child_Node: TXmlNode);

implementation

uses XMLproc, Globals, GlobalFuncs, xmlProcessing, EnergyPlusPPErrorMessages, EnergyPlusObject, EnergyPlusSettings;

constructor T_EP_Construction.Create;
begin
  inherited;
  Layers := TObjectList.Create;
  LowTemperatureRadiantProperties := T_LowTemperatureRadiantProperties.Create;
  WindowShade := T_EP_WindowShade.Create;
  SwitchableGlazingControlMode := 'MeetDaylightIlluminanceSetpoint';
  SwitchableGlazing := False;
  WindowShaded := False;
end;

destructor T_EP_Construction.Destroy;
begin
  LowTemperatureRadiantProperties.Free;
  WindowShade.Free;
  inherited;
end;

{ T_EP_Construction }

procedure T_EP_Construction.AddCost(CostPer: double; Facade:String);
begin
  //there can only be one cost element per facade
  if not Assigned(Cost) then
  begin
    Cost := T_EP_Economics.Create;
    Cost.Name := Facade + ':' + Name;
    Cost.RefObjName := Name;
    Cost.Costing := ecCostPerArea;
    Cost.CostType := etConstruction;
    Cost.CostValue := CostPer;
  end;
end;

procedure T_EP_Construction.AddLayers(aNode: TxmlNode);
var
  i: integer;
  bFound: boolean;
  matName: string;
  childNode: TXMLnode;
  matType: TMaterialType;
  iMat: Integer;
  currentMatReg: T_EP_Material_Regular;
  currentMatR: T_EP_Material_Regular_R;
  currentMatAir: T_EP_Material_Air;
  currentWinGas: T_EP_Material_WindowGas;
  currentWinGlass: T_EP_Material_WindowGlass;
  currentWinShade: T_EP_Material_WindowShade;
  currentSimpleWindow: T_EP_Material_SimpleWindow;
begin
  //get material name
  for i := 0 to aNode.NodeCount - 1 do
  begin
    //find nodes
    if (aNode.nodes[i].Name <> 'ConstructionName') and
      (aNode.nodes[i].Name <> 'Performance') and
      (aNode.nodes[i].Name <> 'SwitchableGlazing') and
      (aNode.nodes[i].Name <> 'SwitchableGlazingControlMode') and
      (aNode.Nodes[i].Name <> 'ShadingControl') and
      (aNode.Nodes[i].Name <> 'HighAlbedo') then
    begin
      matName := StringValueFromAttribute(aNode.Nodes[i], 'MaterialName');
      childNode := aNode.Nodes[i];
      if childNode.Name = 'Material' then
        matType := mtRegular
      else if childNode.Name = 'Material-R' then
        matType := mtRegular_R
      else if childNode.Name = 'Material-Air' then
        matType := mtAir
      else if childNode.Name = 'WindowGlass' then
        matType := mtWindowGlass
      else if childNode.Name = 'WindowGas' then
        matType := mtWindowGas
      else if childNode.Name = 'WindowShade' then
        matType := mtWindowShade
      else if childNode.Name = 'SimpleGlazingSystem' then
      begin
        matType := mtSimpleWindow;
        matName := StringValueFromPath(aNode.Nodes[i], 'Name');
      end;
      //check if name exists and if so add to master materials list
      bFound := false;
      for iMat := 0 to Materials.Count - 1 do
      begin
        if TEnergyPlusGroup(Materials[iMat]).Name = MatName then
        begin
          //material already exists
          bFound := true;
          //don't add to layer if it is a window shade
          if matType <> mtWindowShade then
            Layers.Add(TEnergyPlusGroup(Materials[iMat]));
          break;
        end;
      end;
      if not bFound then
      begin
        if MatType = mtRegular then
        begin
          currentMatReg := T_EP_Material_Regular.Create;
          currentMatReg.Name := matName;
          ReadMaterialStruct(currentMatReg, childNode);
          Layers.Add(currentMatReg);
          Materials.Add(currentMatReg);
        end
        else if matType = mtRegular_R then
        begin
          currentMatR := T_EP_Material_Regular_R.Create;
          currentMatR.Name := matName;
          ReadMaterial_RStruct(currentMatR, childNode);
          Layers.Add(currentMatR);
          Materials.Add(currentMatR);
        end
        else if matType = mtAir then
        begin
          currentMatAir := T_EP_Material_Air.Create;
          currentMatAir.Name := matName;
          ReadMaterial_AirStruct(currentMatAir, childNode);
          Layers.Add(currentMatAir);
          Materials.Add(currentMatAir);
        end
        else if matType = mtWindowGas then
        begin
          currentWinGas := T_EP_Material_WindowGas.Create;
          currentWinGas.Name := matName;
          ReadWindowGasStruct(currentWinGas, childNode);
          Layers.Add(currentWinGas);
          Materials.Add(currentWinGas);
        end
        else if matType = mtWindowGlass then
        begin
          currentWinGlass := T_EP_Material_WindowGlass.Create;
          currentWinGlass.Name := matName;
          ReadWindowGlassStruct(currentWinGlass, childNode);
          Layers.Add(currentWinGlass);
          Materials.Add(currentWinGlass);
        end
        else if matType = mtWindowShade then
        begin
          currentWinShade :=T_EP_Material_WindowShade.Create;
          currentWinShade.Name := matName;
          ReadWindowShadeStruct(currentWinShade, ChildNode);
          Materials.Add(currentWinShade);          
        end
        else if matType = mtSimpleWindow then
        begin
          currentSimpleWindow := T_EP_Material_SimpleWindow.Create;
          currentSimpleWindow.Name :=  matName;
          ReadSimpleWindowStruct(currentSimpleWindow, childNode);
          Layers.Add(currentSimpleWindow);
          Materials.Add(currentSimpleWindow);
        end;
      end;
    end; //if not construction name
  end;
end;

procedure T_EP_Construction.CheckElectrochromic(aNode: TxmlNode);
var
  i: integer;
begin
  for i := 0 to aNode.NodeCount - 1 do
  begin
    if (aNode.nodes[i].Name = 'SwitchableGlazing') then
    begin
      SwitchableGlazing := BooleanValueFromPath(aNode, 'SwitchableGlazing');
    end;
    if (aNode.Nodes[i].Name = 'SwitchableGlazingControlMode') then
    begin
      SwitchableGlazingControlMode := StringValueFromPath(aNode, 'SwitchableGlazingControlMode');
    end;
  end;
end;

procedure T_EP_Construction.CheckShadingControl(aNode: TxmlNode);
var
  i: integer;
begin
  for i := 0 to aNode.NodeCount - 1 do
  begin
    if (aNode.nodes[i].Name = 'ShadingControl') then
    begin
      WindowShaded := True;
    end;
  end;
end;

procedure T_EP_Construction.Finalize;
var
  MatName: string;
  iMat: Integer;
begin
  inherited;
  //todo: copy material and create a new one... then manipulate
  if HighAlbedo then
  begin
    //find the material and adjust the thermal properties
    MatName := TEnergyPlusGroup(Layers[0]).Name;
    for iMat := 0 to Materials.Count - 1 do
    begin
      if TEnergyPlusGroup(Materials[iMat]).Name = MatName then
      begin
        //material already exists
        //thermal absorbtivity is equal to thermal emmissivity (Kirchoff's Law)
        //T_EP_Material_Regular(Materials[iMat]).AbsorThermal := 0.3;
        T_EP_Material_Regular(Materials[iMat]).AbsorSolar := 0.3;
        T_EP_Material_Regular(Materials[iMat]).AbsorVis := 0.3;
        break;
      end;
    end;
  end;
end;

procedure T_EP_Construction.ToIDF;
var
  i: integer;
  Obj: TEnergyPlusObject;
begin
  if not BldgConstructions.UseExternalFileForConstructions then
  begin
    if (LowTemperatureRadiantProperties.SourcePresentAfterLayerNumber > 0) then
    begin
      Obj := IDF.AddObject('Construction:InternalSource');
      Obj.AddField('Name', Name);
      Obj.AddField('Source Present After Layer Number', LowTemperatureRadiantProperties.SourcePresentAfterLayerNumber);
      Obj.AddField('Temperature Calculation Requested After Layer Number', LowTemperatureRadiantProperties.TempCalcAfterLayerNumber);
      Obj.AddField('Dimensions for the CTF Calculation', LowTemperatureRadiantProperties.DimensionsForCTFCalculation);
      Obj.AddField('Tube Spacing', LowTemperatureRadiantProperties.TubeSpacing);
    end
    else
    begin
      Obj := IDF.AddObject('Construction');
      Obj.AddField('Name', Name);
    end;
    // add all the layers
    for i := 0 to Layers.Count - 1 do
    begin
      Obj.AddField('Layer ' + IntToStr(i + 1), TEnergyPlusGroup(Layers[i]).Name);
    end;
    if Assigned(Cost) and EPSettings.Costs then Cost.ToIDF;
    if WindowShade.Typ <> '' then
    begin
      Obj := IDF.AddObject('WindowProperty:ShadingControl');
      Obj.AddField('Name', Name + '_WindowShade');
      Obj.AddField('Shading Type', WindowShade.Typ);
      Obj.AddField('Construction with Shading Name', '');
      Obj.AddField('Shading Control Type', WindowShade.ControlType);
      Obj.AddField('Schedule Name', WindowShade.ScheduleName);
      if WindowShade.Setpoint <> -9999.0 then
        Obj.AddField('Setpoint {W/m2, W, or deg C}', WindowShade.Setpoint)
      else
        Obj.AddField('Setpoint {W/m2, W, or deg C}', '');
      if WindowShade.ShadingIsScheduled then
        Obj.AddField('Shading Control Is Scheduled', 'Yes')
      else
        Obj.AddField('Shading Control Is Scheduled', 'No');
      if WindowShade.GlareControl then
        Obj.AddField('Glare Control Is Active', 'Yes')
      else
        Obj.AddField('Glare Control Is Active', 'No');
      Obj.AddField('Shading Device Material Name', WindowShade.MaterialName);
      Obj.AddField('Type of Slat Angle Control for Blinds', WindowShade.SlatAngleControl);
      Obj.AddField('Slat Angle Schedule Name', WindowShade.SlatAngleSchedule);
    end;
    if SwitchableGlazing then
    begin
      // assume electrochromic  need shading control and dark construction
      Obj := IDF.AddObject('WindowProperty:ShadingControl');
      Obj.AddField('Name', name + '_ECcontrol');
      Obj.AddField('Shading Type', 'SwitchableGlazing');
      Obj.AddField('Construction with Shading Name', name + '_Dark');
      Obj.AddField('Shading Control Type', SwitchableGlazingControlMode);
      Obj.AddField('Schedule Name', 'ALWAYS_ON');
      Obj.AddField('Setpoint', 10.0, '{W/m2}');
      obj.AddField('Shading Control is Scheduled', 'No');
      Obj.AddField('Glare Control Is Active', 'No');
      Obj.AddField('Shading Device Material Name', '');
      Obj.AddField('Type of Slat Angle Control for Blinds', '');

      Obj := IDF.AddObject('Construction');
      Obj.AddField('Name', name + '_Dark');
      Obj.AddField('Layer 1', name + '_Dark_1');
      Obj.AddField('Layer 2', 'XENON 9MM');
      Obj.AddField('Layer 3', name + '_Dark_2');
      Obj.AddField('Layer 4', 'ARGON  13MM');
      Obj.AddField('Layer 5', name + '_Dark_3');

      Obj := IDF.AddObject('WindowMaterial:Glazing');
      Obj.AddField('Name', name + '_Dark_1');
      Obj.AddField('Optical Data Type', 'SpectralAverage');
      Obj.AddField('Window Glass Spectral Data Set Name', '');
      Obj.AddField('Thickness', 0.003048);
      Obj.AddField('Solar Transmittance at Normal Incidence', 0.06);
      Obj.AddField('Front Side Solar Reflectance at Normal Incidence', 0.800);
      Obj.AddField('Back Side Solar Reflectance at Normal Incidence', 0.800);
      Obj.AddField('Visible Transmittance at Normal Incidence', 0.022);
      Obj.AddField('Front Side Visible Reflectance at Normal Incidence', 0.800);
      Obj.AddField('Back Side Visible Reflectance at Normal Incidence', 0.800);
      Obj.AddField('Infrared Transmittance at Normal Incidence', 0.0000);
      Obj.AddField('Front Side Infrared Hemispherical Emissivity', 0.840);
      Obj.AddField('Back Side Infrared Hemispherical Emissivity', 0.0100);
      Obj.AddField('Conductivity', 0.900);

      Obj := IDF.AddObject('WindowMaterial:Glazing');
      Obj.AddField('Name', name + '_Dark_2');
      Obj.AddField('Optical Data Type', 'SpectralAverage');
      Obj.AddField('Window Glass Spectral Data Set Name', '');
      Obj.AddField('Thickness', 0.003048);
      Obj.AddField('Solar Transmittance at Normal Incidence', 0.834);
      Obj.AddField('Front Side Solar Reflectance at Normal Incidence', 0.0750);
      Obj.AddField('Back Side Solar Reflectance at Normal Incidence', 0.0750);
      Obj.AddField('Visible Transmittance at Normal Incidence', 0.899);
      Obj.AddField('Front Side Visible Reflectance at Normal Incidence', 0.083);
      Obj.AddField('Back Side Visible Reflectance at Normal Incidence', 0.083);
      Obj.AddField('Infrared Transmittance at Normal Incidence', 0.0000);
      Obj.AddField('Front Side Infrared Hemispherical Emissivity', 0.840);
      Obj.AddField('Back Side Infrared Hemispherical Emissivity', 0.8400);
      Obj.AddField('Conductivity', 1.000);

      Obj := IDF.AddObject('WindowMaterial:Glazing');
      Obj.AddField('Name', name + '_Dark_3');
      Obj.AddField('Optical Data Type', 'SpectralAverage');
      Obj.AddField('Window Glass Spectral Data Set Name', '');
      Obj.AddField('Thickness', 0.003048);
      Obj.AddField('Solar Transmittance at Normal Incidence', 0.800);
      Obj.AddField('Front Side Solar Reflectance at Normal Incidence', 0.080);
      Obj.AddField('Back Side Solar Reflectance at Normal Incidence', 0.080);
      Obj.AddField('Visible Transmittance at Normal Incidence', 0.900);
      Obj.AddField('Front Side Visible Reflectance at Normal Incidence', 0.080);
      Obj.AddField('Back Side Visible Reflectance at Normal Incidence', 0.080);
      Obj.AddField('Infrared Transmittance at Normal Incidence', 0.0000);
      Obj.AddField('Front Side Infrared Hemispherical Emissivity', 0.010);
      Obj.AddField('Back Side Infrared Hemispherical Emissivity', 0.8400);
      Obj.AddField('Conductivity', 0.900);
    end;
  end;
end;

{ T_EP_Constructions }

constructor T_EP_Constructions.Create;
begin
  inherited;
  UseExternalFileForConstructions := false;
  StaticLibrary := TSTringList.Create;
  ExternalConstructionFile := TStringList.Create;
end;

function T_EP_Constructions.AddToBldgConstructions(ConstName: string; Facade:String; var AConstruction:T_EP_Construction): boolean;
//returns true if the construction is a new construction -- returns false if not
//both the constname and the facade have to be unique -- if the facade does not exist, then it will not be used.
var
  i: Integer;
  bFound: Boolean;
  bRename: Boolean;
begin
  bFound := False;
  bRename := false;
  //check if construction name already exists
  for i := 0 to BldgConstructions.Count - 1 do
  begin
    AConstruction := T_EP_Construction(BldgConstructions[i]);
    if (SameText(ConstName, AConstruction.Name)) then
    begin
      if SameText(Facade, AConstruction.Facade) then
      begin
        bFound := true;
      end
      else
      begin
        writeln('Same construction found for multiple facades, renaming construction');
        bRename := true;
        bFound := false;
      end;
      break;
    end;
  end; //for i
  if not bFound then
  begin
    AConstruction := T_EP_Construction.Create;
    if bRename then
      AConstruction.Name := ConstName + '_' + Facade
    else
      AConstruction.Name := ConstName;
    AConstruction.Facade := Facade;
    BldgConstructions.Add(AConstruction);
  end
  else
  begin
    T_EP_PPErrorMessage.AddErrorMessage(esWarning, 'Construction name repeated: ' + ConstName);
    //send message to EnergyPlus
  end;
  result := not bFound;
end;

function T_EP_Constructions.GetConstruction(ConstructionName: string):
  T_EP_Construction;
var
  i: Integer;
begin
  result := nil;
  for i := 0 to Count - 1 do
  begin
    if (T_EP_Construction(Items[i]).Name = ConstructionName) then
    begin
      Result := T_EP_Construction(Items[i]);
      break;
    end;
  end; //for count
end;

function T_EP_Constructions.GetConstruction(Typ, Facade: string): T_EP_Construction;
var
  i: Integer;
  bFound: Boolean;
begin
  bFound := false;
  result := nil;
  for i := 0 to Count - 1 do
  begin
    if (SameText(T_EP_Construction(Items[i]).Typ, typ)) and
       (SameText(T_EP_Construction(Items[i]).Facade, Facade)) then
    begin
      Result := T_EP_Construction(Items[i]);
      bFound := true;
      break;
    end;
  end; //for count
  if not bFound then
  begin
    result := T_EP_Construction(Items[0]);
    T_EP_PPErrorMessage.AddErrorMessage(esFatal, 'Could not find construction: ' + Typ + ' - ' + Facade);
  end;
end;

function T_EP_Constructions.GetIndex(Typ, Facade: string): Integer;
var
  i: Integer;
  iIndex: Integer;
begin
  iIndex := -1;
  for i := 0 to Count - 1 do
  begin
    if (SameText(T_EP_Construction(Items[i]).Typ, typ)) and
       (SameText(T_EP_Construction(Items[i]).Facade, Facade)) then
    begin
      iIndex := i;
      break;
    end;
  end; //for count
  result := iIndex;
end;

{ T_EP_LowTemperatureRadiantProperties }

constructor T_LowTemperatureRadiantProperties.Create;
begin
  inherited;
  SourcePresentAfterLayerNumber := -9999;
  TempCalcAfterLayerNumber := -9999;
  DimensionsForCTFCalculation := -9999;
  TubeSpacing := -9999;
end;

{ T_EP_WindowShade}

constructor T_EP_WindowShade.Create;
begin
  inherited;
  Typ := '';
  ControlType := '';
  Setpoint := -9999.0;
  ShadingIsScheduled := False;
  ScheduleName := '';
  GlareControl := False;
  SlatAngleControl := '';
  SlatAngleSchedule := '';
end;

{ T_EP_Material_WindowGas }

constructor T_EP_Material_WindowGas.Create;
begin
  inherited;
end;

procedure T_EP_Material_WindowGas.Finalize;
begin
  inherited;
end;

procedure T_EP_Material_WindowGas.ToIDF;
var
  Obj: TEnergyPlusObject;
begin
  Obj := IDF.AddObject('WindowMaterial:Gas');
  Obj.AddField('Name', Name);
  Obj.AddField('Gas Type', GasType);
  Obj.AddField('Thickness', Thickness);
end;

{ T_EP_Material_WindowGlass }

constructor T_EP_Material_WindowGlass.Create;
begin
  inherited;
end;

procedure T_EP_Material_WindowGlass.Finalize;
begin
  inherited;
end;

procedure T_EP_Material_WindowGlass.ToIDF;
var
  Obj: TEnergyPlusObject;
begin
  Obj := IDF.AddObject('WindowMaterial:Glazing');
  Obj.AddField('Name', Name);
  Obj.AddField('Optical Data Type', 'SpectralAverage');
  Obj.AddField('Window Glass Spectral Data Set Name', '');
  Obj.AddField('Thickness', Thickness);
  Obj.AddField('Solar Transmittance at Normal Incidence', SolarTrans);
  Obj.AddField('Front Side Solar Reflectance at Normal Incidence', SolarReflectFront);
  Obj.AddField('Back Side Solar Reflectance at Normal Incidence', SolarReflectBack);
  Obj.AddField('Visible Transmittance at Normal Incidence', VisibleTrans);
  Obj.AddField('Front Side Visible Reflectance at Normal Incidence', VisibleReflectFront);
  Obj.AddField('Back Side Visible Reflectance at Normal Incidence', VisibleReflectBack);
  Obj.AddField('Infrared Transmittance at Normal Incidence', IRTrans);
  Obj.AddField('Front Side Infrared Hemispherical Emissivity', IREmmFront);
  Obj.AddField('Back Side Infrared Hemispherical Emissivity', IREmmBack);
  Obj.AddField('Conductivity', Conductivity);
  Obj.AddField('Dirt Correction Factor for Solar and Visible Transmittance', 1.0 );
  Obj.AddField('Solar Diffusing', 'No' );
end;

{ T_EP_Material_WindowShade }

constructor T_EP_Material_WindowShade.Create;
begin
  inherited;
end;

procedure T_EP_Material_WindowShade.Finalize;
begin
  inherited;
end;

procedure T_EP_Material_WindowShade.ToIDF;
var
  Obj: TEnergyPlusObject;
begin
  Obj := IDF.AddObject('WindowMaterial:Shade');
  Obj.AddField('Name', Name);
  Obj.AddField('Solar Transmittance at Normal Incidence', SolarTrans);
  Obj.AddField('Solar Reflectance (Same For Front and Back Side)', SolarReflect);
  Obj.AddField('Visible Transmittance at Normal Incidence', VisibleTrans);
  Obj.AddField('Visible Reflectance (Same For Front and Back Side)', VisibleReflect);
  Obj.AddField('Infrared Emissivity (Same For Front and Back Side)', IREmm);
  Obj.AddField('Infrared Transmittance', IRTrans);
  Obj.AddField('Thickness {m}', Thickness);
  Obj.AddField('Conductivity {W/m-K}', Conductivity);
  Obj.AddField('Shade to Glass Distance {m}', ShadeToGlassDistance);
  Obj.AddField('Top Opening Multiplier', TopOpenMult);
  Obj.AddField('Bottom Opening Multiplier', BottomOpenMult);
  Obj.AddField('Left-Side Opening Multiplier', LeftOpenMult);
  Obj.AddField('Right-Side Opening Multiplier', RightOpenMult);
  Obj.AddField('Air-Flow Permeability', AirPermeability);
end;

{T_EP_Material_SimpleWindow }

constructor T_EP_Material_SimpleWindow.Create;
begin
  inherited;
end;

procedure T_EP_Material_SimpleWindow.Finalize;
begin
  inherited;
end;

procedure T_EP_Material_SimpleWindow.ToIDF;
var
  Obj: TEnergyPlusObject;
begin
  Obj := IDF.AddObject('WindowMaterial:SimpleGlazingSystem');
  Obj.AddField('Name', Name);
  Obj.AddField('U-Factor', UValue);
  Obj.AddField('Solar Heat Gain Coefficient', SHGC);
  if VT > 0 then
  begin
    Obj.addField('Visible Transmittance', VT)
  end;
end;

{ T_EP_Material_Regular }

constructor T_EP_Material_Regular.Create;
begin
  inherited;
end;

procedure T_EP_Material_Regular.Finalize;
begin
  inherited;
end;

procedure T_EP_Material_Regular.ToIDF;
var
  Obj: TEnergyPlusObject;
begin
  Obj := IDF.AddObject('Material');
  Obj.AddField('Name', Name);
  Obj.AddField('Roughness', Roughness);
  Obj.AddField('Thickness', Thickness);
  Obj.AddField('Conductivity', Conductivity);
  Obj.AddField('Density', Density);
  Obj.AddField('Specific Heat', SpecificHeat);
  Obj.AddField('Thermal Absorptance', AbsorThermal);
  Obj.AddField('Solar Absorptance', AbsorSolar);
  Obj.AddField('Visible Absorptance', AbsorVis);
end;

{ T_EP_Material_Regular_R }

constructor T_EP_Material_Regular_R.Create;
begin
  inherited;
end;

procedure T_EP_Material_Regular_R.Finalize;
begin
  inherited;
end;

procedure T_EP_Material_Regular_R.ToIDF;
var
  Obj: TEnergyPlusObject;
begin
  Obj := IDF.AddObject('Material:NoMass');
  Obj.AddField('Name', Name);
  Obj.AddField('Roughness', Roughness);
  Obj.AddField('Thermal Resistance', ThermalRes, '{(m2-K)/W}');
  Obj.AddField('Thermal Absorptance', AbsorThermal);
  Obj.AddField('Solar Absorptance', AbsorSolar);
  Obj.AddField('Visible Absorptance', AbsorVis);
end;

{ T_EP_Material_Air }

constructor T_EP_Material_Air.Create;
begin
  inherited;
end;

procedure T_EP_Material_Air.Finalize;
begin
  inherited;
end;

procedure T_EP_Material_Air.ToIDF;
var
  Obj: TEnergyPlusObject;
begin
  Obj := IDF.AddObject('Material:AirGap');
  Obj.AddField('Name', Name);
  Obj.AddField('Thermal Resistance', ThermalRes, '{(m2-K)/W}');
end;

procedure ReadMaterialStruct(var inMatReg: T_EP_Material_Regular;
  Child_Node: TXmlNode);
begin
  if Child_Node <> nil then
  begin
    with inMatReg do
    begin
      Roughness := StringValueFromAttribute(Child_Node, 'Roughness', False);
      Thickness := FloatValueFromAttribute(Child_Node, 'Thickness');
      Conductivity := FloatValueFromAttribute(Child_Node, 'Conductivity');
      Density := FloatValueFromAttribute(Child_Node, 'Density');
      SpecificHeat := FloatValueFromAttribute(Child_Node, 'SpecificHeat');
      AbsorThermal := FloatValueFromAttribute(Child_Node, 'AbsorThermal');
      AbsorSolar := FloatValueFromAttribute(Child_Node, 'AbsorSolar');
      AbsorVis := FloatValueFromAttribute(Child_Node, 'AbsorVis');
    end; //with
  end; //if
end; //readrealval

procedure ReadMaterial_RStruct(var inMat_R: T_EP_Material_Regular_R;
  Child_Node: TXmlNode);
begin
  if Child_Node <> nil then
  begin
    with inMat_R do
    begin
      Roughness := StringValueFromAttribute(Child_Node, 'Roughness', False);
      ThermalRes := FloatValueFromAttribute(Child_Node, 'ThermalResistance');
      AbsorThermal := FloatValueFromAttribute(Child_Node, 'AbsorThermal');
      AbsorSolar := FloatValueFromAttribute(Child_Node, 'AbsorSolar');
      AbsorVis := FloatValueFromAttribute(Child_Node, 'AbsorVis');
    end; //with
  end; //if
end; //readrealval

procedure ReadMaterial_AirStruct(var inMat_Air: T_EP_Material_Air; Child_Node: TXmlNode);
begin
  if Child_Node <> nil then
  begin
    with inMat_Air do
    begin
      ThermalRes := FloatValueFromAttribute(Child_Node, 'ThermalResistance');
    end; //with
  end; //if child
end; //readrealval


procedure ReadSimpleWindowStruct(var inWindow_SimpleSystem: T_EP_Material_SimpleWindow; Child_Node: TXmlNode);
begin
  if Child_Node <> nil then
  begin
    with inWindow_SimpleSystem do
    begin
      UValue := FloatValueFromPath(Child_Node, 'UValue');
      SHGC := FloatValueFromPath(Child_Node, 'SHGC');
      VT := FloatValueFromPath(Child_Node, 'VT');
    end; //with
  end; // if child node
end;

procedure ReadWindowGlassStruct(var inWindow_Glass: T_EP_Material_WindowGlass; Child_Node: TXmlNode);
begin
  if Child_Node <> nil then
  begin
    with inWindow_Glass do
    begin
      Thickness := FloatValueFromAttribute(Child_Node, 'Thickness');
      SolarTrans := FloatValueFromAttribute(Child_Node, 'SolarTrans');
      SolarReflectFront := FloatValueFromAttribute(Child_Node, 'SolarReflectFront');
      SolarReflectBack := FloatValueFromAttribute(Child_Node, 'SolarReflectBack');
      VisibleTrans := FloatValueFromAttribute(Child_Node, 'VisibleTrans');
      VisibleReflectFront := FloatValueFromAttribute(Child_Node, 'VisibleReflectFront');
      VisibleReflectBack := FloatValueFromAttribute(Child_Node, 'VisibleReflectBack');
      IRTrans := FloatValueFromAttribute(Child_Node, 'IRTrans');
      IREmmBack := FloatValueFromAttribute(Child_Node, 'IREmmBack');
      IREmmFront := FloatValueFromAttribute(Child_Node, 'IREmmFront');
      Conductivity := FloatValueFromAttribute(Child_Node, 'Conductivity');
    end; //with
  end; //if childnode
end; //readrealval

procedure ReadWindowShadeStruct(var inWindow_Shade: T_EP_Material_WindowShade; Child_Node: TXmlNode);
begin
  if Child_Node <> nil then
  begin
    with inWindow_Shade do
    begin
      SolarTrans := FloatValueFromAttribute(Child_Node, 'SolarTrans');
      SolarReflect := FloatValueFromAttribute(Child_Node, 'SolarReflect');
      VisibleTrans := FloatValueFromAttribute(Child_Node, 'VisibleTrans');
      VisibleReflect := FloatValueFromAttribute(Child_Node, 'VisibleReflect');
      IREmm := FloatValueFromAttribute(Child_Node, 'IREmm');
      IRTrans := FloatValueFromAttribute(Child_Node, 'IRTrans');
      Thickness := FloatValueFromAttribute(Child_Node, 'Thickness');
      Conductivity := FloatValueFromAttribute(Child_Node, 'Conductivity');
      ShadeToGlassDistance := FloatValueFromAttribute(Child_Node, 'ShadeToGlassDistance');
      TopOpenMult := FloatValueFromAttribute(Child_Node, 'TopOpenMult');
      BottomOpenMult := FloatValueFromAttribute(Child_Node, 'BottomOpenMult');
      LeftOpenMult := FloatValueFromAttribute(Child_Node, 'LeftOpenMult');
      RightOpenMult := FloatValueFromAttribute(Child_Node, 'RightOpenMult');
      AirPermeability := FloatValueFromAttribute(Child_Node, 'AirPermeability');
    end; //with
  end; //if childnode
end; //readrealval

procedure ReadWindowGasStruct(var inWindow_Gas: T_EP_Material_WindowGas; Child_Node: TXmlNode);
begin
  if Child_Node <> nil then
  begin
    with inWindow_Gas do
    begin
      Thickness := FloatValueFromAttribute(Child_Node, 'Thickness');
      GasType := StringValueFromAttribute(Child_Node, 'GasType', False);
    end; //with
  end;
end; //readrealval

end.
