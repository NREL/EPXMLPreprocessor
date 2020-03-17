////////////////////////////////////////////////////////////////////////////////
//                                                                            //
// Copyright (c) 2008-2020 Alliance for Sustainable Energy.                   //
// All rights reserved.                                                       //
//                                                                            // 
////////////////////////////////////////////////////////////////////////////////

unit GlobalFuncs;

interface

uses
  EnergyPlusSurfaces,
  EnergyPlusPPErrorMessages,
  Globals,
  Classes,
  sysUtils,
  EnergyPlusZones,
  EnergyPlusSystems,
  EnergyPlusSystemComponents,
  PreProcMacro,
  RegExpr;

function GetSurface(SurfaceName: string): T_EP_Surface;
function GetZone(ZoneName: string): T_EP_Zone;
procedure GetDxCurves(DataSetKey: string; Typ: string; Name: string; FanType: string);
procedure GetHeatPumpEqnFitCoil(DataSetKey: string; Typ: string; Name: string; COP: double; FanPlacement: string);
procedure GetRefrigerantProperties(RefrigerantList: TStringList);

implementation

function GetSurface(SurfaceName: string): T_EP_Surface;
var
  iZone: integer;
  aZone: T_EP_Zone;
  iSurf: integer;
  aSurf: T_EP_Surface;
  bFound: boolean;
begin
  bFound := false;
  for iZone := 0 to Zones.Count - 1 do
  begin
    aZone := T_EP_Zone(Zones[iZone]);
    for iSurf := 0 to aZone.Surfaces.Count - 1 do
    begin
      aSurf := T_EP_Surface(aZone.Surfaces[iSurf]);
      if aSurf.Name = SurfaceName then
      begin
        bFound := true;
        break;
      end;
    end;
    if bFound then break;
  end;
  if bFound then
    result := aSurf
  else
    Result := nil;
end;

function GetZone(ZoneName: string): T_EP_Zone;
var
  iZone: integer;
  aZone: T_EP_Zone;
  bFound: boolean;
begin
  bFound := false;
  for iZone := 0 to Zones.Count - 1 do
  begin
    aZone := T_EP_Zone(Zones[iZone]);
    if aZone.Name = ZoneName then
    begin
      bFound := true;
      break;
    end;
  end;
  if bFound then
    result := aZone
  else
    Result := nil;
end;

procedure GetDxCurves(DataSetKey: string; Typ: string; Name: string; FanType: string);
var
  DxCurvePreProcMacro: TPreProcMacro;
  DxCurveStringList: TStringList;
  DxCurveString: string;
begin
  if SameText(Typ, 'Clg') then
    if SameText(FanType, 'Variable') then
      DxCurvePreProcMacro := TPreProcMacro.Create('include/HPBDxTwoSpdClgCoilCurves.imf')
    else
      DxCurvePreProcMacro := TPreProcMacro.Create('include/HPBDxClgCoilCurves.imf')
  else if SameText(Typ, 'Htg') then
    DxCurvePreProcMacro := TPreProcMacro.Create('include/HPBDxHtgCoilCurves.imf');
  try
    DxCurveString := DxCurvePreProcMacro.getDefinedText(DataSetKey);
    DxCurveString := ReplaceRegExpr('#{CapFuncTempCurve}', DxCurveString, Name + '_' + Typ + 'CapFuncTempCurve', False);
    DxCurveString := ReplaceRegExpr('#{CapFuncFlowFracCurve}', DxCurveString, Name + '_' + Typ + 'CapFuncFlowFracCurve', False);
    DxCurveString := ReplaceRegExpr('#{EirFuncTempCurve}', DxCurveString, Name + '_' + Typ + 'EirFuncTempCurve', False);
    DxCurveString := ReplaceRegExpr('#{EirFuncFlowFracCurve}', DxCurveString, Name + '_' + Typ + 'EirFuncFlowFracCurve', False);
    DxCurveString := ReplaceRegExpr('#{PlrCurve}', DxCurveString, Name + '_' + Typ + 'PlrCurve', False);
    if SameText(FanType, 'Variable') then
    begin
      DxCurveString := ReplaceRegExpr('#{LowSpdCapFuncTempCurve}', DxCurveString, Name + '_' + Typ + 'LowSpdCapFuncTempCurve', False);
      DxCurveString := ReplaceRegExpr('#{LowSpdEirFuncTempCurve}', DxCurveString, Name + '_' + Typ + 'LowSpdEirFuncTempCurve', False);
    end;
    //write to IDF
    DxCurveString := ReplaceRegExpr(#$D#$A#$D#$A#$D#$A, DxCurveString, '', False); //delete blank lines
    DxCurveStringList := TStringList.Create;
    DxCurveStringList.Add(DxCurveString);
    IDF.AddStringList(DxCurveStringList);
  finally
    DxCurvePreProcMacro.Free;
  end;
end;

procedure GetHeatPumpEqnFitCoil(DataSetKey: string; Typ: string; Name: string; COP: double; FanPlacement: string);
var
  HeatPumpEqnFitPreProcMacro: TPreProcMacro;
  HeatPumpEqnFitStringList: TStringList;
  HeatPumpEqnFitString: string;
begin
  if SameText(Typ, 'Cool') then
    HeatPumpEqnFitPreProcMacro := TPreProcMacro.Create('include/HPBHeatPumpEqnFitClgCoil.imf')
  else if SameText(Typ, 'Heat') then
    HeatPumpEqnFitPreProcMacro := TPreProcMacro.Create('include/HPBHeatPumpEqnFitHtgCoil.imf');
  try
    HeatPumpEqnFitString := HeatPumpEqnFitPreProcMacro.getDefinedText(DataSetKey);
    HeatPumpEqnFitString := ReplaceRegExpr('#{Name}', HeatPumpEqnFitString, Name + ' ' + Typ + ' Coil', False);
    HeatPumpEqnFitString := ReplaceRegExpr('#{WaterInletNode}', HeatPumpEqnFitString, Name + ' ' + Typ + ' Coil Water Inlet Node', False);
    HeatPumpEqnFitString := ReplaceRegExpr('#{WaterOutletNode}', HeatPumpEqnFitString, Name + ' ' + Typ + ' Coil Water Outlet Node', False);
    if SameText(FanPlacement, 'BlowThrough') then
    begin
      if SameText(Typ, 'Cool') then
      begin
        HeatPumpEqnFitString := ReplaceRegExpr('#{AirInletNode}', HeatPumpEqnFitString, Name + ' Cool Coil Air Inlet Node', False);
        HeatPumpEqnFitString := ReplaceRegExpr('#{AirOutletNode}', HeatPumpEqnFitString, Name + ' Heat Coil Air Inlet Node', False);
      end
      else if SameText(Typ, 'Heat') then
      begin
        HeatPumpEqnFitString := ReplaceRegExpr('#{AirInletNode}', HeatPumpEqnFitString, Name + ' Heat Coil Air Inlet Node', False);
        HeatPumpEqnFitString := ReplaceRegExpr('#{AirOutletNode}', HeatPumpEqnFitString, Name + ' Sup Heat Coil Air Inlet Node', False);
      end;
    end
    else if SameText(FanPlacement, 'DrawThrough') then
    begin
      if SameText(Typ, 'Cool') then
      begin
        HeatPumpEqnFitString := ReplaceRegExpr('#{AirInletNode}', HeatPumpEqnFitString, Name + ' Mixed Air Node', False);
        HeatPumpEqnFitString := ReplaceRegExpr('#{AirOutletNode}', HeatPumpEqnFitString, Name + ' Heat Coil Air Inlet Node', False);
      end
      else if SameText(Typ, 'Heat') then
      begin
        HeatPumpEqnFitString := ReplaceRegExpr('#{AirInletNode}', HeatPumpEqnFitString, Name + ' Heat  Coil Air Inlet Node', False);
        HeatPumpEqnFitString := ReplaceRegExpr('#{AirOutletNode}', HeatPumpEqnFitString, Name + ' Fan Inlet Node', False);
      end;
    end;
    HeatPumpEqnFitString := ReplaceRegExpr('#{COP}', HeatPumpEqnFitString, FloatToStr(COP), False);
    //write to IDF
    HeatPumpEqnFitString := ReplaceRegExpr(#$D#$A#$D#$A#$D#$A, HeatPumpEqnFitString, '', False); //delete blank lines
    HeatPumpEqnFitStringList := TStringList.Create;
    HeatPumpEqnFitStringList.Add(HeatPumpEqnFitString);
    IDF.AddStringList(HeatPumpEqnFitStringList);
  finally
    HeatPumpEqnFitPreProcMacro.Free;
  end;
end;

procedure GetRefrigerantProperties(RefrigerantList: TStringList);
var
  i: integer;
  RefrigerantPreProcMacro: TPreProcMacro;
  RefrigerantStringList: TStringList;
  RefrigerantString: string;
begin
  if Assigned(RefrigerantList) then
    begin
    //add fluid properties
    for i := 0 to RefrigerantList.Count - 1 do
    begin
      IDF.AddComment('');   // intentional blank line
      IDF.AddComment('Refrigerant Properties');
      RefrigerantPreProcMacro := TPreProcMacro.Create('include/HPBRefrigerationFluidProperties.imf');
      try
        RefrigerantString := RefrigerantPreProcMacro.getDefinedText(RefrigerantList[i]);
        RefrigerantString := ReplaceRegExpr(#$D#$A#$D#$A#$D#$A, RefrigerantString, '', False);
        RefrigerantStringList := TStringList.Create;
        RefrigerantStringList.Add(RefrigerantString);
        IDF.AddStringList(RefrigerantStringList);
      finally
        RefrigerantPreProcMacro.Free;
      end;
    end;
  end;
end;

end.
