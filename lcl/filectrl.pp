{
 /***************************************************************************
                               filectrl.pp
                               -----------
                             Component Library File Controls
                   Initial Revision  : Sun Apr 23 18:30:00 PDT 2000


 ***************************************************************************/

 *****************************************************************************
  This file is part of the Lazarus Component Library (LCL)

  See the file COPYING.modifiedLGPL.txt, included in this distribution,
  for details about the license.
 *****************************************************************************

This unit contains file and directory controls and supporting handling functions. 
} 

unit FileCtrl;

{$mode objfpc}{$H+}

interface

{$ifdef Trace}
  {$ASSERTIONS ON}
{$endif}

uses
  Classes, SysUtils,
  StdCtrls, Graphics, ShellCtrls,
  FileUtil, LazFileUtils, Masks;

Type

  { TCustomFileListBox }

  TFileAttr = (ftReadOnly, ftHidden, ftSystem, ftVolumeID, ftDirectory,
               ftArchive, ftNormal);

  TFileType = set of TFileAttr;

  TCustomFileListBox = class(TCustomListBox)
  private
    FDrive: Char;
    FDirectory: String;
    FFileName: String;
    FFileType: TFileType;
    FMask: String;
    FOnChange: TNotifyEvent;
    FLastChangeFileName: string;
    function MaskIsStored: boolean;
    procedure SetDirectory(const AValue: String);
    procedure SetDrive(const AValue: Char);
    procedure SetFileName(const AValue: String);
    procedure SetFileType(const AValue: TFileType);
    procedure SetMask(const AValue: String);
    procedure UpdateSelectedFileName;
  protected
    procedure DoChangeFile; virtual;
    procedure Loaded; override;
    function IndexOfFile(const AFilename: string): integer;
    procedure KeyUp(var Key: Word; Shift: TShiftState); override;
    procedure SetItemIndex(AIndex: Integer); override;
  public
    constructor Create(TheOwner: TComponent); override;
    destructor Destroy; override;
    procedure Click; override;
    procedure UpdateFileList; virtual;
  public
    property Drive: Char Read FDrive Write SetDrive default ' ';
    property Directory: String Read FDirectory Write SetDirectory;
    property FileName: String Read FFileName Write SetFileName;
    property FileType: TFileType Read FFileType Write SetFileType default [ftNormal];
    property Mask: String Read FMask Write SetMask stored MaskIsStored;
    property OnChange: TNotifyEvent Read FOnChange Write FOnChange;
    property Sorted default true;
  end;


  { TFileListBox }

  TFileListBox = class(TCustomFileListBox)
  published
    property Align;
    property Anchors;
    property BiDiMode;
    property BorderSpacing;
    property BorderStyle;
    property Color;
    property Constraints;
    property Directory;
    property DragCursor;
    property DragMode;
    property Enabled;
    property ExtendedSelect;
    property FileType;
    property Font;
    property IntegralHeight;
    property ItemHeight;
    property Mask;
    property MultiSelect;
    property ParentBiDiMode;
    property ParentColor;
    property ParentShowHint;
    property ParentFont;
    property PopupMenu;
    property ShowHint;
    property Sorted;
    property Style;
    property TabOrder;
    property TabStop;
    property TopIndex;
    property Visible;
    { events }
    property OnChange;
    property OnChangeBounds;
    property OnClick;
    property OnDblClick;
    property OnDragDrop;
    property OnDragOver;
    property OnDrawItem;
    property OnEndDrag;
    property OnEnter;
    property OnExit;
    property OnKeyPress;
    property OnKeyDown;
    property OnKeyUp;
    property OnMouseDown;
    property OnMouseEnter;
    property OnMouseLeave;
    property OnMouseMove;
    property OnMouseUp;
    property OnMouseWheel;
    property OnMouseWheelDown;
    property OnMouseWheelUp;
    property OnResize;
    property OnSelectionChange;
    property OnStartDrag;
    property OnUTF8KeyPress;
  end;

  { TCustomFilterComboBox }

  TCustomFilterComboBox = class(TCustomComboBox)
  private
    FFilter: string;
    FShellListView: TShellListView;
    function GetMask: string;
    procedure SetFilter(const AValue: string);
    procedure SetShellListView(const AValue: TShellListView);
  protected
    procedure Select; override;
    procedure Notification(AComponent: TComponent; Operation: TOperation);
      override;
  public
    { Base methods }
    constructor Create(TheOwner: TComponent); override;
    destructor Destroy; override;
    { Externally available methods }
    class procedure ConvertFilterToStrings(AFilter: string;
      AStrings: TStrings; AClearStrings, AAddDescription, AAddFilter: Boolean);
    { properties }
    property Mask: string read GetMask; // Can be used to conect to other controls
    property ShellListView: TShellListView read FShellListView write SetShellListView;
  end;

  TFilterComboBox = class(TCustomFilterComboBox)
  published
    { properties }
    property Align;
    property Anchors;
    property AutoComplete;
    property AutoDropDown;
    property AutoSize;// Note: windows has a fixed height in some styles
    property BidiMode;
    property BorderSpacing;
    property Color;
    property Constraints;
    property DragCursor;
    property DragKind;
    property DragMode;
    property Enabled;
    // property FileList: TFileList
    property Filter: string read FFilter write SetFilter;
    property Font;
    property ItemIndex;
    property ParentBidiMode;
    property ParentColor;
    property ParentFont;
    property ParentShowHint;
    property PopupMenu;
    property ShellListView;
    property ShowHint;
    property TabOrder;
    property TabStop;
    property TextHint;
    property Visible;
    { events }
    property OnChange;
    property OnClick;
    property OnCloseUp;
    property OnContextPopup;
    property OnDblClick;
    property OnDragDrop;
    property OnDragOver;
    property OnEndDrag;
    property OnDropDown;
    property OnEnter;
    property OnExit;
    property OnKeyDown;
    property OnKeyPress;
    property OnKeyUp;
    property OnMouseDown;
    property OnMouseEnter;
    property OnMouseLeave;
    property OnMouseMove;
    property OnMouseUp;
    property OnMouseWheel;
    property OnMouseWheelDown;
    property OnMouseWheelUp;
    property OnStartDrag;
    property OnSelect;
    property OnUTF8KeyPress;
  end;

function MinimizeName(FileName: String; Canvas: TCanvas; MaxWidth: Integer): String;

procedure Register;


implementation

function MinimizeName(FileName: String; Canvas: TCanvas; MaxWidth: Integer): String;
{
 This function will return a shortened version of FileName, so that it fits
 on the given Canvas, with a given MaxWidth.
 eg. C:\Documents and Settings\User\Application Data\Microsoft\Word\custom.dic
     would become something like: C:\...\Word\custom.dic
}
  procedure RemoveFirstDir(var Dir: String);
  {
   This procedure will remove the first directory from Dir
   and will set ADelim to the Delimiter that separated the first Dir
   eg. In: Dir: 'Dir1\Dir2\Dir3'
  }
  var p: Integer;
  begin
    p:= Pos(PathDelim,Dir);
    if (p > 0) then
    begin
      Dir := Copy(Dir,p+1,Length(Dir)-p);
    end;
  end;

var Drive, Dir, Fn: String;
    ComposedName: String;
    TWidth: Integer;
begin
  Result := FileName;
  //if FileName does not contain any (sub)dir then return FileName
  if Pos(PathDelim, FileName) = 0 then Exit;
  //if FileName fits, no need to do anyhing
  if Canvas.TextWidth(FileName) <= MaxWidth then Exit;
  Drive := ExtractFileDrive(FileName);
  Fn := ExtractFileName(FileName);
  Dir := ExtractFilePath(FileName);
  //Remove Drive from Dir
  if (Length(Drive) > 0) then System.Delete(Dir, 1, Length(Drive));
  //Transfer all PathDelimiters at the start of Dir to Drive
  While (Length(Dir) > 0) and (Dir[1] in ['/','\']) do
  begin
    Drive := Drive + Dir[1];
    System.Delete(Dir,1,1);
  end;
  //if Dir is empty then we cannot shorten it,
  //and we know at this point that Drive+FileName is too long, so we return only filename
  if (Length(Dir) = 0) then
  begin
    Result := Fn;
    Exit;
  end;
  repeat
    //at this point we know that Dir ends with PathDelim (otherwise we exited before this point,
    //so RemoveFirstDir will return a truncated Dir or an empty string
    RemoveFirstDir(Dir);
    ComposedName := Drive+'...'+PathDelim+Dir+Fn;
    TWidth := Canvas.TextWidth(ComposedName);
  until (Length(Dir) = 0) or (TWidth <= MaxWidth);
  if (TWidth <= MaxWidth) then Result := ComposedName else Result := Fn;
end;


{ TCustomFileListBox }

procedure TCustomFileListBox.UpdateFileList;
const
  FileTypeFilesOnly = [ftReadOnly, ftHidden, ftSystem, ftArchive, ftNormal];
  {AttrNotNormal = faReadOnly or
                  faHidden or
                  faSysFile or
                  faVolumeID or
                  faDirectory or
                  faArchive  }
var
  Info: TSearchRec;
  FileAttr: LongInt;

  function FileTypeToFileAttribute(FileType: TFileType): LongInt;
  const
    FileTypeToAttrMap: array[TFileAttr] of LongInt =
    (
 { ftReadOnly  } faReadOnly,
 { ftHidden    } faHidden{%H-},
 { ftSystem    } faSysFile{%H-},
 { ftVolumeID  } faVolumeId{%H-},
 { ftDirectory } faDirectory,
 { ftArchive   } faArchive,
 { ftNormal    } 0
    );
  var
    Iter: TFileAttr;
  begin
    Result := 0;
    for Iter := Low(TFileAttr) to High(TFileAttr) do
      if Iter in FileType then
        Result := Result or FileTypeToAttrMap[Iter];
  end;

begin
  if [csloading, csdestroying] * ComponentState <> [] then
    Exit;
  Clear;
  if FileType <> [] then
  begin
    FileAttr := FileTypeToFileAttribute(FileType);
    if FindFirstUTF8(
      IncludeTrailingPathDelimiter(FDirectory)+AllDirectoryEntriesMask,
      FileAttr, Info) = 0
    then
      repeat
        if MatchesMaskList(Info.Name,Mask) then
        begin
          if (ftNormal in FileType) or ((Info.Attr and FileAttr {AttrNotNormal}) > 0) then
          begin
            if (Info.Attr and faDirectory) > 0 then
              Items.Add('['+Info.Name+']')
            else
            begin
              if (FileType * FileTypeFilesOnly <> []) then //don't add files if no file attribute is specified
                Items.Add(Info.Name);
            end;
          end;
        end;
      until FindNextUTF8(Info) <> 0;
    FindCloseUTF8(Info);
  end;

  UpdateSelectedFileName;
end;

procedure TCustomFileListBox.Click;
begin
  UpdateSelectedFileName;
  inherited Click; 
end;

procedure TCustomFileListBox.Loaded;
begin
  inherited Loaded;
  UpdateFileList;
end;

function TCustomFileListBox.IndexOfFile(const AFilename: string): integer;
var
  CurItem: string;
begin
  Result:=0;
  while (Result<Items.Count) do begin
    CurItem:=Items[Result];
    if (CompareFilenames(AFilename,CurItem)=0)
    or ((CurItem<>'') and (CurItem[1]='[') and (CurItem[length(CurItem)]=']')
      and (CompareFilenames('['+AFilename+']',CurItem)=0))
    then
      exit;
    inc(Result);
  end;
  Result:=-1;
end;

procedure TCustomFileListBox.KeyUp(var Key: Word; Shift: TShiftState);
begin
  UpdateSelectedFileName;
  inherited KeyUp(Key, Shift);
end;

procedure TCustomFileListBox.SetFileType(const AValue: TFileType);
begin
  if FFileType=AValue then exit;
  FFileType := AValue;
  UpdateFileList;
end;

procedure TCustomFileListBox.SetDirectory(const AValue: String);
begin
  if FDirectory=AValue then exit;
  FDirectory := AValue;
  UpdateFileList;
end;

function TCustomFileListBox.MaskIsStored: boolean;
begin
  Result:=(FMask<>AllDirectoryEntriesMask);
end;

procedure TCustomFileListBox.SetDrive(const AValue: Char);
begin
  if FDrive=AValue then exit;
  FDrive := AValue;
  // ToDo: change to current directory of drive
  UpdateFileList;
end;

procedure TCustomFileListbox.SetItemIndex(AIndex: Integer);
begin
  inherited;
  UpdateSelectedFileName;
end;

procedure TCustomFileListBox.SetFileName(const AValue: String);
var
  i: Integer;
begin
  i:=IndexOfFile(AValue);
  if i<>ItemIndex then begin
    ItemIndex:=i;
    UpdateSelectedFileName;
  end;
end;

procedure TCustomFileListBox.SetMask(const AValue: String);
begin
  if FMask = AValue then exit;
  FMask := AValue;
  UpdateFileList;
end;

procedure TCustomFileListBox.UpdateSelectedFileName;
var
  i: Integer;
begin
  i:=ItemIndex;
  // in a multiselect listbox, the itemindex can be 0 in an empty list
  if (i<0) or (i>=Items.Count) then
    FFileName := ''
  else begin
    FFileName := Items[i];
    if (FFileName<>'')
    and (FFileName[1]='[') and (FFileName[length(FFileName)]=']') then
      FFileName:=copy(FFileName,2,length(FFileName)-2);
    FFileName:= FDirectory+DirectorySeparator+FFileName;
  end;
  DoChangeFile;
end;

procedure TCustomFileListBox.DoChangeFile;
begin
  if FFilename=FLastChangeFileName then exit;
  FLastChangeFileName:=FFilename;
  If Assigned(FOnChange) then FOnChange(Self);
end;

constructor TCustomFileListBox.Create(TheOwner: TComponent);
var
  FileDrive: string;
  CurrentDir: string;
begin
  inherited Create(TheOwner);
  //Initializes the Mask property.
  FMask := AllDirectoryEntriesMask;
  //Initializes the FileType property.
  FFileType := [ftNormal];
  //Initializes the Directory and Drive properties to the current directory.
  CurrentDir := GetCurrentDirUTF8;
  FDirectory := CurrentDir;
  FileDrive := ExtractFileDrive(CurrentDir);
  if FileDrive<>'' then
    FDrive:=FileDrive[1]
  else
    FDrive:=' ';
  //Initializes the MultiSelect property.
  MultiSelect := False;
  //Fills the list box with all the files in the directory.
  UpdateFileList;
  //Initializes the Sorted property.
  Sorted := True;
end;

destructor TCustomFileListBox.Destroy;
begin
  inherited Destroy; 
end;

{ TCustomFilterComboBox }

function TCustomFilterComboBox.GetMask: string;
var
  FilterList: TStrings;
begin
  Result := '';

  FilterList := TStringList.Create;
  try
    TCustomFilterComboBox.ConvertFilterToStrings(FFilter, FilterList, True, False, True);

    if (ItemIndex >= 0) and (ItemIndex < FilterList.Count) then
    begin
      Result := FilterList[ItemIndex];
    end;
  finally
    FilterList.Free;
  end;
end;

procedure TCustomFilterComboBox.SetFilter(const AValue: string);
begin
  if AValue = FFilter then Exit;

  FFilter := AValue;

  TFilterComboBox.ConvertFilterToStrings(AValue, Items, True, True, False);

  ItemIndex := 0;
end;

procedure TCustomFilterComboBox.SetShellListView(const AValue: TShellListView);
begin
  if FShellListView=AValue then exit;

  FShellListView:=AValue;

  if FShellListView <> nil then begin
    FShellListView.Mask := Mask;
    FreeNotification(FShellListView);
  end;
end;

procedure TCustomFilterComboBox.Select;
begin
  if FShellListView <> nil then
    FShellListView.Mask := Mask;

  inherited Select;
end;

procedure TCustomFilterComboBox.Notification(AComponent: TComponent;
  Operation: TOperation);
begin
  inherited Notification(AComponent, Operation);
  if Operation=opRemove then
  begin
    if FShellListView=AComponent then
      FShellListView:=nil;
  end;
end;

{------------------------------------------------------------------------------
This is a parser that converts LCL filter strings to a TStringList

The parses states are:

0 - Initial state, is reading a string to be displayed on the filter
1 - Is reading the extensions

A LCL filter string looks like this:

Text files (*.txt *.pas)|*.txt;*.pas|Binaries (*.exe)|*.exe
or
Text files (*.txt *.pas)|*.txt;*.pas|Binaries (*.exe)|*.exe|

The TStrings will contain the following strings if
AAddDescription = True, AAddFilter = False

Text files (*.txt *.pas)
Binaries (*.exe)

Adapted from the converter initially created for QtWSDialogs.pas
------------------------------------------------------------------------------}
class procedure TCustomFilterComboBox.ConvertFilterToStrings(AFilter: string;
  AStrings: TStrings; AClearStrings, AAddDescription, AAddFilter: Boolean);
var
  ParserState, Position, i: Integer;
begin
  if AStrings = nil then Exit;

  if AClearStrings then AStrings.Clear;

  ParserState := 0;
  Position := 1;
  AFilter := AFilter + '|'; // to prevent ignoring of last filter

  for i := 1 to Length(AFilter) do
  begin
    if AFilter[i] = '|' then
    begin
      case ParserState of
      0:
      begin
        if AAddDescription then
          AStrings.Add(Copy(AFilter, Position, i - Position));
        ParserState := 1;
      end;
      1:
      begin
        if AAddFilter then
          AStrings.Add(Copy(AFilter, Position, i - Position));
        ParserState := 0;
      end;
      end;// case

      Position := i + 1;
    end;
  end;
end;

constructor TCustomFilterComboBox.Create(TheOwner: TComponent);
begin
  inherited Create(TheOwner);

  Text := '';
end;

destructor TCustomFilterComboBox.Destroy;
begin

  inherited Destroy;
end;

procedure Register;
begin
  RegisterComponents('Misc',[TFileListBox, TFilterComboBox]);
end;

end.

