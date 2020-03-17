////////////////////////////////////////////////////////////////////////////////
//                                                                            //
// Copyright (c) 2008-2020 Alliance for Sustainable Energy.                   //
// All rights reserved.                                                       //
//                                                                            // 
////////////////////////////////////////////////////////////////////////////////

unit EnergyPlusExteriorLoads;

interface

uses
  SysUtils,
  Contnrs,
  Globals,
  EnergyPlusCore;

type
  T_EP_ExteriorFacadeLighting = class(TEnergyPlusGroup)
  public
    DesignLevel: double;
    TotalPower: double;
    PowerDensity: double;
    ScheduleName: string;
    ControlOption: string;
    procedure ToIDF; override;
    procedure Finalize; override;
  end;

implementation

uses EnergyPlusObject;

{ T_EP_ExteriorFacadeLighting }

procedure T_EP_ExteriorFacadeLighting.Finalize;
begin
  inherited;
end;

procedure T_EP_ExteriorFacadeLighting.ToIDF;
var
  Obj: TEnergyPlusObject;
begin
  inherited;

  Obj := IDF.AddObject('Exterior:Lights');
  Obj.AddField('Name', Name);
  Obj.AddField('Schedule Name', ScheduleName);
  Obj.AddField('Design Level', DesignLevel);
  Obj.AddField('Control Option', ControlOption);
  Obj.AddField('End-Use Subcategory', 'Exterior Facade Lighting');
end;


end.
