unit TestChangeDeclaration;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils,
  LazLogger, LazFileUtils, fpcunit, testregistry, AVL_Tree,
  CodeToolManager, CodeCache, PascalParserTool,
  TestFinddeclaration, TestStdCodetools;

type

  { TTestChangeDeclaration }

  TTestChangeDeclaration = class(TCustomTestCTStdCodetools)
  protected
    FDefFilename: string;
    procedure SetUp; override;
  published
    procedure TestCTAddProcedureModifier;
  end;

implementation

procedure TTestChangeDeclaration.SetUp;
begin
  inherited SetUp;
  FDefFilename:='TestChangeDeclaration.pas';
end;

procedure TTestChangeDeclaration.TestCTAddProcedureModifier;

  procedure Test(ProcCode, aModifier, Expected: string);
  var
    Code: TCodeBuffer;
    Src, ProcHead: String;
  begin
    Src:='unit '+FDefFilename+';'+sLineBreak
      +'interface'+sLineBreak
      +ProcCode+sLineBreak
      +'implementation'+sLineBreak
      +'end.';
    Code:=CodeToolBoss.CreateFile(FDefFilename);
    try
      Code.Source:=Src;
      if not CodeToolBoss.AddProcModifier(Code,3,3,aModifier) then
      begin
        Fail('AddProcModifier failed: '+CodeToolBoss.ErrorMessage);
      end else begin
        if not CodeToolBoss.ExtractProcedureHeader(Code,3,3,
          [phpWithStart,phpWithResultType,phpWithOfObject,phpWithProcModifiers,phpWithComments,phpDoNotAddSemicolon],
          ProcHead)
        then
          Fail('ExtractProcedureHeader failed: '+CodeToolBoss.ErrorMessage);
        if ProcHead<>Expected then begin
          writeln('Test ProcCode="',ProcCode,'"');
          Src:=Code.Source;
          writeln('SrcSTART:======================');
          writeln(Src);
          writeln('SrcEND:========================');
          AssertEquals('ProcHead',Expected,ProcHead);
        end;
      end;
    finally
      Code.IsDeleted:=true;
    end;
  end;

begin
  // remove first unit
  Test('procedure DoIt;','overload','procedure DoIt; overload;');
  Test('procedure DoIt ;','overload','procedure DoIt; overload ;');
  Test('procedure DoIt ; ;','overload','procedure DoIt; overload ;');
  Test('procedure DoIt; overload;','overload','procedure DoIt; overload;');
  Test('procedure DoIt; {$IFDEF FPC}overload{$ENDIF};','overload','procedure DoIt; {$IFDEF FPC}overload{$ENDIF};');
  Test('procedure DoIt; procedure Bla;','overload','procedure DoIt; overload;');
  Test('  procedure DoIt;'+sLineBreak+'  procedure Bla;',
    'overload','procedure DoIt; overload;');
  Test('  procedure DoIt; external name ''doit'';'+sLineBreak+'  procedure Bla;',
    'overload','procedure DoIt; external name ''doit''; overload;');
end;

initialization
  RegisterTests([TTestChangeDeclaration]);
end.

