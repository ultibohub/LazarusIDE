unit TestWatches;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, fpcunit, testregistry, TestBase, FpDebugValueConvertors,
  FpDebugDebugger, TestDbgControl, TestDbgTestSuites, TestOutputLogger,
  TTestWatchUtilities, TestCommonSources, TestDbgConfig, LazDebuggerIntf,
  LazDebuggerIntfBaseTypes, LazDebuggerValueConverter, DbgIntfDebuggerBase,
  DbgIntfBaseTypes, FpDbgInfo, FpPascalParser, FpDbgCommon, FpDbgDwarfFreePascal, FpdMemoryTools,
  IdeDebuggerWatchValueIntf, Forms, IdeDebuggerBase, IdeDebuggerWatchResult,
  IdeDebuggerBackendValueConv, FpDebugStringConstants, FpDebugDebuggerUtils;

type

  { TTestWatches }

  TTestWatches = class(TDBGTestCase)
  private
    FEvalDone: Boolean;
    procedure DoEvalDone(Sender: TObject; ASuccess: Boolean;
      ResultText: String; ResultDBGType: TDBGType);
    procedure RunToPause(var ABrk: TDBGBreakPoint; ADisableBreak: Boolean = True);
  published
    procedure TestWatchesScope;
    procedure TestWatchesValue;
    procedure TestWatchesIntrinsic;
    procedure TestWatchesIntrinsic2;
    procedure TestWatchesFunctions;
    procedure TestWatchesFunctions2;
    procedure TestWatchesFunctionsWithString;
    procedure TestWatchesFunctionsWithRecord;
    procedure TestWatchesFunctionsSysVarToLStr;
    procedure TestWatchesAddressOf;
    procedure TestWatchesTypeCast;
    procedure TestWatchesExpression;
    procedure TestWatchesModify;
    procedure TestWatchesErrors;
    procedure TestClassRtti;
    procedure TestClassMangled;
  end;

implementation

var
  ControlTestWatch, ControlTestWatchScope, ControlTestWatchValue, ControlTestWatchIntrinsic, ControlTestWatchIntrinsic2,
  ControlTestWatchFunct, ControlTestWatchFunct2, ControlTestWatchFunctStr, ControlTestWatchFunctRec,
  ControlTestWatchFunctVariant, ControlTestWatchAddressOf, ControlTestWatchTypeCast, ControlTestModify,
  ControlTestExpression, ControlTestErrors, ControlTestRTTI, ControlTestMangled: Pointer;

procedure TTestWatches.RunToPause(var ABrk: TDBGBreakPoint;
  ADisableBreak: Boolean);
begin
  Debugger.RunToNextPause(dcRun);
  AssertDebuggerState(dsPause);
  if ADisableBreak then
    ABrk.Enabled := False;
end;

procedure TTestWatches.DoEvalDone(Sender: TObject; ASuccess: Boolean;
  ResultText: String; ResultDBGType: TDBGType);
begin
  if ResultDBGType <> nil then
    ResultDBGType.Free;
  FEvalDone := True;
end;

procedure TTestWatches.TestWatchesScope;

  procedure AddWatchesForClassMethods(t: TWatchExpectationList; AName: String; AStackOffs: Integer);
  var
    n: String;
    f: Integer;
    //IntGlobFlags: TWatchExpErrorHandlingFlags;
  begin
    // Test all outer, class, glopbal scopes are visible - from each stackframe

    n := AName;
    f := -AStackOffs;
    if f >= 0 then begin
      t.Add(n, 'Int_MethodMainChildNestedTwice',  30, f);
      t.Add(n, 'Int_MethodMainChildNested'     ,  40, f);
      t.Add(n, 'Int_MethodMainChild'           ,  50, f);
      t.Add(n, 'Int_MethodMainChild_Late'      ,  51, f).ExpectNotFound.NotImplemented;
      t.Add(n, 'Int_TClassMainChild'           ,  70, f);
      t.Add(n, 'Int_TClassMainChild_Prot'      ,  71, f);
      t.Add(n, 'Int_TClassMainChild_Priv'      ,  72, f);
      t.Add(n, 'Int_TClassMain'                ,  80, f);
      t.Add(n, 'Int_TClassMain_Prot'           ,  81, f);
      t.Add(n, 'Int_TClassMain_Priv'           ,  82, f);
      t.Add(n, 'Int_TClassMainBase'            , 170, f);
      t.Add(n, 'Int_TClassMainBase_Prot'       , 171, f);
      t.Add(n, 'Int_TClassMainBase_Priv'       , 172, f).ExpectNotFound.NotImplemented;
      t.Add(n, 'Int_TClassMainBaseBase'        , 270, f);
      t.Add(n, 'Int_TClassMainBaseBase_Prot'   , 271, f);
      t.Add(n, 'Int_TClassMainBaseBase_Priv'   , 272, f).ExpectNotFound.NotImplemented;
      t.Add(n, 'Int_GlobalPrg'                 , 101, f);
      t.Add(n, 'Int_GlobalUnit1'               , 201, f);
      t.Add(n, 'Int_GlobalUnit2'               , 202, f);
  //    t.Add(n, 'WatchesScopeUnit1.Int_GlobalPrg'   , 101, f).ExpectNotFound;
  //    t.Add(n, 'WatchesScopeUnit1.Int_GlobalUnit1' , 201, f);
  //    t.Add(n, 'WatchesScopeUnit2.Int_GlobalUnit1' , 201, f).ExpectNotFound;
  //    t.Add(n, 'WatchesScopeUnit2.Int_GlobalUnit2' , 202, f);

      t.Add(n, 'Self.Int_MethodMainChildNestedTwice',  30, f).ExpectNotFound;
      t.Add(n, 'Self.Int_MethodMainChildNested'     ,  40, f).ExpectNotFound;
      t.Add(n, 'Self.Int_MethodMainChild'           ,  50, f).ExpectNotFound;
      t.Add(n, 'Self.Int_MethodMainChild_Late'      ,  51, f).ExpectNotFound;
      t.Add(n, 'Self.Int_TClassMainChild'           ,  70, f);
      t.Add(n, 'Self.Int_TClassMainChild_Prot'      ,  71, f);
      t.Add(n, 'Self.Int_TClassMainChild_Priv'      ,  72, f);
      t.Add(n, 'Self.Int_TClassMain'                ,  80, f);
      t.Add(n, 'Self.Int_TClassMain_Prot'           ,  81, f);
      t.Add(n, 'Self.Int_TClassMain_Priv'           ,  82, f);
      t.Add(n, 'Self.Int_TClassMainBase'            , 170, f);
      t.Add(n, 'Self.Int_TClassMainBase_Prot'       , 171, f);
      t.Add(n, 'Self.Int_TClassMainBase_Priv'       , 172, f).ExpectNotFound.NotImplemented;
      t.Add(n, 'Self.Int_TClassMainBaseBase'        , 270, f);
      t.Add(n, 'Self.Int_TClassMainBaseBase_Prot'   , 271, f);
      t.Add(n, 'Self.Int_TClassMainBaseBase_Priv'   , 272, f).ExpectNotFound.NotImplemented;
      t.Add(n, 'Self.Int_GlobalPrg'                 , 101, f).ExpectNotFound;
      t.Add(n, 'Self.Int_GlobalUnit1'               , 201, f).ExpectNotFound;
      t.Add(n, 'Self.Int_GlobalUnit2'               , 202, f).ExpectNotFound;

      t.Add(n, 'TClassMainChild(Self).Int_TClassMainChild'           ,  70, f);
      t.Add(n, 'TClassMainChild(Self).Int_TClassMainChild_Prot'      ,  71, f);
      t.Add(n, 'TClassMainChild(Self).Int_TClassMainChild_Priv'      ,  72, f);
      t.Add(n, 'TClassMainChild(Self).Int_TClassMain'                ,  80, f);
      t.Add(n, 'TClassMainChild(Self).Int_TClassMain_Prot'           ,  81, f);
      t.Add(n, 'TClassMainChild(Self).Int_TClassMain_Priv'           ,  82, f);
      t.Add(n, 'TClassMainChild(Self).Int_TClassMainBase'            , 170, f);
      t.Add(n, 'TClassMainChild(Self).Int_TClassMainBase_Prot'       , 171, f);
      t.Add(n, 'TClassMainChild(Self).Int_TClassMainBase_Priv'       , 172, f).ExpectNotFound.NotImplemented;
      t.Add(n, 'TClassMainChild(Self).Int_TClassMainBaseBase'        , 270, f);
      t.Add(n, 'TClassMainChild(Self).Int_TClassMainBaseBase_Prot'   , 271, f);
      t.Add(n, 'TClassMainChild(Self).Int_TClassMainBaseBase_Priv'   , 272, f).ExpectNotFound.NotImplemented;

      t.Add(n, 'TClassMain(Self).Int_TClassMainChild'           ,  70, f).ExpectNotFound;
      t.Add(n, 'TClassMain(Self).Int_TClassMainChild_Prot'      ,  71, f).ExpectNotFound;
      t.Add(n, 'TClassMain(Self).Int_TClassMainChild_Priv'      ,  72, f).ExpectNotFound;
      t.Add(n, 'TClassMain(Self).Int_TClassMain'                ,  80, f);
      t.Add(n, 'TClassMain(Self).Int_TClassMain_Prot'           ,  81, f);
      t.Add(n, 'TClassMain(Self).Int_TClassMain_Priv'           ,  82, f);
      t.Add(n, 'TClassMain(Self).Int_TClassMainBase'            , 170, f);
      t.Add(n, 'TClassMain(Self).Int_TClassMainBase_Prot'       , 171, f);
      t.Add(n, 'TClassMain(Self).Int_TClassMainBase_Priv'       , 172, f).ExpectNotFound.NotImplemented;
      t.Add(n, 'TClassMain(Self).Int_TClassMainBaseBase'        , 270, f);
      t.Add(n, 'TClassMain(Self).Int_TClassMainBaseBase_Prot'   , 271, f);
      t.Add(n, 'TClassMain(Self).Int_TClassMainBaseBase_Priv'   , 272, f).ExpectNotFound.NotImplemented;

      t.Add(n, 'TClassMainBase(Self).Int_TClassMainChild'           ,  70, f).ExpectNotFound;
      t.Add(n, 'TClassMainBase(Self).Int_TClassMainChild_Prot'      ,  71, f).ExpectNotFound;
      t.Add(n, 'TClassMainBase(Self).Int_TClassMainChild_Priv'      ,  72, f).ExpectNotFound;
      t.Add(n, 'TClassMainBase(Self).Int_TClassMain'                ,  80, f).ExpectNotFound;
      t.Add(n, 'TClassMainBase(Self).Int_TClassMain_Prot'           ,  81, f).ExpectNotFound;
      t.Add(n, 'TClassMainBase(Self).Int_TClassMain_Priv'           ,  82, f).ExpectNotFound;
      t.Add(n, 'TClassMainBase(Self).Int_TClassMainBase'            , 170, f);
      t.Add(n, 'TClassMainBase(Self).Int_TClassMainBase_Prot'       , 171, f);
      t.Add(n, 'TClassMainBase(Self).Int_TClassMainBase_Priv'       , 172, f);
      t.Add(n, 'TClassMainBase(Self).Int_TClassMainBaseBase'        , 270, f);
      t.Add(n, 'TClassMainBase(Self).Int_TClassMainBaseBase_Prot'   , 271, f);
      t.Add(n, 'TClassMainBase(Self).Int_TClassMainBaseBase_Priv'   , 272, f).ExpectNotFound.NotImplemented;

      t.Add(n + '; Hide, view MainChild', 'Int_HideTest_Class' , 3001, f);
      t.Add(n + '; Hide, view MainChild', 'Self.Int_HideTest_Class' , 3001, f);
      t.Add(n + '; Hide, view MainChild', 'TClassMain(Self).Int_HideTest_Class' , 0, f).ExpectNotFound.NotImplemented;
      t.Add(n + '; Hide, view MainChild', 'TClassMainBase(Self).Int_HideTest_Class' , 1001, f);
      t.Add(n + '; Hide, view MainChild', 'TObject(Self).Int_HideTest_Class' , 0, f).ExpectNotFound;

      t.Add(n + '; Hide, view MainChild', 'Int_HideTest_Unit' , 3010, f);

      t.Add(n, 'TMethodMainChildNestedTwiceEnum(1)', weEnum('mmCNT2'), f);
      t.Add(n, 'TMethodMainChildNestedEnum(1)',      weEnum('mmCN2'),  f);
      t.Add(n, 'TMethodMainChildEnum(1)',            weEnum('mmC2'),   f);
      t.Add(n, 'TMainEnum(1)',                       weEnum('mm2'),    f);
      t.Add(n, 'TMainBaseEnum(1)',                   weEnum('mmB2'),   f);
      t.Add(n, 'TMainGlobEnum(1)',                   weEnum('mmG2'),   f);

      t.Add(n, 'THideMainEnum(1)', weEnum('hmCNT2'), f);

    end;

    n := AName + ' (Stack: MethodMainChildNested)';
    f := 1 - AStackOffs;
    if f >= 0 then begin
      t.Add(n, 'Int_MethodMainChildNestedTwice',  30, f).ExpectNotFound;
      t.Add(n, 'Int_MethodMainChildNested'     ,  40, f);
      t.Add(n, 'Int_MethodMainChild'           ,  50, f);
      t.Add(n, 'Int_MethodMainChild_Late'      ,  51, f).ExpectNotFound.NotImplemented;
      t.Add(n, 'Int_TClassMainChild'           ,  70, f);
      t.Add(n, 'Int_TClassMainChild_Prot'      ,  71, f);
      t.Add(n, 'Int_TClassMainChild_Priv'      ,  72, f);
      t.Add(n, 'Int_TClassMain'                ,  80, f);
      t.Add(n, 'Int_TClassMain_Prot'           ,  81, f);
      t.Add(n, 'Int_TClassMain_Priv'           ,  82, f);
      t.Add(n, 'Int_TClassMainBase'            , 170, f);
      t.Add(n, 'Int_TClassMainBase_Prot'       , 171, f);
      t.Add(n, 'Int_TClassMainBase_Priv'       , 172, f).ExpectNotFound.NotImplemented;
      t.Add(n, 'Int_TClassMainBaseBase'        , 270, f);
      t.Add(n, 'Int_TClassMainBaseBase_Prot'   , 271, f);
      t.Add(n, 'Int_TClassMainBaseBase_Priv'   , 272, f).ExpectNotFound.NotImplemented;
      t.Add(n, 'Int_GlobalPrg'                 , 101, f);
      t.Add(n, 'Int_GlobalUnit1'               , 201, f);
      t.Add(n, 'Int_GlobalUnit2'               , 202, f);

      t.Add(n + '; Hide, view MainChild', 'Int_HideTest_Class' , 3001, f);
      t.Add(n + '; Hide, view MainChild', 'Int_HideTest_Unit' , 3010, f);

      t.Add(n, 'TMethodMainChildNestedTwiceEnum(1)', weEnum('mmCNT2'), f).ExpectNotFound;
      t.Add(n, 'TMethodMainChildNestedEnum(1)',      weEnum('mmCN2'),  f);
      t.Add(n, 'TMethodMainChildEnum(1)',            weEnum('mmC2'),   f);
      t.Add(n, 'TMainEnum(1)',                       weEnum('mm2'),    f);
      t.Add(n, 'TMainBaseEnum(1)',                   weEnum('mmB2'),   f);
      t.Add(n, 'TMainGlobEnum(1)',                   weEnum('mmG2'),   f);

      t.Add(n, 'THideMainEnum(1)', weEnum('hmCN2'), f);
    end;

    n := AName + ' (Stack: MethodMainChild)';
    f := 2 - AStackOffs;
    if f >= 0 then begin
      t.Add(n, 'Int_MethodMainChildNestedTwice',  30, f).ExpectNotFound;
      t.Add(n, 'Int_MethodMainChildNested'     ,  40, f).ExpectNotFound;
      t.Add(n, 'Int_MethodMainChild'           ,  50, f);
      t.Add(n, 'Int_MethodMainChild_Late'      ,  51, f).ExpectNotFound.NotImplemented;
      t.Add(n, 'Int_TClassMainChild'           ,  70, f);
      t.Add(n, 'Int_TClassMainChild_Prot'      ,  71, f);
      t.Add(n, 'Int_TClassMainChild_Priv'      ,  72, f);
      t.Add(n, 'Int_TClassMain'                ,  80, f);
      t.Add(n, 'Int_TClassMain_Prot'           ,  81, f);
      t.Add(n, 'Int_TClassMain_Priv'           ,  82, f);
      t.Add(n, 'Int_TClassMainBase'            , 170, f);
      t.Add(n, 'Int_TClassMainBase_Prot'       , 171, f);
      t.Add(n, 'Int_TClassMainBase_Priv'       , 172, f).ExpectNotFound.NotImplemented;
      t.Add(n, 'Int_TClassMainBaseBase'        , 270, f);
      t.Add(n, 'Int_TClassMainBaseBase_Prot'   , 271, f);
      t.Add(n, 'Int_TClassMainBaseBase_Priv'   , 272, f).ExpectNotFound.NotImplemented;
      t.Add(n, 'Int_GlobalPrg'                 , 101, f);
      t.Add(n, 'Int_GlobalUnit1'               , 201, f);
      t.Add(n, 'Int_GlobalUnit2'               , 202, f);

      t.Add(n + '; Hide, view MainChild', 'Int_HideTest_Class' , 3001, f);
      t.Add(n + '; Hide, view MainChild', 'Int_HideTest_Unit' , 3010, f);

      t.Add(n, 'TMethodMainChildNestedTwiceEnum(1)', weEnum('mmCNT2'), f).ExpectNotFound;
      t.Add(n, 'TMethodMainChildNestedEnum(1)',      weEnum('mmCN2'),  f).ExpectNotFound;
      t.Add(n, 'TMethodMainChildEnum(1)',            weEnum('mmC2'),   f);
      t.Add(n, 'TMainEnum(1)',                       weEnum('mm2'),    f);
      t.Add(n, 'TMainBaseEnum(1)',                   weEnum('mmB2'),   f);
      t.Add(n, 'TMainGlobEnum(1)',                   weEnum('mmG2'),   f);

      t.Add(n, 'THideMainEnum(1)', weEnum('hmC2'), f);
    end;

    n := AName + ' (Stack: MethodMain)';
    f := 3 - AStackOffs;
    if f >= 0 then begin
      t.Add(n, 'Int_MethodMainChildNestedTwice',  30, f).ExpectNotFound;
      t.Add(n, 'Int_MethodMainChildNested'     ,  40, f).ExpectNotFound;
      t.Add(n, 'Int_MethodMainChild'           ,  50, f).ExpectNotFound;
      t.Add(n, 'Int_MethodMainChild_Late'      ,  51, f).ExpectNotFound;
      t.Add(n, 'Int_TClassMainChild'           ,  70, f).ExpectNotFound;
      t.Add(n, 'Int_TClassMainChild_Prot'      ,  71, f).ExpectNotFound;
      t.Add(n, 'Int_TClassMainChild_Priv'      ,  72, f).ExpectNotFound;
      t.Add(n, 'Int_TClassMain'                ,  80, f);
      t.Add(n, 'Int_TClassMain_Prot'           ,  81, f);
      t.Add(n, 'Int_TClassMain_Priv'           ,  82, f);
      t.Add(n, 'Int_TClassMainBase'            , 170, f);
      t.Add(n, 'Int_TClassMainBase_Prot'       , 171, f);
      t.Add(n, 'Int_TClassMainBase_Priv'       , 172, f).ExpectNotFound.NotImplemented;
      t.Add(n, 'Int_TClassMainBaseBase'        , 270, f);
      t.Add(n, 'Int_TClassMainBaseBase_Prot'   , 271, f);
      t.Add(n, 'Int_TClassMainBaseBase_Priv'   , 272, f).ExpectNotFound.NotImplemented;
      t.Add(n, 'Int_GlobalPrg'                 , 101, f);
      t.Add(n, 'Int_GlobalUnit1'               , 201, f);
      t.Add(n, 'Int_GlobalUnit2'               , 202, f);

      t.Add(n + ', Hide, view glob Prg', 'Int_HideTest_Class' , 3000, f).ExpectNotFound.NotImplemented;

      t.Add(n, 'TMethodMainChildNestedTwiceEnum(1)', weEnum('mmCNT2'), f).ExpectNotFound;
      t.Add(n, 'TMethodMainChildNestedEnum(1)',      weEnum('mmCN2'),  f).ExpectNotFound;
      t.Add(n, 'TMethodMainChildEnum(1)',            weEnum('mmC2'),   f).ExpectNotFound;
      t.Add(n, 'TMainEnum(1)',                       weEnum('mm2'),    f);
      t.Add(n, 'TMainBaseEnum(1)',                   weEnum('mmB2'),   f);
      t.Add(n, 'TMainGlobEnum(1)',                   weEnum('mmG2'),   f);

      t.Add(n, 'THideMainEnum(1)', weEnum('hmB2'), f)^.AddFlag(ehNotImplementedData);
    end;

    n := AName + ' (Stack: MethodMainBase)';
    f := 4 - AStackOffs;
    if f >= 0 then begin
      t.Add(n, 'Int_MethodMainChildNestedTwice',  30, f).ExpectNotFound;
      t.Add(n, 'Int_MethodMainChildNested'     ,  40, f).ExpectNotFound;
      t.Add(n, 'Int_MethodMainChild'           ,  50, f).ExpectNotFound;
      t.Add(n, 'Int_MethodMainChild_Late'      ,  51, f).ExpectNotFound;
      t.Add(n, 'Int_TClassMainChild'           ,  70, f).ExpectNotFound;
      t.Add(n, 'Int_TClassMainChild_Prot'      ,  71, f).ExpectNotFound;
      t.Add(n, 'Int_TClassMainChild_Priv'      ,  72, f).ExpectNotFound;
      t.Add(n, 'Int_TClassMain'                ,  80, f).ExpectNotFound;
      t.Add(n, 'Int_TClassMain_Prot'           ,  81, f).ExpectNotFound;
      t.Add(n, 'Int_TClassMain_Priv'           ,  82, f).ExpectNotFound;
      t.Add(n, 'Int_TClassMainBase'            , 170, f);
      t.Add(n, 'Int_TClassMainBase_Prot'       , 171, f);
      t.Add(n, 'Int_TClassMainBase_Priv'       , 172, f).ExpectNotFound.NotImplemented;
      t.Add(n, 'Int_TClassMainBaseBase'        , 270, f);
      t.Add(n, 'Int_TClassMainBaseBase_Prot'   , 271, f);
      t.Add(n, 'Int_TClassMainBaseBase_Priv'   , 272, f).ExpectNotFound.NotImplemented;
      t.Add(n, 'Int_GlobalPrg'                 , 101, f).ExpectNotFound.NotImplemented;
      t.Add(n, 'Int_GlobalUnit1'               , 201, f);
      t.Add(n, 'Int_GlobalUnit2'               , 202, f);

      t.Add(n, 'TClassMain(Self).Int_MethodMainChildNestedTwice',  30, f).ExpectNotFound;
      t.Add(n, 'TClassMain(Self).Int_MethodMainChildNested'     ,  40, f).ExpectNotFound;
      t.Add(n, 'TClassMain(Self).Int_MethodMainChild'           ,  50, f).ExpectNotFound;
      t.Add(n, 'TClassMain(Self).Int_MethodMainChild_Late'      ,  51, f).ExpectNotFound;
      t.Add(n, 'TClassMain(Self).Int_TClassMainChild'           ,  70, f).ExpectNotFound;
      t.Add(n, 'TClassMain(Self).Int_TClassMainChild_Prot'      ,  71, f).ExpectNotFound;
      t.Add(n, 'TClassMain(Self).Int_TClassMainChild_Priv'      ,  72, f).ExpectNotFound;
      t.Add(n, 'TClassMain(Self).Int_TClassMain'                ,  80, f);
      t.Add(n, 'TClassMain(Self).Int_TClassMain_Prot'           ,  81, f);
      t.Add(n, 'TClassMain(Self).Int_TClassMain_Priv'           ,  82, f);
      t.Add(n, 'TClassMain(Self).Int_TClassMainBase'            , 170, f);
      t.Add(n, 'TClassMain(Self).Int_TClassMainBase_Prot'       , 171, f);
      t.Add(n, 'TClassMain(Self).Int_TClassMainBase_Priv'       , 172, f).ExpectNotFound.NotImplemented;
      t.Add(n, 'TClassMain(Self).Int_TClassMainBaseBase'        , 270, f);
      t.Add(n, 'TClassMain(Self).Int_TClassMainBaseBase_Prot'   , 271, f);
      t.Add(n, 'TClassMain(Self).Int_TClassMainBaseBase_Priv'   , 272, f).ExpectNotFound.NotImplemented;
      t.Add(n, 'TClassMain(Self).Int_GlobalPrg'                 , 101, f).ExpectNotFound;
      t.Add(n, 'TClassMain(Self).Int_GlobalUnit1'               , 201, f).ExpectNotFound;
      t.Add(n, 'TClassMain(Self).Int_GlobalUnit2'               , 202, f).ExpectNotFound;

      t.Add(n, 'TClassMainChild(Self).Int_MethodMainChildNestedTwice',  30, f).ExpectNotFound;
      t.Add(n, 'TClassMainChild(Self).Int_MethodMainChildNested'     ,  40, f).ExpectNotFound;
      t.Add(n, 'TClassMainChild(Self).Int_MethodMainChild'           ,  50, f).ExpectNotFound;
      t.Add(n, 'TClassMainChild(Self).Int_MethodMainChild_Late'      ,  51, f).ExpectNotFound;
      t.Add(n, 'TClassMainChild(Self).Int_TClassMainChild'           ,  70, f);
      t.Add(n, 'TClassMainChild(Self).Int_TClassMainChild_Prot'      ,  71, f);
      t.Add(n, 'TClassMainChild(Self).Int_TClassMainChild_Priv'      ,  72, f);
      t.Add(n, 'TClassMainChild(Self).Int_TClassMain'                ,  80, f);
      t.Add(n, 'TClassMainChild(Self).Int_TClassMain_Prot'           ,  81, f);
      t.Add(n, 'TClassMainChild(Self).Int_TClassMain_Priv'           ,  82, f);
      t.Add(n, 'TClassMainChild(Self).Int_TClassMainBase'            , 170, f);
      t.Add(n, 'TClassMainChild(Self).Int_TClassMainBase_Prot'       , 171, f);
      t.Add(n, 'TClassMainChild(Self).Int_TClassMainBase_Priv'       , 172, f).ExpectNotFound.NotImplemented;
      t.Add(n, 'TClassMainChild(Self).Int_TClassMainBaseBase'        , 270, f);
      t.Add(n, 'TClassMainChild(Self).Int_TClassMainBaseBase_Prot'   , 271, f);
      t.Add(n, 'TClassMainChild(Self).Int_TClassMainBaseBase_Priv'   , 272, f).ExpectNotFound.NotImplemented;

      t.Add(n + '; Hide, view MainChild', 'Int_HideTest_Class' , 1001, f);
      t.Add(n + '; Hide, view MainChild', 'Int_HideTest_Unit' , 1010, f);

      t.Add(n, 'TMethodMainChildNestedTwiceEnum(1)', weEnum('mmCNT2'), f).ExpectNotFound;
      t.Add(n, 'TMethodMainChildNestedEnum(1)',      weEnum('mmCN2'),  f).ExpectNotFound;
      t.Add(n, 'TMethodMainChildEnum(1)',            weEnum('mmC2'),   f).ExpectNotFound;
      t.Add(n, 'TMainEnum(1)',                       weEnum('mm2'),    f).ExpectNotFound.NotImplemented; // found in other unit
      t.Add(n, 'TMainBaseEnum(1)',                   weEnum('mmB2'),   f);
      t.Add(n, 'TMainGlobEnum(1)',                   weEnum('mmG2'),   f).ExpectNotFound.NotImplemented;

      t.Add(n, 'THideMainEnum(1)', weEnum('hmB2'), f);  // found via unit / but otherwise ehNotImplemented;
    end;

    n := AName + ' (Stack: MethodMainBaseBase)';
    f := 5 - AStackOffs;
    if f >= 0 then begin
      t.Add(n, 'Int_MethodMainChildNestedTwice',  30, f).ExpectNotFound;
      t.Add(n, 'Int_MethodMainChildNested'     ,  40, f).ExpectNotFound;
      t.Add(n, 'Int_MethodMainChild'           ,  50, f).ExpectNotFound;
      t.Add(n, 'Int_MethodMainChild_Late'      ,  51, f).ExpectNotFound;
      t.Add(n, 'Int_TClassMainChild'           ,  70, f).ExpectNotFound;
      t.Add(n, 'Int_TClassMainChild_Prot'      ,  71, f).ExpectNotFound;
      t.Add(n, 'Int_TClassMainChild_Priv'      ,  72, f).ExpectNotFound;
      t.Add(n, 'Int_TClassMain'                ,  80, f).ExpectNotFound;
      t.Add(n, 'Int_TClassMain_Prot'           ,  81, f).ExpectNotFound;
      t.Add(n, 'Int_TClassMain_Priv'           ,  82, f).ExpectNotFound;
      t.Add(n, 'Int_TClassMainBase'            , 170, f).ExpectNotFound;
      t.Add(n, 'Int_TClassMainBase_Prot'       , 171, f).ExpectNotFound;
      t.Add(n, 'Int_TClassMainBase_Priv'       , 172, f).ExpectNotFound;
      t.Add(n, 'Int_TClassMainBaseBase'        , 270, f);
      t.Add(n, 'Int_TClassMainBaseBase_Prot'   , 271, f);
      t.Add(n, 'Int_TClassMainBaseBase_Priv'   , 272, f).ExpectNotFound.NotImplemented;
      t.Add(n, 'Int_GlobalPrg'                 , 101, f).ExpectNotFound.NotImplemented;
      t.Add(n, 'Int_GlobalUnit1'               , 201, f).ExpectNotFound.NotImplemented;
      t.Add(n, 'Int_GlobalUnit2'               , 202, f);

      t.Add(n + '; Hide, view MainChild', 'Int_HideTest_Class' , 2001, f);
      t.Add(n + '; Hide, view MainChild', 'Int_HideTest_Unit' , 2010, f);

      t.Add(n, 'TMethodMainChildNestedTwiceEnum(1)', weEnum('mmCNT2'), f).ExpectNotFound;
      t.Add(n, 'TMethodMainChildNestedEnum(1)',      weEnum('mmCN2'),  f).ExpectNotFound;
      t.Add(n, 'TMethodMainChildEnum(1)',            weEnum('mmC2'),   f).ExpectNotFound;
      t.Add(n, 'TMainEnum(1)',                       weEnum('mm2'),    f).ExpectNotFound.NotImplemented; // found in other unit
      t.Add(n, 'TMainBaseEnum(1)',                   weEnum('mmB2'),   f).ExpectNotFound.NotImplemented; // found in other unit
      t.Add(n, 'TMainGlobEnum(1)',                   weEnum('mmG2'),   f).ExpectNotFound.NotImplemented;

      t.Add(n, 'THideMainEnum(1)', weEnum('x'), f).ExpectNotFound.NotImplemented; // will find main unit
    end;

    n := AName + ' (Stack: main)';
    f := 6 - AStackOffs;
    if f >= 0 then begin
      t.Add(n, 'Int_MethodMainChildNestedTwice',  30, f).ExpectNotFound;
      t.Add(n, 'Int_MethodMainChildNested'     ,  40, f).ExpectNotFound;
      t.Add(n, 'Int_MethodMainChild'           ,  50, f).ExpectNotFound;
      t.Add(n, 'Int_MethodMainChild_Late'      ,  51, f).ExpectNotFound;
      t.Add(n, 'Int_TClassMainChild'           ,  70, f).ExpectNotFound;
      t.Add(n, 'Int_TClassMainChild_Prot'      ,  71, f).ExpectNotFound;
      t.Add(n, 'Int_TClassMainChild_Priv'      ,  72, f).ExpectNotFound;
      t.Add(n, 'Int_TClassMain'                ,  80, f).ExpectNotFound;
      t.Add(n, 'Int_TClassMain_Prot'           ,  81, f).ExpectNotFound;
      t.Add(n, 'Int_TClassMain_Priv'           ,  82, f).ExpectNotFound;
      t.Add(n, 'Int_TClassMainBase'            , 170, f).ExpectNotFound;
      t.Add(n, 'Int_TClassMainBase_Prot'       , 171, f).ExpectNotFound;
      t.Add(n, 'Int_TClassMainBase_Priv'       , 172, f).ExpectNotFound;
      t.Add(n, 'Int_TClassMainBaseBase'        , 270, f).ExpectNotFound;
      t.Add(n, 'Int_TClassMainBaseBase_Prot'   , 271, f).ExpectNotFound;
      t.Add(n, 'Int_TClassMainBaseBase_Priv'   , 272, f).ExpectNotFound;
      t.Add(n, 'Int_GlobalPrg'                 , 101, f);
      t.Add(n, 'Int_GlobalUnit1'               , 201, f);
      t.Add(n, 'Int_GlobalUnit2'               , 202, f);

      t.Add(n + '; Hide, view MainChild', 'Int_HideTest_Class' , 3000, f);
      t.Add(n + '; Hide, view MainChild', 'Int_HideTest_Unit' , 3010, f);

      t.Add(n, 'TMethodMainChildNestedTwiceEnum(1)', weEnum('mmCNT2'), f).ExpectNotFound;
      t.Add(n, 'TMethodMainChildNestedEnum(1)',      weEnum('mmCN2'),  f).ExpectNotFound;
      t.Add(n, 'TMethodMainChildEnum(1)',            weEnum('mmC2'),   f).ExpectNotFound;
      t.Add(n, 'TMainEnum(1)',                       weEnum('mm2'),    f).ExpectNotFound.NotImplemented; // found in unit scope
      t.Add(n, 'TMainBaseEnum(1)',                   weEnum('mmB2'),   f).ExpectNotFound.NotImplemented; // found in unit scope
      t.Add(n, 'TMainGlobEnum(1)',                   weEnum('mmG2'),   f);

      t.Add(n, 'THideMainEnum(1)', weEnum('hmG2'), f)^.AddFlag([ehNotImplementedData]); // may find the class scope
    end;
  end;

  procedure AddWatchesForFoo(t: TWatchExpectationList; AName: String; AStackOffs: Integer; Twice2: Boolean = False);
  var
    n: String;
    f: Integer;
    //IntGlobFlags: TWatchExpErrorHandlingFlags;
  begin

    n := AName;
    f := -AStackOffs;
    if f >= 0 then begin
      if Twice2 then begin
        t.Add(n, 'Int_Hide_Foo',  5, f);
        t.Add(n, 'Result',  'abc2', f).IgnKindPtr.IgnKind(stDwarf3Up);;
      end
      else begin
        t.Add(n, 'Int_Hide_Foo',  4, f);
        t.Add(n, 'Result',  'abc', f).IgnKindPtr.IgnKind(stDwarf3Up);;
      end;
    end;

    n := AName + ' FooNested';
    f := 1 - AStackOffs;
    if f >= 0 then begin
      t.Add(n, 'Int_Hide_Foo',  3, f);
      t.Add(n, 'Result',  'bar', f).IgnKindPtr.IgnKind(stDwarf3Up);;
    end;

    n := AName + ' Foo';
    f := 2 - AStackOffs;
    if f >= 0 then begin
      t.Add(n, 'Int_Hide_Foo',  2, f);
      t.Add(n, 'Result',  99, f);
    end;

    n := AName + ' Prg';
    f := 3 - AStackOffs;
    if f >= 0 then begin
      t.Add(n, 'Int_Hide_Foo',  1, f);
      t.Add(n, 'Result',  0, f).ExpectNotFound;
    end;

    // Test: Nested can see Outer scope
    if AStackOffs <= 2 then
      t.Add(n, 'TestEnum',  weEnum('te3'), 0);
    if AStackOffs <= 1 then
      t.Add(n, 'TestEnum',  weEnum('te3'), 1);

  end;

var
  ExeName: String;
  t: TWatchExpectationList;
  Src: TCommonSource;
begin
  if SkipTest then exit;
  if not TestControlCanTest(ControlTestWatchScope) then exit;
  t := nil;

  Src := GetCommonSourceFor('WatchesScopePrg.pas');
  TestCompile(Src, ExeName);

  AssertTrue('Start debugger', Debugger.StartDebugger(AppDir, ExeName));

  try
    t := TWatchExpectationList.Create(Self);
    t.AcceptSkSimple := [skInteger, skCardinal, skBoolean, skChar, skFloat, skString, skAnsiString, skCurrency, skVariant, skWideString];
    t.AddTypeNameAlias('integer', 'integer|longint');
    t.AddTypeNameAlias('Char', 'Char|AnsiChar');


    Debugger.SetBreakPoint(Src, 'FuncFooNestedTwice');
    Debugger.SetBreakPoint(Src, 'FuncFooNestedTwice2');
    Debugger.SetBreakPoint(Src, 'FuncFooNested');
    Debugger.SetBreakPoint(Src, 'FuncFoo');

    Debugger.SetBreakPoint(Src, 'MethodMainChildNestedTwice');
    Debugger.SetBreakPoint(Src, 'MethodMainChildNested');
    Debugger.SetBreakPoint(Src, 'MethodMainChild');
    Debugger.SetBreakPoint(Src, 'MethodMain');
    Debugger.SetBreakPoint(Src, 'WatchesScopeUnit1.pas', 'MethodMainBase');
    Debugger.SetBreakPoint(Src, 'WatchesScopeUnit2.pas', 'MethodMainBaseBase');

    Debugger.SetBreakPoint(Src, 'Prg');

    Debugger.SetBreakPoint(Src, 'FuncFin1');
    Debugger.SetBreakPoint(Src, 'FuncFin2');
    Debugger.SetBreakPoint(Src, 'FuncFin3');
    AssertDebuggerNotInErrorState;

    (* ************ Nested Functions ************* *)

    Debugger.RunToNextPause(dcRun);
    AssertDebuggerState(dsPause);
    t.Clear;
    AddWatchesForFoo(t, 'Scope in FuncFooNestedTwice', 0);
    t.EvaluateWatches;
    t.CheckResults;

    Debugger.RunToNextPause(dcRun);
    AssertDebuggerState(dsPause);
    t.Clear;
    AddWatchesForFoo(t, 'Scope in FuncFooNestedTwice2', 0, True);
    t.EvaluateWatches;
    t.CheckResults;

    Debugger.RunToNextPause(dcRun);
    AssertDebuggerState(dsPause);
    t.Clear;
    AddWatchesForFoo(t, 'Scope in FuncFooNested', 1);
    t.EvaluateWatches;
    t.CheckResults;

    Debugger.RunToNextPause(dcRun);
    AssertDebuggerState(dsPause);
    t.Clear;
    AddWatchesForFoo(t, 'Scope in FuncFoo', 2);
    t.EvaluateWatches;
    t.CheckResults;

    (* ************ Class ************* *)

    Debugger.RunToNextPause(dcRun); // MethodMainChildNestedTwice
    AssertDebuggerState(dsPause);
    t.Clear;
    AddWatchesForClassMethods(t, 'Scope in MethodMainChildNestedTwice', 0);
    t.EvaluateWatches;
    t.CheckResults;

    Debugger.RunToNextPause(dcRun); // MethodMainChildNested
    AssertDebuggerState(dsPause);
    t.Clear;
    AddWatchesForClassMethods(t, 'Scope in MethodMainChildNested', 1);
    t.EvaluateWatches;
    t.CheckResults;

    Debugger.RunToNextPause(dcRun); // MethodMainChild
    AssertDebuggerState(dsPause);
    t.Clear;
    AddWatchesForClassMethods(t, 'Scope in MethodMainChild', 2);
    t.EvaluateWatches;
    t.CheckResults;

    Debugger.RunToNextPause(dcRun); // MethodMain
    AssertDebuggerState(dsPause);
    t.Clear;
    AddWatchesForClassMethods(t, 'Scope in MethodMain', 3);
    t.EvaluateWatches;
    t.CheckResults;

    Debugger.RunToNextPause(dcRun); // MethodMainBase
    AssertDebuggerState(dsPause);
    t.Clear;
    AddWatchesForClassMethods(t, 'Scope in MethodMainBase', 4);
    t.EvaluateWatches;
    t.CheckResults;

    Debugger.RunToNextPause(dcRun); // MethodMainBaseBase
    AssertDebuggerState(dsPause);
    t.Clear;
    AddWatchesForClassMethods(t, 'Scope in MethodMainBaseBase', 5);
    t.EvaluateWatches;
    t.CheckResults;

    (* ************ Program level ************* *)

    Debugger.RunToNextPause(dcRun);
    AssertDebuggerState(dsPause);
    t.Clear;
    AddWatchesForClassMethods(t, 'Scope in Prg', 6);
    AddWatchesForFoo(t, 'Scope in Prg', 3);
    t.EvaluateWatches;
    t.CheckResults;


    (* ************ finally ************* *)

    Debugger.RunToNextPause(dcRun);
    AssertDebuggerState(dsPause);
    t.Clear;
    t.Add('FinFoo1', 'FinFoo1' , 123);
    t.Add('FinFoo2', 'FinFoo2' , 456);
    t.Add('FinFoo3', 'FinFoo3' , 789);
    t.EvaluateWatches;
    t.CheckResults;

    Debugger.RunToNextPause(dcRun);
    AssertDebuggerState(dsPause);
    t.Clear;
    t.Add('FinFoo1', 'FinFoo1' , 123);
    t.Add('FinFoo2', 'FinFoo2' , 456);
    t.Add('FinFoo3', 'FinFoo3' , 789);
    t.EvaluateWatches;
    t.CheckResults;

    Debugger.RunToNextPause(dcRun);
    AssertDebuggerState(dsPause);
    t.Clear;
    t.Add('FinFoo1', 'FinFoo1' , 123);
    t.Add('FinFoo2', 'FinFoo2' , 456);
    t.Add('FinFoo3', 'FinFoo3' , 789);
    t.EvaluateWatches;
    t.CheckResults;


  finally
    Debugger.RunToNextPause(dcStop);
    t.Free;
    Debugger.ClearDebuggerMonitors;
    Debugger.FreeDebugger;

    AssertTestErrors;
  end;
end;

procedure TTestWatches.TestWatchesValue;

  type
    TTestLoc = (tlAny, tlConst, tlParam, tlArrayWrap, tlPointer, tlPointerAny, tlClassConst, tlClassVar);
    TTestIgn = set of (
      tiPointerMath,  // pointer math / (ptr+n)^ / ptr[n]
      tlReduced,      // reduced set of tests
      tlTypeTX        // TX... = type .... // not all names translate
    );
    TTestPart = (tp1, tp2, tp3);
    TTestParts = set of TTestPart;

  procedure AddWatches(t: TWatchExpectationList; AName: String; APrefix: String; AOffs: Integer; AChr1: Char;
    ALoc: TTestLoc = tlAny; APostFix: String = ''; AIgnFlags: TTestIgn = []; TpPreFix: String = ''; APartToRun: TTestParts = [tp1, tp2, tp3]);
  var
    p, e, x: String;
    n, StartIdx,  i: Integer;

  var _SkipContstIdx: integer;
  procedure BeginSkipConst;
  begin
    _SkipContstIdx := t.Count;
  end;
  procedure EndSkipConst(AClassConstOnly: boolean = false);
  var i: integer;
  begin
    if AClassConstOnly then
      for i := _SkipContstIdx to t.Count-1 do
        t.Tests[i].SkipIf(ALoc in [tlClassConst])
    else
      for i := _SkipContstIdx to t.Count-1 do
        t.Tests[i].SkipIf(ALoc in [tlConst, tlClassConst]);
  end;

  var _TxStartIdx: integer;
  procedure BeginTxTypeIgnore;
  begin
    _TxStartIdx := t.Count;
  end;
  procedure EndTxTypeIgnore;
  var i: integer;
  begin
    if (tlTypeTX in AIgnFlags) then
      for i := _TxStartIdx to t.Count-1 do
        t.Tests[i].IgnTypeName.AddFlag(ehIgnTypeNameInData);
  end;

  begin
    p := APrefix;
    e := APostFix;
    n := AOffs;
    x := TpPreFix;

    (* ******************************
       **********  PART 1  **********
       ****************************** *)
    if tp1 in APartToRun then begin

    t.Add(AName, p+'Byte'+e,       weCardinal(1+n,                    x+'Byte',     1));
    t.Add(AName, p+'Word'+e,       weCardinal(100+n,                  x+'Word',     2));
    t.Add(AName, p+'Longword'+e,   weCardinal(1000+n,                 x+'Longword', 4));
    t.Add(AName, p+'QWord'+e,      weCardinal(10000+n,                x+'QWord',    8));
    t.Add(AName, p+'Shortint'+e,   weInteger (50+n,                   x+'Shortint', 1));
    t.Add(AName, p+'Smallint'+e,   weInteger (500+n,                  x+'Smallint', 2));
    t.Add(AName, p+'Longint'+e,    weInteger (5000+n,                 x+'Longint',  4));
    t.Add(AName, p+'Int64'+e,      weInteger (50000+n,                x+'Int64',    8));
    t.Add(AName, p+'IntRange'+e,   weInteger (-50+n,                  x+'IntRange',0));
    t.Add(AName, p+'CardinalRange'+e, weCardinal(50+n,                x+'CardinalRange',0));

    BeginTxTypeIgnore;
      if not (tlReduced in AIgnFlags) then begin
        t.Add(AName, p+'Byte_2'+e,     weCardinal(240+n,                  x+'Byte',     1));
        t.Add(AName, p+'Word_2'+e,     weCardinal(65501+n,                x+'Word',     2));
        t.Add(AName, p+'Longword_2'+e, weCardinal(4123456789+n,           x+'Longword', 4));
        t.Add(AName, p+'QWord_2'+e,    weCardinal(15446744073709551610+n, x+'QWord',    8));
        t.Add(AName, p+'Shortint_2'+e, weInteger (112+n,                  x+'Shortint', 1));
        t.Add(AName, p+'Smallint_2'+e, weInteger (32012+n,                x+'Smallint', 2));
        t.Add(AName, p+'Longint_2'+e,  weInteger (20123456+n,             x+'Longint',  4));
        t.Add(AName, p+'Int64_2'+e,    weInteger (9123372036854775801+n,  x+'Int64',    8));

        t.Add(AName, p+'Shortint_3'+e, weInteger(-112+n,                 x+'Shortint', 1));
        t.Add(AName, p+'Smallint_3'+e, weInteger(-32012+n,               x+'Smallint', 2));
        t.Add(AName, p+'Longint_3'+e,  weInteger(-20123456+n,            x+'Longint',  4));
        t.Add(AName, p+'Int64_3'+e,    weInteger(-9123372036854775801+n, x+'Int64',    8));

        t.Add(AName, p+'Bool1'+e,      weBool(False,  x+'Boolean'));
        t.Add(AName, p+'Bool2'+e,      weBool(True,   x+'Boolean'));
        t.Add(AName, p+'WBool1'+e,      weBool(False, x+'Boolean16'));
        t.Add(AName, p+'WBool2'+e,      weBool(True , x+'Boolean16'));
        t.Add(AName, p+'LBool1'+e,      weBool(False, x+'Boolean32'));
        t.Add(AName, p+'LBool2'+e,      weBool(True , x+'Boolean32'));
        t.Add(AName, p+'QBool1'+e,      weBool(False, x+'Boolean64'));
        t.Add(AName, p+'QBool2'+e,      weBool(True , x+'Boolean64'));
      end;

      t.Add(AName, p+'ByteBool1'+e,  weSizedBool(False, x+'ByteBool'));
      t.Add(AName, p+'ByteBool2'+e,  weSizedBool(True , x+'ByteBool'));
      t.Add(AName, p+'WordBool1'+e,  weSizedBool(False, x+'WordBool'));
      t.Add(AName, p+'WordBool2'+e,  weSizedBool(True , x+'WordBool'));
      t.Add(AName, p+'LongBool1'+e,  weSizedBool(False, x+'LongBool'));
      t.Add(AName, p+'LongBool2'+e,  weSizedBool(True , x+'LongBool'));
      t.Add(AName, p+'QWordBool1'+e, weSizedBool(False, x+'QWordBool'));
      t.Add(AName, p+'QWordBool2'+e, weSizedBool(True , x+'QWordBool'));
    EndTxTypeIgnore;

    t.Add(AName, p+'Real'+e,       weFloat(50.25+n,                 x+'Real'       ));
    t.Add(AName, p+'Single'+e,     weSingle(100.125+n,              x+'Single'     ));
    t.Add(AName, p+'Double'+e,     weDouble(1000.125+n,             x+'Double'     ));
    t.Add(AName, p+'Extended'+e,   weFloat(10000.175+n,             ''   )) // Double ?
    .IgnAll([], Compiler.Version <= 030202);
//    {$IFDEF cpu64}
//    if Compiler.CpuBitType = cpu32 then // a 64bit debugger does has no 10byte extended type // TODO: check for error
//      t.Tests[-1]^.AddFlag(ehExpectError); // TODO: check error msg
//    {$ENDIF}
    //t.Add(p+'Comp'+e,       weInteger(150.125+n,              'Comp'       ));
//TODO: currency // integer is wrong, but lets check it
    t.Add(AName,         p+'Currency'+e,   weInteger(1251230+n*10000,  x+'Currency', SIZE_8 ))
      .SkipIf(ALoc = tlPointerAny);
    t.Add(AName+'-TODO', p+'Currency'+e,   weFloat(125.123+n,        x+'Currency'))^.AddFlag([ehNotImplementedData])
      .SkipIf(ALoc = tlPointerAny);

    BeginTxTypeIgnore;
      t.Add(AName, p+'Real_2'+e,     weFloat(-50.25+n,                x+'Real'       ));
      t.Add(AName, p+'Single_2'+e,   weSingle(-100.125+n,             x+'Single'     ));
      t.Add(AName, p+'Double_2'+e,   weDouble(-1000.125+n,            x+'Double'     ));
      t.Add(AName, p+'Extended_2'+e, weFloat(-10000.175+n,            ''   )) // Double ?
    .IgnAll([], Compiler.Version <= 030202);
//      {$IFDEF cpu64}
//      if Compiler.CpuBitType = cpu32 then // a 64bit debugger does has no 10byte extended type // TODO: check for error
//        t.Tests[-1]^.AddFlag(ehExpectError); // TODO: check error msg
//      {$ENDIF}
      //t.Add(p+'Comp_2'+e,     weFloat(-150.125+n,             'Comp'       ));
      t.Add(AName+'-TODO', p+'Currency_2'+e, weFloat(-125.123+n,              x+'Currency'   ))^.AddFlag([ehNotImplementedData])
        .SkipIf(ALoc = tlPointerAny);

      t.Add(AName, p+'Ptr1'+e, wePointerAddr(nil,                 x+'Pointer'));
      t.Add(AName, p+'Ptr2'+e, wePointerAddr(Pointer(1000+n),     x+'Pointer'));

      t.Add(AName, p+'Char'+e,       weChar(AChr1, x+'Char'));
      t.Add(AName, p+'Char2'+e,      weChar(#0   , x+'Char'));
      t.Add(AName, p+'Char3'+e,      weChar(' '  , x+'Char'));

// tlConst => strings are stored as shortstring
      t.Add(AName, p+'String1'+e,    weShortStr(AChr1, x+'ShortStr1'))                      .IgnTypeName([], ALoc in [tlConst, tlClassConst]).NotImplemented(stDwarf3up, tiPointerMath in AIgnFlags);
      t.Add(AName, p+'String1e'+e,   weShortStr('',    x+'ShortStr1'))                      .IgnTypeName([], ALoc in [tlConst, tlClassConst]).NotImplemented(stDwarf3up, tiPointerMath in AIgnFlags);
      t.Add(AName, p+'String10'+e,   weShortStr(AChr1+'bc1',               x+'ShortStr10')) .IgnTypeName([], ALoc in [tlConst, tlClassConst]).NotImplemented(stDwarf3up, tiPointerMath in AIgnFlags);
      t.Add(AName, p+'String10e'+e,  weShortStr('',                        x+'ShortStr10')) .IgnTypeName([], ALoc in [tlConst, tlClassConst]).NotImplemented(stDwarf3up, tiPointerMath in AIgnFlags);
      t.Add(AName, p+'String10x'+e,  weShortStr(AChr1+'S'#0'B'#9'b'#10#13, x+'ShortStr10')) .IgnTypeName([], ALoc in [tlConst, tlClassConst]).NotImplemented(stDwarf3up, tiPointerMath in AIgnFlags);
      t.Add(AName, p+'String255'+e,  weShortStr(AChr1+'bcd0123456789', x+'ShortStr255'))                                      .NotImplemented(stDwarf3up, tiPointerMath in AIgnFlags);
    EndTxTypeIgnore;

    if not (tlReduced in AIgnFlags) then begin
      BeginTxTypeIgnore;
        t.Add(AName, p+'Ansi1'+e,      weAnsiStr(Succ(AChr1), x+'AnsiString' ))     .IgnKindPtr(stDwarf2).IgnKind(stDwarf3Up)
          .IgnTypeName([], ALoc in [tlConst, tlClassConst]).IgnKind([], ALoc in [tlConst, tlClassConst]);
        t.Add(AName, p+'Ansi2'+e,      weAnsiStr(AChr1+'abcd0123', x+'AnsiString')).IgnKindPtr(stDwarf2).IgnKind(stDwarf3Up)
          .IgnTypeName([], ALoc in [tlConst, tlClassConst]).IgnKind([], ALoc in [tlConst, tlClassConst]);
        t.Add(AName, p+'Ansi3'+e,      weAnsiStr('', x+'AnsiString'))              .IgnKindPtr(stDwarf2).IgnKind(stDwarf3Up)
          .IgnTypeName([], ALoc in [tlConst, tlClassConst]).IgnKind([], ALoc in [tlConst, tlClassConst]);
        t.Add(AName, p+'Ansi4'+e,      weAnsiStr(AChr1+'A'#0'B'#9'b'#10#13, x+'AnsiString'))  // cut off at #0 in dwarf2 / except tlConst, because it is a shortstring (kind of works by accident)
                 .IgnKindPtr(stDwarf2).IgnData(stDwarf2, not(ALoc in [tlConst, tlClassConst])).IgnKind(stDwarf3Up)
          .IgnTypeName([], ALoc in [tlConst, tlClassConst]).IgnKind([], ALoc in [tlConst, tlClassConst]);
        t.Add(AName, p+'Ansi5'+e,      weAnsiStr(AChr1+'bcdefghijAbcdefghijAbcdefghijAbcdefghijAbcdefghijAbcdefghijAbcdefghijAbcdefghijAbcdefghijAbcdefghijAbcdefghijAbcdefghijAbcdefghijAbcdefghijAbcdefghijAbcdefghijAbcdefghijAbcdefghijAbcdefghijAbcdefghijAbcdefghijAbcdefghijAbcdefghijAbcdefghijAbcdefghijAbcdefghijAbcdefghijAbcdefghijAbcdefghijAbcdefghijAbcdefghijAbcdefghijAbcdefghijAbcdefghijAbcdefghijAbcdefghij',
          x+'AnsiString') )    .IgnKindPtr(stDwarf2)                  .IgnKind(stDwarf3Up)
          .IgnTypeName([], ALoc in [tlConst, tlClassConst]).IgnKind([], ALoc in [tlConst, tlClassConst]);
      EndTxTypeIgnore;

        //TODO wePchar
      t.Add(AName, p+'PChar'+e,      wePointer(weAnsiStr('', 'Char'), x+'PChar'));
      BeginTxTypeIgnore;
        t.Add(AName, p+'PChar2'+e,     wePointer(weAnsiStr(AChr1+'abcd0123', 'Char'), x+'TPChr')).SkipIf(ALoc in [tlConst, tlClassConst]);

        // char by index
        // TODO: no typename => calculated value ?
        t.Add(AName, p+'String10'+e+'[2]',   weChar('b', '')).CharFromIndex.NotImplemented(stDwarf3up, tiPointerMath in AIgnFlags);
        t.Add(AName, p+'Ansi2'+e+'[2]',      weChar('a', '')).CharFromIndex;
        t.Add(AName, p+'PChar2'+e+'[1]',     weChar('a', '')).CharFromIndex.SkipIf(ALoc in [tlConst, tlClassConst]);
        t.Add(AName, p+'String10'+e+'[1]',   weChar(AChr1, '')).CharFromIndex.NotImplemented(stDwarf3up, tiPointerMath in AIgnFlags);
        t.Add(AName, p+'Ansi2'+e+'[1]',      weChar(AChr1, '')).CharFromIndex;
        t.Add(AName, p+'PChar2'+e+'[0]',     weChar(AChr1, '')).CharFromIndex.SkipIf(ALoc in [tlConst, tlClassConst]);


        t.Add(AName, p+'WideChar'+e,       weChar(AChr1, x+'Char')); // TODO: widechar
        t.Add(AName, p+'WideChar2'+e,      weChar(#0   , x+'Char'));
        t.Add(AName, p+'WideChar3'+e,      weChar(' '  , x+'Char'));

        BeginSkipConst; // tlConst => Only eval the watch. No tests
          t.Add(AName, p+'WideString1'+e,    weWideStr(Succ(AChr1), x+'WideString'))              .IgnKindPtr;
          t.Add(AName, p+'WideString2'+e,    weWideStr(AChr1+'abcX0123', x+'WideString'))         .IgnKindPtr;
          t.Add(AName, p+'WideString3'+e,    weWideStr('', x+'WideString'))                       .IgnKindPtr;
          t.Add(AName, p+'WideString4'+e,    weWideStr(AChr1+'A'#0'X'#9'b'#10#13, x+'WideString')).IgnKindPtr
            .IgnData(stDwarf2).IgnData([], Compiler.Version < 030100); // cut off at #0
          t.Add(AName, p+'WideString5'+e,    weWideStr(AChr1+'XcdefghijAbcdefghijAbcdefghijAbcdefghijAbcdefghijAbcdefghijAbcdefghijAbcdefghijAbcdefghijAbcdefghijAbcdefghijAbcdefghijAbcdefghijAbcdefghijAbcdefghijAbcdefghijAbcdefghijAbcdefghijAbcdefghijAbcdefghijAbcdefghijAbcdefghijAbcdefghijAbcdefghijAbcdefghijAbcdefghijAbcdefghijAbcdefghijAbcdefghijAbcdefghijAbcdefghijAbcdefghijAbcdefghijAbcdefghijAbcdefghijAbcdefghij',
            x+'TWStrTA'))                                                         .IgnKindPtr;

          t.Add(AName, p+'WideString2'+e+'[1]',  weWideChar(AChr1))     .CharFromIndex.IgnTypeName(stDwarf3Up);
          t.Add(AName, p+'WideString2'+e+'[2]',  weWideChar('a'))       .CharFromIndex.IgnTypeName(stDwarf3Up);
          t.Add(AName, p+'WideString5'+e+'[1]',  weWideChar(AChr1))     .CharFromIndex.IgnTypeName(stDwarf3Up);
          t.Add(AName, p+'WideString5'+e+'[2]',  weWideChar('X'))       .CharFromIndex.IgnTypeName(stDwarf3Up);
        // for tlClassConst the error should be something about "unknown type" due to absence of type info
        EndSkipConst;

        //TODO wePWidechar
        t.Add(AName, p+'PWideChar'+e,      wePointer(weWideStr('', 'WideChar'), 'PWideChar'));
        t.Add(AName, p+'PWideChar2'+e,     wePointer(weWideStr(AChr1+'abcX0123', 'WideChar'), 'TPWChr')).SkipIf(ALoc in [tlConst, tlClassConst]);

        BeginSkipConst;
          t.Add(AName, p+'UnicodeString1'+e,    weUniStr(Succ(AChr1), x+'UnicodeString'))              .IgnKindPtr(stDwarf2);
          t.Add(AName, p+'UnicodeString2'+e,    weUniStr(AChr1+'aBcX0123'))         .IgnKindPtr(stDwarf2);
          t.Add(AName, p+'UnicodeString3'+e,    weUniStr(''))                       .IgnKindPtr(stDwarf2);
          t.Add(AName, p+'UnicodeString4'+e,    weUniStr(AChr1+'B'#0'X'#9'b'#10#13)).IgnKindPtr(stDwarf2).IgnData(stDwarf2); // #00 terminated in dwarf2
          t.Add(AName, p+'UnicodeString5'+e,    weUniStr(AChr1+'YcdefghijAbcdefghijAbcdefghijAbcdefghijAbcdefghijAbcdefghijAbcdefghijAbcdefghijAbcdefghijAbcdefghijAbcdefghijAbcdefghijAbcdefghijAbcdefghijAbcdefghijAbcdefghijAbcdefghijAbcdefghijAbcdefghijAbcdefghijAbcdefghijAbcdefghijAbcdefghijAbcdefghijAbcdefghijAbcdefghijAbcdefghijAbcdefghijAbcdefghijAbcdefghijAbcdefghijAbcdefghijAbcdefghijAbcdefghijAbcdefghijAbcdefghij',
            'TUStrTA'))                                                         .IgnKindPtr(stDwarf2);

          //todo dwarf 3
          t.Add(AName, p+'UnicodeString2'+e+'[1]',    weWideChar(AChr1))       .CharFromIndex(stDwarf2).IgnTypeName(stDwarf3Up);
          t.Add(AName, p+'UnicodeString2'+e+'[2]',    weWideChar('a'))         .CharFromIndex(stDwarf2).IgnTypeName(stDwarf3Up);
          t.Add(AName, p+'UnicodeString5'+e+'[1]',    weWideChar(AChr1))       .CharFromIndex(stDwarf2).IgnTypeName(stDwarf3Up);
          t.Add(AName, p+'UnicodeString5'+e+'[2]',    weWideChar('Y'))         .CharFromIndex(stDwarf2).IgnTypeName(stDwarf3Up);

          t.Add(AName, p+'Variant_1'+e,      weMatch('71237',skVariant))
            .SkipIf(ALoc in [tlPointerAny])
            .IgnKind();
          t.Add(AName, p+'Variant_2'+e,      weMatch('True',skVariant))
            .SkipIf(ALoc in [tlPointerAny])
            .IgnKind();
        EndSkipConst;
      EndTxTypeIgnore;


      // TODO
      t.Add(AName, p+'ShortRec'+e,     weMatch(''''+AChr1+''', *''b'', *'''+AChr1+'''', skRecord))
        .SkipIf(ALoc in [tlClassConst])
        .SkipIf(ALoc = tlPointerAny);

    end;    // if not (tlReduced in AIgnFlags) then begin

    end; //  if tp1 in APartToRun then begin

    (* ******************************
       **********  PART 2  **********
       ****************************** *)

    if tp2 in APartToRun then begin

    if not (tlReduced in AIgnFlags) then begin
      BeginTxTypeIgnore;
      BeginSkipConst;   // class const only
        t.add(AName, p+'CharDynArray'+e,  weDynArray([]                                        )).SkipIf(ALoc in [tlPointer, tlClassConst]);
        t.add(AName, p+'CharDynArray2'+e, weDynArray(weChar(['N', AChr1, 'M'])                 )).SkipIf(ALoc in [tlConst, tlClassConst, tlPointer]);
        t.AddIndexFromPrevious(['0','1','2'], [0,1,2]);
        t.add(AName, p+'CharDynArray3'+e, weDynArray([],                        'TCharDynArray')).SkipIf(ALoc in [tlClassConst]);
        t.Add(AName, p+'CharDynArray4'+e, weDynArray(weChar(['J', AChr1, 'M']), 'TCharDynArray')).SkipIf(ALoc in [tlConst, tlClassConst]);
        t.AddIndexFromPrevious(['0','1','2'], [0,1,2]);

        t.Add(AName, p+'WCharDynArray'+e, weDynArray([]                        )).SkipIf(ALoc in [tlPointer, tlClassConst]);
        t.Add(AName, p+'WCharDynArray2'+e,weDynArray(weWideChar(['W', AChr1, 'M']) )).SkipIf(ALoc in [tlConst, tlClassConst,tlPointer]);
        t.AddIndexFromPrevious(['0','1','2'], [0,1,2]);
        t.Add(AName, p+'WCharDynArray3'+e,weDynArray([]                        )).SkipIf(ALoc in [tlClassConst]);
        t.Add(AName, p+'WCharDynArray4'+e,weDynArray(weWideChar(['K', AChr1, 'M']) )).SkipIf(ALoc in [tlConst, tlClassConst]);
        t.AddIndexFromPrevious(['0','1','2'], [0,1,2]);

        t.add(AName, p+'IntDynArray'+e,   weDynArray([]                                           )).SkipIf(ALoc in [tlPointer]);
        t.add(AName, p+'IntDynArray2'+e,  weDynArray(weInteger([11, 30+AOffs, 60])                )).SkipIf(ALoc in [tlConst,tlPointer]);
        t.AddIndexFromPrevious(['0','1','2'], [0,1,2]);
        t.add(AName, p+'IntDynArray3'+e,  weDynArray([],                            'TIntDynArray'));
        t.Add(AName, p+'IntDynArray4'+e,  weDynArray(weInteger([12, 30+AOffs, 60]), 'TIntDynArray')).SkipIf(ALoc in [tlConst]);
        t.AddIndexFromPrevious(['0','1','2'], [0,1,2]);

        t.add(AName, p+'IntDynArray5'+e,  weDynArray([],                            'TIntDynArray'));

        t.add(AName, p+'AnsiDynArray'+e,  weDynArray([]                                                     )).SkipIf(ALoc in [tlPointer]);
        t.add(AName, p+'AnsiDynArray2'+e, weDynArray(weAnsiStr(['N123', AChr1+'ab', 'M'#9])                 )).SkipIf(ALoc in [tlConst,tlPointer]);
    // TODO: currently gets skPointer instead of skAnsiString (dwarf 2)
    //    t.AddIndexFromPrevious(['0','1','2'], [0,1,2]);
        t.add(AName, p+'AnsiDynArray3'+e, weDynArray([],                                     'TAnsiDynArray'));
        t.Add(AName, p+'AnsiDynArray4'+e, weDynArray(weAnsiStr(['J123', AChr1+'ab', 'M'#9]), 'TAnsiDynArray')).SkipIf(ALoc in [tlConst]);
    // TODO: currently gets skPointer instead of skAnsiString (dwarf 2)
    //    t.AddIndexFromPrevious(['0','1','2'], [0,1,2]);

        t.add(AName, p+'ShortStrDynArray'+e,  weDynArray([]                                                          )).SkipIf(ALoc in [tlPointer]);
        t.add(AName, p+'ShortStrDynArray2'+e, weDynArray(weShortStr(['N123', AChr1+'ac', 'M'#9], 'ShortStr10')                     ))
          .SkipIf(ALoc in [tlConst,tlPointer]);
        t.AddIndexFromPrevious(['0','1','2'], [0,1,2]);
        t.add(AName, p+'ShortStrDynArray3'+e, weDynArray([],                                      'TShortStrDynArray'));
        t.Add(AName, p+'ShortStrDynArray4'+e, weDynArray(weShortStr(['J123', AChr1+'ac', 'M'#9], 'ShortStr10'), 'TShortStrDynArray'))
          .SkipIf(ALoc = tlConst);
        t.AddIndexFromPrevious(['0','1','2'], [0,1,2]);
      EndSkipConst(True);
      EndTxTypeIgnore;
    end; //     if not (tlReduced in AIgnFlags) then begin


    BeginTxTypeIgnore;
    BeginSkipConst;
      t.Add(AName, p+'DynDynArrayInt'+e, weDynArray([
          weDynArray(weInteger([11+AOffs,0,-22])),
          weDynArray(weInteger([110+AOffs])),
          weDynArray(weInteger([11+AOffs,0,-22])),
          weDynArray(weInteger([])),
          weDynArray(weInteger([11,12,11,10]))
        ], 'TDynDynArrayInt'));

      t.Add(AName, p+'DynDynArrayInt'+e+'[0]', weDynArray(weInteger([11+AOffs,0,-22])) );
      t.Add(AName, p+'DynDynArrayInt'+e+'[1]', weDynArray(weInteger([110+AOffs])) );
      t.Add(AName, p+'DynDynArrayInt'+e+'[2]', weDynArray(weInteger([11+AOffs,0,-22])) );
      t.Add(AName, p+'DynDynArrayInt'+e+'[3]', weDynArray(weInteger([])) );
      t.Add(AName, p+'DynDynArrayInt'+e+'[4]', weDynArray(weInteger([11,12,11,10])) );

      t.Add(AName, p+'DynDynArrayInt2'+e+'[0]', weDynArray(weInteger([11+AOffs,0,-22])) );
      t.Add(AName, p+'DynDynArrayInt2'+e+'[1]', weDynArray(weInteger([110+AOffs])) );
      t.Add(AName, p+'DynDynArrayInt2'+e+'[2]', weDynArray(weInteger([11+AOffs,0,-22])) );
      t.Add(AName, p+'DynDynArrayInt2'+e+'[3]', weDynArray(weInteger([])) );
      t.Add(AName, p+'DynDynArrayInt2'+e+'[4]', weDynArray(weInteger([11,12,11,10])) );


/////    t.Add(AName, p+'pre__FiveDynArray'+e,  weStatArray(weChar([AChr1, 'b', AChr1, 'B', 'c'])                  ))
t.Add(AName, p+'FiveDynArray'+e,            weMatch('.*',skArray));
t.Add(AName, p+'FiveDynArray'+e+'[0]',      weMatch('.*',skRecord));
//    t.Add(AName, p+'FiveDynArray'+e,            we());
//    t.Add(AName, p+'FiveDynArrayPack'+e,        we());
//    t.Add(AName, p+'FivePackDynArray'+e,        we());
//    t.Add(AName, p+'FivePackDynArrayPack'+e,    we());
//    t.Add(AName, p+'RecFiveDynArray'+e,         we());
//    t.Add(AName, p+'RecFiveDynPackArray'+e,     we());
//    t.Add(AName, p+'RecFivePackDynArray'+e,     we());
//    t.Add(AName, p+'RecFivePackDynPackArray'+e, we());
//    t.Add(AName, p+'FiveDynArray2'+e,           we());
//    t.Add(AName, p+'FiveDynArrayPack2'+e,       we());
//    t.Add(AName, p+'FivePackDynArray2'+e,       we());
//    t.Add(AName, p+'FivePackDynArrayPack2'+e,   we());

    EndSkipConst;


    BeginSkipConst; // class const only
      t.Add(AName, p+'CharStatArray'+e,  weStatArray(weChar([AChr1, 'b', AChr1, 'B', 'c'])                  ))
        .SkipIf(ALoc = tlParam).SkipIf(ALoc = tlPointer);
      t.Add(AName, p+'CharStatArray2'+e, weStatArray(weChar([AChr1, 'c', AChr1, 'B', 'c']), 'TCharStatArray'));

  if  (tlReduced in AIgnFlags) then exit;

      t.Add(AName, p+'WCharStatArray'+e, weStatArray(weChar([AChr1, 'b', AChr1, 'B', 'd'])                   ))
        .SkipIf(ALoc = tlParam).SkipIf(ALoc = tlPointer);
      t.Add(AName, p+'WCharStatArray2'+e,weStatArray(weChar([AChr1, 'c', AChr1, 'B', 'd']), 'TwCharStatArray'));

      t.Add(AName, p+'IntStatArray'+e,  weStatArray(weInteger([-1, 300+AOffs, 2, 0, 1])                 ))
        .SkipIf(ALoc = tlParam).SkipIf(ALoc = tlPointer);
      t.Add(AName, p+'IntStatArray2'+e, weStatArray(weInteger([-2, 200+AOffs, 2, 0, 1]), 'TIntStatArray'));

      t.Add(AName, p+'AnsiStatArray'+e,  weStatArray(weAnsiStr([AChr1, 'b123', AChr1+'ab', 'B', 'cdef'#9])                  ))
        .SkipIf(ALoc = tlParam).SkipIf(ALoc = tlPointer);
      t.Add(AName, p+'AnsiStatArray2'+e, weStatArray(weAnsiStr([AChr1, 'c123', AChr1+'ad', 'D', 'cxx'#9] ), 'TAnsiStatArray'));

      t.Add(AName, p+'ShortStrStatArray'+e,  weStatArray(weShortStr([AChr1, 'b123', AChr1+'ab', 'C', 'cdef'#9])                  ))
        .SkipIf(ALoc = tlParam).SkipIf(ALoc = tlPointer);
      t.Add(AName, p+'ShortStrStatArray2'+e, weStatArray(weShortStr([AChr1, 'c123', AChr1+'ad', 'C', 'cxx'#9] ), 'TShortStrStatArray'));

//      t.Add(AName, p+'FiveStatArray{e}             _O2_ TFiveStatArray            _EQ_ ((a:-9;b:44), (a:-8-ADD;b:33), (a:-7;b:22));          //@@ _pre3_FiveStatArray;
//      t.Add(AName, p+'FiveStatArrayPack{e}         _O2_ TFiveStatArrayPack        _EQ_ ((a:-9;b:44), (a:-8-ADD;b:33), (a:-7;b:22));          //@@ _pre3_FiveStatArrayPack;
//      t.Add(AName, p+'FivePackStatArray{e}         _O2_ TFivePackStatArray        _EQ_ ((a:-9;b:44), (a:-8-ADD;b:33), (a:-7;b:22));          //@@ _pre3_FivePackStatArray;
//      t.Add(AName, p+'FivePackStatArrayPack{e}     _O2_ TFivePackStatArrayPack    _EQ_ ((a:-9;b:44), (a:-8-ADD;b:33), (a:-7;b:22));          //@@ _pre3_FivePackStatArrayPack;
//      t.Add(AName, p+'RecFiveStatArray{e}          _O2_ TRecFiveStatArray         _EQ_ ((a:-9;b:44), (a:-8-ADD;b:33), (a:-7;b:22));          //@@ _pre3_RecFiveStatArray;
//      t.Add(AName, p+'RecFiveStatPackArray{e}      _O2_ TRecFiveStatPackArray     _EQ_ ((a:-9;b:44), (a:-8-ADD;b:33), (a:-7;b:22));          //@@ _pre3_RecFiveStatPackArray;
//      t.Add(AName, p+'RecFivePackStatArray{e}      _O2_ TRecFivePackStatArray     _EQ_ ((a:-9;b:44), (a:-8-ADD;b:33), (a:-7;b:22));          //@@ _pre3_RecFivePackStatArray;
//      t.Add(AName, p+'RecFivePackStatPackArray{e}  _O2_ TRecFivePackStatPackArray _EQ_ ((a:-9;b:44), (a:-8-ADD;b:33), (a:-7;b:22));          //@@ _pre3_RecFivePackStatPackArray;

//TODO: element by index

      t.Add(AName, p+'ArrayEnum1'+e, weStatArray(weCardinal([500+n,701,702,703], 'WORD', SIZE_2)  ))
        .SkipIf(ALoc = tlParam).SkipIf(ALoc = tlPointer);
      t.AddIndexFromPrevious(['EnVal1','EnVal2','EnVal3','EnVal4',
       'gvEnum', 'gvEnumA', 'gvEnum1',  'gcEnum', 'gcEnumA', 'gcEnum1',   p+'Enum'+e, p+'EnumA'+e, p+'Enum1'+e],
       [0,1,2,3,  2,0,1,  2,0,1,  2,0,1]);
      t.Add(AName, p+'ArrayEnum3'+e, weStatArray(weCardinal([200+n,701,702,703], 'WORD', SIZE_2), 'TArrayEnum'));
      t.AddIndexFromPrevious(['EnVal1','EnVal2','EnVal3','EnVal4',
       'gvEnum', 'gvEnumA', 'gvEnum1',  'gcEnum', 'gcEnumA', 'gcEnum1',   p+'Enum'+e, p+'EnumA'+e, p+'Enum1'+e],
       [0,1,2,3,  2,0,1,  2,0,1,  2,0,1]);

      t.Add(AName, p+'ArrayEnumSub1'+e, weStatArray(weCardinal([600+n,801], 'WORD', SIZE_2)  ))
        .SkipIf(ALoc = tlParam).SkipIf(ALoc = tlPointer);
      t.AddIndexFromPrevious(['EnVal1','EnVal2',
       'gvEnumA', 'gvEnum1',  'gcEnumA', 'gcEnum1',   p+'EnumA'+e, p+'Enum1'+e],
       [0,1,  0,1,  0,1,  0,1]);
      t.Add(AName, p+'ArrayEnumSub3'+e, weStatArray(weCardinal([100+n,801], 'WORD', SIZE_2), 'TArrayEnumSub'));
      t.AddIndexFromPrevious(['EnVal1','EnVal2',
       'gvEnumA', 'gvEnum1',  'gcEnumA', 'gcEnum1',   p+'EnumA'+e, p+'Enum1'+e],
       [0,1,  0,1,  0,1,  0,1]);

      t.Add(AName, p+'ArrayEnum2'+e, weStatArray(weCardinal([300+n,701,702,703], 'WORD', SIZE_2)  ))
        .SkipIf(ALoc = tlParam).SkipIf(ALoc = tlPointer);
      t.AddIndexFromPrevious(['EnVal1','EnVal2','EnVal3','EnVal4',
       'gvEnum', 'gvEnumA', 'gvEnum1',  'gcEnum', 'gcEnumA', 'gcEnum1',   p+'Enum'+e, p+'EnumA'+e, p+'Enum1'+e],
       [0,1,2,3,  2,0,1,  2,0,1,  2,0,1]);
      t.Add(AName, p+'ArrayEnum4'+e, weStatArray(weCardinal([800+n,701,702,703], 'WORD', SIZE_2), 'TArrayEnumElem'));
      t.AddIndexFromPrevious(['EnVal1','EnVal2','EnVal3','EnVal4',
       'gvEnum', 'gvEnumA', 'gvEnum1',  'gcEnum', 'gcEnumA', 'gcEnum1',   p+'Enum'+e, p+'EnumA'+e, p+'Enum1'+e],
       [0,1,2,3,  2,0,1,  2,0,1,  2,0,1]);

      t.Add(AName, p+'ArrayEnumSub2'+e, weStatArray(weCardinal([400+n,801], 'WORD', SIZE_2)  ))
        .SkipIf(ALoc = tlParam).SkipIf(ALoc = tlPointer);
      t.AddIndexFromPrevious(['EnVal1','EnVal2',
       'gvEnumA', 'gvEnum1',  'gcEnumA', 'gcEnum1',   p+'EnumA'+e, p+'Enum1'+e],
       [0,1,  0,1,  0,1,  0,1]);
      t.Add(AName, p+'ArrayEnumSub4'+e, weStatArray(weCardinal([700+n,801], 'WORD', SIZE_2), 'TArrayEnumSubElem'));
      t.AddIndexFromPrevious(['EnVal1','EnVal2',
       'gvEnumA', 'gvEnum1',  'gcEnumA', 'gcEnum1',   p+'EnumA'+e, p+'Enum1'+e],
       [0,1,  0,1,  0,1,  0,1]);


      t.Add(AName, p+'Enum'+e, weEnum('EnVal3', 'TEnum'));
      t.Add(AName, p+'Enum1'+e, weEnum('EnVal2', 'TEnumSub'));
      t.Add(AName, p+'Enum2'+e, weEnum('EnVal21', 'TEnum2'));
      t.Add(AName, p+'Enum3'+e, weEnum('EnVal25', 'TEnum2'));

      t.Add(AName, p+'EnumX0a'+e, weEnum('EnXVal01', 'TEnumX0'));
      t.Add(AName, p+'EnumX0b'+e, weEnum('EnXVal04', 'TEnumX0'));
      t.Add(AName, p+'EnumX1a'+e, weEnum('EnXVal11 = -3', 'TEnumX1'));
      t.Add(AName, p+'EnumX1b'+e, weEnum('EnXVal14 = 10', 'TEnumX1'));
      t.Add(AName, p+'EnumX1Aa'+e, weEnum('EnXValA11 = 1', 'TEnumX1a'));
      t.Add(AName, p+'EnumX1Ab'+e, weEnum('EnXValA14 = 190', 'TEnumX1a'))
      .IgnAll(stDwarf2, Compiler.Version >= 030301);
      t.Add(AName, p+'EnumX2a'+e, weEnum('EnXVal21', 'TEnumX2'));
      t.Add(AName, p+'EnumX2b'+e, weEnum('EnXVal24', 'TEnumX2'));

//      t.Add(AName, 'EnVal2', weMatch('xxx', skEnumValue));

      t.Add(AName, p+'Enum16'+e, weEnum('ExVal23', 'TEnum16'));
      t.Add(AName, p+'Enum16A'+e, weEnum('ExValX5', 'TEnum16'));

      t.Add(AName, p+'Set'+e, weSet(['EnVal2', 'EnVal4'], 'TSet')).Skip([stDwarf]);
      t.Add(AName, p+'Set2'+e, weSet(['EnVal1', 'EnVal4'])).Skip([stDwarf])
        .SkipIf(ALoc = tlParam).SkipIf(ALoc = tlPointer);

      t.Add(AName, p+'Set4'+e, weSet(['E4Val02', 'E4Val0A'], 'TSet4')).Skip([stDwarf]);
      t.Add(AName, p+'Set5'+e, weSet(['E5Val02', 'E5Val12'], 'TSet5')).Skip([stDwarf]);
      t.Add(AName, p+'Set6'+e, weSet(['E6Val02', 'E6Val1A'], 'TSet6')).Skip([stDwarf]);
      t.Add(AName, p+'Set7'+e, weSet(['E7Val02', 'E7Val3A'], 'TSet7')).Skip([stDwarf]);
      t.Add(AName, p+'Set8'+e, weSet(['E8Val02', 'E8Val5B'], 'TSet8')).Skip([stDwarf]);

      t.Add(AName, p+'SmallSet'+e, weSet(['22', '24', '25'], 'TSmallRangeSet')).Skip([stDwarf])
        .SkipIf(ALoc = tlParam).SkipIf(ALoc = tlPointer);
      t.Add(AName, p+'SmallSet2'+e, weSet(['21', '24', '25'])).Skip([stDwarf])
        .SkipIf(ALoc = tlParam).SkipIf(ALoc = tlPointer);

    EndSkipConst(True);
    EndTxTypeIgnore;

    end; //  if tp2 in APartToRun then begin


    if tp3 in APartToRun then begin
    (* ******************************
       **********  PART 3  **********
       ****************************** *)
    BeginTxTypeIgnore;
    BeginSkipConst;  // class const only


      // bitpacked
      t.Add(AName, p+'BitPackBoolArray'+e,     weStatArray(weBool([True, False, True, True])   ));
      t.AddIndexFromPrevious(['0','1','2','3'], [0,1,2,3]);
      t.Add(AName, p+'BitPackTinyArray'+e,     weStatArray(weCardinal([1, 0, 3, 2], 'TTinyRange', SIZE_1)   ));
      t.AddIndexFromPrevious(['0','1','2','3'], [0,1,2,3]);
      t.Add(AName, p+'BitPackTinyNegArray'+e,  weStatArray(weInteger([2, -2, 0, -1], #1, SIZE_1)   ));
      t.AddIndexFromPrevious(['0','1','2','3'], [0,1,2,3]);
      t.Add(AName, p+'BitPackEnumArray'+e,  weStatArray(weEnum(['EnVal3', 'EnVal1', 'EnVal2', 'EnVal3'])   ));
      t.AddIndexFromPrevious(['0','1','2','3'], [0,1,2,3]);
      t.Add(AName, p+'BitPackEnum3Array'+e,  weStatArray(weEnum(['EnVal32', 'EnVal32', 'EnVal31', 'EnVal32'])   ));
      t.AddIndexFromPrevious(['0','1','2','3'], [0,1,2,3]);
      t.Add(AName, p+'BitPackSetArray'+e,  weStatArray([ weSet(['EnVal1', 'EnVal3']), weSet([]), weSet(['EnVal3']), weSet(['EnVal1'])]  ))
        .Skip([stDwarf]);
      t.AddIndexFromPrevious(['0','1','2','3'], [0,1,2,3]);
      t.Add(AName, p+'BitPackSet3Array'+e,  weStatArray([weSet(['EnVal31', 'EnVal32']), weSet([]), weSet(['EnVal31']), weSet(['EnVal32'])]  ))
        .Skip([stDwarf]);
      t.AddIndexFromPrevious(['0','1','2','3'], [0,1,2,3]);


      t.Add(AName, p+'BitPackBoolArray2'+e,     weStatArray([
         weStatArray(weBool([True, False, True])),
         weStatArray(weBool([False, True, True]))
      ]));
      t.AddIndexFromPrevious(['0','1'], [0,1]);
      t.AddIndexFromPrevious(['0','1','2'], [0,1,2]);
      t.Add(AName, p+'BitPackTinyArray2'+e,     weStatArray([
          weStatArray(weCardinal([1, 0, 3], 'TTinyRange', SIZE_1)),
          weStatArray(weCardinal([2, 3, 0], 'TTinyRange', SIZE_1))
      ]));
      t.AddIndexFromPrevious(['0','1'], [0,1]);
      t.AddIndexFromPrevious(['0','1','2'], [0,1,2]);
      t.Add(AName, p+'BitPackTinyNegArray2'+e,  weStatArray([
          weStatArray(weInteger([2, -2, 0], #1, SIZE_1)),
          weStatArray(weInteger([1, 0, -1], #1, SIZE_1))
      ]));
      t.AddIndexFromPrevious(['0','1'], [0,1]);
      t.AddIndexFromPrevious(['0','1','2'], [0,1,2]);
      t.Add(AName, p+'BitPackEnumArray2'+e,  weStatArray([
          weStatArray(weEnum(['EnVal3', 'EnVal1', 'EnVal2'])),
          weStatArray(weEnum(['EnVal1', 'EnVal4', 'EnVal2']))
      ]));
      t.AddIndexFromPrevious(['0','1'], [0,1]);
      t.AddIndexFromPrevious(['0','1','2'], [0,1,2]);
      t.Add(AName, p+'BitPackEnum3Array2'+e,  weStatArray([
          weStatArray(weEnum(['EnVal32', 'EnVal32', 'EnVal31'])),
          weStatArray(weEnum(['EnVal31', 'EnVal31', 'EnVal32']))
      ]));
      t.AddIndexFromPrevious(['0','1'], [0,1]);
      t.AddIndexFromPrevious(['0','1','2'], [0,1,2]);
      //t.Add(AName, p+'BitPackEnumSet'+e,  weStatArray(weSet(['EnVal3', 'EnVal1']), weSet([]), weSet(['EnVal3']), weSet(['EnVal1'])  ));
      //t.AddIndexFromPrevious(['0','1'], [0,1]);
      //t.Add(AName, p+'BitPackEnumSet3'+e,  weStatArray(weSet(['EnVal31', 'EnVal32']), weSet([]), weSet(['EnVal31']), weSet(['EnVal32'])  ));
      //t.AddIndexFromPrevious(['0','1'], [0,1]);


      t.Add(AName, p+'BitPackBoolRecord'+e,     weRecord([
        weBool(True).N('a'), weBool(False).N('b'), weBool(True).N('c'), weBool(True).N('d'), weBool(False).N('e')
      ], 'TBitPackBoolRecord')   );
      t.AddMemberFromPrevious();
      t.Add(AName, p+'BitPackTinyRecord'+e,     weRecord([
        weCardinal(1, 'TTinyRange', SIZE_1).N('a'),
        weCardinal(1, 'TTinyRange', SIZE_1).N('b'),
        weCardinal(0, 'TTinyRange', SIZE_1).N('c'),
        weCardinal(3, 'TTinyRange', SIZE_1).N('d'),
        weCardinal(0, 'TTinyRange', SIZE_1).N('e')
      ], 'TBitPackTinyRecord')   );
      t.AddMemberFromPrevious();
      t.Add(AName, p+'BitPackTinyNegRecord'+e,     weRecord([
        weInteger( 3, #1, SIZE_1).N('a'),
        weInteger(-2, #1, SIZE_1).N('b'),
        weInteger(-1, #1, SIZE_1).N('c'),
        weInteger( 0, #1, SIZE_1).N('d'),
        weInteger( 1, #1, SIZE_1).N('e')
      ], 'TBitPackTinyNegRecord')   );
      t.AddMemberFromPrevious();
      t.Add(AName, p+'BitPackEnumRecord'+e,     weRecord([
        weEnum('EnVal3').N('a'), weEnum('EnVal1').N('b'), weEnum('EnVal2').N('c'), weEnum('EnVal2').N('d'), weEnum('EnVal1').N('e')
      ], 'TBitPackEnumRecord')   );
      t.AddMemberFromPrevious();
      t.Add(AName, p+'BitPackEnum3Record'+e,     weRecord([
        weEnum('EnVal31').N('a'), weEnum('EnVal32').N('b'), weEnum('EnVal31').N('c'), weEnum('EnVal31').N('d'), weEnum('EnVal32').N('e')
      ], 'TBitPackEnum3Record')   );
      t.AddMemberFromPrevious();
      t.Add(AName, p+'BitPackSetRecord'+e,     weRecord([
        weSet(['EnVal3']).N('a'), weSet([]).N('b'), weSet(['EnVal1','EnVal2']).N('c'), weSet(['EnVal2']).N('d'), weSet(['EnVal1','EnVal3']).N('e')
      ], 'TBitPackSetRecord')   )
        .Skip([stDwarf]);
      t.AddMemberFromPrevious();
      t.Add(AName, p+'BitPackSet3Record'+e,     weRecord([
        weSet(['EnVal31']).N('a'), weSet([]).N('b'), weSet(['EnVal31','EnVal32']).N('c'), weSet(['EnVal32']).N('d'), weSet(['EnVal31']).N('e')
      ], 'TBitPackSet3Record')   )
        .Skip([stDwarf]);
      t.AddMemberFromPrevious();

      t.Add(AName, p+'BitPackBoolArrayRecord'+e,     weRecord([
         weStatArray(weBool([True, False, True, True])).N('a'),
         weStatArray(weBool([False, True, True, False])).N('b')
      ], 'TBitPackBoolArrayRecord')   );
      t.AddMemberFromPrevious();
      t.AddIndexFromPrevious(['0','1','2','3'], [0,1,2,3]);

      t.Add(AName, p+'BitPackTinyArrayRecord'+e,     weRecord([
          weStatArray(weCardinal([1, 0, 3, 2], 'TTinyRange', SIZE_1)).N('a'),
          weStatArray(weCardinal([2, 3, 0, 1], 'TTinyRange', SIZE_1)).N('b')
      ], 'TBitPackTinyArrayRecord')   );
      t.AddMemberFromPrevious();
      t.AddIndexFromPrevious(['0','1','2','3'], [0,1,2,3]);
      t.Add(AName, p+'BitPackTinyNegArrayRecord'+e,     weRecord([
          weStatArray(weInteger([2, -2, 0, -1], #1, SIZE_1)).N('a'),
          weStatArray(weInteger([1, 0, -1, 2],  #1, SIZE_1)).N('b')
      ], 'TBitPackTinyNegArrayRecord')   );
      t.AddMemberFromPrevious();
      t.AddIndexFromPrevious(['0','1','2','3'], [0,1,2,3]);


      t.Add(AName, p+'FpDbgValueSize'+e, weRecord([
        weInteger(0, 'Int64',    SIZE_8).N('Size'),
        weInteger(2, 'TBitSize', SIZE_1).N('BitSize')
      ], 'TFpDbgValueSize')   )
        .Skip([stDwarf]).SkipIf(ALoc in [tlConst, tlPointerAny]);
      t.AddMemberFromPrevious();



      t.Add(AName, p+'FiveRec'+e,            weMatch('a *:.*b *: *44',skRecord))
        .SkipIf(ALoc = tlPointerAny);
      t.Add(AName, p+'FiveRec'+e,     weRecord([weInteger(-22-n).N('a'), weInteger(44).N('b')], 'TRecordFive'))
        .SkipIf(ALoc = tlPointerAny);

        // FDynInt  // nil for tlconst
      t.Add(AName, p+'Instance1'+e,   weClass([weInteger(22+n).N('FInt'), weAnsiStr(AChr1+'T').N('FAnsi')], 'TClass1'))
        .AddFlag(ehMissingFields)
        .SkipIf(ALoc in [tlConst, tlPointerAny]);

      t.Add(AName, p+'Obj3'+e,   weObject([weInteger(-22).N('a'), weInteger(44).N('b'), weInteger(4000+n).N('c')],
        'TObject3Int64'))
        .Skip(stDwarf3Up)  // fixed in fpc 3.3 with .SkipKind since it reports skRecord
        .IgnKind([], Compiler.Version < 029900)
        .SkipIf(ALoc = tlPointerAny);
      t.Add(AName, p+'Obj3Ex'+e,   weObject([weInteger(-22).N('a'), weInteger(44).N('b'), weInteger(4100+n).N('c'), weInteger(555).N('d')],
        'TObject3Int64Ex'))
        .Skip(stDwarf3Up)  // fixed in fpc 3.3 with .SkipKind since it reports skRecord
        .SkipIf(ALoc = tlPointerAny);
      t.Add(AName, p+'Obj3C'+e,   weObject([weInteger(22).N('a'), weInteger(44).N('b'), weInteger(4200+n).N('c')],
        'TObjectCreate3Int64'))
        .AddFlag(ehMissingFields)
        .Skip(stDwarf3Up)  // fixed in fpc 3.3
        .SkipIf(ALoc in [tlConst, tlPointerAny]);
      t.Add(AName, p+'Obj3ExC'+e,   weObject([weInteger(22).N('a'), weInteger(44).N('b'), weInteger(4300+n).N('c'), weInteger(655).N('d')],
        'TObjectCreate3Int64Ex'))
        .AddFlag(ehMissingFields)
        .Skip(stDwarf3Up)  // fixed in fpc 3.3
        .SkipIf(ALoc in [tlConst, tlPointerAny]);




      t.Add(AName, p+'IntfUnknown1'+e, weMatch('.?', skInterface)) //.Skip(); // only run eval / do not crash
        .SkipIf(ALoc = tlPointerAny);
      t.Add(AName, p+'IntfUnknown'+e, weMatch('nil', skInterface)); //.Skip(); // only run eval / do not crash


StartIdx := t.Count; // tlConst => Only eval the watch. No tests
      t.Add(AName, p+'SomeFunc1Ref'+e,         weMatch('\$[0-9A-F]+ = SomeFunc1: *function *\(SOMEVALUE, Foo: LONGINT; Bar: Word; x: Byte\): *BOOLEAN', skFunctionRef) );
      t.Add(AName, '@'+p+'SomeFunc1Ref'+e,     wePointer('^TFunc1') ).AddFlag(ehIgnPointerDerefData);
      t.Add(AName, p+'SomeProc1Ref'+e,         weMatch('\$[0-9A-F]+ = SomeProc1: *procedure *\(\) *$', skProcedureRef) );
      t.Add(AName, p+'SomeMeth1Ref'+e,         weMatch('Proc *: *\$[0-9A-F]+ *= *TMyBaseClass\.SomeMeth1.*: *TMeth1;[\s\r\n]*Self.*:.*', skRecord) );
      t.Add(AName, p+'SomeMeth1Ref'+e+'.Proc', weMatch('\$[0-9A-F]+ = TMyBaseClass\.SomeMeth1: *function *\(.*AVal.*\): *BOOLEAN', skFunctionRef) );
for i := StartIdx to t.Count-1 do
  t.Tests[i].SkipIf(ALoc in [tlConst, tlPointerAny]);



    EndSkipConst(True);
    EndTxTypeIgnore;



    // Trigger a search through everything
    t.Add('NotExistingFooBar123_X', weInteger(0))^.AddFlag(ehExpectError);

  end; //  if tp3 in APartToRun then begin
  end;

var
  ExeName: String;
  t: TWatchExpectationList;
  Src: TCommonSource;
  BrkPrg,
    BrkMethFoo, BrkBaseMethFoo,
    BaseObjMethFoo, ObjMethFoo: TDBGBreakPoint;
  BrkFooBegin, BrkFoo, BrkFooVar, BrkFooVarBegin, BrkFooConstRef:
    array [TTestPart] of TDBGBreakPoint;
  c, i: Integer;
  UseParts: Boolean;
  tp: TTestPart;
  tpS: TTestParts;
begin
  if SkipTest then exit;
  if not TestControlCanTest(ControlTestWatchValue) then exit;
  t := nil;

  UseParts := pos('llvm', Compiler.FullName) > 0;

  Src := GetCommonSourceFor('WatchesValuePrg.pas');
  if UseParts then
    TestCompile(Src, ExeName, '_p3')
  else
    TestCompile(Src, ExeName, '', ' -dSINGLE_BIG_FUNC ');

  AssertTrue('Start debugger', Debugger.StartDebugger(AppDir, ExeName));

  try
    t := TWatchExpectationList.Create(Self);
    t.AcceptSkSimple := [skInteger, skCardinal, skBoolean, skChar, skFloat,
      skString, skAnsiString, skCurrency, skVariant, skWideString,
      skInterface, skEnumValue];
    t.AddTypeNameAlias('integer', 'integer|longint');
    t.AddTypeNameAlias('Char', 'Char|AnsiChar');
    t.AddTypeNameAlias('ShortStr255', 'ShortStr255|ShortString');
    t.AddTypeNameAlias('TEnumSub', 'TEnum|TEnumSub');


    BrkPrg         := Debugger.SetBreakPoint(Src, 'Prg');
    if UseParts then begin
      for tp in TTestPart do begin
        BrkFooBegin   [tp] := Debugger.SetBreakPoint(Src, 'FooBegin'+inttostr(ord(tp)+1));
        BrkFoo        [tp] := Debugger.SetBreakPoint(Src, 'Foo'+inttostr(ord(tp)+1));
        BrkFooVarBegin[tp] := Debugger.SetBreakPoint(Src, 'FooVarBegin'+inttostr(ord(tp)+1));
        BrkFooVar     [tp] := Debugger.SetBreakPoint(Src, 'FooVar'+inttostr(ord(tp)+1));
        BrkFooConstRef[tp] := Debugger.SetBreakPoint(Src, 'FooConstRef'+inttostr(ord(tp)+1));
      end;
    end
    else begin
      BrkFooBegin   [tp1] := Debugger.SetBreakPoint(Src, 'FooBegin');
      BrkFoo        [tp1] := Debugger.SetBreakPoint(Src, 'Foo');
      BrkFooVarBegin[tp1] := Debugger.SetBreakPoint(Src, 'FooVarBegin');
      BrkFooVar     [tp1] := Debugger.SetBreakPoint(Src, 'FooVar');
      BrkFooConstRef[tp1] := Debugger.SetBreakPoint(Src, 'FooConstRef');
    end;
    BrkMethFoo     := Debugger.SetBreakPoint(Src, 'MethFoo');  // call with TMyClass
    BrkBaseMethFoo := Debugger.SetBreakPoint(Src, 'BaseMethFoo'); // call with TMyClass

    if Compiler.Version >= 030300 then begin
      BaseObjMethFoo := Debugger.SetBreakPoint(Src, 'BaseObjMethFoo');
      ObjMethFoo     := Debugger.SetBreakPoint(Src, 'ObjMethFoo');
    end;

    AssertDebuggerNotInErrorState;

    (* ************ Nested Functions ************* *)

    RunToPause(BrkPrg);
    t.Clear;

//t.Add('gvBitPackBoolArray',     weStatArray(weBool([True, False, True, True])   ));
  //t.Add('MyClass2.cl_c_Byte',     weStatArray(weBool([True, False, True, True])   ));
  //t.Add('MyClass2.cl_c_ShortRec',     weStatArray(weBool([True, False, True, True])   ));
//t.EvaluateWatches;
//t.CheckResults;
//exit;

    t.Add('U8Data1',    weAnsiStr(#$E2#$89#$A7, 'Utf8String'))
    //t.Add('U8Data1',    weAnsiStr(''''#$2267'''', 'Utf8String'))
     .IgnData([], Compiler.HasFlag('Dwarf2'))
     .NoCharQuoting
     .IgnTypeName.IgnKind
     .skipIf(Compiler.Version < 030000);
    t.Add('U8Data2',    weAnsiStr(#$E2#$89#$A7'X', 'Utf8String'))
    //t.Add('U8Data2',    weAnsiStr(''''#$2267'X''', 'Utf8String'))
     .IgnData([], Compiler.HasFlag('Dwarf2'))
     .NoCharQuoting
     .IgnTypeName.IgnKind
     .skipIf(Compiler.Version < 030000);

    t.Add('SomeFunc1',    weMatch('^function *\(SOMEVALUE, Foo: LONGINT; Bar: Word; x: Byte\): *BOOLEAN *AT *\$[0-9A-F]+', skFunction) );
    t.Add('SomeProc1',    weMatch('^procedure *\(\) *AT *\$[0-9A-F]+', skProcedure) );
    t.Add('@SomeFunc1',   weMatch('\^.*function.*\$[0-9A-F]+'{' = SomeFunc1'}, skPointer {skFunctionRef}) );
    t.Add('@SomeProc1',   weMatch('\^.*procedure.*\$[0-9A-F]+'{' = SomeFunc1'}, skPointer {skProcedureRef}) );

    // TODO: TClass1 must not contain "<unknown>"
    // '    _vptr$TOBJECT: Pointer'
    t.Add( 'TClass1',       weMatch('type class\(TObject\).*FInt: (integer|longint).*end', skType)).AddFlag(ehNoTypeInfo);
    t.Add( 'TClass1',       weMatch('type class\(TObject\).*_vptr\$TOBJECT: *Pointer.*end', skType)).AddFlag(ehNoTypeInfo);
    t.Add( 'TFunc1',        weMatch('type function *\(SomeValue.*\) *: *Boolean', skType)).AddFlag(ehNoTypeInfo);
    t.Add( 'TIntStatArray', weMatch('type array *\[1\.\.5\] *of (integer|longint)', skType)).AddFlag(ehNoTypeInfo);
    t.Add( 'TIntDynArray',  weMatch('type array of (integer|longint)', skType)).AddFlag(ehNoTypeInfo);
    t.Add( 'byte',          weMatch('type byte', skType)).AddFlag(ehNoTypeInfo);

    t.Add('MyStringItemList',                 weStatArray([], -1) ).IgnTypeName();
    t.Add('MyStringList.FLIST^',                 weStatArray([], -1) ).IgnTypeName();
    t.Add('TMYSTRINGLIST(MyStringList).FLIST^',    weStatArray([], -1) ).IgnTypeName();
    t.Add('MyClass1.FMyStringList.FLIST^',                 weStatArray([], -1) ).IgnTypeName();
    t.Add('TMYSTRINGLIST(MyClass1.FMyStringList).FLIST^',    weStatArray([], -1) ).IgnTypeName();
    t.Add('TMYSTRINGLIST(TMyClass(MyClass1).FMyStringList).FLIST^',    weStatArray([], -1) ).IgnTypeName();
    t.Add('TMYSTRINGLIST(TMyClass(MyClass2).FMyStringList).FLIST^',    weStatArray([], -1) ).IgnTypeName();

    t.Add('MyStringList.FLIST^[0]',                 weMatch('FString', skRecord) ).IgnTypeName();
    t.Add('TMYSTRINGLIST(MyStringList).FLIST^[0]',    weMatch('FString', skRecord) ).IgnTypeName();
    t.Add('MyClass1.FMyStringList.FLIST^[0]',                 weMatch('FString', skRecord) ).IgnTypeName();
    t.Add('TMYSTRINGLIST(MyClass1.FMyStringList).FLIST^[0]',    weMatch('FString', skRecord) ).IgnTypeName();
    t.Add('TMYSTRINGLIST(TMyClass(MyClass1).FMyStringList).FLIST^[0]',    weMatch('FString', skRecord) ).IgnTypeName();
    t.Add('TMYSTRINGLIST(TMyClass(MyClass2).FMyStringList).FLIST^[0]',    weMatch('FString', skRecord) ).IgnTypeName();

    // make sure no deep recorsion...
    t.Add('TSize', 'TSize', weMatch('.', skType)).AddFlag(ehNoTypeInfo);
    t.Add('TFuncSelfRef', 'TFuncSelfRef', weMatch('.', skType)).AddFlag(ehNoTypeInfo)
    .SkipIf(Compiler.Version < 029900);
    t.Add('PFuncSelfRef', 'PFuncSelfRef', weMatch('.', skType)).AddFlag(ehNoTypeInfo)
    .SkipIf(Compiler.Version < 029900);

    t.Add('EnVal1', 'EnVal1', weMatch('EnVal1 *:?= *0', skEnumValue));
    t.Add('EnVal2', 'EnVal2', weMatch('EnVal2 *:?= *1', skEnumValue));
    t.Add('EnVal3', 'EnVal3', weMatch('EnVal3 *:?= *2', skEnumValue));
    t.Add('EnVal21', 'EnVal21', weMatch('EnVal21 *:?= *3', skEnumValue));
    t.Add('EnVal23', 'EnVal23', weMatch('EnVal23 *:?= *7', skEnumValue));

    t.Add('EnXVal01', 'EnXVal01', weMatch('EnXVal01 *:?= *-503', skEnumValue));
    t.Add('EnXVal04', 'EnXVal04', weMatch('EnXVal04 *:?= *510', skEnumValue));
    t.Add('EnXVal11', 'EnXVal11', weMatch('EnXVal11 *:?= *-3', skEnumValue));
    t.Add('EnXVal14', 'EnXVal14', weMatch('EnXVal14 *:?= *10', skEnumValue));
    t.Add('EnXVal21', 'EnXVal21', weMatch('EnXVal21 *:?= *-203', skEnumValue));
    t.Add('EnXVal24', 'EnXVal24', weMatch('EnXVal24 *:?= *210', skEnumValue));
    t.Add('EnXValA11', 'EnXValA11', weMatch('EnXValA11 *= *1', skEnumValue));
    t.Add('EnXValA14', 'EnXValA14', weMatch('EnXValA14 *= *190', skEnumValue))
    .IgnAll(stDwarf2, Compiler.Version >= 030301);

    // recurse pointers
    // TODO: currently just run them and check they do not fail,crash or hang.
    // TODO: add checks for result
    t.Add('RecursePtrA1',   'RecursePtrA1', weMatch('.*', skPointer));
    t.Add('RecursePtrA1^',  'RecursePtrA1^', weMatch('.*', skPointer));
    t.Add('RecursePtrA1^^', 'RecursePtrA1^^', weMatch('.*', skPointer));
    t.Add('RecursePtrA1^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^', 'RecursePtrA1^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^', weMatch('.*', skPointer));
    t.Add('@RecursePtrA1',   '@RecursePtrA1', weMatch('.*', skPointer));
    t.Add('@RecursePtrA1^',  '@RecursePtrA1^', weMatch('.*', skPointer));
    t.Add('@RecursePtrA1^^', '@RecursePtrA1^^', weMatch('.*', skPointer));
    t.Add('@RecursePtrA1^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^', '@RecursePtrA1^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^', weMatch('.*', skPointer));
    t.Add('RecursePtrB1',   'RecursePtrB1', weMatch('.*', skPointer));
    t.Add('RecursePtrB1^',  'RecursePtrB1^', weMatch('.*', skPointer));
    t.Add('RecursePtrB1^^', 'RecursePtrB1^^', weMatch('.*', skPointer));
    t.Add('RecursePtrB1^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^',   'RecursePtrB1^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^', weMatch('.*', skPointer));
    t.Add('RecursePtrC1',   'RecursePtrC1', weMatch('.*', skPointer));
    t.Add('RecursePtrC1^',  'RecursePtrC1^', weMatch('.*', skPointer));
    t.Add('RecursePtrC1^^', 'RecursePtrC1^^', weMatch('.*', skPointer));
    t.Add('RecursePtrC1^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^',   'RecursePtrC1^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^', weMatch('.*', skPointer));

    AddWatches(t, 'glob const', 'gc', 000, 'A', tlConst);
    AddWatches(t, 'glob var',   'gv', 001, 'B');
    AddWatches(t, 'glob var (@)^',   '(@gv', 001, 'B', tlAny, ')^');
    AddWatches(t, 'glob var (@)[0]',   '(@gv', 001, 'B', tlAny, ')[0]');
//    AddWatches(t, 'glob var @^',   '@gv', 001, 'B', tlAny, '^');

    AddWatches(t, 'glob MyClass1',     'MyClass1.mc',  002, 'C');
    AddWatches(t, 'glob MyBaseClass1', 'MyClass1.mbc', 003, 'D');
    AddWatches(t, 'glob cast MyClass2',     'TMyClass(MyClass2).mc',  004, 'E');
    AddWatches(t, 'glob cast MyBaseClass2', 'TMyClass(MyClass2).mbc', 005, 'F');
    AddWatches(t, 'glob MyPClass1',          'MyPClass1^.mc',  002, 'C');
    AddWatches(t, 'glob cast MyPClass2',     'TMyClass(MyPClass2^).mc',  004, 'E');

    c := t.Count; // Do not crash when accessing fields on nil
    AddWatches(t, 'glob MyNilClass1',     'MyNilClass1.mc',  002, 'C');
    for i := c to t.Count-1 do
      t.Tests[i].Skip;

    AddWatches(t, 'glob TMyBaseClass class const',   'TMyBaseClass.cl_c_',  001, 'c', tlClassConst);
    AddWatches(t, 'glob TMyClass class const',   'TMyClass.cl_c_',  001, 'c', tlClassConst);
    c := t.Count;
    AddWatches(t, 'glob TMyBaseClass class var',     'TMyBaseClass.cl_v_',  007, 'v', tlClassVar);
    AddWatches(t, 'glob TMyClass class var',     'TMyClass.cl_v_',  007, 'v', tlClassVar);
    for i := c to t.Count-1 do
      t.Tests[i].Skip;  // class var do not work => but ensure they do not crash

    AddWatches(t, 'glob MyClass2 class const',   'MyClass2.cl_c_',  001, 'c', tlClassConst);
    AddWatches(t, 'glob MyClass1 class const',   'MyClass1.cl_c_',  001, 'c', tlClassConst);
    c := t.Count;
    AddWatches(t, 'glob MyClass2 class var',     'MyClass2.cl_v_',  007, 'v', tlClassVar);
    AddWatches(t, 'glob MyClass1 class var',     'MyClass1.cl_v_',  007, 'v', tlClassVar);
    for i := c to t.Count-1 do
      t.Tests[i].Skip;  // class var do not work => but ensure they do not crash

    if (Compiler.Version >= 030202) or (Compiler.SymbolType in stDwarf2) then begin
      AddWatches(t, 'glob MyOldObjectBase',      'MyOldObjectBase.obc', 003, 'D', tlAny, '', [tlReduced]);
      AddWatches(t, 'glob MyOldObject inherhit', 'MyOldObject.obc', 004, 'E', tlAny, '', [tlReduced]);
      AddWatches(t, 'glob MyOldObject',          'MyOldObject.oc',  002, 'C', tlAny, '', [tlReduced]);

      AddWatches(t, 'glob MyPOldObjectBase^',      'MyPOldObjectBase^.obc', 003, 'D', tlAny, '', [tlReduced]);
      AddWatches(t, 'glob MyPOldObject^ inherhit', 'MyPOldObject^.obc', 004, 'E', tlAny, '', [tlReduced]);
      AddWatches(t, 'glob MyPOldObject^',          'MyPOldObject^.oc',  002, 'C', tlAny, '', [tlReduced]);
    end;

    AddWatches(t, 'glob MyTestRec1',     'MyTestRec1.rc_f_',  002, 'r');
    AddWatches(t, 'glob MyPTestRec1',     'MyPTestRec1^.rc_f_',  002, 'r');

    AddWatches(t, 'glob MyTestRec1.MyEmbedClass class const',   'MyTestRec1.MyEmbedClass.cl_c_',  001, 'c', tlClassConst);

    AddWatches(t, 'glob var dyn array of [0]',   'gva', 005, 'K', tlArrayWrap, '[0]' );
    AddWatches(t, 'glob var dyn array of [1]',   'gva', 006, 'L', tlArrayWrap, '[1]');
    AddWatches(t, 'glob var array [0..2] of [0]',   'gv_sa_', 007, 'O', tlArrayWrap, '[0]' );
    AddWatches(t, 'glob var array [0..2] of [1]',   'gv_sa_', 008, 'P', tlArrayWrap, '[1]');
    AddWatches(t, 'glob var array [-1..2] of [-1]',   'gv_nsa_', 009, 'Q', tlArrayWrap, '[-1]' );
    AddWatches(t, 'glob var array [-1..2] of [0]',    'gv_nsa_', 010, 'R', tlArrayWrap, '[0]');
    AddWatches(t, 'glob var array [-1..2] of [1]',    'gv_nsa_', 011, 'S', tlArrayWrap, '[1]');

    AddWatches(t, 'glob var ptr dyn array of [0]',   'gvp_a_', 005, 'K', tlArrayWrap, '^[0]' );
    AddWatches(t, 'glob var ptr dyn array of [1]',   'gvp_a_', 006, 'L', tlArrayWrap, '^[1]');
    AddWatches(t, 'glob var ptr array [0..2] of [0]',   'gvp_sa_', 007, 'O', tlArrayWrap, '^[0]' );
    AddWatches(t, 'glob var ptr array [0..2] of [1]',   'gvp_sa_', 008, 'P', tlArrayWrap, '^[1]');
    AddWatches(t, 'glob var ptr array [-1..2] of [-1]',   'gvp_nsa_', 009, 'Q', tlArrayWrap, '^[-1]' );
    AddWatches(t, 'glob var ptr array [-1..2] of [0]',    'gvp_nsa_', 010, 'R', tlArrayWrap, '^[0]');
    AddWatches(t, 'glob var ptr array [-1..2] of [1]',    'gvp_nsa_', 011, 'S', tlArrayWrap, '^[1]');

    AddWatches(t, 'glob var pointer',            'gvp_', 001, 'B', tlPointer, '^'); // pointer
    AddWatches(t, 'glob var named pointer',      'gvpt_', 001, 'B', tlPointer, '^'); // pointer
    (*
      ptr[0] is tested above: glob var (@)[0]',   '(@gv', 001, 'B', tlAny, ')[0]'
      More pointer ops tested in Expression testcase
      // Using array index [1] or greater will fail some pchar tests, as the become pchar<>string
      // they need .CharFromIndex at least for Dwarf2...
    *)
    //AddWatches(t, 'glob var pointer 2 (@gva[1+0])',  'gvp2_', 006, 'L', tlPointer, '[0]'); // pointer
    //AddWatches(t, 'glob var pointer 2 (@gva[1+2])',  'gvp2_', 009, 'O', tlPointer, '[2]'); // pointer // fails gvp2_Char[2] / gvp2_WideChar[2] and similar => needs to
    AddWatches(t, 'glob var pointer 2 (@gva[1-1])',  'gvp2_', 005, 'K', tlPointer, '[-1]', [tiPointerMath]); // pointer
    AddWatches(t, 'glob var pointer 2 (@gva[1]+2)^','(gvp2_', 009, 'O', tlPointer, '+2)^', [tiPointerMath]); // pointer
    //AddWatches(t, 'glob var pointer 2 (@gva[1]-1)^','(gvp2_', 005, 'K', tlPointer, '-1)^'); // pointer

// type names do not match....
    c := t.Count;
    AddWatches(t, 'glob var TYPED pointer',            'gvptt_', 007, 'N', tlPointerAny, '^', [tlTypeTX], 'TX'); // pointer
    AddWatches(t, 'glob var TYPED ALIAS ',             'gvtt_', 007, 'N', tlPointerAny, '', [tlTypeTX], 'TX');

    t.EvaluateWatches;
    t.CheckResults;

    // Pointer(1)
    // Do not check values. // Just ensure no crash occurs
    AddWatches(t, 'glop bad pointer - no crash', 'gvpX_', 001, 'B');
    AddWatches(t, 'glob MyClassBadMemc - no crash',   'MyClassBadMem.mc',  001, 'c');
    t.EvaluateWatches;


    for tp in TTestPart do begin
      tpS := [tp];
      if not UseParts then tpS := [low(TTestPart)..high(TTestPart)];

      RunToPause(BrkFooBegin[tp]);
      t.Clear;
      AddWatches(t, 'fooBegin args', 'arg', 001, 'B', tlParam, '', [], '', tpS);
      AddWatches(t, 'fooBegin local', 'fooloc', 002, 'C', tlAny, '', [], '', tpS);
      t.EvaluateWatches;
      // Do not check values. // Just ensure no crash occurs
      // Registers are wrong in prologue.


      //cl := Debugger.LazDebugger.GetLocation.SrcLine;
      RunToPause(BrkFoo[tp]);
      //// below might have been caused by the break on FooVarBegin, if there was no code.
      //if (cl > 1) and (cl = Debugger.LazDebugger.GetLocation.SrcLine) then begin dbg.Run; Debugger.WaitForFinishRun(); end; // TODO: bug, stopping twice the same breakpoint
      t.Clear;
      AddWatches(t, 'foo local', 'fooloc', 002, 'C', tlAny, '', [], '', tpS);
      AddWatches(t, 'foo args', 'arg', 001, 'B', tlParam, '', [], '', tpS);

      if tp = tp1 then begin
        AddWatches(t, 'foo ArgMyClass1',     'ArgMyClass1.mc',  002, 'C', tlAny, '', [], '');
        AddWatches(t, 'foo ArgMyBaseClass1', 'ArgMyClass1.mbc', 003, 'D', tlAny, '', [], '');
        AddWatches(t, 'foo ArgMyClass1',     'TMyClass(ArgMyClass2).mc',  004, 'E', tlAny, '', [], '');
        AddWatches(t, 'foo ArgMyBaseClass1', 'TMyClass(ArgMyClass2).mbc', 005, 'F', tlAny, '', [], '');
        AddWatches(t, 'foo ArgMyTestRec1',   'ArgMyTestRec1.rc_f_',  002, 'r', tlAny, '', [], '');
      end;
      t.EvaluateWatches;
      t.CheckResults;



      RunToPause(BrkFooVarBegin[tp]);
      t.Clear;
      AddWatches(t, 'foo var args', 'argvar', 001, 'B', tlParam, '', [], '', tpS);
      t.EvaluateWatches;
      // Do not check values. // Just ensure no crash occurs
      // Registers are wrong in prologue.



      RunToPause(BrkFooVar[tp]);
      t.Clear;
      AddWatches(t, 'foo var args', 'argvar', 001, 'B', tlParam, '', [], '', tpS);

      if tp = tp1 then begin
        AddWatches(t, 'foo var ArgMyClass1',     'ArgVarMyClass1.mc',  002, 'C', tlAny, '', [], '');
        AddWatches(t, 'foo var ArgMyBaseClass1', 'ArgVarMyClass1.mbc', 003, 'D', tlAny, '', [], '');
        AddWatches(t, 'foo var ArgMyClass1',     'TMyClass(ArgVarMyClass2).mc',  004, 'E', tlAny, '', [], '');
        AddWatches(t, 'foo var ArgMyBaseClass1', 'TMyClass(ArgVarMyClass2).mbc', 005, 'F', tlAny, '', [], '');
        AddWatches(t, 'foo var ArgMyTestRec1',   'ArgVarMyTestRec1.rc_f_',  002, 'r', tlAny, '', [], '');
      end;
      t.EvaluateWatches;
      t.CheckResults;


      RunToPause(BrkFooConstRef[tp]);
      t.Clear;
      AddWatches(t, 'foo const ref args', 'argconstref', 001, 'B', tlParam, '', [], '', tpS);
      t.EvaluateWatches;
      t.CheckResults;

      if not UseParts then break;
    end;


    RunToPause(BrkBaseMethFoo, False);
    t.Clear;
    t.Add('BaseMethFoo of TMyClass1 - ClassBaseVar1', 'ClassBaseVar1', weInteger(118));
//    t.Add('BaseMethFoo of TMyClass1 - ClassVar1', 'ClassVar1', weInteger(119));
    // Trigger a search through everything
    t.Add('NotExistingFooBar123_X', weInteger(0))^.AddFlag(ehExpectError);
    //AddWatches(t, 'foo const ref args', 'argconstref', 001, 'B', tlParam);
    t.EvaluateWatches;
    t.CheckResults;


    RunToPause(BrkMethFoo);
    t.Clear;
    t.Add('MethFoo of TMyClass1 - ClassBaseVar1', 'ClassBaseVar1', weInteger(118));
    t.Add('MethFoo of TMyClass1 - ClassVar1', 'ClassVar1', weInteger(119));
    // Trigger a search through everything
    t.Add('NotExistingFooBar123_X', weInteger(0))^.AddFlag(ehExpectError);
    //AddWatches(t, 'foo const ref args', 'argconstref', 001, 'B', tlParam);

    AddWatches(t, 'FIELD MyClass1',     'mc',  002, 'C', tlAny, '', [tlReduced]);
    AddWatches(t, 'FIELD MyBaseClass1', 'mbc', 003, 'D', tlAny, '', [tlReduced]);
    AddWatches(t, 'self MyClass1',     'self.mc',  002, 'C', tlAny, '', [tlReduced]);
    AddWatches(t, 'self MyBaseClass1', 'self.mbc', 003, 'D', tlAny, '', [tlReduced]);

    t.EvaluateWatches;
    t.CheckResults;


    RunToPause(BrkBaseMethFoo);
    t.Clear;
    t.Add('BaseMethFoo of TMyBaseClass - ClassBaseVar1', 'ClassBaseVar1', weInteger(118));
//    t.Add('BaseMethFoo of TMyBaseClass - ClassVar1', 'ClassVar1', weInteger(119));
    // Trigger a search through everything
    t.Add('NotExistingFooBar123_X', weInteger(0))^.AddFlag(ehExpectError);
    //AddWatches(t, 'foo const ref args', 'argconstref', 001, 'B', tlParam);
    t.EvaluateWatches;
    t.CheckResults;


    if Compiler.Version >= 030300 then begin
      RunToPause(BaseObjMethFoo);
      t.Clear;
      AddWatches(t, 'field MyOldObject base', 'obc', 003, 'D', tlAny, '', [tlReduced]);
      AddWatches(t, 'self MyOldObject base', 'self.obc', 003, 'D', tlAny, '', [tlReduced]);
      t.Add('ocByte', weInteger(0))^.AddFlag(ehExpectError);
      t.Add('NotExistingFooBar123_X', weInteger(0))^.AddFlag(ehExpectError);
      t.EvaluateWatches;
      t.CheckResults;

      RunToPause(ObjMethFoo);
      t.Clear;
      AddWatches(t, 'field MyOldObject inherhit', 'obc', 004, 'E', tlAny, '', [tlReduced]);
      AddWatches(t, 'field MyOldObject',          'oc',  002, 'C', tlAny, '', [tlReduced]);
      AddWatches(t, 'self MyOldObject inherhit', 'self.obc', 004, 'E', tlAny, '', [tlReduced]);
      AddWatches(t, 'self MyOldObject',          'self.oc',  002, 'C', tlAny, '', [tlReduced]);
      t.Add('MyOldObject - NotExistingFooBar123_X', weInteger(0))^.AddFlag(ehExpectError);
      t.EvaluateWatches;
      t.CheckResults;
    end;


  finally
    Debugger.RunToNextPause(dcStop);
    t.Free;
    Debugger.ClearDebuggerMonitors;
    Debugger.FreeDebugger;

    AssertTestErrors;
  end;
end;

procedure TTestWatches.TestWatchesIntrinsic;

  const PREFIX = ':';

  type
    TTestLoc = (tlAny, tlConst, tlParam, tlArrayWrap, tlPointer, tlPointerAny, tlClassConst, tlClassVar);
    TTestIgn = set of (
      tiPointerMath  // pointer math / (ptr+n)^ / ptr[n]
    );

  procedure AddWatches(t: TWatchExpectationList; AName: String; APrefix: String; AOffs: Integer; AChr1: Char;
    ALoc: TTestLoc = tlAny; APostFix: String = ''; AIgnFlags: TTestIgn = []);
  var
    LN, p, e: String;
    n, StartIdx, i, StartIdxClassConst: Integer;
  begin
    p := APrefix;
    e := APostFix;
    n := AOffs;

    LN := PREFIX+'Length';

    t.Add(AName, LN+'('+p+'Char'+e+')',   weInteger(1, #1, 0)).IgnTypeName();
    t.Add(AName, LN+'('+p+'Char2'+e+')',  weInteger(1, #1, 0)).IgnTypeName();
    t.Add(AName, LN+'('+p+'Char2'+e+'+''a'')',   weInteger(2, #1, 0)).IgnTypeName();
    t.Add(AName, LN+'('+p+'Char2'+e+'+''ab'')',  weInteger(3, #1, 0)).IgnTypeName();

    t.Add(AName, LN+'('+p+'String1'+e+')',    weInteger( 1, #1, 0)).IgnTypeName();
    t.Add(AName, LN+'('+p+'String1e'+e+')',   weInteger( 0, #1, 0)).IgnTypeName();
    t.Add(AName, LN+'('+p+'String10'+e+')',   weInteger( 4, #1, 0)).IgnTypeName();
    t.Add(AName, LN+'('+p+'String10e'+e+')',  weInteger( 0, #1, 0)).IgnTypeName();
    t.Add(AName, LN+'('+p+'String10x'+e+')',  weInteger( 8, #1, 0)).IgnTypeName();
    t.Add(AName, LN+'('+p+'String255'+e+')',  weInteger(14, #1, 0)).IgnTypeName();
    t.Add(AName, LN+'('+p+'String10'+e+'+''a'')',    weInteger( 5, #1, 0)).IgnTypeName();
    t.Add(AName, LN+'('+p+'String10'+e+'+''ab'')',   weInteger( 6, #1, 0)).IgnTypeName();

  //if Compiler.HasFlag('SkipStringFunc') then exit;
  //if Compiler.HasFlag('Dwarf2') then exit;

    t.Add(AName, LN+'('+p+'Ansi1'+e+')',  weInteger(  1, #1, 0)).IgnTypeName().IgnAll(stDwarf2);
    t.Add(AName, LN+'('+p+'Ansi2'+e+')',  weInteger(  9, #1, 0)).IgnTypeName().IgnAll(stDwarf2);
    t.Add(AName, LN+'('+p+'Ansi3'+e+')',  weInteger(  0, #1, 0)).IgnTypeName().IgnAll(stDwarf2);
    t.Add(AName, LN+'('+p+'Ansi4'+e+')',  weInteger(  8, #1, 0)).IgnTypeName().IgnAll(stDwarf2);
    t.Add(AName, LN+'('+p+'Ansi5'+e+')',  weInteger(360, #1, 0)).IgnTypeName().IgnAll(stDwarf2);
    t.Add(AName, LN+'('+p+'Ansi4'+e+'+''a'')',   weInteger( 9, #1, 0)).IgnTypeName().IgnAll(stDwarf2);
    t.Add(AName, LN+'('+p+'Ansi4'+e+'+''ab'')',  weInteger(10, #1, 0)).IgnTypeName().IgnAll(stDwarf2);


    t.Add(AName, LN+'('+p+'CharDynArray'+e+')',   weInteger(0, #1, 0)).IgnTypeName().IgnAll(stDwarf2);
    t.Add(AName, LN+'('+p+'CharDynArray2'+e+')',  weInteger(3, #1, 0)).IgnTypeName().IgnAll(stDwarf2);

    t.Add(AName, LN+'('+p+'IntDynArray'+e+')',   weInteger(0, #1, 0)).IgnTypeName().IgnAll(stDwarf2);
    t.Add(AName, LN+'('+p+'IntDynArray2'+e+')',  weInteger(3, #1, 0)).IgnTypeName().IgnAll(stDwarf2);

    t.Add(AName, LN+'('+p+'ShortStrDynArray2'+e+')',     weInteger(3, #1, 0)).IgnTypeName().IgnAll(stDwarf2);
    t.Add(AName, LN+'('+p+'ShortStrDynArray2[0]'+e+')',  weInteger(4, #1, 0)).IgnTypeName().IgnAll(stDwarf2);
    t.Add(AName, LN+'('+p+'ShortStrDynArray2[1]'+e+')',  weInteger(3, #1, 0)).IgnTypeName().IgnAll(stDwarf2);

    t.Add(AName, LN+'('+p+'ArrayEnum1'+e+')',  weInteger(4, #1, 0)).IgnTypeName().IgnAll(stDwarf2)
    .SkipIf(ALoc = tlParam).SkipIf(ALoc = tlPointer);


  end;

var
  ExeName, vn, d1: String;
  t: TWatchExpectationList;
  Src: TCommonSource;
  BrkPrg, BrkFoo, BrkFooVar, BrkFooConstRef: TDBGBreakPoint;
  i: Integer;
begin
  if SkipTest then exit;
  if not TestControlCanTest(ControlTestWatchIntrinsic) then exit;
  t := nil;

  Src := GetCommonSourceFor('WatchesValuePrg.pas');
  TestCompile(Src, ExeName, '', ' -dSINGLE_BIG_FUNC ');

  AssertTrue('Start debugger', Debugger.StartDebugger(AppDir, ExeName));

  try
    t := TWatchExpectationList.Create(Self);
    t.AcceptSkSimple := [skInteger, skCardinal, skBoolean, skChar, skFloat,
      skString, skAnsiString, skCurrency, skVariant, skWideString,
      skInterface, skEnumValue];
    t.AddTypeNameAlias('integer', 'integer|longint');
    t.AddTypeNameAlias('Char', 'Char|AnsiChar');
    t.AddTypeNameAlias('ShortStr255', 'ShortStr255|ShortString');
    t.AddTypeNameAlias('TEnumSub', 'TEnum|TEnumSub');


    BrkPrg         := Debugger.SetBreakPoint(Src, 'Prg');
    BrkFoo         := Debugger.SetBreakPoint(Src, 'Foo');
    BrkFooVar      := Debugger.SetBreakPoint(Src, 'FooVar');
    BrkFooConstRef := Debugger.SetBreakPoint(Src, 'FooConstRef');

    AssertDebuggerNotInErrorState;
    RunToPause(BrkPrg);


    t.Clear;
    (*
:ord
gvBitPackEnumArray
TEnumX1
    *)

    t.Add('refcnt', PREFIX+'refcnt(SRef0)',     weInteger( 0, #1, 0)).IgnTypeName().IgnAll(stDwarf2);
    t.Add('refcnt', PREFIX+'refcnt(SRef1)',     weInteger(-1, #1, 0)).IgnTypeName().IgnAll(stDwarf2);
    t.Add('refcnt', PREFIX+'refcnt(SRef2)',     weInteger( 1, #1, 0)).IgnTypeName().IgnAll(stDwarf2);
    t.Add('refcnt', PREFIX+'refcnt(SRef3)',     weInteger( 2, #1, 0)).IgnTypeName().IgnAll(stDwarf2);
    t.Add('refcnt', PREFIX+'refcnt(SRef4)',     weInteger( 2, #1, 0)).IgnTypeName().IgnAll(stDwarf2);

    t.Add('refcnt', PREFIX+'refcnt(ARef0)',     weInteger( 0, #1, 0)).IgnTypeName();
    t.Add('refcnt', PREFIX+'refcnt(ARef1)',     weInteger( 1, #1, 0)).IgnTypeName();
    t.Add('refcnt', PREFIX+'refcnt(ARef2)',     weInteger( 1, #1, 0)).IgnTypeName();
    t.Add('refcnt', PREFIX+'refcnt(ARef3)',     weInteger( 2, #1, 0)).IgnTypeName();
    t.Add('refcnt', PREFIX+'refcnt(ARef4)',     weInteger( 2, #1, 0)).IgnTypeName();

    t.Add('pos', PREFIX+'pos(''c'', SRef1)',     weInteger( 3, #1, 0)).IgnTypeName();
    t.Add('pos', PREFIX+'pos(''d'', PCRef1)',     weInteger( 4, #1, 0)).IgnTypeName();
    t.Add('pos', PREFIX+'pos(''e'', Short0)',     weInteger( 5, #1, 0)).IgnTypeName();
    t.Add('pos', PREFIX+'pos(''e'', ''1e'')',     weInteger( 2, #1, 0)).IgnTypeName();

// dwarf2 incorrectly does SREF: PChar
    t.Add('substr', PREFIX+'substr(SRef1, 2,3)',   weAnsiStr('bcd', #1)).IgnTypeName().IgnAll(stDwarf2);
    t.Add('substr', PREFIX+'substr(SRef1, 2,3)',   weAnsiStr('cde', #1)).IgnTypeName().IgnAll(stDwarf3Up);
    t.Add('substr', PREFIX+'substr(Short0, 4,3)',   weAnsiStr('def', #1)).IgnTypeName();
    t.Add('substr', PREFIX+'substr(SRef1, 2,3, false)',   weAnsiStr('bcd', #1)).IgnTypeName().IgnAll(stDwarf2);
    t.Add('substr', PREFIX+'substr(SRef1, 2,3, false)',   weAnsiStr('cde', #1)).IgnTypeName().IgnAll(stDwarf3Up);
    t.Add('substr', PREFIX+'substr(Short0, 4,3, false)',   weAnsiStr('def', #1)).IgnTypeName();
    //  0 based
    t.Add('substr', PREFIX+'substr(SRef1, 2,3, true)',   weAnsiStr('cde', #1)).IgnTypeName();
    t.Add('substr', PREFIX+'substr(Short0, 4,3, true)',   weAnsiStr('ef1', #1)).IgnTypeName().IgnAll(stDwarf2);
    // cut off
    t.Add('substr', PREFIX+'substr(SRef1, 10, 30)',   weAnsiStr('456', #1)).IgnTypeName().IgnAll(stDwarf2);
    //t.Add('substr', PREFIX+'substr(SRef1, 10, 30)',   weAnsiStr('567', #1)).IgnTypeName().IgnAll(stDwarf3Up);

    t.Add('substr', PREFIX+'substr(SHORT1[1], -4, 2, true)',   weAnsiStr('23', #1)).IgnTypeName()
.IgnAll(stDwarf2);

    t.Add('substr', PREFIX+'substr(PtrRef1, 2, 4, true)',   weAnsiStr('cdef', #1)).IgnTypeName();
    t.Add('substr', PREFIX+'substr(PCRef1, 2, 4, true)',   weAnsiStr('cdef', #1)).IgnTypeName();


    t.Add('string[..]', 'SRef1[3..5]', weAnsiStr('cde').IgnTypeName()).IgnAll(stDwarf2);
    t.Add('string[..]', 'SRef1[2..6][2]', weChar('c').IgnTypeName()).IgnAll(stDwarf2);
    t.Add('string[..]', 'SRef1[2..6][2..3]', weAnsiStr('cd').IgnTypeName()).IgnAll(stDwarf2);
// not avail for pchar
//    t.Add('pchar[..]', 'PCRef1[2..4]', weAnsiStr('cde').IgnTypeName()).IgnAll(stDwarf2);
//    t.Add('string[..]', '@SRef1[1][2..4]', weAnsiStr('cde').IgnTypeName()).IgnAll(stDwarf2);


    for i := 0 to 2 do begin
      case i of
        0: begin
            vn := 'dotdotArray1a';
            d1 := '';
          end;
        1: begin
            vn := 'dotdotArrayP1a';
            d1 := '^';
          end;
        2: begin
            vn := 'dotdotArrayPPa^';
            d1 := '';
          end;
      end;

      t.Add('..', vn+'[2..4]'+d1, weStatArray([
        ////weMatchErr('error|fail'),
        weRecord([wePointer(weAnsiStr('ABCDE')).N('p1'),       weMatch('nil',skPointer).N('p2')  ]),
        weRecord([weMatch('nil',skPointer).N('p1'),            weMatch('nil',skPointer).N('p2')  ]),
        weRecord([wePointer(weAnsiStr('bcdef123456')).N('p1'), weMatch('nil',skPointer).N('p2')  ])
      ], 3))
      .AddFlag(ehIgnKindArrayType);
      t.Add('..', vn+'[2..4]'+d1+'.p1', weStatArray([
        wePointer(weAnsiStr('ABCDE').IgnTypeName()),
        weMatch('nil',skPointer),
        wePointer(weAnsiStr('bcdef123456').IgnTypeName())
      ], 3))
      .AddFlag(ehIgnKindArrayType);
      t.Add('..', vn+'[2..4]'+d1+'.p1[0]', weStatArray([
        weChar('A', #1).IgnTypeName(),
        weMatchErr('error|fail'),
        weChar('b', #1).IgnTypeName()
      ], 3))
      .AddFlag(ehIgnKindArrayType);


      t.Add('..', vn+'[1..4]'+d1, weStatArray([
        weRecord([wePointerAddr(pointer(1), weMatchErr('error|fail')).N('p1'),  weMatch('nil',skPointer).N('p2')  ]),
        weRecord([wePointer(weAnsiStr('ABCDE')).N('p1'),               weMatch('nil',skPointer).N('p2')  ]),
        weRecord([weMatch('nil',skPointer).N('p1'),                    weMatch('nil',skPointer).N('p2')  ]),
        weRecord([wePointer(weAnsiStr('bcdef123456')).N('p1'),         weMatch('nil',skPointer).N('p2')  ])
      ], 4))
      .AddFlag(ehIgnKindArrayType);
      t.Add('..', vn+'[1..4]'+d1+'.p1', weStatArray([
        wePointerAddr(pointer(1), weMatchErr('error|fail')),
        wePointer(weAnsiStr('ABCDE').IgnTypeName()),
        weMatch('nil',skPointer),
        wePointer(weAnsiStr('bcdef123456').IgnTypeName())
      ], 4))
      .AddFlag(ehIgnKindArrayType);
      t.Add('..', vn+'[1..4]'+d1+'.p1^', weStatArray([
        weMatchErr('error|fail'),
        weChar('A', #1).IgnTypeName(),
        weMatchErr('error|fail'),
        weChar('b', #1).IgnTypeName()
      ],4))
      .AddFlag(ehIgnKindArrayType);
      t.Add('..', vn+'[1..4]'+d1+'.p1[0]', weStatArray([
        weMatchErr('error|fail'),
        weChar('A', #1).IgnTypeName(),
        weMatchErr('error|fail'),
        weChar('b', #1).IgnTypeName()
      ],4))
      .AddFlag(ehIgnKindArrayType);
      t.Add('..', vn+'[1..4]'+d1+'.p1[1]', weStatArray([
        weMatchErr('error|fail'),
        weChar('B', #1).IgnTypeName(),
        weMatchErr('error|fail'),
        weChar('c', #1).IgnTypeName()
      ],4))
      .ChrIdxExpPChar
      .AddFlag(ehIgnKindArrayType);

      t.Add('..', '@'+vn+'[1..4]'+d1+'.p1^', weStatArray([
        wePointerAddr(pointer(1), weMatchErr('error|fail')),
        wePointer(weAnsiStr('ABCDE').IgnTypeName()),
        weMatch('nil',skPointer),
        wePointer(weAnsiStr('bcdef123456').IgnTypeName())
      ], 4))
      .ChrIdxExpPChar
      .AddFlag(ehIgnKindArrayType);
      t.Add('..', '@'+vn+'[1..4]'+d1+'.p1[0]', weStatArray([
        wePointerAddr(pointer(1), weMatchErr('error|fail')),
        wePointer(weAnsiStr('ABCDE').IgnTypeName()),
        weMatch('nil',skPointer),
        wePointer(weAnsiStr('bcdef123456').IgnTypeName())
      ], 4))
      .ChrIdxExpPChar
      .AddFlag(ehIgnKindArrayType);
      t.Add('..', '@'+vn+'[1..4]'+d1+'.p1[1]', weStatArray([
        wePointerAddr(pointer(2), weMatchErr('error|fail')),
        wePointer(weAnsiStr('BCDE').IgnTypeName()),
        wePointerAddr(pointer(1), weMatchErr('error|fail')),
        wePointer(weAnsiStr('cdef123456').IgnTypeName())
      ], 4))
      .ChrIdxExpPChar
      .AddFlag(ehIgnKindArrayType);
      t.Add('..', '@('+vn+'[1..4]'+d1+'.p1[1])', weStatArray([
        wePointerAddr(pointer(2), weMatchErr('error|fail')),
        wePointer(weAnsiStr('BCDE').IgnTypeName()),
        wePointerAddr(pointer(1), weMatchErr('error|fail')),
        wePointer(weAnsiStr('cdef123456').IgnTypeName())
      ], 4))
      .ChrIdxExpPChar
      .AddFlag(ehIgnKindArrayType);



      t.Add('..', '(@'+vn+'[1..4]'+d1+'.p1[1])[2]', weStatArray([
        weMatchErr('error|fail'),
        weChar('D').IgnTypeName(),
        weMatchErr('error|fail'),
        weChar('e').IgnTypeName()
      ], 4))
      .ChrIdxExpPChar
      .AddFlag(ehIgnKindArrayType);

      //t.Add('..', '(@'+vn+'[1..4]'+d1+'.p1[1])[1..2]', weStatArray([
      //  weMatchErr('error|fail'),
      //  weAnsiStr('BC').IgnTypeName(),
      //  weMatchErr('error|fail'),
      //  weAnsiStr('cd').IgnTypeName()
      //], 4))
      //.ChrIdxExpPChar
      //.AddFlag(ehIgnKindArrayType);


      case i of
        0: begin
            vn := 'dotdotArray2a';
            d1 := '';
          end;
        1: begin
            vn := 'dotdotArrayP2a';
            d1 := '^';
          end;
        else continue;
      end;

      t.Add('..', vn+'[0..1][0..2]'+d1, weStatArray([
    //TODO: detect outer array error
        weStatArray([
          weMatchErr('error|fail'),
          weMatchErr('error|fail'),
          weMatchErr('error|fail')
        ], 3)
        .AddFlag(ehIgnKindArrayType),
        weStatArray([
          weRecord([wePointer(weAnsiStr('abcdef123456')).N('p1'),        weMatch('nil',skPointer).N('p2')  ]),
          weRecord([wePointerAddr(pointer(1), weMatchErr('error|fail')).N('p1'),  weMatch('nil',skPointer).N('p2')  ]),
          weRecord([wePointer(weAnsiStr('ABCDE')).N('p1'),               weMatch('nil',skPointer).N('p2')  ])
        ], 3)
        .AddFlag(ehIgnKindArrayType)
      ], 2))
      .AddFlag(ehIgnKindArrayType);

      t.Add('..', vn+'[0..1][0..2]'+d1+'.p1', weStatArray([
        //weMatchErr('error|fail'),
        weStatArray([
          weMatchErr('error|fail'),
          weMatchErr('error|fail'),
          weMatchErr('error|fail')
        ], 3)
        .AddFlag(ehIgnKindArrayType),
        weStatArray([
          wePointer(weAnsiStr('abcdef123456').IgnTypeName()),
          wePointerAddr(pointer(1), weMatchErr('error|fail')),
          wePointer(weAnsiStr('ABCDE').IgnTypeName())
        ], 3)
        .AddFlag(ehIgnKindArrayType)
      ], 2))
      .AddFlag(ehIgnKindArrayType);


    end;


    AddWatches(t, 'glob var',   'gv', 001, 'B');
    AddWatches(t, 'glob MyClass1',     'MyClass1.mc',  002, 'C');
    t.EvaluateWatches;
    t.CheckResults;


    RunToPause(BrkFoo);
    t.Clear;
    AddWatches(t, 'foo local', 'fooloc', 002, 'C');
    AddWatches(t, 'foo args', 'arg', 001, 'B', tlParam);
    t.EvaluateWatches;
    t.CheckResults;


    RunToPause(BrkFooVar);
    t.Clear;
    AddWatches(t, 'foo var args', 'argvar', 001, 'B', tlParam);
    t.EvaluateWatches;
    t.CheckResults;


    RunToPause(BrkFooConstRef);
    t.Clear;
    AddWatches(t, 'foo const ref args', 'argconstref', 001, 'B', tlParam);
    t.EvaluateWatches;
    t.CheckResults;



  finally
    Debugger.RunToNextPause(dcStop);
    t.Free;
    Debugger.ClearDebuggerMonitors;
    Debugger.FreeDebugger;

    AssertTestErrors;
  end;
end;

procedure TTestWatches.TestWatchesIntrinsic2;
var
  ExeName: String;
  Src: TCommonSource;
  BrkPrg: TDBGBreakPoint;
  t: TWatchExpectationList;
begin
  if SkipTest then exit;
  if not TestControlCanTest(ControlTestWatchIntrinsic2) then exit;
  t := nil;

  Src := GetCommonSourceFor(AppDir + 'WatchesIntrinsicPrg.pas');
  TestCompile(Src, ExeName);

  AssertTrue('Start debugger', Debugger.StartDebugger(AppDir, ExeName));
  try
    t := TWatchExpectationList.Create(Self);
    t.AcceptSkSimple := [skInteger, skCardinal, skBoolean, skChar, skFloat,
      skString, skAnsiString, skCurrency, skVariant, skWideString,
      skInterface, skEnumValue];
    t.AddTypeNameAlias('integer', 'integer|longint');

    BrkPrg         := Debugger.SetBreakPoint(Src, 'Prg');

    AssertDebuggerNotInErrorState;
    RunToPause(BrkPrg);


    t.Clear;
    t.Add('flatten', ':flatten(f1, Next, [])',     weArray([
        weMatch('Value *:?=? ?1', skClass),
        weMatch('Value *:?=? ?2', skClass),
        weMatch('Value *:?=? ?3', skClass),
        weMatch('Value *:?=? ?4', skClass)
      ], 4)).IgnTypeName();
    t.Add('flatten', ':flatten(f1, Next)',     weArray([
        weMatch('Value *:?=? ?1', skClass),
        weMatch('Value *:?=? ?2', skClass),
        weMatch('Value *:?=? ?3', skClass),
        weMatch('Value *:?=? ?4', skClass),
        weMatch('rec',skNone).ExpectError()
      ], 5)).IgnTypeName();

    t.Add('flatten', ':flatten(f1, Next, Value, [loop, nil, obj=false])',     weArray([
        weMatch('Value *:?=? ?1', skClass),
         weMatch('Value *:?=? ?2', skClass),
          weMatch('Value *:?=? ?3', skClass),
           weMatch('Value *:?=? ?4', skClass),
            weMatch('rec',skNone).ExpectError(),
           weInteger(4),
          weInteger(3),
         weInteger(2),
        weInteger(1)
      ], 9)).IgnTypeName();
    t.Add('flatten', ':flatten(f1, Next, Value, -[obj])',     weArray([
        weMatch('Value *:?=? ?1', skClass),
         weMatch('Value *:?=? ?2', skClass),
          weMatch('Value *:?=? ?3', skClass),
           weMatch('Value *:?=? ?4', skClass),
            weMatch('rec',skNone).ExpectError(),
           weInteger(4),
          weInteger(3),
         weInteger(2),
        weInteger(1)
      ], 9)).IgnTypeName();

    t.Add('flatten', ':flatten(f1, Next, Dummy, -[obj, err])',     weArray([
        weMatch('Value *:?=? ?1', skClass),
         weMatch('Value *:?=? ?2', skClass),
          weMatch('Value *:?=? ?3', skClass),
           weMatch('Value *:?=? ?4', skClass),
            weMatch('rec',skNone).ExpectError(),
           weRecord(weInteger(994).N('a')),
           weMatch('err',skNone).ExpectError(), // not found NEXT
           weMatch('err',skNone).ExpectError(), // not found DUMMY
          weRecord(weInteger(993).N('a')),
          weMatch('err',skNone).ExpectError(),
          weMatch('err',skNone).ExpectError(),
         weRecord(weInteger(992).N('a')),
         weMatch('err',skNone).ExpectError(),
         weMatch('err',skNone).ExpectError(),
        weRecord(weInteger(991).N('a')),
        weMatch('err',skNone).ExpectError(),
        weMatch('err',skNone).ExpectError()
      ], 17)).IgnTypeName();

    t.Add('flatten', ':flatten(f1, Dummy,a, [])',     weArray([
        weMatch('Value *:?=? ?1', skClass),
        weRecord(weInteger(991).N('a')),
        weInteger(991)
      ], 3)).IgnTypeName();

    t.Add('flatten', ':flatten(f1.Dummy, (:_.a), [loop, obj=false])',     weArray([
        weRecord(weInteger(991).N('a')),
        weInteger(991)
      ], 2)).IgnTypeName();
    t.Add('flatten', ':flatten(f1.Dummy, (TDummy(:_.a)), [loop, obj=false])',     weArray([
        weRecord(weInteger(991).N('a')),
        weRecord(weInteger(991).N('a')), // the typecast => diff location
        weMatch('err',skNone).ExpectError()   // rec
      ], 3)).IgnTypeName();

    t.Add('flatten', ':flatten(f1.Dummy2, (:_.a), [loop])',     weArray([
        weRecord(weMatch('a.*1991', skRecord).N('a')),        //weRecord(weRecord(weInteger(991).N('a')).N('a')),
        weRecord(weInteger(1991).N('a')),
        weInteger(1991)
      ], 3)).IgnTypeName();
    t.Add('flatten', ':flatten(f1.Dummy2, (TDummy2(:_.a)), [loop])',     weArray([
        weRecord(weMatch('a.*1991', skRecord).N('a')),
        weMatch('err',skNone).ExpectError()   // rec
      ], 2)).IgnTypeName();



    t.Add('flatten', ':flatten(f1, NextP)',     weArray([
        weMatch('Value *:?=? ?1', skClass),
        weMatch('Value *:?=? ?2', skClass),
        weMatch('Value *:?=? ?3', skClass),
        weMatch('Value *:?=? ?4', skClass),
        weMatch('rec',skNone).ExpectError()
      ], 5)).IgnTypeName();
    t.Add('flatten', ':flatten(f1, NextP^)',     weArray([
        weMatch('Value *:?=? ?1', skClass),
        weMatch('Value *:?=? ?2', skClass),
        weMatch('Value *:?=? ?3', skClass),
        weMatch('Value *:?=? ?4', skClass),
        weMatch('rec',skNone).ExpectError()
      ], 5)).IgnTypeName();

    t.Add('flatten', ':flatten(f1, NextP, [loop,err])',     weArray([
        weMatch('Value *:?=? ?1', skClass),
        wePointer(weMatch('.', skClass))
      ], 2)).IgnTypeName();
    t.Add('flatten', ':flatten(f1, NextP^, [loop,err])',     weArray([
        weMatch('Value *:?=? ?1', skClass),
        weMatch('Value *:?=? ?2', skClass),
        weMatch('Value *:?=? ?3', skClass),
        weMatch('Value *:?=? ?4', skClass),
        weMatch('rec',skNone).ExpectError()
      ], 5)).IgnTypeName();




    t.Add('flatten', ':flatten(fa[4], (fa[:_.Idx]))',     weArray([
        weMatch('Value *:?=? ?1', skClass),
        weMatch('Value *:?=? ?2', skClass),
        weMatch('Value *:?=? ?3', skClass),
        weMatch('Value *:?=? ?4', skClass),
        weMatch('rec',skNone).ExpectError()
      ], 5)).IgnTypeName();


    t.Add('flatten', ':flatten(f1, more[3..9]!,  [array])',     weArray([
      weMatch('Value *:?=? ?1', skClass),
        weMatch('Value *:?=? ?100004', skClass),
        weMatch('Value *:?=? ?100005', skClass),
        weMatch('Value *:?=? ?100006', skClass),
        weMatch('Value *:?=? ?100007', skClass),
        weMatch('Value *:?=? ?2', skClass),
          weMatch('Value *:?=? ?4', skClass),
            weMatch('Value *:?=? ?400003', skClass),
            weMatch('Value *:?=? ?400004', skClass),
          weMatch('Value *:?=? ?200004', skClass),
          weMatch('Value *:?=? ?200005', skClass),
          weMatch('Value *:?=? ?200006', skClass),
        weMatch('Value *:?=? ?3', skClass),
          weMatch('Value *:?=? ?300003', skClass),
          weMatch('Value *:?=? ?300004', skClass),
          weMatch('Value *:?=? ?300005', skClass)
      ], 16)).IgnTypeName();


    t.Add('flatten', ':flatten(f2, more2[0..1][3..5]!!, moreidx[1..2]!, [array=2])',     weArray([
      weMatch('Value *:?=? ?2', skClass),
        weMatch('Value *:?=? ?4', skClass),  //[0,3]
          weMatch('Value *:?=? ?10400003', skClass),
            weInteger(1),weInteger(2),
          weMatch('Value *:?=? ?10400004', skClass),
            weInteger(1),weInteger(2),
          weMatch('Value *:?=? ?20400003', skClass),
            weInteger(1),weInteger(2),
          weMatch('Value *:?=? ?20400004', skClass),
            weInteger(1),weInteger(2),
          weInteger(1),weInteger(2),
        weMatch('Value *:?=? ?10200004', skClass), //[0,4]
          weInteger(1),weInteger(2),
        weMatch('Value *:?=? ?10200005', skClass), //[0,5]
          weInteger(1),weInteger(2),

        weMatch('Value *:?=? ?4', skClass),  //[1,0]
          weMatch('Value *:?=? ?10400003', skClass),
            weInteger(1),weInteger(2),
          weMatch('Value *:?=? ?10400004', skClass),
            weInteger(1),weInteger(2),
          weMatch('Value *:?=? ?20400003', skClass),
            weInteger(1),weInteger(2),
          weMatch('Value *:?=? ?20400004', skClass),
            weInteger(1),weInteger(2),
          weInteger(1),weInteger(2),
        weMatch('Value *:?=? ?20200004', skClass), //[1,4]
          weInteger(1),weInteger(2),
        weMatch('Value *:?=? ?20200005', skClass), //[1,5]
          weInteger(1),weInteger(2),
        weInteger(1),weInteger(2)
      ], 45)).IgnTypeName();

    t.Add('flatten + slice', ':flatten( TObject(@bytes[0]), ( TObject(^byte(:_)+8 ) ) : ( ^byte(:_)[0..7]! ), [max=3])',
        weArray([
            weMatch('.', skClass).IgnAll(),
            weArray(weCardinal([9,10,11,12,13,14,15,16], #1, 1), 8).IgnKindArrayType().IgnTypeName(),
            weArray(weCardinal([17,18,19,20,21,22,23,24], #1, 1), 8).IgnKindArrayType().IgnTypeName()
        ], 3)
      ).IgnTypeName();
    t.Add('flatten + map', '^byte( :flatten(TObject(@bytes[0]), ( TObject(^byte(:_)+8) ), [max=3]) [0..2] ) [0..7]',
        weArray([
            weArray(weCardinal([1,2,3,4,5,6,7,8], #1, 1), 8).IgnKindArrayType().IgnTypeName(),
            weArray(weCardinal([9,10,11,12,13,14,15,16], #1, 1), 8).IgnKindArrayType().IgnTypeName(),
            weArray(weCardinal([17,18,19,20,21,22,23,24], #1, 1), 8).IgnKindArrayType().IgnTypeName()
        ], 3)
      ).IgnTypeName();

    t.Add('i2o', ':i2o(AnIntf1)', weClass([
        weInteger(123).N('a'), weInteger(987).N('b'), weInteger(551177).N('c') ], 'TIntf1'));
    t.Add('i2o', ':i2o(AnIntf2)', weClass([
        weInteger(321).N('x'), weInteger(789).N('y'), weInteger(441188).N('c') ], 'TIntf2'));

    t.EvaluateWatches;
    t.CheckResults;


    t.Clear;
    TFpDebugDebuggerProperties(Debugger.LazDebugger.GetProperties).AutoDeref := True;
    Debugger.RunToNextPause(dcStepOver); // changing settings, requires the cache to be cleared
    t.Add('flatten(autoderef)', ':flatten(f1, NextP, [loop,err])',     weArray([
        weMatch('Value *:?=? ?1', skClass),
        wePointer(weMatch('.', skClass)),
        wePointer(weMatch('.', skClass)),
        wePointer(weMatch('.', skClass)),
        wePointer(weMatch('.', skClass)),
        weMatch('.',skNone).ExpectError()
      ], 6)).IgnTypeName();
    t.Add('flatten(autoderef)', ':flatten(f1, NextP^, [loop,err])',     weArray([
        weMatch('Value *:?=? ?1', skClass),
        weMatch('Value *:?=? ?2', skClass),
        weMatch('Value *:?=? ?3', skClass),
        weMatch('Value *:?=? ?4', skClass),
        weMatch('rec',skNone).ExpectError()
      ], 5)).IgnTypeName();

    t.EvaluateWatches;
    t.CheckResults;

  finally
    TFpDebugDebuggerProperties(Debugger.LazDebugger.GetProperties).AutoDeref := False;
    Debugger.RunToNextPause(dcStop);
    t.Free;
    Debugger.ClearDebuggerMonitors;
    Debugger.FreeDebugger;

    AssertTestErrors;
  end;
end;

procedure TTestWatches.TestWatchesFunctions;
var
  ExeName: String;
  t: TWatchExpectationList;
  Src: TCommonSource;
  BrkPrg: TDBGBreakPoint;
begin
  if SkipTest then exit;
  if not TestControlCanTest(ControlTestWatchFunct) then exit;
  t := nil;

  Src := GetCommonSourceFor('WatchesValuePrg.pas');
  TestCompile(Src, ExeName, '', ' -dSINGLE_BIG_FUNC ');

  AssertTrue('Start debugger', Debugger.StartDebugger(AppDir, ExeName));

  try
    t := TWatchExpectationList.Create(Self);
    t.AcceptSkSimple := [skInteger, skCardinal, skBoolean, skChar, skFloat,
      skString, skAnsiString, skCurrency, skVariant, skWideString,
      skInterface, skEnumValue];
    t.AddTypeNameAlias('integer', 'integer|longint');
    t.AddTypeNameAlias('Char', 'Char|AnsiChar');


    BrkPrg         := Debugger.SetBreakPoint(Src, 'Prg');
    AssertDebuggerNotInErrorState;

    (* ************ Nested Functions ************* *)

    RunToPause(BrkPrg);
    t.Clear;

    t.Add('SomeFuncIntRes()',     weInteger(0)).AddEvalFlag([defAllowFunctionCall]);
    t.Add('SomeFuncInt()',     weInteger(0)).AddEvalFlag([defAllowFunctionCall]);
    t.Add('SomeFuncInt()',     weInteger(1)).AddEvalFlag([defAllowFunctionCall]);
    t.Add('SomeFuncInt()',     weInteger(2)).AddEvalFlag([defAllowFunctionCall]);
    t.Add('FuncIntAdd(3,5)',     weInteger(8)).AddEvalFlag([defAllowFunctionCall]);
    t.Add('FuncIntAdd(-3,-5)',   weInteger(-8)).AddEvalFlag([defAllowFunctionCall]);
    t.Add('FuncIntAdd(3,15)',     weInteger(18)).AddEvalFlag([defAllowFunctionCall]);
    t.Add('FuncIntAdd(3,FuncIntAdd(4,5))',     weInteger(12)).AddEvalFlag([defAllowFunctionCall]);
    t.Add('FuncIntAdd(3,4) + FuncIntAdd(4,5)',     weInteger(16,#1,-1)).AddEvalFlag([defAllowFunctionCall]);
    //t.Add('FuncTooManyArg(3,4,3,4,3,4,3,4,3,4,3,4)',     weInteger(16)).AddEvalFlag([defAllowFunctionCall])^.AddFlag(ehExpectError);
    t.Add('FuncTooManyArg(3,4,3,4,3,4,3,4,3,4,3,4)',     weInteger(123)).AddEvalFlag([defAllowFunctionCall]);

    t.Add('MyClass1.SomeFuncIntResAdd(3)',     weInteger(80)).AddEvalFlag([defAllowFunctionCall]);
    t.Add('MyClass1.SomeFuncIntRes()',     weInteger(80+999)).AddEvalFlag([defAllowFunctionCall]);

    // Error wrong param count
    t.Add('SomeFuncIntRes(1)',     weInteger(0)).AddEvalFlag([defAllowFunctionCall]).ExpectError;
    t.Add('SomeFuncIntRes(1,2)',     weInteger(0)).AddEvalFlag([defAllowFunctionCall]).ExpectError;
    t.Add('FuncIntAdd()',     weInteger(0)).AddEvalFlag([defAllowFunctionCall]).ExpectError;
    t.Add('FuncIntAdd(1)',     weInteger(0)).AddEvalFlag([defAllowFunctionCall]).ExpectError;
    t.Add('FuncIntAdd(1,2,3)',     weInteger(0)).AddEvalFlag([defAllowFunctionCall]).ExpectError;

    t.EvaluateWatches;
    t.CheckResults;


  finally
    Debugger.RunToNextPause(dcStop);
    t.Free;
    Debugger.ClearDebuggerMonitors;
    Debugger.FreeDebugger;

    AssertTestErrors;
  end;
end;

procedure TTestWatches.TestWatchesFunctions2;
var
  ExeName: String;
  t: TWatchExpectationList;
  Src: TCommonSource;
  BrkPrg: TDBGBreakPoint;

  procedure AddTest(AFunc, ARes: String; AExp: TWatchExpectationResult);
  begin
    t.Add(AFunc, AExp).AddEvalFlag([defAllowFunctionCall]).IgnTypeName;
    t.Add('LastRes',     weAnsiStr(ARes)).IgnTypeName;
  end;

begin
  if SkipTest then exit;
  if not TestControlCanTest(ControlTestWatchFunct2) then exit;
  t := nil;

  Src := GetCommonSourceFor(AppDir + 'WatchesFuncPrg.pas');
  TestCompile(Src, ExeName);

  AssertTrue('Start debugger', Debugger.StartDebugger(AppDir, ExeName));

  try
    t := TWatchExpectationList.Create(Self);
    t.AcceptSkSimple := [skInteger, skCardinal, skBoolean, skChar, skFloat,
      skString, skAnsiString, skCurrency, skVariant, skWideString,
      skInterface, skEnumValue];
    t.AddTypeNameAlias('integer', 'integer|longint');
    t.AddTypeNameAlias('Char', 'Char|AnsiChar');


    BrkPrg         := Debugger.SetBreakPoint(Src, 'main');
    AssertDebuggerNotInErrorState;

    (* ************ Nested Functions ************* *)

    RunToPause(BrkPrg);
    t.Clear;

    AddTest('FuncResByte(11)', '11', weCardinal( 2, #1, 1));
    AddTest('FuncResWord(21)', '21', weCardinal( 2, #1, 2));
    AddTest('FuncResInt(31)',  '31', weInteger(-2, #1, 4));
//    AddTest('FuncResInt64(41)','41', weInteger(-2, #1, 8));

    AddTest('FuncByte1(191)',   '191',  weInteger(3, #1, 4));
    AddTest('FuncByte2(11,99)', '1199', weInteger(4, #1, 4));
    AddTest('FuncByte12(1,2,3,4,5,6,7,8,9,11,99,0)', '12345678911990', weInteger(14, #1, 4));

    AddTest('FuncWord1(191)',     '191',  weInteger(3, #1, 4));
    AddTest('FuncWord2(2211,99)', '221199', weInteger(6, #1, 4));
    AddTest('FuncWord12(991,2,3,4,5,6,7,8,9,11,799,0)', '99123456789117990', weInteger(17, #1, 4));

    AddTest('FuncInt1(191)',   '191',  weInteger(3, #1, 4));
    AddTest('FuncInt2(11,99)', '1199', weInteger(4, #1, 4));
    AddTest('FuncInt12(3000001,2,3,4,5,6,7,8,9,11,2000099,0)', '3000001234567891120000990', weInteger(25, #1, 4));

    AddTest('FuncQWord1(191)',   '191',  weInteger(3, #1, 4));
    AddTest('FuncQWord2(11,99)', '1199', weInteger(4, #1, 4));
    AddTest('FuncQWord12(40000000000001,2,3,4,5,6,7,8,9,11,300000000000099,0)', '4000000000000123456789113000000000000990', weInteger(40, #1, 4));


    AddTest('foo.FuncInt12(1,2,3,4,5,6,7,8,9,11,99,0)', '12345678911990201', weInteger(17, #1, 4));




    //t.Add('FuncResByte(11)',  weInteger(2)).AddEvalFlag([defAllowFunctionCall]);
    //t.Add('LastRes',     weAnsiStr('')).IgnTypeName;

    t.EvaluateWatches;
    t.CheckResults;


  finally
    Debugger.RunToNextPause(dcStop);
    t.Free;
    Debugger.ClearDebuggerMonitors;
    Debugger.FreeDebugger;

    AssertTestErrors;
  end;

end;

procedure TTestWatches.TestWatchesFunctionsWithString;
var
  MemUsed, PrevMemUsed: Int64;
  t2: TWatchExpectationList;

  procedure UpdateMemUsed;
  var
    Thread: Integer;
    WtchVal: TWatchValue;
  begin
    PrevMemUsed := MemUsed;
    MemUsed := -1;
    t2.Clear;
    t2.AddWithoutExpect('', 'CurMemUsed');
    t2.EvaluateWatches;
    Thread := Debugger.Threads.Threads.CurrentThreadId;
    WtchVal := t2.Tests[0]^.TstWatch.Values[Thread, 0];
    if (WtchVal <> nil) and (WtchVal.ResultData <> nil) then
      MemUsed := WtchVal.ResultData.AsInt64;
    TestTrue('MemUsed <> 0', MemUsed > 0);
  end;
  procedure CheckMemUsed;
  begin
    Debugger.RunToNextPause(dcStepOver);
    UpdateMemUsed;
    TestEquals('MemUsed not changed', PrevMemUsed, MemUsed);
  end;

var
  t: TWatchExpectationList;
  TstSkipAll: Boolean;

  procedure CheckAndClear;
  var
    i: Integer;
  begin
    for i := 0 to t.Count - 1 do begin
      t.Tests[i]
        .AddEvalFlag([defAllowFunctionCall])
        .IgnTypeName
        .SkipEval;
      if TstSkipAll then
        t.Tests[i].IgnAll;
    end;
    t.EvalAndCheck;
    CheckMemUsed;

    t.Clear;
  end;

var
  ExeName, tbn: String;
  Src: TCommonSource;
  BrkPrg: TDBGBreakPoint;
  i: Integer;
begin
  if SkipTest then exit;
  if not TestControlCanTest(ControlTestWatchFunctStr) then exit;
  if not (Compiler.SymbolType in [stDwarf3, stDwarf4]) then exit;
  if Compiler.HasFlag('SkipStringFunc') then exit;
  if Compiler.HasFlag('Dwarf2') then exit;
  tbn := TestBaseName;

  try
  for i := 0 to 2 do begin
    TestBaseName := tbn;
    TestBaseName := TestBaseName + ' -O'+IntToStr(i);

    Src := GetCommonSourceFor(AppDir + 'WatchesFuncStringPrg.pas');
    case i of
      0: TestCompile(Src, ExeName, '_O0', '-O-');
      1: TestCompile(Src, ExeName, '_O1', '-O-1');
      2: TestCompile(Src, ExeName, '_O2', '-O-2');
    end;

    t := nil;
    t2 := nil;

    AssertTrue('Start debugger', Debugger.StartDebugger(AppDir, ExeName));

    try
      t := TWatchExpectationList.Create(Self);
      t2 := TWatchExpectationList.Create(Self);
      t.AcceptSkSimple := [skInteger, skCardinal, skBoolean, skChar, skFloat,
        skString, skAnsiString, skCurrency, skVariant, skWideString,
        skInterface, skEnumValue];
      t.AddTypeNameAlias('integer', 'integer|longint');
      t.AddTypeNameAlias('Char', 'Char|AnsiChar');


      BrkPrg         := Debugger.SetBreakPoint(Src, 'main');
      AssertDebuggerNotInErrorState;

      (* ************ Nested Functions ************* *)

      RunToPause(BrkPrg);

      UpdateMemUsed;
      t.Clear;
      TstSkipAll := False;

      t.Add('TestStrRes()',     weAnsiStr('#0'));
      CheckAndClear;
      t.Add('TestStrRes()',     weAnsiStr('#1'));
      CheckAndClear;
      t.Add('TestIntToStrRes(33)',     weAnsiStr('$00000021'));
      CheckAndClear;
      t.Add('TestIntToStrRes(SomeInt)',     weAnsiStr('$0000007E'));
      CheckAndClear;
      t.Add('TestIntSumToStrRes(10,20)',     weAnsiStr('$0000001E'));
      CheckAndClear;
      t.Add('TestIntSumToStrRes(SomeInt,3)',     weAnsiStr('$00000081'));
      CheckAndClear;


      t.Add('TestStrToIntRes(s1)',     weInteger(0));
      t.Add('s1',     weAnsiStr(''));
      CheckAndClear;
      t.Add('TestStrToIntRes(s2)',     weInteger(4));
      t.Add('s2',     weAnsiStr('A'));
      CheckAndClear;
      t.Add('TestStrToIntRes(s3)',     weInteger(3));
      t.Add('s3',     weAnsiStr('abc'));
      CheckAndClear;

      t.Add('TestStrToIntRes('''')',     weInteger(0));
      CheckAndClear;
      t.Add('TestStrToIntRes(''abcde'')',     weInteger(5));
      CheckAndClear;
      t.Add('TestStrToIntRes(''a'')',     weInteger(4));
      CheckAndClear;
      t.Add('TestStrToIntRes(TestIntToStrRes(111))',     weInteger(9));
      CheckAndClear;
      t.Add('TestStrToIntRes(TestIntToStrRes(111)+''abc'')',     weInteger(12));
      CheckAndClear;


      t.Add('TestStrToStrRes(s1)',     weAnsiStr('"0"'));
      t.Add('s1',     weAnsiStr(''));
      CheckAndClear;
      t.Add('TestStrToStrRes(s2)',     weAnsiStr('"4"'));
      t.Add('s2',     weAnsiStr('A'));
      CheckAndClear;
      t.Add('TestStrToStrRes(s3)',     weAnsiStr('"3"'));
      t.Add('s3',     weAnsiStr('abc'));
      CheckAndClear;


      t.Add('conc(s1, s2)',     weAnsiStr('A'));
      CheckAndClear;
      t.Add('conc(s3, s4)',     weAnsiStr('abcdef'));
      CheckAndClear;
      t.Add('conc('''', s4)',     weAnsiStr('def'));
      CheckAndClear;
      t.Add('conc(''A'', s4)',     weAnsiStr('Adef'));
      CheckAndClear;
      t.Add('conc(''AB'', s4)',     weAnsiStr('ABdef'));
      CheckAndClear;

      // widestring
(* TODO: FpDebug currenly reports PWideChar *)

      {$IFnDEF WINDOWS}
      TstSkipAll := True;
      {$ENDIF}
      if Compiler.Version >= 030200 then begin
        t.Add('wTestStrRes()',     weWideStr('#2'));
        CheckAndClear;
        t.Add('wTestStrRes()',     weWideStr('#3'));
        CheckAndClear;
        t.Add('wTestIntToStrRes(33)',     weWideStr('$00000021'));
        CheckAndClear;
        t.Add('wTestIntToStrRes(SomeInt)',     weWideStr('$0000007E'));
        CheckAndClear;
        t.Add('wTestIntSumToStrRes(10,20)',     weWideStr('$0000001E'));
        CheckAndClear;
        t.Add('wTestIntSumToStrRes(SomeInt,3)',     weWideStr('$00000081'));
        CheckAndClear;
      end;


      t.Add('wTestStrToIntRes(ws1)',     weInteger(0));
      t.Add('ws1',     weWideStr(''));
      CheckAndClear;
      t.Add('wTestStrToIntRes(ws2)',     weInteger(4));
      t.Add('ws2',     weWideStr('A'));
      CheckAndClear;
      t.Add('wTestStrToIntRes(ws3)',     weInteger(3));
      t.Add('ws3',     weWideStr('abc'));
      CheckAndClear;

      t.Add('wTestStrToIntRes('''')',     weInteger(0))
        .IgnData([], Compiler.Version < 030200);
      CheckAndClear;
      t.Add('wTestStrToIntRes(''abcde'')',     weInteger(5))
        .IgnData([], Compiler.Version < 030200);
      CheckAndClear;
      t.Add('wTestStrToIntRes(''a'')',     weInteger(4))
        .IgnData([], Compiler.Version < 030200);
      CheckAndClear;
      if Compiler.Version >= 030200 then begin
        t.Add('wTestStrToIntRes(wTestIntToStrRes(111))',     weInteger(9));
        CheckAndClear;
        t.Add('wTestStrToIntRes(wTestIntToStrRes(111)+''abc'')',     weInteger(12));
        CheckAndClear;
      end;


      if Compiler.Version >= 030200 then begin
        t.Add('wTestStrToStrRes(ws1)',     weWideStr('"0"'));
        t.Add('ws1',     weWideStr(''));
        CheckAndClear;
        t.Add('wTestStrToStrRes(ws2)',     weWideStr('"4"'));
        t.Add('ws2',     weWideStr('A'));
        CheckAndClear;
        t.Add('wTestStrToStrRes(ws3)',     weWideStr('"3"'));
        t.Add('ws3',     weWideStr('abc'));
        CheckAndClear;


        t.Add('wconc(ws1, ws2)',     weWideStr('A'));
        CheckAndClear;
        t.Add('wconc(ws3, ws4)',     weWideStr('abcdef'));
        CheckAndClear;
        t.Add('wconc('''', ws4)',     weWideStr('def'));
        CheckAndClear;
        t.Add('wconc(''A'', ws4)',     weWideStr('Adef'));
        CheckAndClear;
        t.Add('wconc(''AB'', ws4)',     weWideStr('ABdef'));
        CheckAndClear;
      end;



    finally
      Debugger.RunToNextPause(dcStop);
      FreeAndNil(t);
      FreeAndNil(t2);
      Debugger.ClearDebuggerMonitors;
      Debugger.FreeDebugger;
    end;

  end;
  finally
    AssertTestErrors;
  end;

end;

procedure TTestWatches.TestWatchesFunctionsWithRecord;
var
  ExeName, tbn: String;
  t: TWatchExpectationList;
  Src: TCommonSource;
  BrkPrg: TDBGBreakPoint;
  i, p: Integer;
begin
  if SkipTest then exit;
  if not TestControlCanTest(ControlTestWatchFunctRec) then exit;
  //if not (Compiler.SymbolType in [stDwarf3, stDwarf4]) then exit;
  //if Compiler.HasFlag('SkipStringFunc') then exit;
  tbn := TestBaseName;

  try
  for p := 0 to 3 do
  for i := 0 to 2 do begin
    TestBaseName := tbn;
    TestBaseName := TestBaseName + ' -O'+IntToStr(i) + ' (def: ' + IntToStr(p) + ')';

    Src := GetCommonSourceFor(AppDir + 'WatchesFuncRecordPrg.pas');
    case p of
      0: case i of
           0: TestCompile(Src, ExeName, '_O0', '-O-');
           1: TestCompile(Src, ExeName, '_O1', '-O-1');
           2: TestCompile(Src, ExeName, '_O2', '-O-2');
         end;
      1: case i of
           0: TestCompile(Src, ExeName, '_O0_pack', '-dPCKREC -O-');
           1: TestCompile(Src, ExeName, '_O1_pack', '-dPCKREC -O-1');
           2: TestCompile(Src, ExeName, '_O2_pack', '-dPCKREC -O-2');
         end;
      2: case i of
           0: TestCompile(Src, ExeName, '_O0_pack_padbyte', '-dPCKREC -dRECPAD1 -O-');
           1: TestCompile(Src, ExeName, '_O1_pack_padbyte', '-dPCKREC -dRECPAD1 -O-1');
           2: TestCompile(Src, ExeName, '_O2_pack_padbyte', '-dPCKREC -dRECPAD1 -O-2');
         end;
      3: case i of
           0: TestCompile(Src, ExeName, '_O0_pack_padword', '-dPCKREC -dRECPAD1 -dRECPAD2 -O-');
           1: TestCompile(Src, ExeName, '_O1_pack_padword', '-dPCKREC -dRECPAD1 -dRECPAD2 -O-1');
           2: TestCompile(Src, ExeName, '_O2_pack_padword', '-dPCKREC -dRECPAD1 -dRECPAD2 -O-2');
         end;
    end;

    t := nil;

    AssertTrue('Start debugger', Debugger.StartDebugger(AppDir, ExeName));

    try
      t := TWatchExpectationList.Create(Self);
      t.AcceptSkSimple := [skInteger, skCardinal, skBoolean, skChar, skFloat,
        skString, skAnsiString, skCurrency, skVariant, skWideString,
        skInterface, skEnumValue];
      t.AddTypeNameAlias('integer', 'integer|longint');
      t.AddTypeNameAlias('Char', 'Char|AnsiChar');


      BrkPrg         := Debugger.SetBreakPoint(Src, 'main');
      AssertDebuggerNotInErrorState;

      (* ************ Nested Functions ************* *)

      RunToPause(BrkPrg);


      t.Clear;

      t.Add('TestRecN2_a(aRecN2)', weCardinal(11)).AddEvalFlag([defAllowFunctionCall]).IgnTypeName.SkipEval;
      t.Add('TestRecN2_b(aRecN2)', weCardinal(12)).AddEvalFlag([defAllowFunctionCall]).IgnTypeName.SkipEval;

      t.Add('TestRecB2_a(aRecB2)', weCardinal(11)).AddEvalFlag([defAllowFunctionCall]).IgnTypeName.SkipEval;
      t.Add('TestRecB2_b(aRecB2)', weCardinal(21)).AddEvalFlag([defAllowFunctionCall]).IgnTypeName.SkipEval;
      t.Add('TestRecB2_a(bRecB2)', weCardinal(51)).AddEvalFlag([defAllowFunctionCall]).IgnTypeName.SkipEval;
      t.Add('TestRecB2_b(bRecB2)', weCardinal(61)).AddEvalFlag([defAllowFunctionCall]).IgnTypeName.SkipEval;
      t.Add('aRecB2.a', weCardinal(11, #1, -1)).IgnTypeName.SkipEval.IgnKind;
      t.Add('bRecB2.a', weCardinal(51, #1, -1)).IgnTypeName.SkipEval.IgnKind;

      t.Add('TestRecW2_a(aRecW2)', weCardinal(12)).AddEvalFlag([defAllowFunctionCall]).IgnTypeName.SkipEval;
      t.Add('TestRecW2_b(aRecW2)', weCardinal(22)).AddEvalFlag([defAllowFunctionCall]).IgnTypeName.SkipEval;
      t.Add('TestRecW2_a(bRecW2)', weCardinal(52)).AddEvalFlag([defAllowFunctionCall]).IgnTypeName.SkipEval;
      t.Add('TestRecW2_b(bRecW2)', weCardinal(62)).AddEvalFlag([defAllowFunctionCall]).IgnTypeName.SkipEval;
      t.Add('aRecW2.a', weCardinal(12, #1, -1)).IgnTypeName.SkipEval.IgnKind;
      t.Add('bRecW2.a', weCardinal(52, #1, -1)).IgnTypeName.SkipEval.IgnKind;

      t.Add('TestRecC2_a(aRecC2)', weCardinal(13)).AddEvalFlag([defAllowFunctionCall]).IgnTypeName.SkipEval;
      t.Add('TestRecC2_b(aRecC2)', weCardinal(23)).AddEvalFlag([defAllowFunctionCall]).IgnTypeName.SkipEval;
      t.Add('TestRecC2_a(bRecC2)', weCardinal(53)).AddEvalFlag([defAllowFunctionCall]).IgnTypeName.SkipEval;
      t.Add('TestRecC2_b(bRecC2)', weCardinal(63)).AddEvalFlag([defAllowFunctionCall]).IgnTypeName.SkipEval;
      t.Add('aRecC2.a', weCardinal(13, #1, -1)).IgnTypeName.SkipEval.IgnKind;
      t.Add('bRecC2.a', weCardinal(53, #1, -1)).IgnTypeName.SkipEval.IgnKind;

      t.Add('TestRecQ2_a(aRecQ2)', weCardinal(14)).AddEvalFlag([defAllowFunctionCall]).IgnTypeName.SkipEval;
      t.Add('TestRecQ2_b(aRecQ2)', weCardinal(24)).AddEvalFlag([defAllowFunctionCall]).IgnTypeName.SkipEval;
      t.Add('TestRecQ2_a(bRecQ2)', weCardinal(54)).AddEvalFlag([defAllowFunctionCall]).IgnTypeName.SkipEval;
      t.Add('TestRecQ2_b(bRecQ2)', weCardinal(64)).AddEvalFlag([defAllowFunctionCall]).IgnTypeName.SkipEval;
      t.Add('aRecQ2.a', weCardinal(14, #1, -1)).IgnTypeName.SkipEval.IgnKind;
      t.Add('bRecQ2.a', weCardinal(54, #1, -1)).IgnTypeName.SkipEval.IgnKind;


      t.Add('TestRecB3_a(aRecB3)', weCardinal(15)).AddEvalFlag([defAllowFunctionCall]).IgnTypeName.SkipEval;
      t.Add('TestRecB3_c(aRecB3)', weCardinal(35)).AddEvalFlag([defAllowFunctionCall]).IgnTypeName.SkipEval;
      t.Add('aRecB3.a', weCardinal(15, #1, -1)).IgnTypeName.SkipEval.IgnKind;

      t.Add('TestRecW3_a(aRecW3)', weCardinal(16)).AddEvalFlag([defAllowFunctionCall]).IgnTypeName.SkipEval;
      t.Add('TestRecW3_c(aRecW3)', weCardinal(36)).AddEvalFlag([defAllowFunctionCall]).IgnTypeName.SkipEval;
      t.Add('aRecW3.a', weCardinal(16, #1, -1)).IgnTypeName.SkipEval.IgnKind;

      t.Add('TestRecC3_a(aRecC3)', weCardinal(17)).AddEvalFlag([defAllowFunctionCall]).IgnTypeName.SkipEval;
      t.Add('TestRecC3_c(aRecC3)', weCardinal(37)).AddEvalFlag([defAllowFunctionCall]).IgnTypeName.SkipEval;
      t.Add('aRecC3.a', weCardinal(17, #1, -1)).IgnTypeName.SkipEval.IgnKind;

      t.Add('TestRecQ3_a(aRecQ3)', weCardinal(18)).AddEvalFlag([defAllowFunctionCall]).IgnTypeName.SkipEval;
      t.Add('TestRecQ3_c(aRecQ3)', weCardinal(38)).AddEvalFlag([defAllowFunctionCall]).IgnTypeName.SkipEval;
      t.Add('aRecQ3.a', weCardinal(18, #1, -1)).IgnTypeName.SkipEval.IgnKind;


      t.Add('Test1RecB2(aRecB2, 0)', weCardinal(11)).AddEvalFlag([defAllowFunctionCall]).IgnTypeName.SkipEval;
      t.Add('Test1RecB2(aRecB2, 1)', weCardinal(21)).AddEvalFlag([defAllowFunctionCall]).IgnTypeName.SkipEval;

      t.Add('Test1RecW2(aRecW2, 0)', weCardinal(12)).AddEvalFlag([defAllowFunctionCall]).IgnTypeName.SkipEval;
      t.Add('Test1RecW2(aRecW2, 1)', weCardinal(22)).AddEvalFlag([defAllowFunctionCall]).IgnTypeName.SkipEval;

      t.Add('Test1RecC2(aRecC2, 0)', weCardinal(13)).AddEvalFlag([defAllowFunctionCall]).IgnTypeName.SkipEval;
      t.Add('Test1RecC2(aRecC2, 1)', weCardinal(23)).AddEvalFlag([defAllowFunctionCall]).IgnTypeName.SkipEval;

      t.Add('Test1RecQ2(aRecQ2, 0)', weCardinal(14)).AddEvalFlag([defAllowFunctionCall]).IgnTypeName.SkipEval;
      t.Add('Test1RecQ2(aRecQ2, 1)', weCardinal(24)).AddEvalFlag([defAllowFunctionCall]).IgnTypeName.SkipEval;


      t.Add('Test2RecB2(0, aRecB2)', weCardinal(11)).AddEvalFlag([defAllowFunctionCall]).IgnTypeName.SkipEval;
      t.Add('Test2RecB2(1, aRecB2)', weCardinal(21)).AddEvalFlag([defAllowFunctionCall]).IgnTypeName.SkipEval;

      t.Add('Test2RecW2(0, aRecW2)', weCardinal(12)).AddEvalFlag([defAllowFunctionCall]).IgnTypeName.SkipEval;
      t.Add('Test2RecW2(1, aRecW2)', weCardinal(22)).AddEvalFlag([defAllowFunctionCall]).IgnTypeName.SkipEval;

      t.Add('Test2RecC2(0, aRecC2)', weCardinal(13)).AddEvalFlag([defAllowFunctionCall]).IgnTypeName.SkipEval;
      t.Add('Test2RecC2(1, aRecC2)', weCardinal(23)).AddEvalFlag([defAllowFunctionCall]).IgnTypeName.SkipEval;

      t.Add('Test2RecQ2(0, aRecQ2)', weCardinal(14)).AddEvalFlag([defAllowFunctionCall]).IgnTypeName.SkipEval;
      t.Add('Test2RecQ2(1, aRecQ2)', weCardinal(24)).AddEvalFlag([defAllowFunctionCall]).IgnTypeName.SkipEval;

      t.Add('aRecB2.a', weCardinal(11, #1, -1)).IgnTypeName.SkipEval.IgnKind;
      t.Add('aRecW2.a', weCardinal(12, #1, -1)).IgnTypeName.SkipEval.IgnKind;
      t.Add('aRecC2.a', weCardinal(13, #1, -1)).IgnTypeName.SkipEval.IgnKind;
      t.Add('aRecQ2.a', weCardinal(14, #1, -1)).IgnTypeName.SkipEval.IgnKind;


      t.Add('TestRecN2N2_1(aRecN2, bRecN2)', weCardinal(11)).AddEvalFlag([defAllowFunctionCall]).IgnTypeName.SkipEval;
      t.Add('TestRecN2N2_2(aRecN2, bRecN2)', weCardinal(8)).AddEvalFlag([defAllowFunctionCall]).IgnTypeName.SkipEval;

      t.Add('TestRecB2B2_1(aRecB2, bRecB2)', weCardinal(11)).AddEvalFlag([defAllowFunctionCall]).IgnTypeName.SkipEval;
      t.Add('TestRecB2B2_2(aRecB2, bRecB2)', weCardinal(51)).AddEvalFlag([defAllowFunctionCall]).IgnTypeName.SkipEval;
      t.Add('TestRecW2W2_1(aRecW2, bRecW2)', weCardinal(12)).AddEvalFlag([defAllowFunctionCall]).IgnTypeName.SkipEval;
      t.Add('TestRecW2W2_2(aRecW2, bRecW2)', weCardinal(52)).AddEvalFlag([defAllowFunctionCall]).IgnTypeName.SkipEval;
      t.Add('TestRecC2C2_1(aRecC2, bRecC2)', weCardinal(13)).AddEvalFlag([defAllowFunctionCall]).IgnTypeName.SkipEval;
      t.Add('TestRecC2C2_2(aRecC2, bRecC2)', weCardinal(53)).AddEvalFlag([defAllowFunctionCall]).IgnTypeName.SkipEval;
      t.Add('TestRecQ2Q2_1(aRecQ2, bRecQ2)', weCardinal(14)).AddEvalFlag([defAllowFunctionCall]).IgnTypeName.SkipEval;
      t.Add('TestRecQ2Q2_2(aRecQ2, bRecQ2)', weCardinal(54)).AddEvalFlag([defAllowFunctionCall]).IgnTypeName.SkipEval;

      t.Add('Test1RecB2B2(aRecB2, bRecB2, 0)', weCardinal(11)).AddEvalFlag([defAllowFunctionCall]).IgnTypeName.SkipEval;
      t.Add('Test1RecB2B2(aRecB2, bRecB2, 1)', weCardinal(51)).AddEvalFlag([defAllowFunctionCall]).IgnTypeName.SkipEval;
      t.Add('Test1RecW2W2(aRecW2, bRecW2, 0)', weCardinal(12)).AddEvalFlag([defAllowFunctionCall]).IgnTypeName.SkipEval;
      t.Add('Test1RecW2W2(aRecW2, bRecW2, 1)', weCardinal(52)).AddEvalFlag([defAllowFunctionCall]).IgnTypeName.SkipEval;
      t.Add('Test1RecC2C2(aRecC2, bRecC2, 0)', weCardinal(13)).AddEvalFlag([defAllowFunctionCall]).IgnTypeName.SkipEval;
      t.Add('Test1RecC2C2(aRecC2, bRecC2, 1)', weCardinal(53)).AddEvalFlag([defAllowFunctionCall]).IgnTypeName.SkipEval;
      t.Add('Test1RecQ2Q2(aRecQ2, bRecQ2, 0)', weCardinal(14)).AddEvalFlag([defAllowFunctionCall]).IgnTypeName.SkipEval;
      t.Add('Test1RecQ2Q2(aRecQ2, bRecQ2, 1)', weCardinal(54)).AddEvalFlag([defAllowFunctionCall]).IgnTypeName.SkipEval;

      t.Add('Test2RecB2B2(0, aRecB2, bRecB2)', weCardinal(11)).AddEvalFlag([defAllowFunctionCall]).IgnTypeName.SkipEval;
      t.Add('Test2RecB2B2(1, aRecB2, bRecB2)', weCardinal(51)).AddEvalFlag([defAllowFunctionCall]).IgnTypeName.SkipEval;
      t.Add('Test2RecW2W2(0, aRecW2, bRecW2)', weCardinal(12)).AddEvalFlag([defAllowFunctionCall]).IgnTypeName.SkipEval;
      t.Add('Test2RecW2W2(1, aRecW2, bRecW2)', weCardinal(52)).AddEvalFlag([defAllowFunctionCall]).IgnTypeName.SkipEval;
      t.Add('Test2RecC2C2(0, aRecC2, bRecC2)', weCardinal(13)).AddEvalFlag([defAllowFunctionCall]).IgnTypeName.SkipEval;
      t.Add('Test2RecC2C2(1, aRecC2, bRecC2)', weCardinal(53)).AddEvalFlag([defAllowFunctionCall]).IgnTypeName.SkipEval;
      t.Add('Test2RecQ2Q2(0, aRecQ2, bRecQ2)', weCardinal(14)).AddEvalFlag([defAllowFunctionCall]).IgnTypeName.SkipEval;
      t.Add('Test2RecQ2Q2(1, aRecQ2, bRecQ2)', weCardinal(54)).AddEvalFlag([defAllowFunctionCall]).IgnTypeName.SkipEval;

      t.Add('aRecB2.a', weCardinal(11, #1, -1)).IgnTypeName.SkipEval.IgnKind;
      t.Add('aRecW2.a', weCardinal(12, #1, -1)).IgnTypeName.SkipEval.IgnKind;
      t.Add('aRecC2.a', weCardinal(13, #1, -1)).IgnTypeName.SkipEval.IgnKind;
      t.Add('aRecQ2.a', weCardinal(14, #1, -1)).IgnTypeName.SkipEval.IgnKind;
      t.Add('bRecB2.a', weCardinal(51, #1, -1)).IgnTypeName.SkipEval.IgnKind;
      t.Add('bRecW2.a', weCardinal(52, #1, -1)).IgnTypeName.SkipEval.IgnKind;
      t.Add('bRecC2.a', weCardinal(53, #1, -1)).IgnTypeName.SkipEval.IgnKind;
      t.Add('bRecQ2.a', weCardinal(54, #1, -1)).IgnTypeName.SkipEval.IgnKind;


      t.Add('TestRecB2B3_1(aRecB2, bRecB3)', weCardinal(11)).AddEvalFlag([defAllowFunctionCall]).IgnTypeName.SkipEval;
      t.Add('TestRecB2Q2_1(aRecB2, bRecQ2)', weCardinal(11)).AddEvalFlag([defAllowFunctionCall]).IgnTypeName.SkipEval;
      t.Add('TestRecB3B2_1(aRecB3, bRecB2)', weCardinal(15)).AddEvalFlag([defAllowFunctionCall]).IgnTypeName.SkipEval;
      t.Add('TestRecB3Q2_1(aRecB3, bRecQ2)', weCardinal(15)).AddEvalFlag([defAllowFunctionCall]).IgnTypeName.SkipEval;
      t.Add('TestRecQ2B2_1(aRecQ2, bRecB2)', weCardinal(14)).AddEvalFlag([defAllowFunctionCall]).IgnTypeName.SkipEval;
      t.Add('TestRecQ2B3_1(aRecQ2, bRecB3)', weCardinal(14)).AddEvalFlag([defAllowFunctionCall]).IgnTypeName.SkipEval;
      t.Add('TestRecB2B3_2(aRecB2, bRecB3)', weCardinal(55)).AddEvalFlag([defAllowFunctionCall]).IgnTypeName.SkipEval;
      t.Add('TestRecB2Q2_2(aRecB2, bRecQ2)', weCardinal(54)).AddEvalFlag([defAllowFunctionCall]).IgnTypeName.SkipEval;
      t.Add('TestRecB3B2_2(aRecB3, bRecB2)', weCardinal(51)).AddEvalFlag([defAllowFunctionCall]).IgnTypeName.SkipEval;
      t.Add('TestRecB3Q2_2(aRecB3, bRecQ2)', weCardinal(54)).AddEvalFlag([defAllowFunctionCall]).IgnTypeName.SkipEval;
      t.Add('TestRecQ2B2_2(aRecQ2, bRecB2)', weCardinal(51)).AddEvalFlag([defAllowFunctionCall]).IgnTypeName.SkipEval;
      t.Add('TestRecQ2B3_2(aRecQ2, bRecB3)', weCardinal(55)).AddEvalFlag([defAllowFunctionCall]).IgnTypeName.SkipEval;


      t.Add('Test1RecB2B3(aRecB2, bRecB3, 0)', weCardinal(11)).AddEvalFlag([defAllowFunctionCall]).IgnTypeName.SkipEval;
      t.Add('Test1RecB2Q2(aRecB2, bRecQ2, 0)', weCardinal(11)).AddEvalFlag([defAllowFunctionCall]).IgnTypeName.SkipEval;
      t.Add('Test1RecB3B2(aRecB3, bRecB2, 0)', weCardinal(15)).AddEvalFlag([defAllowFunctionCall]).IgnTypeName.SkipEval;
      t.Add('Test1RecB3Q2(aRecB3, bRecQ2, 0)', weCardinal(15)).AddEvalFlag([defAllowFunctionCall]).IgnTypeName.SkipEval;
      t.Add('Test1RecQ2B2(aRecQ2, bRecB2, 0)', weCardinal(14)).AddEvalFlag([defAllowFunctionCall]).IgnTypeName.SkipEval;
      t.Add('Test1RecQ2B3(aRecQ2, bRecB3, 0)', weCardinal(14)).AddEvalFlag([defAllowFunctionCall]).IgnTypeName.SkipEval;
      t.Add('Test1RecB2B3(aRecB2, bRecB3, 1)', weCardinal(55)).AddEvalFlag([defAllowFunctionCall]).IgnTypeName.SkipEval;
      t.Add('Test1RecB2Q2(aRecB2, bRecQ2, 1)', weCardinal(54)).AddEvalFlag([defAllowFunctionCall]).IgnTypeName.SkipEval;
      t.Add('Test1RecB3B2(aRecB3, bRecB2, 1)', weCardinal(51)).AddEvalFlag([defAllowFunctionCall]).IgnTypeName.SkipEval;
      t.Add('Test1RecB3Q2(aRecB3, bRecQ2, 1)', weCardinal(54)).AddEvalFlag([defAllowFunctionCall]).IgnTypeName.SkipEval;
      t.Add('Test1RecQ2B2(aRecQ2, bRecB2, 1)', weCardinal(51)).AddEvalFlag([defAllowFunctionCall]).IgnTypeName.SkipEval;
      t.Add('Test1RecQ2B3(aRecQ2, bRecB3, 1)', weCardinal(55)).AddEvalFlag([defAllowFunctionCall]).IgnTypeName.SkipEval;


      t.Add('Test2RecB2B3(0, aRecB2, bRecB3)', weCardinal(11)).AddEvalFlag([defAllowFunctionCall]).IgnTypeName.SkipEval;
      t.Add('Test2RecB2Q2(0, aRecB2, bRecQ2)', weCardinal(11)).AddEvalFlag([defAllowFunctionCall]).IgnTypeName.SkipEval;
      t.Add('Test2RecB3B2(0, aRecB3, bRecB2)', weCardinal(15)).AddEvalFlag([defAllowFunctionCall]).IgnTypeName.SkipEval;
      t.Add('Test2RecB3Q2(0, aRecB3, bRecQ2)', weCardinal(15)).AddEvalFlag([defAllowFunctionCall]).IgnTypeName.SkipEval;
      t.Add('Test2RecQ2B2(0, aRecQ2, bRecB2)', weCardinal(14)).AddEvalFlag([defAllowFunctionCall]).IgnTypeName.SkipEval;
      t.Add('Test2RecQ2B3(0, aRecQ2, bRecB3)', weCardinal(14)).AddEvalFlag([defAllowFunctionCall]).IgnTypeName.SkipEval;
      t.Add('Test2RecB2B3(1, aRecB2, bRecB3)', weCardinal(55)).AddEvalFlag([defAllowFunctionCall]).IgnTypeName.SkipEval;
      t.Add('Test2RecB2Q2(1, aRecB2, bRecQ2)', weCardinal(54)).AddEvalFlag([defAllowFunctionCall]).IgnTypeName.SkipEval;
      t.Add('Test2RecB3B2(1, aRecB3, bRecB2)', weCardinal(51)).AddEvalFlag([defAllowFunctionCall]).IgnTypeName.SkipEval;
      t.Add('Test2RecB3Q2(1, aRecB3, bRecQ2)', weCardinal(54)).AddEvalFlag([defAllowFunctionCall]).IgnTypeName.SkipEval;
      t.Add('Test2RecQ2B2(1, aRecQ2, bRecB2)', weCardinal(51)).AddEvalFlag([defAllowFunctionCall]).IgnTypeName.SkipEval;
      t.Add('Test2RecQ2B3(1, aRecQ2, bRecB3)', weCardinal(55)).AddEvalFlag([defAllowFunctionCall]).IgnTypeName.SkipEval;

      t.Add('Test2RecQ3Q3(0, aRecQ3, bRecQ3)', weCardinal(18)).AddEvalFlag([defAllowFunctionCall]).IgnTypeName.SkipEval;
      t.Add('Test2RecQ3Q3(1, aRecQ3, bRecQ3)', weCardinal(38)).AddEvalFlag([defAllowFunctionCall]).IgnTypeName.SkipEval;
      t.Add('Test2RecQ3Q3(2, aRecQ3, bRecQ3)', weCardinal(58)).AddEvalFlag([defAllowFunctionCall]).IgnTypeName.SkipEval;
      t.Add('Test2RecQ3Q3(3, aRecQ3, bRecQ3)', weCardinal(78)).AddEvalFlag([defAllowFunctionCall]).IgnTypeName.SkipEval;

      t.Add('Test2RecQ4Q4(0, aRecQ4, bRecQ4)', weCardinal(58)).AddEvalFlag([defAllowFunctionCall]).IgnTypeName.SkipEval;
      t.Add('Test2RecQ4Q4(1, aRecQ4, bRecQ4)', weCardinal( 2)).AddEvalFlag([defAllowFunctionCall]).IgnTypeName.SkipEval;
      t.Add('Test2RecQ4Q4(2, aRecQ4, bRecQ4)', weCardinal(59)).AddEvalFlag([defAllowFunctionCall]).IgnTypeName.SkipEval;
      t.Add('Test2RecQ4Q4(3, aRecQ4, bRecQ4)', weCardinal(92)).AddEvalFlag([defAllowFunctionCall]).IgnTypeName.SkipEval;

      t.Add('Test2RecQ5Q5(0, aRecQ5, bRecQ5)', weCardinal(58)).AddEvalFlag([defAllowFunctionCall]).IgnTypeName.SkipEval;
      t.Add('Test2RecQ5Q5(1, aRecQ5, bRecQ5)', weCardinal( 3)).AddEvalFlag([defAllowFunctionCall]).IgnTypeName.SkipEval;
      t.Add('Test2RecQ5Q5(2, aRecQ5, bRecQ5)', weCardinal(59)).AddEvalFlag([defAllowFunctionCall]).IgnTypeName.SkipEval;
      t.Add('Test2RecQ5Q5(3, aRecQ5, bRecQ5)', weCardinal(93)).AddEvalFlag([defAllowFunctionCall]).IgnTypeName.SkipEval;

      t.Add('Test2RecQ6Q6(0, aRecQ6, bRecQ6)', weCardinal(58)).AddEvalFlag([defAllowFunctionCall]).IgnTypeName.SkipEval;
      t.Add('Test2RecQ6Q6(1, aRecQ6, bRecQ6)', weCardinal( 4)).AddEvalFlag([defAllowFunctionCall]).IgnTypeName.SkipEval;
      t.Add('Test2RecQ6Q6(2, aRecQ6, bRecQ6)', weCardinal(59)).AddEvalFlag([defAllowFunctionCall]).IgnTypeName.SkipEval;
      t.Add('Test2RecQ6Q6(3, aRecQ6, bRecQ6)', weCardinal(94)).AddEvalFlag([defAllowFunctionCall]).IgnTypeName.SkipEval;

      t.Add('Test2RecQ7Q7(0, aRecQ7, bRecQ7)', weCardinal(58)).AddEvalFlag([defAllowFunctionCall]).IgnTypeName.SkipEval;
      t.Add('Test2RecQ7Q7(1, aRecQ7, bRecQ7)', weCardinal( 5)).AddEvalFlag([defAllowFunctionCall]).IgnTypeName.SkipEval;
      t.Add('Test2RecQ7Q7(2, aRecQ7, bRecQ7)', weCardinal(59)).AddEvalFlag([defAllowFunctionCall]).IgnTypeName.SkipEval;
      t.Add('Test2RecQ7Q7(3, aRecQ7, bRecQ7)', weCardinal(95)).AddEvalFlag([defAllowFunctionCall]).IgnTypeName.SkipEval;

      t.Add('aRecB2.a', weCardinal(11, #1, -1)).IgnTypeName.SkipEval.IgnKind;
      t.Add('aRecW2.a', weCardinal(12, #1, -1)).IgnTypeName.SkipEval.IgnKind;
      t.Add('aRecC2.a', weCardinal(13, #1, -1)).IgnTypeName.SkipEval.IgnKind;
      t.Add('aRecQ2.a', weCardinal(14, #1, -1)).IgnTypeName.SkipEval.IgnKind;
      t.Add('bRecB2.a', weCardinal(51, #1, -1)).IgnTypeName.SkipEval.IgnKind;
      t.Add('bRecW2.a', weCardinal(52, #1, -1)).IgnTypeName.SkipEval.IgnKind;
      t.Add('bRecC2.a', weCardinal(53, #1, -1)).IgnTypeName.SkipEval.IgnKind;
      t.Add('bRecQ2.a', weCardinal(54, #1, -1)).IgnTypeName.SkipEval.IgnKind;


      t.Add('Test2RecB2QQQB3(0, aRecB2, 1,2,3,4,5,6,7,8, bRecB3)', weCardinal(11)).AddEvalFlag([defAllowFunctionCall]).IgnTypeName.SkipEval;
      t.Add('Test2RecB2QQQQ2(0, aRecB2, 1,2,3,4,5,6,7,8, bRecQ2)', weCardinal(11)).AddEvalFlag([defAllowFunctionCall]).IgnTypeName.SkipEval;
      t.Add('Test2RecB3QQQB2(0, aRecB3, 1,2,3,4,5,6,7,8, bRecB2)', weCardinal(15)).AddEvalFlag([defAllowFunctionCall]).IgnTypeName.SkipEval;
      t.Add('Test2RecB3QQQQ2(0, aRecB3, 1,2,3,4,5,6,7,8, bRecQ2)', weCardinal(15)).AddEvalFlag([defAllowFunctionCall]).IgnTypeName.SkipEval;
      t.Add('Test2RecQ2QQQB2(0, aRecQ2, 1,2,3,4,5,6,7,8, bRecB2)', weCardinal(14)).AddEvalFlag([defAllowFunctionCall]).IgnTypeName.SkipEval;
      t.Add('Test2RecQ2QQQB3(0, aRecQ2, 1,2,3,4,5,6,7,8, bRecB3)', weCardinal(14)).AddEvalFlag([defAllowFunctionCall]).IgnTypeName.SkipEval;

      t.Add('Test2RecB2QQQB3(0, aRecB2, 11,2,3,4,5,6,7,8, bRecB3)', weCardinal(8)).AddEvalFlag([defAllowFunctionCall]).IgnTypeName.SkipEval;
      t.Add('Test2RecB2QQQQ2(0, aRecB2, 11,2,3,4,5,6,7,8, bRecQ2)', weCardinal(8)).AddEvalFlag([defAllowFunctionCall]).IgnTypeName.SkipEval;
      t.Add('Test2RecB3QQQB2(0, aRecB3, 11,2,3,4,5,6,7,8, bRecB2)', weCardinal(8)).AddEvalFlag([defAllowFunctionCall]).IgnTypeName.SkipEval;
      t.Add('Test2RecB3QQQQ2(0, aRecB3, 11,2,3,4,5,6,7,8, bRecQ2)', weCardinal(8)).AddEvalFlag([defAllowFunctionCall]).IgnTypeName.SkipEval;
      t.Add('Test2RecQ2QQQB2(0, aRecQ2, 11,2,3,4,5,6,7,8, bRecB2)', weCardinal(8)).AddEvalFlag([defAllowFunctionCall]).IgnTypeName.SkipEval;
      t.Add('Test2RecQ2QQQB3(0, aRecQ2, 11,2,3,4,5,6,7,8, bRecB3)', weCardinal(8)).AddEvalFlag([defAllowFunctionCall]).IgnTypeName.SkipEval;

      t.EvalAndCheck;


    finally
      Debugger.RunToNextPause(dcStop);
      FreeAndNil(t);
      Debugger.ClearDebuggerMonitors;
      Debugger.FreeDebugger;
    end;

  end;
  finally
    AssertTestErrors;
  end;
end;

procedure TTestWatches.TestWatchesFunctionsSysVarToLStr;
var
  ExeName: String;
  t: TWatchExpectationList;
  Src: TCommonSource;
  BrkPrg: TDBGBreakPoint;
  ValueConverterSelectorList: TIdeDbgValueConvertSelectorList;
  obj: TIdeDbgValueConvertSelector;
  i, c: Integer;
begin
  if SkipTest then exit;
  if not TestControlCanTest(ControlTestWatchFunctVariant) then exit;
  t := nil;

  Src := GetCommonSourceFor('WatchesValuePrg.pas');
  TestCompile(Src, ExeName, '', ' -dSINGLE_BIG_FUNC ');

  AssertTrue('Start debugger', Debugger.StartDebugger(AppDir, ExeName));

  ValueConverterSelectorList := TIdeDbgValueConvertSelectorList.Create;
  ValueConverterConfigList := ValueConverterSelectorList;
  try
    t := TWatchExpectationList.Create(Self);
    t.AcceptSkSimple := [skInteger, skCardinal, skBoolean, skChar, skFloat,
      skString, skAnsiString, skCurrency, skVariant, skWideString,
      skInterface, skEnumValue];
    t.AddTypeNameAlias('integer', 'integer|longint');
    t.AddTypeNameAlias('Char', 'Char|AnsiChar');
    t.AddTypeNameAlias('ShortStr255', 'ShortStr255|ShortString');
    t.AddTypeNameAlias('TEnumSub', 'TEnum|TEnumSub');


    BrkPrg         := Debugger.SetBreakPoint(Src, 'Prg');

    AssertDebuggerNotInErrorState;

    (* ************ Nested Functions ************* *)

    RunToPause(BrkPrg);

    obj := TIdeDbgValueConvertSelector.Create(TFpDbgValueConverterVariantToLStr.Create);
    //obj.MatchKinds := [skRecord];
    obj.MatchTypeNames.Add('variant');
    ValueConverterSelectorList.Add(obj);

    t.Clear;
    t.Add('variant1 to lstr', 'variant1',    weAnsiStr('102'));
    t.Add('variant2 to lstr', 'variant2',    weAnsiStr('True'));

    t.Add('rec variant1 to lstr', 'v_rec.variant1',    weAnsiStr('103'));
    t.Add('rec variant2 to lstr', 'v_rec.variant2',    weAnsiStr('False'));

    t.Add('array variant1 to lstr', 'v_array[3]',    weAnsiStr('104'));
    t.Add('array variant2 to lstr', 'v_array[4]',    weAnsiStr('True'));


    c := t.Count;
    t.Add('Extra-depth: variant1 to lstr', 'variant1',    weAnsiStr('102'));
    t.Add('Extra-depth: variant2 to lstr', 'variant2',    weAnsiStr('True'));

    t.Add('Extra-depth: rec variant1 to lstr', 'v_rec.variant1',    weAnsiStr('103'));
    t.Add('Extra-depth: rec variant2 to lstr', 'v_rec.variant2',    weAnsiStr('False'));

    t.Add('Extra-depth: array variant1 to lstr', 'v_array[3]',    weAnsiStr('104'));
    t.Add('Extra-depth: array variant2 to lstr', 'v_array[4]',    weAnsiStr('True'));

    for i := c to t.Count-1 do
      t.Tests[i]^.TstWatch.EvaluateFlags := t.Tests[i]^.TstWatch.EvaluateFlags + [defExtraDepth];


    for i := 0 to t.Count-1 do
      t.Tests[i].AddFlag(ehNoTypeInfo);

    if Compiler.Version < 029999 then
      for i := 0 to t.Count-1 do
        t.Tests[i]
          .IgnTypeName
          .IgnData([], Compiler.Version < 029999);

    t.EvaluateWatches;
    t.CheckResults;




  finally
    ValueConverterConfigList := nil;
    FreeAndNil(ValueConverterSelectorList);

    Debugger.RunToNextPause(dcStop);
    t.Free;
    Debugger.ClearDebuggerMonitors;
    Debugger.FreeDebugger;

    AssertTestErrors;
  end;
end;

procedure TTestWatches.TestWatchesAddressOf;

  type
    TTestLoc = (tlAny, tlConst, tlParam, tlArrayWrap, tlPointer);

  procedure AddWatches(t: TWatchExpectationList; AName: String; APrefix: String; ALoc: TTestLoc = tlAny; APostFix: String = '');
  var
    p, e: String;
  begin
    p := APrefix;
    e := APostFix;

    t.AddWithoutExpect(AName, p+'Byte'+e);
    t.AddWithoutExpect(AName, p+'Word'+e);
    t.AddWithoutExpect(AName, p+'Longword'+e);
    t.AddWithoutExpect(AName, p+'QWord'+e);
    t.AddWithoutExpect(AName, p+'Shortint'+e);
    t.AddWithoutExpect(AName, p+'Smallint'+e);
    t.AddWithoutExpect(AName, p+'Longint'+e);
    t.AddWithoutExpect(AName, p+'Int64'+e);
    t.AddWithoutExpect(AName, p+'IntRange'+e);
    t.AddWithoutExpect(AName, p+'CardinalRange'+e);

    t.AddWithoutExpect(AName, p+'Byte_2'+e);
    t.AddWithoutExpect(AName, p+'Word_2'+e);
    t.AddWithoutExpect(AName, p+'Longword_2'+e);
    t.AddWithoutExpect(AName, p+'QWord_2'+e);
    t.AddWithoutExpect(AName, p+'Shortint_2'+e);
    t.AddWithoutExpect(AName, p+'Smallint_2'+e);
    t.AddWithoutExpect(AName, p+'Longint_2'+e);
    t.AddWithoutExpect(AName, p+'Int64_2'+e);

    t.AddWithoutExpect(AName, p+'Shortint_3'+e);
    t.AddWithoutExpect(AName, p+'Smallint_3'+e);
    t.AddWithoutExpect(AName, p+'Longint_3'+e);
    t.AddWithoutExpect(AName, p+'Int64_3'+e);

    t.AddWithoutExpect(AName, p+'Real'+e);
    t.AddWithoutExpect(AName, p+'Single'+e);
    t.AddWithoutExpect(AName, p+'Double'+e);
    t.AddWithoutExpect(AName, p+'Extended'+e);
    //t.AddWithoutExpect(p+'Comp'+e);
    t.AddWithoutExpect(AName, p+'Currency'+e);

    t.AddWithoutExpect(AName, p+'Real_2'+e);
    t.AddWithoutExpect(AName, p+'Single_2'+e);
    t.AddWithoutExpect(AName, p+'Double_2'+e);
    t.AddWithoutExpect(AName, p+'Extended_2'+e); // Double ?
    //t.AddWithoutExpect(p+'Comp_2'+e);
    t.AddWithoutExpect(AName, p+'Currency_2'+e);

    t.AddWithoutExpect(AName, p+'Char'+e);
    t.AddWithoutExpect(AName, p+'Char2'+e);
    t.AddWithoutExpect(AName, p+'Char3'+e);

    t.AddWithoutExpect(AName, p+'String1'+e);
    t.AddWithoutExpect(AName, p+'String1e'+e);
    t.AddWithoutExpect(AName, p+'String10'+e);
    t.AddWithoutExpect(AName, p+'String10e'+e);
    t.AddWithoutExpect(AName, p+'String10x'+e);
    t.AddWithoutExpect(AName, p+'String255'+e);

    t.AddWithoutExpect(AName, p+'Ansi1'+e);
    t.AddWithoutExpect(AName, p+'Ansi2'+e);
    t.AddWithoutExpect(AName, p+'Ansi3'+e);
    t.AddWithoutExpect(AName, p+'Ansi4'+e);
    t.AddWithoutExpect(AName, p+'Ansi5'+e);

//TODO wePchar
    t.AddWithoutExpect(AName, p+'PChar'+e);
    t.AddWithoutExpect(AName, p+'PChar2'+e);

    // char by index
    // TODO: no typename => calculated value ?
////    t.AddWithoutExpect(AName, p+'String10'+e+'[2]').CharFromIndex;
////    t.AddWithoutExpect(AName, p+'Ansi2'+e+'[2]').CharFromIndex;
////    t.AddWithoutExpect(AName, p+'PChar2'+e+'[1]').CharFromIndex;
////    t.AddWithoutExpect(AName, p+'String10'+e+'[1]').CharFromIndex;
////    t.AddWithoutExpect(AName, p+'Ansi2'+e+'[1]').CharFromIndex;
////    t.AddWithoutExpect(AName, p+'PChar2'+e+'[0]').CharFromIndex;


    t.AddWithoutExpect(AName, p+'WideChar'+e); // TODO: widechar
    t.AddWithoutExpect(AName, p+'WideChar2'+e);
    t.AddWithoutExpect(AName, p+'WideChar3'+e);

    t.AddWithoutExpect(AName, p+'WideString1'+e);
    t.AddWithoutExpect(AName, p+'WideString2'+e);
    t.AddWithoutExpect(AName, p+'WideString3'+e);
    t.AddWithoutExpect(AName, p+'WideString4'+e);
    t.AddWithoutExpect(AName, p+'WideString5'+e);

////    t.AddWithoutExpect(AName, p+'WideString2'+e+'[1]')     .CharFromIndex;
////    t.AddWithoutExpect(AName, p+'WideString2'+e+'[2]')     .CharFromIndex;
////    t.AddWithoutExpect(AName, p+'WideString5'+e+'[1]')     .CharFromIndex;
////    t.AddWithoutExpect(AName, p+'WideString5'+e+'[2]')     .CharFromIndex;

//TODO wePWidechar
    t.AddWithoutExpect(AName, p+'PWideChar'+e);
    t.AddWithoutExpect(AName, p+'PWideChar2'+e);

    t.AddWithoutExpect(AName, p+'UnicodeString1'+e);
    t.AddWithoutExpect(AName, p+'UnicodeString2'+e);
    t.AddWithoutExpect(AName, p+'UnicodeString3'+e);
    t.AddWithoutExpect(AName, p+'UnicodeString4'+e);
    t.AddWithoutExpect(AName, p+'UnicodeString5'+e);

//todo dwarf 3
////    t.AddWithoutExpect(AName, p+'UnicodeString2'+e+'[1]')       .CharFromIndex(stDwarf2);
////    t.AddWithoutExpect(AName, p+'UnicodeString2'+e+'[2]')       .CharFromIndex(stDwarf2);
////    t.AddWithoutExpect(AName, p+'UnicodeString5'+e+'[1]')       .CharFromIndex(stDwarf2);
////    t.AddWithoutExpect(AName, p+'UnicodeString5'+e+'[2]')       .CharFromIndex(stDwarf2);


// The below are not real constants => they can have @xxx their address taken.
// Do not add, if expecting ddsError
if not (ALoc = tlConst) then begin
    t.AddWithoutExpect(AName, p+'ShortRec'+e);


    t.AddWithoutExpect(AName, p+'CharDynArray3'+e);
    t.AddWithoutExpect(AName, p+'CharDynArray4'+e);

    t.AddWithoutExpect(AName, p+'WCharDynArray3'+e);
    t.AddWithoutExpect(AName, p+'WCharDynArray4'+e);

    t.AddWithoutExpect(AName, p+'IntDynArray3'+e);
    t.AddWithoutExpect(AName, p+'IntDynArray4'+e);

    t.AddWithoutExpect(AName, p+'AnsiDynArray3'+e);
    t.AddWithoutExpect(AName, p+'AnsiDynArray4'+e);

    t.AddWithoutExpect(AName, p+'ShortStrDynArray3'+e);
    t.AddWithoutExpect(AName, p+'ShortStrDynArray4'+e);


    t.AddWithoutExpect(AName, p+'DynDynArrayInt'+e);

////    t.AddWithoutExpect(AName, p+'DynDynArrayInt'+e+'[0]');
////    t.AddWithoutExpect(AName, p+'DynDynArrayInt'+e+'[1]');
////    t.AddWithoutExpect(AName, p+'DynDynArrayInt'+e+'[2]');
////    t.AddWithoutExpect(AName, p+'DynDynArrayInt'+e+'[3]');
////    t.AddWithoutExpect(AName, p+'DynDynArrayInt'+e+'[4]');
////
////    t.AddWithoutExpect(AName, p+'DynDynArrayInt2'+e+'[0]');
////    t.AddWithoutExpect(AName, p+'DynDynArrayInt2'+e+'[1]');
////    t.AddWithoutExpect(AName, p+'DynDynArrayInt2'+e+'[2]');
////    t.AddWithoutExpect(AName, p+'DynDynArrayInt2'+e+'[3]');
////    t.AddWithoutExpect(AName, p+'DynDynArrayInt2'+e+'[4]');


/////    t.AddWithoutExpect(AName, p+'pre__FiveDynArray'+e                  ))
t.AddWithoutExpect(AName, p+'FiveDynArray'+e);
////t.AddWithoutExpect(AName, p+'FiveDynArray'+e+'[0]');
//    t.AddWithoutExpect(AName, p+'FiveDynArray'+e);
//    t.AddWithoutExpect(AName, p+'FiveDynArrayPack'+e);
//    t.AddWithoutExpect(AName, p+'FivePackDynArray'+e);
//    t.AddWithoutExpect(AName, p+'FivePackDynArrayPack'+e);
//    t.AddWithoutExpect(AName, p+'RecFiveDynArray'+e);
//    t.AddWithoutExpect(AName, p+'RecFiveDynPackArray'+e);
//    t.AddWithoutExpect(AName, p+'RecFivePackDynArray'+e);
//    t.AddWithoutExpect(AName, p+'RecFivePackDynPackArray'+e);
//    t.AddWithoutExpect(AName, p+'FiveDynArray2'+e);
//    t.AddWithoutExpect(AName, p+'FiveDynArrayPack2'+e);
//    t.AddWithoutExpect(AName, p+'FivePackDynArray2'+e);
//    t.AddWithoutExpect(AName, p+'FivePackDynArrayPack2'+e);



    t.AddWithoutExpect(AName, p+'CharStatArray2'+e);
    t.AddWithoutExpect(AName, p+'WCharStatArray2'+e);
    t.AddWithoutExpect(AName, p+'IntStatArray2'+e);
    t.AddWithoutExpect(AName, p+'AnsiStatArray2'+e);
    t.AddWithoutExpect(AName, p+'ShortStrStatArray2'+e);
end;


//    t.AddWithoutExpect(AName, p+'FiveStatArray{e}             _O2_ TFiveStatArray            _EQ_ ((a:-9;b:44), (a:-8-AddWithoutExpect;b:33), (a:-7;b:22));          //@@ _pre3_FiveStatArray;
//    t.AddWithoutExpect(AName, p+'FiveStatArrayPack{e}         _O2_ TFiveStatArrayPack        _EQ_ ((a:-9;b:44), (a:-8-AddWithoutExpect;b:33), (a:-7;b:22));          //@@ _pre3_FiveStatArrayPack;
//    t.AddWithoutExpect(AName, p+'FivePackStatArray{e}         _O2_ TFivePackStatArray        _EQ_ ((a:-9;b:44), (a:-8-AddWithoutExpect;b:33), (a:-7;b:22));          //@@ _pre3_FivePackStatArray;
//    t.AddWithoutExpect(AName, p+'FivePackStatArrayPack{e}     _O2_ TFivePackStatArrayPack    _EQ_ ((a:-9;b:44), (a:-8-AddWithoutExpect;b:33), (a:-7;b:22));          //@@ _pre3_FivePackStatArrayPack;
//    t.AddWithoutExpect(AName, p+'RecFiveStatArray{e}          _O2_ TRecFiveStatArray         _EQ_ ((a:-9;b:44), (a:-8-AddWithoutExpect;b:33), (a:-7;b:22));          //@@ _pre3_RecFiveStatArray;
//    t.AddWithoutExpect(AName, p+'RecFiveStatPackArray{e}      _O2_ TRecFiveStatPackArray     _EQ_ ((a:-9;b:44), (a:-8-AddWithoutExpect;b:33), (a:-7;b:22));          //@@ _pre3_RecFiveStatPackArray;
//    t.AddWithoutExpect(AName, p+'RecFivePackStatArray{e}      _O2_ TRecFivePackStatArray     _EQ_ ((a:-9;b:44), (a:-8-AddWithoutExpect;b:33), (a:-7;b:22));          //@@ _pre3_RecFivePackStatArray;
//    t.AddWithoutExpect(AName, p+'RecFivePackStatPackArray{e}  _O2_ TRecFivePackStatPackArray _EQ_ ((a:-9;b:44), (a:-8-AddWithoutExpect;b:33), (a:-7;b:22));          //@@ _pre3_RecFivePackStatPackArray;


//TODO: element by index


  t.AddWithoutExpect(AName, p+'Enum'+e);
  t.AddWithoutExpect(AName, p+'Enum1'+e);
  t.AddWithoutExpect(AName, p+'Enum2'+e);
  t.AddWithoutExpect(AName, p+'Enum3'+e);

  t.AddWithoutExpect(AName, p+'Set'+e).Skip([stDwarf]);

  t.AddWithoutExpect(AName, p+'IntfUnknown'+e);

  end;

  procedure AddWatches2(t: TWatchExpectationList; AName: String; APrefix: String; AChr1: Char; ALoc: TTestLoc = tlAny; APostFix: String = '');
  var
    p, e: String;
    i, c: Integer;
  begin
    p := APrefix;
    e := APostFix;


    t.Add(AName, p+'PChar2'+e+'+0',     wePointer(weAnsiStr(AChr1+'abcd0123', 'Char'), 'PChar'));
    t.Add(AName, p+'PChar2'+e+'+1',     wePointer(weAnsiStr('abcd0123', 'Char'), 'PChar'));
    t.Add(AName, p+'PChar2'+e+'+2',     wePointer(weAnsiStr('bcd0123', 'Char'), 'PChar'));

    t.Add(AName, p+'PWideChar2'+e+'+0',     wePointer(weWideStr(AChr1+'abcX0123', 'WideChar'), 'TPWChr'));
    t.Add(AName, p+'PWideChar2'+e+'+1',     wePointer(weWideStr('abcX0123', 'WideChar'), 'TPWChr'));
    t.Add(AName, p+'PWideChar2'+e+'+2',     wePointer(weWideStr('bcX0123', 'WideChar'), 'TPWChr'));


    c := t.Count;
    // .CharFromIndex.
    //t.Add(AName, p+'PChar2'+e+'[0]',     weChar(AChr1, 'Char'));
    //t.Add(AName, p+'PChar2'+e+'[1]',     weChar('a', 'Char'));
    //t.Add(AName, '@'+p+'PChar2'+e+'[0]',     wePointer(weAnsiStr(AChr1+'abcd0123', 'Char'), 'PChar'));
    //t.Add(AName, '@'+p+'PChar2'+e+'[1]',     wePointer(weAnsiStr('abcd0123', 'Char'), 'PChar'));
    //t.Add(AName, '@'+p+'PChar2'+e+'[2]',     wePointer(weAnsiStr('bcd0123', 'Char'), 'PChar'));

    t.Add(AName, '@'+p+'Ansi2'+e+'[1]',      wePointer(weAnsiStr(AChr1+'abcd0123').IgnTypeName, '^Char')).IgnKindPtr(stDwarf2);
    t.Add(AName, '@'+p+'Ansi2'+e+'[2]',      wePointer(weAnsiStr('abcd0123').IgnTypeName, '^Char')).IgnKindPtr(stDwarf2);
    t.Add(AName, '@'+p+'Ansi2'+e+'[3]',      wePointer(weAnsiStr('bcd0123').IgnTypeName, '^Char')).IgnKindPtr(stDwarf2);
//    t.Add(AName, '@'+p+'Ansi2'+e+'[1]+1',    wePointer(weAnsiStr('abcd0123'), '^Char')).IgnKindPtr(stDwarf2).IgnKind(stDwarf3Up);

    t.Add(AName, '@'+p+'String10'+e+'[1]',    wePointer(weShortStr(AChr1+'bc1', '').IgnTypeName, '^Char'));
    t.Add(AName, '@'+p+'String10'+e+'[2]',    wePointer(weShortStr('bc1', '').IgnTypeName, '^Char'));


    // DWARF-3: .CharFromIndex.
    t.Add(AName, '@'+p+'WideString2'+e+'[1]',     wePointer(weWideStr(AChr1+'abcX0123', 'WideChar'), '^WideChar'))
    .IgnAll(stDwarf3Up);
    t.Add(AName, '@'+p+'WideString2'+e+'[2]',     wePointer(weWideStr('abcX0123', 'WideChar'), '^WideChar'))
    .IgnAll(stDwarf3Up);
    t.Add(AName, '@'+p+'WideString2'+e+'[3]',     wePointer(weWideStr('bcX0123', 'WideChar'), '^WideChar'))
    .IgnAll(stDwarf3Up);

    for i := 0 to t.Count - 1 do begin
      t.Tests[i].IgnTypeName;
      t.Tests[i].IgnKind;
      if i >= c then
        t.Tests[i].IgnAll(stDwarf2);
    end;
  end;

  procedure CmpWatches(t1, t2: TWatchExpectationList);
  var
    i, Thread: Integer;
    v1, v2: String;
    p: SizeInt;
  begin
    AssertTrue('Same count', t1.Count = t2.Count);
    t1.EvaluateWatches;
    t2.EvaluateWatches;
    Thread := Debugger.Threads.Threads.CurrentThreadId;
    for i := 0 to t1.Count - 1 do begin
      v1 := t1.Tests[i]^.TstWatch.Values[Thread, 0].Value;
      v2 := t2.Tests[i]^.TstWatch.Values[Thread, 0].Value;

      // check, if v2 has the derefed value at the end
      if (length(v1) < Length(v2)) and (pos(') ', v2) = Length(v1)) then
        v2 := copy(v2, 1, Length(v1));

      // v1 may have a single deref value at the end
      if (length(v1) <> Length(v2)) and (pos('^: ', v1) = pos('^: ', v2)) then begin
        p := pos('^: ', v1);
        v1 := copy(v1, 1, p);
        v2 := copy(v2, 1, p);
      end;

      TestEquals(t1.Tests[i]^.TstTestName + ': ' + t1.Tests[i]^.TstWatch.Expression + ' <> ' + t2.Tests[i]^.TstWatch.Expression,
        v1, v2);
    end;
  end;

  procedure AssertFailedWatches(t1: TWatchExpectationList);
  var
    i, Thread: Integer;
    v1: TWatchValue;
    s: string;
  begin
    t1.EvaluateWatches;
    Thread := Debugger.Threads.Threads.CurrentThreadId;
    for i := 0 to t1.Count - 1 do begin
      v1 := t1.Tests[i]^.TstWatch.Values[Thread, 0];
      WriteStr(s, v1.Validity);

      TestTrue(t1.Tests[i]^.TstTestName + ': ' + t1.Tests[i]^.TstWatch.Expression + ' >> ' + v1.Value + ' / ' + s,
        v1.Validity in [ddsError{, ddsInvalid}]);
    end;
  end;

var
  ExeName: String;
  t, tp: TWatchExpectationList;
  Src: TCommonSource;
  BrkPrg, BrkFoo, BrkFooVar, BrkFooConstRef: TDBGBreakPoint;
begin
  if SkipTest then exit;
  if not TestControlCanTest(ControlTestWatchAddressOf) then exit;
  t := nil;
  tp := nil;

  Src := GetCommonSourceFor('WatchesValuePrg.pas');
  TestCompile(Src, ExeName, '', ' -dSINGLE_BIG_FUNC ');

  AssertTrue('Start debugger', Debugger.StartDebugger(AppDir, ExeName));

  try
    t := TWatchExpectationList.Create(Self);
    t.AddTypeNameAlias('integer', 'integer|longint');
    t.AddTypeNameAlias('Char', 'Char|AnsiChar');
    tp := TWatchExpectationList.Create(Self);

    BrkPrg         := Debugger.SetBreakPoint(Src, 'Prg');
    BrkFoo         := Debugger.SetBreakPoint(Src, 'Foo');
    BrkFooVar      := Debugger.SetBreakPoint(Src, 'FooVar');
    BrkFooConstRef := Debugger.SetBreakPoint(Src, 'FooConstRef');
    AssertDebuggerNotInErrorState;

    (* ************ Nested Functions ************* *)

    RunToPause(BrkPrg);

    t.Clear;
    AddWatches(t,  'glob const',         '@gc', tlConst);
    AssertFailedWatches(t);

    t.Clear;
    tp.Clear;
    AddWatches(t,  'glob var',         '@gv');
    AddWatches(tp, 'glob var pointer', 'gvp_'); // pointer
    CmpWatches(t, tp);

    t.Clear;
    AddWatches2(t, 'glob var pchar',   'gv', 'B');
    t.EvaluateWatches;
    t.CheckResults;

// TODO: field / field on nil object


    RunToPause(BrkFoo);
    t.Clear;
    tp.Clear;
    AddWatches(t,  'foo local',         '@fooloc');
    AddWatches(tp, 'foo local pointer', 'fooloc_pl_');
    CmpWatches(t, tp);

    t.Clear;
    tp.Clear;
    AddWatches(t,  'foo local',         '@arg');
    AddWatches(tp, 'foo local pointer', 'fooloc_pa_');
    CmpWatches(t, tp);


    RunToPause(BrkFooVar);
    t.Clear;
    tp.Clear;
    AddWatches(t,  'foo var args',         '@argvar', tlParam);
    AddWatches(tp, 'foo var args pointer', 'fooloc_pv_');
    CmpWatches(t, tp);


    //RunToPause(BrkFooConstRef);
    //t.Clear;
    //AddWatches(t, 'foo const ref args', 'argconstref', tlParam);
    //CmpWatches(t, tp);


  finally
    Debugger.RunToNextPause(dcStop);
    t.Free;
    tp.Free;
    Debugger.ClearDebuggerMonitors;
    Debugger.FreeDebugger;

    AssertTestErrors;
  end;
end;

procedure TTestWatches.TestWatchesTypeCast;

  type
    TTestLoc = (tlAny, tlConst, tlParam, tlArrayWrap, tlPointer);
  var
    t2: TWatchExpectationList;

  procedure AddWatchesConv(t: TWatchExpectationList; AName: String; APrefix: String; AOffs: Integer; AChr1: Char;
    ALoc: TTestLoc = tlAny; APostFix: String = '');

    function SignedIntAnd(AVal: Int64; AMask: Qword): Int64;
    begin
      {$PUSH}{$Q-}{$R-}
      Result := AVal and AMask;
      if (Result and (AMask xor (AMask >> 1))) <> 0 then
        Result := Result or (not AMask);
      {$POP}
    end;
  const
    UIntConvert: array[0..3] of record TypeName: String; Mask: qword; end = (
      ( TypeName: 'Byte';     Mask: $FF),
      ( TypeName: 'Word';     Mask: $FFFF),
      ( TypeName: 'LongWord'; Mask: $FFFFFFFF),
      ( TypeName: 'QWord';    Mask: qword($FFFFFFFFFFFFFFFF))
      //( TypeName: 'Pointer';  Mask: ),
    );
    SIntConvert: array[0..3] of record TypeName: String; Mask: QWord; end = (
      ( TypeName: 'ShortInt';  Mask: $FF),
      ( TypeName: 'SmallInt';  Mask: $FFFF),
      ( TypeName: 'LongInt';   Mask: $FFFFFFFF),
      ( TypeName: 'Int64';     Mask: qword($FFFFFFFFFFFFFFFF))
    );

  var
    p, e, tn: String;
    i, n: Integer;
    tm: QWord  ;
  begin
    p := APrefix;
    e := APostFix;
    n := AOffs;

    {$PUSH}{$Q-}{$R-}
    for i := low(UIntConvert) to high(UIntConvert) do begin
      tn := UIntConvert[i].TypeName;
      tm := UIntConvert[i].Mask;
      t.Add(AName+' '+tn, tn+'('+p+'Byte'+e+')',          weCardinal(qword((1+n)                    and tm), tn, -1));
      t.Add(AName+' '+tn, tn+'('+p+'Word'+e+')',          weCardinal(qword((100+n)                  and tm), tn, -1));
      t.Add(AName+' '+tn, tn+'('+p+'Longword'+e+')',      weCardinal(qword((1000+n)                 and tm), tn, -1));
      t.Add(AName+' '+tn, tn+'('+p+'QWord'+e+')',         weCardinal(qword((10000+n)                and tm), tn, -1));
      t.Add(AName+' '+tn, tn+'('+p+'Shortint'+e+')',      weCardinal(qword((50+n)                   and tm), tn, -1));
      t.Add(AName+' '+tn, tn+'('+p+'Smallint'+e+')',      weCardinal(qword((500+n)                  and tm), tn, -1));
      t.Add(AName+' '+tn, tn+'('+p+'Longint'+e+')',       weCardinal(qword((5000+n)                 and tm), tn, -1));
      t.Add(AName+' '+tn, tn+'('+p+'Int64'+e+')',         weCardinal(qword((50000+n)                and tm), tn, -1));
      t.Add(AName+' '+tn, tn+'('+p+'IntRange'+e+')',      weCardinal(qword((-50+n)                  and tm), tn, -1));
      t.Add(AName+' '+tn, tn+'('+p+'CardinalRange'+e+')', weCardinal(qword((50+n)                   and tm), tn, -1));
      t.Add(AName+' '+tn, tn+'('+p+'Byte_2'+e+')',        weCardinal(qword((240+n)                  and tm), tn, -1));
      t.Add(AName+' '+tn, tn+'('+p+'Word_2'+e+')',        weCardinal(qword((65501+n)                and tm), tn, -1));
      t.Add(AName+' '+tn, tn+'('+p+'Longword_2'+e+')',    weCardinal(qword((4123456789+n)           and tm), tn, -1));
      t.Add(AName+' '+tn, tn+'('+p+'QWord_2'+e+')',       weCardinal(qword((15446744073709551610+n) and tm), tn, -1));
      t.Add(AName+' '+tn, tn+'('+p+'Shortint_2'+e+')',    weCardinal(qword((112+n)                  and tm), tn, -1));
      t.Add(AName+' '+tn, tn+'('+p+'Smallint_2'+e+')',    weCardinal(qword((32012+n)                and tm), tn, -1));
      t.Add(AName+' '+tn, tn+'('+p+'Longint_2'+e+')',     weCardinal(qword((20123456+n)             and tm), tn, -1));
      t.Add(AName+' '+tn, tn+'('+p+'Int64_2'+e+')',       weCardinal(qword((9123372036854775801+n)  and tm), tn, -1));
      t.Add(AName+' '+tn, tn+'('+p+'Shortint_3'+e+')',    weCardinal(qword((-112+n)                 and tm), tn, -1));
      t.Add(AName+' '+tn, tn+'('+p+'Smallint_3'+e+')',    weCardinal(qword((-32012+n)               and tm), tn, -1));
      t.Add(AName+' '+tn, tn+'('+p+'Longint_3'+e+')',     weCardinal(qword((-20123456+n)            and tm), tn, -1));
      t.Add(AName+' '+tn, tn+'('+p+'Int64_3'+e+')',       weCardinal(qword((-9123372036854775801+n) and tm), tn, -1));

      // constant
      t.Add(AName+' '+tn, tn+'($77AA55BBDD)',             weCardinal(qword(($77AA55BBDD)            and tm), tn, -1));
      // bit packed
      t.Add(AName+' '+tn, tn+'('+p+'BitPackTinyNegArray[0]'+e+')',    weCardinal(qword((2)        and tm), tn, -1));
      t.Add(AName+' '+tn, tn+'('+p+'BitPackTinyNegArray[1]'+e+')',    weCardinal(qword((-2)       and tm), tn, -1));
      t.Add(AName+' '+tn, tn+'('+p+'BitPackTinyNegArray[2]'+e+')',    weCardinal(qword((0)        and tm), tn, -1));
      t.Add(AName+' '+tn, tn+'('+p+'BitPackTinyNegArray[3]'+e+')',    weCardinal(qword((-1)       and tm), tn, -1));

      t.Add(AName+' '+tn, tn+'('+p+'Char'+e+')',          weCardinal(ord(AChr1), tn, -1));
      t.Add(AName+' '+tn, tn+'('+p+'Char2'+e+')',         weCardinal(ord(#0),    tn, -1));
      t.Add(AName+' '+tn, tn+'('+p+'Char3'+e+')',         weCardinal(ord(' '),   tn, -1));
    end;
    for i := low(SIntConvert) to high(SIntConvert) do begin
      tn := SIntConvert[i].TypeName;
      tm := SIntConvert[i].Mask;
      t.Add(AName+' '+tn, tn+'('+p+'Byte'+e+')',          weInteger(SignedIntAnd(1+n                   , tm), tn, -1));
      t.Add(AName+' '+tn, tn+'('+p+'Word'+e+')',          weInteger(SignedIntAnd(100+n                 , tm), tn, -1));
      t.Add(AName+' '+tn, tn+'('+p+'Longword'+e+')',      weInteger(SignedIntAnd(1000+n                , tm), tn, -1));
      t.Add(AName+' '+tn, tn+'('+p+'QWord'+e+')',         weInteger(SignedIntAnd(10000+n               , tm), tn, -1));
      t.Add(AName+' '+tn, tn+'('+p+'Shortint'+e+')',      weInteger(SignedIntAnd(50+n                  , tm), tn, -1));
      t.Add(AName+' '+tn, tn+'('+p+'Smallint'+e+')',      weInteger(SignedIntAnd(500+n                 , tm), tn, -1));
      t.Add(AName+' '+tn, tn+'('+p+'Longint'+e+')',       weInteger(SignedIntAnd(5000+n                , tm), tn, -1));
      t.Add(AName+' '+tn, tn+'('+p+'Int64'+e+')',         weInteger(SignedIntAnd(50000+n               , tm), tn, -1));
      t.Add(AName+' '+tn, tn+'('+p+'IntRange'+e+')',      weInteger(SignedIntAnd(-50+n                 , tm), tn, -1));
      t.Add(AName+' '+tn, tn+'('+p+'CardinalRange'+e+')', weInteger(SignedIntAnd(50+n                  , tm), tn, -1));
      t.Add(AName+' '+tn, tn+'('+p+'Byte_2'+e+')',        weInteger(SignedIntAnd(240+n                 , tm), tn, -1));
      t.Add(AName+' '+tn, tn+'('+p+'Word_2'+e+')',        weInteger(SignedIntAnd(65501+n               , tm), tn, -1));
      t.Add(AName+' '+tn, tn+'('+p+'Longword_2'+e+')',    weInteger(SignedIntAnd(4123456789+n          , tm), tn, -1));
      t.Add(AName+' '+tn, tn+'('+p+'QWord_2'+e+')',       weInteger(SignedIntAnd(15446744073709551610+n, tm), tn, -1));
      t.Add(AName+' '+tn, tn+'('+p+'Shortint_2'+e+')',    weInteger(SignedIntAnd(112+n                 , tm), tn, -1));
      t.Add(AName+' '+tn, tn+'('+p+'Smallint_2'+e+')',    weInteger(SignedIntAnd(32012+n               , tm), tn, -1));
      t.Add(AName+' '+tn, tn+'('+p+'Longint_2'+e+')',     weInteger(SignedIntAnd(20123456+n            , tm), tn, -1));
      t.Add(AName+' '+tn, tn+'('+p+'Int64_2'+e+')',       weInteger(SignedIntAnd(9123372036854775801+n , tm), tn, -1));
      t.Add(AName+' '+tn, tn+'('+p+'Shortint_3'+e+')',    weInteger(SignedIntAnd(-112+n                , tm), tn, -1));
      t.Add(AName+' '+tn, tn+'('+p+'Smallint_3'+e+')',    weInteger(SignedIntAnd(-32012+n              , tm), tn, -1));
      t.Add(AName+' '+tn, tn+'('+p+'Longint_3'+e+')',     weInteger(SignedIntAnd(-20123456+n           , tm), tn, -1));
      t.Add(AName+' '+tn, tn+'('+p+'Int64_3'+e+')',       weInteger(SignedIntAnd(-9123372036854775801+n, tm), tn, -1));
      // bit packed
      t.Add(AName+' '+tn, tn+'('+p+'BitPackTinyNegArray[0]'+e+')',  weInteger(SignedIntAnd(2  , tm), tn, -1));
      t.Add(AName+' '+tn, tn+'('+p+'BitPackTinyNegArray[1]'+e+')',  weInteger(SignedIntAnd(-2 , tm), tn, -1));
      t.Add(AName+' '+tn, tn+'('+p+'BitPackTinyNegArray[2]'+e+')',  weInteger(SignedIntAnd(0  , tm), tn, -1));
      t.Add(AName+' '+tn, tn+'('+p+'BitPackTinyNegArray[3]'+e+')',  weInteger(SignedIntAnd(-1 , tm), tn, -1));

      t.Add(AName+' '+tn, tn+'('+p+'Char'+e+')',          weInteger(ord(AChr1), tn, -1));
      t.Add(AName+' '+tn, tn+'('+p+'Char2'+e+')',         weInteger(ord(#0),    tn, -1));
      t.Add(AName+' '+tn, tn+'('+p+'Char3'+e+')',         weInteger(ord(' '),   tn, -1));
    end;
    {$POP}

    t.Add(AName+' Char', 'Char('+p+'Byte'+e+')',          weChar(Chr(1+n), 'Char'));

    t.Add(AName+' Char', 'Char('+p+'FiveRec'+e+')',          weMatch('.', skSimple)).ExpectError();

  end;

  procedure AddWatchesCast(t: TWatchExpectationList; AName: String; APrefix: String; AOffs: Integer; AChr1: Char;
    ALoc: TTestLoc = tlAny; APostFix: String = '');
  var
    p, e, val: String;
    Thread, n, StartIdx, i: Integer;
    we: PWatchExpectation;
    v: QWord;
  begin
    p := APrefix;
    n := AOffs;
    e := APostFix;
    t2.Clear;

      t2.AddWithoutExpect(AName, p+'Instance1_Int'+e);
      t2.AddWithoutExpect(AName, 'PtrUInt(@'+p+'Instance1'+e+')');

      t2.AddWithoutExpect(AName, p+'Ansi5_Int'+e);
      t2.AddWithoutExpect(AName, p+'IntDynArray4_Int'+e);
      t2.AddWithoutExpect(AName, 'PtrUInt(@'+p+'IntDynArray4'+e+')');

      t2.AddWithoutExpect(AName, 'PtrUInt(@'+p+'Word'+e+')');
      t2.AddWithoutExpect(AName, 'PtrUInt(@'+p+'FiveRec'+e+')');

      t2.EvaluateWatches;
      Thread := Debugger.Threads.Threads.CurrentThreadId;

StartIdx := t.Count; // tlConst => Only eval the watch. No tests
      if ALoc <> tlConst then
        TestTrue('got rdkNum 0', t2.Tests[0]^.TstWatch.Values[Thread, 0].ResultData.ValueKind in [rdkSignedNumVal, rdkUnsignedNumVal]);
      v := t2.Tests[0]^.TstWatch.Values[Thread, 0].ResultData.AsQWord;
      val := '$'+IntToHex(v, 16);
      t.Add(AName+' Int', 'PtrUInt('+p+'Instance1'+e+')',   weCardinal(v, 'PtrUInt', -1));
      t.Add(AName+' TClass1', 'TClass1('+p+'Instance1_Int'+e+')',            weMatch('FAnsi *:[ $0-9A-F()]*\^?:? *'''+AChr1+'T', skClass));
      t.Add(AName+' TClass1', 'TClass1('+val+')',                            weMatch('FAnsi *:[ $0-9A-F()]*\^?:? *'''+AChr1+'T', skClass));
      t.Add(AName+' TClass1', 'TClass1(Pointer('+p+'Instance1_Int'+e+'))',   weMatch('FAnsi *:[ $0-9A-F()]*\^?:? *'''+AChr1+'T', skClass));
      t.Add(AName+' TClass1', 'TClass1(Pointer('+val+'))',                   weMatch('FAnsi *:[ $0-9A-F()]*\^?:? *'''+AChr1+'T', skClass));

      if ALoc <> tlConst then
        TestTrue('got rdkNum 1', t2.Tests[1]^.TstWatch.Values[Thread, 0].ResultData.ValueKind in [rdkSignedNumVal, rdkUnsignedNumVal]);
      v := t2.Tests[1]^.TstWatch.Values[Thread, 0].ResultData.AsQWord;
      val := '$'+IntToHex(v, 16);
      t.Add(AName+' PTxInstance1', 'PTxInstance1(@'+p+'Instance1'+e+')^',           weMatch('FAnsi *:[ $0-9A-F()]*\^?:? *'''+AChr1+'T', skClass));
      t.Add(AName+' PTxInstance1', 'PTxInstance1('+val+')^',                        weMatch('FAnsi *:[ $0-9A-F()]*\^?:? *'''+AChr1+'T', skClass));
      t.Add(AName+' PTxInstance1', 'PTxInstance1(Pointer(@'+p+'Instance1'+e+'))^',  weMatch('FAnsi *:[ $0-9A-F()]*\^?:? *'''+AChr1+'T', skClass));
      t.Add(AName+' PTxInstance1', 'PTxInstance1(Pointer('+val+'))^',               weMatch('FAnsi *:[ $0-9A-F()]*\^?:? *'''+AChr1+'T', skClass));


      if ALoc <> tlConst then
        TestTrue('got rdkNum 2', t2.Tests[2]^.TstWatch.Values[Thread, 0].ResultData.ValueKind in [rdkSignedNumVal, rdkUnsignedNumVal]);
      v := t2.Tests[2]^.TstWatch.Values[Thread, 0].ResultData.AsQWord;
      val := '$'+IntToHex(v, 16);
      t.Add(AName+' Ansi', 'PtrUInt('+p+'Ansi5'+e+')',   weCardinal(v, 'PtrUInt', -1));
      t.Add(AName+' AnsiString', 'AnsiString('+p+'Ansi5_Int'+e+')',
        weAnsiStr(AChr1+'bcdefghijAbcdefghijAbcdefghijAbcdefghijAbcdefghijAbcdefghijAbcdefghijAbcdefghijAbcdefghijAbcdefghijAbcdefghijAbcdefghijAbcdefghijAbcdefghijAbcdefghijAbcdefghijAbcdefghijAbcdefghijAbcdefghijAbcdefghijAbcdefghijAbcdefghijAbcdefghijAbcdefghijAbcdefghijAbcdefghijAbcdefghijAbcdefghijAbcdefghijAbcdefghijAbcdefghijAbcdefghijAbcdefghijAbcdefghijAbcdefghijAbcdefghij')
      ).IgnKindPtr(stDwarf2)    .IgnKind(stDwarf3Up);
      t.Add(AName+' AnsiString', 'AnsiString('+val+')',
        weAnsiStr(AChr1+'bcdefghijAbcdefghijAbcdefghijAbcdefghijAbcdefghijAbcdefghijAbcdefghijAbcdefghijAbcdefghijAbcdefghijAbcdefghijAbcdefghijAbcdefghijAbcdefghijAbcdefghijAbcdefghijAbcdefghijAbcdefghijAbcdefghijAbcdefghijAbcdefghijAbcdefghijAbcdefghijAbcdefghijAbcdefghijAbcdefghijAbcdefghijAbcdefghijAbcdefghijAbcdefghijAbcdefghijAbcdefghijAbcdefghijAbcdefghijAbcdefghijAbcdefghij')
      ).IgnKindPtr(stDwarf2)    .IgnKind(stDwarf3Up);

      if ALoc <> tlConst then
        TestTrue('got rdkNum 3', t2.Tests[3]^.TstWatch.Values[Thread, 0].ResultData.ValueKind in [rdkSignedNumVal, rdkUnsignedNumVal]);
      v := t2.Tests[3]^.TstWatch.Values[Thread, 0].ResultData.AsQWord;
      val := '$'+IntToHex(v, 16);
      t.Add(AName+' DynArray', 'PtrUInt('+p+'IntDynArray4'+e+')',   weCardinal(v, 'PtrUInt', -1));
      t.Add(AName, 'TIntDynArray('+p+'IntDynArray4_Int'+e+')',           weDynArray(weInteger([12, 30+AOffs, 60]), 'TIntDynArray'));
      t.Add(AName, 'TIntDynArray('+val+')',                              weDynArray(weInteger([12, 30+AOffs, 60]), 'TIntDynArray'));
      t.Add(AName, 'TIntDynArray(Pointer('+p+'IntDynArray4_Int'+e+'))',  weDynArray(weInteger([12, 30+AOffs, 60]), 'TIntDynArray'));
      t.Add(AName, 'TIntDynArray(Pointer('+val+'))',                     weDynArray(weInteger([12, 30+AOffs, 60]), 'TIntDynArray'));
      t.Add(AName, 'TIntDynArray(PtrUint('+p+'IntDynArray4_Int'+e+'))',  weDynArray(weInteger([12, 30+AOffs, 60]), 'TIntDynArray'));
      t.Add(AName, 'TIntDynArray(PtrUint('+val+'))',                     weDynArray(weInteger([12, 30+AOffs, 60]), 'TIntDynArray'));

      if ALoc <> tlConst then
        TestTrue('got rdkNum 4', t2.Tests[4]^.TstWatch.Values[Thread, 0].ResultData.ValueKind in [rdkSignedNumVal, rdkUnsignedNumVal]);
      v := t2.Tests[4]^.TstWatch.Values[Thread, 0].ResultData.AsQWord;
      val := '$'+IntToHex(v, 16);
      t.Add(AName, 'PTxIntDynArray4(@'+p+'IntDynArray4'+e+')^',           weDynArray(weInteger([12, 30+AOffs, 60]), 'TxIntDynArray4'));
      t.Add(AName, 'PTxIntDynArray4('+val+')^',                           weDynArray(weInteger([12, 30+AOffs, 60]), 'TxIntDynArray4'));
      t.Add(AName, 'PTxIntDynArray4(Pointer(@'+p+'IntDynArray4'+e+'))^',  weDynArray(weInteger([12, 30+AOffs, 60]), 'TxIntDynArray4'));
      t.Add(AName, 'PTxIntDynArray4(Pointer('+val+'))^',                  weDynArray(weInteger([12, 30+AOffs, 60]), 'TxIntDynArray4'));
      t.Add(AName, 'PTxIntDynArray4(PtrUint(@'+p+'IntDynArray4'+e+'))^',  weDynArray(weInteger([12, 30+AOffs, 60]), 'TxIntDynArray4'));
      t.Add(AName, 'PTxIntDynArray4(PtrUint('+val+'))^',                  weDynArray(weInteger([12, 30+AOffs, 60]), 'TxIntDynArray4'));

      t.Add(AName, 'TIntDynArray(PxIntDynArray4('+val+')^)',       weDynArray(weInteger([12, 30+AOffs, 60]), 'TIntDynArray'));



      if ALoc <> tlConst then
        TestTrue('got rdkNum 5', t2.Tests[5]^.TstWatch.Values[Thread, 0].ResultData.ValueKind in [rdkSignedNumVal, rdkUnsignedNumVal]);
      v := t2.Tests[5]^.TstWatch.Values[Thread, 0].ResultData.AsQWord;
      val := '$'+IntToHex(v, 16);
      t.Add(AName, 'PTxWord(@'+p+'Word'+e+')^',                weCardinal(100+n,         'TxWord',     2));
      t.Add(AName, 'PTxWord('+val+')^',                        weCardinal(100+n,         'TxWord',     2));
      t.Add(AName, 'PTxWord(Pointer(@'+p+'Word'+e+'))^',       weCardinal(100+n,         'TxWord',     2));
      t.Add(AName, 'PTxWord(Pointer('+val+'))^',               weCardinal(100+n,         'TxWord',     2));
      t.Add(AName, 'PTxWord(PtrUInt(@'+p+'Word'+e+'))^',       weCardinal(100+n,         'TxWord',     2));
      t.Add(AName, 'PTxWord(PtrUInt('+val+'))^',               weCardinal(100+n,         'TxWord',     2));
      if p='gv' then
        t.Add(AName, 'PTxWord(gvp_'+'Word'+e+')^',             weCardinal(100+n,         'TxWord',     2));

      t.Add(AName, 'PTxWord($'+IntToHex(StrToInt64Def(val, 0), 8)+')^',    weCardinal(100+n,         'TxWord',     2));
      t.Add(AName, '^TxWord('+val+')^',                                    weCardinal(100+n,         'TxWord',     2));
      t.Add(AName, '^TxWord($'+IntToHex(StrToInt64Def(val, 0), 8)+')^',    weCardinal(100+n,         'TxWord',     2));


      if ALoc <> tlConst then
        TestTrue('got rdkNum 6', t2.Tests[6]^.TstWatch.Values[Thread, 0].ResultData.ValueKind in [rdkSignedNumVal, rdkUnsignedNumVal]);
      v := t2.Tests[6]^.TstWatch.Values[Thread, 0].ResultData.AsQWord;
      val := '$'+IntToHex(v, 16);
      t.Add(AName, 'PTxFiveRec(@'+p+'FiveRec'+e+')^',                  weMatch('a *:.*b *: *44',skRecord));
      t.Add(AName, 'PTxFiveRec('+val+')^',                             weMatch('a *:.*b *: *44',skRecord));
      t.Add(AName, 'PTxFiveRec(Pointer(@'+p+'FiveRec'+e+'))^',         weMatch('a *:.*b *: *44',skRecord));
      t.Add(AName, 'PTxFiveRec(Pointer('+val+'))^',                    weMatch('a *:.*b *: *44',skRecord));
      t.Add(AName, 'PTxFiveRec(PtrUInt(@'+p+'FiveRec'+e+'))^',         weMatch('a *:.*b *: *44',skRecord));
      t.Add(AName, 'PTxFiveRec(PtrUInt('+val+'))^',                    weMatch('a *:.*b *: *44',skRecord));
      if p='gv' then
        t.Add(AName, 'PTxFiveRec(gvp_'+'FiveRec'+e+')^',               weMatch('a *:.*b *: *44',skRecord));

for i := StartIdx to t.Count-1 do
  t.Tests[i].SkipIf(ALoc = tlConst);


if p='gv' then begin

      we:= t.Add(AName, '^TRecordClass1(gv_aptr_Class1Rec[0])^.Foo',          weClass([weInteger(22+n).N('FInt'), weAnsiStr(AChr1+'T').N('FAnsi')], 'TClass1') )
        .AddFlag(ehMissingFields);
      we^.EvalCallTestFlags := [defFullTypeInfo];
      we:= t.Add(AName, '^TRecordClass1(gv_aptr_Class1Rec[1])^.Foo',          weClass([weInteger(22+n+2).N('FInt'), weAnsiStr('D'+'T').N('FAnsi')], 'TClass1') )
        .AddFlag(ehMissingFields);
      we^.EvalCallTestFlags := [defFullTypeInfo];




      we:=      t.Add(AName, '^TRecordFive(gv_ptr_FiveRec)^.a',                             weInteger(-22-n));
      we^.EvalCallTestFlags := [defFullTypeInfo];

      t.Add(AName, '^TRecordFive(gv_aptr_FiveRec[0])^.a',                             weInteger(-22-n));
      t.Add(AName, '^TRecordFive(gv_aptr_FiveRec[1])^.a',                             weInteger(-22-(n+2)));

      t.Add(AName, 'PTxFiveRec(gv_aptr_FiveRec[0])^.a',                             weInteger(-22-n));
      t.Add(AName, 'PTxFiveRec(gv_aptr_FiveRec[1])^.a',                             weInteger(-22-(n+2)));

      we:=      t.Add(AName, '^TRecordFive(gv_ptrlist_FiveRec^[0])^.a',                             weInteger(-22-n));
      we^.TstWatch.EvaluateFlags := [defFullTypeInfo];
      we^.EvalCallTestFlags := [defFullTypeInfo];
      we:=      t.Add(AName, '^TRecordFive(gv_ptrlist_FiveRec^[1])^.a',                             weInteger(-22-(n+2)));
      we^.TstWatch.EvaluateFlags := [defFullTypeInfo];
      we^.EvalCallTestFlags := [defFullTypeInfo];

      we:=      t.Add(AName, 'PTxFiveRec(gv_ptrlist_FiveRec^[0])^.a',                             weInteger(-22-n));
      we^.TstWatch.EvaluateFlags := [defFullTypeInfo];
      we^.EvalCallTestFlags := [defFullTypeInfo];
      we:=      t.Add(AName, 'PTxFiveRec(gv_ptrlist_FiveRec^[1])^.a',                             weInteger(-22-(n+2)));
      we^.TstWatch.EvaluateFlags := [defFullTypeInfo];
      we^.EvalCallTestFlags := [defFullTypeInfo];

      t.Add(AName, 'PTxFiveRec('+val+')^.a',                             weInteger(-22-n));
      t.Add(AName, '^TRecordFive('+val+')^.a',                             weInteger(-22-n));
end;


    t.Add(AName+' Cardinal', 'Cardinal('+p+'Rec3S'+e+')',  weMatch('.', skSimple)).ExpectError();
    t.Add(AName+' QWord', 'QWord('+p+'Rec3S'+e+')',        weMatch('.', skSimple)).ExpectError();

    t.Add(AName+' QWord', 'TRecord3QWord('+p+'Rec3S'+e+')',        weMatch('a *:.*18446744073709551594.*b *:.*44.*c *: .', skRecord));

  end;

var
  ExeName: String;
  t: TWatchExpectationList;
  Src: TCommonSource;
  BrkPrg, BrkFoo, BrkFooVar, BrkFooConstRef: TDBGBreakPoint;
begin
  if SkipTest then exit;
  if not TestControlCanTest(ControlTestWatchTypeCast) then exit;
  t := nil;
  t2 := nil;

  Src := GetCommonSourceFor('WatchesValuePrg.pas');
  TestCompile(Src, ExeName, '', ' -dSINGLE_BIG_FUNC ');

  AssertTrue('Start debugger', Debugger.StartDebugger(AppDir, ExeName));

  try
    t := TWatchExpectationList.Create(Self);
    t2 := TWatchExpectationList.Create(Self);
    t.AcceptSkSimple := [skInteger, skCardinal, skBoolean, skChar, skFloat,
      skString, skAnsiString, skCurrency, skVariant, skWideString,
      skInterface];
    t.AddTypeNameAlias('integer', 'integer|longint');
    t.AddTypeNameAlias('Char', 'Char|AnsiChar');
    t.AddTypeNameAlias('ShortStr255', 'ShortStr255|ShortString');
    t.AddTypeNameAlias('TEnumSub', 'TEnum|TEnumSub');

    BrkPrg         := Debugger.SetBreakPoint(Src, 'Prg');
    BrkFoo         := Debugger.SetBreakPoint(Src, 'Foo');
    BrkFooVar      := Debugger.SetBreakPoint(Src, 'FooVar');
    BrkFooConstRef := Debugger.SetBreakPoint(Src, 'FooConstRef');
    AssertDebuggerNotInErrorState;

    (* ************ Nested Functions ************* *)

    RunToPause(BrkPrg);
//t.Clear;
//t.Add('', '^TRecordClass1(gv_aptr_Class1Rec[0])^.Foo',          weClass([weInteger(22+1).N('FInt'), weAnsiStr('T').N('FAnsi')], 'TClass1') ).AddFlag(ehMissingFields)
//^.EvalCallTestFlags := [defFullTypeInfo];
//t.EvaluateWatches;
//t.CheckResults;

    t.Clear;
    t.Add('pbyte(0)', 'pbyte(0)',  wePointerAddr(nil,    'PByte'));
    t.Add('pbyte($0)', 'pbyte($0)',  wePointerAddr(nil,    'PByte'));
    t.Add('^byte(0)', '^byte(0)',  wePointerAddr(nil,    '^Byte'));
    t.Add('^byte($0)', '^byte($0)',  wePointerAddr(nil,    '^Byte'));

    t.Add('^^^char(gvInstance1)^[3][0]',         '^^^char(gvInstance1)^[3][0]',   weChar(#7)); // TCLass1 / len=7
    t.Add('^^^char(gvInstance1)^[3][1]',         '^^^char(gvInstance1)^[3][1]',   weChar('T')); // TCLass1
    t.Add('^^^char(gvInstance1)^[3][2]',         '^^^char(gvInstance1)^[3][2]',   weChar('C'));
    t.Add('^^^char(gvInstance1)^[3][3]',         '^^^char(gvInstance1)^[3][3]',   weChar('l'));
    t.Add('^^^char(gvInstance1)^[3]^',           '^^^char(gvInstance1)^[3]^',    weChar(#7)); // TCLass1 / len=7
    t.Add('(^^^char(gvInstance1)^[3])^',         '(^^^char(gvInstance1)^[3])^',  weChar(#7)); // TCLass1 / len=7
    t.Add('(^^^char(gvInstance1)^[3]+0)^',       '(^^^char(gvInstance1)^[3]+0)^',   weChar(#7)); // TCLass1 / len=7
    t.Add('(^^^char(gvInstance1)^[3]+1)^',       '(^^^char(gvInstance1)^[3]+1)^',   weChar('T')); // TCLass1

    t.Add('((^^^char(gvInstance1)^)+3)^^',       '((^^^char(gvInstance1)^)+3)^^',   weChar(#7));
    t.Add('((^^^char(gvInstance1)^)+3)[0]^',     '((^^^char(gvInstance1)^)+3)[0]^',   weChar(#7));
    t.Add('((^^^char(gvInstance1)^)+3)^[0]',     '((^^^char(gvInstance1)^)+3)^[0]',   weChar(#7));
    t.Add('((^^^char(gvInstance1)^)+3)[0][0]',   '((^^^char(gvInstance1)^)+3)[0][0]',   weChar(#7));
    t.Add('(((^^^char(gvInstance1)^)+3)^+1)^',   '(((^^^char(gvInstance1)^)+3)^+1)^',   weChar('T'));
    t.Add('(((^^^char(gvInstance1)^)+3)[0]+1)^', '(((^^^char(gvInstance1)^)+3)[0]+1)^',   weChar('T'));
    t.Add('((^^^char(gvInstance1)^)+3)^[1]',     '((^^^char(gvInstance1)^)+3)^[1]',   weChar('T'));
    t.Add('((^^^char(gvInstance1)^)+3)[0][1]',   '((^^^char(gvInstance1)^)+3)[0][1]',   weChar('T'));

    t.Add('TCastRecordB1(gvByte_2)', 'TCastRecordB1(gvByte_2)', weRecord([weCardinal(241, 'Byte', 12).N('b')], 'TCastRecordB1')  );
    t.Add('TCastRecordB1(gcByte_2)', 'TCastRecordB1(gcByte_2)', weRecord([weCardinal(240, 'Byte', 12).N('b')], 'TCastRecordB1')  );
    t.Add('TCastRecordB1($04)',      'TCastRecordB1($04)',      weRecord([weCardinal(  4, 'Byte', 12).N('b')], 'TCastRecordB1')  );

    t.Add('TCastRecordB2(gvWord2)', 'TCastRecordB2(gvWord_2)', weRecord([weCardinal($DE, 'Byte', 1).N('b'), weCardinal($FF, 'Byte', 1).N('b2')], 'TCastRecordB2')    );
    t.Add('TCastRecordB2(gcWord2)', 'TCastRecordB2(gcWord_2)', weRecord([weCardinal($DD, 'Byte', 1).N('b'), weCardinal($FF, 'Byte', 1).N('b2')], 'TCastRecordB2')    );
    t.Add('TCastRecordB2($0405)',   'TCastRecordB2($0405)',    weRecord([weCardinal($05, 'Byte', 1).N('b'), weCardinal($04, 'Byte', 1).N('b2')], 'TCastRecordB2')    );

    t.Add('TCastRecordW2(gvLongword_2)', 'TCastRecordW2(gvLongword_2)', weRecord([weCardinal($F516, 'Word', 2).N('w'), weCardinal($F5C6, 'Word', 2).N('w2')], 'TCastRecordW2')    );
    t.Add('TCastRecordW2(gcLongword_2)', 'TCastRecordW2(gcLongword_2)', weRecord([weCardinal($F515, 'Word', 2).N('w'), weCardinal($F5C6, 'Word', 2).N('w2')], 'TCastRecordW2')    );
    t.Add('TCastRecordW2($01020304)',    'TCastRecordW2($01020304)',    weRecord([weCardinal($0304, 'Word', 2).N('w'), weCardinal($0102, 'Word', 2).N('w2')], 'TCastRecordW2')    );
    t.Add('TCastRecordW2(LongWord(gvLongword_2))', 'TCastRecordW2(LongWord(gvLongword_2))', weRecord([weCardinal($F516, 'Word', 2).N('w'), weCardinal($F5C6, 'Word', 2).N('w2')], 'TCastRecordW2')    );
    t.Add('TCastRecordW2(LongWord(gcLongword_2))', 'TCastRecordW2(LongWord(gcLongword_2))', weRecord([weCardinal($F515, 'Word', 2).N('w'), weCardinal($F5C6, 'Word', 2).N('w2')], 'TCastRecordW2')    );
    t.Add('TCastRecordW2(LongWord($01020304))', '   TCastRecordW2(LongWord($01020304))',    weRecord([weCardinal($0304, 'Word', 2).N('w'), weCardinal($0102, 'Word', 2).N('w2')], 'TCastRecordW2')    );

    t.Add('TCastRecordL2(gvQword_2)', 'TCastRecordL2(gvQword_2)', weRecord([weCardinal($09D3FFFB, 'LongWord', 4).N('l'), weCardinal($D65DDBE5, 'LongWord', 4).N('l2')], 'TCastRecordL2')    );
    t.Add('TCastRecordL2(gcQword_2)', 'TCastRecordL2(gcQword_2)', weRecord([weCardinal($09D3FFFA, 'LongWord', 4).N('l'), weCardinal($D65DDBE5, 'LongWord', 4).N('l2')], 'TCastRecordL2')    );
    t.Add('TCastRecordL2($0102030405060708)', 'TCastRecordL2($0102030405060708)',    weRecord([weCardinal($05060708, 'LongWord', 4).N('l'), weCardinal($01020304, 'LongWord', 4).N('l2')], 'TCastRecordL2')    );

    t.Add('TCastRecordW2(VarCastRecL1)', 'TCastRecordW2(VarCastRecL1)', weRecord([weCardinal(7, 'Word', 2).N('w'), weCardinal(0, 'Word', 2).N('w2')], 'TCastRecordW2')    );
    t.Add('TCastRecordL1(VarCastRecW2)', 'TCastRecordL1(VarCastRecW2)', weRecord([weCardinal($00060005, 'LongWord', 4).N('l')], 'TCastRecordL1')    );

    t.Add('TCastRecordQ2(VarCastRecL4)', 'TCastRecordQ2(VarCastRecL4)', weRecord([weCardinal($000000000B0000000A, 'QWord', 8).N('q'), weCardinal($000000000D0000000C, 'QWord', 8).N('q2')], 'TCastRecordQ2')    );
    t.Add('TCastRecordL4(VarCastRecQ2)', 'TCastRecordL4(VarCastRecQ2)', weRecord([weCardinal($00120013, 'LongWord', 4).N('l'), weCardinal($00100011, 'LongWord', 4).N('l2'), weCardinal($00220023, 'LongWord', 4).N('l3'), weCardinal($00200021, 'LongWord', 4).N('l4')], 'TCastRecordL4')    );


    AddWatchesConv(t, 'glob const', 'gc', 000, 'A', tlConst);
    AddWatchesConv(t, 'glob var',   'gv', 001, 'B');

    AddWatchesCast(t, 'glob const', 'gc', 000, 'A', tlConst);
    AddWatchesCast(t, 'glob var',   'gv', 001, 'B');
    AddWatchesCast(t, 'glob MyClass1',     'MyClass1.mc',  002, 'C');
    AddWatchesCast(t, 'glob MyBaseClass1', 'MyClass1.mbc', 003, 'D');
    AddWatchesCast(t, 'glob MyClass1',     'TMyClass(MyClass2).mc',  004, 'E');
    AddWatchesCast(t, 'glob MyBaseClass1', 'TMyClass(MyClass2).mbc', 005, 'F');
    AddWatchesCast(t, 'glob var dyn array of [0]',   'gva', 005, 'K', tlArrayWrap, '[0]' );
    AddWatchesCast(t, 'glob var dyn array of [1]',   'gva', 006, 'L', tlArrayWrap, '[1]');
    AddWatchesCast(t, 'glob var pointer',            'gvp_', 001, 'B', tlPointer, '^'); // pointer


    t.EvaluateWatches;
    t.CheckResults;


    RunToPause(BrkFoo);
    t.Clear;
    AddWatchesCast(t, 'foo local', 'fooloc', 002, 'C');
    t.EvaluateWatches;
    t.CheckResults;


    RunToPause(BrkFooVar);
    t.Clear;
    AddWatchesCast(t, 'foo var args', 'argvar', 001, 'B', tlParam);
    AddWatchesCast(t, 'foo var ArgMyBaseClass1', 'TMyClass(ArgVarMyClass2).mbc', 005, 'F');
    t.EvaluateWatches;
    t.CheckResults;

    RunToPause(BrkFooConstRef);
    t.Clear;
    AddWatchesCast(t, 'foo const ref args', 'argconstref', 001, 'B', tlParam);
    t.EvaluateWatches;
    t.CheckResults;


  finally
    Debugger.RunToNextPause(dcStop);
    t.Free;
    t2.Free;
    Debugger.ClearDebuggerMonitors;
    Debugger.FreeDebugger;

    AssertTestErrors;
  end;
end;

procedure TTestWatches.TestWatchesExpression;

  type
    TTestLoc = (tlAny, tlConst, tlParam, tlArrayWrap, tlPointer, tlPointerAny);

  procedure AddWatches(t: TWatchExpectationList; AName: String;
    APrefix: String;  AOffs: Integer;  AChr1: Char;  APostFix: String;  ALoc: TTestLoc;
    APrefix2: String; AOffs2: Integer; AChr12: Char; APostFix2: String; ALoc2: TTestLoc
  );
  var
    p, e, p2, e2: String;
    n, n2: Integer;
  begin
    p := APrefix;
    e := APostFix;
    n := AOffs;
    p2 := APrefix2;
    e2 := APostFix2;
    n2 := AOffs2;

    t.Add(AName, p+'Byte'+e +'='+ IntToStr(1+n),    weBool(True) );
    t.Add(AName, p+'Byte'+e +'='+ p2+'Byte'+e2,     weBool(n=n2) );
    t.Add(AName, p+'Byte'+e +'='+ p2+'Byte_2'+e2,   weBool(n+1=n2+240) );

    t.Add(AName, p+'Single'+e +'='+ FloatToStr(100.125+n),    weBool(True) );
    t.Add(AName, p+'Double'+e +'='+ FloatToStr(1000.125+n),    weBool(True) );

    t.Add(AName, p+'Single'+e +'='+ p+'Byte'+e,    weBool(False) );
    t.Add(AName, p+'Single'+e +'>'+ p+'Byte'+e,    weBool(True) );
    t.Add(AName, p+'Single'+e +'<'+ p+'Byte'+e,    weBool(False) );
    t.Add(AName, p+'Single'+e+'-99.125' +'='+ p+'Byte'+e,    weBool(True) );

    t.Add(AName, p+'String1e'+e + ' = '''' ',   weBool(True));
    t.Add(AName, p+'String10'+e + ' = '''+AChr1+'bc1'' ',   weBool(True));
    t.Add(AName, p+'String10'+e + '+''a'' = '''+AChr1+'bc1'' ',   weBool(False));
    t.Add(AName, p+'String10'+e + '+''a'' = '''+AChr1+'bc1a'' ',   weBool(True));

    t.Add(AName, p+'Ansi3'+e + ' = '''' ',   weBool(True));
    t.Add(AName, p+'Ansi2'+e + ' = '''+AChr1+'abcd0123'' ',   weBool(True));
    t.Add(AName, p+'Ansi2'+e + ' +''x'' = '''+AChr1+'abcd0123'' ',   weBool(False));
    t.Add(AName, p+'Ansi2'+e + ' +''x'' = '''+AChr1+'abcd0123x'' ',   weBool(True));

    t.Add(AName, p+'WideString3'+e + ' = '''' ',   weBool(True)).SkipIf(ALoc = tlConst);
    t.Add(AName, p+'WideString2'+e + ' = '''+AChr1+'abcX0123'' ',   weBool(True)).SkipIf(ALoc = tlConst);
    t.Add(AName, p+'WideString2'+e + ' +''x'' = '''+AChr1+'abcX0123'' ',   weBool(False)).SkipIf(ALoc = tlConst);
    t.Add(AName, p+'WideString2'+e + ' +''x'' = '''+AChr1+'abcX0123x'' ',   weBool(True)).SkipIf(ALoc = tlConst);

    t.Add(AName, p+'String1e'+e + ' = '+p+'Ansi3'+e,   weBool(True));


    t.Add(AName, p+'IntfUnknown'+e  +'='+ 'nil',              weBool(True) );
    t.Add(AName, p+'IntfUnknown1'+e +'='+ 'nil',              weBool(False) )
      .skipIf((ALoc in [tlConst]));
    t.Add(AName, 'nil' +'='+ p+'IntfUnknown'+e ,              weBool(True) );
    t.Add(AName, 'nil' +'='+ p+'IntfUnknown1'+e,              weBool(False) )
      .skipIf((ALoc in [tlConst]));

    t.Add(AName, p+'IntfUnknown'+e  +'='+ p2+'IntfUnknown'+e2,   weBool(True) );
    t.Add(AName, p+'IntfUnknown1'+e +'='+ p2+'IntfUnknown1'+e2,  weBool(True) )
      .skipIf((ALoc in [tlConst]) or (ALoc2 in [tlConst]));

    t.Add(AName, p+'IntfUnknown'+e  +'='+ p2+'IntfUnknown2'+e2,   weBool(False) )
      .skipIf((ALoc2 in [tlConst]));
    t.Add(AName, p+'IntfUnknown1'+e +'='+ p2+'IntfUnknown2'+e2,  weBool(False) )
      .skipIf((ALoc in [tlConst]) or (ALoc2 in [tlConst]));
    t.Add(AName, p+'IntfUnknown2'+e +'='+ p2+'IntfUnknown2b'+e2, weBool(True) )
      .skipIf((ALoc in [tlConst]) or (ALoc2 in [tlConst]));


    t.Add(AName, p+'Instance0'+e +'='+ 'nil',               weBool(True) );
    t.Add(AName, p+'Instance1'+e +'='+ 'nil',               weBool(False) )
      .skipIf((ALoc in [tlConst]));

    t.Add(AName, p+'Instance0'+e +'='+ p2+'Instance0'+e2,   weBool(True) )
      .skipIf((ALoc2 in [tlConst]));
    t.Add(AName, p+'Instance1'+e +'='+ p2+'Instance1'+e2,   weBool(True) )
      .skipIf((ALoc in [tlConst]) or (ALoc2 in [tlConst]));

    t.Add(AName, p+'Instance0'+e +'='+ p2+'Instance2'+e2,   weBool(False) )
      .skipIf((ALoc2 in [tlConst]));
    t.Add(AName, p+'Instance1'+e +'='+ p2+'Instance2'+e2,   weBool(False) )
      .skipIf((ALoc in [tlConst]) or (ALoc2 in [tlConst]));
    t.Add(AName, p+'Instance2'+e +'='+ p2+'Instance2b'+e2,  weBool(True) )
      .skipIf((ALoc in [tlConst]) or (ALoc2 in [tlConst]));


    t.Add(AName, p+'Word'+e +' and '+ p+'LongWord'+e,           weCardinal((100+n) and (1000+n)) );
    t.Add(AName, p+'Word'+e +' and Byte('+ p+'Char'+e+')',      weCardinal((100+n) and Byte(AChr1)) );
    t.Add(AName, p+'Word'+e +' and '+ IntToStr(1002+n),         weCardinal((100+n) and (1002+n)) );
    t.Add(AName, p+'Word'+e +' and ShortInt('+ p+'Char'+e+')',  weCardinal((100+n) and Byte(AChr1)) );

    t.Add(AName, p+'ShortInt'+e +' and '+ p+'SmallInt'+e,       weInteger((50+n) and (500+n)) );
    t.Add(AName, p+'ShortInt'+e +' and '+ p+'Word'+e,           weCardinal((50+n) and (1000+n)) );
    t.Add(AName, p+'ShortInt'+e +' and '+ IntToStr(1002+n),     weCardinal((50+n) and (1002+n)) );


    t.Add('ENUM-EQ: ', p+'Enum = eNVaL2',         weBool(False));
    t.Add('ENUM-EQ: ', p+'Enum = eNVaL3',         weBool(True));
    t.Add('ENUM-EQ: ', p+'Enum = TEnum.eNVaL2',   weBool(False));
    t.Add('ENUM-EQ: ', p+'Enum = TEnum.eNVaL3',   weBool(True));
    t.Add('ENUM-EQ: ', 'eNVaL2 = '+p+'Enum',      weBool(False));
    t.Add('ENUM-EQ: ', 'eNVaL3 = '+p+'Enum',      weBool(True));
    t.Add('ENUM-EQ: ', p+'Enum = '+p2+'Enum',     weBool(True));
    t.Add('ENUM-EQ: ', p+'Enum = '+p2+'EnumA',    weBool(False));
    t.Add('ENUM-EQ: ', 'eNVaL3 = eNVaL2',         weBool(False));
    t.Add('ENUM-EQ: ', 'eNVaL3 = eNVaL3',         weBool(True));

    t.Add('ENUM-EQ: ', 'TEnum('+p+'Enum) = eNVaL2',        weBool(False));
    t.Add('ENUM-EQ: ', 'TEnum('+p+'Enum) = eNVaL3',        weBool(True));
    t.Add('ENUM-EQ: ', p+'Enum = TEnum(1)',        weBool(False));
    t.Add('ENUM-EQ: ', p+'Enum = TEnum(2)',        weBool(True));
    t.Add('ENUM-EQ: ', 'TEnum(1) = '+p+'Enum',     weBool(False));
    t.Add('ENUM-EQ: ', 'TEnum(2) = '+p+'Enum',     weBool(True));
    t.Add('ENUM-EQ: ', 'TEnum(2) = TEnum(1)',      weBool(False));
    t.Add('ENUM-EQ: ', 'TEnum(2) = TEnum(2)',      weBool(True));
    t.Add('ENUM-EQ: ', 'TEnum(2) = eNVaL2',        weBool(False));
    t.Add('ENUM-EQ: ', 'TEnum(2) = eNVaL3',        weBool(True));

    t.Add('ENUM-EQ: ', p+'EnumA = '+p2+'Enum1',    weBool(False));
    t.Add('ENUM-EQ: ','ENVal2 = '+p2+'Enum1',     weBool(True));
    t.Add('ENUM-EQ: ','ENVal1 = '+p2+'Enum1',     weBool(False));

    t.Add('ENUM-Cmp: ', p+'Enum >  eNVaL2',        weBool(True));
    t.Add('ENUM-Cmp: ', p+'Enum >= eNVaL2',        weBool(True));
    t.Add('ENUM-Cmp: ', p+'Enum >  eNVaL3',        weBool(False));
    t.Add('ENUM-Cmp: ', p+'Enum >= eNVaL3',        weBool(True));
    t.Add('ENUM-Cmp: ', p+'Enum < eNVaL2',        weBool(False));
    t.Add('ENUM-Cmp: ', p+'Enum < eNVaL3',        weBool(False));
    t.Add('ENUM-Cmp: ', p+'Enum < eNVaL4',        weBool(True));
    t.Add('ENUM-Cmp: ', 'eNVaL2 < '+p+'Enum',     weBool(True));
    t.Add('ENUM-Cmp: ', 'eNVaL3 < '+p+'Enum',     weBool(False));
    t.Add('ENUM-Cmp: ', 'eNVaL3 < eNVaL2',        weBool(False));
    t.Add('ENUM-Cmp: ', 'eNVaL3 > eNVaL2',        weBool(True));

    t.Add('ENUM-Cmp: ', 'TEnum('+p+'Enum) > eNVaL2',        weBool(True));
    t.Add('ENUM-Cmp: ', 'TEnum('+p+'Enum) > eNVaL3',        weBool(False));
    t.Add('ENUM-Cmp: ', p+'Enum > TEnum(2)',        weBool(False));
    t.Add('ENUM-Cmp: ', p+'Enum > TEnum(1)',        weBool(True));
    t.Add('ENUM-Cmp: ', p+'Enum > TEnum(-1)',       weBool(False)) // Enum is all positive / cast will be an unsigned enum // changed
    .IgnAll([], Compiler.Version < 030301)
    .IgnAll(stDwarf2, Compiler.Version >= 030301);
    t.Add('ENUM-Cmp: ', p+'EnumX0a < TEnumX0(-1)',       weBool(True));
    t.Add('ENUM-Cmp: ', p+'EnumX0a > TEnumX0(-900)',       weBool(True));
    t.Add('ENUM-Cmp: ', p+'EnumX0b > TEnumX0(-1)',       weBool(True));

    t.Add('ENUM-Cmp: ', p+'EnumX1a <  '+p+'EnumX1b',       weBool(True));
    t.Add('ENUM-Cmp: ', p+'EnumX1a <  EnXVal14',       weBool(True));
    t.Add('ENUM-Cmp: ', p+'EnumX1a =  EnXVal11',       weBool(True));
    t.Add('ENUM-Cmp: ', p+'EnumX1b >  EnXVal11',       weBool(True));
    t.Add('ENUM-Cmp: ', p+'EnumX1b >  EnXVal12',       weBool(True));
    t.Add('ENUM-Cmp: ',   'EnXVal11 < EnXVal14',       weBool(True));

    t.Add('ENUM-Cmp: ', p+'EnumX1Aa <  '+p+'EnumX1Ab',       weBool(True))
    .IgnAll(stDwarf2, Compiler.Version >= 030301);
    t.Add('ENUM-Cmp: ', p+'EnumX1Aa <  EnXValA14',       weBool(True))
    .IgnAll(stDwarf2, Compiler.Version >= 030301);
    t.Add('ENUM-Cmp: ', p+'EnumX1Aa =  EnXValA11',       weBool(True))
    .IgnAll(stDwarf2, Compiler.Version >= 030301);
    t.Add('ENUM-Cmp: ', p+'EnumX1Ab >  EnXValA11',       weBool(True))
    .IgnAll(stDwarf2, Compiler.Version >= 030301);
    t.Add('ENUM-Cmp: ', p+'EnumX1Ab >  EnXValA12',       weBool(True))
    .IgnAll(stDwarf2, Compiler.Version >= 030301);
    t.Add('ENUM-Cmp: ',   'EnXValA11 < EnXValA14',       weBool(True))
    .IgnAll(stDwarf2, Compiler.Version >= 030301);
  end;

var
  ExeName, enx01, enx02: String;
  t: TWatchExpectationList;
  Src: TCommonSource;
  BrkPrg: TDBGBreakPoint;
  i,j, i2, j2: Integer;
begin
  if SkipTest then exit;
  if not TestControlCanTest(ControlTestExpression) then exit;
  t := nil;

  Src := GetCommonSourceFor('WatchesValuePrg.pas');
  TestCompile(Src, ExeName, '', ' -dSINGLE_BIG_FUNC ');

  AssertTrue('Start debugger', Debugger.StartDebugger(AppDir, ExeName));

  try
    t := TWatchExpectationList.Create(Self);
    t.AcceptSkSimple := [skInteger, skCardinal, skBoolean, skChar, skFloat,
      skString, skAnsiString, skCurrency, skVariant, skWideString,
      skInterface];
    t.AddTypeNameAlias('integer', 'integer|longint');
    t.AddTypeNameAlias('Char', 'Char|AnsiChar');
    t.AddTypeNameAlias('ShortStr255', 'ShortStr255|ShortString');
    t.AddTypeNameAlias('TEnumSub', 'TEnum|TEnumSub');

    BrkPrg         := Debugger.SetBreakPoint(Src, 'Prg');
    //BrkFoo         := Debugger.SetBreakPoint(Src, 'Foo');
    //BrkFooVar      := Debugger.SetBreakPoint(Src, 'FooVar');
    //BrkFooConstRef := Debugger.SetBreakPoint(Src, 'FooConstRef');
    AssertDebuggerNotInErrorState;

    (* ************ Nested Functions ************* *)

    RunToPause(BrkPrg);

    t.Clear;

    // test mem leaks // json content
    t.Add('json ', '''[1,2]''',     weAnsiStr('[1,2]','')).IgnTypeName.IgnKind;
    t.Add('json ', '''[1,2,}]''',     weAnsiStr('[1,2,}]','')).IgnTypeName.IgnKind;

    // Constant values
    t.Add('Const-Expr: 107', '107',     weCardinal(107));
    t.Add('Const-Expr: $10', '$10',     weInteger(16));
    t.Add('Const-Expr: -17', '-17',     weInteger(-17));
    t.Add('Const-Expr: True', 'True',    weBool(True));
    t.Add('Const-Expr: False', 'False',    weBool(False));

    t.Add('Const-EQ: ', 'True and False',     weBool(False));
    t.Add('Const-EQ: ', 'True and True',     weBool(True));
    t.Add('Const-EQ: ', 'False and False',     weBool(False));
    t.Add('Const-EQ: ', 'True or False',     weBool(True));
    t.Add('Const-EQ: ', 'True or True',     weBool(True));
    t.Add('Const-EQ: ', 'False or False',     weBool(False));
    t.Add('Const-EQ: ', 'True xor False',     weBool(True));
    t.Add('Const-EQ: ', 'True xor True',     weBool(False));
    t.Add('Const-EQ: ', 'False xor False',     weBool(False));

    t.Add('Const-EQ: ', '(1=7) and (3=3)',     weBool(False));
    t.Add('Const-EQ: ', '(1<7) and (3>1)',     weBool(True));

    t.Add('Const-Expr: ansistring ', '''abc''',    weAnsiStr('abc')).IgnKind;
    t.Add('Const-Expr: ansistring ', '''''',    weAnsiStr('')).IgnKind;
    t.Add('Const-Expr: ansistring ', '''abc''''DE''',    weAnsiStr('abcDE')).IgnKind;
    t.Add('Const-Expr: ansistring ', '''abc''#32''DE''',    weAnsiStr('abc DE')).IgnKind;
    t.Add('Const-Expr: ansistring ', '#32''abc''',    weAnsiStr(' abc')).IgnKind;
    t.Add('Const-Expr: ansistring ', '#49#50',    weAnsiStr('12')).IgnKind;
    t.Add('Const-Expr: ansistring ', '#$30#$31',    weAnsiStr('01')).IgnKind;
    t.Add('Const-Expr: ansistring ', '#&61#&62',    weAnsiStr('12')).IgnKind;
    t.Add('Const-Expr: ansistring ', '#49',    weChar('1')).IgnKind;
    t.Add('Const-Expr: ansistring ', '#%110001',    weChar('1')).IgnKind;
    t.Add('Const-Expr: ansistring ', '#%00110001',    weChar('1')).IgnKind;

    t.Add('Const-Expr: ansistring ', '''a',    weAnsiStr('1')).IgnKind^.AddFlag(ehExpectError);
    t.Add('Const-Expr: ansistring ', '''',    weAnsiStr('1')).IgnKind^.AddFlag(ehExpectError);
    t.Add('Const-Expr: ansistring ', '#',    weAnsiStr('abc')).IgnKind.AddFlag(ehExpectError);
    t.Add('Const-Expr: ansistring ', '#$',    weAnsiStr('abc')).IgnKind.AddFlag(ehExpectError);
    t.Add('Const-Expr: ansistring ', '#''',    weAnsiStr('abc')).IgnKind.AddFlag(ehExpectError);
    t.Add('Const-Expr: ansistring ', '#$''',    weAnsiStr('abc')).IgnKind.AddFlag(ehExpectError);
    t.Add('Const-Expr: ansistring ', '#A',    weAnsiStr('abc')).IgnKind.AddFlag(ehExpectError);
    t.Add('Const-Expr: ansistring ', '#$X',    weAnsiStr('abc')).IgnKind.AddFlag(ehExpectError);

    t.Add('Const-Op: ', '10',     weCardinal(10));
    t.Add('Const-Op: ', '-10',     weInteger(-10));
    t.Add('Const-Op: ', '- -10',     weInteger(10)); // 2 unary
    t.Add('Const-Op: ', '+10',     weCardinal(10));

    t.Add('Const-Op: ', '107 + 1',     weCardinal(108));
    t.Add('Const-Op: ', '107 - 1',     weCardinal(106));
    t.Add('Const-Op: ', '107 + -1',    weInteger(106));
    t.Add('Const-Op: ', '107 + +1',    weCardinal(108));
    t.Add('Const-Op: ', '107 - -1',    weInteger(108));
    t.Add('Const-Op: ', '11 * 3',      weCardinal(33));
    t.Add('Const-Op: ', '11 * -3',     weInteger(-33));
    t.Add('Const-Op: ', '-11 * 3',     weInteger(-33));
    t.Add('Const-Op: ', '-11 * -3',    weInteger(33));
    t.Add('Const-Op: ', '11 / 3',      weMatch('3\.666', skFloat));
    t.Add('Const-Op: ', '11 div 3',    weCardinal(3));
    t.Add('Const-Op: ', '11 mod 3',    weCardinal(2));
    t.Add('Const-precedence: ', '1 + 11 * 3',      weCardinal(34));
    t.Add('Const-precedence: ', '11 * 3 + 1',      weCardinal(34));
    t.Add('Const-bracket: ', '(1 + 11) * 3',      weCardinal(36));
    t.Add('Const-bracket: ', '11 * (3 + 1)',      weCardinal(44));

    t.Add('Const-Op: ', '1.5',      weFloat(1.5));
    t.Add('Const-Op: ', '-1.5',     weFloat(-1.5));
    t.Add('Const-Op: ', '- -1.5',     weFloat(1.5));
    t.Add('Const-Op: ', '+1.5',     weFloat(1.5));

    t.Add('Const-Op: ', ' 10.5 + 1',      weFloat(11.5));
    t.Add('Const-Op: ', ' 10.0 + 1',      weFloat(11));
    t.Add('Const-Op: ', ' 10   + 1.5',    weFloat(11.5));
    t.Add('Const-Op: ', '-10   + 1.5',    weFloat(-8.5));
    t.Add('Const-Op: ', '-10   + -1.5',   weFloat(-11.5));

    t.Add('Const-Op: ', ' 10.5 - 1',      weFloat(9.5));
    t.Add('Const-Op: ', ' 10.0 - 1',      weFloat(9));
    t.Add('Const-Op: ', ' 10   - 1.5',    weFloat(8.5));
    t.Add('Const-Op: ', '-10   - 1.5',    weFloat(-11.5));
    t.Add('Const-Op: ', '-10   - -1.5',   weFloat(-8.5));

    t.Add('Const-Op: ', '10.5 * 3',      weFloat(31.5));
    t.Add('Const-Op: ', '10.0 * 3',      weFloat(30));
    t.Add('Const-Op: ', ' 9   * 1.5',    weFloat(13.5));
    t.Add('Const-Op: ', '-9   * 1.5',    weFloat(-13.5));
    t.Add('Const-Op: ', '-9   * -1.5',   weFloat(13.5));

    t.Add('Const-Op: ', ' 31.5 / 3',      weFloat(10.5));
    t.Add('Const-Op: ', ' 30.0 / 3',      weFloat(10));
    t.Add('Const-Op: ', ' 13.5 / 1.5',    weFloat(9));
    t.Add('Const-Op: ', '-13.5 / 1.5',    weFloat(-9));
    t.Add('Const-Op: ', '-13.5 / -1.5',   weFloat(9));

    t.Add('Const-Op: ', '35 And 17',     weCardinal(1));
    t.Add('Const-Op: ', '35 And 7',     weCardinal(3));
    t.Add('Const-Op: ', '35 or 7',     weCardinal(39));
    t.Add('Const-Op: ', '35 Xor 7',     weCardinal(36));

    t.Add('Const-EQ: ', '17 = $11',     weBool(True));
    t.Add('Const-EQ: ', '18 = $11',     weBool(False));
    t.Add('Const-EQ: ', '17 <> 17',     weBool(False));
    t.Add('Const-EQ: ', '18 <> 17',     weBool(True));
    t.Add('Const-EQ: ', '17 > 18',     weBool(False));
    t.Add('Const-EQ: ', '17 > 17',     weBool(False));
    t.Add('Const-EQ: ', '17 > 16',     weBool(True));
    t.Add('Const-EQ: ', '17 >= 18',     weBool(False));
    t.Add('Const-EQ: ', '17 >= 17',     weBool(True));
    t.Add('Const-EQ: ', '17 >= 16',     weBool(True));
    t.Add('Const-EQ: ', '17 < 18',     weBool(True));
    t.Add('Const-EQ: ', '17 < 17',     weBool(False));
    t.Add('Const-EQ: ', '17 < 16',     weBool(False));
    t.Add('Const-EQ: ', '17 <= 18',     weBool(True));
    t.Add('Const-EQ: ', '17 <= 17',     weBool(True));
    t.Add('Const-EQ: ', '17 <= 16',     weBool(False));

    t.Add('Const-EQ: ', '''A'' = #65',     weBool(True));
    t.Add('Const-EQ: ', '''A'' = #65#65',  weBool(False));
    t.Add('Const-EQ: ', '''A'' = ''B''',   weBool(False));
    t.Add('Const-EQ: ', '''A'' <> #65',     weBool(False));
    t.Add('Const-EQ: ', '''A'' <> #65#65',  weBool(True));
    t.Add('Const-EQ: ', '''A'' <> ''B''',   weBool(True));

    t.Add('Const-EQ: ', '17.0 = $11',     weBool(True));
    t.Add('Const-EQ: ', '18.0 = $11',     weBool(False));
    t.Add('Const-EQ: ', '17.0 <> 17',     weBool(False));
    t.Add('Const-EQ: ', '18.0 <> 17',     weBool(True));
    t.Add('Const-EQ: ', '17.0 > 18',     weBool(False));
    t.Add('Const-EQ: ', '17.0 > 17',     weBool(False));
    t.Add('Const-EQ: ', '17.0 > 16',     weBool(True));
    t.Add('Const-EQ: ', '17.0 >= 18',     weBool(False));
    t.Add('Const-EQ: ', '17.0 >= 17',     weBool(True));
    t.Add('Const-EQ: ', '17.0 >= 16',     weBool(True));
    t.Add('Const-EQ: ', '17.0 < 18',     weBool(True));
    t.Add('Const-EQ: ', '17.0 < 17',     weBool(False));
    t.Add('Const-EQ: ', '17.0 < 16',     weBool(False));
    t.Add('Const-EQ: ', '17.0 <= 18',     weBool(True));
    t.Add('Const-EQ: ', '17.0 <= 17',     weBool(True));
    t.Add('Const-EQ: ', '17.0 <= 16',     weBool(False));

    t.Add('Const-EQ: ', '17.5 = 17.5',     weBool(True));
    t.Add('Const-EQ: ', '17.1 <> 17.5',    weBool(True));
    t.Add('Const-EQ: ', '17.1 < 17.5',     weBool(True));
    t.Add('Const-EQ: ', '17.8 > 17.5',     weBool(True));
    t.Add('Const-EQ: ', '17.5 = 17.1',     weBool(False));
    t.Add('Const-EQ: ', '17.5 <> 17.5',    weBool(False));
    t.Add('Const-EQ: ', '17.8 < 17.5',     weBool(False));
    t.Add('Const-EQ: ', '17.1 > 17.5',     weBool(False));

    t.Add('Const-EQ: ', '12 = ''abc''',     weBool(False)).ExpectError();

    t.Add('Pointer-Op: ', 'LongInt(Pointer(10)+4)',     weInteger(14));

    t.Add('Pointer-Op: ', 'Pointer(10)-Pointer(4)',     weInteger(6));
    t.Add('Pointer-Op: ', 'PWord(10)-PWord(4)',     weInteger(3));
    t.Add('Pointer-Op: ', '^Word(10)-^Word(4)',     weInteger(3));
    t.Add('Pointer-Op: ', '^Word(10)-Pointer(4)',     weInteger(3)).ExpectError();

    t.Add('Pointer-Op: ', '^Char(10)-^Char(4)',     weInteger(6));
    t.Add('Pointer-Op: ', '^Char(10)-PChar(4)',     weInteger(6));
    t.Add('Pointer-Op: ', 'PChar(10)-^Char(4)',     weInteger(6));
    t.Add('Pointer-Op: ', 'PChar(10)-PChar(4)',     weInteger(6));

    t.Add('Pointer-Op: ', 'gvPChar3-gvPChar2',      weInteger(3));
    t.Add('Pointer-Op: ', 'PChar(@gvAnsi2[3])-PChar(gvAnsi2)',     weInteger(2)).ChrIdxExpString(stDwarf2);
    t.Add('Pointer-Op: ', '^Char(@gvAnsi2[3])-^Char(gvAnsi2)',     weInteger(2)).ChrIdxExpString(stDwarf2);
    t.Add('Pointer-Op: ', '@gvAnsi2[3]-@gvAnsi2[1]',      weInteger(2)).ChrIdxExpString(stDwarf2);

    t.Add('Pointer-Op: ', '@gvAnsi2[3]-@gvPChar2[1]',     weInteger(1))
      .ChrIdxSkip(stDwarf2) //skip
      .ChrIdxExpPChar(stDwarf3Up);
    t.Add('Pointer-Op: ', '@gvAnsi2[3]-gvPChar2',         weInteger(2)).ChrIdxExpString();
    t.Add('Pointer-Op: ', '@gvPChar2[3]-@gvPChar2[1]',     weInteger(2)).ChrIdxExpPChar();
    t.Add('Pointer-Op: ', '@gvPChar3[2]-@gvPChar2[1]',     weInteger(4)).ChrIdxExpPChar();


    t.Add('Pointer-Op: ', 'gcPtr2 - gcPtr1',     weInteger(1000));
    t.Add('Pointer-Op: ', 'gcPtr2 - gvPtr1',     weInteger(1000));
    t.Add('Pointer-Op: ', 'gvPtr2 - gcPtr2',     weInteger(1));
    t.Add('Pointer-Op: ', 'gvPtr2 - gvPtr1',     weInteger(1001));
    t.Add('Pointer-Op: ', '@gv_sa_Word[2] - @gv_sa_Word[1]',     weInteger(1));
    t.Add('Pointer-Op: ', 'pointer(@gv_sa_Word[2]) - pointer(@gv_sa_Word[1])',     weInteger(2));


    t.Add('Set + ', '[]+[]', weSet([])).IgnTypeName;
    t.Add('Set + ', '[]+[EnVal4]', weSet(['EnVal4'])).IgnTypeName;
    t.Add('Set + ', '[EnVal1]+[]', weSet(['EnVal1'])).IgnTypeName;
    t.Add('Set + ', '[EnVal1]+[EnVal4]', weSet(['EnVal1', 'EnVal4'])).IgnTypeName;
    t.Add('Set + ', '[EnVal1]+[EnVal2, EnVal4]', weSet(['EnVal1', 'EnVal2', 'EnVal4'])).IgnTypeName;
    t.Add('Set + ', '[EnVal1, EnVal3]+[EnVal2, EnVal4]', weSet(['EnVal1', 'EnVal3', 'EnVal2', 'EnVal4'])).IgnTypeName;

    t.Add('Set + ', 'gvSet+gvSet2', weSet(['EnVal2', 'EnVal4', 'EnVal1'])).IgnTypeName.Skip([stDwarf]);
    t.Add('Set + ', 'gvSet+[EnVal3]', weSet(['EnVal2', 'EnVal4', 'EnVal3'])).IgnTypeName.Skip([stDwarf]);
    t.Add('Set + ', '[EnVal3]+gvSet', weSet(['EnVal3', 'EnVal2', 'EnVal4'])).IgnTypeName.Skip([stDwarf]);

    t.Add('Set + ', '[1,2]+[3,4]', weSet(['1','2','3','4'])).IgnTypeName;

    t.Add('Set - ', '[]-[]', weSet([])).IgnTypeName;
    t.Add('Set - ', '[]-[EnVal4]', weSet([])).IgnTypeName;
    t.Add('Set - ', '[EnVal1]-[]', weSet(['EnVal1'])).IgnTypeName;
    t.Add('Set - ', '[EnVal1]-[EnVal4]', weSet(['EnVal1'])).IgnTypeName;
    t.Add('Set - ', '[EnVal1, EnVal4]-[EnVal4]', weSet(['EnVal1'])).IgnTypeName;

    t.Add('Set >< ', '[]><[]', weSet([])).IgnTypeName;
    t.Add('Set >< ', '[EnVal4]><[EnVal4]', weSet([])).IgnTypeName;
    t.Add('Set >< ', '[]><[EnVal4]', weSet(['EnVal4'])).IgnTypeName;
    t.Add('Set >< ', '[EnVal1]><[]', weSet(['EnVal1'])).IgnTypeName;


    t.Add('IN: ', '1 in [1,2]',      weBool(True)).IgnTypeName;
    t.Add('IN: ', '1 in [01,2]',     weBool(True)).IgnTypeName;
    t.Add('IN: ', '1 in [-1,2,1]',   weBool(True)).IgnTypeName;
    t.Add('IN: ', '-1 in [-1,2,1]',  weBool(True)).IgnTypeName;
    t.Add('IN: ', '1 in [2,3]',      weBool(False)).IgnTypeName;
    t.Add('IN: ', '1 in []',        weBool(False)).IgnTypeName;

    t.Add('IN: ', 'gvWord in [-1, 101, 2]',   weBool(True)).IgnTypeName;
    t.Add('IN: ', 'gvWord in [-1, 1010, 2]',  weBool(False)).IgnTypeName;
    t.Add('IN: ', 'gvWord in []',             weBool(False)).IgnTypeName;

    t.Add('IN: ', '101 in [-1, gvWord, 2]',     weBool(True)).IgnTypeName;
    t.Add('IN: ', '102 in [-1, gvWord+1, 2]',   weBool(True)).IgnTypeName;
    t.Add('IN: ', '102 in [-1, gvWord, 2]',     weBool(False)).IgnTypeName;
    t.Add('IN: ', '101 in [-1, gvWord+1, 2]',   weBool(False)).IgnTypeName;

    t.Add('IN: ', '''a'' in [''a'', ''b'']',      weBool(True)).IgnTypeName;
    t.Add('IN: ', '''c'' in [''a'', ''b'']',      weBool(False)).IgnTypeName;
    t.Add('IN: ', '''c'' in []',                  weBool(False)).IgnTypeName;

    t.Add('IN: ', 'gvChar3 in [''a'', '' '']',      weBool(True)).IgnTypeName;
    t.Add('IN: ', 'gvChar3 in [''a'', ''d'']',      weBool(False)).IgnTypeName;
    t.Add('IN: ', 'gvChar3 in []',                  weBool(False)).IgnTypeName;


    t.Add('IN: ', 'EnVal1 in [EnVal1, EnVal2]',      weBool(True)).IgnTypeName;
    t.Add('IN: ', 'EnVal1 in [EnVal2, EnVal3]',      weBool(False)).IgnTypeName;
    t.Add('IN: ', 'EnVal1 in []',                    weBool(False)).IgnTypeName;

    t.Add('IN: ', 'EnVal1 in gvSet2',      weBool(True)).IgnTypeName.Skip([stDwarf]);
    t.Add('IN: ', 'EnVal3 in gvSet2',      weBool(False)).IgnTypeName.Skip([stDwarf]);

    AddWatches(t, 'glob',   'gv', 001, 'B', '', tlAny,     'gv', 001, 'B', '', tlAny);
    AddWatches(t, 'glob',   'gc', 000, 'A', '', tlConst,   'gv', 001, 'B', '', tlAny);
    AddWatches(t, 'glob',   'gv', 001, 'B', '', tlAny,     'gc', 000, 'A', '', tlConst);

    for i := 0 to 9 do
    for i2 := 0 to 3 do
    for j := 0 to 9 do
    for j2 := 0 to 3 do
    if ( (i2 = 0) or
         ((i in [6,7]) and (i2 < 2)) or
         (i in [1,8])
       ) and
       ( (j2 = 0) or
         ((j in [6,7]) and (j2 < 2)) or
         (j in [1,8])
       )
    then
    begin
      case i of
        0: enx01 := 'TEnumX0(-504)';
        1: case i2 of
          0: enx01 := 'TEnumX0(-503)';
          1: enx01 := 'EnXVal01';
          2: enx01 := 'gvEnumX0a';
          3: enx01 := 'gcEnumX0a';
        end;
        2: enx01 := 'TEnumX0(-502)';
        3: enx01 := 'TEnumX0(-1)';
        4: enx01 := 'TEnumX0(0)';
        5: enx01 := 'TEnumX0(1)';
        6: case i2 of
          0: enx01 := 'TEnumX0(4)';
          1: enx01 := 'EnXVal02';
        end;
        7: case i2 of
          0: enx01 := 'TEnumX0(7)';
          1: enx01 := 'EnXVal03';
        end;
        8: case i2 of
          0: enx01 := 'TEnumX0(510)';
          1: enx01 := 'EnXVal04';
          2: enx01 := 'gvEnumX0b';
          3: enx01 := 'gcEnumX0b';
        end;
        9: enx01 := 'TEnumX0(5000)';
      end;
      case j of
        0: enx02 := 'TEnumX0(-504)';
        1: case j2 of
          0: enx02 := 'TEnumX0(-503)';
          1: enx02 := 'EnXVal01';
          2: enx02 := 'gvEnumX0a';
          3: enx02 := 'gcEnumX0a';
        end;
        2: enx02 := 'TEnumX0(-502)';
        3: enx02 := 'TEnumX0(-1)';
        4: enx02 := 'TEnumX0(0)';
        5: enx02 := 'TEnumX0(1)';
        6: case j2 of
          0: enx02 := 'TEnumX0(4)';
          1: enx02 := 'EnXVal02';
        end;
        7: case j2 of
          0: enx02 := 'TEnumX0(7)';
          1: enx02 := 'EnXVal03';
        end;
        8: case j2 of
          0: enx02 := 'TEnumX0(510)';
          1: enx02 := 'EnXVal04';
          2: enx02 := 'gvEnumX0b';
          3: enx02 := 'gcEnumX0b';
        end;
        9: enx02 := 'TEnumX0(5000)';
      end;

      t.Add('Signed TEnumX0-Cmp > : ', enx01+' > '+enx02,       weBool(i >  j ));
      t.Add('Signed TEnumX0-Cmp < : ', enx01+' < '+enx02,       weBool(i <  j ));
      t.Add('Signed TEnumX0-Cmp <>: ', enx01+' <> '+enx02,      weBool(i <> j ));
      t.Add('Signed TEnumX0-Cmp = : ', enx01+' = '+enx02,       weBool(i =  j ));
//      t.Add('Signed ENUM-Cmp: ', enx01+' in ['+enx02+']', weBool((i and $FFFC) = (j and $FFFC)));


      case i of
        0: enx01 := 'TEnumX1(-4)';
        1: case i2 of
          0: enx01 := 'TEnumX1(-3)';
          1: enx01 := 'EnXVal11';
          2: enx01 := 'gvEnumX1a';
          3: enx01 := 'gcEnumX1a';
        end;
        2: enx01 := 'TEnumX1(-2)';
        3: enx01 := 'TEnumX1(-1)';
        4: enx01 := 'TEnumX1(0)';
        5: enx01 := 'TEnumX1(1)';
        6: case i2 of
          0: enx01 := 'TEnumX1(4)';
          1: enx01 := 'EnXVal12';
        end;
        7: case i2 of
          0: enx01 := 'TEnumX1(7)';
          1: enx01 := 'EnXVal13';
        end;
        8: case i2 of
          0: enx01 := 'TEnumX1(10)';
          1: enx01 := 'EnXVal14';
          2: enx01 := 'gvEnumX1b';
          3: enx01 := 'gcEnumX1b';
        end;
        9: enx01 := 'TEnumX1(50)';
      end;
      case j of
        0: enx02 := 'TEnumX1(-4)';
        1: case j2 of
          0: enx02 := 'TEnumX1(-3)';
          1: enx02 := 'EnXVal11';
          2: enx02 := 'gvEnumX1a';
          3: enx02 := 'gcEnumX1a';
        end;
        2: enx02 := 'TEnumX1(-2)';
        3: enx02 := 'TEnumX1(-1)';
        4: enx02 := 'TEnumX1(0)';
        5: enx02 := 'TEnumX1(1)';
        6: case j2 of
          0: enx02 := 'TEnumX1(4)';
          1: enx02 := 'EnXVal12';
        end;
        7: case j2 of
          0: enx02 := 'TEnumX1(7)';
          1: enx02 := 'EnXVal13';
        end;
        8: case j2 of
          0: enx02 := 'TEnumX1(10)';
          1: enx02 := 'EnXVal14';
          2: enx02 := 'gvEnumX1b';
          3: enx02 := 'gcEnumX1b';
        end;
        9: enx02 := 'TEnumX1(50)';
      end;

      t.Add('Signed TEnumX1-Cmp > : ', enx01+' > '+enx02,       weBool(i >  j ));
      t.Add('Signed TEnumX1-Cmp < : ', enx01+' < '+enx02,       weBool(i <  j ));
      t.Add('Signed TEnumX1-Cmp <>: ', enx01+' <> '+enx02,      weBool(i <> j ));
      t.Add('Signed TEnumX1-Cmp = : ', enx01+' = '+enx02,       weBool(i =  j ));
//      t.Add('Signed ENUM-Cmp: ', enx01+' in ['+enx02+']', weBool((i and $FFFC) = (j and $FFFC)));

    end;


    for i := 0 to t.Count - 1 do begin
      t.Tests[i].IgnTypeName();

      if (t.Tests[i]^.TstExpected.ExpResultKind = rkInteger) then
        t.Tests[i]^.TstExpected.ExpIntSize := -1
      else
      if (t.Tests[i]^.TstExpected.ExpResultKind = rkCardinal) then
        t.Tests[i]^.TstExpected.ExpCardinalSize := -1;
    end;

    t.EvaluateWatches;
    t.CheckResults;

  finally
    Debugger.RunToNextPause(dcStop);
    t.Free;
    Debugger.ClearDebuggerMonitors;
    Debugger.FreeDebugger;

    AssertTestErrors;
  end;
end;

procedure TTestWatches.TestWatchesModify;
  procedure WaitForModify;
  var
    i: Integer;
  begin
    // Modify does not have a callback (yet). So wait for an eval
    FEvalDone := False;
    Debugger.LazDebugger.Evaluate('p', @DoEvalDone);
    i := 0;
    while (not FEvalDone) and (i < 5*400) do begin // timeout after 5 sec
      Application.Idle(False);
      Debugger.WaitForFinishRun(25);
      inc(i);
    end;
  end;
var
  ExeName, ExpName: String;
  t: TWatchExpectationList;
  Src: TCommonSource;
  BrkPrg: TDBGBreakPoint;
  ExpPre: TWatchExpectationResult;
  testidx: Integer;
begin
  if SkipTest then exit;
  if not TestControlCanTest(ControlTestModify) then exit;
  t := nil;

  Src := GetCommonSourceFor('WatchesValuePrg.pas');
  TestCompile(Src, ExeName, '', ' -dSINGLE_BIG_FUNC ');

  AssertTrue('Start debugger', Debugger.StartDebugger(AppDir, ExeName));

  try
    t := TWatchExpectationList.Create(Self);
    t.AcceptSkSimple := [skInteger, skCardinal, skBoolean, skChar, skFloat,
      skString, skAnsiString, skCurrency, skVariant, skWideString,
      skInterface];
    t.AddTypeNameAlias('integer', 'integer|longint');
    t.AddTypeNameAlias('cardinal', 'cardinal|longword');
    t.AddTypeNameAlias('Char', 'Char|AnsiChar');
    t.AddTypeNameAlias('BYTEBOOL', 'boolean|BYTEBOOL');
    t.AddTypeNameAlias('TEnumSub', 'TEnum|TEnumSub');

    BrkPrg         := Debugger.SetBreakPoint(Src, 'Prg');
    AssertDebuggerNotInErrorState;

    (* ************ Nested Functions ************* *)

    RunToPause(BrkPrg);

    for testidx := 0 to 1 do begin
      ExpPre := weCardinal(qword($9696969696969696),    'QWord', 8);
      ExpName := 'ModifyTest';
      if testidx = 1 then begin
        ExpPre := weCardinal(byte($96),    'Byte', 1);
        ExpName := 'ModifyPackTest';
      end;

      t.Clear;

      //t.Add(AName, p+'QWord'+e,      weCardinal(10000+n,                'QWord',    8));
      //t.Add(AName, p+'Shortint'+e,   weInteger (50+n,                   'Shortint', 1));

      t.Add('(before)', ExpName + 'Byte.pre',    ExpPre);
      t.Add('(before)', ExpName + 'Byte.post',   weCardinal($69,    'Byte', 1));
      t.Add('(before)', ExpName + 'Byte.val',    weCardinal($01,    'Byte', 1));
      t.EvaluateWatches;
      t.CheckResults;
      t.Clear;
      Debugger.LazDebugger.Modify(ExpName + 'Byte.val', '131');
      WaitForModify;
      t.Add('(after)', ExpName + 'Byte.pre',    ExpPre);
      t.Add('(after)', ExpName + 'Byte.post',   weCardinal($69,    'Byte', 1));
      t.Add('(after)', ExpName + 'Byte.val',    weCardinal(131,    'Byte', 1));
      t.EvaluateWatches;
      t.CheckResults;
      t.Clear;


      t.Add('(before)', ExpName + 'Word.pre',    ExpPre);
      t.Add('(before)', ExpName + 'Word.post',   weCardinal($69,    'Byte', 1));
      t.Add('(before)', ExpName + 'Word.val',    weCardinal($0101,    'Word', 2));
      t.EvaluateWatches;
      t.CheckResults;
      t.Clear;
      Debugger.LazDebugger.Modify(ExpName + 'Word.val', '35131');
      WaitForModify;
      t.Add('(after)', ExpName + 'Word.pre',    ExpPre);
      t.Add('(after)', ExpName + 'Word.post',   weCardinal($69,    'Byte', 1));
      t.Add('(after)', ExpName + 'Word.val',    weCardinal(35131,    'Word', 2));
      t.EvaluateWatches;
      t.CheckResults;
      t.Clear;


      t.Add('(before)', ExpName + 'Cardinal.pre',    ExpPre);
      t.Add('(before)', ExpName + 'Cardinal.post',   weCardinal($69,    'Byte', 1));
      t.Add('(before)', ExpName + 'Cardinal.val',    weCardinal($81020102,    'Cardinal', 4));
      t.EvaluateWatches;
      t.CheckResults;
      t.Clear;
      Debugger.LazDebugger.Modify(ExpName + 'Cardinal.val', '$9AA93333');
      WaitForModify;
      t.Add('(after)', ExpName + 'Cardinal.pre',    ExpPre);
      t.Add('(after)', ExpName + 'Cardinal.post',   weCardinal($69,    'Byte', 1));
      t.Add('(after)', ExpName + 'Cardinal.val',    weCardinal($9AA93333,    'Cardinal', 4));
      t.EvaluateWatches;
      t.CheckResults;
      t.Clear;


      t.Add('(before)', ExpName + 'QWord.pre',    ExpPre);
      t.Add('(before)', ExpName + 'QWord.post',   weCardinal($69,    'Byte', 1));
      t.Add('(before)', ExpName + 'QWord.val',    weCardinal(qword($8102010201020102),    'QWord', 8));
      t.EvaluateWatches;
      t.CheckResults;
      t.Clear;
      Debugger.LazDebugger.Modify(ExpName + 'QWord.val', '$9AA9333344224422');
      WaitForModify;
      t.Add('(after)', ExpName + 'QWord.pre',    ExpPre);
      t.Add('(after)', ExpName + 'QWord.post',   weCardinal($69,    'Byte', 1));
      t.Add('(after)', ExpName + 'QWord.val',    weCardinal(qword($9AA9333344224422),    'QWord', 8));
      t.EvaluateWatches;
      t.CheckResults;
      t.Clear;


      t.Add('(before)', ExpName + 'Int.pre',    ExpPre);
      t.Add('(before)', ExpName + 'Int.post',   weCardinal($69,    'Byte', 1));
      t.Add('(before)', ExpName + 'Int.val',    weInteger(-$01030103,    'Integer', 4));
      t.EvaluateWatches;
      t.CheckResults;
      t.Clear;
      Debugger.LazDebugger.Modify(ExpName + 'Int.val', '$44225522');
      WaitForModify;
      t.Add('(after)', ExpName + 'Int.pre',    ExpPre);
      t.Add('(after)', ExpName + 'Int.post',   weCardinal($69,    'Byte', 1));
      t.Add('(after)', ExpName + 'Int.val',    weInteger($44225522,    'Integer', 4));
      t.EvaluateWatches;
      t.CheckResults;
      t.Clear;


      t.Add('(before)', ExpName + 'Int64.pre',    ExpPre);
      t.Add('(before)', ExpName + 'Int64.post',   weCardinal($69,    'Byte', 1));
      t.Add('(before)', ExpName + 'Int64.val',    weInteger(-$0103010301030103,    'Int64', 8));
      t.EvaluateWatches;
      t.CheckResults;
      t.Clear;
      Debugger.LazDebugger.Modify(ExpName + 'Int64.val', '$4422552201020102');
      WaitForModify;
      t.Add('(after)', ExpName + 'Int64.pre',    ExpPre);
      t.Add('(after)', ExpName + 'Int64.post',   weCardinal($69,    'Byte', 1));
      t.Add('(after)', ExpName + 'Int64.val',    weInteger($4422552201020102,    'Int64', 8));
      t.EvaluateWatches;
      t.CheckResults;
      t.Clear;


      t.Add('(before)', ExpName + 'Pointer.pre',    ExpPre);
      t.Add('(before)', ExpName + 'Pointer.post',   weCardinal($69,    'Byte', 1));
      t.Add('(before)', ExpName + 'Pointer.val',    wePointerAddr(Pointer(30), 'Pointer'));
      t.EvaluateWatches;
      t.CheckResults;
      t.Clear;
      Debugger.LazDebugger.Modify(ExpName + 'Pointer.val', '50');
      WaitForModify;
      t.Add('(after)', ExpName + 'Pointer.pre',    ExpPre);
      t.Add('(after)', ExpName + 'Pointer.post',   weCardinal($69,    'Byte', 1));
      t.Add('(after)', ExpName + 'Pointer.val',    wePointerAddr(Pointer(50), 'Pointer'));
      t.EvaluateWatches;
      t.CheckResults;
      t.Clear;


      t.Add('(before)', ExpName + 'PWord.pre',    ExpPre);
      t.Add('(before)', ExpName + 'PWord.post',   weCardinal($69,    'Byte', 1));
      t.Add('(before)', ExpName + 'PWord.val',    wePointerAddr(Pointer(40), 'PWord'));
      t.EvaluateWatches;
      t.CheckResults;
      t.Clear;
      Debugger.LazDebugger.Modify(ExpName + 'PWord.val', '70');
      WaitForModify;
      t.Add('(after)', ExpName + 'PWord.pre',    ExpPre);
      t.Add('(after)', ExpName + 'PWord.post',   weCardinal($69,    'Byte', 1));
      t.Add('(after)', ExpName + 'PWord.val',    wePointerAddr(Pointer(70), 'PWord'));
      t.EvaluateWatches;
      t.CheckResults;
      t.Clear;


      t.Add('(before)', ExpName + 'Bool.pre',    ExpPre);
      t.Add('(before)', ExpName + 'Bool.post',   weCardinal($69,    'Byte', 1));
      t.Add('(before)', ExpName + 'Bool.val',    weBool(True));
      t.EvaluateWatches;
      t.CheckResults;
      t.Clear;
      Debugger.LazDebugger.Modify(ExpName + 'Bool.val', 'False');
      WaitForModify;
      t.Add('(after)', ExpName + 'Bool.pre',    ExpPre);
      t.Add('(after)', ExpName + 'Bool.post',   weCardinal($69,    'Byte', 1));
      t.Add('(after)', ExpName + 'Bool.val',    weBool(False));
      t.EvaluateWatches;
      t.CheckResults;
      t.Clear;


      t.Add('(before)', ExpName + 'ByteBool.pre',    ExpPre);
      t.Add('(before)', ExpName + 'ByteBool.post',   weCardinal($69,    'Byte', 1));
      t.Add('(before)', ExpName + 'ByteBool.val',    weSizedBool(False, 'BYTEBOOL'));
      t.EvaluateWatches;
      t.CheckResults;
      t.Clear;
      Debugger.LazDebugger.Modify(ExpName + 'ByteBool.val', 'True');
      WaitForModify;
      t.Add('(after)', ExpName + 'ByteBool.pre',    ExpPre);
      t.Add('(after)', ExpName + 'ByteBool.post',   weCardinal($69,    'Byte', 1));
      t.Add('(after)', ExpName + 'ByteBool.val',    weSizedBool(True, 'BYTEBOOL'));
      t.EvaluateWatches;
      t.CheckResults;
      t.Clear;


      t.Add('(before)', ExpName + 'Char.pre',    ExpPre);
      t.Add('(before)', ExpName + 'Char.post',   weCardinal($69,    'Byte', 1));
      t.Add('(before)', ExpName + 'Char.val',    weChar('B'));
      t.EvaluateWatches;
      t.CheckResults;
      t.Clear;
      Debugger.LazDebugger.Modify(ExpName + 'Char.val', 'X');
      WaitForModify;
      t.Add('(after)', ExpName + 'Char.pre',    ExpPre);
      t.Add('(after)', ExpName + 'Char.post',   weCardinal($69,    'Byte', 1));
      t.Add('(after)', ExpName + 'Char.val',    weChar('X'));
      t.EvaluateWatches;
      t.CheckResults;
      t.Clear;


      t.Add('(before)', ExpName + 'WideChar.pre',    ExpPre);
      t.Add('(before)', ExpName + 'WideChar.post',   weCardinal($69,    'Byte', 1));
      t.Add('(before)', ExpName + 'WideChar.val',    weWideChar('B'));
      t.EvaluateWatches;
      t.CheckResults;
      t.Clear;
      Debugger.LazDebugger.Modify(ExpName + 'WideChar.val', 'Y');
      WaitForModify;
      t.Add('(after)', ExpName + 'WideChar.pre',    ExpPre);
      t.Add('(after)', ExpName + 'WideChar.post',   weCardinal($69,    'Byte', 1));
      t.Add('(after)', ExpName + 'WideChar.val',    weWideChar('Y'));
      t.EvaluateWatches;
      t.CheckResults;
      t.Clear;


      t.Add('(before)', ExpName + 'Enum.pre',    ExpPre);
      t.Add('(before)', ExpName + 'Enum.post',   weCardinal($69,    'Byte', 1));
      t.Add('(before)', ExpName + 'Enum.val',    weEnum('EnVal2'));
      t.EvaluateWatches;
      t.CheckResults;
      t.Clear;
      Debugger.LazDebugger.Modify(ExpName + 'Enum.val', 'EnVal4');
      WaitForModify;
      t.Add('(after)', ExpName + 'Enum.pre',    ExpPre);
      t.Add('(after)', ExpName + 'Enum.post',   weCardinal($69,    'Byte', 1));
      t.Add('(after)', ExpName + 'Enum.val',    weEnum('EnVal4'));
      t.EvaluateWatches;
      t.CheckResults;
      t.Clear;


      t.Add('(before)', ExpName + 'Enum16.pre',    ExpPre);
      t.Add('(before)', ExpName + 'Enum16.post',   weCardinal($69,    'Byte', 1));
      t.Add('(before)', ExpName + 'Enum16.val',    weEnum('ExValX2'));
      t.EvaluateWatches;
      t.CheckResults;
      t.Clear;
      Debugger.LazDebugger.Modify(ExpName + 'Enum16.val', 'ExValX7');
      WaitForModify;
      t.Add('(after)', ExpName + 'Enum16.pre',    ExpPre);
      t.Add('(after)', ExpName + 'Enum16.post',   weCardinal($69,    'Byte', 1));
      t.Add('(after)', ExpName + 'Enum16.val',    weEnum('ExValX7'));
      t.EvaluateWatches;
      t.CheckResults;
      t.Clear;

      if Compiler.SymbolType <> stDwarf then begin

        t.Add('(before)', ExpName + 'Set.pre',    ExpPre);
        t.Add('(before)', ExpName + 'Set.post',   weCardinal($69,    'Byte', 1));
        t.Add('(before)', ExpName + 'Set.val',    weSet(['EnVal2', 'EnVal4']));
        t.EvaluateWatches;
        t.CheckResults;
        t.Clear;
        Debugger.LazDebugger.Modify(ExpName + 'Set.val', ' [ EnVal1, EnVal3] ');
        WaitForModify;
        t.Add('(after)', ExpName + 'Set.pre',    ExpPre);
        t.Add('(after)', ExpName + 'Set.post',   weCardinal($69,    'Byte', 1));
        t.Add('(after)', ExpName + 'Set.val',    weSet(['EnVal1', 'EnVal3']));
        t.EvaluateWatches;
        t.CheckResults;
        t.Clear;
        Debugger.LazDebugger.Modify(ExpName + 'Set.val', ' [ EnVal1] ');
        WaitForModify;
        t.Add('(after)', ExpName + 'Set.pre',    ExpPre);
        t.Add('(after)', ExpName + 'Set.post',   weCardinal($69,    'Byte', 1));
        t.Add('(after)', ExpName + 'Set.val',    weSet(['EnVal1']));
        t.EvaluateWatches;
        t.CheckResults;
        t.Clear;
        Debugger.LazDebugger.Modify(ExpName + 'Set.val', ' [ EnVal4] ');
        WaitForModify;
        t.Add('(after)', ExpName + 'Set.pre',    ExpPre);
        t.Add('(after)', ExpName + 'Set.post',   weCardinal($69,    'Byte', 1));
        t.Add('(after)', ExpName + 'Set.val',    weSet(['EnVal4']));
        t.EvaluateWatches;
        t.CheckResults;
        t.Clear;


        t.Add('(before)', ExpName + 'Set4.pre',    ExpPre);
        t.Add('(before)', ExpName + 'Set4.post',   weCardinal($69,    'Byte', 1));
        t.Add('(before)', ExpName + 'Set4.val',    weSet(['E4Val02', 'E4Val09']));
        t.EvaluateWatches;
        t.CheckResults;
        t.Clear;
        Debugger.LazDebugger.Modify(ExpName + 'Set4.val', '[E4Val03,E4Val0A ]');
        WaitForModify;
        t.Add('(after)', ExpName + 'Set4.pre',    ExpPre);
        t.Add('(after)', ExpName + 'Set4.post',   weCardinal($69,    'Byte', 1));
        t.Add('(after)', ExpName + 'Set4.val',    weSet(['E4Val03', 'E4Val0A']));
        t.EvaluateWatches;
        t.CheckResults;
        t.Clear;
        Debugger.LazDebugger.Modify(ExpName + 'Set4.val', ' [E4Val0B ]');
        WaitForModify;
        t.Add('(after)', ExpName + 'Set4.pre',    ExpPre);
        t.Add('(after)', ExpName + 'Set4.post',   weCardinal($69,    'Byte', 1));
        t.Add('(after)', ExpName + 'Set4.val',    weSet(['E4Val0B']));
        t.EvaluateWatches;
        t.CheckResults;
        t.Clear;


        t.Add('(before)', ExpName + 'Set6.pre',    ExpPre);
        t.Add('(before)', ExpName + 'Set6.post',   weCardinal($69,    'Byte', 1));
        t.Add('(before)', ExpName + 'Set6.val',    weSet(['E6Val02', 'E6Val1A']));
        t.EvaluateWatches;
        t.CheckResults;
        t.Clear;
        Debugger.LazDebugger.Modify(ExpName + 'Set6.val', '[E6Val03,E6Val1B ]');
        WaitForModify;
        t.Add('(after)', ExpName + 'Set6.pre',    ExpPre);
        t.Add('(after)', ExpName + 'Set6.post',   weCardinal($69,    'Byte', 1));
        t.Add('(after)', ExpName + 'Set6.val',    weSet(['E6Val03', 'E6Val1B']));
        t.EvaluateWatches;
        t.CheckResults;
        t.Clear;


        t.Add('(before)', ExpName + 'Set7.pre',    ExpPre);
        t.Add('(before)', ExpName + 'Set7.post',   weCardinal($69,    'Byte', 1));
        t.Add('(before)', ExpName + 'Set7.val',    weSet(['E7Val02', 'E7Val3A']));
        t.EvaluateWatches;
        t.CheckResults;
        t.Clear;
        Debugger.LazDebugger.Modify(ExpName + 'Set7.val', '[E7Val03,E7Val12,E7Val3B ]');
        WaitForModify;
        t.Add('(after)', ExpName + 'Set7.pre',    ExpPre);
        t.Add('(after)', ExpName + 'Set7.post',   weCardinal($69,    'Byte', 1));
        t.Add('(after)', ExpName + 'Set7.val',    weSet(['E7Val03', 'E7Val12', 'E7Val3B']));
        t.EvaluateWatches;
        t.CheckResults;
        t.Clear;


        t.Add('(before)', ExpName + 'Set8.pre',    ExpPre);
        t.Add('(before)', ExpName + 'Set8.post',   weCardinal($69,    'Byte', 1));
        t.Add('(before)', ExpName + 'Set8.val',    weSet(['E8Val02', 'E8Val59']));
        t.EvaluateWatches;
        t.CheckResults;
        t.Clear;
        Debugger.LazDebugger.Modify(ExpName + 'Set8.val', '[E8Val03,E8Val12,E8Val58 ]');
        WaitForModify;
        t.Add('(after)', ExpName + 'Set8.pre',    ExpPre);
        t.Add('(after)', ExpName + 'Set8.post',   weCardinal($69,    'Byte', 1));
        t.Add('(after)', ExpName + 'Set8.val',    weSet(['E8Val03', 'E8Val12', 'E8Val58']));
        t.EvaluateWatches;
        t.CheckResults;
        t.Clear;


        t.Add('(before)', ExpName + 'SRangeSet.pre',    ExpPre);
        t.Add('(before)', ExpName + 'SRangeSet.post',   weCardinal($69,    'Byte', 1));
        t.Add('(before)', ExpName + 'SRangeSet.val',    weSet(['20','23','28']));
        t.EvaluateWatches;
        t.CheckResults;
        t.Clear;
        Debugger.LazDebugger.Modify(ExpName + 'SRangeSet.val', '[21,$18,27 ]');
        WaitForModify;
        t.Add('(after)', ExpName + 'SRangeSet.pre',    ExpPre);
        t.Add('(after)', ExpName + 'SRangeSet.post',   weCardinal($69,    'Byte', 1));
        t.Add('(after)', ExpName + 'SRangeSet.val',    weSet(['21', '24', '27']));
        t.EvaluateWatches;
        t.CheckResults;
        t.Clear;
        Debugger.LazDebugger.Modify(ExpName + 'SRangeSet.val', '[30 ]');
        WaitForModify;
        t.Add('(after)', ExpName + 'SRangeSet.pre',    ExpPre);
        t.Add('(after)', ExpName + 'SRangeSet.post',   weCardinal($69,    'Byte', 1));
        t.Add('(after)', ExpName + 'SRangeSet.val',    weSet(['30']));
        t.EvaluateWatches;
        t.CheckResults;
        t.Clear;

      end;

    end;
  finally
    Debugger.RunToNextPause(dcStop);
    t.Free;
    Debugger.ClearDebuggerMonitors;
    Debugger.FreeDebugger;

    AssertTestErrors;
  end;
end;

procedure TTestWatches.TestWatchesErrors;
var
  ExeName, op1, op2: String;
  t: TWatchExpectationList;
  Src: TCommonSource;
  BrkPrg: TDBGBreakPoint;
begin
  if SkipTest then exit;
  if not TestControlCanTest(ControlTestErrors) then exit;
  t := nil;

  Src := GetCommonSourceFor('WatchesValuePrg.pas');
  TestCompile(Src, ExeName, '', ' -dSINGLE_BIG_FUNC ');

  AssertTrue('Start debugger', Debugger.StartDebugger(AppDir, ExeName));

  try
    t := TWatchExpectationList.Create(Self);
    t.AcceptSkSimple := [skInteger, skCardinal, skBoolean, skChar, skFloat,
      skString, skAnsiString, skCurrency, skVariant, skWideString,
      skInterface];
    t.AddTypeNameAlias('integer', 'integer|longint');
    t.AddTypeNameAlias('Char', 'Char|AnsiChar');
    t.AddTypeNameAlias('ShortStr255', 'ShortStr255|ShortString');
    t.AddTypeNameAlias('TEnumSub', 'TEnum|TEnumSub');

    BrkPrg         := Debugger.SetBreakPoint(Src, 'Prg');
    //BrkFoo         := Debugger.SetBreakPoint(Src, 'Foo');
    //BrkFooVar      := Debugger.SetBreakPoint(Src, 'FooVar');
    //BrkFooConstRef := Debugger.SetBreakPoint(Src, 'FooConstRef');
    AssertDebuggerNotInErrorState;

    (* ************ Nested Functions ************* *)

    RunToPause(BrkPrg);

    t.Clear;
    // Constant values
    //t.Add('', '^char(1)^+[1]',   weMatchErr('Can not evaluate: "\[1\]"'));
    t.Add('', '^char(1)^+[1]',   weMatchErr('.'));

    t.Add('', 'not_exist_fooxyz',    weMatchFpErr(LazErrSymbolNotFound_p));
    t.Add('', 'gvAnsi4[99]',         weMatchFpErr(LazErrPasParserIndexError_Wrapper + '%x' + LazErrIndexOutOfRange)).IgnAll(stDwarf2);
    t.Add('', 'gvIntStatArray[1,2]', weMatchFpErr(LazErrPasParserIndexError_Wrapper + '%x'  + LazErrTypeNotIndexable));
    t.Add('', 'gvIntStatArray^',     weMatchFpErr(LazErrCannotDeref_p));
    t.Add('', '^byte(''abc'')^',     weMatchErr('.'));

    for op1 in [' ', '+','-'] do
    for op2 in ['   +  ','   - ', '   * ', '   / ', '   = ', ' div ', ' mod ', ' and ', ' or ', ' xor '] do
    begin
      t.Add('', op1+'^byte(0)^',       weMatchErr('read.*mem|data.*location')); // TODO: wrong error
      t.Add('', op1+'^byte(0)^'+op2+'2',     weMatchErr('read.*mem|data.*location'));
      t.Add('', op1+'2'+op2+'^byte(0)^',     weMatchErr('read.*mem|data.*location'));
      t.Add('', op1+'^byte(1)^',       weMatchErr('read.*mem|data.*location'));
      t.Add('', op1+'^byte(1)^'+op2+'2',     weMatchErr('read.*mem|data.*location'));
      t.Add('', op1+'2'+op2+'^byte(1)^',     weMatchErr('read.*mem|data.*location|div.*zero|mod.*zero'));
    end;

    for op1 in ['    ', 'not '] do
    for op2 in ['   = ', ' and ', ' or ', ' xor '] do
    begin
      t.Add('', op1+'^boolean(0)^',       weMatchErr('read.*mem|data.*location|data.*location')); // TODO: wrong error
      t.Add('', op1+'^boolean(0)^'+op2+'True',     weMatchErr('read.*mem|data.*location'));
      t.Add('', op1+'True'+op2+'^boolean(0)^',     weMatchErr('read.*mem|data.*location'));
      t.Add('', op1+'^boolean(1)^',       weMatchErr('read.*mem|data.*location'));
      t.Add('', op1+'^boolean(1)^'+op2+'True',     weMatchErr('read.*mem|data.*location'));
      t.Add('', op1+'True'+op2+'^boolean(1)^',     weMatchErr('read.*mem|data.*location'));
    end;

    t.Add('Diff ENUM types: ','gvEnum2 = gvEnum',      weMatchErr('type'));
    t.Add('Diff ENUM types: ','gvEnum2 = gvEnum1',     weMatchErr('type'));
    t.Add('Diff ENUM types: ','gvEnum2 = EnVal2',      weMatchErr('type'));


    t.EvaluateWatches;
    t.CheckResults;




  finally
    Debugger.RunToNextPause(dcStop);
    t.Free;
    Debugger.ClearDebuggerMonitors;
    Debugger.FreeDebugger;

    AssertTestErrors;
  end;
end;

procedure TTestWatches.TestClassRtti;
var
  ExeName: String;
  Src: TCommonSource;
  BrkPrg: TDBGBreakPoint;
  fp: TFpDebugDebugger;
  AnExpressionScope: TFpDbgSymbolScope;
  APasExpr: TFpPascalExpression;
  ResValue: TFpValue;
  InstClass, AnUnitName: String;
  r: Boolean;
begin
  if SkipTest then exit;
  if not TestControlCanTest(ControlTestRTTI) then exit;

  Src := GetCommonSourceFor('WatchesValuePrg.pas');
  TestCompile(Src, ExeName, '', ' -dSINGLE_BIG_FUNC ');

  AssertTrue('Start debugger', Debugger.StartDebugger(AppDir, ExeName));

  AnExpressionScope := nil;
  try
    BrkPrg         := Debugger.SetBreakPoint(Src, 'Prg');
    AssertDebuggerNotInErrorState;
    RunToPause(BrkPrg);

{$IFDEF FPDEBUG_THREAD_CHECK}
    ClearCurrentFpDebugThreadIdForAssert;
{$ENDIF}

  fp := TFpDebugDebugger(Debugger.LazDebugger);
  AnExpressionScope := fp.DbgController.CurrentProcess.FindSymbolScope(fp.DbgController.CurrentThread.ID, 0);
  TestTrue('got scope', AnExpressionScope <> nil);

  if AnExpressionScope <> nil then begin

    APasExpr := TFpPascalExpression.Create('MyClass1', AnExpressionScope);
    ResValue := APasExpr.ResultValue;

    r := ResValue.GetInstanceClassName(InstClass);
    TestTrue('got inst class ', r);
    TestEquals('inst class ', 'TMyClass', InstClass);

    r := ResValue.GetInstanceClassName(@InstClass, @AnUnitName);
    TestTrue('got inst class ', r);
    TestEquals('inst class ', 'TMyClass', InstClass);
    TestEquals('unit name', 'WatchesValuePrg', AnUnitName);

    r := ResValue.GetInstanceClassName(@InstClass, @AnUnitName, 1);
    TestTrue('got inst class ', r);
    TestEquals('inst class ', 'TMyBaseClass', InstClass);
    TestEquals('unit name', 'WatchesValuePrg', AnUnitName);

    r := ResValue.GetInstanceClassName(@InstClass, @AnUnitName, 2);
    TestTrue('got inst class ', r);
    TestEquals('inst class ', 'TObject', InstClass);
    TestEquals('unit name', 'system', lowercase(AnUnitName));

    APasExpr.Free;



    APasExpr := TFpPascalExpression.Create('MyClass2', AnExpressionScope);
    ResValue := APasExpr.ResultValue;

    r := ResValue.GetInstanceClassName(InstClass);
    TestTrue('got inst class ', r);
    TestEquals('inst class ', 'TMyClass', InstClass);

    r := ResValue.GetInstanceClassName(@InstClass, @AnUnitName);
    TestTrue('got inst class ', r);
    TestEquals('inst class ', 'TMyClass', InstClass);
    TestEquals('unit name', 'WatchesValuePrg', AnUnitName);

    r := ResValue.GetInstanceClassName(@InstClass, @AnUnitName, 1);
    TestTrue('got inst class ', r);
    TestEquals('inst class ', 'TMyBaseClass', InstClass);
    TestEquals('unit name', 'WatchesValuePrg', AnUnitName);

    r := ResValue.GetInstanceClassName(@InstClass, @AnUnitName, 2);
    TestTrue('got inst class ', r);
    TestEquals('inst class ', 'TObject', InstClass);
    TestEquals('unit name', 'system', lowercase(AnUnitName));

    APasExpr.Free;

  end;


  finally
    AnExpressionScope.ReleaseReference;

    Debugger.RunToNextPause(dcStop);
    Debugger.ClearDebuggerMonitors;
    Debugger.FreeDebugger;

    AssertTestErrors;
  end;
end;

procedure TTestWatches.TestClassMangled;
var
  ExeName: String;
  Src: TCommonSource;
  BrkPrg: TDBGBreakPoint;
  fp: TFpDebugDebugger;
  AnExpressionScope: TFpDbgSymbolScope;
  APasExpr: TFpPascalExpression;
  ResValue: TFpValue;
  InstClass, AnUnitName: String;
  r: Boolean;
  a: TFpDbgMemLocation;
begin
  if SkipTest then exit;
  if not TestControlCanTest(ControlTestMangled) then exit;
  if Compiler.Version < 030000 then exit;

  Src := GetCommonSourceFor('WatchesScopePrg.pas');
  TestCompile(Src, ExeName);

  AssertTrue('Start debugger', Debugger.StartDebugger(AppDir, ExeName));

  AnExpressionScope := nil;
  try
    BrkPrg   := Debugger.SetBreakPoint(Src, 'WatchesScopeUnit2.pas', 'MethodMainBaseBase');
    AssertDebuggerNotInErrorState;
    RunToPause(BrkPrg);

{$IFDEF FPDEBUG_THREAD_CHECK}
    ClearCurrentFpDebugThreadIdForAssert;
{$ENDIF}

  fp := TFpDebugDebugger(Debugger.LazDebugger);
  AnExpressionScope := fp.DbgController.CurrentProcess.FindSymbolScope(fp.DbgController.CurrentThread.ID, 0);
  TestTrue('got scope', AnExpressionScope <> nil);

  if AnExpressionScope <> nil then begin

    APasExpr := TFpPascalExpression.Create('MethodMainBaseBase', AnExpressionScope);
    ResValue := APasExpr.ResultValue;
    TestTrue('got inst class ', ResValue is TFpValueDwarfFreePascalSubroutine);
    if ResValue is TFpValueDwarfFreePascalSubroutine then begin
      a := TFpValueDwarfFreePascalSubroutine(ResValue).GetMangledAddress;
      TestTrue('method - got addr ' + dbgs(a), IsTargetAddr(a) );
    end;
    APasExpr.Free;

    APasExpr := TFpPascalExpression.Create('Self.MethodMainBaseBase', AnExpressionScope);
    ResValue := APasExpr.ResultValue;
    TestTrue('got inst class ', ResValue is TFpValueDwarfFreePascalSubroutine);
    if ResValue is TFpValueDwarfFreePascalSubroutine then begin
      a := TFpValueDwarfFreePascalSubroutine(ResValue).GetMangledAddress;
      TestTrue('self - got addr ' + dbgs(a), IsTargetAddr(a) );
    end;
    APasExpr.Free;

    APasExpr := TFpPascalExpression.Create('MethodMainBase', AnExpressionScope);
    ResValue := APasExpr.ResultValue;
    TestTrue('got inst class ', ResValue is TFpValueDwarfFreePascalSubroutine);
    if ResValue is TFpValueDwarfFreePascalSubroutine then begin
      a := TFpValueDwarfFreePascalSubroutine(ResValue).GetMangledAddress;
      TestTrue('method other - got addr ' + dbgs(a), IsTargetAddr(a) );
    end;
    APasExpr.Free;

    APasExpr := TFpPascalExpression.Create('Self.MethodMainBase', AnExpressionScope);
    ResValue := APasExpr.ResultValue;
    TestTrue('got inst class ', ResValue is TFpValueDwarfFreePascalSubroutine);
    if ResValue is TFpValueDwarfFreePascalSubroutine then begin
      a := TFpValueDwarfFreePascalSubroutine(ResValue).GetMangledAddress;
      TestTrue('self other - got addr ' + dbgs(a), IsTargetAddr(a) );
    end;
    APasExpr.Free;

    APasExpr := TFpPascalExpression.Create('Unit2Init', AnExpressionScope);
    ResValue := APasExpr.ResultValue;
    TestTrue('got inst class ', ResValue is TFpValueDwarfFreePascalSubroutine);
    if ResValue is TFpValueDwarfFreePascalSubroutine then begin
      a := TFpValueDwarfFreePascalSubroutine(ResValue).GetMangledAddress;
      TestTrue('function - got addr '+dbgs(a), IsTargetAddr(a) );
    end;
    APasExpr.Free;


  end
  else
    TestTrue('scope ', False);


  finally
    AnExpressionScope.ReleaseReference;

    Debugger.RunToNextPause(dcStop);
    Debugger.ClearDebuggerMonitors;
    Debugger.FreeDebugger;

    AssertTestErrors;
  end;
end;


initialization
  RegisterDbgTest(TTestWatches);
  ControlTestWatch          := TestControlRegisterTest('TTestWatch');
  ControlTestWatchScope     := TestControlRegisterTest('Scope', ControlTestWatch);
  ControlTestWatchValue     := TestControlRegisterTest('Value', ControlTestWatch);
  ControlTestWatchIntrinsic := TestControlRegisterTest('Intrinsic', ControlTestWatch);
  ControlTestWatchIntrinsic2:= TestControlRegisterTest('Intrinsic2', ControlTestWatch);
  ControlTestWatchFunct     := TestControlRegisterTest('Function', ControlTestWatch);
  ControlTestWatchFunct2    := TestControlRegisterTest('Function2', ControlTestWatch);
  ControlTestWatchFunctStr  := TestControlRegisterTest('FunctionString', ControlTestWatch);
  ControlTestWatchFunctRec  := TestControlRegisterTest('FunctionRecord', ControlTestWatch);
  ControlTestWatchFunctVariant:= TestControlRegisterTest('FunctionSysVarToLstr', ControlTestWatch);
  ControlTestWatchAddressOf := TestControlRegisterTest('AddressOf', ControlTestWatch);
  ControlTestWatchTypeCast  := TestControlRegisterTest('TypeCast', ControlTestWatch);
  ControlTestModify         := TestControlRegisterTest('Modify', ControlTestWatch);
  ControlTestExpression     := TestControlRegisterTest('Expression', ControlTestWatch);
  ControlTestErrors         := TestControlRegisterTest('Errors', ControlTestWatch);
  ControlTestRTTI           :=   TestControlRegisterTest('Rtti', ControlTestWatch);
  ControlTestMangled        :=   TestControlRegisterTest('Mangled', ControlTestWatch);

end.


