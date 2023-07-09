{
 *****************************************************************************
  See the file COPYING.modifiedLGPL.txt, included in this distribution,
  for details about the license.
 *****************************************************************************

  Author: Maciej Izak

  DaThoX 2004-2015
  FreeSparta.com
}

unit sparta_MainIDE;

{$mode delphi}{$H+}

interface

uses
  Classes, SysUtils,
  Generics.Collections, Generics.Defaults,
  contnrs,
  // LCL
  LCLIntf, LCLType, LMessages, ComCtrls, Controls, Forms, ExtCtrls, Graphics,
  // IdeIntf
  SrcEditorIntf, LazIDEIntf, FormEditingIntf, PropEdits, PropEditUtils, ComponentEditors,
  // Sparta
  sparta_InterfacesMDI, sparta_strconsts, sparta_DesignedForm, sparta_resizer,
  sparta_FakeForm, sparta_FakeFrame, sparta_FakeCustom;

const
  WM_SETNOFRAME = WM_USER;
  WM_BOUNDTODESIGNTABSHEET = WM_USER + 1;

type
  { TDesignFormData }

  TDesignFormData = class(TComponent, IDesignedForm, IDesignedFormIDE)
  private
    FWndMethod: TWndMethod;
    FForm: IDesignedFormIDE;
    FLastScreenshot: TBitmap;
    FPopupParent: TSourceEditorWindowInterface;
    FHiding: boolean;
    FFormImages: TList<TImage>;
    procedure WndMethod(var Msg: TLMessage);
    procedure SetPopupParent(AVal: TSourceEditorWindowInterface);
    procedure DoAddForm;
    procedure FormChangeBounds(Sender: TObject);
  public
    class var AddFormEvents: TList<TNotifyEvent>;
    class constructor Init;
    class destructor Finit;
    procedure AddFormImage(AImage: TImage);
    procedure RemoveFormImage(AImage: TImage);
    procedure RepaintFormImages;

    property Form: IDesignedFormIDE read FForm implements IDesignedForm, IDesignedFormIDE;
    property LastScreenshot: TBitmap read FLastScreenshot;
    property PopupParent: TSourceEditorWindowInterface read FPopupParent write SetPopupParent;

    constructor Create(AForm: TCustomForm); reintroduce;
    destructor Destroy; override;
  end;

  { TModulePageControl }

  TModulePageControl = class(TPageControl)
  private
    FResizer: TResizer;
    FDesignFormData: TDesignFormData;
  protected
    procedure SetDesignFormData(const AValue: TDesignFormData); virtual;
  public
    destructor Destroy; override;
    procedure ShowDesignPage;
    procedure HideDesignPage;
    procedure BoundToDesignTabSheet;

    property Resizer: TResizer read FResizer;
    property DesignFormData: TDesignFormData read FDesignFormData write SetDesignFormData;
  end;

  { TSourceEditorWindowData }

  TSourceEditorWindowData = class
  private
    FActiveDesignFormData: TDesignFormData;
    FForm: TSourceEditorWindowInterface;
    FPageCtrlList: TDictionary<TSourceEditorInterface, TModulePageControl>;
    FLastTopParent: TControl;

    procedure SetActiveDesignFormData(const AValue: TDesignFormData);
    procedure OnChangeBounds(Sender: TObject);
    procedure AddPageCtrl(ASrcEditor: TSourceEditorInterface; APage: TModulePageControl);
    procedure RemovePageCtrl(ASrcEditor: TSourceEditorInterface);
  public
    constructor Create(AForm: TSourceEditorWindowInterface);
    destructor Destroy; override;
    property ActiveDesignFormData: TDesignFormData read FActiveDesignFormData write SetActiveDesignFormData;
    procedure BoundToDesignTabSheet;
  end;

  { TDTXTabMaster }

  TDTXTabMaster = class(TIDETabMaster)
  private
    FAutoSizeControlList: TObjectList;
  protected
    function GetTabDisplayState: TTabDisplayState; override;
    function GetTabDisplayStateEditor(Index: TSourceEditorInterface): TTabDisplayState; override;
  public
    constructor Create;
    destructor Destroy; override;
    function AutoSizeInShowDesigner(AControl: TControl): Boolean; override;
    procedure EnableAutoSizing(AControl: TControl);
    procedure ToggleFormUnit; override;
    procedure JumpToCompilerMessage(ASourceEditor: TSourceEditorInterface); override;

    procedure ShowCode(ASourceEditor: TSourceEditorInterface); override;
    procedure ShowDesigner(ASourceEditor: TSourceEditorInterface; {%H-}AIndex: Integer = 0); override;
    procedure ShowForm(AForm: TCustomForm); override;
  end;

  { TDTXComponentsMaster }

  TDTXComponentsMaster = class(TIDEComponentsMaster)
    function DrawNonVisualComponents(ALookupRoot: TComponent): Boolean; override;
  end;

  TFormHack = class(TCustomForm);

  { TSpartaMainIDE }

  TSpartaMainIDE = class(TObject)
  public
    class function GetCurrentResizer: TResizer;
    class procedure TryFreeFormData(Form: TCustomForm);

    class procedure Screen_FormAdded(Sender: TObject; Form: TCustomForm);
    class procedure Screen_FormDel(Sender: TObject; Form: TCustomForm);

    class procedure WindowCreate(Sender: TObject);
    class procedure WindowDestroy(Sender: TObject);
    class procedure WindowShow(Sender: TObject);
    class procedure WindowHide(Sender: TObject);

    class procedure EditorActivated(Sender: TObject);
    class procedure EditorDestroyed(Sender: TObject);
    class procedure EditorCreate(Sender: TObject);

    class procedure TabChange(Sender: TObject);

    class procedure GlobalOnChangeBounds(Sender: TObject);
    class procedure GlobalSNOnChangeBounds(Sender: TObject);
    class procedure OnShowDesignerForm(Sender: TObject; {%H-}AEditor: TSourceEditorInterface;
                                 AComponentPaletteClassSelected: Boolean);
    class procedure OnShowSrcEditor(Sender: TObject);

    class procedure OnShowMethod(const Name: String);
    class procedure OnDesignRefreshPropertyValues;
    class procedure OnModifiedPersistentAdded({%H-}APersistent: TPersistent; {%H-}Select: Boolean);
    class procedure OnModifiedSender(Sender: TObject);
    class procedure OnModified(APersistent: TPersistent);
    class procedure DesignerSetFocus;
    class procedure OnDesignMouseDown(Sender: TObject; {%H-}Button: TMouseButton;
      {%H-}Shift: TShiftState; {%H-}X, {%H-}Y: Integer);
  end;

var
  normForms: Classes.TList; // normal forms
  dsgnForms: Classes.TList; // design forms
  SourceEditorWindows: TObjectDictionary<TSourceEditorWindowInterface, TSourceEditorWindowData>;
  LastActiveSourceEditorWindow: TSourceEditorWindowInterface = nil;
  LastActiveSourceEditor: TSourceEditorInterface = nil;
  BoundInitialized: Boolean;

function FindModulePageControl(AForm: TSourceEditorWindowInterface): TModulePageControl; overload;
function FindSourceEditorForDesigner(ADesigner: TIDesigner): TSourceEditorInterface;

implementation

uses
  sparta_ResizerFrame;

// FUTURE USE
//
//function FindDesignForm(ADesigner: TIDesigner): TCustomForm;
//var
//  f: TDesignFormData;
//begin
//  for Pointer(f) in dsgnForms do
//    with f as IDesignedForm do
//    if Form.Designer = ADesigner then
//      Exit(Form);
//
//  Result := nil;
//end;
//
//function FindDesignFormData(AForm: TSourceEditorWindowInterface): TDesignFormData; overload;
//begin
//  Result := FindDesignFormData(
//    FindModulePageControl(AForm)
//  );
//end;
//
//procedure HideAllForms;
//var
//  f: TDesignFormData;
//begin
//  for Pointer(f) in dsgnForms do
//    ShowWindow(f.Form.Form.Handle, SW_HIDE);
//end;

function FindModulePageControl(ASourceEditor: TSourceEditorInterface): TModulePageControl; overload;
var
  LParent: TWinControl;
begin
  if ASourceEditor = nil then
    Exit(nil);
  LParent := ASourceEditor.EditorControl.Parent;
  while LParent <> nil do
  begin
    if LParent is TModulePageControl then
      Exit(TModulePageControl(LParent));
    LParent := LParent.Parent;
  end;
  Result := nil;
end;

function FindModulePageControl(AForm: TSourceEditorWindowInterface): TModulePageControl; overload;
begin
  Result := FindModulePageControl(AForm.ActiveEditor);
end;

function AbsoluteFindModulePageControl(ASrcEditor: TSourceEditorInterface): TModulePageControl;
var
  LSEWD: TSourceEditorWindowData;
begin
  Result := nil;
  for LSEWD in SourceEditorWindows.Values do
    if LSEWD.FPageCtrlList.ContainsKey(ASrcEditor) then
      Exit(LSEWD.FPageCtrlList[ASrcEditor]);
end;

function FindSourceEditorForDesigner(ADesigner: TIDesigner): TSourceEditorInterface;
var
  i: Integer;
begin
  for i := 0 to SourceEditorManagerIntf.SourceEditorCount - 1 do
    if SourceEditorManagerIntf.SourceEditors[i].GetDesigner(False) = ADesigner then
      Exit(SourceEditorManagerIntf.SourceEditors[i]);
  Result := nil;
end;

function FindDesignFormData(ADesigner: TIDesigner): TDesignFormData; overload;
var
  p: Pointer;
  f: TDesignFormData absolute p;
  fi: IDesignedForm = nil;
begin
  Result := nil;
  if ADesigner = nil then
    Exit;
  for p in dsgnForms do
  begin
    fi := f.FForm;
    if (fi.Form.Designer = ADesigner) then
      Exit(f);
  end;
end;

procedure RefreshAllSourceWindowsModulePageControl;
var
  LWindow: TSourceEditorWindowInterface;
  LPageCtrl: TModulePageControl;
begin
  for LWindow in SourceEditorWindows.Keys do
  begin
    LPageCtrl := FindModulePageControl(LWindow);
    // for example LPageCtrl is nil when we clone module to new window
    if (LPageCtrl = nil) or (csDestroying in LWindow.ComponentState) then
      Continue;
    if LWindow.ActiveEditor = nil then
      LPageCtrl.HideDesignPage
    else
      if LWindow.ActiveEditor.GetDesigner(True) <> nil then
        // TODO some check function: is displayed right form?
        LPageCtrl.ShowDesignPage
      else
        LPageCtrl.HideDesignPage;
  end;
end;

// sometimes at some level of initialization form can not contain TIDesigner
// (during ide run and when is oppened default project with some TForm1)
function FindDesignFormData(AForm: TCustomForm): TDesignFormData; overload;
var
  f: TDesignFormData;
begin
  Result := nil;
  if AForm = nil then
    Exit;
  for Pointer(f) in dsgnForms do
    if (f as IDesignedForm).Form = AForm then
      Exit(f);
end;

function FindDesignFormData(AModulePageCtrl: TModulePageControl): TDesignFormData; overload;
var
  LSourceWindow: TSourceEditorWindowInterface;
  LSourceEditor: TSourceEditorInterface;
begin
  Result := nil;
  if AModulePageCtrl = nil then
    Exit;
  for LSourceWindow in SourceEditorWindows.Keys do
  begin
    if AModulePageCtrl.Owner = LSourceWindow then
    begin
      LSourceEditor := LSourceWindow.ActiveEditor;
      if LSourceEditor = nil then
        Exit;
      Result := FindDesignFormData(LSourceEditor.GetDesigner(True));
      Exit;
    end;
  end;
end;

{ TDesignFormData }

procedure TDesignFormData.WndMethod(var Msg: TLMessage);

  // Without this button F12 don't work. (after creating new for editor is inactive) :<
  procedure FixF12_ActiveEditor;
  var
    i: Integer;
  begin
    // Just do it for new created forms or the last loaded form becomes the active
    // source editor after reopening a project.
    if Form.Form.Designer <> SourceEditorManagerIntf.ActiveEditor.GetDesigner(True) then Exit;

    SourceEditorManagerIntf.ActiveEditor := nil;
    for i := 0 to SourceEditorManagerIntf.UniqueSourceEditorCount - 1 do
      if Form.Form.Designer = SourceEditorManagerIntf.UniqueSourceEditors[i].GetDesigner(True) then
      begin
        SourceEditorManagerIntf.ActiveEditor := SourceEditorManagerIntf.UniqueSourceEditors[i];
        Break;
      end;
  end;

var
  Timer: TLMTimer;
begin
  if Msg.msg = LM_TIMER then
  begin
    Timer := TLMTimer(Msg);
    if Timer.TimerID = WM_SETNOFRAME then
    begin
      KillTimer(FForm.Form.Handle, WM_SETNOFRAME);
      ShowWindow(Form.Form.Handle, SW_HIDE);
      FHiding := False;
      FixF12_ActiveEditor;
      if Form.Form is TFakeForm then
        RepaintFormImages;
      Exit;
    end;
    if Timer.TimerID = WM_BOUNDTODESIGNTABSHEET then
    begin
      KillTimer(FForm.Form.Handle, WM_BOUNDTODESIGNTABSHEET);
      SourceEditorWindows[Form.LastActiveSourceWindow].BoundToDesignTabSheet;
      Exit;
    end;
  end;

  // we need to correct ActiveEditor to right form
  // this code works correctly on Windows platform 
  // (is necessery for selecting controls after form resizing).
  // in Linux platforms below code brings problems with QT (inactive form)
  {$IFDEF WINDOWS}
  case Msg.msg of
    LM_LBUTTONDOWN, LM_RBUTTONDOWN, LM_MBUTTONDOWN, LM_XBUTTONDOWN:
      if Form.LastActiveSourceWindow <> nil then
      begin
        SourceEditorManagerIntf.ActiveSourceWindow := Form.LastActiveSourceWindow;
        SourceEditorManagerIntf.ActiveEditor := Form.LastActiveSourceWindow.ActiveEditor;
      end;
  end;
  {$ENDIF}

  FWndMethod(Msg);
end;

procedure TDesignFormData.SetPopupParent(AVal: TSourceEditorWindowInterface);
begin
  FPopupParent := AVal;
  Form.RealPopupParent := FPopupParent;
end;

class constructor TDesignFormData.Init;
begin
  AddFormEvents := TList<TNotifyEvent>.Create;
end;

class destructor TDesignFormData.Finit;
begin
  AddFormEvents.Free;
end;

procedure TDesignFormData.AddFormImage(AImage: TImage);
begin
  if FFormImages <> nil then
    FFormImages.Add(AImage);
end;

procedure TDesignFormData.RemoveFormImage(AImage: TImage);
begin
  if FFormImages <> nil then
    FFormImages.Remove(AImage);
end;

procedure TDesignFormData.RepaintFormImages;
var
  LImage: TImage;
begin
  if FFormImages <> nil then
    for LImage in FFormImages do
      LImage.OnResize(LImage);
end;

procedure TDesignFormData.DoAddForm;
var
  ne: TNotifyEvent;
begin
  for ne in AddFormEvents do
    ne(Self);
end;

procedure TDesignFormData.FormChangeBounds(Sender: TObject);
begin
  if not FForm.Update then
    SetTimer(FForm.Form.Handle, WM_BOUNDTODESIGNTABSHEET, 10, nil);
end;

constructor TDesignFormData.Create(AForm: TCustomForm);
begin
  FForm := TDesignedFormImpl.Create(Self, AForm);
  AForm.AddHandlerOnChangeBounds(FormChangeBounds);

  FLastScreenshot := TBitmap.Create;
  FWndMethod := FForm.Form.WindowProc;
  FForm.Form.WindowProc := WndMethod;

  if FForm.Form is TFakeForm then
  begin
    FFormImages := TList<TImage>.Create;
    DoAddForm;
  end;
end;

destructor TDesignFormData.Destroy;
var
  LImage: TImage;
begin
  FForm.Form.WindowProc := FWndMethod; // ! important risky point :P
  if FFormImages <> nil then
  begin
    for LImage in FFormImages do
      LImage.Free;
    FreeAndNil(FFormImages);
  end;
  FLastScreenshot.Free;

  inherited Destroy;
  Pointer(FForm) := nil;
end;

{ TModulePageControl }

procedure TModulePageControl.SetDesignFormData(const AValue: TDesignFormData);
begin
  if (AValue = FDesignFormData) then
    // for show lfm code, if we want after editing lfm go back to form without any error
    // (when we restart IDE some error can be raised )
    if (FResizer=Nil)
    or ((AValue <> nil) and (FResizer.DesignedForm = AValue as IDesignedForm)) then
      Exit;

  FDesignFormData := AValue;
  if AValue = nil then
  begin
    //find
    if Assigned(FResizer) then
      FResizer.DesignedForm := nil;
  end
  else
  begin
    AValue.Form.LastActiveSourceWindow := Owner as TSourceEditorWindowInterface;
    if Assigned(FResizer) then
      FResizer.DesignedForm := AValue;
    BoundToDesignTabSheet;
  end;
end;

destructor TModulePageControl.Destroy;
begin
  DesignFormData := nil;
  inherited Destroy;
end;

procedure TModulePageControl.ShowDesignPage;
begin
  Pages[1].TabVisible := True;
end;

procedure TModulePageControl.HideDesignPage;
begin
  Pages[1].TabVisible := False;
end;

procedure TModulePageControl.BoundToDesignTabSheet;
begin
  if (ActivePageIndex <> 1) then
    Exit;
  if Assigned(FResizer) then
    FResizer.TryBoundSizerToDesignedForm(nil);
end;

{ TSourceEditorWindowData }

procedure TSourceEditorWindowData.SetActiveDesignFormData(
  const AValue: TDesignFormData);
var
  LPageCtrl: TModulePageControl;
begin
  if FActiveDesignFormData = AValue then
    Exit;
  if FActiveDesignFormData <> nil then
    // don't hide now if soon form will be hidden (for example on the IDE start)
    if not FActiveDesignFormData.FHiding then
      FActiveDesignFormData.FForm.HideWindow;
  FActiveDesignFormData := AValue;

  LPageCtrl := FindModulePageControl(FForm);
  if (AValue <> nil) then
  begin
    {with AValue as IDesignedForm do
    if not AValue.FHiding and (RealBorderStyle <> bsNone) then
    begin
      //BeginUpdate;
      //RealBorderIcons := [];
      //RealBorderStyle := bsNone;
      //Form.Show;
      //EndUpdate;
    end;}
    // important when we want back to tab where was oppened form :<
    LazarusIDE.DoShowDesignerFormOfSrc(FForm.ActiveEditor);
  end;

  // when is fired DestroyEditor - from this place we can't navigate to pagecontrol by FForm (we need to handle lastactiveeditor)
  if LPageCtrl = nil then
    Exit;
  LPageCtrl.DesignFormData := AValue;
  // for USE_POPUP_PARENT_DESIGNER to eliminate form over code  << maybe not needed any more since USE_POPUP_PARENT_DESIGNER isn't supported any more
  LPageCtrl.OnChange(LPageCtrl);
end;

constructor TSourceEditorWindowData.Create(AForm: TSourceEditorWindowInterface);
begin
  FForm := AForm;
  FPageCtrlList := TDictionary<TSourceEditorInterface, TModulePageControl>.Create;
end;

destructor TSourceEditorWindowData.Destroy;
begin
  FPageCtrlList.Free;
  inherited Destroy;
end;

procedure TSourceEditorWindowData.BoundToDesignTabSheet;
var
  LPageCtrl: TModulePageControl;
begin
  LPageCtrl := FindModulePageControl(FForm);
  if LPageCtrl <> nil then
    LPageCtrl.BoundToDesignTabSheet;
end;

procedure TSourceEditorWindowData.OnChangeBounds(Sender: TObject);
//var
//  LPageCtrl: TModulePageControl;
begin
//  LPageCtrl := FindModulePageControl(FForm);
//  if LPageCtrl <> nil then
//    LPageCtrl.BoundToDesignTabSheet;
end;

procedure TSourceEditorWindowData.AddPageCtrl(ASrcEditor: TSourceEditorInterface; APage: TModulePageControl);
begin
  FPageCtrlList.Add(ASrcEditor, APage);
  APage.Pages[1].OnChangeBounds:=OnChangeBounds;
end;

procedure TSourceEditorWindowData.RemovePageCtrl(ASrcEditor: TSourceEditorInterface);
begin
  FPageCtrlList.Remove(ASrcEditor);
end;

{ TDTXTabMaster }

function TDTXTabMaster.GetTabDisplayState: TTabDisplayState;
begin
  Result := GetTabDisplayStateEditor(SourceEditorManagerIntf.ActiveEditor);
end;

function TDTXTabMaster.GetTabDisplayStateEditor(Index: TSourceEditorInterface
  ): TTabDisplayState;
var
  LPageCtrl: TModulePageControl;
begin
  if Index = nil then
    Exit(tdsNone);
  LPageCtrl := FindModulePageControl(Index);
  if LPageCtrl = nil then
    Exit(tdsNone);
  case LPageCtrl.PageIndex of
    0: Exit(tdsCode);
    1: Exit(tdsDesign);
  else
    Exit(tdsOther);
  end;
end;

constructor TDTXTabMaster.Create;
begin
  FAutoSizeControlList := TObjectList.Create(False);
end;

destructor TDTXTabMaster.Destroy;
begin
  FAutoSizeControlList.Free;
  inherited Destroy;
end;

function TDTXTabMaster.AutoSizeInShowDesigner(AControl: TControl): Boolean;
begin
  FAutoSizeControlList.Add(AControl);
  Result := True;
end;

procedure TDTXTabMaster.EnableAutoSizing(AControl: TControl);
var
  AIndex: Integer;
  AutoSizeControl: TControl;
begin
  if not Assigned(AControl) then Exit;
  AutoSizeControl := nil;

  if AControl is TNonFormProxyDesignerForm then
  begin
    if (TNonFormProxyDesignerForm(AControl).LookupRoot is TControl) then
      AutoSizeControl := TControl(TNonFormProxyDesignerForm(AControl).LookupRoot);
  end
  else
    AutoSizeControl := AControl;

  AIndex := FAutoSizeControlList.IndexOf(AutoSizeControl);
  if (AIndex >= 0) then
  begin
    FAutoSizeControlList.Delete(AIndex);
    AutoSizeControl.EnableAutoSizing{$IFDEF DebugDisableAutoSizing}('TAnchorDockMaster Delayed'){$ENDIF};
  end;
end;

procedure TDTXTabMaster.ToggleFormUnit;
begin
  case TabDisplayState of
    tdsCode:
      ShowDesigner(SourceEditorManagerIntf.ActiveEditor);
    tdsDesign:
      ShowCode(SourceEditorManagerIntf.ActiveEditor);
  end;
end;

procedure TDTXTabMaster.JumpToCompilerMessage(
  ASourceEditor: TSourceEditorInterface);
begin
  SourceEditorManagerIntf.ActiveEditor := ASourceEditor;
  ShowCode(ASourceEditor);
end;

procedure TDTXTabMaster.ShowCode(ASourceEditor: TSourceEditorInterface);
begin
  if ASourceEditor = nil then
    Exit;
  FindModulePageControl(ASourceEditor).PageIndex := 0;
end;

procedure TDTXTabMaster.ShowDesigner(ASourceEditor: TSourceEditorInterface; AIndex: Integer);
var
  LPageCtrl: TModulePageControl;
begin
  if ASourceEditor = nil then
    Exit;
  LPageCtrl := FindModulePageControl(ASourceEditor);
  if not LPageCtrl.Pages[1].TabVisible then
    Exit;
  LPageCtrl.PageIndex := 1;
  LPageCtrl.OnChange(LPageCtrl);
end;

procedure TDTXTabMaster.ShowForm(AForm: TCustomForm);
var
  LEditor: TSourceEditorInterface;
begin
  LEditor := FindSourceEditorForDesigner(AForm.Designer);
  SourceEditorManagerIntf.ActiveEditor := LEditor;
  ShowDesigner(LEditor);
end;

{ TDTXComponentsMaster }

function TDTXComponentsMaster.DrawNonVisualComponents(ALookupRoot: TComponent): Boolean;
var
  LFormData: TDesignFormData;
  LPageCtrl: TModulePageControl;
begin
  Result := True;
  LFormData := FindDesignFormData(FormEditingHook.GetDesignerForm(ALookupRoot){ALookupRoot as TCustomForm});
  if LFormData = nil then
    Exit;
  LPageCtrl := FindModulePageControl(LFormData.Form.LastActiveSourceWindow);
  if (LPageCtrl = nil) or (LPageCtrl.Resizer = nil) or (LPageCtrl.Resizer.MainDTU = nil) then
    Exit;
  Result := LPageCtrl.Resizer.MainDTU.ShowNonVisualComponents;
end;

{ TSpartaMainIDE }

class procedure TSpartaMainIDE.Screen_FormAdded(Sender: TObject; Form: TCustomForm);
var
  LSourceEditor: TSourceEditorInterface;
  LFormData: TDesignFormData;
  //i: Integer;
  LPageCtrl: TModulePageControl;
begin
  if IsFormDesign(Form) then
  begin
    // Form like TForm1 etc...
    if (csDesignInstance in Form.ComponentState) or (Form is TNonFormProxyDesignerForm) then
    begin
      LFormData := TDesignFormData.Create(Form);
      LFormData.FHiding:=True;
      dsgnForms.Add(LFormData);
      LSourceEditor := FindSourceEditorForDesigner(Form.Designer);
      if LSourceEditor <> nil then
      begin
        LPageCtrl := FindModulePageControl(LSourceEditor);
        if LPageCtrl <> nil then
        begin
          LPageCtrl.ShowDesignPage;
          LPageCtrl.DesignFormData := LFormData;
        end;
      end;
      SetTimer(Form.Handle, WM_SETNOFRAME, 10, nil);
    end;
  end
  else
  begin
    // ONDREJ: the following code marged with (on-del) seems to help with nothing
    // but slows down loading forms and make them flicker.
    // I therefore commented it out. Please revert if there'll be regressions.
    {  // (on-del)
    if not BoundInitialized then
    begin
      for i := 0 to Screen.FormCount - 1 do
        if Screen.Forms[i] = Form then
          Continue
        else
        begin
          Screen.Forms[i].AddHandlerOnChangeBounds(GlobalOnChangeBounds);
        end;
      BoundInitialized := True;
    end;}

    if Form is TSourceEditorWindowInterface then
    begin
      Form.AddHandlerOnChangeBounds(GlobalSNOnChangeBounds);
      //Form.PopupMode := pmExplicit; // (on-del)
      normForms.Add(Form); // (on-del)
    end
    else
    begin
      //Form.AddHandlerOnChangeBounds(GlobalOnChangeBounds); // (on-del)
    end;
    //Forms.Add(Form); // (on-del)
  end;
end;

class procedure TSpartaMainIDE.TryFreeFormData(Form: TCustomForm);
var
  LSEWD: TSourceEditorWindowData;
  mpc: TModulePageControl;
  LFormData: TDesignFormData;
begin
  Form.Parent := nil;
  Application.ProcessMessages; // For TFrame - System Error. Code: 1400. Invalid window handle.

  LFormData := FindDesignFormData(Form);
  dsgnForms.Remove(LFormData);

  for LSEWD in SourceEditorWindows.Values do
  begin
    if LSEWD.ActiveDesignFormData <> nil then
      if LSEWD.ActiveDesignFormData.Form.Form = Form then
        LSEWD.FActiveDesignFormData := nil; // important - we can't call OnChange tab, because tab don't exist anymore

    for mpc in LSEWD.FPageCtrlList.Values do
      if mpc.DesignFormData <> nil then
         if mpc.DesignFormData.Form.Form = Form then
            mpc.DesignFormData := nil;
  end;
  LFormData.Free;
end;

class procedure TSpartaMainIDE.Screen_FormDel(Sender: TObject; Form: TCustomForm);
begin
  if not IsFormDesign(Form) then
  begin
    if Form is TSourceEditorWindowInterface then
      Form.RemoveHandlerOnChangeBounds(GlobalSNOnChangeBounds)
    else
      Form.RemoveHandlerOnChangeBounds(GlobalOnChangeBounds)
  end
  else
    TryFreeFormData(Form);
end;

class procedure TSpartaMainIDE.WindowCreate(Sender: TObject);
var
  LSourceEditorWindow: TSourceEditorWindowInterface;
begin
  if Sender.ClassNameIs('TSourceNotebook') then
  begin
    LSourceEditorWindow := Sender as TSourceEditorWindowInterface;
    SourceEditorWindows.Add(LSourceEditorWindow, TSourceEditorWindowData.Create(LSourceEditorWindow));
  end;
end;

class procedure TSpartaMainIDE.WindowDestroy(Sender: TObject);
var
  p: Pointer;
  f: TDesignFormData absolute p;
begin
  for p in dsgnForms do
    if f.FForm.LastActiveSourceWindow = Sender then
      f.FForm.LastActiveSourceWindow := nil;
  SourceEditorWindows.Remove(Sender as TSourceEditorWindowInterface);
  if LastActiveSourceEditorWindow = Sender then
    LastActiveSourceEditorWindow := nil;
end;

class procedure TSpartaMainIDE.WindowShow(Sender: TObject);
var
  LWindow: TSourceEditorWindowInterface;
  LWindowData: TSourceEditorWindowData;
  LDesignedForm: IDesignedForm;
begin
  LWindow := Sender as TSourceEditorWindowInterface;
  if not SourceEditorWindows.TryGetValue(LWindow, LWindowData) or
    (LWindowData.ActiveDesignFormData = nil)
  then
    Exit;
  LDesignedForm := LWindowData.ActiveDesignFormData as IDesignedForm;
  LDesignedForm.ShowWindow;
end;

class procedure TSpartaMainIDE.WindowHide(Sender: TObject);
var
  LWindow: TSourceEditorWindowInterface;
  LWindowData: TSourceEditorWindowData;
  LDesignedForm: IDesignedForm;
begin
  LWindow := Sender as TSourceEditorWindowInterface;
  if not SourceEditorWindows.TryGetValue(LWindow, LWindowData) or
    (LWindowData.ActiveDesignFormData = nil)
  then
    Exit;
  LDesignedForm := LWindowData.ActiveDesignFormData as IDesignedForm;
  LDesignedForm.HideWindow;
end;

class procedure TSpartaMainIDE.DesignerSetFocus;
var
  LResizer: TResizer;
begin
  LResizer := GetCurrentResizer;
  if LResizer<>nil then
    LResizer.ActiveResizeFrame.DesignerSetFocus;
end;

class procedure TSpartaMainIDE.EditorActivated(Sender: TObject);
var
  LDesigner: TIDesigner;
  LSourceEditor: TSourceEditorInterface;

  function LastSourceEditorNotFound: boolean;
  var
    i: Integer;
    se: TSourceEditorInterface;
    ASourceEditorWindowData: TSourceEditorWindowData;
  begin
    if (LastActiveSourceEditorWindow = nil) or (LastActiveSourceEditor = nil) then
      Exit(False);

    ASourceEditorWindowData := SourceEditorWindows[LastActiveSourceEditorWindow];
    for se in ASourceEditorWindowData.FPageCtrlList.Keys do
    begin
      Result := True;
      for i := 0 to LastActiveSourceEditorWindow.Count - 1 do
        if se = LastActiveSourceEditorWindow.Items[i] then
        begin
          Result := False;
          Break;
        end;
      if Result then
      begin
        LastActiveSourceEditor := se; // after moving code editor into other window, sometimes IDE switch to other tab :\ damn... this line prevent this.
        Exit;
      end;
    end;
    Result := False;
  end;

var
  LPageCtrl: TModulePageControl;
  LSourceEditorWindow: TSourceEditorWindowInterface;
  LDesignFormData: TDesignFormData;
begin
  if Sender is TSourceEditorInterface then
  begin
    LSourceEditor := TSourceEditorInterface(Sender);
    // if we create directly new project then Activate is called without EditorCreate...
    if not (LSourceEditor.EditorControl.Parent.Parent is TModulePageControl) then
    begin
      // possible is situation when we moved tab into other window
      // then was not called event EditorDestroy - that generates problems with switching tabs
      // or when we moving tab to first window ( then is raising : duplicates not allowed in dictionary).
      if LastSourceEditorNotFound then
        EditorDestroyed(nil);
      EditorCreate(Sender);
    end;
    LDesigner := LSourceEditor.GetDesigner(True);
    // should be performed during EditorCreate (parent of parent is module page ctrl)
    LPageCtrl := TModulePageControl(LSourceEditor.EditorControl.Parent.Parent);
    if LPageCtrl = nil then
      Exit;
    if LDesigner = nil then
      LPageCtrl.HideDesignPage
    else
    begin
      if LPageCtrl.Resizer = nil then
        LPageCtrl.FResizer := TResizer.Create(LPageCtrl.Pages[1], TResizerFrame);
      LPageCtrl.ShowDesignPage;
    end;

    LSourceEditorWindow := TSourceEditorWindowInterface(LPageCtrl.Owner);
    LastActiveSourceEditorWindow := LSourceEditorWindow;
    LastActiveSourceEditor := LSourceEditor;
    LDesignFormData := FindDesignFormData(LPageCtrl);
    // when we switch tab, design form should be hidden
    if (LDesigner = nil) or (LDesignFormData = nil) then
      SourceEditorWindows[LSourceEditorWindow].ActiveDesignFormData := nil
    else
    begin
      // during form  loading for example from package, ActiveDesignFormData assignment,
      // blocks the message queue responsible for hiding form
      // We can't check it because there are some forms where designing is not handled yet.
      // (for that kind of forms is returned empty designformdata)
      // maybe we can fix this in future
      if not LDesignFormData.FHiding then
        // Prevent unexpected events (when is deactivated some control outside designed form)
        if (LDesignFormData.Form.LastActiveSourceWindow = LSourceEditorWindow)
        // important!!! for many error - switching between editors...
        and (LPageCtrl.PageIndex = 1) then
          SourceEditorWindows[LSourceEditorWindow].ActiveDesignFormData := LDesignFormData
        else
          SourceEditorWindows[LSourceEditorWindow].ActiveDesignFormData := nil;
    end;

    case LPageCtrl.PageIndex of
      0: if LDesignFormData <> nil then LDesignFormData.Form.HideWindow;
      1:
        begin
          // Michl: I comment the next line, as it breaks other editors
          // (like Actionlist Editor). Imho in all cases all designer
          // were already active, so it isn't needed. See issue #33872
          // LazarusIDE.DoShowDesignerFormOfSrc(LSourceEditorWindow.ActiveEditor);

          // for lfm edition...
          with LDesignFormData as IDesignedForm do
          if not LDesignFormData.FHiding {and (RealBorderStyle <> bsNone)} then
          begin
              //BeginUpdate;
              //RealBorderIcons := [];
              //RealBorderStyle := bsNone;
              //Form.Show;
              //EndUpdate;
              LPageCtrl.BoundToDesignTabSheet;
              SetTimer(Form.Handle, WM_BOUNDTODESIGNTABSHEET, 10, nil);
          end;
        end;
    end;
  end
  else
    RefreshAllSourceWindowsModulePageControl;
end;

class procedure TSpartaMainIDE.EditorDestroyed(Sender: TObject);
var
  LSourceEditor: TSourceEditorInterface;
  LPageCtrl: TModulePageControl;
  LSourceEditorWindow: TSourceEditorWindowInterface;
  LSourceEditorWindowData: TSourceEditorWindowData;
  LFormData: TDesignFormData;
begin
  // sender is here as special parameter, because is possible situation where is moved editor
  // to another window and was not triggered EditorDestroy - for more info goto editoractivate
  if Sender = nil then
    LSourceEditor := LastActiveSourceEditor
  else
    LSourceEditor := TSourceEditorInterface(Sender);

  // parent don't exist anymore and we must search in each window...
  if Sender = nil then // but not for Sender = nil :P
  begin
    LSourceEditorWindowData := SourceEditorWindows[LastActiveSourceEditorWindow];
    LPageCtrl := LSourceEditorWindowData.FPageCtrlList[LastActiveSourceEditor]
  end else
    LPageCtrl := AbsoluteFindModulePageControl(LSourceEditor);

  if LPageCtrl = nil then
    Exit;

  LFormData := FindDesignFormData(LSourceEditor.GetDesigner(False));

  // goto first comment (forced destroy)
  if Sender = nil then
    LSourceEditorWindow := LastActiveSourceEditorWindow
  else
    LSourceEditorWindow := TSourceEditorWindowInterface(LPageCtrl.Owner);

  if LFormData <> nil then
  begin
    SourceEditorWindows[LSourceEditorWindow].ActiveDesignFormData := nil;
    LFormData.Form.LastActiveSourceWindow := nil;
  end;

  SourceEditorWindows[LSourceEditorWindow].RemovePageCtrl(LSourceEditor);
  LPageCtrl.Free;

  if LastActiveSourceEditor = LSourceEditor then
    LastActiveSourceEditor := nil;
end;

class function TSpartaMainIDE.GetCurrentResizer: TResizer;
var
  LForm: TCustomForm;
  LFormData: TDesignFormData;
  LSourceWindow: TSourceEditorWindowInterface;
  LPageCtrl: TModulePageControl;
begin
  Result := nil;
  if (FormEditingHook = nil) or (GlobalDesignHook = nil) then
    Exit;
  LForm := FormEditingHook.GetDesignerForm(GlobalDesignHook.LookupRoot);
  LFormData := FindDesignFormData(LForm);
  if LFormData=nil then Exit;
  LSourceWindow := (LFormData as IDesignedFormIDE).LastActiveSourceWindow;
  LPageCtrl := FindModulePageControl(LSourceWindow);
  Result := LPageCtrl.Resizer;
end;

class procedure TSpartaMainIDE.EditorCreate(Sender: TObject);

var
  LSourceEditor: TSourceEditorInterface;

  function CreateModulePageControl: TModulePageControl;
  var
    LNewTabSheet: TTabSheet;
    LSourceEditorWindow: TSourceEditorWindowInterface;
    LParent: TWinControl;
  begin
    Result := TModulePageControl.Create(LSourceEditor.EditorControl.Owner);
    Result.TabPosition := tpBottom;
    Result.Align:=alClient;
    LParent := LSourceEditor.EditorControl.Parent;

    LNewTabSheet := TTabSheet.Create(Result);
    LNewTabSheet.PageControl := Result;
    LNewTabSheet.Caption := SCode;
    LSourceEditor.EditorControl.Parent := LNewTabSheet;  // ! SynEdit :)

    LNewTabSheet := TTabSheet.Create(Result);
    LNewTabSheet.PageControl := Result;
    LNewTabSheet.Caption := SDesigner;

    Result.OnChange := TabChange;
    Result.Parent := LParent;
    LSourceEditorWindow := TSourceEditorWindowInterface(Result.Owner);
    SourceEditorWindows[LSourceEditorWindow].AddPageCtrl(LSourceEditor, Result)
  end;

begin
  LSourceEditor := Sender as TSourceEditorInterface;
  if not (LSourceEditor.EditorControl.Parent.Parent is TModulePageControl) then
    CreateModulePageControl;
end;

class procedure TSpartaMainIDE.TabChange(Sender: TObject);
var
  LActiveSourceWindow: TSourceEditorWindowInterface;
  w: TSourceEditorWindowInterface;
  p: TPair<TSourceEditorInterface, TModulePageControl>;
  LDesigner: TIDesigner;
  LFormData: TDesignFormData;
  LPageCtrl: TModulePageControl;
  LSourceWndData: TSourceEditorWindowData;
begin
  // activate proper source editor window when user is clicking on page.
  // (at clicking time can be active other source window)
  LActiveSourceWindow := TComponent(Sender).Owner as TSourceEditorWindowInterface;
  if LActiveSourceWindow <> SourceEditorManagerIntf.ActiveSourceWindow then
    SourceEditorManagerIntf.ActiveSourceWindow := LActiveSourceWindow;

  LPageCtrl := TModulePageControl(Sender);
  // in case there is no module and is visible page other than code page.
  if (LActiveSourceWindow.ActiveEditor <> nil) and (LPageCtrl <> nil) then
  begin
    LDesigner := LActiveSourceWindow.ActiveEditor.GetDesigner(True);
    LFormData := FindDesignFormData(LDesigner);
    if (LFormData <> nil)
    and SourceEditorWindows.TryGetValue(LActiveSourceWindow, LSourceWndData) then
    begin
      case LPageCtrl.ActivePageIndex of
        0: LSourceWndData.ActiveDesignFormData := nil;
        1: begin            //  deactivate design tab in other page control :)
            for w in SourceEditorWindows.Keys do
              if w = LActiveSourceWindow then
                Continue
              else
                for p in SourceEditorWindows[w].FPageCtrlList do
                  if (p.Value.DesignFormData = LFormData) and (p.Value <> Sender) then
                    IDETabMaster.ShowCode(p.Key);
            LSourceWndData.ActiveDesignFormData := LFormData;
            // enable autosizing after creating a new form
            TDTXTabMaster(IDETabMaster).EnableAutoSizing(LFormData.Form.Form);
            // to handle windows with different size
            LPageCtrl.BoundToDesignTabSheet;
          end;
      end;
    end;
  end;
end;

class procedure TSpartaMainIDE.GlobalOnChangeBounds(Sender: TObject);
var
  sewd: TSourceEditorWindowData;
begin
  for sewd in SourceEditorWindows.Values do
    sewd.OnChangeBounds(Sender);
end;

class procedure TSpartaMainIDE.GlobalSNOnChangeBounds(Sender: TObject);
var
  LWindow: TSourceEditorWindowInterface;
  LWindowData: TSourceEditorWindowData;
  LDesignForm: TDesignFormData;
begin
  // Check parent. Maybe is different? If yes then window changed state (docked/undocked) and we need to perform few actions
  LWindow := Sender as TSourceEditorWindowInterface;

  // dock/undock event :)
  if not SourceEditorWindows.TryGetValue(LWindow, LWindowData) then
    Exit;
  if LWindowData.FLastTopParent <> LWindow.GetTopParent then
  begin
    LWindowData.FLastTopParent := LWindow.GetTopParent;
    // refresh for popupparent
    LDesignForm := LWindowData.ActiveDesignFormData;
    LWindowData.ActiveDesignFormData := nil;
    LWindowData.ActiveDesignFormData := LDesignForm;
    if LDesignForm <> nil then
    begin
      LDesignForm.Form.Form.Parent := FindModulePageControl(LWindow).Resizer.ActiveResizeFrame.FormHandler;
      SetTimer(LDesignForm.Form.Form.Handle, WM_BOUNDTODESIGNTABSHEET, 10, nil);
    end;
  end;

  LWindowData.OnChangeBounds(Sender);
end;

class procedure TSpartaMainIDE.OnDesignMouseDown(Sender: TObject;
  Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
  DesignerSetFocus;
end;

class procedure TSpartaMainIDE.OnModifiedSender(Sender: TObject);
begin
  OnModified(Nil);
end;

class procedure TSpartaMainIDE.OnModified(APersistent: TPersistent);
var
  LResizer: TResizer;
begin
  LResizer := GetCurrentResizer;
  if LResizer<>nil then
    LResizer.ActiveResizeFrame.OnModified;
end;

class procedure TSpartaMainIDE.OnModifiedPersistentAdded(
  APersistent: TPersistent; Select: Boolean);
begin
  OnModified(Nil);
end;

class procedure TSpartaMainIDE.OnShowDesignerForm(Sender: TObject; AEditor: TSourceEditorInterface;
                                 AComponentPaletteClassSelected: Boolean);
var
  LForm: TDesignFormData;
  LPageCtrl, p: TModulePageControl;
  w: TSourceEditorWindowInterface;
  e: TSourceEditorInterface;
begin
  LForm := FindDesignFormData(TCustomForm(Sender).Designer);
  if (LForm = nil) or LForm.FHiding then
    Exit;
  LPageCtrl := FindModulePageControl(SourceEditorManagerIntf.ActiveEditor);
  if LPageCtrl = nil then
    Exit; // it should not happen but who knows :P Lazarus IDE is sometimes mischievous

  if AComponentPaletteClassSelected then
  begin
    // if form is already opened do nothing, if not then show form for active module.
    for w in SourceEditorWindows.Keys do
    begin
      e := w.ActiveEditor;
      if (e = nil) or (e.GetDesigner(True) <> LForm.Form.Form.Designer) then
        Continue;
      p := FindModulePageControl(e);
      if p.PageIndex = 1 then
        Exit;
    end;
  end;
  IDETabMaster.ShowDesigner(SourceEditorManagerIntf.ActiveEditor);
end;

class procedure TSpartaMainIDE.OnShowSrcEditor(Sender: TObject);
begin
  IDETabMaster.ShowCode(Sender as TSourceEditorInterface);
end;

class procedure TSpartaMainIDE.OnShowMethod(const Name: String);
var
  LForm: TDesignFormData;
  LSecondEditor: TSourceEditorInterface = nil;
  i: Integer;
  LSourceWindow: TSourceEditorWindowInterface;
begin
  if FormEditingHook = nil then
    Exit;
  LForm := FindDesignFormData(FormEditingHook.GetCurrentDesigner);
  if LForm = nil then
    Exit;
  for i := 0 to SourceEditorManagerIntf.SourceWindowCount - 1 do
  begin
    LSourceWindow := SourceEditorManagerIntf.SourceWindows[i];
    if LForm.Form.LastActiveSourceWindow = LSourceWindow then
      Continue;
    if LSourceWindow.ActiveEditor <> nil then
      if LSourceWindow.ActiveEditor.GetDesigner(True) = LForm.Form.Form.Designer then
      begin
        LSecondEditor := LSourceWindow.ActiveEditor;
        Break;
      end;
  end;

  if Assigned(LSecondEditor) then
  begin
    IDETabMaster.ShowCode(LSecondEditor);
    LazarusIDE.DoShowMethod(LSecondEditor, Name);
  end
  else
    if Assigned(LForm.Form.LastActiveSourceWindow) then
      IDETabMaster.ShowCode(LForm.Form.LastActiveSourceWindow.ActiveEditor);
end;

class procedure TSpartaMainIDE.OnDesignRefreshPropertyValues;
var
  LForm: TCustomForm;
  LSourceWindow: TSourceEditorWindowInterface;
  LFormData: TDesignFormData;
  LPageCtrl: TModulePageControl;

  function RootIsSelected: Boolean;
  var
    LSelection: TPersistentSelectionList;
    i: integer;
  begin
    Result := False;
    LSelection := TPersistentSelectionList.Create;
    GlobalDesignHook.GetSelection(LSelection);
    for i := 0 to LSelection.Count - 1 do
      if LSelection.Items[i] = GlobalDesignHook.LookupRoot then
      begin
        Result := True;
        Break;
      end;
    LSelection.Free;
  end;

begin
  if (GlobalDesignHook.LookupRoot is TCustomFrame) then
  begin
    if not RootIsSelected then
      Exit;
    LForm := FormEditingHook.GetDesignerForm(GlobalDesignHook.LookupRoot);
    LFormData := FindDesignFormData(LForm);
    LSourceWindow := (LFormData as IDesignedFormIDE).LastActiveSourceWindow;
    LPageCtrl := FindModulePageControl(LSourceWindow);
    TFakeFrame(LForm).SetBounds(LForm.Left-1,LForm.Top-1,TFakeFrame(LForm).Width,TFakeFrame(LForm).Height);
    //LPageCtrl.BoundToDesignTabSheet;
  end
  else
  if (GlobalDesignHook.LookupRoot is TCustomForm) then
  begin
    if not RootIsSelected then
      Exit;
    LForm := TCustomForm(GlobalDesignHook.LookupRoot);
    LFormData := FindDesignFormData(LForm);
    LSourceWindow := (LFormData as IDesignedFormIDE).LastActiveSourceWindow;
    LPageCtrl := FindModulePageControl(LSourceWindow);
    LPageCtrl.BoundToDesignTabSheet;
  end;
end;

initialization
  dsgnForms := Classes.TList.Create;
  SourceEditorWindows := TObjectDictionary<TSourceEditorWindowInterface, TSourceEditorWindowData>.Create([doOwnsValues]);
  normForms := Classes.TList.Create;

finalization
  normForms.Free;
  SourceEditorWindows.Free;
  FreeAndNil(dsgnForms);
end.

