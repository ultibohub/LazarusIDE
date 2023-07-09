{ Search engine for wiki pages

  Copyright (C) 2012  Mattias Gaertner  mattias@freepascal.org

  This source is free software; you can redistribute it and/or modify it under
  the terms of the GNU General Public License as published by the Free
  Software Foundation; either version 2 of the License, or (at your option)
  any later version.

  This code is distributed in the hope that it will be useful, but WITHOUT ANY
  WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS
  FOR A PARTICULAR PURPOSE.  See the GNU General Public License for more
  details.

  A copy of the GNU General Public License is available on the World Wide Web
  at <http://www.gnu.org/copyleft/gpl.html>. You can also obtain it by writing
  to the Free Software Foundation, Inc., 51 Franklin Street - Fifth Floor,
  Boston, MA 02110-1335, USA.

}
unit WikiHelpManager;

{$mode objfpc}{$H+}

{ $DEFINE VerboseWikiHelp}

interface

uses
  Classes, SysUtils, math,
  // LazUtils
  LazFileUtils, LazLogger, LazDbgLog, LazUTF8, LazStringUtils, laz2_DOM, AvgLvlTree,
  // CodeTools
  BasicCodeTools, KeywordFuncLists,
  //
  MTProcs,
  // Wiki
  Wiki2HTMLConvert, Wiki2XHTMLConvert, WikiFormat, WikiParser;

type
  TWikiHelp = class;

  TWHFitsCategory = (
    whfcNone,
    whfcLink,
    whfcText,
    whfcHeader,
    whfcPageTitle
    );
  TWHFitsCategories = set of TWHFitsCategory;

  TWHFitsStringFlag = (
    whfsPart,
    whfsWholeWord
    );
  TWHFitsStringFlags = set of TWHFitsStringFlag;

  TWHPhrasePageFit = record
    Category: TWHFitsCategory;
    Quality: TWHFitsStringFlag;
  end;
  PWHPhrasePageFit = ^TWHPhrasePageFit;

  TWHScore = single;

  { TWHScoring }

  TWHScoring = class(TPersistent)
  public
    Phrases: array[TWHFitsCategory,TWHFitsStringFlag] of TWHScore;
    function Equals(Obj: TObject): boolean; override;
    procedure Assign(Source: TPersistent); override;
  end;

  { TWikiHelpQuery }

  TWikiHelpQuery = class(TPersistent)
  public
    Phrases: TStrings;
    LoPhrases: TStrings; // Phrases lowercase
    Languages: string; // comma separated list, '-' means not the original, 'de' = german, '*' = all
    Scoring: TWHScoring;
    FreeScoring: boolean;
    constructor Create(const SearchText: string; const aLang: string = '';
      aScoring: TWHScoring = nil; aFreeScoring: boolean = false);
    constructor Clone(Query: TWikiHelpQuery);
    destructor Destroy; override;
    function Equals(Obj: TObject): boolean; override;
    procedure Assign(Source: TPersistent); override;
  end;

  TWHTextNodeType = (
    whnTxt,
    whnHeader,
    whnLink
    );

  { TWHTextNode }

  TWHTextNode = class
  private
    FChildNodes: TFPList; // list of TW2HelpTextNode
    FIndexInParent: integer;
    FParent: TWHTextNode;
    function GetChildNodes(Index: integer): TWHTextNode;
    procedure RemoveChild(Child: TWHTextNode);
  public
    Typ: TWHTextNodeType;
    Txt: string;
    constructor Create(aTyp: TWHTextNodeType; aParent: TWHTextNode);
    destructor Destroy; override;
    procedure Clear;
    procedure Add(Node: TWHTextNode);
    function Count: integer;
    property ChildNodes[Index: integer]: TWHTextNode read GetChildNodes; default;
    property IndexInParent: integer read FIndexInParent;
    property Parent: TWHTextNode read FParent;
    function FirstChild: TWHTextNode;
    function LastChild: TWHTextNode;
    function NextSibling: TWHTextNode;
    function PreviousSibling: TWHTextNode;
    function Next: TWHTextNode; // first child, then next sibling, then next sibling of parent, ...
    function NextSkipChildren: TWHTextNode; // first next sibling, then next sibling of parent, ...
    function Previous: TWHTextNode; // the reverse of Next
    function LastLeaf: TWHTextNode; // get last child of last child of ...
    function Level: integer; // root node has 0

    function CalcMemSize: SizeInt;
  end;

  { TW2HelpPage }

  TW2HelpPage = class(TW2HTMLPage)
  public
    WHRoot: TWHTextNode;
    CurWHNode: TWHTextNode;
    Score: single;
    destructor Destroy; override;
    function GetScore(Query: TWikiHelpQuery): TWHScore;
    procedure GetFit(Query: TWikiHelpQuery; Fit: PWHPhrasePageFit);
    function GetNodeHighestScore(Query: TWikiHelpQuery): TWHTextNode;
  end;

  { TWiki2HelpConverter }

  TWiki2HelpConverter = class(TWiki2HTMLConverter)
  private
    FCurQuery: TWikiHelpQuery;
    FHelp: TWikiHelp;
  protected
    PagesPerThread: integer;
    AvailableImages: TFilenameToStringTree; // existing files in the ImagesDirectory
    procedure SavePage({%H-}Page: TW2XHTMLPage); override;
    function FindImage(const ImgFilename: string): string; override;
    procedure ExtractPageText(Page: TW2HelpPage);
    procedure ExtractTextToken(Token: TWPToken);
    procedure ParallelExtractPageText(Index: PtrInt; {%H-}Data: Pointer; {%H-}Item: TMultiThreadProcItem);
    procedure ParallelLoadPage(Index: PtrInt; {%H-}Data: Pointer; {%H-}Item: TMultiThreadProcItem);
    procedure ParallelComputeScores(Index: PtrInt; {%H-}Data: Pointer; {%H-}Item: TMultiThreadProcItem);
  public
    constructor Create; override;
    procedure Clear; override;
    destructor Destroy; override;
    procedure LoadPages;
    procedure ConvertInit; override;
    procedure ExtractAllTexts;
    procedure Search(Query: TWikiHelpQuery; var FoundPages: TFPList);
    procedure SavePageAsHTMLToStream(Page: TW2HelpPage; aStream: TStream);
    function PageToFilename(Page: string; IsInternalLink, {%H-}Full: boolean
      ): string; override;
    function PageToFilename(Page: TW2XHTMLPage; {%H-}Full: boolean): string; override;
    property Help: TWikiHelp read FHelp;
  end;

  { TWikiHelpThread }

  TWikiHelpThread = class(TThread)
  protected
    fLogMsg: string;
    fCompleted: boolean;
    procedure Execute; override;
    procedure MainThreadLog;
    procedure Log({%H-}Msg: string);
    procedure ConverterLog({%H-}Msg: string);
    procedure Scanned; // called in thread at end
  public
    Help: TWikiHelp;
  end;

  TWikiHelpProgressStep = (
    whpsNone,
    whpsWikiScanDir,
    whpsWikiLoadPages,
    whpsWikiExtractPageTexts,
    whpsWikiLoadComplete,
    whpsWikiSearch,
    whpsWikiSearchComplete
    );

  { TWikiHelp }

  TWikiHelp = class(TComponent)
  private
    FAborting: boolean;
    FConverter: TWiki2HelpConverter;
    FMaxResults: integer;
    FOnScanned: TNotifyEvent;
    FOnSearched: TNotifyEvent;
    FQuery: TWikiHelpQuery;
    FDefaultScoring: TWHScoring;
    FResultsCSS: string;
    FResultsCSSURL: string;
    FResultsHTML: string;
    FXMLDirectory: string;
    FCritSec: TRTLCriticalSection;
    FScanThread: TWikiHelpThread;
    fProgressStep: TWikiHelpProgressStep;
    fProgressCount: integer;
    fProgressMax: integer;
    fWikiLoadTimeMSec: integer;
    fWikiSearchTimeMSec: integer;
    function GetImagesDirectory: string;
    procedure SetImagesDirectory(AValue: string);
    procedure SetMaxResults(AValue: integer);
    procedure SetQuery(AValue: TWikiHelpQuery);
    procedure SetXMLDirectory(AValue: string);
    procedure EnterCritSect;
    procedure LeaveCritSect;
    procedure Scanned;
    procedure DoSearch;
    function FoundNodeToHTMLSnippet(aPage: TW2HelpPage; aNode: TWHTextNode;
      aQuery: TWikiHelpQuery): string;
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    function GetProgressCaption: string;
    function Busy: boolean;

    property ResultsCSS: string read FResultsCSS write FResultsCSS;
    property ResultsCSSURL: string read FResultsCSSURL write FResultsCSSURL;

    // load wiki files
    procedure StartLoading; // returns immediately
    function LoadingContent: boolean;
    procedure AbortLoading(Wait: boolean);
    property Aborting: boolean read FAborting;
    function LoadComplete: boolean;

    // languages
    function CollectAllLanguages(AsCaption: boolean): TStrings;

    // search
    procedure Search(const Term: string; const Languages: string = '';
                     Scoring: TWHScoring = nil; FreeScoring: boolean = false);
    procedure Search(aQuery: TWikiHelpQuery);
    property Query: TWikiHelpQuery read FQuery;
    property DefaultScoring: TWHScoring read FDefaultScoring;
    property MaxResults: integer read FMaxResults write SetMaxResults;
    property ResultsHTML: string read FResultsHTML;

    // get page
    procedure SavePageToStream(DocumentName: string; aStream: TStream);
  public
    property XMLDirectory: string read FXMLDirectory write SetXMLDirectory; // directory where the wiki xml files are
    property ImagesDirectory: string read GetImagesDirectory write SetImagesDirectory; // directory where the wiki image files are
    property Converter: TWiki2HelpConverter read FConverter;
    property OnScanned: TNotifyEvent read FOnScanned write FOnScanned;
    property OnSearched: TNotifyEvent read FOnSearched write FOnSearched;
  end;

var
  WikiHelp: TWikiHelp = nil;

function SearchTextToPhrases(Txt: string): TStringList;
function CompareW2HPageForScore(Page1, Page2: Pointer): integer;
function TextToHTMLSnipped(Txt: string; LoCaseStringsToHighlight: TStrings;
  MaxUTF8Length: integer): string;

function dbgs(t: TWHTextNodeType): string; overload;

procedure Test_TextToHTMLSnipped;

implementation

function TextToHTMLSnipped(Txt: string; LoCaseStringsToHighlight: TStrings;
  MaxUTF8Length: integer): string;
var
  i: Integer;
  LoTxt: String;
  Bold: PByte; // for each UTF-8 character: the number of matching phrases
  Phrase: String;
  PhraseStartChar: Char;
  LoTxtP: PChar;
  CurLoTxtP: PChar;
  CurPhraseP: PChar;
  BoldP: PByte;
  l: Integer;
  BestPhraseCount: Integer;
  CurPhraseCount: Integer;
  BestPos: Integer;
  IsBold: Boolean;
  StartChomped: Boolean;
  EndChomped: Boolean;
begin
  if MaxUTF8Length<=0 then exit('');
  Result:=UTF8Trim(Txt);
  {$IFDEF VerboseTextToHTMLSnipped}
  debugln(['TextToHTMLSnipped trimmed Result="',Result,'"']);
  debugln(['TextToHTMLSnipped LoCaseStringsToHighlight="',Trim(LoCaseStringsToHighlight.Text),'"']);
  {$ENDIF}
  // convert white space to single space
  i:=1;
  while i<=length(Result) do begin
    if Result[i] in [#0..#31] then
      Result[i]:=' ';
    if (Result[i]=' ') and ((i=1) or (Result[i-1]=' ')) then
      Delete(Result,i,1)
    else
      inc(i);
  end;
  if Result='' then exit;
  LoTxt:=UTF8LowerCase(Result);
  {$IFDEF VerboseTextToHTMLSnipped}
  debugln(['TextToHTMLSnipped locase Result="',LoTxt,'"']);
  {$ENDIF}
  GetMem(Bold,Max(length(LoTxt),length(Result))+7);
  try
    // mark phrases
    FillByte(Bold^,length(LoTxt)+7,0);
    for i:=0 to Min(LoCaseStringsToHighlight.Count-1,255) do begin
      Phrase:=LoCaseStringsToHighlight[i];
      if Phrase='' then continue;
      BoldP:=Bold;
      PhraseStartChar:=Phrase[1];
      LoTxtP:=PChar(LoTxt);
      while LoTxtP^<>#0 do begin
        //debugln(['TextToHTMLSnipped PhraseStartChar=',PhraseStartChar,' ',dbgstr(LoTxtP^)]);
        if LoTxtP^=PhraseStartChar then begin
          CurLoTxtP:=LoTxtP+1;
          CurPhraseP:=PChar(Phrase)+1;
          while (CurLoTxtP^=CurPhraseP^) and (CurLoTxtP^<>#0) do begin
            inc(CurLoTxtP);
            inc(CurPhraseP);
          end;
          if CurPhraseP^=#0 then begin
            // phrase found => mark phrase in Bold array
            //debugln(['TextToHTMLSnipped phrase "',Phrase,'" found at ',LoTxtP-PChar(LoTxt)]);
            CurPhraseP:=PChar(Phrase);
            while (CurPhraseP^<>#0) do begin
              l:=UTF8CodepointSize(CurPhraseP);
              inc(LoTxtP,l);
              inc(CurPhraseP,l);
              BoldP^+=1;
              inc(BoldP);
            end;
            continue;
          end;
        end;
        inc(LoTxtP,UTF8CodepointSize(LoTxtP));
        inc(BoldP);
      end;
    end;

    {$IFDEF VerboseTextToHTMLSnipped}
    dbgout(' Bold: ');
    LoTxtP:=PChar(LoTxt);
    BoldP:=Bold;
    while LoTxtP^<>#0 do begin
      dbgout([' ',dbgstr(LoTxtP^),':',BoldP^]);
      inc(LoTxtP,UTF8CodepointSize(LoTxtP));
      inc(BoldP);
    end;
    debugln;
    debugln('Result="',Result,'"');
    dbgout ('Bold  = ');
    l:=UTF8Length(Result);
    for i:=0 to l-1 do
      dbgout(dbgs(Bold[i]));
    debugln;
    {$ENDIF}

    l:=UTF8Length(Result);
    StartChomped:=false;
    EndChomped:=false;
    if (l>MaxUTF8Length) then begin
      // text too long
      // => find substring with most phrases
      CurPhraseCount:=0;
      for i:=0 to MaxUTF8Length-1 do
        inc(CurPhraseCount,Bold[i]);
      BestPhraseCount:=CurPhraseCount;
      BestPos:=0;
      for i:=0 to l-MaxUTF8Length-1 do begin
        CurPhraseCount+=Bold[i+MaxUTF8Length]-Bold[i];
        if CurPhraseCount>=BestPhraseCount then begin
          BestPhraseCount:=CurPhraseCount;
          BestPos:=i+1;
        end;
      end;
      if BestPos>0 then begin
        // BestPos is the latest substring containing the maximum
        // => move BestPos to center the maximum
        // => balance left and right of not marked characters
        i:=BestPos;
        while (i>0) and (Bold[i-1]=0)  and (Bold[i+MaxUTF8Length-1]=0) do
          dec(i);
        if i<BestPos then inc(i);
        BestPos:=(i+BestPos) div 2;
      end;

      // cut down Result and Bold
      Result:=UTF8Copy(Result,BestPos+1,MaxUTF8Length);
      if BestPos>0 then begin
        StartChomped:=true;
        System.Move(Bold[BestPos],Bold[0],MaxUTF8Length);
      end;
      if BestPos+MaxUTF8Length<l then
        EndChomped:=true;
    end;

    {$IFDEF VerboseTextToHTMLSnipped}
    debugln(['TextToHTMLSnipped chomped Result="',Result,'"']);
    {$ENDIF}

    // add bold tags
    i:=1;
    BoldP:=Bold;
    IsBold:=false;
    while i<=length(Result) do begin
      if (BoldP^>0) and (not IsBold) then begin
        // insert bold start tag
        Insert('<b>',Result,i);
        inc(i,length('<b>'));
        IsBold:=true;
      end else if (BoldP^=0) and IsBold then begin
        // insert bold end tag
        Insert('</b>',Result,i);
        inc(i,length('</b>'));
        IsBold:=false;
      end;
      if Result[i]='<' then begin
        // replace <
        ReplaceSubstring(Result,i,1,'&lt;');
        inc(i,length('&lt;'));
      end else if Result[i]='>' then begin
        // replace >
        ReplaceSubstring(Result,i,1,'&gt;');
        inc(i,length('&gt;'));
      end else
        inc(i,UTF8CodepointSize(@Result[i]));
      inc(BoldP);
    end;
    if IsBold then
      Result+='</b>';
    // prepend and append '...'
    Result:=UTF8Trim(Result);
    if StartChomped then
      Result:='...'+Result;
    if EndChomped then
      Result+='...';

    {$IFDEF VerboseTextToHTMLSnipped}
    debugln(['TextToHTMLSnipped END Result="',Result,'"']);
    {$ENDIF}
  finally
    FreeMem(Bold);
  end;
end;

function dbgs(t: TWHTextNodeType): string;
begin
  Result:='';
  writestr(Result,t);
end;

procedure Test_TextToHTMLSnipped;

  procedure t(Txt, LoCaseHighlights: string; MaxUTF8Length: integer; Expected: string);
  var
    LoCaseStringsToHighlight: TStringList;
    s: String;
  begin
    LoCaseStringsToHighlight:=TStringList.Create;
    LoCaseStringsToHighlight.Delimiter:=',';
    LoCaseStringsToHighlight.StrictDelimiter:=true;
    LoCaseStringsToHighlight.DelimitedText:=LoCaseHighlights;
    s:=TextToHTMLSnipped(Txt,LoCaseStringsToHighlight,MaxUTF8Length);
    if Expected<>s then begin
      debugln(['Test_TextToHTMLSnipped Txt="'+Txt+'"']);
      debugln(['Test_TextToHTMLSnipped LoCaseHighlights="'+LoCaseHighlights+'"']);
      debugln(['Test_TextToHTMLSnipped MaxUTF8Length='+dbgs(MaxUTF8Length)]);
      debugln(['Test_TextToHTMLSnipped Expected="'+Expected+'"']);
      debugln(['Test_TextToHTMLSnipped Result  ="'+s+'"']);
      raise Exception.Create('Test_TextToHTMLSnipped: Txt="'+Txt+'" LoCaseHighlights="'+LoCaseHighlights+'" Max='+dbgs(MaxUTF8Length)+' Expected="'+Expected+'" Result="'+s+'"');
    end;
    LoCaseStringsToHighlight.Free;
  end;

begin
  t('','',0,'');
  t('bla','bla',100,'<b>bla</b>');
  t('bla foo bar','bla,bar',100,'<b>bla</b> foo <b>bar</b>');
  t('bla foo bar','bla foo,bla,foo',100,'<b>bla foo</b> bar');
  t('bla foo bar','foo',100,'bla <b>foo</b> bar');
  t('bla foo bar','foo',7,'...a <b>foo</b> b...');
  t('bl< foo >ar','foo',7,'...&lt; <b>foo</b> &gt;...');
end;

function SearchTextToPhrases(Txt: string): TStringList;
var
  p: PChar;
  StartPos: PChar;
  Phrase: String;
begin
  Result:=TStringList.Create;
  Txt:=UTF8Trim(Txt);
  if Txt='' then exit;
  Result.Add(Txt);
  p:=PChar(Txt);
  Phrase:='';
  while p^<>#0 do begin
    if p^='"' then begin
      // quote
      inc(p);
      StartPos:=p;
      while not (p^ in [#0,'"']) do inc(p);
      Phrase:=Phrase+SubString(StartPos,p-StartPos);
      if p^<>#0 then inc(p);
    end else if p^ in [' ',#9,#10,#13] then begin
      // space => end phrase
      inc(p);
      if Phrase<>'' then begin
        if Result.IndexOf(Phrase)<0 then
          Result.Add(Phrase);
        Phrase:='';
      end;
    end else begin
      // word
      StartPos:=p;
      while not (p^ in [#0,'"',' ',#9,#10,#13]) do inc(p);
      Phrase:=Phrase+SubString(StartPos,p-StartPos);
    end;
  end;
  if (Phrase<>'') and (Result.IndexOf(Phrase)<0) then
    Result.Add(Phrase);
end;

function CompareW2HPageForScore(Page1, Page2: Pointer): integer;
var
  p1: TW2HelpPage absolute Page1;
  p2: TW2HelpPage absolute Page2;
begin
  if p1.Score>p2.Score then
    exit(-1)
  else if p1.Score<p2.Score then
    exit(1)
  else
    exit(0);
end;

{ TWHScoring }

function TWHScoring.Equals(Obj: TObject): boolean;
var
  c: TWHFitsCategory;
  f: TWHFitsStringFlag;
  Src: TWHScoring;
begin
  if Self=Obj then exit(true);
  Result:=false;
  if Obj=nil then exit;
  if Obj is TWHScoring then begin
    Src:=TWHScoring(Obj);
    for c:=Low(TWHFitsCategory) to high(TWHFitsCategory) do
      for f:=Low(TWHFitsStringFlag) to high(TWHFitsStringFlag) do
        if Phrases[c,f]<>Src.Phrases[c,f] then exit;
  end;
  Result:=true;
end;

procedure TWHScoring.Assign(Source: TPersistent);
var
  Src: TWHScoring;
begin
  if Source is TWHScoring then begin
    Src:=TWHScoring(Source);
    Move(Src.Phrases,Phrases,SizeOf(Phrases));
  end else
    inherited Assign(Source);
end;

{ TWikiHelpQuery }

constructor TWikiHelpQuery.Create(const SearchText: string;
  const aLang: string; aScoring: TWHScoring; aFreeScoring: boolean);
var
  i: Integer;
begin
  Phrases:=SearchTextToPhrases(SearchText);
  LoPhrases:=TStringList.Create;
  for i:=0 to Phrases.Count-1 do
    LoPhrases.Add(UTF8LowerCase(Phrases[i]));
  Languages:=aLang;
  Scoring:=aScoring;
  FreeScoring:=aFreeScoring;
end;

constructor TWikiHelpQuery.Clone(Query: TWikiHelpQuery);
begin
  Phrases:=TStringList.Create;
  LoPhrases:=TStringList.Create;
  Scoring:=TWHScoring.Create;
  FreeScoring:=true;
  Assign(Query);
end;

destructor TWikiHelpQuery.Destroy;
begin
  FreeAndNil(Phrases);
  FreeAndNil(LoPhrases);
  if FreeScoring then
    FreeAndNil(Scoring)
  else
    Scoring:=nil;
  inherited Destroy;
end;

function TWikiHelpQuery.Equals(Obj: TObject): boolean;
var
  Src: TWikiHelpQuery;
begin
  if Obj=Self then exit(true);
  Result:=false;
  if Obj=nil then exit;
  if not (Obj is TWikiHelpQuery) then exit;
  Src:=TWikiHelpQuery(Obj);
  if not Phrases.Equals(Src.Phrases) then exit;
  // LoPhrases is computed from Phrases
  if Languages<>Src.Languages then exit;
  if not Scoring.Equals(Src.Scoring) then exit;
  Result:=true;
end;

procedure TWikiHelpQuery.Assign(Source: TPersistent);
var
  Src: TWikiHelpQuery;
begin
  if Source is TWikiHelpQuery then begin
    Src:=TWikiHelpQuery(Source);
    Phrases.Assign(Src.Phrases);
    LoPhrases.Assign(Src.LoPhrases);
    Languages:=Src.Languages;
    Scoring.Assign(Src.Scoring);
  end else
    inherited Assign(Source);
end;

{ TW2HelpPage }

destructor TW2HelpPage.Destroy;
begin
  FreeAndNil(WHRoot);
  inherited Destroy;
end;

function TW2HelpPage.GetScore(Query: TWikiHelpQuery): TWHScore;
var
  PhrasesFit: PWHPhrasePageFit;
  Size: Integer;
  i: Integer;
  Fit: PWHPhrasePageFit;
begin
  Result:=0;
  if (Query=nil) or (Query.LoPhrases.Count=0) then exit;
  if not WikiPageHasLanguage(WikiDocumentName,Query.Languages) then begin
    //debugln(['TW2HelpPage.GetScore lang does not fit ',WikiDocumentName,' "',GetWikiPageLanguage(WikiDocumentName),'" ',Query.Languages]);
    exit;
  end;

  Size:=Query.LoPhrases.Count*SizeOf(TWHPhrasePageFit);
  GetMem(PhrasesFit,Size);
  try
    FillByte(PhrasesFit^,Size,0);
    GetFit(Query,PhrasesFit);
    for i:=0 to Query.LoPhrases.Count-1 do begin
      Fit:=@PhrasesFit[i];
      Result+=Query.Scoring.Phrases[Fit^.Category,Fit^.Quality];
    end;
  finally
    FreeMem(PhrasesFit);
  end;
end;

procedure TW2HelpPage.GetFit(Query: TWikiHelpQuery; Fit: PWHPhrasePageFit);

  procedure CheckTxt(s: string; Category: TWHFitsCategory);
  var
    i: Integer;
    Phrase: String;
    FitsWholeWord: boolean;
    FitsCount: SizeInt;
    Quality: TWHFitsStringFlag;
  begin
    s:=UTF8LowerCase(s);
    for i:=0 to Query.LoPhrases.Count-1 do begin
      if Fit[i].Category>Category then continue;
      if (Fit[i].Category=Category) and (Fit[i].Quality>=whfsWholeWord) then
        continue;
      Phrase:=Query.LoPhrases[i];
      HasTxtWord(PChar(Phrase),PChar(s),FitsWholeWord,FitsCount);
      if FitsCount<=0 then continue;
      if FitsWholeWord then
        Quality:=whfsWholeWord
      else
        Quality:=whfsPart;
      Fit[i].Category:=Category;
      Fit[i].Quality:=Quality;
    end;
  end;

  procedure Traverse(Node: TWHTextNode);
  var
    i: Integer;
    Category: TWHFitsCategory;
  begin
    if Node=nil then exit;
    case Node.Typ of
    whnTxt: Category:=whfcText;
    whnHeader: Category:=whfcHeader;
    whnLink: Category:=whfcLink;
    else exit;
    end;
    CheckTxt(Node.Txt,Category);
    for i:=0 to Node.Count-1 do
      Traverse(Node[i]);
  end;

begin
  CheckTxt(WikiPage.Title,whfcPageTitle);
  Traverse(WHRoot);
end;

function TW2HelpPage.GetNodeHighestScore(Query: TWikiHelpQuery): TWHTextNode;

  function GetNodeScore(Node: TWHTextNode): TWHScore;
  var
    s: String;
    i: Integer;
    Phrase: String;
    FitsWholeWord: boolean;
    FitsCount: SizeInt;
    Quality: TWHFitsStringFlag;
    Category: TWHFitsCategory;
  begin
    Result:=0;
    case Node.Typ of
    whnTxt: Category:=whfcText;
    whnHeader: Category:=whfcHeader;
    whnLink: Category:=whfcLink;
    else exit;
    end;
    s:=UTF8LowerCase(Node.Txt);
    for i:=0 to Query.LoPhrases.Count-1 do begin
      Phrase:=Query.LoPhrases[i];
      HasTxtWord(PChar(Phrase),PChar(s),FitsWholeWord,FitsCount);
      if FitsCount<=0 then continue;
      if FitsWholeWord then
        Quality:=whfsWholeWord
      else
        Quality:=whfsPart;
      Result+=Query.Scoring.Phrases[Category,Quality];
    end;
  end;

  procedure Traverse(Node: TWHTextNode;
    var BestNode: TWHTextNode; var BestScore: TWHScore);
  var
    i: Integer;
    NodeScore: TWHScore;
  begin
    if Node=nil then exit;
    NodeScore:=GetNodeScore(Node);
    if NodeScore>BestScore then begin
      BestNode:=Node;
      BestScore:=NodeScore;
    end;
    for i:=0 to Node.Count-1 do
      Traverse(Node[i],BestNode,BestScore);
  end;

var
  NodeScore: TWHScore;
begin
  Result:=nil;
  NodeScore:=0;
  Traverse(WHRoot,Result,NodeScore);
end;

{ TWHTextNode }

function TWHTextNode.GetChildNodes(Index: integer): TWHTextNode;
begin
  Result:=TWHTextNode(FChildNodes[Index]);
end;

procedure TWHTextNode.RemoveChild(Child: TWHTextNode);
var
  i: Integer;
begin
  FChildNodes.Delete(Child.IndexInParent);
  for i:=Child.IndexInParent to FChildNodes.Count-1 do
    ChildNodes[i].fIndexInParent:=i;
end;

constructor TWHTextNode.Create(aTyp: TWHTextNodeType; aParent: TWHTextNode);
begin
  Typ:=aTyp;
  if aParent<>nil then
    aParent.Add(Self)
  else
    fIndexInParent:=-1;
end;

destructor TWHTextNode.Destroy;
begin
  Clear;
  if Parent<>nil then
    Parent.RemoveChild(Self);
  FreeAndNil(FChildNodes);
  inherited Destroy;
end;

procedure TWHTextNode.Clear;
var
  i: Integer;
  Child: TWHTextNode;
begin
  Txt:='';
  if FChildNodes<>nil then begin
    for i:=FChildNodes.Count-1 downto 0 do begin
      Child:=TWHTextNode(FChildNodes[i]);
      Child.fParent:=nil;
      Child.Free;
    end;
    FChildNodes.Clear;
  end;
end;

procedure TWHTextNode.Add(Node: TWHTextNode);
begin
  if Node.Parent=Self then exit;
  if Node.Parent<>nil then
    Node.Parent.RemoveChild(Node);
  if FChildNodes=nil then
    FChildNodes:=TFPList.Create;
  Node.fIndexInParent:=Count;
  FChildNodes.Add(Node);
  Node.fParent:=Self;
end;

function TWHTextNode.Count: integer;
begin
  if FChildNodes<>nil then
    Result:=FChildNodes.Count
  else
    Result:=0;
end;

function TWHTextNode.FirstChild: TWHTextNode;
begin
  if Count>0 then
    Result:=ChildNodes[0]
  else
    Result:=nil;
end;

function TWHTextNode.LastChild: TWHTextNode;
var
  c: Integer;
begin
  c:=Count;
  if c>0 then
    Result:=ChildNodes[c-1]
  else
    Result:=nil;
end;

function TWHTextNode.NextSibling: TWHTextNode;
begin
  if (Parent=nil) or (IndexInParent+2>=Parent.Count) then exit(nil);
  Result:=Parent[IndexInParent+1];
end;

function TWHTextNode.PreviousSibling: TWHTextNode;
begin
  if (Parent=nil) or (IndexInParent=0) then exit(nil);
  Result:=Parent[IndexInParent-1];
end;

function TWHTextNode.Next: TWHTextNode;
begin
  Result:=FirstChild;
  if Result=nil then
    Result:=NextSkipChildren;
end;

function TWHTextNode.NextSkipChildren: TWHTextNode;
var
  Node: TWHTextNode;
begin
  Result:=Self;
  repeat
    Node:=Result.NextSibling;
    if Node<>nil then exit(Node);
    Result:=Result.Parent;
  until Result=nil;
  Result:=nil;
end;

function TWHTextNode.Previous: TWHTextNode;
var
  Node: TWHTextNode;
begin
  Result:=PreviousSibling;
  if Result=nil then
    exit(Parent);
  Node:=Result.LastLeaf;
  if Node<>nil then
    Result:=Node;
end;

function TWHTextNode.LastLeaf: TWHTextNode;
var
  Node: TWHTextNode;
begin
  Result:=LastChild;
  if Result=nil then exit;
  repeat
    Node:=Result.LastChild;
    if Node=nil then exit;
    Result:=Node;
  until false;
end;

function TWHTextNode.Level: integer;
var
  Node: TWHTextNode;
begin
  Result:=0;
  Node:=Parent;
  while Node<>nil do begin
    inc(Result);
    Node:=Node.Parent;
  end;
end;

function TWHTextNode.CalcMemSize: SizeInt;
var
  i: Integer;
begin
  Result:=InstanceSize+SizeInt(MemSizeString(Txt));
  if FChildNodes<>nil then begin
    inc(Result,FChildNodes.InstanceSize+FChildNodes.Count*SizeOf(Pointer));
    for i:=0 to Count-1 do
      inc(Result,ChildNodes[i].CalcMemSize);
  end;
end;

{ TWiki2HelpConverter }

procedure TWiki2HelpConverter.SavePage(Page: TW2XHTMLPage);
begin
  // do not save
end;

function TWiki2HelpConverter.FindImage(const ImgFilename: string): string;
begin
  //Log('AvailableImages='+dbgs(AvailableImages.Tree.Count)+' Img="'+ImgFilename+'"');
  if AvailableImages.Contains(ImgFilename) then
    Result:=ImgFilename
  else
    Result:='';
end;

procedure TWiki2HelpConverter.ExtractTextToken(Token: TWPToken);
var
  Page: TW2HelpPage;
  W: TWikiPage;
  Txt: String;
  CurNode: TWHTextNode;
  StartP, EndP: PChar;
  NodeType: TWHTextNodeType;
  TextToken: TWPTextToken;
  LinkToken: TWPLinkToken;
  Caption: String;
begin
  Page:=TW2HelpPage(Token.UserData);
  W:=Page.WikiPage;
  CurNode:=Page.CurWHNode;
  if CurNode=nil then CurNode:=Page.WHRoot;
  case Token.Token of
  wptText:
    if Token is TWPTextToken then begin
      TextToken:=TWPTextToken(Token);
      StartP:=PChar(W.Src)+TextToken.StartPos-1;
      EndP:=PChar(W.Src)+TextToken.EndPos-1;
      while (StartP<EndP) and (StartP^ in [#1..#31,' ']) do inc(StartP);
      if StartP<EndP then begin
        // not only space
        Txt:=copy(W.Src,TextToken.StartPos,TextToken.EndPos-TextToken.StartPos);
        CurNode.Txt:=CurNode.Txt+Txt;
        exit;
      end;
    end;

  wptSection,wptHeader:
    if Token.Range=wprOpen then begin
      if Token.Token=wptHeader then
        NodeType:=whnHeader
      else
        NodeType:=whnTxt;
      Page.CurWHNode:=TWHTextNode.Create(NodeType,CurNode);
      exit;
    end else if Token.Range=wprClose then begin
      Page.CurWHNode:=CurNode.Parent;
      exit;
    end;

  wptInternLink, wptExternLink:
    if Token is TWPLinkToken then begin
      LinkToken:=TWPLinkToken(Token);
      Caption:=copy(W.Src,LinkToken.CaptionStartPos,
                    LinkToken.CaptionEndPos-LinkToken.CaptionStartPos);
      if Caption<>'' then begin
        CurNode:=TWHTextNode.Create(whnLink,CurNode);
        CurNode.Txt:=Caption;
        // do not exit, append a space to the current node
      end;
    end;
  end;
  // add a space to separate words
  if (CurNode.Txt='') or (not (CurNode.Txt[length(CurNode.Txt)] in [#1..#31,' ']))
  then
    CurNode.Txt:=CurNode.Txt+' ';
end;

procedure TWiki2HelpConverter.ParallelExtractPageText(Index: PtrInt;
  Data: Pointer; Item: TMultiThreadProcItem);
var
  StartIndex, EndIndex: Integer;
  i: Integer;
begin
  StartIndex:=Index*PagesPerThread;
  EndIndex:=Min(StartIndex+PagesPerThread-1,Count-1);
  if Help.Aborting then exit;
  for i:=StartIndex to EndIndex do
    ExtractPageText(TW2HelpPage(Pages[i]));
  Help.EnterCritSect;
  try
    inc(Help.fProgressCount,PagesPerThread);
  finally
    Help.LeaveCritSect;
  end;
end;

procedure TWiki2HelpConverter.ParallelLoadPage(Index: PtrInt; Data: Pointer;
  Item: TMultiThreadProcItem);
var
  Page: TW2HelpPage;
  StartIndex, EndIndex: Integer;
  i: Integer;
begin
  StartIndex:=Index*PagesPerThread;
  EndIndex:=Min(StartIndex+PagesPerThread-1,Count-1);
  for i:=StartIndex to EndIndex do begin
    if Help.Aborting then exit;
    Page:=TW2HelpPage(Pages[i]);
    try
      Page.ParseWikiDoc(false);
    except
      on E: Exception do begin
        Log('ERROR: '+Page.WikiFilename+': '+E.Message);
      end;
    end;
  end;
  Help.EnterCritSect;
  try
    inc(Help.fProgressCount,PagesPerThread);
  finally
    Help.LeaveCritSect;
  end;
end;

procedure TWiki2HelpConverter.ParallelComputeScores(Index: PtrInt;
  Data: Pointer; Item: TMultiThreadProcItem);
var
  StartIndex, EndIndex: Integer;
  i: Integer;
  Page: TW2HelpPage;
begin
  StartIndex:=Index*PagesPerThread;
  EndIndex:=Min(StartIndex+PagesPerThread-1,Count-1);
  if Help.Aborting then exit;
  for i:=StartIndex to EndIndex do begin
    Page:=TW2HelpPage(Pages[i]);
    Page.Score:=Page.GetScore(FCurQuery);
  end;
  Help.EnterCritSect;
  try
    inc(Help.fProgressCount,PagesPerThread);
  finally
    Help.LeaveCritSect;
  end;
end;

procedure TWiki2HelpConverter.ExtractPageText(Page: TW2HelpPage);
begin
  FreeAndNil(Page.WHRoot);
  Page.WHRoot:=TWHTextNode.Create(whnTxt,nil);
  try
    Page.CurWHNode:=Page.WHRoot;
    if Page.WikiPage<>nil then
      Page.WikiPage.Parse(@ExtractTextToken,Page);
  finally
    Page.CurWHNode:=nil;
  end;
end;

procedure TWiki2HelpConverter.ConvertInit;
var
  FileInfo: TSearchRec;
begin
  inherited ConvertInit;

  //Log('ImagesDir='+ImagesDir);
  AvailableImages.Clear;
  if FindFirstUTF8(ImagesDir+AllFilesMask,faAnyFile,FileInfo)=0 then begin
    repeat
      if (FileInfo.Name='') or (FileInfo.Name='.') or (FileInfo.Name='..') then
        continue;
      AvailableImages[FileInfo.Name]:='1';
    until FindNextUTF8(FileInfo)<>0;
  end;
  FindCloseUTF8(FileInfo);
  Log('Found '+IntToStr(AvailableImages.Tree.Count)+' wiki images in "'+ImagesDir+'"');
end;

procedure TWiki2HelpConverter.ExtractAllTexts;
begin
  Help.EnterCritSect;
  try
    Help.fProgressStep:=whpsWikiExtractPageTexts;
    Help.fProgressCount:=0;
    Help.fProgressMax:=Count;
  finally
    Help.LeaveCritSect;
  end;
  ProcThreadPool.DoParallel(@ParallelExtractPageText,0,(Count-1) div PagesPerThread);
end;

procedure TWiki2HelpConverter.Search(Query: TWikiHelpQuery;
  var FoundPages: TFPList);
var
  i: Integer;
  Page: TW2HelpPage;
begin
  Help.EnterCritSect;
  try
    Help.fProgressStep:=whpsWikiSearch;
    Help.fProgressCount:=0;
    Help.fProgressMax:=Count;
  finally
    Help.LeaveCritSect;
  end;
  FCurQuery:=Query;
  if FoundPages=nil then
    FoundPages:=TFPList.Create;
  ProcThreadPool.DoParallel(@ParallelComputeScores,0,(Count-1) div PagesPerThread);
  for i:=0 to Count-1 do begin
    Page:=TW2HelpPage(Pages[i]);
    if Page.Score<=0 then continue;
    FoundPages.Add(Page);
  end;
  FoundPages.Sort(@CompareW2HPageForScore);
end;

procedure TWiki2HelpConverter.SavePageAsHTMLToStream(Page: TW2HelpPage;
  aStream: TStream);
begin
  ConvertPage(Page);
  SavePageToStream(Page,aStream);
  Page.ClearConversion;
end;

function TWiki2HelpConverter.PageToFilename(Page: string; IsInternalLink,
  Full: boolean): string;
begin
  Result:=WikiPageToFilename(Page,IsInternalLink,false);
end;

function TWiki2HelpConverter.PageToFilename(Page: TW2XHTMLPage; Full: boolean
  ): string;
begin
  Result:=Page.WikiDocumentName;
end;

procedure TWiki2HelpConverter.LoadPages;
begin
  Help.EnterCritSect;
  try
    Help.fProgressStep:=whpsWikiLoadPages;
    Help.fProgressCount:=0;
    Help.fProgressMax:=Count;
  finally
    Help.LeaveCritSect;
  end;
  ProcThreadPool.DoParallel(@ParallelLoadPage,0,(Count-1) div PagesPerThread);
end;

constructor TWiki2HelpConverter.Create;
begin
  inherited Create;
  AvailableImages:=TFilenameToStringTree.Create(true);
  fPageClass:=TW2HelpPage;
  PagesPerThread:=100;
end;

procedure TWiki2HelpConverter.Clear;
begin
  inherited Clear;
  AvailableImages.Clear;
end;

destructor TWiki2HelpConverter.Destroy;
begin
  inherited Destroy;
  FreeAndNil(AvailableImages);
end;

{ TWikiHelpThread }

procedure TWikiHelpThread.Execute;
var
  FileInfo: TSearchRec;
  Files: TStringList;
  i: Integer;
  Filename: String;
  StartTime: TDateTime;
  EndTime: TDateTime;
begin
  try
    Files:=nil;
    try
      StartTime:=Now;
      Log('TWikiHelpThread.Execute START XMLDirectory="'+Help.XMLDirectory+'"');

      Files:=TStringList.Create;
      try
        Help.Converter.OnLog:=@ConverterLog;
        // get all wiki xml files
        if FindFirstUTF8(Help.XMLDirectory+AllFilesMask,faAnyFile,FileInfo)=0 then begin
          repeat
            if CompareFileExt(FileInfo.Name,'.xml',false)<>0 then continue;
            Files.Add(FileInfo.Name);
          until FindNextUTF8(FileInfo)<>0;
        end;
        FindCloseUTF8(FileInfo);

        // add file names to converter
        for i:=0 to Files.Count-1 do begin
          Filename:=Help.XMLDirectory+Files[i];
          Help.Converter.AddWikiPage(Filename,false);
        end;
        if Help.Aborting then exit;

        // load xml files
        Help.Converter.LoadPages;
        if Help.Aborting then exit;

        // extract texts
        Help.Converter.ConvertInit;
        if Help.Aborting then exit;
        Help.Converter.ExtractAllTexts;
        if Help.Aborting then exit;

        fCompleted:=true;
        EndTime:=Now;
        Help.fWikiLoadTimeMSec:=round(Abs(EndTime-StartTime)*86400000);
        Log('TWikiHelpThread.Execute SCAN complete XMLDirectory="'+Help.XMLDirectory+'" '+dbgs(Help.fWikiLoadTimeMSec)+'msec');
      finally
        Files.Free;
        Help.Converter.OnLog:=nil;
      end;
    except
      on E: Exception do begin
        Log('TWikiHelpThread.Execute error: '+E.Message);
      end;
    end;
  finally
    Scanned;
  end;
end;

procedure TWikiHelpThread.MainThreadLog;
// called in main thread
begin
  DebugLn(fLogMsg);
end;

procedure TWikiHelpThread.Log(Msg: string);
begin
  fLogMsg:=Msg;
  CurrentThread.Synchronize(@MainThreadLog);
end;

procedure TWikiHelpThread.ConverterLog(Msg: string);
begin
  {$IFDEF VerboseWikiHelp}
  Log(Msg);
  {$ENDIF}
end;

procedure TWikiHelpThread.Scanned;
// called in this thread
begin
  Help.EnterCritSect;
  try
    Help.FScanThread:=nil;
    if fCompleted then
      Help.fProgressStep:=whpsWikiLoadComplete
    else
      Help.fProgressStep:=whpsNone;
  finally
    Help.LeaveCritSect;
  end;
  Synchronize(@Help.Scanned);
end;

{ TWikiHelp }

procedure TWikiHelp.SetImagesDirectory(AValue: string);
var
  NewDir: String;
begin
  NewDir:=TrimAndExpandDirectory(TrimFilename(AValue));
  if Converter.ImagesDir=NewDir then Exit;
  AbortLoading(true);
  Converter.ImagesDir:=NewDir;
end;

procedure TWikiHelp.SetMaxResults(AValue: integer);
begin
  if FMaxResults=AValue then Exit;
  FMaxResults:=AValue;
end;

procedure TWikiHelp.SetQuery(AValue: TWikiHelpQuery);
begin
  if FQuery=AValue then Exit;
  FQuery:=AValue;
end;

function TWikiHelp.GetImagesDirectory: string;
begin
  Result:=Converter.ImagesDir;
end;

procedure TWikiHelp.SetXMLDirectory(AValue: string);
var
  NewDir: String;
begin
  NewDir:=TrimAndExpandDirectory(TrimFilename(AValue));
  if FXMLDirectory=NewDir then Exit;
  AbortLoading(true);
  FXMLDirectory:=NewDir;
end;

procedure TWikiHelp.EnterCritSect;
begin
  EnterCriticalsection(FCritSec);
end;

procedure TWikiHelp.LeaveCritSect;
begin
  LeaveCriticalsection(FCritSec);
end;

procedure TWikiHelp.Scanned;
begin
  if Assigned(OnScanned) then
    OnScanned(Self);
  DoSearch;
end;

procedure TWikiHelp.DoSearch;
var
  StartTime: TDateTime;
  EndTime: TDateTime;
  FoundPages: TFPList;
  i: Integer;
  Page: TW2HelpPage;
  Node: TWHTextNode;
  s: String;
  HTML: String;
begin
  FResultsHTML:='';
  if (Query=nil) or (Query.Phrases.Count=0) then begin
    EnterCritSect;
    try
      fProgressStep:=whpsWikiLoadComplete;
    finally
      LeaveCritSect;
    end;
  end else begin
    StartTime:=Now;
    //debugln(['TWikiHelp.DoSearch START Search=',Trim(Query.Phrases.Text),' Lang="',Query.Languages,'"']);
    FoundPages:=nil;
    Converter.Search(Query,FoundPages);
    HTML:='<html>'+LineEnding
         +'<head>'+LineEnding
         +' <meta content="text/html; charset=utf-8" http-equiv="Content-Type">'+LineEnding;
    if ResultsCSSURL<>'' then
    HTML+=' <link href="'+ResultsCSSURL+'" type="text/css" rel="stylesheet">'+LineEnding;
    HTML+='</head>'+LineEnding
         +'<body>'+LineEnding;
    for i:=0 to Min(FoundPages.Count-1,MaxResults) do begin
      Page:=TW2HelpPage(FoundPages[i]);
      //debugln(['TWikiHelp.DoSearch ',Page.WikiDocumentName,' ',Page.WikiLanguage,' ',WikiPageHasLanguage(Page.WikiDocumentName,Query.Languages)]);
      Node:=Page.GetNodeHighestScore(Query);
      s:='<div class="wikiSearchResultItem">'+FoundNodeToHTMLSnippet(Page,Node,Query)+'</div>'+LineEnding;
      //debugln(['TWikiHelp.TestSearch Score=',Page.Score,' HTML="',s,'"']);
      HTML+=s;
    end;
    HTML+='</body>'+LineEnding
         +'</html>'+LineEnding;
    FResultsHTML:=HTML;
    FoundPages.Free;
    EndTime:=Now;
    fWikiSearchTimeMSec:=round(Abs(EndTime-StartTime)*86400000);
    EnterCritSect;
    try
      fProgressStep:=whpsWikiSearchComplete;
    finally
      LeaveCritSect;
    end;
    //debugln(['TWikiHelp.DoSearch END Search="',Trim(Query.Phrases.Text),'" ',dbgs(fWikiSearchTimeMSec)+'msec']);
  end;
  if Assigned(OnSearched) then
    OnSearched(Self);
end;

function TWikiHelp.FoundNodeToHTMLSnippet(aPage: TW2HelpPage;
  aNode: TWHTextNode; aQuery: TWikiHelpQuery): string;
var
  HeaderNode: TWHTextNode;
begin
  // link to the page
  Result:='<a href="'+StrToXMLValue(aPage.WikiDocumentName)+'"'
    +' class="wikiLinkPage"'
    +' alt="'+StrToXMLValue(aPage.WikiPage.Title)+'"'
    +'>'
    +TextToHTMLSnipped(aPage.WikiPage.Title,aQuery.LoPhrases,200)+'</a><br>'+LineEnding;
  if aNode=nil then begin
    // get the first node with some text
    aNode:=aPage.WHRoot;
    while (aNode<>nil) and (UTF8Trim(aNode.Txt)='') do
      aNode:=aNode.Next;
  end;
  if aNode<>nil then begin
    //debugln(['TWikiHelp.FoundNodeToHTMLSnippet ',dbgs(aNode.Typ),' Txt="'+dbgstr(ANode.Txt)+'"']);
    HeaderNode:=aNode;
    while (HeaderNode<>nil) and (HeaderNode.Typ<>whnHeader) do
      HeaderNode:=HeaderNode.Previous;
    if aNode=HeaderNode then begin
      // get the first node after the header with some text
      repeat
        aNode:=aNode.Next;
      until (aNode=nil) or (UTF8Trim(aNode.Txt)<>'');
    end;
    if HeaderNode<>nil then begin
      // add a direct link to the sub topic
      Result+='Topic <a href="'+StrToXMLValue(aPage.WikiDocumentName+'#'+WikiHeaderToLink(HeaderNode.Txt))+'"'
        +' class="wikiLinkTopic"'
        +' alt="'+StrToXMLValue(HeaderNode.Txt)+'"'
        +'>'
        +TextToHTMLSnipped(HeaderNode.Txt,aQuery.LoPhrases,200)+'</a>: ';
    end;
    if aNode<>nil then begin
      // add text
      Result+=TextToHTMLSnipped(aNode.Txt,aQuery.LoPhrases,200);
    end;
  end;
end;

constructor TWikiHelp.Create(AOwner: TComponent);
begin
  InitCriticalSection(FCritSec);
  inherited Create(AOwner);
  FConverter:=TWiki2HelpConverter.Create;
  FConverter.CodeTags:=WikiCreateCommonCodeTagList(true);
  FConverter.FHelp:=Self;
  FDefaultScoring:=TWHScoring.Create;
  with FDefaultScoring do begin
    Phrases[whfcPageTitle,whfsWholeWord]:=128;
    Phrases[whfcPageTitle,whfsPart]:=64;
    Phrases[whfcHeader,whfsWholeWord]:=32;
    Phrases[whfcHeader,whfsPart]:=16;
    Phrases[whfcText,whfsWholeWord]:=8;
    Phrases[whfcText,whfsPart]:=4;
    Phrases[whfcLink,whfsWholeWord]:=2;
    Phrases[whfcLink,whfsPart]:=1;
  end;
  FMaxResults:=10;
  fProgressStep:=whpsNone;
end;

destructor TWikiHelp.Destroy;
begin
  AbortLoading(true);
  FConverter.CodeTags.Free;
  FreeAndNil(FConverter);
  FreeAndNil(FDefaultScoring);
  FreeAndNil(FQuery);
  inherited Destroy;
  DoneCriticalsection(FCritSec);
end;

procedure TWikiHelp.StartLoading;
begin
  if not DirPathExists(XMLDirectory) then
    raise Exception.Create('TWikiHelp.StartScan XMLDirectory not found: '+XMLDirectory);
  if not DirPathExists(ImagesDirectory) then
    raise Exception.Create('TWikiHelp.StartScan ImagesDirectory not found: '+ImagesDirectory);
  EnterCritSect;
  try
    if fProgressStep>whpsNone then exit;
    fProgressStep:=whpsWikiScanDir;
    fWikiLoadTimeMSec:=0;
    fProgressCount:=0;
    fProgressMax:=0;
    FScanThread:=TWikiHelpThread.Create(true);
    FScanThread.FreeOnTerminate:=true;
    FScanThread.Help:=Self;
    FScanThread.Start;
  finally
    LeaveCritSect;
  end;
end;

function TWikiHelp.LoadingContent: boolean;
begin
  Result:=(fProgressStep>whpsNone) and (fProgressStep<whpsWikiLoadComplete);
end;

procedure TWikiHelp.AbortLoading(Wait: boolean);
begin
  EnterCritSect;
  try
    if not LoadingContent then exit;
    FAborting:=true;
  finally
    LeaveCritSect;
  end;
  if not Wait then exit;
  while LoadingContent do
    Sleep(10);
  EnterCritSect;
  try
    FAborting:=false;
  finally
    LeaveCritSect;
  end;
end;

function TWikiHelp.LoadComplete: boolean;
begin
  Result:=(fProgressStep>=whpsWikiLoadComplete);
end;

function TWikiHelp.CollectAllLanguages(AsCaption: boolean): TStrings;

  procedure Add(Code: string);
  begin
    if AsCaption then
      Code:=WikiLangCodeToCaption(Code);
    CollectAllLanguages.Add(Code);
  end;

var
  Codes: String;
  p: SizeInt;
  Code: String;
begin
  Result:=TStringList.Create;
  Add('');
  if LoadComplete then begin
    Codes:=Converter.CollectAllLangCodes(';')+';';
    repeat
      p:=Pos(';',Codes);
      if p<1 then p:=length(Codes)+1;
      Code:=LeftStr(Codes,p-1);
      Delete(Codes,1,p);
      if Code<>'' then
        Add(Code);
    until Codes='';
  end;
end;

function TWikiHelp.GetProgressCaption: string;
begin
  EnterCritSect;
  try
    case fProgressStep of
    whpsNone: Result:='Wiki not yet loaded.';
    whpsWikiScanDir: Result:='Scanning Wiki directory ...';
    whpsWikiLoadPages: Result:='Loaded '+IntToStr(fProgressCount)+' of '+IntToStr(fProgressMax)+' Wiki pages.';
    whpsWikiExtractPageTexts: Result:='Read '+IntToStr(fProgressCount)+' of '+IntToStr(fProgressMax)+' Wiki pages.';
    whpsWikiLoadComplete: Result:='Loaded '+IntToStr(Converter.Count)+' Wiki pages in '+IntToStr(fWikiLoadTimeMSec)+'msec.';
    whpsWikiSearch: Result:='Searched '+IntToStr(fProgressCount)+' of '+IntToStr(fProgressMax)+' Wiki pages.';
    whpsWikiSearchComplete: Result:='Searched '+IntToStr(Converter.Count)+' Wiki pages in '+IntToStr(fWikiSearchTimeMSec)+'msec.';
    else Result:='unknown step: '+IntToStr(ord(fProgressStep));
    end;
  finally
    LeaveCritSect;
  end;
end;

function TWikiHelp.Busy: boolean;
begin
  Result:=not (fProgressStep in [whpsWikiLoadComplete,whpsWikiSearchComplete]);
end;

procedure TWikiHelp.Search(const Term: string; const Languages: string;
  Scoring: TWHScoring; FreeScoring: boolean);
var
  aQuery: TWikiHelpQuery;
begin
  if Scoring=nil then Scoring:=DefaultScoring;
  aQuery:=TWikiHelpQuery.Create(Term,Languages,
    Scoring,FreeScoring and (Scoring<>DefaultScoring));
  try
    Search(aQuery);
  finally
    aQuery.Free;
  end;
end;

procedure TWikiHelp.Search(aQuery: TWikiHelpQuery);
begin
  EnterCritSect;
  try
    if aQuery=nil then exit;
    if FQuery=nil then
      // first query
      FQuery:=TWikiHelpQuery.Clone(aQuery)
    else if FQuery.Equals(aQuery) then begin
      // same query
      //debugln(['TWikiHelp.Search same query ',FQuery=aQuery,' ',FQuery.Scoring.Equals(aQuery.Scoring),' fquery.scoring=',FQuery.Scoring.Phrases[whfcPageTitle,whfsWholeWord],' aquery.scoring=',aQuery.Scoring.Phrases[whfcPageTitle,whfsWholeWord]]);
      exit;
    end else
      FQuery.Assign(aQuery);
    if LoadingContent then exit;
  finally
    LeaveCritSect;
  end;
  //debugln(['TWikiHelp.Search searching']);
  DoSearch;
end;

procedure TWikiHelp.SavePageToStream(DocumentName: string; aStream: TStream);
var
  Page: TW2HelpPage;
begin
  Page:=TW2HelpPage(Converter.GetPageWithDocumentName(DocumentName));
  if Page=nil then
    raise Exception.Create('document "'+DocumentName+'" not found in wiki');
  Converter.SavePageAsHTMLToStream(Page,aStream);
end;

end.

