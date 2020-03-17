////////////////////////////////////////////////////////////////////////////////
//                                                                            //
// Copyright (c) 2008-2020 Alliance for Sustainable Energy.                   //
// All rights reserved.                                                       //
//                                                                            // 
////////////////////////////////////////////////////////////////////////////////

unit StringFileUtilities;

interface

uses
  {$IFDEF MSWINDOWS}
  Windows,
  Zlib,
  ShellAPI,
  {$ENDIF}
  SysUtils,
  Classes
  ;

function GetColumn(AString: string; Column: byte; ADelim: Char): string;
function UnixPathToDosPath(const Path : string) : string;
procedure GetColumns(AString: String; ADelim: Char; var AStringList: TStringList);
function CleanStringFilename(InStr: string; RemoveAllSpaces: boolean = false): string;
function CleanString(InStr, Replace, ReplaceWith: string;
  RemoveMultSpaces: boolean = false): string;
function RemoveAllSpaces(InStr: string): string;
function MakeLinesFromString(AString: string): TStringList;

//function below here still need tests
function ReplaceColumn(InStr: string; column: byte; newstring: string): string;
procedure ReplaceStringsInFile(infilename: string; ReplaceStr: string; WithStr: string);
function PrevDir(Directory: string): string;
function ExtractLastDirByDepth(Directory: string; Depth: byte): string;
function ExtractFilePathByDepth(Directory: string; Depth: byte): string;
function GetDirectoryDepth(Directory: string): byte;
function FindTextInStrings(ToFind: string; strlist: Tstrings): boolean;
function AllowedAddress(sAddress:string; sFilename:string):boolean ;
procedure ConvertHtmlBodyToTextBody(htmlBody:TStrings; var newBody: TStringList);

{$IFDEF MSWINDOWS}
procedure keybd_sendstring(str: string);
procedure keybd_event_repeat(bVk: byte; count: byte);
procedure InsertTextInFile(InFileName: string; InText: TStringList; LineNum: word);
function GetTextFileDate(PathnName: string): TDateTime;
function GetFileSize(Filename: string): integer;
function IsFileInUse(fName: string): boolean;
function CopyDir(const fromDir, toDir: string): Boolean;
function IntegerStringListSortByNames(List: TStringList; Index1, Index2: Integer): Integer;
function IntegerStringListSortByNamesAndValues(List: TStringList; Index1, Index2: Integer): Integer;
{$ENDIF}



implementation

function UnixPathToDosPath(const Path : string) : string;

      var
         i : integer;

      begin
         Result:=Path;
         for i:=1 to Length(Result) do
           if Result[i]='/' then
             Result[i]:='\';
      end;


function PrevDir(Directory: string): string;
//this function takes a directory and returns the path of the previous directoryu.
//There are no stops in the directory to prevent returning nothing, for example
//if the user passes "C:\" the program will return "C:\".
var
  tempstr: string;
  i: integer;
begin
  tempstr := extractfiledir(directory);
  for i := Length(tempstr) - 1 downto 0 do
  begin //start on 2 because don't want last \
    if (tempstr[i] = '\') or (tempstr[i] = '/') then
    begin
      tempstr := copy(tempstr, 1, i);
      break;
    end; //if directory
  end;
  result := tempstr;
end; //prevDir

function ExtractLastDirByDepth(Directory: string; Depth: byte): string;
//this function takes a directory and returns the last directory name.
//There are no stops in the directory to prevent returning nothing, for example
//if the user passes "C:\" the program will return "C:\".
//Another example if user passes "C:\junk\whatever\foo.txt, 1", then
//this function will return "whatever"
var
  sTemp, DirName: string;
  i: integer;
begin
  //convert to dos path

  sTemp := ExtractFilePath(Directory);        //includes trailing slash
  DirName := '';
  if Depth > 0 then
  begin
    i := 0;
    while i < Depth do
    begin
      sTemp := ExcludeTrailingPathDelimiter(sTemp);
      dirName := ExtractFileName(sTemp);
      sTemp := ExtractFileDir(sTemp);
      sTemp := IncludeTrailingPathDelimiter(sTemp);
      inc(i);

      //break out of the while look if we have gone all the way back to the
      //root directory
      if GetDirectoryDepth(sTemp) < 1 then
        break;
    end;
  end;
  result := DirName;
end; //prevDir

function ExtractFilePathByDepth(Directory: string; Depth: byte): string;
//this function takes a directory and returns the path of the previous directoryu.
//There are no stops in the directory to prevent returning nothing, for example
//if the user passes "C:\, 4" the program will return a null string ''.
var
  sTemp : string;
  i : integer;
begin
  i := 0;
  sTemp := ExtractFilePath(Directory);    //includes trailing slash
  if Depth > 0 then
  begin
    while i < Depth do
    begin
      sTemp := ExcludeTrailingPathDelimiter(sTemp);
      sTemp := ExtractFileDir(sTemp);  
      sTemp := IncludeTrailingPathDelimiter(sTemp);
      inc(i);

      //break out of the while look if we have gone all the way back to the
      //root directory
      if GetDirectoryDepth(sTemp) < 1 then
        break;
    end;
  end;
  result := sTemp;
end; //prevDir

function GetDirectoryDepth(Directory: string): byte;
//returns how many directory are in the string.
var
  depth: integer;
  i: byte;
  tempstr: string;
begin
  tempstr := UnixPathToDosPath(directory);
  Directory := ExcludeTrailingPathDelimiter(tempstr);
  if Length(Directory) > 3 then directory := directory + '\'; //avoid root dir
  depth := 0;
  for i := 0 to Length(Directory) - 1 do
  begin
    if pos('\', Directory) <> 0 then
    begin
      inc(depth);
      Directory := copy(Directory, pos('\', Directory) + 1, Length(Directory));
      continue;
    end; //pos
  end; //for
  result := depth;
end; //get directory Depth

procedure ReplaceStringsInFile(infilename: string; ReplaceStr: string;
  WithStr: string);
//this function takes a filename and replaces all the strings that are replacestr
//with withstr.  It creates a new file, copies all the lines over with the
//replaced strings, then deletes the old file and renames the new file to the
//original name.
var
  infile, Outfile: textfile;
  tempstr: string;
  isp: integer;
begin
  assignfile(infile, infilename);
  reset(infile);
  assignfile(Outfile, infilename + '~');
  rewrite(outfile);
  while not eof(infile) do
  begin
    readln(infile, tempstr);
    while (pos(ReplaceStr, tempstr) > 0) do
    begin
      isp := pos(ReplaceStr, tempstr);
      tempstr := copy(tempstr, 1, isp - 1) + withstr +
        copy(tempstr, isp + Length(ReplaceStr), Length(tempstr) - isp);
    end;
    Writeln(outfile, tempstr);
  end; //while
  CloseFile(infile);
  CloseFile(outfile);
  deletefile(infilename);
  renamefile(infilename + '~', infilename);
end; //ReplaceStringsInFile

function CleanString(InStr, Replace, ReplaceWith: string;
  RemoveMultSpaces: boolean = false): string;
//this function takes the InStr and replaces any strings listed in replace with ReplaceWith
var
  isp: integer;
begin
  result := InStr;
  if RemoveMultSpaces then
  begin
    while pos('  ', result) > 0 do
    begin
      isp := pos('  ', result);
      result := copy(result, 1, isp - 1) + copy(result, isp + 1, Length(result) - isp);
    end;
  end; //if remove mult space

  if Replace <> ReplaceWith then
    result := StringReplace(result, Replace, ReplaceWith, [rfReplaceAll]);
end; //CleanString

function CleanStringFilename(InStr: string; RemoveAllSpaces: boolean = false): string;
//this function takes the InStr and removes any characters that make file names illegal
begin
  // illegal file characters:   \ / : * ? " < > |
  // also remove other characters:  , % ;
  result := InStr;
  if RemoveAllSpaces then
  begin
    result := StringReplace(result, ' ', '', [rfReplaceAll]);
  end; //if remove space

  result := StringReplace(result, '\', '', [rfReplaceAll]);
  result := StringReplace(result, '/', '', [rfReplaceAll]);
  result := StringReplace(result, ':', '', [rfReplaceAll]);
  result := StringReplace(result, '*', '', [rfReplaceAll]);
  result := StringReplace(result, '?', '', [rfReplaceAll]);
  result := StringReplace(result, '"', '', [rfReplaceAll]);
  result := StringReplace(result, '<', '', [rfReplaceAll]);
  result := StringReplace(result, '>', '', [rfReplaceAll]);
  result := StringReplace(result, '|', '', [rfReplaceAll]);

  result := StringReplace(result, ',', '', [rfReplaceAll]); //this isn't a violation
  result := StringReplace(result, '%', '', [rfReplaceAll]); //this isn't a violation
  result := StringReplace(result, '!', '', [rfReplaceAll]); //this isn't a violation
  result := StringReplace(result, ';', '', [rfReplaceAll]); //this isn't a violation
end; //CleanString

//-------------Random Functions----------------------------------------------

function ReplaceColumn(InStr: string; column: byte; newstring: string): string;
var
  colcnt: byte;
  i, k: integer;
  newresult: string;
  leftstr, rightstr: string;
begin
  colcnt := 0;
  k := 1;
  for i := 1 to length(InStr) do
  begin
    if (InStr[i] = ',') or (InStr[i] = ';') then
    begin
      inc(colcnt);
      if column = colcnt then
      begin
        leftstr := trim(copy(InStr, 1, k - 1));
        rightstr := trim(copy(InStr, i, length(InStr) - i + 1));
        newresult := leftstr + newstring + rightstr;
        break;
      end; //case
      k := i + 1;
    end; //if
  end; //for
  result := newresult;
end; //replace column

function GetColumn(AString: string; Column: byte; ADelim: Char): string;
//this function gets the string of the column listed in the arguments
//If the delim is surrounded by quotes then the program ignores the delim
//within the quotes.
var
  colcnt: byte;
  k: integer;
  aSL: TStringList;
begin
  colcnt := 0;
  k := 1;

  AString := trim(AString);
  if AString[length(AString)] <> ';' then
    AString := AString + ';';

  result := '';
  aSL := TStringList.Create;
  try
    GetColumns(AString, ADelim, aSL);

    //get the value out of this result
    if column <= aSL.Count then
    begin
      Result := aSL[column - 1];
    end;
  finally
    aSL.Free;
  end;
end; //get column

procedure GetColumns(AString:String; ADelim: Char; var AStringList: TStringList);
//this function gets the string of the column listed in the arguments
//If the delim is surrounded by quotes then the program ignores the delim
//within the quotes.
var
  i, k: integer;
  entry: string;
  quote: boolean;
begin
  if not Assigned(AStringList) then
    AStringList := TStringList.Create;

  aStringList.Clear;
  k := 1;

  AString := trim(AString);
  AString := AString + ';';

  quote := false;
  for i := 1 to Length(AString) do
  begin
    if AString[i] = '"' then quote := not quote;
    if ((AString[i] = ADelim) or (AString[i] = ';')) and not quote then
    begin
      entry := trim(copy(AString, k, i - k));
      entry := CleanString(entry, '"', '', false);
      k := i + 1;
      aStringList.Add(entry);
    end; //if
  end; //for
end; //get column

function FindTextInStrings(ToFind: string; strlist: Tstrings): boolean;
//searches the stringlist (all in LowerCase) to find the ToFind varialbe.
var
  i: integer;
begin
  for i := 0 to strlist.count - 1 do
  begin
    if pos(LowerCase(ToFind), LowerCase(strlist.strings[i])) > 0 then
    begin
      result := true;
      exit;
    end;
  end;
  result := false;
end; //findtext in strings

function RemoveAllSpaces(InStr: string): string;
//this function takes the tempstr and removes all spaces
begin
  Result := StringReplace(InStr, ' ', '', [rfReplaceAll]);
end;

function MakeLinesFromString(AString: string): TStringList;
//This function takes a string and makes a paragraph with line lengths of strlen.
//the result is a string with #13#10 for each new line.
var
  sTemp: string;
begin
  Result := TStringList.Create;
  //don't break on . because it can be in line
  sTemp := WrapText(AString, #13#10, [' ', #9], 60);

  while Pos(#13#10, sTemp) <> 0 do
  begin
    Result.Add(Trim(Copy(sTemp, 1, pos(#13#10, sTemp))));
    sTemp := Trim(Copy(sTemp,
                       pos(#13#10, sTemp) + 2,
                       length(sTemp) - pos(#13#10, sTemp) + 2));
  end;
  if sTemp <> '' then
    Result.Add(sTemp);
end;


function GetFileSize(Filename: string): integer;
//returns in bytes
var
  SearchRec: TSearchRec;
begin
  result := 0;
  if FindFirst(Filename, 0, SearchRec) = 0 then
    result := SearchRec.Size;
  FindClose(SearchRec);
end;

function AllowedAddress(sAddress:string; sFilename:string):boolean ;
var
  aSL: TStringList;
begin
  aSL := TStringList.Create;
  result := false;
  try
    aSL.LoadFromFile(sFilename);
    if aSL.IndexOf(sAddress) >= 0 then
      result := true;
  finally
    aSL.Free;
  end;
end;

procedure ConvertHtmlBodyToTextBody(htmlBody:TStrings; var newBody: TStringList);
var
  tempStr: string;
  i: Integer;
  newStr: string;
  PrevPos: Integer;
  htmlTag: Boolean;
  line: Boolean;
begin
  newBody.Clear;

  tempStr := StringReplace(htmlBody.Text, #10, '', [rfReplaceAll]);
  tempStr := StringReplace(tempStr, #13, '', [rfReplaceAll]);
  tempStr := StringReplace(tempStr, '<BR>', #10, [rfReplaceAll]);
  tempStr := trim(StringReplace(tempStr, '<br>', #10, [rfReplaceAll]));

  newStr := '';
  //go through the temp string and remove any items that are in '<' and '>'
  htmlTag := False;
  for i := 1 to length(tempstr) do
  begin
    if (tempstr[i] = '<') and (not htmlTag) then
      htmlTag := true
    else if (tempstr[i] = '<') and (htmlTag) then
      assert(False, 'Should not have reached a < in a non html tag')
    else if (tempstr[i] = '>') and (not htmlTag) then
      assert(False, 'Should not have reached a > in a non html tag')
    else if (tempstr[i] = '>') and (htmlTag) then
    begin
      htmlTag := false;
      continue;
    end;

    if htmlTag then
    begin
      continue;
    end
    else if not htmlTag then
    begin
      newStr := newStr + tempstr[i];
    end;
  end;

  //replace some of the known escapes
  newStr := StringReplace(newStr, '&amp;', '&', [rfReplaceAll]);
  newStr := StringReplace(newStr, '&lt;', '<', [rfReplaceAll]);
  newStr := StringReplace(newStr, '&gt;', '>', [rfReplaceAll]);
  newStr := StringReplace(newStr, '&apos;', '''', [rfReplaceAll]);
  newStr := StringReplace(newStr, '&quot;', '"', [rfReplaceAll]);
  newStr := StringReplace(newStr, '&nbsp;', #10, [rfReplaceAll]);

  line := False;
  tempStr := '';
  for i := 1 to length(newStr) do
  begin
    if newStr[i] = #10 then
    begin
      line := true;
      tempStr := '';
    end;

    if not line then
      tempStr := tempStr + newStr[i]
    else if line then
    begin
      newBody.Add(tempStr);
      line := false;
    end;
  end;

  newBody.Text := newStr;
end;

{$IFDEF MSWINDOWS}
function IntegerStringListSortByNames(List: TStringList; Index1, Index2: Integer): Integer;
//reference from where you got it?
var
  d1, d2: Integer;
  r1, r2: Boolean;

  function IsInt(AString : string; var AInteger : Integer): Boolean;
  var
    Code: Integer;
  begin
    Val(AString, AInteger, Code);
    Result := (Code = 0);
  end;
begin
  r1 :=  IsInt(List.Names[Index1], d1);
  r2 :=  IsInt(List.Names[Index2], d2);
  Result := ord(r1 or r2);
  if Result <> 0 then
  begin
    if d1 < d2 then
      Result := -1
    else if d1 > d2 then
      Result := 1
    else
     Result := 0;
  end else
   Result := lstrcmp(PChar(List.Names[Index1]), PChar(List.Names[Index2]));
end;

function IntegerStringListSortByNamesAndValues(List: TStringList; Index1, Index2: Integer): Integer;
//reference from where you got it?
var
  d1, d2: Integer;
  v1, v2: Integer;
  r1, r2, r3, r4: Boolean;

  function IsInt(AString : string; var AInteger : Integer): Boolean;
  var
    Code: Integer;
  begin
    Val(AString, AInteger, Code);
    Result := (Code = 0);
  end;
begin
  r1 :=  IsInt(List.Names[Index1], d1);
  r2 :=  IsInt(List.Names[Index2], d2);
  r3 :=  IsInt(List.ValueFromIndex[Index1], v1);
  r4 :=  IsInt(List.ValueFromIndex[Index2], v2);
  Result := ord(r1 or r2 or r3 or r4);
  if Result <> 0 then
  begin
    if d1 < d2 then
      Result := -1
    else if d1 > d2 then
      Result := 1
    else
    begin
      if v1 < v2 then
        Result := -1
      else if v1 > v2 then
        Result := 1
      else
        Result := 0;
    end;
  end else
   Result := lstrcmp(PChar(List.Names[Index1]), PChar(List.Names[Index2]));
end;

procedure InsertTextInFile(InFileName: string; InText: TStringList; LineNum: word);
//this routine inserts text (intext) into the infilename file at after line number.
var
  rowcnt: integer;
  infile: textfile;
  outfile: textfile;
  tempfilename: string;
  i: word;
  tempstr: string;
begin
  i := 1;
  repeat
    tempfilename := infilename + '~' + IntToStr(i);
    inc(i);
  until not fileexists(tempfilename);
  assignfile(outfile, tempfilename);
  rewrite(outfile);
  //copyfile(pchar(infilename),pchar(tempfilename),false);
  assignfile(infile, infilename);
  reset(infile);
  rowcnt := 0;
  while not eof(infile) do
  begin
    readln(infile, tempstr);
    Writeln(outfile, tempstr);
    inc(rowcnt);
    if rowcnt = linenum then
    begin
      for i := 0 to InText.Count - 1 do
      begin
        Writeln(outfile, intext.strings[i]);
      end;
    end;
  end; //while not
  CloseFile(infile);
  CloseFile(outfile);
  deletefile(infilename);
  MoveFile(pchar(tempfilename), pchar(infilename));
  //delete files - just in case
  i := 1;
  repeat
    tempfilename := infilename + '~' + IntToStr(i);
    inc(i);
    if fileexists(tempfilename) then
      DeleteFile(tempfilename)
    else if i > 10 then
      break;
  until i = 200;
end; //insertTextInFile

function CopyDir(const fromDir, toDir: string): Boolean;
var
  fos: TSHFileOpStruct;
begin
  ZeroMemory(@fos, SizeOf(fos));
  with fos do
  begin
    wFunc := FO_COPY;
    fFlags := FOF_FILESONLY;
    pFrom := PChar(fromDir + #0);
    pTo := PChar(toDir + #0);
  end;
  Result := (0 = ShFileOperation(fos));
end;

procedure keybd_sendstring(str: string);
//this sends a string of vitual keys.
var
  i: word;
begin
  str := UpperCase(str);
  for i := 1 to Length(str) do
  begin
    if str[i] = ':' then
    begin
      keybd_event(VK_LSHIFT, 0, 0, 0); //'shift'
      keybd_event($BA, 0, 0, 0); //':'
      keybd_event(VK_LSHIFT, 0, KEYEVENTF_KEYUP, 0); //'end shift'
    end
    else if str[i] = '\' then
    begin
      keybd_event($DC, 0, 0, 0); //'\'
    end
    else if str[i] = ' ' then
    begin
      keybd_event($20, 0, 0, 0); //' '
    end
    else if str[i] = '.' then
    begin
      keybd_event($BE, 0, 0, 0); //'.'
    end
    else if str[i] = '_' then
    begin
      keybd_event(VK_LSHIFT, 0, 0, 0); //'shift'
      keybd_event($BD, 0, 0, 0); //'_'
      keybd_event(VK_LSHIFT, 0, KEYEVENTF_KEYUP, 0); //'end shift'
    end
    else if str[i] = '-' then
    begin
      keybd_event($6D, 0, 0, 0); //'-'
    end
    else
      keybd_event(ord(str[i]), 0, 0, 0);
    sleep(25);
  end;
end; //keybdSendstr

procedure keybd_event_repeat(bVk: byte; count: byte);
//this sends a repeated key "count" times
var
  i: word;
begin
  for i := 0 to count - 1 do
  begin
    keybd_event(bVK, 0, 0, 0);
    sleep(100);
  end;
end; //keybdSendstr

function GetTextFileDate(PathnName: string): TDateTime;
var
  FileH: THandle;
  LocalFT: TFileTime;
  DosFT: DWORD;
  LastAccessedTime: TDateTime;
  FindData: TWin32FindData;
begin
  FileH := FindFirstFile(PChar(PathnName), FindData);
  if FileH <> INVALID_HANDLE_VALUE then
  begin
    Windows.FindClose(FileH);
    if (FindData.dwFileAttributes and
      FILE_ATTRIBUTE_DIRECTORY) = 0 then
    begin
      FileTimeToLocalFileTime
        (FindData.ftLastWriteTime, LocalFT);
      FileTimeToDosDateTime
        (LocalFT, LongRec(DosFT).Hi, LongRec(DosFT).Lo);
      LastAccessedTime := FileDateToDateTime(DosFT);
      Result := LastAccessedTime;
    end;
  end;
end;


function IsFileInUse(fName: string): boolean;
var
  HFileRes: HFILE;
begin
  Result := false;
  if not FileExists(fName) then exit;
  HFileRes :=
    CreateFile(pchar(fName),
    GENERIC_READ or GENERIC_WRITE,
    0, nil, OPEN_EXISTING,
    FILE_ATTRIBUTE_NORMAL,
    0);
  Result := (HFileRes = INVALID_HANDLE_VALUE);
  if not Result then
    CloseHandle(HFileRes);
end;
{$ENDIF MSWINDOWS}



end.
