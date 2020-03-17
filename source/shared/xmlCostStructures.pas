////////////////////////////////////////////////////////////////////////////////
//                                                                            //
// Copyright (c) 2008-2020 Alliance for Sustainable Energy.                   //
// All rights reserved.                                                       //
//                                                                            // 
////////////////////////////////////////////////////////////////////////////////

unit xmlCostStructures;

interface

type
  //These need to be objects with read/write capabilities to XML / IDF
  CostStruct = record
    MatCost: double; //also cost instance in database
    InstallCost: double;
    FixedOM: double;
    VariableOM: double;
    ExpectedLife: double;
    SalvageCost: double;
    PhysicalSpace: double;
    CostUnits: string;
    DataSource: string;
  end; //cost struct

  StringValStruct = record
    Instance: string;
    Units: string; //this isn't in the xml it is set in the default section
    StrType: Integer;
    Options: string;
    Comments: string;
    Cost: CostStruct;
  end; //str rec

  RealValStruct = record
    Instance: Double;
    Units: string;
    RealType: Integer;
    Mean: Double;
    Min: Double;
    Max: Double;
    StDev: Double;
    Distribution: string;
    Cost: CostStruct;
    Comments: string;
  end; //str rec

  RealCostStruct = record
    Value: double;
    Cost: CostStruct;
  end;

  IntegerCostStruct = record
    Value: Integer;
    Cost: CostStruct;
  end;

  BoolCostStruct = record
    Value: Boolean;
    Cost: CostStruct;
  end;

  StringCostStruct = record
    Value: string;
    Cost: CostStruct;
  end;

  IntegerValStruct = record
    Instance: integer;
    Units: string;
    IntType: Integer;
    Mode: Integer;
    Min: Integer;
    Max: Integer;
    Distribution: string;
    Cost: CostStruct;
    Comments: string;
  end; //str rec

implementation

end.
