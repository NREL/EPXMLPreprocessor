////////////////////////////////////////////////////////////////////////////////
//                                                                            //
// Copyright (c) 2008-2020 Alliance for Sustainable Energy.                   //
// All rights reserved.                                                       //
//                                                                            // 
////////////////////////////////////////////////////////////////////////////////

unit VectorMath;
{This unit does simple math on vectors.  Created 11/15/06 - Nicholas Long}

interface

uses                                                                                
  Contnrs,
  Globals;

type
  // DLM: need better vector class, this one only 3x1
  // DLM: this could be fixed array or record to reduce memory leaks
  T_EP_Vector = class(TObject)
  public
    i: double;
    j: double;
    k: double;
    constructor Create; reintroduce;
    destructor Destroy; overload; override;
  end;

  // DLM: need better matrix class, this one only 3x3
  T_EP_Matrix = class(TObject)
  public
    m11, m12, m13: double;
    m21, m22, m23: double;
    m31, m32, m33: double;
    constructor Create; reintroduce;
    destructor Destroy; overload; override;
  end;

  // transforms world coordinates to local
  T_EP_AffineTransformation = class(TObject)
  public
    Translation: T_EP_Vector;
    Rotation: T_EP_Matrix;
    constructor Create; reintroduce;
    destructor Destroy; overload; override;
    function TransformWorldToLocal(WorldVec: T_EP_Vector): T_EP_Vector;
    function TransformLocalToWorld(LocalVec: T_EP_Vector): T_EP_Vector;
  end;

  // DLM: need seperate class for 'cartesian point' and 'unit vector' types?
  // DLM: T_EP_Verts should contain list of T_EP_Vector
  T_EP_Verts = class(TObjectList)
  private
    finalized: boolean;
  public
    constructor Create; reintroduce;
    procedure AddVert(X1, Y1, Z1: double);
    procedure Reverse;
    procedure Finalize;
    function AreFinalized: boolean;
    procedure AssertFinalized;
  end;

  // DLM: what is distinction between T_EP_Vector and T_EP_Point?
  // DLM: access to internal storage of cartesian coordinates should be same for
  // DLM: vector as well as point (i.e. all 'x','y','z'), they are same concept
  // DLM: this should be extension of T_EP_Verts and renamed
  // DLM: why does a point have an angle?
  T_EP_Point = class(TObject)
  public
    X1: double;
    Y1: double;
    Z1: double;
    Angle: double;
    BiLength: double;
    BiAngle: double; //not used
    BiVec: T_EP_Vector; //the bisecting unit vector
    constructor Create; reintroduce;
    destructor Destroy; overload; override;
  end;

// DLM: almost all of these have memory leaks in normal useage
function VectorMagnitude(vecIn: T_EP_Vector): double;
function VectorAdd(vec1, vec2: T_EP_Vector): T_EP_Vector;
function VectorSubtract(vec1, vec2: T_EP_Vector): T_EP_Vector;
function VectorAngle(vec1: T_EP_Vector): double; overload;
function VectorAngle(P1, P2: T_EP_Point): double; overload;
function VectorUnit(VecIn: T_EP_Vector): T_EP_Vector;
function VectorMult(MultBy: double; VecIn: T_EP_Vector): T_EP_Vector;
function VectorBtwnPoints(P0, P1, P2: T_EP_Point; bUnitVector: boolean = true): T_EP_Vector;


// DLM: new, need review
// DLM: almost all of these have memory leaks in normal useage
function MatrixMult(MatIn: T_EP_Matrix; MultBy: double): T_EP_Matrix; overload;
function MatrixMult(MatIn: T_EP_Matrix; MultBy: T_EP_Vector): T_EP_Vector; overload;
function MatrixMult(MatIn: T_EP_Matrix; MultBy: T_EP_Matrix): T_EP_Matrix; overload;
function MatrixTranspose(MatIn: T_EP_Matrix): T_EP_Matrix;
function RotationMatrixFromEulerAngles(a1, a2, a3: double): T_EP_Matrix;
function RotationMatrixFromBases(v1, v2, v3: T_EP_Vector): T_EP_Matrix;
function RotationMatrixToSurface(Verts: T_EP_Verts): T_EP_Matrix;
function TransformVerts(Verts: T_EP_Verts; R: T_EP_Matrix; Origin: T_EP_Vector; AreaFraction: double = 1.0; OffsetAmount: double = 0.0): T_EP_Verts;
function WorldToLocalTransformation(Verts: T_EP_Verts): T_EP_AffineTransformation;

function AngleBisecBtwnPoints(P0, P1, P2: T_EP_Point): double;
function AngleBtwnPoints(P1, P2: T_EP_Vector): double;
function VertsTilt(Verts: T_EP_Verts):double ;
function FindULCIndex(Verts: T_EP_Verts):integer ;
function DistanceBtwnPoints(P1, P2: T_EP_Point): double;
function VectorCrossProduct(vec1, vec2: T_EP_Vector): T_EP_Vector;
function VectorDotProduct(vec1, vec2: T_EP_Vector): double;
function AreaPolygon(points: T_EP_Verts): double;
function VolumeContributionPolygon(points: T_EP_Verts):double;
function VertsCenterPoint(Verts: T_EP_Verts): T_EP_Vector;
function VertsSurfaceNormal(Verts: T_EP_Verts): T_EP_Vector;
function InsidePolygon(PolyPoints: T_EP_Verts; x, y: double): boolean; overload;
function InsidePolygon(PolyPoints: T_EP_Verts; XOrig1, YOrig1: double;
  TestPolyPoints: T_EP_Verts; XOrig2, YOrig2: Double): boolean; overload;



implementation

uses math, Classes, GlobalFuncs, EnergyPlusPPErrorMessages;

constructor T_EP_Vector.Create;
begin
  i := 0;
  j := 0;
  k := 0;
  inherited;
end;

destructor T_EP_Vector.Destroy;
begin
  inherited;
end;

constructor T_EP_Matrix.Create;
begin
  m11 := 0.0; m12 := 0.0; m13 := 0.0;
  m21 := 0.0; m22 := 0.0; m23 := 0.0;
  m31 := 0.0; m32 := 0.0; m33 := 0.0;
  inherited;
end;

destructor T_EP_Matrix.Destroy;
begin
  inherited;
end;

constructor T_EP_AffineTransformation.Create;
begin
   Translation := T_EP_Vector.Create;
   Rotation := T_EP_Matrix.Create;
   inherited;
end;

destructor T_EP_AffineTransformation.Destroy;
begin
  Translation.Destroy;
  Rotation.Destroy;
  inherited;
end;

constructor T_EP_Point.Create;
begin
  BiVec := T_EP_Vector.Create;
  inherited;
end;

destructor T_EP_Point.Destroy;
begin
  BiVec.Free;
  inherited;
end;

{ T_EP_Verts }

constructor T_EP_Verts.Create;
begin
  inherited;
  finalized := False;
end;

procedure T_EP_Verts.AddVert(X1, Y1, Z1: double);
var
  newVert: T_EP_Vector;
begin
  if finalized then
    T_EP_PPErrorMessage.AddErrorMessage(esSevere, 'Added vertex to finalized verts');

  newVert := T_EP_Vector.Create;
  newVert.i := x1;
  newVert.j := y1;
  newVert.k := z1;
  Add(newVert);
end;

// call after all verts are added
// find index of ULC vert and reorder so ULC is first
procedure T_EP_Verts.Finalize;
var
  iFirstVert, rotateCount: integer;
begin
  if finalized then
    T_EP_PPErrorMessage.AddErrorMessage(esSevere, 'Re-finalizing verts');

  // if there are less than 3 verts we can't order yet
  if (Count < 3) then
    T_EP_PPErrorMessage.AddErrorMessage(esSevere, 'Verts finalized with fewer than 3 vertices');

  // verts are now finalized
  finalized := True;

  // find vertex index for ULC
  iFirstVert := FindULCIndex(Self);
  if not (iFirstVert = 0)  then
  //  T_EP_PPErrorMessage.AddErrorMessage(esWarning, 'Reordered Verts for ULC convention');

  // rotate vertices for ULC convention
  for rotateCount := 0 to iFirstVert-1 do
  begin
    // remove the first item from the list without freeing it, then add it to end of list
    Add(Extract(First()));
  end;
end;


procedure T_EP_Verts.Reverse;
//Reverse the sense of the verts keeping the same starting vert
var
  insertIdx: integer;
begin
  if finalized then
    T_EP_PPErrorMessage.AddErrorMessage(esSevere, 'Reversing finalized verts');

  for insertIdx := 0 to Count-1 do
  begin
    // remove the first item from the list without freeing it, then add it to end of list
    Insert(insertIdx, Extract(Last()));
  end;
end;


function T_EP_Verts.AreFinalized;
begin
  result := finalized;
end;

procedure T_EP_Verts.AssertFinalized;
begin
  if not finalized then
    T_EP_PPErrorMessage.AddErrorMessage(esSevere, 'Verts failed assert finalized');
end;


function VectorMagnitude(vecIn: T_EP_Vector): double;
//finds the magniture of the vector
begin
  result := sqrt(Power(vecIn.i, 2) + Power(vecIn.j, 2) + Power(vecIn.k, 2));
end;

function VectorAdd(vec1, vec2: T_EP_Vector): T_EP_Vector;
//add two vectors together
var
  tmpVec: T_EP_Vector;
begin
  tmpVec := T_EP_Vector.Create;
  tmpVec.i := vec1.i + vec2.i;
  tmpVec.j := vec1.j + vec2.j;
  tmpVec.k := vec1.k + vec2.k;
  result := tmpVec;
end;

function VectorSubtract(vec1, vec2: T_EP_Vector): T_EP_Vector;
//subtract two vectors, vec1-vec2
var
  tmpVec: T_EP_Vector;
begin
  tmpVec := T_EP_Vector.Create;
  tmpVec.i := vec1.i - vec2.i;
  tmpVec.j := vec1.j - vec2.j;
  tmpVec.k := vec1.k - vec2.k;
  result := tmpVec;
end;

function VectorCrossProduct(vec1, vec2: T_EP_Vector): T_EP_Vector;
var
  vecCross: T_EP_Vector;
begin
  vecCross := T_EP_Vector.Create;
  vecCross.i := (vec1.j * vec2.k) - (vec1.k * vec2.j);
  vecCross.j := -((vec1.i * vec2.k) - (vec1.k * vec2.i));
  vecCross.k := (vec1.i * vec2.j) - (vec1.j * vec2.i);
  result := vecCross;
end; //vectorcross

function VectorDotProduct(vec1, vec2: T_EP_Vector): Double;
begin
  Result := (vec1.i * vec2.i) + (vec1.j * vec2.j) + (vec1.k * vec2.k);
end; //vec dot

function VectorAngle(vec1: T_EP_Vector): double;
//returns the lesser of the angle of the vector - only between i,j   -pi to pi
begin
  result := arcTan2(vec1.j, vec1.i);
end;

function VectorAngle(P1, P2: T_EP_Point): double;
//returns the angle of the two points.  -pi to pi
var
  vec1: T_EP_Vector;
begin
  vec1 := T_EP_Vector.Create;
  try
    vec1.i := p2.x1 - P1.X1;
    vec1.j := p2.Y1 - p1.Y1;
  finally
    result := VectorAngle(vec1);
    vec1.Free;
  end;
end; //if

function VectorUnit(VecIn: T_EP_Vector): T_EP_Vector;
//returns the unit vector
var
  mag: double;
  newVec: T_EP_Vector;
begin
  newVec := T_EP_Vector.Create;
  mag := VectorMagnitude(vecIn);
  if mag <> 0 then
  begin
    newVec.i := VecIn.i / mag;
    newVec.j := VecIn.j / mag;
    newVec.k := VecIn.k / mag;
  end;
  result := newVec;
end; //unitvect

function VectorMult(MultBy: double; VecIn: T_EP_Vector): T_EP_Vector;
//scale the vector by MultBy
var
  newVec: T_EP_Vector;
begin
  newVec := T_EP_Vector.Create;
  newVec.i := VecIn.i * MultBy;
  newVec.j := VecIn.j * MultBy;
  newVec.k := VecIn.k * MultBy;
  result := newVec;
end;

function VectorBtwnPoints(P0, P1, P2: T_EP_Point; bUnitVector: boolean = true): T_EP_Vector;
//todo: this still needs to be fixed, the vector around 0º isn't working right.
var
  vec1, vec2: T_EP_Vector;
  vecSum: T_EP_Vector;
  p0Angle, p1Angle: double;
begin
  vec1 := T_EP_Vector.Create;
  vec2 := T_EP_Vector.Create;
  vecSum := T_EP_Vector.Create;

  try
    vec1.i := P0.X1 - P1.X1;
    vec1.j := P0.Y1 - P1.Y1;

    vec2.i := P2.X1 - P1.X1;
    vec2.j := P2.Y1 - P1.Y1;

    vec1 := VectorUnit(vec1);
    vec2 := VectorUnit(vec2);

    //check if concave zone.
    p0Angle := P0.Angle;
    p1Angle := P1.Angle;

    if p1Angle = 0 then p1Angle := 2 * pi;
    if p0Angle < 0 then p0Angle := 2 * pi + p0Angle;
    if p1Angle < 0 then p1Angle := 2 * pi + p1Angle;

    if (p1Angle - p0Angle < 0) then
    begin
      //negate the vectors
      vec1 := VectorMult(-1, vec1);
      vec2 := VectorMult(-1, vec2);
    end;

    //add the unit vectors together
    vecSum := VectorAdd(vec1, vec2);
    if bUnitVector then vecSum := VectorUnit(vecSum);

  finally
    result := vecSum;
    vec1.Free;
    vec2.Free;
  end;
end;

function MatrixMult(MatIn: T_EP_Matrix; MultBy: double): T_EP_Matrix;
//scale the matrix by MultBy, MatIn*MultBy
begin
  Result := T_EP_Matrix.Create;
  Result.m11 := MatIn.m11 * MultBy;
  Result.m12 := MatIn.m11 * MultBy;
  Result.m13 := MatIn.m11 * MultBy;
  Result.m21 := MatIn.m11 * MultBy;
  Result.m22 := MatIn.m11 * MultBy;
  Result.m23 := MatIn.m11 * MultBy;
  Result.m31 := MatIn.m11 * MultBy;
  Result.m32 := MatIn.m11 * MultBy;
  Result.m33 := MatIn.m11 * MultBy;
end;

function MatrixMult(MatIn: T_EP_Matrix; MultBy: T_EP_Vector): T_EP_Vector;
// multiply the vector times a matrix, MatIn*MultBy
begin
  Result := T_EP_Vector.Create;
  Result.i := MatIn.m11*MultBy.i + MatIn.m12*MultBy.j + MatIn.m13*MultBy.k;
  Result.j := MatIn.m21*MultBy.i + MatIn.m22*MultBy.j + MatIn.m23*MultBy.k;
  Result.k := MatIn.m31*MultBy.i + MatIn.m32*MultBy.j + MatIn.m33*MultBy.k;
end;

function MatrixMult(MatIn: T_EP_Matrix; MultBy: T_EP_Matrix): T_EP_Matrix;
// multiply the matrix times a matrix, MatIn*MultBy
begin
  Result := T_EP_Matrix.Create;
  Result.m11 := MatIn.m11*MultBy.m11 + MatIn.m12*MultBy.m21 + MatIn.m13*MultBy.m31;
  Result.m12 := MatIn.m11*MultBy.m12 + MatIn.m12*MultBy.m22 + MatIn.m13*MultBy.m32;
  Result.m13 := MatIn.m11*MultBy.m13 + MatIn.m12*MultBy.m23 + MatIn.m13*MultBy.m33;
  Result.m21 := MatIn.m21*MultBy.m11 + MatIn.m22*MultBy.m21 + MatIn.m23*MultBy.m31;
  Result.m22 := MatIn.m21*MultBy.m12 + MatIn.m22*MultBy.m22 + MatIn.m23*MultBy.m32;
  Result.m23 := MatIn.m21*MultBy.m13 + MatIn.m22*MultBy.m23 + MatIn.m23*MultBy.m33;
  Result.m31 := MatIn.m31*MultBy.m11 + MatIn.m32*MultBy.m21 + MatIn.m33*MultBy.m31;
  Result.m32 := MatIn.m31*MultBy.m12 + MatIn.m32*MultBy.m22 + MatIn.m33*MultBy.m32;
  Result.m33 := MatIn.m31*MultBy.m13 + MatIn.m32*MultBy.m23 + MatIn.m33*MultBy.m33;
end;


function MatrixTranspose(MatIn: T_EP_Matrix): T_EP_Matrix;
// transpose a matrix, don't worry about complex conjugate these are doubles
begin
  Result := T_EP_Matrix.Create;
  Result.m11 := MatIn.m11; Result.m12 := MatIn.m21; Result.m13 := MatIn.m31;
  Result.m21 := MatIn.m12; Result.m22 := MatIn.m22; Result.m23 := MatIn.m32;
  Result.m31 := MatIn.m13; Result.m32 := MatIn.m23; Result.m33 := MatIn.m33;
end;

function RotationMatrixFromEulerAngles(a1, a2, a3: double): T_EP_Matrix;
// DLM: This is a weird convention but it fits with definition of East as 90 degrees
// rotate a1 radians about negative z-axis (North = 0, East = 90, South = 180, West = 270)
// rotate a2 radians about rotated x-axis
// rotate a3 radians about rotated negative z-axis
var
  c1, s1, c2, s2, c3, s3: double;
begin
  c1 := cos(a1); s1 := sin(a1);
  c2 := cos(a2); s2 := sin(a2);
  c3 := cos(a3); s3 := sin(a3);

  Result := T_EP_Matrix.Create;
  Result.m11 := c1*c3-c2*s1*s3;
  Result.m12 := c3*s1+c1*c2*s3;
  Result.m13 := s2*s3;
  Result.m21 := -c2*c3*s1-c1*s3;
  Result.m22 := c1*c2*c3-s1*s3;
  Result.m23 := c3*s2;
  Result.m31 := s1*s2;
  Result.m32 := -c1*s2;
  Result.m33 := c2;
end;

function RotationMatrixFromBases(v1, v2, v3: T_EP_Vector): T_EP_Matrix;
// create a rotation matrix from three input unit vectors that form a right-hand coordinate system
// if v1,v2,v3 define a coordinate system in x,y,z then resulting matrix will rotate you from x,y,z into v1,v2,v3
begin
  // assert( unitvec(v1, v2, v3))
  // assert dot(v1,v2)=0, dot(v1,v3)=0, dot(v2,v3)=0

  Result := T_EP_Matrix.Create;
  Result.m11 := v1.i; Result.m12 := v2.i; Result.m13 := v3.i;
  Result.m21 := v1.j; Result.m22 := v2.j; Result.m23 := v3.j;
  Result.m31 := v1.k; Result.m32 := v2.k; Result.m33 := v3.k;
end;

function RotationMatrixToSurface(Verts: T_EP_Verts): T_EP_Matrix;
// returns a rotation matrix which rotates from world coordinates to surface with z as outward normal
var
  X, Y, Z, thisX, thisY, thisZ: T_EP_Vector;
begin
  Verts.AssertFinalized();
  X := T_EP_Vector.Create;  X.i := 1.0;
  Y := T_EP_Vector.Create;  Y.j := 1.0;
  Z := T_EP_Vector.Create;  Z.k := 1.0;

  thisZ :=  VertsSurfaceNormal(Verts);
  thisX := VectorSubtract(X, VectorMult(VectorDotProduct(X, thisZ), thisZ));
  thisY := VectorSubtract(Y, VectorMult(VectorDotProduct(Y, thisZ), thisZ));
  if (VectorMagnitude(thisX) > VectorMagnitude(thisY)) then
  begin
    thisX := VectorUnit(thisX);
    thisY := VectorCrossProduct(thisZ, thisX);
  end
  else
  begin
    thisY := VectorUnit(thisY);
    thisX := VectorCrossProduct(thisY, thisZ);
  end;

  Result := RotationMatrixFromBases(thisX, thisY, thisZ);
end;

function TransformVerts(Verts: T_EP_Verts; R: T_EP_Matrix; Origin: T_EP_Vector; AreaFraction: double = 1.0; OffsetAmount: double = 0.0): T_EP_Verts;
// Transform a set of vertices by 1) scaling by AreaFraction, 2) Rotation about Origin by R matrix,
// 3) Translate so all vertices are more than offsetAmount outside surface

var
  surfNormal, thisVector, tempVector: T_EP_Vector;
  dotDiff, maxDotDiff, xTrans, yTrans, zTrans, sqrtAreaFraction: double;
  iVert: integer;
begin
  Verts.AssertFinalized();
  maxDotDiff := -1E308;
  Result := T_EP_Verts.Create;
  surfNormal := VertsSurfaceNormal(Verts);
  sqrtAreaFraction := sqrt(AreaFraction);

  for iVert := 0 to Verts.Count - 1 do //copy these vertices
  begin
    thisVector := T_EP_Vector(Verts[iVert]);
    // subtract origin and scale
    tempVector := VectorSubtract(thisVector, Origin);
    tempVector := VectorMult(sqrtAreaFraction, tempVector);
    // rotate and add origin
    tempVector := MatrixMult(R, tempVector);
    tempVector := VectorAdd(tempVector, Origin);
    // add in temporary vertex
    Result.AddVert(tempVector.i, tempVector.j, tempVector.k);
    // compute distance to surface along surface normal
    dotDiff := VectorDotProduct(VectorSubtract(thisVector, tempVector), surfNormal);
    if (dotDiff > maxDotDiff) then
    begin
        maxDotDiff := dotDiff;
    end;
  end;
  Result.Finalize();

  // translate all points so they are at least OffsetAmount outside of the surface
  tempVector := VectorMult(maxDotDiff+OffsetAmount, surfNormal);
  for iVert := 0 to Result.Count - 1 do //copy these vertices
  begin
     with T_EP_Vector(Result[iVert]) do
     begin
      i := i + tempVector.i ;
      j := j + tempVector.j;
      k := k + tempVector.k;
     end;
  end;
end;


function WorldToLocalTransformation(Verts: T_EP_Verts): T_EP_AffineTransformation;
// local = Rotation*world + Translation
// world = Rotation^-1*(local-Translation)
var
  WorldTranslation: T_EP_Vector;
begin
  WorldTranslation := VertsCenterPoint(Verts);

  // TODO: DLM, use principle axes to define coordinate system
  Result := T_EP_AffineTransformation.Create;
  Result.Rotation := RotationMatrixToSurface(Verts);
  Result.Translation := MatrixMult(Result.Rotation, WorldTranslation);

  WorldTranslation.Destroy;
end;


function T_EP_AffineTransformation.TransformWorldToLocal(WorldVec: T_EP_Vector): T_EP_Vector;
var
  Tmp: T_EP_Vector;
begin
  Tmp := MatrixMult(Rotation, WorldVec);
  Result := VectorAdd(tmp, Translation);
  Tmp.Destroy;
end;

function T_EP_AffineTransformation.TransformLocalToWorld(LocalVec: T_EP_Vector): T_EP_Vector;
var
  InvRot: T_EP_Matrix;
  Tmp: T_EP_Vector;
begin
  InvRot := MatrixTranspose(Rotation);
  Tmp := VectorSubtract(LocalVec, Translation);
  Result := MatrixMult(InvRot, Tmp);
  InvRot.Destroy;
  Tmp.Destroy;
end;


function AngleBisecBtwnPoints(P0, P1, P2: T_EP_Point): double;
//this takes the 3 points, makes them vectors and finds the bisecting angle between them.
//P2 is the reference point.
var
  vec1, vec2: T_EP_Vector;
  vecSum: T_EP_Vector;
  theta: double;
begin
  vec1 := T_EP_Vector.Create;
  vec2 := T_EP_Vector.Create;
  vecSum := T_EP_Vector.Create;
  try
    theta := 0;
    vec1.i := P0.X1 - P1.X1;
    vec1.j := P0.Y1 - P1.Y1;

    vec2.i := P2.X1 - P1.X1;
    vec2.j := P2.Y1 - P1.Y1;

    vec1 := VectorUnit(vec1);
    vec2 := VectorUnit(vec2);

    //check if concave zone.
    {if P2.Angle - P1.Angle < 0 then
    begin
      //negate the vectors
      vec1 := VectorMult(-1,vec1);
      vec2 := VectorMult(-1,vec2);
    end;    }

    //add the unit vectors together
    vecSum := VectorAdd(vec1, vec2);
    vecSum := VectorUnit(vecSum);

    theta := ArcTan2(vecSum.j, vecSum.i);
    //theta := theta * (360 / (2*pi));
  finally
    result := theta;
    vecSum.Free;
    vec1.free;
    vec2.free;
  end;
end;

// DLM: could project all points onto arbitrary surface defined by normal
// DLM: then use fast 2D polygon area method http://local.wasp.uwa.edu.au/~pbourke/geometry/polyarea/
function AreaPolygon(points: T_EP_Verts): double;
var
  normal: T_EP_Vector;
  pV: array of T_EP_Vector;
  csum, dResult: double;
  i: Integer;
begin
  points.AssertFinalized();
  normal := T_EP_Vector.Create;
  setlength(pV, points.Count);

  csum := 0;
  dResult := 0; // DLM: initialize to error code?
  try
    if points.Count >= 3 then
    begin
      // get the surface normal
      normal := VertsSurfaceNormal(points);

      //generate the vectors (which are just the points)
      for i := 0 to points.Count - 1 do
      begin
        pV[i] := T_EP_Vector(points[i]);
      end;

      // loop over all vertices
      for i := 0 to length(pV) - 2 do
      begin
        csum := csum + VectorDotProduct(normal, VectorCrossProduct(pV[i], pV[i + 1]));
      end;
      csum := csum + VectorDotProduct(normal, VectorCrossProduct(pV[length(pV) - 1], pV[0]));

      // multiply by one half to get area
      dResult := 0.5*csum;
    end;
  finally
    result := dResult;
    normal.free;
  end;
end;


// DLM: very similar to areaPolygon, this does not return the volume of a polyhedron
// DLM: it returns the volume contribution of one of the surfaces (polygon) in the polyhedron
// DLM: which may be positive or negative, therefore you need to take the cumulative sum somewhere else
function VolumeContributionPolygon(points: T_EP_Verts):double;
var
  normal: T_EP_Vector;
  pV: array of T_EP_Vector;
  csum, dResult: double;
  i: Integer;
begin
  points.AssertFinalized();
  normal := T_EP_Vector.Create;
  setlength(pV, points.Count);

  csum := 0;
  dResult := 0; // DLM: initialize to error code?
  try
    if points.Count >= 3 then
    begin
      // get the surface normal
      normal := VertsSurfaceNormal(points);

      //generate the vectors (which are just the points)
      for i := 0 to points.Count - 1 do
      begin
        pV[i] := T_EP_Vector(points[i]);
      end;

      // loop over all vertices
      for i := 0 to length(pV) - 2 do
      begin
        csum := csum + VectorDotProduct(normal, pV[i])*VectorDotProduct(normal, VectorCrossProduct(pV[i], pV[i + 1]));
      end;
      csum := csum + VectorDotProduct(normal, pV[length(pV)-1])*VectorDotProduct(normal, VectorCrossProduct(pV[length(pV)-1], pV[0]));

      // divide by six to get volume contribution
      dResult := csum/6.0;
    end;
  finally
    result := dResult;
    normal.free;
  end;
end;

{function PolygonCentroid(N:integer;Points:Array of tPoint;area:double): tPoint;
var
  i,j:integer;
  C:tPoint;
  P:double;
begin
    C.X := 0;
    C.Y := 0;
    For i := 0 to N-1 do
    begin
         j:=(i + 1) mod N;
         P:= Points[i].X * Points[j].Y - Points[j].X * Points[i].Y;
         C.X := C.X + (Points[i].X + Points[j].X) * P;
         C.Y := C.Y + (Points[i].Y + Points[j].Y) * P;
    end;
    C.X := C.X / (6 * area);
    C.Y := C.Y / (6 * area);
    PolygonCentroid := C;
end;}

// Returns a vector which is the average of all verts
// DLM: this is not really the "center" although it will be a good interior point
// DLM: to define center you have to say center of verts or center of edges
function VertsCenterPoint(Verts: T_EP_Verts) : T_EP_Vector;
var
  idx: integer;
begin
  Verts.AssertFinalized();
  Result := T_EP_Vector.Create; // initialized to 0
  if Verts.Count <> 0 then
  begin
    for idx := 0 to Verts.Count - 1 do
    begin
      Result := VectorAdd(Result, T_EP_Vector(Verts[idx]));
    end;
    Result := VectorMult(1.0/Verts.Count, Result);
  end
end;

// Returns unit vector in direction of outward surface normal
function VertsSurfaceNormal(Verts: T_EP_Verts) : T_EP_Vector;
var
  vec1, vec2: T_EP_Vector;
  idx: integer;
  thisDot, minDot: double;
begin
  Result := T_EP_Vector.Create; // initialized to 0
  minDot := 2.0; // dot product will never be greater than 1

  // can only compute surface normal if more than 2 points
  if Verts.Count > 2 then
  begin
    // DLM: any memory leaks?
    vec1 := VectorUnit( VectorSubtract(T_EP_Vector(Verts[1]), T_EP_Vector(Verts[0])) );
    for idx := 2 to Verts.Count - 1 do
    begin
      // DLM: any memory leaks?
      vec2 := VectorUnit( VectorSubtract(T_EP_Vector(Verts[idx]), T_EP_Vector(Verts[1])) );
      thisDot := VectorDotProduct(vec1, vec2);
      if (thisDot < minDot) then
      begin
        // want the most orthogonal vectors for numerical accuracy, could also have check for minimum vector length
        minDot := thisDot;
        Result := VectorCrossProduct(vec1, vec2);
      end;
    end;
  end;

  // DLM: any memory leaks? yes
  Result := VectorUnit(Result);
end;

function VertsTilt(Verts: T_EP_Verts):double ;
var
  aVec : T_EP_Vector;
begin
  Verts.AssertFinalized();
  aVec := VertsSurfaceNormal(verts);
  Result := RadToDeg(ArcCos(aVec.k));
end;

function AngleBtwnPoints(P1, P2: T_EP_Vector): double;
//return the angle between 2 vectors on a plane.  The angle is
//from vector 1 to vector 2, positive counterclockwise
//the result is between -pi to pi
var
  dtheta, theta1, theta2: double;
begin
  theta1 := ArcTan2(p1.j, p1.i);
  theta2 := ArcTan2(p2.j, p2.i);
  dtheta := theta2 - theta1;
  while (dtheta > pi) do
  begin
    dtheta := dtheta - 2 * pi;
  end;

  while (dtheta < -pi) do
  begin
    dtheta := dtheta + 2 * pi;
  end;
  result := dtheta;
end;

function DistanceBtwnPoints(P1, P2: T_EP_Point): double;
//returns the distance between the two points
begin
  Result := Sqrt(Power(P2.X1 - P1.X1, 2) + Power(P2.Y1 - P1.Y1, 2) + Power(P2.Z1 - P1.Z1, 2));
end;


function FindULCIndex(Verts: T_EP_Verts): integer;
// given a set of verts find the index of the ULC vert
// ULC only defined if outward normal unit vector is more than 1 degree from +/-z
// so floors and ceilings do not have defined ulc for now, will just return 0
// (this mirrors what input/output reference says)
// DLM: Nick look here, code review
var
  normal, up, upPrime, rightPrime: T_EP_Vector;
  thisLeft, thisUp, maxLeft, maxUp: double;
  iULC, iVert: integer;
begin

  Verts.AssertFinalized();

  // initiallize ULC index to first vert
  iULC := 0;

  // compute the surface normal
  normal := VertsSurfaceNormal(Verts);

  // if we are more than 1 degree away from either +/- z, dot(a,b) = |a||b|cos(theta)
  if (abs(normal.k) < 0.9998) then
  begin
    up := T_EP_Vector.Create;
    up.k := 1;

    // create and reference temporaries
    upPrime := VectorUnit(VectorSubtract(up, VectorMult(VectorDotProduct(up, normal), normal)));
    rightPrime := VectorCrossProduct(upPrime, normal);

    // at first maxLeft and maxUp equal first vert, remember that negative right is left
    maxLeft := -VectorDotProduct(T_EP_Vector(Verts[0]), rightPrime);
    maxUp := VectorDotProduct(T_EP_Vector(Verts[0]), upPrime);

    // to see if vert is ULC, test for furthest left first, then furthest up
    for iVert := 1 to Verts.Count-1 do
    begin
      thisLeft := -VectorDotProduct(T_EP_Vector(Verts[iVert]), rightPrime);
      thisUp := VectorDotProduct(T_EP_Vector(Verts[iVert]), upPrime);
      if (thisLeft > maxLeft) then
      begin
        maxLeft := thisLeft;
        maxUp := thisUp;
        iULC := iVert;
      end
      else if ((thisLeft = maxLeft) and (thisUp > maxUp)) then
      begin
        maxLeft := thisLeft;
        maxUp := thisUp;
        iULC := iVert;
      end;
    end;

    // free temporaries
    upPrime.Free;
    rightPrime.Free;
  end;

  // free vector
  normal.Free;

  result := iULC;
end;


// DLM: why not pass in origin as a vector?
function InsidePolygon(PolyPoints: T_EP_Verts; x, y: double): boolean;
//adds the sum of the angles between the test point and each pair of points.
//if sum is 2pi then it is interior, if 0 then exterior.
//http://local.wasp.uwa.edu.au/~pbourke/geometry/insidepoly/
var
  i: integer;
  angle: double;
  p1, p2: T_EP_Vector;
  bResult: boolean;
begin
  PolyPoints.AssertFinalized();
  p1 := T_EP_Vector.Create;
  p2 := T_EP_Vector.Create;
  try
    angle := 0;
    for i := 0 to PolyPoints.Count - 2 do
    begin
      p1.i := T_EP_Vector(PolyPoints[i]).i - x;
      p1.j := T_EP_Vector(PolyPoints[i]).j - y;
      p2.i := T_EP_Vector(PolyPoints[i + 1]).i - x;
      p2.j := T_EP_Vector(PolyPoints[i + 1]).j - y;
      angle := angle + AngleBtwnPoints(p1, p2);
    end;

    if Abs(angle) < Pi then
      bResult := false
    else
      bResult := true;
  finally
    p1.free;
    p2.free;
  end;
  result := bResult;
end; //inside polygon

// DLM: why not pass in origin as a vector?
function InsidePolygon(PolyPoints: T_EP_Verts; XOrig1, YOrig1: double;
  TestPolyPoints: T_EP_Verts; XOrig2, YOrig2: Double): boolean;
//test whether any of the points in the TestPolyPoints (x and y) are in the PolyPoints (x and Y).
//returns true if it is inside polygon.
var
  i: integer;
  x1: double;
  bInside: Boolean;
  y1: double;
  epvPP: T_EP_Verts;
  iPP: Integer;
begin
  //create new poly points based on obsolute coordinates
  PolyPoints.AssertFinalized();
  epvPP := T_EP_Verts.Create;
  try
    for iPP := 0 to PolyPoints.Count - 1 do
    begin
      epvPP.AddVert(XOrig1 + T_EP_Vector(PolyPoints[iPP]).i,
        YOrig1 + T_EP_Vector(PolyPoints[iPP]).j,
        T_EP_Vector(PolyPoints[iPP]).k);
    end; //for ipp
    epvPP.Finalize();

    bInside := False;
    for i := 0 to TestPolyPoints.Count - 1 do
    begin
      x1 := XOrig2 + T_EP_Vector(TestPolyPoints[i]).i;
      y1 := YOrig2 + T_EP_Vector(TestPolyPoints[i]).j;

      if InsidePolygon(epvPP, x1, y1) then bInside := true;
      if bInside then break;
    end;
    result := bInside;

  finally
    epvPP.Free;
  end;

end; //inside polygon

end.
