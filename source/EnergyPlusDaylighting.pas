////////////////////////////////////////////////////////////////////////////////
//                                                                            //
// Copyright (c) 2008-2020 Alliance for Sustainable Energy.                   //
// All rights reserved.                                                       //
//                                                                            // 
////////////////////////////////////////////////////////////////////////////////

unit EnergyPlusDaylighting;

interface

uses
  SysUtils,
  Globals,
  EnergyPlusCore,
  VectorMath,
  EnergyPlusEconomics;

type
  T_EP_Daylighting = class(TEnergyPlusGroup)
  public
    ControlType: string;
    Cost: T_EP_Economics;
    MinimumInputPowerFraction: double;
    MinimumLightOutputFraction: double;
    NumberOfSteps: integer;
    RefPoint1: T_EP_Point;
    RefPoint1_PercControlled: double;
    RefPoint2: T_EP_Point;
    RefPoint2_PercControlled: double;
    Setpoint: double;
    ZoneName: string;
    constructor Create; reintroduce;
    procedure AddReferencePoint(RefNum: integer; X1, Y1: double; Z1: double = 0.762;
      PercentControlled: double = 1.0);
    procedure Finalize; override;
    procedure ToIDF; override;
  end;

implementation

uses EnergyPlusObject, EnergyPlusSettings;

constructor T_EP_Daylighting.Create;
begin
  inherited;
  Cost := T_EP_Economics.Create;
  RefPoint1_PercControlled := 1.0;
  RefPoint1_PercControlled := 0.0;
end;

{ T_EP_Daylighting }

procedure T_EP_Daylighting.AddReferencePoint(RefNum: integer; X1, Y1,
  Z1: double; PercentControlled: double);
begin
  if RefNum = 1 then
  begin
    RefPoint1 := T_EP_Point.Create;
    RefPoint1.X1 := X1;
    RefPoint1.Y1 := Y1;
    RefPoint1.Z1 := Z1;
    RefPoint1_PercControlled := PercentControlled / 100;
  end
  else if RefNum = 2 then
  begin
    RefPoint2 := T_EP_Point.Create;
    RefPoint2.X1 := X1;
    RefPoint2.Y1 := Y1;
    RefPoint2.Z1 := Z1;
    RefPoint2_PercControlled := PercentControlled / 100;
  end;

end;

procedure T_EP_Daylighting.Finalize;
begin
  inherited;
end;

procedure T_EP_Daylighting.ToIDF;
var
  Obj: TEnergyPlusObject;
  NumPoints: Integer;
begin
  inherited;

  if ControlType <> 'None' then
  begin
    Obj := IDF.AddObject('Daylighting:Controls');
    Obj.AddField('Zone Name', ZoneName);
    if assigned(RefPoint2) then
      NumPoints := 2
    else
      NumPoints := 1;
    Obj.AddField('Total Daylighting Reference Points', NumPoints);
    if assigned(RefPoint1) then
      Obj.AddField('X1, Y1, Z1',
        format('%.3f,  %.3f,  %.3f',
        [RefPoint1.X1, RefPoint1.Y1, RefPoint1.Z1]))
    else
      Obj.AddField('X1, Y1, Z1',
        format('%.3f,  %.3f,  %.3f',
        [0.0, 0.0, 0.0]));

    if assigned(RefPoint2) then
      Obj.AddField('X2, Y2, Z2',
        format('%.3f,  %.3f,  %.3f',
        [RefPoint2.X1, RefPoint2.Y1, RefPoint2.Z1]))
    else
      Obj.AddField('X2, Y2, Z2',
        format('%.3f,  %.3f,  %.3f',
        [0.0, 0.0, 0.0]));

    Obj.AddField('Fraction of Zone Controlled by First Reference Point', RefPoint1_PercControlled);
    Obj.AddField('Fraction of Zone Controlled by Second Reference Point', RefPoint2_PercControlled);

    Obj.AddField('Illuminance Setpoint at First Reference Point', Setpoint);
    Obj.AddField('Illuminance Setpoint at Second Reference Point', Setpoint);

    if SameText(ControlType, 'Continuous') then
      Obj.AddField('Lighting Control Type', 1, '', ControlType)
    else if SameText(ControlType, 'Stepped') then
      Obj.AddField('Lighting Control Type', 2, '', ControlType)
    else if SameText(ControlType, 'Continuous/Off') then
      Obj.AddField('Lighting Control Type', 3, '', ControlType)
    else
      Obj.AddField('Lighting Control Type', 'ERROR-IN-INPUT', '', ControlType);


    Obj.AddField('Glare Calculation Azimuth Angle of View Direction Clockwise from Zone y-Axis', 180);
    Obj.AddField('Maximum Allowable Discomfort Glare Index', 20);

    Obj.AddField('Minimum Input Power Fraction for Continuous Dimming Control',
      MinimumInputPowerFraction);
    Obj.AddField('Minimum Light Output Fraction for Continuous Dimming Control',
      MinimumLightOutputFraction);
    Obj.AddField('Number of Stepped Control Steps', NumberOfSteps);
    Obj.AddField('Probability Lighting will be Reset When Needed in Manual Stepped Control', 1.0);

    Cost.Costing := ecCostPerEach;
    Cost.CostType := etDaylighting;
    Cost.RefObjName := ZoneName;
    Cost.Name := 'Daylighting:' + ZoneName;
    Cost.CostValue := 1;
    Cost.Quantity := NumPoints;  //This will be overriden by energyplus output.
    if EPSettings.Costs then Cost.ToIDF;
  end;
end;

end.
