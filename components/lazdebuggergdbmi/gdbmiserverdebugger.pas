{              ----------------------------------------------
                GDBMiServerDebugger.pp  -  Debugger class for gdbserver
               ----------------------------------------------

 This unit contains the debugger class for the GDB/MI debugger through SSH.

 ***************************************************************************
 *                                                                         *
 *   This source is free software; you can redistribute it and/or modify   *
 *   it under the terms of the GNU General Public License as published by  *
 *   the Free Software Foundation; either version 2 of the License, or     *
 *   (at your option) any later version.                                   *
 *                                                                         *
 *   This code is distributed in the hope that it will be useful, but      *
 *   WITHOUT ANY WARRANTY; without even the implied warranty of            *
 *   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU     *
 *   General Public License for more details.                              *
 *                                                                         *
 *   A copy of the GNU General Public License is available on the World    *
 *   Wide Web at <http://www.gnu.org/copyleft/gpl.html>. You can also      *
 *   obtain it by writing to the Free Software Foundation,                 *
 *   Inc., 51 Franklin Street - Fifth Floor, Boston, MA 02110-1335, USA.   *
 *                                                                         *
 ***************************************************************************
}
unit GDBMIServerDebugger;

{$mode objfpc}
{$H+}

interface

uses
  Classes, sysutils, UTF8Process, Process, LazFileUtils, MacroIntf,
  // DebuggerIntf
  DbgIntfDebuggerBase,
  // CmdLineDebuggerBase
  DebuggerPropertiesBase,
  // LazDebuggerGdbmi
  GDBMIDebugger, GDBMIMiscClasses, GdbmiStringConstants;
  
type

  { TGDBMIServerDebugger }

  TGDBMIServerDebugger = class(TGDBMIDebuggerBase)
  private
  protected
    function CreateCommandInit: TGDBMIDebuggerCommandInitDebugger; override;
    function CreateCommandStartDebugging(AContinueCommand: TGDBMIDebuggerCommand): TGDBMIDebuggerCommandStartDebugging; override;
    procedure InterruptTarget; override;
    procedure ProcessLineWhileRunning(const ALine: String; AnInLogWarning: boolean;
      var AHandled, AForceStop: Boolean; var AStoppedParams: String;
      var AResult: TGDBMIExecResult); override;
    procedure StopInitProc;
  public
    InitProc: TProcessUTF8;
    destructor Destroy; override;
    function NeedReset: Boolean; override;
    class function CreateProperties: TDebuggerProperties; override;  // Creates debuggerproperties
    class function Caption: String; override;
    class function RequiresLocalExecutable: Boolean; override;
    procedure Done; override;         // Kills external debugger
  end;

  TInitExecMode = (
    ieRun,            // run and forget
    ieRunCloseOnStop  // run, and keep the process until the debugger is stopped
                      // when the debugger is stopped, terminate the process, if it's still running
    // todo: to be implemented!
    //ieRunWaitToExit   // run and wait until the process finishes, before letting the debugger run "target remote"
  );

  TDebugger_Target_Mode = (
    dtTargetRemote,
    dtTargetExtendedRemote
  );

  { TGDBMIServerGdbEventProperties }

  TGDBMIServerGdbEventProperties = class(TGDBMIDebuggerGdbEventPropertiesBase)
  private
    FAfterConnect: TXmlConfStringList;
    procedure SetAfterConnect(AValue: TXmlConfStringList);
  public
    constructor Create; override;
    destructor Destroy; override;
    procedure Assign(Source: TPersistent); override;
  published
    property AfterConnect: TXmlConfStringList read FAfterConnect write SetAfterConnect;
    property AfterInit;
  end;

  { TGDBMIServerDebuggerProperties }

  TGDBMIServerDebuggerProperties = class(TGDBMIDebuggerPropertiesBase)
  private
    FArchitecture: string;
    FDebugger_Remote_Hostname: string;
    FDebugger_Remote_Port: string;
    FDebugger_Remote_DownloadExe: boolean;
    FRemoteTimeout: integer;
    FSkipSettingLocalExeName: Boolean;

    FInitExec_RemoteTarget: string;
    FInitExec_Mode: TInitExecMode;
    FDebugger_Target_Mode : TDebugger_Target_Mode;
    function GetEventProperties: TGDBMIServerGdbEventProperties;
    procedure SetEventProperties(AValue: TGDBMIServerGdbEventProperties);
  protected
    procedure CreateEventProperties; override;
  public
    constructor Create; override;
    procedure Assign(Source: TPersistent); override;
  published
    property Debugger_Remote_Hostname: String read FDebugger_Remote_Hostname write FDebugger_Remote_Hostname;
    property Debugger_Remote_Port: String read FDebugger_Remote_Port write FDebugger_Remote_Port;
    property Debugger_Remote_DownloadExe: boolean read FDebugger_Remote_DownloadExe write FDebugger_Remote_DownloadExe;
    property Debugger_Target_Mode: TDebugger_Target_Mode read FDebugger_Target_Mode write FDebugger_Target_Mode default dtTargetRemote;
    property RemoteTimeout: integer read FRemoteTimeout write FRemoteTimeout default -1;
    property Architecture: string read FArchitecture write FArchitecture;
    property SkipSettingLocalExeName: Boolean read FSkipSettingLocalExeName write FSkipSettingLocalExeName default False;
    property InitExec_RemoteTarget: string read FInitExec_RemoteTarget write FInitExec_RemoteTarget;
    property InitExec_Mode: TInitExecMode read FInitExec_Mode write FInitExec_Mode default ieRun;
  published
    property Debugger_Startup_Options;
    {$IFDEF UNIX}
    property ConsoleTty;
    {$ENDIF}
    property MaxDisplayLengthForString;
    property MaxDisplayLengthForStaticArray;
    property MaxLocalsLengthForStaticArray;
    property TimeoutForEval;
    property WarnOnTimeOut;
    property WarnOnInternalError;
    property EncodeCurrentDirPath;
    property EncodeExeFileName;
    property EncodingForEnvironment;
    property EncodingForExeArgs;
    property EncodingForExeFileName;
    property EncodingForCurrentDirPath;
    property InternalStartBreak;
    property UseNoneMiRunCommands;
    property DisableLoadSymbolsForLibraries;
    property DisableForcedBreakpoint;
    //property WarnOnSetBreakpointError;
    property CaseSensitivity;
    property GdbValueMemLimit;
    property GdbLocalsValueMemLimit;
    property AssemblerStyle;
    property DisableStartupShell;
    property FixStackFrameForFpcAssert;
    property FixIncorrectStepOver;
    property InternalExceptionBreakPoints;
    property InternalExceptionBrkSetMethod;
    property EventProperties: TGDBMIServerGdbEventProperties read GetEventProperties write SetEventProperties;
  end;

procedure Register;

implementation

type

  { TGDBMIServerDebuggerCommandInitDebugger }

  TGDBMIServerDebuggerCommandInitDebugger = class(TGDBMIDebuggerCommandInitDebugger)
  protected
    function  DoExecute: Boolean; override;
  end;

  { TGDBMIServerDebuggerCommandStartDebugging }

  TGDBMIServerDebuggerCommandStartDebugging = class(TGDBMIDebuggerCommandStartDebugging)
  protected
    function GdbRunCommand: TGDBMIExecCommandType; override;
    procedure DetectTargetPid(InAttach: Boolean = False); override;
    function  DoTargetDownload: boolean; override;
    function DoChangeFilename: Boolean; override;
  end;

{ TGDBMIServerGdbEventProperties }

procedure TGDBMIServerGdbEventProperties.SetAfterConnect(
  AValue: TXmlConfStringList);
begin
  FAfterConnect.Assign(AValue);
end;

procedure TGDBMIServerGdbEventProperties.Assign(Source: TPersistent);
var
  aSource: TGDBMIServerGdbEventProperties;
begin
  inherited Assign(Source);
  if Source is TGDBMIServerGdbEventProperties then
  begin
    aSource := TGDBMIServerGdbEventProperties(Source);
    FAfterConnect.Assign(aSource.FAfterConnect);
  end;
end;

constructor TGDBMIServerGdbEventProperties.Create;
begin
  FAfterConnect := TXmlConfStringList.Create;
  inherited Create;
end;

destructor TGDBMIServerGdbEventProperties.Destroy;
begin
  FAfterConnect.Free;
  inherited Destroy;
end;

{ TGDBMIServerDebuggerCommandStartDebugging }

function TGDBMIServerDebuggerCommandStartDebugging.GdbRunCommand: TGDBMIExecCommandType;
begin
  Result := ectContinue;
end;

procedure TGDBMIServerDebuggerCommandStartDebugging.DetectTargetPid(InAttach: Boolean);
begin
  // do nothing // prevent dsError in inherited
end;

function TGDBMIServerDebuggerCommandStartDebugging.DoTargetDownload: boolean;
begin
  Result := True;
  if TGDBMIServerDebuggerProperties(DebuggerProperties).FDebugger_Remote_DownloadExe then
  begin
    // Called after -file-exec-and-symbols, so gdb knows what file to download
    // If call sequence is different, then supply binary file name below as parameter
    Result := ExecuteCommand('-target-download', [], [cfCheckError]);
    Result := Result and (DebuggerState <> dsError);
  end;
end;

function TGDBMIServerDebuggerCommandStartDebugging.DoChangeFilename: Boolean;
begin
  Result := True;
  if not TGDBMIServerDebuggerProperties(DebuggerProperties).SkipSettingLocalExeName then
    Result := inherited DoChangeFilename;
end;

{ TGDBMIServerDebuggerCommandInitDebugger }

function TGDBMIServerDebuggerCommandInitDebugger.DoExecute: Boolean;
var
  R: TGDBMIExecResult;
  t: Integer;
  s: String;
  ip     : TProcessUTF8;
  ipsucc : Boolean;
  ipkeep : Boolean;
  iperr  : string;
  srv    : TGDBMIServerDebugger;
begin
  Result := inherited DoExecute;
  if (not FSuccess) then exit;

  if not TGDBMIDebuggerBase(FTheDebugger).AsyncModeEnabled then begin
    SetDebuggerErrorState(GDBMiSNoAsyncMode);
    FSuccess := False;
    exit;
  end;

  s := Trim(TGDBMIServerDebuggerProperties(DebuggerProperties).InitExec_RemoteTarget);
  IDEMacros.SubstituteMacros(s);

  if s <> '' then begin
    iperr := '';
    ip := TProcessUTF8.Create(nil);

    SplitCmdLineParams(s, ip.Parameters);
    ip.Executable := ip.Parameters[0];
    ip.Parameters.Delete(0);

    ip.Options := [poNewConsole,poNewProcessGroup];
    try
      ip.Execute;
      {if TGDBMIServerDebuggerProperties(DebuggerProperties).InitExec_Mode = ieRunWaitToExit then
      begin
        ip.WaitOnExit;
        iperr := Format(GDBMiSFailedInitProcWaitOnExit, [ip.ExitStatus, ip.ExitCode]);
        ipkeep := false;
      end else}
        ipkeep := TGDBMIServerDebuggerProperties(DebuggerProperties).InitExec_Mode = ieRunCloseOnStop;
      ipsucc := true;
    except
      on e: exception do begin
        iperr := e.Message;
        ipkeep := false;
        ipsucc := false;
      end;
    end;

    if not ipsucc then begin
      ip.Free;
      SetDebuggerErrorState(GDBMiSFailedInitProc, iperr);
      FSuccess := False;
      exit;
    end;

    if ipkeep then begin
      srv := TGDBMIServerDebugger(FTheDebugger);
      srv.StopInitProc;
      srv.InitProc := ip
    end else
      ip.Free;

  end;

  s := TGDBMIServerDebuggerProperties(DebuggerProperties).Architecture;
  if s <> '' then
    ExecuteCommand(Format('set architecture %s', [s]), R);

  t := TGDBMIServerDebuggerProperties(DebuggerProperties).RemoteTimeout;
  if t >= 0 then
    ExecuteCommand(Format('set remotetimeout %d', [t]), R);

  // TODO: Maybe should be done in CommandStart, But Filename, and Environment will be done before Start
  s := '';
  if TGDBMIServerDebuggerProperties(DebuggerProperties).Debugger_Target_Mode = dtTargetExtendedRemote then
    s := 'extended-';
  if TGDBMIServerDebuggerProperties(DebuggerProperties).Debugger_Remote_Port = '' then
    FSuccess := ExecuteCommand(Format('target %sremote %s',
                               [s, TGDBMIServerDebuggerProperties(DebuggerProperties).FDebugger_Remote_Hostname
                                ]),
                               R)
  else
    FSuccess := ExecuteCommand(Format('target %sremote %s:%s',
                               [s, TGDBMIServerDebuggerProperties(DebuggerProperties).FDebugger_Remote_Hostname,
                                TGDBMIServerDebuggerProperties(DebuggerProperties).Debugger_Remote_Port ]),
                               R);

  FSuccess := FSuccess and (r.State <> dsError);

  if (FSuccess = true) then
    ExecuteUserCommands(TGDBMIServerDebuggerProperties(DebuggerProperties).EventProperties.AfterConnect);

end;


{ TGDBMIServerDebuggerProperties }

function TGDBMIServerDebuggerProperties.GetEventProperties: TGDBMIServerGdbEventProperties;
begin
  Result := TGDBMIServerGdbEventProperties(InternalEventProperties);
end;

procedure TGDBMIServerDebuggerProperties.SetEventProperties(
  AValue: TGDBMIServerGdbEventProperties);
begin
  InternalEventProperties.Assign(AValue);
end;

procedure TGDBMIServerDebuggerProperties.CreateEventProperties;
begin
  InternalEventProperties := TGDBMIServerGdbEventProperties.Create;
end;

constructor TGDBMIServerDebuggerProperties.Create;
begin
  inherited Create;
  FDebugger_Remote_Hostname:= '';
  FDebugger_Remote_Port:= '2345';
  FDebugger_Remote_DownloadExe := False;
  FDebugger_Target_Mode := dtTargetRemote;
  FRemoteTimeout := -1;
  FArchitecture := '';
  FSkipSettingLocalExeName := False;
  UseAsyncCommandMode := True;
end;

procedure TGDBMIServerDebuggerProperties.Assign(Source: TPersistent);
begin
  inherited Assign(Source);
  if Source is TGDBMIServerDebuggerProperties then begin
    FDebugger_Remote_Hostname := TGDBMIServerDebuggerProperties(Source).FDebugger_Remote_Hostname;
    FDebugger_Remote_Port := TGDBMIServerDebuggerProperties(Source).FDebugger_Remote_Port;
    FDebugger_Remote_DownloadExe := TGDBMIServerDebuggerProperties(Source).FDebugger_Remote_DownloadExe;
    FDebugger_Target_Mode := TGDBMIServerDebuggerProperties(Source).FDebugger_Target_Mode;
    FRemoteTimeout := TGDBMIServerDebuggerProperties(Source).FRemoteTimeout;
    FArchitecture := TGDBMIServerDebuggerProperties(Source).FArchitecture;
    FSkipSettingLocalExeName := TGDBMIServerDebuggerProperties(Source).FSkipSettingLocalExeName;
    UseAsyncCommandMode := True;
    FInitExec_RemoteTarget := TGDBMIServerDebuggerProperties(Source).FInitExec_RemoteTarget;
    FInitExec_Mode := TGDBMIServerDebuggerProperties(Source).FInitExec_Mode;
  end;
end;


{ TGDBMIServerDebugger }

class function TGDBMIServerDebugger.Caption: String;
begin
  Result := 'GNU remote debugger (gdbserver)';
end;

function TGDBMIServerDebugger.CreateCommandInit: TGDBMIDebuggerCommandInitDebugger;
begin
  Result := TGDBMIServerDebuggerCommandInitDebugger.Create(Self);
end;

function TGDBMIServerDebugger.CreateCommandStartDebugging(
  AContinueCommand: TGDBMIDebuggerCommand): TGDBMIDebuggerCommandStartDebugging;
begin
  Result:= TGDBMIServerDebuggerCommandStartDebugging.Create(Self, AContinueCommand);
end;

procedure TGDBMIServerDebugger.InterruptTarget;
begin
  if not( CurrentCmdIsAsync and (CurrentCommand <> nil) ) then begin
    exit;
  end;

  inherited InterruptTarget;
end;

procedure TGDBMIServerDebugger.ProcessLineWhileRunning(const ALine: String;
  AnInLogWarning: boolean; var AHandled, AForceStop: Boolean;
  var AStoppedParams: String; var AResult: TGDBMIExecResult);
const
  LogDisconnect = 'remote connection closed';
var
  i: Integer;
begin
  inherited ProcessLineWhileRunning(ALine, AnInLogWarning, AHandled, AForceStop,
    AStoppedParams, AResult);

  // If remote connection terminated then this debugging session is over
  i := 1;
  if (ALine[1] = '&') and  (ALine[2] = '"') then
    i := 3;
  if (not AnInLogWarning)
  and (LowerCase(Copy(ALine, i, Length(LogDisconnect))) = LogDisconnect) then begin
    AHandled := True;
    AForceStop := True;
    AStoppedParams := '';
    SetState(dsStop);
  end;
end;

procedure TGDBMIServerDebugger.StopInitProc;
begin
  if not Assigned(InitProc) then Exit;
  if InitProc.Active then InitProc.Terminate(0);
  InitProc.Free;
  InitProc:=nil;
end;

destructor TGDBMIServerDebugger.Destroy;
begin
  StopInitProc;
  inherited Destroy;
end;

function TGDBMIServerDebugger.NeedReset: Boolean;
begin
  Result := True;
end;

class function TGDBMIServerDebugger.CreateProperties: TDebuggerProperties;
begin
  Result := TGDBMIServerDebuggerProperties.Create;
end;

class function TGDBMIServerDebugger.RequiresLocalExecutable: Boolean;
begin
  Result := False;
end;

procedure TGDBMIServerDebugger.Done;
begin
  inherited Done;
  StopInitProc;
end;

procedure Register;
begin
  RegisterDebugger(TGDBMIServerDebugger);
end;

end.


