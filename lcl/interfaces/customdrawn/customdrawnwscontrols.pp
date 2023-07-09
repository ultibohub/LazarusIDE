{
 *****************************************************************************
 *                         CustomDrawnWSControls.pp                          *
 *                              ---------------                              * 
 *                                                                           *
 *                                                                           *
 *****************************************************************************

 *****************************************************************************
  This file is part of the Lazarus Component Library (LCL)

  See the file COPYING.modifiedLGPL.txt, included in this distribution,
  for details about the license.
 *****************************************************************************
}
unit CustomDrawnWSControls;

{$mode objfpc}{$H+}

{$I customdrawndefines.inc}

interface

uses
  // LCL
  SysUtils, Classes, Types,
  //
  Controls, LCLType, LCLProc, Forms, Graphics,
  lazcanvas, lazregions,
  // Widgetset
  InterfaceBase, WSProc, WSControls, WSLCLClasses, customdrawnint,
  customdrawnproc;

type

  { TCDWSDragImageListResolution }

  TCDWSDragImageListResolution = class(TWSDragImageListResolution)
  published
{    class function BeginDrag(const ADragImageList: TDragImageListResolution; Window: HWND; AIndex, X, Y: Integer): Boolean; override;
    class function DragMove(const ADragImageList: TDragImageListResolution; X, Y: Integer): Boolean; override;
    class procedure EndDrag(const ADragImageList: TDragImageListResolution); override;
    class function HideDragImage(const ADragImageList: TDragImageListResolution;
      ALockedWindow: HWND; DoUnLock: Boolean): Boolean; override;
    class function ShowDragImage(const ADragImageList: TDragImageListResolution;
      ALockedWindow: HWND; X, Y: Integer; DoLock: Boolean): Boolean; override;}
  end;

  { TCDWSLazAccessibleObject }

  TCDWSLazAccessibleObject = class(TWSLazAccessibleObject)
  public
    class function CreateHandle(const AObject: TLazAccessibleObject): HWND; override;
    class procedure DestroyHandle(const AObject: TLazAccessibleObject); override;
    class procedure SetAccessibleDescription(const AObject: TLazAccessibleObject; const ADescription: string); override;
    class procedure SetAccessibleValue(const AObject: TLazAccessibleObject; const AValue: string); override;
    class procedure SetAccessibleRole(const AObject: TLazAccessibleObject; const ARole: TLazAccessibilityRole); override;
  end;

  { TCDWSControl }

  TCDWSControl = class(TWSControl)
  published
  end;

  { TCDWSWinControl }

  TCDWSWinControl = class(TWSWinControl)
  published
    //class procedure AddControl(const AControl: TControl); override;

    class function  GetText(const AWinControl: TWinControl; var AText: String): Boolean; override;


    class procedure SetBounds(const AWinControl: TWinControl; const ALeft, ATop, AWidth, AHeight: Integer); override;
    class procedure SetBorderStyle(const AWinControl: TWinControl; const ABorderStyle: TBorderStyle); override;
    class procedure SetChildZPosition(const AWinControl, AChild: TWinControl;
                                      const AOldPos, ANewPos: Integer;
                                      const AChildren: TFPList); override;
    class procedure SetColor(const AWinControl: TWinControl); override;
    class procedure SetFont(const AWinControl: TWinControl; const AFont: TFont); override;
    class procedure SetText(const AWinControl: TWinControl; const AText: string); override;

    class procedure ConstraintsChange(const AWinControl: TWinControl); override;
    class function  CreateHandle(const AWinControl: TWinControl;
          const AParams: TCreateParams): HWND; override;
    class procedure DestroyHandle(const AWinControl: TWinControl); override;
    class procedure Invalidate(const AWinControl: TWinControl); override;
    class procedure ShowHide(const AWinControl: TWinControl); override;

{    class function  CanFocus(const AWinControl: TWinControl): Boolean; override;
    class function  CreateHandle(const AWinControl: TWinControl;
          const AParams: TCreateParams): TLCLHandle; override;
    class procedure DestroyHandle(const AWinControl: TWinControl); override;
    class procedure Invalidate(const AWinControl: TWinControl); override;
    class procedure AddControl(const AControl: TControl); override;
    class function  GetClientBounds(const AWincontrol: TWinControl; var ARect: TRect): Boolean; override;
    class function  GetClientRect(const AWincontrol: TWinControl; var ARect: TRect): Boolean; override;
    class function GetDesignInteractive(const AWinControl: TWinControl; AClientPos: TPoint): Boolean; override;

    class procedure SetBiDiMode(const AWinControl: TWinControl; UseRightToLeftAlign, UseRightToLeftReading, UseRightToLeftScrollBar : Boolean); override;
    class procedure SetBounds(const AWinControl: TWinControl; const ALeft, ATop, AWidth, AHeight: Integer); override;
    class procedure SetBorderStyle(const AWinControl: TWinControl; const ABorderStyle: TBorderStyle); override;
    class procedure SetPos(const AWinControl: TWinControl; const ALeft, ATop: Integer); override;
    class procedure SetSize(const AWinControl: TWinControl; const AWidth, AHeight: Integer); override;
    class procedure ShowHide(const AWinControl: TWinControl); override; //TODO: rename to SetVisible(control, visible)
    class procedure SetColor(const AWinControl: TWinControl); override;
    class procedure SetCursor(const AWinControl: TWinControl; const ACursor: HCURSOR); override;
    class procedure SetFont(const AWinControl: TWinControl; const AFont: TFont); override;
    class procedure SetShape(const AWinControl: TWinControl; const AShape: HBITMAP); override;

    class procedure GetPreferredSize(const AWinControl: TWinControl;
      var PreferredWidth, PreferredHeight: integer; WithThemeSpace: Boolean); override;

    class function  GetText(const AWinControl: TWinControl; var AText: String): Boolean; override;
    class procedure SetText(const AWinControl: TWinControl; const AText: string); override;

    class procedure SetChildZPosition(const AWinControl, AChild: TWinControl;
                                      const AOldPos, ANewPos: Integer;
                                      const AChildren: TFPList); override;

    class procedure ConstraintsChange(const AWinControl: TWinControl); override;
    class procedure PaintTo(const AWinControl: TWinControl; ADC: HDC; X, Y: Integer); override;}
  end;

  { TCDWSGraphicControl }

  TCDWSGraphicControl = class(TWSGraphicControl)
  published
  end;

  { TCDWSCustomControl }

  TCDWSCustomControl = class(TWSCustomControl)
  published
//    class function CreateHandle(const AWinControl: TWinControl;
//          const AParams: TCreateParams): TLCLHandle; override;
  end;

  { TCDWSImageList }

  TCDWSImageList = class(TWSImageList)
  published
  end;

implementation

uses
  {$ifdef CD_Cocoa}
  customdrawn_cocoaproc,
  {$endif}
  customdrawnwsforms;

{ TCDWSLazAccessibleObject }

{$ifdef CD_Cocoa}
class function TCDWSLazAccessibleObject.CreateHandle(
  const AObject: TLazAccessibleObject): HWND;
begin
  Result := 0;
  if AObject = nil then Exit;

  // If this is a top-level window, then use the window Handle
  if AObject.OwnerControl is TCustomForm then
  begin
    Result := HWND(TCocoaWindow(TCustomForm(AObject.OwnerControl).Handle).CocoaForm);
    Exit;
  end;

  // Otherwise create a new handle
  Result := HWND(TCocoaAccessibleObject.alloc.init);
  TCocoaAccessibleObject(Result).LCLAcc := AObject;
  TCocoaAccessibleObject(Result).LCLControl := AObject.OwnerControl;
  TCocoaAccessibleObject(Result).LCLInjectedControl := nil;
end;

class procedure TCDWSLazAccessibleObject.DestroyHandle(
  const AObject: TLazAccessibleObject);
var
  lAccessibleHandle: TCocoaAccessibleObject;
begin
  if AObject.OwnerControl is TCustomForm then
    Exit;

  lAccessibleHandle := TCocoaAccessibleObject(AObject.Handle);
  lAccessibleHandle.release;
end;

class procedure TCDWSLazAccessibleObject.SetAccessibleDescription(
  const AObject: TLazAccessibleObject; const ADescription: string);
begin

end;

class procedure TCDWSLazAccessibleObject.SetAccessibleValue(
  const AObject: TLazAccessibleObject; const AValue: string);
begin

end;

class procedure TCDWSLazAccessibleObject.SetAccessibleRole(
  const AObject: TLazAccessibleObject; const ARole: TLazAccessibilityRole);
begin

end;
{$else}
class function TCDWSLazAccessibleObject.CreateHandle(
  const AObject: TLazAccessibleObject): HWND;
begin
  Result := 0;
end;

class procedure TCDWSLazAccessibleObject.DestroyHandle(
  const AObject: TLazAccessibleObject);
begin
end;

class procedure TCDWSLazAccessibleObject.SetAccessibleDescription(
  const AObject: TLazAccessibleObject; const ADescription: string);
begin

end;

class procedure TCDWSLazAccessibleObject.SetAccessibleValue(
  const AObject: TLazAccessibleObject; const AValue: string);
begin

end;

class procedure TCDWSLazAccessibleObject.SetAccessibleRole(
  const AObject: TLazAccessibleObject; const ARole: TLazAccessibilityRole);
begin

end;
{$endif}

class function  TCDWSWinControl.GetText(const AWinControl: TWinControl; var AText: String): Boolean;
begin
  AText := '';
  Result := false;
end;

class procedure TCDWSWinControl.SetBorderStyle(const AWinControl: TWinControl; const ABorderStyle: TBorderStyle);
begin
  RecreateWnd(AWinControl);
end;

class procedure TCDWSWinControl.SetChildZPosition(
  const AWinControl, AChild: TWinControl; const AOldPos, ANewPos: Integer;
  const AChildren: TFPList);
begin
  if not WSCheckHandleAllocated(AWincontrol, 'SetChildZPosition')
  then Exit;
  if not WSCheckHandleAllocated(AChild, 'SetChildZPosition (child)')
  then Exit;

{  if ANewPos = 0 // bottom
  then AfterWnd := HWND_BOTTOM
  else if ANewPos >= AChildren.Count - 1
  then AfterWnd := HWND_TOP
  else begin
    // Search for the first child above us with a handle
    // the child list is reversed form the windows order.
    // So the first window is the top window and is the last child
    // if we don't find a allocated handle then we are effectively not moved
    AfterWnd := 0;
    if AOldPos > ANewPos
    then StopPos := AOldPos              // The child is moved to the bottom, oldpos is on top of it
    else StopPos := AChildren.Count - 1; // the child is moved to the top

    for n := ANewPos + 1 to StopPos do
    begin
      Child := TWinControl(AChildren[n]);
      if Child.HandleAllocated
      then begin
        AfterWnd := Child.Handle;
        Break;
      end;
    end;

    if AfterWnd = 0 then Exit; // nothing to do
  end;
  Windows.SetWindowPos(AChild.Handle, AfterWnd, 0, 0, 0, 0,
    SWP_NOACTIVATE or SWP_NOMOVE or SWP_NOOWNERZORDER or
    SWP_NOSIZE or SWP_NOSENDCHANGING);}
end;

{------------------------------------------------------------------------------
  Method:  SetBounds
  Params:  AWinControl                  - the object which invoked this function
           ALeft, ATop, AWidth, AHeight - new dimensions for the control
  Pre:     AWinControl.HandleAllocated
  Returns: Nothing

  Resize a window
 ------------------------------------------------------------------------------}
class procedure TCDWSWinControl.SetBounds(const AWinControl: TWinControl;
  const ALeft, ATop, AWidth, AHeight: Integer);
var
  lCDWinControl: TCDWinControl;
begin
  //WriteLn(Format('[TCDWSWinControl.SetBounds Control=%s:%s x=%d y=%d w=%d h=%d',
  //  [AWinControl.Name, AWinControl.ClassName, ALeft, ATop, AWidth, AHeight]));
  lCDWinControl := TCDWinControl(AWinControl.Handle);
  lCDWinControl.Region.SetAsSimpleRectRegion(Bounds(ALeft, ATop, AWidth, AHeight));
  Invalidate(AWinControl);
end;

class procedure TCDWSWinControl.SetColor(const AWinControl: TWinControl);
begin
end;

class procedure TCDWSWinControl.SetFont(const AWinControl: TWinControl; const AFont: TFont);
begin
end;

class procedure TCDWSWinControl.SetText(const AWinControl: TWinControl; const AText: string);
begin
end;

class procedure TCDWSWinControl.ConstraintsChange(const AWinControl: TWinControl);
begin
end;

class function TCDWSWinControl.CreateHandle(const AWinControl: TWinControl;
  const AParams: TCreateParams): HWND;
var
  lCDWinControl, lCDParent: TCDWinControl;
  lControlPosInForm: TPoint;
begin
  lCDWinControl := TCDWinControl.Create;
  lCDWinControl.WinControl := AWinControl;
  lCDWinControl.Region := TLazRegionWithChilds.Create;
  lCDWinControl.Region.UserData := AWinControl;
  lControlPosInForm := FindControlPositionRelativeToTheForm(AWinControl);
  lCDWinControl.Region.SetAsSimpleRectRegion(Bounds(lControlPosInForm.X, lControlPosInForm.Y, AParams.Width, AParams.Height));

  Result := HWND(lCDWinControl);

  // Adding on a form
  if AWinControl.Parent is TCustomForm then
  begin
    AddCDWinControlToForm(TCustomForm(AWinControl.Parent), lCDWinControl);
  end
  // Adding on another control
  else if AWinControl.Parent is TWinControl then
  begin
    lCDParent := TCDWinControl(AWinControl.Parent.Handle);
    if lCDParent.Children = nil then lCDParent.Children := TFPList.Create;
    lCDParent.Children.Add(lCDWinControl);
    lCDParent.Region.Childs.Add(lCDWinControl.Region);
  end;
end;

class procedure TCDWSWinControl.DestroyHandle(const AWinControl: TWinControl);
begin
end;

class procedure TCDWSWinControl.Invalidate(const AWinControl: TWinControl);
begin
  // lpRect = nil updates entire client area of window
  CDWidgetset.InvalidateRect(AWinControl.Handle, nil, true);
end;

class procedure TCDWSWinControl.ShowHide(const AWinControl: TWinControl);
begin
end;

end.
