{
 *****************************************************************************
 *                              CocoaWSCheckLst.pp                           *
 *                              ---------------                              * 
 *                                                                           *
 *                                                                           *
 *****************************************************************************

 *****************************************************************************
  This file is part of the Lazarus Component Library (LCL)

  See the file COPYING.modifiedLGPL.txt, included in this distribution,
  for details about the license.
 *****************************************************************************
}
unit CocoaWSCheckLst;

{$mode objfpc}{$H+}
{$modeswitch objectivec1}
{$modeswitch objectivec2}

interface

uses
  // Libs
  MacOSAll, CocoaAll, Classes, sysutils,
  // LCL
  Controls, StdCtrls, CheckLst, LCLType, LCLMessageGlue,
  // Widgetset
  WSCheckLst, WSLCLClasses,
  // LCL Cocoa
  CocoaWSCommon, CocoaPrivate, CocoaCallback, CocoaWSStdCtrls,
  CocoaListControl, CocoaTables, CocoaScrollers, CocoaWSScrollers;

type

  { TLCLCheckboxListCallback }

  TLCLCheckboxListCallback = class(TLCLListBoxCallback)
  protected
    function AllocStrings(ATable: NSTableView): TCocoaListControlStringList; override;
  public
    checklist: TCustomCheckListBox;
    constructor Create(AOwner: NSObject; ATarget: TWinControl; AHandleView: NSView); override;
    procedure SetItemCheckedAt( row: Integer; CheckState: Integer); override;
  end;

  { TCocoaWSCustomCheckListBox }

  TCocoaWSCustomCheckListBox = class(TWSCustomCheckListBox)
  published
    class function CreateHandle(const AWinControl: TWinControl; const AParams: TCreateParams): TLCLHandle; override;
    class function GetState(const ACheckListBox: TCustomCheckListBox; const AIndex: integer): TCheckBoxState; override;
    class procedure SetState(const ACheckListBox: TCustomCheckListBox; const AIndex: integer; const AState: TCheckBoxState); override;
  end;

implementation

{ TLCLCheckboxListCallback }

function TLCLCheckboxListCallback.AllocStrings(ATable: NSTableView): TCocoaListControlStringList;
begin
  Result:=TCocoaListBoxStringList.Create(ATable);
end;

constructor TLCLCheckboxListCallback.Create(AOwner: NSObject; ATarget: TWinControl; AHandleView: NSView);
begin
  inherited Create(AOwner, ATarget, AHandleView);
  if ATarget is TCustomCheckListBox then
    checklist := TCustomCheckListBox(ATarget);
end;

procedure TLCLCheckboxListCallback.SetItemCheckedAt( row: Integer;
  CheckState: Integer);
begin
  Inherited;
  LCLSendChangedMsg( self.Target, row );
end;

{ TCocoaWSCustomCheckListBox }

{------------------------------------------------------------------------------
  Method:  TCocoaWSCustomCheckListBox.CreateHandle
  Params:  AWinControl - LCL control
           AParams     - Creation parameters
  Returns: Handle to the control in Cocoa interface

  Creates new check list box in Cocoa interface with the specified parameters
 ------------------------------------------------------------------------------}
class function TCocoaWSCustomCheckListBox.CreateHandle(
  const AWinControl: TWinControl; const AParams: TCreateParams): TLCLHandle;
var
  list: TCocoaTableListView;
  scroll: TCocoaScrollView;
  processor: TCocoaTableViewProcessor;
  lclCheckListBox: TCustomCheckListBox absolute AWinControl;
begin
  list := AllocCocoaTableListView.lclInitWithCreateParams(AParams);
  if not Assigned(list) then
  begin
    Result := 0;
    Exit;
  end;
  processor:= TCocoaTableListBoxProcessor.Create;
  list.lclSetProcessor( processor );
  list.callback := TLCLCheckboxListCallback.CreateWithView(list, AWinControl);
  list.lclSetCheckboxes(true);
  //list.list := TCocoaStringList.Create(list);
  list.addTableColumn(NSTableColumn.alloc.init.autorelease);
  list.setHeaderView(nil);
  list.setDataSource(list);
  list.setDelegate(list);
  list.setAllowsMultipleSelection(lclCheckListBox.MultiSelect);
  list.readOnly := true;
  //todo:
  //list.AllowMixedState := TCustomCheckListBox(AWinControl).AllowGrayed;
  list.isOwnerDraw := lclCheckListBox.Style in [lbOwnerDrawFixed, lbOwnerDrawVariable];

  scroll := EmbedInScrollView(list);
  if not Assigned(scroll) then
  begin
    Result := 0;
    Exit;
  end;
  scroll.callback := list.callback;
  scroll.setHasVerticalScroller(true);
  scroll.setAutohidesScrollers(true);

  ScrollViewSetBorderStyle(scroll, lclCheckListBox.BorderStyle);
  UpdateControlFocusRing(list, AWinControl);

  Result := TLCLHandle(scroll);
end;

{------------------------------------------------------------------------------
  Method:  TCocoaWSCustomCheckListBox.GetState
  Params:  ACustomCheckListBox - LCL custom check list box
           AIndex              - Item index
  Returns: If the specified item in check list box in Cocoa interface is
           checked, grayed or unchecked
 ------------------------------------------------------------------------------}
class function TCocoaWSCustomCheckListBox.GetState(
  const ACheckListBox: TCustomCheckListBox; const AIndex: integer): TCheckBoxState;
var
  lclcb : TLCLCheckboxListCallback;
  checkState: Integer;
begin
  Result:= cbUnchecked;

  lclcb:= TLCLCheckboxListCallback( getCallbackFromLCLListBox(ACheckListBox) );
  if NOT Assigned(lclcb) then
    Exit;

  if lclcb.GetItemCheckedAt(AIndex, checkState) then begin
    if checkState <> NSOffState then
      Result:= cbChecked;
  end;
end;

{------------------------------------------------------------------------------
  Method:  TCocoaWSCustomCheckListBox.SetState
  Params:  ACustomCheckListBox - LCL custom check list box
           AIndex              - Item index to change checked value
           AChecked            - New checked value

  Changes checked value of item with the specified index of check list box in
  Cocoa interface
 ------------------------------------------------------------------------------}
class procedure TCocoaWSCustomCheckListBox.SetState(
  const ACheckListBox: TCustomCheckListBox; const AIndex: integer;
  const AState: TCheckBoxState);
var
  cocoaTLV: TCocoaTableListView;
  lclcb : TLCLCheckboxListCallback;
  checkState: Integer;
begin
  lclcb:= TLCLCheckboxListCallback( getCallbackFromLCLListBox(ACheckListBox) );
  if NOT Assigned(lclcb) then
    Exit;

  if AState <> cbUnchecked then
    checkState:= NSOnState
  else
    checkState:= NSOffState;

  lclcb.SetItemCheckedAt( AIndex, checkState );

  cocoaTLV:= getTableViewFromLCLListBox( ACheckListBox );
  cocoaTLV.reloadDataForRow_column( AIndex, 0 );
end;

end.
