unit ChmLangRef;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, chmreader, chmsitemap,
  Dialogs, LazHelpIntf, HelpIntfs,
  FileUtil, LazFileUtils, LazStringUtils, LazUTF8,
  IDEHelpIntf, MacroIntf;

const
  sFPCLangRef = 'FPC Language Reference';

type

  { TLangRefHelpDatabase }

  TLangRefHelpDatabase = class(THelpDatabase)
  private
    FCHMSearchPath: string;
    FKeywordNodes: TList;
    FKeyWordsList: TStringListUTF8Fast;
    FRTLIndex: TStringList;
    procedure ClearKeywordNodes;
    procedure LoadChmIndex(const Path, ChmFileName: string;
      IndexStrings: TStrings; const Filter: string = '');
  public
    constructor Create(TheOwner: TComponent); override;
    destructor Destroy; override;
    procedure LoadKeywordList(const Path: string);
    function GetNodesForKeyword(const HelpKeyword: string;
      var ListOfNodes: THelpNodeQueryList; var ErrMsg: string
      ): TShowHelpResult; override;
    function ShowHelp(Query: THelpQuery; {%H-}BaseNode, NewNode: THelpNode;
      {%H-}QueryItem: THelpQueryItem;
      var ErrMsg: string): TShowHelpResult; override;
    property CHMSearchPath: string read FCHMSearchPath write FCHMSearchPath;
  end;

procedure RegisterLangRefHelpDatabase;

var
  LangRefHelpDatabase: TLangRefHelpDatabase = nil;

implementation

procedure RegisterLangRefHelpDatabase;
begin
  if not Assigned(LangRefHelpDatabase) then
    LangRefHelpDatabase := TLangRefHelpDatabase(HelpDatabases.CreateHelpDatabase(sFPCLangRef,
    TLangRefHelpDatabase, true));
end;

{ TLangRefHelpDatabase }

procedure TLangRefHelpDatabase.ClearKeywordNodes;
var
  i: Integer;
begin
  for i := 0 to FKeywordNodes.Count - 1 do
    TObject(FKeywordNodes[i]).Free;
  FKeywordNodes.Clear;
end;

constructor TLangRefHelpDatabase.Create(TheOwner: TComponent);
begin
  inherited Create(TheOwner);
  FKeywordNodes := TList.Create;
  FKeyWordsList := TStringListUTF8Fast.Create;
  FKeyWordsList.CaseSensitive := False;
  FRTLIndex := TStringList.Create;
  FRTLIndex.CaseSensitive := False;
end;

destructor TLangRefHelpDatabase.Destroy;
begin
  ClearKeywordNodes;
  FKeywordNodes.Free;
  FKeyWordsList.Free;
  FRTLIndex.Free;
  inherited Destroy;
end;

procedure TLangRefHelpDatabase.LoadKeywordList(const Path: string);
begin
  FRTLIndex.Clear; // Path has been changed
  LoadChmIndex(Path, 'ref.chm', FKeyWordsList);
end;

procedure TLangRefHelpDatabase.LoadChmIndex(const Path, ChmFileName: string;
  IndexStrings: TStrings; const Filter: string = '');
var
  chm: TChmFileList;
  fchm: TChmReader;
  SM: TChmSiteMap;
  X, Y: Integer;
  s: string;
  Filename: String;
  SMItem: TChmSiteMapItem;
begin
  fCHMSearchPath := Path;
  if fCHMSearchPath = '' then
  begin
    fCHMSearchPath := '$(LazarusDir)/docs/chm;$(LazarusDir)/docs/html';
    IDEMacros.SubstituteMacros(fCHMSearchPath);
    fCHMSearchPath := MinimizeSearchPath(GetForcedPathDelims(fCHMSearchPath));
  end;
  Filename:=SearchFileInPath(ChmFileName,'',fCHMSearchPath,';',[]);

  IndexStrings.Clear;
  if (Filename<>'') then
  begin
    chm := TChmFileList.Create(Utf8ToSys(Filename));
    try
      if chm.Count = 0 then Exit;
      fchm := chm.Chm[0];
      SM := fChm.GetIndexSitemap;
      if SM <> nil then
      begin
        for X := 0 to SM.Items.Count - 1 do
        begin
          SMItem:=SM.Items.Item[X];
          {$IF FPC_Fullversion>30100}
          s := SMItem.Name;
          {$ELSE}
          s := SMItem.Text;
          {$ENDIF}
          if SMItem.Children.Count = 0 then
          begin
            if (SMItem.Local<>'')
                and ((Filter = '') or (Pos(Filter, SMItem.Local) > 0)) then
              IndexStrings.Add(s + '=' + SMItem.Local)
          end else begin
            with SMItem.Children do
              for Y := 0 to Count - 1 do
              begin
                if (Item[Y].Local<>'')
                and ((Filter = '') or (Pos(Filter, Item[Y].Local) > 0)) then
                  IndexStrings.Add(s + '=' + Item[Y].Local)
              end;
          end;
          {$IF FPC_Fullversion>30100}
          for Y:=0 to SMItem.SubItemcount-1 do begin
            if (SMItem.SubItem[Y].Local<>'')
            and ((Filter = '') or (Pos(Filter, SMItem.SubItem[Y].Local) > 0)) then
              IndexStrings.Add(s + '=' + SMItem.SubItem[Y].Local)
          end;
          {$ENDIF}
        end;
        SM.Free;
      end;
      fchm.Free;
    finally
      chm.Free;
    end;
  end;
end;

function TLangRefHelpDatabase.GetNodesForKeyword(const HelpKeyword: string;
  var ListOfNodes: THelpNodeQueryList; var ErrMsg: string): TShowHelpResult;
var
  KeyWord, s: String;
  i, n: Integer;
  KeywordNode: THelpNode;
begin
  Result := shrHelpNotFound;
  if (csDesigning in ComponentState) then Exit;
  if (FPCKeyWordHelpPrefix<>'')
  and (LeftStr(HelpKeyword,length(FPCKeyWordHelpPrefix))=FPCKeyWordHelpPrefix) then
  begin
    if FKeyWordsList.Count = 0 then LoadKeywordList(fCHMSearchPath);
    if FKeyWordsList.Count = 0 then
    begin
      Result := shrDatabaseNotFound;
      ErrMsg := Format('ref.chm not found. Please put ref.chm help file in '+ LineEnding
        + '%s' +  LineEnding
        +'or set the path to it with "HelpFilesPath" in '
        +' Environment Options -> Help -> Help Options ->' + LineEnding
        +'under Viewers - CHM Help Viewer', [fCHMSearchPath]);
      Exit;
    end;
    // HelpKeyword starts with KeywordPrefix
    KeyWord := Copy(HelpKeyword, Length(FPCKeyWordHelpPrefix) + 1, Length(HelpKeyword));
    ClearKeywordNodes;
    n := 0;
    for i := 0 to FKeyWordsList.Count - 1 do
    begin
      if SameText(FKeyWordsList.Names[i], KeyWord) then
      begin
        Inc(n);
        KeywordNode := THelpNode.CreateURL(Self,KeyWord,'ref.chm://' + FKeyWordsList.ValueFromIndex[i]);
        KeywordNode.Title := Format('Pascal keyword "%s"', [KeyWord]);
        if n > 1 then
          KeywordNode.Title := KeywordNode.Title + ' (' + IntToStr(n) + ')';
        FKeywordNodes.Add(KeywordNode);
        CreateNodeQueryListAndAdd(KeywordNode,nil,ListOfNodes,true);
        Result := shrSuccess;
      end;
    end;
    if (Result = shrSuccess) and (SameText(KeyWord, 'for') or SameText(KeyWord, 'in')) then
    begin  { for => +forin, in => +forin }
      i := FKeyWordsList.IndexOfName('forin');
      if i < 0 then Exit;
      KeywordNode := THelpNode.CreateURL(Self,KeyWord,'ref.chm://' + FKeyWordsList.ValueFromIndex[i]);
      KeywordNode.Title := Format('Pascal keyword "%s"', ['for..in']);
      FKeywordNodes.Add(KeywordNode);
      CreateNodeQueryListAndAdd(KeywordNode, nil, ListOfNodes, True);
    end;
    if Result <> shrSuccess then
    begin
      { it can be predefined procedure/function from RTL }
      if FRTLIndex.Count = 0 then
        LoadChmIndex(FCHMSearchPath, 'rtl.chm', FRTLIndex, 'system/');
      for i := 0 to FRTLIndex.Count - 1 do
      begin
        s := FRTLIndex.Names[i];
        if LazStartsText(KeyWord, s) and
          ((Length(s) = Length(KeyWord)) or (s[Length(KeyWord) + 1] = ' ')) then
        begin
          KeywordNode := THelpNode.CreateURL(Self,KeyWord,'rtl.chm://' + FRTLIndex.ValueFromIndex[i]);
          KeywordNode.Title := Format('RTL - Free Pascal Run Time Library: "%s"', [KeyWord]);
          FKeywordNodes.Add(KeywordNode);
          CreateNodeQueryListAndAdd(KeywordNode, nil, ListOfNodes, True);
          Exit(shrSuccess); // only first match
        end;
      end;
    end;
  end;
end;

function TLangRefHelpDatabase.ShowHelp(Query: THelpQuery; BaseNode,
  NewNode: THelpNode; QueryItem: THelpQueryItem; var ErrMsg: string
  ): TShowHelpResult;
var
  Viewer: THelpViewer;
begin
  Result:=shrHelpNotFound;
  if not (Query is THelpQueryKeyword) then exit;
  Result := FindViewer('text/html', ErrMsg, Viewer);
  if Result <> shrSuccess then Exit;
  Result := Viewer.ShowNode(NewNode, ErrMsg);
end;

end.

