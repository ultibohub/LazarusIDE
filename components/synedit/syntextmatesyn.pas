unit SynTextMateSyn;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, fgl, Math,
  jsonparser, jsonscanner, fpjson,
  // LazUtils
  LazFileUtils,
  Laz2_XMLRead, PList2JSon, Laz2_DOM, LazStringUtils,
  // LazEdit
  TextMateGrammar,
  // SynEdit
  SynEditHighlighter, SynEditHighlighterFoldBase, SynEditTypes, SynEditTextBase;

type

  TNameAttributesMap   = specialize TFPGMapObject<string, TSynHighlighterAttributes>;
  TGrammarLoadEvent = procedure(AGrammarFile, AGrammarPath: String; out AGrammarDef: String);

 TSynTextMateRangeInfo = record
    FoldLevel: Smallint;
  end;

  { TSynHighlighterTextMateRangeList }

  TSynHighlighterTextMateRangeList = class(TSynHighlighterRangeList)
  private
    FItemOffset: integer;
    function GetRangeInfo(Index: Integer): TSynTextMateRangeInfo;
    procedure SetRangeInfo(Index: Integer; AValue: TSynTextMateRangeInfo);
  public
    constructor Create;
    property RangeInfo[Index: Integer]: TSynTextMateRangeInfo read GetRangeInfo write SetRangeInfo;
  end;

  { TSynTextMateSyn }

  TSynTextMateSyn = class(TSynCustomFoldHighlighter)
  private
    FGrammarPath: String;
    FOnLoadGrammarFile: TGrammarLoadEvent;
    FTextMateGrammar: TTextMateGrammar;

  private
    FAttriMap: TNameAttributesMap;

    function  LoadFile(AGrammarFile: String): String;
    procedure SetGrammarPath(AValue: String);

    function GetOrCreateAttribIdxForName(AName: String): integer;
    procedure DoPopulateAttributeInfo(Sender: TTextMateGrammar; APattern: TTextMatePattern;
      AContextName: String; var AnAttribInfo: TSynAttributeInfo);
    procedure DoCheckAttributeInfo(Sender: TTextMatePattern;
      const AnAttribInfo: TSynAttributeInfo; out AnUseId, AnUseObject: Boolean);
  private
    FCurrentRange: Integer;
    FRangeInfo: TSynTextMateRangeInfo;
    FCurrentTokenPos, FCurrentTokenLen: Integer;
    FCurrentTokenKind: integer;
    FCurrentAttrib: TSynHighlighterAttributes;
    function GetParserError: String;

  protected
    function GetInstanceLanguageName: string; override;
    function CreateRangeList(ALines: TSynEditStringsBase): TSynHighlighterRangeList; override;
    function UpdateRangeInfoAtLine(Index: Integer): Boolean; override;
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    procedure LoadGrammar(AGrammarDef: String);
    procedure LoadGrammar(AGrammarFile, AGrammarPath: String);

    procedure SetLine(const NewValue: String; LineNumber: Integer); override;
    procedure Next; override;
    function GetEol: Boolean; override;
    function DebugAttrAtXPos(AXPos: Integer): String; // requires StartAtLineIndex before

    function GetToken: String; override;
    procedure GetTokenEx(out TokenStart: PChar; out TokenLength: integer); override;
    function GetTokenPos: Integer; override;
    function GetTokenKind: integer; override;
    function GetTokenAttribute: TSynHighlighterAttributes; override;
    //
    function GetDefaultAttribute(Index: integer): TSynHighlighterAttributes; override;

    procedure SetRange(Value: Pointer); override;
    procedure ResetRange; override;
    function GetRange: Pointer; override;

    function FoldBlockEndLevel(ALineIndex: TLineIdx; const AFilter: TSynFoldBlockFilter): integer; override; overload;
    function FoldBlockMinLevel(ALineIndex: TLineIdx; const AFilter: TSynFoldBlockFilter): integer; override; overload;

    property OnLoadGrammarFile: TGrammarLoadEvent read FOnLoadGrammarFile write FOnLoadGrammarFile;
    property GrammarPath: String read FGrammarPath write SetGrammarPath;
    property ParserError: String read GetParserError;
    property TextMateGrammar: TTextMateGrammar read FTextMateGrammar;
  end;

implementation

{ TSynHighlighterTextMateRangeList }

function TSynHighlighterTextMateRangeList.GetRangeInfo(Index: Integer
  ): TSynTextMateRangeInfo;
begin
  if (Index < 0) or (Index >= Count) then
    Result := Default(TSynTextMateRangeInfo)
  else
    Result := TSynTextMateRangeInfo((ItemPointer[Index] + FItemOffset)^);
end;

procedure TSynHighlighterTextMateRangeList.SetRangeInfo(Index: Integer;
  AValue: TSynTextMateRangeInfo);
begin
  TSynTextMateRangeInfo((ItemPointer[Index] + FItemOffset)^) := AValue;
end;

constructor TSynHighlighterTextMateRangeList.Create;
begin
  inherited;
  FItemOffset := ItemSize;
  ItemSize := FItemOffset + SizeOf(TSynTextMateRangeInfo);
end;

{ TSynTextMateSyn }

function TSynTextMateSyn.LoadFile(AGrammarFile: String): String;
var
  s: TStringStream;
begin
  if Assigned(FOnLoadGrammarFile) then begin
    OnLoadGrammarFile(AGrammarFile, FGrammarPath, Result);
  end
  else begin
    s := TStringStream.Create('');
    try
      s.LoadFromFile(FGrammarPath + AGrammarFile);
      Result := s.DataString;
    finally
      s.Free;
    end;
  end;
end;

procedure TSynTextMateSyn.SetGrammarPath(AValue: String);
begin
  if FGrammarPath = AValue then Exit;
  if AValue <> '' then
    AppendPathDelim(AValue);
  FGrammarPath := AValue;
end;

function TSynTextMateSyn.GetOrCreateAttribIdxForName(AName: String): integer;
var
  attr: TSynHighlighterAttributes;
begin
  if AName = '' then
    exit(-1);
  Result := FAttriMap.IndexOf(AName);
  if Result >= 0 then
    exit;
  attr := TSynHighlighterAttributes.Create(AName, AName);
  AddAttribute(attr);
  Result := FAttriMap.Add(AName, attr);
end;

function TSynTextMateSyn.GetInstanceLanguageName: string;
begin
  Result := FTextMateGrammar.LanguageName;
end;

function TSynTextMateSyn.CreateRangeList(ALines: TSynEditStringsBase
  ): TSynHighlighterRangeList;
begin
  Result := TSynHighlighterTextMateRangeList.Create;
end;

function TSynTextMateSyn.UpdateRangeInfoAtLine(Index: Integer): Boolean;
var
  r: TSynTextMateRangeInfo;
  i: Integer;
begin
  GetRange;
  i := Integer(TSynHighlighterTextMateRangeList(CurrentRanges).Range[Index]);
  if i <> FCurrentRange then
    FTextMateGrammar.MainPatternList[i].DecRefCount;

  Result := inherited;
  r := TSynHighlighterTextMateRangeList(CurrentRanges).RangeInfo[Index];
  Result := Result
        or (FRangeInfo.FoldLevel <> r.FoldLevel);
  TSynHighlighterTextMateRangeList(CurrentRanges).RangeInfo[Index] := FRangeInfo;

  if i <> FCurrentRange then
    FTextMateGrammar.MainPatternList[Integer(i)].IncRefCount;
end;

procedure TSynTextMateSyn.DoPopulateAttributeInfo(
  Sender: TTextMateGrammar; APattern: TTextMatePattern;
  AContextName: String; var AnAttribInfo: TSynAttributeInfo);
begin
  AnAttribInfo.TokId := GetOrCreateAttribIdxForName(AContextName);
  if AnAttribInfo.TokId < 0 then
    AnAttribInfo.TokObject := nil
  else
    AnAttribInfo.TokObject := FAttriMap.Data[AnAttribInfo.TokId];
end;

procedure TSynTextMateSyn.DoCheckAttributeInfo(Sender: TTextMatePattern;
  const AnAttribInfo: TSynAttributeInfo; out AnUseId, AnUseObject: Boolean);
begin
  AnUseId := AnAttribInfo.TokId >= 0;
  AnUseObject := (AnAttribInfo.TokObject <> nil) and
                 (TSynHighlighterAttributes(AnAttribInfo.TokObject).IsEnabled);
end;

function TSynTextMateSyn.GetParserError: String;
begin
  Result := FTextMateGrammar.ParserError;
end;

constructor TSynTextMateSyn.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  FAttriMap := TNameAttributesMap.Create(False);
  FTextMateGrammar := TTextMateGrammar.Create;
  FTextMateGrammar.OnPopulateAttributeInfo := @DoPopulateAttributeInfo;
  FTextMateGrammar.OnCheckAttributeInfo := @DoCheckAttributeInfo;
end;

destructor TSynTextMateSyn.Destroy;
begin
  FTextMateGrammar.ClearGrammar;
  FTextMateGrammar.Free;
  FreeHighlighterAttributes;
  FAttriMap.Clear;
  FAttriMap.Free;
  inherited Destroy;
end;

procedure TSynTextMateSyn.LoadGrammar(AGrammarDef: String);
begin
  FTextMateGrammar.ParseGrammar(AGrammarDef);
end;

procedure TSynTextMateSyn.LoadGrammar(AGrammarFile, AGrammarPath: String);
begin
  GrammarPath := AGrammarPath;
  FTextMateGrammar.ParseGrammar(LoadFile(AGrammarFile));
  if FTextMateGrammar.LanguageName = '' then
    FTextMateGrammar.LanguageName := AGrammarFile;
end;

procedure TSynTextMateSyn.SetLine(const NewValue: String;
  LineNumber: Integer);
var
  nd: TSynFoldNodeInfo;
begin
  inherited SetLine(NewValue, LineNumber);

  if FCurrentRange = -2 then
    FCurrentRange := FTextMateGrammar.CurrentPatternIndex;
// TODO setline - keep range?

  FTextMateGrammar.SetLine(CurrentLineText, FCurrentRange);
  FCurrentRange := -2;

  if FTextMateGrammar.IsFoldBegin then begin
    if not FTextMateGrammar.IsFoldEnd then begin
      inc(FRangeInfo.FoldLevel);
      if IsCollectingNodeInfo then begin
        nd := Default(TSynFoldNodeInfo);
        nd.LineIndex := LineIndex;
        nd.FoldGroup := 1;
        nd.FoldLvlStart := FRangeInfo.FoldLevel - 1;
        nd.FoldLvlEnd := FRangeInfo.FoldLevel;
        nd.NestLvlStart := FRangeInfo.FoldLevel - 1;
        nd.NestLvlEnd := FRangeInfo.FoldLevel;
        nd.FoldAction := [sfaFold, sfaFoldFold, sfaOpen, sfaOpenFold];
        CollectingNodeInfoList.Add(nd);
      end;
    end;
  end
  else
  if FTextMateGrammar.IsFoldEnd and (FRangeInfo.FoldLevel > 0) then begin
    dec(FRangeInfo.FoldLevel);
    if IsCollectingNodeInfo then begin
      nd := Default(TSynFoldNodeInfo);
      nd.LineIndex := LineIndex;
      nd.FoldGroup := 1;
      nd.FoldLvlStart := FRangeInfo.FoldLevel + 1;
      nd.FoldLvlEnd := FRangeInfo.FoldLevel;
      nd.NestLvlStart := FRangeInfo.FoldLevel + 1;
      nd.NestLvlEnd := FRangeInfo.FoldLevel;
      nd.FoldAction := [sfaFold, sfaFoldFold, sfaClose, sfaCloseFold];
      CollectingNodeInfoList.Add(nd);
    end;
  end;

  if IsScanning then begin
    FTextMateGrammar.NextToEol;
  end
  else begin
    FTextMateGrammar.First;
    FCurrentTokenKind := FTextMateGrammar.CurrentTokenKind;
    FCurrentAttrib    := TSynHighlighterAttributes(FTextMateGrammar.CurrentAttrib);
    FCurrentTokenPos  := FTextMateGrammar.CurrentTokenPos;
    FCurrentTokenLen  := FTextMateGrammar.CurrentTokenLen;
  end;
  //FCurrentRange := FTextMateGrammar.CurrentPatternIndex;

end;

procedure TSynTextMateSyn.Next;
begin
  FTextMateGrammar.Next;
  FCurrentTokenKind := FTextMateGrammar.CurrentTokenKind;
  FCurrentAttrib    := TSynHighlighterAttributes(FTextMateGrammar.CurrentAttrib);
  FCurrentTokenPos  := FTextMateGrammar.CurrentTokenPos;
  FCurrentTokenLen  := FTextMateGrammar.CurrentTokenLen;
  //FCurrentRange     := FTextMateGrammar.CurrentPatternIndex;
end;

function TSynTextMateSyn.DebugAttrAtXPos(AXPos: Integer): String;
var
  st: TTextMatePatternState;
  i: Integer;
begin
  Result := '';
  st := FTextMateGrammar.CurrentState;
  SetLength(st.StateList, Length(st.StateList)) ;
  while (FCurrentTokenPos + FCurrentTokenLen < AXPos) do begin
    if GetEol then begin
      result := format('EOL At %d Len %d %s', [FCurrentTokenPos, FCurrentTokenLen, LineEnding]);
      exit;
    end;
    st := FTextMateGrammar.CurrentState;
    SetLength(st.StateList, Length(st.StateList)) ;
    Next;
  end;

  result := format('At %d Len %d %s', [FCurrentTokenPos, FCurrentTokenLen, LineEnding]);

  for i := st.StateIdx downto 0 do begin
    if st.StateList[i].Pattern <> nil then begin
      if (st.StateList[i].Pattern is TTextMatePatternBaseNested) and
         (st.StateList[i].Pattern.ForwardTarget <> nil)
      then
        Result := Result + Format('%2d: %4d: %s / %s >// %s %s%s', [
          i,
          st.StateList[i].Pattern.ForwardTarget.Index,
          st.StateList[i].Pattern.ForwardTarget.Name,
          st.StateList[i].Pattern.ForwardTarget.Comment,
          StripLN(st.StateList[i].Pattern.DebugDump(0,false,'')),
          st.StateList[i].Pattern.ForwardTarget.ClassName,
          LineEnding
        ])
      else
        Result := Result + Format('%2d: %4d: %s / %s  // %s%s%s', [
          i,
          st.StateList[i].Pattern.Index,
          st.StateList[i].Pattern.Name,
          st.StateList[i].Pattern.Comment,
          StripLN(st.StateList[i].Pattern.DebugDump(0,false,'')),
          st.StateList[i].Pattern.ClassName,
          LineEnding
        ]);
      end
      else
        Result := Result + '???';
  end;
end;

function TSynTextMateSyn.GetEol: Boolean;
begin
  Result := FTextMateGrammar.IsAtEol;
end;

function TSynTextMateSyn.GetToken: String;
begin
  Result := Copy(CurrentLineText, FCurrentTokenPos, FCurrentTokenLen);
end;

procedure TSynTextMateSyn.GetTokenEx(out TokenStart: PChar; out
  TokenLength: integer);
begin
  TokenStart := @CurrentLineText[FCurrentTokenPos];
  TokenLength := FCurrentTokenLen;
end;

function TSynTextMateSyn.GetTokenPos: Integer;
begin
  Result := FCurrentTokenPos - 1;
end;

function TSynTextMateSyn.GetTokenKind: integer;
begin
  Result := FCurrentTokenKind;
end;

function TSynTextMateSyn.GetTokenAttribute: TSynHighlighterAttributes;
begin
  Result := FCurrentAttrib;
end;

function TSynTextMateSyn.GetDefaultAttribute(Index: integer
  ): TSynHighlighterAttributes;
begin
  Result := FAttriMap.Data[FTextMateGrammar.RootPattern.AttribInfo.TokId];
end;

procedure TSynTextMateSyn.SetRange(Value: Pointer);
begin
  FCurrentRange := PtrUInt(Value);
  FRangeInfo := TSynHighlighterTextMateRangeList(CurrentRanges).RangeInfo[LineIndex-1];
end;

procedure TSynTextMateSyn.ResetRange;
begin
  FCurrentRange := -1;
  FRangeInfo := Default(TSynTextMateRangeInfo);
end;

function TSynTextMateSyn.GetRange: Pointer;
begin
  FCurrentRange     := FTextMateGrammar.CurrentPatternIndex;
  Result := Pointer(PtrUInt(FCurrentRange));
end;

function TSynTextMateSyn.FoldBlockEndLevel(ALineIndex: TLineIdx;
  const AFilter: TSynFoldBlockFilter): integer;
var
  RangeInfo: TSynTextMateRangeInfo;
begin
  RangeInfo := TSynHighlighterTextMateRangeList(CurrentRanges).RangeInfo[ALineIndex];
  Result := RangeInfo.FoldLevel;
end;

function TSynTextMateSyn.FoldBlockMinLevel(ALineIndex: TLineIdx;
  const AFilter: TSynFoldBlockFilter): integer;
var
  RangeInfo: TSynTextMateRangeInfo;
begin
  RangeInfo := TSynHighlighterTextMateRangeList(CurrentRanges).RangeInfo[ALineIndex-1];
  Result := RangeInfo.FoldLevel;
  RangeInfo := TSynHighlighterTextMateRangeList(CurrentRanges).RangeInfo[ALineIndex];
  if Result > RangeInfo.FoldLevel then
    Result := RangeInfo.FoldLevel;
end;

end.

