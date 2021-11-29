{
 *****************************************************************************
  See the file COPYING.modifiedLGPL.txt, included in this distribution,
  for details about the license.
 *****************************************************************************

  Author: Mattias Gaertner

  Abstract:
    TComponentTreeView is a component to show the child components of a
    TComponent. TControls are shown in a hierachic view.
    It supports
      - multi selecting components
      - editing the creation order
      - editing the TControl.Parent hierachy
    For an usage example, see the object inspector.
}
unit ComponentTreeView;

{$mode objfpc}{$H+}

{off $DEFINE VerboseComponentTVWalker}

interface

uses
  Classes, SysUtils, TypInfo, Laz_AVL_Tree,
  // LazUtils
  LazUtilities, LazLoggerBase, LazTracer, AvgLvlTree,
  // LCL
  Dialogs, Forms, Controls, ComCtrls,
  // IdeIntf
  ObjInspStrConsts, PropEdits, PropEditUtils, ComponentEditors, IDEImagesIntf;
  
type
  TCTVGetImageIndexEvent = procedure(APersistent: TPersistent;
    var AIndex: integer) of object;

  // First 4 are ways to change ZOrder, zoDelete deletes a component.
  TZOrderDelete = (zoToFront, zoToBack, zoForward, zoBackward, zoDelete);

  { TComponentTreeView }

  TComponentTreeView = class(TCustomTreeView)
  private
    FComponentList: TBackupComponentList;
    FPropertyEditorHook: TPropertyEditorHook;
    // Map of Root component -> TAVLTree of collapsed components.
    FRoot2CollapasedMap: TPointerToPointerTree;
    FCollapsedComps: TAVLTree;       // The current list of collapsed components.
    FDrawWholeTree: Boolean;
    FZOrderDelCommand: TZOrderDelete;
    FPreviousDeleted: TPersistent;   // Delete command can be called twice. Keep track.
    // Events
    FOnComponentGetImageIndex: TCTVGetImageIndexEvent;
    FOnModified: TNotifyEvent;
    function AddOrGetPersNode(AParentNode: TTreeNode; APers: TPersistent;
      ACapt: String): TTreeNode;
    procedure AddChildren(AComponent: TComponent; ARootNode: TTreeNode);
    procedure ChangeNode(ANode: TTreeNode);
    function FindAndChange(APers: TPersistent; AZOrderDel: TZOrderDelete): Boolean;
    function GetRootObject: TPersistent;
    function GetSelection: TPersistentSelectionList;
    function IterateTree(ANode: TTreeNode; APers: TPersistent): TTreeNode;
    procedure NodeCollapsed(Sender: TObject; Node: TTreeNode);
    procedure NodeExpanded(Sender: TObject; Node: TTreeNode);
    procedure RestoreExpand(ANode: TTreeNode);
    procedure SetPropertyEditorHook(AValue: TPropertyEditorHook);
    procedure SetSelection(NewSelection: TPersistentSelectionList);
    procedure UpdateCompNode(ANode: TTreeNode);
    procedure UpdateSelNode(ANode: TTreeNode);
    procedure UpdateSelected;
  protected
    procedure DoSelectionChanged; override;
    function GetImageFor(APersistent: TPersistent):integer;
    procedure DragOver(Source: TObject; X, Y: Integer; State: TDragState;
                       var Accept: Boolean); override;
    procedure DragCanceled; override;
    procedure MouseLeave; override;
    procedure GetComponentInsertMarkAt(X, Y: Integer;
                              out AnInsertMarkNode: TTreeNode;
                              out AnInsertMarkType: TTreeViewInsertMarkType);
    procedure DoModified;
  public
    constructor Create(TheOwner: TComponent); override;
    destructor Destroy; override;
    procedure DragDrop(Source: TObject; X, Y: Integer); override;
    procedure BuildComponentNodes(AWholeTree: Boolean);
    procedure ChangeCompZOrder(APersistent: TPersistent; AZOrder: TZOrderDelete);
    procedure DeleteComponentNode(APersistent: TPersistent);
    procedure UpdateComponentNodesValues;
  public
    ImgIndexForm: Integer;
    ImgIndexComponent: Integer;
    ImgIndexControl: Integer;
    ImgIndexBox: Integer;
    ImgIndexCollection: Integer;
    ImgIndexItem: Integer;
    property Selection: TPersistentSelectionList read GetSelection
                                                 write SetSelection;
    property PropertyEditorHook: TPropertyEditorHook
                           read FPropertyEditorHook write SetPropertyEditorHook;
    property OnSelectionChanged;
    property OnModified: TNotifyEvent read FOnModified write FOnModified;
    property OnComponentGetImageIndex : TCTVGetImageIndexEvent
                  read FOnComponentGetImageIndex write FOnComponentGetImageIndex;
  end;

implementation

{$R ../../images/componenttreeview.res}

type
  TCollectionAccess = class(TCollection);
  TComponentAccessor = class(TComponent);

  { TComponentWalker }

  TComponentWalker = class
  private
    FCompTV: TComponentTreeView;
    FLookupRoot: TComponent;
    FNode: TTreeNode;
    procedure AddCollection(AColl: TCollection; AParentNode: TTreeNode);
    procedure AddOwnedPersistent(APers: TPersistent; const APropName: String;
      AParentNode: TTreeNode);
    procedure GetOwnedPersistents(APers: TPersistent; AParentNode: TTreeNode);
    procedure Walk(AComponent: TComponent);
  public
    constructor Create(ACompTV: TComponentTreeView; ALookupRoot: TComponent);
  end;

function CollectionCaption(ACollection: TCollection; DefaultName: string): string;
var
  PropList: PPropList;
  i, PropCount: Integer;
begin
  Result := '';
  if Result <> '' then
    Result := TCollectionAccess(ACollection).PropName
  else if DefaultName<>'' then
    Result := DefaultName  // DefaultName is the property name.
  else if ACollection.Owner <> nil then
  begin
    PropCount := GetPropList(ACollection.Owner, PropList);
    try                 // Find the property name where ACollection can be found.
      for i := 0 to PropCount - 1 do
        if (PropList^[i]^.PropType^.Kind = tkClass) then
          if GetObjectProp(ACollection.Owner, PropList^[i], ACollection.ClassType) = ACollection then
          begin
            Result := PropList^[i]^.Name;
            Break;
          end;
    finally
      FreeMem(PropList);
    end;
  end;
  if Result = '' then
    Result := '<unknown collection>';
  Result := Result + ': ' + ACollection.ClassName;
end;

function CollectionItemCaption(ACollItem: TCollectionItem): string;
begin
  Result := IntToStr(ACollItem.Index)+' - '+ACollItem.DisplayName+': '+ACollItem.ClassName;
end;

function ComponentCaption(AComponent: TComponent): String;
begin
  Result := AComponent.Name + ': ' + AComponent.ClassName;
end;

function CreateNodeCaption(APersistent: TPersistent; DefaultName: string): string;
begin
  Result := APersistent.ClassName;
  if APersistent is TComponent then
    Result := ComponentCaption(TComponent(APersistent))
  else if APersistent is TCollection then
    Result := CollectionCaption(TCollection(APersistent), DefaultName)
  else if APersistent is TCollectionItem then
    Result := CollectionItemCaption(TCollectionItem(APersistent))
  else if DefaultName<>'' then
    Result := DefaultName + ':' + Result;
end;

{ TComponentWalker }

constructor TComponentWalker.Create(ACompTV: TComponentTreeView; ALookupRoot: TComponent);
begin
  {$IFDEF VerboseComponentTVWalker}
  DebugLn(['TComponentWalker.Create ALookupRoot=',DbgSName(ALookupRoot)]);
  {$ENDIF}
  FCompTV := ACompTV;
  FLookupRoot := ALookupRoot;
end;

procedure TComponentWalker.AddCollection(AColl: TCollection; AParentNode: TTreeNode);
var
  ItemNode: TTreeNode;
  Item: TCollectionItem;
  i: integer;
begin
  for i := 0 to AColl.Count - 1 do
  begin
    Item := AColl.Items[i];
    {$IFDEF VerboseComponentTVWalker}
    DebugLn(['TComponentWalker.AddCollection, Adding CollectionItem ',
             Item.DisplayName, ':', Item.ClassName]);
    {$ENDIF}
    ItemNode := FCompTV.AddOrGetPersNode(AParentNode, Item, CollectionItemCaption(Item));
    // Collections can be nested. Add possible Collections under a CollectionItem.
    GetOwnedPersistents(Item, ItemNode);
  end;
end;

procedure TComponentWalker.AddOwnedPersistent(APers: TPersistent;
  const APropName: String; AParentNode: TTreeNode);
var
  TVNode: TTreeNode;
  TheRoot: TPersistent;
begin
  if (APers is TComponent) then
    Assert(not (csDestroying in TComponent(APers).ComponentState), 'TComponentWalker: Comp is Destroying.');
  TheRoot := GetLookupRootForComponent(APers);
  {$IFDEF VerboseComponentTVWalker}
  DebugLn(['TComponentWalker.AddOwnedPersistent'+
           ' PropName=',APropName,' Persistent=',DbgSName(APers),
           ' its root=',DbgSName(TheRoot),' FLookupRoot=',DbgSName(FLookupRoot)]);
  {$ENDIF}
  if TheRoot <> FLookupRoot then begin
    DebugLn(['TComponentWalker.AddOwnedPersistent: TheRoot "', TheRoot, '" <> FLookupRoot "', FLookupRoot, '"']);
    Exit;
  end;
  TVNode := FCompTV.AddOrGetPersNode(AParentNode, APers, CreateNodeCaption(APers, APropName));
  if APers is TCollection then
    AddCollection(TCollection(APers), TVNode);
end;

procedure TComponentWalker.GetOwnedPersistents(APers: TPersistent; AParentNode: TTreeNode);
var
  PropList: PPropList;
  PropCount, i: Integer;
  PropInfo: PPropInfo;
  PropPers: TPersistent;
begin
  PropCount := GetPropList(APers, PropList);
  try
    for i := 0 to PropCount - 1 do begin
      PropInfo:=PropList^[i];
      if (PropInfo^.PropType^.Kind <> tkClass) then Continue;
      {$IFDEF ShowOwnedObjectsOI}
      PropPers := TPersistent(GetObjectProp(APers, PropInfo, TPersistent));
      {$ELSE}
      PropPers := TPersistent(GetObjectProp(APers, PropInfo, TCollection));
      {$ENDIF}
      if PropPers=nil then Continue;
      if GetEditorClass(PropInfo, APers)=nil then Continue;
      {$IFDEF VerboseComponentTVWalker}
      DebugLn(['TComponentWalker.GetOwnedPersistents Persistent=',DbgSName(APers),
               ' PropName=',PropInfo^.Name,' FLookupRoot=',DbgSName(FLookupRoot)]);
      {$ENDIF}
      AddOwnedPersistent(PropPers, PropInfo^.Name, AParentNode);
    end;
  finally
    FreeMem(PropList);
  end;
end;

procedure TComponentWalker.Walk(AComponent: TComponent);
var
  OldNode: TTreeNode;
  Root: TComponent;
begin
  if csDestroying in AComponent.ComponentState then begin
    DebugLn(['TComponentWalker.Walk: ', AComponent, ' is Destroying.']);
    Exit;
  end;
  if GetLookupRootForComponent(AComponent) <> FLookupRoot then begin
    DebugLn(['TComponentWalker.Walk: "', AComponent, '" LookupRoot <> FLookupRoot "', FLookupRoot, '"']);
    Exit;
  end;
  OldNode := FNode;
  FNode := FCompTV.AddOrGetPersNode(FNode, AComponent, ComponentCaption(AComponent));
  GetOwnedPersistents(AComponent, FNode);
  if (csInline in AComponent.ComponentState) or (AComponent.Owner = nil) then
    Root := AComponent
  else
    Root := AComponent.Owner;
  if not ( (Root is TControl)
          and (csOwnedChildrenNotSelectable in TControl(Root).ControlStyle) )
  then
    TComponentAccessor(AComponent).GetChildren(@Walk, Root);
  FNode := OldNode;
end;

{ TComponentTreeView }

procedure TComponentTreeView.SetSelection(NewSelection: TPersistentSelectionList);
begin
  if (PropertyEditorHook = nil) then
  begin
    if (FComponentList.LookupRoot = nil) then Exit;
    FComponentList.Clear;
  end
  else if not NewSelection.ForceUpdate
     and FComponentList.IsEqual(PropertyEditorHook.LookupRoot, NewSelection) then
  begin
    // nodes ok, but maybe node values need update
    UpdateComponentNodesValues;
    Exit;
  end;
  FComponentList.LookupRoot := PropertyEditorHook.LookupRoot;
  FComponentList.Selection.Assign(NewSelection);
  NewSelection.ForceUpdate:=false;
  UpdateSelected;
end;

procedure TComponentTreeView.DoSelectionChanged;
var
  ANode: TTreeNode;
  APersistent: TPersistent;
  NewSelection: TPersistentSelectionList;
begin
  NewSelection := TPersistentSelectionList.Create;
  try
    if (PropertyEditorHook<>nil) and
       (PropertyEditorHook.LookupRoot<>nil) and
       (not (csDestroying in ComponentState)) then
    begin
      ANode := GetFirstMultiSelected;
      while ANode <> nil do
      begin
        APersistent := TPersistent(ANode.Data);
        if APersistent = nil then
          RaiseGDBException('TComponentTreeView.DoSelectionChanged ANode.Data=nil');
        if GetLookupRootForComponent(APersistent) = PropertyEditorHook.LookupRoot then
          NewSelection.Add(APersistent);
        ANode := ANode.GetNextMultiSelected;
      end;
      NewSelection.SortLike(FComponentList.Selection);
    end;
    if NewSelection.IsEqual(FComponentList.Selection) then
      Exit;
    FComponentList.Selection.Assign(NewSelection);

    inherited DoSelectionChanged;
  finally
    NewSelection.Free;
  end;
end;

procedure TComponentTreeView.DragDrop(Source: TObject; X, Y: Integer);
var
  Node, ParentNode, SelNode: TTreeNode;
  ACollection: TCollection;
  AContainer, OldContainer: TWinControl;
  AControl: TControl;
  InsertType: TTreeViewInsertMarkType;
  RootDesigner: TIDesigner;
  CompEditDsg: TComponentEditorDesigner;
  NewIndex, AIndex: Integer;
  ok: Boolean;
begin
  GetComponentInsertMarkAt(X, Y, Node, InsertType);
  SetInsertMark(nil, tvimNone);
  if InsertType in [tvimAsNextSibling, tvimAsPrevSibling] then
    ParentNode := Node.Parent
  else
    ParentNode := Node;
  if Assigned(ParentNode) then
  begin
    // Find designer for Undo actions.
    Assert(Assigned(FPropertyEditorHook), 'TComponentTreeView.DragDrop: PropertyEditorHook=Nil.');
    RootDesigner := FindRootDesigner(FPropertyEditorHook.LookupRoot);
    if (RootDesigner is TComponentEditorDesigner) then
      CompEditDsg := TComponentEditorDesigner(RootDesigner) //if CompEditDsg.IsUndoLocked then Exit;
    else
      CompEditDsg := nil;

    if TObject(ParentNode.Data) is TWinControl then
    begin
      AContainer := TWinControl(ParentNode.Data);
      SelNode := GetFirstMultiSelected;
      while Assigned(SelNode) do
      begin
        if TObject(SelNode.Data) is TControl then
        begin
          AControl := TControl(SelNode.Data);
          ok:=false;
          try
            OldContainer := AControl.Parent;
            AControl.Parent := AContainer;
            if Assigned(CompEditDsg) then
              CompEditDsg.AddUndoAction(AControl, uopChange, True, 'Parent',
                                        OldContainer.Name, AContainer.Name);
            ok:=true;
            DoModified;
          except
            on E: Exception do
              MessageDlg(oisError,
                Format(oisUnableToChangeParentOfControlToNewParent,
                       [DbgSName(AControl), DbgSName(AContainer), LineEnding, E.Message]),
                mtError, [mbOk], 0);
          end;
          if not ok then break;
        end;
        SelNode := SelNode.GetNextMultiSelected;
      end;
    end
    else
    if TObject(Node.Data) is TCollectionItem then
    begin
      ACollection := TCollectionItem(Node.Data).Collection;
      ACollection.BeginUpdate;
      case InsertType of
        tvimAsNextSibling:
          NewIndex := TCollectionItem(Node.Data).Index + 1;
        tvimAsPrevSibling:
          NewIndex := TCollectionItem(Node.Data).Index;
      end;
      SelNode := GetLastMultiSelected;
      while Assigned(SelNode) do
      begin
        if (TObject(SelNode.Data) is TCollectionItem) and
           (TCollectionItem(SelNode.Data).Collection = ACollection) then
        begin
          ok := False;
          try
            AIndex := TCollectionItem(SelNode.Data).Index;
            if AIndex < NewIndex then
              TCollectionItem(SelNode.Data).Index := NewIndex - 1
            else
              TCollectionItem(SelNode.Data).Index := NewIndex;
            ok := True;
            DoModified;
          except
            on E: Exception do
              MessageDlg(E.Message, mtError, [mbOk], 0);
          end;
          if not ok then break;
        end;
        SelNode := SelNode.GetPrevMultiSelected;
      end;
      ACollection.EndUpdate;
    end;
    BuildComponentNodes(True);
  end;
  inherited DragDrop(Source, X, Y);
end;

procedure TComponentTreeView.DragOver(Source: TObject; X, Y: Integer;
  State: TDragState; var Accept: Boolean);
var
  Node: TTreeNode;
  AnObject: TObject;
  AControl: TControl absolute AnObject;
  AContainer: TPersistent;
  AcceptControl, AcceptContainer: Boolean;
  InsertType: TTreeViewInsertMarkType;
  ParentNode: TTreeNode;
  aLookupRoot: TPersistent;
begin
  //debugln('TComponentTreeView.DragOver START ',dbgs(Accept));

  AcceptContainer := False;
  AcceptControl := True;

  GetComponentInsertMarkAt(X, Y, Node, InsertType);
  SetInsertMark(Node, InsertType);

  if PropertyEditorHook<>nil then
    aLookupRoot := PropertyEditorHook.LookupRoot
  else
    aLookupRoot := nil;

  // check new parent
  ParentNode := Node;
  if InsertType in [tvimAsNextSibling, tvimAsPrevSibling] then
    ParentNode := ParentNode.Parent;
  if Assigned(ParentNode) and Assigned(ParentNode.Data) then
  begin
    AnObject := TObject(ParentNode.Data);
    if (AnObject is TWinControl) then
    begin
      if ControlAcceptsStreamableChildComponent(TWinControl(AControl),
         TComponentClass(AnObject.ClassType),aLookupRoot)
      then begin
        AContainer := TPersistent(AnObject);
        //DebugLn(['TComponentTreeView.DragOver AContainer=',DbgSName(AContainer)]);
        AcceptContainer := True;
      end;
    end
    else
    if (AnObject is TCollection) then
    begin
      // it is allowed to move container items inside the container
      AContainer := TPersistent(AnObject);
      AcceptContainer := True;
    end;
  end;

  if AcceptContainer then 
  begin
    Node := GetFirstMultiSelected;
    while Assigned(Node) and AcceptControl do
    begin
      AnObject := TObject(Node.Data);
      // don't allow to move ancestor components
      if (AnObject is TComponent) and
         (csAncestor in TComponent(AnObject).ComponentState) then break;
      if (AnObject is TControl) then
      begin
        if AnObject = AContainer then break;
        if not (AContainer is TWinControl) then break;
        //DebugLn(['TComponentTreeView.DragOver AControl=',DbgSName(AControl),' Parent=',DbgSName(AControl.Parent),' OldAccepts=',csAcceptsControls in AControl.Parent.ControlStyle]);
        // check if new parent allows this control class
        if not TWinControl(AContainer).CheckChildClassAllowed(AnObject.ClassType, False) then
          break;
        // check if one of the parent of the container is the control itself
        if AControl.IsParentOf(TWinControl(AContainer)) then break;
        // do not move children of a restricted parent to another parent
        // e.g. TPage of TPageControl
        if (AControl.Parent <> nil) and (AControl.Parent <> AContainer) and
            (not (csAcceptsControls in AControl.Parent.ControlStyle)) then
          break;
      end
      else
      if (AnObject is TCollectionItem) then
      begin
        if AnObject = AContainer then break;
        if not (AContainer is TCollection) then
          break;
        if TCollectionItem(AnObject).Collection <> TCollection(AContainer) then
          break;
      end;
      Node := Node.GetNextMultiSelected;
    end;
    AcceptControl := (Node = nil);
  end;

  Accept := AcceptContainer and AcceptControl;
  //debugln('TComponentTreeView.DragOver A ',dbgs(Accept));
  inherited DragOver(Source, X, Y, State, Accept);
  //debugln('TComponentTreeView.DragOver B ',dbgs(Accept));

  Accept := AcceptContainer and AcceptControl and ((OnDragOver=nil) or Accept);
end;

procedure TComponentTreeView.DragCanceled;
begin
  SetInsertMark(nil, tvimNone);
  inherited DragCanceled;
end;

procedure TComponentTreeView.MouseLeave;
begin
  SetInsertMark(nil,tvimNone);
  inherited MouseLeave;
end;

procedure TComponentTreeView.GetComponentInsertMarkAt(X, Y: Integer; out
  AnInsertMarkNode: TTreeNode; out AnInsertMarkType: TTreeViewInsertMarkType);
var
  Node: TTreeNode;
begin
  Node := GetFirstMultiSelected;
  if (Node <> nil) and (TObject(Node.Data) is TControl) then
  begin
    // TWinControl allows only to add/remove children, but not at a specific position
    AnInsertMarkNode := GetNodeAt(X,Y);
    AnInsertMarkType := tvimAsFirstChild;
  end
  else
  begin
    GetInsertMarkAt(X, Y, AnInsertMarkNode, AnInsertMarkType);
    if (Node <> nil) and (TObject(Node.Data) is TCollectionItem) then
      if AnInsertMarkType = tvimAsFirstChild then
        AnInsertMarkType := tvimAsPrevSibling;
  end;
end;

procedure TComponentTreeView.DoModified;
begin
  if Assigned(PropertyEditorHook) then
    PropertyEditorHook.RefreshPropertyValues;
  if Assigned(FOnModified) then
    OnModified(Self);
end;

function TComponentTreeView.GetImageFor(APersistent: TPersistent): integer;
begin
  Result := -1;
  if Assigned(APersistent) then
  begin
    if (APersistent is TControl) then begin
      if (csAcceptsControls in TControl(APersistent).ControlStyle) then
        Result := ImgIndexBox
      else
        Result := ImgIndexControl;
    end
    else
    if (APersistent is TComponent) then
      Result := ImgIndexComponent
    else
    if (APersistent is TCollection) then
      Result := ImgIndexCollection
    else
    if (APersistent is TCollectionItem) then
      Result := ImgIndexItem;
  end;
  // finally, ask the designer such as TDesignerMediator to override it, if any
  if Assigned(OnComponentGetImageIndex) then
    OnComponentGetImageIndex(APersistent, Result);
end;

procedure TComponentTreeView.SetPropertyEditorHook(AValue: TPropertyEditorHook);
begin
  if FPropertyEditorHook=AValue then exit;
  FPropertyEditorHook:=AValue;
end;

function TComponentTreeView.GetSelection: TPersistentSelectionList;
begin
  Result:=FComponentList.Selection;
end;

constructor TComponentTreeView.Create(TheOwner: TComponent);
begin
  inherited Create(TheOwner);
  DragMode := dmAutomatic;
  FComponentList:=TBackupComponentList.Create;
  FRoot2CollapasedMap:=TPointerToPointerTree.Create;
  Options := Options + [tvoAllowMultiselect, tvoAutoItemHeight, tvoKeepCollapsedNodes, tvoReadOnly];
  MultiSelectStyle := MultiSelectStyle + [msShiftSelect];
  ImgIndexForm := IDEImages.GetImageIndex('oi_form');
  ImgIndexComponent := IDEImages.GetImageIndex('oi_comp');
  ImgIndexControl := IDEImages.GetImageIndex('oi_control');
  ImgIndexBox := IDEImages.GetImageIndex('oi_box');
  ImgIndexCollection := IDEImages.GetImageIndex('oi_collection');
  ImgIndexItem := IDEImages.GetImageIndex('oi_item');
  Images := IDEImages.Images_16;
end;

destructor TComponentTreeView.Destroy;
var
  Enumer: TPointerToPointerEnumerator;
begin
  Enumer := FRoot2CollapasedMap.GetEnumerator;
  while Enumer.MoveNext do
    FreeAndNil(TObject(Enumer.Current^.Value)); // Free the CollapsedComp TAVLTrees.
  Enumer.Free;
  FreeThenNil(FRoot2CollapasedMap);
  FreeThenNil(FComponentList);
  inherited Destroy;
end;

procedure TComponentTreeView.NodeCollapsed(Sender: TObject; Node: TTreeNode);
begin
  Assert(Assigned(FCollapsedComps), 'TComponentTreeView.NodeCollapsed: FCollapsedComps=Nil.');
  FCollapsedComps.Add(Node.Data);
end;

procedure TComponentTreeView.NodeExpanded(Sender: TObject; Node: TTreeNode);
begin
  Assert(Assigned(FCollapsedComps), 'TComponentTreeView.NodeExpanded: FCollapsedComps=Nil.');
  if not FCollapsedComps.Remove(Node.Data) then
    DebugLn(['TComponentTreeView.NodeExpanded: Removing node ', TPersistent(Node.Data), ' failed.']);
end;

function TComponentTreeView.AddOrGetPersNode(AParentNode: TTreeNode;
  APers: TPersistent; ACapt: String): TTreeNode;
var
  xNode: TTreeNode;
begin
  if not FDrawWholeTree then
  begin
    if AParentNode = nil then
      Exit(Items.GetFirstNode);   // Return existing root node.
    // Search for an existing valid node.
    xNode := AParentNode.GetFirstChild;
    while (xNode<>nil) and (TObject(xNode.Data)<>APers) do
      xNode := xNode.GetNextSibling;
    if Assigned(xNode) then
      Exit(xNode);                // Return existing node if there is one.
  end;
  // Add a new node and set its properties.
  Result := Items.AddChildObject(AParentNode, ACapt, APers);
  if AParentNode = nil then
    Result.ImageIndex := ImgIndexForm
  else
    Result.ImageIndex := GetImageFor(APers);
  Result.SelectedIndex := Result.ImageIndex;
  Result.MultiSelected := Selection.IndexOf(APers) >= 0;
end;

procedure TComponentTreeView.AddChildren(AComponent: TComponent; ARootNode: TTreeNode);
var
  Walker: TComponentWalker;
begin
  if csDestroying in AComponent.ComponentState then exit;
  Walker := TComponentWalker.Create(Self, AComponent);
  Walker.FNode := ARootNode;
  try      // add inline components children
    TComponentAccessor(AComponent).GetChildren(@Walker.Walk, AComponent);
  finally
    Walker.Free;
  end;
end;

function TComponentTreeView.GetRootObject: TPersistent;
// Get root object / component
begin
  if PropertyEditorHook = nil then Exit(nil);
  Result := PropertyEditorHook.LookupRoot;
  if (Result is TComponent) and (csDestroying in TComponent(Result).ComponentState) then
    Result := nil;
end;

procedure TComponentTreeView.BuildComponentNodes(AWholeTree: Boolean);
// Add all components to the tree.
// AWholeTree=True means clearing and refilling all,
//       False means existing tree is used and only missing components are added.
var
  RootObject: TPersistent;
  RootNode: TTreeNode;
begin
  OnCollapsed:=nil;     // Don't handle these events while the tree builds.
  OnExpanded:=nil;
  BeginUpdate;
  RootObject := GetRootObject;
  if AWholeTree then
    Items.Clear;
  if RootObject <> nil then
  begin
    //DebugLn(['TComponentTreeView.BuildComponentNodes: RootObj=', RootObject, ', AWholeTree=', AWholeTree]);
    FDrawWholeTree := AWholeTree;
    // first add the lookup root
    RootNode := AddOrGetPersNode(nil, RootObject, CreateNodeCaption(RootObject,''));
    // add components in creation order and TControl.Parent relationship
    if RootObject is TComponent then
      AddChildren(TComponent(RootObject), RootNode);
    if AWholeTree then
    begin
      // Get the right list of collapsed nodes based on LookupRoot
      FCollapsedComps := TAVLTree(FRoot2CollapasedMap[RootObject]);
      if FCollapsedComps = nil then
      begin
        FCollapsedComps := TAVLTree.Create;
        FRoot2CollapasedMap[RootObject] := FCollapsedComps;
      end;
    end;
    RestoreExpand(RootNode);     // then restore the Expanded/Collapsed state.
    MakeSelectionVisible;
  end;
  EndUpdate;
  OnCollapsed:=@NodeCollapsed;
  OnExpanded:=@NodeExpanded;
end;

procedure TComponentTreeView.RestoreExpand(ANode: TTreeNode);
// Restore Expanded/Collapsed state based on user's choice from last time.
begin
  ANode.Expanded := FCollapsedComps.Find(ANode.Data) = Nil; // Nil means a user
  ANode := ANode.GetFirstChild;           // did not collapse the node last time.
  while ANode<>nil do begin
    RestoreExpand(ANode);           // Recursive call.
    ANode := ANode.GetNextSibling;
  end;
end;

procedure TComponentTreeView.ChangeNode(ANode: TTreeNode);
// Change ZOrder of the given node or delete it.
var
  Neighbor: TTreeNode;
begin
  case FZOrderDelCommand of
    zoToFront: begin              // Front means the last sibling.
      Neighbor := ANode.GetLastSibling;
      if Assigned(Neighbor) then
        ANode.MoveTo(Neighbor, naInsertBehind);
    end;
    zoToBack: begin               // Back means the first sibling.
      Neighbor := ANode.GetFirstSibling;
      if Assigned(Neighbor) then
        ANode.MoveTo(Neighbor, naInsert);
    end;
    zoForward: begin              // Towards the end.
      Neighbor := ANode.GetNextSibling;
      if Assigned(Neighbor) then
        ANode.MoveTo(Neighbor, naInsertBehind);
    end;
    zoBackward: begin             // Towards the beginning.
      Neighbor := ANode.GetPrevSibling;
      if Assigned(Neighbor) then
        ANode.MoveTo(Neighbor, naInsert);
    end;
    zoDelete: ANode.Delete;       // Delete the node
  end;
end;

function TComponentTreeView.IterateTree(ANode: TTreeNode; APers: TPersistent): TTreeNode;
// Returns the node that was changed.
begin
  Result := Nil;
  if TObject(ANode.Data)=APers then
  begin
    ChangeNode(ANode);
    Exit(ANode);                         // Found and changed.
  end;
  // Iterate subnodes.
  ANode := ANode.GetFirstChild;
  while Assigned(ANode) and (Result=Nil) do
  begin
    Result := IterateTree(ANode, APers); // Recursive call.
    ANode := ANode.GetNextSibling;
  end;
end;

function TComponentTreeView.FindAndChange(APers: TPersistent;
  AZOrderDel: TZOrderDelete): Boolean;
// APers is Component to be moved or deleted based on AZOrderDel value.
var
  ChangedNode: TTreeNode;
begin
  // Search for a node to change.
  Assert(Assigned(APers), 'TComponentTreeView.FindAndChangeItem: APers=Nil.');
  Assert(Items.GetFirstNode.GetNextSibling=Nil,
         'TComponentTreeView.FindAndChange: Top node has siblings.');
  FZOrderDelCommand := AZOrderDel;
  ChangedNode := IterateTree(Items.GetFirstNode, APers);
  Result := Assigned(ChangedNode);
end;

procedure TComponentTreeView.ChangeCompZOrder(APersistent: TPersistent;
  AZOrder: TZOrderDelete);
begin
  if not FindAndChange(APersistent, AZOrder) then
    DebugLn(['TComponentTreeView.ChangeCompZOrder failed.']);
end;

procedure TComponentTreeView.DeleteComponentNode(APersistent: TPersistent);
begin
  if FPreviousDeleted = APersistent then
    FPreviousDeleted := Nil     // Don't try to delete the same component twice.
  else begin
    FPreviousDeleted := APersistent;
    //FindAndChange(APersistent, zoDelete); // Does not work with CollectionItems.
    // Now rebuild the tree. ToDo: use TCollectionObserver, IFPObserver interface.
    BuildComponentNodes(True);
  end;
end;

procedure TComponentTreeView.UpdateCompNode(ANode: TTreeNode);
var
  APersistent: TPersistent;
begin
  if ANode = nil then Exit;
  APersistent := TPersistent(ANode.Data);
  if APersistent is TComponent then
    ANode.Text := ComponentCaption(TComponent(APersistent))
  else if APersistent is TCollectionItem then
    ANode.Text := CollectionItemCaption(TCollectionItem(APersistent));
  // Note: Collection name does not change, don't update.

  UpdateCompNode(ANode.GetFirstChild);    // Recursive call.
  UpdateCompNode(ANode.GetNextSibling);
end;

procedure TComponentTreeView.UpdateComponentNodesValues;
// Could be optimised by adding a PropName parameter and searching a node by name.
begin
  BeginUpdate;
  UpdateCompNode(Items.GetFirstNode);
  EndUpdate;
end;

procedure TComponentTreeView.UpdateSelNode(ANode: TTreeNode);
var
  APersistent: TPersistent;
begin
  if ANode = nil then Exit;
  APersistent := TPersistent(ANode.Data);
  ANode.MultiSelected := Selection.IndexOf(APersistent) >= 0;
  UpdateSelNode(ANode.GetFirstChild);     // Recursive call.
  UpdateSelNode(ANode.GetNextSibling);
end;

procedure TComponentTreeView.UpdateSelected;
begin
  BeginUpdate;
  Selected := Nil;
  UpdateSelNode(Items.GetFirstNode);
  EndUpdate;
end;

end.

