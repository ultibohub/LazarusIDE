{
 /***************************************************************************
                    CarbonInt.pas  -  CarbonInterface Object
                    ----------------------------------------

                 Initial Revision  : Mon August 6th CST 2004


 ***************************************************************************/

 *****************************************************************************
  This file is part of the Lazarus Component Library (LCL)

  See the file COPYING.modifiedLGPL.txt, included in this distribution,
  for details about the license.
 *****************************************************************************
 }

unit CarbonInt;

{$mode objfpc}{$H+}

interface

{$ifdef Trace}
{$ASSERTIONS ON}
{$endif}

// defines
{$I carbondefines.inc}

uses
  // rtl+ftl
  Types, Classes, SysUtils, Math,
  // carbon bindings
  MacOSAll,
  // Cocoa bindings
  {$ifdef CarbonUseCocoa}
    foundation, appkit,
  {$endif}
  // interfacebase
  InterfaceBase,
  // widgetset
  CarbonGDIObjects,
  {$ifdef DebugBitmaps}
    CarbonDebug,
  {$endif}
  glgrab,
  LCLPlatformDef, LMessages, LCLMessageGlue, LCLProc, LCLIntf, LCLType, IntfGraphics,
  GraphType, GraphMath, Graphics, Controls, Forms, Dialogs, Menus, Maps, Themes;

type

  { TCarbonWidgetSet }

  TCarbonWidgetSet = class(TWidgetSet)
  private
    // Set when the QuitEventHandler terminates
    FTerminating: Boolean;
    FUserTerm: Boolean;
    FMainEventQueue: EventQueueRef;
    FTimerMap: TMap; // the map contains all installed timers
    FCurrentCursor: HCURSOR;
    FMainMenu: HMENU; // Main menu attached to menu bar
    FCaptureWidget: HWND; // Captured widget (TCarbonWidget descendant)
    FFocusedWidget: HWND; // Forced Focus widgetset (TCarbonWidget descendant)
    FOpenEventHandlerUPP: AEEventHandlerUPP;
    FQuitEventHandlerUPP: AEEventHandlerUPP;

    FAppLoop: TApplicationMainLoop;
    FAppStdEvents: Boolean;
    fMenuEnabled: Boolean;
    FAEventHandlerRef: array[0..5] of EventHandlerRef;
    {$ifdef CarbonUseCocoa}
      pool: NSAutoreleasePool;
    {$endif}
  protected
    function CreateThemeServices: TThemeServices; override;
    procedure PassCmdLineOptions; override;
    procedure SendCheckSynchronizeMessage;
    procedure OnWakeMainThread(Sender: TObject);

    procedure RegisterEvents;

  public
    constructor Create; override;
    destructor Destroy; override;

    function LCLPlatform: TLCLPlatform; override;

    procedure AppInit(var ScreenInfo: TScreenInfo); override;
    procedure AppRun(const ALoop: TApplicationMainLoop); override;
    procedure AppWaitMessage; override;
    procedure AppProcessMessages; override;
    procedure AppTerminate; override;
    procedure AppMinimize; override;
    procedure AppRestore; override;
    procedure AppBringToFront; override;
    procedure AppSetIcon(const {%H-}Small, Big: HICON); override;
    procedure AppSetTitle(const {%H-}ATitle: string); override;

    function  GetLCLCapability(ACapability: TLCLCapability): PtrUInt; override;
    
    function  DCGetPixel(CanvasHandle: HDC; X, Y: integer): TGraphicsColor; override;
    procedure DCSetPixel(CanvasHandle: HDC; X, Y: integer; AColor: TGraphicsColor); override;
    procedure DCRedraw(CanvasHandle: HDC); override;
    procedure DCSetAntialiasing(CanvasHandle: HDC; AEnabled: Boolean); override;

    procedure SetDesigning({%H-}AComponent: TComponent); override;

    function  IsHelpKey({%H-}Key: Word; {%H-}Shift: TShiftState): Boolean; override;

    // create and destroy
    function CreateTimer(Interval: integer; TimerFunc: TWSTimerProc) : TLCLHandle; override;
    function DestroyTimer(TimerHandle: TLCLHandle) : boolean; override;
    function PrepareUserEvent(Handle: HWND; Msg: Cardinal; wParam: WParam;
      lParam: LParam; out Target: EventTargetRef): EventRef;

    function RawImage_DescriptionFromCarbonBitmap(out ADesc: TRawImageDescription; ABitmap: TCarbonBitmap): Boolean;
    function RawImage_FromCarbonBitmap(out ARawImage: TRawImage; ABitmap, AMask: TCarbonBitmap; ARect: PRect = nil): Boolean;
    function RawImage_DescriptionToBitmapType(ADesc: TRawImageDescription; out bmpType: TCarbonBitmapType): Boolean;
    function GetImagePixelData(AImage: CGImageRef; out bitmapByteCount: PtrUInt): Pointer;

    // the winapi compatibility methods
    {$I carbonwinapih.inc}
    // the extra LCL interface methods
    {$I carbonlclintfh.inc}

  public
    procedure SetMainMenuEnabled(AEnabled: Boolean);
    procedure SetRootMenu(const AMenu: HMENU);
    property MainMenu: HMENU read FMainMenu;
    property MenuEnabled: Boolean read fMenuEnabled;
  public
    procedure SetCaptureWidget(const AWidget: HWND);
    procedure SetTextFractional(ACanvas: TCanvas; AEnabled: Boolean);
    procedure SetFocusedWidget(const AWidget: HWND);
    function GetFocusedWidget: HWND;
    property CaptureWidgetSet: HWND read FCaptureWidget;
  end;
  
const
  // missing constant
  kAEOpenContents = $6F636F6E (* 'ocon' *);

var
  CarbonWidgetSet: TCarbonWidgetSet;

function Create32BitAlphaBitmap(ABitmap, AMask: TCarbonBitmap): TCarbonBitmap;

implementation

uses
  {%H-}CarbonWSFactory,
  { these can/should go up }
  CarbonDef, CarbonPrivate, CarbonMenus, {%H-}CarbonButtons, {%H-}CarbonBars, {%H-}CarbonEdits,
  CarbonListViews, {%H-}CarbonTabs,
  CarbonThemes, CarbonCanvas, {%H-}CarbonStrings, CarbonClipboard, CarbonCaret,
  CarbonProc, CarbonDbgConsts, CarbonUtils,
  
  Buttons, ExtCtrls, LResources;

var
  FirstAppEventLock: MPEventID = nil;

const
  EventFlags : MPEventFlags = 1;

procedure SignalFirstAppEvent;
begin
  MPSetEvent(FirstAppEventLock, EventFlags);
end;

procedure WaitFirstAppEvent;
var
  fl  : MPEventFlags;
begin
  fl := EventFlags;
  if FirstAppEventLock <> nil then
  begin
    MPWaitForEvent(FirstAppEventLock, @fl, kDurationForever);
    SignalFirstAppEvent;
  end;
end;

// the implementation of the utility methods
{$I carbonobject.inc}
// the implementation of the winapi compatibility methods
{$I carbonwinapi.inc}
// the implementation of the extra LCL interface methods
{$I carbonlclintf.inc}


procedure InternalInit;
begin
  MPCreateEvent(FirstAppEventLock);
end;

procedure InternalFinal;
begin
  if Assigned(FirstAppEventLock) then
  begin
    SignalFirstAppEvent;
    MPDeleteEvent(FirstAppEventLock);
    FirstAppEventLock:=nil;
  end;
end;


initialization
  InternalInit;

finalization
  InternalFinal;

end.
