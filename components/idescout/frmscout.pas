{ Form for the scout window

  Copyright (C) 2018  Michael van Canneyt  michael@freepascal.org

  This library is free software; you can redistribute it and/or modify it
  under the terms of the GNU Library General Public License as published by
  the Free Software Foundation; either version 2 of the License, or (at your
  option) any later version with the following modification:

  As a special exception, the copyright holders of this library give you
  permission to link this library with independent modules to produce an
  executable, regardless of the license terms of these independent modules,and
  to copy and distribute the resulting executable under terms of your choice,
  provided that you also meet, for each linked independent module, the terms
  and conditions of the license of that module. An independent module is a
  module which is not derived from or based on this library. If you modify
  this library, you may extend this exception to your version of the library,
  but you are not obligated to do so. If you do not wish to do so, delete this
  exception statement from your version.

  This program is distributed in the hope that it will be useful, but WITHOUT
  ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or
  FITNESS FOR A PARTICULAR PURPOSE. See the GNU Library General Public License
  for more details.

  You should have received a copy of the GNU Library General Public License
  along with this library; if not, write to the Free Software Foundation,
  Inc., 51 Franklin Street - Fifth Floor, Boston, MA 02110-1335, USA.
}
unit frmscout;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Types,
  // LCL
  LCLType, Forms, Controls, Graphics, Dialogs, StdCtrls, EditBtn,
  // LazUtils
  FileUtil, LazUTF8,
  // BuildIntf
  ComponentReg, IDEOptionsIntf,
  // IdeIntf
  IDECommands, LazIDEIntf, IDEOptEditorIntf,
  IDEScoutStrConsts;

Type
  TScoutTerrain = (stCommands,stRecentProjects,stRecentFiles,stRecentPackages,stComponents);
  TScoutTerrains = set of TScoutTerrain;

  { TSearchItem }
  TMatchPos = Array of Integer;
  TSearchItem = Class(TObject)
  private
    FKeyStroke: String;
    FMatchLen: TMatchPos;
    FMatchPos: TMatchPos;
    FOwnsSource: Boolean;
    FPrefix: String;
    FSource: TObject;
    procedure SetSource(AValue: TObject);
  Public
    Constructor Create(aSource : TObject;AOwnsSource : Boolean = False);
    Destructor Destroy; override;
  published
    Property OwnsSource: Boolean read FOwnsSource Write FOwnsSource;
    Property Source : TObject read FSource write FSource;
    Property KeyStroke : String Read FKeyStroke Write FKeyStroke;
    Property Prefix : String Read FPrefix Write FPrefix;
    Property MatchPos : TMatchPos Read FMatchPos Write FMatchPos;
    Property MatchLen : TMatchPos Read FMatchLen Write FMatchLen;
  end;

  { TOpenFileItem }

  TOpenFileItem = class(TObject)
  private
    FFileName: String;
    FHandler: TIDERecentHandler;
  public
    constructor Create(const AFileName: String; AHandler: TIDERecentHandler);
    Procedure Execute;
    Property FileName : String Read FFileName;
    Property Handler : TIDERecentHandler Read FHandler;
  end;

  { TComponentItem }

  TComponentItem = class(TObject)
  private
    Class Var
      LastParent : TComponent;
      LastLeft,LastTop : integer;
    function FindParent: TComponent;
  private
    FComponent : TRegisteredComponent;
  public
    Class Var
      Drop : Boolean;
      DefaultWidth, DefaultHeight : integer;
  Public
    constructor Create(aComponent: TRegisteredComponent);
    Procedure Execute;
    Property Component : TRegisteredComponent Read FComponent;
  end;


  { TIDEScoutForm }

  TIDEScoutForm = class(TForm)
    ESearch: TEditButton;
    LBMatches: TListBox;
    procedure ECommandChange(Sender: TObject);
    procedure ECommandKeyDown(Sender: TObject; var Key: Word; {%H-}Shift: TShiftState);
    procedure ESearchButtonClick(Sender: TObject);
    procedure FormActivate(Sender: TObject);
    procedure FormClose(Sender: TObject; var CloseAction: TCloseAction);
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure LBMatchesClick(Sender: TObject);
    procedure LBMatchesDrawItem(Control: TWinControl; Index: Integer;
      ARect: TRect; {%H-}State: TOwnerDrawState);
    procedure LBMatchesKeyUp(Sender: TObject; var Key: Word; {%H-}Shift: TShiftState);
  private
    FRefresh,
    FHighlights: TScoutTerrains;
    FKeyStrokeColor: TColor;
    FMatchColor: TColor;
    FShowCategory: Boolean;
    FSearchItems: TStringListUTF8Fast;
    FSelectedIdx: Integer;
    FOrgCaption : String;
    FShowShortCutKey: Boolean;
    procedure ClearRefreshableItems;
    procedure FillComponents;
    Procedure RefreshList;
    procedure FillRecent(aType: TIDERecentHandler);
    Procedure Initialize;
    procedure ExecuteOnIdle(Sender: TObject; var Done: Boolean);
    procedure ExecuteSelected;
    Procedure FillCommands;
    procedure FilterList(aSearchTerm: String);
    Procedure AddFileToList(aFileName : String; aType : TIDERecentHandler; CheckDuplicate : Boolean = False);
    function GetCommandCategoryString(Cmd: TIDECommand): String;
    procedure PackageOpened(Sender: TObject; AFileName: string; var AAllow: Boolean);
    procedure FileOpened(Sender: TObject; AFileName: string; var AAllow: Boolean);
    procedure ProjectOpened(Sender: TObject; AFileName: string; var AAllow: Boolean);
    procedure RefreshCaption(aCount: Integer);
  public
    Property ShowCategory : Boolean Read FShowCategory Write FShowCategory;
    Property ShowShortCutKey : Boolean Read FShowShortCutKey Write FShowShortCutKey;
    property KeyStrokeColor : TColor Read FKeyStrokeColor Write FKeyStrokeColor;
    property MatchColor : TColor Read FMatchColor Write FMatchColor;
    Property Highlights : TScoutTerrains Read FHighlights Write FHighlights;
  end;


Const
  AllTerrains = [stCommands,stRecentProjects,stRecentFiles,stRecentPackages];

Var
  ScoutTerrains : TScoutTerrains = AllTerrains;
  ShowCmdCategory : Boolean = True;
  ShowShortCutKey : Boolean = True;
  MatchColor : TColor = clMaroon;
  KeyStrokeColor : TColor = clNavy;
  SettingsClass : TAbstractIDEOptionsEditorClass = Nil;

Procedure ShowScoutForm;
Procedure ApplyScoutOptions;
Procedure SaveScoutOptions;
procedure LoadScoutOptions;
procedure CreateScoutWindow(Sender: TObject; aFormName: string; var AForm: TCustomForm; DoDisableAutoSizing: boolean);

implementation

Uses
  StrUtils, LCLIntf, LCLProc,  PackageIntf, BaseIDEIntf, LazConfigStorage, IDEWindowIntf, propedits, srceditorintf, componenteditors;

{$R *.lfm}

var
  ScoutForm: TIDEScoutForm;


Const
  IDEScoutOptsFile = 'idescout.xml';

  KeyHighLight = 'highlight/';
  KeyShowCategory = 'showcategory/value';
  KeyShowShortCut = 'showShortCut/value';
  KeyShortCutColor = 'ShortCutColor/value';
  KeyMatchColor = 'MatchColor/value';
  KeyDefaultComponentWidth = 'Components/DefaultWidth';
  KeyDefaultComponentHeight = 'Components/DefaultHeight';
  KeyDropComponent = 'Components/Drop';


  HighlightNames : Array[TScoutTerrain] of string =
    ('Commands','Projects','Files','Packages','Components');

procedure LoadScoutOptions;
var
  Cfg: TConfigStorage;
  SH  : TScoutTerrain;
  SHS : TScoutTerrains;

begin
  Cfg:=GetIDEConfigStorage(IDEScoutOptsFile,true);
  try
   SHS:=[];
   for SH in TScoutTerrain do
     if Cfg.GetValue(KeyHighLight+HighlightNames[SH],SH In ScoutTerrains) then
       Include(SHS,SH);
    ScoutTerrains:=SHS;
    TComponentItem.DefaultWidth:=Cfg.GetValue(KeyDefaultComponentWidth,TComponentItem.DefaultWidth);
    TComponentItem.DefaultHeight:=Cfg.GetValue(KeyDefaultComponentHeight,TComponentItem.DefaultHeight);
    TComponentItem.Drop:=Cfg.GetValue(KeyDropComponent,TComponentItem.Drop);
    ShowCmdCategory:=Cfg.GetValue(KeyShowCategory,ShowCmdCategory);
    ShowShortCutKey:=Cfg.GetValue(KeyShowShortCut,ShowShortCutKey);
    KeyStrokeColor:=TColor(Cfg.GetValue(KeyShortCutColor,Ord(KeyStrokeColor)));
    MatchColor:=TColor(Cfg.GetValue(KeyMatchColor,Ord(MatchColor)));
    ApplyScoutOptions;
  finally
    Cfg.Free;
  end;
end;


procedure SaveScoutOptions;
var
  Cfg: TConfigStorage;
  SH  : TScoutTerrain;

begin
  Cfg:=GetIDEConfigStorage(IDEScoutOptsFile,false);
  try
    for SH in TScoutTerrain do
      Cfg.SetValue(KeyHighLight+HighlightNames[SH],SH In ScoutTerrains);
    Cfg.SetValue(KeyDefaultComponentWidth,TComponentItem.DefaultWidth);
    Cfg.SetValue(KeyDefaultComponentHeight,TComponentItem.DefaultHeight);
    Cfg.SetValue(KeyDropComponent,TComponentItem.Drop);
    Cfg.SetValue(KeyShowCategory,ShowCmdCategory);
    Cfg.SetValue(KeyShowShortCut,ShowShortCutKey);
    Cfg.SetValue(KeyShortCutColor,Ord(KeyStrokeColor));
    Cfg.SetValue(KeyMatchColor,Ord(MatchColor));
  finally
    Cfg.Free;
  end;
end;

Procedure ApplyScoutOptions;

begin
  if Assigned(ScoutForm) then
    begin
    ScoutForm.ShowCategory:=ShowCmdCategory;
    ScoutForm.MatchColor:=MatchColor;
    ScoutForm.KeyStrokeColor:=KeyStrokeColor;
    ScoutForm.ShowShortCutKey:=ShowShortCutKey;
    ScoutForm.Highlights:=ScoutTerrains;
    ScoutForm.Initialize;
    end;
end;

Procedure MaybeCreateScoutForm;

begin
  if ScoutForm=Nil then
    begin
    ScoutForm:=TIDEScoutForm.Create(Application);
    ApplyScoutOptions;
    end;
end;

Procedure ShowScoutForm;

begin
  MaybeCreateScoutForm;
  IDEWindowCreators.ShowForm(ScoutForm,True,vmAlwaysMoveToVisible);
end;


procedure CreateScoutWindow(Sender: TObject; aFormName: string;
  var AForm: TCustomForm; DoDisableAutoSizing: boolean);
begin
  MaybeCreateScoutForm;
  aForm:=ScoutForm;
end;

{ TComponentItem }

constructor TComponentItem.Create(aComponent: TRegisteredComponent);
begin
  FComponent:=aComponent;
end;

Function TComponentItem.FindParent : TComponent;

Var
  ASelections: TPersistentSelectionList;
begin
  Result:=Nil;
  ASelections := TPersistentSelectionList.Create;
  try
    GlobalDesignHook.GetSelection(ASelections);
    if (ASelections.Count>0) and (ASelections[0] is TComponent) then
      Result := TComponent(ASelections[0])
    else if GlobalDesignHook.LookupRoot is TComponent then
      Result:= TComponent(GlobalDesignHook.LookupRoot)
    else
      Result := nil;
  finally
    ASelections.Free;
  end;
end;

procedure TComponentItem.Execute;

var
  NewParent: TComponent;
  RootDesigner : TIDesigner;
  CompDesigner : TComponentEditorDesigner;

begin
  IDEComponentPalette.SetSelectedComp(FComponent,False);
  if not Drop then
    exit;
  NewParent:=FindParent;
  if NewParent=nil then
      Exit;
  RootDesigner:=FindRootDesigner(NewParent);
  if not (RootDesigner is TComponentEditorDesigner) then
    exit;
  CompDesigner:=RootDesigner as TComponentEditorDesigner;
  CompDesigner.AddComponentCheckParent(NewParent, NewParent, nil, FComponent.ComponentClass);
  if NewParent=nil then
    Exit;
  if LastParent<>NewParent then
    begin
    LastLeft := 0;
    LastTop := 0;
    LastParent := NewParent;
    end;
  Inc(LastLeft, 8);
  Inc(LastTop, 8);
  CompDesigner.AddComponent(FComponent, FComponent.ComponentClass, NewParent, Lastleft, LastTop, DefaultWidth, DefaultHeight);
end;

{ TOpenFileItem }

constructor TOpenFileItem.Create(const AFileName : String; AHandler: TIDERecentHandler);
begin
  FFileName:=AFileName;
  FHandler:=aHandler;
end;

procedure TOpenFileItem.Execute;
begin
  case fHandler of
    irhProjectFiles : LazarusIDE.DoOpenProjectFile(FileName,[ofAddToRecent]);
    irhOpenFiles : LazarusIDE.DoOpenEditorFile(FileName,-1,-1,[ofAddToRecent]);
    irhPackageFiles : PackageEditingInterface.DoOpenPackageFile(FFileName,[pofAddToRecent],False);
  end;
end;

{ TSearchItem }

procedure TSearchItem.SetSource(AValue: TObject);
begin
  if FSource=AValue then Exit;
  FSource:=AValue;
end;

constructor TSearchItem.Create(aSource: TObject; AOwnsSource: Boolean);
begin
  FSource:=aSource;
  FOwnsSource:=AOwnsSource;
end;

destructor TSearchItem.Destroy;
begin
  if OwnsSource then
    FreeAndNil(FSource);
  Inherited;
end;

{ TIDEScoutForm }

procedure TIDEScoutForm.ECommandChange(Sender: TObject);
begin
  FilterList(ESearch.Text);
end;

procedure TIDEScoutForm.ECommandKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  Case Key of
  VK_ESCAPE: Hide;
  VK_UP:
    begin
    If LBMatches.ItemIndex>0 then
      LBMatches.ItemIndex:=LBMatches.ItemIndex-1;
    Key:=0;
    ESearch.SelStart:=Length(ESearch.Text);
    end;
  VK_DOWN:
    begin
    If LBMatches.ItemIndex<LBMatches.Items.Count-1 then
      LBMatches.ItemIndex:=LBMatches.ItemIndex+1;
    Key:=0;
    ESearch.SelStart:=Length(ESearch.Text);
    end;
  VK_RETURN :
    If LBMatches.ItemIndex>=0 then
      ExecuteSelected;
  end;
end;

procedure TIDEScoutForm.ESearchButtonClick(Sender: TObject);
begin
  LazarusIDE.DoOpenIDEOptions(SettingsClass,'IDE Scout');
  Close;
end;


procedure TIDEScoutForm.FormActivate(Sender: TObject);
begin
  ESearch.SetFocus;
end;

procedure TIDEScoutForm.FormClose(Sender: TObject;
  var CloseAction: TCloseAction);
begin
  CloseAction:=caHide;
end;

procedure TIDEScoutForm.RefreshCaption(aCount : Integer);

begin
  if ACount=-1 then
    Caption:=FOrgCaption+Format(' (%d)',[FSearchItems.Count])
  else
    Caption:=FOrgCaption+Format(' (%d/%d)',[aCount,FSearchItems.Count]);
end;

procedure TIDEScoutForm.FilterList(aSearchTerm: String);

Var
  i : Integer;
  Itm : TSearchItem;
  Words : Array of string;
  MatchPos : Array of Integer;
  MatchLen : Array of Integer;

  Function Match(S : String) : Boolean;

  Var
    I : integer;

  begin
    Result:=True;
    I:=0;
    While Result and (I<Length(Words)) do
      begin
      MatchPos[i]:=Pos(Words[i],S);
      Result:=MatchPos[i]<>0;
      inc(I);
      end;
  end;

begin
  if (ASearchTerm='') then
    begin
    LBMatches.Clear;
    Exit;
    end;
  aSearchTerm:=LowerCase(aSearchTerm);
  Setlength(Words,WordCount(aSearchTerm,[' ']));
  Setlength(MatchPos,Length(Words));
  Setlength(MatchLen,Length(Words));
  For I:=1 to Length(Words) do
    begin
    Words[I-1]:=ExtractWord(I,aSearchTerm,[' ']);
    MatchLen[I-1]:=Length(Words[I-1]);
    end;
  LBMatches.Items.BeginUpdate;
  try
    LBMatches.Items.Clear;
    For I:=0 to FSearchItems.Count-1 do
      if Match(FSearchItems[I]) then
        begin
        Itm:=FSearchItems.Objects[I] as TSearchItem;
        Itm.MatchPos:=Copy(MatchPos,0,Length(MatchPos));
        Itm.MatchLen:=Copy(MatchLen,0,Length(MatchLen));
        LBMatches.Items.AddObject(FSearchItems[I],Itm);
        end;
    RefreshCaption(LBMatches.Items.Count);
  finally
    LBMatches.Items.EndUpdate;
    LBMatches.Visible:=LBMatches.Items.Count>0;
    If LBMatches.Visible then
      LBMatches.ItemIndex:=0;
  end;
end;

procedure TIDEScoutForm.AddFileToList(aFileName: String; aType: TIDERecentHandler; CheckDuplicate : Boolean = False);

Var
  F : TOpenFileItem;
  SI : TSearchItem;
  FN,Prefix : String;

begin
  if ShowCategory then
    Case aType of
      irhPackageFiles : Prefix:='Package: ';
      irhProjectFiles : Prefix:='Project: ';
      irhOpenFiles : Prefix:='File: ';
    end;
  FN:=Prefix+aFileName;
  if (Not CheckDuplicate) or (FSearchItems.IndexOf(FN)=-1) then
    begin
    F:=TOpenFileItem.Create(aFileName,aType);
    SI:=TSearchItem.Create(F,True);
    SI.Prefix:=Prefix;
    FSearchItems.AddObject(FN,SI);
    end;

end;

procedure TIDEScoutForm.FormCreate(Sender: TObject);
begin
  FSearchItems:=TStringListUTF8Fast.Create;
  FSearchItems.OwnsObjects:=True;
  FSelectedIdx:=-1;
  Application.AddOnIdleHandler(@ExecuteOnIdle);
  Caption:=isrsIDEScout;
  FOrgCaption:=Caption;
  ESearch.TextHint:=isrsTypeSearchTerms;
end;

procedure TIDEScoutForm.FormDestroy(Sender: TObject);
begin
  FreeAndNil(FSearchItems);
end;

procedure TIDEScoutForm.FormShow(Sender: TObject);

begin
  ESearch.Clear;
  LBMatches.Clear;
  RefreshCaption(-1);
  if FRefresh<>[] then
    RefreshList;
end;

procedure TIDEScoutForm.LBMatchesClick(Sender: TObject);

begin
  ExecuteSelected;
end;

procedure TIDEScoutForm.LBMatchesDrawItem(Control: TWinControl; Index: Integer;
  ARect: TRect; State: TOwnerDrawState);

Const
  LeftMargin = 5;
  RightMargin = LeftMargin;

Var
  LB : TListbox;
  DS,S : String;
  Itm : TSearchItem;
  R : TRect;
  P,I,SP,W : Integer;
  FC : TColor;

begin
  LB:=Control as TListBox;
  LB.Canvas.FillRect(ARect);
  FC:=LB.Canvas.Font.Color;
  Itm:=LB.Items.Objects[Index] as TSearchItem;
  S:=LB.Items[Index];
  R:=ARect;
  if ShowShortCutKey and (Itm.KeyStroke<>'') then
    begin
    W:=LB.Canvas.TextWidth(Itm.KeyStroke);
    R.Right:=R.Right-W-RightMargin;
    end;
  Inc(R.Left,LeftMargin);
  SP:=1;
  For I:=0 to Length(Itm.MatchPos)-1 do
    begin
    P:=Itm.MatchPos[i];
    if (P-SP>0) then
      begin
      DS:=Copy(S,SP,P-SP);
      LB.Canvas.TextRect(R,R.Left,R.Top,DS);
      Inc(R.Left,LB.Canvas.TextWidth(DS));
      end;
    DS:=Copy(S,P,Itm.MatchLen[i]);
    LB.Canvas.Font.Color:=MatchColor;
    LB.Canvas.TextRect(R,R.Left,R.Top,DS);
    LB.Canvas.Font.Color:=FC;
    Inc(R.Left,LB.Canvas.TextWidth(DS));
    SP:=P+Itm.MatchLen[i];
    end;
  if SP<=Length(S) then
    begin
    DS:=Copy(S,SP,Length(S)-SP+1);
    LB.Canvas.TextRect(R,R.Left,R.Top,DS);
    end;
  if Itm.KeyStroke<>'' then
    begin
    R.Left:=R.Right+1;
    R.Right:=aRect.Right;
    LB.Canvas.Font.Color:=KeyStrokeColor;
    LB.Canvas.TextRect(R,R.Left,R.Top,Itm.KeyStroke);
    end;
end;

procedure TIDEScoutForm.ExecuteOnIdle(Sender: TObject; var Done: Boolean);
Var
  Itm : TSearchItem;
begin
  if FSelectedIdx=-1 then exit;
  Itm:=LBMatches.Items.Objects[FSelectedIdx] as TSearchItem;
  if Itm.Source is TIDECommand then
    TIDECommand(Itm.Source).Execute(SourceEditorManagerIntf.ActiveEditor)
  else if Itm.Source is TComponentItem then
    TComponentItem(Itm.Source).Execute
  else if Itm.Source is TOpenFileItem then
    TOpenFileItem(Itm.Source).Execute;
  FSelectedIdx:=-1;
  Done:=True;
end;

procedure TIDEScoutForm.ExecuteSelected;
begin
  FSelectedIdx:=LBMatches.ItemIndex;
  if FSelectedIdx>=0 then
  begin
    Hide;
    sleep(10);
  end;
end;


procedure TIDEScoutForm.LBMatchesKeyUp(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  if Key=VK_ESCAPE then
    Hide;
end;

procedure TIDEScoutForm.FillRecent(aType : TIDERecentHandler);

Var
  L : TStringList;
  S : String;

begin
  L:=TstringList.Create;
  try
    IDEEnvironmentOptions.GetRecentFiles(aType,L);
    For S in L do
       AddFileToList(S,aType,False);
  finally
    L.Free;
  end;
end;

procedure TIDEScoutForm.FillComponents;

Var
  I : integer;
  Prefix,CC : String;
  RC : TRegisteredComponent;
  SI : TSearchItem;

begin
  For I:=0 to IDEComponentPalette.Comps.Count-1 do
    begin
    RC:=IDEComponentPalette.Comps[I];
    if RC.CanBeCreatedInDesigner then
      begin
      CC:=RC.ComponentClass.ClassName+' ('+RC.GetUnitName+')';
      Prefix:='Component: ';
      SI:=TSearchItem.Create(TComponentItem.Create(RC),True);
      SI.Prefix:=Prefix;
      FSearchItems.AddObject(UTF8LowerCase(Prefix+CC),SI);
      end;
    end;
end;

procedure TIDEScoutForm.ClearRefreshableItems;

Var
  I : Integer;
  Si : TSearchItem;
  SH : Set of TIDERecentHandler;

begin
  SH:=[];
  if stRecentFiles in FRefresh then
    Include(SH,irhOpenFiles);
  if stRecentProjects in FRefresh then
    Include(SH,irhProjectFiles);
  if stRecentPackages in FRefresh then
    Include(SH,irhPackageFiles);
  I:=FSearchItems.Count-1;
  While I>=0 do
    begin
    SI:=TSearchItem(FSearchItems.Objects[i]);
    if (SI.Source is TOpenFileItem) then
      if TOpenFileItem(SI.Source).Handler in SH then
         FSearchItems.Delete(I);
    Dec(I);
    end;
end;

procedure TIDEScoutForm.RefreshList;

begin
  FSearchItems.Sorted:=False;
  FSearchItems.BeginUpdate;
  try
    ClearRefreshableItems;
    if stRecentFiles in FRefresh then
      FillRecent(irhOpenFiles);
    if stRecentProjects in FRefresh then
      FillRecent(irhProjectFiles);
    if stRecentPackages in FRefresh then
      FillRecent(irhPackageFiles);
    FRefresh:=[];
  finally
    FSearchItems.Sorted:=True;
    FSearchItems.EndUpdate;
  end;
end;

procedure TIDEScoutForm.Initialize;
begin
  FSearchItems.Sorted:=False;
  FSearchItems.BeginUpdate;
  try
    FSearchItems.Clear;
    if stCommands in Highlights then
      FillCommands;
    if stComponents in Highlights then
      FillComponents;
    if stRecentFiles in Highlights then
      begin
      IDEEnvironmentOptions.AddHandlerAddToRecentOpenFiles(@FileOpened,False);
      FillRecent(irhOpenFiles);
      end;
    if stRecentProjects in Highlights then
      begin
      IDEEnvironmentOptions.AddHandlerAddToRecentProjectFiles(@ProjectOpened,False);
      FillRecent(irhProjectFiles);
      end;
    if stRecentPackages in Highlights then
      begin
      IDEEnvironmentOptions.AddHandlerAddToRecentPackageFiles(@PackageOpened,False);
      FillRecent(irhPackageFiles);
      end;
  finally
    FSearchItems.Sorted:=True;
    FSearchItems.EndUpdate;
  end;
end;

function TIDEScoutForm.GetCommandCategoryString(Cmd: TIDECommand): String;

Const
  Cmds = ' commands';

Var
  Cat: TIDECommandCategory;
  D : String;
  P : Integer;

begin
  Result:='';
  If Not ShowCategory then
    Exit;
  Cat:=Cmd.Category;
  While (Cat<>Nil) and (Cat.Parent<>Nil) do
    Cat:=Cat.Parent;
  If Cat<>Nil then
    begin
    D:=Cat.Description;
    P:=Pos(' commands',D);
    If (P>0) and (P=Length(D)-Length(Cmds)+1) then
      D:=Copy(D,1,P-1);
    Result:=D+': ';
    end;
end;

procedure TIDEScoutForm.PackageOpened(Sender: TObject; AFileName: string;
  var AAllow: Boolean);
begin
  Include(FRefresh,stRecentPackages);
end;

procedure TIDEScoutForm.FileOpened(Sender: TObject; AFileName: string;
  var AAllow: Boolean);
begin
  Include(FRefresh,stRecentFiles);
end;

procedure TIDEScoutForm.ProjectOpened(Sender: TObject; AFileName: string;
  var AAllow: Boolean);
begin
  Include(FRefresh,stRecentProjects);
end;

procedure TIDEScoutForm.FillCommands;
var
  I, J: Integer;
  Itm : TSearchItem;
  Cmd : TIDECommand;
  Ks,Pref : String;

begin
  For I:=0 to IDECommandList.CategoryCount-1 do
    for J:=0 to IDECommandList.Categories[I].Count-1 do
      begin
      if TObject(IDECommandList.Categories[I].Items[J]) is TIDECommand then
        begin
        Cmd:=TIDECommand(IDECommandList.Categories[I].Items[J]);
        Pref:=GetCommandCategoryString(Cmd);
        ks:='';
        if Cmd.ShortcutA.Key1<>VK_UNKNOWN then
          begin
          ks:=' ('+KeyAndShiftStateToKeyString(Cmd.ShortcutA.Key1,Cmd.ShortcutA.Shift1);
          if Cmd.ShortcutA.Key2<>VK_UNKNOWN then
            ks:=Ks+', '+KeyAndShiftStateToKeyString(Cmd.ShortcutA.Key2,Cmd.ShortcutA.Shift2);
          ks:=ks+')';
          end;
        Itm:=TSearchItem.Create(Cmd);
        Itm.Prefix:=Pref;
        Itm.KeyStroke:=Ks;
        FSearchItems.AddObject(UTF8LowerCase(Pref+Cmd.LocalizedName),Itm);
        end;
      end;
  RefreshCaption(-1);
end;

end.

