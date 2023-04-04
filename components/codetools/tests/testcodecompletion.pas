unit TestCodeCompletion;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, CodeToolManager, CodeCache,
  LazLogger, LazFileUtils, fpcunit, testregistry,
  TestFinddeclaration, TestStdCodetools;

type

  { TTestCodeCompletion }

  TTestCodeCompletion = class(TCustomTestCTStdCodetools)
  private
    procedure Test(Title: string; Src: array of string; Line, Col: integer;
      Expected: array of string);
  published
    procedure TestIntfProcUpdateArgName;
    procedure TestIntfCompleteMethodBody_ResultGenericObjFPC;
    procedure TestIntfCompleteMethodBody_ResultGenericDelphi;
    procedure TestMethodUpdateArgName_GenericObjFPC;
    procedure TestMethodUpdateArgName_GenericDelphi;
    procedure TestCompleteMethodSignature_Def_GenericObjFPC;
    procedure TestCompleteMethodSignature_Body_GenericObjFPC;
    procedure TestCompleteMethodSignature_Def_GenericDelphi;
    procedure TestCompleteMethodSignature_Body_GenericDelphi; // todo
    procedure TestCompleteMethodBody_GenericObjFPC;
    procedure TestCompleteMethodBody_GenericDelphi;
    procedure TestCompleteMethodBody_GenericMethod;
    procedure TestCompleteMethodBody_GenericFunctionResultObjFPC;
    procedure TestCompleteMethodBody_GenericFunctionResultDelphi;
    procedure TestCompleteMethodBody_ParamGenericObjFPC;
    procedure TestCompleteMethodBody_ParamGenericDelphi;
    procedure TestCompleteProperty_TypeWithUnitname;
    procedure TestCompleteProperty_TypeGenericObjFPC;
    procedure TestCompleteProperty_TypeGenericDelphi;
    procedure TestCompleteProperty_GenericObjFPC;
    procedure TestCompleteProperty_GenericDelphi;
    procedure TestCompleteVariableWithSpecializedType;
    procedure TestCompleteMethodSignature_Empty_Parentheses;
    procedure TestCompleteMethodSignature_Without_Parentheses;
    procedure TestCompleteEventAssignmentDelphi;
    procedure TestCompleteEventAssignmentObjFPC;
    procedure TestCompleteEventAssignmentObjFPC_AtName;
    procedure TestCompleteClass_Unit_NewClass;
    procedure TestCompleteClass_Unit_NewClass_BehindOldClass;
    procedure TestCompleteClass_Unit_NewClass_InFrontOfOldClass;
    procedure TestCompleteClass_Unit_NewClass_BetweenOldClasses;
    procedure TestCompleteNestedClass_Unit_NewClass_BehindParentClass;
  end;

implementation

{ TTestCodeCompletion }

procedure TTestCodeCompletion.Test(Title: string; Src: array of string; Line,
  Col: integer; Expected: array of string);
var
  i, NewX, NewY, NewTopLine, BlockTopLine, BlockBottomLine: Integer;
  s: String;
  NewCode, Code: TCodeBuffer;
begin
  Code:=CodeToolBoss.CreateFile('test1.pas');
  s:='';
  for i:=Low(Src) to High(Src) do
    s+=Src[i]+LineEnding;
  Code.Source:=s;

  if not CodeToolBoss.CompleteCode(Code,Col,Line,Line,NewCode,NewX,NewY,NewTopLine,
    BlockTopLine,BlockBottomLine,false)
  and (CodeToolBoss.ErrorDbgMsg<>'') then
  begin
    NewCode:=Code;
    NewY:=Line;
    NewX:=Col;
    if (CodeToolBoss.ErrorCode<>nil) and (CodeToolBoss.ErrorLine>0) then begin
      NewY:=CodeToolBoss.ErrorLine;
      NewX:=CodeToolBoss.ErrorColumn;
      NewCode:=CodeToolBoss.ErrorCode;
    end;
    WriteSource(NewCode.Filename,NewY,NewX);
    Fail(Title+': call CompleteCode failed: "'+CodeToolBoss.ErrorDbgMsg+'"');
  end;
  s:='';
  for i:=Low(Expected) to High(Expected) do
    s+=Expected[i]+LineEnding;
  CheckDiff(Title,s,Code.Source);
end;

procedure TTestCodeCompletion.TestIntfProcUpdateArgName;
begin
  Test('TestIntfProcUpdateArgName',
    ['unit test1;'
    ,'interface'
    ,'procedure DoIt(NewName: longint);'
    ,'implementation'
    ,'procedure DoIt(OldName: longint);'
    ,'begin end;'
    ,'end.'],
    3,1,
    ['unit test1;'
    ,'interface'
    ,'procedure DoIt(NewName: longint);'
    ,'implementation'
    ,'procedure DoIt(NewName: longint);'
    ,'begin end;'
    ,'end.']);
end;

procedure TTestCodeCompletion.TestMethodUpdateArgName_GenericObjFPC;
begin
  Test('TestMethodUpdateArgName_GenericObjFPC',
    ['unit test1;',
    '{$mode objfpc}{$H+}',
    'interface',
    'type',
    '',
    '  { TBird }',
    '',
    '  generic TBird<T: class> = class',
    '    procedure DoIt(NewName: string);',
    '  end;',
    'implementation',
    'procedure TBird.DoIt(OldName: string);',
    'begin',
    'end;',
    'end.'],
    9,1,
    ['unit test1;',
    '{$mode objfpc}{$H+}',
    'interface',
    'type',
    '',
    '  { TBird }',
    '',
    '  generic TBird<T: class> = class',
    '    procedure DoIt(NewName: string);',
    '  end;',
    'implementation',
    'procedure TBird.DoIt(NewName: string);',
    'begin',
    'end;',
    'end.']);
end;

procedure TTestCodeCompletion.TestMethodUpdateArgName_GenericDelphi;
begin
  Test('TestMethodUpdateArgName_GenericDelphi',
    ['unit test1;',
    '{$mode delphi}{$H+}',
    'interface',
    'type',
    '',
    '  { TBird }',
    '',
    '  TBird<T: class> = class',
    '    procedure DoIt(NewName: string);',
    '  end;',
    'implementation',
    'procedure TBird<T>.DoIt(OldName: string);',
    'begin',
    'end;',
    'end.'],
    9,1,
    ['unit test1;',
    '{$mode delphi}{$H+}',
    'interface',
    'type',
    '',
    '  { TBird }',
    '',
    '  TBird<T: class> = class',
    '    procedure DoIt(NewName: string);',
    '  end;',
    'implementation',
    'procedure TBird<T>.DoIt(NewName: string);',
    'begin',
    'end;',
    'end.']);
end;

procedure TTestCodeCompletion.TestIntfCompleteMethodBody_ResultGenericObjFPC;
begin
  Test('TestIntfCompleteMethodBody_ResultGenericObjFPC',
    ['unit test1;'
    ,'{$mode objfpc}{$H+}'
    ,'interface'
    ,'type'
    ,'generic TBird<T> = class'
    ,'end;'
    ,'function DoIt: specialize TBird<T>;'
    ,'implementation'
    ,'end.'],
    7,1,
    ['unit test1;'
    ,'{$mode objfpc}{$H+}'
    ,'interface'
    ,'type'
    ,'generic TBird<T> = class'
    ,'end;'
    ,'function DoIt: specialize TBird<T>;'
    ,'implementation'
    ,'function DoIt: specialize TBird<T>;'
    ,'begin'
    ,'end;'
    ,'end.']);
end;

procedure TTestCodeCompletion.TestIntfCompleteMethodBody_ResultGenericDelphi;
begin
  Test('TestIntfCompleteMethodBody_ResultGenericDelphi',
    ['unit test1;'
    ,'{$mode delphi}{$H+}'
    ,'interface'
    ,'type'
    ,'TBird<T> = class'
    ,'end;'
    ,'function DoIt: TBird<T>;'
    ,'implementation'
    ,'end.'],
    7,1,
    ['unit test1;'
    ,'{$mode delphi}{$H+}'
    ,'interface'
    ,'type'
    ,'TBird<T> = class'
    ,'end;'
    ,'function DoIt: TBird<T>;'
    ,'implementation'
    ,'function DoIt: TBird<T>;'
    ,'begin'
    ,'end;'
    ,'end.']);
end;

procedure TTestCodeCompletion.TestCompleteMethodSignature_Def_GenericObjFPC;
begin
  Test('TestCompleteMethodSignature_Def_GenericObjFPC',
    ['unit test1;',
    '{$mode objfpc}{$H+}',
    'interface',
    'type',
    '  generic TBird<T: class> = class',
    '    procedure DoIt(s: string);',
    '    procedure DoIt;',
    '  end;',
    'implementation',
    'procedure TBird.DoIt(s: char);',
    'begin',
    'end;',
    'procedure TBird.DoIt;',
    'begin',
    'end;',
    'end.'],
    6,1,
    ['unit test1;',
    '{$mode objfpc}{$H+}',
    'interface',
    'type',
    '',
    '  { TBird }',
    '',
    '  generic TBird<T: class> = class',
    '    procedure DoIt(s: string);',
    '    procedure DoIt;',
    '  end;',
    'implementation',
    'procedure TBird.DoIt(s: string);',
    'begin',
    'end;',
    'procedure TBird.DoIt;',
    'begin',
    'end;',
    'end.']);
end;

procedure TTestCodeCompletion.TestCompleteMethodSignature_Body_GenericObjFPC;
begin
  Test('TestCompleteMethodSignature_Body_GenericObjFPC',
    ['unit test1;',
    '{$mode objfpc}{$H+}',
    'interface',
    'type',
    '  generic TBird<T: class> = class',
    '    procedure DoIt(s: string);',
    '    procedure DoIt;',
    '  end;',
    'implementation',
    'procedure TBird.DoIt(s: char);',
    'begin',
    'end;',
    'procedure TBird.DoIt;',
    'begin',
    'end;',
    'end.'],
    10,1,
    ['unit test1;',
    '{$mode objfpc}{$H+}',
    'interface',
    'type',
    '  generic TBird<T: class> = class',
    '    procedure DoIt(s: char);',
    '    procedure DoIt;',
    '  end;',
    'implementation',
    'procedure TBird.DoIt(s: char);',
    'begin',
    'end;',
    'procedure TBird.DoIt;',
    'begin',
    'end;',
    'end.']);
end;

procedure TTestCodeCompletion.TestCompleteMethodSignature_Def_GenericDelphi;
begin
  Test('TestCompleteMethodSignature_Def_GenericDelphi',
    ['unit test1;',
    '{$mode delphi}{$H+}',
    'interface',
    'type',
    '  TBird<T: class> = class',
    '    procedure DoIt(s: string);',
    '    procedure DoIt;',
    '  end;',
    'implementation',
    'procedure TBird<T>.DoIt(s: char);',
    'begin',
    'end;',
    'procedure TBird<T>.DoIt;',
    'begin',
    'end;',
    'end.'],
    6,1,
    ['unit test1;',
    '{$mode delphi}{$H+}',
    'interface',
    'type',
    '',
    '  { TBird }',
    '',
    '  TBird<T: class> = class',
    '    procedure DoIt(s: string);',
    '    procedure DoIt;',
    '  end;',
    'implementation',
    'procedure TBird<T>.DoIt(s: string);',
    'begin',
    'end;',
    'procedure TBird<T>.DoIt;',
    'begin',
    'end;',
    'end.']);
end;

procedure TTestCodeCompletion.TestCompleteMethodSignature_Body_GenericDelphi;
begin
  exit;
  Test('TestCompleteMethodSignature_Body_GenericDelphi',
    ['unit test1;',
    '{$mode delphi}{$H+}',
    'interface',
    'type',
    '  TBird<T: class> = class',
    '    procedure DoIt(s: string);',
    '    procedure DoIt;',
    '  end;',
    'implementation',
    'procedure TBird<T>.DoIt(s: char);',
    'begin',
    'end;',
    'procedure TBird<T>.DoIt;',
    'begin',
    'end;',
    'end.'],
    10,1,
    ['unit test1;',
    '{$mode delphi}{$H+}',
    'interface',
    'type',
    '  TBird<T: class> = class',
    '    procedure DoIt(s: char);',
    '    procedure DoIt;',
    '  end;',
    'implementation',
    'procedure TBird<T>.DoIt(s: char);',
    'begin',
    'end;',
    'procedure TBird<T>.DoIt;',
    'begin',
    'end;',
    'end.']);
end;

procedure TTestCodeCompletion.TestCompleteMethodBody_GenericObjFPC;
begin
  Test('TestCompleteMethodBody_GenericObjFPC',
    ['unit test1;',
    '{$mode objfpc}{$H+}',
    'interface',
    'type',
    '  generic TBird<T: class> = class',
    '    procedure DoIt;',
    '  end;',
    'implementation',
    'end.'],
    6,1,
    ['unit test1;',
    '{$mode objfpc}{$H+}',
    'interface',
    'type',
    '',
    '  { TBird }',
    '',
    '  generic TBird<T: class> = class',
    '    procedure DoIt;',
    '  end;',
    'implementation',
    '',
    'procedure TBird.DoIt;',
    'begin',
    'end;',
    '',
    'end.']);
end;

procedure TTestCodeCompletion.TestCompleteMethodBody_GenericDelphi;
begin
  Test('TestCompleteMethodBody_GenericDelphi',
    ['unit test1;',
    '{$mode delphi}',
    'interface',
    'type',
    '  TBird<T: class;U> = class',
    '    procedure DoIt;',
    '  end;',
    'implementation',
    'end.'],
    6,1,
    ['unit test1;',
    '{$mode delphi}',
    'interface',
    'type',
    '',
    '  { TBird }',
    '',
    '  TBird<T: class;U> = class',
    '    procedure DoIt;',
    '  end;',
    'implementation',
    '',
    'procedure TBird<T, U>.DoIt;',
    'begin',
    '',
    'end;',
    '',
    'end.']);
end;

procedure TTestCodeCompletion.TestCompleteMethodBody_GenericMethod;
begin
  Test('TestCompleteMethodBody_GenericMethod',
    ['unit test1;',
    '{$mode delphi}',
    'interface',
    'type',
    '  TBird<T: class> = class',
    '    generic class procedure DoIt<P>(i: P);',
    '  end;',
    'implementation',
    'end.'],
    6,1,
    ['unit test1;',
    '{$mode delphi}',
    'interface',
    'type',
    '',
    '  { TBird }',
    '',
    '  TBird<T: class> = class',
    '    generic class procedure DoIt<P>(i: P);',
    '  end;',
    'implementation',
    '',
    'generic class procedure TBird<T>.DoIt<P>(i: P);',
    'begin',
    '',
    'end;',
    '',
    'end.']);
end;

procedure TTestCodeCompletion.TestCompleteMethodBody_GenericFunctionResultObjFPC;
begin
  Test('TestCompleteMethodBody_GenericFunctionResultObjFPC',
    ['unit test1;',
    '{$mode objfpc}{$H+}',
    'interface',
    'type',
    '  generic TBird<T: class> = class',
    '    function DoIt: specialize TBird<T>;',
    '  end;',
    'implementation',
    'end.'],
    6,1,
    ['unit test1;',
    '{$mode objfpc}{$H+}',
    'interface',
    'type',
    '',
    '  { TBird }',
    '',
    '  generic TBird<T: class> = class',
    '    function DoIt: specialize TBird<T>;',
    '  end;',
    'implementation',
    '',
    'function TBird.DoIt: specialize TBird<T>;',
    'begin',
    'end;',
    '',
    'end.']);
end;

procedure TTestCodeCompletion.TestCompleteMethodBody_GenericFunctionResultDelphi;
begin
  Test('TestCompleteMethodBody_GenericFunctionResultDelphi',
    ['unit test1;',
    '{$mode delphi}{$H+}',
    'interface',
    'type',
    '  TBird<T: class> = class',
    '    function DoIt: TBird<T>;',
    '  end;',
    'implementation',
    'end.'],
    6,1,
    ['unit test1;',
    '{$mode delphi}{$H+}',
    'interface',
    'type',
    '',
    '  { TBird }',
    '',
    '  TBird<T: class> = class',
    '    function DoIt: TBird<T>;',
    '  end;',
    'implementation',
    '',
    'function TBird<T>.DoIt: TBird<T>;',
    'begin',
    'end;',
    '',
    'end.']);
end;

procedure TTestCodeCompletion.TestCompleteMethodBody_ParamGenericObjFPC;
begin
  Test('TestCompleteMethodBody_ParamGenericObjFPC',
    ['unit test1;',
    '{$mode objfpc}{$H+}',
    'interface',
    'type',
    '  TBird = class',
    '    procedure DoIt(i: specialize TGenList<longint>);',
    '    procedure DoIt2(i: specialize TGenList<specialize TGenObject<integer>>);',
    '  end;',
    'implementation',
    'end.'],
    6,1,
    ['unit test1;',
    '{$mode objfpc}{$H+}',
    'interface',
    'type',
    '',
    '  { TBird }',
    '',
    '  TBird = class',
    '    procedure DoIt(i: specialize TGenList<longint>);',
    '    procedure DoIt2(i: specialize TGenList<specialize TGenObject<integer>>);',
    '  end;',
    'implementation',
    '',
    'procedure TBird.DoIt(i: specialize TGenList<longint>);',
    'begin',
    'end;',
    '',
    'procedure TBird.DoIt2(i: specialize TGenList<specialize TGenObject<integer>>);',
    'begin',
    'end;',
    '',
    'end.']);
end;

procedure TTestCodeCompletion.TestCompleteMethodBody_ParamGenericDelphi;
begin
  Test('TestCompleteMethodBody_ParamGenericDelphi',
    ['unit test1;',
    '{$mode delphi}',
    'interface',
    'type',
    '  TBird = class',
    '    procedure DoIt(i: TGenList<longint>);',
    '    procedure DoIt2(i: TGenList<TGenObject<longint>>);',
    '  end;',
    'implementation',
    'end.'],
    6,1,
    ['unit test1;',
    '{$mode delphi}',
    'interface',
    'type',
    '',
    '  { TBird }',
    '',
    '  TBird = class',
    '    procedure DoIt(i: TGenList<longint>);',
    '    procedure DoIt2(i: TGenList<TGenObject<longint>>);',
    '  end;',
    'implementation',
    '',
    'procedure TBird.DoIt(i: TGenList<longint>);',
    'begin',
    'end;',
    '',
    'procedure TBird.DoIt2(i: TGenList<TGenObject<longint>>);',
    'begin',
    'end;',
    '',
    'end.']);
end;

procedure TTestCodeCompletion.TestCompleteProperty_TypeWithUnitname;
begin
  Test('TestCompleteProperty_TypeWithUnitname',
    ['unit test1;',
    '{$mode objfpc}{$H+}',
    'interface',
    'type',
    '  TBird = class',
    '  public',
    '    property Wing: system.string;',
    '  end;',
    'implementation',
    'end.'],
    7,1,
    ['unit test1;',
    '{$mode objfpc}{$H+}',
    'interface',
    'type',
    '',
    '  { TBird }',
    '',
    '  TBird = class',
    '  private',
    '    fWing: system.string;',
    '    procedure SetWing(AValue: system.string);',
    '  public',
    '    property Wing: system.string read fWing write SetWing;',
    '  end;',
    'implementation',
    'procedure TBird.SetWing(AValue: system.string);',
    'begin',
    '  if fWing=AValue then Exit;',
    '  fWing:=AValue;',
    'end;',
    'end.']);
end;

procedure TTestCodeCompletion.TestCompleteProperty_TypeGenericObjFPC;
begin
  Test('TestCompleteProperty_TypeGenericObjFPC',
    ['unit test1;',
    '{$mode objfpc}{$H+}',
    'interface',
    'type',
    '  generic TLimb<T> = class end;',
    '  TBird = class',
    '  public',
    '    property Wing: specialize TLimb<string>;',
    '  end;',
    'implementation',
    'end.'],
    7,1,
    ['unit test1;',
    '{$mode objfpc}{$H+}',
    'interface',
    'type',
    '  generic TLimb<T> = class end;',
    '',
    '  { TBird }',
    '',
    '  TBird = class',
    '  private',
    '    fWing: specialize TLimb<string>;',
    '    procedure SetWing(AValue: specialize TLimb<string>);',
    '  public',
    '    property Wing: specialize TLimb<string> read fWing write SetWing;',
    '  end;',
    'implementation',
    'procedure TBird.SetWing(AValue: specialize TLimb<string>);',
    'begin',
    '  if fWing=AValue then Exit;',
    '  fWing:=AValue;',
    'end;',
    'end.']);
end;

procedure TTestCodeCompletion.TestCompleteProperty_TypeGenericDelphi;
begin
  Test('TestCompleteProperty_TypeGenericDelphi',
    ['unit test1;',
    '{$mode delphi}{$H+}',
    'interface',
    'type',
    '  TLimb<T> = class end;',
    '  TBird = class',
    '  public',
    '    property Wing: TLimb<string>;',
    '  end;',
    'implementation',
    'end.'],
    7,1,
    ['unit test1;',
    '{$mode delphi}{$H+}',
    'interface',
    'type',
    '  TLimb<T> = class end;',
    '',
    '  { TBird }',
    '',
    '  TBird = class',
    '  private',
    '    fWing: TLimb<string>;',
    '    procedure SetWing(AValue: TLimb<string>);',
    '  public',
    '    property Wing: TLimb<string> read fWing write SetWing;',
    '  end;',
    'implementation',
    'procedure TBird.SetWing(AValue: TLimb<string>);',
    'begin',
    '  if fWing=AValue then Exit;',
    '  fWing:=AValue;',
    'end;',
    'end.']);
end;

procedure TTestCodeCompletion.TestCompleteProperty_GenericObjFPC;
begin
  Test('TestCompleteProperty_GenericObjFPC',
    ['unit test1;',
    '{$mode objfpc}{$H+}',
    'interface',
    'type',
    '  generic TBird<T> = class',
    '  public',
    '    property Wing: string;',
    '  end;',
    'implementation',
    'end.'],
    7,1,
    ['unit test1;',
    '{$mode objfpc}{$H+}',
    'interface',
    'type',
    '',
    '  { TBird }',
    '',
    '  generic TBird<T> = class',
    '  private',
    '    fWing: string;',
    '    procedure SetWing(AValue: string);',
    '  public',
    '    property Wing: string read fWing write SetWing;',
    '  end;',
    'implementation',
    'procedure TBird.SetWing(AValue: string);',
    'begin',
    '  if fWing=AValue then Exit;',
    '  fWing:=AValue;',
    'end;',
    'end.']);
end;

procedure TTestCodeCompletion.TestCompleteProperty_GenericDelphi;
begin
  Test('TestCompleteProperty_GenericDelphi',
    ['unit test1;',
    '{$mode delphi}{$H+}',
    'interface',
    'type',
    '  TBird<T> = class',
    '  public',
    '    function Fly(w: TArray<T>): TArray<T>;',
    '    property Wing: string;',
    '  end;',
    'implementation',
    'end.'],
    7,1,
    ['unit test1;',
    '{$mode delphi}{$H+}',
    'interface',
    'type',
    '',
    '  { TBird }',
    '',
    '  TBird<T> = class',
    '  private',
    '    fWing: string;',
    '    procedure SetWing(AValue: string);',
    '  public',
    '    function Fly(w: TArray<T>): TArray<T>;',
    '    property Wing: string read fWing write SetWing;',
    '  end;',
    'implementation',
    'procedure TBird<T>.SetWing(AValue: string);',
    'begin',
    '  if fWing=AValue then Exit;',
    '  fWing:=AValue;',
    'end;',
    'function TBird<T>.Fly(w: TArray<T>): TArray<T>;',
    'begin',
    'end;',
    'end.']);
end;

procedure TTestCodeCompletion.TestCompleteVariableWithSpecializedType;
begin
  Test('TestCompleteVariableWithSpecializedType (not fixed so far)',
    ['program Project1;',
    '{$mode objfpc}{$H+}',
    'uses',
    '  Generics.Collections;',
    'type',
    '  generic TObjectList2<T> = class(specialize TObjectList<T>)',
    '  end;',
    '  TList = specialize TObjectList2<TObject>;',
    '  TClass = class',
    '    List: TList;',
    '  end;',
    'var',
    '  Base: TObject;',
    'begin',
    '  List := TClass(Base).List;',
    'end.'],
    15,3,
    ['program Project1;',
    '{$mode objfpc}{$H+}',
    'uses',
    '  Generics.Collections;',
    'type',
    '  generic TObjectList2<T> = class(specialize TObjectList<T>)',
    '  end;',
    '  TList = specialize TObjectList2<TObject>;',
    '  TClass = class',
    '    List: TList;',
    '  end;',
    'var',
    '  Base: TObject;',
    '  List: TList;',
    'begin',
    '  List := TClass(Base).List;',
    'end.']);
end;

procedure TTestCodeCompletion.TestCompleteMethodSignature_Empty_Parentheses;
begin
  Test('TestCompleteMethodSignature_Empty_Parentheses',
    ['unit SomeUnit;'
    ,'{$MODE OBJFPC}'
    ,'interface'
    ,'procedure Foo();'
    ,'implementation'
    ,'end.'],
    4,1,
    ['unit SomeUnit;'
    ,'{$MODE OBJFPC}'
    ,'interface'
    ,'procedure Foo();'
    ,'implementation'
    ,'procedure Foo();'
    ,'begin'
    ,'end;'
    ,'end.']);
end;

procedure TTestCodeCompletion.TestCompleteMethodSignature_Without_Parentheses;
begin
  Test('TestCompleteMethodSignature_Without_Parentheses',
    ['unit SomeUnit;'
    ,'{$MODE OBJFPC}'
    ,'interface'
    ,'procedure Foo;'
    ,'implementation'
    ,'end.'],
    4,1,
    ['unit SomeUnit;'
    ,'{$MODE OBJFPC}'
    ,'interface'
    ,'procedure Foo;'
    ,'implementation'
    ,'procedure Foo;'
    ,'begin'
    ,'end;'
    ,'end.']);
end;

procedure TTestCodeCompletion.TestCompleteEventAssignmentDelphi;
begin
  Test('TestCompleteEventAssignmentDelphi',
    ['unit SomeUnit;'
    ,'{$MODE DELPHI}'
    ,'interface'
    ,'type'
    ,'  TNotifyEvent = procedure(Sender: TObject) of object;'
    ,'  TBird = class'
    ,'  private'
    ,'  public'
    ,'    Eagle: TBird;'
    ,'    OnClick: TNotifyEvent;'
    ,'    procedure Fly;'
    ,'  end;'
    ,'implementation'
    ,'procedure TBird.Fly;'
    ,'begin;'
    ,'  Eagle.OnClick:='
    ,'end;'
    ,'end.'],
    16,18,
    ['unit SomeUnit;'
    ,'{$MODE DELPHI}'
    ,'interface'
    ,'type'
    ,'  TNotifyEvent = procedure(Sender: TObject) of object;'
    ,'  { TBird }'
    ,'  TBird = class'
    ,'  private'
    ,'    procedure EagleClick(Sender: TObject);'
    ,'  public'
    ,'    Eagle: TBird;'
    ,'    OnClick: TNotifyEvent;'
    ,'    procedure Fly;'
    ,'  end;'
    ,'implementation'
    ,''
    ,'procedure TBird.EagleClick(Sender: TObject);'
    ,'begin'
    ,''
    ,'end;'
    ,''
    ,'procedure TBird.Fly;'
    ,'begin;'
    ,'  Eagle.OnClick:=EagleClick;'
    ,'end;'
    ,'end.']);
end;

procedure TTestCodeCompletion.TestCompleteEventAssignmentObjFPC;
begin
  Test('TestCompleteEventAssignmentDelphi',
    ['unit SomeUnit;'
    ,'{$MODE ObjFPC}'
    ,'interface'
    ,'type'
    ,'  TNotifyEvent = procedure(Sender: TObject) of object;'
    ,'  TBird = class'
    ,'  private'
    ,'  public'
    ,'    Eagle: TBird;'
    ,'    OnClick: TNotifyEvent;'
    ,'    procedure Fly;'
    ,'  end;'
    ,'implementation'
    ,'procedure TBird.Fly;'
    ,'begin;'
    ,'  Eagle.OnClick:='
    ,'end;'
    ,'end.'],
    16,18,
    ['unit SomeUnit;'
    ,'{$MODE ObjFPC}'
    ,'interface'
    ,'type'
    ,'  TNotifyEvent = procedure(Sender: TObject) of object;'
    ,'  { TBird }'
    ,'  TBird = class'
    ,'  private'
    ,'    procedure EagleClick(Sender: TObject);'
    ,'  public'
    ,'    Eagle: TBird;'
    ,'    OnClick: TNotifyEvent;'
    ,'    procedure Fly;'
    ,'  end;'
    ,'implementation'
    ,''
    ,'procedure TBird.EagleClick(Sender: TObject);'
    ,'begin'
    ,''
    ,'end;'
    ,''
    ,'procedure TBird.Fly;'
    ,'begin;'
    ,'  Eagle.OnClick:=@EagleClick;'
    ,'end;'
    ,'end.']);
end;

procedure TTestCodeCompletion.TestCompleteEventAssignmentObjFPC_AtName;
begin
  Test('TestCompleteEventAssignmentDelphi',
    ['unit SomeUnit;'
    ,'{$MODE ObjFPC}'
    ,'interface'
    ,'type'
    ,'  TNotifyEvent = procedure(Sender: TObject) of object;'
    ,'  TBird = class'
    ,'  private'
    ,'  public'
    ,'    Eagle: TBird;'
    ,'    OnClick: TNotifyEvent;'
    ,'    procedure Fly;'
    ,'  end;'
    ,'implementation'
    ,'procedure TBird.Fly;'
    ,'begin;'
    ,'  Eagle.OnClick:=@OnEagled'
    ,'end;'
    ,'end.'],
    16,18,
    ['unit SomeUnit;'
    ,'{$MODE ObjFPC}'
    ,'interface'
    ,'type'
    ,'  TNotifyEvent = procedure(Sender: TObject) of object;'
    ,'  { TBird }'
    ,'  TBird = class'
    ,'  private'
    ,'    procedure OnEagled(Sender: TObject);'
    ,'  public'
    ,'    Eagle: TBird;'
    ,'    OnClick: TNotifyEvent;'
    ,'    procedure Fly;'
    ,'  end;'
    ,'implementation'
    ,''
    ,'procedure TBird.OnEagled(Sender: TObject);'
    ,'begin'
    ,''
    ,'end;'
    ,''
    ,'procedure TBird.Fly;'
    ,'begin;'
    ,'  Eagle.OnClick:=@OnEagled;'
    ,'end;'
    ,'end.']);
end;

procedure TTestCodeCompletion.TestCompleteClass_Unit_NewClass;
// test creating the first method body of a class
begin
  Test('TestCompleteClass_Unit_NewClass',
    ['unit SomeUnit;'
    ,'{$MODE ObjFPC}'
    ,'interface'
    ,'type'
    ,'  TBird = class'
    ,'    procedure Fly;'
    ,'  end;'
    ,'implementation'
    ,'end.'],
    6,4,
    ['unit SomeUnit;'
    ,'{$MODE ObjFPC}'
    ,'interface'
    ,'type'
    ,''
    ,'  { TBird }'
    ,''
    ,'  TBird = class'
    ,'    procedure Fly;'
    ,'  end;'
    ,'implementation'
    ,''
    ,'procedure TBird.Fly;'
    ,'begin'
    ,'end;'
    ,''
    ,'end.']);
end;

procedure TTestCodeCompletion.TestCompleteClass_Unit_NewClass_BehindOldClass;
// test if a new class is created behind
begin
  Test('TestCompleteClass_Unit_NewClass_BehindOldClass',
    ['unit SomeUnit;'
    ,'{$MODE ObjFPC}'
    ,'interface'
    ,'type'
    ,'  TBird = class'
    ,'    procedure Fly;'
    ,'  end;'
    ,'  TCheetah = class'
    ,'    procedure Run;'
    ,'  end;'
    ,'implementation'
    ,''
    ,'procedure TBird.Fly;'
    ,'begin'
    ,'end;'
    ,''
    ,'end.'],
    9,4,
    ['unit SomeUnit;'
    ,'{$MODE ObjFPC}'
    ,'interface'
    ,'type'
    ,'  TBird = class'
    ,'    procedure Fly;'
    ,'  end;'
    ,'  { TCheetah }'
    ,'  TCheetah = class'
    ,'    procedure Run;'
    ,'  end;'
    ,'implementation'
    ,''
    ,'procedure TBird.Fly;'
    ,'begin'
    ,'end;'
    ,''
    ,'procedure TCheetah.Run;'
    ,'begin'
    ,'end;'
    ,''
    ,'end.']);
end;

procedure TTestCodeCompletion.TestCompleteClass_Unit_NewClass_InFrontOfOldClass;
begin
  Test('TestCompleteClass_Unit_NewClass_BehindOldClass',
    ['unit SomeUnit;'
    ,'{$MODE ObjFPC}'
    ,'interface'
    ,'type'
    ,'  TBird = class'
    ,'    procedure Fly;'
    ,'  end;'
    ,'  TCheetah = class'
    ,'    procedure Run;'
    ,'  end;'
    ,'implementation'
    ,''
    ,'procedure TCheetah.Run;'
    ,'begin'
    ,'end;'
    ,''
    ,'end.'],
    6,4,
    ['unit SomeUnit;'
    ,'{$MODE ObjFPC}'
    ,'interface'
    ,'type'
    ,'  { TBird }'
    ,'  TBird = class'
    ,'    procedure Fly;'
    ,'  end;'
    ,'  TCheetah = class'
    ,'    procedure Run;'
    ,'  end;'
    ,'implementation'
    ,''
    ,'procedure TBird.Fly;'
    ,'begin'
    ,'end;'
    ,''
    ,'procedure TCheetah.Run;'
    ,'begin'
    ,'end;'
    ,''
    ,'end.']);
end;

procedure TTestCodeCompletion.TestCompleteClass_Unit_NewClass_BetweenOldClasses;
begin
  Test('TestCompleteClass_Unit_NewClass_BetweenOldClasses',
    ['unit SomeUnit;'
    ,'{$MODE ObjFPC}'
    ,'interface'
    ,'type'
    ,'  TBird = class'
    ,'    procedure Fly;'
    ,'  end;'
    ,'  TCheetah = class'
    ,'    procedure Run;'
    ,'  end;'
    ,'  TFish = class'
    ,'    procedure Swim;'
    ,'  end;'
    ,'implementation'
    ,''
    ,'procedure TBird.Fly;'
    ,'begin'
    ,'end;'
    ,''
    ,'procedure TFish.Swim;'
    ,'begin'
    ,'end;'
    ,'end.'],
    9,4,
    ['unit SomeUnit;'
    ,'{$MODE ObjFPC}'
    ,'interface'
    ,'type'
    ,'  TBird = class'
    ,'    procedure Fly;'
    ,'  end;'
    ,'  { TCheetah }'
    ,'  TCheetah = class'
    ,'    procedure Run;'
    ,'  end;'
    ,'  TFish = class'
    ,'    procedure Swim;'
    ,'  end;'
    ,'implementation'
    ,''
    ,'procedure TBird.Fly;'
    ,'begin'
    ,'end;'
    ,''
    ,'procedure TCheetah.Run;'
    ,'begin'
    ,'end;'
    ,''
    ,'procedure TFish.Swim;'
    ,'begin'
    ,'end;'
    ,'end.']);
end;

procedure TTestCodeCompletion.
  TestCompleteNestedClass_Unit_NewClass_BehindParentClass;
begin
  Test('TestCompleteNestedClass_Unit_NewClass_BehindParentClass',
    ['unit SomeUnit;'
    ,'{$MODE ObjFPC}'
    ,'interface'
    ,'type'
    ,'  TBird = class'
    ,'  type'
    ,'    TWing = class'
    ,'      procedure Flap;'
    ,'    end;'
    ,'    procedure Fly;'
    ,'  end;'
    ,'  TFish = class'
    ,'    procedure Swim;'
    ,'  end;'
    ,'implementation'
    ,''
    ,'procedure TBird.Fly;'
    ,'begin'
    ,'end;'
    ,''
    ,'procedure TFish.Swim;'
    ,'begin'
    ,'end;'
    ,'end.'],
    8,4,
    ['unit SomeUnit;'
    ,'{$MODE ObjFPC}'
    ,'interface'
    ,'type'
    ,'  TBird = class'
    ,'  type'
    ,'    { TWing }'
    ,'    TWing = class'
    ,'      procedure Flap;'
    ,'    end;'
    ,'    procedure Fly;'
    ,'  end;'
    ,'  TFish = class'
    ,'    procedure Swim;'
    ,'  end;'
    ,'implementation'
    ,''
    ,'procedure TBird.Fly;'
    ,'begin'
    ,'end;'
    ,''
    ,'procedure TBird.TWing.Flap;'
    ,'begin'
    ,'end;'
    ,''
    ,'procedure TFish.Swim;'
    ,'begin'
    ,'end;'
    ,'end.']);
end;


initialization
  RegisterTests([TTestCodeCompletion]);
end.

