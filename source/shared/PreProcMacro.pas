////////////////////////////////////////////////////////////////////////////////
//                                                                            //
// Copyright (c) 2008-2020 Alliance for Sustainable Energy.                   //
// All rights reserved.                                                       //
//                                                                            // 
////////////////////////////////////////////////////////////////////////////////

unit PreProcMacro;

interface

uses
  Classes,
  SysUtils; 

type
  TPreProcMacro = class(TObject)
  protected
    FilePath: String;
    text: String;
  public
    constructor Create(aFilePath: string);
    procedure Initialize;
    function getDefinedText(definedTextName: string): string;
  end;


implementation
  uses
    RegExpr;
  

  constructor TPreProcMacro.Create(aFilePath: string);
  begin
    FilePath := aFilePath;
    Initialize;
  end;
  
  procedure TPreProcMacro.initialize;
  begin
    with TStringList.Create do
    try
      LoadFromFile(FilePath);
      Self.Text := Text;
    finally
      Free;
    end;
  end;

  function TPreProcMacro.getDefinedText(definedTextName: string): string;
  //const

  var
    re: TRegExpr;
    ARegExp: string;
  begin
    ARegExp := '##def\s+';
    ARegExp := ARegExp + '(' + definedTextName + ')';
    ARegExp := ARegExp + '\[.*?\](.*?)##enddef';
    re := TRegExpr.Create;
    // ksb: case insensitive
    re.ModifierI := True;
    re.Expression := ARegExp;
    re.Exec(text);
    Result := re.Match[2];
    re.Free;

  end;
  
end.

