{
 *****************************************************************************
 *                              QtWSDesigner.pp                              * 
 *                               ------------                                * 
 *                                                                           *
 *                                                                           *
 *****************************************************************************

 *****************************************************************************
  This file is part of the Lazarus Component Library (LCL)

  See the file COPYING.modifiedLGPL.txt, included in this distribution,
  for details about the license.
 *****************************************************************************
}
unit QtWSDesigner;

{$mode objfpc}{$H+}

interface

{$I qtdefines.inc}

////////////////////////////////////////////////////
// I M P O R T A N T                                
////////////////////////////////////////////////////
// 1) Only class methods allowed
// 2) Class methods have to be published and virtual
// 3) To get as little as posible circles, the uses
//    clause should contain only those LCL units 
//    needed for registration. WSxxx units are OK
// 4) To improve speed, register only classes in the 
//    initialization section which actually 
//    implement something
// 5) To enable your XXX widgetset units, look at
//    the uses clause of the XXXintf.pp
////////////////////////////////////////////////////
uses
  // Bindings
  qt6,
  qtwidgets,
// LCL
  Classes, Controls, RubberBand, LCLType,
// Widgetset
  WsLCLClasses, WsDesigner, WsProc;

type
  { TWsCustomRubberBand }

  { TQtWsCustomRubberBand }

  TQtWsCustomRubberBand = class(TWsCustomRubberBand)
  published
    class function  CreateHandle(const AWinControl: TWinControl; const AParams: TCreateParams): TLCLIntfHandle; override;
    class procedure SetShape(ARubberBand: TCustomRubberBand; AShape: TRubberBandShape); override;
  end;

implementation
const
  RubberBandShapeMap: array[TRubberBandShape] of QRubberBandShape =
  (
    QRubberBandLine,
    QRubberBandRectangle
  );

{ TQtWsCustomRubberBand }

class function TQtWsCustomRubberBand.CreateHandle(
  const AWinControl: TWinControl; const AParams: TCreateParams
  ): TLCLIntfHandle;
var
  QtRubberBand: TQtRubberBand;
begin
  QtRubberBand := TQtRubberBand.Create(AWinControl, AParams);
  QtRubberBand.AttachEvents;
  QtRubberBand.setShape(RubberBandShapeMap[TCustomRubberBand(AWinControl).Shape]);

  Result := TLCLIntfHandle(QtRubberBand);
end;

class procedure TQtWsCustomRubberBand.SetShape(ARubberBand: TCustomRubberBand;
  AShape: TRubberBandShape);
begin
  if not WSCheckHandleAllocated(ARubberBand, 'SetShape') then
    Exit;
  TQtRubberBand(ARubberBand.Handle).setShape(RubberBandShapeMap[AShape]);
end;

end.
