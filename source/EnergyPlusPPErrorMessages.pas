////////////////////////////////////////////////////////////////////////////////
//                                                                            //
// Copyright (c) 2008-2020 Alliance for Sustainable Energy.                   //
// All rights reserved.                                                       //
//                                                                            // 
////////////////////////////////////////////////////////////////////////////////

unit EnergyPlusPPErrorMessages;

interface

uses
  SysUtils,
  Contnrs,
  EnergyPlusCore,
  classes,
  Globals;

type
  TErrorSeverity = (esWarning, esSevere, esFatal);
  
  T_EP_PPErrorMessage = class(TEnergyPlusGroup)
  public
    Severity: TErrorSeverity;
    ErrorMessage: string;
    class procedure AddErrorMessage(ErrorSeverity: TErrorSeverity; sMessage: string);
    procedure ToIDF; override;
    procedure Finalize; override;
  end;

implementation

uses GlobalFuncs, StringFileUtilities, EnergyPlusObject;

class procedure T_EP_PPErrorMessage.AddErrorMessage(ErrorSeverity: TErrorSeverity; sMessage: string);
var
  newErr: T_EP_PPErrorMessage;
begin
  newErr := T_EP_PPErrorMessage.Create;
  newErr.Name := 'ErrorMessage_' + IntToStr(ErrorMessages.Count + 1);
  newErr.Severity := ErrorSeverity;
  newErr.ErrorMessage := sMessage;
  ErrorMessages.Add(newErr);

  case ErrorSeverity of
    esWarning: writeln('Warning: ' + sMessage);
    esSevere: writeln('Severe Error: ' + sMessage);
    esFatal: writeln('FATAL ERROR: ' + sMessage);
  end;
end;

{ T_EP_PPErrorMessage }

procedure T_EP_PPErrorMessage.Finalize;
begin
  inherited;
end;

procedure T_EP_PPErrorMessage.ToIDF;
var
  Obj: TEnergyPlusObject;
  slMessage: TStringList;
  sSeverity: string;
  i: Integer;
begin
  inherited;

  slMessage := MakeLinesFromString(ErrorMessage);
  try
    Obj := IDF.AddObject('Output:PreprocessorMessage');
    Obj.AddField('Preprocessor Name', 'EPXMLPreProc2');
    if Severity = esWarning then
      sSeverity := 'Warning'
    else if Severity = esSevere then
      sSeverity := 'Severe'
    else if Severity = esFatal then
      sSeverity := 'Fatal';

    Obj.AddField('Error Severity', sSeverity);
    for i := 0 to slMessage.Count - 1 do
    begin
      if i > 9 then break;
      Obj.AddField('Message Line ' + inttostr(i + 1), slMessage[i]);
    end;
  finally
    slMessage.Free;
  end;
end;

end.
