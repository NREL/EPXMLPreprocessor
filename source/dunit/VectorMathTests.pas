unit VectorMathTests;

interface

uses
  VectorMath,
  TestFrameWork,
  SysUtils;

type
  T_EP_VectorGlobalTests = class(TTestCase)
  private

  protected

  published
    procedure TestPolygonArea;
  end;

  T_EP_VectorTests = class(TTestCase)
  private

  protected

//    procedure SetUp; override;
//    procedure TearDown; override;

  published

    // Test methods
    procedure TestCreate;
    procedure TestDestroy;

  end;

type
  T_EP_MatrixTests = class(TTestCase)
  private

  protected

//    procedure SetUp; override;
//    procedure TearDown; override;

  published

    // Test methods
    procedure TestCreate;
    procedure TestDestroy;

  end;

type
  T_EP_AffineTransformationTests = class(TTestCase)
  private

  protected

//    procedure SetUp; override;
//    procedure TearDown; override;

  published

    // Test methods
    procedure TestCreate;
    procedure TestDestroy;
    procedure TestTransformWorldToLocal;
    procedure TestTransformLocalToWorld;

  end;

type
  T_EP_VertsTests = class(TTestCase)
  private

  protected

//    procedure SetUp; override;
//    procedure TearDown; override;

  published

    // Test methods
    procedure TestCreate;
    procedure TestAddVert;
    procedure TestReverse;
    procedure TestFinalize;
    procedure TestAreFinalized;
    procedure TestAssertFinalized;

  end;

type
  T_EP_PointTests = class(TTestCase)
  private

  protected

//    procedure SetUp; override;
//    procedure TearDown; override;

  published

    // Test methods
    procedure TestCreate;
    procedure TestDestroy;

  end;

implementation

{ T_EP_PointTests }

procedure T_EP_PointTests.TestCreate;
begin

end;

procedure T_EP_PointTests.TestDestroy;
begin

end;

{ T_EP_VertsTests }

procedure T_EP_VertsTests.TestAddVert;
begin

end;

procedure T_EP_VertsTests.TestAreFinalized;
begin

end;

procedure T_EP_VertsTests.TestAssertFinalized;
begin

end;

procedure T_EP_VertsTests.TestCreate;
begin

end;

procedure T_EP_VertsTests.TestFinalize;
begin

end;

procedure T_EP_VertsTests.TestReverse;
begin

end;

{ T_EP_VectorTests }

procedure T_EP_VectorTests.TestCreate;
begin

end;

procedure T_EP_VectorTests.TestDestroy;
begin

end;

{ T_EP_MatrixTests }

procedure T_EP_MatrixTests.TestCreate;
begin

end;

procedure T_EP_MatrixTests.TestDestroy;
begin

end;

{ T_EP_AffineTransformationTests }

procedure T_EP_AffineTransformationTests.TestCreate;
begin

end;

procedure T_EP_AffineTransformationTests.TestDestroy;
begin

end;

procedure T_EP_AffineTransformationTests.TestTransformLocalToWorld;
begin

end;

procedure T_EP_AffineTransformationTests.TestTransformWorldToLocal;
begin

end;



//testing the global routines


{ T_EP_VectorGlobalTests }

procedure T_EP_VectorGlobalTests.TestPolygonArea;
var
  aVec: T_EP_Vector;
  vertices: T_EP_Verts;
  dTest: double;
begin
  //create a simple rectange and check area
  vertices := T_EP_Verts.Create;
  try
    vertices.AddVert(0, 0, 0);
    vertices.AddVert(0, 10, 0);
    vertices.AddVert(10, 10, 0);
    vertices.AddVert(10, 0, 0);
    vertices.Finalize;
    
    dTest := AreaPolygon(vertices);
    CheckEquals(100, dTest);
  finally
    vertices.Free;
  end;

  vertices := T_EP_Verts.Create;
  try
    vertices.AddVert(25,  0,  0);
    vertices.AddVert(25, -5,  0);
    vertices.AddVert(30, -5,  0);
    vertices.AddVert(30,  0,  0);
    vertices.AddVert(50,  0,  0);
    vertices.AddVert(50, 30,  0);
    vertices.AddVert(0,  30,  0);
    vertices.AddVert(0,   0,  0);
    vertices.Finalize;

    dTest := AreaPolygon(vertices);
    CheckEquals(1525, dTest);
  finally
    vertices.Free;
  end;

  vertices := T_EP_Verts.Create;
  try
    vertices.AddVert(25.135,     0,  6.096);
    vertices.AddVert(25.135,    -3,  6.096);
    vertices.AddVert(29.135,    -3,  6.096);
    vertices.AddVert(29.135,     0,  6.096);
    vertices.AddVert(54.27,      0,  6.096);
    vertices.AddVert(54.27,  29.27,  6.096);
    vertices.AddVert(0,      29.27,  6.096);
    vertices.AddVert(0,          0,  6.096);
    vertices.Finalize;

    dTest := AreaPolygon(vertices);
    CheckEquals('1600.4829', Format('%.4f', [dTest]));
  finally
    vertices.Free;
  end;

  vertices := T_EP_Verts.Create;
  try
    vertices.AddVert(0,          0,  6.096);
    vertices.AddVert(25.135,     0,  6.096);
    vertices.AddVert(25.135,    -3,  6.096);
    vertices.AddVert(29.135,    -3,  6.096);
    vertices.AddVert(29.135,     0,  6.096);
    vertices.AddVert(54.27,      0,  6.096);
    vertices.AddVert(54.27,  29.27,  6.096);
    vertices.AddVert(0,      29.27,  6.096);
    vertices.Finalize;

    dTest := AreaPolygon(vertices);
    CheckEquals('1600.4829', Format('%.4f', [dTest]));
  finally
    vertices.Free;
  end;
end;

initialization

  TestFramework.RegisterTest('VectorMathTests Suite',
    T_EP_VectorGlobalTests.Suite);
  TestFramework.RegisterTest('VectorMathTests Suite',
    T_EP_VectorTests.Suite);
  TestFramework.RegisterTest('VectorMathTests Suite',
    T_EP_MatrixTests.Suite);
  TestFramework.RegisterTest('VectorMathTests Suite',
    T_EP_AffineTransformationTests.Suite);
  TestFramework.RegisterTest('VectorMathTests Suite',
    T_EP_VertsTests.Suite);
  TestFramework.RegisterTest('VectorMathTests Suite',
    T_EP_PointTests.Suite);

end.
