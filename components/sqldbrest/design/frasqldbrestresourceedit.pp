unit frasqldbrestresourceedit;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, StdCtrls, ExtCtrls, ComCtrls, ActnList,
  lresources, Menus, db, sqldbrestbridge, sqldbRestSchema, SynEdit, SynHighlighterSQL,
  sqldbschemaedittools, frasqldbresourcefields, frasqldbresourceparams;



type

  { TSQLDBRestResourceEditFrame }

  TSQLDBRestResourceEditFrame = class(TBaseEditFrame)
    AInsertAdditonalWhere: TAction;
    AInsertLimit: TAction;
    aInsertOrderBy: TAction;
    AInsertFullOrderBy: TAction;
    AInsertOptionalWhere: TAction;
    AInsertRequiredWhere: TAction;
    AInsertFullWhere: TAction;
    AUpdateParams: TAction;
    AUpdateFields: TAction;
    AValidateSQL: TAction;
    AGenerateSQL: TAction;
    aLResource: TActionList;
    BFields1: TButton;
    BGenerate: TButton;
    BParams: TButton;
    BParams1: TButton;
    BValidate: TButton;
    BFields: TButton;
    CBEnabled: TCheckBox;
    CGOperations: TCheckGroup;
    CBConnection: TComboBox;
    CBInMetadata: TCheckBox;
    EName: TEdit;
    ETableName: TEdit;
    Label1: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    MenuItem1: TMenuItem;
    MenuItem10: TMenuItem;
    MenuItem11: TMenuItem;
    MenuItem12: TMenuItem;
    MenuItem13: TMenuItem;
    MenuItem2: TMenuItem;
    MenuItem3: TMenuItem;
    MenuItem4: TMenuItem;
    MenuItem5: TMenuItem;
    MenuItem6: TMenuItem;
    MenuItem7: TMenuItem;
    MenuItem8: TMenuItem;
    MenuItem9: TMenuItem;
    pnlParambuttons: TPanel;
    PCResource: TPageControl;
    PButtons: TPanel;
    PButtons1: TPanel;
    fraFields: TResourceFieldsEditFrame;
    fraParameters: TResourceParametersEditFrame;
    PMEdit: TPopupMenu;
    SESelect: TSynEdit;
    SEInsert: TSynEdit;
    SEupdate: TSynEdit;
    SEDelete: TSynEdit;
    SynSQLSyn1: TSynSQLSyn;
    TSparameters: TTabSheet;
    TSFields: TTabSheet;
    TSSelect: TTabSheet;
    TSInsert: TTabSheet;
    TabSheet3: TTabSheet;
    TSDelete: TTabSheet;
    procedure AGenerateSQLExecute(Sender: TObject);
    procedure AInsertFullOrderByExecute(Sender: TObject);
    procedure AInsertFullWhereExecute(Sender: TObject);
    procedure AInsertLimitExecute(Sender: TObject);
    procedure AInsertOptionalWhereExecute(Sender: TObject);
    procedure aInsertOrderByExecute(Sender: TObject);
    procedure AInsertRequiredWhereExecute(Sender: TObject);
    procedure AUpdateFieldsExecute(Sender: TObject);
    procedure AUpdateFieldsUpdate(Sender: TObject);
    procedure AUpdateParamsExecute(Sender: TObject);
    procedure AUpdateParamsUpdate(Sender: TObject);
    procedure AValidateSQLExecute(Sender: TObject);
    procedure AValidateSQLUpdate(Sender: TObject);
    procedure ETableNameEditingDone(Sender: TObject);
  private
    FOnFieldsChanged: TNotifyEvent;
    FOnParametersChanged: TNotifyEvent;
    FResource: TSQLDBRestResource;
    function GetOnFieldSelected: TNotifyEvent;
    function GetOnParameterSelected: TNotifyEvent;
    function HaveSelectSQL: Boolean;
    procedure InsertInSelect(const aPlaceholder: string);
    procedure InsertInSynedit(aSyn: TSynedit; const aPlaceHolder: string);
    procedure SetOnFieldSelected(AValue: TNotifyEvent);
    procedure SetOnParameterSelected(AValue: TNotifyEvent);
    procedure SetResource(AValue: TSQLDBRestResource);
    procedure SetTableNames;
  Protected
    procedure FieldsChanged;
    Procedure UpdateFieldList;

    procedure ParametersChanged;
    Procedure UpdateParameterList;

    procedure SetConnections(AValue: TSQLDBRestConnectionList); override;
    Procedure SetFrameData(aData: TObject); override;
  public
    constructor create(aOwner : TComponent); override;
    Function Modified : Boolean; override;
    Procedure SaveData; override;
    procedure ShowConnections;
    Procedure ShowResource;
    Function FrameCaption: String; override;
    Property Resource : TSQLDBRestResource Read FResource Write SetResource;
    Property OnFieldsChanged : TNotifyEvent Read FOnFieldsChanged Write FOnFieldsChanged;
    Property OnParametersChanged : TNotifyEvent Read FOnParametersChanged Write FOnParametersChanged;
    Property OnSelectField : TNotifyEvent Read GetOnFieldSelected Write SetOnFieldSelected;
    Property OnSelectParameter : TNotifyEvent Read GetOnParameterSelected Write SetOnParameterSelected;
  end;

implementation

uses dialogs, sqldb, TypInfo;

{$R *.lfm}


{ TSQLDBRestResourceEditFrame }

procedure TSQLDBRestResourceEditFrame.AGenerateSQLExecute(Sender: TObject);
begin
  SESelect.Lines.Text:=Resource.GenerateDefaultSQL(skSelect);
end;

procedure TSQLDBRestResourceEditFrame.AInsertFullOrderByExecute(Sender: TObject);
begin
  InsertInSelect('%FULLORDERBY%');
end;

procedure TSQLDBRestResourceEditFrame.AInsertFullWhereExecute(Sender: TObject);
begin
  InsertInSelect('%FULLWHERE%');
end;

procedure TSQLDBRestResourceEditFrame.InsertInSynedit(aSyn : TSynedit; const aPlaceHolder : string);

begin
  aSyn.SelText:=aPlaceHolder;
end;

procedure TSQLDBRestResourceEditFrame.InsertInSelect(const aPlaceholder : string);

begin
  InsertInSynedit(SESelect,aPlaceHolder);
end;

procedure TSQLDBRestResourceEditFrame.AInsertLimitExecute(Sender: TObject);
begin
  InsertInSelect('%LIMIT%');
end;

procedure TSQLDBRestResourceEditFrame.AInsertOptionalWhereExecute(Sender: TObject);
begin
  InsertInSelect('%OPTIONALWHERE%');
end;

procedure TSQLDBRestResourceEditFrame.aInsertOrderByExecute(Sender: TObject);
begin
  InsertInSelect('%ORDERBY%');
end;

procedure TSQLDBRestResourceEditFrame.AInsertRequiredWhereExecute(Sender: TObject);
begin
  InsertInSelect('%REQUIREDWHERE%');
end;

procedure TSQLDBRestResourceEditFrame.AUpdateFieldsExecute(Sender: TObject);

begin
  if Resource.Fields.Count>0 then
     if QuestionDlg(SResetFields, Format(SResetFieldsPrompt, [LineEnding, LineEnding]), mtWarning, [mrYes, SYesResetFields, mrNo,
       SDoNotResetFields], 0) <> mrYes then exit;
  UpdateFieldList;
end;

function TSQLDBRestResourceEditFrame.HaveSelectSQL: Boolean;

begin
  Result:=(SESelect.Lines.Count>0) and (Trim(SESelect.Lines[0])<>'');
end;

function TSQLDBRestResourceEditFrame.GetOnFieldSelected: TNotifyEvent;
begin
  Result:=FraFields.OnSelectField;
end;

function TSQLDBRestResourceEditFrame.GetOnParameterSelected: TNotifyEvent;
begin
  Result:=FraParameters.OnSelectParameter;
end;

procedure TSQLDBRestResourceEditFrame.SetOnFieldSelected(AValue: TNotifyEvent);
begin
  FraFields.OnSelectField:=aValue;
end;

procedure TSQLDBRestResourceEditFrame.SetOnParameterSelected(
  AValue: TNotifyEvent);
begin
  FraParameters.OnSelectParameter:=aValue;
end;

procedure TSQLDBRestResourceEditFrame.AUpdateFieldsUpdate(Sender: TObject);
begin
  (Sender as Taction).Enabled:=(ETableName.Text<>'') or HaveSelectSQL;
end;

procedure TSQLDBRestResourceEditFrame.AUpdateParamsExecute(Sender: TObject);
begin
  if Resource.Parameters.Count>0 then
     if QuestionDlg(SResetParameters, Format(SResetParametersPrompt, [LineEnding, LineEnding]), mtWarning,
       [mrYes, SYesResetParameters, mrNo,SDoNotResetParameters], 0) <> mrYes then exit;
  UpdateParameterList;
end;

procedure TSQLDBRestResourceEditFrame.AUpdateParamsUpdate(Sender: TObject);
begin
  (Sender as Taction).Enabled:=HaveSelectSQL;
end;

procedure TSQLDBRestResourceEditFrame.AValidateSQLExecute(Sender: TObject);

begin
  With ExecuteSelect(CBConnection.Text,Resource.ProcessSQl(SESelect.Lines.text,'(1=0)','','')) do
    Free;
  ShowMessage(SSQLValidatesOK);
end;

procedure TSQLDBRestResourceEditFrame.AValidateSQLUpdate(Sender: TObject);
begin
  (Sender as Taction).Enabled:=CanGetSQLConnection and HaveSelectSQL;
end;

procedure TSQLDBRestResourceEditFrame.ETableNameEditingDone(Sender: TObject);
begin
  if Not SameText(ETableName.Text,Resource.TableName)
     and (Resource.Fields.Count>0)
     and Not HaveSelectSQL then
    if MessageDlg(Format(STableNameChanged, [LineEnding]), mtWarning, [mbYes, mbNo], 0) = mrYes then
      UpdateFieldList;
end;

procedure TSQLDBRestResourceEditFrame.SetResource(AValue: TSQLDBRestResource);
begin
  if FResource=AValue then Exit;
  FResource:=AValue;
  fraFields.Resource:=Resource;
  fraParameters.Resource:=Resource;
  SetTableNames;
  ShowResource;
end;


procedure TSQLDBRestResourceEditFrame.SetTableNames;

Var
  L : TSQLDBRestResourceList;
  aTables : TStringList;
  I : integer;
  TN : String;

begin
  if not Assigned(FResource) then exit;
  if not (FResource.Collection is TSQLDBRestResourceList) then exit;
  L:=FResource.Collection as TSQLDBRestResourceList;
  aTables:=TStringList.Create;
  Try
    aTables.Sorted:=true;
    aTables.Duplicates:=dupIgnore;
    for I:=0 to L.Count-1 do
      begin
      TN:=L[i].TableName;
      if TN<>'' then
        aTables.Add(TN);
      end;
    SynSQLSyn1.TableNames:=aTables;
  finally
    aTables.Free;
  end;
end;

procedure TSQLDBRestResourceEditFrame.FieldsChanged;
begin
  FraFields.ShowResource;
  If Assigned(FonFieldsChanged) then
    FOnFieldsChanged(FResource);
end;


procedure TSQLDBRestResourceEditFrame.UpdateFieldList;

Var
  Q : TSQLQuery;
  SQL : String;
  idxFields : TStringArray;

begin
  SQL:=Trim(SESelect.Lines.Text);
  if SQL='' then
    SQL:=Resource.GenerateDefaultSQL(skSelect);
  Q:=ExecuteSelect(CBConnection.Text,Resource.ProcessSQl(SQL,'(1=0)','',''));
  try
    Resource.Fields.Clear;
    idxFields:=TSQLDBRestSchema.GetPrimaryIndexFields(Q);
    Resource.PopulateFieldsFromFieldDefs(Q.FieldDefs,idxFields,Nil,MinFieldOptions);
    FieldsChanged;
  finally
    Q.Free;
  end;
end;


procedure TSQLDBRestResourceEditFrame.ParametersChanged;
begin
  FraParameters.ShowResource;
  If Assigned(FOnParametersChanged) then
    FOnParametersChanged(FResource);
end;

procedure TSQLDBRestResourceEditFrame.UpdateParameterList;

Var
  Q : TSQLQuery;
  SQL : String;
  idxFields : TStringArray;
  Parms : TParams;

begin
  SQL:=Trim(SESelect.Lines.Text);
  if SQL='' then
    SQL:=Resource.GenerateDefaultSQL(skSelect);
  Resource.PopulateParametersFromSQl(SQL,true);
  ParametersChanged;
end;


procedure TSQLDBRestResourceEditFrame.ShowConnections;

Var
  I : Integer;

begin
  With CBConnection.Items do
      begin
      BeginUpdate;
      try
        if Not assigned(Connections) then
          For I:=0 to Connections.Count-1 do
            AddObject(Connections[i].Name,Connections[i]);
      finally
        EndUpdate;
      end;
      end;
end;

procedure TSQLDBRestResourceEditFrame.SetConnections(AValue: TSQLDBRestConnectionList);
begin
  inherited SetConnections(AValue);
  ShowConnections;
end;

procedure TSQLDBRestResourceEditFrame.SetFrameData(aData: TObject);
begin
  Resource:=aData as TMySQLDBRestResource;
end;

constructor TSQLDBRestResourceEditFrame.create(aOwner: TComponent);

var
  ro : TRestOperation;
  S : String;

begin
  inherited create(aOwner);
  CGOperations.Items.Clear;
  For ro:=Succ(Low(TRestOperation)) to High(TRestOperation) do
    begin
    S:=GetEnumName(TypeInfo(TRestOperation),Ord(RO));
    Delete(S,1,2);
    CGOperations.Items.Add(S);
    end;
  AUpdateParams.Visible:=Not FakeParams;
  PCResource.ActivePageIndex:=0;
end;

function TSQLDBRestResourceEditFrame.Modified: Boolean;

  Function Diff(S1,S2 : TStrings) : Boolean;

  begin
    Result:=Trim(S1.Text)<>Trim(S2.Text);
  end;

  Procedure DoOperation(O : TRestOperation);

  begin
    Result:=Result or (CGOperations.Checked[Ord(O)-1] <> (O in Resource.AllowedOperations));
  end;

Var
  O : TRestOperation;

begin
  Result:=False;
  With Resource do
    begin
    Result:=(ResourceName<>eName.Text) Or
            (TableName<>ETableName.Text) Or
            (Enabled<>CBEnabled.Checked) Or
            (InMetadata<>CBInMetadata.Checked) or
            Diff(SQLSelect, SESelect.Lines) Or
            Diff(SQLInsert,SEInsert.Lines) Or
            Diff(SQLUpdate,SEUpdate.Lines) Or
            Diff(SQLDelete,SEDelete.Lines);
    for O in TRestOperation do
      if o<>roUnknown then
        DoOperation(O);
    end;
end;

procedure TSQLDBRestResourceEditFrame.SaveData;

  Procedure DoOperation(O : TRestOperation);

  begin
    if CGOperations.Checked[Ord(O)-1] then
      Resource.AllowedOperations:=Resource.AllowedOperations+[O]
    else
      Resource.AllowedOperations:=Resource.AllowedOperations-[O]
  end;

Var
  O : TRestOperation;

begin
  With Resource do
    begin
    ResourceName := eName.Text;
    TableName    := ETableName.Text;
    SQLSelect    := SESelect.Lines;
    SQLInsert    := SEInsert.Lines;
    SQLUpdate    := SEUpdate.Lines;
    SQLDelete    := SEDelete.Lines;
    Enabled      := CBEnabled.Checked;
    InMetadata   := CBInMetadata.Checked;
    for O in TRestOperation do
      if o<>roUnknown then
        DoOperation(O);
    end;
end;

procedure TSQLDBRestResourceEditFrame.ShowResource;

  Procedure DoOperation(O : TRestOperation);

  begin
    CGOperations.Checked[Ord(O)-1]:=O in Resource.AllowedOperations;
  end;

Var
  O : TRestOperation;

begin
  With Resource do
    begin
    eName.Text:=ResourceName;
    ETableName.Text:=TableName;
    SESelect.Lines:=SQLSelect;
    SEInsert.Lines:=SQLInsert;
    SEUpdate.Lines:=SQLUpdate;
    SEDelete.Lines:=SQLDelete;
    CBEnabled.Checked:=Enabled;
    CBInMetadata.Checked:=InMetadata;
    for O in TRestOperation do
      if o<>roUnknown then
        DoOperation(O);
    end;
end;

function TSQLDBRestResourceEditFrame.FrameCaption: String;
begin
  if FResource=Nil then
    Result:=SUnknownObject
  else
    Result:=FResource.ResourceName;
  Result:=Format(SEditObject,[SResource,Result]);
end;

end.

