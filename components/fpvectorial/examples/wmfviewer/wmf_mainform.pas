unit wmf_mainform;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, Forms, Controls, Graphics, Dialogs, ShellCtrls,
  ExtCtrls, ComCtrls, StdCtrls, fpvectorial;

type

  { TForm1 }

  TForm1 = class(TForm)
    BtnSaveAsWMF: TButton;
    Image1: TImage;
    ImageList: TImageList;
    ImageInfo: TLabel;
    LeftPanel: TPanel;
    Panel1: TPanel;
    ImagePanel: TPanel;
    RbMaxSize: TRadioButton;
    RbOrigSize: TRadioButton;
    ScrollBox1: TScrollBox;
    ShellListView: TShellListView;
    ShellTreeView: TShellTreeView;
    Splitter1: TSplitter;
    Splitter2: TSplitter;
    procedure BtnSaveAsWMFClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure RbMaxSizeChange(Sender: TObject);
    procedure RbOrigSizeChange(Sender: TObject);
    procedure ScrollBox1Resize(Sender: TObject);
    procedure ShellListViewSelectItem(Sender: TObject; Item: TListItem;
      Selected: Boolean);
    procedure ShellTreeViewExpanded(Sender: TObject; Node: TTreeNode);
    procedure ShellTreeViewGetImageIndex(Sender: TObject; Node: TTreeNode);
    procedure ShellTreeViewGetSelectedIndex(Sender: TObject; Node: TTreeNode);
  private
    { private declarations }
    FVec: TvVectorialDocument;
    FFileName: String;
    procedure LoadImage(const AFileName: String);
    procedure PaintImage(APage: TvPage);
    procedure ReadFromIni;
    procedure WriteToIni;
  public
    { public declarations }
  end;

var
  Form1: TForm1;

implementation

{$R *.lfm}

uses
  IniFiles, LazFileUtils, fpvUtils;

const
  PROGRAM_NAME = 'wmfViewer';
  INCH = 25.4;


{ TForm1 }

procedure TForm1.BtnSaveAsWMFClick(Sender: TObject);
var
  fn: String;
begin
  if ShellListView.Selected = nil then
    exit;
  fn := ShellListview.GetPathFromItem(ShellListview.Selected);
  fn := ChangeFileExt(fn, '') + '-saved.wmf';
  if FileExistsUTF8(fn) then begin
    if MessageDlg(Format('File "%s" already exists. Overwrite?', [fn]),
      mtConfirmation, [mbYes, mbNo], 0) <> mrYes then exit;
    DeleteFileUTF8(fn);
  end;
  FVec.WriteToFile(fn, vfWindowsMetafileWMF);
  ShowMessage(Format('Saved as "%s"', [fn]));
end;

procedure TForm1.FormCreate(Sender: TObject);
begin
  // Set correct dpi for scaling by wmf reader
  ScreenDPIX := ScreenInfo.PixelsPerInchX;
  ScreenDPIY := ScreenInfo.PixelsPerInchY;

  Caption := PROGRAM_NAME;
  ShellListview.Mask := '*.svg;*.wmf';

  ReadFromIni;

  if ParamCount > 0 then begin
    ShellTreeview.Path := ExtractFilepath(ParamStr(1));
    ShellTreeview.MakeSelectionVisible;
    LoadImage(ParamStr(1));
  end;
end;

procedure TForm1.FormDestroy(Sender: TObject);
begin
  WriteToIni;
  FreeAndNil(FVec);
end;

procedure TForm1.LoadImage(const AFileName: String);
var
  page: TvPage;
begin
  FreeAndNil(FVec);
  try
    FVec := TvVectorialDocument.Create;
    // Load the image file into a TvVectorialDocument
    FVec.ReadFromFile(AFilename);
    // Draw the image
    FVec.GuessDocumentSize;
    page := FVec.GetPage(0);
    if (page.Width = 0) or (page.Height = 0) then
      page.CalculateDocumentSize;
    PaintImage(page);
    // Misc
    Caption := Format('%s - "%s"', [PROGRAM_NAME, AFileName]);
    ImageInfo.Caption := Format('%.0f x %.0f', [page.Width, page.Height]);
    FFileName := AFileName;
  except
    on E:Exception do
      MessageDlg(E.Message, mtError, [mbOK], 0);
  end;
end;

procedure TForm1.PaintImage(APage: TvPage);
var
  bmp: TBitmap;
  multiplierX, multiplierY: Double;
  wimg, himg: Integer;
  dx, dy: Integer;
  zoom: Double;
begin
  if APage = nil then
    exit;

  // For conversion of the mm returned by the wmf reader to screen pixels
  multiplierX := 1.0; //ScreenInfo.PixelsPerInchX / INCH;
  multiplierY := 1.0; //ScreenInfo.PixelsPerInchY / INCH;

  // Calc image size
  wimg := round(APage.Width * multiplierX);   // image size in pixels
  himg := round(APage.Height * multiplierY);
  if (wimg = 0) or (himg = 0) then
    exit;

  // Create a temporary bitmap onto which the image file will be drawn
  bmp := TBitmap.Create;
  try
    if RbMaxSize.Checked then begin
      if himg/wimg > Scrollbox1.ClientHeight / Scrollbox1.ClientWidth then
      begin
        bmp.Height := Scrollbox1.ClientHeight;
        bmp.Width := round(wimg/himg * bmp.Height);
        multiplierX := multiplierX * Scrollbox1.ClientHeight / himg;
        multiplierY := multiplierY * Scrollbox1.ClientHeight / himg;
      end else begin
        bmp.Width := Scrollbox1.ClientWidth;
        bmp.Height := round(himg/wimg * bmp.Width);
        multiplierX := multiplierX * Scrollbox1.ClientWidth / wimg;
        multiplierY := multiplierY * Scrollbox1.ClientWidth / wimg;
      end;
    end else begin
      bmp.SetSize(wimg, himg);
      multiplierX := 1.0;
      multiplierY := 1.0;
    end;

    bmp.Canvas.Brush.Color := clWindow;
    bmp.Canvas.FillRect(0, 0, bmp.Width, bmp.Height);

   // APage.AutoFit(bmp.Canvas, wimg, wimg, wimg, dx, dy, zoom);

    if APage.UseTopLeftCoordinates then
      APage.Render(bmp.Canvas, 0, 0, multiplierX, multiplierY) else
      APage.Render(bmp.Canvas, 0, himg, multiplierX, -multiplierY);

    {
    if APage.UseTopLeftCoordinates then
      APage.Render(bmp.Canvas, dx, dy, zoom, zoom) else
      APage.Render(bmp.Canvas, dx, himg - dy, zoom, -zoom);
      }

    {
    if SameText(ExtractFileExt(FFileName), '.wmf') then
      APage.Render(bmp.Canvas, dx, dy, zoom, zoom) else
      APage.Render(bmp.Canvas, dx, himg - dy, zoom, -zoom);
     }

//    APage.Render(bmp.Canvas, 0, 0, multiplierX, multiplierY);
    // Assign the bitmap to the image's picture.
    Image1.Picture.Assign(bmp);
    Image1.Width := bmp.Width;
    Image1.Height := bmp.Height;
  finally
    bmp.Free;
  end;
end;

procedure TForm1.RbMaxSizeChange(Sender: TObject);
begin
  if FVec <> nil then
    PaintImage(FVec.GetPage(0));
end;

procedure TForm1.RbOrigSizeChange(Sender: TObject);
begin
  if FVec <> nil then
    PaintImage(FVec.GetPage(0));
end;

procedure TForm1.ShellListViewSelectItem(Sender: TObject; Item: TListItem;
  Selected: Boolean);
var
  fn: String;
begin
  if Selected then
  begin
    fn := ShellListview.GetPathFromItem(ShellListview.Selected);
    ShellTreeview.MakeSelectionVisible;
    LoadImage(fn);
  end;
end;

procedure TForm1.ShellTreeViewExpanded(Sender: TObject; Node: TTreeNode);
begin
  ShellTreeView.AlphaSort;
end;

procedure TForm1.ShellTreeViewGetImageIndex(Sender: TObject; Node: TTreeNode);
begin
  if Node.Level = 0 then
    Node.ImageIndex := 2 else
    Node.ImageIndex := 0;
end;

procedure TForm1.ShellTreeViewGetSelectedIndex(Sender: TObject; Node: TTreeNode);
begin
  Node.SelectedIndex := 1;
end;

procedure TForm1.ReadFromIni;
var
  ini: TCustomIniFile;
  L, T, W, H: Integer;
  R: TRect;
begin
  ini := TMemIniFile.Create(ChangeFileExt(Application.ExeName, '.ini'));
  try
    L := ini.ReadInteger('MainForm', 'Left', Left);
    T := ini.ReadInteger('MainForm', 'Top', Top);
    W := ini.ReadInteger('MainForm', 'Width', Width);
    H := ini.ReadInteger('MainForm', 'Height', Height);
    R := Screen.DesktopRect;
    if L+W > R.Right then L := R.Right - W;
    if L < R.Left then L := R.Left;
    if T+H > R.Bottom then T := R.Bottom - H;
    if T < R.Top then T := R.Top;
    SetBounds(L, T, W, H);
    ShellTreeView.Height := ini.ReadInteger('MainForm', 'ShellTreeViewHeight', ShellTreeView.Height);
    LeftPanel.Width := ini.ReadInteger('MainForm', 'ShellControlsWidth', LeftPanel.Width);
    ShellTreeview.Path := ini.ReadString('Settings', 'InitialDir', '');
  finally
    ini.Free;
  end;
end;

procedure TForm1.ScrollBox1Resize(Sender: TObject);
begin
  if FVec <> nil then
    PaintImage(FVec.GetPage(0));
end;

procedure TForm1.WriteToIni;
var
  ini: TCustomIniFile;
begin
  ini := TMemIniFile.Create(ChangeFileExt(Application.ExeName, '.ini'));
  try
    if WindowState = wsNormal then begin
      ini.WriteInteger('MainForm', 'Left', Left);
      ini.WriteInteger('MainForm', 'Top', Top);
      ini.WriteInteger('MainForm', 'Width', Width);
      ini.WriteInteger('MainForm', 'Height', Height);
      ini.WriteInteger('MainForm', 'ShellTreeViewHeight', ShellTreeView.Height);
      ini.WriteInteger('MainForm', 'ShellControlsWidth', LeftPanel.Width);
    end;
    ini.WriteString('Settings', 'InitialDir', ShellTreeview.Path);
  finally
    ini.Free;
  end;
end;


end.

