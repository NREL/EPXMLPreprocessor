////////////////////////////////////////////////////////////////////////////////
//                                                                            //
// Copyright (c) 2008-2020 Alliance for Sustainable Energy.                   //
// All rights reserved.                                                       //
//                                                                            // 
////////////////////////////////////////////////////////////////////////////////

unit EnergyPlusReportVariables;

interface

uses
  Globals,
  EnergyPlusCore,
  classes;

type
  T_EP_ReportVariables = class(TEnergyPlusGroup)
  public
    VariableLibrary: TStringList;
    procedure ToIDF; override;
    constructor Create; reintroduce;
  end;

implementation

{ T_EP_ReportVariables }

constructor T_EP_ReportVariables.Create;
begin
  inherited;
  VariableLibrary := TStringList.Create;
end;

procedure T_EP_ReportVariables.ToIDF;
begin
  inherited;

  if Assigned(VariableLibrary) then
    if VariableLibrary.Count > 0 then
      IDF.AddStringList(VariableLibrary);
end;

end.
