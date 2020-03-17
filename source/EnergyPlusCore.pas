////////////////////////////////////////////////////////////////////////////////
//                                                                            //
// Copyright (c) 2008-2020 Alliance for Sustainable Energy.                   //
// All rights reserved.                                                       //
//                                                                            // 
////////////////////////////////////////////////////////////////////////////////

unit EnergyPlusCore;
// home to TEnergyPlusObject and TEnergyPlusIDF

interface

uses
  SysUtils,
  classes,
  Contnrs;

type
  TEnergyPlusGroup = class(TObject)
  public
    Name: string;
    procedure Finalize; virtual; abstract; 
    procedure ToIDF; virtual; abstract;
  end;

  TEnergyPlusGroupList = class(TObjectList)
  protected
    function GetItem(Index: Integer): TEnergyPlusGroup;
    procedure SetItem(Index: Integer; AnEnergyPlusGroup: TEnergyPlusGroup);
  public
    //This object list owns the write method for the XMLObject because it
    //calls the write of each of the XMLObjects
    property Items[Index: Integer]: TEnergyPlusGroup read GetItem write SetItem; default;
    procedure ToIDF;
  end;

  THVACComponent = class(TEnergyPlusGroup)
  public
    DetailedReporting: Boolean;
    ComponentType: string;
    ControlType: string; // this is the main control type PASSIVE|ACTIVE|BYPASS
    DemandControlType: string; // this is used when the object is on the Demand side (same obj could differ 'tween supply and demand)
    DemandInletNode: string;
    DemandOutletNode: string;
    SupplyInletNode: string;
    SupplyOutletNode: string;
    SuppressToIDF: boolean;
    ControlNode: string;
    AirSystemName: string;
    ZoneServedName: string;
    LiquidSystemName: string;
    RefrigSystemName: string;
    SetPtMgrName: string;
    OutletTemperature: double;
    Capacity: double;
  end;

  TEnergyPlusComment = class(TObject)
  public
    SuppressAsterisks: boolean;
    SuppressCommentChar : boolean;
    Comment: string;
    constructor Create(CommentString: string = ''); overload;
    function ToIDF: string;
    function ToIDFConcise: string;
  end;

var
  // Global constants
  NL: string = #13#10; // This is the Windows definition; Linux uses #10
  Indent: string = '  ';

implementation

// string utility function


{ TEnergyPlusObject }



{ TEnergyPlusComment }

constructor TEnergyPlusComment.Create(CommentString: string);
begin
  Comment := CommentString;
  SuppressAsterisks := false;
  SuppressCommentChar := false;
end;

function TEnergyPlusComment.ToIDF: string;
begin
  if Comment = '' then
    result := ''
  else
  begin
    if not SuppressAsterisks then
    begin
      if not SuppressCommentChar then
        result := '!***** ' + Comment + ' *****'
      else
        result := '***** ' + Comment + ' *****'; //should never be seen
    end
    else
    begin
      if not SuppressCommentChar then
        result := '! ' + Comment
      else
        result := Comment
    end;
  end;
end;

function TEnergyPlusComment.ToIDFConcise: string;
begin
  result := '';
end;

{ TEnergyPlusGroupList }

function TEnergyPlusGroupList.GetItem(Index: Integer): TEnergyPlusGroup;
begin
  Result := TEnergyPlusGroup(inherited Items[Index]);
end;

procedure TEnergyPlusGroupList.SetItem(Index: Integer;
  AnEnergyPlusGroup: TEnergyPlusGroup);
begin
  inherited Items[Index] := AnEnergyPlusGroup;
end;

procedure TEnergyPlusGroupList.ToIDF;
var
  i: integer;
begin
  for i := 0 to Count - 1 do
    Items[i].ToIDF;
end;

end.
