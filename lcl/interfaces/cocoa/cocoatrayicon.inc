{%mainunit cocoawsextctrls.pas}

type

  { TCocoaStatusItemHandle }

  TCocoaStatusItemHandle = objcclass(NSObject, NSMenuDelegateProtocol)
  public
    { Fields }
    statusitem: NSStatusItem;
    TrayIcon: TCustomTrayIcon;
    { Methods }
    procedure lclAction(sender: id); message 'lclAction:';
    procedure lclSetTrayIcon(ATrayIcon: TCustomTrayIcon); message 'lclSetTrayIcon:';
    procedure menuWillOpen(menu: NSMenu); message 'menuWillOpen:';
  end;

  { TCocoaUserNotificationCenterDelegate }

  TCocoaUserNotificationCenterDelegate = objcclass(NSObject, NSUserNotificationCenterDelegateProtocol)
    function userNotificationCenter_shouldPresentNotification (center: NSUserNotificationCenter; notification: NSUserNotification): ObjCBOOL; message 'userNotificationCenter:shouldPresentNotification:';
  end;

{ TCocoaStatusItemHandle }

procedure TCocoaStatusItemHandle.lclAction(sender: id);
begin
  if Assigned(TrayIcon.OnClick) then
    TrayIcon.OnClick(TrayIcon);
end;

procedure TCocoaStatusItemHandle.lclSetTrayIcon(ATrayIcon: TCustomTrayIcon);
var
  image: NSImage;
begin
  TrayIcon := ATrayIcon;

  // Shows the icon

  if (ATrayIcon.icon <> nil) and (ATrayIcon.icon.Handle <> 0) then
  begin
    image := TCocoaBitmap(ATrayIcon.icon.Handle).image;
    if image <> nil then begin
      statusItem.button.setImageScaling(NSImageScaleProportionallyUpOrDown);
      statusItem.button.setImage(image);
    end;
  end;

  // Show the menu

  if (ATrayIcon.PopUpMenu <> nil) then
  begin
    ATrayIcon.PopUpMenu.HandleNeeded();
    //ATrayIcon.PopUpMenu.
    if Assigned(statusitem.menu) and (statusitem.menu.delegate = NSMenuDelegateProtocol(self)) then
      statusitem.menu.setDelegate(nil);

    statusitem.setMenu(TCocoaMenu(ATrayIcon.PopUpMenu.Handle));

    TCocoaMenu(ATrayIcon.PopUpMenu.Handle).setDelegate( self);
  end;
end;

procedure TCocoaStatusItemHandle.menuWillOpen(menu: NSMenu);
begin
  if Assigned(statusitem)
    and (statusitem.menu=menu)
    and (TrayIcon.PopUpMenu = nil) // LCL changes the value w/o letting WS know! :(
  then
    menu.cancelTrackingWithoutAnimation;
end;

function TCocoaUserNotificationCenterDelegate.userNotificationCenter_shouldPresentNotification
  (center: NSUserNotificationCenter; notification: NSUserNotification
  ): ObjCBOOL;
begin
  Result:= True;
end;

{ TCocoaWSCustomTrayIcon }

class function TCocoaWSCustomTrayIcon.Hide(const ATrayIcon: TCustomTrayIcon): Boolean;
var
  StatusItemHandle: TCocoaStatusItemHandle;
  statusitem: NSStatusItem;
begin
  Result:=false;
  if ATrayIcon.Handle = 0 then Exit;
  StatusItemHandle := TCocoaStatusItemHandle(ATrayIcon.Handle);
  statusitem := StatusItemHandle.statusitem;
  if statusitem = nil then Exit;

  statusitem.release;

  Result := True;
end;

class function TCocoaWSCustomTrayIcon.Show(const ATrayIcon: TCustomTrayIcon): Boolean;
var
  statusitem: NSStatusItem;
  bar: NSStatusBar;
  StatusItemHandle: TCocoaStatusItemHandle;
begin
  {$ifdef VerboseCocoaTrayIcon}
    WriteLn(':>[TCocoaWSCustomTrayIcon.Show]');
  {$endif VerboseCocoaTrayIcon}

  Result := False;

  { Creates the handle }
  
  bar := NSStatusBar.systemStatusBar();
  statusitem := bar.statusItemWithLength(NSSquareStatusItemLength);
  statusitem.retain();
  StatusItemHandle := TCocoaStatusItemHandle.alloc.init();
  StatusItemHandle.statusitem := statusitem;
  ATrayIcon.Handle := HWND(StatusItemHandle);

  // OnClick support
  statusitem.setTarget(StatusItemHandle);
  statusitem.setAction(objcselector('lclAction:'));

  // set the main properties
  StatusItemHandle.lclSetTrayIcon(ATrayIcon);

  statusitem.setHighlightMode(True);
  {$ifdef BOOLFIX}
  statusitem.setEnabled_(Ord(True));
  {$else}
  statusitem.setEnabled(True);
  {$endif}

  Result := True;
  
  {$ifdef VerboseCocoaTrayIcon}
{    WriteLn(':<[TCocoaWSCustomTrayIcon.Show]',
     ' Handle: ', IntToHex(ATrayIcon.Handle, 8),
     ' ACGRect.size.width: ', ACGRect.size.width,
     ' ACGRect.size.height: ', ACGRect.size.height,
     ' ACGRect.origin.x: ', ACGRect.origin.x,
     ' ACGRect.origin.y: ', ACGRect.origin.y,
     ' TCocoaBitmap(ATrayIcon.Icon.Handle).CGImage ', IntToHex(Int64(TCocoaBitmap(ATrayIcon.Icon.Handle).CGImage), 8)
     );}
  {$endif VerboseCocoaTrayIcon}
end;

class procedure TCocoaWSCustomTrayIcon.InternalUpdate(const ATrayIcon: TCustomTrayIcon);
var
  StatusItemHandle: TCocoaStatusItemHandle;
begin
  if ATrayIcon.Handle = 0 then Exit;
  StatusItemHandle := TCocoaStatusItemHandle(ATrayIcon.Handle);

  StatusItemHandle.lclSetTrayIcon(ATrayIcon);
end;

// macOS 10.14+ required
// APP codesign required
// codesign --deep --force --verify --verbose --sign '-' 'your.app'
class function TCocoaWSCustomTrayIcon.newUserNotify(const ATrayIcon: TCustomTrayIcon): Boolean;
var
  nc: UNUserNotificationCenter;
  trigger: UNTimeIntervalNotificationTrigger;
  message: UNMutableNotificationContent;
  request: UNNotificationRequest;
const
  options: NSInteger = UNAuthorizationOptionAlert or
                       UNAuthorizationOptionBadge or
                       UNAuthorizationOptionSound;
begin
  Result:= True;

  nc:= UNUserNotificationCenter.currentNotificationCenter;
  nc.requestAuthorizationWithOptions_completionHandler( options );

  trigger:= UNTimeIntervalNotificationTrigger.triggerWithTimeInterval_repeats(
    0.01, False);

  message:= UNMutableNotificationContent.new;
  message.setTitle( StrToNSString(ATrayIcon.BalloonTitle) );
  message.setBody( StrToNSString(ATrayIcon.BalloonHint) );
  message.setSound( UNNotificationSound.defaultSound );

  request:= UNNotificationRequest.requestWithIdentifier_content_trigger(
    NSString.string_, message, trigger );

  nc.addNotificationRequest_withCompletionHandler( request );

  message.release;
end;

class function TCocoaWSCustomTrayIcon.legacyUserNotify(const ATrayIcon: TCustomTrayIcon): Boolean;
var
  nc: NSUserNotificationCenter;
  message: NSUserNotification;
begin
  Result := True;
  message:= NSUserNotification.new;
  message.setTitle( StrToNSString(ATrayIcon.BalloonTitle) );
  message.setInformativeText( StrToNSString(ATrayIcon.BalloonHint) );
  if NOT NSApplication(NSApp).isActive then
    message.setSoundName( NSUserNotificationDefaultSoundName );

  nc:= NSUserNotificationCenter.defaultUserNotificationCenter;
  if CocoaConfigNotification.alwaysPresent then begin
    if NOT Assigned(nc.delegate) then
      nc.setDelegate( TCocoaUserNotificationCenterDelegate.new );
  end;
  nc.deliverNotification( message );

  message.release;
end;

class function TCocoaWSCustomTrayIcon.ShowBalloonHint(const ATrayIcon: TCustomTrayIcon): Boolean;
begin
  if NSAppKitVersionNumber >= NSAppKitVersionNumber11_0 then
    Result:= newUserNotify( ATrayIcon )       // APP codesign required
  else
    Result:= legacyUserNotify( ATrayIcon );
end;

class function TCocoaWSCustomTrayIcon.GetPosition(const ATrayIcon: TCustomTrayIcon): TPoint;
begin
  Result := Point(0, 0);
end;

