// Uncomment the following directive to create a console application
// or leave commented to create a GUI application... 
// {$APPTYPE CONSOLE}

program EPXMLPreproc2Tests;

uses
  TestFramework {$IFDEF LINUX},
  QForms,
  QGUITestRunner {$ELSE},
  Forms,
  GUITestRunner {$ENDIF},
  TextTestRunner,
  GlobalFuncs in '..\GlobalFuncs.pas',
  XMLproc in '..\XMLproc.pas',
  EnergyPlusBuilding in '..\EnergyPlusBuilding.pas',
  EnergyPlusConstructions in '..\EnergyPlusConstructions.pas',
  EnergyPlusCore in '..\EnergyPlusCore.pas',
  EnergyPlusDaylighting in '..\EnergyPlusDaylighting.pas',
  EnergyPlusEconomics in '..\EnergyPlusEconomics.pas',
  EnergyPlusElectricLoadCenter in '..\EnergyPlusElectricLoadCenter.pas',
  EnergyPlusEndUseComponents in '..\EnergyPlusEndUseComponents.pas',
  EnergyPlusExteriorLoads in '..\EnergyPlusExteriorLoads.pas',
  EnergyPlusGeometry in '..\EnergyPlusGeometry.pas',
  EnergyPlusInternalGains in '..\EnergyPlusInternalGains.pas',
  EnergyPlusLibGrab in '..\EnergyPlusLibGrab.pas',
  EnergyPlusPerformanceCurves in '..\EnergyPlusPerformanceCurves.pas',
  EnergyPlusPPErrorMessages in '..\EnergyPlusPPErrorMessages.pas',
  EnergyPlusReportVariables in '..\EnergyPlusReportVariables.pas',
  EnergyPlusSchedules in '..\EnergyPlusSchedules.pas',
  EnergyPlusSettings in '..\EnergyPlusSettings.pas',
  EnergyPlusSizing in '..\EnergyPlusSizing.pas',
  EnergyPlusSurfaces in '..\EnergyPlusSurfaces.pas',
  EnergyPlusSystemComponents in '..\EnergyPlusSystemComponents.pas',
  EnergyPlusSystems in '..\EnergyPlusSystems.pas',
  EnergyPlusZoneEquipmentList in '..\EnergyPlusZoneEquipmentList.pas',
  EnergyPlusZones in '..\EnergyPlusZones.pas',
  Globals in '..\Globals.pas',
  MemCheck in '..\MemCheck.pas',
  PlatformDepFunctions in '..\PlatformDepFunctions.pas',
  PreprocSettings in '..\PreprocSettings.pas',
  VectorMath in '..\VectorMath.pas',
  xmlCostStructures in '..\shared\xmlCostStructures.pas',
  XMLProcessing in '..\shared\XMLProcessing.pas',
  NativeXml in '..\shared\NativeXml.pas',
  PreProcMacro in '..\shared\PreProcMacro.pas',
  RegExpr in '..\string\regexpr\RegExpr.pas',
  StringFileUtilities in '..\string\stringfileutilities\StringFileUtilities.pas',
  StringFileUtilitiesTests in '..\string\stringfileutilities\dunit\StringFileUtilitiesTests.pas',
  EnergyPlusField in '..\EnergyPlusField.pas',
  EnergyPlusIDF in '..\EnergyPlusIDF.pas',
  EnergyPlusObject in '..\EnergyPlusObject.pas',
  EnergyPlusFieldTests in 'EnergyPlusFieldTests.pas',
  VectorMathTests in 'VectorMathTests.pas';

{$R *.RES}

begin
  Application.Initialize;

{$IFDEF LINUX}
  QGUITestRunner.RunRegisteredTests;
{$ELSE}
  if System.IsConsole then
    TextTestRunner.RunRegisteredTests
  else
    GUITestRunner.RunRegisteredTests;
{$ENDIF}

end.

