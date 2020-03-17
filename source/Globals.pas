////////////////////////////////////////////////////////////////////////////////
//                                                                            //
// Copyright (c) 2008-2020 Alliance for Sustainable Energy.                   //
// All rights reserved.                                                       //
//                                                                            // 
////////////////////////////////////////////////////////////////////////////////

unit Globals;

interface

uses
  Contnrs,
  Classes,
  EnergyPlusCore,
  EnergyPlusIDF,
  EnergyPlusObject,
  EnergyPlusConstructions;

//  EnergyPlusElectricLoadCenter;

type
  TWindowRepresentationType = (wrtBanded, wrtDiscrete); //only banded works for now
  TWindowApplyType = (watTopDown, watBottomUp);
  TWindowType = (wtViewGlass, wtDaylightingGlass);
  TEquipmentType = (etGas, etElectric);
  TSurfaceType = (stWall, stCeiling, stFloor, stUnknown);  // walls, ceiling, and floor can be interior or exterior, depends on specific type
  TSpecificSurfaceType = (sstExteriorWall, sstInteriorWall,
    sstInteriorCeiling, sstRoof, sstAtticCeiling, sstAtticRoof,
    sstInteriorFloor, sstSlab, sstBelowGradeExteriorWall, sstExposedFloor,
    sstAtticFloor,
    sstAdiabaticWall,
    sstAdiabaticFloor,
    sstAdiabaticCeiling,
    sstUnknown);
  TOutsideEnvironment =(oeUnknown, oeOtherZoneSurface, oeUnenteredOtherZoneSurface, oeExteriorEnvironment, oeGround, oeOtherSideCoeff, oeOtherSideConditionsModel, oeAdiabatic, oeTranspiredSolarCollector);
  TSolarExposure = (seUnknown, seSunExposed, seNoSun);
  TWindExposure = (weUnknown, weWindExposed, weNoWind);
  TNormalType = (ntNorth, ntSouth, ntEast, ntWest, ntCustom, ntUp, ntDown, ntNone); //none is used for floors and ceiling
  TDoorType = (dtDoor, dtGlassDoor, dtNonSwingingDoor);
  TSkylightType = (stSkylight, stDiffuser, stDome);
  TZoneType = (ztNormal, ztPlenum, ztAttic);
  TFloorType = (ftUnknown, ftBasement, ftGround, ftMiddle, ftTop, ftAttic);

  function GetSurfaceTypeAsString(surfaceType: TSurfaceType): string;
  function GetOutsideEnvironmentAsString(outsideEnvironment: TOutsideEnvironment): string;

var
  IDF: TEnergyPlusIDF;
  //Obj: TEnergyPlusObject; //  frequently used variable
  //Building : T_EP_Building;

  Directory: string;
  InputFileName: string;

  BldgConstructions: T_EP_Constructions;
 // ElectricLoadCenter: T_EP_ElectricLoadCenter;
  Schedules: TObjectList;
  Settings: TObjectList;
  gPreprocSettings: TObject;
  Materials: TObjectList;
  Geometry: TObject;
  Zones: TObjectList;
  gPerformanceCurves: TObjectList;
  ExternalSurfaces: TObjectList; // Surfaces outside the building including PV
  Systems: TObjectList; // global registry of all systems
  Misc: TObjectList;
  ErrorMessages: TObjectList;
  BldgRotation: double;
  gloTDDIndex: integer; //this has to be global... to generate unique instances of TDDs
  RefrigerantList: TStringList;
  TranspiredSolarCollectorSurfaces: TStringList;
  TranspiredSolarCollectorArea: TStringList;
  TranspiredSolarCollectorMaxZ: TStringList;
  TranspiredSolarCollectorMinZ: TStringList;
  CreateChillerCondenserLoop: boolean;
  UseEvapCoolerEmsCode: boolean;
  HasHeatRecoveryChiller: boolean;
  HasHeatPumpHotWaterHeater:boolean;

implementation

function GetSurfaceTypeAsString(surfaceType: TSurfaceType): string;
begin
  case surfaceType of
    stWall: result := 'Wall';
    stFloor: result := 'Floor';
    stCeiling: result := 'Ceiling';
  end;
end;

function GetOutsideEnvironmentAsString(outsideEnvironment: TOutsideEnvironment): string;
begin
  case outsideEnvironment of
    oeUnknown: result := 'Unknown';
    oeOtherZoneSurface: result := 'Surface';
    oeUnenteredOtherZoneSurface: result := 'Zone';
    oeExteriorEnvironment: result := 'Outdoors';
    oeGround: result := 'Ground';
    oeAdiabatic: result := 'Adiabatic';
    oeOtherSideCoeff: result := 'OtherSideCoefficients';
    oeOtherSideConditionsModel: result := 'OtherSideConditionsModel';
    oeTranspiredSolarCollector: result := 'OtherSideConditionsModel';
  end;
end;

end.
