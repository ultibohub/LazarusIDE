{
 /***************************************************************************
                             taborderdlg.pas
                             ---------------

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

unit TabOrderDlg;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, AVL_Tree,
  // LCL
  Forms, Controls, Dialogs, Buttons, ExtCtrls, StdCtrls, ComCtrls, LCLType,
  // LazUtils
  LazLoggerBase,
  // IdeIntf
  PropEdits, IDEDialogs, IDEImagesIntf,
  //IDE
  IDEOptionDefs, LazarusIDEStrConsts;

type

  { TTabOrderDialog }

  TTabOrderDialog = class(TForm)
    ArrowDown: TSpeedButton;
    ArrowUp: TSpeedButton;
    CheckBoxSortRecursivly: TCheckBox;
    PanelSortByPosition: TPanel;
    ItemTreeview: TTreeView;
    SortByPositionButton: TBitBtn;
    procedure ItemTreeviewSelectionChanged(Sender: TObject);
    procedure SortByPositionButtonClick(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure TabOrderDialogCreate(Sender: TObject);
    procedure UpSpeedbuttonClick(Sender: TObject);
    procedure DownSpeedbuttonClick(Sender: TObject);
    procedure ItemTreeviewKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
  private
    FUpdating: Boolean;
    procedure SwapNodes(ANode1, ANode2, NewSelected: TTreeNode);
    procedure CheckButtonsEnabled;
    procedure CreateCandidates(OwnerComponent: TComponent; Candidates: TAvlTree);
    procedure CreateNodes(ParentControl: TWinControl; ParentNode: TTreeNode;
      Candidates: TAvlTree);
    procedure RefreshTree;
    procedure SomethingChanged;
    procedure PersistentAdded({%H-}APersistent: TPersistent; {%H-}Select: boolean);
    procedure PersistentDeleting({%H-}APersistent: TPersistent);
    procedure DeletePersistent(var {%H-}APersistent: TPersistent);
    procedure SetSelection(const ASelection: TPersistentSelectionList);
  end;

  { TTabOrderPropEditor }

  TTabOrderPropEditor = class(TIntegerPropertyEditor)
  public
    function GetAttributes: TPropertyAttributes; override;
    procedure Edit; override;
  end;

var
  TabOrderDialog: TTabOrderDialog;
  ShowTabOrderEditor: TNotifyEvent;

implementation

{$R *.lfm}

function SortNodeByControlPos(Item1, Item2: Pointer): Integer;
var
  Node1: TTreeNode absolute Item1;
  Node2: TTreeNode absolute Item2;
  Control1, Control2: TControl;
  HorzDiff, TopDiff: Integer;
begin
  Control1 := TControl(Node1.Data);
  Control2 := TControl(Node2.Data);
  Assert(Control1.Parent = Control2.Parent);
  HorzDiff := Control1.Left - Control2.Left;
  if Control1.Parent.BiDiMode <> bdLeftToRight then
  begin
    Inc(HorzDiff, Control1.Width);
    Dec(HorzDiff, Control2.Width);
    HorzDiff := -HorzDiff;
  end;
  TopDiff := Control1.Top - Control2.Top;
  if TopDiff = 0 then
    Exit(HorzDiff);

  // Control1/2 will now refer to upper and lower control.
  if TopDiff > 0 then
  begin
    Control1 := TControl(Node2.Data);
    Control2 := TControl(Node1.Data);
  end;
  // If a control is "almost completely" above the other, it takes precedence
  //regardless of the horizontal positioning.
  if (Control1.Top + Control1.Height div 2 < Control2.Top)
    and (Control1.Top + Control1.Height < Control2.Top + Control2.Height)
  then
    Result := TopDiff
  else
    Result := HorzDiff;
end;

{ TTabOrderDialog }

procedure TTabOrderDialog.TabOrderDialogCreate(Sender: TObject);
begin
  Name := NonModalIDEWindowNames[nmiwTabOrderEditor];

  GlobalDesignHook.AddHandlerChangeLookupRoot(@SomethingChanged);
  GlobalDesignHook.AddHandlerRefreshPropertyValues(@SomethingChanged);
  GlobalDesignHook.AddHandlerPersistentAdded(@PersistentAdded);
  GlobalDesignHook.AddHandlerPersistentDeleting(@PersistentDeleting);
  GlobalDesignHook.AddHandlerDeletePersistent(@DeletePersistent);
  GlobalDesignHook.AddHandlerSetSelection(@SetSelection);

  IDEImages.AssignImage(ArrowDown, 'arrow_down');
  IDEImages.AssignImage(ArrowUp, 'arrow_up');
  IDEImages.AssignImage(SortByPositionButton, 'menu_edit_sort');

  ArrowDown.Hint:=lisTabOrderDownHint;
  ArrowUp.Hint:=lisTabOrderUpHint;
  SortByPositionButton.Hint:=lisTabOrderSortHint;
  CheckBoxSortRecursivly.Caption := lisTabOrderRecursively;
  CheckBoxSortRecursivly.Hint := lisTabOrderRecursionHint;
end;

procedure TTabOrderDialog.FormShow(Sender: TObject);
var
  Sel: TPersistentSelectionList;
begin
  RefreshTree;
  Sel := TPersistentSelectionList.Create;
  try
    GlobalDesignHook.GetSelection(Sel);
    SetSelection(Sel);
  finally
    Sel.Free;
  end;
  CheckButtonsEnabled;
end;

procedure TTabOrderDialog.SortByPositionButtonClick(Sender: TObject);

  procedure SortControls(FirstItem: TTreeNode);
  var
    SortedNodes: TFPList;
    I: Integer;
    CurrItem: TTreeNode;
  begin
    if Assigned(FirstItem) then begin
      SortedNodes := TFPList.Create;
      try
        CurrItem := FirstItem;
        repeat
          if CheckBoxSortRecursivly.Checked then
            SortControls(CurrItem.GetFirstChild);

          SortedNodes.Add(CurrItem);
          CurrItem := CurrItem.GetNextSibling;
        until CurrItem = nil;

        SortedNodes.Sort(@SortNodeByControlPos);

        for I := SortedNodes.Count - 1 downto 0 do
        begin
          CurrItem := TTreeNode(SortedNodes[I]);
          CurrItem.MoveTo(FirstItem, naAddFirst);
          TWinControl(CurrItem.Data).TabOrder := I;
          CurrItem.Text := TWinControl(CurrItem.Data).Name + '   (' + IntToStr(I) + ')';
        end;
      finally
        SortedNodes.Free;
      end;
    end;
  end;

var
  FirstItem: TTreeNode;
begin
  if (ItemTreeview.Selected <> nil) and (ItemTreeview.Selected.Parent <> nil) then
    FirstItem := ItemTreeview.Selected.Parent.GetFirstChild
  else
    FirstItem := ItemTreeview.Items.GetFirstNode;

  if IDEMessageDialog('', Format(lisTabOrderConfirmSort, [TControl(FirstItem.Data).Parent.Name]),
    mtConfirmation, mbOKCancel) <> mrOK then
  begin
    Exit;
  end;

  ItemTreeview.BeginUpdate;
  try
    SortControls(FirstItem);
  finally
    ItemTreeview.EndUpdate;
  end;
  GlobalDesignHook.Modified(Self);
  GlobalDesignHook.RefreshPropertyValues;
  CheckButtonsEnabled;
end;

procedure TTabOrderDialog.ItemTreeviewSelectionChanged(Sender: TObject);
var
  Node: TTreeNode;
begin
  if FUpdating then Exit;
  Node := ItemTreeview.Selected;
  if Assigned(Node) then begin
    FUpdating := True;
    GlobalDesignHook.SelectOnlyThis(TPersistent(Node.Data));
    FUpdating := False;
    CheckButtonsEnabled;
  end;
end;

procedure TTabOrderDialog.UpSpeedbuttonClick(Sender: TObject);
var
  CurItem, NewItem: TTreeNode;
begin
  CurItem := ItemTreeview.Selected;
  if (CurItem=nil) or (CurItem.GetPrevSibling=nil) then exit;
  NewItem := CurItem.GetPrevSibling;
  SwapNodes(NewItem, CurItem, CurItem);
end;

procedure TTabOrderDialog.DownSpeedbuttonClick(Sender: TObject);
var
  CurItem, NewItem: TTreeNode;
begin
  CurItem:=ItemTreeview.Selected;
  if (CurItem=nil) or (CurItem.GetNextSibling=nil) then exit;
  NewItem := CurItem.GetNextSibling;
  SwapNodes(CurItem, NewItem, CurItem);
end;

procedure TTabOrderDialog.ItemTreeviewKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  if Shift = [ssCtrl] then
  begin
    case Key of
      VK_UP:
      begin
        ArrowUp.Click;
        Key := 0;
      end;
      VK_DOWN:
      begin
        ArrowDown.Click;
        Key := 0;
      end;
    end;
  end;
end;

procedure TTabOrderDialog.SwapNodes(ANode1, ANode2, NewSelected: TTreeNode);
var
  Ctrl1, Ctrl2: TWinControl;
  TabOrd: TTabOrder;
begin
  if IsVisible and not FUpdating then
  begin
    FUpdating := true;
    ItemTreeview.BeginUpdate;
    try
      ANode2.MoveTo(ANode1,naInsert);          // Move Node2 in front of Node1.
      Ctrl1 := TWinControl(ANode1.Data);
      Ctrl2 := TWinControl(ANode2.Data);
      TabOrd := Ctrl1.TabOrder;                // Swap TabOrder values.
      Ctrl1.TabOrder := Ctrl2.TabOrder;
      Ctrl2.TabOrder := TabOrd;
      ANode1.Text := Ctrl1.Name + '   (' + IntToStr(Ctrl1.TabOrder) + ')';
      ANode2.Text := Ctrl2.Name + '   (' + IntToStr(Ctrl2.TabOrder) + ')';
      ItemTreeview.Selected := NewSelected;
      GlobalDesignHook.Modified(Self);
      GlobalDesignHook.RefreshPropertyValues;
      CheckButtonsEnabled;
    finally
      ItemTreeview.EndUpdate;
      FUpdating := false;
    end;
  end;
end;

procedure TTabOrderDialog.CheckButtonsEnabled;
var
  CurItem: TTreeNode;
begin
  CurItem := ItemTreeview.Selected;
  ArrowUp.Enabled   := Assigned(CurItem) and Assigned(CurItem.GetPrevSibling);
  ArrowDown.Enabled := Assigned(CurItem) and Assigned(CurItem.GetNextSibling);
  SortByPositionButton.Enabled := Assigned(ItemTreeview.Items.GetFirstNode);
end;

procedure TTabOrderDialog.CreateCandidates(OwnerComponent: TComponent;
  Candidates: TAvlTree);
var
  i: Integer;
  AComponent: TComponent;
begin
  if OwnerComponent = nil then Exit;
  if csDestroying in OwnerComponent.ComponentState then exit;
  for i := 0 to OwnerComponent.ComponentCount - 1 do
  begin
    AComponent := OwnerComponent.Components[i];
    if csDestroying in AComponent.ComponentState then continue;
    if Candidates.Find(AComponent)<>nil then
    begin
      DebugLn('WARNING: TTabOrderDialog.CreateCandidates doppelganger found ', AComponent.Name);
    end
    else
    begin
      Candidates.Add(AComponent);
      if csInline in AComponent.ComponentState then
        CreateCandidates(AComponent, Candidates);
    end;
  end;
end;

procedure TTabOrderDialog.CreateNodes(ParentControl: TWinControl; ParentNode: TTreeNode; Candidates: TAvlTree);
// Add all controls in Designer to ItemTreeview.
var
  AControl: TControl;
  i, CurTab: integer;
  FirstSibling: TTreeNode;
  NodeBehind: TTreeNode;
  NewNode: TTreeNode;
  NodeText: string;
  AWinControl: TWinControl;
begin
  ItemTreeview.BeginUpdate;
  if ParentNode = nil then
    FirstSibling := nil
  else
    FirstSibling := ParentNode.GetFirstChild;
  for i := 0 to ParentControl.ControlCount - 1 do
  begin
    AControl := ParentControl.Controls[i];
    // skip non TWinControls and invisible form designer controls
    if not (AControl is TWinControl) or (csNoDesignVisible in AControl.ControlStyle) or
      not Assigned(Candidates.Find(AControl))
    then
      continue;
    AWinControl := TWinControl(AControl);
    CurTab      := AWinControl.TabOrder;
    NodeBehind  := FirstSibling;
    while (NodeBehind <> nil) and (TWinControl(NodeBehind.Data).TabOrder <= CurTab) do
      NodeBehind := NodeBehind.GetNextSibling;
    NodeText := AWinControl.Name + '   (' + IntToStr(AWinControl.TabOrder) + ')';
    if NodeBehind <> nil then
      NewNode := ItemTreeview.Items.InsertObject(NodeBehind, NodeText, AControl)
    else
      NewNode := ItemTreeview.Items.AddChildObject(ParentNode, NodeText, AControl);
    if (FirstSibling = nil) or (NewNode.GetPrevSibling = nil) then
      FirstSibling := NewNode;
    CreateNodes(AWinControl, NewNode, Candidates);
    NewNode.Expanded := True;
  end;
  ItemTreeview.EndUpdate;
end;

procedure TTabOrderDialog.RefreshTree;
var
  LookupRoot: TPersistent;
  Candidates: TAvlTree;
begin
  if not IsVisible then Exit;
  ItemTreeview.BeginUpdate;
  try
    ItemTreeview.Items.Clear;
    LookupRoot := GlobalDesignHook.LookupRoot;
    if LookupRoot is TWinControl then begin
      Candidates := TAvlTree.Create;
      try
        CreateCandidates(TComponent(LookupRoot), Candidates);
        CreateNodes(TWinControl(LookupRoot), nil, Candidates);
      finally
        Candidates.Free;
      end;
      Caption := Format(lisTabOrderOf, [TWinControl(LookupRoot).Name]);
    end else
      Caption := lisMenuViewTabOrder;
  finally
    ItemTreeview.EndUpdate;
  end;
end;

procedure TTabOrderDialog.SomethingChanged;
begin
  if FUpdating then Exit;
  FUpdating := true;
  RefreshTree;
  CheckButtonsEnabled;
  FUpdating := false;
end;

procedure TTabOrderDialog.PersistentAdded(APersistent: TPersistent; Select: boolean);
begin
  SomethingChanged;
end;

procedure TTabOrderDialog.PersistentDeleting(APersistent: TPersistent);
begin
  SomethingChanged;
end;

procedure TTabOrderDialog.DeletePersistent(var APersistent: TPersistent);
begin
  ShowMessage('TTabOrderDialog.OnDeletePersistent is never called for some reason!');
  SomethingChanged;
end;

procedure TTabOrderDialog.SetSelection(const ASelection: TPersistentSelectionList);
// Select item also in TreeView when selection in Designer changes.

  function FindSelection: TTreeNode;
  var
    Node: TTreeNode;
  begin
    Node := ItemTreeview.Items.GetFirstNode;
    while Assigned(Node) do
    begin
      if Assigned(Node.Data)
      and (ASelection.IndexOf(TPersistent(Node.Data)) >= 0) then
        Exit(Node);
      Node := Node.GetNext;
    end;
    Result := Nil;
  end;

var
  Node: TTreeNode;
begin
  // ToDo: support also multiply selections.
  if FUpdating then Exit;
  FUpdating := True;
  Node := FindSelection;
  if Node = Nil then
  begin           // Changing TabSheet in a PageControl does not trigger handlers
    RefreshTree;  //  thus selection is not found -> refresh tree and try again.
    Node := FindSelection;
  end;
  if Assigned(Node) then
    ItemTreeview.Selected := Node;
  FUpdating := False;
  CheckButtonsEnabled;
end;

{ TTabOrderPropEditor }

function TTabOrderPropEditor.GetAttributes: TPropertyAttributes;
begin
  Result:=(inherited GetAttributes)+[paDialog];
end;

procedure TTabOrderPropEditor.Edit;
begin
  ShowTabOrderEditor(Self);
end;

initialization
  RegisterPropertyEditor(TypeInfo(TTabOrder), TControl, 'TabOrder', TTabOrderPropEditor);

end.

