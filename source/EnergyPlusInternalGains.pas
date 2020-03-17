////////////////////////////////////////////////////////////////////////////////
//                                                                            //
// Copyright (c) 2008-2020 Alliance for Sustainable Energy.                   //
// All rights reserved.                                                       //
//                                                                            // 
////////////////////////////////////////////////////////////////////////////////

unit EnergyPlusInternalGains;

interface

uses
  SysUtils,
  Contnrs,
  Globals,
  EnergyPlusCore,
  EnergyPlusSchedules,
  EnergyPlusSettings,
  EnergyPlusEconomics,
  EnergyPlusZoneEquipmentList;

type
  //this is only an internal gain
  T_EP_Infiltration = class(TEnergyPlusGroup)
  public
    ZoneName: string;
    DesignLevel: Double;
    FlowPerExtWallArea: double;
    FlowPerExtArea: double;
    ScheduleName: string;
    Schedule: T_EP_Schedule;
    EndUseSubcategory: string;
    Cost: T_EP_Economics;
    procedure ToIDF; override;
    procedure Finalize; override;
  end;

  T_EP_VentilationSimple = class(TEnergyPlusGroup)
  public
    ZoneName: string;
    FanPressureDrop: double;
    FanEfficiency: double;
    DesignFlowRate: double;
    VentilationType: string;
    MinimumIndoorTemp: double;
    MaximumIndoorTemp: double;
    MinimumOutdoorTemp: double;
    MaximumOutdoorTemp: double;
    DeltaTemp: double;
    MotorizedDamper: boolean;
    MinOASchedule: string;
    procedure ToIDF; override;
    constructor Create; reintroduce;
  end;

  T_EP_People = class(TEnergyPlusGroup)
  public
    FExteriorLoad: Boolean;
    ZoneName: string;
    DesignLevel: Double;
    ScheduleName: string;
    Schedule: T_EP_Schedule;
    EndUseSubcategory: string;
    Cost: T_EP_Economics;
    constructor Create(ExteriorLoads: Boolean); reintroduce;
    procedure ToIDF; override;
    procedure Finalize; override;
  end;

  T_EP_Lighting = class(TEnergyPlusGroup)
  public
    FExteriorLoad: Boolean;
    ZoneName: string;
    DesignLevel: Double;
    ScheduleName: string;
    Schedule: T_EP_Schedule;
    EndUseSubcategory: string;
    Cost: T_EP_Economics;
    HoursPerDay : integer;
    fracRadiant: double;
    fracReturn: double;
    SchFileColumn: integer;
    SchFileRowSkip: integer;
    constructor Create(ExteriorLoads: Boolean); reintroduce;
    procedure ToIDF; override;
    procedure Finalize; override;
  end;

  T_EP_SimpleRefrigeration = class(TEnergyPlusGroup)  //added as exterior equipment
  public
    DesignLevel: Double;
    ScheduleName: string;
    Schedule: T_EP_Schedule;
    EndUseSubcategory: string;
    Cost: T_EP_Economics;
    procedure ToIDF; override;
    procedure AddCost(CostPer: double);
    procedure Finalize; override;
  end;

  T_EP_ZoneGains = class(TObject)
  private
    FPeople: T_EP_People;
    FLighting: T_EP_Lighting;
    FEquipmentList : T_EP_EquipmentList;
  public
    constructor Create; reintroduce;
    destructor Destroy; override;
    property EquipmentList: T_EP_EquipmentList read FEquipmentList write FEquipmentList;
    property Lighting: T_EP_Lighting read FLighting write FLighting;
    property People: T_EP_People read FPeople write FPeople;
  end;

implementation

uses GlobalFuncs, EnergyPlusZones, Classes, EnergyPlusObject;

procedure T_EP_Infiltration.Finalize;
begin
  inherited;
end;

procedure T_EP_Infiltration.ToIDF;
var
  Obj: TEnergyPlusObject;
  aZone: T_EP_Zone;
  dQuan: double;
begin
  inherited;

  Obj := IDF.AddObject('ZoneInfiltration:DesignFlowRate');
  Obj.AddField('Name', ZoneName + '_Infiltration');
  Obj.AddField('Zone Name', ZoneName);
  if ScheduleName = '' then
    Obj.AddField('Schedule Name', 'INFIL_SCH')
  else
    Obj.AddField('Schedule Name', ScheduleName);
  if FlowPerExtWallArea > 0.0 then
    Obj.AddField('Design Volume Flow Rate Calculation Method', 'Flow/ExteriorWallArea')
  else if FlowPerExtArea > 0.0 then
    Obj.AddField('Design Volume Flow Rate Calculation Method', 'Flow/ExteriorArea')
  else
    Obj.AddField('Design Volume Flow Rate Calculation Method', 'Flow/Zone');
  if (FlowPerExtWallArea > 0.0) or (FlowPerExtArea > 0.0) then
    Obj.AddField('Design Flow Rate', '', '{m3/s}')
  else
    Obj.AddField('Design Flow Rate', FloatToStr(DesignLevel), '{m3/s}');
  Obj.AddField('Flow per Zone Area', '', '{m3/s/m2}');
  if FlowPerExtWallArea > 0.0 then
    Obj.AddField('Flow per Exterior Surface Area', FloatToStr(FlowPerExtWallArea), '{m3/s/m2}')
  else if FlowPerExtArea > 0.0 then
    Obj.AddField('Flow per Exterior Surface Area', FloatToStr(FlowPerExtArea), '{m3/s/m2}')
  else
    Obj.AddField('Flow per Exterior Surface Area', '', '{m3/s/m2}');
  Obj.AddField('Air Changes Per Hour', '', '{ACH}');
  Obj.AddField('Constant Term Coefficient', 1.0);
  Obj.AddField('Temperature Term Coefficient', 0.0);
  Obj.AddField('Velocity Term Coefficient', 0.0);
  Obj.AddField('Velocity Squared Term Coefficient', 0.0);
  if not Assigned(Cost) then
  begin
    //put in generic cost structure for post processing
    Cost := T_EP_Economics.Create;
    Cost.Name := 'Infiltration:' + ZoneName;
    Cost.RefObjName := ZoneName;
    Cost.Costing := ecCostPerEach;
    Cost.CostType := etGeneral;
    Cost.CostValue := 1;
    //apply multiplier
    aZone := GetZone(ZoneName);
    dQuan := (DesignLevel * aZone.ZoneMultiplier);
    Cost.Quantity := dQuan;
  end;
  if Assigned(Cost) and EPSettings.Costs then Cost.ToIDF;
end;

constructor T_EP_VentilationSimple.Create;
begin
  inherited;
  self.DesignFlowRate := -999.0;
  self.FanPressureDrop := 0.0;
  self.FanEfficiency := 0.5;
end;

procedure T_EP_VentilationSimple.ToIDF;
var
  Obj: TEnergyPlusObject;
  aZone: T_EP_Zone;
  VentSched: string;
begin
  inherited;
  aZone := GetZone(self.ZoneName);
  Obj := IDF.AddObject('ZoneVentilation:DesignFlowRate');
  Obj.AddField('Name', self.Name);
  Obj.AddField('Zone Name', aZone.Name);
  if self.MinOASchedule = '' then
  begin
    if aZone.DemandControlVentilation then
    begin
      VentSched := 'BLDG_OCC_SCH';
      if assigned(aZone.InternalGains.People) then begin
        if aZone.InternalGains.People.ScheduleName <> '' then
          VentSched := aZone.InternalGains.People.ScheduleName;
        Obj.AddField('Schedule Name', VentSched);
      end;
    end
    else if self.MotorizedDamper then
    begin
      Obj.AddField('Schedule Name', 'MinOA_MotorizedDamper_Sched');
    end
    else
    begin
      Obj.AddField('Schedule Name', 'MinOA_Sched');
    end;
  end
  else
  begin
    Obj.AddField('Schedule Name', self.MinOASchedule);
  end;
  Obj.AddField('Design Flow Rate Calculation Method', 'Flow/Zone');
  if self.DesignFlowRate <> -999.0 then
  begin
    Obj.AddField('Design Flow Rate', self.DesignFlowRate, '{m3/s}');
  end
  else
  begin
    Obj.AddField('Design Flow Rate', aZone.MaxOA, '{m3/s}');
  end;
  Obj.AddField('Volume Flow Rate per Zone Floor Area', '', '{m3/s/m2}');
  Obj.AddField('Volume Flow Rate per Person', '', '{m3/s/person}');
  Obj.AddField('Air Changes per Hour', '', '{ACH}');
  if VentilationType <> '' then
  begin
    Obj.AddField('Ventilation Type', VentilationType);
  end
  else
  begin
    Obj.AddField('Ventilation Type', 'Intake');
  end;
  Obj.AddField('Fan Pressure Rise', FanPressureDrop);
  Obj.AddField('Fan Total Efficiency', FanEfficiency);
  Obj.AddField('Constant Term Coefficient', 1.0);
  Obj.AddField('Temperature Term Coefficient', 0.0);
  Obj.AddField('Velocity Term Coefficient', 0.0);
  Obj.AddField('Velocity Squared Term Coefficient', 0.0);
  Obj.AddField('Minimum Indoor Temperature', MinimumIndoorTemp, '{C}');
  Obj.AddField('Minimum Indoor Temperature Schedule Name', '');
  Obj.AddField('Maximum Indoor Temperature', MaximumIndoorTemp,  '{C}');
  Obj.AddField('Maximum Indoor Temperature Schedule Name', '');
  Obj.AddField('Delta Temperature', DeltaTemp,  '{C}');
  Obj.AddField('Delta Temperature Schedule Name', '');
  Obj.AddField('Minimum Outdoor Temperature', MinimumOutdoorTemp,  '{C}');
  Obj.AddField('Minimum Outdoor Temperature Schedule Name', '');
  Obj.AddField('Maximum Outdoor Temperature', MaximumOutdoorTemp,  '{C}');
  obj.AddField('Maximum Outdoor Temperature Schedule Name', '');
  Obj.Addfield('Maximum Wind Speed', 6.0,  '{m/s}');
end;

{ T_EP_People }

constructor T_EP_People.Create(ExteriorLoads: Boolean);
begin
  FExteriorLoad := ExteriorLoads;
end;

procedure T_EP_People.Finalize;
begin
  inherited;
end;

procedure T_EP_People.ToIDF;
var
  Obj: TEnergyPlusObject;
  aZone: T_EP_Zone;
  dQuan: double;
begin
  inherited;
  Obj := IDF.AddObject('People');
  Obj.AddField('Name', ZoneName + ' People');
  Obj.AddField('Zone Name', ZoneName);
  if ScheduleName = '' then
    Obj.AddField('Schedule Name', 'BLDG_OCC_SCH')
  else
    Obj.AddField('Schedule Name', ScheduleName);
  Obj.AddField('Number of People Calculation Method', 'People');
  Obj.AddField('Number of People', DesignLevel);
  Obj.AddField('People per Zone Area',  '');
  Obj.AddField('Zone Area per Person', '');
  Obj.AddField('Fraction Radiant', 0.3);
  Obj.AddField('User Specified Sensible Fraction', 'AUTOCALCULATE');
  Obj.AddField('Activity Level Schedule Name', 'ACTIVITY_SCH');
  Obj.AddField('Carbon Dioxide Generation Rate', '3.82E-8', '{m3/s-W}');
  Obj.AddField('Enable ASHRAE 55 Comfort Warnings', 'No');
  Obj.AddField('MRT Calculation', 'ZoneAveraged');
  Obj.AddField('Surface Name', '');
  Obj.AddField('Work Efficiency Schedule Name', 'WORK_EFF_SCH');
  if SameText(EPSettings.VersionOfEnergyPlus, '8.1') then
  begin
    Obj.AddField('Clothing Insulation Calculation Method', 'ClothingInsulationSchedule', '{ClothingInsulationSchedule | DynamicClothingModelASHRAE55 | CalculationMethodSchedule}');
    Obj.AddField('Clothing Insulation Calculation Method Schedule Name', '');
  end;
  Obj.AddField('Clothing Schedule Name', 'CLOTHING_SCH');
  Obj.AddField('Air Velocity Schedule Name', 'AIR_VELO_SCH');
  Obj.AddField('Thermal Comfort Report', 'FANGER');
  if not Assigned(Cost) then
  begin
    //put in generic cost structure for post processing
    Cost := T_EP_Economics.Create;
    Cost.Name := 'People:' + ZoneName;
    Cost.RefObjName := ZoneName;
    Cost.Costing := ecCostPerEach;
    Cost.CostType := etGeneral;
    Cost.CostValue := 1;
    //apply multiplier
    aZone := GetZone(ZoneName);
    dQuan := (DesignLevel * aZone.ZoneMultiplier);
    Cost.Quantity := dQuan;
  end;
  if Assigned(Cost) and EPSettings.Costs then Cost.ToIDF;
end;

{ T_EP_Lighting }

constructor T_EP_Lighting.Create(ExteriorLoads: Boolean);
begin
  FExteriorLoad := ExteriorLoads;
  ScheduleName := 'BLDG_LIGHT_SCH';
  SchFileColumn := -9999;
  SchFileRowSkip := -9999;
end;

procedure T_EP_Lighting.Finalize;
begin
  inherited;
end;

procedure T_EP_Lighting.ToIDF;
var
  Obj: TEnergyPlusObject;
  fracVisible: double;
  heatgain: double;
begin
  inherited;

  if HoursPerDay <> -9999 then
  begin
    //automatically create a very simple schedule
    Obj := IDF.AddObject('Schedule:Compact');
    ScheduleName := ZoneName + '_' + Name + '_Schedule';
    Obj.AddField('Name', ScheduleName);
    Obj.AddField('Schedule Type Limits Name', 'Fraction');
    Obj.AddField('Field 1', 'Through: 12/31');
    Obj.AddField('Field 2', 'For: AllDays');
    if HoursPerDay <= 0.0 then
    begin
      Obj.AddField('Field 3', 'Until: 24:00, 0.0');
    end
    else if HoursPerDay < 24 then
    begin
      Obj.AddField('Field 3', 'Until: ' + inttostr(HoursPerDay) + ':00, 1.0');
      Obj.AddField('Field 4', 'Until: 24:00, 0.0');
    end
    else if HoursPerDay >= 24 then
    begin
      Obj.AddField('Field 3', 'Until: 24:00, 1.0');
    end;
  end;

  if not FExteriorLoad then
  begin
    Obj := IDF.AddObject('Lights');
    Obj.AddField('Name', ZoneName + '_' + Name);
    Obj.AddField('Zone Name', ZoneName);
    if ((SchFileColumn <> -9999) and (SchFileRowSkip <> -9999)) then
      Obj.AddField('Schedule Name', ZoneName + '_' + ScheduleName)
    else
      Obj.AddField('Schedule Name', ScheduleName);
    obj.AddField('Design Level Calculation Method', 'LightingLevel');
    Obj.AddField('Design Level', DesignLevel, '{W}');
    obj.AddField('Watts per Zone Area', '', '{W/m2}');
    obj.AddField('Watts per Person', '' , '{W/person}');
    fracVisible := 0.2;
    heatgain := 1.0 - (fracReturn + fracRadiant + fracVisible);
    if heatgain >= 1.0 then fracReturn := 1 - (fracRadiant + fracVisible);
    Obj.AddField('Return Air Fraction', fracReturn);
    Obj.AddField('Fraction Radiant', fracRadiant);
    Obj.AddField('Fraction Visible', fracVisible);
    Obj.AddField('Fraction Replaceable', 1.0);
    Obj.AddField('End-Use Subcategory', EndUseSubcategory);
    obj.AddField('Return Air Fraction is Calculated from Plenum Temperature', 'No');
    //add schedule file
    if ((SchFileColumn <> -9999) or (SchFileRowSkip <> -9999)) then
    begin
      Obj := IDF.AddObject('Schedule:File');
      Obj.AddField('Name', ZoneName + '_' + ScheduleName);
      Obj.AddField('Schedule Type Limits Name', 'Fraction');
      Obj.AddField('File Name', ScheduleName + '.csv');
      Obj.AddField('Column Number', SchFileColumn);
      Obj.AddField('Rows to Skip at Top', SchFileRowSkip);
      Obj.AddField('Number of Hours of Data', '8760');
      Obj.AddField('Column Separator', 'Comma');
    end;
  end
  else //exterior loads
  begin
    Obj := IDF.AddObject('Exterior:Lights');
    Obj.AddField('Name', ZoneName + '_' + Name);
    if SameText(ScheduleName,'AstroClock') then
      Obj.AddField('Schedule Name', 'ALWAYS_ON')
    else
      Obj.AddField('Schedule Name', ScheduleName);
    Obj.AddField('Design Level', DesignLevel);
    if SameText(ScheduleName,'AstroClock') then
      Obj.AddField('Control Option', 'AstronomicalClock')
    else
      Obj.AddField('Control Option', 'ScheduleNameOnly');
    Obj.AddField('End-Use Subcategory', EndUseSubcategory)
  end;

  if not Assigned(Cost) then
  begin
    //put in generic cost structure for post processing
    Cost := T_EP_Economics.Create;
    Cost.Name := 'LIGHTING EQUIP:' + ZoneName;
    Cost.RefObjName := ZoneName;
    Cost.Costing := ecCostPerKilowatt;
    Cost.CostType := etLighting;
    Cost.CostValue := 1;
  end;

  if Assigned(Cost) and EPSettings.Costs then Cost.ToIDF;
end;



{ T_EP_SimpleRefrigeration }

procedure T_EP_SimpleRefrigeration.AddCost(CostPer: double);
begin
  Cost := T_EP_Economics.Create;
  Cost.Name := 'SIMPLE REFRIGERATION EQUIP:' + Name;
  Cost.Costing := ecCostPerEach;
  Cost.CostType := etGeneral;
  Cost.CostValue := CostPer * DesignLevel / 1000;
  Cost.Quantity := 1;
end;

procedure T_EP_SimpleRefrigeration.Finalize;
begin
  inherited;
end;

procedure T_EP_SimpleRefrigeration.ToIDF;
var
  Obj: TEnergyPlusObject;
begin
  inherited;

  Obj := IDF.AddObject('Exterior:FuelEquipment');
  Obj.AddField('Name', Name);
  Obj.AddField('Fuel Type', 'Electricity');
  if ScheduleName = '' then
    Obj.AddField('Schedule Name', 'ALWAYS_ON')
  else
    Obj.AddField('Schedule Name', ScheduleName);
  Obj.AddField('Design Level', DesignLevel, '{W}');
  Obj.AddField('End-Use Subcategory', EndUseSubcategory);

  if Assigned(Cost) and EPSettings.Costs then Cost.ToIDF;

end;

constructor T_EP_ZoneGains.Create;
begin
  inherited;
  FEquipmentList := T_EP_EquipmentList.Create;
end;

destructor T_EP_ZoneGains.Destroy;
begin
  FEquipmentList.Free;
  inherited;
end;


end.
