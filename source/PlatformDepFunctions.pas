////////////////////////////////////////////////////////////////////////////////
//                                                                            //
// Copyright (c) 2008-2020 Alliance for Sustainable Energy.                   //
// All rights reserved.                                                       //
//                                                                            // 
////////////////////////////////////////////////////////////////////////////////

unit PlatformDepFunctions;

interface

{$IFDEF MSWINDOWS}
uses
  Contnrs,
  classes,
  SysUtils,
  windows;

function GetAppVersion:string;  
{$ENDIF}

{$IFDEF LINUX}
uses
  Contnrs,
  classes,
  SysUtils;

function GetAppVersion:string;
{$ENDIF}


implementation

//Define all windows functions here
{$IFDEF MSWINDOWS}
function GetAppVersion:string;
var
  Size, Size2: Cardinal;
  Pt, Pt2: Pointer;
begin
  Size := GetFileVersionInfoSize(PChar (ParamStr (0)), Size2);
  if Size > 0 then
  begin
    GetMem (Pt, Size);
    try
      GetFileVersionInfo (PChar (ParamStr (0)), 0, Size, Pt);
      VerQueryValue (Pt, '\', Pt2, Size2);
      with TVSFixedFileInfo (Pt2^) do
      begin
        Result:= IntToStr (HiWord (dwFileVersionMS)) + '.' +
                 IntToStr (LoWord (dwFileVersionMS)) + '.' +
                 IntToStr (HiWord (dwFileVersionLS)) + '.' +
                 IntToStr (LoWord (dwFileVersionLS));
      end;
    finally
      FreeMem (Pt);
    end;
  end;
end;
{$ENDIF}

{$IFDEF LINUX}
function GetAppVersion:string;
begin
  result := '0.1.2.32';
end;
{$ENDIF}


end.
