{
CalControlWrapper
- - - - - - - - - - - - - - - - -
Author: Zoran Vučenović
        Зоран Вученовић

   This unit is part of DateTimeCtrls package for Lazarus.

   By default, TDateTimePicker uses LCL's TCalendar to represent the
drop-down calendar, but you can use some other calendar control instead.

   In order to use another calendar control, you should "wrap" that control with
a CalendarControlWrapper.

   To be used by DateTimePicker, the calendar control must at least provide
a way to determine whether the coordinates are on the date (when this control
gets clicked, we must decide if the date has just been chosen - then we should
respond by closing the drop-down form and setting the date from calendar to
DateTimePicker - for example in LCL's TCalendar we will respond when the
calendar is clicked on date, but not when the user clicks in title area changing
months or years, then we let the user keep browsing the calendar).

   When creating new wrapper, there are four abstract methods which need to be
overridden. Please see the comments in code below.

-----------------------------------------------------------
LICENCE
- - - -
   Modified LGPL -- see the file COPYING.modifiedLGPL.

-----------------------------------------------------------
NO WARRANTY
- - - - - -
   There is no warranty whatsoever.

-----------------------------------------------------------
BEST REGARDS TO LAZARUS COMMUNITY!
- - - - - - - - - - - - - - - - - -
   I do hope the DateTimeCtrls package will be useful.
}
unit calcontrolwrapper;

{$mode objfpc}{$H+}

interface

uses
  Controls;

type

  { TCalendarControlWrapper }

  TCalendarControlWrapper = class abstract (TObject)
  private
    FCalendarControl: TControl;
  public
  { There are four abstract methods that derived classes should override: }

  { Should be overriden to just return the class of the calendar control. }
    class function GetCalendarControlClass: TControlClass; virtual abstract;

  { Should be overridden to set the date in the calendar control. }
    procedure SetDate(Date: TDate); virtual abstract;

  { Should be overridden to get the date from the calendar control. }
    function GetDate: TDate; virtual abstract;

  { This function should return True if coordinates (X, Y) are on the date in
    the calendar control (DateTimePicker calls this function when the calendar
    is clicked, to determine whether the drop-down calendar should return the
    date or not). }
    function AreCoordinatesOnDate(X, Y: Integer): Boolean; virtual abstract;

  public
  { Not mandatory to override: }

  { Override only if the calendar class have "views", like Windows calendar
    control (LCL's TCalendar in Win WS).
    Should return False only when the calendar is in some view other than month.
    DateTimePicker asks this when closing calendar. }
    function InMonthView: Boolean; virtual;

  public
    function GetCalendarControl: TControl;
    constructor Create; virtual;
    destructor Destroy; override;
  end;

  TCalendarControlWrapperClass = class of TCalendarControlWrapper;

implementation

{ TCalendarControlWrapper }

function TCalendarControlWrapper.InMonthView: Boolean;
begin
  Result := True;
end;

function TCalendarControlWrapper.GetCalendarControl: TControl;
begin
  Result := FCalendarControl;
end;

constructor TCalendarControlWrapper.Create;
begin
  FCalendarControl := GetCalendarControlClass.Create(nil);
end;

destructor TCalendarControlWrapper.Destroy;
begin
  FCalendarControl.Free;
  inherited Destroy;
end;

end.

