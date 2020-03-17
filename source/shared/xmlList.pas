////////////////////////////////////////////////////////////////////////////////
//                                                                            //
// Copyright (c) 2008-2020 Alliance for Sustainable Energy.                   //
// All rights reserved.                                                       //
//                                                                            // 
////////////////////////////////////////////////////////////////////////////////

unit xmlList;

//This unit contains the array ability for xml persistence

interface

uses
  xmlCore, NativeXml, SysUtils, Classes;
  
type
  TXmlDoubleList = class(TXMLObject)  //this should inherit from TMLList
  private
    FnodeName : string;
  public
    Data: Array of double;
    constructor Create(nodeName:String);
    procedure Clear();
    destructor Destroy; override;
    procedure ToXML(var rootNode:TXmlNode); override;
    procedure FromXML(rootNode:TXmlNode); override;
    procedure Assign(AXmlDoubleList:TXmlDoubleList);  overload;
    procedure Assign(doubleArray: array of Double);  overload;
  end;

implementation

{ TXmlList }

procedure TXmlDoubleList.Assign(AXmlDoubleList: TXmlDoubleList);
var
  i: Integer;
begin
  Clear;

  FnodeName := AXmlDoubleList.FnodeName;
  SetLength(Data, length(AXmlDoubleList.Data));
  for i := 0 to length(AXmlDoubleList.Data) - 1 do
    Data[i] := AXmlDoubleList.Data[i];
end;

procedure TXmlDoubleList.Assign(doubleArray: array of Double);
var
  i: Integer;
begin
  Clear;

  SetLength(Data, length(doubleArray));
  for i := 0 to length(doubleArray) - 1 do
    Data[i] := doubleArray[i];

end;

procedure TXmlDoubleList.Clear;
begin
  SetLength(Data, 0);
end;

constructor TXmlDoubleList.Create(nodeName:String);
begin
  inherited Create;
  FnodeName := nodeName;
end;

destructor TXmlDoubleList.Destroy;
begin
  inherited;
end;

procedure TXmlDoubleList.FromXML(rootNode: TXmlNode);
var
  lNodes: TList;
  i: Integer;
begin
  inherited;

  //clear out the data
  Clear;

  lNodes := TList.Create;
  try
    lNodes.Clear;
    rootNode.NodesByName(FnodeName, lNodes);
    if lNodes.Count > 0 then
    begin
      SetLength(Data, lNodes.count);
      for i := 0 to lNodes.Count - 1 do
        with TXmlNode(lNodes.Items[i]) do
          Data[i] := ValueAsFloatDef(0);
    end;
  finally
    lNodes.free;
  end;
end;

procedure TXmlDoubleList.ToXML(var rootNode: TXmlNode);
var
  i: Integer;
begin
  inherited;

  for i := 0 to Length(Data) - 1 do
  begin
    rootNode.NodeNew(FnodeName).ValueAsFloat := Data[i];
  end;
end;

end.
