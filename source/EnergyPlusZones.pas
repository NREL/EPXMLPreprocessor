////////////////////////////////////////////////////////////////////////////////
//                                                                            //
// Copyright (c) 2008-2020 Alliance for Sustainable Energy.                   //
// All rights reserved.                                                       //
//                                                                            // 
////////////////////////////////////////////////////////////////////////////////

unit EnergyPlusZones;

interface

uses
  SysUtils,
  Classes,
  Contnrs,
  Globals,
  EnergyPlusCore,
  EnergyPlusGeometry,
  EnergyPlusSurfaces,
  EnergyPlusSettings,
  EnergyPlusInternalGains,
  EnergyPlusDaylighting,
  NativeXML,
  VectorMath;

type
  T_EP_FloorInfo = class(TObject)
  private
    FFloorNumber: integer;
    FFloorType: TFloorType;
  public
    constructor Create; reintroduce;
    function FloorNumberKnown: boolean;
    property FloorNumber : integer read FFloorNumber write FFloorNumber;
    property FloorType : TFloorType read FFloorType write FFloorType;
  end;

  T_EP_LowTempRadiantSurfaceGroup = class(TEnergyPlusGroup)
  private
    FName: string;
    FSurfaces: TObjectList;
    FSurfaceArea: double;
    FTubeLength: double;
  public
    constructor Create; reintroduce;
    destructor Destroy; override;
    procedure Finalize; override;
    procedure ToIDF; override;
    procedure AddSurface(aSurface: T_EP_Surface);
    property Name : string read FName write FName;  // name of the group
    property Surfaces : TObjectList read FSurfaces; // surfaces in the group
    property SurfaceArea : double read FSurfaceArea; // total surface area (m^2)
    property TubeLength : double read FTubeLength; // total tube length (m)
  end;

  T_EP_Zone = class(TEnergyPlusGroup)
  private
    Infiltration: T_EP_Infiltration;
    InternalMass: T_EP_InternalMass;
    Daylighting: T_EP_Daylighting;
    CostItems: TObjectList;
  protected
    ProcessLoads: TObjectList;
    function CoolingMinAirFlow: double;
  public
    SpaceConditioning: TObjectList;  
    InternalGains: T_EP_ZoneGains;
    ExternalGains: T_EP_ZoneGains;
    WriteZoneObject: boolean;
    Surfaces: TObjectList;
    CustomTDDs: TObjectList;
    VentilationSimpleObjects: TObjectList;
    LowTempRadiantSurfaceGroup: T_EP_LowTempRadiantSurfaceGroup;
    Typ: TZoneType;
    NorthAxis : double;
    XOrigin, YOrigin, ZOrigin: double;
    ZoneMultiplier: integer;
    FloorMultiplier: Boolean;
    CeilingHeight: double;
    PlenumHeight: double;
    FloorInfo: T_EP_FloorInfo;
    WallTurns: Integer;
    AirSystemName: string;
    ExhaustFanComponent: THVACComponent;
    //simple ventilation
    MinimumIndoorTemp: double;
    MaximumIndoorTemp: double;
    MinimumOutdoorTemp: double;
    MaximumOutdoorTemp: double;
    DeltaTemp: double;
    OAPerArea: double;
    OAPerPerson: double;
    OAPerZone: double;
    OAPerACH: double;
    AirDistributionEffectivenessCooling: double;
    AirDistributionEffectivenessHeating: double;
    AirDistributionEffectivenessSchedule: string;
    CoolingDesignAirFlowMethod: string;
    CoolingDesignAirFlowRate: double;
    CoolingMinAirFlowPerArea: double;
    CoolingMinAirFlowPerZone: double;
    CoolingMinAirFlowACH: double;
    CoolingMinAirFlowFraction: double;
    ZoneSizingFactor: double;
    CoolingDesignSupplyAirTemperature: double;
    HeatingDesignSupplyAirTemperature: double;
    CoolingDesignSupplyAirHumidityRatio: double;
    HeatingDesignSupplyAirHumidityRatio: double;
    //strOutsideAirFlowPerZone: string;
    ExhaustAirFlowPerArea: double;
    DemandControlVentilation: boolean;
    MinOASchedule: string;
    SimpleVentilation: boolean; // if true, then simple ventilation object used at Zone level for OA
    FanPressureDrop: double; // only used with simple ventilation
    FanEfficiency: double; // only used with simple ventilation
    SimpleVentilationDesignFlowRate: double; // only used with simple ventilation
    SimpleVentilationType: string; // only used with simple ventilation
    MotorizedDamper: boolean; //control schedule choice on simple Ventilation object
    OAviaZoneERV: boolean; // set to true if all the mech vent is to come from zone ERV
    EconomizeViaZoneERV: boolean; // set to true if Zone ERV is to do air-side economizing
    HeatSP_Sch: string;
    CoolSP_Sch: string;
    UsePrecooling: boolean;
    OccupiedConditioned: boolean;
    Plenum: boolean;
    Area: double;
    ExcludeInTotalBuildingArea: boolean;
    AirVolume: double;
    NumPeople: double;
    NumPeopleExt: double; //not yet used
    HoursPerDay: double;
    UseHumidistat: boolean;
    HumiditySetpoint: double; // ksb: going to deprecate this one
    MinRelHumSetSch: string; // ksb: moving to schedules
    MaxRelHumSetSch: string;
    AirInletNodes: TStringList;
    AirExhaustNodes: TStringList;
    AirSysSupplySideOutletNode: string; // is Air system domain but needed for set point manager
    ZoneIntGainsProcessed: boolean; //used to determine if zone info has been processed yet
    ZoneHVACProcessed: boolean;
    ZoneProcessLoadInfoProcessed: boolean; //used to determine if zone HVAC info has been processed yet
    RoofMultiplierVal: integer; //this is the value that the roof multiplier changed
    FloorMultiplierVal: integer;
    HasHPWH: boolean;
    function MaxOA: double;
    function AddSpaceConditioning(Component: THVACComponent): THVACComponent;
    function AddProcessLoad(Component: THVACComponent): THVACComponent;
    procedure ToIDF; override;
    procedure GetZoneArea;
    procedure GetZoneVolume;
    function GetAreaFromPrincSurf(Distance: double; princSurf: T_EP_Surface): double;
    procedure GetWallTurns;
    function GetDaylightingPositions(NumPoints: Integer; var DLpnt1, DLpnt2: T_EP_Point;
      var PercCont1, PercCont2: Double): integer;
    function AddRoofMultiplier(ReduceBy: integer):boolean;
    function ExhaustAirFlow: double;
    procedure AddSurface(aSurface: T_EP_Surface);
    procedure AddCustomTDD(aCustomTDD: T_EP_CustomTDD);
    procedure ProcessZoneInfo(aNode: TxmlNode);
    procedure CheckEnclosed;
    procedure Finalize; override;
    constructor Create; reintroduce;
  end;

  // TODO: DLM: how to make private to this unit?
  // used in checkEnclosed
  T_SurfaceEdge = class(TObject)
    V1: T_EP_Vector;
    V2: T_EP_Vector;
    SurfNormal: T_EP_Vector;
    SurfName: string;
    MatchIndex: Integer;
    constructor Create; reintroduce;
    destructor Destroy; overload; override;
    function isEqual(otherSurfaceEdge: T_SurfaceEdge): boolean;
  end;

  T_SurfaceEdgeList = class(TObjectList)
  public
    procedure AddSurfaceEdge(V1: T_EP_Vector; V2: T_EP_Vector; SurfNormal: T_EP_Vector; SurfName: string);
  end;

var
  GeometryConfiguration: string;

implementation

uses
  EnergyPlusEndUseComponents, Math, XMLproc,
  EnergyPlusEconomics,
  EnergyPlusConstructions, EnergyPlusPPErrorMessages, GlobalFuncs,
  xmlProcessing, EnergyPlusZoneEquipmentList,
  EnergyPlusObject, // prevents a circular reference  (search on circular reference)
  EnergyPlusSystems;

constructor T_EP_FloorInfo.Create;
begin
  FFloorNumber := -9999;
  FFloorType := ftUnknown;
end;

function T_EP_FloorInfo.FloorNumberKnown: boolean;
begin
  result := not (FFloorNumber = -9999);
end;

constructor T_EP_LowTempRadiantSurfaceGroup.Create;
begin
  inherited;
  FSurfaces := TObjectList.create;
  FSurfaceArea := 0;
  FTubeLength := 0;
end;

destructor T_EP_LowTempRadiantSurfaceGroup.Destroy;
begin
  FSurfaces.Free;
  inherited;
end;

procedure T_EP_LowTempRadiantSurfaceGroup.Finalize;
begin

end;

procedure T_EP_LowTempRadiantSurfaceGroup.ToIDF;
var
  i: integer;
  Obj: TEnergyPlusObject;
begin
  if Surfaces.Count > 0 then
  begin
    Obj := IDF.AddObject('ZoneHVAC:LowTemperatureRadiant:SurfaceGroup');
    Obj.AddField('Name', Name);
    for i := 0 to Surfaces.Count - 1 do
    begin
      Obj.AddField('Surface ' + inttostr(i + 1), T_EP_Surface(Surfaces[i]).Name);
      Obj.AddField('Flow Fraction', FloatToStr(1.0 / Surfaces.Count) );
    end;
  end;
end;

procedure T_EP_LowTempRadiantSurfaceGroup.AddSurface(aSurface: T_EP_Surface);
var
  aConstruction: T_EP_Construction;
begin
  Surfaces.Add(aSurface);
  //FSurfaceArea := FSurfaceArea + aSurface.SurfaceArea;
  //FTubeLength := FTubeLength + aSurface.SurfaceArea / aConstruction.LowTemperatureRadiantProperties.TubeSpacing;
end;

constructor T_SurfaceEdge.Create;
begin
  V1 := T_EP_Vector.Create;
  V2 := T_EP_Vector.Create;
  SurfNormal := T_EP_Vector.Create;
  inherited;
end;

destructor T_SurfaceEdge.Destroy;
begin
  V1.destroy;
  V2.destroy;
  SurfNormal.destroy;
  inherited;
end;

function T_SurfaceEdge.isEqual(otherSurfaceEdge: T_SurfaceEdge): boolean;
var
  tol: double;
begin
  tol := 0.1; // meters, should be global threshold
  result := False;
  if (VectorMagnitude(VectorSubtract(V1,otherSurfaceEdge.V2)) <= tol) and
     (VectorMagnitude(VectorSubtract(V2,otherSurfaceEdge.V1)) <= tol) then
  begin
      result := True;
  end
  else if (VectorMagnitude(VectorSubtract(V1,otherSurfaceEdge.V1)) <= tol) and
     (VectorMagnitude(VectorSubtract(V2,otherSurfaceEdge.V2)) <= tol) then
  begin
     writeln('ERROR: One of these surfaces points into zone: ' + SurfName + ' or ' + otherSurfaceEdge.surfName);
  end;
end;

// DLM: really wish we had generic containers so didn't have to define specific TObjectLists
procedure T_SurfaceEdgeList.AddSurfaceEdge(V1: T_EP_Vector; V2: T_EP_Vector; SurfNormal: T_EP_Vector; SurfName: string);
var
  newSurfaceEdge: T_SurfaceEdge;
  tol: double;
begin
  tol := 0.1; // meters, should be global threshold
  // check not zero length edge
  if (VectorMagnitude(VectorSubtract(V1, V2)) <= tol) then
    writeln('ERROR: Zero length edge detected on surface ' + SurfName);
  // DLM: we need deep copy of TObject
  newSurfaceEdge := T_SurfaceEdge.Create;
  newSurfaceEdge.V1.i := V1.i;
  newSurfaceEdge.V1.j := V1.j;
  newSurfaceEdge.V1.k := V1.k;
  newSurfaceEdge.V2.i := V2.i;
  newSurfaceEdge.V2.j := V2.j;
  newSurfaceEdge.V2.k := V2.k;
  newSurfaceEdge.SurfNormal.i := SurfNormal.i;
  newSurfaceEdge.SurfNormal.j := SurfNormal.j;
  newSurfaceEdge.SurfNormal.k := SurfNormal.k;
  newSurfaceEdge.SurfName := SurfName;
  newSurfaceEdge.MatchIndex := -1;
  Add(newSurfaceEdge);
end;

{ T_EP_Zone }

constructor T_EP_Zone.Create;
begin
  Zones.Add(self);
  SpaceConditioning := TObjectList.Create;
  ProcessLoads := TObjectList.Create;
  AirInletNodes := TStringList.Create;
  AirExhaustNodes := TStringList.Create;
  Surfaces := TObjectList.Create;
  CustomTDDs := TObjectList.Create;
  VentilationSimpleObjects := TObjectList.Create;
  LowTempRadiantSurfaceGroup := nil;
  CostItems := TObjectList.Create;
  ZoneMultiplier := 1;
  SimpleVentilation := false;
  MotorizedDamper := false;
  OAviaZoneERV := false;
  EconomizeViaZoneERV := false;
  FloorMultiplier := False;
  UseHumidistat := false;
  ExcludeInTotalBuildingArea := False;
  WriteZoneObject := True;
  OccupiedConditioned := True;
  ZoneIntGainsProcessed := False;
  ZoneHVACProcessed := False;
  ZoneProcessLoadInfoProcessed := False;
  FloorInfo := T_EP_FloorInfo.Create;
  InternalGains := T_EP_ZoneGains.Create;
  ExternalGains := T_EP_ZoneGains.Create;
  //set some defaults
  NorthAxis := 0;
  HeatSP_Sch := 'HtgSetP_Sch';
  CoolSP_Sch := 'ClgSetP_Sch';
  AirVolume := -9999;
  RoofMultiplierVal := -9999;
  FloorMultiplierVal := 1;
  // defaults from XMLproc
  SimpleVentilationDesignFlowRate := -999.0;
  SimpleVentilationType := '';
  MinimumIndoorTemp := 5.0;
  MaximumIndoorTemp := 35.0;
  MinimumOutdoorTemp := -30.0;
  MaximumOutdoorTemp := 50.0;
  DeltaTemp := -30.0;
  OAPerArea := 0.0;
  OAPerPerson := 0.0;
  OAPerZone := 0.0;
  OAPerACH := 0.0;
  ZoneSizingFactor := 0.0;
  AirDistributionEffectivenessCooling := 1.0;
  AirDistributionEffectivenessHeating := 1.0;
  AirDistributionEffectivenessSchedule := '';
  CoolingDesignAirFlowMethod := 'DesignDay';
  CoolingDesignAirFlowRate := 0.0;
  CoolingMinAirFlowPerArea := 0.0;
  CoolingMinAirFlowPerZone := 0.0;
  CoolingMinAirFlowACH := 0.0;
  CoolingMinAirFlowFraction := 0.0;
  CoolingDesignSupplyAirTemperature := 14.0;
  HeatingDesignSupplyAirTemperature := 40.0;
  CoolingDesignSupplyAirHumidityRatio := 0.0085;
  HeatingDesignSupplyAirHumidityRatio := 0.008;
  FanEfficiency := 0.5;
  HasHPWH := false;
end;

function T_EP_Zone.AddSpaceConditioning(Component: THVACComponent): THVACComponent;
begin
  SpaceConditioning.Add(Component);
  TEndUseComponent(Component).Zone := self;
  result := Component;
end;

function T_EP_Zone.AddProcessLoad(Component: THVACComponent): THVACComponent;
begin
  ProcessLoads.Add(Component);
  TEndUseComponent(Component).Zone := self;
  result := Component;
end;

function T_EP_Zone.CoolingMinAirFlow: double;
// ksb: function CoolingMinAirFlow computes the maximum
// of the minimum cooling cfm and ach
// the result is used for the cooling minimum air flow in the zone sizng object
var
  LargestValue: double;
  FlowFromACH: double;
begin
  LargestValue := 0;
  if CoolingMinAirFlowPerZone > LargestValue then LargestValue := CoolingMinAirFlowPerZone;
  FlowFromACH := CoolingMinAirFlowACH * AirVolume / 3600.0;
  if FlowFromACH > LargestValue then LargestValue := FlowFromACH;
  Result := LargestValue;
end;

function T_EP_Zone.MaxOA: double;
var
  RateFromFlowPerArea: double;
  RateFromACH: double;
  RateFromFlowPerPerson: double;
  LargestFlow: double;
begin
  if (OAPerArea > 0.0) then
    RateFromFlowPerArea := OAPerArea * Area
  else
    RateFromFlowPerArea := 0.0;
  if (OAPerACH > 0.0) then
    RateFromACH := OAPerACH * AirVolume / 3600.0
  else
    RateFromACH := 0.0;
  if (OAPerPerson > 0.0) then
    RateFromFlowPerPerson := OAPerPerson * NumPeople
  else
    RateFromFlowPerPerson := 0.0;
  if (OAPerZone > 0.0) then
    // do nothing
  else
    OAPerZone := 0.0;
  LargestFlow := OAPerZone;
  if RateFromFlowPerArea + RateFromFlowPerPerson > LargestFlow then
    LargestFlow := RateFromFlowPerArea + RateFromFlowPerPerson;
  if RateFromACH > LargestFlow then LargestFlow := RateFromACH;
  if ExhaustAirFlow > LargestFlow then LargestFlow := ExhaustAirFlow;
  Result := LargestFlow
end;

procedure T_EP_Zone.Finalize;
var
  constructionName: string;
  iSurf: integer;
  aSurface: T_EP_Surface;
  aConstruction: T_EP_Construction;
  //aLowTempRadiantSurfaceGroup: T_EP_LowTempRadiantSurfaceGroup;
begin
  // use GetSurface if you want to add particular surfaces
  if (LowTempRadiantSurfaceGroup = nil) then
  begin
    // no explicit LowTempRadiantSurfaceGroups, create default one
    LowTempRadiantSurfaceGroup := T_EP_LowTempRadiantSurfaceGroup.create;
    LowTempRadiantSurfaceGroup.Name := Name + '_RadiantSurfaces';
    // add all the low temperature radiant surfaces that are in this zone
    for iSurf := 0 to Surfaces.Count - 1 do
    begin
      aSurface := T_EP_Surface(Surfaces[iSurf]);
      constructionName := aSurface.Construction;
      aConstruction := BldgConstructions.GetConstruction(constructionName);
      if (aConstruction <> nil) then
      begin
        if (aConstruction.LowTemperatureRadiantProperties.SourcePresentAfterLayerNumber > 0) then
        begin
          LowTempRadiantSurfaceGroup.AddSurface(aSurface);
        end;
      end;
    end;
  end;
end;

function T_EP_Zone.ExhaustAirFlow: double;
var
 i: integer;
 OAPerZoneSum: double;
 exhaustSum: double;
 OAFromOther : double;
 OAFromACH : double;
begin
  exhaustSum := 0.0;
  If (SpaceConditioning.Count > 0) then begin
    for i := 0 to SpaceConditioning.Count -1 do
    begin
      If (T_EP_ExhaustFan(SpaceConditioning[i]).ComponentType = 'Fan:ZoneExhaust') then
      begin
        T_EP_ExhaustFan(SpaceConditioning[i]).finalize;
        if T_EP_ExhaustFan(SpaceConditioning[i]).OverrideOA then
          exhaustSum := exhaustSum + T_EP_ExhaustFan(SpaceConditioning[i]).MaxExhaustFlowRate ;
      end;
    end;
  end;
  Result := exhaustSum;
end;

procedure T_EP_Zone.ToIDF;
var
  Obj: TEnergyPlusObject;
  i: integer;
  VentSched: string;
  bIncludeArea: boolean;
label SkipZoneEquipList;
label SkipNodeList;
begin
  Finalize;
  if WriteZoneObject then
  begin
    //write the geometry for each zone
    Obj := IDF.AddObject('Zone');
    Obj.AddField('Name', Name);
    Obj.AddField('Direction of Relative North', NorthAxis);
    Obj.AddField('X Origin', XOrigin);
    Obj.AddField('Y Origin', YOrigin);
    Obj.AddField('Z Origin', ZOrigin);
    Obj.AddField('Type', 1);
    Obj.AddField('Multiplier', ZoneMultiplier);
    if CeilingHeight > 0.0 then
      Obj.AddField('Ceiling Height', CeilingHeight, '{m}')
    else
      Obj.AddField('Ceiling Height', 'AutoCalculate', '{m}');
    if AirVolume > 0.0 then
      Obj.AddField('Volume', AirVolume, '{m3}')
    else
      Obj.AddField('Volume', 'AutoCalculate', '{m3}');
    Obj.AddField('Floor Area', 'AutoCalculate', '{m2}');
    Obj.AddField('Zone Inside Convection Algorithm', '');
    Obj.AddField('Zone Outside Convection Algorithm', '');
    bIncludeArea := OccupiedConditioned;
    if ExcludeInTotalBuildingArea then bIncludeArea := false;
    if bIncludeArea then
      Obj.AddField('Part of Total Floor Area', 'Yes')
    else
      Obj.AddField('Part of Total Floor Area', 'No');
  end;
  for i := 0 to Surfaces.Count - 1 do
  begin
    T_EP_Surface(Surfaces[i]).ToIDF;
  end;
  LowTempRadiantSurfaceGroup.ToIDF;
  for i := 0 to CustomTDDs.Count - 1 do
  begin
    T_EP_CustomTDD(CustomTDDs[i]).ToIDF;
  end;
  if Assigned(Daylighting) then Daylighting.ToIDF;
  if Assigned(InternalMass) then InternalMass.ToIDF;
  if Assigned(Infiltration) then Infiltration.ToIDF;
  if Assigned(InternalGains) then
  begin
    if Assigned(InternalGains.People) then
      InternalGains.People.ToIDF;
    if Assigned(InternalGains.Lighting) then
      InternalGains.Lighting.ToIDF;
    if Assigned(InternalGains.EquipmentList) then
      InternalGains.EquipmentList.ToIDF;
  end;
  if Assigned(ExternalGains) then
  begin
    //if Assigned(ExternalGains.People) then
    //  ExternalGains.People.ToIDF;
    if Assigned(ExternalGains.Lighting) then
      ExternalGains.Lighting.ToIDF;
    if Assigned(ExternalGains.EquipmentList) then
      ExternalGains.EquipmentList.ToIDF;
  end;
  if assigned(CostItems) then
  begin
    for i := 0 to CostItems.Count - 1 do
    begin
      T_EP_Economics(CostItems[i]).ToIDF;
    end;
  end; //for cost items
  if SpaceConditioning.Count > 0 then
  begin
    IDF.AddComment('');  // intentional blank line
    IDF.AddComment('Space Conditioning For Zone: ' + Name);
    Obj := IDF.AddObject('Sizing:Zone');
    Obj.AddField('Zone Name', Name);
    Obj.AddField('Zone Cooling Design Supply Air Temperature Input Method', 'SupplyAirTemperature', '{SupplyAirTemperature | TemperatureDifference}');
    Obj.AddField('Zone Cooling Design Supply Air Temperature', CoolingDesignSupplyAirTemperature, '{C}');
    Obj.AddField('Zone Cooling Design Supply Air Temperature Difference', '', '{deltaC}');
    Obj.AddField('Zone Heating Design Supply Air Temperature Input Method', 'SupplyAirTemperature', '{SupplyAirTemperature | TemperatureDifference}');
    Obj.AddField('Zone Heating Design Supply Air Temperature', HeatingDesignSupplyAirTemperature, '{C}');
    Obj.AddField('Zone Heating Design Supply Air Temperature Difference', '', '{deltaC}');
    Obj.AddField('Zone Cooling Design Supply Air Humidity Ratio', CoolingDesignSupplyAirHumidityRatio, '{kg-H20/kg-air}');
    Obj.AddField('Zone Heating Design Supply Air Humidity Ratio', HeatingDesignSupplyAirHumidityRatio, '{kg-H20/kg-air}');
    Obj.AddField('Design Specification Outdoor Air Object Name', Name + ' OA Design Spec');
    if ZoneSizingFactor > 0.0 then
    begin
      Obj.AddField('Zone Heating Sizing Factor', ZoneSizingFactor, '');
      Obj.AddField('Zone Cooling Sizing Factor', ZoneSizingFactor, '');
    end
    else
    begin
      Obj.AddField('Zone Heating Sizing Factor', '', '');
      Obj.AddField('Zone Cooling Sizing Factor', '', '');
    end;
    Obj.AddField('Cooling Design Air Flow Method', CoolingDesignAirFlowMethod, '{Flow/Zone | DesignDay | DesignDayWithLimit}');
    if CoolingDesignAirFlowMethod = 'Flow/Zone' then
    begin
      if CoolingDesignAirFlowRate > 0.0 then
        Obj.AddField('Cooling Design Air Flow Rate', FloatToStr(CoolingDesignAirFlowRate))
      else
        Obj.AddField('Cooling Design Air Flow Rate', '');
    end
    else
      Obj.AddField('Cooling Design Air Flow Rate', '');
    if CoolingDesignAirFlowMethod = 'DesignDayWithLimit' then
    begin
      if CoolingMinAirFlowPerArea > 0.0 then
        Obj.AddField('Cooling Minimum Air Flow Per Zone Floor Area', FloatToStr(CoolingMinAirFlowPerArea))
      else
        Obj.AddField('Cooling Minimum Air Flow Per Zone Floor Area', '');
      if CoolingMinAirFlow > 0.0 then
        Obj.AddField('Cooling Minimum Air Flow', FloatToStr(CoolingMinAirFlow))
      else
        Obj.AddField('Cooling Minimum Air Flow', '');
    end
    else
    begin
      Obj.AddField('Cooling Minimum Air Flow Per Zone Floor Area', '');
      Obj.AddField('Cooling Minimum Air Flow', '');
    end;
    if CoolingMinAirFlowFraction > 0.0 then
      Obj.AddField('Cooling Minimum Air Flow Fraction', FloatToStr(CoolingMinAirFlowFraction))
    else
      Obj.AddField('Cooling Minimum Air Flow Fraction', '0.0');
    Obj.AddField('Heating Design Air Flow Method', 'DesignDay', '{Flow/Zone | DesignDay}');
    Obj.AddField('Heating Design Air Flow Rate', '0.0');
    Obj.AddField('Heating Maximum Air Flow Per Zone Floor Area', '');
    Obj.AddField('Heating Maximum Air Flow', '');
    Obj.AddField('Heating Maximum Air Flow Fraction', '');
    Obj.AddField('Design Specification Zone Air Distribution Object Name', Name + ' Air Dist Design Spec');
    //OA design spec object
    Obj := IDF.AddObject('DesignSpecification:OutdoorAir');
    Obj.AddField('Name', Name + ' OA Design Spec');
    if Self.DemandControlVentilation then
    begin
      Obj.AddField('Outdoor Air Method', 'Sum');
      Obj.AddField('Outdoor Air Flow Per Person', FloatToStr(Self.OAPerPerson), '{m3/s-person}');
      Obj.AddField('Outdoor Air Flow Per Zone Floor Area', FloatToStr(Self.OAPerArea), '{m3/s-m2}');
      Obj.AddField('Outdoor Air Flow Per Zone', FloatToStr(Self.OAPerZone), '{m3/s}');
      Obj.AddField('Outdoor Air Flow Air Changes per Hour', FloatToStr(Self.OAPerACH), '{1/hr}');
    end
    else
    begin
      Obj.AddField('Outdoor Air Method', 'Flow/Zone');
      Obj.AddField('Outdoor Air Flow Per Person', '0.0', '{m3/s-person}');
      Obj.AddField('Outdoor Air Flow Per Zone Floor Area', '0.0', '{m3/s-m2}');
      Obj.AddField('Outdoor Air Flow Per Zone', FloatToStr(Self.MaxOA), '{m3/s}');
      Obj.AddField('Outdoor Air Flow Air Changes per Hour', '0.0', '{1/hr}');
    end;
    Obj.AddField('Outdoor Air Flow Rate Fraction Schedule Name', '');
    //air distribution design spec object
    Obj := IDF.AddObject('DesignSpecification:ZoneAirDistribution');
    Obj.AddField('Name', Name + ' Air Dist Design Spec');
    Obj.AddField('Zone Air Distribution Effectiveness in Cooling Mode', Self.AirDistributionEffectivenessCooling);
    Obj.AddField('Zone Air Distribution Effectiveness in Heating Mode', Self.AirDistributionEffectivenessHeating);
    Obj.AddField('Zone Air Distribution Effectiveness Schedule Name', Self.AirDistributionEffectivenessSchedule);
    Obj.AddField('Zone Secondary Recirculation Fraction', '0.0');
    //thermostat
    Obj := IDF.AddObject('ZoneControl:Thermostat');
    Obj.AddField('Name', Name + ' Thermostat');
    Obj.AddField('Zone Name', Name);
    Obj.AddField('Control Type Schedule Name', 'Dual Zone Control Type Sched');
    Obj.AddField('Control 1 Object Type', 'ThermostatSetpoint:DualSetpoint');
    Obj.AddField('Control 1 Name', Name + ' DualSPSched');
    //humidistat
    if UseHumidistat then
    begin
      if (MinRelHumSetSch <> '') or (MaxRelHumSetSch <> '') then
      begin
        Obj := IDF.AddObject('ZoneControl:Humidistat');
        Obj.AddField('Name', Name + ' Humidistat');
        Obj.AddField('Zone Name', Name);
        Obj.AddField('Humidifying Relative Humidity Setpoint Schedule Name', MinRelHumSetSch);
        Obj.AddField('Dehumidifying Relative Humidity Setpoint Schedule Name', MaxRelHumSetSch);
      end
      else
      begin
        Obj := IDF.AddObject('Schedule:Compact');
        Obj.AddField('Name', name + ' Humidity Schedule');
        Obj.AddField('Schedule Type Limits Name', 'Any number');
        Obj.AddField('Field 1', 'Through: 12/31');
        Obj.AddField('Field 2', 'For: AllDays');
        Obj.AddField('Field 3', 'Until: 24:00');
        Obj.AddField('Field 4', HumiditySetpoint);
      end;
    end;
    if UsePrecooling then
    begin
      Obj := IDF.AddObject('ThermostatSetpoint:DualSetpoint');
      Obj.AddField('Name', Name + ' DualSPSched');
      Obj.AddField('Heating Setpoint Temperature Schedule Name', HeatSP_Sch);
      Obj.AddField('Cooling Setpoint Temperature Schedule Name', 'ClgSetP_Precool_Sch');
      Obj := IDF.AddObject('Schedule:Compact');
      Obj.AddField('Name', 'ClgSetP_Precool_Sch');
      Obj.AddField('Schedule Type Limits Type', 'Temperature');
      Obj.AddField('Field 1', 'Through: 12/31');
      Obj.AddField('Field 2', 'For: AllDays');
      Obj.AddField('Field 3', 'Until: 4:00');
      Obj.AddField('Field 4', '24.0');
      Obj.AddField('Field 5', 'Until: 7:00'); // precool from 4:00 to 7:00
      Obj.AddField('Field 6', '20.0');
      Obj.AddField('Field 7', 'Until: 24:00');
      Obj.AddField('Field 8', '24.0');
    end
    else
    begin // use default cooling schedule
      Obj := IDF.AddObject('ThermostatSetpoint:DualSetpoint');
      Obj.AddField('Name', Name + ' DualSPSched');
      Obj.AddField('Heating Setpoint Temperature Schedule Name', HeatSP_Sch);
      Obj.AddField('Cooling Setpoint Temperature Schedule Name', CoolSP_Sch);
    end;
    Obj := IDF.AddObject('ZoneHVAC:EquipmentConnections');
    Obj.AddField('Zone Name', Name);
    Obj.AddField('Zone Conditioning Equipment List Name', Name + ' Equipment');
    if AirInletNodes.Count > 0 then
      Obj.AddField('Zone Air Inlet Node or NodeList Name', Name + ' Inlet Nodes')
    else
      Obj.AddField('Zone Air Inlet Node or NodeList Name', '');
    if AirExhaustNodes.Count > 0 then
      Obj.AddField('Zone Air Exhaust Node or NodeList Name', Name + ' Exhaust Nodes')
    else if Self.HasHPWH then
      Obj.AddField('Zone Air Exhaust Node or NodeList Name', Name + ' Outlet Nodes')
    else
      Obj.AddField('Zone Air Exhaust Node or NodeList Name', '');
    Obj.AddField('Zone Air Node Name', Name + ' Air Node');
    Obj.AddField('Zone Return Air Node Name', Name + ' Return Air Node Name');
    if AirInletNodes.Count > 0 then
    begin
      Obj := IDF.AddObject('NodeList');
      Obj.AddField('Name', Name + ' Inlet Nodes');
      if Self.HasHPWH then
      begin
        Obj.AddField('Node 1 Name', Name + ' Bottom Outlet Node');
        Obj.AddField('Node 2 Name', Name + ' Top Outlet Node');
        for i := 0 to AirInletNodes.Count - 1 do
        begin
          Obj.AddField('Node ' + IntToStr(i + 3) + ' Name', AirInletNodes[i]);
        end;
        Obj := IDF.AddObject('NodeList');
        Obj.AddField('Name', Name + ' Outlet Nodes');
        Obj.AddField('Node 1 Name', Name + ' Top Inlet Node');
        Obj.AddField('Node 2 Name', Name + ' Bottom Inlet Node');
        Goto SkipNodeList;
      end;
      for i := 0 to AirInletNodes.Count - 1 do
      begin
        Obj.AddField('Node ' + IntToStr(i + 1) + ' Name', AirInletNodes[i]);
      end;
      SkipNodeList:
    end;
    if AirExhaustNodes.Count > 0 then
    begin
      Obj := IDF.AddObject('NodeList');
      Obj.AddField('Name', Name + ' Exhaust Nodes');
      for i := 0 to AirExhaustNodes.Count - 1 do
      begin
        Obj.AddField('Node ' + IntToStr(i + 1) + ' Name', AirExhaustNodes[i]);
      end;
    end;
    Obj := IDF.AddObject('ZoneHVAC:EquipmentList');
    Obj.AddField('Name', Name + ' Equipment');
    if Self.HasHPWH then
    begin
      Obj.AddField('Zone Equipment Object 1 Type', 'WaterHeater:HeatPump');
      Obj.AddField('Zone Equipment 1 Name', 'SWHSys1 Water Heater Top');
      Obj.AddField('Zone Equipment Cooling Priority', '1');
      Obj.AddField('Zone Equipment Heating Priority', '1');
      Obj.AddField('Zone Equipment Object 1 Type', 'WaterHeater:HeatPump');
      Obj.AddField('Zone Equipment 1 Name', 'SWHSys1 Water Heater Bottom');
      Obj.AddField('Zone Equipment Cooling Priority', '2');
      Obj.AddField('Zone Equipment Heating Priority', '2');
      for i := 0 to SpaceConditioning.Count - 1 do
      begin
        Obj.AddField('Zone Equipment ' + IntToStr(i + 3) + ' Object Type', THVACComponent(SpaceConditioning[i]).ComponentType);
        Obj.AddField('Zone Equipment ' + IntToStr(i + 3) + ' Name' , THVACComponent(SpaceConditioning[i]).Name);
        Obj.AddField('Zone Equipment ' + IntToStr(i + 3) + ' Cooling Priority', IntToStr(i + 3));
        Obj.AddField('Zone Equipment ' + IntToStr(i + 3) + ' Heating Priority', IntToStr(i + 3));
      end;
      Goto SkipZoneEquipList
    end;
    for i := 0 to SpaceConditioning.Count - 1 do
    begin
      Obj.AddField('Zone Equipment ' + IntToStr(i + 1) + ' Object Type', THVACComponent(SpaceConditioning[i]).ComponentType);
      Obj.AddField('Zone Equipment ' + IntToStr(i + 1) + ' Name' , THVACComponent(SpaceConditioning[i]).Name);
      Obj.AddField('Zone Equipment ' + IntToStr(i + 1) + ' Cooling Priority', IntToStr(i + 1));
      Obj.AddField('Zone Equipment ' + IntToStr(i + 1) + ' Heating Priority', IntToStr(i + 1));
    end;
    SkipZoneEquipList:
  end; //SpaceConditioning.Count > 0
  for i := 0 to SpaceConditioning.Count - 1 do
  begin
    TEndUseComponent(SpaceConditioning[i]).ToIDF;
  end;
  if ProcessLoads.Count > 0 then
  begin
    IDF.AddComment('');
    IDF.AddComment('Process Loads For Zone: ' + Name);
  end;
  for i := 0 to ProcessLoads.Count - 1 do
  begin
    THVACComponent(ProcessLoads[i]).ToIDF;
    //TEndUseComponent(ProcessLoads[i]).ToIDF;
  end;
  for i := 0 to self.VentilationSimpleObjects.Count -1 do
  begin
    T_EP_VentilationSimple(self.VentilationSimpleObjects[i]).ToIDF;
  end;
end;

procedure T_EP_Zone.AddSurface(aSurface: T_EP_Surface);
begin
  aSurface.InsideEnvironment := Name;
  Surfaces.Add(aSurface);
end;

procedure T_EP_Zone.AddCustomTDD(aCustomTDD: T_EP_CustomTDD);
begin
  CustomTDDs.Add(aCustomTDD);
end;

procedure T_EP_Zone.GetZoneArea;
//this goes through all the surfaces in the zones and sums up the
//area of the floors
var
  i: Integer;
  aSurf: T_EP_Surface;
begin
  Area := 0;
  for i := 0 to Surfaces.Count - 1 do
  begin
    aSurf := T_EP_Surface(Surfaces[i]);
    if (aSurf.Typ = stFloor) then
    begin
      Area := Area + AreaPolygon(aSurf.Verts);
      WriteLn('Surf: ' + aSurf.Name + ' Area: ' + Format('%f',[Area]));
    end;
  end;
end;

procedure T_EP_Zone.GetZoneVolume;
// go through each surface and calculate sum of volume contribution for each polygon
// this will have serious problems if the zone is not completely closed
var
  i : Integer;
  aSurf: T_EP_Surface;
  dAirVolumeTest: double;
  dTest: double;
const
  VOL_PRECISION = 0.05;
begin
  if Surfaces.count = 1 then
  begin
    AirVolume := 0;
  end
  else  //more than one surface
  begin
    // loop over all surfaces regardless of type
    dAirVolumeTest := 0;
    for i := 0 to Surfaces.Count - 1 do
    begin
      aSurf := T_EP_Surface(Surfaces[i]);
      dAirVolumeTest := dAirVolumeTest + VolumeContributionPolygon(aSurf.Verts);
    end;

    if AirVolume = -9999 then
    begin
      AirVolume := dAirVolumeTest;
    end
    else
    begin
      if AirVolume <> 0 then
      begin
        dTest := 100*(abs(airvolume - dAirVolumeTest))/(AirVolume);
        if dTest > VOL_PRECISION then
        begin
          writeln('WARNING: ' + Name + ' Input AirVolume and Calculated AirVolume differ by ' +
                  format('%.2f',[dTest]) + '%.  Input = ' + format('%.2f',[AirVolume]) +
                  ', Calculated = ' +  format('%.2f',[dAirVolumeTest]));
        end;
      end
      else
        T_EP_PPErrorMessage.AddErrorMessage(esWarning,'Zone: ' + Name + ' No air volume');
    end;

    if AirVolume < 0 then
    begin
      //AirVolume := Area * CeilingHeight;
      T_EP_PPErrorMessage.AddErrorMessage(esSevere, 'AirVolume was negative for ' + Name);
    end
    else
      WriteLn('Zone: ' + Name + ' NumSurfs: ' + IntToStr(Surfaces.Count) + ' AirVol: ' + Format('%f',[AirVolume]));
    CheckEnclosed();
  end;
end;


function T_EP_Zone.AddRoofMultiplier(ReduceBy: integer):boolean;
//the value of reduce by is the same as the multiplier.
//the function returns true iff the roof was reduced.
var
  baseArea: double;
  newRatio: double;
  i: Integer;
  aSurf: T_EP_Surface;
  iVert: Integer;
  xStart: double;
  yStart: double;
  bSkip: boolean;
  xMin: double;
  xMax: double;
  yMin: double;
  yMax: double;
begin
  result := false;
  if ZoneMultiplier = 1 then
  begin
    //reform roof to use a multiplier and simulate smaller area
    if WallTurns = 4 then //only works for rectangular shapes
    begin
      //make sure that the zone does not have an exterior wall
      bSkip := false;
      for i := 0 to Surfaces.Count - 1 do
      begin
        aSurf := T_EP_Surface(Surfaces.Items[i]);
        if (aSurf.Typ = stWall) then
        begin
          if (aSurf.SpecificType = sstExteriorWall) then
          begin
            bSkip := true;
            break;
          end;
        end;
      end;
      if bSkip then
      begin
        result := false;
        exit;
      end;

      for i := 0 to Surfaces.Count - 1 do
      begin
        aSurf := T_EP_Surface(Surfaces.Items[i]);
        if (aSurf.Typ = stCeiling) and (aSurf.SpecificType = sstRoof) then
        begin
          newRatio := sqrt(ReduceBy);
          //the ratio is the value each point will be moved.

          ZoneMultiplier := reduceBy;
          AirVolume := AirVolume / ZoneMultiplier;

          //find the max/min position
          for iVert := 0 to aSurf.Verts.Count - 1 do
          begin
            if iVert = 0 then
            begin
              //initialize vars
              xMin := T_EP_Vector(aSurf.Verts[iVert]).i;
              xMax := T_EP_Vector(aSurf.Verts[iVert]).i;
              yMin := T_EP_Vector(aSurf.Verts[iVert]).j;
              yMax := T_EP_Vector(aSurf.Verts[iVert]).j;
            end;

            if T_EP_Vector(aSurf.Verts[iVert]).i < xMin then
              xMin := T_EP_Vector(aSurf.Verts[iVert]).i;
            if T_EP_Vector(aSurf.Verts[iVert]).i > xMax then
              xMax := T_EP_Vector(aSurf.Verts[iVert]).i;
            if T_EP_Vector(aSurf.Verts[iVert]).j < yMin then
              yMin := T_EP_Vector(aSurf.Verts[iVert]).j;
            if T_EP_Vector(aSurf.Verts[iVert]).j > yMax then
              yMax := T_EP_Vector(aSurf.Verts[iVert]).j;
          end;

          //resize the roof
          for iVert := 0 to aSurf.Verts.Count - 1 do
          begin
            if iVert = 0 then
            begin
              //calculate the new starting points for the zone
              xStart := ((xMax - xMin) - (xMax / newRatio - xMin / newRatio)) / 2 +
                (xMax / newRatio - xMin / newRatio) / 2 + xMin;
              yStart := ((yMax - yMin) - (yMax / newRatio - yMin / newRatio)) / 2 +
                (yMax / newRatio - yMin / newRatio) / 2 + yMin;
            end;

            T_EP_Vector(aSurf.Verts[iVert]).i :=
              xStart +
              (T_EP_Vector(aSurf.Verts[iVert]).i - xStart) / newRatio;

            T_EP_Vector(aSurf.Verts[iVert]).j :=
              yStart +
              (T_EP_Vector(aSurf.Verts[iVert]).j - yStart) / newRatio;
          end;
          Area := AreaPolygon(aSurf.Verts);
          aSurf.SurfaceArea := Area;
        end;
      end;

      //now go through and resize all the other surfaces
      for i := 0 to Surfaces.Count - 1 do
      begin
        aSurf := T_EP_Surface(Surfaces.Items[i]);

        //change surfaces underneath to be self referencing
        if (aSurf.Typ = stFloor) then
        begin
          //resize the roof
          for iVert := aSurf.Verts.Count - 1 downto 0 do
          begin
            T_EP_Vector(aSurf.Verts[iVert]).i :=
              xStart +
              (T_EP_Vector(aSurf.Verts[iVert]).i - xStart) / newRatio;

            T_EP_Vector(aSurf.Verts[iVert]).j :=
              yStart +
              (T_EP_Vector(aSurf.Verts[iVert]).j - yStart) / newRatio;
          end;

          if (aSurf.SpecificType = sstInteriorFloor) then
          begin
            aSurf.MakeAdiabatic(true);
          end;
        end;

        //change walls to be self referencing
        if (aSurf.Typ = stWall) and
          ((aSurf.SpecificType = sstInteriorWall) or
          (aSurf.SpecificType = sstAdiabaticWall)) then
        begin
          //make the other zone surface adiabatic also
          aSurf.MakeAdiabatic(true);
          //don't write the wall objects for the multiplied zone
          aSurf.WriteObject := false;
        end;
      end; //for surfaces
      result := true;
    end; //if 6 surfaces
  end;
end; //

procedure T_EP_Zone.ProcessZoneInfo(aNode: TxmlNode);
var
  ChildNode: Txmlnode;
  valr: double;
  i: Integer;
  aSurf: T_EP_Surface;
  ChildNode_2: TXmlNode;
  AreaFraction: Double;
  SillHeight: double;
  EdgeOffset: Double;
  winRepresentationType: TWindowRepresentationType;
  OverhangDepth: double;
  OverhangProjFactor: double;
  OverhangOffset: double;
  FinDepth: double;
  FinOffset: double;
  aList: TList;
  anEquip: T_EP_Equipment;
  bAdiabatic: boolean;
  iSurf: Integer;
  xmlSurfIndex: integer;
  xmlSurf: TXmlnode;
  xmlSurfNorm: TNormalType;
  xmlSurfNormName: string;
  xmlSurfNormString: string;
  xmlExtWalls: TXmlnode;
  xmlIntWalls: txmlnode;
  xmlFen: txmlnode;
  bWindowsInstalled: Boolean;
  sTempstr: string;
  j: Integer;
  bTDDsInstalled: Boolean;
  aNewCost: T_EP_Economics;
  numTDDsAdded: Integer;
  sConstructName: string;
  aConstruct: T_EP_Construction;
  Childnode_3: Txmlnode;
  OverhangCost: double;
  FinCost: double;
  MultBy: integer;
  aSurf2: T_EP_SUrface;
  numSkyAdded: integer;
  HeaderHeight: double;
  winApplyType: TWindowApplyType;
  pnt1: T_EP_Point;
  pnt2: T_EP_Point;
  numDL: Integer;
  percCont1: double;
  percCont2: double;
  aConst: T_EP_Construction;
  infil_DesignLevel: double;
  infil_FlowPerExtWallArea: double;
  infil_FlowPerExtArea: double;
  FinProjFactor: double;
  sensorNode: txmlnode;
  bCustomSensor: Boolean;
  bSensor2: Boolean;
  flrSurf: t_ep_surface;
  xmlDLFen: Txmlnode;
  FinSpacing: double;
  iTestMult: Integer;
  numCount: Integer;
  valr2: double;
  Gains: TXmlNode;
begin
  //set up zone parameters
  ExcludeInTotalBuildingArea := BooleanValueFromPath(aNode, 'ExcludeInArea', False);


  if Typ = ztNormal then
  begin
    //grab all surfaces objects
    aList := TList.Create;
    try
      aNode.FindNodes('Surfaces', aList);
      if aList.Count > 0 then
        for i := 0 to aList.Count - 1 do
        begin
          xmlSurf := TXmlNode(aList[i]);
          xmlExtWalls := nil;
          xmlIntWalls := nil;
          xmlFen := nil;

          xmlSurfNormString := StringValueFromPath(xmlSurf, 'SurfaceNormal');
          if xmlSurfNormString = 'SOUTH' then
            xmlSurfNorm := ntSouth
          else if xmlSurfNormString = 'EAST' then
            xmlSurfNorm := ntEast
          else if xmlSurfNormString = 'NORTH' then
            xmlSurfNorm := ntNorth
          else if xmlSurfNormString = 'WEST' then
            xmlSurfNorm := ntWest
          else if xmlSurfNormString = 'NAME' then
          begin
            xmlSurfNorm := ntNone;
            xmlSurfNormName := StringValueFromPath(xmlSurf, 'SurfaceName', False, '')
          end
          else
            xmlSurfNorm := ntNone;

          xmlSurfIndex := IntegerValueFromPath(xmlSurf, 'SurfaceIndex', -1);
          xmlExtWalls := xmlSurf.FindNode('ExteriorWalls');
          xmlIntWalls := xmlSurf.FindNode('InteriorWalls');
          xmlFen := xmlSurf.FindNode('Fenestration');
          xmlDLFen := xmlSurf.FindNode('DaylightFenestration');

          for iSurf := 0 to Surfaces.Count - 1 do
          begin
            aSurf := T_EP_Surface(Surfaces.Items[iSurf]);
            if ((xmlSurfIndex <> -1) and (xmlSurfIndex = iSurf)) or
              (aSurf.Nrm = xmlSurfNorm) or
              (aSurf.Name = xmlSurfNormName) or
              (xmlSurfNormString = 'ALL') then
            begin
              //apply the exterior walls
              if (assigned(xmlExtWalls)) and (aSurf.SpecificType = sstExteriorWall) then
              begin
                if BooleanValueFromPath(xmlExtWalls, 'Adiabatic') then
                  aSurf.MakeAdiabatic;

                ChildNode_2 := xmlExtWalls.FindNode('Construction');
                if Assigned(ChildNode_2) then
                begin
                  //find construction name
                  Childnode_3 := ChildNode_2.FindNode('ConstructionName');
                  if assigned(Childnode_3) then
                  begin
                    sConstructName := StringValueFromAttribute(Childnode_3, 'instance');
                    if BldgConstructions.AddToBldgConstructions(sConstructName, 'Custom', aConstruct) then
                    begin
                      aConstruct.Typ := 'Opaque';
                      aConstruct.AddCost(FloatValueFromAttribute(Childnode_3, 'CostPer', 1),
                                         'Custom');
                      aConstruct.AddLayers(ChildNode_2);

                    end;
                    aSurf.SetConstruction(sConstructName);
                  end; //if childnode_3
                end;
              end;

              //apply the fenestration
              if (assigned(xmlFen)) and (aSurf.SpecificType = sstExteriorWall) then
              begin
                if StringValueFromPath(xmlFen, 'ApplyType', TRUE, 'BOTTOMUP') = 'TOPDOWN' then
                  winApplyType := watTopDown
                else
                  winApplyType := watBottomUp;
                AreaFraction := FloatValueFromPath(xmlFen, 'AreaFraction');
                SillHeight := FloatValueFromPath(xmlFen, 'SillHeight', 1.1);
                HeaderHeight := FloatValueFromPath(xmlFen, 'HeaderHeight', 0.5);
                EdgeOffset := FloatValueFromPath(xmlFen, 'EdgeOffset', 0.05);
                if StringValueFromPath(xmlFen, 'Type', False) = 'Discrete' then
                  winRepresentationType := wrtDiscrete
                else
                  winRepresentationType := wrtBanded;

                if AreaFraction <> 0 then
                begin
                  aSurf.AddWindow(wtViewGlass, winApplyType, AreaFraction, SillHeight, HeaderHeight,
                    EdgeOffset, winRepresentationType);
                end;

                ChildNode := xmlFen.FindNode('Overhang');
                if assigned(ChildNode) then
                begin
                  OverhangDepth := FloatValueFromPath(ChildNode, 'Depth');
                  OverhangProjFactor := FloatValueFromPath(ChildNode, 'ProjectionFactor');
                  OverhangOffset := FloatValueFromPath(ChildNode, 'Offset');
                  OverhangCost := 0.0;

                  if OverhangDepth <> 0 then
                  begin
                    ChildNode_2 := ChildNode.FindNode('Depth');
                    if Assigned(ChildNode_2) then
                      OverhangCost := FloatValueFromAttribute(ChildNode_2, 'CostPer');

                    aSurf.AddOverhang(OverhangDepth, OverhangOffset, OverhangCost);
                  end
                  else if OverhangProjFactor <> 0 then
                  begin
                    ChildNode_2 := ChildNode.FindNode('ProjectionFactor');
                    if Assigned(ChildNode_2) then
                      OverhangCost := FloatValueFromAttribute(ChildNode_2, 'CostPer');

                    aSurf.AddOverhangByProjFactor(OverhangProjFactor, OverhangOffset, OverhangCost);
                  end
                end;

                ChildNode := xmlFen.FindNode('Fin');
                if assigned(ChildNode) then
                begin
                  FinDepth := FloatValueFromPath(ChildNode, 'Depth');
                  FinProjFactor := FloatValueFromPath(ChildNOde, 'ProjectionFactor');
                  FinSpacing := FloatValueFromPath(ChildNode, 'Spacing');
                  FinOffset := FloatValueFromPath(ChildNode, 'Offset');
                  FinCost := 0.0;

                  if FinDepth <> 0 then
                  begin
                    ChildNode_2 := ChildNode.FindNode('Depth');
                    if Assigned(ChildNode_2) then
                      FinCost := FloatValueFromAttribute(ChildNode_2, 'CostPer');

                    aSurf.AddFin(FinDepth, FinOffset, FinSpacing, FinCost);
                  end
                  else if FinProjFactor <> 0 then
                  begin
                    ChildNode_2 := ChildNode.FindNode('ProjectionFactor');
                    if Assigned(ChildNode_2) then
                      FinCost := FloatValueFromAttribute(ChildNode_2, 'CostPer');

                    aSurf.AddFinByProjFactor(FinProjFactor, FinOffset, FinCost);
                  end
                end;
              end; //if xmlFEN

              //apply the daylighting fenestration
              if (assigned(xmlDLFen)) and (aSurf.SpecificType = sstExteriorWall) then
              begin
                if StringValueFromPath(xmlDLFen, 'ApplyType', TRUE, 'BOTTOMUP') = 'TOPDOWN' then
                  winApplyType := watTopDown
                else
                  winApplyType := watBottomUp;
                AreaFraction := FloatValueFromPath(xmlDLFen, 'AreaFraction');
                SillHeight := FloatValueFromPath(xmlDLFen, 'SillHeight', 1.1);
                HeaderHeight := FloatValueFromPath(xmlDLFen, 'HeaderHeight', 0.5);
                EdgeOffset := FloatValueFromPath(xmlDLFen, 'EdgeOffset', 0.05);
                if StringValueFromPath(xmlDLFen, 'Type') = 'Discrete' then
                  winRepresentationType := wrtDiscrete // discrete windows not available yet
                else
                  winRepresentationType := wrtBanded;

                if AreaFraction <> 0 then
                begin
                  aSurf.AddWindow(wtDaylightingGlass, winApplyType, AreaFraction, SillHeight, HeaderHeight,
                    EdgeOffset, winRepresentationType);
                end;

                //todo 1: this will not work right now, because it will add
                //the overhangs to all the windows, incl the ones that were
                //already on the building.  Need to rewrite a portion of
                //the routine to specify which windows get overhangs.
                ChildNode := xmlDLFen.FindNode('Overhang');
                if assigned(ChildNode) then
                begin
                  OverhangDepth := FloatValueFromPath(ChildNode, 'Depth');
                  OverhangProjFactor := FloatValueFromPath(ChildNode, 'ProjectionFactor');
                  OverhangOffset := FloatValueFromPath(ChildNode, 'Offset');
                  OverhangCost := 0.0;

                  if OverhangDepth <> 0 then
                  begin
                    ChildNode_2 := ChildNode.FindNode('Depth');
                    if Assigned(ChildNode_2) then
                      OverhangCost := FloatValueFromAttribute(ChildNode_2, 'CostPer');

                    aSurf.AddDaylightOverhang(OverhangDepth, OverhangOffset, OverhangCost);
                  end
                  else if OverhangProjFactor <> 0 then
                  begin
                    ChildNode_2 := ChildNode.FindNode('ProjectionFactor');
                    if Assigned(ChildNode_2) then
                      OverhangCost := FloatValueFromAttribute(ChildNode_2, 'CostPer');

                    aSurf.AddDaylightOverhangByProjFactor(OverhangProjFactor, OverhangOffset, OverhangCost);
                  end
                end;

                ChildNode := xmlDLFen.FindNode('Fin');
                if assigned(ChildNode) then
                begin
                  FinDepth := FloatValueFromPath(ChildNode, 'Depth');
                  FinProjFactor := FloatValueFromPath(ChildNOde, 'ProjectionFactor');
                  FinSpacing := FloatValueFromPath(ChildNode, 'Spacing');
                  FinOffset := FloatValueFromPath(ChildNode, 'Offset');
                  FinCost := 0.0;

                  if FinDepth <> 0 then
                  begin
                    ChildNode_2 := ChildNode.FindNode('Depth');
                    if Assigned(ChildNode_2) then
                      FinCost := FloatValueFromAttribute(ChildNode_2, 'CostPer');

                    aSurf.AddDaylightFin(FinDepth, FinOffset, FinSpacing, FinCost);
                  end
                  else if FinProjFactor <> 0 then
                  begin
                    ChildNode_2 := ChildNode.FindNode('ProjectionFactor');
                    if Assigned(ChildNode_2) then
                      FinCost := FloatValueFromAttribute(ChildNode_2, 'CostPer');

                    aSurf.AddDaylightFinByProjFactor(FinProjFactor, FinOffset, FinCost);
                  end
                end;
              end; //if xmlDLFen

            end;
          end;
        end;
    finally
      aList.Free;
    end;
  end; //if normal zone type

  //check if zone has windows installed
  bWindowsInstalled := false;
  for i := 0 to Surfaces.Count - 1 do
  begin
    aSurf := T_EP_Surface(Surfaces.Items[i]);
    if aSurf.WindowArea > 0 then bWindowsInstalled := true;
  end; //for i

  //check ceilings
  bTDDsInstalled := False;
  for i := 0 to Surfaces.Count - 1 do
  begin
    aSurf := T_EP_Surface(Surfaces.Items[i]);
    if aSurf.Typ = stCeiling then
    begin
      ChildNode := aNode.FindNode('Ceiling');
      if assigned(ChildNode) then
      begin
        bAdiabatic := BooleanValueFromPath(ChildNode, 'Adiabatic');
        if bAdiabatic then
          aSurf.MakeAdiabatic;


        //disable TDDs and skylights for attics for now
        if Typ = ztNormal then
        begin
          //check if top zone
          if aSurf.SpecificType = sstRoof then
          begin
            ChildNode_2 := ChildNode.FindNode('TubularDaylightingDevices');
            if Assigned(ChildNode_2) then
            begin
              sTempstr := StringValueFromPath(ChildNode_2, 'InstallConfiguration');
              if (sTempstr = '') or
                (sTempstr = 'ALL TOP ZONES') or
                (
                (sTempstr = 'ALL TOP ZONES WITHOUT WINDOWS') and
                (not bWindowsInstalled)
                ) then
              begin
                //check the zone to see if it has windows installed
                bTDDsInstalled := true;
                valr := FloatValueFromPath(ChildNode_2, 'AreaPerTDD');
                if valr <> 0 then
                begin
                  if not T_EP_Geometry(Geometry).SuppressRoofMultipliers then
                  begin
                    numTDDsAdded := aSurf.AddTDDs(valr, True);
                    if numTDDsAdded >= 32 then
                    begin
                      iTestMult := ceil(numTDDsAdded / 16);
                      if AddRoofMultiplier(iTestMult) then
                        RoofMultiplierVal := iTestMult;
                    end;
                  end;
                  numTDDsAdded := aSurf.AddTDDs(valr);
                end;
              end;
            end;

            ChildNode_2 := ChildNode.FindNode('Skylights');
            if (not bTDDsInstalled) and (Assigned(ChildNode_2)) then
            begin
              sTempstr := StringValueFromPath(ChildNode_2, 'InstallConfiguration');
              if (sTempstr = '') or
                (sTempstr = 'ALL TOP ZONES') or
                (
                (sTempstr = 'ALL TOP ZONES WITHOUT WINDOWS') and
                (not bWindowsInstalled)
                ) then
              begin
                //check the zone to see if it has windows installed
                valr := FloatValueFromPath(ChildNode_2, 'AreaFraction');
                if valr <> 0 then
                begin
                  //figure out how many skylights are to be installed
                  if not T_EP_Geometry(Geometry).SuppressRoofMultipliers then
                  begin
                    numSkyAdded := aSurf.AddSkyLight(valr, True);
                    if numSkyAdded >= 32 then
                    begin
                      iTestMult := ceil(numSkyAdded / 16);
                      if AddRoofMultiplier(iTestMult) then
                        RoofMultiplierVal := iTestMult;
                    end;
                  end;
                  numSkyAdded := aSurf.AddSkyLight(valr);
                end;
              end;
            end;
          end;

          ChildNode_2 := ChildNode.FindNode('Construction');
          if Assigned(ChildNode_2) then
          begin
            //find construction name
            Childnode_3 := ChildNode_2.FindNode('ConstructionName');
            if assigned(Childnode_3) then
            begin
              sConstructName := StringValueFromAttribute(Childnode_3, 'instance');
              if BldgConstructions.AddToBldgConstructions(sConstructName, 'Custom', aConstruct) then
              begin
                aConstruct.Typ := 'Opaque';
                aConstruct.AddCost(FloatValueFromAttribute(Childnode_3, 'CostPer', 1),
                                   'Custom');
                aConstruct.AddLayers(ChildNode_2);
              end;
              aSurf.SetConstruction(sConstructName);
            end; //if childnode_3
          end;
        end; //if normal zone
      end;
    end;
  end; //for i

  if Typ = ztNormal then
  begin
    if bTDDsInstalled then
    begin
      //add the cost item
      aNewCost := T_EP_Economics.Create;
      aNewCost.Name := Name + ':' + 'TDDs';
      aNewCost.CostValue := 1;
      aNewCost.Costing := ecCostPerEach;
      aNewCost.RefObjName := '*';
      aNewCost.CostType := etGeneral;
      aNewCost.Quantity := numTDDsAdded * ZoneMultiplier;
      CostItems.Add(aNewCost);
    end;
  end;

  //check floors
  for i := 0 to Surfaces.Count - 1 do
  begin
    aSurf := T_EP_Surface(Surfaces.Items[i]);
    if aSurf.Typ = stFloor then
    begin
      ChildNode := aNode.FindNode('Floor');
      if assigned(ChildNode) then
      begin
        bAdiabatic := BooleanValueFromPath(ChildNode, 'Adiabatic');
        if bAdiabatic then
          aSurf.MakeAdiabatic;
        //add construction

        ChildNode_2 := ChildNode.FindNode('Construction');
        if Assigned(ChildNode_2) then
        begin
          //find construction name
          Childnode_3 := ChildNode_2.FindNode('ConstructionName');
          if assigned(Childnode_3) then
          begin
            sConstructName := StringValueFromAttribute(Childnode_3, 'instance');
            if BldgConstructions.AddToBldgConstructions(sConstructName, 'Custom', aConstruct) then
            begin
              aConstruct.Typ := 'Opaque';
              aConstruct.AddCost(FloatValueFromAttribute(Childnode_3, 'CostPer', 1),
                                 'Custom');
              aConstruct.AddLayers(ChildNode_2);

            end;
            aSurf.SetConstruction(sConstructName);
          end; //if childnode_3
        end;

      end;
    end;
  end; //for i

  //add any other zone multiplier needed (for custom multipliers)
  MultBy := IntegerValueFromPath(aNode, 'ZoneMultiplier', 1);
  ZoneMultiplier := ZoneMultiplier * MultBy;

  //now add all loads -- must be done after the multipliers, so that the areas
  //are represented correctly.

  if Typ = ztNormal then
  begin
    //check zone are
    if Area = 0 then
      T_EP_PPErrorMessage.AddErrorMessage(esSevere, 'Zone area was found to be zero in zone: ' + Name);

    //Get internal gains
    Gains := aNode.FindNode('InternalGains');
    if assigned(Gains) then
    begin
      //only add internal mass if there are internal gains for the object.
      //todo: make an input for the XML for internal mass!
      InternalMass := T_EP_InternalMass.Create;
      InternalMass.ZoneName := Name;
      if assigned(aNode.FindNode('InternalMassMultiplier')) then
      begin
        InternalMass.InternalMassMultiplier := FloatValueFromPath(aNode,'InternalMassMultiplier',1.0);
        InternalMass.SurfaceArea := InternalMass.InternalMassMultiplier * Area * 2; //this is an assumed value
      end
      else
      begin
        InternalMass.SurfaceArea := Area * 2; //this is an assumed value
      end;
      aList := TList.Create;
      try
        NumPeople := 0;
        Gains.FindNodes('People', aList);
        for i := 0 to aList.Count - 1 do
        begin
          ChildNode := TXmlNode(aList[i]);

          InternalGains.People := T_EP_People.Create(false);
          InternalGains.People.Name := StringValueFromPath(ChildNode, 'PeopleName', false, 'People');
          InternalGains.People.ZoneName := Name;
          valr := FloatValueFromPath(ChildNode, 'PeopleDensity', 0.0);
          if valr <> 0 then
            InternalGains.People.DesignLevel := valr * Area / 100
          else
          begin
            //try to grab total people
            valr := FloatValueFromPath(ChildNode, 'TotalPeople', 0.0);
            InternalGains.People.DesignLevel := InternalGains.People.DesignLevel + valr;
          end;

          InternalGains.People.EndUseSubcategory :=
            StringValueFromPath(childNode, 'EndUseCategory', False, 'General');
          InternalGains.People.ScheduleName := StringValueFromPath(ChildNode, 'Schedule', false);

          //save to zone info
          NumPeople := InternalGains.People.DesignLevel;
          if (RoofMultiplierVal > 0) then
            NumPeople := NumPeople / RoofMultiplierVal;
        end;
      finally
        aList.Free;
      end;

      aList := TList.Create;
      try
        Gains.FindNodes('Lights', aList);
        for i := 0 to aList.Count - 1 do
        begin
          ChildNode := TXmlNode(aList[i]);
          InternalGains.Lighting := T_EP_Lighting.Create(false);
          InternalGains.Lighting.Name := StringValueFromPath(ChildNode, 'LightingName', false, 'Lights');
          InternalGains.Lighting.ZoneName := Name;
          InternalGains.Lighting.DesignLevel := 0.0;
          if Assigned(ChildNode.FindNode('PowerDensity')) then
          begin
            valr := FloatValueFromPath(ChildNode, 'PowerDensity', 0.0);
            InternalGains.Lighting.DesignLevel := valr * Area;
          end;
          if Assigned(ChildNode.FindNode('TotalPower')) then
          begin
            valr := FloatValueFromPath(ChildNode, 'TotalPower', 0.0);
            InternalGains.Lighting.DesignLevel := InternalGains.Lighting.DesignLevel + valr;
          end;
          if Assigned(ChildNode.FindNode('PowerPerPerson')) then
          begin
            valr := FloatValueFromPath(ChildNode, 'PowerPerPerson', 0.0);
            InternalGains.Lighting.DesignLevel := InternalGains.Lighting.DesignLevel + (valr * NumPeople);
          end;
          InternalGains.Lighting.fracRadiant := FloatValueFromPath(ChildNode, 'FractionRadiant', 0.37);
          InternalGains.Lighting.fracReturn := FloatValueFromPath(ChildNode, 'FractionReturn', 0.2);
          InternalGains.Lighting.EndUseSubcategory := StringValueFromPath(childNode, 'EndUseCategory', False, 'General');
          //can't have both schedule and hours per day.
          InternalGains.Lighting.HoursPerDay := IntegerValueFromPath(ChildNode, 'HoursPerDay', -9999);
          InternalGains.Lighting.ScheduleName := StringValueFromPath(ChildNode, 'Schedule', False, 'BLDG_LIGHT_SCH');
          InternalGains.Lighting.SchFileColumn := IntegerValueFromPath(ChildNode, 'SchFileColumn', -9999);
          InternalGains.Lighting.SchFileRowSkip := IntegerValueFromPath(ChildNode, 'SchFileRowSkip', -9999);
        end;
      finally
        aList.Free;
      end;

      aList := TList.Create;
      try
        Gains.FindNodes('Equipment', aList);
        for i := 0 to aList.Count - 1 do
        begin
          ChildNode := TXmlNode(aList[i]);

          anEquip := InternalGains.EquipmentList.AddNew(false);
          anEquip.Name := StringValueFromPath(ChildNode, 'EquipmentName', false, 'PlugMisc');
          anEquip.ZoneName := Name;
          if SameText(StringValueFromPath(ChildNode, 'EquipmentType'), 'Gas') then
          begin
            anEquip.EquipmentType := etGas;
          end
          else
          begin
            anEquip.EquipmentType := etElectric;
          end;
          if assigned(ChildNode.FindNode('PowerDensity')) then
          begin
            valr := FloatValueFromPath(ChildNode, 'PowerDensity', 0.0);
            anEquip.DesignLevel := valr * Area;
          end
          else if assigned(ChildNode.FindNode('TotalPower')) then
          begin
            anEquip.DesignLevel := FloatValueFromPath(ChildNode, 'TotalPower', 0.0);
            if (RoofMultiplierVal > 0) then
               anEquip.DesignLevel :=  anEquip.DesignLevel / RoofMultiplierVal;
          end
          else if assigned(ChildNode.FindNode('PowerPerPerson')) then
          begin
            valr := FloatValueFromPath(ChildNode, 'PowerPerPerson', 0.0);
            anEquip.DesignLevel := valr * NumPeople;
          end;
    
          anEquip.fracRadiant := FloatValueFromPath(ChildNode, 'RadiantFraction', 0.5);
          anEquip.fracLatent := FloatValueFromPath(ChildNode, 'LatentFraction', 0.0);
          anEquip.fracLost  := FloatValueFromPath(ChildNode, 'LostFraction', 0.0);
          anEquip.EndUseSubcategory :=
            StringValueFromPath(childNode, 'EndUseCategory', False, 'General');
          anEquip.ScheduleName := StringValueFromPath(ChildNode, 'Schedule', false, 'BLDG_EQUIP_SCH');
          anEquip.SchFileColumn := IntegerValueFromPath(ChildNode, 'SchFileColumn', -9999);
          anEquip.SchFileRowSkip := IntegerValueFromPath(ChildNode, 'SchFileRowSkip', -9999);
        end;
      finally
        aList.Free;
      end;

      //add specific gains to the zone
      ChildNode := Gains.FindNode('Elevators');
      if Assigned(ChildNode) then
      begin
        numCount := IntegerValueFromPath(ChildNode, 'NumberOfElevators', 0);
        if numCount > 0 then
        begin
          anEquip := InternalGains.EquipmentList.AddNew(false);
          anEquip.Name := 'Elevators';
          anEquip.ZoneName := Self.Name;
          anEquip.EquipmentType := etElectric;
          if FloatValueFromPath(ChildNode, 'TotalPower') <> 0 then
          begin
            anEquip.DesignLevel := numCount * FloatValueFromPath(ChildNode, 'TotalPower') / ZoneMultiplier;
          end
          else //assume entered HP, Motor Efficiency
          begin
            valr := FloatValueFromPath(ChildNode, 'MotorPower');
            valr2 := FloatValueFromPath(ChildNode, 'MotorEfficiency');
            if valr2 <> 0 then
              anEquip.DesignLevel := numCount * valr / valr2 / ZoneMultiplier
            else
              anEquip.DesignLevel := numCount * valr / ZoneMultiplier;
            ;
          end;

          anEquip.fracRadiant := 0.5;
          anEquip.fracLatent := 0.0;
          anEquip.fracLost   := 0.0;
          anEquip.EndUseSubcategory := 'Elevators';
          anEquip.ScheduleName := StringValueFromPath(ChildNode, 'Schedule', false, 'BLDG_ELEVATORS');
          //todo 1: add cost
        end; //if numcount > 0
      end;  //elevators
    end; //if gains

    //Get external gains
    Gains := aNode.FindNode('ExternalGains');
    if assigned(Gains) then
    begin
      aList := TList.Create;
      try
        NumPeopleExt := 0;
        Gains.FindNodes('People', aList);
        for i := 0 to aList.Count - 1 do
        begin
          ChildNode := TXmlNode(aList[i]);

          ExternalGains.People := T_EP_People.Create(True);
          ExternalGains.People.Name := StringValueFromPath(ChildNode, 'PeopleName', false, 'ExtPeople');
          ExternalGains.People.ZoneName := Name;
          valr := FloatValueFromPath(ChildNode, 'PeopleDensity', 0.0);
          ExternalGains.People.DesignLevel := 0.0;
          if valr <> 0 then
            ExternalGains.People.DesignLevel := valr * Area / 100
          else
          begin
            //try to grab total people
            valr := FloatValueFromPath(ChildNode, 'TotalPeople', 0.0);
            ExternalGains.People.DesignLevel := valr;
          end;

          ExternalGains.People.EndUseSubcategory :=
            StringValueFromPath(childNode, 'EndUseCategory', False, 'General');
          ExternalGains.People.ScheduleName := StringValueFromPath(ChildNode, 'Schedule', false);

          //save to zone info
          NumPeopleExt := ExternalGains.People.DesignLevel;
        end;
      finally
        aList.Free;
      end;

      aList := TList.Create;
      try
        Gains.FindNodes('Lights', aList);
        for i := 0 to aList.Count - 1 do
        begin
          ChildNode := TXmlNode(aList[i]);
          
          ExternalGains.Lighting := T_EP_Lighting.Create(True);
          ExternalGains.Lighting.Name := StringValueFromPath(ChildNode, 'LightingName', false, 'ExtLights');
          ExternalGains.Lighting.ZoneName := Name;
          valr := FloatValueFromPath(ChildNode, 'PowerDensity', 0.0);
          ExternalGains.Lighting.DesignLevel := valr * Area;
          ExternalGains.Lighting.fracRadiant := FloatValueFromPath(ChildNode, 'FractionRadiant', 0.37);
          ExternalGains.Lighting.fracReturn := FloatValueFromPath(ChildNode, 'FractionReturn', 0.2);
          ExternalGains.Lighting.EndUseSubcategory :=
            StringValueFromPath(childNode, 'EndUseCategory', False, 'General');
          //can't have both schedule and hours per day.
          ExternalGains.Lighting.HoursPerDay :=
              IntegerValueFromPath(ChildNode, 'HoursPerDay', -9999);
          ExternalGains.Lighting.ScheduleName :=
              StringValueFromPath(ChildNode, 'Schedule', false, 'AstroClock');
        end;
      finally
        aList.Free;
      end;

      aList := TList.Create;
      try
        Gains.FindNodes('Equipment', aList);
        for i := 0 to aList.Count - 1 do
        begin
          ChildNode := TXmlNode(aList[i]);
          anEquip := ExternalGains.EquipmentList.AddNew(True);
          anEquip.Name := StringValueFromPath(ChildNode, 'EquipmentName', false, 'ExtPlugMisc');
          anEquip.ZoneName := Name;
          if StringValueFromPath(ChildNode, 'EquipmentType') = 'Gas' then
            anEquip.EquipmentType := etGas
          else
            anEquip.EquipmentType := etElectric;
          valr := FloatValueFromPath(ChildNode, 'PowerDensity', 0.0);
          if valr <> 0 then
            anEquip.DesignLevel := valr * Area
          else //try grabbing it by total power
          begin
            anEquip.DesignLevel := FloatValueFromPath(ChildNode, 'TotalPower', 0.0);
            if (RoofMultiplierVal > 0) then
               anEquip.DesignLevel :=  anEquip.DesignLevel / RoofMultiplierVal;
          end;

          anEquip.fracRadiant := FloatValueFromPath(ChildNode, 'RadiantFraction', 0.5);
          anEquip.fracLatent := FloatValueFromPath(ChildNode, 'LatentFraction', 0.0);
          anEquip.fracLost   := FloatValueFromPath(ChildNode, 'LostFraction', 0.0);
          anEquip.EndUseSubcategory :=
            StringValueFromPath(childNode, 'EndUseCategory', False, 'General');
          anEquip.ScheduleName := StringValueFromPath(ChildNode, 'Schedule', false, 'BLDG_EQUIP_SCH');
        end;
      finally
        aList.Free;
      end;

      //add specific gains to the zone
      ChildNode := Gains.FindNode('Elevators');
      if Assigned(ChildNode) then
      begin
        numCount := IntegerValueFromPath(ChildNode, 'NumberOfElevators', 0);
        if numCount > 0 then
        begin
          anEquip := ExternalGains.EquipmentList.AddNew(True);
          anEquip.Name := 'Elevators';
          anEquip.ZoneName := Self.Name;
          anEquip.EquipmentType := etElectric;
          if FloatValueFromPath(ChildNode, 'TotalPower') <> 0 then
          begin
            anEquip.DesignLevel := numCount * FloatValueFromPath(ChildNode, 'TotalPower') / ZoneMultiplier;
          end
          else //assume entered HP, Motor Efficiency
          begin
            valr := FloatValueFromPath(ChildNode, 'MotorPower');
            valr2 := FloatValueFromPath(ChildNode, 'MotorEfficiency');
            if valr2 <> 0 then
              anEquip.DesignLevel := numCount * valr / valr2 / ZoneMultiplier
            else
              anEquip.DesignLevel := numCount * valr / ZoneMultiplier;
          end;

          anEquip.fracRadiant := 0.5;
          anEquip.fracLatent := 0.0;
          anEquip.fracLost   := 0.0;
          anEquip.EndUseSubcategory := 'Elevators';
          anEquip.ScheduleName := StringValueFromPath(ChildNode, 'Schedule', false, 'BLDG_ELEVATORS');
          //todo 1: add cost
        end; //if numcount > 0
      end;  //elevators
    end; //if gains

    ChildNode := aNode.FindNode('Daylighting');
    if assigned(ChildNode) then
    begin
      pnt1 := T_EP_Point.Create;
      pnt2 := T_EP_Point.Create;
      numDL := IntegerValueFromPath(ChildNode, 'NumberOfSensors');
      if numDL = 0 then numDL := 1;
      try
        //check if there are windows
        bWindowsInstalled := false;
        for i := 0 to Surfaces.Count - 1 do
        begin
          aSurf := T_EP_Surface(Surfaces.Items[i]);
          // todo : DLM, this counts doors as windows
          if aSurf.SubSurfaces.Count > 0 then bWindowsInstalled := true;
        end;

        if bWindowsInstalled or assigned(ChildNode) then
        begin
          //find the floor
          for i := 0 to Surfaces.Count - 1 do
          begin
            if T_EP_Surface(Surfaces[i]).Typ = stFloor then
            begin
              flrSurf := T_EP_Surface(Surfaces[i]);
            end;
          end;

          bCustomSensor := false;
          sensorNode := childNode.FindNode('Sensor_1');
          if assigned(sensorNode) then
          begin
            bCustomSensor := true;
            pnt1.X1 := FloatValueFromPath(sensorNode, 'x');
            pnt1.Y1 := FloatValueFromPath(sensorNode, 'y');
            pnt1.Z1 := FloatValueFromPath(sensorNode, 'z');
            percCont1 := FloatValueFromPath(sensorNode, 'FractionOfZone') * 100;

            //check to make sure it is in the zone
            if not InsidePolygon(flrSurf.Verts, pnt1.X1, pnt1.Y1) then
            begin
              T_EP_PPErrorMessage.AddErrorMessage(esWarning, 'Custom position of daylight setpoint 1 falls ' +
                'outside of zone.');
            end;

          end;

          bSensor2 := false;
          sensorNode := childNode.FindNode('Sensor_2');
          if assigned(sensorNode) then
          begin
            bCustomSensor := true;
            bSensor2 := true;
            pnt2.X1 := FloatValueFromPath(sensorNode, 'x');
            pnt2.Y1 := FloatValueFromPath(sensorNode, 'y');
            pnt2.Z1 := FloatValueFromPath(sensorNode, 'z');
            percCont2 := FloatValueFromPath(sensorNode, 'FractionOfZone') * 100;

            //check to make sure it is in the zone
            if not InsidePolygon(flrSurf.Verts, pnt2.X1, pnt2.Y1) then
            begin
              T_EP_PPErrorMessage.AddErrorMessage(esWarning, 'Custom position of daylight setpoint 2 falls ' +
                'outside of zone.');
            end;
          end;

          if bCustomSensor then
          begin
            if not bSensor2 then numDL := 1;
          end
          else
          begin
            numDL := GetDaylightingPositions(numDL, pnt1, pnt2, percCont1, percCont2);
          end;

          Daylighting := T_EP_Daylighting.Create;
          Daylighting.ZoneName := Name;
          Daylighting.ControlType := StringValueFromPath(ChildNode, 'ControlType', True, 'None');
          Daylighting.Setpoint := FloatValueFromPath(ChildNode, 'Setpoint', 0.0);
          Daylighting.NumberOfSteps := IntegerValueFromPath(ChildNode, 'NumberOfSteps', 3);
          Daylighting.MinimumInputPowerFraction :=
            FloatValueFromPath(ChildNode, 'MinimumInputPowerFraction', 0.3);
          Daylighting.MinimumLightOutputFraction :=
            FloatValueFromPath(ChildNode, 'MinimumLightOutputFraction', 0.2);

          //find the zone "z" value.
          Daylighting.AddReferencePoint(1, pnt1.X1, pnt1.Y1, pnt1.Z1, percCont1);
          if numDL = 2 then
            Daylighting.AddReferencePoint(2, pnt2.X1, pnt2.Y1, pnt2.Z1, percCont2);
        end;

      finally
        pnt1.Free;
        pnt2.Free;
      end;
    end;
  end; //if normal zone

  //go through all of the surfaces and find if there is infiltration associated
  //with them
  infil_DesignLevel := 0;
  infil_FlowPerExtWallArea := 0;
  infil_FlowPerExtArea := 0;
  for iSurf := 0 to Surfaces.Count - 1 do
  begin
    aSurf := T_EP_Surface(Surfaces[iSurf]);
    sConstructName := aSurf.Construction;
    aConst := BldgConstructions.GetConstruction(sConstructName);
    if Assigned(aConst) then
      if aConst.InfiltrationPerArea <> 0 then
      begin
        infil_DesignLevel := infil_DesignLevel + aConst.InfiltrationPerArea * aSurf.SurfaceArea;
      end;
  end;

  //see if there is other infiltration to zone
  ChildNode := aNode.FindNode('Infiltration');
  if assigned(ChildNode) then
  begin
    valr := FloatValueFromPath(ChildNode, 'Rate', 0.0);   //in ACH
    infil_DesignLevel := infil_DesignLevel + (valr * AirVolume / 3600); // volume times ACH times hour/seconds conversion
    infil_FlowPerExtWallArea := FloatValueFromPath(Childnode, 'FlowPerExtWallArea', 0.0); //in (m^3/s)/m^2
    infil_FlowPerExtArea :=  FloatValueFromPath(Childnode, 'FlowPerExtArea', 0.0)
  end;

  if (infil_DesignLevel <> 0) or (infil_FlowPerExtWallArea <> 0) or (infil_FlowPerExtArea <> 0) then
  begin
    Infiltration := T_EP_Infiltration.Create;
    Infiltration.ZoneName := Name;
    Infiltration.DesignLevel := infil_DesignLevel;
    Infiltration.FlowPerExtWallArea := infil_FlowPerExtWallArea;
    Infiltration.FlowPerExtArea := infil_FlowPerExtArea;
    Infiltration.ScheduleName := StringValueFromPath(ChildNode,'Schedule',False,'INFIL_SCH');
  end;

  //set flag to tell other zones that the zone has been processed
  ZoneIntGainsProcessed := true;
end;



procedure T_EP_Zone.GetWallTurns;
var
  iTurns: Integer;
  aSurf1, aSurf2: T_EP_Surface;
  iSurf: Integer;
  bFirst: Boolean;
begin
  iTurns := 1;
  bFirst := True;
  for iSurf := 0 to Surfaces.count - 1 do
  begin
    if T_EP_Surface(Surfaces[iSurf]).Typ = stWall then
    begin
      if bFirst then
      begin
        //initialize varialbe
        bFirst := False;
        aSurf1 := T_EP_Surface(Surfaces[iSurf]);
        continue;
      end;
      aSurf2 := T_EP_Surface(Surfaces[iSurf]);

      if aSurf1.Angle <> aSurf2.Angle then Inc(iTurns);
      aSurf1 := aSurf2;
    end;
  end;

  if iTurns = 0 then
    WallTurns := Surfaces.Count
  else
    WallTurns := iTurns;

end;

// this procedure checks that the zone is fully enclosed, throwing an error if it is not.
// the check is currently done by asserting that each edge of each surface has exactly one
// matching edge on another surface in the zone, the counterclockwise convention is
// enforced to ensure that both surfaces are point out from the zone
procedure T_EP_Zone.CheckEnclosed;
var
  iSurf, iVert, iEdge1, iEdge2 : integer;
  surfNormal: T_EP_Vector;
  aSurf: T_EP_Surface;
  aVerts: T_EP_Verts;
  aSurfEdge1, aSurfEdge2: T_SurfaceEdge;
  aSurfEdgeList: T_SurfaceEdgeList;
  foundMatch: boolean;
  foundMatchNum, missingMatchNum: integer;
begin

  // create list of all edges
  aSurfEdgeList := T_SurfaceEdgeList.create;
  for iSurf := 0 to Surfaces.count - 1 do
  begin
    aSurf := T_EP_Surface(Surfaces[iSurf]);
    aVerts := aSurf.Verts;
    surfNormal := VertsSurfaceNormal(aVerts);

    // loop over all verts
    for iVert := 0 to aVerts.count - 2 do
    begin
      aSurfEdgeList.AddSurfaceEdge(T_EP_Vector(aVerts[iVert]), T_EP_Vector(aVerts[iVert+1]), surfNormal, aSurf.Name);
    end;
    // add last edge
    aSurfEdgeList.AddSurfaceEdge(T_EP_Vector(aVerts[aVerts.count-1]), T_EP_Vector(aVerts[0]), surfNormal, aSurf.Name);
  end;

  // double loop over all edges
  foundMatchNum := 0;
  missingMatchNum := 0;
  for iEdge1 := 0 to aSurfEdgeList.count-2 do
  begin
    aSurfEdge1 := T_SurfaceEdge(aSurfEdgeList[iEdge1]);

    // if already matched, continue
    if aSurfEdge1.MatchIndex >= 0 then
      continue;

    foundMatch := False;
    for iEdge2 := iEdge1+1 to aSurfEdgeList.count-1 do
    begin
      aSurfEdge2 := T_SurfaceEdge(aSurfEdgeList[iEdge2]);

      // if already matched continue
      if aSurfEdge2.MatchIndex >= 0 then
        continue;

      // if these edges are the same, make the match then break
      if aSurfEdge1.isEqual(aSurfEdge2) then
      begin
          aSurfEdge1.MatchIndex := iEdge2;
          aSurfEdge2.MatchIndex := iEdge1;
          foundMatch := True;
          break;
      end;
    end;

    if foundMatch then
    begin
      // found a match, increment counter by 2
      foundMatchNum := foundMatchNum + 2;
    end
    else
    begin
      // couldn't find a match, increment counter
      missingMatchNum := missingMatchNum + 1;

      // comment out for now
      //writeln('Error: Zone: ' + Name + ' Surf: ' + aSurfEdge1.SurfName + ' missing match to edge ' + inttostr(iEdge1) + ' of ' + inttostr(aSurfEdgeList.count));
      //writeln('  [V1 = ' + floattostr(aSurfEdge1.V1.i) + ' ' + floattostr(aSurfEdge1.V1.j) + ' ' + floattostr(aSurfEdge1.V1.k) + ']');
      //writeln('  [V2 = ' + floattostr(aSurfEdge1.V2.i) + ' ' + floattostr(aSurfEdge1.V2.j) + ' ' + floattostr(aSurfEdge1.V2.k) + ']');
    end;

  end;

  // comment out for now
  //if missingMatchNum > 0 then
  //  writeln('Error: Zone: ' + Name + ' has ' + inttostr(missingMatchNum) + ' missing edges');

end;



function T_EP_Zone.GetDaylightingPositions(NumPoints: Integer;
  var DLpnt1, DLpnt2: T_EP_Point;
  var PercCont1, PercCont2: Double): integer;
//returns the number of installed daylighting sensors
var
  aSurf: T_EP_Surface;
  i: Integer;
  xCent: double;
  yCent: double;
  ZCent: double;
  prinSurf: T_EP_Surface;
  bWindowsFound: boolean;
  flrSurf, clgSurf: T_EP_Surface;
  bOnlyOne: Boolean;
  iResult: Integer;
begin
  bOnlyOne := false;
  iResult := 0;
  if NumPoints <= 1 then bOnlyOne := true;

  if NumPoints <= 1 then
  begin
    //get surface
    for i := 0 to Surfaces.Count - 1 do
    begin
      clgSurf := T_EP_Surface(Surfaces.Items[i]);

      if (clgSurf.Typ = stCeiling) then
      begin
        //find the placement of the sensor
        clgSurf.CenterPoint(xCent, yCent, ZCent);
        if clgSurf.RoofFen then
        begin
          if Odd(clgSurf.RoofFenCntRows) and (clgSurf.RoofFenCntRows <> 1) then
            yCent := yCent - (clgSurf.RoofFenY / 2);
          if Odd(clgSurf.RoofFenCntCols) and (clgSurf.RoofFenCntCols <> 1) then
            xCent := xCent - (clgSurf.RoofFenX / 2);
        end;
      end;
    end;

    for i := 0 to Surfaces.Count - 1 do
    begin
      flrSurf := T_EP_Surface(Surfaces.Items[i]);

      if (flrSurf.Typ = stFloor) then
      begin
        // DLM: assuming all floor verts have same z level
        ZCent := T_EP_Vector(flrSurf.Verts[0]).k + 0.762;
      end;
    end;


    DLpnt1.X1 := xCent;
    DLpnt1.Y1 := yCent;
    DLpnt1.Z1 := ZCent;
    iResult := 1;
  end
  else //2 points
  begin
    //find the ceiling
    for i := 0 to Surfaces.Count - 1 do
    begin
      if T_EP_Surface(Surfaces[i]).Typ = stCeiling then
      begin
        clgSurf := T_EP_Surface(Surfaces[i]);
      end;
    end;

    //find the floor
    for i := 0 to Surfaces.Count - 1 do
    begin
      if T_EP_Surface(Surfaces[i]).Typ = stFloor then
      begin
        flrSurf := T_EP_Surface(Surfaces[i]);
      end;
    end;

    //find the principle wall.  This is the wall with the biggest window area

    //default to first wall
    bWindowsFound := false;
    for i := 0 to Surfaces.Count - 1 do
    begin
      prinSurf := T_EP_Surface(Surfaces.Items[i]);
      if prinSurf.Typ = stWall then
      begin
        if prinSurf.WindowArea > 0 then
          bWindowsFound := true;
        break;
      end;
    end;

    for i := 0 to Surfaces.Count - 1 do
    begin
      aSurf := T_EP_Surface(Surfaces.Items[i]);
      if aSurf.Typ = stWall then
      begin
        if aSurf.WindowArea > prinSurf.WindowArea then
        begin
          prinSurf := aSurf;
          bWindowsFound := true;
        end;
      end;
    end;

    if bWindowsFound then
    begin
      //set the first daylighting setpoint 7.5 ft (2.286 m) from the window
      DLpnt1.X1 := T_EP_Vector(prinSurf.Verts[0]).i +
        0.5 * prinSurf.WallLength * Cos(prinSurf.angle) -
        Sin(prinSurf.angle) * 2.286;
      DLpnt1.Y1 := T_EP_Vector(prinSurf.Verts[0]).j +
        0.5 * prinSurf.WallLength * Sin(prinSurf.angle) +
        Cos(prinSurf.angle) * 2.286;
      DLpnt1.Z1 := 0.762;
    end;

    //make sure that it is in the zone
    if (not InsidePolygon(flrSurf.Verts, DLpnt1.X1, DLpnt1.Y1)) or
      (not bWindowsFound) then
    begin
      //set to the center of the zone - and only use one sensor
      bOnlyOne := true;
      iResult := 1;
      clgSurf.CenterPoint(DLpnt1.X1, DLpnt1.Y1, ZCent);
      DLpnt1.Z1 := 0.762;

      if clgSurf.RoofFen then
      begin
        if Odd(clgSurf.RoofFenCntRows) and (clgSurf.RoofFenCntRows <> 1) then
          DLpnt1.Y1 := DLpnt1.Y1 - (clgSurf.RoofFenY / 2);
        if Odd(clgSurf.RoofFenCntCols) and (clgSurf.RoofFenCntCols <> 1) then
          DLpnt1.X1 := DLpnt1.X1 - (clgSurf.RoofFenX / 2);
      end;
    end;

    if not bOnlyOne then
    begin
      iResult := 2;
      //go 15 feet away from window to other end of the zone.
      //Currently limited to only rectangular zones.
      //Make sure that it is still in the zone.
      //GetAreaFromPrincSurf(4.572, prinSurf);

      flrSurf.CenterPoint(DLpnt2.X1, DLpnt2.Y1, Zcent);
      DLpnt2.Z1 := 0.762;

      //check the distance between the two points.  If less than 7.5 feet, then
      //remove the second point
      if DistanceBtwnPoints(DLpnt1, DLpnt2) < 2.286 then
      begin
        iResult := 1;
        bOnlyOne := true;
      end;
    end;
  end;

  if iResult = 1 then
  begin
    PercCont1 := 100;
  end
  else
  begin
    //find the areas for each daylight sensor

    PercCont1 := 50;
    PercCont2 := 50;
  end;

  result := iResult;
end; //

function T_EP_Zone.GetAreaFromPrincSurf(Distance: double;
  princSurf: T_EP_Surface): double;
var
  dResult: double;
  iSurf: Integer;
  iStart: Integer;
  iVert: Integer;
  aSurf: T_EP_Surface;
begin
  dResult := 0;

  if WallTurns = 4 then
  begin
    //create a new object.
    //look at the floor
    iStart := -1;
    for iSurf := 0 to Surfaces.Count - 1 do
    begin
      if T_EP_Surface(Surfaces[iSurf]).Name = princSurf.Name then
      begin
        iStart := iSurf;
        break;
      end;
    end;

    if iStart <> -1 then
    begin
      for iSurf := 0 to Surfaces.Count - 1 do
      begin
        aSurf := T_EP_Surface(Surfaces[iSurf]);
        if aSurf.Typ = stFloor then
        begin
          for iVert := 0 to aSurf.Verts.Count - 1 do
          begin
            //writeln(T_EP_Vector(aSurf.Verts[iVert]).i,'  ',
            //        T_EP_Vector(aSurf.Verts[iVert]).j);
          end;
        end
      end;
    end;
  end;

  result := dResult;
end;





end.
