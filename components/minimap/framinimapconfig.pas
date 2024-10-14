{
 *****************************************************************************
  See the file COPYING.modifiedLGPL.txt, included in this distribution,
  for details about the license.
 *****************************************************************************

  Abstract:
    Options dialog for minimap
}
unit fraMiniMapConfig;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, StdCtrls, ColorBox, Dialogs, SpinEx,
  IDEOptionsIntf, IDEOptEditorIntf;

type

  { TMiniMapConfigFrame }

  TMiniMapConfigFrame = class(TAbstractIDEOptionsEditor)
    cbEnabled: TCheckBox;
    cbViewWindow: TColorBox;
    cbViewText: TColorBox;
    CDView: TColorDialog;
    cbAlignLeft: TCheckBox;
    lblViewWindowColor: TLabel;
    lblViewWindowTextColor: TLabel;
    lblMapWidth: TLabel;
    lblInitialFontSize: TLabel;
    seWidth: TSpinEditEx;
    seInitialFontSize: TSpinEditEx;
  private

  public
    function GetTitle: String; override;
    procedure Setup({%H-}ADialog: TAbstractOptionsEditorDialog); override;
    procedure ReadSettings({%H-}AOptions: TAbstractIDEOptions); override;
    procedure WriteSettings({%H-}AOptions: TAbstractIDEOptions); override;
    class function SupportedOptionsClass: TAbstractIDEOptionsClass; override;
  end;

implementation

uses CtrlMiniMap, StrMiniMap;
{$R *.lfm}

{ TMiniMapConfigFrame }

function TMiniMapConfigFrame.GetTitle: String;
begin
  Result:=SMinimapConfigTitle;
end;

procedure TMiniMapConfigFrame.Setup(ADialog: TAbstractOptionsEditorDialog);
begin
  cbEnabled.Caption:=SShowMinimap;
  cbAlignLeft.Caption:=SPutMapLeftOfEditorRe;
  lblMapWidth.Caption:=SMapWidth;
  lblInitialFontSize.Caption:=SInitialFontSize;
  lblViewWindowColor.Caption:=SViewWindowColor;
  lblViewWindowTextColor.Caption:=SViewWindowTextColor;
end;

procedure TMiniMapConfigFrame.ReadSettings(AOptions: TAbstractIDEOptions);

var
  C : TMiniMapController;

begin
  C:=MiniMapController;
  cbEnabled.Checked:=C.Enabled;
  cbAlignLeft.Checked:=C.AlignLeft;
  seWidth.Value:=C.MapWidth;
  seInitialFontSize.Value:=C.InitialViewFontSize;
  cbViewWindow.Selected:=C.ViewWindowColor;
  cbViewText.Selected:=C.ViewWindowTextColor;
end;

procedure TMiniMapConfigFrame.WriteSettings(AOptions: TAbstractIDEOptions);
var
  C : TMiniMapController;

begin
  C:=MiniMapController;
  C.Enabled:=cbEnabled.Checked;
  C.AlignLeft:=cbAlignLeft.Checked;
  C.MapWidth:=seWidth.Value;
  C.InitialViewFontSize:=seInitialFontSize.Value;
  C.ViewWindowColor:=cbViewWindow.Selected;
  C.ViewWindowTextColor:=cbViewText.Selected;
  C.SaveConfig;
  C.ReconfigurePanels;
end;

class function TMiniMapConfigFrame.SupportedOptionsClass: TAbstractIDEOptionsClass;
begin
  Result:=IDEEditorGroups.GetByIndex(GroupEnvironment)^.GroupClass;
end;

end.

