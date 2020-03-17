////////////////////////////////////////////////////////////////////////////////
//                                                                            //
// Copyright (c) 2008-2020 Alliance for Sustainable Energy.                   //
// All rights reserved.                                                       //
//                                                                            // 
////////////////////////////////////////////////////////////////////////////////

unit EnergyPlusSchedules;

interface

uses
  Contnrs,
  classes,
  Globals,
  EnergyPlusCore;

type
  T_EP_Schedule = class(TEnergyPlusGroup)
  public
    SchedTypeLibrary: TStringList;
    SchedLibrary: TStringList;
    constructor Create; reintroduce;
    procedure ToIDF; override;
    procedure Finalize; override;
  end;

implementation

constructor T_EP_Schedule.Create;
begin
  inherited;

  Schedules.Add(self);
  SchedLibrary := TStringList.Create;
  SchedTypeLibrary := TStringList.Create;
end;

procedure T_EP_Schedule.Finalize;
begin
  inherited;
end;

procedure T_EP_Schedule.ToIDF;
begin
  inherited;

  if Assigned(SchedTypeLibrary) then
    if SchedTypeLibrary.Count > 0 then
      IDF.AddStringList(SchedTypeLibrary);

  if Assigned(SchedLibrary) then
    if SchedLibrary.Count > 0 then
      IDF.AddStringList(SchedLibrary);

  //write schedule library
  //obj

end;

end.
