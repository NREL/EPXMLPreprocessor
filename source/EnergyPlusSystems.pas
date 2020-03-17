////////////////////////////////////////////////////////////////////////////////
//                                                                            //
// Copyright (c) 2008-2020 Alliance for Sustainable Energy.                   //
// All rights reserved.                                                       //
//                                                                            // 
////////////////////////////////////////////////////////////////////////////////

unit EnergyPlusSystems;

interface

uses
  SysUtils,
  Contnrs,
  Globals,
  EnergyPlusCore,
  EnergyPlusZones,
  EnergyPlusPPErrorMessages;

type
  T_EP_SystemType = (cSystemTypeUncontrolled, cSystemTypeCool, cSystemTypeHeat, cSystemTypeCoolHeat,
    cSystemTypeCondTower, cSystemTypeSolar, cSystemTypeHotWater, cSystemHeatRecovery, cSystemTypeGroundLoop); // cSystemTypeDual

type
  T_EP_System = class(TEnergyPlusGroup)
  protected
    DemandComponents: TObjectList;
    UnitaryControl: boolean;
  public
    HHWSetpointManagerType: string;
    HHWSetpointAtOutdoorLowTemp: double;
    HHWOutdoorLowTemp: double;
    HHWSetpointAtOutdoorHighTemp: double;
    HHWOutdoorHighTemp: double;
    HHWLoopExitTemp: double;
    HHWLoopTempDifference: double;
    CHWLoopExitTemp: double;
    CHWLoopTempDifference: double;
    CondLoopDesignExitTemp: double;
    CondLoopDesignDeltaTemp: double;
    CondLoopPumpType: string;
    CondLoopPumpFlowRate: double;
    CondLoopPumpHead: double;
    CondLoopPumpPower: double;
    CondLoopPumpEfficiency: double;
    CondLoopPumpCurveCoeff1: double;
    CondLoopPumpCurveCoeff2: double;
    CondLoopPumpCurveCoeff3: double;
    CondLoopPumpCurveCoeff4: double;
    CondLoopPumpControlType: string;
    SupplyComponents: TObjectList;
    RecircSupplyComponents: TObjectList;
    DetailedReporting: Boolean;
    SystemType: T_EP_SystemType;
    //SetPointType : string;
    SetPointSchedule: string;
    ControlledComponents: TObjectList; // probably should be protected and use a function
    SetpointComponents: TObjectList;
    RecircControlledComponents: TObjectList;
    RecircSetpointComponents: TObjectList;
    InletNode: string;
    OutletNode: string;
    RecircInletNode: string;
    RecircOutletNode: string;
    FanInletNode: string;
    FanOutletNode: string;
    RecircFanInletNode: string;
    RecircFanOutletNode: string;
    AutosizedSystem : boolean;
    SystemDesignVolFlowRate: double;
    procedure Finalize; override; // moved from protected to finalize before zones.ToIDF
    function AddSupplyComponent(Component: THVACComponent): THVACComponent;
    function AddRecircSupplyComponent(Component: THVACComponent): THVACComponent;
    function AddDemandComponent(Component: THVACComponent): THVACComponent;
    constructor Create; reintroduce;
    destructor Destroy; override;
  end;

  { T_EP_AirSystem }

  type
  T_EP_AirSystem = class(T_EP_System)
  protected
    OASystemValue: T_EP_System;
    procedure SetOASystem(thisOASystemValue: T_EP_System);
  public
    UseReturnPlenum: boolean; //  all these could really drop the "Use"
    UseSupplyPlenum: boolean;
    UseNightCycle: boolean;
    NightCycleAvailabiltySchedule: string;
    NightCycleFanSchedule: string;
    NightCycleControlType: string;
    NightCycleThermostatTolerance: double;
    NightCycleCyclingRunTime: double;
    OperationSchedule: string;
    UseLowTempTurnOff: boolean;
    UseDirectEvapTurnOff: boolean;
    ZonesServed: TObjectList;
    DistributionType: string;
    SATManagerType: string;
    SATManagerScheduleName: string;
    DualDuctSatMgrSchName: string;
    SATSetpointAtOutdoorLowTemp: double;
    SATOutdoorLowTemp: double;
    SATSetpointAtOutdoorHighTemp: double;
    SATOutdoorHighTemp: double;
    CoolingSATTemperature: double;
    HeatingSATTemperature: double;
    MinSystemAirFlowRatio: double;
    ComponentFanPressureDrop: double;
    ReturnPlenumZoneName: string;
    DesignSysAirFlowRate: string;
    HumidityMinControlZone: string;
    HumidityMaxControlZone: string;
    SysSizingCoincidence: string;
    SysSizingCooling100pcntOA: string;
    SysSizingHeating100pcntOA: string;
    SysSizingCoolingSupAirHumidityRatio: double;
    SysSizingHeatingSupAirHumidityRatio: double;
    TypeOfLoadToSizeOn: string;
    SysOaMethod: string;
    SuppressOA: boolean;
    EmsDataSetKey: string;
    EMSTurnDownRatio: string;
    DualDuct: boolean;
    property OASystem: T_EP_System read OASystemValue write SetOASystem;
    function FigureOAReliefNodeName: String;
    procedure ToIDF; override;
    function AddZoneServed(Zone: T_EP_Zone): T_EP_Zone;
    constructor Create; reintroduce;
    procedure Finalize; override;
    destructor Destroy; override;
  end;

type //incomplete, here, currently treating as component, will want to treat as system once upstream components are modeled

  { T_EP_OutsideAirSystem }

  T_EP_OutsideAirSystem = class(T_EP_System)
  protected
    MixerName: string;
    OAMixerValue: TObject;
    UseEconomizer: boolean;
    MotorizedDamper: boolean;
    ERV: TObject;
    DemandControlVentilation: boolean;
    UnitaryControl: boolean;
    OANodeName: string;
    procedure SetOAMixer(aOAMixer: TObject);
  public
    PrimaryAirSystem: T_EP_AirSystem;
    MixerOAInletNode: string;
    MixerReliefNode: string;
    MixerOutletNode: string;
    MixerRAInletNode: string;
    MinOAFraction: double;
    MinOAMultiplierSchedule: string;
    MinOAFractionSchedule: string;
    MaxOAFractionSchedule: string;
    EconomizerControlSchedule: string;
    EconomizerControlType: string;
    EconomizerMaxLimitDBT: double;
    EconomizerMaxLimitEnthalpy: double;
    DesignOAFraction: double;
    UseControllerMechVent: boolean;
    ZoneOutdoorAirMethod: string;
    SystemOutdoorAirMethod: string;
    SystemVentilationEffectiveness: double;
    SuppressOA: boolean;
    SetPtMgrName: string;
    property OAMixer: TObject read OAMixerValue write SetOAMixer;
    procedure ToIDF; override;
    procedure Finalize; override;
    constructor Create(
      var aPrimaryAirSystem: T_EP_AirSystem;
      aUseEconomizer: boolean = false;
      aMotorizedDamper: boolean = true;
      aERV: TObject = nil);
    destructor Destroy; override;
  end;

type
  T_EP_LiquidSystem = class(T_EP_System)
  protected
    LoopType: string;
  public
    LoopTempSetpoint: double;
    DesignFlowRate: double;
    ExitTemp: double; //liquid system condenser
    DeltaTemp: double; //liquid system condenser
    UseWatersideEconomizer: boolean; //liquid system condenser
    SWHStorage: double;
    SWHHeatingCapacity: double;
    UseUncontrolledLoop: boolean;
    UseWetFluidCooler: boolean;
    procedure FigureSWHsizes;
    procedure ToIDF; override;
    constructor Create; reintroduce;
    procedure Finalize; override;
  end;

type
  T_EP_CondenserSystem = class(T_EP_LiquidSystem)
  public
    constructor Create; reintroduce;
    procedure Finalize; override;
  end;

type
  T_EP_ColdWaterSystem = class(TEnergyPlusGroup)
  protected
    SupplyComponents: TObjectList;
    DemandComponents: TObjectList;
    StorageComponents: TObjectList;
  public
    SubCategory: string;
    function AddStorageComponent(Component: THVACComponent): THVACComponent;
    function AddSupplyComponent(Component: THVACComponent): THVACComponent;
    function AddDemandComponent(Component: THVACComponent): THVACComponent;
    constructor Create; reintroduce;
    procedure Finalize; override;
  end;

type
 T_EP_RefrigerationCompressorRack = class(THVACComponent)
 protected
    HeatRejectionValue: string;
    procedure SetHeatRejection(HeatRejectionType: string);
 public
    DataSetKey: string;
    FanPower: double;
    RefrigeratedCase: TObjectList;
    RefrigeratedWalkin: TObjectList;
    EvapEffectiveness: double;
    COP: double;
    HeatRejectionLocation: string;
    HeatRejectionZone: string;
    HeatRejectionLoop: T_EP_CondenserSystem;
    function AddCase(Component: THVACComponent): THVACComponent;
    property HeatRejection: string read HeatRejectionValue write SetHeatRejection;
    procedure Finalize; override;
    procedure ToIDF; override;
    constructor Create; reintroduce;
 end;

type
 T_EP_RefrigerationSystem = class(T_EP_System)
 protected
    DemandSystemValue: T_EP_System;
    procedure SetDemandSystem(SystemParameter: T_EP_System);
 public
    Refrigerant: string;
    MinCondensingTemp: double;
    RefrigeratedCase: TObjectList;
    RefrigeratedWalkin: TObjectList;
    RefrigerationCompressor: TObjectList;
    RefrigerationCondenser: TObjectList;
    Components: TObjectList;
    DemandInletNode: string;
    DemandOutletNode: string;
    function AddCase(Component: THVACComponent): THVACComponent;
    function AddRefrigSystemComponent(Component: THVACComponent): THVACComponent;
    property DemandSystem: T_EP_System read DemandSystemValue write SetDemandSystem;
    procedure Finalize; override;
    procedure ToIDF; override;
    constructor Create; reintroduce;
 end;

implementation

uses
  EnergyPlusSystemComponents, EnergyPlusSettings, StrUtils,
  classes, EnergyPlusObject, PreProcMacro, RegExpr, EnergyPlusEndUseComponents; // prevents a circular reference  (search on circular reference)

{ T_EP_System }

constructor T_EP_System.Create;
begin
  inherited;
  Systems.Add(self);
  Name := 'AirSys1'; //  why air sys ?   sometimes water
  SystemType := cSystemTypeCool;
  SupplyComponents := TObjectList.Create;
  RecircSupplyComponents := TObjectList.Create;
  DemandComponents := TObjectList.Create;
  AutosizedSystem  :=  true;
  SystemDesignVolFlowRate := -9999.0;
end;

function T_EP_System.AddSupplyComponent(Component: THVACComponent): THVACComponent;
begin
  SupplyComponents.Add(Component);
  TSystemComponent(Component).System := Self;
  THVACComponent(Component).SuppressToIDF := False;
  Result := Component;
end;

function T_EP_System.AddRecircSupplyComponent(Component: THVACComponent): THVACComponent;
begin
  RecircSupplyComponents.Add(Component);
  TSystemComponent(Component).System := Self;
  THVACComponent(Component).SuppressToIDF := False;
  Result := Component;
end;

function T_EP_System.AddDemandComponent(Component: THVACComponent): THVACComponent;
begin
  DemandComponents.Add(Component);
  THVACComponent(Component).SuppressToIDF := false;
  result := Component;
end;

procedure T_EP_System.Finalize;
var
  i: integer;
  j: integer;
  Component1: THVACComponent;
  Component2: THVACComponent;
  NodeName: string;
  SupplyComponentsInletNodeName: string;
  RecircSupplyComponentsInletNodeName: string;
  OAMixerOutletNodeName: string;
  PeakVolScaleFactor: double;
  PeakVolSum: double;
  OASystem: T_EP_OutsideAirSystem;
begin
  inherited;
  InletNode := Name + ' Supply Equipment Inlet Node';
  OutletNode := Name +  ' Supply Equipment Outlet Node';
  RecircInletNode := Name + ' Recirc Supply Equipment Inlet Node';
  RecircOutletNode := Name +  ' Recirc Supply Equipment Outlet Node';
  // ksb: look through the components on the primary air system and see
  // if there are unitary systems.  This could influence the type of
  // set point managers
  for i := 0 to SupplyComponents.Count - 1 do
  begin
    if SupplyComponents[i] is T_EP_UnitaryPackage then
    begin
      UnitaryControl := true;
    end;
  end;
  // ksb: supply components are everything after the oa system if it exists
  // ksb: first assume there is no oa system
  SupplyComponentsInletNodeName := InletNode;
  RecircSupplyComponentsInletNodeName := RecircInletNode;
  // ksb: now if there is an oa system
  if self is T_EP_AirSystem then
  begin
    if Assigned(T_EP_OutsideAirSystem(T_EP_AirSystem(self).OASystem)) then
    begin
      OASystem := T_EP_OutsideAirSystem(T_EP_AirSystem(self).OASystem);
      OASystem.MixerRAInletNode := InletNode;
      if SupplyComponents.Count > 0 then
      begin
        OAMixerOutletNodeName := OASystem.Name +
          '-' +
          THVACComponent(SupplyComponents[0]).Name +
          'Node';
        SupplyComponentsInletNodeName := OAMixerOutletNodeName;
      end
      else
      begin
        OAMixerOutletNodeName := OutletNode;
      end;
      OASystem.MixerOutletNode := OAMixerOutletNodeName;
    end;
  end;
  // Connect equipment in order of fluid flow direction
  if SupplyComponents.Count > 0 then
  begin
    THVACComponent(SupplyComponents[0]).SupplyInletNode := SupplyComponentsInletNodeName;
    THVACComponent(SupplyComponents[SupplyComponents.Count - 1]).SupplyOutletNode := OutletNode;
  end;
  if RecircSupplyComponents.Count > 0 then
  begin
    THVACComponent(RecircSupplyComponents[0]).SupplyInletNode := RecircSupplyComponentsInletNodeName;
    THVACComponent(RecircSupplyComponents[RecircSupplyComponents.Count - 1]).SupplyOutletNode := RecircOutletNode;
  end;
  if SupplyComponents.Count > 1 then
  begin
    for i := 0 to SupplyComponents.Count - 2 do
    begin
      // may need to trap for plant loop pumps here
      Component1 := THVACComponent(SupplyComponents[i]);
      Component2 := THVACComponent(SupplyComponents[i + 1]);
      NodeName := Component1.Name + '-' + Component2.Name + 'Node';
      Component1.SupplyOutletNode := NodeName;
      Component2.SupplyInletNode := NodeName;
    end;
  end;
  if RecircSupplyComponents.Count > 1 then
  begin
    for i := 0 to RecircSupplyComponents.Count - 2 do
    begin
      Component1 := THVACComponent(RecircSupplyComponents[i]);
      Component2 := THVACComponent(RecircSupplyComponents[i + 1]);
      NodeName := Component1.Name + '-' + Component2.Name + 'Node';
      Component1.SupplyOutletNode := NodeName;
      Component2.SupplyInletNode := NodeName;
    end;
  end;
  //THIS MAY BE WRONG, USUALLY want components working of their own outlet
  //set each component's control node to be the supply side outlet
  for i := 0 to SupplyComponents.Count - 1 do
  begin
    THVACComponent(SupplyComponents[i]).ControlNode := OutletNode;
  end;
  if RecircSupplyComponents.Count > 0 then
  begin
    for i := 0 to RecircSupplyComponents.Count - 1 do
    begin
      THVACComponent(RecircSupplyComponents[i]).ControlNode := RecircOutletNode;
    end;
  end;
  //look for water heaters on supply side, and set nodes
  for i := 0 to SupplyComponents.Count - 1 do
  begin
    if SupplyComponents.Items[i] is T_EP_WaterHeater then
    begin
       if ((T_EP_WaterHeater(SupplyComponents[i]).SourceSideSystem = self ) AND
        ( T_EP_WaterHeater(SupplyComponents[i]).SourceSideOnSupply ) )then
       begin
         T_EP_WaterHeater(SupplyComponents[i]).SupplyInletNode  := T_EP_WaterHeater(SupplyComponents[i]).SourceSideInletNode ;
         T_EP_WaterHeater(SupplyComponents[i]).SupplyOutletNode := T_EP_WaterHeater(SupplyComponents[i]).SourceSideOutletNode  ;
         T_EP_WaterHeater(SupplyComponents[i]).ControlType := 'Passive';
       end;
       If ((T_EP_WaterHeater(SupplyComponents[i]).UseSideSystem = self ) AND
        ( T_EP_WaterHeater(SupplyComponents[i]).UseSideOnSupply ) )then
       begin
         T_EP_WaterHeater(SupplyComponents[i]).SupplyInletNode  := T_EP_WaterHeater(SupplyComponents[i]).UseSideInletNode ;
         T_EP_WaterHeater(SupplyComponents[i]).SupplyOutletNode := T_EP_WaterHeater(SupplyComponents[i]).UseSideOutletNode  ;
         T_EP_WaterHeater(SupplyComponents[i]).ControlType := 'Passive';
       end;
    end;
  end;
  // look for fan components and set FanInletNode and FanOutletNode for Mixed air controller.
  for i := 0 to SupplyComponents.Count - 1 do
  begin
    if SupplyComponents.Items[i] is T_EP_FAN then
    begin
      FanInletNode := THVACComponent(SupplyComponents[i]).SupplyInletNode;
      FanOutletNode := THVACComponent(SupplyComponents[i]).SupplyOutletNode;
    end;
    if SupplyComponents.Items[i] is T_EP_EvaporativeCooler then
    begin
      if T_EP_EvaporativeCooler(SupplyComponents.Items[i]).Typ = 'Direct' then
      begin
        // ksb: we will assume the system is an air system and set UseDirectEvapTurnOff
        // this sets up availability managers that turn off the air system
        // when the direct evap and cooling is not beneficial
        T_EP_AirSystem(self).UseDirectEvapTurnOff := true;
      end;
    end;
    if SupplyComponents.Items[i] is T_EP_UnitaryPackage then
    begin
      if T_EP_UnitaryPackage(SupplyComponents.Items[i]).Typ = 'AIRTOAIRHEATPUMPHEATCOOL' then
      begin
        FanInletNode := THVACComponent(SupplyComponents[i]).SupplyInletNode;
        FanOutletNode := THVACComponent(SupplyComponents[i]).name + 'DXcool air inlet';
      end
      else if T_EP_UnitaryPackage(SupplyComponents.Items[i]).Typ = 'AIRTOAIRHEATPUMPHEATONLY' then
      begin
        FanInletNode := THVACComponent(SupplyComponents[i]).SupplyInletNode;
        FanOutletNode := THVACComponent(SupplyComponents[i]).name + 'DXcool air inlet';
      end
      else if T_EP_UnitaryPackage(SupplyComponents.Items[i]).Typ = 'AIRTOAIRHEATCOOL' then
      begin
        FanInletNode := THVACComponent(SupplyComponents[i]).SupplyInletNode;
        FanOutletNode := THVACComponent(SupplyComponents[i]).name + 'CoolCoil air inlet';
      end
      else if T_EP_UnitaryPackage(SupplyComponents.Items[i]).Typ = 'WATERTOAIRHEATPUMP' then
      begin
        FanInletNode := THVACComponent(SupplyComponents[i]).SupplyInletNode;
        FanOutletNode := THVACComponent(SupplyComponents[i]).name + '_cooling_coil_air_inlet';
      end
      else if T_EP_UnitaryPackage(SupplyComponents.Items[i]).Typ = 'FURNACEHEATONLY' then
      begin
        FanInletNode := THVACComponent(SupplyComponents[i]).SupplyInletNode;
        FanOutletNode := THVACComponent(SupplyComponents[i]).Name + 'Heating Coil Air Inlet';
      end;
    end;
  end;
  if RecircSupplyComponents.Count > 0 then
  begin
    for i := 0 to RecircSupplyComponents.Count - 1 do
    begin
      if RecircSupplyComponents.Items[i] is T_EP_FAN then
      begin
        RecircFanInletNode := THVACComponent(RecircSupplyComponents[i]).SupplyInletNode;
        RecircFanOutletNode := THVACComponent(RecircSupplyComponents[i]).SupplyOutletNode;
      end;
    end;
  end;
  // look for fan components and set DX coil type for CV vs VAV (if needed)
  for i := 0 to SupplyComponents.Count - 1 do
  begin
    if SupplyComponents.Items[i] is T_EP_FAN then
    begin
      if T_EP_Fan(SupplyComponents.Items[i]).Typ = 'Constant' then
      begin
        // do nothing , this is default
      end
      else if T_EP_Fan(SupplyComponents.Items[i]).Typ = 'VARIABLE' then
      begin
        for j := 0 to SupplyComponents.Count - 1 do
        begin
          if SupplyComponents.Items[j] is T_EP_Coil then
          begin
            if T_EP_Coil(SupplyComponents.Items[j]).ComponentType = 'CoilSystem:Cooling:DX' then
            begin
              T_EP_Coil(SupplyComponents.Items[j]).AirVolumeMode := 'VARIABLE';
            end;
          end;
        end;
      end;
    end;
  end;
  if RecircSupplyComponents.Count > 0 then
  begin
    for i := 0 to RecircSupplyComponents.Count - 1 do
    begin
      if RecircSupplyComponents.Items[i] is T_EP_FAN then
      begin
        if T_EP_Fan(RecircSupplyComponents.Items[i]).Typ = 'VARIABLE' then
        begin
          for j := 0 to RecircSupplyComponents.Count - 1 do
          begin
            if RecircSupplyComponents.Items[j] is T_EP_Coil then
            begin
              if T_EP_Coil(RecircSupplyComponents.Items[j]).ComponentType = 'CoilSystem:Cooling:DX' then
              begin
                T_EP_Coil(RecircSupplyComponents.Items[j]).AirVolumeMode := 'VARIABLE';
              end;
            end;
          end;
        end;
      end;
    end;
  end;
  // look for pumps on a plant loop system and reset nodes
  for i := 0 to SupplyComponents.Count - 1 do
  begin
    if SupplyComponents.Items[i] is T_EP_PUMP then
    begin
      THVACComponent(SupplyComponents[i]).SupplyInletNode := Name + ' Supply Inlet Node';
      THVACComponent(SupplyComponents[i]).SupplyOutletNode := THVACComponent(SupplyComponents[i + 1]).SupplyInletNode + 'viaConnector';
      // figure out if pump is sized or supposed to be autosized.
      if (T_EP_PUMP(SupplyComponents.Items[i]).RatedFlowRate <> -9999.0) then begin
         AutosizedSystem := false;
         SystemDesignVolFlowRate := T_EP_PUMP(SupplyComponents.Items[i]).RatedFlowRate;
      end; // if
    end;
  end;
  // look for demand components (eg. hot water coils
  for i := 0 to DemandComponents.Count - 1 do
  begin
    if DemandComponents.Items[i] is T_EP_Coil then
    begin
      THVACComponent(DemandComponents[i]).DemandInletNode := THVACComponent(DemandComponents[i]).Name + ' Demand Inlet Node';
      THVACComponent(DemandComponents[i]).DemandOutletNode := THVACComponent(DemandComponents[i]).Name + ' Demand Outlet Node';
    end;
  end;
  // Figure SWH peak flow rate and correct if too small for EnergyPlus
  PeakVolSum := 0.0;
  PeakVolScaleFactor := 1.0;
  for i := 0 to DemandComponents.Count - 1 do
  begin
    if DemandComponents.Items[i] is T_EP_WaterUseConnection then
    begin
      T_EP_WaterUseConnection(DemandComponents[i]).Finalize;
      PeakVolSum := PeakVolSum + T_EP_WaterUseConnection(DemandComponents[i]).WaterUseObject.PeakVolFlowRate;
    end;
  end;
  if (PeakVolSum < 1E-6) then
  begin
    if (PeakVolSum > 0.0) then
    begin
      PeakVolScaleFactor := 1.1E-6 / PeakVolSum;
    end;
    for i := 0 to DemandComponents.Count - 1 do
    begin
      if DemandComponents.Items[i] is T_EP_WaterUseConnection then
      begin
        T_EP_WaterUseConnection(DemandComponents[i]).WaterUseObject.PeakVolFlowRate := T_EP_WaterUseConnection(DemandComponents[i]).WaterUseObject.PeakVolFlowRate * PeakVolScaleFactor;
      end;
    end;
  end;
end;

destructor T_EP_System.Destroy;
begin
  Systems.Remove(self);
  inherited;
end;

{ T_EP_AirSystem }

constructor T_EP_AirSystem.Create;
begin
  inherited;
  Name := 'AirSys';
  ControlledComponents := TObjectList.Create;
  SetPointComponents := TObjectList.Create;
  RecircControlledComponents := TObjectList.Create;
  RecircSetPointComponents := TObjectList.Create;
  DesignSysAirFlowRate := 'AUTOSIZE';
  TypeOfLoadToSizeOn := 'Sensible';
  SysOaMethod := 'ZoneSum';
  SuppressOA := false;
  ZonesServed := TObjectList.Create;
  UseReturnPlenum := false;
  UseSupplyPlenum := false;
  UseNightCycle := false;
  OperationSchedule := 'HVACOperationSchd';
  DistributionType := 'SingleZone';
  SATManagerType := 'Scheduled';
  SATSetpointAtOutdoorLowTemp := 15.5;
  SATOutdoorLowTemp := 15.5;
  SATSetpointAtOutdoorHighTemp := 12.8;
  SATOutdoorHighTemp := 21.0;
  UseLowTempTurnOff := false;
  CoolingSATTemperature := 12.8;
  HeatingSATTemperature := 16.7;
  MinSystemAirFlowRatio := -999.0;
  ComponentFanPressureDrop := 0.0;
  SysSizingCoincidence := 'NonCoincident';
  SysSizingCooling100pcntOA := 'No';
  SysSizingHeating100pcntOA := 'No';
  SysSizingCoolingSupAirHumidityRatio := 0.0085;
  SysSizingHeatingSupAirHumidityRatio := 0.008;
  OASystem := nil;
end;

procedure T_EP_AirSystem.SetOASystem(thisOASystemValue: T_EP_System);
begin
  OASystemValue := thisOASystemValue;
end;

function T_EP_AirSystem.AddZoneServed(Zone: T_EP_Zone): T_EP_Zone;
begin
  ZonesServed.Add(Zone);
  result := Zone;
end;

destructor T_EP_AirSystem.Destroy;
begin
  if Assigned(OASystem) then OASystem.Free;
  inherited;
end;

function T_EP_AirSystem.FigureOAReliefNodeName : string  ;
var
  i: integer;
begin
  for i := 0 to SupplyComponents.Count - 1 do
  begin
    result := T_EP_OutsideAirSystem(self.OASystemValue).MixerReliefNode;
  end;
end;

procedure T_EP_AirSystem.ToIDF;
var
  Obj: TEnergyPlusObject;
  SupplyPlenumZoneName: string;
  i: integer;
  inc: integer;
  Component: THVACComponent;
  iZone: Integer;
  bUseHumidistat: Boolean;
  EmsPreProcMacro: TPreProcMacro;
  EmsStringList: TStringList;
  EmsString: string;
  CleanName: string;
  CleanZoneName: string;
begin
  inherited;
  Finalize;
  if SATManagerType = '' then SATManagerType := 'Scheduled';
  IDF.AddComment('');   // intentional blank line
  IDF.AddComment('Air Loop: ' + Name);
  //air loop HVAC
  Obj := IDF.AddObject('AirLoopHVAC');
  Obj.AddField('Name', Name);
  if ((ControlledComponents.Count > 0) or (RecircControlledComponents.Count > 0)) then
    Obj.AddField('Controller List Name', Name + '_Controllers')
  else
    Obj.AddField('Controller List Name', '');
  if UseNightCycle or UseLowTempTurnoff or UseDirectEvapTurnOff then
    Obj.AddField('Availability Manager List Name', Name + ' Availability Manager List')
  else
    Obj.AddField('Availability Manager List Name', '');
  Obj.AddField('Design Supply Air Flow Rate', DesignSysAirFlowRate, '{m3/s}');
  Obj.AddField('Branch List Name', Name + ' Air Loop Branches');
  if DualDuct and (RecircSupplyComponents.Count > 0) then
  begin
    Obj.AddField('Connector List Name', Name + ' Dual Duct Connectors');
    Obj.AddField('Supply Side Inlet Node Name', Name + ' Dual Duct Inlet Node');
  end
  else
  begin
    Obj.AddField('Connector List Name', '');
    Obj.AddField('Supply Side Inlet Node Name', InletNode);
  end;
  Obj.AddField('Demand Side Outlet Node Name', Name + ' Zone Equipment Outlet Node');
  if DualDuct and (RecircSupplyComponents.Count > 0) then
  begin
    Obj.AddField('Demand Side Inlet Node Names', Name + ' Zone Equipment Inlet Node List');
    Obj.AddField('Supply Side Outlet Node Names', OutletNode + ' List');
    //demand side inlet node names
    Obj := IDF.AddObject('NodeList');
    Obj.AddField('Name',  Name + ' Zone Equipment Inlet Node List');
    Obj.AddField('Node 1 Name', Name + ' Zone Equipment Inlet Node');
    Obj.AddField('Node 2 Name', Name + ' Zone Equipment Recirc Inlet Node');
    //supply side outlet node names
    Obj := IDF.AddObject('NodeList');
    Obj.AddField('Name',  OutletNode + ' List');
    Obj.AddField('Node 1 Name', OutletNode);
    Obj.AddField('Node 2 Name', RecircOutletNode);
  end
  else
  begin
    Obj.AddField('Demand Side Inlet Node Names', Name + ' Zone Equipment Inlet Node');
    Obj.AddField('Supply Side Outlet Node Names', OutletNode);
  end;
  // check for humidistat
  bUseHumidistat := False;
  for iZone := 0 to ZonesServed.Count - 1 do
  begin
    if T_EP_Zone(ZonesServed[iZone]).UseHumidistat then
    begin
      bUseHumidistat := True;
      break;
    end;
  end;
  // add connector list and return air splitter if dual duct
  if DualDuct and (RecircSupplyComponents.Count > 0) then
  begin
    // connector list
    Obj := IDF.AddObject('ConnectorList');
    Obj.AddField('Name', Name + ' Dual Duct Connectors');
    Obj.AddField('Connector 1 Object Type', 'Connector:Splitter');
    Obj.AddField('Connector 1 Name', Name + ' Return Air Splitter');
    // return air splitter
    Obj := IDF.AddObject('Connector:Splitter');
    Obj.AddField('Name', Name + ' Return Air Splitter');
    Obj.AddField('Inlet Branch Name', Name + ' Dual Duct Branch');
    Obj.AddField('Outlet Branch 1 Name', Name + ' Air Loop Main Branch');
    if RecircSupplyComponents.Count > 0 then
      Obj.AddField('Outlet Branch 2 Name', Name + ' Recirc Branch');
  end;
  // add controller lists
  if ((ControlledComponents.Count > 0) or (RecircControlledComponents.Count > 0)) then
  begin
    Obj := IDF.AddObject('AirLoopHVAC:ControllerList');
    Obj.AddField('Name', Name + '_Controllers');
    for i := 0 to ControlledComponents.Count - 1 do
    begin
      Obj.AddField('Controller '+ IntToStr(i + 1) +' Object Type' , 'Controller:WaterCoil');
      Obj.AddField('Controller '+ IntToStr(i + 1) +' Name ' , THVACComponent(ControlledComponents[i]).Name + '_Controller');
    end;
    for i := 0 to RecircControlledComponents.Count - 1 do
    begin
      Obj.AddField('Controller '+ IntToStr(i + 1) +' Object Type' , 'Controller:WaterCoil');
      Obj.AddField('Controller '+ IntToStr(i + 1) +' Name ' , THVACComponent(RecircControlledComponents[i]).Name + '_Controller');
    end;
    for i := 0 to ControlledComponents.Count - 1 do
    begin
      if ControlledComponents[i] is T_EP_Coil then
      begin
        if ((T_EP_Coil(ControlledComponents[i]).ComponentType = 'Coil:Cooling:Water') or
            (T_EP_Coil(ControlledComponents[i]).ComponentType = 'Coil:Cooling:Water:DetailedGeometry')) then
        begin
          Obj := IDF.AddObject('Controller:WaterCoil');
          Obj.AddField('Name', THVACComponent(ControlledComponents[i]).Name + '_Controller');
          if bUseHumidistat then
            Obj.AddField('Control Variable', 'TemperatureAndHumidityRatio', '{Temperature | HumidityRatio | TemperatureAndHumidityRatio | Flow}')
          else
            Obj.AddField('Control Variable', 'Temperature', '{Temperature | HumidityRatio | TemperatureAndHumidityRatio | Flow}');
          Obj.AddField('Action', 'Reverse', '{Normal | Reverse}');
          Obj.AddField('Actuator Variable', 'Flow', '{Flow}');
          Obj.AddField('Sensor Node Name', THVACComponent(ControlledComponents[i]).SupplyOutletNode);
          Obj.AddField('Actuator Node Name', THVACComponent(ControlledComponents[i]).DemandInletNode);
          Obj.AddField('Controller Convergence Tolerance', '', '{delta C}', 'Delta temp from setpoint');
          Obj.AddField('Maximum Actuated Flow', 'AUTOSIZE', '{m3/s}');
          Obj.AddField('Minimum Actuated Flow', '0.0', '{m3/s}');
        end
        else if T_EP_Coil(ControlledComponents[i]).ComponentType = 'Coil:Heating:Water' then
        begin
          Obj := IDF.AddObject('Controller:WaterCoil');
          Obj.AddField('Name', THVACComponent(ControlledComponents[i]).Name + '_Controller');
          Obj.AddField('Control Variable', 'Temperature', '{Temperature | HumidityRatio | TemperatureAndHumidityRatio | Flow}');
          Obj.AddField('Action', 'Normal', '{Normal | Reverse}');
          Obj.AddField('Actuator Variable', 'Flow', '{FLOW}');
          Obj.AddField('Sensor Node Name', THVACComponent(ControlledComponents[i]).SupplyOutletNode);
          Obj.AddField('Actuator Node Name', THVACComponent(ControlledComponents[i]).DemandInletNode);
          Obj.AddField('Controller Convergence Tolerance', '0.0001', '{delta C}', 'Delta temp from setpoint');
          Obj.AddField('Maximum Actuated Flow', 'AUTOSIZE', '{m3/s}');
          Obj.AddField('Minimum Actuated Flow', '0.0', '{m3/s}');
        end;
      end;
    end;
    for i := 0 to RecircControlledComponents.Count - 1 do
    begin
      if RecircControlledComponents[i] is T_EP_Coil then
      begin
        if ((T_EP_Coil(RecircControlledComponents[i]).ComponentType = 'Coil:Cooling:Water') or
            (T_EP_Coil(RecircControlledComponents[i]).ComponentType = 'Coil:Cooling:Water:DetailedGeometry')) then
        begin
          Obj := IDF.AddObject('Controller:WaterCoil');
          Obj.AddField('Name', THVACComponent(RecircControlledComponents[i]).Name + '_Controller');
          if bUseHumidistat then
            Obj.AddField('Control Variable', 'TemperatureAndHumidityRatio', '{Temperature | HumidityRatio | TemperatureAndHumidityRatio | Flow}')
          else
            Obj.AddField('Control Variable', 'Temperature', '{Temperature | HumidityRatio | TemperatureAndHumidityRatio | Flow}');
          Obj.AddField('Action', 'Reverse', '{Normal | Reverse}');
          Obj.AddField('Actuator Variable', 'Flow', '{Flow}');
          Obj.AddField('Sensor Node Name', THVACComponent(RecircControlledComponents[i]).SupplyOutletNode);
          Obj.AddField('Actuator Node Name', THVACComponent(RecircControlledComponents[i]).DemandInletNode);
          Obj.AddField('Controller Convergence Tolerance', '', '{delta C}', 'Delta temp from setpoint');
          Obj.AddField('Maximum Actuated Flow', 'AUTOSIZE', '{m3/s}');
          Obj.AddField('Minimum Actuated Flow', '0.0', '{m3/s}');
        end
        else if T_EP_Coil(RecircControlledComponents[i]).ComponentType = 'Coil:Heating:Water' then
        begin
          Obj := IDF.AddObject('Controller:WaterCoil');
          Obj.AddField('Name', THVACComponent(RecircControlledComponents[i]).Name + '_Controller');
          Obj.AddField('Control Variable', 'Temperature', '{Temperature | HumidityRatio | TemperatureAndHumidityRatio | Flow}');
          Obj.AddField('Action', 'Normal', '{Normal | Reverse}');
          Obj.AddField('Actuator Variable', 'Flow', '{FLOW}');
          Obj.AddField('Sensor Node Name', THVACComponent(RecircControlledComponents[i]).SupplyOutletNode);
          Obj.AddField('Actuator Node Name', THVACComponent(RecircControlledComponents[i]).DemandInletNode);
          Obj.AddField('Controller Convergence Tolerance', '0.0001', '{delta C}', 'Delta temp from setpoint');
          Obj.AddField('Maximum Actuated Flow', 'AUTOSIZE', '{m3/s}');
          Obj.AddField('Minimum Actuated Flow', '0.0', '{m3/s}');
        end;
      end;
    end;
  end;
  if ((SetpointComponents.Count > 0) or (RecircSetpointComponents.Count > 0)) then
  begin
    // ksb: for all of the set point components I will assume there is a fan as the last component
    if SameText(DistributionType, 'MultiZone') then
    begin
      if SameText(SATManagerType, 'Scheduled') then
      begin
        Obj := IDF.AddObject('SetpointManager:Scheduled');
        Obj.AddField('Name', Name + ' SAT Setpoint');
        Obj.AddField('Control Variable', 'Temperature', '{Temperature | Others}');
        Obj.AddField('Schedule Name', 'Seasonal-Reset-Supply-Air-Temp-Sch');
        Obj.AddField('Setpoint Node or NodeList Name', OutletNode);
      end
      else if SameText(SATManagerType, 'OutsideAir') then
      begin
        Obj := IDF.AddObject('SetpointManager:OutdoorAirReset');
        Obj.AddField('Name', Name + ' SAT Setpoint');
        Obj.AddField('Control Variable', 'Temperature', '{ Temperature | Others }');
        Obj.AddField('Setpoint at Outdoor Low Temperature', SATSetpointAtOutdoorLowTemp);
        Obj.AddField('Outdoor Low Temperature', SATOutdoorLowTemp);
        Obj.AddField('Setpoint at Outdoor High Temperature', SATSetpointAtOutdoorHighTemp);
        Obj.AddField('Outdoor High Temperature', SATOutdoorHighTemp);
        Obj.AddField('Setpoint Node or NodeList Name', OutletNode);
      end
      else if SameText(SATManagerType, 'Substitution') then
      begin
        Obj := IDF.AddObject('SetpointManager:Scheduled');
        Obj.AddField('Name', Name + ' SAT Setpoint');
        Obj.AddField('Control Variable', 'Temperature', '{Temperature | Others}');
        Obj.AddField('Schedule Name', SATManagerScheduleName);
        Obj.AddField('Setpoint Node or NodeList Name', OutletNode);
      end
      else if SameText(SATManagerType, 'Warmest') then
      begin
        Obj := IDF.AddObject('SetpointManager:Warmest');
        Obj.AddField('Name', Name + ' SAT Setpoint');
        Obj.AddField('Control Variable', 'Temperature', '{ Temperature | Others}');
        Obj.AddField('HVAC Air Loop Name', Name);
        Obj.AddField('Minimum Setpoint Temperature', '12.8', '{deg C}');
        Obj.AddField('Maximum Setpoint Temperature', '20.0', '{deg C}');
        Obj.AddField('Strategy', 'MaximumTemperature', '{MaximumTemperature | Others}');
        Obj.AddField('Setpoint Node or NodeList Name', OutletNode);
      end;
    end;
    if SameText(DistributionType, 'DualDuct') then
    begin
      if SameText(SATManagerType, 'Scheduled') then
      begin
        // main branch
        Obj := IDF.AddObject('SetpointManager:Scheduled');
        Obj.AddField('Name', Name + ' OA SAT Setpoint');
        Obj.AddField('Control Variable', 'Temperature', '{Temperature | Others}');
        Obj.AddField('Schedule Name', 'Seasonal-Reset-Supply-Air-Temp-Sch');
        Obj.AddField('Setpoint Node or NodeList Name', OutletNode);
        // recirc branch
        if RecircSupplyComponents.Count > 0 then
        begin
          Obj := IDF.AddObject('SetpointManager:Scheduled');
          Obj.AddField('Name', Name + ' RC SAT Setpoint');
          Obj.AddField('Control Variable', 'Temperature', '{Temperature | Others}');
          Obj.AddField('Schedule Name', DualDuctSatMgrSchName);
          Obj.AddField('Setpoint Node or NodeList Name', RecircOutletNode);
        end;
      end
      else if SameText(SATManagerType, 'OutsideAir') then
      begin
        // main branch
        Obj := IDF.AddObject('SetpointManager:OutdoorAirReset');
        Obj.AddField('Name', Name + ' OA SAT Setpoint');
        Obj.AddField('Control Variable', 'Temperature', '{ Temperature | Others }');
        Obj.AddField('Setpoint at Outdoor Low Temperature', SATSetpointAtOutdoorLowTemp);
        Obj.AddField('Outdoor Low Temperature', SATOutdoorLowTemp);
        Obj.AddField('Setpoint at Outdoor High Temperature', SATSetpointAtOutdoorHighTemp);
        Obj.AddField('Outdoor High Temperature', SATOutdoorHighTemp);
        Obj.AddField('Setpoint Node or NodeList Name', OutletNode);
        // recirc branch
        if RecircSupplyComponents.Count > 0 then
        begin
          Obj := IDF.AddObject('SetpointManager:OutdoorAirReset');
          Obj.AddField('Name', Name + ' RC SAT Setpoint');
          Obj.AddField('Control Variable', 'Temperature', '{ Temperature | Others }');
          Obj.AddField('Setpoint at Outdoor Low Temperature', SATSetpointAtOutdoorLowTemp);
          Obj.AddField('Outdoor Low Temperature', SATOutdoorLowTemp);
          Obj.AddField('Setpoint at Outdoor High Temperature', SATSetpointAtOutdoorHighTemp);
          Obj.AddField('Outdoor High Temperature', SATOutdoorHighTemp);
          Obj.AddField('Setpoint Node or NodeList Name', RecircOutletNode);
        end;
      end
      else if SameText(SATManagerType, 'Substitution') then
      begin
        // main branch
        Obj := IDF.AddObject('SetpointManager:Scheduled');
        Obj.AddField('Name', Name + ' SAT Setpoint');
        Obj.AddField('Control Variable', 'Temperature', '{Temperature | Others}');
        Obj.AddField('Schedule Name', SATManagerScheduleName);
        Obj.AddField('Setpoint Node or NodeList Name', OutletNode);
        // recirc branch
        if RecircSupplyComponents.Count > 0 then
        begin
          Obj := IDF.AddObject('SetpointManager:Scheduled');
          Obj.AddField('Name', Name + ' RC SAT Setpoint');
          Obj.AddField('Control Variable', 'Temperature', '{Temperature | Others}');
          Obj.AddField('Schedule Name', DualDuctSatMgrSchName);
          Obj.AddField('Setpoint Node or NodeList Name', RecircOutletNode);
        end;
      end;
    end;
    for i := 0 to SetpointComponents.Count - 1 do
    begin
      if SetpointComponents[i] is T_EP_Coil then
      begin
        // chilled water coil
        if ((T_EP_Coil(SetpointComponents[i]).ComponentType = 'Coil:Cooling:Water') or
            (T_EP_Coil(SetpointComponents[i]).ComponentType = 'Coil:Cooling:Water:DetailedGeometry')) then
        begin
          if bUseHumidistat then
          begin
            Obj := IDF.AddObject('SetpointManager:SingleZone:Humidity:Maximum');
            Obj.AddField('Name', THVACComponent(SetpointComponents[i]).Name + ' HUMRAT Setpoint');
            Obj.AddField('Control Variable', '');
            Obj.AddField('Schedule Name', '');
            Obj.AddField('Setpoint Node or NodeList Name', THVACComponent(SetpointComponents[i]).SupplyOutletNode);
            // need a governing zone here , assume first zone with humidistat will work well enough
            Obj.AddField('Control Zone Air Node Name', HumidityMaxControlZone + ' Air Node');
            // if user provides setpoint manager schedule name
            if THVACComponent(SetpointComponents[i]).SetPtMgrName <> '' then
            begin
              Obj := IDF.AddObject('SetpointManager:Scheduled');
              Obj.AddField('Name', THVACComponent(SetpointComponents[i]).Name + ' SAT Manager');
              Obj.AddField('Control Variable', 'Temperature', '{Temperature | Others}');
              Obj.AddField('Schedule Name', THVACComponent(SetpointComponents[i]).SetPtMgrName);
              Obj.AddField('Setpoint Node or NodeList Name', THVACComponent(SetpointComponents[i]).SupplyOutletNode);
            end
            else // mixed air setpoint manager
            begin
              Obj := IDF.AddObject('SetpointManager:MixedAir');
              Obj.AddField('Name', THVACComponent(SetpointComponents[i]).Name + ' SAT Manager');
              Obj.AddField('Control Variable', 'Temperature', '{Temperature}');
              Obj.AddField('Reference Setpoint Node Name', OutletNode);
              Obj.AddField('Fan Inlet Node Name', FanInletNode);
              Obj.AddField('Fan Outlet Node Name', FanOutletNode);
              Obj.AddField('Setpoint Node or NodeList Name', THVACComponent(SetpointComponents[i]).SupplyOutletNode);
            end;
          end
          else
          begin
            if THVACComponent(SetpointComponents[i]).SetPtMgrName <> '' then
            begin
              Obj := IDF.AddObject('SetpointManager:Scheduled');
              Obj.AddField('Name', THVACComponent(SetpointComponents[i]).Name + ' SAT Manager');
              Obj.AddField('Control Variable', 'Temperature', '{Temperature | Others}');
              Obj.AddField('Schedule Name', THVACComponent(SetpointComponents[i]).SetPtMgrName);
              Obj.AddField('Setpoint Node or NodeList Name', THVACComponent(SetpointComponents[i]).SupplyOutletNode);
            end
            else
            begin
              Obj := IDF.AddObject('SetpointManager:MixedAir');
              Obj.AddField('Name', THVACComponent(SetpointComponents[i]).Name + ' SAT Manager');
              Obj.AddField('Control Variable', 'Temperature', '{Temperature}');
              Obj.AddField('Reference Setpoint Node Name', OutletNode);
              Obj.AddField('Fan Inlet Node Name', FanInletNode);
              Obj.AddField('Fan Outlet Node Name', FanOutletNode);
              Obj.AddField('Setpoint Node or NodeList Name', THVACComponent(SetpointComponents[i]).SupplyOutletNode);
            end;
          end;
        end
        // heating hot water coil
        else if T_EP_Coil(SetpointComponents[i]).ComponentType = 'Coil:Heating:Water' then
        begin
          if THVACComponent(SetpointComponents[i]).SetPtMgrName <> '' then
          begin
            Obj := IDF.AddObject('SetpointManager:Scheduled');
            Obj.AddField('Name', THVACComponent(SetpointComponents[i]).Name + ' SAT Manager');
            Obj.AddField('Control Variable', 'Temperature', '{Temperature | Others}');
            Obj.AddField('Schedule Name', THVACComponent(SetpointComponents[i]).SetPtMgrName);
            Obj.AddField('Setpoint Node or NodeList Name', THVACComponent(SetpointComponents[i]).SupplyOutletNode);
          end
          else
          begin
            Obj := IDF.AddObject('SetpointManager:MixedAir');
            Obj.AddField('Name', THVACComponent(SetpointComponents[i]).Name + ' SAT Manager');
            Obj.AddField('Control Variable', 'Temperature', '{Temperature}');
            Obj.AddField('Reference Setpoint Node Name', OutletNode);
            Obj.AddField('Fan Inlet Node Name', FanInletNode);
            Obj.AddField('Fan Outlet Node Name', FanOutletNode);
            Obj.AddField('Setpoint Node or NodeList Name', THVACComponent(SetpointComponents[i]).SupplyOutletNode);
          end;
        end
        // DX cooling coil
        else if SameText(T_EP_Coil(SetpointComponents[i]).ComponentType, 'CoilSystem:Cooling:DX') then
        begin
          if bUseHumidistat then
          begin
            Obj := IDF.AddObject('SetpointManager:SingleZone:Humidity:Maximum');
            Obj.AddField('Name', THVACComponent(SetpointComponents[i]).Name + ' HUMRAT Setpoint');
            Obj.AddField('Control Variable', '');
            Obj.AddField('Schedule Name', '');
            Obj.AddField('Setpoint Node or NodeList Name', THVACComponent(SetpointComponents[i]).SupplyOutletNode);
            // need a governing zone here , assume first zone with humidistat will work well enough
            Obj.AddField('Control Zone Air Node Name', HumidityMaxControlZone + ' Air Node');
            // if user provides setpoint manager schedule name
            if THVACComponent(SetpointComponents[i]).SetPtMgrName <> '' then
            begin
              Obj := IDF.AddObject('SetpointManager:Scheduled');
              Obj.AddField('Name', THVACComponent(SetpointComponents[i]).Name + ' SAT Manager');
              Obj.AddField('Control Variable', 'Temperature', '{Temperature | Others}');
              Obj.AddField('Schedule Name', THVACComponent(SetpointComponents[i]).SetPtMgrName);
              Obj.AddField('Setpoint Node or NodeList Name', THVACComponent(SetpointComponents[i]).SupplyOutletNode);
            end
            else // mixed air setpoint manager
            begin
              Obj := IDF.AddObject('SetpointManager:MixedAir');
              Obj.AddField('Name', THVACComponent(SetpointComponents[i]).Name + ' SAT Manager');
              Obj.AddField('Control Variable', 'Temperature', '{Temperature}');
              Obj.AddField('Reference Setpoint Node Name', OutletNode);
              Obj.AddField('Fan Inlet Node Name', FanInletNode);
              Obj.AddField('Fan Outlet Node Name', FanOutletNode);
              Obj.AddField('Setpoint Node or NodeList Name', THVACComponent(SetpointComponents[i]).SupplyOutletNode);
            end;
          end
          else
          begin
            if THVACComponent(SetpointComponents[i]).SetPtMgrName <> '' then
            begin
              Obj := IDF.AddObject('SetpointManager:Scheduled');
              Obj.AddField('Name', THVACComponent(SetpointComponents[i]).Name + ' SAT Manager');
              Obj.AddField('Control Variable', 'Temperature', '{Temperature | Others}');
              Obj.AddField('Schedule Name', THVACComponent(SetpointComponents[i]).SetPtMgrName);
              Obj.AddField('Setpoint Node or NodeList Name', THVACComponent(SetpointComponents[i]).SupplyOutletNode);
            end
            else
            begin
              Obj := IDF.AddObject('SetpointManager:MixedAir');
              Obj.AddField('Name', THVACComponent(SetpointComponents[i]).Name + ' SAT Manager');
              Obj.AddField('Control Variable', 'Temperature', '{Temperature}');
              Obj.AddField('Reference Setpoint Node Name', OutletNode);
              Obj.AddField('Fan Inlet Node Name', FanInletNode);
              Obj.AddField('Fan Outlet Node Name', FanOutletNode);
              Obj.AddField('Setpoint Node or NodeList Name', THVACComponent(SetpointComponents[i]).SupplyOutletNode);
            end;
          end;
        end;
      end;
      // evaporative cooler
      if ((SameText(T_EP_EvaporativeCooler(SetpointComponents[i]).ComponentType , 'EvaporativeCooler:Indirect:ResearchSpecial')) or
          (SameText(T_EP_EvaporativeCooler(SetpointComponents[i]).ComponentType , 'EvaporativeCooler:Direct:ResearchSpecial'))) then
      begin
        Obj := IDF.AddObject('SetpointManager:MixedAir');
        Obj.AddField('Name', THVACComponent(SetpointComponents[i]).Name + ' SAT Manager');
        Obj.AddField('Control Variable', 'Temperature', '{Temperature}');
        Obj.AddField('Reference Setpoint Node Name', OutletNode);
        Obj.AddField('Fan Inlet Node Name', FanInletNode);
        Obj.AddField('Fan Outlet Node Name', FanOutletNode);
        Obj.AddField('Setpoint Node or NodeList Name', THVACComponent(SetpointComponents[i]).SupplyOutletNode);
      end;
      // electric, gas, steam heating coil
      if ((T_EP_Coil(SetpointComponents[i]).ComponentType = 'Coil:Heating:Electric') or
          (T_EP_Coil(SetpointComponents[i]).ComponentType =  'Coil:Heating:Gas') or
          (T_EP_Coil(SetpointComponents[i]).ComponentType =  'Coil:Heating:Steam')) then
      begin
        if THVACComponent(SetpointComponents[i]).SetPtMgrName <> '' then
        begin
          Obj := IDF.AddObject('SetpointManager:Scheduled');
          Obj.AddField('Name', THVACComponent(SetpointComponents[i]).Name + ' MixedAir Manager');
          Obj.AddField('Control Variable', 'Temperature', '{Temperature | Others}');
          Obj.AddField('Schedule Name', THVACComponent(SetpointComponents[i]).SetPtMgrName);
          Obj.AddField('Setpoint Node or NodeList Name', THVACComponent(SetpointComponents[i]).SupplyOutletNode);
        end
        else
        begin
          Obj := IDF.AddObject('SetpointManager:MixedAir');
          Obj.AddField('Name', THVACComponent(SetpointComponents[i]).Name + ' MixedAir Manager');
          Obj.AddField('Control Variable', 'Temperature');
          Obj.AddField('Reference Setpoint Node Name', OutletNode);
          Obj.AddField('Fan Inlet Node Name', FanInletNode);
          Obj.AddField('Fan Outlet Node Name', FanOutletNode);
          Obj.AddField('Setpoint Node or NodeList Name', THVACComponent(SetpointComponents[i]).SupplyOutletNode);
        end
      end;
      // humidifier
      if SameText(T_EP_Humidifier(SetpointComponents[i]).ComponentType,'Humidifier:Steam:Electric') then
      begin
        Obj := IDF.AddObject('SetpointManager:SingleZone:Humidity:Minimum');
        Obj.AddField('Name', THVACComponent(SetpointComponents[i]).Name + ' HUMRAT Setpoint');
        Obj.AddField('Control Variable', '');
        Obj.AddField('Schedule Name', '');
        Obj.AddField('Setpoint Node or NodeList Name', THVACComponent(SetpointComponents[i]).SupplyOutletNode);
        // need a governing zone here , assume first zone with humidistat will work well enough
        Obj.AddField('Control Zone Air Node Name', HumidityMinControlZone + ' Air Node');
      end;
      // desiccant system
      if SameText(T_EP_DesiccantSystem(SetpointComponents[i]).ComponentType, 'Dehumidifier:Desiccant:System') then
      begin
        if bUseHumidistat then
        begin
          Obj := IDF.AddObject('SetpointManager:SingleZone:Humidity:Maximum');
          Obj.AddField('Name', THVACComponent(SetpointComponents[i]).Name + ' HUMRAT Setpoint');
          Obj.AddField('Control Variable', '');
          Obj.AddField('Schedule Name', '');
          Obj.AddField('Setpoint Node or NodeList Name', THVACComponent(SetpointComponents[i]).SupplyOutletNode);
          // need a governing zone here , assume first zone with humidistat will work well enough
          Obj.AddField('Control Zone Air Node Name', HumidityMaxControlZone + ' Air Node');
          // mixed air setpoint manager
          Obj := IDF.AddObject('SetpointManager:MixedAir');
          Obj.AddField('Name', THVACComponent(SetpointComponents[i]).Name + ' SAT Manager');
          Obj.AddField('Control Variable', 'Temperature', '{Temperature}');
          Obj.AddField('Reference Setpoint Node Name', OutletNode);
          Obj.AddField('Fan Inlet Node Name', FanInletNode);
          Obj.AddField('Fan Outlet Node Name', FanOutletNode);
          Obj.AddField('Setpoint Node or NodeList Name', THVACComponent(SetpointComponents[i]).SupplyOutletNode);
        end
        else
        begin
          Obj := IDF.AddObject('SetpointManager:MixedAir');
          Obj.AddField('Name', THVACComponent(SetpointComponents[i]).Name + ' SAT Manager');
          Obj.AddField('Control Variable', 'Temperature', '{Temperature}');
          Obj.AddField('Reference Setpoint Node Name', OutletNode);
          Obj.AddField('Fan inlet node name', FanInletNode);
          Obj.AddField('Fan outlet node name', FanOutletNode);
          Obj.AddField('Name of the set point Node', THVACComponent(SetpointComponents[i]).SupplyOutletNode);
        end;
      end;
    end;
    // recirc branch components
    for i := 0 to RecircSetpointComponents.Count - 1 do
    begin
      if not AnsiContainsStr(T_EP_Coil(RecircSetpointComponents[i]).SupplyOutletNode, 'Supply Equipment Outlet Node') then
      begin
        if RecircSetpointComponents[i] is T_EP_Coil then
        begin
          // chilled water coil
          if ((T_EP_Coil(RecircSetpointComponents[i]).ComponentType = 'Coil:Cooling:Water') or
              (T_EP_Coil(RecircSetpointComponents[i]).ComponentType = 'Coil:Cooling:Water:DetailedGeometry')) then
          begin
            if bUseHumidistat then
            begin
              Obj := IDF.AddObject('SetpointManager:SingleZone:Humidity:Maximum');
              Obj.AddField('Name', THVACComponent(RecircSetpointComponents[i]).Name + ' HUMRAT Setpoint');
              Obj.AddField('Control Variable', '');
              Obj.AddField('Schedule Name', '');
              Obj.AddField('Setpoint Node or NodeList Name', THVACComponent(RecircSetpointComponents[i]).SupplyOutletNode);
              // need a governing zone here , assume first zone with humidistat will work well enough
              Obj.AddField('Control Zone Air Node Name', HumidityMaxControlZone + ' Air Node');
              // if user provides setpoint manager schedule name
              if THVACComponent(RecircSetpointComponents[i]).SetPtMgrName <> '' then
              begin
                Obj := IDF.AddObject('SetpointManager:Scheduled');
                Obj.AddField('Name', THVACComponent(RecircSetpointComponents[i]).Name + ' SAT Manager');
                Obj.AddField('Control Variable', 'Temperature', '{Temperature | Others}');
                Obj.AddField('Schedule Name', THVACComponent(RecircSetpointComponents[i]).SetPtMgrName);
                Obj.AddField('Setpoint Node or NodeList Name', THVACComponent(RecircSetpointComponents[i]).SupplyOutletNode);
              end
              else // mixed air setpoint manager
              begin
                Obj := IDF.AddObject('SetpointManager:MixedAir');
                Obj.AddField('Name', THVACComponent(RecircSetpointComponents[i]).Name + ' SAT Manager');
                Obj.AddField('Control Variable', 'Temperature', '{Temperature}');
                Obj.AddField('Reference Setpoint Node Name', RecircOutletNode);
                Obj.AddField('Fan Inlet Node Name', RecircFanInletNode);
                Obj.AddField('Fan Outlet Node Name', RecircFanOutletNode);
                Obj.AddField('Setpoint Node or NodeList Name', THVACComponent(RecircSetpointComponents[i]).SupplyOutletNode);
              end;
            end
            else
            begin
              if THVACComponent(RecircSetpointComponents[i]).SetPtMgrName <> '' then
              begin
                Obj := IDF.AddObject('SetpointManager:Scheduled');
                Obj.AddField('Name', THVACComponent(RecircSetpointComponents[i]).Name + ' SAT Manager');
                Obj.AddField('Control Variable', 'Temperature', '{Temperature | Others}');
                Obj.AddField('Schedule Name', THVACComponent(RecircSetpointComponents[i]).SetPtMgrName);
                Obj.AddField('Setpoint Node or NodeList Name', THVACComponent(RecircSetpointComponents[i]).SupplyOutletNode);
              end
              else
              begin
                Obj := IDF.AddObject('SetpointManager:MixedAir');
                Obj.AddField('Name', THVACComponent(RecircSetpointComponents[i]).Name + ' SAT Manager');
                Obj.AddField('Control Variable', 'Temperature', '{Temperature}');
                Obj.AddField('Reference Setpoint Node Name', RecircOutletNode);
                Obj.AddField('Fan Inlet Node Name', RecircFanInletNode);
                Obj.AddField('Fan Outlet Node Name', RecircFanOutletNode);
                Obj.AddField('Setpoint Node or NodeList Name', THVACComponent(RecircSetpointComponents[i]).SupplyOutletNode);
              end;
            end;
          end
          // heating hot water coil
          else if T_EP_Coil(RecircSetpointComponents[i]).ComponentType = 'Coil:Heating:Water' then
          begin
            if THVACComponent(RecircSetpointComponents[i]).SetPtMgrName <> '' then
            begin
              Obj := IDF.AddObject('SetpointManager:Scheduled');
              Obj.AddField('Name', THVACComponent(RecircSetpointComponents[i]).Name + ' SAT Manager');
              Obj.AddField('Control Variable', 'Temperature', '{Temperature | Others}');
              Obj.AddField('Schedule Name', THVACComponent(RecircSetpointComponents[i]).SetPtMgrName);
              Obj.AddField('Setpoint Node or NodeList Name', THVACComponent(RecircSetpointComponents[i]).SupplyOutletNode);
            end
            else
            begin
              Obj := IDF.AddObject('SetpointManager:MixedAir');
              Obj.AddField('Name', THVACComponent(RecircSetpointComponents[i]).Name + ' SAT Manager');
              Obj.AddField('Control Variable', 'Temperature', '{Temperature}');
              Obj.AddField('Reference Setpoint Node Name', RecircOutletNode);
              Obj.AddField('Fan Inlet Node Name', RecircFanInletNode);
              Obj.AddField('Fan Outlet Node Name', RecircFanOutletNode);
              Obj.AddField('Setpoint Node or NodeList Name', THVACComponent(RecircSetpointComponents[i]).SupplyOutletNode);
            end;
          end
          // DX cooling coil
          else if SameText(T_EP_Coil(RecircSetpointComponents[i]).ComponentType, 'CoilSystem:Cooling:DX') then
          begin
            if bUseHumidistat then
            begin
              Obj := IDF.AddObject('SetpointManager:SingleZone:Humidity:Maximum');
              Obj.AddField('Name', THVACComponent(RecircSetpointComponents[i]).Name + ' HUMRAT Setpoint');
              Obj.AddField('Control Variable', '');
              Obj.AddField('Schedule Name', '');
              Obj.AddField('Setpoint Node or NodeList Name', THVACComponent(RecircSetpointComponents[i]).SupplyOutletNode);
              // need a governing zone here , assume first zone with humidistat will work well enough
              Obj.AddField('Control Zone Air Node Name', HumidityMaxControlZone + ' Air Node');
              // if user provides setpoint manager schedule name
              if THVACComponent(RecircSetpointComponents[i]).SetPtMgrName <> '' then
              begin
                Obj := IDF.AddObject('SetpointManager:Scheduled');
                Obj.AddField('Name', THVACComponent(RecircSetpointComponents[i]).Name + ' SAT Manager');
                Obj.AddField('Control Variable', 'Temperature', '{Temperature | Others}');
                Obj.AddField('Schedule Name', THVACComponent(RecircSetpointComponents[i]).SetPtMgrName);
                Obj.AddField('Setpoint Node or NodeList Name', THVACComponent(RecircSetpointComponents[i]).SupplyOutletNode);
              end
              else // mixed air setpoint manager
              begin
                Obj := IDF.AddObject('SetpointManager:MixedAir');
                Obj.AddField('Name', THVACComponent(RecircSetpointComponents[i]).Name + ' SAT Manager');
                Obj.AddField('Control Variable', 'Temperature', '{Temperature}');
                Obj.AddField('Reference Setpoint Node Name', RecircOutletNode);
                Obj.AddField('Fan Inlet Node Name', RecircFanInletNode);
                Obj.AddField('Fan Outlet Node Name', RecircFanOutletNode);
                Obj.AddField('Setpoint Node or NodeList Name', THVACComponent(RecircSetpointComponents[i]).SupplyOutletNode);
              end;
            end
            else
            begin
              if THVACComponent(RecircSetpointComponents[i]).SetPtMgrName <> '' then
              begin
                Obj := IDF.AddObject('SetpointManager:Scheduled');
                Obj.AddField('Name', THVACComponent(RecircSetpointComponents[i]).Name + ' SAT Manager');
                Obj.AddField('Control Variable', 'Temperature', '{Temperature | Others}');
                Obj.AddField('Schedule Name', THVACComponent(RecircSetpointComponents[i]).SetPtMgrName);
                Obj.AddField('Setpoint Node or NodeList Name', THVACComponent(RecircSetpointComponents[i]).SupplyOutletNode);
              end
              else
              begin
                Obj := IDF.AddObject('SetpointManager:MixedAir');
                Obj.AddField('Name', THVACComponent(RecircSetpointComponents[i]).Name + ' SAT Manager');
                Obj.AddField('Control Variable', 'Temperature', '{Temperature}');
                Obj.AddField('Reference Setpoint Node Name', RecircOutletNode);
                Obj.AddField('Fan Inlet Node Name', RecircFanInletNode);
                Obj.AddField('Fan Outlet Node Name', RecircFanOutletNode);
                Obj.AddField('Setpoint Node or NodeList Name', THVACComponent(RecircSetpointComponents[i]).SupplyOutletNode);
              end;
            end;
          end;
        end;
        // electric, gas, steam heating coil
        if ((T_EP_Coil(RecircSetpointComponents[i]).ComponentType = 'Coil:Heating:Electric') or
            (T_EP_Coil(RecircSetpointComponents[i]).ComponentType =  'Coil:Heating:Gas') or
            (T_EP_Coil(RecircSetpointComponents[i]).ComponentType =  'Coil:Heating:Steam')) then
        begin
          if THVACComponent(RecircSetpointComponents[i]).SetPtMgrName <> '' then
          begin
            Obj := IDF.AddObject('SetpointManager:Scheduled');
            Obj.AddField('Name', THVACComponent(RecircSetpointComponents[i]).Name + ' MixedAir Manager');
            Obj.AddField('Control Variable', 'Temperature', '{Temperature | Others}');
            Obj.AddField('Schedule Name', THVACComponent(RecircSetpointComponents[i]).SetPtMgrName);
            Obj.AddField('Setpoint Node or NodeList Name', THVACComponent(RecircSetpointComponents[i]).SupplyOutletNode);
          end
          else
          begin
            Obj := IDF.AddObject('SetpointManager:MixedAir');
            Obj.AddField('Name', THVACComponent(RecircSetpointComponents[i]).Name + ' MixedAir Manager');
            Obj.AddField('Control Variable', 'Temperature');
            Obj.AddField('Reference Setpoint Node Name', RecircOutletNode);
            Obj.AddField('Fan Inlet Node Name', RecircFanInletNode);
            Obj.AddField('Fan Outlet Node Name', RecircFanOutletNode);
            Obj.AddField('Setpoint Node or NodeList Name', THVACComponent(RecircSetpointComponents[i]).SupplyOutletNode);
          end
        end;
      end;
    end;
  end;
  Obj := IDF.AddObject('Sizing:System');
  Obj.AddField('AirLoop Name', Name);
  Obj.AddField('Type Of Load To Size On', self.TypeOfLoadToSizeOn, '{}');
  if SuppressOA then
    Obj.AddField('Design Outdoor Air Flow Rate', '0.0', '{m3/s}')
  else
    Obj.AddField('Design Outdoor Air Flow Rate', 'AUTOSIZE', '{m3/s}');
  Obj.AddField('Minimum System Air Flow Ratio', MinSystemAirFlowRatio, '{}');
  Obj.AddField('Preheat Design Temperature', '7.0', '{C}');
  Obj.AddField('Preheat Design Humidity Ratio', '0.008',  '{kg-H2O/kg-air}');
  Obj.AddField('Precool Design Temperature', CoolingSATTemperature, '{C}');
  Obj.AddField('Precool Design Humidity Ratio', '0.008', '{kg-H2O/kg-air}');
  Obj.AddField('Central Cooling Design Supply Air Temperature', CoolingSATTemperature, '{C}'); //
  if SameText(DistributionType, 'MultiZone') then // assumption here, may need different check
    Obj.AddField('Central Heating Design Supply Air Temperature', HeatingSATTemperature, '{C}') // will be parameter, but not yet implemented
  else
    Obj.AddField('Central Heating Design Supply Air Temperature', '40.0', '{C}'); // will be parameter, but not yet implemented
  Obj.AddField('Sizing Option', SysSizingCoincidence, '{Coincident | NonCoincident}');
  Obj.AddField('100% Outdoor Air in Cooling', SysSizingCooling100pcntOA, '{Yes | No}');
  Obj.AddField('100% Outdoor Air in Heating', SysSizingHeating100pcntOA, '{Yes | No}');
  Obj.AddField('Central Cooling Design Supply Air Humidity Ratio', SysSizingCoolingSupAirHumidityRatio, '{kg-H2O/kg-air}');
  Obj.AddField('Central Heating Design Supply Air Humidity Ratio', SysSizingHeatingSupAirHumidityRatio, '{kg-H2O/kg-air}');
  Obj.AddField('Cooling Design Air Flow Method', 'DesignDay');
  Obj.AddField('Cooling Design Air Flow Rate', '0.0', '{m3/s}');
  Obj.AddField('Heating Design Air Flow Method', 'DesignDay');
  Obj.AddField('Heating Design Air Flow Rate', '0.0', '{m3/s}');
  Obj.AddField('System Outdoor Air Method', SysOaMethod, '{ ZoneSum | VentilationRateProcedure }');
  Obj.AddField('Zone Maximum Outdoor Air Fraction', '1.0');
  //availability managers
  if UseNightCycle then
  begin
    Obj := IDF.AddObject('AvailabilityManagerAssignmentList');
    Obj.AddField('Name', Name + ' Availability Manager List');
    Obj.AddField('Availability Manager 1 Object Type', 'AvailabilityManager:NightCycle');
    Obj.AddField('Availability Manager 1 Name', Name + ' Availability Manager');
    //night cycle availability manager
    Obj := IDF.AddObject('AvailabilityManager:NightCycle');
    Obj.AddField('Name', Name + ' Availability Manager', '', '*****Also must set MinOA schedule to 0 at night');
    if NightCycleAvailabiltySchedule <> '' then
      Obj.AddField('Availability Schedule Name', NightCycleAvailabiltySchedule)
    else
      Obj.AddField('Availability Schedule Name', 'Always_On');
    if NightCycleFanSchedule <> '' then
      Obj.AddField('Fan Schedule Name', NightCycleFanSchedule)
    else
      Obj.AddField('Fan Schedule Name', OperationSchedule);
    if NightCycleControlType <> '' then
      Obj.AddField('Control Type', NightCycleControlType, '{CycleOnAny | CycleOnControlZone | CycleOnAnyZoneFansOnly}')
    else
      Obj.AddField('Control Type', 'CycleOnAny', '{CycleOnAny | CycleOnControlZone | CycleOnAnyZoneFansOnly}');
    if NightCycleThermostatTolerance > 0.0 then
      Obj.AddField('Thermostat Tolerance', NightCycleThermostatTolerance, '{delta C}')
    else
      Obj.AddField('Thermostat Tolerance', '1.0', '{delta C}');
    if NightCycleCyclingRunTime > 0.0 then
      Obj.AddField('Cycling Run Time', NightCycleCyclingRunTime, '{s}')
    else
      Obj.AddField('Cycling Run Time', '1800', '{s}');
  end
  else if UseLowTempTurnOff then
  begin
    Obj := IDF.AddObject('AvailabilityManagerAssignmentList');
    Obj.AddField('Name', Name + ' Availability Manager List');
    Obj.AddField('Availability Manager 1 Object Type', 'AvailabilityManager:LowTemperatureTurnOff');
    Obj.AddField('Availability Manager 1 Name', Name + 'Turn off Availability Manager');
    //availability manager
    Obj := IDF.AddObject('AvailabilityManager:LowTemperatureTurnOff');
    Obj.AddField('Name', Name + 'Turn off Availability Manager');
    Obj.AddField('Sensor Node Name', T_EP_Zone(ZonesServed[0]).Name + ' Return Air Node Name');
    Obj.AddField('Temperature', '22.0');
  end
  else if UseDirectEvapTurnOff then
  begin
    Obj := IDF.AddObject('AvailabilityManagerAssignmentList');
    Obj.AddField('Name', Name + ' Availability Manager List');
    Obj.AddField('Availability Manager 1 Object Type', 'AvailabilityManager:LowTemperatureTurnOff');
    Obj.AddField('Availability Manager 1 Name', Name + 'Turn Off Availability Manager');
    //availability manager
    Obj := IDF.AddObject('AvailabilityManager:LowTemperatureTurnOff');
    Obj.AddField('Name', Name + 'Turn Off Availability Manager');
    Obj.AddField('Sensor Node Name', T_EP_Zone(ZonesServed[0]).Name + ' Air Node');
    Obj.AddField('Temperature', '23.0');
  end;
  //air loop branch list
  Obj := IDF.AddObject('BranchList');
  Obj.AddField('Name', Name + ' Air Loop Branches');
  if DualDuct and (RecircSupplyComponents.Count > 0) then
  begin
    Obj.AddField('Branch 1 Name', Name + ' Dual Duct Branch');
    Obj.AddField('Branch 2 Name', Name + ' Air Loop Main Branch');
    Obj.AddField('Branch 3 Name', Name + ' Recirc Branch');
  end
  else
  begin
    Obj.AddField('Branch 1 Name', Name + ' Air Loop Main Branch');
  end;
  // dual duct main branch
  if DualDuct and (RecircSupplyComponents.Count > 0) then
  begin
    // branch
    Obj := IDF.AddObject('Branch');
    Obj.AddField('Name', Name + ' Dual Duct Branch');
    Obj.AddField('Maximum Flow Rate', 'AUTOSIZE', '{m3/s}');
    Obj.AddField('Pressure Curve Name', '');
    Obj.AddField('Component 1 Object Type', 'Duct');
    Obj.AddField('Component 1 Name', Name + ' Inlet Duct');
    Obj.AddField('Component 1 Inlet Node Name', Name + ' Dual Duct Inlet Node');
    Obj.AddField('Component 1 Outlet Node Name', Name + ' Recirc Splitter Inlet Node');
    Obj.AddField('Component 1 Branch Control Type', 'Passive', '{ Active | Passive | SeriesActive | Bypass }');
    // duct
    Obj := IDF.AddObject('Duct');
    Obj.AddField('Name', Name + ' Inlet Duct');
    Obj.AddField('Inlet Node Name', Name + ' Dual Duct Inlet Node');
    Obj.AddField('Outlet Node Name', Name + ' Recirc Splitter Inlet Node');
  end;
  //air loop main branch
  Obj := IDF.AddObject('Branch');
  Obj.AddField('Name', Name + ' Air Loop Main Branch');
  Obj.AddField('Maximum Flow Rate', 'AUTOSIZE', '{m3/s}');
  Obj.AddField('Pressure Curve Name', '');
  inc := 1;
  if Assigned(OASystem) then begin
    Obj.AddField('Component ' + '1' + ' Object Type', 'AirLoopHVAC:OutdoorAirSystem');
    Obj.AddField('Component ' + '1' + ' Name', OASystem.Name);
    Obj.AddField('Component ' + '1' + ' Inlet Node Name', T_EP_OutsideAirSystem(OASystem).MixerRAInletNode);
    Obj.AddField('Component ' + '1' + ' Outlet Node Name', T_EP_OutsideAirSystem(OASystem).MixerOutletNode);
    Obj.AddField('Component ' + '1' + ' Branch Control Type', 'Passive', '{ Active | Passive | SeriesActive | Bypass }');
    inc := 2;
  end;
  for i := 0 to SupplyComponents.Count - 1 do
  begin
    Component := THVACComponent(SupplyComponents[i]);
    // Repeat and fill this block based on children of Equipment element
    Obj.AddField('Component ' + IntToStr(i + inc) + ' Object Type', Component.ComponentType);
    Obj.AddField('Component ' + IntToStr(i + inc) + ' Name', Component.Name);
    Obj.AddField('Component ' + IntToStr(i + inc) + ' Inlet Node Name', Component.SupplyInletNode);
    Obj.AddField('Component ' + IntToStr(i + inc) + ' Outlet Node Name', Component.SupplyOutletNode);
    Obj.AddField('Component ' + IntToStr(i + inc) + ' Branch Control Type', Component.ControlType, '{ Active | Passive | SeriesActive | Bypass }');
  end;
  //dual duct branch (if supply components exist)
  inc := 1;
  if RecircSupplyComponents.Count > 0 then
  begin
    Obj := IDF.AddObject('Branch');
    Obj.AddField('Name', Name + ' Recirc Branch');
    Obj.AddField('Maximum Flow Rate', 'AUTOSIZE', '{m3/s}');
    Obj.AddField('Pressure Curve Name', '');
    for i := 0 to RecircSupplyComponents.Count - 1 do
    begin
      Component := THVACComponent(RecircSupplyComponents[i]);
      // Repeat and fill this block based on children of Equipment element
      Obj.AddField('Component ' + IntToStr(i + inc) + ' Object Type', Component.ComponentType);
      Obj.AddField('Component ' + IntToStr(i + inc) + ' Name', Component.Name);
      Obj.AddField('Component ' + IntToStr(i + inc) + ' Inlet Node Name', Component.SupplyInletNode);
      Obj.AddField('Component ' + IntToStr(i + inc) + ' Outlet Node Name', Component.SupplyOutletNode);
      Obj.AddField('Component ' + IntToStr(i + inc) + ' Branch Control Type', Component.ControlType, '{ Active | Passive | SeriesActive | Bypass }');
    end;
  end;
  // ksb: write out the oa system if it exists
  if Assigned(OASystem) then OASystem.ToIDF;
  for i := 0 to SupplyComponents.Count - 1 do
  begin
    THVACComponent(SupplyComponents[i]).ToIDF;
  end;
  if RecircSupplyComponents.Count > 0 then
  begin
    for i := 0 to RecircSupplyComponents.Count - 1 do
    begin
      THVACComponent(RecircSupplyComponents[i]).ToIDF;
    end;
  end;
  InletNode := Name + ' Zone Equipment Inlet Node';
  OutletNode := Name + ' Zone Equipment Outlet Node';
  RecircInletNode := Name + ' Zone Equipment Recirc Inlet Node';
  RecircOutletNode := Name + ' Zone Equipment Recirc Outlet Node';
  // it is idiosyncratic that both ZONE SUPPLY PLENUM and ZONE SPLITTER are required
  i := 1;
  // ksb: supply air path
  // ksb: This is not my code.  I only worked on the return plenums
  Obj := IDF.AddObject('AirLoopHVAC:SupplyPath');
  Obj.AddField('Name', Name + ' Supply Path');
  Obj.AddField('Supply Air Path Inlet Node Name', InletNode);
  if UseSupplyPlenum then
  begin
    Obj.AddField('Component ' + IntToStr(i) + ' Object Type' , 'AirLoopHVAC:SupplyPlenum');
    Obj.AddField('Component ' + IntToStr(i) + ' Name' , Name + ' Supply Plenum');
    i := i + 1;
  end;
  Obj.AddField('Component ' + IntToStr(i) + ' Object Type', 'AirLoopHVAC:ZoneSplitter');
  Obj.AddField('Component ' + IntToStr(i) + ' Name', Name + ' Supply Air Splitter');
  if DualDuct and (RecircSupplyComponents.Count > 0) then
  begin
    Obj := IDF.AddObject('AirLoopHVAC:SupplyPath');
    Obj.AddField('Name', Name + ' RC Supply Path');
    Obj.AddField('Supply Air Path Inlet Node Name', RecircInletNode);
    Obj.AddField('Component ' + IntToStr(i) + ' Object Type', 'AirLoopHVAC:ZoneSplitter');
    Obj.AddField('Component ' + IntToStr(i) + ' Name', Name + ' RC Supply Air Splitter');
  end;
  if UseSupplyPlenum then
  begin
    Obj := IDF.AddObject('AirLoopHVAC:SupplyPlenum');
    Obj.AddField('Name', Name + ' Supply Plenum');
    Obj.AddField('Zone Name', SupplyPlenumZoneName);
    Obj.AddField('Zone Node Name', SupplyPlenumZoneName + ' Plenum Node');
    Obj.AddField('Inlet Node Name', InletNode);
    Obj.AddField('Outlet 1 Node Name', OutletNode);
  end;
  Obj := IDF.AddObject('AirLoopHVAC:ZoneSplitter');
  Obj.AddField('Name', Name + ' Supply Air Splitter');
  Obj.AddField('Inlet Node Name', InletNode);
  for i := 0 to DemandComponents.Count - 1 do
  begin
    Obj.AddField('Outlet '+ IntToStr(i + 1) + ' Node Name', THVACComponent(DemandComponents[i]).DemandInletNode);
  end;
  if DualDuct and (RecircSupplyComponents.Count > 0) then
  begin
    Obj := IDF.AddObject('AirLoopHVAC:ZoneSplitter');
    Obj.AddField('Name', Name + ' RC Supply Air Splitter');
    Obj.AddField('Inlet Node Name', RecircInletNode);
    for i := 0 to DemandComponents.Count - 1 do
    begin
      Obj.AddField('Outlet '+ IntToStr(i + 1) + ' Node Name', 'RC ' + THVACComponent(DemandComponents[i]).DemandInletNode);
    end;
  end;
  // ksb: return air path
  Obj := IDF.AddObject('AirLoopHVAC:ReturnPath');
  Obj.AddField('Name', Name + ' Return Air Path');
  Obj.AddField('Return Air Path Outlet Node Name', OutletNode);
  if UseReturnPlenum then
  begin
    Obj.AddField('Component 1 Object Type', 'AirLoopHVAC:ReturnPlenum');
    Obj.AddField('Component 1 Name', Name + ' Return Plenum');
    Obj.AddField('Component 2 Object Type', 'AirLoopHVAC:ZoneMixer');
    Obj.AddField('Component 2 Name', Name + ' Return Air Mixer');
  end
  else
  begin
    Obj.AddField('Component 1 Object Type', 'AirLoopHVAC:ZoneMixer');
    Obj.AddField('Component 1 Name', Name + ' Return Air Mixer');
  end;
  if UseReturnPlenum then
  begin
    Obj := IDF.AddObject('AirLoopHVAC:ReturnPlenum');
    Obj.AddField('Name', Name + ' Return Plenum');
    Obj.AddField('Zone Name', ReturnPlenumZoneName);
    Obj.AddField('Zone Node Name', ReturnPlenumZoneName + 'PlenumNode');
    Obj.AddField('Outlet Node Name', ReturnPlenumZoneName + 'PlenumOutletNode');
    Obj.AddField('Induced Air Outlet Node or NodeList Name', '');
    for i := 0 to ZonesServed.Count - 1 do begin
      Obj.AddField('Inlet ' + IntToStr(i+1) + ' Node Name', T_EP_Zone(ZonesServed[i]).Name + ' Return Air Node Name');
    end;
    Obj := IDF.AddObject('AirLoopHVAC:ZoneMixer');
    Obj.AddField('Name', Name + ' Return Air Mixer');
    Obj.AddField('Outlet Node Name', OutletNode);
    Obj.AddField('Inlet 1 Node Name', ReturnPlenumZoneName + 'PlenumOutletNode');
  end
  else
  begin
    Obj := IDF.AddObject('AirLoopHVAC:ZoneMixer');
    Obj.AddField('Name', Name + ' Return Air Mixer');
    Obj.AddField('Outlet Node Name', OutletNode);
    for i := 0 to ZonesServed.Count - 1 do
    begin
      Obj.AddField('Inlet ' + IntToStr(i + 1) + ' Node Name ' , T_EP_Zone(ZonesServed[i]).Name + ' Return Air Node Name');
    end;
  end;
  //EMS Code
  if not SameText(EmsDataSetKey, '') then
  begin
    IDF.AddComment('');// intentional blank line
    IDF.AddComment(Name + ' EMS Code');
    EmsPreProcMacro := TPreProcMacro.Create('include/HPBEmsCode.imf');
    CleanName := StringReplace(Name, ' ', '_', [rfReplaceAll]); //replace spaces
    CleanName := StringReplace(CleanName, '-', '_', [rfReplaceAll]); //replace dashes
    CleanName := StringReplace(CleanName, ':', '_', [rfReplaceAll]); //replace colons
    CleanZoneName := StringReplace(T_EP_Zone(ZonesServed[0]).Name, ' ', '_', [rfReplaceAll]); //replace spaces
    CleanZoneName := StringReplace(CleanZoneName, '-', '_', [rfReplaceAll]); //replace dashes
    CleanZoneName := StringReplace(CleanZoneName, ':', '_', [rfReplaceAll]); //replace colons
    try
      EmsString := EmsPreProcMacro.GetDefinedText(EmsDataSetKey);
      EmsString := ReplaceRegExpr('#{SystemName}', EmsString, Name, False);
      EmsString := ReplaceRegExpr('#{CleanSystemName}', EmsString, CleanName, False);
      if SameText(EMSTurnDownRatio,'') then EMSTurnDownRatio := '0.40';
      EmsString := ReplaceRegExpr('#{EMSTurnDownRatio}', EmsString, EMSTurnDownRatio, False);
      EmsString := ReplaceRegExpr('#{ZoneName}', EmsString, T_EP_Zone(ZonesServed[0]).Name, False);
      EmsString := ReplaceRegExpr('#{CleanZoneName}', EmsString, CleanZoneName, False);
      EmsString := ReplaceRegExpr(#$D#$A#$D#$A#$D#$A, EmsString, '', False);
      EmsStringList := TStringList.Create;
      EmsStringList.Add(EmsString);
      IDF.AddStringList(EmsStringList);
    finally
      EmsPreProcMacro.Free;
    end;
  end;
end;

procedure T_EP_AirSystem.Finalize;
begin
  inherited;
  if (SameText( self.DistributionType,'SingleZone') and
    (self.ZonesServed.Count > 0)) then
  begin
    self.HumidityMinControlZone := T_EP_Zone(self.ZonesServed.First).Name;
    self.HumidityMaxControlZone := T_EP_Zone(self.ZonesServed.First).Name;
  end
end;

{ T_EP_OutsideAirSystem }

constructor T_EP_OutsideAirSystem.Create(
  var aPrimaryAirSystem: T_EP_AirSystem;
  aUseEconomizer: boolean = false;
  aMotorizedDamper: boolean = true;
  aERV: TObject = nil);
begin
  ControlledComponents := TObjectList.Create;
  SetPointComponents := TObjectList.Create;
  SupplyComponents := TObjectList.Create;
  PrimaryAirSystem := aPrimaryAirSystem;
  UseEconomizer := aUseEconomizer;
  MotorizedDamper := aMotorizedDamper;
  ERV := aERV;
  DemandControlVentilation := false;
  MixerName := PrimaryAirSystem.Name + '_OAMixing Box';
  Name := PrimaryAirSystem.Name + '_OA';
  // ksb: add self to a primary air system
  // ksb: the oa system will be destroyed with the primary air system
  PrimaryAirSystem.OASystem := self;
  if Assigned(ERV) then begin
    T_EP_HeatRecoveryAirToAir(ERV).System := self;
    self.SetPointComponents.add(ERV);
  end;
end;

destructor T_EP_OutsideAirSystem.Destroy;
begin
  inherited;
  ControlledComponents.Free;
  SetPointComponents.Free;
  SupplyComponents.Free;
  OAMixerValue.Free;
  ERV.Free;
end;

procedure T_EP_OutsideAirSystem.Finalize;
var
  i: integer;
  NodeName: string;
  Component: THVACComponent;
  Component1: THVACComponent;
  Component2: THVACComponent;
  iZone: Integer;
begin
  // ksb: the outdoor air node name
  OANodeName := PrimaryAirSystem.Name + '_OAInlet Node';
  // ksb: MixerOutletNode finalized by main air system
  // ksb: MixerRAInletNode finalized by main air system
  // ksb: Connect equipment in order of fluid flow direction
  if SupplyComponents.Count > 1 then
  begin
    for i := 0 to SupplyComponents.Count - 2 do
    begin
      Component1 := THVACComponent(SupplyComponents[i]);
      Component2 := THVACComponent(SupplyComponents[i + 1]);
      NodeName := Component1.Name + '-' + Component2.Name + 'Node';
      Component1.SupplyOutletNode := NodeName;
      Component2.SupplyInletNode := NodeName;
    end;
  end;
  // ksb: now handle the end nodes
  // ksb: we put the ERV last if it exists
  if Assigned(ERV) then
  begin
    if SupplyComponents.Count > 0 then
    begin
      // ksb: connect first supply component
      Component := THVACComponent(SupplyComponents[0]);
      NodeName := T_EP_HeatRecoveryAirToAir(ERV).Name + '-' + Component.Name + 'Node';
      Component.SupplyInletNode := NodeName;
      T_EP_HeatRecoveryAirToAir(ERV).SupplyInletNode := OANodeName;
      T_EP_HeatRecoveryAirToAir(ERV).SupplyOutletNode := NodeName;
      // ksb: connect last supply component
      Component := THVACComponent(SupplyComponents[SupplyComponents.Count - 1]);
      NodeName := Component.Name + '-' + MixerName + 'Node';
      Component.SupplyOutletNode := NodeName;
      MixerOAInletNode := NodeName;
    end
    else // ksb: there are no supply components besides the ERV
    begin
      // ksb: connect the ERV to the OA mixer
      NodeName := T_EP_HeatRecoveryAirToAir(ERV).Name + '-' + MixerName + 'Node';
      T_EP_HeatRecoveryAirToAir(ERV).SupplyInletNode := OANodeName;
      T_EP_HeatRecoveryAirToAir(ERV).SupplyOutletNode := NodeName;
      MixerOAInletNode := NodeName;
    end;
  end
  else // ksb: we are not assigned an ERV
  begin
    if SupplyComponents.Count > 0 then
    begin
      // ksb: connect first supply component
      Component := THVACComponent(SupplyComponents[0]);
      Component.SupplyInletNode := OANodeName;
      // ksb: connect last supply component
      Component := THVACComponent(SupplyComponents[SupplyComponents.Count - 1]);
      NodeName := Component.Name + '-' + MixerName + 'Node';
      Component.SupplyOutletNode := NodeName;
      MixerOAInletNode := NodeName;
    end
    else // ksb: there are no supply components at all
    begin
      // ksb: define the oa mixer oa node
      MixerOAInletNode := OANodeName;
    end;
  end;
  // ksb: now we deal with the relief air side of the oa mixer
  if Assigned(ERV) then
  begin
    NodeName := MixerName + '-' + T_EP_HeatRecoveryAirToAir(ERV).Name + 'Node';
    T_EP_HeatRecoveryAirToAir(ERV).ExhaustInletNode := NodeName;
    MixerReliefNode := NodeName;
    T_EP_HeatRecoveryAirToAir(ERV).ExhaustOutletNode := PrimaryAirSystem.Name + 'ERV Exhaust air node';
  end
  else // ksb: we do not have an ERV
  begin
    MixerReliefNode := PrimaryAirSystem.Name + '_OARelief Node';
  end;
  // determine if we are using demand control ventilation for any of the zones on this system
  for iZone := 0 to Zones.Count - 1 do
  begin
    if T_EP_Zone(Zones[iZone]).AirSysSupplySideOutletNode = PrimaryAirSystem.OutletNode then
    begin
      if T_EP_Zone(Zones[iZone]).DemandControlVentilation then
      begin
        DemandControlVentilation := true;
        break
      end;
    end;
  end;
end;

procedure T_EP_OutsideAirSystem.SetOAMixer(aOAMixer: TObject);
begin
  OAMixerValue := aOAMixer;
end;

procedure T_EP_OutsideAirSystem.ToIDF;
var
  EconomizerChoice: string;
  sMinOASched: string;
  i: integer;
  j: integer;
  fan: string;
  iZone: integer;
  iSL: integer;
  iNodeCount: integer;
  component: TSystemComponent;
  slZones: TObjectList;
  aZone: T_EP_Zone;
  Obj: TEnergyPlusObject;
  zoneHasOA: boolean;
  zoneHasArea: boolean;
  SumMaxOA: double;
  scope: string;
  AnyZoneHasDcv: boolean;
begin
  // ksb: the finalize routine should set the inlet and outlet node names for each of the components in the system
  finalize;
  // controller list
  Obj := IDF.AddObject('AirLoopHVAC:ControllerList');
  Obj.AddField('Name', Name + '_Controllers');
  Obj.AddField('Controller 1 Object Type', 'Controller:OutdoorAir');
  Obj.AddField('Controller 1 Name', PrimaryAirSystem.Name + '_OA_Controller');
  if ControlledComponents.Count > 0 then
  begin
    for i := 0 to ControlledComponents.Count - 1 do
    begin
      Obj.AddField('Controller ' + IntToStr(i + 2)+ ' Object Type' , 'Controller:WaterCoil');
      Obj.AddField('Controller ' + IntToStr(i + 2) + ' Name', TSystemComponent(ControlledComponents[i]).Name + '_Controller');
    end;
  end;
  // ejb: write out a controller for each of the controlled components
  if ControlledComponents.Count > 0 then
  begin
    for i := 0 to ControlledComponents.Count - 1 do
    begin
      if ControlledComponents[i] is T_EP_Coil then
      begin
        if ((T_EP_Coil(ControlledComponents[i]).ComponentType = 'Coil:Cooling:Water') or
            (T_EP_Coil(ControlledComponents[i]).ComponentType = 'Coil:Cooling:Water:DetailedGeometry')) then
        begin
          Obj := IDF.AddObject('Controller:WaterCoil');
          Obj.AddField('Name', THVACComponent(ControlledComponents[i]).Name + '_Controller');
          Obj.AddField('Control Variable', 'Temperature', '{Temperature | HumidityRatio | TemperatureAndHumidityRatio | Flow}');
          Obj.AddField('Action', 'Reverse', '{Normal | Reverse}');
          Obj.AddField('Actuator Variable', 'Flow', '{Flow}');
          Obj.AddField('Sensor Node Name', THVACComponent(ControlledComponents[i]).SupplyOutletNode);
          Obj.AddField('Actuator Node Name', THVACComponent(ControlledComponents[i]).DemandInletNode);
          Obj.AddField('Controller Convergence Tolerance', '', '{delta C}', 'Delta temp from setpoint');
          Obj.AddField('Maximum Actuated Flow', 'AUTOSIZE', '{m3/s}');
          Obj.AddField('Minimum Actuated Flow', '0.0', '{m3/s}');
        end
        else if T_EP_Coil(ControlledComponents[i]).ComponentType = 'Coil:Heating:Water' then
        begin
          Obj := IDF.AddObject('Controller:WaterCoil');
          Obj.AddField('Name', THVACComponent(ControlledComponents[i]).Name + '_Controller');
          Obj.AddField('Control Variable', 'Temperature', '{Temperature | HumidityRatio | TemperatureAndHumidityRatio | Flow}');
          Obj.AddField('Action', 'Normal', '{Normal | Reverse}');
          Obj.AddField('Actuator Variable', 'Flow', '{FLOW}');
          Obj.AddField('Sensor Node Name', THVACComponent(ControlledComponents[i]).SupplyOutletNode);
          Obj.AddField('Actuator Node Name', THVACComponent(ControlledComponents[i]).DemandInletNode);
          Obj.AddField('Controller Convergence Tolerance', '0.0001', '{delta C}', 'Delta temp from setpoint');
          Obj.AddField('Maximum Actuated Flow', 'AUTOSIZE', '{m3/s}');
          Obj.AddField('Minimum Actuated Flow', '0.0', '{m3/s}');
        end;
      end;
    end;
  end;
  // equipment list
  Obj := IDF.AddObject('AirLoopHVAC:OutdoorAirSystem:EquipmentList');
  Obj.AddField('Name', Name + '_Equipment');
  if Assigned(ERV) then
  begin
    Obj.AddField('Component 1 Object Type', T_EP_HeatRecoveryAirToAir(ERV).ComponentType);
    Obj.AddField('Component 1 Name', T_EP_HeatRecoveryAirToAir(ERV).Name);
  end;
  if SupplyComponents.Count > 0 then
  begin
    for i := 0 to SupplyComponents.Count - 1 do
    begin
      Obj.AddField('Component ' + IntToStr(i + 1) + ' Object Type', TSystemComponent(SupplyComponents[i]).ComponentType);
      Obj.AddField('Component ' + IntToStr(i + 1) + ' Name', TSystemComponent(SupplyComponents[i]).name);
    end;
  end;
  Obj.AddField('Component 1 Object Type', 'OutdoorAir:Mixer');
  Obj.AddField('Component 1 Name', MixerName);
  // air loop
  Obj := IDF.AddObject('AirLoopHVAC:OutdoorAirSystem');
  Obj.AddField('Name', Name);
  Obj.AddField('Controller List Name', Name + '_Controllers');
  Obj.AddField('Outdoor Air Equipment List Name', Name + '_Equipment');
  if PrimaryAirSystem.UseNightCycle or PrimaryAirSystem.UseLowTempTurnOff or PrimaryAirSystem.UseDirectEvapTurnOff then
    Obj.AddField('Availability Manager List Name', PrimaryAirSystem.Name + ' Availability Manager List')
  else
    Obj.AddField('Availability Manager List Name', '');
  // ksb: create some oa nodes
  Obj := IDF.AddObject('OutdoorAir:NodeList');
  Obj.AddField('Node or NodeList Name 1', PrimaryAirSystem.Name + '_OANode List');
  // node list
  Obj := IDF.AddObject('NodeList');
  Obj.AddField('Name', PrimaryAirSystem.Name + '_OANode List');
  Obj.AddField('Node 1 Name', OANodeName);
  // ksb: we get an outside air mixer automatically with this system
  // ksb: not treated like other "supply" components
  // in the future it might be good to make this its own component object
  Obj := IDF.AddObject('OutdoorAir:Mixer');
  Obj.AddField('Name', MixerName);
  Obj.AddField('Mixed Air Node Name', MixerOutletNode);
  Obj.AddField('Outdoor Air Stream Node Name', MixerOAInletNode);
  Obj.AddField('Relief Air Stream Node Name', MixerReliefNode);
  Obj.AddField('Return Air Stream Node Name', MixerRAInletNode);
  if Assigned(ERV) then
  begin
    T_EP_HeatRecoveryAirToAir(ERV).ToIDF;
    if T_EP_HeatRecoveryAirToAir(ERV).SetPtMgrName <> '' then
    begin
      Obj := IDF.AddObject('SetpointManager:Scheduled');
      Obj.AddField('Name',PrimaryAirSystem.Name + ' ERV Mixed Air Temp Manager');
      Obj.AddField('Control Variable', 'Temperature', '{Temperature | Others}');
      Obj.AddField('Schedule Name', T_EP_HeatRecoveryAirToAir(ERV).SetPtMgrName);
      Obj.AddField('Setpoint Node or NodeList Name', T_EP_HeatRecoveryAirToAir(ERV).SupplyOutletNode);
    end
    else
    begin
      Obj := IDF.AddObject('SetpointManager:MixedAir');
      Obj.AddField('Name',PrimaryAirSystem.Name + ' ERV Mixed Air Temp Manager');
      Obj.AddField('Control Variable','Temperature');
      Obj.AddField('Reference Setpoint Node Name', PrimaryAirSystem.OutletNode);
      Obj.AddField('Fan Inlet Node Name', PrimaryAirSystem.FanInletNode);
      Obj.AddField('Fan Outlet Node Name', PrimaryAirSystem.FanOutletNode);
      Obj.AddField('Setpoint Node or NodeList Name', T_EP_HeatRecoveryAirToAir(ERV).SupplyOutletNode);
    end;
    if SameText(PrimaryAirSystem.DistributionType, 'SingleZone') or UseEconomizer then
    begin
      if SetPtMgrName <> '' then
      begin
        Obj := IDF.AddObject('SetpointManager:Scheduled');
        Obj.AddField('Name', PrimaryAirSystem.Name + ' OA Mixed Air Temp Manager');
        Obj.AddField('Control Variable', 'Temperature', '{Temperature | Others}');
        Obj.AddField('Schedule Name', SetPtMgrName);
        Obj.AddField('Setpoint Node or NodeList Name', MixerOutletNode);
      end
      else
      begin
        Obj := IDF.AddObject('SetpointManager:MixedAir');
        Obj.AddField('Name', PrimaryAirSystem.Name + ' OA Mixed Air Temp Manager');
        Obj.AddField('Control Variable','Temperature');
        Obj.AddField('Reference Setpoint Node Name', PrimaryAirSystem.OutletNode);
        Obj.AddField('Fan Inlet Node Name', PrimaryAirSystem.FanInletNode);
        Obj.AddField('Fan Outlet Node Name', PrimaryAirSystem.FanOutletNode);
        Obj.AddField('Setpoint Node or NodeList Name', MixerOutletNode);
      end;
    end;
  end
  else
  begin
    // setpoint manager
      if SetPtMgrName <> '' then
      begin
        Obj := IDF.AddObject('SetpointManager:Scheduled');
        Obj.AddField('Name', PrimaryAirSystem.Name + ' OA Mixed Air Temp Manager');
        Obj.AddField('Control Variable', 'Temperature', '{Temperature | Others}');
        Obj.AddField('Schedule Name', SetPtMgrName);
        Obj.AddField('Setpoint Node or NodeList Name', MixerOutletNode);
      end
      else
      begin
        Obj := IDF.AddObject('SetpointManager:MixedAir');
        Obj.AddField('Name', PrimaryAirSystem.Name + ' OA Mixed Air Temp Manager');
        Obj.AddField('Control Variable','Temperature');
        Obj.AddField('Reference Setpoint Node Name', PrimaryAirSystem.OutletNode);
        Obj.AddField('Fan Inlet Node Name', PrimaryAirSystem.FanInletNode);
        Obj.AddField('Fan Outlet Node Name', PrimaryAirSystem.FanOutletNode);
        Obj.AddField('Setpoint Node or NodeList Name', MixerOutletNode);
      end;
    end;
  // ksb: write out a set point manager for each of the set point components
  if SetPointComponents.Count > 0 then
  begin
    for i := 0 to SetPointComponents.Count - 1 do
    begin
      Component := TSystemComponent(SetPointComponents[i]);
      if SameText(Component.ComponentType, 'HeatExchanger:AirToAir:SensibleAndLatent') then continue;
      if (SameText(Component.ComponentType , 'EvaporativeCooler:Indirect:ResearchSpecial')) or
        (SameText(Component.ComponentType , 'EvaporativeCooler:Direct:ResearchSpecial')) then
      begin
        if T_EP_EvaporativeCooler(Component).SetPtMgrName <> '' then
        begin
          Obj := IDF.AddObject('SetpointManager:Scheduled');
          Obj.AddField('Name',Component.Name + ' ' + 'SAT Manager');
          Obj.AddField('Control Variable', 'Temperature', '{Temperature | Others}');
          Obj.AddField('Schedule Name', T_EP_EvaporativeCooler(Component).SetPtMgrName);
          Obj.AddField('Setpoint Node or NodeList Name', Component.SupplyOutletNode);
        end
        else
        begin
          Obj := IDF.AddObject('SetpointManager:MixedAir');
          Obj.AddField('Name',Component.Name + ' ' + 'SAT Manager');
          Obj.AddField('Control Variable','Temperature','{Temperature | Others}');
          Obj.AddField('Reference Setpoint Node Name', PrimaryAirSystem.OutletNode);
          Obj.AddField('Fan Inlet Node Name', PrimaryAirSystem.FanInletNode);
          Obj.AddField('Fan Outlet Node Name', PrimaryAirSystem.FanOutletNode);
          Obj.AddField('Setpoint Node or NodeList Name', component.SupplyOutletNode);
        end;
      end
      else
      begin
        if Component.SetPtMgrName <> '' then
        begin
          Obj := IDF.AddObject('SetpointManager:Scheduled');
          Obj.AddField('Name',Component.Name + ' ' + 'SAT Manager');
          Obj.AddField('Control Variable', 'Temperature', '{Temperature | Others}');
          Obj.AddField('Schedule Name', Component.SetPtMgrName);
          Obj.AddField('Setpoint Node or NodeList Name', Component.SupplyOutletNode);
        end
        else
        begin
          Obj := IDF.AddObject('SetpointManager:MixedAir');
          Obj.AddField('Name',Component.Name + ' ' + 'SAT Manager');
          Obj.AddField('Control Variable','Temperature','{Temperature | Others}');
          Obj.AddField('Reference Setpoint Node Name', PrimaryAirSystem.OutletNode);
          Obj.AddField('Fan Inlet Node Name', PrimaryAirSystem.FanInletNode);
          Obj.AddField('Fan Outlet Node Name', PrimaryAirSystem.FanOutletNode);
          Obj.AddField('Setpoint Node or NodeList Name', component.SupplyOutletNode);
        end;
      end;
    end;
  end;
  // ksb: oa controller for the oa mixer
  Obj := IDF.AddObject('Controller:OutdoorAir');
  Obj.AddField('Name',PrimaryAirSystem.Name + '_OA_Controller');
  Obj.AddField('Relief Air Outlet Node Name', MixerReliefNode);
  Obj.AddField('Return Air Node Name', MixerRAInletNode);
  Obj.AddField('Mixed Air Node Name', MixerOutletNode);
  Obj.AddField('Actuator Node Name', OANodeName);
  // if system supports zones with demand control ventilation then let outdoor air go to 0
  // otherwise it will be autosized
  if DemandControlVentilation or SuppressOA then
    Obj.AddField('Minimum Outdoor Air Flow Rate', '0.0000', '{m3/s}')
  else
    Obj.AddField('Minimum Outdoor Air Flow Rate', 'AUTOSIZE', '{m3/s}');
  // if system ventilation effectiveness is specified, don't autosize OA controller
  // instead size the OA controller as the sum of the OA requirements of all the zones
  // divided by the system ventilation effectiveness, per ASHRAE STD 62.1-2004
  if SystemVentilationEffectiveness > 0.0 then
  begin
    SumMaxOA := 0.0;
    for iZone := 0 to Zones.Count - 1 do
    begin
      SumMaxOA := SumMaxOA + T_EP_Zone(Zones[iZone]).MaxOA;
    end;
    Obj.AddField('Maximum Outdoor Air Flow Rate', FloatToStr(SumMaxOA/SystemVentilationEffectiveness), '{m3/s}');
  end
  else if SuppressOA then
    Obj.AddField('Maximum Outdoor Air Flow Rate', '0.0000', '{m3/s}')
  else
    Obj.AddField('Maximum Outdoor Air Flow Rate', 'AUTOSIZE', '{m3/s}');
  if UseEconomizer then
  begin
    if EconomizerControlType <> '' then
      Obj.AddField('Economizer Control Type', EconomizerControlType)
    else
      Obj.AddField('Economizer Control Type', 'DifferentialEnthalpy');
  end
  else
    Obj.AddField('Economizer Control Type', 'NoEconomizer');
  Obj.AddField('Economizer Control Action Type', 'ModulateFlow');
  if EconomizerMaxLimitDBT > 0.0 then
    Obj.AddField('Economizer Maximum Limit Dry-Bulb Temperature', FloatToStr(EconomizerMaxLimitDBT), '{C}')
  else
    Obj.AddField('Economizer Maximum Limit Dry-Bulb Temperature', '28.0', '{C}');
  if EconomizerMaxLimitEnthalpy > 0.0 then
    Obj.AddField('Economizer Maximum Limit Enthalpy', FloatToStr(EconomizerMaxLimitEnthalpy), '{J/kg}')
  else
    Obj.AddField('Economizer Maximum Limit Enthalpy', '64000.0', '{J/kg}');
  Obj.AddField('Economizer Maximum Limit Dew-Point Temperature','');
  Obj.AddField('Electronic Enthalpy Limit Curve Name', '');
  Obj.AddField('Economizer Minimum Limit Dry-Bulb Temperature', '-100.0', '{C}');
  Obj.AddField('Lockout Type', 'NoLockout');
  Obj.AddField('Minimum Limit Type', 'FixedMinimum');
  if not (minOAMultiplierSchedule = '') then
    Obj.AddField('Minimum Outdoor Air Schedule Name', minOAMultiplierSchedule)
  else
  begin
    if MotorizedDamper then
      Obj.AddField('Minimum Outdoor Air Schedule Name', 'MinOA_MotorizedDamper_Sched')
    else
      Obj.AddField('Minimum Outdoor Air Schedule Name', 'MinOA_Sched');
  end;
  if not (MinOAFractionSchedule = '') then
    Obj.AddField('Minimum Fraction of Outdoor Air Schedule Name', MinOAFractionSchedule)
  else if ((MinOAFraction > 0.0) and (MinOAFraction <= 1.0)) then
    Obj.AddField('Minimum Fraction of Outdoor Air Schedule Name', Name + 'MinOAFracSchedule')
  else
    Obj.AddField('Minimum Fraction of Outdoor Air Schedule Name', '');
  if not (MaxOAFractionSchedule = '') then
    Obj.AddField('Maximum Fraction of Outdoor Air Schedule Name', MaxOAFractionSchedule)
  else
    Obj.AddField('Maximum Fraction of Outdoor Air Schedule Name', '');
  if UseControllerMechVent then
    Obj.AddField('Mechanical Ventilation Controller Name', Name + 'Mechanical Ventilation')
  else
    Obj.AddField('Mechanical Ventilation Controller Name', '');
  if UseControllerMechVent then
  begin
    slZones := TObjectList.Create;
    slZones.OwnsObjects:=false;
    try
      for iZone := 0 to Zones.Count - 1 do
      begin
        if T_EP_Zone(Zones[iZone]).AirSysSupplySideOutletNode = PrimaryAirSystem.OutletNode then
          slZones.Add(T_EP_Zone(Zones[iZone]));
      end;
      //create new ventilation object
      zoneHasArea := false;
      for iSL := 0 to slZones.Count - 1 do
      begin
        aZone := T_EP_Zone(slZones[iSL]);
        if (aZone.Area > 0.0) then
        begin
            zoneHasArea := true;
            break;
        end;
      end;
      zoneHasOA := false;
      for iSL := 0 to slZones.Count - 1 do
      begin
        aZone := T_EP_Zone(slZones[iSL]);
        if (aZone.OAPerArea > 0.0) or
          (aZone.OAPerPerson > 0.0) or
          (aZone.OAPerZone > 0.0) or
          (aZone.OAPerACH > 0.0) then
        begin
            zoneHasOA := true;
            break;
        end;
      end;
      if (zoneHasOA = true) and
        (zoneHasArea = true) then
      begin
        if not (EconomizerControlSchedule = '') then
          Obj.AddField('Time of Day Economizer Control Schedule Name', EconomizerControlSchedule)
        else
          Obj.AddField('Time of Day Economizer Control Schedule Name', '' );
        Obj.AddField('High Humidity Control', 'No' );
        Obj.AddField('Humidistat Control Zone Name', '');
        Obj.AddField('High Humidity Outdoor Air Flow Ratio', '');
        Obj.AddField('Control High Indoor Humidity Based on Outdoor Humidity Ratio', '');
        Obj.AddField('Heat Recovery Bypass Control Type', 'BypassWhenOAFlowGreaterThanMinimum');
        //mechanical ventilation controller
        Obj := IDF.AddObject('Controller:MechanicalVentilation');
        Obj.AddField('Name', Name + 'Mechanical Ventilation');
        if not (minOAMultiplierSchedule = '') then
          Obj.AddField('Availability Schedule Name', minOAMultiplierSchedule)
        else
        begin
          if MotorizedDamper then
            Obj.AddField('Availability Schedule Name', 'MinOA_MotorizedDamper_Sched')
          else
            Obj.AddField('Availability Schedule Name', 'MinOA_Sched');
        end;
        //test for DCV on system
        AnyZoneHasDcv := false;
        for iSL := 0 to slZones.Count - 1 do
        begin
          aZone := T_EP_Zone(slZones[iSL]);
          if aZone.DemandControlVentilation then AnyZoneHasDcv := true;
        end;
        if AnyZoneHasDcv then
          Obj.AddField('Demand Controlled Ventilation', 'Yes', '{ Yes | No }')
        else
          Obj.AddField('Demand Controlled Ventilation', 'No', '{ Yes | No }');
        if SameText(SystemOutdoorAirMethod, 'VRP') then SystemOutdoorAirMethod := 'VentilationRateProcedure';
        Obj.AddField('System Outdoor Air Method', SystemOutdoorAirMethod, '{ ZoneSum | VentilationRateProcedure | IndoorAirQualityProcedure }');
        Obj.AddField('Zone Maximum Outdoor Air Fraction', '1.0');
        for iSL := 0 to slZones.Count - 1 do
        begin
          aZone := T_EP_Zone(slZones[iSL]);
          Obj.AddField('Zone ' + IntToStr(iSL + 1) + ' Name', aZone.Name);
          Obj.AddField('Design Specification Outdoor Air Object Name ' + IntToStr(iSL + 1), aZone.Name + ' OA Design Spec');
          Obj.AddField('Design Specification Outdoor Air Object Name ' + IntToStr(iSL + 1), aZone.Name + ' Air Dist Design Spec');
        end;
      end;
    finally
      slZones.Free;
    end;
  end
  else
  begin
    //Obj.AddField('Mechanical Ventilation Controller Name',  '');
    if not (EconomizerControlSchedule = '') then
      Obj.AddField('Time of Day Economizer Control Schedule Name', EconomizerControlSchedule)
    else
      Obj.AddField('Time of Day Economizer Control Schedule Name', '' );
    Obj.AddField('High Humidity Control', 'No' );
    Obj.AddField('Humidistat Control Zone Name', '');
    Obj.AddField('High Humidity Outdoor Air Flow Ratio', '');
    Obj.AddField('Control High Indoor Humidity Based on Outdoor Humidity Ratio', '');
    Obj.AddField('Heat Recovery Bypass Control Type', 'BypassWhenOAFlowGreaterThanMinimum');
  end;
  //if min OA fraction is specified in the XML then write out schedule
  if ((MinOAFraction > 0.0) and (MinOAFraction <= 1.0)) then begin
    Obj := IDF.AddObject('Schedule:Compact');
    Obj.AddField('Name', name + 'MinOAFracSchedule');
    Obj.AddField('Schedule Type Limits Name', 'Fraction');
    Obj.AddField('Field 1', 'Through: 12/31');
    Obj.AddField('Field 2', 'For: AllDays');
    Obj.AddField('Field 3', 'Until: 24:00');
    Obj.AddField('Field 4', MinOAFraction);
  end;
  // ksb: now handle any components in the supply path of the oa mixer
  // ksb: write out each of the supply components
  if SupplyComponents.Count > 0 then
  begin
    for i := 0 to SupplyComponents.Count - 1 do
    begin
      Component := TSystemComponent(SupplyComponents[i]);
      Component.ToIDF;
      if ((Component.ComponentType = 'EvaporativeCooler:Indirect:ResearchSpecial') or
        (Component.ComponentType = 'EvaporativeCooler:Direct:ResearchSpecial')) then
      begin
        try
          if SupplyComponents.Count > 1 then
            if ((Component.ComponentType = 'EvaporativeCooler:Indirect:ResearchSpecial') and
              (TSystemComponent(SupplyComponents[i+1]).ComponentType = 'EvaporativeCooler:Direct:ResearchSpecial')) then continue;
        except
          // do nothing
        end;
        for j := 0 to Self.PrimaryAirSystem.SupplyComponents.Count -1 do
        begin
          if TSystemComponent(Self.PrimaryAirSystem.SupplyComponents[j]).ComponentType = 'AirLoopHVAC:UnitaryHeatCool' then
          begin
            Fan := TSystemComponent(Self.PrimaryAirSystem.SupplyComponents[j]).Name + '_FAN';
            break;
          end
          else if TSystemComponent(Self.PrimaryAirSystem.SupplyComponents[j]).ComponentType = 'Fan:ConstantVolume' then
          begin
            Fan := TSystemComponent(Self.PrimaryAirSystem.SupplyComponents[j]).Name;
            break;
          end
          else if TSystemComponent(Self.PrimaryAirSystem.SupplyComponents[j]).ComponentType = 'Fan:VariableVolume' then
          begin
            Fan := TSystemComponent(Self.PrimaryAirSystem.SupplyComponents[j]).Name;
            break;
          end
          else
            Fan := '-9999';
        end;
        if UseEvapCoolerEmsCode then
        begin
          Scope := StringReplace(Component.Name, ':', '_',[rfReplaceAll, rfIgnoreCase]);

          Obj := IDF.AddObject('EnergyManagementSystem:Sensor');
          Obj.AddField('Name',scope + 'SystemSupplyFlow');
          Obj.AddField('Output:Variable or Output:Meter Index Key Name', self.PrimaryAirSystem.Name + ' Zone Equipment Inlet Node');
          Obj.AddField('Output:Variable or Output:Meter Name','System Node MassFlowRate');

          Obj := IDF.AddObject('EnergyManagementSystem:InternalVariable');
          Obj.AddField('Name',Scope + 'OAMinFlow');
          Obj.AddField('Internal Data Index Key Name',self.PrimaryAirSystem.Name + '_OA_CONTROLLER');
          Obj.AddField('Internal Data Type','Outdoor Air Controller Minimum Mass Flow Rate');

          Obj := IDF.AddObject('EnergyManagementSystem:InternalVariable');
          Obj.AddField('Name',Scope + 'OAMaxFlow');
          Obj.AddField('Internal Data Index Key Name', fan);
          Obj.AddField('Internal Data Type','Fan Maximum Mass Flow Rate');

          Obj := IDF.AddObject('EnergyManagementSystem:Actuator');
          Obj.AddField('Name',Scope + 'OAFlowActuator');
          Obj.AddField('Actuated Component Unique Name',self.PrimaryAirSystem.Name + '_OA_CONTROLLER');
          Obj.AddField('Actuated Component Type','Outdoor Air Controller');
          Obj.AddField('Actuated Component Control Type','Air Mass Flow Rate');

          Obj := IDF.AddObject('EnergyManagementSystem:Sensor');
          Obj.AddField('Name',Scope + 'SystemReturnTemp');
          Obj.AddField('Output:Variable or Output:Meter Index Key Name',self.PrimaryAirSystem.Name + ' Supply Equipment Inlet Node' );
          Obj.AddField('Output:Variable or Output:Meter Name','System Node Temp');

          Obj := IDF.AddObject('EnergyManagementSystem:Sensor');
          Obj.AddField('Name',Scope + 'IDECSupplyTemp');
          Obj.AddField('Output:Variable or Output:Meter Index Key Name',component.SupplyOutletNode);
          Obj.AddField('Output:Variable or Output:Meter Name','System Node Temp');

          Obj := IDF.AddObject('EnergyManagementSystem:Sensor');
          Obj.AddField('Name',Scope + 'OAFlowSensor');
          Obj.AddField('Output:Variable or Output:Meter Index Key Name',self.OANodeName);
          Obj.AddField('Output:Variable or Output:Meter Name','System Node MassFlowRate');

          Obj := IDF.AddObject('EnergyManagementSystem:Sensor');
          Obj.AddField('Name',Scope + 'SystemMixedSP');
          Obj.AddField('Output:Variable or Output:Meter Index Key Name',self.MixerOutletNode);
          Obj.AddField('Output:Variable or Output:Meter Name','System Node Setpoint Temp');

          Obj := IDF.AddObject('EnergyManagementSystem:Sensor');
          Obj.AddField('Name',Scope + 'SystemMixedTemp');
          Obj.AddField('Output:Variable or Output:Meter Index Key Name',self.MixerOutletNode);
          Obj.AddField('Output:Variable or Output:Meter Name','System Node Temp');

          Obj := IDF.AddObject('EnergyManagementSystem:Sensor');
          Obj.AddField('Name',Scope + 'SystemMixedHR');
          Obj.AddField('Output:Variable or Output:Meter Index Key Name',self.MixerOutletNode);
          Obj.AddField('Output:Variable or Output:Meter Name','System Node Humidity Ratio');

          Obj := IDF.AddObject('EnergyManagementSystem:Sensor');
          Obj.AddField('Name',Scope + 'IDECSupplyEnth');
          Obj.AddField('Output:Variable or Output:Meter Index Key Name',component.SupplyOutletNode);
          Obj.AddField('Output:Variable or Output:Meter Name','System Node Enthalpy');

          Obj := IDF.AddObject('EnergyManagementSystem:Sensor');
          Obj.AddField('Name',Scope + 'SystemReturnEnth');
          Obj.AddField('Output:Variable or Output:Meter Index Key Name',self.PrimaryAirSystem.Name + ' Supply Equipment Inlet Node');
          Obj.AddField('Output:Variable or Output:Meter Name','System Node Enthalpy');

          Obj := IDF.AddObject('EnergyManagementSystem:ProgramCallingManager');
          Obj.AddField('Name',Scope + 'ControlManager');
          Obj.AddField('EnergyPlus Model Calling Point','InsideHVACSystemIterationLoop');
          Obj.AddField('Program Name 1',Scope + 'Control');

          Obj := IDF.AddObject('EnergyManagementSystem:Program');
          Obj.AddField('Name',Scope + 'Control');
          Obj.AddField('Program Line','SET SystemMixedTemp = ' + Scope + 'SystemMixedTemp');
          Obj.AddField('Program Line','SET SystemMixedHR = ' + Scope + 'SystemMixedHR');
          Obj.AddField('Program Line','SET IDECSupplyEnth = ' + Scope + 'IDECSupplyEnth');
          Obj.AddField('Program Line','SET SystemReturnEnth = ' + Scope + 'SystemReturnEnth');
          Obj.AddField('Program Line','SET SystemMixedSP = ' + Scope + 'SystemMixedSP');
          Obj.AddField('Program Line','SET SystemMixedSPEnth = @HFnTdbW SystemMixedSP SystemMixedHR');
          Obj.AddField('Program Line','SET OAMinFlow = ' + Scope + 'OAMinFlow');
          Obj.AddField('Program Line','SET IDECSupplyTemp = ' + Scope + 'IDECSupplyTemp');
          Obj.AddField('Program Line','SET SystemReturnTemp = ' + Scope + 'SystemReturnTemp');
          Obj.AddField('Program Line','SET SystemSupplyFlow = ' + Scope + 'SystemSupplyFlow');
          Obj.AddField('Program Line','SET OAFlowActuator = OAMinFlow');
          Obj.AddField('Program Line','SET tosetpoint = IDECSupplyTemp - SystemMixedSP');
          Obj.AddField('Program Line','IF (tosetpoint <= 0.0) && (SystemMixedSP < SystemReturnTemp)');
          Obj.AddField('Program Line','  SET numerator = SystemMixedSPEnth - SystemReturnEnth');
          Obj.AddField('Program Line','  SET denominator = IDECSupplyEnth - SystemReturnEnth');
          Obj.AddField('Program Line','  SET abs_denominator = @Abs denominator');
          Obj.AddField('Program Line','  IF (abs_denominator < 0.000001)');
          Obj.AddField('Program Line','    SET OAFlowActuator = SystemSupplyFlow');
          Obj.AddField('Program Line','  ELSE');
          Obj.AddField('Program Line','    SET OAFlowActuator = SystemSupplyFlow * numerator / denominator');
          Obj.AddField('Program Line','  ENDIF');
          Obj.AddField('Program Line','  IF (OAFlowActuator > SystemSupplyFlow)');
          Obj.AddField('Program Line','    SET OAFlowActuator = SystemSupplyFlow');
          Obj.AddField('Program Line','  ENDIF');
          Obj.AddField('Program Line','  IF (OAFlowActuator < OAMinFlow)');
          Obj.AddField('Program Line','    SET OAFlowActuator = OAMinFlow');
          Obj.AddField('Program Line','  ENDIF');
          Obj.AddField('Program Line','ENDIF');
          Obj.AddField('Program Line','IF (IDECSupplyTemp < SystemReturnTemp) && (SystemReturnTemp < SystemMixedSP)');
          Obj.AddField('Program Line','  SET OAFlowActuator = OAMinFlow');
          Obj.AddField('Program Line','ENDIF');
          Obj.AddField('Program Line','IF (SystemReturnTemp < IDECSupplyTemp) && (IDECSupplyTemp < SystemMixedSP)');
          Obj.AddField('Program Line','  SET OAFlowActuator = SystemSupplyFlow');
          Obj.AddField('Program Line','ENDIF');
          Obj.AddField('Program Line','IF (SystemMixedSP < IDECSupplyTemp) && (IDECSupplyTemp < SystemReturnTemp)');
          Obj.AddField('Program Line','  SET OAFlowActuator = SystemSupplyFlow');
          Obj.AddField('Program Line','ENDIF');
          Obj.AddField('Program Line','IF (SystemMixedSP < SystemReturnTemp) && (SystemReturnTemp < IDECSupplyTemp)');
          Obj.AddField('Program Line','  SET OAFlowActuator = OAMinFlow');
          Obj.AddField('Program Line','ENDIF');
          Obj.AddField('Program Line','SET ' + Scope + 'OAFlowActuator = OAFlowActuator');
        end;
      end;
    end;
  end;
end;

{ T_EP_LiquidSystem }

constructor T_EP_LiquidSystem.Create;
begin
  inherited;
  Name := 'Plant1';
  LoopType := 'Plant';
  ControlledComponents := TObjectList.Create;
  SetPointComponents  := TObjectList.Create;
  RecircControlledComponents := TObjectList.Create;
  RecircSetPointComponents  := TObjectList.Create;
  LoopTempSetpoint := 54.0;
  ExitTemp := 21.0;
  DeltaTemp := 5.0;
  UseUncontrolledLoop := false;
  UseWetFluidCooler := false;
end;

procedure T_EP_LiquidSystem.FigureSWHsizes;
var
  i: integer;
  component: THVACComponent;
begin
  SWHStorage := 0.0;
  SWHHeatingCapacity := 0.0;
  if SystemType = cSystemTypeHotWater then
  begin
    for i := 0 to DemandComponents.Count - 1 do
    begin
      Component := THVACComponent(DemandComponents[i]);
      if SameText(Component.ComponentType, 'WaterUse:Connections') then
      begin
        SWHStorage := SWHStorage + T_EP_WaterUseConnection(Component).WaterUseObject.StorageVolume;
        SWHHeatingCapacity := SWHHeatingCapacity + T_EP_WaterUseConnection(Component).WaterUseObject.HeatingCapacity;
      end;

    end; //for
  end;
end;

procedure T_EP_LiquidSystem.Finalize;
begin
  inherited;
end;

procedure T_EP_LiquidSystem.ToIDF;
var
  SetpointNode: string;
  i: integer;
  j: integer;
  k: integer;
  aFloat: double;
  Component: THVACComponent;
  PumpSupplyComponentID: integer;
  NameNoSpaces: string;
  Obj: TEnergyPlusObject;
label SkipEquipList;
label SkipSupplyEquipBranch;
begin
  Finalize;
  FigureSWHsizes;
  SetPointNode := Name + ' Supply Outlet Node';
  IDF.AddComment(''); //intentional blank line
  IDF.AddComment(LoopType + ' Loop: ' + Name);
  // need to know
  // setpoint type
  // can take this a step farther and make objects out of BRANCH and PIPE
  // Actually loop could be both cooling and heating!! needs dualsetpoint mgr
  // can hook up cooling and heating on separate branches
  // could automatically do this
  //******************************************
  // BEGIN PLANT LOOP
  Obj := IDF.AddObject(LoopType + 'Loop');
  Obj.AddField('Name', Name);
  Obj.AddField('Fluid Type', 'Water', '{WATER}');
  Obj.AddField('User Defined Fluid Type', '');
  Obj.AddField('Loop Equipment Operation Scheme Name', Name + ' Loop Operation Scheme List');
  // loop temp limits depend on type of plant system.
  if SystemType = cSystemTypeCondTower then
  begin
    Obj.AddField('Loop Temperature Setpoint Node Name', SetPointNode);
    Obj.AddField('Maximum Loop Temperature', '80.0', '{C}');
    Obj.AddField('Minimum Loop Temperature', '5.0', '{C}');
    Obj.AddField('Maximum Loop Flow Rate', 'AUTOSIZE', '{m3/s}');
  end
  else if SystemType = cSystemTypeGroundLoop then
  begin // for GSHP
    Obj.AddField('Loop Temperature Setpoint Node Name', SetPointNode);
    Obj.AddField('Maximum Loop Temperature', '80.0', '{C}');
    Obj.AddField('Minimum Loop Temperature', '1.0', '{C}');
    if DesignFlowRate > 0 then
      Obj.AddField('Maximum Loop Flow Rate', DesignFlowRate, '{m3/s}')
    else
      Obj.AddField('Maximum Loop Flow Rate', 'AUTOSIZE', '{m3/s}');
  end
  else if SystemType = cSystemTypeCool then
  begin
    Obj.AddField('Loop Temperature Setpoint Node Name', SetPointNode);
    Obj.AddField('Maximum Loop Temperature', '98.0', '{C}');
    Obj.AddField('Minimum Loop Temperature', '1.0', '{C}');
    Obj.AddField('Maximum Loop Flow Rate', 'AUTOSIZE', '{m3/s}');
  end
  else if SystemType = cSystemTypeHeat then
  begin
    Obj.AddField('Loop Temperature Setpoint Node Name', SetPointNode);
    Obj.AddField('Maximum Loop Temperature', '100.0', '{C}');
    Obj.AddField('Minimum Loop Temperature', '10.0', '{C}');
    Obj.AddField('Maximum Loop Flow Rate', 'AUTOSIZE', '{m3/s}');
  end
  else if SystemType = cSystemHeatRecovery then
  begin
    Obj.AddField('Loop Temperature Setpoint Node Name', SetPointNode);
    Obj.AddField('Maximum Loop Temperature', '98.0', '{C}');
    Obj.AddField('Minimum Loop Temperature', '10.0', '{C}');
    if AutosizedSystem then
      Obj.AddField('Maximum Loop Flow Rate', 'AUTOSIZE', '{m3/s}')
    else
      Obj.AddField('Maximum Loop Flow Rate', SystemDesignVolFlowRate, '{m3/s}');
  end
  else if SystemType = cSystemTypeHotWater then
  begin
    Obj.AddField('Loop Temperature Setpoint Node', SetPointNode);
    Obj.AddField('Maximum Loop Temperature', '60.0', '{C}');
    Obj.AddField('Minimum Loop Temperature', '10.0', '{C}');
    Obj.AddField('Maximum Loop Flow Rate', 'AUTOSIZE', '{m3/s}');
  end;
  Obj.AddField('Minimum Loop Flow Rate', '0.0', '{m3/s}');
  Obj.AddField('Loop Volume', 'AUTOSIZE', '{m3}');
  Obj.AddField('Supply Side Inlet Node', Name + ' Supply Inlet Node');
  Obj.AddField('Supply Side Outlet Node', Name + ' Supply Outlet Node');
  Obj.AddField('Supply Side Branch List Name', Name + ' Supply Branches');
  Obj.AddField('Supply Side Connector List Name', Name + ' Supply Connectors');
  Obj.AddField('Demand Side Inlet Node', Name + ' Demand Inlet Node');
  Obj.AddField('Demand Side Outlet Node', Name + ' Demand Outlet Node');
  Obj.AddField('Demand Side Branch List Name', Name + ' Demand Branches');
  Obj.AddField('Demand Side Connector List Name', Name + ' Demand Connectors');
  if SystemType = cSystemTypeCondTower then
  begin
    Obj.AddField('Load Distribution Scheme', 'Sequential', '{OPTIMAL | SEQUENTIAL}');
    Obj := IDF.AddObject('SetpointManager:FollowOutdoorAirTemperature');
    Obj.AddField('Name', Name + ' Condenser Control');
    Obj.AddField('Control Variable', 'Temperature', '{ Temperature | Others }');
    Obj.AddField('Reference Temperature Type', 'OutdoorAirWetBulb');
    Obj.AddField('Offset Temperature Difference', '0');
    Obj.AddField('Maximum Setpoint Temperature', '80');
    Obj.AddField('Minimum Setpoint Temperature', '5');
    Obj.AddField('Setpoint Node or NodeList Name', SetPointNode);
  end
  else
    Obj.AddField('Load Distribution Scheme', 'Optimal', '{OPTIMAL | SEQUENTIAL}');
  // System Availability Manager List     (Not used for CONDENSER LOOP)
  if SystemType = cSystemTypeCool then
  begin
    Obj := IDF.AddObject('Sizing:Plant');
    Obj.AddField('Loop Name', Name);
    Obj.AddField('Loop Type', 'Cooling', '{COOLING | HEATING}');
    if CHWLoopExitTemp > 0.0 then
      Obj.AddField('Design Loop Exit Temperature', CHWLoopExitTemp, '{C}')
    else
      Obj.AddField('Design Loop Exit Temperature', '6.67', '{C}');
    if CHWLoopTempDifference > 0.0 then
      Obj.AddField('Design Loop Temperature Difference', CHWLoopTempDifference, '{C}')
    else
      Obj.AddField('Design Loop Temperature Difference', '6.67', '{C}');
  end
  else if SystemType = cSystemTypeHeat then
  begin
    Obj := IDF.AddObject('Sizing:Plant');
    Obj.AddField('Loop Name', Name);
    Obj.AddField('Loop Type', 'Heating', '{COOLING | HEATING}');
    if HHWLoopExitTemp > 0.0 then
      Obj.AddField('Design Loop Exit Temperature', HHWLoopExitTemp, '{C}')
    else
      Obj.AddField('Design Loop Exit Temperature', '82.2', '{C}');
    if HHWLoopTempDifference > 0.0 then
      Obj.AddField('Design Loop Temperature Difference', HHWLoopTempDifference, '{C}')
    else
      Obj.AddField('Design Loop Temperature Difference', '11.1', '{C}');
  end
  else if (SystemType = cSystemTypeCondTower) then
  begin
    Obj := IDF.AddObject('Sizing:Plant');
    Obj.AddField('Loop Name', Name);
    Obj.AddField('Loop Type', 'CONDENSER', '{COOLING | HEATING | CONDENSER}');
    if CondLoopDesignExitTemp > 0.0 then
      Obj.AddField('Design Loop Exit Temperature', FloatToStr(CondLoopDesignExitTemp), '{C}')
    else
      Obj.AddField('Design Loop Exit Temperature', '29.4', '{C}');
    if CondLoopDesignDeltaTemp > 0.0 then
      Obj.AddField('Design Loop Temperature Difference', FloatToStr(CondLoopDesignDeltaTemp), '{C}')
    else
      Obj.AddField('Design Loop Temperature Difference', '5.6', '{C}');
    if (CondLoopDesignExitTemp > 0.0) then
    begin
      Obj := IDF.AddObject('SetpointManager:Scheduled');
      Obj.AddField('Name', Name + ' Loop Setpoint Manager');
      Obj.AddField('Control Variable', 'Temperature');
      Obj.AddField('Schedule Name', Name + ' Loop Temperature Schedule');
      Obj.AddField('Setpoint Node or Node List Name', SetPointNode);
      Obj := IDF.AddObject('Schedule:Compact');
      Obj.AddField('Name', Name + ' Loop Temperature Schedule');
      Obj.AddField('Schedule Type Limits Name', 'Temperature');
      Obj.AddField('Field 1', 'Through: 12/31');
      Obj.AddField('Field 2', 'For: AllDays');
      Obj.AddField('Field 3', 'Until: 24:00');
      Obj.AddField('Field 4', FloatToStr(CondLoopDesignExitTemp));
    end;
  end
  else if SystemType = cSystemHeatRecovery then
  begin
    if AutosizedSystem then
    begin
      Obj := IDF.AddObject('Sizing:Plant');
      Obj.AddField('Loop Name', Name);
      Obj.AddField('Loop Type', 'Heating', '{COOLING | HEATING}');
      Obj.AddField('Design Loop Exit Temperature', '62.0', '{C}');
      Obj.AddField('Design Loop Temperature Difference', '5.0', '{C}');
    end;
  end
  else if SystemType = cSystemTypeHotWater then
  begin
    Obj := IDF.AddObject('Sizing:Plant');
    Obj.AddField('Loop Name', Name);
    Obj.AddField('Loop Type', 'Heating', '{COOLING | HEATING}');
    Obj.AddField('Design Loop Exit Temperature', FloatToStr(LoopTempSetpoint), '{C}');
    Obj.AddField('Design Loop Temperature Difference', '5.0', '{C}');
  end
  else if SystemType = cSystemTypeGroundLoop then
  begin
    Obj := IDF.AddObject('Sizing:Plant');
    Obj.AddField('Loop Name', Name);
    Obj.AddField('Loop Type', 'CONDENSER');
    Obj.AddField('Design Loop Exit Temperature', ExitTemp, '{C}');
    Obj.AddField('Design Loop Temperature Difference', DeltaTemp, '{C}');
  end;
  if (SystemType <> cSystemTypeCondTower) then
  begin
    if SystemType = cSystemTypeGroundLoop then
    begin
      Obj := IDF.AddObject('SetpointManager:Scheduled');
      Obj.AddField('Name', Name + ' Loop Setpoint Manager');
      Obj.AddField('Control Variable', 'Temperature', '{TEMP}');
      Obj.AddField('Schedule Name', Name + ' Supply Outlet Setpoint Sched');
      Obj.AddField('Setpoint Node Name', Name + ' Supply Outlet Node');
      //supply outlet setpoint schedule
      Obj := IDF.AddObject('Schedule:Compact');
      Obj.AddField('Name', Name + ' Supply Outlet Setpoint Sched');
      Obj.AddField('Schedule Type Limits Name', 'Temperature');
      Obj.AddField('Field 1', 'Through: 12/31');
      Obj.AddField('Field 2', 'For: AllDays');
      Obj.AddField('Field 3', 'Until: 24:00');
      Obj.AddField('Field 4', ExitTemp);
    end
    else if (SystemType = cSystemTypeCool) and (CHWLoopExitTemp > 0.0) then
    begin
      Obj := IDF.AddObject('SetpointManager:Scheduled');
      Obj.AddField('Name', Name + ' Loop Setpoint Manager');
      Obj.AddField('Control Variable', 'Temperature', '{TEMP}');
      Obj.AddField('Schedule Name', Name + ' Loop Setpoint Sched');
      Obj.AddField('Setpoint Node Name', Name + ' Supply Outlet Node');
      //loop setpoint schedule
      Obj := IDF.AddObject('Schedule:Compact');
      Obj.AddField('Name', Name + ' Loop Setpoint Sched');
      Obj.AddField('Schedule Type Limits Name', 'Temperature');
      Obj.AddField('Field 1', 'Through: 12/31');
      Obj.AddField('Field 2', 'For: AllDays');
      Obj.AddField('Field 3', 'Until: 24:00');
      Obj.AddField('Field 4', CHWLoopExitTemp);
    end
    else if (SystemType = cSystemTypeHeat) and SameText(HHWSetpointManagerType, 'OutsideAir') then
    begin
      Obj := IDF.AddObject('SetpointManager:OutdoorAirReset');
      Obj.AddField('Name', Name + ' Loop Setpoint Manager');
      Obj.AddField('Control Variable', 'Temperature');
      if HHWSetpointAtOutdoorLowTemp > 0.0 then
        Obj.AddField('Setpoint at Outdoor Low Temperature', HHWSetpointAtOutdoorLowTemp)
      else
        Obj.AddField('Setpoint at Outdoor Low Temperature', '82.2');
      if HHWOutdoorLowTemp > 0.0 then
        Obj.AddField('Outdoor Low Temperature', HHWOutdoorLowTemp)
      else
        Obj.AddField('Outdoor Low Temperature', '-17.8');
      if HHWSetpointAtOutdoorHighTemp > 0.0 then
        Obj.AddField('Setpoint at Outdoor High Temperature', HHWSetpointAtOutdoorHighTemp)
      else
        Obj.AddField('Setpoint at Outdoor High Temperature', '60.0');
      if HHWOutdoorHighTemp > 0.0 then
        Obj.AddField('Outdoor High Temperature', HHWOutdoorHighTemp)
      else
        Obj.AddField('Outdoor High Temperature', '15.6');
      Obj.AddField('Setpoint Node Name', Name + ' Supply Outlet Node');
    end
    else if (SystemType = cSystemTypeHeat) and (HHWLoopExitTemp > 0) and not SameText(HHWSetpointManagerType, 'OutsideAir') then
    begin
      Obj := IDF.AddObject('SetpointManager:Scheduled');
      Obj.AddField('Name', Name + ' Loop Setpoint Manager');
      Obj.AddField('Control Variable', 'Temperature', '{TEMP}');
      Obj.AddField('Schedule Name', Name + ' Loop Setpoint Sched');
      Obj.AddField('Setpoint Node Name', Name + ' Supply Outlet Node');
      //loop setpoint schedule
      Obj := IDF.AddObject('Schedule:Compact');
      Obj.AddField('Name', Name + ' Loop Setpoint Sched');
      Obj.AddField('Schedule Type Limits Name', 'Temperature');
      Obj.AddField('Field 1', 'Through: 12/31');
      Obj.AddField('Field 2', 'For: AllDays');
      Obj.AddField('Field 3', 'Until: 24:00');
      Obj.AddField('Field 4', HHWLoopExitTemp);
    end
    else if not (SystemType = cSystemHeatRecovery) then
    begin
      Obj := IDF.AddObject('SetpointManager:Scheduled');
      Obj.AddField('Name', Name + ' Loop Setpoint Manager');
      Obj.AddField('Control Variable', 'Temperature', '{TEMP}');
      Obj.AddField('Schedule Name', SetPointSchedule);
      Obj.AddField('Setpoint Node Name', Name + ' Supply Outlet Node');
    end
    else
    begin
      Obj := IDF.AddObject('SetpointManager:Scheduled');
      Obj.AddField('Name', Name + ' Loop Setpoint Manager');
      Obj.AddField('Control Variable', 'Temperature', '{TEMP}');
      Obj.AddField('Schedule Name', Name + ' Loop Setpoint Sched');
      Obj.AddField('Setpoint Node Name', Name + ' Supply Outlet Node');
      //loop setpoint schedule
      Obj := IDF.AddObject('Schedule:Compact');
      Obj.AddField('Name', Name + ' Loop Setpoint Sched');
      Obj.AddField('Schedule Type Limits Name', 'Temperature');
      Obj.AddField('Field 1', 'Through: 12/31');
      Obj.AddField('Field 2', 'For: AllDays');
      Obj.AddField('Field 3', 'Until: 24:00');
      Obj.AddField('Field 4', LoopTempSetpoint);
    end;
  end;
  if SystemType = cSystemTypeCondTower then
  begin
//  Obj := IDF.AddObject('SetpointManager:Scheduled');
//  Obj.AddField('Name', Name + ' Loop Setpoint Manager');
//  Obj.AddField('Control Variable', 'Temperature', '{TEMP}');
//  Obj.AddField('Schedule Name', 'CW-Loop-Temp-Schedule');
//  Obj.AddField('Set Point Node Name', Name + ' Supply Outlet Node');
  end;
  if SystemType = cSystemTypeGroundLoop then
  begin // for GSHP
    //ejb: loop through all system components, if there exists a component other than a ground heat exchanger and a pump
    //then create a component set point plant equipment operation scheme, otherwise create an uncontrolled operation scheme
    //set use uncontrolled loop (loop w/ only pump and ground heat exchanger) to true to start with
    UseUncontrolledLoop := true;
    //loop though supply components
    for i := 0 to SupplyComponents.Count - 1 do
    begin
      Component := THVACComponent(SupplyComponents[i]);
      //if any other pieces of equipment (fluid cooler, boiler, etc.) are encountered, set to false
      if Component.ComponentType = 'GroundHeatExchanger:Vertical' then continue;
      if Component.ComponentType = 'Pump:ConstantSpeed' then continue;
      if Component.ComponentType = 'Pump:VariableSpeed' then continue;
      UseUncontrolledLoop := false;
      if Component.ComponentType = 'EvaporativeFluidCooler:SingleSpeed' then UseWetFluidCooler := true;
    end;
    Obj := IDF.AddObject(LoopType + 'EquipmentOperationSchemes');
    Obj.AddField('Name', Name + ' Loop Operation Scheme List');
    if UseUncontrolledLoop then //create an uncontrolled plant operation scheme
    begin
      Obj.AddField('Control Scheme 1 Object Type', 'PlantEquipmentOperation:Uncontrolled', '{*******}');
      Obj.AddField('Control Scheme 1 Name', Name + ' Operation Scheme');
      Obj.AddField('Control Scheme 1 Schedule Name', 'ALWAYS_ON');
    end
    else if UseWatersideEconomizer then //create a special operation scheme
    begin
      Obj.AddField('Control Scheme 1 Object Type', 'PlantEquipmentOperation:CoolingLoad', '{*******}');
      Obj.AddField('Control Scheme 1 Name', Name + ' Cooling Operation Scheme');
      Obj.AddField('Control Scheme 1 Schedule Name', Name + ' Load Based Control Schedule');
      Obj.AddField('Control Scheme 2 Object Type', 'PlantEquipmentOperation:HeatingLoad', '{*******}');
      Obj.AddField('Control Scheme 2 Name', Name + ' Heating Operation Scheme');
      Obj.AddField('Control Scheme 2 Schedule Name', Name + ' Load Based Control Schedule');
      Obj.AddField('Control Scheme 3 Object Type', 'PlantEquipmentOperation:ComponentSetpoint', '{*******}');
      Obj.AddField('Control Scheme 3 Name', Name + ' Operation Scheme');
      Obj.AddField('Control Scheme 3 Schedule Name', Name + ' Setpoint Based Control Schedule');
      //add load based schedule
      Obj := IDF.AddObject('Schedule:Compact');
      Obj.AddField('Name', Name + ' Load Based Control Schedule');
      Obj.AddField('Type', 'Fraction');
      Obj.AddField('Field 1', 'Through: 12/31');
      Obj.AddField('Field 2', 'For: AllDays');
      Obj.AddField('Field 3', 'Until: 24:00, 1.00');
      //add setpoint based schedule
      Obj := IDF.AddObject('Schedule:Compact');
      Obj.AddField('Name', Name + ' Setpoint Based Control Schedule');
      Obj.AddField('Type', 'Fraction');
      Obj.AddField('Field 1', 'Through: 12/31');
      Obj.AddField('Field 2', 'For: AllDays');
      Obj.AddField('Field 3', 'Until: 24:00, 1.00');
    end
    else if UseWetFluidCooler then
    begin
      Obj.AddField('Control Scheme 1 Object Type', 'PlantEquipmentOperation:ComponentSetpoint', '{*******}');
      Obj.AddField('Control Scheme 1 Name', Name + ' Operation Scheme');
      Obj.AddField('Control Scheme 1 Schedule Name', Name + ' Setpoint Based Control Schedule');
      //add setpoint based schedule
      Obj := IDF.AddObject('Schedule:Compact');
      Obj.AddField('Name', Name + ' Setpoint Based Control Schedule');
      Obj.AddField('Type', 'Fraction');
      Obj.AddField('Field 1', 'Through: 12/31');
      Obj.AddField('Field 2', 'For: AllDays');
      Obj.AddField('Field 3', 'Until: 24:00, 1.00');
    end
    else //create a setpoint based operation scheme
    begin
      Obj.AddField('Control Scheme 1 Object Type', 'PlantEquipmentOperation:ComponentSetpoint', '{*******}');
      Obj.AddField('Control Scheme 1 Name', Name + ' Operation Scheme');
      Obj.AddField('Control Scheme 1 Schedule Name', 'ALWAYS_ON');
    end;
    if UseUncontrolledLoop then //create an uncontrolled plant operation scheme
    begin
      Obj := IDF.AddObject('PlantEquipmentOperation:Uncontrolled');
      Obj.AddField('Name', Name + ' Operation Scheme');
      Obj.AddField('Equipment List Name', Name + ' Equipment List');
      //equipment list
      Obj := IDF.AddObject('PlantEquipmentList');
      Obj.AddField('Name', Name + ' Equipment List');
      for i := 0 to SupplyComponents.Count - 1 do
      begin
        Component := THVACComponent(SupplyComponents[i]);
        Obj.AddField('Object Type', Component.ComponentType);
        Obj.AddField('Object Name', Component.Name);
      end;
    end
    else if UseWatersideEconomizer then //create a special operation scheme
    begin
      //cooling equipment operation
      Obj := IDF.AddObject('PlantEquipmentOperation:CoolingLoad');
      Obj.AddField('Name', Name + ' Cooling Operation Scheme');
      Obj.AddField('Load Range Lower Limit', '0', '{W}');
      Obj.AddField('Load Range Upper Limit', '1000000000000', '{W}');
      Obj.AddField('Priority Control Equipment List Name', Name + ' Cooling Equipment List');
      //heating equipment operation
      Obj := IDF.AddObject('PlantEquipmentOperation:HeatingLoad');
      Obj.AddField('Name', Name + ' Heating Operation Scheme');
      Obj.AddField('Load Range Lower Limit', '100000000000', '{W}');
      Obj.AddField('Load Range Upper Limit', '1000000000000', '{W}');
      Obj.AddField('Priority Control Equipment List Name', Name + ' Heating Equipment List');
      //cooling equipment list
      Obj := IDF.AddObject('PlantEquipmentList');
      Obj.AddField('Name', Name + ' Cooling Equipment List');
      for i := 0 to SupplyComponents.Count - 1 do
      begin
        Component := THVACComponent(SupplyComponents[i]);
        if (AnsiContainsStr(Component.ComponentType, 'Chiller') or
          SameText(Component.ComponentType, 'HeatExchanger:FluidToFluid')) then
        begin
          Obj.AddField('Equipment Object Type', Component.ComponentType);
          Obj.AddField('Equipment Name', Component.Name);
        end;
      end;
      //heating equipment list
      Obj := IDF.AddObject('PlantEquipmentList');
      Obj.AddField('Name', Name + ' Heating Equipment List');
      for i := 0 to SupplyComponents.Count - 1 do
      begin
        Component := THVACComponent(SupplyComponents[i]);
        if AnsiContainsStr(Component.ComponentType, 'Boiler') then
        begin
          Obj.AddField('Equipment Object Type', Component.ComponentType);
          Obj.AddField('Equipment Name', Component.Name);
        end;
      end;
      //setpoint based operation
      Obj := IDF.AddObject('PlantEquipmentOperation:ComponentSetpoint');
      Obj.AddField('Name', Name + ' Operation Scheme');
      for i := 0 to SupplyComponents.Count - 1 do
      begin
        Component := THVACComponent(SupplyComponents[i]);
        if AnsiContainsStr(Component.ComponentType, 'Boiler') then
        begin
          Obj.AddField('Object Type', Component.ComponentType);
          Obj.AddField('Object Name', Component.Name);
          Obj.AddField('Demand Calculation Node Name', Component.SupplyInletNode);
          Obj.AddField('Setpoint Node Name', Component.SupplyOutletNode);
          Obj.AddField('Component Flow Rate', 'AUTOSIZE');
          Obj.AddField('Operation Type', 'Heating');
          //add boiler setpoint manager
          Obj := IDF.AddObject('SetpointManager:Scheduled');
          Obj.AddField('Name', Name + ' Boiler Setpoint');
          Obj.AddField('Control Variable', 'Temperature');
          Obj.AddField('Schedule Name', Name + ' Boiler Setpoint Schedule');
          Obj.AddField('Setpoint Node or NodeList Name', Component.SupplyOutletNode);
          //add boiler setpoint manager schedule
          Obj := IDF.AddObject('Schedule:Compact');
          Obj.AddField('Name', Name + ' Boiler Setpoint Schedule');
          Obj.AddField('Schedule Type Limits Name', 'Any Number');
          Obj.AddField('Field 1', 'Through: 12/31');
          Obj.AddField('Field 2', 'For: AllDays');
          Obj.AddField('Field 3', 'Until: 24:00, 20.0');
        end;
      end;
      //add custom EMS code for waterside economizer control
      NameNoSpaces := StringReplace(Name, ' ', '', [rfReplaceAll]); //removed spaces from name for ems code
      //loop over supply equipment to grab waterside economizer
      for i := 0 to SupplyComponents.Count - 1 do
      begin
        Component := THVACComponent(SupplyComponents[i]);
        if SameText(Component.ComponentType, 'HeatExchanger:FluidToFluid') then
        begin
          //ems sensor for condenser loop temperature
          Obj := IDF.AddObject('EnergyManagementSystem:Sensor');
          Obj.AddField('Name', NameNoSpaces + 'InletTempSensor');
          Obj.AddField('Output:Variable or Output:Meter Index Key Name', Component.SupplyInletNode);
          Obj.AddField('Output:Variable or Output:Meter Name', 'System Node Temp');
        end;
      end;
      //ems actuator for load based control schedule
      Obj := IDF.AddObject('EnergyManagementSystem:Actuator');
      Obj.AddField('Name', NameNoSpaces + 'LoadBasedControlScheduleActuator');
      Obj.AddField('Actuated Component Unique Name', Name + ' Load Based Control Schedule');
      Obj.AddField('Actuated Component Type', 'Schedule:Compact');
      Obj.AddField('Actuated Component Type', 'Schedule Value');
      //ems actuator for setpoint based control schedule
      Obj := IDF.AddObject('EnergyManagementSystem:Actuator');
      Obj.AddField('Name', NameNoSpaces + 'SetpointBasedControlScheduleActuator');
      Obj.AddField('Actuated Component Unique Name', Name + ' Setpoint Based Control Schedule');
      Obj.AddField('Actuated Component Type', 'Schedule:Compact');
      Obj.AddField('Actuated Component Type', 'Schedule Value');
      //ems actuator for condenser loop temperature
      Obj := IDF.AddObject('EnergyManagementSystem:Actuator');
      Obj.AddField('Name', NameNoSpaces + 'SetpointScheduleActuator');
      Obj.AddField('Actuated Component Unique Name', Name + ' Supply Outlet Setpoint Sched');
      Obj.AddField('Actuated Component Type', 'Schedule:Compact');
      Obj.AddField('Actuated Component Type', 'Schedule Value');
      //ems program calling manager
      Obj := IDF.AddObject('EnergyManagementSystem:ProgramCallingManager');
      Obj.AddField('Name', NameNoSpaces + 'ScheduleSelectorCallingManager');
      Obj.AddField('EnergyPlus Model Calling Point', 'BeginTimestepBeforePredictor');
      Obj.AddField('Program Name', NameNoSpaces + 'ScheduleSelector');
      //ems program
      Obj := IDF.AddObject('EnergyManagementSystem:Program');
      Obj.AddField('Name', NameNoSpaces + 'ScheduleSelector');
      Obj.AddField('Program Line 1', 'IF ' + NameNoSpaces + 'InletTempSensor' + ' >= 23');
      Obj.AddField('Program Line 2', 'SET ' + NameNoSpaces + 'LoadBasedControlScheduleActuator' + ' = 1');
      Obj.AddField('Program Line 3', 'SET ' + NameNoSpaces + 'SetpointBasedControlScheduleActuator' + ' = 0');
      Obj.AddField('Program Line 4', 'SET ' + NameNoSpaces + 'SetpointScheduleActuator' + ' = 30.0');
      Obj.AddField('Program Line 5', 'ELSE');
      Obj.AddField('Program Line 6', 'SET ' + NameNoSpaces + 'LoadBasedControlScheduleActuator' + ' = 0');
      Obj.AddField('Program Line 7', 'SET ' + NameNoSpaces + 'SetpointBasedControlScheduleActuator' + ' = 1');
      Obj.AddField('Program Line 8', 'SET ' + NameNoSpaces + 'SetpointScheduleActuator' + ' = 20.0');
      Obj.AddField('Program Line 9', 'ENDIF');
    end
    else if UseWetFluidCooler then
    begin
      //cooling equipment list
      Obj := IDF.AddObject('PlantEquipmentList');
      Obj.AddField('Name', Name + ' Cooling Equipment List');
      for i := 0 to SupplyComponents.Count - 1 do
      begin
        Component := THVACComponent(SupplyComponents[i]);
        if SameText(Component.ComponentType, 'EvaporativeFluidCooler:SingleSpeed') then
        begin
          Obj.AddField('Equipment Object Type', Component.ComponentType);
          Obj.AddField('Equipment Name', Component.Name);
        end;
      end;
      //heating equipment list
      Obj := IDF.AddObject('PlantEquipmentList');
      Obj.AddField('Name', Name + ' Heating Equipment List');
      for i := 0 to SupplyComponents.Count - 1 do
      begin
        Component := THVACComponent(SupplyComponents[i]);
        if AnsiContainsStr(Component.ComponentType, 'Boiler') then
        begin
          Obj.AddField('Equipment Object Type', Component.ComponentType);
          Obj.AddField('Equipment Name', Component.Name);
        end;
      end;
      //setpoint based operation
      Obj := IDF.AddObject('PlantEquipmentOperation:ComponentSetpoint');
      Obj.AddField('Name', Name + ' Operation Scheme');
      for i := 0 to SupplyComponents.Count - 1 do
      begin
        Component := THVACComponent(SupplyComponents[i]);
        if SameText(Component.ComponentType, 'EvaporativeFluidCooler:SingleSpeed') then
        begin
          Obj.AddField('Equipment 1 Object Type', Component.ComponentType);
          Obj.AddField('Equipment 1 Name', Component.Name);
          Obj.AddField('Demand Calculation 1 Node Name', Component.SupplyInletNode);
          Obj.AddField('Setpoint 1 Node Name', Component.SupplyOutletNode);
          Obj.AddField('Component 1 Flow Rate', 'AUTOSIZE');
          Obj.AddField('Operation 1 Type', 'Cooling');
        end
        else if AnsiContainsStr(Component.ComponentType, 'Boiler') then
        begin
          Obj.AddField('Equipment 2 Object Type', Component.ComponentType);
          Obj.AddField('Equipment 2 Name', Component.Name);
          Obj.AddField('Demand Calculation 2 Node Name', Component.SupplyInletNode);
          Obj.AddField('Setpoint 2 Node Name', Component.SupplyOutletNode);
          Obj.AddField('Component 2 Flow Rate', 'AUTOSIZE');
          Obj.AddField('Operation 2 Type', 'Heating');
        end;
      end;
      //setpoint managers
      for i := 0 to SupplyComponents.Count - 1 do
      begin
        Component := THVACComponent(SupplyComponents[i]);
        if AnsiContainsStr(Component.ComponentType, 'Boiler') then
        begin
          //add boiler setpoint manager
          Obj := IDF.AddObject('SetpointManager:Scheduled');
          Obj.AddField('Name', Name + ' Boiler Setpoint');
          Obj.AddField('Control Variable', 'Temperature');
          Obj.AddField('Schedule Name', Name + ' Boiler Setpoint Schedule');
          Obj.AddField('Setpoint Node or NodeList Name', Component.SupplyOutletNode);
          //add boiler setpoint manager schedule
          Obj := IDF.AddObject('Schedule:Compact');
          Obj.AddField('Name', Name + ' Boiler Setpoint Schedule');
          Obj.AddField('Schedule Type Limits Name', 'Any Number');
          Obj.AddField('Field 1', 'Through: 12/31');
          Obj.AddField('Field 2', 'For: AllDays');
          Obj.AddField('Field 3', 'Until: 24:00, 20.0');
        end;
      end;
      for i := 0 to SupplyComponents.Count - 1 do
      begin
        Component := THVACComponent(SupplyComponents[i]);
        if SameText(Component.ComponentType, 'EvaporativeFluidCooler:SingleSpeed') then
        begin
          //add wet fluid cooler setpoint manager
          Obj := IDF.AddObject('SetpointManager:Scheduled');
          Obj.AddField('Name', Name + ' Evaporative Fluid Cooler Setpoint');
          Obj.AddField('Control Variable', 'Temperature');
          Obj.AddField('Schedule Name', Name + ' Evaporative Fluid Cooler Setpoint Schedule');
          Obj.AddField('Setpoint Node or NodeList Name', Component.SupplyOutletNode);
          //add wet fluid cooler setpoint manager schedule
          Obj := IDF.AddObject('Schedule:Compact');
          Obj.AddField('Name', Name + ' Evaporative Fluid Cooler Setpoint Schedule');
          Obj.AddField('Schedule Type Limits Name', 'Any Number');
          Obj.AddField('Field 1', 'Through: 12/31');
          Obj.AddField('Field 2', 'For: AllDays');
          Obj.AddField('Field 3', 'Until: 24:00, 30.0');
        end
      end;
    end
    else  //create a setpoint based operation scheme
    begin
      Obj := IDF.AddObject('PlantEquipmentOperation:ComponentSetpoint');
      Obj.AddField('Name', Name + ' Operation Scheme');
      for i := 0 to SupplyComponents.Count - 1 do
      begin
        Component := THVACComponent(SupplyComponents[i]);
        if Component.ComponentType = 'GroundHeatExchanger:Vertical' then continue;
        if Component.ComponentType = 'Pump:ConstantSpeed' then continue;
        if Component.ComponentType = 'Pump:VariableSpeed' then continue;
        Obj.AddField('Object Type', Component.ComponentType);
        Obj.AddField('Object Name', Component.Name);
        Obj.AddField('Demand Calculation Node Name', Component.SupplyInletNode);
        Obj.AddField('Setpoint Node Name', Component.SupplyOutletNode);
        if DesignFlowRate > 0.0 then
          Obj.AddField('Component Flow Rate', DesignFlowRate)
        else
          Obj.AddField('Component Flow Rate', 'AUTOSIZE');
        if Component.ComponentType = 'Boiler:HotWater' then
          Obj.AddField('Operation Type', 'Heating')
        else
          Obj.AddField('Operation Type', 'Cooling');
      end;
      for i := 0 to SupplyComponents.Count - 1 do
      begin
        Component := THVACComponent(SupplyComponents[i]);
        if Component.ComponentType = 'GroundHeatExchanger:Vertical' then continue;
        if Component.ComponentType = 'Pump:ConstantSpeed' then continue;
        if Component.ComponentType = 'FluidCooler:SingleSpeed' then
        begin
          Obj := IDF.AddObject('SetpointManager:Scheduled');
          Obj.AddField('Name', Component.Name + '_SP');
          Obj.AddField('Control Variable', 'Temperature');
          Obj.AddField('Schedule Name', Component.Name + '_SP_Schedule');
          Obj.AddField('Setpoint Node or NodeList Name', Component.SupplyOutletNode);
          //setpoint schedule
          Obj := IDF.AddObject('Schedule:Compact');
          Obj.AddField('Name',Component.Name + '_SP_Schedule');
          Obj.AddField('Schedule Type Limits Name', 'Any Number');
          Obj.AddField('Field 1', 'Through: 12/31');
          Obj.AddField('Field 2', 'For: AllDays');
          Obj.AddField('Field 3', 'Until: 24:00');
          Obj.AddField('Field 4', '30.0');
        end
        else if Component.ComponentType = 'Boiler:HotWater' then
        begin
          Obj := IDF.AddObject('SetpointManager:Scheduled');
          Obj.AddField('Name', Component.Name + '_SP');
          Obj.AddField('Control Variable', 'Temperature');
          Obj.AddField('Schedule Name', Component.Name + '_SP_Schedule');
          Obj.AddField('Setpoint Node or NodeList Name', Component.SupplyOutletNode);
          //setpoint schedule
          Obj := IDF.AddObject('Schedule:Compact');
          Obj.AddField('Name',Component.Name + '_SP_Schedule');
          Obj.AddField('Schedule Type Limits Name', 'Any Number');
          Obj.AddField('Field 1', 'Through: 12/31');
          Obj.AddField('Field 1', 'For: AllDays');
          Obj.AddField('Field 2', 'Until: 24:00');
          Obj.AddField('Field 3', Component.OutletTemperature);
        end;
      end;
    end;
  end
  else if SystemType = cSystemTypeCool then
  begin
    Obj := IDF.AddObject(LoopType + 'EquipmentOperationSchemes');
    Obj.AddField('Name', Name + ' Loop Operation Scheme List');
    Obj.AddField('Control Scheme 1 Object Type', 'PlantEquipmentOperation:CoolingLoad', '{*******}');
    Obj.AddField('Control Scheme 1 Name', Name + ' Operation Scheme');
    Obj.AddField('Control Scheme 1 Schedule Name', 'PlantOnSched');
    //operation scheme
    Obj := IDF.AddObject('PlantEquipmentOperation:CoolingLoad');
    Obj.AddField('Name', Name + ' Operation Scheme');
    Obj.AddField('Load Range 1 Lower Limit', '0.0', '{W}');
    if ((SystemType = cSystemTypeCool) and (HasHeatRecoveryChiller)) then
    begin
      for i := 0 to SupplyComponents.Count - 1 do
      begin
        Component := THVACComponent(SupplyComponents[i]);
        if AnsiContainsText(Component.Name, 'Heat Recovery') then
          aFloat := Component.Capacity;
      end;
      Obj.AddField('Load Range 1 Upper Limit', aFloat, '{W}');
      Obj.AddField('Priority Control 1 Equipment List Name', Name + ' Heat Recovery Equipment List');
      Obj.AddField('Load Range 2 Lower Limit', aFloat, '{W}');
      Obj.AddField('Load Range 2 Upper Limit', '100000000000000', '{W}');
      Obj.AddField('Priority Control 2 Equipment List Name', Name + ' Equipment List');
    end
    else
    begin
      Obj.AddField('Load Range 1 Upper Limit', '100000000000000', '{W}');
      Obj.AddField('Priority Control 1 Equipment List Name', Name + ' Equipment List');
    end;
  end
  else if SystemType = cSystemTypeHeat then
  begin
    Obj := IDF.AddObject(LoopType + 'EquipmentOperationSchemes');
    Obj.AddField('Name', Name + ' Loop Operation Scheme List');
    Obj.AddField('Control Scheme 1 Object Type', 'PlantEquipmentOperation:HeatingLoad', '{*******}');
    Obj.AddField('Control Scheme 1 Name', Name + ' Operation Scheme');
    Obj.AddField('Control Scheme 1 Schedule Name', 'PlantOnSched');
    //operation scheme
    Obj := IDF.AddObject('PlantEquipmentOperation:HeatingLoad');
    Obj.AddField('Name', Name + ' Operation Scheme');
    Obj.AddField('Load Range 1 Lower Limit', '0.0', '{W}');
    Obj.AddField('Load Range 1 Upper Limit', '1000000000000000', '{W}');
    Obj.AddField('Priority Control 1 Equipment List Name', Name + ' Equipment List');
  end
  else if SystemType = cSystemTypeHotWater then
  begin
    Obj := IDF.AddObject(LoopType + 'EquipmentOperationSchemes');
    Obj.AddField('Name', Name + ' Loop Operation Scheme List');
    Obj.AddField('Control Scheme 1 Object Type', 'PlantEquipmentOperation:HeatingLoad', '{*******}');
    Obj.AddField('Control Scheme 1 Name', Name + ' Operation Scheme');
    Obj.AddField('Control Scheme 1 Schedule Name', 'PlantOnSched');
    //operation scheme
    Obj := IDF.AddObject('PlantEquipmentOperation:HeatingLoad');
    Obj.AddField('Name', Name + ' Operation Scheme');
    Obj.AddField('Load Range 1 Lower Limit', '0.0', '{W}');
    Obj.AddField('Load Range 1 Upper Limit', '1000000000000000', '{W}');
    Obj.AddField('Priority Control 1 Equipment List Name', Name + ' Equipment List');
  end
  else if SystemType = cSystemHeatRecovery then
  begin
//  Obj := IDF.AddObject(LoopType + 'EquipmentOperationSchemes');
//  Obj.AddField('Name', Name + ' Loop Operation Scheme List');
//  Obj.AddField('Control Scheme 1 Object Type', 'PlantEquipmentOperation:HeatingLoad', '{*******}');
//  Obj.AddField('Control Scheme 1 Name', Name + ' Operation Scheme');
//  Obj.AddField('Control Scheme 1 Schedule Name', 'PlantOnSched');
    //operation scheme
//  Obj := IDF.AddObject('PlantEquipmentOperation:HeatingLoad');
//  Obj.AddField('Name', Name + ' Operation Scheme');
//  Obj.AddField('Load Range 1 Lower Limit', '0.0', '{W}');
//  Obj.AddField('Load Range 1 Upper Limit', '1000000000000000', '{W}');
//  Obj.AddField('Equipment List Name 1', Name + ' Equipment List');
    //operation scheme list
    Obj := IDF.AddObject(LoopType + 'EquipmentOperationSchemes');
    Obj.AddField('Name', Name + ' Loop Operation Scheme List');
    Obj.AddField('Control Scheme 1 Object Type 1', 'PlantEquipmentOperation:Uncontrolled', '{*******}');
    Obj.AddField('Control Scheme 1 Name', Name + ' Operation Scheme');
    Obj.AddField('Control Scheme 1 Schedule Name', 'ALWAYS_ON');
    //operation scheme
    Obj := IDF.AddObject('PlantEquipmentOperation:Uncontrolled');
    Obj.AddField('Name', Name + ' Operation Scheme');
    Obj.AddField('Equipment List Name', Name + ' Equipment List');
  end
  else if SystemType = cSystemTypeCondTower then
  begin
    Obj := IDF.AddObject(LoopType + 'EquipmentOperationSchemes');
    Obj.AddField('Name', Name + ' Loop Operation Scheme List');
    Obj.AddField('Control Scheme 1 Object Type', 'PlantEquipmentOperation:CoolingLoad', '{*******}');
    Obj.AddField('Control Scheme 1 Name', Name + ' Operation Scheme');
    Obj.AddField('Control Scheme 1 Schedule Name', 'PlantOnSched');
    //operation scheme
    Obj := IDF.AddObject('PlantEquipmentOperation:CoolingLoad');
    Obj.AddField('Name', Name + ' Operation Scheme');
    Obj.AddField('Load Range 1 Lower Limit', '0.0', '{W}');
    Obj.AddField('Load Range 1 Upper Limit', '1000000000000', '{W}');
    Obj.AddField('Priority Control 1 Equipment List Name', Name + ' Equipment List');
  end;
  if SystemType = cSystemTypeHotWater then
  begin
    Obj := IDF.AddObject('Schedule:Compact');
    Obj.AddField('Name', SetPointSchedule);
    Obj.AddField('Schedule Type Limits Name', 'Temperature');
    Obj.AddField('Field 1', 'Through: 12/31');
    Obj.AddField('Field 2', 'For: AllDays');
    Obj.AddField('Field 3', 'Until: 24:00');
    Obj.AddField('Field 4', FloatToStr(LoopTempSetpoint));
  end;
  // Supply Side
  // ksb: if it is a ground loop we are using set point control
  // so there is no need for the equipment list
  if SystemType <> cSystemTypeGroundLoop then
  begin
    if ((SystemType = cSystemTypeCool) and (HasHeatRecoveryChiller)) then
    begin
      Obj := IDF.AddObject(LoopType + 'EquipmentList');
      Obj.AddField('Name', Name + ' Heat Recovery Equipment List');
      for i := 0 to SupplyComponents.Count - 1 do
      begin
        Component := THVACComponent(SupplyComponents[i]);
        if AnsiContainsText(Component.Name, 'Heat Recovery Chiller') then
        begin
          Obj.AddField('Equipment 1 Object Type', Component.ComponentType);
          Obj.AddField('Equipment 1 Name', Component.Name);
        end;
      end;
    end;
    Obj := IDF.AddObject(LoopType + 'EquipmentList');
    Obj.AddField('Name', Name + ' Equipment List');
    if ((SystemType = cSystemTypeHotWater) and (HasHeatPumpHotWaterHeater)) then
    begin
      Obj.AddField('Equipment Object Type', 'WaterHeater:HeatPump');
      Obj.AddField('Equipment Name', Name + ' Water Heater Bottom');
      Obj.AddField('Equipment Object Type', 'WaterHeater:HeatPump');
      Obj.AddField('Equipment Name', Name + ' Water Heater Top');
      Obj.AddField('Equipment Object Type', 'WaterHeater:Mixed');
      Obj.AddField('Equipment Name', Name + ' Water Heater Dummy Tankless');
      Goto SkipEquipList;
    end;
    j := 0;
    for i := 0 to SupplyComponents.Count - 1 do
    begin
      Component := THVACComponent(SupplyComponents[i]);
      // Repeat and fill this block based on children of Equipment element
      // Need to filter out pumps
      if ((Component.ComponentType = 'Pump:ConstantSpeed') or (Component.ComponentType = 'Pump:VariableSpeed')) then
      begin
        PumpSupplyComponentID := i;
        continue;
      end;
      Obj.AddField('Equipment ' + IntToStr(j + 1) + ' Object Type', Component.ComponentType);
      Obj.AddField('Equipment ' + IntToStr(j + 1) + ' Name', Component.Name);
      j := j + 1;
    end;
  end;
  SkipEquipList:
  // all supply side objects
  Obj := IDF.AddObject('BranchList');
  Obj.AddField('Name', Name + ' Supply Branches');
  Obj.AddField('Branch 1 Name', Name + ' Supply Inlet Branch');
  if ((SystemType = cSystemTypeCool) and (HasHeatRecoveryChiller)) then
  begin
    Obj.AddField('Branch 2 Name', Name + ' Heat Recovery Chiller Branch');
    Obj.AddField('Branch 3 Name', Name + ' Supply Equipment Branch');
    Obj.AddField('Branch 4 Name', Name + ' Supply Equipment Bypass Branch');
    Obj.AddField('Branch 5 Name', Name + ' Supply Outlet Branch');
  end
  else
  begin
    Obj.AddField('Branch 2 Name', Name + ' Supply Equipment Branch');
    Obj.AddField('Branch 3 Name', Name + ' Supply Equipment Bypass Branch');
    Obj.AddField('Branch 4 Name', Name + ' Supply Outlet Branch');
  end;
  //supply connectors
  Obj := IDF.AddObject('ConnectorList');
  Obj.AddField('Name', Name + ' Supply Connectors');
  Obj.AddField('Connector 1 Object Type', 'Connector:Splitter');
  Obj.AddField('Connector 1 Name', Name + ' Supply Splitter');
  Obj.AddField('Connector 2 Object Type', 'Connector:Mixer');
  Obj.AddField('Connector 2 Name', Name + ' Supply Mixer');
  //supply splitter
  Obj := IDF.AddObject('Connector:Splitter');
  Obj.AddField('Name', Name + ' Supply Splitter');
  Obj.AddField('Inlet Branch Name', Name + ' Supply Inlet Branch');
  if ((SystemType = cSystemTypeCool) and (HasHeatRecoveryChiller)) then
  begin
    Obj.AddField('Outlet Branch 1 Name', Name + ' Heat Recovery Chiller Branch');
    Obj.AddField('Outlet Branch 2 Name', Name + ' Supply Equipment Branch');
    Obj.AddField('Outlet Branch 3 Name', Name + ' Supply Equipment Bypass Branch');
  end
  else
  begin
    Obj.AddField('Outlet Branch 1 Name', Name + ' Supply Equipment Branch');
    Obj.AddField('Outlet Branch 2 Name', Name + ' Supply Equipment Bypass Branch');
  end;
  //supply mixer
  Obj := IDF.AddObject('Connector:Mixer');
  Obj.AddField('Name', Name + ' Supply Mixer');
  Obj.AddField('Outlet Branch Name', Name + ' Supply Outlet Branch');
  if ((SystemType = cSystemTypeCool) and (HasHeatRecoveryChiller)) then
  begin
    Obj.AddField('Inlet Branch 1 Name', Name + ' Heat Recovery Chiller Branch');
    Obj.AddField('Inlet Branch 2 Name', Name + ' Supply Equipment Branch');
    Obj.AddField('Inlet Branch 3 Name', Name + ' Supply Equipment Bypass Branch');
  end
  else
  begin
    Obj.AddField('Inlet Branch 1 Name', Name + ' Supply Equipment Branch');
    Obj.AddField('Inlet Branch 2 Name', Name + ' Supply Equipment Bypass Branch');
  end;
  //supply inlet branch
  Obj := IDF.AddObject('Branch');
  Obj.AddField('Name', Name + ' Supply Inlet Branch');
  Obj.AddField('Maximum Flow Rate', '', '{m3/s}');
  Obj.AddField('Pressure Curve Name', '');
  // all supply Inlet Branches on a PLANT or CONDENSER LOOP must have a pump
  Component := THVACComponent(SupplyComponents[PumpSupplyComponentID]);
  Obj.AddField('Component 1 Object Type', Component.ComponentType);
  Obj.AddField('Component 1 Name', Component.Name);
  Obj.AddField('Component 1 Inlet Node Name', Component.SupplyInletNode);
  if ((SystemType = cSystemTypeCool) and (HasHeatRecoveryChiller)) then
  begin
    Obj.AddField('Component 1 Outlet Node Name', StringReplace(Component.SupplyOutletNode, ' Heat Recovery', '', [rfReplaceAll]));
    Obj.AddField('Component 1 Branch Control Type', 'Active', '{Active | Passive}');
    //heat recovery branch
    Obj := IDF.AddObject('Branch');
    Obj.AddField('Name', Name + ' Heat Recovery Chiller Branch');
    Obj.AddField('Maximum Flow Rate', '', '{m3/s}');
    Obj.AddField('Pressure Curve Name', '');
    for i := 0 to SupplyComponents.Count - 1 do
    begin
      Component := THVACComponent(SupplyComponents[i]);
      if AnsiContainsText(Component.Name, 'Heat Recovery') then
      begin
        Obj.AddField('Component 1 Object Type', Component.ComponentType);
        Obj.AddField('Component 1 Name', Component.Name);
        Obj.AddField('Component 1 Inlet Node Name', Component.SupplyInletNode);
        Obj.AddField('Component 1 Outlet Node Name', Name + ' Heat Recovery Chiller Outlet Node');
        Obj.AddField('Component 1 Branch Control Type', 'Active', '{Active | Passive}');
      end;
    end;
  end
  else
  begin
    Obj.AddField('Component 1 Outlet Node Name', Component.SupplyOutletNode);
    Obj.AddField('Component 1 Branch Control Type', 'Active', '{Active | Passive}');
  end;
  //supply inlet pipe
  {Obj := IDF.AddObject('Pipe:Adiabatic');
  Obj.AddField('Name', Name + ' Supply Inlet Pipe');
  Obj.AddField('Inlet Node Name', Name + ' Supply Inlet Node');
  Obj.AddField('Outlet Node Name', Name + ' Supply Inlet Pipe-' + Name + ' Supply Mixer');}
  //supply equipment branch
  Obj := IDF.AddObject('Branch');
  Obj.AddField('Name', Name + ' Supply Equipment Branch');
  Obj.AddField('Maximum Flow Rate', '', '{m3/s}');
  Obj.AddField('Pressure Curve Name', '');
  if ((SystemType = cSystemTypeHotWater) and (HasHeatPumpHotWaterHeater)) then
  begin
    Obj.AddField('Component 1 Object Type', 'WaterHeater:HeatPump');
    Obj.AddField('Component 1 Name', Name + ' Water Heater Bottom');
    Obj.AddField('Component 1 Inlet Node Name', Name + ' Pump-SWHSys1 Water HeaterNode');
    Obj.AddField('Component 1 Outlet Node Name', Name + ' Water Heater Bottom-Top Node');
    Obj.AddField('Component 1 Branch Control Type', 'Passive');
    Obj.AddField('Component 2 Object Type', 'WaterHeater:HeatPump');
    Obj.AddField('Component 2 Name', Name + ' Water Heater Top');
    Obj.AddField('Component 2 Inlet Node Name', Name + ' Water Heater Bottom-Top Node');
    Obj.AddField('Component 2 Outlet Node Name', Name + ' Water Heater Top-Tankless Node');
    Obj.AddField('Component 2 Branch Control Type', 'Passive');
    Obj.AddField('Component 3 Object Type', 'WaterHeater:Mixed');
    Obj.AddField('Component 3 Name', Name + ' Water Heater Dummy Tankless');
    Obj.AddField('Component 3 Inlet Node Name', Name + ' Water Heater Top-Tankless Node');
    Obj.AddField('Component 3 Outlet Node Name', Name + ' Supply Equipment Outlet Node');
    Obj.AddField('Component 3 Branch Control Type', 'Passive');
    Goto SkipSupplyEquipBranch
  end;
  j := 0;
  for i := 0 to SupplyComponents.Count - 1 do
  begin
    Component := THVACComponent(SupplyComponents[i]);
    // Pump should be first component on inlet branch, filter out here
    if ((Component.ComponentType = 'Pump:ConstantSpeed') or
      (Component.ComponentType = 'Pump:VariableSpeed') or
      (AnsiContainsText(Component.Name, 'Heat Recovery Chiller'))) then continue;
    Obj.AddField('Component ' + IntToStr(j + 1) + ' Object Type', Component.ComponentType);
    Obj.AddField('Component ' + IntToStr(j + 1) + ' Name', Component.Name);
    if ((SystemType = cSystemTypeCool) and (HasHeatRecoveryChiller)) then
      Obj.AddField('Component ' + IntToStr(j + 1) + ' Inlet Node Name', Name + ' Pump-' + Name + ' ChillerNode')
    else
      Obj.AddField('Component ' + IntToStr(j + 1) + ' Inlet Node Name', Component.SupplyInletNode);
    Obj.AddField('Component ' + IntToStr(j + 1) + ' Outlet Node Name', Component.SupplyOutletNode);
    if (SystemType = cSystemTypeUncontrolled) then
      Obj.AddField('Component ' + IntToStr(j + 1) + ' Branch Control Type', 'Active')
    else
      Obj.AddField('Component ' + IntToStr(j + 1) + ' Branch Control Type', Component.ControlType);
    j := j + 1;
  end;
  SkipSupplyEquipBranch:
  for i := 0 to SupplyComponents.Count - 1 do
  begin
    Component := THVACComponent(SupplyComponents[i]);
    //need to test of suppress supply side component like water heater duplications
    if not Component.SuppressToIDF   then
    begin
      if ((SystemType = cSystemTypeUncontrolled) and (Component.ComponentType = 'Pump:ConstantSpeed')) then
        T_EP_Pump(Component).PumpControlType := 'Continuous';
      Component.ToIDF;
    end;
  end;

  Obj := IDF.AddObject('Branch');
  Obj.AddField('Name', Name + ' Supply Equipment Bypass Branch');
  Obj.AddField('Maximum Flow Rate', '', '{m3/s}');
  Obj.AddField('Pressure Curve Name', '');
  Obj.AddField('Component 1 Object Type', 'Pipe:Adiabatic');
  Obj.AddField('Component 1 Name', Name + ' Supply Equipment Bypass Pipe');
  Obj.AddField('Component 1 Inlet Node Name', Name + ' Supply Equip Bypass Inlet Node');
  Obj.AddField('Component 1 Outlet Node Name', Name + ' Supply Equip Bypass Outlet Node');
  Obj.AddField('Component 1 Control Type', 'Bypass', '{ACTIVE | PASSIVE | BYPASS}');
  //supply bypass pipe
  Obj := IDF.AddObject('Pipe:Adiabatic');
  Obj.AddField('Name', Name + ' Supply Equipment Bypass Pipe');
  Obj.AddField('Inlet Node Name', Name + ' Supply Equip Bypass Inlet Node');
  Obj.AddField('Outlet Node Name', Name + ' Supply Equip Bypass Outlet Node');
  //supply outlet branch
  Obj := IDF.AddObject('Branch');
  Obj.AddField('Name', Name + ' Supply Outlet Branch');
  Obj.AddField('Maximum Flow Rate', '', '{m3/s}');
  Obj.AddField('Pressure Curve Name', '');
  Obj.AddField('Component 1 Object Type', 'Pipe:Adiabatic');
  Obj.AddField('Component 1 Name', Name + ' Supply Outlet Pipe');
  Obj.AddField('Component 1 Inlet Node Name', Name + ' Supply Mixer-' + Name + ' Supply Outlet Pipe');
  Obj.AddField('Component 1 Outlet Node Name', Name + ' Supply Outlet Node');
  Obj.AddField('Component 1 Control Type', 'Passive');
  //supply outlet pipe
  Obj := IDF.AddObject('Pipe:Adiabatic');
  Obj.AddField('Name', Name + ' Supply Outlet Pipe');
  Obj.AddField('Inlet Node Name', Name + ' Supply Mixer-' + Name + ' Supply Outlet Pipe');
  Obj.AddField('Outlet Node Name', Name + ' Supply Outlet Node');
  // All demand side objects (except actual load component)
  Obj := IDF.AddObject('BranchList');
  Obj.AddField('Name', Name + ' Demand Branches');
  Obj.AddField('Branch 1 Name', Name + ' Demand Inlet Branch');
  for i := 0 to DemandComponents.Count - 1 do
  begin
    if DemandComponents[i] is T_EP_UnitaryPackage then
    begin
      if T_EP_UnitaryPackage(DemandComponents[i]).Typ = 'WATERTOAIRHEATPUMP' then
      begin
        Obj.AddField('Branch ' + IntToStr(i + 1) + ' Name', Name + ' Demand Load Branch HP Cooling' + IntToStr(i + 1));
        Obj.AddField('Branch ' + IntToStr(i + 1) + ' Name', Name + ' Demand Load Branch HP Heating' + IntToStr(i + 1));
        continue;
      end;
    end;
    if DemandComponents[i] is T_EP_HeatPumpWaterToAir then
    begin
      Obj.AddField('Branch ' + IntToStr(i + 1) + ' Name', Name + ' Demand Load Branch HP Cooling ' + IntToStr(i + 1));
      Obj.AddField('Branch ' + IntToStr(i + 1) + ' Name', Name + ' Demand Load Branch HP Heating ' + IntToStr(i + 1));
      continue;
    end;
    Obj.AddField('Branch ' + IntToStr(i + 2) + ' Name', Name + ' Demand Load Branch ' + IntToStr(i + 1));
  end;
  if ((SystemType = cSystemTypeCondTower) and (HasHeatRecoveryChiller)) then
  begin
    Obj.AddField('Branch ' + IntToStr(DemandComponents.Count + 2) + ' Name', StringReplace(Name, 'Chiller', 'Heat Recovery Chiller', [rfReplaceAll]) + ' Demand Load Branch');
    Obj.AddField('Branch ' + IntToStr(DemandComponents.Count + 3) + ' Name', Name + ' Demand Bypass Branch');
    Obj.AddField('Branch ' + IntToStr(DemandComponents.Count + 4) + ' Name', Name + ' Demand Outlet Branch');
  end
  else
  begin
    Obj.AddField('Branch ' + IntToStr(DemandComponents.Count + 2) + ' Name', Name + ' Demand Bypass Branch');
    Obj.AddField('Branch ' + IntToStr(DemandComponents.Count + 3) + ' Name', Name + ' Demand Outlet Branch');
  end;
  //demand connectors
  Obj := IDF.AddObject('ConnectorList');
  Obj.AddField('Name', Name + ' Demand Connectors');
  Obj.AddField('Connector 1 Object Type', 'Connector:Splitter');
  Obj.AddField('Connector 1 Name', Name + ' Demand Splitter');
  Obj.AddField('Connector 2 Object Type', 'Connector:Mixer');
  Obj.AddField('Connector 2 Name', Name + ' Demand Mixer');
  //demand splitter
  Obj := IDF.AddObject('Connector:Splitter');
  Obj.AddField('Name', Name + ' Demand Splitter');
  Obj.AddField('Inlet Branch Name', Name + ' Demand Inlet Branch');
  for i := 0 to DemandComponents.Count - 1 do
  begin
    if DemandComponents[i] is T_EP_UnitaryPackage then
    begin
      if T_EP_UnitaryPackage(DemandComponents[i]).Typ = 'WATERTOAIRHEATPUMP' then
      begin
        Obj.AddField('Outlet Branch ' + IntToStr(i + 1) + ' Name', Name + ' Demand Load Branch HP Cooling' + IntToStr(i + 1));
        Obj.AddField('Outlet Branch ' + IntToStr(i + 1) + ' Name', Name + ' Demand Load Branch HP Heating' + IntToStr(i + 1));
        continue;
      end;
    end;
    if DemandComponents[i] is T_EP_HeatPumpWaterToAir then
    begin
      Obj.AddField('Outlet Branch ' + IntToStr(i + 1) + ' Name', Name + ' Demand Load Branch HP Cooling ' + IntToStr(i + 1));
      Obj.AddField('Outlet Branch ' + IntToStr(i + 1) + ' Name', Name + ' Demand Load Branch HP Heating ' + IntToStr(i + 1));
      continue;
    end;
    Obj.AddField('Outlet Branch ' + IntToStr(i + 1) + ' Name', Name + ' Demand Load Branch ' + IntToStr(i + 1));
  end;
  if ((SystemType = cSystemTypeCondTower) and (HasHeatRecoveryChiller)) then
  begin
    Obj.AddField('Outlet Branch ' + IntToStr(DemandComponents.Count + 1) + ' Name', StringReplace(Name, 'Chiller', 'Heat Recovery Chiller', [rfReplaceAll]) + ' Demand Load Branch');
    Obj.AddField('Outlet Branch ' + IntToStr(DemandComponents.Count + 2) + ' Name' , Name + ' Demand Bypass Branch');
  end
  else
    Obj.AddField('Outlet Branch ' + IntToStr(DemandComponents.Count + 1) + ' Name' , Name + ' Demand Bypass Branch');
  //demand mixer
  Obj := IDF.AddObject('Connector:Mixer');
  Obj.AddField('Name', Name + ' Demand Mixer');
  Obj.AddField('Outlet Branch Name', Name + ' Demand Outlet Branch');
  for i := 0 to DemandComponents.Count - 1 do
  begin
    if DemandComponents[i] is T_EP_UnitaryPackage then
    begin
      if T_EP_UnitaryPackage(DemandComponents[i]).Typ = 'WATERTOAIRHEATPUMP' then
      begin
        Obj.AddField('Inlet Branch ' + IntToStr(i + 1) + ' Name', Name + ' Demand Load Branch HP Cooling' + IntToStr(i + 1));
        Obj.AddField('Inlet Branch ' + IntToStr(i + 1) + ' Name', Name + ' Demand Load Branch HP Heating' + IntToStr(i + 1));
        continue;
      end;
    end;
    if DemandComponents[i] is T_EP_HeatPumpWaterToAir then
    begin
      Obj.AddField('Inlet Branch ' + IntToStr(i + 1) + ' Name', Name + ' Demand Load Branch HP Cooling ' + IntToStr(i + 1));
      Obj.AddField('Inlet Branch ' + IntToStr(i + 1) + ' Name', Name + ' Demand Load Branch HP Heating ' + IntToStr(i + 1));
      continue;
    end;
    Obj.AddField('Inlet Branch ' + IntToStr(i + 1) + ' Name', Name + ' Demand Load Branch ' + IntToStr(i + 1));
  end;
  if ((SystemType = cSystemTypeCondTower) and (HasHeatRecoveryChiller)) then
  begin
    Obj.AddField('Inlet Branch ' + IntToStr(DemandComponents.Count + 1) + ' Name', StringReplace(Name, 'Chiller', 'Heat Recovery Chiller', [rfReplaceAll]) + ' Demand Load Branch');
    Obj.AddField('Inlet Branch ' + IntToStr(DemandComponents.Count + 2) + ' Name' , Name + ' Demand Bypass Branch');
  end
  else
    Obj.AddField('Inlet Branch ' + IntToStr(DemandComponents.Count + 1) + ' Name' , Name + ' Demand Bypass Branch');
  //demand inlet branch
  Obj := IDF.AddObject('Branch');
  Obj.AddField('Name', Name + ' Demand Inlet Branch');
  Obj.AddField('Maximum Flow Rate', '', '{m3/s}');
  Obj.AddField('Pressure Curve Name', '');
  Obj.AddField('Component 1 Object Type', 'Pipe:Adiabatic');
  Obj.AddField('Component 1 Name', Name + ' Demand Inlet Pipe');
  Obj.AddField('Component 1 Inlet Node Name', Name + ' Demand Inlet Node');
  Obj.AddField('Component 1 Outlet Node Name', Name + ' Demand Inlet Pipe-' + Name + ' Demand Mixer');
  Obj.AddField('Component 1 Control Type', 'Passive');
  //demand inlet pipe
  Obj := IDF.AddObject('Pipe:Adiabatic');
  Obj.AddField('Name', Name + ' Demand Inlet Pipe');
  Obj.AddField('Inlet Node Name', Name + ' Demand Inlet Node');
  Obj.AddField('Outlet Node Name', Name + ' Demand Inlet Pipe-' + Name + ' Demand Mixer');
  for i := 0 to DemandComponents.Count - 1 do
  begin
    if DemandComponents[i] is T_EP_UnitaryPackage then continue;
    if DemandComponents[i] is T_EP_HeatPumpWaterToAir then continue;
    Component := THVACComponent(DemandComponents[i]);
    Obj := IDF.AddObject('Branch');
    Obj.AddField('Name', Name + ' Demand Load Branch ' + IntToStr(i + 1));
    Obj.AddField('Maximum Flow Rate', '', '{m3/s}');
    Obj.AddField('Pressure Curve Name', '');
    Obj.AddField('Component ' + IntToStr(i + 1) + ' Object Type', Component.ComponentType);
    Obj.AddField('Component ' + IntToStr(i + 1) + ' Name', Component.Name);
    Obj.AddField('Component ' + IntToStr(i + 1) + ' Inlet Node Name', Component.DemandInletNode);
    Obj.AddField('Component ' + IntToStr(i + 1) + ' Outlet Node Name', Component.DemandOutletNode);
    Obj.AddField('Component ' + IntToStr(i + 1) + ' Control Type', Component.DemandControlType);
  end;
  if ((SystemType = cSystemTypeCondTower) and (HasHeatRecoveryChiller)) then
  begin
    Obj := IDF.AddObject('Branch');
    Obj.AddField('Name', StringReplace(Name, 'Chiller', 'Heat Recovery Chiller', [rfReplaceAll]) + ' Demand Load Branch');
    Obj.AddField('Maximum Flow Rate', '', '{m3/s}');
    Obj.AddField('Pressure Curve Name', '');
    Obj.AddField('Component 1 Object Type', 'Chiller:Electric:EIR');
    Obj.AddField('Component 1 Name', StringReplace(Name, 'Chiller TowerSys', 'Heat Recovery Chiller', [rfReplaceAll]));
    Obj.AddField('Component 1 Inlet Node Name', StringReplace(Component.DemandInletNode, 'Chiller', 'Heat Recovery Chiller', [rfReplaceAll]));
    Obj.AddField('Component 1 Outlet Node Name', StringReplace(Component.DemandOutletNode, 'Chiller', 'Heat Recovery Chiller', [rfReplaceAll]));
    Obj.AddField('Component 1 Control Type', 'Active');
  end;
  // ksb: handle heat pumps differently because they are treated as one component (unitary system), but
  // ksb: really have two demand components (heating, cooling coils)
  for i := 0 to DemandComponents.Count - 1 do
  begin
    if DemandComponents[i] is T_EP_UnitaryPackage then
    begin
      if T_EP_UnitaryPackage(DemandComponents[i]).Typ = 'WATERTOAIRHEATPUMP' then
      begin
        Component := THVACComponent(DemandComponents[i]);
        //cooling demand load branch
        Obj := IDF.AddObject('Branch');
        Obj.AddField('Name', Name + ' Demand Load Branch HP Cooling' + IntToStr(i + 1));
        Obj.AddField('Maximum Flow Rate', '', '{m3/s}');
        Obj.AddField('Pressure Curve Name', '');
        Obj.AddField('Component ' + IntToStr(i + 1) + ' Object Type', 'Coil:Cooling:WaterToAirHeatPump:EquationFit');
        Obj.AddField('Component ' + IntToStr(i + 1) + ' Name', Component.Name + '_cooling_coil');
        Obj.AddField('Component ' + IntToStr(i + 1) + ' Inlet Node Name', Component.Name + '_cooling_coil_water_inlet');
        Obj.AddField('Component ' + IntToStr(i + 1) + ' Outlet Node Name', Component.Name + '_cooling_coil_water_outlet');
        Obj.AddField('Component ' + IntToStr(i + 1) + ' Control Type', 'Active');
        //heating demand load branch
        Obj := IDF.AddObject('Branch');
        Obj.AddField('Name', Name + ' Demand Load Branch HP Heating' + IntToStr(i + 1));
        Obj.AddField('Maximum Flow Rate', '', '{m3/s}');
        Obj.AddField('Pressure Curve Name', '');
        Obj.AddField('Component ' + IntToStr(i + 1) + ' Object Type', 'Coil:Heating:WaterToAirHeatPump:EquationFit');
        Obj.AddField('Component ' + IntToStr(i + 1) + ' Name', Component.Name + '_heating_coil');
        Obj.AddField('Component ' + IntToStr(i + 1) + ' Inlet Node Name', Component.Name + '_heating_coil_water_inlet');
        Obj.AddField('Component ' + IntToStr(i + 1) + ' Outlet Node Name', Component.Name + '_heating_coil_water_outlet');
        Obj.AddField('Component ' + IntToStr(i + 1) + ' Control Type', 'Active');
      end;
    end;
    if DemandComponents[i] is T_EP_HeatPumpWaterToAir then
    begin
      Component := T_EP_HeatPumpWaterToAir(DemandComponents[i]);
      //cooling demand load branch
      Obj := IDF.AddObject('Branch');
      Obj.AddField('Name', Name + ' Demand Load Branch HP Cooling ' + IntToStr(i + 1));
      Obj.AddField('Maximum Flow Rate', '', '{m3/s}');
      Obj.AddField('Pressure Curve Name', '');
      Obj.AddField('Component ' + IntToStr(i + 1) + ' Object Type', 'Coil:Cooling:WaterToAirHeatPump:EquationFit');
      Obj.AddField('Component ' + IntToStr(i + 1) + ' Name', Component.Name + ' Cool Coil');
      Obj.AddField('Component ' + IntToStr(i + 1) + ' Inlet Node Name', Component.Name + ' Cool Coil Water Inlet Node');
      Obj.AddField('Component ' + IntToStr(i + 1) + ' Outlet Node Name', Component.Name + ' Cool Coil Water Outlet Node');
      Obj.AddField('Component ' + IntToStr(i + 1) + ' Control Type', 'Active');
      //heating demand load branch
      Obj := IDF.AddObject('Branch');
      Obj.AddField('Name', Name + ' Demand Load Branch HP Heating ' + IntToStr(i + 1));
      Obj.AddField('Maximum Flow Rate', '', '{m3/s}');
      Obj.AddField('Pressure Curve Name', '');
      Obj.AddField('Component ' + IntToStr(i + 1) + ' Object Type', 'Coil:Heating:WaterToAirHeatPump:EquationFit');
      Obj.AddField('Component ' + IntToStr(i + 1) + ' Name', Component.Name + ' Heat Coil');
      Obj.AddField('Component ' + IntToStr(i + 1) + ' Inlet Node Name', Component.Name + ' Heat Coil Water Inlet Node');
      Obj.AddField('Component ' + IntToStr(i + 1) + ' Outlet Node Name', Component.Name + ' Heat Coil Water Outlet Node');
      Obj.AddField('Component ' + IntToStr(i + 1) + ' Control Type', 'Active');
    end;
  end;
  Obj := IDF.AddObject('Branch');
  Obj.AddField('Name', Name + ' Demand Bypass Branch');
  Obj.AddField('Maximum Flow Rate', '', '{m3/s}');
  Obj.AddField('Pressure Curve Name', '');
  Obj.AddField('Component 1 Object Type', 'Pipe:Adiabatic');
  Obj.AddField('Component 1 Name', Name + ' Demand Bypass Pipe');
  Obj.AddField('Component 1 Inlet Node Name', Name + ' Demand Bypass Pipe Inlet Node');
  Obj.AddField('Component 1 Outlet Node Name', Name + ' Demand Bypass Pipe Outlet Node');
  Obj.AddField('Component 1 Control Type', 'Bypass', '{ACTIVE | PASSIVE| BYPASS}');
  //demand bypass pipe
  Obj := IDF.AddObject('Pipe:Adiabatic');
  Obj.AddField('Name', Name + ' Demand Bypass Pipe');
  Obj.AddField('Inlet Node Name', Name + ' Demand Bypass Pipe Inlet Node');
  Obj.AddField('Outlet Node Name', Name + ' Demand Bypass Pipe Outlet Node');
  //demand outlet branch
  Obj := IDF.AddObject('Branch');
  Obj.AddField('Name', Name + ' Demand Outlet Branch');
  Obj.AddField('Maximum Flow Rate', '', '{m3/s}');
  Obj.AddField('Pressure Curve Name', '');
  Obj.AddField('Component 1 Object Type', 'Pipe:Adiabatic');
  Obj.AddField('Component 1 Name', Name + ' Demand Outlet Pipe');
  Obj.AddField('Component 1 Inlet Node Name', Name + ' Demand Mixer-' + Name + ' Demand Outlet Pipe');
  Obj.AddField('Component 1 Outlet Node Name', Name + ' Demand Outlet Node');
  Obj.AddField('Component 1 Control Type', 'Passive' );
  //demand outlet pipe
  Obj := IDF.AddObject('Pipe:Adiabatic');
  Obj.AddField('Name', Name + ' Demand Outlet Pipe');
  Obj.AddField('Inlet Node Name', Name + ' Demand Mixer-' + Name + ' Demand Outlet Pipe');
  Obj.AddField('Outlet Node Name', Name + ' Demand Outlet Node');
end;

constructor T_EP_CondenserSystem.Create;
begin
  inherited;
  Name := 'Cond1';
  LoopType := 'Condenser';
end;

{T_EP_ColdWaterSystem}

constructor T_EP_ColdWaterSystem.Create;
begin
  inherited;
  Name := 'WaterSys';
  SupplyComponents.Create;
  DemandComponents.Create;
  StorageComponents.Create;
end;

function T_EP_ColdWaterSystem.AddSupplyComponent(Component: THVACComponent): THVACComponent;
begin
  SupplyComponents.Add(Component);
  result := Component;
end;

function T_EP_ColdWaterSystem.AddDemandComponent(Component: THVACComponent): THVACComponent;
begin
  DemandComponents.Add(Component);
  result := Component;
end;

function T_EP_ColdWaterSystem.AddStorageComponent(Component: THVACComponent): THVACComponent;
begin
  StorageComponents.Add(Component);
  result := Component;
end;

procedure T_EP_ColdWaterSystem.Finalize;
begin
  inherited;
end;

{ T_EP_RefrigerationCompressorRack }

constructor T_EP_RefrigerationCompressorRack.Create;
begin
  inherited;
  Systems.Add(Self);
  ComponentType := 'Refrigeration:CompressorRack';
  DemandControlType := 'Passive';
  HeatRejection := 'AirCooled';
  RefrigeratedCase := TObjectList.Create;
  RefrigeratedWalkin := TObjectList.Create;
end;

function T_EP_RefrigerationCompressorRack.AddCase(Component: THVACComponent): THVACComponent;
begin
  RefrigeratedCase.Add(Component);
  RefrigeratedWalkin.Add(Component);
  Result := Component;
end;

procedure T_EP_RefrigerationCompressorRack.SetHeatRejection(HeatRejectionType: string);
var
  Component: THVACComponent;
begin
  if SameText(HeatRejectionType, 'AirCooled') then
  begin
    HeatRejectionValue := 'AirCooled';
    if Assigned(HeatRejectionLoop) then HeatRejectionLoop.Free;
  end
  else if SameText(HeatRejectionType, 'EvaporativelyCooled') then
  begin
    HeatRejectionValue := 'EvaporativelyCooled';
    if Assigned(HeatRejectionLoop) then HeatRejectionLoop.Free;
  end
  else if (SameText(HeatRejectionType, 'WaterCooledSingleSpeedTower') or
    SameText(HeatRejectionType, 'WaterCooledTwoSpeedTower') or
    SameText(HeatRejectionType, 'WaterCooledVariableSpeedTower')) then
  begin
    HeatRejectionValue := 'WaterCooled';
    DemandControlType := 'Active';
    DemandInletNode := Name + ' Water Inlet Node';
    DemandOutletNode := Name + ' Water Outlet Node';
    if not Assigned(HeatRejectionLoop) then
    begin
      HeatRejectionLoop := T_EP_CondenserSystem.Create;
      HeatRejectionLoop.Name := Name + '_CondenserLoop';
      HeatRejectionLoop.SystemType := cSystemTypeCondTower;
      HeatRejectionLoop.AddDemandComponent(Self);
      Component := T_EP_Pump.Create;
      T_EP_Pump(Component).Typ := 'Constant';
      HeatRejectionLoop.AddSupplyComponent(Component);
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

procedure T_EP_RefrigerationCompressorRack.Finalize;
begin
  inherited;
end;

procedure T_EP_RefrigerationCompressorRack.ToIDF;
var
  i: integer;
  j: integer;
  Component: THVACComponent;
  Obj: TEnergyPlusObject;
  CaseList: TStringList;
  WalkinList: TStringList;
  RackPreProcMacro: TPreProcMacro;
  RackStringList: TStringList;
  RackString: string;
begin
  inherited;
  Finalize;
  IDF.AddComment('');   //intentional blank line
  IDF.AddComment('Refrigeration Compressor Rack: ' + Name);
  RackPreProcMacro := TPreProcMacro.Create('include/HPBRefrigerationCompressorRacks.imf');
  try
    RackString := RackPreProcMacro.getDefinedText(DataSetKey);
    RackString := ReplaceRegExpr('#{Name}', RackString, Name, False);
    if SameText(HeatRejectionLocation, 'Outdoors') then
    begin
      RackString := ReplaceRegExpr('#{HeatRejectionLocation}\w*', RackString, 'Outdoors', False);
    end
    else if SameText(HeatRejectionLocation, 'Zone') then
    begin
      RackString := ReplaceRegExpr('#{HeatRejectionLocation}\w*', RackString, 'Zone', False);
      RackString := ReplaceRegExpr('#{ZoneName}', RackString, HeatRejectionZone, False);
    end;
    if COP <> -9999.0 then
    begin
      RackString := ReplaceRegExpr('#{COP}\d*\.\d*', RackString, FloatToStr(COP), False);
    end
    else
    begin
      RackString := ReplaceRegExpr('#{COP}', RackString, '', False);
    end;
    //COP curve
    RackString := ReplaceRegExpr('#{CopCurveName}', RackString, Name + '_CopFuncTempCurve', False);
    if FanPower <> -9999.0 then
    begin
      RackString := ReplaceRegExpr('#{FanPower}\d*\.\d*', RackString, FloatToStr(FanPower), False);
    end
    else
    begin
      RackString := ReplaceRegExpr('#{FanPower}', RackString, '', False);
    end;
    //fan power curve
    RackString := ReplaceRegExpr('#{FanCurveName}', RackString, Name + '_FanFuncTempCurve', False);
    RackString := ReplaceRegExpr('#{CondenserType}', RackString, HeatRejectionValue, False);
    if SameText(HeatRejectionValue, 'AirCooled') then
    begin
      RackString := ReplaceRegExpr('#{DemandInletNode}', RackString, '', False);
      RackString := ReplaceRegExpr('#{DemandOutletNode}', RackString, '', False);
      RackString := ReplaceRegExpr('#{LoopFlowType}\w*', RackString, '', False);
      RackString := ReplaceRegExpr('#{DesignFlowRate}\d*\.\d*', RackString, '', False);
      RackString := ReplaceRegExpr('#{MaxFlowRate}\d*\.\d*', RackString, '', False);
      RackString := ReplaceRegExpr('#{MaxOutletTemp}\d*\.\d*', RackString, '', False);
      RackString := ReplaceRegExpr('#{MinInletTemp}\d*\.\d*', RackString, '', False);
      RackString := ReplaceRegExpr('#{EvapEffectiveness}\d*\.\d*', RackString, '', False);
      RackString := ReplaceRegExpr('#{EvapAirFlowRate}\w*', RackString, '', False);
      RackString := ReplaceRegExpr('#{BasinHeaterCapacity}\d*\.\d*', RackString, '', False);
      RackString := ReplaceRegExpr('#{BasinSetpointTemperature}\d*\.\d*', RackString, '', False);
      RackString := ReplaceRegExpr('#{EvapPumpPower}\w*', RackString, '', False);
      RackString := ReplaceRegExpr('#{AirInletNodeName}', RackString, Name + '_CondenserNode', False);
    end
    else if SameText(HeatRejectionValue, 'EvaporativelyCooled') then
    begin
      RackString := ReplaceRegExpr('#{DemandInletNode}', RackString, '', False);
      RackString := ReplaceRegExpr('#{DemandOutletNode}', RackString, '', False);
      RackString := ReplaceRegExpr('#{LoopFlowType}\w*', RackString, '', False);
      RackString := ReplaceRegExpr('#{DesignFlowRate}\d*\.\d*', RackString, '', False);
      RackString := ReplaceRegExpr('#{MaxFlowRate}\d*\.\d*', RackString, '', False);
      RackString := ReplaceRegExpr('#{MaxOutletTemp}\d*\.\d*', RackString, '', False);
      RackString := ReplaceRegExpr('#{MinInletTemp}\d*\.\d*', RackString, '', False);
      if EvapEffectiveness <> -9999.0 then
      begin
        RackString := ReplaceRegExpr('#{EvapEffectiveness}\d*\.\d*', RackString, FloatToStr(EvapEffectiveness), False);
      end
      else
      begin
        RackString := ReplaceRegExpr('#{EvapEffectiveness}', RackString, '', False);
      end;
      RackString := ReplaceRegExpr('#{EvapAirFlowRate}\w*', RackString, '', False);
      RackString := ReplaceRegExpr('#{BasinHeaterCapacity}', RackString, '', False);
      RackString := ReplaceRegExpr('#{BasinSetpointTemperature}', RackString, '', False);
      RackString := ReplaceRegExpr('#{EvapPumpPower}', RackString, '', False);
      RackString := ReplaceRegExpr('#{AirInletNodeName}', RackString, '', False);
    end
    else if (SameText(HeatRejectionValue, 'WaterCooled')) then
    begin
      RackString := ReplaceRegExpr('#{DemandInletNode}', RackString, DemandInletNode, False);
      RackString := ReplaceRegExpr('#{DemandOutletNode}', RackString, DemandOutletNode, False);
      RackString := ReplaceRegExpr('#{LoopFlowType}', RackString, '', False);
      RackString := ReplaceRegExpr('#{DesignFlowRate}', RackString, '', False);
      RackString := ReplaceRegExpr('#{MaxFlowRate}', RackString, '', False);
      RackString := ReplaceRegExpr('#{MaxOutletTemp}', RackString, '', False);
      RackString := ReplaceRegExpr('#{MinInletTemp}', RackString, '', False);
      RackString := ReplaceRegExpr('#{EvapEffectiveness}\d*\.\d*', RackString, '', False);
      RackString := ReplaceRegExpr('#{EvapAirFlowRate}\w*', RackString, '', False);
      RackString := ReplaceRegExpr('#{BasinHeaterCapacity}\d*\.\d*', RackString, '', False);
      RackString := ReplaceRegExpr('#{BasinSetpointTemperature}\d*\.\d*', RackString, '', False);
      RackString := ReplaceRegExpr('#{EvapPumpPower}\w*', RackString, '', False);
      RackString := ReplaceRegExpr('#{AirInletNodeName}', RackString, '', False);
    end;
    if RefrigeratedCase.Count + RefrigeratedWalkin.Count = 1 then
    begin
      if RefrigeratedCase.Count > 0 then
      begin
        Component := THVACComponent(RefrigeratedCase.Items[0]);
        RackString := ReplaceRegExpr('#{CaseListName}', RackString, Component.Name, False);
      end
      else if RefrigeratedWalkin.Count > 0 then
      begin
        Component := THVACComponent(RefrigeratedWalkin.Items[0]);
        RackString := ReplaceRegExpr('#{CaseListName}', RackString, Component.Name, False);
      end;
    end
    else if RefrigeratedCase.Count + RefrigeratedWalkin.Count > 1 then
    begin
      RackString := ReplaceRegExpr('#{CaseListName}', RackString, Name + '_CaseList', False);
    end;
    if SameText(HeatRejectionLocation, 'Zone') and not SameText(HeatRejectionZone, 'NotSet') then
    begin
      RackString := ReplaceRegExpr('#{ZoneName}', RackString, HeatRejectionZone, False);
    end
    else
    begin
      RackString := ReplaceRegExpr('#{ZoneName}', RackString, '', False);
    end;
    //write to idf
    RackString := ReplaceRegExpr(#$D#$A#$D#$A#$D#$A, RackString, '', False);
    RackStringList := TStringList.Create;
    RackStringList.Add(RackString);
    IDF.AddStringList(RackStringList);
    //add air inlet node if air cooled
    if SameText(HeatRejectionValue, 'AirCooled') or SameText(HeatRejectionValue, 'EvaporativelyCooled') then
    begin
      Obj := IDF.AddObject('OutdoorAir:Node');
      Obj.AddField('Name', Name + '_CondenserNode');
    end;
    //add case list
    if RefrigeratedCase.Count + RefrigeratedWalkin.Count > 1 then
    begin
      CaseList := TStringList.Create;
      WalkinList := TStringList.Create;
      Obj := IDF.AddObject('Refrigeration:CaseAndWalkInList');
      Obj.AddField('Refrigerated Case List Name', Name + '_CaseList');
      for i := 0 to RefrigeratedCase.Count - 1 do
      begin
        Component := THVACComponent(RefrigeratedCase.Items[i]);
        with CaseList do
        begin
          Sorted := True;
          Duplicates := dupIgnore;
          Add(Component.Name);
        end;
      end;
      if RefrigeratedCase.Count > 0 then
      begin
        for j := 0 to CaseList.Count - 1 do
        begin
          Component := THVACComponent(RefrigeratedCase.Items[j]);
          Obj.AddField('Case ' + IntToStr(j + 1) + ' Name', Component.Name);
        end;
      end;
      for i := 0 to RefrigeratedWalkin.Count - 1 do
      begin
        Component := THVACComponent(RefrigeratedWalkin.Items[i]);
        with WalkinList do
        begin
          Sorted := True;
          Duplicates := dupIgnore;
          Add(Component.Name);
        end;
      end;
      if RefrigeratedWalkin.Count > 0 then
      begin
        for j := 0 to WalkinList.Count - 1 do
        begin
          Component := THVACComponent(RefrigeratedWalkin.Items[j]);
          Obj.AddField('Case ' + IntToStr(j+1) + ' Name', Component.Name);
        end;
      end;
    end;
  finally
    RackPreProcMacro.Free;
  end;
end;

{ T_EP_RefrigerationSystem }

constructor T_EP_RefrigerationSystem.Create;
begin
  inherited;
  RefrigeratedCase := TObjectList.Create;
  RefrigeratedWalkin := TObjectList.Create;
  Components := TObjectList.Create;
end;

procedure T_EP_RefrigerationSystem.SetDemandSystem(SystemParameter:T_EP_System);
begin
  if Assigned(SystemParameter) then
  begin
    DemandSystemValue := SystemParameter;
    DemandInletNode := Name + ' Water Inlet Node';
    DemandOutletNode := Name + ' Water Outlet Node';
  end;
end;

function T_EP_RefrigerationSystem.AddCase(Component: THVACComponent): THVACComponent;
begin
  RefrigeratedCase.Add(Component);
  RefrigeratedWalkin.Add(Component);
  Result := Component;
end;

function T_EP_RefrigerationSystem.AddRefrigSystemComponent(Component: THVACComponent): THVACComponent;
begin
  Components.Add(Component);
  TSystemComponent(Component).System := Self;
  THVACComponent(Component).SuppressToIDF := false;
  Result := Component;
end;

procedure T_EP_RefrigerationSystem.Finalize;
begin
  inherited;
end;

procedure T_EP_RefrigerationSystem.ToIDF;
var
  i: integer;
  j: integer;
  Component: THVACComponent;
  Obj: TEnergyPlusObject;
  CaseList: TStringList;
  WalkinList: TStringList;
begin
  inherited;
  finalize;
  IDF.AddComment('');   //intentional blank line
  IDF.AddComment('Refrigeration System: ' + Name);  
  //add refrigeration system object
  Obj := IDF.AddObject('Refrigeration:System');
  Obj.AddField('Name', Name);
  if RefrigeratedCase.Count + RefrigeratedWalkin.Count = 1 then
  begin
    if RefrigeratedCase.Count > 0 then
    begin
      Component := THVACComponent(RefrigeratedCase.Items[0]);
      Obj.AddField('Refrigeration Case Name or CaseList Name', Component.Name);
    end
    else if RefrigeratedWalkin.Count > 0 then
    begin
      Component := THVACComponent(RefrigeratedWalkin.Items[0]);
      Obj.AddField('Refrigeration Case Name or CaseList Name', Component.Name);
    end;
  end
  else if RefrigeratedCase.Count + RefrigeratedWalkin.Count > 1 then
  begin
    Obj.AddField('Refrigeration Case Name or CaseList Name' , Name + '_CaseList');
  end;
  Obj.AddField('Refrigeration Transfer Load or TransferLoad List Name', '');
  Obj.AddField('Refrigeration Condenser Name', Name + '_RefrigCond');
  Obj.AddField('Compressor Name or CompressorList Name', Name + '_CompressorList');
  if MinCondensingTemp <> -9999.0 then
    Obj.AddField('Minimum Condensing Temperature {C}', MinCondensingTemp)
  else
    Obj.AddField('Minimum Condensing Temperature {C}', '25.0');
  Obj.AddField('Refrigeration System Working Fluid Type', Refrigerant);
  Obj.AddField('Suction Temperature Control Type','ConstantSuctionTemperature');
  Obj.AddField('Mechanical Subcooler Name','');
  Obj.AddField('Liquid Suction Heat Exchanger Subcooler Name','');
  Obj.AddField('Sum UA Suction Piping {W/(deltaC)}','');
  Obj.AddField('Suction Piping Zone Name','');
  Obj.AddField('End-Use Subcategory', 'Refrigeration');
  Obj.AddField('Number of Compressor Stages', '1', '{ 1 | 2 }');
  Obj.AddField('Intercooler Type', 'None', '{ None | Flash Intercooler | Shell-and-Coil Intercooler }');
  Obj.AddField('Shell-and-Coil Intercooler Effectiveness', '0.8');
  Obj.AddField('High-Stage Compressor or CompressorList Name', '');
  //add case list
  if RefrigeratedCase.Count + RefrigeratedWalkin.Count > 1 then
  begin
    CaseList := TStringList.Create;
    WalkinList := TStringList.Create;
    Obj := IDF.AddObject('Refrigeration:CaseAndWalkInList');
    Obj.AddField('Refrigerated Case List Name', Name + '_CaseList');
    for i := 0 to RefrigeratedCase.Count - 1 do
    begin
      Component := THVACComponent(RefrigeratedCase.Items[i]);
      with CaseList do
      begin
        Sorted := True;
        Duplicates := dupIgnore;
        Add(Component.Name);
      end;
    end;
    if RefrigeratedCase.Count > 0 then
    begin
      for j := 0 to CaseList.Count - 1 do
      begin
        Component := THVACComponent(RefrigeratedCase.Items[j]);
        Obj.AddField('Case ' + IntToStr(j + 1) + ' Name', Component.Name);
      end;
    end;
    for i := 0 to RefrigeratedWalkin.Count - 1 do
    begin
      Component := THVACComponent(RefrigeratedWalkin.Items[i]);
      with WalkinList do
      begin
        Sorted := True;
        Duplicates := dupIgnore;
        Add(Component.Name);
      end;
    end;
    if RefrigeratedWalkin.Count > 0 then
    begin
      for j := 0 to WalkinList.Count - 1 do
      begin
        Component := THVACComponent(RefrigeratedWalkin.Items[j]);
        Obj.AddField('Case ' + IntToStr(j+1) + ' Name', Component.Name);
      end;
    end;
  end;
  //add compressor(s) and compressor list
  Obj := IDF.AddObject('Refrigeration:CompressorList');
  Obj.AddField('Refrigeration Compressor List Name', Name + '_CompressorList');
  for i := 0 to Components.Count - 1 do
  begin
    Component := THVACComponent(Components[i]);
    Component.Finalize; // to set compressor name
    if SameText(Component.ComponentType, 'Refrigeration:Compressor') then
    begin
      Obj.AddField('Compressor ' + IntToStr(i+1) + ' Name' , Component.Name);
      Component.ToIDF;
    end
    else if SameText(Component.ComponentType, 'Refrigeration:Condenser:AirCooled') or
      SameText(Component.ComponentType, 'Refrigeration:Condenser:EvaporativeCooled') or
      SameText(Component.ComponentType, 'Refrigeration:Condenser:WaterCooled') then
    begin
      Component.ToIDF;
    end;
  end;
end;

procedure T_EP_CondenserSystem.Finalize;
begin
  inherited;
end;

end.
