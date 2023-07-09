{*****************************************************}
{                                                     }
{               FastReport v2.3                       }
{          RoundRect plus Add-in object               }
{       (C) Guilbaud Olivier for FR 2.3x              }
{    Some corrections by Alexander Tzyganenko         }
{     For question mail to : golivier@free.fr         }
{*****************************************************}
{Histo :                                              }
{ 29/04/99 : Cr�ation                                 }
{ 30/04/99 : Corrections minueurs                     }
{            Changer le TButton en TImage             }
{            pour le choix de la couleur              }
{            de l'ombre.                              }
{            Initialis� avec mots entiers             }
{            par defaut                               }
{ 22/06/99 : Ajout� la possibilit� de d�grad�         }
{            mais dans ce cas, c'est un rectangle     }
{ 10/11/99 : Update for the FR 2.31 version           }
{                                                     }

unit LR_RRect;

interface

{$I lr_vers.inc}
{$Packset 1}

uses
  Classes, SysUtils, LResources, GraphMath,
  Graphics, Controls, Forms, Dialogs,Buttons,
  StdCtrls, Menus,ClipBrd,

  LCLType,LR_Class, ExtCtrls,LCLIntf,LCLProc
  {$IFDEF LCLNOGUI}
  ,lr_ngcanvas
  {$ENDIF}
  ;

type
  {These are the six different gradient styles available.}
  TGradientStyle = (gsHorizontal, gsVertical, gsElliptic, gsRectangle,
                    gsVertCenter, gsHorizCenter);

  { TfrRoundRectObject }

  TfrRoundRectObject = class(TComponent)
  public
    Constructor Create(aOwner : TComponent); override;
  end;

  TCorner = (ctTopLeft,ctBottomLeft,ctBottomRight,ctTopRight);
  TCornerSet = set of TCorner;

  // Pour enregistrer les param�tres
  TfrRoundRect = packed record
    SGradian  : Boolean;   //ShowGradian
    GradStyle : TGradientStyle;
    
    SdColor   : TColor;    // Color of Shadow
    wShadow   : Integer;   // Width of shadow
    sCurve    : Boolean;   // RoundRect On/Off
    wCurve    : Integer;   // Curve size
    Corners   : TCornerSet; // Set of squared corners
  end;

  { TfrRoundRectView }

  TfrRoundRectView = class(TfrMemoView)
  private
    fCadre: TfrRoundRect;
    
    function GetGradStyle: TGradientStyle;
    function GetRoundRect: boolean;
    function GetRoundRectCurve: Integer;
    function GetShadowColor: TColor;
    function GetShadowWidth: Integer;
    function GetShowGrad: Boolean;
    procedure SetCorners(AValue: TCornerSet);
    procedure SetGradStyle(const AValue: TGradientStyle);
    procedure SetRoundRect(const AValue: boolean);
    procedure SetRoundRectCurve(const AValue: Integer);
    procedure SetShadowColor(const AValue: TColor);
    procedure SetShadowWidth(const AValue: Integer);
    procedure SetShowGrad(const AValue: Boolean);
    function  GetCorners: TCornerSet;
  public
    constructor Create(AOwnerPage:TfrPage); override;
    procedure Assign(Source: TPersistent); override;
    procedure LoadFromStream(Stream: TStream); override;
    procedure SaveToStream(Stream: TStream); override;
    procedure LoadFromXML(XML: TLrXMLConfig; const Path: String); override;
    procedure SaveToXML(XML: TLrXMLConfig; const Path: String); override;

    procedure ShowFrame; override;
    procedure ShowBackGround; override;
  published
    property ShowGradian : Boolean read GetShowGrad write SetShowGrad;
    property GradianStyle: TGradientStyle read GetGradStyle write SetGradStyle;
    property ShadowColor : TColor read GetShadowColor write SetShadowColor;
    property ShadowWidth : Integer read GetShadowWidth write SetShadowWidth;
    property RoundRect   : boolean read GetRoundRect write SetRoundRect;
    property RoundRectCurve : Integer read GetRoundRectCurve write SetRoundRectCurve;
    property SquaredCorners: TCornerSet read GetCorners write SetCorners;
  end;

  // Editeur de propri�t�s

  {$IFNDEF LCLNOGUI}

  { TfrRoundRectForm }

  TfrRoundRectForm = class(TfrObjEditorForm)
    chkTL: TCheckBox;
    chkTR: TCheckBox;
    chkBL: TCheckBox;
    chkBR: TCheckBox;
    lblSqrCorners: TLabel;
    M1: TMemo;
    Button5: TButton;
    Button6: TButton;
    lblSample: TLabel;
    colorDlg: TColorDialog;
    bOk: TButton;
    bCancel: TButton;
    Image1: TImage;
    imgSample: TImage;
    cbGradian: TCheckBox;
    panCurve: TPanel;
    cmShadow: TCheckBox;
    sCurve: TEdit;
    lblSWidth: TLabel;
    ShWidth: TEdit;
    lblSColor: TLabel;
    bcolor: TImage;
    cbCadre: TCheckBox;
    panGrad: TPanel;
    Label1: TLabel;
    bcolor3: TImage;
    Label2: TLabel;
    bColor2: TImage;
    cbStyle: TComboBox;
    Label3: TLabel;
    procedure Button5Click(Sender: TObject);
    procedure Button6Click(Sender: TObject);
    procedure bColorClick(Sender: TObject);
    procedure chkTLClick(Sender: TObject);
    procedure ShWidthChange(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure cbCadreClick(Sender: TObject);
    procedure cbGradianChange(Sender: TObject);
    procedure cmShadowClick(Sender: TObject);
    procedure M1KeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure FormKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure cbGradianClick(Sender: TObject);
    procedure FormShow(Sender: TObject);
  private
    { D�clarations priv�es }
    fShadowColor: TColor;
    fNormalColor: TColor;
    
    procedure ChgColorButton(S: TObject; C: TColor);
    procedure SetCorners(AValue: TCornerSet);
    procedure UpdateSample;
    function  GetCorners: TCornerSet;
  public
    { D�clarations publiques }
    procedure ShowEditor(t: TfrView); override;
    property Corners: TCornerSet read GetCorners write SetCorners;
  end;

  {$ENDIF}
implementation

uses LR_Const, LR_Var, LR_Flds;

{$IFNDEF LCLNOGUI}
{$R *.lfm}

var
  frRoundRectForm: TfrRoundRectForm;
{$ENDIF}

function RGB(R,G,B : Byte): TColor;
begin
  Result:=(R or (G shl 8) or (B shl 16));
end;


procedure PaintGrad(Cv: TCanvas; X, Y, X1, Y1: Word;
  FBeginClr, FEndClr: TColor; FGradientStyle: TGradientStyle);
var
  FromR, FromG, FromB: Integer; //These are the separate color values for RGB
  DiffR, DiffG, DiffB: Integer; // of color values.
  bm: TLazReportBitmap;

  {To speed things up and reduce flicker, I use a Bitmap to draw the button in
   its entirety, ten BitBlt it to the canvas of the control.}
  procedure DoHorizontal(fr, fg, fb, dr, dg, db: Integer);
  var
    ColorRect: TRect;
    I: Integer;
    R, G, B: Byte;
  begin
    DebugLn('DoHorizontal');
    ColorRect.Top := 0;                        //Set rectangle top
    ColorRect.Bottom := bm.Height;
    for I := 0 to 255 do
    begin         //Make lines (rectangles) of color
      ColorRect.Left := MulDiv (I, bm.Width, 256);    //Find left for this color
      ColorRect.Right := MulDiv (I + 1, bm.Width, 256);   //Find Right
      R := fr + MulDiv(I, dr, 255);            //Find the RGB values
      G := fg + MulDiv(I, dg, 255);
      B := fb + MulDiv(I, db, 255);
      bm.Canvas.Brush.Color := RGB(R, G, B);   //Plug colors into brush
      bm.Canvas.FillRect(ColorRect);           //Draw on Bitmap
    end;
  end;

  procedure DoVertical(fr, fg, fb, dr, dg, db: Integer);
  var
    ColorRect: TRect;
    I: Integer;
    R, G, B: Byte;
  begin
    DebugLn('DoVertical');

    ColorRect.Left := 0;                //Set rectangle left&right
    ColorRect.Right := bm.Width;
    for I := 0 to 255 do
    begin                               //Make lines (rectangles) of color
      ColorRect.Top := MulDiv (I, bm.Height, 256);    //Find top for this color
      ColorRect.Bottom := MulDiv (I + 1, bm.Height, 256);   //Find Bottom
      R := fr + MulDiv(I, dr, 255);    //Find the RGB values
      G := fg + MulDiv(I, dg, 255);
      B := fb + MulDiv(I, db, 255);
      bm.Canvas.Brush.Color := RGB(R, G, B);   //Plug colors into brush
      bm.Canvas.FillRect(ColorRect);           //Draw on Bitmap
    end;
  end;

  procedure DoElliptic(fr, fg, fb, dr, dg, db: Integer);
  var
    I: Integer;
    R, G, B: Byte;
    Pw, Ph: Double;
    x1, y1, x2, y2: Double;
  {The elliptic is a bit different, since I had to use real numbers. I cut down
   on the number (to 155 instead of 255) of iterations in an attempt to speed
   things up, to no avail.  I think it just takes longer for windows to draw an
   ellipse as opposed to a rectangle.}
  begin
    DebugLn('DoElliptic');

    bm.Canvas.Pen.Style := psClear;
    bm.Canvas.Pen.Mode := pmCopy;
    x1 := 0 - (bm.Width / 4);
    x2 := bm.Width + (bm.Width / 4);
    y1 := 0 - (bm.Height / 4);
    y2 := bm.Height + (bm.Height / 4);
    Pw := ((bm.Width / 4) + (bm.Width / 2)) / 155;
    Ph := ((bm.Height / 4) + (bm.Height / 2)) / 155;
    for I := 0 to 155 do
    begin                              //Make ellipses of color
      x1 := x1 + Pw;
      x2 := X2 - Pw;
      y1 := y1 + Ph;
      y2 := y2 - Ph;
      R := fr + MulDiv(I, dr, 155);    //Find the RGB values
      G := fg + MulDiv(I, dg, 155);
      B := fb + MulDiv(I, db, 155);
      bm.Canvas.Brush.Color := R or (G shl 8) or (b shl 16);   //Plug colors into brush
      bm.Canvas.Ellipse(Trunc(x1), Trunc(y1), Trunc(x2), Trunc(y2));
    end;
    bm.Canvas.Pen.Style := psSolid;
  end;

  procedure DoRectangle(fr, fg, fb, dr, dg, db: Integer);
  var
    I: Integer;
    R, G, B: Byte;
    Pw, Ph: Real;
    x1, y1, x2, y2: Double;
  begin
    DebugLn('DoRectangle');

    bm.Canvas.Pen.Style := psClear;
    bm.Canvas.Pen.Mode := pmCopy;
    x1 := 0;
    x2 := bm.Width;
    y1 := 0;
    y2 := bm.Height;
    Pw := (bm.Width / 2) / 255;
    Ph := (bm.Height / 2) / 255;
    for I := 0 to 255 do
    begin                              //Make rectangles of color
      x1 := x1 + Pw;
      x2 := X2 - Pw;
      y1 := y1 + Ph;
      y2 := y2 - Ph;
      R := fr + MulDiv(I, dr, 255);    //Find the RGB values
      G := fg + MulDiv(I, dg, 255);
      B := fb + MulDiv(I, db, 255);
      bm.Canvas.Brush.Color := RGB(R, G, B);   //Plug colors into brush
      bm.Canvas.FillRect(Rect(Trunc(x1), Trunc(y1), Trunc(x2), Trunc(y2)));
    end;
    bm.Canvas.Pen.Style := psSolid;
  end;

  procedure DoVertCenter(fr, fg, fb, dr, dg, db: Integer);
  var
    ColorRect: TRect;
    I: Integer;
    R, G, B: Byte;
    Haf: Integer;
  begin
    DebugLn('DoVertCenter');

    Haf := bm.Height Div 2;
    ColorRect.Left := 0;
    ColorRect.Right := bm.Width;
    for I := 0 to Haf do
    begin
      ColorRect.Top := MulDiv(I, Haf, Haf);
      ColorRect.Bottom := MulDiv(I + 1, Haf, Haf);
      R := fr + MulDiv(I, dr, Haf);
      G := fg + MulDiv(I, dg, Haf);
      B := fb + MulDiv(I, db, Haf);
      bm.Canvas.Brush.Color := RGB(R, G, B);
      bm.Canvas.FillRect(ColorRect);
      ColorRect.Top := bm.Height - (MulDiv (I, Haf, Haf));
      ColorRect.Bottom := bm.Height - (MulDiv (I + 1, Haf, Haf));
      bm.Canvas.FillRect(ColorRect);
    end;
  end;

  procedure DoHorizCenter(fr, fg, fb, dr, dg, db: Integer);
  var
    ColorRect: TRect;
    I: Integer;
    R, G, B: Byte;
    Haf: Integer;
  begin
    DebugLn('DoHorizCenter');

    Haf := bm.Width Div 2;
    ColorRect.Top := 0;
    ColorRect.Bottom := bm.Height;
    for I := 0 to Haf do
    begin
      ColorRect.Left := MulDiv(I, Haf, Haf);
      ColorRect.Right := MulDiv(I + 1, Haf, Haf);
      R := fr + MulDiv(I, dr, Haf);
      G := fg + MulDiv(I, dg, Haf);
      B := fb + MulDiv(I, db, Haf);
      bm.Canvas.Brush.Color := RGB(R, G, B);
      bm.Canvas.FillRect(ColorRect);
      ColorRect.Left := bm.Width - (MulDiv (I, Haf, Haf));
      ColorRect.Right := bm.Width - (MulDiv (I + 1, Haf, Haf));
      bm.Canvas.FillRect(ColorRect);
    end;
  end;

begin
  DebugLn('PaintGrad');
  try
    bm := TLazReportBitmap.Create;
    if Cv = nil then Exit;
    bm.Width := X1 - X;          //Set BMP dimensions to match control's
    bm.Height :=Y1 - Y;
    FromR := FBeginClr and $000000ff;  //Strip out separate RGB values
    FromG := (FBeginClr shr 8) and $000000ff;
    FromB := (FBeginClr shr 16) and $000000ff;
    DiffR := (FEndClr and $000000ff) - FromR;   //Find the difference
    DiffG := ((FEndClr shr 8) and $000000ff) - FromG;
    DiffB := ((FEndClr shr 16) and $000000ff) - FromB;
    //Depending on gradient style selected, go draw it on the Bitmap canvas.
    if FGradientStyle = gsHorizontal then
      DoHorizontal(FromR, FromG, FromB, DiffR, DiffG, DiffB);
    if FGradientStyle = gsVertical then
      DoVertical(FromR, FromG, FromB, DiffR, DiffG, DiffB);
    if FGradientStyle = gsElliptic then
      DoElliptic(FromR, FromG, FromB, DiffR, DiffG, DiffB);
    if FGradientStyle = gsRectangle then
      DoRectangle(FromR, FromG, FromB, DiffR, DiffG, DiffB);
    if FGradientStyle = gsVertCenter then
      DoVertCenter(FromR, FromG, FromB, DiffR, DiffG, DiffB);
    if FGradientStyle = gsHorizCenter then
      DoHorizCenter(FromR, FromG, FromB, DiffR, DiffG, DiffB);
    //By setting the Brush style to Clear, it will draw without overlaying bkgrnd
    bm.Canvas.Brush.Style := bsClear;  //Gradient is done, time for Hilite-Shadow
    {Finally, the button is all painted on the bitmap canvas. Now we just need
     to copy it to the canvas of our control.  BitBlt is one method; there are
     several others.}
    {$IFDEF LCLNOGUI}
    TVirtualCanvas(Cv).Draw(x, y, bm);
    {$ELSE}
    BitBlt(Cv.Handle, X, Y, bm.Width, bm.Height, bm.Canvas.Handle, 0, 0, SRCCOPY);
    {$ENDIF}
  finally
    bm.Free;
  end;
end;

procedure MixedRoundRect(Canvas:TCanvas; X1, Y1, X2, Y2: integer; RX, RY: integer;
  SqrCorners: TCornerSet);
var
  Pts: PPoint;
  c: Integer;
  Mx,My: Integer;

  procedure Corner(Ax,Ay,Bx,By,Cx,Cy:Integer);
  begin
    ReallocMem(Pts, SizeOf(TPoint)*(c+3));
    Pts[c].x:=ax; Pts[c].y:=ay; inc(c);
    Pts[c].x:=bx; Pts[c].y:=by; inc(c);
    Pts[c].x:=cx; Pts[c].y:=cy; inc(c);
  end;

begin

  X2 := X2-1;
  Y2 := Y2-1;

  // basic checks
  if X1>X2 then
  begin
    c :=X2;
    X2 := X1;
    X1 := c;
  end;
  if Y1>Y2 then
  begin
    c := Y2;
    Y2 := Y1;
    Y1 := c;
  end;
  if RY>(Y2-Y1) then
    RY:=(Y2-Y1);
  if RX>(X2-X1) then
    RX :=(X2-X1);

  MX := RX div 2;
  MY := RY div 2;

  c := 0;
  Pts := nil;
  if ctTopLeft in SqrCorners then
    Corner(X1+MX,Y1, X1,Y1, X1,Y1+MY)
  else
    BezierArcPoints(X1,Y1,RX,RY, 90*16, 90*16, 0, Pts, c);
  if ctBottomLeft in SqrCorners then
    Corner(X1,Y2-MY,X1,Y2,X1+MX,Y2)
  else
    BezierArcPoints(X1,Y2-RY,RX,RY, 180*16, 90*16, 0, Pts, c);
  if ctBottomRight in SqrCorners then
    Corner(X2-MX,Y2, X2,Y2, X2, Y2-MY)
  else
    BezierArcPoints(X2-RX,Y2-RY,RX,RY, 270*16, 90*16, 0, Pts, c);
  if ctTopRight in SqrCorners then
    Corner(X2,Y1+MY, X2,Y1, X2-MX,Y1)
  else
    BezierArcPoints(X2-RX,Y1,RX,RY, 0, 90*16, 0, Pts, c);

  Canvas.Polygon(Pts, c);
  ReallocMem(Pts, 0);
end;

function TfrRoundRectView.GetRoundRect: boolean;
begin
  Result:=fCadre.sCurve;
end;

function TfrRoundRectView.GetGradStyle: TGradientStyle;
begin
  Result:=fCadre.GradStyle;
end;

function TfrRoundRectView.GetRoundRectCurve: Integer;
begin
  Result:=fCadre.wCurve;
end;

function TfrRoundRectView.GetShadowColor: TColor;
begin
  Result:=fCadre.SdColor;
end;

function TfrRoundRectView.GetShadowWidth: Integer;
begin
  Result:=fCadre.wShadow;
end;

function TfrRoundRectView.GetShowGrad: Boolean;
begin
  Result:=fCadre.SGradian;
end;

procedure TfrRoundRectView.SetCorners(AValue: TCornerSet);
begin
  BeforeChange;
  fCadre.Corners := Avalue;
  AfterChange;
end;

procedure TfrRoundRectView.SetGradStyle(const AValue: TGradientStyle);
begin
  BeforeChange;
  fCadre.GradStyle:=aValue;
  AfterChange;
end;

procedure TfrRoundRectView.SetRoundRect(const AValue: boolean);
begin
  BeforeChange;
  fCadre.sCurve:=aValue;
  AfterChange;
end;

procedure TfrRoundRectView.SetRoundRectCurve(const AValue: Integer);
begin
  BeforeChange;
  fCadre.wCurve:=aValue;
  AfterChange;
end;

procedure TfrRoundRectView.SetShadowColor(const AValue: TColor);
begin
  BeforeChange;
  fCadre.SdColor:=aValue;
  AfterChange;
end;

procedure TfrRoundRectView.SetShadowWidth(const AValue: Integer);
begin
  BeforeChange;
  fCadre.wShadow:=aValue;
  AfterChange;
end;

procedure TfrRoundRectView.SetShowGrad(const AValue: Boolean);
begin
  BeforeChange;
  fCadre.SGradian:=aValue;
  AfterChange;
end;

function TfrRoundRectView.GetCorners: TCornerSet;
begin
  result := fCadre.Corners;
end;

(********************************************************)
constructor TfrRoundRectView.Create(AOwnerPage: TfrPage);
begin
  inherited Create(AOwnerPage);
  BeginUpdate;
  try
    //Initialization
    Typ      := gtAddIn;
    Frames   := frAllFrames;
    BaseName := 'RoundRect';

    //Default values
    fCadre.SGradian:=False;
    fCadre.GradStyle:=gsHorizontal;
    fCadre.SdColor := clGray;
    fCadre.wShadow := 6;
    fCadre.sCurve := True;
    fCadre.wCurve := 10;
    fCadre.Corners := [];
  finally
    Endupdate;
  end;
end;

procedure TfrRoundRectView.Assign(Source: TPersistent);
begin
  inherited Assign(Source);

  if Source is TfrRoundRectView then
    fCadre := TfrRoundRectView(Source).fCadre
  else
  begin
    fCadre.wCurve:=10;
    fCadre.sCurve:=true;
    fCadre.SGradian:=false;
    fCadre.wShadow:=0;
    fCadre.Corners:=[ctTopLeft,ctBottomLeft,ctBottomRight,ctTopRight];
  end;
end;

procedure TfrRoundRectView.LoadFromStream(Stream: TStream);
begin
  inherited LoadFromStream(Stream);
  Stream.Read(fCadre, SizeOf(fCadre));
end;

procedure TfrRoundRectView.SaveToStream(Stream: TStream);
begin
  inherited SaveToStream(Stream);
  Stream.Write(fCadre, SizeOf(fCadre));
end;

procedure TfrRoundRectView.LoadFromXML(XML: TLrXMLConfig; const Path: String);
begin
  inherited LoadFromXML(XML, Path);
  
  RestoreProperty('GradianStyle',XML.GetValue(Path+'Data/GradianStyle/Value',''));
  RestoreProperty('ShowGradian',XML.GetValue(Path+'Data/ShowGradian/Value',''));
  RestoreProperty('ShadowColor',XML.GetValue(Path+'Data/ShadowColor/Value',''));
  RestoreProperty('ShadowWidth',XML.GetValue(Path+'Data/ShadowWidth/Value',''));
  RestoreProperty('RoundRect',XML.GetValue(Path+'Data/RoundRect/Value',''));
  RestoreProperty('RoundRectCurve',XML.GetValue(Path+'Data/RoundRectCurve/Value',''));
  RestoreProperty('SquaredCorners',XML.GetValue(Path+'Data/SquaredCorners/Value',''));
end;

procedure TfrRoundRectView.SaveToXML(XML: TLrXMLConfig; const Path: String);
begin
  inherited SaveToXML(XML, Path);
  
  XML.SetValue(Path+'Data/ShowGradian/Value', GetSaveProperty('ShowGradian'));
  XML.SetValue(Path+'Data/GradianStyle/Value', GetSaveProperty('GradianStyle'));
  XML.SetValue(Path+'Data/ShadowColor/Value', GetSaveProperty('ShadowColor'));
  XML.SetValue(Path+'Data/ShadowWidth/Value', GetSaveProperty('ShadowWidth'));
  XML.SetValue(Path+'Data/RoundRect/Value', GetSaveProperty('RoundRect'));
  XML.SetValue(Path+'Data/RoundRectCurve/Value', GetSaveProperty('RoundRectCurve'));
  XML.SetValue(Path+'Data/SquaredCorners/Value', GetSaveProperty('SquaredCorners'));
end;

procedure TfrRoundRectView.ShowBackGround;
var
  OldDRect: TRect;
  OldFill: TColor;
begin
  // prevent screen garbage in designer
  if (DocMode <> dmDesigning) or fCadre.SGradian then Exit;
  BeginUpdate;
  try
    OldDRect := DRect;
    OldFill := FillColor;
    DRect := Rect(x, y, x + dx + 1, y + dy + 1);
    FillColor := clWhite;
  inherited;
    DRect := OldDRect;
    FillColor := OldFill;
  Finally
    EndUpdate;
  end;
end;

procedure TfrRoundRectView.ShowFrame;
var
  FSW, FCU: Integer;

  procedure Line(x, y, dx, dy: Integer);
  begin
    Canvas.MoveTo(x, y);
    Canvas.LineTo(x + dx, y + dy);
  end;

  procedure FrameLine(i: Integer);
  begin
    Canvas.Pen.Width := Round(FrameWidth);
    case i of
      0: Line(x + dx, y, 0, dy);
      1: Line(x, y, 0, dy);
      2: Line(x, y + dy, dx, 0);
      3: Line(x, y, dx, 0);
    end;
  end;

begin
  if DisableDrawing then Exit;
  with Canvas do
  begin
    if fCadre.SGradian then
    begin
      if fCadre.wCurve < 0 then
        fCadre.wCurve := 0;
      PaintGrad(Canvas, X, Y, X + DX, Y + DY, FillColor, fCadre.SdColor,fCadre.GradStyle);
      Pen.Width := Round(FrameWidth);
      Pen.Color := FrameColor;

      //(frbLeft, frbTop, frbRight, frbBottom)
      if (frbRight in Frames) then FrameLine(0);
      if (frbLeft in Frames) then FrameLine(1);
      if (frbBottom in Frames) then FrameLine(2);
      if (frbTop in Frames) then FrameLine(3);

      Exit;
    end;

    // Trace l'ombre
    Pen.Style := psSolid;
    if FillColor=clNone then
      Brush.Style := bsClear
    else
      Brush.Style := bsSolid;
    Pen.Color := fCadre.SdColor;
    Pen.Width := Round(FrameWidth);
    Brush.Color := fCadre.SdColor;

    FSW := Round(fCadre.wShadow * ScaleY);
    FCU := Round(fCadre.wCurve * ScaleY);

    if fCadre.sCurve then
    begin
      MixedRoundRect(Canvas, x + FSW, y + FSW, x + dx + 1, y + dy + 1, FCu, Fcu, GetCorners);
    end
    else
      Rectangle(x + FSW, y + FSW, x + dx + 1, y + dy + 1);

    // Trace la zone de texte
    Pen.Width := Round(FrameWidth);

    if (Frames=[]) then
      Pen.Color := FillColor
    else
      Pen.Color := FrameColor; // Trace le cadre

    Brush.Color := FillColor;
    if fCadre.sCurve then
    begin
      MixedRoundRect(Canvas, x, y, x + dx + 1 - FSW, y + dy + 1 - FSW, FCu, Fcu, GetCorners);
    end
    else
      Rectangle(x, y, x + dx + 1 - FSW, y + dy + 1 - FSW);

    Brush.Style := bsSolid;
  end;
end;

{$IFNDEF LCLNOGUI}
(****************************************************)
procedure TfrRoundRectForm.FormCreate(Sender: TObject);
var
  i: Integer;
  s: String;
begin
  if sender=nil then ;
  Caption := sRoundRectFormCaption;
  LblSample.Caption := sRoundRectFormSample;
  Button5.Caption   := sRoundRectFormVar;
  Button6.Caption   := sRoundRectFormData;
  cbGradian.Caption := sRoundRectFormGradient;
  lblSWidth.Caption := sRoundRectFormShadow;
  LblSColor.Caption := sRoundRectFormColor;
  cmShadow.Caption  := sRoundRectFormCurve;
  cbCadre.Caption   := sRoundRectFormFramed;
  Label1.Caption    := sRoundRectFormEndColor;
  Label2.Caption    := sRoundRectFormBeginColor;
  Label3.Caption    := sRoundRectFormStyle;
  bColor.Hint       := sRoundRectFormHint;
  bColor2.Hint      := bColor.Hint;
  bColor3.Hint      := bColor3.Hint;
  BOk.Caption       := sOk;
  bCancel.Caption   := sCancel;
  lblSqrCorners.Caption := sRoundRectSqrCorners;

  cbStyle.Items.CommaText := sRoundRectFormStyleDif;
  for i := 0 to cbStyle.Items.Count - 1 do
  begin
    s := cbStyle.Items.Strings[i];
    if Pos('_', s) <> 0 then
    begin
      s[Pos('_', s)] := ' ';
      cbStyle.Items.Strings[i] := s;
    end;
  end;

  panGrad.Left := panCurve.Left;
  panGrad.Top := panCurve.Top;
  panGrad.Visible := False;
end;

procedure TfrRoundRectForm.Button5Click(Sender: TObject);
begin
  if sender=nil then ;
  frVarForm := TfrVarForm.Create(nil);
  with frVarForm do
  if ShowModal = mrOk then
  begin
    ClipBoard.Clear;
    if SelectedItem <> '' then
    Begin
      ClipBoard.Clear;
      ClipBoard.AsText := '[' + SelectedItem + ']';
      M1.PasteFromClipboard;
    end;
  end;
  frVarForm.Free;
  M1.SetFocus;
end;

procedure TfrRoundRectForm.Button6Click(Sender: TObject);
begin
  if sender=nil then ;
  frFieldsForm := TfrFieldsForm.Create(nil);
  with frFieldsForm do
  if ShowModal = mrOk then
    if DBField <> '' then
    begin
      ClipBoard.Clear;
      ClipBoard.AsText := '[' + DBField + ']';
      M1.PasteFromClipboard;
    end;
  frFieldsForm.Free;
  M1.SetFocus;
end;

procedure TfrRoundRectForm.ChgColorButton(S: TObject; C: TColor);
var
  BM: TBitmap;
  Bc: TImage;
begin
  BM := TBitmap.Create;
  Bc := S as TImage;
  BM.Height := bC.Height;
  BM.Width := bC.Width;

  with BM.Canvas do
  begin
    Pen.Color := clBlack;
    Brush.Color := C;
    Rectangle(0, 0, bC.Width, bC.Height);
  end;

  if Bc.Tag = 0 then
    fShadowColor := C
  else
    fNormalColor := C;

  bC.Picture.Assign(BM);
  BM.Free;
end;

procedure TfrRoundRectForm.SetCorners(AValue: TCornerSet);
begin
  chkTL.Checked := ctTopLeft in AValue;
  chkBL.Checked := ctBottomLeft in AValue;
  chkBR.Checked := ctBottomRight in AValue;
  chkTR.Checked := ctTopRight in AValue;
end;

procedure TfrRoundRectForm.UpdateSample;
var
  CC: TCanvas;
  FsW: Integer;
  FCu: Integer;
  BM: TBitmap;
begin
  try
    FsW := StrToInt(ShWidth.Text);
  except
    FsW := 10;
  end;

  try
    FCu := StrToInt(SCurve.Text);
  except
    FCu := 10;
  end;

  BM := TBitmap.Create;
  BM.Height := imgSample.Height;
  BM.Width := imgSample.Width;

  CC := BM.Canvas;

  if cbGradian.Checked then
  begin
    FsW := cbStyle.ItemIndex;
    if FsW < 0 then FsW:=0;
    PaintGrad(CC, 0, 0, bm.Width, bm.Height, fNormalColor, fShadowColor,
      TGradientStyle(FsW));
  end
  else
  begin
    // R�initialise le panel
    CC.Pen.Color := clBtnFace;
    CC.Brush.Color := clBtnFace;
    CC.Rectangle(0, 0, imgSample.Width, imgSample.Height);

    // Trace l'ombre
    CC.Pen.Color := fShadowColor;
    CC.Brush.Color := fShadowColor;

    if cmShadow.Checked then
      MixedRoundRect(CC,0 + FSW, 0 + FSW, imgSample.Width, imgSample.Height,
        FCu, FCu, GetCorners)
    else
      CC.Rectangle(0 + FSW, 0 + FSW, imgSample.Width, imgSample.Height);

    // Trace la zone de texte
    if not cbCadre.Checked then
      CC.Pen.Color := fNormalColor
    else
      CC.Pen.Color := clBlack; // Trace le cadre

    CC.Brush.Color := fNormalColor;
    if cmShadow.Checked then
      MixedRoundRect(CC,0, 0, imgSample.Width - FSW, imgSample.Height - FSW,
        FCu, FCu, GetCorners)
    else
      CC.Rectangle(0, 0, imgSample.Width - FSW, imgSample.Height - FSW);
  end;

  imgSample.Picture.Assign(BM);
  BM.Free;
end;

function TfrRoundRectForm.GetCorners: TCornerSet;
begin
  result := [];
  if chkTL.Checked then Include(result, ctTopLeft);
  if chkBL.Checked then Include(result, ctBottomLeft);
  if chkBR.Checked then Include(result, ctBottomRight);
  if chkTR.Checked then Include(result, ctTopRight);
end;

procedure TfrRoundRectForm.bColorClick(Sender: TObject);
begin
  if sender=nil then ;
  ColorDlg.Color := fShadowColor;
  if ColorDlg.Execute then
  begin
    ChgColorButton(Sender, ColorDlg.Color);
    UpdateSample;
  end;
end;

procedure TfrRoundRectForm.chkTLClick(Sender: TObject);
begin
  //
  UpdateSample;
end;

procedure TfrRoundRectForm.ShWidthChange(Sender: TObject);
begin
  if Sender is TEdit then
    if TEdit(Sender).Text = '' then Exit;
  UpdateSample;
end;

procedure TfrRoundRectForm.cbCadreClick(Sender: TObject);
begin
  if sender=nil then ;
  UpdateSample;
end;

procedure TfrRoundRectForm.cbGradianChange(Sender: TObject);
begin
  if sender=nil then ;
end;

procedure TfrRoundRectForm.cmShadowClick(Sender: TObject);
begin
  if sender=nil then ;
  UpdateSample;
end;

procedure TfrRoundRectForm.cbGradianClick(Sender: TObject);
begin
  if sender=nil then ;
  panGrad.Visible := cbGradian.Checked;
  panCurve.Visible := not panGrad.Visible;
  if panGrad.Visible then
  begin
    sCurve.Text := '0';
    cbStyle.ItemIndex := 0;
  end
  else
    sCurve.Text := '10';
end;

procedure TfrRoundRectForm.M1KeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  if sender=nil then ;
  if (Key = vk_Insert) and (Shift = []) then Button5Click(Self);
  if Key = vk_Escape then ModalResult := mrCancel;
end;

procedure TfrRoundRectForm.FormKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  if sender=nil then ;
  if (Key = vk_Return) and (ssCtrl in Shift) then
  begin
    ModalResult := mrOk;
    Key := 0;
  end;
end;

procedure TfrRoundRectForm.ShowEditor(t:TfrView);
begin
  M1.Lines.Assign(t.Memo);
  with t as TfrRoundRectView do
  begin
    shWidth.Text := IntToStr(fCadre.wShadow);
    if not fCadre.SGradian then
    begin // RoundRect
      cbGradian.Checked := False;
      fShadowColor := fCadre.sdColor;
      fNormalColor := FillColor;
      cbCadre.Checked := (t.Frames<>[]);
      cmShadow.Checked := fCadre.sCurve;
      sCurve.Text := IntToStr(fCadre.wCurve);
      Corners := fCadre.Corners;
    end
    else
    begin //Gradian
      cbGradian.Checked := True;
      fShadowColor := fCadre.sdColor;
      fNormalColor := FillColor;
      if fCadre.wCurve > cbStyle.Items.Count - 1 then
        fCadre.wCurve := 0;
      cbStyle.ItemIndex :=Ord(fCadre.GradStyle);
    end;

    if ShowModal = mrOk then
    begin
      Memo.Assign(M1.Lines);
      fCadre.sdColor := fShadowColor;
      FillColor := fNormalColor;
      fCadre.sCurve := cmShadow.Checked;
      if cbCadre.Checked then
        Frames:=frAllFrames
      else
        Frames:=[];
      try
        fCadre.wShadow := StrToInt(shWidth.Text);
      except
        fCadre.wShadow := 6;
      end;

      fCadre.Corners := Corners;

      fCadre.SGradian:=cbGradian.checked;
      
      try
        fCadre.wCurve := StrToInt(sCurve.Text);
        if fCadre.SGradian then
          fCadre.GradStyle:=TGradientStyle(cbStyle.ItemIndex);
      except
        fCadre.wCurve := 10;
      end;
    end;
  end;
end;

procedure TfrRoundRectForm.FormShow(Sender: TObject);
begin
  if sender=nil then ;
  M1.SetFocus;
  UpdateSample;
  ChgColorButton(bColor, fShadowColor);
  ChgColorButton(bColor2, fNormalColor);
  ChgColorButton(bColor3, fShadowColor);
end;
{$ENDIF}


{ TfrRoundRectObject }

constructor TfrRoundRectObject.Create(aOwner: TComponent);
begin
  inherited Create(aOwner);
  {$IFNDEF LCLNOGUI}
  if not assigned(frRoundRectForm) {and not (csDesigning in ComponentState)} then
  begin
    frRoundRectForm := TfrRoundRectForm.Create(nil);
    frRegisterObject(TfrRoundRectView, frRoundRectForm.Image1.Picture.Bitmap,
      sInsRoundRect, frRoundRectForm);
  end;
  {$ENDIF}
end;

{$IFNDEF LCLNOGUI}
initialization

  frRoundRectForm:=nil;

finalization

  if Assigned(frRoundRectForm) then
    frRoundRectForm.Free;

{$ELSE}
initialization
  frRegisterObject(TfrRoundRectView, nil, sInsRoundRect, nil);
{$ENDIF}

end.

