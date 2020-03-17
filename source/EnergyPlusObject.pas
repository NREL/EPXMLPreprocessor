////////////////////////////////////////////////////////////////////////////////
//                                                                            //
// Copyright (c) 2008-2020 Alliance for Sustainable Energy.                   //
// All rights reserved.                                                       //
//                                                                            // 
////////////////////////////////////////////////////////////////////////////////

unit EnergyPlusObject;

interface

uses
  SysUtils,
  EnergyPlusField;

type
  TEnergyPlusObject = class(TObject)
  private
    FieldList: TFieldList;
  public
    Name: string;
    constructor Create(ObjectName: string = ''); overload;
    destructor Destroy; override;
    function AddField(Name: string; Value: string; Units: string = ''; Comment: string = ''): TField; overload;
    function AddField(Name: string; IntValue: Integer; Units: string = ''; Comment: string = ''): TField; overload;
    function AddField(Name: string; DblValue: double; Units: string = ''; Comment: string = ''): TField; overload;
    function ToIDF: string;
    function ToIDFConcise: string;
  end;

implementation

uses EnergyPlusCore;

constructor TEnergyPlusObject.Create(ObjectName: string);
begin
  Name := ObjectName;
  FieldList := TFieldList.Create;
end;

destructor TEnergyPlusObject.Destroy;
begin
  FieldList.Free;
  inherited;
end;

function TEnergyPlusObject.AddField(Name, Value, Units, Comment: string): TField;
begin
  Result := FieldList.Add(Name, Value, Units, Comment);
end;

function TEnergyPlusObject.AddField(Name: string; IntValue: Integer; Units, Comment: string): TField;
var
  sValue: string;
begin
  sValue := IntToStr(IntValue);
  Result := FieldList.Add(Name, sValue, Units, Comment);
end;

function TEnergyPlusObject.AddField(Name: string; DblValue: double; Units, Comment: string): TField;
var
  sValue: string;
begin
  sValue := format('%.4f', [DblValue]);
  Result := FieldList.Add(Name, sValue, Units, Comment);
end;

function TEnergyPlusObject.ToIDF: string;
begin
  result := Name + ',' + NL;
  result := result + FieldList.ToIDF(False);
end;

function TEnergyPlusObject.ToIDFConcise: string;
begin
  result := Name + ',' + FieldList.ToIDF(True);
end;

end.
