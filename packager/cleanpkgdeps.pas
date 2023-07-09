{
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

  Author: Mattias Gaertner

  Abstract: Dialog to show all not needed package dependencies.
    At the moment it shows dependencies that exists already through other
    packages. For example using LCL automatically uses LazUtils, so LazUtils
    will be shown as not needed.
}
unit CleanPkgDeps;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Contnrs, AVL_Tree,
  // LCL
  Forms, Controls, ComCtrls, ExtCtrls, StdCtrls, Buttons,
  // IdeIntf
  IDEImagesIntf,
  // IDE
  LazarusIDEStrConsts, Project, PackageDefs;

const
  CPDProjectName = '-Project-';
type

  { TCPDNodeInfo }

  TCPDNodeInfo = class
  public
    Owner: string; // CPDProjectName or package name
    Dependency: string; // required package name
  end;

  { TCleanPkgDepsDlg }

  TCleanPkgDepsDlg = class(TForm)
    CancelBitBtn: TBitBtn;
    DeleteSelectedBitBtn: TBitBtn;
    BtnPanel: TPanel;
    SelectAllBitBtn: TBitBtn;
    SelectNoneBitBtn: TBitBtn;
    TransitivityLabel: TLabel;
    TransitivityTreeView: TTreeView;
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure SelectAllBitBtnClick(Sender: TObject);
    procedure SelectNoneBitBtnClick(Sender: TObject);
    procedure TransitivityTreeViewMouseDown(Sender: TObject;
      {%H-}Button: TMouseButton; {%H-}Shift: TShiftState; X, Y: Integer);
  private
    function GetTVNodeChecked(TVNode: TTreeNode): boolean;
    procedure SetTVNodeChecked(TVNode: TTreeNode; AValue: boolean);
  private
    FOwners: TFPList;
    ImgIndexProject: integer;
    ImgIndexPackage: integer;
    ImgIndexDelete: integer;
    ImgIndexKeep: integer;
    procedure SetOwners(AValue: TFPList);
    procedure ClearTreeData;
    procedure UpdateTransitivityTree;
    procedure UpdateButtons;
    procedure AddTransitivities(DepOwner: TObject; ImgIndex: integer;
      FirstDependency: TPkgDependency);
    function FindAlternativeRoute(Dependency, StartDependency: TPkgDependency): TFPList;
    property TVNodeChecked[TVNode: TTreeNode]: boolean read GetTVNodeChecked write SetTVNodeChecked;
    function GetDepOwnerName(DepOwner: TObject; WithVersion: boolean): string;
  public
    property Owners: TFPList read FOwners write SetOwners;
    function FetchDeletes: TObjectList; // list of TCPDNodeInfo
  end;

var
  CleanPkgDepsDlg: TCleanPkgDepsDlg;

function ShowCleanPkgDepDlg(Pkg: TLazPackage; out ListOfNodeInfos: TObjectList): TModalResult;
function ShowCleanPkgDepDlg(AProject: TProject; out ListOfNodeInfos: TObjectList): TModalResult;
function ShowCleanPkgDepDlg(Owners: TFPList; FreeOwners: boolean;
  out ListOfNodeInfos: TObjectList): TModalResult;

implementation

function ShowCleanPkgDepDlg(Pkg: TLazPackage; out ListOfNodeInfos: TObjectList): TModalResult;
var
  Owners: TFPList;
begin
  Owners:=TFPList.Create;
  Owners.Add(Pkg);
  Result:=ShowCleanPkgDepDlg(Owners,true,ListOfNodeInfos);
end;

function ShowCleanPkgDepDlg(AProject: TProject;
  out ListOfNodeInfos: TObjectList): TModalResult;
var
  Owners: TFPList;
begin
  Owners:=TFPList.Create;
  Owners.Add(AProject);
  Result:=ShowCleanPkgDepDlg(Owners,true,ListOfNodeInfos);
end;

function ShowCleanPkgDepDlg(Owners: TFPList; FreeOwners: boolean;
  out ListOfNodeInfos: TObjectList): TModalResult;
var
  Dlg: TCleanPkgDepsDlg;
begin
  ListOfNodeInfos:=nil;
  Dlg:=TCleanPkgDepsDlg.Create(nil);
  try
    Dlg.Owners:=Owners;
    Result:=Dlg.ShowModal;
    if Result=mrOk then
      ListOfNodeInfos:=Dlg.FetchDeletes;
  finally
    if FreeOwners then
      Owners.Free;
    Dlg.Free;
  end;
end;

{$R *.lfm}

{ TCleanPkgDepsDlg }

procedure TCleanPkgDepsDlg.FormCreate(Sender: TObject);
begin
  ImgIndexProject          := IDEImages.LoadImage('item_project');
  ImgIndexPackage          := IDEImages.LoadImage('item_package');
  ImgIndexDelete           := IDEImages.LoadImage('laz_delete');
  ImgIndexKeep             := IDEImages.LoadImage('menu_run');

  Caption:=lisPkgCleanUpPackageDependencies;
  TransitivityLabel.Caption:=
    lisPkgTheFollowingDependenciesAreNotNeededBecauseOfTheAu;
  TransitivityTreeView.Images:=IDEImages.Images_16;

  SelectAllBitBtn.Caption:=lisMenuSelectAll;
  SelectNoneBitBtn.Caption:=lisPkgClearSelection;
  DeleteSelectedBitBtn.Caption:=lisPkgDeleteDependencies;
end;

procedure TCleanPkgDepsDlg.FormDestroy(Sender: TObject);
begin
  ClearTreeData;
end;

procedure TCleanPkgDepsDlg.SelectAllBitBtnClick(Sender: TObject);
var
  i: Integer;
begin
  for i:=0 to TransitivityTreeView.Items.Count-1 do
    TVNodeChecked[TransitivityTreeView.Items[i]]:=true;
end;

procedure TCleanPkgDepsDlg.SelectNoneBitBtnClick(Sender: TObject);
var
  i: Integer;
begin
  for i:=0 to TransitivityTreeView.Items.Count-1 do
    TVNodeChecked[TransitivityTreeView.Items[i]]:=false;
end;

procedure TCleanPkgDepsDlg.TransitivityTreeViewMouseDown(Sender: TObject;
  Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
var
  TVNode: TTreeNode;
begin
  TVNode:=TransitivityTreeView.GetNodeAt(X,Y);
  if TVNode=nil then exit;
  if X>=TVNode.DisplayIconLeft then begin
    TVNodeChecked[TVNode]:=not TVNodeChecked[TVNode];
  end;
end;

function TCleanPkgDepsDlg.GetTVNodeChecked(TVNode: TTreeNode): boolean;
begin
  Result:=(TVNode<>nil) and (TVNode.Data<>nil) and (TVNode.ImageIndex=ImgIndexDelete);
end;

procedure TCleanPkgDepsDlg.SetTVNodeChecked(TVNode: TTreeNode; AValue: boolean);
begin
  if TVNode.Data=nil then exit;
  if TVNodeChecked[TVNode]=AValue then exit;
  if AValue then
    TVNode.ImageIndex:=ImgIndexDelete
  else
    TVNode.ImageIndex:=ImgIndexKeep;
  TVNode.SelectedIndex:=TVNode.ImageIndex;
  UpdateButtons;
end;

procedure TCleanPkgDepsDlg.SetOwners(AValue: TFPList);
begin
  if FOwners=AValue then Exit;
  FOwners:=AValue;
  UpdateTransitivityTree;
  UpdateButtons;
end;

procedure TCleanPkgDepsDlg.ClearTreeData;
var
  i: Integer;
  TVNode: TTreeNode;
begin
  for i:=0 to TransitivityTreeView.Items.Count-1 do begin
    TVNode:=TransitivityTreeView.Items[i];
    if TVNode.Data<>nil then begin
      TObject(TVNode.Data).Free;
      TVNode.Data:=nil;
    end;
  end;
end;

procedure TCleanPkgDepsDlg.UpdateTransitivityTree;
var
  i: Integer;
  CurOwner: TObject;
  AProject: TProject;
  APackage: TLazPackage;
begin
  TransitivityTreeView.BeginUpdate;
  ClearTreeData;
  TransitivityTreeView.Items.Clear;
  for i:=0 to Owners.Count-1 do begin
    CurOwner:=TObject(Owners[i]);
    if CurOwner is TProject then begin
      AProject:=TProject(CurOwner);
      AddTransitivities(AProject,ImgIndexProject,AProject.FirstRequiredDependency);
    end else if CurOwner is TLazPackage then begin
      APackage:=TLazPackage(CurOwner);
      AddTransitivities(APackage,ImgIndexPackage,APackage.FirstRequiredDependency);
    end;
  end;
  TransitivityTreeView.EndUpdate;
end;

procedure TCleanPkgDepsDlg.UpdateButtons;
var
  i: Integer;
  TVNode: TTreeNode;
  CheckCnt: Integer;
begin
  CheckCnt:=0;
  for i:=0 to TransitivityTreeView.Items.Count-1 do begin
    TVNode:=TransitivityTreeView.Items[i];
    if TVNodeChecked[TVNode] then
      CheckCnt+=1;
  end;
  DeleteSelectedBitBtn.Enabled:=CheckCnt>0;
end;

procedure TCleanPkgDepsDlg.AddTransitivities(DepOwner: TObject; ImgIndex: integer;
  FirstDependency: TPkgDependency);
var
  Dependency: TPkgDependency;
  AltRoute: TFPList;
  MainTVNode: TTreeNode;
  TVNode: TTreeNode;
  Info: TCPDNodeInfo;
  s: String;
  i: Integer;
begin
  MainTVNode:=nil;
  Dependency:=FirstDependency;
  while Dependency<>nil do begin
    AltRoute:=FindAlternativeRoute(Dependency,FirstDependency);
    if AltRoute<>nil then begin
      if MainTVNode=nil then begin
        MainTVNode:=TransitivityTreeView.Items.Add(nil,GetDepOwnerName(DepOwner,true));
        MainTVNode.ImageIndex:=ImgIndex;
        MainTVNode.SelectedIndex:=MainTVNode.ImageIndex;
      end;
      s:=Dependency.AsString+' = ';
      for i:=0 to AltRoute.Count-1 do begin
        if i>0 then
          s+='-';
        s+=TLazPackage(AltRoute[i]).Name;
      end;
      TVNode:=TransitivityTreeView.Items.AddChild(MainTVNode,s);
      TVNode.ImageIndex:=ImgIndexDelete;
      TVNode.SelectedIndex:=TVNode.ImageIndex;
      Info:=TCPDNodeInfo.Create;
      TVNode.Data:=Info;
      Info.Owner:=GetDepOwnerName(DepOwner,false);
      Info.Dependency:=Dependency.RequiredPackage.Name;
      MainTVNode.Expand(true);
      AltRoute.Free;
    end;
    Dependency:=Dependency.NextRequiresDependency;
  end;
end;

function TCleanPkgDepsDlg.FindAlternativeRoute(Dependency,
  StartDependency: TPkgDependency): TFPList;
var
  Visited: TAvlTree;

  function Search(Pkg: TLazPackage; Level: integer; var AltRoute: TFPList): boolean;
  var
    CurDependency: TPkgDependency;
  begin
    Result:=false;
    if Pkg=nil then exit;
    if Pkg=Dependency.Owner then exit; // cycle detected
    if (Level>0) and (Pkg=Dependency.RequiredPackage) then begin
      // alternative route found
      AltRoute:=TFPList.Create;
      AltRoute.Add(Pkg);
      exit(true);
    end;

    if Visited.Find(Pkg)<>nil then exit;
    Visited.Add(Pkg);
    CurDependency:=Pkg.FirstRequiredDependency;
    while CurDependency<>nil do begin
      if Search(CurDependency.RequiredPackage,Level+1,AltRoute) then begin
        AltRoute.Insert(0,Pkg);
        exit(true);
      end;
      CurDependency:=CurDependency.NextRequiresDependency;
    end;
  end;

var
  CurDependency: TPkgDependency;
begin
  Result:=nil;
  if Dependency=nil then exit;
  if Dependency.RequiredPackage=nil then exit;
  Visited:=TAvlTree.Create;
  try
    CurDependency:=StartDependency;
    while CurDependency<>nil do begin
      if CurDependency<>Dependency then
        if Search(CurDependency.RequiredPackage,0,Result) then exit;
      CurDependency:=CurDependency.NextRequiresDependency;
    end;
  finally
    Visited.Free;
  end;
end;

function TCleanPkgDepsDlg.GetDepOwnerName(DepOwner: TObject; WithVersion: boolean
  ): string;
begin
  if DepOwner is TProject then
    Result:=CPDProjectName
  else if DepOwner is TLazPackage then begin
    if WithVersion then
      Result:=TLazPackage(DepOwner).IDAsString
    else
      Result:=TLazPackage(DepOwner).Name;
  end
  else
    Result:='';
end;

function TCleanPkgDepsDlg.FetchDeletes: TObjectList;
var
  i: Integer;
  TVNode: TTreeNode;
  Info: TCPDNodeInfo;
begin
  Result:=TObjectList.Create(true);
  for i:=0 to TransitivityTreeView.Items.Count-1 do begin
    TVNode:=TransitivityTreeView.Items[i];
    if TVNodeChecked[TVNode] and (TObject(TVNode.Data) is TCPDNodeInfo) then begin
      Info:=TCPDNodeInfo(TVNode.Data);
      TVNode.Data:=nil;
      Result.Add(Info);
    end;
  end;
end;

end.

