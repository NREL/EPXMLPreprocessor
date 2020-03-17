////////////////////////////////////////////////////////////////////////////////
//                                                                            //
// Copyright (c) 2008-2020 Alliance for Sustainable Energy.                   //
// All rights reserved.                                                       //
//                                                                            // 
////////////////////////////////////////////////////////////////////////////////

unit EnergyPlusGeometry;

interface

uses
  SysUtils,
  Contnrs,
  Globals,
  VectorMath,
  EnergyPlusCore,
  EnergyPlusSurfaces,
  Classes,
  NativeXML;

type
  T_EP_Zoning = class(TObject)
  public
    EP_Points: TObjectList;
    constructor Create; reintroduce;
    procedure AddPoint(EPPoint: T_EP_Point); overload;
    procedure AddPoint(xValue, yValue: double); overload;
    //function GetPoint(index:integer):T_EP_Point;
  end;

  T_EP_Footprint = class(TEnergyPlusGroup)
  public
    Enabled: Boolean;
    EP_Points: TObjectList;
    Zoning: TObjectList;
    ZoneLayout: string; //Minimum Zones, Perimeter and Core, Perimeter Corners and Core, Other
    ZoneNameMoniker: string;
    ZoneDescription: string;
    FootPrintType: string; //Rectangle, L-Shape, ...
    FloorPlateArea: double;
    FloorNum: integer;
    FloorMult: double;
    FloorToFloorHeight: double;
    Length1: double;
    Length2: double;
    Width1: double;
    Width2: double;
    End1: double;
    End2: double;
    Offset1: double;
    Offset2: double;
    Offset3: double;
    X1, X2, X3, Y1, Y2, Y3: double; //these are used for specific zone layouts
    procedure ToIDF; override;
    procedure AddPoint(EPPoint: T_EP_Point); overload;
    procedure AddPoint(xValue, yValue: double; zValue: double); overload;
    function GetPoint(index: integer): T_EP_Point;
    function AddZoning: T_EP_Zoning;
    constructor Create; reintroduce;
    procedure Finalize; override;
  end;

  T_EP_Geometry = class(TEnergyPlusGroup)
  private
    procedure CreateAtticZoning();
    procedure CreateMinimalZoning(aFootPrint: T_EP_Footprint; iFlr: integer; Section: integer);
  public
    AtticHeight: Double;
    BuildingFootPrint: boolean;
    DivideVertWallFactor: double;
    ExtFileSegment: TStringList;
    FloortoFloorHeight: double;
    Footprints: TObjectList;
    Length: double;
    NumFloors: integer;
    PerimDepth: Double;
    PlenumHeight: double;
    RaisedFloorHeight: double;
    RoofTiltAngle: double;
    Rotation: double;
    SuppressFloorMultipliers: boolean;
    SuppressRoofMultipliers: boolean;
    TmpNumFloors: Integer;
    TotalArea: double;
    UseExternalFile: Boolean;
    UseRelativeAngles: Boolean;
    UseReturnPlenum: boolean;
    UseVirtualPlenum: boolean;
    Width: double;
    aCustomTDD: T_EP_CustomTDD;
    constructor Create; reintroduce;
    function AddFootPrint(FootprintType: string): T_EP_Footprint;
    procedure AddPlenumZones;
    procedure DetermineZones;
    procedure Finalize; override;
    procedure ProcessCustomXYZ(aNode:TXmlNode);
    procedure ProcessDetachedShadingCustomXYZ(aNode:TXmlNode);
    procedure ToIDF; override;
  end;

implementation

uses Math, EnergyPlusZones,
  GlobalFuncs, XMLproc, xmlProcessing, PreprocSettings,
  EnergyPlusPPErrorMessages;

constructor T_EP_Geometry.Create;
begin
  inherited;
  Geometry := self;
  UseReturnPlenum := false;
  UseVirtualPlenum := false;
  Footprints := TObjectList.Create;
  ExtFileSegment := TStringList.Create;
end;

{ T_EP_Geometry }

function T_EP_Geometry.AddFootPrint(FootprintType: string): T_EP_Footprint;
var
  Footprint: T_EP_FootPrint;
begin
  Footprint := T_EP_Footprint.Create;
  Footprint.FootPrintType := FootPrintType;
  Footprints.Add(Footprint);
  result := Footprint;
end;

procedure T_EP_Geometry.AddPlenumZones;
var
  i: Integer;
  aZone: T_EP_Zone;
  iSurf: Integer;
  aSurf: T_EP_Surface;
  iVert: Integer;
  aVert: T_EP_Vector;
begin
  for i := 0 to zones.Count - 1 do
  begin
    aZone := T_EP_Zone(zones[i]);
    if aZone.Typ = ztNormal then
    begin
      for iSurf := 0 to aZone.Surfaces.Count - 1 do
      begin
        aSurf := T_EP_Surface(aZone.Surfaces[iSurf]);
        if aSurf.Typ = stWall then
        begin
          //reduce the wall heights
          for iVert := 0 to aSurf.Verts.Count - 1 do
          begin
            aVert := T_EP_Vector(aSurf.Verts[iVert]);

            // TODO, do something?
          end;

        end;
      end;
    end; //if aZone
  end;
end;

procedure T_EP_Geometry.CreateAtticZoning();
var
  Zone: T_EP_Zone;
  i: Integer;
  aSurf: T_EP_Surface;
  iZone: Integer;
  TopZone: T_EP_Zone;
  aTopSurf: T_EP_Surface;
  iVert: Integer;
begin
  //find the top zones for all the spaces
  if RoofTiltAngle = 0 then
  begin
    // TODO: DLM, why not Zones.Count-1? add comment if intentional
    for iZone := 0 to Zones.Count do
    begin
      TopZone := T_EP_Zone(Zones[iZone]);

      if (TopZone.FloorInfo.FloorNumber = TmpNumFloors) then
      begin
        //create new attic zone
        Zone := T_EP_Zone.Create;
        Zone.Name := TopZone.Name + '_Attic';
        Zone.ExcludeInTotalBuildingArea := True;
        Zone.XOrigin := TopZone.XOrigin;
        Zone.YOrigin := TopZone.YOrigin;
        Zone.ZOrigin := TopZone.ZOrigin + FloortoFloorHeight;
        Zone.CeilingHeight := AtticHeight;
        Zone.FloorInfo.FloorNumber := TopZone.FloorInfo.FloorNumber + 1;
        Zone.FloorInfo.FloorType := ftAttic;
        Zone.Typ := ztAttic;
        Zone.OccupiedConditioned := False;    //has to be set here!

        for i := 0 to TopZone.Surfaces.Count - 1 do
        begin
          aTopSurf := T_EP_Surface(TopZone.Surfaces[i]);

          aSurf := T_EP_Surface.Create;
          aSurf.ZoneName := Zone.Name;
          if aTopSurf.Typ = stWall then
            aSurf.Name := Zone.Name + '_Wall_' + inttostr(zone.surfaces.count + 1)
          else if aTopSurf.Typ = stCeiling then
            aSurf.Name := Zone.Name + '_Ceiling'
          else if aTopSurf.Typ = stFloor then
            aSurf.Name := Zone.Name + '_Floor';

          aSurf.SetType(aTopSurf.Typ);
          for iVert := 0 to aTopSurf.Verts.Count - 1 do
          begin
            if T_EP_Vector(aTopSurf.Verts[iVert]).k <> 0 then
              aSurf.Verts.AddVert(T_EP_Vector(aTopSurf.Verts[iVert]).i,
                T_EP_Vector(aTopSurf.Verts[iVert]).j,
                AtticHeight)
            else
              aSurf.Verts.AddVert(T_EP_Vector(aTopSurf.Verts[iVert]).i,
                T_EP_Vector(aTopSurf.Verts[iVert]).j,
                0.0)

          end;
          aSurf.Finalize();
          aSurf.FindWallProperties;
          Zone.AddSurface(aSurf);
        end;
      end;
    end;
  end
  else
  begin
    //roof tile angle is > 0
    for iZone := 0 to Zones.Count do
    begin
      TopZone := T_EP_Zone(Zones[iZone]);

      if (TopZone.FloorInfo.FloorNumber = TmpNumFloors) then
      begin
        //create new attic zone
        Zone := T_EP_Zone.Create;
        Zone.Name := TopZone.Name + '_Attic';
        Zone.ExcludeInTotalBuildingArea := True;
        Zone.XOrigin := TopZone.XOrigin;
        Zone.YOrigin := TopZone.YOrigin;
        Zone.ZOrigin := TopZone.ZOrigin + FloortoFloorHeight;
        Zone.CeilingHeight := AtticHeight;
        Zone.FloorInfo.FloorNumber := TopZone.FloorInfo.FloorNumber + 1;
        Zone.FloorInfo.FloorType := ftAttic;
        zone.Typ := ztAttic;
        Zone.OccupiedConditioned := False;    //has to be set here!

        for i := 0 to TopZone.Surfaces.Count - 1 do
        begin
          aTopSurf := T_EP_Surface(TopZone.Surfaces[i]);

          aSurf := T_EP_Surface.Create;
          aSurf.ZoneName := Zone.Name;
          if aTopSurf.Typ = stWall then
            aSurf.Name := Zone.Name + '_Wall_' + inttostr(zone.surfaces.count + 1)
          else if aTopSurf.Typ = stCeiling then
            aSurf.Name := Zone.Name + '_Ceiling'
          else if aTopSurf.Typ = stFloor then
            aSurf.Name := Zone.Name + '_Floor';

          aSurf.SetType(aTopSurf.Typ);
          for iVert := 0 to aTopSurf.Verts.Count - 1 do
          begin
            if T_EP_Vector(aTopSurf.Verts[iVert]).k <> 0 then
              aSurf.Verts.AddVert(T_EP_Vector(aTopSurf.Verts[iVert]).i,
                T_EP_Vector(aTopSurf.Verts[iVert]).j,
                AtticHeight)
            else
              aSurf.Verts.AddVert(T_EP_Vector(aTopSurf.Verts[iVert]).i,
                T_EP_Vector(aTopSurf.Verts[iVert]).j,
                0.0)

          end;
          aSurf.Finalize();
          aSurf.FindWallProperties;
          Zone.AddSurface(aSurf);
        end;
      end;
    end;
  end;
end;

procedure T_EP_Geometry.CreateMinimalZoning(aFootPrint: T_EP_Footprint;
  iFlr, Section: integer);
var
  Zone: T_EP_Zone;
  i: Integer;
  P0, P1, P2: T_EP_Point;
  theta2: double;
  aSurf: T_EP_Surface;
begin
  Zone := T_EP_Zone.Create;
  if aFootPrint.ZoneNameMoniker = '' then
    Zone.Name := 'ZN_1' + '_FLR_' + inttostr(iFlr) + '_SEC_' + IntToStr(section + 1)
  else
    Zone.Name := aFootPrint.ZoneNameMoniker + '_ZN_1_FLR_' + inttostr(iFlr);
  Zone.OccupiedConditioned := true;
  Zone.XOrigin := T_EP_Point(aFootprint.EP_Points[0]).X1;
  Zone.YOrigin := T_EP_Point(aFootprint.EP_Points[0]).Y1;
  Zone.ZOrigin := (iFlr - 1) * T_EP_Point(aFootprint.EP_Points[0]).Z1;
  Zone.CeilingHeight := T_EP_Point(aFootprint.EP_Points[0]).Z1;
  Zone.FloorInfo.FloorNumber := iFlr;
  // TODO: assign floor type


  zone.Typ := ztNormal;
  //if UseReturnPlenum then Zone.CreatePlenum;

  for i := 0 to aFootprint.EP_Points.Count - 1 do
  begin
    if i = 0 then
      P0 := T_EP_Point(aFootprint.EP_Points[aFootprint.EP_Points.Count - 1])
    else
      P0 := T_EP_Point(aFootprint.EP_Points[i - 1]);
    P1 := T_EP_Point(aFootprint.EP_Points[i]);
    if i = aFootprint.EP_Points.Count - 1 then
      P2 := T_EP_Point(aFootprint.EP_Points[0])
    else
      P2 := T_EP_Point(aFootprint.EP_Points[i + 1]);

    theta2 := vectorAngle(p1, p2);
    T_EP_Point(aFootprint.EP_Points[i]).Angle := theta2;
  end;

  for i := 0 to aFootprint.EP_Points.Count - 1 do
  begin
    if i = 0 then
      P0 := T_EP_Point(aFootprint.EP_Points[aFootprint.EP_Points.Count - 1])
    else
      P0 := T_EP_Point(aFootprint.EP_Points[i - 1]);

    P1 := T_EP_Point(aFootprint.EP_Points[i]);

    if i = aFootprint.EP_Points.Count - 1 then
      P2 := T_EP_Point(aFootprint.EP_Points[0])
    else
      P2 := T_EP_Point(aFootprint.EP_Points[i + 1]);

    aSurf := T_EP_Surface.Create;
    aSurf.ZoneName := Zone.Name;
    aSurf.Name := Zone.Name + '_Wall_' + inttostr(zone.surfaces.count + 1);
    aSurf.SetType(stWall);
    aSurf.Verts.AddVert(p1.x1 - Zone.XOrigin,
      P1.Y1 - Zone.YOrigin,
      P1.Z1);
    aSurf.Verts.AddVert(p1.x1 - Zone.XOrigin,
      P1.Y1 - Zone.YOrigin,
      0.0);
    aSurf.Verts.AddVert(P2.x1 - Zone.XOrigin,
      P2.Y1 - Zone.YOrigin,
      0.0);
    aSurf.Verts.AddVert(P2.x1 - Zone.XOrigin,
      P2.Y1 - Zone.YOrigin,
      P1.Z1);
    aSurf.Finalize();
    aSurf.FindWallProperties;
    Zone.AddSurface(aSurf);
  end;

  //add floor to core
  aSurf := T_EP_Surface.Create;
  aSurf.ZoneName := Zone.Name;
  aSurf.Name := Zone.Name + '_Floor';
  aSurf.SetType(stFloor);
  for i := aFootprint.EP_Points.Count - 1 downto 0 do
  begin
    if i = 0 then
      P0 := T_EP_Point(aFootprint.EP_Points[aFootprint.EP_Points.Count - 1])
    else
      P0 := T_EP_Point(aFootprint.EP_Points[i - 1]);
    P1 := T_EP_Point(aFootprint.EP_Points[i]);
    if i = aFootprint.EP_Points.Count - 1 then
      P2 := T_EP_Point(aFootprint.EP_Points[0])
    else
      P2 := T_EP_Point(aFootprint.EP_Points[i + 1]);

    if (p1.Angle = p0.Angle) then
    begin
      //wall is the same angle as previous wall - therefore is in same plane
      continue;
    end;

    aSurf.Verts.AddVert(P1.X1 - Zone.XOrigin,
                        P1.Y1 - Zone.YOrigin,
                        0.0);
  end;
  aSurf.Finalize();
  aSurf.FindWallProperties;
  Zone.AddSurface(aSurf);

  //add ceiling to core
  aSurf := T_EP_Surface.Create;
  aSurf.ZoneName := Zone.Name;
  aSurf.Name := Zone.Name + '_Ceiling';
  aSurf.SetType(stCeiling);
  for i := 0 to aFootprint.EP_Points.Count - 1 do
  begin
    if i = 0 then
      P0 := T_EP_Point(aFootprint.EP_Points[aFootprint.EP_Points.Count - 1])
    else
      P0 := T_EP_Point(aFootprint.EP_Points[i - 1]);
      P1 := T_EP_Point(aFootprint.EP_Points[i]);
    if i = aFootprint.EP_Points.Count - 1 then
      P2 := T_EP_Point(aFootprint.EP_Points[0])
    else
      P2 := T_EP_Point(aFootprint.EP_Points[i + 1]);

    if (p1.Angle = p0.Angle) then
    begin
      //wall is the same angle as previous wall - therefore is in same plane
      continue;
    end;

    aSurf.Verts.AddVert(P1.X1 - Zone.XOrigin,
                        P1.Y1 - Zone.YOrigin,
                        P1.Z1);
  end;
  aSurf.Finalize();
  aSurf.FindWallProperties;
  Zone.AddSurface(aSurf);
end;

procedure T_EP_Geometry.DetermineZones;
var
  AspectRatio: double;
  i: Integer;
  Zone: T_EP_Zone;
  iFlr: Integer;
  iFP: Integer;
  aFootprint: T_EP_FootPrint;
  multBy: Integer;
  newFootPrint: T_EP_FootPrint;
  iSec: Integer;
  dOrigPerimDepth: double;
  cyBLCx: double;
  cyBLCy: double;
  floorMultiplier: Boolean;
begin
  for iFP := 0 to Footprints.Count - 1 do
  begin
    //go through and create minimum zoning/core zoning for each template
    aFootprint := T_EP_Footprint(Footprints[iFP]);
    if SameText(aFootprint.FootPrintType, 'Rectangle') then
    begin
      if aFootprint.Width1 = 0 then
        AspectRatio := aFootprint.Length1
      else
        AspectRatio := aFootprint.Length1 / aFootprint.Width1;

      if TotalArea = 0 then
      begin
        TotalArea := aFootprint.Length1 * aFootprint.Width1 * NumFloors;
      end;

      aFootprint.FloorPlateArea := 0;
      if NumFloors <> 0 then
        aFootprint.FloorPlateArea := TotalArea / NumFloors
      else
      begin
        T_EP_PPErrorMessage.AddErrorMessage(esFatal, 'Number of floors was 0');
        //set values here to some arbitrary value to exit gracefully
        NumFloors := 1;
        aFootprint.FloorPlateArea := 1;
      end;



      Length := sqrt(aFootprint.FloorPlateArea * AspectRatio);
      Width := sqrt(aFootprint.FloorPlateArea / AspectRatio);

      if SameText(aFootprint.ZoneLayout, 'Minimum Zones') then
      begin
        newFootPrint := AddFootPrint('Custom');
        newFootPrint.ZoneLayout := 'Minimum Zones';
        if aFootprint.ZoneNameMoniker <> '' then
          newFootPrint.ZoneNameMoniker := aFootprint.ZoneNameMoniker + '_1';
        if aFootprint.ZoneDescription <> '' then
          newFootPrint.ZoneDescription := aFootprint.ZoneDescription + '_1';
        newFootPrint.FloorNum := aFootprint.FloorNum;
        newFootPrint.FloorToFloorHeight := aFootprint.FloorToFloorHeight;
        newFootPrint.AddPoint(0, 0, FloortoFloorHeight);
        newFootPrint.AddPoint(Length, 0, FloortoFloorHeight);
        newFootPrint.AddPoint(Length, Width, FloortoFloorHeight);
        newFootPrint.AddPoint(0, Width, FloortoFloorHeight);

        //disable the original footprint
        aFootprint.Enabled := false;
      end
      else if SameText(aFootprint.ZoneLayout, 'Perimeter and Core') then
      begin
        //check if the perimeter depth will fit into the area
        if 2 * PerimDepth > 0.9 * Width then
        begin
          dOrigPerimDepth := PerimDepth;
          while (2 * PerimDepth > 0.9 * Width) do
          begin
            PerimDepth := PerimDepth / 1.25;
          end;
          T_EP_PPErrorMessage.AddErrorMessage(esWarning, 'Problem with the width for requested floor area and ' +
            'perimeter depth.  Reduced perimeter depth from ' +
            floattostr(dOrigPerimDepth) + ' to ' + FloatToStr(PerimDepth) +
            ' to accomodate perimeter and core layout.');
        end;
        if 2 * PerimDepth > 0.9 * Length then
        begin
          dOrigPerimDepth := PerimDepth;
          while (2 * PerimDepth > 0.9 * Length) do
          begin
            PerimDepth := PerimDepth / 1.25;
          end;
          T_EP_PPErrorMessage.AddErrorMessage(esWarning, 'Problem with the length for requested floor area and ' +
            'perimeter depth.  Reduced perimeter depth from ' +
            floattostr(dOrigPerimDepth) + ' to ' + FloatToStr(PerimDepth) +
            ' to accomodate perimeter and core layout.');
        end;

        //create perimeter zoning
        newFootPrint := AddFootPrint('Custom');
        newFootPrint.ZoneLayout := 'Minimum Zones';
        if aFootprint.ZoneNameMoniker <> '' then
          newFootPrint.ZoneNameMoniker := aFootprint.ZoneNameMoniker + '_1';
        if aFootprint.ZoneDescription <> '' then
          newFootPrint.ZoneDescription := aFootprint.ZoneDescription + '_1';
        newFootPrint.FloorNum := aFootprint.FloorNum;
        newFootPrint.FloorToFloorHeight := aFootprint.FloorToFloorHeight;
        newFootPrint.AddPoint(0,
          0,
          FloortoFloorHeight);
        newFootPrint.AddPoint(Length,
          0,
          FloortoFloorHeight);
        newFootPrint.AddPoint(Length - PerimDepth,
          PerimDepth,
          FloortoFloorHeight);
        newFootPrint.AddPoint(PerimDepth,
          PerimDepth,
          FloortoFloorHeight);

        newFootPrint := AddFootPrint('Custom');
        newFootPrint.ZoneLayout := 'Minimum Zones';
        if aFootprint.ZoneNameMoniker <> '' then
          newFootPrint.ZoneNameMoniker := aFootprint.ZoneNameMoniker + '_2';
        if aFootprint.ZoneDescription <> '' then
          newFootPrint.ZoneDescription := aFootprint.ZoneDescription + '_2';
        newFootPrint.FloorNum := aFootprint.FloorNum;
        newFootPrint.FloorToFloorHeight := aFootprint.FloorToFloorHeight;
        newFootPrint.AddPoint(Length,
          0,
          FloortoFloorHeight);
        newFootPrint.AddPoint(Length,
          Width,
          FloortoFloorHeight);
        newFootPrint.AddPoint(Length - PerimDepth,
          Width - PerimDepth,
          FloortoFloorHeight);
        newFootPrint.AddPoint(Length - PerimDepth,
          PerimDepth,
          FloortoFloorHeight);

        newFootPrint := AddFootPrint('Custom');
        newFootPrint.ZoneLayout := 'Minimum Zones';
        if aFootprint.ZoneNameMoniker <> '' then
          newFootPrint.ZoneNameMoniker := aFootprint.ZoneNameMoniker + '_3';
        if aFootprint.ZoneDescription <> '' then
          newFootPrint.ZoneDescription := aFootprint.ZoneDescription + '_3';
        newFootPrint.FloorNum := aFootprint.FloorNum;
        newFootPrint.FloorToFloorHeight := aFootprint.FloorToFloorHeight;
        newFootPrint.AddPoint(PerimDepth,
          Width - PerimDepth,
          FloortoFloorHeight);
        newFootPrint.AddPoint(Length - PerimDepth,
          Width - PerimDepth,
          FloortoFloorHeight);
        newFootPrint.AddPoint(Length,
          Width,
          FloortoFloorHeight);
        newFootPrint.AddPoint(0,
          Width,
          FloortoFloorHeight);

        newFootPrint := AddFootPrint('Custom');
        newFootPrint.ZoneLayout := 'Minimum Zones';
        if aFootprint.ZoneNameMoniker <> '' then
          newFootPrint.ZoneNameMoniker := aFootprint.ZoneNameMoniker + '_4';
        if aFootprint.ZoneDescription <> '' then
          newFootPrint.ZoneDescription := aFootprint.ZoneDescription + '_4';
        newFootPrint.FloorNum := aFootprint.FloorNum;
        newFootPrint.FloorToFloorHeight := aFootprint.FloorToFloorHeight;
        newFootPrint.AddPoint(0,
          0,
          FloortoFloorHeight);
        newFootPrint.AddPoint(PerimDepth,
          PerimDepth,
          FloortoFloorHeight);
        newFootPrint.AddPoint(PerimDepth,
          Width - PerimDepth,
          FloortoFloorHeight);
        newFootPrint.AddPoint(0,
          Width,
          FloortoFloorHeight);

        newFootPrint := AddFootPrint('Custom');
        newFootPrint.ZoneLayout := 'Minimum Zones';
        if aFootprint.ZoneNameMoniker <> '' then
          newFootPrint.ZoneNameMoniker := aFootprint.ZoneNameMoniker + '_5';
        if aFootprint.ZoneDescription <> '' then
          newFootPrint.ZoneDescription := aFootprint.ZoneDescription + '_5';
        newFootPrint.FloorNum := aFootprint.FloorNum;
        newFootPrint.FloorToFloorHeight := aFootprint.FloorToFloorHeight;
        newFootPrint.AddPoint(PerimDepth,
          PerimDepth,
          FloortoFloorHeight);
        newFootPrint.AddPoint(Length - PerimDepth,
          PerimDepth,
          FloortoFloorHeight);
        newFootPrint.AddPoint(Length - PerimDepth,
          Width - PerimDepth,
          FloortoFloorHeight);
        newFootPrint.AddPoint(PerimDepth,
          Width - PerimDepth,
          FloortoFloorHeight);

        //disable the original footprint
        aFootprint.Enabled := false;
      end;
    end
    else if SameText(aFootprint.FootPrintType, 'Courtyard') then
    begin
      Length := aFootprint.Length1;
      Width := aFootprint.Width1;

      if SameText(aFootprint.ZoneLayout, 'Minimum Zones') then
      begin
        //these are the widths of the court yard.
        cyBLCx := (aFootprint.Length1 - aFootprint.Length2) / 2;
        cyBLCy := (aFootprint.Width1 - aFootprint.Width2) / 2;

        //check if the perimeter depth will fit into the area
        if 2 * PerimDepth > (0.9 * cyBLCy) then
        begin
          dOrigPerimDepth := PerimDepth;
          while (2 * PerimDepth > (0.9 * cyBLCy)) do
          begin
            PerimDepth := PerimDepth / 1.25;
          end;
          T_EP_PPErrorMessage.AddErrorMessage(esWarning, 'Problem with the width for requested floor area and ' +
            'perimeter depth.  Reduced perimeter depth from ' +
            floattostr(dOrigPerimDepth) + ' to ' + FloatToStr(PerimDepth) +
            ' to accomodate perimeter and core layout.');
        end;
        if 2 * PerimDepth > (0.9 * cyBLCx) then
        begin
          dOrigPerimDepth := PerimDepth;
          while (2 * PerimDepth > (0.9 * cyBLCx)) do
          begin
            PerimDepth := PerimDepth / 1.25;
          end;
          T_EP_PPErrorMessage.AddErrorMessage(esWarning, 'Problem with the length for requested floor area and ' +
            'perimeter depth.  Reduced perimeter depth from ' +
            floattostr(dOrigPerimDepth) + ' to ' + FloatToStr(PerimDepth) +
            ' to accomodate perimeter and core layout.');
        end;

        newFootPrint := AddFootPrint('Custom');
        newFootPrint.ZoneLayout := 'Minimum Zones';
        if aFootprint.ZoneNameMoniker <> '' then
          newFootPrint.ZoneNameMoniker := aFootprint.ZoneNameMoniker + '_1';
        if aFootprint.ZoneDescription <> '' then
          newFootPrint.ZoneDescription := aFootprint.ZoneDescription + '_1';
        newFootPrint.FloorNum := aFootprint.FloorNum;
        newFootPrint.FloorToFloorHeight := aFootprint.FloorToFloorHeight;
        newFootPrint.AddPoint(0,
          0,
          FloortoFloorHeight);
        newFootPrint.AddPoint(aFootprint.Length1,
          0,
          FloortoFloorHeight);
        newFootPrint.AddPoint(aFootprint.Length1,
          cyBLCy,
          FloortoFloorHeight);
        newFootPrint.AddPoint(aFootprint.Length1 - cyBLCx,
          cyBLCy,
          FloortoFloorHeight);
        newFootPrint.AddPoint(cyBLCx,
          cyBLCy,
          FloortoFloorHeight);
        newFootPrint.AddPoint(0,
          cyBLCy,
          FloortoFloorHeight);

        newFootPrint := AddFootPrint('Custom');
        newFootPrint.ZoneLayout := 'Minimum Zones';
        if aFootprint.ZoneNameMoniker <> '' then
          newFootPrint.ZoneNameMoniker := aFootprint.ZoneNameMoniker + '_2';
        if aFootprint.ZoneDescription <> '' then
          newFootPrint.ZoneDescription := aFootprint.ZoneDescription + '_2';
        newFootPrint.FloorNum := aFootprint.FloorNum;
        newFootPrint.FloorToFloorHeight := aFootprint.FloorToFloorHeight;
        newFootPrint.AddPoint(aFootprint.Length1 - cyBLCx,
          cyBLCy,
          FloortoFloorHeight);
        newFootPrint.AddPoint(aFootprint.Length1,
          cyBLCy,
          FloortoFloorHeight);
        newFootPrint.AddPoint(aFootprint.Length1,
          aFootprint.Width1 - cyBLCy,
          FloortoFloorHeight);
        newFootPrint.AddPoint(aFootprint.Length1 - cyBLCx,
          aFootprint.Width1 - cyBLCy,
          FloortoFloorHeight);

        newFootPrint := AddFootPrint('Custom');
        newFootPrint.ZoneLayout := 'Minimum Zones';
        if aFootprint.ZoneNameMoniker <> '' then
          newFootPrint.ZoneNameMoniker := aFootprint.ZoneNameMoniker + '_3';
        if aFootprint.ZoneDescription <> '' then
          newFootPrint.ZoneDescription := aFootprint.ZoneDescription + '_3';
        newFootPrint.FloorNum := aFootprint.FloorNum;
        newFootPrint.FloorToFloorHeight := aFootprint.FloorToFloorHeight;
        newFootPrint.AddPoint(0,
          aFootprint.Width1 - cyBLCy,
          FloortoFloorHeight);
        newFootPrint.AddPoint(cyBLCx,
          aFootprint.Width1 - cyBLCy,
          FloortoFloorHeight);
        newFootPrint.AddPoint(aFootprint.Length1 - cyBLCx,
          aFootprint.Width1 - cyBLCy,
          FloortoFloorHeight);
        newFootPrint.AddPoint(aFootprint.Length1,
          aFootprint.Width1 - cyBLCy,
          FloortoFloorHeight);
        newFootPrint.AddPoint(aFootprint.Length1,
          aFootprint.Width1,
          FloortoFloorHeight);
        newFootPrint.AddPoint(0,
          aFootprint.Width1,
          FloortoFloorHeight);

        newFootPrint := AddFootPrint('Custom');
        newFootPrint.ZoneLayout := 'Minimum Zones';
        if aFootprint.ZoneNameMoniker <> '' then
          newFootPrint.ZoneNameMoniker := aFootprint.ZoneNameMoniker + '_4';
        if aFootprint.ZoneDescription <> '' then
          newFootPrint.ZoneDescription := aFootprint.ZoneDescription + '_4';
        newFootPrint.FloorNum := aFootprint.FloorNum;
        newFootPrint.FloorToFloorHeight := aFootprint.FloorToFloorHeight;
        newFootPrint.AddPoint(0,
          cyBLCy,
          FloortoFloorHeight);
        newFootPrint.AddPoint(cyBLCx,
          cyBLCy,
          FloortoFloorHeight);
        newFootPrint.AddPoint(cyBLCx,
          aFootprint.Width1 - cyBLCy,
          FloortoFloorHeight);
        newFootPrint.AddPoint(0,
          aFootprint.Width1 - cyBLCy,
          FloortoFloorHeight);

        //disable the original footprint
        aFootprint.Enabled := false;
      end
      else if SameText(aFootprint.ZoneLayout, 'Perimeter and Core') then
      begin
        cyBLCx := (aFootprint.Length1 - aFootprint.Length2) / 2;
        cyBLCy := (aFootprint.Width1 - aFootprint.Width2) / 2;

        //check if the perimeter depth will fit into the area
        if 2 * PerimDepth > (0.9 * cyBLCy) then
        begin
          dOrigPerimDepth := PerimDepth;
          while (2 * PerimDepth > (0.9 * cyBLCy)) do
          begin
            PerimDepth := PerimDepth / 1.25;
          end;
          T_EP_PPErrorMessage.AddErrorMessage(esWarning, 'Problem with the width for requested floor area and ' +
            'perimeter depth.  Reduced perimeter depth from ' +
            floattostr(dOrigPerimDepth) + ' to ' + FloatToStr(PerimDepth) +
            ' to accomodate perimeter and core layout.');
        end;
        if 2 * PerimDepth > (0.9 * cyBLCx) then
        begin
          dOrigPerimDepth := PerimDepth;
          while (2 * PerimDepth > (0.9 * cyBLCx)) do
          begin
            PerimDepth := PerimDepth / 1.25;
          end;
          T_EP_PPErrorMessage.AddErrorMessage(esWarning, 'Problem with the length for requested floor area and ' +
            'perimeter depth.  Reduced perimeter depth from ' +
            floattostr(dOrigPerimDepth) + ' to ' + FloatToStr(PerimDepth) +
            ' to accomodate perimeter and core layout.');
        end;

        newFootPrint := AddFootPrint('Custom');
        newFootPrint.ZoneLayout := 'Minimum Zones';
        if aFootprint.ZoneNameMoniker <> '' then
          newFootPrint.ZoneNameMoniker := aFootprint.ZoneNameMoniker + '_1';
        if aFootprint.ZoneDescription <> '' then
          newFootPrint.ZoneDescription := aFootprint.ZoneDescription + '_1';
        newFootPrint.FloorNum := aFootprint.FloorNum;
        newFootPrint.FloorToFloorHeight := aFootprint.FloorToFloorHeight;
        newFootPrint.AddPoint(0,
          0,
          FloortoFloorHeight);
        newFootPrint.AddPoint(aFootprint.Length1,
          0,
          FloortoFloorHeight);
        newFootPrint.AddPoint(aFootprint.Length1 - PerimDepth,
          PerimDepth,
          FloortoFloorHeight);
        newFootPrint.AddPoint(PerimDepth,
          PerimDepth,
          FloortoFloorHeight);

        newFootPrint := AddFootPrint('Custom');
        newFootPrint.ZoneLayout := 'Minimum Zones';
        if aFootprint.ZoneNameMoniker <> '' then
          newFootPrint.ZoneNameMoniker := aFootprint.ZoneNameMoniker + '_2';
        if aFootprint.ZoneDescription <> '' then
          newFootPrint.ZoneDescription := aFootprint.ZoneDescription + '_2';
        newFootPrint.FloorNum := aFootprint.FloorNum;
        newFootPrint.FloorToFloorHeight := aFootprint.FloorToFloorHeight;
        newFootPrint.AddPoint(aFootprint.Length1 - PerimDepth,
          PerimDepth,
          FloortoFloorHeight);
        newFootPrint.AddPoint(aFootprint.Length1,
          0,
          FloortoFloorHeight);
        newFootPrint.AddPoint(aFootprint.Length1,
          aFootprint.Width1,
          FloortoFloorHeight);
        newFootPrint.AddPoint(aFootprint.Length1 - PerimDepth,
          aFootprint.Width1 - PerimDepth,
          FloortoFloorHeight);

        newFootPrint := AddFootPrint('Custom');
        newFootPrint.ZoneLayout := 'Minimum Zones';
        if aFootprint.ZoneNameMoniker <> '' then
          newFootPrint.ZoneNameMoniker := aFootprint.ZoneNameMoniker + '_3';
        if aFootprint.ZoneDescription <> '' then
          newFootPrint.ZoneDescription := aFootprint.ZoneDescription + '_3';
        newFootPrint.FloorNum := aFootprint.FloorNum;
        newFootPrint.FloorToFloorHeight := aFootprint.FloorToFloorHeight;
        newFootPrint.AddPoint(PerimDepth,
          aFootprint.Width1 - PerimDepth,
          FloortoFloorHeight);
        newFootPrint.AddPoint(aFootprint.Length1 - PerimDepth,
          aFootprint.Width1 - PerimDepth,
          FloortoFloorHeight);
        newFootPrint.AddPoint(aFootprint.Length1,
          aFootprint.Width1,
          FloortoFloorHeight);
        newFootPrint.AddPoint(0,
          aFootprint.Width1,
          FloortoFloorHeight);

        newFootPrint := AddFootPrint('Custom');
        newFootPrint.ZoneLayout := 'Minimum Zones';
        if aFootprint.ZoneNameMoniker <> '' then
          newFootPrint.ZoneNameMoniker := aFootprint.ZoneNameMoniker + '_4';
        if aFootprint.ZoneDescription <> '' then
          newFootPrint.ZoneDescription := aFootprint.ZoneDescription + '_4';
        newFootPrint.FloorNum := aFootprint.FloorNum;
        newFootPrint.FloorToFloorHeight := aFootprint.FloorToFloorHeight;
        newFootPrint.AddPoint(0,
          0,
          FloortoFloorHeight);
        newFootPrint.AddPoint(PerimDepth,
          PerimDepth,
          FloortoFloorHeight);
        newFootPrint.AddPoint(PerimDepth,
          aFootprint.Width1 - PerimDepth,
          FloortoFloorHeight);
        newFootPrint.AddPoint(0,
          aFootprint.Width1,
          FloortoFloorHeight);

        newFootPrint := AddFootPrint('Custom');
        newFootPrint.ZoneLayout := 'Minimum Zones';
        if aFootprint.ZoneNameMoniker <> '' then
          newFootPrint.ZoneNameMoniker := aFootprint.ZoneNameMoniker + '_5';
        if aFootprint.ZoneDescription <> '' then
          newFootPrint.ZoneDescription := aFootprint.ZoneDescription + '_5';
        newFootPrint.FloorNum := aFootprint.FloorNum;
        newFootPrint.FloorToFloorHeight := aFootprint.FloorToFloorHeight;
        newFootPrint.AddPoint(PerimDepth,
          PerimDepth,
          FloortoFloorHeight);
        newFootPrint.AddPoint(aFootprint.Length1 - PerimDepth,
          PerimDepth,
          FloortoFloorHeight);
        newFootPrint.AddPoint(aFootprint.Length1 - cyBLCx + PerimDepth,
          cyBLCy - PerimDepth,
          FloortoFloorHeight);
        newFootPrint.AddPoint(cyBLCx - PerimDepth,
          cyBLCy - PerimDepth,
          FloortoFloorHeight);

        newFootPrint := AddFootPrint('Custom');
        newFootPrint.ZoneLayout := 'Minimum Zones';
        if aFootprint.ZoneNameMoniker <> '' then
          newFootPrint.ZoneNameMoniker := aFootprint.ZoneNameMoniker + '_6';
        if aFootprint.ZoneDescription <> '' then
          newFootPrint.ZoneDescription := aFootprint.ZoneDescription + '_6';
        newFootPrint.FloorNum := aFootprint.FloorNum;
        newFootPrint.FloorToFloorHeight := aFootprint.FloorToFloorHeight;
        newFootPrint.AddPoint(aFootprint.Length1 - cyBLCx + PerimDepth,
          cyBLCy - PerimDepth,
          FloortoFloorHeight);
        newFootPrint.AddPoint(aFootprint.Length1 - PerimDepth,
          PerimDepth,
          FloortoFloorHeight);
        newFootPrint.AddPoint(aFootprint.Length1 - PerimDepth,
          aFootprint.Width1 - PerimDepth,
          FloortoFloorHeight);
        newFootPrint.AddPoint(aFootprint.Length1 - cyBLCx + PerimDepth,
          aFootprint.Width1 - cyBLCy + PerimDepth,
          FloortoFloorHeight);

        newFootPrint := AddFootPrint('Custom');
        newFootPrint.ZoneLayout := 'Minimum Zones';
        if aFootprint.ZoneNameMoniker <> '' then
          newFootPrint.ZoneNameMoniker := aFootprint.ZoneNameMoniker + '_7';
        if aFootprint.ZoneDescription <> '' then
          newFootPrint.ZoneDescription := aFootprint.ZoneDescription + '_7';
        newFootPrint.FloorNum := aFootprint.FloorNum;
        newFootPrint.FloorToFloorHeight := aFootprint.FloorToFloorHeight;
        newFootPrint.AddPoint(cyBLCx - PerimDepth,
          aFootprint.Width1 - cyBLCy + PerimDepth,
          FloortoFloorHeight);
        newFootPrint.AddPoint(aFootprint.Length1 - cyBLCx + PerimDepth,
          aFootprint.Width1 - cyBLCy + PerimDepth,
          FloortoFloorHeight);
        newFootPrint.AddPoint(aFootprint.Length1 - PerimDepth,
          aFootprint.Width1 - PerimDepth,
          FloortoFloorHeight);
        newFootPrint.AddPoint(PerimDepth,
          aFootprint.Width1 - PerimDepth,
          FloortoFloorHeight);

        newFootPrint := AddFootPrint('Custom');
        newFootPrint.ZoneLayout := 'Minimum Zones';
        if aFootprint.ZoneNameMoniker <> '' then
          newFootPrint.ZoneNameMoniker := aFootprint.ZoneNameMoniker + '_8';
        if aFootprint.ZoneDescription <> '' then
          newFootPrint.ZoneDescription := aFootprint.ZoneDescription + '_8';
        newFootPrint.FloorNum := aFootprint.FloorNum;
        newFootPrint.FloorToFloorHeight := aFootprint.FloorToFloorHeight;
        newFootPrint.AddPoint(PerimDepth,
          PerimDepth,
          FloortoFloorHeight);
        newFootPrint.AddPoint(cyBLCx - PerimDepth,
          cyBLCy - PerimDepth,
          FloortoFloorHeight);
        newFootPrint.AddPoint(cyBLCx - PerimDepth,
          aFootprint.Width1 - cyBLCy + PerimDepth,
          FloortoFloorHeight);
        newFootPrint.AddPoint(PerimDepth,
          aFootprint.Width1 - PerimDepth,
          FloortoFloorHeight);

        newFootPrint := AddFootPrint('Custom');
        newFootPrint.ZoneLayout := 'Minimum Zones';
        if aFootprint.ZoneNameMoniker <> '' then
          newFootPrint.ZoneNameMoniker := aFootprint.ZoneNameMoniker + '_9';
        if aFootprint.ZoneDescription <> '' then
          newFootPrint.ZoneDescription := aFootprint.ZoneDescription + '_9';
        newFootPrint.FloorNum := aFootprint.FloorNum;
        newFootPrint.FloorToFloorHeight := aFootprint.FloorToFloorHeight;
        newFootPrint.AddPoint(cyBLCx - PerimDepth,
          cyBLCy - PerimDepth,
          FloortoFloorHeight);
        newFootPrint.AddPoint(aFootprint.Length1 - cyBLCx + PerimDepth,
          cyBLCy - PerimDepth,
          FloortoFloorHeight);
        newFootPrint.AddPoint(aFootprint.Length1 - cyBLCx,
          cyBLCy,
          FloortoFloorHeight);
        newFootPrint.AddPoint(cyBLCx,
          cyBLCy,
          FloortoFloorHeight);

        newFootPrint := AddFootPrint('Custom');
        newFootPrint.ZoneLayout := 'Minimum Zones';
        if aFootprint.ZoneNameMoniker <> '' then
          newFootPrint.ZoneNameMoniker := aFootprint.ZoneNameMoniker + '_10';
        if aFootprint.ZoneDescription <> '' then
          newFootPrint.ZoneDescription := aFootprint.ZoneDescription + '_10';
        newFootPrint.FloorNum := aFootprint.FloorNum;
        newFootPrint.FloorToFloorHeight := aFootprint.FloorToFloorHeight;
        newFootPrint.AddPoint(aFootprint.Length1 - cyBLCx + PerimDepth,
          cyBLCy - PerimDepth,
          FloortoFloorHeight);
        newFootPrint.AddPoint(aFootprint.Length1 - cyBLCx + PerimDepth,
          aFootprint.Width1 - cyBLCy + PerimDepth,
          FloortoFloorHeight);
        newFootPrint.AddPoint(aFootprint.Length1 - cyBLCx,
          aFootprint.Width1 - cyBLCy,
          FloortoFloorHeight);
        newFootPrint.AddPoint(aFootprint.Length1 - cyBLCx,
          cyBLCy,
          FloortoFloorHeight);

        newFootPrint := AddFootPrint('Custom');
        newFootPrint.ZoneLayout := 'Minimum Zones';
        if aFootprint.ZoneNameMoniker <> '' then
          newFootPrint.ZoneNameMoniker := aFootprint.ZoneNameMoniker + '_11';
        if aFootprint.ZoneDescription <> '' then
          newFootPrint.ZoneDescription := aFootprint.ZoneDescription + '_11';
        newFootPrint.FloorNum := aFootprint.FloorNum;
        newFootPrint.FloorToFloorHeight := aFootprint.FloorToFloorHeight;
        newFootPrint.AddPoint(cyBLCx,
          aFootprint.Width1 - cyBLCy,
          FloortoFloorHeight);
        newFootPrint.AddPoint(aFootprint.Length1 - cyBLCx,
          aFootprint.Width1 - cyBLCy,
          FloortoFloorHeight);
        newFootPrint.AddPoint(aFootprint.Length1 - cyBLCx + PerimDepth,
          aFootprint.Width1 - cyBLCy + PerimDepth,
          FloortoFloorHeight);
        newFootPrint.AddPoint(cyBLCx - PerimDepth,
          aFootprint.Width1 - cyBLCy + PerimDepth,
          FloortoFloorHeight);

        newFootPrint := AddFootPrint('Custom');
        newFootPrint.ZoneLayout := 'Minimum Zones';
        if aFootprint.ZoneNameMoniker <> '' then
          newFootPrint.ZoneNameMoniker := aFootprint.ZoneNameMoniker + '_12';
        if aFootprint.ZoneDescription <> '' then
          newFootPrint.ZoneDescription := aFootprint.ZoneDescription + '_12';
        newFootPrint.FloorNum := aFootprint.FloorNum;
        newFootPrint.FloorToFloorHeight := aFootprint.FloorToFloorHeight;
        newFootPrint.AddPoint(cyBLCx - PerimDepth,
          cyBLCy - PerimDepth,
          FloortoFloorHeight);
        newFootPrint.AddPoint(cyBLCx,
          cyBLCy,
          FloortoFloorHeight);
        newFootPrint.AddPoint(cyBLCx,
          aFootprint.Width1 - cyBLCy,
          FloortoFloorHeight);
        newFootPrint.AddPoint(cyBLCx - PerimDepth,
          aFootprint.Width1 - cyBLCy + PerimDepth,
          FloortoFloorHeight);

        //disable the original footprint
        aFootprint.Enabled := false;
      end;
    end
    else if SameText(aFootprint.FootPrintType, 'L-Shape') then
    begin
      //the area has no use in this format -- todo: make it a scaler
      Length := aFootprint.Length1; //these are not the real values
      Width := aFootprint.Width1;

      if SameText(aFootprint.ZoneLayout, 'Minimum Zones') then
      begin
        //create three seperate zones
        newFootPrint := AddFootPrint('Custom');
        newFootPrint.ZoneLayout := 'Minimum Zones';
        if aFootprint.ZoneNameMoniker <> '' then
          newFootPrint.ZoneNameMoniker := aFootprint.ZoneNameMoniker + '_1';
        if aFootprint.ZoneDescription <> '' then
          newFootPrint.ZoneDescription := aFootprint.ZoneDescription + '_1';
        newFootPrint.FloorNum := aFootprint.FloorNum;
        newFootPrint.FloorToFloorHeight := aFootprint.FloorToFloorHeight;
        newFootPrint.AddPoint(0, 0, FloortoFloorHeight);
        newFootPrint.AddPoint(aFootprint.End2, 0, FloortoFloorHeight);
        newFootPrint.AddPoint(aFootprint.End2, aFootprint.End1, FloortoFloorHeight);
        newFootPrint.AddPoint(0, aFootprint.End1, FloortoFloorHeight);

        newFootPrint := AddFootPrint('Custom');
        newFootPrint.ZoneLayout := 'Minimum Zones';
        if aFootprint.ZoneNameMoniker <> '' then
          newFootPrint.ZoneNameMoniker := aFootprint.ZoneNameMoniker + '_2';
        if aFootprint.ZoneDescription <> '' then
          newFootPrint.ZoneDescription := aFootprint.ZoneDescription + '_2';
        newFootPrint.FloorNum := aFootprint.FloorNum;
        newFootPrint.FloorToFloorHeight := aFootprint.FloorToFloorHeight;
        newFootPrint.AddPoint(aFootprint.End2, 0, FloortoFloorHeight);
        newFootPrint.AddPoint(aFootprint.Length1, 0, FloortoFloorHeight);
        newFootPrint.AddPoint(aFootprint.Length1, aFootprint.End1, FloortoFloorHeight);
        newFootPrint.AddPoint(aFootprint.End2, aFootprint.End1, FloortoFloorHeight);

        newFootPrint := AddFootPrint('Custom');
        newFootPrint.ZoneLayout := 'Minimum Zones';
        if aFootprint.ZoneNameMoniker <> '' then
          newFootPrint.ZoneNameMoniker := aFootprint.ZoneNameMoniker + '_3';
        if aFootprint.ZoneDescription <> '' then
          newFootPrint.ZoneDescription := aFootprint.ZoneDescription + '_3';
        newFootPrint.FloorNum := aFootprint.FloorNum;
        newFootPrint.FloorToFloorHeight := aFootprint.FloorToFloorHeight;
        newFootPrint.AddPoint(0, aFootprint.End1, FloortoFloorHeight);
        newFootPrint.AddPoint(aFootprint.End2, aFootprint.End1, FloortoFloorHeight);
        newFootPrint.AddPoint(aFootprint.End2, aFootprint.Width1, FloortoFloorHeight);
        newFootPrint.AddPoint(0, aFootprint.Width1, FloortoFloorHeight);

        //disable the original footprint
        aFootprint.Enabled := false;
      end
      else if SameText(aFootprint.ZoneLayout, 'Perimeter and Core') then
      begin
        //check if the perimeter depth will fit into the area

        if 2 * PerimDepth > 0.9 * aFootprint.End1 then
        begin
          dOrigPerimDepth := PerimDepth;
          while (2 * PerimDepth > 0.9 * aFootprint.End1) do
          begin
            PerimDepth := PerimDepth / 1.25;
          end;
          T_EP_PPErrorMessage.AddErrorMessage(esWarning, 'Problem with length of End 1 and the ' +
            'perimeter depth.  Reduced perimeter depth from ' +
            floattostr(dOrigPerimDepth) + ' to ' + FloatToStr(PerimDepth) +
            ' to accomodate perimeter and core layout.');
        end;
        if 2 * PerimDepth > 0.9 * aFootprint.End2 then
        begin
          dOrigPerimDepth := PerimDepth;
          while (2 * PerimDepth > 0.9 * aFootprint.End2) do
          begin
            PerimDepth := PerimDepth / 1.25;
          end;
          T_EP_PPErrorMessage.AddErrorMessage(esWarning, 'Problem with the length of End 2 and the ' +
            'perimeter depth.  Reduced perimeter depth from ' +
            floattostr(dOrigPerimDepth) + ' to ' + FloatToStr(PerimDepth) +
            ' to accomodate perimeter and core layout.');
        end;

        newFootPrint := AddFootPrint('Custom');
        newFootPrint.ZoneLayout := 'Minimum Zones';
        if aFootprint.ZoneNameMoniker <> '' then
          newFootPrint.ZoneNameMoniker := aFootprint.ZoneNameMoniker + '_1';
        if aFootprint.ZoneDescription <> '' then
          newFootPrint.ZoneDescription := aFootprint.ZoneDescription + '_1';
        newFootPrint.FloorNum := aFootprint.FloorNum;
        newFootPrint.FloorToFloorHeight := aFootprint.FloorToFloorHeight;
        newFootPrint.AddPoint(0, 0, FloortoFloorHeight);
        newFootPrint.AddPoint(aFootprint.Length1, 0, FloortoFloorHeight);
        newFootPrint.AddPoint(aFootprint.Length1 - PerimDepth,
          PerimDepth,
          FloortoFloorHeight);
        newFootPrint.AddPoint(PerimDepth, PerimDepth, FloortoFloorHeight);

        newFootPrint := AddFootPrint('Custom');
        newFootPrint.ZoneLayout := 'Minimum Zones';
        if aFootprint.ZoneNameMoniker <> '' then
          newFootPrint.ZoneNameMoniker := aFootprint.ZoneNameMoniker + '_2';
        if aFootprint.ZoneDescription <> '' then
          newFootPrint.ZoneDescription := aFootprint.ZoneDescription + '_2';
        newFootPrint.FloorNum := aFootprint.FloorNum;
        newFootPrint.FloorToFloorHeight := aFootprint.FloorToFloorHeight;
        newFootPrint.AddPoint(aFootprint.Length1 - PerimDepth,
          PerimDepth,
          FloortoFloorHeight);
        newFootPrint.AddPoint(aFootprint.Length1, 0, FloortoFloorHeight);
        newFootPrint.AddPoint(aFootprint.Length1,
          aFootprint.End1,
          FloortoFloorHeight);
        newFootPrint.AddPoint(aFootprint.Length1 - PerimDepth,
          aFootprint.End1 - PerimDepth,
          FloortoFloorHeight);

        newFootPrint := AddFootPrint('Custom');
        newFootPrint.ZoneLayout := 'Minimum Zones';
        if aFootprint.ZoneNameMoniker <> '' then
          newFootPrint.ZoneNameMoniker := aFootprint.ZoneNameMoniker + '_3';
        if aFootprint.ZoneDescription <> '' then
          newFootPrint.ZoneDescription := aFootprint.ZoneDescription + '_3';
        newFootPrint.FloorNum := aFootprint.FloorNum;
        newFootPrint.FloorToFloorHeight := aFootprint.FloorToFloorHeight;
        newFootPrint.AddPoint(aFootprint.End2 - PerimDepth,
          aFootprint.End1 - PerimDepth,
          FloortoFloorHeight);
        newFootPrint.AddPoint(aFootprint.Length1 - PerimDepth,
          aFootprint.End1 - PerimDepth,
          FloortoFloorHeight);
        newFootPrint.AddPoint(aFootprint.Length1,
          aFootprint.End1,
          FloortoFloorHeight);
        newFootPrint.AddPoint(aFootprint.End2,
          aFootprint.End1,
          FloortoFloorHeight);

        newFootPrint := AddFootPrint('Custom');
        newFootPrint.ZoneLayout := 'Minimum Zones';
        if aFootprint.ZoneNameMoniker <> '' then
          newFootPrint.ZoneNameMoniker := aFootprint.ZoneNameMoniker + '_4';
        if aFootprint.ZoneDescription <> '' then
          newFootPrint.ZoneDescription := aFootprint.ZoneDescription + '_4';
        newFootPrint.FloorNum := aFootprint.FloorNum;
        newFootPrint.FloorToFloorHeight := aFootprint.FloorToFloorHeight;
        newFootPrint.AddPoint(aFootprint.End2 - PerimDepth,
          aFootprint.End1 - PerimDepth,
          FloortoFloorHeight);
        newFootPrint.AddPoint(aFootprint.End2,
          aFootprint.End1,
          FloortoFloorHeight);
        newFootPrint.AddPoint(aFootprint.End2,
          aFootprint.Width1,
          FloortoFloorHeight);
        newFootPrint.AddPoint(aFootprint.End2 - PerimDepth,
          aFootprint.Width1 - PerimDepth,
          FloortoFloorHeight);

        newFootPrint := AddFootPrint('Custom');
        newFootPrint.ZoneLayout := 'Minimum Zones';
        if aFootprint.ZoneNameMoniker <> '' then
          newFootPrint.ZoneNameMoniker := aFootprint.ZoneNameMoniker + '_5';
        if aFootprint.ZoneDescription <> '' then
          newFootPrint.ZoneDescription := aFootprint.ZoneDescription + '_5';
        newFootPrint.FloorNum := aFootprint.FloorNum;
        newFootPrint.FloorToFloorHeight := aFootprint.FloorToFloorHeight;
        newFootPrint.AddPoint(PerimDepth,
          aFootprint.Width1 - PerimDepth,
          FloortoFloorHeight);
        newFootPrint.AddPoint(aFootprint.End2 - PerimDepth,
          aFootprint.Width1 - PerimDepth,
          FloortoFloorHeight);
        newFootPrint.AddPoint(aFootprint.End2,
          aFootprint.Width1,
          FloortoFloorHeight);
        newFootPrint.AddPoint(0,
          aFootprint.Width1,
          FloortoFloorHeight);

        newFootPrint := AddFootPrint('Custom');
        newFootPrint.ZoneLayout := 'Minimum Zones';
        if aFootprint.ZoneNameMoniker <> '' then
          newFootPrint.ZoneNameMoniker := aFootprint.ZoneNameMoniker + '_6';
        if aFootprint.ZoneDescription <> '' then
          newFootPrint.ZoneDescription := aFootprint.ZoneDescription + '_6';
        newFootPrint.FloorNum := aFootprint.FloorNum;
        newFootPrint.FloorToFloorHeight := aFootprint.FloorToFloorHeight;
        newFootPrint.AddPoint(0, 0, FloortoFloorHeight);
        newFootPrint.AddPoint(PerimDepth,
          PerimDepth,
          FloortoFloorHeight);
        newFootPrint.AddPoint(PerimDepth,
          aFootprint.Width1 - PerimDepth,
          FloortoFloorHeight);
        newFootPrint.AddPoint(0,
          aFootprint.Width1,
          FloortoFloorHeight);

        newFootPrint := AddFootPrint('Custom');
        newFootPrint.ZoneLayout := 'Minimum Zones';
        if aFootprint.ZoneNameMoniker <> '' then
          newFootPrint.ZoneNameMoniker := aFootprint.ZoneNameMoniker + '_7';
        if aFootprint.ZoneDescription <> '' then
          newFootPrint.ZoneDescription := aFootprint.ZoneDescription + '_7';
        newFootPrint.FloorNum := aFootprint.FloorNum;
        newFootPrint.FloorToFloorHeight := aFootprint.FloorToFloorHeight;
        newFootPrint.AddPoint(PerimDepth, PerimDepth, FloortoFloorHeight);
        newFootPrint.AddPoint(aFootprint.Length1 - PerimDepth,
          PerimDepth,
          FloortoFloorHeight);
        newFootPrint.AddPoint(aFootprint.Length1 - PerimDepth,
          aFootprint.End1 - PerimDepth,
          FloortoFloorHeight);
        newFootPrint.AddPoint(aFootprint.End2 - PerimDepth,
          aFootprint.End1 - PerimDepth,
          FloortoFloorHeight);

        newFootPrint := AddFootPrint('Custom');
        newFootPrint.ZoneLayout := 'Minimum Zones';
        if aFootprint.ZoneNameMoniker <> '' then
          newFootPrint.ZoneNameMoniker := aFootprint.ZoneNameMoniker + '_8';
        if aFootprint.ZoneDescription <> '' then
          newFootPrint.ZoneDescription := aFootprint.ZoneDescription + '_8';
        newFootPrint.FloorNum := aFootprint.FloorNum;
        newFootPrint.FloorToFloorHeight := aFootprint.FloorToFloorHeight;
        newFootPrint.AddPoint(PerimDepth, PerimDepth, FloortoFloorHeight);
        newFootPrint.AddPoint(aFootprint.End2 - PerimDepth,
          aFootprint.End1 - PerimDepth,
          FloortoFloorHeight);
        newFootPrint.AddPoint(aFootprint.End2 - PerimDepth,
          aFootprint.Width1 - PerimDepth,
          FloortoFloorHeight);
        newFootPrint.AddPoint(PerimDepth,
          aFootprint.Width1 - PerimDepth,
          FloortoFloorHeight);

        aFootprint.Enabled := false;

      end;
    end
    else if SameText(aFootprint.FootPrintType, 'T-Shape') then
    begin
      Length := aFootprint.Length1; //these are not the real values
      Width := aFootprint.Width1;

      if SameText(aFootprint.ZoneLayout, 'Minimum Zones') then
      begin
        //create two seperate zones
        newFootPrint := AddFootPrint('Custom');
        newFootPrint.ZoneLayout := 'Minimum Zones';
        if aFootprint.ZoneNameMoniker <> '' then
          newFootPrint.ZoneNameMoniker := aFootprint.ZoneNameMoniker + '_1';
        if aFootprint.ZoneDescription <> '' then
          newFootPrint.ZoneDescription := aFootprint.ZoneDescription + '_1';
        newFootPrint.FloorNum := aFootprint.FloorNum;
        newFootPrint.FloorToFloorHeight := aFootprint.FloorToFloorHeight;
        newFootPrint.AddPoint(aFootprint.Offset1,
          0,
          FloortoFloorHeight);
        newFootPrint.AddPoint(aFootprint.Offset1 + aFootprint.End2,
          0,
          FloortoFloorHeight);
        newFootPrint.AddPoint(aFootprint.Offset1 + aFootprint.End2,
          aFootprint.Width1 - aFootprint.End1,
          FloortoFloorHeight);
        newFootPrint.AddPoint(aFootprint.Offset1,
          aFootprint.Width1 - aFootprint.End1,
          FloortoFloorHeight);

        newFootPrint := AddFootPrint('Custom');
        newFootPrint.ZoneLayout := 'Minimum Zones';
        if aFootprint.ZoneNameMoniker <> '' then
          newFootPrint.ZoneNameMoniker := aFootprint.ZoneNameMoniker + '_2';
        if aFootprint.ZoneDescription <> '' then
          newFootPrint.ZoneDescription := aFootprint.ZoneDescription + '_2';
        newFootPrint.FloorNum := aFootprint.FloorNum;
        newFootPrint.FloorToFloorHeight := aFootprint.FloorToFloorHeight;
        newFootPrint.AddPoint(0,
          aFootprint.Width1 - aFootprint.End1,
          FloortoFloorHeight);
        newFootPrint.AddPoint(aFootprint.Offset1,
          aFootprint.Width1 - aFootprint.End1,
          FloortoFloorHeight);
        newFootPrint.AddPoint(aFootprint.Offset1 + aFootprint.End2,
          aFootprint.Width1 - aFootprint.End1,
          FloortoFloorHeight);
        newFootPrint.AddPoint(aFootprint.Length1,
          aFootprint.Width1 - aFootprint.End1,
          FloortoFloorHeight);
        newFootPrint.AddPoint(aFootprint.Length1,
          aFootprint.Width1,
          FloortoFloorHeight);
        newFootPrint.AddPoint(0,
          aFootprint.Width1,
          FloortoFloorHeight);

        aFootprint.Enabled := false;
      end
      else if SameText(aFootprint.ZoneLayout, 'Perimeter and Core') then
      begin
        newFootPrint := AddFootPrint('Custom');
        newFootPrint.ZoneLayout := 'Minimum Zones';
        if aFootprint.ZoneNameMoniker <> '' then
          newFootPrint.ZoneNameMoniker := aFootprint.ZoneNameMoniker + '_1';
        if aFootprint.ZoneDescription <> '' then
          newFootPrint.ZoneDescription := aFootprint.ZoneDescription + '_1';
        newFootPrint.FloorNum := aFootprint.FloorNum;
        newFootPrint.FloorToFloorHeight := aFootprint.FloorToFloorHeight;
        newFootPrint.AddPoint(aFootprint.Offset1,
          0,
          FloortoFloorHeight);
        newFootPrint.AddPoint(aFootprint.Offset1 + aFootprint.End2,
          0,
          FloortoFloorHeight);
        newFootPrint.AddPoint(aFootprint.Offset1 + aFootprint.End2 - PerimDepth,
          PerimDepth,
          FloortoFloorHeight);
        newFootPrint.AddPoint(aFootprint.Offset1 + PerimDepth,
          PerimDepth,
          FloortoFloorHeight);

        newFootPrint := AddFootPrint('Custom');
        newFootPrint.ZoneLayout := 'Minimum Zones';
        if aFootprint.ZoneNameMoniker <> '' then
          newFootPrint.ZoneNameMoniker := aFootprint.ZoneNameMoniker + '_2';
        if aFootprint.ZoneDescription <> '' then
          newFootPrint.ZoneDescription := aFootprint.ZoneDescription + '_2';
        newFootPrint.FloorNum := aFootprint.FloorNum;
        newFootPrint.FloorToFloorHeight := aFootprint.FloorToFloorHeight;
        newFootPrint.AddPoint(aFootprint.Offset1 + aFootprint.End2 - PerimDepth,
          PerimDepth,
          FloortoFloorHeight);
        newFootPrint.AddPoint(aFootprint.Offset1 + aFootprint.End2,
          0,
          FloortoFloorHeight);
        newFootPrint.AddPoint(aFootprint.Offset1 + aFootprint.End2,
          aFootprint.Width1 - aFootprint.End1,
          FloortoFloorHeight);
        newFootPrint.AddPoint(aFootprint.Offset1 + aFootprint.End2 - PerimDepth,
          aFootprint.Width1 - aFootprint.End1 + PerimDepth,
          FloortoFloorHeight);

        newFootPrint := AddFootPrint('Custom');
        newFootPrint.ZoneLayout := 'Minimum Zones';
        if aFootprint.ZoneNameMoniker <> '' then
          newFootPrint.ZoneNameMoniker := aFootprint.ZoneNameMoniker + '_3';
        if aFootprint.ZoneDescription <> '' then
          newFootPrint.ZoneDescription := aFootprint.ZoneDescription + '_3';
        newFootPrint.FloorNum := aFootprint.FloorNum;
        newFootPrint.FloorToFloorHeight := aFootprint.FloorToFloorHeight;
        newFootPrint.AddPoint(aFootprint.Offset1 + aFootprint.End2,
          aFootprint.Width1 - aFootprint.End1,
          FloortoFloorHeight);
        newFootPrint.AddPoint(aFootprint.Length1,
          aFootprint.Width1 - aFootprint.End1,
          FloortoFloorHeight);
        newFootPrint.AddPoint(aFootprint.Length1 - PerimDepth,
          aFootprint.Width1 - aFootprint.End1 + PerimDepth,
          FloortoFloorHeight);
        newFootPrint.AddPoint(aFootprint.Offset1 + aFootprint.End2 - PerimDepth,
          aFootprint.Width1 - aFootprint.End1 + PerimDepth,
          FloortoFloorHeight);

        newFootPrint := AddFootPrint('Custom');
        newFootPrint.ZoneLayout := 'Minimum Zones';
        if aFootprint.ZoneNameMoniker <> '' then
          newFootPrint.ZoneNameMoniker := aFootprint.ZoneNameMoniker + '_4';
        if aFootprint.ZoneDescription <> '' then
          newFootPrint.ZoneDescription := aFootprint.ZoneDescription + '_4';
        newFootPrint.FloorNum := aFootprint.FloorNum;
        newFootPrint.FloorToFloorHeight := aFootprint.FloorToFloorHeight;
        newFootPrint.AddPoint(aFootprint.Length1 - PerimDepth,
          aFootprint.Width1 - aFootprint.End1 + PerimDepth,
          FloortoFloorHeight);
        newFootPrint.AddPoint(aFootprint.Length1,
          aFootprint.Width1 - aFootprint.End1,
          FloortoFloorHeight);
        newFootPrint.AddPoint(aFootprint.Length1,
          aFootprint.Width1,
          FloortoFloorHeight);
        newFootPrint.AddPoint(aFootprint.Length1 - PerimDepth,
          aFootprint.Width1 - PerimDepth,
          FloortoFloorHeight);

        newFootPrint := AddFootPrint('Custom');
        newFootPrint.ZoneLayout := 'Minimum Zones';
        if aFootprint.ZoneNameMoniker <> '' then
          newFootPrint.ZoneNameMoniker := aFootprint.ZoneNameMoniker + '_5';
        if aFootprint.ZoneDescription <> '' then
          newFootPrint.ZoneDescription := aFootprint.ZoneDescription + '_5';
        newFootPrint.FloorNum := aFootprint.FloorNum;
        newFootPrint.FloorToFloorHeight := aFootprint.FloorToFloorHeight;
        newFootPrint.AddPoint(PerimDepth,
          aFootprint.Width1 - PerimDepth,
          FloortoFloorHeight);
        newFootPrint.AddPoint(aFootprint.Length1 - PerimDepth,
          aFootprint.Width1 - PerimDepth,
          FloortoFloorHeight);
        newFootPrint.AddPoint(aFootprint.Length1,
          aFootprint.Width1,
          FloortoFloorHeight);
        newFootPrint.AddPoint(0,
          aFootprint.Width1,
          FloortoFloorHeight);

        newFootPrint := AddFootPrint('Custom');
        newFootPrint.ZoneLayout := 'Minimum Zones';
        if aFootprint.ZoneNameMoniker <> '' then
          newFootPrint.ZoneNameMoniker := aFootprint.ZoneNameMoniker + '_6';
        if aFootprint.ZoneDescription <> '' then
          newFootPrint.ZoneDescription := aFootprint.ZoneDescription + '_6';
        newFootPrint.FloorNum := aFootprint.FloorNum;
        newFootPrint.FloorToFloorHeight := aFootprint.FloorToFloorHeight;
        newFootPrint.AddPoint(0,
          aFootprint.Width1 - aFootprint.End1,
          FloortoFloorHeight);
        newFootPrint.AddPoint(PerimDepth,
          aFootprint.Width1 - aFootprint.End1 + PerimDepth,
          FloortoFloorHeight);
        newFootPrint.AddPoint(PerimDepth,
          aFootprint.Width1 - PerimDepth,
          FloortoFloorHeight);
        newFootPrint.AddPoint(0,
          aFootprint.Width1,
          FloortoFloorHeight);

        newFootPrint := AddFootPrint('Custom');
        newFootPrint.ZoneLayout := 'Minimum Zones';
        if aFootprint.ZoneNameMoniker <> '' then
          newFootPrint.ZoneNameMoniker := aFootprint.ZoneNameMoniker + '_7';
        if aFootprint.ZoneDescription <> '' then
          newFootPrint.ZoneDescription := aFootprint.ZoneDescription + '_7';
        newFootPrint.FloorNum := aFootprint.FloorNum;
        newFootPrint.FloorToFloorHeight := aFootprint.FloorToFloorHeight;
        newFootPrint.AddPoint(0,
          aFootprint.Width1 - aFootprint.End1,
          FloortoFloorHeight);
        newFootPrint.AddPoint(aFootprint.Offset1,
          aFootprint.Width1 - aFootprint.End1,
          FloortoFloorHeight);
        newFootPrint.AddPoint(aFootprint.Offset1 + PerimDepth,
          aFootprint.Width1 - aFootprint.End1 + PerimDepth,
          FloortoFloorHeight);
        newFootPrint.AddPoint(PerimDepth,
          aFootprint.Width1 - aFootprint.End1 + PerimDepth,
          FloortoFloorHeight);

        newFootPrint := AddFootPrint('Custom');
        newFootPrint.ZoneLayout := 'Minimum Zones';
        if aFootprint.ZoneNameMoniker <> '' then
          newFootPrint.ZoneNameMoniker := aFootprint.ZoneNameMoniker + '_8';
        if aFootprint.ZoneDescription <> '' then
          newFootPrint.ZoneDescription := aFootprint.ZoneDescription + '_8';
        newFootPrint.FloorNum := aFootprint.FloorNum;
        newFootPrint.FloorToFloorHeight := aFootprint.FloorToFloorHeight;
        newFootPrint.AddPoint(aFootprint.Offset1,
          0,
          FloortoFloorHeight);
        newFootPrint.AddPoint(aFootprint.Offset1 + PerimDepth,
          PerimDepth,
          FloortoFloorHeight);
        newFootPrint.AddPoint(aFootprint.Offset1 + PerimDepth,
          aFootprint.Width1 - aFootprint.End1 + PerimDepth,
          FloortoFloorHeight);
        newFootPrint.AddPoint(aFootprint.Offset1,
          aFootprint.Width1 - aFootprint.End1,
          FloortoFloorHeight);

        newFootPrint := AddFootPrint('Custom');
        newFootPrint.ZoneLayout := 'Minimum Zones';
        if aFootprint.ZoneNameMoniker <> '' then
          newFootPrint.ZoneNameMoniker := aFootprint.ZoneNameMoniker + '_9';
        if aFootprint.ZoneDescription <> '' then
          newFootPrint.ZoneDescription := aFootprint.ZoneDescription + '_9';
        newFootPrint.FloorNum := aFootprint.FloorNum;
        newFootPrint.FloorToFloorHeight := aFootprint.FloorToFloorHeight;
        newFootPrint.AddPoint(aFootprint.Offset1 + PerimDepth,
          PerimDepth,
          FloortoFloorHeight);
        newFootPrint.AddPoint(aFootprint.Offset1 + aFootprint.End2 - PerimDepth,
          PerimDepth,
          FloortoFloorHeight);
        newFootPrint.AddPoint(aFootprint.Offset1 + aFootprint.End2 - PerimDepth,
          aFootprint.Width1 - aFootprint.End1 + PerimDepth,
          FloortoFloorHeight);
        newFootPrint.AddPoint(aFootprint.Offset1 + PerimDepth,
          aFootprint.Width1 - aFootprint.End1 + PerimDepth,
          FloortoFloorHeight);

        newFootPrint := AddFootPrint('Custom');
        newFootPrint.ZoneLayout := 'Minimum Zones';
        if aFootprint.ZoneNameMoniker <> '' then
          newFootPrint.ZoneNameMoniker := aFootprint.ZoneNameMoniker + '_10';
        if aFootprint.ZoneDescription <> '' then
          newFootPrint.ZoneDescription := aFootprint.ZoneDescription + '_10';
        newFootPrint.FloorNum := aFootprint.FloorNum;
        newFootPrint.FloorToFloorHeight := aFootprint.FloorToFloorHeight;
        newFootPrint.AddPoint(PerimDepth,
          aFootprint.Width1 - aFootprint.End1 + PerimDepth,
          FloortoFloorHeight);
        newFootPrint.AddPoint(aFootprint.Offset1 + PerimDepth,
          aFootprint.Width1 - aFootprint.End1 + PerimDepth,
          FloortoFloorHeight);
        newFootPrint.AddPoint(aFootprint.Offset1 + aFootprint.End2 - PerimDepth,
          aFootprint.Width1 - aFootprint.End1 + PerimDepth,
          FloortoFloorHeight);
        newFootPrint.AddPoint(aFootprint.Length1 - PerimDepth,
          aFootprint.Width1 - aFootprint.End1 + PerimDepth,
          FloortoFloorHeight);
        newFootPrint.AddPoint(aFootprint.Length1 - PerimDepth,
          aFootprint.Width1 - PerimDepth,
          FloortoFloorHeight);
        newFootPrint.AddPoint(PerimDepth,
          aFootprint.Width1 - PerimDepth,
          FloortoFloorHeight);

        aFootprint.Enabled := false;
      end; //if perimeter and core
    end
    else if SameText(aFootprint.FootPrintType, 'H-Shape') then
    begin
      //the area has no use in this format
      Length := aFootprint.Length1; //these are not the real values
      Width := aFootprint.Width1;

      if SameText(aFootprint.ZoneLayout, 'Minimum Zones') then
      begin
        //create three seperate zones
        newFootPrint := AddFootPrint('Custom');
        newFootPrint.ZoneLayout := 'Minimum Zones';
        if aFootprint.ZoneNameMoniker <> '' then
          newFootPrint.ZoneNameMoniker := aFootprint.ZoneNameMoniker + '_1';
        if aFootprint.ZoneDescription <> '' then
          newFootPrint.ZoneDescription := aFootprint.ZoneDescription + '_1';
        newFootPrint.FloorNum := aFootprint.FloorNum;
        newFootPrint.FloorToFloorHeight := aFootprint.FloorToFloorHeight;
        newFootPrint.AddPoint(0,
          0,
          FloortoFloorHeight);
        newFootPrint.AddPoint(aFootprint.End1,
          0,
          FloortoFloorHeight);
        newFootPrint.AddPoint(aFootprint.End1,
          aFootprint.Offset2,
          FloortoFloorHeight);
        newFootPrint.AddPoint(aFootprint.End1,
          aFootprint.Width1 - aFootprint.Offset1,
          FloortoFloorHeight);
        newFootPrint.AddPoint(aFootprint.End1,
          aFootprint.Width1,
          FloortoFloorHeight);
        newFootPrint.AddPoint(0,
          aFootprint.Width1,
          FloortoFloorHeight);

        newFootPrint := AddFootPrint('Custom');
        newFootPrint.ZoneLayout := 'Minimum Zones';
        if aFootprint.ZoneNameMoniker <> '' then
          newFootPrint.ZoneNameMoniker := aFootprint.ZoneNameMoniker + '_2';
        if aFootprint.ZoneDescription <> '' then
          newFootPrint.ZoneDescription := aFootprint.ZoneDescription + '_2';
        newFootPrint.FloorNum := aFootprint.FloorNum;
        newFootPrint.FloorToFloorHeight := aFootprint.FloorToFloorHeight;
        newFootPrint.AddPoint(aFootprint.End1,
          aFootprint.Offset2,
          FloortoFloorHeight);
        newFootPrint.AddPoint(aFootprint.Length1 - aFootprint.End2,
          aFootprint.Offset2,
          FloortoFloorHeight);
        newFootPrint.AddPoint(aFootprint.Length1 - aFootprint.End2,
          aFootprint.Width1 - aFootprint.Offset1,
          FloortoFloorHeight);
        newFootPrint.AddPoint(aFootprint.End1,
          aFootprint.Width1 - aFootprint.Offset1,
          FloortoFloorHeight);

        newFootPrint := AddFootPrint('Custom');
        newFootPrint.ZoneLayout := 'Minimum Zones';
        if aFootprint.ZoneNameMoniker <> '' then
          newFootPrint.ZoneNameMoniker := aFootprint.ZoneNameMoniker + '_3';
        if aFootprint.ZoneDescription <> '' then
          newFootPrint.ZoneDescription := aFootprint.ZoneDescription + '_3';
        newFootPrint.FloorNum := aFootprint.FloorNum;
        newFootPrint.FloorToFloorHeight := aFootprint.FloorToFloorHeight;
        newFootPrint.AddPoint(aFootprint.Length1 - aFootprint.End2,
          -aFootprint.Offset3,
          FloortoFloorHeight);
        newFootPrint.AddPoint(aFootprint.Length1,
          -aFootprint.Offset3,
          FloortoFloorHeight);
        newFootPrint.AddPoint(aFootprint.Length1,
          -aFootprint.Offset3 + aFootprint.Width2,
          FloortoFloorHeight);
        newFootPrint.AddPoint(aFootprint.Length1 - aFootprint.End2,
          -aFootprint.Offset3 + aFootprint.Width2,
          FloortoFloorHeight);
        newFootPrint.AddPoint(aFootprint.Length1 - aFootprint.End2,
          aFootprint.Width1 - aFootprint.Offset1,
          FloortoFloorHeight);
        newFootPrint.AddPoint(aFootprint.Length1 - aFootprint.End2,
          aFootprint.Offset2,
          FloortoFloorHeight);

        //disable the original footprint
        aFootprint.Enabled := false;
      end
      else if SameText(aFootprint.ZoneLayout, 'Perimeter and Core') then
      begin
        newFootPrint := AddFootPrint('Custom');
        newFootPrint.ZoneLayout := 'Minimum Zones';
        if aFootprint.ZoneNameMoniker <> '' then
          newFootPrint.ZoneNameMoniker := aFootprint.ZoneNameMoniker + '_1';
        if aFootprint.ZoneDescription <> '' then
          newFootPrint.ZoneDescription := aFootprint.ZoneDescription + '_1';
        newFootPrint.FloorNum := aFootprint.FloorNum;
        newFootPrint.FloorToFloorHeight := aFootprint.FloorToFloorHeight;
        newFootPrint.AddPoint(0,
          0,
          FloortoFloorHeight);
        newFootPrint.AddPoint(aFootprint.End1,
          0,
          FloortoFloorHeight);
        newFootPrint.AddPoint(aFootprint.End1 - PerimDepth,
          PerimDepth,
          FloortoFloorHeight);
        newFootPrint.AddPoint(PerimDepth,
          PerimDepth,
          FloortoFloorHeight);

        newFootPrint := AddFootPrint('Custom');
        newFootPrint.ZoneLayout := 'Minimum Zones';
        if aFootprint.ZoneNameMoniker <> '' then
          newFootPrint.ZoneNameMoniker := aFootprint.ZoneNameMoniker + '_2';
        if aFootprint.ZoneDescription <> '' then
          newFootPrint.ZoneDescription := aFootprint.ZoneDescription + '_2';
        newFootPrint.FloorNum := aFootprint.FloorNum;
        newFootPrint.FloorToFloorHeight := aFootprint.FloorToFloorHeight;
        newFootPrint.AddPoint(aFootprint.End1 - PerimDepth,
          PerimDepth,
          FloortoFloorHeight);
        newFootPrint.AddPoint(aFootprint.End1,
          0,
          FloortoFloorHeight);
        newFootPrint.AddPoint(aFootprint.End1,
          aFootprint.Offset2,
          FloortoFloorHeight);
        newFootPrint.AddPoint(aFootprint.End1 - PerimDepth,
          aFootprint.Offset2 + PerimDepth,
          FloortoFloorHeight);

        newFootPrint := AddFootPrint('Custom');
        newFootPrint.ZoneLayout := 'Minimum Zones';
        if aFootprint.ZoneNameMoniker <> '' then
          newFootPrint.ZoneNameMoniker := aFootprint.ZoneNameMoniker + '_3';
        if aFootprint.ZoneDescription <> '' then
          newFootPrint.ZoneDescription := aFootprint.ZoneDescription + '_3';
        newFootPrint.FloorNum := aFootprint.FloorNum;
        newFootPrint.FloorToFloorHeight := aFootprint.FloorToFloorHeight;
        newFootPrint.AddPoint(aFootprint.End1,
          aFootprint.Offset2,
          FloortoFloorHeight);
        newFootPrint.AddPoint(aFootprint.Length1 - aFootprint.End2,
          aFootprint.Offset2,
          FloortoFloorHeight);
        newFootPrint.AddPoint(aFootprint.Length1 - aFootprint.End2 + PerimDepth,
          aFootprint.Offset2 + PerimDepth,
          FloortoFloorHeight);
        newFootPrint.AddPoint(aFootprint.End1 - PerimDepth,
          aFootprint.Offset2 + PerimDepth,
          FloortoFloorHeight);

        newFootPrint := AddFootPrint('Custom');
        newFootPrint.ZoneLayout := 'Minimum Zones';
        if aFootprint.ZoneNameMoniker <> '' then
          newFootPrint.ZoneNameMoniker := aFootprint.ZoneNameMoniker + '_4';
        if aFootprint.ZoneDescription <> '' then
          newFootPrint.ZoneDescription := aFootprint.ZoneDescription + '_4';
        newFootPrint.FloorNum := aFootprint.FloorNum;
        newFootPrint.FloorToFloorHeight := aFootprint.FloorToFloorHeight;
        newFootPrint.AddPoint(aFootprint.Length1 - aFootprint.End2,
          -aFootprint.Offset3,
          FloortoFloorHeight);
        newFootPrint.AddPoint(aFootprint.Length1 - aFootprint.End2 + PerimDepth,
          -aFootprint.Offset3 + PerimDepth,
          FloortoFloorHeight);
        newFootPrint.AddPoint(aFootprint.Length1 - aFootprint.End2 + PerimDepth,
          aFootprint.Offset2 + PerimDepth,
          FloortoFloorHeight);
        newFootPrint.AddPoint(aFootprint.Length1 - aFootprint.End2,
          aFootprint.Offset2,
          FloortoFloorHeight);

        newFootPrint := AddFootPrint('Custom');
        newFootPrint.ZoneLayout := 'Minimum Zones';
        if aFootprint.ZoneNameMoniker <> '' then
          newFootPrint.ZoneNameMoniker := aFootprint.ZoneNameMoniker + '_5';
        if aFootprint.ZoneDescription <> '' then
          newFootPrint.ZoneDescription := aFootprint.ZoneDescription + '_5';
        newFootPrint.FloorNum := aFootprint.FloorNum;
        newFootPrint.FloorToFloorHeight := aFootprint.FloorToFloorHeight;
        newFootPrint.AddPoint(aFootprint.Length1 - aFootprint.End2,
          -aFootprint.Offset3,
          FloortoFloorHeight);
        newFootPrint.AddPoint(aFootprint.Length1,
          -aFootprint.Offset3,
          FloortoFloorHeight);
        newFootPrint.AddPoint(aFootprint.Length1 - PerimDepth,
          -aFootprint.Offset3 + PerimDepth,
          FloortoFloorHeight);
        newFootPrint.AddPoint(aFootprint.Length1 - aFootprint.End2 + PerimDepth,
          -aFootprint.Offset3 + PerimDepth,
          FloortoFloorHeight);

        newFootPrint := AddFootPrint('Custom');
        newFootPrint.ZoneLayout := 'Minimum Zones';
        if aFootprint.ZoneNameMoniker <> '' then
          newFootPrint.ZoneNameMoniker := aFootprint.ZoneNameMoniker + '_6';
        if aFootprint.ZoneDescription <> '' then
          newFootPrint.ZoneDescription := aFootprint.ZoneDescription + '_6';
        newFootPrint.FloorNum := aFootprint.FloorNum;
        newFootPrint.FloorToFloorHeight := aFootprint.FloorToFloorHeight;
        newFootPrint.AddPoint(aFootprint.Length1 - PerimDepth,
          -aFootprint.Offset3 + PerimDepth,
          FloortoFloorHeight);
        newFootPrint.AddPoint(aFootprint.Length1,
          -aFootprint.Offset3,
          FloortoFloorHeight);
        newFootPrint.AddPoint(aFootprint.Length1,
          -aFootprint.Offset3 + aFootprint.Width2,
          FloortoFloorHeight);
        newFootPrint.AddPoint(aFootprint.Length1 - PerimDepth,
          -aFootprint.Offset3 + aFootprint.Width2 - PerimDepth,
          FloortoFloorHeight);

        newFootPrint := AddFootPrint('Custom');
        newFootPrint.ZoneLayout := 'Minimum Zones';
        if aFootprint.ZoneNameMoniker <> '' then
          newFootPrint.ZoneNameMoniker := aFootprint.ZoneNameMoniker + '_7';
        if aFootprint.ZoneDescription <> '' then
          newFootPrint.ZoneDescription := aFootprint.ZoneDescription + '_7';
        newFootPrint.FloorNum := aFootprint.FloorNum;
        newFootPrint.FloorToFloorHeight := aFootprint.FloorToFloorHeight;
        newFootPrint.AddPoint(aFootprint.Length1 - aFootprint.End2 + PerimDepth,
          -aFootprint.Offset3 + aFootprint.Width2 - PerimDepth,
          FloortoFloorHeight);
        newFootPrint.AddPoint(aFootprint.Length1 - PerimDepth,
          -aFootprint.Offset3 + aFootprint.Width2 - PerimDepth,
          FloortoFloorHeight);
        newFootPrint.AddPoint(aFootprint.Length1,
          -aFootprint.Offset3 + aFootprint.Width2,
          FloortoFloorHeight);
        newFootPrint.AddPoint(aFootprint.Length1 - aFootprint.End2,
          -aFootprint.Offset3 + aFootprint.Width2,
          FloortoFloorHeight);

        newFootPrint := AddFootPrint('Custom');
        newFootPrint.ZoneLayout := 'Minimum Zones';
        if aFootprint.ZoneNameMoniker <> '' then
          newFootPrint.ZoneNameMoniker := aFootprint.ZoneNameMoniker + '_8';
        if aFootprint.ZoneDescription <> '' then
          newFootPrint.ZoneDescription := aFootprint.ZoneDescription + '_8';
        newFootPrint.FloorNum := aFootprint.FloorNum;
        newFootPrint.FloorToFloorHeight := aFootprint.FloorToFloorHeight;
        newFootPrint.AddPoint(aFootprint.Length1 - aFootprint.End2,
          aFootprint.Width1 - aFootprint.Offset1,
          FloortoFloorHeight);
        newFootPrint.AddPoint(aFootprint.Length1 - aFootprint.End2 + PerimDepth,
          aFootprint.Width1 - aFootprint.Offset1 - PerimDepth,
          FloortoFloorHeight);
        newFootPrint.AddPoint(aFootprint.Length1 - aFootprint.End2 + PerimDepth,
          -aFootprint.Offset3 + aFootprint.Width2 - PerimDepth,
          FloortoFloorHeight);
        newFootPrint.AddPoint(aFootprint.Length1 - aFootprint.End2,
          -aFootprint.Offset3 + aFootprint.Width2,
          FloortoFloorHeight);

        newFootPrint := AddFootPrint('Custom');
        newFootPrint.ZoneLayout := 'Minimum Zones';
        if aFootprint.ZoneNameMoniker <> '' then
          newFootPrint.ZoneNameMoniker := aFootprint.ZoneNameMoniker + '_9';
        if aFootprint.ZoneDescription <> '' then
          newFootPrint.ZoneDescription := aFootprint.ZoneDescription + '_9';
        newFootPrint.FloorNum := aFootprint.FloorNum;
        newFootPrint.FloorToFloorHeight := aFootprint.FloorToFloorHeight;
        newFootPrint.AddPoint(aFootprint.End1 - PerimDepth,
          aFootprint.Width1 - aFootprint.Offset1 - PerimDepth,
          FloortoFloorHeight);
        newFootPrint.AddPoint(aFootprint.Length1 - aFootprint.End2 + PerimDepth,
          aFootprint.Width1 - aFootprint.Offset1 - PerimDepth,
          FloortoFloorHeight);
        newFootPrint.AddPoint(aFootprint.Length1 - aFootprint.End2,
          aFootprint.Width1 - aFootprint.Offset1,
          FloortoFloorHeight);
        newFootPrint.AddPoint(aFootprint.End1,
          aFootprint.Width1 - aFootprint.Offset1,
          FloortoFloorHeight);

        newFootPrint := AddFootPrint('Custom');
        newFootPrint.ZoneLayout := 'Minimum Zones';
        if aFootprint.ZoneNameMoniker <> '' then
          newFootPrint.ZoneNameMoniker := aFootprint.ZoneNameMoniker + '_10';
        if aFootprint.ZoneDescription <> '' then
          newFootPrint.ZoneDescription := aFootprint.ZoneDescription + '_10';
        newFootPrint.FloorNum := aFootprint.FloorNum;
        newFootPrint.FloorToFloorHeight := aFootprint.FloorToFloorHeight;
        newFootPrint.AddPoint(aFootprint.End1 - PerimDepth,
          aFootprint.Width1 - aFootprint.Offset1 - PerimDepth,
          FloortoFloorHeight);
        newFootPrint.AddPoint(aFootprint.End1,
          aFootprint.Width1 - aFootprint.Offset1,
          FloortoFloorHeight);
        newFootPrint.AddPoint(aFootprint.End1,
          aFootprint.Width1,
          FloortoFloorHeight);
        newFootPrint.AddPoint(aFootprint.End1 - PerimDepth,
          aFootprint.Width1 - PerimDepth,
          FloortoFloorHeight);

        newFootPrint := AddFootPrint('Custom');
        newFootPrint.ZoneLayout := 'Minimum Zones';
        if aFootprint.ZoneNameMoniker <> '' then
          newFootPrint.ZoneNameMoniker := aFootprint.ZoneNameMoniker + '_11';
        if aFootprint.ZoneDescription <> '' then
          newFootPrint.ZoneDescription := aFootprint.ZoneDescription + '_11';
        newFootPrint.FloorNum := aFootprint.FloorNum;
        newFootPrint.FloorToFloorHeight := aFootprint.FloorToFloorHeight;
        newFootPrint.AddPoint(PerimDepth,
          aFootprint.Width1 - PerimDepth,
          FloortoFloorHeight);
        newFootPrint.AddPoint(aFootprint.End1 - PerimDepth,
          aFootprint.Width1 - PerimDepth,
          FloortoFloorHeight);
        newFootPrint.AddPoint(aFootprint.End1,
          aFootprint.Width1,
          FloortoFloorHeight);
        newFootPrint.AddPoint(0,
          aFootprint.Width1,
          FloortoFloorHeight);

        newFootPrint := AddFootPrint('Custom');
        newFootPrint.ZoneLayout := 'Minimum Zones';
        if aFootprint.ZoneNameMoniker <> '' then
          newFootPrint.ZoneNameMoniker := aFootprint.ZoneNameMoniker + '_12';
        if aFootprint.ZoneDescription <> '' then
          newFootPrint.ZoneDescription := aFootprint.ZoneDescription + '_12';
        newFootPrint.FloorNum := aFootprint.FloorNum;
        newFootPrint.FloorToFloorHeight := aFootprint.FloorToFloorHeight;
        newFootPrint.AddPoint(0,
          0,
          FloortoFloorHeight);
        newFootPrint.AddPoint(PerimDepth,
          PerimDepth,
          FloortoFloorHeight);
        newFootPrint.AddPoint(PerimDepth,
          aFootprint.Width1 - PerimDepth,
          FloortoFloorHeight);
        newFootPrint.AddPoint(0,
          aFootprint.Width1,
          FloortoFloorHeight);

        newFootPrint := AddFootPrint('Custom');
        newFootPrint.ZoneLayout := 'Minimum Zones';
        if aFootprint.ZoneNameMoniker <> '' then
          newFootPrint.ZoneNameMoniker := aFootprint.ZoneNameMoniker + '_13';
        if aFootprint.ZoneDescription <> '' then
          newFootPrint.ZoneDescription := aFootprint.ZoneDescription + '_13';
        newFootPrint.FloorNum := aFootprint.FloorNum;
        newFootPrint.FloorToFloorHeight := aFootprint.FloorToFloorHeight;
        newFootPrint.AddPoint(PerimDepth,
          PerimDepth,
          FloortoFloorHeight);
        newFootPrint.AddPoint(aFootprint.End1 - PerimDepth,
          PerimDepth,
          FloortoFloorHeight);
        newFootPrint.AddPoint(aFootprint.End1 - PerimDepth,
          aFootprint.Offset2 + PerimDepth,
          FloortoFloorHeight);
        newFootPrint.AddPoint(aFootprint.End1 - PerimDepth,
          aFootprint.Width1 - aFootprint.Offset1 - PerimDepth,
          FloortoFloorHeight);
        newFootPrint.AddPoint(aFootprint.End1 - PerimDepth,
          aFootprint.Width1 - PerimDepth,
          FloortoFloorHeight);
        newFootPrint.AddPoint(PerimDepth,
          aFootprint.Width1 - PerimDepth,
          FloortoFloorHeight);

        newFootPrint := AddFootPrint('Custom');
        newFootPrint.ZoneLayout := 'Minimum Zones';
        if aFootprint.ZoneNameMoniker <> '' then
          newFootPrint.ZoneNameMoniker := aFootprint.ZoneNameMoniker + '_14';
        if aFootprint.ZoneDescription <> '' then
          newFootPrint.ZoneDescription := aFootprint.ZoneDescription + '_14';
        newFootPrint.FloorNum := aFootprint.FloorNum;
        newFootPrint.FloorToFloorHeight := aFootprint.FloorToFloorHeight;
        newFootPrint.AddPoint(aFootprint.End1 - PerimDepth,
          aFootprint.Offset2 + PerimDepth,
          FloortoFloorHeight);
        newFootPrint.AddPoint(aFootprint.Length1 - aFootprint.End2 + PerimDepth,
          aFootprint.Offset2 + PerimDepth,
          FloortoFloorHeight);
        newFootPrint.AddPoint(aFootprint.Length1 - aFootprint.End2 + PerimDepth,
          aFootprint.Width1 - aFootprint.Offset1 - PerimDepth,
          FloortoFloorHeight);
        newFootPrint.AddPoint(aFootprint.End1 - PerimDepth,
          aFootprint.Width1 - aFootprint.Offset1 - PerimDepth,
          FloortoFloorHeight);

        newFootPrint := AddFootPrint('Custom');
        newFootPrint.ZoneLayout := 'Minimum Zones';
        if aFootprint.ZoneNameMoniker <> '' then
          newFootPrint.ZoneNameMoniker := aFootprint.ZoneNameMoniker + '_15';
        if aFootprint.ZoneDescription <> '' then
          newFootPrint.ZoneDescription := aFootprint.ZoneDescription + '_15';
        newFootPrint.FloorNum := aFootprint.FloorNum;
        newFootPrint.FloorToFloorHeight := aFootprint.FloorToFloorHeight;
        newFootPrint.AddPoint(aFootprint.Length1 - aFootprint.End2 + PerimDepth,
          -aFootprint.Offset3 + PerimDepth,
          FloortoFloorHeight);
        newFootPrint.AddPoint(aFootprint.Length1 - PerimDepth,
          -aFootprint.Offset3 + PerimDepth,
          FloortoFloorHeight);
        newFootPrint.AddPoint(aFootprint.Length1 - PerimDepth,
          -aFootprint.Offset3 + aFootprint.Width2 - PerimDepth,
          FloortoFloorHeight);
        newFootPrint.AddPoint(aFootprint.Length1 - aFootprint.End2 + PerimDepth,
          -aFootprint.Offset3 + aFootprint.Width2 - PerimDepth,
          FloortoFloorHeight);
        newFootPrint.AddPoint(aFootprint.Length1 - aFootprint.End2 + PerimDepth,
          aFootprint.Width1 - aFootprint.Offset1 - PerimDepth,
          FloortoFloorHeight);
        newFootPrint.AddPoint(aFootprint.Length1 - aFootprint.End2 + PerimDepth,
          aFootprint.Offset2 + PerimDepth,
          FloortoFloorHeight);

        //disable the original footprint
        aFootprint.Enabled := false;

      end;
    end
    else if SameText(aFootprint.FootPrintType, 'U-Shape') then
    begin
      //the area has no use in this format -- todo: make it a scaler
      Length := aFootprint.Length1; //these are not the real values
      Width := aFootprint.Width1;

      if SameText(aFootprint.ZoneLayout, 'Minimum Zones') then
      begin
        //create three seperate zones
        newFootPrint := AddFootPrint('Custom');
        newFootPrint.ZoneLayout := 'Minimum Zones';
        if aFootprint.ZoneNameMoniker <> '' then
          newFootPrint.ZoneNameMoniker := aFootprint.ZoneNameMoniker + '_1';
        if aFootprint.ZoneDescription <> '' then
          newFootPrint.ZoneDescription := aFootprint.ZoneDescription + '_1';
        newFootPrint.FloorNum := aFootprint.FloorNum;
        newFootPrint.FloorToFloorHeight := aFootprint.FloorToFloorHeight;
        newFootPrint.AddPoint(0,
          0,
          FloortoFloorHeight);
        newFootPrint.AddPoint(aFootprint.End1,
          0,
          FloortoFloorHeight);
        newFootPrint.AddPoint(aFootprint.End1,
          aFootprint.Width1 - aFootprint.Offset1,
          FloortoFloorHeight);
        newFootPrint.AddPoint(aFootprint.End1,
          aFootprint.Width1,
          FloortoFloorHeight);
        newFootPrint.AddPoint(0,
          aFootprint.Width1,
          FloortoFloorHeight);

        newFootPrint := AddFootPrint('Custom');
        newFootPrint.ZoneLayout := 'Minimum Zones';
        if aFootprint.ZoneNameMoniker <> '' then
          newFootPrint.ZoneNameMoniker := aFootprint.ZoneNameMoniker + '_2';
        if aFootprint.ZoneDescription <> '' then
          newFootPrint.ZoneDescription := aFootprint.ZoneDescription + '_2';
        newFootPrint.FloorNum := aFootprint.FloorNum;
        newFootPrint.FloorToFloorHeight := aFootprint.FloorToFloorHeight;
        newFootPrint.AddPoint(aFootprint.End1,
          0,
          FloortoFloorHeight);
        newFootPrint.AddPoint(aFootprint.Length1 - aFootprint.End2,
          0,
          FloortoFloorHeight);
        newFootPrint.AddPoint(aFootprint.Length1 - aFootprint.End2,
          aFootprint.Width1 - aFootprint.Offset1,
          FloortoFloorHeight);
        newFootPrint.AddPoint(aFootprint.End1,
          aFootprint.Width1 - aFootprint.Offset1,
          FloortoFloorHeight);

        newFootPrint := AddFootPrint('Custom');
        newFootPrint.ZoneLayout := 'Minimum Zones';
        if aFootprint.ZoneNameMoniker <> '' then
          newFootPrint.ZoneNameMoniker := aFootprint.ZoneNameMoniker + '_3';
        if aFootprint.ZoneDescription <> '' then
          newFootPrint.ZoneDescription := aFootprint.ZoneDescription + '_3';
        newFootPrint.FloorNum := aFootprint.FloorNum;
        newFootPrint.FloorToFloorHeight := aFootprint.FloorToFloorHeight;
        newFootPrint.AddPoint(aFootprint.Length1 - aFootprint.End2,
          0,
          FloortoFloorHeight);
        newFootPrint.AddPoint(aFootprint.Length1,
          0,
          FloortoFloorHeight);
        newFootPrint.AddPoint(aFootprint.Length1,
          aFootprint.Width2,
          FloortoFloorHeight);
        newFootPrint.AddPoint(aFootprint.Length1 - aFootprint.End2,
          aFootprint.Width2,
          FloortoFloorHeight);
        newFootPrint.AddPoint(aFootprint.Length1 - aFootprint.End2,
          aFootprint.Width1 - aFootprint.Offset1,
          FloortoFloorHeight);

        //disable the original footprint
        aFootprint.Enabled := false;
      end
      else if SameText(aFootprint.ZoneLayout, 'Perimeter and Core') then
      begin
        //create three seperate zones
        newFootPrint := AddFootPrint('Custom');
        newFootPrint.ZoneLayout := 'Minimum Zones';
        if aFootprint.ZoneNameMoniker <> '' then
          newFootPrint.ZoneNameMoniker := aFootprint.ZoneNameMoniker + '_1';
        if aFootprint.ZoneDescription <> '' then
          newFootPrint.ZoneDescription := aFootprint.ZoneDescription + '_1';
        newFootPrint.FloorNum := aFootprint.FloorNum;
        newFootPrint.FloorToFloorHeight := aFootprint.FloorToFloorHeight;
        newFootPrint.AddPoint(0,
          0,
          FloortoFloorHeight);
        newFootPrint.AddPoint(aFootprint.Length1,
          0,
          FloortoFloorHeight);
        newFootPrint.AddPoint(aFootprint.Length1 - PerimDepth,
          PerimDepth,
          FloortoFloorHeight);
        newFootPrint.AddPoint(PerimDepth,
          PerimDepth,
          FloortoFloorHeight);

        newFootPrint := AddFootPrint('Custom');
        newFootPrint.ZoneLayout := 'Minimum Zones';
        if aFootprint.ZoneNameMoniker <> '' then
          newFootPrint.ZoneNameMoniker := aFootprint.ZoneNameMoniker + '_2';
        if aFootprint.ZoneDescription <> '' then
          newFootPrint.ZoneDescription := aFootprint.ZoneDescription + '_2';
        newFootPrint.FloorNum := aFootprint.FloorNum;
        newFootPrint.FloorToFloorHeight := aFootprint.FloorToFloorHeight;
        newFootPrint.AddPoint(aFootprint.Length1 - PerimDepth,
          PerimDepth,
          FloortoFloorHeight);
        newFootPrint.AddPoint(aFootprint.Length1,
          0,
          FloortoFloorHeight);
        newFootPrint.AddPoint(aFootprint.Length1,
          aFootprint.Width2,
          FloortoFloorHeight);
        newFootPrint.AddPoint(aFootprint.Length1 - PerimDepth,
          aFootprint.Width2 - PerimDepth,
          FloortoFloorHeight);

        newFootPrint := AddFootPrint('Custom');
        newFootPrint.ZoneLayout := 'Minimum Zones';
        if aFootprint.ZoneNameMoniker <> '' then
          newFootPrint.ZoneNameMoniker := aFootprint.ZoneNameMoniker + '_3';
        if aFootprint.ZoneDescription <> '' then
          newFootPrint.ZoneDescription := aFootprint.ZoneDescription + '_3';
        newFootPrint.FloorNum := aFootprint.FloorNum;
        newFootPrint.FloorToFloorHeight := aFootprint.FloorToFloorHeight;
        newFootPrint.AddPoint(aFootprint.Length1 - aFootprint.End2 + PerimDepth,
          aFootprint.Width2 - PerimDepth,
          FloortoFloorHeight);
        newFootPrint.AddPoint(aFootprint.Length1 - PerimDepth,
          aFootprint.Width2 - PerimDepth,
          FloortoFloorHeight);
        newFootPrint.AddPoint(aFootprint.Length1,
          aFootprint.Width2,
          FloortoFloorHeight);
        newFootPrint.AddPoint(aFootprint.Length1 - aFootprint.End2,
          aFootprint.Width2,
          FloortoFloorHeight);

        newFootPrint := AddFootPrint('Custom');
        newFootPrint.ZoneLayout := 'Minimum Zones';
        if aFootprint.ZoneNameMoniker <> '' then
          newFootPrint.ZoneNameMoniker := aFootprint.ZoneNameMoniker + '_4';
        if aFootprint.ZoneDescription <> '' then
          newFootPrint.ZoneDescription := aFootprint.ZoneDescription + '_4';
        newFootPrint.FloorNum := aFootprint.FloorNum;
        newFootPrint.FloorToFloorHeight := aFootprint.FloorToFloorHeight;
        newFootPrint.AddPoint(aFootprint.Length1 - aFootprint.End2,
          aFootprint.Width1 - aFootprint.Offset1,
          FloortoFloorHeight);
        newFootPrint.AddPoint(aFootprint.Length1 - aFootprint.End2 + PerimDepth,
          aFootprint.Width1 - aFootprint.Offset1 - PerimDepth,
          FloortoFloorHeight);
        newFootPrint.AddPoint(aFootprint.Length1 - aFootprint.End2 + PerimDepth,
          aFootprint.Width2 - PerimDepth,
          FloortoFloorHeight);
        newFootPrint.AddPoint(aFootprint.Length1 - aFootprint.End2,
          aFootprint.Width2,
          FloortoFloorHeight);

        newFootPrint := AddFootPrint('Custom');
        newFootPrint.ZoneLayout := 'Minimum Zones';
        if aFootprint.ZoneNameMoniker <> '' then
          newFootPrint.ZoneNameMoniker := aFootprint.ZoneNameMoniker + '_5';
        if aFootprint.ZoneDescription <> '' then
          newFootPrint.ZoneDescription := aFootprint.ZoneDescription + '_5';
        newFootPrint.FloorNum := aFootprint.FloorNum;
        newFootPrint.FloorToFloorHeight := aFootprint.FloorToFloorHeight;
        newFootPrint.AddPoint(aFootprint.End1 - PerimDepth,
          aFootprint.Width1 - aFootprint.Offset1 - PerimDepth,
          FloortoFloorHeight);
        newFootPrint.AddPoint(aFootprint.Length1 - aFootprint.End2 + PerimDepth,
          aFootprint.Width1 - aFootprint.Offset1 - PerimDepth,
          FloortoFloorHeight);
        newFootPrint.AddPoint(aFootprint.Length1 - aFootprint.End2,
          aFootprint.Width1 - aFootprint.Offset1,
          FloortoFloorHeight);
        newFootPrint.AddPoint(aFootprint.End1,
          aFootprint.Width1 - aFootprint.Offset1,
          FloortoFloorHeight);

        newFootPrint := AddFootPrint('Custom');
        newFootPrint.ZoneLayout := 'Minimum Zones';
        if aFootprint.ZoneNameMoniker <> '' then
          newFootPrint.ZoneNameMoniker := aFootprint.ZoneNameMoniker + '_6';
        if aFootprint.ZoneDescription <> '' then
          newFootPrint.ZoneDescription := aFootprint.ZoneDescription + '_6';
        newFootPrint.FloorNum := aFootprint.FloorNum;
        newFootPrint.FloorToFloorHeight := aFootprint.FloorToFloorHeight;
        newFootPrint.AddPoint(aFootprint.End1 - PerimDepth,
          aFootprint.Width1 - aFootprint.Offset1 - PerimDepth,
          FloortoFloorHeight);
        newFootPrint.AddPoint(aFootprint.End1,
          aFootprint.Width1 - aFootprint.Offset1,
          FloortoFloorHeight);
        newFootPrint.AddPoint(aFootprint.End1,
          aFootprint.Width1,
          FloortoFloorHeight);
        newFootPrint.AddPoint(aFootprint.End1 - PerimDepth,
          aFootprint.Width1 - PerimDepth,
          FloortoFloorHeight);

        newFootPrint := AddFootPrint('Custom');
        newFootPrint.ZoneLayout := 'Minimum Zones';
        if aFootprint.ZoneNameMoniker <> '' then
          newFootPrint.ZoneNameMoniker := aFootprint.ZoneNameMoniker + '_7';
        if aFootprint.ZoneDescription <> '' then
          newFootPrint.ZoneDescription := aFootprint.ZoneDescription + '_7';
        newFootPrint.FloorNum := aFootprint.FloorNum;
        newFootPrint.FloorToFloorHeight := aFootprint.FloorToFloorHeight;
        newFootPrint.AddPoint(PerimDepth,
          aFootprint.Width1 - PerimDepth,
          FloortoFloorHeight);
        newFootPrint.AddPoint(aFootprint.End1 - PerimDepth,
          aFootprint.Width1 - PerimDepth,
          FloortoFloorHeight);
        newFootPrint.AddPoint(aFootprint.End1,
          aFootprint.Width1,
          FloortoFloorHeight);
        newFootPrint.AddPoint(0,
          aFootprint.Width1,
          FloortoFloorHeight);

        newFootPrint := AddFootPrint('Custom');
        newFootPrint.ZoneLayout := 'Minimum Zones';
        if aFootprint.ZoneNameMoniker <> '' then
          newFootPrint.ZoneNameMoniker := aFootprint.ZoneNameMoniker + '_8';
        if aFootprint.ZoneDescription <> '' then
          newFootPrint.ZoneDescription := aFootprint.ZoneDescription + '_8';
        newFootPrint.FloorNum := aFootprint.FloorNum;
        newFootPrint.FloorToFloorHeight := aFootprint.FloorToFloorHeight;
        newFootPrint.AddPoint(0,
          0,
          FloortoFloorHeight);
        newFootPrint.AddPoint(PerimDepth,
          PerimDepth,
          FloortoFloorHeight);
        newFootPrint.AddPoint(PerimDepth,
          aFootprint.Width1 - PerimDepth,
          FloortoFloorHeight);
        newFootPrint.AddPoint(0,
          aFootprint.Width1,
          FloortoFloorHeight);

        newFootPrint := AddFootPrint('Custom');
        newFootPrint.ZoneLayout := 'Minimum Zones';
        if aFootprint.ZoneNameMoniker <> '' then
          newFootPrint.ZoneNameMoniker := aFootprint.ZoneNameMoniker + '_9';
        if aFootprint.ZoneDescription <> '' then
          newFootPrint.ZoneDescription := aFootprint.ZoneDescription + '_9';
        newFootPrint.FloorNum := aFootprint.FloorNum;
        newFootPrint.FloorToFloorHeight := aFootprint.FloorToFloorHeight;
        newFootPrint.AddPoint(PerimDepth,
          PerimDepth,
          FloortoFloorHeight);
        newFootPrint.AddPoint(aFootprint.Length1 - PerimDepth,
          PerimDepth,
          FloortoFloorHeight);
        newFootPrint.AddPoint(aFootprint.Length1 - aFootprint.End2 + PerimDepth,
          aFootprint.Width1 - aFootprint.Offset1 - PerimDepth,
          FloortoFloorHeight);
        newFootPrint.AddPoint(aFootprint.End1 - PerimDepth,
          aFootprint.Width1 - aFootprint.Offset1 - PerimDepth,
          FloortoFloorHeight);

        newFootPrint := AddFootPrint('Custom');
        newFootPrint.ZoneLayout := 'Minimum Zones';
        if aFootprint.ZoneNameMoniker <> '' then
          newFootPrint.ZoneNameMoniker := aFootprint.ZoneNameMoniker + '_10';
        if aFootprint.ZoneDescription <> '' then
          newFootPrint.ZoneDescription := aFootprint.ZoneDescription + '_10';
        newFootPrint.FloorNum := aFootprint.FloorNum;
        newFootPrint.FloorToFloorHeight := aFootprint.FloorToFloorHeight;
        newFootPrint.AddPoint(aFootprint.Length1 - PerimDepth,
          PerimDepth,
          FloortoFloorHeight);
        newFootPrint.AddPoint(aFootprint.Length1 - PerimDepth,
          aFootprint.Width2 - PerimDepth,
          FloortoFloorHeight);
        newFootPrint.AddPoint(aFootprint.Length1 - aFootprint.End2 + PerimDepth,
          aFootprint.Width2 - PerimDepth,
          FloortoFloorHeight);
        newFootPrint.AddPoint(aFootprint.Length1 - aFootprint.End2 + PerimDepth,
          aFootprint.Width1 - aFootprint.Offset1 - PerimDepth,
          FloortoFloorHeight);

        newFootPrint := AddFootPrint('Custom');
        newFootPrint.ZoneLayout := 'Minimum Zones';
        if aFootprint.ZoneNameMoniker <> '' then
          newFootPrint.ZoneNameMoniker := aFootprint.ZoneNameMoniker + '_11';
        if aFootprint.ZoneDescription <> '' then
          newFootPrint.ZoneDescription := aFootprint.ZoneDescription + '_11';
        newFootPrint.FloorNum := aFootprint.FloorNum;
        newFootPrint.FloorToFloorHeight := aFootprint.FloorToFloorHeight;
        newFootPrint.AddPoint(PerimDepth,
          PerimDepth,
          FloortoFloorHeight);
        newFootPrint.AddPoint(aFootprint.End1 - PerimDepth,
          aFootprint.Width1 - aFootprint.Offset1 - PerimDepth,
          FloortoFloorHeight);
        newFootPrint.AddPoint(aFootprint.End1 - PerimDepth,
          aFootprint.Width1 - PerimDepth,
          FloortoFloorHeight);
        newFootPrint.AddPoint(PerimDepth,
          aFootprint.Width1 - PerimDepth,
          FloortoFloorHeight);

        //disable the original footprint
        aFootprint.Enabled := false;

      end;
    end
    else if SameText(aFootprint.FootPrintType, 'Retail') then
    begin
      if aFootprint.Width1 = 0 then
        AspectRatio := aFootprint.Length1
      else
        AspectRatio := aFootprint.Length1 / aFootprint.Width1;

      if TotalArea = 0 then
      begin
        TotalArea := aFootprint.Length1 * aFootprint.Width1 * NumFloors;
      end;

      aFootprint.FloorPlateArea := 0;
      if NumFloors <> 0 then
        aFootprint.FloorPlateArea := TotalArea / NumFloors
      else
      begin
        T_EP_PPErrorMessage.AddErrorMessage(esFatal, 'Number of floors was 0');
        //set values here to some arbitrary value to exit gracefully
        NumFloors := 1;
        aFootprint.FloorPlateArea := 1;

      end;

      aFootprint.FloorPlateArea := TotalArea / NumFloors;

      Length := sqrt(aFootprint.FloorPlateArea * AspectRatio);
      Width := sqrt(aFootprint.FloorPlateArea / AspectRatio);

      if SameText(aFootprint.ZoneLayout, 'Minimum Zones') then
      begin
        //create three seperate zones
        newFootPrint := AddFootPrint('Custom');
        newFootPrint.ZoneLayout := 'Minimum Zones';
        if aFootprint.ZoneNameMoniker <> '' then
          newFootPrint.ZoneNameMoniker := aFootprint.ZoneNameMoniker + '_1';
        if aFootprint.ZoneDescription <> '' then
          newFootPrint.ZoneDescription := aFootprint.ZoneDescription + '_1';
        newFootPrint.FloorNum := aFootprint.FloorNum;
        newFootPrint.FloorToFloorHeight := aFootprint.FloorToFloorHeight;
        newFootPrint.AddPoint(0,
          0,
          FloortoFloorHeight);
        newFootPrint.AddPoint(Length / 2 - aFootprint.X3 / 2,
          0,
          FloortoFloorHeight);
        newFootPrint.AddPoint(Length / 2 - aFootprint.X3 / 2,
          aFootprint.Y1,
          FloortoFloorHeight);
        newFootPrint.AddPoint(Length / 2 - aFootprint.X3 / 2,
          aFootprint.Y2,
          FloortoFloorHeight);
        newFootPrint.AddPoint(aFootprint.X1,
          aFootprint.Y2,
          FloortoFloorHeight);
        newFootPrint.AddPoint(0,
          aFootprint.Y2,
          FloortoFloorHeight);

        newFootPrint := AddFootPrint('Custom');
        newFootPrint.ZoneLayout := 'Minimum Zones';
        if aFootprint.ZoneNameMoniker <> '' then
          newFootPrint.ZoneNameMoniker := aFootprint.ZoneNameMoniker + '_2';
        if aFootprint.ZoneDescription <> '' then
          newFootPrint.ZoneDescription := aFootprint.ZoneDescription + '_2';
        newFootPrint.FloorNum := aFootprint.FloorNum;
        newFootPrint.FloorToFloorHeight := aFootprint.FloorToFloorHeight;
        newFootPrint.AddPoint(Length / 2 - aFootprint.X3 / 2,
          0,
          FloortoFloorHeight);
        newFootPrint.AddPoint(Length / 2 + aFootprint.X3 / 2,
          0,
          FloortoFloorHeight);
        newFootPrint.AddPoint(Length / 2 + aFootprint.X3 / 2,
          aFootprint.Y1,
          FloortoFloorHeight);
        newFootPrint.AddPoint(Length / 2 - aFootprint.X3 / 2,
          aFootprint.Y1,
          FloortoFloorHeight);

        newFootPrint := AddFootPrint('Custom');
        newFootPrint.ZoneLayout := 'Minimum Zones';
        if aFootprint.ZoneNameMoniker <> '' then
          newFootPrint.ZoneNameMoniker := aFootprint.ZoneNameMoniker + '_3';
        if aFootprint.ZoneDescription <> '' then
          newFootPrint.ZoneDescription := aFootprint.ZoneDescription + '_3';
        newFootPrint.FloorNum := aFootprint.FloorNum;
        newFootPrint.FloorToFloorHeight := aFootprint.FloorToFloorHeight;
        newFootPrint.AddPoint(Length / 2 + aFootprint.X3 / 2,
          0,
          FloortoFloorHeight);
        newFootPrint.AddPoint(Length,
          0,
          FloortoFloorHeight);
        newFootPrint.AddPoint(Length,
          aFootprint.Y2,
          FloortoFloorHeight);
        newFootPrint.AddPoint(Length - aFootprint.X2,
          aFootprint.Y2,
          FloortoFloorHeight);
        newFootPrint.AddPoint(Length / 2 + aFootprint.X3 / 2,
          aFootprint.Y2,
          FloortoFloorHeight);
        newFootPrint.AddPoint(Length / 2 + aFootprint.X3 / 2,
          aFootprint.Y1,
          FloortoFloorHeight);

        newFootPrint := AddFootPrint('Custom');
        newFootPrint.ZoneLayout := 'Minimum Zones';
        if aFootprint.ZoneNameMoniker <> '' then
          newFootPrint.ZoneNameMoniker := aFootprint.ZoneNameMoniker + '_4';
        if aFootprint.ZoneDescription <> '' then
          newFootPrint.ZoneDescription := aFootprint.ZoneDescription + '_4';
        newFootPrint.FloorNum := aFootprint.FloorNum;
        newFootPrint.FloorToFloorHeight := aFootprint.FloorToFloorHeight;
        newFootPrint.AddPoint(Length / 2 - aFootprint.X3 / 2,
          aFootprint.Y1,
          FloortoFloorHeight);
        newFootPrint.AddPoint(Length / 2 + aFootprint.X3 / 2,
          aFootprint.Y1,
          FloortoFloorHeight);
        newFootPrint.AddPoint(Length / 2 + aFootprint.X3 / 2,
          aFootprint.Y2,
          FloortoFloorHeight);
        newFootPrint.AddPoint(Length / 2 - aFootprint.X3 / 2,
          aFootprint.Y2,
          FloortoFloorHeight);

        newFootPrint := AddFootPrint('Custom');
        newFootPrint.ZoneLayout := 'Minimum Zones';
        if aFootprint.ZoneNameMoniker <> '' then
          newFootPrint.ZoneNameMoniker := aFootprint.ZoneNameMoniker + '_5';
        if aFootprint.ZoneDescription <> '' then
          newFootPrint.ZoneDescription := aFootprint.ZoneDescription + '_5';
        newFootPrint.FloorNum := aFootprint.FloorNum;
        newFootPrint.FloorToFloorHeight := aFootprint.FloorToFloorHeight;
        newFootPrint.AddPoint(0,
          aFootprint.Y2,
          FloortoFloorHeight);
        newFootPrint.AddPoint(aFootprint.X1,
          aFootprint.Y2,
          FloortoFloorHeight);
        newFootPrint.AddPoint(aFootprint.X1,
          Width - aFootprint.Y3,
          FloortoFloorHeight);
        newFootPrint.AddPoint(0,
          Width - aFootprint.Y3,
          FloortoFloorHeight);

        newFootPrint := AddFootPrint('Custom');
        newFootPrint.ZoneLayout := 'Minimum Zones';
        if aFootprint.ZoneNameMoniker <> '' then
          newFootPrint.ZoneNameMoniker := aFootprint.ZoneNameMoniker + '_6';
        if aFootprint.ZoneDescription <> '' then
          newFootPrint.ZoneDescription := aFootprint.ZoneDescription + '_6';
        newFootPrint.FloorNum := aFootprint.FloorNum;
        newFootPrint.FloorToFloorHeight := aFootprint.FloorToFloorHeight;
        newFootPrint.AddPoint(aFootprint.X1,
          aFootprint.Y2,
          FloortoFloorHeight);
        newFootPrint.AddPoint(Length / 2 - aFootprint.X3 / 2,
          aFootprint.Y2,
          FloortoFloorHeight);
        newFootPrint.AddPoint(Length / 2 + aFootprint.X3 / 2,
          aFootprint.Y2,
          FloortoFloorHeight);
        newFootPrint.AddPoint(Length - aFootprint.X2,
          aFootprint.Y2,
          FloortoFloorHeight);
        newFootPrint.AddPoint(Length - aFootprint.X2,
          Width - aFootprint.Y3,
          FloortoFloorHeight);
        newFootPrint.AddPoint(aFootprint.X1,
          Width - aFootprint.Y3,
          FloortoFloorHeight);

        newFootPrint := AddFootPrint('Custom');
        newFootPrint.ZoneLayout := 'Minimum Zones';
        if aFootprint.ZoneNameMoniker <> '' then
          newFootPrint.ZoneNameMoniker := aFootprint.ZoneNameMoniker + '_7';
        if aFootprint.ZoneDescription <> '' then
          newFootPrint.ZoneDescription := aFootprint.ZoneDescription + '_7';
        newFootPrint.FloorNum := aFootprint.FloorNum;
        newFootPrint.FloorToFloorHeight := aFootprint.FloorToFloorHeight;
        newFootPrint.AddPoint(Length - aFootprint.X2,
          aFootprint.Y2,
          FloortoFloorHeight);
        newFootPrint.AddPoint(Length,
          aFootprint.Y2,
          FloortoFloorHeight);
        newFootPrint.AddPoint(Length,
          Width - aFootprint.Y3,
          FloortoFloorHeight);
        newFootPrint.AddPoint(Length - aFootprint.X2,
          Width - aFootprint.Y3,
          FloortoFloorHeight);

        newFootPrint := AddFootPrint('Custom');
        newFootPrint.ZoneLayout := 'Minimum Zones';
        if aFootprint.ZoneNameMoniker <> '' then
          newFootPrint.ZoneNameMoniker := aFootprint.ZoneNameMoniker + '_8';
        if aFootprint.ZoneDescription <> '' then
          newFootPrint.ZoneDescription := aFootprint.ZoneDescription + '_8';
        newFootPrint.FloorNum := aFootprint.FloorNum;
        newFootPrint.FloorToFloorHeight := aFootprint.FloorToFloorHeight;
        newFootPrint.AddPoint(0,
          Width - aFootprint.Y3,
          FloortoFloorHeight);
        newFootPrint.AddPoint(aFootprint.X1,
          Width - aFootprint.Y3,
          FloortoFloorHeight);
        newFootPrint.AddPoint(Length - aFootprint.X2,
          Width - aFootprint.Y3,
          FloortoFloorHeight);
        newFootPrint.AddPoint(Length,
          Width - aFootprint.Y3,
          FloortoFloorHeight);
        newFootPrint.AddPoint(Length,
          Width,
          FloortoFloorHeight);
        newFootPrint.AddPoint(0,
          Width,
          FloortoFloorHeight);

        //disable the original footprint
        aFootprint.Enabled := false;
      end;

    end; //retail
  end;

  iSec := -1;
  for iFP := 0 to Footprints.Count - 1 do
  begin
    if T_EP_Footprint(Footprints[iFP]).Enabled then
    begin
      aFootprint := T_EP_Footprint(Footprints[iFP]);
      inc(iSec);
      if SameText(aFootprint.ZoneLayout, 'Minimum Zones') then
      begin
        if not BuildingFootPrint then
        begin
          CreateMinimalZoning(aFootprint, aFootprint.FloorNum, iSec);
        end
        else
        begin
          //create for all floors
          TmpNumFloors := NumFloors;
          if not SuppressFloorMultipliers then
          begin
            if NumFloors >= 4 then
              TmpNumFloors := 3
          end;

          for iFlr := 1 to TmpNumFloors do
          begin
            CreateMinimalZoning(aFootprint, iFlr, iSec);
          end;
        end;
      end
    end; //for footprints
  end;

  if PlenumHeight <> 0 then
  begin
    AddPlenumZones; //todo: add plenums
  end;

  //figure out multiplier for middle floors
  multBy := 1;
  floorMultiplier := False;
  if (not SuppressFloorMultipliers) and (NumFloors >= 4) then
  begin
    multBy := NumFloors - 2;
    floorMultiplier := True;
  end;

  // set floor types and multipliers
  for i := 0 to Zones.Count - 1 do
  begin
    zone := T_EP_Zone(zones[i]);
    Zone.FloorMultiplier := floorMultiplier;

    if Zone.FloorInfo.FloorNumber = 1 then
    begin
      // ground floor
      Zone.FloorInfo.FloorType := ftGround;

      if floorMultiplier then
        Zone.FloorMultiplierVal := 1;
    end
    else if Zone.FloorInfo.FloorNumber = TmpNumFloors then
    begin
      // top floor
      Zone.FloorInfo.FloorType := ftTop;

      if floorMultiplier then
        Zone.FloorMultiplierVal := 1;
    end
    else
    begin
      // middle floor
      Zone.FloorInfo.FloorType := ftMiddle;

      if floorMultiplier then
        Zone.FloorMultiplierVal := multBy;
    end;
  end;

  // possibly create an attic
  if (AtticHeight <> 0) or (RoofTiltAngle <> 0) then
  begin
    CreateAtticZoning;
  end;

  //todo: add tilted roof
end;

procedure T_EP_Geometry.Finalize;
begin
  inherited;
end;

procedure T_EP_Geometry.ProcessCustomXYZ(aNode: TXmlNode);
var
  Zone: T_EP_Zone;
  theta2: double;
  aSurf: T_EP_Surface;
  ndCustomXYZ: TXmlNode;
  lSurfs: TList;
  iSurf: Integer;
  ndSurf: tXmlNode;
  sTest: string;
  sSpecificType: string;
  lVertices: TList;
  lSubSurfs: TList;
  lShading: TList;
  iVert: Integer;
  ndVert: TxmlNode;
  x1: double;
  y1: double;
  z1: double;
  maxZ, minZ: double;
  iSubSurf: Integer;
  iShading: Integer;
  ndSubSurf: TXmlNode;
  ndShading: TXmlNode;
  newSubSurface: T_EP_SubSurface;
  newAttachedShading: T_EP_AttachedShading;
  norm: T_EP_Vector;
  iTest: Integer;
  aTestSurf: T_EP_Surface;
  sZoneType: string;
  sConstruction: string;
  sOutsideEnvironment: string;
  sSolarExposure: string;
  sWindExposure: string;
  sOutsideObject: string;
  floorMultiplier: integer;
begin

  Zone := T_EP_Zone.Create;

  Zone.Name := StringValueFromPath(aNode, 'Name', False);
  //writeln('Processing custom XYZ input for zone ' + Zone.Name);

  Zone.OccupiedConditioned := not BooleanValueFromPath(aNode, 'ZoneNotOccupied', False);

  sZoneType := StringValueFromPath(aNode, 'ZoneType', False, 'NORMAL');

  Zone.FloorInfo.FloorNumber := IntegerValueFromPath(ANode, 'FloorNumber', -9999);
  if Zone.FloorInfo.FloorNumberKnown then
  begin
    if Zone.FloorInfo.FloorNumber <= 0 then
      Zone.FloorInfo.FloorType := ftBasement
    else if Zone.FloorInfo.FloorNumber = 1 then
      Zone.FloorInfo.FloorType := ftGround
    else if Zone.FloorInfo.FloorNumber = T_EP_Geometry(Geometry).NumFloors then
      Zone.FloorInfo.FloorType := ftGround
    else
      Zone.FloorInfo.FloorType := ftMiddle;
  end;

  //What about Multipliers < 1
  floorMultiplier := IntegerValueFromPath(aNode, 'FloorMultiplier', 1);
  if (floorMultiplier <> 1) then
  begin
    Zone.FloorMultiplier := true;
    Zone.FloorMultiplierVal := floorMultiplier;
  end;

  ndCustomXYZ := aNode.FindNode('CustomXYZ');
  if assigned(ndCustomXYZ) then
  begin
    Zone.NorthAxis := FloatValueFromPath(ndCustomXYZ, 'NorthAxis');
    Zone.XOrigin := FloatValueFromPath(ndCustomXYZ, 'XOrigin');
    Zone.YOrigin := FloatValueFromPath(ndCustomXYZ, 'YOrigin');
    Zone.ZOrigin := FloatValueFromPath(ndCustomXYZ, 'ZOrigin');
    Zone.CeilingHeight := FloatValueFromPath(ndCustomXYZ, 'ZoneHeight', -9999);
    Zone.AirVolume := FloatValueFromPath(ndCustomXYZ, 'ZoneVolume', -9999);

    // will read zone multiplier when processing zone loads
    if SameText(sZoneType, 'Attic') then
      Zone.typ := ztAttic
    else if SameText(sZoneType, 'Plenum') then
      Zone.typ := ztPlenum
    else
      Zone.Typ := ztNormal;
  end;

  //get all the surfaces for this zone
  lSurfs := TList.Create;
  lSubSurfs := TList.Create;
  lShading := TList.Create;
  lVertices := TList.Create;
  try
    ndCustomXYZ.FindNodes('CustomXYZSurfaces',lSurfs);
    for iSurf := 0 to lSurfs.Count-1 do
    begin
      ndSurf := TXmlNode(lSurfs[iSurf]);
      aSurf := T_EP_Surface.Create;
      aSurf.ZoneName := Zone.Name;
      aSurf.Name := StringValueFromPath(ndSurf, 'SurfaceName', False);

      //check if the construction is an air-wall - this is a special case for
      //for reading in the benchmark files only.  This can be handled in
      //other parts of the xml for other cases.
      sConstruction := StringValueFromPath(ndSurf, 'ConstructionName', false);
      if SameText(sConstruction, 'Airwall') then
        sConstruction := 'AIR-WALL'  //this is a standard construction
      else if (sConstruction = '') then
        sConstruction := 'Default'; // will result in no-op in SetConstruction
      aSurf.SetConstruction(sConstruction);

      // determine the surface type, Typ defaults to stUnknown
      sTest := StringValueFromPath(ndSurf, 'SurfaceType');
      if SameText(sTest, 'Wall') then
        aSurf.SetType(stWall)
      else if SameText(sTest, 'Floor') then
        aSurf.SetType(stFloor)
      else if SameText(sTest, 'Ceiling') then
        aSurf.SetType(stCeiling)
      else if SameText(sTest, 'Roof') then
        aSurf.SetType(stCeiling); // We have no roof type, distinguished only by specific types

      // read in outside environment, defaults to oeUnknown
      sOutsideEnvironment := StringValueFromPath(ndSurf, 'OutsideFaceEnv');
      if SameText(sOutsideEnvironment, 'OtherZoneSurface') then
        aSurf.SetOutsideEnvironment(oeOtherZoneSurface)
      else if SameText(sOutsideEnvironment, 'Surface') then
        aSurf.SetOutsideEnvironment(oeOtherZoneSurface)
      else if SameText(sOutsideEnvironment, 'UnenteredOtherZoneSurface') then
        aSurf.SetOutsideEnvironment(oeUnenteredOtherZoneSurface)
      else if SameText(sOutsideEnvironment, 'Adiabatic') then
        aSurf.SetOutsideEnvironment(oeAdiabatic)
      else if SameText(sOutsideEnvironment, 'Outdoors') then
        aSurf.SetOutsideEnvironment(oeExteriorEnvironment)
      else if SameText(sOutsideEnvironment, 'ExteriorEnvironment') then
        aSurf.SetOutsideEnvironment(oeExteriorEnvironment)
      else if SameText(sOutsideEnvironment, 'Ground') then
        aSurf.SetOutsideEnvironment(oeGround)
      else if SameText(sOutsideEnvironment, 'OtherSideCoeff') then
        aSurf.SetOutsideEnvironment(oeOtherSideCoeff)
      else if SameText(sOutsideEnvironment, 'OtherSideCoefficients') then
        aSurf.SetOutsideEnvironment(oeOtherSideCoeff)
      else if SameText(sOutsideEnvironment, 'OtherSideConditionsModel') then
        aSurf.SetOutsideEnvironment(oeOtherSideConditionsModel)
      else if SameText(sOutsideEnvironment, 'TranspiredSolarCollector') then
        aSurf.SetOutsideEnvironment(oeTranspiredSolarCollector);

      // read in outside object, defaults to ''
      sOutsideObject := StringValueFromPath(ndSurf, 'OutsideFaceEnvObject', False);
      //set boundary condition model if user selects transpired solar collector
      if SameText(sOutsideEnvironment, 'TranspiredSolarCollector') then
        sOutsideObject := 'UTSC_BCModel';
      if (sOutsideObject <> '') then
        aSurf.SetOutsideObject(sOutsideObject);

      // read in solar exposure, defaults to seUnknown
      sSolarExposure := StringValueFromPath(ndSurf, 'SolarExposure', false);
      if SameText(sSolarExposure, 'SunExposed') then
        aSurf.SetSolarExposure(seSunExposed)
      else if SameText(sSolarExposure, 'NoSun') then
        aSurf.SetSolarExposure(seNoSun);

      // read in wind exposure, defaults to seUnknown
      sWindExposure := StringValueFromPath(ndSurf, 'WindExposure', false);
      if SameText(sWindExposure, 'WindExposed') then
        aSurf.SetWindExposure(weWindExposed)
      else if SameText(sWindExposure, 'NoWind') then
        aSurf.SetWindExposure(weNoWind);

      // Construction, SolarExposure, WindExposure, OutsideEnvironment, and OutsideObject
      // are all write once objects, therefore he who writes first wins, this allows
      // values from the xml to trump automatic routines

      // SpecificTyp will remain as sstUnknown in this function
      // it will be set in Building.FindAdjacentSurface

      lVertices.Clear;
      // VERY IMPORTANT: USE NodesByName instead of FindNode
      // NodesByName only operates at current level
      ndSurf.NodesByName('Vertices', lVertices);
      for iVert := 0 to lVertices.count-1 do
      begin
        ndVert := TxmlNode(lVertices[iVert]);
        x1 := FloatValueFromAttribute(ndVert, 'X1');
        y1 := FloatValueFromAttribute(ndVert, 'Y1');
        z1 := FloatValueFromAttribute(ndVert, 'Z1');
        aSurf.Verts.AddVert(x1, y1, z1);
        //for determining transpired solar collector sizes
        if SameText(sOutsideEnvironment, 'TranspiredSolarCollector') then
        begin
          if iVert = 0 then
          begin
            MaxZ := z1;
            MinZ := z1;
          end
          else
          begin
            MaxZ := Max(MaxZ, z1);
            MinZ := Min(MinZ, z1);
          end;
        end;
      end;
      aSurf.Finalize();

      //for determining transpired solar collector sizes
      if SameText(sOutsideEnvironment, 'TranspiredSolarCollector') then
      begin
        TranspiredSolarCollectorSurfaces.Add(aSurf.Name);
        TranspiredSolarCollectorArea.Add(FloatToStr(AreaPolygon(aSurf.Verts)));
        TranspiredSolarCollectorMaxZ.Add(FloatToStr(MaxZ));
        TranspiredSolarCollectorMinZ.Add(FloatToStr(MinZ));
      end;

      // find normal, angle, and length of surface as well as if surface is ground coupled
      aSurf.FindWallProperties;

      // Process all of the boundary conditions data that has been read in so far
      // must occur after find wall properties
      // anything remaining unknown will be set in Building.FinalizeBoundaryConditions
      if (aSurf.OutsideEnvironment <> oeUnknown) then
      begin

        // look for warnings and errors
        if (aSurf.OutsideEnvironment = oeOtherZoneSurface) or
           (aSurf.OutsideEnvironment = oeUnenteredOtherZoneSurface) or
           (aSurf.OutsideEnvironment = oeAdiabatic) then
        begin
          // must have outside object set, no wind and no sun
          aSurf.AssertOutsideObjectSet(true);
          aSurf.AssertSolarExposure(seNoSun);
          aSurf.AssertWindExposure(weNoWind);
        end
        else if (aSurf.OutsideEnvironment = oeExteriorEnvironment) then
        begin
          // no outside object
          aSurf.AssertOutsideObjectSet(false);
        end
        else if (aSurf.OutsideEnvironment = oeGround) then
        begin
          // no outside object, no sun or wind
          aSurf.AssertOutsideObjectSet(false);
          aSurf.AssertSolarExposure(seNoSun);
          aSurf.AssertWindExposure(weNoWind);
        end
        else if (aSurf.OutsideEnvironment = oeOtherSideCoeff) or
                (aSurf.OutsideEnvironment = oeOtherSideConditionsModel) or
                (aSurf.OutsideEnvironment = oeTranspiredSolarCollector) then
        begin
          // must have an outside object
          aSurf.AssertOutsideObjectSet(true);
        end;

        // process entered boundary conditions
        case aSurf.OutsideEnvironment of
          oeOtherZoneSurface: aSurf.SetSpecificType(false, Zone.typ, Zone.typ, aSurf.GroundCoupled);
          oeUnenteredOtherZoneSurface: aSurf.SetSpecificType(false, Zone.typ, Zone.typ, aSurf.GroundCoupled);
          oeExteriorEnvironment: aSurf.SetSpecificType(true, Zone.typ, Zone.typ, aSurf.GroundCoupled);
          oeGround: aSurf.SetSpecificType(true, Zone.typ, Zone.typ, true);
          oeOtherSideCoeff: aSurf.SetSpecificType(true, Zone.typ, Zone.typ, aSurf.GroundCoupled);  // is this really exterior?
          oeOtherSideConditionsModel: aSurf.SetSpecificType(true, Zone.typ, Zone.typ, aSurf.GroundCoupled); // is this really exterior?
          oeTranspiredSolarCollector: aSurf.SetSpecificType(true, Zone.typ, Zone.typ, aSurf.GroundCoupled); // is this really exterior?
          oeAdiabatic: aSurf.SetSpecificType(false, Zone.typ, Zone.typ, aSurf.GroundCoupled);
        end;

      end
      else
      begin
          // look for warnings and errors

          // no outside object
          aSurf.AssertOutsideObjectSet(false);
      end;

      // add the surface to the zone
      Zone.AddSurface(aSurf);

      //todo: other objects to grab
      //daylighting device tubular

      //add the subsurfaces to the surface
      lSubSurfs.Clear;
      ndSurf.FindNodes('CustomXYZSubSurfaces',lSubSurfs);
      for iSubSurf := 0 to lSubSurfs.Count-1 do
      begin
        ndSubSurf := TXmlNode(lSubSurfs[iSubSurf]);
        sTest := StringValueFromPath(ndSubSurf, 'SubSurfaceType', false);
        sSpecificType := StringValueFromPath(ndSubSurf, 'SubSurfaceSpecificType', false);

        if SameText(sTest, 'Door') then
        begin
          newSubSurface := T_EP_Door.Create;
          if SameText(sSpecificType, 'Swinging') then
            T_EP_Door(newSubSurface).DoorType := dtDoor
          else if SameText(sSpecificType, 'Non-Swinging') then
            T_EP_Door(newSubSurface).DoorType := dtNonSwingingDoor;

        end
        else if SameText(sTest, 'GlassDoor') then
        begin
          newSubSurface := T_EP_Door.Create;
          T_EP_Door(newSubSurface).DoorType := dtGlassDoor;
          
        end
        else if SameText(sTest, 'Window') then
        begin
          newSubSurface := T_EP_Window.Create;
          T_EP_Window(newSubSurface).WindowType := wtViewGlass;

        end
        else if SameText(sTest, 'DaylightWindow') then
        begin
          newSubSurface := T_EP_Window.Create;
          T_EP_Window(newSubSurface).WindowType := wtDaylightingGlass;

        end
        else if SameText(sTest, 'Skylight') then
        begin
           newSubSurface := T_EP_Skylight.Create;
           T_EP_Skylight(newSubSurface).SkylightType := stSkylight;

        end
        else if sTest = 'TDD:Dome' then
        begin
          newSubSurface := T_EP_Skylight.Create;
          T_EP_Skylight(newSubSurface).SkylightType := stDome;

        end
        else if sTest = 'TDD:Diffuser' then
        begin
          newSubSurface := T_EP_Skylight.Create;
          T_EP_Skylight(newSubSurface).SkylightType := stDiffuser;

        end
        else
        begin
          // DLM: what about TDD, TDD:Tube objects ???
          // DLM: don't mess with other objects
          continue;
        end;

        // set construction name
        if not ((StringValueFromPath(ndSubSurf, 'ConstructionName') = '') or
                 SameText(StringValueFromPath(ndSubSurf, 'ConstructionName'),'Default')) then
            newSubSurface.Construction := StringValueFromPath(ndSubSurf, 'ConstructionName', False);

        // set outside object
        if not (StringValueFromPath(ndSubSurf, 'OutsideFaceEnvObject') = '') then
            newSubSurface.OutsideObject := StringValueFromPath(ndSubSurf, 'OutsideFaceEnvObject', False);

        newSubSurface.Nrm := aSurf.Nrm;
        newSubSurface.Name := StringValueFromPath(ndSubSurf, 'SubSurfaceName', False);
        newSubSurface.SurfaceName := aSurf.Name;

        // DLM: why override a 0 multiplier from file?
        newSubSurface.Multiplier := FloatValueFromPath(ndSubSurf, 'Multiplier', 1);
        if newSubSurface.Multiplier = 0 then
        begin
          newSubSurface.Multiplier := 1;
        end;

        lVertices.Clear;
        // VERY IMPORTANT: USE NodesByName instead of FindNode,
        // NodesByName only operates at current level
        ndSubSurf.NodesByName('SubVertices', lVertices);
        for iVert := 0 to lVertices.count-1 do
        begin
          ndVert := TxmlNode(lVertices[iVert]);
          x1 := FloatValueFromAttribute(ndVert, 'X1');
          y1 := FloatValueFromAttribute(ndVert, 'Y1');
          z1 := FloatValueFromAttribute(ndVert, 'Z1');
          newSubSurface.Verts.AddVert(x1, y1, z1);

          if iVert = 0 then
          begin
            maxZ := z1;
            minZ := z1;
          end
          else
          begin
            maxZ := max(maxZ, z1);
            minZ := min(minZ, z1);
          end;
        end;
        newSubSurface.Finalize();

        //ejb: custom TDD
        if SameText(sTest, 'TDD:Dome') and not (StringValueFromPath(ndSubSurf, 'OutsideFaceEnvObject', False) = '') then
        begin
          aCustomTDD := T_EP_CustomTDD.Create;
          Zone.AddCustomTDD(aCustomTDD);
          aCustomTDD.DomeName := StringValueFromPath(ndSubSurf, 'SubSurfaceName', False);
          aCustomTDD.DiffuserName := StringValueFromPath(ndSubSurf, 'OutsideFaceEnvObject', False);
          aCustomTDD.Diameter := SQRT((4/Pi) * AreaPolygon(newSubSurface.Verts));
          aCustomTDD.ZoneName := Zone.Name;
        end;

        if (newSubSurface is T_EP_VerticalSubSurface) then
        begin
          //get the top of the window/door
          T_EP_VerticalSubSurface(newSubSurface).Top := maxZ;
          T_EP_VerticalSubSurface(newSubSurface).Bottom := minZ;
          T_EP_VerticalSubSurface(newSubSurface).Height := maxZ - minZ;
        end;

        // if window check less and than or equal to 4 verts
        if SameText(sTest, 'Window') then
        begin
          //if the number of vertices is greater than 4 then report
          //an error, delete the newWin, and continue
          // DLM: can doors have more than
          if lVertices.Count > 4 then
          begin
            T_EP_PPErrorMessage.AddErrorMessage(esWarning, 'Window' + newSubSurface.Name + ' has more than 4 vertices');
            newSubSurface.Free;
          end
          else
          begin
            aSurf.AddSubSurface(newSubsurface);
          end;
        end
        else
        begin
          aSurf.AddSubSurface(newSubsurface);
        end;
      end;
      aSurf.GetWindowArea;

      //add attached shading to the surface
      lShading.Clear;
      ndSurf.FindNodes('CustomXYZShading',lShading);
      for iShading := 0 to lShading.Count-1 do
      begin
        ndShading := TXmlNode(lShading[iShading]);
        newAttachedShading := T_EP_AttachedShading.Create;
        newAttachedShading.Name := StringValueFromPath(ndShading, 'ShadingName', False);
        newAttachedShading.SurfaceName := aSurf.Name;
        // TODO: DLM, handle attached shading schedule

        lVertices.Clear;
        // VERY IMPORTANT: USE NodesByName instead of FindNode, NodesByName only operates at current level
        ndShading.NodesByName('ShadingVertices', lVertices);
        for iVert := 0 to lVertices.count-1 do
        begin
          ndVert := TxmlNode(lVertices[iVert]);
          x1 := FloatValueFromAttribute(ndVert, 'X1');
          y1 := FloatValueFromAttribute(ndVert, 'Y1');
          z1 := FloatValueFromAttribute(ndVert, 'Z1');
          newAttachedShading.Verts.AddVert(x1, y1, z1);
        end;

        //DLM:  require that all shading face "up"
        norm := VertsSurfaceNormal(newAttachedShading.Verts);
        if norm.k < 0 then
          newAttachedShading.Verts.Reverse;

        newAttachedShading.Finalize();

        aSurf.Shading.Add(newAttachedShading);
      end;
    end;
  finally
    lSurfs.free;
    lSubSurfs.free;
    lShading.Free;
    lVertices.Free;
  end;


end;

procedure T_EP_Geometry.ProcessDetachedShadingCustomXYZ(aNode: TXmlNode);
var
  aShade: T_EP_DetachedShading;
  lVertices: TList;
  iVert: Integer;
  ndVert: TxmlNode;
  norm: T_EP_Vector;
  x1: double;
  y1: double;
  z1: double;
begin
  aShade := T_EP_DetachedShading.Create;
  aShade.Name := StringValueFromPath(aNode, 'SurfaceName', False);
  aShade.SurfaceType := StringValueFromPath(aNode, 'SurfaceType', False);
  aShade.ShadingTransmittanceSchedule := StringValueFromPath(aNode, 'ShadingTransmittanceSchedule', False);

  lVertices := TList.Create;
  try
    lVertices.Clear;
    // VERY IMPORTANT: USE NodesByName instead of FindNode, NodesByName only operates at current level
    aNode.NodesByName('Vertices', lVertices);
    for iVert := 0 to lVertices.count-1 do
    begin
      ndVert := TxmlNode(lVertices[iVert]);
      x1 := FloatValueFromAttribute(ndVert, 'X1');
      y1 := FloatValueFromAttribute(ndVert, 'Y1');
      z1 := FloatValueFromAttribute(ndVert, 'Z1');
      aShade.Verts.AddVert(x1, y1, z1);
    end;

    //DLM:  require that all shading face "up"
    norm := VertsSurfaceNormal(aShade.Verts);
    if norm.k < 0 then
      aShade.Verts.Reverse;

    aShade.Finalize();
    ExternalSurfaces.Add(aShade);
  finally
    lVertices.Free;
  end;
end;

procedure T_EP_Geometry.ToIDF;
begin
  inherited;

  if UseExternalFile then
    if Assigned(ExtFileSegment) then
      if ExtFileSegment.Count > 0 then
        IDF.AddStringList(ExtFileSegment);
end;

{ T_EP_Footprint }

procedure T_EP_Footprint.AddPoint(EPPoint: T_EP_Point);
begin
  //
  EP_Points.Add(EPPoint);
end;

procedure T_EP_Footprint.AddPoint(xValue, yValue: double; zValue: double);
var
  EPpoint: T_EP_Point;
begin
  EPpoint := T_EP_Point.Create;
  EPpoint.X1 := xValue;
  EPpoint.Y1 := yValue;
  EPPoint.Z1 := zValue; //this is typically the ceiling height
  AddPoint(EPpoint);
end;

function T_EP_Footprint.AddZoning: T_EP_Zoning;
var
  aNewZoning: T_EP_Zoning;
begin
  aNewZoning := T_EP_Zoning.Create;
  Zoning.Add(aNewZoning);
  result := aNewZoning;
end;

function T_EP_Footprint.GetPoint(index: integer): T_EP_Point;
begin
  if index < EP_Points.Count then
    result := T_EP_Point(EP_Points[index])
  else
    result := nil;
end;

constructor T_EP_Footprint.Create;
begin
  inherited;
  EP_Points := TObjectList.Create;
  Zoning := TObjectList.Create;
  Enabled := True;

end;

procedure T_EP_Footprint.ToIDF;
begin
  inherited;
end;

constructor T_EP_Zoning.Create;
begin
  inherited;
  EP_Points := TObjectList.Create;
end;

procedure T_EP_Footprint.Finalize;
begin
  inherited;
end;

{ T_EP_Zoning }

procedure T_EP_Zoning.AddPoint(EPPoint: T_EP_Point);
begin
  EP_Points.Add(EPPoint);
end;

procedure T_EP_Zoning.AddPoint(xValue, yValue: double);
var
  EPpoint: T_EP_Point;
begin
  EPpoint := T_EP_Point.Create;
  EPpoint.X1 := xValue;
  EPpoint.Y1 := yValue;
  AddPoint(EPpoint);
end;

end.
