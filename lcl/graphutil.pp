{ $Id$ }
{
 /***************************************************************************
                                graphutil.pp
                                ------------
                          Graphic utility functions.

 ***************************************************************************/

 *****************************************************************************
  This file is part of the Lazarus Component Library (LCL)

  See the file COPYING.modifiedLGPL.txt, included in this distribution,
  for details about the license.
 *****************************************************************************
}
unit GraphUtil;

{$mode objfpc}{$H+}

interface

uses
  SysUtils, Types, Math,
  // LCL
  Graphics, LCLType, LCLIntf,
  // LazUtils
  GraphType;

function ColorToGray(const AColor: TColor): Byte;
procedure ColorToHLS(const AColor: TColor; out H, L, S: Byte);
procedure RGBtoHLS(const R, G, B: Byte; out H, L, S: Byte);
function HLStoColor(const H, L, S: Byte): TColor;
procedure HLStoRGB(const H, L, S: Byte; out R, G, B: Byte);

// HSV functions are copied from mbColorLib without changes
procedure ColorToHSV(c: TColor; out H, S, V: Double);
function HSVToColor(H, S, V: Double): TColor;
procedure RGBToHSV(R, G, B: Integer; out H, S, V: Double);
procedure HSVtoRGB(H, S, V: Double; out R, G, B: Integer);
procedure RGBtoHSVRange(R, G, B: integer; out H, S, V: integer);
procedure HSVtoRGBRange(H, S, V: Integer; out R, G, B: Integer);
function HSVRangeToColor(H, S, V: Integer): TColor;
function HSVtoRGBTriple(H, S, V: integer): TRGBTriple;
function HSVtoRGBQuad(H, S, V: integer): TRGBQuad;

function GetHValue(Color: TColor): integer;
function GetSValue(Color: TColor): integer;
function GetVValue(Color: TColor): integer;

// specific things:

{ Draw gradient from top to bottom with parabolic color grow }
procedure DrawVerticalGradient(Canvas: TCanvas; ARect: TRect; TopColor, BottomColor: TColor);

{ Draw nice looking window with Title }
procedure DrawGradientWindow(Canvas: TCanvas; WindowRect: TRect; TitleHeight: Integer; BaseColor: TColor);

{ Stretch-draw a bitmap in an anti-aliased way }
procedure AntiAliasedStretchDrawBitmap(SourceBitmap, DestBitmap: TCustomBitmap;
  DestWidth, DestHeight: integer);

{ Converts a bitmap to grayscale taking filtering parameters into account. }
procedure BitmapGrayscale(ABitmap: TCustomBitmap; RedFilter, GreenFilter, BlueFilter: Single);

{ Draw arrows }
type TScrollDirection=(sdLeft,sdRight,sdUp,sdDown);
     TArrowType = (atSolid, atArrows);
const NiceArrowAngle=45*pi/180;

procedure DrawArrow(Canvas:TCanvas;Direction:TScrollDirection; Location: TPoint; Size: Longint; ArrowType: TArrowType=atSolid);
procedure DrawArrow(Canvas:TCanvas;p1,p2: TPoint; ArrowType: TArrowType=atSolid);
procedure DrawArrow(Canvas:TCanvas;p1,p2: TPoint; ArrowLen: longint; ArrowAngleRad: float=NiceArrowAngle; ArrowType: TArrowType=atSolid);

procedure FloodFill(Canvas: TCanvas; X, Y: Integer; lColor: TColor; FillStyle: TFillStyle);
procedure ScaleImg(AImage: TCustomBitmap; AWidth, AHeight: Integer);

// delphi compatibility
procedure ColorRGBToHLS(clrRGB: COLORREF; var Hue, Luminance, Saturation: Word);
function ColorHLSToRGB(Hue, Luminance, Saturation: Word): TColorRef;
function ColorAdjustLuma(clrRGB: TColor; n: Integer; fScale: BOOL): TColor;
function GetHighLightColor(const Color: TColor; Luminance: Integer = 19): TColor;
function GetShadowColor(const Color: TColor; Luminance: Integer = -50): TColor;

// misc
function NormalizeRect(const R: TRect): TRect;
procedure WaveTo(ADC: HDC; X, Y, R: Integer);


implementation

uses
  fpimage, fpcanvas, IntfGraphics, LazCanvas;

//TODO: Check code on endianess

procedure ExtractRGB(RGB: TColorRef; var R, G, B: Byte); inline;
begin
  R := RGB and $FF;
  G := (RGB shr 8) and $FF;
  B := (RGB shr 16) and $FF;
end;

function ColorToGray(const AColor: TColor): Byte;
var
  RGB: TColorRef;
begin
  if AColor = clNone
  then RGB := 0
  else RGB := ColorToRGB(AColor);
  Result := Trunc(0.222 * (RGB and $FF) + 0.707 * ((RGB shr 8) and $FF) + 0.071 * (RGB shr 16 and $FF));
end;

procedure ColorToHLS(const AColor: TColor; out H, L, S: Byte);
var
  R, G, B: Byte;
  RGB: TColorRef;
begin
  RGB := ColorToRGB(AColor);
  ExtractRGB(RGB, R, G, B);

  RGBtoHLS(R, G, B, H, L, S);
end;

function HLStoColor(const H, L, S: Byte): TColor;
var
  R, G, B: Byte;
begin
  HLStoRGB(H, L, S, R, G, B);
  Result := R or (G shl 8) or (B shl 16);
end;

procedure RGBtoHLS(const R, G, B: Byte; out H, L, S: Byte);
var aDelta, aMin, aMax: Byte;
begin
  aMin := Math.min(Math.min(R, G), B);
  aMax := Math.max(Math.max(R, G), B);
  aDelta := aMax - aMin;
  if aDelta > 0 then
    begin
      if aMax = B
        then H := round(170 + 42.5*(R - G)/aDelta)   { 2*255/3; 255/6 }
        else if aMax = G
               then H := round(85 + 42.5*(B - R)/aDelta)  { 255/3 }
               else if G >= B
                      then H := round(42.5*(G - B)/aDelta)
                      else H := round(255 + 42.5*(G - B)/aDelta);
    end;
  L := (aMax + aMin) div 2;
  if (L = 0) or (aDelta = 0)
    then S := 0
    else if L <= 127
           then S := round(255*aDelta/(aMax + aMin))
           else S := round(255*aDelta/(510 - aMax - aMin));
end;


procedure HLSToRGB(const H, L, S: Byte; out R, G, B: Byte);
var hue, chroma, x: Single;
begin
  if S > 0 then
    begin  { color }
      hue:=6*H/255;
      chroma := S*(1 - abs(0.0078431372549*L - 1));  { 2/255 }
      G := trunc(hue);
      B := L - round(0.5*chroma);
      x := B + chroma*(1 - abs(hue - 1 - G and 254));
      case G of
        0: begin
             R := B + round(chroma);
             G := round(x);
           end;
        1: begin
             R := round(x);
             G := B + round(chroma);
           end;
        2: begin
             R := B;
             G := B + round(chroma);
             B := round(x);
           end;
        3: begin
             R := B;
             G := round(x);
             inc(B, round(chroma));
           end;
        4: begin
             R := round(x);
             G := B;
             inc(B, round(chroma));
           end;
        otherwise
          R := B + round(chroma);
          G := B;
          B := round(x);
      end;
    end else
    begin  { grey }
      R := L;
      G := L;
      B := L;
    end;
end;




procedure DrawArrow(Canvas: TCanvas; Direction: TScrollDirection;
  Location: TPoint; Size: Longint; ArrowType: TArrowType);
const ScrollDirectionX:array[TScrollDirection]of longint=(-1,+1,0,0);
      ScrollDirectionY:array[TScrollDirection]of longint=(0,0,-1,+1);
begin
  DrawArrow(Canvas,Location,
            point(ScrollDirectionX[Direction]*size+Location.x,ScrollDirectionY[Direction]*size+Location.y),
            max(5,size div 10),
            NiceArrowAngle,ArrowType);
end;

procedure DrawArrow(Canvas: TCanvas; p1, p2: TPoint; ArrowType: TArrowType);
begin
  DrawArrow(Canvas,p1,p2,round(sqrt(sqr(p1.x-p2.x)+sqr(p1.y-p2.y))/10),NiceArrowAngle,ArrowType);
end;

procedure DrawArrow(Canvas: TCanvas; p1, p2: TPoint; ArrowLen: longint;
  ArrowAngleRad: float; ArrowType: TArrowType);
var
  LineAngle: float;
  sinAngle, cosAngle: float;
  ArrowPoint1, ArrowPoint2: TPoint;
begin
  LineAngle:=arctan2(p2.y-p1.y,p2.x-p1.x);
  SinCos(pi + LineAngle - ArrowAngleRad, sinAngle, cosAngle);
  ArrowPoint1.x := round(ArrowLen * cosAngle) + p2.x;
  ArrowPoint1.y := round(ArrowLen * sinAngle) + p2.y;
  SinCos(pi + LineAngle + ArrowAngleRad, sinAngle, cosAngle);
  ArrowPoint2.x := round(ArrowLen * cosAngle) + p2.x;
  ArrowPoint2.y := round(ArrowLen * sinAngle) + p2.y;
  Canvas.Line(p1,p2);

  case ArrowType of
    atSolid: begin
      canvas.Polygon([ArrowPoint1,p2,ArrowPoint2]);
    end;
    atArrows: begin
      Canvas.LineTo(ArrowPoint1.x,ArrowPoint1.y);
      Canvas.Line(p2.x,p2.y,ArrowPoint2.x,ArrowPoint2.y);
    end;
  end;
end;

type
  ByteRA = array [1..1] of byte;
  Bytep = ^ByteRA;
  LongIntRA = array [1..1] of LongInt;
  LongIntp = ^LongIntRA;

procedure FloodFill(Canvas: TCanvas; X, Y: Integer; lColor: TColor;
  FillStyle: TFillStyle);
//Written by Chris Rorden
// Very slow, because uses Canvas.Pixels.
//A simple first-in-first-out circular buffer (the queue) for flood-filling contiguous voxels.
//This algorithm avoids stack problems associated simple recursive algorithms
//http://steve.hollasch.net/cgindex/polygons/floodfill.html [^]
const
  kFill = 0; //pixels we will want to flood fill
  kFillable = 128; //voxels we might flood fill
  kUnfillable = 255; //voxels we can not flood fill
var
  lWid,lHt,lQSz,lQHead,lQTail: integer;
  lQRA: LongIntP;
  lMaskRA: ByteP;
  
  procedure IncQra(var lVal, lQSz: integer);//nested inside FloodFill
  begin
      inc(lVal);
      if lVal >= lQSz then
         lVal := 1;
  end; //nested Proc IncQra
  
  function Pos2XY (lPos: integer): TPoint;
  begin
      result.X := ((lPos-1) mod lWid)+1; //horizontal position
      result.Y := ((lPos-1) div lWid)+1; //vertical position
  end; //nested Proc Pos2XY
  
  procedure TestPixel(lPos: integer);
  begin
       if (lMaskRA^[lPos]=kFillable) then begin
          lMaskRA^[lPos] := kFill;
          lQra^[lQHead] := lPos;
          incQra(lQHead,lQSz);
       end;
  end; //nested Proc TestPixel
  
  procedure RetirePixel; //nested inside FloodFill
  var
     lVal: integer;
     lXY : TPoint;
  begin
     lVal := lQra^[lQTail];
     lXY := Pos2XY(lVal);
     if lXY.Y > 1 then
          TestPixel (lVal-lWid);//pixel above
     if lXY.Y < lHt then
        TestPixel (lVal+lWid);//pixel below
     if lXY.X > 1 then
          TestPixel (lVal-1); //pixel to left
     if lXY.X < lWid then
        TestPixel (lVal+1); //pixel to right
     incQra(lQTail,lQSz); //done with this pixel
  end; //nested proc RetirePixel
  
var
   lTargetColorVal,lDefaultVal: byte;
   lX,lY,lPos: integer;
   lBrushColor: TColor;
begin //FloodFill
  if FillStyle = fsSurface then begin
     //fill only target color with brush - bounded by nontarget color.
     if Canvas.Pixels[X,Y] <> lColor then exit;
     lTargetColorVal := kFillable;
     lDefaultVal := kUnfillable;
  end else begin //fsBorder
      //fill non-target color with brush - bounded by target-color
     if Canvas.Pixels[X,Y] = lColor then exit;
     lTargetColorVal := kUnfillable;
     lDefaultVal := kFillable;
  end;
  //if (lPt < 1) or (lPt > lMaskSz) or (lMaskP[lPt] <> 128) then exit;
  lHt := Canvas.Height;
  lWid := Canvas.Width;
  lQSz := lHt * lWid;
  //Qsz should be more than the most possible simultaneously active pixels
  //Worst case scenario is a click at the center of a 3x3 image: all 9 pixels will be active simultaneously
  //for larger images, only a tiny fraction of pixels will be active at one instance.
  //perhaps lQSz = ((lHt*lWid) div 4) + 32; would be safe and more memory efficient
  if (lHt < 1) or (lWid < 1) then exit;
  getmem(lQra,lQSz*sizeof(longint)); //very wasteful -
  getmem(lMaskRA,lHt*lWid*sizeof(byte));
  for lPos := 1 to (lHt*lWid) do
      lMaskRA^[lPos] := lDefaultVal; //assume all voxels are non targets
  lPos := 0;
  // MG: it is very slow to access the whole (!) canvas with pixels
  for lY := 0 to (lHt-1) do
      for lX := 0 to (lWid-1) do begin
          lPos := lPos + 1;
          if Canvas.Pixels[lX,lY] = lColor then
             lMaskRA^[lPos] := lTargetColorVal;
      end;
  lQHead := 2;
  lQTail := 1;
  lQra^[lQTail] := ((Y * lWid)+X+1); //NOTE: both X and Y start from 0 not 1
  lMaskRA^[lQra^[lQTail]] := kFill;
  RetirePixel;
  while lQHead <> lQTail do
        RetirePixel;
  lBrushColor := Canvas.Brush.Color;
  lPos := 0;
  for lY := 0 to (lHt-1) do
      for lX := 0 to (lWid-1) do begin
          lPos := lPos + 1;
          if lMaskRA^[lPos] = kFill then
             Canvas.Pixels[lX,lY] := lBrushColor;
      end;
  freemem(lMaskRA);
  freemem(lQra);
end;

procedure ScaleImg(AImage: TCustomBitmap; AWidth, AHeight: Integer);
var
  srcImg: TLazIntfImage = nil;
  destCanvas: TLazCanvas = nil;
begin
  try
    // Create the source LazIntfImage
    srcImg := AImage.CreateIntfImage;
    // Create the destination LazCanvas
    destCanvas := TLazCanvas.Create(srcImg);
    // Execute the canvas.StretchDraw
    destCanvas.StretchDraw(0, 0, AWidth, AHeight, srcImg);
    // Reload the stretched image into the CustomBitmap
    AImage.LoadFromIntfImage(srcImg);
    AImage.SetSize(AWidth, AHeight);
  finally
    destCanvas.Free;
    srcImg.Free;
  end;
end;

procedure ColorRGBToHLS(clrRGB: COLORREF; var Hue, Luminance, Saturation: Word);
var
  H, L, S: Byte;
begin
  ColorToHLS(clrRGB, H, L, S);
  Hue := H;
  Luminance := L;
  Saturation := S;
end;

function ColorHLSToRGB(Hue, Luminance, Saturation: Word): TColorRef;
begin
  Result := HLStoColor(Hue, Luminance, Saturation);
end;

function ColorAdjustLuma(clrRGB: TColor; n: Integer; fScale: BOOL): TColor;
var
  H, L, S: Byte;
begin
  // what is fScale?
  ColorToHLS(clrRGB, H, L, S);
  Result := HLStoColor(H, L + n, S);
end;

function GetHighLightColor(const Color: TColor; Luminance: Integer): TColor;
begin
  Result := ColorAdjustLuma(Color, Luminance, False);
end;

function GetShadowColor(const Color: TColor; Luminance: Integer): TColor;
begin
  Result := ColorAdjustLuma(Color, Luminance, False);
end;

function NormalizeRect(const R: TRect): TRect;
begin
  if R.Left <= R.Right then
  begin
    Result.Left := R.Left;
    Result.Right := R.Right;
  end
  else
  begin
    Result.Left := R.Right;
    Result.Right := R.Left;
  end;

  if R.Top <= R.Bottom then
  begin
    Result.Top := R.Top;
    Result.Bottom := R.Bottom;
  end
  else
  begin
    Result.Top := R.Bottom;
    Result.Bottom := R.Top;
  end;
end;

procedure DrawVerticalGradient(Canvas: TCanvas; ARect: TRect; TopColor, BottomColor: TColor);
var
  y, h: Integer;
  r1, g1, b1: byte;
  r2, g2, b2: byte;
  dr, dg, db: integer;

 function GetColor(pos, total: integer): TColor;

   function GetComponent(c1, dc: integer): integer;
   begin
     Result := Round(dc / sqr(total) * sqr(pos) + c1);
   end;

 begin
   Result :=
     GetComponent(r1, dr) or
     (GetComponent(g1, dg) shl 8) or
     (GetComponent(b1, db) shl 16);
 end;

begin
  ExtractRGB(ColorToRGB(TopColor), r1, g1, b1);
  ExtractRGB(ColorToRGB(BottomColor), r2, g2, b2);
  dr := r2 - r1;
  dg := g2 - g1;
  db := b2 - b1;
  h := ARect.Bottom - ARect.Top;
  for y := ARect.Top to ARect.Bottom do
  begin
    Canvas.Pen.Color := GetColor(y - ARect.Top, h);
    Canvas.Line(ARect.Left, y, ARect.Right, y);
  end;
end;

procedure DrawGradientWindow(Canvas: TCanvas; WindowRect: TRect; TitleHeight: Integer; BaseColor: TColor);
begin
  Canvas.Brush.Color := BaseColor;
  Canvas.FrameRect(WindowRect);
  InflateRect(WindowRect, -1, -1);
  WindowRect.Bottom := WindowRect.Top + TitleHeight;
  DrawVerticalGradient(Canvas, WindowRect, GetHighLightColor(BaseColor), GetShadowColor(BaseColor));
end;

procedure AntiAliasedStretchDrawBitmap(SourceBitmap, DestBitmap: TCustomBitmap;
  DestWidth, DestHeight: integer);
var
  DestIntfImage, SourceIntfImage: TLazIntfImage;
  DestCanvas: TLazCanvas;
begin
  DestIntfImage := TLazIntfImage.Create(0, 0);
  try
    DestIntfImage.LoadFromBitmap(DestBitmap.Handle, DestBitmap.MaskHandle);
    DestCanvas := TLazCanvas.Create(DestIntfImage);
    try
      SourceIntfImage := SourceBitmap.CreateIntfImage;
      try
        DestCanvas.Interpolation := TFPBaseInterpolation.Create;
        try
          DestCanvas.StretchDraw(0, 0, DestWidth, DestHeight, SourceIntfImage);
          DestBitmap.LoadFromIntfImage(DestIntfImage);
        finally
          DestCanvas.Interpolation.Free;
        end;
      finally
        SourceIntfImage.Free;
      end;
    finally
      DestCanvas.Free;
    end;
  finally
    DestIntfImage.Free;
  end;
end;

{ Converts a bitmap to grayscale by taking filtering parameters into account

  Examples:
    BitmapGrayscale(Image1.Picture.Bitmap, 0.30, 0.59, 0.11);  // Neutral filter
    BitmapGrayscale(Image1.Picture.Bitmap, 1.00, 0.00, 0.00);  // Red filter
    BitmapGrayscale(Image1.Picture.Bitmap, 0.00, 1.00, 0.00);  // Green filter
    BitmapGrayscale(Image1.Picture.Bitmap, 0.00, 0.00, 1.00);  // Blue filter
    BitmapGrayscale(Image1.Picture.Bitmap, 0.00, 0.50, 0.50);  // Cyan filter
    BitmapGrayscale(Image1.Picture.Bitmap, 0.50, 0.00, 0.50);  // Magenta filter
    BitmapGrayscale(Image1.Picture.Bitmap, 0.50, 0.50, 0.00);  // Yellow filter
}
procedure BitmapGrayscale(ABitmap: TCustomBitmap; RedFilter, GreenFilter, BlueFilter: Single);
var
  IntfImg: TLazIntfImage = nil;
  x, y: Integer;
  TempColor: TFPColor;
  Gray: Word;
  sum: Single;
begin
  // Normalize filter factors to avoid word overflow.
  sum := RedFilter + GreenFilter + BlueFilter;
  if sum = 0.0 then
    exit;
  RedFilter := RedFilter / sum;
  GreenFilter := GreenFilter / sum;
  BlueFilter := BlueFilter / sum;

  IntfImg := ABitmap.CreateIntfImage;
  try
    IntfImg.BeginUpdate;
    try
      for y := 0 to IntfImg.Height - 1 do
        for x := 0 to IntfImg.Width - 1 do
        begin
          TempColor := IntfImg.Colors[x, y];
          Gray := word(Round(TempColor.Red * RedFilter + TempColor.Green * GreenFilter + TempColor.Blue * BlueFilter));
          TempColor.Red := Gray;
          TempColor.Green := Gray;
          TempColor.Blue := Gray;
          IntfImg.Colors[x, y] := TempColor;
        end;
    finally
      IntfImg.EndUpdate;
    end;
    ABitmap.LoadFromIntfImage(IntfImg);
  finally
    IntfImg.Free;
  end;
end;

procedure WaveTo(ADC: HDC; X, Y, R: Integer);
var
  Direction, Cur: Integer;
  PenPos, Dummy: TPoint;
begin
  dec(R);
  // get the current pos
  MoveToEx(ADC, 0, 0, @PenPos);
  MoveToEx(ADC, PenPos.X, PenPos.Y, @Dummy);

  Direction := 1;
  // vertical wave
  if PenPos.X = X then
  begin
    Cur := PenPos.Y;
    if Cur < Y then
      while (Cur < Y) do
      begin
        X := X + Direction * R;
        LineTo(ADC, X, Cur + R);
        Direction := -Direction;
        inc(Cur, R);
      end
    else
      while (Cur > Y) do
      begin
        X := X + Direction * R;
        LineTo(ADC, X, Cur - R);
        Direction := -Direction;
        dec(Cur, R);
      end;
  end
  else
  // horizontal wave
  begin
    Cur := PenPos.X;
    if (Cur < X) then
      while (Cur < X) do
      begin
        Y := Y + Direction * R;
        LineTo(ADC, Cur + R, Y);
        Direction := -Direction;
        inc(Cur, R);
      end
    else
      while (Cur > X) do
      begin
        Y := Y + Direction * R;
        LineTo(ADC, Cur - R, Y);
        Direction := -Direction;
        dec(Cur, R);
      end;
  end;
end;


function RGBtoRGBTriple(R, G, B: byte): TRGBTriple;
begin
  with Result do
  begin
    rgbtRed := R;
    rgbtGreen := G;
    rgbtBlue := B;
  end
end;

function RGBtoRGBQuad(R, G, B: byte): TRGBQuad;
begin
  with Result do
  begin
    rgbRed := R;
    rgbGreen := G;
    rgbBlue := B;
    rgbReserved := 0;
  end
end;

function RGBTripleToColor(RGBTriple: TRGBTriple): TColor;
begin
  Result := RGBTriple.rgbtBlue shl 16 + RGBTriple.rgbtGreen shl 8 + RGBTriple.rgbtRed;
end;


{ Assumes R, G, B to be in range 0..255. Calculates H, S, V in range 0..1
  From: http://axonflux.com/handy-rgb-to-hsl-and-rgb-to-hsv-color-model-c }
procedure RGBToHSV(R, G, B: Integer; out H, S, V: Double);
var
  rr, gg, bb: Double;
  cmax, cmin, delta: Double;
begin
  rr := R / 255;
  gg := G / 255;
  bb := B / 255;
  cmax := MaxValue([rr, gg, bb]);
  cmin := MinValue([rr, gg, bb]);
  delta := cmax - cmin;
  if delta = 0 then
  begin
    H := 0;
    S := 0;
  end else
  begin
    if cmax = rr then
      H := (gg - bb) / delta + IfThen(gg < bb, 6, 0)
    else if cmax = gg then
      H := (bb - rr) / delta + 2
    else if (cmax = bb) then
      H := (rr -gg) / delta + 4;
    H := H / 6;
    S := delta / cmax;
  end;
  V := cmax;
end;

procedure ColorToHSV(c: TColor; out H, S, V: Double);
begin
  RGBToHSV(GetRValue(c), GetGValue(c), GetBValue(c), H, S, V);
end;


{ Assumes H, S, V in the range 0..1 and calculates the R, G, B values which are
  returned to be in the range 0..255.
  From: http://axonflux.com/handy-rgb-to-hsl-and-rgb-to-hsv-color-model-c
}
procedure HSVtoRGB(H, S, V: Double; out R, G, B: Integer);
var
  i: Integer;
  f: Double;
  p, q, t: Double;

  procedure MakeRgb(rr, gg, bb: Double);
  begin
    R := Round(rr * 255);
    G := Round(gg * 255);
    B := Round(bb * 255);
  end;

begin
  i := floor(H * 6);
  f := H * 6 - i;
  p := V * (1 - S);
  q := V * (1 - f*S);
  t := V * (1 - (1 - f) * S);
  case i mod 6 of
    0: MakeRGB(V, t, p);
    1: MakeRGB(q, V, p);
    2: MakeRGB(p, V, t);
    3: MakeRGB(p, q, V);
    4: MakeRGB(t, p, V);
    5: MakeRGB(V, p, q);
    else MakeRGB(0, 0, 0);
  end;
end;

function HSVToColor(H, S, V: Double): TColor;
var
  r, g, b: Integer;
begin
  HSVtoRGB(H, S, V, r, g, b);
  Result := RgbToColor(r, g, b);
end;


procedure RGBToHSVRange(R, G, B: integer; out H, S, V: integer);
var
  Delta, Min, H1, S1: double;
begin
  Min := MinIntValue([R, G, B]);
  V := MaxIntValue([R, G, B]);
  Delta := V - Min;
  if V =  0.0 then S1 := 0 else S1 := Delta / V;
  if S1  = 0.0 then
    H1 := 0
  else
  begin
    if R = V then
      H1 := 60.0 * (G - B) / Delta
    else if G = V then
      H1 := 120.0 + 60.0 * (B - R) / Delta
    else if B = V then
      H1 := 240.0 + 60.0 * (R - G) / Delta;
    if H1 < 0.0 then H1 := H1 + 360.0;
  end;
  h := round(h1);
  s := round(s1*255);
end;

procedure HSVtoRGBRange(H, S, V: Integer; out R, G, B: Integer);
var
  t: TRGBTriple;
begin
  t := HSVtoRGBTriple(H, S, V);
  R := t.rgbtRed;
  G := t.rgbtGreen;
  B := t.rgbtBlue;
end;

function HSVtoRGBTriple(H, S, V: integer): TRGBTriple;
const
  divisor: integer = 255*60;
var
  f, hTemp, p, q, t, VS: integer;
begin
  if H > 360 then H := H - 360;
  if H < 0 then H := H + 360;
  if s = 0 then
    Result := RGBtoRGBTriple(V, V, V)
  else
  begin
    if H = 360 then hTemp := 0 else hTemp := H;
    f := hTemp mod 60;
    hTemp := hTemp div 60;
    VS := V*S;
    p := V - VS div 255;
    q := V - (VS*f) div divisor;
    t := V - (VS*(60 - f)) div divisor;
    case hTemp of
      0: Result := RGBtoRGBTriple(V, t, p);
      1: Result := RGBtoRGBTriple(q, V, p);
      2: Result := RGBtoRGBTriple(p, V, t);
      3: Result := RGBtoRGBTriple(p, q, V);
      4: Result := RGBtoRGBTriple(t, p, V);
      5: Result := RGBtoRGBTriple(V, p, q);
    else Result := RGBtoRGBTriple(0,0,0)
    end;
  end;
end;

function HSVtoRGBQuad(H, S, V: integer): TRGBQuad;
const
  divisor: integer = 255*60;
var
  f, hTemp, p, q, t, VS: integer;
begin
  if H > 360 then H := H - 360;
  if H < 0 then H := H + 360;
  if s = 0 then
    Result := RGBtoRGBQuad(V, V, V)
  else
  begin
    if H = 360 then hTemp := 0 else hTemp := H;
    f := hTemp mod 60;
    hTemp := hTemp div 60;
    VS := V*S;
    p := V - VS div 255;
    q := V - (VS*f) div divisor;
    t := V - (VS*(60 - f)) div divisor;
    case hTemp of
      0: Result := RGBtoRGBQuad(V, t, p);
      1: Result := RGBtoRGBQuad(q, V, p);
      2: Result := RGBtoRGBQuad(p, V, t);
      3: Result := RGBtoRGBQuad(p, q, V);
      4: Result := RGBtoRGBQuad(t, p, V);
      5: Result := RGBtoRGBQuad(V, p, q);
    else Result := RGBtoRGBQuad(0,0,0)
    end;
  end;
end;

function HSVRangeToColor(H, S, V: integer): TColor;
begin
  Result := RGBTripleToColor(HSVtoRGBTriple(H, S, V));
end;

function GetHValue(Color: TColor): integer;
var
  s, v: integer;
begin
  RGBToHSVRange(GetRValue(Color), GetGValue(Color), GetBValue(Color), Result, s, v);
end;

function GetSValue(Color: TColor): integer;
var
  h, v: integer;
begin
  RGBToHSVRange(GetRValue(Color), GetGValue(Color), GetBValue(Color), h, Result, v);
end;

function GetVValue(Color: TColor): integer;
var
  h, s: integer;
begin
  RGBToHSVRange(GetRValue(Color), GetGValue(Color), GetBValue(Color), h, s, Result);
end;


end.
