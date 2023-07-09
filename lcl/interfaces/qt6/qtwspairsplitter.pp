{
 *****************************************************************************
 *                            QtWSPairSplitter.pp                            * 
 *                            -------------------                            * 
 *                                                                           *
 *                                                                           *
 *****************************************************************************

 *****************************************************************************
  This file is part of the Lazarus Component Library (LCL)

  See the file COPYING.modifiedLGPL.txt, included in this distribution,
  for details about the license.
 *****************************************************************************
}
unit QtWSPairSplitter;

{$mode objfpc}{$H+}

interface

uses
////////////////////////////////////////////////////
// I M P O R T A N T                                
////////////////////////////////////////////////////
// To get as little as posible circles,
// uncomment only when needed for registration
////////////////////////////////////////////////////
//  PairSplitter,
////////////////////////////////////////////////////
  qt6, qtwidgets,
  Controls, LCLType, LCLProc,
  WSPairSplitter, WSLCLClasses;

type

  { TQtWSPairSplitterSide }

  TQtWSPairSplitterSide = class(TWSPairSplitterSide)
  published
    class function  CreateHandle(const AWinControl: TWinControl;
          const AParams: TCreateParams): TLCLHandle; override;
  end;

  { TQtWSCustomPairSplitter }

  TQtWSCustomPairSplitter = class(TWSCustomPairSplitter)
  published
  end;

implementation

{ TQtWSPairSplitterSide }

class function TQtWSPairSplitterSide.CreateHandle(
  const AWinControl: TWinControl; const AParams: TCreateParams
  ): TLCLHandle;
var
  QtWidget: TQtWidget;
begin
  {$ifdef VerboseQt}
    WriteLn('> TQtWSPairSplitterSide.CreateHandle for ',dbgsname(AWinControl));
  {$endif}
  QtWidget := TQtWidget.Create(AWinControl, AParams);
  QtWidget.setAttribute(QtWA_NoMousePropagation, True);

  QtWidget.AttachEvents;

  Result := TLCLHandle(QtWidget);

  {$ifdef VerboseQt}
    WriteLn('< TQtWSPairSplitterSide.CreateHandle for ',dbgsname(AWinControl),' Result: ', dbgHex(Result));
  {$endif}
end;

end.
