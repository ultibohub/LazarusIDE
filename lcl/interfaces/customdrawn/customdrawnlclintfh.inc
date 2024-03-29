{%MainUnit customdrawnint.pp}
{******************************************************************************
                All CustomDrawn interface communication implementations.
                   Initial Revision  : Sat Jan 17 19:00:00 2004


  !! Keep alphabetical !!

 ******************************************************************************
 Interface
 ******************************************************************************

 *****************************************************************************
  This file is part of the Lazarus Component Library (LCL)

  See the file COPYING.modifiedLGPL.txt, included in this distribution,
  for details about the license.
 *****************************************************************************
}

//##apiwiz##sps##   // Do not remove
(*
function AddEventHandler(AHandle: TLCLHandle; AFlags: dword;
  AEventHandler: TWaitHandleEvent; AData: PtrInt): PEventHandler; override;
function AddPipeEventHandler(AHandle: TLCLHandle;
  AEventHandler: TPipeEvent; AData: PtrInt): PPipeEventHandler; override;
function AddProcessEventHandler(AHandle: TLCLHandle;
  AEventHandler: TChildExitEvent; AData: PtrInt): PProcessEventHandler; override;*)
function AskUser(const DialogCaption, DialogMessage: string; DialogType:
   LongInt; Buttons: TDialogButtons; HelpCtx: Longint): LongInt; override;

function CreateEmptyRegion: hRGN; override;
(*function CreateStandardCursor(ACursor: SmallInt): HCURSOR; override;
function CreateRubberBand(const ARect: TRect; const ABrush: HBrush = 0): HWND; override;
procedure DrawDefaultDockImage(AOldRect, ANewRect: TRect; AOperation: TDockImageOperation); override;
procedure DrawGrid(DC: HDC; const R: TRect; DX, DY: Integer); override;
procedure DestroyRubberBand(ARubberBand: HWND); override;
function FontIsMonoSpace(Font: HFont): boolean; override;
*)
function GetAvailableNativeCanvasTypes(DC: HDC; AAllowFallbackToParent: Boolean = False): TNativeCanvasTypes; override;
function GetAvailableNativeHandleTypes(Handle: HWND; AAllowFallbackToParent: Boolean = False): TNativeHandleTypes; override;
//function GetDesignerDC(WindowHandle: HWND): HDC; override;
function GetNativeCanvas(DC: HDC; AHandleType: TNativeCanvasType; AAllowFallbackToParent: Boolean = False): PtrInt; override;
function GetNativeHandle(Handle: HWND; AHandleType: TNativeHandleType; AAllowFallbackToParent: Boolean = False): PtrInt; override;

procedure HideVirtualKeyboard();

(*
function IsDesignerDC(WindowHandle: HWND; DC: HDC): Boolean; override;*)
function IsMobilePlatform: Boolean; override;
function IsScreenDC(ADC: HDC): Boolean;
function IsCDIntfControl(AWinControl: TObject): Boolean; override;

function PromptUser(const DialogCaption : string;
                    const DialogMessage : string;
                          DialogType    : LongInt;
                          Buttons       : PLongInt;
                          ButtonCount   : LongInt;
                          DefaultIndex  : LongInt;
                          EscapeResult  : LongInt) : LongInt; override;

function RadialPie(DC: HDC; x1, y1, x2, y2, Angle1, Angle2: Integer): Boolean; override;
function RawImage_CreateBitmaps(const ARawImage: TRawImage; out ABitmap, AMask: HBitmap; ASkipMask: Boolean = False): Boolean; override;

function RawImage_DescriptionFromBitmap(ABitmap: HBITMAP; out ADesc: TRawImageDescription): Boolean; override;
function RawImage_DescriptionFromDevice(ADC: HDC; out ADesc: TRawImageDescription): Boolean; override;

function RawImage_FromBitmap(out ARawImage: TRawImage; ABitmap, AMask: HBITMAP; ARect: PRect = nil): Boolean; override;
function RawImage_FromDevice(out ARawImage: TRawImage; ADC: HDC; const ARect: TRect): Boolean; override;
function RawImage_QueryDescription(AFlags: TRawImageQueryFlags; var ADesc: TRawImageDescription): Boolean; override;
(*function ReleaseDesignerDC(Window: HWND; DC: HDC): Integer; override;

procedure RemoveEventHandler(var AHandler: PEventHandler); override;
procedure RemovePipeEventHandler(var AHandler: PPipeEventHandler); override;
procedure RemoveProcessEventHandler(var AHandler: PProcessEventHandler); override;

procedure SetEventHandlerFlags(AHandler: PEventHandler; NewFlags: dword); override;
procedure SetRubberBandRect(const ARubberBand: HWND; const ARect: TRect); override;*)
function ShowSelectItemDialog(const AItems: TStrings; APos: TPoint): Boolean; override;
{$ifndef CD_HasNativeSelectItemDialog}
procedure HandleSelectItemDialogClose(ASender: TObject);
{$endif}
procedure ShowVirtualKeyboard();

// No need to implement this one as the default is redirecting to ExtTextOut
// which already handles UTF-8
//function TextUTF8Out(DC: HDC; X, Y: Integer; Str: PChar; Count: Longint): Boolean; override;

//##apiwiz##eps##   // Do not remove, no wizard declaration after this line
