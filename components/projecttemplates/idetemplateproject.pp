unit IDETemplateProject;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, StrUtils, ContNrs,
  // LCL
  LResources, Forms, Controls, Graphics, Dialogs,
  // LazUtils
  LazFileUtils, LazLoggerBase,
  // IdeIntf
  ProjectIntf, NewItemIntf, MenuIntf, BaseIDEIntf, LazIDEIntf,
  // ProjectTemplates
  ProjectTemplates, frmTemplateSettings, frmTemplateVariables, ptstrconst;

type

  { TTemplateProjectDescriptor }

  TTemplateProjectDescriptor = class(TProjectDescriptor)
  Private
    FTemplate : TProjectTemplate;
    FProjectDirectory : String;
    FProjectName : String;
    FIgnoreExts,
    FVariables : TStrings;
    Function ShowOptionsDialog : TModalResult;
  public
    constructor Create(ATemplate : TProjectTemplate); overload;
    destructor Destroy; override;
    Function DoInitDescriptor : TModalResult; override;
    function GetLocalizedName: string; override;
    function GetLocalizedDescription: string; override;
    function InitProject(AProject: TLazProject) : TModalResult; override;
    function CreateStartFiles({%H-}AProject: TLazProject) : TModalResult; override;
    Property Template : TProjectTemplate Read FTemplate Write FTemplate;
  end;
  
procedure Register;

implementation

Var
  IDETemplates : TProjectTemplates = nil;
  itmFileNewFromTemplate : TIDEMenuSection;
  MenuList : TObjectList;

Type
  { TIDEObject }

  TIDEObject=Class(TObject)
    FProjDesc : TTemplateProjectDescriptor;
    FProjMenu : TIDEMenuCommand;
    Constructor Create(AProjDesc : TTemplateProjectDescriptor;
                       AProjMenu : TIDEMenuCommand);
  end;

{ TIDEObject }

constructor TIDEObject.Create(AProjDesc: TTemplateProjectDescriptor;
                              AProjMenu: TIDEMenuCommand);

begin
  FPRojDesc:=AProjDesc;
  FPRojMenu:=AProjMenu;
end;

Const
  STemplateSettings = 'itmTemplateSettings';
  SItmtemplate = 'itmTemplate';
  
{ ---------------------------------------------------------------------
  Configuration
  ---------------------------------------------------------------------}

Function GetTemplateDir : String;

begin
  With GetIDEConfigStorage('projtemplate.xml',True) do
    try
      Result:=GetValue('TemplateDir',AppendPathDelim(LazarusIDE.GetPrimaryConfigPath)+'templates');
    Finally
      Free;
    end;
end;

procedure SaveTemplateSettings;

begin
  With GetIDEConfigStorage('projtemplate.xml',False) do
    try
      SetValue('TemplateDir',IDETemplates.TemplateDir);
      WriteToDisk;
    Finally
      Free;
    end;
end;

{ ---------------------------------------------------------------------
  Registration
  ---------------------------------------------------------------------}

Procedure RegisterTemplateCategory;

begin
  NewIDEItems.Add(TNewIDEItemCategory.Create(STemplateCategory));
end;

procedure FileReplaceText(FN, AFrom, ATo: string);
var
  sl: TStringList;
  i: Integer;
begin
  //DebugLn(['FileReplaceText: From=', AFrom, ', To=', ATo]);
  if (not FileExistsUTF8(FN)) or (AFrom='') then
    exit;
  sl:=TStringList.Create;
  try
    sl.LoadFromFile(FN);
    for i:=0 to sl.Count-1 do
      sl[i]:=ReplaceText(sl[i],AFrom,ATo);
    sl.SaveToFile(fn);
  finally
    sl.Free;
  end;
end;

Procedure DoProject(Sender : TObject);

Var
  I : Integer;
  Desc : TTemplateProjectDescriptor;
  fn: string;

begin
  I:=MenuList.count-1;
  Desc:=Nil;
  While (Desc=Nil) and (I>=0) do
    begin
    With TIDEObject(MenuList[i]) do
      if FProjMenu=Sender then
        Desc:=FProjDesc;
    Dec(i);
    end;
  If Desc=Nil then
    exit;

  If Desc.ShowOptionsDialog<>mrOk then
    exit;
  Desc.Template.CreateProject(Desc.FProjectDirectory,Desc.FVariables);
  fn:=Desc.FProjectDirectory+Desc.FProjectName;
  FileReplaceText(fn+'.lpi',Desc.FTemplate.ProjectFile,Desc.FProjectName);
  FileReplaceText(fn+'.lpr',Desc.FTemplate.ProjectFile,Desc.FProjectName);
  FileReplaceText(fn+'.lps',Desc.FTemplate.ProjectFile,Desc.FProjectName);
  LazarusIDE.DoOpenProjectFile(Desc.FProjectDirectory+Desc.FProjectName+'.lpi',
    [ofProjectLoading,ofOnlyIfExists,ofConvertMacros,ofDoLoadResource]);
end;

procedure RegisterKnowntemplates;

Var
  I : Integer;
  ATemplate : TProjectTemplate;
  ProjDesc : TTemplateProjectDescriptor;
  ProjMenu : TIDEMenuCommand;

begin
  For I:=0 to IDETemplates.Count-1 do
    begin
    ATemplate:=IDETemplates[i];
    ProjDesc:=TTemplateProjectDescriptor.Create(ATemplate);
    RegisterProjectDescriptor(ProjDesc,STemplateCategory);
    ProjMenu:=RegisterIDEMenuCommand(itmFileNewFromTemplate,
                                     SItmtemplate+ATemplate.Name,
                                     ATemplate.Name,                                     
                                     Nil,@DoProject,Nil);
    MenuList.Add(TIDEObject.Create(ProjDesc,ProjMenu));
    end;
end;

procedure UnRegisterKnownTemplates;

Var
  I : Integer;

begin
  For I:=MenuList.Count-1 downto 0 do
    begin
    With TIDEObject(MenuList[i]) do
      begin
      ProjectDescriptors.UnregisterDescriptor(FProjDesc);
      FreeAndNil(FProjMenu);
      end;
    MenuList.Delete(I);
    end;
end;

procedure ChangeSettings(Sender : TObject);

begin
  With TTemplateSettingsForm.Create(Application) do
    Try
      Templates:=IDETemplates;
      if ShowModal=mrOK then
        begin
        SaveTemplateSettings;
        UnRegisterKnownTemplates;
        RegisterKnownTemplates;
        end;
    Finally
      Free;
    end;
end;

procedure Register;

begin
  RegisterIdeMenuCommand(itmOptionsDialogs,STemplateSettings,SProjectTemplateSettings,nil,@ChangeSettings);
  itmFileNewFromTemplate:=RegisterIDESubMenu(itmFileNew,
                                             'itmFileFromTemplate',
                                             SNewFromTemplate);
  IDETemplates:=TProjectTemplates.Create(GetTemplateDir);
  RegisterTemplateCategory;
  RegisterKnownTemplates;
end;


{ TTemplateProjectDescriptor }

function TTemplateProjectDescriptor.ShowOptionsDialog : TModalResult;

var
  I: Integer;
  
begin
  With TProjectVariablesForm.Create(Application) do
    try
      Caption:=Caption+' '+FTemplate.Name;
      FVariables.Assign(FTemplate.Variables);
      I:=FVariables.IndexOfName('ProjName');
      if (I<>-1) then
        begin
        EProjectName.Text:=FVariables.Values['ProjName'];
        FVariables.Delete(I);
        end;
      I:=FVariables.IndexOfName('ProjDir');
      if (I<>-1) then
        begin
        DEDestDir.Text:=FVariables.Values['ProjDir'];
        FVariables.Delete(I);
        end;
      Templates:=Templates;
      Variables:=FVariables;
      Result:=ShowModal;
      if Result=mrOK then
        begin
        FProjectDirectory:=IncludeTrailingPathDelimiter(ProjectDir);
        FProjectName:=ProjectName;
        FVariables.Values['ProjName']:=FProjectName;
        FVariables.Values['ProjDir']:=FProjectDirectory;
        end;
    finally
      Free;
    end;
end;


constructor TTemplateProjectDescriptor.Create(ATemplate : TProjectTemplate);
begin
  inherited Create;
  FTemplate:=ATemplate;
  If Assigned(FTemplate) then
    Name:=FTemplate.Name
  else
    Name:='Template Project';
  FVariables:=TStringList.Create;
  FIgnoreExts:=TStringList.Create;
  {$IF FPC_FULLVERSION>=30200}FIgnoreExts.UseLocale := false;{$ENDIF}
  FIgnoreExts.CommaText:='.lpr,.lps,.lfm,.lrs,.ico,.res,.lpi,.bak';
end;

destructor TTemplateProjectDescriptor.destroy;
begin
  FreeAndNil(FIgnoreExts);
  FTemplate:=Nil;
  FreeAndNil(FVariables);
  Inherited;
end;


function TTemplateProjectDescriptor.GetLocalizedName: string;
begin
  Result:=FTemplate.Name;
end;

function TTemplateProjectDescriptor.GetLocalizedDescription: string;
begin
  Result:=FTemplate.Description;
end;


function TTemplateProjectDescriptor.DoInitDescriptor: TModalResult;
var
  I : integer;
  Desc : TTemplateProjectDescriptor;
begin
  Result:=mrCancel;
  I:=MenuList.count-1;
  Desc:=Nil;
  While (Desc=Nil) and (I>=0) do
  begin
  With TIDEObject(MenuList[i]) do
    if FProjDesc=self then
      begin
      DoProject(FProjMenu);
      exit;
      end;
  Dec(i);
  end;
end;


function TTemplateProjectDescriptor.InitProject(AProject: TLazProject) : TModalResult;

Var
  I : Integer;
  AFile: TLazProjectFile;
  FN : String;
  L : TStringList;
  
begin
  AProject.AddPackageDependency('FCL');
  AProject.AddPackageDependency('LCL');
  AProject.Title:=FProjectName;
  AProject.UseAppBundle:=true;
  AProject.UseManifest:=true;
  AProject.LoadDefaultIcon;
  If Assigned(FTemplate) then
    begin
    FTemplate.CreateProjectDirs(FProjectDirectory,FVariables);
    AProject.ProjectInfoFile:=FProjectDirectory+FProjectName+'.lpi';
    For I:=0 to FTemplate.FileCount-1 do
      begin
      FN:=FTemplate.FileNames[I];
      If FilenameExtIs(FN,'lpr') then
        begin
        FN:=FProjectDirectory+FTemplate.TargetFileName(FN,FVariables);
        AFile:=AProject.CreateProjectFile(FN);
        AFile.IsPartOfProject:=true;
        AProject.AddFile(AFile,False);
        AProject.MainFileID:=0;
        L:=TStringList.Create;
        try
          FTemplate.CreateFile(I,L,FVariables);
          AFile.SetSourceText(L.Text);
        Finally
          L.Free;
        end;
        end;
      end;
    Result:=mrOK;
    end
  else
    Result:=mrCancel;

Result:=mrCancel;

end;

Function TTemplateProjectDescriptor.CreateStartFiles(AProject: TLazProject) : TModalresult;

Var
  I : Integer;
  FN : String;

begin
  if Assigned(FTemplate) then
    begin
    Result:=mrOK;
    For I:=0 to FTemplate.FileCount-1 do
      begin
      FN:=FTemplate.FileNames[I];
      If (FIgnoreExts.IndexOf(ExtractFileExt(FN))=-1) then
        begin
        FN:=FProjectDirectory+FTemplate.TargetFileName(FN,FVariables);
        LazarusIDE.DoOpenEditorFile(FN, -1, -1, [ofProjectLoading,ofQuiet,ofAddToProject]);
        end;
      end;
    end
  else
    Result:=mrCancel;
end;

Initialization
  MenuList:=TObjectList.Create;
Finalization
  FreeAndNil(IDETemplates);
  FreeAndNil(MenuList);
end.
