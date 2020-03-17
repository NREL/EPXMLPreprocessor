////////////////////////////////////////////////////////////////////////////////
//                                                                            //
// Copyright (c) 2008-2020 Alliance for Sustainable Energy.                   //
// All rights reserved.                                                       //
//                                                                            // 
////////////////////////////////////////////////////////////////////////////////

unit EnergyPlusZoneEquipmentList;

interface

uses
  SysUtils,
  Globals,
  EnergyPlusCore,
  EnergyPlusSchedules,
  EnergyPlusEconomics;

type
  T_EP_Equipment = class(TEnergyPlusGroup)
  public
    FExteriorLoad: Boolean;
    ZoneName: string;
    DesignLevel: Double;
    ScheduleName: string;
    Schedule: T_EP_Schedule;
    EndUseSubcategory: string;
    Cost: T_EP_Economics;
    EquipmentType: TEquipmentType;
    fracRadiant: double;
    fracLatent: double;
    fracLost: double;
    SchFileColumn: integer;
    SchFileRowSkip: integer;
    constructor Create(ExteriorLoads: Boolean); reintroduce;
    procedure ToIDF; override;
    procedure Finalize; override;
  end;

  T_EP_EquipmentList = class(TEnergyPlusGroupList)
  protected
    function GetItem(Index: Integer): T_EP_Equipment;
    procedure SetItem(Index: Integer; AnEP_Equipment: T_EP_Equipment);
  public
    constructor Create; reintroduce;
    destructor Destroy; override;
    function AddNew(ExteriorLoad:Boolean): T_EP_Equipment;  
    function AddNewByIndex(ExteriorLoad:Boolean): Integer;
    function Add(AnEP_Equipment: T_EP_Equipment): Integer;
    function Extract(Item: T_EP_Equipment): T_EP_Equipment;
    function Remove(AnEP_Equipment: T_EP_Equipment): Integer;
    function IndexOf(AnEP_Equipment: T_EP_Equipment): Integer;
    procedure Insert(Index: Integer; AnEP_Equipment: T_EP_Equipment);
    function First: T_EP_Equipment;
    function Last: T_EP_Equipment;
    property Items[Index: Integer]: T_EP_Equipment read GetItem write SetItem; default;
    function FindFirst(AnEP_Equipment:T_EP_Equipment):T_EP_Equipment;
  end;

implementation

uses EnergyPlusZones, EnergyPlusSettings, GlobalFuncs, EnergyPlusObject;

{ T_EP_Equipment }

constructor T_EP_Equipment.Create(ExteriorLoads: Boolean);
begin
  FExteriorLoad := ExteriorLoads;
  ScheduleName := 'BLDG_EQUIP_SCH';
  SchFileColumn := -9999;
  SchFileRowSkip := -9999;
end;

procedure T_EP_Equipment.Finalize;
begin
  inherited;
end;

procedure T_EP_Equipment.ToIDF;
var
  Obj: TEnergyPlusObject;
  sObjName: string;
  dQuan: double;
  aZone: T_EP_Zone;
  sEquipType: string;
begin
  inherited;
  if not FExteriorLoad then
  begin
    if EquipmentType = etElectric then
      sEquipType := 'ElectricEquipment'
    else
      sEquipType := 'GasEquipment';
    sObjName := ZoneName + '_' + Name + '_Equip';
    Obj := IDF.AddObject(sEquipType);
    Obj.AddField('Name', sObjName);
    Obj.AddField('Zone Name', ZoneName);
    if ((SchFileColumn <> -9999) and (SchFileRowSkip <> -9999)) then
      Obj.AddField('Schedule Name', ZoneName + '_' + ScheduleName)
    else
      Obj.AddField('Schedule Name', ScheduleName);
    obj.AddField('Design Level Calculation Method', 'EquipmentLevel');
    Obj.AddField('Design Level', DesignLevel, '{W}');
    obj.AddField('Watts per Zone Floor Area', '', '{W/m2}');
    obj.AddField('Watts per Person', '', '{W/person}');
    Obj.AddField('Fraction Latent', fracLatent);
    Obj.AddField('Fraction Radiant', fracRadiant);
    Obj.AddField('Fraction Lost', fracLost);
    if SameText(sEquipType, 'GasEquipment') then
      Obj.AddField('Carbon Dioxide Generation Rate', '3.96E-8', '{m3/s-W}');
    Obj.AddField('End-Use Subcategory', EndUseSubcategory);
    //add schedule file
    if ((SchFileColumn <> -9999) or (SchFileRowSkip <> -9999)) then
    begin
      Obj := IDF.AddObject('Schedule:File');
      Obj.AddField('Name', ZoneName + '_' + ScheduleName);
      Obj.AddField('Schedule Type Limits Name', 'Fraction');
      Obj.AddField('File Name', ScheduleName + '.csv');
      Obj.AddField('Column Number', SchFileColumn);
      Obj.AddField('Rows to Skip at Top', SchFileRowSkip);
      Obj.AddField('Number of Hours of Data', '8760');
      Obj.AddField('Column Separator', 'Comma');
    end;
  end
  else //exterior loads
  begin
    if EquipmentType = etElectric then
      sEquipType := 'Electricity'
    else
      sEquipType := 'NaturalGas';
    Obj := IDF.AddObject('Exterior:FuelEquipment');
    Obj.AddField('Name', ZoneName + '_' + Name);
    Obj.AddField('Fuel Use Type', sEquipType);
    Obj.AddField('Schedule Name', ScheduleName);
    Obj.AddField('Design Level', DesignLevel);
    Obj.AddField('End-Use Subcategory', EndUseSubcategory);
  end;
  if not Assigned(Cost) then
  begin
    //put in generic cost structure for post processing
    Cost := T_EP_Economics.Create;
    Cost.Name := sEquipType + ':' + ZoneName + ':' + Name;
    Cost.RefObjName := ZoneName;
    Cost.Costing := ecCostPerEach;
    Cost.CostType := etGeneral;
    Cost.CostValue := 1;
    //apply multiplier
    aZone := GetZone(ZoneName);
    dQuan := (DesignLevel * aZone.ZoneMultiplier) / 1000;  //put value into kW
    Cost.Quantity := dQuan;
  end;
  if Assigned(Cost) and EPSettings.Costs then Cost.ToIDF;
end;

{ T_EP_EquipmentList }

function T_EP_EquipmentList.Add(AnEP_Equipment: T_EP_Equipment): Integer;
begin
  Result := inherited Add(AnEP_Equipment);
end;

function T_EP_EquipmentList.AddNew(ExteriorLoad:Boolean): T_EP_Equipment;
var
  aNewEPEquipment : T_EP_Equipment;
  index: integer;
begin
  aNewEPEquipment := T_EP_Equipment.Create(ExteriorLoad);
  //memory is set here and isn't freed until the THVACZoneEquipEquipList is freed.

  index := Add(aNewEPEquipment);
  result := Items[index];
end;

function T_EP_EquipmentList.AddNewByIndex(ExteriorLoad:Boolean): Integer;
var
  aNewEPEquipment : T_EP_Equipment;
begin
  aNewEPEquipment := T_EP_Equipment.Create(ExteriorLoad);
  //memory is set here and isn't freed until the THVACZoneEquipEquipList is freed.

  result := inherited Add(aNewEPEquipment);
end;

constructor T_EP_EquipmentList.Create;
begin
  inherited;
end;

destructor T_EP_EquipmentList.Destroy;
begin
  inherited;
end;

function T_EP_EquipmentList.Extract(Item: T_EP_Equipment): T_EP_Equipment;
begin
  Result := T_EP_Equipment(inherited Extract(Item));
end;

function T_EP_EquipmentList.FindFirst(
  AnEP_Equipment: T_EP_Equipment): T_EP_Equipment;
begin
  Result := T_EP_Equipment(inherited First);
end;

function T_EP_EquipmentList.First: T_EP_Equipment;
begin
  Result := T_EP_Equipment(inherited First);
end;

function T_EP_EquipmentList.GetItem(Index: Integer): T_EP_Equipment;
begin
  Result := T_EP_Equipment(inherited Items[Index]);
end;

function T_EP_EquipmentList.IndexOf(
  AnEP_Equipment: T_EP_Equipment): Integer;
begin
  Result := inherited IndexOf(AnEP_Equipment);
end;

procedure T_EP_EquipmentList.Insert(Index: Integer;
  AnEP_Equipment: T_EP_Equipment);
begin
  inherited Insert(Index, AnEP_Equipment);
end;

function T_EP_EquipmentList.Last: T_EP_Equipment;
begin
  Result := T_EP_Equipment(inherited Last);
end;

function T_EP_EquipmentList.Remove(
  AnEP_Equipment: T_EP_Equipment): Integer;
begin
  Result := inherited Remove(AnEP_Equipment);
end;

procedure T_EP_EquipmentList.SetItem(Index: Integer;
  AnEP_Equipment: T_EP_Equipment);
begin
  inherited Items[Index] := AnEP_Equipment;
end;

end.
