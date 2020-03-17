////////////////////////////////////////////////////////////////////////////////
//                                                                            //
// Copyright (c) 2008-2020 Alliance for Sustainable Energy.                   //
// All rights reserved.                                                       //
//                                                                            // 
////////////////////////////////////////////////////////////////////////////////

unit EnergyPlusLibGrab;

interface

uses
  SysUtils,
  Classes;

procedure ReadLibrariesIntoIDF(InFilename: string; NewFilename: string);
procedure GrabTextFromFile(IncludeFilename, libname: string; var slText: TStringList);

implementation

uses NativeXml, GlobalFuncs, Globals, EnergyPlusPPErrorMessages;

procedure GrabTextFromFile(IncludeFilename, libname: string; var slText: TStringList);
var
  includefile: textfile;
  copyinfo: Boolean;
  tempstr: string;
begin
  if not SameText(IncludeFileName, './include/') then
  begin
    if fileexists(IncludeFilename) then
    begin
      assignfile(includefile, IncludeFilename);
      try
        reset(includefile);
        copyinfo := false;
        while not eof(includefile) do
        begin
          readln(includefile, tempstr);
          if ((pos(lowercase(libname), lowercase(tempstr)) > 0) and
            (pos('!', tempstr) <> 1) and
            (pos('##def', lowercase(tempstr)) > 0)) or
            (libname = '') then copyinfo := true;

          if copyinfo then
          begin
            if (pos('##', tempstr) = 0) and
              (pos('******', tempstr) = 0) then
            begin
              slText.Add(tempstr);
            end;
            if pos('##enddef', lowercase(tempstr)) > 0 then
            begin
              copyinfo := false;
              exit;
            end;
          end; //if pos
        end; //while not
      finally
        closefile(includefile);
      end;
    end
    else
    begin
      T_EP_PPErrorMessage.AddErrorMessage(esWarning, 'Could not find macro library file ' + IncludeFilename);
    end;
  end;
end;

procedure ReadLibrariesIntoIDF(InFilename: string; NewFilename: string);
//Read an EPLUS input file and find all ##include references.  When ## is found
//the program opens the ##include file and finds the tag needed.
var
  infile, copyfile: textfile;
  IncludeFilename, IncludeString: string;
  rowcnt: integer;
  tempstr: string;
  ValidFile: boolean;
  WriteOnce, IgnoreEntry: boolean;
  XMLDoc: TNativeXml;
  ChildNode, ChildNode_2: TxmlNode;
  lNodes: TList;
  i: Integer;
  sSubText: string;
  sCatName: string;
  sMatCost: string;
  aSL: TStringList;
begin
  validfile := false;
  ignoreentry := false;
  writeonce := false;
  if NewFilename = InFilename then NewFilename := NewFilename + '~';
  if not fileexists(InFilename) then
  begin
    writeln('Cannot find ID Input File: ' + InFilename);
    exit;
  end;
  assignfile(infile, InFilename);
  reset(infile);
  assignfile(copyfile, NewFilename);
  rewrite(copyfile);
  while not eof(infile) do
  begin
    inc(rowcnt);
    readln(infile, tempstr);
    if pos('##include', lowercase(tempstr)) > 0 then
    begin
      writeonce := true;
      IgnoreEntry := false;
      IncludeString := tempstr;
      //fix tempstr to remove ##include
      IncludeFilename := copy(IncludeString, pos(' ', IncludeString) + 1,
        length(IncludeString) - pos(' ', IncludeString));
      //skip this line (add back later if needed);
      readln(infile, tempstr);
      //check to make sure file exists, if not report an error
      if not fileexists(IncludeFilename) then
      begin
        writeln('Cannot Find Include File: ' + includefilename);
        ValidFile := false;
        continue;
      end
      else
        ValidFile := True;
    end;

    //check the entries for EPMacro to handle
    if (pos('##set1', lowercase(tempstr)) <> 0) then
    begin
      if writeonce then
      begin
        writeln(copyfile, IncludeString);
        writeonce := false;
      end;
    end;

    if pos('##set1', lowercase(tempstr)) <> 0 then IgnoreEntry := true;

    //this does not look at libraries with passed variables
    if (pos('[]', tempstr) > 0) and
      (pos('!', tempstr) = 0) and
      (Validfile) and
      (not IgnoreEntry) then
    begin
      //grab library
      //GrabTextFromFile(IncludeFilename, libname);
      aSL := TStringList.create;
      try
        GrabTextFromFile(IncludeFilename, tempstr, aSL);
        for i := 0 to aSL.count - 1 do
        begin
          writeln(copyfile, aSL[i]);
        end;
      finally
        aSL.Free;
      end;
      continue;
    end;
    writeln(copyfile, tempstr);
  end; //while not
  closefile(infile);

  //also read in the XML section if applicable
  XMLDoc := TNativeXml.Create;
  try
    if FileExists(InputFileName) then
    begin
      XMLDoc.LoadFromFile(InputFileName);
      XMLDoc.XmlFormat := xfReadable;
      if Assigned(XMLDoc.Root) then
      begin
        ChildNode := XMLDoc.Root.FindNode('TextInput');
        if ChildNode <> nil then
        begin
          lNodes := TList.Create;
          try
            ChildNode.FindNodes('DirectSubstitution', lNodes);
            for i := 0 to lNodes.count - 1 do
            begin
              ChildNode_2 := TxmlNode(lNodes.Items[i]).FindNode('SubCategory');
              if ChildNode_2 <> nil then
              begin
                if ChildNode_2.HasAttribute('instance') then
                  sCatName := ChildNode_2.AttributeByName['instance'];
                if ChildNode_2.HasAttribute('CostPer') then
                  sMatCost := ChildNode_2.AttributeByName['CostPer'];

                //write out cost objects
                writeln(copyfile, '! Inserting costing information text for ' + sCatName);
                writeln(copyfile, 'ComponentCost:LineItem,');
                writeln(copyfile, '    DirectSubstitution:' + sCatName + ',');
                writeln(copyfile, '    , !Type');
                writeln(copyfile, '    GENERAL,  !Line Item Type');
                writeln(copyfile, '    *,! Item Name');
                writeln(copyfile, '    , ! Object End Use Key');
                writeln(copyfile, '    ' + sMatCost + ',! Cost per Each');
                writeln(copyfile, '    ,! Cost per Area');
                writeln(copyfile, '    ,! Cost per Unit of Output Capacity');
                writeln(copyfile, '    ,! Cost per Unit of Output Capacity per COP');
                writeln(copyfile, '    ,,,');
                writeln(copyfile, '    1.0,! Quantity ');
                writeln(copyfile, '    ,,,,,,;');
                writeln(copyfile);

                writeln(copyfile, '! Inserting direct substitution text for ' + sCatName);
              end;
              sSubText := TxmlNode(lNodes.Items[i]).FindNode('SubText').ValueAsString;

              writeln(copyfile, sSubText);
            end;
          finally
            lNodes.Free;
          end;
        end; //if ChildNode
      end; // if
    end;
  finally
    XMLDoc.Free;
  end; // try

  closefile(copyfile);
  if NewFileName[Length(NewFileName)] = '~' then
  begin
    DeleteFile(InFilename);
    RenameFile(NewFileName, InFileName);
  end;

end; //read idf

end.
