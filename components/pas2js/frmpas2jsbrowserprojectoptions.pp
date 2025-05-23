unit frmpas2jsbrowserprojectoptions;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, StdCtrls, ButtonPanel,
  Spin, strpas2jsdesign;

const
  WBBoolCreateHTML = 0;
  WBBoolMainHTML = 1;
  WBBoolRunOnReady = 2;
  WBBoolShowUncaughtExceptions = 3;
  WBBoolUseBrowserApp = 4;
  WBBoolUseWASI = 5;
  WBBoolUseBrowserConsole = 6;
  WBBoolUseModule = 7;
  WBBoolRunLocation = 8;
  WBBoolRunServerAtPort = 9;
  WBBoolRunBrowserWithURL = 10;
  WBBoolRunDefault = 11;
  WBBoolEnableThreading = 12;

type

  { TWebBrowserProjectOptionsForm }

  TWebBrowserProjectOptionsForm = class(TForm)
    BPHelpOptions: TButtonPanel;
    CBCreateHTML: TCheckBox;
    CBMaintainPage: TCheckBox;
    CBRunLocationOnSWS: TComboBox;
    CBRunOnReady: TCheckBox;
    CBRunServerURL: TComboBox;
    CBShowUncaughtExceptions: TCheckBox;
    CBUseBrowserApp: TCheckBox;
    CBUseBrowserConsole: TCheckBox;
    CBUseModule: TCheckBox;
    CBUseWASI: TCheckBox;
    CBEnableThreading: TCheckBox;
    edtWasmProgram: TEdit;
    RBRunLocationOnSWS: TRadioButton;
    RBRunBrowserWithURL: TRadioButton;
    RBRunDefault: TRadioButton;
    RBRunServerAt: TRadioButton;
    RunGroupBox: TGroupBox;
    SERunPort: TSpinEdit;
    procedure CBCreateHTMLChange(Sender: TObject);
    procedure CBUseBrowserAppChange(Sender: TObject);
    procedure CBUseHTTPServerChange(Sender: TObject);
    procedure CBEnableThreadingChange(Sender: TObject);
    procedure CBUseWASIChange(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure RBRunLocationOnSWSChange(Sender: TObject);
    procedure RBRunDefaultChange(Sender: TObject);
    procedure RBRunServerAtChange(Sender: TObject);
    procedure RBRunBrowserWithURLChange(Sender: TObject);
  private
    procedure CheckWasiControls;
    function GetB(AIndex: Integer): Boolean;
    function GetLocation: string;
    function GetServerPort: Word;
    function GetURL: String;
    function GetWasmProgramURL: String;
    procedure SetB(AIndex: Integer; AValue: Boolean);
    procedure SetLocation(const AValue: string);
    procedure SetServerPort(AValue: Word);
    procedure SetURL(AValue: String);
    procedure SetWasmProgramURL(AValue: String);
    procedure UpdateHTMLControls;
    procedure UpdateBrowserAppControls;
    procedure UpdateRunControls;
  public
    procedure HideWASM; virtual;
    procedure HideModule; virtual;
    procedure HideRunOnReady; virtual;
    procedure HideUseBrowserApp; virtual;
    procedure HideRunHTTPServer; virtual;
    procedure HideRunLocation; virtual;

    property CreateHTML : Boolean Index WBBoolCreateHTML read GetB Write SetB;
    property MaintainHTML : Boolean Index WBBoolMainHTML read GetB Write SetB;
    property UseRunOnReady : Boolean Index WBBoolRunOnReady read GetB Write SetB;
    property ShowUncaughtExceptions : Boolean Index WBBoolShowUncaughtExceptions read GetB Write SetB;

    property UseBrowserApp : Boolean Index WBBoolUseBrowserApp read GetB Write SetB;
    property UseWASI : Boolean Index WBBoolUseWASI read GetB Write SetB;
    Property EnableThreading : Boolean Index WBBoolEnableThreading Read GetB Write SetB;
    property WasmProgramURL : String Read GetWasmProgramURL Write SetWasmProgramURL;

    property UseBrowserConsole : Boolean Index WBBoolUseBrowserConsole read GetB Write SetB;
    property UseModule : Boolean Index WBBoolUseModule read GetB Write SetB;

    property RunLocation : Boolean Index WBBoolRunLocation read GetB Write SetB;
    property Location : string Read GetLocation Write SetLocation;
    property RunServerAtPort : Boolean Index WBBoolRunServerAtPort read GetB Write SetB;
    property ServerPort : Word Read GetServerPort Write SetServerPort;
    property RunBrowserWithURL : Boolean Index WBBoolRunBrowserWithURL read GetB Write SetB;
    property URL : String Read GetURL Write SetURL;
    property RunDefault : Boolean Index WBBoolRunDefault read GetB Write SetB;
  end;

var
  WebBrowserProjectOptionsForm: TWebBrowserProjectOptionsForm;

implementation

{$R *.lfm}

{ TWebBrowserProjectOptionsForm }

procedure TWebBrowserProjectOptionsForm.CBCreateHTMLChange(Sender: TObject);

  Procedure DOCB(CB : TCheckbox);

  begin
    CB.Enabled:=CBCreateHTML.Checked;
    if not CB.Enabled then
      CB.Checked:=False;
  end;

begin
  UpdateHTMLControls;
  DoCB(CBMaintainPage);
  DoCB(CBRunOnReady);
end;

procedure TWebBrowserProjectOptionsForm.CBUseBrowserAppChange(Sender: TObject);
begin
  UpdateBrowserAppControls;
end;

procedure TWebBrowserProjectOptionsForm.CBUseHTTPServerChange(Sender: TObject);
begin

end;

procedure TWebBrowserProjectOptionsForm.CBEnableThreadingChange(Sender: TObject);
begin

end;

procedure TWebBrowserProjectOptionsForm.CBUseWASIChange(Sender: TObject);
begin
  CheckWasiControls;
end;

procedure TWebBrowserProjectOptionsForm.CheckWasiControls;

begin
  edtWasmProgram.Enabled:=UseWASI;
  CBEnableThreading.Enabled:=UseWASI;
  if not CBEnableThreading.Enabled then
    CBEnableThreading.Checked:=False;
end;

procedure TWebBrowserProjectOptionsForm.UpdateBrowserAppControls;

begin
  CBUseWASI.Enabled:=UseBrowserApp;
  if not CBUseWASI.Enabled then
    CBUseWASI.Checked:=False;
  CheckWasiControls;
end;

procedure TWebBrowserProjectOptionsForm.FormCreate(Sender: TObject);
begin
  // localize
  Caption:=pjsdPas2JSBrowserProjectOptions;
  CBCreateHTML.Caption:=pjsdCreateInitialHTMLPage;
  CBMaintainPage.Caption:=pjsdMaintainHTMLPage;
  CBRunOnReady.Caption:=pjsdRunRTLWhenAllPageResourcesAreFullyLoaded;
  CBShowUncaughtExceptions.Caption:=pjsdLetRTLShowUncaughtExceptions;

  CBUseBrowserApp.Caption:=pjsdUseBrowserApplicationObject;
  CBUseWASI.Caption:=pjsdUseWASIApplicationObject;
  CBEnableThreading.Caption:=pjsWasiEnableThreading;
  edtWasmProgram.TextHint:=pjsWasiProgramFileTextHint;

  CBUseBrowserConsole.Caption:=pjsdUseBrowserConsoleUnitToDisplayWritelnOutput;
  CBUseModule.Caption:=pjsCreateAJavascriptModuleInsteadOfAScript;

  RunGroupBox.Caption:=pjsdRun;
  RBRunLocationOnSWS.Caption:=pjsdLocationOnSimpleWebServer;
  RBRunLocationOnSWS.Hint:=pjsdTheSimpleWebServerIsAutomaticallyStartedOnRunTheLo;
  RBRunServerAt.Caption:=pjsdStartHTTPServerOnPort;
  RBRunBrowserWithURL.Caption:=pjsdUseThisURLToStartApplication;
  RBRunBrowserWithURL.Hint:=pjsdUseThisWhenYouStartYourOwnHttpServer;
  RBRunDefault.Caption:=pjsExecuteRunParameters;

  CBCreateHTMLChange(self);
end;

procedure TWebBrowserProjectOptionsForm.RBRunLocationOnSWSChange(
  Sender: TObject);
begin
  UpdateRunControls;
end;

procedure TWebBrowserProjectOptionsForm.RBRunDefaultChange(Sender: TObject);
begin
  UpdateRunControls;
end;

procedure TWebBrowserProjectOptionsForm.RBRunServerAtChange(Sender: TObject);
begin
  UpdateRunControls;
end;

procedure TWebBrowserProjectOptionsForm.RBRunBrowserWithURLChange(Sender: TObject);
begin
  UpdateRunControls;
end;

function TWebBrowserProjectOptionsForm.GetB(AIndex: Integer): Boolean;
begin
  Case Aindex of
    WBBoolCreateHTML : Result:=CBCreateHTML.Checked;
    WBBoolMainHTML : Result:=CBMaintainPage.Checked;
    WBBoolRunOnReady : Result:=CBRunOnReady.Checked;
    WBBoolShowUncaughtExceptions : Result:=CBShowUncaughtExceptions.Checked;
    WBBoolUseBrowserApp : Result:=CBUseBrowserApp.Checked;
    WBBoolUseWASI : Result:=cbUseWASI.Checked;
    WBBoolEnableThreading : Result:=cbEnableThreading.Checked;
    WBBoolUseBrowserConsole : Result:=CBUseBrowserConsole.Checked;
    WBBoolUseModule : Result:=cbUseModule.Checked;
    WBBoolRunLocation : Result:=RBRunLocationOnSWS.Checked;
    WBBoolRunServerAtPort : Result:=RBRunServerAt.Checked;
    WBBoolRunBrowserWithURL : Result:=RBRunBrowserWithURL.Checked;
    WBBoolRunDefault : Result:=RBRunDefault.Checked;
  else
    Result:=False;
  end;
end;

function TWebBrowserProjectOptionsForm.GetLocation: string;
begin
  Result:=CBRunLocationOnSWS.Text;
end;

function TWebBrowserProjectOptionsForm.GetServerPort: Word;
begin
  Result:=SERunPort.Value;
end;

function TWebBrowserProjectOptionsForm.GetURL: String;
begin
  Result:=CBRunServerURL.Text;
end;

function TWebBrowserProjectOptionsForm.GetWasmProgramURL: String;
begin
  Result:=edtWasmProgram.Text;
end;

procedure TWebBrowserProjectOptionsForm.SetB(AIndex: Integer; AValue: Boolean);
begin
  Case Aindex of
  WBBoolCreateHTML : begin CBCreateHTML.Checked:=AValue; UpdateHTMLControls; end;
    WBBoolMainHTML : CBMaintainPage.Checked:=AValue;
    WBBoolRunOnReady : CBRunOnReady.Checked:=AValue;
    WBBoolShowUncaughtExceptions : CBShowUncaughtExceptions.Checked:=AValue;
    WBBoolUseBrowserConsole : CBUseBrowserConsole.Checked:=AValue;
  WBBoolUseBrowserApp : begin CBUseBrowserApp.Checked:=AValue; UpdateBrowserAppControls; end;
  WBBoolUseWASI : begin cbUseWASI.Checked:=AValue; UpdateBrowserAppControls; end;
  WBBoolEnableThreading : cbEnableThreading.Checked;
  WBBoolUseModule : cbUseModule.Checked:=AValue;
  WBBoolRunLocation : begin RBRunLocationOnSWS.Checked:=AValue; UpdateRunControls; end;
  WBBoolRunServerAtPort : begin RBRunServerAt.Checked:=AValue; UpdateRunControls; end;
  WBBoolRunBrowserWithURL : begin RBRunBrowserWithURL.Checked:=AValue; UpdateRunControls; end;
  WBBoolRunDefault : begin RBRunDefault.Checked:=AValue; UpdateRunControls; end;
  end;
end;

procedure TWebBrowserProjectOptionsForm.SetLocation(const AValue: string);
begin
  CBRunLocationOnSWS.Text:=AValue;
end;

procedure TWebBrowserProjectOptionsForm.SetServerPort(AValue: Word);
begin
  SERunPort.Value:=AValue;
end;

procedure TWebBrowserProjectOptionsForm.SetURL(AValue: String);
begin
  CBRunServerURL.Text:=AValue;
end;

procedure TWebBrowserProjectOptionsForm.SetWasmProgramURL(AValue: String);
begin
  edtWasmProgram.Text:=aValue;
end;

procedure TWebBrowserProjectOptionsForm.UpdateHTMLControls;
var
  aEnabled: Boolean;
begin
  aEnabled:=CBCreateHTML.Checked;
  CBMaintainPage.Enabled:=aEnabled;
  CBRunOnReady.Enabled:=aEnabled;
  CBShowUncaughtExceptions.Enabled:=aEnabled;
  CBUseBrowserConsole.Enabled:=aEnabled;
end;

procedure TWebBrowserProjectOptionsForm.UpdateRunControls;
begin
  CBRunLocationOnSWS.Enabled:=RBRunLocationOnSWS.Enabled and RBRunLocationOnSWS.Checked;
  SERunPort.Enabled:=RBRunServerAt.Enabled and RBRunServerAt.Checked;
  CBRunServerURL.Enabled:=RBRunBrowserWithURL.Enabled and RBRunBrowserWithURL.Checked;
end;

procedure TWebBrowserProjectOptionsForm.HideWASM;
begin
  CBUseWASI.Visible:=false;
  edtWasmProgram.Visible:=false;
end;

procedure TWebBrowserProjectOptionsForm.HideModule;
begin
  CBUseModule.Visible:=false;
end;

procedure TWebBrowserProjectOptionsForm.HideRunOnReady;
begin
  CBRunOnReady.Visible:=false;
end;

procedure TWebBrowserProjectOptionsForm.HideUseBrowserApp;
begin
  CBUseBrowserApp.Visible:=false;
end;

procedure TWebBrowserProjectOptionsForm.HideRunHTTPServer;
begin
  RunGroupBox.Visible:=false;
end;

procedure TWebBrowserProjectOptionsForm.HideRunLocation;
begin
  RBRunServerAt.Checked:=true;
  RBRunLocationOnSWS.Visible:=false;
  CBRunLocationOnSWS.Visible:=false;
end;

end.

