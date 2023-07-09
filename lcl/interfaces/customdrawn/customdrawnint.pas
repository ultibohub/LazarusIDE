{
 /***************************************************************************
                CustomDrawnInt.pas -  CustomDrawn Interface Object
                             -------------------

 ***************************************************************************/

 *****************************************************************************
  This file is part of the Lazarus Component Library (LCL)

  See the file COPYING.modifiedLGPL.txt, included in this distribution,
  for details about the license.
 *****************************************************************************
}

unit CustomDrawnInt;

{$mode objfpc}{$H+}

{$I customdrawndefines.inc}

interface

uses
  // RTL
  // for CD_Cocoa Types needs to be after the platform-specif units or else Mac
  // will catch MacOSAll.Rect/Size/Point
  {$ifndef CD_Cocoa}Types,{$endif}Classes, SysUtils, Math,
  fpimage, fpcanvas, fpimgcanv, ctypes, dateutils,
  // XML
  XMLRead, Dom,
  // Platform specific
  {$ifdef CD_Windows}Windows, customdrawn_WinProc, customdrawn_winextra,{$endif}
  {$ifdef CD_Cocoa}MacOSAll, CocoaAll, customdrawn_cocoaproc, CocoaGDIObjects,Types,{$endif}
  {$ifdef CD_X11}X, XLib, XUtil, BaseUnix, customdrawn_x11proc,{$ifdef CD_UseNativeText}xft, fontconfig,{$endif}{$endif}
  {$ifdef CD_Android}
  customdrawn_androidproc, jni, bitmap, log, keycodes,
  {$endif}
  {$ifdef WinCE}aygshell,{$endif}
  // LazUtils
  LazFileUtils, lazutf8,
  {$ifndef CD_UseNativeText}
  // LazFreeType
  LazFreeTypeIntfDrawer, LazFreeType, EasyLazFreeType, IniFiles,
  {$endif}
  // Widgetset
  customdrawnproc, customdrawnthemes,
  // LCL
  customdrawn_common, customdrawncontrols, customdrawndrawers,
  lazcanvas, lazregions, lazdeviceapis,
  LCLPlatformDef, InterfaceBase, Themes, Dialogs, Buttons,
  Controls,  Forms, lclproc, IntfGraphics, GraphType,
  LCLType, LMessages, Graphics, LCLStrConsts, Menus, LazLoggerBase;

type
  {$ifdef CD_Windows}
  TWinCETitlePolicy = (tpAlwaysUseOKButton, tpOKButtonOnlyOnDialogs, tpControlWithBorderIcons);

  PPPipeEventInfo = ^PPipeEventInfo;
  PPipeEventInfo = ^TPipeEventInfo;
  TPipeEventInfo = record
    Handle: THandle;
    UserData: PtrInt;
    OnEvent: TPipeEvent;
    Prev: PPipeEventInfo;
    Next: PPipeEventInfo;
  end;

  TWaitHandler = record
    ListIndex: pdword;
    UserData: PtrInt;
    OnEvent: TWaitHandleEvent;
  end;

  TSocketEvent = function(ASocket: THandle; Flags: dword): Integer of object;
  {$endif}
  {$ifdef CD_Cocoa}

  TCDTimerObject=objcclass(NSObject)
    func : TWSTimerProc;
    procedure timerEvent; message 'timerEvent';
    class function initWithFunc(afunc: TWSTimerProc): TCDTimerObject; message 'initWithFunc:';
  end;

  TCDAppDelegate = objcclass(NSObject, NSApplicationDelegateProtocol)
    function applicationShouldTerminate(sender: NSApplication): NSApplicationTerminateReply; message 'applicationShouldTerminate:';
  end;
  {$endif}
  {$ifdef CD_X11}
  // Just in case...
  {$endif}

  // Return true to disable the form background drawing
  TDisableFormBackgroundDrawingProc = function (AForm: TCustomForm): Boolean of object;

  { TLazCDCustomFont }

  TLazCDCustomFont = class(TFPCustomFont)
  public
    {$ifndef CD_UseNativeText}
    FTFont: TFreeTypeFont;
    {$endif}
    constructor Create; override;
    destructor Destroy; override;
  end;

  { TCDWidgetSet }

  TCDWidgetSet = class(TWidgetSet)
  private
    FTerminating: Boolean;

    // Clipboard support
    FClipBoardFormats: TStringList;

    {$ifdef CD_WINDOWS}
    // In win32 it is: The parent of all windows, represents the button of the taskbar
    // In wince it is just an invisible window, but retains the following functions:
    // * This window is also the owner of the clipboard.
    // * Assoc. windowproc also acts as handler for popup menus
    // * It is indispensable for popupmenus and thread synchronization
    FAppHandle: THandle;

    FMetrics: TNonClientMetrics;
    FMetricsFailed: Boolean;

    FStatusFont: HFONT;
    FMessageFont: HFONT;

    FWaitHandleCount: dword;
    FWaitHandles: array of HANDLE;
    FWaitHandlers: array of TWaitHandler;
    FWaitPipeHandlers: PPipeEventInfo;

    FOnAsyncSocketMsg: TSocketEvent;

    function WinRegister: Boolean;
    procedure CreateAppHandle;
    {$endif}
  public
    {$ifdef CD_X11}
    FDisplayName: string;
    FDisplay: PDisplay;
    FScreen: longint;
    FVisual: TVisual; // Visual from X11

    LeaderWindow: X.TWindow;
    ClientLeaderAtom: TAtom;

    FWMProtocols: TAtom;	  // Atom for "WM_PROTOCOLS"
    FWMDeleteWindow: TAtom;	  // Atom for "WM_DELETE_WINDOW"
    FWMHints: TAtom;		  // Atom for "_MOTIF_WM_HINTS"
    FWMPaint: TAtom;		  // Atom for "WM_PAINT"

    // For composing character events
    ComposeBuffer: string;
    ComposeStatus: TStatus;
    InputMethod: xlib.PXIM;
    InputContext: PXIC;
    LastKeySym: TKeySym; // Used for KeyRelease event
    LastKey: Word;       // Used for KeyRelease event

    ShiftState: TShiftState; // Keeps ShiftState from X

    // XConnections list
    XConnections: TFPList;
    // Windows Info List
    XWindowList: TStringList;
    // Timer queue head
    {$ifdef CD_X11_UseNewTimer}
    XTimerListHead: customdrawn_x11proc.TCDX11Timer;
    {$endif}

    // Functions to keep track of windows needing repaint
    function CheckInvalidateWindowForX(XWIndowID: X.TWindow): Boolean;
    procedure WindowUpdated(XWIndowID: X.TWindow);

    function FindWindowByXID(XWindowID: X.TWindow; out AWindowInfo: TX11WindowInfo): TWinControl;
    procedure AppProcessMessage;
    procedure AppProcessInvalidates;
    function XStateToLCLState(XKeyState: cuint): TShiftState;
    {$endif}
    {$ifdef CD_Android}
    CombiningAccent: Cardinal;
    procedure AndroidDebugLn(ASender: TObject; AStr: string; var AHandled: Boolean;
      Target: TLazLoggerWriteTarget; Data: Pointer);
    function AndroidKeyCodeToLCLKeyCode(AAndroidKeyCode: Integer): Word;
    function DoOpenURLWidgetsetImplementation(AURL: string): Boolean;
    function DoOpenDocumentWidgetsetImplementation(APath: string): Boolean;
    function DoOpenAndroidURI(AURI: JObject; AMimeType: string): Boolean;
    function GetMimeTypeFromFileName(AFileName: string): string;
    procedure ShowListViewDialog(ATitle: string; ATitles,
      ADescriptions: array of string;
      AColorOddRow: jint = $ff292C29; AColorEvenRow: jint = $ff424542);
    {$endif}
    {$ifdef CD_Cocoa}
    pool      : NSAutoreleasePool;
    NSApp     : NSApplication;
    delegate  : TCDAppDelegate;
    ScreenBitmapContext: CGContextRef;
    {$endif}
  // For generic methods added in customdrawn
  // They are used internally in LCL-CustomDrawn, LCL app should not use them
  public
    {$ifndef CD_UseNativeText}
    // Font Path List
    FFontPaths: TstringList;
    FFontList: THashedStringList;
    // default fonts availability
    LiberationFont: Boolean;
    LuxiFont: Boolean;
    {$endif}
    // Stock objects
    FStockBlackBrush: TFPCustomBrush;
    FStockDKGrayBrush: TFPCustomBrush;
    FStockGrayBrush: TFPCustomBrush;
    FStockLtGrayBrush: TFPCustomBrush;
    FStockNullBrush: TFPCustomBrush;
    FStockWhiteBrush: TFPCustomBrush;

    FStockBlackPen: TFPCustomPen;
    FStockNullPen: TFPCustomPen;
    FStockWhitePen: TFPCustomPen;

    DefaultFontSize: Integer;
    FDefaultGUIFont: TFPCustomFont;
    //
    AccumulatedStr: string;
    // The currently focused control
    FocusedControl: TWinControl;
    FocusedIntfControl: TWinControl;
    // Default Fonts
    DefaultFont: TFPCustomFont;
    DefaultFontAndroidSize: Integer;
    // Mobile emulator and mobile mode
    MobileMainForm: TLCLHandle;
    // For unusual implementations of DebugLn/DebugOut
    procedure AccumulatingDebugOut(ASender: TObject; AStr: string; var AHandled: Boolean;
      Target: TLazLoggerWriteTarget; Data: Pointer);
    //
    procedure CDSetFocusToControl(ALCLControl, AIntfControl: TWinControl);
  //
  protected
    function CreateThemeServices: TThemeServices; override;
    function GetAppHandle: TLCLHandle; override; //BackendSpecific
    //procedure SetAppHandle(const AValue: TLCLHandle); override;
    //
    procedure BackendCreate;
    procedure BackendDestroy;
    //
    procedure GenericAppInit;
  public
    // ScreenDC and Image for doing Canvas operations outside the Paint event
    // and also for text drawing operations
    ScreenDC: TLazCanvas;
    ScreenBitmapRawImage: TRawImage;
    ScreenBitmapHeight: Integer;
    ScreenBitmapWidth: Integer;
    ScreenImage: TLazIntfImage;
    ScreenFormat: TLazCanvasImageFormat;

    // Android Activity callbacks
    ActivityOnCreate: TProcedure;
    ActivityClassName: string;

    constructor Create; override;
    destructor Destroy; override;

    function LCLPlatform: TLCLPlatform; override;
    function GetLCLCapability(ACapability: TLCLCapability): PtrUInt; override;

    { Initialize the API }
    procedure AppInit(var ScreenInfo: TScreenInfo); override;
    procedure AppRun(const ALoop: TApplicationMainLoop); override;
    procedure AppWaitMessage; override;
    procedure AppProcessMessages; override;
    procedure AppTerminate; override;
    procedure AppMinimize; override;
    procedure AppRestore; override;
    procedure AppBringToFront; override;
    procedure AppSetIcon(const Small, Big: HICON); override;
    procedure AppSetTitle(const ATitle: string); override;
    procedure AppSetVisible(const AVisible: Boolean); override;
    function AppRemoveStayOnTopFlags(const ASystemTopAlso: Boolean = False): Boolean; override;
    function AppRestoreStayOnTopFlags(const ASystemTopAlso: Boolean = False): Boolean; override;
    procedure AppSetMainFormOnTaskBar(const DoSet: Boolean); override;

    //function  InitStockFont(AFont: TObject; AStockFont: TStockFont): Boolean; override;

    procedure DCSetPixel(CanvasHandle: HDC; X, Y: integer; AColor: TGraphicsColor); override;
    function  DCGetPixel(CanvasHandle: HDC; X, Y: integer): TGraphicsColor; override;
    procedure DCRedraw(CanvasHandle: HDC); override;
    procedure DCSetAntialiasing(CanvasHandle: HDC; AEnabled: Boolean); override;
    procedure SetDesigning(AComponent: TComponent); override;

    // create and destroy
    function CreateTimer(Interval: integer; TimerFunc: TWSTimerProc): TLCLHandle; override;
    function DestroyTimer(TimerHandle: TLCLHandle): boolean; override;

    {$I customdrawnwinapih.inc}
    {$I customdrawnlclintfh.inc}
  public
    { Variables to be set by the user }
    {$ifdef WinCE}
    WinCETitlePolicy: TWinCETitlePolicy;
    {$endif}

    // This callback might be set to provide a routine which will select for
    // which forms the drawing of the background should be disabled
    // This is provided for speeding up the drawing
    //
    // Only use it if you are 100% sure that you are filling the entire buffer
    // in the form paint event. Note that the form might sometimes be smaller
    // then the buffer in Android so fill the entire Canvas area, not only the form size
    DisableFormBackgroundDrawingProc: TDisableFormBackgroundDrawingProc;
  end;

var
  CDWidgetSet: TCDWidgetSet absolute WidgetSet;

function CDMessageBoxFunction(Text, Caption : PChar; Flags : Longint) : Integer;

{$ifdef CD_WINDOWS}
function WindowProc(Window: HWnd; Msg: UInt; WParam: Windows.WParam;
  LParam: Windows.LParam): LResult; {$ifdef WinCE}cdecl;{$else}stdcall;{$endif}
{$endif}
{$ifdef CD_X11}
procedure MyXConnectionWatchProc(display: PDisplay; client_data: TXPointer;
  fd: cint; opening: XLib.TBool; watch_data: PXPointer); cdecl;
{$endif}
{$ifdef CD_Android}
function Java_com_pascal_lclproject_LCLActivity_LCLOnTouch(env:PJNIEnv;this:jobject; x, y: single; action: jint): jint; cdecl;
function Java_com_pascal_lclproject_LCLActivity_LCLDrawToBitmap(
    env:PJNIEnv;this:jobject; width, height: jint; abitmap: jobject): jint; cdecl;
function Java_com_pascal_lclproject_LCLActivity_LCLOnCreate(
    env:PJNIEnv; this:jobject; alclactivity: jobject): jint; cdecl;
function Java_com_pascal_lclproject_LCLActivity_LCLOnMessageBoxFinished(
    env:PJNIEnv; this:jobject; AResult, ADialogType: jint): jint; cdecl;
function Java_com_pascal_lclproject_LCLActivity_LCLOnKey(
    env:PJNIEnv; this:jobject; AKind: jint; AKeyCode: jint;
    AEvent: jobject; AChar: jint): jint; cdecl;
function Java_com_pascal_lclproject_LCLActivity_LCLOnTimer(
    env:PJNIEnv; this:jobject; ATimer: jobject; ATimerIDIndex: jint): jint; cdecl;
function Java_com_pascal_lclproject_LCLActivity_LCLOnConfigurationChanged(
    env:PJNIEnv; this:jobject; ANewDPI, ANewWidth: jint): jint; cdecl;
function Java_com_pascal_lclproject_LCLActivity_LCLOnSensorChanged(
    env:PJNIEnv; this:jobject; ASensorKind: jint; AValues: JDoubleArray): jint; cdecl;
function Java_com_pascal_lclproject_LCLActivity_LCLOnMenuAction(
  env:PJNIEnv; this:jobject; kind, itemIndex: jint): jint; cdecl;
function JNI_OnLoad(vm:PJavaVM;reserved:pointer):jint; cdecl;
procedure JNI_OnUnload(vm:PJavaVM;reserved:pointer); cdecl;

var
  javaVMRef: PJavaVM=nil;
  javaEnvRef: PJNIEnv=nil;
  javaActivityClass: JClass = nil;
  javaActivityObject: jobject = nil;

  // The SDK Version
  android_os_Build_VERSION_SDK_INT: jint;

  // Other classes and objects
  javaAndroidAppActivityClass: JClass = nil;
  javaJavaLangSystemClass: JClass = nil;
  javaAndroidOSBuildClass: JClass = nil;
  javaAndroidOSVibratorClass: JClass = nil;
  javaAndroidContentContextClass: JClass = nil;
  javaJavaLangStringClass: JClass = nil;
  javaAndroidOSBuildVERSIONClass: JClass = nil;

  // Other fields
  javaField_VERSION_SDK_INT: JFieldID = nil;
  // Fields of our Activity
  // Strings
  javaField_lcltext: JfieldID=nil;
  javaField_lcltitle: JfieldID=nil;
  javaField_lclbutton1str: JfieldID=nil;
  javaField_lclbutton2str: JfieldID=nil;
  javaField_lclbutton3str: JfieldID=nil;
  // Integers
  javaField_lclwidth: JfieldID=nil;
  javaField_lclheight: JfieldID=nil;
  javaField_lclbutton1: JfieldID=nil;
  javaField_lclbutton2: JfieldID=nil;
  javaField_lclbutton3: JfieldID=nil;
  javaField_lclbitmap: JfieldID=nil;
  javaField_lcltextsize: JfieldID=nil;
  // Text metrics
  javaField_lcltextascent: JfieldID=nil;
  javaField_lcltextbottom: JfieldID=nil;
  javaField_lcltextdescent: JfieldID=nil;
  javaField_lcltextleading: JfieldID=nil;
  javaField_lcltexttop: JfieldID=nil;
  javaField_lclmaxwidth: JfieldID=nil;
  javaField_lclmaxcount: JfieldID=nil;
  javaField_lclpartialwidths: JfieldID=nil;
  // Timer
  javaField_lcltimerinterval: JfieldID=nil;
  javaField_lcltimerid: JfieldID=nil;
  // Screen Metrics
  javaField_lclxdpi: JfieldID=nil;
  javaField_lclydpi: JfieldID=nil;
  javaField_lclformwidth: JfieldID=nil;
  javaField_lclformheight: JfieldID=nil;
  javaField_lclscreenwidth: JfieldID=nil;
  javaField_lclscreenheight: JfieldID=nil;
  // For LazDeviceAPIs
  javaField_lcldestination: JfieldID=nil;
  javaField_lclkind: JfieldID=nil;

  // Methods of our Activity
  javaMethod_LCLDoGetTextBounds: jmethodid = nil;
  javaMethod_LCLDoGetTextPartialWidths: jmethodid = nil;
  javaMethod_LCLDoDrawText: jmethodid = nil;
  javaMethod_LCLDoShowMessageBox: jmethodid = nil;
  javaMethod_LCLDoCreateTimer: jmethodid = nil;
  javaMethod_LCLDoDestroyTimer: jmethodid = nil;
  javaMethod_LCLDoHideVirtualKeyboard: jmethodid = nil;
  javaMethod_LCLDoShowVirtualKeyboard: jmethodid = nil;
  javaMethod_LCLDoStartReadingAccelerometer: jmethodid = nil;
  javaMethod_LCLDoStopReadingAccelerometer: jmethodid = nil;
  javaMethod_LCLDoSendMessage: jmethodid = nil;
  javaMethod_LCLDoRequestPositionInfo: jmethodid = nil;
  // Methods from android.app.Activity
  javaMethod_Activity_finish: jmethodid = nil;
  // Methods from java.lang.System
  javaMethod_System_exit: jmethodid = nil;
  // Generic methods from Context
  javaMethod_getSystemService: jmethodid = nil;

  // This is utilized to store the information such as invalidate requests in events
  eventResult: jint;
{$endif}

implementation

uses
  WsControls, lclintf,
  CustomDrawnWSFactory,
  CustomDrawnWSForms,
{  Win32WSButtons,
  Win32WSMenus,
  Win32WSStdCtrls,
  Win32WSDialogs,
  Win32Themes,
////////////////////////////////////////////////////
  Win32Extra,}
  customdrawnprivate,
  LCLMessageGlue;

  {$ifdef CD_Windows}
const
  CDBackendNativeHandle = nhtWindowsHWND;
  {$define CD_HasNativeFormHandle}
  {$endif}
  {$ifdef CD_X11}
const
  CDBackendNativeHandle = nhtX11TWindow;
  {$define CD_HasNativeFormHandle}
  {$endif}
  {$ifdef CD_Cocoa}
const
  CDBackendNativeHandle = nhtCocoaNSWindow;
  {$define CD_HasNativeFormHandle}
  {$endif}

{ TLazCDCustomFont }

constructor TLazCDCustomFont.Create;
begin
  inherited Create;
  {$ifndef CD_UseNativeText}
  FTFont := TFreeTypeFont.Create;
  {$endif}
end;

destructor TLazCDCustomFont.Destroy;
begin
  {$ifndef CD_UseNativeText}
  FTFont.Free;
  {$endif}
  inherited Destroy;
end;

{$I customdrawnobject.inc}

{$I customdrawnwinapi.inc}
{$I customdrawnlclintf.inc}

{$ifdef CD_Windows}
  {$include wincallback.inc}
  {$I customdrawnobject_win.inc}
  {$I customdrawnwinapi_win.inc}
  {$I customdrawnlclintf_win.inc}
{$endif}
{$ifdef CD_Cocoa}
  {$I customdrawnobject_cocoa.inc}
  {$I customdrawnwinapi_cocoa.inc}
  {$I customdrawnlclintf_cocoa.inc}
{$endif}
{$ifdef CD_X11}
  {$I customdrawnobject_x11.inc}
  {$I customdrawnwinapi_x11.inc}
  {$I customdrawnlclintf_x11.inc}
{$endif}
{$ifdef CD_Android}
  {$I customdrawnobject_android.inc}
  {$I customdrawnwinapi_android.inc}
  {$I customdrawnlclintf_android.inc}
{$endif}

end.
