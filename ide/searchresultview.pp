{
 /***************************************************************************
                       searchresultviewView.pp - SearchResult view
                       -------------------------------------------
                   TSearchResultsView is responsible for displaying the
                   Search Results of a find operation.


                   Initial Revision  : Sat Nov 8th 2003


 ***************************************************************************/

 ***************************************************************************
 *                                                                         *
 *   This source is free software; you can redistribute it and/or modify   *
 *   it under the terms of the GNU General Public License as published by  *
 *   the Free Software Foundation; either version 2 of the License, or     *
 *   (at your option) any later version.                                   *
 *                                                                         *
 *   This code is distributed in the hope that it will be useful, but      *
 *   WITHOUT ANY WARRANTY; without even the implied warranty of            *
 *   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU     *
 *   General Public License for more details.                              *
 *                                                                         *
 *   A copy of the GNU General Public License is available on the World    *
 *   Wide Web at <http://www.gnu.org/copyleft/gpl.html>. You can also      *
 *   obtain it by writing to the Free Software Foundation,                 *
 *   Inc., 51 Franklin Street - Fifth Floor, Boston, MA 02110-1335, USA.   *
 *                                                                         *
 ***************************************************************************
}
unit SearchResultView;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Math, StrUtils, Laz_AVL_Tree,
  // LCL
  LCLProc, LCLType, LCLIntf, Forms, Controls, Graphics, ComCtrls, Menus, Clipbrd,
  ActnList, ExtCtrls, StdCtrls, Dialogs,
  // LazControls
  TreeFilterEdit, ExtendedNotebook,
  // LazUtils
  LazUTF8, LazFileUtils, LazLoggerBase, LazStringUtils,
  // IdeIntf
  IDEImagesIntf, IDECommands,
  // IDE
  IDEOptionDefs, LazarusIDEStrConsts, EnvironmentOpts, InputHistory, Project, MainIntf;


type
  { TLazSearchMatchPos }

  TLazSearchMatchPos = class(TObject)
  private
    FFileEndPos: TPoint;
    FFilename: string;
    FFileStartPos: TPoint;
    fMatchStart: integer;
    fMatchLen: integer;
    FNextInThisLine: TLazSearchMatchPos;
    FShownFilename: string;
    FTheText: string;
  public
    property MatchStart: integer read fMatchStart write fMatchStart;// start in TheText
    property MatchLen: integer read fMatchLen write fMatchLen; // length in TheText
    property Filename: string read FFilename write FFilename;
    property FileStartPos: TPoint read FFileStartPos write FFileStartPos;
    property FileEndPos: TPoint read FFileEndPos write FFileEndPos;
    property TheText: string read FTheText write FTheText;
    property ShownFilename: string read FShownFilename write FShownFilename;
    property NextInThisLine: TLazSearchMatchPos read FNextInThisLine write FNextInThisLine;
    destructor Destroy; override;
  end;//TLazSearchMatchPos


  { TLazSearch }

  TLazSearch = Class(TObject)
  private
    FReplaceText: string;
    fSearchString: string;
    fSearchOptions: TLazFindInFileSearchOptions;
    fSearchDirectories: string;
    fSearchMask: string;
  public
    property SearchString: string read fSearchString write fSearchString;
    property ReplaceText: string read FReplaceText write FReplaceText;
    property SearchOptions: TLazFindInFileSearchOptions read fSearchOptions
                                                        write fSearchOptions;
    property SearchDirectories: string read fSearchDirectories
                                     write fSearchDirectories;
    property SearchMask: string read fSearchMask write fSearchMask;
  end;//TLazSearch


  { TLazSearchResultTV }

  TLazSearchResultTV = class(TCustomTreeView)
  private
    fSearchObject: TLazSearch;
    FSkipped: integer;
    fUpdateStrings: TStrings;
    fUpdating: boolean;
    fUpdateCount: integer;
    FSearchInListPhrases: string;
    fFiltered: Boolean;
    fFilenameToNode: TAvlTree; // TTreeNode sorted for Text
    procedure SetSkipped(const AValue: integer);
    procedure AddNode(Line: string; MatchPos: TLazSearchMatchPos);
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    property SearchObject: TLazSearch read fSearchObject write fSearchObject;
    procedure BeginUpdate;
    procedure EndUpdate;
    procedure ShortenPaths;
    procedure FreeObjectsTN(tnItems: TTreeNodes);
    procedure FreeObjects(slItems: TStrings);
    function BeautifyLineAt(SearchPos: TLazSearchMatchPos): string;
    property Filtered: Boolean read fFiltered write fFiltered;
    property SearchInListPhrases: string read FSearchInListPhrases write FSearchInListPhrases;
    property UpdateItems: TStrings read fUpdateStrings write fUpdateStrings;
    property Updating: boolean read fUpdating;
    property Skipped: integer read FSkipped write SetSkipped;
    function ItemsAsStrings: TStrings;
  end;

  TSVCloseButtonsState = (
    svcbNone,
    svcbEnable,
    svcbDisable
    );

  { TSearchResultsView }

  TSearchResultsView = class(TForm)
    actClosePage: TAction;
    actCloseLeft: TAction;
    actCloseOthers: TAction;
    actCloseRight: TAction;
    actCloseAll: TAction;
    actNextPage: TAction;
    actPrevPage: TAction;
    ActionList: TActionList;
    ClosePageButton: TToolButton;
    ControlBar1: TPanel;
    MenuItem1: TMenuItem;
    mniCollapseAll: TMenuItem;
    mniExpandAll: TMenuItem;
    mniCopySelected: TMenuItem;
    mniCopyAll: TMenuItem;
    mniCopyItem: TMenuItem;
    pnlToolBars: TPanel;
    popList: TPopupMenu;
    ResultsNoteBook: TExtendedNotebook;
    tbbCloseLeft: TToolButton;
    tbbCloseOthers: TToolButton;
    tbbCloseRight: TToolButton;
    PageToolBar: TToolBar;
    CloseTabs: TToolBar;
    RefreshButton: TToolButton;
    SearchAgainButton: TToolButton;
    SearchInListEdit: TTreeFilterEdit;
    ShowPathButton: TToolButton;
    ToolButton1: TToolButton;
    ToolButton3: TToolButton;
    tbbCloseAll: TToolButton;
    procedure actNextPageExecute(Sender: TObject);
    procedure actPrevPageExecute(Sender: TObject);
    procedure RefreshButtonClick(Sender: TObject);
    procedure SearchAgainButtonClick(Sender: TObject);
    procedure ClosePageButtonClick(Sender: TObject);
    procedure ResultsNoteBookResize(Sender: TObject);
    procedure ShowPathButtonClick(Sender: TObject);
    procedure tbbCloseAllClick(Sender: TObject);
    procedure tbbCloseLeftClick(Sender: TObject);
    procedure tbbCloseOthersClick(Sender: TObject);
    procedure tbbCloseRightClick(Sender: TObject);
    procedure Form1Create(Sender: TObject);
    procedure FormClose(Sender: TObject; var CloseAction: TCloseAction);
    procedure FormKeyDown(Sender: TObject; var Key: Word; {%H-}Shift: TShiftState);
    procedure mniCopyAllClick(Sender: TObject);
    procedure mniCopyItemClick(Sender: TObject);
    procedure mniCopySelectedClick(Sender: TObject);
    procedure mniExpandAllClick(Sender: TObject);
    procedure mniCollapseAllClick(Sender: TObject);
    procedure ResultsNoteBookChanging(Sender: TObject; var {%H-}AllowChange: Boolean);
    procedure ResultsNoteBookMouseDown(Sender: TObject; Button: TMouseButton;
      {%H-}Shift: TShiftState; X, Y: Integer);
    procedure TreeViewKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure ResultsNoteBookClosetabclicked(Sender: TObject);
    procedure TreeViewAdvancedCustomDrawItem(Sender: TCustomTreeView;
      Node: TTreeNode; State: TCustomDrawState; Stage: TCustomDrawStage;
      var {%H-}PaintImages, {%H-}DefaultDraw: Boolean);
    procedure LazTVShowHint(Sender: TObject; {%H-}HintInfo: PHintInfo);
    procedure LazTVMousemove(Sender: TObject; {%H-}Shift: TShiftState;
                             X, Y: Integer);
    Procedure LazTVMouseWheel(Sender: TObject; Shift: TShiftState;
                   {%H-}WheelDelta: Integer; MousePos: TPoint; var Handled: Boolean);
    procedure TreeViewKeyPress(Sender: TObject; var Key: char);
    procedure ResultsNoteBookPageChanged (Sender: TObject );
    procedure SearchInListChange(Sender: TObject );
    procedure TreeViewMouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
  private
    type
      TOnSide = (osLeft, osOthers, osRight); { Handling of multi tab closure }
  private
    FAsyncUpdateCloseButtons: TSVCloseButtonsState;
    FMaxItems: integer;
    FFocusTreeViewInOnChange: Boolean;
    FFocusTreeViewInEndUpdate: Boolean;
    FWorkedSearchText: string;
    FOnSelectionChanged: TNotifyEvent;
    FMouseOverIndex: integer;
    FClosingTabs: boolean;
    function BeautifyPageName(const APageName: string): string;
    function GetPageIndex(const APageName: string): integer;
    function GetTreeView(APageIndex: integer): TLazSearchResultTV;
    function GetCurrentTreeView: TLazSearchResultTV;
    procedure SetAsyncUpdateCloseButtons(const AValue: TSVCloseButtonsState);
    procedure SetItems(Index: Integer; Value: TStrings);
    function GetItems(Index: integer): TStrings;
    procedure SetMaxItems(const AValue: integer);
    procedure UpdateToolbar;
    function  GetPagesOnActiveLine(aOnSide : TOnSide = osOthers):TFPlist;
    procedure ClosePageOnSides(aOnSide : TOnSide);
    procedure ClosePageBegin;
    procedure ClosePageEnd;
    procedure DoAsyncUpdateCloseButtons(Data: PtrInt);
  protected
    procedure Loaded; override;
    procedure ActivateControl(aWinControl: TWinControl);
    procedure UpdateShowing; override;
    property AsyncUpdateCloseButtons: TSVCloseButtonsState read FAsyncUpdateCloseButtons write SetAsyncUpdateCloseButtons;
  public
    function AddSearch(const ResultsName: string;
                       const SearchText: string;
                       const ReplaceText: string;
                       const ADirectories: string;
                       const AMask: string;
                       const TheOptions: TLazFindInFileSearchOptions): TTabSheet;
    function GetSourcePositon: TPoint;
    function GetSourceFileName: string;
    function GetSelectedText: string;
    function GetSelectedMatchPos: TLazSearchMatchPos;
    procedure AddMatch(const APageIndex: integer;
                       const Filename: string; const StartPos, EndPos: TPoint;
                       const TheText: string;
                       const MatchStart: integer; const MatchLen: integer);
    procedure BeginUpdate(APageIndex: integer);
    procedure EndUpdate(APageIndex: integer);
    procedure Parse_Search_Phrases(var slPhrases: TStrings);
    procedure ClosePage(PageIndex: integer);

    property MaxItems: integer read FMaxItems write SetMaxItems;
    property WorkedSearchText: string read FWorkedSearchText;
    property OnSelectionChanged: TNotifyEvent read fOnSelectionChanged
                                              write fOnSelectionChanged;
    property Items[Index: integer]: TStrings read GetItems write SetItems;
  end;

var
  SearchResultsView: TSearchResultsView = nil;
  OnSearchResultsViewSelectionChanged: TNotifyEvent = nil;
  OnSearchAgainClicked: TNotifyEvent = nil;

implementation

{$R *.lfm}

function CompareTVNodeTextAsFilename(Node1, Node2: Pointer): integer;
var
  TVNode1: TTreeNode absolute Node1;
  TVNode2: TTreeNode absolute Node2;
begin
  Result:=CompareFilenames(TVNode1.Text,TVNode2.Text);
end;

function CompareFilenameWithTVNode(Filename, Node: Pointer): integer;
var
  aFilename: String;
  TVNode: TTreeNode absolute Node;
begin
  aFilename:=String(Filename);
  Result:=CompareFilenames(aFilename,TVNode.Text);
end;

function CopySearchMatchPos(var Src, Dest: TLazSearchMatchPos): Boolean;
begin
  Result := False;
  if ((Src = nil) or (Dest = nil)) then Exit;
  Dest.MatchStart := Src.MatchStart;
  Dest.MatchLen := Src.MatchLen;
  Dest.Filename := Src.Filename;
  Dest.FileStartPos := Src.FileStartPos;
  Dest.FileEndPos := Src.FileEndPos;
  Dest.TheText := Src.TheText;
  Dest.ShownFilename := Src.ShownFilename;
  Result := True;
end;

function GetTreeSelectedItemsAsText(ATreeView: TCustomTreeView): string;
var
  sl: TStringList;
  node: TTreeNode;
begin
  sl:=TStringList.Create;
  node := ATreeView.GetFirstMultiSelected;
  while assigned(node) do
  begin
    sl.Add(node.Text);
    node := node.GetNextMultiSelected;
  end;
  Result:=sl.Text;
  sl.Free;
end;

{ TSearchResultsView }

procedure TSearchResultsView.Form1Create(Sender: TObject);
var
  CloseCommand: TIDECommand;
begin
  FMaxItems:=50000;
  ResultsNoteBook.Options:= ResultsNoteBook.Options+[nboShowCloseButtons];
  ResultsNoteBook.Update;

  Name:=NonModalIDEWindowNames[nmiwSearchResultsView];
  Caption:=lisMenuViewSearchResults;

  RefreshButton.Hint:=rsRefreshTheSearch;
  SearchAgainButton.Hint:=rsNewSearchWithSameCriteria;
  ClosePageButton.Hint:=rsCloseCurrentPage;
  SearchInListEdit.Hint:=rsFilterTheListWithString;
  ShowPathButton.Hint:=rsShowPath;
  { Close tabs buttons }
  actCloseLeft.Hint:=rsCloseLeft;
  actCloseRight.Hint:=rsCloseRight;
  actCloseOthers.Hint:=rsCloseOthers;
  actCloseAll.Hint:=rsCloseAll;

  CloseCommand := IDECommandList.FindIDECommand(ecClose);
  if CloseCommand <> nil then
  begin
    if CloseCommand.AsShortCut <> 0 then
      actClosePage.ShortCut:=CloseCommand.AsShortCut;
    if (CloseCommand.ShortcutB.Key1 <> 0) and (CloseCommand.ShortcutB.Key2 = 0) then
      actClosePage.SecondaryShortCuts.Append(ShortCutToText(
        ShortCut(CloseCommand.ShortcutB.Key1, CloseCommand.ShortcutB.Shift1)));
  end;
  fOnSelectionChanged:= nil;
  ShowHint:= True;
  fMouseOverIndex:= -1;

  mniCopyItem.Caption := lisCopyItemToClipboard;
  mniCopySelected.Caption := lisCopySelectedItemToClipboard;
  mniCopyAll.Caption := lisCopyAllItemsToClipboard;
  mniExpandAll.Caption := lisExpandAll;
  mniCollapseAll.Caption := lisCollapseAll;

  PageToolBar.Images := IDEImages.Images_16;
  RefreshButton.ImageIndex     := IDEImages.LoadImage('laz_refresh');
  SearchAgainButton.ImageIndex := IDEImages.LoadImage('menu_new_search');
  ClosePageButton.ImageIndex   := IDEImages.LoadImage('menu_close');
  ShowPathButton.ImageIndex    := IDEImages.LoadImage('da_directory');
  ActionList.Images := IDEImages.Images_16;
  actClosePage.ImageIndex := IDEImages.LoadImage('menu_close');
  { Close tabs buttons }
  CloseTabs.Images := IDEImages.Images_16;
  actCloseLeft.ImageIndex   := IDEImages.LoadImage('tab_close_L');
  actCloseOthers.ImageIndex := IDEImages.LoadImage('tab_close_LR');
  actCloseRight.ImageIndex  := IDEImages.LoadImage('tab_close_R');
  actCloseAll.ImageIndex    := IDEImages.LoadImage('tab_close_All');
end;

procedure TSearchResultsView.FormClose(Sender: TObject; var CloseAction: TCloseAction);
begin

end;

procedure TSearchResultsView.FormKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  if (Key = VK_ESCAPE) and (Shift = []) then
  begin
    Key := VK_UNKNOWN;
    Close;
  end;
  if (Key = VK_F) and (Shift = [ssCtrl]) then
  begin
    Key := VK_UNKNOWN;
    if SearchInListEdit.CanSetFocus then
      SearchInListEdit.SetFocus;
  end;
  if (Key = VK_P) and (Shift = [ssCtrl]) then
  begin
    Key := VK_UNKNOWN;
    ShowPathButton.Down := not ShowPathButton.Down;
    ShowPathButtonClick(Sender);
  end;
  if (Key = VK_N) and (Shift = [ssCtrl]) then
  begin
    Key := VK_UNKNOWN;
    SearchAgainButtonClick(Sender);
  end;
end;

procedure TSearchResultsView.mniCopyAllClick(Sender: TObject);
var
  sl: TStrings;
begin
  sl := (popList.PopupComponent as TLazSearchResultTV).ItemsAsStrings;
  Clipboard.AsText := sl.Text;
  sl.Free;
end;

procedure TSearchResultsView.mniCopyItemClick(Sender: TObject);
var
  tv: TCustomTreeView;
  Node: TTreeNode;
begin
  tv := popList.PopupComponent as TCustomTreeView;
  with tv.ScreenToClient(popList.PopupPoint) do
    Node := tv.GetNodeAt(X, Y);
  if Node <> nil then
    Clipboard.AsText := Node.Text;
end;

procedure TSearchResultsView.mniCopySelectedClick(Sender: TObject);
begin
  Clipboard.AsText := GetTreeSelectedItemsAsText(popList.PopupComponent as TCustomTreeView);
end;

procedure TSearchResultsView.mniExpandAllClick(Sender: TObject);
var
  CurrentTV: TLazSearchResultTV;
  Key: Char = '*';
begin
  CurrentTV := GetCurrentTreeView;
  if Assigned(CurrentTV) then
    TreeViewKeyPress(CurrentTV, Key);
end;

procedure TSearchResultsView.mniCollapseAllClick(Sender: TObject);
var
  CurrentTV: TLazSearchResultTV;
  Key: Char = '/';
begin
  CurrentTV := GetCurrentTreeView;
  if Assigned(CurrentTV) then
    TreeViewKeyPress(CurrentTV, Key);
end;

procedure TSearchResultsView.ResultsNoteBookMouseDown(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
var
  TabIndex: LongInt;
begin
  if (Button = mbMiddle) then
  begin
    TabIndex := ResultsNoteBook.IndexOfPageAt(Point(X,Y));
    if TabIndex >= 0 then
      ResultsNoteBookClosetabclicked(ResultsNoteBook.Page[TabIndex]);
  end;
end;

procedure TSearchResultsView.RefreshButtonClick(Sender: TObject);
begin
  ShowMessage('ToDo: Refresh the search in current page.');
end;

procedure TSearchResultsView.SearchAgainButtonClick(Sender: TObject);
var
  CurrentTV: TLazSearchResultTV;
  SearchObj: TLazSearch;
begin
  CurrentTV:= GetCurrentTreeView;
  if not Assigned(CurrentTV) then
    MainIDEInterface.FindInFilesPerDialog(Project1)
  else begin
    SearchObj:= CurrentTV.SearchObject;
    OnSearchAgainClicked(SearchObj);
    with SearchObj do
      MainIDEInterface.FindInFiles(Project1, SearchString, SearchOptions, SearchMask, SearchDirectories);
  end;
end;

procedure TSearchResultsView.ClosePageButtonClick(Sender: TObject);
begin
  ClosePage(ResultsNoteBook.PageIndex);
end;

procedure TSearchResultsView.actNextPageExecute(Sender: TObject);
begin
  ResultsNoteBook.SelectNextPage(True);
end;

procedure TSearchResultsView.actPrevPageExecute(Sender: TObject);
begin
  ResultsNoteBook.SelectNextPage(False);
end;

procedure TSearchResultsView.ResultsNoteBookResize(Sender: TObject);
begin
  if ResultsNoteBook.PageCount>0 then
    AsyncUpdateCloseButtons:=svcbEnable
  else
    AsyncUpdateCloseButtons:=svcbDisable;
end;

procedure TSearchResultsView.ShowPathButtonClick(Sender: TObject);
var
  lTree: TLazSearchResultTV;
begin
  lTree := GetCurrentTreeView;
  if lTree = nil then exit;
  lTree.Invalidate;
end;

{ Handling of tabs closure. Only tabs on pages at the level of active page in
  multiline ResultsNoteBook will be closed by Left / Others and Right }
procedure TSearchResultsView.ClosePageOnSides(aOnSide: TOnSide);
var
  lvPageList: TFPList = nil;
  lCurTabSheet, lTabSheet: TTabSheet;
  ix: integer;
  lNeedsRefresh : boolean = false;
begin
  lvPageList := GetPagesOnActiveLine(aOnSide);
  if lvPageList = Nil then Exit;
  ClosePageBegin;
  lCurTabSheet := ResultsNoteBook.ActivePage;
  if aOnSide = osLeft then
    ix := lvPageList.IndexOf(lCurTabSheet)-1
  else
    ix := lvPageList.Count-1;
  while ix >= 0 do begin
    lTabSheet := TTabSheet(lvPageList[ix]);
    if lTabSheet = lCurTabSheet then begin
      if aOnSide = osRight then
        break;
    end
    else begin
      ClosePage(lTabSheet.TabIndex);
      lNeedsRefresh := True;
    end;
    Dec(ix);
  end;
  lvPageList.Free;
  ClosePageEnd;
  if lNeedsRefresh then { Force resizing of the active TabSheet }
    lCurTabSheet.Height := lCurTabSheet.Height+1;
  UpdateToolBar;
end;

procedure TSearchResultsView.ClosePageBegin;
begin
  FClosingTabs := True;
end;

procedure TSearchResultsView.ClosePageEnd;
begin
  FClosingTabs := False;
end;

procedure TSearchResultsView.tbbCloseLeftClick(Sender: TObject);
begin
  ClosePageOnSides(osLeft);
end;

procedure TSearchResultsView.tbbCloseOthersClick(Sender: TObject);
begin
  ClosePageOnSides(osOthers);
end;

procedure TSearchResultsView.tbbCloseRightClick(Sender: TObject);
begin
  ClosePageOnSides(osRight);
end;

procedure TSearchResultsView.tbbCloseAllClick(Sender: TObject);
var
  lPageIx : integer;
begin
  with ResultsNoteBook do begin
    lPageIx := PageCount;
    while lPageIx > 0 do begin
      Dec(lPageIx);
      if lPageIx < PageCount then
        ClosePage(lPageIx);
    end;
  end;
end;

{Keeps track of the Index of the Item the mouse is over, Sets ShowHint to true
if the Item length is longer than the TreeView client width.}
procedure TSearchResultsView.LazTVMousemove(Sender: TObject; Shift: TShiftState;
                                            X, Y: Integer);
var
  Node: TTreeNode;
begin
  if Sender is TLazSearchResultTV then
    with TLazSearchResultTV(Sender) do
    begin
      Node := GetNodeAt(X, Y);
      if Assigned(Node) then
        fMouseOverIndex:=Node.Index
      else
        fMouseOverIndex:=-1;
      if (fMouseOverIndex > -1) and (fMouseOverIndex < Items.Count)
      and (Canvas.TextWidth(Items[fMouseOverIndex].Text) > Width) then
        ShowHint:= True
      else
        ShowHint:= False;
    end;//with
end;

{Keep track of the mouse position over the treeview when the wheel is used}
procedure TSearchResultsView.LazTVMouseWheel(Sender: TObject;
  Shift: TShiftState; WheelDelta: Integer; MousePos: TPoint;
  var Handled: Boolean);
begin
  LazTVMouseMove(Sender,Shift,MousePos.X, MousePos.Y);
  Handled:= false;
end;

procedure TSearchResultsView.TreeViewKeyPress(Sender: TObject; var Key: char);
var
  i: Integer;
  Tree: TLazSearchResultTV;
  Node: TTreeNode;
  Collapse: Boolean;
begin
  if Key in ['/', '*'] then
  begin
    Collapse := Key = '/';
    Tree := (Sender as TLazSearchResultTV);
    for i := Tree.Items.TopLvlCount -1 downto 0 do
    begin
      Node := Tree.Items.TopLvlItems[i];
      if Collapse then
        Node.Collapse(False)
      else
        Node.Expand(False);
    end;
    Key := #0;
  end else
  if Key = Char(VK_RETURN) then  //SearchInListEdit passes only OnPress through
  begin
    Key := #0;
    if Assigned(FOnSelectionChanged) then
      FOnSelectionChanged(Self);
  end;
end;

procedure TSearchResultsView.ResultsNoteBookPageChanged(Sender: TObject);
var
  CurrentTV: TLazSearchResultTV;
begin
  CurrentTV := GetCurrentTreeView;
  if Assigned(CurrentTV) and not (csDestroying in CurrentTV.ComponentState) then begin
    SearchInListEdit.FilteredTreeview := CurrentTV;
    SearchInListEdit.Filter := CurrentTV.SearchInListPhrases;
    if FFocusTreeViewInOnChange then
      ActivateControl(CurrentTV);
  end;
  UpdateToolbar;
end;

procedure TSearchResultsView.SearchInListChange (Sender: TObject );
var
  CurrentTV: TLazSearchResultTV;
begin
  CurrentTV := GetCurrentTreeView;
  if Assigned(CurrentTV) then
    CurrentTV.SearchInListPhrases := SearchInListEdit.Text;
end;

procedure TSearchResultsView.TreeViewMouseDown(Sender: TObject;
  Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
var
  TV: TCustomTreeView;
  Node: TTreeNode;
begin
  if Button<>mbLeft then exit;
  TV:=Sender as TCustomTreeView;
  Node:=TV.GetNodeAt(X,Y);
  if Node=nil then exit;
  if x<Node.DisplayTextLeft then exit;
  //debugln(['TSearchResultsView.TreeViewMouseDown single=',([ssDouble,ssTriple,ssQuad]*Shift=[]),' Option=',EnvironmentOptions.MsgViewDblClickJumps]);
  if EnvironmentOptions.MsgViewDblClickJumps then
  begin
    // double click jumps
    if not (ssDouble in Shift) then exit;
  end else begin
    // single click jumps -> single selection
    if ([ssDouble,ssTriple,ssQuad]*Shift<>[]) then exit;
    TV.Items.SelectOnlyThis(Node);
  end;
  if Assigned(fOnSelectionChanged) then
    fOnSelectionChanged(Self);
end;

function TSearchResultsView.BeautifyPageName(const APageName: string): string;
const
  MaxPageName = 25;
begin
  Result:=Utf8EscapeControlChars(APageName, emHexPascal);
  if UTF8Length(Result)>MaxPageName then
    Result:=UTF8Copy(Result,1,MaxPageName-5)+'...';
end;

procedure TSearchResultsView.AddMatch(const APageIndex: integer;
  const Filename: string; const StartPos, EndPos: TPoint;
  const TheText: string;
  const MatchStart: integer; const MatchLen: integer);
var
  CurrentTV: TLazSearchResultTV;
  SearchPos: TLazSearchMatchPos;
  ShownText: String;
  LastPos: TLazSearchMatchPos;
begin
  CurrentTV:=GetTreeView(APageIndex);
  if Assigned(CurrentTV) then
  begin
    if CurrentTV.Updating then begin
      if CurrentTV.UpdateItems.Count>=MaxItems then begin
        CurrentTV.Skipped:=CurrentTV.Skipped+1;
        exit;
      end;
    end else begin
      if CurrentTV.Items.Count>=MaxItems then begin
        CurrentTV.Skipped:=CurrentTV.Skipped+1;
        exit;
      end;
    end;
    SearchPos:= TLazSearchMatchPos.Create;
    SearchPos.MatchStart:=MatchStart;
    SearchPos.MatchLen:=MatchLen;
    SearchPos.Filename:=Filename;
    SearchPos.FileStartPos:=StartPos;
    SearchPos.FileEndPos:=EndPos;
    SearchPos.TheText:=TheText;
    SearchPos.ShownFilename:=SearchPos.Filename;
    ShownText:=CurrentTV.BeautifyLineAt(SearchPos);
    LastPos:=nil;
    if CurrentTV.Updating then begin
      if (CurrentTV.UpdateItems.Count>0)
      and (CurrentTV.UpdateItems.Objects[CurrentTV.UpdateItems.Count-1] is TLazSearchMatchPos) then
        LastPos:=TLazSearchMatchPos(CurrentTV.UpdateItems.Objects[CurrentTV.UpdateItems.Count-1]);
    end else
      if (CurrentTV.Items.Count>0) and Assigned(CurrentTV.Items[CurrentTV.Items.Count-1].Data) then
        LastPos:=TLazSearchMatchPos(CurrentTV.Items[CurrentTV.Items.Count-1].Data);
    if (LastPos<>nil) and (LastPos.Filename=SearchPos.Filename) and
       (LastPos.FFileStartPos.Y=SearchPos.FFileStartPos.Y) and
       (LastPos.FFileEndPos.Y=SearchPos.FFileEndPos.Y) then
    begin
      while (LastPos.NextInThisLine<>nil) do
        LastPos := LastPos.NextInThisLine;
      LastPos.NextInThisLine:=SearchPos
    end
    else if CurrentTV.Updating then
      CurrentTV.UpdateItems.AddObject(ShownText, SearchPos)
    else
      CurrentTV.AddNode(ShownText, SearchPos);
    CurrentTV.ShortenPaths;
  end;//if
end;//AddMatch

procedure TSearchResultsView.BeginUpdate(APageIndex: integer);
var
  CurrentTV: TLazSearchResultTV;
begin
  CurrentTV:= GetTreeView(APageIndex);
  if Assigned(CurrentTV) then
    CurrentTV.BeginUpdate;
  UpdateToolbar;
end;

procedure TSearchResultsView.EndUpdate(APageIndex: integer);
var
  CurrentTV: TLazSearchResultTV;
begin
  CurrentTV:= GetTreeView(APageIndex);
  if Assigned(CurrentTV) then
  begin
    CurrentTV.EndUpdate;
    if CurrentTV.Items.Count>0 then begin
      CurrentTV.Items[0].Selected:=True;
    end;
  end;
  UpdateToolbar;
  if FFocusTreeViewInEndUpdate and Assigned(CurrentTV) then
    ActivateControl(CurrentTV)
  else
  if SearchInListEdit.CanFocus then
    ActivateControl(SearchInListEdit);
end;

procedure TSearchResultsView.Parse_Search_Phrases(var slPhrases: TStrings);
var
  i, iLength: Integer;
  sPhrases, sPhrase: string;
begin
  //Parse Phrases
  sPhrases := SearchInListEdit.Text;
  iLength := Length(sPhrases);
  sPhrase := '';
  for i:=1 to iLength do
  begin
    if ((sPhrases[i] = ' ') or (sPhrases[i] = ',') or (i = iLength)) then
    begin
      if not ((sPhrases[i] = ' ') or (sPhrases[i] = ',')) then
        sPhrase := sPhrase + sPhrases[i];
      if (sPhrase > ' ') then
        slPhrases.Add(UpperCase(sPhrase)); //End of phrase, add to phrase list
      sPhrase := '';//Reset sPhrase
    end
    else if (sPhrases[i] > ' ') then
      sPhrase := sPhrase + sPhrases[i];
  end; //End for-loop i
end;

procedure TSearchResultsView.ResultsNoteBookChanging(Sender: TObject;
  var AllowChange: Boolean);
var
  CurrentTV: TLazSearchResultTV;
begin
  CurrentTV := GetCurrentTreeView;
  FFocusTreeViewInOnChange := Assigned(CurrentTV) and CurrentTV.Focused;
end;

procedure TSearchResultsView.ClosePage(PageIndex: integer);
var
  CurrentTV: TLazSearchResultTV;
begin
  if (PageIndex>=0) and (PageIndex<ResultsNoteBook.PageCount) then
  begin
    CurrentTV:= GetTreeView(PageIndex);
    if Assigned(CurrentTV) and CurrentTV.Updating then
      exit;

    ResultsNoteBook.Pages[PageIndex].Free;
  end;
  if ResultsNoteBook.PageCount = 0 then
    Close
  else
    AsyncUpdateCloseButtons:=svcbEnable;
end;

{Sets the Items from the treeview on the currently selected page in the TNoteBook}
procedure TSearchResultsView.SetItems(Index: Integer; Value: TStrings);
var
  CurrentTV: TLazSearchResultTV;
begin
  if Index > -1 then
  begin
    CurrentTV:= GetTreeView(Index);
    if Assigned(CurrentTV) then
    begin
      if CurrentTV.Updating then
        CurrentTV.UpdateItems.Assign(Value)
      else
        CurrentTV.Items.Assign(Value);
      CurrentTV.Skipped:=0;
    end;
  end;
end;

function TSearchResultsView.GetItems(Index: integer): TStrings;
var
  CurrentTV: TLazSearchResultTV;
begin
  result:= nil;
  CurrentTV:= GetTreeView(Index);
  if Assigned(CurrentTV) then
  begin
    if CurrentTV.Updating then
      result:= CurrentTV.UpdateItems
    else
      Result := CurrentTV.ItemsAsStrings;
  end;
end;

procedure TSearchResultsView.SetMaxItems(const AValue: integer);
begin
  if FMaxItems=AValue then exit;
  FMaxItems:=AValue;
end;

procedure TSearchResultsView.UpdateToolbar;
var
  CurrentTV: TLazSearchResultTV;
  state: Boolean;
begin
  CurrentTV:= GetCurrentTreeView;
  state := Assigned(CurrentTV) and not CurrentTV.Updating;
  RefreshButton.Enabled := state;
  SearchAgainButton.Enabled := state;
  ClosePageButton.Enabled := state;
  SearchInListEdit.Enabled := state;
  if state then
    AsyncUpdateCloseButtons:=svcbEnable;
end;

{ Returns a list of all pages (visible tabs) on the same line of Tabs as the ActivaPage }
function TSearchResultsView.GetPagesOnActiveLine(aOnSide: TOnSide {=osOthers}): TFPlist;
var
  lActiveMidY, lActiveIndex, ix, hh: integer;
  lActiveRect, lRect, lLastRect: TRect;
begin
  Result := nil;
  with ResultsNoteBook do begin
    if ActivePage = Nil then Exit;
    Result := TFPList.Create;
    lActiveIndex := ResultsNoteBook.ActivePageIndex;
    lActiveRect := TabRect(lActiveIndex);
    hh := (lActiveRect.Bottom - lActiveRect.Top) div 2;
    { Some widgetsets returned a negative value from Bottom-Top calculation. }
    if hh < 0 then begin       // Do a sanity check.
      DebugLn(['TSearchResultsView.GetPagesOnActiveLine: TabRect Bottom-Top calculation'+
               ' for ActivePage returned a negative value "', hh, '".']);
      hh := -hh;
    end;
    lActiveMidY := lActiveRect.Top + hh;
    { Search closable tabs left of current tab }
    if aOnSide in [osLeft, osOthers] then begin
      lLastRect := lActiveRect;
      for ix := lActiveIndex-1 downto 0 do begin
        lRect := TabRect(ix);
        if (lRect.Top >= lActiveMidY) or (lRect.Bottom <= lActiveMidY)
        or (lRect.Right > lLastRect.Left) then
          break;
        Result.Insert(0, Pages[ix]);
        lLastRect := lRect;
      end;
    end;
    { Current tab }
    Result.Add(Pages[lActiveIndex]);
    { Search closable tabs right of current tab }
    if aOnSide in [osOthers, osRight] then begin
      lLastRect := lActiveRect;
      for ix := lActiveIndex+1 to PageCount-1  do begin
        lRect := TabRect(ix);
        if (lRect.Top >= lActiveMidY) or (lRect.Bottom <= lActiveMidY)
        or (lRect.Left < lLastRect.Right) then
          break;
        Result.Add(Pages[ix]);
        lLastRect := lRect;
      end;
    end;
  end;
end;

procedure TSearchResultsView.DoAsyncUpdateCloseButtons(Data: PtrInt);
var
  lPageList: TFPlist = nil;
  lActiveIx: integer = -1;
  aEnable: Boolean;
begin
  if FClosingTabs then
    exit;
  if FAsyncUpdateCloseButtons=svcbNone then exit;
  aEnable:=FAsyncUpdateCloseButtons=svcbEnable;
  FAsyncUpdateCloseButtons:=svcbNone;

  if aEnable and (ResultsNoteBook.PageCount>0) then begin
    lPageList := GetPagesOnActiveLine;
    if Assigned(lPageList) and (lPageList.Count>0) then
      repeat
        inc(lActiveIx);
        if lPageList[lActiveIx]=Pointer(ResultsNoteBook.ActivePage) then
          break;
      until lActiveIx>=lPageList.Count -1;
  end;
  aEnable := aEnable and Assigned(lPageList);
  actCloseLeft.Enabled  := aEnable and (lActiveIx>0);
  if aEnable then begin
    actCloseOthers.Enabled:= lPageList.Count>1;
    actCloseRight.Enabled := lActiveIx<(lPageList.Count-1);
  end
  else begin
    actCloseOthers.Enabled:= False;
    actCloseRight.Enabled := False;
  end;
  actCloseAll.Enabled   := aEnable;
  lPageList.Free;
end;

procedure TSearchResultsView.ResultsNoteBookClosetabclicked(Sender: TObject);
begin
  if (Sender is TTabSheet) then
    ClosePage(TTabSheet(Sender).PageIndex)
end;

procedure TSearchResultsView.TreeViewKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  if (Key = VK_RETURN) and (Shift = []) then
  begin
    Key:=VK_UNKNOWN;
    if Assigned(FOnSelectionChanged) then
      FOnSelectionChanged(Self);
  end;
end;

{ Add Result will create a tab in the Results view window with an new
  treeview or focus an existing TreeView and update it's searchoptions.}
function TSearchResultsView.AddSearch(const ResultsName: string;
  const SearchText: string;
  const ReplaceText: string;
  const ADirectories: string;
  const AMask: string;
  const TheOptions: TLazFindInFileSearchOptions): TTabSheet;
var
  NewTreeView: TLazSearchResultTV;
  NewPage: LongInt;
  SearchObj: TLazSearch;
begin
  Result:= nil;
  if Assigned(ResultsNoteBook) then
  begin
    with ResultsNoteBook do
    begin
      FFocusTreeViewInEndUpdate := not (Assigned(ActivePage)
                                  and SearchInListEdit.IsParentOf(ActivePage));
      FWorkedSearchText:=BeautifyPageName(ResultsName);
      NewPage:= TCustomTabControl(ResultsNoteBook).Pages.Add(FWorkedSearchText);
      PageIndex:= NewPage;
      Page[PageIndex].OnKeyDown := @TreeViewKeyDown;
      if NewPage > -1 then
      begin
        NewTreeView:= TLazSearchResultTV.Create(Page[NewPage]);
        with NewTreeView do
        begin
          Parent:= Page[NewPage];
          Align:= alClient;
          BorderSpacing.Around := 0;
          OnKeyDown := @TreeViewKeyDown;
          OnAdvancedCustomDrawItem:= @TreeViewAdvancedCustomDrawItem;
          OnShowHint:= @LazTVShowHint;
          OnMouseMove:= @LazTVMousemove;
          OnMouseWheel:= @LazTVMouseWheel;
          OnMouseDown:=@TreeViewMouseDown;
          OnKeyPress:=@TreeViewKeyPress;
          ShowHint:= true;
          RowSelect := True;                        // we are using custom draw
          Options := Options + [tvoAllowMultiselect] - [tvoThemedDraw];
          PopupMenu := popList;
          NewTreeView.Canvas.Brush.Color:= clWhite;
        end;//with
        SearchObj:=NewTreeView.SearchObject;
        if SearchObj<>nil then begin
          SearchObj.SearchString:= SearchText;
          SearchObj.ReplaceText := ReplaceText;
          SearchObj.SearchDirectories:= ADirectories;
          SearchObj.SearchMask:= AMask;
          SearchObj.SearchOptions:= TheOptions;
        end;
        NewTreeView.Skipped:=0;
      end
      else
        NewTreeView:=nil;
      Result:= Pages[PageIndex];
      SearchInListEdit.ResetFilter;
      SearchInListEdit.FilteredTreeview := NewTreeView;
    end;//with
  end;
end;

procedure TSearchResultsView.LazTVShowHint(Sender: TObject; HintInfo: PHintInfo);
var
  MatchPos: TLazSearchMatchPos;
  HintStr: string;
begin
  if Sender is TLazSearchResultTV then
  begin
    With Sender as TLazSearchResultTV do
    begin
      if (fMouseOverIndex >= 0) and (fMouseOverIndex < Items.Count) then
      begin
        if Assigned(Items[fMouseOverIndex].Data) then
          MatchPos:= TLazSearchMatchPos(Items[fMouseOverIndex].Data)
        else
          MatchPos:= nil;
        if MatchPos<>nil then
          HintStr:=MatchPos.Filename
                   +' ('+IntToStr(MatchPos.FileStartPos.Y)
                   +','+IntToStr(MatchPos.FileStartPos.X)+')'
                   +' '+MatchPos.TheText
        else
          HintStr:=Items[fMouseOverIndex].Text;
        Hint:= HintStr;
      end;//if
    end;//with
  end;//if
end;

procedure TSearchResultsView.Loaded;
begin
  inherited Loaded;

  ActiveControl := ResultsNoteBook;
end;

procedure TSearchResultsView.ActivateControl(aWinControl: TWinControl);
var
  aForm: TCustomForm;
begin
  if not aWinControl.CanFocus then exit;
  if Parent=nil then
    ActiveControl:=aWinControl
  else begin
    aForm:=GetParentForm(Self);
    if aForm<>nil then aForm.ActiveControl:=aWinControl;
  end;
end;

procedure TSearchResultsView.UpdateShowing;
begin
  inherited UpdateShowing;
  AsyncUpdateCloseButtons:=svcbDisable;
end;

procedure TSearchResultsView.TreeViewAdvancedCustomDrawItem(
  Sender: TCustomTreeView; Node: TTreeNode; State: TCustomDrawState;
  Stage: TCustomDrawStage; var PaintImages, DefaultDraw: Boolean);
var
  lTree: TLazSearchResultTV;
  lRect: TRect;
  lMatch: TLazSearchMatchPos;
  lPart, lRelPath: string;
  lDrawnLength: integer;
  lDigitWidth: integer;
  lTextX: integer;
  i: integer;

  procedure DrawNextText(aText: string; aColor: TColor = clNone; aStyle: TFontStyles = []);
  var
    lOldColor: TColor;
  begin
    // store
    lOldColor := lTree.Canvas.Font.Color;
    // apply
    if aColor <> clNone then
      lTree.Canvas.Font.Color := aColor;
    lTree.Canvas.Font.Style := aStyle;
    lTree.Canvas.Brush.Style := bsClear;
    // draw
    lTree.Canvas.TextOut(lTextX, lRect.Top, aText);
    inc(lTextX, lTree.Canvas.GetTextWidth(aText) + 1);
    // restore
    lTree.Canvas.Font.Color := lOldColor;
    lTree.Canvas.Font.Style := [];
    lTree.Canvas.Brush.Style := bsSolid;
  end;

begin
  if Stage <> cdPostPaint then exit;

  if Sender is TLazSearchResultTV // it also check nil
    then lTree := TLazSearchResultTV(Sender)
    else exit;

  // clear
  lRect := Node.DisplayRect(true);
  lTree.Canvas.FillRect(lRect);

  if TObject(Node.Data) is TLazSearchMatchPos then
  begin { search results }
    lMatch := TLazSearchMatchPos(Node.Data);

    // clear tree lines (optional)
    lTree.Canvas.FillRect(Rect(lRect.Left - lRect.Height, lRect.Top, lRect.Right, lRect.Bottom));

    // calculating the maximum width of a digit:
    // not in monospace fonts, digits can have different widths
    lDigitWidth := lTree.Canvas.GetTextWidth(':');
    for i := 0 to 9 do
      lDigitWidth := Max(lDigitWidth, lTree.Canvas.GetTextWidth(inttostr(i)));

    lPart := inttostr(lMatch.FileStartPos.Y) + ':';
    lTextX := lRect.Left + 6 * lDigitWidth - lTree.Canvas.GetTextWidth(lPart);
    // draw line number ("99999: ")
    DrawNextText(lPart, clGrayText);

    lTextX := lRect.Left + 7 * lDigitWidth;
    lDrawnLength := 0;
    while assigned(lMatch) do
    begin
      //debugln(['TSearchResultsView.TreeViewAdvancedCustomDrawItem MatchPos.TheText="',lMatch.TheText,'" MatchPos.MatchStart=',lMatch.MatchStart,' MatchPos.MatchLen=',lMatch.MatchLen]);
      // draw normal text
      lPart := copy(lMatch.TheText, lDrawnLength + 1, lMatch.MatchStart - 1 - lDrawnLength);
      lPart := Utf8EscapeControlChars(lPart, emHexPascal);
      lDrawnLength := lMatch.MatchStart - 1;

      // draw normal text
      DrawNextText(lPart);

      lPart := ShortDotsLine(copy(lMatch.TheText, lDrawnLength + 1, lMatch.MatchLen));
      lDrawnLength := lDrawnLength + lMatch.MatchLen;

      // draw found text
      if [cdsSelected,cdsMarked] * State <> []
        then DrawNextText(lPart, clHighlightText)
        else DrawNextText(lPart, clHighlight);

      // remaining normal text
      if lMatch.NextInThisLine = nil then
      begin
        lPart := copy(lMatch.TheText, lDrawnLength + 1, Length(lMatch.TheText));
        lPart := Utf8EscapeControlChars(lPart, emHexPascal);
        // draw normal text
        DrawNextText(lPart);
      end;
      lMatch := lMatch.NextInThisLine;
    end;

  end else begin { filename }
    lTextX := lRect.Left;

    // show path or file name
    lRelPath := ExtractRelativePath(
      IncludeTrailingPathDelimiter(lTree.SearchObject.SearchDirectories),
      Node.Text
    );
    if ShowPathButton.Down then
    begin
      DrawNextText(lRelPath, clNone, [fsBold]);
    end else begin
      if [cdsSelected,cdsMarked] * State <> [] then
      begin
        DrawNextText(ExtractFileName(lRelPath), clNone, [fsBold]);
        DrawNextText(' (' + lRelPath + ')', clHighlightText);
      end else begin
        DrawNextText(ExtractFileName(lRelPath), clNone, [fsBold]);
      end;
    end;

    // show a warning that this is a backup folder
    // strip path delimiter and filename, then check if last directory is 'backup'
    lPart := ExcludeTrailingPathDelimiter(ExtractFilePath(lRelPath));
    if CompareText('backup', ExtractFileNameOnly(lPart)) = 0 then
      DrawNextText(' [BACKUP]', clRed);

  end;
end;

{Returns the Position within the source file from a properly formated search result}
function TSearchResultsView.GetSourcePositon: TPoint;
var
  MatchPos: TLazSearchMatchPos;
begin
  Result.x:= -1;
  Result.y:= -1;
  MatchPos:=GetSelectedMatchPos;
  if MatchPos=nil then exit;
  Result:=MatchPos.FileStartPos;
end;

{Returns The file name portion of a properly formated search result}
function TSearchResultsView.GetSourceFileName: string;
var
  MatchPos: TLazSearchMatchPos;
begin
  MatchPos:=GetSelectedMatchPos;
  if MatchPos=nil then
    Result:=''
  else
    Result:=MatchPos.Filename;
end;

{Returns the selected text in the currently active TreeView.}
function TSearchResultsView.GetSelectedText: string;
var
  lPage: TTabSheet;
  lTree: TLazSearchResultTV;
  i: integer;
begin
  result := '';
  i := ResultsNoteBook.PageIndex;
  if i < 0 then exit;

  lPage:= ResultsNoteBook.Pages[i];
  if not assigned(lPage) then exit;

  lTree := GetTreeView(lPage.PageIndex);
  if Assigned(lTree.Selected) then
    Result := lTree.Selected.Text;
end;

function TSearchResultsView.GetSelectedMatchPos: TLazSearchMatchPos;
var
  lPage: TTabSheet;
  lTree: TLazSearchResultTV;
  i: integer;
begin
  result:= nil;
  i := ResultsNoteBook.PageIndex;
  if i < 0 then exit;

  lPage := ResultsNoteBook.Pages[i];
  if not Assigned(lPage) then exit;

  lTree := GetTreeView(lPage.PageIndex);
  if Assigned(lTree.Selected) then
    Result := TLazSearchMatchPos(lTree.Selected.Data);
end;

function TSearchResultsView.GetPageIndex(const APageName: string): integer;
var
  Paren, i: integer;
  PN: String;
begin
  result := -1;
  for i := 0 to ResultsNoteBook.PageCount - 1 do
  begin
    PN := ResultsNoteBook.Page[i].Caption;
    Paren := Pos(' (', PN);
    if (Paren > 0) and (PosEx(')', PN, Paren + 2) > 0) then
      PN := LeftStr(PN, Paren-1);
    if PN = APageName then
      exit(i);
  end;
end;

{Returns the TreeView control from a Tab if both the page and the TreeView exist,
 else returns nil}
function TSearchResultsView.GetTreeView(APageIndex: integer): TLazSearchResultTV;
var
  i: integer;
  lPage: TTabSheet;
begin
  result := nil;
  if not InRange(APageIndex, 0, ResultsNoteBook.PageCount - 1) then exit;

  lPage := ResultsNoteBook.Pages[APageIndex];
  if not assigned(lPage) then exit;

  for i:= 0 to lPage.ComponentCount - 1 do
    if lPage.Components[i] is TLazSearchResultTV then
      exit(TLazSearchResultTV(lPage.Components[i]));
end;

function TSearchResultsView.GetCurrentTreeView: TLazSearchResultTV;
begin
  result := GetTreeView(ResultsNoteBook.PageIndex);
end;

procedure TSearchResultsView.SetAsyncUpdateCloseButtons(const AValue: TSVCloseButtonsState);
var
  Old: TSVCloseButtonsState;
begin
  if FAsyncUpdateCloseButtons=AValue then Exit;
  Old:=FAsyncUpdateCloseButtons;
  FAsyncUpdateCloseButtons:=AValue;
  if Old=svcbNone then
    Application.QueueAsyncCall(@DoAsyncUpdateCloseButtons,0);
end;

procedure TLazSearchResultTV.SetSkipped(const AValue: integer);
var
  SrcList: TStrings;
  s: String;
  HasSkippedLine: Boolean;
  SkippedLine: String;
begin
  if FSkipped=AValue then exit;
  FSkipped:=AValue;
  s:=rsFoundButNotListedHere;
  if fUpdating then
    SrcList:=fUpdateStrings
  else
    SrcList:=ItemsAsStrings;
  if (SrcList.Count>0) and (copy(SrcList[SrcList.Count-1],1,length(s))=s) then
    HasSkippedLine:=true
  else
    HasSkippedLine:=false;
  SkippedLine:=s+IntToStr(FSkipped);
  if FSkipped>0 then begin
    if HasSkippedLine then begin
      SrcList[SrcList.Count-1]:=SkippedLine;
    end else begin
      SrcList.add(SkippedLine);
    end;
  end else begin
    if HasSkippedLine then
      SrcList.Delete(SrcList.Count-1);
  end;
end;

procedure TLazSearchResultTV.AddNode(Line: string; MatchPos: TLazSearchMatchPos);
var
  Node: TTreeNode;
  ChildNode: TTreeNode;
  AVLNode: TAvlTreeNode;
begin
  if MatchPos=nil then exit;
  AVLNode:=fFilenameToNode.FindKey(PChar(MatchPos.FileName),@CompareFilenameWithTVNode);
  if AVLNode<>nil then
    Node := TTreeNode(AVLNode.Data)
  else
    Node := nil;

  //enter a new file entry
  if not Assigned(Node) then
    begin
    Node := Items.Add(Nil, MatchPos.FileName);
    fFilenameToNode.Add(Node);
    end;

  ChildNode := Items.AddChild(Node, Line);
  Node.Expanded := true;
  ChildNode.Data := MatchPos;
end;

{******************************************************************************
  TLazSearchResultTV
******************************************************************************}
Constructor TLazSearchResultTV.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  ReadOnly := True;
  fSearchObject:= TLazSearch.Create;
  fUpdateStrings:= TStringList.Create;
  fFilenameToNode:=TAvlTree.Create(@CompareTVNodeTextAsFilename);
  fUpdating:= false;
  fUpdateCount:= 0;
  FSearchInListPhrases := '';
  fFiltered := False;
end;//Create

Destructor TLazSearchResultTV.Destroy;
begin
  if Assigned(fSearchObject) then
    FreeThenNil(fSearchObject);
  //if UpdateStrings is empty, the objects are stored in Items due to filtering
  //filtering clears UpdateStrings
  if (fUpdateStrings.Count = 0) then
    FreeObjectsTN(Items);
  FreeThenNil(fFilenameToNode);
  Assert(Assigned(fUpdateStrings), 'fUpdateStrings = Nil');
  FreeObjects(fUpdateStrings);
  FreeThenNil(fUpdateStrings);
  inherited Destroy;
end;//Destroy

procedure TLazSearchResultTV.BeginUpdate;
var
  s: TStrings;
begin
  inc(fUpdateCount);
  if (fUpdateCount = 1) then
  begin
    // save old treeview content
    if Assigned(Items) then
    begin
      s := ItemsAsStrings;
      fUpdateStrings.Assign(s);
      s.Free;
    end;
    fUpdating:= true;
  end;
end;

procedure TLazSearchResultTV.EndUpdate;
var
  i: integer;
begin
  if (fUpdateCount = 0) then
    RaiseGDBException('TLazSearchResultTV.EndUpdate');
  Dec(fUpdateCount);
  if (fUpdateCount = 0) then
  begin
    ShortenPaths;
    fUpdating:= false;
    FreeObjectsTN(Items);
    Items.BeginUpdate;
    Items.Clear;
    fFilenameToNode.Clear;
    for i := 0 to fUpdateStrings.Count - 1 do
      AddNode(fUpdateStrings[i], TLazSearchMatchPos(fUpdateStrings.Objects[i]));
    Items.EndUpdate;
  end;//if
end;//EndUpdate

procedure TLazSearchResultTV.ShortenPaths;
var
  i: Integer;
  AnObject: TObject;
  SharedPath: String;
  MatchPos: TLazSearchMatchPos;
  SrcList: TStrings;
  SharedLen: Integer;
  ShownText: String;
  FreeSrcList: Boolean;
begin
  if fUpdateCount > 0 then exit;

  FreeSrcList := not fUpdating;
  if fUpdating
    then SrcList := fUpdateStrings
    else SrcList := ItemsAsStrings;

  try
    // find shared path (the path of all filenames, that is the same)
    SharedPath := '';
    for i := 0 to SrcList.Count - 1 do
    begin
      AnObject := SrcList.Objects[i];
      if AnObject is TLazSearchMatchPos then
      begin
        MatchPos := TLazSearchMatchPos(AnObject);
        if i = 0 then
          SharedPath := ExtractFilePath(MatchPos.Filename)
        else if SharedPath <> '' then
        begin
          SharedLen := 0;

          while
            (SharedLen < length(MatchPos.Filename)) and
            (SharedLen < length(SharedPath)) and
            (MatchPos.Filename[SharedLen + 1] = SharedPath[SharedLen + 1])
          do
            inc(SharedLen);

          while (SharedLen > 0) and (SharedPath[SharedLen] <> PathDelim) do
            dec(SharedLen);

          if SharedLen <> length(SharedPath) then
            SharedPath := copy(SharedPath, 1, SharedLen);
        end;
      end;
    end;

    // shorten shown paths
    SharedLen := length(SharedPath);
    for i := 0 to SrcList.Count - 1 do
    begin
      AnObject := SrcList.Objects[i];
      if AnObject is TLazSearchMatchPos then
      begin
        MatchPos := TLazSearchMatchPos(AnObject);
        MatchPos.ShownFilename := copy(MatchPos.Filename, SharedLen + 1, length(MatchPos.Filename));
        ShownText := BeautifyLineAt(MatchPos);
        SrcList[i] := ShownText;
        SrcList.Objects[i] := MatchPos;
      end;
    end;
  finally
    if FreeSrcList then FreeThenNil(SrcList);
  end;
end;

procedure TLazSearchResultTV.FreeObjectsTN(tnItems: TTreeNodes);
var i: Integer;
begin
  fFilenameToNode.Clear;
  for i:=0 to tnItems.Count-1 do
    if Assigned(tnItems[i].Data) then
      TLazSearchMatchPos(tnItems[i].Data).Free;
end;

procedure TLazSearchResultTV.FreeObjects(slItems: TStrings);
var i: Integer;
begin
  if (slItems.Count <= 0) then Exit;
  for i:=0 to slItems.Count-1 do
    if Assigned(slItems.Objects[i]) then
      slItems.Objects[i].Free;
end;

function TLazSearchResultTV.BeautifyLineAt(SearchPos: TLazSearchMatchPos): string;
begin
  with SearchPos do
    Result:=BeautifyLineXY(ShownFilename, TheText, FileStartPos.X, FileStartPos.Y);
end;

function TLazSearchResultTV.ItemsAsStrings: TStrings;
var
  i: integer;
begin
  Result := TStringList.Create;
  for i := 0 to Items.Count - 1 do
    Result.AddObject(Items[i].Text,TObject(Items[i].Data));
end;

{ TLazSearchMatchPos }

destructor TLazSearchMatchPos.Destroy;
begin
  FreeThenNil(FNextInThisLine);
  inherited Destroy;
end;

end.

