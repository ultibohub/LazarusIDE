unit TestCommonSources;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, LCLType, strutils, LazFileUtils, TestOutputLogger;

{$R sources.rc} // change to .res if you do not have windres (or fpcres). Ensure you have the latest .res pre-compiled resource

type

  { TCommonSource }

  TCommonSource = class
  private
    FData: TStringList;
    FFileName: String;
    FFolder: String;
    FOtherSources: Array of TCommonSource;
    FBreakPoints: TStringList;
    function GetBreakPoints(AName: String): Integer;
    function GetFullFileName: String;
    function GetOtherBreakPoints(AUnitName, AName: String): Integer;
    function GetOtherSrc(AName: String): TCommonSource;
  protected
    procedure SaveToFolder(AFolder: String);
    procedure DeleteFromFolder(AFolder: String);
  public
    constructor Create(AName: String);
    destructor Destroy; override;
    procedure Save(BaseDir: String; SubDir: String = '');
    procedure SaveTo(AFolder: TCommonSource; SubDir: String='');
    procedure SaveTo(AFolder: String);
    property FileName: String read FFileName write FFileName;
    property FullFileName: String read GetFullFileName;
    property Folder: String read FFolder;
    property OtherSrc[AName: String]: TCommonSource read GetOtherSrc;
    property BreakPoints[AName: String]: Integer read GetBreakPoints;
    property OtherBreakPoints[AUnitName, AName: String]: Integer read GetOtherBreakPoints;
  end;

function GetCommonSourceFor(AName: String): TCommonSource;

implementation
var
  CommonSources: TStringList;
  BlockRecurseName: String;

function GetCommonSourceFor(AName: String): TCommonSource;
var
  i: Integer;
begin
  if UpperCase(AName) = UpperCase(BlockRecurseName) then
    raise Exception.Create('BlockRecurseName');
  i := CommonSources.IndexOf(AName);
  if i >= 0 then
    exit(TCommonSource(CommonSources.Objects[i]));

  Result := TCommonSource.Create(AName);
  CommonSources.AddObject(AName, Result);
end;

{ TCommonSource }

function TCommonSource.GetFullFileName: String;
begin
  if pos(PathDelim, FFileName) > 0 then
    Result := FFileName
  else
    Result := AppendPathDelim(FFolder)+FFileName;
end;

function TCommonSource.GetOtherBreakPoints(AUnitName, AName: String): Integer;
begin
  Result := OtherSrc[AUnitName].BreakPoints[AName];
end;

function TCommonSource.GetBreakPoints(AName: String): Integer;
var
  i: Integer;
begin
  i := FBreakPoints.IndexOf(AName);
  if (i < 0) or (FBreakPoints.Objects[i] = nil) then
    raise Exception.Create('Break unknown '+AName);
  Result := Integer(PtrInt(FBreakPoints.Objects[i]));
//TestLogger.DebugLn(['Break: ',AName, '  ',Result]);
end;

function TCommonSource.GetOtherSrc(AName: String): TCommonSource;
var
  i: Integer;
begin
  Result := nil;
  i := Length(FOtherSources) - 1;
  while i >= 0 do begin
    if FOtherSources[i].FileName = AName then begin
      Result := FOtherSources[i];
      break;
    end;
    dec(i);
  end;
end;

procedure TCommonSource.SaveToFolder(AFolder: String);
begin
  if pos(PathDelim, FFileName) > 0 then exit;
TestLogger.DebugLn(['SAVE: ',AFolder, '  ',FFileName]);
  FData.SaveToFile(AppendPathDelim(AFolder)+FFileName);
end;

procedure TCommonSource.DeleteFromFolder(AFolder: String);
begin
  if pos(PathDelim, FFileName) > 0 then exit;
TestLogger.DebugLn(['DELETE: ',AFolder, '  ',FFileName]);
  DeleteFile(AppendPathDelim(AFolder)+FFileName);
end;

constructor TCommonSource.Create(AName: String);

  procedure AddOther(n: String);
  var
    i: Integer;
  begin
TestLogger.DebugLn(['OTHER: ',n]);
    i := Length(FOtherSources);
    SetLength(FOtherSources, i+1);
    FOtherSources[i] := GetCommonSourceFor(n);
  end;

var
  r: TStream;
  Other, s, s2: String;
  i, Line: Integer;
  OwnBlockRecurseName: Boolean;
  i2: SizeInt;
begin
  OwnBlockRecurseName := BlockRecurseName = '';
  if OwnBlockRecurseName then
    BlockRecurseName := AName;

  FFileName := AName;
  if pos(PathDelim, AName) > 0 then
    r := TFileStream.Create(AName, fmOpenRead)
  else
    try
      r := TResourceStream.Create(HINSTANCE, AName, RT_RCDATA);
    except
      r := TFileStream.Create(AName, fmOpenRead)
    end;

  FData := TStringList.Create;
  FData.LoadFromStream(r);
  r.Free;

  FBreakPoints := TStringList.Create;
  if FData.Count < 1 then exit;

  // TEST_USES
  Other := FData[0];
  i := pos('TEST_USES=', Other);
  if i > 0 then begin
    Delete(Other, 1, i+9);
    i := pos(',', Other);
    while i > 0 do begin
      AddOther(copy(Other, 1, i-1));
      Delete(Other, 1, i);
      i := pos(',', Other);
    end;
    AddOther(Other);
  end;

  // TEST_PREPOCESS(file, subst=val, subst=val ....)
  s := FData.Text;
  i := pos('TEST_PREPOCESS(', s);
  while i > 0 do begin
    i2 := i+1;
    while (i2 <= length(s)) and (s[i2] <> ')') do
      if s[i2]='"'
      then i2 := PosEx('"', s, i2+1) + 1
      else i2 := i2 + 1;
//    i2 := PosEx(')', s, i+14);
    FData.CommaText := copy(s, i+15, i2 - (i+15));
    s2 := OtherSrc[FData[0]].FData.Text;
    FData.Delete(0);
    while FData.Count > 0 do begin
      s2 := ReplaceStr(s2, FData.Names[0], FData.Values[FData.Names[0]]);
      FData.Delete(0);
    end;
    Delete(s, i, i2-i+1);
    Insert(s2, s, i);
    i := pos('TEST_PREPOCESS', s);
  end;
  FData.Text := s;

  // TEST_BREAKPOINT
  for Line := 0 to FData.Count - 1 do begin
    i := pos('TEST_BREAKPOINT=', FData[Line]);
    if i > 0 then begin
      i := i + 16;
      if FBreakPoints.IndexOf(copy(FData[Line], i, MaxInt)) >= 0 then
        raise Exception.Create('dup brkpoint name in: '+FFileName+' '+IntToStr(Line));
      FBreakPoints.AddObject(copy(FData[Line], i, MaxInt), TObject(Line + 1));
    end;
  end;

  if OwnBlockRecurseName then
    BlockRecurseName := '';
end;

destructor TCommonSource.Destroy;
begin
  FBreakPoints.Free;
  FreeAndNil(FData);
  if FFolder <> '' then
    if not RemoveDirUTF8(FFolder) then
      TestLogger.DebugLn(['removed dir ', FFolder, ' err: ', GetLastOSError]);
  inherited Destroy;
end;

procedure TCommonSource.Save(BaseDir: String; SubDir: String);
var
  d: String;
  i: Integer;
begin
  if pos(PathDelim, FFileName) > 0 then exit;
  if FFolder <> '' then
    exit;
  d := AppendPathDelim(BaseDir) + ExtractFileNameOnly(FFileName) + '_' + IntToStr(Random(9999999))+'_';
  i := 0;
  while (i < 1000) and DirectoryExistsUTF8(d+IntToStr(i)) do inc(i);
  d := d+IntToStr(i);
  CreateDirUTF8(d);
  CreateDirUTF8(AppendPathDelim(d)+'lib');
  FFolder := d;
  if SubDir <> '' then
    FFolder := AppendPathDelim(FFolder) + SubDir;
  SaveToFolder(d);
  for i := 0 to Length(FOtherSources) - 1 do
    FOtherSources[i].SaveToFolder(d);
end;

procedure TCommonSource.SaveTo(AFolder: TCommonSource; SubDir: String);
begin
  if SubDir <> '' then
    SaveTo(AppendPathDelim(AFolder.Folder) + SubDir)
  else
    SaveTo(AFolder.Folder);
end;

procedure TCommonSource.SaveTo(AFolder: String);
var
  i: Integer;
begin
  FFolder := AFolder;
  if not DirectoryExistsUTF8(FFolder) then
    CreateDirUTF8(FFolder);
  SaveToFolder(FFolder);
  for i := 0 to Length(FOtherSources) - 1 do
    FOtherSources[i].SaveToFolder(FFolder);
end;

initialization
  CommonSources := TStringList.Create;

finalization;
  while CommonSources.Count > 0 do begin
    CommonSources.Objects[0].Free;
    CommonSources.Delete(0);
  end;
  CommonSources.Free;
end.

