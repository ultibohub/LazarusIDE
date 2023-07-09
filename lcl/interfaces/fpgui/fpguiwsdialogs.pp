{ $Id: FpGuiwsdialogs.pp 5319 2004-03-17 20:11:29Z marc $}
{
 *****************************************************************************
 *                              FpGuiWSDialogs.pp                               * 
 *                              --------------                               * 
 *                                                                           *
 *                                                                           *
 *****************************************************************************

 *****************************************************************************
  This file is part of the Lazarus Component Library (LCL)

  See the file COPYING.LCL, included in this distribution,
  for details about the license.
 *****************************************************************************
}
unit FpGuiWSDialogs;

{$mode objfpc}{$H+}

interface

uses
////////////////////////////////////////////////////
// I M P O R T A N T                                
////////////////////////////////////////////////////
// To get as little as posible circles,
// uncomment only when needed for registration
////////////////////////////////////////////////////
  Dialogs,
////////////////////////////////////////////////////
// Bindings
  fpg_base, fpg_main, fpg_dialogs, fpguiwsprivate,
  LCLType, WSDialogs, WSLCLClasses;

type

  { TFpGuiWSCommonDialog }

  TFpGuiWSCommonDialog = class(TWSCommonDialog)
  private
  protected
  published
    class function CreateHandle(const ACommonDialog: TCommonDialog): TLCLHandle; override;
    class procedure ShowModal(const ACommonDialog: TCommonDialog); override;
    class procedure DestroyHandle(const ACommonDialog: TCommonDialog); override;
  end;

  { TFpGuiWSFileDialog }

  TFpGuiWSFileDialog = class(TWSFileDialog)
  private
  protected
  published
    class function CreateHandle(const ACommonDialog: TCommonDialog): TLCLHandle; override;
  end;

  { TFpGuiWSOpenDialog }

  TFpGuiWSOpenDialog = class(TWSOpenDialog)
  private
  protected
  published
    class function CreateHandle(const ACommonDialog: TCommonDialog): TLCLHandle; override;
  end;

  { TFpGuiWSSaveDialog }

  TFpGuiWSSaveDialog = class(TWSSaveDialog)
  private
  protected
  published
    class function CreateHandle(const ACommonDialog: TCommonDialog): TLCLHandle; override;
  end;

  { TFpGuiWSSelectDirectoryDialog }

  TFpGuiWSSelectDirectoryDialog = class(TWSSelectDirectoryDialog)
  private
  protected
  public
  end;

  { TFpGuiWSColorDialog }

  TFpGuiWSColorDialog = class(TWSColorDialog)
  private
  protected
  public
  published
    class function CreateHandle(const ACommonDialog: TCommonDialog): TLCLHandle; override;
  end;

  { TFpGuiWSColorButton }

  TFpGuiWSColorButton = class(TWSColorButton)
  private
  protected
  public
  end;

  { TFpGuiWSFontDialog }

  TFpGuiWSFontDialog = class(TWSFontDialog)
  private
  protected
  published
    class function CreateHandle(const ACommonDialog: TCommonDialog): TLCLHandle; override;
  end;


implementation

{ TFpGuiWSColorDialog }

class function TFpGuiWSColorDialog.CreateHandle(
  const ACommonDialog: TCommonDialog): TLCLHandle;
begin
  Result := TLCLHandle(TFPGUIPrivateColorDialog.Create(ACommonDialog));
end;

{ TFpGuiWSCommonDialog }

class function TFpGuiWSCommonDialog.CreateHandle(
  const ACommonDialog: TCommonDialog): TLCLHandle;
begin
  Result := TLCLHandle(TFPGUIPrivateCommonDialog.Create(ACommonDialog));
end;

class procedure TFpGuiWSCommonDialog.ShowModal(
  const ACommonDialog: TCommonDialog);
begin
  TFPGUIPrivateCommonDialog(ACommonDialog.Handle).ShowDialog;
end;

class procedure TFpGuiWSCommonDialog.DestroyHandle(
  const ACommonDialog: TCommonDialog);
var
  FPGDialog: TFPGUIPrivateCommonDialog;
begin
  FPGDialog := TFPGUIPrivateCommonDialog(ACommonDialog.Handle);
  FPGDialog.Free;
end;

{ TFpGuiWSFileDialog }

class function TFpGuiWSFileDialog.CreateHandle(
  const ACommonDialog: TCommonDialog): TLCLHandle;
begin
  Result := TLCLHandle(TFPGUIPrivateFileDialog.Create(ACommonDialog));
end;

{ TFpGuiWSOpenDialog }

class function TFpGuiWSOpenDialog.CreateHandle(
  const ACommonDialog: TCommonDialog): TLCLHandle;
begin
  Result := TLCLHandle(TFPGUIPrivateOpenDialog.Create(ACommonDialog));
end;

{ TFpGuiWSSaveDialog }

class function TFpGuiWSSaveDialog.CreateHandle(
  const ACommonDialog: TCommonDialog): TLCLHandle;
begin
  Result := TLCLHandle(TFPGUIPrivateSaveDialog.Create(ACommonDialog));
end;

{ TFpGuiWSFontDialog }

class function TFpGuiWSFontDialog.CreateHandle(
  const ACommonDialog: TCommonDialog): TLCLHandle;
begin
  Result := TLCLHandle(TFPGUIPrivateFontDialog.Create(ACommonDialog));
end;

initialization

////////////////////////////////////////////////////
// I M P O R T A N T
////////////////////////////////////////////////////
// To improve speed, register only classes
// which actually implement something
////////////////////////////////////////////////////
//  RegisterWSComponent(TCommonDialog, TFpGuiWSCommonDialog);
//  RegisterWSComponent(TFileDialog, TFpGuiWSFileDialog);
//  RegisterWSComponent(TOpenDialog, TFpGuiWSOpenDialog);
//  RegisterWSComponent(TSaveDialog, TFpGuiWSSaveDialog);
//  RegisterWSComponent(TSelectDirectoryDialog, TFpGuiWSSelectDirectoryDialog);
//  RegisterWSComponent(TColorDialog, TFpGuiWSColorDialog);
//  RegisterWSComponent(TColorButton, TFpGuiWSColorButton);
//  RegisterWSComponent(TFontDialog, TFpGuiWSFontDialog);
////////////////////////////////////////////////////
end.
