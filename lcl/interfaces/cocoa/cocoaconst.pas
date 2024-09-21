unit CocoaConst;

{$mode ObjFPC}{$H+}
{$modeswitch objectivec1}

interface

uses
  SysUtils, LCLStrConsts, LCLType, LCLProc,
  CocoaAll;

type
  TNSStringArray = Array of NSString;

function BUTTON_CAPTION_ARRAY: TNSStringArray;

function NSSTR_EMPTY: NSString;

function NSSTR_DARK_NAME: NSString;
function NSSTR_DARK_NAME_VIBRANT: NSString;

function NSSTR_LINE_FEED: NSString;
function NSSTR_CARRIAGE_RETURN: NSString;
function NSSTR_LINE_SEPARATOR: NSString;
function NSSTR_PARAGRAPH_SEPARATOR: NSString;

function NSSTR_KEY_ENTER: NSString;
function NSSTR_KEY_ESC: NSString;
function NSSTR_KEY_EQUALS: NSString;
function NSSTR_KEY_PLUS: NSString;

function NSSTR_TABCONTROL_PREV_ARROW: NSSTRING;
function NSSTR_TABCONTROL_NEXT_ARROW: NSSTRING;

implementation

const
  DarkName = 'NSAppearanceNameDarkAqua'; // used in 10.14
  DarkNameVibrant = 'NSAppearanceNameVibrantDark'; // used in 10.13

var
  _BUTTON_CAPTION_ARRAY: TNSStringArray;

var
  _NSSTR_EMPTY: NSString;

  _NSSTR_DARK_NAME: NSString;
  _NSSTR_DARK_NAME_VIBRANT: NSString;

  _NSSTR_LINE_FEED: NSString;
  _NSSTR_CARRIAGE_RETURN: NSString;
  _NSSTR_LINE_SEPARATOR: NSString;
  _NSSTR_PARAGRAPH_SEPARATOR: NSString;

  _NSSTR_KEY_ENTER: NSString;
  _NSSTR_KEY_ESC: NSString;
  _NSSTR_KEY_EQUALS: NSString;
  _NSSTR_KEY_PLUS: NSString;

  _NSSTR_TABCONTROL_PREV_ARROW: NSSTRING;
  _NSSTR_TABCONTROL_NEXT_ARROW: NSSTRING;

function NSSTR_EMPTY: NSString;
begin
  Result:= _NSSTR_EMPTY;
end;

function NSSTR_DARK_NAME: NSString;
begin
  Result:= _NSSTR_DARK_NAME;
end;

function NSSTR_DARK_NAME_VIBRANT: NSString;
begin
  Result:= _NSSTR_DARK_NAME_VIBRANT;
end;


function NSSTR_LINE_FEED: NSString;
begin
  Result:= _NSSTR_LINE_FEED;
end;

function NSSTR_CARRIAGE_RETURN: NSString;
begin
  Result:= _NSSTR_CARRIAGE_RETURN;
end;

function NSSTR_LINE_SEPARATOR: NSString;
begin
  Result:= _NSSTR_LINE_SEPARATOR;
end;

function NSSTR_PARAGRAPH_SEPARATOR: NSString;
begin
  Result:= _NSSTR_PARAGRAPH_SEPARATOR;
end;


function NSSTR_KEY_ENTER: NSString;
begin
  Result:= _NSSTR_KEY_ENTER;
end;

function NSSTR_KEY_ESC: NSString;
begin
  Result:= _NSSTR_KEY_ESC;
end;

function NSSTR_KEY_EQUALS: NSString;
begin
  Result:= _NSSTR_KEY_EQUALS;
end;

function NSSTR_KEY_PLUS: NSString;
begin
  Result:= _NSSTR_KEY_PLUS;
end;


function NSSTR_TABCONTROL_PREV_ARROW: NSSTRING;
begin
  Result:= _NSSTR_TABCONTROL_PREV_ARROW;
end;

function NSSTR_TABCONTROL_NEXT_ARROW: NSSTRING;
begin
  Result:= _NSSTR_TABCONTROL_NEXT_ARROW;
end;


function StringToNSString( const s:String ): NSString;
begin
  Result:= NSString.alloc.initWithUTF8String( pchar(s) );
end;

function StringRemoveAcceleration(const str: String): String;
var
  posAmp: Integer;
  posRight: Integer;
  posLeft: Integer;
begin
  Result:= str;
  posAmp:= DeleteAmpersands(Result);
  if posAmp < 0 then
    Exit;

  posRight:= str.IndexOf( ')' );
  if (posRight<0) or (posRight<posAmp) then
    Exit;

  posLeft:= str.IndexOf( '(' );
  if (posLeft<0) or (posLeft>posAmp) then
    Exit;

  Result:= str.Substring(0,posLeft).Trim;
end;

function LclTitleToNSString( const title:String ): NSString;
begin
  Result:= StringToNSString( StringRemoveAcceleration(title) );
end;

function BUTTON_CAPTION_ARRAY: TNSStringArray;
begin
  if length(_BUTTON_CAPTION_ARRAY)=0 then begin
    setlength( _BUTTON_CAPTION_ARRAY, idButtonNoToAll+1 );
    _BUTTON_CAPTION_ARRAY[idButtonOk]:= LclTitleToNSString( rsMbOK );
    _BUTTON_CAPTION_ARRAY[idButtonCancel]:= LclTitleToNSString( rsMbCancel );
    _BUTTON_CAPTION_ARRAY[idButtonHelp]:= LclTitleToNSString( rsMbHelp );
    _BUTTON_CAPTION_ARRAY[idButtonYes]:= LclTitleToNSString( rsMbYes );
    _BUTTON_CAPTION_ARRAY[idButtonNo]:= LclTitleToNSString( rsMbNo );
    _BUTTON_CAPTION_ARRAY[idButtonClose]:= LclTitleToNSString( rsMbClose );
    _BUTTON_CAPTION_ARRAY[idButtonAbort]:= LclTitleToNSString( rsMbAbort );
    _BUTTON_CAPTION_ARRAY[idButtonRetry]:= LclTitleToNSString( rsMbRetry );
    _BUTTON_CAPTION_ARRAY[idButtonIgnore]:= LclTitleToNSString( rsMbIgnore );
    _BUTTON_CAPTION_ARRAY[idButtonAll]:= LclTitleToNSString( rsMbAll );
    _BUTTON_CAPTION_ARRAY[idButtonYesToAll]:= LclTitleToNSString( rsMbYesToAll );
    _BUTTON_CAPTION_ARRAY[idButtonNoToAll]:= LclTitleToNSString( rsMbNoToAll );
  end;
  Result:= _BUTTON_CAPTION_ARRAY;
end;

initialization
  _NSSTR_EMPTY:= NSString.string_;

  _NSSTR_DARK_NAME:= NSSTR(DarkName);
  _NSSTR_DARK_NAME_VIBRANT:= NSSTR(DarkNameVibrant);

  _NSSTR_LINE_FEED:= NSSTR(#10);
  _NSSTR_CARRIAGE_RETURN:= NSSTR(#13);
  _NSSTR_LINE_SEPARATOR:= StringToNSString(#$E2#$80#$A8);
  _NSSTR_PARAGRAPH_SEPARATOR:= StringToNSString(#$E2#$80#$A9);

  _NSSTR_KEY_ENTER:= NSSTR(#13);
  _NSSTR_KEY_ESC:= NSSTR(#27);
  _NSSTR_KEY_EQUALS:= NSSTR('=');
  _NSSTR_KEY_PLUS:= NSSTR('+');

  _NSSTR_TABCONTROL_PREV_ARROW:= StringToNSString('◀');
  _NSSTR_TABCONTROL_NEXT_ARROW:= StringToNSString('▶');

finalization;
  _NSSTR_LINE_SEPARATOR.release;
  _NSSTR_PARAGRAPH_SEPARATOR.release;

  _NSSTR_TABCONTROL_PREV_ARROW.release;
  _NSSTR_TABCONTROL_NEXT_ARROW.release;

end.

