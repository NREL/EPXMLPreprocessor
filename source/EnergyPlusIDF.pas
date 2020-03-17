////////////////////////////////////////////////////////////////////////////////
//                                                                            //
// Copyright (c) 2008-2020 Alliance for Sustainable Energy.                   //
// All rights reserved.                                                       //
//                                                                            // 
////////////////////////////////////////////////////////////////////////////////

unit EnergyPlusIDF;
//This unit will need the functionality also to overwrite the version
//for opteplus

interface

uses
  EnergyPlusCore,
  EnergyPlusObject,
  Contnrs,
  classes;

type
  TIDFWriteMode = (cNew, cAppend);

  TIDFFormat = (cConcise, cVerbose);

  TEnergyPlusIDF = class(TObject)
  private
    //This can be an EnergyPlus object or StringList
    FData: TObjectList;
  public
    WriteMode: TIDFWriteMode;
    Format: TIDFFormat;
    constructor Create; reintroduce;
    destructor Destroy; override;
    function AddObject(ObjectName: string = ''): TEnergyPlusObject;
    procedure AddStringList(aSL: TStringList; Comment: boolean = false);
    procedure SortObjects;
    function AddComment(Comment: string = '';
      SuppressAsterisks: boolean = false;
      SuppressCommentChar:boolean = false): TEnergyPlusComment;
    procedure SaveToFile(FileName: string);
    procedure Clear;
    procedure ReadFromFile(FileName: string);
  end;

implementation

constructor TEnergyPlusIDF.Create;
begin
  Format := cVerbose;
  FData := TObjectList.Create;
end;

destructor TEnergyPlusIDF.Destroy;
begin
  FData.Free;
  inherited;
end;

function TEnergyPlusIDF.AddObject(ObjectName: string): TEnergyPlusObject;
var
  EnergyPlusObject: TEnergyPlusObject;
begin
  EnergyPlusObject := TEnergyPlusObject.Create(ObjectName);
  FData.Add(EnergyPlusObject);
  result := EnergyPlusObject;
end;

procedure TEnergyPlusIDF.Clear;
begin
  FData.Clear;
end;

procedure TEnergyPlusIDF.SortObjects;
var
  i: Integer;
begin
  for i := 0 to FData.Count - 1 do
  begin
    //FData.Sort();
  end;
  // not yet implemented
  // don't know what to do with comments either
end;

function TEnergyPlusIDF.AddComment(Comment: string = '';
  SuppressAsterisks: boolean = false; SuppressCommentChar:boolean = false): TEnergyPlusComment;
var
  EnergyPlusComment: TEnergyPlusComment;
begin
  EnergyPlusComment := TEnergyPlusComment.Create(Comment);
  if SuppressAsterisks then EnergyPlusComment.SuppressAsterisks := true;
  if SuppressCommentChar then EnergyPlusComment.SuppressCommentChar := true;

  FData.Add(EnergyPlusComment);
  result := EnergyPlusComment;
end;

procedure TEnergyPlusIDF.AddStringList(aSL: TStringList; Comment: boolean = false);
var
  iSL: Integer;
begin
  if Comment then
  begin
    for iSL := 0 to aSL.Count - 1 do
    begin
      aSL[iSL] := '! ' + aSL[iSL];
    end;
  end;
  FData.Add(aSL);
end;

procedure TEnergyPlusIDF.SaveToFile(FileName: string);
var
  IDFFile: TextFile;
  i: integer;
  iSL: Integer;
begin
  AssignFile(IDFFile, FileName);
  try
    if WriteMode = cAppend then
      Append(IDFFile)
    else
      Rewrite(IDFFile);

    for i := 0 to FData.Count - 1 do
    begin
      if (FData[i] is TEnergyPlusObject) then
      begin
        if Format = cVerbose then
          WriteLn(IDFFile, NL + TEnergyPlusObject(FData[i]).ToIDF)
        else if Format = cConcise then
          WriteLn(IDFFile, TEnergyPlusObject(FData[i]).ToIDFConcise);
      end;

      if (FData[i] is TEnergyPlusComment) then
      begin
        if Format = cVerbose then
          WriteLn(IDFFile, TEnergyPlusComment(FData[i]).ToIDF);
        // if Format = cConcise then do nothing
      end;

      if (FData[i] is TStringList) then
      begin
        //no concise format for these
        writeln(IDFFile);
        for iSL := 0 to TStringList(FData[i]).Count - 1 do
          WriteLn(IDFFile, TStringList(FData[i])[iSL]);
      end;

    end;
  finally
    CloseFile(IDFFile);
  end;
end;

procedure TEnergyPlusIDF.ReadFromFile(FileName: string);
begin
  //
end;

end.
 