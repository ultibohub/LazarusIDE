unit PJSDsgnRegister;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils,
  // LCL
  Forms, Controls,
  // LazUtils
  LazLoggerBase,
  // IdeIntf
  ProjectIntf, CompOptsIntf, LazIDEIntf, IDEOptionsIntf, IDEOptEditorIntf,
  // Pas2js
  PJSDsgnOptions, PJSDsgnOptsFrame;

const
  ProjDescNamePas2JSWebApp = 'Web Application';
  ProjDescNamePas2JSNodeJSApp = 'NodeJS Application';


type

  { TProjectPas2JSWebApp }
  TBrowserApplicationOption = (baoCreateHtml,        // Create template HTML page
                               baoMaintainHTML,      // Maintain the template HTML page
                               baoRunOnReady,        // Run in document.onReady
                               baoUseBrowserApp,     // Use browser app object
                               baoUseBrowserConsole, // use browserconsole unit to display Writeln()
                               baoStartServer,       // Start simple server
                               baoUseURL,            // Use this URL to run/show project in browser
                               baoShowException,     // let RTL show uncaught exceptions
                               baoUseWASI           // Use WASI browser app object
                               );
  TBrowserApplicationOptions = set of TBrowserApplicationOption;

  TProjectPas2JSWebApp = class(TProjectDescriptor)
  private
    FOptions: TBrowserApplicationOptions;
    FProjectPort: integer;
    FProjectURL: String;
    FProjectWasmURL : String;
  protected
    function CreateHTMLFile(AProject: TLazProject; AFileName: String
      ): TLazProjectFile; virtual;
    function CreateProjectSource: String; virtual;
    function GetNextPort: Word; virtual;
    function ShowOptionsDialog: TModalResult; virtual;
  public
    constructor Create; override;
    Function DoInitDescriptor : TModalResult; override;
    function GetLocalizedName: string; override;
    function GetLocalizedDescription: string; override;
    function InitProject(AProject: TLazProject): TModalResult; override;
    function CreateStartFiles(AProject: TLazProject): TModalResult; override;
    Property Options : TBrowserApplicationOptions read FOptions Write Foptions;
    Property ProjectPort : integer Read FProjectPort Write FProjectPort;
    Property ProjectURL : String Read FProjectURL Write FProjectURL;
  end;

  { TProjectPas2JSNodeJSApp }
  TNodeJSApplicationOption = (naoUseNodeJSApp);      // Use NodeJS app object
  TNodeJSApplicationOptions = set of TNodeJSApplicationOption;

  TProjectPas2JSNodeJSApp = class(TProjectDescriptor)
  private
    FOptions: TNodeJSApplicationOptions;
  protected
    function CreateProjectSource: String; virtual;
    function ShowOptionsDialog: TModalResult; virtual;
  public
    constructor Create; override;
    Function DoInitDescriptor : TModalResult; override;
    function GetLocalizedName: string; override;
    function GetLocalizedDescription: string; override;
    function InitProject(AProject: TLazProject): TModalResult; override;
    function CreateStartFiles(AProject: TLazProject): TModalResult; override;
    property Options : TNodeJSApplicationOptions Read FOptions Write FOptions;
  end;

var
  PJSOptionsFrameID: integer = 1000;

Const
  // Position in project options dialog.
  Pas2JSOptionsIndex  = ProjectOptionsMisc + 100;

procedure Register;

implementation

uses
  frmpas2jswebservers,
  frmpas2jsnodejsprojectoptions,
  frmpas2jsbrowserprojectoptions,
  pjsprojectoptions,
  pjscontroller, strpas2jsdesign, IDECommands, ToolbarIntf, MenuIntf;

procedure ShowServerDialog(Sender: TObject);
begin
  TPasJSWebserverProcessesForm.Instance.Show;
  TPasJSWebserverProcessesForm.Instance.BringToFront;
end;

Const
  sPas2JSWebserverName = 'Pas2JSWebservers';

procedure Register;

Var
  ViewCategory : TIDECommandCategory;
  IDECommand : TIDECommand;

begin
  PJSOptions:=TPas2jsOptions.Create;
  PJSOptions.Load;
  TPJSController.Instance.Hook;
  // register new-project items
  RegisterProjectDescriptor(TProjectPas2JSWebApp.Create);
  RegisterProjectDescriptor(TProjectPas2JSNodeJSApp.Create);
  // add IDE options frame
  PJSOptionsFrameID:=RegisterIDEOptionsEditor(GroupEnvironment,TPas2jsOptionsFrame,
                                              PJSOptionsFrameID)^.Index;
  ViewCategory := IDECommandList.FindCategoryByName(CommandCategoryViewName);
  if ViewCategory <> nil then
    begin
    IDECommand := RegisterIDECommand(ViewCategory,sPas2JSWebserverName,SPasJSWebserverCaption,
                                     CleanIDEShortCut,CleanIDEShortCut,Nil,@ShowServerDialog);
    if IDECommand <> nil then
      RegisterIDEButtonCommand(IDECommand);
    end;
  RegisterIdeMenuCommand(itmViewDebugWindows,sPas2JSWebserverName,SPasJSWebserverCaption,nil,@ShowServerDialog);
  // Add project options frame
  RegisterIDEOptionsEditor(GroupProject,TPas2JSProjectOptionsFrame, Pas2JSOptionsIndex);
end;

{ TProjectPas2JSNodeJSApp }

function TProjectPas2JSNodeJSApp.CreateProjectSource: String;
Var
  Src : TStrings;
  units : string;

  Procedure Add(aLine : String);

  begin
    Src.Add(aLine);
  end;

  Procedure AddLn(aLine : String);

  begin
    if (Aline<>'') then
      Aline:=Aline+';';
    Add(Aline);
  end;


begin
  Units:='';
  if naoUseNodeJSApp in Options then
    Units:=Units+' nodejsapp,' ;
  Units:=Units+' JS, Classes, SysUtils, nodeJS';
  Src:=TStringList.Create;
  try
    // create program source
    AddLn('program Project1');
    AddLn('');
    Add('{$mode objfpc}');
    Add('');
    Add('uses');
    AddLn(units) ;
    Add('');
    if naoUseNodeJSApp in Options then
      begin
      Add('Type');
        Add('  TMyApplication = Class(TNodeJSApplication)');
      AddLn('    procedure doRun; override');
      AddLn('  end');
      Add('');
      AddLn('Procedure TMyApplication.doRun');
      Add('');
      Add('begin');
      Add('  // Your code here');
      AddLn('  Terminate');
      AddLn('end');
      Add('');
      Add('var');
      AddLn('  Application : TMyApplication');
      Add('');
      end;
    Add('begin');
    if Not (naoUseNodeJSApp in Options) then
       Add('  // Your code here')
    else
       begin
       AddLn('  Application:=TMyApplication.Create(Nil)');
       AddLn('  Application.Initialize');
       AddLn('  Application.Run');
       end;
    Add('end.');
    Result:=Src.Text;
  finally
    Src.Free;
  end;
end;

function TProjectPas2JSNodeJSApp.ShowOptionsDialog: TModalResult;

  Function Co(o : TNodeJSApplicationOption) : boolean;

  begin
    Result:=O in Options;
  end;

  Procedure So(Value : Boolean; o : TNodeJSApplicationOption);

  begin
    if Value then
      Include(Foptions,O);
  end;


begin
  With TNodeJSProjectOptionsForm.Create(Nil) do
    try
      UseNodeJSApplication:=CO(naoUseNodeJSApp);
      Result:=ShowModal;
      if Result=mrOK then
        begin
        SO(UseNodeJSApplication,naoUseNodeJSApp);
        end;
    finally
      Free;
    end;
end;

constructor TProjectPas2JSNodeJSApp.Create;
begin
  inherited Create;
  Name:= ProjDescNamePas2JSNodeJSApp;
  Flags:=DefaultProjectNoApplicationFlags-[pfRunnable];
end;

function TProjectPas2JSNodeJSApp.DoInitDescriptor: TModalResult;
begin
  Result:=ShowOptionsDialog;
end;

function TProjectPas2JSNodeJSApp.GetLocalizedName: string;
begin
  Result:=pjsdNodeJSApplication;
end;

function TProjectPas2JSNodeJSApp.GetLocalizedDescription: string;
begin
  Result:=pjsdNodeJSAppDescription;
end;

function TProjectPas2JSNodeJSApp.InitProject(AProject: TLazProject ): TModalResult;

var
  MainFile : TLazProjectFile;
  CompOpts : TLazCompilerOptions;

begin
  Result:=inherited InitProject(AProject);
  MainFile:=AProject.CreateProjectFile('project1.lpr');
  MainFile.IsPartOfProject:=true;
  AProject.AddFile(MainFile,false);
  AProject.MainFileID:=0;
  CompOpts:=AProject.LazBuildModes.BuildModes[0].LazCompilerOptions;
  SetDefaultNodeJSCompileOptions(CompOpts);
  CompOpts.TargetFilename:='project1';

  SetDefaultNodeRunParams(AProject.RunParameters.GetOrCreate('Default'));

  // create program source
  AProject.MainFile.SetSourceText(CreateProjectSource,true);

  //AProject.AddPackageDependency('pas2js_rtl');
  //if naoUseNodeJSApp in Options then
  //  AProject.AddPackageDependency('fcl_base_pas2js');
end;

function TProjectPas2JSNodeJSApp.CreateStartFiles(AProject: TLazProject
  ): TModalResult;
begin
  Result:=LazarusIDE.DoOpenEditorFile(AProject.MainFile.Filename,-1,-1,
                                      [ofProjectLoading,ofRegularFile]);
end;

{ TProjectPas2JSWebApp }

constructor TProjectPas2JSWebApp.Create;
begin
  inherited Create;
  Name:=ProjDescNamePas2JSWebApp;
  Flags:=DefaultProjectNoApplicationFlags-[pfRunnable];
end;

function TProjectPas2JSWebApp.GetNextPort : Word;

begin
  Result:=PJSOptions.StartAtPort;
  if Result>=$ffff then
    Result:=1024
  else
    inc(Result);
  PJSOptions.StartAtPort:=Result;
  PJSOptions.Save;
end;

function TProjectPas2JSWebApp.ShowOptionsDialog : TModalResult;

  Function Co(o : TBrowserApplicationOption) : boolean;

  begin
    Result:=O in Options;
  end;

  Procedure So(AValue : Boolean; o : TBrowserApplicationOption);

  begin
    if AValue then
      Include(Foptions,O)
    else
      Exclude(Foptions,O)
  end;


begin
  With TWebBrowserProjectOptionsForm.Create(Nil) do
    try
      CreateHTML:=CO(baoCreateHtml);
      MaintainHTML:=CO(baoCreateHtml) and Co(baoMaintainHTML);
      UseBrowserApp:=CO(baoUseBrowserApp);
      UseBrowserConsole:=CO(baoUseBrowserConsole);
      StartHTTPServer:=CO(baoStartServer);
      UseRunOnReady:=CO(baoRunOnReady);
      UseWASI:=CO(baoUseWASI);
      ShowUncaughtExceptions:=CO(baoShowException);
      // We allocate the new port in all cases.
      ServerPort:=GetNextPort;
      URL:='';
      WasmProgramURL:='';
      if Not CO(baoStartServer) then
        UseURL:=CO(baoUseURL);
      Result:=ShowModal;
      if Result=mrOK then
        begin
        SO(CreateHTML,baoCreateHtml);
        SO(MaintainHTML,baoCreateHtml);
        SO(UseBrowserApp,baoUseBrowserApp);
        SO(UseBrowserConsole,baoUseBrowserConsole);
        SO(StartHTTPServer,baoStartServer);
        SO(UseRunOnReady,baoRunOnReady);
        SO(ShowUncaughtExceptions,baoShowException);
        SO(UseWASI,baoUseWASI);
        DebugLN(['Start server:', CO(baoStartServer)]);
        if CO(baoStartServer) then
          begin
          Self.ProjectPort:=ServerPort;
          DebugLN(['Start server port: ', Self.ProjectPort,'from: ',ServerPort]);
          end
        else
          begin
          UseURL:=CO(baoUseURL);
          if UseURL then
            FProjectURL:=URL;
          end;
        end;
        FProjectWasmURL:=WasmProgramURL;
    finally
      Free;
    end;
end;

function TProjectPas2JSWebApp.DoInitDescriptor: TModalResult;
begin
  // Reset options
  FOptions:=[baoCreateHtml,baoMaintainHTML];
  ProjectPort:=0;
  ProjectURL:='';
  Result:=ShowOptionsDialog;
end;

function TProjectPas2JSWebApp.GetLocalizedName: string;
begin
  Result:=pjsdWebApplication;
end;

function TProjectPas2JSWebApp.GetLocalizedDescription: string;
begin
  Result:=pjsdWebAppDescription;
end;

function TProjectPas2JSWebApp.CreateHTMLFile(AProject: TLazProject;
  AFileName: String): TLazProjectFile;

Const
  ConsoleDiv = '<div id="pasjsconsole"></div>'+LineEnding;
  TemplateHTMLSource =
     '<!doctype html>'+LineEnding
    +'<html lang="en">'+LineEnding
    +'<head>'+LineEnding
    +'  <meta http-equiv="Content-type" content="text/html; charset=utf-8">'+LineEnding
    +'  <meta name="viewport" content="width=device-width, initial-scale=1">'+LineEnding
    +'  <title>Project1</title>'+LineEnding
    +'  <script src="%s"></script>'+LineEnding
    +'</head>'+LineEnding
    +'<body>'+LineEnding
    +'  <script>'+LineEnding
    +'  %s'+LineEnding
    +'  </script>'+LineEnding
    +'  %s'+LineEnding
    +'</body>'+LineEnding
    +'</html>'+LineEnding;


Var
  HTMLFile : TLazProjectFile;
  HTMLSource : String;
  RunScript,Content : String;

begin
  HTMLFile:=AProject.CreateProjectFile('project1.html');
  HTMLFile.IsPartOfProject:=true;
  AProject.CustomData.Values[PJSProjectHTMLFile]:=HTMLFile.Filename;
  AProject.AddFile(HTMLFile,false);
  Content:='';
  if baoUseBrowserConsole in Options then
    Content:=ConsoleDiv;
  if baoShowException in Options then
    Runscript:='rtl.showUncaughtExceptions=true;'+LineEnding+'  '
  else
    RunScript:='';
  if baoRunOnReady in Options then
    RunScript:=Runscript+'window.addEventListener("load", rtl.run);'+LineEnding
  else
    RunScript:=Runscript+'rtl.run();'+LineEnding;
  HTMLSource:=Format(TemplateHTMLSource,[aFileName,RunScript,Content]);
  HTMLFile.SetSourceText(HTMLSource);
  Result:=HTMLFile;
end;

function TProjectPas2JSWebApp.CreateProjectSource : String;

Var
  Src : TStrings;
  units : string;

  Procedure Add(aLine : String);

  begin
    Src.Add(aLine);
  end;

  Procedure AddLn(aLine : String);

  begin
    if (Aline<>'') then
      Aline:=Aline+';';
    Add(Aline);
  end;


begin
  Units:='';
  if baoUseBrowserConsole in Options then
    Units:=' browserconsole,';
  if baoUseBrowserApp in Options then
    begin
    Units:=Units+' browserapp,' ;
    if baoUseWASI in options then
      Units:=Units+' wasihostapp,' ;
    end;
  Units:=Units+' JS, Classes, SysUtils, Web';
  Src:=TStringList.Create;
  try
    // create program source
    AddLn('program Project1');
    AddLn('');
    Add('{$mode objfpc}');
    Add('');
    Add('uses');
    AddLn(units) ;
    Add('');
    if baoUseBrowserApp in Options then
      begin
      Add('Type');
      if baoUseWASI in Options then
        Add('  TMyApplication = Class(TWASIHostApplication)')
      else
        Add('  TMyApplication = Class(TBrowserApplication)');
      AddLn('    procedure doRun; override');
      AddLn('  end');
      Add('');
      AddLn('Procedure TMyApplication.doRun');
      Add('');
      Add('begin');
      if baoUseWASI in Options then
        begin
        if FProjectWasmURL='' then
          FProjectWasmURL:='yourwebassembly.wasm';
        AddLn(Format('  StartWebAssembly(''%s'')',[FProjectWasmURL]));
        end
      else
        Add('  // Your code here');
      AddLn('  Terminate');
      AddLn('end');
      Add('');
      Add('var');
      AddLn('  Application : TMyApplication');
      Add('');
      end;
    Add('begin');
    if Not (baoUseBrowserApp in Options) then
       Add('  // Your code here')
    else
       begin
       AddLn('  Application:=TMyApplication.Create(Nil)');
       AddLn('  Application.Initialize');
       AddLn('  Application.Run');
       AddLn('  Application.Free');
       end;
    Add('end.');
    Result:=Src.Text;
  finally
    Src.Free;
  end;
end;

function TProjectPas2JSWebApp.InitProject(AProject: TLazProject): TModalResult;

var
  MainFile,
  HTMLFile : TLazProjectFile;
  CompOpts: TLazCompilerOptions;

begin
  Result:=inherited InitProject(AProject);
  MainFile:=AProject.CreateProjectFile('project1.lpr');
  MainFile.IsPartOfProject:=true;
  AProject.AddFile(MainFile,false);
  AProject.MainFileID:=0;
  CompOpts:=AProject.LazCompilerOptions;
  SetDefaultWebCompileOptions(CompOpts);
  CompOpts.TargetFilename:='project1';
  SetDefaultWebRunParams(AProject.RunParameters.GetOrCreate('Default'));
  AProject.MainFile.SetSourceText(CreateProjectSource,true);
  AProject.CustomData.Values[PJSProjectWebBrowser]:='1';
  if baoUseURL in Options then
    begin
    AProject.CustomData.Remove(PJSProjectPort);
    AProject.CustomData.Values[PJSProjectURL]:=ProjectURL;
    end
  else
    begin
    AProject.CustomData.Values[PJSProjectPort]:=IntToStr(ProjectPort);
    AProject.CustomData.Remove(PJSProjectURL);
    end;
  With AProject.CustomData do
    begin
    DebugLn(['Info: (pas2jsdsgn) ',PJSProjectWebBrowser,': ',Values[PJSProjectWebBrowser]]);
    DebugLn(['Info: (pas2jsdsgn) ',PJSProjectPort,': ',Values[PJSProjectPort]]);
    DebugLn(['Info: (pas2jsdsgn) ',PJSProjectURL,': ',Values[PJSProjectURL]]);
    end;
  // create html source
  if baoCreateHtml in Options then
    begin
    debugln(['AAA2 TProjectPas2JSWebApp.InitProject ']);
    HTMLFile:=CreateHTMLFile(aProject,'project1.js');
    HTMLFile.CustomData[PJSIsProjectHTMLFile]:='1';
    if baoMaintainHTML in Options then
      AProject.CustomData.Values[PJSProjectMaintainHTML]:='1';
    if baoUseBrowserConsole in Options then
      AProject.CustomData[PJSProjectWebBrowser]:='1';
    if baoRunOnReady in options then
      AProject.CustomData[PJSProjectRunAtReady]:='1';
    end;
  //AProject.AddPackageDependency('pas2js_rtl');
  //if baoUseBrowserApp in Options then
  //  AProject.AddPackageDependency('fcl_base_pas2js');
end;

function TProjectPas2JSWebApp.CreateStartFiles(AProject: TLazProject
  ): TModalResult;
begin
  Result:=LazarusIDE.DoOpenEditorFile(AProject.MainFile.Filename,-1,-1,
                                      [ofProjectLoading,ofRegularFile]);
  if Result<>mrOK then
     exit;

  if baoCreateHtml in Options then
    Result:=LazarusIDE.DoOpenEditorFile('project1.html',-1,-1,
                                        [ofProjectLoading,ofRegularFile]);
end;

end.

