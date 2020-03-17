////////////////////////////////////////////////////////////////////////////////
//                                                                            //
// Copyright (c) 2008-2020 Alliance for Sustainable Energy.                   //
// All rights reserved.                                                       //
//                                                                            // 
////////////////////////////////////////////////////////////////////////////////

unit xmlStringList;

interface

uses
  classes, NativeXml;

type
  TXmlStringList = class(TStringList)
  private
    FParentNodeName: String;
    FChildNodeName: String;
  public
    constructor Create(ParentNodeName: string; ChildNodeName: string); reintroduce;
    procedure ToXml(var rootNode:TXmlNode);
    procedure FromXml(var rootNode: TXmlNode);
    procedure Remove(ItemName: string);
    procedure RemoveIfContains(ContainsStr: string);
  end;

  TUniqueXmlStringList = class(TXmlStringList)
  public
    function Add(const S: string): Integer; reintroduce;
  end;

implementation

uses xmltoIDFRoutines, xmlProcessing, HPBXMLManager, uMapDBtoXML;

constructor TXmlStringList.Create(ParentNodeName: string; ChildNodeName: string);
begin
  inherited Create;

  FParentNodeName := ParentNodeName;
  FChildNodeName := ChildNodeName;
end;

procedure TXmlStringList.FromXml(var rootNode: TXmlNode);
var
  aNode: TXmlNode;
  lNodes: TList;
  i: Integer;
begin
  //check if there is the parent node
  aNode := rootNode.FindNode(FParentNodeName);
  if aNode <> nil then
  begin
    lNodes := TList.Create;
    try
      //get the list of child nodes
      aNode.NodesByName(FChildNodeName, lNodes);
      if lNodes.count > 0 then
      begin
        for i := 0 to lNodes.Count - 1 do
        begin
          Add(TXmlNode(lNodes[i]).ValueAsString);
        end;
      end;
    finally
      lNodes.Free;
    end;
  end;
end;

procedure TXmlStringList.Remove(ItemName: string);
var
  index: Integer;
begin
  index := IndexOf(ItemName);
  if index >= 0 then
    Delete(index);
end;

procedure TXmlStringList.RemoveIfContains(ContainsStr: string);
var
  i: Integer;
begin
  for i := Count - 1 downto 0 do
  begin
    if pos(Strings[i], ContainsStr) >= 0 then
      Delete(i);
  end;
end;

procedure TXmlStringList.ToXml(var rootNode: TXmlNode);
var
  i: Integer;
  parentNode: TXmlNode;
begin
  if Count > 0 then
  begin
    parentNode := rootNode.NodeNew(FParentNodeName);
    for i := 0 to Count - 1 do
    begin
      AddElement(parentNode, FChildNodeName, Strings[i]);
    end;
  end;
end;

function TUniqueXmlStringList.Add(const S: string): Integer;
begin
  result := IndexOf(S);
  if result = -1 then
    result := inherited Add(S);
end;

end.
