////////////////////////////////////////////////////////////////////////////////
//                                                                            //
// Copyright (c) 2008-2020 Alliance for Sustainable Energy.                   //
// All rights reserved.                                                       //
//                                                                            // 
////////////////////////////////////////////////////////////////////////////////

unit EnergyPlusSystemComponents;

interface

uses
  SysUtils,
  Contnrs,
  Globals,
  EnergyPlusCore,
  EnergyPlusZones,
  EnergyPlusSettings,
  math,
  EnergyPlusSystems;

type
  TSystemComponent = class(THVACComponent)
  protected
    SystemValue: T_EP_System; // System refers to one where this component is on the supply side
    procedure SetSystem(SystemParameter: T_EP_System); virtual; abstract;
  public
    WaterSystem: T_EP_ColdWaterSystem;
    property System: T_EP_System read SystemValue write SetSystem; // System is really the Supply Side System
  end;

  // Air Components

type
  T_EP_Fan = class(TSystemComponent)
  protected
    TypeValue: string;
    procedure SetSystem(SystemParameter: T_EP_System); override;
    procedure SetType(TypeParameter: string);
  public
    Efficiency: double;
    PressureDrop: double;
    MotorEfficiency: double;
    Schedule: string;
    FanPwrMinFlowMethod: string;
    FanPwrMinFlowFrac: double;
    FanPwrMinFlowRate: double;
    CurveCoeff1: double;
    CurveCoeff2: double;
    CurveCoeff3: double;
    CurveCoeff4: double;
    CurveCoeff5: double;
    MotorInAirstreamFraction: double;
    BranchName: string;
    Kind: string;
    property Typ: string read TypeValue write SetType;
    procedure ToIDF; override;
    constructor Create; reintroduce;
    procedure Finalize; override;
  end;

type
  T_EP_Coil = class(TSystemComponent)
  protected
    TypeValue: string;
    FuelValue: string;
    procedure SetSystem(SystemParameter: T_EP_System); override;
    procedure SetType(TypeParameter: string);
    procedure SetFuel(FuelParameter: string);
  public
    Efficiency: double;
    COP: double;
    DataSetKey: string;
    AirVolumeMode: string;
    CondenserInletNodeName: string;
    ZoneObj: T_EP_Zone;
    Disabled: boolean;
    // initialized to true, meaning some coils that have bypass fractions are partially bypassed
    // setting this parameter to false, sets the bypass fraction to 0.
    // this is needed when a coil is a companion to a desiccant system.
    ByPassFraction: boolean;
    ClgCoilID: integer;
    HtgCoilID: integer;
    Schedule: string;
    SuppressLatDeg: boolean;
    EvapCondEff: double;
    EvapCondPumpPwr: double;
    BasinHeaterCap: double;
    BranchName: string;
    property Typ: string read TypeValue write SetType;
    property Fuel: string read FuelValue write SetFuel;
    procedure ToIDF; override;
    constructor Create; reintroduce;
    procedure Finalize; override;
  end;

type
  T_EP_DesiccantSystem = class(TSystemComponent)
  protected
    procedure SetSystem(SystemParameter: T_EP_System); override;
  public
    dxCoil: T_EP_Coil;
    procedure ToIDF; override;
    procedure Finalize; override;
    constructor Create; reintroduce;
  end;

type
  T_EP_UnitaryPackage = class(TSystemComponent)
  protected
    TypeValue: string;
    procedure SetSystem(SystemParameter: T_EP_System); override;
    procedure SetType(TypeParameter: string);
  public
    FanType: string;
    FanEfficiency: double;
    FanPressureDrop: double;
    FanOperation: string;
    DataSetKey: string;
    LiquidSystemCondenserName: string;
    DXCoilType: string;
    HtgCoilType: string;
    ReheatCoilType: string;
    CoolCOP: double;
    HeatCOP: double;
    HeatEff: double;
    ZoneObj: T_EP_Zone;
    Cooling: boolean;
    SuppressLatDeg: boolean;
    EvapCondEff: double;
    EvapCondPumpPwr: double;
    BasinHeaterCap: double;
    property Typ: string read TypeValue write SetType;
    procedure ToIDF; override;
    constructor Create; reintroduce;
    procedure Finalize; override;
  end;

type
  T_EP_Humidifier = class(TSystemComponent)
  protected
    procedure SetSystem(SystemParameter: T_EP_System); override;
  public
    HumidifierType: string;
    RatedCapacity: double;
    RatedPower: double;
    RatedFanPower: double;
    StandbyPower: double;
    WaterStorageTankName: string;
    procedure ToIDF; override;
    constructor Create; reintroduce;
    procedure Finalize; override;
  end;

type
  T_EP_EvaporativeCooler = class(TSystemComponent)
  protected
    TypeValue: string;
    procedure SetSystem(SystemParameter: T_EP_System); override;
    procedure SetType(TypeParameter: string);
  public
    Area: double;
    Depth: double;
    WetBulbEffectiveness: double;
    SecondaryFanFlowRate: double;
    SecondaryFanEfficiency: double;
    SecondaryFanPressure: double;
    DewpointEffectiveness: double;
    SecondaryAirType: string;
    WaterRecircPumpPower: double;
	  PressureDrop: double;
    ReliefNodeName: string;
    DriftFraction: double;
    BlowdownRatio: double;
    AvailabilitySchedule: string;
    SetPtMgrName: string;
    property Typ: string read TypeValue write SetType;
    procedure Finalize; override;
    procedure ToIDF; override;
    constructor Create; reintroduce;
  end;

type
  T_EP_DesiccantDehumidifier = class(TSystemComponent)
  protected
    procedure SetSystem(SystemParameter: T_EP_System); override;
  public
    procedure ToIDF; override;
    constructor Create; reintroduce;
    procedure Finalize; override;
  end;

type
  T_EP_TranspiredSolarCollector = class(TSystemComponent)
  protected
    procedure SetSystem(SystemParameter: T_EP_System); override;
  public
    FreeHtgSetptSch: string;
    PerforationDiameter: double;
    PerforationDistance: double;
    CollectorEmissivity: double;
    CollectorAbsorbtivity: double;
    GapThickness: double;
    HoleLayoutPattern: string;
    EffectivenessCorrelation: string;
    ActualToProjectedAreaRatio: double;
    CollectorRoughness: string;
    CollectorThickness: double;
    WindEffectiveness: double;
    DischargeCoefficient: double;
    SetpointNodeName: string;
    ZoneNodeName: string;
    CollectorHeight: double;
    CollectorWidth: double;
    procedure Finalize; override;
    procedure ToIDF; override;
    constructor Create; reintroduce;
  end;

type
  T_EP_HeatRecoveryAirToAir = class(TSystemComponent)
  protected
    procedure SetSystem(SystemParameter: T_EP_System); override;
  public
    AirFlowRate: double;
    SensEff: double;
    LatEff: double;
    ParaPower: double;
    EconBypass: boolean;
    AvailSch: string;
    SetPtMgrName: string;
    HxType: string;
    FrostCtrlType: string;
    ThresholdTemp: double;
    InitialDefrostTime: double;
    RateDefrostTimeIncrease: double;
    ExhaustInletNode: string;
    ExhaustOutletNode: string;
    procedure ToIDF; override;
    constructor Create; reintroduce;
    procedure Finalize; override;
  end;

// Plant Components
type
  T_EP_Pump = class(TSystemComponent)
  protected
    TypeValue: string;
    procedure SetSystem(SystemParameter: T_EP_System); override;
    procedure SetType(TypeParameter: string);
  public
    PumpControlType: string;
    Efficiency: double;
    PressureDrop: double;
    RatedFlowRate: double;
    RatedPower: double;
    CurveCoeff1: double;
    CurveCoeff2: double;
    CurveCoeff3: double;
    CurveCoeff4: double;
    property Typ: string read TypeValue write SetType;
    constructor Create; reintroduce;
    procedure ToIDF; override;
    procedure Finalize; override;
  end;

type
  T_EP_Chiller = class(TSystemComponent)
  protected
    TypeValue: string;
    HeatRejectionValue: string;
    procedure SetSystem(SystemParameter: T_EP_System); override;
    procedure SetHeatRejection(HeatRejectionType: string);
    procedure SetType(TypeParameter: string);
  public
    COP: double;
    DataSetKey: string;
    SizingFactor: double;
    OutletTemperature: double;
    OptimumPartLoadRatio: double;
    MinimumUnloadingRatio: double;
    FlowMode: string;
    UseWatersideEconomizer: boolean;
    UserDefCondPump: boolean;
    HeatRejectionLoop: T_EP_CondenserSystem;
    property HeatRejection: string read HeatRejectionValue write SetHeatRejection;
    property Typ: string read TypeValue write SetType;
    procedure ToIDF; override;
    constructor Create; reintroduce;
    procedure Finalize; override;
  end;

type
  T_EP_HeatPumpWaterToWater = class(TSystemComponent)
  protected
    TypeValue: string;
    procedure SetSystem(SystemParameter: T_EP_System); override;
    procedure SetType(TypeParameter: string);
  public
    //COP : string;
    //HeatRejectionLoop : T_EP_CondenserSystem;
    property Typ: string read TypeValue write SetType;
    procedure ToIDF; override;
    constructor Create; reintroduce;
    procedure Finalize; override;
  end;

type
  T_EP_WaterTank = class(TsystemComponent)
  public
    overflowTankObj: T_EP_WaterTank; // doubt recursion works (?)
    SupplyingObj: TObjectList;
    DemandingObj: TObjectList;
    constructor Create; reintroduce;
    procedure Finalize; override;
  end;

type
  T_EP_WaterUse = class(TsystemComponent)
  public
    ZoneObj: T_EP_Zone;
    // ConnectionObj : T_EP_WaterUseConnection;
    Typ: string;
    SubCategory: string;
    InputUseRatePer: double;
    InputStorageRequiredPer: double;
    InputMaxDemandPer: double;
    InputRecoveryRatePer: double;
    PeakVolFlowRate: double;
    StorageVolume: double;
    HeatingCapacity: double;
    FlowSchedule: string;
    TargetTemperature: double;
    HotServiceTargetTemp: double;
    LatentFraction: double;
    SensibleFraction: double;
    procedure ToIDF; override;
    procedure Finalize; override;
    constructor Create; reintroduce;
  end;

type
  T_EP_WaterUseConnection = class(TsystemComponent)
  protected
    procedure SetSystem(SystemParameter: T_EP_System); override;
  public
    WaterUseObject: T_EP_WaterUse;
    WaterStorageTank: T_EP_WaterTank;
    ReclaimTargetTank: T_EP_WaterTank;
    procedure ToIDF; override;
    procedure Finalize; override;
    constructor Create; reintroduce;
  end;

type
  T_EP_WaterHeater = class(TSystemComponent)
  protected
    DemandSystemValue: T_EP_System;
    procedure SetSystem(SystemParameter: T_EP_System); override;
    procedure SetDemandSystem(SystemParameter: T_EP_System);
  public
    Typ: string;
    Efficiency: double;
    Fuel: string;
    Volume: double;
    Capacity: double;
    Height:  double;
    HeightAspectRatio: double;
    NumNodes: integer;
    TankUValue: double;
    HPWHZone: string;
    COP: double;
    SourceSideOnSupply: boolean;
    SourceSideInletNode: string;
    SourceSideOutletNode: string;
    SourceSideSystem: T_EP_System;
    UseSideOnSupply: boolean;
    UseSideInletNode: string;
    UseSideOutletNode: string;
    UseSideSystem: T_EP_System;
    property DemandSystem: T_EP_System read DemandSystemValue write SetDemandSystem;
    procedure SetUseSideSupplySystem(SystemParameter: T_EP_System);
    procedure SetSourceSideSupplySystem(SystemParameter: T_EP_System);
    procedure SetWaterHeaterSizes;
    procedure ToIDF; override;
    constructor Create; reintroduce;
    procedure Finalize; override;
  end;

type
  T_EP_Boiler = class(TSystemComponent)
  protected
    procedure SetSystem(SystemParameter: T_EP_System); override;
  public
    Typ: string;
    Efficiency: double;
    Capacity: double;
    Fuel: string;
    SizingFactor: double;
    PerformanceCurve: string;
    PerfCurveName: string;
    procedure ToIDF; override;
    constructor Create; reintroduce;
    procedure Finalize; override;
  end;

type
  T_EP_PurchHotWater = class(TSystemComponent)
  protected
    procedure SetSystem(SystemParameter: T_EP_System); override;
  public
    Typ: string;
    Capacity: double;
    procedure ToIDF; override;
    constructor Create; reintroduce;
    procedure Finalize; override;
  end;

type
  T_EP_PurchChilledWater = class(TSystemComponent)
  protected
    procedure SetSystem(SystemParameter: T_EP_System); override;
  public
    Typ: string;
    Capacity: double;
    procedure ToIDF; override;
    constructor Create; reintroduce;
    procedure Finalize; override;
  end;

type
  T_EP_IceStorage = class(TSystemComponent)
  protected
    procedure SetSystem(SystemParameter: T_EP_System); override;
  public
    Typ: string;
    Capacity: double;
    procedure ToIDF; override;
    constructor Create; reintroduce;
    procedure Finalize; override;
  end;

type
  T_EP_WatersideEconomizer = class(TSystemComponent)
  protected
    procedure SetSystem(SystemParameter: T_EP_System); override;
  public
    HeatExchangerType: string;
    procedure ToIDF; override;
    constructor Create; reintroduce;
    procedure Finalize; override;
  end;

// Heat Rejection Components
type
  T_EP_CoolingTower = class(TSystemComponent)
  protected
    TypeValue: string;
    procedure SetSystem(SystemParameter: T_EP_System); override;
    procedure SetType(TypeParameter: string);
  public
    property Typ: string read TypeValue write SetType; //   Typ : string;
    procedure ToIDF; override;
    procedure Finalize; override;
    constructor Create; reintroduce;
  end;

type
  T_EP_FluidCooler = class(TSystemComponent)
  protected
    TypeValue: string;
    procedure SetSystem(SystemParameter: T_EP_System); override;
    procedure SetType(TypeParameter: string);
  public
    Capacity: double;
    property Typ: string read TypeValue write SetType;
    constructor Create; reintroduce;
    procedure ToIDF; override;
    procedure Finalize; override;    
  end;

type
  T_EP_GroundSourceHeatExchanger = class(TSystemComponent)
  protected
    procedure SetSystem(SystemParameter: T_EP_System); override;
  public
    GroundTemp: double;
    IMFDef: string;
    procedure ToIDF; override;
    constructor Create; reintroduce;
    procedure Finalize; override;
  end;

type
  T_EP_RefrigerationCompressor = class(TSystemComponent)
  protected
    procedure SetSystem(SystemParameter: T_EP_System); override;
  public
    DataSetKey: string;
    CompressorID: integer;
    procedure ToIDF; override;
    constructor Create; reintroduce;
    procedure Finalize; override;
  end;

type
  T_EP_RefrigerationCondenser = class(TSystemComponent)
  protected
    HeatRejectionValue: string;
    procedure SetSystem(SystemParameter: T_EP_System); override;
    procedure SetHeatRejection(HeatRejectionType: string);
  public
    DataSetKey: string;
    FanType: string;
    FanPower: double;
    HeatRejectionLoop: T_EP_CondenserSystem;
    property HeatRejection: string read HeatRejectionValue write SetHeatRejection;
    procedure ToIDF; override;
    constructor Create; reintroduce;
    procedure Finalize; override;
  end;

implementation

uses classes, GlobalFuncs, RegExpr, PreProcMacro, StrUtils,
  EnergyPlusPPErrorMessages, EnergyPlusObject;

{ T_EP_Fan }

constructor T_EP_Fan.Create;
begin
  inherited;
  Name := 'Fan 1';
  ComponentType := 'Fan:ConstantVolume';
  ControlType := 'Active';
  DemandControlType := 'Passive';
  Efficiency := 0.7;
  PressureDrop := 500;
  MotorEfficiency := 0.0;
  MotorInAirstreamFraction := 1.0;
  FanPwrMinFlowMethod := 'Fraction';
  FanPwrMinFlowFrac := 0.6;
  FanPwrMinFlowRate := 0.0;
  CurveCoeff1 := -9999.0;
  CurveCoeff2 := -9999.0;
  CurveCoeff3 := -9999.0;
  CurveCoeff4 := -9999.0;
  CurveCoeff5 := -9999.0;
  BranchName := '';
end;

procedure T_EP_Fan.Finalize;
begin
  inherited;
end;

procedure T_EP_Fan.SetSystem(SystemParameter: T_EP_System);
begin
  inherited;
  if Assigned(SystemParameter) then
  begin
    SystemValue := SystemParameter;
    Name := System.Name + BranchName + '_Fan';
    System.FanInletNode := SupplyInletNode; // store for use in Mixed air setpoint manager
    System.FanOutletNode := SupplyOutletNode; // store for use in Mixed air setpoint manager
  end;
end;

procedure T_EP_Fan.SetType(TypeParameter: string);
begin
  TypeValue := TypeParameter;
  if SameText(Typ, 'Constant') then
    ComponentType := 'Fan:ConstantVolume'
  else if SameText(Typ, 'Variable') then
    ComponentType := 'Fan:VariableVolume';
end;

procedure T_EP_Fan.ToIDF;
var
  Obj: TEnergyPlusObject;
begin
  inherited;
  if SameText(Typ, 'Constant') then
  begin
    Obj := IDF.AddObject('Fan:ConstantVolume');
    Obj.AddField('Name', Name);
    if Schedule <> '' then
    begin
      Obj.AddField('Availability Schedule Name', Schedule);
    end
    else
    begin
      Obj.AddField('Availability Schedule Name', T_EP_AirSystem(SystemValue).OperationSchedule);
    end;
    Obj.AddField('Fan Efficiency', FloatToStr(Efficiency), '{}');
    if AnsiContainsText(Name, 'OA Unit') then
    begin
      Obj.AddField('Pressure Rise', FloatToStr(PressureDrop), '{Pa}');
      Obj.AddField('Maximum Flow Rate', 'AUTOSIZE', '{m3/s}');
    end
    else
    begin
      Obj.AddField('Pressure Rise', FloatToStr(PressureDrop + T_EP_AirSystem(SystemValue).ComponentFanPressureDrop), '{Pa}');
      if T_EP_AirSystem(System).DesignSysAirFlowRate <> '' then
        Obj.AddField('Maximum Flow Rate', T_EP_AirSystem(System).DesignSysAirFlowRate, '{m3/s}')
      else
        Obj.AddField('Maximum Flow Rate', 'AUTOSIZE', '{m3/s}');
    end;
    if MotorEfficiency = 0 then
      Obj.AddField('Motor Efficiency', '0.85', '{}')
    else
      Obj.AddField('Motor Efficiency', MotorEfficiency, '{}');
    Obj.AddField('Motor In Airstream Fraction', MotorInAirstreamFraction, '{}');
    Obj.AddField('Air Inlet Node Name', SupplyInletNode);
    Obj.AddField('Air Outlet Node Name', SupplyOutletNode);
    obj.AddField('End-Use Subcategory', 'Fan Energy')   ;
  end
  else if SameText(Typ, 'Variable') then
  begin
    Obj := IDF.AddObject('Fan:VariableVolume');
    Obj.AddField('Name', Name);
    if Schedule <> '' then
      Obj.AddField('Availability Schedule Name', Schedule)
    else
      Obj.AddField('Availability Schedule Name', T_EP_AirSystem(SystemValue).OperationSchedule);
    Obj.AddField('Fan Efficiency', FloatToStr(Efficiency), '{}');
    if AnsiContainsText(Name, 'OA Unit') then
    begin
      Obj.AddField('Pressure Rise', FloatToStr(PressureDrop), '{Pa}');
      Obj.AddField('Maximum Flow Rate', 'AUTOSIZE', '{m3/s}');
    end
    else
    begin
      Obj.AddField('Pressure Rise', FloatToStr(PressureDrop + T_EP_AirSystem(SystemValue).ComponentFanPressureDrop), '{Pa}');
      if T_EP_AirSystem(System).DesignSysAirFlowRate <> '' then
        Obj.AddField('Maximum Flow Rate', T_EP_AirSystem(System).DesignSysAirFlowRate, '{m3/s}')
      else
        Obj.AddField('Maximum Flow Rate', 'AUTOSIZE', '{m3/s}');
    end;
    Obj.AddField('Fan Power Minimum Flow Rate Input Method', FanPwrMinFlowMethod, '{Fraction | FixedFlowRate}');
    if SameText(FanPwrMinFlowMethod, 'Fraction') then
    begin
      Obj.AddField('Fan Power Minimum Flow Fraction', FanPwrMinFlowFrac, '{}');
      Obj.AddField('Fan Power Minimum Air Flow Rate', '', '{m3/s}');
    end
    else if SameText(FanPwrMinFlowMethod, 'FixedFlowRate') then
    begin
      Obj.AddField('Fan Power Minimum Flow Fraction', '', '{}');
      Obj.AddField('Fan Power Minimum Air Flow Rate', FanPwrMinFlowRate, '{m3/s}');
    end;
    if MotorEfficiency = 0.0 then
      Obj.AddField('Motor Efficiency', '0.9', '{}')
    else
      Obj.AddField('Motor Efficiency', MotorEfficiency, '{}');
    Obj.AddField('Motor In Airstream Fraction', MotorInAirstreamFraction, '{}');
    if CurveCoeff1 <> -9999.0 then
      Obj.AddField('Fan Coefficient 1', CurveCoeff1)
    else
      Obj.AddField('Fan Coefficient 1', '0.0407598940'); //Stien/Hydeman Good SP Reset (to 0.5")
    if CurveCoeff2 <> -9999.0 then
      Obj.AddField('Fan Coefficient 2', CurveCoeff2)
    else
      Obj.AddField('Fan Coefficient 2', '0.08804497'); //Stien/Hydeman Good SP Reset (to 0.5")
    if CurveCoeff3 <> -9999.0 then
      Obj.AddField('Fan Coefficient 3', CurveCoeff3)
    else
      Obj.AddField('Fan Coefficient 3', '-0.072926120'); //Stien/Hydeman Good SP Reset (to 0.5")
    if CurveCoeff4 <> -9999.0 then
      Obj.AddField('Fan Coefficient 4', CurveCoeff4)
    else
      Obj.AddField('Fan Coefficient 4', '0.9437398230'); //Stien/Hydeman Good SP Reset (to 0.5")
    if CurveCoeff5 <> -9999.0 then
      Obj.AddField('Fan Coefficient 5', CurveCoeff5)
    else
      Obj.AddField('Fan Coefficient 5', '0'); //Stien/Hydeman Good SP Reset (to 0.5")
    Obj.AddField('Air Inlet Node Name', SupplyInletNode);
    Obj.AddField('Air Outlet Node Name', SupplyOutletNode);
    obj.AddField('End-Use Subcategory', 'Fan Energy');
  end;
end;

{ T_EP_Coil }

constructor T_EP_Coil.Create;
begin
  inherited;
  ComponentType := 'Coil:Heating:Electric';
  ControlType := 'Passive';
  DemandControlType := 'Passive';
  Typ := 'HEATING';
  Fuel := 'ELECTRICITY';
  Efficiency := 0.8;
  COP := 3.0;
  DataSetKey := 'LennoxTGA120S2B';
  AirVolumeMode := 'Constant';
  ByPassFraction := true;
  Disabled := false;
  BranchName := '';
end;

procedure T_EP_Coil.SetSystem(SystemParameter: T_EP_System);
begin
  inherited;
  if Assigned(SystemParameter) then
  begin
    SystemValue := SystemParameter;
    // ksb: in most cases the "Name" has already been set
    // ksb: however taking this out breaks some cases with a heating coil
    // ksb: in the future the name setting should be standardized
    // ksb: I suggest taking it out here because it seems strang to set the
    // ksb: component name using the "system" property
    // ksb: the if statement only sets "Name" if it has not already been set
    if Name = '' then
    begin
      if ((SameText(Typ, 'Cooling')) or (SameText(Typ, 'DXCoolingTwoStageWithHumidityControl')) or (SameText(Typ, 'DXSingleSpeed'))) then
        Name := System.Name + BranchName + '_CoolC ' + IntToStr(ClgCoilID)
      else
        Name := System.Name + BranchName + '_HeatC ' + IntToStr(HtgCoilID);
    end;
    // ksb: these are being reset by the T_EP_Finalize routine
    // ksb: I don't think they are needed anymore
    DemandInletNode := Name + ' Water Inlet Node';
    DemandOutletNode := Name + ' Water Outlet Node';
    // ksb: I don't think it makes sense to set "ControlTypes" using the "system" property
    // ksb: It seems more logical to me to set control type either when the component
    // ksb: is created or when it is added to a system later in the XMLproc routine
    if ComponentType = 'Coil:Cooling:Water:DetailedGeometry' then
    begin
      if SameText(BranchName, '') or SameText(BranchName, '_OA') then
      begin
        System.ControlledComponents.Add(self);
        System.SetpointComponents.Add(self);
      end
      else if SameText(BranchName, '_RC') then
      begin
        System.RecircControlledComponents.Add(self);
        System.RecircSetpointComponents.Add(Self);
      end;
      ControlType := 'Passive'; // used to set control type on branch
      DemandControlType := 'Active';
    end;
    if ComponentType = 'Coil:Cooling:Water' then
    begin
      if SameText(BranchName, '') or SameText(BranchName, '_OA') then
      begin
        System.ControlledComponents.Add(self);
        System.SetpointComponents.Add(self);
      end
      else if SameText(BranchName, '_RC') then
      begin
        System.RecircControlledComponents.Add(self);
        System.RecircSetpointComponents.Add(Self);
      end;
      ControlType := 'Passive'; // used to set control type on branch
      DemandControlType := 'Active';
    end;
    if ComponentType = 'Coil:Heating:Water' then
    begin
      if SameText(BranchName, '') or SameText(BranchName, '_OA') then
      begin
        System.ControlledComponents.Add(self);
        System.SetpointComponents.Add(self);
      end
      else if SameText(BranchName, '_RC') then
      begin
        System.RecircControlledComponents.Add(self);
        System.RecircSetpointComponents.Add(Self);
      end;
      ControlType := 'Passive'; // used to set control type on branch
      DemandControlType := 'Active';
    end;
    if ComponentType = 'CoilSystem:Cooling:DX' then
    begin
      if SameText(BranchName, '') or SameText(BranchName, '_OA') then
        System.SetpointComponents.Add(self)
      else if SameText(BranchName, '_RC') then
        System.RecircSetpointComponents.Add(Self);
      ControlType := 'Passive'; // used to set control type on branch
      DemandControlType := 'Passive';
    end;
    if ComponentType = 'Coil:Heating:Electric' then
    begin
      if SameText(BranchName, '') or SameText(BranchName, '_OA') then
        System.SetpointComponents.Add(self)
      else if SameText(BranchName, '_RC') then
        System.RecircSetpointComponents.Add(Self);
    end;
    if ComponentType = 'Coil:Heating:Gas' then
    begin
      if SameText(BranchName, '') or SameText(BranchName, '_OA') then
        System.SetpointComponents.Add(self)
      else if SameText(BranchName, '_RC') then
        System.RecircSetpointComponents.Add(Self);
    end;
    if ComponentType = 'Coil:Heating:Steam' then
    begin
      if SameText(BranchName, '') or SameText(BranchName, '_OA') then
        System.SetpointComponents.Add(self)
      else if SameText(BranchName, '_RC') then
        System.RecircSetpointComponents.Add(Self);
    end;
  end;
end;

procedure T_EP_Coil.SetType(TypeParameter: string);
begin
  TypeValue := TypeParameter;
  if SameText(Typ,'DXCoolingTwoStageWithHumidityControl') or SameText(Typ, 'DXSingleSpeed') then
    ComponentType := 'CoilSystem:Cooling:DX'
  else if SameText(Typ, 'Cooling') then
  begin
    if SameText(Fuel, 'Electricity') then
      ComponentType := 'CoilSystem:Cooling:DX'
    else if SameText(Fuel, 'Water') then
      ComponentType := 'Coil:Cooling:Water'
    else if SameText(Fuel, 'WaterDetailed') then
    begin
      ComponentType := 'Coil:Cooling:Water:DetailedGeometry';
      DemandControlType := 'Active';
    end;
  end
  else if SameText(Typ, 'Heating') then
  begin
    if SameText(Fuel, 'Electricity') then
    begin
      ComponentType := 'Coil:Heating:Electric';
    end
    else if SameText(Fuel, 'Water') then
    begin
      ComponentType := 'Coil:Heating:Water';
      ControlType := 'Passive'; // used to set control type on branch
      DemandControlType := 'Active';
    end
    else if SameText(Fuel, 'Gas') then
      ComponentType := 'Coil:Heating:Gas'
    else if SameText(Fuel, 'Steam') then
      ComponentType := 'Coil:Heating:Steam';
    //heat pump
    //desuperheating
    //NOTE:  There are actually 19! different types of COIL objects!!!
  end;
end;

procedure T_EP_Coil.SetFuel(FuelParameter: string);
begin
  FuelValue := FuelParameter;
  if SameText(Fuel, 'Electricity') then
  begin
    if SameText(Typ,'Cooling') then
      ComponentType := 'CoilSystem:Cooling:DX'
    else if SameText(Typ, 'Heating') then
      ComponentType := 'Coil:Heating:Electric';
  end
  else if SameText(Fuel, 'Water') then
  begin
    if SameText(Typ,'Cooling') then
      ComponentType := 'Coil:Cooling:Water'
    else if SameText(Typ, 'Heating') then
      ComponentType := 'Coil:Heating:Water';
  end
  else if SameText(Fuel, 'WaterDetailed') then
  begin
    if SameText(Typ,'Cooling') then
      ComponentType := 'Coil:Cooling:Water:DetailedGeometry'
    else if SameText(Typ, 'Heating') then
      ComponentType := 'Coil:Heating:Water';
  end
  else if SameText(Fuel, 'Gas') then
    ComponentType := 'Coil:Heating:Gas'
  else if SameText(Fuel, 'Steam') then
    ComponentType := 'Coil:Heating:Steam';
end;

procedure T_EP_Coil.ToIDF;
var
  Obj: TEnergyPlusObject;
begin
  inherited;
  //allow user to override variable fan = two speed coil
  if SameText(Typ, 'DXSingleSpeed') then
    AirVolumeMode := 'Constant';
  if SameText(Typ,'Cooling') or SameText(Typ, 'DXSingleSpeed') then
  begin
    if SameText(Fuel, 'Electricity') then
    begin
      Obj := IDF.AddObject('CoilSystem:Cooling:DX');
      Obj.AddField('Name', Name);
      if disabled then
        Obj.AddField('Availability Schedule Name', 'ALWAYS_OFF')
      else if Schedule <> '' then
        Obj.AddField('Availability Schedule Name', Schedule)
      else
        Obj.AddField('Availability Schedule Name', 'ALWAYS_ON');
      Obj.AddField('DX Cooling Coil System Inlet Node Name', SupplyInletNode);
      Obj.AddField('DX Cooling Coil System Outlet Node Name', SupplyOutletNode);
      Obj.AddField('DX Cooling Coil System Sensor Node Name', SupplyOutletNode);
      if (AirVolumeMode = 'Constant') then
      begin
        Obj.AddField('Cooling Coil Object Type', 'Coil:Cooling:DX:SingleSpeed');
      end
      else if (AirVolumeMode = 'VARIABLE') then
      begin
        Obj.AddField('Cooling Coil Object Type', 'Coil:Cooling:DX:TwoSpeed');
      end;
      Obj.AddField('Cooling Coil Name', Name + ' DXCoil');
      //need to distinguish between Fan type, for multiSpeed.
      if (AirVolumeMode = 'Constant') then
      begin
        Obj := IDF.AddObject('Coil:Cooling:DX:SingleSpeed');
        Obj.AddField('Name', Name + ' DXCoil');
        Obj.AddField('Availability Schedule Name', 'ALWAYS_ON');
        Obj.AddField('Rated Total Cooling Capacity', 'AUTOSIZE', '{W}');
        Obj.AddField('Rated Sensible Heat Ratio', 'AUTOSIZE', '{}');
        Obj.AddField('Rated COP', FloatToStr(COP), '{}');
        Obj.AddField('Rated Air Flow Rate', 'AUTOSIZE', '{m3/s}');
        Obj.AddField('Rated Evaporator Fan Power Per Volume Flow Rate', '773.3', '{W/(m3/s)}');
        Obj.AddField('Air Inlet Node Name', SupplyInletNode);
        Obj.AddField('Air Outlet Node Name', SupplyOutletNode);
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
            if EvapCondPumpPwr >= 0.0 then
              Obj.AddField('Evaporative Condenser Pump Rated Power Consumption', EvapCondPumpPwr, '{W}')
            else
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
            if BasinHeaterCap >= 0.0 then
              Obj.AddField('Basin Heater Capacity', BasinHeaterCap, '{W/K}')
            else
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
      end
      else if (AirVolumeMode = 'VARIABLE') then
      begin
        Obj := IDF.AddObject('Coil:Cooling:DX:TwoSpeed');
        Obj.AddField('Name', Name + ' DXCoil');
        Obj.AddField('Availability Schedule Name', 'ALWAYS_ON');
        Obj.AddField('Rated High Speed Total Cooling Capacity', 'AUTOSIZE', '{W}');
        Obj.AddField('Rated High Speed Sensible Heat Ratio', 'AUTOSIZE', '{}');
        Obj.AddField('Rated High Speed COP', FloatToStr(COP), '{}');
        Obj.AddField('Rated High Speed Air Flow Rate', 'AUTOSIZE', '{m3/s}');
        Obj.AddField('Unit Internal Static Air Pressure', '', '{Pa}');
        Obj.AddField('Air Inlet Node Name', SupplyInletNode);
        Obj.AddField('Air Outlet Node Name', SupplyOutletNode);
        Obj.AddField('Total Cooling Capacity Function of Temperature Curve Name', Name + '_ClgCapFuncTempCurve');
        Obj.AddField('Total Cooling Capacity Function of Flow Fraction Curve Name', Name + '_ClgCapFuncFlowFracCurve');
        Obj.AddField('Energy Input Ratio Function of Temperature Curve Name', Name + '_ClgEirFuncTempCurve');
        Obj.AddField('Energy Input Ratio Function of Flow Fraction Curve Name', Name + '_ClgEirFuncFlowFracCurve');
        Obj.AddField('Part Load Fraction Correlation Curve Name', Name + '_ClgPlrCurve');
        Obj.AddField('Rated Low Speed Total Cooling Capacity', 'AUTOSIZE', '{W}');
        obj.AddField('Rated Low Speed Sensible Heat Ratio', '0.69');
        obj.AddField('Rated Low Speed COP', FloatToStr(COP), '{}');
        Obj.AddField('Rated Low Speed Air Flow Rate', 'AUTOSIZE');
        Obj.AddField('Low Speed Total Cooling Capacity Function of Temperature Curve Name', Name + '_ClgLowSpdCapFuncTempCurve');
        Obj.AddField('Low Speed Energy Input Ratio Function of Temperature Curve Name', Name + '_ClgLowSpdEirFuncTempCurve');
        Obj.AddField('Condenser Air Inlet Node Name', Name + '_CondAirInletNode');
        if EvapCondEff > 0.0 then
        begin
          Obj.AddField('Condenser Type', 'EvaporativelyCooled');
          Obj.AddField('High Speed Evaporative Condenser Effectiveness', EvapCondEff, '{}');
          Obj.AddField('High Speed Evaporative Condenser Air Flow Rate', 'AUTOSIZE', '{m3/s}');
          if EvapCondPumpPwr >= 0.0 then
            Obj.AddField('High Evaporative Condenser Pump Rated Power Consumption', EvapCondPumpPwr, '{W}')
          else
            Obj.AddField('High Evaporative Condenser Pump Rated Power Consumption', 'AUTOSIZE', '{W}');
          Obj.AddField('Low Speed Evaporative Condenser Effectiveness', EvapCondEff, '{}');
          Obj.AddField('Low Speed Evaporative Condenser Air Flow Rate', 'AUTOSIZE', '{m3/s}');
          if EvapCondPumpPwr >= 0.0 then
            Obj.AddField('Low Evaporative Condenser Pump Rated Power Consumption', EvapCondPumpPwr, '{W}')
          else
            Obj.AddField('Low Evaporative Condenser Pump Rated Power Consumption', 'AUTOSIZE', '{W}');
        end
        else
        begin
          Obj.AddField('Condenser Type', 'AirCooled');
          Obj.AddField('High Speed Evaporative Condenser Effectiveness', '', '{}');
          Obj.AddField('High Speed Evaporative Condenser Air Flow Rate', '', '{m3/s}');
          Obj.AddField('High Speed Evaporative Condenser Pump Rated Power Consumption', '', '{W}');
          Obj.AddField('Low Speed Evaporative Condenser Effectiveness', '', '{}');
          Obj.AddField('Low Speed Evaporative Condenser Air Flow Rate', '', '{m3/s}');
          Obj.AddField('Low Speed Evaporative Condenser Pump Rated Power Consumption', '', '{W}');
        end;
        Obj.AddField('Supply Water Storage Tank Name', '');
        Obj.AddField('Condensate Collection Water Storage Tank Name', '');
        if BasinHeaterCap >= 0.0 then
          Obj.AddField('Basin Heater Capacity', BasinHeaterCap, '{W/K}')
        else
          Obj.AddField('Basin Heater Capacity', '10.0', '{W/K}');
        Obj.AddField('Basin Heater Setpoint Temperature', '2.0', '{C}');
        Obj.AddField('Basin Heater Operating Schedule Name', '');        
      end;
      //add outdoor air node
      Obj := IDF.AddObject('OutdoorAir:Node');
      Obj.AddField('Node Name', Name + '_CondAirInletNode');
      //grab curves from library and write to IDF
      GetDxCurves(DataSetKey, 'Clg', Name, AirVolumeMode);
    end
    else if SameText(Fuel, 'Water') then
    begin
      Obj := IDF.AddObject('Coil:Cooling:Water');
      Obj.AddField('Name', Name);
      if disabled then
      begin
        Obj.AddField('Availability Schedule', 'ALWAYS_OFF');
      end
      else
      begin
        Obj.AddField('Availability Schedule Name', 'ALWAYS_ON');
      end;
      Obj.AddField('Design Water Flow Rate', 'AUTOSIZE', '{m3/s}');
      Obj.AddField('Design Air Flow Rate', 'AUTOSIZE', '{m3/s}');
      Obj.AddField('Design Inlet Water Temperature', 'AUTOSIZE', '{C}');
      Obj.AddField('Design Inlet Air Temperature', 'AUTOSIZE', '{C}');
      Obj.AddField('Design Outlet Air Temperature', 'AUTOSIZE', '{C}');
      Obj.AddField('Design Inlet Humidity Ratio', 'AUTOSIZE', '{kg-H2O/kg-air}');
      Obj.AddField('Design Outlet Humidity Ratio', 'AUTOSIZE', '{kg-H2O/kg-air}');
      Obj.AddField('Water Inlet Node Name', DemandInletNode);
      Obj.AddField('Water Outlet Node Name', DemandOutletNode);
      Obj.AddField('Air Inlet Node Name', SupplyInletNode);
      Obj.AddField('Air Outlet Node Name', SupplyOutletNode);
      Obj.AddField('Type of Analysise', 'SimpleAnalysis', '{*******}');
      Obj.AddField('Heat Exchanger Configuration', 'CrossFlow', '{*********}');
    end
    else if SameText(Fuel, 'WaterDetailed') then
    begin
      Obj := IDF.AddObject('Coil:Cooling:Water:DetailedGeometry');
      Obj.AddField('Name', Name);
      if disabled then
      begin
        Obj.AddField('Availability Schedule Name', 'ALWAYS_OFF');
      end
      else
      begin
        Obj.AddField('Availability Schedule Name', 'ALWAYS_ON');
      end;
      Obj.AddField('Maximum Water Flow Rate', 'AUTOSIZE', '{m3/s}');
      Obj.AddField('Tube Outside Surface Area ', 'AUTOSIZE', '{m2}');
      Obj.AddField('Total Tube Inside Area', 'AUTOSIZE', '{m2}');
      Obj.AddField('Fin Surface Area', 'AUTOSIZE', '{m2}');
      Obj.AddField('Minimum Airflow Area', 'AUTOSIZE', '{m2}');
      Obj.AddField('Coil Depth', 'AUTOSIZE', '{m}');
      Obj.AddField('Fin Diameter', 'AUTOSIZE', '{m}');
      Obj.AddField('Fin Thickness', '0.0015', '{m}');
      Obj.AddField('Tube Inside Diameter ', '0.01445', '{m}');
      Obj.AddField('Tube Outside Diameter', '0.0159', '{m}');
      Obj.AddField('Tube Thermal Conductivity', '386.0', '{W/m-K}');
      Obj.AddField('Fin Thermal Conductivity', '204.0', '{W/m-K}');
      Obj.AddField('Fin Spacing', '0.0018', '{m}');
      Obj.AddField('Tube Depth Spacing', '0.026', '{m}');
      Obj.AddField('Number of Tube Rows', '6');
      Obj.AddField('Number of Tubes per Row', 'AUTOSIZE');
      Obj.AddField('Water Inlet Node Name', DemandInletNode);
      Obj.AddField('Water Outlet Node Name', DemandOutletNode);
      Obj.AddField('Air Inlet Node Name', SupplyInletNode);
      Obj.AddField('Air Outlet Node Name', SupplyOutletNode);
    end
  end
  else if SameText(Typ,'DXCoolingTwoStageWithHumidityControl') then
  begin
    Obj := IDF.AddObject('CoilSystem:Cooling:DX');
    Obj.AddField('Name', Name);
    if disabled then
    begin
      Obj.AddField('Availability Schedule Name', 'ALWAYS_OFF');
    end
    else
    begin
      Obj.AddField('Availability Schedule Name', 'ALWAYS_ON');
    end;
    Obj.AddField('DX Cooling Coil System Inlet Node Name', SupplyInletNode);
    Obj.AddField('DX Cooling Coil System Outlet Node Name', SupplyOutletNode);
    Obj.AddField('DX Cooling Coil System Sensor Node Name', SupplyOutletNode);
    Obj.AddField('Cooling Coil Object Type', 'Coil:Cooling:DX:TwoStageWithHumidityControlMode');
    Obj.AddField('Cooling Coil Name', Name + ' DXCoil');
    //cooling coil
    Obj := IDF.AddObject('Coil:Cooling:DX:TwoStageWithHumidityControlMode');
    Obj.AddField('Name', Name + ' DXCoil');
    Obj.AddField('Availability Schedule Name', 'ALWAYS_ON');
    Obj.AddField('Air Inlet Node Name', SupplyInletNode);
    Obj.AddField('Air Outlet Node Name', SupplyOutletNode);
    Obj.AddField('Crankcase Heater Capacity', '');
    Obj.AddField('Max Outdoor Dry-Bulb Temp For Crankcase Heat Operation', '');
    Obj.AddField('Number of Capacity Stages', IntToStr(2),'1 or 2');
    Obj.AddField('Number of Enhanced Dehumidification Modes', IntToStr(1), '0 or 1');
    Obj.AddField('Normal Mode Stage 1 Coil Performance Object Type', 'CoilPerformance:DX:Cooling');
    Obj.AddField('Normal Mode Stage 1 Coil Performance Object Name', Name + ' ACDXCoil 2 Standard Mode-Stage 1');
    Obj.AddField('Normal Mode Stage 1+2 Coil Performance Object Type', 'CoilPerformance:DX:Cooling');
    Obj.AddField('Normal Mode Stage 1+2 Coil Performance Object Name', Name + ' ACDXCoil 2 Standard Mode-Stage 1&2');
    Obj.AddField('Dehumidification Mode 1 Stage 1 Coil Performance Object Type', 'CoilPerformance:DX:Cooling');
    Obj.AddField('Dehumidification Mode 1 Stage 1 Coil Perforamance Object Name', Name + ' ACDXCoil 2 Subcool Mode-Stage 1');
    Obj.AddField('Dehumidification Mode 1 Stage 1+2 Coil Performance Object Type' ,'CoilPerformance:DX:Cooling');
    Obj.AddField('Dehumidification MOde 1 Stage 1+2 Coil Performance Object Name', Name + ' ACDXCoil 2 Subcool Mode-Stage 1&2');
    //coil performance
    Obj := IDF.AddObject('CoilPerformance:DX:Cooling');
    Obj.AddField('Name', Name + ' ACDXCoil 2 Standard Mode-Stage 1');
    Obj.AddField('Rated Total Cooling Capacity','AUTOSIZE','W');
    Obj.AddField('Rated Sensible Heat Ratio','AUTOSIZE');
    Obj.AddField('Rated COP',FloatToStr(COP));
    Obj.AddField('Rated Air Flow Rate','AUTOSIZE','m3/s');
    if ByPassFraction then
      Obj.AddField('Fraction of Air Flow Bypassed Around Coil','0.4')
    else
      Obj.AddField('Fraction of Air Flow Bypassed Around Coil','0.0');
    Obj.AddField('Total Cooling Capacity function of temperature curve name', Name + ' WindAC2CoolCapFT');
    Obj.AddField('Total Cooling Capacity Function of Flow Fraction Curve Name', Name + ' WindACCoolCapFFF');
    Obj.AddField('Energy Input Ratio Function of Temperature Curve Name', Name + ' WindAC2EIRFT');
    Obj.AddField('Energy Input Ratio Function of Flow Fraction Curve Name', Name + ' WindACEIRFFF');
    Obj.AddField('Cooling Capacity Function of Temperature Curve Name', Name + ' WindACPLFFPLR');
    Obj.AddField('Supply Air Fan Operating Mode','ContinuousFanWithCyclingCompressor');
    Obj.AddField('Nominal Time for Condensate Removal to Begin','','s');
    Obj.AddField('Ratio of Initial Moisture Evaporation Rate and Steady State Latent Capacity','');
    Obj.AddField('Maximum Cycling Rate','','cycles/hr');
    Obj.AddField('Latent Capacity Time Constant','','s');
    if not (CondenserInletNodeName = '') then
      Obj.AddField('CondenserAirInletNodeName',CondenserInletNodeName);
    //coil performance
    Obj := IDF.AddObject('CoilPerformance:DX:Cooling');
    Obj.AddField('Name', Name + ' ACDXCoil 2 Standard Mode-Stage 1&2');
    Obj.AddField('Rated Total Cooling Capacity','AUTOSIZE','W');
    Obj.AddField('Rated Sensible Heat Ratio','AUTOSIZE');
    Obj.AddField('Rated COP',FloatToStr(COP));
    Obj.AddField('Rated Air Flow Rate','AUTOSIZE','m3/s');
    Obj.AddField('Fraction of Air Flow Bypassed Around Coil','0.0');
    Obj.AddField('Total Cooling Capacity function of temperature curve name', Name + ' WindAC2CoolCapFT');
    Obj.AddField('Total Cooling Capacity Function of Flow Fraction Curve Name', Name + ' WindACCoolCapFFF');
    Obj.AddField('Energy Input Ratio Function of Temperature Curve Name', Name + ' WindAC2EIRFT');
    Obj.AddField('Energy Input Ratio Function of Flow Fraction Curve Name', Name + ' WindACEIRFFF');
    Obj.AddField('Cooling Capacity Function of Temperature Curve Name', Name + ' WindACPLFFPLR');
    Obj.AddField('Supply Air Fan Operating Mode','ContinuousFanWithCyclingCompressor');
    Obj.AddField('Nominal Time for Condensate Removal to Begin','','s');
    Obj.AddField('Ratio of Initial Moisture Evaporation Rate and Steady State Latent Capacity','');
    Obj.AddField('Maximum Cycling Rate','','cycles/hr');
    Obj.AddField('Latent Capacity Time Constant','','s');
    if not (CondenserInletNodeName = '') then
      Obj.AddField('CondenserAirInletNodeName',CondenserInletNodeName);
    //coil performance
    Obj := IDF.AddObject('CoilPerformance:DX:Cooling');
    Obj.AddField('Name', Name + ' ACDXCoil 2 Subcool Mode-Stage 1');
    Obj.AddField('Rated Total Cooling Capacity','AUTOSIZE','W');
    Obj.AddField('Rated Sensible Heat Ratio','AUTOSIZE');
    Obj.AddField('Rated COP',FloatToStr(COP));
    Obj.AddField('Rated Air Flow Rate','AUTOSIZE','m3/s');
    if ByPassFraction then
      Obj.AddField('Fraction of Air Flow Bypassed Around Coil','0.4')
    else
      Obj.AddField('Fraction of Air Flow Bypassed Around Coil','0.0');
    Obj.AddField('Total Cooling Capacity function of temperature curve name', Name + ' WindAC2SubClCoolCapFT');
    Obj.AddField('Total Cooling Capacity Function of Flow Fraction Curve Name', Name + ' WindACCoolCapFFF');
    Obj.AddField('Energy Input Ratio Function of Temperature Curve Name', Name + ' WindAC2SubClEIRFT');
    Obj.AddField('Energy Input Ratio Function of Flow Fraction Curve Name', Name + ' WindACEIRFFF');
    Obj.AddField('Cooling Capacity Function of Temperature Curve Name', Name + ' WindACPLFFPLR');
    Obj.AddField('Supply Air Fan Operating Mode','ContinuousFanWithCyclingCompressor');
    Obj.AddField('Nominal Time for Condensate Removal to Begin','','s');
    Obj.AddField('Ratio of Initial Moisture Evaporation Rate and Steady State Latent Capacity','');
    Obj.AddField('Maximum Cycling Rate','','cycles/hr');
    Obj.AddField('Latent Capacity Time Constant','','s');
    if not (CondenserInletNodeName = '') then
      Obj.AddField('CondenserAirInletNodeName',CondenserInletNodeName);
    //coil performance
    Obj := IDF.AddObject('CoilPerformance:DX:Cooling');
    Obj.AddField('Name', Name + ' ACDXCoil 2 Subcool Mode-Stage 1&2');
    Obj.AddField('Rated Total Cooling Capacity','AUTOSIZE','W');
    Obj.AddField('Rated Sensible Heat Ratio','AUTOSIZE');
    Obj.AddField('Rated COP',FloatToStr(COP));
    Obj.AddField('Rated Air Flow Rate','AUTOSIZE','m3/s');
    Obj.AddField('Fraction of Air Flow Bypassed Around Coil','0.0');
    Obj.AddField('Total Cooling Capacity function of temperature curve name', Name + ' WindAC2SubClCoolCapFT');
    Obj.AddField('Total Cooling Capacity Function of Flow Fraction Curve Name', Name + ' WindACCoolCapFFF');
    Obj.AddField('Energy Input Ratio Function of Temperature Curve Name', Name + ' WindAC2SubClEIRFT');
    Obj.AddField('Energy Input Ratio Function of Flow Fraction Curve Name', Name + ' WindACEIRFFF');
    Obj.AddField('Cooling Capacity Function of Temperature Curve Name', Name + ' WindACPLFFPLR');
    Obj.AddField('Supply Air Fan Operating Mode','ContinuousFanWithCyclingCompressor');
    Obj.AddField('Nominal Time for Condensate Removal to Begin','','s');
    Obj.AddField('Ratio of Initial Moisture Evaporation Rate and Steady State Latent Capacity','');
    Obj.AddField('Maximum Cycling Rate','','cycles/hr');
    Obj.AddField('Latent Capacity Time Constant','','s');
    if not (CondenserInletNodeName = '') then
      Obj.AddField('CondenserAirInletNodeName',CondenserInletNodeName);
    //curve
    Obj := IDF.AddObject('Curve:Biquadratic');
    Obj.AddField('Name', Name + ' WindAC2CoolCapFT');
    Obj.AddField('Coefficient1 Constant','1.067939449');
    Obj.AddField('Coefficient2 x','-0.031261829');
    Obj.AddField('Coefficient3 x**2','0.001974308');
    Obj.AddField('Coefficient4 y','-0.002726426');
    Obj.AddField('Coefficient5 y**2','-5.52654E-05');
    Obj.AddField('Coefficient6 x*y','-6.31169E-05');
    Obj.AddField('Minimum Value of x','-100');
    Obj.AddField('Maximum Value of x','100');
    Obj.AddField('Minimum Value of y','-100');
    Obj.AddField('Maximum Value of y','100');
    //curve
    Obj := IDF.AddObject('Curve:Biquadratic');
    Obj.AddField('Name', Name + ' WindAC2EIRFT');
    Obj.AddField('Coefficient1 Constant','0.174059889');
    Obj.AddField('Coefficient2 x','0.022281508');
    Obj.AddField('Coefficient3 x**2','-0.000134077');
    Obj.AddField('Coefficient4 y','0.028298025');
    Obj.AddField('Coefficient5 y**2','0.000485106');
    Obj.AddField('Coefficient6 x*y','-0.001677095');
    Obj.AddField('Minimum Value of x','-100');
    Obj.AddField('Maximum Value of x','100');
    Obj.AddField('Minimum Value of y','-100');
    Obj.AddField('Maximum Value of y','100');
    //curve
    Obj := IDF.AddObject('Curve:Biquadratic');
    Obj.AddField('Name', Name + ' WindAC2SubClCoolCapFT');
    Obj.AddField('Coefficient1 Constant','0.596779741');
    Obj.AddField('Coefficient2 x','0.034216637');
    Obj.AddField('Coefficient3 x**2','0.000113924');
    Obj.AddField('Coefficient4 y','-0.00375859');
    Obj.AddField('Coefficient5 y**2','-9.17495E-05');
    Obj.AddField('Coefficient6 x*y','-8.98373E-05');
    Obj.AddField('Minimum Value of x','-100');
    Obj.AddField('Maximum Value of x','100');
    Obj.AddField('Minimum Value of y','-100');
    Obj.AddField('Maximum Value of y','100');
    //curve
    Obj := IDF.AddObject('Curve:Biquadratic');
    Obj.AddField('Name', Name + ' WindAC2SubClEIRFT');
    Obj.AddField('Coefficient1 Constant','0.435347586');
    Obj.AddField('Coefficient2 x','0.004015641');
    Obj.AddField('Coefficient3 x**2','0.000604235');
    Obj.AddField('Coefficient4 y','0.015824043');
    Obj.AddField('Coefficient5 y**2','0.000747287');
    Obj.AddField('Coefficient6 x*y','-0.001779745');
    Obj.AddField('Minimum Value of x','-100');
    Obj.AddField('Maximum Value of x','100');
    Obj.AddField('Minimum Value of y','-100');
    Obj.AddField('Maximum Value of y','100');
    //curve
    Obj := IDF.AddObject('Curve:Quadratic');
    Obj.AddField('Name', Name + ' WindACCoolCapFFF');
    Obj.AddField('Coefficient1 Constant','0.8');
    Obj.AddField('Coefficient2 x','0.2');
    Obj.AddField('Coefficient3 x**2','0.0');
    Obj.AddField('Minimum Value of x','0.5');
    Obj.AddField('Maximum Value of x','1.5');
    //curve
    Obj := IDF.AddObject('Curve:Quadratic');
    Obj.AddField('Name', Name + ' WindACEIRFFF');
    Obj.AddField('Coefficient1 Constant','1.1552');
    Obj.AddField('Coefficient2 x','-0.1808');
    Obj.AddField('Coefficient3 x**2','0.0256');
    Obj.AddField('Minimum Value of x','0.5');
    Obj.AddField('Maximum Value of x','1.5');
    //curve
    Obj := IDF.AddObject('Curve:Quadratic');
    Obj.AddField('Name', Name + ' WindACPLFFPLR');
    Obj.AddField('Coefficient1 Constant','0.85');
    Obj.AddField('Coefficient2 x','0.15');
    Obj.AddField('Coefficient3 x**2','0.0');
    Obj.AddField('Minimum Value of x','0.0');
    Obj.AddField('Maximum Value of x','1.0');
  end
  else if SameText(Typ, 'Heating') then
  begin
    if SameText(Fuel, 'Electricity') then
    begin
      Obj := IDF.AddObject('Coil:Heating:Electric');
      Obj.AddField('Name', Name);
      if disabled then
      begin
        Obj.AddField('Availability Schedule Name', 'ALWAYS_OFF');
      end
      else
      begin
        Obj.AddField('Availability Schedule Name', 'ALWAYS_ON');
      end;
      Obj.AddField('Efficiency', FloatToStr(Efficiency), '{}');
      Obj.AddField('Nominal Capacity', 'AUTOSIZE', '{W}');
      Obj.AddField('Air Inlet Node Name', SupplyInletNode);
      Obj.AddField('Air Outlet Node Name', SupplyOutletNode);
      Obj.AddField('Temperature Setpoint Node Name', SupplyOutletNode);
    end
    else if SameText(Fuel, 'Water') then
    begin
      Obj := IDF.AddObject('Coil:Heating:Water');
      Obj.AddField('Name', Name);
      if disabled then
      begin
        Obj.AddField('Availability Schedule Name', 'ALWAYS_OFF');
      end
      else
      begin
        Obj.AddField('Availability Schedule Name', 'ALWAYS_ON');
      end;
      Obj.AddField('U-Factor Times Area Value', 'AUTOSIZE', '{W/K}');
      Obj.AddField('Maximum Water Flow Rate', 'AUTOSIZE', '{m3/s}');
      Obj.AddField('Water Inlet Node Name', DemandInletNode);
      Obj.AddField('Water Outlet Node Name', DemandOutletNode);
      Obj.AddField('Air Inlet Node Name', SupplyInletNode);
      Obj.AddField('Air Outlet Node Name', SupplyOutletNode);
      Obj.AddField('Coil Peformance input method', 'UFactorTimesAreaAndDesignWaterFlowRate');
      Obj.Addfield('Nominal Capacity', 'AUTOSIZE');
      Obj.AddField('Design Inlet Water Temperature', '82.2');
      Obj.AddField('Design Inlet Air Temperature', '16.6');
      Obj.AddField('Design Outlet Water Temperature', '71.1');
      Obj.AddField('Design Outlet Air Temperature', '32.2');
      Obj.AddField('Rated Ratio for Air and Water Convection', '1.0', '{}');
    end
    else if SameText(Fuel, 'Gas') then
    begin
      Obj := IDF.AddObject('Coil:Heating:Gas');
      Obj.AddField('Name', Name);
      if disabled then
      begin
        Obj.AddField('Availability Schedule Name', 'ALWAYS_OFF');
      end
      else
      begin
        Obj.AddField('Availability Schedule Name', 'ALWAYS_ON');
      end;
      Obj.AddField('Gas Burner Efficiency', FloatToStr(Efficiency), '{}');
      Obj.AddField('Nominal Capacity', 'AUTOSIZE', '{W}');
      Obj.AddField('Air Inlet Node Name', SupplyInletNode);
      Obj.AddField('Air Outlet Node Name', SupplyOutletNode);
      Obj.AddField('Temperature Setpoint Node Name', SupplyOutletNode);
    end
    else if SameText(Fuel, 'Steam') then
    begin
      ComponentType := 'Coil:Steam:Heating'
    end
      //desuperheating
    else
    begin
      //do nothing
    end;
  end;
end;

procedure T_EP_Coil.Finalize;
begin
  inherited;
end;

{  T_EP_DesiccantSystem }

constructor T_EP_DesiccantSystem.Create;
begin
  inherited;
  ComponentType := 'Dehumidifier:Desiccant:System';
  ControlType := 'Passive';
  dxCoil := T_EP_Coil.Create;
  dxCoil.ByPassFraction := false;
  dxCoil.SetType('DXCoolingTwoStageWithHumidityControl');
end;

procedure T_EP_DesiccantSystem.SetSystem(SystemParameter: T_EP_System);
begin
  inherited;
  if Name = '' then
  begin
      self.SystemValue := SystemParameter;
      Self.System.SetpointComponents.Add(self);
      Name := SystemParameter.Name + 'HCU';
      ControlType := 'Passive';
      dxCoil.CondenserInletNodeName := Name + 'HX Regen Inlet Node';  
  end;
  inherited;
end;

procedure T_EP_DesiccantSystem.Finalize;
begin
  inherited;
end;

procedure T_EP_DesiccantSystem.ToIDF;
var
  Obj: TEnergyPlusObject;
begin
  inherited;

  Obj := IDF.AddObject('Dehumidifier:Desiccant:System');
  Obj.AddField('Name', Name);
  Obj.AddField('Availability Schedule Name', 'ALWAYS_ON');
  Obj.AddField('Desiccant Heat Exchanger Object Type', 'HeatExchanger:Desiccant:BalancedFlow' );
  Obj.AddField('Desiccant Heat Exchanger Name', Name + 'HCU Heat Exchanger' );
  Obj.AddField('Sensor Node Name', SupplyOutletNode );
  Obj.AddField('Regeneration Air Fan Object Type', 'Fan:OnOff');
  Obj.AddField('Regeneration Air Fan Name', Name + 'Regen Fan' );
  Obj.AddField('Regeneration Air Fan Placement', 'DrawThrough' );
  Obj.AddField('Regeneration Air Heater Object Type', '' );
  Obj.AddField('Regeneration Air Heater Name', '' );
  Obj.AddField('Regeneration Inlet Air Setpoint Temperature','46.11', '{C}' );
  Obj.AddField('Companion Cooling Coil Object Typ', 'Coil:Cooling:DX:TwoStageWithHumidityControlMode' );
  Obj.AddField('Companion Cooling Coil Name', self.dxCoil.Name + ' DXCoil' );
  Obj.AddField('Companion Cooling Coil Upstream of Dehumidifier Process Inlet', 'Yes' );
  Obj.AddField('Companion Coil Regeneration Air Heating', 'Yes' );
  Obj.AddField('Exhaust Fan Maximum Flow Rate', '1.05', '{m3/s}' );
  Obj.AddField('Exhaust Fan Maximum Power', '50.0', '{W}' );
  Obj.AddField('Exhaust Fan Power Curve Name', Name + 'EXHAUSTFANPLF' );

  Obj := IDF.AddObject('Curve:Cubic');
  Obj.AddField('Name', Name + 'EXHAUSTFANPLF' );
  Obj.AddField('Coefficient1 Constant', '0' );
  Obj.AddField('Coefficient2 x', '1' );
  Obj.AddField('Coefficient3 x**2', '0' );
  Obj.AddField('Coefficient3 x**3', '0' );
  Obj.AddField('Minimum Value of x', '0' );
  Obj.AddField('Maximum Value of x', '1.0' );

  Obj := IDF.AddObject('Fan:OnOff');
  Obj.AddField('Name', Name + 'Regen Fan');
  Obj.AddField('Availability Schedule Name', 'HVACOperationSchd');
  Obj.AddField('Fan Efficiency', '0.3' );

  Obj.AddField('Pressure Rise', '200'); 
  Obj.AddField('Maximum Flow Rate', 'AUTOSIZE');
  Obj.AddField('Motor Efficiency', '0.9');
  Obj.AddField('Motor in Airstream Fraction', '1.0');
  Obj.AddField('Air Inlet Node Name', Name + 'Regen Fan Inlet Node');
  Obj.AddField('Air Outlet Node Name', Name + 'Regen Fan Outlet Node');



  Obj := IDF.AddObject('OutdoorAir:NodeList');
  Obj.AddField('Node or NodeList Name 1', Name + 'HX Regen Inlet Node' );

  Obj := IDF.AddObject('HeatExchanger:Desiccant:BalancedFlow');
  Obj.AddField('Name', Name + 'HCU Heat Exchanger' );
  Obj.AddField('Availability Schedule Name', 'ALWAYS_ON' );
  Obj.AddField('Regeneration Air Inlet Node Name', Name + 'HX Regen Inlet Node' );
  Obj.AddField('Regeneration Air Outlet Node Name', Name + 'Regen Fan Inlet Node' );
  Obj.AddField('Process Air Inlet Node Name', SupplyInletNode );
  Obj.AddField('Process Air Outlet Node name', SupplyOutletNode );
  Obj.AddField('Heat Exchanger Performance Object Type', 'HeatExchanger:Desiccant:BalancedFlow:PerformanceDataType1' );
  Obj.AddField('Heat Exchanger Performance Name', Name + 'HXDesPerf1' );

  Obj := IDF.AddObject('HeatExchanger:Desiccant:BalancedFlow:PerformanceDataType1');
  Obj.AddField('Name', Name + 'HXDesPerf1' );
  Obj.AddField('Nominal Air Flow Rate', '1.05', '{m3/s}' );
  Obj.AddField('Nominal Air Face Velocity', '3.25', '{m/s}' );
  Obj.AddField('Nominal Electric Power', '50.0', '{W}' );
  Obj.AddField('Temperature Equation Coefficient 1', '-2.53636E+00' );
  Obj.AddField('Temperature Equation Coefficient 2', '2.13247E+01' );
  Obj.AddField('Temperature Equation Coefficient 3', '9.23308E-01' );
  Obj.AddField('Temperature Equation Coefficient 4', '9.43276E+02' );
  Obj.AddField('Temperature Equation Coefficient 5', '-5.92367E+01' );
  Obj.AddField('Temperature Equation Coefficient 6', '-4.27465E-02' );
  Obj.AddField('Temperature Equation Coefficient 7', '1.12204E+02' );
  Obj.AddField('Temperature Equation Coefficient 8', '7.78252E-01' );
  Obj.AddField('Minimum Regeneration Inlet Air Humidity Ratio for Temperature Equation', '0.007143', '{kg/kg}' );
  Obj.AddField('Maximum Regeneration Inlet Air Humidity Ratio for Temperature Equation', '0.024286', '{kg/kg}' );
  Obj.AddField('Minimum Regeneration Inlet Air Temperature for Temperature Equation', '46.111110', '{C}' );
  Obj.AddField('Maximum Regeneration Inlet Air Temperature for Temperature Equation', '46.111112', '{C}' );
  Obj.AddField('Minimum Process Inlet Air Humidity Ratio for Temperature Equation', '0.005000', '{kg/kg}' );
  Obj.AddField('Maximum Process Inlet Air Humidity Ratio for Temperature Equation', '0.015714', '{kg/kg}' );
  Obj.AddField('Minimum Process Inlet Air Temperature for Temperature Equation', '4.583333', '{C}' );
  Obj.AddField('Maximum Process Inlet Air Temperature for Temperature Equation', '21.83333', '{C}' );
  Obj.AddField('Minimum Regeneration Air Velocity for Temperature Equation', '2.286', '{m/s}' );
  Obj.AddField('Maximum Regeneration Air Velocity for Temperature Equation', '4.826', '{m/s}' );
  Obj.AddField('Minimum Regeneration Outlet Air Temperature for Temperature Equation', '35.0', '{C}' );
  Obj.AddField('Maximum Regeneration Outlet Air Temperature for Temperature Equation', '50.0', '{C}' );
  Obj.AddField('Minimum Regeneration Inlet Air Relative Humidity for Temperature Equation', '5.0', '{percent}' );
  Obj.AddField('Maximum Regeneration Inlet Air Relative Humidity for Temperature Equation', '45.0', '{percent}' );
  Obj.AddField('Minimum Process Inlet Air Relative Humidity for Temperature Equation', '80.0', '{percent}' );
  Obj.AddField('Maximum Process Inlet Air Relative Humidity for Temperature Equation', '100.0', '{percent}' );
  Obj.AddField('Humidity Ratio Equation Coefficient 1', '-2.25547E+01' );
  Obj.AddField('Humidity Ratio Equation Coefficient 2', '9.76839E-01' );
  Obj.AddField('Humidity Ratio Equation Coefficient 3', '4.89176E-01' );
  Obj.AddField('Humidity Ratio Equation Coefficient 4', '-6.30019E-02' );
  Obj.AddField('Humidity Ratio Equation Coefficient 5', '1.20773E-02' );
  Obj.AddField('Humidity Ratio Equation Coefficient 6', '5.17134E-05' );
  Obj.AddField('Humidity Ratio Equation Coefficient 7', '4.94917E-02' );
  Obj.AddField('Humidity Ratio Equation Coefficient 8', '-2.59417E-04' );
  Obj.AddField('Minimum Regeneration Inlet Air Humidity Ratio for Humidity Ratio Equation', '0.007143', '{kg/kg}' );
  Obj.AddField('Maximum Regeneration Inlet Air Humidity Ratio for Humidity Ratio Equation', '0.024286', '{kg/kg}' );
  Obj.AddField('Minimum Regeneration Inlet Air Temperature for Humidity Ratio Equation', '46.111110', '{C}' );
  Obj.AddField('Maximum Regeneration Inlet Air Temperature for Humidity Ratio Equation', '46.111112', '{C}' );
  Obj.AddField('Minimum Process Inlet Air Humidity Ratio for Humidity Ratio Equation', '0.005000', '{kg/kg}' );
  Obj.AddField('Maximum Process Inlet Air Humidity Ratio for Humidity Ratio Equation', '0.015714', '{kg/kg}' );
  Obj.AddField('Minimum Process Inlet Air Temperature for Humidity Ratio Equation', '4.583333', '{C}' );
  Obj.AddField('Maximum Process Inlet Air Temperature for Humidity Ratio Equation', '21.83333', '{C}' );
  Obj.AddField('Minimum Regeneration Air Velocity for Humidity Ratio Equation', '2.286', '{m/s}' );
  Obj.AddField('Maximum Regeneration Air Velocity for Humidity Ratio Equation', '4.826', '{m/s}' );
  Obj.AddField('Minimum Regeneration Outlet Air Humidity Ratio for Humidity Ratio Equation', '0.007914', '{kg/kg}' );
  Obj.AddField('Maximum Regeneration Outlet Air Humidity Ratio for Humidity Ratio Equation', '0.026279', '{kg/kg}' );
  Obj.AddField('Minimum Regeneration Inlet Air Relative Humidity for Humidity Ratio Equation', '5.0', '{percent}' );
  Obj.AddField('Maximum Regeneration Inlet Air Relative Humidity for Humidity Ratio Equation', '45.0', '{percent}' );
  Obj.AddField('Minimum Process Inlet Air Relative Humidity for Humidity Ratio Equation', '80.0', '{percent}' );
  Obj.AddField('Maximum Process Inlet Air Relative Humidity for Humidity Ratio Equation', '100.0', '{percent}' );
end;

{  T_EP_UnitaryPackage   }

constructor T_EP_UnitaryPackage.Create;
begin
  inherited;
  Name := 'Unitary Pckg';
// ksb: comment out for now, using setType procedure  ComponentType := 'AirLoopHVAC:UnitaryHeatPump:AirToAir';
  FanType := 'Constant';
  FanEfficiency := 0.5;
  DXCoilType := 'DX';
  HtgCoilType := 'NaturalGas';
  ReheatCoilType := 'gas';
  DataSetKey := 'DefaultUnitaryPackage';
end;

procedure T_EP_UnitaryPackage.Finalize;
begin
  inherited;
end;

procedure T_EP_UnitaryPackage.SetSystem(SystemParameter: T_EP_System);
begin
  inherited;
  if (Assigned(SystemParameter)) then
  begin
    SystemValue := SystemParameter;
    Name := System.Name + '_Unitary_Package'; //NLL: Make sure to put an _ to separate the name of the zone
    T_EP_AirSystem(System).MinSystemAirFlowRatio := 1.0;
    System.SetpointComponents.Add(self);
    ControlType := 'Active'; // used to set control type on branch
    DemandControlType := 'Passive';
  end;
end;

procedure T_EP_UnitaryPackage.SetType(TypeParameter: string);
begin
  TypeValue := TypeParameter;
  if Typ = 'AIRTOAIRHEATPUMPHEATCOOL' then
  begin
    ComponentType := 'AirLoopHVAC:UnitaryHeatPump:AirToAir';
    cooling := true;
  end
  else if Typ = 'AIRTOAIRHEATPUMPHEATONLY' then
  begin
    ComponentType := 'AirLoopHVAC:UnitaryHeatPump:AirToAir';
    cooling := false;
  end
  else if Typ = 'AIRTOAIRHEATCOOL' then
  begin
    ComponentType := 'AirLoopHVAC:UnitaryHeatCool';
    cooling := true;
  end
  else if Typ = 'WATERTOAIRHEATPUMP' then
  begin
    ComponentType := 'AirLoopHVAC:UnitaryHeatPump:WaterToAir';
    cooling := true;
  end
  else if Typ = 'FURNACEHEATONLY' then
  begin
    ComponentType := 'AirLoopHVAC:Unitary:Furnace:HeatOnly';
    cooling := false;
  end
  else
  begin
    //do nothing
  end;
end;

procedure T_EP_UnitaryPackage.ToIDF;
var
  Obj: TEnergyPlusObject;
begin
  inherited;
  ZoneObj := T_EP_Zone(T_EP_AirSystem(System).ZonesServed[0]);
  if Typ = 'AIRTOAIRHEATPUMPHEATCOOL' then
  begin
    // heat pump
    Obj := IDF.AddObject('AirLoopHVAC:UnitaryHeatPump:AirToAir');
    Obj.AddField('Name', Name);
    Obj.AddField('Availability Schedule Name', 'ALWAYS_ON');
    Obj.AddField('Air Inlet Node Name', SupplyInletNode);
    Obj.AddField('Air Outlet Node Name', SupplyOutletNode);
    Obj.AddField('Supply Air Flow Rate During Cooling Operation', 'AUTOSIZE');
    Obj.AddField('Supply Air Flow Rate During Heating Operation', 'AUTOSIZE');
    Obj.AddField('Supply Air Flow Rate When No Cooling or Heating is Needed', 'AUTOSIZE');
    Obj.AddField('Controlling Zone or Thermostat Location', T_EP_Zone(ZoneObj).Name);
    Obj.AddField('Supply Air Fan Object Type', 'Fan:OnOff');
    Obj.AddField('Supply Air Fan Name', name + '_fan');
    Obj.AddField('Heating Coil Object Type', 'Coil:Heating:DX:SingleSpeed');
    Obj.AddField('Heating Coil Name', name + '_heat');
    Obj.AddField('Cooling Coil Object Type', 'Coil:Cooling:DX:SingleSpeed');
    Obj.AddField('Cooling Coil Name', name + '_cool');
    Obj.AddField('Supplemental Heating Coil Object Type', 'Coil:Heating:Electric');
    Obj.AddField('Supplemental Heating Coil Name', name + '_SupHeat');
    Obj.AddField('Maximum Supply Air Temperature from Supplemental Heater', 'AUTOSIZE');
    Obj.AddField('Maximum Outdoor Dry-Bulb Temperature for Supplemental Heater Operation', '14.0');
    Obj.AddField('Fan Placement', 'BlowThrough');
    Obj.AddField('Supply Air Fan Operating Mode Schedule Name', 'ALWAYS_ON');
    // fan
    Obj := IDF.AddObject('Fan:OnOff');
    Obj.AddField('Name', name + '_fan');
    Obj.AddField('Availability Schedule Name', T_EP_AirSystem(System).OperationSchedule);
    Obj.AddField('Fan Efficiency', FloatToStr(FanEfficiency));
    Obj.AddField('Pressure Rise', FloatToStr(FanPressureDrop));
    Obj.AddField('Maximum Flow Rate', 'AUTOSIZE');
    Obj.AddField('Motor Efficiency', '0.9');
    Obj.AddField('Motor in Airstream fraction', '1.0');
    Obj.AddField('Air Inlet Node Name', SupplyInletNode);
    Obj.AddField('Air Outlet Node Name', name + 'DXcool air inlet');
    Obj.AddField('Fan Power Ratio Function of Speed Ratio Curve Name', '');
    Obj.AddField('Fan Efficiency Ratio Function of Speed Ratio Curve Name', '');
    Obj.AddField('End-Use Subcategory', 'Heat Pump Fans');
    // dx heating coil
    Obj := IDF.AddObject('Coil:Heating:DX:SingleSpeed');
    Obj.AddField('Name', name + '_heat');
    Obj.AddField('Availability Schedule Name', 'ALWAYS_ON');
    Obj.AddField('Rated Total Heating Capacity', 'AUTOSIZE', '{W}');
    Obj.AddField('Rated COP', FloatToStr(HeatCOP));
    Obj.AddField('Rated Air Flow Rate', 'AUTOSIZE');
    Obj.AddField('Rated Evaporator Fan Power Per Volume Flow Rate', '773.3');
    Obj.AddField('Air Inlet Node Name', name + 'heatCoil_AirInlet');
    obj.AddField('Air Outlet Node Name', name + 'sup heat air inlet');
    obj.AddField('Total Heating Capacity Function of Temperature Curve Name', Name + '_HtgCapFuncTempCurve');
    obj.AddField('Total Heating Capacity Function of Flow Fraction Curve Name', Name + '_HtgCapFuncFlowFracCurve');
    obj.AddField('Energy Input Ratio Function of Temperature Curve Name', Name + '_HtgEirFuncTempCurve');
    obj.AddField('Energy Input Ratio Function of Flow Fraction Curve Name', Name + '_HtgEirFuncFlowFracCurve');
    Obj.AddField('Part Load Fraction Correlation Curve Name', Name + '_HtgPlrCurve');
    Obj.AddField('Defrost Energy Input Ratio Function of Temperature Curve Name', '');
    Obj.AddField('Minimum Outdoor Dry-Bulb Temperature for Compressor Operation', '-8.0');
    Obj.AddField('Outdoor Dry-Bulb Temperature to Turn On Compressor', '');
    Obj.AddField('Maximum Outdoor Dry-Bulb Temperature for Defrost Operation', '5.0');
    Obj.AddField('Crankcase Heater Capacity', '200.0', '{W}');
    Obj.AddField('Maximum Outdoor Dry-Bulb Temperature for Crankcase Heater Operation', '8.0', '{C}');
    Obj.AddField('Defrost Strategy', 'RESISTIVE');
    Obj.AddField('Defrost Control', 'TIMED');
    Obj.AddField('Defrost Time Period Fraction', '0.166667');
    Obj.AddField('Resistive Defrost Heater Capacity', 'AUTOSIZE', '{W}');
    Obj.AddField('Region Number For Calculating HSPF', '4');
    Obj.AddField('Evaporator Air Inlet Node Name', '');
    // if data set key is not set by user, modify default to grab heat pump curves
    if SameText(DataSetKey, 'DefaultUnitaryPackage') then
      DataSetKey := 'DefaultUnitaryPackageHeatPump';
    GetDxCurves(DataSetKey, 'Htg', Name, '');
    // dx cooling coil
    Obj := IDF.AddObject('Coil:Cooling:DX:SingleSpeed');
    Obj.AddField('Name', Name + '_cool');
    if cooling then
      Obj.AddField('Availability Schedule Name', 'ALWAYS_ON')
    else
      Obj.AddField('Availability Schedule Name', 'ALWAYS_OFF');
    Obj.AddField('Rated Total Cooling Capacity', 'AUTOSIZE', '{W}');
    Obj.AddField('Rated Sensible Heat Ratio', 'AUTOSIZE');
    Obj.AddField('Rated COP', FloatToStr(CoolCOP));
    Obj.AddField('Rated Air Flow Rate', 'AUTOSIZE');
    Obj.AddField('Rated Evaporator Fan Power Per Volume Flow Rate', '773.3', '{W/(m3/s)}');
    Obj.AddField('Air Inlet Node Name', name + 'DXcool air inlet');
    Obj.AddField('Air Outlet Node Name', name + 'heatCoil_AirInlet');
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
        if EvapCondPumpPwr > 0.0 then
          Obj.AddField('Evaporative Condenser Pump Rated Power Consumption', EvapCondPumpPwr, '{W}')
        else
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
        if BasinHeaterCap > 0.0 then
          Obj.AddField('Basin Heater Capacity', BasinHeaterCap, '{W/K}')
        else
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
    // if data set key is not set by user, modify default to grab heat pump curves
    if SameText(DataSetKey, 'DefaultUnitaryPackage') then
      DataSetKey := 'DefaultUnitaryPackageHeatPump';
    GetDxCurves(DataSetKey, 'Clg', Name, '');
    //reheat coil
    Obj := IDF.AddObject('Coil:Heating:Electric');
    Obj.AddField('Name', name + '_SupHeat');
    Obj.AddField('Availability Schedule Name', 'ALWAYS_ON');
    Obj.AddField('Efficiency', '1.0');
    Obj.AddField('Nominal Capacity', 'AUTOSIZE');
    Obj.AddField('Air Inlet Node Name', name + 'sup heat air inlet');
    Obj.AddField('Air Outlet Node Name', SupplyOutletNode);
  end
  //ksb: adding new unitary systems
  else if Typ = 'AIRTOAIRHEATCOOL' then
  begin
    //ksb: PSZ
    Obj := IDF.AddObject('AirLoopHVAC:UnitaryHeatCool');
    Obj.AddField('Name', Name);
    Obj.AddField('Availability Schedule Name', 'ALWAYS_ON');
    Obj.AddField('Unitary System Air Inlet Node Name', SupplyInletNode);
    Obj.AddField('Unitary System Air Outlet Node Name', SupplyOutletNode);
    if SameText(FanOperation,'ContinuousFan') then
      Obj.AddField('Supply Air Fan Operating Mode Schedule Name', 'ALWAYS_ON')
    else
      Obj.AddField('Supply Air Fan Operating Mode Schedule Name', T_EP_AirSystem(System).OperationSchedule); // ksb: blank will cycle fan
    Obj.AddField('Maximum Supply Air Temperature', 'AUTOSIZE');
    Obj.AddField('Supply Air Flow Rate During Cooling Operation', 'AUTOSIZE');
    Obj.AddField('Supply Air Flow Rate During Heating Operation', 'AUTOSIZE');
    Obj.AddField('Supply Air Flow Rate When No Cooling or Heating is Needed', 'AUTOSIZE');
    Obj.AddField('Controlling Zone or Thermostat Location', T_EP_Zone(ZoneObj).Name);
    Obj.AddField('Supply Fan Object Type', 'Fan:OnOff');
    Obj.AddField('Supply Fan Name', name + '_fan');
    Obj.AddField('Fan Placement', 'BlowThrough');
    if SameText(HtgCoilType, 'NaturalGas') then
      Obj.AddField('Heating Coil Object Type', 'Coil:Heating:Gas')
    else if SameText(HtgCoilType, 'Electric') then
      Obj.AddField('Heating Coil Object Type', 'Coil:Heating:Electric');
    Obj.AddField('Heating Coil Name', name + '_HeatCoil');
    // ksb: cooling coil type
    if (T_EP_Zone(ZoneObj).UseHumidistat and
      SameText(DXCoilType,'DXwHXAssist')) then
    begin
      Obj.AddField('Cooling Coil Object Type', 'CoilSystem:Cooling:DX:HeatExchangerAssisted');
      Obj.AddField('Cooling Coil Name', name + '_CoolCoilSystem');
    end
    else
    begin
      Obj.AddField('Cooling Coil Object Type', 'Coil:Cooling:DX:SingleSpeed');
      Obj.AddField('Cooling Coil Name', name + '_CoolCoil');
    end;
    // ksb: reheat type
    if (T_EP_Zone(ZoneObj).UseHumidistat and
      SameText(DXCoilType,'DX')) then
    begin
      Obj.AddField('Dehumidification Control Type', 'CoolReheat');
      if (SameText(ReheatCoilType,'desuperheat')) then
        Obj.AddField('Reheat Coil Object Type', 'Coil:Heating:Desuperheater')
      else if (SameText(ReheatCoilType,'electric')) then
        Obj.AddField('Reheat Coil Object Type', 'Coil:Heating:Electric')
      else
        Obj.AddField('Reheat Coil Object Type', 'Coil:Heating:Gas');
      Obj.AddField('Reheat Coil Name', name + '_ReheatCoil');
    end
    else if (T_EP_Zone(ZoneObj).UseHumidistat and SameText(DXCoilType,'DXwHXAssist')) then
    begin
      Obj.AddField('Dehumidification Control Type', 'Multimode');
      Obj.AddField('Reheat Coil Object Type', '');
      Obj.AddField('Reheat Coil Name', '');
    end
    else
    begin
      Obj.AddField('Dehumidification Control Type', 'None');
      Obj.AddField('Reheat Coil Object Type', '');
      Obj.AddField('Reheat Coil Name', '');
    end;
    //fan
    Obj := IDF.AddObject('Fan:OnOff');
    Obj.AddField('Name', name + '_fan');
    if T_EP_Zone(ZoneObj).UseHumidistat then
      Obj.AddField('Availability Schedule Name', 'ALWAYS_ON')
    else
      Obj.AddField('Availability Schedule Name', T_EP_AirSystem(System).OperationSchedule);
    Obj.AddField('Fan Efficiency', FloatToStr(FanEfficiency));
    Obj.AddField('Pressure Rise', FloatToStr(FanPressureDrop));
    Obj.AddField('Maximum Flow Rate', 'AUTOSIZE');
    Obj.AddField('Motor Efficiency', '0.9');
    Obj.AddField('Motor in Airstream Fraction', '1.0');
    Obj.AddField('Air Inlet Node Name', SupplyInletNode);
    Obj.AddField('Air Outlet Node Name', name + 'CoolCoil air inlet');
    Obj.AddField('Fan Power Ratio Function of Speed Ratio Curve Name', '');
    Obj.AddField('Fan Efficiency Ratio Function of Speed Ratio Curve Name', '');
    Obj.AddField('End-Use Subcategory', 'Unitary Fans');
    //gas heating coil
    if SameText(HtgCoilType, 'NaturalGas') then
    begin
      Obj := IDF.AddObject('Coil:Heating:Gas');
      Obj.AddField('Name', Name + '_HeatCoil');
      Obj.AddField('Availability Schedule Name','ALWAYS_ON');
      Obj.AddField('Gas Burner Efficiency', FloatToStr(HeatEff));
      Obj.AddField('Nominal Capacity','AUTOSIZE');
      Obj.AddField('Air Inlet Node Name', Name + 'HeatCoil Air Inlet');
      if (T_EP_Zone(ZoneObj).UseHumidistat and SameText(DXCoilType,'DX')) then
        Obj.AddField('Air Outlet Node Name', Name + 'ReheatCoil Air Inlet')
      else if (T_EP_Zone(ZoneObj).UseHumidistat and SameText(DXCoilType,'DXwHXAssist')) then
        Obj.AddField('Air Outlet Node Name', Name + 'HX1 Air Inlet')
      else
        Obj.AddField('Air Outlet Node Name', SupplyOutletNode );
    end
    //electric heating coil
    else if SameText(HtgCoilType, 'Electric') then
    begin
      Obj := IDF.AddObject('Coil:Heating:Electric');
      Obj.AddField('Name', Name + '_HeatCoil');
      Obj.AddField('Availability Schedule Name','ALWAYS_ON');
      Obj.AddField('Efficiency', FloatToStr(HeatEff));
      Obj.AddField('Nominal Capacity','AUTOSIZE');
      Obj.AddField('Air Inlet Node Name', Name + 'HeatCoil Air Inlet');
      if (T_EP_Zone(ZoneObj).UseHumidistat and SameText(DXCoilType,'DX')) then
        Obj.AddField('Air Outlet Node Name', Name + 'ReheatCoil Air Inlet')
      else if (T_EP_Zone(ZoneObj).UseHumidistat and SameText(DXCoilType,'DXwHXAssist')) then
        Obj.AddField('Air Outlet Node Name', Name + 'HX1 Air Inlet')
      else
        Obj.AddField('Air Outlet Node Name', SupplyOutletNode);
    end;
    //heat-exchanger assisted cooling coil
    if (T_EP_Zone(ZoneObj).UseHumidistat and SameText(DXCoilType,'DXwHXAssist')) then
    begin
      Obj := IDF.AddObject('CoilSystem:Cooling:DX:HeatExchangerAssisted');
      Obj.AddField('Name', name + '_CoolCoilSystem');
      Obj.AddField('Heat Exchanger Object Type', 'HeatExchanger:AirToAir:SensibleAndLatent');
      Obj.AddField('Heat Exchanger Name', name + '_HX');
      Obj.AddField('Cooling Coil Object Type', 'Coil:Cooling:DX:SingleSpeed');
      Obj.AddField('Cooling Coil Name', name + '_CoolCoil');
      //air to air heat exchanger
      Obj := IDF.AddObject('HeatExchanger:AirToAir:SensibleAndLatent');
      Obj.AddField('Name', Name + '_HX');
      Obj.AddField('Availability Schedule Name', 'ALWAYS_ON');
      Obj.AddField('Nominal Supply Air Flow Rate', '1.0', '{m3/s}');
      Obj.AddField('Sensible Effectiveness at 100% Heating Air Flow', FloatToStr(0.75), '{}');
      Obj.AddField('Latent Effectiveness at 100% Heating Air Flow', FloatToStr(0.0), '{}');
      Obj.AddField('Sensible Effectiveness at 75% Heating Air Flow', FloatToStr(0.75), '{}');
      Obj.AddField('Latent Effectiveness at 75% Heating Air Flow', FloatToStr(0.0), '{}');
      Obj.AddField('Sensible Effectiveness at 100% Cooling Air Flow', FloatToStr(0.75), '{}');
      Obj.AddField('Latent Effectiveness at 100% Cooling Air Flow', FloatToStr(0.0), '{}');
      Obj.AddField('Sensible Effectiveness at 75% Cooling Air Flow', FloatToStr(0.75), '{}');
      Obj.AddField('Latent Effectiveness at 75% Cooling Air Flow', FloatToStr(0.0), '{}');
      Obj.AddField('Supply Air Inlet Node Name', name + 'HX1 air inlet');
      Obj.AddField('Supply Air Outlet Node Name', name + 'CoolCoil air inlet');
      Obj.AddField('Exhaust Air Inlet Node Name', name + 'HX2 air inlet');
      Obj.AddField('Exhaust Air Outlet Node Name', name + 'HeatCoil air inlet');
      Obj.AddField('Nominal Electric Power', FloatToStr(0.0), '{W}');
      Obj.AddField('Supply Outlet Temperature Control', 'No', '{YES | NO}');
      Obj.AddField('Heat Exchanger Type', 'PLATE', '{PLATE | ROTARY}');
      Obj.AddField('Frost Control Type', 'None', '{********}');
      Obj.AddField('Threshold Temperature', '1.7', '{C}');
    end;
    //dx cooling coil
    Obj := IDF.AddObject('Coil:Cooling:DX:SingleSpeed');
    Obj.AddField('Name', name + '_CoolCoil');
    Obj.AddField('Availability Schedule Name', 'ALWAYS_ON');
    Obj.AddField('Rated Total Cooling Capacity', 'AUTOSIZE', '{W}');
    Obj.AddField('Rated Sensible Heat Ratio', 'AUTOSIZE');
    Obj.AddField('Rated COP', floatToStr(CoolCOP));
    Obj.AddField('Rated Air Flow Rate', 'AUTOSIZE');
    Obj.AddField('Rated Evaporator Fan Power Per Volume Flow Rate', '773.3', '{W/(m3/s)}');
    Obj.AddField('Air Inlet Node Name', name + 'CoolCoil air inlet');
    if (T_EP_Zone(ZoneObj).UseHumidistat and SameText(DXCoilType,'DX')) then
      Obj.AddField('Air Outlet Node Name', name + 'HeatCoil air inlet')
    else if (T_EP_Zone(ZoneObj).UseHumidistat and SameText(DXCoilType,'DXwHXAssist')) then
      Obj.AddField('Air Outlet Node Name', name + 'HX2 air inlet')
    else
      Obj.AddField('Air Outlet Node Name', name + 'HeatCoil air inlet');
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
        if EvapCondPumpPwr > 0.0 then
          Obj.AddField('Evaporative Condenser Pump Rated Power Consumption', EvapCondPumpPwr, '{W}')
        else
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
        if BasinHeaterCap > 0.0 then
          Obj.AddField('Basin Heater Capacity', BasinHeaterCap, '{W/K}')
        else
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
    //DX curves
    GetDxCurves(DataSetKey, 'Clg', Name, '');
    if (T_EP_Zone(ZoneObj).UseHumidistat and SameText(DXCoilType,'DX')) then
    begin
      if (SameText(ReheatCoilType, 'desuperheat')) then
      begin
        Obj := IDF.AddObject('Coil:Heating:Desuperheater');
        Obj.AddField('Name', name + '_ReheatCoil');
        Obj.AddField('Available Schedule Name', 'ALWAYS_ON');
        Obj.AddField('Heat Reclaim Recovery Efficiency','0.3');
        Obj.AddField('Air Inlet Node name', name + 'ReheatCoil air inlet');
        Obj.AddField('Air Outlet Node Name', SupplyOutletNode);
        Obj.AddField('Heating Source Type','Coil:Cooling:DX:SingleSpeed');
        Obj.AddField('Heating Source Name',name + '_CoolCoil' );
        Obj.AddField('Coil Temperature Setpoint Node Name', '');
        Obj.AddField('Parasitic Electric Load', '0.0', '{W}');
      end
      else if (SameText(ReheatCoilType, 'electric')) then
      begin
        Obj := IDF.AddObject('Coil:Heating:Electric');
        Obj.AddField('Name', name + '_ReheatCoil');
        Obj.AddField('Available Schedule Name', 'ALWAYS_ON');
        Obj.AddField('Efficiency','1.0');
        Obj.AddField('Nominal Capacity', 'Autosize');
        Obj.AddField('Air Inlet Node name', name + 'ReheatCoil air inlet');
        Obj.AddField('Air Outlet Node Name', SupplyOutletNode);
      end
      else
      begin
        Obj := IDF.AddObject('Coil:Heating:Gas');
        Obj.AddField('Name', name + '_ReheatCoil');
        Obj.AddField('Availability Schedule Name', 'ALWAYS_ON');
        Obj.AddField('Efficiency', '0.8', '{}');
        Obj.AddField('Nominal Capacity', 'AUTOSIZE', '{W}');
        Obj.AddField('Air Inlet Node name', name + 'ReheatCoil air inlet');
        Obj.AddField('Air Outlet Node Name', SupplyOutletNode);
      end;
    end;
  end
  else if Typ = 'WATERTOAIRHEATPUMP' then
  begin
    //ksb: PSZ
    Obj := IDF.AddObject('AirLoopHVAC:UnitaryHeatPump:WaterToAir');
    Obj.AddField('Name', Name);
    Obj.AddField('Availability Schedule Name', 'ALWAYS_ON');
    Obj.AddField('Air Inlet Node Name', SupplyInletNode);
    Obj.AddField('Air Outlet Node Name', SupplyOutletNode);
    Obj.AddField('Supply Air Flow Rate', 'AUTOSIZE');
    Obj.AddField('Controlling Zone or Thermostat Location', T_EP_Zone(ZoneObj).Name);
    Obj.AddField('Supply Air Fan Object Type', 'Fan:OnOff');
    Obj.AddField('Supply Air Fan Name', Name + '_supply_air_fan');
    Obj.AddField('Heating Coil Object Type', 'Coil:Heating:WaterToAirHeatPump:EquationFit');
    Obj.AddField('Heating Coil Name', Name + '_heating_coil');
    Obj.AddField('Heating Convergence', '0.001');
    Obj.AddField('Cooling Coil Object Type', 'Coil:Cooling:WaterToAirHeatPump:EquationFit');
    Obj.AddField('Cooling Coil Name', Name + '_cooling_coil');
    Obj.AddField('Cooling Convergence', '0.001');
    Obj.AddField('Maximum Cycling Rate', '2.5');
    Obj.AddField('Heat Pump Time Constant', '60.0');
    Obj.AddField('Fraction of On-Cycle Power Use', '0.01');
    Obj.AddField('Heat Pump Fan Delay Time', '60.0');
    Obj.AddField('Supplemental Heating Coil Object Type', 'Coil:Heating:Electric');
    Obj.AddField('Supplemental Heating Coil Name', Name + '_supp_heating_coil');
    Obj.AddField('Maximum Supply Air Temperature from Supplemental Heater', 'AUTOSIZE');
    Obj.AddField('Maximum Outdoor Dry-Bulb Temperature for Supplemental Heater Operation', '21.0');
    Obj.AddField('Outdoor Dry-Bulb Temperature Sensor Node Name', name + 'oa_node');
    Obj.AddField('Fan Placement', 'BlowThrough');
    Obj.AddField('Supply Air Fan Operating Mode Schedule Name', 'ALWAYS_ON');
    //outdoor air node list
    Obj := IDF.AddObject('OutdoorAir:NodeList');
    Obj.AddField('Node or NodeList Name 1', name + '_OANode List');
    //outdoor air node
    Obj := IDF.AddObject('NodeList');
    Obj.AddField('Name', name + '_OANode List');
    Obj.AddField('Node 1 Name', name + 'oa_node');
    //fan
    Obj := IDF.AddObject('Fan:OnOff');
    Obj.AddField('Name', Name + '_supply_air_fan');
    Obj.AddField('Availability Schedule Name', T_EP_AirSystem(System).OperationSchedule);
    Obj.AddField('Fan Efficiency', FloatToStr(FanEfficiency));
    Obj.AddField('Pressure Rise', FloatToStr(FanPressureDrop));
    Obj.AddField('Maximum Flow Rate', 'AUTOSIZE');
    Obj.AddField('Motor Efficiency', '0.9');
    Obj.AddField('Motor in Airstream fraction', '1.0');
    Obj.AddField('Air Inlet Node Name', SupplyInletNode);
    Obj.AddField('Air Outlet Node Name', Name + '_cooling_coil_air_inlet');
    Obj.AddField('Fan Power Ratio Function of Speed Ratio Curve Name', '');
    Obj.AddField('Fan Efficiency Ratio Function of Speed Ratio Curve Name', '');
    Obj.AddField('End-Use Subcategory', 'WAHP Fans');
    //cooling coil
    Obj := IDF.AddObject('Coil:Cooling:WaterToAirHeatPump:EquationFit');
    Obj.AddField('Name', Name + '_cooling_coil');
    Obj.AddField('Water Inlet Node Name', Name + '_cooling_coil_water_inlet');
    Obj.AddField('Water Outlet Node Name', Name + '_cooling_coil_water_outlet');
    Obj.AddField('Air Inlet Node Name', Name + '_cooling_coil_air_inlet');
    Obj.AddField('Air Outlet Node Name', Name + '_heating_coil_air_inlet');
    Obj.AddField('Rated Air Volumetric Flow Rate','AUTOSIZE');
    Obj.AddField('Rated Water Volumetric Flow Rate','AUTOSIZE');
    Obj.AddField('Rated Total Cooling Capacity','AUTOSIZE');
    Obj.AddField('Rated Sensible Cooling Capacity','AUTOSIZE');
    Obj.AddField('Rated Cooling Coefficient of Performance',HeatCOP);
    Obj.AddField('Total Cooling Capacity Coefficient 1','-0.68');
    Obj.AddField('Total Cooling Capacity Coefficient 2','2.00');
    Obj.AddField('Total Cooling Capacity Coefficient 3','-0.94');
    Obj.AddField('Total Cooling Capacity Coefficient 4','0.02');
    Obj.AddField('Total Cooling Capacity Coefficient 5','0.01');
    Obj.AddField('Sensible Cooling Capacity Coefficient 1','2.24');
    Obj.AddField('Sensible Cooling Capacity Coefficient 2','7.29');
    Obj.AddField('Sensible Cooling Capacity Coefficient 3','-9.06');
    Obj.AddField('Sensible Cooling Capacity Coefficient 4','-0.37');
    Obj.AddField('Sensible Cooling Capacity Coefficient 5','0.22');
    Obj.AddField('Sensible Cooling Capacity Coefficient 6','0.01');
    Obj.AddField('Cooling Power Consumption Coefficient 1','-3.20');
    Obj.AddField('Cooling Power Consumption Coefficient 2','0.48');
    Obj.AddField('Cooling Power Consumption Coefficient 3','3.17');
    Obj.AddField('Cooling Power Consumption Coefficient 4','0.10');
    Obj.AddField('Cooling Power Consumption Coefficient 5','-0.04');
    Obj.AddField('Nominal Time for Condensate Removal to Begin','0');
    Obj.AddField('Ratio of Initial Moisture Evaporation Rate and Steady State Latent Capacity','0');
    //heating coil
    Obj := IDF.AddObject('Coil:Heating:WaterToAirHeatPump:EquationFit');
    Obj.AddField('Name', Name + '_heating_coil');
    Obj.AddField('Water Inlet Node Name', Name + '_heating_coil_water_inlet');
    Obj.AddField('Water Outlet Node Name', Name + '_heating_coil_water_outlet');
    Obj.AddField('Air Inlet Node Name', Name + '_heating_coil_air_inlet');
    Obj.AddField('Air Outlet Node Name', Name + '_sup_heating_coil_air_inlet');
    Obj.AddField('Rated Air Volumetric Flow Rate','AUTOSIZE');
    Obj.AddField('Rated Water Volumetric Flow Rate','AUTOSIZE');
    Obj.AddField('Rated Heating Capacity','AUTOSIZE');
    Obj.AddField('Rated Heating Coefficient of Performance',CoolCOP);
    Obj.AddField('Heating Capacity Coefficient 1','-5.50');
    Obj.AddField('Heating Capacity Coefficient 2','-0.97');
    Obj.AddField('Heating Capacity Coefficient 3','7.71');
    Obj.AddField('Heating Capacity Coefficient 4','0.03');
    Obj.AddField('Heating Capacity Coefficient 5','0.03');
    Obj.AddField('Heating Power Consumption Coefficient 1','-7.48');
    Obj.AddField('Heating Power Consumption Coefficient 2','6.41');
    Obj.AddField('Heating Power Consumption Coefficient 3','2.00');
    Obj.AddField('Heating Power Consumption Coefficient 4','-0.05');
    Obj.AddField('Heating Power Consumption Coefficient 5','0.01');
    //supplemental heating coil
    Obj := IDF.AddObject('Coil:Heating:Electric');
    Obj.AddField('Name', Name + '_supp_heating_coil');
    Obj.AddField('Availability Schedule Name', 'ALWAYS_ON');
    Obj.AddField('Efficiency', '1.0');
    Obj.AddField('Nominal Capacity', 'AUTOSIZE');
    Obj.AddField('Air Inlet Node Name', Name + '_sup_heating_coil_air_inlet');
    Obj.AddField('Air Outlet Node Name', SupplyOutletNode);
  end
  else if Typ = 'FURNACEHEATONLY' then
  begin
    Obj := IDF.AddObject('AirLoopHVAC:Unitary:Furnace:HeatOnly');
    Obj.AddField('Name', Name);
    Obj.AddField('Availability Schedule Name', 'ALWAYS_ON');
    Obj.AddField('Furnace Air Inlet Node Name', SupplyInletNode);
    Obj.AddField('Furnace Air Outlet Node Name', SupplyOutletNode);
    if SameText(FanOperation,'ContinuousFan') then
    begin
      Obj.AddField('Supply Air Fan Operating Mode Schedule Name', 'ALWAYS_ON')
    end
    else
    begin
      Obj.AddField('Supply Air Fan Operating Mode Schedule Name', 'HVACOperationSchd');
    end;
    Obj.AddField('Maximum Supply Air Temperature', 'AUTOSIZE');
    Obj.AddField('Supply Air Flow Rate', 'AUTOSIZE');
    Obj.AddField('Controlling Zone or Thermostat Location', T_EP_Zone(ZoneObj).Name);
    Obj.AddField('Supply Fan Object Type', 'Fan:OnOff');
    Obj.AddField('Supply Air Fan Name', Name + '_Fan');
    Obj.AddField('Fan Placement', 'BlowThrough');
    Obj.AddField('Heating Coil Object Type', 'Coil:Heating:Gas');
    Obj.AddField('Heating Coil Name', Name + '_HeatingCoil');
    //fan
    Obj := IDF.AddObject('Fan:OnOff');
    Obj.AddField('Name', Name + '_Fan');
    Obj.AddField('Availability Schedule Name', 'ALWAYS_ON');
    Obj.AddField('Fan Efficiency', FloatToStr(FanEfficiency));
    Obj.AddField('Pressure Rise', FloatToStr(FanPressureDrop));
    Obj.AddField('Maximum Flow Rate', 'AUTOSIZE');
    Obj.AddField('Motor Efficiency', '0.9');
    Obj.AddField('Motor in Airstream Fraction', '1.0');
    Obj.AddField('Air Inlet Node Name', SupplyInletNode);
    Obj.AddField('Air Outlet Node Name', Name + 'Heating Coil Air Inlet');
    Obj.AddField('Fan Power Ratio Function of Speed Ratio Curve Name', '');
    Obj.AddField('Fan Efficiency Ratio Function of Speed Ratio Curve Name', '');
    Obj.AddField('End-Use Subcategory', 'Unitary Fans');

    Obj := IDF.AddObject('Coil:Heating:Gas');
    Obj.AddField('Name', Name + '_HeatingCoil');
    Obj.AddField('Availability Schedule Name', 'ALWAYS_ON');
    Obj.AddField('Gas Burner Efficiency', FloatToStr(HeatEff));
    Obj.AddField('Nominal Capacity','AUTOSIZE');
    Obj.AddField('Air Inlet Node Name', Name + 'Heating Coil Air Inlet');
    Obj.AddField('Air Outlet Node Name', SupplyOutletNode);
  end;
end;

{ T_EP_Humidifier }
constructor T_EP_Humidifier.Create;
begin
  inherited;
  ComponentType := 'Humidifier:Steam:Electric';
  ControlType := 'Passive';
end;

procedure T_EP_Humidifier.Finalize;
begin
  inherited;
end;


procedure T_EP_Humidifier.ToIDF;
var
  Obj: TEnergyPlusObject;
begin
  inherited;

  Obj := IDF.AddObject(ComponentType);
  Obj.AddField('Name', Name);
  Obj.AddField('Availability Schedule Name','ALWAYS_ON');
  Obj.AddField('Rated Capacity',FloatToStr(RatedCapacity),'m3/s');
  Obj.AddField('Rated Power',FloatToStr(RatedPower),'W');
  Obj.AddField('Rated Fan Power',FloatToStr(RatedFanPower),'W');
  Obj.AddField('Standby Power', FloatToStr(StandbyPower), 'W');
  Obj.AddField('Air inlet node name',SupplyInletNode);
  Obj.AddField('Air outlet node name',SupplyOutletNode);
  Obj.AddField('Water storage tank name',WaterStorageTankName);
  
end;

procedure T_EP_Humidifier.SetSystem(SystemParameter: T_EP_System);
begin
  inherited;
  SystemValue := SystemParameter;
  Name := System.Name + ' Humidifier';
  System.SetpointComponents.Add(self);
end;


{ T_EP_EvaporativeCooler }

constructor T_EP_EvaporativeCooler.Create;
begin
  inherited;
  Name := 'Evap Cooler 1';
  Typ := 'Indirect:ResearchSpecial';
  ComponentType := 'EvaporativeCooler:Indirect:ResearchSpecial';
  ControlType := 'Passive';
  DemandControlType := 'Passive';
  Area := 0.5;
  Depth := 0.4;
  SecondaryFanFlowRate := -99999.0 ; // init to E+ autosize value
  SecondaryFanEfficiency := 0.4 ;
  SecondaryFanPressure := 0.0; //crude init
  SecondaryAirType := 'OUTSIDE';
  DewpointEffectiveness := 0.9 ; //crude init
  WetBulbEffectiveness := 0.7 ; //crude init
  WaterRecircPumpPower := 0.0; //crude init
  DriftFraction := 0.0;
  BlowdownRatio := 3.0;
end;

procedure T_EP_EvaporativeCooler.SetSystem(SystemParameter: T_EP_System);
begin
  inherited;
  if Assigned(SystemParameter) then
  begin
    SystemValue := SystemParameter;
    Name := System.Name + '_Evap_Cooler';
    //T_EP_AirSystem(SystemParameter).UseLowTempTurnOff := true;
    if (SameText(Typ, 'Indirect:RDDSpecial')) or (SameText(Typ, 'Indirect:ResearchSpecial')) then
    begin
      System.SetpointComponents.Add(self);
      Name := System.Name + '_Indirect_Evap_Cooler';
    end;
    if SameText(Typ, 'Direct:ResearchSpecial') then
    begin
      System.SetpointComponents.Add(self);
      Name := System.Name + '_Direct_Evap_Cooler';
    end;
    if SameText(Typ, 'Direct') then
    begin
      Name := System.Name + '_Direct_Evap_Cooler';
    end;
  end;
end;

procedure T_EP_EvaporativeCooler.SetType(TypeParameter: string);
begin
  TypeValue := TypeParameter;
  if SameText(Typ, 'Direct') then
    ComponentType := 'EvaporativeCooler:Direct:CelDekPad'
  else if SameText(Typ, 'Indirect') then
    ComponentType := 'EvaporativeCooler:Indirect:CelDekPad'
  else if SameText(Typ, 'Indirect:RDDSpecial') then
    ComponentType := 'EvaporativeCooler:Indirect:ResearchSpecial'
  else if SameText(Typ, 'Indirect:ResearchSpecial') Then
    ComponentType := 'EvaporativeCooler:Indirect:ResearchSpecial'
  else if SameText(Typ, 'Direct:ResearchSpecial') Then
    ComponentType := 'EvaporativeCooler:Direct:ResearchSpecial'  ;
end;

procedure T_EP_EvaporativeCooler.Finalize;
var
  thisZone: Tobject;
  thisZoneArea: double;
begin
  //get zone floor area.
  try
    // ksb: added this try except to handle equipment on a oa air system
    // this was originally written to get the first zone name
    // I am leaving it this way, but what if there are multiple ZonesServed?
    thisZone := T_EP_OutsideAirSystem(System).PrimaryAirSystem.ZonesServed.First;
    ReliefNodeName :=T_EP_OutsideAirSystem(System).MixerReliefNode;
  except
    thisZone := T_EP_AirSystem(System).ZonesServed.First;
    ReliefNodeName :=T_EP_AirSystem(System).FigureOAReliefNodeName;
  end;
  //thisZoneArea := T_EP_Zone(thisZone).Area * T_EP_Zone(thisZone).Multiplier;
  // ksb: area of the evap pad I presume  //Bg yes, only for CelDekPad models
  Area := (thisZoneArea * (1.5 * 0.02832) / (0.0929 * 60)) / 2.5;
  if Area < 0.75 then Area := 0.75;
  if ((ReliefNodeName = ' ') and (SameText(SecondaryAirType, 'RELIEF'))) then
  begin
    SecondaryAirType := 'OUTSIDE';
  end;
end;

procedure T_EP_EvaporativeCooler.ToIDF;
var
  Obj: TEnergyPlusObject;
begin
  inherited;
  finalize;
  if SameText(Typ, 'Direct') then
  begin
    Obj := IDF.AddObject(ComponentType);     //'EvaporativeCooler:Direct:CelDekPad'
    Obj.AddField('Name', Name);
    if not SameText(AvailabilitySchedule, 'NotSet') then
      Obj.AddField('Availability Schedule Name', AvailabilitySchedule)
    else
      Obj.AddField('Availability Schedule Name', 'ALWAYS_ON');
    Obj.AddField('Direct Pad Area', '0.74', '{m2}');
    Obj.AddField('Direct Pad Depth', '0.20', '{m}');
    Obj.AddField('Recirculating Water Pump Power Consumption', '45.0', '{W}');
    Obj.AddField('Air Inlet Node Name', SupplyInletNode);
    Obj.AddField('Air Outlet Node Name', SupplyOutletNode);
    Obj.AddField('Control Type', 'Constant', '{CONSTANT}');
  end
  else if SameText(Typ, 'Indirect') then
  begin
    Obj := IDF.AddObject(ComponentType);      //'EvaporativeCooler:Indirect:CelDekPad'
    Obj.AddField('Name', Name);
    if not SameText(AvailabilitySchedule, 'NotSet') then
      Obj.AddField('Availability Schedule Name', AvailabilitySchedule)
    else
      Obj.AddField('Availability Schedule Name', 'ALWAYS_ON');
    Obj.AddField('Direct Pad Area', FloatToStr(Area), '{m2}');
    Obj.AddField('Direct Pad Depth', FloatToStr(Depth), '{m}');
    Obj.AddField('Recirculating Water Pump Power Consumption', '45.0', '{W}');
    Obj.AddField('Secondary Fan Flow Rate', '1.0', '{m3/s}');
    Obj.AddField('Secondary Fan Efficiency', '0.7', '{}');
    Obj.AddField('Secondary Fan Delta Pressure', '200', '{Pa}');
    Obj.AddField('Indirect Heat Exchanger Effectiveness', '0.67', '{}');
    Obj.AddField('Primary Air Inlet Node Name', SupplyInletNode);
    Obj.AddField('Primary Air Outlet Node Name', SupplyOutletNode);
    Obj.AddField('Control Type', 'Constant', '{CONSTANT}');
    Obj.AddField('Water Supply Storage Tank Name', '' );
    Obj.AddField('Secondary Air Inlet Node Name',  Name + 'secondary OA inlet');
    //oa node
    Obj := IDF.AddObject('OutdoorAir:Node');
    Obj.AddField('Name', Name + 'secondary OA inlet' );
  end
  else if SameText(Typ, 'Direct:ResearchSpecial') Then
  begin
    Obj := IDF.AddObject(ComponentType);   //  'EvaporativeCooler:Direct:ResearchSpecial'
    Obj.AddField('Name', Name);
    if not SameText(AvailabilitySchedule, 'NotSet') then
      Obj.AddField('Availability Schedule Name', AvailabilitySchedule)
    else
      Obj.AddField('Availability Schedule Name', 'ALWAYS_ON');
    Obj.AddField('Cooler Effectiveness', WetBulbEffectiveness) ;
    Obj.AddField('Recirculating Water Pump Power Consumption', WaterRecircPumpPower );
    Obj.AddField('Air Inlet Node Name', SupplyInletNode );
    Obj.AddField('Air Outlet Node Name',SupplyOutletNode );
    Obj.AddField('Sensor Node Name',SupplyOutletNode );
    Obj.AddField('Water Supply Storage Tank Name', '');
    Obj.AddField('Drift Loss Fraction', DriftFraction );
    Obj.AddField('Blowdown Concentration Ratio' , BlowdownRatio );
  end
  else if (SameText(Typ, 'Indirect:RDDSpecial')) or
    (SameText(Typ, 'Indirect:ResearchSpecial')) then
  begin
    Obj := IDF.AddObject(ComponentType);   //  'EvaporativeCooler:Indirect:ResearchSpecial'
    Obj.AddField('Name', Name);
    if not SameText(AvailabilitySchedule, 'NotSet') then
      Obj.AddField('Availability Schedule Name', AvailabilitySchedule)
    else
      Obj.AddField('Availability Schedule Name', 'ALWAYS_ON');
    Obj.AddField('Cooler Maximum Effectiveness', WetBulbEffectiveness) ;
    Obj.AddField('Cooler Flow Ratio', '');
    Obj.AddField('Recirculating Water Pump Power Consumption', WaterRecircPumpPower );
    if  (SecondaryFanFlowRate = -99999.0) then
    begin
      Obj.AddField('Secondary Fan Flow Rate', 'AUTOSIZE' );
    end else
    begin
      Obj.AddField('Secondary Fan Flow Rate', SecondaryFanFlowRate );
    end;
    Obj.AddField('Secondary Fan Efficiency', SecondaryFanEfficiency );
    Obj.AddField('Secondary Fan Delta Pressure',  SecondaryFanPressure );
    obj.AddField('Primary Air Inlet Node Name', SupplyInletNode );
    obj.AddField('Primary Air Outlet Node Name',SupplyOutletNode );
    obj.AddField('Control Type', '');
    obj.AddField('Dewpoint Effectiveness Factor',DewpointEffectiveness ) ;
    if SameText(SecondaryAirType, 'OUTSIDE') then
    begin
      Obj.AddField('Secondary Air Inlet Node Name' , Name + 'OA node');
      Obj.AddField('Sensor Node Name',SupplyOutletNode );
      Obj.AddField('Relief Air Inlet Node Name', '' );
    end
    else if SameText(SecondaryAirType, 'RELIEF') then
    begin
      Obj.AddField('Secondary Air Inlet Node Name' ,Name + 'OA node'  );
      Obj.AddField('Sensor Node Name',SupplyOutletNode );
      Obj.AddField('Relief Air Inlet Node Name', self.ReliefNodeName );
    end;
    Obj.AddField('Water Supply Storage Tank Name', '');
    Obj.AddField('Drift Loss Fraction', DriftFraction );
    Obj.AddField('Blowdown Concentration Ratio' , BlowdownRatio );
    //oa node
    Obj := IDF.AddObject('OutdoorAir:Node');
    Obj.AddField('Name', Name + 'OA node') ;
    Obj.AddField('Height Above Ground', -1, '{m}', 'Height is ignored');
    // ksb: Begin EMS related objects used to economize
    //Obj := IDF.AddObject('Output:EnergyManagementSystem');
    //Obj.AddField('Actuator Availability Dictionary Reporting','Verbose');
    //Obj.AddField('Internal Variable Availability Dictionary Repo','Verbose');
    //Obj.AddField('EMS Runtime Language Debug Output Level','Verbose');
  end;
end;

{ T_EP_TranspiredSolarCollector }

constructor T_EP_TranspiredSolarCollector.Create;
begin
  inherited;
  Name := 'Transpired Solar Collector 1';
  ComponentType := 'SolarCollector:UnglazedTranspired';
  ControlType := 'Passive';
  DemandControlType := 'Passive';
  PerforationDiameter := 0.0016;
  PerforationDistance := 0.01689;
  CollectorEmissivity := 0.9;
  CollectorAbsorbtivity := 0.9;
  GapThickness := 0.1;
  HoleLayoutPattern := 'Triangle';
  EffectivenessCorrelation := 'Kutscher1994';
  ActualToProjectedAreaRatio := 1.165;
  CollectorRoughness := 'MediumRough';
  CollectorThickness := 0.001;
  WindEffectiveness := 0.25;
  DischargeCoefficient := 0.5;
end;

procedure T_EP_TranspiredSolarCollector.SetSystem(SystemParameter: T_EP_System);
begin
  inherited;
  if Assigned(SystemParameter) then
  begin
    SystemValue := SystemParameter;
    Name := System.Name + '_TranspiredSolarCollector';
  end;
end;

procedure T_EP_TranspiredSolarCollector.Finalize;
var
  i: integer;
  j: integer;
  k: integer;
  MaxZ: double;
  MinZ: double;
  Area: double;
begin
  //set node names
  SetpointNodeName := T_EP_OutsideAirSystem(System).MixerOutletNode;
  ZoneNodeName := T_EP_Zone(T_EP_OutsideAirSystem(System).PrimaryAirSystem.ZonesServed[0]).Name + ' Air Node';
  //area
  Area := StrToFloat(TranspiredSolarCollectorArea[0]);
  for i := 1 to TranspiredSolarCollectorArea.Count - 1 do
  begin
    Area := Area + StrToFloat(TranspiredSolarCollectorArea[i]);
  end;
  //max z
  MaxZ := StrToFloat(TranspiredSolarCollectorMaxZ[0]);
  for j := 1 to TranspiredSolarCollectorMaxZ.Count - 1 do
  begin
    if StrToFloat(TranspiredSolarCollectorMaxZ[j]) > MaxZ then
      MaxZ := StrToFloat(TranspiredSolarCollectorMaxZ[j]);
  end;
  //min z
  MinZ := StrToFloat(TranspiredSolarCollectorMinZ[0]);
  for k := 1 to TranspiredSolarCollectorMinZ.Count - 1 do
  begin
    if StrToFloat(TranspiredSolarCollectorMinZ[k]) < MinZ then
      MinZ := StrToFloat(TranspiredSolarCollectorMinZ[k]);
  end;
  //height
  CollectorHeight := MaxZ - MinZ;
  CollectorWidth := Area / CollectorHeight;
end;

procedure T_EP_TranspiredSolarCollector.ToIDF;
var
  Obj: TEnergyPlusObject;
  i: integer;
begin
  inherited;
  Finalize;
  Obj := IDF.AddObject(ComponentType);
  Obj.AddField('Name', Name);
  Obj.AddField('Boundary Conditions Model Name', 'UTSC_BCModel');
  Obj.AddField('Availability Schedule Name', 'ALWAYS_ON');
  Obj.AddField('Inlet Node Name', SupplyInletNode);
  Obj.AddField('Outlet Node Name', SupplyOutletNode);
  Obj.AddField('Setpoint Node Name', SetpointNodeName); //from finalize routine
  Obj.AddField('Zone Node Name', ZoneNodeName);
  Obj.AddField('Free Heating Setpoint Schedule Name', FreeHtgSetptSch);
  Obj.AddField('Diameter of Perforations in Collector', FloatToStr(PerforationDiameter), '{m}');
  Obj.AddField('Distance Between Perforations in Collector', FloatToStr(PerforationDistance), '{m}');
  Obj.AddField('Thermal Emissivity of Collector Surface', FloatToStr(CollectorEmissivity), '{dimensionless}');
  Obj.AddField('Solar Absorbtivity of Collector Surface', FloatToStr(CollectorAbsorbtivity), '{dimensionless}');
  Obj.AddField('Effective Overall Height of Collector', FloatToStr(CollectorHeight));
  Obj.AddField('Effective Gap Thickness of Plenum Behind Collector', FloatToStr(GapThickness), '{m}');
  Obj.AddField('Effective Cross Section Area of Plenum Behind Collector', FloatToStr(GapThickness * CollectorWidth), '{m2}');
  Obj.AddField('Hole Layout Pattern for Pitch', HoleLayoutPattern, '{Triangle | Square}');
  Obj.AddField('Heat Exchange Effectiveness Correlation', EffectivenessCorrelation, '{Kutscher1994 | VanDeckerHollandsBrunger2001}');
  Obj.AddField('Ratio of Actual Collector Surface Area to Projected Surface Area', FloatToStr(ActualToProjectedAreaRatio), '{dimensionless}');
  Obj.AddField('Roughness of Collector', CollectorRoughness, '{VeryRough | Rough | MediumRough | MediumSmooth | Smooth | VerySmooth}');
  Obj.AddField('Collector Thickness', FloatToStr(CollectorThickness), '{m}');
  Obj.AddField('Effectiveness for Perforations with Respect to Wind', FloatToStr(WindEffectiveness), '{dimensionless}');
  Obj.AddField('Discharge Coefficient for Openings with Respect to Buoyancy Driven Flow', FloatToStr(DischargeCoefficient), '{dimensionless}');
  for i := 0 to TranspiredSolarCollectorSurfaces.Count - 1 do
  begin
    Obj.AddField('Surface ' + IntToStr(i + 1) + ' Name', TranspiredSolarCollectorSurfaces[i]);
  end;
  //boundary conditions model
  Obj := IDF.AddObject('SurfaceProperty:OtherSideConditionsModel');
  Obj.AddField('Name', 'UTSC_BCModel');
  Obj.AddField('Type of Modeling', 'GapConvectionRadiation');
end;

{ T_EP_DesiccantDehumidifier }
constructor T_EP_DesiccantDehumidifier.Create;
begin
  inherited;
  Name := 'Desiccant Dehumidifier 1';
  ComponentType := 'Dehumidifier:Desiccant:NoFans';
  ControlType := 'Passive';
  DemandControlType := 'Passive';
end;

procedure T_EP_DesiccantDehumidifier.Finalize;
begin
  inherited;
end;

procedure T_EP_DesiccantDehumidifier.SetSystem(SystemParameter: T_EP_System);
begin
  inherited;
  if Assigned(SystemParameter) then
  begin
    SystemValue := SystemParameter;

    Name := System.Name + ' Desiccant Dehumidifier';
  end;
end;

procedure T_EP_DesiccantDehumidifier.ToIDF;
var
  Fan: T_EP_Fan;
  Obj: TEnergyPlusObject;
begin
  inherited;
  Obj := IDF.AddObject('Dehumidifier:Desiccant:NoFans');
  Obj.AddField('Name', Name);
  Obj.AddField('Availability Schedule Name', 'ALWAYS_ON');
  Obj.AddField('Process Air Inlet Node Name', SupplyInletNode);
  Obj.AddField('Process Air Outlet Node Name', SupplyOutletNode);
  Obj.AddField('Regeneration Air Inlet Node Name', Name + ' Regen Coil Outlet Node');
  Obj.AddField('Regeneration Fan Inlet Node Name', Name + ' Regeneration Fan Inlet Node Name');
  Obj.AddField('Control Type', 'LeavingMaximumHumidityRatioSetpoint');
  Obj.AddField('Leaving Maximum Humidity Ratio Setpoint', '0.007', '{kg-H2O/kg-air}');
  Obj.AddField('Nominal Process Air Flow Rate', '1.0', '{m3/s}');
  Obj.AddField('Nominal Process Air Velocity', '3.556', '{m/s}');
  Obj.AddField('Rotor Power', '10', '{W}');
  Obj.AddField('Regeneration Coil Object Type', 'Coil:Heating:Gas');
  Obj.AddField('Regeneration Coil Name', Name + ' Regen Coil');
  Obj.AddField('Regeneration Fan Object Type', 'Fan:VariableVolume');
  Obj.AddField('Regeneration Fan Name', Name + ' Regen Fan');
  Obj.AddField('Performance Model Type', 'Default', '{DEFAULT | USER CURVES}');

  Obj := IDF.AddObject('OutdoorAir:NodeList'); // Note:  It's okay to have multiple instances of this object in the IDF
  Obj.AddField('Node or NodeList Name 1', Name + ' Regeneration Fan Inlet Node Name');

  // Coil := .Create;

  Obj := IDF.AddObject('Coil:Heating:Gas');
  Obj.AddField('Name', Name + ' Regen Coil');
  Obj.AddField('Availability Schedule Name', 'ALWAYS_ON');
  Obj.AddField('Efficiency', '0.8', '{}');
  Obj.AddField('Nominal Capacity', '100000', '{W}');
  Obj.AddField('Air Inlet Node Name', Name + ' Regen Coil Inlet Node');
  Obj.AddField('Air Outlet Node Name', Name + ' Regen Coil Outlet Node');

  Fan := T_EP_Fan.Create;
  Fan.Typ := 'VARIABLE';
  Fan.Name := Name + '_Regen Fan';
  Fan.PressureDrop := 600;
  Fan.SupplyInletNode := Name + ' Regeneration Fan Inlet Node Name';
  Fan.SupplyOutletNode := Name + ' Regen Coil Inlet Node'; // be nicer to fix node-to-node naming here
  Fan.ToIDF;

  // might also need Set Point Manager:Outside Air Pretreat

end;

{ T_EP_HeatRecoveryAirToAir }

constructor T_EP_HeatRecoveryAirToAir.Create;
begin
  inherited;
  AirFlowRate := 1.0;
  SensEff := 0.5;
  LatEff := 0.5;
  ParaPower := 0.0;
  EconBypass := true;
  AvailSch := 'NotSet';
  SetPtMgrName := '';
  HxType := 'Plate';
  FrostCtrlType := 'None';
  ThresholdTemp := 1.7;
  InitialDefrostTime := 0.083;
  RateDefrostTimeIncrease := 0.012;
  Name := 'Outside Air Heat Recovery '; // ksb: this will get replaced when system is set
  ComponentType := 'HeatExchanger:AirToAir:SensibleAndLatent';
  // ksb: I am not using these for oa system
  ControlType := 'Passive';
  DemandControlType := 'Passive';
end;

procedure T_EP_HeatRecoveryAirToAir.Finalize;
begin
  inherited;
end;

procedure T_EP_HeatRecoveryAirToAir.SetSystem(SystemParameter: T_EP_System);
begin
  inherited;
  if Assigned(SystemParameter) then
  begin
    SystemValue := SystemParameter;
    Name := System.Name + 'Outside Air Heat Recovery';
  end;
end;

procedure T_EP_HeatRecoveryAirToAir.ToIDF;
var
  Obj: TEnergyPlusObject;
begin
  inherited;
  // can add parameter for effectiveness
  Obj := IDF.AddObject('HeatExchanger:AirToAir:SensibleAndLatent');
  Obj.AddField('Name', Name);
  if not SameText(AvailSch, 'NotSet') then
    Obj.AddField('Availability Schedule Name', AvailSch)
  else
    Obj.AddField('Availability Schedule Name', 'ALWAYS_ON');
  if AirFlowRate > 0.0 then
    Obj.AddField('Nominal Supply Air Flow Rate', FloatToStr(AirFlowRate), '{m3/s}')
  else
    Obj.AddField('Nominal Supply Air Flow Rate', 'AUTOSIZE', '{m3/s}');
  Obj.AddField('Sensible Effectiveness at 100% Heating Air Flow', FloatToStr(SensEff), '{}');
  Obj.AddField('Latent Effectiveness at 100% Heating Air Flow', FloatToStr(LatEff), '{}');
  Obj.AddField('Sensible Effectiveness at 75% Heating Air Flow', FloatToStr(SensEff), '{}');
  Obj.AddField('Latent Effectiveness at 75% Heating Air Flow', FloatToStr(LatEff), '{}');
  Obj.AddField('Sensible Effectiveness at 100% Cooling Air Flow', FloatToStr(SensEff), '{}');
  Obj.AddField('Latent Effectiveness at 100% Cooling Air Flow', FloatToStr(LatEff), '{}');
  Obj.AddField('Sensible Effectiveness at 75% Cooling Air Flow', FloatToStr(SensEff), '{}');
  Obj.AddField('Latent Effectiveness at 75% Cooling Air Flow', FloatToStr(LatEff), '{}');
  Obj.AddField('Supply Air Inlet Node Name', SupplyInletNode);
  Obj.AddField('Supply Air Outlet Node Name', SupplyOutletNode);
  Obj.AddField('Exhaust Air Inlet Node Name', ExhaustInletNode);
  Obj.AddField('Exhaust Air Outlet Node Name', ExhaustOutletNode);
  Obj.AddField('Nominal Electric Power', FloatToStr(ParaPower), '{W}');
  if AnsiContainsText(Name, 'OA Unit') then
    Obj.AddField('Supply Outlet Temperature Control', 'No', '{YES | NO}')
  else
    Obj.AddField('Supply Outlet Temperature Control', 'Yes', '{YES | NO}');
  Obj.AddField('Heat Exchanger Type', HxType, '{ Plate | Rotary }');
  Obj.AddField('Frost Control Type', FrostCtrlType, '{ None | ExhaustAirRecirculation | ExhaustOnly | MinimumExhaustTemperature }');
  Obj.AddField('Threshold Temperature', ThresholdTemp, '{C}');
  Obj.AddField('Initial Defrost Time Fraction', InitialDefrostTime, '{min/min}');
  Obj.AddField('Rate of Defrost Time Fraction Increase', RateDefrostTimeIncrease, '{min/min per deg C}');
  if EconBypass then
    Obj.AddField('Economizer Lockout', 'Yes','')
  else
    Obj.AddField('Economizer Lockout', 'No','');
end;

{ T_EP_Pump }

constructor T_EP_Pump.Create;
begin
  inherited;
  Name := 'Pump 1';
  ComponentType := 'Pump:ConstantSpeed';
  ControlType := 'Active';
  DemandControlType := 'Passive';
  Efficiency := 0.87;
  PressureDrop := 179352; // now considered too high. need to reset..
  RatedFlowRate := -9999.0;
  RatedPower    := -9999.0;
  PumpControlType := 'Intermittent';
end;

procedure T_EP_Pump.Finalize;
begin
  inherited;
end;

procedure T_EP_Pump.SetSystem(SystemParameter: T_EP_System);
begin
  inherited;
  if Assigned(SystemParameter) then
  begin
    SystemValue := SystemParameter;
    Name := System.Name + ' Pump';
    SupplyInletNode := System.Name + ' Supply Inlet Node';
  end;
end;

procedure T_EP_Pump.SetType(TypeParameter: string);
begin
  TypeValue := TypeParameter;
  if SameText(Typ, 'Constant') then
    ComponentType := 'Pump:ConstantSpeed'
  else if SameText(Typ, 'Variable') then
    ComponentType := 'Pump:VariableSpeed';
end;

procedure T_EP_Pump.ToIDF;
var
  Obj: TEnergyPlusObject;
begin
  inherited;
  if SameText(Typ,'Constant') then
  begin
    Obj := IDF.AddObject('Pump:ConstantSpeed');
    Obj.AddField('Name', Name);
    Obj.AddField('Inlet Node Name', SupplyInletNode);
    Obj.AddField('Outlet Node Name', SupplyOutletNode);
    if RatedFlowRate < 0.0 then
      Obj.AddField('Rated Flow Rate', 'AUTOSIZE', '{m3/s}')
    else
      Obj.AddField('Rated Flow Rate', FloatToStr(RatedFlowRate), '{m3/s}');
    Obj.AddField('Rated Pump Head', FloatToStr(PressureDrop), '{Pa}', '179352 Pa = 60 ft');
    if RatedPower < 0.0 then
      Obj.AddField('Rated Power Consumption', 'AUTOSIZE', '{W}')
    else
      Obj.AddField('Rated Power Consumption', RatedPower, '{W}');
    Obj.AddField('Motor Efficiency', FloatToStr(Efficiency), '{}');
    Obj.AddField('Fraction of Motor Inefficiencies to Fluid Stream', '0.0', '{}');
    Obj.AddField('Pump Control Type', PumpControlType, '{Continuous | Intermittent}');
    Obj.AddField('Pump Flow Rate Schedule Name', '');
    // control depends on loop type and application!
  end
  else if SameText(Typ, 'Variable') then
  begin
    Obj := IDF.AddObject('Pump:VariableSpeed');
    Obj.AddField('Name', Name);
    Obj.AddField('Inlet Node Name', SupplyInletNode);
    Obj.AddField('Outlet Node Name', StringReplace(SupplyOutletNode, 'Heat Recovery ', '', [rfReplaceAll]));
    if RatedFlowRate < 0.0 then
      Obj.AddField('Rated Flow Rate', 'AUTOSIZE', '{m3/s}')
    else
      Obj.AddField('Rated Flow Rate', FloatToStr(RatedFlowRate), '{m3/s}');
    Obj.AddField('Rated Pump Head', FloatToStr(PressureDrop), '{Pa}', '179352 Pa = 60 ft');
    if RatedPower < 0.0 then
      Obj.AddField('Rated Power Consumption', 'AUTOSIZE', '{W}')
    else
      Obj.AddField('Rated Power Consumption', RatedPower, '{W}');
    Obj.AddField('Motor Efficiency', FloatToStr(Efficiency), '{}');
    Obj.AddField('Fraction of Motor Inefficiencies to Fluid Stream', '0.0', '{}');
    if CurveCoeff1 <> -9999.0 then
      Obj.AddField('Coefficient 1 of the Part Load Performance Curve', CurveCoeff1)
    else
      Obj.AddField('Coefficient 1 of the Part Load Performance Curve', '0');
    if CurveCoeff2 <> -9999.0 then
      Obj.AddField('Coefficient 2 of the Part Load Performance Curve', CurveCoeff2)
    else
      Obj.AddField('Coefficient 2 of the Part Load Performance Curve', '1');
    if CurveCoeff3 <> -9999.0 then
      Obj.AddField('Coefficient 3 of the Part Load Performance Curve', CurveCoeff3)
    else
      Obj.AddField('Coefficient 3 of the Part Load Performance Curve', '0');
    if CurveCoeff4 <> -9999.0 then
      Obj.AddField('Coefficient 4 of the Part Load Performance Curve', CurveCoeff4)
    else
      Obj.AddField('Coefficient 4 of the Part Load Performance Curve', '0');
    Obj.AddField('Minimum Flow Rate', '0.0', '{m3/s}');
    Obj.AddField('Pump Control Type', 'Intermittent', '{Continuous | Intermittent}');
    Obj.AddField('Pump Flow Rate Schedule Name', '');
  end;
end;

{ T_EP_Chiller }

constructor T_EP_Chiller.Create;
begin
  inherited;
  ComponentType := 'Chiller:ConstantCOP';
  ControlType := 'Active';
  DemandControlType := 'Passive';
  Capacity := -9999.0;
  FlowMode := 'NotModulated';
  if CreateChillerCondenserLoop then
    HeatRejectionLoop := T_EP_CondenserSystem.Create;
end;

procedure T_EP_Chiller.SetSystem(SystemParameter: T_EP_System);
begin
  inherited;
  if Assigned(SystemParameter) then
  begin
    SystemValue := SystemParameter;
    Name := System.Name + ' Chiller';
    DemandInletNode := Name + ' Water Inlet Node';
    DemandOutletNode := Name + ' Water Outlet Node';
  end;
end;

procedure T_EP_Chiller.SetHeatRejection(HeatRejectionType: string);
var
  Component: THVACComponent;
begin
  if SameText(HeatRejectionType, 'AirCooled') then
  begin
    HeatRejectionValue := 'AirCooled';
    DemandInletNode := Name + '_CondenserOAInlet';
    DemandOutletNode := Name + '_CondenserOutlet';
  end
  else if SameText(HeatRejectionType, 'EvaporativelyCooled') then
  begin
    HeatRejectionValue := 'EvaporativelyCooled';
    DemandInletNode := Name + '_CondenserOAInlet';
    DemandOutletNode := Name + '_CondenserOutlet';
  end
  else if (SameText(HeatRejectionType, 'WaterCooledSingleSpeedTower') or
    SameText(HeatRejectionType, 'WaterCooledTwoSpeedTower') or
    SameText(HeatRejectionType, 'WaterCooledVariableSpeedTower')) then
  begin
    HeatRejectionValue := 'WaterCooled';
    DemandControlType := 'Active';
    if not AnsiContainsText(Name, 'Heat Recovery') then
    begin
      HeatRejectionLoop.Name := Name + ' TowerSys';
      HeatRejectionLoop.SystemType := cSystemTypeCondTower;
      HeatRejectionLoop.AddDemandComponent(Self);
      //add pump
      Component := T_EP_Pump.Create;
      if UserDefCondPump then
      begin
        T_EP_Pump(Component).Typ := HeatRejectionLoop.CondLoopPumpType;
        T_EP_Pump(Component).PressureDrop := HeatRejectionLoop.CondLoopPumpHead;
        T_EP_Pump(Component).Efficiency := HeatRejectionLoop.CondLoopPumpEfficiency;
        T_EP_Pump(Component).RatedFlowRate := HeatRejectionLoop.CondLoopPumpFlowRate;
        T_EP_Pump(Component).RatedPower := HeatRejectionLoop.CondLoopPumpPower;
        T_EP_Pump(Component).CurveCoeff1 := HeatRejectionLoop.CondLoopPumpCurveCoeff1;
        T_EP_Pump(Component).CurveCoeff2 := HeatRejectionLoop.CondLoopPumpCurveCoeff2;
        T_EP_Pump(Component).CurveCoeff3 := HeatRejectionLoop.CondLoopPumpCurveCoeff3;
        T_EP_Pump(Component).CurveCoeff4 := HeatRejectionLoop.CondLoopPumpCurveCoeff4;
        T_EP_Pump(Component).ControlType := HeatRejectionLoop.CondLoopPumpControlType;
      end
      else
      begin
        T_EP_Pump(Component).Typ := 'Constant';
        T_EP_Pump(Component).PressureDrop := 179352;
        T_EP_Pump(Component).Efficiency := 0.87;
      end;
      HeatRejectionLoop.AddSupplyComponent(Component);
      if UseWatersideEconomizer then
      begin
        Component := T_EP_WatersideEconomizer.Create;
        T_EP_WatersideEconomizer(Component).Name := System.Name + ' HX';
        T_EP_WatersideEconomizer(Component).DemandInletNode := T_EP_WatersideEconomizer(Component).Name + ' HX Inlet Node';
        T_EP_WatersideEconomizer(Component).DemandOutletNode := T_EP_WatersideEconomizer(Component).Name + ' HX Outlet Node';
        HeatRejectionLoop.AddDemandComponent(Component);
      end;
      Component := T_EP_CoolingTower.Create;
      if SameText(HeatRejectionType, 'WaterCooledSingleSpeedTower') then
        T_EP_CoolingTower(Component).Typ := 'SingleSpeed'
      else if SameText(HeatRejectionType, 'WaterCooledTwoSpeedTower') then
        T_EP_CoolingTower(Component).Typ := 'TwoSpeed'
      else if SameText(HeatRejectionType, 'WaterCooledVariableSpeedTower') then
        T_EP_CoolingTower(Component).Typ := 'VariableSpeed';
      THVACComponent(Component).ControlType := 'Active';
      HeatRejectionLoop.AddSupplyComponent(Component);
    end;
  end;
end;

procedure T_EP_Chiller.SetType(TypeParameter: string);
begin
  TypeValue := TypeParameter;
  if SameText(Typ, 'ConstantCOP') then
    ComponentType := 'Chiller:ConstantCOP'
  else if SameText(Typ, 'Electric') then
    ComponentType := 'Chiller:Electric'
  else if SameText(Typ, 'ElectricEIR') then
    ComponentType := 'Chiller:Electric:EIR'
  else if SameText(Typ, 'ElectricReformulatedEIR') then
    ComponentType := 'Chiller:Electric:ReformulatedEIR'
  else if SameText(Typ, 'HeatRecovery') then
    ComponentType := 'Chiller:Electric:EIR';
end;

procedure T_EP_Chiller.ToIDF;
var
  Obj: TEnergyPlusObject;
  ChillerPreProcMacro: TPreProcMacro;
  ChillerStringList: TStringList;
  ChillerString: string;
begin
  if AnsiContainsText(Name, 'Heat Recovery') then
  begin
    SupplyOutletNode := Name + ' Outlet Node';
    DemandInletNode := Name + ' Water Inlet Node';
    DemandOutletNode := Name + ' Water Outlet Node';
  end
  else if HasHeatRecoveryChiller then
  begin
    SupplyInletNode := System.Name + ' Pump-' + Name + 'Node';
  end;
  if SameText(ComponentType, 'Chiller:ConstantCOP') then
  begin
    IDF.AddComment(''); //intentional blank line
    IDF.AddComment('Chiller: ' + Name);
    Obj := IDF.AddObject('Chiller:ConstantCOP');
    Obj.AddField('Name', Name);
    if Capacity > 0 then
      Obj.AddField('Nominal Capacity', Capacity, '{W}')
    else
      Obj.AddField('Nominal Capacity', 'AUTOSIZE', '{W}');
    Obj.AddField('Nominal COP', FloatToStr(COP), '{}');
    Obj.AddField('Design Chilled Water Flow Rate', 'AUTOSIZE', '{m3/s}');
    if SameText(HeatRejection, 'AirCooled') then
      Obj.AddField('Design Condenser Water Flow Rate', '', '{m3/s}')
    else
      Obj.AddField('Design Condenser Water Flow Rate', 'AUTOSIZE', '{m3/s}');
    Obj.AddField('Chilled Water Inlet Node Name', SupplyInletNode);
    Obj.AddField('Chilled Water Outlet Node Name', SupplyOutletNode);
    Obj.AddField('Condenser Inlet Node Name', DemandInletNode);
    Obj.AddField('Condenser Outlet Node Name', DemandOutletNode);
    Obj.AddField('Condenser Type', HeatRejection, '{AirCooled | EvaporativelyCooled | WaterCooled}');
    Obj.AddField('Chiller Flow Mode', 'LeavingSetpointModulated');
    Obj.AddField('Sizing Factor', SizingFactor);
  end;
  if SameText(ComponentType, 'Chiller:Electric') then
  begin
    IDF.AddComment(''); //intentional blank line
    IDF.AddComment('Chiller: ' + Name);
    Obj := IDF.AddObject('Chiller:Electric');
    Obj.AddField('Name', Name);
    Obj.AddField('Condenser Type', HeatRejection, '{AirCooled | EvaporativelyCooled | WaterCooled}');
    if Capacity > 0 then
      Obj.AddField('Nominal Capacity', Capacity, '{W}')
    else
      Obj.AddField('Nominal Capacity', 'AUTOSIZE', '{W}');
    Obj.AddField('Nominal COP', COP, '{}');
    Obj.AddField('Chilled Water Inlet Node Name', SupplyInletNode);
    Obj.AddField('Chilled Water Outlet Node Name', SupplyOutletNode);
    Obj.AddField('Condenser Inlet Node Name', DemandInletNode);
    Obj.AddField('Condenser Outlet Node Name', DemandOutletNode);
    Obj.AddField('Minimum Part Load Ratio', '0.0');
    Obj.AddField('Maximum Part Load Ratio', '1.0');
    Obj.AddField('Optimum Part Load Ratio', '0.65');
    if SameText(HeatRejectionValue, 'AirCooled') or SameText(HeatRejectionValue, 'EvaporativelyCooled') then
      Obj.AddField('Design Condenser Inlet Temperature', '35.0', '{C}')
    else if SameText(HeatRejectionValue, 'WaterCooled') then
      Obj.AddField('Design Condenser Inlet Temperature', '29.4', '{C}');
    Obj.AddField('Temperature Rise Coefficient', '2.778');
    Obj.AddField('Design Chilled Water Outlet Temperature', OutletTemperature, '{C}');
    Obj.AddField('Design Chilled Water Flow Rate', 'AUTOSIZE', '{m3/s}');
    Obj.AddField('Design Condenser Water Flow Rate', 'AUTOSIZE', '{m3/s}');
    Obj.AddField('Coefficient 1 of Capacity Ratio Curve', '0.9949');
    Obj.AddField('Coefficient 2 of Capacity Ratio Curve', '-0.045954');
    Obj.AddField('Coefficient 3 of Capacity Ratio Curve', '-0.0013543');
    Obj.AddField('Coefficient 1 of Power Ratio Curve', '2.333');
    Obj.AddField('Coefficient 2 of Power Ratio Curve', '-1.975');
    Obj.AddField('Coefficient 3 of Power Ratio Curve', '0.6121');
    Obj.AddField('Coefficient 1 of Full Load Ratio Curve', '0.03303');
    Obj.AddField('Coefficient 2 of Full Load Ratio Curve', '0.6852');
    Obj.AddField('Coefficient 3 of Full Load Ratio Curve', '0.2818');
    Obj.AddField('Chilled Water Outlet Temperature Lower Limit', '5.0', '{C}');
    Obj.AddField('Chiller Flow Mode', FlowMode);
    Obj.AddField('Sizing Factor', SizingFactor);
    if SameText(HeatRejectionValue, 'AirCooled') or SameText(HeatRejectionValue, 'EvaporativelyCooled') then
    begin
      Obj := IDF.AddObject('OutdoorAir:Node');
      Obj.AddField('Name', DemandInletNode);
    end;
  end;
  if SameText(ComponentType, 'Chiller:Electric:EIR') then
  begin
    IDF.AddComment(''); //intentional blank line
    IDF.AddComment('Chiller: ' + Name);
    Obj := IDF.AddObject('Chiller:Electric:EIR');
    Obj.AddField('Name', Name);
    if Capacity > 0 then
      Obj.AddField('Reference Capacity', Capacity, '{W}')
    else
      Obj.AddField('Reference Capacity', 'AUTOSIZE', '{W}');
    Obj.AddField('Reference COP', COP, '{ }');
    Obj.AddField('Reference Leaving Chilled Water Temperature', OutletTemperature, '{C}');
    if SameText(HeatRejectionValue, 'AirCooled') or SameText(HeatRejectionValue, 'EvaporativelyCooled') then
      Obj.AddField('Reference Entering Condenser Fluid Temperature', '35.0', '{C}')
    else if SameText(HeatRejectionValue, 'WaterCooled') then
      Obj.AddField('Reference Entering Condenser Fluid Temperature', '29.4', '{C}');
    Obj.AddField('Reference Chilled Water Flow Rate', 'AUTOSIZE', '{m3/s}');
    Obj.AddField('Reference Condenser Water Flow Rate', 'AUTOSIZE' , '{m3/s}');
    Obj.AddField('Cooling Capacity Function of Temperature Curve Name', Name + ' ClgCapFuncTempCurve');
    Obj.AddField('Electric Input to Cooling Output Ratio Function of Temperature Curve Name', Name + ' EirFuncTempCurve');
    Obj.AddField('Electric Input to Cooling Output Ratio Function of Part Load Ratio Curve Name', Name + ' EirFuncPlrCurve');
    Obj.AddField('Minimum Part Load Ratio', '0.15');
    Obj.AddField('Maximum Part Load Ratio', '1.0');
    Obj.AddField('Optimum Part Load Ratio', OptimumPartLoadRatio);
    Obj.AddField('Minimum Unloading Ratio', MinimumUnloadingRatio);
    Obj.AddField('Chilled Water Inlet Node Name', SupplyInletNode);
    Obj.AddField('Chilled Water Outlet Node Name', SupplyOutletNode);
    Obj.AddField('Condenser Inlet Node Name', DemandInletNode);
    Obj.AddField('Condenser Outlet Node Name', DemandOutletNode);
    Obj.AddField('Condenser Type', HeatRejectionValue);
    Obj.AddField('Condenser Fan Power Ratio', '0.0', '{W/W}');
    Obj.AddField('Compressor Motor Efficiency', '');
    Obj.AddField('Leaving Chilled Water Lower Temperature Limit', '2.0', '{C}');
    Obj.AddField('Chiller Flow Mode', FlowMode);
    Obj.AddField('Design Heat Recovery Water Flow Rate', '0.0', '{m3/s}');
    Obj.AddField('Heat Recovery Inlet Node Name', '');
    Obj.AddField('Heat Recovery Outlet Node Name', '');
    Obj.AddField('Sizing Factor', SizingFactor);
    //grab curves from library
    try
      ChillerPreProcMacro := TPreProcMacro.Create('include/HPBChillers.imf');
      ChillerString := ChillerPreProcMacro.getDefinedText(DataSetKey + HeatRejectionValue);
      ChillerString := ReplaceRegExpr('#{ClgCapFuncTempCurve}', ChillerString, Name + ' ClgCapFuncTempCurve', False);
      ChillerString := ReplaceRegExpr('#{EirFuncTempCurve}', ChillerString, Name + ' EirFuncTempCurve', False);
      ChillerString := ReplaceRegExpr('#{EirFuncPlrCurve}', ChillerString, Name + ' EirFuncPlrCurve', False);
      //write curves to IDF
      ChillerString := ReplaceRegExpr(#$D#$A#$D#$A#$D#$A, ChillerString, '', False); //delete blank lines
      ChillerStringList := TStringList.Create;
      ChillerStringList.Add(ChillerString);
      IDF.AddStringList(ChillerStringList);
    finally
      ChillerPreProcMacro.Free;
    end;
    //add outdoor air node if air-cooled or evap-cooled
    if SameText(HeatRejectionValue, 'AirCooled') or SameText(HeatRejectionValue, 'EvaporativelyCooled') then
    begin
      Obj := IDF.AddObject('OutdoorAir:Node');
      Obj.AddField('Name', DemandInletNode);
    end;
  end;
  if SameText(ComponentType, 'Chiller:Electric:ReformulatedEIR') then
  begin
    IDF.AddComment(''); //intentional blank line
    IDF.AddComment('Chiller: ' + Name);
    Obj := IDF.AddObject('Chiller:Electric:ReformulatedEIR');
    Obj.AddField('Name', Name);
    if Capacity > 0 then
      Obj.AddField('Reference Capacity', Capacity, '{W}')
    else
      Obj.AddField('Reference Capacity', 'AUTOSIZE', '{W}');
    Obj.AddField('Reference COP', COP, '{ }');
    Obj.AddField('Reference Leaving Chilled Water Temperature', OutletTemperature, '{C}');
    if SameText(HeatRejectionValue, 'AirCooled') or SameText(HeatRejectionValue, 'EvaporativelyCooled') then
      Obj.AddField('Reference Leaving Condenser Fluid Temperature', '35.0', '{C}')
    else if SameText(HeatRejectionValue, 'WaterCooled') then
      Obj.AddField('Reference Leaving Condenser Fluid Temperature', '29.4', '{C}');
    Obj.AddField('Reference Chilled Water Flow Rate', 'AUTOSIZE', '{m3/s}');
    Obj.AddField('Reference Condenser Water Flow Rate', 'AUTOSIZE' , '{m3/s}');
    Obj.AddField('Cooling Capacity Function of Temperature Curve Name', Name + ' ClgCapFuncTempCurve');
    Obj.AddField('Electric Input to Cooling Output Ratio Function of Temperature Curve Name', Name + ' EirFuncTempCurve');
    Obj.AddField('Electric Input to Cooling Output Ratio Function of Part Load Ratio Curve Name', Name + ' EirFuncPlrCurve');
    Obj.AddField('Minimum Part Load Ratio', '0.15');
    Obj.AddField('Maximum Part Load Ratio', '1.0');
    Obj.AddField('Optimum Part Load Ratio', OptimumPartLoadRatio);
    Obj.AddField('Minimum Unloading Ratio', MinimumUnloadingRatio);
    Obj.AddField('Chilled Water Inlet Node Name', SupplyInletNode);
    Obj.AddField('Chilled Water Outlet Node Name', SupplyOutletNode);
    Obj.AddField('Condenser Inlet Node Name', DemandInletNode);
    Obj.AddField('Condenser Outlet Node Name', DemandOutletNode);
    Obj.AddField('Compressor Motor Efficiency', '1.0');
    Obj.AddField('Leaving Chilled Water Lower Temperature Limit', '2.0', '{C}');
    Obj.AddField('Chiller Flow Mode', FlowMode);
    Obj.AddField('Design Heat Recovery Water Flow Rate', '0.0', '{m3/s}');
    Obj.AddField('Heat Recovery Inlet Node Name', '');
    Obj.AddField('Heat Recovery Outlet Node Name', '');
    Obj.AddField('Sizing Factor', SizingFactor);
    //grab curves from library
    try
      ChillerPreProcMacro := TPreProcMacro.Create('include/HPBChillers.imf');
      ChillerString := ChillerPreProcMacro.getDefinedText(DataSetKey + HeatRejectionValue);
      ChillerString := ReplaceRegExpr('#{ClgCapFuncTempCurve}', ChillerString, Name + ' ClgCapFuncTempCurve', False);
      ChillerString := ReplaceRegExpr('#{EirFuncTempCurve}', ChillerString, Name + ' EirFuncTempCurve', False);
      ChillerString := ReplaceRegExpr('#{EirFuncPlrCurve}', ChillerString, Name + ' EirFuncPlrCurve', False);
      //write curves to IDF
      ChillerString := ReplaceRegExpr(#$D#$A#$D#$A#$D#$A, ChillerString, '', False); //delete blank lines
      ChillerStringList := TStringList.Create;
      ChillerStringList.Add(ChillerString);
      IDF.AddStringList(ChillerStringList);
    finally
      ChillerPreProcMacro.Free;
    end;
    //add outdoor air node if air-cooled or evap-cooled
    if SameText(HeatRejectionValue, 'AirCooled') or SameText(HeatRejectionValue, 'EvaporativelyCooled') then
    begin
      Obj := IDF.AddObject('OutdoorAir:Node');
      Obj.AddField('Name', DemandInletNode);
    end;
  end;
  //add setpoint manager for variable flow chillers
  if SameText(FlowMode, 'LeavingSetpointModulated') then
  begin
    Obj := IDF.AddObject('SetpointManager:Scheduled');
    Obj.AddField('Name', Name + ' Setpoint Manager');
    Obj.AddField('Control Variable', 'Temperature', '{Temperature | Others}');
    Obj.AddField('Schedule Name', 'CW-Loop-Temp-Schedule');
    Obj.AddField('Setpoint Node or NodeList Name', SupplyOutletNode);
  end;
  //add EMS code for heat recovery chiller if applicable
  if AnsiContainsText(Name, 'Heat Recovery') then
  begin
    //rejection power sensor
    Obj := IDF.AddObject('EnergyManagementSystem:Sensor');
    Obj.AddField('Name', 'Chiller_Rejection_Power');
    Obj.AddField('Output:Variable or Output:Meter Index Key Name', Name);
    Obj.AddField('Output:Variable or Output:Meter Name', 'Chiller Cond Heat Trans Rate');
    //heat recovery schedule actuator
    Obj := IDF.AddObject('EnergyManagementSystem:Actuator');
    Obj.AddField('Name', 'Heat_Recovery_Sch_Act');
    Obj.AddField('Actuated Component Unique Name', 'Heat_Recovery_Sch');
    Obj.AddField('Actuated Component Type', 'Schedule:Compact');
    Obj.AddField('Actuated Component Control Type', 'Schedule Value');
    //heat recovery schedule
    Obj := IDF.AddObject('Schedule:Compact');
    Obj.AddField('Name', 'Heat_Recovery_Sch');
    Obj.AddField('Schedule Type Limits Name', 'On/Off');
    Obj.AddField('Field 1', 'Through: 12/31');
    Obj.AddField('Field 2', 'For: AllDays');
    Obj.AddField('Field 3', 'Until: 24:00, 1.0');
    //global variables
    Obj := IDF.AddObject('EnergyManagementSystem:GlobalVariable');
    Obj.AddField('Name', 'Heat_Recovery_Timestep');
    Obj := IDF.AddObject('EnergyManagementSystem:GlobalVariable');
    Obj.AddField('Name', 'Heat_Recovery_Total');
    //output variables
    Obj := IDF.AddObject('EnergyManagementSystem:OutputVariable');
    Obj.AddField('Name', 'Heat_Recovery_Timestep_Output [J]');
    Obj.AddField('EMS Variable Name', 'Heat_Recovery_Timestep');
    Obj.AddField('Type of Data in Variable', 'Summed');
    Obj.AddField('Update Frequency', 'SystemTimeStep');
    Obj.AddField('Units', 'J');
    Obj := IDF.AddObject('EnergyManagementSystem:OutputVariable');
    Obj.AddField('Name', 'Heat_Recovery_Total_Output [J]');
    Obj.AddField('EMS Variable Name', 'Heat_Recovery_Total');
    Obj.AddField('Type of Data in Variable', 'Summed');
    Obj.AddField('Update Frequency', 'SystemTimeStep');
    Obj.AddField('Units', 'J');
    //program calling managers
    Obj := IDF.AddObject('EnergyManagementSystem:ProgramCallingManager');
    Obj.AddField('Name', 'Initialize_Heat_Recovery_Total_Manager');
    Obj.AddField('EnergyPlus Model Calling Point', 'BeginNewEnvironment');
    Obj.AddField('Program 1 Name', 'Initialize_Heat_Recovery_Total');
    Obj := IDF.AddObject('EnergyManagementSystem:ProgramCallingManager');
    Obj.AddField('Name', 'Heat_Recovery_Schedule_Manager');
    Obj.AddField('EnergyPlus Model Calling Point', 'BeginTimestepBeforePredictor');
    Obj.AddField('Program 1 Name', 'Heat_Recovery_Schedule');
    //programs
    Obj := IDF.AddObject('EnergyManagementSystem:Program');
    Obj.AddField('Name', 'Initialize_Heat_Recovery_Total');
    Obj.AddField('Program Line 1', 'SET Heat_Recovery_Total = 0');
    Obj := IDF.AddObject('EnergyManagementSystem:Program');
    Obj.AddField('Name', 'Heat_Recovery_Schedule');
    Obj.AddField('Program Line 1', 'IF Chiller_Rejection_Power > Boiler_Power');
    Obj.AddField('Program Line 2', '  SET Heat_Recovery_Rate = Boiler_Power');
    Obj.AddField('Program Line 3', 'ELSE');
    Obj.AddField('Program Line 4', '  SET Heat_Recovery_Rate = Chiller_Rejection_Power');
    Obj.AddField('Program Line 5', 'ENDIF');
    Obj.AddField('Program Line 6', 'SET Heat_Recovery_Timestep = Heat_Recovery_Rate');
    Obj.AddField('Program Line 7', 'SET Heat_Recovery_Total = Heat_Recovery_Total + Heat_Recovery_Timestep');
    Obj.AddField('Program Line 8', 'SET Heat_Recovery_Sch_Act = -(Heat_Recovery_Rate / 1000000000) * (Boiler_Gas_Rate / Boiler_Power)');
    //exterior fuel equipment
    Obj := IDF.AddObject('Exterior:FuelEquipment');
    Obj.AddField('Name', 'Outside Gas Equip');
    Obj.AddField('Fuel Use Type', 'NaturalGas');
    Obj.AddField('Schedule Name', 'Heat_Recovery_Sch');
    Obj.AddField('Design Level', '1000000000');
  end;
end;

procedure T_EP_Chiller.Finalize;
begin
  inherited;
end;

{ T_EP_HeatPumpWaterToWater }

constructor T_EP_HeatPumpWaterToWater.Create;
begin
  inherited;
  TypeValue := 'COOLING';
  ComponentType := 'HeatPump:WaterToWater:EquationFit:Cooling';
  ControlType := 'Passive';
  DemandControlType := 'Passive';
end;

procedure T_EP_HeatPumpWaterToWater.Finalize;
begin
  inherited;
end;

procedure T_EP_HeatPumpWaterToWater.SetSystem(SystemParameter: T_EP_System);
begin
  inherited;
  if Assigned(SystemParameter) then
  begin
    SystemValue := SystemParameter;
    Name := System.Name + ' Water-To-Water Heat Pump ' + TypeValue;
    DemandInletNode := Name + ' Water Inlet Node';
    DemandOutletNode := Name + ' Water Outlet Node';
  end;
end;

procedure T_EP_HeatPumpWaterToWater.SetType(TypeParameter: string);
begin
  TypeValue := TypeParameter;
  if TypeParameter = 'COOLING' then
    ComponentType := 'HeatPump:WaterToWater:EquationFit:Cooling'
  else if TypeParameter = 'HEATING' then
    ComponentType := 'HeatPump:WaterToWater:ParameterEstimation:Heating';
end;

procedure T_EP_HeatPumpWaterToWater.ToIDF;
var
  Obj: TEnergyPlusObject;
begin
  inherited;
  // Nothing autosizes!!
  if SameText(Typ,'Cooling') then
  begin
    Obj := IDF.AddObject('HeatPump:WaterToWater:EquationFit:Cooling');
    Obj.AddField('Name', Name);
    Obj.AddField('Source Side Inlet Node Name', SupplyInletNode);
    Obj.AddField('Source Side Outlet Node Name', SupplyOutletNode);
    Obj.AddField('Load Side Inlet Node Name', DemandInletNode);
    Obj.AddField('Load Side Outlet Node Name', DemandOutletNode);
    Obj.AddField('Rated Load Side Flow Rate', '1.89E-03', '{m3/s}');
    Obj.AddField('Rated Source Side Flow Rate', '1.89E-03', '{m3/s}');
    Obj.AddField('Rated Cooling Capacity', '39890.91', '{W}');
    Obj.AddField('Rated Cooling Power Consumption', '4790.0', '{W}');
    Obj.AddField('Cooling Capacity Coefficient 1', '-1.52030596');
    Obj.AddField('Cooling Capacity Coefficient 2', '3.46625667');
    Obj.AddField('Cooling Capacity Coefficient 3', '-1.32267797');
    Obj.AddField('Cooling Capacity Coefficient 4', '0.09395678');
    Obj.AddField('Cooling Capacity Coefficient 5', '0.038975504');
    Obj.AddField('Cooling Power Consumption Coefficient 1', '-8.59564386');
    Obj.AddField('Cooling Power Consumption Coefficient 2', '0.96265085');
    Obj.AddField('Cooling Power Consumption Coefficient 3', '8.69489229');
    Obj.AddField('Cooling Power Consumption Coefficient 4', '0.02501669');
    Obj.AddField('Cooling Power Consumption Coefficient 5', '-0.20132665');
    if SameText(EPSettings.VersionOfEnergyPlus , '8.0') then
      Obj.AddField('Cycle Time', '0.1', '{hr}');
  end

  else if SameText(Typ, 'Heating') then
  begin
    // *******************
    // NOTE:  these are not the correct parameters yet!!!
    // *******************

    Obj := IDF.AddObject('HeatPump:WaterToWater:EquationFit:Heating');
    Obj.AddField('Name', Name);
    Obj.AddField('Source Side Inlet Node Name', SupplyInletNode);
    Obj.AddField('Source Side Outlet Node Name', SupplyOutletNode);
    Obj.AddField('Load Side Inlet Node Name', DemandInletNode);
    Obj.AddField('Load Side Outlet Node Name', DemandOutletNode);
    Obj.AddField('Rated Load Side Flow Rate', '1.89E-03', '{m3/s}');
    Obj.AddField('Rated Source Side Flow Rate', '1.89E-03', '{m3/s}');
    Obj.AddField('Rated Heating Capacity', '39890.91', '{W}');
    Obj.AddField('Rated Heating Power Consumption', '4790.0', '{W}');
    Obj.AddField('Heating Capacity Coefficient 1', '-1.52030596');
    Obj.AddField('Heating Capacity Coefficient 2', '3.46625667');
    Obj.AddField('Heating Capacity Coefficient 3', '-1.32267797');
    Obj.AddField('Heating Capacity Coefficient 4', '0.09395678');
    Obj.AddField('Heating Capacity Coefficient 5', '0.038975504');
    Obj.AddField('Heating Power Consumption Coefficient 1', '-8.59564386');
    Obj.AddField('Heating Power Consumption Coefficient 2', '0.96265085');
    Obj.AddField('Heating Power Consumption Coefficient 3', '8.69489229');
    Obj.AddField('Heating Power Consumption Coefficient 4', '0.02501669');
    Obj.AddField('Heating Power Consumption Coefficient 5', '-0.20132665');
    if SameText(EPSettings.VersionOfEnergyPlus , '8.0') then
      Obj.AddField('Cycle Time', '0.1', '{hr}');
  end;

end;

{ T_EP_WaterHeater }

constructor T_EP_WaterHeater.Create;
begin
  inherited;
  ComponentType := 'WaterHeater:Mixed';
  ControlType := 'Passive';      // BG changed from Active to passive (Lesley's finding)
  DemandControlType := 'Active';
  Capacity := 0.0; //watts of heating
  Height := 0.0;
  SourceSideOnSupply := true;
  HPWHZone := '';
  COP := 2.8;
end;

procedure T_EP_WaterHeater.SetSystem(SystemParameter: T_EP_System);
begin
  inherited;
  if Assigned(SystemParameter) then
  begin
    SystemValue := SystemParameter;
    Name := System.Name + ' Water Heater'; // would be nice to have indication of Type in name
  end;
end;

procedure T_EP_WaterHeater.SetDemandSystem(SystemParameter: T_EP_System);
begin
  if Assigned(SystemParameter) then
  begin
    DemandSystemValue := SystemParameter;
    DemandInletNode := SystemParameter.Name + ' Water Inlet Node';
    DemandOutletNode := SystemParameter.Name + ' Water Outlet Node';
  end;
end;

procedure T_EP_WaterHeater.SetSourceSideSupplySystem(SystemParameter: T_EP_System);
begin
  if Assigned(SystemParameter) then
  begin
    SourceSideSystem := SystemParameter;
    SourceSideInletNode := SystemParameter.Name + ' Water Inlet Node';
    SourceSideOutletNode := SystemParameter.Name + ' Water Outlet Node';
  end;
end;

procedure T_EP_WaterHeater.SetUseSideSupplySystem(SystemParameter: T_EP_System);
begin
  if Assigned(SystemParameter) then
  begin
    UseSideSystem := SystemParameter;
    UseSideInletNode := SystemParameter.Name + ' Water Inlet Node';
    UseSideOutletNode := SystemParameter.Name + ' Water Outlet Node';
  end;
end;

procedure T_EP_WaterHeater.SetWaterHeaterSizes;
begin
  // use xml input if non zero
  if capacity = 0.0 then
  begin
    capacity := T_EP_LiquidSystem(System).SWHHeatingCapacity;
  end;
  if Volume = 0.0 then
  begin
    Volume := T_EP_LiquidSystem(System).SWHStorage;
  end;
  if Height = 0.0 then
  begin
    Height :=  Power(2.0, (2.0/3.0))* Power(Volume, (2.0/3.0))* Power(HeightAspectRatio, (2.0/3.0) ) / Power(PI,(2.0/3.0)) ;
  end;
end;

procedure T_EP_WaterHeater.ToIDF;
var
  htr1Height: double;
  useInHeight: double;
  UseOutHeight: double;
  SourceInHeight: double;
  SourceOutHeight : double; 
  i: integer;
  Obj: TEnergyPlusObject;
begin
  inherited;
  SetWaterHeaterSizes;
  // Fuel can be "Electricity" or "NaturalGas"
  if Typ = 'STORAGE TANK' then
  begin
    Obj := IDF.AddObject('WaterHeater:Mixed');
    Obj.AddField('Name', Name);
    Obj.AddField('Tank Volume', FloatToStr(Volume), '{m3}');
    Obj.AddField('Setpoint Temperature Schedule Name', Name + ' Setpoint Temperature Schedule Name');
    Obj.AddField('Deadband Temperature Difference', '2.0', '{deltaC}');
    Obj.AddField('Maximum Temperature Limit', '82.2222', '{C}');
    Obj.AddField('Heater Control Type', 'Cycle', '{Cycle | Modulate}');
    Obj.AddField('Heater Maximum Capacity', FloatToStr(Capacity), '{W}');
    Obj.AddField('Heater Minimum Capacity', '', '{W}');
    Obj.AddField('Heater Ignition Minimum Flow Rate', '', '{m3/s}');
    Obj.AddField('Heater Ignition Delay', '', '{s}');
    Obj.AddField('Heater Fuel Type', Fuel);
    Obj.AddField('Heater Thermal Efficiency', FloatToStr(Efficiency), '{}');
    Obj.AddField('Part Load Factor Curve Name', '');
    Obj.AddField('Off Cycle Parasitic Fuel Consumption Rate', '20', '{W}');
    Obj.AddField('Off Cycle Parasitic Fuel Type', Fuel);
    Obj.AddField('Off Cycle Parasitic Heat Fraction To Tank', FloatToStr(Efficiency), '{}');
    Obj.AddField('On Cycle Parasitic Fuel Consumption Rate', '', '{W}');
    Obj.AddField('On Cycle Parasitic Fuel Type', Fuel);
    Obj.AddField('On Cycle Parasitic Heat Fraction To Tank', '', '{}');
    Obj.AddField('Ambient Temperature Indicator', 'SCHEDULE', '{Schedule | Zone | Outdoors}');
    Obj.AddField('Ambient Temperature Schedule Name', Name + ' Ambient Temperature Schedule Name');
    Obj.AddField('Ambient Temperature Zone Name', '');
    Obj.AddField('Ambient Temperature Outdoor Air Node Name', '');
    Obj.AddField('Off Cycle Loss Coefficient to Ambient Temperature', '6.0', '{W/K}');
    Obj.AddField('Off Cycle Loss Fraction to Zone', '');
    Obj.AddField('On Cycle Loss Coefficient to Ambient Temperature', '6.0', '{W/K}');
    Obj.AddField('On Cycle Loss Fraction to Zone', '');
    Obj.AddField('Peak Use Flow Rate', '', '{m3/s}');
    Obj.AddField('Use Flow Rate Fraction Schedule Name', '');
    Obj.AddField('Cold Water Supply Temperature Schedule Name', '');
    Obj.AddField('Use Side Inlet Node Name', SupplyInletNode);
    Obj.AddField('Use Side Outlet Node Name', SupplyOutletNode);
    Obj.AddField('Use Side Effectiveness', '1.0');
    Obj.AddField('Source Side Inlet Node Name', DemandInletNode);
    Obj.AddField('Source Side Outlet Node Name', DemandOutletNode);
    Obj.AddField('Source Side Effectiveness', '1.0');
    obj.AddField('Use Side Design Flow Rate', 'AUTOSIZE');
    obj.AddField('Source Side Design Flow Rate' , 'AUTOSIZE');
    Obj.AddField('Indirect Water Heater Recovery Time', '1.5');
  end
  else if Typ = 'Indirect' then
  begin
    Obj := IDF.AddObject('WaterHeater:Mixed');
    Obj.AddField('Name', Name);
    Obj.AddField('Tank Volume', FloatToStr(Volume), '{m3}');
    Obj.AddField('Setpoint Temperature Schedule Name', Name + ' Setpoint Temperature Schedule Name');
    Obj.AddField('Deadband Temperature Difference', '2.0', '{deltaC}');
    Obj.AddField('Maximum Temperature Limit', '82.2222', '{C}');
    Obj.AddField('Heater Control Type', 'Cycle', '{Cycle | Modulate}');
    Obj.AddField('Heater Maximum Capacity', '0.0', '{W}');
    Obj.AddField('Heater Minimum Capacity', '', '{W}');
    Obj.AddField('Heater Ignition Minimum Flow Rate', '', '{m3/s}');
    Obj.AddField('Heater Ignition Delay', '', '{s}');
    Obj.AddField('Heater Fuel Type', Fuel);
    Obj.AddField('Heater Thermal Efficiency', FloatToStr(Efficiency), '{}');
    Obj.AddField('Part Load Factor Curve Name', '');
    Obj.AddField('Off Cycle Parasitic Fuel Consumption Rate', '20', '{W}');
    Obj.AddField('Off Cycle Parasitic Fuel Type', Fuel);
    Obj.AddField('Off Cycle Parasitic Heat Fraction To Tank', FloatToStr(Efficiency), '{}');
    Obj.AddField('On Cycle Parasitic Fuel Consumption Rate', '', '{W}');
    Obj.AddField('On Cycle Parasitic Fuel Type', Fuel);
    Obj.AddField('On Cycle Parasitic Heat Fraction To Tank', '', '{}');
    Obj.AddField('Ambient Temperature Indicator', 'Schedule', '{Schedule | Zone | Outdoors}');
    Obj.AddField('Ambient Temperature Schedule Name', Name + ' Ambient Temperature Schedule Name');
    Obj.AddField('Ambient Temperature Zone Name', '');
    Obj.AddField('Ambient Temperature Outdoor Air Node Name', '');
    Obj.AddField('Off Cycle Loss Coefficient to Ambient Temperature', '6.0', '{W/K}');
    Obj.AddField('Off Cycle Loss Fraction to Zone', '');
    Obj.AddField('On Cycle Loss Coefficient to Ambient Temperature', '6.0', '{W/K}');
    Obj.AddField('On Cycle Loss Fraction to Zone', '');
    Obj.AddField('Peak Use Flow Rate', '', '{m3/s}');
    Obj.AddField('Use Flow Rate Fraction Schedule Name', '');
    Obj.AddField('Cold Water Supply Temperature Schedule Name', '');
    Obj.AddField('Use Side Inlet Node Name', SupplyInletNode);
    Obj.AddField('Use Side Outlet Node Name', SupplyOutletNode);
    Obj.AddField('Use Side Effectiveness', '1.0');
    Obj.AddField('Source Side Inlet Node Name', DemandInletNode);
    Obj.AddField('Source Side Outlet Node Name', DemandOutletNode);
    Obj.AddField('Source Side Effectiveness', '1.0');
    obj.AddField('Use Side Design Flow Rate', 'AUTOSIZE');
    obj.AddField('Source Side Design Flow Rate' , 'AUTOSIZE');
    Obj.AddField('Indirect Water Heater Recovery Time', '1.5');
  end
  else if Typ = 'HEATRECOVERYELECTRICFOLLOW' then
  begin
    Obj := IDF.AddObject('WaterHeater:Mixed');
    Obj.AddField('Name', Name);
    Obj.AddField('Tank Volume', FloatToStr(Volume), '{m3}');
    Obj.AddField('Setpoint Temperature Schedule Name', Name + ' Setpoint Temperature Schedule Name');
    Obj.AddField('Deadband Temperature Difference', '2.0', '{deltaC}');
    Obj.AddField('Maximum Temperature Limit', '98.00', '{C}');
    Obj.AddField('Heater Control Type', 'Cycle', '{Cycle | Modulate}');
    Obj.AddField('Heater Maximum Capacity', FloatToStr(Capacity), '{W}');
    Obj.AddField('Heater Minimum Capacity', '', '{W}');
    Obj.AddField('Heater Ignition Minimum Flow Rate', '', '{m3/s}');
    Obj.AddField('Heater Ignition Delay', '', '{s}');
    Obj.AddField('Heater Fuel Type', Fuel);
    Obj.AddField('Heater Thermal Efficiency', FloatToStr(Efficiency), '{}');
    Obj.AddField('Part Load Factor Curve Name', '');
    Obj.AddField('Off Cycle Parasitic Fuel Consumption Rate', '20', '{W}');
    Obj.AddField('Off Cycle Parasitic Fuel Type', Fuel);
    Obj.AddField('Off Cycle Parasitic Heat Fraction To Tank', FloatToStr(Efficiency), '{}');
    Obj.AddField('On Cycle Parasitic Fuel Consumption Rate', '', '{W}');
    Obj.AddField('On Cycle Parasitic Fuel Type', Fuel);
    Obj.AddField('On Cycle Parasitic Heat Fraction To Tank', '', '{}');
    Obj.AddField('Ambient Temperature Indicator', 'Schedule', '{Schedule | Zone | Outdoors}');
    Obj.AddField('Ambient Temperature Schedule Name', Name + ' Ambient Temperature Schedule Name');
    Obj.AddField('Ambient Temperature Zone Name', '');
    Obj.AddField('Ambient Temperature Outdoor Air Node Name', '');
    Obj.AddField('Off Cycle Loss Coefficient to Ambient Temperature', '6.0', '{W/K}');
    Obj.AddField('Off Cycle Loss Fraction to Zone', '');
    Obj.AddField('On Cycle Loss Coefficient to Ambient Temperature', '6.0', '{W/K}');
    Obj.AddField('On Cycle Loss Fraction to Zone', '');
    Obj.AddField('Peak Use Flow Rate', '', '{m3/s}');
    Obj.AddField('Use Flow Rate Fraction Schedule Name', '');
    Obj.AddField('Cold Water Supply Temperature Schedule Name', '');
    Obj.AddField('Use Side Inlet Node Name', UseSideInletNode);
    Obj.AddField('Use Side Outlet Node Name', UseSideOutletNode);
    Obj.AddField('Use Side Effectiveness', '1.0');
    Obj.AddField('Source Side Inlet Node Name', SourceSideInletNode);
    Obj.AddField('Source Side Outlet Node Name', SourceSideOutletNode);
    Obj.AddField('Source Side Effectiveness', '1.0');
    obj.AddField('Use Side Design Flow Rate', 'AUTOSIZE');
    obj.AddField('Source Side Design Flow Rate' , 'AUTOSIZE');
    Obj.AddField('Indirect Water Heater Recovery Time', '1.5');
  end
  else if Typ = 'HEATRECOVERYELECTRICFOLLOWSTRATIFIED' then
  begin
    Obj := IDF.AddObject('WaterHeater:Stratified');
    Obj.AddField('Name', Name);
    obj.AddField('End-Use Subcategory', 'tank backup');
    Obj.AddField('Tank Volume', Volume, '{m3}');
    obj.AddField('Tank Height', Height);
    Obj.AddField('Tank Shape', 'VerticalCylinder');
    Obj.AddField('Tank Perimeter', '');
    Obj.AddField('Maximum Temperature Limit', '98.00', '{C}');
    obj.AddField('Heater Priority Control',  'MasterSlave');
    obj.AddField('Heater 1 Setpoint Temperature Schedule Name',Name + ' Setpoint Temperature Schedule Name' );
    obj.AddField('Heater 1 Deadband Temperature Difference', 10.0);
    obj.AddField('Heater 1 Capacity', Capacity );
    htr1Height := 0.9 * Height ;
    obj.AddField('Heater 1 Height', htr1Height );
    obj.AddField('Heater 2 Setpoint Temperature Schedule Name', Name + ' Setpoint Temperature Schedule Name');
    obj.AddField('Heater 2 Deadband Temperature Difference', 5.0);
    obj.AddField('Heater 2 Capacity', 0.0 );
    obj.AddField('Heater 2 Height', 0.0);
    Obj.AddField('Heater Fuel Type', Fuel);
    Obj.AddField('Heater Thermal Efficiency', Efficiency, '{}');
    Obj.AddField('Off Cycle Parasitic Fuel Consumption Rate', '0.0', '{W}');
    Obj.AddField('Off Cycle Parasitic Fuel Type', Fuel);
    Obj.AddField('Off Cycle Parasitic Heat Fraction To Tank', Efficiency, '{}');
    obj.AddField('Off Cycle Parasitic Height', 0.5 );
    Obj.AddField('On Cycle Parasitic Fuel Consumption Rate', '', '{W}');
    Obj.AddField('On Cycle Parasitic Fuel Type', Fuel);
    Obj.AddField('On Cycle Parasitic Heat Fraction To Tank', '', '{}');
    obj.AddField('On Cycle Parasitic Height', 0.5 );
    Obj.AddField('Ambient Temperature Indicator', 'Schedule', '{Schedule | Zone | Outdoors}');
    Obj.AddField('Ambient Temperature Schedule Name', Name + ' Ambient Temperature Schedule Name');
    Obj.AddField('Ambient Temperature Zone Name', '');
    Obj.AddField('Ambient Temperature Outdoor Air Node Name', '');
    Obj.AddField('Uniform Skin Loss Coefficient per Unit Area to Ambient Temperature', TankUValue );
    Obj.AddField('Skin Loss Fraction to Zone', 1.0 );
    Obj.AddField('Off Cycle Flue Loss Coefficient To Ambient Temperature', '6.0', '{W/K}');
    Obj.AddField('Off Cycle Flue Loss Fraction To Zone', '');
    Obj.AddField('Peak Use Flow Rate', '', '{m3/s}');
    Obj.AddField('Use Flow Rate Fraction Schedule Name', '');
    Obj.AddField('Cold Water Supply Temperature Schedule Name', '');
    Obj.AddField('Use Side Inlet Node Name', UseSideInletNode);
    Obj.AddField('Use Side Outlet Node Name', UseSideOutletNode);
    Obj.AddField('Use Side Effectiveness', '1.0');
    useInHeight := 0.05 * Height;
    Obj.AddField('Use Side Inlet Height', UseInHeight);
    UseOutHeight := 0.95 * Height;
    Obj.AddField('Use Side Outlet Height', UseOutHeight);
    Obj.AddField('Source Side Inlet Node Name', SourceSideInletNode);
    Obj.AddField('Source Side Outlet Node Name', SourceSideOutletNode);
    Obj.AddField('Source Side Effectiveness', '1.0');
    SourceInHeight := 0.95 * Height;
    Obj.AddField('Source Side Inlet Height', SourceInHeight);
    SourceOutHeight := 0.05 * Height;
    Obj.AddField('Source Side Outlet Height', SourceOutHeight);
    obj.AddField('Inlet Mode' , 'Fixed');
    obj.AddField('Use Side Design Flow Rate', 'AUTOSIZE');
    obj.AddField('Source Side Design Flow Rate' , 'AUTOSIZE');
    Obj.AddField('Indirect Water Heater Recovery Time', '1.5');
    obj.AddField('Number of Nodes',NumNodes);
    obj.AddField('Additional Destratification Conductivity', 0.1);
    for i := 0 to NumNodes -1 do
    begin
      obj.AddField('Node # Additional Loss Coefficient', '');
    end; //for
  end
  else if Typ = 'HEATRECOVERYTHERMALFOLLOW' then
  begin
    Obj := IDF.AddObject('WaterHeater:Mixed');
    Obj.AddField('Name', Name);
    Obj.AddField('Tank Volume', FloatToStr(Volume), '{m3}');
    Obj.AddField('Setpoint Temperature Schedule Name', Name + ' Setpoint Temperature Schedule Name');
    Obj.AddField('Deadband Temperature Difference', '2.0', '{deltaC}');
    Obj.AddField('Maximum Temperature Limit', '98.00', '{C}');
    Obj.AddField('Heater Control Type', 'Cycle', '{Cycle | Modulate}');
    Obj.AddField('Heater Maximum Capacity', FloatToStr(Capacity), '{W}');
    Obj.AddField('Heater Minimum Capacity', '', '{W}');
    Obj.AddField('Heater Ignition Minimum Flow Rate', '', '{m3/s}');
    Obj.AddField('Heater Ignition Delay', '', '{s}');
    Obj.AddField('Heater Fuel Type', Fuel);
    Obj.AddField('Heater Thermal Efficiency', FloatToStr(Efficiency), '{}');
    Obj.AddField('Part Load Factor Curve Name', '');
    Obj.AddField('Off Cycle Parasitic Fuel Consumption Rate', '20', '{W}');
    Obj.AddField('Off Cycle Parasitic Fuel Type', Fuel);
    Obj.AddField('Off Cycle Parasitic Heat Fraction To Tank', FloatToStr(Efficiency), '{}');
    Obj.AddField('On Cycle Parasitic Fuel Consumption Rate', '', '{W}');
    Obj.AddField('On Cycle Parasitic Fuel Type', Fuel);
    Obj.AddField('On Cycle Parasitic Heat Fraction To Tank', '', '{}');
    Obj.AddField('Ambient Temperature Indicator', 'Schedule', '{Schedule | Zone | Outdoors}');
    Obj.AddField('Ambient Temperature Schedule Name', Name + ' Ambient Temperature Schedule Name');
    Obj.AddField('Ambient Temperature Zone Name', '');
    Obj.AddField('Ambient Temperature Outdoor Air Node Name', '');
    Obj.AddField('Off Cycle Loss Coefficient to Ambient Temperature', '6.0', '{W/K}');
    Obj.AddField('Off Cycle Loss Fraction to Zone', '');
    Obj.AddField('On Cycle Loss Coefficient to Ambient Temperature', '6.0', '{W/K}');
    Obj.AddField('On Cycle Loss Fraction to Zone', '');
    Obj.AddField('Peak Use Flow Rate', '', '{m3/s}');
    Obj.AddField('Use Flow Rate Fraction Schedule Name', '');
    Obj.AddField('Cold Water Supply Temperature Schedule Name', '');
    Obj.AddField('Use Side Inlet Node Name', UseSideInletNode);
    Obj.AddField('Use Side Outlet Node Name', UseSideOutletNode);
    Obj.AddField('Use Side Effectiveness', '1.0');
    Obj.AddField('Source Side Inlet Node Name', SourceSideInletNode);
    Obj.AddField('Source Side Outlet Node Name', SourceSideOutletNode);
    Obj.AddField('Source Side Effectiveness', '1.0');
    obj.AddField('Use Side Design Flow Rate', 'AUTOSIZE');
    obj.AddField('Source Side Design Flow Rate' , 'AUTOSIZE');
    Obj.AddField('Indirect Water Heater Recovery Time', '1.5');
  end
  else if Typ = 'HEATRECOVERYTHERMALFOLLOWSTRATIFIED' then
  begin
    Obj := IDF.AddObject('WaterHeater:Stratified');
    Obj.AddField('Name', Name);
    obj.AddField('End-use Subcategory', 'tank backup');
    Obj.AddField('Tank Volume', Volume, '{m3}');
    obj.AddField('Tank Height', Height );
    Obj.AddField('Tank Shape', 'VerticalCylinder');
    Obj.AddField('Tank perimeter', '');
    Obj.AddField('Maximum Temperature Limit', '98.00', '{C}');
    obj.AddField('Heater Priority Control',  'MasterSlave');
    obj.AddField('Heater 1 setpoint Temp sched',Name + ' Setpoint Temperature Schedule Name');
    obj.AddField('Heater 1 Deadband Temp diff', 10.0);
    obj.AddField('Heater 1 Capacity', Capacity);
    htr1Height := 0.9 * Height;
    obj.AddField('Heater 1 Height', htr1Height);
    obj.AddField('Heater 2 setpoint Temp sched', Name + ' Setpoint Temperature Schedule Name');
    obj.AddField('Heater 2 Deadband Temp diff', 5.0);
    obj.AddField('Heater 2 Capacity', 0.0);
    obj.AddField('Heater 2 Height', 0.0);
    Obj.AddField('Heater Fuel Type', Fuel);
    Obj.AddField('Heater Thermal Efficiency', Efficiency, '{}');
    Obj.AddField('Off Cycle Parasitic Fuel Consumption Rate', '0.0', '{W}');
    Obj.AddField('Off Cycle Parasitic Fuel Type', Fuel);
    Obj.AddField('Off Cycle Parasitic Heat Fraction To Tank', Efficiency, '{}');
    obj.AddField('Off-Cycle parasitic height', 0.5);
    Obj.AddField('On Cycle Parasitic Fuel Consumption Rate', '', '{W}');
    Obj.AddField('On Cycle Parasitic Fuel Type', Fuel);
    Obj.AddField('On Cycle Parasitic Heat Fraction To Tank', '', '{}');
    obj.AddField('On-Cycle parasitic height', 0.5);
    Obj.AddField('Ambient Temperature Indicator', 'Schedule', '{Schedule | Zone | Outdoors}');
    Obj.AddField('Ambient Temperature Schedule Name', Name + ' Ambient Temperature Schedule Name');
    Obj.AddField('Ambient Temperature Zone Name', '');
    Obj.AddField('Ambient Temperature Outdoor Air Node Name', '');
    Obj.AddField('Uniform skin loss coef per unit area to ambient', TankUValue );
    Obj.AddField('Skin loss fraction to Zone', 1.0 );
    Obj.AddField('Off Cycle Flue Loss Coefficient To Ambient Temperature', '6.0', '{W/K}');
    Obj.AddField('Off Cycle Flue Loss Fraction To Zone', '');
    Obj.AddField('Peak Use Flow Rate', '', '{m3/s}');
    Obj.AddField('Use Flow Rate Fraction Schedule Name', '');
    Obj.AddField('Cold Water Supply Temperature Schedule Name', '');
    Obj.AddField('Use Side Inlet Node Name', UseSideInletNode);
    Obj.AddField('Use Side Outlet Node Name', UseSideOutletNode);
    Obj.AddField('Use Side Effectiveness', '1.0');
    useInHeight := 0.05 * Height;
    Obj.AddField('Use Side inlet height', UseInHeight);
    UseOutHeight := 0.95 * Height;
    Obj.AddField('Use Side outlet height', UseOutHeight);
    Obj.AddField('Source Side Inlet Node Name', SourceSideInletNode);
    Obj.AddField('Source Side Outlet Node Name', SourceSideOutletNode);
    Obj.AddField('Source Side Effectiveness', '1.0');
    SourceInHeight := 0.95 * Height;
    Obj.AddField('Source Side inlet height', SourceInHeight);
    SourceOutHeight := 0.05 * Height;
    Obj.AddField('Source Side outlet height', SourceOutHeight);
    obj.AddField('Inlet Mode' , 'Fixed');
    obj.AddField('Use Side Design Flow Rate', 'AUTOSIZE');
    obj.AddField('Source Side Design Flow Rate' , 'AUTOSIZE');
    Obj.AddField('Indirect Water Heater Recovery Time', '1.5');
    obj.AddField('Number of Nodes',NumNodes);
    obj.AddField('Additional Destratification Conductivity', 0.1);
    for i := 0 to NumNodes -1 do
    begin
      obj.AddField('additional loss coef', '');
    end; //for
  end
  else if Typ = 'INSTANTANEOUS' then
  begin
    Obj := IDF.AddObject('WaterHeater:Mixed');
    Obj.AddField('Name', Name);
    Obj.AddField('Tank Volume', '0.003785', '{m3}');
    Obj.AddField('Setpoint Temperature Schedule Name', Name + ' Setpoint Temperature Schedule Name');
    Obj.AddField('Deadband Temperature Difference', '', '{deltaC}');
    Obj.AddField('Maximum Temperature Limit', '82.2222', '{C}');
    Obj.AddField('Heater Control Type', 'Modulate', '{Cycle | Modulate}');
    Obj.AddField('Heater Maximum Capacity', FloatToStr(Capacity), '{W}');
    Obj.AddField('Heater Minimum Capacity', '', '{W}');
    Obj.AddField('Heater Ignition Minimum Flow Rate', '', '{m3/s}');
    Obj.AddField('Heater Ignition Delay', '', '{s}');
    Obj.AddField('Heater Fuel Type', Fuel);
    Obj.AddField('Heater Thermal Efficiency', FloatToStr(Efficiency), '{}');
    Obj.AddField('Part Load Factor Curve Name', '');
    Obj.AddField('Off Cycle Parasitic Fuel Consumption Rate', '2', '{W}');
    Obj.AddField('Off Cycle Parasitic Fuel Type', Fuel);
    Obj.AddField('Off Cycle Parasitic Heat Fraction To Tank', FloatToStr(Efficiency), '{}');
    Obj.AddField('On Cycle Parasitic Fuel Consumption Rate', '', '{W}');
    Obj.AddField('On Cycle Parasitic Fuel Type', Fuel);
    Obj.AddField('On Cycle Parasitic Heat Fraction To Tank', '', '{}');
    Obj.AddField('Ambient Temperature Indicator', 'Schedule', '{Schedule | Zone | Outdoors}');
    Obj.AddField('Ambient Temperature Schedule Name', Name + ' Ambient Temperature Schedule Name');
    Obj.AddField('Ambient Temperature Zone Name', '');
    Obj.AddField('Ambient Temperature Outdoor Air Node Name', '');
    Obj.AddField('Off Cycle Loss Coefficient to Ambient Temperature', '6.0', '{W/K}');
    Obj.AddField('Off Cycle Loss Fraction to Zone', '');
    Obj.AddField('On Cycle Loss Coefficient to Ambient Temperature', '6.0', '{W/K}');
    Obj.AddField('On Cycle Loss Fraction to Zone', '');
    Obj.AddField('Peak Use Flow Rate', '', '{m3/s}');
    Obj.AddField('Use Flow Rate Fraction Schedule Name', '');
    Obj.AddField('Cold Water Supply Temperature Schedule Name', '');
    Obj.AddField('Use Side Inlet Node Name', SupplyInletNode);
    Obj.AddField('Use Side Outlet Node Name', SupplyOutletNode);
    Obj.AddField('Use Side Effectiveness', '1.0');
    Obj.AddField('Source Side Inlet Node Name', '');
    Obj.AddField('Source Side Outlet Node Name', '');
    Obj.AddField('Source Side Effectiveness', '');
    obj.AddField('Use Side Design Flow Rate', 'AUTOSIZE');
    obj.AddField('Source Side Design Flow Rate' , 'AUTOSIZE');
    Obj.AddField('Indirect Water Heater Recovery Time', '1.5');
  end
  else if Typ = 'HEAT PUMP' then
  begin
    //WaterHeater:HeatPump
    Obj := IDF.AddObject('WaterHeater:HeatPump');
    Obj.AddField('Name', Name + ' Bottom');
    Obj.AddField('Availability Schedule Name', 'Always_On');
    Obj.AddField('Compressor Setpoint Temperature Schedule Name', Name + ' Setpoint Temperature Schedule Name');
    Obj.AddField('Dead Band Temperature Difference', '0.01', '{deltaC}');
    Obj.AddField('Condenser Water Inlet Node Name', Name + ' Bottom Condenser Water Inlet Node');
    Obj.AddField('Condenser Water Outlet Node Name', Name + ' Bottom Condenser Water Outlet Node');
    Obj.AddField('Condenser Water Flow Rate', '0.0000251174', '{m3/s}');
    Obj.AddField('Evaporator Air Flow Rate', '0.1321452832', '{m3/s}');
    Obj.AddField('Inlet Air Configuration', 'ZoneAirOnly');
    Obj.AddField('Air Inlet Node Name', HPWHZone + ' Bottom Inlet Node');
    Obj.AddField('Air Outlet Node Name', HPWHZone + ' Bottom Outlet Node');
    Obj.AddField('Outdoor Air Node Name', '');
    Obj.AddField('Exhaust Air Node Name', '');
    Obj.AddField('Inlet Air Temperature Schedule Name', '');
    Obj.AddField('Inlet Air Humidity Schedule Name', '');
    Obj.AddField('Inlet Air Zone Name', HPWHZone);
    Obj.AddField('Tank Object Type', 'WaterHeater:Mixed');
    Obj.AddField('Tank Name', Name + ' Tank Bottom');
    Obj.AddField('Tank Use Side Inlet Node Name', SupplyInletNode);
    Obj.AddField('Tank Use Side Outlet Node Name', Name + ' Bottom-Top Node');
    Obj.AddField('DX Coil Object Type', 'Coil:WaterHeating:AirToWaterHeatPump');
    Obj.AddField('DX Coil Name', Name + ' Bottom Coil');
    Obj.AddField('Minimum Inlet Air Temperature for Compressor Operation', '7.222222222222222', '{C}');
    Obj.AddField('Compressor Location', 'Zone');
    Obj.AddField('Compressor Ambient Temperature Schedule Name', '');
    Obj.AddField('Fan Object Type', 'Fan:OnOff');
    Obj.AddField('Fan Name', Name + ' Bottom Fan');
    Obj.AddField('Fan Placement', 'DrawThrough');
    Obj.AddField('On Cycle Parasitic Electric Load', '3', '{W}');
    Obj.AddField('Off Cycle Parasitic Electric Load', '3', '{W}');
    Obj.AddField('Parasitic Heat Rejection Location', 'Zone');
    //WaterHeater:Mixed
    Obj := IDF.AddObject('WaterHeater:Mixed');
    Obj.AddField('Name', Name + ' Tank Bottom');
    Obj.AddField('Tank Volume', '0.0170343531', '{m3}');
    Obj.AddField('Setpoint Temperature Schedule Name',  Name + ' Setpoint Temperature Schedule Name');
    Obj.AddField('Deadband Temperature Difference', '0.1', '{deltaC}');
    Obj.AddField('Maximum Temperature Limit', '99', '{C}');
    Obj.AddField('Heater Control Type', 'Cycle', '{Cycle | Modulate}');
    Obj.AddField('Heater Maximum Capacity', FloatToStr(Capacity), '{W}');
    Obj.AddField('Heater Minimum Capacity', '0', '{W}');
    Obj.AddField('Heater Ignition Minimum Flow Rate', '', '{m3/s}');
    Obj.AddField('Heater Ignition Delay', '', '{s}');
    Obj.AddField('Heater Fuel Type', Fuel);
    Obj.AddField('Heater Thermal Efficiency', FloatToStr(Efficiency), '{}');
    Obj.AddField('Part Load Factor Curve Name', '');
    Obj.AddField('Off Cycle Parasitic Fuel Consumption Rate', '0', '{W}');
    Obj.AddField('Off Cycle Parasitic Fuel Type', Fuel);
    Obj.AddField('Off Cycle Parasitic Heat Fraction To Tank', '0', '{}');
    Obj.AddField('On Cycle Parasitic Fuel Consumption Rate', '0', '{W}');
    Obj.AddField('On Cycle Parasitic Fuel Type', Fuel);
    Obj.AddField('On Cycle Parasitic Heat Fraction To Tank', '0', '{}');
    Obj.AddField('Ambient Temperature Indicator', 'Zone', '{Schedule | Zone | Outdoors}');
    Obj.AddField('Ambient Temperature Schedule Name', '');
    Obj.AddField('Ambient Temperature Zone Name', HPWHZone);
    Obj.AddField('Ambient Temperature Outdoor Air Node Name', '');
    Obj.AddField('Off Cycle Loss Coefficient to Ambient Temperature', '0.195175', '{W/K}');
    Obj.AddField('Off Cycle Loss Fraction to Zone', '1');
    Obj.AddField('On Cycle Loss Coefficient to Ambient Temperature', '0.195175', '{W/K}');
    Obj.AddField('On Cycle Loss Fraction to Zone', '1');
    Obj.AddField('Peak Use Flow Rate', '', '{m3/s}');
    Obj.AddField('Use Flow Rate Fraction Schedule Name', '');
    Obj.AddField('Cold Water Supply Temperature Schedule Name', '');
    Obj.AddField('Use Side Inlet Node Name', SupplyInletNode);
    Obj.AddField('Use Side Outlet Node Name', Name + ' Bottom-Top Node');
    Obj.AddField('Use Side Effectiveness', '1');
    Obj.AddField('Source Side Inlet Node Name', Name + ' Bottom Condenser Water Outlet Node');
    Obj.AddField('Source Side Outlet Node Name', Name + ' Bottom Condenser Water Inlet Node');
    Obj.AddField('Source Side Effectiveness', '1');
    Obj.AddField('Use Side Design Flow Rate', 'AutoSize');
    //Coil:WaterHeating:AirToWaterHeatPump
    Obj := IDF.AddObject('Coil:WaterHeating:AirToWaterHeatPump');
    Obj.AddField('Name', Name + ' Bottom Coil');
    Obj.AddField('Rated Heating Capacity', 1400, '{W}');
    Obj.AddField('Rated COP', FloatToStr(COP), '{W/W}');
    Obj.AddField('Rated Sensible Heat Ratio', '0.8837333333333334');
    Obj.AddField('Rated Evaporator Inlet Air Dry-Bulb Temperature', '19.722222222222222', '{C}');
    Obj.AddField('Rated Evaporator Inlet Air Wet-Bulb Temperature', '13.555555555555554', '{C}');
    Obj.AddField('Rated Condenser Inlet Water Temperature', '48.888888888888886', '{C}');
    Obj.AddField('Rated Evaporator Air Flow Rate', '0.1321452832', '{m3/s}');
    Obj.AddField('Rated Condenser Water Flow Rate', '0.0000251174', '{m3/s}');
    Obj.AddField('Evaporator Fan Power Included in Rated COP', 'Yes');
    Obj.AddField('Condenser Pump Power Included in Rated COP', 'No');
    Obj.AddField('Condenser Pump Heat Included in Rated Heating Capacity and Rated COP', 'Yes');
    Obj.AddField('Condenser Water Pump Power', '0', '{W}');
    Obj.AddField('Fraction of Condenser Pump Heat to Water', '0.00001', '{}');
    Obj.AddField('Evaporator Air Inlet Node Name', HPWHZone + ' Bottom Inlet Node');
    Obj.AddField('Evaporator Air Outlet Node Name', Name + ' Bottom Coil Air Outlet Fan Air Inlet Node');
    Obj.AddField('Condenser Water Inlet Node Name', Name + ' Bottom Condenser Water Inlet Node');
    Obj.AddField('Condenser Water Outlet Node Name', Name + ' Bottom Condenser Water Outlet Node');
    Obj.AddField('Crankcase Heater Capacity', '0', '{W}');
    Obj.AddField('Maximum Ambient Temperature for Crankcase Heater Operation', '0', '{C}');
    Obj.AddField('Evaporator Air Temperature Type for Curve Objects', 'WetBulbTemperature');
    Obj.AddField('Heating Capacity Function of Temperature Curve Name', Name + ' Htg Cap fTemp');
    Obj.AddField('Heating Capacity Function of Air Flow Fraction Curve Name', '');
    Obj.AddField('Heating Capacity Function of Water Flow Fraction Curve Name', '');
    Obj.AddField('Heating COP Function of Temperature Curve Name', Name + ' Htg COP fTemp');
    Obj.AddField('Heating COP Function of Air Flow Fraction Curve Name', '');
    Obj.AddField('Heating COP Function of Water Flow Fraction Curve Name', '');
    Obj.AddField('Part Load Fraction Correlation Curve Name', Name + ' Htg COP fPLR');
    //Fan:OnOff
    Obj := IDF.AddObject('Fan:OnOff');
    Obj.AddField('Name', Name + ' Bottom Fan');
    Obj.AddField('Availability Schedule Name', 'Always_On');
    Obj.AddField('Fan Efficiency', '0.47194744', '{}');
    Obj.AddField('Pressure Rise', '100', '{Pa}');
    Obj.AddField('Maximum Flow Rate', '0.1321452832', '{m3/s}');
    Obj.AddField('Motor Efficiency', '1', '{}');
    Obj.AddField('Motor In Airstream Fraction', '0', '{}');
    Obj.AddField('Air Inlet Node Name', Name + ' Bottom Coil Air Outlet Fan Air Inlet Node');
    Obj.AddField('Air Outlet Node Name', HPWHZone + ' Bottom Outlet Node');
    //WaterHeater:HeatPump
    Obj := IDF.AddObject('WaterHeater:HeatPump');
    Obj.AddField('Name', Name + ' Top');
    Obj.AddField('Availability Schedule Name', 'Always_On');
    Obj.AddField('Compressor Setpoint Temperature Schedule Name', Name + ' Setpoint Temperature Schedule Name');
    Obj.AddField('Dead Band Temperature Difference', '0.01', '{deltaC}');
    Obj.AddField('Condenser Water Inlet Node Name', Name + ' Top Condenser Water Inlet Node');
    Obj.AddField('Condenser Water Outlet Node Name', Name + ' Top Condenser Water Outlet Node');
    Obj.AddField('Condenser Water Flow Rate', '0.0000251174', '{m3/s}');
    Obj.AddField('Evaporator Air Flow Rate', '0.1321452832', '{m3/s}');
    Obj.AddField('Inlet Air Configuration', 'ZoneAirOnly');
    Obj.AddField('Air Inlet Node Name', HPWHZone + ' Top Inlet Node');
    Obj.AddField('Air Outlet Node Name', HPWHZone + ' Top Outlet Node');
    Obj.AddField('Outdoor Air Node Name', '');
    Obj.AddField('Exhaust Air Node Name', '');
    Obj.AddField('Inlet Air Temperature Schedule Name', '');
    Obj.AddField('Inlet Air Humidity Schedule Name', '');
    Obj.AddField('Inlet Air Zone Name', HPWHZone);
    Obj.AddField('Tank Object Type', 'WaterHeater:Mixed');
    Obj.AddField('Tank Name', Name + ' Tank Top');
    Obj.AddField('Tank Use Side Inlet Node Name', Name + ' Bottom-Top Node');
    Obj.AddField('Tank Use Side Outlet Node Name', Name + ' Top-Tankless Node');
    Obj.AddField('DX Coil Object Type', 'Coil:WaterHeating:AirToWaterHeatPump');
    Obj.AddField('DX Coil Name', Name + ' Top Coil');
    Obj.AddField('Minimum Inlet Air Temperature for Compressor Operation', '7.222222222222222', '{C}');
    Obj.AddField('Compressor Location', 'Zone');
    Obj.AddField('Compressor Ambient Temperature Schedule Name', '');
    Obj.AddField('Fan Object Type', 'Fan:OnOff');
    Obj.AddField('Fan Name', Name + ' Top Fan');
    Obj.AddField('Fan Placement', 'DrawThrough');
    Obj.AddField('On Cycle Parasitic Electric Load', '0', '{W}');
    Obj.AddField('Off Cycle Parasitic Electric Load', '0', '{W}');
    Obj.AddField('Parasitic Heat Rejection Location', 'Zone');
    //WaterHeater:Mixed
    Obj := IDF.AddObject('WaterHeater:Mixed');
    Obj.AddField('Name', Name + ' Tank Top');
    Obj.AddField('Tank Volume', '0.1533091779', '{m3}');
    Obj.AddField('Setpoint Temperature Schedule Name', Name + ' Setpoint Temperature Schedule Name');
    Obj.AddField('Deadband Temperature Difference', '3', '{deltaC}');
    Obj.AddField('Maximum Temperature Limit', '99', '{C}');
    Obj.AddField('Heater Control Type', 'Cycle', '{Cycle | Modulate}');
    Obj.AddField('Heater Maximum Capacity', FloatToStr(Capacity), '{W}');
    Obj.AddField('Heater Minimum Capacity', '0', '{W}');
    Obj.AddField('Heater Ignition Minimum Flow Rate', '', '{m3/s}');
    Obj.AddField('Heater Ignition Delay', '', '{s}');
    Obj.AddField('Heater Fuel Type', Fuel);
    Obj.AddField('Heater Thermal Efficiency', FloatToStr(Efficiency), '{}');
    Obj.AddField('Part Load Factor Curve Name', '');
    Obj.AddField('Off Cycle Parasitic Fuel Consumption Rate', '0', '{W}');
    Obj.AddField('Off Cycle Parasitic Fuel Type', Fuel);
    Obj.AddField('Off Cycle Parasitic Heat Fraction To Tank', '0', '{}');
    Obj.AddField('On Cycle Parasitic Fuel Consumption Rate', '0', '{W}');
    Obj.AddField('On Cycle Parasitic Fuel Type', Fuel);
    Obj.AddField('On Cycle Parasitic Heat Fraction To Tank', '0', '{}');
    Obj.AddField('Ambient Temperature Indicator', 'Schedule', '{Schedule | Zone | Outdoors}');
    Obj.AddField('Ambient Temperature Schedule Name', Name + ' Ambient Temperature Schedule Name');
    Obj.AddField('Ambient Temperature Zone Name', '');
    Obj.AddField('Ambient Temperature Outdoor Air Node Name', '');
    Obj.AddField('Off Cycle Loss Coefficient to Ambient Temperature', '1.756575', '{W/K}');
    Obj.AddField('Off Cycle Loss Fraction to Zone', '1');
    Obj.AddField('On Cycle Loss Coefficient to Ambient Temperature', '1.756575', '{W/K}');
    Obj.AddField('On Cycle Loss Fraction to Zone', '1');
    Obj.AddField('Peak Use Flow Rate', '', '{m3/s}');
    Obj.AddField('Use Flow Rate Fraction Schedule Name', '');
    Obj.AddField('Cold Water Supply Temperature Schedule Name', '');
    Obj.AddField('Use Side Inlet Node Name', Name + ' Bottom-Top Node');
    Obj.AddField('Use Side Outlet Node Name', Name + ' Top-Tankless Node');
    Obj.AddField('Use Side Effectiveness', '1');
    Obj.AddField('Source Side Inlet Node Name', Name + ' Top Condenser Water Outlet Node');
    Obj.AddField('Source Side Outlet Node Name', Name + ' Top Condenser Water Inlet Node');
    Obj.AddField('Source Side Effectiveness', '1');
    Obj.AddField('Use Side Design Flow Rate', 'AutoSize');
    //Coil:WaterHeating:AirToWaterHeatPump
    Obj := IDF.AddObject('Coil:WaterHeating:AirToWaterHeatPump');
    Obj.AddField('Name', Name + ' Top Coil');
    Obj.AddField('Rated Heating Capacity', '1400', '{W}');
    Obj.AddField('Rated COP', FloatToStr(COP), '{W/W}');
    Obj.AddField('Rated Sensible Heat Ratio', '0.8837333333333334');
    Obj.AddField('Rated Evaporator Inlet Air Dry-Bulb Temperature', '19.722222222222222', '{C}');
    Obj.AddField('Rated Evaporator Inlet Air Wet-Bulb Temperature', '13.555555555555554', '{C}');
    Obj.AddField('Rated Condenser Inlet Water Temperature', '48.888888888888886', '{C}');
    Obj.AddField('Rated Evaporator Air Flow Rate', '0.1321452832', '{m3/s}');
    Obj.AddField('Rated Condenser Water Flow Rate', '0.0000251174', '{m3/s}');
    Obj.AddField('Evaporator Fan Power Included in Rated COP', 'Yes');
    Obj.AddField('Condenser Pump Power Included in Rated COP', 'No');
    Obj.AddField('Condenser Pump Heat Included in Rated Heating Capacity and Rated COP', 'Yes');
    Obj.AddField('Condenser Water Pump Power', '0', '{W}');
    Obj.AddField('Fraction of Condenser Pump Heat to Water', '0.00001', '{}');
    Obj.AddField('Evaporator Air Inlet Node Name', HPWHZone + ' Top Inlet Node');
    Obj.AddField('Evaporator Air Outlet Node Name', Name + ' Top Coil Air Outlet Fan Air Inlet Node');
    Obj.AddField('Condenser Water Inlet Node Name', Name + ' Top Condenser Water Inlet Node');
    Obj.AddField('Condenser Water Outlet Node Name', Name + ' Top Condenser Water Outlet Node');
    Obj.AddField('Crankcase Heater Capacity', '0', '{W}');
    Obj.AddField('Maximum Ambient Temperature for Crankcase Heater Operation', '0', '{C}');
    Obj.AddField('Evaporator Air Temperature Type for Curve Objects', 'WetBulbTemperature');
    Obj.AddField('Heating Capacity Function of Temperature Curve Name', Name + ' Htg Cap fTemp');
    Obj.AddField('Heating Capacity Function of Air Flow Fraction Curve Name', '');
    Obj.AddField('Heating Capacity Function of Water Flow Fraction Curve Name', '');
    Obj.AddField('Heating COP Function of Temperature Curve Name', Name + ' Htg COP fTemp');
    Obj.AddField('Heating COP Function of Air Flow Fraction Curve Name', '');
    Obj.AddField('Heating COP Function of Water Flow Fraction Curve Name', '');
    Obj.AddField('Part Load Fraction Correlation Curve Name', Name + ' Htg COP fPLR');
    //Fan:OnOff
    Obj := IDF.AddObject('Fan:OnOff');
    Obj.AddField('Name', Name + ' Top Fan');
    Obj.AddField('Availability Schedule Name', 'Always_On');
    Obj.AddField('Fan Efficiency', '0.47194744', '{}');
    Obj.AddField('Pressure Rise', '100', '{Pa}');
    Obj.AddField('Maximum Flow Rate', '0.1321452832', '{m3/s}');
    Obj.AddField('Motor Efficiency', '1', '{}');
    Obj.AddField('Motor In Airstream Fraction', '0', '{}');
    Obj.AddField('Air Inlet Node Name', Name + ' Top Coil Air Outlet Fan Air Inlet Node');
    Obj.AddField('Air Outlet Node Name', HPWHZone + ' Top Outlet Node');
    //WaterHeater:Mixed
    Obj := IDF.AddObject('WaterHeater:Mixed');
    Obj.AddField('Name', Name + ' Dummy Tankless');
    Obj.AddField('Tank Volume', '0', '{m3}');
    Obj.AddField('Setpoint Temperature Schedule Name', Name + ' Setpoint Temperature Schedule Name');
    Obj.AddField('Deadband Temperature Difference', '2.0', '{deltaC}');
    Obj.AddField('Maximum Temperature Limit', '82.2222', '{C}');
    Obj.AddField('Heater Control Type', 'Cycle', '{Cycle | Modulate}');
    Obj.AddField('Heater Maximum Capacity', '3082.699001', '{W}');
    Obj.AddField('Heater Minimum Capacity', '', '{W}');
    Obj.AddField('Heater Ignition Minimum Flow Rate', '', '{m3/s}');
    Obj.AddField('Heater Ignition Delay', '', '{s}');
    Obj.AddField('Heater Fuel Type', Fuel);
    Obj.AddField('Heater Thermal Efficiency', '0.7', '{}');
    Obj.AddField('Part Load Factor Curve Name', '');
    Obj.AddField('Off Cycle Parasitic Fuel Consumption Rate', '20', '{W}');
    Obj.AddField('Off Cycle Parasitic Fuel Type', Fuel);
    Obj.AddField('Off Cycle Parasitic Heat Fraction To Tank', '0.7', '{}');
    Obj.AddField('On Cycle Parasitic Fuel Consumption Rate', '', '{W}');
    Obj.AddField('On Cycle Parasitic Fuel Type', Fuel);
    Obj.AddField('On Cycle Parasitic Heat Fraction To Tank', '', '{}');
    Obj.AddField('Ambient Temperature Indicator', 'Schedule', '{Schedule | Zone | Outdoors}');
    Obj.AddField('Ambient Temperature Schedule Name', Name + ' Ambient Temperature Schedule Name');
    Obj.AddField('Ambient Temperature Zone Name', '');
    Obj.AddField('Ambient Temperature Outdoor Air Node Name', '');
    Obj.AddField('Off Cycle Loss Coefficient to Ambient Temperature', '6.0', '{W/K}');
    Obj.AddField('Off Cycle Loss Fraction to Zone', '');
    Obj.AddField('On Cycle Loss Coefficient to Ambient Temperature', '6.0', '{W/K}');
    Obj.AddField('On Cycle Loss Fraction to Zone', '');
    Obj.AddField('Peak Use Flow Rate', '', '{m3/s}');
    Obj.AddField('Use Flow Rate Fraction Schedule Name', '');
    Obj.AddField('Cold Water Supply Temperature Schedule Name', '');
    Obj.AddField('Use Side Inlet Node Name', Name + ' Top-Tankless Node');
    Obj.AddField('Use Side Outlet Node Name', SupplyOutletNode);
    Obj.AddField('Use Side Effectiveness', '1.0');
    Obj.AddField('Source Side Inlet Node Name', '');
    Obj.AddField('Source Side Outlet Node Name', '');
    Obj.AddField('Source Side Effectiveness', '1.0');
    Obj.AddField('Use Side Design Flow Rate', 'AutoSize');
    Obj.AddField('Source Side Design Flow Rate', 'AutoSize');
    Obj.AddField('Indirect Water Heater Recovery Time', '1.5');
    //Curve:Biquadratic
    Obj := IDF.AddObject('Curve:Biquadratic');
    Obj.AddField('Name', Name + ' Htg Cap fTemp');
    Obj.AddField('Coefficient1 Constant', '1');
    Obj.AddField('Coefficient2 X', '0');
    Obj.AddField('Coefficient3 X**2', '0');
    Obj.AddField('Coefficient4 Y', '0');
    Obj.AddField('Coefficient5 Y**2', '0');
    Obj.AddField('Coefficient6 X*Y', '0');
    Obj.AddField('Minimum Value of X', '0');
    Obj.AddField('Maximum Value of X', '140');
    Obj.AddField('Minimum Value of Y', '0');
    Obj.AddField('Maximum Value of Y', '140');
    Obj.AddField('Minimum Curve Output', '0');
    Obj.AddField('Maximum Curve Output', '');
    Obj.AddField('Input Unit Type for X', 'Temperature');
    Obj.AddField('Input Unit Type for Y', 'Temperature');
    Obj.AddField('Output Unit Type', 'Dimensionless');
    //Curve:Biquadratic
    Obj := IDF.AddObject('Curve:Biquadratic');
    Obj.AddField('Name', Name + ' Htg COP fTemp');
    Obj.AddField('Coefficient1 Constant', '1');
    Obj.AddField('Coefficient2 X', '0');
    Obj.AddField('Coefficient3 X**2', '0');
    Obj.AddField('Coefficient4 Y', '0');
    Obj.AddField('Coefficient5 Y**2', '0');
    Obj.AddField('Coefficient6 X*Y', '0');
    Obj.AddField('Minimum Value of X', '0');
    Obj.AddField('Maximum Value of X', '140');
    Obj.AddField('Minimum Value of Y', '0');
    Obj.AddField('Maximum Value of Y', '140');
    Obj.AddField('Minimum Curve Output', '0');
    Obj.AddField('Maximum Curve Output', '');
    Obj.AddField('Input Unit Type for X', 'Temperature');
    Obj.AddField('Input Unit Type for Y', 'Temperature');
    Obj.AddField('Output Unit Type', 'Dimensionless');
    //Curve:Quadratic
    Obj := IDF.AddObject('Curve:Quadratic');
    Obj.AddField('Name', Name + ' Htg COP fPLR');
    Obj.AddField('Coefficient1 Constant', '1');
    Obj.AddField('Coefficient2 X', '0');
    Obj.AddField('Coefficient3 X**2', '0');
    Obj.AddField('Minimum Value of X', '0');
    Obj.AddField('Maximum Value of X', '140');
  end;
  //Schedule:Compact
  Obj := IDF.AddObject('Schedule:Compact');
  Obj.AddField('Name', Name + ' Setpoint Temperature Schedule Name');
  Obj.AddField('Schedule Type Limits Name', 'Temperature');
  Obj.AddField('Field 1', 'Through: 12/31');
  Obj.AddField('Field 2', 'For: AllDays');
  Obj.AddField('Field 3', 'Until: 24:00');
  Obj.AddField('Field 4', '60.0');
  //Schedule:Compact
  Obj := IDF.AddObject('Schedule:Compact');
  Obj.AddField('Name', Name + ' Ambient Temperature Schedule Name');
  Obj.AddField('Schedule Type Limits Name', 'Temperature');
  Obj.AddField('Field 1', 'Through: 12/31');
  Obj.AddField('Field 2', 'For: AllDays');
  Obj.AddField('Field 3', 'Until: 24:00');
  Obj.AddField('Field 4', '22.0');
  //suppress to IDF
  SuppressToIDF := true; // don't write it out again!
end;

procedure T_EP_WaterHeater.Finalize;
begin
  inherited;
end;

{ T_EP_WaterUseConnection }

constructor T_EP_WaterUseConnection.Create;
begin
  inherited;
  ComponentType := 'WaterUse:Connections';
  ControlType := 'Active';
  DemandControlType := 'Active';

end;

procedure T_EP_WaterUseConnection.SetSystem(SystemParameter: T_EP_System);
begin
  inherited;
  if Assigned(SystemParameter) then
  begin
    SystemValue := SystemParameter;

  end;
end;

procedure T_EP_WaterUseConnection.finalize;
begin
  inherited;
  WaterUseObject.Finalize;
end;

procedure T_EP_WaterUseConnection.ToIDF;
var
  Obj: TEnergyPlusObject;
begin
  inherited;
  if WaterUseObject.SubCategory = '' then
    Name := System.Name + ' Water Equipment'
  else
    Name := System.Name + ' ' + WaterUseObject.SubCategory;
    
  DemandInletNode := Name + ' Water Inlet Node';
  DemandOutletNode := Name + ' Water Outlet Node';

  Obj := IDF.AddObject('WaterUse:Connections');
  obj.AddField('Name', Name);
  obj.AddField('Inlet Node Name', DemandInletNode);
  obj.AddField('Outlet Node Name', DemandOutletNode);

  if Assigned(WaterStorageTank) then
  begin
    obj.AddField('Supply Water Storage Tank Name', WaterStorageTank.Name);
  end
  else
  begin
    obj.AddField('Supply Water Storage Tank Name', '');
  end;

  if Assigned(ReclaimTargetTank) then
  begin
    obj.AddField('Reclamation Water Storage Tank Name', ReclaimTargetTank.Name);
  end
  else
  begin
    obj.AddField('Reclamation Water Storage Tank Name', '');
  end;
  obj.AddField('Hot Water Supply Temperature Schedule Name', '');
  Obj.AddField('Cold Water Supply Temperature Schedule Name', '');
  Obj.AddField('Drain Water Heat Exchanger Type', '');
  Obj.AddField('Drain Water Heat Exchanger Destination', '');
  Obj.AddField('Drain Water Heat Exchanger U-Factor Times Area', '');
  Obj.AddField('Water Use Equipment 1 Name', WaterUseObject.name);

  WaterUseObject.ToIDF;

end;

{  T_EP_WaterUse }

constructor T_EP_WaterUse.Create;
begin
  FlowSchedule := 'BLDG_SWH_SCH';
  SubCategory := '';
  PeakVolFlowRate := 0.1; // really need to this get set!!
  LatentFraction := 0.05;
  SensibleFraction := 0.2;
  TargetTemperature := 38.0;
  HotServiceTargetTemp := 55.0;
end;

procedure T_EP_WaterUse.Finalize;
begin
  inherited;
  if SubCategory = '' then
    Name := ZoneObj.Name + ' Water Equipment'
  else
    Name := zoneObj.Name + ' ' + SubCategory;
  // need to calculate PeakVolFlowRate  in m^3 / sec
  PeakVolFlowRate := 0.0;
  if SameText(Typ, 'PERSONPERHOUR') then
  begin
    // need number of people
    PeakVolFlowRate := (InputUseRatePer * ZoneObj.NumPeople) / 3600;
    StorageVolume := InputStorageRequiredPer * ZoneObj.NumPeople;
    HeatingCapacity := InputRecoveryRatePer * ZoneObj.NumPeople;
  end
  else if SameText(Typ, 'PERSONPERDAY') then
  begin
    if ZoneObj.HoursPerDay = 0 then
    begin
      PeakVolFlowRate := 0;
      StorageVolume := InputStorageRequiredPer * ZoneObj.NumPeople;
      HeatingCapacity := InputRecoveryRatePer * ZoneObj.NumPeople;
    end
    else
    begin
      PeakVolFlowRate := (InputUseRatePer * ZoneObj.NumPeople) /
        (ZoneObj.HoursPerDay * 3600);
      StorageVolume := InputStorageRequiredPer * ZoneObj.NumPeople;
      HeatingCapacity := InputRecoveryRatePer * ZoneObj.NumPeople;
    end;
  end
  else if SameText(Typ, 'AREAPERHOUR') then
  begin
    PeakVolFlowRate := (InputUseRatePer * ZoneObj.Area) / 3600;
    StorageVolume := InputStorageRequiredPer * ZoneObj.Area;
    HeatingCapacity := InputRecoveryRatePer * ZoneObj.Area;
  end
  else if SameText(Typ, 'AREAPERDAY') then
  begin
    if ZoneObj.HoursPerDay = 0 then
    begin
      PeakVolFlowRate := 0;
      StorageVolume := InputStorageRequiredPer * ZoneObj.Area;
      HeatingCapacity := InputRecoveryRatePer * ZoneObj.Area;
    end
    else
    begin
      PeakVolFlowRate := (InputUseRatePer * ZoneObj.Area) /
        (ZoneObj.HoursPerDay * 3600);
      StorageVolume := InputStorageRequiredPer * ZoneObj.Area;
      HeatingCapacity := InputRecoveryRatePer * ZoneObj.Area;
    end;
  end
  else if SameText(Typ, 'EACHPERHOUR') then
  begin
    //have to divide out only if we are using roof multipliers don't have to
    //in the other cases because the areas and people are already adjusted
    //based on the multiplier
    PeakVolFlowRate := (InputUseRatePer) / 3600;
    if (ZoneObj.RoofMultiplierVal > 0) then
      PeakVolFlowRate := PeakVolFlowRate / ZoneObj.RoofMultiplierVal;
    StorageVolume := InputStorageRequiredPer;
    HeatingCapacity := InputRecoveryRatePer;
  end
  else if SameText(Typ, 'EACHPERDAY') then
  begin
    if ZoneObj.HoursPerDay = 0 then
    begin
      PeakVolFlowRate := 0;
      StorageVolume := InputStorageRequiredPer;
      HeatingCapacity := InputRecoveryRatePer;
    end
    else
    begin
      PeakVolFlowRate := InputUseRatePer / (ZoneObj.HoursPerDay * 3600);
      if (ZoneObj.RoofMultiplierVal > 0) then
        PeakVolFlowRate := PeakVolFlowRate / ZoneObj.RoofMultiplierVal;
      StorageVolume := InputStorageRequiredPer;
      HeatingCapacity := InputRecoveryRatePer;
    end;
  end
  else
  begin
    //
  end;
  // need to correct if total volume design volume flow rate is too small
end;

procedure T_EP_WaterUse.ToIDF;
var
  Obj: TEnergyPlusObject;
begin
  Obj := IDF.AddObject('WaterUse:Equipment');
  obj.AddField('Name', Name);
  Obj.AddField('End-Use subcategory', SubCategory);
  Obj.AddField('Peak Flow Rate', floattostr(PeakVolFlowRate), '{m3/s}');
  obj.AddField('Flow Rate Fraction Schedule Name', FlowSchedule);
  obj.AddField('Target Temperature Schedule Name ', Name + ' Temp Sched');
  obj.AddField('Hot Water Supply Temperature Schedule Name ', Name + ' Hot Supply Temp Sched', '{C}');
  obj.AddField('Cold Water Supply Temperature Schedule Name', ''); //! intentionally blank to get MAINS correlation
  obj.AddField('Zone Name', ZoneObj.Name);
  obj.AddField('Sensible Fraction Schedule Name', Name + ' Sensible fract sched');
  obj.AddField('Latent Fraction Schedule Name', Name + ' Latent fract sched');

  Obj := IDF.AddObject('Schedule:Compact');
  Obj.AddField('Name', Name + ' Latent fract sched');
  Obj.AddField('Schedule Type Limits Name', 'Fraction');
  Obj.AddField('Field 1', 'Through: 12/31');
  Obj.AddField('Field 2', 'For: AllDays');
  Obj.AddField('Field 3', 'Until: 24:00');
  Obj.AddField('Field 4', FloatToStr(LatentFraction));

  Obj := IDF.AddObject('Schedule:Compact');
  Obj.AddField('Name', Name + ' Sensible fract sched');
  Obj.AddField('Schedule Type Limits Name', 'Fraction');
  Obj.AddField('Field 1', 'Through: 12/31');
  Obj.AddField('Field 2', 'For: AllDays');
  Obj.AddField('Field 3', 'Until: 24:00');
  Obj.AddField('Field 4', FloatToStr(SensibleFraction));

  Obj := IDF.AddObject('Schedule:Compact');
  Obj.AddField('Name', Name + ' Temp Sched');
  Obj.AddField('Schedule Type Limits Name', 'Temperature');
  Obj.AddField('Field 1', 'Through: 12/31');
  Obj.AddField('Field 2', 'For: AllDays');
  Obj.AddField('Field 3', 'Until: 24:00');
  Obj.AddField('Field 4', FloatToStr(TargetTemperature));

  Obj := IDF.AddObject('Schedule:Compact');
  Obj.AddField('Name', Name + ' Hot Supply Temp Sched');
  Obj.AddField('Schedule Type Limits Name', 'Temperature');
  Obj.AddField('Field 1', 'Through: 12/31');
  Obj.AddField('Field 2', 'For: AllDays');
  Obj.AddField('Field 3', 'Until: 24:00');
  Obj.AddField('Field 4', FloatToStr(HotServiceTargetTemp));
end;

{ T_EP_WaterTank }

constructor T_EP_WaterTank.Create;
begin
  inherited;
  componenttype := 'WaterUse:Storage';
  ControlType := 'Passive';
  DemandControlType := 'Active';
end;

procedure T_EP_WaterTank.Finalize;
begin
  inherited;
end;

{ T_EP_Boiler}

constructor T_EP_Boiler.Create;
begin
  inherited;
  Capacity := -999.0;
  OutletTemperature := 82.2;
  SizingFactor := 1.0;
  ComponentType := 'Boiler:HotWater';
  ControlType := 'Active';
  DemandControlType := 'Passive';
  PerformanceCurve := '';
  PerfCurveName := '';
end;

procedure T_EP_Boiler.Finalize;
begin
  inherited;
end;

procedure T_EP_Boiler.SetSystem(SystemParameter: T_EP_System);
begin
  inherited;
  if Assigned(SystemParameter) then
  begin
    SystemValue := SystemParameter;
    Name := System.Name + ' Boiler'; // would be nice to have indication of Type in name
  end;
end;

procedure T_EP_Boiler.ToIDF;
var
  Obj: TEnergyPlusObject;
begin
  inherited;
  Obj := IDF.AddObject(ComponentType);
  Obj.AddField('Name', Name);
  Obj.AddField('Fuel Type', Fuel);
  if SameText(ComponentType, 'Boiler:HotWater') then
  begin
    if Capacity > 0.0 then
      Obj.AddField('Nominal Capacity', Capacity, '{W}')
    else
      Obj.AddField('Nominal Capacity', 'AUTOSIZE', '{W}');
    Obj.AddField('Nominal Thermal Efficiency', FloatToStr(Efficiency));
    Obj.AddField('Efficiency Curve Temperature Evaluation Variable', 'LeavingBoiler');
    if PerformanceCurve = 'Substitution' then
      Obj.AddField('Normalized Boiler Efficiency Curve Name', PerfCurveName)
    else if PerformanceCurve = 'NonCondensing' then
      Obj.AddField('Normalized Boiler Efficiency Curve Name', Name + ' Non-Condensing Boiler Curve')
    else if PerformanceCurve = 'Condensing' then
      Obj.AddField('Normalized Boiler Efficiency Curve Name', Name + ' Condensing Boiler Curve')
    else
      Obj.AddField('Normalized Boiler Efficiency Curve Name', '');
    Obj.AddField('Design Water Outlet Temperature', OutletTemperature, '{C}');
    Obj.AddField('Design Water Flow Rate', 'AUTOSIZE', '{m3/s}');
    Obj.AddField('Minimum Part Load Ratio', '0.0');
    Obj.AddField('Maximum Part Load Ratio', '1.1');
    Obj.AddField('Optimum Part Load Ratio', '1.0');
    Obj.AddField('Boiler Water Inlet Node Name', SupplyInletNode);
    Obj.AddField('Boiler Water Outlet Node Name', SupplyOutletNode);
    Obj.AddField('Water Outlet Upper Temperature Limit', '95.0', '{C}');
    Obj.AddField('Boiler Flow Mode', 'NotModulated', '{ ConstantFlow | LeavingSetpointModulated | NotModulated }');
    Obj.AddField('Parasitic Electric Load', 0.0 );
    Obj.AddField('Sizing Factor', SizingFactor, '');
    //performance curves
    if PerformanceCurve = 'NonCondensing' then
    begin
      Obj := IDF.AddObject('Curve:Cubic');
      Obj.AddField('Name', Name + ' Non-Condensing Boiler Curve');
      Obj.AddField('Coefficient1 Const', FloatToStr(0.626428326));//a
      Obj.AddField('Coefficient2 x', FloatToStr(0.645643582));//b
      Obj.AddField('Coefficient3 x**2', FloatToStr(-0.77720685));//c
      Obj.AddField('Coefficient4 x**3', FloatToStr(0.313806701));//d
      Obj.AddField('Minimum Value of x', FloatToStr(0.1));
      Obj.AddField('Maximum Value of x', FloatToStr(1.0));
    end;
    if PerformanceCurve = 'Condensing' then
    begin
      Obj := IDF.AddObject('Curve:Cubic');
      Obj.AddField('Name', Name + ' Condensing Boiler Curve');
      Obj.AddField('Coefficient1 Const', FloatToStr(0.9667));//a
      Obj.AddField('Coefficient2 x', FloatToStr(-0.1667));//b
      Obj.AddField('Coefficient3 x**2', FloatToStr(0.0));//c
      Obj.AddField('Coefficient4 x**3', FloatToStr(0.0));//d
      Obj.AddField('Minimum Value of x', FloatToStr(0.1));
      Obj.AddField('Maximum Value of x', FloatToStr(1.0));
    end;
  end
  else if SameText(ComponentType, 'Boiler:Steam') then
  begin
    Obj.AddField('Maximum Operating Pressure', '160000', '{kPa}');
    Obj.AddField('Theoretical Efficiency', FloatToStr(Efficiency));
    Obj.AddField('Design Outlet Steam Temperature', '115', '{C}');
    if Capacity > 0.0 then
      Obj.AddField('Nominal Capacity', Capacity, '{W}')
    else
      Obj.AddField('Nominal Capacity', 'AUTOSIZE', '{W}');
    Obj.AddField('Minimum Part Load Ratio', '0.00001');
    Obj.AddField('Maximum Part Load Ratio', '1.0');
    Obj.AddField('Optimum Part Load Ratio', '0.2');
    Obj.AddField('Coefficient 1 of Fuel Use Function of Part Load Ratio Curve', '0.8');
    Obj.AddField('Coefficient 2 of Fuel Use Function of Part Load Ratio Curve', '0.1');
    Obj.AddField('Coefficient 3 of Fuel Use Function of Part Load Ratio Curve', '0.1');
    Obj.AddField('Water Inlet Node Name', SupplyInletNode);
    Obj.AddField('Steam Outlet Node Name', SupplyOutletNode);
    //add steam properties
    with RefrigerantList do
    begin
       Sorted := true;
       Duplicates := dupIgnore;
       Add('Steam');
    end;
  end;
  //add EMS code for heat recovery chiller if applicable
  if HasHeatRecoveryChiller then
  begin
    //power sensor
    Obj := IDF.AddObject('EnergyManagementSystem:Sensor');
    Obj.AddField('Name', 'Boiler_Power');
    Obj.AddField('Output:Variable or Output:Meter Index Key Name', Name);
    Obj.AddField('Output:Variable or Output:Meter Name', 'Boiler Heating Output Rate');
    //gas rate sensor
    Obj := IDF.AddObject('EnergyManagementSystem:Sensor');
    Obj.AddField('Name', 'Boiler_Gas_Rate');
    Obj.AddField('Output:Variable or Output:Meter Index Key Name', Name);
    Obj.AddField('Output:Variable or Output:Meter Name', 'Boiler Gas Consumption Rate');
  end;
end;

{ T_EP_PurchHotWater }

constructor T_EP_PurchHotWater.Create;
begin
  inherited;
  ComponentType := 'DistrictHeating';
  ControlType := 'Active';
  DemandControlType := 'Passive';
end;

procedure T_EP_PurchHotWater.Finalize;
begin
  inherited;
end;

procedure T_EP_PurchHotWater.SetSystem(SystemParameter: T_EP_System);
begin
  inherited;
  if Assigned(SystemParameter) then
  begin
    SystemValue := SystemParameter;

    Name := System.Name + ' Purch HW';
  end;
end;

procedure T_EP_PurchHotWater.ToIDF;
var
  obj: TEnergyPlusObject;
begin
  inherited;
  obj := IDF.AddObject('DistrictHeating');
  Obj.AddField('Name', Name);
  obj.AddField('Hot Water Inlet Node Name', SupplyInletNode);
  Obj.AddField('Hot Water Outlet Node Name', SupplyOutletNode);
  Obj.AddField('Nominal Capacity', '10000000000.0', '{W}');

end;

{ T_EP_PurchChilledWater }

constructor T_EP_PurchChilledWater.Create;
begin
  inherited;
  ComponentType := 'DistrictCooling';
  ControlType := 'Active';
  DemandControlType := 'Passive';

end;

procedure T_EP_PurchChilledWater.Finalize;
begin
  inherited;
end;

procedure T_EP_PurchChilledWater.SetSystem(SystemParameter: T_EP_System);
begin
  inherited;
  if Assigned(SystemParameter) then
  begin
    SystemValue := SystemParameter;

    Name := System.Name + ' Purch CW';
  end;
end;

procedure T_EP_PurchChilledWater.ToIDF;
var
  obj: TEnergyPlusObject;
begin
  inherited;

  obj := IDF.AddObject('DistrictCooling');
  Obj.AddField('Name', Name);
  obj.AddField('Chilled Water Inlet Node Name', SupplyInletNode);
  Obj.AddField('Chilled Water Outlet Node Name', SupplyOutletNode);
  Obj.AddField('Nominal Capacity', '10000000000.0', '{W}');

end;

{ T_EP_IceStorage }

constructor T_EP_IceStorage.Create;
begin
  inherited;
  ComponentType := 'ThermalStorage:Ice:Simple';
  ControlType := 'Passive';
  DemandControlType := 'Passive';
  Typ := 'INTERNAL ICE-ON-COIL';
end;

procedure T_EP_IceStorage.Finalize;
begin
  inherited;
end;

procedure T_EP_IceStorage.SetSystem(SystemParameter: T_EP_System);
begin
  inherited;
  if Assigned(SystemParameter) then
  begin
    SystemValue := SystemParameter;
    Name := System.Name + ' Ice Storage';
  end;
end;

procedure T_EP_IceStorage.ToIDF;
var
  StorageType: string;
  Obj: TEnergyPlusObject;
begin
  inherited;

  if Typ = 'INTERNAL ICE-ON-COIL' then
    StorageType := 'IceOnCoilInternal'
  else if Typ = 'EXTERNAL ICE-ON-COIL' then
    StorageType := 'IceOnCoilExternal';

  Obj := IDF.AddObject('ThermalStorage:Ice:Simple');
  Obj.AddField('Name', Name);
  Obj.AddField('Ice Storage Type', StorageType, '{IceOnCoilInternal | IceOnCoilExternal}');
  Obj.AddField('Capacity', FloatToStr(Capacity), '{GJ}');
  Obj.AddField('Inlet Node Name', SupplyInletNode);
  Obj.AddField('Outlet Node Name', SupplyOutletNode);

  {
  To use this component in a chilled water plant, the following items must be considered:
  1. As mentioned above, the THERMAL STORAGE:ICE:SIMPLE component should be
  place in the chilled water loop supply side outlet branch, following by a PIPE
  component.
  2. Use the COMPONENT SETPOINT BASED OPERATION plant operation scheme
  type, and vary chiller and storage tank setpoints to control operation. List the
  chiller(s) first and then the storage tank.
  3. Using a SET POINT MANAGER:SCHEDULED, vary the setpoints on the chiller outlet
  node, the ice storage outlet node, and the chilled water plant loop supply outlet node.
  Example setpoints to use for various modes of operation are shown in the table
  below:
  4. In the PLANT LOOP object, the "Minimum Loop Temperature" must be set equal to
  or less than the lowest setpoint to be used anywhere in the loop.
  5. Because the storage tank is on the supply side of the loop, the chilled water pump
  operation must be CONTINUOUS and must be scheduled to run for both charging
  and discharging. If INTERMITTENT pump operation is used, the pump will not come
  on to start the charging process if there is no coil demand at that time.
  }

end;

{ T_EP_WatersideEconomizer }

constructor T_EP_WatersideEconomizer.Create;
begin
  inherited;
  ComponentType := 'HeatExchanger:FluidToFluid';
  ControlType := 'Passive';
  DemandControlType := 'Passive';
end;

procedure T_EP_WatersideEconomizer.SetSystem(SystemParameter: T_EP_System);
begin
  inherited;
  if Assigned(SystemParameter) then
  begin
    SystemValue := SystemParameter;
    Name := System.Name + ' HX';
    DemandInletNode := Name + ' HX Inlet Node';
    DemandOutletNode := Name + ' HX Outlet Node';
  end;
end;

procedure T_EP_WatersideEconomizer.Finalize;
begin
  inherited;
end;

procedure T_EP_WatersideEconomizer.ToIDF;
var
  Obj: TEnergyPlusObject;
begin
  inherited;
  Obj := IDF.AddObject(ComponentType);
  Obj.AddField('Name', Name);
  Obj.AddField('Availability Schedule', 'ALWAYS_ON');
  Obj.AddField('Loop Demand Side Inlet Node Name', DemandInletNode);
  Obj.AddField('Loop Demand Side Outlet Node Name', DemandOutletNode);
  Obj.AddField('Loop Demand Side Design Flow Rate', 'AutoSize', '{m3/s}');
  Obj.AddField('Loop Supply Side Inlet Node Name', SupplyInletNode);
  Obj.AddField('Loop Supply Side Outlet Node Name', SupplyOutletNode);
  Obj.AddField('Loop Supply Side Design Flow Rate', 'AutoSize', '{m3/s}');
  Obj.AddField('Heat Exchanger Model Type', HeatExchangerType, '{ CrossFlowBothUnMixed | CrossFlowBothMixed | CrossFlowSupplyMixedDemandUnMixed | CrossFlowSupplyUnMixedDemandMixed | CounterFlow | ParallelFlow | Ideal }');
  Obj.AddField('Heat Exchanger U-Factor Times Area Value', 'AutoSize', '{W/K}');
  Obj.AddField('Control Type', 'CoolingDifferentialOnOff', '');
  Obj.AddField('Heat Exchanger Setpoint Node Name', '');
  Obj.AddField('Minimum Temperature Difference to Activate Heat Exchanger', '2.0', '{delta C}');
  Obj.AddField('Heat Transfer Metering End Use Type', '{ FreeCooling | HeatRecovery | HeatRejection | HeatRecoveryForCooling | HeatRecoveryForHeating | LoopToLoop }');
end;

{ T_EP_CoolingTower }

constructor T_EP_CoolingTower.Create;
begin
  inherited;
  Typ := 'SingleSpeed'; // if TType gets set, need to also set ComponentType, Or use property to read ComponentType
  ComponentType := 'CoolingTower:SingleSpeed';
  ControlType := 'Passive';
  DemandControlType := 'Passive';
end;

procedure T_EP_CoolingTower.SetSystem(SystemParameter: T_EP_System);
begin
  inherited;
  if Assigned(SystemParameter) then
  begin
    SystemValue := SystemParameter;
    Name := System.Name + ' CoolTower';
  end;
end;

procedure T_EP_CoolingTower.SetType(TypeParameter: string);
begin
  TypeValue := TypeParameter;
  if Typ = 'SingleSpeed' then
    ComponentType := 'CoolingTower:SingleSpeed';
  if Typ = 'TwoSpeed' then
    ComponentType := 'CoolingTower:TwoSpeed';
  if Typ = 'VariableSpeed' then
    ComponentType := 'CoolingTower:VariableSpeed';

end;

procedure T_EP_CoolingTower.Finalize;
begin
  inherited;
  ControlType := 'Passive';
  DemandControlType := 'Active';
  if Typ = 'SingleSpeed' then
    ComponentType := 'CoolingTower:SingleSpeed'
  else if Typ = 'TwoSpeed' then
    ComponentType := 'CoolingTower:TwoSpeed'
  else
    ComponentType := 'CoolingTower:VariableSpeed'
end;

procedure T_EP_CoolingTower.ToIDF;
var
  Obj: TEnergyPlusObject;
begin
  Finalize;
  if Typ = 'SingleSpeed' then
  begin
    if SameText(EPSettings.VersionOfEnergyPlus , '8.0') then
    begin
      Obj := IDF.AddObject('CoolingTower:SingleSpeed');
      Obj.AddField('Name', Name);
      Obj.AddField('Water Inlet Node Name', SupplyInletNode);
      Obj.AddField('Water Outlet Node Name', SupplyOutletNode);
      Obj.AddField('Design Water Flow Rate', 'AUTOSIZE', '{m3/s}');
      Obj.AddField('Design Air Flow Rate', 'AUTOSIZE', '{m3/s}');
      Obj.AddField('Fan Power At Design Air Flow Rate', 'AUTOSIZE', '{W}');
      Obj.AddField('U-Factor Times Area Value at Design Air Flow Rate', 'AUTOSIZE', '{W/K}');
      Obj.AddField('Air Flow Rate In Free Convection Regime', 'AUTOSIZE', '{m3/s}');
      Obj.AddField('U-Factor Times Area Value at Free Convection Air Flow Rate', 'AUTOSIZE', '{W/K}');
      Obj.AddField('Performance Input Method', 'UFactorTimesAreaAndDesignWaterFlowRate', '{NominalCapacity | UFactorTimesAreaAndDesignWaterFlowRate}');
      Obj.AddField('Nominal Capacity', '', '{W}');
      Obj.AddField('Free Convection Capacity', '', '{W}');
      Obj.AddField('Basin Heater Capacity', '0.0', '{W/K}');
      Obj.AddField('Basin Heater Setpoint Temperature', '2.0', '{C}');
      Obj.AddField('Basin Heater Operating Schedule Name', '');
      Obj.AddField('Evaporation Loss Mode', 'SaturatedExit', '{LossFactor | SaturatedExit}');
      Obj.AddField('Evaporation Loss Factor', '');
      Obj.AddField('Drift Loss Percent', 0.008);
      Obj.AddField('Blowdown Calculation Mode', 'ConcentrationRatio' , '{ConcentrationRatio | ScheduledRate}');
      Obj.AddField('Blowdown Concentration Ratio', 3.0);
      Obj.AddField('Blowdown Makeup Water Usage Schedule Name', '');
      Obj.AddField('Supply Water Storage Tank Name', '');
      Obj.AddField('Outdoor Air Inlet Node Name', Name + ' OA Ref Node');
      Obj.AddField('Capacity Control', 'FanCycling', '{ FanCycling |  FluidBypass }');
      Obj.AddField('Number of Cells', '1.0', '{}');
      Obj.AddField('Cell Control', 'MinimalCell', '{MinimalCell | MaximalCell}');
      Obj.AddField('Cell Minimum Water Flow Rate Fraction', '0.33', '{}');
      Obj.AddField('Cell Maximum Water Flow Rate Fraction', '2.5', '{}');
      Obj.AddField('Sizing Factor', 1.0, '{}');
    end
    else if SameText(EPSettings.VersionOfEnergyPlus , '8.1') then
    begin
      Obj := IDF.AddObject('CoolingTower:SingleSpeed');
      Obj.AddField('Name', Name);
      Obj.AddField('Water Inlet Node Name', SupplyInletNode);
      Obj.AddField('Water Outlet Node Name', SupplyOutletNode);
      Obj.AddField('Design Water Flow Rate', 'AutoSize', '{m3/s}');
      Obj.AddField('Design Air Flow Rate', 'AutoSize', '{m3/s}');
      Obj.AddField('Design Fan Power', 'AutoSize', '{W}');
      Obj.AddField('Design U-Factor Times Area Value', 'AutoSize', '{W/K}');
      Obj.AddField('Free Convection Air Flow Rate', 'AutoCalculate', '{m3/s}');
      Obj.AddField('Free Convection Air Flow Rate Sizing Factor', '');
      Obj.AddField('Free Convection U-Factor Times Area Value', 'AutoCalculate', '{W/K}');
      Obj.AddField('Free Convection U-Factor Times Area Value Sizing Factor', '');
      Obj.AddField('Performance Input Method', 'UFactorTimesAreaAndDesignWaterFlowRate', '{UFactorTimesAreaAndDesignWaterFlowRate | NominalCapacity}');
      Obj.AddField('Heat Rejection Capacity and Nominal Capacity Sizing Ratio', '1.25');
      Obj.AddField('Nominal Capacity', '', '{W}');
      Obj.AddField('Free Convection Capacity', '', '{W}');
      Obj.AddField('Free Convection Nominal Capacity Sizing Factor', '');
      Obj.AddField('Basin Heater Capacity', '0.0', '{W/K}');
      Obj.AddField('Basin Heater Setpoint Temperature', '2.0', '{C}');
      Obj.AddField('Basin Heater Operating Schedule Name', '');
      Obj.AddField('Evaporation Loss Mode', 'SaturatedExit', '{LossFactor | SaturatedExit}');
      Obj.AddField('Evaporation Loss Factor', '');
      Obj.AddField('Drift Loss Percent', 0.008);
      Obj.AddField('Blowdown Calculation Mode', 'ConcentrationRatio' , '{ConcentrationRatio | ScheduledRate}');
      Obj.AddField('Blowdown Concentration Ratio', 3.0);
      Obj.AddField('Blowdown Makeup Water Usage Schedule Name', '');
      Obj.AddField('Supply Water Storage Tank Name', '');
      Obj.AddField('Outdoor Air Inlet Node Name', Name + ' OA Ref Node');
      Obj.AddField('Capacity Control', 'FanCycling', '{ FanCycling |  FluidBypass }');
      Obj.AddField('Number of Cells', '1.0', '{}');
      Obj.AddField('Cell Control', 'MinimalCell', '{MinimalCell | MaximalCell}');
      Obj.AddField('Cell Minimum Water Flow Rate Fraction', '0.33', '{}');
      Obj.AddField('Cell Maximum Water Flow Rate Fraction', '2.5', '{}');
      Obj.AddField('Sizing Factor', 1.0, '{}');
    end;
    //outdoor air node
    Obj := IDF.AddObject('OutdoorAir:Node');
    Obj.AddField('Name', Name + ' OA Ref Node');
  end
  else if Typ = 'TwoSpeed' then
  begin
    if SameText(EPSettings.VersionOfEnergyPlus , '8.0') then
    begin
      Obj := IDF.AddObject('CoolingTower:TwoSpeed');
      Obj.AddField('Name', Name);
      Obj.AddField('Water Inlet Node Name', SupplyInletNode);
      Obj.AddField('Water Outlet Node Name', SupplyOutletNode);
      Obj.AddField('Design Water Flow Rate', 'AUTOSIZE', '{m3/s}');
      Obj.AddField('Air Flow Rate at High Fan Speed', 'AUTOSIZE', '{m3/s}');
      Obj.AddField('Fan Power at High Fan Speed', 'AUTOSIZE', '{W}');
      Obj.AddField('U-Factor Times Area Value at High Fan Speed', 'AUTOSIZE', '{W/K}');
      Obj.AddField('Air Flow Rate at Low Fan Speed', 'AUTOSIZE', '{m3/s}');
      Obj.AddField('Fan Power at Low Fan Speed', 'AUTOSIZE', '{W}');
      Obj.AddField('U-Factor Times Area Value at Low Fan Speed', 'AUTOSIZE', '{W/K}');
      Obj.AddField('Air Flow Rate in Free Convection Regime', 'AUTOSIZE', '{m3/s}');
      Obj.AddField('U-Factor Times Area Value at Free Convection Air Flow Rate', 'AUTOSIZE', '{W/K}');
      Obj.AddField('Performance Input Method', 'UFactorTimesAreaAndDesignWaterFlowRate', '{NominalCapacity | UFactorTimesAreaAndDesignWaterFlowRate}');
      Obj.AddField('High Speed Nominal Capacity', '', '{W}');
      Obj.AddField('Low Speed Nominal Capacity', '', '{W}');
      Obj.AddField('Free Convection Capacity', '', '{W}');
      Obj.AddField('Basin Heater Capacity', '0.0', '{W/K}');
      Obj.AddField('Basin Heater Setpoint Temperature', '2.0', '{C}');
      Obj.AddField('Basin Heater Operating Schedule Name', '');
      Obj.AddField('Evaporation Loss Mode', 'SaturatedExit', '{LossFactor | SaturatedExit}');
      Obj.AddField('Evaporation Loss Factor', 0.2);
      Obj.AddField('Drift Loss Percent', 0.008);
      Obj.AddField('Blowdown Calculation Mode', 'ConcentrationRatio', '{ConcentrationRatio | ScheduledRate}');
      Obj.AddField('Blowdown Concentration Ratio', 3.0);
      Obj.AddField('Blowdown Makeup Water Usage Schedule Name' , '');
      Obj.AddField('Supply Water Storage Tank Name' , '');
      Obj.AddField('Outdoor Air Inlet Node Name', Name + ' OA Ref Node');
      Obj.AddField('Number of Cells', '1.0', '{}');
      Obj.AddField('Cell Control', 'MinimalCell', '{MinimalCell | MaximalCell}');
      Obj.AddField('Cell Minimum Water Flow Rate Fraction', '0.33', '{}');
      Obj.AddField('Cell Maximum Water Flow Rate Fraction', '2.5', '{}');
      Obj.AddField('Sizing Factor', 1.0, '{}');
    end
    else if SameText(EPSettings.VersionOfEnergyPlus , '8.1') then
    begin
      Obj := IDF.AddObject('CoolingTower:TwoSpeed');
      Obj.AddField('Name', Name);
      Obj.AddField('Water Inlet Node Name', SupplyInletNode);
      Obj.AddField('Water Outlet Node Name', SupplyOutletNode);
      Obj.AddField('Design Water Flow Rate', 'AutoSize', '{m3/s}');
      Obj.AddField('High Fan Speed Air Flow Rate', 'AutoSize', '{m3/s}');
      Obj.AddField('High Fan Speed Fan Power', 'AutoSize', '{W}');
      Obj.AddField('High Fan Speed U-Factor Times Area Value', 'AutoSize', '{W/K}');
      Obj.AddField('Low Fan Speed Air Flow Rate', 'AutoCalculate', '{m3/s}');
      Obj.AddField('Low Fan Speed Air Flow Rate Sizing Factor', '');
      Obj.AddField('Low Fan Speed Fan Power', 'AutoCalculate', '{W}');
      Obj.AddField('Low Fan Speed Fan Power Sizing Factor', '');
      Obj.AddField('Low Fan Speed U-Factor Times Area Value', 'AutoCalculate', '{W/K}');
      Obj.AddField('Low Fan Speed U-Factor Times Area Sizing Factor', '', '{W/K}');
      Obj.AddField('Free Convection Regime Air Flow Rate', 'AutoCalculate', '{m3/s}');
      Obj.AddField('Free Convection Regime Air Flow Rate Sizing Factor', '', '{m3/s}');
      Obj.AddField('Free Convection Regime U-Factor Times Area Value', 'AutoCalculate', '{W/K}');
      Obj.AddField('Free Convection Regime U-Factor Times Area Value Sizing Factor', '0.1', '{W/K}');
      Obj.AddField('Performance Input Method', 'UFactorTimesAreaAndDesignWaterFlowRate', '{UFactorTimesAreaAndDesignWaterFlowRate | NominalCapacity}');
      Obj.AddField('Heat Rejection Capacity and Nominal Capacity Sizing Ratio', '1.25');
      Obj.AddField('High Speed Nominal Capacity', '', '{W}');
      Obj.AddField('Low Speed Nominal Capacity', '', '{W}');
      Obj.AddField('Low Speed Nominal Capacity Sizing Factor', '');
      Obj.AddField('Free Convection Nominal Capacity', '', '{W}');
      Obj.AddField('Free Convection Nominal Capacity Sizing Factor', '');
      Obj.AddField('Basin Heater Capacity', '0.0', '{W/K}');
      Obj.AddField('Basin Heater Setpoint Temperature', '2.0', '{C}');
      Obj.AddField('Basin Heater Operating Schedule Name', '');
      Obj.AddField('Evaporation Loss Mode', 'SaturatedExit', '{LossFactor | SaturatedExit}');
      Obj.AddField('Evaporation Loss Factor', 0.2);
      Obj.AddField('Drift Loss Percent', 0.008);
      Obj.AddField('Blowdown Calculation Mode', 'ConcentrationRatio', '{ConcentrationRatio | ScheduledRate}');
      Obj.AddField('Blowdown Concentration Ratio', 3.0);
      Obj.AddField('Blowdown Makeup Water Usage Schedule Name' , '');
      Obj.AddField('Supply Water Storage Tank Name' , '');
      Obj.AddField('Outdoor Air Inlet Node Name', Name + ' OA Ref Node');
      Obj.AddField('Number of Cells', '1.0', '{}');
      Obj.AddField('Cell Control', 'MinimalCell', '{MinimalCell | MaximalCell}');
      Obj.AddField('Cell Minimum Water Flow Rate Fraction', '0.33', '{}');
      Obj.AddField('Cell Maximum Water Flow Rate Fraction', '2.5', '{}');
      Obj.AddField('Sizing Factor', 1.0, '{}');
    end;
    //outdoor air node
    Obj := IDF.AddObject('OutdoorAir:Node');
    Obj.AddField('Name', Name + ' OA Ref Node');
  end
  else
  begin
    Obj := IDF.AddObject('CoolingTower:VariableSpeed');
    Obj.AddField('Name', Name);
    Obj.AddField('Water Inlet Node Name', SupplyInletNode);
    Obj.AddField('Water Outlet Node Name', SupplyOutletNode);
    Obj.AddField('Tower Model Type', 'CoolToolsCrossFlow');
    Obj.AddField('Tower Model Coefficient Name', '');
    Obj.Addfield('Design Inlet Air Wet-Bulb Temperature', 25.5556, '{C}');
    Obj.Addfield('Design Approach Temperature', 3.8889, '{C}');
    Obj.Addfield('Design Range Temperature', 5.5556, '{C}');
    Obj.AddField('Design Water Flow Rate', 'AUTOSIZE', '{m3/s}');
    Obj.AddField('Design Air Flow Rate', 'AUTOSIZE', '{m3/s}');
    Obj.AddField('Design Fan Power', 'AUTOSIZE', '{W}');
    Obj.AddField('Fan Power Ratio Function of Air Flow Rate Ratio Curve Name', Name + 'FanRatioCurve', '{m3/s}');
    Obj.AddField('Minimum Air Flow Ratio', 0.2);
    Obj.AddField('Fraction of Tower Capacity in Free Convection Regime', 0.125);
    Obj.Addfield('Basin Heater Capacity', 0.0, '{W/K}');
    Obj.Addfield('Basin Heater Setpoint Temperature', 2.0, '{C}');
    Obj.Addfield('Basin Heater Operating Schedule Name', '');
    Obj.AddField('Evaporation Loss Mode', 'SaturatedExit', '{LossFactor | SaturatedExit}');
    Obj.AddField('Evaporation Loss Factor', 0.2);
    Obj.AddField('Drift Loss Percent', 0.008);
    Obj.AddField('Blowdown Calculation Mode', 'ConcentrationRatio', '{ConcentrationRatio | ScheduledRate}');
    Obj.AddField('Blowdown Concentration Ratio', 3.0);
    Obj.AddField('Blowdown Makeup Water Usage Schedule Name', '');
    Obj.AddField('Supply Water Storage Tank Name', '');
    Obj.AddField('Outdoor Air Inlet Node Name' , Name + ' OA Ref Node');
    Obj.AddField('Number of Cells', '1.0', '{}');
    Obj.AddField('Cell Control', 'MinimalCell', '{MinimalCell | MaximalCell}');
    Obj.AddField('Cell Minimum Water Flow Rate Fraction', '0.33', '{}');
    Obj.AddField('Cell Maximum Water Flow Rate Fraction', '2.5', '{}');
    Obj.AddField('Sizing Factor', 1.0, '{}');
    //fan ratio curve
    Obj := IDF.AddObject('Curve:Cubic');
    Obj.AddField('Name', Name + 'FanRatioCurve');
    Obj.AddField('Coefficient 1 {x^0}', -0.00931516301535329);
    Obj.AddField('Coefficient 2 {x^1}', 0.0512333965844443);
    Obj.AddField('Coefficient 3 {x^2}', -0.0838364671381841);
    Obj.AddField('Coefficient 4 {x^3}', 1.04191823356909);
    Obj.AddField('Minimum Value of x', 0.15);
    Obj.AddField('Maximum Value of x', 1.0);
    //outdoor air node
    Obj := IDF.AddObject('OutdoorAir:Node');
    Obj.AddField('Name', Name + ' OA Ref Node');
  end;
end;

constructor T_EP_FluidCooler.Create;
begin
  inherited;
  ComponentType := 'FluidCooler:SingleSpeed';
  ControlType := 'Passive';
  Typ := 'Dry';
  Capacity := -9999.0;
end;

procedure T_EP_FluidCooler.Finalize;
begin
  inherited;
end;

procedure T_EP_FluidCooler.SetSystem(SystemParameter: T_EP_System);
begin
  inherited;
  if Assigned(SystemParameter) then
  begin
    SystemValue := SystemParameter;
    Name := System.Name + ' FluidCooler';
  end;
end;

procedure T_EP_FluidCooler.SetType(TypeParameter: string);
begin
  TypeValue := TypeParameter;
  if Typ = 'Dry' then
    ComponentType := 'FluidCooler:SingleSpeed';
  if Typ = 'Wet' then
    ComponentType := 'EvaporativeFluidCooler:SingleSpeed';
end;

procedure T_EP_FluidCooler.ToIDF;
var
  Obj: TEnergyPlusObject;
begin
  Finalize;
  Obj := IDF.AddObject(ComponentType);
  Obj.AddField('Name', Name);
  Obj.AddField('Water Inlet Node Name', SupplyInletNode);
  Obj.AddField('Water Outlet Node Name', SupplyOutletNode);
  if SameText(ComponentType, 'FluidCooler:SingleSpeed') then
  begin
    if Capacity > 0 then
    begin
      Obj.AddField('Performance Input Method', 'NominalCapacity');
      Obj.AddField('UA Value at Design Air Flow Rate', '', '{W/K}');
      Obj.AddField('FluidCooler Nominal Capacity', Capacity, '{W}');
    end
    else
    begin
      Obj.AddField('Performance Input Method', 'UFactorTimesAreaAndDesignWaterFlowRate');
      Obj.AddField('UA Value at Design Air Flow Rate', 'AUTOSIZE', '{W/K}');
      Obj.AddField('FluidCooler Nominal Capacity', '1000000', '{W}');
    end;
    Obj.AddField('Design Entering Water Temperature', '51.67', '{C}');
    Obj.AddField('Design Entering Air Temperature', '35.0', '{C}');
    Obj.AddField('Design Entering Air Wet-Bulb Temperature', '25.6', '{C}');
    if T_EP_LiquidSystem(SystemValue).DesignFlowRate > 0 then
      Obj.AddField('Design Water Flow Rate', T_EP_LiquidSystem(SystemValue).DesignFlowRate, '{m3/s}')
    else
      Obj.AddField('Design Water Flow Rate', 'AUTOSIZE', '{m3/s}');
    Obj.AddField('Design Air Flow Rate', 'AUTOSIZE', '{m3/s}');
    Obj.AddField('Fan Power at Design Air Flow Rate', 'AUTOSIZE', '{W}');
  end
  else if SameText(ComponentType, 'EvaporativeFluidCooler:SingleSpeed') then
  begin
    Obj.AddField('Design Air Flow Rate', 'AUTOSIZE', '{m3/s}');
    Obj.AddField('Fan Power at Design Air Flow Rate', 'AUTOSIZE', '{W}');
    Obj.AddField('Design Spray Water Flow Rate', '0.01', '{W}');
    Obj.AddField('Performance Input Method', 'UFactorTimesAreaAndDesignWaterFlowRate');
    Obj.AddField('Outdoor Air Inlet Node Name', Name + ' OA Ref Node');
    if SameText(EPSettings.VersionOfEnergyPlus, '8.1') then
      Obj.AddField('Heat Rejection Capacity and Nominal Capacity Sizing Ratio', '1.25');
    Obj.AddField('Standard Design Capacity', '', '{W/K}');
    Obj.AddField('U-factor Times Area Value at Design Air Flow Rate', 'AUTOSIZE', '{W/K}');
    Obj.AddField('Design Water Flow Rate', 'AUTOSIZE', '{m3/s}');
    Obj.AddField('User Specified Design Capacity', '', '{W}');
    Obj.AddField('Design Entering Water Temperature', '', '{C}');
    Obj.AddField('Design Entering Air Temperature', '', '{C}');
    Obj.AddField('Design Entering Air Wet-bulb Temperature', '', '{C}');
    Obj.AddField('Capacity Control', 'FanCycling', '{FanCycling | FluidBypass}');
    Obj.AddField('Sizing Factor', '1.0', '{}');
    Obj.AddField('Evaporation Loss Mode', 'SaturatedExit', '{LossFactor | SaturatedExit}');
    Obj.AddField('Evaporation Loss Factor', '0.2');
    Obj.AddField('Drift Loss Percent', '0.008');
    Obj.AddField('Blowdown Calculation Mode', 'ConcentrationRatio', '{ConcentrationRatio | ScheduledRate}');
    Obj.AddField('Blowdown Concentration Ratio', '3.0');
    Obj.AddField('Blowdown Makeup Water Usage Schedule Name', '');
    Obj.AddField('Supply Water Storage Tank Name', '');
    //outdoor air node
    Obj := IDF.AddObject('OutdoorAir:Node');
    Obj.AddField('Name', Name + ' OA Ref Node');
  end;
end;

{ T_EP_GroundSourceHeatExchanger }

constructor T_EP_GroundSourceHeatExchanger.Create;
begin
  inherited;
  GroundTemp := 13.33;
  ComponentType := 'GroundHeatExchanger:Vertical';
  ControlType := 'Passive';
  DemandControlType := 'Passive';
end;

procedure T_EP_GroundSourceHeatExchanger.Finalize;
begin
  inherited;
end;

procedure T_EP_GroundSourceHeatExchanger.SetSystem(SystemParameter: T_EP_System);
begin
  inherited;
  if Assigned(SystemParameter) then
  begin
    SystemValue := SystemParameter;

    Name := System.Name + ' Ground Source Heat Exchanger';
  end;
end;

procedure T_EP_GroundSourceHeatExchanger.ToIDF;
var
  preProcMacro: TPreProcMacro;
  aStringList: TStringList;
  aString: string;
begin
  preProcMacro := TPreProcMacro.Create('include/HPBGroundHX.imf');
  // ksb: get the Ground HX as it is defined in the include file
  try
    aString := preProcMacro.getDefinedText(IMFDef);
    aString := ReplaceRegExpr('#{name}',aString,Name,false);
    aString := ReplaceRegExpr('#{inlet_node}',aString,SupplyInletNode,false);
    aString := ReplaceRegExpr('#{outlet_node}',aString,SupplyOutletNode,false);
    aString := ReplaceRegExpr('#{ground_temp}',aString,FloatToStr(GroundTemp),false);
    // ejb: remove blank lines
    aString := ReplaceRegExpr(#$D#$A#$D#$A#$D#$A, aString, '', False);
    // ksb: I think "IDF" will free aStringList when it is no longer needed
    // ksb: I will not free here, is this the correct way or is this a memory leak?

    aStringList := TStringList.Create;
    aStringList.Add(aString);
    IDF.AddStringList(aStringList);
  finally
    preProcMacro.Free;
  end;
end;

{ T_EP_RefrigerationCompressor }

constructor T_EP_RefrigerationCompressor.Create;
begin
  inherited;
  DataSetKey := '';
  ComponentType := 'Refrigeration:Compressor';
end;

procedure T_EP_RefrigerationCompressor.Finalize;
begin
  inherited;
  Name := System.Name + '_RefrigerationCompressor:' + IntToStr(CompressorID);
end;

procedure T_EP_RefrigerationCompressor.SetSystem(SystemParameter: T_EP_System);
begin
  inherited;
  if Assigned(SystemParameter) then
  begin
    SystemValue := SystemParameter;
  end;
end;

procedure T_EP_RefrigerationCompressor.ToIDF;
var
  RefrigCompressorPreProcMacro: TPreProcMacro;
  RefrigCompressorStringList: TStringList;
  RefrigCompressorString: string;
begin
  inherited;
  Finalize;
  IDF.AddComment('');// intentional blank line
  IDF.AddComment(Name);
  RefrigCompressorPreProcMacro := TPreProcMacro.Create('include/HPBRefrigerationCompressors.imf');
  try
    RefrigCompressorString := RefrigCompressorPreProcMacro.getDefinedText(DataSetKey);
    RefrigCompressorString := ReplaceRegExpr('#{Name}', RefrigCompressorString, Name, False);
    RefrigCompressorString := ReplaceRegExpr('#{PowerCurveName}', RefrigCompressorString, Name + '_PowerCurve', False);
    RefrigCompressorString := ReplaceRegExpr('#{CapacityCurveName}', RefrigCompressorString, Name + '_CapacityCurve', False);
    RefrigCompressorString := ReplaceRegExpr(#$D#$A#$D#$A#$D#$A, RefrigCompressorString, '', False);
    RefrigCompressorStringList := TStringList.Create;
    RefrigCompressorStringList.Add(RefrigCompressorString);
    IDF.AddStringList(RefrigCompressorStringList);
  finally
    RefrigCompressorPreProcMacro.Free;
  end;
end;

{ T_EP_RefrigerationCondenser }

constructor T_EP_RefrigerationCondenser.Create;
begin
  inherited;
end;

procedure T_EP_RefrigerationCondenser.SetHeatRejection(HeatRejectionType: string);
var
  Component: THVACComponent;
begin
  if SameText(HeatRejectionType, 'AirCooled') then
  begin
    ComponentType := 'Refrigeration:Condenser:AirCooled';
    HeatRejectionValue := 'AirCooled';
    if Assigned(HeatRejectionLoop) then HeatRejectionLoop.Free;
  end
  else if SameText(HeatRejectionType, 'EvaporativelyCooled') then
  begin
    ComponentType := 'Refrigeration:Condenser:EvaporativeCooled';
    HeatRejectionValue := 'EvaporativelyCooled';
    if Assigned(HeatRejectionLoop) then HeatRejectionLoop.Free;
  end
  else if (SameText(HeatRejectionType, 'WaterCooledSingleSpeedTower') or
    SameText(HeatRejectionType, 'WaterCooledTwoSpeedTower') or
    SameText(HeatRejectionType, 'WaterCooledVariableSpeedTower')) then
  begin
    ComponentType := 'Refrigeration:Condenser:WaterCooled';
    HeatRejectionValue := 'WaterCooled';
    DemandControlType := 'Active';
    DemandInletNode := Name + ' Water Inlet Node';
    DemandOutletNode := Name + ' Water Outlet Node';
    if not Assigned(HeatRejectionLoop) then
    begin
      HeatRejectionLoop := T_EP_CondenserSystem.Create;
      HeatRejectionLoop.Name := Name + 'Loop';
      HeatRejectionLoop.SystemType := cSystemTypeCondTower;
      HeatRejectionLoop.AddDemandComponent(Self);
      Component := T_EP_Pump.Create;
      T_EP_Pump(Component).Typ := 'Constant';
      HeatRejectionLoop.AddSupplyComponent(Component);
      Component := T_EP_CoolingTower.Create;
      if SameText(HeatRejectionType, 'WaterCooledSingleSpeedTower') then
      begin
        T_EP_CoolingTower(Component).Typ := 'SingleSpeed';
      end
      else if SameText(HeatRejectionType, 'WaterCooledTwoSpeedTower') then
      begin
        T_EP_CoolingTower(Component).Typ := 'TwoSpeed';
      end
      else if SameText(HeatRejectionType, 'WaterCooledVariableSpeedTower') then
      begin
        T_EP_CoolingTower(Component).Typ := 'VariableSpeed';
      end;
      THVACComponent(Component).ControlType := 'Active';
      HeatRejectionLoop.AddSupplyComponent(Component);
    end;
  end;
end;

procedure T_EP_RefrigerationCondenser.Finalize;
begin
  inherited;
end;

procedure T_EP_RefrigerationCondenser.SetSystem(SystemParameter: T_EP_System);
begin
  inherited;
  if Assigned(SystemParameter) then
  begin
    SystemValue := SystemParameter;
    Name := System.Name + '_RefrigCond';
  end;
end;

procedure T_EP_RefrigerationCondenser.ToIDF;
var
  Obj: TEnergyPlusObject;
  RefrigCondenserPreProcMacro: TPreProcMacro;
  RefrigCondenserStringList: TStringList;
  RefrigCondenserString: string;
begin
  inherited;
  Finalize;
  IDF.AddComment('');   // intentional blank line
  IDF.AddComment(Name);
  RefrigCondenserPreProcMacro := TPreProcMacro.Create('include/HPBRefrigerationCondensers.imf');
  try
    RefrigCondenserString := RefrigCondenserPreProcMacro.getDefinedText(DataSetKey);
    RefrigCondenserString := ReplaceRegExpr('#{Name}', RefrigCondenserString, Name, False);
    if SameText(HeatRejectionValue, 'AirCooled') then
    begin
      RefrigCondenserString := ReplaceRegExpr('#{HeatRejectionCurveName}', RefrigCondenserString, Name + '_HeatRejectionCurve', False);
      RefrigCondenserString := ReplaceRegExpr('#{AirInletNodeName}', RefrigCondenserString, Name + '_CondenserNode', False);
    end
    else if SameText(HeatRejectionValue, 'EvaporativelyCooled') then
    begin
      RefrigCondenserString := ReplaceRegExpr('#{AirInletNodeName}', RefrigCondenserString, Name + '_CondenserNode', False);
    end
    else if SameText(HeatRejectionValue, 'WaterCooled') then
    begin
      RefrigCondenserString := ReplaceRegExpr('#{DemandInletNode}', RefrigCondenserString, DemandInletNode, False);
      RefrigCondenserString := ReplaceRegExpr('#{DemandOutletNode}', RefrigCondenserString, DemandOutletNode, False);
    end;
    //fan type
    if not SameText(FanType, 'NotSet') then
    begin
      RefrigCondenserString := ReplaceRegExpr('#{FanType}\w*', RefrigCondenserString, FanType, False);
    end
    else
    begin
      RefrigCondenserString := ReplaceRegExpr('#{FanType}', RefrigCondenserString, '', False);
    end;
    //fan power
    if FanPower > 0 then
    begin
      RefrigCondenserString := ReplaceRegExpr('#{FanPower}\d*\.\d*', RefrigCondenserString, FloatToStr(FanPower), False);
    end
    else
    begin
      RefrigCondenserString := ReplaceRegExpr('#{FanPower}', RefrigCondenserString, '', False);
    end;
    RefrigCondenserString := ReplaceRegExpr(#$D#$A#$D#$A#$D#$A, RefrigCondenserString, '', False);
    RefrigCondenserStringList := TStringList.Create;
    RefrigCondenserStringList.Add(RefrigCondenserString);
    IDF.AddStringList(RefrigCondenserStringList);
    if SameText(HeatRejectionValue, 'AirCooled') or SameText(HeatRejectionValue, 'EvaporativelyCooled') then
    begin
      RefrigCondenserString := ReplaceRegExpr('#{AirInletNodeName}', RefrigCondenserString, Name + '_CondenserNode', False);
    end;
  finally
    RefrigCondenserPreProcMacro.Free;
  end;
  if SameText(HeatRejectionValue, 'AirCooled') or SameText(HeatRejectionValue, 'EvaporativelyCooled') then
  begin
    Obj := IDF.AddObject('OutdoorAir:Node');
    Obj.AddField('Name', Name + '_CondenserNode');
  end;
end;

end.
