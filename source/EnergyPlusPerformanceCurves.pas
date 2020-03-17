////////////////////////////////////////////////////////////////////////////////
//                                                                            //
// Copyright (c) 2008-2020 Alliance for Sustainable Energy.                   //
// All rights reserved.                                                       //
//                                                                            // 
////////////////////////////////////////////////////////////////////////////////

unit EnergyPlusPerformanceCurves;

interface
uses
  EnergyPlusCore,
  Globals;

type
  T_Curve_Cubic = class(TEnergyPlusGroup)
  public
    Name: string;
    Coeff1: double;
    Coeff2: double;
    Coeff3: double;
    Coeff4: double;
    minimum_value_of_x: double;
    maximum_value_of_x: double;
    procedure ToIDF; override;
    constructor Create; reintroduce;
    procedure Finalize; override;
  end;
implementation

uses EnergyPlusObject;

constructor T_Curve_Cubic.Create;
begin
  gPerformanceCurves.add(self);
end;

procedure T_Curve_Cubic.Finalize;
begin
  inherited;
end;

procedure T_Curve_Cubic.ToIDF;
var
  Obj: TEnergyPlusObject;
begin
  Obj := IDF.AddObject('Curve:Cubic');
  Obj.AddField('Name', Name);
  Obj.AddField('Coefficient1 Constant', Coeff1);
  Obj.AddField('Coefficient2 x', Coeff2);
  Obj.AddField('Coefficient3 x**2', Coeff3);
  Obj.AddField('Coefficient4 x**3', Coeff4);
  Obj.AddField('Minimum Value of x', minimum_value_of_x);
  Obj.AddField('Maximum Value of x', maximum_value_of_x);
end;


end.
