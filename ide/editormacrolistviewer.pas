{
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

  Abstract:
    A GUI for managing editor macros.
}
unit EditorMacroListViewer;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils,
  // LCL
  LCLType, Forms, Controls, Dialogs, StdCtrls, ButtonPanel, ComCtrls, ExtCtrls,
  Spin, Menus, Buttons,
  // LazUtils
  LazFileUtils, LazStringUtils, Laz2_XMLCfg, LazUTF8, LazLoggerBase,
  // SynEdit
  SynMacroRecorder, SynEdit, SynEditKeyCmds,
  // IdeIntf
  IdeIntfStrConsts, IDEWindowIntf, IDEImagesIntf, SrcEditorIntf, IDEHelpIntf, IDECommands,
  LazIDEIntf, IDEDialogs,
  // IDE
  LazarusIDEStrConsts, ProjectDefs, LazConf, Project, KeyMapping,
  KeyMapShortCutDlg, MainIntf, ToolBarIntf;

type
  TSynEditorMacro = class(TSynMacroRecorder)
  end;

  { TIdeEditorMacro }

  TIdeEditorMacro = class(TEditorMacro)
  private
    FMacroName: String;
    FHasError: Boolean;
    FErrorMsg: String;
    FFailedText: String;
    FSynMacro: TSynEditorMacro;
    FKeyBinding: TEditorMacroKeyBinding;

    procedure DoMacroRecorderState(Sender: TObject);
    procedure DoMacroRecorderUserCommand({%H-}aSender: TCustomSynMacroRecorder;
                aCmd: TSynEditorCommand; var aEvent: TSynMacroEvent);
  protected
    function  GetMacroName: String; override;
    procedure SetMacroName(AValue: string); override;
    function  GetState: TEditorMacroState; override;
    function  GetErrorMsg: String; override;
    function  GetKeyBinding: TEditorMacroKeyBinding; override;

    procedure DoRecordMacro(aEditor: TWinControl); override;
    procedure DoPlaybackMacro(aEditor: TWinControl); override;
    procedure DoStop; override;
    procedure DoPause; override;
    procedure DoResume; override;
  public
    constructor Create(aOwner: TComponent); override;
    destructor Destroy; override;
    procedure AssignEventsFrom(AMacroRecorder: TEditorMacro); override;
    function  AddEditor(AValue: TCustomSynEdit): integer;
    procedure Clear; override;

    function  GetAsSource: String; override;
    procedure SetFromSource(const AText: String); override;
    procedure WriteToXmlConf(AConf: TXMLConfig; const APath: String); override;
    procedure ReadFromXmlConf(AConf: TXMLConfig; const APath: String); override;

    function  IsEmpty: Boolean; override;
    function  IsInvalid: Boolean; override;
    function  IsRecording(AnEditor: TWinControl): Boolean; override;
  end;


  { TIdeEditorMacroKeyBinding }

  TIdeEditorMacroKeyBinding = class(TEditorMacroKeyBinding)
  protected
    FIdeCmd: TIDECommand;
    function  GetIdeCmd: TIDECommand; override;
    procedure ExecMacro(Sender: TObject);
  public
    destructor Destroy; override;
    procedure WriteToXmlConf(AConf: TXMLConfig; const APath: String); override;
    procedure ReadFromXmlConf(AConf: TXMLConfig; const APath: String); override;
    procedure MacroNameChanged; override;
    function  ShortCutAsText: String; override;
  end;

  { TIdeMacroEventWriter }

  TIdeMacroEventWriter = class(TSynMacroEventWriter)
  private
    FText: String;
    FCmdName, FParams: String;
    FUseLineFeed: Boolean;
  public
    constructor Create;
    procedure BeginEvent;
    procedure FinishEvent;
    procedure WriteEventCommand(const ACmd: TSynEditorCommand); override;
    procedure WriteEventParam(const AParam: string); override;
    procedure WriteEventParam(const AParam: integer); override;
    property Text: String read FText;
    property UseLineFeed: Boolean read FUseLineFeed write FUseLineFeed;
  end;

  { TIdeMacroEventReader }

  TIdeMacroEventReader = class(TSynMacroEventReader)
  private
    FErrorText: String;
    FEventName: String;
    FHasError: Boolean;
    FText, FOrigText: String;
    FPos, FPosCompensate: Integer;
    FEventCommand: TSynEditorCommand;
    FParams: Array of record
        ParamType: TSynEventParamType;
        Text : String;
        Num: Integer;
      end;
  protected
    function GetParamAsInt(Index: Integer): Integer; override;
    function GetParamAsString(Index: Integer): String; override;
    function GetParamType(Index: Integer): TSynEventParamType; override;
    function PosToXY: TPoint;
    function AddError(AMsg: string): Boolean;
  public
    constructor Create(const Atext: String);
    function  EventCommand: TSynEditorCommand; override;
    function  ParamCount: Integer; override;
    function  ParseNextEvent: Boolean;
    property  EventName: String read FEventName;
    property  HasError: Boolean read FHasError;
    property  ErrorText: String read FErrorText;
  end;

  { TEditorMacroList }

  TEditorMacroList = class;
  TMacroAddedEvent = procedure(AList: TEditorMacroList; AMacro: TEditorMacro) of object;

  TEditorMacroList = class
  private
    FList: TList;
    FOnAdded: TMacroAddedEvent;
    FOnChange: TNotifyEvent;
    FOnRemove: TMacroAddedEvent;
    function GetMacros(Index: Integer): TEditorMacro;
    procedure DoChanged;
    procedure DoAdded(AMacro: TEditorMacro);
    procedure DoRemove(AMacro: TEditorMacro);
  public
    constructor Create;
    destructor Destroy; override;
    procedure WriteToXmlConf(AConf: TXMLConfig; const APath: String);
    procedure ReadFromXmlConf(AConf: TXMLConfig; const APath: String);
    procedure ClearAndFreeMacros;
    function Count: Integer;
    function IndexOf(AMacro: TEditorMacro): Integer;
    function IndexOfName(AName: String): Integer;
    function UniqName(AName: String): String;
    function Add(AMacro: TEditorMacro): Integer;
    procedure Delete(AnIndex: Integer);
    procedure Remove(AMacro: TEditorMacro);
    property Macros[Index: Integer]: TEditorMacro read GetMacros;
    property OnChange: TNotifyEvent read FOnChange write FOnChange;
    property OnAdded: TMacroAddedEvent read FOnAdded write FOnAdded;
    property OnRemove: TMacroAddedEvent read FOnRemove write FOnRemove;
  end;

  { TMacroListView }

  TMacroListView = class(TForm)
    btnDelete: TBitBtn;
    btnEdit: TBitBtn;
    btnPlay: TBitBtn;
    btnRecord: TBitBtn;
    btnRecordStop: TBitBtn;
    btnAddEditNew: TBitBtn;
    btnRename: TBitBtn;
    btnSelect: TBitBtn;
    btnSetKeys: TBitBtn;
    BtnWarnClose: TSpeedButton;
    ButtonPanel1: TButtonPanel;
    chkRepeat: TCheckBox;
    gbAddMacro: TGroupBox;
    LabelWarning: TLabel;
    lbMoveTo: TLabel;
    lbMacroView: TListView;
    mnExport: TMenuItem;
    mnImport: TMenuItem;
    OpenDialog1: TOpenDialog;
    Panel1: TPanel;
    PanelWarnings: TPanel;
    PanelRepeat: TPanel;
    pnlButtons: TPanel;
    PopupMenu1: TPopupMenu;
    RenameButton: TPanelBitBtn;
    edRepeat: TSpinEdit;
    SaveDialog1: TSaveDialog;
    ToolBar1: TToolBar;
    tbRecorded: TToolButton;
    tbProject: TToolButton;
    tbIDE: TToolButton;
    ToolBar2: TToolBar;
    tbMoveProject: TToolButton;
    tbMoveIDE: TToolButton;
    ToolButton3: TToolButton;
    ToolButton4: TToolButton;
    procedure btnDeleteClick(Sender: TObject);
    procedure btnEditClick(Sender: TObject);
    procedure btnPlayClick(Sender: TObject);
    procedure btnRecordClick(Sender: TObject);
    procedure btnAddEditNewClick(Sender: TObject);
    procedure btnRecordStopClick(Sender: TObject);
    procedure btnRenameClick(Sender: TObject);
    procedure btnSelectClick(Sender: TObject);
    procedure btnSetKeysClick(Sender: TObject);
    procedure BtnWarnCloseClick(Sender: TObject);
    procedure FormActivate(Sender: TObject);
    procedure HelpButtonClick(Sender: TObject);
    procedure lbMacroViewSelectItem(Sender: TObject; {%H-}Item: TListItem; {%H-}Selected: Boolean);
    procedure mnExportClick(Sender: TObject);
    procedure mnImportClick(Sender: TObject);
    procedure tbIDEClick(Sender: TObject);
    procedure tbMoveIDEClick(Sender: TObject);
    procedure tbMoveProjectClick(Sender: TObject);
    procedure tbProjectClick(Sender: TObject);
    procedure tbRecordedClick(Sender: TObject);
  private
    FImageReady: Integer;
    FImageRec: Integer;
    FImagePlay: Integer;
    FImageSel: Integer;
    FImageErr: Integer;
    FIsPlaying: Boolean;
    FIgnoreMacroChanges: Boolean;
    procedure DoOnMacroListChange(Sender: TObject);
    procedure DoMacroContentChanged(Sender: TObject);
    procedure DoMacroStateChanged(Sender: TObject);
    procedure UpdateButtons;
  protected
    procedure DoEditorMacroStateChanged;
  public
    constructor Create(TheOwner: TComponent); override;
    destructor Destroy; override;
    function  MacroByFullName(AName: String): TEditorMacro;
    procedure UpdateDisplay;
  end;

  { TMacrosToolButton }

  TMacrosToolButton = class(TIDEToolButton)
  private
    procedure AddList(AList: TEditorMacroList);
    procedure AddMenuItem(AMacro: TEditorMacro);
    procedure RefreshMenu(Sender: TObject);
    procedure mnuPlayMacro(Sender: TObject);
  public
    procedure DoOnAdded; override;
  end;


function MacroListViewer: TMacroListView;
procedure ShowMacroListViewer;
procedure UpdateMacroListViewer;
procedure DoEditorMacroStateChanged;

procedure LoadProjectSpecificInfo(XMLConfig: TXMLConfig);
procedure SaveProjectSpecificInfo(XMLConfig: TXMLConfig; Flags: TProjectWriteFlags);
procedure LoadGlobalInfo;
procedure SaveGlobalInfo;

var
  OnKeyMapReloaded: procedure of object;
  OnEditorMacroStateChange: TNotifyEvent;
  // SelectedEditorMacro: Selected, for playing with default shortcut
  SelectedEditorMacro: TEditorMacro = nil;

const
  EditorMacroVirtualDrive = '%Macro:|'; // do not use \ or /, they can be converted by the IDE

implementation

var
  MacroListView: TMacroListView = nil;

  CurrentEditorMacroList: TEditorMacroList = nil;
  EditorMacroListRec, EditorMacroListProj, EditorMacroListGlob: TEditorMacroList;

  // CurrentRecordingMacro:
  // The player-macro, to wich the recording in process will be assigned
  CurrentRecordingMacro: TEditorMacro = nil;

  MacroRecCounter: Integer = 1;
  KeyCategory: TIDECommandCategory = nil;

const
  GlobalConfFileName = 'EditorMacros.xml';

procedure DoMacroListViewerWarningChanged({%H-}Sender: TObject);
begin
  if MacroListView = nil then exit;
  MacroListView.LabelWarning.Caption := MacroListViewerWarningText;
  MacroListView.PanelWarnings.Visible := MacroListViewerWarningText <> '';
end;

function MacroListViewer: TMacroListView;
begin
  if MacroListView = nil then
    MacroListView := TMacroListView.Create(Application);
  Result := MacroListView;
  DoMacroListViewerWarningChanged(nil);
end;

procedure ShowMacroListViewer;
begin
  IDEWindowCreators.ShowForm(MacroListViewer, True);
end;

procedure UpdateMacroListViewer;
begin
  if MacroListView <> nil then
    MacroListView.UpdateDisplay;
end;

function MacroListToName(AList: TEditorMacroList): string;
begin
  Result := '';
  if AList = EditorMacroListRec then Result := 'Rec'
  else if AList = EditorMacroListProj then Result := 'Prj'
  else if AList = EditorMacroListGlob then Result := 'Ide';
end;

function NameToMacroList(AName: string): TEditorMacroList;
begin
  Result := nil;
  if AName = 'Rec' then Result := EditorMacroListRec
  else if AName = 'Prj' then Result := EditorMacroListProj
  else if AName = 'Ide' then Result := EditorMacroListGlob;
end;

procedure DoEditorMacroStateChanged;
begin
  if EditorMacroForRecording= nil then exit;

  if not(EditorMacroForRecording.State in [emRecording, emRecPaused]) and
    (CurrentRecordingMacro <> nil)
  then begin
    // finished recording
    if EditorMacroForRecording.IsEmpty then begin
      EditorMacroListRec.Remove(CurrentRecordingMacro);
      FreeAndNil(CurrentRecordingMacro);
    end else begin
      CurrentRecordingMacro.AssignEventsFrom(EditorMacroForRecording);
      SelectedEditorMacro := CurrentRecordingMacro;
      CurrentRecordingMacro := nil;
    end;
  end;

  if (EditorMacroForRecording.State = emRecording) and (CurrentRecordingMacro = nil) then begin
    CurrentRecordingMacro := EditorMacroPlayerClass.Create(nil);
    CurrentRecordingMacro.OnStateChange := @MacroListViewer.DoMacroStateChanged;
    CurrentRecordingMacro.OnChange := @MacroListViewer.DoMacroContentChanged;
    CurrentRecordingMacro.MacroName := Format(lisNewMacroName, [MacroRecCounter]);
    inc(MacroRecCounter);
    EditorMacroListRec.Add(CurrentRecordingMacro);
  end;

  if MacroListView <> nil then
    MacroListView.DoEditorMacroStateChanged;
end;

procedure LoadProjectSpecificInfo(XMLConfig: TXMLConfig);
begin
  if MacroListView<>nil then
    MacroListView.FIgnoreMacroChanges := True;
  try
    EditorMacroListProj.ReadFromXmlConf(XMLConfig, '');
  finally
    if MacroListView<>nil then
      MacroListView.FIgnoreMacroChanges := False;
  end;
end;

procedure SaveProjectSpecificInfo(XMLConfig: TXMLConfig; Flags: TProjectWriteFlags);
begin
  if not (pwfSkipSeparateSessionInfo in Flags) then
  begin
    EditorMacroListProj.WriteToXmlConf(XMLConfig, '');
  end;
end;

procedure LoadGlobalInfo;
var
  Filename: String;
  XMLConfig: TXMLConfig;
begin
  if MacroListView<>nil then
    MacroListView.FIgnoreMacroChanges := True;
  Filename := TrimFilename(AppendPathDelim(GetPrimaryConfigPath)+GlobalConfFileName);
  try
    XMLConfig := TXMLConfig.Create(Filename);
    try
      EditorMacroListGlob.ReadFromXmlConf(XMLConfig, '');
    finally
      XMLConfig.Free;
    end;
  except
    on E: Exception do begin
      DebugLn('[EditorMacroListViewer.LoadGlobalInfo]  error reading "',Filename,'": ',E.Message);
    end;
  end;
  if MacroListView<>nil then
    MacroListView.FIgnoreMacroChanges := False;
end;

procedure SaveGlobalInfo;
var
  Filename: String;
  XMLConfig: TXMLConfig;
begin
  Filename := TrimFilename(AppendPathDelim(GetPrimaryConfigPath)+GlobalConfFileName);
  try
    XMLConfig := TXMLConfig.CreateClean(Filename);
    try
      EditorMacroListGlob.WriteToXmlConf(XMLConfig, '');
    finally
      XMLConfig.Free;
    end;
  except
    on E: Exception do begin
      DebugLn('[EditorMacroListViewer.SaveGlobalInfo]  error writing "',Filename,'": ',E.Message);
    end;
  end;
end;

{ TIdeEditorMacroKeyBinding }

function TIdeEditorMacroKeyBinding.GetIdeCmd: TIDECommand;
begin
  Result := FIdeCmd;
end;

procedure TIdeEditorMacroKeyBinding.ExecMacro(Sender: TObject);
begin
  if ActiveEditorMacro <> nil then exit;
  FOwner.PlaybackMacro(TCustomSynEdit(SourceEditorManagerIntf.ActiveEditor.EditorControl));
end;

procedure TIdeEditorMacroKeyBinding.MacroNameChanged;
begin
  if (IDECommandList = nil) then
    exit;

  if FOwner.IsInvalid then begin
    if FIdeCmd <> nil then begin
      (IDECommandList as TKeyCommandRelationList).RemoveCommand(FIdeCmd);
      FreeAndNil(FIdeCmd);
    end;
    exit;
  end;

  if KeyCategory = nil then
    KeyCategory := IDECommandList.CreateCategory(nil, 'EditorMacros',
      'Editor Macros', IDECmdScopeSrcEditOnly);

  if FIdeCmd = nil then begin
    FIdeCmd := (IDECommandList as TKeyCommandRelationList).CreateCommand(
      KeyCategory,
      'EdtMacro'+FOwner.MacroName,
      FOwner.MacroName,
      IDEShortCut(VK_UNKNOWN, [], VK_UNKNOWN, []),
      IDEShortCut(VK_UNKNOWN, [], VK_UNKNOWN, []),
      @ExecMacro, nil
    );
    (FIdeCmd as TKeyCommandRelation).SkipSaving := True;
  end
  else
    FIdeCmd.LocalizedName := FOwner.MacroName;

end;

destructor TIdeEditorMacroKeyBinding.Destroy;
begin
  inherited Destroy;
  if (FIdeCmd <> nil) and (IDECommandList <> nil) then begin
    (IDECommandList as TKeyCommandRelationList).RemoveCommand(FIdeCmd);
    FreeAndNil(FIdeCmd);
  end;
end;

procedure TIdeEditorMacroKeyBinding.WriteToXmlConf(AConf: TXMLConfig; const APath: String);
  procedure ClearKey(const SubPath: string);
  begin
    AConf.DeleteValue(SubPath+'Key1');
    AConf.DeleteValue(SubPath+'Shift1');
    AConf.DeleteValue(SubPath+'Key2');
    AConf.DeleteValue(SubPath+'Shift2');
  end;
  procedure Store(const SubPath: string; Key: TIDEShortCut);
  var
    s: TShiftState;
  begin
    AConf.SetDeleteValue(SubPath+'Key1', key.Key1, VK_UNKNOWN);
    if key.Key1=VK_UNKNOWN then
      s:=[]
    else
      s:=key.Shift1;
    AConf.SetDeleteValue(SubPath+'Shift1',ShiftStateToCfgStr(s),ShiftStateToCfgStr([]));
    AConf.SetDeleteValue(SubPath+'Key2',key.Key2,VK_UNKNOWN);
    if key.Key2=VK_UNKNOWN then
      s:=[]
    else
      s:=key.Shift2;
    AConf.SetDeleteValue(SubPath+'Shift2',ShiftStateToCfgStr(s),ShiftStateToCfgStr([]));
  end;

begin
  if (FIdeCmd = nil) then begin
    ClearKey(APath + 'KeyA/');
    ClearKey(APath + 'KeyB/');
  end else begin
    Store(APath + 'KeyA/', FIdeCmd.ShortcutA);
    Store(APath + 'KeyB/', FIdeCmd.ShortcutB);
  end;
end;

procedure TIdeEditorMacroKeyBinding.ReadFromXmlConf(AConf: TXMLConfig; const APath: String);
  procedure Load(SubPath: string; out Key: TIDEShortCut);
  begin
    key.Key1   := AConf.GetValue(SubPath+'Key1',VK_UNKNOWN);
    key.Shift1 := CfgStrToShiftState(AConf.GetValue(SubPath+'Shift1',''));
    key.Key2   := AConf.GetValue(SubPath+'Key2',VK_UNKNOWN);
    key.Shift2 := CfgStrToShiftState(AConf.GetValue(SubPath+'Shift2',''));
  end;
var
  SCut: TIDEShortCut;
begin
  if (FIdeCmd <> nil) then begin
    Load(APath+'KeyA/', SCut);
    if (IDECommandList as TKeyCommandRelationList).Find(SCut, TSourceEditorWindowInterface) = nil then
      FIdeCmd.ShortcutA := SCut;

    Load(APath+'KeyB/', SCut);
    if (IDECommandList as TKeyCommandRelationList).Find(SCut, TSourceEditorWindowInterface) = nil then
      FIdeCmd.ShortcutB := SCut;
  end;
end;

function TIdeEditorMacroKeyBinding.ShortCutAsText: String;
begin
  Result := '';
  If FIdeCmd = nil then
    exit;
  if not IDEShortCutEmpty(FIdeCmd.ShortcutA) then
    Result := Result + ' (' + KeyAndShiftStateToEditorKeyString(FIdeCmd.ShortcutA) + ')';
  if not IDEShortCutEmpty(FIdeCmd.ShortcutB) then
    Result := Result + ' (' + KeyAndShiftStateToEditorKeyString(FIdeCmd.ShortcutB) + ')';
end;

{ TIdeEditorMacro }

function TIdeEditorMacro.GetMacroName: String;
begin
  Result := FMacroName;
end;

procedure TIdeEditorMacro.DoMacroRecorderState(Sender: TObject);
begin
  DoStateChanged;
  CheckStateAndActivated;
end;

procedure TIdeEditorMacro.DoMacroRecorderUserCommand(aSender: TCustomSynMacroRecorder;
  aCmd: TSynEditorCommand; var aEvent: TSynMacroEvent);
begin
  case aCmd of
    ecSynMacroPlay, ecSynMacroRecord,
    ecToggleFormUnit..ecViewThreads, ecViewHistory,
    ecNextEditor, ecPrevEditor, ecNextWindow, ecPrevWindow,
    ecPrevEditorInHistory, ecNextEditorInHistory,
    ecGotoEditor1..ecGotoEditor0:
      aEvent := TSynSkippedEvent.Create;
    else
      ;//
  end;
end;

function TIdeEditorMacro.GetState: TEditorMacroState;
begin
  case FSynMacro.state of
    msStopped:   Result := emStopped;
    msRecording: Result := emRecording;
    msPlaying:   Result := emPlaying;
    msPaused:    Result := emRecPaused;
  end;
end;

function TIdeEditorMacro.GetErrorMsg: String;
begin
  Result := FErrorMsg;
end;

function TIdeEditorMacro.GetKeyBinding: TEditorMacroKeyBinding;
begin
  if FKeyBinding = nil then
    FKeyBinding := GetDefaultKeyBinding;
  Result := FKeyBinding;
end;

procedure TIdeEditorMacro.SetMacroName(AValue: string);
begin
  FMacroName := AValue;
  FSynMacro.MacroName := AValue;
  DoChanged;
end;

constructor TIdeEditorMacro.Create(aOwner: TComponent);
begin
  FSynMacro := TSynEditorMacro.Create(aOwner);
  FHasError := False;

  FSynMacro.OnUserCommand   := @DoMacroRecorderUserCommand;
  FSynMacro.OnStateChange  := @DoMacroRecorderState;
  FSynMacro.RecordCommandID := ecNone; // ecSynMacroRecord;
  FSynMacro.PlaybackCommandID := ecNone; // ecSynMacroPlay;
  FSynMacro.RecordShortCut := 0;
  FSynMacro.PlaybackShortCut := 0;
end;

destructor TIdeEditorMacro.Destroy;
begin
  inherited Destroy;
  FreeAndNil(FSynMacro);
  FreeAndNil(FKeyBinding);
end;

procedure TIdeEditorMacro.AssignEventsFrom(AMacroRecorder: TEditorMacro);
begin
  if AMacroRecorder = nil then
    Clear
  else
  if AMacroRecorder is TIdeEditorMacro then
    FSynMacro.AssignEventsFrom(TIdeEditorMacro(AMacroRecorder).FSynMacro)
  else
    SetFromSource(AMacroRecorder.GetAsSource);

  DoChanged;
end;

function TIdeEditorMacro.AddEditor(AValue: TCustomSynEdit): integer;
begin
  Result := FSynMacro.AddEditor(AValue);
end;

procedure TIdeEditorMacro.DoRecordMacro(aEditor: TWinControl);
begin
  FSynMacro.RecordMacro(aEditor as TCustomSynEdit);
end;

procedure TIdeEditorMacro.DoPlaybackMacro(aEditor: TWinControl);
begin
  FSynMacro.PlaybackMacro(aEditor as TCustomSynEdit);
end;

procedure TIdeEditorMacro.DoStop;
begin
  FSynMacro.Stop;
end;

procedure TIdeEditorMacro.DoPause;
begin
  FSynMacro.Pause;
end;

procedure TIdeEditorMacro.DoResume;
begin
  FSynMacro.Resume;
end;

procedure TIdeEditorMacro.Clear;
begin
  FSynMacro.Clear;
  DoChanged;
end;

function TIdeEditorMacro.GetAsSource: String;
var
  i : integer;
  W: TIdeMacroEventWriter;
begin
  if FHasError then begin
    Result := FFailedText;
    exit;
  end;

  W := TIdeMacroEventWriter.Create;
  W.UseLineFeed := True;
  try
    for i := 0 to FSynMacro.EventCount -1 do
    begin
      W.BeginEvent;
      FSynMacro.Events[i].SaveToWriter(W);
      W.FinishEvent;
    end;
    Result := w.Text;
  finally
    W.Free;
  end;
end;

procedure TIdeEditorMacro.SetFromSource(const AText: String);
var
  iEvent: TSynMacroEvent;
  R: TIdeMacroEventReader;
begin
  Stop;
  FSynMacro.Clear;
  FHasError := False;

  R := TIdeMacroEventReader.Create(AText);
  try
    while R.ParseNextEvent do begin
      iEvent := FSynMacro.CreateMacroEvent(R.EventCommand);
      iEvent.LoadFromReader(R);
      FSynMacro.InsertCustomEvent(FSynMacro.EventCount, iEvent);
    end;
    if R.HasError then begin
      FHasError := True;
      FErrorMsg := R.ErrorText;
      FFailedText := AText;
      MacroName := MacroName;
    end;
  finally
    R.Free;
  end;
  DoChanged;
end;

procedure TIdeEditorMacro.WriteToXmlConf(AConf: TXMLConfig; const APath: String);
begin
  AConf.SetValue(APath + 'Name', MacroName);
  AConf.SetValue(APath + 'Code/Value', GetAsSource);

  if (KeyBinding <> nil) then
    KeyBinding.WriteToXmlConf(AConf, APath);
end;

procedure TIdeEditorMacro.ReadFromXmlConf(AConf: TXMLConfig; const APath: String);
var
  s: String;
begin
  s := AConf.GetValue(APath + 'Code/Value', '');
  SetFromSource(s);
  s := AConf.GetValue(APath + 'Name', '');
  if s <> '' then MacroName := s;

  if (not FHasError) and (FSynMacro.EventCount = 0) then begin
    FHasError := True;
    FErrorMsg := 'No content found';
    FFailedText := s;
  end;

  if (KeyBinding <> nil) then
    KeyBinding.ReadFromXmlConf(AConf, APath);

  DoChanged;
end;

function TIdeEditorMacro.IsEmpty: Boolean;
begin
  Result := FSynMacro.IsEmpty;
end;

function TIdeEditorMacro.IsInvalid: Boolean;
begin
  Result := FHasError;
end;

function TIdeEditorMacro.IsRecording(AnEditor: TWinControl): Boolean;
begin
  Result := (State in [emRecording, emRecPaused]) and
            (FSynMacro.CurrentEditor = AnEditor);
end;

{ TIdeMacroEventReader }

function TIdeMacroEventReader.GetParamAsInt(Index: Integer): Integer;
begin
  if (Index < 0) or (Index >= Length(FParams)) or (ParamType[Index] <> ptInteger)
  then begin
    FHasError := True;
    AddError('Wrong amount of param');
    exit(0);
  end;
  Result := FParams[Index].Num;
end;

function TIdeMacroEventReader.GetParamAsString(Index: Integer): String;
begin
  if (Index < 0) or (Index >= Length(FParams)) or (ParamType[Index] <> ptString)
  then begin
    FHasError := True;
    AddError('Wrong amount of param');
    exit('');
  end;
  Result := FParams[Index].Text;
end;

function TIdeMacroEventReader.GetParamType(Index: Integer): TSynEventParamType;
begin
  if (Index < 0) or (Index >= Length(FParams)) then begin
    FHasError := True;
    AddError('Wrong amount of param');
    exit(ptString); // What to return here?
  end;
  Result := FParams[Index].ParamType;
end;

function TIdeMacroEventReader.PosToXY: TPoint;
var
  f: TStringList;
begin
  f := TStringList.Create;
  f.Text := copy(FOrigText,1 ,FPos);
  if f.Count = 0 then begin
    Result.y := 1;
    Result.x := 1;
  end
  else begin
    Result.y := f.Count;
    Result.x := length(f[f.Count-1])+1;
  end;
  f.Free;
end;

function TIdeMacroEventReader.AddError(AMsg: string): Boolean;
var
  p: TPoint;
begin
  p := PosToXY;
  FErrorText := FErrorText + Format('Error: %s at Line %d, Column %d', [AMsg, p.y, p.x]);
  Result := False;
end;

constructor TIdeMacroEventReader.Create(const Atext: String);
var
  i: Integer;
  s: String;
begin
  FText := Atext;
  FOrigText := Atext;
  FHasError := False;
  FErrorText := '';
  FText := TrimRight(FText);
  FPosCompensate := Length(FOrigText) - Length(FText);
  FText := TrimLeft(FText);
  i := length(FText);
  if (i > 11) and
     LazStartsText('begin', FText) and
     (FText[6] in [#9,#10,#13,' ']) and
     LazEndsText('end.', FText) and
     (FText[i-4] in [#9,#10,#13,' '])
  then begin
    FText := copy(FText, 7, i-11);
    FPosCompensate := FPosCompensate + 4;
    s := TrimRight(FText);
    FPosCompensate := FPosCompensate + Length(FText) - Length(s);
    FText := Trim(FText);
  end;
end;

function TIdeMacroEventReader.EventCommand: TSynEditorCommand;
begin
  Result := FEventCommand;
end;

function TIdeMacroEventReader.ParamCount: Integer;
begin
  Result := Length(FParams);
end;

function TIdeMacroEventReader.ParseNextEvent: Boolean;
  procedure SkipNum(var i: integer);
  begin
    while (i <= Length(FText)) and (FText[i] in ['0'..'9']) do
      inc(i);
  end;
  procedure SkipSpace(var i: integer);
  begin
    while (i <= Length(FText)) and (FText[i] in [' ', #9, #13, #10]) do 
      inc(i);
  end;
var
  c,i,j,k: Integer;
  s: String;
begin
  FEventName := '';
  FText := TrimLeft(FText);

  Result := (FText <> '') and (not FHasError);
  if not Result then exit;
  Result := False;
  FPos := Length(FOrigText) - Length(FText) - FPosCompensate;

  FHasError := True; // Assume the worst

  i := 1;
  while (i <= Length(FText)) and (FText[i] in ['a'..'z','A'..'Z','0'..'9','_']) do
    inc(i);
  if i = 1 then exit(AddError('Expected Command, but found "'+UTF8Copy(FText,1,1)+'"'));

  s := Copy(FText, 1, i-1);
  j:=0;
  if not IdentToEditorCommand(s, j) then exit(AddError('Unknown Command "'+s+'"'));
  FEventCommand := j;
  FEventName := s;

  FPos := Length(FOrigText) - Length(FText) - FPosCompensate;
  while (i <= Length(FText)) and (FText[i] in [' ', #9]) do
    inc(i);
  if (i > Length(FText)) then exit(AddError('Expected "(" or ";" bot got end of file'));

  SetLength(FParams, 0);
  c := 0;

  if (FText[i] = '(') then begin
    inc(i);
    repeat
      SkipSpace(i);
      if (i > Length(FText)) then exit(AddError('Unexpected end of file in params'));

      if FText[i] in ['0'..'9'] then begin
        // Parse number
        j := i;
        SkipNum(i);
        SetLength(FParams, c + 1);
        FParams[c].ParamType := ptInteger;
        FParams[c].Num := StrToInt(copy(FText, j, i-j));
        inc(c);
      end
      else
      if FText[i] in ['#', ''''] then begin
        // Parse string
        s := '';
        repeat
          case FText[i] of
            ' ',#9,#10,#13: inc(i);
            '+': begin
                inc(i);
                if not (FText[i] in ['''', '#']) then exit(AddError('Expected string or char after +'));
              end;
            '#': begin
                inc(i);
                j := i;
                SkipNum(i);
                if i = j then exit(AddError('Expected number in string after #'));
                k := StrToInt(copy(FText, j, i-j));
                if k > 255 then exit(AddError('Argument to long'));
                s := s + chr(k);
              end;
            '''':  begin
                inc(i);
                repeat
                  case FText[i] of
                    '''': begin
                        if (i+1 <= Length(FText)) and (FText[i+1] = '''') then begin
                          s := s + '''';
                          inc(i,2);
                        end
                        else begin
                          inc(i);
                          break;
                        end;
                      end;
                    else begin
                        s := s + FText[i];
                        inc(i);
                      end;
                  end;
                until i > Length(FText);
              end;
            else
              break;
          end;
        until i > Length(FText);

        SetLength(FParams, c + 1);
        FParams[c].ParamType := ptString;
        FParams[c].Text := s;
        inc(c);
      end
      else
      if FText[i] <> ')' then
        exit(AddError('Unknown Arguent'));

      SkipSpace(i);
      if (i >= Length(FText)) then exit(AddError('Missing ")"'));
      if FText[i] = ')' then break;
      if not(FText[i] = ',') then exit(AddError('Expected ","'));
      inc(i);
    until i > Length(FText);
    inc(i);
  end;

  if (i > Length(FText)) then exit(AddError('Missing ";"'));
  if (FText[i] = ';') then begin
    Delete(FText, 1, i);
    Result := True;
    FHasError := False;
    exit;
  end;
  AddError('Unknown Error');
end;

{ TSynMacroEventWriter }

constructor TIdeMacroEventWriter.Create;
begin
  FUseLineFeed := False;
end;

procedure TIdeMacroEventWriter.BeginEvent;
begin
  FCmdName := '';
  FParams := '';
end;

procedure TIdeMacroEventWriter.FinishEvent;
begin
  FText := FText + FCmdName;
  if FParams <> '' then
    FText := FText + '(' + FParams + ')';
  FText := FText + ';';
  if FUseLineFeed then
    FText := FText + LineEnding;
end;

procedure TIdeMacroEventWriter.WriteEventCommand(const ACmd: TSynEditorCommand);
begin
  EditorCommandToIdent(ACmd, FCmdName);
end;

procedure TIdeMacroEventWriter.WriteEventParam(const AParam: string);
var
  s: String;
  i: Integer;
  InQuotes: Boolean;
begin
  if FParams <> '' then
    FParams := FParams + ', ';
  s := '';
  InQuotes := False;
  for i := 1 to length(AParam) do
    case AParam[i] of
      #0..#31: begin
          if InQuotes then s := s + '''';
          InQuotes := False;
          s := s + '#' + IntToStr(ord(AParam[i]));
        end;
      '''': begin
          if not InQuotes then s := s + '''';
          InQuotes := True;
          s := s + '''''';
        end;
      else begin
          if not InQuotes then s := s + '''';
          InQuotes := True;
          s := s + AParam[i];
        end;
    end;
  if InQuotes then s := s + '''';
  FParams := FParams + s;
end;

procedure TIdeMacroEventWriter.WriteEventParam(const AParam: integer);
begin
  if FParams <> '' then
    FParams := FParams + ', ';
  FParams := FParams + IntToStr(AParam);
end;

{ TMacroListView }

procedure TMacroListView.btnRenameClick(Sender: TObject);
var
  s: String;
  M: TEditorMacro;
begin
  if lbMacroView.ItemIndex < 0 then exit;
  M := CurrentEditorMacroList.Macros[lbMacroView.ItemIndex];
  s := M.MacroName;
  if InputQuery(lisNewMacroname2, Format(lisEnterNewNameForMacroS, [m.MacroName]), s)
  then begin
    while (s <> '') and (CurrentEditorMacroList.IndexOfName(s) >= 0) do begin
      case IDEMessageDialog(lisDuplicateName, lisAMacroWithThisNameAlreadyExists, mtWarning,
        mbOKCancel) of
        mrOK:
          if not InputQuery(lisNewMacroname2, Format(lisEnterNewNameForMacroS, [m.MacroName]), s)
          then s := '';
        else
          s := '';
      end;
    end;

    if s <> '' then
      M.MacroName := s;
    UpdateDisplay;
  end;
end;

procedure TMacroListView.btnPlayClick(Sender: TObject);
var
  i: Integer;
  M: TEditorMacro;
  se: TSourceEditorInterface;
begin
  if ActiveEditorMacro <> nil then exit;
  if lbMacroView.ItemIndex < 0 then exit;
  se := SourceEditorManagerIntf.ActiveEditor;
  if se = nil then Exit;

  i := 1;
  if chkRepeat.Checked then
    i := edRepeat.Value;
  FIsPlaying := True;
  UpdateButtons;

  M := CurrentEditorMacroList.Macros[lbMacroView.ItemIndex];
  try
    while i > 0 do begin
      M.PlaybackMacro(TCustomSynEdit(se.EditorControl));
      Application.ProcessMessages;
      dec(i);
      if not FIsPlaying then break;
    end;
  finally
    FIsPlaying := False;
    UpdateButtons;
  end;

end;

procedure TMacroListView.btnDeleteClick(Sender: TObject);
var
  m: TEditorMacro;
begin
  if lbMacroView.ItemIndex < 0 then exit;
  if IDEMessageDialog(lisReallyDelete, lisDeleteSelectedMacro, mtConfirmation,
                      [mbYes, mbNo]) = mrYes
  then begin
    if SelectedEditorMacro = CurrentEditorMacroList.Macros[lbMacroView.ItemIndex] then
      SelectedEditorMacro := nil;
    m := CurrentEditorMacroList.Macros[lbMacroView.ItemIndex];
    CurrentEditorMacroList.Delete(lbMacroView.ItemIndex);
    m.Free;
    if CurrentEditorMacroList = EditorMacroListProj then Project1.Modified := True;
    if CurrentEditorMacroList = EditorMacroListGlob then MainIDEInterface.SaveEnvironment(False);
    UpdateDisplay;
  end;
end;

procedure TMacroListView.btnEditClick(Sender: TObject);
var
  M: TEditorMacro;
begin
  if lbMacroView.ItemIndex < 0 then exit;
  M := CurrentEditorMacroList.Macros[lbMacroView.ItemIndex];
  if M = nil then exit;
  LazarusIDE.DoOpenEditorFile(
    EditorMacroVirtualDrive+MacroListToName(CurrentEditorMacroList)+'|'+M.MacroName,
    -1, -1, [ofVirtualFile, ofInternalFile]);
end;

procedure TMacroListView.btnRecordClick(Sender: TObject);
var
  se: TSourceEditorInterface;
begin
  se := SourceEditorManagerIntf.ActiveEditor;
  if se = nil then Exit;
  if CurrentEditorMacroList <> EditorMacroListRec then
  begin
    tbRecorded.Down := True;        // Switch to "recorded" page when recording.
    tbRecorded.Click;
  end;
  lbMacroView.ItemIndex := -1;
  if (ActiveEditorMacro = nil) and (EditorMacroForRecording.State = emStopped) then
    EditorMacroForRecording.RecordMacro(se.EditorControl)
  else
  if EditorMacroForRecording.State = emRecording then
    EditorMacroForRecording.Pause
  else
  if EditorMacroForRecording.State = emRecPaused then
    EditorMacroForRecording.Resume;
  se.EditorControl.SetFocus;
end;

procedure TMacroListView.btnRecordStopClick(Sender: TObject);
begin
  FIsPlaying := False;
  EditorMacroForRecording.Stop;
  UpdateButtons;
end;

procedure TMacroListView.btnAddEditNewClick(Sender: TObject);
var
  se: TSourceEditorInterface;
  M: TEditorMacro;
begin
  se := SourceEditorManagerIntf.ActiveEditor;
  Assert(Assigned(se) and (ActiveEditorMacro=nil) and (EditorMacroForRecording.State=emStopped),
         'TMacroListView.btnAddEditNewClick: Problem');
  lbMacroView.ItemIndex := -1;
  M := TIdeEditorMacro.Create(nil);
  M.OnStateChange := @MacroListViewer.DoMacroStateChanged;
  M.OnChange := @MacroListViewer.DoMacroContentChanged;
  M.MacroName := Format(lisNewMacroName, [MacroRecCounter]);
  inc(MacroRecCounter);
  CurrentEditorMacroList.Add(M);
  Assert(not FIsPlaying, 'TMacroListView.btnAddEditNewClick: IsPlaying');
  LazarusIDE.DoOpenEditorFile(
    EditorMacroVirtualDrive+MacroListToName(CurrentEditorMacroList)+'|'+M.MacroName,
    -1, -1, [ofVirtualFile, ofInternalFile]);

  UpdateDisplay;
end;

procedure TMacroListView.btnSelectClick(Sender: TObject);
begin
  if ActiveEditorMacro <> nil then exit;
  if lbMacroView.ItemIndex >= 0 then
    SelectedEditorMacro := CurrentEditorMacroList.Macros[lbMacroView.ItemIndex]
  else
    SelectedEditorMacro:= nil;
  UpdateDisplay;
end;

procedure TMacroListView.btnSetKeysClick(Sender: TObject);
var
  i: integer;
  M: TEditorMacro;
begin
  if lbMacroView.ItemIndex < 0 then exit;
  M := CurrentEditorMacroList.Macros[lbMacroView.ItemIndex];

  if (M.KeyBinding = nil) or (M.KeyBinding.IdeCmd = nil) or
     not(M.KeyBinding.IdeCmd is TKeyCommandRelation)
  then // only for error macros
    exit;

  i := (IDECommandList as TKeyCommandRelationList).IndexOf(M.KeyBinding.IdeCmd as TKeyCommandRelation);
  if (i >= 0) then
    if ShowKeyMappingEditForm(i, (IDECommandList as TKeyCommandRelationList)) = mrOK then begin
      if CurrentEditorMacroList = EditorMacroListProj then Project1.Modified := True;
      if CurrentEditorMacroList = EditorMacroListGlob then MainIDEInterface.SaveEnvironment(False);
    end;
  UpdateDisplay;
  if OnKeyMapReloaded <> nil then OnKeyMapReloaded();
end;

procedure TMacroListView.BtnWarnCloseClick(Sender: TObject);
begin
  PanelWarnings.Visible := False;
end;

procedure TMacroListView.DoMacroStateChanged(Sender: TObject);
begin
  if OnEditorMacroStateChange <> nil then
    OnEditorMacroStateChange(Sender);
end;

procedure TMacroListView.FormActivate(Sender: TObject);
begin
  DebugLn(['TMacroListView.FormActivate: Active=', Active]);
  lbMacroView.HideSelection := Active; // Active = False always ?
  UpdateButtons;
end;

procedure TMacroListView.HelpButtonClick(Sender: TObject);
begin
  LazarusHelp.ShowHelpForIDEControl(Self);
end;

procedure TMacroListView.lbMacroViewSelectItem(Sender: TObject; Item: TListItem;
  Selected: Boolean);
begin
  UpdateButtons;
end;

procedure TMacroListView.mnExportClick(Sender: TObject);
var
  Conf: TXMLConfig;
begin
  if lbMacroView.ItemIndex < 0 then exit;

  if SaveDialog1.Execute then begin
    Conf := TXMLConfig.Create(SaveDialog1.FileName);
    try
      Conf.Clear;
      Conf.SetValue('EditorMacros/Count', 1);
      CurrentEditorMacroList.Macros[lbMacroView.ItemIndex].WriteToXmlConf(Conf, 'EditorMacros/Macro1/');
    finally
      Conf.Free;
    end;
  end;
end;

procedure TMacroListView.mnImportClick(Sender: TObject);
var
  Conf: TXMLConfig;
  NewMacro: TEditorMacro;
begin
  if OpenDialog1.Execute then begin
    Conf := TXMLConfig.Create(OpenDialog1.FileName);
    try
      NewMacro := EditorMacroPlayerClass.Create(nil);
      NewMacro.OnStateChange := @DoMacroStateChanged;
      NewMacro.OnChange := @DoMacroContentChanged;
      NewMacro.ReadFromXmlConf(Conf, 'EditorMacros/Macro1/');
      if not NewMacro.IsEmpty then begin
        CurrentEditorMacroList.Add(NewMacro);
        if CurrentEditorMacroList = EditorMacroListProj then Project1.Modified := True;
        if CurrentEditorMacroList = EditorMacroListGlob then MainIDEInterface.SaveEnvironment(False);
      end
      else
        NewMacro.Free;
    finally
      Conf.Free;
    end;
  end;
end;

procedure TMacroListView.tbIDEClick(Sender: TObject);
begin
  CurrentEditorMacroList := EditorMacroListGlob;
  UpdateDisplay;
end;

procedure TMacroListView.tbMoveIDEClick(Sender: TObject);
var
  i: Integer;
begin
  if (lbMacroView.ItemIndex < 0) or (CurrentEditorMacroList = EditorMacroListGlob) then exit;
  i := lbMacroView.ItemIndex;
  EditorMacroListGlob.Add(CurrentEditorMacroList.Macros[i]);
  CurrentEditorMacroList.Delete(i);
  if CurrentEditorMacroList = EditorMacroListProj then Project1.Modified := True;
  MainIDEInterface.SaveEnvironment(False);
  UpdateDisplay;
end;

procedure TMacroListView.tbMoveProjectClick(Sender: TObject);
var
  i: Integer;
begin
  if (lbMacroView.ItemIndex < 0) or (CurrentEditorMacroList = EditorMacroListProj) then exit;
  i := lbMacroView.ItemIndex;
  EditorMacroListProj.Add(CurrentEditorMacroList.Macros[i]);
  CurrentEditorMacroList.Delete(i);
  Project1.Modified := True;
  if CurrentEditorMacroList = EditorMacroListGlob then MainIDEInterface.SaveEnvironment(False);
  UpdateDisplay;
end;

procedure TMacroListView.tbProjectClick(Sender: TObject);
begin
  CurrentEditorMacroList := EditorMacroListProj;
  UpdateDisplay;
end;

procedure TMacroListView.tbRecordedClick(Sender: TObject);
begin
  CurrentEditorMacroList := EditorMacroListRec;
  UpdateDisplay;
end;

procedure TMacroListView.DoOnMacroListChange(Sender: TObject);
begin
  UpdateDisplay;
  if Sender = EditorMacroListProj then
    Project1.SessionModified := True;
end;

procedure TMacroListView.DoMacroContentChanged(Sender: TObject);
begin
  if FIgnoreMacroChanges then exit;

  if EditorMacroListProj.IndexOf(Sender as TEditorMacro) >= 0 then
    Project1.Modified := True;
  if EditorMacroListGlob.IndexOf(Sender as TEditorMacro) >= 0 then
    MainIDEInterface.SaveEnvironment(False);
end;

procedure TMacroListView.UpdateDisplay;
var
  NewItem: TListItem;
  i, idx: Integer;
  M: TEditorMacro;
begin
  idx := lbMacroView.ItemIndex;
  lbMacroView.Items.Clear;

  for i := 0 to CurrentEditorMacroList.Count - 1 do begin
    M := CurrentEditorMacroList.Macros[i];
    NewItem := lbMacroView.Items.Add;

    if m.KeyBinding <> nil then
      NewItem.Caption := M.MacroName + M.KeyBinding.ShortCutAsText
    else
      NewItem.Caption := M.MacroName;

    // Image
    if M.IsInvalid then
      NewItem.ImageIndex := FImageErr
    else
    if (m = CurrentRecordingMacro) then
      NewItem.ImageIndex := FImageRec
    else
    if (CurrentRecordingMacro = nil) then begin // If recording, then recorder is selected
      If (M = ActiveEditorMacro) and (M.State = emPlaying) then
        NewItem.ImageIndex := FImagePlay
      else
      if (M = SelectedEditorMacro) then
        NewItem.ImageIndex := FImageSel;
    end;
  end;
  if idx < lbMacroView.Items.Count then
    lbMacroView.ItemIndex := idx
  else
    lbMacroView.ItemIndex := -1;

  lbMacroViewSelectItem(nil, nil, False);
  UpdateButtons;
end;

procedure TMacroListView.UpdateButtons;
var
  IsSel, IsErr, IsStopped: Boolean;
  M: TEditorMacro;
  RecState: TEditorMacroState;
begin
  IsSel := (lbMacroView.ItemIndex >= 0);
  IsStopped := (ActiveEditorMacro = nil);
  if IsSel then
    M := CurrentEditorMacroList.Macros[lbMacroView.ItemIndex];
  IsErr := IsSel and M.IsInvalid;
  RecState := emStopped;
  if EditorMacroForRecording <> nil then
    RecState := EditorMacroForRecording.State;

  btnSelect.Enabled  := IsStopped and IsSel and (not FIsPlaying) and (not IsErr);
  btnRename.Enabled  := IsStopped and IsSel and (not FIsPlaying) and (not IsErr);
  btnEdit.Enabled    := IsStopped and IsSel and (not FIsPlaying);
  btnSetKeys.Enabled := IsStopped and IsSel and (not FIsPlaying) and (not IsErr);
  btnDelete.Enabled  := IsStopped and IsSel and (not FIsPlaying);

  btnPlay.Enabled    := IsStopped and IsSel and (not FIsPlaying) and (not IsErr);
  chkRepeat.Enabled  := IsStopped and (not FIsPlaying);
  edRepeat.Enabled   := IsStopped and (not FIsPlaying);

  btnRecord.Enabled := Assigned(SourceEditorManagerIntf.ActiveEditor)
                  and (RecState in [emStopped, emRecPaused, emRecording])
                  and (not FIsPlaying);
  btnAddEditNew.Enabled := Assigned(SourceEditorManagerIntf.ActiveEditor)
                  and (RecState = emStopped) and not FIsPlaying;
  btnRecordStop.Enabled := (not IsStopped) or FIsPlaying;

  if (RecState = emRecording) then
  begin
    btnRecord.Caption := lisPause;
    btnRecord.ImageIndex := FImageRec;
  end
  else if (RecState = emRecPaused) then
  begin
    btnRecord.Caption := lisContinue;
    btnRecord.ImageIndex := FImageReady;
  end
  else begin
    btnRecord.Caption := lisRecord;
    btnRecord.ImageIndex := FImageReady;
  end;

  mnImport.Enabled := IsStopped and (not FIsPlaying);
  mnExport.Enabled := IsStopped and IsSel and (not FIsPlaying);

  tbMoveProject.Visible := CurrentEditorMacroList <> EditorMacroListProj;
  tbMoveProject.Enabled := IsStopped and IsSel and (not FIsPlaying);
  tbMoveIDE.Visible := CurrentEditorMacroList <> EditorMacroListGlob;
  tbMoveIDE.Enabled := IsStopped and IsSel and (not FIsPlaying);

  Update;
end;

function TMacroListView.MacroByFullName(AName: String): TEditorMacro;
const
  FolderStart = length(EditorMacroVirtualDrive)+1;
  NameStart = FolderStart+length('PRJ|');
var
  Alist: TEditorMacroList;
  i: Integer;
begin
  Result := nil;
  If not LazStartsStr(EditorMacroVirtualDrive, AName) or
     (copy(AName, NameStart-1, 1) <> '|')
  then exit;
  Alist := NameToMacroList(copy(AName, FolderStart, 3));
  if (Alist = nil) then exit;
  i := Alist.IndexOfName(copy(AName, NameStart, length(AName)));
  if i < 0 then exit;
  Result := Alist.Macros[i];
end;

procedure TMacroListView.DoEditorMacroStateChanged;
begin
  UpdateDisplay;
end;

constructor TMacroListView.Create(TheOwner: TComponent);
begin
  inherited Create(TheOwner);
  FIgnoreMacroChanges := False;

  Caption := lisEditorMacros;
  EditorMacroListRec.OnChange := @DoOnMacroListChange;
  EditorMacroListProj.OnChange := @DoOnMacroListChange;
  EditorMacroListGlob.OnChange := @DoOnMacroListChange;

  tbRecorded.Caption := lisRecordedMacros;
  tbProject.Caption := lisProjectMacro;
  tbIDE.Caption := lisIDE;
  tbRecorded.Hint := lisNewRecordedMacrosNotToBeSaved;
  tbProject.Hint := lisSavedWithProjectSession;
  tbIDE.Hint := lisSavedWithIDESettings;
  tbMoveProject.Caption := lisProjectMacro;
  tbMoveIDE.Caption := lisIDE;
  lbMoveTo.Caption := lisMoveTo + '  '; // Anchors do not work here. Use spaces.

  // Preloaded images
  lbMacroView.SmallImages := IDEImages.Images_16;
  FImageReady := IDEImages.LoadImage('InactiveBreakPoint'); // green dot
  FImageRec := IDEImages.LoadImage('Record');               // red dot
  FImagePlay := IDEImages.LoadImage('menu_run');            // green triangle
  FImageSel := IDEImages.LoadImage('arrow_right');
  FImageErr := IDEImages.LoadImage('state_error');

  // Controls in pnlButtons
  btnSelect.Caption := lisMakeCurrent;
  btnSelect.Images := IDEImages.Images_16;
  btnSelect.ImageIndex := IDEImages.LoadImage('btn_ok');

  btnRename.Caption := lisRename2;
  btnRename.Images := IDEImages.Images_16;
  btnRename.ImageIndex := IDEImages.LoadImage('laz_edit');

  btnSetKeys.Caption := lisEditKey;
  btnSetKeys.Images := IDEImages.Images_16;
  btnSetKeys.ImageIndex := IDEImages.LoadImage('item_character');

  btnEdit.Caption := lisEdit;
  btnEdit.Images := IDEImages.Images_16;
  btnEdit.ImageIndex := IDEImages.LoadImage('show_source');

  btnDelete.Caption := lisDelete;
  btnDelete.Images := IDEImages.Images_16;
  btnDelete.ImageIndex := IDEImages.LoadImage('laz_delete');

  btnPlay.Caption := lisPlay;
  btnPlay.Images := IDEImages.Images_16;
  btnPlay.ImageIndex := IDEImages.LoadImage('menu_run');

  chkRepeat.Caption := lisRepeat;

  // Add new macro
  gbAddMacro.Caption := lisAddNewMacro;

  btnRecord.Caption := lisRecord;
  btnRecord.Images := IDEImages.Images_16;
  btnRecord.ImageIndex := FImageReady;

  btnRecordStop.Caption := lisStop;
  btnRecordStop.Images := IDEImages.Images_16;
  btnRecordStop.ImageIndex := IDEImages.LoadImage('menu_stop');

  btnAddEditNew.Caption := lisCreateAndEdit;
  btnAddEditNew.Images := IDEImages.Images_16;
  btnAddEditNew.ImageIndex := IDEImages.LoadImage('laz_add');

  // Warning
  BtnWarnClose.Images := IDEImages.Images_16;
  BtnWarnClose.ImageIndex := IDEImages.LoadImage('menu_close');

  SaveDialog1.Title := lisSaveMacroAs;
  OpenDialog1.Title := lisLoadMacroFrom;
  mnImport.Caption := lisDlgImport;
  mnExport.Caption := lisDlgExport;
end;

destructor TMacroListView.Destroy;
begin
  inherited Destroy;
end;

{ TEditorMacroList }

function TEditorMacroList.GetMacros(Index: Integer): TEditorMacro;
begin
  Result := TEditorMacro(FList[Index]);
end;

procedure TEditorMacroList.DoChanged;
begin
  if Assigned(FOnChange) then
    FOnChange(Self);
end;

procedure TEditorMacroList.DoAdded(AMacro: TEditorMacro);
begin
  if Assigned(FOnAdded) then
    FOnAdded(Self, AMacro);
end;

procedure TEditorMacroList.DoRemove(AMacro: TEditorMacro);
begin
  if Assigned(FOnRemove) then
    FOnRemove(Self, AMacro);
end;

constructor TEditorMacroList.Create;
begin
  FList := TList.Create;
end;

destructor TEditorMacroList.Destroy;
begin
  FOnChange := nil;
  ClearAndFreeMacros;
  FreeAndNil(FList);
  inherited Destroy;
end;

procedure TEditorMacroList.WriteToXmlConf(AConf: TXMLConfig; const APath: String);
var
  i: Integer;
begin
  AConf.SetDeleteValue(APath + 'EditorMacros/Count', Count, 0);
  for i := 0 to Count - 1 do
    Macros[i].WriteToXmlConf(AConf, 'EditorMacros/Macro'+IntToStr(i+1)+'/');
end;

procedure TEditorMacroList.ReadFromXmlConf(AConf: TXMLConfig; const APath: String);
var
  c, i: Integer;
  NewMacro: TEditorMacro;
begin
  ClearAndFreeMacros;
  c := AConf.GetValue(APath + 'EditorMacros/Count', 0);
  for i := 0 to c -1 do begin
    NewMacro := EditorMacroPlayerClass.Create(nil);
    NewMacro.OnStateChange := @MacroListViewer.DoMacroStateChanged;
    NewMacro.OnChange := @MacroListViewer.DoMacroContentChanged;
    try
      NewMacro.ReadFromXmlConf(AConf, 'EditorMacros/Macro'+IntToStr(i+1)+'/');
    finally
      Add(NewMacro)
    end;
  end;
end;

procedure TEditorMacroList.ClearAndFreeMacros;
var
  i: Integer;
begin
  for i := 0 to Count - 1 do
    Macros[i].Free;
  FList.Clear;
end;

function TEditorMacroList.Count: Integer;
begin
  Result := FList.Count;
end;

function TEditorMacroList.IndexOf(AMacro: TEditorMacro): Integer;
begin
  Result := FList.IndexOf(AMacro);
end;

function TEditorMacroList.IndexOfName(AName: String): Integer;
begin
  Result := Count - 1;
  while Result >= 0 do
    if Macros[Result].MacroName = AName
    then break
    else dec(Result);
end;

function TEditorMacroList.UniqName(AName: String): String;
var
  i: Integer;
begin
  Result := AName;
  if IndexOfName(AName) < 0 then exit;
  i := 1;
  while IndexOfName(AName+'_'+IntToStr(i)) >= 0 do
    inc(i);
  Result := AName+'_'+IntToStr(i);
end;

function TEditorMacroList.Add(AMacro: TEditorMacro): Integer;
begin
  AMacro.MacroName := UniqName(AMacro.MacroName);
  Result := FList.Add(AMacro);
  DoAdded(AMacro);
  DoChanged;
end;

procedure TEditorMacroList.Delete(AnIndex: Integer);
begin
  DoRemove(Macros[AnIndex]);
  FList.Delete(AnIndex);
  DoChanged;
end;

procedure TEditorMacroList.Remove(AMacro: TEditorMacro);
begin
  DoRemove(AMacro);
  FList.Remove(AMacro);
  DoChanged;
end;

// itmMacroListView.enabled

{ TMacrosToolButton }

procedure TMacrosToolButton.DoOnAdded;
begin
  inherited DoOnAdded;
  DropdownMenu := TPopupMenu.Create(Self);
  DropdownMenu.OnPopup := @RefreshMenu;
  Style := tbsDropDown;
end;

procedure TMacrosToolButton.mnuPlayMacro(Sender: TObject);
var
  M: TEditorMacro;
  se: TSourceEditorInterface;
begin
  se := SourceEditorManagerIntf.ActiveEditor;
  if se = nil then
    Exit;
  M := TEditorMacro(TMenuItem(Sender).Tag);
  M.PlaybackMacro(TCustomSynEdit(se.EditorControl));
end;

procedure TMacrosToolButton.AddMenuItem(AMacro: TEditorMacro);
var
  MI: TMenuItem;
begin
  MI := TMenuItem.Create(DropdownMenu);
  DropdownMenu.Items.Add(MI);
  MI.OnClick := @mnuPlayMacro;
  MI.Caption := AMacro.MacroName+'  '+AMacro.KeyBinding.ShortCutAsText;
  MI.Tag := PtrInt(AMacro);
end;

procedure TMacrosToolButton.AddList(AList: TEditorMacroList);
var
  i: integer;
begin
  if AList.Count = 0 then
    Exit;
  if DropdownMenu.Items.Count > 0 then
    DropdownMenu.Items.AddSeparator;
  for i := 0 to Pred(AList.Count) do
    AddMenuItem(AList.Macros[i]);
end;

procedure TMacrosToolButton.RefreshMenu(Sender: TObject);
begin
  DropdownMenu.Items.Clear;
  AddList(EditorMacroListGlob);
  AddList(EditorMacroListProj);
  AddList(EditorMacroListRec);
end;


{$R *.lfm}

initialization
  if EditorMacroPlayerClass = nil then
    EditorMacroPlayerClass := TIdeEditorMacro;
  if DefaultBindingClass = nil then
  DefaultBindingClass := TIdeEditorMacroKeyBinding;
  EditorMacroListRec := TEditorMacroList.Create;
  EditorMacroListProj := TEditorMacroList.Create;
  EditorMacroListGlob := TEditorMacroList.Create;
  CurrentEditorMacroList := EditorMacroListRec;

  MacroListViewerWarningChanged := @DoMacroListViewerWarningChanged;

finalization
  CurrentEditorMacroList := nil;
  FreeAndNil(EditorMacroListRec);
  FreeAndNil(EditorMacroListProj);
  FreeAndNil(EditorMacroListGlob);

end.

