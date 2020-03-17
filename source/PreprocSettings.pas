////////////////////////////////////////////////////////////////////////////////
//                                                                            //
// Copyright (c) 2008-2020 Alliance for Sustainable Energy.                   //
// All rights reserved.                                                       //
//                                                                            // 
////////////////////////////////////////////////////////////////////////////////

unit PreprocSettings;

interface

uses
  SysUtils,
  Contnrs,
  Globals,
  EnergyPlusCore;
type
  T_Preproc_Settings = class(TObject)
  protected

  public
    Constructor Create; reintroduce;
    procedure Finalize;
  end;

implementation


procedure T_Preproc_Settings.Finalize;
begin
  ;
end;

Constructor T_Preproc_Settings.Create;
begin

end;

end.
