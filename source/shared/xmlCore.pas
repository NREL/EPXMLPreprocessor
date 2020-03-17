////////////////////////////////////////////////////////////////////////////////
//                                                                            //
// Copyright (c) 2008-2020 Alliance for Sustainable Energy.                   //
// All rights reserved.                                                       //
//                                                                            // 
////////////////////////////////////////////////////////////////////////////////

unit xmlCore;

interface

uses
  Classes{TComponent}, Contnrs, NativeXML;

type
  //TODO: Break out this interface into two separate interfaces -- remove the
  //abstract virtual methods
  TXMLObject = class(TObject)
  public
    procedure ToXML(var rootNode:TXmlNode); virtual; abstract;
    procedure FromXML(rootNode:TXmlNode); virtual; abstract;
    procedure ToIDF(var outfile: TextFile); virtual; abstract;
  end;

  TXMLObjectList = class(TObjectList)
  protected
    function GetItem(Index: Integer): TXMLObject;
    procedure SetItem(Index: Integer; AnXmlObject: TXMLObject);
  public
    //This object list owns the write method for the XMLObject because it
    //calls the write of each of the XMLObjects
    procedure ToXML(var RootNode:TXmlNode);
    property Items[Index: Integer]: TXMLObject read GetItem write SetItem; default;
  end;

const
  TB = '  '; //define the tab
  
implementation

function TXMLObjectList.GetItem(Index: Integer): TXMLObject;
begin
  Result := TXMLObject(inherited Items[Index]);
end;

procedure TXMLObjectList.SetItem(Index: Integer; AnXmlObject: TXMLObject);
begin
  inherited Items[Index] := AnXmlObject;
end;

procedure TXMLObjectList.ToXML(var RootNode:TXmlNode);
var
  i: Integer;
begin
  for i := 0 to count - 1 do
  begin
    Items[i].ToXML(RootNode);
  end;
end;

end.
