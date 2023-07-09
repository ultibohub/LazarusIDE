{ $Id: FpGuiwscontrols.pp 5319 2004-03-17 20:11:29Z marc $}
{
 *****************************************************************************
 *                              FpGuiWSControls.pp                              * 
 *                              ---------------                              * 
 *                                                                           *
 *                                                                           *
 *****************************************************************************

 *****************************************************************************
  This file is part of the Lazarus Component Library (LCL)

  See the file COPYING.LCL, included in this distribution,
  for details about the license.
 *****************************************************************************
}
unit FpGuiWSControls;

{$mode objfpc}{$H+}

interface

uses
  // FCL
  Classes, sysutils,
  // Bindings
  fpguiwsprivate, fpguiobjects, fpg_panel,
  // LCL
  Controls, LCLType,  Graphics,
  // Widgetset
  fpguiproc, WSControls, WSLCLClasses;

type

  { TFpGuiWSDragImageList }

  TFpGuiWSDragImageList = class(TWSDragImageListResolution)
  private
  protected
  public
  end;

  { TFpGuiWSControl }

  TFpGuiWSControl = class(TWSControl)
  private
  protected
  public
  end;

  { TFpGuiWSWinControl }

  TFpGuiWSWinControl = class(TWSWinControl)
  private
  protected
  published
    class function  CreateHandle(const AWinControl: TWinControl;
          const AParams: TCreateParams): TLCLHandle; override;
    class procedure DestroyHandle(const AWinControl: TWinControl); override;
    class procedure Invalidate(const AWinControl: TWinControl); override;
    class function  GetClientRect(const AWincontrol: TWinControl;
                             var ARect: TRect): Boolean; override;
    class function  GetDefaultClientRect(const AWinControl: TWinControl;
                             const aLeft, aTop, aWidth, aHeight: integer;
                             var aClientRect: TRect): Boolean; override;
    class procedure GetPreferredSize(const AWinControl: TWinControl;
                            var PreferredWidth, PreferredHeight: integer;
                            WithThemeSpace: Boolean); override;
    class procedure PaintTo(const AWinControl: TWinControl; ADC: HDC; X, Y: Integer); override;
    class procedure SetBounds(const AWinControl: TWinControl; const ALeft, ATop, AWidth, AHeight: Integer); override;
    class procedure SetPos(const AWinControl: TWinControl; const ALeft, ATop: Integer); override;
    class procedure SetSize(const AWinControl: TWinControl; const AWidth, AHeight: Integer); override;
    class procedure ShowHide(const AWinControl: TWinControl); override; //TODO: rename to SetVisible(control, visible)
    class procedure SetColor(const AWinControl: TWinControl); override;
    class function  GetText(const AWinControl: TWinControl; var AText: String): Boolean; override;
    class procedure SetText(const AWinControl: TWinControl; const AText: string); override;
    class procedure SetCursor(const AWinControl: TWinControl; const ACursor: HCursor); override;

{    class procedure AddControl(const AControl: TControl); override;
    class procedure SetBorderStyle(const AWinControl: TWinControl; const ABorderStyle: TBorderStyle); override;}

    class procedure SetFont(const AWinControl: TWinControl; const AFont: TFont); override;

{    class procedure ConstraintsChange(const AWinControl: TWinControl); override;}
    class function CanFocus(const AWincontrol: TWinControl): Boolean; override;
  end;

  { TFpGuiWSGraphicControl }

  TFpGuiWSGraphicControl = class(TWSGraphicControl)
  private
  protected
  public
  published
  end;

  { TFpGuiWSCustomControl }

  TFpGuiWSCustomControl = class(TWSCustomControl)
  private
  protected
  public
  end;

  { TFpGuiWSImageList }

  TFpGuiWSImageList = class(TWSImageList)
  private
  protected
  public
  end;


implementation

uses
  fpg_widget, fpg_base;

{ TFpGuiWSWinControl }

{------------------------------------------------------------------------------
  Method: TFpGuiWSWinControl.CreateHandle
  Params:  None
  Returns: Nothing
 ------------------------------------------------------------------------------}
class function TFpGuiWSWinControl.CreateHandle(const AWinControl: TWinControl;
  const AParams: TCreateParams): TLCLHandle;
begin
  {$ifdef VerboseFPGUIIntf}
    WriteLn(Self.ClassName,'.CreateHandle ',AWinControl.Name);
  {$endif}

  Result := TLCLHandle(TFPGUIPrivateWidget.Create(AWinControl, AParams));
end;

{------------------------------------------------------------------------------
  Method: TFpGuiWSWinControl.DestroyHandle
  Params:  None
  Returns: Nothing
 ------------------------------------------------------------------------------}
class procedure TFpGuiWSWinControl.DestroyHandle(const AWinControl: TWinControl);
begin
  TFPGUIPrivateWidget(AWinControl.Handle).Free;

  AWinControl.Handle := 0;
end;

{------------------------------------------------------------------------------
  Method: TFpGuiWSWinControl.Invalidate
  Params:  None
  Returns: Nothing
 ------------------------------------------------------------------------------}
class procedure TFpGuiWSWinControl.Invalidate(const AWinControl: TWinControl);
var
  FPWidget: TfpgWidget;
begin
  FPWidget := TFPGUIPrivateWidget(AWinControl.Handle).Widget;
  FPWidget.Invalidate;
end;

class function TFpGuiWSWinControl.GetClientRect(const AWincontrol: TWinControl;
  var ARect: TRect): Boolean;
begin
  TFPGUIPrivateWidget(AWincontrol.Handle).GetClientRect(ARect);
  Result:=true;
end;

class function TFpGuiWSWinControl.GetDefaultClientRect(
  const AWinControl: TWinControl; const aLeft, aTop, aWidth, aHeight: integer;
  var aClientRect: TRect): Boolean;
begin
  if AWincontrol.HandleAllocated then begin
    TFPGUIPrivateWidget(AWincontrol.Handle).GetDefaultClientRect(aClientRect);
    Result:=true;
  end else begin
    Result:=false;
  end;
end;

class procedure TFpGuiWSWinControl.GetPreferredSize(
  const AWinControl: TWinControl; var PreferredWidth, PreferredHeight: integer;
  WithThemeSpace: Boolean);
begin
  TFPGUIPrivateWidget(AWinControl.Handle).GetPreferredSize(PreferredWidth,PreferredHeight,WithThemeSpace);
end;

class procedure TFpGuiWSWinControl.PaintTo(const AWinControl: TWinControl;
  ADC: HDC; X, Y: Integer);
//var
//  AADC: TFPGUIDeviceContext absolute ADC;
begin
//  TFPGUIPrivateWidget(AWinControl.Handle).PaintTo(AADC.fpgCanvas,X,Y);
end;

{------------------------------------------------------------------------------
  Method: TFpGuiWSWinControl.SetBounds
  Params:  AWinControl - the calling object
           ALeft, ATop - Position
           AWidth, AHeight - Size
  Returns: Nothing

  Sets the position and size of a widget
 ------------------------------------------------------------------------------}
class procedure TFpGuiWSWinControl.SetBounds(const AWinControl: TWinControl;
  const ALeft, ATop, AWidth, AHeight: Integer);
begin
  TFPGUIPrivateWidget(AWinControl.Handle).SetPosition(ALeft,ATop);
  TFPGUIPrivateWidget(AWinControl.Handle).SetSize(AWidth,AHeight);
end;

{------------------------------------------------------------------------------
  Method: TFpGuiWSWinControl.SetPos
  Params:  AWinControl - the calling object
           ALeft, ATop - Position
  Returns: Nothing

  Sets the position of a widget
 ------------------------------------------------------------------------------}
class procedure TFpGuiWSWinControl.SetPos(const AWinControl: TWinControl;
  const ALeft, ATop: Integer);
begin
  TFPGUIPrivateWidget(AWinControl.Handle).SetPosition(ALeft,ATop);
end;

{------------------------------------------------------------------------------
  Method: TFpGuiWSWinControl.SetSize
  Params:  AWinControl     - the calling object
           AWidth, AHeight - Size
  Returns: Nothing

  Sets the size of a widget
 ------------------------------------------------------------------------------}
class procedure TFpGuiWSWinControl.SetSize(const AWinControl: TWinControl;
  const AWidth, AHeight: Integer);
begin
  TFPGUIPrivateWidget(AWinControl.Handle).SetSize(AWidth,AHeight);
end;

{------------------------------------------------------------------------------
  Method: TFpGuiWSWinControl.ShowHide
  Params:  AWinControl     - the calling object
  Returns: Nothing

  Shows or hides a widget.
 ------------------------------------------------------------------------------}
class procedure TFpGuiWSWinControl.ShowHide(const AWinControl: TWinControl);
var
  FPPrivate: TFPGUIPrivateWidget;
begin
  FPPrivate := TFPGUIPrivateWidget(AWinControl.Handle);
  FPPrivate.Visible := AWinControl.Visible;
end;

class procedure TFpGuiWSWinControl.SetColor(const AWinControl: TWinControl);
var
  FPPrivate: TFPGUIPrivateWidget;
begin
  FPPrivate := TFPGUIPrivateWidget(AWinControl.Handle);
  FPPrivate.Widget.BackgroundColor:=TColorToTfpgColor(AWinControl.Color)
end;

class function TFpGuiWSWinControl.GetText(const AWinControl: TWinControl;
  var AText: String): Boolean;
var
  FPPrivateWidget: TFPGUIPrivateWidget;
begin
  FPPrivateWidget := TFPGUIPrivateWidget(AWinControl.Handle);
  Result := FPPrivateWidget.HasStaticText;
  if Result then AText := FPPrivateWidget.GetText;
end;

class procedure TFpGuiWSWinControl.SetText(const AWinControl: TWinControl;
  const AText: string);
var
  FPPrivateWidget: TFPGUIPrivateWidget;
begin
  FPPrivateWidget := TFPGUIPrivateWidget(AWinControl.Handle);
  FPPrivateWidget.SetText(AText);
end;

class procedure TFpGuiWSWinControl.SetCursor(const AWinControl: TWinControl;
  const ACursor: HCursor);
var
  FPPrivateWidget: TFPGUIPrivateWindow;
begin
  FPPrivateWidget := TFPGUIPrivateWindow(AWinControl.Handle);
  FPPrivateWidget.SetCursor(integer(ACursor));
end;

class procedure TFpGuiWSWinControl.SetFont(const AWinControl: TWinControl;
  const AFont: TFont);
var
  FPPrivateWidget: TFPGUIPrivateWindow;
begin
  FPPrivateWidget := TFPGUIPrivateWindow(AWinControl.Handle);
  FPPrivateWidget.Font:=AFont;
end;

class function TFpGuiWSWinControl.CanFocus(const AWincontrol: TWinControl
  ): Boolean;
var
  FPPrivateWidget: TFPGUIPrivateWindow;
begin
  FPPrivateWidget := TFPGUIPrivateWindow(AWinControl.Handle);
  Result:=FPPrivateWidget.Widget.Focusable;
end;

end.
