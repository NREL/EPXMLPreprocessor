////////////////////////////////////////////////////////////////////////////////
//                                                                            //
// Copyright (c) 2008-2020 Alliance for Sustainable Energy.                   //
// All rights reserved.                                                       //
//                                                                            // 
////////////////////////////////////////////////////////////////////////////////

unit EnergyPlusElectricLoadCenter;

interface

uses
  Contnrs,
  EnergyPlusCore,
  EnergyPlusEconomics,
  EnergyPlusSystems,
  EnergyPlusZones,
  EnergyPlusSystemComponents,
  EnergyPlusSettings,
  math,
  Classes,
  SysUtils;


type

  T_EP_SimplePVAreaType = record
    PVArea: double;
    isRoof: boolean;
  end;

  T_EP_SimplePV_Params = record
    PVMode: string;
    PVAreaFraction: double;
    PVInstalledCap: double;
    PVEfficiency: double;
    PVInverterEff: double;
    IntegrationMode: string;
    OrientationAngle: double;
    TiltAngle: double;
    ExistingSurfaces: TStringList;
  end;

  T_EP_PVs = class(TEnergyPlusGroup)
  public
    Area : double;
    AvailSchedule: string;
    RatedOutput: double;
    Cost: T_EP_Economics;
    SurfaceName: string;
    ActiveAreaFraction: double;
    InverterEff: double;
    IntegrationMode: string;
    CellEff: double;
    procedure ToIDF; override;
    constructor Create; reintroduce;
    procedure Finalize; override;
  end;

  T_EP_ElectricLoadCenter_Params = record
    HasSimplePV: boolean;
    SimplePV_Params: T_EP_SimplePV_Params;
  end;

  T_EP_ElectricLoadCenter = class(TEnergyPlusGroup)
  protected
    function AreaValidPVSurface(Obj: TEnergyPlusGroup; params: T_EP_SimplePV_Params): T_EP_SimplePVAreaType;
  public
    Generators: TObjectList;
    ControlMode: string;
    ElectricalBussType : string;
    procedure DesignElectricLoadCenter(params: T_EP_ElectricLoadCenter_Params);
    procedure DesignSimplePV(params: T_EP_SimplePV_Params);
    procedure ToIDF; override;
    constructor Create; reintroduce;
    procedure Finalize; override;
  end;


  T_EP_MicroCHP = class(TSystemComponent)
  protected
 //   SystemValue: T_EP_System; // System refers to one where this component is on the supply side
    DemandSystemValue: T_EP_System;
    procedure SetDemandSystem(SystemParameter: T_EP_System);
    procedure SetSystem(SystemParameter: T_EP_System); override;
  public
    DemandSidePosition: Boolean;
    RatedOutput: double;
    RatedThermElecRatio: double;
    CombustionType : string;
    AvailSchedule: string;
    A42inputsetKey: string;
    ControlMode: string;
    FuelType : string;
    ZoneObj: T_EP_Zone; // these can dump heat to a zone
    ZoneName: string;
    //hot water component (in remote loop
    property DemandSystem: T_EP_System read DemandSystemValue write SetDemandSystem;
    property System: T_EP_System read SystemValue write SetSystem; // System is really the Supply Side System
    procedure Finalize; override;
    procedure ToIDF; override;
    constructor Create; reintroduce;
  end;
  
var
  ElectricLoadCenter: T_EP_ElectricLoadCenter;
  
implementation

uses Globals, GlobalFuncs, StrUtils, DateUtils, EnergyPlusSurfaces, VectorMath,
  EnergyPlusPPErrorMessages, EnergyPlusObject;

{ T_EP_PVs }

constructor T_EP_PVs.Create;
begin
  inherited;
  Cost := T_EP_Economics.Create;
  RatedOutput := 100000;
  AvailSchedule := 'ALWAYS_ON';
  ElectricLoadCenter.Generators.Add(self);
end;

procedure T_EP_PVs.Finalize;
begin
  inherited;
end;

procedure T_EP_PVs.ToIDF;
var
  Obj: TEnergyPlusObject;
  performanceObj: TEnergyPlusObject;
  performanceName: string;
  dQuan: double;
begin
  inherited;
  performanceName := Name + ':Performance';

  Obj := IDF.AddObject('Generator:Photovoltaic');
  Obj.AddField('Name', Name);
  Obj.AddField('Surface Name', SurfaceName);
  // TODO: DLM, this should be a parameter?
  Obj.AddField('Photovoltaic Performance Object Type', 'PhotovoltaicPerformance:Simple');
  Obj.AddField('Module Performance Name', performanceName);
  Obj.AddField('Heat Transfer Surface Integration Mode', IntegrationMode);
  Obj.AddField('Number of Modules in Parallel', 1);   // this is only for Simple PV
  Obj.AddField('Number of Modules in Series', 1);   // this is only for Simple PV

  performanceObj := IDF.AddObject('PhotovoltaicPerformance:Simple');
  performanceObj.AddField('Name', performanceName);
  performanceObj.AddField('Fraction of Surface Area with Active Solar Cells', ActiveAreaFraction);
  performanceObj.AddField('Conversion Efficiency Input Mode', 'Fixed');
  performanceObj.AddField('Value for Cell Efficiency If Fixed', CellEff);
  performanceObj.AddField('Efficiency Schedule Name', '');

  //Cost.CostValue
  Cost.Name := Name;
  Cost.RefObjName := Name;
  Cost.CostType := etGeneral;
  Cost.Costing := ecCostPerEach;
  Cost.CostValue := 1;
  //get area of surface

  dQuan := Area;
  dQuan := 1 * dQuan * ActiveAreaFraction * CellEff;
  //[Quantity kW] = [Solar kW / m2] * [Area m2] * [Fraction non-dim] * [CellEfficiency non-dim]
  Cost.Quantity := dQuan;
  if EPSettings.Costs then Cost.ToIDF;
end;


{ T_EP_MicroCHP }

constructor T_EP_MicroCHP.Create;
begin
  inherited;

  AvailSchedule := 'ALWAYS_ON';
  ElectricLoadCenter.Generators.Add(self);
  DemandSidePosition := true;
  ComponentType := 'Generator:MicroCHP';
end;

Procedure T_EP_MicroCHP.Finalize ;
begin

end;

procedure T_EP_MicroCHP.SetSystem(SystemParameter: T_EP_System);
begin
  inherited;
  If Assigned(SystemParameter) then
  begin
    SystemValue := SystemParameter;
    ControlType := 'Passive';
    SupplyInletNode := Name + ' Water Inlet Node';
    SupplyOutletNode := Name + ' Water Outlet Node';
  end;
end;

procedure T_EP_MicroCHP.SetDemandSystem(SystemParameter: T_EP_System);
begin
  if Assigned(SystemParameter) then
  begin

    DemandSystemValue := SystemParameter;
    DemandInletNode := Name + ' Water Inlet Node';
    DemandOutletNode := Name + ' Water Outlet Node';
    DemandControlType :=  'Active';
  end;

end;

procedure T_EP_MicroCHP.ToIDF;

var
  obj: TEnergyPlusObject;
begin
  inherited;

  Obj :=  IDF.AddObject('Generator:MicroCHP');
  obj.AddField('Name', Name ) ;
  obj.AddField('Performance Parameters Name',A42inputsetKey);
  obj.AddField('Zone Name', ZoneName);
  if DemandSidePosition then
  begin
    obj.AddField('Cooling Water Inlet Node Name', DemandInletNode);
    obj.AddField('Cooling Water Outlet Node Name',  DemandOutletNode );
  end
  else
  begin
    obj.AddField('Cooling Water Inlet Node Name', SupplyInletNode);
    obj.AddField('Cooling Water Outlet Node Name',  SupplyOutletNode );
  end;
  obj.AddField('Air Inlet Node Name', Name + ' Air Inlet Node Name');
  obj.AddField('Air Outlet Node Name', '');
  obj.AddField('Generator Fuel Supply Name', FuelType );
  obj.AddField('Availability Schedule Name', AvailSchedule );

  if A42inputsetKey = 'SENERTECH5_5KW' then
  begin
    obj := IDF.AddObject('Generator:MicroCHP:NonNormalizedParameters');
    obj.AddField('Name', A42inputsetKey );
    obj.AddField('Maximum Electric Power', 5500.0 );
    obj.AddField('Minimum Electric Power', 0.0 );
    obj.AddField('Minimum Cooling Water Flow Rate', 0.0);
    obj.AddField('Maximum Cooling Water Temperature', 80.0);
    Obj.AddField('Electrical Efficiency Curve Name', 'SenerTechElEff');
    obj.AddField('Thermal Efficiency Curve Name', 'SenerTechThermEff');
    if DemandSidePosition then
    begin
      obj.AddField('Cooling Water Flow Rate Mode', 'INTERNAL CONTROL');
    end
    else
    begin
      obj.AddField('Cooling Water Flow Rate Mode', 'PLANT CONTROL');
    end;
    obj.AddField('Cooling Water Flow Rate Curve Name', 'SenerTechCoolWaterflow');
    obj.AddField('Air Flow Rate Curve Name', 'SenerTechAirFlow');
    obj.AddField('Maximum Net Electrical Power Rate of Change', 1.0E09);
    obj.AddField('Maximum Fuel Flow Rate of Change', 1.0E09);
    obj.AddField('Heat Exchanger U-Factor Times Area Value', 741.0);
    obj.AddField('Skin Loss U-Factor Times Area Value', 13.7);
    obj.AddField('Skin Loss Radiative Fraction', 0.5);
    obj.AddField('Aggregated Thermal Mass of Energy Conversion Portion of Generator', 63605.6);
    obj.AddField('Aggregated Thermal Mass of Heat Recovery Portion of Generator', 1000.7);
    obj.AddField('Standby Power', 0.0);
    obj.AddField('Warm Up Mode', 'TimeDelay');
    Obj.AddField('Warm Up Fuel Flow Rate Coefficient', '');
    obj.AddField('Nominal Engine Operating Temperature', '');
    obj.AddField('Warm Up Power Coefficient', '');
    obj.AddField('Warm Up Fuel Flow Rate Limit Ratio', '');
    obj.AddField('Warm up Delay Time', 60.0);
    obj.AddField('Cool Down Power', 0.0);
    obj.AddField('Cool Down Delay Time', 60.0);
    obj.AddField('Restart Mode', 'OptionalCoolDown');


    obj := IDF.AddObject('Curve:Quadratic');
    Obj.AddField('Name', 'SenerTechAirFlow');
    obj.AddField('Coefficient1 Constant', 15.0E-06);
    obj.AddField('Coefficient2 x', 2.0);
    obj.AddField('Coefficient3 x**2', -10.0E3);
    obj.AddField('Minimum Value of x', 0.0);
    obj.AddField('Maximum Value of x', 1.0E12);

    obj := IDF.AddObject('Curve:Biquadratic');
    obj.AddField('Name', 'SenerTechCoolWaterflow');
    obj.AddField('Coefficient1 Constant', 0.4 );
    obj.AddField('Coefficient2 x', 0.0 );
    obj.AddField('Coefficient3 x**2', 0.0 );
    obj.AddField('Coefficient4 y ', 0.0 );
    obj.AddField('Coefficient5 y**2  ', 0.0 );
    obj.AddField('Coefficient6 x*y ', 0.0 );
    obj.AddField('Minimum Value of x  ', 0.0 );
    obj.AddField('Maximum Value of x', '1.0E12' );
    obj.AddField('Minimum Value of y ', 0.0 );
    obj.AddField('Maximum Value of y', '1.0E12' );

    obj := IDF.AddObject('Curve:Triquadratic');
    obj.AddField('Name', 'SenerTechThermEff') ;
    obj.AddField('Coefficient1 Constant', 0.66);
    obj.AddField('Coefficient2 x**2', 0.0 );
    obj.AddField('Coefficient3 x   ' , 0.0 );
    obj.AddField('Coefficient4 y**2 ' , 0.0 );
    obj.AddField('Coefficient5 y  ' , 0.0 );
    obj.AddField('Coefficient6 z**2  ' , 0.0 );
    obj.AddField('Coefficient7 z    ' , 0.0 );
    obj.AddField('Coefficient8 x**2*y**2 ' , 0.0 );
    obj.AddField('Coefficient9 x*y  ' , 0.0 );
    obj.AddField('Coefficient10 x*y**2  ' , 0.0 );
    obj.AddField('Coefficient11 x**2*y ' , 0.0 );
    obj.AddField('Coefficient12 x**2*z**2 ' , 0.0 );
    obj.AddField('Coefficient13 x*z    ' , 0.0 );
    obj.AddField('Coefficient14 x*z**2   ' , 0.0 );
    obj.AddField('Coefficient15 x**2*z  ' , 0.0 );
    obj.AddField('Coefficient16 y**2*z**2  ' , 0.0 );
    obj.AddField('Coefficient17 y*z     ' , 0.0 );
    obj.AddField('Coefficient18 y*z**2   ' , 0.0 );
    obj.AddField('Coefficient19 y**2*z  ' , 0.0 );
    obj.AddField('Coefficient20 x**2*y**2*z**2  ' , 0.0 );
    obj.AddField('Coefficient21 x**2*y**2*z  ' , 0.0 );
    obj.AddField('Coefficient22 x**2*y*z**2 ' , 0.0 );
    obj.AddField('Coefficient23 x*y**2*z**2 ' , 0.0 );
    obj.AddField('Coefficient24 x**2*y*z ' , 0.0 );
    obj.AddField('Coefficient25 x*y**2*z  ' , 0.0 );
    obj.AddField('Coefficient26 x*y*z**2 ' , 0.0 );
    obj.AddField('Coefficient27 x*y*z   ' , 0.0 );
    obj.AddField('Minimum Value of x'  , 0.0 );
    obj.AddField('Maximum Value of x   ', 1.0E09 );
    obj.AddField('Minimum Value of y   ' , 0.0 );
    obj.AddField('Maximum Value of y  ', 1.0E09 );
    obj.AddField('Minimum Value of z  ' , 0.0 );
    obj.AddField('Maximum Value of z  ', 1.0E09 );

    obj := IDF.AddObject('Curve:Triquadratic');
    obj.AddField('Name', 'SenerTechElEff') ;
    obj.AddField('Coefficient1 Constant', 0.27);
    obj.AddField('Coefficient2 x**2', 0.0 );
    obj.AddField('Coefficient3 x   ' , 0.0 );
    obj.AddField('Coefficient4 y**2 ' , 0.0 );
    obj.AddField('Coefficient5 y  ' , 0.0 );
    obj.AddField('Coefficient6 z**2  ' , 0.0 );
    obj.AddField('Coefficient7 z    ' , 0.0 );
    obj.AddField('Coefficient8 x**2*y**2 ' , 0.0 );
    obj.AddField('Coefficient9 x*y  ' , 0.0 );
    obj.AddField('Coefficient10 x*y**2  ' , 0.0 );
    obj.AddField('Coefficient11 x**2*y ' , 0.0 );
    obj.AddField('Coefficient12 x**2*z**2 ' , 0.0 );
    obj.AddField('Coefficient13 x*z    ' , 0.0 );
    obj.AddField('Coefficient14 x*z**2   ' , 0.0 );
    obj.AddField('Coefficient15 x**2*z  ' , 0.0 );
    obj.AddField('Coefficient16 y**2*z**2  ' , 0.0 );
    obj.AddField('Coefficient17 y*z     ' , 0.0 );
    obj.AddField('Coefficient18 y*z**2   ' , 0.0 );
    obj.AddField('Coefficient19 y**2*z  ' , 0.0 );
    obj.AddField('Coefficient20 x**2*y**2*z**2  ' , 0.0 );
    obj.AddField('Coefficient21 x**2*y**2*z  ' , 0.0 );
    obj.AddField('Coefficient22 x**2*y*z**2 ' , 0.0 );
    obj.AddField('Coefficient23 x*y**2*z**2 ' , 0.0 );
    obj.AddField('Coefficient24 x**2*y*z ' , 0.0 );
    obj.AddField('Coefficient25 x*y**2*z  ' , 0.0 );
    obj.AddField('Coefficient26 x*y*z**2 ' , 0.0 );
    obj.AddField('Coefficient27 x*y*z   ' , 0.0 );
    obj.AddField('Minimum Value of x'  , 0.0 );
    obj.AddField('Maximum Value of x   ', 1.0E09 );
    obj.AddField('Minimum Value of y   ' , 0.0 );
    obj.AddField('Maximum Value of y  ', 1.0E09 );
    obj.AddField('Minimum Value of z  ' , 0.0 );
    obj.AddField('Maximum Value of z  ', 1.0E09 );

  end; // if SenerTech5_5kW

  if FuelType = 'NATURALGAS' then
  begin
    obj := IDF.AddObject('Generator:FuelSupply');
    obj.AddField('Name', FuelType);
    obj.AddField('Fuel Temperature Modeling Mode', 'TEMPERATURE FROM AIR NODE');
    obj.AddField('Fuel Temperature Reference Node Name', Name + ' Air Inlet Node Name');
    obj.AddField('Fuel Temperature Schedule Name', '');
    obj.AddField('Compressor Power Function of Fuel Rate Curve Name', 'NullCubic');
    obj.AddField('Compressor Heat Loss Factor', 1.0);
    obj.AddField('Fuel Type', 'GaseousConstituents');
    obj.AddField('Liquid Generic Fuel Lower Heating Value', '');
    obj.Addfield('Liquid Generic Fuel Higher Heating Value', '');
    obj.AddField('Liquid Generic Fuel Molecular Weight', '');
    obj.AddField('Liquid Generic Fuel CO2 Emission Factor', '');
    obj.AddField('Number of Constituents in Gaseous Constituent Fuel Supply', 8);
    //. these values are from Union Gas's web site.  
    obj.AddField('Constituent 1 Name', 'Methane');
    obj.AddField('Constituent 1 Molar Fraction', 0.949);
    obj.AddField('Constituent 2 Name', 'CarbonDioxide');
    obj.AddField('Constituent 2 Molar Fraction', 0.007);
    obj.AddField('Constituent 3 Name', 'Nitrogen');
    obj.AddField('Constituent 3 Molar Fraction', 0.016);
    obj.AddField('Constituent 4 Name', 'Ethane');
    obj.AddField('Constituent 4 Molar Fraction', 0.025);
    obj.AddField('Constituent 5 Name', 'Propane');
    obj.AddField('Constituent 5 Molar Fraction', 0.002);
    obj.AddField('Constituent 6 Name', 'Butane');
    obj.AddField('Constituent 6 Molar Fraction', 0.0006);
    obj.AddField('Constituent 7 Name', 'Pentane');
    obj.AddField('Constituent 7 Molar Fraction', 0.0002);
    obj.AddField('Constituent 8 Name', 'Oxygen');
    obj.AddField('Constituent 8 Molar Fraction', 0.0002);

    obj := IDF.ADdObject('Curve:Cubic'); //, !curve = C1 + C2*x + C3*x**2 + C4*x**3
    obj.AddField('Name', 'NullCubic');
    obj.AddField('Coefficient1 Constant', 0.0 );
    obj.AddField('Coefficient2 x', 0.0 );
    obj.AddField('Coefficient3 x**2 ', 0.0 );
    obj.AddField('Coefficient4 x**3 ', 0.0 );
    obj.AddField('Minimum Value of x ', 0.0 );
    obj.AddField('Maximum Value of x', 0.0 );
    
  end;


   SuppressToIDF := true; // don't write it out again!

end;

{ T_EP_ElectricLoadCenter }

constructor T_EP_ElectricLoadCenter.Create;
begin
  inherited;
  Generators := TObjectList.Create;
  ControlMode :=  'Baseload';
  ElectricalBussType := 'AlternatingCurrent';
end;

// Design all the components for the electric load center
// TODO: I think ideally the wall would lay out all components on it (such as windows, skylights, PV, etc)
// TODO: this way the wall can make things pretty and complain when it is "full"
procedure T_EP_ElectricLoadCenter.DesignElectricLoadCenter(params: T_EP_ElectricLoadCenter_Params);
var
  iGen: integer;

begin
  // if hasWind then DesignWind, ...., etc

  if params.hasSimplePV then
    DesignSimplePV(params.SimplePV_Params);

  //need to set elect center controlMode based on control mode of generators
  if Assigned(Generators) then
    begin
    for iGen := 0 to Generators.Count - 1 do
      begin
        if (Generators[iGen] is T_EP_PVs) then
        begin
          ElectricalBussType := 'DirectCurrentWithInverter';

        end;

        if (Generators[iGen] is T_EP_MicroCHP) then
        begin
          If SameText(T_EP_MicroCHP(Generators[iGen]).ControlMode, 'BaseElectrical') then begin
            ControlMode := 'Baseload';
          end;
          If SameText(T_EP_MicroCHP(Generators[iGen]).ControlMode, 'ElectricalFollowing') then begin
            ControlMode := 'TrackElectrical';

          end;
          IF SameText(T_EP_MicroCHP(Generators[iGen]).ControlMode, 'ThermalLoadFollowing') then begin
            ControlMode := 'FollowThermal';
          end;
          IF SameText(T_EP_MIcroCHP(Generators[iGen]).ControlMode, 'ThermalLoadFollowElectricalLimting') then begin
            ControlMode := 'FollowThermalLimitElectrical' ;
          end;
          
        end;

    end; // for

  end; // assigned generators

end;

// Design all the simple PV components
// Tilt and orientation apply only to PV on roof surfaces
// Flat PV is applied to all other surfaces 
procedure T_EP_ElectricLoadCenter.DesignSimplePV(params: T_EP_SimplePV_Params);
var
  aShading: T_EP_AttachedShading;
  aSurf: T_EP_Surface;
  aZone: T_EP_Zone;
  aDetachedShading: T_EP_DetachedShading;
  aPV: T_EP_PVs;
  zoneOrigin: T_EP_Vector;
  areaType: T_EP_SimplePVAreaType;
  newName: string;
  iExternal, iShade, iSurf, iZone: Integer;
  pvArea, roofArea, pvAreaFraction, actualAreaFraction, actualTilt, writeAreaFraction, writeArea: double;
  isTilted : boolean;
  iExistingSurface: Integer;
  bExistingSurfaceFound: Boolean;
  sExistingSurfacePVName: string;
  iGen: Integer;
const
  MaxPVAreaFraction: double = 0.99;
begin

  zoneOrigin := T_EP_Vector.Create();

  // loop over all surfaces and create surfaces to attach pv to
  // compute available area and compute requested area
  if params.PVInstalledCap <> 0 then
  begin
    //find all the roof areas for PV
    // DLM: roofArea bad name, not just roof
    roofArea := 0;
    for iZone := 0 to Zones.Count - 1 do
    begin
      aZone := T_EP_Zone(Zones[iZone]);
      for iSurf := 0 to aZone.Surfaces.Count - 1 do
      begin
        aSurf := T_EP_Surface(aZone.Surfaces[iSurf]);
        areaType := AreaValidPVSurface(aSurf, params);
        roofArea := roofArea + areaType.PVArea * aZone.ZoneMultiplier;

        for iShade := 0 to aSurf.Shading.Count - 1 do
        begin
          areaType := AreaValidPVSurface(TEnergyPlusGroup(aSurf.Shading[iShade]), params);
          roofArea := roofArea + areaType.PVArea * aZone.ZoneMultiplier;
        end
      end;
    end;

    //area needed
    pvArea := params.PVInstalledCap / params.PVEfficiency;
    if pvArea > MaxPVAreaFraction*roofArea then
    begin
      T_EP_PPErrorMessage.AddErrorMessage(esSevere, 'The PV capacity requested was too large to ' +
          'install only on the roof');
      pvAreaFraction := MaxPVAreaFraction;
    end
    else
      pvAreaFraction := pvArea / roofArea;

  end
  else
  begin
    pvAreaFraction := min(params.PVAreaFraction, MaxPVAreaFraction);
  end;

  // apply PV to external surfaces first because pv added in zones will result in
  // creation of external surfaces, want to avoid duplicate pv objects
  for iExternal := 0 to ExternalSurfaces.Count-1 do
  begin
    aDetachedShading := T_EP_DetachedShading(ExternalSurfaces[iExternal]);
    actualTilt := VertsTilt(aDetachedShading.Verts);
    isTilted := ((actualTilt > 1) or (actualTilt < -1));
    areaType := AreaValidPVSurface(TEnergyPlusGroup(aDetachedShading), params);
    if (areaType.PVArea > 0) then
    begin
      actualAreaFraction := areaType.PVArea*(pvAreaFraction/AreaPolygon(aDetachedShading.Verts));
      if (isTilted or SameText(params.PVMode, 'EXISTING SURFACES')) then
      begin
        newName := aDetachedShading.Name;
        writeAreaFraction := actualAreaFraction;
        writeArea := AreaType.PVArea;
      end
      else
      begin
        newName := AddPVSurface(aSurf.Verts, actualAreaFraction, zoneOrigin, params.OrientationAngle, params.TiltAngle);
        writeAreaFraction := 1.0; // this surface is created to be the right size
        writeArea := actualAreaFraction * AreaType.PVArea;
      end;

      aPV := T_EP_PVs.Create;
      aPV.Name := 'PV:' + newName;
      aPV.ActiveAreaFraction := writeAreaFraction;
      aPV.CellEff := params.PVEfficiency;
      aPV.InverterEff := params.PVInverterEff;
      aPV.IntegrationMode := params.IntegrationMode;
      aPV.SurfaceName := newName;
      aPV.Area := writeArea;
    end;
  end;

  // now apply PV to ares in the building
  for iZone := 0 to Zones.Count - 1 do
  begin
    aZone := T_EP_Zone(Zones[iZone]);
    zoneOrigin.i := aZone.XOrigin;
    zoneOrigin.j := aZone.YOrigin;
    zoneOrigin.k := aZone.ZOrigin;
    for iSurf := 0 to aZone.Surfaces.Count - 1 do
    begin
      aSurf := T_EP_Surface(aZone.Surfaces[iSurf]);
      actualTilt := VertsTilt(aSurf.Verts);
      isTilted := ((actualTilt > 1) or (actualTilt < -1));
      areaType := AreaValidPVSurface(aSurf, params);
      if (areaType.PVArea > 0) then
      begin
        if (areaType.isRoof) then
        begin
          // you can have tilts on a roof
          actualAreaFraction := areaType.PVArea*(pvAreaFraction/AreaPolygon(aSurf.Verts))*aZone.ZoneMultiplier; // less due to windows, etc
          if (isTilted or SameText(params.PVMode, 'EXISTING SURFACES')) then
          begin
            // use existing surface
            newName := aSurf.Name;
            writeAreaFraction := actualAreaFraction;
            writeArea := AreaType.PVArea;
          end
          else
          begin
            // create new surface with tilt and orientation and add pv
            newName := AddPVSurface(aSurf.Verts, actualAreaFraction, zoneOrigin, params.OrientationAngle, params.TiltAngle);
            writeAreaFraction := 1.0; // this surface is created to be the right size
            writeArea := actualAreaFraction * AreaType.PVArea;
          end;
        end
        else
        begin
          // apply flat to a new surface
          actualAreaFraction := areaType.PVArea*(pvAreaFraction/AreaPolygon(aSurf.Verts))*aZone.ZoneMultiplier; // less due to windows, etc

          // use existing surface
          newName := aSurf.Name;
          writeAreaFraction := actualAreaFraction;
          writeArea := AreaType.PVArea;
        end;

        aPV := T_EP_PVs.Create;
        aPV.Name := 'PV:' + newName;
        aPV.ActiveAreaFraction := writeAreaFraction;
        aPV.CellEff := params.PVEfficiency;
        aPV.InverterEff := params.PVInverterEff;
        aPV.IntegrationMode := params.IntegrationMode;
        aPV.SurfaceName := newName;
        aPV.Area := writeArea;
      end;

      for iShade := 0 to aSurf.Shading.Count - 1 do
      begin
        areaType := AreaValidPVSurface(TEnergyPlusGroup(aSurf.Shading[iShade]), params);
        if (areaType.PVArea > 0) then
        begin
          aShading := T_EP_AttachedShading(aSurf.Shading[iShade]);
          actualTilt := VertsTilt(aShading.Verts);
          isTilted := ((actualTilt > 1) or (actualTilt < -1));
          actualAreaFraction := areaType.PVArea*(pvAreaFraction/AreaPolygon(aShading.Verts))*aZone.ZoneMultiplier;
          if SameText(params.PVMode, 'EXISTING SURFACES') then
          begin
            newName := aShading.Name;
            writeAreaFraction := actualAreaFraction;
            writeArea := AreaType.PVArea;
          end
          else
          begin
            newName := AddPVSurface(aSurf.Verts, actualAreaFraction, zoneOrigin, params.OrientationAngle, params.TiltAngle);
            writeAreaFraction := 1.0; // this surface is created to be the right size
            writeArea := actualAreaFraction * AreaType.PVArea;
          end;

          aPV := T_EP_PVs.Create;
          aPV.Name := 'PV:' + newName;
          aPV.ActiveAreaFraction := writeAreaFraction;
          aPV.CellEff := params.PVEfficiency;
          aPV.InverterEff := params.PVInverterEff;
          aPV.IntegrationMode := params.IntegrationMode;
          aPV.SurfaceName := newName;
          aPV.Area := writeArea;
        end;
      end
    end;
  end;

  // check that we have made all of our existing surfaces
  // for example, we may have missed those in direct substitutions
  if SameText(params.PVMode, 'EXISTING SURFACES') then
  begin
    for iExistingSurface := 0 to params.ExistingSurfaces.Count-1 do
    begin
      sExistingSurfacePVName := 'PV:' + params.ExistingSurfaces[iExistingSurface];

      bExistingSurfaceFound := false;
      for iGen := 0 to Generators.Count - 1 do
      begin
        if (Generators[iGen] is T_EP_PVs) and
           SameText(sExistingSurfacePVName, T_EP_PVs(Generators[iGen]).Name) then
        begin
          bExistingSurfaceFound := true;
          break;
        end;
      end;

      if not bExistingSurfaceFound then
      begin
        T_EP_PPErrorMessage.AddErrorMessage(esWarning, 'Adding PV for existing surface not in xml: ' +
                                            sExistingSurfacePVName +
                                            '. This object will not be costed automatically.') ;

        aPV := T_EP_PVs.Create;
        aPV.Name := sExistingSurfacePVName;
        aPV.ActiveAreaFraction := params.PVAreaFraction;
        aPV.CellEff := params.PVEfficiency;
        aPV.InverterEff := params.PVInverterEff;
        aPV.IntegrationMode := params.IntegrationMode;
        aPV.SurfaceName := params.ExistingSurfaces[iExistingSurface];
        aPV.Area := 0;
      end;
    end;
  end;

  // free variables
  zoneOrigin.Free();
end;

// Return area of PV that can go on this object based on PVMode string
// DLM: it is horrible that we have to pass in obj as a TEnergyPlusGroup
function T_EP_ElectricLoadCenter.AreaValidPVSurface(Obj: TEnergyPlusGroup; params: T_EP_SimplePV_Params): T_EP_SimplePVAreaType;
var
  aSurf: T_EP_Surface;
  anAttachedShading: T_EP_AttachedShading;
  aDetachedShading: T_EP_DetachedShading;
  aSubSurf: T_EP_SubSurface;
  allOpaque: boolean;
  iSub: integer;
  bInstalled: Boolean;
  PVMode: string;
begin
  PVMode := params.PVMode;
  Result.PVArea := 0.0;
  Result.isRoof := false;
  allOpaque := AnsiContainsText(PVMode, 'ALL OPAQUE EXTERIOR');

  bInstalled := false;
  if (Obj is T_EP_Surface) then
  begin
    aSurf := T_EP_Surface(Obj);
    if (SameText(PVMode, 'Existing Surfaces') and (params.ExistingSurfaces.IndexOf(aSurf.Name)>=0)) then
    begin
      bInstalled := true;
      Result.PVArea := AreaPolygon(aSurf.Verts);
      Result.isRoof := true;
    end
    else if (((aSurf.SpecificType = sstRoof) or (aSurf.SpecificType = sstAtticRoof)) and
             (allOpaque or AnsiContainsText (PVMode, 'Roof'))) then
    begin
      bInstalled := true;
      Result.PVArea := AreaPolygon(aSurf.Verts);
      Result.isRoof := true;
    end
    else if (aSurf.SpecificType = sstExteriorWall) then
    begin
      if allOpaque
      or
      (((aSurf.AbsNrm = ntSouth) and AnsiContainsText(PVMode, 'SOUTH FACADE'))
      or
      ((aSurf.AbsNrm = ntEast) and AnsiContainsText(PVMode, 'EAST FACADE'))
      or
      ((aSurf.AbsNrm = ntWest) and AnsiContainsText(PVMode, 'WEST FACADE'))
      or
      ((aSurf.AbsNrm = ntNorth) and AnsiContainsText(PVMode, 'NORTH FACADE'))) then
      begin
        bInstalled := true;
        Result.PVArea := AreaPolygon(aSurf.Verts);
        Result.isRoof := false;
      end;
    end;

    if bInstalled then
    begin
      // remove window/tdd/skylight/door area from available area
      for iSub := 0 to aSurf.SubSurfaces.Count - 1 do
      begin
        aSubSurf := T_EP_SubSurface(aSurf.SubSurfaces[iSub]);
        Result.PVArea := Result.PVArea - AreaPolygon(aSubSurf.Verts);
      end;
    end; //if installed

  end
  else if (Obj is T_EP_AttachedShading) then
  begin
    anAttachedShading := T_EP_AttachedShading(Obj);

    if ((SameText(PVMode, 'EXISTING SURFACES') and (params.ExistingSurfaces.IndexOf(anAttachedShading.Name)>=0)) or
        (allOpaque or AnsiContainsText(PVMode, 'ATTACHED SHADES'))) then
    begin
      Result.PVArea := AreaPolygon(anAttachedShading.Verts);
      Result.isRoof := false;
    end;
  end
  else if (Obj is T_EP_DetachedShading) then
  begin
    aDetachedShading := T_EP_DetachedShading(Obj);

    if ((SameText(PVMode, 'EXISTING SURFACES') and (params.ExistingSurfaces.IndexOf(aDetachedShading.Name)>=0)) or
        (allOpaque or AnsiContainsText(PVMode, 'DETTACHED SHADES'))) then
    begin
      Result.PVArea := AreaPolygon(aDetachedShading.Verts);
      Result.isRoof := false;
    end;
  end;

  // DLM: assert Result.PVArea >= 0.0

end;


procedure T_EP_ElectricLoadCenter.ToIDF;
var
  Obj: TEnergyPlusObject;
  iGen: Integer;
  inverterEfficiency: double;
  inverterAvailSchedule: string;
begin
  inherited;

  if Assigned(Generators) then
    if Generators.Count > 0 then
    begin
      Obj := IDF.AddObject('ElectricLoadCenter:Distribution');
      Obj.AddField('Name', 'Main Load Center');
      Obj.AddField('Generator List Name', 'Generator List');
      Obj.AddField('Generator Operation Scheme Type', ControlMode);
      Obj.AddField('Demand Limit Scheme Purchased Electric Demand Limit', 0);
      Obj.AddField('Track Schedule Name Scheme Schedule Name', '');
      Obj.AddField('Track Meter Scheme Meter Name', '');
      Obj.AddField('Electrical Buss Type', ElectricalBussType );
      if  (ElectricalBussType = 'DirectCurrentWithInverter') then
      begin
        Obj.AddField('Inverter Object Name' , 'Main Load Center Inverter');
      end
      else
      begin
        Obj.AddField('Inverter Object Name' , '');
      end;

      Obj.AddField('Electrical Storage Object Name' , '');

      if Assigned(Generators) then
      begin
        inverterEfficiency := T_EP_PVs(Generators[0]).InverterEff;
        inverterAvailSchedule := T_EP_PVs(Generators[0]).AvailSchedule;

        Obj := IDF.AddObject('ElectricLoadCenter:Generators');
        Obj.AddField('Generator List Name', 'Generator List');
        for iGen := 0 to Generators.Count - 1 do
        begin
          if (Generators[iGen] is T_EP_PVs) then
          begin
            Obj.AddField('Name', T_EP_PVs(Generators[iGen]).Name);
            Obj.AddField('Generator Object Type', 'Generator:Photovoltaic');
            Obj.AddField('Generator Rated Electric Power Output', T_EP_PVs(Generators[iGen]).RatedOutput);
            Obj.AddField('Generator Availability Schedule Name', T_EP_PVs(Generators[iGen]).AvailSchedule);
            Obj.AddField('Generator Rated Thermal to Electrical Power Ratio', '' );
          end;
          
          if (Generators[iGen] is T_EP_MicroCHP) then
          begin
            obj.AddField('Name', T_EP_MicroCHP(Generators[iGen]).Name);
            Obj.AddField('Generator Object Type', 'Generator:MicroCHP');
            Obj.AddField('Generator Rated Electric Power Output', T_EP_MicroCHP(Generators[iGen]).RatedOutput);
            Obj.AddField('Generator Availability Schedule Name', T_EP_MicroCHP(Generators[iGen]).AvailSchedule);
            Obj.AddField('Generator Rated Thermal to Electrical Power Ratio',
                          T_EP_MicroCHP(Generators[iGen]).RatedThermElecRatio );
          end;
        end;

      end; //if

      // DLM: AvailSchedule and InverterEff should be parameters of ElectricLoadCenter and not T_EP_PVs

      if SameText(ElectricalBussType,'DirectCurrentWithInverter') then
      begin
        Obj := IDF.AddObject('ElectricLoadCenter:Inverter:Simple');
        Obj.AddField('Name', 'Main Load Center Inverter');
        Obj.AddField('Availability Schedule Name', inverterAvailSchedule);
        Obj.AddField('Zone Name', '');
        Obj.AddField('Radiative Fraction', '');
        Obj.AddField('Inverter Efficiency', inverterEfficiency);
      end;

      for iGen := 0 to Generators.Count - 1 do
      begin
        if (not (Generators[iGen] is THVACComponent)
            or (not THVACComponent(Generators[iGen]).SuppressToIDF)) then
        begin
          // check that efficiency and schedule agree with previously written values
          if not SameText(T_EP_PVs(Generators[0]).AvailSchedule, inverterAvailSchedule) then
              T_EP_PPErrorMessage.AddErrorMessage(esWarning, 'Inverter Availability Schedules Do Not Match: ' +
                                                  T_EP_PVs(Generators[0]).AvailSchedule + ' not equal to ' + inverterAvailSchedule ) ;

          if T_EP_PVs(Generators[0]).InverterEff <> inverterEfficiency then
              T_EP_PPErrorMessage.AddErrorMessage(esWarning, 'Inverter Efficiencies Do Not Match: ' +
                                                  FloatToStr(T_EP_PVs(Generators[0]).InverterEff) + ' not equal to ' + FloatToStr(inverterEfficiency) ) ;

          // write to idf
          TEnergyPlusGroup(Generators[iGen]).ToIDF;
        end;
      end;

    end;

end;

procedure T_EP_ElectricLoadCenter.Finalize;
begin
  inherited;

end;

end.
