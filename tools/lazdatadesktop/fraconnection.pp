unit fraconnection;

{$mode objfpc}{$H+}

interface

uses
  fpdatadict, fraquery, Classes, SysUtils, FileUtil, LResources, Graphics, DB,
  Forms, Controls, ComCtrls, ExtCtrls,
  dmImages;

type

  { TConnectionFrame }

  TConnectionFrame = class(TFrame)
    FTV: TTreeView;
    FSplit: TSplitter;
    FPC: TPageControl;
    FTSQuery: TTabSheet;
    FTSDisplay: TTabSheet;
    FDisplay: TPanel;
    procedure DoSelectNode(Sender: TObject);
    procedure DoTabChange(Sender: TObject);
  private
    FDescription: String;
    FEngine: TFPDDEngine;
    FQueryPanel : TQueryFrame;
    procedure AddPair(LV: TListView; Const AName, AValue: String);
    procedure ClearDisplay;
    function GetCurrentObjectType: TObjectType;
    function NewNode(TV: TTreeView; ParentNode: TTreeNode; ACaption: String;
      AImageIndex: Integer): TTreeNode;
    procedure SelectConnection;
    procedure SelectField(TableName, FieldName: String);
    procedure SelectFields(TableName: String);
    procedure SelectIndexes(TableName: String);
    procedure SelectTable(TableName: String);
    procedure SelectTables;
    procedure SetDescription(const AValue: String);
    procedure SetEngine(const AValue: TFPDDEngine);
    procedure ShowDatabase;
    procedure ShowFields(ATableName: String; ATV: TTreeView; ParentNode: TTreeNode);
    procedure ShowFields(ATableName: String; ALV: TListView);
    procedure ShowIndexes(ATableName: String; ATV: TTreeView; ParentNode: TTreeNode);
    procedure ShowIndexes(ATableName: String; ALV: TListView);
    procedure ShowTableData(ATableName: String);
    procedure ShowTables(ATV : TTreeView;ParentNode: TTreeNode; AddSubNodes : Boolean = False);
  Public
    Constructor Create(AOwner : TComponent); override;
    Destructor Destroy; override;
    procedure Notification(AComponent: TComponent; Operation: TOperation); override;
    Procedure Connect(Connectstring : String);
    Procedure DisConnect;
    Function CanCreateCode : Boolean;
    Function CanCreateSQL : Boolean;
    Procedure CreateCode;
    Procedure CreateSQL;
    Property Engine : TFPDDEngine Read FEngine Write SetEngine;
    Property ObjectType : TObjectType Read GetCurrentObjectType;
    Property Description : String Read FDescription Write SetDescription;
  end;

  { TConnectionEditor }

  TConnectionEditor = Class(TTabSheet)
  private
    FFrame: TConnectionFrame;
  Public
    Constructor Create(AOwner : TComponent); override;
    Destructor Destroy; override;
    Property Frame : TConnectionFrame Read FFrame;
  end;


implementation

{$r *.lfm}

uses typinfo, fradata, lazdatadeskstr, frmgeneratesql, sqltypes;

  { TConnectionEditor }

constructor TConnectionEditor.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  FFrame:=TConnectionFrame.CReate(Self);
  FFrame.Parent:=Self;
  FFrame.Align:=alClient;
end;

destructor TConnectionEditor.Destroy;
begin
  FreeAndNil(FFrame);
  inherited Destroy;
end;

{ TConnectionFrame }

procedure TConnectionFrame.SetEngine(const AValue: TFPDDEngine);
begin
  if FEngine=AValue then exit;
  If (FEngine<>Nil) then
    FEngine.Disconnect;
  FEngine:=AValue;
  FQuerypanel.Engine:=AValue;
  If (FEngine<>Nil) then
    begin
    FEngine.FreeNotification(Self);
    FTSQuery.TabVisible:=(ecRunquery in Fengine.EngineCapabilities);
    end
  else
    FTSQuery.TabVisible:=False;
end;

constructor TConnectionFrame.Create(AOwner: TComponent);

begin
  inherited Create(AOwner);
  FTSDisplay.Caption:=SSelectedObject;
  FTSQuery.Caption:=SQuery;
  // Query panel
  FQueryPanel:= TQueryFrame.Create(Self);
  FQueryPanel.Name:='FQueryPanel';
  FQueryPanel.Parent:=FTSQuery;
  FQueryPanel.Align:=alClient;
  FTV.Images := ImgDatamodule.AppImages;
end;

destructor TConnectionFrame.Destroy;
begin
  If Assigned(FEngine) then
    FEngine.Disconnect;
  inherited Destroy;
end;

procedure TConnectionFrame.Notification(AComponent: TComponent;
  Operation: TOperation);
begin
  inherited Notification(AComponent, Operation);
  If (Operation=opRemove) and (AComponent=FEngine) then
    FEngine:=Nil;
end;

procedure TConnectionFrame.Connect(Connectstring : String);
begin
  If FEngine.Connect(ConnectString) then
    ShowDatabase;
end;

procedure TConnectionFrame.DisConnect;
begin
  If Assigned(FEngine) then
    FEngine.Disconnect;
end;

function TConnectionFrame.CanCreateCode: Boolean;

Var
  C : TControl;

begin
  C:=Nil;
  Result:=False;
  If FPC.ActivePage=FTSQuery then
    begin
    Result:=Assigned(FQueryPanel.Dataset) and FQueryPanel.Dataset.Active;
    end
  else  If FPC.ActivePage=FTSDisplay then
    begin
    if FDisplay.ControlCount>0 then
      C:=FDisplay.Controls[0];
    If Not (C is TDataFrame) then
      C:=Nil;
    Result:=Assigned(C);
    end;
end;

function TConnectionFrame.CanCreateSQL: Boolean;
begin
  Result:=(ObjectType in [otTable,otFields,otField,otTableData,otIndexDefs]);
end;

procedure TConnectionFrame.CreateSQL;

Var
  N,PN,PPN : TTreeNode;
  TN : String;
  TS : TDDTableDefs;
  L : TStringList;
begin
  N:=FTV.Selected;
  If N=Nil then
    exit;
  If Assigned(N.Parent) then
    begin
    PN:=N.Parent;
    If Assigned(PN) then
      PPN:=PN.Parent;
    end;
  Case ObjectType of
    otTable : TN:=N.Text;
    otFields,
    otTableData,
    otIndexDefs : TN:=PN.Text;
    otField : TN:=PPN.Text;
  end;
  TS:=TDDTableDefs.Create(TDDTableDef);
  try
    L:=TStringList.Create;
    try
      L.Add(TN);
      FEngine.ImportTables(TS,L,True);
    finally
      L.Free;
    end;
    TGenerateSQLForm.GenerateSQLDialog(TS,TN,False);
  finally
    TS.Free;
  end;
end;

procedure TConnectionFrame.CreateCode;

Var
  C : TControl;

begin
  C:=Nil;
  If FPC.ActivePage=FTSQuery then
    begin
    FQueryPanel.CreateCode;
    end
  else If FPC.ActivePage=FTSDisplay then
    begin
    if FDisplay.ControlCount>0 then
      C:=FDisplay.Controls[0];
    If (C is TDataFrame) then
      TDataFrame(C).CreateCode;
    end;
end;

function TConnectionFrame.NewNode(TV : TTreeView;ParentNode: TTreeNode;
  ACaption: String; AImageIndex : Integer): TTreeNode;
begin
  Result:=TV.Items.AddChild(ParentNode,ACaption);
  If AImageIndex>=0 then
    begin
    Result.ImageIndex:=AImageIndex;
    Result.SelectedIndex:=Result.ImageIndex;
    end;
end;

procedure TConnectionFrame.ShowDatabase;

Var
  S : String;
  FConnNode : TTreeNode;
  TablesNode : TTreeNode;

begin
  FTV.Items.BeginUpdate;
  try
    FTV.Items.Clear;
    If Assigned(FEngine) then
      begin
      S:=FDescription;
      If (S='') then
        S:=SNodeDatabase;
      FConnNode:=NewNode(FTV,Nil,S,iiConnection);
      TablesNode:=NewNode(FTV,FConnNode,SNodeTables,iiTables);
      ShowTables(FTV,TablesNode,True);
      FConnNode.Expand(False);
      TablesNode.Expand(False);
      FTV.Selected:=FConnNode;
      end;
  Finally
    FTV.Items.EndUpdate;
  end;
end;

function CompareSqlIdentifier(Item1, Item2: TCollectionItem): Integer;
var
   o1, o2: TSqlObjectIdenfier;
begin
     o1:=Item1 as TSqlObjectIdenfier;
     o2:=Item2 as TSqlObjectIdenfier;
     Result:=CompareStr(o1.SchemaName, o2.SchemaName);

     if Result=0
     then
       Result:=CompareStr(o1.ObjectName, o2.ObjectName);
end;

procedure TConnectionFrame.ShowTables(ATV : TTreeView;ParentNode : TTreeNode; AddSubNodes : Boolean = False);

Var
  L : TSqlObjectIdentifierList;
  I : Integer;
  N : TTreeNode;
  S : String;

begin
  L:=TSqlObjectIdentifierList.Create(TSqlObjectIdenfier);
  Try
    FEngine.GetObjectList(stTables, L);
    L.Sort(@CompareSqlIdentifier);
    For I:=0 to L.Count-1 do
      begin
      S:=L[i].ObjectName;
      If L[i].SchemaName<>'' then
        S:=L[i].SchemaName + '.' + S;
      N:=NewNode(ATV,ParentNode,S,iiTable);
      If AddSubNodes then
        begin
        NewNode(ATV,N,SNodeFields,iiFields);
        If (ecTableIndexes in FEngine.EngineCapabilities) then
          NewNode(ATV,N,SNodeIndexes,iiIndexes);
        If (ecViewTable in FEngine.EngineCapabilities) then
          NewNode(ATV,N,SNodeTabledata,iiTableData);
        end;
      end;
  Finally
    L.Free;
  end;
end;

procedure TConnectionFrame.DoSelectNode(Sender: TObject);

Var
  N,PN,PPN : TTreeNode;

begin
  N:=FTV.Selected;
  If N=Nil then
    exit;
  If Assigned(N.Parent) then
    begin
    PN:=N.Parent;
    If Assigned(PN) then
      PPN:=PN.Parent;
    end;
  Case ObjectType of
    otUnknown    : ;
    otConnection : SelectConnection;
    otTables     : SelectTables;
    otTable      : SelectTable(N.Text);
    otFields     : If Assigned(PN) then
                     SelectFields(PN.Text);
    otField      : If Assigned(PPN) then
                     SelectField(PPN.Text,N.Text);
    otTableData  : If Assigned(PN) then
                     ShowTableData(PN.Text);
    otIndexDefs  : If Assigned(PN) then
                     SelectIndexes(PN.Text);
  end;
end;

procedure TConnectionFrame.DoTabChange(Sender: TObject);
begin
  If FPC.ActivePage=FTSQuery then
    FQueryPanel.ActivatePanel;
end;

procedure TConnectionFrame.ShowTableData(ATableName : String);

Var
  P : TDataFrame;

begin
  ClearDisplay;
  P:=TDataFrame.Create(Self);
  P.DisplayMemoText := true; // TODO: implement a global option?
  P.TableName:=ATableName;
  P.Parent:=FDisplay;
  P.Align:=alClient;
  P.Dataset:=FEngine.ViewTable(ATableName,Self);
  P.Dataset.Open;
end;


procedure TConnectionFrame.AddPair(LV : TListView; Const AName, AValue : String);

Var
  LI : TListItem;

begin
  LI:=LV.Items.Add;
  LI.Caption:=AName;
  LI.SubItems.Add(AValue);
end;

procedure TConnectionFrame.SelectConnection;


Var
  LV : TListView;
  LC : TListColumn;
  L : TStringList;
  N,V : String;
  I : Integer;


begin
  ClearDisplay;
  LV:=TListView.Create(Self);
  LV.ViewStyle:=vsReport;
  LV.ShowColumnHeaders:=True;
  LC:=LV.Columns.Add;
  LC.Caption:=SParameter;
  LC.Width:=100;
  LC:=LV.Columns.Add;
  LC.Caption:=SValue;
  LC.Width:=300;
  LV.Parent:=FDisplay;
  LV.Align:=alClient;
  LV.BeginUpdate;
  try
    AddPair(LV,SDescription,FDescription);
    AddPair(LV,SEngineType,FEngine.Description);
    L:=TStringList.Create;
    Try
      L.CommaText:=FEngine.ConnectString;
      For I:=0 to L.Count-1 do
        begin
        L.GetNameValue(I,N,V);
        If (CompareText(N,'Password')<>0) then
          AddPair(LV,N,V);
        end;
    Finally
      L.Free;
    end;
  finally
    LV.EndUpdate;
  end;
end;

procedure TConnectionFrame.ClearDisplay;

begin
  With FDisplay do
    While (ControlCount>0) do
      Controls[ControlCount-1].Free;
end;

procedure TConnectionFrame.SelectTables;

Var
  TV : TTreeView;

begin
  ClearDisplay;
  TV:=TTreeView.Create(Self);
  TV.Parent:=FDisplay;
  TV.Align:=alClient;
  TV.Images := ImgDataModule.AppImages;
  ShowTables(TV,Nil);
end;

procedure TConnectionFrame.SetDescription(const AValue: String);
begin
  if FDescription=AValue then exit;
  FDescription:=AValue;
  Caption:=AValue;
end;

procedure TConnectionFrame.SelectTable(TableName : String);

Var
  TV : TTreeView;
  TN : TTreeNode;
  N : TTreeNode;

begin
  ClearDisplay;
  TV:=TTreeView.Create(Self);
  TV.Parent:=FDisplay;
  TV.Align:=alClient;
  TV.Images := ImgDatamodule.AppImages;
  TN:=NewNode(TV,Nil,TableName,iiTable);
  N:=NewNode(TV,TN,SNodeFields,iiFields);
  ShowFields(TableName,TV,N);
  N:=NewNode(TV,TN,SNodeIndexes,iiIndexes);
  ShowIndexes(TableName,TV,N);
  TN.Expand(True);
end;

procedure TConnectionFrame.SelectIndexes(TableName : String);

Var
  LV : TListView;
  LC : TListColumn;

begin
  ClearDisplay;
  LV:=TListView.Create(Self);
  LV.ViewStyle:=vsReport;
  LV.ShowColumnHeaders:=True;
  LC:=LV.Columns.Add;
  LC.Caption:=SColName;
  LC.Width:=200;
  LC:=LV.Columns.Add;
  LC.Caption:=SColFields;
  LC.Width:=80;
  LC:=LV.Columns.Add;
  LC.Caption:=SColOptions;
  LC.Width:=160;
  LV.Parent:=FDisplay;
  LV.Align:=alClient;
  LV.BeginUpdate;
  Try
    ShowIndexes(TableName,LV);
  Finally
    LV.EndUpdate;
  end;
end;

procedure TConnectionFrame.ShowIndexes(ATableName : String; ATV : TTreeView;ParentNode : TTreeNode);

Var
  L : TStringList;
  ID : TDDIndexDefs;
  D : TDDIndexDef;
  NI : TTreeNode;
  I : Integer;

begin
  L:=TStringList.Create;
  Try
    ID:=TDDIndexDefs.Create(ATableName);
    try
      FEngine.GetTableIndexDefs(ATableName,ID);
      For I:=0 to ID.Count-1 do
        L.AddObject(ID[I].IndexName,ID[I]);
      L.Sort;
      For I:=0 to L.Count-1 do
        begin
        D:=L.Objects[I] as TDDIndexDef;
        NI:=NewNode(ATV,ParentNode,D.IndexName,iiIndex);
        NewNode(ATV,NI,SNodeIndexFields+D.Fields,iiIndexFields);
        NewNode(ATV,NI,SNodeIndexOptions+IndexOptionsToString(D.Options),iiIndexOptions)
        end;
    finally
      ID.Free;
    end;
  Finally
    L.Free;
  end;
end;

procedure TConnectionFrame.ShowIndexes(ATableName : String; ALV : TListView);

Var
  L : TStringList;
  ID : TDDIndexDefs;
  D : TDDIndexDef;
  LI : TListItem;
  I : Integer;

begin
  L:=TStringList.Create;
  Try
    ID:=TDDIndexDefs.Create(ATableName);
    try
      FEngine.GetTableIndexDefs(ATableName,ID);
      For I:=0 to ID.Count-1 do
        L.AddObject(ID[I].IndexName,ID[I]);
      L.Sort;
      For I:=0 to L.Count-1 do
        begin
        D:=L.Objects[I] as TDDIndexDef;
        LI:=ALV.Items.Add;
        LI.Caption:=D.IndexName;
        LI.SubItems.Add(D.Fields);
        LI.SubItems.Add(IndexOptionsToString(D.Options));
        end;
    finally
      ID.Free;
    end;
  Finally
    L.Free;
  end;
end;

procedure TConnectionFrame.ShowFields(ATableName : String; ATV : TTreeView;ParentNode : TTreeNode);

Var
  L : TStringList;
  I : Integer;
  TD : TDDTableDef;
begin
  L:=TStringList.Create;
  Try
    TD:=TDDTableDef.Create(Nil);
    Try
      TD.TableName:=ATableName;
      FEngine.ImportFields(TD);
      For I:=0 to TD.Fields.Count-1 do
        L.Add(TD.Fields[I].FieldName);
    Finally
      TD.Free;
    end;
    L.Sorted:=True;
    For I:=0 to L.Count-1 do
      NewNode(ATV,ParentNode,L[I],iiField);
  Finally
    L.Free;
  end;
end;

procedure TConnectionFrame.ShowFields(ATableName : String; ALV : TListView);

Var
  L : TStringList;
  I : Integer;
  TD : TDDTableDef;
  FD : TDDFieldDef;
  LI : TListItem;

begin
  L:=TStringList.Create;
  Try
    TD:=TDDTableDef.Create(Nil);
    Try
      TD.TableName:=ATableName;
      FEngine.ImportFields(TD);
      For I:=0 to TD.Fields.Count-1 do
        L.AddObject(TD.Fields[I].FieldName,TD.Fields[I]);
      L.Sorted:=True;
      For I:=0 to L.Count-1 do
        begin
        LI:=ALV.Items.Add;
        FD:=L.Objects[I] as TDDFieldDef;
        LI.Caption:=FD.FieldName;
        LI.SubItems.Add(GetEnumName(TypeInfo(TFieldType),Ord(FD.FieldType)));
        LI.SubItems.Add(IntToStr(FD.Size));
        LI.SubItems.Add(BoolToStr(FD.Required,SYes,SNo));
        LI.SubItems.Add(BoolToStr(FD.ReadOnly,SYes,SNo));
        end;
    Finally
      TD.Free;
    end;
  Finally
    L.Free;
  end;
end;

procedure TConnectionFrame.SelectFields(TableName : String);

Var
  LV : TListView;
  LC : TListColumn;

begin
  ClearDisplay;
  LV:=TListView.Create(Self);
  LV.ViewStyle:=vsReport;
  LV.ShowColumnHeaders:=True;
  LC:=LV.Columns.Add;
  LC.Caption:=SColName;
  LC.Width:=200;
  LC:=LV.Columns.Add;
  LC.Caption:=SColType;
  LC.Width:=80;
  LC:=LV.Columns.Add;
  LC.Caption:=SColSize;
  LC.Width:=90;
  LC:=LV.Columns.Add;
  LC.Caption:=SColRequired;
  LC.Width:=90;
  LC:=LV.Columns.Add;
  LC.Caption:=SColReadonly;
  LC.Width:=90;
  LV.Parent:=FDisplay;
  LV.Align:=alClient;
  LV.BeginUpdate;
  Try
    ShowFields(TableName,LV);
  Finally
    LV.EndUpdate;
  end;
end;

procedure TConnectionFrame.SelectField(TableName,FieldName : String);

begin
end;

function TConnectionFrame.GetCurrentObjectType: TObjectType;

Var
  N : TTreeNode;

begin
  Result:=otUnknown;
  N:=FTV.Selected;
  If N=Nil then
    exit;
  Case N.ImageIndex of
    iiConnection : Result:=otConnection;
    iiTables     : Result:=otTables;
    iiTable      : Result:=otTable;
    iiFields     : Result:=otFields;
    iiField      : Result:=otField;
    iiTableData  : Result:=otTabledata;
    iiIndexes    : Result:=otIndexDefs;
  end;
end;

end.

