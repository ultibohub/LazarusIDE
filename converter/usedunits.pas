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

  Author: Juha Manninen

  Abstract:
    Takes care of converting Uses section, adding, removing and replacing unit names.
    Part of Delphi converter.
}
unit UsedUnits;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, AVL_Tree,
  // LCL
  Forms, Controls,
  // LazUtils
  LazFileUtils, AvgLvlTree,
  // codetools
  StdCodeTools, CodeTree, CodeAtom, CodeCache,
  LinkScanner, KeywordFuncLists, SourceChanger, CodeToolsStrConsts,
  // IDE + IdeIntf
  LazarusIDEStrConsts, IDEExternToolIntf,
  // Converter
  ConverterTypes, ConvCodeTool, ConvertSettings, ReplaceNamesUnit;

type

  TUsedUnitsTool = class;

  { TUsedUnits }

  TUsedUnits = class
  private
    fCTLink: TCodeToolLink;              // Link to codetools.
    fOwnerTool: TUsedUnitsTool;
    fUsesSection: TUsesSection;          // Enum used by some codetools funcs.
    fExistingUnits: TStringList;         // List of units before conversion.
    fUnitsToAdd: TStringList;            // List of new units to add.
    fUnitsToAddForLCL: TStringList;      // List of new units for LCL (not for Delphi).
    fUnitsToRemove: TStringList;         // List of units to remove.
    fUnitsToRename: TStringToStringTree; // Units to rename. Map old name -> new name.
    fUnitsToRenameKeys: TStringList;     // List of keys of the above map.
    fUnitsToRenameVals: TStringList;     // List of values of the above map.
    fUnitsToFixCase: TStringToStringTree;// Like rename but done for every target.
    fUnitsToComment: TStringList;        // List of units to be commented.
    fMissingUnits: TStringList;          // Units not found in search path.
    function FindMissingUnits: boolean;
    procedure ToBeRenamedOrRemoved(AOldName, ANewName: string);
    procedure FindReplacement(AUnitUpdater: TStringMapUpdater;
                              AMapToEdit: TStringToStringTree);
    function AddDelphiAndLCLSections: Boolean;
    function RemoveUnits: boolean;
  protected
    // This is either the Interface or Implementation node.
    function ParentBlockNode: TCodeTreeNode; virtual; abstract;
    // Uses node in either Main or Implementation section.
    function UsesSectionNode: TCodeTreeNode; virtual; abstract;
    procedure ParseToUsesSectionEnd; virtual; abstract;
  public
    constructor Create(ACTLink: TCodeToolLink; aOwnerTool: TUsedUnitsTool);
    destructor Destroy; override;
    procedure CommentAutomatic(ACommentedUnits: TStringList);
    procedure OmitUnits;
  public
    property UnitsToRemove: TStringList read fUnitsToRemove;
    property UnitsToRename: TStringToStringTree read fUnitsToRename;
    property UnitsToFixCase: TStringToStringTree read fUnitsToFixCase;
    property MissingUnits: TStringList read fMissingUnits;
  end;

  { TMainUsedUnits }

  TMainUsedUnits = class(TUsedUnits)
  private
  protected
    function ParentBlockNode: TCodeTreeNode; override;
    function UsesSectionNode: TCodeTreeNode; override;
    procedure ParseToUsesSectionEnd; override;
  public
    constructor Create(ACTLink: TCodeToolLink; aOwnerTool: TUsedUnitsTool);
    destructor Destroy; override;
  end;

  { TImplUsedUnits }

  TImplUsedUnits = class(TUsedUnits)
  private
  protected
    function ParentBlockNode: TCodeTreeNode; override;
    function UsesSectionNode: TCodeTreeNode; override;
    procedure ParseToUsesSectionEnd; override;
  public
    constructor Create(ACTLink: TCodeToolLink; aOwnerTool: TUsedUnitsTool);
    destructor Destroy; override;
  end;

  { TUsedUnitsTool }

  TUsedUnitsTool = class
  private
    fCTLink: TCodeToolLink;
    fFilename: string;
    fIsMainFile: Boolean;                 // Main project / package file.
    fIsConsoleApp: Boolean;
    fMainUsedUnits: TUsedUnits;
    fImplUsedUnits: TUsedUnits;
    fOnCheckPackageDependency: TCheckUnitEvent;
    fOnCheckUnitForConversion: TCheckUnitEvent;
    function HasUnit(aUnitName: string): Boolean;
    function GetMissingUnitCount: integer;
  public
    constructor Create(ACTLink: TCodeToolLink; AFilename: string);
    destructor Destroy; override;
    function Prepare: TModalResult;
    function ConvertUsed: TModalResult;
    function Remove(aUnit: string): TModalResult;
    procedure MoveMissingToComment(aAllCommentedUnits: TStrings);
    function AddUnitImmediately(aUnitName: string): Boolean;
    function AddUnitIfNeeded(aUnitName: string): Boolean;
    function MaybeAddPackageDep(aUnitName: string): Boolean;
    function AddThreadSupport: TModalResult;
  public
    property Filename: string read fFilename;
    property IsMainFile: Boolean read fIsMainFile write fIsMainFile;
    property IsConsoleApp: Boolean read fIsConsoleApp write fIsConsoleApp;
    property MainUsedUnits: TUsedUnits read fMainUsedUnits;
    property ImplUsedUnits: TUsedUnits read fImplUsedUnits;
    property MissingUnitCount: integer read GetMissingUnitCount;
    property OnCheckPackageDependency: TCheckUnitEvent
            read fOnCheckPackageDependency write fOnCheckPackageDependency;
    property OnCheckUnitForConversion: TCheckUnitEvent
            read fOnCheckUnitForConversion write fOnCheckUnitForConversion;
  end;


implementation

function Join(AList: TStringList): string;
// Make a comma separated list from a StringList. Could be moved to a more generic place.
var
  i: Integer;
begin
  Result:='';
  for i:=0 to AList.Count-1 do
    if i<AList.Count-1 then
      Result:=Result+AList[i]+', '
    else
      Result:=Result+AList[i];
end;

{ TUsedUnits }

constructor TUsedUnits.Create(ACTLink: TCodeToolLink; aOwnerTool: TUsedUnitsTool);
var
  UsesNode: TCodeTreeNode;
begin
  inherited Create;
  fCTLink:=ACTLink;
  fOwnerTool:=aOwnerTool;
  fUnitsToAdd:=TStringList.Create;
  fUnitsToAddForLCL:=TStringList.Create;
  fUnitsToRemove:=TStringList.Create;
  fUnitsToRename:=TStringToStringTree.Create(true);
  fUnitsToRenameKeys:=TStringList.Create;
  fUnitsToRenameKeys.CaseSensitive:=false;
  fUnitsToRenameVals:=TStringList.Create;
  fUnitsToRenameVals.CaseSensitive:=false;
  fUnitsToRenameVals.Sorted:=True;
  fUnitsToFixCase:=TStringToStringTree.Create(true);
  fUnitsToComment:=TStringList.Create;
  fMissingUnits:=TStringList.Create;
  // Get existing unit names from uses section
  UsesNode:=UsesSectionNode;
  if Assigned(UsesNode) then
    fExistingUnits:=TStringList(fCTLink.CodeTool.UsesSectionToUnitnames(UsesNode))
  else
    fExistingUnits:=TStringList.Create;
  fExistingUnits.CaseSensitive:=false;
  fExistingUnits.Sorted:=True;
end;

destructor TUsedUnits.Destroy;
begin
  fExistingUnits.Free;
  fMissingUnits.Free;
  fUnitsToComment.Free;
  fUnitsToFixCase.Free;
  fUnitsToRenameVals.Free;
  fUnitsToRenameKeys.Free;
  fUnitsToRename.Free;
  fUnitsToRemove.Free;
  fUnitsToAddForLCL.Free;
  fUnitsToAdd.Free;
  inherited Destroy;
end;

function TUsedUnits.FindMissingUnits: boolean;
var
  UsesNode: TCodeTreeNode;
  InAtom, UnitNameAtom: TAtomPosition;
  CaretPos: TCodeXYPosition;
  OldUnitName, OldInFilename: String;
  NewUnitName, NewInFilename: String;
  FullFileN, LowFileN: String;
  OmitUnit: Boolean;
begin
  UsesNode:=UsesSectionNode;
  if UsesNode=nil then exit(true);
  with fCTLink do begin
    CodeTool.MoveCursorToUsesStart(UsesNode);
    repeat
      // read next unit name
      CodeTool.ReadNextUsedUnit(UnitNameAtom, InAtom);
      OldUnitName:=CodeTool.GetAtom(UnitNameAtom);
      if InAtom.StartPos>0 then
        OldInFilename:=copy(CodeTool.Src,InAtom.StartPos+1,
                            InAtom.EndPos-InAtom.StartPos-2)
      else
        OldInFilename:='';
      // find unit file
      NewUnitName:=OldUnitName;
      LowFileN:=LowerCase(NewUnitName);
      NewInFilename:=OldInFilename;
      FullFileN:=CodeTool.DirectoryCache.FindUnitSourceInCompletePath(
                                            NewUnitName,NewInFilename,True,True);
      if FullFileN<>'' then begin                         // * Unit found *
        OmitUnit := Settings.OmitProjUnits.Contains(NewUnitName);
        // Report omitted units as missing, pretend they don't exist here,
        if OmitUnit then                       // but they can have replacements.
          fMissingUnits.Add(OldUnitName)
        else begin
          if NewUnitName<>OldUnitName then begin
            // Character case differs, fix it.
            fUnitsToFixCase[OldUnitName]:=NewUnitName;
            if CodeTool.CleanPosToCaret(UnitNameAtom.StartPos, CaretPos) then
              Settings.AddLogLine(mluNote,
                Format(lisConvDelphiFixedUnitCase, [OldUnitName, NewUnitName]),
                fOwnerTool.fFilename, CaretPos.Y, CaretPos.X);
          end;
          // Report Windows specific units as missing if target is CrossPlatform.
          //  Needed if work-platform is Windows.
          if Settings.CrossPlatform and IsWinSpecificUnit(LowFileN) then
            fMissingUnits.Add(OldUnitName);
        end;
        // Check if the unit is not part of project. It will be added and converted then.
        if not fOwnerTool.IsMainFile then
          if Assigned(fOwnerTool.OnCheckUnitForConversion) then
            fOwnerTool.OnCheckUnitForConversion(FullFileN);
      end
      else begin                                          // * Unit not found *
        // Add unit to fMissingUnits, but don't add Windows specific units if target
        //  is "Windows only". Needed if work-platform is different from Windows.
        if Settings.CrossPlatform or not IsWinSpecificUnit(LowFileN) then begin
          FullFileN:=NewUnitName;
          if NewInFilename<>'' then
            FullFileN:=FullFileN+' in '''+NewInFilename+'''';
          fMissingUnits.Add(FullFileN);
        end;
      end;
      if CodeTool.CurPos.Flag=cafComma then begin
        // read next unit name
        CodeTool.ReadNextAtom;
      end else if CodeTool.CurPos.Flag=cafSemicolon then begin
        break;
      end else
        Raise EDelphiConverterError.CreateFmt(ctsStrExpectedButAtomFound,[';',CodeTool.GetAtom]);
    until false;
  end;
  Result:=true;
end;

procedure TUsedUnits.ToBeRenamedOrRemoved(AOldName, ANewName: string);
// Replace a unit name with a new name or remove it if there is no new name.
var
  sl: TStringList;
  WillRemove: Boolean;
  i: Integer;
begin
  WillRemove:=ANewName='';
  if not WillRemove then begin
    // ANewName can have comma separated list of units. Use only units that don't yet exist.
    sl:=TStringList.Create;
    try
      sl.Delimiter:=',';
      sl.DelimitedText:=ANewName;
      for i:=sl.Count-1 downto 0 do begin
        if fOwnerTool.HasUnit(sl[i]) then
          sl.Delete(i)
        else
          fOwnerTool.MaybeAddPackageDep(sl[i]);
      end;
      WillRemove:=sl.Count=0;
      if not WillRemove then begin
        // At least some new units will be used
        ANewName:=Join(sl);
        fUnitsToRename[AOldName]:=ANewName;
        fUnitsToRenameKeys.Add(AOldName);
        fUnitsToRenameVals.AddStrings(sl);
        fCTLink.Settings.AddLogLine(mluNote,
          Format(lisConvDelphiReplacedUnitInUsesSection, [AOldName, ANewName]),
          fOwnerTool.fFilename);
      end;
    finally
      sl.Free;
    end;
  end;
  if WillRemove then begin
    i:=Pos(' in ',AOldName);
    if i>1 then
      AOldName:=Copy(AOldName, 1, i-1);  // Strip the file name part.
    if fUnitsToRemove.IndexOf(AOldName)=-1 then
      fUnitsToRemove.Add(AOldName);
    fCTLink.Settings.AddLogLine(mluNote,
      Format(lisConvDelphiRemovedUnitFromUsesSection, [AOldName]),
      fOwnerTool.fFilename);
  end;
end;

procedure TUsedUnits.FindReplacement(AUnitUpdater: TStringMapUpdater;
                                     AMapToEdit: TStringToStringTree);
var
  i: integer;
  UnitN, s: string;
begin
  for i:=fMissingUnits.Count-1 downto 0 do begin
    UnitN:=fMissingUnits[i];
    if AUnitUpdater.FindReplacement(UnitN, s) then begin
      // Don't replace Windows unit with LCL units in a console application.
      if (CompareText(UnitN,'windows')=0) and fOwnerTool.IsConsoleApp then
        s:='';
      if Assigned(AMapToEdit) then
        AMapToEdit[UnitN]:=s                      // Add for interactive editing.
      else
        ToBeRenamedOrRemoved(UnitN, s);
      fMissingUnits.Delete(i);
    end;
  end;
end;

function TUsedUnits.AddDelphiAndLCLSections: Boolean;
var
  DelphiOnlyUnits: TStringList;  // Delphi specific units.
  LclOnlyUnits: TStringList;     // LCL specific units.

  function MoveToDelphi(AUnitName: string): boolean;
  var
    UsesNode: TCodeTreeNode;
  begin
    Result:=True;
    with fCTLink do begin
      ResetMainScanner;
      ParseToUsesSectionEnd;
      // Calls either FindMainUsesNode or FindImplementationUsesNode
      UsesNode:=UsesSectionNode;
      Assert(Assigned(UsesNode),
            'UsesNode should be assigned in AddDelphiAndLCLSections->MoveToDelphi');
      Result:=CodeTool.RemoveUnitFromUsesSection(UsesNode,UpperCaseStr(AUnitName),SrcCache);
    end;
    DelphiOnlyUnits.Add(AUnitName);
  end;

var
  i, InsPos: Integer;
  s: string;
  EndChar: char;
  UsesNode: TCodeTreeNode;
  ParentBlock: TCodeTreeNode;
begin
  Result:=False;
  DelphiOnlyUnits:=TStringList.Create;
  LclOnlyUnits:=TStringList.Create;
  try
    // Don't remove the unit names but add to Delphi block instead.
    for i:=0 to fUnitsToRemove.Count-1 do
      if not MoveToDelphi(fUnitsToRemove[i]) then Exit;
    fUnitsToRemove.Clear;
    // ... and don't comment the unit names either.
    for i:=0 to fUnitsToComment.Count-1 do
      if not MoveToDelphi(fUnitsToComment[i]) then Exit;
    fUnitsToComment.Clear;
    // Add replacement units to LCL block.
    for i:=0 to fUnitsToRenameKeys.Count-1 do begin
      if not MoveToDelphi(fUnitsToRenameKeys[i]) then Exit;
      LCLOnlyUnits.Add(fUnitsToRename[fUnitsToRenameKeys[i]]);
    end;
    fUnitsToRenameKeys.Clear;
    // Additional units for LCL (like Interfaces).
    LCLOnlyUnits.AddStrings(fUnitsToAddForLCL);
    fUnitsToAddForLCL.Clear;
    // Add LCL and Delphi sections for output.
    if (LclOnlyUnits.Count=0) and (DelphiOnlyUnits.Count=0) then Exit(True);
    fCTLink.ResetMainScanner;
    ParseToUsesSectionEnd;
    UsesNode:=UsesSectionNode;
    if Assigned(UsesNode) then begin      //uses section exists
      EndChar:=',';
      s:='';
      fCTLink.CodeTool.MoveCursorToUsesStart(UsesNode);
      InsPos:=fCTLink.CodeTool.CurPos.StartPos;
    end
    else begin                            //uses section does not exist
      EndChar:=';';
      s:=LineEnding;
      // ParentBlock should never be Nil. UsesNode=Nil only for implementation section.
      ParentBlock:=ParentBlockNode;
      Assert(Assigned(ParentBlock),'ParentBlock should be assigned in AddDelphiAndLCLSections');
      if ParentBlock=Nil then Exit;
      // set insert position behind interface or implementation keyword
      // TODO: what about program?
      with fCTLink.CodeTool do begin
        MoveCursorToNodeStart(ParentBlock);
        ReadNextAtom;
        InsPos:=FindLineEndOrCodeAfterPosition(CurPos.EndPos,false);
      end;
    end;
    s:=s+'{$IFnDEF FPC}'+LineEnding;
    if DelphiOnlyUnits.Count>0 then begin
      if UsesNode=Nil then
        s:=s+'uses'+LineEnding;
      s:=s+'  '+Join(DelphiOnlyUnits)+EndChar+LineEnding;
    end;
    s:=s+'{$ELSE}'+LineEnding;
    if LclOnlyUnits.Count>0 then begin
      if UsesNode=Nil then
        s:=s+'uses'+LineEnding;
      s:=s+'  '+Join(LclOnlyUnits)+EndChar+LineEnding;
    end;
    s:=s+'{$ENDIF}';
    if Assigned(UsesNode) then
      s:=s+LineEnding+'  ';
    // Now add the generated lines.
    if not fCTLink.SrcCache.Replace(gtNewLine,gtNone,InsPos,InsPos,s) then exit;
    Result:=fCTLink.SrcCache.Apply;
  finally
    LclOnlyUnits.Free;
    DelphiOnlyUnits.Free;
  end;
end;

procedure TUsedUnits.CommentAutomatic(ACommentedUnits: TStringList);
// Comment automatically all missing units that are found in predefined list.
var
  i, x: Integer;
begin
  if ACommentedUnits = Nil then Exit;
  for i:=fMissingUnits.Count-1 downto 0 do begin
    if ACommentedUnits.Find(fMissingUnits[i], x) then
    begin
      fUnitsToComment.Add(fMissingUnits[i]);
      fMissingUnits.Delete(i);
    end;
  end;
end;

procedure TUsedUnits.OmitUnits;
// Remove globally omitted units from MissingUnits.
// Those units were added to MissingUnits to find possible replacements.
var
  i: Integer;
begin
  for i:=fMissingUnits.Count-1 downto 0 do
    if fCTLink.Settings.OmitProjUnits.Contains(fMissingUnits[i]) then
      fMissingUnits.Delete(i);
end;

function TUsedUnits.RemoveUnits: boolean;
// Remove units
var
  i: Integer;
begin
  Result:=false;
  for i:=0 to fUnitsToRemove.Count-1 do
  begin
    ParseToUsesSectionEnd;
    if not fCTLink.CodeTool.RemoveUnitFromUsesSection(UsesSectionNode,
                         UpperCaseStr(fUnitsToRemove[i]), fCTLink.SrcCache) then
      exit;
  end;
  fUnitsToRemove.Clear;
  Result:=true;
end;

{ TMainUsedUnits }

constructor TMainUsedUnits.Create(ACTLink: TCodeToolLink; aOwnerTool: TUsedUnitsTool);
begin
  inherited Create(ACTLink, aOwnerTool);
  fUsesSection:=usMain;
end;

destructor TMainUsedUnits.Destroy;
begin
  inherited Destroy;
end;

function TMainUsedUnits.ParentBlockNode: TCodeTreeNode;
begin
  Result:=fCTLink.CodeTool.FindInterfaceNode;
end;

function TMainUsedUnits.UsesSectionNode: TCodeTreeNode;
var
  IsPackage: Boolean;
begin
  IsPackage := FilenameExtIn(fOwnerTool.fFilename,['.dpk','.lpk'],True);
  Result:=fCTLink.CodeTool.FindMainUsesNode(IsPackage);
end;

procedure TMainUsedUnits.ParseToUsesSectionEnd;
begin
  fCTLink.CodeTool.BuildTree(lsrMainUsesSectionEnd)
end;

{ TImplUsedUnits }

constructor TImplUsedUnits.Create(ACTLink: TCodeToolLink; aOwnerTool: TUsedUnitsTool);
begin
  inherited Create(ACTLink, aOwnerTool);
  fUsesSection:=usImplementation;
end;

destructor TImplUsedUnits.Destroy;
begin
  inherited Destroy;
end;

function TImplUsedUnits.ParentBlockNode: TCodeTreeNode;
begin
  Result:=fCTLink.CodeTool.FindImplementationNode;
end;

function TImplUsedUnits.UsesSectionNode: TCodeTreeNode;
begin
  Result:=fCTLink.CodeTool.FindImplementationUsesNode;
end;

procedure TImplUsedUnits.ParseToUsesSectionEnd;
begin
  fCTLink.CodeTool.BuildTree(lsrImplementationUsesSectionEnd);
end;

{ TUsedUnitsTool }

constructor TUsedUnitsTool.Create(ACTLink: TCodeToolLink; AFilename: string);
begin
  inherited Create;
  fCTLink:=ACTLink;
  fFilename:=AFilename;
  fIsMainFile:=False;
  fIsConsoleApp:=False;
  fCTLink.CodeTool.BuildTree(lsrEnd);
  // These will read uses sections while creating.
  fMainUsedUnits:=TMainUsedUnits.Create(ACTLink, Self);
  fImplUsedUnits:=TImplUsedUnits.Create(ACTLink, Self);
end;

destructor TUsedUnitsTool.Destroy;
begin
  fImplUsedUnits.Free;
  fMainUsedUnits.Free;
  inherited Destroy;
end;

function TUsedUnitsTool.Prepare: TModalResult;
// Find missing units and mark some of them to be replaced later.
// More units can be marked for add, remove, rename and comment during conversion.
var
  UnitUpdater: TStringMapUpdater;
  MapToEdit: TStringToStringTree;
  Node: TAVLTreeNode;
  Item: PStringToStringItem;
  UnitN, s: string;
  i: Integer;
begin
  Result:=mrOK;
  // Add unit 'Interfaces' if project uses 'Forms' and doesn't have 'Interfaces' yet.
  if fIsMainFile then begin
    if ( fMainUsedUnits.fExistingUnits.Find('forms', i)
      or fImplUsedUnits.fExistingUnits.Find('forms', i) )
    and (not fMainUsedUnits.fExistingUnits.Find('interfaces', i) )
    and (not fImplUsedUnits.fExistingUnits.Find('interfaces', i) ) then
      fMainUsedUnits.fUnitsToAddForLCL.Add('Interfaces');
  end;
  UnitUpdater:=TStringMapUpdater.Create(fCTLink.Settings.ReplaceUnits);
  try
    MapToEdit:=Nil;
    if fCTLink.Settings.UnitsReplaceMode=rlInteractive then
      MapToEdit:=TStringToStringTree.Create(false);
    fCTLink.CodeTool.BuildTree(lsrEnd);
    if not (fMainUsedUnits.FindMissingUnits and
            fImplUsedUnits.FindMissingUnits) then
      exit(mrCancel);

    // Find replacements for missing units from settings.
    fMainUsedUnits.FindReplacement(UnitUpdater, MapToEdit);
    fImplUsedUnits.FindReplacement(UnitUpdater, MapToEdit);
    if Assigned(MapToEdit) and (MapToEdit.Tree.Count>0) then begin
      // Edit, then remove or replace units.
      Result:=EditMap(MapToEdit, Format(lisConvDelphiUnitsToReplaceIn,
                                        [ExtractFileName(fFilename)]));
      if Result<>mrOK then exit;
      // Iterate the map and rename / remove.
      Node:=MapToEdit.Tree.FindLowest;
      while Node<>nil do begin
        Item:=PStringToStringItem(Node.Data);
        UnitN:=Item^.Name;
        s:=Item^.Value;
        if fMainUsedUnits.fExistingUnits.IndexOf(UnitN)<>-1 then
          fMainUsedUnits.ToBeRenamedOrRemoved(UnitN,s);
        if fImplUsedUnits.fExistingUnits.IndexOf(UnitN)<>-1 then
          fImplUsedUnits.ToBeRenamedOrRemoved(UnitN,s);
        Node:=MapToEdit.Tree.FindSuccessor(Node);
      end;
    end;
  finally
    MapToEdit.Free;      // May be Nil but who cares.
    UnitUpdater.Free;
  end;
end;

function TUsedUnitsTool.HasUnit(aUnitName: string): Boolean;
// Return True if a given unit already is used or will be used later.
var
  x: Integer;
begin
  Result := fMainUsedUnits.fExistingUnits.Find(aUnitName, x)
         or fImplUsedUnits.fExistingUnits.Find(aUnitName, x)
         or(fMainUsedUnits.fUnitsToAdd.IndexOf(aUnitName) > -1)
         or fMainUsedUnits.fUnitsToRenameVals.Find(aUnitName, x)
         or fImplUsedUnits.fUnitsToRenameVals.Find(aUnitName, x);
end;

function TUsedUnitsTool.MaybeAddPackageDep(aUnitName: string): Boolean;
// Add a dependency to a package containing the unit and open it.
// Called when the unit is not found.
// Returns True if a dependency was really added.
var
  s: String;
begin
  Result := False;
  s:='';
  if fCTLink.CodeTool.DirectoryCache.FindUnitSourceInCompletePath(aUnitName,s,True) = '' then
    if Assigned(fOnCheckPackageDependency) then
      Result := fOnCheckPackageDependency(aUnitName);
end;

function TUsedUnitsTool.ConvertUsed: TModalResult;
// Add, remove, rename and comment out unit names that were marked earlier.
var
  i: Integer;
begin
  Result:=mrCancel;
  with fCTLink do begin
    // Fix case
    if not CodeTool.ReplaceUsedUnits(fMainUsedUnits.fUnitsToFixCase, SrcCache) then exit;
    fMainUsedUnits.fUnitsToFixCase.Clear;
    if not CodeTool.ReplaceUsedUnits(fImplUsedUnits.fUnitsToFixCase, SrcCache) then exit;
    fImplUsedUnits.fUnitsToFixCase.Clear;
    // Add more units.
    with fMainUsedUnits do begin
      for i:=0 to fUnitsToAdd.Count-1 do
        if not CodeTool.AddUnitToSpecificUsesSection(
                          fUsesSection, fUnitsToAdd[i], '', SrcCache) then exit;
      fUnitsToAdd.Clear;
    end;
    with fImplUsedUnits do begin
      for i:=0 to fUnitsToAdd.Count-1 do
        if not CodeTool.AddUnitToSpecificUsesSection(
                          fUsesSection, fUnitsToAdd[i], '', SrcCache) then exit;
      fUnitsToAdd.Clear;
    end;
    if fIsMainFile or not Settings.SupportDelphi then begin
      // One way conversion (or main file) -> remove and rename units.
      if not fMainUsedUnits.RemoveUnits then exit;    // Remove
      if not fImplUsedUnits.RemoveUnits then exit;
      // Rename
      if not CodeTool.ReplaceUsedUnits(fMainUsedUnits.fUnitsToRename, SrcCache) then exit;
      fMainUsedUnits.fUnitsToRename.Clear;
      if not CodeTool.ReplaceUsedUnits(fImplUsedUnits.fUnitsToRename, SrcCache) then exit;
      fImplUsedUnits.fUnitsToRename.Clear;
    end;
    if Settings.SupportDelphi then begin
      // Support Delphi. Add IFDEF blocks for units.
      if not fMainUsedUnits.AddDelphiAndLCLSections then exit;
      if not fImplUsedUnits.AddDelphiAndLCLSections then exit;
    end
    else begin // Lazarus only multi- or single-platform -> comment out units if needed.
      if fMainUsedUnits.fUnitsToComment.Count+fImplUsedUnits.fUnitsToComment.Count > 0 then
      begin
        CodeTool.BuildTree(lsrInitializationStart);
        if fMainUsedUnits.fUnitsToComment.Count > 0 then
          if not CodeTool.CommentUnitsInUsesSection(fMainUsedUnits.fUnitsToComment,
            SrcCache, CodeTool.FindMainUsesNode) then exit;
        if fImplUsedUnits.fUnitsToComment.Count > 0 then
          if not CodeTool.CommentUnitsInUsesSection(fImplUsedUnits.fUnitsToComment,
            SrcCache, CodeTool.FindImplementationUsesNode) then exit;
        if not SrcCache.Apply then exit;
        fMainUsedUnits.fUnitsToComment.Clear;
        fImplUsedUnits.fUnitsToComment.Clear;
      end;
      // Add more units meant for only LCL.
      with fMainUsedUnits do begin
        for i:=0 to fUnitsToAddForLCL.Count-1 do
          if not CodeTool.AddUnitToSpecificUsesSection(fUsesSection,
                                   fUnitsToAddForLCL[i], '', SrcCache) then exit;
        fUnitsToAddForLCL.Clear;
      end;
      with fImplUsedUnits do begin
        for i:=0 to fUnitsToAddForLCL.Count-1 do
          if not CodeTool.AddUnitToSpecificUsesSection(fUsesSection,
                                   fUnitsToAddForLCL[i], '', SrcCache) then exit;
        fUnitsToAddForLCL.Clear;
      end;
    end;
  end;
  Result:=mrOK;
end;

function TUsedUnitsTool.Remove(aUnit: string): TModalResult;
var
  x: Integer;
begin
  Result:=mrIgnore;
  if fMainUsedUnits.fExistingUnits.Find(aUnit, x) then begin
    fMainUsedUnits.UnitsToRemove.Add(aUnit);
    Result:=mrOK;
  end
  else if fImplUsedUnits.fExistingUnits.Find(aUnit, x) then begin
    fImplUsedUnits.UnitsToRemove.Add(aUnit);
    Result:=mrOK;
  end;
end;

procedure TUsedUnitsTool.MoveMissingToComment(aAllCommentedUnits: TStrings);
begin
  // These units will be commented automatically in one project/package.
  if Assigned(aAllCommentedUnits) then begin
    aAllCommentedUnits.AddStrings(fMainUsedUnits.fMissingUnits);
    aAllCommentedUnits.AddStrings(fImplUsedUnits.fMissingUnits);
  end;
  // Move all to be commented.
  fMainUsedUnits.fUnitsToComment.AddStrings(fMainUsedUnits.fMissingUnits);
  fMainUsedUnits.fMissingUnits.Clear;
  fImplUsedUnits.fUnitsToComment.AddStrings(fImplUsedUnits.fMissingUnits);
  fImplUsedUnits.fMissingUnits.Clear;
end;

function TUsedUnitsTool.AddUnitImmediately(aUnitName: string): Boolean;
// Add a unit to uses section and apply the change at once.
// Returns True if the unit was actually added (did not exist yet).

  procedure RemoveFromAdded(aUnitList: TStrings);
  var
    i: Integer;
  begin
    i:=aUnitList.IndexOf(aUnitName);
    if (i > -1) then
      aUnitList.Delete(i);
  end;

var
  x: Integer;
begin
  Result:=not ( fMainUsedUnits.fExistingUnits.Find(aUnitName, x)
             or fImplUsedUnits.fExistingUnits.Find(aUnitName, x) );
  if not Result then Exit;
  Result:=fCTLink.CodeTool.AddUnitToSpecificUsesSection(
                 fMainUsedUnits.fUsesSection, aUnitName, '', fCTLink.SrcCache);
  if not Result then Exit;
  Result:=fCTLink.SrcCache.Apply;
  if not Result then Exit;
  // Make sure the same unit will not be added again later.
  RemoveFromAdded(fMainUsedUnits.fUnitsToAdd);
  RemoveFromAdded(fImplUsedUnits.fUnitsToAdd);
  RemoveFromAdded(fMainUsedUnits.fUnitsToAddForLCL);
  RemoveFromAdded(fImplUsedUnits.fUnitsToAddForLCL);
  fCTLink.Settings.AddLogLine(mluNote,
    Format(lisConvDelphiAddedUnitToUsesSection, [aUnitName]), fFilename);
end;

function TUsedUnitsTool.AddUnitIfNeeded(aUnitName: string): Boolean;
begin
  Result := not HasUnit(aUnitName);
  if Result then
  begin
    fMainUsedUnits.fUnitsToAdd.Add(aUnitName);
    fCTLink.Settings.AddLogLine(mluNote,
      Format(lisConvDelphiAddedUnitToUsesSection, [aUnitName]), fFilename);
    MaybeAddPackageDep(aUnitName);
  end;
end;

function TUsedUnitsTool.AddThreadSupport: TModalResult;
// AddUnitToSpecificUsesSection would insert cthreads in the beginning automatically
// It doesn't work with {$IFDEF UNIX} directive -> use UsesInsertPolicy.
var
  i: Integer;
  OldPolicy: TUsesInsertPolicy;
begin
  Result:=mrCancel;
  if not ( fMainUsedUnits.fExistingUnits.Find('cthreads', i) or
           fImplUsedUnits.fExistingUnits.Find('cthreads', i) ) then
    with fCTLink, SrcCache.BeautifyCodeOptions do
    try
      OldPolicy:=UsesInsertPolicy;
      UsesInsertPolicy:=uipFirst;
      if not CodeTool.AddUnitToSpecificUsesSection(fMainUsedUnits.fUsesSection,
                           '{$IFDEF UNIX}cthreads{$ENDIF}', '', SrcCache) then exit;
    finally
      UsesInsertPolicy:=OldPolicy;
    end;
  Result:=mrOK;
end;

function TUsedUnitsTool.GetMissingUnitCount: integer;
begin
  Result:=fMainUsedUnits.fMissingUnits.Count
         +fImplUsedUnits.fMissingUnits.Count;
end;

end.

