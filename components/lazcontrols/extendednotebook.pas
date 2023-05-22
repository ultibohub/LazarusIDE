{ ExtendedNotebook

  Copyright (C) 2010 Lazarus team

  This library is free software; you can redistribute it and/or modify it
  under the same terms as the Lazarus Component Library (LCL)

  See the file COPYING.modifiedLGPL.txt, included in this distribution,
  for details about the license.

}
unit ExtendedNotebook;

{$mode objfpc}{$H+}

// Order Of Events are:
// W32:     Changing, Change, MDown,                    MMove,                    MUp
// Gtk, QT:                   MDown, Changing, Change,  MMove,                    MUp
// Carbon:                    MDown,                    MMove,  Changing, Change, MUp

{off $DEFINE ExtNBookDebug}

interface

uses
  Classes, sysutils, math,
  // LCL
  LCLIntf, LCLType, LMessages, Controls, ComCtrls
  {$IFDEF ExtNBookDebug} , LCLProc {$ENDIF};

type

  TNotebookTabDragDropEvent = procedure(Sender, Source: TObject;
                                        OldIndex, NewIndex: Integer;
                                        CopyDrag: Boolean;
                                        var Done: Boolean) of object;
  TNotebookTabDragOverEvent = procedure(Sender, Source: TObject;
                                        OldIndex, NewIndex: Integer;
                                        CopyDrag: Boolean;
                                        var Accept: Boolean) of object;

  //TNotebookTabDragFlag = (ndfWaitForDrag, ndfTabDragged);
  //TNotebookTabDragFlags = set of TNotebookTabDragFlag;

  { TExtendedNotebook }

  TExtendedNotebook = class(TPageControl)
  private
    FDraggingTabIndex: Integer;
    FOnTabDragDrop: TDragDropEvent;
    FOnTabDragOver: TDragOverEvent;
    FOnTabDragOverEx: TNotebookTabDragOverEvent;
    FOnTabDragDropEx: TNotebookTabDragDropEvent;
    FOnTabEndDrag: TEndDragEvent;
    FOnTabStartDrag: TStartDragEvent;
    FTabDragMode: TDragMode;
    FTabDragAcceptMode: TDragMode;

    FTabDragged: boolean;
    FDragOverIndex: Integer;
    FDragToRightSide: Boolean;
    FDragOverTabRect, FDragNextToTabRect: TRect;

    FMouseWaitForDrag: Boolean;
    FMouseDownIndex: Integer;
    FMouseDownX, FMouseDownY, FTriggerDragX, FTriggerDragY: Integer;

    procedure InitDrag;
    procedure InvalidateRect(ARect: TRect);
    function  TabIndexForDrag(x, y: Integer): Integer;
    function  TabRectEx(AIndex, X, Y: Integer; out IsRightHalf: Boolean): TRect;
  protected
    procedure MouseDown(Button: TMouseButton; Shift: TShiftState; X, Y: Integer); override;
    procedure MouseUp(Button: TMouseButton; Shift: TShiftState; X,
             Y: Integer); override;
    procedure MouseMove(Shift: TShiftState; X, Y: Integer); override;
    procedure CNNotify(var Message: TLMNotify); message CN_NOTIFY;
    procedure RemovePage(Index: Integer); override;
    procedure InsertPage(APage: TCustomPage; Index: Integer); override;
    procedure CaptureChanged; override;
    procedure DoStartDrag(var DragObject: TDragObject); override;
    procedure DoEndDrag(Target: TObject; X,Y: Integer); override;
    procedure DragOver(Source: TObject; X, Y: Integer; State: TDragState;
      var Accept: Boolean); override;
    procedure DragCanceled; override;
    procedure PaintWindow(DC: HDC); override;
  public
    constructor Create(TheOwner: TComponent); override;
    procedure DragDrop(Source: TObject; X, Y: Integer); override;
    procedure BeginDragTab(ATabIndex: Integer; Immediate: Boolean; Threshold: Integer = -1);
    property DraggingTabIndex: Integer read FDraggingTabIndex;
  published
    property OnTabDragOver: TDragOverEvent read FOnTabDragOver write FOnTabDragOver;
    property OnTabDragOverEx: TNotebookTabDragOverEvent read FOnTabDragOverEx write FOnTabDragOverEx;
    property OnTabDragDrop: TDragDropEvent read FOnTabDragDrop write FOnTabDragDrop;
    property OnTabDragDropEx: TNotebookTabDragDropEvent read FOnTabDragDropEx write FOnTabDragDropEx;
    property OnTabEndDrag: TEndDragEvent read FOnTabEndDrag write FOnTabEndDrag;
    property OnTabStartDrag: TStartDragEvent read FOnTabStartDrag write FOnTabStartDrag;

    property TabDragMode: TDragMode read FTabDragMode write FTabDragMode
             default dmManual;
    property TabDragAcceptMode: TDragMode read FTabDragAcceptMode write FTabDragAcceptMode
             default dmManual;
  end;

implementation

{ TExtendedNotebook }

procedure TExtendedNotebook.InitDrag;
Begin
  FMouseWaitForDrag := False;
  DragCursor := crDrag;
  FDragOverIndex := -1;
  FDraggingTabIndex := -1;
  FDragOverTabRect   := Rect(0, 0, 0, 0);
  FDragNextToTabRect := Rect(0, 0, 0, 0);
end;

procedure TExtendedNotebook.InvalidateRect(ARect: TRect);
begin
  LCLIntf.InvalidateRect(Handle, @ARect, false);
end;

function TExtendedNotebook.TabIndexForDrag(x, y: Integer): Integer;
var
  TabPos: TRect;
begin
  Result := IndexOfPageAt(X, Y);
  if Result < 0 then begin
    TabPos := TabRect(PageCount-1);
    // Check empty space after last tab
    if (TabPos.Right > 1) and (X > TabPos.Left) and
       (Y >= TabPos.Top) and (Y <= TabPos.Bottom)
    then
      Result := PageCount - 1;
  end;

end;

function TExtendedNotebook.TabRectEx(AIndex, X, Y: Integer; out IsRightHalf: Boolean): TRect;
begin
  Result := TabRect(AIndex);
  if (TabPosition in [tpLeft, tpRight]) then    // Drag-To-Bottom/Lower
    IsRightHalf := Y > (Result.Top + Result.Bottom) div 2
  else
    IsRightHalf := X > (Result.Left + Result.Right) div 2;
end;

procedure TExtendedNotebook.MouseDown(Button: TMouseButton; Shift: TShiftState; X,
  Y: Integer);
Begin
  {$IFDEF ExtNBookDebug}debugln(['TExtendedNotebook.MouseDown']);{$ENDIF}
  InitDrag;
  FTabDragged:=false;
  inherited MouseDown(Button, Shift, X, Y);
  if (fTabDragMode = dmAutomatic) and (Button = mbLeft) then Begin
    // Defer BeginDrag to MouseMove.
    // On GTK2 if BeginDrag is called before PageChanging, the GTK notebook no longer works
    FMouseWaitForDrag := True;
    if FMouseDownIndex < 0 then
      FMouseDownIndex := IndexOfPageAt(X, Y);
    FMouseDownX := X;
    FMouseDownY := Y;
    FTriggerDragX := GetSystemMetrics(SM_CXDRAG);
    FTriggerDragY := GetSystemMetrics(SM_CYDRAG);
    MouseCapture := True;
  end;
end;

procedure TExtendedNotebook.MouseUp(Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
  {$IFDEF ExtNBookDebug}debugln(['TExtendedNotebook.MouseUp']);{$ENDIF}
  MouseCapture := False;
  InitDrag;
  inherited MouseUp(Button, Shift, X, Y);
  FMouseDownIndex := -1;
end;

procedure TExtendedNotebook.MouseMove(Shift: TShiftState; X, Y: Integer);
begin
  inherited MouseMove(Shift, X, Y);
  if (FMouseWaitForDrag) and (FMouseDownIndex >= 0) and
     ( (Abs(fMouseDownX - X) >= FTriggerDragX) or (Abs(fMouseDownY - Y) >= FTriggerDragY) )
  then begin
    {$IFDEF ExtNBookDebug}debugln(['TExtendedNotebook.MouseMove: BeginDragTab Idx=',FMouseDownIndex]);{$ENDIF}
    FMouseWaitForDrag := False;
    BeginDragTab(FMouseDownIndex, True);
  end;
end;

procedure TExtendedNotebook.CNNotify(var Message: TLMNotify);
Begin
  if (Dragging or (FDraggingTabIndex >= 0)) and
     ( (Message.NMHdr^.code = TCN_SELCHANGING) or
       (Message.NMHdr^.code = TCN_SELCHANGE) )
  then
    CancelDrag
  else
  if Message.NMHdr^.code = TCN_SELCHANGING then Begin
    if (fTabDragMode = dmAutomatic) and (not FMouseWaitForDrag) then
      FMouseDownIndex := IndexOfPageAt(ScreenToClient(Mouse.CursorPos));
    {$IFDEF ExtNBookDebug}debugln(['TExtendedNotebook.CNNotify: FMouseWaitForDrag=', FMouseWaitForDrag, ' Idx=',FMouseDownIndex]);{$ENDIF}
  end;
  inherited CNNotify(Message);
end;

procedure TExtendedNotebook.RemovePage(Index: Integer);
begin
  CancelDrag;
  FMouseDownIndex := -1;
  FMouseWaitForDrag := False;
  inherited RemovePage(Index);
end;

procedure TExtendedNotebook.InsertPage(APage: TCustomPage; Index: Integer);
begin
  CancelDrag;
  FMouseDownIndex := -1;
  FMouseWaitForDrag := False;
  inherited InsertPage(APage, Index);
end;

procedure TExtendedNotebook.CaptureChanged;
begin
  FMouseDownIndex := -1;
  FMouseWaitForDrag := False;
  inherited CaptureChanged;
end;

procedure TExtendedNotebook.DoStartDrag(var DragObject: TDragObject);
begin
  {$IFDEF ExtNBookDebug}debugln(['TExtendedNotebook.DoStartDrag  FDraggingTabIndex=', FDraggingTabIndex]);{$ENDIF}
  if FDraggingTabIndex < 0 then
    inherited DoStartDrag(DragObject)
  else
    if Assigned(FOnTabStartDrag) then FOnTabStartDrag(Self, DragObject);
end;

procedure TExtendedNotebook.DoEndDrag(Target: TObject; X, Y: Integer);
begin
  {$IFDEF ExtNBookDebug}debugln(['TExtendedNotebook.DoEndDrag  FDraggingTabIndex=', FDraggingTabIndex]);{$ENDIF}
  if FDraggingTabIndex < 0 then
    inherited DoEndDrag(Target, X, Y)
  else
    if Assigned(FOnTabEndDrag) then FOnTabEndDrag(Self, Target, x, Y);
end;

procedure TExtendedNotebook.DragOver(Source: TObject; X, Y: Integer; State: TDragState;
  var Accept: Boolean);
var
  TabId: Integer;
  LastRect, LastNRect: TRect;
  LastIndex: Integer;
  LastRight, NeedInvalidate: Boolean;
  Ctrl: Boolean;
  Src: TExtendedNotebook;
begin
  if (not (Source is TExtendedNotebook)) or
     (TExtendedNotebook(Source).FDraggingTabIndex < 0)
  then begin
    // normal DragOver
    inherited DragOver(Source, X, Y, State, Accept);
    exit;
  end;

  // Tab drag over
  TabId := TabIndexForDrag(X,Y);

  Accept := (FTabDragAcceptMode = dmAutomatic) and (Source = Self) and
            (TabId >= 0) and (TabId <> FDraggingTabIndex);

  if Assigned(FOnTabDragOver) then
    FOnTabDragOver(Self,Source,X,Y,State,Accept);

  if ((state = dsDragLeave) or (TabId < 0)) and (FDragOverIndex >= 0)
  then begin
    InvalidateRect(FDragOverTabRect);
    InvalidateRect(FDragNextToTabRect);
    FDragOverIndex := -1;
  end;

  if (TabId < 0) then
    exit;

  Ctrl := (GetKeyState(VK_CONTROL) and $8000)<>0;
  if Ctrl then
    DragCursor := crMultiDrag
  else
    DragCursor := crDrag;

  LastIndex := FDragOverIndex;
  LastRight := FDragToRightSide;
  LastRect  := FDragOverTabRect;
  LastNRect := FDragNextToTabRect;
  FDragOverIndex   := TabId;
  FDragOverTabRect := TabRectEx(TabId, X, Y, FDragToRightSide);

  if (Source = Self) and (TabId = FDraggingTabIndex - 1) then
    FDragToRightSide := False;
  if (Source = Self) and (TabId = FDraggingTabIndex + 1) then
    FDragToRightSide := True;

  NeedInvalidate := (FDragOverIndex <> LastIndex) or (FDragToRightSide <> LastRight);
  if NeedInvalidate then begin
    InvalidateRect(LastRect);
    InvalidateRect(LastNRect);
    InvalidateRect(FDragOverTabRect);
    InvalidateRect(FDragNextToTabRect);
  end;

  if FDragToRightSide then begin
    inc(TabId);
    if TabId < PageCount then
      FDragNextToTabRect := TabRect(TabId);
  end else begin
    if TabId > 0 then
      FDragNextToTabRect := TabRect(TabId - 1);
  end;
  if NeedInvalidate then
    InvalidateRect(FDragNextToTabRect);

  Src := TExtendedNotebook(Source);
  if (Source = self) and (TabId > Src.DraggingTabIndex) then
    dec(TabId);

  if Assigned(FOnTabDragOverEx) then
    FOnTabDragOverEx(Self, Source, Src.DraggingTabIndex, TabId, Ctrl, Accept);

  if (not Accept) or (state = dsDragLeave) then begin
    InvalidateRect(FDragOverTabRect);
    InvalidateRect(FDragNextToTabRect);
    FDragOverIndex := -1;
  end;
end;

procedure TExtendedNotebook.DragCanceled;
begin
  inherited DragCanceled;
  if (FDragOverIndex >= 0) then begin
    InvalidateRect(FDragOverTabRect);
    InvalidateRect(FDragNextToTabRect);
  end;
  FDragOverIndex := -1;
  DragCursor := crDrag;
end;

procedure TExtendedNotebook.PaintWindow(DC: HDC);
var
  Points: Array [0..3] of TPoint;

  procedure DrawLeftArrow(ARect: TRect);
  var y, h: Integer;
  begin
    h := Min( (Abs(ARect.Bottom - ARect.Top) - 4) div 2,
              (Abs(ARect.Left - ARect.Right) - 4) div 2 );
    y := (ARect.Top + ARect.Bottom) div 2;
    Points[0].X := ARect.Left + 2 + h;
    Points[0].y := y - h;
    Points[1].X := ARect.Left + 2 + h;
    Points[1].y := y + h;
    Points[2].X := ARect.Left + 2;
    Points[2].y := y;
    Points[3] := Points[0];
    Polygon(DC, @Points[Low(Points)], 4, False);
  end;
  procedure DrawRightArrow(ARect: TRect);
  var y, h: Integer;
  begin
    h := Min( (Abs(ARect.Bottom - ARect.Top) - 4) div 2,
              (Abs(ARect.Left - ARect.Right) - 4) div 2 );
    y := (ARect.Top + ARect.Bottom) div 2;
    Points[0].X := ARect.Right - 2 - h;
    Points[0].y := y - h;
    Points[1].X := ARect.Right - 2 - h;
    Points[1].y := y + h;
    Points[2].X := ARect.Right - 2;
    Points[2].y := y;
    Points[3] := Points[0];
    Polygon(DC, @Points[Low(Points)], 4, False);
  end;
  procedure DrawTopArrow(ARect: TRect);
  var x, h: Integer;
  begin
    h := Min( (Abs(ARect.Bottom - ARect.Top) - 4) div 2,
              (Abs(ARect.Left - ARect.Right) - 4) div 2 );
    x := (ARect.Left + ARect.Right) div 2;
    Points[0].Y := ARect.Top + 2 + h;
    Points[0].X := x - h;
    Points[1].Y := ARect.Top + 2 + h;
    Points[1].X := x + h;
    Points[2].Y	 := ARect.Top + 2;
    Points[2].X := x;
    Points[3] := Points[0];
    Polygon(DC, @Points[Low(Points)], 4, False);
  end;
  procedure DrawBottomArrow(ARect: TRect);
  var x, h: Integer;
  begin
    h := Min( (Abs(ARect.Bottom - ARect.Top) - 4) div 2,
              (Abs(ARect.Left - ARect.Right) - 4) div 2 );
    x := (ARect.Left + ARect.Right) div 2;
    Points[0].Y := ARect.Bottom - 2 - h;
    Points[0].X := X - h;
    Points[1].Y := ARect.Bottom - 2 - h;
    Points[1].X := X + h;
    Points[2].Y := ARect.Bottom - 2;
    Points[2].X := X;
    Points[3] := Points[0];
    Polygon(DC, @Points[Low(Points)], 4, False);
  end;

begin
  inherited PaintWindow(DC);
  if FDragOverIndex < 0 then exit;

  if (TabPosition in [tpLeft, tpRight]) then begin
    if FDragToRightSide then begin
      DrawBottomArrow(FDragOverTabRect);
      if (FDragOverIndex < PageCount - 1) then
        DrawTopArrow(FDragNextToTabRect);
    end else begin
      DrawTopArrow(FDragOverTabRect);
      if (FDragOverIndex > 0) then
        DrawBottomArrow(FDragNextToTabRect);
    end;
  end
  else
  begin
    if FDragToRightSide then begin
      DrawRightArrow(FDragOverTabRect);
      if (FDragOverIndex < PageCount - 1) then
        DrawLeftArrow(FDragNextToTabRect);
    end else begin
      DrawLeftArrow(FDragOverTabRect);
      if (FDragOverIndex > 0) then
        DrawRightArrow(FDragNextToTabRect);
    end;
  end;
end;

constructor TExtendedNotebook.Create(TheOwner: TComponent);
begin
  inherited Create(TheOwner);
  InitDrag;
  FMouseDownIndex := -1;
  fTabDragMode := dmManual;
end;

procedure TExtendedNotebook.DragDrop(Source: TObject; X, Y: Integer);
var
  TabId, TabId2: Integer;
  ToRight: Boolean;
  Ctrl: Boolean;
  Src: TExtendedNotebook;
  Accept: Boolean;
begin
  if (not (Source is TExtendedNotebook)) or
     (TExtendedNotebook(Source).FDraggingTabIndex < 0)
  then begin
    // normal DragDrop
    inherited DragDrop(Source, X, Y);
    exit;
  end;

  // Tab DragDrop
  If Assigned(FOnTabDragDrop) then FOnTabDragDrop(Self, Source,X,Y);

  if (FDragOverIndex >= 0) then begin
    InvalidateRect(FDragOverTabRect);
    InvalidateRect(FDragNextToTabRect);
  end;
  FDragOverIndex := -1;
  DragCursor := crDrag;

  TabId := TabIndexForDrag(X,Y);
  TabRectEx(TabId, X, Y, ToRight);

  if (Source = Self) and (TabId = FDraggingTabIndex - 1) then
    ToRight := False;
  if (Source = Self) and (TabId = FDraggingTabIndex + 1) then
    ToRight := True;
  if ToRight then
    inc(TabId);

  Src := TExtendedNotebook(Source);
  TabId2 := TabId;
  if (Source = self) and (TabId > Src.DraggingTabIndex) then
    dec(TabId);

  if assigned(FOnTabDragDropEx) then begin
    Ctrl := (GetKeyState(VK_CONTROL) and $8000)<>0;
    Accept := True;
    if Assigned(FOnTabDragOverEx) then
      FOnTabDragOverEx(Self, Source, Src.DraggingTabIndex, TabId, Ctrl, Accept);
    if Accept then
      FOnTabDragDropEx(Self, Source, Src.DraggingTabIndex, TabId, Ctrl, FTabDragged);
  end;

  if (not FTabDragged) and (FTabDragAcceptMode = dmAutomatic) and
     (Source = Self) and (TabId2 >= 0) and (TabId2 <> FDraggingTabIndex)
  then begin
    TCustomTabControl(Self).Pages.Move(Src.DraggingTabIndex, TabId);
    FTabDragged := True;
  end;
end;

procedure TExtendedNotebook.BeginDragTab(ATabIndex: Integer; Immediate: Boolean;
  Threshold: Integer = -1);
begin
  if (ATabIndex < 0) or (ATabIndex >= PageCount) then
    raise Exception.Create('Bad index');
  FDraggingTabIndex := ATabIndex;
  BeginDrag(Immediate, Threshold);
end;

end.
