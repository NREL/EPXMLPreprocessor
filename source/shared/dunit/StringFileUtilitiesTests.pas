////////////////////////////////////////////////////////////////////////////////
//                                                                            //
// Copyright (c) 2008-2020 Alliance for Sustainable Energy.                   //
// All rights reserved.                                                       //
//                                                                            // 
////////////////////////////////////////////////////////////////////////////////

unit StringFileUtilitiesTests;

interface

uses
  StringFileUtilities,
  TestFrameWork,
  classes;

type
  TStringFileUtilitiesTests = class(TTestCase)
  private

  protected

//    procedure SetUp; override;
//    procedure TearDown; override;

  published
    procedure TestMakeLinesFromString;
    procedure TestGetColumn;
    procedure TestGetColumns;
    procedure TestRemoveAllSpaces;
    procedure TestCleanStringFilename;
    procedure TestCleanString;
  end;

implementation

procedure TStringFileUtilitiesTests.TestRemoveAllSpaces;
var
  sTest: string;
begin
  sTest := 'This Is A Test  String  ';
  sTest := RemoveAllSpaces(sTest);
  CheckEquals('ThisIsATestString', sTest);
end;

procedure TStringFileUtilitiesTests.TestGetColumn;
var
  sTest: string;
  sResult: string;
begin
  sTest := 'AB,"C",DEF,EFGHI';
  sResult := GetColumn(sTest, 2, ',');
  CheckEquals('C', sResult);
  sResult := GetColumn(sTest, 3, ',');
  CheckEquals('DEF', sResult);
end;

procedure TStringFileUtilitiesTests.TestGetColumns;
var
  aSL: TStringList;
  sTest: string;
begin
  sTest := 'AB,"C",DEF,EFGHI';
  GetColumns(sTest, ',', aSL);
  CheckEquals('C', aSL[1]);
  CheckEquals('DEF', aSL[2]);
  Check(aSL.Count = 4, 'Incorrect number of columns');
end;

procedure TStringFileUtilitiesTests.TestMakeLinesFromString;
var
  sTest: string;
  slLines: TStringList;
begin
          //         10        20        30        40        50        60        70
          //1234567890123456789012345678901234567890123456789012345678901234567890123456789
  sTest := 'This is a test string to make sure that it breaks at the right character number.';
  slLines := MakeLinesFromString(sTest);
  Check(slLines.Count = 2, 'Broke into incorrect number of lines');
  CheckEquals('This is a test string to make sure that it breaks at the', slLines[0]);
  CheckEquals('right character number.', slLines[1]);

            //         10        20        30        40        50        60        70
          //1234567890123456789012345678901234567890123456789012345678901234567890123456789
  sTest := 'The rain in Spain falls mainly in the plain';
  slLines := MakeLinesFromString(sTest);
  Check(slLines.Count = 1, 'Broke into incorrect number of lines');
  CheckEquals('The rain in Spain falls mainly in the plain', slLines[0]);
end;

procedure TStringFileUtilitiesTests.TestCleanStringFilename;
var
  sTest: string;
  sResult: string;
begin
  sTest := ' \/:*?"<>|,%!;';
  sResult := CleanStringFilename(sTest);
  CheckEquals(' ', sResult);
  sResult := CleanStringFilename(sTest, True);
  CheckEquals('', sResult);
end;

procedure TStringFileUtilitiesTests.TestCleanString;
var
  sResult: string;
  sTest: string;
begin
  sTest := 'Replace ABC with XYZ and remove    spaces  ';
  sResult := CleanString(sTest, 'ABC', 'XYZ', False);
  CheckEquals('Replace XYZ with XYZ and remove    spaces  ', sResult);
  sResult := CleanString(sTest, 'ABC', 'XYZ', True);
  CheckEquals('Replace XYZ with XYZ and remove spaces ', sResult);
end;

initialization

  TestFramework.RegisterTest('StringFileUtilitiesTests Suite',
    TStringFileUtilitiesTests.Suite);

end.
 