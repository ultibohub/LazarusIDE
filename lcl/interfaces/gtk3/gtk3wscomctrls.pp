{
 *****************************************************************************
 *                             Gtk3WSComCtrls.pp                             *
 *                             -----------------                             * 
 *                                                                           *
 *                                                                           *
 *****************************************************************************

 *****************************************************************************
  This file is part of the Lazarus Component Library (LCL)

  See the file COPYING.modifiedLGPL.txt, included in this distribution,
  for details about the license.
 *****************************************************************************
}
unit Gtk3WSComCtrls;

{$mode objfpc}{$H+}
{$I gtk3defines.inc}

interface

uses
  // libs
  LazGtk3, LazGdk3, LazGlib2, LazGObject2, LazGdkPixbuf2,
  // RTL, FCL
  Types, Classes, Math, Sysutils,
  // LCL
  LCLType, Controls, Graphics, StdCtrls, ComCtrls, Forms,
  ImgList, InterfaceBase,
  // LazUtils
  LazLogger,
  // widgetset
  WSComCtrls, WSLCLClasses, WSControls, WSProc,
  gtk3widgets, gtk3int;
  
type
  { TGtk3WSCustomPage }

  TGtk3WSCustomPage = class(TWSCustomPage)
  published
    class function CreateHandle(const AWinControl: TWinControl;
      const AParams: TCreateParams): TLCLHandle; override;
    class function GetDefaultClientRect(const AWinControl: TWinControl;
            const aLeft, aTop, aWidth, aHeight: integer; var aClientRect: TRect
            ): boolean; override;
    class procedure SetBounds(const AWinControl:TWinControl; const ALeft,ATop,AWidth,AHeight:
      Integer); override;
    class procedure SetFont(const AWinControl:TWinControl; const AFont:TFont); override;
    class procedure ShowHide(const AWinControl: TWinControl); override;
    class procedure UpdateProperties(const ACustomPage: TCustomPage); override;
  end;

  { TGtk3WSCustomTabControl }

  TGtk3WSCustomTabControl = class(TWSCustomTabControl)
  published
    class function CreateHandle(const AWinControl: TWinControl;
                                const AParams: TCreateParams): TLCLHandle; override;
    class function GetDefaultClientRect(const AWinControl: TWinControl;
            const aLeft, aTop, aWidth, aHeight: integer; var aClientRect: TRect
            ): boolean; override;
    class procedure AddPage(const ATabControl: TCustomTabControl;
      const AChild: TCustomPage; const AIndex: integer); override;
    class procedure MovePage(const ATabControl: TCustomTabControl;
      const AChild: TCustomPage; const NewIndex: integer); override;
    class procedure RemovePage(const ATabControl: TCustomTabControl; const AIndex: integer); override;

    class function GetCapabilities: TCTabControlCapabilities; override;
    class function GetNotebookMinTabHeight(const AWinControl: TWinControl): integer; override;
    class function GetNotebookMinTabWidth(const AWinControl: TWinControl): integer; override;
    class function GetTabIndexAtPos(const ATabControl: TCustomTabControl; const AClientPos: TPoint): integer; override;
    class function GetTabRect(const ATabControl: TCustomTabControl; const AIndex: Integer): TRect; override;
    class procedure SetPageIndex(const ATabControl: TCustomTabControl; const AIndex: integer); override;
    class procedure SetTabCaption(const ATabControl: TCustomTabControl; const AChild: TCustomPage; const AText: string); override;
    class procedure SetTabPosition(const ATabControl: TCustomTabControl; const ATabPosition: TTabPosition); override;
    class procedure ShowTabs(const ATabControl: TCustomTabControl; AShowTabs: boolean); override;
    class procedure UpdateProperties(const ATabControl: TCustomTabControl); override;
  end;

  { TGtk3WSStatusBar }

  TGtk3WSStatusBar = class(TWSStatusBar)
  published
    class function CreateHandle(const AWinControl: TWinControl; const AParams: TCreateParams): TLCLHandle; override;
    class procedure PanelUpdate(const AStatusBar: TStatusBar; PanelIndex: integer); override;
    class procedure SetPanelText(const AStatusBar: TStatusBar; PanelIndex: integer); override;
    class procedure Update(const AStatusBar: TStatusBar); override;
    class procedure GetPreferredSize(const {%H-}AWinControl: TWinControl;
                        var {%H-}PreferredWidth, PreferredHeight: integer;
                        {%H-}WithThemeSpace: Boolean); override;

    class procedure SetSizeGrip(const AStatusBar: TStatusBar; {%H-}SizeGrip: Boolean); override;
  end;

  { TGtk3WSTabSheet }

  TGtk3WSTabSheet = class(TWSTabSheet)
  published
  end;

  { TGtk3WSPageControl }

  TGtk3WSPageControl = class(TWSPageControl)
  published
  end;

  { TGtk3WSCustomListView }

  TGtk3WSCustomListView = class(TWSCustomListView)
  private
    class procedure SetPropertyInternal(const ALV: TCustomListView; const AProp: TListViewProperty; const AIsSet: Boolean);
    class procedure AddRemoveCheckboxRenderer(const ALV: TCustomListView; const Add: Boolean);
  published
    // columns
    class procedure ColumnDelete(const ALV: TCustomListView; const AIndex: Integer); override;
    class function  ColumnGetWidth(const ALV: TCustomListView; const {%H-}AIndex: Integer; const AColumn: TListColumn): Integer; override;
    class procedure ColumnInsert(const ALV: TCustomListView; const AIndex: Integer; const AColumn: TListColumn); override;
    class procedure ColumnMove(const ALV: TCustomListView; const AOldIndex, ANewIndex: Integer; const {%H-}AColumn: TListColumn); override;
    class procedure ColumnSetAlignment(const ALV: TCustomListView; const AIndex: Integer; const {%H-}AColumn: TListColumn; const AAlignment: TAlignment); override;
    class procedure ColumnSetAutoSize(const ALV: TCustomListView; const AIndex: Integer; const {%H-}AColumn: TListColumn; const AAutoSize: Boolean); override;
    class procedure ColumnSetCaption(const ALV: TCustomListView; const AIndex: Integer; const {%H-}AColumn: TListColumn; const ACaption: String); override;
    class procedure ColumnSetImage(const ALV: TCustomListView; const {%H-}AIndex: Integer; const {%H-}AColumn: TListColumn; const {%H-}AImageIndex: Integer); override;
    class procedure ColumnSetMaxWidth(const ALV: TCustomListView; const AIndex: Integer; const {%H-}AColumn: TListColumn; const AMaxWidth: Integer); override;
    class procedure ColumnSetMinWidth(const ALV: TCustomListView; const AIndex: Integer; const {%H-}AColumn: TListColumn; const AMinWidth: integer); override;
    class procedure ColumnSetWidth(const ALV: TCustomListView; const AIndex: Integer; const {%H-}AColumn: TListColumn; const AWidth: Integer); override;
    class procedure ColumnSetVisible(const ALV: TCustomListView; const AIndex: Integer; const {%H-}AColumn: TListColumn; const AVisible: Boolean); override;
    class procedure ColumnSetSortIndicator(const ALV: TCustomListView; const AIndex: Integer;
      const AColumn: TListColumn; const ASortIndicator: TSortIndicator); override;

    // items
    class procedure ItemDelete(const ALV: TCustomListView; const AIndex: Integer); override;
    class function  ItemDisplayRect(const ALV: TCustomListView; const AIndex, ASubItem: Integer; {%H-}ACode: TDisplayCode): TRect; override;
    class procedure ItemExchange(const ALV: TCustomListView; {%H-}AItem: TListItem; const AIndex1, AIndex2: Integer); override;
    class procedure ItemMove(const ALV: TCustomListView; {%H-}AItem: TListItem; const AFromIndex, AToIndex: Integer); override;
    class function  ItemGetChecked(const {%H-}ALV: TCustomListView; const {%H-}AIndex: Integer; const AItem: TListItem): Boolean; override;
    class function  ItemGetState(const ALV: TCustomListView; const AIndex: Integer; const {%H-}AItem: TListItem; const AState: TListItemState; out AIsSet: Boolean): Boolean; override; // returns True if supported
    class procedure ItemInsert(const ALV: TCustomListView; const AIndex: Integer; const {%H-}AItem: TListItem); override;
    class procedure ItemSetChecked(const ALV: TCustomListView; const {%H-}AIndex: Integer; const {%H-}AItem: TListItem; const {%H-}AChecked: Boolean); override;
    class procedure ItemSetImage(const ALV: TCustomListView; const AIndex: Integer; const {%H-}AItem: TListItem; const {%H-}ASubIndex, AImageIndex: Integer); override;
    class procedure ItemSetState(const ALV: TCustomListView; const AIndex: Integer; const {%H-}AItem: TListItem; const AState: TListItemState; const AIsSet: Boolean); override;
    class procedure ItemSetText(const ALV: TCustomListView; const AIndex: Integer; const {%H-}AItem: TListItem; const {%H-}ASubIndex: Integer; const {%H-}AText: String); override;
    class procedure ItemShow(const ALV: TCustomListView; const AIndex: Integer; const {%H-}AItem: TListItem; const {%H-}PartialOK: Boolean); override;
    class function  ItemGetPosition(const ALV: TCustomListView; const AIndex: Integer): TPoint; override;
    class procedure ItemUpdate(const ALV: TCustomListView; const {%H-}AIndex: Integer; const {%H-}AItem: TListItem); override;

    // lv
    class function CreateHandle(const AWinControl: TWinControl; const AParams: TCreateParams): TLCLHandle; override;
    // class procedure DestroyHandle(const AWinControl: TWinControl); override;

    class procedure BeginUpdate(const ALV: TCustomListView); override;
    class procedure EndUpdate(const ALV: TCustomListView); override;

    class function GetBoundingRect(const ALV: TCustomListView): TRect; override;
    class function GetDropTarget(const ALV: TCustomListView): Integer; override;
    class function GetHoverTime(const ALV: TCustomListView): Integer; override;
    class function GetItemAt(const ALV: TCustomListView; x,y: integer): Integer; override;
    class function GetSelCount(const ALV: TCustomListView): Integer; override;
    class function GetSelection(const ALV: TCustomListView): Integer; override;
    class function GetTopItem(const ALV: TCustomListView): Integer; override;
    class function GetViewOrigin(const ALV: TCustomListView): TPoint; override;
    class function GetVisibleRowCount(const ALV: TCustomListView): Integer; override;

    class procedure SetAllocBy(const ALV: TCustomListView; const {%H-}AValue: Integer); override;
    class procedure SetDefaultItemHeight(const ALV: TCustomListView; const {%H-}AValue: Integer); override;
    class procedure SetHotTrackStyles(const ALV: TCustomListView; const {%H-}AValue: TListHotTrackStyles); override;
    class procedure SetHoverTime(const ALV: TCustomListView; const {%H-}AValue: Integer); override;
    //    class procedure SetIconOptions(const ALV: TCustomListView; const AValue: TIconOptions); override;
    class procedure SetImageList(const ALV: TCustomListView; const AList: TListViewImageList; const AValue: TCustomImageListResolution); override;
    class procedure SetItemsCount(const ALV: TCustomListView; const {%H-}Avalue: Integer); override;
    class procedure SetProperty(const ALV: TCustomListView; const AProp: TListViewProperty; const AIsSet: Boolean); override;
    class procedure SetProperties(const ALV: TCustomListView; const AProps: TListViewProperties); override;
    class procedure SetScrollBars(const ALV: TCustomListView; const AValue: TScrollStyle); override;
    class procedure SetSort(const ALV: TCustomListView; const {%H-}AType: TSortType; const {%H-}AColumn: Integer;
      const {%H-}ASortDirection: TSortDirection); override;
    class procedure SetViewOrigin(const ALV: TCustomListView; const AValue: TPoint); override;
    class procedure SetViewStyle(const ALV: TCustomListView; const AValue: TViewStyle); override;
  end;

  { TGtk3WSListView }

  TGtk3WSListView = class(TWSListView)
  published
  end;

  { TGtk3WSProgressBar }

  TGtk3WSProgressBar = class(TWSProgressBar)
  published
    class function CreateHandle(const AWinControl: TWinControl; const AParams: TCreateParams): TLCLHandle; override;
    class procedure ApplyChanges(const AProgressBar: TCustomProgressBar); override;
    class procedure SetPosition(const AProgressBar: TCustomProgressBar; const NewPosition: integer); override;
    class procedure SetStyle(const AProgressBar: TCustomProgressBar; const NewStyle: TProgressBarStyle); override;
  end;

  { TGtk3WSCustomUpDown }

  TGtk3WSCustomUpDown = class(TWSCustomUpDown)
  published
  end;

  { TGtk3WSUpDown }

  TGtk3WSUpDown = class(TWSUpDown)
  published
  end;

  { TGtk3WSToolButton }

  TGtk3WSToolButton = class(TWSToolButton)
  published
  end;

  { TGtk3WSToolBar }

  TGtk3WSToolBar = class(TWSToolBar)
  published
    class function CreateHandle(const AWinControl: TWinControl; const AParams: TCreateParams): TLCLHandle; override;
  end;

  { TGtk3WSTrackBar }

  TGtk3WSTrackBar = class(TWSTrackBar)
  published
    class function CreateHandle(const AWinControl: TWinControl; const AParams: TCreateParams): TLCLHandle; override;
    class procedure ApplyChanges(const ATrackBar: TCustomTrackBar); override;
    class function  GetPosition(const ATrackBar: TCustomTrackBar): integer; override;
    class procedure SetPosition(const ATrackBar: TCustomTrackBar; const NewPosition: integer); override;
    class procedure SetOrientation(const ATrackBar: TCustomTrackBar; const {%H-}AOrientation: TTrackBarOrientation); override;
  end;

  { TGtk3WSCustomTreeView }

  TGtk3WSCustomTreeView = class(TWSCustomTreeView)
  published
  end;

  { TGtk3WSTreeView }

  TGtk3WSTreeView = class(TWSTreeView)
  published
  end;


implementation
uses gtk3procs, Gtk3CellRenderer, gtk3objects;

{ TGtk3WSTrackBar }

class function TGtk3WSTrackBar.CreateHandle(const AWinControl: TWinControl;
  const AParams: TCreateParams): TLCLHandle;
var
  ATrack: TGtk3TrackBar;
  APt: TPoint;
begin
  ATrack := TGtk3TrackBar.Create(AWinControl, AParams);
  Result := TLCLHandle(ATrack);
end;

class procedure TGtk3WSTrackBar.ApplyChanges(const ATrackBar: TCustomTrackBar);
var
  ATrack: TGtk3TrackBar;
  APt: TPoint;
begin
  // inherited ApplyChanges(ATrackBar);
  if not WSCheckHandleAllocated(ATrackBar, 'ApplyChanges') then
    Exit;
  ATrack := TGtk3TrackBar(ATrackBar.Handle);
  APt.X := ATrackBar.Min;
  APt.Y := ATrackBar.Max;
  ATrack.BeginUpdate;
  ATrack.Range := APt;
  ATrack.Position:=ATrackBar.Position;
  ATrack.SetStep(ATrackBar.Frequency, ATrackBar.PageSize);
  ATrack.SetScalePos(ATrackBar.ScalePos);
  ATrack.SetTickMarks(ATrackbar.TickMarks, ATrackBar.TickStyle);
  ATrack.Reversed := ATrackBar.Reversed;
  ATrack.EndUpdate;
end;

class function TGtk3WSTrackBar.GetPosition(const ATrackBar: TCustomTrackBar
  ): integer;
begin
  if not WSCheckHandleAllocated(ATrackBar, 'GetPosition') then
    Exit(0);
  Result := TGtk3TrackBar(ATrackBar.Handle).Position;
end;

class procedure TGtk3WSTrackBar.SetPosition(const ATrackBar: TCustomTrackBar;
  const NewPosition: integer);
begin
  if not WSCheckHandleAllocated(ATrackBar, 'SetPosition') then
    Exit;
  TGtk3TrackBar(ATrackBar.Handle).BeginUpdate;
  TGtk3TrackBar(ATrackBar.Handle).Position := NewPosition;
  TGtk3TrackBar(ATrackBar.Handle).EndUpdate;
end;

class procedure TGtk3WSTrackBar.SetOrientation(
  const ATrackBar: TCustomTrackBar; const AOrientation: TTrackBarOrientation);
begin
  // inherited SetOrientation(ATrackBar, AOrientation);
  if not WSCheckHandleAllocated(ATrackBar, 'SetOrientation') then
    Exit;
  if TGtk3TrackBar(ATrackBar.Handle).GetTrackBarOrientation <> AOrientation then
    RecreateWnd(ATrackBar);
end;

{ TGtk3WSToolBar }

class function TGtk3WSToolBar.CreateHandle(const AWinControl: TWinControl;
  const AParams: TCreateParams): TLCLHandle;
var
  AToolBar: TGtk3CustomControl;
  // TGtk3ToolBar;
begin
  AToolBar := TGtk3CustomControl.Create(AWinControl, AParams);
  // TGtk3ToolBar.Create(AWinControl, AParams);
  Result := TLCLHandle(AToolBar);
end;

{ TGtk3WSProgressBar }

class function TGtk3WSProgressBar.CreateHandle(const AWinControl: TWinControl;
  const AParams: TCreateParams): TLCLHandle;
var
  AProgress: TGtk3ProgressBar;
begin
  AProgress := TGtk3ProgressBar.Create(AWinControl, AParams);
  Result := TLCLHandle(AProgress);
end;

class procedure TGtk3WSProgressBar.ApplyChanges(
  const AProgressBar: TCustomProgressBar);
begin
  // inherited ApplyChanges(AProgressBar);
  if not WSCheckHandleAllocated(AProgressBar, 'ApplyChanges') then
    Exit;
  TGtk3ProgressBar(AProgressBar.Handle).BeginUpdate;
  SetPosition(AProgressBar, AProgressBar.Position);
  SetStyle(AProgressBar, AProgressBar.Style);
  TGtk3ProgressBar(AProgressBar.Handle).ShowText := AProgressBar.BarShowText;
  TGtk3ProgressBar(AProgressBar.Handle).Orientation := AProgressBar.Orientation;
  TGtk3ProgressBar(AProgressBar.Handle).EndUpdate;
end;

class procedure TGtk3WSProgressBar.SetPosition(
  const AProgressBar: TCustomProgressBar; const NewPosition: integer);
begin
  if not WSCheckHandleAllocated(AProgressBar, 'SetPosition') then
    Exit;
  TGtk3ProgressBar(AProgressBar.Handle).BeginUpdate;
  TGtk3ProgressBar(AProgressBar.Handle).Position := NewPosition;
  TGtk3ProgressBar(AProgressBar.Handle).EndUpdate;
end;

class procedure TGtk3WSProgressBar.SetStyle(
  const AProgressBar: TCustomProgressBar; const NewStyle: TProgressBarStyle);
begin
  // inherited SetStyle(AProgressBar, NewStyle);
  if not WSCheckHandleAllocated(AProgressBar, 'SetStyle') then
    Exit;
  TGtk3ProgressBar(AProgressBar.Handle).BeginUpdate;
  TGtk3ProgressBar(AProgressBar.Handle).Style := NewStyle;
  TGtk3ProgressBar(AProgressBar.Handle).EndUpdate;
end;

{ TGtk3WSCustomListView }

type
  TLVHack = class(TCustomListView)
  end;
  TLVItemHack = class(TListItem)
  end;

class function TGtk3WSCustomListView.CreateHandle(
  const AWinControl: TWinControl; const AParams: TCreateParams): TLCLHandle;
var
  AListView: TGtk3ListView;
begin
  // DebugLn('TGtk3WSCustomListView.CreateHandle');
  AListView := TGtk3ListView.Create(AWinControl, AParams);
  if TLVHack(AWinControl).ViewStyle = vsSmallIcon then
  begin
    if Assigned(TLVHack(AWinControl).SmallImages) then
      AListView.setItemWidth(TLVHack(AWinControl).SmallImages.Width)
    else
      AListView.setItemWidth(0);
  end else
  if TLVHack(AWinControl).ViewStyle = vsIcon then
  begin
    if Assigned(TLVHack(AWinControl).LargeImages) then
      AListView.setItemWidth(TLVHack(AWinControl).LargeImages.Width)
    else
      AListView.setItemWidth(0);
  end;
  Result := TLCLHandle(AListView);
end;

procedure Gtk3_ItemCheckedChanged(renderer: PGtkCellRendererToggle; PathStr: Pgchar; aData: gPointer);cdecl;
var
  LV: TLVHack;
  Index: Integer;
  ListItem: TLVItemHack;
  R: TRect;
  x, y, cellw, cellh: gint;
  AMinSize, ANaturalSize: TGtkRequisition;
begin
  LV := TLVHack(TGtk3ListView(aData).LCLObject);
  Index := StrToInt(PathStr);
  ListItem := TLVItemHack(LV.Items.Item[Index]);
  if ListItem <> nil then
  begin
    ListItem.Checked := not ListItem.GetCheckedInternal;
    if Assigned(LV.OnItemChecked) then
      LV.OnItemChecked(TGtk3ListView(aData).LCLObject, LV.Items.Item[Index]);

    // we must update renderer row, otherwise visually it looks different
    // if we change toggle state by keyboard (eg. pressing Space key)
    R := ListItem.DisplayRect(drBounds);
    // ARect := GdkRectFromRect(R);

    gtk_cell_renderer_get_preferred_size(PGtkCellRenderer(renderer), TGtk3ListView(aData).getContainerWidget,
      @AMinSize, @ANaturalSize);
    with R do
      gtk_widget_queue_draw_area(TGtk3ListView(aData).getContainerWidget, Left, Top, ANaturalSize.width, ANaturalSize.height);
  end;
end;

procedure Gtk3WSLV_ListViewGetCheckedDataFunc({%H-}tree_column: PGtkTreeViewColumn;
  cell: PGtkCellRenderer; tree_model: PGtkTreeModel; iter: PGtkTreeIter; aData: gPointer); cdecl;
var
  APath: PGtkTreePath;
  ListItem: TLVItemHack;
begin
  gtk_tree_model_get(tree_model, iter, [0, @ListItem, -1]);

  if (ListItem = nil) and TCustomListView(TGtk3ListView(aData).LCLObject).OwnerData then
  begin
    APath := gtk_tree_model_get_path(tree_model,iter);
    ListItem := TLVItemHack(TCustomListView(TGtk3ListView(aData).LCLObject).Items[gtk_tree_path_get_indices(APath)^]);
    gtk_tree_path_free(APath);
  end;

  if ListItem = nil then
    Exit;
  gtk_cell_renderer_toggle_set_active(PGtkCellRendererToggle(cell), ListItem.GetCheckedInternal);
end;

procedure Gtk3WSLV_ListViewGetPixbufDataFuncForColumn(tree_column: PGtkTreeViewColumn;
  cell: PGtkCellRenderer; tree_model: PGtkTreeModel; iter: PGtkTreeIter; aData: gPointer); cdecl;
var
  ListItem: TListItem;
  Images: TFPList;
  ListColumn: TListColumn;
  ImageIndex: Integer;
  ColumnIndex: Integer;
  APath: PGtkTreePath;
  ImageList: TCustomImageList;
  Bmp: TBitmap;
  pixbuf: PGdkPixbuf;
  PixbufValue: TGValue;
begin
  PixbufValue:=Default(TGValue);
  g_value_init(@PixbufValue,  gdk_pixbuf_get_type());
  g_object_set_property(PgObject(cell), PChar('pixbuf'), @PixbufValue);

  gtk_tree_model_get(tree_model, iter, [0, @ListItem, -1]);

  ListColumn := TListColumn(g_object_get_data(PGObject(tree_column), 'TListColumn'));
  if ListColumn = nil then
  begin
    g_value_unset(@PixbufValue);
    Exit;
  end;
  ColumnIndex := ListColumn.Index;
  ImageList := nil;
  Images := TGtk3ListView(aData).Images;
  if TCustomListView(TGtk3ListView(aData).LCLObject).OwnerData then
    ImageList := TLVHack(TGtk3ListView(aData).LCLObject).SmallImages;
  if (Images = nil) and (ImageList = nil) then
  begin
    g_value_unset(@PixbufValue);
    Exit;
  end;
  ImageIndex := -1;

  if (ListItem = nil) and TCustomListView(TGtk3ListView(aData).LCLObject).OwnerData then
  begin
    APath := gtk_tree_model_get_path(tree_model,iter);
    ListItem := TCustomListView(TGtk3ListView(aData).LCLObject).Items[gtk_tree_path_get_indices(APath)^];
    gtk_tree_path_free(APath);
  end;

  if ListItem = nil then
  begin
    g_value_unset(@PixbufValue);
    Exit;
  end;

  if ColumnIndex = 0 then
    ImageIndex := ListItem.ImageIndex
  else
    if ColumnIndex -1 <= ListItem.SubItems.Count-1 then
      ImageIndex := ListItem.SubItemImages[ColumnIndex-1];

  if (ImageList <> nil) and
    (ImageIndex > -1) and (ImageIndex <= ImageList.Count-1) then
  begin
    Bmp := TBitmap.create;
    try
      pixbuf := nil;
      ImageList.GetBitmap(ImageIndex, Bmp);
      pixbuf := TGtk3Image(Bmp.Handle).Handle^.copy;
      if pixbuf <> nil then
      begin
        g_value_unset(@PixbufValue);
        g_value_init(@PixbufValue, gdk_pixbuf_get_type());
        g_value_set_object(@PixbufValue, pixbuf);
        g_object_set_property(PGObject(cell), PChar('pixbuf'), @PixbufValue);
      end;
    finally
      Bmp.Free;
    end;
  end;
  if (ImageIndex > -1) and (ImageIndex <= Images.Count-1) and (Images.Items[ImageIndex] <> nil) then
  begin
    Pixbuf := PGdkPixbuf(Images.Items[ImageIndex]);
    if Assigned(pixBuf) then
    begin
      g_value_set_object(@PixbufValue, pixbuf);
      g_object_set_property(PGObject(cell), PChar('pixbuf'), @PixbufValue);
    end;
  end;
  g_value_unset(@PixbufValue);
end;

class procedure TGtk3WSCustomListView.AddRemoveCheckboxRenderer(
  const ALV: TCustomListView; const Add: Boolean);
var
  togglerenderer,
  pixrenderer,
  textrenderer: PGtkCellRenderer;
  column: PGtkTreeViewColumn;
  aPath: PGtkTreePath;
  aRect: TGdkRectangle;
begin
  column := gtk_tree_view_get_column(PGtkTreeView(TGtk3ListView(ALV.Handle).GetContainerWidget), 0);

  if column = nil then
    Exit;
  PixRenderer := PGtkCellRenderer(g_object_get_data(PGObject(Column), 'pix_renderer'));
  TextRenderer := PGtkCellRenderer(g_object_get_data(PGObject(Column), 'text_renderer'));

  g_object_ref(pixrenderer);
  g_object_ref(textrenderer);

  if Add then
  begin
    column^.clear;
    togglerenderer := gtk_cell_renderer_toggle_new();

    column^.pack_start(togglerenderer, gtk_false);
    column^.pack_start(pixrenderer, gtk_false);
    column^.pack_start(textrenderer, gtk_true);

    column^.set_cell_data_func(togglerenderer, TGtkTreeCellDataFunc(@Gtk3WSLV_ListViewGetCheckedDataFunc), TGtk3ListView(ALV.Handle), nil);
    column^.set_cell_data_func(pixrenderer, TGtkTreeCellDataFunc(@Gtk3WSLV_ListViewGetPixbufDataFuncForColumn), TGtk3ListView(ALV.Handle), nil);
    column^.set_cell_data_func(textrenderer, TGtkTreeCellDataFunc(@LCLIntfCellRenderer_CellDataFunc), TGtk3ListView(ALV.Handle), nil);

    g_signal_connect_data(togglerenderer, 'toggled', TGCallback(@Gtk3_ItemCheckedChanged), TGtk3ListView(ALV.Handle), nil, G_CONNECT_DEFAULT);
  end else
  begin
    column^.clear;
    column^.pack_start(pixrenderer, gtk_false);
    column^.pack_start(textrenderer, gtk_true);

    column^.set_cell_data_func(pixrenderer, TGtkTreeCellDataFunc(@Gtk3WSLV_ListViewGetPixbufDataFuncForColumn), TGtk3ListView(ALV.Handle), nil);
    column^.set_cell_data_func(textrenderer, TGtkTreeCellDataFunc(@LCLIntfCellRenderer_CellDataFunc), TGtk3ListView(ALV.Handle), nil);

  end;
  if Gtk3IsObject(pixrenderer) then
    g_object_unref(pixrenderer);
  if Gtk3IsObject(textrenderer) then
    g_object_unref(textrenderer);
end;

class procedure TGtk3WSCustomListView.SetPropertyInternal(
  const ALV: TCustomListView; const AProp: TListViewProperty;
  const AIsSet: Boolean);
const
  BoolToSelectionMode: array[Boolean] of TGtkSelectionMode = (
    GTK_SELECTION_SINGLE {1} ,
    GTK_SELECTION_MULTIPLE {3}
  );
begin
  case AProp of
    lvpAutoArrange:
    begin
      // TODO: implement ??
    end;
    lvpCheckboxes:
    begin
      if TListView(ALV).ViewStyle in [vsReport,vsList] then
        AddRemoveCheckboxRenderer(ALV, AIsSet);
    end;
    lvpColumnClick:
    begin
      // allow only column modifications when in report mode
      if TListView(ALV).ViewStyle <> vsReport then Exit;
      if TGtk3ListView(ALV.Handle).IsTreeView then
        PGtkTreeView(TGtk3ListView(ALV.Handle).GetContainerWidget)^.set_headers_clickable(AIsSet);
    end;
    lvpFlatScrollBars:
    begin
      // TODO: implement ??
    end;
    lvpFullDrag:
    begin
      // TODO: implement ??
    end;
    lvpGridLines:
    begin
      // TODO: better implementation
      // maybe possible with some cellwidget hacking
      // this create rows with alternating colors
      if TGtk3ListView(ALV.Handle).IsTreeView then
      begin
        if AIsSet then
          PGtkTreeView(TGtk3ListView(ALV.Handle).GetContainerWidget)^.set_grid_lines(GTK_TREE_VIEW_GRID_LINES_BOTH)
        else
          PGtkTreeView(TGtk3ListView(ALV.Handle).GetContainerWidget)^.set_grid_lines(GTK_TREE_VIEW_GRID_LINES_NONE);
      end;
    end;
    lvpHideSelection:
    begin
      // TODO: implement
      // should be possible with some focus in/out events
    end;
    lvpHotTrack:
    begin
      // TODO: implement
      // should be possible with some mouse tracking
    end;
    lvpMultiSelect:
    begin
      if TGtk3ListView(ALV.Handle).IsTreeView then
        PGtkTreeView(TGtk3ListView(ALV.Handle).GetContainerWidget)^.get_selection^.set_mode(BoolToSelectionMode[AIsSet])
      else
        PGtkIconView(TGtk3ListView(ALV.Handle).GetContainerWidget)^.set_selection_mode(BoolToSelectionMode[AIsSet]);
    end;
    lvpOwnerDraw:
    begin
      // TODO: implement
      // use custom images/widgets ?
    end;
    lvpReadOnly:
    begin
      // TODO: implement inline editor ?
    end;
    lvpRowSelect:
    begin
      // TODO: implement ???
      // how to do cell select
    end;
    lvpShowColumnHeaders:
    begin
      if TGtk3ListView(ALV.Handle).IsTreeView then
      begin
        //Delphi docs: To use columns in a list view, the ViewStyle property must be set to vsReport.
        PGtkTreeView(TGtk3ListView(ALV.Handle).GetContainerWidget)^.set_headers_visible(AIsSet and (TLVHack(ALV).ViewStyle = vsReport));
        PGtkTreeView(TGtk3ListView(ALV.Handle).GetContainerWidget)^.resize_children;
      end;
    end;
    lvpShowWorkAreas:
    begin
      // TODO: implement ???
    end;
    lvpWrapText:
    begin
      // TODO: implement ???
    end;
    lvpToolTips:
    begin
     // TODO:
    end;
    else
      DebugLn(Format('WARNING: TGtk3WSCustomListView.SetPropertyInternal property %d not handled.',[Ord(AProp)]));
  end;
end;

class procedure TGtk3WSCustomListView.ColumnDelete(const ALV: TCustomListView;
  const AIndex: Integer);
begin
  if not WSCheckHandleAllocated(ALV, 'ColumnDelete') then
    Exit;
  // DebugLn('TGtk3WSCustomListView.ColumnDelete ');
  TGtk3ListView(ALV.Handle).ColumnDelete(AIndex);
end;

class function TGtk3WSCustomListView.ColumnGetWidth(const ALV: TCustomListView;
  const AIndex: Integer; const AColumn: TListColumn): Integer;
begin
  if not WSCheckHandleAllocated(ALV, 'ColumnGetWidth') then
    Exit;
  // DebugLn('TGtk3WSCustomListView.ColumnGetWidth ');
  Result := TGtk3ListView(ALV.Handle).ColumnGetWidth(AIndex);
end;

class procedure TGtk3WSCustomListView.ColumnInsert(const ALV: TCustomListView;
  const AIndex: Integer; const AColumn: TListColumn);
begin
  // DebugLn('TGtk3WSCustomListView.ColumnInsert ');
  if not WSCheckHandleAllocated(ALV, 'ColumnInsert') then
    Exit;
  TGtk3ListView(ALV.Handle).ColumnInsert(AIndex, AColumn);
  // inherited ColumnInsert(ALV, AIndex, AColumn);
end;

class procedure TGtk3WSCustomListView.ColumnMove(const ALV: TCustomListView;
  const AOldIndex, ANewIndex: Integer; const AColumn: TListColumn);
begin
  DebugLn('TGtk3WSCustomListView.ColumnMove ');
  // inherited ColumnMove(ALV, AOldIndex, ANewIndex, AColumn);
end;

class procedure TGtk3WSCustomListView.ColumnSetAlignment(
  const ALV: TCustomListView; const AIndex: Integer;
  const AColumn: TListColumn; const AAlignment: TAlignment);
begin
  if not WSCheckHandleAllocated(ALV, 'ColumnSetAlignment') then
    Exit;
  // DebugLn('TGtk3WSCustomListView.ColumnSetAlignment ');
  // inherited ColumnSetAlignment(ALV, AIndex, AColumn, AAlignment);
  TGtk3ListView(ALV.Handle).SetAlignment(AIndex, AColumn, AAlignment);
end;

class procedure TGtk3WSCustomListView.ColumnSetAutoSize(
  const ALV: TCustomListView; const AIndex: Integer;
  const AColumn: TListColumn; const AAutoSize: Boolean);
begin
  if not WSCheckHandleAllocated(ALV, 'ColumnSetAutoSize') then
    Exit;
  // DebugLn('TGtk3WSCustomListView.ColumnSetAutoSize ');
  TGtk3ListView(ALV.Handle).SetColumnAutoSize(AIndex, AColumn, AAutoSize);
  // inherited ColumnSetAutoSize(ALV, AIndex, AColumn, AAutoSize);
end;

class procedure TGtk3WSCustomListView.ColumnSetCaption(
  const ALV: TCustomListView; const AIndex: Integer;
  const AColumn: TListColumn; const ACaption: String);
begin
  if not WSCheckHandleAllocated(ALV, 'ColumnSetCaption') then
    Exit;
  // DebugLn('TGtk3WSCustomListView.ColumnSetCaption ');
  // inherited ColumnSetCaption(ALV, AIndex, AColumn, ACaption);
  TGtk3ListView(ALV.Handle).SetColumnCaption(AIndex, AColumn, ACaption);
end;

class procedure TGtk3WSCustomListView.ColumnSetImage(
  const ALV: TCustomListView; const AIndex: Integer;
  const AColumn: TListColumn; const AImageIndex: Integer);
begin
  // DebugLn('TGtk3WSCustomListView.ColumnSetImage ');
  // inherited ColumnSetImage(ALV, AIndex, AColumn, AImageIndex);
end;

class procedure TGtk3WSCustomListView.ColumnSetMaxWidth(
  const ALV: TCustomListView; const AIndex: Integer;
  const AColumn: TListColumn; const AMaxWidth: Integer);
begin
  if not WSCheckHandleAllocated(ALV, 'ColumnSetMaxWidth') then
    Exit;
  // DebugLn('TGtk3WSCustomListView.ColumnSetMaxWidth ');
  TGtk3ListView(ALV.Handle).SetColumnMaxWidth(AIndex, AColumn, AMaxWidth);
  // inherited ColumnSetMaxWidth(ALV, AIndex, AColumn, AMaxWidth);
end;

class procedure TGtk3WSCustomListView.ColumnSetMinWidth(
  const ALV: TCustomListView; const AIndex: Integer;
  const AColumn: TListColumn; const AMinWidth: integer);
begin
  if not WSCheckHandleAllocated(ALV, 'ColumnSetMinWidth') then
    Exit;
  // DebugLn('TGtk3WSCustomListView.ColumnSetMinWidth ');
  TGtk3ListView(ALV.Handle).SetColumnMinWidth(AIndex, AColumn, AMinWidth);
  // inherited ColumnSetMinWidth(ALV, AIndex, AColumn, AMinWidth);
end;

class procedure TGtk3WSCustomListView.ColumnSetWidth(
  const ALV: TCustomListView; const AIndex: Integer;
  const AColumn: TListColumn; const AWidth: Integer);
begin
  if not WSCheckHandleAllocated(ALV, 'ColumnSetWidth') then
    Exit;
  // DebugLn('TGtk3WSCustomListView.ColumnSetWidth ');
  // inherited ColumnSetWidth(ALV, AIndex, AColumn, AWidth);
  TGtk3ListView(ALV.Handle).SetColumnWidth(AIndex, AColumn, AWidth);
end;

class procedure TGtk3WSCustomListView.ColumnSetVisible(
  const ALV: TCustomListView; const AIndex: Integer;
  const AColumn: TListColumn; const AVisible: Boolean);
begin
  if not WSCheckHandleAllocated(ALV, 'ColumnSetVisible') then
    Exit;
  // DebugLn('TGtk3WSCustomListView.ColumnSetVisible ');
  // inherited ColumnSetVisible(ALV, AIndex, AColumn, AVisible);
  TGtk3ListView(ALV.Handle).SetColumnVisible(AIndex, AColumn, AVisible);
end;

class procedure TGtk3WSCustomListView.ColumnSetSortIndicator(
  const ALV: TCustomListView; const AIndex: Integer;
  const AColumn: TListColumn; const ASortIndicator: TSortIndicator);
begin
  if not WSCheckHandleAllocated(ALV, 'ColumnSetSortIndicator') then
    Exit;

  TGtk3ListView(ALV.Handle).ColumnSetSortIndicator(AIndex,AColumn,ASortIndicator);
end;




type
  TListItemHack = class(TListItem)
  end;

class procedure TGtk3WSCustomListView.ItemDelete(const ALV: TCustomListView;
  const AIndex: Integer);
begin
  if not WSCheckHandleAllocated(ALV, 'ItemDelete') then
    Exit;
  TGtk3ListView(ALV.Handle).ItemDelete(AIndex);
  // DebugLn('TGtk3WSCustomListView.ItemDelete ');
  // inherited ItemDelete(ALV, AIndex);
end;

class function TGtk3WSCustomListView.ItemDisplayRect(
  const ALV: TCustomListView; const AIndex, ASubItem: Integer;
  ACode: TDisplayCode): TRect;
begin
  //DebugLn('TGtk3WSCustomListView.ItemDisplayRect ');
  if not WSCheckHandleAllocated(ALV, 'ItemDisplayRect') then
    Exit;
  Result := TGtk3ListView(ALV.Handle).ItemDisplayRect(AIndex, ASubItem, ACode);
end;

class procedure TGtk3WSCustomListView.ItemExchange(const ALV: TCustomListView;
  AItem: TListItem; const AIndex1, AIndex2: Integer);
begin
  DebugLn('TGtk3WSCustomListView.ItemExchange ');
  // inherited ItemExchange(ALV, AItem, AIndex1, AIndex2);
end;

class procedure TGtk3WSCustomListView.ItemMove(const ALV: TCustomListView;
  AItem: TListItem; const AFromIndex, AToIndex: Integer);
begin
  DebugLn('TGtk3WSCustomListView.ItemMove ');
  // inherited ItemMove(ALV, AItem, AFromIndex, AToIndex);
end;

class function TGtk3WSCustomListView.ItemGetChecked(const ALV: TCustomListView;
  const AIndex: Integer; const AItem: TListItem): Boolean;
begin
  if not WSCheckHandleAllocated(ALV, 'ItemGetChecked') then
    Exit;
  // DebugLn('TGtk3WSCustomListView.ItemGetChecked ');
  Result := TListItemHack(AItem).GetCheckedInternal;
end;

class function TGtk3WSCustomListView.ItemGetState(const ALV: TCustomListView;
  const AIndex: Integer; const AItem: TListItem; const AState: TListItemState;
  out AIsSet: Boolean): Boolean;
begin
  if not WSCheckHandleAllocated(ALV, 'ItemGetState') then
    Exit;
  // DebugLn('TGtk3WSCustomListView.ItemGetState ');
  Result := TGtk3ListView(ALV.Handle).ItemGetState(AIndex, AItem, AState, AIsSet);
end;

class procedure TGtk3WSCustomListView.ItemInsert(const ALV: TCustomListView;
  const AIndex: Integer; const AItem: TListItem);
begin
  if not WSCheckHandleAllocated(ALV, 'ItemInsert') then
    Exit;
  // DebugLn('TGtk3WSCustomListView.ItemInsert ');
  TGtk3ListView(ALV.Handle).ItemInsert(AIndex, AItem);
end;

class procedure TGtk3WSCustomListView.ItemSetChecked(
  const ALV: TCustomListView; const AIndex: Integer; const AItem: TListItem;
  const AChecked: Boolean);
begin
  if not WSCheckHandleAllocated(ALV, 'ItemSetChecked') then
    Exit;
  // not needed
  // DebugLn('TGtk3WSCustomListView.ItemSetChecked ');
  // inherited ItemSetChecked(ALV, AIndex, AItem, AChecked);
end;

class procedure TGtk3WSCustomListView.ItemSetImage(const ALV: TCustomListView;
  const AIndex: Integer; const AItem: TListItem; const ASubIndex,
  AImageIndex: Integer);
begin
  if not WSCheckHandleAllocated(ALV, 'ItemSetImage') then
    Exit;
  TGtk3ListView(ALV.Handle).BeginUpdate;
  TGtk3ListView(ALV.Handle).ItemSetImage(AIndex,ASubIndex, AItem);
  TGtk3ListView(ALV.Handle).EndUpdate;
end;

class procedure TGtk3WSCustomListView.ItemSetState(const ALV: TCustomListView;
  const AIndex: Integer; const AItem: TListItem; const AState: TListItemState;
  const AIsSet: Boolean);
begin
  if not WSCheckHandleAllocated(ALV, 'ItemSetState') then
    Exit;
   // DebugLn('TGtk3WSCustomListView.ItemSetState ');
  // inherited ItemSetState(ALV, AIndex, AItem, AState, AIsSet);
  TGtk3ListView(ALV.Handle).BeginUpdate;
  TGtk3ListView(ALV.Handle).ItemSetState(AIndex, AItem, AState, AIsSet);
  TGtk3ListView(ALV.Handle).EndUpdate;
end;

class procedure TGtk3WSCustomListView.ItemSetText(const ALV: TCustomListView;
  const AIndex: Integer; const AItem: TListItem; const ASubIndex: Integer;
  const AText: String);
begin
  if not WSCheckHandleAllocated(ALV, 'ItemSetText') then
    Exit;
  // DebugLn('TGtk3WSCustomListView.ItemSetText ');
  TGtk3ListView(ALV.Handle).ItemSetText(AIndex, ASubIndex, AItem, AText);
end;

class procedure TGtk3WSCustomListView.ItemShow(const ALV: TCustomListView;
  const AIndex: Integer; const AItem: TListItem; const PartialOK: Boolean);
begin
  // DebugLn('TGtk3WSCustomListView.ItemShow ');
  // inherited ItemShow(ALV, AIndex, AItem, PartialOK);
  if ALV.HandleAllocated then
  begin
    //TODO: Hide/Show items
    if not PartialOk then
      TGtk3ListView(ALV.Handle).ScrollToRow(AIndex);
  end;
end;

class function TGtk3WSCustomListView.ItemGetPosition(
  const ALV: TCustomListView; const AIndex: Integer): TPoint;
begin
  //DebugLn('TGtk3WSCustomListView.ItemGetPosition ');
  Result := Point(-1, -1); // inherited ItemGetPosition(ALV, AIndex);
  if ALV.HandleAllocated then
    Result := TGtk3ListView(ALV.Handle).ItemPosition(AIndex);
end;

class procedure TGtk3WSCustomListView.ItemUpdate(const ALV: TCustomListView;
  const AIndex: Integer; const AItem: TListItem);
begin
  DebugLn('TGtk3WSCustomListView.ItemUpdate ');
  // inherited ItemUpdate(ALV, AIndex, AItem);
end;

class procedure TGtk3WSCustomListView.BeginUpdate(const ALV: TCustomListView);
begin
  // inherited BeginUpdate(ALV);
  DebugLn('TGtk3WSCustomListView.BeginUpdate ');
end;

class procedure TGtk3WSCustomListView.EndUpdate(const ALV: TCustomListView);
begin
  // inherited EndUpdate(ALV);
  DebugLn('TGtk3WSCustomListView.EndUpdate ');
end;

class function TGtk3WSCustomListView.GetBoundingRect(const ALV: TCustomListView
  ): TRect;
begin
  DebugLn('TGtk3WSCustomListView.GetBoundingRect ');
  Result := Rect(0, 0, 0, 0);
  if ALV.HandleAllocated then
    Result := TGtk3ListView(ALV.handle).getClientBounds;
end;

class function TGtk3WSCustomListView.GetDropTarget(const ALV: TCustomListView
  ): Integer;
begin
  DebugLn('TGtk3WSCustomListView.GetDropTarget ');
  Result := -1;
end;

class function TGtk3WSCustomListView.GetHoverTime(const ALV: TCustomListView
  ): Integer;
begin
  DebugLn('TGtk3WSCustomListView.GetHoverTime ');
  Result := 0;
end;

class function TGtk3WSCustomListView.GetItemAt(const ALV: TCustomListView; x,
  y: integer): Integer;
var
  ItemPath: PGtkTreePath;
  Column: PGtkTreeViewColumn;
  cx, cy: gint;
begin
  Result := -1;
  if not WSCheckHandleAllocated(ALV, 'GetItemAt') then
    Exit;
  if TGtk3ListView(ALV.Handle).IsTreeView then
  begin
    //PGtkTreeView(TGtk3ListView(ALV.Handle).GetContainerWidget)^.get_bin_window^.get_position(@cx, @cy);
    //Dec(x, cx);
    //Dec(y, cy);
    ItemPath := nil;
    Column := nil;
    if PGtkTreeView(TGtk3ListView(ALV.Handle).GetContainerWidget)^.get_path_at_pos(x, y, @ItemPath, @Column, nil, nil) then
    begin
      if ItemPath <> nil then
      begin
        Result := gtk_tree_path_get_indices(ItemPath)^;
        gtk_tree_path_free(ItemPath);
      end;
    end;
  end else
  begin
    ItemPath := PGtkIconView(TGtk3ListView(ALV.Handle).GetContainerWidget)^.get_path_at_pos(x, y);
    if ItemPath <> nil then
    begin
      Result := gtk_tree_path_get_indices(ItemPath)^;
      gtk_tree_path_free(ItemPath);
    end;
  end;
end;

class function TGtk3WSCustomListView.GetSelCount(const ALV: TCustomListView
  ): Integer;
begin
  DebugLn('TGtk3WSCustomListView.GetSelCount ');
  Result := 0;
end;

class function TGtk3WSCustomListView.GetSelection(const ALV: TCustomListView
  ): Integer;
begin
  DebugLn('TGtk3WSCustomListView.GetSelection ');
  Result := -1;
end;

class function TGtk3WSCustomListView.GetTopItem(const ALV: TCustomListView
  ): Integer;
begin
  DebugLn('TGtk3WSCustomListView.GetTopItem ');
  Result := 0;
end;

class function TGtk3WSCustomListView.GetViewOrigin(const ALV: TCustomListView
  ): TPoint;
begin
  // DebugLn('TGtk3WSCustomListView.GetViewOrigin ');

  Result := Point(0, 0);
  if ALV.HandleAllocated then
  begin
    Result := Point(Round(TGtk3ListView(ALV.Handle).getHorizontalScrollbar^.get_value),
      Round(TGtk3ListView(ALV.Handle).getVerticalScrollbar^.get_value));
  end;
end;

class function TGtk3WSCustomListView.GetVisibleRowCount(
  const ALV: TCustomListView): Integer;
begin
  DebugLn('TGtk3WSCustomListView.GetVisibleRowCount ');
  Result := 0;
  // Result:=inherited GetVisibleRowCount(ALV);
end;

class procedure TGtk3WSCustomListView.SetAllocBy(const ALV: TCustomListView;
  const AValue: Integer);
begin
  // DebugLn('TGtk3WSCustomListView.SetAllocBy ');
  // inherited SetAllocBy(ALV, AValue);
end;

class procedure TGtk3WSCustomListView.SetDefaultItemHeight(
  const ALV: TCustomListView; const AValue: Integer);
begin
  if not WSCheckHandleAllocated(ALV, 'SetDefaultItemHeight') then
    Exit;
  // DebugLn('TGtk3WSCustomListView.SetDefaultItemHeight ',dbgs(AValue));
  if TGtk3ListView(ALV.Handle).IsTreeView then
    PGtkTreeView(TGtk3ListView(ALV.Handle).GetContainerWidget)^.set_fixed_height_mode(AValue > 0);
end;

class procedure TGtk3WSCustomListView.SetHotTrackStyles(
  const ALV: TCustomListView; const AValue: TListHotTrackStyles);
begin
  // DebugLn('TGtk3WSCustomListView.SetHotTrackStyles ');
  // inherited SetHotTrackStyles(ALV, AValue);
end;

class procedure TGtk3WSCustomListView.SetHoverTime(const ALV: TCustomListView;
  const AValue: Integer);
begin
  // DebugLn('TGtk3WSCustomListView.SetHoverTime ');
  // inherited SetHoverTime(ALV, AValue);
end;

class procedure TGtk3WSCustomListView.SetImageList(const ALV: TCustomListView;
  const AList: TListViewImageList; const AValue: TCustomImageListResolution);
var
  BitImage: TBitmap;
  pixbuf: PGDKPixBuf;
  i: Integer;
  pixrenderer: PGtkCellRenderer;
  AColumn: PGtkTreeViewColumn;
begin
  if not WSCheckHandleAllocated(ALV, 'SetImageList') then
    exit;

  TGtk3ListView(ALV.Handle).GetContainerWidget^.realize;
  TGtk3ListView(ALV.Handle).GetContainerWidget^.queue_draw;

  if ((AList = lvilLarge) and (TLVHack(ALV).ViewStyle = vsIcon)) or
     ((AList = lvilSmall) and (TLVHack(ALV).ViewStyle <> vsIcon)) then
  begin
    if TGtk3ListView(ALV.Handle).Images <> nil then
      TGtk3ListView(ALV.Handle).ClearImages;
    if AValue = nil then
      exit;

    if TGtk3ListView(ALV.Handle).Images = nil then
      TGtk3ListView(ALV.Handle).Images := TFPList.Create;

    if (AValue.Count = 0) and TGtk3ListView(ALV.Handle).IsTreeView and (TLVHack(ALV).Columns.Count > 0) and
      not TLVHack(ALV).OwnerDraw then
    begin
      AColumn := PGtkTreeView(TGtk3ListView(ALV.Handle).GetContainerWidget)^.get_column(0);
      PixRenderer := PGtkCellRenderer(g_object_get_data(PgObject(AColumn), 'pix_renderer'));
      PixRenderer^.set_fixed_size(AValue.Width + 2, AValue.Height + 2);
      AColumn^.queue_resize;
    end;
    if TLVHack(ALV).ViewStyle in [vsSmallIcon, vsIcon] then
      TGtk3ListView(ALV.Handle).setItemWidth(AValue.Width);

    for i := 0 to AValue.Count-1 do
    begin
      pixbuf := nil;
      BitImage := TBitmap.Create;
      try
        AValue.GetBitmap(i, BitImage);
        pixbuf := TGtk3Image(BitImage.Handle).Handle^.copy;
        TGtk3ListView(ALV.Handle).Images.Add(pixbuf);
      finally
        BitImage.Free;
      end;
    end;
  end;
end;

class procedure TGtk3WSCustomListView.SetItemsCount(const ALV: TCustomListView;
  const Avalue: Integer);
begin
  DebugLn('TGtk3WSCustomListView.SetItemsCount ');
  // inherited SetItemsCount(ALV, Avalue);
end;

class procedure TGtk3WSCustomListView.SetProperty(const ALV: TCustomListView;
  const AProp: TListViewProperty; const AIsSet: Boolean);
begin
  if not WSCheckHandleAllocated(ALV, 'SetProperty') then
    Exit;
  // DebugLn('TGtk3WSCustomListView.SetProperty ');
  SetPropertyInternal(ALV, AProp, AIsSet);
end;

class procedure TGtk3WSCustomListView.SetProperties(const ALV: TCustomListView;
  const AProps: TListViewProperties);
var
  Prop: TListViewProperty;
begin
  if not WSCheckHandleAllocated(ALV, 'SetProperties') then
    Exit;
  for Prop := Low(Prop) to High(Prop) do
    SetPropertyInternal(ALV, Prop, Prop in AProps);
end;

class procedure TGtk3WSCustomListView.SetScrollBars(const ALV: TCustomListView;
  const AValue: TScrollStyle);
var
  SS: TGtkScrollStyle;
begin
  if not WSCheckHandleAllocated(ALV, 'SetScrollBars') then
    Exit;
  // DebugLn('TGtk3WSCustomListView.SetScrollbars ');
  // inherited SetScrollBars(ALV, AValue);
  SS := Gtk3TranslateScrollStyle(AValue);
  TGtk3ListView(ALV.Handle).GetScrolledWindow^.set_policy(SS.Horizontal, SS.Vertical);
end;

class procedure TGtk3WSCustomListView.SetSort(const ALV: TCustomListView;
  const AType: TSortType; const AColumn: Integer;
  const ASortDirection: TSortDirection);
begin
  if not WSCheckHandleAllocated(ALV, 'SetSort') then
    Exit;
  if TGtk3ListView(ALV.Handle).GetContainerWidget^.get_realized then
    TGtk3ListView(ALV.Handle).GetContainerWidget^.queue_draw;
  // DebugLn('TGtk3WSCustomListView.SetSort ');
  // inherited SetSort(ALV, AType, AColumn, ASortDirection);
end;

class procedure TGtk3WSCustomListView.SetViewOrigin(const ALV: TCustomListView;
  const AValue: TPoint);
begin
  if not WSCheckHandleAllocated(ALV, 'SetViewOrigin') then
    Exit;
  if not TGtk3ListView(ALV.Handle).GetContainerWidget^.get_realized then
    exit;
  // DebugLn('TGtk3WSCustomListView.SetViewOrigin ');
  if TGtk3ListView(ALV.Handle).IsTreeView then
    PGtkTreeView(TGtk3ListView(ALV.Handle).GetContainerWidget)^.scroll_to_point(AValue.X, AValue.Y);
  // TODO: else
  //  PGtkIconView(TGtk3ListView(ALV.Handle).GetContainerWidget)^.scroll_to_path();
end;

class procedure TGtk3WSCustomListView.SetViewStyle(const ALV: TCustomListView;
  const AValue: TViewStyle);
begin
  if not WSCheckHandleAllocated(ALV, 'SetViewStyle') then
    Exit;
  // DebugLn('TGtk3WSCustomListView.SetViewStyle ');
  RecreateWnd(ALV);
  // inherited SetViewStyle(ALV, AValue);
end;

{ TGtk3WSStatusBar }

class function TGtk3WSStatusBar.CreateHandle(const AWinControl: TWinControl;
  const AParams: TCreateParams): TLCLHandle;
var
  AStatusBar: TGtk3StatusBar;
begin
  AStatusBar := TGtk3StatusBar.Create(AWinControl, AParams);
  Result := TLCLHandle(AStatusBar);
end;

class procedure TGtk3WSStatusBar.PanelUpdate(const AStatusBar: TStatusBar;
  PanelIndex: integer);
begin
  // inherited PanelUpdate(AStatusBar, PanelIndex);
end;

class procedure TGtk3WSStatusBar.SetPanelText(const AStatusBar: TStatusBar;
  PanelIndex: integer);
begin
  // inherited SetPanelText(AStatusBar, PanelIndex);
end;

class procedure TGtk3WSStatusBar.Update(const AStatusBar: TStatusBar);
begin
  // inherited Update(AStatusBar);
end;

class procedure TGtk3WSStatusBar.GetPreferredSize(
  const AWinControl: TWinControl; var PreferredWidth, PreferredHeight: integer;
  WithThemeSpace: Boolean);
begin
  inherited GetPreferredSize(AWinControl, PreferredWidth, PreferredHeight,
    WithThemeSpace);
end;

class procedure TGtk3WSStatusBar.SetSizeGrip(const AStatusBar: TStatusBar;
  SizeGrip: Boolean);
begin
  // inherited SetSizeGrip(AStatusBar, SizeGrip);
end;

{ TGtk3WSCustomTabControl }

class function TGtk3WSCustomTabControl.CreateHandle(
  const AWinControl: TWinControl; const AParams: TCreateParams): TLCLHandle;
begin
  if AWinControl is TTabControl then
    Result := TLCLHandle(TGtk3CustomControl.Create(AWinControl, AParams))
  else
    Result := TLCLHandle(TGtk3NoteBook.Create(AWinControl, AParams));
end;

{used when handle of TCustomTabControl isn't allocated or TGt3Widget(Handle).WidgetMapped = false}
function MeasureClientRect(const {%H-}AWinControl: TWinControl; const {%H-}ALeft, {%H-}ATop, AWidth, AHeight: integer): TRect;
var
  ANoteBook: PGtkNoteBook;
  APage:PGtkBox;
  AFixed:PGtkFixed;
  Alloc:TGtkAllocation;
  abox:PGtkBox;
  AWindow:PGtkWindow;
begin
  Result := Rect(0, 0, 0, 0);
  AWindow := TGtkWindow.new(GTK_WINDOW_TOPLEVEL);

  gtk_window_set_decorated(awindow, False);
  gtk_widget_set_app_paintable(awindow, gtk_true);
  gtk_widget_set_size_request(awindow, 1, 1);
  gtk_window_set_default_size(aWindow, AWidth, AHeight);
  gtk_window_set_focus_on_map(aWindow, false);
  gtk_window_set_position(AWindow, GTK_WIN_POS_NONE);
  gtk_window_set_keep_below(AWindow, True);

  abox := gtk_box_new(GTK_ORIENTATION_VERTICAL, 0);
  gtk_container_add(aWindow, abox);


  ANoteBook := TGtkNoteBook.new;
  APage := TGtkHBox.new(GTK_ORIENTATION_HORIZONTAL, 0);
  AFixed := TGtkFixed.new;

  APage^.pack_start(AFixed, True, True, 0);
  APage^.set_child_packing(AFixed, True, True, 0, GTK_PACK_START);
  Alloc.x := 1;
  Alloc.y := 1;
  Alloc.width := 300;
  Alloc.Height := 200;
  ANoteBook^.append_page(APage, gtk_label_new('Tab1'));
  ANoteBook^.set_current_page(0);

  gtk_box_pack_start(abox, ANoteBook, True, True, 0);
  aBox^.set_child_packing(aNoteBook, True, True, 0, GTK_PACK_START);

  ANoteBook^.show_all;
  ANoteBook^.set_allocation(@Alloc);
  ANoteBook^.set_show_tabs(True);
  AWindow^.realize;
  AWindow^.show_all;
  APage^.get_allocation(@Alloc);
  Result := Bounds(0, 0, Alloc.Width, Alloc.Height);
  AWindow^.set_visible(false);
  AWindow^.destroy_;

end;

{used when handle of TCustomTabControl isn't allocated or TGt3Widget(Handle).WidgetMapped = false}
function GetTabSize(AWinControl: TCustomTabControl): integer;
var
  ABounds:TRect;
begin
  ABounds := AWinControl.BoundsRect;
  if AWinControl.TabPosition in [tpTop, tpBottom] then
  begin
    with ABounds do
      Result := Bottom - Top - MeasureClientRect(AWinControl, Left, Top, Right - Left, Bottom - Top).Height;
  end else
  begin
    with ABounds do
      Result := Right - Left - MeasureClientRect(AWinControl, Left, Top, Right - Left, Bottom - Top).Width;
  end;
end;

class function TGtk3WSCustomTabControl.GetDefaultClientRect(const AWinControl:
  TWinControl;const aLeft,aTop,aWidth,aHeight:integer;var aClientRect:TRect):
  boolean;
var
  dx:Integer;
begin
  Result := False;
  if AWinControl.HandleAllocated then
  begin
    if not (AWinControl is TTabControl) then
    begin
      if not TGtk3NoteBook(AWinControl.Handle).WidgetMapped then
      begin
        aClientRect := MeasureClientRect(AWinControl, ALeft, ATop, AWidth, AHeight);
        if IsRectEmpty(aClientRect) then
        begin
          TGtk3NoteBook(AWinControl.Handle).DefaultClientRect := Rect(0, 0, 0, 0);
          exit(False);
        end;
        TGtk3NoteBook(AWinControl.Handle).DefaultClientRect := aClientRect;
        Result := True;
      end;
    end;
  end else
  begin
    if AWinControl is TTabControl then
    begin
      dx := GetTabSize(TTabControl(AWinControl));
      aClientRect := Rect(0,0, Max(0, aWidth - (dx * 2)), Max(0, aHeight - (dx * 2)));
    end else
      aClientRect := MeasureClientRect(AWinControl, ALeft, ATop, AWidth, AHeight);
    Result := True;
  end;
end;

class procedure TGtk3WSCustomTabControl.AddPage(
  const ATabControl: TCustomTabControl; const AChild: TCustomPage;
  const AIndex: integer);
begin
  if not WSCheckHandleAllocated(ATabControl, 'AddPage') then
    Exit;
  // set LCL size
  AChild.SetBounds(AChild.Left, AChild.Top, ATabControl.ClientWidth, ATabControl.ClientHeight);

  if AChild.TabVisible then
    TGtk3Widget(AChild.Handle).Show;

  if ATabControl is TTabControl then
    exit;

  TGtk3Notebook(ATabControl.Handle).InsertPage(AChild, AIndex);
end;

class procedure TGtk3WSCustomTabControl.MovePage(
  const ATabControl: TCustomTabControl; const AChild: TCustomPage;
  const NewIndex: integer);
begin
  if not WSCheckHandleAllocated(ATabControl, 'MovePage') then
    Exit;
  if (ATabControl is TTabControl) then
    exit;
  TGtk3Notebook(ATabControl.Handle).MovePage(AChild, NewIndex);
end;

class procedure TGtk3WSCustomTabControl.RemovePage(
  const ATabControl: TCustomTabControl; const AIndex: integer);
begin
  if not WSCheckHandleAllocated(ATabControl, 'RemovePage') then
    Exit;
  if (ATabControl is TTabControl) then
    exit;
  TGtk3Notebook(ATabControl.Handle).RemovePage(AIndex);
end;

class function TGtk3WSCustomTabControl.GetCapabilities: TCTabControlCapabilities;
begin
  Result := [nbcShowCloseButtons, nbcMultiLine, nbcPageListPopup, nbcShowAddTabButton];
end;

class function TGtk3WSCustomTabControl.GetNotebookMinTabHeight(
  const AWinControl: TWinControl): integer;
begin
  Result := TWSCustomTabControl.GetNotebookMinTabHeight(AWinControl);
  if AWinControl.HandleAllocated then
  begin
    if not (AWinControl is TTabControl) then
      Result := TGtk3Notebook(AWinControl.Handle).GetTabSize(AWinControl);
  end;
end;

class function TGtk3WSCustomTabControl.GetNotebookMinTabWidth(
  const AWinControl: TWinControl): integer;
begin
  Result := TWSCustomTabControl.GetNotebookMinTabWidth(AWinControl);
end;

class function TGtk3WSCustomTabControl.GetTabIndexAtPos(
  const ATabControl: TCustomTabControl; const AClientPos: TPoint): integer;
var
  NoteBookWidget: PGtkNotebook;
  TabWidget, PageWidget: PGtkWidget;
  i: integer;
  AList: PGList;
  Allocation: TGtkAllocation;
  ARect: TRect;
begin
  Result:=-1;
  if (ATabControl is TTabControl) then
    exit;
  NoteBookWidget := PGtkNotebook(TGtk3NoteBook(ATabControl.Handle).GetContainerWidget);
  if (NotebookWidget=nil) then exit;

  AList := NoteBookWidget^.get_children;
  try
    for i := 0 to g_list_length(AList) - 1 do
    begin
      PageWidget := NoteBookWidget^.get_nth_page(i);
      if (PageWidget<>nil) then
      begin
        TabWidget := NoteBookWidget^.get_tab_label(PageWidget);
        if TabWidget <> nil then
        begin
          gtk_widget_get_allocation(TabWidget, @Allocation);
          ARect := RectFromGdkRect(Allocation);
          if PtInRect(ARect, AClientPos) then
          begin
            Result := I;
            break;
          end;
        end;
      end;
    end;
  finally
    if AList <> nil then
      g_list_free(Alist);
  end;
end;

class function TGtk3WSCustomTabControl.GetTabRect(
  const ATabControl: TCustomTabControl; const AIndex: Integer): TRect;
var
  NoteBookWidget: PGtkNotebook;
  TabWidget, PageWidget: PGtkWidget;
  Count: guint;
  AList: PGList;
  Allocation: TGtkAllocation;
  X, Y: gint;
begin
  Result := inherited;
  if (ATabControl is TTabControl) then
    exit;
  Result := Rect(0, 0, 0, 0);

  NoteBookWidget := PGtkNotebook(TGtk3NoteBook(ATabControl.Handle).GetContainerWidget);
  if (NotebookWidget=nil) then exit;

  AList := NoteBookWidget^.get_children;
  try
    Count := g_list_length(AList);
    PageWidget := NoteBookWidget^.get_nth_page(AIndex);
    if (PageWidget<>nil) and (AIndex < Count) then
    begin
      TabWidget := NoteBookWidget^.get_tab_label(PageWidget);
      if TabWidget <> nil then
      begin
        gtk_widget_get_allocation(TabWidget, @Allocation);
        Result := RectFromGdkRect(Allocation);
        gtk_widget_get_allocation(NoteBookWidget, @Allocation);
        Y := Allocation.y;
        X := Allocation.x;
        if Y <= 0 then
          exit;
        case ATabControl.TabPosition of
          tpTop, tpBottom:
              OffsetRect(Result, 0, -Y);
          tpLeft, tpRight:
            OffsetRect(Result, -X, -Y);
        end;
      end;
    end;
  finally
    if AList <> nil then
      g_list_free(Alist);
  end;
end;

class procedure TGtk3WSCustomTabControl.SetPageIndex(
  const ATabControl: TCustomTabControl; const AIndex: integer);
begin
  if (ATabControl is TTabControl) then
    exit;
  if not WSCheckHandleAllocated(ATabControl, 'SetPageIndex') then
    Exit;
  TGtk3Notebook(ATabControl.Handle).BeginUpdate;
  TGtk3Notebook(ATabControl.Handle).SetPageIndex(AIndex);
  TGtk3Notebook(ATabControl.Handle).EndUpdate;
end;

class procedure TGtk3WSCustomTabControl.SetTabCaption(
  const ATabControl: TCustomTabControl; const AChild: TCustomPage;
  const AText: string);
begin
  if (ATabControl is TTabControl) then
    exit;
  if not WSCheckHandleAllocated(ATabControl, 'SetTabCaption') then
    Exit;
  TGtk3NoteBook(ATabControl.Handle).SetTabLabelText(AChild, AText);
end;

class procedure TGtk3WSCustomTabControl.SetTabPosition(
  const ATabControl: TCustomTabControl; const ATabPosition: TTabPosition);
begin
  if (ATabControl is TTabControl) then
    exit;
  if not WSCheckHandleAllocated(ATabControl, 'SetTabPosition') then
    Exit;
  TGtk3NoteBook(ATabControl.Handle).SetTabPosition(ATabPosition);
end;

class procedure TGtk3WSCustomTabControl.ShowTabs(
  const ATabControl: TCustomTabControl; AShowTabs: boolean);
begin
  if ATabControl is TTabControl then
    exit;
  if not WSCheckHandleAllocated(ATabControl, 'ShowTabs') then
    Exit;
  TGtk3NoteBook(ATabControl.Handle).SetShowTabs(AShowTabs);
end;

class procedure TGtk3WSCustomTabControl.UpdateProperties(
  const ATabControl: TCustomTabControl);
var
  aPage: PGtkWidget;
  aLCLPage: TGtk3Page;
  i: Integer;
begin
  if ATabControl is TTabControl then
    exit;
  for i := 0 to PGtkNotebook(TGtk3NoteBook(ATabControl.Handle).GetContainerWidget)^.get_n_pages - 1 do
  begin
    aPage := PGtkNotebook(TGtk3NoteBook(ATabControl.Handle).GetContainerWidget)^.get_nth_page(i);
    aLCLPage := TGtk3Page(HwndFromGtkWidget(aPage));
    if Assigned(aLCLPage) then
    begin
      aLCLPage.CloseButtonVisible := (nboShowCloseButtons in ATabControl.Options);
      if Assigned(ATabControl.Images) then
        TGtk3WSCustomPage.UpdateProperties(TCustomPage(aLCLPage.LCLObject));
    end;
  end;
  if (nboHidePageListPopup in ATabControl.Options) then
    PGtkNotebook(TGtk3NoteBook(ATabControl.Handle).GetContainerWidget)^.popup_disable
  else
    PGtkNotebook(TGtk3NoteBook(ATabControl.Handle).GetContainerWidget)^.popup_enable;
end;


{ TGtk3WSCustomPage }

class function TGtk3WSCustomPage.CreateHandle(const AWinControl: TWinControl;
  const AParams: TCreateParams): TLCLHandle;
begin
  Result := TLCLHandle(TGtk3Page.Create(AWinControl, AParams));
end;

class function TGtk3WSCustomPage.GetDefaultClientRect(const AWinControl:
  TWinControl;const aLeft,aTop,aWidth,aHeight:integer;var aClientRect:TRect):
  boolean;
begin
  Result := False;
  if AWinControl.Parent = nil then
    exit;
  if AWinControl.HandleAllocated and AWinControl.Parent.HandleAllocated and
    TGtk3Widget(AWinControl.Parent.Handle).WidgetMapped and TGtk3Widget(AWinControl.Handle).WidgetMapped then
    exit
  else
  begin
    aClientRect := AWinControl.Parent.ClientRect;
    Result := True;
  end;
end;

class procedure TGtk3WSCustomPage.SetBounds(const AWinControl:TWinControl;const
  ALeft,ATop,AWidth,AHeight:Integer);
begin
  //do nothing !
  //inherited SetBounds(AWinControl,ALeft,ATop,AWidth,AHeight);
  if AWinControl.HandleAllocated then
  begin
    TGtk3Page(AWinControl.Handle).LCLWidth := aWidth;
    TGtk3Page(AWinControl.Handle).LCLWidth := aHeight;
  end;
end;

class procedure TGtk3WSCustomPage.SetFont(const AWinControl:TWinControl;const
  AFont:TFont);
begin
  //do nothing !
  //inherited SetFont(AWinControl,AFont);
end;

class procedure TGtk3WSCustomPage.ShowHide(const AWinControl:TWinControl);
begin
  //do nothing !
  //inherited ShowHide(AWinControl);
end;

class procedure TGtk3WSCustomPage.UpdateProperties(
  const ACustomPage: TCustomPage);

var
  ImageList: TCustomImageList;
  ImageIndex: Integer;
  Bmp: TBitmap;
  Res: TScaledImageListResolution;
begin
  if not WSCheckHandleAllocated(ACustomPage, 'UpdateProperties') then
    Exit;

  ImageList := TCustomTabControl(ACustomPage.Parent).Images;

  if Assigned(ImageList) then
  begin
    Res := ImageList.ResolutionForPPI[
      TCustomTabControl(ACustomPage.Parent).ImagesWidth,
      TCustomTabControl(ACustomPage.Parent).Font.PixelsPerInch,
      TCustomTabControl(ACustomPage.Parent).GetCanvasScaleFactor];
    ImageIndex := TCustomTabControl(ACustomPage.Parent).GetImageIndex(ACustomPage.PageIndex);
    if (ImageIndex >= 0) and (ImageIndex < Res.Count) then
    begin
      Bmp := TBitmap.Create;
      try
        Res.GetBitmap(ACustomPage.ImageIndex, Bmp);
        TGtk3Page(ACustomPage.Handle).setTabImage(Bmp);
      finally
        Bmp.Free;
      end;
    end else
      TGtk3Page(ACustomPage.Handle).setTabImage(nil);
  end else
    TGtk3Page(ACustomPage.Handle).setTabImage(nil);
end;

end.
