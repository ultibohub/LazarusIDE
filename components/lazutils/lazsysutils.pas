{
 *****************************************************************************
  This file is part of LazUtils.

  See the file COPYING.modifiedLGPL.txt, included in this distribution,
  for details about the license.
 *****************************************************************************
}
unit LazSysUtils;

{$mode objfpc}{$H+}

interface

uses
  SysUtils;

function NowUTC: TDateTime;
function GetTickCount64: QWord;

implementation

uses
  {$IFDEF Windows}
    Windows,
  {$ELSE}
    {$IFnDEF HASAMIGA}
      Unix, BaseUnix,
    {$ENDIF}
  {$ENDIF}
  Classes;

function GetTickCount64: QWord;
begin
  Result := SysUtils.GetTickCount64;
end;

// ToDo: Move the code to 1 include file per platform
{$IFDEF WINDOWS}
function NowUTC: TDateTime;
var
  SystemTime: TSystemTime;
begin
  windows.GetSystemTime(SystemTime{%H-});
  result := systemTimeToDateTime(SystemTime);
end;
{$ELSE WINDOWS}
{$IFDEF UNIX}
Const
{Date Translation}
  C1970=2440588;
  D0   =   1461;
  D1   = 146097;
  D2   =1721119;

Procedure JulianToGregorian(JulianDN:LongInt;out Year,Month,Day:Word);
Var
  YYear,XYear,Temp,TempMonth : LongInt;
Begin
  Temp:=((JulianDN-D2) shl 2)-1;
  JulianDN:=Temp Div D1;
  XYear:=(Temp Mod D1) or 3;
  YYear:=(XYear Div D0);
  Temp:=((((XYear mod D0)+4) shr 2)*5)-3;
  Day:=((Temp Mod 153)+5) Div 5;
  TempMonth:=Temp Div 153;
  If TempMonth>=10 Then
   Begin
     inc(YYear);
     dec(TempMonth,12);
   End;
  inc(TempMonth,3);
  Month := TempMonth;
  Year:=YYear+(JulianDN*100);
end;

Procedure EpochToLocal(epoch:longint;out year,month,day,hour,minute,second:Word);
{
  Transforms Epoch time into local time (hour, minute,seconds)
}
Var
  DateNum: LongInt;
Begin
  Datenum:=(Epoch Div 86400) + c1970;
  JulianToGregorian(DateNum,Year,Month,day);
  Epoch:=Abs(Epoch Mod 86400);
  Hour:=Epoch Div 3600;
  Epoch:=Epoch Mod 3600;
  Minute:=Epoch Div 60;
  Second:=Epoch Mod 60;
End;

function NowUTC: TDateTime;
var
  tz:timeval;
  SystemTime: TSystemTime;
begin
  fpgettimeofday(@tz,nil);
  EpochToLocal(tz.tv_sec,SystemTime.year,SystemTime.month,SystemTime.day,SystemTime.hour,SystemTime.Minute,SystemTime.Second);
  SystemTime.MilliSecond:=tz.tv_usec div 1000;
  result := systemTimeToDateTime(SystemTime);
end;

{$ELSE UNIX}
// Not Windows and not UNIX, so just write the most trivial code until we have something better:
function NowUTC: TDateTime;
begin
  Result := Now;
end;
{$ENDIF UNIX}
{$ENDIF WINDOWS}

end.

