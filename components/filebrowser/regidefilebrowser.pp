unit RegIDEFileBrowser;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils,
  LazLoggerBase,
  Controls, Forms,
  LazIDEIntf, MenuIntf, IDECommands, IDEWindowIntf, BaseIDEIntf,
  IDEOptionsIntf, IDEOptEditorIntf,
  frmFileBrowser, {frmConfigFileBrowser, }ctrlfilebrowser, fraconfigfilebrowser;

procedure Register;

implementation

uses filebrowsertypes;

var
  FileBrowserOptionsFrameID: integer = 2000;
  FileBrowserCreator: TIDEWindowCreator; // set by Register procedure

procedure ShowFileBrowser(Sender: TObject);
begin
  IDEWindowCreators.ShowForm(FileBrowserCreator.FormName,true);
end;

procedure CreateFileBrowser(Sender: TObject; aFormName: string; var AForm: TCustomForm; DoDisableAutoSizing: boolean);

var
  C: TFileBrowserController;

begin
  // sanity check to avoid clashing with another package that has registered a window with the same name
  if CompareText(aFormName,'FileBrowser')<>0 then begin
    DebugLn(['ERROR: CreateFileBrowser: there is already a form with this name']);
    exit;
  end;
  C := LazarusIDE.OwningComponent.FindComponent('IDEFileBrowserController') as TFileBrowserController;
  IDEWindowCreators.CreateForm(AForm,TFileBrowserForm,true,C);
  AForm.Name:=aFormName;
  FileBrowserForm:=AForm as TFileBrowserForm;
  C.ConfigWindow(FileBrowserForm);
  FileBrowserForm.ShowFiles;
  if not DoDisableAutoSizing then
    AForm.EnableAutoSizing;
end;

procedure CreateController;

var
  C: TFileBrowserController;

begin
  C := LazarusIDE.OwningComponent.FindComponent('IDEFileBrowserController') as TFileBrowserController;
  if (C = nil) then
    begin
    C := TFileBrowserController.Create(LazarusIDE.OwningComponent);
    C.Name:='IDEFileBrowserController';
    end;
  C.ConfigFrame:=TFileBrowserOptionsFrame;
end;

procedure Register;

var
  CmdCatViewMenu: TIDECommandCategory;
  ViewFileBrowserCommand: TIDECommand;

begin
  // search shortcut category
  CmdCatViewMenu:=IDECommandList.FindCategoryByName(CommandCategoryViewName);
  // register shortcut
  ViewFileBrowserCommand:=RegisterIDECommand(CmdCatViewMenu,
    'ViewFileBrowser',SFileBrowserIDEMenuCaption,
    CleanIDEShortCut,nil,@ShowFileBrowser);
  // register menu item in View menu
  RegisterIDEMenuCommand(itmViewMainWindows,
    ViewFileBrowserCommand.Name,
    SFileBrowserIDEMenuCaption, nil, nil, ViewFileBrowserCommand);

  CreateController;

  // register dockable Window
  FileBrowserCreator:=IDEWindowCreators.Add(
    'FileBrowser',
    @CreateFileBrowser,nil,
    '200','100','400','400'  // default place at left=200, top=100, right=400, bottom=400
     // you can also define percentage values of screen or relative positions, see wiki
    );

  // add IDE options frame
  FileBrowserOptionsFrameID:=RegisterIDEOptionsEditor(GroupEnvironment,TFileBrowserOptionsFrame,
                                              FileBrowserOptionsFrameID)^.Index;

end;

end.

