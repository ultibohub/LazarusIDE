unit fraquery;

{$mode objfpc}{$H+}
{$modeswitch typehelpers}

interface

uses
  Classes, SysUtils, FileUtil, SynHighlighterSQL, SynEdit, LResources, Forms,
  DB, LCLType, Controls, ComCtrls, StdCtrls, ActnList, Dialogs, ExtCtrls, Menus, StdActns,
  dmImages, fpDatadict, fradata, lazdatadeskstr, sqlscript, sqldb, fpddsqldb, lazddsqlutils, fraparams;

type
   TExecuteMode = (emSingle,emSelection,emScript,emSelectionScript);
   TScriptMode = (smStopNextError,smStopNoErrors,smAbort);
   TBusyMode = (bmIdle,bmSingle,bmScript);

  { TQueryFrame }

  TQueryFrame = class(TFrame)
    ACloseQuery: TAction;
    ACreateCode: TAction;
    aCommit: TAction;
    aCopyAsSQLConst: TAction;
    aCopyAsTStringsAdd: TAction;
    aCleanPascalCode: TAction;
    aPrepareParameters: TAction;
    aRollBack: TAction;
    AExecuteSelectionScript: TAction;
    AExecuteScript: TAction;
    AExecuteSelection: TAction;
    AExecuteSingle: TAction;
    AExport: TAction;
    ASaveSQL: TAction;
    ALoadSQL: TAction;
    ANextQuery: TAction;
    APreviousQuery: TAction;
    AExecute: TAction;
    ALQuery: TActionList;
    aCopy: TEditCopy;
    aCut: TEditCut;
    aPaste: TEditPaste;
    aSelectAll: TEditSelectAll;
    MenuItem1: TMenuItem;
    MenuItem2: TMenuItem;
    MenuItem3: TMenuItem;
    MenuItem4: TMenuItem;
    mnuPrevSQL: TMenuItem;
    mnuNextSQL: TMenuItem;
    mnuSep2: TMenuItem;
    mnuSep: TMenuItem;
    mnuSelectAll: TMenuItem;
    mnuPaste: TMenuItem;
    mnuCopy: TMenuItem;
    mnuCut: TMenuItem;
    MIExecuteSelectionScript: TMenuItem;
    MIExecuteScript: TMenuItem;
    MIExecuteSelection: TMenuItem;
    MIExecuteSingle: TMenuItem;
    ODSQL: TOpenDialog;
    PCResult: TPageControl;
    FMSQL: TSynEdit;
    PMExecute: TPopupMenu;
    pmSynEdit: TPopupMenu;
    SDSQL: TSaveDialog;
    SQuery: TSplitter;
    SQLSyn: TSynSQLSyn;
    MResult: TSynEdit;
    tbPrepareParams: TToolButton;
    TSParams: TTabSheet;
    TBExecute: TToolButton;
    TBSep1: TToolButton;
    TBPrevious: TToolButton;
    TBClose: TToolButton;
    TBNext: TToolButton;
    TBSep2: TToolButton;
    TBLoadSQL: TToolButton;
    TBSaveSQL: TToolButton;
    TBSep3: TToolButton;
    TBExport: TToolButton;
    TBCreateCode: TToolButton;
    btnCommit: TToolButton;
    btnRollback: TToolButton;
    ToolButton5: TToolButton;
    TSResult: TTabSheet;
    TSData: TTabSheet;
    TBQuery: TToolBar;
    procedure aCleanPascalCodeExecute(Sender: TObject);
    procedure aCommitExecute(Sender: TObject);
    procedure aCommitUpdate(Sender: TObject);
    procedure aCopyAsSQLConstExecute(Sender: TObject);
    procedure aCopyAsTStringsAddExecute(Sender: TObject);
    procedure AExecuteExecute(Sender: TObject);
    procedure AExecuteScriptExecute(Sender: TObject);
    procedure AExecuteSelectionExecute(Sender: TObject);
    procedure AExecuteSelectionScriptExecute(Sender: TObject);
    procedure AExecuteSingleExecute(Sender: TObject);
    procedure aPrepareParametersExecute(Sender: TObject);
    procedure aRollBackExecute(Sender: TObject);
    procedure aRollBackUpdate(Sender: TObject);
    procedure CloseQueryClick(Sender: TObject);
    procedure HaveNextQuery(Sender: TObject);
    procedure HavePreviousQuery(Sender: TObject);
    procedure HaveSQLSelection(Sender: TObject);
    procedure LoadQueryClick(Sender: TObject);
    procedure NextQueryClick(Sender: TObject);
    procedure NotBusy(Sender: TObject);
    procedure OnMemoKey(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure PreviousQueryClick(Sender: TObject);
    procedure SaveQueryClick(Sender: TObject);
    procedure ExportDataClick(Sender: TObject);
    procedure CreateCodeClick(Sender: TObject);
    Procedure HaveParamsAvailabe(Sender: TObject);
    Procedure DataShowing(Sender: TObject);
  private
    { private declarations }
    FParamFrame : TfraParams;
    FEngine: TFPDDEngine;
    FQueryHistory : TStrings;
    FCurrentQuery : Integer;
    FBusy : TBusyMode;
    FData : TDataFrame;
    FScript : TEventSQLScript;
    FScriptMode : TScriptMode;
    FErrorCount,
    FStatementCount : Integer;
    FSQLConstName: String;
    FSQLQuoteOptions: TQuoteOptions;
    FAbortScript : Boolean;
    FExecParams : TParams;
    procedure AddToResult(const Msg: String; SetCursorPos : Boolean = false);
    procedure ClearParams;
    procedure ClearResults;
    function CountStatements(const S: String): Integer;
    function DetermineExecuteMode: TExecuteMode;
    // Script events
    procedure DoCommit(Sender: TObject);
    procedure DoDirective(Sender: TObject; Directive, Argument: AnsiString;  var StopExecution: Boolean);
    procedure DoSQLStatement(Sender: TObject; Statement: TStrings; var StopExecution: Boolean);
    // Execute SQL
    procedure DoExecuteQuery(const Qry: TStrings; ACount: Integer);
    function GetTransaction: TSQLTransaction;
    procedure LocalizeFrame;
    function SelectionHint: Boolean;
    procedure SetTableNames;
  public
  Protected
    Function HaveTransaction : Boolean;
    Function HaveParams : Boolean;
    Function TransactionIsActive : Boolean;
    procedure SetEngine(const AValue: TFPDDEngine);
    Function GetDataset: TDataset;
    Procedure CreateControls; virtual;
    Property Transaction : TSQLTransaction Read GetTransaction;
  Public
    Constructor Create(AOwner : TComponent); override;
    Destructor Destroy; override;
    function ExecuteQuery(const Qry: TStrings; ACount: Integer = 0): Boolean;
    procedure ExecuteScript(AScript: String);
    procedure SaveQuery(AFileName: String);
    procedure LoadQuery(AFileName: String);
    Function AddToHistory(Qry : String) : Integer;
    Function NextQuery : Integer;
    Function PreviousQuery : Integer;
    Procedure CloseDataset;
    Procedure FreeDataset;
    Procedure ExportData;
    Procedure CreateCode;
    Procedure ActivatePanel;
    Property Dataset : TDataset Read GetDataset;
    Property Engine : TFPDDEngine Read FEngine Write SetEngine;
    Property QueryHistory : TStrings Read FQueryHistory;
    Property CurrentQuery : Integer Read FCurrentQuery;
    Property Busy : TBusyMode Read FBusy;
    Property SQLQuoteOptions : TQuoteOptions Read FSQLQuoteOptions Write FSQLQuoteOptions;
    Property SQLConstName : String Read FSQLConstName Write FSQLConstName;
    Property ParamFrame : TfraParams Read FParamFrame;
    { public declarations }
  end;

   { TSQLDBHelper }

   TSQLDBHelper = class helper for TSQLDBDDEngine
   private
     function GetConn: TSQLConnection;
     function GetTrans: TSQLTransaction;
   Public
     {$IFDEF VER3_2}
     Procedure ApplyParams(DS : TDataset;Params : TParams);
     Function RunQuery(SQL : String; Params : TParams) : Integer; overload;
     {$ENDIF}
     Property SQLConnection : TSQLConnection Read GetConn;
     Property Transaction : TSQLTransaction Read GetTrans;
   end;

implementation

uses
  Clipbrd, strutils,
  fpdataexporter,
  fpcodegenerator;

{$r *.lfm}

{ TSQLDBHelper }

function TSQLDBHelper.GetConn: TSQLConnection;
begin
  Result:=Connection
end;

function TSQLDBHelper.GetTrans: TSQLTransaction;

Var
  Conn : TSQLConnection;

begin
  Conn:=SQLConnection;
  if Assigned(Conn) then
    Result:=Conn.Transaction
  else
    Result:=Nil;
end;

{$IFDEF VER3_2}
procedure TSQLDBHelper.ApplyParams(DS: TDataset; Params: TParams);
begin
  if Assigned(Params) and (DS is TSQLQuery) then
    TSQLQuery(DS).Params.Assign(Params);
end;

function TSQLDBHelper.RunQuery(SQL: String; Params: TParams): Integer;

Var
  Q : TSQLQuery;

begin
  Q:=CreateSQLQuery(Nil);
  Try
    Q.SQL.Text:=SQL;
    if Assigned(Params) then
      ApplyParams(Q,Params);
    Q.ExecSQL;
    Result:=0;
  Finally
    Q.Free;
  end;
end;
{$ENDIF}

constructor TQueryFrame.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  FQueryHistory:=TStringList.Create;
  FCurrentQuery:=-1;
  CreateControls;
  LocalizeFrame;
end;

destructor TQueryFrame.Destroy;
begin
  FreeAndNil(FQueryHistory);
  inherited Destroy;
end;

procedure TQueryFrame.SetEngine(const AValue: TFPDDEngine);
begin
  if FEngine=AValue then exit;
  If Assigned(Dataset) then
    begin
    CloseDataset;
    FreeDataset;
    end;
  FEngine:=AValue;
  SetTableNames;
  TSParams.TabVisible:=HaveParams;
end;

procedure TQueryFrame.SetTableNames;

begin
  SQLSyn.TableNames.BeginUpdate;
  try
    SQLSyn.TableNames.Clear;
    if (FEngine=Nil) or Not (FEngine.Connected) then
       exit;
    FEngine.GetTableList(SQLSyn.TableNames);
  finally
    SQLSyn.TableNames.EndUpdate;
  end;
end;

function TQueryFrame.HaveTransaction: Boolean;
begin
  Result:=(Dataset is TSQLQuery) and Assigned(TSQLQuery(Dataset).SQLTransaction);
  if not Result then
    if FEngine is TSQLDBDDEngine then
      Result:=Assigned(TSQLDBDDEngine(FEngine).Transaction);
end;

function TQueryFrame.HaveParams: Boolean;
begin
{$ifdef VER3_2}
  Result:=FEngine is TSQLDBDDEngine;
{$ELSE}
  Result:=ecParams in FEngine.EngineCapabilities;
{$endif}
end;

function TQueryFrame.TransactionIsActive: Boolean;
begin
  Result:=HaveTransaction;
  if Result then
    if FEngine is TSQLDBDDEngine then
      Result:=TSQLDBDDEngine(FEngine).Transaction.Active;
end;

procedure TQueryFrame.ExportDataClick(Sender: TObject);
begin
  ExportData;
end;

procedure TQueryFrame.CreateCodeClick(Sender: TObject);
begin
  CreateCode;
end;

function TQueryFrame.GetDataset: TDataset;
begin
  Result:=FData.Dataset;
end;

procedure TQueryFrame.LocalizeFrame;

begin
  // Localize
  AExecute.Caption:=SExecute;
  AExecute.Hint:=SHintExecute;
  APreviousQuery.Caption:=SPrevious;
  APreviousQuery.Hint:=SHintPrevious;
  ANextQuery.Caption:=SNext;
  ANextQuery.Hint:=SHintNext;
  ALoadSQL.Caption:=SLoad;
  ALoadSQL.Hint:=SHintLoad;
  ASaveSQL.Caption:=SSave;
  ASaveSQL.Hint:=SHintSave;
  ACloseQuery.Caption:=SClose;
  ACloseQuery.Hint:=SHintClose;
  AExport.Caption:=SExport;
  AExport.Hint:=SHintExport;
  ACreateCode.Caption:=SCreateCode;
  ACreateCode.Hint:=SHintCreateCode;
  ODSQL.Filter:=SSQLFilters;
  SDSQL.Filter:=SSQLFilters;
  aCommit.Caption:=SCommit;
  aCommit.Hint:=SCommitTransaction;
  aRollback.Caption:=SRollback;
  aRollBack.Hint:=SRollbackransaction;

end;

procedure TQueryFrame.CreateControls;

begin
  FData:=TDataFrame.Create(Self);
  FData.Parent:=TSData;
  FData.Align:=alClient;
  FData.Visible:=True;
  FData.ShowExtraButtons:=False;
  MResult.Lines.Clear;
  MResult.Append(SReadyForSQL);
  FScript:=TEventSQLScript.Create(Self);
  FScript.UseDefines:=True;
  FScript.UseSetTerm:=True;
  FScript.UseCommit:=True;
  FScript.OnSQLStatement:=@DoSQLStatement;
  FScript.OnDirective:=@DoDirective;
  FScript.OnCommit:=@DoCommit;
  PCResult.ActivePage:=TSResult;
  FParamFrame:=TfraParams.Create(Self);
  FParamFrame.Parent:=TSParams;
  FParamFrame.Align:=alClient;
end;

{ ---------------------------------------------------------------------
  Callbacks
  ---------------------------------------------------------------------}

procedure TQueryFrame.OnMemoKey(Sender: TObject; var Key: Word; Shift: TShiftState);
begin
  If (Key=VK_E) and (Shift=[ssCtrl]) then
    begin
    AExecute.Execute;
    Key:=0;
    end;
end;

procedure TQueryFrame.ClearResults;

Var
  DS : TDataset;

begin
  MResult.Clear;
  DS:=Dataset;
  If Assigned(DS) then
    CloseDataset;
end;

function TQueryFrame.CountStatements(const S: String): Integer;

Var
  I : integer;

begin
  Result:=1;
  For I:=2 To Length(S) do
    If S[I-1]=';' then
      inc(Result);
end;

function TQueryFrame.DetermineExecuteMode: TExecuteMode;

begin
  if SelectionHint then
    begin
    Result:=emSelection;
    if CountStatements(Trim(FMSQL.SelText))>1 then
      Result:=emSelectionScript
    end
  else
    begin
    Result:=emSingle;
    if (FMSQL.Lines.Count>300) then
      Result:=emScript
    else
      if CountStatements(Trim(FMSQL.Lines.Text))>1 then
        result:=emScript
    end;
end;

procedure TQueryFrame.DoSQLStatement(Sender: TObject; Statement: TStrings;
  var StopExecution: Boolean);

Var
  RetryStatement : Boolean;
begin
  Application.ProcessMessages;
  StopExecution:=False;
  RetryStatement:=False;
  Inc(FStatementCount);
  Repeat
    If not ExecuteQuery(Statement,FStatementCount) then
      begin
      If not RetryStatement then
        Inc(FErrorCount);
      if (FScriptMode=smStopNextError) then
        Case QuestionDlg(SErrInScript,SErrInScriptChoice,mtWarning,[
            mrYes,SStopOnNextError,
            mrYesToAll,SStopNoError,
            mrAbort,SAbortScript,
            mrRetry,SRetryStatement
          ],0) of
          mrYesToAll : FScriptMode:=smStopNoErrors;
          mrAbort : StopExecution:=True;
          mrRetry : RetryStatement:=True;
        else
          FScriptMode:=smStopNextError;
        end;
      end;
  until StopExecution or Not RetryStatement;
  if FAbortScript then
    StopExecution:=True;
  Application.ProcessMessages;
end;

procedure TQueryFrame.DoCommit(Sender: TObject);
begin
  if not HaveTransaction then
    AddToResult(SErrCommitNotSupported)
  else
    Transaction.Commit;
end;

procedure TQueryFrame.DoDirective(Sender: TObject; Directive, Argument: AnsiString; var StopExecution: Boolean);
begin
  MResult.Append(Format(SErrUnknownDirective,[Directive,Argument]));
  StopExecution:=False;
  // Not yet implemented
end;

procedure TQueryFrame.AExecuteExecute(Sender: TObject);

begin
  ClearResults;
  Case DetermineExecuteMode of
    emSingle          : AExecuteSingle.Execute;
    emSelection       : AExecuteSelection.Execute;
    emScript          : AExecuteScript.Execute;
    emSelectionScript : AExecuteSelectionScript.Execute;
  end;
end;

procedure TQueryFrame.aCommitExecute(Sender: TObject);
begin
  if HaveTransaction then
    Transaction.Commit;
end;

procedure TQueryFrame.aCleanPascalCodeExecute(Sender: TObject);
var
  Src,Dest : TStrings;

begin
  Dest:=nil;
  Src:=TStringList.Create;
  try
    Dest:=TStringList.Create;
    if FMSQL.SelEnd=FMSQL.SelEnd then
      Src.AddStrings(FMSQL.Lines)
    else
      Src.Text:=FMSQL.SelText;
    UnQuoteSQL(Src,Dest);
    if FMSQL.SelEnd=FMSQL.SelEnd then
      FMSQL.Lines:=Dest
    else
      FMSQL.SelText:=Dest.Text
  finally
    Dest.Free;
    Src.Free;
  end;
end;

procedure TQueryFrame.aCommitUpdate(Sender: TObject);

begin
  (Sender as TAction).Enabled:=HaveTransaction and Transaction.Active;
end;

procedure TQueryFrame.aCopyAsSQLConstExecute(Sender: TObject);

var
  Src,Dest : TStrings;

begin
  Dest:=nil;
  Src:=TStringList.Create;
  try
    Dest:=TStringList.Create;
    if FMSQL.SelEnd=FMSQL.SelEnd then
      Src.AddStrings(FMSQL.Lines)
    else
      Src.Text:=FMSQL.SelText;
    QuoteSQL(Src,Dest,SQLQuoteOptions,SQLConstName);
    Clipboard.AsText:=Dest.Text;
  finally
    Dest.Free;
    Src.Free;
  end;
end;



procedure TQueryFrame.aCopyAsTStringsAddExecute(Sender: TObject);
var
  Src,Dest : TStrings;

begin
  Dest:=nil;
  Src:=TStringList.Create;
  try
    Dest:=TStringList.Create;
    if FMSQL.SelEnd=FMSQL.SelEnd then
      Src.AddStrings(FMSQL.Lines)
    else
      Src.Text:=FMSQL.SelText;
    QuoteSQL(Src,Dest,[qoTStringsAdd],SQLConstName);
    Clipboard.AsText:=Dest.Text;
  finally
    Dest.Free;
    Src.Free;
  end;
end;

procedure TQueryFrame.AExecuteScriptExecute(Sender: TObject);
begin
  ClearResults;
  ExecuteScript(Trim(FMSQL.Lines.Text));
end;

procedure TQueryFrame.AExecuteSelectionExecute(Sender: TObject);

Var
  SQL : TStrings;

begin
  ClearResults;
  SQL:=TStringList.Create;
  try
    SQL.Text:=FMSQL.SelText;
    ExecuteQuery(SQL);
  finally
    SQL.Free;
    ClearParams;
  end;
end;

procedure TQueryFrame.AExecuteSelectionScriptExecute(Sender: TObject);
begin
  ClearResults;
  ExecuteScript(Trim(FMSQL.SelText));
  ClearParams;
end;

procedure TQueryFrame.AExecuteSingleExecute(Sender: TObject);
begin
  ClearResults;
  ExecuteQuery(FMSQL.Lines);
  ClearParams;
end;

procedure TQueryFrame.ClearParams;

begin
  FreeAndNil(FExecParams);
  TSParams.TabVisible:=False;
end;

procedure TQueryFrame.aPrepareParametersExecute(Sender: TObject);

begin
//  ShowMessage(ParamFrame.SGParams.Columns[1].PickList.Text);
  if Assigned(FExecParams) then
    begin
    ParamFrame.Params.Clear;
    FreeAndNil(FExecParams);
    PCResult.ActivePage:=TSResult;
    TSParams.TabVisible:=False;
    end
  else
    begin
    FExecParams:=TParams.Create(TParam);
    FExecParams.ParseSQL(FMSQL.Lines.Text,True);
    ParamFrame.Params:=FExecParams;
    TSParams.TabVisible:=True;
    PCResult.ActivePage:=TSParams;
    end;
end;

procedure TQueryFrame.aRollBackExecute(Sender: TObject);
begin
  if HaveTransaction then
    Transaction.RollBack;
end;

procedure TQueryFrame.aRollBackUpdate(Sender: TObject);
begin
  (Sender as TAction).Enabled:=HaveTransaction and Transaction.Active;
end;

procedure TQueryFrame.CloseQueryClick(Sender : TObject);

begin
  CloseDataset;
end;

procedure TQueryFrame.HaveParamsAvailabe(Sender: TObject);

begin
  NotBusy(Sender);
  (Sender as TAction).Enabled:=(Sender as TAction).Enabled and HaveParams;
end;

procedure TQueryFrame.DataShowing(Sender : TObject);

Var
  DS : TDataset;

begin
  DS:=Dataset;
  (Sender as TAction).Enabled:=Assigned(DS) and DS.Active;
end;

procedure TQueryFrame.HaveNextQuery(Sender : TObject);

begin
  (Sender as TAction).Enabled:=(FCurrentQuery<FQueryHistory.Count-1);
end;

procedure TQueryFrame.HavePreviousQuery(Sender : TObject);

begin
  (Sender as TAction).Enabled:=(FCurrentQuery>0);
end;

function TQueryFrame.SelectionHint: Boolean;

Var
  S : String;

begin
  S:=Trim(FMSQL.SelText);
  Result:=WordCount(S,[#10,#13,#9,' '])>1;
end;

procedure TQueryFrame.HaveSQLSelection(Sender: TObject);
begin
  (Sender as TAction).Enabled:=SelectionHint;
end;

procedure TQueryFrame.NextQueryClick(Sender : TObject);

begin
  NextQuery;
end;

procedure TQueryFrame.NotBusy(Sender: TObject);
begin
  (Sender as TAction).Enabled:=FBusy=bmIdle;
end;

procedure TQueryFrame.PreviousQueryClick(Sender : TObject);

begin
  PreviousQuery;
end;

procedure TQueryFrame.LoadQueryClick(Sender : TObject);

begin
  With ODSQL do
    begin
    Options:=[ofFileMustExist];
    If Execute then
      LoadQuery(FileName);
    end;
end;

procedure TQueryFrame.SaveQueryClick(Sender : TObject);

begin
  With SDSQL.Create(Self) do
    begin
    If Execute then
      SaveQuery(FileName);
    end;
end;

{ ---------------------------------------------------------------------
  Actual commands
  ---------------------------------------------------------------------}

procedure TQueryFrame.LoadQuery(AFileName: String);

begin
  FMSQL.Lines.LoadFromFile(AFileName);
end;

function TQueryFrame.AddToHistory(Qry: String): Integer;

Var
  I : Integer;

begin
  I:=FQueryHistory.IndexOf(Qry);
  If (I=-1) then
    FCurrentQuery:=FQueryHistory.Add(Qry)
  else
    begin
    FQueryHistory.Move(I,FQueryHistory.Count-1);
    FCurrentQuery:=FQueryHistory.Count-1;
    end;
  Result:=FCurrentQuery;
end;

function TQueryFrame.NextQuery: Integer;
begin
  If FCurrentQuery<FQueryHistory.Count-1 then
    begin
    Inc(FCurrentQuery);
    FMSQL.Lines.Text:=FQueryHistory[FCurrentQuery];
    end;
  Result:=FCurrentQuery;
end;

function TQueryFrame.PreviousQuery: Integer;
begin
  If (FCurrentQuery>0) then
    begin
    Dec(FCurrentQuery);
    FMSQL.Lines.Text:=FQueryHistory[FCurrentQuery];
    end;
  Result:=FCurrentQuery;
end;


procedure TQueryFrame.SaveQuery(AFileName: String);

begin
  FMSQL.Lines.SaveToFile(AFileName);
end;

procedure TQueryFrame.DoExecuteQuery(const Qry: TStrings; ACount: Integer);

Var
  DS : TDataset;
  SQL,S,RowsAff : String;
  N : Integer;
  TS,TE : TDateTime;

begin
  RowsAff:='';
  TS:=Now;
  if ACount<>0 then
    AddToResult(Format(SExecutingSQLStatementCount,[DateTimeToStr(TS),ACount]))
  else
    AddToResult(Format(SExecutingSQLStatement,[DateTimeToStr(TS)]));
  For S in Qry do
    AddToResult(S,False);
  If Not assigned(FEngine) then
    Raise Exception.Create(SErrNoEngine);
  if Assigned(FExecParams) then
    FExecParams.Assign(ParamFrame.Params);
  SQL:=Qry.Text;
  S:=ExtractDelimited(1,Trim(SQL),[' ',#9,#13,#10]);
  If (IndexText(S,['With','SELECT'])=-1) then
    begin
    if HaveParams and Assigned(FExecParams) then
      begin
      {$IFDEF VER3_2}
      if FEngine is TSQLDBDDEngine then
        N:=TSQLDBDDEngine(FEngine).RunQuery(SQL,FExecParams)
      {$ELSE}
        FEngine.RunQuery(SQL,FExecParams)
      {$ENDIF}
      end
    else
      N:=FEngine.RunQuery(SQL);
    TE:=Now;
    If ecRowsAffected in FEngine.EngineCapabilities then
      RowsAff:=Format(SRowsAffected,[N]);
    TSData.TabVisible:=False;
    TSParams.TabVisible:=False;
    PCResult.ActivePage:=TSResult;
    end
  else
    begin
    DS:=Dataset;
    If Assigned(DS) then
      FEngine.SetQueryStatement(SQL,DS)
    else
      begin
      DS:=FEngine.CreateQuery(SQL,Self);
      FData.Dataset:=DS;
      end;
    TSData.TabVisible:=true;
    TSParams.TabVisible:=False;
    PCResult.ActivePage:=TSData;
    FData.Visible:=True;
    if HaveParams and Assigned(FExecParams) then
      begin
      {$IFDEF VER3_2}
      if FEngine is TSQLDBDDEngine then
        TSQLDBDDEngine(FEngine).ApplyParams(DS,FExecParams);
      {$ELSE}
        FEngine.ApplyParams(DS,FExecParams)
      {$ENDIF}
      end;
    DS.Open;
    TE:=Now;
    RowsAff:=Format(SRecordsFetched,[DS.RecordCount]);
    end;
  AddToResult(Format(SSQLExecutedOK,[DateTimeToStr(TE)]));
  AddToResult(Format(SExecutionTime,[FormatDateTime('hh:nn:ss.zzz',TE-TS,[fdoInterval])]),RowsAff='');
  if (RowsAff<>'') then
    AddToResult(RowsAff,True);
  AddToHistory(SQL);
  ACloseQuery.Update;
end;

function TQueryFrame.GetTransaction: TSQLTransaction;
begin
  Result:=Nil;
  if (Dataset is TSQLQuery) then
    Result:=TSQLQuery(Dataset).SQLTransaction;
  if (Result=Nil) then
    if FEngine is TSQLDBDDEngine then
      Result:=TSQLDBDDEngine(FEngine).Transaction;
end;

procedure TQueryFrame.AddToResult(const Msg: String; SetCursorPos: Boolean);

var
  MsgLines : TStringList;

begin
  MsgLines:=TStringList.Create;
  try
    MsgLines.Text:=Msg;
    MResult.Lines.AddStrings(MsgLines);
    if SetCursorPos then
      begin
      MResult.SelStart:=Length(MResult.Text);
      MResult.EnsureCursorPosVisible;
      end;
  finally
    MsgLines.Free;
  end;
end;

function TQueryFrame.ExecuteQuery(const Qry: TStrings; ACount: Integer): Boolean;

Var
  Msg : String;

begin
  Result:=False;
  if ACount>0 then
    FBusy:=bmScript
  else
    FBusy:=bmSingle;
  Try
    try
      DoExecuteQuery(Qry,ACount);
      Result:=True;
    except
{$IFNDEF VER2_6}
      on Ed : ESQLDatabaseError do
        begin
        Msg:=Ed.Message;
        if Ed.ErrorCode<>0 then
          Msg:=Msg+sLineBreak+Format(SSQLErrorCode,[Ed.ErrorCode]);
        if (Ed.SQLState<>'') then
          Msg:=Msg+sLineBreak+Format(SSQLStatus,[Ed.SQLState]);
        end;
{$ENDIF}
      On E : EDatabaseError do
        begin
        Msg:=E.Message;
        end;
    end;
    if (Msg<>'') then
      begin
      PCResult.ActivePage:=TSResult;
      AddToResult(Msg,True);
      end;
  Finally
    TSParams.TabVisible:=False;
    if ACount<=0 then
      FBusy:=bmIdle;
  end;
end;

procedure TQueryFrame.ExecuteScript(AScript : String);

begin
  FStatementCount:=0;
  FErrorCount:=0;
  FScriptMode:=smStopNextError;

  FBusy:=bmScript;
  try
    FScript.Script.Text:=AScript;
    FScript.Execute;
    If Fscript.Aborted then
      MResult.Append(Format(SScriptAborted,[FStatementCount]))
    else
      MResult.Append(Format(SScriptCompleted,[FStatementCount]));
    if FErrorCount>0 then
      MResult.Append(Format(SScriptErrorCount ,[FErrorCount]));
  finally
    FBusy:=bmIdle;
  end;
end;


procedure TQueryFrame.CloseDataset;
begin
  if FBusy=bmScript then
    FAbortScript:=True
  else
    begin
    fBusy:=bmSingle;
    Try
      FData.Dataset.Close;
      FData.Visible:=False;
      ACloseQuery.Update;
    Finally
      FBusy:=bmIdle;
    end;
    end;
end;

procedure TQueryFrame.FreeDataset;

Var
  D : TDataset;

begin
  D:=FData.Dataset;
  FData.Dataset:=Nil;
  D.Free;
end;



procedure TQueryFrame.ExportData;

begin
  With TFPDataExporter.Create(Dataset) do
    try
      Execute;
    finally
      Free;
    end;
end;

procedure TQueryFrame.CreateCode;
begin
  With TFPCodeGenerator.Create(Dataset) do
    try
      SQL:=FMSQL.Lines;
      DataSet:=Self.Dataset;
      Execute;
    Finally
      Free;
    end;
end;

procedure TQueryFrame.ActivatePanel;
begin
  If SQLSyn.TableNames.Count=0 then
    SetTableNames;
end;
end.

