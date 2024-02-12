unit DbgTreeViewWatchData;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Math, IdeDebuggerBase, DebuggerTreeView,
  IdeDebuggerWatchResult, ArrayNavigationFrame, BaseDebugManager,
  laz.VirtualTrees, DbgIntfDebuggerBase, IdeDebuggerWatchValueIntf, Controls,
  LazDebuggerIntf, LazDebuggerIntfBaseTypes;

type

  TTreeViewDataScope       = (vdsFocus, vdsSelection, vdsSelectionOrFocus, vdsAll);
  TTreeViewDataToTextField = (vdfName, vdfDataAddress, vdfValue);
  TTreeViewDataToTextOption = (
    vdoUnQuoted, vdoAllowMultiLine
  );
  TTreeViewDataToTextFields = set of TTreeViewDataToTextField;
  TTreeViewDataToTextOptions = set of TTreeViewDataToTextOption;

  { TDbgTreeViewWatchDataMgr }

  TDbgTreeViewWatchDataMgr = class
  private
    FCancelUpdate: Boolean;
    FTreeView: TDbgTreeView;
    FExpandingWatchAbleResult: TObject;

    procedure TreeViewExpanded(Sender: TBaseVirtualTree; Node: PVirtualNode);
    procedure TreeViewInitChildren(Sender: TBaseVirtualTree;
      Node: PVirtualNode; var ChildCount: Cardinal);

    procedure DoItemRemovedFromView(Sender: TDbgTreeView; AWatchAble: TObject; ANode: PVirtualNode);
    procedure DoWatchAbleFreed(Sender: TObject);
    procedure WatchNavChanged(Sender: TArrayNavigationBar; AValue: Int64);
  protected
    function  WatchAbleResultFromNode(AVNode: PVirtualNode): IWatchAbleResultIntf; virtual; abstract;
    function  WatchAbleResultFromObject(AWatchAble: TObject): IWatchAbleResultIntf; virtual; abstract;

    function GetFieldAsText(Nd: PVirtualNode;
      AWatchAble: TObject; AWatchAbleResult: IWatchAbleResultIntf; //AVNode: PVirtualNode
      AField: TTreeViewDataToTextField;
      AnOpts: TTreeViewDataToTextOptions): String; virtual;
    procedure UpdateColumnsText(AWatchAble: TObject; AWatchAbleResult: IWatchAbleResultIntf; AVNode: PVirtualNode); virtual; abstract;
    procedure ConfigureNewSubItem(AWatchAble: TObject); virtual;

    procedure UpdateSubItemsLocked(AWatchAble: TObject; AWatchAbleResult: IWatchAbleResultIntf; AVNode: PVirtualNode; out ChildCount: LongWord); virtual;
    procedure UpdateSubItems(AWatchAble: TObject; AWatchAbleResult: IWatchAbleResultIntf; AVNode: PVirtualNode; out ChildCount: LongWord); virtual;
    procedure DoUpdateArraySubItems(AWatchAble: TObject; AWatchAbleResult: IWatchAbleResultIntf; AVNode: PVirtualNode; out ChildCount: LongWord);
    procedure DoUpdateStructSubItems(AWatchAble: TObject; AWatchAbleResult: IWatchAbleResultIntf; AVNode: PVirtualNode; out ChildCount: LongWord);
    procedure DoUpdateOldSubItems(AWatchAble: TObject; AWatchAbleResult: IWatchAbleResultIntf; AVNode: PVirtualNode; out ChildCount: LongWord);
  public
    constructor Create(ATreeView: TDbgTreeView);
    //destructor Destroy; override;

    function AddWatchData(AWatchAble: TObject; AWatchAbleResult: IWatchAbleResultIntf = nil; AVNode: PVirtualNode = nil): PVirtualNode;
    procedure UpdateWatchData(AWatchAble: TObject; AVNode: PVirtualNode; AWatchAbleResult: IWatchAbleResultIntf = nil; AnIgnoreNodeVisible: Boolean = False);

    function GetAsText(AScope: TTreeViewDataScope;
      AFields: TTreeViewDataToTextFields;
      AnOpts: TTreeViewDataToTextOptions): String;

    property CancelUpdate: Boolean read FCancelUpdate write FCancelUpdate;
    property TreeView: TDbgTreeView read FTreeView;
  end;

implementation

{ TDbgTreeViewWatchDataMgr }

procedure TDbgTreeViewWatchDataMgr.DoWatchAbleFreed(Sender: TObject);
var
  VNode: PVirtualNode;
  Nav: TControl;
begin
  VNode := FTreeView.FindNodeForItem(Sender);
  if VNode = nil then
    exit;

  FTreeView.OnItemRemoved := nil;
  FTreeView.NodeItem[VNode] := nil;

  if FTreeView.ChildCount[VNode] > 0 then begin
    VNode := FTreeView.GetFirstVisible(VNode);
    Nav := FTreeView.NodeControl[VNode];
    if (Nav <> nil) and (Nav is TArrayNavigationBar) then
      TArrayNavigationBar(Nav).OwnerData := nil;
  end;

  FTreeView.OnItemRemoved := @DoItemRemovedFromView;
end;

procedure TDbgTreeViewWatchDataMgr.WatchNavChanged(Sender: TArrayNavigationBar;
  AValue: Int64);
var
  VNode: PVirtualNode;
  AWatchAble: TObject;
  AWatchAbleResult: IWatchAbleResultIntf;
  c: LongWord;
begin
  if Sender.OwnerData = nil then
    exit;

  AWatchAble :=  TObject(Sender.OwnerData);
  AWatchAbleResult :=  WatchAbleResultFromObject(AWatchAble);
  if (AWatchAbleResult <> nil) and AWatchAbleResult.Enabled and
     (AWatchAbleResult.Validity = ddsValid)
  then begin
    VNode := FTreeView.FindNodeForItem(AWatchAble);
    if VNode = nil then
      exit;

    UpdateSubItems(AWatchAble, AWatchAbleResult, VNode, c);
  end;
end;

function TDbgTreeViewWatchDataMgr.GetFieldAsText(Nd: PVirtualNode;
  AWatchAble: TObject; AWatchAbleResult: IWatchAbleResultIntf;
  AField: TTreeViewDataToTextField; AnOpts: TTreeViewDataToTextOptions): String;
begin
  Result := '';
  case AField of
    vdfName:        Result := TreeView.NodeText[Nd, 0];
    vdfDataAddress: Result := TreeView.NodeText[Nd, 1];
    vdfValue:       Result := TreeView.NodeText[Nd, 2];
  end;
end;

procedure TDbgTreeViewWatchDataMgr.ConfigureNewSubItem(AWatchAble: TObject);
begin
  //
end;

procedure TDbgTreeViewWatchDataMgr.UpdateSubItemsLocked(AWatchAble: TObject;
  AWatchAbleResult: IWatchAbleResultIntf; AVNode: PVirtualNode; out
  ChildCount: LongWord);
begin
  UpdateSubItems(AWatchAble, AWatchAbleResult, AVNode, ChildCount);
end;

procedure TDbgTreeViewWatchDataMgr.UpdateSubItems(AWatchAble: TObject;
  AWatchAbleResult: IWatchAbleResultIntf; AVNode: PVirtualNode; out
  ChildCount: LongWord);
var
  ResData: TWatchResultData;
begin
  ChildCount := 0;
  if (AWatchAble <> nil) or (AWatchAbleResult = nil) then
    AWatchAbleResult := WatchAbleResultFromObject(AWatchAble);
  if (AWatchAble = nil) or (AWatchAbleResult = nil) then begin
    FTreeView.ChildCount[AVNode] := 0;
    exit;
  end;

  ResData := AWatchAbleResult.ResultData;
  while (ResData <> nil) and (ResData.ValueKind = rdkPointerVal) do
    ResData := ResData.DerefData;

  if (ResData <> nil) and
     (ResData.FieldCount > 0) and
     (ResData.ValueKind <> rdkConvertRes)
  then
    DoUpdateStructSubItems(AWatchAble, AWatchAbleResult, AVNode, ChildCount)
  else
  if (ResData <> nil) and
     //(ResData.ValueKind = rdkArray) and
     (ResData.ArrayLength > 0)
  then
    DoUpdateArraySubItems(AWatchAble, AWatchAbleResult, AVNode, ChildCount)
  else
  if (AWatchAbleResult.TypeInfo <> nil) and (AWatchAbleResult.TypeInfo.Fields <> nil) then
    // Old Interface
    DoUpdateOldSubItems(AWatchAble, AWatchAbleResult, AVNode, ChildCount);

  FTreeView.ChildCount[AVNode] := ChildCount;
  FTreeView.Invalidate;
end;

procedure TDbgTreeViewWatchDataMgr.DoUpdateArraySubItems(AWatchAble: TObject;
  AWatchAbleResult: IWatchAbleResultIntf; AVNode: PVirtualNode; out
  ChildCount: LongWord);
var
  NewWatchAble: TObject;
  i, TotalCount, DerefCount: Integer;
  ResData: TWatchResultData;
  ExistingNode, nd: PVirtualNode;
  Nav: TArrayNavigationBar;
  Offs, KeepCnt, KeepBelow: Int64;
begin
  ChildCount := 0;
  ResData := AWatchAbleResult.ResultData;
  DerefCount := 0;
  while (ResData <> nil) and (ResData.ValueKind = rdkPointerVal) do begin
    ResData := ResData.DerefData;
    inc(DerefCount);
  end;
  if (ResData = nil) then
    exit;

  TotalCount := ResData.ArrayLength;
  if (ResData.ValueKind <> rdkArray) or (TotalCount = 0) then
    TotalCount := ResData.Count;

  ExistingNode := FTreeView.GetFirstChildNoInit(AVNode);
  if ExistingNode = nil then
    ExistingNode := FTreeView.AddChild(AVNode, nil)
  else
    FTreeView.NodeItem[ExistingNode] := nil;

  Nav := TArrayNavigationBar(FTreeView.NodeControl[ExistingNode]);
  if Nav = nil then begin
    Nav := TArrayNavigationBar.Create(nil);
    Nav.ParentColor := False;
    Nav.ParentBackground := False;
    Nav.Color := FTreeView.Colors.BackGroundColor;
    Nav.LowBound := ResData.LowBound;
    Nav.HighBound := ResData.LowBound + TotalCount - 1;
    Nav.ShowBoundInfo := True;
    Nav.Index := ResData.LowBound;
    Nav.PageSize := 10;
    Nav.OnIndexChanged := @WatchNavChanged;
    Nav.OnPageSize := @WatchNavChanged;
    Nav.HardLimits := not(ResData.ValueKind = rdkArray);
    FTreeView.NodeControl[ExistingNode] := Nav;
    FTreeView.NodeText[ExistingNode, 0] := ' ';
    FTreeView.NodeText[ExistingNode, 1] := ' ';
  end;
  Nav.OwnerData := AWatchAble;
  ChildCount := Nav.LimitedPageSize;

  ExistingNode := FTreeView.GetNextSiblingNoInit(ExistingNode);

  Offs := Nav.Index;
  for i := 0 to ChildCount - 1 do begin
    NewWatchAble := AWatchAbleResult.ChildrenByNameAsArrayEntry[Offs +  i, DerefCount];
    if NewWatchAble = nil then begin
      dec(ChildCount);
      continue;
    end;

    ConfigureNewSubItem(NewWatchAble);

    if ExistingNode <> nil then begin
      FTreeView.NodeItem[ExistingNode] := NewWatchAble;
      nd := ExistingNode;
      ExistingNode := FTreeView.GetNextSiblingNoInit(ExistingNode);
    end
    else begin
      nd := FTreeView.AddChild(AVNode, NewWatchAble);
    end;
    (NewWatchAble as IFreeNotifyingIntf).AddFreeNotification(@DoWatchAbleFreed);
    UpdateWatchData(NewWatchAble, nd, nil, True);
  end;

  inc(ChildCount); // for the nav row

  KeepCnt := Nav.PageSize;
  KeepBelow := KeepCnt;
  KeepCnt := max(max(50, KeepCnt+10),
           Min(KeepCnt*10, 500) );
  KeepBelow := Min(KeepBelow, KeepCnt - Nav.PageSize);
  (AWatchAble as IWatchAbleDataIntf).LimitChildWatchCount(KeepCnt, ResData.LowBound + KeepBelow);
end;

procedure TDbgTreeViewWatchDataMgr.DoUpdateStructSubItems(AWatchAble: TObject;
  AWatchAbleResult: IWatchAbleResultIntf; AVNode: PVirtualNode; out
  ChildCount: LongWord);
var
  ResData: TWatchResultData;
  ExistingNode, nd: PVirtualNode;
  AnchClass: String;
  NewWatchAble: TObject;
  ChildInfo: TWatchResultDataFieldInfo;
  DerefCount: Integer;
begin
  ChildCount := 0;
  ResData := AWatchAbleResult.ResultData;
  DerefCount := 0;
  while (ResData <> nil) and (ResData.ValueKind = rdkPointerVal) do begin
    ResData := ResData.DerefData;
    inc(DerefCount);
  end;
  if ResData = nil then
    exit;

  ExistingNode := FTreeView.GetFirstChildNoInit(AVNode);
  if ExistingNode <> nil then
    FTreeView.NodeControl[ExistingNode] := nil;

  AnchClass := '';
  if ResData.StructType <> dstRecord then
    AnchClass := ResData.TypeName;
  for ChildInfo in ResData do begin
    NewWatchAble := AWatchAbleResult.ChildrenByNameAsField[ChildInfo.FieldName, AnchClass, DerefCount];
    if NewWatchAble = nil then begin
      continue;
    end;
    inc(ChildCount);

    ConfigureNewSubItem(NewWatchAble);

    if ExistingNode <> nil then begin
      FTreeView.NodeItem[ExistingNode] := NewWatchAble;
      nd := ExistingNode;
      ExistingNode := FTreeView.GetNextSiblingNoInit(ExistingNode);
    end
    else begin
      nd := FTreeView.AddChild(AVNode, NewWatchAble);
    end;
    (NewWatchAble as IFreeNotifyingIntf).AddFreeNotification(@DoWatchAbleFreed);
    UpdateWatchData(NewWatchAble, nd, nil, True);
  end;
end;

procedure TDbgTreeViewWatchDataMgr.DoUpdateOldSubItems(AWatchAble: TObject;
  AWatchAbleResult: IWatchAbleResultIntf; AVNode: PVirtualNode; out
  ChildCount: LongWord);
var
  TypInfo: TDBGType;
  IsGdbmiArray: Boolean;
  ExistingNode, nd: PVirtualNode;
  AnchClass: String;
  i: Integer;
  NewWatchAble: TObject;
begin
  TypInfo := AWatchAbleResult.TypeInfo;

  if (TypInfo <> nil) and (TypInfo.Fields <> nil) then begin
    IsGdbmiArray := TypInfo.Attributes * [saDynArray, saArray] <> [];
    ChildCount := TypInfo.Fields.Count;
    ExistingNode := FTreeView.GetFirstChildNoInit(AVNode);

    AnchClass := TypInfo.TypeName;
    for i := 0 to TypInfo.Fields.Count-1 do begin
      if IsGdbmiArray then
        NewWatchAble := AWatchAbleResult.ChildrenByNameAsArrayEntry[StrToInt64Def(TypInfo.Fields[i].Name, 0), 0]
      else
        NewWatchAble := AWatchAbleResult.ChildrenByNameAsField[TypInfo.Fields[i].Name, AnchClass, 0];
      if NewWatchAble = nil then begin
        dec(ChildCount);
        continue;
      end;
      ConfigureNewSubItem(NewWatchAble);

      if ExistingNode <> nil then begin
        FTreeView.NodeItem[ExistingNode] := NewWatchAble;
        nd := ExistingNode;
        ExistingNode := FTreeView.GetNextSiblingNoInit(ExistingNode);
      end
      else begin
        nd := FTreeView.AddChild(AVNode, NewWatchAble);
      end;
      (NewWatchAble as IFreeNotifyingIntf).AddFreeNotification(@DoWatchAbleFreed);
      UpdateWatchData(NewWatchAble, nd, nil, True);
    end;
  end;
end;

procedure TDbgTreeViewWatchDataMgr.TreeViewExpanded(Sender: TBaseVirtualTree;
  Node: PVirtualNode);
var
  AWatchAble: TObject;
begin
  Node := FTreeView.GetFirstChildNoInit(Node);
  while Node <> nil do begin
    AWatchAble := FTreeView.NodeItem[Node];
    if AWatchAble <> nil then
      UpdateWatchData(AWatchAble, Node);
    Node := FTreeView.GetNextSiblingNoInit(Node);
  end;
end;

procedure TDbgTreeViewWatchDataMgr.TreeViewInitChildren(
  Sender: TBaseVirtualTree; Node: PVirtualNode; var ChildCount: Cardinal);
var
  AWatchAble: TObject;
  AWatchAbleResult: IWatchAbleResultIntf;
begin
  ChildCount := 0;
  AWatchAble := FTreeView.NodeItem[Node];
  if (AWatchAble <> nil) then
    AWatchAbleResult := WatchAbleResultFromObject(AWatchAble);
  if (AWatchAble = nil) or (AWatchAbleResult = nil) then begin
    FTreeView.ChildCount[Node] := 0;
    exit;
  end;

  FExpandingWatchAbleResult := AWatchAble;
  UpdateSubItemsLocked(AWatchAble, AWatchAbleResult, Node, ChildCount);
  FExpandingWatchAbleResult := nil;
end;

procedure TDbgTreeViewWatchDataMgr.DoItemRemovedFromView(Sender: TDbgTreeView;
  AWatchAble: TObject; ANode: PVirtualNode);
begin
  if AWatchAble <> nil then
    with (AWatchAble as IWatchAbleDataIntf) do begin
      ClearDisplayData;
      RemoveFreeNotification(@DoWatchAbleFreed);
    end;
end;

constructor TDbgTreeViewWatchDataMgr.Create(ATreeView: TDbgTreeView);
begin
  FTreeView := ATreeView;
  FTreeView.OnItemRemoved  := @DoItemRemovedFromView;
  FTreeView.OnExpanded     := @TreeViewExpanded;
  FTreeView.OnInitChildren := @TreeViewInitChildren;
end;

function TDbgTreeViewWatchDataMgr.AddWatchData(AWatchAble: TObject;
  AWatchAbleResult: IWatchAbleResultIntf; AVNode: PVirtualNode): PVirtualNode;
begin
  if AWatchAble = nil then
    exit;

  if (AVNode <> nil) then begin
    FTreeView.NodeItem[AVNode] := AWatchAble;
    FTreeView.SelectNode(AVNode);
    (AWatchAble as IFreeNotifyingIntf).AddFreeNotification(@DoWatchAbleFreed);
  end
  else begin
    AVNode := FTreeView.FindNodeForItem(AWatchAble);
    if AVNode = nil then begin
      AVNode := FTreeView.AddChild(nil, AWatchAble);
      FTreeView.SelectNode(AVNode);
      (AWatchAble as IFreeNotifyingIntf).AddFreeNotification(@DoWatchAbleFreed);
    end;
  end;
  Result := AVNode;

  UpdateWatchData(AWatchAble, AVNode, AWatchAbleResult);
end;

procedure TDbgTreeViewWatchDataMgr.UpdateWatchData(AWatchAble: TObject;
  AVNode: PVirtualNode; AWatchAbleResult: IWatchAbleResultIntf;
  AnIgnoreNodeVisible: Boolean);
var
  TypInfo: TDBGType;
  ResData: TWatchResultData;
  HasChildren: Boolean;
  c: LongWord;
begin
  if not (FTreeView.FullyVisible[AVNode] or AnIgnoreNodeVisible) then
    exit;

  if AWatchAbleResult = nil then
    AWatchAbleResult := WatchAbleResultFromObject(AWatchAble);

  UpdateColumnsText(AWatchAble, AWatchAbleResult, AVNode);
  FTreeView.Invalidate;

  if AWatchAbleResult = nil then
    exit;

  // some debuggers may have run Application.ProcessMessages
  if CancelUpdate then
    exit;

  (* If the watch is ddsRequested or ddsEvaluating => keep any expanded tree-nodes. (Avoid flicker)
     > ddsEvaluating includes "not HasAllValidParents"
     If the debugger is running => keey any expanded tree-nodes
  *)

  if (not(AWatchAbleResult.Validity in [ddsRequested, ddsEvaluating])) and
     ((DebugBoss = nil) or (DebugBoss.State <> dsRun))
  then begin
    TypInfo := AWatchAbleResult.TypeInfo;
    ResData := AWatchAbleResult.ResultData;
    while (ResData <> nil) and (ResData.ValueKind = rdkPointerVal) do
      ResData := ResData.DerefData;
    HasChildren := ( (TypInfo <> nil) and (TypInfo.Fields <> nil) and (TypInfo.Fields.Count > 0) ) or
                   ( (ResData <> nil) and
                     ( ( (ResData.FieldCount > 0) and (ResData.ValueKind <> rdkConvertRes) )
                       or
                       //( (ResData.ValueKind = rdkArray) and (ResData.ArrayLength > 0) )
                       (ResData.ArrayLength > 0)
                   ) );
    FTreeView.HasChildren[AVNode] := HasChildren;

    if HasChildren and FTreeView.Expanded[AVNode] then begin
      if (AWatchAbleResult.Validity = ddsValid) then begin
        (* The current "AWatchAbleResult" should be done. Allow UpdateItem for nested entries *)

        UpdateSubItems(AWatchAble, AWatchAbleResult, AVNode, c);
      end;
    end
    else
    if AWatchAble <> FExpandingWatchAbleResult then
      FTreeView.DeleteChildren(AVNode, False);
  end
end;

function TDbgTreeViewWatchDataMgr.GetAsText(AScope: TTreeViewDataScope;
  AFields: TTreeViewDataToTextFields; AnOpts: TTreeViewDataToTextOptions
  ): String;

  function GetEntryText(Nd: PVirtualNode): String;
  var
    AWatchAbleResult: IWatchAbleResultIntf;
    AWatchAble: TObject;
    r: String;
  begin
    AWatchAble := TreeView.NodeItem[Nd];
    AWatchAbleResult := WatchAbleResultFromObject(AWatchAble);
    Result := '';
    if vdfName in AFields then
      Result := GetFieldAsText(Nd, AWatchAble, AWatchAbleResult, vdfName, AnOpts);
    if vdfDataAddress in AFields then begin
      r := GetFieldAsText(Nd, AWatchAble, AWatchAbleResult, vdfDataAddress, AnOpts);
      if r <> '' then begin
        if Result <> '' then
          Result := Result + ' ';
        if (AFields - [vdfDataAddress]) <> [] then
          Result := Result + '@';
        Result := Result + r;
      end;
    end;
    if vdfValue in AFields then begin
      r := GetFieldAsText(Nd, AWatchAble, AWatchAbleResult, vdfValue, AnOpts);
      if r <> '' then begin
        if Result <> '' then
          Result := Result + ' = ';
        Result := Result + r;
      end;
    end;
  end;

var
  Nd: PVirtualNode;
  Itr: TVTVirtualNodeEnumeration;
begin
  Result := '';
  if (AScope = vdsFocus) or
     ( (AScope = vdsSelectionOrFocus) and (TreeView.SelectedCount=0) )
  then begin
    Nd := TreeView.FocusedNode;
    Result := GetEntryText(Nd);
    exit;
  end;

  case AScope of
    vdsSelection, vdsSelectionOrFocus: Itr := TreeView.SelectedNodes;
    vdsAll: Itr := TreeView.NoInitNodes;
  end;
  for Nd in Itr do begin
    Result := Result + GetEntryText(Nd) + LineEnding;
  end;
end;

end.

