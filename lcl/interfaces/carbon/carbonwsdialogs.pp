{
 *****************************************************************************
 *                              CarbonWSDialogs.pp                           * 
 *                              --------------                               * 
 *                                                                           *
 *                                                                           *
 *****************************************************************************

 *****************************************************************************
  This file is part of the Lazarus Component Library (LCL)

  See the file COPYING.modifiedLGPL.txt, included in this distribution,
  for details about the license.
 *****************************************************************************
}
unit CarbonWSDialogs;

{$mode objfpc}{$H+}

interface

// defines
{$I carbondefines.inc}

uses
  // libs
  MacOSAll,
  // LCL
  Classes, SysUtils, FileUtil, Controls, Dialogs, LCLType, LCLProc, Masks,
  LazFileUtils, Graphics,
  // widgetset
  WSLCLClasses, WSDialogs,
  // LCL Carbon
  CarbonDef;
  
type

  { TCarbonWSCommonDialog }

  TCarbonWSCommonDialog = class(TWSCommonDialog)
  published
  end;

  { TCarbonWSFileDialog }

  TCarbonWSFileDialog = class(TWSFileDialog)
  published
    class procedure ShowModal(const ACommonDialog: TCommonDialog); override;
  end;

  { TCarbonWSOpenDialog }

  TCarbonWSOpenDialog = class(TWSOpenDialog)
  published
  end;

  { TCarbonWSSaveDialog }

  TCarbonWSSaveDialog = class(TWSSaveDialog)
  published
  end;

  { TCarbonWSSelectDirectoryDialog }

  TCarbonWSSelectDirectoryDialog = class(TWSSelectDirectoryDialog)
  published
  end;

  { TCarbonWSColorDialog }

  TCarbonWSColorDialog = class(TWSColorDialog)
  published
    class procedure ShowModal(const ACommonDialog: TCommonDialog); override;
  end;

  { TCarbonWSColorButton }

  TCarbonWSColorButton = class(TWSColorButton)
  published
  end;

  { TCarbonWSFontDialog }

  TCarbonWSFontDialog = class(TWSFontDialog)
  published
    class procedure ShowModal(const ACommonDialog: TCommonDialog); override;
  end;


implementation

uses
  CarbonProc, CarbonDbgConsts, CarbonInt, CarbonUtils, CarbonGDIObjects;

{ TCarbonWSFileDialog }

var
  Filters: TStringList; // filter text + TMaskList in object

procedure DescListToFiles(DescList: AEDescListPtr; FileDialog: TFileDialog);
var
  FileCount, FileIdx: Integer;
  Keyword: AEKeyword;
  FileDesc: AEDesc;
  FileRef: FSRef;
  FileURL: CFURLRef;
  FileCFStr: CFStringRef;
  FileName: string;
begin
  //DebugLnEnter('DescListToFiles INIT');
  //if OSError(NavDialogGetReply(DialogRef, DialogReply{%H-}), Self, SShowModal,
  //  'NavDialogGetReply') then Exit;  // Get user's selection
  //
  FileDialog.Files.Clear;

  if DescList=nil then begin
    DebugLnExit('DescList is nil, EXIT');
    exit;
  end;

  if (DescList=nil) or OSError(AECountItems(DescList^, FileCount{%H-}), FileDialog,
    SShowModal, 'AECountItems') then Exit;

  for FileIdx := 1 to FileCount do
  begin
    if OSError(AEGetNthDesc(DescList^, FileIdx, typeFSRef,
      @Keyword, FileDesc{%H-}), FileDialog, SShowModal, 'AEGetNthDesc') then Exit;

    // Get file reference
    if OSError(AEGetDescData(FileDesc, @FileRef, SizeOf(FSRef)), FileDialog,
      SShowModal, 'AEGetDescData') then Exit;

    if OSError(AEDisposeDesc(FileDesc), FileDialog, SShowModal,
      'AEDisposeDesc') then Exit;

    FileURL := CFURLCreateFromFSRef(kCFAllocatorDefault, FileRef); // Get URL
    FileCFStr := CFURLCopyFileSystemPath(FileURL, kCFURLPOSIXPathStyle); // Get path
    FileName := CFStringToStr(FileCFStr);
    //DebugLn('%d/%d FileName=%s',[FileIdx, FileCount, FileName]);
    FileDialog.Files.Add(FileName);

    FreeCFString(FileURL);
    FreeCFString(FileCFStr);
    // Note: Previous 5 lines replace next 2 lines and eliminate need
    //   to decide what size to make FileBuf array.
    //   See http://developer.apple.com/technotes/tn2002/tn2078.html
    //  FSRefMakePath(FileRef, @FileBuf, SizeOf(FileBuf));  {Get file path}
    //  FileDialog.Files.Add(string(FileBuf));  //FileBuf contains UTF8 C string
  end;

  FileDialog.FileName := FileDialog.Files.Strings[0];

  //if FileDialog.FCompStyle=csSaveFileDialog then
  //  FileDialog.FileName := FileDialog.FileName + PathDelim +
  //    CFStringToStr(NavDialogGetSaveFileName(DialogRef));
  //    {Note: Not at all clear from Apple docs that NavReplyRecord.Selection
  //      returns only path to file's folder with Save dialog. Also, what they
  //      mean by the "full file name" returned by NavDialogGetSaveFileName
  //      must mean extension and not path to file's folder.}


  // Dispose of data that record points to (?)
  //if OSError(NavDisposeReply(DialogReply), FileDialog, SShowModal,
  //  'NavDisposeReply') then Exit;

  //FileDialog.FilterIndex := FilterIndex + 1;
  //DebugLnExit('DescListToFiles END Files.Count=%d',[FileDialog.Files.Count]);
end;

function FilterCallback(var theItem: AEDesc; info: NavFileOrFolderInfoPtr;
 callbackUD: UnivPtr; {%H-}filterMode: NavFilterModes): Boolean; mwpascal;
 {Custom filter callback function. Pointer to this function is passed as
   inFilterProc to NavCreateGetFileDialog and NavCreateChooseFolderDialog.
  If theItem file should be highlighted in file dialog, return True;
   if it should be dimmed in file dialog, return False.
  The callbackUD param contains file dialog object passed as inClientData
   to NavCreateGetFileDialog and NavCreateChooseFolderDialog.}
var
  FileRef: FSRef;
  FileURL: CFURLRef;
  FileCFStr: CFStringRef;
  FilePath: string;
  FilterMask: TMaskList;
  FileDialog: TFileDialog;
  AIndex: Integer;
begin
  Result := True;
  FileDialog := TFileDialog(CallbackUD);
  if (FileDialog = nil) or (FileDialog.Filter='') then  // No user data passed?
    Exit;

  if FileDialog is TOpenDialog then
  begin
    if info^.isFolder then  // Don't dim folder?
      Exit;
  end
  else  {Must be TSelectDirectoryDialog}
  begin
    if not info^.isFolder then  // Dim file?
    begin
      Result := False;
      Exit;
    end;
  end;

  if OSError(AEGetDescData(theItem, @FileRef, SizeOf(FSRef)), 
             'FilterByExtCallback', '', 'AEGetDescData') then Exit;
                     
  FileURL := CFURLCreateFromFSRef(kCFAllocatorDefault, FileRef);
  FileCFStr := CFURLCopyFileSystemPath(FileURL, kCFURLPOSIXPathStyle);
          
  FilePath := CFStringToStr(FileCFStr);

  FreeCFString(FileURL);
  FreeCFString(FileCFStr);

  FilterMask := nil;
  AIndex := FileDialog.FilterIndex - 1;
  if (AIndex >= 0) and (AIndex < Filters.Count) then
    FilterMask := TMaskList(Filters.Objects[AIndex]);

  Result := (FilterMask = nil) or FilterMask.Matches(ExtractFilename(FilePath));
  //DebugLn('FilterCallback ' + DbgS(FilterMask) + ' ' + ExtractFilename(FilePath) + ' ' + DbgS(Result));
end;  {FilterCallback}

procedure NavDialogCallback(CallBackSelector: NavEventCallbackMessage;
  CallBackParms: NavCBRecPtr; CallBackUD: UnivPtr); mwpascal;
var
  Dir: AEDesc;
  DirRef: FSRef;
  DirURL: CFURLRef;
  DirCFStr: CFStringRef;
  PMenuSpec: NavMenuItemSpecPtr;
  MenuSpec: NavMenuItemSpec;
  AEDescList: AEDescListPtr;
  FileDialog: TFileDialog;
const
  SName = 'NavDialogCallback';
begin
  //DebugLnEnter(['NavDialogCallback INIT selector=',CallbackSelector]);
  if CallbackUD = nil then  // No user data passed?
    Exit;
  FileDialog := TFileDialog(CallbackUD);
    
  case CallBackSelector of
  kNavCBStart:
    begin

      // Set InitialDir
      if DirectoryExistsUTF8(FileDialog.InitialDir) then
      begin
        //DebugLn('Set InitialDir ' + TFileDialog(CallbackUD).InitialDir);
        CreateCFString(FileDialog.InitialDir, DirCFStr);
        try
          DirURL := CFURLCreateWithFileSystemPath(nil, DirCFStr,
            kCFURLPOSIXPathStyle, True);
        finally
          FreeCFString(DirCFStr);
        end;

        if DirURL <> nil then
          if CFURLGetFSRef(DirURL, DirRef{%H-}) then
            if not OSError(AECreateDesc(typeFSRef, @DirRef, SizeOf(FSRef), Dir{%H-}),
              SName, 'AECreateDesc') then
              OSError(NavCustomControl(CallBackParms^.context, kNavCtlSetLocation, @Dir),
                SName, 'NavCustomControl', 'InitialDir');
      end;

      // set initial filter index
      MenuSpec.version := kNavMenuItemSpecVersion;
      MenuSpec.menuCreator := kExtensionFolderType;
      MenuSpec.menuType := OSType(FileDialog.FilterIndex-1);
      MenuSpec.menuItemName := '';
      OSError(NavCustomControl(CallBackParms^.context, kNavCtlSelectCustomType, @MenuSpec),
                SName, 'NavCustomControl', 'FilterIndex');
    
    end;
  kNavCBPopupMenuSelect: // user has changed filter
    begin
      if CallBackParms = nil then Exit;
      PMenuSpec := NavMenuItemSpecPtr(CallBackParms^.eventData.eventDataParms.param);
      if PMenuSpec = nil then Exit;
      FileDialog.IntfFileTypeChanged(PMenuSpec^.menuType + 1);
    end;
  kNavCBSelectEntry:   // user has selected something
    begin
      if CallbackParms = nil then exit;
      AEDescList := AEDescListPtr(CallBackParms^.eventData.eventDataParms.param);
      DescListToFiles(AEDescList, FileDialog);
      //DebugLn(['kNavCBSelectEntry IsOpenDialog=',FileDialog is TOpenDialog]);
      if FileDialog is TOpenDialog then
        TOpenDialog(FileDialog).DoSelectionChange;
    end;
  kNavCBNewLocation:  // user has changed folder
    if FileDialog is TOpenDialog then
      TOpenDialog(FileDialog).DoFolderChange;
  end;

  //DebugLnExit('NavDialogCallback DONE');
end;


{------------------------------------------------------------------------------
  Method:  TCarbonWSFileDialog.ShowModal
  Params:  ACommonDialog - LCL common dialog
  
  Shows a file dialog (open, save, slect directory) in Carbon interface. Sets
  ACommonDialog.UserChoice to mrOK or mrCancel. If mrOK, also sets
  ACommonDialog.FileName to first file selected and adds file(s) selected to
  ACommonDialog.Files.
 ------------------------------------------------------------------------------}
class procedure TCarbonWSFileDialog.ShowModal(const ACommonDialog: TCommonDialog);
 {
  Called by Execute method of TOpenDialog, TSaveDialog and TSelectDirectoryDialog.
 }
var
  FileDialog: TFileDialog;
  CreationOptions: NavDialogCreationOptions;
  FilterUPP: NavObjectFilterUPP;
  NavDialogUPP: NavEventUPP;
  DialogRef: NavDialogRef;
  ReplyRecord: NavReplyRecord;
  I: Integer;
  ParsedFilter: TParseStringList;
  M: TMaskList;
  filterext: String;
  supportPackages: Boolean; //todo: select packages by name
begin
  {$IFDEF VerboseWSClass}
    DebugLn('TCarbonWSFileDialog.ShowModal for ' + ACommonDialog.Name);
  {$ENDIF}

  FileDialog := ACommonDialog as TFileDialog;

  // Initialize record to default values
  if OSError(NavGetDefaultDialogCreationOptions(CreationOptions{%H-}),
    Self, SShowModal, 'NavGetDefaultDialogCreationOptions') then Exit;

  CreationOptions.preferenceKey := 272829;  // The default of zero seems to cause setting the initial directory
                                            // to fail half the time on Sierra at least, so set to an arbitrary
                                            // non-zero value
  if FileDialog.Title <> '' then  // Override dialog's default title?
    CreateCFString(FileDialog.Title, CreationOptions.windowTitle);

  FileDialog.UserChoice := mrCancel; // Return this if user cancels or we need to exit

  FilterUPP := NewNavObjectFilterUPP(NavObjectFilterProcPtr(@FilterCallback));
  NavDialogUPP := NewNavEventUPP(NavEventProcPtr(@NavDialogCallback));

  Filters := TStringList.Create;
  // parse filters to popup menu - filter text + TMaskList
  ParsedFilter := TParseStringList.Create(FileDialog.Filter, '|');
  try
    for I := 1 to ParsedFilter.Count div 2 do
    begin
      try
        filterext:=ParsedFilter[I * 2 - 1];
        { Spaces in filters cause problems }
        filterext := StringReplace(filterext, ' ', '', [rfReplaceAll]);
        if (filterext = '*') or (filterext = '*.*') or (ExtractFileExt(filterext) = '.app') then
          supportPackages := true;
        M := TMaskList.Create(filterext);
      except
        FreeAndNil(M);
      end;
      //DebugLn('Filter ' + ParsedFilter[I * 2 - 1]);
      Filters.AddObject(ParsedFilter[I * 2 - 2], M);
    end;
  finally
    ParsedFilter.Free;
  end;
  supportPackages:=supportPackages or (Filters.Count=0);

  CreationOptions.popupExtension := StringsToCFArray(Filters);
  if supportPackages then
    CreationOptions.optionFlags := CreationOptions.optionFlags or kNavSupportPackages;
  try
    if FileDialog.FCompStyle=csSaveFileDialog then
    begin  // Checking for TSaveDialog first since it's descendent of TOpenDialog
      CreateCFString(ExtractFileName(FileDialog.FileName),
        CreationOptions.saveFileName);  // Note doesn't like path
        
      if ofOverwritePrompt in TOpenDialog(FileDialog).Options then
        CreationOptions.optionFlags :=
           CreationOptions.optionFlags and (not kNavDontConfirmReplacement)
      else
        CreationOptions.optionFlags :=
          CreationOptions.optionFlags or kNavDontConfirmReplacement;
         
      // Create Save dialog
      if OSError(
        NavCreatePutFileDialog(@CreationOptions, 0, 0, NavDialogUPP,
           UnivPtr(FileDialog), DialogRef{%H-}),
         Self, SShowModal, 'NavCreatePutFileDialog') then Exit;
    end
    else
      if FileDialog is TSelectDirectoryDialog then // Create Choose folder dialog
      begin
        if OSError(
          NavCreateChooseFolderDialog(@CreationOptions, NavDialogUPP,
           FilterUPP, UnivPtr(FileDialog), DialogRef),
           Self, SShowModal, 'NavCreateChooseFolderDialog') then Exit;
      end
      else
        if FileDialog is TOpenDialog then
        begin
          if not (ofAllowMultiSelect in TOpenDialog(FileDialog).Options) then
            CreationOptions.optionFlags :=
              CreationOptions.optionFlags and (not kNavAllowMultipleFiles)
          else
            CreationOptions.optionFlags :=
              CreationOptions.optionFlags or kNavAllowMultipleFiles;

          // Create Open dialog
          if OSError(
            NavCreateGetFileDialog(@CreationOptions, nil, NavDialogUPP, nil,
             FilterUPP, UnivPtr(FileDialog), DialogRef),
             Self, SShowModal, 'NavCreateGetFileDialog') then Exit;
        end;

    try
      // Display dialog
      FileDialog.Handle := TLCLHandle(DialogRef);
      if OSError(NavDialogRun(DialogRef), Self, SShowModal, 'NavDialogRun') then Exit;
      
      if NavDialogGetUserAction(DialogRef) <> kNavUserActionCancel then // User OK?
      begin
        if OSError(NavDialogGetReply(DialogRef, ReplyRecord), Self, SShowModal, 'NavDialogGetReply') then
          Exit;
        try
          if not ReplyRecord.validRecord then
            Exit;
          DescListToFiles(@ReplyRecord.selection, FileDialog);
        if FileDialog.FCompStyle=csSaveFileDialog then
            FileDialog.FileName := FileDialog.FileName + PathDelim + CFStringToStr(ReplyRecord.saveFileName);
        finally
         NavDisposeReply(ReplyRecord);
       end;
        FileDialog.UserChoice := mrOK;
      end;
    finally
      NavDialogDispose(DialogRef);  // Dispose of dialog
    end;

  finally
    CFRelease(CreationOptions.popupExtension);
    for I := 0 to Filters.Count - 1 do
      if Filters.Objects[I] <> nil then Filters.Objects[I].Free;
    Filters.Free;

    DisposeNavObjectFilterUPP(FilterUPP);
    DisposeNavEventUPP(NavDialogUPP);
    FreeCFString(CreationOptions.windowTitle);
    FreeCFString(CreationOptions.saveFileName);
  end;
end;  {TCarbonWSFileDialog.ShowModal}

{ TCarbonWSColorDialog }

{------------------------------------------------------------------------------
  Method:  TCarbonWSColorDialog.ShowModal
  Params:  ACommonDialog - LCL color dialog

  Shows Carbon interface color picker
 ------------------------------------------------------------------------------}
class procedure TCarbonWSColorDialog.ShowModal(
  const ACommonDialog: TCommonDialog);
var
  ColorInfo: NColorPickerInfo;
  ColorDialog: TColorDialog;
  Profile: CMProfileRef;
begin
  {$IFDEF VerboseWSClass}
    DebugLn('TCarbonWSColorDialog.ShowModal for ' + ACommonDialog.Name);
  {$ENDIF}
  
  ACommonDialog.UserChoice := mrCancel;
  ColorDialog := ACommonDialog as TColorDialog;
  
  CMGetDefaultProfileBySpace(cmRGBData, Profile{%H-});
  FillChar(ColorInfo{%H-}, SizeOf(ColorPickerInfo), 0);
  ColorInfo.theColor.color.rgb := CMRGBColor(ColorToRGBColor(ColorDialog.Color));
  ColorInfo.theColor.profile := Profile;
  ColorInfo.dstProfile := Profile;
  ColorInfo.flags := kColorPickerDialogIsModal or
                     kColorPickerDialogIsMoveable;
  ColorInfo.placeWhere :=  kCenterOnMainScreen;
  ColorInfo.pickerType := 0; // use last picker subtype
  ColorInfo.eventProc := nil;
  ColorInfo.colorProc := nil;
  ColorInfo.prompt := ColorDialog.Title;  // ColorDialog.Title is ignored, ColorInfo.prompt is not shown anywhere
  
  if OSError(NPickColor(ColorInfo), Self, SShowModal, 'PickColor') then Exit;
  
  if ColorInfo.newColorChosen then
  begin
    ColorDialog.Color := RGBColorToColor(RGBColor(ColorInfo.theColor.color.rgb));
    ACommonDialog.UserChoice := mrOK;
  end;
end;

var
  FontDialog: TFontDialog;

{ TCarbonWSFontDialog }

function CarbonFontDialog_Selection(ANextHandler: EventHandlerCallRef;
  AEvent: EventRef;
  {%H-}AWidget: TCarbonWidget): OSStatus; {$IFDEF darwin}mwpascal;{$ENDIF}
var
  ID: ATSUFontID;
  Size: Fixed;
  Color: RGBColor;
  Style: FMFontStyle;
begin
  {$IFDEF VerboseWSClass}
    DebugLn('CarbonFontDialog_Selection: ', DbgSName(FontDialog));
  {$ENDIF}

  Result := CallNextEventHandler(ANextHandler, AEvent);

  // get font panel settings
    
  if GetEventParameter(AEvent, kEventParamATSUFontID, typeATSUFontID,
    nil, SizeOf(ID), nil, @ID) = noErr then
  begin
    //DebugLn('ID: ' + DbgS(ID));
    FontDialog.Font.Name := CarbonFontIDToFontName(ID);
  end;
  
  if GetEventParameter(AEvent, kEventParamATSUFontSize, typeATSUSize,
    nil, SizeOf(Size), nil, @Size) = noErr then
  begin
    //DebugLn('Size: ' + DbgS(RoundFixed(Size)));
    //API gives "size" which equals to LCL's height (LCL height has minus)
    FontDialog.Font.Height := -RoundFixed(Size);
  end;
  
  if GetEventParameter(AEvent, kEventParamFontColor, typeFontColor,
    nil, SizeOf(Color), nil, @Color) = noErr then
  begin
    //DebugLn('Color: ' + DbgS(RGBColorToColor(Color)));
    FontDialog.Font.Color := RGBColorToColor(Color);
  end;

{ These styles don't work for most modern fonts, and can result in
  a font being double-bolded now that carbonproc.pp::lclFontName uses
  the full name (including style), rather than just the family name.

  if GetEventParameter(AEvent, kEventParamFMFontStyle, typeFMFontStyle,
    nil, SizeOf(Style), nil, @Style) = noErr then
  begin
    //DebugLn('Style: ' + DbgS(Style));
    FontDialog.Font.Style := [];
    if (Style and MacOSAll.bold) > 0 then
      FontDialog.Font.Style := FontDialog.Font.Style + [fsBold];
    if (Style and MacOSAll.italic) > 0 then
      FontDialog.Font.Style := FontDialog.Font.Style + [fsItalic];
    if (Style and MacOSAll.underline) > 0 then
      FontDialog.Font.Style := FontDialog.Font.Style + [fsUnderline];
  end;
}
  // TODO: fsStrikeOut
    
  FontDialog.UserChoice := mrOK;
end;

function CarbonFontDialog_Close(ANextHandler: EventHandlerCallRef;
  AEvent: EventRef;
  {%H-}AWidget: TCarbonWidget): OSStatus; {$IFDEF darwin}mwpascal;{$ENDIF}
begin
  {$IFDEF VerboseWSClass}
    DebugLn('CarbonFontDialog_Close: ', DbgSName(FontDialog));
  {$ENDIF}

  Result := CallNextEventHandler(ANextHandler, AEvent);
  
  CarbonWidgetSet.SetMainMenuEnabled(True);
  
  // hide font panel
  if FPIsFontPanelVisible then
    OSError(FPShowHideFontPanel, 'CarbonFontDialog_Close', 'FPShowHideFontPanel');
end;

{------------------------------------------------------------------------------
  Method:  TCarbonWSFontDialog.ShowModal
  Params:  ACommonDialog - LCL font dialog

  Shows Carbon interface font panel
 ------------------------------------------------------------------------------}
class procedure TCarbonWSFontDialog.ShowModal(const ACommonDialog: TCommonDialog);
var
  AFontDialog: TFontDialog;
  TmpSpec: EventTypeSpec;
  Dialog: WindowRef;
  Style: ATSUStyle;
  ID: ATSUFontID;
  M: ATSUTextMeasurement;
  C: RGBColor;
  Attr: ATSUAttributeTag;
  S: ByteCount;
  A: ATSUAttributeValuePtr;
begin
  {$IFDEF VerboseWSClass}
    DebugLn('TCarbonWSFontDialog.ShowModal for ' + ACommonDialog.Name);
  {$ENDIF}
  
  AFontDialog := ACommonDialog as TFontDialog;
  AFontDialog.UserChoice := mrCancel;

  if OSError(
    CreateNewWindow(kModalWindowClass,
      kWindowCompositingAttribute or kWindowStandardHandlerAttribute or kWindowFrameworkScaledAttribute, GetCarbonRect(0, 0, 0, 0), Dialog{%H-}),
    Self, SShowModal, 'CreateNewWindow') then Exit;
    
  try
    TmpSpec := MakeEventSpec(kEventClassFont, kEventFontPanelClosed);
    InstallWindowEventHandler(Dialog,
      RegisterEventHandler(@CarbonFontDialog_Close),
      1, @TmpSpec, nil, nil);

    TmpSpec := MakeEventSpec(kEventClassFont, kEventFontSelection);
    InstallWindowEventHandler(Dialog,
      RegisterEventHandler(@CarbonFontDialog_Selection),
      1, @TmpSpec, nil, nil);


    OSError(ATSUCreateAndCopyStyle(TCarbonFont(AFontDialog.Font.Reference.Handle).Style, Style{%H-}),
      Self, SShowModal, 'ATSUCreateAndCopyStyle');
      
    // force set font ID
    if ATSUGetAttribute(Style, kATSUFontTag, SizeOf(ID), @ID, nil) = kATSUNotSetErr then
    begin
      Attr := kATSUFontTag;
      A := @ID;
      S := SizeOf(ID);
      OSError(ATSUSetAttributes(Style, 1, @Attr, @S, @A), Self, SShowModal,
        'ATSUSetAttributes', 'kATSUFontTag');
    end;
    
    // force set font size
    if ATSUGetAttribute(Style, kATSUSizeTag, SizeOf(M), @M, nil) = kATSUNotSetErr then
    begin
      Attr := kATSUSizeTag;
      A := @M;
      S := SizeOf(M);
      OSError(ATSUSetAttributes(Style, 1, @Attr, @S, @A), Self, SShowModal,
        'ATSUSetAttributes', 'kATSUSizeTag');
    end;
    
    // force set font color
    if ATSUGetAttribute(Style, kATSUColorTag, SizeOf(C), @C, nil) = kATSUNotSetErr then
    begin
      Attr := kATSUColorTag;
      A := @C;
      S := SizeOf(C);
      OSError(ATSUSetAttributes(Style, 1, @Attr, @S, @A), Self, SShowModal,
        'ATSUSetAttributes', 'kATSUSizeTag');
    end;

    if OSError(SetFontInfoForSelection(kFontSelectionATSUIType, 1,
      @Style, GetWindowEventTarget(Dialog)),
      Self, SShowModal, 'SetFontInfoForSelection') then Exit;

    CarbonWidgetSet.SetMainMenuEnabled(False);

    FontDialog := AFontDialog;
    MacOSAll.ShowWindow(Dialog);

    // show font panel
    if not FPIsFontPanelVisible then
      OSError(FPShowHideFontPanel, Self, SShowModal, 'FPShowHideFontPanel');
      
    while FPIsFontPanelVisible do
      CarbonWidgetSet.AppProcessMessages;

  finally
    DisposeWindow(Dialog);
    CarbonWidgetSet.SetMainMenuEnabled(True);
  end;
end;

end.
