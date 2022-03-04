unit ProjectDescriptorTypes;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils,
  // LCL
  Controls, Forms,
  // Codetools
  FileProcs,
  // LazUtils
  LazFileUtils, LazUTF8,
  // IdeIntf
  CompOptsIntf, ProjectIntf, LazIDEIntf,
  // IDE
  frmCustomApplicationOptions, LazarusIDEStrConsts, Project, W32Manifest;

type

  //----------------------------------------------------------------------------

  { TProjectApplicationDescriptor }

  TProjectApplicationDescriptor = class(TProjectDescriptor)
  public
    constructor Create; override;
    function GetLocalizedName: string; override;
    function GetLocalizedGroup: string; override; //Ultibo
    function GetLocalizedDescription: string; override;
    function InitProject(AProject: TLazProject): TModalResult; override;
    function CreateStartFiles({%H-}AProject: TLazProject): TModalResult; override;
  end;

  { TProjectSimpleProgramDescriptor }

  TProjectSimpleProgramDescriptor = class(TProjectDescriptor)
  public
    constructor Create; override;
    function GetLocalizedName: string; override;
    function GetLocalizedGroup: string; override; //Ultibo
    function GetLocalizedDescription: string; override;
    function InitProject(AProject: TLazProject): TModalResult; override;
    function CreateStartFiles(AProject: TLazProject): TModalResult; override;
  end;

  { TProjectProgramDescriptor }

  TProjectProgramDescriptor = class(TProjectDescriptor)
  public
    constructor Create; override;
    function GetLocalizedName: string; override;
    function GetLocalizedGroup: string; override; //Ultibo
    function GetLocalizedDescription: string; override;
    function InitProject(AProject: TLazProject): TModalResult; override;
    function CreateStartFiles(AProject: TLazProject): TModalResult; override;
  end;

  { TProjectUltiboSimpleProgramDescriptor } //Ultibo

  TProjectSimpleUltiboProgramDescriptor = class(TProjectDescriptor) //Ultibo
  public
    constructor Create; override;
    function GetLocalizedName: string; override;
    function GetLocalizedGroup: string; override;
    function GetLocalizedDescription: string; override;
    function InitProject(AProject: TLazProject): TModalResult; override;
    function CreateStartFiles(AProject: TLazProject): TModalResult; override;
  end; //Ultibo

  { TProjectUltiboProgramDescriptor } //Ultibo

  TProjectUltiboProgramDescriptor = class(TProjectDescriptor) //Ultibo
  public
    constructor Create; override;
    function GetLocalizedName: string; override;
    function GetLocalizedGroup: string; override;
    function GetLocalizedDescription: string; override;
    function InitProject(AProject: TLazProject): TModalResult; override;
    function CreateStartFiles(AProject: TLazProject): TModalResult; override;
  end; //Ultibo

  { TProjectRaspberryPiProgramDescriptor } //Ultibo

  TProjectRaspberryPiProgramDescriptor = class(TProjectDescriptor) //Ultibo
  public
    constructor Create; override;
    function GetLocalizedName: string; override;
    function GetLocalizedGroup: string; override;
    function GetLocalizedDescription: string; override;
    function InitProject(AProject: TLazProject): TModalResult; override;
    function CreateStartFiles(AProject: TLazProject): TModalResult; override;
  end; //Ultibo
  
  { TProjectRaspberryPi2ProgramDescriptor } //Ultibo

  TProjectRaspberryPi2ProgramDescriptor = class(TProjectDescriptor) //Ultibo
  public
    constructor Create; override;
    function GetLocalizedName: string; override;
    function GetLocalizedGroup: string; override;
    function GetLocalizedDescription: string; override;
    function InitProject(AProject: TLazProject): TModalResult; override;
    function CreateStartFiles(AProject: TLazProject): TModalResult; override;
  end; //Ultibo

  { TProjectRaspberryPi3ProgramDescriptor } //Ultibo

  TProjectRaspberryPi3ProgramDescriptor = class(TProjectDescriptor) //Ultibo
  public
    constructor Create; override;
    function GetLocalizedName: string; override;
    function GetLocalizedGroup: string; override;
    function GetLocalizedDescription: string; override;
    function InitProject(AProject: TLazProject): TModalResult; override;
    function CreateStartFiles(AProject: TLazProject): TModalResult; override;
  end; //Ultibo

  { TProjectRaspberryPi4ProgramDescriptor } //Ultibo

  TProjectRaspberryPi4ProgramDescriptor = class(TProjectDescriptor) //Ultibo
  public
    constructor Create; override;
    function GetLocalizedName: string; override;
    function GetLocalizedGroup: string; override;
    function GetLocalizedDescription: string; override;
    function InitProject(AProject: TLazProject): TModalResult; override;
    function CreateStartFiles(AProject: TLazProject): TModalResult; override;
  end; //Ultibo
  
  { TProjectRaspberryPiZeroProgramDescriptor } //Ultibo

  TProjectRaspberryPiZeroProgramDescriptor = class(TProjectDescriptor) //Ultibo
  public
    constructor Create; override;
    function GetLocalizedName: string; override;
    function GetLocalizedGroup: string; override;
    function GetLocalizedDescription: string; override;
    function InitProject(AProject: TLazProject): TModalResult; override;
    function CreateStartFiles(AProject: TLazProject): TModalResult; override;
  end; //Ultibo

  { TProjectQEMUVersatilePBProgramDescriptor } //Ultibo

  TProjectQEMUVersatilePBProgramDescriptor = class(TProjectDescriptor) //Ultibo
  public
    constructor Create; override;
    function GetLocalizedName: string; override;
    function GetLocalizedGroup: string; override;
    function GetLocalizedDescription: string; override;
    function InitProject(AProject: TLazProject): TModalResult; override;
    function CreateStartFiles(AProject: TLazProject): TModalResult; override;
  end; //Ultibo

  { TProjectConsoleApplicationDescriptor }

  TProjectConsoleApplicationDescriptor = class(TProjectDescriptor)
  public
    constructor Create; override;
    function GetLocalizedName: string; override;
    function GetLocalizedGroup: string; override; //Ultibo
    function GetLocalizedDescription: string; override;
    function InitProject(AProject: TLazProject): TModalResult; override;
    function CreateStartFiles(AProject: TLazProject): TModalResult; override;
  end;

  { TProjectLibraryDescriptor }

  TProjectLibraryDescriptor = class(TProjectDescriptor)
  public
    constructor Create; override;
    function GetLocalizedName: string; override;
    function GetLocalizedGroup: string; override; //Ultibo
    function GetLocalizedDescription: string; override;
    function InitProject(AProject: TLazProject): TModalResult; override;
    function CreateStartFiles(AProject: TLazProject): TModalResult; override;
  end;

  { TProjectManualProgramDescriptor }

  TProjectManualProgramDescriptor = class(TProjectDescriptor)
  private
    FAddMainSource: boolean;
  public
    constructor Create; override;
    function GetLocalizedName: string; override;
    function GetLocalizedGroup: string; override; //Ultibo
    function GetLocalizedDescription: string; override;
    function InitProject(AProject: TLazProject): TModalResult; override;
    function CreateStartFiles(AProject: TLazProject): TModalResult; override;
    property AddMainSource: boolean read FAddMainSource write FAddMainSource;
  end;

  { TProjectEmptyProgramDescriptor }

  TProjectEmptyProgramDescriptor = class(TProjectManualProgramDescriptor)
  public
    constructor Create; override;
  end;


implementation

{ TProjectApplicationDescriptor }

constructor TProjectApplicationDescriptor.Create;
begin
  inherited Create;
  Name:=ProjDescNameApplication;
  Group:=ProjDescGroupName; //Ultibo
  Flags:=Flags+[pfUseDefaultCompilerOptions];
end;

function TProjectApplicationDescriptor.GetLocalizedName: string;
begin
  Result:=dlgPOApplication;
end;

function TProjectApplicationDescriptor.GetLocalizedGroup: string; //Ultibo
begin
  Result:=dlgProject;
end;

function TProjectApplicationDescriptor.GetLocalizedDescription: string;
begin
  Result:=lisApplicationProgramDescriptor;
end;

function TProjectApplicationDescriptor.InitProject(AProject: TLazProject): TModalResult;
var
  NewSource: String;
  MainFile: TLazProjectFile;
begin
  Result:=inherited InitProject(AProject);

  MainFile:=AProject.CreateProjectFile('project1.lpr');
  MainFile.IsPartOfProject:=true;
  AProject.AddFile(MainFile,false);
  AProject.MainFileID:=0;
  AProject.UseAppBundle:=true;
  AProject.UseManifest:=true;
  AProject.Scaled:=true;
  (AProject as TProject).ProjResources.XPManifest.DpiAware := xmdaTrue;
  AProject.LoadDefaultIcon;

  // create program source
  NewSource:='program Project1;'+LineEnding
    +LineEnding
    +'{$mode objfpc}{$H+}'+LineEnding
    +LineEnding
    +'uses'+LineEnding
    +'  {$IFDEF UNIX}'+LineEnding
    +'  cthreads,'+LineEnding
    +'  {$ENDIF}'+LineEnding
    +'  {$IFDEF HASAMIGA}'+LineEnding
    +'  athreads,'+LineEnding
    +'  {$ENDIF}'+LineEnding
    +'  Interfaces, // this includes the LCL widgetset'+LineEnding
    +'  Forms'+LineEnding
    +'  { you can add units after this };'+LineEnding
    +LineEnding
    +'begin'+LineEnding
    +'  RequireDerivedFormResource:=True;'+LineEnding
    +'  Application.Scaled:=True;'+LineEnding
    +'  Application.Initialize;'+LineEnding
    +'  Application.Run;'+LineEnding
    +'end.'+LineEnding
    +LineEnding;
  AProject.MainFile.SetSourceText(NewSource,true);

  // add lcl pp/pas dirs to source search path
  AProject.AddPackageDependency('LCL');
  AProject.LazCompilerOptions.Win32GraphicApp:=true;
  AProject.LazCompilerOptions.UnitOutputDirectory:='lib'+PathDelim+'$(TargetCPU)-$(TargetOS)';
  AProject.LazCompilerOptions.TargetFilename:='project1';
end;

function TProjectApplicationDescriptor.CreateStartFiles(AProject: TLazProject
  ): TModalResult;
begin
  Result:=LazarusIDE.DoNewEditorFile(FileDescriptorForm,'','',
                         [nfIsPartOfProject,nfOpenInEditor,nfCreateDefaultSrc]);
end;

{ TProjectSimpleProgramDescriptor }

constructor TProjectSimpleProgramDescriptor.Create;
begin
  inherited Create;
  Name:=ProjDescNameSimpleProgram;
  Group:=ProjDescGroupName; //Ultibo
  Flags:=Flags-[pfMainUnitHasCreateFormStatements,pfMainUnitHasTitleStatement,pfMainUnitHasScaledStatement]
              +[pfUseDefaultCompilerOptions];
end;

function TProjectSimpleProgramDescriptor.GetLocalizedName: string;
begin
  Result:=lisSimpleProgram;
end;

function TProjectSimpleProgramDescriptor.GetLocalizedGroup: string; //Ultibo
begin
  Result:=dlgProject;
end;

function TProjectSimpleProgramDescriptor.GetLocalizedDescription: string;
begin
  Result:=lisSimpleProgramProgramDescriptor;
end;

function TProjectSimpleProgramDescriptor.InitProject(AProject: TLazProject): TModalResult;
var
  NewSource: String;
  MainFile: TLazProjectFile;
begin
  Result:=inherited InitProject(AProject);

  MainFile:=AProject.CreateProjectFile('project1.lpr');
  MainFile.IsPartOfProject:=true;
  AProject.AddFile(MainFile,false);
  AProject.MainFileID:=0;

  // create program source
  NewSource:='program Project1;'+LineEnding
    +LineEnding
    +'begin'+LineEnding
    +'end.'+LineEnding
    +LineEnding;
  AProject.MainFile.SetSourceText(NewSource,true);

  AProject.LazCompilerOptions.UnitOutputDirectory:='lib'+PathDelim+'$(TargetCPU)-$(TargetOS)';
  AProject.LazCompilerOptions.TargetFilename:='project1';
end;

function TProjectSimpleProgramDescriptor.CreateStartFiles(AProject: TLazProject): TModalResult;
begin
  Result:=LazarusIDE.DoOpenEditorFile(AProject.MainFile.Filename,-1,-1,
                                      [ofProjectLoading,ofRegularFile]);
end;

{ TProjectProgramDescriptor }

constructor TProjectProgramDescriptor.Create;
begin
  inherited Create;
  Name:=ProjDescNameProgram;
  Group:=ProjDescGroupName; //Ultibo
  Flags:=Flags-[pfMainUnitHasCreateFormStatements,pfMainUnitHasTitleStatement,pfMainUnitHasScaledStatement]
              +[pfUseDefaultCompilerOptions];
end;

function TProjectProgramDescriptor.GetLocalizedName: string;
begin
  Result:=lisProgram;
end;

function TProjectProgramDescriptor.GetLocalizedGroup: string; //Ultibo
begin
  Result:=dlgProject;
end;

function TProjectProgramDescriptor.GetLocalizedDescription: string;
begin
  Result:=lisProgramProgramDescriptor;
end;

function TProjectProgramDescriptor.InitProject(AProject: TLazProject): TModalResult;
var
  NewSource: String;
  MainFile: TLazProjectFile;
begin
  Result:=inherited InitProject(AProject);

  MainFile:=AProject.CreateProjectFile('project1.lpr');
  MainFile.IsPartOfProject:=true;
  AProject.AddFile(MainFile,false);
  AProject.MainFileID:=0;

  // create program source
  NewSource:='program Project1;'+LineEnding
    +LineEnding
    +'{$mode objfpc}{$H+}'+LineEnding
    +LineEnding
    +'uses'+LineEnding
    +'  {$IFDEF UNIX}'+LineEnding
    +'  cthreads,'+LineEnding
    +'  {$ENDIF}'+LineEnding
    +'  Classes'+LineEnding
    +'  { you can add units after this };'+LineEnding
    +LineEnding
    +'begin'+LineEnding
    +'end.'+LineEnding
    +LineEnding;
  AProject.MainFile.SetSourceText(NewSource,true);

  AProject.LazCompilerOptions.UnitOutputDirectory:='lib'+PathDelim+'$(TargetCPU)-$(TargetOS)';
  AProject.LazCompilerOptions.TargetFilename:='project1';
end;

function TProjectProgramDescriptor.CreateStartFiles(AProject: TLazProject): TModalResult;
begin
  Result:=LazarusIDE.DoOpenEditorFile(AProject.MainFile.Filename,-1,-1,
                                      [ofProjectLoading,ofRegularFile]);
end;

{ TProjectSimpleUltiboProgramDescriptor } //Ultibo

constructor TProjectSimpleUltiboProgramDescriptor.Create; //Ultibo
begin
  inherited Create;
  Name:=ProjDescNameSimpleUltiboProgram;
  Group:=ProjDescGroupNameUltibo;
  Flags:=Flags-[pfMainUnitHasCreateFormStatements,pfMainUnitHasTitleStatement,pfMainUnitHasScaledStatement]
              -[pfRunnable,pfUseDesignTimePackages]
              +[pfUseDefaultCompilerOptions];
end;

function TProjectSimpleUltiboProgramDescriptor.GetLocalizedName: string; //Ultibo
begin
  Result:=lisSimpleUltiboProgram;
end;

function TProjectSimpleUltiboProgramDescriptor.GetLocalizedGroup: string; //Ultibo
begin
  Result:=dlgUltiboProject;
end;

function TProjectSimpleUltiboProgramDescriptor.GetLocalizedDescription: string; //Ultibo
begin
  Result:=lisSimpleUltiboProgramProgramDescriptor;
end;

function TProjectSimpleUltiboProgramDescriptor.InitProject(AProject: TLazProject): TModalResult; //Ultibo
var
  NewSource: String;
  MainFile: TLazProjectFile;
begin
  Result:=inherited InitProject(AProject);

  MainFile:=AProject.CreateProjectFile('project1.lpr');
  MainFile.IsPartOfProject:=true;
  AProject.AddFile(MainFile,false);
  AProject.MainFileID:=0;

  // create program source
  NewSource:='program Project1;'+LineEnding
    +LineEnding
    +'{ Getting Started with Ultibo                                                  }'+LineEnding
    +'{  Add your program code below, add a "uses" section and additional units if   }'+LineEnding
    +'{  required and create new units by selecting File, New Unit from the menu.    }'+LineEnding
    +'{                                                                              }'+LineEnding
    +'{  Select Project, Project Options from the menu and specify your type of      }'+LineEnding
    +'{  board and from the Config and Target page.                                  }'+LineEnding
    +'{                                                                              }'+LineEnding
    +'{  To compile your program select Run, Compile (or Run, Build) from the menu.  }'+LineEnding
    +'{                                                                              }'+LineEnding
    +'{ Tip                                                                          }'+LineEnding
    +'{  To start a new project with specific settings for Raspberry Pi select File, }'+LineEnding
    +'{  New ... from the menu and choose the application that suits the model of    }'+LineEnding
    +'{  Raspberry Pi you have.                                                      }'+LineEnding
    +'{                                                                              }'+LineEnding
    +'{  Some simple example programs are available under Tools, Example Projects.   }'+LineEnding
    +LineEnding
    +'begin'+LineEnding
    +' { Add your program code here }'+LineEnding
    +'end.'+LineEnding
    +LineEnding;
  AProject.MainFile.SetSourceText(NewSource,true);

  AProject.LazCompilerOptions.UnitOutputDirectory:='lib'+PathDelim+'$(TargetCPU)-$(TargetOS)';
  AProject.LazCompilerOptions.TargetFilename:='project1';

  AProject.LazCompilerOptions.TargetCPU:='arm';
  AProject.LazCompilerOptions.TargetOS:='ultibo';
  AProject.LazCompilerOptions.TargetProcessor:='';
  AProject.LazCompilerOptions.TargetController:='';
  AProject.LazCompilerOptions.OptimizationLevel:=2;
  AProject.LazCompilerOptions.GenerateDebugInfo:=False;
  AProject.LazCompilerOptions.UseLineInfoUnit:=False;
  AProject.LazCompilerOptions.SmartLinkUnit:=True;
  AProject.LazCompilerOptions.LinkSmart:=True;
end;

function TProjectSimpleUltiboProgramDescriptor.CreateStartFiles(AProject: TLazProject): TModalResult; //Ultibo
begin
  Result:=LazarusIDE.DoOpenEditorFile(AProject.MainFile.Filename,-1,-1,
                                      [ofProjectLoading,ofRegularFile]);
end;

{ TProjectUltiboProgramDescriptor } //Ultibo

constructor TProjectUltiboProgramDescriptor.Create; //Ultibo
begin
  inherited Create;
  Name:=ProjDescNameUltiboProgram;
  Group:=ProjDescGroupNameUltibo;
  Flags:=Flags-[pfMainUnitHasCreateFormStatements,pfMainUnitHasTitleStatement,pfMainUnitHasScaledStatement]
              -[pfRunnable,pfUseDesignTimePackages]
              +[pfUseDefaultCompilerOptions];
end;

function TProjectUltiboProgramDescriptor.GetLocalizedName: string; //Ultibo
begin
  Result:=lisUltiboProgram;
end;

function TProjectUltiboProgramDescriptor.GetLocalizedGroup: string; //Ultibo
begin
  Result:=dlgUltiboProject;
end;

function TProjectUltiboProgramDescriptor.GetLocalizedDescription: string; //Ultibo
begin
  Result:=lisUltiboProgramProgramDescriptor;
end;

function TProjectUltiboProgramDescriptor.InitProject(AProject: TLazProject): TModalResult; //Ultibo
var
  NewSource: String;
  MainFile: TLazProjectFile;
begin
  Result:=inherited InitProject(AProject);

  MainFile:=AProject.CreateProjectFile('project1.lpr');
  MainFile.IsPartOfProject:=true;
  AProject.AddFile(MainFile,false);
  AProject.MainFileID:=0;

  // create program source
  NewSource:='program Project1;'+LineEnding
    +LineEnding
    +'{$mode objfpc}{$H+}'+LineEnding
    +LineEnding
    +'{ Getting Started with Ultibo                                                  }'+LineEnding
    +'{  Add your program code below, add additional units to the "uses" section if  }'+LineEnding
    +'{  required and create new units by selecting File, New Unit from the menu.    }'+LineEnding
    +'{                                                                              }'+LineEnding
    +'{  Select Project, Project Options from the menu and specify your type of      }'+LineEnding
    +'{  board and from the Config and Target page.                                  }'+LineEnding
    +'{                                                                              }'+LineEnding
    +'{  To compile your program select Run, Compile (or Run, Build) from the menu.  }'+LineEnding
    +'{                                                                              }'+LineEnding
    +'{ Tip                                                                          }'+LineEnding
    +'{  To start a new project with specific settings for Raspberry Pi select File, }'+LineEnding
    +'{  New ... from the menu and choose the application that suits the model of    }'+LineEnding
    +'{  Raspberry Pi you have.                                                      }'+LineEnding
    +'{                                                                              }'+LineEnding
    +'{  Some simple example programs are available under Tools, Example Projects.   }'+LineEnding
    +LineEnding
    +'uses'+LineEnding
    +'  GlobalConfig,'+LineEnding
    +'  GlobalConst,'+LineEnding
    +'  GlobalTypes,'+LineEnding
    +'  Platform,'+LineEnding
    +'  Threads,'+LineEnding
    +'  SysUtils,'+LineEnding
    +'  Classes,'+LineEnding
    +'  Ultibo'+LineEnding
    +'  { Add additional units here };'+LineEnding
    +LineEnding
    +'begin'+LineEnding
    +' { Add your program code here }'+LineEnding
    +'end.'+LineEnding
    +LineEnding;
  AProject.MainFile.SetSourceText(NewSource,true);

  AProject.LazCompilerOptions.UnitOutputDirectory:='lib'+PathDelim+'$(TargetCPU)-$(TargetOS)';
  AProject.LazCompilerOptions.TargetFilename:='project1';

  AProject.LazCompilerOptions.TargetCPU:='arm';
  AProject.LazCompilerOptions.TargetOS:='ultibo';
  AProject.LazCompilerOptions.TargetProcessor:='';
  AProject.LazCompilerOptions.TargetController:='';
  AProject.LazCompilerOptions.OptimizationLevel:=2;
  AProject.LazCompilerOptions.GenerateDebugInfo:=False;
  AProject.LazCompilerOptions.UseLineInfoUnit:=False;
  AProject.LazCompilerOptions.SmartLinkUnit:=True;
  AProject.LazCompilerOptions.LinkSmart:=True;
end;

function TProjectUltiboProgramDescriptor.CreateStartFiles(AProject: TLazProject): TModalResult; //Ultibo
begin
  Result:=LazarusIDE.DoOpenEditorFile(AProject.MainFile.Filename,-1,-1,
                                      [ofProjectLoading,ofRegularFile]);
end;

{ TProjectRaspberryPiProgramDescriptor } //Ultibo

constructor TProjectRaspberryPiProgramDescriptor.Create; //Ultibo
begin
  inherited Create;
  Name:=ProjDescNameRaspberryPiProgram;
  Group:=ProjDescGroupNameUltibo;
  Flags:=Flags-[pfMainUnitHasCreateFormStatements,pfMainUnitHasTitleStatement,pfRunnable,pfUseDesignTimePackages]; //Ultibo
              //+[pfUseDefaultCompilerOptions]; //Do not use defaults for specific model templates
end;

function TProjectRaspberryPiProgramDescriptor.GetLocalizedName: string; //Ultibo
begin
  Result:=lisRaspberryPiProgram;
end;

function TProjectRaspberryPiProgramDescriptor.GetLocalizedGroup: string; //Ultibo
begin
  Result:=dlgUltiboProject;
end;

function TProjectRaspberryPiProgramDescriptor.GetLocalizedDescription: string; //Ultibo
begin
  Result:=lisRaspberryPiProgramProgramDescriptor;
end;

function TProjectRaspberryPiProgramDescriptor.InitProject(AProject: TLazProject): TModalResult; //Ultibo
var
  NewSource: String;
  MainFile: TLazProjectFile;
begin
  Result:=inherited InitProject(AProject);

  MainFile:=AProject.CreateProjectFile('project1.lpr');
  MainFile.IsPartOfProject:=true;
  AProject.AddFile(MainFile,false);
  AProject.MainFileID:=0;

  // create program source
  NewSource:='program Project1;'+LineEnding
    +LineEnding
    +'{$mode objfpc}{$H+}'+LineEnding
    +LineEnding 
    +'{ Raspberry Pi Application                                                     }'+LineEnding 
    +'{  Add your program code below, add additional units to the "uses" section if  }'+LineEnding 
    +'{  required and create new units by selecting File, New Unit from the menu.    }'+LineEnding 
    +'{                                                                              }'+LineEnding 
    +'{  To compile your program select Run, Compile (or Run, Build) from the menu.  }'+LineEnding 
    +'{                                                                              }'+LineEnding 
    +'{  To build for the QEMU target select Project, Project Options ... from the   }'+LineEnding 
    +'{  menu, go to Config and Target and choose the appropriate Target Controller. }'+LineEnding 
    +LineEnding
    +'uses'+LineEnding
    +'  RaspberryPi,'+LineEnding
    +'  GlobalConfig,'+LineEnding 
    +'  GlobalConst,'+LineEnding 
    +'  GlobalTypes,'+LineEnding 
    +'  Platform,'+LineEnding
    +'  Threads,'+LineEnding
    +'  SysUtils,'+LineEnding
    +'  Classes,'+LineEnding
    +'  Ultibo'+LineEnding
    +'  { Add additional units here };'+LineEnding
    +LineEnding
    +'begin'+LineEnding
    +' { Add your program code here }'+LineEnding
    +'end.'+LineEnding
    +LineEnding;
  AProject.MainFile.SetSourceText(NewSource,true);

  AProject.LazCompilerOptions.UnitOutputDirectory:='lib'+PathDelim+'$(TargetCPU)-$(TargetOS)';
  AProject.LazCompilerOptions.TargetFilename:='project1';
  
  AProject.LazCompilerOptions.TargetCPU:='arm';
  AProject.LazCompilerOptions.TargetOS:='ultibo';
  AProject.LazCompilerOptions.TargetProcessor:='armv6'; 
  AProject.LazCompilerOptions.TargetController:='RPIB'; 
  AProject.LazCompilerOptions.OptimizationLevel:=2; 
  AProject.LazCompilerOptions.GenerateDebugInfo:=False; 
  AProject.LazCompilerOptions.UseLineInfoUnit:=False;
  AProject.LazCompilerOptions.SmartLinkUnit:=True; 
  AProject.LazCompilerOptions.LinkSmart:=True; 
end;

function TProjectRaspberryPiProgramDescriptor.CreateStartFiles(AProject: TLazProject): TModalResult; //Ultibo
begin
  Result:=LazarusIDE.DoOpenEditorFile(AProject.MainFile.Filename,-1,-1,
                                      [ofProjectLoading,ofRegularFile]);
end;

{ TProjectRaspberryPi2ProgramDescriptor } //Ultibo

constructor TProjectRaspberryPi2ProgramDescriptor.Create; //Ultibo
begin
  inherited Create;
  Name:=ProjDescNameRaspberryPi2Program;
  Group:=ProjDescGroupNameUltibo;
  Flags:=Flags-[pfMainUnitHasCreateFormStatements,pfMainUnitHasTitleStatement,pfRunnable,pfUseDesignTimePackages]; //Ultibo
              //+[pfUseDefaultCompilerOptions]; //Do not use defaults for specific model templates
end;

function TProjectRaspberryPi2ProgramDescriptor.GetLocalizedName: string; //Ultibo
begin
  Result:=lisRaspberryPi2Program;
end;

function TProjectRaspberryPi2ProgramDescriptor.GetLocalizedGroup: string; //Ultibo
begin
  Result:=dlgUltiboProject;
end;

function TProjectRaspberryPi2ProgramDescriptor.GetLocalizedDescription: string; //Ultibo
begin
  Result:=lisRaspberryPi2ProgramProgramDescriptor;
end;

function TProjectRaspberryPi2ProgramDescriptor.InitProject(AProject: TLazProject): TModalResult; //Ultibo
var
  NewSource: String;
  MainFile: TLazProjectFile;
begin
  Result:=inherited InitProject(AProject);

  MainFile:=AProject.CreateProjectFile('project1.lpr');
  MainFile.IsPartOfProject:=true;
  AProject.AddFile(MainFile,false);
  AProject.MainFileID:=0;

  // create program source
  NewSource:='program Project1;'+LineEnding
    +LineEnding
    +'{$mode objfpc}{$H+}'+LineEnding
    +LineEnding
    +'{ Raspberry Pi 2 Application                                                   }'+LineEnding 
    +'{  Add your program code below, add additional units to the "uses" section if  }'+LineEnding 
    +'{  required and create new units by selecting File, New Unit from the menu.    }'+LineEnding 
    +'{                                                                              }'+LineEnding 
    +'{  To compile your program select Run, Compile (or Run, Build) from the menu.  }'+LineEnding 
    +'{                                                                              }'+LineEnding 
    +'{  To build for the QEMU target select Project, Project Options ... from the   }'+LineEnding 
    +'{  menu, go to Config and Target and choose the appropriate Target Controller. }'+LineEnding 
    +LineEnding
    +'uses'+LineEnding
    +'  RaspberryPi2,'+LineEnding
    +'  GlobalConfig,'+LineEnding 
    +'  GlobalConst,'+LineEnding 
    +'  GlobalTypes,'+LineEnding 
    +'  Platform,'+LineEnding
    +'  Threads,'+LineEnding
    +'  SysUtils,'+LineEnding
    +'  Classes,'+LineEnding
    +'  Ultibo'+LineEnding
    +'  { Add additional units here };'+LineEnding
    +LineEnding
    +'begin'+LineEnding
    +' { Add your program code here }'+LineEnding
    +'end.'+LineEnding
    +LineEnding;
  AProject.MainFile.SetSourceText(NewSource,true);

  AProject.LazCompilerOptions.UnitOutputDirectory:='lib'+PathDelim+'$(TargetCPU)-$(TargetOS)';
  AProject.LazCompilerOptions.TargetFilename:='project1';
  
  AProject.LazCompilerOptions.TargetCPU:='arm';
  AProject.LazCompilerOptions.TargetOS:='ultibo';
  AProject.LazCompilerOptions.TargetProcessor:='armv7a';
  AProject.LazCompilerOptions.TargetController:='RPI2B';
  AProject.LazCompilerOptions.OptimizationLevel:=2;
  AProject.LazCompilerOptions.GenerateDebugInfo:=False;
  AProject.LazCompilerOptions.UseLineInfoUnit:=False;
  AProject.LazCompilerOptions.SmartLinkUnit:=True;
  AProject.LazCompilerOptions.LinkSmart:=True;
end;

function TProjectRaspberryPi2ProgramDescriptor.CreateStartFiles(AProject: TLazProject): TModalResult; //Ultibo
begin
  Result:=LazarusIDE.DoOpenEditorFile(AProject.MainFile.Filename,-1,-1,
                                      [ofProjectLoading,ofRegularFile]);
end;

{ TProjectRaspberryPi3ProgramDescriptor } //Ultibo

constructor TProjectRaspberryPi3ProgramDescriptor.Create; //Ultibo
begin
  inherited Create;
  Name:=ProjDescNameRaspberryPi3Program;
  Group:=ProjDescGroupNameUltibo;
  Flags:=Flags-[pfMainUnitHasCreateFormStatements,pfMainUnitHasTitleStatement,pfRunnable,pfUseDesignTimePackages]; //Ultibo
              //+[pfUseDefaultCompilerOptions]; //Do not use defaults for specific model templates
end;

function TProjectRaspberryPi3ProgramDescriptor.GetLocalizedName: string; //Ultibo
begin
  Result:=lisRaspberryPi3Program;
end;

function TProjectRaspberryPi3ProgramDescriptor.GetLocalizedGroup: string; //Ultibo
begin
  Result:=dlgUltiboProject;
end;

function TProjectRaspberryPi3ProgramDescriptor.GetLocalizedDescription: string; //Ultibo
begin
  Result:=lisRaspberryPi3ProgramProgramDescriptor;
end;

function TProjectRaspberryPi3ProgramDescriptor.InitProject(AProject: TLazProject): TModalResult; //Ultibo
var
  NewSource: String;
  MainFile: TLazProjectFile;
begin
  Result:=inherited InitProject(AProject);

  MainFile:=AProject.CreateProjectFile('project1.lpr');
  MainFile.IsPartOfProject:=true;
  AProject.AddFile(MainFile,false);
  AProject.MainFileID:=0;

  // create program source
  NewSource:='program Project1;'+LineEnding
    +LineEnding
    +'{$mode objfpc}{$H+}'+LineEnding
    +LineEnding
    +'{ Raspberry Pi 3 Application                                                   }'+LineEnding 
    +'{  Add your program code below, add additional units to the "uses" section if  }'+LineEnding 
    +'{  required and create new units by selecting File, New Unit from the menu.    }'+LineEnding 
    +'{                                                                              }'+LineEnding 
    +'{  To compile your program select Run, Compile (or Run, Build) from the menu.  }'+LineEnding 
    +'{                                                                              }'+LineEnding 
    +'{  To build for the QEMU target select Project, Project Options ... from the   }'+LineEnding 
    +'{  menu, go to Config and Target and choose the appropriate Target Controller. }'+LineEnding 
    +LineEnding
    +'uses'+LineEnding
    +'  RaspberryPi3,'+LineEnding
    +'  GlobalConfig,'+LineEnding 
    +'  GlobalConst,'+LineEnding 
    +'  GlobalTypes,'+LineEnding 
    +'  Platform,'+LineEnding
    +'  Threads,'+LineEnding
    +'  SysUtils,'+LineEnding
    +'  Classes,'+LineEnding
    +'  Ultibo'+LineEnding
    +'  { Add additional units here };'+LineEnding
    +LineEnding
    +'begin'+LineEnding
    +' { Add your program code here }'+LineEnding
    +'end.'+LineEnding
    +LineEnding;
  AProject.MainFile.SetSourceText(NewSource,true);

  AProject.LazCompilerOptions.UnitOutputDirectory:='lib'+PathDelim+'$(TargetCPU)-$(TargetOS)';
  AProject.LazCompilerOptions.TargetFilename:='project1';
  
  AProject.LazCompilerOptions.TargetCPU:='arm';
  AProject.LazCompilerOptions.TargetOS:='ultibo';
  AProject.LazCompilerOptions.TargetProcessor:='armv7a';
  AProject.LazCompilerOptions.TargetController:='RPI3B';
  AProject.LazCompilerOptions.OptimizationLevel:=2;
  AProject.LazCompilerOptions.GenerateDebugInfo:=False;
  AProject.LazCompilerOptions.UseLineInfoUnit:=False;
  AProject.LazCompilerOptions.SmartLinkUnit:=True;
  AProject.LazCompilerOptions.LinkSmart:=True;
end;

function TProjectRaspberryPi3ProgramDescriptor.CreateStartFiles(AProject: TLazProject): TModalResult; //Ultibo
begin
  Result:=LazarusIDE.DoOpenEditorFile(AProject.MainFile.Filename,-1,-1,
                                      [ofProjectLoading,ofRegularFile]);
end;

{ TProjectRaspberryPi4ProgramDescriptor } //Ultibo

constructor TProjectRaspberryPi4ProgramDescriptor.Create; //Ultibo
begin
  inherited Create;
  Name:=ProjDescNameRaspberryPi4Program;
  Group:=ProjDescGroupNameUltibo;
  Flags:=Flags-[pfMainUnitHasCreateFormStatements,pfMainUnitHasTitleStatement,pfRunnable,pfUseDesignTimePackages]; //Ultibo
              //+[pfUseDefaultCompilerOptions]; //Do not use defaults for specific model templates
end;

function TProjectRaspberryPi4ProgramDescriptor.GetLocalizedName: string; //Ultibo
begin
  Result:=lisRaspberryPi4Program;
end;

function TProjectRaspberryPi4ProgramDescriptor.GetLocalizedGroup: string; //Ultibo
begin
  Result:=dlgUltiboProject;
end;

function TProjectRaspberryPi4ProgramDescriptor.GetLocalizedDescription: string; //Ultibo
begin
  Result:=lisRaspberryPi4ProgramProgramDescriptor;
end;

function TProjectRaspberryPi4ProgramDescriptor.InitProject(AProject: TLazProject): TModalResult; //Ultibo
var
  NewSource: String;
  MainFile: TLazProjectFile;
begin
  Result:=inherited InitProject(AProject);

  MainFile:=AProject.CreateProjectFile('project1.lpr');
  MainFile.IsPartOfProject:=true;
  AProject.AddFile(MainFile,false);
  AProject.MainFileID:=0;

  // create program source
  NewSource:='program Project1;'+LineEnding
    +LineEnding
    +'{$mode objfpc}{$H+}'+LineEnding
    +LineEnding
    +'{ Raspberry Pi 4 Application                                                   }'+LineEnding 
    +'{  Add your program code below, add additional units to the "uses" section if  }'+LineEnding 
    +'{  required and create new units by selecting File, New Unit from the menu.    }'+LineEnding 
    +'{                                                                              }'+LineEnding 
    +'{  To compile your program select Run, Compile (or Run, Build) from the menu.  }'+LineEnding 
//    +'{                                                                              }'+LineEnding 
//    +'{  To build for the QEMU target select Project, Project Options ... from the   }'+LineEnding 
//    +'{  menu, go to Config and Target and choose the appropriate Target Controller. }'+LineEnding 
    +LineEnding
    +'uses'+LineEnding
    +'  RaspberryPi4,'+LineEnding
    +'  GlobalConfig,'+LineEnding 
    +'  GlobalConst,'+LineEnding 
    +'  GlobalTypes,'+LineEnding 
    +'  Platform,'+LineEnding
    +'  Threads,'+LineEnding
    +'  SysUtils,'+LineEnding
    +'  Classes,'+LineEnding
    +'  Ultibo'+LineEnding
    +'  { Add additional units here };'+LineEnding
    +LineEnding
    +'begin'+LineEnding
    +' { Add your program code here }'+LineEnding
    +'end.'+LineEnding
    +LineEnding;
  AProject.MainFile.SetSourceText(NewSource,true);

  AProject.LazCompilerOptions.UnitOutputDirectory:='lib'+PathDelim+'$(TargetCPU)-$(TargetOS)';
  AProject.LazCompilerOptions.TargetFilename:='project1';
  
  AProject.LazCompilerOptions.TargetCPU:='arm';
  AProject.LazCompilerOptions.TargetOS:='ultibo';
  AProject.LazCompilerOptions.TargetProcessor:='armv7a';
  AProject.LazCompilerOptions.TargetController:='RPI4B';
  AProject.LazCompilerOptions.OptimizationLevel:=2;
  AProject.LazCompilerOptions.GenerateDebugInfo:=False;
  AProject.LazCompilerOptions.UseLineInfoUnit:=False;
  AProject.LazCompilerOptions.SmartLinkUnit:=True;
  AProject.LazCompilerOptions.LinkSmart:=True;
end;

function TProjectRaspberryPi4ProgramDescriptor.CreateStartFiles(AProject: TLazProject): TModalResult; //Ultibo
begin
  Result:=LazarusIDE.DoOpenEditorFile(AProject.MainFile.Filename,-1,-1,
                                      [ofProjectLoading,ofRegularFile]);
end;

{ TProjectRaspberryPiZeroProgramDescriptor } //Ultibo

constructor TProjectRaspberryPiZeroProgramDescriptor.Create; //Ultibo
begin
  inherited Create;
  Name:=ProjDescNameRaspberryPiZeroProgram;
  Group:=ProjDescGroupNameUltibo;
  Flags:=Flags-[pfMainUnitHasCreateFormStatements,pfMainUnitHasTitleStatement,pfRunnable,pfUseDesignTimePackages]; //Ultibo
              //+[pfUseDefaultCompilerOptions]; //Do not use defaults for specific model templates
end;

function TProjectRaspberryPiZeroProgramDescriptor.GetLocalizedName: string; //Ultibo
begin
  Result:=lisRaspberryPiZeroProgram;
end;

function TProjectRaspberryPiZeroProgramDescriptor.GetLocalizedGroup: string; //Ultibo
begin
  Result:=dlgUltiboProject;
end;

function TProjectRaspberryPiZeroProgramDescriptor.GetLocalizedDescription: string; //Ultibo
begin
  Result:=lisRaspberryPiZeroProgramProgramDescriptor;
end;

function TProjectRaspberryPiZeroProgramDescriptor.InitProject(AProject: TLazProject): TModalResult; //Ultibo
var
  NewSource: String;
  MainFile: TLazProjectFile;
begin
  Result:=inherited InitProject(AProject);

  MainFile:=AProject.CreateProjectFile('project1.lpr');
  MainFile.IsPartOfProject:=true;
  AProject.AddFile(MainFile,false);
  AProject.MainFileID:=0;

  // create program source
  NewSource:='program Project1;'+LineEnding
    +LineEnding
    +'{$mode objfpc}{$H+}'+LineEnding
    +LineEnding
    +'{ Raspberry Pi Zero Application                                                }'+LineEnding 
    +'{  Add your program code below, add additional units to the "uses" section if  }'+LineEnding 
    +'{  required and create new units by selecting File, New Unit from the menu.    }'+LineEnding 
    +'{                                                                              }'+LineEnding 
    +'{  To compile your program select Run, Compile (or Run, Build) from the menu.  }'+LineEnding 
    +'{                                                                              }'+LineEnding 
    +'{  To build for the QEMU target select Project, Project Options ... from the   }'+LineEnding 
    +'{  menu, go to Config and Target and choose the appropriate Target Controller. }'+LineEnding 
    +LineEnding
    +'uses'+LineEnding
    +'  RaspberryPi,'+LineEnding
    +'  GlobalConfig,'+LineEnding 
    +'  GlobalConst,'+LineEnding 
    +'  GlobalTypes,'+LineEnding 
    +'  Platform,'+LineEnding
    +'  Threads,'+LineEnding
    +'  SysUtils,'+LineEnding
    +'  Classes,'+LineEnding
    +'  Ultibo'+LineEnding
    +'  { Add additional units here };'+LineEnding
    +LineEnding
    +'begin'+LineEnding
    +' { Add your program code here }'+LineEnding
    +'end.'+LineEnding
    +LineEnding;
  AProject.MainFile.SetSourceText(NewSource,true);

  AProject.LazCompilerOptions.UnitOutputDirectory:='lib'+PathDelim+'$(TargetCPU)-$(TargetOS)';
  AProject.LazCompilerOptions.TargetFilename:='project1';
  
  AProject.LazCompilerOptions.TargetCPU:='arm';
  AProject.LazCompilerOptions.TargetOS:='ultibo';
  AProject.LazCompilerOptions.TargetProcessor:='armv6';
  AProject.LazCompilerOptions.TargetController:='RPIZERO';
  AProject.LazCompilerOptions.OptimizationLevel:=2;
  AProject.LazCompilerOptions.GenerateDebugInfo:=False;
  AProject.LazCompilerOptions.UseLineInfoUnit:=False;
  AProject.LazCompilerOptions.SmartLinkUnit:=True;
  AProject.LazCompilerOptions.LinkSmart:=True;
end;

function TProjectRaspberryPiZeroProgramDescriptor.CreateStartFiles(AProject: TLazProject): TModalResult; //Ultibo
begin
  Result:=LazarusIDE.DoOpenEditorFile(AProject.MainFile.Filename,-1,-1,
                                      [ofProjectLoading,ofRegularFile]);
end;

{ TProjectQEMUVersatilePBProgramDescriptor } //Ultibo

constructor TProjectQEMUVersatilePBProgramDescriptor.Create; //Ultibo
begin
  inherited Create;
  Name:=ProjDescNameQEMUVersatilePBProgram;
  Group:=ProjDescGroupNameUltibo;
  Flags:=Flags-[pfMainUnitHasCreateFormStatements,pfMainUnitHasTitleStatement,pfRunnable,pfUseDesignTimePackages]; //Ultibo
              //+[pfUseDefaultCompilerOptions]; //Do not use defaults for specific model templates
end;

function TProjectQEMUVersatilePBProgramDescriptor.GetLocalizedName: string; //Ultibo
begin
  Result:=lisQEMUVersatilePBProgram;
end;

function TProjectQEMUVersatilePBProgramDescriptor.GetLocalizedGroup: string; //Ultibo
begin
  Result:=dlgUltiboProject;
end;

function TProjectQEMUVersatilePBProgramDescriptor.GetLocalizedDescription: string; //Ultibo
begin
  Result:=lisQEMUVersatilePBProgramProgramDescriptor;
end;

function TProjectQEMUVersatilePBProgramDescriptor.InitProject(AProject: TLazProject): TModalResult; //Ultibo
var
  NewSource: String;
  MainFile: TLazProjectFile;
begin
  Result:=inherited InitProject(AProject);

  MainFile:=AProject.CreateProjectFile('project1.lpr');
  MainFile.IsPartOfProject:=true;
  AProject.AddFile(MainFile,false);
  AProject.MainFileID:=0;

  // create program source
  NewSource:='program Project1;'+LineEnding
    +LineEnding
    +'{$mode objfpc}{$H+}'+LineEnding
    +LineEnding
    +'{ QEMU VersatilePB Application                                                 }'+LineEnding 
    +'{  Add your program code below, add additional units to the "uses" section if  }'+LineEnding 
    +'{  required and create new units by selecting File, New Unit from the menu.    }'+LineEnding 
    +'{                                                                              }'+LineEnding 
    +'{  To compile your program select Run, Compile (or Run, Build) from the menu.  }'+LineEnding 
    +LineEnding
    +'uses'+LineEnding
    +'  QEMUVersatilePB,'+LineEnding
    +'  GlobalConfig,'+LineEnding 
    +'  GlobalConst,'+LineEnding 
    +'  GlobalTypes,'+LineEnding 
    +'  Platform,'+LineEnding
    +'  Threads,'+LineEnding
    +'  SysUtils,'+LineEnding
    +'  Classes,'+LineEnding
    +'  Ultibo'+LineEnding
    +'  { Add additional units here };'+LineEnding
    +LineEnding
    +'begin'+LineEnding
    +' { Add your program code here }'+LineEnding
    +'end.'+LineEnding
    +LineEnding;
  AProject.MainFile.SetSourceText(NewSource,true);

  AProject.LazCompilerOptions.UnitOutputDirectory:='lib'+PathDelim+'$(TargetCPU)-$(TargetOS)';
  AProject.LazCompilerOptions.TargetFilename:='project1';
  
  AProject.LazCompilerOptions.TargetCPU:='arm';
  AProject.LazCompilerOptions.TargetOS:='ultibo';
  AProject.LazCompilerOptions.TargetProcessor:='armv7a';
  AProject.LazCompilerOptions.TargetController:='QEMUVPB';
  AProject.LazCompilerOptions.OptimizationLevel:=2;
  AProject.LazCompilerOptions.GenerateDebugInfo:=False;
  AProject.LazCompilerOptions.UseLineInfoUnit:=False;
  AProject.LazCompilerOptions.SmartLinkUnit:=True;
  AProject.LazCompilerOptions.LinkSmart:=True;
end;

function TProjectQEMUVersatilePBProgramDescriptor.CreateStartFiles(AProject: TLazProject): TModalResult; //Ultibo
begin
  Result:=LazarusIDE.DoOpenEditorFile(AProject.MainFile.Filename,-1,-1,
                                      [ofProjectLoading,ofRegularFile]);
end;

{ TProjectManualProgramDescriptor }

constructor TProjectManualProgramDescriptor.Create;
begin
  inherited Create;
  VisibleInNewDialog:=false;
  Name:=ProjDescNameCustomProgram;
  Group:=ProjDescGroupName; //Ultibo
  Flags:=Flags-[pfMainUnitHasUsesSectionForAllUnits,
                pfMainUnitHasCreateFormStatements,
                pfMainUnitHasTitleStatement,
                pfMainUnitHasScaledStatement]
              +[pfUseDefaultCompilerOptions];
  FAddMainSource:=true;
end;

function TProjectManualProgramDescriptor.GetLocalizedName: string;
begin
  Result:=lisCustomProgram;
end;

function TProjectManualProgramDescriptor.GetLocalizedGroup: string; //Ultibo
begin
  Result:=dlgProject;
end;

function TProjectManualProgramDescriptor.GetLocalizedDescription: string;
begin
  Result:=lisCustomProgramProgramDescriptor;
end;

function TProjectManualProgramDescriptor.InitProject(AProject: TLazProject): TModalResult;
var
  NewSource: String;
  MainFile: TLazProjectFile;
begin
  Result:=inherited InitProject(AProject);

  if AddMainSource then begin
    MainFile:=AProject.CreateProjectFile('project1.pas');
    MainFile.IsPartOfProject:=true;
    AProject.AddFile(MainFile,false);
    AProject.MainFileID:=0;

    // create program source
    NewSource:='program Project1;'+LineEnding
      +LineEnding
      +'{$mode objfpc}{$H+}'+LineEnding
      +LineEnding
      +'uses'+LineEnding
      +'  Classes, SysUtils'+LineEnding
      +'  { you can add units after this };'+LineEnding
      +LineEnding
      +'begin'+LineEnding
      +'end.'+LineEnding
      +LineEnding;
    AProject.MainFile.SetSourceText(NewSource,true);
    AProject.LazCompilerOptions.Win32GraphicApp:=false;
  end;
end;

function TProjectManualProgramDescriptor.CreateStartFiles(AProject: TLazProject
  ): TModalResult;
begin
  if AProject.MainFile<>nil then
    Result:=LazarusIDE.DoOpenEditorFile(AProject.MainFile.Filename,-1,-1,
                                        [ofProjectLoading,ofRegularFile])
  else
    Result:=mrCancel;
end;

{ TProjectEmptyProgramDescriptor }

constructor TProjectEmptyProgramDescriptor.Create;
begin
  inherited Create;
  FAddMainSource:=false;
end;

{ TProjectConsoleApplicationDescriptor }

constructor TProjectConsoleApplicationDescriptor.Create;
begin
  inherited Create;
  Name:=ProjDescNameConsoleApplication;
  Group:=ProjDescGroupName; //Ultibo
  Flags:=Flags-[pfMainUnitHasCreateFormStatements,pfMainUnitHasTitleStatement,pfMainUnitHasScaledStatement]
              +[pfUseDefaultCompilerOptions];
end;

function TProjectConsoleApplicationDescriptor.GetLocalizedName: string;
begin
  Result:=lisConsoleApplication;
end;

function TProjectConsoleApplicationDescriptor.GetLocalizedGroup: string; //Ultibo
begin
  Result:=dlgProject;
end;

function TProjectConsoleApplicationDescriptor.GetLocalizedDescription: string;
begin
  Result:=lisConsoleApplicationProgramDescriptor;
end;

function TProjectConsoleApplicationDescriptor.InitProject(AProject: TLazProject
  ): TModalResult;
var
  NewSource: TStringList;
  MainFile: TLazProjectFile;
  C, T : String;
  CC,CD,CU,CS, CO : Boolean;

begin
  Result:=inherited InitProject(AProject);
  If Result<>mrOk then
    Exit;
  With TCustomApplicationOptionsForm.Create(Application) do
    try
      Result:=ShowModal;
      If Result<>mrOk then
        Exit;
      C:=Trim(AppClassName);
      T:=StringReplace(Title,'''','''''',[rfReplaceAll]);
      CC:=CodeConstructor;
      CD:=CodeDestructor;
      CU:=CodeUsage;
      CS:=CodeStopOnError;
      CO:=CodeCheckOptions;
    finally
      Free;
    end;
  MainFile:=AProject.CreateProjectFile('project1.lpr');
  MainFile.IsPartOfProject:=true;
  AProject.AddFile(MainFile,false);
  AProject.MainFileID:=0;

  AProject.LazCompilerOptions.UnitOutputDirectory:='lib'+PathDelim+'$(TargetCPU)-$(TargetOS)';
  AProject.LazCompilerOptions.TargetFilename:='project1';
  AProject.LazCompilerOptions.Win32GraphicApp:=false;

  // create program source
  NewSource:=TStringList.Create;
  NewSource.Add('program Project1;');
  NewSource.Add('');
  NewSource.Add('{$mode objfpc}{$H+}');
  NewSource.Add('');
  NewSource.Add('uses');
  NewSource.Add('  {$IFDEF UNIX}');
  NewSource.Add('  cthreads,');
  NewSource.Add('  {$ENDIF}');
  NewSource.Add('  Classes, SysUtils, CustApp');
  NewSource.Add('  { you can add units after this };');
  NewSource.Add('');
  NewSource.Add('type');
  NewSource.Add('');
  NewSource.Add('  { '+C+' }');
  NewSource.Add('');
  NewSource.Add('  '+C+' = class(TCustomApplication)');
  NewSource.Add('  protected');
  NewSource.Add('    procedure DoRun; override;');
  NewSource.Add('  public');
  If CC or CS then
    NewSource.Add('    constructor Create(TheOwner: TComponent); override;');
  if CD then
    NewSource.Add('    destructor Destroy; override;');
  if CU then
    NewSource.Add('    procedure WriteHelp; virtual;');
  NewSource.Add('  end;');
  NewSource.Add('');
  NewSource.Add('{ '+C+' }');
  NewSource.Add('');
  NewSource.Add('procedure '+C+'.DoRun;');
  NewSource.Add('var');
  NewSource.Add('  ErrorMsg: String;');
  NewSource.Add('begin');
  if CO then
    begin
    NewSource.Add('  // quick check parameters');
    NewSource.Add('  ErrorMsg:=CheckOptions(''h'',''help'');');
    NewSource.Add('  if ErrorMsg<>'''' then begin');
    NewSource.Add('    ShowException(Exception.Create(ErrorMsg));');
    NewSource.Add('    Terminate;');
    NewSource.Add('    Exit;');
    NewSource.Add('  end;');
    NewSource.Add('');
    end;
  If CU then
    begin
    NewSource.Add('  // parse parameters');
    NewSource.Add('  if HasOption(''h'',''help'') then begin');
    NewSource.Add('    WriteHelp;');
    NewSource.Add('    Terminate;');
    NewSource.Add('    Exit;');
    NewSource.Add('  end;');
    end;
  NewSource.Add('');
  NewSource.Add('  { add your program here }');
  NewSource.Add('');
  NewSource.Add('  // stop program loop');
  NewSource.Add('  Terminate;');
  NewSource.Add('end;');
  NewSource.Add('');
  If CC or CS then
    begin
    NewSource.Add('constructor '+C+'.Create(TheOwner: TComponent);');
    NewSource.Add('begin');
    NewSource.Add('  inherited Create(TheOwner);');
    If CS then
    NewSource.Add('  StopOnException:=True;');
    NewSource.Add('end;');
    NewSource.Add('');
    end;
  If CD then
    begin
    NewSource.Add('destructor '+C+'.Destroy;');
    NewSource.Add('begin');
    NewSource.Add('  inherited Destroy;');
    NewSource.Add('end;');
    NewSource.Add('');
    end;
  If CU then
    begin
    NewSource.Add('procedure '+C+'.WriteHelp;');
    NewSource.Add('begin');
    NewSource.Add('  { add your help code here }');
    NewSource.Add('  writeln(''Usage: '',ExeName,'' -h'');');
    NewSource.Add('end;');
    NewSource.Add('');
    end;
  NewSource.Add('var');
  NewSource.Add('  Application: '+C+';');
  NewSource.Add('begin');
  NewSource.Add('  Application:='+C+'.Create(nil);');
  If (T<>'') then
    begin
    AProject.Flags:=AProject.Flags+[pfMainUnitHasTitleStatement];
    AProject.Title:=T;
    NewSource.Add('  Application.Title:='''+T+''';');
    end;
  NewSource.Add('  Application.Run;');
  NewSource.Add('  Application.Free;');
  NewSource.Add('end.');
  NewSource.Add('');
  AProject.MainFile.SetSourceText(NewSource.Text,true);
  NewSource.Free;
end;

function TProjectConsoleApplicationDescriptor.CreateStartFiles(
  AProject: TLazProject): TModalResult;
begin
  Result:=LazarusIDE.DoOpenEditorFile(AProject.MainFile.Filename,-1,-1,
                                      [ofProjectLoading,ofRegularFile]);
end;

{ TProjectLibraryDescriptor }

constructor TProjectLibraryDescriptor.Create;
begin
  inherited Create;
  Name:=ProjDescNameLibrary;
  Group:=ProjDescGroupName; //Ultibo
  Flags:=Flags-[pfMainUnitHasCreateFormStatements,pfMainUnitHasTitleStatement,pfMainUnitHasScaledStatement]
              +[pfUseDefaultCompilerOptions];
end;

function TProjectLibraryDescriptor.GetLocalizedName: string;
begin
  Result:=lisPckOptsLibrary;
end;

function TProjectLibraryDescriptor.GetLocalizedGroup: string; //Ultibo
begin
  Result:=dlgProject;
end;

function TProjectLibraryDescriptor.GetLocalizedDescription: string;
begin
  Result:=lisLibraryProgramDescriptor;
end;

function TProjectLibraryDescriptor.InitProject(AProject: TLazProject): TModalResult;
var
  NewSource: String;
  MainFile: TLazProjectFile;
begin
  Result:=inherited InitProject(AProject);

  MainFile:=AProject.CreateProjectFile('project1.lpr');
  MainFile.IsPartOfProject:=true;
  AProject.AddFile(MainFile,false);
  AProject.MainFileID:=0;
  AProject.LazCompilerOptions.ExecutableType:=cetLibrary;

  // create program source
  NewSource:='library Project1;'+LineEnding
    +LineEnding
    +'{$mode objfpc}{$H+}'+LineEnding
    +LineEnding
    +'uses'+LineEnding
    +'  Classes'+LineEnding
    +'  { you can add units after this };'+LineEnding
    +LineEnding
    +'begin'+LineEnding
    +'end.'+LineEnding
    +LineEnding;
  AProject.MainFile.SetSourceText(NewSource,true);

  AProject.LazCompilerOptions.UnitOutputDirectory:='lib'+PathDelim+'$(TargetCPU)-$(TargetOS)';
  AProject.LazCompilerOptions.TargetFilename:='project1';
  AProject.LazCompilerOptions.Win32GraphicApp:=false;
  AProject.LazCompilerOptions.RelocatableUnit:=true;
end;

function TProjectLibraryDescriptor.CreateStartFiles(AProject: TLazProject): TModalResult;
begin
  Result:=LazarusIDE.DoOpenEditorFile(AProject.MainFile.Filename,-1,-1,
                                      [ofProjectLoading,ofRegularFile]);
end;

end.

