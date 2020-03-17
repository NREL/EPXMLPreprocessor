////////////////////////////////////////////////////////////////////////////////
//                                                                            //
// Copyright (c) 2008-2020 Alliance for Sustainable Energy.                   //
// All rights reserved.                                                       //
//                                                                            // 
////////////////////////////////////////////////////////////////////////////////

unit DataOutput;

interface

uses
  Globals,
  EnergyPlusBuilding,
  NativeXml;

procedure ZoneSummary(Building: T_EP_Building; DocRoot: TXMLNode);

implementation

procedure ZoneSummary(Building: T_EP_Building; DocRoot: TXMLNode);

var
  IDFFile: TextFile;

begin

  //AssignFile(IDFFile, 'ZoneInfo.csv');
  try
    Rewrite(IDFFile);
    WriteLn(IDFFile, 'Hello World');

  finally
    CloseFile(IDFFile);
  end;
  
end;

end.
