////////////////////////////////////////////////////////////////////////////////
//                                                                            //
// Copyright (c) 2008-2020 Alliance for Sustainable Energy.                   //
// All rights reserved.                                                       //
//                                                                            // 
////////////////////////////////////////////////////////////////////////////////

program EPXMLPreproc2;

{$APPTYPE CONSOLE}
{$IFDEF MSWINDOWS}
{$R *.res} // ksb: directive required for version information
{$ENDIF}

//if you are incrementing the build number, then you will have to change,
//the linux File Version by hand (unless someone can figure out how to get it).
//The function is under the "PlatformDepFunctions" unit.

uses
  SysUtils,
  StrUtils,
  XMLproc in 'XMLproc.pas',
  Globals in 'Globals.pas',
  NativeXml in '3rdparty/nativexml/NativeXml.pas',
  EnergyPlusCore in 'EnergyPlusCore.pas',
  EnergyPlusBuilding in 'EnergyPlusBuilding.pas',
  EnergyPlusLibGrab in 'EnergyPlusLibGrab.pas',
  EnergyPlusSizing in 'EnergyPlusSizing.pas',
  EnergyPlusSettings in 'EnergyPlusSettings.pas',
  EnergyPlusSurfaces in 'EnergyPlusSurfaces.pas',
  EnergyPlusSystemComponents in 'EnergyPlusSystemComponents.pas',
  EnergyPlusSystems in 'EnergyPlusSystems.pas',
  EnergyPlusZones in 'EnergyPlusZones.pas',
  GlobalFuncs in 'GlobalFuncs.pas',
  VectorMath in 'VectorMath.pas',
  EnergyPlusConstructions in 'EnergyPlusConstructions.pas',
  EnergyPlusDaylighting in 'EnergyPlusDaylighting.pas',
  EnergyPlusEconomics in 'EnergyPlusEconomics.pas',
  EnergyPlusElectricLoadCenter in 'EnergyPlusElectricLoadCenter.pas',
  EnergyPlusEndUseComponents in 'EnergyPlusEndUseComponents.pas',
  EnergyPlusExteriorLoads in 'EnergyPlusExteriorLoads.pas',
  EnergyPlusGeometry in 'EnergyPlusGeometry.pas',
  EnergyPlusInternalGains in 'EnergyPlusInternalGains.pas',
  EnergyPlusPPErrorMessages in 'EnergyPlusPPErrorMessages.pas',
  EnergyPlusReportVariables in 'EnergyPlusReportVariables.pas',
  EnergyPlusSchedules in 'EnergyPlusSchedules.pas',
  PlatformDepFunctions in 'PlatformDepFunctions.pas',
  EnergyPlusZoneEquipmentList in 'EnergyPlusZoneEquipmentList.pas',
  EnergyPlusPerformanceCurves in 'EnergyPlusPerformanceCurves.pas',
  PreprocSettings in 'PreprocSettings.pas',
  xmlProcessing in 'shared/xmlProcessing.pas',
  xmlCostStructures in 'shared/xmlCostStructures.pas',
  PreProcMacro in 'shared/PreProcMacro.pas',
  EnergyPlusIDF in 'EnergyPlusIDF.pas',
  EnergyPlusField in 'EnergyPlusField.pas',
  EnergyPlusObject in 'EnergyPlusObject.pas',
  DataOutput in 'DataOutput.pas';

var
  Building: T_EP_Building;
  OutputFileName, InputDir, EIOFilename: string;
  Param: string;
  Mode: TIDFWriteMode;
  Format: TIDFFormat;
  Echo: boolean;
  i: integer;
  XMLDoc: TNativeXml;
  SortIDF: boolean;
begin
  {$IFDEF MSWINDOWS}
  //To a memcheck, uncomment the two lines below
  //MemCheckLogFileName := 'memcheck.log';
  //MemChk;
  {$ENDIF}

  // Initialize implicit default parameter values
  InputFileName := 'in.xml';
  OutputFileName := 'out_pp2.idf';

  Mode := cNew;
  Format := cVerbose;
  Echo := false;
  SortIDF := False;

  if lowercase(paramstr(1)) = '/version' then
  begin
    writeln(GetAppVersion);
    ExitCode := 0;
    exit;
  end
  else if lowercase(paramstr(1)) = '/lib' then
  begin
    writeln('Running Library Grabber');
    InputFileName := paramstr(2);
    if length(ParamStr(3)) > 0 then
    begin
      OutputFileName := paramstr(3);
    end
    else
      OutputFileName := InputFileName;
    ReadLibrariesIntoIDF(InputFileName, OutputFileName);
    writeln('Successfully Completed Library Grabber');
    ExitCode := 0;
    exit;
  end
  else if lowercase(paramstr(1)) = '/runsize' then
  begin
    //change idf to run only sizing
    writeln('Setting up file for sizing run');
    InputFileName := paramstr(2);
    if not fileexists(InputFileName) then
    begin
      writeln('Could not find input file');
      ExitCode := 0;
      exit;
    end;
    if length(ParamStr(3)) > 0 then
    begin
      OutputFileName := paramstr(3);
    end
    else
      OutputFileName := InputFileName;
    SetRunControl(InputFileName, OutputFileName, True, False);
    writeln('Successfully setup sizing run');
    ExitCode := 0;
    exit;
  end
  else if lowercase(paramstr(1)) = '/removesize' then
  begin
    //change idf to run only sizing
    writeln('Setting up file to remove sizing run');
    InputFileName := paramstr(2);
    if not fileexists(InputFileName) then
    begin
      writeln('Could not find input file');
      ExitCode := 0;
      exit;
    end;
    if length(ParamStr(3)) > 0 then
    begin
      OutputFileName := paramstr(3);
    end
    else
      OutputFileName := InputFileName;
    SetRunControl(InputFileName, OutputFileName, False, False);
    writeln('Successfully removed sizing run');
    ExitCode := 0;
    exit;
  end
  else if lowercase(paramstr(1)) = '/findsize' then
  begin
    //change idf to run only sizing
    writeln('Finding component sizes from run');
    InputFileName := paramstr(2);
    if not fileexists(InputFileName) then
    begin
      writeln('Could not find input file');
      ExitCode := 0;
      exit;
    end;
    if length(ParamStr(3)) > 0 then
      OutputFileName := paramstr(3)
    else
      OutputFileName := InputFileName;

    if length(ParamStr(4)) > 0 then
      EIOFilename := trim(paramstr(4))
    else
      EIOFileName := 'eplusout.eio';
    SetRunControl(InputFileName, OutputFileName, False, True);
    ReadEIOFile(EIOFileName, 'Component Sizing');
    ReplaceAutosize(InputFileName, OutputFileName);
    writeln('Successfully found component sizing');
    ExitCode := 0;
    exit;
  end
  else // Override explicit command line parameter values
    for i := 1 to ParamCount do
    begin
      Param := UpperCase(ParamStr(i));
      if (i = 1) and (LeftStr(Param, 1) <> '/') then
      begin
        InputFileName := ParamStr(1);
        InputDir := ExtractFilePath(InputFileName);
        OutputFileName := InputDir + 'out_pp2.idf';
      end
      else if (i = 2) and (LeftStr(Param, 1) <> '/') then
        OutputFileName := ParamStr(2)
      else if (Param = '/APPEND') or (Param = '/A') then
        Mode := cAppend
      else if (Param = '/SORT') or (Param = '/S') then
        SortIDF := True
      else if (Param = '/CONCISE') or (Param = '/C') then
        Format := cConcise
      else if (Param = '/ECHO') or (Param = '/E') then
        Echo := true
      else if (Param = '/HELP') or (Param = '/?') then
        WriteLn('PREPROC [input.xml] [output.idf] [/CONCISE] [/ECHO] [/?]')
          // add more lines to describe what switches do
      else
        WriteLn('Unhandled parameter input: ' + ParamStr(i));
    end;

  IDF := TEnergyPlusIDF.Create;
  IDF.WriteMode := Mode;
  IDF.Format := Format;
  {
  pos := StrPos(PChar(XMLFileName), PChar('\'));
  if pos > 0 then begin
    Directory := Copy(XMLFileName, 1, pos);
    ChDir(Directory);
  end;
  }

 { Directory := GetCurrentDir;
  WriteLn(Directory);
 }

  WriteLn('XML input file name: ' + InputFilename);
  WriteLn('IDF output file name: ' + OutputFileName);

  Building := T_EP_Building.Create;

  XMLDoc := TNativeXml.Create;
  try
    if FileExists(InputFilename) then
    begin
      XMLDoc.LoadFromFile(InputFilename);
      XMLDoc.XmlFormat := xfReadable;
      if Assigned(XMLDoc.Root) then
      begin
        try
          ProcessXML(Building, XMLDoc.Root);
          //ZoneSummary(Building, XMLDoc.Root);
        except
          on E: Exception do
            raise Exception.Create('Failed processing on XML. [' + E.Message + ']');
        end;
        // based on flags, optionally write Echo, Defaults, Schema
      end; // if
    end
    else
    begin
      WriteLn('Could not find file: ' + InputFilename);
      //exit;
    end;

  finally
    XMLDoc := XMLDoc;
    XMLDoc.Free;
  end; // try

  // The T_EP part may be able to be left off because all of the EP stuff may be confined to one file

  Writeln('Writing building to IDF object');
  try
    // write everything to IDF
    if SortIDF then IDF.SortObjects;
    Building.ToIDF;
  except
    on E: Exception do
      Writeln('Error saving building to IDF: ' + E.Message);
  end;

  try
    Writeln('Saving IDF Object to File');
    IDF.SaveToFile(OutputFilename);
  finally
    IDF.Free;
  end;

  WriteLn;

  //ReadLn;
end.
