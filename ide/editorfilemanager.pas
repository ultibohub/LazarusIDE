unit EditorFileManager;

{$mode objfpc}{$H+}

interface

uses
  Classes, sysutils, Forms, Controls, CheckLst, ButtonPanel, StdCtrls, Buttons,
  ExtCtrls, Menus, LCLProc, LCLType, IDEImagesIntf, LazIDEIntf, IDEHelpIntf,
  SrcEditorIntf, IDEWindowIntf, SourceEditor, LazarusIDEStrConsts,
  ListFilterEdit, IDEOptionDefs;

type

  { TEditorFileManagerForm }

  TEditorFileManagerForm = class(TForm)
    ActivateMenuItem: TMenuItem;
    FileCountLabel: TLabel;
    MoveDownBtn: TSpeedButton;
    MoveUpBtn: TSpeedButton;
    FilterPanel: TPanel;
    OpenButton: TSpeedButton;
    SaveCheckedButton: TBitBtn;
    ButtonPanel1: TButtonPanel;
    CloseCheckedButton: TBitBtn;
    CloseMenuItem: TMenuItem;
    Panel1: TPanel;
    PopupMenu1: TPopupMenu;
    CheckAllCheckBox: TCheckBox;
    CheckListBox1: TCheckListBox;
    FilterEdit: TListFilterEdit;
    SortAlphabeticallyButton: TSpeedButton;
    procedure ActivateMenuItemClick(Sender: TObject);
    procedure CheckListBox1DblClick(Sender: TObject);
    procedure CheckListBox1KeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure CheckListBox1KeyPress(Sender: TObject; var Key: char);
    procedure CloseButtonClick(Sender: TObject);
    procedure DoEditorsChanged(Sender: TObject);
    procedure FormKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure HelpButtonClick(Sender: TObject);
    procedure MoveDownBtnClick(Sender: TObject);
    procedure MoveUpBtnClick(Sender: TObject);
    procedure CheckListBox1Click(Sender: TObject);
    procedure CheckListBox1ItemClick(Sender: TObject; Index: integer);
    procedure CloseCheckedButtonClick(Sender: TObject);
    procedure PopupMenu1Popup(Sender: TObject);
    procedure SaveCheckedButtonClick(Sender: TObject);
    procedure CloseMenuItemClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure ActivateButtonClick(Sender: TObject);
    procedure CheckAllCheckBoxClick(Sender: TObject);
    procedure SortAlphabeticallyButtonClick(Sender: TObject);
  private
    FSortAlphabetically: boolean;
    procedure CloseListItem(ListIndex: integer);
    procedure PopulateList;
    function SrcEditorByListItem(ListIndex: integer): TSourceEditor;
    procedure SetSortAlphabetically(AValue: boolean);
    procedure UpdateCheckAllCaption;
    procedure UpdateButtons;
    procedure UpdateMoveButtons(ListIndex: integer);
  public
    destructor Destroy; override;
    property SortAlphabetically: boolean read FSortAlphabetically write SetSortAlphabetically;
  end;

var
  EditorFileManagerForm: TEditorFileManagerForm;

procedure ShowEditorFileManagerForm(State: TIWGetFormState = iwgfShowOnTop);

implementation

{$R *.lfm}

procedure ShowEditorFileManagerForm(State: TIWGetFormState);
begin
  if EditorFileManagerForm = Nil then
    IDEWindowCreators.CreateForm(EditorFileManagerForm,TEditorFileManagerForm,
       State=iwgfDisabled,LazarusIDE.OwningComponent)
  else if State=iwgfDisabled then
    EditorFileManagerForm.DisableAlign;
  if State>=iwgfShow then
    IDEWindowCreators.ShowForm(EditorFileManagerForm,State=iwgfShowOnTop);
end;

{ TEditorFileManagerForm }

procedure TEditorFileManagerForm.FormCreate(Sender: TObject);
begin
  Name := NonModalIDEWindowNames[nmiwEditorFileManager];

  SourceEditorManager.RegisterChangeEvent(semEditorCreate, @DoEditorsChanged);
  SourceEditorManager.RegisterChangeEvent(semEditorDestroy, @DoEditorsChanged);

  PopulateList;          // Populate the list with all open editor file names
  // Captions
  Caption:=lisSourceEditorWindowManager;
  ActivateMenuItem.Caption:=lisActivate;
  CloseMenuItem.Caption:=lisClose;
  CheckAllCheckBox.Caption:=lisCheckAll;
  SaveCheckedButton.Caption:=lisSaveAllChecked;
  CloseCheckedButton.Caption:=lisCloseAllChecked;
  MoveUpBtn.Hint:=lisMoveSelectedUp;
  MoveDownBtn.Hint:=lisMoveSelectedDown;
  // Icons
  PopupMenu1.Images:=IDEImages.Images_16;
  ActivateMenuItem.ImageIndex:=IDEImages.LoadImage('laz_open');
  CloseMenuItem.ImageIndex:=IDEImages.LoadImage('menu_close');
  IDEImages.AssignImage(CloseCheckedButton, 'menu_close_all');
  IDEImages.AssignImage(SaveCheckedButton, 'menu_save_all');
  IDEImages.AssignImage(MoveUpBtn, 'arrow_up');
  IDEImages.AssignImage(MoveDownBtn, 'arrow_down');
  // Buttons on FilterPanel
  IDEImages.AssignImage(OpenButton, 'laz_open');
  OpenButton.Hint:=lisActivateSelected;
  SortAlphabeticallyButton.Hint:=lisPESortFilesAlphabetically;
  IDEImages.AssignImage(SortAlphabeticallyButton, 'pkg_sortalphabetically');
end;

procedure TEditorFileManagerForm.CheckListBox1Click(Sender: TObject);
var
  clb: TCheckListBox;
begin
  clb:=Sender as TCheckListBox;
  // Enable Activate when there is a selected item.
  OpenButton.Enabled:=clb.SelCount>0;
  UpdateMoveButtons(clb.ItemIndex);
end;

procedure TEditorFileManagerForm.CheckListBox1ItemClick(Sender: TObject; Index: integer);
var
  clb: TCheckListBox;
  i: Integer;
  HasChecked: Boolean;
begin
  clb:=Sender as TCheckListBox;
  // Notify the filter edit that item's checked state has changed.
  if Index>-1 then
    FilterEdit.ItemWasClicked(clb.Items[Index], clb.Checked[Index]);
  // Enable save and close buttons when there are checked items.
  HasChecked:=False;
  for i:=clb.Count-1 downto 0 do
    if clb.Checked[i] then begin
      HasChecked:=True;
      Break;
    end;
  SaveCheckedButton.Enabled:=HasChecked;
  CloseCheckedButton.Enabled:=HasChecked;
  CloseMenuItem.Enabled:=HasChecked;
  CheckAllCheckBox.Enabled:=clb.Count>0;
  // If all items were unchecked, change CheckAllCheckBox state.
  if CheckAllCheckBox.Checked and not HasChecked then begin
    CheckAllCheckBox.Checked:=HasChecked;
    UpdateCheckAllCaption;
  end;
  CheckListBox1Click(CheckListBox1); // Call also OnClick handler for other controls.
end;

procedure TEditorFileManagerForm.CheckAllCheckBoxClick(Sender: TObject);
var
  cb: TCheckBox;
  i: Integer;
begin
  cb:=Sender as TCheckBox;
  UpdateCheckAllCaption;
  // Set / reset all CheckListBox1 items.
  for i:=0 to CheckListBox1.Count-1 do begin
    if CheckListBox1.Checked[i]<>cb.Checked then begin
      CheckListBox1.Checked[i]:=cb.Checked;
      FilterEdit.ItemWasClicked(CheckListBox1.Items[i], cb.Checked); // Notify the filter
    end;
  end;
  CheckListBox1ItemClick(CheckListBox1, CheckListBox1.Count-1);
end;

procedure TEditorFileManagerForm.SortAlphabeticallyButtonClick(Sender: TObject);
begin
  SortAlphabetically:=SortAlphabeticallyButton.Down;
end;

procedure TEditorFileManagerForm.SaveCheckedButtonClick(Sender: TObject);
var
  i: Integer;
  SrcEdit: TSourceEditor;
begin
  for i:=CheckListBox1.Count-1 downto 0 do
    if CheckListBox1.Checked[i] then begin
      SrcEdit:=SrcEditorByListItem(i);
      Assert(Assigned(SrcEdit), 'TEditorFileManagerForm.SaveCheckedButtonClick: SrcEdit is not assigned.');
      if (not SrcEdit.CodeBuffer.IsVirtual) and (LazarusIDE.DoSaveEditorFile(SrcEdit, []) <> mrOk) then
        DebugLn(['TSourceNotebook.EncodingClicked LazarusIDE.DoSaveEditorFile failed']);
    end;
end;

procedure TEditorFileManagerForm.CloseCheckedButtonClick(Sender: TObject);
var
  i: Integer;
begin
  for i:=CheckListBox1.Count-1 downto 0 do
    if CheckListBox1.Checked[i] then
      CloseListItem(i);
  PopulateList;
  UpdateButtons;
end;

procedure TEditorFileManagerForm.PopupMenu1Popup(Sender: TObject);
var
  HasSelected: Boolean;
begin
  HasSelected:=CheckListBox1.SelCount>0;
  ActivateMenuItem.Enabled:=HasSelected;
  CloseMenuItem.Enabled:=HasSelected;
end;

procedure TEditorFileManagerForm.CloseMenuItemClick(Sender: TObject);
begin
  CloseListItem(CheckListBox1.ItemIndex);
  PopulateList;
  UpdateButtons;
end;

procedure TEditorFileManagerForm.ActivateMenuItemClick(Sender: TObject);
begin
  ActivateButtonClick(nil);
end;

procedure TEditorFileManagerForm.CheckListBox1DblClick(Sender: TObject);
begin
  ActivateButtonClick(nil);
end;

procedure TEditorFileManagerForm.CheckListBox1KeyDown(Sender: TObject;
  var Key: Word; Shift: TShiftState);
begin
  if (ssCtrl in Shift ) and ((Key = VK_UP) or (Key = VK_DOWN)) then begin
    if Key = VK_UP then
      MoveUpBtnClick(nil)
    else
      MoveDownBtnClick(nil);
    Key:=VK_UNKNOWN;
  end;
end;

procedure TEditorFileManagerForm.CheckListBox1KeyPress(Sender: TObject; var Key: char);
begin
  if Key = char(VK_RETURN) then
    ActivateButtonClick(nil);
end;

procedure TEditorFileManagerForm.CloseButtonClick(Sender: TObject);
begin
  Close;
end;

procedure TEditorFileManagerForm.DoEditorsChanged(Sender: TObject);
begin
  PopulateList;
end;

procedure TEditorFileManagerForm.FormKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
begin
  if (Key = VK_ESCAPE) and (Shift = []) then
    Close;
end;

procedure TEditorFileManagerForm.HelpButtonClick(Sender: TObject);
begin
  LazarusHelp.ShowHelpForIDEControl(Self);
end;

procedure TEditorFileManagerForm.MoveDownBtnClick(Sender: TObject);
var
  SrcEdit: TSourceEditor;
  i: Integer;
begin
  i:=CheckListBox1.ItemIndex;
  if (i>-1) and (i<CheckListBox1.Items.Count-1)
  and (FilterEdit.Filter='') and not SortAlphabetically then begin
    SrcEdit:=SrcEditorByListItem(i);
    Assert(Assigned(SrcEdit), 'TEditorFileManagerForm.MoveDownBtnClick: SrcEdit is not assigned.');
    if SrcEdit.PageIndex < SrcEdit.SourceNotebook.PageCount-1 then begin
      // First move the source editor tab
      SrcEdit.SourceNotebook.MoveEditor(SrcEdit.PageIndex, SrcEdit.PageIndex+1);
      // Then switch the list items
      FilterEdit.Items.Exchange(i, i+1);
      FilterEdit.InvalidateFilter;
      UpdateMoveButtons(i+1);
    end;
  end;
end;

procedure TEditorFileManagerForm.MoveUpBtnClick(Sender: TObject);
var
  SrcEdit: TSourceEditor;
  i: Integer;
begin
  i := CheckListBox1.ItemIndex;
  if (i > 0) and (FilterEdit.Filter='') and not SortAlphabetically then begin
    SrcEdit:=SrcEditorByListItem(i);
    Assert(Assigned(SrcEdit), 'TEditorFileManagerForm.MoveUpBtnClick: SrcEdit is not assigned.');
    if SrcEdit.PageIndex > 0 then begin
      // First move the source editor tab
      SrcEdit.SourceNotebook.MoveEditor(SrcEdit.PageIndex, SrcEdit.PageIndex-1);
      // Then switch the list items
      FilterEdit.Items.Exchange(i, i-1);
      FilterEdit.InvalidateFilter;
      UpdateMoveButtons(i-1);
    end;
  end;
end;

procedure TEditorFileManagerForm.ActivateButtonClick(Sender: TObject);
var
  i: Integer;
  SrcEdit: TSourceEditor;
begin
  for i:=0 to CheckListBox1.Count-1 do
    if CheckListBox1.Selected[i] then begin       // Find first selected.
      SrcEdit:=SrcEditorByListItem(CheckListBox1.ItemIndex);
      Assert(Assigned(SrcEdit), 'TEditorFileManagerForm.ActivateButtonClick: SrcEdit is not assigned.');
      SrcEdit.Activate;
      Break;
    end;
end;

// Private methods

procedure TEditorFileManagerForm.CloseListItem(ListIndex: integer);
var
  SrcEdit: TSourceEditor;
begin
  SrcEdit:=SrcEditorByListItem(ListIndex);
  Assert(Assigned(SrcEdit), 'TEditorFileManagerForm.CloseListItem: SrcEdit is not assigned.');
  LazarusIDE.DoCloseEditorFile(SrcEdit, [cfSaveFirst]);
end;

procedure TEditorFileManagerForm.PopulateList;
// Populate the list with all open editor file names
var
  SrcEdit: TSourceEditor;
  i, j: Integer;
  sw: TSourceNotebook;
  Modi: String;
begin
  FilterEdit.Items.Clear;
  with SourceEditorManager do
    for i:=0 to SourceWindowCount-1 do begin
      sw:=SourceWindows[i];
      Assert(sw.PageCount=sw.EditorCount, 'sw.PageCount<>sw.EditorCount');
      for j:=0 to sw.EditorCount-1 do begin
        SrcEdit:=sw.FindSourceEditorWithPageIndex(j);
        if SrcEdit.Modified then
          Modi:='* '
        else
          Modi:='';
        FilterEdit.Items.Add(Modi+SrcEdit.FileName);
      end;
    end;
  FilterEdit.InvalidateFilter;
  FileCountLabel.Caption:=Format(dlgFiles,[IntToStr(SourceEditorManager.SourceEditorCount)]);
end;

function TEditorFileManagerForm.SrcEditorByListItem(ListIndex: integer): TSourceEditor;
var
  s: String;
begin
  s:=CheckListBox1.Items[ListIndex];
  if (s<>'') and (s[1]='*') then        // Modified indicator
    delete(s, 1, 2);
  Result:=SourceEditorManager.SourceEditorIntfWithFilename(s);
end;

procedure TEditorFileManagerForm.SetSortAlphabetically(AValue: boolean);
begin
  if FSortAlphabetically=AValue then exit;
  FSortAlphabetically:=AValue;
  SortAlphabeticallyButton.Down:=FSortAlphabetically;
  FilterEdit.SortData:=FSortAlphabetically;
end;

procedure TEditorFileManagerForm.UpdateCheckAllCaption;
// Caption text: check all / uncheck all
begin
  if CheckAllCheckBox.Checked then
    CheckAllCheckBox.Caption:=lisUncheckAll
  else
    CheckAllCheckBox.Caption:=lisCheckAll;
end;

procedure TEditorFileManagerForm.UpdateButtons;
// Update the filter and buttons. Reuse event handlers for it.
begin
  FilterEdit.InvalidateFilter;
  CheckListBox1ItemClick(CheckListBox1, CheckListBox1.Count-1);
end;

procedure TEditorFileManagerForm.UpdateMoveButtons(ListIndex: integer);
var
  SrcEdit: TSourceEditor;
  UpEnabled, DownEnabled: Boolean;
begin
  UpEnabled:=False;
  DownEnabled:=False;
  if (ListIndex>-1) and (ListIndex<CheckListBox1.Items.Count)
  and (FilterEdit.Filter='') and not SortAlphabetically then begin
    //DebugLn(['TEditorFileManagerForm.UpdateMoveButtons: Filename', CheckListBox1.Items[ListIndex], ', ListIndex:', ListIndex]);
    SrcEdit:=SrcEditorByListItem(ListIndex);
    if Assigned(SrcEdit) then begin
      DownEnabled:=(ListIndex<CheckListBox1.Items.Count-1)
               and (SrcEdit.PageIndex<SrcEdit.SourceNotebook.PageCount-1);
      UpEnabled:=(ListIndex>0) and (SrcEdit.PageIndex>0);
    end;
  end;
  MoveUpBtn.Enabled:=UpEnabled;
  MoveDownBtn.Enabled:=DownEnabled;
end;

destructor TEditorFileManagerForm.Destroy;
begin
  if SourceEditorManager <> nil then begin
    SourceEditorManager.UnRegisterChangeEvent(semEditorCreate, @DoEditorsChanged);
    SourceEditorManager.UnRegisterChangeEvent(semEditorDestroy, @DoEditorsChanged);
  end;
  inherited Destroy;
end;

end.

