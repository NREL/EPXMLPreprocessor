////////////////////////////////////////////////////////////////////////////////
//                                                                            //
// Copyright (c) 2008-2020 Alliance for Sustainable Energy.                   //
// All rights reserved.                                                       //
//                                                                            // 
////////////////////////////////////////////////////////////////////////////////

unit EnergyPlusEndUseComponents;
// includes Zone Equipment and Process Loads

// may be able to get rid of Initialize on all classes here

interface

uses
  SysUtils,
  Contnrs,
  NativeXml,
  Globals,
  Classes,
  EnergyPlusCore,
  EnergyPlusSystemComponents,
  EnergyPlusSystems,
  GlobalFuncs,
  EnergyPlusSettings,
  EnergyPlusZones;

type
  TEndUseComponent = class(THVACComponent)
  protected
    procedure SetZone(ZoneParameter: T_EP_Zone); virtual; abstract;
  public
    ZoneValue: T_EP_Zone;
    property Zone: T_EP_Zone read ZoneValue write SetZone;
    procedure Finalize; override;
  end;

type
  T_EP_DirectAir = class(TEndUseComponent)
  protected
    procedure SetZone(ZoneParameter: T_EP_Zone); override;
  public
    RunAsNeutralDOAS: boolean;
    TempSetpoint: double;
    HUMRATSetpoint: double;
    airFlowRate: string;
    unitary_control: boolean;
    multizone: boolean;
    MinSupplyAirTemp: double;
    MaxSupplyAirTemp: double;
    procedure ToIDF; override;
    constructor Create; reintroduce;
    procedure Finalize; override;
  end;

type
  T_EP_DualDuctOutdoorAir = class(TEndUseComponent)
  protected
    procedure SetZone(ZoneParameter: T_EP_Zone); override;
  public
    RecircDemandInletNode: string;
    RecircBranch: boolean;
    procedure ToIDF; override;
    constructor Create; reintroduce;
    procedure Finalize; override;
  end;

type
  T_EP_SingleDuctVariableFlow = class(TEndUseComponent)
  protected
    ReheatCoilValue: string;
    procedure SetZone(ZoneParameter: T_EP_Zone); override;
    procedure SetReheatCoil(ReheatCoilParameter: string);
  public
    MinFlowFraction: double;
    MinFlowFractionSchedule: string;
    MinAirFlowRate: double;
    ReheatCoilEfficiency: double;
    HotWaterReheatCoilObject: T_EP_Coil;
    // sum of all required total air flow, only set if any total air flow components
    // are set.  Otherwise defaults to autosize for heating/cooling
    MaxAirFlowRate: double;
    // components of total air flow, storage variables
    TotalAirPerArea: double;
    TotalAirPerPerson: double;
    TotalAirPerZone: double;
    TotalAirPerACH: double;
    LeakageFraction: double;
    // on/off control of the terminal box
    AvailSchedule: string;
    DamperHeatingAction: string;
    SuppressOA: boolean;
    SuppressDesignSpecOA: boolean;
    CoilAvailSch: string;
    procedure SetMaxAirFlowComponents(MaxAirFlowNode: TXMLNode);
    property ReheatCoilType: string read ReheatCoilValue write SetReheatCoil;
    procedure ToIDF; override;
    constructor Create; reintroduce;
    procedure Finalize; override;
  end;

type
  T_EP_FanPoweredTerminal = class(TEndUseComponent)
  protected
    ReheatCoilValue: string;
    procedure SetZone(ZoneParameter: T_EP_Zone); override;
    procedure SetReheatCoil(ReheatCoilParameter: string);
  public
    ReheatCoilEfficiency: real;
    HotWaterReheatCoilObject: T_EP_Coil;
    FanPressureDrop: double;
    FanEfficiency: double;
    FanOperationSchedule: string;
    property ReheatCoilType: string read ReheatCoilValue write SetReheatCoil;
    procedure ToIDF; override;
    constructor Create; reintroduce;
    procedure Finalize; override;
  end;

type
  T_EP_ExhaustFan = class(TEndUseComponent)
  protected
    HeatRecoveryValue: boolean;
    procedure SetZone(ZoneParameter: T_EP_Zone); override;
  public
    ScheduleName: string;
    NumSources: integer;
    DrawFromInfiltrationFraction: double;
    MakeupTransferZoneList: TStringList;
    MakeupTransferZoneFractions: array of double;
    MakeupTransferFlowRates: array of double;
    FanEfficiency: double;
    FanPressureDrop: double;
    ExhaustFlowPerArea: double;
    ExhaustFlowRate: double;
    ExhaustFlowACH: double;
    OverrideOA: boolean;
    ExhaustFanID: integer;
    function TotalMakeupTransferFlowRate: double ;
    procedure Finalize; override;
    procedure ToIDF; override;
    function DrawFromInfiltrationRate: double;
    constructor Create; reintroduce;
    function MaxExhaustFlowRate: double;
  end;

type
  T_EP_BaseboardHeaterConvectiveWater = class(TEndUseComponent)
  protected
    procedure SetZone(ZoneParameter: T_EP_Zone); override;
  public
    procedure ToIDF; override;
    constructor Create; reintroduce;
    procedure Finalize; override;
  end;

type
  T_EP_BaseboardHeaterConvectiveElectric = class(TEndUseComponent)
  protected
    procedure SetZone(ZoneParameter: T_EP_Zone); override;
  public
    constructor Create; reintroduce;
    procedure ToIDF; override;
    procedure Finalize; override;
  end;

type
  T_EP_LowTempRadiantVariableFlow = class(TEndUseComponent)
  protected
    procedure SetZone(ZoneParameter: T_EP_Zone); override;
  public
    LowTempRadiantSurfaceGroup: T_EP_LowTempRadiantSurfaceGroup;
    UserProvidedName: string;
    HotSupplyInletNode: string;
    HotSupplyOutletNode: string;
    ColdSupplyInletNode: string;
    ColdSupplyOutletNode: string;
    coldWaterComponent: TSystemComponent;
    hotWaterComponent: TSystemComponent;
    AvailabilitySchedule: string;
    TubingInsideDiameter: double;
    TubingLength: double;
    TempControlType: string;
    MaxHotWaterFlow: double;
    HeatingThrottlingRange: double;
    HeatingTempSchedule: string;
    MaxChilledWaterFlow: double;
    CoolingThrottlingRange: double;
    CoolingTempSchedule: string;
    CondensationControlType: string;
    CondensationControlDewpointOffset: double; 
    constructor Create; reintroduce;
    procedure ToIDF; override;
    procedure Finalize; override;
  end;

type
  T_EP_WindowAC = class(TEndUseComponent)
  protected
    procedure SetZone(ZoneParameter: T_EP_Zone); override;
  public
    ControlMode: string;
    COP: double;
    FanEfficiency: double;
    FanPressureDrop: double;
    DataSetKey: string;
    SuppressLatDeg: boolean;
    EvapCondEff: double;
    procedure ToIDF; override;
    constructor Create; reintroduce;
    procedure Finalize; override;
  end;

type
  T_EP_PTAC = class(TEndUseComponent)
  protected
    HeatCoilTypeValue: string;
    procedure setHeatCoil(CoilParameter: string);
    procedure SetZone(ZoneParameter: T_EP_Zone); override;
  public
    HWcoil: T_EP_Coil;
    Typ: string;
    FanType: string;
    FanEfficiency: double;
    FanPressureDrop: double;
    CoolCOP: double;
    HeatCoilEfficiency: double;
    ControlMode: string;
    SuppressOA: boolean;
    DataSetKey: string;
    SuppressLatDeg: boolean;
    EvapCondEff: double;
    AvailSch: string;
    procedure ToIDF; override;
    constructor Create; reintroduce;
    property HeatCoilType: string read HeatCoilTypeValue write SetHeatCoil;
    procedure Finalize; override;
  end;

type
  T_EP_PTHP = class(TEndUseComponent)
  protected
    procedure SetZone(ZoneParameter: T_EP_Zone); override;
  public
    Typ: string;
    FanType: string;
    FanEfficiency: double;
    FanPressureDrop: double;
    CoolCOP: double;
    HeatCOP: double;
    ControlMode: string;
    DataSetKey: string;
    SuppressLatDeg: boolean;
    EvapCondEff: double;
    constructor Create; reintroduce;
    procedure ToIDF; override;
    procedure Finalize; override;
  end;

type
  T_EP_HeatPumpWaterToAir = class(TEndUseComponent)
  protected
    procedure SetZone(ZoneParameter: T_EP_Zone); override;
  public
    CoolCOP: double;
    HeatCOP: double;
    FanEfficiency: double;
    FanPressureDrop: double;
    FanMotorEfficiency: double;
    FanPlacement: string;
    FanScheduleName: string;
    SupHeatCoilType: string;
    SupHeatCoilEfficiency: double;
    SuppressOA: boolean;
    DataSetKey: string;
    FanControl: string;
    LiqSysCondName: string;
    constructor Create; reintroduce;
    procedure ToIDF; override;
    procedure Finalize; override;
  end;

type
  T_EP_OutdoorAirUnit = class(TEndUseComponent)
  protected
    EquipList: TObjectList;
    procedure SetZone(ZoneParameter: T_EP_Zone); override;
  public
    OaRate: double;
    OaSch: string;
    CtrlType: string;
    HighAirTempSch: string;
    LowAirTempSch: string;
    SupFanOutNode: string;
    HasExhFan: boolean;
    ExhFan: T_EP_Fan;
    ERV: T_EP_HeatRecoveryAirToAir;
    AvailSch: string;
    function AddEquip(ChildComponent: THVACComponent): THVACComponent;
    constructor Create; reintroduce;
    procedure ToIDF; override;
    procedure Finalize; override;
  end;

type
  T_EP_UnitHeater = class(TEndUseComponent)
  protected
    CoilTypeValue: string;
    FanTypeValue: string;
    procedure SetZone(ZoneParameter: T_EP_Zone); override;
    procedure setCoil(CoilParameter: string);
    procedure setFan(FanParameter: string);
  public
    HWcoil: T_EP_Coil;
    fan: T_EP_Fan;
    CoilEfficiency: double;
    FanEfficiency: double;
    FanPressureDrop: double;
    property CoilType: string read CoilTypeValue write SetCoil;
    property FanType: string read FanTypeValue write SetFan;
    procedure ToIDF; override;
    constructor Create; reintroduce;
    procedure Finalize; override;
  end;

type
  T_EP_UnitVentilator = class(TEndUseComponent)
  protected
    // CoolCoilTypeValue : string;
    HeatCoilTypeValue: string;
    FanTypeValue: string;
    procedure SetZone(ZoneParameter: T_EP_Zone); override;
    procedure setHeatCoil(CoilParameter: string);
    procedure setFan(FanParameter: string);
  public
    coolingAvail: boolean; // for future add of cooling capability
    HWcoil: T_EP_Coil;
    coolingCoil: T_EP_Coil;
    CoilOption: string;
    fan: T_EP_Fan;
    HeatCoilEfficiency: double;
    FanEfficiency: double;
    FanPressureDrop: double;
    MotorizedDamper: boolean;
    AvailSch: string;
    OaCtrlType: string;
    // Property CoolCoilType: string read CoolCoilTypeValue write SetCoolCoil;
    property HeatCoilType: string read HeatCoilTypeValue write SetHeatCoil;
    property FanType: string read FanTypeValue write SetFan;
    procedure ToIDF; override;
    constructor Create; reintroduce;
    procedure Finalize; override;
  end;

type
  T_EP_FanCoil = class(TEndUseComponent)
  protected
    procedure SetZone(ZoneParameter: T_EP_Zone); override;
  public
    Typ: string;
    Kind: string;
    ClgCoil: T_EP_Coil;
    HtgCoil: T_EP_Coil;
    FanEff: double;
    FanPresDrop: double;
    SuppressOA: boolean;
    procedure ToIDF; override;
    constructor Create; reintroduce;
    procedure Finalize; override;
  end;

type
  T_EP_ZoneERV = class(TEndUseComponent)
  protected
    procedure SetZone(ZoneParameter: T_EP_Zone); override;
  public
    SupFanEfficiency: double;
    SupFanPressureDrop: double;
    ExhFanEfficiency: double;
    ExhFanPressureDrop: double;
    SensibleEffectiveness: double;
    LatentEffectiveness: double;
    ParasiticPower: double;
    UseEconomizer: boolean;
    procedure ToIDF; override;
    constructor Create; reintroduce;
    procedure Finalize; override;
  end;

type
  T_EP_PurchasedAir = class(TEndUseComponent)
  protected
    procedure SetZone(ZoneParameter: T_EP_Zone); override;
  public
    OutdoorAir: boolean;
    procedure ToIDF; override;
    constructor Create; reintroduce;
    procedure Finalize; override;
  end;

// Process Loads
type
  T_EP_WaterSystems = class(TEndUseComponent)
  protected
    procedure SetZone(ZoneParameter: T_EP_Zone); override;
  public
    ScheduleName: string;
    TopologyType: string;
    BoilerLoop: T_EP_LiquidSystem;
    UseConnection: T_EP_WaterUseConnection;
    procedure ToIDF; override;
    constructor Create; reintroduce;
    procedure Finalize; override;
  end;

type
  T_EP_RefrigeratedCase = class(TEndUseComponent) // this actually doesn't have to connect to plant loop, but can connect on SupplySide for HeatRecovery
  protected
    procedure SetZone(ZoneParameter: T_EP_Zone); override;
  public
    CaseType: string; // there will be several different types - but only used for the naming (opteplus variable)
    DataSetKey : string;
    CaseID: integer;
    CompressorRackName: string;
    CompressorRackObj: T_EP_RefrigerationCompressorRack;
    RefrigSysObj: T_EP_RefrigerationSystem;
    CaseLength: double;
    CoolingCapPerLength: double;
    OperatingTemp: double;
    CaseFanPowerPerLength: double;
    OperatingCaseFanPowerPerLength: double;
    CaseFanPower: double;
    CaseLightingPowerPerLength: double;
    InstalledLightingPowerPerLength: double;
    CaseLightingSchedule: string;
    FractionLightsToCase: double;
    COP: double;
    AntiSweatHeaterPowerPerLength: double;
    AntiSweatHeaterControlType: string;
    DefrostPowerPerLength: double;
    DefrostType: string;
    DefrostSchedule: string;
    DefrostDripDownSchedule: string;
    DefrostEnergyCorrectionCurveType: string;
    DefrostEnergyCorrectionCurveName: string;
    RestockSchedule: string;
    CaseCreditSchedule: string;
    procedure ToIDF; override;
    procedure Finalize; override;
    constructor Create; reintroduce;
  end;

type
  T_EP_RefrigeratedWalkin = class(TEndUseComponent)
  protected
    procedure SetZone(ZoneParameter: T_EP_Zone); override;
  public
    DataSetKey : string;
    WalkinID: integer;
    CompressorRackName: string;
    CompressorRackObj: T_EP_RefrigerationCompressorRack;
    RefrigSysObj: T_EP_RefrigerationSystem;
    CoolingCapacity: double;
    OperatingTemp: double;
    SourceTemp: double;
    HeatingPower: double;
    HeatingPowerSchedule: string;
    CoolingCoilFanPower: double;
    LightingPower: double;
    LightingSchedule: string;
    DefrostType: string;
    DefrostControlType: string;
    DefrostSchedule: string;
    DefrostDripDownSchedule: string;
    DefrostPower: double;
    RestockSchedule: string;
    FloorSurfaceArea: double;
    SurfaceAreaFacingZone: double;
    ReachInDoorSchedule: string;
    StockingDoorSchedule: string;
    procedure ToIDF; override;
    procedure Finalize; override;
    constructor Create; reintroduce;
  end;

// kind of odd to have this here, but it is demand side equipment in EnergyPlus, but does not have a zone
type
  T_EP_SolarCollector = class(TEndUseComponent)
  public
    Typ: string;
    Area: double;
    Tilt: double;
    procedure ToIDF; override;
    constructor Create; reintroduce;
    procedure Finalize; override;
  end;

implementation

uses EnergyPlusPPErrorMessages, EnergyPlusObject, xmlProcessing, RegExpr, PreProcMacro;

{ T_EP_DirectAir }

constructor T_EP_DirectAir.Create;
begin
  inherited;
  ComponentType := 'AirTerminal:SingleDuct:Uncontrolled';
  RunAsNeutralDOAS := false;
  unitary_control := false;
  multizone := false;
end;

procedure T_EP_DirectAir.Finalize;
begin
  inherited;
end;

procedure T_EP_DirectAir.SetZone(ZoneParameter: T_EP_Zone);
begin
  inherited;
  if Assigned(ZoneParameter) then
  begin
    ZoneValue := ZoneParameter;
    Name := Zone.Name + ' Direct Air';
    DemandInletNode := Name + ' Inlet Node Name';
    DemandOutletNode := Zone.Name + ' Return Air Node Name';
    Zone.AirInletNodes.Add(DemandInletNode);
    //    Zone.AirSysSupplySideOutletNode := SupplyOutletNode;
  end;
end;

procedure T_EP_DirectAir.ToIDF;
var
  Obj: TEnergyPlusObject;
  k: integer;
  useOAReset: boolean;
begin
  useOAReset := false;
  Obj := IDF.AddObject('AirTerminal:SingleDuct:Uncontrolled');
  Obj.AddField('Name', Name);
  Obj.AddField('Availability Schedule Name', 'ALWAYS_ON');
  Obj.AddField('Zone Supply Air Node Name', DemandInletNode);
  Obj.AddField('Maximum Air Flow Rate', airFlowRate, '{m3/s}');

  for k := 0 to Systems.Count - 1 do
  begin
    if Systems[k].ClassNameIs('T_EP_AirSystem') then begin
      if airSystemName = T_EP_AirSystem(Systems[k]).Name then begin
        if SameText(T_EP_AirSystem(Systems[k]).DistributionType, 'MultiZone') then begin
          multizone := true;
        end;
        if SameText(T_EP_AirSystem(Systems[k]).SATManagerType, 'OutsideAir') then begin
          useOAReset := true;
        end;
        break;
      end;
    end;
  end;

  if not multizone then
  begin
    if useOAReset then
    begin
      Obj := IDF.AddObject('SetpointManager:OutdoorAirReset');
      obj.AddField('Name', 'SupAirTemp Mngr' + Zone.Name);
      Obj.AddField('Control Variable', 'Temperature');
      Obj.AddField('Setpoint at Outdoor Low Temperature', '15.5');
      Obj.AddField('Outdoor Low Temperature', '15.5');
      Obj.AddField('Setpoint at Outdoor High Temperature', '12.8');
      Obj.AddField('Outdoor High Temperature', '21.0');
      Obj.AddField('Setpoint Node or NodeList Name', Zone.AirSysSupplySideOutletNode);
      // should really throw error here, this would not control a zone.
    end
    else
    begin
      Obj := IDF.AddObject('SetpointManager:SingleZone:Reheat');
      Obj.AddField('Name', 'SupAirTemp Mngr' + Zone.Name);
      Obj.AddField('Control Variable', 'Temperature');
      if MinSupplyAirTemp <> -9999.0 then
      begin
        Obj.AddField('Minimum Supply Air Temperature', MinSupplyAirTemp, 'C');
      end
      else
      begin
        Obj.AddField('Minimum Supply Air Temperature', '10.0', 'C');
      end;
      if MaxSupplyAirTemp <> -9999.0 then
      begin
        Obj.AddField('Maximum Supply Air Temperature', MaxSupplyAirTemp, 'C');
      end
      else
      begin
        Obj.AddField('Maximum Supply Air Temperature', '50.0', 'C');
      end;
      Obj.AddField('Control Zone Name', Zone.Name);
      Obj.AddField('Zone Node Name', Zone.Name + ' Air Node');
      Obj.AddField('Zone Inlet Node Name', DemandInletNode);
      Obj.AddField('Setpoint Node or NodeList Name', Zone.AirSysSupplySideOutletNode); // what about slave zones??
    end;
  end;

  if DetailedReporting then
  begin
    Obj := IDF.AddObject('Output:Variable');
    Obj.AddField('Key Value', Zone.AirSysSupplySideOutletNode);
    Obj.AddField('Variable Name', 'System Node Temp');
    Obj.AddField('Reporting Frequency', 'Hourly');

    Obj := IDF.AddObject('Output:Variable');
    Obj.AddField('Key Value', Zone.AirSysSupplySideOutletNode);
    Obj.AddField('Variable Name', 'System Node Setpoint Temp');
    Obj.AddField('Reporting Frequency', 'Hourly');
  end;
end;

{ T_EP_DualDuctOutdoorAir }

constructor T_EP_DualDuctOutdoorAir.Create;
begin
  inherited;
  ComponentType := 'ZoneHVAC:AirDistributionUnit';
  RecircBranch := true;
end;

procedure T_EP_DualDuctOutdoorAir.SetZone(ZoneParameter: T_EP_Zone);
begin
  inherited;
  if Assigned(ZoneParameter) then
  begin
    ZoneValue := ZoneParameter;
    Name := Zone.Name + ' Dual Duct Box';
    DemandInletNode := Name + ' Inlet Node Name';
    RecircDemandInletNode := 'RC ' + Name + ' Inlet Node Name';
    DemandOutletNode := Name + ' Outlet Node Name';
    Zone.AirInletNodes.Add(DemandOutletNode);
  end;
end;

procedure T_EP_DualDuctOutdoorAir.ToIDF;
var
  Obj: TEnergyPlusObject;
begin
  Finalize;
  // ZoneHVAC:AirDistributionUnit
  Obj := IDF.AddObject('ZoneHVAC:AirDistributionUnit');
  Obj.AddField('Name', Name);
  Obj.AddField('Air Distribution Unit Outlet Node Name', Name + ' Outlet Node Name');
  Obj.AddField('Air Terminal Object Type', 'AirTerminal:DualDuct:VAV:OutdoorAir');
  Obj.AddField('Air Terminal Name', Name + ' Component');
  // AirTerminal:DualDuct:VAV:OutdoorAir
  Obj := IDF.AddObject('AirTerminal:DualDuct:VAV:OutdoorAir');
  Obj.AddField('Name', Name + ' Component');
  Obj.AddField('Availability Schedule Name', 'ALWAYS_ON');
  Obj.AddField('Air Outlet Node Name', DemandOutletNode);
  Obj.AddField('Outdoor Air Inlet Node Name', DemandInletNode);
  if RecircBranch then
    Obj.AddField('Recirculated Air Inlet Node Name', RecircDemandInletNode)
  else
    Obj.AddField('Recirculated Air Inlet Node Name', '');
  Obj.AddField('Maximum Damper Air Flow Rate', 'AUTOSIZE', '{m3/s}');
  Obj.AddField('Design Specification Outdoor Air Object Name', Name + ' OA Design Spec');
  if Zone.DemandControlVentilation then
    Obj.AddField('Per Person Ventilation Rate Mode', 'CurrentOccupancy')
  else
    Obj.AddField('Per Person Ventilation Rate Mode', 'DesignOccupancy');
  // DesignSpecification:OutdoorAir
  Obj := IDF.AddObject('DesignSpecification:OutdoorAir');
  Obj.AddField('Name', Name + ' OA Design Spec');
  if Zone.DemandControlVentilation then
  begin
    Obj.AddField('Outdoor Air Method', 'Sum');
    if Zone.OAPerPerson > 0 then
      Obj.AddField('Outdoor Air Flow per Person', FloatToStr(Zone.OAPerPerson), '{m3/s-person}')
    else
      Obj.AddField('Outdoor Air Flow per Person', '0.0', '{m3/s-person}');
    if Zone.OAPerArea > 0 then
      Obj.AddField('Outdoor Air Flow per Zone Floor Area', FloatToStr(Zone.OAPerArea), '{m3/s-m2}')
    else
      Obj.AddField('Outdoor Air Flow per Zone Floor Area', '0.0', '{m3/s-m2}');
    if Zone.OAPerZone > 0 then
      Obj.AddField('Outdoor Air Flow per Zone', FloatToStr(Zone.OAPerZone), '{m3/s}')
    else
      Obj.AddField('Outdoor Air Flow per Zone', '0.0', '{m3/s}');
    if Zone.OAPerACH > 0 then
      Obj.AddField('Outdoor Air Flow Air Changes per Hour', FloatToStr(Zone.OAPerACH), '{1/hr}')
    else
      Obj.AddField('Outdoor Air Flow Air Changes per Hour', '0.0', '{1/hr}');
    Obj.AddField('Outdoor Air Flow Rate Fraction Schedule Name', 'MinOA_Sched');
  end
  else
  begin
    Obj.AddField('Outdoor Air Method', 'Flow/Zone');
    Obj.AddField('Outdoor Air Flow per Person', '0.0', '{m3/s-person}');
    Obj.AddField('Outdoor Air Flow per Zone Floor Area', '0.0', '{m3/s-m2}');
    Obj.AddField('Outdoor Air Flow per Zone', FloatToStr(Zone.MaxOA), '{m3/s}');
    Obj.AddField('Outdoor Air Flow Air Changes per Hour', '0.0', '{1/hr}');
    Obj.AddField('Outdoor Air Flow Rate Fraction Schedule Name', 'MinOA_Sched');
  end;
end;

procedure T_EP_DualDuctOutdoorAir.Finalize;
begin
  inherited;
end;

{ T_EP_SingleDuctVariableFlow }

constructor T_EP_SingleDuctVariableFlow.Create;
begin
  inherited;
  ComponentType := 'ZoneHVAC:AirDistributionUnit';
  ReheatCoilEfficiency := 1.0;
  MinFlowFraction := -9999.0;
  MaxAirFlowRate := -9999.0;
  TotalAirPerArea := 0.0;
  TotalAirPerPerson := 0.0;
  TotalAirPerZone := 0.0;
  TotalAirPerACH := 0.0;
  AvailSchedule := 'ALWAYS_ON';
  MinFlowFractionSchedule := 'SchedNotSet';
  MinAirFlowRate := 0.0;
  DamperHeatingAction := 'Reverse';
  SuppressOA := false;
  SuppressDesignSpecOA := false;
  CoilAvailSch := 'ALWAYS_ON'
end;

procedure T_EP_SingleDuctVariableFlow.SetZone(ZoneParameter: T_EP_Zone);
begin
  inherited;
  if Assigned(ZoneParameter) then
  begin
    ZoneValue := ZoneParameter;
    Name := Zone.Name + ' VAV Box';
    DemandInletNode := Name + ' Inlet Node Name';
    DemandOutletNode := Name + ' Outlet Node Name';
    Zone.AirInletNodes.Add(DemandOutletNode);
  end;
end;

procedure T_EP_SingleDuctVariableFlow.SetReheatCoil(ReheatCoilParameter: string);
begin
  ReheatCoilValue := ReheatCoilParameter;
  if SameText(ReheatCoilType, 'HOT WATER') then
  begin
    //now in XMLproc.pas to add to LiquidHeatingsystms
    //not sure yet what else may be needed here.
  end;
end;

procedure T_EP_SingleDuctVariableFlow.SetMaxAirFlowComponents(MaxAirFlowNode: TXMLNode);
begin
  TotalAirPerArea := FloatValueFromPath(MaxAirFlowNode, 'TotalAirPerArea');
  TotalAirPerPerson := FloatValueFromPath(MaxAirFlowNode, 'TotalAirPerPerson');
  TotalAirPerZone := FloatValueFromPath(MaxAirFlowNode, 'TotalAirPerZone');
  TotalAirPerACH := FloatValueFromPath(MaxAirFlowNode, 'TotalAirPerACH');
end;

procedure T_EP_SingleDuctVariableFlow.ToIDF;
var
  Obj: TEnergyPlusObject;
begin
  Finalize;
  // two types of ADUs here SINGLE DUCT:VAV:REHEAT or SINGLE DUCT:VAV:NOREHEAT
  if SameText(ReheatCoilType, 'None') then
  begin
    Obj := IDF.AddObject('ZoneHVAC:AirDistributionUnit');
    Obj.AddField('Name', Name);
    Obj.AddField('Air Distribution Unit Outlet Node Name', Name + ' Outlet Node Name');
    Obj.AddField('Air Terminal Object Type', 'AirTerminal:SingleDuct:VAV:NoReheat');
    Obj.AddField('Air Terminal Name', Name + ' Component');
    if LeakageFraction > 0.0 then
    begin
      Obj.AddField('Nominal Upstream Leakage Fraction', '', '{%}');
      Obj.AddField('Constant Downstream Leakage Fraction', LeakageFraction, '{%}');
    end;
    Obj := IDF.AddObject('AirTerminal:SingleDuct:VAV:NoReheat');
    Obj.AddField('Name', Name + ' Component');
    Obj.AddField('Availability Schedule Name', AvailSchedule);
    Obj.AddField('Air Outlet Node Name', DemandOutletNode);
    Obj.AddField('Air Inlet Node Name', DemandInletNode);
    if MaxAirFlowRate < 0.0 then
      Obj.AddField('Maximum Air Flow Rate', 'AUTOSIZE', '{m3/s}')
    else
      Obj.AddField('Maximum Air Flow Rate', MaxAirFlowRate, '{m3/s}');
    if not SameText(MinFlowFractionSchedule, 'SchedNotSet') then
    begin
      Obj.AddField('Zone Minimum Air Flow Input Method', 'Scheduled');
      Obj.AddField('Constant Minimum Air Flow Fraction', '', '{}');
      Obj.AddField('Fixed Minimum Air Flow Rate', '', '{m3/s}');
      Obj.AddField('Minimum Air Flow Fraction Schedule Name', MinFlowFractionSchedule);
    end
    else if MinAirFlowRate > 0.0 then
    begin
      Obj.AddField('Zone Minimum Air Flow Input Method', 'FixedFlowRate');
      Obj.AddField('Constant Minimum Air Flow Fraction', '', '{}');
      Obj.AddField('Fixed Minimum Air Flow Rate', MinAirFlowRate, '{m3/s}');
      Obj.AddField('Minimum Air Flow Fraction Schedule Name', '');
    end
    else
    begin
      Obj.AddField('Zone Minimum Air Flow Input Method', 'Constant');
      Obj.AddField('Constant Minimum Air Flow Fraction', MinFlowFraction, '{}');
      Obj.AddField('Fixed Minimum Air Flow Rate', '', '{m3/s}');
      Obj.AddField('Minimum Air Flow Fraction Schedule Name', '');
    end;
    if SuppressOA or SuppressDesignSpecOA then
      Obj.AddField('Design Specification Outdoor Air Object Name', '')
    else
    begin
      Obj.AddField('Design Specification Outdoor Air Object Name', Name + ' OA Design Spec');
      //add OA design specification object
      Obj := IDF.AddObject('DesignSpecification:OutdoorAir');
      Obj.AddField('Name', Name + ' OA Design Spec');
      if Zone.DemandControlVentilation then
      begin
        Obj.AddField('Outdoor Air Method', 'Sum');
        if Zone.OAPerPerson > 0 then
          Obj.AddField('Outdoor Air Flow per Person', FloatToStr(Zone.OAPerPerson), '{m3/s-person}')
        else
          Obj.AddField('Outdoor Air Flow per Person', '0.0', '{m3/s-person}');
        if Zone.OAPerArea > 0 then
          Obj.AddField('Outdoor Air Flow per Zone Floor Area', FloatToStr(Zone.OAPerArea), '{m3/s-m2}')
        else
          Obj.AddField('Outdoor Air Flow per Zone Floor Area', '0.0', '{m3/s-m2}');
        if Zone.OAPerZone > 0 then
          Obj.AddField('Outdoor Air Flow per Zone', FloatToStr(Zone.OAPerZone), '{m3/s}')
        else
          Obj.AddField('Outdoor Air Flow per Zone', '0.0', '{m3/s}');
        if Zone.OAPerACH > 0 then
          Obj.AddField('Outdoor Air Flow Air Changes per Hour', FloatToStr(Zone.OAPerACH), '{1/hr}')
        else
          Obj.AddField('Outdoor Air Flow Air Changes per Hour', '0.0', '{1/hr}');
        Obj.AddField('Outdoor Air Flow Rate Fraction Schedule Name', '');
      end
      else
      begin
        Obj.AddField('Outdoor Air Method', 'Flow/Zone');
        Obj.AddField('Outdoor Air Flow per Person', '0.0', '{m3/s-person}');
        Obj.AddField('Outdoor Air Flow per Zone Floor Area', '0.0', '{m3/s-m2}');
        Obj.AddField('Outdoor Air Flow per Zone', FloatToStr(Zone.MaxOA), '{m3/s}');
        Obj.AddField('Outdoor Air Flow Air Changes per Hour', '0.0', '{1/hr}');
        Obj.AddField('Outdoor Air Flow Rate Fraction Schedule Name', '');
      end;
    end;
  end
  else
  begin
    Obj := IDF.AddObject('ZoneHVAC:AirDistributionUnit');
    Obj.AddField('Name', Name);
    Obj.AddField('Air Distribution Unit Outlet Node Name', Name + ' Outlet Node Name');
    Obj.AddField('Air Terminal Object Type', 'AirTerminal:SingleDuct:VAV:Reheat');
    Obj.AddField('Air Terminal Name', Name + ' Component');
    if LeakageFraction > 0.0 then
    begin
      Obj.AddField('Nominal Upstream Leakage Fraction', LeakageFraction, '{%}');
      Obj.AddField('Constant Downstream Leakage Fraction', '', '{%}');
    end;
    Obj := IDF.AddObject('AirTerminal:SingleDuct:VAV:Reheat');
    Obj.AddField('Name', Name + ' Component');
    Obj.AddField('Availability Schedule Name', AvailSchedule);
    Obj.AddField('Damper Air Outlet Node Name', Name + ' Damper Node');
    Obj.AddField('Air Inlet Node Name', DemandInletNode);
    if MaxAirFlowRate < 0.0 then
      Obj.AddField('Maximum Air Flow Rate', 'AUTOSIZE', '{m3/s}')
    else
      Obj.AddField('Maximum Air Flow Rate',MaxAirFlowRate, '{m3/s}');
    //is it scheduled?
    if not SameText(MinFlowFractionSchedule, 'SchedNotSet') then
    begin
      Obj.AddField('Zone Minimum Air Flow Input Method', 'Scheduled') ;
      Obj.AddField('Constant Minimum Air Flow Fraction', '', '{}');
      Obj.AddField('Fixed Minimum Air Flow Rate', '', '{m3/s}');
      Obj.AddField('Minimum Air Flow Fraction Schedule Name', MinFlowFractionSchedule);
    end
    else if MinAirFlowRate > 0.0 then
    begin
      Obj.AddField('Zone Minimum Air Flow Input Method','FixedFlowRate');
      Obj.AddField('Constant Minimum Air Flow Fraction', '', '{}');
      Obj.AddField('Fixed Minimum Air Flow Rate', MinAirFlowRate, '{m3/s}');
      Obj.AddField('Minimum Air Flow Fraction Schedule Name', '');
    end
    else
    begin
      Obj.AddField('Zone Minimum Air Flow Input Method','Constant');
      Obj.AddField('Constant Minimum Air Flow Fraction', MinFlowFraction, '{}');
      Obj.AddField('Fixed Minimum Air Flow Rate', '', '{m3/s}');
      Obj.AddField('Minimum Air Flow Fraction Schedule Name', '');
    end;
    if SameText(ReheatCoilType, 'Gas') then
    begin
      Obj.AddField('Reheat Coil Object Type', 'Coil:Heating:Gas');
      Obj.AddField('Reheat Coil Name', Name + ' Reheat Coil');
    end
    else if SameText(ReheatCoilType, 'Electric') then
    begin
      Obj.AddField('Reheat Coil Object Type', 'Coil:Heating:Electric');
      Obj.AddField('Reheat Coil Name', Name + ' Reheat Coil');
    end
    else if SameText(ReheatCoilType, 'HOT WATER') then
    begin
      Obj.AddField('Reheat Coil Object Type', 'Coil:Heating:Water');
      Obj.AddField('Reheat Coil Name', Name + ' Reheat Coil');
    end;
    Obj.AddField('Maximum Hot Water or Steam Flow Rate', 'AUTOSIZE', '{m3/s}');
    Obj.AddField('Minimum Hot Water or Steam Flow Rate', '0.0', '{m3/s}');
    Obj.AddField('Air Outlet Node Name', DemandOutletNode);
    Obj.AddField('Convergence Tolerance', '0.001', '{}');
    Obj.AddField('Damper Heating Action', DamperHeatingAction);
    Obj.AddField('Maximum Flow per Zone Floor Area during Reheat', 'AUTOCALCULATE', '{m3/s-m2}');
    Obj.AddField('Maximum Flow Fraction During Reheat', 'AUTOCALCULATE', '{}');
    Obj.AddField('Maximum Reheat Air Temperature', '50.0', '{C}');
    if SuppressDesignSpecOA then
      Obj.AddField('Design Specification Outdoor Air Object Name', '')
    else
    begin
      Obj.AddField('Design Specification Outdoor Air Object Name', Name + ' OA Design Spec');
      //add OA design specification object
      Obj := IDF.AddObject('DesignSpecification:OutdoorAir');
      Obj.AddField('Name', Name + ' OA Design Spec');
      if Zone.DemandControlVentilation then
      begin
        Obj.AddField('Outdoor Air Method', 'Sum');
        if Zone.OAPerPerson > 0 then
          Obj.AddField('Outdoor Air Flow per Person', FloatToStr(Zone.OAPerPerson), '{m3/s-person}')
        else
          Obj.AddField('Outdoor Air Flow per Person', '0.0', '{m3/s-person}');
        if Zone.OAPerArea > 0 then
          Obj.AddField('Outdoor Air Flow per Zone Floor Area', FloatToStr(Zone.OAPerArea), '{m3/s-m2}')
        else
          Obj.AddField('Outdoor Air Flow per Zone Floor Area', '0.0', '{m3/s-m2}');
        if Zone.OAPerZone > 0 then
          Obj.AddField('Outdoor Air Flow per Zone', FloatToStr(Zone.OAPerZone), '{m3/s}')
        else
          Obj.AddField('Outdoor Air Flow per Zone', '0.0', '{m3/s}');
        if Zone.OAPerACH > 0 then
          Obj.AddField('Outdoor Air Flow Air Changes per Hour', FloatToStr(Zone.OAPerACH), '{1/hr}')
        else
          Obj.AddField('Outdoor Air Flow Air Changes per Hour', '0.0', '{1/hr}');
        Obj.AddField('Outdoor Air Flow Rate Fraction Schedule Name', '');
      end
      else
      begin
        Obj.AddField('Outdoor Air Method', 'Flow/Zone');
        Obj.AddField('Outdoor Air Flow per Person', '0.0', '{m3/s-person}');
        Obj.AddField('Outdoor Air Flow per Zone Floor Area', '0.0', '{m3/s-m2}');
        Obj.AddField('Outdoor Air Flow per Zone', Zone.MaxOA, '{m3/s}');
        Obj.AddField('Outdoor Air Flow Air Changes per Hour', '0.0', '{1/hr}');
        Obj.AddField('Outdoor Air Flow Rate Fraction Schedule Name', '');
      end;
    end;
    //add heating coil objects
    if SameText(ReheatCoilType, 'Gas') then
    begin
      Obj := IDF.AddObject('Coil:Heating:Gas');
      Obj.AddField('Name', Name + ' Reheat Coil');
      Obj.AddField('Availability Schedule Name', CoilAvailSch);
      Obj.AddField('Gas Burner Efficiency', ReheatCoilEfficiency, '{}');
      Obj.AddField('Nominal Capacity', 'AUTOSIZE', '{W}');
      Obj.AddField('Air Inlet Node Name', Name + ' Damper Node');
      Obj.AddField('Air Outlet Node Name', DemandOutletNode);
    end
    else if SameText(ReheatCoilType, 'Electric') then
    begin
      Obj := IDF.AddObject('Coil:Heating:Electric');
      Obj.AddField('Name', Name + ' Reheat Coil');
      Obj.AddField('Availability Schedule Name', CoilAvailSch);
      Obj.AddField('Efficiency', ReheatCoilEfficiency, '{}');
      Obj.AddField('Nominal Capacity', 'AUTOSIZE', '{W}');
      Obj.AddField('Air Inlet Node', Name + ' Damper Node');
      Obj.AddField('Air Outlet Node', DemandOutletNode);
    end
    else if SameText(ReheatCoilType, 'HOT WATER') then
    begin
      //should this component should get written out elsewhere as a System Component?
      //reuse that code for T_EP_Coil.ToIDF but call it here
      HotWaterReheatCoilObject.DemandControlType := 'Active';
      HotWaterReheatCoilObject.SupplyInletNode := Name + ' Damper Node';
      HotWaterReheatCoilObject.SupplyOutletNode := DemandOutletNode;
      HotWaterReheatCoilObject.ToIDF;
    end;
  end; // else not no reheat
end;

procedure T_EP_SingleDuctVariableFlow.Finalize;
var
  AirFlowFromACH : double;
  AirFlowFromOther : double;
begin
  // make sure zone area, volume, etc. are calculated
  Zone.Finalize;
  // now determine total air flow for zone as sum of its components, this will override autosizing for loads
  AirFlowFromOther := 0.0;
  if TotalAirPerArea > 0.0 then
    AirFlowFromOther := AirFlowFromOther + TotalAirPerArea*Zone.Area;
  if totalAirPerPerson > 0.0 then
    AirFlowFromOther := AirFlowFromOther + TotalAirPerPerson*Zone.NumPeople;
  if totalAirPerZone > 0.0 then
    AirFlowFromOther := AirFlowFromOther + totalAirPerZone;
  AirFlowFromACH := 0.0;
  if TotalAirPerACH > 0.0 then
    AirFlowFromACH := TotalAirPerACH*Zone.AirVolume / 3600.0;
  if AirFlowFromOther > AirFlowFromACH then
    MaxAirFlowRate := AirFlowFromOther
  else
    MaxAirFlowRate := AirFlowFromACH;
  if MaxAirFlowRate = 0.0 then
    MaxAirFlowRate := -999.0;
  //if min flow fraction has not been set, then provide default
  if (MinFlowFraction < 0) then
  begin
    // if there is a max flow rate set, default to 0.3
    if MaxAirFlowRate > 0 then
      MinFlowFraction := 0.3
    // else default to 0.3
    else
      MinFlowFraction := 0.3;
  end;
  inherited;
end;

{  T_EP_FanPoweredTerminal  }

constructor T_EP_FanPoweredTerminal.Create;
begin
  inherited;
  ComponentType := 'ZoneHVAC:AirDistributionUnit';
  FanOperationSchedule := 'HVACOperationSchd';
end;

procedure T_EP_FanPoweredTerminal.SetZone(ZoneParameter: T_EP_Zone);
begin
  inherited;
  if Assigned(ZoneParameter) then
  begin
    ZoneValue := ZoneParameter;
    Name := Zone.Name + ' PFP';
    DemandInletNode := Name + 'Primary Air Inlet Node';
    DemandOutletNode := Name + 'Primary Air Outlet Node';
    SupplyInletNode := Name + 'Secondary Air Inlet Node';
    SupplyOutletNode := Name + 'secondary Air Outlet Node';
    Zone.AirInletNodes.Add(DemandOutletNode);
    Zone.AirExhaustNodes.Add(SupplyInletNode);
  end;
end;

procedure T_EP_FanPoweredTerminal.SetReheatCoil(ReheatCoilParameter: string);
begin
  ReheatCoilValue := ReheatCoilParameter;

  if SameText(ReheatCoilType, 'HOT WATER') then
  begin
    //now in XMLproc.pas to add to LiquidHeatingsystms
    // not sure yet what else may be needed here.

  end;

end;

procedure T_EP_FanPoweredTerminal.ToIDF;
var
  Obj: TEnergyPlusObject;
begin
  //air distribution unit
  Obj := IDF.AddObject('ZoneHVAC:AirDistributionUnit');
  Obj.AddField('Name', Name);
  Obj.AddField('Air Distribution Unit Outlet Node Name', DemandOutletNode);
  Obj.AddField('Air Terminal Object Type', 'AirTerminal:SingleDuct:ParallelPIU:Reheat');
  Obj.AddField('Air Terminal Name', Name + ' Component');
  //air terminal
  Obj := IDF.AddObject('AirTerminal:SingleDuct:ParallelPIU:Reheat');
  Obj.AddField('Name', Name + ' Component');
  Obj.AddField('Availability Schedule Name', 'ALWAYS_ON');
  Obj.AddField('Maximum Primary Air Flow Rate', 'AUTOSIZE');
  Obj.AddField('Maximum Secondary Air Flow Rate', 'AUTOSIZE');
  Obj.AddField('Minimum Primary Air Flow Fraction', 'AUTOSIZE');
  Obj.AddField('Fan On Flow Fraction', 'AUTOSIZE');
  Obj.AddField('Supply Air Inlet Node Name', DemandInletNode);
  Obj.AddField('Secondary Air Inlet Node Name', SupplyInletNode);
  Obj.AddField('Outlet Node Name', DemandOutletNode);
  Obj.AddField('Reheat Coil Air Inlet Node Name', name + 'reheat air inlet node');
  Obj.AddField('Zone Mixer Name', name + ' zone mixer');
  Obj.AddField('Fan Name', name + ' fan');
  if SameText(ReheatCoilType, 'Gas') then
    Obj.AddField('Reheat Coil Object Type', 'Coil:Heating:Gas')
  else if SameText(ReheatCoilType, 'Electric') then
    Obj.AddField('Reheat Coil Object Type', 'Coil:Heating:Electric')
  else if SameText(Reheatcoiltype, 'HOT WATER') then
    Obj.AddField('Reheat Coil Object Type', 'Coil:Heating:Water');
  Obj.AddField('Reheat Coil Name', name + ' reheat coil');
  Obj.AddField('Maximum Hot Water or Steam Flow Rate', 'AUTOSIZE');
  Obj.AddField('Minimum Hot Water or Steam Flow Rate', '0.0');
  if Assigned(HotWaterReheatCoilObject) then
    Obj.AddField('Hot Water or Steam Inlet Node Name', HotWaterReheatCoilObject.DemandInletNode)
  else
    Obj.AddField('Hot Water or Steam Inlet Node Name', '');
  Obj.AddField('Convergence Tolerance', '0.0005');
  //zone mixer
  Obj := IDF.AddObject('AirLoopHVAC:ZoneMixer');
  Obj.AddField('Name', name + ' zone mixer');
  Obj.AddField('Outlet Node Name', name + 'reheat air inlet node');
  Obj.Addfield('Inlet 1 Node Name', DemandInletNode);
  Obj.AddField('Inlet 2 Node Name', name + 'fan outlet node');
  //fan
  Obj := IDF.AddObject('Fan:ConstantVolume');
  Obj.AddField('Name', name + ' fan');
  Obj.AddField('Availability Schedule Name', FanOperationSchedule);
  Obj.AddField('Fan Efficiency', FloatToStr(FanEfficiency));
  Obj.AddField('Pressure Rise', FloatToStr(FanPressureDrop));
  Obj.AddField('Maximum Flow Rate', 'AUTOSIZE');
  Obj.AddField('Motor Efficiency', '0.9');
  Obj.AddField('Motor in Airstream Fraction', '1.0');
  Obj.AddField('Air Inlet Node Name' , SupplyInletNode);
  Obj.AddField('Air Outlet Node Name' , name + 'fan outlet node');
  obj.AddField('End-Use Subcategory', 'Fan-Powered Terminal Fan') ;
  //reheat coil
  if SameText(ReheatCoilType, 'Gas') then
  begin
    Obj := IDF.AddObject('Coil:Heating:Gas');
    Obj.AddField('Name', name + ' reheat coil');
    Obj.AddField('Availability Schedule Name', 'ALWAYS_ON');
    Obj.AddField('Gas Burner Efficiency', FloatToStr(ReheatCoilEfficiency), '{}');
    Obj.AddField('Nominal Capacity', 'AUTOSIZE', '{W}');
    Obj.AddField('Air Inlet Node Name', name + 'reheat air inlet node');
    Obj.AddField('Air Outlet Node Name', DemandOutletNode);
  end
  else if SameText(ReheatCoilType, 'Electric') then
  begin
    Obj := IDF.AddObject('Coil:Heating:Electric');
    Obj.AddField('Name', name + ' reheat coil');
    Obj.AddField('Availability Schedule Name', 'ALWAYS_ON');
    Obj.AddField('Efficiency', FloatToStr(ReheatCoilEfficiency), '{}');
    Obj.AddField('Nominal Capacity', 'AUTOSIZE', '{W}');
    Obj.AddField('Air Inlet Node Name', name + 'reheat air inlet node');
    Obj.AddField('Air Outlet Node Name', DemandOutletNode);
  end
  else if SameText(ReheatCoilType, 'HOT WATER') then
  begin

    // should this component should get written out elsewhere as a System Component?
    //  reuse that code for T_EP_Coil.ToIDF but call it here
    HotWaterReheatCoilObject.DemandControlType := 'Active';
    HotWaterReheatCoilObject.SupplyInletNode := name + 'reheat air inlet node';
    HotWaterReheatCoilObject.SupplyOutletNode := DemandOutletNode;
    HotWaterReheatCoilObject.ToIDF;
  end;
end;

procedure T_EP_FanPoweredTerminal.Finalize;
begin
  inherited;
end;

{ T_EP_ExhaustFan }

constructor T_EP_ExhaustFan.Create;
begin
  inherited;
  ComponentType := 'Fan:ZoneExhaust';
  ScheduleName := 'Hours_of_operation';
  ExhaustFlowPerArea := -999.0;
  OverrideOA := true;
end;

procedure T_EP_ExhaustFan.SetZone(ZoneParameter: T_EP_Zone);
begin
  inherited;
  if Assigned(ZoneParameter) then
  begin
    ZoneValue := ZoneParameter;
    Name := Zone.Name + ' Exhaust Fan' + ' ' + IntToStr(ExhaustFanID);
    DemandInletNode := Name + ' Inlet Node';
    DemandOutletNode := Name + ' Outlet Node';
    Zone.AirExhaustNodes.Add(DemandInletNode);
  end;
end;

function T_EP_ExhaustFan.TotalMakeupTransferFlowRate: double ;
var
  sum: double;
  i: integer;
begin
  sum := 0.0;
  for i := 0 to length(MakeupTransferFlowRates) - 1 do
  begin
    if MakeupTransferFlowRates[i] > 0.0 then
      sum := sum + MakeupTransferFlowRates[i];
  end;
  for i := 0 to length(MakeupTransferZoneFractions) - 1 do
  begin
    if MakeupTransferZoneFractions[i] > 0.0 then
      sum := sum + MakeupTransferZoneFractions[i] * MaxExhaustFlowRate;
  end;
  Result := sum;
end;

function T_EP_ExhaustFan.MaxExhaustFlowRate: double;
var
  RateFromFlowPerArea: double;
  RateFromACH: double;
  LargestFlow: double;
begin
    if (ExhaustFlowPerArea > 0.0) then
      RateFromFlowPerArea := ExhaustFlowPerArea * Zone.Area
    else
      RateFromFlowPerArea := 0.0;
    if (ExhaustFlowACH > 0.0) then
      RateFromACH := ExhaustFlowACH * Zone.AirVolume / 3600.0
    else
      RateFromACH := 0.0;
    if ExhaustFlowRate > 0.0 then
      // do nothing
    else
      ExhaustFlowRate := 0.0;
    LargestFlow := ExhaustFlowRate;
    if RateFromFlowPerArea > LargestFlow then LargestFlow := RateFromFlowPerArea;
    if RateFromACH > LargestFlow then LargestFlow := RateFromACH;
    Result := LargestFlow;
end;

function T_EP_ExhaustFan.DrawFromInfiltrationRate: double;
begin
    if DrawFromInfiltrationFraction > 0.0 then begin
      Result :=  self.MaxExhaustFlowRate * DrawFromInfiltrationFraction ;
    end
    else
      Result := 0.0;
end;

procedure T_EP_ExhaustFan.Finalize;
var
  i: integer;
  SumFractions: double;
begin
    sumFractions := 0.0  ;
    if DrawFromInfiltrationFraction > 0.0 then
    begin
      sumFractions :=  sumFractions +  DrawFromInfiltrationFraction ;
    end;
    if  MakeupTransferZoneList.Count > 0 then
    begin
      // ksb: SetLength(MakeupTransferFlowRates,      MakeupTransferZoneList.Count  );
      For i := 0 to MakeupTransferZoneList.Count - 1 do begin
        sumFractions :=  sumFractions + MakeupTransferZoneFractions[i];
        // ksb: if MakeupTransferZoneFraction is given then use it
        // ksb: if not the schema should require MakeupTransferFlowRate to be
        // ksb: given directly
        if (MakeupTransferZoneFractions[i] >= 0.0) then begin
          MakeupTransferFlowRates[i] :=  self.MaxExhaustFlowRate *  MakeupTransferZoneFractions[i] ;
        end;
      end; // for
    end;
    if sumFractions > 1.0 then
    begin
      // throw preprocessor severe error.
      T_EP_PPErrorMessage.AddErrorMessage(esWarning, 'The sum of make up air fractions exceeds 1.0 for  ' +
                        ' the zone exhaust fan called' + name);
      // ksb: if user input FlowRate instead of FlowFraction they are on their own
      // ksb: there will be no warnings if makeup transfer air exceeds exhaust flow
    end;
end;

procedure T_EP_ExhaustFan.ToIDF;
var
  i: integer;
  Obj: TEnergyPlusObject;
begin
  Finalize;
  Obj := IDF.AddObject('Fan:ZoneExhaust');
  Obj.AddField('Name', Name);
  Obj.AddField('Availability Schedule Name', ScheduleName);
  Obj.AddField('Fan Efficiency', FanEfficiency, '{}');
  Obj.AddField('Pressure Rise', FanPressureDrop, '{Pa}');
  Obj.AddField('Maximum Flow Rate', self.MaxExhaustFlowRate, '{m3/s}', '*******');
  Obj.AddField('Air Inlet Node Name', DemandInletNode);
  Obj.AddField('Air Outlet Node Name', DemandOutletNode);
  Obj.AddField('End-Use Subcategory', 'Zone Exhaust Fans');
  if DrawFromInfiltrationRate > 0.0  then
  begin
    Obj := IDF.AddObject('ZoneInfiltration:DesignFlowRate');
    Obj.AddField('Name', name + 'infilt');
    Obj.AddField('Zone Name', Zone.name);
    Obj.AddField('Schedule Name', ScheduleName);
    obj.AddField('Design Flow Rate Calculation Method', 'Flow/Zone' );
    Obj.AddField('Design Flow Rate', DrawFromInfiltrationRate, '{m3/s}');
    Obj.AddField('Flow per Zone Area', '', '{m3/s/m2}');
    Obj.AddField('Flow per Exterior Surface Area', '', '{m3/s/m2}');
    Obj.AddField('Air Changes Per Hour', '', '{ACH}');
    Obj.AddField('Constant Term Coefficient', 1.0);
    Obj.AddField('Temperature Term Coefficient', 0.0);
    Obj.AddField('Velocity Term Coefficient', 0.0);
    Obj.AddField('Velocity Squared Term Coefficient', 0.0);
  end;
  if  MakeupTransferZoneList.count > 0 then
  begin
    for i := 0 to MakeupTransferZoneList.count - 1 do
    begin
      obj := IDF.AddObject('ZoneMixing');
      obj.AddField('Name', name + 'mixing_'+inttostr(i));
      obj.AddField('Zone Name', zone.Name);
      obj.AddField('Schedule Name', ScheduleName );
      obj.AddField('Design Flow Rate Calculation Method', 'Flow/Zone');
      Obj.AddField('Design Flow Rate', MakeupTransferFlowRates[i] );
      obj.AddField('Flow Rate per Zone Area', '','{m3/s/m2}');
      obj.AddField('Flow Rate per Person', '', '{m3/s/person}');
      obj.AddField('Air Changes per Hour','' , '{ACH}');
      obj.AddField('Source Zone Name', MakeupTransferZoneList.Strings[i] );
      obj.AddField('Delta Temperature', '0.0');
    end;
  end; // if
end;

{ T_EP_BaseboardHeaterConvectiveWater }

constructor T_EP_BaseboardHeaterConvectiveWater.Create;
begin
  inherited;
  ComponentType := 'ZoneHVAC:Baseboard:Convective:Water';
  ControlType := 'Active';
  DemandControlType := 'Active';
end;

procedure T_EP_BaseboardHeaterConvectiveWater.Finalize;
begin
  inherited;
end;

procedure T_EP_BaseboardHeaterConvectiveWater.SetZone(ZoneParameter: T_EP_Zone);
begin
  inherited;
  if Assigned(ZoneParameter) then
  begin
    ZoneValue := ZoneParameter;

    Name := Zone.Name + ' Baseboard Heater';
    DemandInletNode := Name + ' Inlet Node Name';
    DemandOutletNode := Name + ' Outlet Node Name';
  end;
end;

procedure T_EP_BaseboardHeaterConvectiveWater.ToIDF;
var
  Obj: TEnergyPlusObject;
begin
  Obj := IDF.AddObject(ComponentType);  //'ZoneHVAC:Baseboard:Convective:Water'
  Obj.AddField('Name', Name);
  Obj.AddField('Availability Schedule Name', 'ALWAYS_ON');
  Obj.AddField('Inlet Node Name', DemandInletNode);
  Obj.AddField('Outlet Node Name', DemandOutletNode);
  Obj.AddField('U-Factor Times Area Value', 'AUTOSIZE', '{W/K}');
  Obj.AddField('Maximum Water Flow Rate', 'AUTOSIZE', '{m3/s}');
  Obj.AddField('Convergence Tolerance', '0.001', '{}');
end;

{ T_EP_LowTempRadiantVariableFlow }

constructor T_EP_LowTempRadiantVariableFlow.Create;
begin
  inherited;
  ComponentType := 'ZoneHVAC:LowTemperatureRadiant:VariableFlow';
  ControlType := 'Active';
  DemandControlType := 'Active';
  coldWaterComponent := TSystemComponent.Create;
  hotWaterComponent := TSystemComponent.Create;
  coldWaterComponent.ComponentType := 'ZoneHVAC:LowTemperatureRadiant:VariableFlow';
  hotWaterComponent.ComponentType := 'ZoneHVAC:LowTemperatureRadiant:VariableFlow';
  coldWaterComponent.DemandControlType := 'Active';
  hotWaterComponent.DemandControlType := 'Active';

  UserProvidedName := '';
  AvailabilitySchedule := 'HVACOperationSchd';
  TubingInsideDiameter := 0.01905;
  TubingLength := -1.0;
  TempControlType := 'MeanRadiantTemperature';
  MaxHotWaterFlow := -1.0;
  HeatingThrottlingRange := 0.5;
  HeatingTempSchedule := 'HTGSETP_SCH';
  MaxChilledWaterFlow := -1.0;
  CoolingThrottlingRange := 0.5;
  CoolingTempSchedule := 'CLGSETP_SCH';
  CondensationControlType := 'SimpleOff';
  CondensationControlDewpointOffset := 0.5;
end;

procedure T_EP_LowTempRadiantVariableFlow.Finalize;
begin
  inherited;
end;

procedure T_EP_LowTempRadiantVariableFlow.SetZone(ZoneParameter: T_EP_Zone);
begin
  inherited;
  if Assigned(ZoneParameter) then
  begin
    ZoneValue := ZoneParameter;
    if (UserProvidedName <> '') then
      Name := Zone.Name + ' ' + UserProvidedName
    else
      Name := Zone.Name + ' LowTempRadiantConstantFlow';
    coldWaterComponent.Name := self.Name;
    hotWaterComponent.Name := self.Name;
    hotWaterComponent.DemandInletNode := hotWaterComponent.Name + ' Heating Demand Inlet Node';
    hotWaterComponent.DemandOutletNode := hotWaterComponent.Name + ' Heating Demand Outlet Node';
    coldWaterComponent.DemandInletNode := coldWaterComponent.Name + ' Cooling Demand Inlet Node';
    coldWaterComponent.DemandOutletNode := coldWaterComponent.Name + ' Cooling Demand Outlet Node';
    if (self.LowTempRadiantSurfaceGroup <> nil) then
    begin
      self.LowTempRadiantSurfaceGroup.Name := self.Name + 'RadiantSurfaceGroup';
    end;
  end;
end;

procedure T_EP_LowTempRadiantVariableFlow.ToIDF;
var
  Obj: TEnergyPlusObject;
begin
  Obj := IDF.AddObject(ComponentType);
  Obj.AddField('Name', Name);
  Obj.AddField('Availability Schedule Name', self.AvailabilitySchedule);
  Obj.AddField('Zone Name',Zone.Name);
  if (self.LowTempRadiantSurfaceGroup <> nil) then
    Obj.AddField('Surface Name or Radiant Surface Group Name',self.LowTempRadiantSurfaceGroup.Name)
  else if (self.Zone.LowTempRadiantSurfaceGroup <> nil) then
    Obj.AddField('Surface Name or Radiant Surface Group Name',self.Zone.LowTempRadiantSurfaceGroup.Name)
  else
    Obj.AddField('Surface Name or Radiant Surface Group Name','');
  Obj.AddField('Hydronic Tubing Inside Diameter',self.TubingInsideDiameter,'{m}');
  if self.TubingLength < 0.0 then
    Obj.AddField('Hydronic Tubing Length','autosize','{m}')
  else
    Obj.AddField('Hydronic Tubing Length',self.TubingLength,'{m}');
  Obj.AddField('Temperature Control Type',self.TempControlType);
  if not SameText(self.hotWaterComponent.LiquidSystemName,'NONE') then
  begin
    if self.MaxHotWaterFlow < 0.0 then
      Obj.AddField('Maximum Hot Water Flow','autosize','{m3/s}')
    else
      Obj.AddField('Maximum Hot Water Flow',self.MaxHotWaterFlow,'{m3/s}');
    Obj.AddField('Heating Water Inlet Node Name',self.hotWaterComponent.DemandInletNode);
    Obj.AddField('Heating Water Outlet Node Name',self.hotWaterComponent.DemandOutletNode);
    Obj.AddField('Heating Control Throttling Range',self.HeatingThrottlingRange, '{deltaC}');
    Obj.AddField('Heating Control Temperature Schedule Name',self.HeatingTempSchedule);
  end
  else
  begin
    Obj.AddField('Maximum Hot Water Flow','','{m3/s}');
    Obj.AddField('Heating Water Inlet Node Name','');
    Obj.AddField('Heating Water Outlet Node Name','');
    Obj.AddField('Heating Control Throttling Range','', '{deltaC}');
    Obj.AddField('Heating Control Temperature Schedule Name','');
  end;
  if not SameText(self.coldWaterComponent.LiquidSystemName,'NONE') then
  begin
    if self.MaxChilledWaterFlow < 0.0 then
      Obj.AddField('Maximum Cold Water Flow','autosize', '{m3/s}')
    else
      Obj.AddField('Maximum Cold Water Flow',self.MaxChilledWaterFlow, '{m3/s}');
    Obj.AddField('Cooling Water Inlet Node Name',self.coldWaterComponent.DemandInletNode);
    Obj.AddField('Cooling Water Outlet Node Name',self.coldWaterComponent.DemandOutletNode);
    Obj.AddField('Cooling Control Throttling Range',self.CoolingThrottlingRange,'{deltaC}');
    Obj.AddField('Cooling Control Temperature Schedule Name',self.CoolingTempSchedule);
    Obj.AddField('Condensation Control Type',self.CondensationControlType);
    Obj.AddField('Condensation Control Dewpoint Offset',self.CondensationControlDewpointOffset);
  end
  else
  begin
    Obj.AddField('Maximum Cold Water Flow','', '{m3/s}');
    Obj.AddField('Cooling Water Inlet Node Name','');
    Obj.AddField('Cooling Water Outlet Node Name','');
    Obj.AddField('Cooling Control Throttling Range','','{deltaC}');
    Obj.AddField('Cooling Control Temperature Schedule Name','');
    Obj.AddField('Condensation Control Type','');
    Obj.AddField('Condensation Control Dewpoint Offset','');
  end;
  if (self.LowTempRadiantSurfaceGroup <> nil) then
    self.LowTempRadiantSurfaceGroup.ToIDF;
end;

{T_EP_BaseboardHeaterConvectiveElectric}

constructor T_EP_BaseboardHeaterConvectiveElectric.Create;
begin
  ComponentType := 'ZoneHVAC:Baseboard:Convective:Electric';
  ControlType := 'Active';
  DemandControlType := 'Active';
end;

procedure T_EP_BaseboardHeaterConvectiveElectric.Finalize;
begin
  inherited;
end;

procedure T_EP_BaseboardHeaterConvectiveElectric.SetZone(ZoneParameter: T_EP_Zone);
begin
  inherited;
  if Assigned(ZoneParameter) then
  begin
    ZoneValue := ZoneParameter;
    Name := Zone.Name + ' Baseboard Heater';
    DemandInletNode := '';
    DemandOutletNode := '';
  end;
end;

procedure T_EP_BaseboardHeaterConvectiveElectric.ToIDF;
var
  Obj: TEnergyPlusObject;
begin
  Obj := IDF.AddObject(ComponentType);  //'ZoneHVAC:Baseboard:Convective:Electric'
  Obj.AddField('Name', Name);
  Obj.AddField('Availability Schedule Name', 'ALWAYS_ON');
  Obj.AddField('Nominal Capacity', 'AUTOSIZE');
  Obj.AddField('Efficiency', '1.0');
end;

{T_EP_WindowAC}

constructor T_EP_WindowAC.Create;
begin
  inherited;
  ComponentType := 'ZoneHVAC:WindowAirConditioner';
  ControlType := 'Passive';
  DemandControlType := 'Passive';
  DataSetKey := 'DefaultWindowAC'
end;

procedure T_EP_WindowAC.Finalize;
begin
  inherited;
end;

procedure T_EP_WindowAC.SetZone(ZoneParameter: T_EP_Zone);
begin
  if Assigned(ZoneParameter) then
  begin
    ZoneValue := ZoneParameter;
    Name := Zone.Name + ' Window AC';
    DemandInletNode := Name + ' WinAC Exhaust Node';
    DemandOutletNode := Name + ' Inlet Node Name';
    Zone.AirInletNodes.Add(DemandOutletNode);
    Zone.AirExhaustNodes.Add(DemandInletNode);
  end;
end;

procedure T_EP_WindowAC.ToIDF;
var
  Obj: TEnergyPlusObject;
begin
  Obj := IDF.AddObject(ComponentType); //'ZoneHVAC:WindowAirConditioner';
  Obj.AddField('Name', Name);
  Obj.AddField('Availability Schedule Name', 'ALWAYS_ON');
  Obj.AddField('Maximum Supply Air Flow Rate', 'AUTOSIZE');
  if zone.EconomizeViaZoneERV then
    Obj.AddField('Maximum Outdoor Air Flow Rate', '0.0')
  else
    Obj.AddField('Maximum Outdoor Air Flow Rate', 'AUTOSIZE');
  Obj.AddField('Air Inlet Node Name', DemandInletNode);
  Obj.AddField('Air Outlet Node Name', DemandOutletNode);
  Obj.AddField('Outdoor Air Mixer Object Type', 'OutdoorAir:Mixer');
  Obj.AddField('Outdoor Air Mixer Name', Name + ' OA Mixer');
  if SameText(ControlMode, 'ContinuousFanWithCyclingCompressor') then
    Obj.AddField('Supply Air Fan Object Type', 'Fan:ConstantVolume')
  else if SameText(ControlMode, 'CyclingFanAndCompressor') then
    Obj.AddField('Supply Air Fan Object Type', 'Fan:OnOff');
  Obj.AddField('Fan Name', Name + 'Fan');
  Obj.AddField('Cooling Coil Object Type', 'Coil:Cooling:DX:SingleSpeed');
  Obj.AddField('DX Cooling Coil Name', Name + 'Coil');
  obj.AddField('Supply Air Fan Operating Mode Schedule Name', Name + ' Mode Sched' );
  Obj.AddField('Fan Placement', 'BlowThrough');
  Obj.AddField('Cooling Convergence Tolerance', '0.001');
  //control mode schedules
  Obj := IDF.AddObject('Schedule:Compact');
  Obj.AddField('Name', Name + ' Mode Sched');
  Obj.AddField('Schedule Type Limits Name', 'ANY NUMBER');
  Obj.AddField('Field 1', 'Through: 12/31');
  Obj.AddField('Field 2', 'For: AllDays');
  Obj.AddField('Field 3', 'Until: 24:00');
  if SameText(ControlMode, 'ContinuousFanWithCyclingCompressor') then
    Obj.AddField('Field 4', '1.0')
  else if SameText(ControlMode, 'CyclingFanAndCompressor') then
    Obj.AddField('Field 4', '0.0');
  //fan
  if SameText(ControlMode, 'ContinuousFanWithCyclingCompressor') then
    Obj := IDF.AddObject('Fan:ConstantVolume')
  else if SameText(ControlMode, 'CyclingFanAndCompressor') then
    Obj := IDF.AddObject('Fan:OnOff');
  Obj.AddField('Name', Name + 'Fan');
  Obj.AddField('Availability Schedule Name', 'ALWAYS_ON');
  Obj.AddField('Fan Efficiency', FloatToStr(FanEfficiency), '{}');
  Obj.AddField('Pressure Rise', FloatToStr(FanPressureDrop), '{Pa}');
  Obj.AddField('Maximum Flow Rate', 'AUTOSIZE', '{m3/s}');
  Obj.AddField('Motor Efficiency', '0.85', '{}');
  Obj.AddField('Motor In Airstream Fraction', '1.0', '{}');
  Obj.AddField('Air Inlet Node Name', Name + 'Fan Inlet');
  Obj.AddField('Air Outlet Node Name', Name + ' Fan Outlet');
  if SameText(ControlMode, 'CyclingFanAndCompressor') then
  begin
    Obj.AddField('Fan Power Ratio Function of Speed Ratio Curve Name', '');
    Obj.AddField('Fan Efficiency Ratio Function of Speed Ratio Curve Name', '');
  end;
  Obj.AddField('End-Use Subcategory', 'Window AC Fan');
  
  //oa mixer
  Obj := IDF.AddObject('OutdoorAir:Mixer');
  Obj.AddField('Name', Name + ' OA Mixer');
  Obj.AddField('Mixed Air Node Name', Name + 'Fan Inlet');
  Obj.AddField('Outdoor Air Stream Node Name', Name + ' OA Node');
  Obj.AddField('Relief Air Stream Node Name', Name + ' Relief Node');
  Obj.AddField('Return Air Stream Node Name', DemandInletNode);
  //oa node
  Obj := IDF.AddObject('OutdoorAir:Node');
  Obj.AddField('Name', Name + ' OA Node');
  //cooling coil
  Obj := IDF.AddObject('Coil:Cooling:DX:SingleSpeed');
  Obj.AddField('Name', Name + 'Coil');
  Obj.AddField('Availability Schedule Name', 'ALWAYS_ON');
  Obj.AddField('Rated Total Cooling Capacity', 'AUTOSIZE', '{W}');
  Obj.AddField('Rated Sensible Heat Ratio', 'AUTOSIZE', '{}');
  Obj.AddField('Rated COP', FloatToStr(COP), '{}');
  Obj.AddField('Rated Air Flow Rate', 'AUTOSIZE', '{m3/s}');
  Obj.AddField('Rated Evaporator Fan Power Per Volume Flow Rate', '773.3', '{W/(m3/s)}');
  Obj.AddField('Air Inlet Node Name', name + ' Fan outlet');
  Obj.AddField('Air Outlet Node Name', DemandOutletNode);
  Obj.AddField('Total Cooling Capacity Function of Temperature Curve Name', Name + '_ClgCapFuncTempCurve');
  Obj.AddField('Total Cooling Capacity Function of Flow Fraction Curve Name', Name + '_ClgCapFuncFlowFracCurve');
  Obj.AddField('Energy Input Ratio Function of Temperature Curve Name', Name + '_ClgEirFuncTempCurve');
  Obj.AddField('Energy Input Ratio Function of Flow Fraction Curve Name', Name + '_ClgEirFuncFlowFracCurve');
  Obj.AddField('Part Load Fraction Correlation Curve Name', Name + '_ClgPlrCurve');
  if not SuppressLatDeg then
  begin
    Obj.AddField('Nominal Time for Condensate Removal to Begin', '1000.0', '{s}');
    Obj.AddField('Ratio of Initial Moisture Evaporation Rate and Steady State Latent Capacity', '1.5', '{}');
    Obj.AddField('Maximum Cycling Rate', '3.0', '{cycles/hr}');
    Obj.AddField('Latent Capacity Time Constant', '45.0', '{s}');
    Obj.AddField('Condenser Air Inlet Node Name', Name + '_CondAirInletNode');
    if EvapCondEff > 0.0 then
    begin
      Obj.AddField('Condenser Type', 'EvaporativelyCooled');
      Obj.AddField('Evaporative Condenser Effectiveness', EvapCondEff, '{}');
      Obj.AddField('Evaporative Condenser Air Flow Rate', 'AUTOSIZE', '{m3/s}');
      Obj.AddField('Evaporative Condenser Pump Rated Power Consumption', 'AUTOSIZE', '{W}');
    end
    else
    begin
      Obj.AddField('Condenser Type', 'AirCooled');
      Obj.AddField('Evaporative Condenser Effectiveness', '', '{}');
      Obj.AddField('Evaporative Condenser Air Flow Rate', '', '{m3/s}');
      Obj.AddField('Evaporative Condenser Pump Rated Power Consumption', '', '{W}');
    end;
    Obj.AddField('Crankcase Heater Capacity', '', '{W}');
    Obj.AddField('Maximum Outdoor Dry-Bulb Temperature for Crankcase Heater Operation', '', '{C}');
    Obj.AddField('Supply Water Storage Tank Name', '');
    Obj.AddField('Condensate Collection Water Storage Tank Name', '');
    if EvapCondEff > 0.0 then
    begin
      Obj.AddField('Basin Heater Capacity', '10.0', '{W/K}');
      Obj.AddField('Basin Heater Setpoint Temperature', '2.0', '{C}');
      Obj.AddField('Basin Heater Operating Schedule Name', '');
    end
    else
    begin
      Obj.AddField('Basin Heater Capacity', '', '{W/K}');
      Obj.AddField('Basin Heater Setpoint Temperature', '', '{C}');
      Obj.AddField('Basin Heater Operating Schedule Name', '');
    end;
  end;
  //add outdoor air node
  Obj := IDF.AddObject('OutdoorAir:Node');
  Obj.AddField('Node Name', Name + '_CondAirInletNode');
  //get dx curves
  GetDxCurves(DataSetKey, 'Clg', Name, '');
end;

{T_EP_PTAC}

constructor T_EP_PTAC.Create;
begin
  inherited;
  ComponentType := 'ZoneHVAC:PackagedTerminalAirConditioner';
  ControlType := 'Passive';
  DemandControlType := 'Passive';
  SuppressOA := False ;
  ControlMode := 'CyclingFanAndCompressor';
  DataSetKey := 'DefaultPTAC';
  AvailSch := 'ALWAYS_ON';
end;

procedure T_EP_PTAC.Finalize;
begin
  inherited;
end;

procedure T_EP_PTAC.SetZone(ZoneParameter: T_EP_Zone);
begin
  if Assigned(ZoneParameter) then
  begin
    ZoneValue := ZoneParameter;
    Name := Zone.Name + ' PTAC';
    DemandInletNode := Zone.Name + ' PTAC Exhaust Node';
    DemandOutletNode := Zone.Name + ' PTAC Inlet Node';
    Zone.AirInletNodes.Add(DemandOutletNode);
    Zone.AirExhaustNodes.Add(DemandInletNode);
  end;
end;

procedure T_EP_PTAC.setHeatCoil(CoilParameter: string);
begin
  if SameText(CoilParameter, 'Gas') then
    HeatCoilTypeValue := 'Coil:Heating:Gas'
  else if SameText(CoilParameter, 'WATER') then
    HeatCoiltypeValue := 'Coil:Heating:Water'
  else if SameText(CoilParameter, 'ELECTRICITY') then
    HeatCoilTypeValue := 'Coil:Heating:Electric'
  else if CoilParameter = 'STEAM' then
    HeatCoilTypeValue := 'Coil:Heating:Steam'
  else
    writeln('PTAC could not find Coil Parameter ' + CoilParameter);
end;

procedure T_EP_PTAC.ToIDF;
var
  Obj: TEnergyPlusObject;
begin
  Obj := IDF.AddObject(ComponentType); //ZoneHVAC:PackagedTerminalAirConditioner
  Obj.AddField('Name', Name);
  Obj.AddField('Availability Schedule Name', AvailSch);
  Obj.AddField('Air Inlet Node Name', DemandInletNode);
  Obj.AddField('Air Outlet Node Name', DemandOutletNode);
  Obj.AddField('Outdoor Air Mixer Object Type', 'OutdoorAir:Mixer');
  Obj.AddField('Outdoor Air Mixer Name', Name + ' OA Mixer');
  Obj.AddField('Supply Air Flow Rate During Cooling Operation', 'AUTOSIZE');
  Obj.AddField('Supply Air Flow Rate During Heating Operation', 'AUTOSIZE');
  Obj.AddField('Supply Air Flow Rate When No Cooling or Heating is Needed', 'AUTOSIZE');
  if (Zone.OAviaZoneERV or SuppressOA) then
  begin
    Obj.AddField('Outdoor Air Flow Rate During Cooling Operation', '0.0');
    Obj.AddField('Outdoor Air Flow Rate During Heating Operation', '0.0');
    Obj.AddField('Outdoor Air Flow Rate When No Cooling or Heating is Needed', '0.0');
  end
  else
  begin
    Obj.AddField('Outdoor Air Flow Rate During Cooling Operation', 'AUTOSIZE');
    Obj.AddField('Outdoor Air Flow Rate During Heating Operation', 'AUTOSIZE');
    Obj.AddField('Outdoor Air Flow Rate When No Cooling or Heating is Needed', 'AUTOSIZE');
  end;
  if SameText(ControlMode, 'ContinuousFanWithCyclingCompressor') then
    Obj.AddField('Supply Air Fan Object Type', 'Fan:ConstantVolume')
  else if SameText(ControlMode, 'CyclingFanAndCompressor') then
    Obj.AddField('Supply Air Fan Object Type', 'Fan:OnOFF');
  Obj.AddField('Supply Air Fan Name', Name + 'Fan');
  if SameText(HeatCoilType, 'Coil:Heating:Gas') then
    Obj.AddField('Heating Coil Object Type', 'Coil:Heating:Gas')
  else if SameText(HeatCoilType, 'Coil:Heating:Electric') then
    Obj.AddField('Heating Coil Object Type', 'Coil:Heating:Electric')
  else if SameText(HeatCoilType, 'Coil:Heating:Water') then
    Obj.AddField('Heating Coil Object Type', 'Coil:Heating:Water');
  Obj.AddField('Heating Coil Name', Name + ' Heat Coil');
  Obj.AddField('Cooling Coil Object Type', 'Coil:Cooling:DX:SingleSpeed');
  Obj.AddField('Cooling Coil Name', Name + ' DX Coil');
  Obj.AddField('Fan Placement', 'DrawThrough');
  if SameText(ControlMode, 'ContinuousFanWithCyclingCompressor') then
    Obj.AddField('Supply Air Fan Operating Mode Schedule Name', 'ALWAYS_ON')
  else if SameText(ControlMode, 'CyclingFanAndCompressor') then
    Obj.AddField('Supply Air Fan Operating Mode Schedule Name', 'ALWAYS_OFF');
  //fan
  if SameText(ControlMode, 'ContinuousFanWithCyclingCompressor') then
    Obj := IDF.AddObject('Fan:ConstantVolume')
  else if SameText(ControlMode, 'CyclingFanAndCompressor') then
    Obj := IDF.AddObject('Fan:OnOff');
  Obj.AddField('Name', Name + 'Fan');
  Obj.AddField('Availability Schedule Name', 'ALWAYS_ON');
  Obj.AddField('Fan Efficiency', FloatToStr(FanEfficiency), '{}');
  Obj.AddField('Pressure Rise', FloatToStr(FanPressureDrop), '{Pa}');
  Obj.AddField('Maximum Flow Rate', 'AUTOSIZE', '{m3/s}');
  Obj.AddField('Motor Efficiency', '0.85', '{}');
  Obj.AddField('Motor In Airstream Fraction', '1.0', '{}');
  Obj.AddField('Air Inlet Node Name', Name + 'Fan Inlet');
  Obj.AddField('Air Outlet Node Name', DemandOutletNode);
  if SameText(ControlMode, 'CyclingFanAndCompressor') then
  begin
    Obj.AddField('Fan Power Ratio Function of Speed Ratio Curve Name', '');
    Obj.AddField('Fan Efficiency Ratio Function of Speed Ratio Curve Name', '');
  end;
  Obj.AddField('End-Use Subcategory', 'PTAC Fan');
  //oa mixer
  Obj := IDF.AddObject('OutdoorAir:Mixer');
  Obj.AddField('Name', Name + ' OA Mixer');
  Obj.AddField('Mixed Air Node Name', name + 'DX Cool Inlet');
  Obj.AddField('Outside Air Stream Node Name', name + ' OA Node');
  Obj.AddField('Relief Air Stream Node Name', name + ' Relief Node');
  Obj.AddField('Return Air Stream Node Name', DemandInletNode);
  //oa node
  Obj := IDF.AddObject('OutdoorAir:Node');
  OBj.AddField('Name', name + ' OA Node');
  //dx coil
  Obj := IDF.AddObject('Coil:Cooling:DX:SingleSpeed');
  Obj.AddField('Name', Name + ' DX Coil');
  Obj.AddField('Availability Schedule Name', 'ALWAYS_ON');
  Obj.AddField('Rated Total Cooling Capacity', 'AUTOSIZE', '{W}');
  Obj.AddField('Rated Sensible Heat Ratio', 'AUTOSIZE', '{}');
  Obj.AddField('Rated COP', FloatToStr(CoolCOP), '{}');
  Obj.AddField('Rated Air Flow Rate', 'AUTOSIZE', '{m3/s}');
  Obj.AddField('Rated Evaporator Fan Power Per Volume Flow Rate', '773.3', '{W/(m3/s)}');
  Obj.AddField('Air Inlet Node Name', Name + 'DX Cool Inlet');
  Obj.AddField('Air Outlet Node Name', Name + ' Post CC Node');
  Obj.AddField('Total Cooling Capacity Function of Temperature Curve Name', Name + '_ClgCapFuncTempCurve');
  Obj.AddField('Total Cooling Capacity Function of Flow Fraction Curve Name', Name + '_ClgCapFuncFlowFracCurve');
  Obj.AddField('Energy Input Ratio Function of Temperature Curve Name', Name + '_ClgEirFuncTempCurve');
  Obj.AddField('Energy Input Ratio Function of Flow Fraction Curve Name', Name + '_ClgEirFuncFlowFracCurve');
  Obj.AddField('Part Load Fraction Correlation Curve Name', Name + '_ClgPlrCurve');
  Obj.AddField('Nominal Time for Condensate Removal to Begin', '1000.0', '{s}');
  if not SuppressLatDeg then
  begin
    Obj.AddField('Ratio of Initial Moisture Evaporation Rate and Steady State Latent Capacity', '1.5', '{}');
    Obj.AddField('Maximum Cycling Rate', '3.0', '{cycles/hr}');
    Obj.AddField('Latent Capacity Time Constant', '45.0', '{s}');
    Obj.AddField('Condenser Air Inlet Node Name', Name + '_CondAirInletNode');
    if EvapCondEff > 0.0 then
    begin
      Obj.AddField('Condenser Type', 'EvaporativelyCooled');
      Obj.AddField('Evaporative Condenser Effectiveness', EvapCondEff, '{}');
      Obj.AddField('Evaporative Condenser Air Flow Rate', 'AUTOSIZE', '{m3/s}');
      Obj.AddField('Evaporative Condenser Pump Rated Power Consumption', 'AUTOSIZE', '{W}');
    end
    else
    begin
      Obj.AddField('Condenser Type', 'AirCooled');
      Obj.AddField('Evaporative Condenser Effectiveness', '', '{}');
      Obj.AddField('Evaporative Condenser Air Flow Rate', '', '{m3/s}');
      Obj.AddField('Evaporative Condenser Pump Rated Power Consumption', '', '{W}');
    end;
    Obj.AddField('Crankcase Heater Capacity', '', '{W}');
    Obj.AddField('Maximum Outdoor Dry-Bulb Temperature for Crankcase Heater Operation', '', '{C}');
    Obj.AddField('Supply Water Storage Tank Name', '');
    Obj.AddField('Condensate Collection Water Storage Tank Name', '');
    if EvapCondEff > 0.0 then
    begin
      Obj.AddField('Basin Heater Capacity', '10.0', '{W/K}');
      Obj.AddField('Basin Heater Setpoint Temperature', '2.0', '{C}');
      Obj.AddField('Basin Heater Operating Schedule Name', '');
    end
    else
    begin
      Obj.AddField('Basin Heater Capacity', '', '{W/K}');
      Obj.AddField('Basin Heater Setpoint Temperature', '', '{C}');
      Obj.AddField('Basin Heater Operating Schedule Name', '');
    end;
  end;
  //add outdoor air node
  Obj := IDF.AddObject('OutdoorAir:Node');
  Obj.AddField('Node Name', Name + '_CondAirInletNode');
  // dx curves
  GetDxCurves(DataSetKey, 'Clg', Name, '');
  if SameText(HeatCoilType, 'Coil:Heating:Gas') then
  begin
    Obj := IDF.AddObject('Coil:Heating:Gas');
    Obj.AddField('Name', Name + ' Heat Coil');
    Obj.AddField('Availability Schedule Name', 'ALWAYS_ON');
    Obj.AddField('Gas Burner Efficiency', FloatToStr(HeatCoilEfficiency), '{}');
    Obj.AddField('Nominal Capacity', 'AUTOSIZE', '{W}');
    Obj.AddField('Air Inlet Node Name', Name + ' Post CC Node');
    Obj.AddField('Air Outlet Node Name', Name + 'Fan Inlet');
  end
  else if SameText(HeatCoilType, 'Coil:Heating:Electric') then
  begin
    Obj := IDF.AddObject('Coil:Heating:Electric');
    Obj.AddField('Name', Name + ' Heat Coil');
    Obj.AddField('Availability Schedule Name', 'ALWAYS_ON');
    Obj.AddField('Efficiency', '1.0');
    Obj.AddField('Nominal Capacity', 'AUTOSIZE', '{W}');
    Obj.AddField('Air Inlet Node Name', Name + ' Post CC Node');
    Obj.AddField('Air Outlet Node Name', Name + 'Fan Inlet'); // correct for cooling add
  end
  else if SameText(HeatCoilType, 'Coil:Heating:Water') then
  begin
    HWcoil.DemandControlType := 'Active';
    HWcoil.SupplyInletNode := Name + ' Post CC Node';
    HWCoil.Name := Name + ' Heat Coil';
    HWcoil.SupplyOutletNode := Name + 'Fan Inlet'; // correct for cooling add
    T_EP_Coil(HWcoil).ToIDF;
  end;
end;

{T_EP_PTHP}

constructor T_EP_PTHP.Create;
begin
  inherited;
  ComponentType := 'ZoneHVAC:PackagedTerminalHeatPump';
  ControlType := 'CyclingFanAndCompressor';
  DemandControlType := 'Passive';
  DataSetKey := 'DefaultPTHP'
end;

procedure T_EP_PTHP.Finalize;
begin
  inherited;
end;

procedure T_EP_PTHP.SetZone(ZoneParameter: T_EP_Zone);
begin
  if Assigned(ZoneParameter) then
  begin
    ZoneValue := ZoneParameter;
    Name := Zone.Name + ' PTHP';
    DemandInletNode := Zone.Name + ' PTHP Exhaust Node';
    DemandOutletNode := Zone.Name + ' PTHP Inlet Node';
    Zone.AirInletNodes.Add(DemandOutletNode);
    Zone.AirExhaustNodes.Add(DemandInletNode);
  end;
end;

procedure T_EP_PTHP.ToIDF;
var
  Obj: TEnergyPlusObject;
begin
  Obj := IDF.AddObject(ComponentType); //'ZoneHVAC:PackagedTerminalHeatPump'
  Obj.AddField('Name', Name);
  Obj.AddField('Availability Schedule Name', 'ALWAYS_ON');
  Obj.AddField('Air Inlet Node Name', DemandInletNode);
  Obj.AddField('Air Outlet Node Name', DemandOutletNode);
  Obj.AddField('Outdoor Air Mixer Object Type', 'OutdoorAir:Mixer');
  Obj.AddField('Outdoor Air Mixer Name', Name + ' OA Mixer');
  Obj.AddField('Supply Air Flow Rate During Cooling Operation', 'AUTOSIZE');
  Obj.AddField('Supply Air Flow Rate During Heating Operation', 'AUTOSIZE');
  Obj.AddField('Supply Air Flow Rate When No Cooling or Heating is Needed', 'AUTOSIZE');
  if Zone.OAviaZoneERV then
  begin
    Obj.AddField('Outdoor Air Flow Rate During Cooling Operation', '0.0');
    Obj.AddField('Outdoor Air Flow Rate During Heating Operation', '0.0');
    Obj.AddField('Outdoor Air Flow Rate When No Cooling or Heating is Needed', '0.0');
  end
  else
  begin
    Obj.AddField('Outdoor Air Flow Rate During Cooling Operation', 'AUTOSIZE');
    Obj.AddField('Outdoor Air Flow Rate During Heating Operation', 'AUTOSIZE');
    Obj.AddField('Outdoor Air Flow Rate When No Cooling or Heating is Needed', 'AUTOSIZE');
  end;
  Obj.AddField('Supply Air Fan Object Type', 'Fan:OnOff');
  Obj.AddField('Supply Air Fan Name', Name + 'Fan');
  Obj.AddField('Heating Coil Object Type', 'Coil:Heating:DX:SingleSpeed');
  Obj.AddField('Heating Coil Name', Name + ' Heat Pump');
  Obj.AddField('Heating Convergence Tolerance', '0.001');
  Obj.AddField('Minimum Outdoor Dry-Bulb Temperature for Compressor Operation', '-8.0');
  Obj.AddField('Cooling Coil Object Type', 'Coil:Cooling:DX:SingleSpeed');
  Obj.AddField('Cooling Coil Name', Name + ' DX Coil');
  Obj.AddField('Cooling Convergence Tolerance', '0.001');
  Obj.AddField('Supplemental Heating Coil Object Type', 'Coil:Heating:Electric');
  Obj.AddField('Supplemental Heating Coil Name', name + ' Supplmnt Htg Coil');
  Obj.AddField('Maximum Supply Air Temperature from Supplemental Heater', 'AUTOSIZE', '{C}');
  Obj.AddField('Maximum Outdoor Dry-Bulb Temperature for Supplemental Heater Operation', '18.0', '{C}');
  Obj.AddField('Fan Placement', 'DrawThrough');
  Obj.AddField('Supply Air Fan Operating Mode Schedule Name',  Name + ' Mode Sched');
  //mode schedule
  Obj := IDF.AddObject('Schedule:Compact');
  Obj.AddField('Name', Name + ' Mode Sched');
  Obj.AddField('Schedule Type Limits Name', 'ANY NUMBER');
  Obj.AddField('Field 1', 'Through: 12/31');
  Obj.AddField('Field 2', 'For: AllDays');
  Obj.AddField('Field 3', 'Until: 24:00');
  if SameText(ControlMode, 'ContinuousFanWithCyclingCompressor') then
    Obj.AddField('Field 4', '1.0')
  else if SameText(ControlMode, 'CyclingFanAndCompressor') then
    Obj.AddField('Field 4', '0.0');
  if SameText(ControlMode, 'ContinuousFanWithCyclingCompressor') then
    Obj := IDF.AddObject('Fan:ConstantVolume')
  else if SameText(ControlMode, 'CyclingFanAndCompressor') then
    Obj := IDF.AddObject('Fan:OnOff');
  Obj.AddField('Name', Name + 'Fan');
  Obj.AddField('Availability Schedule Name', 'ALWAYS_ON');
  Obj.AddField('Fan Efficiency', FloatToStr(FanEfficiency), '{}');
  Obj.AddField('Pressure Rise', FloatToStr(FanPressureDrop), '{Pa}');
  Obj.AddField('Maximum Flow Rate', 'AUTOSIZE', '{m3/s}');
  Obj.AddField('Motor Efficiency', '0.85', '{}');
  Obj.AddField('Motor In Airstream Fraction', '1.0', '{}');
  Obj.AddField('Air Inlet Node Name', Name + 'Fan Inlet');
  Obj.AddField('Air Outlet Node Name', Name + ' Fan Outlet');
  if SameText(ControlMode, 'CyclingFanAndCompressor') then
  begin
    Obj.AddField('Fan Power Ratio Function of Speed Ratio Curve Name', '');
    Obj.AddField('Fan Efficiency Ratio Function of Speed Ratio Curve Name', '');
  end;
  Obj.AddField('End-Use Subcategory', 'PTHP Fan');
  //oa mixer
  Obj := IDF.AddObject('OutdoorAir:Mixer');
  Obj.AddField('Name', Name + ' OA Mixer');
  Obj.AddField('Mixed Air Node Name', Name + 'DX Coil Inlet');
  Obj.AddField('Outside Air Stream Node Name', Name + ' OA Node');
  Obj.AddField('Relief Air Stream Node Name', Name + ' Relief Node');
  Obj.AddField('Return Air Stream Node Name', DemandInletNode);
  //oa node
  Obj := IDF.AddObject('OutdoorAir:Node');
  OBj.AddField('Name', Name + ' OA Node');
  //dx cooling coil
  Obj := IDF.AddObject('Coil:Cooling:DX:SingleSpeed');
  Obj.AddField('Name', Name + ' DX Coil');
  if SameText(typ, 'AirToAirHeatPumpHeatCool') then
    Obj.AddField('Availability Schedule Name', 'ALWAYS_ON')
  else if SameText(typ, 'AirToAirHeatPumpHeatOnly') then
    Obj.AddField('Availability Schedule Name', 'ALWAYS_OFF');
  Obj.AddField('Rated Total Cooling Capacity', 'AUTOSIZE', '{W}');
  Obj.AddField('Rated Sensible Heat Ratio', 'AUTOSIZE', '{}');
  Obj.AddField('Rated COP', FloatToStr(CoolCOP), '{}');
  Obj.AddField('Rated Air Flow Rate', 'AUTOSIZE', '{m3/s}');
  Obj.AddField('Rated Evaporator Fan Power Per Volume Flow Rate', '773.3', '{W/(m3/s)}');
  Obj.AddField('Air Inlet Node Name', Name + 'DX Coil Inlet');
  Obj.AddField('Air Outlet Node Name', Name + 'HeatCoil_AirInlet');
  Obj.AddField('Total Cooling Capacity Function of Temperature Curve Name', Name + '_ClgCapFuncTempCurve');
  Obj.AddField('Total Cooling Capacity Function of Flow Fraction Curve Name', Name + '_ClgCapFuncFlowFracCurve');
  Obj.AddField('Energy Input Ratio Function of Temperature Curve Name', Name + '_ClgEirFuncTempCurve');
  Obj.AddField('Energy Input Ratio Function of Flow Fraction Curve Name', Name + '_ClgEirFuncFlowFracCurve');
  Obj.AddField('Part Load Fraction Correlation Curve Name', Name + '_ClgPlrCurve');
  if not SuppressLatDeg then
  begin
    Obj.AddField('Nominal Time for Condensate Removal to Begin', '1000.0', '{s}');
    Obj.AddField('Ratio of Initial Moisture Evaporation Rate and Steady State Latent Capacity', '1.5', '{}');
    Obj.AddField('Maximum Cycling Rate', '3.0', '{cycles/hr}');
    Obj.AddField('Latent Capacity Time Constant', '45.0', '{s}');
    Obj.AddField('Condenser Air Inlet Node Name', Name + '_CondAirInletNode');
    if EvapCondEff > 0.0 then
    begin
      Obj.AddField('Condenser Type', 'EvaporativelyCooled');
      Obj.AddField('Evaporative Condenser Effectiveness', EvapCondEff, '{}');
      Obj.AddField('Evaporative Condenser Air Flow Rate', 'AUTOSIZE', '{m3/s}');
      Obj.AddField('Evaporative Condenser Pump Rated Power Consumption', 'AUTOSIZE', '{W}');
    end
    else
    begin
      Obj.AddField('Condenser Type', 'AirCooled');
      Obj.AddField('Evaporative Condenser Effectiveness', '', '{}');
      Obj.AddField('Evaporative Condenser Air Flow Rate', '', '{m3/s}');
      Obj.AddField('Evaporative Condenser Pump Rated Power Consumption', '', '{W}');
    end;
    Obj.AddField('Crankcase Heater Capacity', '', '{W}');
    Obj.AddField('Maximum Outdoor Dry-Bulb Temperature for Crankcase Heater Operation', '', '{C}');
    Obj.AddField('Supply Water Storage Tank Name', '');
    Obj.AddField('Condensate Collection Water Storage Tank Name', '');
    if EvapCondEff > 0.0 then
    begin
      Obj.AddField('Basin Heater Capacity', '10.0', '{W/K}');
      Obj.AddField('Basin Heater Setpoint Temperature', '2.0', '{C}');
      Obj.AddField('Basin Heater Operating Schedule Name', '');
    end
    else
    begin
      Obj.AddField('Basin Heater Capacity', '', '{W/K}');
      Obj.AddField('Basin Heater Setpoint Temperature', '', '{C}');
      Obj.AddField('Basin Heater Operating Schedule Name', '');
    end;
  end;
  //add outdoor air node
  Obj := IDF.AddObject('OutdoorAir:Node');
  Obj.AddField('Node Name', Name + '_CondAirInletNode');
  GetDxCurves(DataSetKey, 'Clg', Name, '');
  //dx heating coil
  Obj := IDF.AddObject('Coil:Heating:DX:SingleSpeed');
  Obj.AddField('Name', Name + ' Heat Pump');
  Obj.AddField('Availability Schedule Name', 'ALWAYS_ON');
  Obj.AddField('Rated Total Heating Capacity', 'AUTOSIZE', '{W}');
  Obj.AddField('Rated COP', FloatToStr(HeatCOP));
  Obj.AddField('Rated Air Flow Rate', 'AUTOSIZE');
  Obj.AddField('Rated Evaporator Fan Power Per Volume Flow Rate', '773.3');
  Obj.AddField('Air Inlet Node Name', Name + 'HeatCoil_AirInlet');
  Obj.AddField('Air Outlet Node Name', Name + 'Fan Inlet');
  Obj.AddField('Total Heating Capacity Function of Temperature Curve Name', Name + '_HtgCapFuncTempCurve');
  Obj.AddField('Total Heating Capacity Function of Flow Fraction Curve Name', Name + '_HtgCapFuncFlowFracCurve');
  Obj.AddField('Energy Input Ratio Function of Temperature Curve Name', Name + '_HtgEirFuncTempCurve');
  Obj.AddField('Energy Input Ratio Function of Flow Fraction Curve Name', Name + '_HtgEirFuncFlowFracCurve');
  Obj.AddField('Part Load Fraction Correlation Curve Name', Name + '_HtgPlrCurve');
  Obj.AddField('Defrost Energy Input Ratio Function of Temperature Curve Name', '');
  Obj.AddField('Minimum Outdoor Dry-Bulb Temperature for Compressor Operation', '-8.0');
  Obj.AddField('Outdoor Dry-Bulb Temperature to Turn On Compressor', '');
  Obj.AddField('Maximum Outdoor Dry-Bulb Temperature for Defrost Operation', '5.0');
  Obj.AddField('Crankcase Heater Capacity', '200.0', '{W}');
  Obj.AddField('Maximum Outdoor Dry-Bulb Temperature for Crankcase Heater Operation', '8.0', '{C}');
  Obj.AddField('Defrost Strategy', 'Resistive');
  Obj.AddField('Defrost Control', 'Timed');
  Obj.AddField('Defrost Time Period Fraction', '0.166667');
  Obj.AddField('Resistive Defrost Heater Capacity', 'AUTOSIZE', '{W}');
  Obj.AddField('Region Number For Calculating HSPF', '4');
  Obj.AddField('Evaporator Air Inlet Node Name', '');
  //get curves
  GetDxCurves(DataSetKey, 'Htg', Name, '');
  //supplemental heating coil
  Obj := IDF.AddObject('Coil:Heating:Electric');
  Obj.AddField('Name', name + ' Supplmnt Htg Coil');
  Obj.AddField('Availability Schedule Name', 'ALWAYS_ON');
  Obj.AddField('Efficiency', '1.0', '{}');
  Obj.AddField('Nominal Capacity', 'AUTOSIZE', '{W}');
  Obj.AddField('Air Inlet Node', Name + ' Fan Outlet');
  Obj.AddField('Air Outlet Node', DemandOutletNode);  
end;

{T_EP_HeatPumpWaterToAir}

constructor T_EP_HeatPumpWaterToAir.Create;
begin
  inherited;
  ComponentType := 'ZoneHVAC:WaterToAirHeatPump';
  DemandControlType := 'Passive';
end;

procedure T_EP_HeatPumpWaterToAir.Finalize;
begin
  inherited;
end;

procedure T_EP_HeatPumpWaterToAir.SetZone(ZoneParameter: T_EP_Zone);
begin
  if Assigned(ZoneParameter) then
  begin
    ZoneValue := ZoneParameter;
    Name := Zone.Name + ' Heat Pump';
    DemandInletNode := Zone.Name + ' Heat Pump Exhaust Node';
    DemandOutletNode := Zone.Name + ' Heat Pump Inlet Node';
    Zone.AirInletNodes.Add(DemandOutletNode);
    Zone.AirExhaustNodes.Add(DemandInletNode);
  end;
end;

procedure T_EP_HeatPumpWaterToAir.ToIDF;
var
  Obj: TEnergyPlusObject;
begin
  Obj := IDF.AddObject(ComponentType); //ZoneHVAC:WaterToAirHeatPump
  Obj.AddField('Name', Name);
  Obj.AddField('Availability Schedule Name', 'ALWAYS_ON');
  Obj.AddField('Air Inlet Node Name', DemandInletNode);
  Obj.AddField('Air Outlet Node Name', DemandOutletNode);
  Obj.AddField('Outdoor Air Mixer Object Type', 'OutdoorAir:Mixer');
  Obj.AddField('Outdoor Air Mixer Name', Name + ' OA Mixer');
  Obj.AddField('Supply Air Flow Rate During Cooling Operation', 'AUTOSIZE', '{m3/s}');
  Obj.AddField('Supply Air Flow Rate During Heating Operation', 'AUTOSIZE', '{m3/s}');
  if SameText(FanControl, 'Continuous') then
    Obj.AddField('Supply Air Flow Rate When No Cooling or Heating is Needed', 'AUTOSIZE', '{m3/s}')
  else if SameText(FanControl, 'Cycle') then
    Obj.AddField('Supply Air Flow Rate When No Cooling or Heating is Needed', '0.0', '{m3/s}');
  if SuppressOA then
  begin
    Obj.AddField('Outdoor Air Flow Rate During Cooling Operation', '0.0', '{m3/s}');
    Obj.AddField('Outdoor Air Flow Rate During Heating Operation', '0.0', '{m3/s}');
  end
  else
  begin
    Obj.AddField('Outdoor Air Flow Rate During Cooling Operation', 'AUTOSIZE', '{m3/s}');
    Obj.AddField('Outdoor Air Flow Rate During Heating Operation', 'AUTOSIZE', '{m3/s}');
  end;
  Obj.AddField('Outdoor Air Flow Rate When No Cooling or Heating is Needed', '', '{m3/s}');
  Obj.AddField('Supply Air Fan Object Type', 'Fan:OnOff');
  Obj.AddField('Supply Air Fan Name', Name + ' Fan');
  Obj.AddField('Heating Coil Object Type', 'Coil:Heating:WaterToAirHeatPump:EquationFit');
  Obj.AddField('Heating Coil Name', Name + ' Heat Coil');
  Obj.AddField('Cooling Coil Object Type', 'Coil:Cooling:WaterToAirHeatPump:EquationFit');
  Obj.AddField('Cooling Coil Name', Name + ' Cool Coil');
  Obj.AddField('Maximum Cycling Rate', '2.5', '{cycles/hr}');
  Obj.AddField('Heat Pump Time Constant', '60.0', '{s}');
  Obj.AddField('Fraction of On-Cycle Power Use', '0.01');
  Obj.AddField('Heat Pump Fan Delay Time', '60.0', '{s}');
  if SameText(SupHeatCoilType, 'Gas') then
    Obj.AddField('Supplemental Heating Coil Object Type', 'Coil:Heating:Gas')
  else if SameText(SupHeatCoilType, 'Electric') then
    Obj.AddField('Supplemental Heating Coil Object Type', 'Coil:Heating:Electric');
  Obj.AddField('Supplemental Heating Coil Name', Name + ' Sup Heat Coil');
  Obj.AddField('Maximum Supply Air Temperature from Supplemental Heater', 'AUTOSIZE', '{C}');
  Obj.AddField('Maximum Outdoor Dry-Bulb Temperature for Supplemental Heater Operation', '20.0', '{C}');
  Obj.AddField('Outdoor Dry-Bulb Temperature Sensor Node Name', Name + ' OA Node');
  Obj.AddField('Fan Placement', FanPlacement);
  if SameText(FanControl, 'Continuous') then
    Obj.AddField('Supply Air Fan Operating Mode Schedule Name', FanScheduleName)
  else if SameText(FanControl, 'Cycle') then
    Obj.AddField('Supply Air Fan Operating Mode Schedule Name', '');
  //oa mixer
  Obj := IDF.AddObject('OutdoorAir:Mixer');
  Obj.AddField('Name', Name + ' OA Mixer');
  Obj.AddField('Mixed Air Node Name', Name + ' Mixed Air Node');
  Obj.AddField('Outside Air Stream Node Name', Name + ' OA Node');
  Obj.AddField('Relief Air Stream Node Name', Name + ' Relief Node');
  Obj.AddField('Return Air Stream Node Name', DemandInletNode);
  //oa node
  Obj := IDF.AddObject('OutdoorAir:Node');
  Obj.AddField('Name', Name + ' OA Node');
  //fan
  Obj := IDF.AddObject('Fan:OnOff');
  Obj.AddField('Name', Name + ' Fan');
  Obj.AddField('Availability Schedule Name', FanScheduleName);
  Obj.AddField('Fan Efficiency', FloatToStr(FanEfficiency), '{}');
  Obj.AddField('Pressure Rise', FloatToStr(FanPressureDrop), '{Pa}');
  Obj.AddField('Maximum Flow Rate', 'AUTOSIZE', '{m3/s}');
  Obj.AddField('Motor Efficiency', FloatToStr(FanMotorEfficiency), '{}');
  Obj.AddField('Motor In Airstream Fraction', '1.0', '{}');
  if SameText(FanPlacement, 'BlowThrough') then
  begin
    Obj.AddField('Air Inlet Node Name', Name + ' Mixed Air Node');
    Obj.AddField('Air Outlet Node Name', Name + ' Cool Coil Air Inlet Node');
  end
  else if SameText(FanPlacement, 'DrawThrough') then
  begin
    Obj.AddField('Air Inlet Node Name', Name + ' Fan Inlet Node');
    Obj.AddField('Air Outlet Node Name', Name + ' Sup Heat Coil Air Inlet Node');
  end;
  Obj.AddField('Fan Power Ratio Function of Speed Ratio Curve Name', '');
  Obj.AddField('Fan Efficiency Ratio Function of Speed Ratio Curve Name', '');
  Obj.AddField('End-Use Subcategory', 'Heat Pump Fan');
  //heating coil
  GetHeatPumpEqnFitCoil(DataSetKey, 'Heat', Name, HeatCOP, FanPlacement);
  //cooling coil
  GetHeatPumpEqnFitCoil(DataSetKey, 'Cool', Name, CoolCOP, FanPlacement);
  //supplemental heating coil
  if SameText(SupHeatCoilType, 'Gas') then
  begin
    Obj := IDF.AddObject('Coil:Heating:Gas');
    Obj.AddField('Name', Name + ' Sup Heat Coil');
    Obj.AddField('Availability Schedule Name', 'ALWAYS_ON');
    Obj.AddField('Gas Burner Efficiency', SupHeatCoilEfficiency, '{}');
    Obj.AddField('Nominal Capacity', 'AUTOSIZE', '{W}');
    Obj.AddField('Air Inlet Node', Name + ' Sup Heat Coil Air Inlet Node');
    Obj.AddField('Air Outlet Node', DemandOutletNode);
  end
  else if SameText(SupHeatCoilType, 'Electric') then
  begin
    Obj := IDF.AddObject('Coil:Heating:Electric');
    Obj.AddField('Name', Name + ' Sup Heat Coil');
    Obj.AddField('Availability Schedule Name', 'ALWAYS_ON');
    Obj.AddField('Efficiency', SupHeatCoilEfficiency, '{}');
    Obj.AddField('Nominal Capacity', 'AUTOSIZE', '{W}');
    Obj.AddField('Air Inlet Node', Name + ' Sup Heat Coil Air Inlet Node');
    Obj.AddField('Air Outlet Node', DemandOutletNode);
  end;
end;

{ T_EP_OutdoorAirUnit }

constructor T_EP_OutdoorAirUnit.Create;
begin
  inherited;
  EquipList := TObjectList.Create;
  ComponentType := 'ZoneHVAC:OutdoorAirUnit';
  DemandControlType := 'Passive';
  OaRate := -9999.0;
  OaSch := 'ALWAYS_ON';
  CtrlType := 'NeutralControl';
  HighAirTempSch := '';
  LowAirTempSch := '';
  SupFanOutNode := '';
  HasExhFan := false;
  ExhFan := nil;
  ERV := nil;
  AvailSch := 'ALWAYS_ON';
end;

procedure T_EP_OutdoorAirUnit.Finalize;
var
  i: integer;
begin
  inherited;
  //supply path end nodes
  if EquipList.Count > 0 then
  begin
    THVACComponent(EquipList[0]).SupplyInletNode := Name + ' OA Node';
    THVACComponent(EquipList[EquipList.Count - 1]).SupplyOutletNode := DemandOutletNode;
    //supply path middle nodes
    for i := 0 to EquipList.Count - 2 do
    begin
      THVACComponent(EquipList[i]).SupplyOutletNode := THVACComponent(EquipList[i]).Name + ' ' + THVACComponent(EquipList[i + 1]).Name + ' Node';
      THVACComponent(EquipList[i + 1]).SupplyInletNode := THVACComponent(EquipList[i]).Name + ' ' + THVACComponent(EquipList[i + 1]).Name + ' Node';
      //pick out supply fan node
      if SameText(THVACComponent(EquipList[i]).ComponentType, 'Fan:ConstantVolume') or SameText(THVACComponent(EquipList[i]).ComponentType, 'Fan:VariableVolume') then
        SupFanOutNode := THVACComponent(EquipList[i]).SupplyOutletNode;
    end;
  end;
  //exhaust path end nodes
  if  ERV <> nil then
  begin
    ERV.ExhaustInletNode := DemandInletNode;
    if ExhFan <> nil then
    begin
      ERV.ExhaustOutletNode := ERV.Name + ' ' + ExhFan.Name + ' Node';
      ExhFan.SupplyInletNode := ERV.Name + ' ' + ExhFan.Name + ' Node';
      ExhFan.SupplyOutletNode := Name + ' Exhaust Node';
    end
    else
      ERV.ExhaustOutletNode := Name + ' Exhaust Node';
  end
  else if ExhFan <> nil then
  begin
    ExhFan.SupplyInletNode := DemandInletNode;
    ExhFan.SupplyOutletNode := Name + ' Exhaust Node';
  end;
end;

function T_EP_OutdoorAirUnit.AddEquip(ChildComponent: THVACComponent): THVACComponent;
begin
  EquipList.Add(ChildComponent);
  THVACComponent(ChildComponent).SuppressToIDF := false;
  Result := ChildComponent;
end;

procedure T_EP_OutdoorAirUnit.SetZone(ZoneParameter: T_EP_Zone);
begin
  if Assigned(ZoneParameter) then
  begin
    ZoneValue := ZoneParameter;
    Name := Zone.Name + ' OA Unit';
    DemandInletNode := Zone.Name + ' OA Unit Zone Outlet Node';
    DemandOutletNode := Zone.Name + ' OA Unit Zone Inlet Node';
    Zone.AirInletNodes.Add(DemandOutletNode);
    Zone.AirExhaustNodes.Add(DemandInletNode);
  end;
end;

procedure T_EP_OutdoorAirUnit.ToIDF;
var
  Obj: TEnergyPlusObject;
  i: integer;
  j: integer;
begin
  Finalize;
  Obj := IDF.AddObject(ComponentType); //ZoneHVAC:OutdoorAirUnit
  Obj.AddField('Name', Name);
  Obj.AddField('Availability Schedule Name', AvailSch);
  Obj.AddField('Zone Name', Zone.Name);
  if OaRate > 0.0 then
    Obj.AddField('Outdoor Air Flow Rate', FloatToStr(OaRate), '{m3/s}')
  else
    Obj.AddField('Outdoor Air Flow Rate', FloatToStr(Zone.MaxOA), '{m3/s}');
  Obj.AddField('Outdoor Air Schedule Name', OaSch);
  Obj.AddField('Supply Fan Name', Name + ' Supply Fan');
  if EquipList.Count > 0 then
  begin
    if SameText(THVACComponent(EquipList[0]).ComponentType,'Fan:ConstantVolume') or SameText(THVACComponent(EquipList[0]).ComponentType,'Fan:VariableVolume') then
      Obj.AddField('Supply Fan Placement', 'BlowThrough', '{BlowThrough | DrawThrough}')
    else
      Obj.AddField('Supply Fan Placement', 'DrawThrough', '{BlowThrough | DrawThrough}');
  end;
  if HasExhFan then
  begin
    Obj.AddField('Exhaust Fan Name', Name + ' Exhaust Fan');
    if OaRate > 0.0 then
      Obj.AddField('Exhaust Air Flow Rate', FloatToStr(OaRate), '{m3/s}')
    else
      Obj.AddField('Exhaust Air Flow Rate', FloatToStr(Zone.MaxOA), '{m3/s}');
    Obj.AddField('Exhaust Air Schedule Name', OaSch);
  end
  else
  begin
    Obj.AddField('Exhaust Fan Name', '');
    Obj.AddField('Exhaust Air Flow Rate', '', '{m3/s}');
    Obj.AddField('Exhaust Air Schedule Name', '');
  end;
  Obj.AddField('Unit Control Type', CtrlType, '{NeutralControl | TemperatureControl}');
  Obj.AddField('High Air Control Temperature Schedule Name', HighAirTempSch);
  Obj.AddField('Low Air Control Temperature Schedule Name', LowAirTempSch);
  Obj.AddField('Outdoor Air Node Name', Name + ' OA Node');
  Obj.AddField('Air Outlet Node Name', DemandOutletNode);
  Obj.AddField('Air Inlet Node Name', DemandInletNode);
  if EquipList.Count > 0 then
  begin
    if SameText(THVACComponent(EquipList[0]).ComponentType,'Fan:ConstantVolume') or SameText(THVACComponent(EquipList[0]).ComponentType,'Fan:VariableVolume') then
      Obj.AddField('Supply Fan Outlet Node Name', SupFanOutNode)
    else
      Obj.AddField('Supply Fan Outlet Node Name', DemandOutletNode);
  end;
  Obj.AddField('Outdoor Air Unit List Name', Name + ' OA Unit Equip List');
  //outdoor air node
  Obj := IDF.AddObject('OutdoorAir:Node');
  Obj.AddField('Node Name', Name + ' OA Node');
  //equipment list
  Obj := IDF.AddObject('ZoneHVAC:OutdoorAirUnit:EquipmentList');
  Obj.AddField('Name', Name + ' OA Unit Equip List');
  j := 1;
  if EquipList.Count > 0 then
  begin
    for i := 0 to EquipList.Count - 1 do
    begin
      if SameText(THVACComponent(EquipList[i]).ComponentType, 'Fan:ConstantVolume') or SameText(THVACComponent(EquipList[i]).ComponentType, 'Fan:VariableVolume') then continue;
      Obj.AddField('Component ' + IntToStr(j) + ' Type', THVACComponent(EquipList[i]).ComponentType);
      Obj.AddField('Component ' + IntToStr(j) + ' Name', THVACComponent(EquipList[i]).Name);
      j := j + 1
    end;
  end;
  //set ERV flow rate to zone OA rate
  if ERV <> nil then
    ERV.AirFlowRate := Zone.MaxOA;
  //setpoint manager if DX coil
  if EquipList.Count > 0 then
  begin
    for i := 0 to EquipList.Count - 1 do
    begin
      if SameText(THVACComponent(EquipList[i]).ComponentType, 'CoilSystem:Cooling:DX') then
      begin
        Obj := IDF.AddObject('SetpointManager:Scheduled');
        Obj.AddField('Name', Name + ' SAT Setpoint');
        Obj.AddField('Control Variable', 'Temperature', '{Temperature | Others }');
        Obj.AddField('Schedule Name', 'Seasonal-Reset-Supply-Air-Temp-Sch');
        Obj.AddField('Setpoint Node or NodeList Name', THVACComponent(EquipList[i]).SupplyOutletNode);
      end;
    end;
  end;
  //equipment
  if EquipList.Count > 0 then
  begin
    for i := 0 to EquipList.Count - 1 do
    begin
      THVACComponent(EquipList[i]).ToIDF;
    end;
  end;
  //exhaust fan
  if ExhFan <> nil then
    ExhFan.ToIDF;
end;

{ T_EP_UnitHeater }

constructor T_EP_UnitHeater.Create;
begin
  inherited;
  ComponentType := 'ZoneHVAC:UnitHeater';
end;

procedure T_EP_UnitHeater.SetZone(ZoneParameter: T_EP_Zone);
begin
  inherited;
  if Assigned(ZoneParameter) then
  begin
    ZoneValue := ZoneParameter;
    Name := Zone.Name + ' Unit Heater';
    DemandInletNode := Name + ' Exhaust Node';
    DemandOutletNode := Name + ' Inlet Node Name';
    Zone.AirInletNodes.Add(DemandOutletNode);
    Zone.AirExhaustNodes.Add(DemandInletNode);
  end;
end;

procedure T_EP_UnitHeater.setCoil(CoilParameter: string);
begin
  if SameText(CoilParameter, 'Gas') then
  begin
    CoilTypeValue := 'Coil:Heating:Gas';
  end
  else if SameText(CoilParameter, 'WATER') then
  begin
    CoiltypeValue := 'Coil:Heating:Water';
  end
  else if SameText(CoilParameter, 'ELECTRICITY') then
  begin
    CoilTypeValue := 'Coil:Heating:Electric';
  end
  else if CoilParameter = 'STEAM' then
  begin
    CoilTypeValue := 'Coil:Heating:Steam';
  end
  else
  begin
    writeln('could not find Coil Parameter ' + CoilParameter)
  end;
end;

procedure T_EP_UnitHeater.setFan(FanParameter: string);
begin
  if SameText(FanParameter, 'Constant') then
  begin
    FanTypeValue := 'Fan:ConstantVolume';
  end
  else if SameText(FanParameter, 'VARIABLE') then
  begin
    FanTypeValue := 'Fan:VariableVolume';
  end
  else
  begin
    writeln('could not find Fan Parameter ' + FanParameter)
  end;
end;

procedure T_EP_UnitHeater.ToIDF;
var
  Obj: TEnergyPlusObject;
begin
  Obj := IDF.AddObject('ZoneHVAC:UnitHeater');
  Obj.AddField('Name', Name);
  Obj.AddField('Availability Schedule Name', 'ALWAYS_ON');
  Obj.AddField('Air Inlet Node Name', DemandInletNode);
  Obj.AddField('Air Outlet Node Name', DemandOutletNode);
  Obj.AddField('Supply Air Fan Object Type', FanType);
  Obj.AddField('Fan Name', Name + 'Fan');
  Obj.Addfield('Maximum Supply Air Flow Rate', 'AUTOSIZE');
  Obj.Addfield('Fan Control Type', 'OnOff');
  obj.AddField('Heating Coil Object Type', CoilType);
  Obj.AddField('Heating Coil Name', Name + ' Coil');
  Obj.AddField('Maximum Hot Water or Steam Flow Rate', 'AUTOSIZE');
  Obj.AddField('Minimum Hot Water or Steam Flow Rate', '0.0');
  Obj.AddField('Heating Convergence Tolerance', '0.001');
  //heating coil
  if SameText(coilType, 'Coil:Heating:Gas') then
  begin // write out coil object here
    Obj := IDF.AddObject('Coil:Heating:Gas');
    Obj.AddField('Name', Name + ' Coil');
    Obj.AddField('Availability Schedule Name', 'ALWAYS_ON');
    Obj.AddField('Gas Burner Efficiency', FloatToStr(CoilEfficiency), '{}');
    Obj.AddField('Nominal Capacity', 'AUTOSIZE', '{W}');
    Obj.AddField('Air Inlet Node Name', Name + ' Post Fan Node');
    Obj.AddField('Air Outlet Node Name', DemandOutletNode);
  end
  else if SameText(CoilType, 'Coil:Heating:Electric') then
  begin
    Obj := IDF.AddObject('Coil:Heating:Electric');
    Obj.AddField('Name', Name + ' Coil');
    Obj.AddField('Availability Schedule Name', 'ALWAYS_ON');
    Obj.AddField('Efficiency', '1.0');
    Obj.AddField('Nominal Capacity', 'AUTOSIZE', '{W}');
    Obj.AddField('Air Inlet Node Name', Name + ' Post Fan Node');
    Obj.AddField('Air Outlet Node Name', DemandOutletNode);
  end
  else if SameText(CoilType, 'Coil:Heating:Water') then
  begin
    HWcoil.DemandControlType := 'Active';
    HWcoil.SupplyInletNode := Name + ' Post Fan Node';
    HWcoil.SupplyOutletNode := DemandOutletNode;
    T_EP_Coil(HWcoil).ToIDF;
  end;
  // fan
  Obj := IDF.AddObject(FanType);
  Obj.AddField('Name', Name + 'Fan');
  Obj.AddField('Availability Schedule Name', 'ALWAYS_ON');
  Obj.AddField('Fan Efficiency', FloatToStr(FanEfficiency), '{}');
  Obj.AddField('Pressure Rise', FloatToStr(FanPressureDrop), '{Pa}');
  Obj.AddField('Maximum Flow Rate', 'AUTOSIZE', '{m3/s}');
  if SameText(FanType, 'Fan:ConstantVolume') then
  begin
    Obj.AddField('Motor Efficiency', '0.85', '{}');
    Obj.AddField('Motor In Airstream Fraction', '1.0', '{}');
    Obj.AddField('Air Inlet Node Name', DemandInletNode);
    Obj.AddField('Air Outlet Node Name', name + ' Post Fan Node');
    obj.AddField('End-Use Subcategory', 'Unit Heater Fans') ;
  end
  else if SameText(FanType, 'Fan:VariableVolume') then
  begin
    Obj.AddField('Fan Power Minimum Flow Rate Input Method', 'Fraction', '{Fraction | FixedFlowRate}');
    Obj.AddField('Fan Power Minimum Flow Fraction', '0.25', '{}');
    Obj.AddField('Fan Power Minimum Air Flow Rate', '', '{m3/s}');
    Obj.AddField('Motor Efficiency', '0.9', '{}');
    Obj.AddField('Motor In Airstream Fraction', '1.0', '{}');
    Obj.AddField('Fan Coefficient 1', '0.35071223');
    Obj.AddField('Fan Coefficient 2', '0.30850535');
    Obj.AddField('Fan Coefficient 3', '-0.54137364');
    Obj.AddField('Fan Coefficient 4', '0.87198823');
    Obj.AddField('Fan Coefficient 5', '0');
    Obj.AddField('Air Inlet Node Name', DemandInletNode);
    Obj.AddField('Air Outlet Node Name', name + ' Post Fan Node');
    obj.AddField('End-Use Subcategory', 'Unit Heater Fans') ;
  end;
end;

procedure T_EP_UnitHeater.Finalize;
begin
  inherited;
end;

{ T_EP_UnitVentilator }

constructor T_EP_UnitVentilator.Create;
begin
  inherited;
  ComponentType := 'ZoneHVAC:UnitVentilator';
  coolingAvail := false;
  MotorizedDamper := false;
  CoilOption := 'HEATING';
  AvailSch := 'ALWAYS_ON';
  OaCtrlType := 'VariablePercent';
end;

procedure T_EP_UnitVentilator.SetZone(ZoneParameter: T_EP_Zone);
begin
  inherited;
  if Assigned(ZoneParameter) then
  begin
    ZoneValue := ZoneParameter;
    Name := Zone.Name + ' Unit Ventilator';
    DemandInletNode := Name + ' Vent Exhaust Node';
    DemandOutletNode := Name + ' Vent Inlet Node';
    Zone.AirInletNodes.Add(DemandOutletNode);
    Zone.AirExhaustNodes.Add(DemandInletNode);
  end;
end;

procedure T_EP_UnitVentilator.setHeatCoil(CoilParameter: string);
begin
  if SameText(CoilParameter, 'Gas') then
    HeatCoilTypeValue := 'Coil:Heating:Gas'
  else if SameText(CoilParameter, 'WATER') then
    HeatCoiltypeValue := 'Coil:Heating:Water'
  else if SameText(CoilParameter, 'ELECTRICITY') then
    HeatCoilTypeValue := 'Coil:Heating:Electric'
  else if CoilParameter = 'STEAM' then
    HeatCoilTypeValue := 'Coil:Heating:Steam'
  else
    writeln('Unit Ventilator could not find Coil Parameter ' + CoilParameter)
end;

procedure T_EP_UnitVentilator.setFan(FanParameter: string);
begin
  if SameText(FanParameter, 'Constant') then
    FanTypeValue := 'Fan:ConstantVolume'
  else if SameText(FanParameter, 'VARIABLE') then
    FanTypeValue := 'Fan:VariableVolume'
  else
    writeln('Unit Ventilator could not find Fan Parameter ' + FanParameter)
end;

procedure T_EP_UnitVentilator.ToIDF;
var
  Obj: TEnergyPlusObject;
begin
  Obj := IDF.AddObject('ZoneHVAC:UnitVentilator');
  Obj.AddField('Name', name);
  Obj.AddField('Availability Schedule Name', AvailSch);
  Obj.Addfield('Maximum Supply Air Flow Rate', 'AUTOSIZE');
  Obj.AddField('Outdoor Air Control Type', OaCtrlType);
  if zone.OAviaZoneERV then
  begin
    Obj.AddField('Minimum Outdoor Air Flow Rate', '0.0');
    if MotorizedDamper then
      Obj.AddField('Minimum Outdoor Air Schedule Name', 'MinOA_MotorizedDamper_Sched')
    else
      Obj.AddField('Minimum Outdoor Air Schedule Name', 'MinOA_Sched');
  end
  else
  begin
    Obj.AddField('Minimum Outdoor Air Flow Rate', 'AUTOSIZE');
    if MotorizedDamper then
      Obj.AddField('Minimum Outdoor Air Schedule Name', 'MinOA_MotorizedDamper_Sched')
    else
      Obj.AddField('Minimum Outdoor Air Schedule Name', 'MinOA_Sched');
  end;
  if zone.EconomizeViaZoneERV then
  begin
    //assume simple hardware without economizer type controls. min = max
    Obj.AddField('Maximum Outdoor Air Flow Rate', '0.0');
    if MotorizedDamper then
      Obj.AddField('Maximum Outdoor Air Fraction or Temperature Schedule Name', 'MinOA_MotorizedDamper_Sched')
    else
      Obj.AddField('Maximum Outdoor Air Fraction or Temperature Schedule Name', 'MinOA_Sched');
  end
  else
  begin
    //assume simple hardware without economizer type controls. min = max
    Obj.AddField('Maximum Outdoor Air Flow Rate', 'AUTOSIZE');
    Obj.AddField('Maximum Outdoor Air Fraction or Temperature Schedule Name', 'ALWAYS_ON');
  end;
  Obj.AddField('Air Inlet Node Name', DemandInletNode);
  Obj.AddField('Air Outlet Node Name', DemandOutletNode);
  Obj.AddField('Outdoor Air Node Name', Name + ' OA Node');
  Obj.AddField('Outdoor Air Relief Node Name', Name + ' Relief Node');
  Obj.AddField('Mixed Air Node Name', Name + 'Fan Inlet');
  Obj.AddField('Supply Air Fan Object Type', FanType);
  Obj.AddField('Fan Name', Name + 'Fan');
  Obj.AddField('Coil Option', CoilOption);
  Obj.AddField('Heating Coil Object Type', HeatCoilType);
  Obj.AddField('Heating Coil Name', Name + 'Heat Coil');
  Obj.AddField('Heating Convergence Tolerance', '0.001');
  if CoolingAvail then
  begin // add additional fields for cooling
    Obj.AddField('Cooling Coil Object Type', 'COIL:WATER:COOLING');
    Obj.AddField('Cooling Coil Name', name + 'Cool Coil');
    Obj.AddField('Cooling Convergence Tolerance', '0.001');
  end;
  if SameText(HeatCoilType, 'Coil:Heating:Gas') then
  begin // write out coil object here
    Obj := IDF.AddObject('Coil:Heating:Gas');
    Obj.AddField('Name', Name + 'Heat Coil');
    Obj.AddField('Availability Schedule Name', 'ALWAYS_ON');
    Obj.AddField('Gas Burner Efficiency', FloatToStr(HeatCoilEfficiency), '{}');
    Obj.AddField('Nominal Capacity', 'AUTOSIZE', '{W}');
    if not CoolingAvail then
      Obj.AddField('Air Inlet Node Name', Name + ' Post Fan Node')
    else
      Obj.AddField('Air Inlet Node Name', Name + ' Post CC Node'); // correct for cooling add
    Obj.AddField('Air Outlet Node Name', DemandOutletNode);
  end
  else if SameText(HeatCoilType, 'Coil:Heating:Electric') then
  begin
    Obj := IDF.AddObject('Coil:Heating:Electric');
    Obj.AddField('Name', Name + 'Heat Coil');
    Obj.AddField('Availability Schedule Name', 'ALWAYS_ON');
    Obj.AddField('Efficiency', '1.0');
    Obj.AddField('Nominal Capacity', 'AUTOSIZE', '{W}');
    if not CoolingAvail then
      Obj.AddField('Air Inlet Node Name', name + ' Post Fan Node')
    else
      Obj.AddField('Air Inlet Node Name', name + ' Post CC Node'); // correct for cooling add
    Obj.AddField('Air Outlet Node Name', DemandOutletNode); // correct for cooling add
  end
  else if SameText(HeatCoilType, 'Coil:Heating:Water') then
  begin
    HWcoil.DemandControlType := 'Active';
    if not CoolingAvail then
      HWcoil.SupplyInletNode := Name + ' Post Fan Node'
    else
      HWcoil.SupplyInletNode := Name + ' Post CC Node';
    HWCoil.Name := Name + 'Heat Coil';
    HWcoil.SupplyOutletNode := DemandOutletNode; // correct for cooling add
    T_EP_Coil(HWcoil).DemandControlType := 'Active';
    T_EP_Coil(HWcoil).ToIDF;
  end
  else
  begin
    // other coil types need to be connected to liquid systems and will get written out by themselves.
  end;
  if CoolingAvail then
  begin
    CoolingCoil.DemandControlType := 'Active';
    CoolingCoil.SupplyInletNode := Name + ' Post Fan Node';
    CoolingCoil.Name := name + 'Cool Coil';
    CoolingCoil.SupplyOutletNode := Name + ' Post CC Node';
    T_EP_Coil(CoolingCoil).ToIDF;
  end;
  Obj := IDF.AddObject(FanType);
  Obj.AddField('Name', Name + 'Fan');
  Obj.AddField('Availability Schedule Name', 'ALWAYS_ON');
  Obj.AddField('Fan Efficiency', FloatToStr(FanEfficiency), '{}');
  Obj.AddField('Pressure Rise', FloatToStr(FanPressureDrop), '{Pa}');
  Obj.AddField('Maximum Flow Rate', 'AUTOSIZE', '{m3/s}');
  if SameText(FanType, 'Fan:ConstantVolume') then
  begin
    Obj.AddField('Motor Efficiency', '0.85', '{}');
    Obj.AddField('Motor In Airstream Fraction', '1.0', '{}');
    Obj.AddField('Air Inlet Node Name', name + 'Fan inlet');
    Obj.AddField('Air Outlet Node Name', name + ' Post Fan Node');
  end
  else if SameText(FanType, 'Fan:VariableVolume') then
  begin
    Obj.AddField('Fan Power Minimum Flow Rate Input Method', 'Fraction', '{Fraction | FixedFlowRate}');
    Obj.AddField('Fan Power Minimum Flow Fraction', '0.25', '{}');
    Obj.AddField('Fan Power Minimum Air Flow Rate', '', '{m3/s}');
    Obj.AddField('Motor Efficiency', '0.9', '{}');
    Obj.AddField('Motor In Airstream Fraction', '1.0', '{}');
    Obj.AddField('Fan Coefficient 1', '0.35071223');
    Obj.AddField('Fan Coefficient 2', '0.30850535');
    Obj.AddField('Fan Coefficient 3', '-0.54137364');
    Obj.AddField('Fan Coefficient 4', '0.87198823');
    Obj.AddField('Fan Coefficient 5', '0');
    Obj.AddField('Air Inlet Node Name', Name + 'Fan Inlet');
    Obj.AddField('Air Outlet Node Name', Name + ' Post Fan Node');
  end;
  Obj := IDF.AddObject('OutdoorAir:Node');
  Obj.AddField('Name', Name + ' OA Node');
end;

procedure T_EP_UnitVentilator.Finalize;
begin
  inherited;
end;

{ T_EP_FanCoil  }

constructor T_EP_FanCoil.Create;
begin
  inherited;
  ComponentType := 'ZoneHVAC:FourPipeFanCoil';
  SuppressOA := false;
end;

procedure T_EP_FanCoil.Finalize;
begin
  inherited;
end;

procedure T_EP_FanCoil.SetZone(ZoneParameter: T_EP_Zone);
begin
  inherited;
  if Assigned(ZoneParameter) then
  begin
    ZoneValue := ZoneParameter;
    Name := Zone.Name + ' Fan Coil';
    DemandInletNode := Zone.Name + ' FCU Inlet Node';
    DemandOutletNode := Zone.Name + ' FCU Exhaust Node';
    Zone.AirInletNodes.Add(DemandOutletNode);
    Zone.AirExhaustNodes.Add(DemandInletNode);
  end;
end;

procedure T_EP_FanCoil.ToIDF;
var
  Obj: TEnergyPlusObject;
begin
  Obj := IDF.AddObject('ZoneHVAC:FourPipeFanCoil');
  Obj.AddField('Name', Name);
  Obj.AddField('Availability Schedule Name', 'ALWAYS_ON');
  Obj.AddField('Capacity Control Method', Typ, '{ConstantFanVariableFlow | CyclingFan | VariableFanVariableFlow | VariableFanConstantFlow}');
  Obj.AddField('Maximum Supply Air Flow Rate', 'AUTOSIZE');
  Obj.AddField('Low Speed Supply Air Flow Ratio', '', '{}');
  Obj.AddField('Medium Speed Supply Air Flow Ratio', '', '{}');
  if SuppressOA then
  begin
    Obj.AddField('Maximum Outdoor Air Flow Rate', '0.0');
    Obj.AddField('Outside Air Schedule Name', '')
  end
  else
  begin
    if Zone.EconomizeViaZoneERV then
      Obj.AddField('Maximum Outdoor Air Flow Rate', '0.0')
    else
      Obj.AddField('Maximum Outdoor Air Flow Rate', 'AUTOSIZE');
    Obj.AddField('Outside Air Schedule Name', 'ALWAYS_ON');
  end;
  Obj.AddField('Air Inlet Node Name', DemandInletNode);
  Obj.AddField('Air Outlet Node Name', DemandOutletNode);
  Obj.AddField('Outdoor Air Mixer Object Type', 'OutdoorAir:Mixer');
  Obj.AddField('Outdoor Air Mixer Name', Name + ' OA Mixer');
  if SameText(Typ, 'ConstantFanVariableFlow') or SameText(Typ, 'CyclingFan') then
    Obj.AddField('Supply Air Fan Object Type', 'Fan:OnOff')
  else if SameText(Typ, 'VariableFanVariableFlow') or SameText(Typ, 'VariableFanConstantFlow') then
    Obj.AddField('Supply Air Fan Object Type', 'Fan:VariableVolume');
  Obj.AddField('Fan Name', Name + ' Fan');
  Obj.AddField('Cooling Coil Object Type', 'Coil:Cooling:Water');
  Obj.AddField('Cooling Coil Name', Name + ' Cool Coil');
  Obj.AddField('Maximum Cold Water Flow Rate', 'AUTOSIZE');
  Obj.AddField('Minimum Cold Water Flow Rate', '0.0');
  Obj.AddField('Cooling Convergence Tolerance', '0.001');
  if SameText(HtgCoil.Fuel, 'Water') then
    Obj.AddField('Heating Coil Object Type', 'Coil:Heating:Water');
  Obj.AddField('Heating Coil Name', Name + ' Heat Coil');
  Obj.AddField('Maximum Hot Water Flow Rate', 'AUTOSIZE');
  Obj.AddField('Minimum Hot Water Flow Rate', '0.0');
  Obj.AddField('Heating Convergence Tolerance', '0.001');
  // oa mixer
  Obj := IDF.AddObject('OutdoorAir:Mixer');
  Obj.AddField('Name', Name + ' OA Mixer');
  Obj.AddField('Mixed Air Node Name', Name + ' OA Mix Outlet Node');
  Obj.AddField('Outdoor Air Stream Node Name', Name + ' OA Inlet Node');
  Obj.AddField('Relief Air Stream Node Name', Name + ' Air Relief Node Name');
  Obj.AddField('Return Air Stream Node Name', DemandInletNode);
  // oa node
  Obj := IDF.AddObject('OutdoorAir:Node');
  Obj.AddField('Name', Name + ' OA Inlet Node');
  // fan
  if SameText(Typ, 'ConstantFanVariableFlow') or SameText(Typ, 'CyclingFan') then
  begin
    Obj := IDF.AddObject('Fan:OnOff');
    Obj.AddField('Name', Name + ' Fan');
    Obj.AddField('Availability Schedule Name', 'ALWAYS_ON');
    Obj.AddField('Fan Efficiency', FloatToStr(FanEff));
    Obj.AddField('Pressure Rise', FloatToStr(FanPresDrop));
    Obj.AddField('Maximum Flow Rate', 'AUTOSIZE');
    Obj.AddField('Motor Efficiency', '0.9', '{}');
    Obj.AddField('Motor In Airstream Fraction', '1.0', '{}');
    Obj.AddField('Air Inlet Node Name', Name + ' OA Mix Outlet Node');
    Obj.AddField('Air Outlet Node Name', Name + ' Fan Outlet Node');
  end
  else if SameText(Typ, 'VariableFanVariableFlow') or SameText(Typ, 'VariableFanConstantFlow') then
  begin
    Obj := IDF.AddObject('Fan:VariableVolume');
    Obj.AddField('Name', Name + ' Fan');
    Obj.AddField('Availability Schedule Name', 'ALWAYS_ON');
    Obj.AddField('Fan Efficiency', FloatToStr(FanEff), '{}');
    Obj.AddField('Pressure Rise', FloatToStr(FanPresDrop));
    Obj.AddField('Maximum Flow Rate', 'AUTOSIZE', '{m3/s}');
    Obj.AddField('Fan Power Minimum Flow Rate Input Method', 'FixedFlowRate', '{Fraction | FixedFlowRate}');
    Obj.AddField('Fan Power Minimum Flow Fraction', '', '{}');
    Obj.AddField('Fan Power Minimum Air Flow Rate', '0.0', '{m3/s}');
    Obj.AddField('Motor Efficiency', '0.9', '{}');
    Obj.AddField('Motor In Airstream Fraction', '1.0', '{}');
    Obj.AddField('Fan Coefficient 1', '0.0407598940'); //Stien/Hydeman Good SP Reset (to 0.5")
    Obj.AddField('Fan Coefficient 2', '0.08804497'); //Stien/Hydeman Good SP Reset (to 0.5")
    Obj.AddField('Fan Coefficient 3', '-0.072926120'); //Stien/Hydeman Good SP Reset (to 0.5")
    Obj.AddField('Fan Coefficient 4', '0.9437398230'); //Stien/Hydeman Good SP Reset (to 0.5")
    Obj.AddField('Fan Coefficient 5', '0'); //Stien/Hydeman Good SP Reset (to 0.5")
    Obj.AddField('Air Inlet Node Name', Name + ' OA Mix Outlet Node');
    Obj.AddField('Air Outlet Node Name', Name + ' Fan Outlet Node');
  end;
  // coils
  HtgCoil.DemandControlType := 'Active';
  HtgCoil.ToIDF;
  ClgCoil.ToIDF;
end;

{  T_EP_ZoneERV  }

constructor T_EP_ZoneERV.Create;
begin
  inherited;
  ComponentType := 'ZoneHVAC:EnergyRecoveryVentilator';
end;

procedure T_EP_ZoneERV.Finalize;
begin
  inherited;
end;

procedure T_EP_ZoneERV.SetZone(ZoneParameter: T_EP_Zone);
begin
  inherited;
  if Assigned(ZoneParameter) then
  begin
    ZoneValue := ZoneParameter;
    Name := Zone.Name + ' ERV';
    DemandInletNode := Name + ' ERV Exhaust Node';
    DemandOutletNode := Name + ' ERV Inlet Node';
    Zone.AirInletNodes.Add(DemandOutletNOde);
    Zone.AirExhaustNodes.Add(DemandInletNode);
    Zone.OAviaZoneERV := true;
    if UseEconomizer then
    begin
      Zone.EconomizeViaZoneERV := true;
    end;
  end;
end;

procedure T_EP_ZoneERV.ToIDF;
var
  Obj: TEnergyPlusObject;
begin
  Obj := IDF.AddObject('ZoneHVAC:EnergyRecoveryVentilator');
  Obj.AddField('Name', name);
  Obj.AddField('Availability Schedule Name', 'MinOA_Sched');
  Obj.AddField('Heat Exchanger Name', name + 'HX');
  Obj.AddField('Supply Air Flow Rate', zone.MaxOA);
  Obj.AddField('Exhaust Air Flow Rate', zone.MaxOA);
  Obj.AddField('Supply Air Fan Name', name + ' Sup Fan');
  Obj.AddField('Exhaust Air Fan Name', name + ' Exh Fan');
  if (UseEconomizer) then
  begin
    Obj.AddField('Controller Name', name + '_Controller');
  end
  else
  begin
    Obj.AddField('Controller Name', '');
  end;
  obj.AddField('Ventilation Rate per Unit Floor Area', '');
  obj.AddField('Ventilation Rate per Occupant', '');
  //heat exchanger
  Obj := IDF.AddObject('HeatExchanger:AirToAir:SensibleAndLatent');
  OBj.AddField('Name', name + 'HX');
  Obj.AddField('Availability Schedule Name', 'MinOA_Sched');
  Obj.AddField('Nominal Supply Air Flow Rate', zone.MaxOA);
  Obj.AddField('Sensible Effectiveness at 100% Heating Air Flow', SensibleEffectiveness);
  OBj.AddField('Latent Effectiveness at 100% Heating Air Flow', LatentEffectiveness);
  Obj.AddField('Sensible Effectiveness at 75% Heating Air Flow', SensibleEffectiveness);
  OBj.AddField('Latent Effectiveness at 75% Heating Air Flow', LatentEffectiveness);
  Obj.AddField('Sensible Effectiveness at 100% Cooling Air Flow', SensibleEffectiveness);
  OBj.AddField('Latent Effectiveness at 100% Cooling Air Flow', LatentEffectiveness);
  Obj.AddField('Sensible Effectiveness at 75% Cooling Air Flow', SensibleEffectiveness);
  OBj.AddField('Latent Effectiveness at 75% Cooling Air Flow', LatentEffectiveness);
  obj.AddField('Supply Air Inlet Node Name', name + ' OA inlet node');
  obj.AddField('Supply Air Outlet Node Name', name + ' Sup Fan inlet node');
  obj.AddField('Exhaust Air Inlet Node Name', DemandInletNode);
  obj.AddField('Exhaust Air Outlet Node Name', name + ' Exh Fan inlet node');
  Obj.AddField('Nominal Electric Power', ParasiticPower);
  Obj.AddField('Supply Air Outlet Temperature Control', 'No'); // not sure about this one.  could try to meet setpoint
  Obj.AddField('Heat Exchanger Type', 'PLATE');
  Obj.AddField('Frost Control Type', 'None');
  Obj.AddField('Threshold Temperature', '1.7');
  //oa node
  Obj := IDF.AddObject('OutdoorAir:Node');
  Obj.AddField('Name', name + ' OA inlet node');
  //supply fan
  Obj := IDF.AddObject('Fan:OnOff');
  obj.AddField('Name ', name + ' Sup Fan');
  Obj.AddField('Availability Schedule Name', 'MinOA_Sched');
  Obj.AddField('Fan Efficiency', SupFanEfficiency);
  Obj.AddField('Pressure Rise', SupFanPressureDrop);
  Obj.AddField('Maximum Flow Rate', zone.MaxOA);
  Obj.AddField('motor efficiency', '0.9');
  Obj.AddField('Motor in Airstream Fraction', '1.0');
  Obj.AddField('Air Inlet Node Name', name + ' Sup Fan inlet node');
  Obj.AddField('Air Outlet Node Name', DemandOutletNode);
  Obj.AddField('Fan Power Ratio Function of Speed Ratio Curve Name', '');
  Obj.AddField('Fan Efficiency Ratio Function of Speed Ratio Curve Name', '');
  Obj.AddField('End-Use Subcategory', 'ERV Fans');
  //exhaust fan
  Obj := IDF.AddObject('Fan:OnOff');
  obj.AddField('Name', name + ' Exh Fan');
  Obj.AddField('Availability Schedule Name', 'MinOA_Sched');
  Obj.AddField('Fan Efficiency', ExhFanEfficiency);
  Obj.AddField('Pressure Rise', ExhFanPressureDrop);
  Obj.AddField('Maximum Flow Rate', zone.MaxOA);
  Obj.AddField('Motor Efficiency', '0.9');
  Obj.AddField('Motor in Airstream Fraction', '1.0');
  Obj.AddField('Air Inlet Node Name', name + ' Exh Fan inlet node');
  Obj.AddField('Air Outlet Node Name', name + ' Exh Fan outlet node');
  Obj.AddField('Fan Power Ratio Function of Speed Ratio Curve Name', '');
  Obj.AddField('Fan Efficiency Ratio Function of Speed Ratio Curve Name', '');
  Obj.AddField('End-Use Subcategory', 'ERV Fans');
  if (UseEconomizer) then
  begin
    Obj := IDF.AddObject('ZoneHVAC:EnergyRecoveryVentilator:Controller');
    Obj.AddField('Name', name + '_Controller');
    obj.AddField('Temperature High Limit', '19.0', '[C]');
    obj.AddField('Temperature Low Limit', '0.0', '[C]');
    obj.AddField('Enthalpy High Limit', '32000.0', 'J/kg');
    obj.AddField('Dew Point Temperature Limit', '');
    obj.AddField('Electronic Enthalpy Limit Curve Name', '');
    obj.AddField('Exhaust Air Temperature Limit' , 'NoExhaustAirTemperatureLimit');
    obj.AddField('Exhaust Air Enthalpy Limit' , 'NoExhaustAirEnthalpyLimit' );
    obj.AddField('Time of Day Economizer Flow Control Schedule Name',  'ALWAYS_ON' );
    obj.AddField('High Humidity Control Flag', 'No');
    obj.AddField('Humidistat Control Zone Name' , zone.name );
    obj.AddField('High Humidity Outdoor Air Flow Ratio', 1.0 );
    obj.AddField('Control High Indoor Humidity Based on Outdoor Humidity Ratio', 'No');
  end;
end;

constructor T_EP_PurchasedAir.Create;
begin
  inherited;
  ComponentType := 'ZoneHVAC:IdealLoadsAirSystem';
  OutdoorAir := true;
end;

procedure T_EP_PurchasedAir.Finalize;
begin
  inherited;
end;

procedure T_EP_PurchasedAir.SetZone(ZoneParameter: T_EP_Zone);
begin
  inherited;
  if Assigned(ZoneParameter) then
  begin
    ZoneValue := ZoneParameter;
    Name := Zone.Name + 'PurchasedAir';
    DemandOutletNode := Name + ' Inlet Node Name';
    Zone.AirInletNodes.Add(DemandOutletNode);
  end;
end;

procedure T_EP_PurchasedAir.ToIDF;
var
  Obj: TEnergyPlusObject;
begin
  Obj := IDF.AddObject('ZoneHVAC:IdealLoadsAirSystem');
  Obj.AddField('Name', name);
  Obj.AddField('Zone Supply Air Node Name', DemandOutletNode);
  Obj.AddField('Heating Supply Air Temperature', '50.0', '[C]');
  Obj.AddField('Cooling Supply Air Temperature', '12.0', '[C]');
  Obj.AddField('Heating Supply Air Humidity Ratio', '0.009', '[kg-H20/kg-air]');
  Obj.AddField('Cooling Supply Air Humidity Ratio', '0.009', '[kg-H20/kg-air]');
  Obj.AddField('Heating Limit', 'NoLimit');
  Obj.AddField('Maximum Heating Air Flow Rate', '');
  Obj.AddField('Cooling Limit', 'NoLimit');
  Obj.AddField('Maximum Cooling Air Flow Rate', '');
  if OutdoorAir = true then
    Obj.AddField('Outdoor Air', 'OutdoorAir')
  else
    Obj.AddField('Outdoor Air', 'NoOutdoorAir');
  Obj.AddField('Outdoor Air Flow Rate', 'AutoSize', '[m3/s]');
  Obj.AddField('Heating Availability Schedule Name', 'HVACOperationSchd');
  Obj.AddField('Cooling Availability Schedule Name', 'HVACOperationSchd');
end;

{ T_EP_WaterSystems}

constructor T_EP_WaterSystems.Create;
begin
  Name := 'water 1'; // since doesn't have to be associated with a zone
  ComponentType := ' '; // not sure if this belongs in or Finalize
  ControlType := 'Active';
  DemandControlType := 'Passive';
end;

procedure T_EP_WaterSystems.Finalize;
begin
  inherited;
end;

procedure T_EP_WaterSystems.SetZone(ZoneParameter: T_EP_Zone);
begin
  inherited;
  if Assigned(ZoneParameter) then
  begin
    ZoneValue := ZoneParameter;
    Name := Zone.Name + ' DHW';
    DemandInletNode := Name + ' Inlet Node Name';
    DemandOutletNode := Name + ' Outlet Node Name';
  end;
end;

procedure T_EP_WaterSystems.ToIDF;
begin
// TODO finish water systems. this may be obsolete original code...
end;

{ T_EP_RefrigeratedCase }

constructor T_EP_RefrigeratedCase.Create;
begin
  inherited;
end;

procedure T_EP_RefrigeratedCase.Finalize;
begin
  inherited;
  Name := Zone.Name + '_' + DataSetKey + '_Case:' + IntToStr(CaseID);
end;

procedure T_EP_RefrigeratedCase.SetZone(ZoneParameter: T_EP_Zone);
begin
  inherited;
  if Assigned(ZoneParameter) then
  begin
    ZoneValue := ZoneParameter;
  end;
end;

procedure T_EP_RefrigeratedCase.ToIDF;
var
  CasePreProcMacro: TPreProcMacro;
  CaseStringList: TStringList;
  CaseString: string;
  CaseLightSchPreProcMacro: TPreProcMacro;
  CaseLightSchStringList: TStringList;
  CaseLightSchString: string;
begin
  inherited;
  Finalize;
  CasePreProcMacro := TPreProcMacro.Create('include/HPBRefrigerationCases.imf');
  CaseLightSchPreProcMacro := TPreProcMacro.Create('include/HPBRefrigerationLightSch.imf');
  try
    CaseString := CasePreProcMacro.getDefinedText(DataSetKey);
    CaseString := ReplaceRegExpr('#{Name}', CaseString, Name, False);
    CaseString := ReplaceRegExpr('#{ZoneName}', CaseString, Zone.Name, False);
    //cooling capacity per unit length
    if CoolingCapPerLength >= 0 then
    begin
      CaseString := ReplaceRegExpr('#{CoolingCapPerLength}\d*\.\d*', CaseString, FloatToStr(CoolingCapPerLength), False);
    end
    else
    begin
      CaseString := ReplaceRegExpr('#{CoolingCapPerLength}', CaseString, '', False);
    end;
    //case length
    if CaseLength >= 0 then
    begin
      CaseString := ReplaceRegExpr('#{Length}\d*\.\d*', CaseString, FloatToStr(CaseLength), False);
    end
    else
    begin
      CaseString := ReplaceRegExpr('#{Length}', CaseString, '', False);
    end;
    //case operating temperature
    if OperatingTemp <> -9999.0 then
    begin
      CaseString := ReplaceRegExpr('#{OperatingTemp}-{0,1}\d*\.\d*', CaseString, FloatToStr(OperatingTemp), False);
    end
    else
    begin
      CaseString := ReplaceRegExpr('#{OperatingTemp}', CaseString, '', False);
    end;
    //latent case credit curve name
    CaseString := ReplaceRegExpr('#{LatentCaseCreditCurveName}', CaseString, Name + '_LatentCaseCreditCurve', False);
    //standard case fan power per unit length
    if CaseFanPowerPerLength >= 0 then
    begin
      CaseString := ReplaceRegExpr('#{StandardFanPowerPerLength}\d*\.\d*', CaseString, FloatToStr(CaseFanPowerPerLength), False);
    end
    else
    begin
      CaseString := ReplaceRegExpr('#{StandardFanPowerPerLength}', CaseString, '', False);
    end;
    //operating case fan power per unit length
    if OperatingCaseFanPowerPerLength >= 0 then
    begin
      CaseString := ReplaceRegExpr('#{OperatingFanPowerPerLength}\d*\.\d*', CaseString, FloatToStr(OperatingCaseFanPowerPerLength), False);
    end
    else
    begin
      CaseString := ReplaceRegExpr('#{OperatingFanPowerPerLength}', CaseString, '', False);
    end;
    //standard lighting power per unit length
    if CaseLightingPowerPerLength >= 0 then
    begin
      CaseString := ReplaceRegExpr('#{StandardLightingPowerPerLength}\d*\.\d*', CaseString, FloatToStr(CaseLightingPowerPerLength), False);
    end
    else
    begin
      CaseString := ReplaceRegExpr('#{StandardLightingPowerPerLength}', CaseString, '', False);
    end;
    //installed lighting power per unit length
    if InstalledLightingPowerPerLength >= 0 then
    begin
      CaseString := ReplaceRegExpr('#{InstalledLightingPowerPerLength}\d*\.\d*', CaseString, FloatToStr(InstalledLightingPowerPerLength), False);
    end
    else
    begin
      CaseString := ReplaceRegExpr('#{InstalledLightingPowerPerLength}', CaseString, '', False);
    end;
    //case lighting schedule name
    if not SameText(CaseLightingSchedule, 'NotSet') then
    begin
      CaseString := ReplaceRegExpr('#{CaseLightingSchedule}\w*', CaseString, CaseLightingSchedule, False);
    end
    else
    begin
      CaseLightSchString := CaseLightSchPreProcMacro.getDefinedText(DataSetKey);
      if CaseLightSchString <> '' then
      begin
        CaseString := ReplaceRegExpr('#{CaseLightingSchedule}\w*', CaseString, Name + '_CaseLightingSchedule', False);
        CaseLightSchString := ReplaceRegExpr('#{CaseLightingScheduleObject}', CaseLightSchString, Name + '_CaseLightingSchedule', False);
      end
      else
      begin
        CaseString := ReplaceRegExpr('#{CaseLightingSchedule}', CaseString, '', False);
      end;
    end;
    //fraction of lighting energy to case
    if FractionLightsToCase >= 0 then
    begin
      CaseString := ReplaceRegExpr('#{FractionLightsToCase}\d*\.\d*', CaseString, FloatToStr(FractionLightsToCase), False);
    end
    else
    begin
      CaseString := ReplaceRegExpr('#{FractionLightsToCase}', CaseString, '', False);
    end;
    //anti-sweat heater power per unit length
    if AntiSweatHeaterPowerPerLength >= 0 then
    begin
      CaseString := ReplaceRegExpr('#{AntiSweatHeaterPowerPerLength}\d*\.\d*', CaseString, FloatToStr(AntiSweatHeaterPowerPerLength), False);
    end
    else
    begin
      CaseString := ReplaceRegExpr('#{AntiSweatHeaterPowerPerLength}', CaseString, '', False);
    end;
    //anti-sweat heater control type
    if not SameText(AntiSweatHeaterControlType, 'NotSet') then
    begin
      CaseString := ReplaceRegExpr('#{AntiSweatHeaterControlType}\w*', CaseString, AntiSweatHeaterControlType, False);
    end
    else
    begin
      CaseString := ReplaceRegExpr('#{AntiSweatHeaterControlType}', CaseString, '', False);
    end;
    //case defrost power per unit length
    if DefrostPowerPerLength >= 0 then
    begin
      CaseString := ReplaceRegExpr('#{DefrostPowerPerLength}\d*\.\d*', CaseString, FloatToStr(DefrostPowerPerLength), False);
    end
    else
    begin
      CaseString := ReplaceRegExpr('#{DefrostPowerPerLength}', CaseString, '', False);
    end;
    //case defrost type
    if SameText(DefrostType, 'None') then
    begin
      CaseString := ReplaceRegExpr('#{DefrostType}\w*', CaseString, 'None', False);
    end
    else if not SameText(DefrostType, 'NotSet') then
    begin
      CaseString := ReplaceRegExpr('#{DefrostType}\w*', CaseString, DefrostType, False);
    end
    else
    begin
      CaseString := ReplaceRegExpr('#{DefrostType}', CaseString, '', False);
    end;
    //case defrost schedule name
    if not SameText(DefrostSchedule, 'NotSet') then
    begin
      CaseString := ReplaceRegExpr('#{DefrostSchedule}\w*', CaseString, DefrostSchedule, False);
      CaseString := ReplaceRegExpr('#{DefrostScheduleObject}', CaseString, Name + '_DefrostSchedule', False);
    end
    else
    begin
      CaseString := ReplaceRegExpr('#{DefrostSchedule}', CaseString, Name + '_DefrostSchedule', False);
      CaseString := ReplaceRegExpr('#{DefrostScheduleObject}', CaseString, Name + '_DefrostSchedule', False);
    end;
    //case defrost drip-down schedule name
    if not SameText(DefrostSchedule, 'NotSet') then
    begin
      CaseString := ReplaceRegExpr('#{DefrostDripDownSchedule}\w*', CaseString, DefrostDripDownSchedule, False);
      CaseString := ReplaceRegExpr('#{DefrostDripDownScheduleObject}', CaseString, Name + '_DefrostDripDownSchedule', False);
    end
    else
    begin
      CaseString := ReplaceRegExpr('#{DefrostDripDownSchedule}', CaseString, Name + '_DefrostDripDownSchedule', False);
      CaseString := ReplaceRegExpr('#{DefrostDripDownScheduleObject}', CaseString, Name + '_DefrostDripDownSchedule', False);
    end;
    //defrost energy correction curve type
    if SameText(DefrostType, 'None') or
      SameText(DefrostType, 'OffCycle') or
      SameText(DefrostType, 'HotGas') or
      SameText(DefrostType, 'Electric') or
      SameText(DefrostType, 'HotFluid') then
    begin
      CaseString := ReplaceRegExpr('#{DefrostEnergyCorrectionCurveType}\w*', CaseString, 'None', False);
    end
    else if not SameText(DefrostEnergyCorrectionCurveType, 'NotSet') then
    begin
      CaseString := ReplaceRegExpr('#{DefrostEnergyCorrectionCurveType}\w*', CaseString, DefrostEnergyCorrectionCurveType, False);
    end
    else
    begin
      CaseString := ReplaceRegExpr('#{DefrostEnergyCorrectionCurveType}', CaseString, '', False);
    end;
    //defrost energy correction curve name
    if SameText(DefrostType, 'None') or
      SameText(DefrostType, 'OffCycle') or
      SameText(DefrostType, 'HotGas') or
      SameText(DefrostType, 'Electric') or
      SameText(DefrostType, 'HotFluid') then
    begin
      CaseString := ReplaceRegExpr('#{DefrostEnergyCorrectionCurveName}', CaseString, '', False);
      CaseString := ReplaceRegExpr('#{DefrostEnergyCorrectionCurveObjectName}', CaseString, Name + '_DefrostEnergyCorrectionCurve', False);
    end;
    if not SameText(DefrostEnergyCorrectionCurveName, 'NotSet') then
    begin
      CaseString := ReplaceRegExpr('#{DefrostEnergyCorrectionCurveName}', CaseString, DefrostEnergyCorrectionCurveName, False);
      CaseString := ReplaceRegExpr('#{DefrostEnergyCorrectionCurveObjectName}', CaseString, DefrostEnergyCorrectionCurveName, False);
    end
    else
    begin
      CaseString := ReplaceRegExpr('#{DefrostEnergyCorrectionCurveName}', CaseString, Name + '_DefrostEnergyCorrectionCurve', False);
      CaseString := ReplaceRegExpr('#{DefrostEnergyCorrectionCurveObjectName}', CaseString, Name + '_DefrostEnergyCorrectionCurve', False);
    end;
    //refrigerated case restocking schedule name
    if not SameText(RestockSchedule, 'NotSet') then
    begin
      CaseString := ReplaceRegExpr('#{RestockSchedule}\w*', CaseString, RestockSchedule, False);
      CaseString := ReplaceRegExpr('#{RestockScheduleObject}', CaseString, Name + '_RestockSchedule', False);
    end
    else
    begin
      CaseString := ReplaceRegExpr('#{RestockSchedule}', CaseString, Name + '_RestockSchedule', False);
      CaseString := ReplaceRegExpr('#{RestockScheduleObject}', CaseString, Name + '_RestockSchedule', False);
    end;
    //refrigerated case credit fraction schedule
    if not SameText(CaseCreditSchedule, 'NotSet') then
    begin
      CaseString := ReplaceRegExpr('#{CaseCreditSchedule}\w*', CaseString, CaseCreditSchedule, False);
      CaseString := ReplaceRegExpr('#{CaseCreditScheduleObject}', CaseString, Name + '_CaseCreditSchedule', False);
    end
    else
    begin
      CaseString := ReplaceRegExpr('#{CaseCreditSchedule}', CaseString, Name + '_CaseCreditSchedule', False);
      CaseString := ReplaceRegExpr('#{CaseCreditScheduleObject}', CaseString, Name + '_CaseCreditSchedule', False);
    end;
    //to idf
    CaseString := ReplaceRegExpr(#$D#$A#$D#$A#$D#$A, CaseString, '', False);
    CaseStringList := TStringList.Create;
    CaseStringList.Add(CaseString);
    IDF.AddStringList(CaseStringList);
    if CaseLightSchString <> '' then
    begin
      CaseLightSchString := ReplaceRegExpr(#$D#$A#$D#$A#$D#$A, CaseLightSchString, '', False);
      CaseLightSchStringList := TStringList.Create;
      CaseLightSchStringList.Add(CaseLightSchString);
      IDF.AddStringList(CaseLightSchStringList);
    end;
  finally
    CasePreProcMacro.Free;
    CaseLightSchPreProcMacro.Free;
  end;

end;

{ T_EP_RefrigeratedWalkin }

constructor T_EP_RefrigeratedWalkin.Create;
begin
  inherited;
end;

procedure T_EP_RefrigeratedWalkin.Finalize;
begin
  inherited;
  Name := Zone.Name + '_' + DataSetKey + '_Walkin:' + IntToStr(WalkinID);
end;

procedure T_EP_RefrigeratedWalkin.SetZone(ZoneParameter: T_EP_Zone);
begin
  inherited;
  if Assigned(ZoneParameter) then
  begin
    ZoneValue := ZoneParameter;
  end;
end;

procedure T_EP_RefrigeratedWalkin.ToIDF;
var
  WalkinPreProcMacro: TPreProcMacro;
  WalkinStringList: TStringList;
  WalkinString: string;
  WalkinLightSchPreProcMacro: TPreProcMacro;
  WalkinLightSchStringList: TStringList;
  WalkinLightSchString: string;
begin
  inherited;
  Finalize;
  WalkinPreProcMacro := TPreProcMacro.Create('include/HPBRefrigerationWalkins.imf');
  try
    WalkinString := WalkinPreProcMacro.getDefinedText(DataSetKey);
    WalkinString := ReplaceRegExpr('#{Name}', WalkinString, Name, False);
    //cooling capacity
    if CoolingCapacity >= 0 then
    begin
      WalkinString := ReplaceRegExpr('#{CoolingCapacity}\d*\.\d*', WalkinString, FloatToStr(CoolingCapacity), False);
    end
    else
    begin
      WalkinString := ReplaceRegExpr('#{CoolingCapacity}', WalkinString, '', False);
    end;
    //operating temperature
    if OperatingTemp <> -9999.0 then
    begin
      WalkinString := ReplaceRegExpr('#{OperatingTemp}\-\d*\.\d*', WalkinString, FloatToStr(OperatingTemp), False);
    end
    else
    begin
      WalkinString := ReplaceRegExpr('#{OperatingTemp}', WalkinString, '', False);
    end;
    //source temperature
    if SourceTemp <> -9999.0 then
    begin
      WalkinString := ReplaceRegExpr('#{SourceTemp}\-\d*\.\d*', WalkinString, FloatToStr(SourceTemp), False);
    end
    else
    begin
      WalkinString := ReplaceRegExpr('#{SourceTemp}', WalkinString, '', False);
    end;
    //heating power
    if HeatingPower <> -9999.0 then
    begin
      WalkinString := ReplaceRegExpr('#{HeatingPower}\-\d*\.\d*', WalkinString, FloatToStr(HeatingPower), False);
    end
    else
    begin
      WalkinString := ReplaceRegExpr('#{HeatingPower}', WalkinString, '', False);
    end;
    //heating power schedule
    if not SameText(HeatingPowerSchedule, 'NotSet') then
    begin
      WalkinString := ReplaceRegExpr('#{HeatingPowerSchedule}\w*', WalkinString, HeatingPowerSchedule, False);
      WalkinString := ReplaceRegExpr('#{HeatingPowerScheduleObject}', WalkinString, Name + '_HeatingPowerSchedule', False);
    end
    else
    begin
      WalkinString := ReplaceRegExpr('#{HeatingPowerSchedule}', WalkinString, Name + '_HeatingPowerSchedule', False);
      WalkinString := ReplaceRegExpr('#{HeatingPowerScheduleObject}', WalkinString, Name + '_HeatingPowerSchedule', False);
    end;
    //cooling coil fan power
    if CoolingCoilFanPower <> -9999.0 then
    begin
      WalkinString := ReplaceRegExpr('#{CoolingCoilFanPower}\-\d*\.\d*', WalkinString, FloatToStr(CoolingCoilFanPower), False);
    end
    else
    begin
      WalkinString := ReplaceRegExpr('#{CoolingCoilFanPower}', WalkinString, '', False);
    end;
    //lighting power
    if LightingPower <> -9999.0 then
    begin
      WalkinString := ReplaceRegExpr('#{LightingPower}\-\d*\.\d*', WalkinString, FloatToStr(LightingPower), False);
    end
    else
    begin
      WalkinString := ReplaceRegExpr('#{LightingPower}', WalkinString, '', False);
    end;
    //walkin lighting schedule name
    if not SameText(LightingSchedule, 'NotSet') then
    begin
      WalkinString := ReplaceRegExpr('#{WalkinLightingSchedule}\w*', WalkinString, LightingSchedule, False);
    end
    else
    begin
      WalkinLightSchPreProcMacro := TPreProcMacro.Create('include/HPBRefrigerationLightSch.imf');
      WalkinLightSchString := WalkinLightSchPreProcMacro.getDefinedText(DataSetKey);
      if WalkinLightSchString <> '' then
      begin
        WalkinString := ReplaceRegExpr('#{WalkinLightingSchedule}\w*', WalkinString, Name + '_WalkinLightingSchedule', False);
        WalkinLightSchString := ReplaceRegExpr('#{WalkinLightingScheduleObject}', WalkinLightSchString, Name + '_WalkinLightingSchedule', False);
      end
      else
      begin
        WalkinString := ReplaceRegExpr('#{WalkinLightingSchedule}', WalkinString, '', False);
      end;
    end;
    //defrost type
    if SameText(DefrostType, 'None') then
    begin
      WalkinString := ReplaceRegExpr('#{DefrostType}\w*', WalkinString, 'None', False);
    end
    else if not SameText(DefrostType, 'NotSet') then
    begin
      WalkinString := ReplaceRegExpr('#{DefrostType}\w*', WalkinString, DefrostType, False);
    end
    else
    begin
      WalkinString := ReplaceRegExpr('#{DefrostType}', WalkinString, '', False);
    end;
    //defrost control type
    if SameText(DefrostType, 'None') then
    begin
      WalkinString := ReplaceRegExpr('#{DefrostControlType}\w*', WalkinString, '', False);
    end
    else if not SameText(DefrostControlType, 'NotSet') then
    begin
      WalkinString := ReplaceRegExpr('#{DefrostControlType}\w*', WalkinString, DefrostControlType, False);
    end
    else
    begin
      WalkinString := ReplaceRegExpr('#{DefrostControlType}', WalkinString, '', False);
    end;
    //defrost schedule name
    if not SameText(DefrostSchedule, 'NotSet') then
    begin
      WalkinString := ReplaceRegExpr('#{DefrostSchedule}\w*', WalkinString, DefrostSchedule, False);
      WalkinString := ReplaceRegExpr('#{DefrostScheduleObject}', WalkinString, Name + '_', False);
    end
    else
    begin
      WalkinString := ReplaceRegExpr('#{DefrostSchedule}', WalkinString, Name + '_', False);
      WalkinString := ReplaceRegExpr('#{DefrostScheduleObject}', WalkinString, Name + '_', False);
    end;
    //defrost drip-down schedule name
    if not SameText(DefrostDripDownSchedule, 'NotSet') then
    begin
      WalkinString := ReplaceRegExpr('#{DefrostDripDownSchedule}\w*', WalkinString, DefrostSchedule, False);
      WalkinString := ReplaceRegExpr('#{DefrostDripDownScheduleObject}', WalkinString, Name + '_', False);
    end
    else
    begin
      WalkinString := ReplaceRegExpr('#{DefrostDripDownSchedule}', WalkinString, Name + '_', False);
      WalkinString := ReplaceRegExpr('#{DefrostDripDownScheduleObject}', WalkinString, Name + '_', False);
    end;
    //defrost power
    if DefrostPower <> -9999.0 then
    begin
      WalkinString := ReplaceRegExpr('#{DefrostPower}\d*\.\d*', WalkinString, FloatToStr(DefrostPower), False);
    end
    else
    begin
      WalkinString := ReplaceRegExpr('#{DefrostPower}', WalkinString, '', False);
    end;
    //restocking schedule
    if not SameText(RestockSchedule, 'NotSet') then
    begin
      WalkinString := ReplaceRegExpr('#{RestockSchedule}\w*', WalkinString, RestockSchedule, False);
      WalkinString := ReplaceRegExpr('#{RestockScheduleObject}', WalkinString, Name + '_RestockSchedule', False);
    end
    else
    begin
      WalkinString := ReplaceRegExpr('#{RestockSchedule}', WalkinString, Name + '_RestockSchedule', False);
      WalkinString := ReplaceRegExpr('#{RestockScheduleObject}', WalkinString, Name + '_RestockSchedule', False);
    end;
    //floor surface area
    if FloorSurfaceArea <> -9999.0 then
    begin
      WalkinString := ReplaceRegExpr('#{FloorSurfaceArea}\d*\.\d*', WalkinString, FloatToStr(FloorSurfaceArea), False);
    end
    else
    begin
      WalkinString := ReplaceRegExpr('#{FloorSurfaceArea}', WalkinString, '', False);
    end;
    WalkinString := ReplaceRegExpr('#{ZoneName}', WalkinString, Zone.Name, False);
    //surface area facing zone
    if SurfaceAreaFacingZone <> -9999.0 then
    begin
      WalkinString := ReplaceRegExpr('#{SurfaceAreaFacingZone}\d*\.\d*', WalkinString, FloatToStr(SurfaceAreaFacingZone), False);
    end
    else
    begin
      WalkinString := ReplaceRegExpr('#{SurfaceAreaFacingZone}', WalkinString, '', False);
    end;
    //reach-in door schedule
    if not SameText(ReachInDoorSchedule, 'NotSet') then
    begin
      WalkinString := ReplaceRegExpr('#{ReachInDoorSchedule}\w*', WalkinString, ReachInDoorSchedule, False);
      WalkinString := ReplaceRegExpr('#{ReachInDoorScheduleObject}', WalkinString, Name + '_ReachInDoorSchedule', False);
    end
    else
    begin
      WalkinString := ReplaceRegExpr('#{ReachInDoorSchedule}', WalkinString, Name + '_ReachInDoorSchedule', False);
      WalkinString := ReplaceRegExpr('#{ReachInDoorScheduleObject}', WalkinString, Name + '_ReachInDoorSchedule', False);
    end;
    //stocking door schedule
    if not SameText(StockingDoorSchedule, 'NotSet') then
    begin
      WalkinString := ReplaceRegExpr('#{StockingDoorSchedule}\w*', WalkinString, StockingDoorSchedule, False);
      WalkinString := ReplaceRegExpr('#{StockingDoorScheduleObject}', WalkinString, Name + '_StockingDoorSchedule', False);
    end
    else
    begin
      WalkinString := ReplaceRegExpr('#{StockingDoorSchedule}', WalkinString, Name + '_StockingDoorSchedule', False);
      WalkinString := ReplaceRegExpr('#{StockingDoorScheduleObject}', WalkinString, Name + '_StockingDoorSchedule', False);
    end;
    //to idf
    WalkinString := ReplaceRegExpr(#$D#$A#$D#$A#$D#$A, WalkinString, '', False);
    WalkinStringList := TStringList.Create;
    WalkinStringList.Add(WalkinString);
    IDF.AddStringList(WalkinStringList);
    if WalkinLightSchString <> '' then
    begin
      WalkinLightSchString := ReplaceRegExpr(#$D#$A#$D#$A#$D#$A, WalkinLightSchString, '', False);
      WalkinLightSchStringList := TStringList.Create;
      WalkinLightSchStringList.Add(WalkinLightSchString);
      IDF.AddStringList(WalkinLightSchStringList);
    end;
  finally
    WalkinPreProcMacro.Free;
    WalkinLightSchPreProcMacro.Free;
  end;
end;

{ T_EP_SolarCollector }

constructor T_EP_SolarCollector.Create;
begin
  inherited;
  Misc.Add(self); // This is kind of a kludge
  Name := 'Solar Collector 1';
  ComponentType := 'SolarCollector:FlatPlate:Water';
  ControlType := 'Passive';
  DemandControlType := 'Passive';
  Typ := 'GLAZED FLAT-PLATE';
  Tilt := 45.0;
  Area := 3.0;
  DemandInletNode := Name + ' Inlet Node Name'; // this is not going to work too well if name changes
  DemandOutletNode := Name + ' Outlet Node Name';
end;

procedure T_EP_SolarCollector.Finalize;
begin
  inherited;
end;

procedure T_EP_SolarCollector.ToIDF;
var
  x0, y0, z0: double;
  x1, y1, z1: double;
  x2, y2, z2: double;
  Width: double;
  Obj: TEnergyPlusObject;
begin
  inherited;
  Obj := IDF.AddObject('SolarCollector:FlatPlate:Water');
  Obj.AddField('Name', Name);
  Obj.AddField('SolarCollectorPerformance Name', Name + ' SolarCollectorPerformance Name');
  Obj.AddField('Surface Name', Name + ' Surface');
  Obj.AddField('Inlet Node Name', DemandInletNode);
  Obj.AddField('Outlet Node Name', DemandOutletNode);
  Obj.AddField('Maximum Flow Rate', '', '{m3/s}');
  if Typ = 'UNGLAZED FLAT-PLATE' then
  begin
    Obj := IDF.AddObject('SolarCollectorPerformance:FlatPlate');
    Obj.AddField('Name', Name + ' SolarCollectorPerformance Name', '', 'Unglazed Flat-Plate Collector:  Heliocol USA Inc HC-30');
    Obj.AddField('Gross Area', FloatToStr(Area), '{m2}');
    Obj.AddField('Test Fluid', 'Water', '{WATER}');
    Obj.AddField('Test Flow Rate', '0.0001890', '{m3/s}');
    Obj.AddField('Test Correlation Type', 'Inlet', '{INLET | AVERAGE | OUTLET}');
    Obj.AddField('Coefficient 1 of Efficiency Equation (Y-Intercept)', '0.873', '{}');
    Obj.AddField('Coefficient 2 of Efficiency Equation (1st Order)', '-20.62', '{W/m2-K2}');
    Obj.AddField('Coefficient 3 of Efficiency Equation (2nd Order)', '-0.043', '{W/m2-K2}');
    Obj.AddField('Coefficient 2 of Incident Angle Modifier (1st Order)', '-0.0316', '{}');
    Obj.AddField('Coefficient 3 of Incident Angle Modifier (2nd Order)', '-0.0104', '{}');
  end
  else if Typ = 'GLAZED FLAT-PLATE' then
  begin
    Obj := IDF.AddObject('SolarCollectorPerformance:FlatPlate');
    Obj.AddField('Name', Name + ' SolarCollectorPerformance Name', '', 'Glazed Flat-Plate Collector:  Alternate Energy Technologies AE-32');
    Obj.AddField('Gross Area', FloatToStr(Area), '{m2}');
    Obj.AddField('Test Fluid', 'Water', '{WATER}');
    Obj.AddField('Test Flow Rate', '0.0000388', '{m3/s}');
    Obj.AddField('Test Correlation Type', 'Inlet', '{INLET | AVERAGE | OUTLET}');
    Obj.AddField('Coefficient 1 of Efficiency Equation (Y-Intercept)', '0.691', '{}');
    Obj.AddField('Coefficient 2 of Efficiency Equation (1st Order)', '-3.396', '{W/m2-K2}');
    Obj.AddField('Coefficient 3 of Efficiency Equation (2nd Order)', '-0.00193', '{W/m2-K2}');
    Obj.AddField('Coefficient 2 of Incident Angle Modifier (1st Order)', '-0.1939', '{}');
    Obj.AddField('Coefficient 3 of Incident Angle Modifier (2nd Order)', '-0.0055', '{}');
  end
  else if Typ = 'EVACUATED TUBE' then
  begin
    Obj := IDF.AddObject('SolarCollectorPerformance:FlatPlate');
    Obj.AddField('Name', Name + ' SolarCollectorPerformance Name', '', 'Evacuated Tube Collector:  Beijing Sunda Solar Energy Technology Co Ltd SEIDO 1-8');
    Obj.AddField('Gross Area', FloatToStr(Area), '{m2}');
    Obj.AddField('Test Fluid', 'Water', '{WATER}');
    Obj.AddField('Test Flow Rate', '0.0000360', '{m3/s}');
    Obj.AddField('Test Correlation Type', 'Inlet', '{INLET | AVERAGE | OUTLET}');
    Obj.AddField('Coefficient 1 of Efficiency Equation (Y-Intercept)', '0.5255', '{}');
    Obj.AddField('Coefficient 2 of Efficiency Equation (1st Order)', '-1.3253', '{W/m2-K2}');
    Obj.AddField('Coefficient 3 of Efficiency Equation (2nd Order)', '-0.00422', '{W/m2-K2}');
    Obj.AddField('Coefficient 2 of Incident Angle Modifier (1st Order)', '0.3023', '{}');
    Obj.AddField('Coefficient 3 of Incident Angle Modifier (2nd Order)', '-0.3057', '{}');
  end;
  // Assume the collector surfaces are far away from building
  // (at least until we figure out how to put them on the building without shading each other)
  x0 := -100;
  y0 := -100;
  z0 := 0.0;
  // DLM: huh, are solar collectors always square, does this matter?
  Width := Sqrt(Area);
  x1 := x0;
  x2 := x0 + Width;
  y1 := y0;
  y2 := y0 - Width * Cos(Tilt);
  z1 := z0;
  z2 := z0 + Width * Sin(Tilt);
  Obj := IDF.AddObject('Shading:Site:Detailed');
  Obj.AddField('Name', Name + ' Surface');
  Obj.AddField('Transmittance Schedule', '');
  Obj.AddField('Number Of Vertices', '4', '{}');
  Obj.AddField('Vertex 1 X-Coordinate', FloatToStr(x1), '{m}');
  Obj.AddField('Vertex 1 Y-Coordinate', FloatToStr(y2), '{m}');
  Obj.AddField('Vertex 1 Z-Coordinate', FloatToStr(z2), '{m}');
  Obj.AddField('Vertex 2 X-Coordinate', FloatToStr(x1), '{m}');
  Obj.AddField('Vertex 2 Y-Coordinate', FloatToStr(y1), '{m}');
  Obj.AddField('Vertex 2 Z-Coordinate', FloatToStr(z1), '{m}');
  Obj.AddField('Vertex 3 X-Coordinate', FloatToStr(x2), '{m}');
  Obj.AddField('Vertex 3 Y-Coordinate', FloatToStr(y1), '{m}');
  Obj.AddField('Vertex 3 Z-Coordinate', FloatToStr(z1), '{m}');
  Obj.AddField('Vertex 4 X-Coordinate', FloatToStr(x2), '{m}');
  Obj.AddField('Vertex 4 Y-Coordinate', FloatToStr(y2), '{m}');
  Obj.AddField('Vertex 4 Z-Coordinate', FloatToStr(z2), '{m}');
end;

{ TEndUseComponent }

procedure TEndUseComponent.Finalize;
begin
  inherited;
end;

end.
