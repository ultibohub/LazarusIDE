{+--------------------------------------------------------------------------+
 | Class:       TmwPasLex
 | Created:     07.98 - 10.98
 | Author:      Martin Waldenburg
 | Description: A very fast Pascal tokenizer.
 | Version:     1.32
 | Copyright (c) 1998, 1999 Martin Waldenburg
 | All rights reserved.
 |
 | LICENCE CONDITIONS
 |
 | USE OF THE ENCLOSED SOFTWARE
 | INDICATES YOUR ASSENT TO THE
 | FOLLOWING LICENCE CONDITIONS.
 |
 |
 |
 | These Licence Conditions are exlusively
 | governed by the Law and Rules of the
 | Federal Republic of Germany.
 |
 | Redistribution and use in source and binary form, with or without
 | modification, are permitted provided that the following conditions
 | are met:
 |
 | 1. Redistributions of source code must retain the above copyright
 |    notice, this list of conditions and the following disclaimer.
 |    If the source is modified, the complete original and unmodified
 |    source code has to distributed with the modified version.
 |
 | 2. Redistributions in binary form must reproduce the above
 |    copyright notice, these licence conditions and the disclaimer
 |    found at the end of this licence agreement in the documentation
 |    and/or other materials provided with the distribution.
 |
 | 3. Software using this code must contain a visible line of credit.
 |
 | 4. If my code is used in a "for profit" product, you have to donate
 |    to a registered charity in an amount that you feel is fair.
 |    You may use it in as many of your products as you like.
 |    Proof of this donation must be provided to the author of
 |    this software.
 |
 | 5. If you for some reasons don't want to give public credit to the
 |    author, you have to donate three times the price of your software
 |    product, or any other product including this component in any way,
 |    but no more than $500 US and not less than $200 US, or the
 |    equivalent thereof in other currency, to a registered charity.
 |    You have to do this for every of your products, which uses this
 |    code separately.
 |    Proof of this donations must be provided to the author of
 |    this software.
 |
 |
 | DISCLAIMER:
 |
 | THIS SOFTWARE IS PROVIDED BY THE AUTHOR 'AS IS'.
 |
 | ALL EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO,
 | THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A
 | PARTICULAR PURPOSE ARE DISCLAIMED.
 |
 | IN NO EVENT SHALL THE AUTHOR BE LIABLE FOR ANY DIRECT, INDIRECT,
 | INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
 | (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS
 | OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
 | INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY,
 | WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING
 | NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF
 | THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 |
 |  Martin.Waldenburg@T-Online.de
 +--------------------------------------------------------------------------+}

{25/03/2003 Olivier GUILBAUD <golivier@free.fr> update for lazarus project}

unit mPasLex;
{$mode objfpc}{$H+}{$M+}
interface

uses
  SysUtils;

var
  Identifiers: array[#0..#255]of ByteBool;
  mHashTable: array[#0..#255]of Integer;

type
  TTokenKind=(tkAbsolute, tkAbstract, tkAddressOp, tkAnd, tkAnsiComment,
    tkArray, tkAs, tkAt, tkAsciiChar, tkAsm, tkAssembler, tkAssign, tkAutomated,
    tkBegin, tkBadString, tkBorComment, tkCase, tkCdecl, tkClass, tkColon,
    tkComma, tkCompDirect, tkConst, tkConstructor, tkCRLF, tkCRLFCo, tkDefault,
    tkDestructor, tkDispid, tkDispinterface, tkDiv, tkDo, tkDoubleAddressOp,
    tkDotDot, tkDownto, tkDynamic, tkElse, tkEnd, tkEqual, tkError, tkExcept,
    tkExport, tkExports, tkExternal, tkFar, tkFile, tkFinalization, tkFinally,
    tkFloat, tkFor, tkForward, tkFunction, tkGoto, tkGreater, tkGreaterEqual,
    tkIdentifier, tkIf, tkImplementation, tkImplements, tkIn, tkIndex,
    tkInherited, tkInitialization, tkInline, tkInteger, tkInterface, tkIs,
    tkKeyString, tkLabel, tkLibrary, tkLower, tkLowerEqual, tkMessage, tkMinus,
    tkMod, tkName, tkNear, tkNil, tkNodefault, tkNone, tkNot, tkNotEqual, tkNull,
    tkNumber, tkObject, tkOf, tkOn, tkOr, tkOut, tkOverload, tkOverride,
    tkPacked, tkPascal, tkPlus, tkPoint, tkPointerSymbol, tkPrivate, tkProcedure,
    tkProgram, tkProperty, tkProtected, tkPublic, tkPublished, tkRaise, tkRead,
    tkReadonly, tkRecord, tkRegister, tkReintroduce, tkRepeat, tkResident,
    tkResourcestring, tkRoundClose, tkRoundOpen, tkSafecall, tkSemiColon, tkSet,
    tkShl, tkShr, tkSlash, tkSlashesComment, tkSquareClose, tkSquareOpen,
    tkSpace, tkStar, tkStdcall, tkStored, tkString, tkStringresource, tkSymbol,
    tkThen, tkThreadvar, tkTo, tkTry, tkType, tkUnit, tkUnknown, tkUntil, tkUses,
    tkVar, tkVectorcall, tkVirtual, tkWhile, tkWith, tkWrite, tkWriteonly, tkXor,
    tkMsAbiDefault,tkMsAbiCdecl,tkSysvAbiDefault,tkSysvAbiCdecl);

  TCommentState=(csAnsi, csBor, csNo);

  TmwPasLex=class(TObject)
  private
    fComment: TCommentState;
    fOrigin: PChar;
    fProcTable: array[#0..#255]of procedure of Object;
    Run: Longint;
    Temp: PChar;
    FRoundCount: Integer;
    FSquareCount: Integer;
    fStringLen: Integer;
    fToIdent: PChar;
    fIdentFuncTable: array[0..191]of function: TTokenKind of Object;
    fTokenPos: Integer;
    fLineNumber: Integer;
    FTokenID: TTokenKind;
    fLastIdentPos: Integer;
    fLastNoSpace: TTokenKind;
    fLastNoSpacePos: Integer;
    fLinePos: Integer;
    fIsInterface: Boolean;
    fIsClass: Boolean;
    function KeyHash(ToHash: PChar): Integer;
    function KeyComp(const aKey: string): Boolean;
    function Func15: TTokenKind;
    function Func19: TTokenKind;
    function Func20: TTokenKind;
    function Func21: TTokenKind;
    function Func23: TTokenKind;
    function Func25: TTokenKind;
    function Func27: TTokenKind;
    function Func28: TTokenKind;
    function Func29: TTokenKind;
    function Func32: TTokenKind;
    function Func33: TTokenKind;
    function Func35: TTokenKind;
    function Func37: TTokenKind;
    function Func38: TTokenKind;
    function Func39: TTokenKind;
    function Func40: TTokenKind;
    function Func41: TTokenKind;
    function Func44: TTokenKind;
    function Func45: TTokenKind;
    function Func47: TTokenKind;
    function Func49: TTokenKind;
    function Func52: TTokenKind;
    function Func54: TTokenKind;
    function Func55: TTokenKind;
    function Func56: TTokenKind;
    function Func57: TTokenKind;
    function Func59: TTokenKind;
    function Func60: TTokenKind;
    function Func61: TTokenKind;
    function Func63: TTokenKind;
    function Func64: TTokenKind;
    function Func65: TTokenKind;
    function Func66: TTokenKind;
    function Func69: TTokenKind;
    function Func71: TTokenKind;
    function Func73: TTokenKind;
    function Func75: TTokenKind;
    function Func76: TTokenKind;
    function Func79: TTokenKind;
    function Func81: TTokenKind;
    function Func84: TTokenKind;
    function Func85: TTokenKind;
    function Func87: TTokenKind;
    function Func88: TTokenKind;
    function Func91: TTokenKind;
    function Func92: TTokenKind;
    function Func94: TTokenKind;
    function Func95: TTokenKind;
    function Func96: TTokenKind;
    function Func97: TTokenKind;
    function Func98: TTokenKind;
    function Func99: TTokenKind;
    function Func100: TTokenKind;
    function Func101: TTokenKind;
    function Func102: TTokenKind;
    function Func103: TTokenKind;
    function Func105: TTokenKind;
    function Func106: TTokenKind;
    function Func111: TTokenKind;
    function Func117: TTokenKind;
    function Func126: TTokenKind;
    function Func129: TTokenKind;
    function Func132: TTokenKind;
    function Func133: TTokenKind;
    function Func136: TTokenKind;
    function Func141: TTokenKind;
    function Func143: TTokenKind;
    function Func166: TTokenKind;
    function Func168: TTokenKind;
    function Func191: TTokenKind;
    function AltFunc: TTokenKind;
    procedure InitIdent;
    function IdentKind(MayBe: PChar): TTokenKind;
    procedure SetOrigin(NewValue: PChar);
    procedure SetRunPos(Value: Integer);
    procedure MakeMethodTables;
    procedure AddressOpProc;
    procedure AsciiCharProc;
    procedure AnsiProc;
    procedure BorProc;
    procedure BraceCloseProc;
    procedure BraceOpenProc;
    procedure ColonProc;
    procedure CommaProc;
    procedure CRProc;
    procedure EqualProc;
    procedure GreaterProc;
    procedure IdentProc;
    procedure IntegerProc;
    procedure LFProc;
    procedure LowerProc;
    procedure MinusProc;
    procedure NullProc;
    procedure NumberProc;
    procedure PlusProc;
    procedure PointerSymbolProc;
    procedure PointProc;
    procedure RoundCloseProc;
    procedure RoundOpenProc;
    procedure SemiColonProc;
    procedure SlashProc;
    procedure SpaceProc;
    procedure SquareCloseProc;
    procedure SquareOpenProc;
    procedure StarProc;
    procedure StringProc;
    procedure SymbolProc;
    procedure UnknownProc;
    function GetToken: string;
    function InSymbols(aChar: Char): Boolean;
  protected
  public
    constructor Create;
    destructor Destroy; override;
    function CharAhead(Count: Integer): Char;
    procedure Next;
    procedure NextID(ID: TTokenKind);
    procedure NextNoJunk;
    procedure NextClass;
    property IsClass: Boolean read fIsClass;
    property IsInterface: Boolean read fIsInterface;
    property LastIdentPos: Integer read fLastIdentPos;
    property LastNoSpace: TTokenKind read fLastNoSpace;
    property LastNoSpacePos: Integer read fLastNoSpacePos;
    property LineNumber: Integer read fLineNumber;
    property LinePos: Integer read fLinePos;
    property Origin: PChar read fOrigin write SetOrigin;
    property RunPos: Integer read Run write SetRunPos;
    property TokenPos: Integer read fTokenPos;
    property Token: string read GetToken;
    property TokenID: TTokenKind read FTokenID;
  published
  end;

var
  mwPasLex: TmwPasLex;

implementation

procedure MakeIdentTable;
var
  I, J: Char;
begin
  for I:=#0 to #255 do
  begin
    Case I of
      '_', '0'..'9', 'a'..'z', 'A'..'Z': Identifiers[I]:=True;
    else Identifiers[I]:=False;
    end;
    J:=UpCase(I);
    Case I of
      'a'..'z', 'A'..'Z', '_': mHashTable[I]:=Ord(J)-64;
    else mHashTable[Char(I)]:=0;
    end;
  end;
end;

procedure TmwPasLex.InitIdent;
var
  I: Integer;
begin
  for I:=0 to High(fIdentFuncTable) do
    Case I of
      15: fIdentFuncTable[I]:={$IFDEF FPC}@{$ENDIF}Func15;
      19: fIdentFuncTable[I]:={$IFDEF FPC}@{$ENDIF}Func19;
      20: fIdentFuncTable[I]:={$IFDEF FPC}@{$ENDIF}Func20;
      21: fIdentFuncTable[I]:={$IFDEF FPC}@{$ENDIF}Func21;
      23: fIdentFuncTable[I]:={$IFDEF FPC}@{$ENDIF}Func23;
      25: fIdentFuncTable[I]:={$IFDEF FPC}@{$ENDIF}Func25;
      27: fIdentFuncTable[I]:={$IFDEF FPC}@{$ENDIF}Func27;
      28: fIdentFuncTable[I]:={$IFDEF FPC}@{$ENDIF}Func28;
      29: fIdentFuncTable[I]:={$IFDEF FPC}@{$ENDIF}Func29;
      32: fIdentFuncTable[I]:={$IFDEF FPC}@{$ENDIF}Func32;
      33: fIdentFuncTable[I]:={$IFDEF FPC}@{$ENDIF}Func33;
      35: fIdentFuncTable[I]:={$IFDEF FPC}@{$ENDIF}Func35;
      37: fIdentFuncTable[I]:={$IFDEF FPC}@{$ENDIF}Func37;
      38: fIdentFuncTable[I]:={$IFDEF FPC}@{$ENDIF}Func38;
      39: fIdentFuncTable[I]:={$IFDEF FPC}@{$ENDIF}Func39;
      40: fIdentFuncTable[I]:={$IFDEF FPC}@{$ENDIF}Func40;
      41: fIdentFuncTable[I]:={$IFDEF FPC}@{$ENDIF}Func41;
      44: fIdentFuncTable[I]:={$IFDEF FPC}@{$ENDIF}Func44;
      45: fIdentFuncTable[I]:={$IFDEF FPC}@{$ENDIF}Func45;
      47: fIdentFuncTable[I]:={$IFDEF FPC}@{$ENDIF}Func47;
      49: fIdentFuncTable[I]:={$IFDEF FPC}@{$ENDIF}Func49;
      52: fIdentFuncTable[I]:={$IFDEF FPC}@{$ENDIF}Func52;
      54: fIdentFuncTable[I]:={$IFDEF FPC}@{$ENDIF}Func54;
      55: fIdentFuncTable[I]:={$IFDEF FPC}@{$ENDIF}Func55;
      56: fIdentFuncTable[I]:={$IFDEF FPC}@{$ENDIF}Func56;
      57: fIdentFuncTable[I]:={$IFDEF FPC}@{$ENDIF}Func57;
      59: fIdentFuncTable[I]:={$IFDEF FPC}@{$ENDIF}Func59;
      60: fIdentFuncTable[I]:={$IFDEF FPC}@{$ENDIF}Func60;
      61: fIdentFuncTable[I]:={$IFDEF FPC}@{$ENDIF}Func61;
      63: fIdentFuncTable[I]:={$IFDEF FPC}@{$ENDIF}Func63;
      64: fIdentFuncTable[I]:={$IFDEF FPC}@{$ENDIF}Func64;
      65: fIdentFuncTable[I]:={$IFDEF FPC}@{$ENDIF}Func65;
      66: fIdentFuncTable[I]:={$IFDEF FPC}@{$ENDIF}Func66;
      69: fIdentFuncTable[I]:={$IFDEF FPC}@{$ENDIF}Func69;
      71: fIdentFuncTable[I]:={$IFDEF FPC}@{$ENDIF}Func71;
      73: fIdentFuncTable[I]:={$IFDEF FPC}@{$ENDIF}Func73;
      75: fIdentFuncTable[I]:={$IFDEF FPC}@{$ENDIF}Func75;
      76: fIdentFuncTable[I]:={$IFDEF FPC}@{$ENDIF}Func76;
      79: fIdentFuncTable[I]:={$IFDEF FPC}@{$ENDIF}Func79;
      81: fIdentFuncTable[I]:={$IFDEF FPC}@{$ENDIF}Func81;
      84: fIdentFuncTable[I]:={$IFDEF FPC}@{$ENDIF}Func84;
      85: fIdentFuncTable[I]:={$IFDEF FPC}@{$ENDIF}Func85;
      87: fIdentFuncTable[I]:={$IFDEF FPC}@{$ENDIF}Func87;
      88: fIdentFuncTable[I]:={$IFDEF FPC}@{$ENDIF}Func88;
      91: fIdentFuncTable[I]:={$IFDEF FPC}@{$ENDIF}Func91;
      92: fIdentFuncTable[I]:={$IFDEF FPC}@{$ENDIF}Func92;
      94: fIdentFuncTable[I]:={$IFDEF FPC}@{$ENDIF}Func94;
      95: fIdentFuncTable[I]:={$IFDEF FPC}@{$ENDIF}Func95;
      96: fIdentFuncTable[I]:={$IFDEF FPC}@{$ENDIF}Func96;
      97: fIdentFuncTable[I]:={$IFDEF FPC}@{$ENDIF}Func97;
      98: fIdentFuncTable[I]:={$IFDEF FPC}@{$ENDIF}Func98;
      99: fIdentFuncTable[I]:={$IFDEF FPC}@{$ENDIF}Func99;
      100: fIdentFuncTable[I]:={$IFDEF FPC}@{$ENDIF}Func100;
      101: fIdentFuncTable[I]:={$IFDEF FPC}@{$ENDIF}Func101;
      102: fIdentFuncTable[I]:={$IFDEF FPC}@{$ENDIF}Func102;
      103: fIdentFuncTable[I]:={$IFDEF FPC}@{$ENDIF}Func103;
      105: fIdentFuncTable[I]:={$IFDEF FPC}@{$ENDIF}Func105;
      106: fIdentFuncTable[I]:={$IFDEF FPC}@{$ENDIF}Func106;
      111: fIdentFuncTable[I]:={$IFDEF FPC}@{$ENDIF}Func111;
      117: fIdentFuncTable[I]:={$IFDEF FPC}@{$ENDIF}Func117;
      126: fIdentFuncTable[I]:={$IFDEF FPC}@{$ENDIF}Func126;
      129: fIdentFuncTable[I]:={$IFDEF FPC}@{$ENDIF}Func129;
      132: fIdentFuncTable[I]:={$IFDEF FPC}@{$ENDIF}Func132;
      133: fIdentFuncTable[I]:={$IFDEF FPC}@{$ENDIF}Func133;
      136: fIdentFuncTable[I]:={$IFDEF FPC}@{$ENDIF}Func136;
      141: fIdentFuncTable[I]:={$IFDEF FPC}@{$ENDIF}Func141;
      143: fIdentFuncTable[I]:={$IFDEF FPC}@{$ENDIF}Func143;
      166: fIdentFuncTable[I]:={$IFDEF FPC}@{$ENDIF}Func166;
      168: fIdentFuncTable[I]:={$IFDEF FPC}@{$ENDIF}Func168;
      191: fIdentFuncTable[I]:={$IFDEF FPC}@{$ENDIF}Func191;
    else fIdentFuncTable[I]:={$IFDEF FPC}@{$ENDIF}AltFunc;
    end;
end;

function TmwPasLex.KeyHash(ToHash: PChar): Integer;
begin
  Result:=0;
  while ToHash^in ['a'..'z', 'A'..'Z']do
  begin
    Inc(Result, mHashTable[ToHash^]);
    Inc(ToHash);
  end;
  if ToHash^in ['_', '0'..'9']then Inc(ToHash);
  fStringLen:=ToHash-fToIdent;
end; { KeyHash }

function TmwPasLex.KeyComp(const aKey: string): Boolean;
var
  I: Integer;
begin
  Temp:=fToIdent;
  if Length(aKey)=fStringLen then
  begin
    Result:=True;
    for i:=1 to fStringLen do
    begin
      if mHashTable[Temp^]<>mHashTable[aKey[i]]then
      begin
        Result:=False;
        Break;
      end;
      Inc(Temp);
    end;
  end else Result:=False;
end; { KeyComp }

function TmwPasLex.Func15: TTokenKind;
begin
  if KeyComp('If')then Result:=tkIf else Result:=tkIdentifier;
end;

function TmwPasLex.Func19: TTokenKind;
begin
  if KeyComp('Do')then Result:=tkDo else
    if KeyComp('And')then Result:=tkAnd else Result:=tkIdentifier;
end;

function TmwPasLex.Func20: TTokenKind;
begin
  if KeyComp('As')then Result:=tkAs else Result:=tkIdentifier;
end;

function TmwPasLex.Func21: TTokenKind;
begin
  if KeyComp('Of')then Result:=tkOf else
    if KeyComp('At')then Result:=tkAt else Result:=tkIdentifier;
end;

function TmwPasLex.Func23: TTokenKind;
begin
  if KeyComp('End')then Result:=tkEnd else
    if KeyComp('In')then Result:=tkIn else Result:=tkIdentifier;
end;

function TmwPasLex.Func25: TTokenKind;
begin
  if KeyComp('Far')then Result:=tkFar else Result:=tkIdentifier;
end;

function TmwPasLex.Func27: TTokenKind;
begin
  if KeyComp('Cdecl')then Result:=tkCdecl else Result:=tkIdentifier;
end;

function TmwPasLex.Func28: TTokenKind;
begin
  if KeyComp('Read')then
  begin
    if inSymbols(CharAhead(fStringLen))then Result:=tkIdentifier else
      Result:=tkRead
  end else
    if KeyComp('Case')then Result:=tkCase else
      if KeyComp('Is')then Result:=tkIs else Result:=tkIdentifier;
end;

function TmwPasLex.Func29: TTokenKind;
begin
  if KeyComp('On')then Result:=tkOn else Result:=tkIdentifier;
end;

function TmwPasLex.Func32: TTokenKind;
begin
  if KeyComp('File')then Result:=tkFile else
    if KeyComp('Label')then Result:=tkLabel else
      if KeyComp('Mod')then Result:=tkMod else
       if KeyComp('Ms_abi_default')then Result:=tkMsAbiDefault else
        if KeyComp('Ms_abi_cdecl')then Result:=tkMsAbiCdecl else Result:=tkIdentifier;
end;

function TmwPasLex.Func33: TTokenKind;
begin
  if KeyComp('Or')then Result:=tkOr else
    if KeyComp('Name')then
    begin
      if inSymbols(CharAhead(fStringLen))then Result:=tkIdentifier else
        Result:=tkName
    end else
      if KeyComp('Asm')then Result:=tkAsm else Result:=tkIdentifier;
end;

function TmwPasLex.Func35: TTokenKind;
begin
  if KeyComp('To')then Result:=tkTo else
    if KeyComp('Nil')then Result:=tkNil else
      if KeyComp('Div')then Result:=tkDiv else Result:=tkIdentifier;
end;

function TmwPasLex.Func37: TTokenKind;
begin
  if KeyComp('Begin')then Result:=tkBegin else Result:=tkIdentifier;
end;

function TmwPasLex.Func38: TTokenKind;
begin
  if KeyComp('Near')then Result:=tkNear else Result:=tkIdentifier;
end;

function TmwPasLex.Func39: TTokenKind;
begin
  if KeyComp('For')then Result:=tkFor else
    if KeyComp('Shl')then Result:=tkShl else Result:=tkIdentifier;
end;

function TmwPasLex.Func40: TTokenKind;
begin
  if KeyComp('Packed')then Result:=tkPacked else Result:=tkIdentifier;
end;

function TmwPasLex.Func41: TTokenKind;
begin
  if KeyComp('Else')then Result:=tkElse else
    if KeyComp('Var')then Result:=tkVar else Result:=tkIdentifier;
end;

function TmwPasLex.Func44: TTokenKind;
begin
  if KeyComp('Set')then Result:=tkSet else Result:=tkIdentifier;
end;

function TmwPasLex.Func45: TTokenKind;
begin
  if KeyComp('Shr')then Result:=tkShr else Result:=tkIdentifier;
end;

function TmwPasLex.Func47: TTokenKind;
begin
  if KeyComp('Then')then Result:=tkThen else Result:=tkIdentifier;
end;

function TmwPasLex.Func49: TTokenKind;
begin
  if KeyComp('Not')then Result:=tkNot else Result:=tkIdentifier;
end;

function TmwPasLex.Func52: TTokenKind;
begin
  if KeyComp('Raise')then Result:=tkRaise else
    if KeyComp('Pascal')then Result:=tkPascal else Result:=tkIdentifier;
end;

function TmwPasLex.Func54: TTokenKind;
begin
  if KeyComp('Class')then
  begin
    Result:=tkClass;
    if fLastNoSpace=tkEqual then
    begin
      fIsClass:=True;
      if Identifiers[CharAhead(fStringLen)]then fIsClass:=False;
    end else fIsClass:=False;
  end else Result:=tkIdentifier;
end;

function TmwPasLex.Func55: TTokenKind;
begin
  if KeyComp('Object')then Result:=tkObject else Result:=tkIdentifier;
end;

function TmwPasLex.Func56: TTokenKind;
begin
  if KeyComp('Index')then
  begin
    if inSymbols(CharAhead(fStringLen))then Result:=tkIdentifier else
      Result:=tkIndex
  end else
    if KeyComp('Out')then Result:=tkOut else Result:=tkIdentifier;
end;

function TmwPasLex.Func57: TTokenKind;
begin
  if KeyComp('While')then Result:=tkWhile else
    if KeyComp('Goto')then Result:=tkGoto else
      if KeyComp('Xor')then Result:=tkXor else Result:=tkIdentifier;
end;

function TmwPasLex.Func59: TTokenKind;
begin
  if KeyComp('Safecall')then Result:=tkSafecall else Result:=tkIdentifier;
end;

function TmwPasLex.Func60: TTokenKind;
begin
  if KeyComp('With')then Result:=tkWith else Result:=tkIdentifier;
end;

function TmwPasLex.Func61: TTokenKind;
begin
  if KeyComp('Dispid')then Result:=tkDispid else Result:=tkIdentifier;
end;

function TmwPasLex.Func63: TTokenKind;
begin
  if KeyComp('Public')then
  begin
    if inSymbols(CharAhead(fStringLen))then Result:=tkIdentifier else
      Result:=tkPublic
  end else
    if KeyComp('Record')then Result:=tkRecord else
      if KeyComp('Try')then Result:=tkTry else
        if KeyComp('Array')then Result:=tkArray else
          if KeyComp('Inline')then Result:=tkInline else Result:=tkIdentifier;
end;

function TmwPasLex.Func64: TTokenKind;
begin
  if KeyComp('Uses')then Result:=tkUses else
    if KeyComp('Unit')then Result:=tkUnit else Result:=tkIdentifier;
end;

function TmwPasLex.Func65: TTokenKind;
begin
  if KeyComp('Repeat')then Result:=tkRepeat else Result:=tkIdentifier;
end;

function TmwPasLex.Func66: TTokenKind;
begin
  if KeyComp('Type')then Result:=tkType else Result:=tkIdentifier;
end;

function TmwPasLex.Func69: TTokenKind;
begin
  if KeyComp('Dynamic')then Result:=tkDynamic else
    if KeyComp('Default')then Result:=tkDefault else
      if KeyComp('Message')then Result:=tkMessage else Result:=tkIdentifier;
end;

function TmwPasLex.Func71: TTokenKind;
begin
  if KeyComp('Stdcall')then Result:=tkStdcall else
    if KeyComp('Const')then Result:=tkConst else Result:=tkIdentifier;
end;

function TmwPasLex.Func73: TTokenKind;
begin
  if KeyComp('Except')then Result:=tkExcept else Result:=tkIdentifier;
end;

function TmwPasLex.Func75: TTokenKind;
begin
  if KeyComp('Write')then
  begin
    if inSymbols(CharAhead(fStringLen))then Result:=tkIdentifier else
      Result:=tkWrite
  end else Result:=tkIdentifier;
end;

function TmwPasLex.Func76: TTokenKind;
begin
  if KeyComp('Until')then Result:=tkUntil else Result:=tkIdentifier;
end;

function TmwPasLex.Func79: TTokenKind;
begin
  if KeyComp('Finally')then Result:=tkFinally else Result:=tkIdentifier;
end;

function TmwPasLex.Func81: TTokenKind;
begin
  if KeyComp('Interface')then
  begin
    Result:=tkInterface;
    if fLastNoSpace=tkEqual then
      fIsInterface:=True else fIsInterface:=False;
  end else
    if KeyComp('Stored')then Result:=tkStored else Result:=tkIdentifier;
end;

function TmwPasLex.Func84: TTokenKind;
begin
  if KeyComp('Abstract')then Result:=tkAbstract else Result:=tkIdentifier;
end;

function TmwPasLex.Func85: TTokenKind;
begin
  if KeyComp('Library')then Result:=tkLibrary else
    if KeyComp('Forward')then Result:=tkForward else
     if KeyComp('Sysv_abi_default')then Result:=tkSysvAbiDefault else
      if KeyComp('Sysv_abi_cdecl')then Result:=tkSysvAbiCdecl else Result:=tkIdentifier;
end;

function TmwPasLex.Func87: TTokenKind;
begin
  if KeyComp('String')then Result:=tkString else Result:=tkIdentifier;
end;

function TmwPasLex.Func88: TTokenKind;
begin
  if KeyComp('Program')then Result:=tkProgram else Result:=tkIdentifier;
end;

function TmwPasLex.Func91: TTokenKind;
begin
  if KeyComp('Private')then
  begin
    if inSymbols(CharAhead(fStringLen))then Result:=tkIdentifier else
      Result:=tkPrivate
  end else
    if KeyComp('Downto')then Result:=tkDownto else Result:=tkIdentifier;
end;

function TmwPasLex.Func92: TTokenKind;
begin
  if KeyComp('overload') then
    Result:=tkOverload
  else
    if KeyComp('Inherited') then
      Result:=tkInherited
    else
      Result:=tkIdentifier;
end;

function TmwPasLex.Func94: TTokenKind;
begin
  if KeyComp('Resident')then Result:=tkResident else
    if KeyComp('Readonly')then Result:=tkReadonly else
      if KeyComp('Assembler')then Result:=tkAssembler else Result:=tkIdentifier;
end;

function TmwPasLex.Func95: TTokenKind;
begin
  if KeyComp('Absolute')then Result:=tkAbsolute else Result:=tkIdentifier;
end;

function TmwPasLex.Func96: TTokenKind;
begin
  if KeyComp('Published')then
  begin
    if inSymbols(CharAhead(fStringLen))then Result:=tkIdentifier else
      Result:=tkPublished
  end else
    if KeyComp('Override')then Result:=tkOverride else Result:=tkIdentifier;
end;

function TmwPasLex.Func97: TTokenKind;
begin
  if KeyComp('Threadvar')then Result:=tkThreadvar else Result:=tkIdentifier;
end;

function TmwPasLex.Func98: TTokenKind;
begin
  if KeyComp('Export')then Result:=tkExport else
    if KeyComp('Nodefault')then Result:=tkNodefault else Result:=tkIdentifier;
end;

function TmwPasLex.Func99: TTokenKind;
begin
  if KeyComp('External')then Result:=tkExternal else Result:=tkIdentifier;
end;

function TmwPasLex.Func100: TTokenKind;
begin
  if KeyComp('Automated')then
  begin
    if inSymbols(CharAhead(fStringLen))then Result:=tkIdentifier else
      Result:=tkAutomated
  end else Result:=tkIdentifier;
end;

function TmwPasLex.Func101: TTokenKind;
begin
  if KeyComp('Register')then Result:=tkRegister else Result:=tkIdentifier;
end;

function TmwPasLex.Func102: TTokenKind;
begin
  if KeyComp('Function')then Result:=tkFunction else Result:=tkIdentifier;
end;

function TmwPasLex.Func103: TTokenKind;
begin
  if KeyComp('Virtual')then Result:=tkVirtual else Result:=tkIdentifier;
end;

function TmwPasLex.Func105: TTokenKind;
begin
  if KeyComp('Procedure')then Result:=tkProcedure else Result:=tkIdentifier;
end;

function TmwPasLex.Func106: TTokenKind;
begin
  if KeyComp('Protected')then
  begin
    if inSymbols(CharAhead(fStringLen))then Result:=tkIdentifier else
      Result:=tkProtected
  end else Result:=tkIdentifier;
end;

function TmwPasLex.Func111: TTokenKind;
begin
  if KeyComp('Vectorcall') then Result:=tkVectorcall else Result:=tkIdentifier;
end;

function TmwPasLex.Func117: TTokenKind;
begin
  if KeyComp('Exports')then Result:=tkExports else Result:=tkIdentifier;
end;

function TmwPasLex.Func126: TTokenKind;
begin
  if KeyComp('Implements') then
    Result:=tkImplements
  else
  Result:=tkIdentifier;
end;

function TmwPasLex.Func129: TTokenKind;
begin
  if KeyComp('Dispinterface')then Result:=tkDispinterface else Result:=tkIdentifier;
end;

function TmwPasLex.Func132: TTokenKind;
begin
  if KeyComp('Reintroduce') then
    Result:=tkReintroduce
  else
  Result:=tkIdentifier;
end;

function TmwPasLex.Func133: TTokenKind;
begin
  if KeyComp('Property')then Result:=tkProperty else Result:=tkIdentifier;
end;

function TmwPasLex.Func136: TTokenKind;
begin
  if KeyComp('Finalization')then Result:=tkFinalization else Result:=tkIdentifier;
end;

function TmwPasLex.Func141: TTokenKind;
begin
  if KeyComp('Writeonly')then Result:=tkWriteonly else Result:=tkIdentifier;
end;

function TmwPasLex.Func143: TTokenKind;
begin
  if KeyComp('Destructor')then Result:=tkDestructor else Result:=tkIdentifier;
end;

function TmwPasLex.Func166: TTokenKind;
begin
  if KeyComp('Constructor')then Result:=tkConstructor else
    if KeyComp('Implementation')then Result:=tkImplementation else Result:=tkIdentifier;
end;

function TmwPasLex.Func168: TTokenKind;
begin
  if KeyComp('Initialization')then Result:=tkInitialization else Result:=tkIdentifier;
end;

function TmwPasLex.Func191: TTokenKind;
begin
  if KeyComp('Resourcestring')then Result:=tkResourcestring else
    if KeyComp('Stringresource')then Result:=tkStringresource else Result:=tkIdentifier;
end;

function TmwPasLex.AltFunc: TTokenKind;
begin
  Result:=tkIdentifier
end;

function TmwPasLex.IdentKind(MayBe: PChar): TTokenKind;
var
  HashKey: Integer;
begin
  fToIdent:=MayBe;
  HashKey:=KeyHash(MayBe);
  if HashKey<=High(fIdentFuncTable) then
    Result:=fIdentFuncTable[HashKey]()
  else
     Result:=tkIdentifier;
end;

procedure TmwPasLex.MakeMethodTables;
var
  I: Char;
begin
  for I:=#0 to #255 do
    case I of
      #0:  fProcTable[I]:={$IFDEF FPC}@{$ENDIF}NullProc;
      #10: fProcTable[I]:={$IFDEF FPC}@{$ENDIF}LFProc;
      #13: fProcTable[I]:={$IFDEF FPC}@{$ENDIF}CRProc;
      #1..#9, #11, #12, #14..#32:
        fProcTable[I]:={$IFDEF FPC}@{$ENDIF}SpaceProc;
      '#': fProcTable[I]:={$IFDEF FPC}@{$ENDIF}AsciiCharProc;
      '$': fProcTable[I]:={$IFDEF FPC}@{$ENDIF}IntegerProc;
      #39: fProcTable[I]:={$IFDEF FPC}@{$ENDIF}StringProc;
      '0'..'9': fProcTable[I]:={$IFDEF FPC}@{$ENDIF}NumberProc;
      'A'..'Z', 'a'..'z', '_':
        fProcTable[I]:={$IFDEF FPC}@{$ENDIF}IdentProc;
      '{': fProcTable[I]:={$IFDEF FPC}@{$ENDIF}BraceOpenProc;
      '}': fProcTable[I]:={$IFDEF FPC}@{$ENDIF}BraceCloseProc;
      '!', '"', '%', '&', '('..'/', ':'..'@', '['..'^', '`', '~':
        begin
          case I of
            '(': fProcTable[I]:={$IFDEF FPC}@{$ENDIF}RoundOpenProc;
            ')': fProcTable[I]:={$IFDEF FPC}@{$ENDIF}RoundCloseProc;
            '*': fProcTable[I]:={$IFDEF FPC}@{$ENDIF}StarProc;
            '+': fProcTable[I]:={$IFDEF FPC}@{$ENDIF}PlusProc;
            ',': fProcTable[I]:={$IFDEF FPC}@{$ENDIF}CommaProc;
            '-': fProcTable[I]:={$IFDEF FPC}@{$ENDIF}MinusProc;
            '.': fProcTable[I]:={$IFDEF FPC}@{$ENDIF}PointProc;
            '/': fProcTable[I]:={$IFDEF FPC}@{$ENDIF}SlashProc;
            ':': fProcTable[I]:={$IFDEF FPC}@{$ENDIF}ColonProc;
            ';': fProcTable[I]:={$IFDEF FPC}@{$ENDIF}SemiColonProc;
            '<': fProcTable[I]:={$IFDEF FPC}@{$ENDIF}LowerProc;
            '=': fProcTable[I]:={$IFDEF FPC}@{$ENDIF}EqualProc;
            '>': fProcTable[I]:={$IFDEF FPC}@{$ENDIF}GreaterProc;
            '@': fProcTable[I]:={$IFDEF FPC}@{$ENDIF}AddressOpProc;
            '[': fProcTable[I]:={$IFDEF FPC}@{$ENDIF}SquareOpenProc;
            ']': fProcTable[I]:={$IFDEF FPC}@{$ENDIF}SquareCloseProc;
            '^': fProcTable[I]:={$IFDEF FPC}@{$ENDIF}PointerSymbolProc;
          else fProcTable[I]:={$IFDEF FPC}@{$ENDIF}SymbolProc;
          end;
        end;
    else fProcTable[I]:={$IFDEF FPC}@{$ENDIF}UnknownProc;
    end;
end;

constructor TmwPasLex.Create;
begin
  inherited Create;
  InitIdent;
  MakeMethodTables;
end; { Create }

destructor TmwPasLex.Destroy;
begin
  inherited Destroy;
end; { Destroy }

procedure TmwPasLex.SetOrigin(NewValue: PChar);
begin
  fOrigin:=NewValue;
  fComment:=csNo;
  fLineNumber:=0;
  fLinePos:=0;
  Run:=0;
  Next;
end; { SetOrigin }

procedure TmwPasLex.SetRunPos(Value: Integer);
begin
  Run:=Value;
  Next;
end;

procedure TmwPasLex.AddressOpProc;
begin
  Case FOrigin[Run+1]of
    '@':
      begin
        fTokenID:=tkDoubleAddressOp;
        Inc(Run, 2);
      end;
  else
    begin
      fTokenID:=tkAddressOp;
      Inc(Run);
    end;
  end;
end;

procedure TmwPasLex.AsciiCharProc;
begin
  fTokenID:=tkAsciiChar;
  Inc(Run);
  while FOrigin[Run]in ['0'..'9']do Inc(Run);
end;

procedure TmwPasLex.BraceCloseProc;
begin
  Inc(Run);
  fTokenId:=tkError;
end;

procedure TmwPasLex.BorProc;
begin
  fTokenID:=tkBorComment;
  case FOrigin[Run]of
    #0:
      begin
        NullProc;
        Exit;
      end;

    #10:
      begin
        LFProc;
        Exit;
      end;

    #13:
      begin
        CRProc;
        Exit;
      end;
  end;

  while FOrigin[Run]<>#0 do
    case FOrigin[Run]of
      '}':
        begin
          fComment:=csNo;
          Inc(Run);
          Break;
        end;
      #10: Break;

      #13: Break;
    else Inc(Run);
    end;
end;

procedure TmwPasLex.BraceOpenProc;
begin
  Case FOrigin[Run+1]of
    '$': fTokenID:=tkCompDirect;
  else
    begin
      fTokenID:=tkBorComment;
      fComment:=csBor;
    end;
  end;
  Inc(Run);
  while FOrigin[Run]<>#0 do
    case FOrigin[Run]of
      '}':
        begin
          fComment:=csNo;
          Inc(Run);
          Break;
        end;
      #10: Break;

      #13: Break;
    else Inc(Run);
    end;
end;

procedure TmwPasLex.ColonProc;
begin
  Case FOrigin[Run+1]of
    '=':
      begin
        Inc(Run, 2);
        fTokenID:=tkAssign;
      end;
  else
    begin
      Inc(Run);
      fTokenID:=tkColon;
    end;
  end;
end;

procedure TmwPasLex.CommaProc;
begin
  Inc(Run);
  fTokenID:=tkComma;
end;

procedure TmwPasLex.CRProc;
begin
  Case fComment of
    csBor: fTokenID:=tkCRLFCo;
    csAnsi: fTokenID:=tkCRLFCo;
  else fTokenID:=tkCRLF;
  end;

  Case FOrigin[Run+1]of
    #10: Inc(Run, 2);
  else Inc(Run);
  end;
  Inc(fLineNumber);
  fLinePos:=Run;
end;

procedure TmwPasLex.EqualProc;
begin
  Inc(Run);
  fTokenID:=tkEqual;
end;

procedure TmwPasLex.GreaterProc;
begin
  Case FOrigin[Run+1]of
    '=':
      begin
        Inc(Run, 2);
        fTokenID:=tkGreaterEqual;
      end;
  else
    begin
      Inc(Run);
      fTokenID:=tkGreater;
    end;
  end;
end;

function TmwPasLex.InSymbols(aChar: Char): Boolean;
begin
  if aChar in ['#', '$', '&', #39, '(', ')', '*', '+', ',', '�', '.', '/', ':',
    ';', '<', '=', '>', '@', '[', ']', '^']then Result:=True else Result:=False;
end;

function TmwPasLex.CharAhead(Count: Integer): Char;
begin
  Temp:=fOrigin+Run+Count;
  while Temp^in [#1..#9, #11, #12, #14..#32]do Inc(Temp);
  Result:=Temp^;
end;

procedure TmwPasLex.IdentProc;
begin
  fTokenID:=IdentKind((fOrigin+Run));
  Inc(Run, fStringLen);
  while Identifiers[fOrigin[Run]]do Inc(Run);
end;

procedure TmwPasLex.IntegerProc;
begin
  Inc(Run);
  fTokenID:=tkInteger;
  while FOrigin[Run]in ['0'..'9', 'A'..'F', 'a'..'f']do Inc(Run);
end;

procedure TmwPasLex.LFProc;
begin
  Case fComment of
    csBor: fTokenID:=tkCRLFCo;
    csAnsi: fTokenID:=tkCRLFCo;
  else fTokenID:=tkCRLF;
  end;
  Inc(Run);
  Inc(fLineNumber);
  fLinePos:=Run;
end;

procedure TmwPasLex.LowerProc;
begin
  case FOrigin[Run+1]of
    '=':
      begin
        Inc(Run, 2);
        fTokenID:=tkLowerEqual;
      end;
    '>':
      begin
        Inc(Run, 2);
        fTokenID:=tkNotEqual;
      end
  else
    begin
      Inc(Run);
      fTokenID:=tkLower;
    end;
  end;
end;

procedure TmwPasLex.MinusProc;
begin
  Inc(Run);
  fTokenID:=tkMinus;
end;

procedure TmwPasLex.NullProc;
begin
  fTokenID:=tkNull;
end;

procedure TmwPasLex.NumberProc;
begin
  Inc(Run);
  fTokenID:=tkNumber;
  while FOrigin[Run]in ['0'..'9', '.', 'e', 'E']do
  begin
    case FOrigin[Run]of
      '.':
        if FOrigin[Run+1]='.' then Break else fTokenID:=tkFloat
    end;
    Inc(Run);
  end;
end;

procedure TmwPasLex.PlusProc;
begin
  Inc(Run);
  fTokenID:=tkPlus;
end;

procedure TmwPasLex.PointerSymbolProc;
begin
  Inc(Run);
  fTokenID:=tkPointerSymbol;
end;

procedure TmwPasLex.PointProc;
begin
  case FOrigin[Run+1]of
    '.':
      begin
        Inc(Run, 2);
        fTokenID:=tkDotDot;
      end;
    ')':
      begin
        Inc(Run, 2);
        fTokenID:=tkSquareClose;
        Dec(FSquareCount);
      end;
  else
    begin
      Inc(Run);
      fTokenID:=tkPoint;
    end;
  end;
end;

procedure TmwPasLex.RoundCloseProc;
begin
  Inc(Run);
  fTokenID:=tkRoundClose;
  Dec(FRoundCount);
end;

procedure TmwPasLex.AnsiProc;
begin
  fTokenID:=tkAnsiComment;
  case FOrigin[Run]of
    #0:
      begin
        NullProc;
        Exit;
      end;

    #10:
      begin
        LFProc;
        Exit;
      end;

    #13:
      begin
        CRProc;
        Exit;
      end;
  end;

  while fOrigin[Run]<>#0 do
    case fOrigin[Run]of
      '*':
        if fOrigin[Run+1]=')' then
        begin
          fComment:=csNo;
          Inc(Run, 2);
          Break;
        end else Inc(Run);
      #10: Break;

      #13: Break;
    else Inc(Run);
    end;
end;

procedure TmwPasLex.RoundOpenProc;
begin
  Inc(Run);
  case fOrigin[Run]of
    '*':
      begin
        fTokenID:=tkAnsiComment;
        if FOrigin[Run+1]='$' then fTokenID:=tkCompDirect else fComment:=csAnsi;
        Inc(Run);
        while fOrigin[Run]<>#0 do
          case fOrigin[Run]of
            '*':
              if fOrigin[Run+1]=')' then
              begin
                fComment:=csNo;
                Inc(Run, 2);
                Break;
              end else Inc(Run);
            #10: Break;
            #13: Break;
          else Inc(Run);
          end;
      end;
    '.':
      begin
        Inc(Run);
        fTokenID:=tkSquareOpen;
        Inc(FSquareCount);
      end;
  else
    begin
      FTokenID:=tkRoundOpen;
      Inc(FRoundCount);
    end;
  end;
end;

procedure TmwPasLex.SemiColonProc;
begin
  Inc(Run);
  fTokenID:=tkSemiColon;
end;

procedure TmwPasLex.SlashProc;
begin
  case FOrigin[Run+1]of
    '/':
      begin
        Inc(Run, 2);
        fTokenID:=tkSlashesComment;
        while FOrigin[Run]<>#0 do
        begin
          case FOrigin[Run]of
            #10, #13: Break;
          end;
          Inc(Run);
        end;
      end;
  else
    begin
      Inc(Run);
      fTokenID:=tkSlash;
    end;
  end;
end;

procedure TmwPasLex.SpaceProc;
begin
  Inc(Run);
  fTokenID:=tkSpace;
  while FOrigin[Run]in [#1..#9, #11, #12, #14..#32]do Inc(Run);
end;

procedure TmwPasLex.SquareCloseProc;
begin
  Inc(Run);
  fTokenID:=tkSquareClose;
  Dec(FSquareCount);
end;

procedure TmwPasLex.SquareOpenProc;
begin
  Inc(Run);
  fTokenID:=tkSquareOpen;
  Inc(FSquareCount);
end;

procedure TmwPasLex.StarProc;
begin
  Inc(Run);
  fTokenID:=tkStar;
end;

procedure TmwPasLex.StringProc;
begin
  fTokenID:=tkString;
  if(FOrigin[Run+1]=#39)and(FOrigin[Run+2]=#39)then Inc(Run, 2);
  repeat
    case FOrigin[Run]of
      #0, #10, #13: Break;
    end;
    Inc(Run);
  until FOrigin[Run]=#39;
  if FOrigin[Run]<>#0 then Inc(Run);
end;

procedure TmwPasLex.SymbolProc;
begin
  Inc(Run);
  fTokenID:=tkSymbol;
end;

procedure TmwPasLex.UnknownProc;
begin
  Inc(Run);
  fTokenID:=tkUnknown;
end;

procedure TmwPasLex.Next;
begin
  Case fTokenID of
    tkIdentifier:
      begin
        fLastIdentPos:=fTokenPos;
        fLastNoSpace:=fTokenID;
        fLastNoSpacePos:=fTokenPos;
      end;
    tkSpace: ;
  else
    begin
      fLastNoSpace:=fTokenID;
      fLastNoSpacePos:=fTokenPos;
    end;
  end;
  fTokenPos:=Run;
  Case fComment of
    csNo: fProcTable[fOrigin[Run]];
  else
    Case fComment of
      csBor: BorProc;
      csAnsi: AnsiProc;
    end;
  end;
end;

function TmwPasLex.GetToken: string;
var
  Len: Longint;
begin
  Result := '';
  Len:=Run-fTokenPos;
  SetString(Result, (FOrigin+fTokenPos), Len);
end;

procedure TmwPasLex.NextID(ID: TTokenKind);
begin
  repeat
    Case fTokenID of
      tkNull: Break;
    else Next;
    end;
  until fTokenID=ID;
end;

procedure TmwPasLex.NextNoJunk;
begin
  repeat
    Next;
  until not(fTokenID in [tkSlashesComment, tkAnsiComment, tkBorComment, tkCRLF, tkCRLFCo, tkSpace]);
end;

procedure TmwPasLex.NextClass;
begin
  if fTokenID<>tkNull then next;
  repeat
    Case fTokenID of
      tkNull: Break;
    else Next;
    end;
  until(fTokenID=tkClass)and(IsClass);
end;

initialization
  MakeIdentTable;

end.





