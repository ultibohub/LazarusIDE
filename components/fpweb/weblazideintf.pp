{
  Copyright (C) 2007 Michael Van Canneyt

  This library is free software; you can redistribute it and/or modify it
  under the terms of the GNU Library General Public License as published by
  the Free Software Foundation; either version 2 of the License, or (at your
  option) any later version.

  This program is distributed in the hope that it will be useful, but WITHOUT
  ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or
  FITNESS FOR A PARTICULAR PURPOSE. See the GNU Library General Public License
  for more details.

  You should have received a copy of the GNU Library General Public License
  along with this library; if not, write to the Free Software Foundation,
  Inc., 51 Franklin Street - Fifth Floor, Boston, MA 02110-1335, USA.
}
{$mode objfpc}
{$H+}
unit WebLazIDEIntf;

interface

uses
  Classes, SysUtils, fpWeb, fpHTML, fpdatasetform,
  fpextjs, extjsjson, extjsxml, fpjsonrpc, jstree,jsparser,
  fpextdirect,fpwebdata, fpwebfile,
{$IF FPC_FULLVERSION>=30004}
  fphttpclient,
  fphttpserver,
{$ENDIF}
{$IF FPC_FULLVERSION>=30100}
  fphttpwebclient,
  fpoauth2,
  fpoauth2ini,
{$ENDIF}
  webjsonrpc,
  Controls, Dialogs, Forms,
  frmnewhttpapp,
  LazFileUtils,
  IDEExternToolIntf, ProjectIntf,
  LazIDEIntf, SrcEditorIntf, IDEMsgIntf,
  fpWebStrConsts;

type
  { TCGIApplicationDescriptor }

  TCGIApplicationDescriptor = class(TProjectDescriptor)
  public
    constructor Create; override;
    function GetLocalizedName: string; override;
    function GetLocalizedDescription: string; override;
    function InitProject(AProject: TLazProject): TModalResult; override;
    function CreateStartFiles(AProject: TLazProject): TModalResult; override;
  end;
  { TApacheApplicationDescriptor }

  TApacheApplicationDescriptor = class(TProjectDescriptor)
  public
    constructor Create; override;
    function GetLocalizedName: string; override;
    function GetLocalizedDescription: string; override;
    function InitProject(AProject: TLazProject): TModalResult; override;
    function CreateStartFiles(AProject: TLazProject): TModalResult; override;
  end;

  { TCustomCGIApplicationDescriptor }
  TCustomCGIApplicationDescriptor = class(TProjectDescriptor)
  public
    constructor Create; override;
    function GetLocalizedName: string; override;
    function GetLocalizedDescription: string; override;
    function InitProject(AProject: TLazProject): TModalResult; override;
    function CreateStartFiles(AProject: TLazProject): TModalResult; override;
  end;

  { TCustomFCGIApplicationDescriptor }
  TCustomFCGIApplicationDescriptor = class(TProjectDescriptor)
  public
    constructor Create; override;
    function GetLocalizedName: string; override;
    function GetLocalizedDescription: string; override;
    function InitProject(AProject: TLazProject): TModalResult; override;
    function CreateStartFiles(AProject: TLazProject): TModalResult; override;
  end;

  { TFCGIApplicationDescriptor }

  TFCGIApplicationDescriptor = class(TProjectDescriptor)
  public
    constructor Create; override;
    function GetLocalizedName: string; override;
    function GetLocalizedDescription: string; override;
    function InitProject(AProject: TLazProject): TModalResult; override;
    function CreateStartFiles(AProject: TLazProject): TModalResult; override;
  end;

  { TFileDescPascalUnitWithCGIDataModule }

  TFileDescWebDataModule = class(TFileDescPascalUnitWithResource)
  public
    constructor Create; override;
    function GetInterfaceUsesSection: string; override;
    function GetLocalizedName: string; override;
    function GetLocalizedDescription: string; override;
    function GetImplementationSource(const Filename, SourceName, ResourceName: string): string;override;
  end;

  { TFileDescFileDataModule }

  TFileDescFileDataModule = class(TFileDescPascalUnitWithResource)
  public
    constructor Create; override;
    function GetInterfaceUsesSection: string; override;
    function GetLocalizedName: string; override;
    function GetLocalizedDescription: string; override;
    function GetImplementationSource(const Filename, SourceName, ResourceName: string): string;override;
  end;


  TFileDescHTMLModule = class(TFileDescPascalUnitWithResource)
  public
    constructor Create; override;
    function GetInterfaceUsesSection: string; override;
    function GetLocalizedName: string; override;
    function GetLocalizedDescription: string; override;
    function GetImplementationSource(const Filename, SourceName, ResourceName: string): string;override;
  end;


  { TFileDescWebProviderDataModule }

  TFileDescWebProviderDataModule = class(TFileDescPascalUnitWithResource)
  public
    constructor Create; override;
    function GetInterfaceUsesSection: string; override;
    function GetLocalizedName: string; override;
    function GetLocalizedDescription: string; override;
    function GetImplementationSource(const Filename, SourceName, ResourceName: string): string;override;
  end;

  { TFileDescWebJSONRPCModule }

  TFileDescWebJSONRPCModule = class(TFileDescPascalUnitWithResource)
  public
    constructor Create; override;
    function GetInterfaceUsesSection: string; override;
    function GetLocalizedName: string; override;
    function GetLocalizedDescription: string; override;
    function GetImplementationSource(const Filename, SourceName, ResourceName: string): string;override;
  end;


  { TFileDescExtDirectModule }

  TFileDescExtDirectModule = class(TFileDescPascalUnitWithResource)
  public
    constructor Create; override;
    function GetInterfaceUsesSection: string; override;
    function GetLocalizedName: string; override;
    function GetLocalizedDescription: string; override;
    function GetImplementationSource(const Filename, SourceName, ResourceName: string): string;override;
  end;

  { TJSFileDescriptor }

  TJSFileDescriptor = class(TProjectFileDescriptor)
  public
    constructor Create; override;
    function GetLocalizedName: string; override;
    function GetLocalizedDescription: string; override;
    function GetResourceSource(const ResourceName: string): string; override;
    function CreateSource(const Filename, SourceName,
                          ResourceName: string): string; override;
    procedure UpdateDefaultPascalFileExtension(const DefPasExt: string); override;
  end;

  TJSSyntaxChecker = Class(TComponent)
  private
    FSFN: String;
  Public
    Procedure ShowMessage(Const Msg : String);
    Procedure ShowMessage(Const Fmt : String; Args : Array of const);
    Procedure ShowException(Const Msg : String; E : Exception);
    function CheckJavaScript (S : TStream): TModalResult;
    function CheckSource(Sender: TObject; var Handled: boolean): TModalResult;
    Property SourceFileName : String Read FSFN;
 end;

  { THTTPApplicationDescriptor }
  THTTPApplicationDescriptor = class(TProjectDescriptor)
  private
    FThreaded : Boolean;
    fServeFiles : TServeFiles;
    FDir,
    FLoc : String;
    FPort : Integer;
    FDefaultFiles : Boolean;
    FStandardModule : TStandardModule;
    function GetOptions: TModalResult;
  public
    constructor Create; override;
    function DoInitDescriptor: TModalResult; override;
    function GetLocalizedName: string; override;
    function GetLocalizedDescription: string; override;
    function InitProject(AProject: TLazProject): TModalResult; override;
    function CreateStartFiles(AProject: TLazProject): TModalResult; override;
  end;

var
  ProjectDescriptorCustomCGIApplication: TCustomCGIApplicationDescriptor;
  ProjectDescriptorCGIApplication: TCGIApplicationDescriptor;
  ProjectDescriptorApacheApplication: TApacheApplicationDescriptor;
  ProjectDescriptorCustomFCGIApplication: TCustomFCGIApplicationDescriptor;
  ProjectDescriptorFCGIApplication: TFCGIApplicationDescriptor;
  FileDescriptorHTMLModule: TFileDescHTMLModule;
  FileDescriptorWebModule: TFileDescWebDataModule;
  FileDescriptorWebProviderDataModule: TFileDescWebProviderDataModule;
  FileDescriptorJSONRPCModule : TFileDescWebJSONRPCModule;
  FileDescriptorExtDirectModule : TFileDescExtDirectModule;
  FileDescriptorFileDataModule : TFileDescFileDataModule;
  ProjectDescriptorHTTPApplication : THTTPApplicationDescriptor;
  AChecker : TJSSyntaxChecker;

procedure Register;

implementation

uses LazarusPackageIntf,FormEditingIntf, PropEdits, DBPropEdits, sqldbwebdata, LResources,
     frmrpcmoduleoptions, registersqldb, sqlstringspropertyeditordlg;

Const
  fpWebTab = 'fpWeb';

Procedure RegisterHTMLComponents;
begin
  RegisterComponents(fpWebTab,[THTMLDatasetContentProducer,
                               THTMLSelectProducer,
                               THTMLDatasetSelectProducer,
                               THTMLEntityProducer,
                               THTMLPageProducer
                               ])

end;

Procedure RegisterDatasetComponents;

begin
  RegisterComponents(fpWebTab,[THTMLDataSetFormShowProducer,
                               THTMLDataSetFormEditProducer,
                               THTMLDataSetFormGridProducer,
                               TWebdataInputAdaptor,TFPWebDataProvider, TSQLDBWebDataProvider,
                               TExtJSJSonWebdataInputAdaptor,TExtJSJSONDataFormatter,
                               TExtJSXMLWebdataInputAdaptor,TExtJSXMLDataFormatter,
                               TJSONRPCHandler,TJSONRPCDispatcher,TSessionJSONRPCDispatcher,
                               TJSONRPCContentProducer,
                               TExtDirectDispatcher,TExtDirectContentProducer
                               ]);
end;

{$IF FPC_FULLVERSION>=30100}
procedure RegisterTFPHTTPWebClient;
begin
end;
procedure RegisterTOAuth2Handler;
begin
  RegisterComponents(fpWebTab,[TOAuth2Handler]);
end;
procedure RegisterTFPOAuth2IniStore;
begin
  RegisterComponents(fpWebTab,[TFPOAuth2IniStore]);
end;
{$ENDIF}

Procedure RegisterWebComponents;

begin
  {$IF FPC_FULLVERSION>=30004}
  RegisterComponents(fpWebTab,[TFPHTTPClient,TFPHTTPServer]);
  {$ENDIF}
  RegisterUnit('fphtml',@RegisterHTMLComponents);
  RegisterUnit('fpdatasetform',@RegisterdatasetComponents);
  {$IF FPC_FULLVERSION>=30100}
  RegisterUnit('fphttpwebclient',@RegisterTFPHTTPWebClient);
  RegisterUnit('fpoauth2',@RegisterTOAuth2Handler);
  RegisterUnit('fpoauth2ini',@RegisterTFPOAuth2IniStore);
  //classes.RegisterComponents(fpWebTab,[TFPHTTPWebClient,TOAuth2Handler,TFPOAuth2IniStore]);
  {$ENDIF}
end;

procedure Register;
begin
  RegisterWebComponents;
  // Module file descriptors
  FileDescriptorWebProviderDataModule:=TFileDescWebProviderDataModule.Create;
  FileDescriptorJSONRPCModule:=TFileDescWebJSONRPCModule.Create;
  FileDescriptorExtDirectModule:=TFileDescExtDirectModule.Create;
  FileDescriptorFileDataModule:=TFileDescFileDataModule.Create;
  FileDescriptorWebModule:=TFileDescWebDataModule.Create;
  FileDescriptorHTMLModule:=TFileDescHTMLModule.Create;
  // Register descriptors
  RegisterProjectFileDescriptor(FileDescriptorHTMLModule);
  RegisterProjectFileDescriptor(FileDescriptorWebModule);
  RegisterProjectFileDescriptor(FileDescriptorWebProviderDataModule);
  RegisterProjectFileDescriptor(FileDescriptorJSONRPCModule);
  RegisterProjectFileDescriptor(FileDescriptorExtDirectModule);
  RegisterProjectFileDescriptor(FileDescriptorFileDataModule);
  // Register base class
  FormEditingHook.RegisterDesignerBaseClass(TFPWebModule);
  FormEditingHook.RegisterDesignerBaseClass(TFPHTMLModule);
  FormEditingHook.RegisterDesignerBaseClass(TFPCustomWebProviderDataModule);
  FormEditingHook.RegisterDesignerBaseClass(TFPWebProviderDataModule);
  FormEditingHook.RegisterDesignerBaseClass(TJSONRPCModule);
  FormEditingHook.RegisterDesignerBaseClass(TExtDirectModule);
  FormEditingHook.RegisterDesignerBaseClass(TFPCustomFileModule);
  //
  AChecker:=TJSSyntaxChecker.Create(Nil);
  LazarusIDE.AddHandlerOnQuickSyntaxCheck(@AChecker.CheckSource,False);
  RegisterPropertyEditor(TStrings.ClassInfo, TSQLDBWebDataProvider,  'SelectSQL', TSQLStringsPropertyEditor);
  RegisterPropertyEditor(TStrings.ClassInfo, TSQLDBWebDataProvider,  'InsertSQL', TSQLStringsPropertyEditor);
  RegisterPropertyEditor(TStrings.ClassInfo, TSQLDBWebDataProvider,  'DeleteSQL', TSQLStringsPropertyEditor);
  RegisterPropertyEditor(TStrings.ClassInfo, TSQLDBWebDataProvider,  'UpdateSQL', TSQLStringsPropertyEditor);
  ProjectDescriptorHTTPApplication:=THTTPApplicationDescriptor.Create;
  RegisterProjectDescriptor(ProjectDescriptorHTTPApplication);

  ProjectDescriptorCGIApplication:=TCGIApplicationDescriptor.Create;
  RegisterProjectDescriptor(ProjectDescriptorCGIApplication);
  ProjectDescriptorCustomCGIApplication:=TCustomCGIApplicationDescriptor.Create;
  RegisterProjectDescriptor(ProjectDescriptorCustomCGIApplication);
  ProjectDescriptorApacheApplication:=TApacheApplicationDescriptor.Create;
  RegisterProjectDescriptor(ProjectDescriptorApacheApplication);
  ProjectDescriptorFCGIApplication:=TFCGIApplicationDescriptor.Create;
  RegisterProjectDescriptor(ProjectDescriptorFCGIApplication);
  ProjectDescriptorCustomFCGIApplication:=TCustomFCGIApplicationDescriptor.Create;
  RegisterProjectDescriptor(ProjectDescriptorCustomFCGIApplication);

  RegisterPropertyEditor(TypeInfo(string), THTMLDatasetSelectProducer, 'ItemField', TFieldProperty);
  RegisterPropertyEditor(TypeInfo(string), THTMLDatasetSelectProducer, 'ValueField', TFieldProperty);
end;

{ TCGIApplicationDescriptor }

constructor TCGIApplicationDescriptor.Create;
begin
  inherited Create;
  Name:='CGI Application';
end;

function TCGIApplicationDescriptor.GetLocalizedName: string;
begin
  Result:=rsCGIApplicati;
end;

function TCGIApplicationDescriptor.GetLocalizedDescription: string;
begin
  Result:=rsCGIApplicati2;
end;

function TCGIApplicationDescriptor.InitProject(AProject: TLazProject): TModalResult;
var
  le: string;
  NewSource: String;
  MainFile: TLazProjectFile;
begin
  inherited InitProject(AProject);

  MainFile:=AProject.CreateProjectFile('cgiproject1.lpr');
  MainFile.IsPartOfProject:=true;
  AProject.AddFile(MainFile,false);
  AProject.MainFileID:=0;

  // create program source
  le:=LineEnding;
  NewSource:='program cgiproject1;'+le
    +le
    +'{$mode objfpc}{$H+}'+le
    +le
    +'uses'+le
    +'  fpCGI;'+le
    +le
    +'begin'+le
    +'  Application.Title:=''cgiproject1'';'+le
    +'  Application.Initialize;'+le
    +'  Application.Run;'+le
    +'end.'+le
    +le;
  AProject.MainFile.SetSourceText(NewSource);

  // add
  AProject.AddPackageDependency('WebLaz');

  // compiler options
  AProject.LazCompilerOptions.Win32GraphicApp:=false;
  AProject.LazCompilerOptions.UnitOutputDirectory:='lib'+PathDelim+'$(TargetCPU)-$(TargetOS)';
  AProject.Flags := AProject.Flags - [pfMainUnitHasCreateFormStatements];
  AProject.Flags := AProject.Flags - [pfRunnable];
  Result:= mrOK;
end;

function TCGIApplicationDescriptor.CreateStartFiles(AProject: TLazProject): TModalResult;
begin
  LazarusIDE.DoNewEditorFile(FileDescriptorWebModule,'','',
                         [nfIsPartOfProject,nfOpenInEditor,nfCreateDefaultSrc]);
  Result:= mrOK;
end;

{ TCustomCGIApplicationDescriptor }

constructor TCustomCGIApplicationDescriptor.Create;
begin
  inherited Create;
  Name:='Custom CGI Application';
end;

function TCustomCGIApplicationDescriptor.GetLocalizedName: string;
begin
  Result:=rsCustomCGIApp;
end;

function TCustomCGIApplicationDescriptor.GetLocalizedDescription: string;
begin
  Result:=rsCustomCGIApp2;
end;

function TCustomCGIApplicationDescriptor.InitProject(AProject: TLazProject): TModalResult;
var
  le: string;
  NewSource: String;
  MainFile: TLazProjectFile;
begin
  inherited InitProject(AProject);

  MainFile:=AProject.CreateProjectFile('cgiproject1.lpr');
  MainFile.IsPartOfProject:=true;
  AProject.AddFile(MainFile,false);
  AProject.MainFileID:=0;

  // create program source
  le:=LineEnding;
  NewSource:='program cgiproject1;'+le
    +le
    +'{$mode objfpc}{$H+}'+le
    +le
    +'uses'+le
    +'  Classes, SysUtils, httpDefs, fpweb,'
    +' custweb, custcgi;'+le
    +le
    +'Type'+le
    +'  TMyCGIHandler = Class(TCgiHandler)'+le
    +'  Public'+le
    +'    Procedure HandleRequest(ARequest : Trequest; AResponse : TResponse); override;'+le
    +'  end;'+le
    +le+le
    +'  TMyCGIApp = Class(TCustomCGIApplication)'+le
    +'  Protected'+le
    +'   function InitializeWebHandler: TWebHandler; override;'+le
    +'  end;'+le
    +le+le
    +'Procedure TMyCGIHandler.HandleRequest(ARequest : Trequest; AResponse : TResponse);'+le
    +le
    +'begin'+le
    +'  // Your code here'+le
    +'end;'+le
    +le+le
    +'Function TMyCGIApp.InitializeWebHandler: TWebHandler; '+le
    +'begin'+le
    +'  Result:=TMyCgiHandler.Create(self);'+le
    +'end;'+le
    +le+le
    +'begin'+le
    +'  With TMyCGIApp.Create(Nil) do'+le
    +'    try'+le
    +'      Initialize;'+le
    +'      Run;'+le
    +'    finally'+le
    +'      Free;'+le
    +'    end;'+le
    +'end.'+le;
  AProject.MainFile.SetSourceText(NewSource);

  // add
  AProject.AddPackageDependency('FCL');
  AProject.AddPackageDependency('WebLaz');
  // compiler options
  AProject.LazCompilerOptions.Win32GraphicApp:=false;
  AProject.LazCompilerOptions.UnitOutputDirectory:='lib'+PathDelim+'$(TargetCPU)-$(TargetOS)';
  AProject.Flags := AProject.Flags - [pfMainUnitHasCreateFormStatements];
  Result:= mrOK;
end;

function TCustomCGIApplicationDescriptor.CreateStartFiles(AProject: TLazProject): TModalResult;
begin
  Result:= mrOK;
end;

{ TFileDescWebDataModule }

constructor TFileDescWebDataModule.Create;
begin
  inherited Create;
  Name:='Web Module';
  ResourceClass:=TFPWebModule;
  UseCreateFormStatements:=true;
end;

function TFileDescWebDataModule.GetInterfaceUsesSection: string;
begin
  Result:='SysUtils, Classes';
  if GetResourceType = rtLRS then
    Result :=  Result+ ', LResources, ';
  Result:=Result+',httpdefs, fpHTTP,fpWeb';
end;

function TFileDescWebDataModule.GetLocalizedName: string;
begin
  Result:=rsWebModule;
end;

function TFileDescWebDataModule.GetLocalizedDescription: string;
begin
  Result:=rsWEBModuleADa;
end;

function TFileDescWebDataModule.GetImplementationSource(const Filename, SourceName, ResourceName: string): string;

begin
  Result:=Inherited GetImplementationSource(FileName,SourceName,ResourceName);
  if GetResourceType = rtRes then
    Result:=Result+'initialization'+LineEnding;
  Result:=Result+'  RegisterHTTPModule(''T'+ResourceName+''',T'+ResourceName+');'+LineEnding;
end;

{ TFileDescFileDataModule }

constructor TFileDescFileDataModule.Create;
begin
  inherited Create;
  Name:='Web File Module';
  ResourceClass:=TFPCustomFileModule;
  UseCreateFormStatements:=true;
end;

function TFileDescFileDataModule.GetInterfaceUsesSection: string;
begin
  Result:='SysUtils, Classes';
  if GetResourceType = rtLRS then
    Result :=  Result+ ', LResources, ';
  Result:=Result+',httpdefs, fpHTTP, fpWeb, fpWebFile';
end;

function TFileDescFileDataModule.GetLocalizedName: string;
begin
  Result:=rsFileModule;
end;

function TFileDescFileDataModule.GetLocalizedDescription: string;
begin
  Result:=rsFileModule2;
end;

function TFileDescFileDataModule.GetImplementationSource(const Filename, SourceName, ResourceName: string): string;

begin
  Result:=Inherited GetImplementationSource(FileName,SourceName,ResourceName);
  if GetResourceType = rtRes then
    Result:=Result+'initialization'+LineEnding;
  Result:=Result+'  RegisterHTTPModule(''T'+ResourceName+''',T'+ResourceName+');'+LineEnding;
end;

{ TFileDescHTMLModule }

constructor TFileDescHTMLModule.Create;
begin
  inherited Create;
  Name:='HTML Module';
  ResourceClass:=TFPHTMLModule;
  UseCreateFormStatements:=true;
end;

function TFileDescHTMLModule.GetInterfaceUsesSection: string;
begin
  Result:='SysUtils, Classes ';
  if (GetResourceType = rtLRS) then
    Result :=  Result+ ', LResources, ';
  Result:=Result+',HTTPDefs,websession,fpHTTP,htmlwriter,htmlelements,fphtml';
end;

function TFileDescHTMLModule.GetLocalizedName: string;
begin
  Result:=rsHTMLWebModul;
end;

function TFileDescHTMLModule.GetLocalizedDescription: string;
begin
  Result:=rsHTMLWEBModul2;
end;

function TFileDescHTMLModule.GetImplementationSource(const Filename, SourceName, ResourceName: string): string;

begin
  Result:=Inherited GetImplementationSource(FileName,SourceName,ResourceName);
  if GetResourceType = rtRes then
    Result:=Result+'initialization'+LineEnding;
  Result:=Result+'  RegisterHTTPModule(''T'+ResourceName+''',T'+ResourceName+');'+LineEnding;
end;

{ TApacheApplicationDescriptor }

constructor TApacheApplicationDescriptor.Create;
begin
  inherited Create;
  Name:='Apache Module';
end;

function TApacheApplicationDescriptor.GetLocalizedName: string;
begin
  Result:=rsApacheModule;
end;

function TApacheApplicationDescriptor.GetLocalizedDescription: string;
begin
  Result:=rsApacheModule2;
end;

function TApacheApplicationDescriptor.InitProject(AProject: TLazProject): TModalResult;
var
  le: string;
  NewSource: String;
  MainFile: TLazProjectFile;
begin
  inherited InitProject(AProject);

  MainFile:=AProject.CreateProjectFile('mod_apache1.lpr');
  MainFile.IsPartOfProject:=true;
  AProject.AddFile(MainFile,false);
  AProject.MainFileID:=0;

  // create program source
  le:=LineEnding;
  NewSource:='Library mod_apache1;'+le
    +le
    +'{$mode objfpc}{$H+}'+le
    +le
    +'Uses'+le
    +'{$ifdef unix}'+le
    +'  cthreads,'+le
    +'{$endif}'+le
    +'  httpd, custapache, fpApache;'+le
    +le
    +'Const'+le
    +le
    +'{ The following constant is used to export the module record. It must '+le
    +'  always match the name in the LoadModule statement in the apache'+le
    +'  configuration file(s). It is case sensitive !}'+le
    +'  ModuleName=''mod_apache1'';'+le
    +le
    +'{ The following constant is used to determine whether the module will'+le
    +'  handle a request. It should match the name in the SetHandler statement'+le
    +'  in the apache configuration file(s). It is not case sensitive. }'+le
    +le
    +'  HandlerName=ModuleName;'+le
    +le
    +'Var'+le
    +'  DefaultModule : module; {$ifdef unix} public name ModuleName;{$endif unix}'+le
    +le
    +'Exports defaultmodule name ModuleName;'+le
    +le
    +'begin'+le
    +'  Application.Title:=''mod_apache1'';'+le
    +'  Application.ModuleName:=ModuleName;'+le
    +'  Application.HandlerName:=HandlerName;'+le
    +'  Application.SetModuleRecord(DefaultModule);'+le
    +'  Application.Initialize;'+le
    +'end.'+le
    +le;
  AProject.MainFile.SetSourceText(NewSource);

  // add
  AProject.AddPackageDependency('WebLaz');

  // compiler options
  AProject.LazCompilerOptions.Win32GraphicApp:=false;
  AProject.ExecutableType:=petLibrary;
  AProject.LazCompilerOptions.UnitOutputDirectory:='lib'+PathDelim+'$(TargetCPU)-$(TargetOS)';
  AProject.Flags := AProject.Flags - [pfMainUnitHasCreateFormStatements];
  AProject.Flags := AProject.Flags - [pfRunnable];
  Result:= mrOK;
end;

function TApacheApplicationDescriptor.CreateStartFiles(AProject: TLazProject): TModalResult;
begin
  LazarusIDE.DoNewEditorFile(FileDescriptorWebModule,'','',
                         [nfIsPartOfProject,nfOpenInEditor,nfCreateDefaultSrc]);
  Result:= mrOK;
end;


{ TCustomFCGIApplicationDescriptor }

constructor TCustomFCGIApplicationDescriptor.Create;
begin
  inherited Create;
  Name:='Custom FastCGI Application';
end;

function TCustomFCGIApplicationDescriptor.GetLocalizedName: string;
begin
  Result:=rsCustomFastCG;
end;

function TCustomFCGIApplicationDescriptor.GetLocalizedDescription: string;
begin
  Result:=rsCustomFastCG2;
end;

function TCustomFCGIApplicationDescriptor.InitProject(AProject: TLazProject): TModalResult;
var
  le: string;
  NewSource: String;
  MainFile: TLazProjectFile;
begin
  inherited InitProject(AProject);

  MainFile:=AProject.CreateProjectFile('fcgiproject1.lpr');
  MainFile.IsPartOfProject:=true;
  AProject.AddFile(MainFile,false);
  AProject.MainFileID:=0;

  // create program source
  le:=LineEnding;
  NewSource:='program fcgiproject1;'+le
    +le
    +'{$mode objfpc}{$H+}'+le
    +le
    +'uses'+le
    +'  Classes,SysUtils,httpDefs,custfcgi;'+le
    +le
    +'Type'+le
    +'  TFCGIApp = Class(TCustomFCGIApplication)'+le
    +'  Public'+le
    +'    Procedure HandleRequest(ARequest : Trequest; AResponse : TResponse); override;'+le
    +'  end;'+le
    +le
    +'Procedure TFCGIApp.HandleRequest(ARequest : Trequest; AResponse : TResponse);'+le
    +le
    +'begin'+le
    +'  // Your code here'+le
    +'end;'+le
    +le
    +'begin'+le
    +'  With TFCGIApp.Create(Nil) do'+le
    +'    try'+le
    +'      { Uncomment the port setting here if you want to run the '+le 
    +'       FastCGI application stand-alone (e.g. for NGINX) }'+le
    +'      // Port:=2015; // For example'+le
    +'      Initialize;'+le
    +'      Run;'+le
    +'    finally'+le
    +'      Free;'+le
    +'    end;'+le
    +'end.'+le;
  AProject.MainFile.SetSourceText(NewSource);

  // add
  AProject.AddPackageDependency('FCL');
  AProject.AddPackageDependency('WebLaz');
  // compiler options
  AProject.LazCompilerOptions.Win32GraphicApp:=false;
  AProject.LazCompilerOptions.UnitOutputDirectory:='lib'+PathDelim+'$(TargetCPU)-$(TargetOS)';
  AProject.Flags := AProject.Flags - [pfMainUnitHasCreateFormStatements];
  Result:= mrOK;
end;

function TCustomFCGIApplicationDescriptor.CreateStartFiles(AProject: TLazProject
  ): TModalResult;
begin
  Result:= mrOK;
end;

{ TFCGIApplicationDescriptor }

constructor TFCGIApplicationDescriptor.Create;
begin
  inherited Create;
  Name:='FastCGI Application';
end;

function TFCGIApplicationDescriptor.GetLocalizedName: string;
begin
  Result:=rsFastCGIAppli;
end;

function TFCGIApplicationDescriptor.GetLocalizedDescription: string;
begin
  Result:=rsFastCGIAppli2;
end;

function TFCGIApplicationDescriptor.InitProject(AProject: TLazProject): TModalResult;
var
  le: string;
  NewSource: String;
  MainFile: TLazProjectFile;
begin
  inherited InitProject(AProject);

  MainFile:=AProject.CreateProjectFile('fcgiproject1.lpr');
  MainFile.IsPartOfProject:=true;
  AProject.AddFile(MainFile,false);
  AProject.MainFileID:=0;

  // create program source
  le:=LineEnding;
  NewSource:='program fcgiproject1;'+le
    +le
    +'{$mode objfpc}{$H+}'+le
    +le
    +'uses'+le
    +'  fpFCGI;'+le
    +le
    +'begin'+le
    +'  Application.Title:=''fcgiproject1'';'+le
    +'  { Uncomment the port setting here if you want to run the '+le 
    +'    FastCGI application stand-alone (e.g. for NGINX) }'+le
    +'  // Application.Port:=2015; // For example'+le
    +'  Application.Initialize;'+le
    +'  Application.Run;'+le
    +'end.'+le
    +le;
  AProject.MainFile.SetSourceText(NewSource);

  // add
  AProject.AddPackageDependency('FCL');
  AProject.AddPackageDependency('WebLaz');

  // compiler options
  AProject.LazCompilerOptions.Win32GraphicApp:=false;
  AProject.LazCompilerOptions.UnitOutputDirectory:='lib'+PathDelim+'$(TargetCPU)-$(TargetOS)';
  AProject.Flags := AProject.Flags - [pfMainUnitHasCreateFormStatements];
  Result:= mrOK;
end;

function TFCGIApplicationDescriptor.CreateStartFiles(AProject: TLazProject
  ): TModalResult;
begin
  LazarusIDE.DoNewEditorFile(FileDescriptorWebModule,'','',
                         [nfIsPartOfProject,nfOpenInEditor,nfCreateDefaultSrc]);
  Result:= mrOK;
end;



{ THTTPApplicationDescriptor }

constructor THTTPApplicationDescriptor.Create;
begin
  inherited Create;
  Name:='FPHTTPApplication';
end;

function THTTPApplicationDescriptor.DoInitDescriptor: TModalResult;
begin
  Result:=GetOptions;
end;

function THTTPApplicationDescriptor.GetLocalizedName: string;
begin
  Result:=rsHTTPAppli;
end;

function THTTPApplicationDescriptor.GetLocalizedDescription: string;
begin
  Result:=rsHTTPAppli2;
end;

function THTTPApplicationDescriptor.GetOptions : TModalResult;

begin
  With TNewHTTPApplicationForm.Create(Application) do
    try
      Result:=ShowModal;
      if Result=mrOK then
        begin
        FThreaded:=Threaded;
        FPort:=Port;
        FServeFiles:=ServeFiles;
        if FServeFiles<>sfNoFiles then
          begin
          FLoc:=FileRoute;
          FDir:=Directory;
          end;
        FStandardModule:=StandardModule;
        end;
    finally
      Free;
    end;
end;
function THTTPApplicationDescriptor.InitProject(AProject: TLazProject
  ): TModalResult;

Var
  S : string;
  le: string;
  NewSource: String;
  MainFile: TLazProjectFile;

begin
  inherited InitProject(AProject);
  MainFile:=AProject.CreateProjectFile('httpproject1.lpr');
  MainFile.IsPartOfProject:=true;
  AProject.AddFile(MainFile,false);
  AProject.MainFileID:=0;
  // create program source
  le:=LineEnding;
  NewSource:='program httpproject1;'+le
    +le
    +'{$mode objfpc}{$H+}'+le
    +le
    +'uses'+le;
  if FServeFiles<>sfNoFiles then
    NewSource:=NewSource+'  fpwebfile,'+le;
  NewSource:=NewSource
    +'  fphttpapp;'+le
    +le
    +'begin'+le;
  Case FServeFiles of
  sfSingleRoute:
    begin
    S:=Format('  RegisterFileLocation(''%s'',''%s'');',[FLoc,FDir]);
    NewSource:=NewSource+S+le
    end;
  sfDefaultRoute:
    begin
    S:='  TSimpleFileModule.BaseDir:='+Format('''%s'';',[StringReplace(FDir,'''','''''',[rfReplaceAll])]);
    S:=S+le+'  TSimpleFileModule.RegisterDefaultRoute;';
    NewSource:=NewSource+S+le;
    end;
  end;
  NewSource:=NewSource
    +'  Application.Title:=''httpproject1'';'+le
    +Format('  Application.Port:=%d;'+le,[FPort]);
  if FThreaded then
    NewSource:=NewSource+'  Application.Threaded:=True;'+le;
  NewSource:=NewSource
    +'  Application.Initialize;'+le
    +'  Application.Run;'+le
    +'end.'+le
    +le;
  AProject.MainFile.SetSourceText(NewSource);

  // add
  AProject.AddPackageDependency('FCL');
  AProject.AddPackageDependency('WebLaz');

  // compiler options
  AProject.LazCompilerOptions.Win32GraphicApp:=false;
  AProject.LazCompilerOptions.UnitOutputDirectory:='lib'+PathDelim+'$(TargetCPU)-$(TargetOS)';
  AProject.Flags := AProject.Flags - [pfMainUnitHasCreateFormStatements];
  Result:= mrOK;
end;

function THTTPApplicationDescriptor.CreateStartFiles(AProject: TLazProject
  ): TModalResult;

Var
  Desc :TProjectFileDescriptor ;

begin
  Case FStandardModule of
    smWeb : Desc:=FileDescriptorWebModule;
    smHTTP : Desc:=FileDescriptorHTMLModule;
    smFile: Desc:=FileDescriptorFileDataModule;
    smExtDirect : Desc:=FileDescriptorExtDirectModule;
    smRPC : Desc:=FileDescriptorJSONRPCModule;
    smWebData : Desc:=FileDescriptorWebProviderDataModule;
  else
    Desc:=Nil;
  end;
  if Desc<>Nil then
  LazarusIDE.DoNewEditorFile(Desc,'','',
                         [nfIsPartOfProject,nfOpenInEditor,nfCreateDefaultSrc]);
  Result:= mrOK;
end;

{ TFileDescWebProviderDataModule }

constructor TFileDescWebProviderDataModule.Create;
begin
  inherited Create;
  Name:='Web DataProvider Module';
  ResourceClass:=TFPWebProviderDataModule;
  UseCreateFormStatements:=False;
end;

function TFileDescWebProviderDataModule.GetInterfaceUsesSection: string;
begin
  Result:=inherited GetInterfaceUsesSection;
  Result:=Result+', HTTPDefs, websession, fpHTTP, fpWeb, fpwebdata';
end;

function TFileDescWebProviderDataModule.GetLocalizedName: string;
begin
  Result:=rsWebDataProvi;
end;

function TFileDescWebProviderDataModule.GetLocalizedDescription: string;
begin
  Result:=rsWEBDataProvi2;
end;

function TFileDescWebProviderDataModule.GetImplementationSource(const Filename,
  SourceName, ResourceName: string): string;
begin
  Result:=Inherited GetImplementationSource(FileName,SourceName,ResourceName);
  if GetResourceType = rtRes then
    Result:=Result+'initialization'+LineEnding;
  Result:=Result+'  RegisterHTTPModule(''T'+ResourceName+''',T'+ResourceName+');'+LineEnding;
end;



{ TFileDescWebJSONFPCModule }

constructor TFileDescWebJSONRPCModule.Create;
begin
  inherited Create;
  Name:='JSON-RPC Module';
  ResourceClass:=TJSONRPCModule;
  UseCreateFormStatements:=False;
end;

function TFileDescWebJSONRPCModule.GetInterfaceUsesSection: string;
begin
  Result:=inherited GetInterfaceUsesSection;
  Result:=Result+', HTTPDefs, websession, fpHTTP, fpWeb, fpjsonrpc, webjsonrpc';
end;

function TFileDescWebJSONRPCModule.GetLocalizedName: string;
begin
  Result:=rsWebJSONRPCMo;
end;

function TFileDescWebJSONRPCModule.GetLocalizedDescription: string;
begin
  Result:=rsWEBJSONRPCMo2;
end;

function TFileDescWebJSONRPCModule.GetImplementationSource(const Filename,
  SourceName, ResourceName: string): string;

Var
  RH,RM : Boolean;
  JRC, HP : String;

begin
  RH:=False;
  RM:=False;
  HP:=ResourceName;
  With TJSONRPCModuleOptionsForm.Create(Application) do
    try
      If (ShowModal=mrOK) then
        begin
        RH:=RegisterHandlers;
        RM:=RegisterModule;
        JRC:=JSONRPCClass;
        If RM then
          HP:=HTTPPath;
        end;
    finally
      Free;
    end;
  Result:=Inherited GetImplementationSource(FileName,SourceName,ResourceName);
  if (GetResourceType = rtRes) and (RM or RH) then
    Result:=Result+'Initialization'+sLineBreak;
  If RM then
    Result:=Result+'  RegisterHTTPModule('''+HP+''',T'+ResourceName+');'+LineEnding;
  If RH then
    Result:=Result+'  JSONRPCHandlerManager.RegisterDatamodule(T'+ResourceName+','''+JRC+''');'+LineEnding;
end;

{ TFileDescExtDirectModule }

constructor TFileDescExtDirectModule.Create;
begin
  inherited Create;
  Name:='Ext.Direct Module';
  ResourceClass:=TExtDirectModule;
  UseCreateFormStatements:=False;
end;

function TFileDescExtDirectModule.GetInterfaceUsesSection: string;
begin
  Result:=inherited GetInterfaceUsesSection;
  Result:=Result+', HTTPDefs, websession, fpHTTP, fpWeb, fpjsonrpc, webjsonrpc, fpextdirect';
end;

function TFileDescExtDirectModule.GetLocalizedName: string;
begin
  Result:=inherited GetLocalizedName;
  Result:=rsWebExtDirect;
end;

function TFileDescExtDirectModule.GetLocalizedDescription: string;
begin
  Result:=rsWEBExtDirect2;
end;

function TFileDescExtDirectModule.GetImplementationSource(const Filename,
  SourceName, ResourceName: string): string;

Var
  RH,RM : Boolean;
  HP : String;

begin
  RH:=False;
  RM:=False;
  HP:=ResourceName;
  With TJSONRPCModuleOptionsForm.Create(Application) do
    try
      If (ShowModal=mrOK) then
        begin
        RH:=RegisterHandlers;
        RM:=RegisterModule;
        If RM then
          HP:=HTTPPath;
        end;
    finally
      Free;
    end;
  Result:=Inherited GetImplementationSource(FileName,SourceName,ResourceName);
  if (GetResourceType = rtRes) and (RM or RH) then
    Result:=Result+'Initialization'+sLineBreak;
  If RM then
    Result:=Result+'  RegisterHTTPModule('''+HP+''',T'+ResourceName+');'+LineEnding;
  If RH then
    Result:=Result+'  JSONRPCHandlerManager.RegisterDatamodule(T'+ResourceName+','''+HP+''',);'+LineEnding;
end;

{ TJSSyntaxChecker }


procedure TJSSyntaxChecker.ShowMessage(const Msg: String);
begin
  IDEMessagesWindow.AddCustomMessage(mluImportant,Msg,SourceFileName);
end;

procedure TJSSyntaxChecker.ShowMessage(const Fmt: String;
  Args: array of const);
begin
  ShowMessage(Format(Fmt,Args));
end;

procedure TJSSyntaxChecker.ShowException(const Msg: String; E: Exception);
begin
  If (Msg<>'') then
    ShowMessage(Msg+' : '+E.Message)
  else
    ShowMessage(Msg+' : '+E.Message);
end;

function TJSSyntaxChecker.CheckJavaScript(S : TStream): TModalResult;

Var
  P : TJSParser;
  E : TJSElement;
begin
  Result:=mrOK;
  P:=TJSParser.Create(S);
  try
    try
      E:=P.Parse;
      E.Free;
      ShowMessage('Javascript syntax OK');
    except
      On E : Exception do
        begin
        ShowException('Javascript syntax error',E);
        Result:=mrAbort;
        end;
    end;
  finally
    P.free;
  end;
end;

function TJSSyntaxChecker.CheckSource(Sender: TObject; var Handled: boolean
  ): TModalResult;

Var
  AE : TSourceEditorInterface;
  S : TStringStream;

begin
  try
  Handled:=False;
  result:=mrNone;
  AE:=SourceEditorManagerIntf.ActiveEditor;
  If (AE<>Nil) then
    begin
    FSFN:=ExtractFileName(AE.FileName);
    Handled:=FilenameExtIs(AE.FileName,'.js');
    If Handled then
      begin
      S:=TStringStream.Create(AE.SourceText);
      try
        CheckJavaScript(S);
        Result:=mrOK;
      finally
        S.Free;
      end;
      end;
    end;
  except
    On E : Exception do
      ShowException('Error during syntax check',E);
  end;
end;

{ TJSFileDescriptor }

constructor TJSFileDescriptor.Create;
begin
  Name:='SQL Script file';
  DefaultFilename:='script.sql';
  DefaultResFileExt:='';
  DefaultFileExt:='.sql';
  VisibleInNewDialog:=true;
end;

function TJSFileDescriptor.GetLocalizedName: string;
begin
  Result:=inherited GetLocalizedName;
end;

function TJSFileDescriptor.GetLocalizedDescription: string;
begin
  Result:=inherited GetLocalizedDescription;
end;

function TJSFileDescriptor.GetResourceSource(const ResourceName: string): string;
begin
  Result:=inherited GetResourceSource(ResourceName);
end;

function TJSFileDescriptor.CreateSource(const Filename, SourceName,
  ResourceName: string): string;
begin
  Result:=inherited CreateSource(Filename, SourceName, ResourceName);
end;

procedure TJSFileDescriptor.UpdateDefaultPascalFileExtension(
  const DefPasExt: string);
begin
  inherited UpdateDefaultPascalFileExtension(DefPasExt);
end;

initialization
 {$i fpweb_images.inc}

finalization
  FreeAndNil(AChecker);

end.

