{%MainUnit ../lclintf.pas}

function DoOpen(APath: String; Param: String): Boolean;
begin
  Result := True;
  if not FileExistsUTF8(APath) and not DirectoryExistsUTF8(Apath) then begin
    // OpenDocument handles URLs as well
    Result := OpenURL(Apath);
    Exit;
  end;
  // Paths with spaces need to be quoted, see bug 21651
  if (APath<>'') and (APath[1]<>'''') then
    APath:=QuotedStr(APath);

  if Param<>'' then
    APath:=Param+' '+APath;

  RunCmdFromPath('open',APath);
end;

function FindDefaultBrowser(out ABrowser, AParams: String): Boolean;
begin
  // open command launches url in the appropriate browser under Mac OS X
  FindBrowserExecutable('open', ABrowser);
  AParams := '"%s"';
  Result := (ABrowser <> '');
  if not Result then
  begin
    Result := FindPredefinedBrowser(ABrowser, AParams);
  end;
end;

// Open a given URL with the default browser
function OpenURL(AURL: String): Boolean;
var
  url: NSURL;
  ws: NSWorkspace;
begin
  Result := False;
  if AURL = '' then
    Exit;
  url := NSURL.URLWithString(NSString.stringWithUTF8String(@AURL[1]));
  // scheme is checking for "protocol" specifier.
  // if no protocol specifier exist - do not consider it as URL and fail
  if not Assigned(url) or (url.scheme.length = 0) then
    Exit;

  ws := NSWorkspace.sharedWorkspace;
  Result := ws.openURL(url);
end;

// Open a document with the default application associated with it in the system
function OpenDocument(APath: String): Boolean;
begin
  Result:=DoOpen(APath,'');
end;

// open the folder and select the file in system filemanager.
function SelectInFolder(AFullPath: String): Boolean;
begin
  Result := DoOpen(AFullPath,'-R');
end;

