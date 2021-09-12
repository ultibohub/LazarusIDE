unit AddPkgDependencyDlg;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Laz_AVL_Tree, fgl,
  // LCL
  LCLType, LCLIntf, Forms, Controls, Dialogs, StdCtrls, ButtonPanel, Graphics, ExtCtrls,
  // LazControls
  ListFilterEdit,
  // LazUtils
  LazLoggerBase,
  // BuildIntf
  PackageIntf, PackageLinkIntf, PackageDependencyIntf,
  // IDEIntf
  IDEWindowIntf, IDEDialogs,
  // IDE
  MainIntf, LazarusIDEStrConsts, PackageDefs, PackageSystem, ProjPackCommon, ProjPackChecks;

type

  TPkgDependencyList = specialize TFPGList<TPkgDependency>;

  { TAddPkgDependencyDialog }

  TAddPkgDependencyDialog = class(TForm)
    BP: TButtonPanel;
    cbLocalPkg: TCheckBox;
    cbOnlinePkg: TCheckBox;
    DependMaxVersionEdit: TEdit;
    DependMaxVersionLabel: TLabel;
    DependMinVersionEdit: TEdit;
    DependMinVersionLabel: TLabel;
    DependPkgNameFilter: TListFilterEdit;
    DependPkgNameLabel: TLabel;
    DependPkgTypeLabel: TLabel;
    DependPkgNameListBox: TListBox;
    pnLocalPkg: TPanel;
    pnOnlinePkg: TPanel;
    procedure cbLocalPkgChange(Sender: TObject);
    procedure cbOnlinePkgChange(Sender: TObject);
    procedure CloseButtonClick(Sender: TObject);
    procedure DependPkgNameListBoxDrawItem(Control: TWinControl;
      Index: Integer; ARect: TRect; State: TOwnerDrawState);
    procedure DependPkgNameListBoxMeasureItem(Control: TWinControl;
      Index: Integer; var AHeight: Integer);
    procedure DependPkgNameListBoxSelectionChange(Sender: TObject; {%H-}User: boolean);
    procedure FormClose(Sender: TObject; var {%H-}CloseAction: TCloseAction);
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure OKButtonClick(Sender: TObject);
    function InstallOnlinePackages: TModalResult;
  private
    fUpdating: Boolean;
    fPackages: TAVLTree;    // tree of TLazPackage or TPackageLink.
    fProjPack: IProjPack;   // Project or package, a recipient of the dependency.
    fResultDependencies: TPkgDependencyList;
    procedure AddUniquePackagesToList(APackageID: TLazPackageID);
    procedure UpdateAvailableDependencyNames;
    function IsInstallButtonVisible: Boolean;
    procedure PackageListAvailable(Sender: TObject);
  public
    constructor Create(TheOwner: TComponent); override;
    destructor Destroy; override;
  end;

var
  AddPkgDependencyDialog: TAddPkgDependencyDialog;

function ShowAddPkgDependencyDlg(AProjPack: IProjPack;
  out AResultDependencies: TPkgDependencyList): TModalResult;

implementation

{$R *.lfm}

function ShowAddPkgDependencyDlg(AProjPack: IProjPack;
  out AResultDependencies: TPkgDependencyList): TModalResult;
var
  AddDepDialog: TAddPkgDependencyDialog;
begin
  AddDepDialog:=TAddPkgDependencyDialog.Create(nil);
  AddDepDialog.fProjPack:=AProjPack;
  AddDepDialog.UpdateAvailableDependencyNames;

  Result:=AddDepDialog.ShowModal;
  if Result=mrOk then begin
    AResultDependencies:=AddDepDialog.fResultDependencies;
    AddDepDialog.fResultDependencies:=nil;
  end else begin
    AResultDependencies:=nil;
  end;
  AddDepDialog.Free;
end;

{ TAddPkgDependencyDialog }

constructor TAddPkgDependencyDialog.Create(TheOwner: TComponent);
begin
  inherited Create(TheOwner);
  Caption:=lisProjAddNewRequirement;
  fPackages:=TAVLTree.Create(@CompareLazPackageIDNames);

  DependPkgNameLabel.Caption:=lisProjAddPackageName;
  DependPkgTypeLabel.Caption:=lisProjAddPackageType;
  cbLocalPkg.Caption:=lisProjAddLocalPkg;
  cbOnlinePkg.Caption:=lisProjAddOnlinePkg;
  BP.CloseButton.Caption := lisPckEditInstall;
  DependMinVersionLabel.Caption:=lisProjAddMinimumVersionOptional;
  DependMinVersionEdit.Text:='';
  DependMaxVersionLabel.Caption:=lisProjAddMaximumVersionOptional;
  DependMaxVersionEdit.Text:='';

  IDEDialogLayoutList.ApplyLayout(Self,400,360);
end;

destructor TAddPkgDependencyDialog.Destroy;
begin
  FreeAndNil(fPackages);
  inherited Destroy;
end;

procedure TAddPkgDependencyDialog.FormClose(Sender: TObject; var CloseAction: TCloseAction);
begin
  IDEDialogLayoutList.SaveLayout(Self);
end;

procedure TAddPkgDependencyDialog.FormCreate(Sender: TObject);
begin
  if Assigned(OPMInterface) then
    cbOnlinePkg.Checked := OPMInterface.IsPackageListLoaded
  else begin
    DependPkgTypeLabel.Visible := False;
    pnLocalPkg.Visible := False;
    pnOnlinePkg.Visible := False;
  end;
  cbOnlinePkg.OnChange := @cbOnlinePkgChange; // Set handler after setting Checked.
  BP.CloseButton.Visible := False;            // CloseButton is now "Install".
  if OPMInterface <> nil then
    OPMInterface.AddPackageListNotification(@PackageListAvailable);
end;

procedure TAddPkgDependencyDialog.FormDestroy(Sender: TObject);
begin
  if OPMInterface <> nil then
    OPMInterface.RemovePackageListNotification(@PackageListAvailable);
end;

procedure TAddPkgDependencyDialog.DependPkgNameListBoxDrawItem(
  Control: TWinControl; Index: Integer; ARect: TRect; State: TOwnerDrawState);
var
  Txt: string;
  Pkg: TLazPackageID;
begin
  with (Control as TListBox).Canvas do
  begin
    Pkg := TLazPackageID(DependPkgNameListBox.Items.Objects[Index]);
    if odSelected In State then
    begin
      Pen.Color := clHighlightText;
      Brush.Color := clHighlight;
      if (Pkg is TPackageLink) and (TPackageLink(Pkg).Origin = ploOnline) then
        Font.Style := Font.Style + [fsBold]
    end
    else begin
      Pen.Color := (Control as TListBox).Font.Color;
      if (Pkg is TPackageLink) and (TPackageLink(Pkg).Origin = ploOnline) then
        Font.Style := Font.Style + [fsBold]
    end;
    FillRect(ARect);
    Txt := (Control as TListBox).Items[Index];
    InflateRect(ARect, -1, -1);
    inc(ARect.Left,3);
    DrawText(Handle, PChar(Txt), Length(Txt), ARect, DT_LEFT or DT_VCENTER or DT_SINGLELINE);
  end;
end;

procedure TAddPkgDependencyDialog.DependPkgNameListBoxMeasureItem(
  Control: TWinControl; Index: Integer; var AHeight: Integer);
begin
  inc(AHeight, 3);   // Compensate InflateRect in DrawItem, and nicer centering
end;

function TAddPkgDependencyDialog.IsInstallButtonVisible: Boolean;
var
  I: Integer;
  Pkg: TLazPackageID;
begin
  for I := 0 to DependPkgNameListBox.Count - 1 do
  begin
    if DependPkgNameListBox.Selected[I] then
    begin
      Pkg := TLazPackageID(DependPkgNameListBox.Items.Objects[I]);
      if (Pkg is TPackageLink) and (TPackageLink(Pkg).Origin = ploOnline) then
        Exit(True);
    end;
  end;
  Result := False;
end;

procedure TAddPkgDependencyDialog.PackageListAvailable(Sender: TObject);
begin
  DebugLn(['TAddPkgDependencyDialog.PackageListAvailable: ', fProjPack.IDAsString]);
  UpdateAvailableDependencyNames;
end;

procedure TAddPkgDependencyDialog.DependPkgNameListBoxSelectionChange(
  Sender: TObject; User: boolean);
begin
  BP.CloseButton.Visible := IsInstallButtonVisible;
  BP.OKButton.Enabled := not BP.CloseButton.Visible;
end;

procedure TAddPkgDependencyDialog.cbLocalPkgChange(Sender: TObject);
begin
  UpdateAvailableDependencyNames;
end;

procedure TAddPkgDependencyDialog.cbOnlinePkgChange(Sender: TObject);
begin
  Assert(Assigned(OPMInterface), 'TAddPkgDependencyDialog: OPMInterface=Nil.');
  if (Sender as TCheckBox).Checked and not OPMInterface.IsPackageListLoaded then
    OPMInterface.GetPackageList  // ListBox will be updated later by an event.
  else
    UpdateAvailableDependencyNames;
end;

function TAddPkgDependencyDialog.InstallOnlinePackages: TModalResult;
var
  I: Integer;
  Pkg: TLazPackageID;
  PkgList: TList;
begin
  Result := mrOk;
  PkgList := TList.Create;
  try
    for I := 0 to DependPkgNameListBox.Count - 1 do
    begin
      if DependPkgNameListBox.Selected[I] then
      begin
        Pkg := TLazPackageID(DependPkgNameListBox.Items.Objects[I]);
        if (Pkg is TPackageLink) and (TPackageLink(Pkg).Origin = ploOnline) then
          PkgList.Add(Pkg);
      end;
    end;
    if PkgList.Count > 0 then
    begin
      Assert(Assigned(OPMInterface), 'InstallOnlinePackages: OPMInterface=Nil');
      Result := OPMInterface.InstallPackages(PkgList);
    end;
  finally
    PkgList.Free;
  end;
end;

procedure TAddPkgDependencyDialog.CloseButtonClick(Sender: TObject);
// CloseButton is now "Install".
begin
  ModalResult := mrNone;
  case InstallOnlinePackages of
    mrCancel: Exit;
    mrRetry:   // mrRetry means the IDE must be rebuilt.
      begin
        Self.Hide;
        MainIDEInterface.DoBuildLazarus([]);
      end;
    else
      UpdateAvailableDependencyNames;
  end;
end;

procedure TAddPkgDependencyDialog.AddUniquePackagesToList(APackageID: TLazPackageID);
begin
  if (APackageID.IDAsString<>fProjPack.IDAsString) and (fPackages.Find(APackageID)=Nil) then
    fPackages.Add(APackageID);
end;

procedure TAddPkgDependencyDialog.UpdateAvailableDependencyNames;
var
  ANode: TAVLTreeNode;
  Pkg: TLazPackageID;
  CntLocalPkg: Integer;
  CntOnlinePkg: Integer;
begin
  if fUpdating then
    Exit;
  fUpdating := True;
  try
    CntLocalPkg := 0;
    CntOnlinePkg := 0;
    DependPkgNameFilter.Items.Clear;
    fPackages.Clear;
    PackageGraph.IteratePackages(fpfSearchAllExisting,@AddUniquePackagesToList);
    ANode:=fPackages.FindLowest;
    while ANode<>nil do
    begin
      Pkg := TLazPackageID(ANode.Data);
      if (Pkg is TPackageLink) and (TPackageLink(Pkg).Origin = ploOnline) then
      begin
        if cbOnlinePkg.Checked then
        begin
          Inc(CntOnlinePkg);
          DependPkgNameFilter.Items.AddObject(Pkg.Name, Pkg);
        end;
      end
      else if cbLocalPkg.Checked then
      begin
        Inc(CntLocalPkg);
        DependPkgNameFilter.Items.AddObject(Pkg.Name, Pkg);
      end;
      ANode:=fPackages.FindSuccessor(ANode);
    end;
    DependPkgNameFilter.InvalidateFilter;
    if Assigned(OPMInterface) then
    begin
      cbLocalPkg.Caption := Format(lisProjAddLocalPkg, [IntToStr(CntLocalPkg)]);
      cbOnlinePkg.Caption := Format(lisProjAddOnlinePkg, [IntToStr(CntOnlinePkg)]);
      BP.CloseButton.Visible := IsInstallButtonVisible;
    end;
  finally
    fUpdating := False;
  end;
end;

procedure TAddPkgDependencyDialog.OKButtonClick(Sender: TObject);
var
  NewDependency: TPkgDependency;
  MinVerTest, MaxVerTest: TPkgVersion;
  MinMaxVerFlags: TPkgDependencyFlags;
  i: Integer;
begin
  MinVerTest := Nil;
  MaxVerTest := Nil;
  MinMaxVerFlags := [];
  try
    // check minimum version
    if DependMinVersionEdit.Text <> '' then
    begin
      MinVerTest := TPkgVersion.Create;
      if not MinVerTest.ReadString(DependMinVersionEdit.Text) then
      begin
        IDEMessageDialog(lisProjAddInvalidVersion,
          Format(lisProjAddTheMinimumVersionIsInvalid,
                 [DependMinVersionEdit.Text, LineEnding, LineEnding]),
          mtError,[mbCancel]);
        exit;
      end;
      MinMaxVerFlags := [pdfMinVersion];
    end;
    // check maximum version
    if DependMaxVersionEdit.Text <> '' then
    begin
      MaxVerTest := TPkgVersion.Create;
      if not MaxVerTest.ReadString(DependMaxVersionEdit.Text) then
      begin
        IDEMessageDialog(lisProjAddInvalidVersion,
          Format(lisProjAddTheMaximumVersionIsInvalid,
                 [DependMaxVersionEdit.Text, LineEnding, LineEnding]),
          mtError,[mbCancel]);
        exit;
      end;
      MinMaxVerFlags := MinMaxVerFlags + [pdfMaxVersion];
    end;

    // Add all selected packages.
    fResultDependencies := TPkgDependencyList.Create; // Will be freed by the caller.
    if DependPkgNameListBox.SelCount > 0 then
    begin
      for i := 0 to DependPkgNameListBox.Count-1 do
      begin
        if DependPkgNameListBox.Selected[i] then
        begin
          NewDependency := TPkgDependency.Create;   // Will be added to package graph.
          NewDependency.PackageName := DependPkgNameListBox.Items[i];
          if Assigned(MinVerTest) then
            NewDependency.MinVersion.Assign(MinVerTest);
          if Assigned(MaxVerTest) then
            NewDependency.MaxVersion.Assign(MaxVerTest);
          NewDependency.Flags := NewDependency.Flags + MinMaxVerFlags;
          if not CheckAddingDependency(fProjPack, NewDependency) then exit;
          fResultDependencies.Add(NewDependency);
          NewDependency := nil;
        end;
      end;
    end;
    ModalResult := mrOk;
  finally
    MinVerTest.Free;
    MaxVerTest.Free;
  end;
end;

end.

