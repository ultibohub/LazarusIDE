{
 ***************************************************************************
 *                                                                         *
 *   This source is free software; you can redistribute it and/or modify   *
 *   it under the terms of the GNU General Public License as published by  *
 *   the Free Software Foundation; either version 2 of the License, or     *
 *   (at your option) any later version.                                   *
 *                                                                         *
 *   This code is distributed in the hope that it will be useful, but      *
 *   WITHOUT ANY WARRANTY; without even the implied warranty of            *
 *   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU     *
 *   General Public License for more details.                              *
 *                                                                         *
 *   A copy of the GNU General Public License is available on the World    *
 *   Wide Web at <http://www.gnu.org/copyleft/gpl.html>. You can also      *
 *   obtain it by writing to the Free Software Foundation,                 *
 *   Inc., 51 Franklin Street - Fifth Floor, Boston, MA 02110-1335, USA.   *
 *                                                                         *
 ***************************************************************************

  Author: Mattias Gaertner

  Abstract:
    The base class for hint windows for the source editor for the online help.
    For example for the fpdoc and comment help.
}
unit SrcEditHintFrm;

{$mode objfpc}{$H+}

interface

uses
  Classes, Math, SysUtils,
  LCLType, LCLIntf, Forms, Controls, Graphics, ExtCtrls,
  SynEdit, SynEditKeyCmds,
  SrcEditorIntf;
  
type

  { TCodeHintProvider }

  TCodeHintProvider = class(TComponent)
  private
    FControl: TWinControl;
  protected
    procedure SetControl(const AValue: TWinControl); virtual;
  public
    procedure GetPreferredSize(var {%H-}PreferredWidth, {%H-}PreferredHeight: integer); virtual;
    procedure UpdateHint; virtual;
    property Control: TWinControl read FControl write SetControl;
  end;

  { TSrcEditHintWindow }

  TSrcEditHintWindow = class(THintWindow)
    IdleTimer1: TIdleTimer;
    procedure ApplicationIdle(Sender: TObject; var {%H-}Done: Boolean);
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure FormKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure FormUTF8KeyPress(Sender: TObject; var UTF8Key: TUTF8Char);
    procedure IdleTimer1Timer(Sender: TObject);
  private
    FAnchorForm: TCustomForm;
    FHelpEnabled: boolean;
    FPreferredHeight: integer;
    FPreferredWidth: integer;
    FProvider: TCodeHintProvider;
    FSrcEditCaret: TPoint;
    procedure SetAnchorForm(const AValue: TCustomForm);
    procedure OnAnchorFormChangeBounds(Sender: TObject);
    procedure SetHelpEnabled(const AValue: boolean);
    procedure SetProvider(const AValue: TCodeHintProvider);
    procedure UpdatePosition;
  public
    constructor Create(TheOwner: TComponent); override;
    destructor Destroy; override;
    procedure Paint; override;
    procedure UpdateHints(Immediately: boolean = false);// update content
    function NeedVisible: boolean;
    property AnchorForm: TCustomForm read FAnchorForm write SetAnchorForm;
    property HelpEnabled: boolean read FHelpEnabled write SetHelpEnabled;
    property SrcEditCaret: TPoint read FSrcEditCaret write FSrcEditCaret;// 0,0 means use current position, should be ScreenXY, not TextXY
    property PreferredWidth: integer read FPreferredWidth write FPreferredWidth;
    property PreferredHeight: integer read FPreferredHeight write FPreferredHeight;
    property Provider: TCodeHintProvider read FProvider write SetProvider; // Provider.Control=Self
  end;
  
var
  SrcEditHintWindow: TSrcEditHintWindow = nil;

implementation

type
  TWinControlAccess = class(TWinControl);

{ TSrcEditHintWindow }

procedure TSrcEditHintWindow.ApplicationIdle(Sender: TObject; var Done: Boolean);
begin
  //DebugLn(['TCodeHintFrm.ApplicationIdle NeedVisible=',NeedVisible]);
  if Visible and (not NeedVisible) then
    Hide;
end;

procedure TSrcEditHintWindow.FormCreate(Sender: TObject);
begin
  Application.AddOnIdleHandler(@ApplicationIdle);
end;

procedure TSrcEditHintWindow.FormDestroy(Sender: TObject);
begin

end;

procedure TSrcEditHintWindow.FormKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
var
  SrcEdit: TSourceEditorInterface;
begin
  if (Key=VK_ESCAPE) and (Shift=[]) then
    Hide
  else if SourceEditorManagerIntf<>nil then begin
    SrcEdit:=SourceEditorManagerIntf.ActiveEditor;
    if SrcEdit=nil then
      Hide
    else begin
      // redirect keys
      TWinControlAccess(SrcEdit.EditorControl).KeyDown(Key,Shift);
      SetActiveWindow(SourceEditorManagerIntf.ActiveSourceWindow.Handle);
    end;
  end;
end;

procedure TSrcEditHintWindow.FormUTF8KeyPress(Sender: TObject; var UTF8Key: TUTF8Char);
var
  SrcEdit: TSourceEditorInterface;
  ASynEdit: TCustomSynEdit;
begin
  SrcEdit:=SourceEditorManagerIntf.ActiveEditor;
  if SrcEdit=nil then begin
    Hide;
  end else begin
    ASynEdit:=(SrcEdit.EditorControl as TCustomSynEdit);
    ASynEdit.CommandProcessor(ecChar,UTF8Key,nil);
  end;
end;

procedure TSrcEditHintWindow.IdleTimer1Timer(Sender: TObject);
begin
  UpdateHints(true);
end;

procedure TSrcEditHintWindow.SetAnchorForm(const AValue: TCustomForm);
begin
  if FAnchorForm=AValue then exit;
  if FAnchorForm<>nil then
    FAnchorForm.RemoveAllHandlersOfObject(Self);
  FAnchorForm:=AValue;
  if FAnchorForm<>nil then
    FAnchorForm.AddHandlerOnChangeBounds(@OnAnchorFormChangeBounds);
  UpdateHints;
end;

procedure TSrcEditHintWindow.OnAnchorFormChangeBounds(Sender: TObject);
begin
  //DebugLn(['TCodeHintFrm.OnAnchorFormChangeBounds ',dbgs(BoundsRect),' Sender=',dbgsName(Sender),' SenderVisible=',TControl(Sender).Visible,' SenderBounds=',dbgs(TControl(Sender).BoundsRect)]);
  if Visible then
    UpdatePosition;
end;

procedure TSrcEditHintWindow.SetHelpEnabled(const AValue: boolean);
begin
  if FHelpEnabled=AValue then exit;
  FHelpEnabled:=AValue;
  if not HelpEnabled then
    Visible:=false;
  UpdateHints;
end;

procedure TSrcEditHintWindow.SetProvider(const AValue: TCodeHintProvider);
begin
  if FProvider=AValue then exit;
  if FProvider<>nil then begin
    FProvider.Control:=nil;
  end;
  FProvider:=AValue;
  if FProvider<>nil then begin
    FProvider.Control:=Self;
    FProvider.GetPreferredSize(FPreferredWidth,FPreferredHeight);
  end;
end;

procedure TSrcEditHintWindow.UpdatePosition;
var
  NewBounds: TRect;
  DesktopBounds: TRect;

  procedure TryPosition(TryBounds: TRect; TheAnchors: TAnchors);
  begin
    TryBounds.Right:=Max(TryBounds.Left,TryBounds.Right);
    TryBounds.Bottom:=Max(TryBounds.Top,TryBounds.Bottom);
    if TryBounds.Right>DesktopBounds.Right then begin
      if not (akLeft in TheAnchors) then begin
        // move to the left
        dec(TryBounds.Left,TryBounds.Right-DesktopBounds.Right);
        TryBounds.Left:=Max(TryBounds.Left,DesktopBounds.Left);
      end;
      TryBounds.Right:=DesktopBounds.Right;
    end;
    if TryBounds.Left<DesktopBounds.Left then begin
      if not (akRight in TheAnchors) then begin
        // move to the right
        inc(TryBounds.Right,DesktopBounds.Left-TryBounds.Left);
        TryBounds.Left:=Min(TryBounds.Right,DesktopBounds.Right);
      end;
      TryBounds.Left:=DesktopBounds.Left;
    end;
    if TryBounds.Bottom>DesktopBounds.Bottom then begin
      if not (akTop in TheAnchors) then begin
        // move to the top
        dec(TryBounds.Top,TryBounds.Bottom-DesktopBounds.Bottom);
        TryBounds.Top:=Max(TryBounds.Top,DesktopBounds.Top);
      end;
      TryBounds.Bottom:=DesktopBounds.Bottom;
    end;
    if TryBounds.Top<DesktopBounds.Top then begin
      if not (akBottom in TheAnchors) then begin
        // move to the bottom
        inc(TryBounds.Bottom,DesktopBounds.Top-TryBounds.Top);
        TryBounds.Bottom:=Min(TryBounds.Bottom,DesktopBounds.Bottom);
      end;
      TryBounds.Top:=DesktopBounds.Top;
    end;
    // check if TryBounds are better than NewBounds
    if (TryBounds.Right-TryBounds.Left)*(TryBounds.Bottom-TryBounds.Top)
     > (NewBounds.Right-NewBounds.Left)*(NewBounds.Bottom-NewBounds.Top)
    then
      NewBounds:=TryBounds;
  end;

var
  CurCaret: TPoint;
  SrcEdit: TSourceEditorInterface;
  AnchorBounds: TRect;
begin
  if (not NeedVisible) or Visible then exit;
  DesktopBounds:=Rect(30,30,Screen.DesktopWidth-30,Screen.DesktopHeight-50);
  NewBounds:=Bounds(DesktopBounds.Left,DesktopBounds.Top,30,30);
  
  if AnchorForm<>nil then begin
    // place near the AnchorForm
    AnchorBounds:=AnchorForm.BoundsRect;
    // try right of AnchorForm
    TryPosition(Bounds(AnchorBounds.Right+6,AnchorBounds.Top,
                      PreferredWidth,PreferredHeight),[akLeft,akTop]);
    // try left of AnchorForm
    TryPosition(Bounds(AnchorBounds.Left-6-PreferredWidth,AnchorBounds.Top,
                      PreferredWidth,PreferredHeight),[akRight,akTop]);
    // try below
    TryPosition(Bounds(AnchorBounds.Left,AnchorBounds.Bottom+6,
                       PreferredWidth,PreferredHeight),[akTop]);
  end else begin
    // place near the source editor caret
    CurCaret:=SrcEditCaret;
    SrcEdit:=SourceEditorManagerIntf.ActiveEditor;
    if CurCaret.Y<1 then
      CurCaret:=SrcEdit.CursorScreenXY;
    CurCaret:=SrcEdit.EditorControl.ClientToScreen(SrcEdit.ScreenToPixelPosition(CurCaret));

    // try below
    TryPosition(Bounds(CurCaret.X-(PreferredWidth div 2),CurCaret.Y+6,
                       PreferredWidth,PreferredHeight),[akTop]);
    // try above
    TryPosition(Bounds(CurCaret.X-(PreferredWidth div 2),
                       CurCaret.Y-6-PreferredHeight,
                       PreferredWidth,PreferredHeight),[akBottom]);
  end;
  
  //DebugLn(['TCodeHintFrm.UpdatePosition NewBounds=',dbgs(NewBounds),' BoundsRect=',dbgs(BoundsRect)]);
  BoundsRect:=NewBounds;
  Visible:=true;
end;

procedure TSrcEditHintWindow.Paint;
begin

end;

constructor TSrcEditHintWindow.Create(TheOwner: TComponent);
begin
  inherited Create(TheOwner);
  OnDestroy:=@FormDestroy;
  OnKeyDown:=@FormKeyDown;
  OnUTF8KeyPress:=@FormUTF8KeyPress;
  FPreferredWidth:=400;
  FPreferredHeight:=200;

  IdleTimer1:=TIdleTimer.Create(Self);
  IdleTimer1.Interval:=400;
  IdleTimer1.OnTimer:=@IdleTimer1Timer;

  FormCreate(Self);
end;

destructor TSrcEditHintWindow.Destroy;
begin
  Application.RemoveAllHandlersOfObject(Self);
  if SrcEditHintWindow=Self then
    SrcEditHintWindow:=nil;
  inherited Destroy;
end;

procedure TSrcEditHintWindow.UpdateHints(Immediately: boolean);
begin
  if Visible and not NeedVisible then begin
    // hide immediately
    Hide;
    exit;
  end;
  if not Immediately then begin
    IdleTimer1.AutoEnabled:=true;
    exit;
  end;
  //DebugLn(['TCodeHintFrm.UpdateHints Visible=',Visible]);
  IdleTimer1.AutoEnabled:=false;
  IdleTimer1.Enabled:=false;
  UpdatePosition;
  if Provider<>nil then Provider.UpdateHint;
end;

function TSrcEditHintWindow.NeedVisible: boolean;
begin
  if not HelpEnabled then exit(false);
  if (AnchorForm<>nil) then begin
    Result:=AnchorForm.IsVisible;
  end else begin
    Result:=(SourceEditorManagerIntf<>nil)
        and (SourceEditorManagerIntf.ActiveEditor<>nil);
  end;
end;

{ TCodeHintProvider }

procedure TCodeHintProvider.SetControl(const AValue: TWinControl);
begin
  if FControl=AValue then exit;
  FControl:=AValue;
end;

procedure TCodeHintProvider.GetPreferredSize(var PreferredWidth,
  PreferredHeight: integer);
begin

end;

procedure TCodeHintProvider.UpdateHint;
begin

end;

end.

