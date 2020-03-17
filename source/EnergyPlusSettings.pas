////////////////////////////////////////////////////////////////////////////////
//                                                                            //
// Copyright (c) 2008-2020 Alliance for Sustainable Energy.                   //
// All rights reserved.                                                       //
//                                                                            // 
////////////////////////////////////////////////////////////////////////////////

unit EnergyPlusSettings;
// includes Zone Equipment and Process Loads

// may be able to get rid of Initialize on all classes here

interface

uses
  SysUtils,
  Contnrs,
  Globals,
  EnergyPlusPPErrorMessages,
  EnergyPlusCore;

type
  T_EP_Settings = class(TEnergyPlusGroup)
  public
    BuildingName: string;
    TimeStepInHour: integer;
    TimeStepsInAveragingWindow: integer;
    RunStartMonth: integer;
    RunStartDay: integer;
    RunStopMonth: integer;
    RunStopDay: integer;
    MaxNumWarmupDays: Integer;
    LoadConvergeTolerance: double;
    TempConvergeTolerance: double;
    UpdateShadowInterval: integer;
    MinSystemTimeStep: integer;
    MaxHVACIterations: integer;
    BenchmarkHeader: boolean;
    RunWeatherFile: boolean;
    DoPlantSizingCalc: boolean;
    SQLiteOutput: boolean;
    Costs: boolean;
    BuildingTerrain: string;
    SolarDistribution: string;
    Rotation: double; //this is written by the building object
    VersionOfEnergyPlus: string;
    SizingFactor: double;
    procedure ToIDF; override;
    procedure Finalize; override;
    constructor Create; reintroduce;
  end;
var
  EPSettings: T_EP_Settings;

implementation

uses GlobalFuncs, StringFileUtilities, EnergyPlusObject;

procedure T_EP_Settings.Finalize;
begin
  inherited;
end;

constructor T_EP_Settings.Create;
begin
  Settings.Add(Self);
end;

procedure T_EP_Settings.ToIDF;
var
  Obj: TEnergyPlusObject;
  sizingWindow: Integer;
begin
  Finalize;
  //version
  Obj := IDF.AddObject('Version');
  if SameText(EPSettings.VersionOfEnergyPlus , '8.0') then
    Obj.AddField('Version', '8.0.0')
  else if SameText(EPSettings.VersionOfEnergyPlus, '8.1') then
    Obj.AddField('Version', '8.1.0')
  else
  begin
     Obj.AddField('Version', '');
     T_EP_PPErrorMessage.AddErrorMessage(esFatal, 'Attempted to used unsupported version of EnergyPlus "' + EPSettings.VersionOfEnergyPlus + '"');
  end;
  //timestep
  Obj := IDF.AddObject('Timestep');
  Obj.AddField('Number of Timesteps per Hour', IntToStr(TimeStepInHour));
  //simulation control
  Obj := IDF.AddObject('SimulationControl');
  Obj.AddField('Do Zone Sizing Calculation', 'Yes');
  Obj.AddField('Do System Sizing Calculation', 'Yes');
  if not DoPlantSizingCalc then
    Obj.AddField('Do Plant Sizing Calculation', 'No')
  else
    Obj.AddField('Do Plant Sizing Calculation', 'Yes');
  Obj.AddField('Run Simulation for Sizing Periods', 'No');
  if RunWeatherFile then
    Obj.AddField('Run Simulation for Weather File Run Periods', 'Yes')
  else
    Obj.AddField('Run Simulation for Weather File Run Periods', 'No');
  //run period
  Obj := IDF.AddObject('RunPeriod');
  Obj.AddField('Name', '');
  Obj.AddField('Begin Month', IntToStr(RunStartMonth));
  Obj.AddField('Begin Day of Month', IntToStr(RunStartDay));
  Obj.AddField('End Month', IntToStr(RunStopMonth));
  Obj.AddField('End Day of Month', IntToStr(RunStopDay));
  Obj.AddField('Day of Week for Start Day', 'Sunday');
  Obj.AddField('Use Weather File Holidays and Special Days', 'No');
  Obj.AddField('Use Weather File Daylight Saving Period', 'No');
  Obj.AddField('Apply Weekend Holiday Rule', 'No');
  Obj.AddField('Use Weather File Rain Indicators', 'Yes');
  Obj.AddField('Use Weather File Snow Indicators', 'Yes');
  Obj.AddField('Number of Times Runperiod to be Done', 1.0);
  Obj.AddField('Increment Day of Week on Repeat', 'Yes');
  Obj.AddField('Start Year', '2012');
  //inside surface convection algorithm
  Obj := IDF.AddObject('SurfaceConvectionAlgorithm:Inside');
  Obj.AddField('Algorithm', 'TARP');
  //outside surface convection algorithm
  Obj := IDF.AddObject('SurfaceConvectionAlgorithm:Outside');
  Obj.AddField('Algorithm', 'DOE-2');
  //heat balance algorithm
  Obj := IDF.AddObject('HeatBalanceAlgorithm');
  Obj.AddField('Solution Algorithm', 'ConductionTransferFunction');
  Obj.AddField('Surface Temperature Upper Limit', 200.0 );
  //zone air heat balance algorithm
  Obj := IDF.AddObject('ZoneAirHeatBalanceAlgorithm');
  Obj.AddField('Solution Algorithm', 'AnalyticalSolution');
  //sizing
  Obj := IDF.AddObject('Sizing:Parameters');
  Obj.AddField('Heating Sizing Factor', FloatToStr(SizingFactor));
  Obj.AddField('Cooling Sizing Factor', FloatToStr(SizingFactor));
  if TimeStepsInAveragingWindow <> -9999 then
    Obj.AddField('Time Steps in Averaging Window', IntToStr(TimeStepsInAveragingWindow))
  else
  begin
    case TimeStepInHour of
      1: sizingWindow := 1;
      2: sizingWindow := 2;
      3: sizingWindow := 3;
      4: sizingWindow := 4;
      6: sizingWindow := 6;
      12: sizingWindow := 12;
      15: sizingWindow := 15;
      30: sizingWindow := 30;
      60: sizingWindow := 60;
    else
      sizingWindow := 3;
    end;
    Obj.AddField('Time Steps in Averaging Window', inttostr(sizingWindow));
  end;
  //convergence limits
  Obj := IDF.AddObject('ConvergenceLimits');
  Obj.AddField('Minimum System Timestep', MinSystemTimeStep);
  Obj.AddField('Maximum HVAC Iterations', MaxHVACIterations);
  //shadow calculations
  Obj := IDF.AddObject('ShadowCalculation');
  Obj.AddField('Calculation Method', 'AverageOverDaysInFrequency', '{ AverageOverDaysInFrequency | TimestepFrequency }');
  Obj.AddField('Calculation Frequency', UpdateShadowInterval);
  obj.AddField('Maximum Figures in Shadow Overlap Calculations',  15000 );
  //geometry rules
  Obj := IDF.AddObject('GlobalGeometryRules');
  Obj.AddField('Starting Vertex Position', 'UpperLeftCorner');
  Obj.AddField('Vertex Entry Direction', 'Counterclockwise');
  Obj.AddField('Coordinate System', 'Relative');
  Obj.AddField('Daylighting Reference Point Coordinate System', 'Relative');
  //sqlite output
  if SQLiteOutput then
  begin
    Obj := IDF.AddObject('Output:SQLite');
    Obj.AddField('', 'SimpleAndTabular');
  end;
  //build name
  Obj := IDF.AddObject('Building');
  //clean up building name, just in case
  if BuildingName = '' then
    Obj.AddField('Name', 'AutoBuilt Model')
  else
  begin
    BuildingName := CleanStringFilename(BuildingName);
    Obj.AddField('Name', BuildingName);
  end;
  Obj.AddField('North Axis', Rotation);
  Obj.AddField('Terrain', BuildingTerrain);
  Obj.AddField('Loads Convergence Tolerance Value', LoadConvergeTolerance);
  Obj.AddField('Temperature Convergence Tolerance Value', TempConvergeTolerance);
  Obj.AddField('Solar Distribution', SolarDistribution);     // going to need to control this for some zone shapes...
  Obj.AddField('Maximum Number of Warmup Days', MaxNumWarmupDays);
  Obj.AddField('Minimum Number of Warmup Days', '6');
end;

end.
