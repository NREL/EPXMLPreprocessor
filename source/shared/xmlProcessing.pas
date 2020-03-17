////////////////////////////////////////////////////////////////////////////////
//                                                                            //
// Copyright (c) 2008-2020 Alliance for Sustainable Energy.                   //
// All rights reserved.                                                       //
//                                                                            // 
////////////////////////////////////////////////////////////////////////////////

unit xmlProcessing;

interface

Uses
  SysUtils,
  NativeXml,
  xmlCostStructures;
  
function StringValueFromPath(XMLNode: TXmlNode; XMLPath: string; UpCase: boolean = true; Default: string = ''): string;
function BooleanValueFromPath(XMLNode: TXmlNode; XMLPath: string; Default: boolean = false): boolean;
function IntegerValueFromPath(XMLNode: TXmlNode; XMLPath: string; Default: integer = 0): integer;
function FloatValueFromPath(XMLNode: TXmlNode; XMLPath: string; Default: double = 0.0): double;
function StringValueFromAttribute(XMLNode: TXmlNode; XMLAttribute: string; UpCase: boolean = true; Default: string = ''): string;
function BooleanValueFromAttribute(XMLNode: TXmlNode; XMLAttribute: string; Default: boolean = false): boolean;
function IntegerValueFromAttribute(XMLNode: TXmlNode; XMLAttribute: string; Default: integer = 0): integer;
function FloatValueFromAttribute(XMLNode: TXmlNode; XMLAttribute: string; Default: double = 0): double;

procedure ReadRealValStruct(var inRealValStruct: RealValStruct;
      Child_Node: TXmlNode);
procedure ReadIntegerValStruct(var inIntStruct: IntegerValStruct;
  Child_Node: TXmlNode);
procedure ReadStringValStruct(var inStringStruct: StringValStruct;
  Child_Node: TXmlNode);
procedure ReadValCostStruct(var inStruct: RealCostStruct;
  Child_Node: TXmlNode; XMLPath: string); overload;
procedure ReadValCostStruct(var inStruct: IntegerCostStruct;
  Child_Node: TXmlNode; XMLPath: string); overload;
procedure ReadValCostStruct(var inStruct: StringCostStruct;
  Child_Node: TXmlNode; XMLPath: string); overload;
procedure ReadValCostStruct(var inStruct: BoolCostStruct;
  Child_Node: TXmlNode; XMLPath: string); overload;
procedure ReadCostStruct(var inCostStruct: CostStruct;
  Child_Node: TXmlNode);

Implementation

function StringValueFromPath(XMLNode: TXmlNode; XMLPath: string; UpCase: boolean = true; Default: string = ''): string;
var
  Node: TXmlNode;
begin
  Result := Default;

  if Assigned(XMLNode) then
  begin
    Node := XMLNode.NodeByName(XMLPath);
    if Assigned(Node) then
    begin
      if UpCase then
        Result := UpperCase(Node.ValueAsString) // will want a case-sensitive version for system names, etc.
      else
        Result := Node.ValueAsString;
    end;
  end;
  Result := Trim(Result);
end;

function BooleanValueFromPath(XMLNode: TXmlNode; XMLPath: string; Default: boolean = false): boolean;
var
  ValueStr: string;
  ValueBool: boolean;
begin
  ValueStr := StringValueFromPath(XMLNode, XMLPath);
  //StrToBoolDef()
  if ValueStr <> '' then
  begin
    if UpperCase(ValueStr) = 'TRUE' then
      ValueBool := true
    else
      ValueBool := false;
  end
  else
    ValueBool := Default;
  result := ValueBool;
end;

function IntegerValueFromPath(XMLNode: TXmlNode; XMLPath: string; Default: integer = 0): integer;
var
  ValueStr: string;
  ValueInt: integer;
begin
  ValueStr := StringValueFromPath(XMLNode, XMLPath);
  if not TryStrToInt(ValueStr, ValueInt) then
    ValueInt := Default;
  result := ValueInt;
end;

function FloatValueFromPath(XMLNode: TXmlNode; XMLPath: string; Default: double = 0.0): double;
var
  ValueStr: string;
  ValueFloat: double;
begin
  ValueStr := StringValueFromPath(XMLNode, XMLPath);
  if not TryStrToFloat(ValueStr, ValueFloat) then
    ValueFloat := Default;
  result := ValueFloat;
end;

function StringValueFromAttribute(XMLNode: TXmlNode; XMLAttribute: string; UpCase: boolean = true; Default: string = ''): string;
begin
  Result := Default;

  if Assigned(XMLNode) then
  begin
    if XMLNode.HasAttribute(XMLAttribute) then
    begin
      Result := XMLNode.AttributeByName[XMLAttribute];
      if UpCase then UpperCase(Result);
    end;
  end;

  Result := Trim(Result);
end;

function BooleanValueFromAttribute(XMLNode: TXmlNode; XMLAttribute: string; Default: boolean = false): boolean;
var
  ValueStr: string;
  ValueBool: boolean;
begin
  ValueStr := StringValueFromAttribute(XMLNode, XMLAttribute);
  if ValueStr <> '' then
  begin
    if UpperCase(ValueStr) = 'TRUE' then
      ValueBool := true
    else
      ValueBool := false;
  end
  else
    ValueBool := Default;
  result := ValueBool;
end;

function IntegerValueFromAttribute(XMLNode: TXmlNode; XMLAttribute: string; Default: integer = 0): integer;
var
  ValueStr: string;
  ValueInt: integer;
begin
  ValueStr := StringValueFromAttribute(XMLNode, XMLAttribute);
  if not TryStrToInt(ValueStr, ValueInt) then
    ValueInt := Default;
  result := ValueInt;
end;

function FloatValueFromAttribute(XMLNode: TXmlNode; XMLAttribute: string; Default: double = 0): double;
var
  ValueStr: string;
  ValueFloat: double;
begin
  ValueStr := StringValueFromAttribute(XMLNode, XMLAttribute);
  if not TryStrToFloat(ValueStr, ValueFloat) then
    ValueFloat := Default;
  result := ValueFloat;
end;

procedure ReadRealValStruct(var inRealValStruct: RealValStruct;
  Child_Node: TXmlNode);
begin
  if Child_Node <> nil then
  begin
    with inRealValStruct, Child_Node do
    begin
      if HasAttribute('instance') then
        Instance := StrToFloat(AttributeByName['instance']);
      if HasAttribute('type') then
        RealType := StrToInt(AttributeByName['type']);
      if HasAttribute('mean') then
        Mean := StrToFloat(AttributeByName['mean']);
      if HasAttribute('min') then
        Min := StrToFloat(AttributeByName['min']);
      if HasAttribute('max') then
        Max := StrToFloat(AttributeByName['max']);
      if HasAttribute('StDev') then
        StDev := StrToFloat(AttributeByName['StDev']);
      if HasAttribute('Distribution') then
        Distribution := AttributeByName['Distribution'];
      ReadCostStruct(Cost, Child_Node);
    end; //with
  end; //if
end; //readrealval


procedure ReadIntegerValStruct(var inIntStruct: IntegerValStruct;
  Child_Node: TXmlNode);
begin
  if Child_Node <> nil then
  begin
    with inIntStruct, Child_Node do
    begin
      if HasAttribute('instance') then
        Instance := StrToInt(AttributeByName['instance']);
      if HasAttribute('type') then
        IntType := StrToInt(AttributeByName['type']);
      if HasAttribute('mode') then
        Mode := StrToInt(AttributeByName['mode']);
      if HasAttribute('min') then
        Min := StrToInt(AttributeByName['min']);
      if HasAttribute('max') then
        Max := StrToInt(AttributeByName['max']);
      if HasAttribute('Distribution') then
        Distribution := AttributeByName['Distribution'];
      ReadCostStruct(Cost, Child_Node);
    end; //with}
  end;
end; //readrealval

procedure ReadStringValStruct(var inStringStruct: StringValStruct;
  Child_Node: TXmlNode);
begin
  if Child_Node <> nil then
  begin
    with inStringStruct, Child_Node do
    begin
      if HasAttribute('instance') then
        Instance := AttributeByName['instance'];
      if HasAttribute('units') then
        Units := AttributeByName['units'];
      if HasAttribute('StrType') then
        StrType := StrToInt(AttributeByName['StrType']);
      if HasAttribute('options') then
        Options := AttributeByName['options'];
      if HasAttribute('Comments') then
        Comments := AttributeByName['Comments'];
      ReadCostStruct(Cost, Child_Node);
    end; //with}
  end;
end; //readstringval

procedure ReadValCostStruct(var inStruct: RealCostStruct;
  Child_Node: TXmlNode; XMLPath: string);
begin
  if assigned(Child_Node) then
  begin
    inStruct.Value := FloatValueFromPath(Child_Node, XMLPath);
    ReadCostStruct(inStruct.Cost, Child_Node.NodeByName(XMLPath));
  end;
end;

procedure ReadValCostStruct(var inStruct: IntegerCostStruct;
  Child_Node: TXmlNode; XMLPath: string);
begin
  if assigned(Child_Node) then
  begin
    inStruct.Value := IntegerValueFromPath(Child_Node, XMLPath);
    ReadCostStruct(inStruct.Cost, Child_Node.NodeByName(XMLPath));
  end;
end;

procedure ReadValCostStruct(var inStruct: StringCostStruct;
  Child_Node: TXmlNode; XMLPath: string);
begin
  if assigned(Child_Node) then
  begin
    inStruct.Value := StringValueFromPath(Child_Node, XMLPath, False);
    ReadCostStruct(inStruct.Cost, Child_Node.NodeByName(XMLPath));
  end;
end;

procedure ReadValCostStruct(var inStruct: BoolCostStruct;
  Child_Node: TXmlNode; XMLPath: string);
begin
  if assigned(Child_Node) then
  begin
    inStruct.Value := BooleanValueFromPath(Child_Node, XMLPath, False);
    ReadCostStruct(inStruct.Cost, Child_Node.NodeByName(XMLPath));
  end;
  //
end;

procedure ReadCostStruct(var inCostStruct: CostStruct;
  Child_Node: TXmlNode);
begin
  if Child_Node <> nil then
  begin
    with inCostStruct do
    begin
      MatCost := FloatvalueFromAttribute(Child_Node, 'CostPer', 0);
      InstallCost := FloatvalueFromAttribute(Child_Node, 'InstallCost', 0);
      FixedOM := FloatvalueFromAttribute(Child_Node, 'FixedOM', 0);
      VariableOM := FloatvalueFromAttribute(Child_Node, 'VariableOM', 0);
      ExpectedLife := FloatvalueFromAttribute(Child_Node, 'ExpectedLife', 0);
      PhysicalSpace := FloatvalueFromAttribute(Child_Node, 'PhysicalSpaceReq', 0);
      SalvageCost := FloatvalueFromAttribute(Child_Node, 'SalvageCost', 0);
      CostUnits := StringValueFromAttribute(Child_Node, 'CostUnits', false);
      DataSource := StringValueFromAttribute(Child_Node, 'DataSource', false);
    end; //wiht
  end; //if
end; //ReadCostSTruct

end.
