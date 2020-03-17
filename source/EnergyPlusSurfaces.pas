////////////////////////////////////////////////////////////////////////////////
//                                                                            //
// Copyright (c) 2008-2020 Alliance for Sustainable Energy.                   //
// All rights reserved.                                                       //
//                                                                            // 
////////////////////////////////////////////////////////////////////////////////

unit EnergyPlusSurfaces;

interface

uses
  SysUtils,
  Contnrs,
  Globals,
  VectorMath,
  EnergyPlusCore,
  EnergyPlusEconomics;

type

  T_EP_SubSurface = class(TEnergyPlusGroup)
  public
    SurfaceName: string;
    Verts: T_EP_Verts;
    Multiplier: double;
    Nrm: TNormalType;
    Construction: string;
    OutsideObject: string;
    ShadingControl: string;
    procedure Finalize; override;
    constructor Create; reintroduce;
  end;

  T_EP_VerticalSubSurface = class(T_EP_SubSurface)
  public
    Height: double;
    Top: double;
    Bottom: double;
    HasOverhang : boolean;
    HasFins : boolean;
    OverhangTop: double;
    OverhangDepth: double;
    procedure Finalize; override;
    constructor Create; reintroduce;
  end;

  T_EP_Door = class(T_EP_VerticalSubSurface)
  public
    DoorType: TDoorType;
    procedure ToIDF; override;
    procedure Finalize; override;
    constructor Create; reintroduce;
  end;

  T_EP_Window = class(T_EP_VerticalSubSurface)
  public
    WindowType: TWindowType;
    procedure ToIDF; override;
    procedure Finalize; override;
    constructor Create; reintroduce;
  end;

  // TDD and SkyLight could both inheirit from HorizontalSubSurface type
  // DLM: do we want to deprecate skylight class and just use window?
  T_EP_Skylight = class(T_EP_SubSurface)
  public
    SkylightType: TSkylightType;
    procedure ToIDF; override;
    procedure Finalize; override;
    constructor Create; reintroduce;
  end;

  T_EP_TDD = class(T_EP_SubSurface)
  public
    Index: integer;
    Diffuser: T_EP_Skylight;
    Dome: T_EP_Skylight;
    TopSurfaceName: string;
    BottomSurfaceName: string;
    Diameter: double;
    ZoneName: string;
    TubeLength: double;
    procedure ToIDF; override;
    procedure Finalize; override;
    constructor Create; reintroduce;
  end;

  T_EP_CustomTDD = class(T_EP_SubSurface)
  public
    DomeName: string;
    DiffuserName: string;
    Diameter: double;
    ZoneName: string;
    ZoneLength: double;
    procedure ToIDF; override;
    procedure Finalize; override;
    constructor Create; reintroduce;
  end;

  T_EP_AttachedShading = class(TEnergyPlusGroup)
  public
    SurfaceName: string;
    Verts: T_EP_Verts;
    Cost: T_EP_Economics;
    procedure ToIDF; override;
    procedure AddCost(CostPer: double);
    function IsOverhang(): boolean;
    procedure Finalize; override;
    constructor Create; reintroduce;
  end;

  T_EP_DetachedShading = class(TEnergyPlusGroup)
  public
    Verts: T_EP_Verts;
    SurfaceType: string;
    ShadingTransmittanceSchedule: string;
    procedure ToIDF; override;
    procedure Finalize; override;
    constructor Create; reintroduce;
  end;

  T_EP_InternalMass = class(TEnergyPlusGroup)
  public
    SurfaceArea: double;
    ZoneName: string;
    Construction: string;
    InternalMassMultiplier: double;
    procedure ToIDF; override;
    procedure Finalize; override;
    constructor Create; reintroduce;
  end;

  T_EP_Surface = class(TEnergyPlusGroup)
  private
    FTyp: TSurfaceType;
    FSpecificType: TSpecificSurfaceType;
    FSolarExposure: TSolarExposure;
    FWindExposure: TWindExposure;
    FConstruction: string;
    FOutsideEnvironment: TOutsideEnvironment;
    FOutsideObject: string;

    procedure SetExteriorWallSpecificType(zoneType: TZoneType; groundCoupled: Boolean);
    procedure SetInteriorWallSpecificType(zoneType: TZoneType);
    procedure SetExteriorRoofSpecificType(zoneType: TZoneType);
    procedure SetExteriorFloorSpecificType(zoneType: TZoneType; groundCoupled: Boolean);
    procedure SetInteriorCeilingSpecificType(zoneType: TZoneType; adjZoneType: TZoneType);
    procedure SetInteriorFloorSpecificType(zoneType: TZoneType; adjZoneType: TZoneType);

  public
    // child lists
    Shading: TObjectList;
    SubSurfaces: TObjectList;

    ZoneName: string;
    Nrm: TNormalType; //this is the normal that is used in the calculations, set in FindNormal
    RelNrm: TNormalType; //this is the relative normal, before rotation
    AbsNrm: TNormalType; //this is the absolute normal, after rotation
    Angle: double;
    Tilt: double;
    WallLength: double;
    GroundCoupled : boolean;
    TopFloor: boolean;
    GrndFloor: boolean;

    Adiabatic: boolean;
    InsideEnvironment: string;

    Verts: T_EP_Verts;
    WriteObject: Boolean;
    WindowArea: double;
    SurfaceArea: double;
    RoofFen: boolean;
    RoofFenX: double;
    RoofFenY: double;
    RoofFenCntRows: Integer;
    RoofFenCntCols: Integer;
    //ZoneNum : integer;

    procedure FindWallProperties;
    procedure AddWindow(WinType: TWindowType; winApplyType: TWindowApplyType; WWR, SillHeight, HeaderHeight, EdgeOffset: double;
      WinRepresentationType: TWindowRepresentationType);
    procedure AddSubSurface(aSubSurface:T_EP_SubSurface);
    function AddSkyLight(Fraction: double; ReturnCountOnly: boolean = false): integer;
    function AddTDDs(Fraction: double; ReturnCountOnly: boolean = false): integer; //returns number added

    // TODO: DLM, both add overhang (and add fin methods) are almost identical, try to merge
    // DLM: also maybe these methods should move down to the VerticalSubSurface level
    procedure AddOverhang(Depth, Offset, CostPer: double);
    procedure AddOverhangByProjFactor(ProjFactor, Offset, CostPer: double);
    procedure AddDaylightOverhang(Depth, Offset, CostPer: double);
    procedure AddDaylightOverhangByProjFactor(ProjFactor, Offset, CostPer: double);
    procedure AddFin(Depth, Offset, Spacing, CostPer: double);
    procedure AddFinByProjFactor(ProjFactor, Offset, CostPer: double);
    procedure AddDaylightFin(Depth, Offset, Spacing, CostPer: double);
    procedure AddDaylightFinByProjFactor(ProjFactor, Offset, CostPer: double);

    procedure SetType(const typ: TSurfaceType);
    procedure SetSpecificType(const specificType: TSpecificSurfaceType); Overload;
    procedure SetSpecificType(exteriorSurface: Boolean; zoneType: TZoneType; adjZoneType: TZoneType;
                              groundCoupled: Boolean); Overload;
    procedure SetSolarExposure(const exposure: TSolarExposure);
    procedure SetWindExposure(const exposure: TWindExposure);
    procedure SetConstruction(const construction: string);
    procedure SetOutsideEnvironment(const outsideEnvironment: TOutsideEnvironment);
    procedure SetOutsideObject(const outsideObject: string);

    procedure AssertOutsideEnvironment(const outsideEnvironment: TOutsideEnvironment);
    procedure AssertOutsideObject(outsideObject: string);
    procedure AssertOutsideObjectSet(outsideObjectSet: Boolean);
    procedure AssertSolarExposure(const exposure: TSolarExposure);
    procedure AssertWindExposure(const exposure: TWindExposure);

    procedure GetWindowArea;
    procedure MakeAdiabatic(MakeOtherZoneSurfaceAdiabaticAlso: boolean = false);
    procedure ToIDF; override;
    procedure CenterPoint(var x1, y1, z1: double);
    function XCenter: double;
    function YCenter: double;
    function ZCenter: double;
    function ZMinimum: double;
    function ZMaximum: double;
    procedure Finalize; override;
    constructor Create; reintroduce;

    property Typ: TSurfaceType read FTyp;
    property SpecificType: TSpecificSurfaceType read FSpecificType;
    property SolarExposure: TSolarExposure read FSolarExposure;
    property WindExposure: TWindExposure read FWindExposure;
    property Construction: string read FConstruction;
    property OutsideEnvironment: TOutsideEnvironment read FOutsideEnvironment;
    property OutsideObject: string read FOutsideObject;
  end;

// Create external surfaces for PV
function AddPVSurface(Verts: T_EP_Verts; AreaFraction: double): string; overload;  //returns name of new surface
function AddPVSurface(Verts: T_EP_Verts; AreaFraction: double; zoneOrigin: T_EP_Vector; OrientationAngle: double; TiltAngle: double): string; overload;  //returns name of new surface

const
  offsetAmount: double = 0.01; // install PV this distance out from existing surface, meters
  deg2rad: double = Pi/180.0;  // pi radians in 180 degrees

implementation

uses Math, EnergyPlusZones, Classes, EnergyPlusConstructions, GlobalFuncs,
  EnergyPlusGeometry, EnergyPlusPPErrorMessages, PreprocSettings,
  EnergyPlusObject, EnergyPlusSettings;

{ T_EP_Surface }

procedure T_EP_Surface.AddFin(Depth, Offset, Spacing, CostPer: double);
var
  newFin: T_EP_AttachedShading;
  surfZone: T_EP_Zone;
  iVert: Integer;
  i: Integer;
  FinHeight: double;
  x1: double;
  y1: Double;
  aSurfNorm: string;
  x2: double;
  y2: double;
  width: double;
  FinDepth: Double;
  numFins: Integer;
  finSpacing: Double;
  iFin: Integer;
  aVerticalSubSurface: T_EP_VerticalSubSurface;
begin

  for i := 0 to SubSurfaces.Count - 1 do
  begin
    // only add fins to vertical sub surfaces (windows/doors)
    if not (SubSurfaces[i] is T_EP_VerticalSubSurface) then
      continue;

    // only add to view glass
    if (SubSurfaces[i] is T_EP_Window) then
    begin
      if (not (T_EP_Window(SubSurfaces[i]).WindowType = wtViewGlass)) then continue;
    end;

    // only shade glass doors in this function
    if (SubSurfaces[i] is T_EP_Door) then
    begin
      if (not (T_EP_Door(SubSurfaces[i]).DoorType = dtGlassDoor)) then continue;
    end;

    aVerticalSubSurface := T_EP_VerticalSubSurface(SubSurfaces[i]);

    // if it already has fins then pass
    if aVerticalSubSurface.HasFins then
      continue;

    FinHeight := aVerticalSubSurface.OverhangTop;
    // DLM: why is 0 used as key to set default? change to -9999
    if FinHeight = 0 then FinHeight := aVerticalSubSurface.Top;

    surfZone := GetZone(ZoneName);
    if Nrm = ntNorth then
      aSurfNorm := 'north'
    else if Nrm = ntSouth then
      aSurfNorm := 'south'
    else if Nrm = ntEast then
      aSurfNorm := 'east'
    else if Nrm = ntWest then
      aSurfNorm := 'west'
    else
      aSurfNorm := '';

    //get window width
    // todo: remove ULC dependence
    x1 := T_EP_Vector(aVerticalSubSurface.Verts[0]).i;
    x2 := T_EP_Vector(aVerticalSubSurface.Verts[3]).i;
    y1 := T_EP_Vector(aVerticalSubSurface.Verts[0]).j;
    y2 := T_EP_Vector(aVerticalSubSurface.Verts[3]).j;

    width := sqrt(power(x2 - x1, 2) + power(y2 - y1, 2));

    //get overhang depth
    FinDepth := aVerticalSubSurface.OverhangDepth;
    // DLM: why is 0 used as key to set default? change to -9999
    if FinDepth = 0 then FinDepth := 2; //if no overhang use a depth of 2 meters

    // DLM: why is 0 used as key to set default? change to -9999
    if Spacing = 0 then Spacing := 5;

    numFins := max(round((width + 2 * offset) / Spacing), 2);
    finSpacing := (width + 2 * offset) / (numFins - 1);

    for iFin := 0 to numFins - 1 do
    begin
      newFin := T_EP_AttachedShading.Create;
      newFin.Name := Name + ':shading_fin_' + aSurfNorm + '_' + inttostr(Shading.Count + 1);
      newFin.SurfaceName := Name; //surface name

      // todo: remove ULC dependence
      x1 := T_EP_Vector(aVerticalSubSurface.Verts[0]).i -
            (Offset * Cos(Angle)) +
            (finSpacing * iFin * Cos(Angle));
      y1 := T_EP_Vector(aVerticalSubSurface.Verts[0]).j -
            (Offset * Sin(Angle)) +
            (finSpacing * iFin * Sin(Angle));

      for iVert := 0 to aVerticalSubSurface.Verts.Count - 1 do //these are the sub surface vertices
      begin
        //vertical sub surface must have 4 vertices
        with T_EP_Vector(aVerticalSubSurface.Verts[iVert]) do
        begin
          case iVert of
            // todo: ULC dependence?
            0: newFin.Verts.AddVert(x1 + (FinDepth * sin(Angle)),
                y1 - (FinDepth * cos(Angle)),
                FinHeight);
            1: newFin.Verts.AddVert(x1 + (FinDepth * sin(Angle)),
                y1 - (FinDepth * cos(Angle)),
                aVerticalSubSurface.Bottom);
            2: newFin.Verts.AddVert(x1 + (0.01 * sin(Angle)),
                y1 - (0.01 * cos(Angle)),
                aVerticalSubSurface.Bottom);
            3: newFin.Verts.AddVert(x1 + (0.01 * sin(Angle)),
                y1 - (0.01 * cos(Angle)),
                FinHeight);
          end;
        end;
      end;
      newFin.AddCost(CostPer);
      newFin.Finalize();
      Shading.Add(newFin);
      aVerticalSubSurface.HasFins := true;

      {
      // DLM: Removed intersection test because it did not correctly account for multiple level buildings
      // DLM: Need better intersection tests
      //check to make sure fin is not within any zones
      bInsideFootprint := false;
      for iZones := 0 to Zones.Count - 1 do
      begin
        aZone := T_EP_Zone(Zones[iZones]);
        for iSurf := 0 to T_EP_Zone(Zones[iZones]).Surfaces.Count - 1 do
        begin
          aSurf := T_EP_Surface(T_EP_Zone(Zones[iZones]).Surfaces[iSurf]);
          if aSurf.Typ = stFloor then
          begin
            if InsidePolygon(aSurf.Verts, aZone.XOrigin, aZone.YOrigin,
              newFin.Verts, surfZone.XOrigin, surfZone.YOrigin) then
              bInsideFootprint := True;
          end;
          if bInsideFootprint then break;
        end; //for
        if bInsideFootprint then break;
      end; //for i Zones

      if not bInsideFootprint then
      begin
        newFin.AddCost(CostPer);
        Shading.Add(newFin);
        aVerticalSubSurface.HasFins := true;
      end
      else
      begin
        // DLM: why not error?
        newFin.Free;
      end;}

    end;
  end; //for sub surfaces
end;


procedure T_EP_Surface.AddFinByProjFactor(ProjFactor, Offset, CostPer: double);
var
  newFin: T_EP_AttachedShading;
  surfZone: T_EP_Zone;
  iVert: Integer;
  i: Integer;
  FinHeight: double;
  x1: double;
  y1: Double;
  aSurfNorm: string;
  width: double;
  x2: double;
  y2: double;
  FinDepth: double;
  numFins: Integer;
  iFin: Integer;
  finSpacing: double;
  aVerticalSubSurface: T_EP_VerticalSubSurface;
begin

  for i := 0 to SubSurfaces.Count - 1 do
  begin
    // only add fins to vertical sub surfaces (windows/doors)
    if not (SubSurfaces[i] is T_EP_VerticalSubSurface) then
      continue;

    // only add to view glass
    if (SubSurfaces[i] is T_EP_Window) then
    begin
      if (not (T_EP_Window(SubSurfaces[i]).WindowType = wtViewGlass)) then continue;
    end;

    // only shade glass doors in this function
    if (SubSurfaces[i] is T_EP_Door) then
    begin
      if (not (T_EP_Door(SubSurfaces[i]).DoorType = dtGlassDoor)) then continue;
    end;

    aVerticalSubSurface := T_EP_VerticalSubSurface(SubSurfaces[i]);

    // if it already has fins then pass
    if aVerticalSubSurface.HasFins then
      continue;

    FinHeight := aVerticalSubSurface.OverhangTop;
    // DLM: why is 0 used as key to set default? change to -9999
    if FinHeight = 0 then FinHeight := aVerticalSubSurface.Top;

    surfZone := GetZone(ZoneName);
    if Nrm = ntNorth then
      aSurfNorm := 'north'
    else if Nrm = ntSouth then
      aSurfNorm := 'south'
    else if Nrm = ntEast then
      aSurfNorm := 'east'
    else if Nrm = ntWest then
      aSurfNorm := 'west'
    else
      aSurfNorm := '';

    //get window width
    // todo: remove ULC dependence
    x1 := T_EP_Vector(aVerticalSubSurface.Verts[0]).i;
    x2 := T_EP_Vector(aVerticalSubSurface.Verts[3]).i;
    y1 := T_EP_Vector(aVerticalSubSurface.Verts[0]).j;
    y2 := T_EP_Vector(aVerticalSubSurface.Verts[3]).j;

    width := sqrt(power(x2 - x1, 2) + power(y2 - y1, 2));

    //get overhang depth
    FinDepth := aVerticalSubSurface.OverhangDepth;
    // DLM: why is 0 used as key to set default? change to -9999
    if FinDepth = 0 then FinDepth := 2; //if no overhang use a depth of 2 meters

    numFins := max(round((projFactor * width + 2 * offset) / FinDepth), 2);
    finSpacing := (width + 2 * offset) / (numFins - 1);

    for iFin := 0 to numFins - 1 do
    begin
      newFin := T_EP_AttachedShading.Create;
      newFin.Name := Name + ':shading_fin_' + aSurfNorm + '_' + inttostr(Shading.Count + 1);
      newFin.SurfaceName := Name; //surface name

      // todo: remove ULC dependence
      x1 := T_EP_Vector(aVerticalSubSurface.Verts[0]).i -
            (Offset * Cos(Angle)) +
            (finSpacing * iFin * Cos(Angle));
      y1 := T_EP_Vector(aVerticalSubSurface.Verts[0]).j -
            (Offset * Sin(Angle)) +
            (finSpacing * iFin * Sin(Angle));

      for iVert := 0 to aVerticalSubSurface.Verts.Count - 1 do //these are the sub surface vertices
      begin
        //vertical sub surface must have 4 vertices
        with T_EP_Vector(aVerticalSubSurface.Verts[iVert]) do
        begin
          case iVert of
            0: newFin.Verts.AddVert(x1 + (FinDepth * sin(Angle)),
                y1 - (FinDepth * cos(Angle)),
                FinHeight);
            1: newFin.Verts.AddVert(x1 + (FinDepth * sin(Angle)),
                y1 - (FinDepth * cos(Angle)),
                aVerticalSubSurface.Bottom);
            2: newFin.Verts.AddVert(x1 + (0.01 * sin(Angle)),
                y1 - (0.01 * cos(Angle)),
                aVerticalSubSurface.Bottom);
            3: newFin.Verts.AddVert(x1 + (0.01 * sin(Angle)),
                y1 - (0.01 * cos(Angle)),
                FinHeight);
          end;
        end;
      end;
      newFin.AddCost(CostPer);
      newFin.Finalize();
      Shading.Add(newFin);
      aVerticalSubSurface.HasFins := true;

      {
      // DLM: Removed intersection test because it did not correctly account for multiple level buildings
      // DLM: Need better intersection tests
      //check to make sure fin is not within any zones
      bInsideFootprint := false;
      for iZones := 0 to Zones.Count - 1 do
      begin
        aZone := T_EP_Zone(Zones[iZones]);
        for iSurf := 0 to T_EP_Zone(Zones[iZones]).Surfaces.Count - 1 do
        begin
          aSurf := T_EP_Surface(T_EP_Zone(Zones[iZones]).Surfaces[iSurf]);
          if aSurf.Typ = stFloor then
          begin
            if InsidePolygon(aSurf.Verts, aZone.XOrigin, aZone.YOrigin,
              newFin.Verts, surfZone.XOrigin, surfZone.YOrigin) then
              bInsideFootprint := True;
          end;
          if bInsideFootprint then break;
        end; //for
        if bInsideFootprint then break;
      end; //for i Zones

      if not bInsideFootprint then
      begin
        newFin.AddCost(CostPer);
        Shading.Add(newFin);
        aVerticalSubSurface.HasFins := true;
      end
      else
      begin
        // DLM: why not error?
        newFin.Free;
      end;   }

    end;
  end; //for sub surfaces
end;

procedure T_EP_Surface.AddDaylightFin(Depth, Offset, Spacing, CostPer: double);
var
  newFin: T_EP_AttachedShading;
  surfZone: T_EP_Zone;
  iVert: Integer;
  i: Integer;
  FinHeight: double;
  x1: double;
  y1: Double;
  aSurfNorm: string;
  x2: double;
  y2: double;
  width: double;
  FinDepth: Double;
  numFins: Integer;
  finSpacing: Double;
  iFin: Integer;
  aVerticalSubSurface: T_EP_VerticalSubSurface;
begin

  for i := 0 to SubSurfaces.Count - 1 do
  begin
    // only add fins to vertical sub surfaces (windows/doors)
    if not (SubSurfaces[i] is T_EP_VerticalSubSurface) then
      continue;

    // only add to daylighting glass
    if (SubSurfaces[i] is T_EP_Window) then
    begin
      if (not (T_EP_Window(SubSurfaces[i]).WindowType = wtDaylightingGlass)) then continue;
    end;

    // only shade glass doors in this function
    if (SubSurfaces[i] is T_EP_Door) then
    begin
      if (not (T_EP_Door(SubSurfaces[i]).DoorType = dtGlassDoor)) then continue;
    end;

    aVerticalSubSurface := T_EP_VerticalSubSurface(SubSurfaces[i]);

    // if it already has fins then pass
    if aVerticalSubSurface.HasFins then
      continue;

    FinHeight := aVerticalSubSurface.OverhangTop;
    // DLM: why is 0 used as key to set default? change to -9999
    if FinHeight = 0 then FinHeight := aVerticalSubSurface.Top;

    surfZone := GetZone(ZoneName);
    if Nrm = ntNorth then
      aSurfNorm := 'north'
    else if Nrm = ntSouth then
      aSurfNorm := 'south'
    else if Nrm = ntEast then
      aSurfNorm := 'east'
    else if Nrm = ntWest then
      aSurfNorm := 'west'
    else
      aSurfNorm := '';

    //get window width
    // todo: remove ULC dependence
    x1 := T_EP_Vector(aVerticalSubSurface.Verts[0]).i;
    x2 := T_EP_Vector(aVerticalSubSurface.Verts[3]).i;
    y1 := T_EP_Vector(aVerticalSubSurface.Verts[0]).j;
    y2 := T_EP_Vector(aVerticalSubSurface.Verts[3]).j;

    width := sqrt(power(x2 - x1, 2) + power(y2 - y1, 2));

    //get overhang depth
    FinDepth := aVerticalSubSurface.OverhangDepth;
    // DLM: why is 0 used as key to set default? change to -9999
    if FinDepth = 0 then FinDepth := 2; //if no overhang use a depth of 2 meters

    // DLM: why is 0 used as key to set default? change to -9999
    if Spacing = 0 then Spacing := 5;

    numFins := max(round((width + 2 * offset) / Spacing), 2);
    finSpacing := (width + 2 * offset) / (numFins - 1);

    for iFin := 0 to numFins - 1 do
    begin
      newFin := T_EP_AttachedShading.Create;
      newFin.Name := Name + ':shading_fin_' + aSurfNorm + '_' + inttostr(Shading.Count + 1);
      newFin.SurfaceName := Name; //surface name

      // todo: remove ULC dependence
      x1 := T_EP_Vector(aVerticalSubSurface.Verts[0]).i -
            (Offset * Cos(Angle)) +
            (finSpacing * iFin * Cos(Angle));
      y1 := T_EP_Vector(aVerticalSubSurface.Verts[0]).j -
            (Offset * Sin(Angle)) +
            (finSpacing * iFin * Sin(Angle));

      for iVert := 0 to aVerticalSubSurface.Verts.Count - 1 do //these are the sub surface vertices
      begin
        //vertical sub surface must have 4 vertices
        with T_EP_Vector(aVerticalSubSurface.Verts[iVert]) do
        begin
          case iVert of
            // todo: ULC dependence?
            0: newFin.Verts.AddVert(x1 + (FinDepth * sin(Angle)),
                y1 - (FinDepth * cos(Angle)),
                FinHeight);
            1: newFin.Verts.AddVert(x1 + (FinDepth * sin(Angle)),
                y1 - (FinDepth * cos(Angle)),
                aVerticalSubSurface.Bottom);
            2: newFin.Verts.AddVert(x1 + (0.01 * sin(Angle)),
                y1 - (0.01 * cos(Angle)),
                aVerticalSubSurface.Bottom);
            3: newFin.Verts.AddVert(x1 + (0.01 * sin(Angle)),
                y1 - (0.01 * cos(Angle)),
                FinHeight);
          end;
        end;
      end;
      newFin.AddCost(CostPer);
      newFin.Finalize();
      Shading.Add(newFin);
      aVerticalSubSurface.HasFins := true;
    end;
  end; //for sub surfaces
end;


procedure T_EP_Surface.AddDaylightFinByProjFactor(ProjFactor, Offset, CostPer: double);
var
  newFin: T_EP_AttachedShading;
  surfZone: T_EP_Zone;
  iVert: Integer;
  i: Integer;
  FinHeight: double;
  x1: double;
  y1: Double;
  aSurfNorm: string;
  width: double;
  x2: double;
  y2: double;
  FinDepth: double;
  numFins: Integer;
  iFin: Integer;
  finSpacing: double;
  aVerticalSubSurface: T_EP_VerticalSubSurface;
begin

  for i := 0 to SubSurfaces.Count - 1 do
  begin
    // only add fins to vertical sub surfaces (windows/doors)
    if not (SubSurfaces[i] is T_EP_VerticalSubSurface) then
      continue;

    // only add to daylighting glass
    if (SubSurfaces[i] is T_EP_Window) then
    begin
      if (not (T_EP_Window(SubSurfaces[i]).WindowType = wtDaylightingGlass)) then continue;
    end;

    // only shade glass doors in this function
    if (SubSurfaces[i] is T_EP_Door) then
    begin
      if (not (T_EP_Door(SubSurfaces[i]).DoorType = dtGlassDoor)) then continue;
    end;

    aVerticalSubSurface := T_EP_VerticalSubSurface(SubSurfaces[i]);

    // if it already has fins then pass
    if aVerticalSubSurface.HasFins then
      continue;

    FinHeight := aVerticalSubSurface.OverhangTop;
    // DLM: why is 0 used as key to set default? change to -9999
    if FinHeight = 0 then FinHeight := aVerticalSubSurface.Top;

    surfZone := GetZone(ZoneName);
    if Nrm = ntNorth then
      aSurfNorm := 'north'
    else if Nrm = ntSouth then
      aSurfNorm := 'south'
    else if Nrm = ntEast then
      aSurfNorm := 'east'
    else if Nrm = ntWest then
      aSurfNorm := 'west'
    else
      aSurfNorm := '';

    //get window width
    // todo: remove ULC dependence
    x1 := T_EP_Vector(aVerticalSubSurface.Verts[0]).i;
    x2 := T_EP_Vector(aVerticalSubSurface.Verts[3]).i;
    y1 := T_EP_Vector(aVerticalSubSurface.Verts[0]).j;
    y2 := T_EP_Vector(aVerticalSubSurface.Verts[3]).j;

    width := sqrt(power(x2 - x1, 2) + power(y2 - y1, 2));

    //get overhang depth
    FinDepth := aVerticalSubSurface.OverhangDepth;
    // DLM: why is 0 used as key to set default? change to -9999
    if FinDepth = 0 then FinDepth := 2; //if no overhang use a depth of 2 meters

    numFins := max(round((projFactor * width + 2 * offset) / FinDepth), 2);
    finSpacing := (width + 2 * offset) / (numFins - 1);

    for iFin := 0 to numFins - 1 do
    begin
      newFin := T_EP_AttachedShading.Create;
      newFin.Name := Name + ':shading_fin_' + aSurfNorm + '_' + inttostr(Shading.Count + 1);
      newFin.SurfaceName := Name; //surface name

      // todo: remove ULC dependence
      x1 := T_EP_Vector(aVerticalSubSurface.Verts[0]).i -
            (Offset * Cos(Angle)) +
            (finSpacing * iFin * Cos(Angle));
      y1 := T_EP_Vector(aVerticalSubSurface.Verts[0]).j -
            (Offset * Sin(Angle)) +
            (finSpacing * iFin * Sin(Angle));

      for iVert := 0 to aVerticalSubSurface.Verts.Count - 1 do //these are the sub surface vertices
      begin
        //vertical sub surface must have 4 vertices
        with T_EP_Vector(aVerticalSubSurface.Verts[iVert]) do
        begin
          case iVert of
            0: newFin.Verts.AddVert(x1 + (FinDepth * sin(Angle)),
                y1 - (FinDepth * cos(Angle)),
                FinHeight);
            1: newFin.Verts.AddVert(x1 + (FinDepth * sin(Angle)),
                y1 - (FinDepth * cos(Angle)),
                aVerticalSubSurface.Bottom);
            2: newFin.Verts.AddVert(x1 + (0.01 * sin(Angle)),
                y1 - (0.01 * cos(Angle)),
                aVerticalSubSurface.Bottom);
            3: newFin.Verts.AddVert(x1 + (0.01 * sin(Angle)),
                y1 - (0.01 * cos(Angle)),
                FinHeight);
          end;
        end;
      end;
      newFin.AddCost(CostPer);
      newFin.Finalize();
      Shading.Add(newFin);
      aVerticalSubSurface.HasFins := true;
    end;
  end; //for sub surfaces
end;

procedure T_EP_Surface.AddOverhang(Depth, Offset, CostPer: double);
var
  newOH: T_EP_AttachedShading;
  iVert: Integer;
  OHHeight: double;
  aSurfNorm: string;
  aVerticalSubSurface: T_EP_VerticalSubSurface;
  i: integer;
begin
  //go through every window/glass door and add overhang on surface
  for i := 0 to SubSurfaces.Count - 1 do
  begin
    // only add overhangs to vertical sub surfaces (windows/doors)
    if not (SubSurfaces[i] is T_EP_VerticalSubSurface) then continue;

    // only add to view glass
    if (SubSurfaces[i] is T_EP_Window) then
    begin
      if (not (T_EP_Window(SubSurfaces[i]).WindowType = wtViewGlass)) then continue;
    end;

    // only shade glass doors in this function
    if (SubSurfaces[i] is T_EP_Door) then
    begin
      if (not (T_EP_Door(SubSurfaces[i]).DoorType = dtGlassDoor)) then continue;
    end;

    aVerticalSubSurface := T_EP_VerticalSubSurface(SubSurfaces[i]);

    // if it already has overhang then pass
    if aVerticalSubSurface.HasOverhang then continue;

    newOH := T_EP_AttachedShading.Create;
    if Nrm = ntNorth then
      aSurfNorm := 'north'
    else if Nrm = ntSouth then
      aSurfNorm := 'south'
    else if Nrm = ntEast then
      aSurfNorm := 'east'
    else if Nrm = ntWest then
      aSurfNorm := 'west'
    else
      aSurfNorm := '';
    newOH.Name := Name + ':shading_' + aSurfNorm + '_' + inttostr(Shading.Count + 1);
    newOH.SurfaceName := Name; //surface name

    OHHeight := aVerticalSubSurface.Top;
    aVerticalSubSurface.OverhangTop := OHHeight + Offset;
    aVerticalSubSurface.OverhangDepth := Depth;
    for iVert := 0 to aVerticalSubSurface.Verts.Count - 1 do //these are the surface vertices
    begin
      //wall must have 4 vertices
      with T_EP_Vector(aVerticalSubSurface.Verts[iVert]) do
      begin
        case iVert of
          // todo: ULC dependence - yes, FIX THIS!
          0: newOH.Verts.AddVert(i + (Depth * sin(Angle)),
              j - (Depth * cos(Angle)),
              OHHeight + Offset);
          1: newOH.Verts.AddVert(i,
              j,
              OHHeight + Offset);
          2: newOH.Verts.AddVert(i,
              j,
              OHHeight + Offset);
          3: newOH.Verts.AddVert(i + (Depth * sin(Angle)),
              j - (Depth * cos(Angle)),
              OHHeight + Offset);
        end;
      end;
    end; //with window
    newOH.Finalize();

    // DLM: no check for intersection of other zone?

    newOH.AddCost(CostPer);
    Shading.Add(newOH);
    aVerticalSubSurface.HasOverhang := true;
  end;
end;

procedure T_EP_Surface.AddOverhangByProjFactor(ProjFactor, Offset, CostPer: double);
//the projection factor is for the window height plus the offset.  The Offset is a
//fraction of the total window height.
var
  newOH: T_EP_AttachedShading;
  iVert: Integer;
  OHHeight: double;
  aSurfNorm: string;
  OHDepth: double;
  OHOffset: double;
  Height: double;
  aVerticalSubSurface: T_EP_VerticalSubSurface;
  i: integer;
begin
  //go through every window/glass door and add overhang on surface
  for i := 0 to SubSurfaces.Count - 1 do
  begin
   // only add overhangs to vertical sub surfaces (windows/doors)
    if not (SubSurfaces[i] is T_EP_VerticalSubSurface) then continue;

    // only add to view glass
    if (SubSurfaces[i] is T_EP_Window) then
    begin
      if (not (T_EP_Window(SubSurfaces[i]).WindowType = wtViewGlass)) then continue;
    end;

    // only shade glass doors in this function
    if (SubSurfaces[i] is T_EP_Door) then
    begin
      if (not (T_EP_Door(SubSurfaces[i]).DoorType = dtGlassDoor)) then continue;
    end;

    aVerticalSubSurface := T_EP_VerticalSubSurface(SubSurfaces[i]);

    // if it already has overhang then pass
    if aVerticalSubSurface.HasOverhang then continue;

    newOH := T_EP_AttachedShading.Create;
    if Nrm = ntNorth then
      aSurfNorm := 'north'
    else if Nrm = ntSouth then
      aSurfNorm := 'south'
    else if Nrm = ntEast then
      aSurfNorm := 'east'
    else if Nrm = ntWest then
      aSurfNorm := 'west'
    else
      aSurfNorm := '';
    newOH.Name := Name + ':shading_' + aSurfNorm + '_' + inttostr(Shading.Count + 1);
    newOH.SurfaceName := Name; //surface name

    // TODO: DLM this looks like a control for which window to apply to, suggest move add overhang to VerticalSubSurface
    //always add the overhang to the most recently added surface
    //this will not work for individual windows
    if SubSurfaces.count = 0 then continue;

    OHHeight := aVerticalSubSurface.Top;
    Height := aVerticalSubSurface.Height;
    OHOffset := Height * Offset;
    OHDepth := ProjFactor * (Height + OHOffset);

    aVerticalSubSurface.OverhangTop := OHHeight + OHOffset;
    aVerticalSubSurface.OverhangDepth := OHDepth;
    for iVert := 0 to aVerticalSubSurface.Verts.Count - 1 do //these are the surface vertices
    begin
      //wall must have 4 vertices
      with T_EP_Vector(aVerticalSubSurface.Verts[iVert]) do
      begin
        case iVert of
          0: newOH.Verts.AddVert(i + (OHDepth * sin(Angle)),
              j - (OHDepth * cos(Angle)),
              OHHeight + OHOffset);
          1: newOH.Verts.AddVert(i,
              j,
              OHHeight + OHOffset);
          2: newOH.Verts.AddVert(i,
              j,
              OHHeight + OHOffset);
          3: newOH.Verts.AddVert(i + (OHDepth * sin(Angle)),
              j - (OHDepth * cos(Angle)),
              OHHeight + OHOffset);
        end;
      end;
    end;
    newOH.Finalize();

    // DLM: no check for intersection of other zone?

    newOH.AddCost(CostPer);
    Shading.Add(newOH);
    aVerticalSubSurface.HasOverhang := true;
  end;
end;

procedure T_EP_Surface.AddDaylightOverhang(Depth, Offset, CostPer: double);
var
  newOH: T_EP_AttachedShading;
  iVert: Integer;
  OHHeight: double;
  aSurfNorm: string;
  aVerticalSubSurface: T_EP_VerticalSubSurface;
  i: integer;
begin
  //go through every window/glass door and add overhang on surface
  for i := 0 to SubSurfaces.Count - 1 do
  begin
    // only add overhangs to vertical sub surfaces (windows/doors)
    if not (SubSurfaces[i] is T_EP_VerticalSubSurface) then continue;

    // only add to daylighting glass
    if (SubSurfaces[i] is T_EP_Window) then
    begin
      if (not (T_EP_Window(SubSurfaces[i]).WindowType = wtDaylightingGlass)) then continue;
    end;

    // only shade glass doors in this function
    if (SubSurfaces[i] is T_EP_Door) then
    begin
      if (not (T_EP_Door(SubSurfaces[i]).DoorType = dtGlassDoor)) then continue;
    end;

    aVerticalSubSurface := T_EP_VerticalSubSurface(SubSurfaces[i]);

    // if it already has overhang then pass
    if aVerticalSubSurface.HasOverhang then continue;

    newOH := T_EP_AttachedShading.Create;
    if Nrm = ntNorth then
      aSurfNorm := 'north'
    else if Nrm = ntSouth then
      aSurfNorm := 'south'
    else if Nrm = ntEast then
      aSurfNorm := 'east'
    else if Nrm = ntWest then
      aSurfNorm := 'west'
    else
      aSurfNorm := '';
    newOH.Name := Name + ':shading_' + aSurfNorm + '_' + inttostr(Shading.Count + 1);
    newOH.SurfaceName := Name; //surface name

    OHHeight := aVerticalSubSurface.Top;
    aVerticalSubSurface.OverhangTop := OHHeight + Offset;
    aVerticalSubSurface.OverhangDepth := Depth;
    for iVert := 0 to aVerticalSubSurface.Verts.Count - 1 do //these are the surface vertices
    begin
      //wall must have 4 vertices
      with T_EP_Vector(aVerticalSubSurface.Verts[iVert]) do
      begin
        case iVert of
          // todo: ULC dependence - yes, FIX THIS!
          0: newOH.Verts.AddVert(i + (Depth * sin(Angle)),
              j - (Depth * cos(Angle)),
              OHHeight + Offset);
          1: newOH.Verts.AddVert(i,
              j,
              OHHeight + Offset);
          2: newOH.Verts.AddVert(i,
              j,
              OHHeight + Offset);
          3: newOH.Verts.AddVert(i + (Depth * sin(Angle)),
              j - (Depth * cos(Angle)),
              OHHeight + Offset);
        end;
      end;
    end; //with window
    newOH.Finalize();

    // DLM: no check for intersection of other zone?

    newOH.AddCost(CostPer);
    Shading.Add(newOH);
    aVerticalSubSurface.HasOverhang := true;
  end;
end;

procedure T_EP_Surface.AddDaylightOverhangByProjFactor(ProjFactor, Offset, CostPer: double);
//the projection factor is for the window height plus the offset.  The Offset is a
//fraction of the total window height.
var
  newOH: T_EP_AttachedShading;
  iVert: Integer;
  OHHeight: double;
  aSurfNorm: string;
  OHDepth: double;
  OHOffset: double;
  Height: double;
  aVerticalSubSurface: T_EP_VerticalSubSurface;
  i: integer;
begin
  //go through every window/glass door and add overhang on surface
  for i := 0 to SubSurfaces.Count - 1 do
  begin
    // only add overhangs to vertical sub surfaces (windows/doors)
    if not (SubSurfaces[i] is T_EP_VerticalSubSurface) then continue;

    // only add to daylighting glass
    if (SubSurfaces[i] is T_EP_Window) then
    begin
      if (not (T_EP_Window(SubSurfaces[i]).WindowType = wtDaylightingGlass)) then continue;
    end;

    // only shade glass doors in this function
    if (SubSurfaces[i] is T_EP_Door) then
    begin
      if (not (T_EP_Door(SubSurfaces[i]).DoorType = dtGlassDoor)) then continue;
    end;

    aVerticalSubSurface := T_EP_VerticalSubSurface(SubSurfaces[i]);

    // if it already has overhang then pass
    if aVerticalSubSurface.HasOverhang then continue;

    newOH := T_EP_AttachedShading.Create;
    if Nrm = ntNorth then
      aSurfNorm := 'north'
    else if Nrm = ntSouth then
      aSurfNorm := 'south'
    else if Nrm = ntEast then
      aSurfNorm := 'east'
    else if Nrm = ntWest then
      aSurfNorm := 'west'
    else
      aSurfNorm := '';
    newOH.Name := Name + ':shading_' + aSurfNorm + '_' + inttostr(Shading.Count + 1);
    newOH.SurfaceName := Name; //surface name

    // TODO: DLM this looks like a control for which window to apply to, suggest move add overhang to VerticalSubSurface
    //always add the overhang to the most recently added surface
    //this will not work for individual windows
    if SubSurfaces.count = 0 then continue;

    OHHeight := aVerticalSubSurface.Top;
    Height := aVerticalSubSurface.Height;
    OHOffset := Height * Offset;
    OHDepth := ProjFactor * (Height + OHOffset);

    aVerticalSubSurface.OverhangTop := OHHeight + OHOffset;
    aVerticalSubSurface.OverhangDepth := OHDepth;
    for iVert := 0 to aVerticalSubSurface.Verts.Count - 1 do //these are the surface vertices
    begin
      //wall must have 4 vertices
      with T_EP_Vector(aVerticalSubSurface.Verts[iVert]) do
      begin
        case iVert of
          0: newOH.Verts.AddVert(i + (OHDepth * sin(Angle)),
              j - (OHDepth * cos(Angle)),
              OHHeight + OHOffset);
          1: newOH.Verts.AddVert(i,
              j,
              OHHeight + OHOffset);
          2: newOH.Verts.AddVert(i,
              j,
              OHHeight + OHOffset);
          3: newOH.Verts.AddVert(i + (OHDepth * sin(Angle)),
              j - (OHDepth * cos(Angle)),
              OHHeight + OHOffset);
        end;
      end;
    end;
    newOH.Finalize();

    // DLM: no check for intersection of other zone?

    newOH.AddCost(CostPer);
    Shading.Add(newOH);
    aVerticalSubSurface.HasOverhang := true;
  end;
end;

procedure T_EP_Surface.SetType(const typ: TSurfaceType);
begin
  if FTyp = stUnknown then
    FTyp := typ
  else if not (FTyp = typ) then
    T_EP_PPErrorMessage.AddErrorMessage(esFatal, 'Attempting to reset surface type for surface "' + Name + '"');
end;

procedure T_EP_Surface.SetSpecificType(const specificType: TSpecificSurfaceType);
begin
  if FSpecificType = sstUnknown then
    FSpecificType := specificType
  else if not (FSpecificType = specificType) then
    T_EP_PPErrorMessage.AddErrorMessage(esFatal, 'Attempting to reset specific surface type for surface "' + Name + '"');
end;

//NL: Break this out into two separate routines--one for interior and one for
//exterior.  If the zone is an interior, then we may need to know the
//condition of the adjacent zone.
procedure T_EP_Surface.SetSpecificType(exteriorSurface: Boolean;
                                       zoneType: TZoneType; adjZoneType: TZoneType;
                                       groundCoupled: Boolean);
begin
  // try to guess the correct specific type based on other parameters

  if (FTyp = stUnknown) then
  begin
    T_EP_PPErrorMessage.AddErrorMessage(esFatal, 'Base surface type unknown "' + Name + '"');
  end
  else if (FTyp = stWall) then
  begin
    if exteriorSurface then
      SetExteriorWallSpecificType(zoneType, groundCoupled)
    else
      SetInteriorWallSpecificType(zoneType);
  end
  else if (FTyp = stCeiling) then
  begin
    if exteriorSurface then
      SetExteriorRoofSpecificType(zoneType)
    else
      SetInteriorCeilingSpecificType(zoneType, adjZoneType);
  end
  else if (FTyp = stFloor) then
  begin
    if exteriorSurface then
      SetExteriorFloorSpecificType(zoneType, groundCoupled)
    else
      SetInteriorFloorSpecificType(zoneType, adjZoneType);
  end;

end;

procedure T_EP_Surface.SetExteriorWallSpecificType(zoneType: TZoneType; groundCoupled: Boolean);
begin
  if (groundCoupled) then
    SetSpecificType(sstBelowGradeExteriorWall)
  else
    SetSpecificType(sstExteriorWall);
end;

procedure T_EP_Surface.SetInteriorWallSpecificType(zoneType: TZoneType);
begin
  SetSpecificType(sstInteriorWall);
end;

procedure T_EP_Surface.SetExteriorRoofSpecificType(zoneType: TZoneType);
begin
  if (zoneType = ztAttic) then
    SetSpecificType(sstAtticRoof)
  else
    SetSpecificType(sstRoof);
end;

procedure T_EP_Surface.SetInteriorCeilingSpecificType(zoneType: TZoneType; adjZoneType: TZoneType);
begin
  //the attic ceiling is really the roof.
  if (zoneType = ztAttic) or
     (adjZoneType = ztAttic) then
    SetSpecificType(sstAtticCeiling)
  else
    SetSpecificType(sstInteriorCeiling);
end;

procedure T_EP_Surface.SetExteriorFloorSpecificType(zoneType: TZoneType; groundCoupled: Boolean);
begin
  if (not groundCoupled) then
    SetSpecificType(sstExposedFloor)
  else
    SetSpecificType(sstSlab);
end;

procedure T_EP_Surface.SetInteriorFloorSpecificType(zoneType: TZoneType; adjZoneType: TZoneType);
begin
  if (zoneType = ztAttic) or (adjZoneType = ztAttic) then
    SetSpecificType(sstAtticFloor)
  else
    SetSpecificType(sstInteriorFloor);
end;

procedure T_EP_Surface.SetSolarExposure(const exposure: TSolarExposure);
begin
  if FSolarExposure = seUnknown then
    FSolarExposure := exposure
  else if not (FSolarExposure = exposure) then
    T_EP_PPErrorMessage.AddErrorMessage(esFatal, 'Attempting to reset solar exposure for surface "' + Name + '"');
end;

procedure T_EP_Surface.SetWindExposure(const exposure: TWindExposure);
begin
  if FWindExposure = weUnknown then
    FWindExposure := exposure
  else if not (FWindExposure = exposure) then
    T_EP_PPErrorMessage.AddErrorMessage(esFatal, 'Attempting to reset wind exposure for surface "' + Name + '"');
end;

procedure T_EP_Surface.SetConstruction(const construction: string);
begin
  if SameText(FConstruction, 'Default') then
    FConstruction := construction
  else if not SameText(FConstruction, construction) then
    T_EP_PPErrorMessage.AddErrorMessage(esFatal, 'Attempting to reset construction from "' + FConstruction +
                                        '" to "' + construction + '" for surface "' + Name + '"');
end;

procedure T_EP_Surface.SetOutsideEnvironment(const outsideEnvironment: TOutsideEnvironment);
begin
  if (FOutsideEnvironment <> oeAdiabatic) and (FOutsideEnvironment <> oeTranspiredSolarCollector) then
  begin
    if FOutsideEnvironment = oeUnknown then
      FOutsideEnvironment := outsideEnvironment
    else if not (FOutsideEnvironment = outsideEnvironment) then
      T_EP_PPErrorMessage.AddErrorMessage(esFatal, 'Attempting to reset outside environment for surface "' + Name + '"');
  end;
end;

procedure T_EP_Surface.SetOutsideObject(const outsideObject: string);
begin
  if SameText(FOutsideObject, '') or SameText(FOutsideObject, 'UTSC_BCModel') then
    FOutsideObject := outsideObject
  else if not SameText(FOutsideObject, outsideObject) then
    T_EP_PPErrorMessage.AddErrorMessage(esFatal, 'Attempting to reset outside object from "' + FOutsideObject +
                                        '" to "' + outsideObject + '" for surface "' + Name + '"');
end;


procedure T_EP_Surface.AssertOutsideEnvironment(const outsideEnvironment: TOutsideEnvironment);
begin
  if (FOutsideEnvironment <> outsideEnvironment) then
    T_EP_PPErrorMessage.AddErrorMessage(esFatal, 'AssertOutsideEnvironment failed: "' + Name + '"');
end;

procedure T_EP_Surface.AssertOutsideObject(outsideObject: string);
begin
  if not SameText(FOutsideObject, outsideObject) then
    T_EP_PPErrorMessage.AddErrorMessage(esFatal, 'AssertOutsideObject failed: "' + Name + '"');
end;

procedure T_EP_Surface.AssertOutsideObjectSet(outsideObjectSet: Boolean);
begin
  if (FOutsideEnvironment <> oeAdiabatic) and (FOutsideEnvironment <> oeTranspiredSolarCollector) then
  begin
    if ((FOutsideObject <> '') <> outsideObjectSet) then
      T_EP_PPErrorMessage.AddErrorMessage(esFatal, 'AssertOutsideObjectSet failed: "' + Name + '"');
  end;
end;

procedure T_EP_Surface.AssertSolarExposure(const exposure: TSolarExposure);
begin
  if (FOutsideEnvironment <> oeAdiabatic) then
  begin
    if (FSolarExposure <> exposure) then
      T_EP_PPErrorMessage.AddErrorMessage(esFatal, 'AssertSolarExposure failed: "' + Name + '"');
  end;
end;

procedure T_EP_Surface.AssertWindExposure(const exposure: TWindExposure);
begin
  if (FOutsideEnvironment <> oeAdiabatic) then
  begin
    if (FWindExposure <> exposure) then
      T_EP_PPErrorMessage.AddErrorMessage(esFatal, 'AssertWindExposure failed: "' + Name + '"');
  end;
end;

// Function creates a new surface which is an offset copy of the original surface
// returns name of new surface
function AddPVSurface(Verts: T_EP_Verts; AreaFraction: double): string;
var
  newPVSurf: T_EP_DetachedShading;
  offsetVec, origin, refVector, tempVector: T_EP_Vector;
  iVert: integer;
begin

  // DLM: assert areaFraction <= 1
  // DLM: assert 0 <= orientation <= 360
  // DLM: assert -90 <= tilt <= 90

  tempVector := T_EP_Vector.Create;
  newPVSurf := T_EP_DetachedShading.Create;

  // DLM: should name include PV surface type?
  // DLM: Should get name from global singleton counter
  newPVSurf.Name := 'External_Surfaces:PV_' + inttostr(ExternalSurfaces.Count + 1);
  newPVSurf.SurfaceType := 'Fixed';
  newPVSurf.ShadingTransmittanceSchedule := 'SHADING_SCH';

  // DLM: this functionality should be in something like "ScaleVerts"

  // the outward surface normal
  offsetVec := VectorMult(offsetAmount, VertsSurfaceNormal(Verts));

  // form the existing coordinate system, this should be a general function of verts
  // DLM: not origin, center would be better name
  origin := VertsCenterPoint(Verts);

  // make new verts
  for iVert := 0 to Verts.Count - 1 do //copy these vertices
  begin
    refVector := T_EP_Vector(Verts[iVert]);
    tempVector.i := refVector.i;
    tempVector.j := refVector.j;
    tempVector.k := refVector.k;

    // subtract origin, scale, add origin, add offset
    tempVector := VectorSubtract(tempVector, origin);
    tempVector := VectorMult(sqrt(AreaFraction), tempVector);
    tempVector := VectorAdd(tempVector, origin);
    tempVector := VectorAdd(tempVector, offsetVec);

    // add these vertices to the new surface
    newPVSurf.Verts.AddVert(tempVector.i, tempVector.j, tempVector.k);
  end;
  newPVSurf.Finalize();

  ExternalSurfaces.Add(newPVSurf);

  Result := newPVSurf.Name;

  // free variables
  // DLM: use free or destroy?
  offsetVec.Free();
  origin.Free();
  tempVector.Free();
  // don't free refVector because it is pointing at a Vert
end;



// Function creates a new surface that will have desired orientation and tilt angles
// returns name of new surface
function AddPVSurface(Verts: T_EP_Verts; AreaFraction: double; zoneOrigin: T_EP_Vector; OrientationAngle: double; TiltAngle: double): string;
var
  newPVSurf: T_EP_DetachedShading;
  rotVerts, newVerts: T_EP_Verts;
  origin, desiredX, desiredY, desiredZ, X, Y, Z, refVector, tempVector: T_EP_Vector;
  Rworld2rot, Rz2desiredZ, Rworld2desired, Rworld2existing, Rexisting2world, Rexisting2desired: T_EP_Matrix;
  iVert: integer;
begin

  // DLM: assert areaFraction <= 1
  // DLM: assert 0 <= orientation <= 360
  // DLM: assert -90 <= tilt <= 90

  tempVector := T_EP_Vector.Create;
  newPVSurf := T_EP_DetachedShading.Create;

  // DLM: should name include PV surface type?
  // DLM: Should get name from global singleton counter
  newPVSurf.Name := 'External_Surfaces:PV_' + inttostr(ExternalSurfaces.Count + 1);
  newPVSurf.SurfaceType := 'Fixed';
  newPVSurf.ShadingTransmittanceSchedule := 'SHADING_SCH';

  X := T_EP_Vector.Create; X.i := 1;
  Y := T_EP_Vector.Create; Y.j := 1;
  Z := T_EP_Vector.Create; Z.k := 1;

  // add zone origin and perform building rotation
  // have to pre-translate/rotate these vertices because we are adding fixed (building independant) surfaces
  rotVerts := T_EP_Verts.Create;
  Rworld2rot := RotationMatrixFromEulerAngles(0.0, 0.0, deg2rad*BldgRotation);
  for iVert := 0 to Verts.Count - 1 do
  begin
    refVector := T_EP_Vector(Verts[iVert]);
    tempVector.i := refVector.i + zoneOrigin.i;
    tempVector.j := refVector.j + zoneOrigin.j;
    tempVector.k := refVector.k + zoneOrigin.k;
    tempVector := MatrixMult(Rworld2rot, tempVector);
    rotVerts.AddVert(tempVector.i, tempVector.j, tempVector.k);
  end;
  rotVerts.Finalize();

  // form the desired coordinate system
  Rz2desiredZ := RotationMatrixFromEulerAngles(0.0, deg2rad*TiltAngle, deg2rad*OrientationAngle);
  desiredZ := MatrixMult(Rz2desiredZ, Z);
  desiredX := VectorSubtract(X, VectorMult(VectorDotProduct(X, desiredZ), desiredZ));
  desiredY := VectorSubtract(Y, VectorMult(VectorDotProduct(Y, desiredZ), desiredZ));
  if (VectorMagnitude(desiredX) > VectorMagnitude(desiredY)) then
  begin
    desiredX := VectorUnit(desiredX);
    desiredY := VectorCrossProduct(desiredZ, desiredX);
  end
  else
  begin
    desiredY := VectorUnit(desiredY);
    desiredX := VectorCrossProduct(desiredY, desiredZ);
  end;
  Rworld2desired := RotationMatrixFromBases(desiredX, desiredY, desiredZ);

  // form the existing coordinate system, this should be a general function of verts
  origin := VertsCenterPoint(rotVerts);
  Rworld2existing := RotationMatrixToSurface(rotVerts);

  // rotation from existing to desired
  Rexisting2world := MatrixTranspose(Rworld2existing);
  Rexisting2desired := MatrixMult(Rworld2desired, Rexisting2world);

  // set of new vertices
  newVerts := TransformVerts(rotVerts, Rexisting2desired, origin, AreaFraction, offsetAmount);

  // add these vertices to the new surface
  for iVert := 0 to newVerts.Count - 1 do
  begin
    with T_EP_Vector(newVerts[iVert]) do
    begin
      newPVSurf.Verts.AddVert(i, j, k);
    end;
  end;
  newPVSurf.Finalize();

  ExternalSurfaces.Add(newPVSurf);

  Result := newPVSurf.Name;

  // free variables
  // DLM: use free or destroy?
  rotVerts.Free();
  newVerts.Free();
  origin.Free();
  desiredX.Free();
  desiredY.Free();
  desiredZ.Free();
  X.Free();
  Y.Free();
  Z.Free();
  // don't free refVector because it is pointing at a Vert
  tempVector.Free();
  Rworld2rot.Free();
  Rz2desiredZ.Free();
  Rworld2desired.Free();
  Rworld2existing.Free();
  Rexisting2world.Free();
  Rexisting2desired.Free();
end;


function T_EP_Surface.AddSkyLight(Fraction: double; ReturnCountOnly: boolean = false): integer;
type
  SkylightXYCordStruct = record
    x, y, z: double
  end;

  SkylightStruct = record
    P1, P2, P3, P4: SkylightXYCordStruct; //the 4 points around the skylight
  end;
var
  iVerts: Integer;
  xMin: double;
  yMin: double;
  xMax: double;
  yMax: double;
  numSkylights: double;
  iSkylight: Integer;
  Skylightx: double;
  Skylighty: double;
  SkylightList: array of SkylightStruct;
  iX: Integer;
  iY: Integer;
  ZoneYWidth: double;
  ZoneXLength: double;
  ZoneAR: double;
  SkyLightArea: double;
  SkylightLengthX: double;
  SkylightLengthY: double;
  aSkyLight: T_EP_Skylight;
  dRows: double;
  dCols: double;
  numRows: Integer;
  numCols: Integer;
begin
  //get zone extremes

  for iVerts := 0 to Verts.Count - 1 do
  begin
    if iVerts = 0 then
    begin
      xMin := T_EP_Vector(Verts[iVerts]).i;
      xMax := T_EP_Vector(Verts[iVerts]).i;
      yMin := T_EP_Vector(Verts[iVerts]).j;
      yMax := T_EP_Vector(Verts[iVerts]).j;
    end
    else
    begin
      xMin := min(xMin, T_EP_Vector(Verts[iVerts]).i);
      xMax := max(xMax, T_EP_Vector(Verts[iVerts]).i);
      yMin := min(yMin, T_EP_Vector(Verts[iVerts]).j);
      yMax := max(yMax, T_EP_Vector(Verts[iVerts]).j);
    end;
  end;

  //find the area needed by skylight
  SkyLightArea := AreaPolygon(Verts) * Fraction;

  //use imaginary bounds to figure out Skylight density
  ZoneXLength := (xMax - xMin);
  ZoneYWidth := (yMax - yMin);
  ZoneAR := 0;
  if ZoneYWidth <> 0 then
    ZoneAR := ZoneXLength / ZoneYWidth;


  SkylightLengthX := 4.0 * 0.3048; //assume 4' x 4' skylight
  SkylightLengthY := 4.0 * 0.3048;

  //number of skylights
  numSkylights := SkylightArea / (SkylightLengthX * SkylightLengthY);

  //solve this simultaneous equation
  //dRows * dCols = numSkylights
  //dRows = ZoneAR * dCols

  dRows := SQRT(numSkylights / ZoneAR);
  dCols := dRows * ZoneAR;

  numRows := round(dRows);
  numCols := round(dCols);
  if numRows = 0 then numRows := 1;
  if numCols = 0 then numCols := 1;
  numSkylights := numRows * numCols;


  Skylightx := ZoneXLength / numCols;
  Skylighty := ZoneYWidth / numRows;

  RoofFen := True;
  RoofFenX := Skylightx;
  RoofFenY := Skylighty;
  RoofFenCntRows := numRows;
  RoofFenCntCols := numCols;

  if ReturnCountOnly then
  begin
    Result := Floor(numSkylights);
    exit;
  end;

  SetLength(SkylightList, Floor(numSkylights));

  iSkylight := 0;
  //create a list of all the tdd vertices, then use them to check whether or
  //not they are in the zone
  for iX := 0 to numRows - 1 do
  begin
    for iY := 0 to numCols - 1 do
    begin

      SkylightList[iSkylight].P1.x := xMin + iY * Skylightx + Skylightx / 2 - SkylightLengthx / 2;
      SkylightList[iSkylight].P1.y := yMin + iX * Skylighty + Skylighty / 2 + SkylightLengthy / 2;
      // todo: remove ULC dependence
      // todo: calculate the roof tilt to correctly place the z component
      SkylightList[iSkylight].P1.z := T_EP_Vector(Verts[0]).k; //ceiling height

      SkylightList[iSkylight].P2.x := xMin + iY * Skylightx + Skylightx / 2 - SkylightLengthx / 2;
      SkylightList[iSkylight].P2.y := yMin + iX * Skylighty + Skylighty / 2 - SkylightLengthy / 2;
      // todo: remove ULC dependence
      SkylightList[iSkylight].P2.z := T_EP_Vector(Verts[0]).k; //ceiling height

      SkylightList[iSkylight].P3.x := xMin + iY * Skylightx + Skylightx / 2 + SkylightLengthx / 2;
      SkylightList[iSkylight].P3.y := yMin + iX * Skylighty + Skylighty / 2 - SkylightLengthy / 2;
      // todo: remove ULC dependence
      SkylightList[iSkylight].P3.z := T_EP_Vector(Verts[0]).k; //ceiling height

      SkylightList[iSkylight].P4.x := xMin + iY * Skylightx + Skylightx / 2 + SkylightLengthx / 2;
      SkylightList[iSkylight].P4.y := yMin + iX * Skylighty + Skylighty / 2 + SkylightLengthy / 2;
      // todo: remove ULC dependence
      SkylightList[iSkylight].P4.z := T_EP_Vector(Verts[0]).k; //ceiling height

      inc(iSkylight);
    end;
  end;

  for iSkylight := 0 to Length(SkylightList) - 1 do
  begin
    if (InsidePolygon(Verts, SkylightList[iSkylight].P1.x, SkylightList[iSkylight].P1.y)) and
      (InsidePolygon(Verts, SkylightList[iSkylight].P2.x, SkylightList[iSkylight].P2.y)) and
      (InsidePolygon(Verts, SkylightList[iSkylight].P3.x, SkylightList[iSkylight].P3.y)) and
      (InsidePolygon(Verts, SkylightList[iSkylight].P4.x, SkylightList[iSkylight].P4.y)) then
    begin
      aSkyLight := T_EP_Skylight.Create;
      aSkyLight.Name := Name + '_skylight_' + inttostr(iSkylight + 1);
      aSkyLight.SkylightType := stSkylight;
      aSkyLight.SurfaceName := Name;

      aSkyLight.Verts.AddVert(SkylightList[iSkylight].P2.x,
        SkylightList[iSkylight].P2.y,
        SkylightList[iSkylight].P2.z);
      aSkyLight.Verts.AddVert(SkylightList[iSkylight].P3.x,
        SkylightList[iSkylight].P3.y,
        SkylightList[iSkylight].P3.z);
      aSkyLight.Verts.AddVert(SkylightList[iSkylight].P4.x,
        SkylightList[iSkylight].P4.y,
        SkylightList[iSkylight].P4.z);
      aSkyLight.Verts.AddVert(SkylightList[iSkylight].P1.x,
        SkylightList[iSkylight].P1.y,
        SkylightList[iSkylight].P1.z);

      aSkyLight.Finalize();
      SubSurfaces.Add(aSkyLight);
    end
    else
    begin
      T_EP_PPErrorMessage.AddErrorMessage(esWarning, 'Skylight ' + IntToStr(iSkylight) + ' in zone ' +
        ZoneName + ' not installed because it is not entirely within zone.');
    end;
  end;

  Result := Floor(numSkylights);
end;


function T_EP_Surface.AddTDDs(Fraction: double; ReturnCountOnly: Boolean = false): integer; //returns number added
type
  TDDXYCordStruct = record
    x, y, z: double
  end;

  TDDStruct = record
    P1, P2, P3, P4: TDDXYCordStruct; //the 4 points around the tdd
  end;
var
  iVerts: Integer;
  xMin: double;
  yMin: double;
  xMax: double;
  yMax: double;
  Area: double;
  numTdd: integer;
  aTDD: T_EP_TDD;
  dRows: double;
  dCols: double;
  numRows: integer;
  numCols: Integer;
  iTDD: Integer;
  TDDx: double;
  TDDy: double;
  TDDList: array of TDDStruct;
  //TDDyOff: double;
  //TDDxOff: double;
  iX: Integer;
  iY: Integer;
  ZoneYWidth: double;
  ZoneXLength: double;
  ZoneAR: double;
  TDDDiameter: double;
  TDDEquivLength: double;
  DLx: double;
  DLy: double;
  DLz: double;
  i: Integer;
  aZone: T_EP_Zone;
  prinSurf, aSurf: T_EP_Surface;
begin
  //find the principle wall.  This is the wall with the biggest window area
  aZone := GetZone(ZoneName);
  //default to first wall
  for i := 0 to aZone.Surfaces.Count - 1 do
  begin
    prinSurf := T_EP_Surface(aZone.Surfaces.Items[i]);
    if prinSurf.Typ = stWall then
    begin
      break;
    end;
  end;

  for i := 0 to aZone.Surfaces.Count - 1 do
  begin
    aSurf := T_EP_Surface(aZone.Surfaces.Items[i]);
    if aSurf.Typ = stWall then
    begin
      if aSurf.WindowArea > prinSurf.WindowArea then
      begin
        prinSurf := aSurf;
      end;
    end;
  end;

  //get zone extremes
  for iVerts := 0 to Verts.Count - 1 do
  begin
    if iVerts = 0 then
    begin
      xMin := T_EP_Vector(Verts[iVerts]).i;
      xMax := T_EP_Vector(Verts[iVerts]).i;
      yMin := T_EP_Vector(Verts[iVerts]).j;
      yMax := T_EP_Vector(Verts[iVerts]).j;
    end
    else
    begin
      xMin := min(xMin, T_EP_Vector(Verts[iVerts]).i);
      xMax := max(xMax, T_EP_Vector(Verts[iVerts]).i);
      yMin := min(yMin, T_EP_Vector(Verts[iVerts]).j);
      yMax := max(yMax, T_EP_Vector(Verts[iVerts]).j);
    end;
  end;

  //use imaginary bounds to figure out tdd density
  ZoneXLength := (xMax - xMin);
  ZoneYWidth := (yMax - yMin);
  ZoneAR := ZoneXLength / ZoneYWidth;
  // DLM: woah, this looks like a bug, use area polygon?
  Area := ZoneXLength * ZoneYWidth;
  numTdd := floor(area / Fraction);

  //solve this simultaneous equation
  //dRows * dCols = numTdd
  //dRows = ZoneAR * dCols
  //dRows = numm
  dRows := SQRT(numTDD / ZoneAR);
  dCols := dRows * ZoneAR;

  numRows := round(dRows);
  numCols := round(dCols);
  if numRows = 0 then numRows := 1;
  if numCols = 0 then numCols := 1;
  numTdd := numRows * numCols;

  //find TDD spacing
  TDDx := ZoneXLength / numCols;
  TDDy := ZoneYWidth / numRows;

  RoofFen := True;
  RoofFenX := TDDx;
  RoofFenY := TDDy;
  RoofFenCntRows := numRows;
  RoofFenCntCols := numCols;

  //if Odd(numRows) and (numRows <> 1) then DLy := DLx - (TDDx / 2)
  //if Odd(numCols) and (numCols <> 1)then DLx := ;
  //DaylightSPLocation.i := DLx;
  //DaylightSPLocation.j := DLy;
  //DaylightSPLocation.k := DLz;

  //21" TDD -- Diameter = 0.5334 m
  TDDDiameter := 0.5334;
  //21" TDD to square = 0.4727 m per side for equivalent area
  TDDEquivLength := sqrt(Pi / 4 * Power(TDDDiameter, 2));

  SetLength(TDDList, Floor(numTdd));

  if ReturnCountOnly then
  begin
    result := Floor(numTdd);
    exit;
  end;

  iTDD := 0;
  //create a list of all the tdd vertices, then use them to check whether or
  //not they are in the zone
  for iX := 0 to numRows - 1 do
  begin
    for iY := 0 to numCols - 1 do
    begin
      TDDList[iTDD].P1.x := xMin + iY * TDDx + TDDx / 2 - TDDEquivLength / 2;
      TDDList[iTDD].P1.y := yMin + iX * TDDy + TDDy / 2 + TDDEquivLength / 2;
      // todo: remove ULC dependence
      TDDList[iTDD].P1.z := T_EP_Vector(Verts[0]).k; //ceiling height

      TDDList[iTDD].P2.x := xMin + iY * TDDx + TDDx / 2 - TDDEquivLength / 2;
      TDDList[iTDD].P2.y := yMin + iX * TDDy + TDDy / 2 - TDDEquivLength / 2;
      // todo: remove ULC dependence
      TDDList[iTDD].P2.z := T_EP_Vector(Verts[0]).k; //ceiling height

      TDDList[iTDD].P3.x := xMin + iY * TDDx + TDDx / 2 + TDDEquivLength / 2;
      TDDList[iTDD].P3.y := yMin + iX * TDDy + TDDy / 2 - TDDEquivLength / 2;
      // todo: remove ULC dependence
      TDDList[iTDD].P3.z := T_EP_Vector(Verts[0]).k; //ceiling height

      TDDList[iTDD].P4.x := xMin + iY * TDDx + TDDx / 2 + TDDEquivLength / 2;
      TDDList[iTDD].P4.y := yMin + iX * TDDy + TDDy / 2 + TDDEquivLength / 2;
      // todo: remove ULC dependence
      TDDList[iTDD].P4.z := T_EP_Vector(Verts[0]).k; //ceiling height
      inc(iTDD);
    end;
  end;

  for iTDD := 0 to Length(TDDList) - 1 do
  begin
    //check to make sure TDD is within zone
    if (InsidePolygon(Verts, TDDList[iTDD].P1.x, TDDList[iTDD].P1.y)) and
      (InsidePolygon(Verts, TDDList[iTDD].P2.x, TDDList[iTDD].P2.y)) and
      (InsidePolygon(Verts, TDDList[iTDD].P3.x, TDDList[iTDD].P3.y)) and
      (InsidePolygon(Verts, TDDList[iTDD].P4.x, TDDList[iTDD].P4.y)) then
    begin
      aTDD := T_EP_TDD.Create;
      aTDD.TopSurfaceName := Name;
      aTDD.BottomSurfaceName := Name;
      aTDD.Diameter := TDDDiameter;
      aTDD.ZoneName := ZoneName;
      aTDD.Index := gloTDDIndex;
      aTDD.TubeLength := 1.0; //todo: this changes for plenum zones

      aTDD.Verts.AddVert(TDDList[iTDD].P2.x,
        TDDList[iTDD].P2.y,
        TDDList[iTDD].P2.z);
      aTDD.Verts.AddVert(TDDList[iTDD].P3.x,
        TDDList[iTDD].P3.y,
        TDDList[iTDD].P3.z);
      aTDD.Verts.AddVert(TDDList[iTDD].P4.x,
        TDDList[iTDD].P4.y,
        TDDList[iTDD].P4.z);
      aTDD.Verts.AddVert(TDDList[iTDD].P1.x,
        TDDList[iTDD].P1.y,
        TDDList[iTDD].P1.z);

      aTDD.Finalize();
      Inc(gloTDDIndex);
      SubSurfaces.Add(aTDD);
    end;
  end;

  result := numTDD;
end;

procedure T_EP_Surface.AddWindow(WinType: TWindowType; winApplyType: TWindowApplyType; WWR, SillHeight, HeaderHeight, EdgeOffset: double;
  WinRepresentationType: TWindowRepresentationType);
var
  n: integer;
  newWin: T_EP_Window;
  reqGlaze: double;
  iVert: integer;
  GlazeHeadZ: double;
  SurfaceHeight: double;
  GlazeBottomZ: double;
  HAdj: double;
  iSub: integer;
  ViewGlassWinTop: double;
  minZ: double;
  WindowHeight: double;
  WindowWidth: double;
  NumWindows: integer;
  MaxWindows : integer;
  WindowSpacing: double;
begin
  //wall must have 4 vertices
  if Verts.Count <> 4 then
  begin
    //T_EP_PPErrorMessage.AddErrorMessage(esWarning, 'Could not add window to surface "' + Name + '", number of vertices not equal 4.' );
    exit;
  end;
  // todo: assert vertical or deal with sloped surfaces
  minZ := ZMinimum();
  SillHeight := SillHeight + minZ;
  //HeaderHeight := HeaderHeight + minZ;
  if WinRepresentationType = wrtBanded then
  begin
    newWin := T_EP_Window.Create;
    newWin.WindowType := WinType;
    newWin.Name := Name + '_window_' + inttostr(SubSurfaces.Count + 1);
    newWin.SurfaceName := Name; //surface name
    newWin.Nrm := Nrm;
    reqGlaze := WWR * SurfaceArea;
    // todo: remove ULC dependence
    SurfaceHeight := T_EP_Vector(Verts[0]).k; //since ULC geom
    if WallLength = 0 then
    begin
      T_EP_PPErrorMessage.AddErrorMessage(esSevere, 'Attemped to add a window on surface ' + Name +
        ' but wall length was 0.');
    end;
    if winApplyType = watBottomUp then
    begin
      GlazeHeadZ := SillHeight + reqGlaze / (WallLength - 2 * EdgeOffset);
      //check the area if it is too big
      if (GlazeHeadZ > SurfaceHeight) then
      begin
        T_EP_PPErrorMessage.AddErrorMessage(esWarning, 'Requested glazing exceeds available area for ' + newWin.Name +
          '.  Reducing sill height to fit.');
        HAdj := (GlazeHeadZ - SurfaceHeight) + EdgeOffset;
        SillHeight := SillHeight - HAdj;
        GlazeHeadZ := GlazeHeadZ - HAdj;
        if SillHeight < 0 then
        begin
          SillHeight := 0;
          GlazeHeadZ := SurfaceHeight - EdgeOffset;
          T_EP_PPErrorMessage.AddErrorMessage(esWarning, 'Sill height was adjusted to be below 0 for ' + newWin.Name +
            '.  Setting the sill height to 0.');
        end;
      end;
      newwin.Top := GlazeHeadZ;
      newwin.Bottom := SillHeight;
      newWin.Height := GlazeHeadZ - SillHeight;
      for iVert := 0 to Verts.Count - 1 do //these are the surface vertices
      begin
        with T_EP_Vector(verts[iVert]) do
        begin
          case iVert of
            0: newWin.Verts.AddVert(i + (EdgeOffset * cos(Angle)),
                j + (EdgeOffset * sin(Angle)),
                GlazeHeadZ);
            1: newWin.Verts.AddVert(i + (EdgeOffset * cos(Angle)),
                j + (EdgeOffset * sin(Angle)),
                SillHeight);
            2: newWin.Verts.AddVert(i - (EdgeOffset * cos(Angle)),
                j - (EdgeOffset * sin(Angle)),
                SillHeight);
            3: newWin.Verts.AddVert(i - (EdgeOffset * cos(Angle)),
                j - (EdgeOffset * sin(Angle)),
                GlazeHeadZ);
          end;
        end;
      end;
      newWin.Finalize();
      SubSurfaces.Add(newWin);
    end
    else if winApplyType = watTopDown then
    begin
      //check if there is another window that already has been defined.
      for iSub := 0 to SubSurfaces.count - 1 do
      begin
        if (SubSurfaces[iSub] is T_EP_Window) then
          ViewGlassWinTop := T_EP_Window(SubSurfaces[iSub]).Top;
      end;
      GlazeBottomZ := (SurfaceHeight - HeaderHeight) - reqGlaze / (WallLength - 2 * EdgeOffset);
      if GlazeBottomZ < ViewGlassWinTop then
      begin
        GlazeBottomZ := ViewGlassWinTop + 0.05;
        T_EP_PPErrorMessage.AddErrorMessage(esWarning, 'The bottom of the top-down glass is below the ' +
          'top of the bottom-up glass.  Automatically adjusting.');
      end;
      //check the area if it is too big
      if (GlazeBottomZ < 0) then
      begin
        T_EP_PPErrorMessage.AddErrorMessage(esWarning, 'Requested glazing exceeds available area for ' + newWin.Name +
          '.  Reducing header height to fit.');
        HeaderHeight := HeaderHeight + GlazeBottomZ;
        GlazeBottomZ := 0;
        if HeaderHeight < 0 then
        begin
          HeaderHeight := 0;
          T_EP_PPErrorMessage.AddErrorMessage(esWarning, 'Header height was adjusted to be below 0 for ' + newWin.Name +
            '.  Setting the Header height to 0.');
        end;
      end;
      newWin.Top := (SurfaceHeight - HeaderHeight);
      newWin.Bottom := GlazeBottomZ;
      newWin.Height := (SurfaceHeight - HeaderHeight) - GlazeBottomZ;
      for iVert := 0 to Verts.Count - 1 do //these are the surface vertices
      begin
        with T_EP_Vector(verts[iVert]) do
        begin
          case iVert of
            0: newWin.Verts.AddVert(i + (EdgeOffset * cos(Angle)),
                j + (EdgeOffset * sin(Angle)),
                SurfaceHeight - HeaderHeight);
            1: newWin.Verts.AddVert(i + (EdgeOffset * cos(Angle)),
                j + (EdgeOffset * sin(Angle)),
                GlazeBottomZ);
            2: newWin.Verts.AddVert(i - (EdgeOffset * cos(Angle)),
                j - (EdgeOffset * sin(Angle)),
                GlazeBottomZ);
            3: newWin.Verts.AddVert(i - (EdgeOffset * cos(Angle)),
                j - (EdgeOffset * sin(Angle)),
                SurfaceHeight - HeaderHeight);
          end;
        end;
      end;
      newWin.Finalize();
      SubSurfaces.Add(newWin);
    end;
  end //if banded
  else if WinRepresentationType = wrtDiscrete then
  begin
    reqGlaze := WWR * SurfaceArea;
    WindowWidth := 0.9144; // 0.9144m = 3ft
    WindowHeight := 1.2192; //1,2192 = 4ft
    NumWindows := Round(reqGlaze / (WindowHeight * WindowWidth));
    MaxWindows := Trunc((WallLength - 2 * EdgeOffset) / WindowWidth);
    //if number of windows is greater than max set to max
    if NumWindows > MaxWindows then
    begin
      NumWindows := MaxWindows;
      T_EP_PPErrorMessage.AddErrorMessage(esWarning, 'WWR larger than max possible for surface ' + Name + '. Reducing number of windows to max possible.');
    end;
    for n := 0 to NumWindows - 1 do
    begin
      newWin := T_EP_Window.Create;
      newWin.WindowType := WinType;
      newWin.Name := Name + '_Window_' + IntToStr(SubSurfaces.Count + 1);
      newWin.SurfaceName := Name; //surface name
      newWin.Nrm := Nrm;
      SurfaceHeight := T_EP_Vector(Verts[0]).k; //since ULC geom
      if WallLength = 0 then
        T_EP_PPErrorMessage.AddErrorMessage(esSevere, 'Attemped to add a window on surface ' + Name + ' but wall length was 0.');
      if NumWindows = 1 then
        WindowSpacing := 0
      else
        WindowSpacing := (WallLength - NumWindows * WindowWidth - 2 * EdgeOffset) / (NumWindows - 1);
      if winApplyType = watBottomUp then
      begin
        GlazeHeadZ := SillHeight + WindowHeight;
        //check the area if it is too big
        if (GlazeHeadZ > SurfaceHeight) then
        begin
          T_EP_PPErrorMessage.AddErrorMessage(esWarning, 'Requested glazing exceeds available area for ' + newWin.Name + '. Reducing sill height to fit.');
          HAdj := (GlazeHeadZ - SurfaceHeight) + EdgeOffset;
          SillHeight := SillHeight - HAdj;
          GlazeHeadZ := GlazeHeadZ - HAdj;
          if SillHeight < 0 then
          begin
            SillHeight := 0;
            GlazeHeadZ := SurfaceHeight - EdgeOffset;
            T_EP_PPErrorMessage.AddErrorMessage(esWarning, 'Sill height was adjusted to be below 0 for ' + newWin.Name + '. Setting the sill height to 0.');
          end;
        end;
        newwin.Top := GlazeHeadZ;
        newwin.Bottom := SillHeight;
        newWin.Height := GlazeHeadZ - SillHeight;
        begin
          for iVert := 0 to Verts.Count - 1 do //these are the surface vertices
          begin
            with T_EP_Vector(Verts[iVert]) do
            begin
              case iVert of
                0: newWin.Verts.AddVert(
                  i + ((EdgeOffset + n * (WindowWidth + WindowSpacing)) * cos(Angle)),
                  j + ((EdgeOffset + n * (WindowWidth + WindowSpacing)) * sin(Angle)),
                  GlazeHeadZ);
                1: newWin.Verts.AddVert(
                  i + ((EdgeOffset + n * (WindowWidth + WindowSpacing)) * cos(Angle)),
                  j + ((EdgeOffset + n * (WindowWidth + WindowSpacing)) * sin(Angle)),
                  SillHeight);
                2: newWin.Verts.AddVert(
                  i - (WallLength - (EdgeOffset + (n + 1) * WindowWidth +  n * WindowSpacing)) * cos(Angle),
                  j - (WallLength - (EdgeOffset + (n + 1) * WindowWidth + n * WindowSpacing)) * sin(Angle),
                  SillHeight);
                3: newWin.Verts.AddVert(
                  i - (WallLength - (EdgeOffset + (n + 1) * WindowWidth +  n * WindowSpacing)) * cos(Angle),
                  j - (WallLength - (EdgeOffset + (n + 1) * WindowWidth + n * WindowSpacing)) * sin(Angle),
                  GlazeHeadZ);
              end;
            end;
          end;
          newWin.Finalize();
          SubSurfaces.Add(newWin);
        end;
      end
      else if winApplyType = watTopDown then
      begin
        T_EP_PPErrorMessage.AddErrorMessage(esSevere, 'Attemped to add discrete windows using top down configuration on surface ' + Name + '. Use bottom up instead.');
      end;
    end;
  end; //if discrete
  GetWindowArea;
end;

procedure T_EP_Surface.AddSubSurface(aSubSurface: T_EP_SubSurface);
begin
  SubSurfaces.Add(aSubSurface);
end;

procedure T_EP_Surface.CenterPoint(var x1, y1, z1: double);
//this doesn't work for concave zones
// DLM: I want to use this with surfaces other than T_EP_Surface, this should be public function of Verts
// DLM: I am not sure this works in general, or at least for which definitions of "center",
// DLM: imagine case with unevenly spaced verts, it will be an interior point at least
var
  i: Integer;
begin
  x1 := 0;
  y1 := 0;
  z1 := 0;
  for i := 0 to Verts.Count - 1 do
  begin
    x1 := x1 + T_EP_Vector(Verts[i]).i;
    y1 := y1 + T_EP_Vector(Verts[i]).j;
    z1 := z1 + T_EP_Vector(Verts[i]).k;
  end;

  if Verts.Count <> 0 then
  begin
    x1 := x1 / Verts.Count;
    y1 := y1 / Verts.Count;
    z1 := z1 / Verts.Count;
  end
  else
  begin
    x1 := 0;
    y1 := 0;
    z1 := 0;
  end;
end;

procedure T_EP_Surface.Finalize;
begin
  //NICK removed.  no virtual abstract inheritance possible?
  //inherited;
  
  if (not Verts.AreFinalized) then
    Verts.Finalize;

  case SpecificType of
    sstAdiabaticWall:
      begin
        if SameText(FConstruction, 'Default') then
          SetConstruction(BldgConstructions.GetConstruction('Opaque', 'int-walls').Name);

        // assert oeOtherZoneSurface
        AssertOutsideEnvironment(oeOtherZoneSurface);

        // assert outside object is self
        AssertOutsideObject(Name);

        // assert solar exposure is false
        AssertSolarExposure(seNoSun);

        // assert wind exposure is false
        AssertWindExposure(weNoWind);
      end;
    sstAdiabaticFloor:
      begin
        if SameText(FConstruction, 'Default') then
          SetConstruction('INT-FLOOR-TOPSIDE');

        // assert oeOtherZoneSurface
        AssertOutsideEnvironment(oeOtherZoneSurface);

        // assert outside object is self
        AssertOutsideObject(Name);

        // assert solar exposure is false
        AssertSolarExposure(seNoSun);

        // assert wind exposure is false
        AssertWindExposure(weNoWind);
      end;
    sstAdiabaticCeiling:
      begin
        if SameText(FConstruction, 'Default') then
          SetConstruction('INT-FLOOR-UNDERSIDE');

        // assert oeOtherZoneSurface
        AssertOutsideEnvironment(oeOtherZoneSurface);

        // assert outside object is self
        AssertOutsideObject(Name);

        // assert solar exposure is false
        AssertSolarExposure(seNoSun);

        // assert wind exposure is false
        AssertWindExposure(weNoWind);
      end;
    sstInteriorWall:
      begin
        if SameText(FConstruction, 'Default') then
          SetConstruction(BldgConstructions.GetConstruction('Opaque', 'int-walls').Name); //make sure that this is reflective

        // always set to OtherZoneSurface, will assert if resets
        SetOutsideEnvironment(oeOtherZoneSurface);

        // assert outside object set
        AssertOutsideObjectSet(true);

        // set solar exposure to false, will assert if resets
        SetSolarExposure(seNoSun);

        // set wind exposure to false, will assert if resets
        SetWindExposure(weNoWind);
      end;
    sstInteriorFloor:
      begin
        if SameText(FConstruction, 'Default') then
          SetConstruction('INT-FLOOR-TOPSIDE');

       // always set to OtherZoneSurface, will assert if resets
        SetOutsideEnvironment(oeOtherZoneSurface);

        // assert outside object set
        AssertOutsideObjectSet(true);

        // set solar exposure to false, will assert if resets
        SetSolarExposure(seNoSun);

        // set wind exposure to false, will assert if resets
        SetWindExposure(weNoWind);
      end;
    sstInteriorCeiling:
      begin
        if SameText(FConstruction, 'Default') then
          SetConstruction('INT-FLOOR-UNDERSIDE');

       // always set to OtherZoneSurface, will assert if resets
        SetOutsideEnvironment(oeOtherZoneSurface);

        // assert outside object set
        AssertOutsideObjectSet(true);

        // set solar exposure to false, will assert if resets
        SetSolarExposure(seNoSun);

        // set wind exposure to false, will assert if resets
        SetWindExposure(weNoWind);
      end;
    sstExteriorWall:
      begin
        if SameText(FConstruction, 'Default') then
          SetConstruction(BldgConstructions.GetConstruction('Opaque', 'ext-walls').Name);

        // always set to exterior, will assert if resets
        SetOutsideEnvironment(oeExteriorEnvironment);

        // assert no outside object
        AssertOutsideObjectSet(false);

        // default solar exposure to true
        if FSolarExposure = seUnknown then
          SetSolarExposure(seSunExposed);

        // default wind exposure to true
        if FWindExposure = weUnknown then
          SetWindExposure(weWindExposed);
      end;
    sstSlab:
      begin
        if SameText(FConstruction, 'Default') then
          SetConstruction(BldgConstructions.GetConstruction('Opaque', 'ext-slab').Name);
        if ((FOutsideEnvironment = oeOtherSideCoeff) or
            (FOutsideEnvironment = oeOtherSideConditionsModel)) then
        begin
          // assert outside object
          AssertOutsideObjectSet(true);
        end
        else
        begin
          // always set to ground, will assert if resets
          SetOutsideEnvironment(oeGround);
          // assert no outside object
          AssertOutsideObjectSet(false);
        end;

        // default solar exposure to false
        if FSolarExposure = seUnknown then
          SetSolarExposure(seNoSun);

        // default wind exposure to false
        if FWindExposure = weUnknown then
          SetWindExposure(weNoWind);
      end;
    sstBelowGradeExteriorWall:
      begin
        if SameText(FConstruction, 'Default') then
          SetConstruction(BldgConstructions.GetConstruction('Opaque', 'ext-slab').Name);
        if ((FOutsideEnvironment = oeOtherSideCoeff) or
            (FOutsideEnvironment = oeOtherSideConditionsModel)) then
        begin
          // assert outside object
          AssertOutsideObjectSet(true);
        end
        else
        begin
          // always set to ground, will assert if resets
          SetOutsideEnvironment(oeGround);
          // assert no outside object
          AssertOutsideObjectSet(false);
        end;

        // default solar exposure to false
        if FSolarExposure = seUnknown then
          SetSolarExposure(seNoSun);

        // default wind exposure to false
        if FWindExposure = weUnknown then
          SetWindExposure(weNoWind);
      end;
    sstExposedFloor:
      begin
        if SameText(FConstruction, 'Default') then
          SetConstruction(BldgConstructions.GetConstruction('Opaque', 'exposed-floor').Name);

        // always set to ground, will assert if resets
        SetOutsideEnvironment(oeExteriorEnvironment);

        // assert no outside object
        AssertOutsideObjectSet(false);

        // default solar exposure to false
        if FSolarExposure = seUnknown then
          SetSolarExposure(seNoSun);

        // default wind exposure to true
        if FWindExposure = weUnknown then
          SetWindExposure(weWindExposed);
      end;
    sstRoof:
      begin
        if SameText(FConstruction, 'Default') then
          SetConstruction(BldgConstructions.GetConstruction('Opaque', 'roofs').Name);

        // always set to exterior, will assert if resets
        SetOutsideEnvironment(oeExteriorEnvironment);

        // assert no outside object
        AssertOutsideObjectSet(false);

        // default solar exposure to true
        if FSolarExposure = seUnknown then
          SetSolarExposure(seSunExposed);

        // default wind exposure to true
        if FWindExposure = weUnknown then
          SetWindExposure(weWindExposed);
      end;
    sstAtticFloor:
      begin
        if SameText(FConstruction, 'Default') then
          SetConstruction(BldgConstructions.GetConstruction('Opaque', 'attic-floor').Name);

       // always set to OtherZoneSurface, will assert if resets
        SetOutsideEnvironment(oeOtherZoneSurface);

        // assert outside object set
        AssertOutsideObjectSet(true);

        // set solar exposure to false, will assert if resets
        SetSolarExposure(seNoSun);

        // set wind exposure to false, will assert if resets
        SetWindExposure(weNoWind);
      end;
    sstAtticCeiling:
      begin
        if SameText(FConstruction, 'Default') then
          SetConstruction(BldgConstructions.GetConstruction('Opaque', 'attic-floor').Name);

       // always set to OtherZoneSurface, will assert if resets
        SetOutsideEnvironment(oeOtherZoneSurface);

        // assert outside object set
        AssertOutsideObjectSet(true);

        // set solar exposure to false, will assert if resets
        SetSolarExposure(seNoSun);

        // set wind exposure to false, will assert if resets
        SetWindExposure(weNoWind);
      end;
    sstAtticRoof:
      begin
        if SameText(FConstruction, 'Default') then
          SetConstruction(BldgConstructions.GetConstruction('Opaque', 'attic-roof').Name);

        // always set to exterior, will assert if resets
        SetOutsideEnvironment(oeExteriorEnvironment);

        // assert no outside object
        AssertOutsideObjectSet(false);

        // default solar exposure to true
        if FSolarExposure = seUnknown then
          SetSolarExposure(seSunExposed);

        // default wind exposure to true
        if FWindExposure = weUnknown then
          SetWindExposure(weWindExposed);
      end;

  end;
end;

procedure T_EP_Surface.FindWallProperties;
//finds the normal
//finds the wall length
//finds the angle
var
  vec1: T_EP_Vector;
  theta: double;
  y2: double;
  x1: double;
  y1: double;
  x2: double;
  z1: double;
  aZone: T_EP_Zone;
  iVert: Integer;
begin
  //find surface area
  Verts.AssertFinalized();
  SurfaceArea := AreaPolygon(Verts);

  WallLength := 0;
  if (Typ = stCeiling) then
  begin
    Nrm := ntUp;
    RelNrm := ntUp;
    AbsNrm := ntUp;

    Tilt := VertsTilt(Verts);
    //writeln('Tilt for ceiling ' + Name + ' is ' + floattostr(tilt));
  end
  else if (Typ = stFloor) then
  begin
    Nrm := ntDown;
    RelNrm := ntDown;
    AbsNrm := ntDown;

    Tilt := VertsTilt(Verts);
    //writeln('Tilt for floor ' + Name + ' is ' + floattostr(tilt));
  end
  else if (Typ = stWall) then
  begin
    vec1 := T_EP_Vector.Create;
    try
      if Verts.Count >= 3 then
      begin
        // todo: remove ULC dependence
        vec1.i := T_EP_Vector(Verts[2]).i - T_EP_Vector(Verts[0]).i;
        vec1.j := T_EP_Vector(Verts[2]).j - T_EP_Vector(Verts[0]).j;
        theta := vectorAngle(vec1);
        Angle := theta;
      end;

      if theta <= 0 then theta := 2 * pi + theta;
      theta := RadToDeg(theta);
      if (theta >= 315) or (theta < 45) then
        RelNrm := ntSouth
      else if (theta >= 45) and (theta < 135) then
        RelNrm := ntEast
      else if (theta >= 135) and (theta < 225) then
        RelNrm := ntNorth
      else if (theta >= 225) and (theta < 315) then
        RelNrm := ntWest;

      theta := theta - BldgRotation;
      if theta < 0 then theta := theta + 360;
      if (theta >= 315) or (theta < 45) then
        AbsNrm := ntSouth
      else if (theta >= 45) and (theta < 135) then
        AbsNrm := ntEast
      else if (theta >= 135) and (theta < 225) then
        AbsNrm := ntNorth
      else if (theta >= 225) and (theta < 315) then
        AbsNrm := ntWest;

      if T_EP_Geometry(Geometry).UseRelativeAngles then
        Nrm := RelNrm
      else
        Nrm := AbsNrm;

      //find wall length
      if Verts.Count >= 4 then
      begin
        // todo: remove ULC dependence
        // DLM: not sure that this does what we want at all
        x1 := T_EP_Vector(verts[0]).i;
        y1 := T_EP_Vector(verts[0]).j;
        x2 := T_EP_Vector(verts[3]).i;
        y2 := T_EP_Vector(verts[3]).j;
      end;
      WallLength := sqrt(Power(x2 - x1, 2) + Power(y2 - y1, 2));

      //get wall tilt
      Tilt := VertsTilt(Verts);
      //writeln('Tilt for wall ' + Name + ' is ' + floattostr(tilt));
    finally
      vec1.Free;
    end;
  end;

  //find if any part of the wall is below grade
  //get the zone to get the absolute height of the wall
  aZone := GetZone(ZoneName);
  if Verts.Count >= 3 then
  begin
    GroundCoupled := false;
    if Typ = stWall then
    begin
      for iVert := 0 to Verts.Count-1 do
      begin
        z1 := aZone.ZOrigin + T_EP_Vector(verts[iVert]).k;
        if z1 < 0 then
        begin
          GroundCoupled := True;
          writeln(name + ' is below grade');
          break;
        end;
      end;
    end
    else if Typ = stFloor then
    begin
      for iVert := 0 to Verts.Count-1 do
      begin
        z1 := aZone.ZOrigin + T_EP_Vector(verts[iVert]).k;
        if z1 <= 0 then
        begin
          GroundCoupled := True;
          writeln(name + ' is on or below grade');
          break;
        end;
      end;
    end;
  end;
end;

procedure T_EP_Surface.GetWindowArea;
var
  winArea: double;
  iSub: Integer;
begin
  winArea := 0;
  for iSub := 0 to SubSurfaces.Count - 1 do
  begin
    if (SubSurfaces[iSub] is T_EP_Window) then
    begin
      winArea := winArea + AreaPolygon(T_EP_Window(SubSurfaces[iSub]).Verts);
    end;
  end;
  WindowArea := winArea;
end;

constructor T_EP_Surface.Create;
begin
  inherited;
  Verts := T_EP_Verts.Create;
  SubSurfaces := TObjectList.Create;
  Shading := TObjectList.Create;

  WriteObject := True;
  RoofFen := False;

  FTyp := stUnknown;
  FSpecificType := sstUnknown;
  FSolarExposure := seUnknown;
  FWindExposure := weUnknown;
  FConstruction := 'Default';
  FOutsideEnvironment := oeUnknown;
  FOutsideObject := '';
end;

procedure T_EP_Surface.MakeAdiabatic(MakeOtherZoneSurfaceAdiabaticAlso: boolean = false);
// DLM, this seems like a big hack but we allow MakeAdiabatic to directly change specific type and conditions
// this allows surfaces to be declared as adiabatic after they have been initially set to something else
// for instance when applying roof multiplier (roof is initially exterior, then changes to adiabatic)
var
  otherSurfname: string;
begin
  if MakeOtherZoneSurfaceAdiabaticAlso then
  begin
    //find other zone surface (if exist)
    otherSurfname := OutsideObject;
    if otherSurfname <> '' then
      GetSurface(otherSurfname).MakeAdiabatic(false);
  end;

  //set the surface variable to true in case it was called from elsewhere.
  //This variable is used to grab the right construction when the surface is finalized
  Adiabatic := true;

  //make internally reflective
  FOutsideEnvironment := oeOtherZoneSurface;
  FOutSideObject := Name;
  FSolarExposure := seNoSun;
  FWindExposure := weNoWind;

  //associate the type to adiabatic, and rename the construction to
  //the default value if it was changed.
  case Typ of
    stWall :
      begin
        FSpecificType := sstAdiabaticWall;
      end;
    stCeiling:
      begin
        FSpecificType := sstAdiabaticCeiling;
      end;
    stFloor:
      begin
        FSpecificType := sstAdiabaticFloor;
      end;
  end;
end;

procedure T_EP_Surface.ToIDF;
var
  i: integer;
  Obj: TEnergyPlusObject;
  sType: string;
begin
  inherited;
  Finalize;

  if not WriteObject then exit;

  Obj := IDF.AddObject('BuildingSurface:Detailed');
  Obj.AddField('Name', Name);

  // get the surface type string
  sType := GetSurfaceTypeAsString(Typ);

  // check if the ceiling was really a roof
  if (Typ = stCeiling) then
  begin
    case SpecificType of
      sstRoof: sType := 'Roof';
      sstAtticRoof: sType := 'Roof';
    end;
  end;
  
  Obj.AddField('Surface Type', sType);
  Obj.AddField('Construction Name', Construction);
  Obj.AddField('Zone Name', InsideEnvironment);
  Obj.AddField('Outside Boundary Condition', GetOutsideEnvironmentAsString(OutsideEnvironment));
  Obj.AddField('Outside Boundary Condition Object', OutsideObject);

  if SolarExposure = seSunExposed then
    Obj.AddField('Sun Exposure', 'SunExposed')
  else
    Obj.AddField('Sun Exposure', 'NoSun');

  if WindExposure = weWindExposed then
    Obj.AddField('Wind Exposure', 'WindExposed')
  else
    Obj.AddField('Wind Exposure', 'NoWind');

  Obj.AddField('View Factor to Ground', 'AutoCalculate');
  Obj.AddField('Number of Vertices', Verts.Count);
  for i := 0 to Verts.Count - 1 do
  begin
    Obj.AddField('X' + IntToStr(i + 1) + ', Y' + IntToStr(i + 1) + ', Z' + IntToStr(i + 1),
      format('%.4f,  %.4f,  %.4f',
      [T_EP_Vector(Verts[i]).i,
      T_EP_Vector(Verts[i]).j,
        T_EP_Vector(Verts[i]).k]));
  end;

  //write subsurfaces
  for i := 0 to SubSurfaces.Count - 1 do
  begin
    TEnergyPlusGroup(SubSurfaces.Items[i]).ToIDF;
  end;

  for i := 0 to Shading.Count - 1 do
  begin
    TEnergyPlusGroup(Shading.Items[i]).ToIDF;
  end;

end;

function T_EP_Surface.XCenter: double;
var
  i: Integer;
  x1: double;
begin
  x1 := 0;
  for i := 0 to Verts.Count - 1 do
  begin
    x1 := x1 + T_EP_Vector(Verts[i]).i;
  end;

  if Verts.Count <> 0 then
  begin
    x1 := x1 / Verts.Count;
  end
  else
  begin
    x1 := 0;
  end;
  result := x1;
end;

function T_EP_Surface.YCenter: double;
var
  i: Integer;
  y1: double;
begin
  y1 := 0;
  for i := 0 to Verts.Count - 1 do
  begin
    y1 := y1 + T_EP_Vector(Verts[i]).j;
  end;

  if Verts.Count <> 0 then
  begin
    y1 := y1 / Verts.Count;
  end
  else
  begin
    y1 := 0;
  end;
  result := y1;
end;

function T_EP_Surface.ZCenter: double;
var
  i: Integer;
  z1: double;
begin
  z1 := 0;
  for i := 0 to Verts.Count - 1 do
  begin
    z1 := z1 + T_EP_Vector(Verts[i]).k;
  end;

  if Verts.Count <> 0 then
  begin
    z1 := z1 / Verts.Count;
  end
  else
  begin
    z1 := 0;
  end;
  result := z1;
end;

function T_EP_Surface.ZMinimum: double;
var
  i: Integer;
  z1: double;
begin

  if Verts.Count <= 0 then
  begin
    result := 0;
    exit;
  end;

  z1 := T_EP_Vector(Verts[0]).k;
  for i := 1 to Verts.Count - 1 do
  begin
    if T_EP_Vector(Verts[i]).k < z1 then
      z1 := T_EP_Vector(Verts[i]).k;
  end;
  result := z1;
end;

function T_EP_Surface.ZMaximum: double;
var
  i: Integer;
  z1: double;
begin

  if Verts.Count <= 0 then
  begin
    result := 0;
    exit;
  end;

  z1 := T_EP_Vector(Verts[0]).k;
  for i := 1 to Verts.Count - 1 do
  begin
    if T_EP_Vector(Verts[i]).k > z1 then
      z1 := T_EP_Vector(Verts[i]).k;
  end;
  result := z1;
end;

{ T_EP_AttachedShading }

procedure T_EP_AttachedShading.AddCost(CostPer: double);
begin
  Cost := T_EP_Economics.Create;
  Cost.Name := 'Fixed Shading:' + Name;
  Cost.RefObjName := Name;
  Cost.Costing := ecCostPerArea;
  Cost.CostType := etShading;
  Cost.CostValue := CostPer;
end;

constructor T_EP_AttachedShading.Create;
begin
  inherited;
  Verts := T_EP_Verts.Create;
end;

procedure T_EP_AttachedShading.Finalize;
begin
  inherited;
  if (not Verts.AreFinalized) then
    Verts.Finalize;
end;

procedure T_EP_AttachedShading.ToIDF;
var
  i: Integer;
  Obj: TEnergyPlusObject;
begin
  inherited;
  Finalize;

  Obj := IDF.AddObject('Shading:Zone:Detailed');
  Obj.AddField('Name', Name);
  Obj.AddField('Base Surface Name', SurfaceName);
  Obj.AddField('Transmittance Schedule Name', '');
  Obj.AddField('Number of Vertices', Verts.Count);
  for i := 0 to Verts.Count - 1 do
  begin
    Obj.AddField('X' + IntToStr(i + 1) + ', Y' + IntToStr(i + 1) + ', Z' + IntToStr(i + 1),
      format('%.4f,  %.4f,  %.4f',
      [T_EP_Vector(Verts[i]).i,
       T_EP_Vector(Verts[i]).j,
       T_EP_Vector(Verts[i]).k]));
  end;
  if Assigned(Cost) and EPSettings.Costs then Cost.ToIDF;
end;

function T_EP_AttachedShading.IsOverhang(): boolean;
// return true if overhang, otherwise is a fin
var
  normVec: T_EP_Vector;
begin
  // DLM: in case you want to test is fin or overhang
  normVec := VertsSurfaceNormal(Verts);

  // if surface is pointed up, normal < cos(60 deg) from up
  result :=  (normVec.k > 0.5);
end;

{ T_EP_DetachedShading}

constructor T_EP_DetachedShading.Create;
begin
  inherited;
  SurfaceType := 'Building';
  ShadingTransmittanceSchedule := '';
  Verts := T_EP_Verts.Create;
end;

procedure T_EP_DetachedShading.Finalize;
begin
  inherited;
  if (not Verts.AreFinalized) then
    Verts.Finalize;
end;

procedure T_EP_DetachedShading.ToIDF;
var
  i: Integer;
  Obj: TEnergyPlusObject;
begin
  inherited;
  Finalize;

  IDF.AddComment('');
  IDF.AddComment('Shading Surfaces');

  if SameText(SurfaceType, 'Fixed') then
    Obj := IDF.AddObject('Shading:Site:Detailed')
  else
    Obj := IDF.AddObject('Shading:Building:Detailed');

  Obj.AddField('Name', Name);
  Obj.AddField('Transmittance Schedule Name', ShadingTransmittanceSchedule);
  Obj.AddField('Number of Vertices', Verts.Count);
  for i := 0 to Verts.Count - 1 do
  begin
    Obj.AddField('X' + IntToStr(i + 1) + ', Y' + IntToStr(i + 1) + ', Z' + IntToStr(i + 1),
      format('%.4f,  %.4f,  %.4f',
      [T_EP_Vector(Verts[i]).i,
      T_EP_Vector(Verts[i]).j,
      T_EP_Vector(Verts[i]).k]));
  end;
end;

{ T_EP_InternalMass }

procedure T_EP_InternalMass.Finalize;
begin
  inherited;
end;

constructor T_EP_InternalMass.Create;
begin
  inherited;
  InternalMassMultiplier := 1.0;
end;

procedure T_EP_InternalMass.ToIDF;
var
  Obj: TEnergyPlusObject;
begin
  inherited;
  if SurfaceArea > 0 then
  begin
    Obj := IDF.AddObject('InternalMass');
    Obj.AddField('Name', ZoneName + ' Internal Mass');
    Obj.AddField('Construction Name', 'InteriorFurnishings');
    Obj.AddField('Zone Name', ZoneName);
    Obj.AddField('Surface Area', SurfaceArea);
  end;
end;

{ T_EP_SubSurface }

constructor T_EP_SubSurface.Create;
begin
  inherited;
  Verts := T_EP_Verts.Create;
  Multiplier := 1;
  OutsideObject := '';
end;

procedure T_EP_SubSurface.Finalize;
begin
  inherited;
  if (not Verts.AreFinalized) then
    Verts.Finalize;
end;

{ T_EP_VerticalSubSurface }

constructor T_EP_VerticalSubSurface.Create;
begin
  inherited;
end;

procedure T_EP_VerticalSubSurface.Finalize;
begin
  inherited;
end;

{ T_EP_Door }

constructor T_EP_Door.Create;
begin
  inherited;
  Construction := 'Default';
end;

procedure T_EP_Door.Finalize;
var
  aConstruction : T_EP_Construction;
  SwitchableGlazing: boolean;
begin
  inherited;
  SwitchableGlazing := False;
  if SameText(Construction, 'Default') then
  begin
    if DoorType = dtDoor then
    begin
      Construction := 'Std Swinging Door_con';
      if BldgConstructions.GetIndex('Opaque', 'door') >= 0 then
      begin
        aConstruction := BldgConstructions.GetConstruction('Opaque', 'door');
        Construction := aConstruction.Name;
      end;
    end
    else if DoorType = dtGlassDoor then
    begin
      // first look under fenestration door, then use regular fenestration
      Construction := 'Std Swinging Door_con';
      if BldgConstructions.GetIndex('Fenestration', 'door') >= 0 then
      begin
        aConstruction := BldgConstructions.GetConstruction('Fenestration', 'door');
        Construction := aConstruction.Name;
        SwitchableGlazing := aConstruction.SwitchableGlazing;
      end
      else
        begin
        case Nrm of
        ntNorth:
          begin
            aConstruction := BldgConstructions.GetConstruction('Fenestration', 'north');
            Construction := aConstruction.Name;
            SwitchableGlazing := aConstruction.SwitchableGlazing;
          end;
        ntSouth:
          begin
            aConstruction := BldgConstructions.GetConstruction('Fenestration', 'south');
            Construction := aConstruction.Name;
            SwitchableGlazing := aConstruction.SwitchableGlazing;
          end;
        ntEast:
          begin
            aConstruction := BldgConstructions.GetConstruction('Fenestration', 'east');
            Construction := aConstruction.Name;
            SwitchableGlazing := aConstruction.SwitchableGlazing;
          end;
        ntWest:
          begin
            aConstruction := BldgConstructions.GetConstruction('Fenestration', 'west');
            Construction := aConstruction.Name;
            SwitchableGlazing := aConstruction.SwitchableGlazing;
          end;
        end;
      end;
    end
    else if DoorType = dtNonSwingingDoor then
    begin
      Construction := 'Std Overhead Door';
      if BldgConstructions.GetIndex('Opaque', 'non-swinging-door') >= 0 then
      begin
        aConstruction := BldgConstructions.GetConstruction('Opaque', 'non-swinging-door');
        Construction := aConstruction.Name;
      end;
    end;
  end;
  if (SwitchableGlazing) then
  begin
    ShadingControl := Construction + '_ECcontrol';
  end;
end;

procedure T_EP_Door.ToIDF;
var
  i: integer;
  Obj: TEnergyPlusObject;
  sType: string;
begin
  inherited;
  Finalize;
  Obj := IDF.AddObject('FenestrationSurface:Detailed');
  Obj.AddField('Name', Name);
  if DoorType = dtDoor then
    sType := 'Door'
  else if DoorType = dtNonSwingingDoor then
    sType := 'Door'
  else if DoorType = dtGlassDoor then
    sType := 'GlassDoor'
  else
    T_EP_PPErrorMessage.AddErrorMessage(esWarning, 'Unknown door type');
  Obj.AddField('Surface Type', sType);
  Obj.AddField('Construction Name', Construction);
  Obj.AddField('Building Surface Name', SurfaceName);
  Obj.AddField('Outside Boundary Condition Object', OutsideObject);
  Obj.AddField('View Factor to Ground', 'AutoCalculate');
  Obj.AddField('Shading Control Name', ShadingControl);
  Obj.AddField('Frame and Divider Name', '');
  Obj.AddField('Multiplier', Multiplier);
  Obj.AddField('Number of Vertices', Verts.Count);
  for i := 0 to Verts.Count - 1 do
  begin
    Obj.AddField('X' + IntToStr(i + 1) + ', Y' + IntToStr(i + 1) + ', Z' + IntToStr(i + 1),
      Format('%.4f,  %.4f,  %.4f', [T_EP_Vector(Verts[i]).i, T_EP_Vector(Verts[i]).j, T_EP_Vector(Verts[i]).k]));
  end;
end;

{ T_EP_Window }

constructor T_EP_Window.Create;
begin
  inherited;
  Verts := T_EP_Verts.Create;
  Multiplier := 1;
  Construction := 'Default';
  HasOverhang := false;
  HasFins := false;
end;

procedure T_EP_Window.Finalize;
var
  aConstruction : T_EP_Construction;
  glassConstructionLoaded: boolean;
begin
  inherited;
  glassConstructionLoaded := False;
  if SameText(Construction, 'Default') then
  begin
    //if none then it was customly set in the
    case Nrm of
    ntNorth:
      begin
        if WindowType = wtViewGlass then
        begin
          glassConstructionLoaded := True;
          aConstruction := BldgConstructions.GetConstruction('Fenestration', 'north');
        end
        else if WindowType = wtDaylightingGlass then
        begin
          glassConstructionLoaded := True;
          aConstruction := BldgConstructions.GetConstruction('DaylightFenestration', 'north');
        end
        else
        begin
          glassConstructionLoaded := True;
          if BldgConstructions.GetIndex('DaylightFenestration', 'north') < 0 then
            aConstruction := BldgConstructions.GetConstruction('Fenestration', 'north')
          else
            aConstruction := BldgConstructions.GetConstruction('DaylightFenestration', 'north');
        end;
      end;
    ntSouth:
      begin
        if WindowType = wtViewGlass then
        begin
          glassConstructionLoaded := True;
          aConstruction := BldgConstructions.GetConstruction('Fenestration', 'south');
        end
        else if WindowType = wtDaylightingGlass then
        begin
          glassConstructionLoaded := True;
          aConstruction := BldgConstructions.GetConstruction('DaylightFenestration', 'south');
        end
        else
        begin
          glassConstructionLoaded := True;
          if BldgConstructions.GetIndex('DaylightFenestration', 'south') < 0 then
            aConstruction := BldgConstructions.GetConstruction('Fenestration', 'south')
          else
            aConstruction := BldgConstructions.GetConstruction('DaylightFenestration', 'south');
        end;
      end;
    ntEast:
      begin
        if WindowType = wtViewGlass then
        begin
          glassConstructionLoaded := True;
          aConstruction := BldgConstructions.GetConstruction('Fenestration', 'east');
        end
        else if WindowType = wtDaylightingGlass then
        begin
          glassConstructionLoaded := True;
          aConstruction := BldgConstructions.GetConstruction('DaylightFenestration', 'east');
        end
        else
        begin
          glassConstructionLoaded := True;
          if BldgConstructions.GetIndex('DaylightFenestration', 'east') < 0 then
            aConstruction := BldgConstructions.GetConstruction('Fenestration', 'east')
          else
            aConstruction := BldgConstructions.GetConstruction('DaylightFenestration', 'east');
        end;
      end;
    ntWest:
      begin
        if WindowType = wtViewGlass then
        begin
          glassConstructionLoaded := True;
          aConstruction := BldgConstructions.GetConstruction('Fenestration', 'west');
        end
        else if WindowType = wtDaylightingGlass then
        begin
          glassConstructionLoaded := True;
          aConstruction := BldgConstructions.GetConstruction('DaylightFenestration', 'west');
        end
        else
        begin
          glassConstructionLoaded := True;
          if BldgConstructions.GetIndex('DaylightFenestration', 'west') < 0 then
            aConstruction := BldgConstructions.GetConstruction('Fenestration', 'west')
          else
            aConstruction := BldgConstructions.GetConstruction('DaylightFenestration', 'west');
        end;
      end;
    end;
    Construction := aConstruction.Name;
  end;
  if (glassConstructionLoaded and aConstruction.SwitchableGlazing) then
  begin
    ShadingControl := Construction + '_ECcontrol';
  end;
  if (glassConstructionLoaded and aConstruction.WindowShaded) then
  begin
    ShadingControl := Construction + '_WindowShade';
  end;
end;

procedure T_EP_Window.ToIDF;
var
  i: integer;
  Obj: TEnergyPlusObject;
begin
  inherited;
  Finalize;
  Obj := IDF.AddObject('FenestrationSurface:Detailed');
  Obj.AddField('Name', Name);
  Obj.AddField('Surface Type', 'Window');
  Obj.AddField('Construction Name', Construction);
  Obj.AddField('Building Surface Name', SurfaceName);
  Obj.AddField('Outside Boundary Condition Object', OutsideObject);
  Obj.AddField('View Factor to Ground', 'AutoCalculate');
  Obj.AddField('Shading Control Name', ShadingControl);
  Obj.AddField('Frame and Divider Name', '');
  Obj.AddField('Multiplier', Multiplier);
  Obj.AddField('Number of Vertices', Verts.Count);
  for i := 0 to Verts.Count - 1 do
  begin
    Obj.AddField('X' + IntToStr(i + 1) + ', Y' + IntToStr(i + 1) + ', Z' + IntToStr(i + 1),
      Format('%.4f,  %.4f,  %.4f', [T_EP_Vector(Verts[i]).i, T_EP_Vector(Verts[i]).j, T_EP_Vector(Verts[i]).k]));
  end;
end;

{ T_EP_TDD }

procedure T_EP_TDD.Finalize;
begin
  inherited;
end;

constructor T_EP_TDD.Create;
begin
  inherited;
  Verts := T_EP_Verts.Create;
  Diffuser := T_EP_Skylight.Create;
  Dome := T_EP_Skylight.Create;
end;

procedure T_EP_TDD.ToIDF;
var
  i: integer;
  Obj: TEnergyPlusObject;
begin
  inherited;
  Finalize;

  Obj := IDF.AddObject('DaylightingDevice:Tubular');
  Name := 'Pipe_' + IntToStr(index);
  Obj.AddField('Name', Name);
  Obj.AddField('Dome Name', 'Dome_' + IntToStr(index));
  Obj.AddField('Diffuser Name', 'Diffuser_' + IntToStr(index));
  if Construction <> '' then
    Obj.AddField('Construction Name', Construction)
  else
    Obj.AddField('Construction Name', 'TDD_Pipe');
  Obj.AddField('Diameter', Diameter);
  Obj.AddField('Total Length', TubeLength + 0.1);
  Obj.AddField('Effective Thermal Resistance', 0.28);
  Obj.AddField('Transition Zone 1 Name', ZoneName);
  Obj.AddField('Transition Zone 1 Length', TubeLength);

  Dome.Name := 'Dome_' + IntToStr(index);
  Dome.SkylightType := stDome;
  Dome.SurfaceName := TopSurfaceName;
  //add verts from TDD object
  for i := 0 to Verts.Count - 1 do
  begin
    Dome.Verts.AddVert(T_EP_Vector(verts[i]).i,
      T_EP_Vector(verts[i]).j,
      T_EP_Vector(verts[i]).k);
  end;
  Dome.Verts.Finalize();

  Diffuser.Name := 'Diffuser_' + IntToStr(index);
  Diffuser.SkylightType := stDiffuser;
  Diffuser.SurfaceName := BottomSurfaceName;
  //add verts from TDD object
  for i := 0 to Verts.Count - 1 do
  begin
    Diffuser.Verts.AddVert(T_EP_Vector(verts[i]).i,
      T_EP_Vector(verts[i]).j,
      T_EP_Vector(verts[i]).k - TubeLength);
  end;
  Diffuser.Verts.Finalize();

  Dome.ToIDF;
  Diffuser.ToIDF;
end;

{ T_EP_CustomTDD }

procedure T_EP_CustomTDD.Finalize;
var
  iZone: integer;
  aZone: T_EP_Zone;
begin
  //get length from zone area and volume
  for iZone := 0 to Zones.Count - 1 do
  begin
    aZone := T_EP_Zone(Zones[iZone]);
    if SameText(aZone.Name, ZoneName) then
    begin
      ZoneLength := aZone.AirVolume/aZone.Area;
    end;
  end;
end;

constructor T_EP_CustomTDD.Create;
begin
  inherited;
end;

procedure T_EP_CustomTDD.ToIDF;
var
  Zone: T_EP_Zone;
  Obj: TEnergyPlusObject;
begin
  inherited;
  Finalize;
  Obj := IDF.AddObject('DaylightingDevice:Tubular');
  Obj.AddField('Name', DomeName + '_' + DiffuserName + '_Pipe');
  Obj.AddField('Dome Name', DomeName);
  Obj.AddField('Diffuser Name', DiffuserName);
  Obj.AddField('Construction Name', 'TDD_Pipe');
  Obj.AddField('Diameter', Diameter);
  Obj.AddField('Total Length', ZoneLength + 0.1);
  Obj.AddField('Effective Thermal Resistance', '0.28');
  Obj.AddField('Transition Zone 1 Name', ZoneName);
  Obj.AddField('Transition Zone 1 Length', ZoneLength);
end;

{ T_EP_Skylight }

constructor T_EP_Skylight.Create;
begin
  inherited;
end;

procedure T_EP_Skylight.Finalize;
var
  aConstruction: T_EP_Construction;
  SwitchableGlazing: boolean;
  WindowShaded: boolean;
begin
  inherited;
  SwitchableGlazing := False;
  WindowShaded := false;
  if (SkylightType = stSkylight) then
  begin
    Construction := 'Skylight';
    if BldgConstructions.GetIndex('Fenestration', 'SkylightConst') >= 0 then
    begin
      aConstruction := BldgConstructions.GetConstruction('Fenestration', 'SkylightConst');
      Construction := aConstruction.Name;
      SwitchableGlazing := aConstruction.SwitchableGlazing;
      WindowShaded := aConstruction.WindowShaded;
    end
  end
  else if (SkylightType = stDiffuser) then
  begin
    Construction := 'TDD_Diffuser';
    if BldgConstructions.GetIndex('Fenestration', 'TDD-diffuser') >= 0 then
    begin
      aConstruction := BldgConstructions.GetConstruction('Fenestration', 'TDD-diffuser');
      Construction := aConstruction.Name;
      SwitchableGlazing := aConstruction.SwitchableGlazing;
      WindowShaded := aConstruction.WindowShaded;
    end
  end
  else if (SkylightType = stDome) then
  begin
    Construction := 'TDD_Dome';
    if BldgConstructions.GetIndex('Fenestration', 'TDD-dome') >= 0 then
    begin
      aConstruction := BldgConstructions.GetConstruction('Fenestration', 'TDD-dome');
      Construction := aConstruction.Name;
      SwitchableGlazing := aConstruction.SwitchableGlazing;
      WindowShaded := aConstruction.WindowShaded;
    end
  end;
  if (SwitchableGlazing) then
  begin
    ShadingControl := Construction + '_ECcontrol';
  end;
  if (WindowShaded) then
  begin
    ShadingControl := Construction + '_WindowShade';
  end;
end;

procedure T_EP_Skylight.ToIDF;
var
  i: integer;
  Obj: TEnergyPlusObject;
  sType: string;
begin
  inherited;
  Finalize;
  if SkylightType = stSkylight then
    sType := 'Window'
  else if SkylightType = stDiffuser then
    sType := 'TubularDaylightDiffuser'
  else if SkylightType = stDome then
    sType := 'TubularDaylightDome'
  else
    T_EP_PPErrorMessage.AddErrorMessage(esWarning, 'Unknown Skylight type');

  Obj := IDF.AddObject('FenestrationSurface:Detailed');
  Obj.AddField('Name', Name);
  Obj.AddField('Surface Type', sType);
  Obj.AddField('Construction Name', Construction);
  Obj.AddField('Building Surface Name', SurfaceName);
  if sType = 'TubularDaylightDome' then
    Obj.AddField('Outside Boundary Condition Object', '') //for custom TDD
  else
    Obj.AddField('Outside Boundary Condition Object', OutsideObject);
  Obj.AddField('View Factor to Ground', 'AutoCalculate');
  Obj.AddField('Shading Control Name', ShadingControl);
  Obj.AddField('Frame and Divider Name', '');
  Obj.AddField('Multiplier', 1);
  Obj.AddField('Number of Vertices', Verts.Count);
  for i := 0 to Verts.Count - 1 do
  begin
    Obj.AddField('X' + IntToStr(i + 1) + ', Y' + IntToStr(i + 1) + ', Z' + IntToStr(i + 1),
      Format('%.4f,  %.4f,  %.4f', [T_EP_Vector(Verts[i]).i, T_EP_Vector(Verts[i]).j, T_EP_Vector(Verts[i]).k]));
  end;
end;

end.
