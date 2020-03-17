////////////////////////////////////////////////////////////////////////////////
//                                                                            //
// Copyright (c) 2008-2020 Alliance for Sustainable Energy.                   //
// All rights reserved.                                                       //
//                                                                            // 
////////////////////////////////////////////////////////////////////////////////

unit EnergyPlusSizing;

//------------------------------------------------------------------------------
//
//                     This unit is from LibCostGrab
//                     Nicholas Long
//                     4-18-2004
//
//  This unit simply goes through the EIO file and finds all the
//  Component sizing entries and replaces the 'autosize' varaibles
//  in the IDF file.  There are no calculations that are performes
//  on the values.
//
//  Structures Used:
//       Similar Structures to the EP_IDD, EP_Data structure.
//------------------------------------------------------------------------------

interface

uses
  SysUtils,
  Classes;

procedure SetRunControl(InputFile: string; OutputFile: string; RunSizing: boolean; HardSized:boolean);
procedure ReadEIOFile(EIOFilename, ObjectName: string);
procedure AddEIODefVar(objectstr, objectname: string);
procedure AddSizeVar(objectstr, objectname: string);
procedure ReplaceAutosize(IDFFilename, NewIDFFilename: string);

type
  FieldStruct = record
    Name: string;
    Descript: string;
    Value: string;
  end;

  SizingArrStruct = record
    ObjectName: string;
    RawData: string;
    Field: array of FieldStruct;
  end;

  SizingDefStruct = record
    ObjectName: string;
    RawData: string;
    Field: array of FieldStruct;
  end; //sizingdef struct

var
  SizingArr: array of SizingArrStruct;
  SizingDef: SizingDefStruct; //this is the current object being loaded

implementation

procedure SetRunControl(InputFile: string; OutputFile: string; RunSizing: boolean; HardSized:boolean);
var
  infile: textfile;
  tempfile: textfile;
  tempfilename: string;
  tempstr: string;
begin
  if OutputFile = InputFile then
    tempfilename := OutputFile + '~'
  else
    tempfilename := OutputFile;

  assignfile(infile, inputfile);
  assignfile(tempfile, tempfilename);
  try
    reset(infile);
    rewrite(tempfile);
    while not eof(infile) do
    begin
      readln(infile, tempstr);
      if Pos('SimulationControl,', tempstr) > 0 then
      begin
        while (pos(';', tempstr) = 0) and (not eof(infile)) do
        begin
          readln(infile, tempstr);
        end;
        if RunSizing then
        begin
          writeln(tempfile, 'SimulationControl,');
          writeln(tempfile, '  Yes,  !- Do Zone Sizing Calculation');
          writeln(tempfile, '  Yes,  !- Do System Sizing Calculation');
          writeln(tempfile, '  Yes,  !- Do Plant Sizing Calculation');
          writeln(tempfile, '  Yes,  !- Run Simulation for Sizing Periods');
          writeln(tempfile, '  No;   !- Run Simulation for Weather File Run Periods');
        end
        else if HardSized then
        begin
          writeln(tempfile, 'SimulationControl,');
          writeln(tempfile, '  No,   !- Do Zone Sizing Calculation');
          writeln(tempfile, '  No,   !- Do System Sizing Calculation');
          writeln(tempfile, '  No,   !- Do Plant Sizing Calculation');
          writeln(tempfile, '  No,   !- Run Simulation for Sizing Periods');
          writeln(tempfile, '  Yes;  !- Run Simulation for Weather File Run Periods');
        end
        else
        begin
          writeln(tempfile, 'SimulationControl,');
          writeln(tempfile, '  Yes,  !- Do Zone Sizing Calculation');
          writeln(tempfile, '  Yes,  !- Do System Sizing Calculation');
          writeln(tempfile, '  Yes,  !- Do Plant Sizing Calculation');
          writeln(tempfile, '  No,   !- Run Simulation for Sizing Periods');
          writeln(tempfile, '  Yes;  !- Run Simulation for Weather File Run Periods');
        end;
        continue;
      end; //run control
      writeln(tempfile, tempstr);
    end; //while not
  finally
    closefile(infile);
    closefile(tempfile);
  end;

  if InputFile = OutputFile then
  begin
    DeleteFile(inputfile);
    RenameFile(tempfilename, inputfile);
  end;
end; //SetRunControl

procedure AddEIODefVar(objectstr, objectname: string);
var
  colcnt: word;
  i, k: integer;
  entry: string;
begin
  SizingDef.ObjectName := objectname;
  SizingDef.RawData := objectstr;

  //fill SizingDef with values from EIO
  colcnt := 0;
  k := 1;
  for i := 0 to length(ObjectStr) do
  begin
    if ((ObjectStr[i] = ',') or (ObjectStr[i] = ';')) then
    begin
      inc(colcnt);
      entry := trim(copy(ObjectStr, k, i - k));
      k := i + 1;
      setlength(SizingDef.Field, length(SizingDef.Field) + 1);
      if colcnt = 1 then
        SizingDef.Field[length(SizingDef.Field) - 1].Descript := objectname
      else
        SizingDef.Field[length(SizingDef.Field) - 1].Descript := entry;
    end; //if
  end; //for
end; //addeiovar

procedure AddSizeVar(objectstr, objectname: string);
var
  colcnt: word;
  i, k: integer;
  entry: string;
begin
  setlength(SizingArr, length(SizingArr) + 1);
  with SizingArr[length(SizingArr) - 1] do
  begin
    ObjectName := SizingDef.ObjectName;
    setlength(Field, length(SizingDef.Field));
    for i := 0 to length(SizingDef.Field) - 1 do
    begin
      Field[i] := SizingDef.Field[i];
    end; //for
    RawData := objectstr;
  end; //with EP_IDF

  //load values in from EIO
  colcnt := 0;
  k := 1;
  for i := 0 to length(ObjectStr) do
  begin
    if ((ObjectStr[i] = ',') or (ObjectStr[i] = ';')) then
    begin
      inc(colcnt);
      entry := trim(copy(ObjectStr, k, i - k));
      k := i + 1;
      //showmessage('Writing to index ' + inttostr(length(EP_IDF)-1));
      if colcnt = 1 then
        SizingArr[Length(sizingArr) - 1].Field[colcnt - 1].Value := objectname
      else
        SizingArr[Length(sizingArr) - 1].Field[colcnt - 1].Value := entry;
    end; //if
  end; //for
end; //addeiovar

procedure ReadEIOFile(EIOFilename, ObjectName: string);
var
  EIOFile: textfile;
  tempstr: string;
  i, j: word;
  val1, val2, val3, val4, val5: string;
  aField: FieldStruct;
begin
  setlength(SizingArr, 0); //reset array size

  assignfile(EIOFile, EIOFilename);
  reset(EIOFile);
  while not eof(EIOFile) do
  begin
    readln(EIOFile, tempstr);
    tempstr := trim(tempstr + ',');
    //there are no operation needed to clean the lines..
    if pos(lowercase(objectname), lowercase(tempstr)) <> 0 then
    begin
      if (pos('<', tempstr) <> 0) and (pos('>', tempstr) <> 0) then
      begin
        AddEIODefVar(tempstr, objectname);
      end
      else
      begin
        AddSizeVar(tempstr, objectname);
      end; //if pos <
    end; //if objectname
  end; //whilenot
  closefile(EIOFile);

  if length(SizingArr) <> 0 then
  begin
    //swap the CONTROLLER:OUTSIDE AIR max/min values because of the EIO file -
    //has to be in order of the autosizing fields within the IDF file.
    //find the values
    for i := 0 to length(SizingArr) - 1 do
      with SizingArr[i] do
      begin
        if lowercase(Field[1].Value) = 'controller:outdoorair' then
        begin
          if pos('maximum', lowercase(field[3].value)) <> 0 then
          begin
            val1 := field[4].value;
            field[4].Value := sizingArr[i + 1].Field[4].Value;
            sizingArr[i + 1].Field[4].Value := val1;
          end;
        end;
      end; //for

    //coil:water:cooling
    for i := 0 to length(SizingArr) - 1 do
      with SizingArr[i] do
      begin
        if lowercase(Field[1].Value) = 'coil:cooling:water' then
        begin
          if pos('max water', lowercase(field[3].value)) <> 0 then
          begin
            //max water flow rate
            //max air flow rate
            val1 := sizingarr[i + 2].field[4].value; //air inlet temp
            val2 := sizingarr[i + 3].field[4].value; //air outlet temp
            val3 := sizingarr[i + 4].field[4].value; //water inlet temp
            //air inlet hum ratio
            //air outlet hum ratio

            //Design Water Flow Rate of Coil
            //Design Air Volume Flow Rate
            sizingarr[i + 2].field[4].value := val3; //Design Inlet Water Temperature
            sizingarr[i + 3].field[4].value := val1; //Design Inlet Air Temperature
            sizingarr[i + 4].field[4].value := val2; //Design Outlet Air Temperature
            //Design Inlet Air Humidity Ratio
            //Design Outlet Air Humidity Ratio
          end;
        end;
      end; //for

    //coil:water:simpleheating
    for i := 0 to length(SizingArr) - 1 do
      with SizingArr[i] do
      begin
        if lowercase(Field[1].Value) = 'coil:heating:water' then
        begin
          if pos('max water', lowercase(field[3].value)) <> 0 then
          begin
            val1 := field[4].value;
            field[4].Value := sizingArr[i + 1].Field[4].Value;
            sizingArr[i + 1].Field[4].Value := val1;
          end;
        end;
      end; //for

    //condenser loop
    for i := 0 to length(SizingArr) - 1 do
      with SizingArr[i] do
      begin
        if lowercase(Field[1].Value) = 'condenserloop' then
        begin
          if pos('volume of', lowercase(field[3].value)) <> 0 then
          begin
            val1 := field[4].value; //volume of the condenser loop
            val2 := sizingArr[i + 1].Field[4].Value; //maximum loop volumetric flow rate
            field[4].value := val2; //max loop volumetric flow rate
            sizingArr[i + 1].Field[4].Value := val1; //volume of the condesner loop
          end;
        end;
      end; //for

    //cooling tower:single speed
    for i := 0 to length(SizingArr) - 1 do
      with SizingArr[i] do
      begin
        if lowercase(Field[1].Value) = 'coolingtower:singlespeed' then
        begin
          if pos('autosized design water', lowercase(field[3].value)) <> 0 then
          begin
            //design water flow rate
            val1 := sizingArr[i + 1].Field[4].Value; //Fan power at design air flow rate
            val2 := sizingArr[i + 2].Field[4].Value; //deisgn air flow rate
            //tower UA value at design air flow rate
            //air flow rate in free convection
            //tower UA value in free convection regime

            //desing water flow rate
            sizingArr[i + 1].Field[4].Value := val2; //design air flow rate
            sizingArr[i + 2].Field[4].Value := val1; //fan power at design air flow rate
            //tower UA value at design air flow rate
            //air flow rate in free convection
            //tower UA value at free convection

          end;
        end;
      end; //for

    //swap Coil:DX:CoolingByPassFactorEmpirical
    //find the values
    for i := 0 to length(SizingArr) - 1 do
      with SizingArr[i] do
      begin
        if lowercase(Field[1].Value) = 'coil:cooling:dx:singlespeed' then
        begin
          if pos('rated air volume', lowercase(field[3].value)) <> 0 then
          begin
            val3 := sizingArr[i + 2].field[4].value;
            sizingArr[i + 2].field[4].value := field[4].Value;
            field[4].value := sizingArr[i + 1].field[4].value;
            sizingArr[i + 1].Field[4].value := val3;
          end; //rated
        end;
      end; //for

    //swap Coil:DX:Multispeed:CoolingEmpirical
    //find the values and swap them around
    for i := 0 to length(SizingArr) - 1 do
      with SizingArr[i] do
      begin
        if lowercase(Field[1].Value) = 'coil:cooling:dx:twospeed' then
        begin
          if pos('rated air volume flow rate [m', lowercase(field[3].value)) <> 0 then
          begin
            val1 := sizingArr[i + 1].field[4].value;
            val2 := sizingArr[i + 2].field[4].value;
            val3 := field[4].value;
            val4 := sizingArr[i + 4].field[4].value;
            val5 := sizingArr[i + 3].field[4].value;

            field[4].value := val1;
            sizingArr[i + 1].Field[4].value := val2;
            sizingArr[i + 2].field[4].value := val3;
            sizingArr[i + 3].field[4].value := val4;
            sizingArr[i + 4].field[4].value := val5;
          end;
        end;
      end; //for

    //swap baseboard heater:water:convective
    //find the values
    for i := 0 to length(SizingArr) - 1 do
      with SizingArr[i] do
      begin
        if lowercase(Field[1].Value) = 'zonehvac:baseboard:convective:water' then
        begin
          if pos('max water flow rate', lowercase(field[3].value)) <> 0 then
          begin
            val1 := sizingArr[i + 1].field[4].value;
            val2 := field[4].value;

            field[4].value := val1;
            sizingArr[i + 1].Field[4].value := val2;

          end;
        end;
      end; //for

    //swap Coil:DX:HeatingEmpirical
    //find the values
    for i := 0 to length(SizingArr) - 1 do
      with SizingArr[i] do
      begin
        if lowercase(Field[1].Value) = 'coil:heating:dx:singlespeed' then
        begin
          if pos('rated air volume', lowercase(field[3].value)) <> 0 then
          begin
            val1 := sizingArr[i + 1].field[4].value;
            val2 := field[4].value;
            val3 := sizingArr[i + 2].field[4].value;

            field[4].value := val1;
            sizingArr[i + 1].Field[4].value := val2;
            sizingArr[i + 2].field[4].value := val3;

          end;
        end;
      end; //for

    //setup UnitarySystem:HeatPump:AirToAir
    for i := 0 to length(SizingArr)-1 do with SizingArr[i] do begin
      if lowercase(Field[1].Value) = 'airloophvac:unitaryheatpump:airtoair' then begin
        if pos('design air flow rate',lowercase(field[3].value))<>0 then begin
          val1 :=   sizingArr[i+1].field[4].value ;
          val2 :=   sizingArr[i+2].field[4].value ;
          val3 :=   sizingArr[i+3].field[4].value ;
          val4 :=   sizingArr[i+6].field[4].value ;
          SizingArr[i].field[4].value := val1 ;
          sizingArr[i+1].field[4].value := val2 ;
          sizingArr[i+2].field[4].value := val3 ;
          sizingArr[i+3].field[4].value := val4 ;
          sizingArr[i+4].field[4].value := val4 ;
        end;
      end;
    end; //for

    //swap fan coil unit:4 pipe
    //find the values
    for i := 0 to length(SizingArr) - 1 do
      with SizingArr[i] do
      begin
        if lowercase(Field[1].Value) = 'zonehvac:fourpipefancoil' then
        begin
          if pos('Maximum Supply Air Flow Rate', lowercase(field[3].value)) <> 0 then
          begin
            val1 := field[4].value;
            val2 := sizingArr[i + 1].field[4].value;
            val3 := sizingArr[i + 3].field[4].value;
            val4 := sizingArr[i + 2].field[4].value;

            field[4].value := val1;
            sizingArr[i + 1].Field[4].value := val2;
            sizingArr[i + 2].field[4].value := val3;
            sizingArr[i + 3].field[4].value := val4;
          end;
        end;
      end; //for

    //swap Unit Ventilator
    //find the values
    for i := 0 to length(SizingArr) - 1 do
      with SizingArr[i] do
      begin
        if lowercase(Field[1].Value) = 'zonehvac:unitventilator' then
        begin
          if pos('Maximum Supply Air Flow Rate', lowercase(field[3].value)) <> 0 then
          begin
            val1 :=                  field[4].value;
            val2 := sizingArr[i + 2].field[4].value;
            val3 := sizingArr[i + 1].field[4].value;

                             field[4].value := val1;
            sizingArr[i + 1].Field[4].value := val2;
            sizingArr[i + 2].field[4].value := val3;

          end;
        end;
      end; //for
  end; //if sizing > 0

end; //ReadEIOFile

procedure ReplaceAutosize(IDFFilename, NewIDFFilename: string);
//this replaces all the Autosize fields, it reads each object in and
//decides if there is an autosize parameter...
var
  outfile, infile: textfile;
  tempstr, writestr: string;
  ObjectName: string;
  Indentifier: string;
  ObjLineCnt: integer;
  i: integer;
  ObjAutosizeCnt: word;
  tempFilename: string;
begin
  if IDFFilename = NewIDFFilename then
    tempFilename := NewIDFFilename + '~'
  else
    tempFilename := NewIDFFilename;

  assignfile(infile, IDFFilename);
  assignfile(outfile, tempFilename);
  try
    rewrite(outfile);
    reset(infile);
    while not eof(infile) do
    begin
      readln(infile, tempstr);
      if (pos('!', trim(tempstr)) = 1) or (tempstr = '') then
      begin
        writeln(outfile, tempstr);
        continue;
      end;

      //remove thef following objects from the input file
      if (pos('sizing:system', lowercase(tempstr)) <> 0) or
        (pos('sizing:zone', lowercase(tempstr)) <> 0) or
        (pos('sizing:plant', lowercase(tempstr)) <> 0) then
      begin
        while (pos(';', tempstr) = 0) and (not eof(infile)) do
        begin
          readln(infile, tempstr);
        end;
        continue;
      end; //run control

      if pos(',', tempstr) <> 0 then
      begin
        writeln(outfile, tempstr);
        //read object name
        ObjectName := trim(copy(tempstr, 1, pos(',', tempstr) - 1));
        ObjLineCnt := 0;
        ObjAutosizeCnt := 0;
        while (not eof(infile)) and (pos(';', tempstr) = 0) do
        begin
          readln(infile, tempstr);
          if (pos('!', trim(tempstr)) = 1) or (tempstr = '') then continue;
          inc(objLineCnt);
          if ObjLineCnt = 1 then Indentifier := trim(copy(tempstr, 1, pos(',', tempstr) - 1)); //the next line should contain the component name

          if (pos('autosize', lowercase(tempstr)) <> 0) and
            (lowercase(ObjectName) <> 'sizing:system') then
          begin
            inc(ObjAutosizeCnt);
            //writeln(outfile,Objectname,',',indentifier,',',trim(tempstr));
            for i := 0 to length(SizingArr) - 1 do
            begin
              if (lowercase(ObjectName) = lowercase(SizingArr[i].Field[1].value)) and
                (lowercase(Indentifier) = lowercase(SizingArr[i].Field[2].value)) then
              begin
                writestr := copy(tempstr, 1, pos('autosize', lowercase(tempstr)) - 1) +
                  SizingArr[i + ObjAutosizeCnt - 1].Field[4].value +
                  copy(tempstr, pos('autosize', lowercase(tempstr)) + 8, length(tempstr));
                writeln(outfile, writestr);
                break;
              end; //if
            end; //for i
          end
          else
          begin
            writeln(outfile, tempstr); //if pos('autosize'
          end;
        end; //while
      end; //if pos(','
    end; //while not eof
  finally
    closefile(outfile);
    closefile(infile);
  end;

  if IDFFilename = NewIDFFilename then
  begin
    DeleteFile(IDFFilename);
    RenameFile(tempFilename, IDFFilename);
  end;
end; //replace autosize

end.
