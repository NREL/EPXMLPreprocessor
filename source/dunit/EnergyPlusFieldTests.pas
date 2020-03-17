////////////////////////////////////////////////////////////////////////////////
//                                                                            //
// Copyright (c) 2008-2009 Alliance for Sustainable Energy.                   //
// All rights reserved.                                                       //
//                                                                            // 
////////////////////////////////////////////////////////////////////////////////

unit EnergyPlusFieldTests;

interface

uses
  EnergyPlusField,
  TestFrameWork;

type
  TFieldTests = class(TTestCase)
  private
    AField : TField;

  protected

    procedure SetUp; override;
    procedure TearDown; override;

  published

    // Test methods
    procedure TestCreate;
    procedure TestToIDF;

  end;

type
  TFieldListTests = class(TTestCase)
  private

  protected

//    procedure SetUp; override;
//    procedure TearDown; override;

  published

    // Test methods
    procedure TestToIDF;
    procedure TestAdd;

  end;

implementation

{ TFieldTests }

procedure TFieldTests.SetUp;
begin
  inherited;
  AField := TField.Create('TestName', 'TestValue', 'TestUnit', 'TestComment');
end;

procedure TFieldTests.TearDown;
begin
  inherited;
  AField.Free;
end;

procedure TFieldTests.TestCreate;
begin
  CheckEquals('TestName', AField.Name);
  CheckEquals('TestValue', AField.Value);
  CheckEquals('TestUnit', AField.Units);
  CheckEquals('TestComment', AField.Comment);
end;

procedure TFieldTests.TestToIDF;
var
  sResult: string;
  toIDFResult: string;
begin
//result := trim(Value + EndOfLine)
  sResult := 'TestValue,' + #13#10;
  toIDFResult := AField.ToIDF(False, True);
  CheckEquals(sResult, toIDFResult);

  sResult := 'TestValue;';
  toIDFResult := AField.ToIDF(True, True);
  CheckEquals(sResult, toIDFResult);

  sResult := 'TestValue,  !- TestName TestUnit [TestComment]' + #13#10;
  toIDFResult := AField.ToIDF(False, False);
  CheckEquals(sResult, toIDFResult);

  sResult := 'TestValue;  !- TestName TestUnit [TestComment]';
  toIDFResult := AField.ToIDF(True, False);
  CheckEquals(sResult, toIDFResult);
end;

{ TFieldListTests }

procedure TFieldListTests.TestAdd;
begin
  //
end;

procedure TFieldListTests.TestToIDF;
begin
  //
end;

initialization

  TestFramework.RegisterTest('EnergyPlusFieldTests Suite',
    TFieldTests.Suite);
  TestFramework.RegisterTest('EnergyPlusFieldTests Suite',
    TFieldListTests.Suite);

end.
 