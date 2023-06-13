{ $Id$ }
{                       ------------------------------------------
                        debugeventsform.pp  -  Shows target output
                        ------------------------------------------

 @created(Wed Mar 1st 2010)
 @lastmod($Date$)
 @author Lazarus Project

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
unit DebugEventsForm;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils,
  // LCL
  Controls, ComCtrls, ActnList, StdActns, ClipBrd, Menus, Dialogs,
  // LazUtils
  LazFileUtils,
  // IdeIntf
  IDEWindowIntf, IDEImagesIntf, LazIDEIntf, InputHistory,
  // DebuggerIntf
  DbgIntfDebuggerBase,
  // IdeDebugger
  BaseDebugManager, Debugger, DebuggerDlg, IdeDebuggerStringConstants, EnvDebuggerOptions,
  // IDE
  debugger_eventlog_options;

type
  { TDbgEventsForm }

  TDbgEventsForm = class(TDebuggerDlg)
    actClear: TAction;
    actAddComment: TAction;
    actOptions: TAction;
    actSave: TAction;
    ActionList1: TActionList;
    EditCopy1: TEditCopy;
    imlMain: TImageList;
    MenuItem1: TMenuItem;
    MenuItem2: TMenuItem;
    MenuItem3: TMenuItem;
    MenuItem4: TMenuItem;
    MenuItem5: TMenuItem;
    PopupMenu1: TPopupMenu;
    tvFilteredEvents: TTreeView;
    procedure actAddCommentExecute(Sender: TObject);
    procedure actClearExecute(Sender: TObject);
    procedure actOptionsExecute(Sender: TObject);
    procedure actSaveExecute(Sender: TObject);
    procedure EditCopy1Execute(Sender: TObject);
    procedure EditCopy1Update(Sender: TObject);
    procedure tvFilteredEventsAdvancedCustomDrawItem(Sender: TCustomTreeView;
      Node: TTreeNode; State: TCustomDrawState; Stage: TCustomDrawStage;
      var {%H-}PaintImages, DefaultDraw: Boolean);
  private
    function GetFilter: TDBGEventCategories;
  private
    FEvents: TStringList;
    procedure UpdateFilteredList;
    property Filter: TDBGEventCategories read GetFilter;
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    procedure SetEvents(const AEvents: TStrings);
    procedure GetEvents(const AResultEvents: TStrings);
    procedure Clear;
    procedure AddEvent(const ACategory: TDBGEventCategory; const AEventType: TDBGEventType; const AText: String);
  end; 

implementation

{$R *.lfm}

var
  EventsDlgWindowCreator: TIDEWindowCreator;

type
  TCustomTreeViewAccess = class(TCustomTreeView);

{ TDbgEventsForm }

procedure TDbgEventsForm.tvFilteredEventsAdvancedCustomDrawItem(
  Sender: TCustomTreeView; Node: TTreeNode; State: TCustomDrawState;
  Stage: TCustomDrawStage; var PaintImages, DefaultDraw: Boolean);
var
  Rec: TDBGEventRec;
  NodeRect, TextRect: TRect;
  TextY: Integer;
begin
  DefaultDraw := Stage <> cdPrePaint;
  if DefaultDraw then Exit;

  Rec.Ptr := Node.Data;

  if cdsSelected in State then
  begin
    Sender.Canvas.Brush.Color := EnvironmentDebugOpts.DebuggerEventLogColors[TDBGEventType(Rec.EventType)].Foreground;
    Sender.Canvas.Font.Color := EnvironmentDebugOpts.DebuggerEventLogColors[TDBGEventType(Rec.EventType)].Background;
  end
  else
  begin
    Sender.Canvas.Brush.Color := EnvironmentDebugOpts.DebuggerEventLogColors[TDBGEventType(Rec.EventType)].Background;
    Sender.Canvas.Font.Color := EnvironmentDebugOpts.DebuggerEventLogColors[TDBGEventType(Rec.EventType)].Foreground;
  end;

  NodeRect := Node.DisplayRect(False);
  TextRect := Node.DisplayRect(True);
  TextY := (TextRect.Top + TextRect.Bottom - Sender.Canvas.TextHeight(Node.Text)) div 2;
  Sender.Canvas.FillRect(NodeRect);
  imlMain.Draw(Sender.Canvas, TCustomTreeViewAccess(Sender).Indent shr 2 + 1 - TCustomTreeViewAccess(Sender).ScrolledLeft, (NodeRect.Top + NodeRect.Bottom - imlMain.Height) div 2,
      Node.ImageIndex, True);
  Sender.Canvas.TextOut(TextRect.Left, TextY, Node.Text);
end;

function TDbgEventsForm.GetFilter: TDBGEventCategories;
begin
  Result := [];
  if EnvironmentDebugOpts.DebuggerEventLogShowBreakpoint then
    Include(Result, ecBreakpoint);
  if EnvironmentDebugOpts.DebuggerEventLogShowProcess then
    Include(Result, ecProcess);
  if EnvironmentDebugOpts.DebuggerEventLogShowThread then
    Include(Result, ecThread);
  if EnvironmentDebugOpts.DebuggerEventLogShowModule then
    Include(Result, ecModule);
  if EnvironmentDebugOpts.DebuggerEventLogShowOutput then
    Include(Result, ecOutput);
  if EnvironmentDebugOpts.DebuggerEventLogShowWindows then
    Include(Result, ecWindows);
  if EnvironmentDebugOpts.DebuggerEventLogShowDebugger then
    Include(Result, ecDebugger);
end;

procedure TDbgEventsForm.EditCopy1Execute(Sender: TObject);
begin
  Clipboard.Open;
  Clipboard.AsText := tvFilteredEvents.Selected.Text;
  Clipboard.Close;
end;

procedure TDbgEventsForm.actClearExecute(Sender: TObject);
begin
  Clear;
end;

procedure TDbgEventsForm.actOptionsExecute(Sender: TObject);
begin
  LazarusIDE.DoOpenIDEOptions(TDebuggerEventLogOptionsFrame);
end;

procedure TDbgEventsForm.actAddCommentExecute(Sender: TObject);
var
  S: String;
begin
  S := '';
  if InputQuery(lisMenuViewDebugEvents, lisEventsLogAddComment2, S) then
    AddEvent(ecDebugger, etDefault, S);
end;

procedure TDbgEventsForm.actSaveExecute(Sender: TObject);
var
  SaveDialog: TSaveDialog;
  AFilename: String;
begin
  SaveDialog := TSaveDialog.Create(nil);
  try
    InputHistories.ApplyFileDialogSettings(SaveDialog);
    SaveDialog.Title   := lisMVSaveMessagesToFileTxt;
    SaveDialog.Options := SaveDialog.Options + [ofPathMustExist];
    if SaveDialog.Execute then
    begin
      AFilename := CleanAndExpandFilename(SaveDialog.Filename);
      if ExtractFileExt(AFilename) = '' then
        AFilename := AFilename + '.txt';
      FEvents.SaveToFile(AFilename);
    end;
    InputHistories.StoreFileDialogSettings(SaveDialog);
  finally
    SaveDialog.Free;
  end;
end;

procedure TDbgEventsForm.EditCopy1Update(Sender: TObject);
begin
  EditCopy1.Enabled := Assigned(tvFilteredEvents.Selected);
end;

procedure TDbgEventsForm.UpdateFilteredList;
const
  CategoryImages: array [TDBGEventCategory] of Integer = (
    { ecBreakpoint } 0,
    { ecProcess    } 1,
    { ecThread     } 2,
    { ecModule     } 3,
    { ecOutput     } 4,
    { ecWindows    } 5,
    { ecDebugger   } 6
  );

var
  i: Integer;
  Item: TTreeNode;
  Rec: TDBGEventRec;
  Cat: TDBGEventCategory;
begin
  tvFilteredEvents.BeginUpdate;
  try
    tvFilteredEvents.Items.Clear;
    for i := 0 to FEvents.Count -1 do
    begin
      Rec.Ptr := FEvents.Objects[i];
      Cat := TDBGEventCategory(Rec.Category);

      if Cat in Filter then
      begin
        Item := tvFilteredEvents.Items.AddChild(nil, FEvents[i]);
        Item.Data := FEvents.Objects[i];
        Item.ImageIndex := CategoryImages[Cat];
        Item.SelectedIndex := CategoryImages[Cat];
      end;
    end;
  finally
    tvFilteredEvents.EndUpdate;
  end;
  // To be a smarter and restore the active Item, we would have to keep a link
  //between the lstFilteredEvents item and FEvents index, and account items
  //removed from FEvents because of log limit.
  // Also, TopItem and GetItemAt(0,0) both return nil in gtk2.
  if tvFilteredEvents.Items.Count <> 0 then
  begin
    tvFilteredEvents.Items[tvFilteredEvents.Items.Count - 1].MakeVisible;
    tvFilteredEvents.Selected := tvFilteredEvents.Items[tvFilteredEvents.Items.Count - 1];
  end;
end;

procedure TDbgEventsForm.SetEvents(const AEvents: TStrings);
begin
  if AEvents <> nil then
    FEvents.Assign(AEvents)
  else
    FEvents.Clear;

  UpdateFilteredList;
end;

procedure TDbgEventsForm.GetEvents(const AResultEvents: TStrings);
begin
  AResultEvents.Assign(FEvents);
end;

procedure TDbgEventsForm.Clear;
begin
  FEvents.Clear;
  tvFilteredEvents.Items.Clear;
end;

constructor TDbgEventsForm.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  Caption := lisMenuViewDebugEvents;
  actClear.Caption := lisEventLogClear;
  actSave.Caption := lisEventLogSaveToFile;
  actAddComment.Caption := lisEventsLogAddComment;
  actOptions.Caption := lisEventLogOptions;
  FEvents := TStringList.Create;
  PopupMenu1.Images := IDEImages.Images_16;
  actOptions.ImageIndex := IDEImages.LoadImage('menu_environment_options');
end;

destructor TDbgEventsForm.Destroy;
begin
  FreeAndNil(FEvents);
  inherited Destroy;
end;

procedure TDbgEventsForm.AddEvent(const ACategory: TDBGEventCategory; const AEventType: TDBGEventType; const AText: String);
var
  Item: TTreeNode;
  Rec: TDBGEventRec;
begin
  if EnvironmentDebugOpts.DebuggerEventLogCheckLineLimit then
  begin
    tvFilteredEvents.BeginUpdate;
    try
      while tvFilteredEvents.Items.Count >= EnvironmentDebugOpts.DebuggerEventLogLineLimit do
        tvFilteredEvents.Items.Delete(tvFilteredEvents.Items[0]);
    finally
      tvFilteredEvents.EndUpdate;
    end;
  end;
  Rec.Category := Ord(ACategory);
  Rec.EventType := Ord(AEventType);
  FEvents.AddObject(AText, TObject(Rec.Ptr));
  if ACategory in Filter then
  begin
    Item := tvFilteredEvents.Items.AddChild(nil, AText);
    Item.ImageIndex := Rec.Category;
    Item.SelectedIndex := Rec.Category;
    Item.Data := Rec.Ptr;
    Item.MakeVisible;
    tvFilteredEvents.Selected := Item;
  end;
end;

initialization

  EventsDlgWindowCreator := IDEWindowCreators.Add(DebugDialogNames[ddtEvents]);
  EventsDlgWindowCreator.OnCreateFormProc := @CreateDebugDialog;
  EventsDlgWindowCreator.CreateSimpleLayout;

end.

