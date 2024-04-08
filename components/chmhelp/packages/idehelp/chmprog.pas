unit ChmProg;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, chmreader, chmFiftiMain,
  Dialogs,
  FileUtil, LazFileUtils, LazUTF8, LazLoggerBase, LazStringUtils,
  LazHelpIntf, HelpIntfs,
  IDEHelpIntf, MacroIntf;

const
  sFPCCompilerDirectives = 'FreePascal Compiler directives';

type

  { TFPCDirectivesHelpDatabase }

  TFPCDirectivesHelpDatabase = class(THelpDatabase)
  private
    FCHMSearchPath: string;
    FDirectiveNodes: TFPList;
    function SearchForDirective(const ADirective: string;
      var ListOfNodes: THelpNodeQueryList): Boolean;
    procedure ClearDirectiveNodes;
  public
    constructor Create(TheOwner: TComponent); override;
    destructor Destroy; override;
    function GetNodesForDirective(const HelpDirective: string;
      var ListOfNodes: THelpNodeQueryList;
      var ErrMsg: string): TShowHelpResult; override;
    function ShowHelp(Query: THelpQuery; {%H-}BaseNode, NewNode: THelpNode;
      {%H-}QueryItem: THelpQueryItem;
      var ErrMsg: string): TShowHelpResult; override;
    function GetCHMSearchPath: string;
    property CHMSearchPath: string read FCHMSearchPath write FCHMSearchPath;
    function FindCHMFile: string;
  end;

procedure RegisterFPCDirectivesHelpDatabase;

var
  FPCDirectivesHelpDatabase: TFPCDirectivesHelpDatabase = nil;

implementation

procedure RegisterFPCDirectivesHelpDatabase;
begin
  if not Assigned(FPCDirectivesHelpDatabase) then
    FPCDirectivesHelpDatabase :=
      TFPCDirectivesHelpDatabase(HelpDatabases.CreateHelpDatabase(
      sFPCCompilerDirectives, TFPCDirectivesHelpDatabase, true));
end;

{ TFPCDirectivesHelpDatabase }

function TFPCDirectivesHelpDatabase.SearchForDirective(const ADirective: string;
  var ListOfNodes: THelpNodeQueryList): Boolean;
var
  chm: TChmFileList;
  fchm: TChmReader;
  DocTitle, URL, Filename: string;
  ms: TMemoryStream;
  SearchReader: TChmSearchReader;
  TitleResults: TChmWLCTopicArray;
  i, k: Integer;
  DirectiveNode: THelpNode;
begin
  Result := False;
  Filename:=FindCHMFile;
  if Filename='' then exit;

  chm := TChmFileList.Create(Utf8ToSys(Filename));
  try
    if chm.Count = 0 then Exit;
    fchm := chm.Chm[0];

    if fchm.SearchReader = nil then
    begin
      ms := fchm.GetObject('/$FIftiMain');
      if ms = nil then Exit;
      SearchReader := TChmSearchReader.Create(ms, True); //frees the stream when done
      fchm.SearchReader := SearchReader;
    end
    else
      SearchReader := fchm.SearchReader;
    SearchReader.LookupWord(Copy(ADirective, 2, MaxInt), TitleResults);
    for k := 0 to High(TitleResults) do
    begin
      URL := fchm.LookupTopicByID(TitleResults[k].TopicIndex, DocTitle);
      i := PosI(ADirective, DocTitle);
      if i = 0 then Continue;
      if Length(DocTitle) = i+Length(ADirective)-1 then Continue;
      if DocTitle[i+Length(ADirective)] in ['A'..'Z','a'..'z','0'..'9'] then Continue;
      if (Length(URL) > 0) and (URL[1] = '/') then
        Delete(URL, 1, 1);
      if URL = '' then Continue;
      DirectiveNode := THelpNode.CreateURL(Self, ADirective, 'prog.chm://' + URL);
      DirectiveNode.Title := 'FPC directives: ' + DocTitle;
      CreateNodeQueryListAndAdd(DirectiveNode, nil, ListOfNodes, True);
      FDirectiveNodes.Add(DirectiveNode);
      Result := True;
    end;

    fchm.Free;
  finally
    chm.Free;
  end;
end;

procedure TFPCDirectivesHelpDatabase.ClearDirectiveNodes;
var i: Integer;
begin
  for i := 0 to FDirectiveNodes.Count - 1 do
    TObject(FDirectiveNodes[i]).Free;
  FDirectiveNodes.Clear;
end;

constructor TFPCDirectivesHelpDatabase.Create(TheOwner: TComponent);
begin
  inherited Create(TheOwner);
  FDirectiveNodes := TFPList.Create;
end;

destructor TFPCDirectivesHelpDatabase.Destroy;
begin
  ClearDirectiveNodes;
  FDirectiveNodes.Free;
  inherited Destroy;
end;

function TFPCDirectivesHelpDatabase.GetNodesForDirective(
  const HelpDirective: string; var ListOfNodes: THelpNodeQueryList;
  var ErrMsg: string): TShowHelpResult;
var
  Directive: String;
  Filename: String;
begin
  Result := shrHelpNotFound;
  if (csDesigning in ComponentState) then Exit;
  if (FPCDirectiveHelpPrefix<>'') and
    (LeftStr(HelpDirective, Length(FPCDirectiveHelpPrefix)) = FPCDirectiveHelpPrefix) then
  begin
    Filename:=FindCHMFile;
    debugln(['TFPCDirectivesHelpDatabase.GetNodesForDirective ',Filename]);
    if (Filename='') then
    begin
      Result := shrDatabaseNotFound;
      ErrMsg := Format('prog.chm not found. Please put prog.chm help file in '+ LineEnding
        + '%s' +  LineEnding
        +'or set the path to it with "HelpFilesPath" in '
        +' Environment Options -> Help -> Help Options ->' + LineEnding
        +'under Viewers - CHM Help Viewer', [FCHMSearchPath]);
      Exit;
    end;
    // HelpDirective starts with DirectivePrefix
    Directive := Copy(HelpDirective, Length(FPCDirectiveHelpPrefix) + 1, Length(HelpDirective));
    ClearDirectiveNodes;
    if SearchForDirective(Directive, ListOfNodes) then
      Result := shrSuccess;
  end;
end;

function TFPCDirectivesHelpDatabase.ShowHelp(Query: THelpQuery; BaseNode,
  NewNode: THelpNode; QueryItem: THelpQueryItem; var ErrMsg: string
  ): TShowHelpResult;
var
  Viewer: THelpViewer;
begin
  Result:=shrHelpNotFound;
  if not (Query is THelpQueryDirective) then exit;
  Result := FindViewer('text/html', ErrMsg, Viewer);
  if Result <> shrSuccess then Exit;
  Result := Viewer.ShowNode(NewNode, ErrMsg);
end;

function TFPCDirectivesHelpDatabase.GetCHMSearchPath: string;
begin
  Result:=FCHMSearchPath;
  if Result='' then
  begin
    Result := '$(LazarusDir)/docs/chm;$(LazarusDir)/docs/html';
    IDEMacros.SubstituteMacros(Result);
    Result:=MinimizeSearchPath(GetForcedPathDelims(Result));
  end;
end;

function TFPCDirectivesHelpDatabase.FindCHMFile: string;
begin
  Result:=SearchFileInPath('prog.chm','',GetCHMSearchPath,';',[]);
end;

end.

