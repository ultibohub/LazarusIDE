{
 *****************************************************************************
 *                              CarbonWSCalendar.pp                          *
 *                              ---------------                              * 
 *                                                                           *
 *                                                                           *
 *****************************************************************************

 *****************************************************************************
  This file is part of the Lazarus Component Library (LCL)

  See the file COPYING.modifiedLGPL.txt, included in this distribution,
  for details about the license.
 *****************************************************************************
}
unit CarbonWSCalendar;

{$mode objfpc}{$H+}

interface

////////////////////////////////////////////////////
// I M P O R T A N T
////////////////////////////////////////////////////
// To get as little as posible circles,
// uncomment only when needed for registration
////////////////////////////////////////////////////

uses
  Types,
  LCLType, Controls, Calendar,
  WSCalendar, WSLCLClasses,
  CarbonDef, CarbonCalendar;

type

  { TCarbonWSCustomCalendar }

  TCarbonWSCustomCalendar = class(TWSCustomCalendar)
  published
    class function CreateHandle(const AWinControl: TWinControl; const AParams: TCreateParams): TLCLHandle; override;
    class function GetDateTime(const ACalendar: TCustomCalendar): TDateTime; override;
    class procedure SetDateTime(const ACalendar: TCustomCalendar; const ADateTime: TDateTime); override;
    class function HitTest(const ACalendar: TCustomCalendar; const APoint: TPoint): TCalendarPart; override;
    class procedure SetDisplaySettings(const {%H-}ACalendar: TCustomCalendar;
      const {%H-}ADisplaySettings: TDisplaySettings); override;
  end;


implementation

{ TCarbonWSCustomCalendar }

class function TCarbonWSCustomCalendar.CreateHandle(const AWinControl: TWinControl;
  const AParams: TCreateParams): TLCLHandle;
begin
  Result := TLCLHandle(TCarbonCalendar.Create(AWinControl, AParams));
end;

class function TCarbonWSCustomCalendar.GetDateTime(const ACalendar: TCustomCalendar): TDateTime;
begin
  if not CheckHandle(ACalendar, Self, 'GetDateTime') then Exit;
  Result := TCarbonCalendar(ACalendar.Handle).DateTime;
end;

class procedure TCarbonWSCustomCalendar.SetDateTime(const ACalendar: TCustomCalendar; const ADateTime: TDateTime);
begin
  if not CheckHandle(ACalendar, Self, 'SetDateTime') then Exit;
  TCarbonCalendar(ACalendar.Handle).DateTime := ADateTime;
end;

class function TCarbonWSCustomCalendar.HitTest(
  const ACalendar: TCustomCalendar; const APoint: TPoint): TCalendarPart;
begin
  //TODO
  Result:=inherited HitTest(ACalendar, APoint);
end;

class procedure TCarbonWSCustomCalendar.SetDisplaySettings(
  const ACalendar: TCustomCalendar; const ADisplaySettings: TDisplaySettings);
begin
  //TODO:
end;

initialization

////////////////////////////////////////////////////
// I M P O R T A N T
////////////////////////////////////////////////////
// To improve speed, register only classes
// which actually implement something
////////////////////////////////////////////////////
//  RegisterWSComponent(TCustomCalendar, TCarbonWSCustomCalendar);
////////////////////////////////////////////////////
end.
