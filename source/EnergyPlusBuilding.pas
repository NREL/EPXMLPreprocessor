////////////////////////////////////////////////////////////////////////////////
//                                                                            //
// Copyright (c) 2008-2020 Alliance for Sustainable Energy.                   //
// All rights reserved.                                                       //
//                                                                            // 
////////////////////////////////////////////////////////////////////////////////

unit EnergyPlusBuilding;

interface

uses
  Contnrs,
  EnergyPlusCore,
  classes,
  EnergyPlusExteriorLoads,
  EnergyPlusInternalGains,
  EnergyPlusReportVariables,
  EnergyPlusElectricLoadCenter,
  EnergyPlusSurfaces,
  SysUtils,
  EnergyPlusZones,
  GlobalFuncs;

type
  T_EP_Building = class(TEnergyPlusGroup)
  public
    //Schedules : T_EP_Schedules;
    BuildingName: string;
    DesignDayLibrary: TStringList;
    DirectSubText: TStringList;
    //Geometry : TObjectList;
    //Zones : TObjectList;
    //Systems : TObjectList;  // these are currently globals that should move into this class
    //Misc : TObjectList;
    ExteriorLights: T_EP_ExteriorFacadeLighting;
    HeaderInformation : string;
    LegalNoticeType : string;
    ReportVariables: T_EP_ReportVariables;
    SimMetaData: TStringList;
    SimpleRefrigeration: T_EP_SimpleRefrigeration;
    USHolidaysLibrary: TStringList;
    UtilityRatesLibrary: TStringList;
    WebInterfaceBldgDescription: string;
    WebInterfaceParameters: TStringList;
    constructor Create; reintroduce;
    procedure AddExteriorLights(WPerM: double; FloorNumber: integer; TotalPower: double;
      PowerDensity: double; ScheduleName: string; ControlOption: string);
    procedure AddSimpleRefrigeration(WPerM: double; CostPer: double);
    function CheckAdjacency(aZone_1: T_EP_Zone; aSurf_1: T_EP_Surface;
                             aZone_2: T_EP_Zone; aSurf_2:T_EP_Surface):boolean;
    procedure Finalize; override;
    procedure ApplyFloorMultipliers;
    procedure FinalizeBoundaryConditions;
    procedure ToIDF; override;
  end;

implementation

uses Globals,
  VectorMath, EnergyPlusConstructions, EnergyPlusGeometry,
  PlatformDepFunctions, EnergyPlusPPErrorMessages;

constructor T_EP_Building.Create;
begin
  inherited;
  DesignDayLibrary := TStringList.Create;
  UtilityRatesLibrary := TStringList.Create;
  USHolidaysLibrary := TStringList.Create;
  SimMetaData := TStringList.Create;
  WebInterfaceParameters := TStringList.Create;
  WebInterfaceBldgDescription := '';
  DirectSubText := TStringList.Create;
  ReportVariables := T_EP_ReportVariables.Create;
  Schedules := TObjectList.Create;
  Settings := TObjectList.Create;
  Materials := TObjectList.Create;
  BldgConstructions := T_EP_Constructions.Create;
  Geometry := TObjectList.Create;
  Zones := TObjectList.Create;
  ExternalSurfaces := TObjectList.Create;
  gPerformanceCurves := TObjectList.Create;
  gPreprocSettings := TObjectList.Create;
  Systems := TObjectList.Create; // these are currently globals that should move into this class
  Misc := TObjectList.Create;
  ErrorMessages := TObjectList.Create;
end;

{ T_EP_Building }

procedure T_EP_Building.AddExteriorLights(WPerM: double; FloorNumber: integer;
  TotalPower: double; PowerDensity: double; ScheduleName: string; ControlOption: string);
var
  ttlLength: double;
  iZone: Integer;
  aZone: T_EP_Zone;
  iSurf: Integer;
  aSurf: T_EP_Surface;
  SurfaceLength: double;
  SurfaceArea: double;
  SurfaceHeight: double;
  bKnowFloors: Boolean;
begin
  ExteriorLights := T_EP_ExteriorFacadeLighting.Create;
  ExteriorLights.Name := 'Exterior Facade Lighting';
  ExteriorLights.TotalPower := TotalPower;
  ExteriorLights.PowerDensity := PowerDensity;
  ExteriorLights.ScheduleName := ScheduleName;
  ExteriorLights.ControlOption := ControlOption;
  //find total perimeter length
  ttlLength := 0;
  for iZone := 0 to Zones.Count - 1 do
  begin
    aZone := T_EP_Zone(Zones[iZone]);
    if aZone.FloorInfo.FloorNumberKnown then
    begin
      if (aZone.FloorInfo.FloorNumber = FloorNumber) then
      begin
        for iSurf := 0 to aZone.Surfaces.Count - 1 do
        begin
          aSurf := T_EP_Surface(aZone.Surfaces[iSurf]);
          if aSurf.SpecificType = sstExteriorWall then
          begin
            if aSurf.Verts.Count > 0 then
            begin
              SurfaceArea := AreaPolygon(aSurf.Verts);
              // todo: remove ULC dependence
              SurfaceHeight := T_EP_Vector(aSurf.Verts[0]).k; //since ULC geom
              if SurfaceHeight <> 0 then
                SurfaceLength := SurfaceArea / SurfaceHeight
              else
                SurfaceLength := 0;
              ttlLength := ttlLength + (aZone.ZoneMultiplier * SurfaceLength);
            end;
          end;
        end; //for i
      end;
    end
    else
    begin
      for iSurf := 0 to aZone.Surfaces.Count - 1 do
      begin
        aSurf := T_EP_Surface(aZone.Surfaces[iSurf]);
        if aSurf.SpecificType = sstExteriorWall then
        begin
          if aSurf.Verts.Count >= 3 then
          begin
            //check if this surface touches the ground (vert 1-2 needs to be 0)
            if (T_EP_Vector(aSurf.Verts[1]).k = 0) and
               (T_EP_Vector(aSurf.Verts[2]).k = 0) then
            begin
              SurfaceArea := AreaPolygon(aSurf.Verts);
              // todo: remove ULC dependence
              SurfaceHeight := T_EP_Vector(aSurf.Verts[0]).k; //since ULC geom
              if SurfaceHeight <> 0 then
                SurfaceLength := SurfaceArea / SurfaceHeight
              else
                SurfaceLength := 0;
              ttlLength := ttlLength + (aZone.ZoneMultiplier * SurfaceLength);
            end;
          end;
        end;
      end;
    end;
  end; //for izone
  //ejb:  if using old attribute instance
  if (WPerM <> 0) then
  begin
    ExteriorLights.DesignLevel := WPerM * ttlLength
  end;
  //ejb: if using new elements total power or power density
  if TotalPower <> 0 then
  begin
    ExteriorLights.DesignLevel := TotalPower;
  end;
  if PowerDensity <> 0 then
  begin
    ExteriorLights.DesignLevel := PowerDensity * ttlLength;
  end;
end;

procedure T_EP_Building.AddSimpleRefrigeration(WPerM: double; CostPer: Double);
var
  ttlArea: double;
begin
  ttlArea := T_EP_Geometry(Geometry).TotalArea;
  if ttlArea <> 0 then
  begin
    SimpleRefrigeration := T_EP_SimpleRefrigeration.Create;
    SimpleRefrigeration.Name := 'Equipment_SimpleRefrigeration';
    SimpleRefrigeration.ScheduleName := 'ALWAYS_ON';
    SimpleRefrigeration.EndUseSubcategory := 'Refrigeration (simple)';
    SimpleRefrigeration.DesignLevel := WPerM * ttlArea;
    if CostPer <> 0 then
    begin
      SimpleRefrigeration.AddCost(CostPer);
    end;
  end;
end;

function T_EP_Building.CheckAdjacency (aZone_1: T_EP_Zone; aSurf_1: T_EP_Surface;
                                       aZone_2: T_EP_Zone; aSurf_2:T_EP_Surface):boolean;
//this routine recursively goes though all the points for the surface
//and returns whether or not the surfaces are adjacent as a boolean.
//The surfaces have to be defined as CCW but they do not have to use the ULC
//convention.
var
  bFound: Boolean;
  iVert_1: Integer;
  iVert_2: Integer;
  bStart: Boolean;
  iStart: Integer;
  ndx: integer;
begin
  bFound := false;
  bStart := false;
  //no reason to check adjacency for surfaces that don't have the same number of
  //vertices
  if aSurf_1.Verts.Count = aSurf_2.Verts.Count then   
  begin
    //march around the vertices for surface 1 (in CCW) direction
    for iVert_1 := 0 to aSurf_1.Verts.Count - 1 do
    begin
      //see if any of the vertices match for surface 2
      //if so then keep marching around surface 2 in the opposite
      //direction (CW) until a match is not found.
      bStart := false;
      for iVert_2 := aSurf_2.Verts.Count - 1 downto 0 do
      begin
        if (abs((aZone_1.XOrigin + T_EP_Vector(aSurf_1.Verts[iVert_1]).i) -
           (aZone_2.XOrigin + T_EP_Vector(aSurf_2.Verts[iVert_2]).i)) < 0.01) and
           (abs((aZone_1.YOrigin + T_EP_Vector(aSurf_1.Verts[iVert_1]).j) -
           (aZone_2.YOrigin + T_EP_Vector(aSurf_2.Verts[iVert_2]).j)) < 0.01) and
           (abs((aZone_1.ZOrigin + T_EP_Vector(aSurf_1.Verts[iVert_1]).k) -
           (aZone_2.ZOrigin + T_EP_Vector(aSurf_2.Verts[iVert_2]).k)) < 0.01) then
        begin
          bStart := true;
          iStart := iVert_2;
          break;
        end;
      end;
      //See if all the points from this starting point match (rather fail
      //when they don't match).
      if bStart then
      begin
        //need to handle wrapping around of the index (i.e. 2, 1, 0, 3)
        bFound := false;
        for iVert_2 := 0 to aSurf_2.Verts.Count - 1 do
        begin
          ndx := iStart - iVert_2;
          if ndx < 0 then ndx := aSurf_2.Verts.Count + ndx;
          //check to see if the surface is within range
          if (abs((aZone_1.XOrigin + T_EP_Vector(aSurf_1.Verts[iVert_2]).i) -
             (aZone_2.XOrigin + T_EP_Vector(aSurf_2.Verts[ndx]).i)) < 0.01) and
             (abs((aZone_1.YOrigin + T_EP_Vector(aSurf_1.Verts[iVert_2]).j) -
             (aZone_2.YOrigin + T_EP_Vector(aSurf_2.Verts[ndx]).j)) < 0.01) and
             (abs((aZone_1.ZOrigin + T_EP_Vector(aSurf_1.Verts[iVert_2]).k) -
             (aZone_2.ZOrigin + T_EP_Vector(aSurf_2.Verts[ndx]).k)) < 0.01) then
          begin
            bFound := true;
          end
          else
          begin
            bFound := false;
            break;
          end;
        end;
        if bFound then break;
      end
      else
      begin
        bFound := false;
      end;
    end;
  end;
  result := bFound;
end;

procedure T_EP_Building.Finalize;
begin
  inherited;
end;

procedure T_EP_Building.ApplyFloorMultipliers;
var
  iSurf,iSurf2: Integer;
  aSurf, aSurf2: T_EP_Surface;
  aZone: T_EP_Zone;
  iZone: Integer;
begin
  // TODO: DLM, I broke this out from process zone info, still needs a lot of work
  // go thru all the zone's surfaces
  for iZone := 0 to Zones.Count - 1 do
  begin
    aZone := T_EP_Zone(zones[iZone]);
    with aZone do
    begin
      //go thru and check if they are multiplied --if so make ceiling and floor self referencing
      if FloorMultiplier then
      begin
        if FloorInfo.FloorType = ftGround then
        begin
          if FloorMultiplierVal <> 1 then
          begin
            T_EP_PPErrorMessage.AddErrorMessage(esFatal, 'Attempting to add floor multiplier to ground floor');
          end
          else
          begin
            for iSurf := 0 to Surfaces.Count - 1 do
            begin
              aSurf := T_EP_Surface(Surfaces.Items[iSurf]);
              if aSurf.Typ = stCeiling then
              begin
                aSurf.MakeAdiabatic;
              end;
            end;
          end;
        end
        else if FloorInfo.FloorType = ftTop then
        begin
          if FloorMultiplierVal <> 1 then
          begin
            T_EP_PPErrorMessage.AddErrorMessage(esFatal, 'Attempting to add floor multiplier to top floor');
          end
          else
          begin
            for iSurf := 0 to Surfaces.Count - 1 do
            begin
              aSurf := T_EP_Surface(Surfaces.Items[iSurf]);
              if aSurf.Typ = stFloor then
              begin
                aSurf.MakeAdiabatic;
              end;
            end;
            //add spacing in the DXF to make it obvious that they are multiplied
            ZOrigin := 2 * ZOrigin;
          end;
        end
        else if FloorInfo.FloorType = ftMiddle then
        begin
          //make the ceiling construction reference the floor construction
          for iSurf := 0 to Surfaces.Count - 1 do
          begin
            aSurf := T_EP_Surface(Surfaces.Items[iSurf]);
            if aSurf.Typ = stFloor then
            begin
              // this is the one place where floor multiplier gets rolled into zone multiplier
              ZoneMultiplier := ZoneMultiplier * FloorMultiplierVal;
              for iSurf2 := 0 to Surfaces.Count - 1 do
              begin
                aSurf2 := T_EP_Surface(Surfaces.Items[iSurf2]);
                if aSurf2.Typ = stCeiling then
                begin
                  // TODO: DLM, this logic does not work if multiple ceilings or floors in the zone
                  aSurf.SetOutsideObject(aSurf2.Name);
                  aSurf.SetOutsideEnvironment(oeOtherZoneSurface);
                  aSurf.SetSpecificType(sstInteriorFloor);
                  aSurf2.SetOutsideObject(aSurf.Name);
                  aSurf2.SetOutsideEnvironment(oeOtherZoneSurface);
                  aSurf2.SetSpecificType(sstInteriorCeiling);
                  break;
                end;
              end;
            end;
          end;
          //add spacing in the DXF to make it obvious that they are multiplied
          ZOrigin := 2 * ZOrigin;
        end;
      end;
    end;
  end;
end;

procedure T_EP_Building.FinalizeBoundaryConditions;
//this routines finds the adjacent surfaces for all of the zones.
//Ensures that SpecificTyp is set for each surface
//OutsideObject will also be set here if a match is found
//OutsideEnvironment, OutsideObject, SolarExposure, and WindExposure will be set in T_EP_Surface.Finalize at end of function

//THIS IS THE LAST FUNCTION WHERE SPECIFIC TYPE SHOULD BE SET
var
  iZones_1, iZones_2: Integer;
  iSurf_1, iSurf_2: Integer;
  aZone_1, aZone_2: T_EP_Zone;
  aSurf_1, aSurf_2: T_EP_Surface;
  bFound: Boolean;
begin
  //setLength(WallAbs,length(WallAbs) + aZone.Surfaces.Count + 1);
  // go thru all the zone's surfaces
  for iZones_1 := 0 to Zones.Count - 1 do
  begin
    aZone_1 := T_EP_Zone(zones[iZones_1]);
    for iSurf_1 := 0 to aZone_1.Surfaces.Count - 1 do
    begin
      aSurf_1 := T_EP_Surface(aZone_1.Surfaces[iSurf_1]);
      // if specific type already set then we already got it figured out
      if aSurf_1.SpecificType <> sstUnknown then
        continue;
      //see if aSurf has a matching surf in another zone
      // no specific type setting has come before here
      // so we use that as the test to whether we are done
      for iZones_2 := 0 to zones.count - 1 do
      begin
        // the second zone
        aZone_2 := T_EP_Zone(zones[iZones_2]);
        for iSurf_2 := 0 to aZone_2.Surfaces.Count - 1 do
        begin
          aSurf_2 := T_EP_Surface(aZone_2.Surfaces[iSurf_2]);
          // the outside object has already been set in aSurf_1 respect that condition,
          // otherwise use a geometric test
          if (aSurf_1.OutsideObject <> '') then
          begin
            bFound := SameText(aSurf_1.OutsideObject, aSurf_2.Name);
          end
          else
          begin
            //rewrite this to recursively look through the points
            //regardless if the points were entered as ULC or not.
            bFound := CheckAdjacency(aZone_1, aSurf_1, aZone_2, aSurf_2);
          end;
          if bFound then
          begin
            // if matched self then make adiabatic
            if (iZones_1 = iZones_2) and (iSurf_1 = iSurf_2) then
            begin
              aSurf_1.MakeAdiabatic;
            end
            else
            begin
              // set specific type with exterior = false
              aSurf_1.SetSpecificType(false, aZone_1.Typ, aZone_2.Typ, aSurf_1.GroundCoupled);
              aSurf_1.SetOutsideObject(aSurf_2.Name);
              aSurf_2.SetSpecificType(false, aZone_2.Typ, aZone_1.Typ, aSurf_2.GroundCoupled);
              aSurf_2.SetOutsideObject(aSurf_1.Name);
            end;
            break; //out of surface
          end;
        end; //for i Surf
      end; //for
    end;
  end; //for iZones

  //go thru and mark the exterior walls, slabs, roofs, attic floors, exposed floor
  for iZones_1 := 0 to Zones.Count - 1 do
  begin
    aZone_1 := T_EP_Zone(zones[iZones_1]);
    for iSurf_1 := 0 to aZone_1.Surfaces.Count - 1 do
    begin
      aSurf_1 := T_EP_Surface(aZone_1.Surfaces[iSurf_1]);
      // if SpecificSurfaceType is still not set, then this is an exterior surface
      if aSurf_1.SpecificType = sstUnknown then
      begin
        // set specific type with exterior = true
        aSurf_1.SetSpecificType(true, aZone_1.Typ, aZone_1.Typ, aSurf_1.GroundCoupled);
        aSurf_1.SetOutsideObject('');
      end;
    end;
  end; //for i
  //finalize all surfaces here to get constructions
  //sets outside environment, sun exposured, and wind exposed
  for iZones_1 := 0 to Zones.Count - 1 do
  begin
    aZone_1 := T_EP_Zone(zones[iZones_1]);
    for iSurf_1 := 0 to aZone_1.Surfaces.Count - 1 do
    begin
      aSurf_1 := T_EP_Surface(aZone_1.Surfaces[iSurf_1]);
      aSurf_1.Finalize;
    end;
  end;
end;

procedure T_EP_Building.ToIDF;
var
  i: integer;
  sAppVersion: string;
begin
  inherited;
  //add the header information if applicable
  IDF.AddComment(HeaderInformation, true, true);
  //add the libraries
  {$IFDEF MSWINDOWS}
  sAppVersion := GetAppVersion;
  IDF.AddComment('Generated by EPXMLPreproc2 (Windows 32 Version ' + sAppVersion + ')', True);
  {$ENDIF}
  {$IFDEF LINUX}
  sAppVersion := GetAppVersion;
  IDF.AddComment('Generated by EPXMLPreproc2 (Linux Version ' + sAppVersion + ')', True);
  {$ENDIF}
  IDF.ADDComment('Created on ' + FormatDateTime('MM/DD/YYYY hh:nn:ss', now), True);
  IDF.ADDComment('');
  if (LegalNoticeType = 'EEFG') or
     (LegalNoticeType = 'General') then
  begin
    IDF.AddComment('This data and software ("Data") is provided by the National Renewable');
    IDF.AddComment('Energy Laboratory ("NREL"), which is operated by the Alliance for');
    IDF.AddComment('Sustainable Energy, LLC ("ALLIANCE") for the U.S. Department Of');
    IDF.AddComment('Energy ("DOE").');
    IDF.AddComment('');
    IDF.AddComment('Access to and use of these Data shall impose the following obligations');
    IDF.AddComment('on the user, as set forth in this Agreement.  The user is granted the');
    IDF.AddComment('right, without any fee or cost, to use, copy, modify, alter, enhance');
    IDF.AddComment('and distribute these Data for any purpose whatsoever, provided that this');
    IDF.AddComment('entire notice appears in all copies of the Data.  Further, the user');
    IDF.AddComment('agrees to credit DOE/NREL/ALLIANCE in any publication that results from');
    IDF.AddComment('the use of these Data.  The names DOE/NREL/ALLIANCE, however, may not');
    IDF.AddComment('be used in any advertising or publicity to endorse or promote any products');
    IDF.AddComment('or commercial entities unless specific written permission is obtained from');
    IDF.AddComment('DOE/NREL/ ALLIANCE.  The user also understands that DOE/NREL/Alliance is');
    IDF.AddComment('not obligated to provide the user with any support, consulting, training');
    IDF.AddComment('or assistance of any kind with regard to the use of these Data or to');
    IDF.AddComment('provide the user with any updates, revisions or new versions of these Data.');
    IDF.AddComment('');
    IDF.AddComment('YOU AGREE TO INDEMNIFY DOE/NREL/Alliance, AND ITS SUBSIDIARIES, AFFILIATES,');
    IDF.AddComment('OFFICERS, AGENTS, AND EMPLOYEES AGAINST ANY CLAIM OR DEMAND, INCLUDING');
    IDF.AddComment('''REASONABLE ATTORNEYS'' FEES, RELATED TO YOUR USE OF THESE DATA.  THESE DATA');
    IDF.AddComment('ARE PROVIDED BY DOE/NREL/Alliance "AS IS" AND ANY EXPRESS OR IMPLIED');
    IDF.AddComment('WARRANTIES, INCLUDING BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF');
    IDF.AddComment('MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED.  IN');
    IDF.AddComment('NO EVENT SHALL DOE/NREL/ALLIANCE BE LIABLE FOR ANY SPECIAL, INDIRECT OR');
    IDF.AddComment('CONSEQUENTIAL DAMAGES OR ANY DAMAGES WHATSOEVER, INCLUDING BUT NOT LIMITED');
    IDF.AddComment('TO CLAIMS ASSOCIATED WITH THE LOSS OF DATA OR PROFITS, WHICH MAY RESULT');
    IDF.AddComment('FROM AN ACTION IN CONTRACT, NEGLIGENCE OR OTHER TORTIOUS CLAIM THAT');
    IDF.AddComment('ARISES OUT OF OR IN CONNECTION WITH THE ACCESS, USE OR PERFORMANCE OF');
    IDF.AddComment('THESE DATA.');
  end
  else if (LegalNoticeType = 'BENCHMARKS') then
  begin
    IDF.AddComment('NOTICE');
    IDF.AddComment('');
    IDF.AddComment('The Benchmarks were prepared as an account of work sponsored by an');
    IDF.AddComment('agency of the United States government. Neither the United States');
    IDF.AddComment('government nor any agency thereof, nor any of their employees, makes');
    IDF.AddComment('any warranty, express or implied, or assumes any legal liability or');
    IDF.AddComment('responsibility for the accuracy, completeness, or usefulness of any');
    IDF.AddComment('information, apparatus, product, or process disclosed, or represents');
    IDF.AddComment('that its use would not infringe privately owned rights. Reference');
    IDF.AddComment('herein to any specific commercial product, process, or service by');
    IDF.AddComment('trade name, trademark, manufacturer, or otherwise does not necessarily');
    IDF.AddComment('constitute or imply its endorsement, recommendation, or favoring by');
    IDF.AddComment('the United States government or any agency thereof. The views and');
    IDF.AddComment('opinions of authors expressed herein do not necessarily state or');
    IDF.AddComment('reflect those of the United States government or any agency thereof.');
    IDF.AddComment('');
    IDF.AddComment('Access to and use of the Benchmarks imposes the following obligations');
    IDF.AddComment('on the user. The user agrees to credit DOE, NREL, PNNL, and LBNL in');
    IDF.AddComment('any publication(s) that that result from the use of Benchmarks.');
    IDF.AddComment('However, the names of DOE/NREL/PNNL/LBNL may not be used in any');
    IDF.AddComment('advertising or publicity that implies endorsement or promotion of any');
    IDF.AddComment('products, services or commercial entities.');
    IDF.AddComment('');
    IDF.AddComment('Reference citation for the Commercial Building Benchmark Models:', True);
    IDF.AddComment('Deru, M.; Field, K.; Studer, D.; Griffith, B.; Long, N.; Benne, K.; ', True);
    IDF.AddComment('Torcellini, P; Halverson, M.; Winiarski,  D.; Liu, B.; Crawley, D. (2009). ', True);
    IDF.AddComment('DOE Commercial Building Resarch Benchmark Models for Energy Simulation. ', True);
    IDF.AddComment('Washington, DC: U.S. Department of Energy,', True);
    IDF.AddComment('Energy Efficiency and Renewable Energy, Office of Building Technologies.', True);
    IDF.AddComment('');
  end;
  if WebInterfaceBldgDescription <> '' then
  begin
    IDF.AddComment('');
    IDF.AddComment('Building Description', true);
    IDF.AddComment(WebInterfaceBldgDescription, true);
  end;
  //write out some global variables that can be used for other values
  if Assigned(SimMetaData) then
    if SimMetaData.Count > 0 then
    begin
      SimMetaData.Insert(0, 'Start SimMetaData');
      SimMetaData.Add('End SimMetaData');
      idf.AddStringList(SimMetaData, true);
    end;
  if Assigned(WebInterfaceParameters) then
    if WebInterfaceParameters.Count > 0 then
    begin
      WebInterfaceParameters.Insert(0, 'Start WebInterface Parameters');
      WebInterfaceParameters.Add('End WebInterface Parameters');
      idf.AddStringList(WebInterfaceParameters, true);
    end;
  //write out general IDF comments
  IDF.AddComment('Number of Zones: ' + IntToStr(Zones.Count), True);
  for i := 0 to Settings.Count - 1 do
  begin
    TEnergyPlusGroup(Settings[i]).ToIDF;
  end;
  if Assigned(USHolidaysLibrary) then
    if USHolidaysLibrary.Count > 0 then
      IDF.AddStringList(USHolidaysLibrary);
  if Assigned(DesignDayLibrary) then
    if DesignDayLibrary.Count > 0 then
      IDF.AddStringList(DesignDayLibrary);
  for i := 0 to Schedules.Count - 1 do
  begin
    IDF.AddComment('',false);
    IDF.AddComment('Schedule Set',false);
    TEnergyPlusGroup(Schedules[i]).ToIDF;
  end;
  //finalize constructions before writing the materials
  for i := 0 to BldgConstructions.Count - 1 do
  begin
    T_EP_Construction(BldgConstructions[i]).Finalize;
  end;
  for i := 0 to Materials.Count - 1 do
  begin
    TEnergyPlusGroup(Materials[i]).ToIDF;
  end;
  if Assigned(BldgConstructions.StaticLibrary) then
    if BldgConstructions.StaticLibrary.Count > 0 then
      IDF.AddStringList(BldgConstructions.StaticLibrary);
  if (Assigned(BldgConstructions.ExternalConstructionFile)) and
    (BldgConstructions.UseExternalFileForConstructions) then
    if BldgConstructions.ExternalConstructionFile.Count > 0 then
      IDF.AddStringList(BldgConstructions.ExternalConstructionFile);
  for i := 0 to BldgConstructions.Count - 1 do
  begin
    T_EP_Construction(BldgConstructions[i]).ToIDF;
  end;
  if Assigned(Geometry) then
    TEnergyPlusGroup(Geometry).ToIDF;
  for i := 0 to gPerformanceCurves.Count - 1 do
  begin
    TEnergyPlusGroup(gPerformanceCurves[i]).ToIDF;
  end;
  for i := 0 to Misc.Count - 1 do
  begin
    TEnergyPlusGroup(Misc[i]).ToIDF;
  end;
  for i := 0 to Systems.Count - 1 do
  begin
    TEnergyPlusGroup(Systems[i]).Finalize; //need to finalize systems before zones can be completed.
  end;
  for i := 0 to Zones.Count - 1 do
  begin
    T_EP_Zone(Zones[i]).ToIDF;
  end;
  for i := 0 to ExternalSurfaces.Count - 1 do
  begin
    // DLM: can add isA checks, but better hierarchy is needed
    // DLM: PVSurf has been depreciated, DetachedShading can do all it needs
    if (ExternalSurfaces[i] is T_EP_DetachedShading) then
    begin
      T_EP_DetachedShading(ExternalSurfaces[i]).ToIDF;
    end
    else
    begin
      T_EP_PPErrorMessage.AddErrorMessage(esSevere, 'Unknown type found in ExternalSurfaces');
    end;
  end;
  for i := 0 to Systems.Count - 1 do
  begin
    TEnergyPlusGroup(Systems[i]).ToIDF;
  end;
  // add refrigerant properties
  GetRefrigerantProperties(RefrigerantList);
  if Assigned(RefrigerantList) then
    RefrigerantList.Destroy;
  if Assigned(ErrorMessages) then
    for i := 0 to ErrorMessages.Count - 1 do
    begin
      TEnergyPlusGroup(ErrorMessages[i]).ToIDF;
    end;
  if Assigned(SimpleRefrigeration) then
    TEnergyPlusGroup(SimpleRefrigeration).ToIDF;
  if Assigned(ExteriorLights) then
    TEnergyPlusGroup(ExteriorLights).ToIDF;
  if Assigned(UtilityRatesLibrary) then
    if UtilityRatesLibrary.Count > 0 then
      IDF.AddStringList(UtilityRatesLibrary);
  if Assigned(ReportVariables.VariableLibrary) then
    if ReportVariables.VariableLibrary.Count > 0 then
    begin
      IDF.AddComment('',false);
      IDF.AddComment('Report Variables',false);
      IDF.AddStringList(ReportVariables.VariableLibrary);
    end;
  if Assigned(DirectSubText) then
    if DirectSubText.Count > 0 then
    begin
      IDF.AddComment('',false);
      IDF.AddComment('Direct Substitution Text',false);
      IDF.AddStringList(DirectSubText);
    end;
  if Assigned(ElectricLoadCenter) then
    ElectricLoadCenter.ToIDF;
end;

end.
