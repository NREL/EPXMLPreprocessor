////////////////////////////////////////////////////////////////////////////////
//                                                                            //
// Copyright (c) 2008-2020 Alliance for Sustainable Energy.                   //
// All rights reserved.                                                       //
//                                                                            // 
////////////////////////////////////////////////////////////////////////////////

unit EnergyPlusField;

interface

uses
  SysUtils,
  Contnrs;

type
  TField = class(TObject)
  private
    FName: string;
    FValue: string;
    FUnits: string;
    FComment: string;
  public
    constructor Create(NameParam: string; ValueParam: string = ''; UnitsParam: string = ''; CommentParam: string = '');
    function ToIDF(EndOfFieldList:Boolean; Concise:Boolean):String;
    property Comment: string read FComment;
    property Name: string read FName;
    property Units: string read FUnits;
    property Value: string read FValue;
  end;

  TFieldList = class(TObjectList)
  private
    function GetItemByName(Name: string): TField;
    function GetItems(Index: Integer): TField;
    procedure SetItems(Index: Integer; const Value: TField);
  public
    Name: string;
    function ToIDF(Concise:Boolean):string ;
    function Add(AField: TField): Integer; overload;
    function Add(Name: string; Value: string = ''; Units: string = ''; Comment: string = ''): TField; overload;
    property Items[Index: Integer]: TField read GetItems write SetItems; default;
    property ItemByName[Name: string]: TField read GetItemByName;
  end;

implementation

uses Classes, EnergyPlusCore;

constructor TField.Create(NameParam, ValueParam, UnitsParam, CommentParam: string);
begin
  inherited Create;
  FName := NameParam;
  FValue := ValueParam;
  FUnits := UnitsParam;
  FComment := CommentParam;
end;

function TField.ToIDF(EndOfFieldList:Boolean; Concise:Boolean):String;
var
  EndOfLine: string;
begin
  result := '';
  if EndOfFieldList then
    EndOfLine := ';'
  else
    EndOfLine := ',';

  if ((Name = '') and (Units = '') and (Comment = '')) or
     (Concise) then
    result := (Value + EndOfLine)
  else if Comment = '' then
    result := (Value + EndOfLine + '  !- ' + Name + ' ' + Units)
  else
    result := (Value + EndOfLine + '  !- ' + Name + ' ' + Units + ' [' + Comment + ']');

  if not EndOfFieldList then
    result := result + NL;
end;

function TFieldList.Add(Name, Value, Units, Comment: string): TField;
begin
  result := TField.Create(Name, Value, Units, Comment);
  Add(Result);
end;

function TFieldList.Add(AField: TField): Integer;
begin
  result := inherited Add(AField);
end;

function TFieldList.GetItemByName(Name: string): TField;
var
  i: Integer;
begin
  result := nil;
  for i := 0 to Count - 1 do
  begin
    if SameText(Items[i].Name, Name) then
    begin
      Result := Items[i];
      break;
    end;
  end; //for count
end;

function TFieldList.GetItems(Index: Integer): TField;
begin
  Result := TField(inherited Items[Index]);
end;

procedure TFieldList.SetItems(Index: Integer; const Value: TField);
begin
  inherited Items[Index] := Value;
end;

function TFieldList.ToIDF(Concise:Boolean): string;
var
  i: Integer;
begin
  if not Concise then
  begin
    for i := 0 to Count - 1 do
    begin
      Result := Result + Indent + Items[i].ToIDF(i = Count - 1, Concise);
    end;
  end
  else
  begin
    Result := Result + Items[i].ToIDF(i = Count - 1, Concise)
  end;
end;

end.
 