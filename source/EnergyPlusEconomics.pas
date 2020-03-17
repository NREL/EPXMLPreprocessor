////////////////////////////////////////////////////////////////////////////////
//                                                                            //
// Copyright (c) 2008-2020 Alliance for Sustainable Energy.                   //
// All rights reserved.                                                       //
//                                                                            // 
////////////////////////////////////////////////////////////////////////////////

unit EnergyPlusEconomics;

interface

uses
  EnergyPlusCore;

type
  TEconomicsType = (etConstruction, etShading, etGeneral, etLighting, etPVSimple,
    etDaylighting);
  TEconomicsCosting = (ecCostPerArea, ecCostPerEach, ecCostPerKilowatt,
    ecCostPerKilowattCOP);

  T_EP_Economics = class(TEnergyPlusGroup)
  public
    CostValue: double;
    Costing: TEconomicsCosting;
    CostType: TEconomicsType;
    RefObjName: string;
    Quantity: double;
    constructor Create; reintroduce;
    procedure ToIDF; override;
    procedure Finalize; override;
  end;

implementation

uses Globals, EnergyPlusObject, EnergyPlusSettings, SysUtils;

constructor T_EP_Economics.Create;
begin
  inherited;
end;

procedure T_EP_Economics.Finalize;
begin
  inherited;
end;

procedure T_EP_Economics.ToIDF;
var
  Obj: TEnergyPlusObject;
begin
  inherited;
  Obj := IDF.AddObject('ComponentCost:LineItem');
  Obj.AddField('Name of Cost Estimate', Name);
  Obj.AddField('Type', '', '', 'Not Used');
  if CostType = etConstruction then
  begin
    Obj.AddField('Line Item Type', 'Construction');
    Obj.AddField('Item Name', RefObjName);
  end
  else if CostType = etShading then
  begin
    Obj.AddField('Line Item Type', 'Shading:Zone:Detailed');
    Obj.AddField('Item Name', RefObjName);
  end
  else if CostType = etGeneral then
  begin
    Obj.AddField('Line Item Type', 'General');
    Obj.AddField('Item Name', RefObjName); 
  end
  else if CostType = etLighting then
  begin
    Obj.AddField('Line Item Type', 'Lights');
    Obj.AddField('Item Name', RefObjName);
  end
  else if CostType = etPVSimple then
  begin
    Obj.AddField('Line Item Type', 'Generator:Photovoltaic');
    Obj.AddField('Item Name', RefObjName);
  end
  else if CostType = etDaylighting then
  begin
    Obj.AddField('Line Item Type', 'Daylighting:Controls');
    Obj.AddField('Item Name', RefObjName);
  end;
  Obj.AddField('Object End Use Key', '', '', 'Not Used');
  if Costing = ecCostPerEach then
    Obj.AddField('Cost per Each', CostValue)
  else
    Obj.AddField('Cost per Each', '');
  if Costing = ecCostPerArea then
    Obj.AddField('Cost per Area', CostValue)
  else
    Obj.AddField('Cost per Area', '');
  if Costing = ecCostPerKilowatt then
    Obj.AddField('Cost per Unit of Output Capacity', CostValue)
  else
    Obj.AddField('Cost per Unit of Output Capacity', '');
  if Costing = ecCostPerKilowattCOP then
    Obj.AddField('Cost per Unit of Output Capacity per COP', CostValue)
  else
    Obj.AddField('Cost per Unit of Output Capacity per COP', '');
  Obj.AddField('Cost per Volume', '');
  Obj.AddField('Cost per Cubic Meter per Second', '');
  Obj.AddField('Cost per Energy per Temperature Difference', '');
  if costing = ecCostPerEach then
    Obj.AddField('Quantity', Quantity)
  else
    Obj.AddField('Quantity', '');
end;

end.
