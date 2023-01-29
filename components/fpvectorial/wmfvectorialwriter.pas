{ A fpvectorial writer for wmf files.

  Documentation used:
  - http://msdn.microsoft.com/en-us/library/cc250370.aspx
  - http://wvware.sourceforge.net/caolan/ora-wmf.html
  - http://www.symantec.com/avcenter/reference/inside.the.windows.meta.file.format.pdf

  Coordinates:
  - wmf has y=0 at top, y grows downward (like with standard canvas).
  - fpv has y=0 at bottom and y grows upward if page.UseTopLeftCoordinates is
    false, or like wmf otherwise.

  Issues:
  - Text background is opaque although it should be transparent.
  - IrfanView cannot open the files written.
  - Text positioning incorrect due to positive/negative font heights.

  Author: Werner Pamler
}

{.$DEFINE WMF_DEBUG}

unit wmfvectorialwriter;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils,
  FPImage, FPCanvas,
  fpvectorial, fpvWMF;

type
  TParamArray = array of word;

  TWMFObjList = class(TFPList)
  public
    function Add(AData: Pointer): Integer;
    function FindBrush(ABrush: TvBrush): Word;
    function FindFont(AFont: TvFont): Word;
    function FindPen(APen: TvPen): Word;
  end;

  { TvWMFVectorialWriter }

  TvWMFVectorialWriter = class(TvCustomVectorialWriter)
  private
    // Headers
    FWMFHeader: TWMFHeader;
    FPlaceableHeader: TPlaceableMetaHeader;
    // list for WMF Objects
    FObjList: TWMFObjList;
    //
    FBBox: TRect;  // in metafile units as specified by UnitsPerInch. NOTE: "logical" units can be different!
    FLogicalMaxX: Word;        // Max x coordinate used for scaling, in logical units
    FLogicalMaxY: Word;        // Max y coordinate used for scaling, in logical units
    FScalingFactor: Double;    // Conversion fpvectorial units to logical units
    FMaxRecordSize: Int64;
    FCurrFont: TvFont;
    FCurrBrush: TvBrush;
    FCurrPen: TvPen;
    FCurrTextColor: TFPColor;
    FCurrTextAnchor: TvTextAnchor;
    FCurrBkMode: Word;
    {%H-}FCurrPolyFillMode: Word;
    FUseTopLeftCoordinates: Boolean;  // If true, input coordinates are given in top/left coordinate system.
    FPage: TvVectorialPage;
    FErrMsg: TStrings;

    function CalcChecksum: Word;
    procedure ClearObjList;
    function MakeWMFColorRecord(AColor: TFPColor): TWMFColorRecord;
    procedure PrepareScaling(APage: TvVectorialPage);
    function ScaleX(x: Double): Integer;
    function ScaleY(y: Double): Integer;
    function ScaleSizeX(x: Double): Integer;
    function ScaleSizeY(y: Double): Integer;

    procedure WriteBkColor(AStream: TStream; AColor: TFPColor);
    procedure WriteBkMode(AStream: TStream; AMode: Word);
    procedure WriteBrush(AStream: TStream; ABrush: TvBrush);
    procedure WriteCircle(AStream: TStream; ACircle: TvCircle);
    procedure WriteEllipse(AStream: TStream; AEllipse: TvEllipse);
    procedure WriteEOF(AStream: TStream);
    procedure WriteExtText(AStream: TStream; AText: TvText);
    procedure WriteFont(AStream: TStream; AFont: TvFont);
    procedure WriteLayer(AStream: TStream; ALayer: TvLayer);
    procedure WriteMapMode(AStream: TStream);
    procedure WritePageEntities(AStream: TStream; APage: TvVectorialPage);
    procedure WritePath(AStream: TStream; APath: TPath);
    procedure WritePen(AStream: TStream; APen: TvPen);
    procedure WritePolyFillMode(AStream: TStream; AValue: Word);
    procedure WritePolygon(AStream: TStream; APolygon: TvPolygon);
    procedure WriteRectangle(AStream: TStream; ARectangle: TvRectangle);
    procedure WriteText(AStream: TStream; AText: TvText);
    procedure WriteTextAlign(AStream: TStream; AAlign: Word);
    procedure WriteTextAnchor(AStream: TStream; AAnchor: TvTextAnchor);
    procedure WriteTextColor(AStream: TStream; AColor: TFPColor);
    procedure WriteWindowExt(AStream: TStream);
    procedure WriteWindowOrg(AStream: TStream);

    procedure WriteEntity(AStream: TStream; AEntity: TvEntity);
    procedure WriteWMFRecord(AStream: TStream; AFunc: word; ASize: Integer); overload;
    procedure WriteWMFRecord(AStream: TStream; AFunc: Word; const AParams; ASize: Integer);
    procedure WriteWMFParams(AStream: TStream; const AParams; ASize: Integer);

  protected
    procedure WritePage(AStream: TStream; {%H-}AData: TvVectorialDocument;
      APage: TvVectorialPage);

    procedure LogError(AMsg: String);

  public
    constructor Create; override;
    destructor Destroy; override;
    procedure WriteToStream(AStream: TStream; AData: TvVectorialDocument); override;
  end;

var
  // Settings
  gWMFVecReader_UseTopLeftCoords: Boolean = True;

implementation

uses
  Types, LazUTF8, LConvEncoding,
  Math,
  fpvUtils;

const
  ONE_INCH = 25.4;     // 1 inch = 25.4 mm
  SIZE_OF_WORD = 2;

type
  TWMFFont = class
    Font: TvFont;
  end;

  TWMFBrush = class
    Brush: TvBrush;
  end;

  TWMFPen = class
    Pen: TvPen;
  end;

  TWMFPalette = {%H-}class
    // not used, just needed as a filler in the ObjList
  end;

  TWMFRegion = {%H-}class
    // not used, just needed as a filler in the ObjList
  end;


function SameBrush(ABrush1, ABrush2: TvBrush): Boolean;
begin
  Result := (ABrush1.Color.Red = ABrush2.Color.Red) and
            (ABrush1.Color.Green = ABrush2.Color.Green) and
            (ABrush1.Color.Blue = ABrush2.Color.Blue) and
            (ABrush1.Style = ABrush2.Style);
end;

function SameFont(AFont1, AFont2: TvFont): Boolean;
const
  EPS = 1E-3;
begin
  Result := {(AFont1.Color.Red = AFont2.Color.Red) and
            (AFont1.Color.Green = AFont2.Color.Green) and
            (AFont1.Color.Blue = AFont2.Color.Blue) and }
            (AFont1.Size = AFont2.Size) and
            (UTF8Lowercase(AFont1.Name) = UTF8Lowercase(AFont2.Name)) and
            SameValue(AFont1.Orientation, AFont2.Orientation, EPS) and
            (AFont1.Bold = AFont2.Bold) and
            (AFont1.Italic = AFont2.Italic) and
            (AFont1.Underline = AFont2.Underline) and
            (AFont1.StrikeThrough = AFont2.StrikeThrough);
end;

function SamePen(APen1, APen2: TvPen): Boolean;
var
  i: Integer;
begin
  Result := (APen1.Color.Red = APen2.Color.Red) and
            (APen1.Color.Green = APen2.Color.Green) and
            (APen1.Color.Blue = APen2.Color.Blue) and
            (APen1.Style = APen2.Style) and
            (APen1.Width = APen2.Width) and
            (High(APen1.Pattern) = High(APen2.Pattern));
  if Result then
    for i:=0 to Length(APen1.Pattern) - 1 do
      if APen1.Pattern[i] <> APen2.Pattern[i] then begin
        Result := false;
        exit;
      end;
end;

function SamePoint(P1, P2: TWMFPointXYRecord): Boolean;
begin
  Result := (P1.X = P2.X) and (P1.Y = P2.Y);
end;


{ TWMFObjList }

function TWMFObjList.Add(AData: Pointer): Integer;
var
  i: Integer;
begin
  // Fill empty items first
  for i := 0 to Count-1 do
    if Items[i] = nil then begin
      Items[i] := AData;
      Result := i;
      exit;
    end;
  Result := inherited Add(AData);
end;

function TWMFObjList.FindBrush(ABrush: TvBrush): Word;
var
  i: Integer;
begin
  for i:=0 to Count-1 do
    if (TObject(Items[i]) is TWMFBrush) and SameBrush(ABrush, TWMFBrush(Items[i]).Brush)
    then begin
      Result := i;
      exit;
    end;
  Result := Word(-1);
end;

function TWMFObjList.FindFont(AFont: TvFont): Word;
var
  i: Integer;
begin
  for i:=0 to Count-1 do
    if (TObject(Items[i]) is TWMFFont) and SameFont(AFont, TWMFFont(Items[i]).Font)
    then begin
      Result := i;
      exit;
    end;
  Result := Word(-1);
end;

function TWMFObjList.FindPen(APen: TvPen): Word;
var
  i: Integer;
begin
  for i:=0 to Count-1 do
    if (TObject(Items[i]) is TWMFPen) and SamePen(APen, TWMFPen(Items[i]).Pen)
    then begin
      Result := i;
      exit;
    end;
  Result := Word(-1);
end;


{ TvWMFVectorialWriter }

constructor TvWMFVectorialWriter.Create;
begin
  inherited;
  FErrMsg := TStringList.Create;
  FObjList := TWMFObjList.Create;
  FCurrTextColor := colBlack;
  FCurrTextAnchor := vtaStart;
  with FCurrPen do begin
    Style := psClear;
    Color := colBlack;
    Width := -1;
  end;
  with FCurrBrush do begin
    Style := bsClear;
    Color := colBlack;
  end;
  with FCurrFont do begin
    Color := colBlack;
    Size := -1;
    Name := '';
    Orientation := 0;
    Bold := false;
    Italic := False;
    Underline := false;
    StrikeThrough := false;
  end;
  FCurrBkMode := BM_TRANSPARENT;
end;

destructor TvWMFVectorialWriter.Destroy;
begin
  ClearObjList;
  FObjList.Free;
  FErrMsg.Free;
  inherited;
end;

{ Calculate the checksum of the PlaceableHeader (without the Checksum field) }
function TvWMFVectorialWriter.CalcChecksum: Word;
var
  P: ^word;
  n: Integer;
begin
  Result := 0;
  P := @FPlaceableHeader;
  n := 0;
  while n < SizeOf(FPlaceableHeader) do begin
    Result := Result xor P^;
    inc(P);
    inc(n, SIZE_OF_WORD);
  end;
end;

procedure TvWMFVectorialWriter.ClearObjList;
var
  i: Integer;
begin
  for i:=0 to FObjList.Count-1 do
    TObject(FObjList[i]).Free;
  FObjList.Clear;
end;

procedure TvWMFVectorialWriter.LogError(AMsg: String);
begin
  FErrMsg.Add(AMsg);
end;

function TvWMFVectorialWriter.MakeWMFColorRecord(AColor: TFPColor): TWMFColorRecord;
begin
  Result.ColorRED := AColor.Red shr 8;
  Result.ColorGREEN := AColor.Green shr 8;
  Result.ColorBLUE := AColor.Blue shr 8;
  Result.Reserved := 0;
end;

procedure TvWMFVectorialWriter.PrepareScaling(APage: TvVectorialPage);
const
  MAXINT16 = 30000;   // should be 32767, but reduce to avoid overflows...
var
  maxx, maxy: Double;
  w, h: Double;
begin
  APage.CalculateDocumentSize;
  w := Max(APage.Width, APage.RealWidth);
  h := Max(APage.Height, APage.RealHeight);

  // fpv stores coordinates in millimeters, wmf in "logical units" where
  // 1 logical unit is 1/100 mm = 10 microns (in MM_HIMETRIC mode)
  FScalingFactor := round(ONE_INCH * 100);
  maxx := w * FScalingFactor;
  maxy := h * FScalingFactor;
  // wmf is 16 bit only! --> reduce magnification if numbers get too big
  if Max(maxx, maxy) > MAXINT16 then
  begin
    FScalingFactor := trunc(MAXINT16 / Max(w, h));
    maxx := APage.Width * FScalingFactor;
    maxy := APage.Height * FScalingFactor;
  end;
  FLogicalMaxX := trunc(maxx);
  FLogicalMaxY := trunc(maxy);
end;

{ Scaling routines which convert between fpv units (millimeters) and wmf units
  ("logical units"). We silently assume there there is no offset in origin. }
function TvWMFVectorialWriter.ScaleSizeX(x: Double): Integer;
begin
  Result := Round(x * FScalingFactor);
end;

function TvWMFVectorialWriter.ScaleSizeY(y: Double): Integer;
begin
  Result := Round(y * FScalingFactor);
end;

function TvWMFVectorialWriter.ScaleX(x: Double): Integer;
begin
  Result := ScaleSizeX(x);
end;

function TvWMFVectorialWriter.ScaleY(y: Double): Integer;
begin
  if FUseTopLeftCoordinates then
    Result := ScaleSizeY(y)
  else
    Result := FLogicalMaxY - ScaleSizeY(y);
end;

procedure TvWMFVectorialWriter.WriteBkColor(AStream: TStream; AColor: TFPColor);
var
  rec: TWMFColorRecord;
begin
  rec := MakeWMFColorRecord(AColor);
  WriteWMFRecord(AStream, META_SETBKCOLOR, rec, SizeOf(rec));
end;

procedure TvWMFVectorialWriter.WriteBkMode(AStream: TStream; AMode: Word);
var
  mode: DWord;
begin
  FCurrBkMode := AMode;
  if AMode in [BM_TRANSPARENT, BM_OPAQUE] then begin
    mode := AMode;
    WriteWMFRecord(AStream, META_SETBKMODE, mode, SizeOf(mode));
  end;
end;

procedure TvWMFVectorialWriter.WriteBrush(AStream: TStream; ABrush: TvBrush);
var
  rec: TWMFBrushRecord;
  idx: Word;
  wmfbrush: TWMFBrush;
  brushstyle: TFPBrushStyle;
begin
  if SameBrush(ABrush, FCurrBrush) then
    exit;

  idx := FObjList.FindBrush(ABrush);
  if idx = Word(-1) then begin
    // No gradient support by wmf --> use a clear brush instead.
    if ABrush.Kind <> bkSimpleBrush then
      brushstyle := bsClear else
      brushstyle := ABrush.Style;
    case brushstyle of
      bsClear      : rec.Style := BS_NULL;
      bsSolid      : rec.Style := BS_SOLID;
      bsHorizontal : begin rec.Style := BS_HATCHED; rec.Hatch := HS_HORIZONTAL; end;
      bsVertical   : begin rec.Style := BS_HATCHED; rec.Hatch := HS_VERTICAL; end;
      bsFDiagonal  : begin rec.Style := BS_HATCHED; rec.Hatch := HS_FDIAGONAL; end;
      bsBDiagonal  : begin rec.Style := BS_HATCHED; rec.Hatch := HS_BDIAGONAL; end;
      bsCross      : begin rec.Style := BS_HATCHED; rec.Hatch := HS_CROSS; end;
      bsDiagCross  : begin rec.Style := BS_HATCHED; rec.Hatch := HS_DIAGCROSS; end;
      { not supported
      BS_PATTERN = $0003;
      BS_INDEXED = $0004;
      BS_DIBPATTERN = $0005;
      BS_DIBPATTERNPT = $0006;
      BS_PATTERN8X8 = $0007;
      BS_DIBPATTERN8X8 = $0008;
      BS_MONOPATTERN = $0009; }
      else          rec.Style := BS_SOLID;
    end;
    rec.ColorRED := ABrush.Color.Red shr 8;
    rec.ColorGREEN := ABrush.Color.Green shr 8;
    rec.ColorBLUE := ABrush.Color.Blue shr 8;
    rec.Reserved := 0;
    wmfBrush := TWMFBrush.Create;
    wmfBrush.Brush := ABrush;
    idx := FObjList.Add(wmfBrush);
    WriteWMFRecord(AStream, META_CREATEBRUSHINDIRECT, rec, SizeOf(rec));
  end;
  WriteWMFRecord(AStream, META_SELECTOBJECT, idx, SizeOf(idx));

  FCurrBrush := ABrush;
end;

procedure TvWMFVectorialWriter.WriteCircle(AStream: TStream;
  ACircle: TvCircle);
var
  rec: TWMFRectRecord;
  c, r: TPoint;
begin
  WritePen(AStream, ACircle.Pen);
  WriteBrush(AStream, ACircle.Brush);
  c.x := ScaleX(ACircle.X);
  c.y := ScaleY(ACircle.Y);
  r.x := ScaleSizeX(ACircle.Radius);
  r.y := ScaleSizeY(ACircle.Radius);
  rec.Left := c.x - r.x;
  rec.Right := c.x + r.x;
  if FUseTopLeftCoordinates then begin
    rec.Top := c.y - r.y;
    rec.Bottom := c.y + r.y;
  end else
  begin
    rec.Top := c.y + r.y;
    rec.Bottom := c.y - r.y;
  end;

  // WMF record header + parameters
  WriteWMFRecord(AStream, META_ELLIPSE, rec, SizeOf(TWMFRectRecord));
end;

procedure TvWMFVectorialWriter.WriteEllipse(AStream: TStream;
  AEllipse: TvEllipse);
var
  r: TWMFRectRecord;
  path: TPath;
begin
  if AEllipse.Angle = 0 then
  begin
    WritePen(AStream, AEllipse.Pen);
    WriteBrush(AStream, AEllipse.Brush);

    r.Left := ScaleX(AEllipse.X - AEllipse.HorzHalfAxis);
    r.Top := ScaleY(AEllipse.Y + AEllipse.VertHalfAxis);
    r.Right := ScaleX(AEllipse.X + AEllipse.HorzHalfAxis);
    r.Bottom := ScaleY(AEllipse.Y - AEllipse.VertHalfAxis);

    // WMF record header + parameters
    WriteWMFRecord(AStream, META_ELLIPSE, r, SizeOf(TWMFRectRecord));
  end else
  begin
    // Write rotated ellipse as a path
    path := AEllipse.CreatePath;
    path.Pen := AEllipse.Pen;
    path.Brush := AEllipse.Brush;
    WritePath(AStream, path);
    path.Free;
  end;
end;


procedure TvWMFVectorialWriter.WriteEntity(AStream: TStream; AEntity: TvEntity);
begin
  if AEntity is TvPolygon then
    WritePolygon(AStream, TvPolygon(AEntity))
  else if AEntity is TvRectangle then
    WriteRectangle(AStream, TvRectangle(AEntity))
  else if AEntity is TvCircle then
    WriteCircle(AStream, TvCircle(AEntity))
  else if AEntity is TvEllipse then
    WriteEllipse(AStream, TvEllipse(AEntity))
  else if AEntity is TvText then
    WriteExtText(AStream, TvText(AEntity))
  else if AEntity is TPath then
    WritePath(AStream, TPath(AEntity));
end;

procedure TvWMFVectorialWriter.WriteEOF(AStream: TStream);
begin
  WriteWMFRecord(AStream, META_EOF, 0);
end;

procedure TvWMFVectorialWriter.WriteExtText(AStream: TStream; AText: TvText);
var
  s: String;
  rec: TWMFExtTextRecord;
  n, strLen, corrLen: Integer;
  brush: TvBrush;
  opts: Word;
begin
  brush := AText.Brush;
  opts := 0;
  if brush.Style <> bsClear then
  begin
    opts := opts or ETO_OPAQUE;
    WriteBkColor(AStream, brush.Color);
  end;
                    (*
  if (brush.Style = bsClear) and (FCurrBkMode = BM_OPAQUE) then
    WriteBkMode(AStream, BM_TRANSPARENT)
  else begin
    if FCurrBkMode = BM_TRANSPARENT then
      WriteBkMode(AStream, BM_OPAQUE);
    WriteBrush(AStream, AText.Brush);
  end;                *)

  WriteFont(AStream, AText.Font);

  if (AText.TextAnchor <> FCurrTextAnchor) then
    WriteTextAnchor(AStream, AText.TextAnchor);

  s := UTF8ToISO_8859_1(AText.Value.Text);
  strLen := Length(s);
  corrLen := strLen;
  if odd(corrLen) then begin
    s := s + #0;
    inc(corrLen);
  end;
  n := SizeOf(TWMFExtTextRecord) + corrLen;

  rec.X := ScaleX(AText.X);
  rec.Y := ScaleY(AText.Y);
  // No vertical offset required because text alignment is TA_BASELINE.
  rec.Options := opts;  // no clipping so far
  rec.Len := strLen;    // true string length

  WriteWMFRecord(AStream, META_EXTTEXTOUT, rec, n);
  AStream.Position := AStream.Position - corrLen;
  WriteWMFParams(AStream, s[1], corrLen);
end;

procedure TvWMFVectorialWriter.WriteFont(AStream: TStream; AFont: TvFont);
var
  rec: TWMFFontRecord;
  idx: Word;
  wmfFont: TWMFFont;
  fntName: String;
  n: Integer;
begin
  if (AFont.Color.Red <> FCurrTextColor.Red) or
     (AFont.Color.Green <> FCurrTextColor.Green) or
     (AFont.Color.Blue <> FCurrTextColor.Blue)
  then
    WriteTextColor(AStream, AFont.Color);

  if SameFont(AFont, FCurrFont) then
    exit;

  idx := FObjList.FindFont(AFont);
  if idx = Word(-1) then begin
    fntName := UTF8ToISO_8859_1(AFont.Name) + #0;
    if odd(UTF8Length(fntName)) then
      fntName := fntName + #0;
    if Length(fntName) > 32 then begin
      Delete(fntName, 31, MaxInt);
      fntName := fntName + #0;
    end;

    n := SizeOf(TWMFFontRecord) + Length(fntName);
    rec.Height := ScaleSizeY(AFont.Size);
    rec.Width := 0;
    rec.Orientation := round(AFont.Orientation * 10);
    rec.Escapement := round(AFont.Orientation * 10); // 0;
      // strange: must use "Escapement" here, not "Orientation".
      // Otherwise MS software will not show the rotated font.
    rec.Weight := IfThen(AFont.Bold, 700, 400);
    rec.Italic := IfThen(AFont.Italic, 1, 0);
    rec.Underline := IfThen(AFont.Underline, 1, 0);
    rec.Strikeout := IfThen(AFont.StrikeThrough, 1, 0);
    rec.Charset := DEFAULT_CHARSET;
    rec.OutPrecision := 0;  // default
    rec.ClipPrecision := 0; // default
    rec.Quality := 0; // default
    rec.PitchAndFamily := 0;  // don't care / default

    WriteWMFRecord(AStream, META_CREATEFONTINDIRECT, rec, n);
    AStream.Position := AStream.Position - Length(fntName);
    WriteWMFParams(AStream, fntName[1], Length(fntName));

    wmfFont := TWMFFont.Create;
    wmfFont.Font := AFont;
    idx := FObjList.Add(wmfFont);
  end;
  WriteWMFRecord(AStream, META_SELECTOBJECT, idx, SizeOf(idx));

  FCurrFont := AFont;
end;

procedure TvWMFVectorialWriter.WriteLayer(AStream: TStream; ALayer: TvLayer);
var
  entity: TvEntity;
  i: Integer;
begin
  for i := 0 to ALayer.GetEntitiesCount - 1 do
  begin
    entity := ALayer.GetEntity(i);
    WriteEntity(AStream, entity);
  end;
end;

procedure TvWMFVectorialWriter.WriteMapMode(AStream: TStream);
var
  mode: Word;
begin
  mode := MM_ANISOTROPIC;
  WriteWMFRecord(AStream, META_SETMAPMODE, mode, SizeOf(mode));
end;

procedure TvWMFVectorialWriter.WritePage(AStream: TStream;
  AData: TvVectorialDocument; APage: TvVectorialPage);
begin
  FPage := APage;
  WriteWindowExt(AStream);
  WriteWindowOrg(AStream);
  WriteMapMode(AStream);
  WriteBkColor(AStream, APage.BackgroundColor);
  WriteBkMode(AStream, BM_TRANSPARENT);
  WriteTextAlign(AStream, TA_BASELINE or TA_LEFT);

  WritePageEntities(AStream, APage);

  WriteEOF(AStream);
end;

procedure TvWMFVectorialWriter.WritePageEntities(AStream: TStream;
  APage: TvVectorialPage);
var
  entity: TvEntity;
  i: Integer;
begin
  for i := 0 to APage.GetEntitiesCount - 1 do
  begin
    entity := APage.GetEntity(i);
    WriteEntity(AStream, entity);
  end;
end;

procedure TvWMFVectorialWriter.WritePath(AStream: TStream; APath: TPath);
var
  points: TPointsArray = nil;     // array of TPoint
  pts: array of TWMFPointXYRecord = nil;
  polystarts: TIntegerDynArray = nil;
  allclosed: boolean;
  isClosed: Boolean;
  i, len: word;
  first, last: Integer;
  p, npoly, npts: Integer;
begin
  WritePen(AStream, APath.Pen);
  WriteBrush(AStream, APath.Brush);

  ConvertPathToPolygons(APath, 0, 0, FScalingFactor, FScalingFactor, points, polystarts);
  SetLength(pts, Length(points));
  for i:=0 to High(points) do begin
    pts[i].X := points[i].X;
    if FUseTopLeftCoordinates then
      pts[i].Y := points[i].Y
    else
      pts[i].Y := FLogicalMaxY - points[i].Y;
  end;

  allClosed := true;
  p := 0;
  while p < Length(polystarts) do begin
    first := polystarts[p];
    last := IfThen(p = High(polystarts), High(pts), polystarts[p+1]-1);
    isClosed := SamePoint(pts[first], pts[last]);
    if not isClosed then begin
      allClosed := false;
      break;
    end;
    inc(p);
  end;

  npoly := Length(polystarts);
  if allClosed and (Length(polystarts) > 1) then begin
    // "POLY-POLYGON"
    WriteWMFRecord(AStream, META_POLYPOLYGON,     // Prepare memory for ...
      SIZE_OF_WORD +                              // ... polygon count
      Length(polystarts) * SIZE_OF_WORD +         // ... point count per polygon
      Length(pts) * SizeOf(TWMFPointXYRecord)     // ... points
    );
    // Write polgon count
    WriteWMFParams(AStream, npoly, SIZE_OF_WORD);
    // Write number of points per polygon
    p := 0;
    while p < Length(polystarts) do begin
      first := polystarts[p];
      last := IfThen(p = High(polystarts), High(pts), polystarts[p+1]-1);
      npts := last - first + 1;
      WriteWMFParams(AStream, npts, SIZE_OF_WORD);
      inc(p);
    end;
    // Write points of each polygon
    p := 0;
    while p < Length(polystarts) do begin
      first := polystarts[p];
      last := IfThen(p = High(polystarts), High(pts), polystarts[p+1]-1);
      npts := last - first + 1;
      WriteWMFParams(AStream, pts[first], npts*SizeOf(TWMFPointXYRecord));
      inc(p);
    end;
  end else
  begin
    p := 0;
    while p < Length(polystarts) do begin
      first := polystarts[p];
      last := IfThen(p = High(polystarts), High(pts), polystarts[p+1]-1);
      len := last - first + 1;
      isClosed := SamePoint(pts[first], pts[last]);
      if isClosed and (APath.Brush.Kind = bkSimpleBrush) and (APath.Brush.Style <> bsClear) then
        WriteWMFRecord(AStream, META_POLYGON, SIZE_OF_WORD + len * SizeOf(TWMFPointXYRecord))
      else
        WriteWMFRecord(AStream, META_POLYLINE, SIZE_OF_WORD + len * SizeOf(TWMFPointXYRecord));
      WriteWMFParams(AStream, len, SIZE_OF_WORD);
      WriteWMFParams(AStream, pts[first], len * SizeOf(TWMFPointXYRecord));
      inc(p);
    end;
  end;
end;

procedure TvWMFVectorialWriter.WritePen(AStream: TStream; APen: TvPen);
var
  rec: TWMFPenRecord;
  idx: Word;
  wmfpen: TWMFPen;
begin
  if SamePen(APen, FCurrPen) then
    exit;

  idx := FObjList.FindPen(APen);
  if idx = Word(-1) then begin
    case APen.Style of
      psDash       : rec.Style := PS_DASH;
      psDot        : rec.Style := PS_DOT;
      psDashDot    : rec.Style := PS_DASHDOT;
      psDashDotDot : rec.Style := PS_DASHDOTDOT;
      psClear      : rec.Style := PS_NULL;
      psInsideFrame: rec.Style := PS_INSIDEFRAME;
      else           rec.Style := PS_SOLID;
    end;
    rec.Width := ScaleSizeX(APen.Width);
    rec.Ignored1 := 0;
    rec.ColorRED := APen.Color.Red shr 8;
    rec.ColorGREEN := APen.Color.Green shr 8;
    rec.ColorBLUE := APen.Color.Blue shr 8;
    rec.Ignored2 := 0;
    wmfPen := TWMFPen.Create;
    wmfPen.Pen := APen;
    idx := FObjList.Add(wmfPen);
    WriteWMFRecord(AStream, META_CREATEPENINDIRECT, rec, SizeOf(rec));
  end;
  WriteWMFRecord(AStream, META_SELECTOBJECT, idx, SizeOf(idx));

  FCurrPen := APen;
end;

procedure TvWMFVectorialWriter.WritePolyFillMode(AStream: TStream;
  AValue: Word);
begin
  WriteWMFRecord(AStream, META_SETPOLYFILLMODE, AValue, SizeOf(AValue));
end;

procedure TvWMFVectorialWriter.WritePolygon(AStream: TStream;
  APolygon: TvPolygon);
var
  pts: array of TWMFPointXYRecord = nil;
  i: Integer;
  w: Word;
begin
  case APolygon.WindingRule of
    vcmEvenOddRule        : WritePolyFillMode(AStream, ALTERNATE);
    vcmNonzeroWindingRule : WritePolyFillMode(AStream, WINDING);
  end;

  WritePen(AStream, APolygon.Pen);
  WriteBrush(AStream, APolygon.Brush);
  SetLength(pts, Length(APolygon.Points));
  for i:=0 to High(APolygon.Points) do begin
    pts[i].X := ScaleX(APolygon.Points[i].X);
    pts[i].Y := ScaleY(APolygon.Points[i].Y);
  end;

  // WMF Record header
  if (APolygon.Brush.Kind = bkSimpleBrush) and (APolygon.Brush.Style = bsClear) then
    WriteWMFRecord(AStream, META_POLYLINE, Length(pts) * SizeOf(TWMFPointXYRecord) + SIZE_OF_WORD)
  else
    WriteWMFRecord(AStream, META_POLYGON, Length(pts) * SizeOf(TWMFPointXYRecord) + SIZE_OF_WORD);

  // Number of points in polygon
  w := Length(APolygon.Points);
  WriteWMFParams(AStream, w, SIZE_OF_WORD);

  // Polygon points
  WriteWMFParams(AStream, pts[0], Length(pts) * SizeOf(TWMFPointXYRecord));
end;

procedure TvWMFVectorialWriter.WriteRectangle(AStream: TStream;
  ARectangle: TvRectangle);
var
  r: TWMFRectRecord;
  p: TWMFPointRecord;
  path: TPath;
begin
  WritePen(AStream, ARectangle.Pen);
  WriteBrush(AStream, ARectangle.Brush);
  r.Left := ScaleX(ARectangle.X);
  r.Top := ScaleY(ARectangle.Y);
  r.Right := ScaleX(ARectangle.X + ARectangle.CX);
  r.Bottom := ScaleY(ARectangle.Y - ARectangle.CY);

  if ARectangle.Angle = 0 then
  begin
    // WMF record header + parameters
    if (ARectangle.RX = 0) or (ARectangle.RY = 0) then
      // "normal" rectangle
      WriteWMFRecord(AStream, META_RECTANGLE, r, SizeOf(TWMFRectRecord))
    else begin
      // rounded rectangle
      p.X := ScaleSizeX(ARectangle.RX);
      p.Y := ScaleSizeY(ARectangle.RY);
      WriteWMFRecord(AStream, META_ROUNDRECT, SizeOf(p) + SizeOf(r));
      WriteWMFParams(AStream, p, SizeOf(p));
      WriteWMFParams(AStream, r, SizeOf(r));
    end;
  end else
  begin
    // Write rotated rectangle as a path
    path := ARectangle.CreatePath;
    path.Pen := ARectangle.Pen;
    path.Brush := ARectangle.Brush;
    WritePath(AStream, path);
    path.Free;
  end;
end;

procedure TvWMFVectorialWriter.WriteText(AStream: TStream; AText: TvText);
var
  s: String;
  strLen, corrLen: SmallInt;
  recSize: DWord;
  ptRec: TWMFPointRecord;
  brush: TvBrush;
begin
  brush := AText.Brush;
  if (brush.Style = bsClear) and (FCurrBkMode = BM_OPAQUE) then
    WriteBkMode(AStream, BM_TRANSPARENT)
  else begin
    if FCurrBkMode = BM_TRANSPARENT then
      WriteBkMode(AStream, BM_OPAQUE);
    WriteBrush(AStream, AText.Brush);
  end;

  WriteFont(AStream, AText.Font);

  if (AText.TextAnchor <> FCurrTextAnchor) then
    WriteTextAnchor(AStream, AText.TextAnchor);

  recSize := SizeOf(TWMFPointRecord);
  s := UTF8ToISO_8859_1(AText.Value.Text);
  strLen := Length(s);
  corrLen := strLen;
  if odd(corrLen) then
  begin
    s := s + #0;
    inc(corrLen);
  end;
  inc(recSize, SizeOf(corrLen) + corrLen);

  ptRec.X := ScaleX(AText.X);
  ptRec.Y := ScaleY(AText.Y);
  // No vertical font height offset required because fpv uses text alignment TA_BASELINE

  { The record structure is
    - TWMFRecord
    - Stringlength (SmallInt)
    - String, no trailing zero
    - y
    - x }
  WriteWMFRecord(AStream, META_TEXTOUT, recSize);
  WriteWMFParams(AStream, strLen, SizeOf(strLen));
  WriteWMFParams(AStream, s[1], corrLen);
  WriteWMFParams(AStream, ptRec, SizeOf(TWMFPointRecord));
end;

procedure TvWMFVectorialWriter.WriteTextAlign(AStream: TStream; AAlign: word);
begin
  WriteWMFRecord(AStream, META_SETTEXTALIGN, AAlign, SizeOf(AAlign));
end;

procedure TvWMFVectorialWriter.WriteTextAnchor(AStream: TStream;
  AAnchor: TvTextAnchor);
var
  align: DWord;
begin
  case AAnchor of
    vtaStart  : align := TA_LEFT;
    vtaMiddle : align := TA_CENTER;
    vtaEnd    : align := TA_RIGHT;
  end;
  align := align or TA_BASELINE;
  WriteTextAlign(AStream, align);
  FCurrTextAnchor := AAnchor;
end;

procedure TvWMFVectorialWriter.WriteTextColor(AStream: TStream;
  AColor: TFPColor);
var
  rec: TWMFColorRecord;
begin
  rec := MakeWMFColorRecord(AColor);
  WriteWMFRecord(AStream, META_SETTEXTCOLOR, rec, SizeOf(rec));
  FCurrTextColor := AColor;
end;

procedure TvWMFVectorialWriter.WriteToStream(AStream: TStream;
  AData: TvVectorialDocument);
const
  PAGE_INDEX = 0;
var
  page: TvVectorialPage;
begin
  // Initialize
  ClearObjList;
  FErrMsg.Clear;
  FWMFHeader.MaxRecordSize := 0;
  FBBox := Rect(0, 0, 0, 0);
  page := AData.GetPageAsVectorial(PAGE_INDEX);
  FUseTopLeftCoordinates := page.UseTopLeftCoordinates;

  // Prepare scaling
  PrepareScaling(page);

  // Write placeholder for WMF header and placeable header,
  // will be rewritten with correct values later
  AStream.Write(FWMFHeader, SizeOf(TWMFHeader));
  AStream.Write(FPlaceableHeader, SizeOf(TPlaceableMetaHeader));

  // Write the specified page of the document
  WritePage(AStream, AData, page);

  // Go back to the beginning of the file and write the headers. Use correct
  // header fields now.
  with FPlaceableHeader do begin
    Key := WMF_MAGIC_NUMBER;
    Handle := 0;
    Reserved := 0;
    Inch := ScaleX(ONE_INCH);
    Left := 0;
    Top := 0;
    Right := ScaleSizeX(page.Width);
    Bottom := ScaleSizeX(page.Height);
    Checksum := CalcChecksum;
  end;
  AStream.Position := 0;
  AStream.WriteBuffer(FPlaceableHeader, SizeOf(TPlaceableMetaHeader));

  with FWMFHeader do begin
    FileType := 1;
    HeaderSize := 9;
    Version := $0300;
    NumOfObjects := FObjList.Count;
    MaxRecordSize := FMaxRecordSize;
    FileSize := AStream.Size div SIZE_OF_WORD;
    NumOfParams := 0;
  end;
  AStream.WriteBuffer(FWMFHeader, SizeOf(TWMFHeader));

  if FErrMsg.Count > 0 then
    raise Exception.Create(FErrMsg.Text);
end;

procedure TvWMFVectorialWriter.WriteWindowExt(AStream: TStream);
var
  params: Array[0..1] of word;
begin
  params[0] := FLogicalMaxY;
  params[1] := FLogicalMaxX;
  WriteWMFRecord(AStream, META_SETWINDOWEXT, params, SizeOf(params));
end;

procedure TvWMFVectorialWriter.WriteWindowOrg(AStream: TStream);
var
  params: Array[0..1] of word;
begin
  params[0] := 0;
  params[1] := 0;
  WriteWMFRecord(AStream, META_SETWINDOWORG, params, Sizeof(params));
end;

{ ASize is in bytes }
procedure TvWMFVectorialWriter.WriteWMFRecord(AStream: TStream;
  AFunc: Word; ASize: Integer);
var
  rec: TWMFRecord;
begin
  rec.Size := (SizeOf(TWMFRecord) + ASize) div SIZE_OF_WORD;
  rec.Func := AFunc;
  AStream.WriteBuffer(rec, SizeOf(TWMFRecord));
  FMaxRecordSize := Max(FMaxRecordSize, rec.Size);
end;

{ ASize is the size of the parameter part, in bytes }
procedure TvWMFVectorialWriter.WriteWMFRecord(AStream: TStream;
  AFunc: Word; const AParams; ASize: Integer);
var
  rec: TWMFRecord;
begin
  rec.Size := (SizeOf(TWMFRecord) + ASize) div SIZE_OF_WORD;
  rec.Func := AFunc;
  AStream.WriteBuffer(rec, SizeOf(TWMFRecord));
  AStream.WriteBuffer(AParams, ASize);
end;

{ ASize is in bytes }
procedure TvWMFVectorialWriter.WriteWMFParams(AStream: TStream;
  const AParams; ASize: Integer);
begin
  AStream.WriteBuffer(AParams, ASize);
end;

initialization
  RegisterVectorialWriter(TvWMFVectorialWriter, vfWindowsMetafileWMF);

end.

