unit filebrowsertypes;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Contnrs;

type
  TStartDir = (sdProjectDir, sdLastOpened, sdCustomDir);

  TRootDir = (rdProjectDir, rdUserDir, rdRootDir, rdCustomDir);

  EFileEntry = Class(Exception);

  TEntryType = (etDirectory,etFile,etSymlink);
  TEntryTypes = Set of TEntryType;

  TReadEntryOption = (reoHidden,reoRecurse);
  TReadEntryOptions = Set of TReadEntryOption;

Const
  AllEntryTypes = [Low(TEntryType)..High(TEntryType)];

Type
  { TFileSystemEntry }

  TFileSystemEntry = Class(TObject)
  private
    FName: String;
    FParent: TFileSystemEntry;
  Protected
    function GetChildCount: Integer; virtual;
    function GetEntry(index : integer): TFileSystemEntry; virtual;
  Public
    Constructor Create(aParent : TFileSystemEntry; const aName : string); virtual;
    Procedure AddEntry(aEntry : TFileSystemEntry); virtual;
    Class function EntryType : TEntryType; virtual; abstract;
    function AbsolutePath : String;
    Procedure Clear; virtual;
    Procedure ReadEntries(aOptions : TReadEntryOptions); virtual;
    Function HasEntries(aShowHidden : Boolean; aTypes : TEntryTypes = AllEntryTypes) : Boolean; virtual;
    Property EntryCount : Integer Read GetChildCount;
    Property Entries [index : integer] : TFileSystemEntry Read GetEntry; default;
    Property Name : String Read FName;
    Property Parent : TFileSystemEntry Read FParent;
  end;

  { TSymlinkEntry }

  TSymlinkEntry = Class(TFileSystemEntry)
  private
    FTarget: String;
  Public
    Constructor Create(aParent : TFileSystemEntry; const aName, aTarget : string); reintroduce;
    Class function EntryType : TEntryType; override;
    property Target : String Read FTarget;
  end;

  { TDirectoryEntry }

  TDirectoryEntry = Class(TFileSystemEntry)
  Private
    FEntries:TFPObjectList;
  Protected
    function GetChildCount: Integer; override;
    function GetEntry(index : integer): TFileSystemEntry; override;
  Public
    Constructor Create(aParent : TFileSystemEntry; const aName: string); override;
    Destructor Destroy; override;
    Procedure Clear; virtual;
    Procedure ReadEntries(aOptions : TReadEntryOptions); override;
    Class function EntryType : TEntryType; override;
    Class function HasEntries(aPath : String; aShowHidden : Boolean; aTypes : TEntryTypes = AllEntryTypes) : Boolean; virtual;
    Function HasEntries(aShowHidden : Boolean; aTypes : TEntryTypes = AllEntryTypes) : Boolean; override;
    Procedure AddEntry(aEntry : TFileSystemEntry); override;
  end;

  { TFileEntry }

  TFileEntry = Class(TFileSystemEntry)
    Class function EntryType : TEntryType; override;
  end;


const
  DefaultStartDir = sdProjectDir;
  DefaultRootDir = sdProjectDir;
  DefaultFilesInTree = False;
  DefaultDirectoriesBeforeFiles = True;
  DefaultSyncCurrentEditor = False;
  DefaultSplitterPos = 150;

  SConfigFile         = 'idebrowserwin.xml';
  KeyStartDir         = 'StartDir';
  KeyRootDir          = 'RootDir';
  KeyCustomStartDir   = 'CustomDir';
  KeyCustomRootDir    = 'CustomRootDir';
  KeySplitterPos      = 'SplitterPos';
  KeyFilesInTree      = 'FilesInTree';
  KeyDirectoriesBeforeFiles     = 'DirectoriesBeforeFiles';
  KeySyncCurrentEditor = 'SyncCurrentEditor';

resourcestring
  SFileBrowserIDEMenuCaption = 'File Browser';


implementation

{ TFileSystemEntry }

function TFileSystemEntry.GetChildCount: Integer;
begin
  Result:=0;
end;

function TFileSystemEntry.GetEntry(index : integer): TFileSystemEntry;
begin
  Result:=Nil;
end;

constructor TFileSystemEntry.Create(aParent: TFileSystemEntry; const aName: string);
begin
  FParent:=aParent;
  FName:=aName;
end;

procedure TFileSystemEntry.AddEntry(aEntry: TFileSystemEntry);
begin
  Raise EFileEntry.CreateFmt('Not supported for class %s',[ClassName]);
end;

function TFileSystemEntry.AbsolutePath: String;

var
  E: TFileSystemEntry;
  S : String;

begin
  E:=Self;
  S:='';
  While Assigned(E) do
    begin
    if (S<>'') then
      S:=PathDelim+S;
    S:=E.Name+S;
    E:=E.Parent;
    end;
  Result:=S;
end;

procedure TFileSystemEntry.Clear;
begin
  // Do nothing;
end;

procedure TFileSystemEntry.ReadEntries(aOptions: TReadEntryOptions);
begin
  // Do Nothing
end;

function TFileSystemEntry.HasEntries(aShowHidden: Boolean; aTypes: TEntryTypes): Boolean;
begin
  Result:=False;
end;

{ TSymlinkEntry }

constructor TSymlinkEntry.Create(aParent: TFileSystemEntry; const aName, aTarget: string);
begin
  Inherited Create(aParent,aName);
  FTarget:=aTarget;
end;

class function TSymlinkEntry.EntryType: TEntryType;
begin
  Result:=etSymlink;
end;

{ TDirectoryEntry }

function TDirectoryEntry.GetChildCount: Integer;
begin
  Result:=FEntries.Count;
end;

function TDirectoryEntry.GetEntry(index: integer): TFileSystemEntry;
begin
  Result:=TFileSystemEntry(FEntries[Index]);
end;

constructor TDirectoryEntry.Create(aParent: TFileSystemEntry; const aName: string);
begin
  inherited Create(aParent, aName);
  FEntries:=TFPObjectList.Create(True);
end;

destructor TDirectoryEntry.Destroy;
begin
  FreeAndNil(FEntries);
  inherited Destroy;
end;

procedure TDirectoryEntry.Clear;
begin
  FEntries.Clear;
end;

procedure TDirectoryEntry.ReadEntries(aOptions: TReadEntryOptions);

var
  Info: TSearchRec;
  Entry : TFileSystemEntry;
  CurrentDir: string;
  LinkTarget : RawByteString;
  isHidden : Boolean;
  isType : TEntryType;
  Add : Boolean;
begin
  Clear;
  CurrentDir:=IncludeTrailingPathDelimiter(AbsolutePath);
  CurrentDir:=CurrentDir;
  if SysUtils.FindFirst(CurrentDir+AllFilesMask,faAnyFile or faSymLink, Info) <> 0 then
     Exit;
  Try
      repeat
        With Info do
          begin
          if Name = '' then
            Continue;
          // check if special dir
          if ((Name = '.') or (Name = '..')) then
            Continue;
          isHidden:=((faHidden and Attr)<>0);
          if isHidden and Not (reoHidden in aOptions) then
            Continue;

          if ((faDirectory and Attr) <> 0) then
            isType:=etDirectory
          else if ((faSymLink and Attr) <> 0) then
            isType:=etSymlink
          else
            isType:=etFile;
          case IsType of
            etFile : Entry:=TFileEntry.Create(Self,Name);
            etDirectory : Entry:=TDirectoryEntry.Create(Self,Name);
            etSymlink :
              begin
              if not FileGetSymLinkTarget(CurrentDir+Name,LinkTarget) then
                LinkTarget:='<?>';
              Entry:=TSymLinkEntry.Create(Self,Name,LinkTarget);
              end;
          else
            Entry:=Nil;
          end;
          if Assigned(Entry) then
            AddEntry(Entry);
          if reoRecurse in aOptions then
            Entry.ReadEntries(aOptions);
          // We found at least one entry, so exit.
          end;
        until SysUtils.FindNext(Info) <> 0;
    finally
      SysUtils.FindClose(Info);
    end;
end;

class function TDirectoryEntry.EntryType: TEntryType;
begin
  Result:=etDirectory;
end;

class function TDirectoryEntry.HasEntries(aPath: String; aShowHidden : Boolean; aTypes: TEntryTypes): Boolean;

var
  Info: TSearchRec;
  CurrentDir: string;
  isHidden,isDir,isLink : Boolean;

begin
  Result := False;
  if aPath = '' then
    Exit;
  CurrentDir:=IncludeTrailingPathDelimiter(aPath);
  CurrentDir:=CurrentDir+AllFilesMask;
  if SysUtils.FindFirst(CurrentDir,faAnyFile or faSymLink, Info) <> 0 then
    Exit;
  Try
    repeat
      With Info do
        begin
        if Name = '' then
          Continue;
        // check if special dir
        if ((Name = '.') or (Name = '..')) then
          Continue;
        isHidden:=((faHidden and Attr)<>0) or (Name[1]='.');
        if isHidden and Not aShowHidden then
          Continue;
        isDir:=((faDirectory and Attr) <> 0);
        isLink:=((faSymLink and Attr) <> 0);

        Result:=(etFile in aTypes) and Not (isDir or IsLink);
        Result := Result or (IsDir and (etDirectory in aTypes));
        Result := Result or (isLink and (etSymlink in aTypes));

        // We found at least one entry, so exit.
        if Result then
          Exit;
        end;
      until SysUtils.FindNext(Info) <> 0;
  finally
    SysUtils.FindClose(Info);
  end;
end;

function TDirectoryEntry.HasEntries(aShowHidden: Boolean; aTypes: TEntryTypes): Boolean;

var
  I : Integer;

begin
  Result:=False;
  if (aTypes = AllEntryTypes) then
    Result:=FEntries.Count>0;
  if Not Result then
    if FEntries.Count=0 then
      Result:=HasEntries(AbsolutePath,aShowHidden,aTypes)
    else
      For I:=0 to EntryCount-1 do
        if Entries[i].EntryType in aTypes then
          exit(True);
end;

procedure TDirectoryEntry.AddEntry(aEntry: TFileSystemEntry);
begin
  if (aEntry=Nil) then
    exit;
  FEntries.Add(aEntry);
end;

{ TFileEntry }

class function TFileEntry.EntryType: TEntryType;
begin
  Result:=etFile;
end;

end.

