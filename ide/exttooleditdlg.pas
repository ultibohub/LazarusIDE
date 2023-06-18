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

  Author: Mattias Gaertner

  Abstract:
    Defines the TExternalToolOptions which stores the settings of a single
    external tool. (= Programfilename and parameters)
    All TExternalToolOptions are stored in a TExternalToolList
    (see exttooldialog.pas).
    And this unit provides TExternalToolOptionDlg which is a dialog for editing
    a single external tool.
}
unit ExtToolEditDlg;

{$mode objfpc}
{$H+}

{$I ide.inc}

interface

uses
  {$IFDEF IDE_MEM_CHECK}
  MemCheck,
  {$ENDIF}
  Classes, SysUtils, contnrs,
  // LCL
  LCLType, Controls, Forms, StdCtrls, Dialogs, LCLProc, ButtonPanel, EditBtn,
  // LazUtils
  FileUtil, LazFileUtils, LazUTF8, LazConfigStorage,
  // Codetools
  FileProcs,
  // IdeIntf
  IdeIntfStrConsts, IDEExternToolIntf, IDEHelpIntf, PropEdits, IDEDialogs, IDECommands, IDEUtils,
  // IdeConfig
  TransferMacros, EnvironmentOpts,
  // IDE
  LazarusIDEStrConsts, KeyMapping;

const
  ExternalToolOptionsVersion = 3;
  // 3: changed ScanOutputForFPCMessages to parser SubToolFPC
  //    changed ScanOutputForMakeMessages to parser SubToolMake
type

  { TExternalUserTool - the options of an external tool in the IDE menu Tools }

  TExternalUserTool = class(TComponent)
  private
    FChangeStamp: integer;
    fCmdLineParams: string;
    FEnvironmentOverrides: TStringList;
    fFilename: string;
    FHideWindow: boolean;
    FKey: word;
    FParsers: TStrings;
    FShift: TShiftState;
    FShowConsole: boolean;
    fTitle: string;
    fWorkingDirectory: string;
    fSavedChangeStamp: integer;
    function GetHasParser(aName: string): boolean;
    function GetModified: boolean;
    procedure SetChangeStamp(AValue: integer);
    procedure SetCmdLineParams(AValue: string);
    procedure SetEnvironmentOverrides(AValue: TStringList);
    procedure SetFilename(AValue: string);
    procedure SetHasParser(aName: string; AValue: boolean);
    procedure SetHideWindow(AValue: boolean);
    procedure SetModified(AValue: boolean);
    procedure SetParsers(AValue: TStrings);
    procedure SetShowConsole(AValue: boolean);
    procedure SetTitle(AValue: string);
    procedure SetWorkingDirectory(AValue: string);
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    procedure Clear;
    function Equals(Obj: TObject): boolean; override;
    procedure Assign(Source: TPersistent); override;
    function Load(Config: TConfigStorage; CfgVersion: integer): TModalResult; virtual;
    function Save(Config: TConfigStorage): TModalResult; virtual;
    procedure IncreaseChangeStamp; inline;
    property CmdLineParams: string read fCmdLineParams write SetCmdLineParams;
    property Filename: string read fFilename write SetFilename;
    property Title: string read fTitle write SetTitle;
    property WorkingDirectory: string read fWorkingDirectory write SetWorkingDirectory;
    property EnvironmentOverrides: TStringList read FEnvironmentOverrides write SetEnvironmentOverrides;
    property Parsers: TStrings read FParsers write SetParsers;
    property HasParser[aName: string]: boolean read GetHasParser write SetHasParser;
    property ShowConsole: boolean read FShowConsole write SetShowConsole;
    property HideWindow: boolean read FHideWindow write SetHideWindow;
    property Modified: boolean read GetModified write SetModified;
    property ChangeStamp: integer read FChangeStamp write SetChangeStamp;
  public
    // these properties are saved in the keymappings, not in the config
    property Key: word read FKey write FKey;
    property Shift: TShiftState read FShift write FShift;
  end;

  { TExternalUserTools }

  TExternalUserTools = class(TBaseExternalUserTools)
  private
    fItems: TObjectList; // list of TExternalUserTool
    function GetItems(Index: integer): TExternalUserTool; inline;
  public
    constructor Create; override;
    destructor Destroy; override;
    procedure Clear; inline;
    function Equals(Obj: TObject): boolean; override;
    procedure Assign(Src: TExternalUserTools);
    function Count: integer; inline;
    property Items[Index: integer]: TExternalUserTool read GetItems; default;
    procedure Add(Item: TExternalUserTool);
    procedure Insert(Index: integer; Item: TExternalUserTool);
    procedure Delete(Index: integer);
    procedure Move(CurIndex, NewIndex: integer);
    // run
    function Run(Index: integer; {%H-}ShowAbort: boolean): TModalResult;
    // load/save
    function Load(Config: TConfigStorage): TModalResult;
    function Load(Config: TConfigStorage; const Path: string): TModalResult; override;
    function Save(Config: TConfigStorage): TModalResult;
    function Save(Config: TConfigStorage; const Path: string): TModalResult; override;
    procedure LoadShortCuts(KeyCommandRelationList: TKeyCommandRelationList);
    procedure SaveShortCuts(KeyCommandRelationList: TKeyCommandRelationList);
  end;

var
  ExternalUserTools: TExternalUserTools = nil;

type
  { TExternalToolOptionDlg - the editor dialog for a single external tool }

  TExternalToolOptionDlg = class(TForm)
    ButtonPanel: TButtonPanel;
    FileNameEdit: TFileNameEdit;
    FilenameLabel: TLabel;
    HideWindowCheckBox: TCheckBox;
    KeyGroupBox: TGroupBox;
    MacrosGroupbox: TGroupbox;
    MacrosInsertButton: TButton;
    MacrosListbox: TListbox;
    MemoParameters: TMemo;
    OptionsGroupBox: TGroupBox;
    ParametersLabel: TLabel;
    ScannersButton: TButton;
    ScanOutputForFPCMessagesCheckBox: TCheckBox;
    ScanOutputForMakeMessagesCheckBox: TCheckBox;
    ShowConsoleCheckBox: TCheckBox;
    TitleEdit: TEdit;
    TitleLabel: TLabel;
    WorkingDirEdit: TDirectoryEdit;
    WorkingDirLabel: TLabel;
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure HelpButtonClick(Sender: TObject);
    procedure MacrosInsertButtonClick(Sender: TObject);
    procedure MacrosListboxClick(Sender: TObject);
    procedure MacrosListboxDblClick(Sender: TObject);
    procedure OKButtonClick(Sender: TObject);
    procedure ShowConsoleCheckBoxChange(Sender: TObject);
  private
    fAllKeys: TKeyCommandRelationList;
    fOptions: TExternalUserTool;
    fTransferMacros: TTransferMacroList;
    fScanners: TStrings;
    fKeyBox: TShortCutGrabBox;
    procedure FillMacroList;
    function KeyConflicts(Key:word; Shift:TShiftState): TModalResult;
    procedure LoadFromOptions;
    procedure SaveToOptions;
    procedure UpdateButtons;
    function ScannersToString(List: TStrings): string;
    procedure SetComboBox(AComboBox: TComboBox; const AValue: string);
    procedure SetOptions(TheOptions: TExternalUserTool);
    procedure SetTransferMacros(TransferMacroList: TTransferMacroList);
  public
    property Options: TExternalUserTool read fOptions write SetOptions;
    property MacroList: TTransferMacroList
           read fTransferMacros write SetTransferMacros;
  end;


function ShowExtToolOptionDlg(TransferMacroList: TTransferMacroList;
  ExternalToolMenuItem: TExternalUserTool;
  AllKeys: TKeyCommandRelationList):TModalResult;

implementation

{$R *.lfm}

function ShowExtToolOptionDlg(TransferMacroList: TTransferMacroList;
  ExternalToolMenuItem: TExternalUserTool;
  AllKeys: TKeyCommandRelationList):TModalResult;
var
  ExternalToolOptionDlg: TExternalToolOptionDlg;
begin
  Result:=mrCancel;
  ExternalToolOptionDlg:=TExternalToolOptionDlg.Create(nil);
  try
    ExternalToolOptionDlg.fAllKeys:=AllKeys;
    ExternalToolOptionDlg.Options:=ExternalToolMenuItem;
    ExternalToolOptionDlg.MacroList:=TransferMacroList;
    Result:=ExternalToolOptionDlg.ShowModal;
    if Result=mrOk then
      ExternalToolMenuItem.Assign(ExternalToolOptionDlg.Options);
  finally
    ExternalToolOptionDlg.Free;
  end;
end;

{ TExternalUserTool }

// inline
procedure TExternalUserTool.IncreaseChangeStamp;
begin
  CTIncreaseChangeStamp(FChangeStamp);
end;

function TExternalUserTool.GetModified: boolean;
begin
  Result:=FChangeStamp=fSavedChangeStamp;
end;

function TExternalUserTool.GetHasParser(aName: string): boolean;
begin
  Result:=IndexInStringList(FParsers,cstCaseInsensitive,aName)>=0;
end;

procedure TExternalUserTool.SetChangeStamp(AValue: integer);
begin
  if FChangeStamp=AValue then Exit;
  FChangeStamp:=AValue;
end;

procedure TExternalUserTool.SetCmdLineParams(AValue: string);
begin
  AValue:=UTF8Trim(AValue,[]);
  if fCmdLineParams=AValue then Exit;
  fCmdLineParams:=AValue;
  IncreaseChangeStamp;
end;

procedure TExternalUserTool.SetEnvironmentOverrides(AValue: TStringList);
begin
  if (FEnvironmentOverrides=AValue) or FEnvironmentOverrides.Equals(AValue) then Exit;
  FEnvironmentOverrides.Assign(AValue);
  IncreaseChangeStamp;
end;

procedure TExternalUserTool.SetFilename(AValue: string);
begin
  AValue:=TrimFilename(AValue);
  if fFilename=AValue then Exit;
  fFilename:=AValue;
  IncreaseChangeStamp;
end;

procedure TExternalUserTool.SetHasParser(aName: string; AValue: boolean);
var
  i: Integer;
begin
  i:=IndexInStringList(FParsers,cstCaseInsensitive,aName);
  if i>=0 then begin
    if AValue then exit;
    FParsers.Delete(i);
  end else begin
    if not AValue then exit;
    FParsers.Add(aName);
  end;
  IncreaseChangeStamp;
end;

procedure TExternalUserTool.SetHideWindow(AValue: boolean);
begin
  if FHideWindow=AValue then Exit;
  FHideWindow:=AValue;
  IncreaseChangeStamp;
end;

procedure TExternalUserTool.SetModified(AValue: boolean);
begin
  if AValue then
    IncreaseChangeStamp
  else
    fSavedChangeStamp:=FChangeStamp;
end;

procedure TExternalUserTool.SetParsers(AValue: TStrings);
begin
  if (FParsers=AValue) or FParsers.Equals(AValue) then Exit;
  FParsers.Assign(AValue);
  IncreaseChangeStamp;
end;

procedure TExternalUserTool.SetShowConsole(AValue: boolean);
begin
  if FShowConsole=AValue then Exit;
  FShowConsole:=AValue;
  IncreaseChangeStamp;
end;

procedure TExternalUserTool.SetTitle(AValue: string);
begin
  AValue:=UTF8Trim(AValue,[]);
  if fTitle=AValue then Exit;
  fTitle:=AValue;
  IncreaseChangeStamp;
end;

procedure TExternalUserTool.SetWorkingDirectory(AValue: string);
begin
  AValue:=TrimFilename(AValue);
  if fWorkingDirectory=AValue then Exit;
  fWorkingDirectory:=AValue;
  IncreaseChangeStamp;
end;

constructor TExternalUserTool.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  FEnvironmentOverrides:=TStringList.Create;
  FParsers:=TStringList.Create;
  fSavedChangeStamp:=CTInvalidChangeStamp;
  Clear;
end;

destructor TExternalUserTool.Destroy;
begin
  FreeAndNil(FEnvironmentOverrides);
  FreeAndNil(FParsers);
  inherited Destroy;
end;

procedure TExternalUserTool.Clear;
begin
  CmdLineParams:='';
  if FEnvironmentOverrides.Count>0 then
  begin
    IncreaseChangeStamp;
    FEnvironmentOverrides.Clear;
  end;
  Filename:='';
  if FParsers.Count>0 then
  begin
    FParsers.Clear;
    IncreaseChangeStamp;
  end;
  Title:='';
  WorkingDirectory:='';
  ShowConsole:=false;
  HideWindow:=true;
end;

function TExternalUserTool.Equals(Obj: TObject): boolean;
var
  Src: TExternalUserTool;
begin
  if Obj is TExternalUserTool then begin
    Src:=TExternalUserTool(Obj);
    Result:=(CmdLineParams=Src.CmdLineParams)
      and EnvironmentOverrides.Equals(Src.EnvironmentOverrides)
      and (Filename=Src.Filename)
      and Parsers.Equals(Src.Parsers)
      and (ShowConsole=Src.ShowConsole)
      and (HideWindow=Src.HideWindow)
      and (Title=Src.Title)
      and (WorkingDirectory=Src.WorkingDirectory)
      and (Key=Src.Key)
      and (Shift=Src.Shift);
  end else
    Result:=inherited;
end;

procedure TExternalUserTool.Assign(Source: TPersistent);
var
  Src: TExternalUserTool;
begin
  if Equals(Source) then exit;
  if Source is TExternalUserTool then begin
    Src:=TExternalUserTool(Source);
    CmdLineParams:=Src.CmdLineParams;
    WorkingDirectory:=Src.WorkingDirectory;
    EnvironmentOverrides:=Src.EnvironmentOverrides;
    Filename:=Src.Filename;
    Parsers:=Src.Parsers;
    ShowConsole:=Src.ShowConsole;
    HideWindow:=Src.HideWindow;
    Title:=Src.Title;
    Key:=Src.Key;
    Shift:=Src.Shift;
  end else
    inherited;
end;

function TExternalUserTool.Load(Config: TConfigStorage; CfgVersion: integer
  ): TModalResult;
begin
  Clear;
  fTitle:=Config.GetValue('Title/Value','');
  fFilename:=Config.GetValue('Filename/Value','');
  fCmdLineParams:=Config.GetValue('CmdLineParams/Value','');
  fWorkingDirectory:=Config.GetValue('WorkingDirectory/Value','');
  Config.GetValue('EnvironmentOverrides/',FEnvironmentOverrides);
  ShowConsole:=Config.GetValue('ShowConsole/Value',false);
  HideWindow:=Config.GetValue('HideWindow/Value',true);

  if CfgVersion<3 then
  begin
    if Config.GetValue('ScanOutputForFPCMessages/Value',false) then
      FParsers.Add(SubToolFPC);
    if Config.GetValue('ScanOutputForMakeMessages/Value',false) then
      FParsers.Add(SubToolMake);
    if Config.GetValue('ShowAllOutput/Value',false) then
      FParsers.Add(SubToolDefault);
  end else
    Config.GetValue('Scanners/',FParsers);

  Modified:=false;
  Result:=mrOk;
end;

function TExternalUserTool.Save(Config: TConfigStorage): TModalResult;
begin
  Config.SetDeleteValue('Title/Value',Title,'');
  Config.SetDeleteValue('Filename/Value',Filename,'');
  Config.SetDeleteValue('CmdLineParams/Value',CmdLineParams,'');
  Config.SetDeleteValue('WorkingDirectory/Value',WorkingDirectory,'');
  Config.SetValue('EnvironmentOverrides/',FEnvironmentOverrides);
  Config.SetValue('Scanners/',FParsers);
  Config.SetDeleteValue('ShowConsole/Value',ShowConsole,false);
  Config.SetDeleteValue('HideWindow/Value',HideWindow,true);
  Modified:=false;
  Result:=mrOk;
end;

{ TExternalUserTools }

// inline
function TExternalUserTools.Count: integer;
begin
  Result:=fItems.Count;
end;

// inline
function TExternalUserTools.GetItems(Index: integer): TExternalUserTool;
begin
  Result:=TExternalUserTool(fItems[Index]);
end;

// inline
procedure TExternalUserTools.Clear;
begin
  fItems.Clear;
end;

constructor TExternalUserTools.Create;
begin
  fItems:=TObjectList.Create(true);
end;

destructor TExternalUserTools.Destroy;
begin
  if ExternalUserTools=Self then
    ExternalUserTools:=nil;
  Clear;
  FreeAndNil(fItems);
  inherited Destroy;
end;

function TExternalUserTools.Equals(Obj: TObject): boolean;
var
  Src: TExternalUserTools;
  i: Integer;
begin
  if Obj=Self then exit(true);
  if Obj is TExternalUserTools then begin
    Src:=TExternalUserTools(Obj);
    Result:=false;
    if Count<>Src.Count then exit;
    for i:=0 to Count-1 do
      if not Items[i].Equals(Src[i]) then exit;
    Result:=true;
  end else
    Result:=inherited Equals(Obj);
end;

procedure TExternalUserTools.Assign(Src: TExternalUserTools);
var
  Item: TExternalUserTool;
  i: Integer;
begin
  if Equals(Src) then exit;
  Clear;
  for i:=0 to Src.Count-1 do begin
    Item:=TExternalUserTool.Create(nil);
    Item.Assign(Src[i]);
    Add(Item);
  end;
end;

procedure TExternalUserTools.Add(Item: TExternalUserTool);
begin
  fItems.Add(Item);
end;

procedure TExternalUserTools.Insert(Index: integer;
  Item: TExternalUserTool);
begin
  fItems.Insert(Index,Item);
end;

procedure TExternalUserTools.Delete(Index: integer);
begin
  fItems.Delete(Index);
end;

procedure TExternalUserTools.Move(CurIndex, NewIndex: integer);
begin
  fItems.Move(CurIndex,NewIndex);
end;

function TExternalUserTools.Run(Index: integer; ShowAbort: boolean
  ): TModalResult;
var
  Item: TExternalUserTool;
  Tool: TIDEExternalToolOptions;
begin
  Result:=mrCancel;
  Item:=Items[Index];

  Tool:=TIDEExternalToolOptions.Create;
  try
    Tool.Title:=Item.Title;
    Tool.Hint:='External tool '+IntToStr(Index+1);
    Tool.Executable:=Item.Filename;
    Tool.WorkingDirectory:=Item.WorkingDirectory;
    Tool.CmdLineParams:=Item.CmdLineParams;
    Tool.EnvironmentOverrides:=Item.EnvironmentOverrides;
    Tool.Parsers:=Item.Parsers;
    Tool.ShowConsole:=Item.ShowConsole;
    Tool.HideWindow:=Item.HideWindow;
    Tool.ResolveMacros:=true;
    if not RunExternalTool(Tool) then exit;
  finally
    Tool.Free;
  end;
end;

function TExternalUserTools.Load(Config: TConfigStorage): TModalResult;
var
  i: integer;
  NewTool: TExternalUserTool;
  NewCount: Integer;
  CfgVersion: Integer;
begin
  Clear;
  NewCount:=Config.GetValue('Count',0);
  CfgVersion:=Config.GetValue('Version',0);
  for i:=1 to NewCount do begin
    NewTool:=TExternalUserTool.Create(nil);
    fItems.Add(NewTool);
    Config.AppendBasePath('Tool'+IntToStr(i)+'/');
    try
      if NewTool.Load(Config,CfgVersion)<>mrOk then exit;
    finally
      Config.UndoAppendBasePath;
    end;
  end;
  Result:=mrOk;
end;

function TExternalUserTools.Load(Config: TConfigStorage; const Path: string
  ): TModalResult;
begin
  if Path<>'' then
    Config.AppendBasePath(Path);
  try
    Result:=Load(Config);
  finally
    if Path<>'' then
      Config.UndoAppendBasePath;
  end;
end;

function TExternalUserTools.Save(Config: TConfigStorage): TModalResult;
var
  i: integer;
begin
  Config.SetValue('Version',ExternalToolOptionsVersion);
  Config.SetDeleteValue('Count',Count,0);
  for i:=1 to Count do begin
    Config.AppendBasePath('Tool'+IntToStr(i)+'/');
    try
      if Items[i-1].Save(Config)<>mrOk then exit;
    finally
      Config.UndoAppendBasePath;
    end;
  end;
  Result:=mrOk;
end;

function TExternalUserTools.Save(Config: TConfigStorage; const Path: string
  ): TModalResult;
begin
  if Path<>'' then
    Config.AppendBasePath(Path);
  try
    Result:=Save(Config);
  finally
    if Path<>'' then
      Config.UndoAppendBasePath;
  end;
end;

procedure TExternalUserTools.LoadShortCuts(
  KeyCommandRelationList: TKeyCommandRelationList);
var
  i: integer;
  KeyCommandRelation: TKeyCommandRelation;
begin
  //debugln(['TExternalUserTools.LoadShortCuts ',KeyCommandRelationList.ExtToolCount,' ',Count]);
  KeyCommandRelationList.ExtToolCount:=Count;
  for i:=0 to Count-1 do begin
    KeyCommandRelation:=KeyCommandRelationList.FindByCommand(ecExtToolFirst+i);
    //debugln(['TExternalUserTools.LoadShortCuts ',i,'/',Count,' ',KeyCommandRelation.Name]);
    if KeyCommandRelation<>nil then begin
      Items[i].Key:=KeyCommandRelation.ShortcutA.Key1;
      Items[i].Shift:=KeyCommandRelation.ShortcutA.Shift1;
    end else begin
      Items[i].Key:=VK_UNKNOWN;
      Items[i].Shift:=[];
    end;
  end;
end;

procedure TExternalUserTools.SaveShortCuts(
  KeyCommandRelationList: TKeyCommandRelationList);
var
  i: integer;
  KeyCommandRelation: TKeyCommandRelation;
begin
  //debugln(['TExternalUserTools.SaveShortCuts ',KeyCommandRelationList.ExtToolCount,' ',Count]);
  KeyCommandRelationList.ExtToolCount:=Count;
  for i:=0 to Count-1 do begin
    KeyCommandRelation:=KeyCommandRelationList.FindByCommand(ecExtToolFirst+i);
    //debugln(['TExternalUserTools.SaveShortCuts ',i,'/',Count,' ',KeyCommandRelation.Name]);
    if KeyCommandRelation<>nil then begin
      KeyCommandRelation.ShortcutA:=IDEShortCut(Items[i].Key,Items[i].Shift,
                                           VK_UNKNOWN,[]);
    end else begin
      DebugLn('[TExternalToolMenuItems.SaveShortCuts] Error: '
        +'unable to save shortcut for external tool "',Items[i].Title,'"');
    end;
  end;
end;

{ TExternalToolOptionDlg }

procedure TExternalToolOptionDlg.LoadFromOptions;
begin
  TitleEdit.Text:=fOptions.Title;
  FilenameEdit.Text:=fOptions.Filename;
  MemoParameters.Lines.Text:=fOptions.CmdLineParams;
  WorkingDirEdit.Text:=fOptions.WorkingDirectory;
  fKeyBox.Key:=fOptions.Key;
  fKeyBox.ShiftState:=fOptions.Shift;
  ScanOutputForFPCMessagesCheckBox.Checked:=fOptions.HasParser[SubToolFPC];
  ScanOutputForMakeMessagesCheckBox.Checked:=fOptions.HasParser[SubToolMake];
  ShowConsoleCheckBox.Checked:=FOptions.ShowConsole;
  HideWindowCheckBox.Checked:=FOptions.HideWindow;
  fScanners.Assign(fOptions.Parsers);
  UpdateButtons;
end;

procedure TExternalToolOptionDlg.SaveToOptions;
begin
  fOptions.Title:=TitleEdit.Text;
  fOptions.Filename:=FilenameEdit.Text;
  fOptions.CmdLineParams:=MemoParameters.Lines.Text;
  fOptions.WorkingDirectory:=WorkingDirEdit.Text;
  fOptions.Key:=fKeyBox.Key;
  fOptions.Shift:=fKeyBox.ShiftState;
  FOptions.ShowConsole := ShowConsoleCheckBox.Checked;
  FOptions.HideWindow := HideWindowCheckBox.Checked;
  fOptions.HasParser[SubToolFPC]:=ScanOutputForFPCMessagesCheckBox.Checked;
  fOptions.HasParser[SubToolMake]:=ScanOutputForMakeMessagesCheckBox.Checked;
end;

procedure TExternalToolOptionDlg.UpdateButtons;
begin
  ScannersButton.Visible:=false;
  {$IFDEF Windows}
  HideWindowCheckBox.Visible:=true;
  ShowConsoleCheckBox.Visible:=true;
  {$ENDIF}
end;

function TExternalToolOptionDlg.ScannersToString(List: TStrings): string;
var
  i: Integer;
begin
  if (List=nil) or (List.Count=0) then begin
    Result:='none';
  end else begin
    Result:='';
    for i:=0 to List.Count-1 do begin
      if Result<>'' then
        Result:=Result+',';
      Result:=Result+List[i];
      if length(Result)>20 then begin
        Result:=copy(Result,1,20);
        break;
      end;
    end;
  end;
end;

procedure TExternalToolOptionDlg.FormCreate(Sender: TObject);
begin
  fScanners:=TStringList.Create;
  Caption:=lisEdtExtToolEditTool;
  TitleLabel.Caption:=dlgPOTitle;
  FilenameLabel.Caption:=lisEdtExtToolProgramfilename;
  FilenameEdit.ButtonHint:=lisClickHereToBrowseTheFileHint;

  FilenameEdit.DialogTitle:=lisSelectFile;
  FilenameEdit.Filter:=dlgFilterAll+' ('+GetAllFilesMask+')|'+GetAllFilesMask
      +'|'+dlgFilterPrograms+' (*.exe)|*.exe';

  ParametersLabel.Caption:=lisEdtExtToolParameters;
  WorkingDirLabel.Caption:=lisEdtExtToolWorkingDirectory;
  OptionsGroupBox.Caption:=lisLazBuildOptions;

  with ScanOutputForFPCMessagesCheckBox do
    Caption:=lisEdtExtToolScanOutputForFreePascalCompilerMessages;
  with ScanOutputForMakeMessagesCheckBox do
    Caption:=lisEdtExtToolScanOutputForMakeMessages;
  ShowConsoleCheckBox.Caption:=lisShowConsole;
  ShowConsoleCheckBox.Hint:=lisOnlyAvailableOnWindowsRunToolInANewConsole;
  HideWindowCheckBox.Caption:=lisHideWindow;
  HideWindowCheckBox.Hint:=lisOnlyAvailableOnWindowsRunTheToolHidden;

  with KeyGroupBox do
    Caption:=lisEdtExtToolKey;

  fKeyBox:=TShortCutGrabBox.Create(Self);
  with fKeyBox do begin
    Name:='fKeyBox';
    Align:=alClient;
    BorderSpacing.Around:=6;
    Parent:=KeyGroupBox;
  end;

  with MacrosGroupbox do
    Caption:=lisEdtExtToolMacros;

  with MacrosInsertButton do
    Caption:=lisAdd;
    
  ButtonPanel.OKButton.Caption:=lisBtnOk;
  ButtonPanel.HelpButton.Caption:=lisMenuHelp;
  ButtonPanel.CancelButton.Caption:=lisCancel;

  fOptions:=TExternalUserTool.Create(nil);
end;

procedure TExternalToolOptionDlg.FormDestroy(Sender: TObject);
begin
  FreeAndNil(fOptions);
  FreeAndNil(fScanners);
end;

procedure TExternalToolOptionDlg.HelpButtonClick(Sender: TObject);
begin
  LazarusHelp.ShowHelpForIDEControl(Self);
end;

procedure TExternalToolOptionDlg.SetOptions(TheOptions: TExternalUserTool);
begin
  if fOptions=TheOptions then exit;
  fOptions.Assign(TheOptions);
  LoadFromOptions;
end;

procedure TExternalToolOptionDlg.SetTransferMacros(
  TransferMacroList: TTransferMacroList);
begin
  if fTransferMacros=TransferMacroList then exit;
  fTransferMacros:=TransferMacroList;
  if MacrosListbox=nil then exit;
  FillMacroList;
end;

procedure TExternalToolOptionDlg.FillMacroList;
var i: integer;
begin
  MacrosListbox.Items.BeginUpdate;
  MacrosListbox.Items.Clear;
  if fTransferMacros<>nil then begin
    for i:=0 to fTransferMacros.Count-1 do begin
      if fTransferMacros[i].MacroFunction=nil then begin
        MacrosListbox.Items.Add('$('+fTransferMacros[i].Name+') - '
                    +fTransferMacros[i].Description);
      end else begin
        MacrosListbox.Items.Add('$'+fTransferMacros[i].Name+'() - '
                    +fTransferMacros[i].Description);
      end;
    end;
  end;
  MacrosListbox.Items.EndUpdate;
end;

function TExternalToolOptionDlg.KeyConflicts(Key: word; Shift: TShiftState
  ): TModalResult;
type
  TConflictType = (ctNone,ctConflictKeyA,ctConflictKeyB);
var
  i: Integer;
  ct:TConflictType;
  CurName: TCaption;
  ConflictName: String;
begin
  Result:=mrOK;
  // look if we have already this key
  if Key=VK_UNKNOWN then
    exit;
  i:=0;
  for i:=0 to fAllKeys.RelationCount-1 do
    begin
    with fAllKeys.Relations[i] do
      begin
      ct:=ctnone;
      if (ShortcutA.Key1=Key) and (ShortcutA.Shift1=Shift) then
        ct:=ctConflictKeyA
      else if (ShortcutB.Key1=Key) and (ShortcutB.Shift1=Shift) then
        ct:=ctConflictKeyB;
      if (ct<>ctNone) then begin
        CurName:=TitleEdit.Text;
        ConflictName:=GetCategoryAndName;
        if ct=ctConflictKeyA then
          ConflictName:=ConflictName
                    +' ('+KeyAndShiftStateToEditorKeyString(ShortcutA)+')'
        else
          ConflictName:=ConflictName
                   +' ('+KeyAndShiftStateToEditorKeyString(ShortcutB)+')';
        case IDEMessageDialog(lisPEConflictFound,
           Format(lisTheKeyIsAlreadyAssignedToRemoveTheOldAssignmentAnd,
                  [KeyAndShiftStateToKeyString(Key,Shift), LineEnding,
                   ConflictName, LineEnding, LineEnding, CurName]),
           mtConfirmation, [mbYes, mbNo, mbCancel])
        of
          mrYes:    Result:=mrOK;
          mrCancel: Result:=mrCancel;
          else      Result:=mrRetry;
        end;
        if Result=mrOK then begin
          if (ct=ctConflictKeyA) then
            ShortcutA:=ShortcutB;
          ClearShortcutB;
        end
        else
          break;
      end;
      end;
    end;
end;

procedure TExternalToolOptionDlg.SetComboBox(
  AComboBox: TComboBox; const AValue: string);
var i: integer;
begin
  i:=AComboBox.Items.IndexOf(AValue);
  if i>=0 then
    AComboBox.ItemIndex:=i
  else begin
    AComboBox.Items.Add(AValue);
    AComboBox.ItemIndex:=AComboBox.Items.IndexOf(AValue);
  end;
end;

procedure TExternalToolOptionDlg.MacrosInsertButtonClick(Sender: TObject);
var i, ALine: integer;
  s, AStr: string;
begin
  i:=MacrosListbox.ItemIndex;
  if i<0 then exit;
  if fTransferMacros[i].MacroFunction=nil then
    s:='$('+fTransferMacros[i].Name+')'
  else
    s:='$'+fTransferMacros[i].Name+'()';
  ALine := MemoParameters.CaretPos.Y;
  if ALine >= MemoParameters.Lines.Count then
    MemoParameters.Lines.Add('');
  AStr := MemoParameters.Lines[Aline];
  MemoParameters.Lines[Aline] := AStr + s;
end;

procedure TExternalToolOptionDlg.MacrosListboxClick(Sender: TObject);
begin
  MacrosInsertButton.Enabled:=(MacrosListbox.ItemIndex>=0);
end;

procedure TExternalToolOptionDlg.MacrosListboxDblClick(Sender: TObject);
begin
  MacrosInsertButtonClick(nil);
end;

procedure TExternalToolOptionDlg.OKButtonClick(Sender: TObject);
begin
  case KeyConflicts(fKeyBox.Key,fKeyBox.ShiftState) of
    mrCancel:   begin
        debugln('TExternalToolOptionDlg.OkButtonClick KeyConflicts failed for key1');
        ModalResult:=mrCancel;
        exit;
      end;
    mrRetry: begin
        ModalResult:=mrNone;
        exit;
      end;
    end;
  if (TitleEdit.Text<>'') and (FilenameEdit.Text<>'') then
    SaveToOptions
  else begin
    IDEMessageDialog(lisEdtExtToolTitleAndFilenameRequired,
                  lisEdtExtToolAValidToolNeedsAtLeastATitleAndAFilename,
                  mtError, [mbCancel]);
    ModalResult:=mrNone;
  end;
end;

procedure TExternalToolOptionDlg.ShowConsoleCheckBoxChange(Sender: TObject);
begin
  if ShowConsoleCheckBox.Checked then
    HideWindowCheckBox.Checked:=false;
end;

initialization
  ExternalUserToolsClass := TExternalUserTools;

end.
