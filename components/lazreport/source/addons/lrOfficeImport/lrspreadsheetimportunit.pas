{ LazReport dialogs control

  Copyright (C) 2012-2013 alexs alexs75.at.hotbox.ru

  This library is free software; you can redistribute it and/or modify it
  under the terms of the GNU Library General Public License as published by
  the Free Software Foundation; either version 2 of the License, or (at your
  option) any later version with the following modification:

  As a special exception, the copyright holders of this library give you
  permission to link this library with independent modules to produce an
  executable, regardless of the license terms of these independent modules,and
  to copy and distribute the resulting executable under terms of your choice,
  provided that you also meet, for each linked independent module, the terms
  and conditions of the license of that module. An independent module is a
  module which is not derived from or based on this library. If you modify
  this library, you may extend this exception to your version of the library,
  but you are not obligated to do so. If you do not wish to do so, delete this
  exception statement from your version.

  This program is distributed in the hope that it will be useful, but WITHOUT
  ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or
  FITNESS FOR A PARTICULAR PURPOSE. See the GNU Library General Public License
  for more details.

  You should have received a copy of the GNU Library General Public License
  along with this library; if not, write to the Free Software Foundation,
  Inc., 51 Franklin Street - Fifth Floor, Boston, MA 02110-1335, USA.
}

unit lrSpreadSheetImportUnit;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, Forms, Controls, Graphics, Dialogs, StdCtrls,
  ButtonPanel, EditBtn, fpspreadsheet, fpsTypes, LR_Class;

type

  { TlrSpreadSheetImportForm }

  TlrSpreadSheetImportForm = class(TForm)
    ButtonPanel1: TButtonPanel;
    CheckBox1: TCheckBox;
    Edit1: TEdit;
    Edit2: TEdit;
    Edit3: TEdit;
    Edit4: TEdit;
    Edit5: TEdit;
    FileNameEdit1: TFileNameEdit;
    Label1: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    Label4: TLabel;
    procedure FormClose(Sender: TObject; var CloseAction: TCloseAction);
  private
    FWorkbook: TsWorkbook;
    FWorksheet: TsWorksheet;
    procedure DoImportFile;
    function CalcColWidth(AWidth: Single): Integer;
    function CalcRowHeight(AHeight: Single): Integer;
    procedure Convert_sFont_to_Font(sFont: TsFont; AFont: TFont);
  public
    { public declarations }
  end;

var
  lrSpreadSheetImportForm: TlrSpreadSheetImportForm;

implementation
uses fpsutils;

{$R *.lfm}

function sHAToA(AValue:TsHorAlignment):TAlignment; inline;
const
  A:array [TsHorAlignment] of TAlignment =
    //haDefault, haLeft, haCenter, haRight
     (taLeftJustify, taLeftJustify, taCenter, taRightJustify,
      taLeftJustify, taLeftJustify, taLeftJustify);
begin
  Result:=A[AValue];
end;


//TsVertAlignment = (vaDefault, vaTop, vaCenter, vaBottom);
//TTextLayout = (tlTop, tlCenter, tlBottom);
function sVAToL(AValue:TsVertAlignment):TTextLayout; inline;
const
  A:array [TsVertAlignment] of TTextLayout =
    //vaDefault, vaTop, vaCenter, vaBottom
     (tlTop, tlTop, tlCenter, tlBottom);
begin
  Result:=A[AValue];
end;


function sBorderToBorders(AValue:TsCellBorders):TfrFrameBorders;
//TfrFrameBorder = (frbLeft, frbTop, frbRight, frbBottom);
//TfrFrameBorders = set of TfrFrameBorder;
//TsCellBorder = (cbNorth, cbWest, cbEast, cbSouth, cbDiagUp, cbDiagDown);
//TsCellBorders = set of TsCellBorder;
begin
  Result:=[];
  if cbNorth in AValue then
    Result:= Result + [frbTop];
  if cbWest in AValue then
    Result:= Result + [frbLeft];
  if cbEast in AValue then
    Result:= Result + [frbRight];
  if cbSouth in AValue then
    Result:= Result + [frbBottom];
end;

{ TlrSpreadSheetImportForm }

procedure TlrSpreadSheetImportForm.FormClose(Sender: TObject;
  var CloseAction: TCloseAction);
begin
  if ModalResult = mrOk then
    DoImportFile;
end;

procedure TlrSpreadSheetImportForm.DoImportFile;
var
  Cell:PCell;
  X, Y, DX, DY: Integer;
  Row: Integer;
  Col, DY1, DX1: Integer;
  T:TfrMemoView;
  AR1, AC1, AR2, AC2, i: Cardinal;
begin
  // Create the spreadsheet
  FWorkbook := TsWorkbook.Create;

  FWorkbook.ReadFromFile(FileNameEdit1.FileName);

  FWorksheet := FWorkbook.GetFirstWorksheet;

  Y:=0;
  for Row:=0 to FWorksheet.GetLastRowIndex do
  begin
    X:=0;
    DY:=CalcRowHeight(FWorksheet.GetRowHeight(Row));
    for Col:=0 to FWorksheet.GetLastColIndex do
    begin
      Cell := FWorksheet.FindCell(Row, Col);

      if Assigned(Cell) then
      begin
        if FWorksheet.IsMerged(Cell) then
        begin
          if not FWorksheet.IsMergeBase(Cell) then
          begin
            Inc(X, CalcColWidth(FWorksheet.GetColWidth(Col)));
            Continue;
          end;

          FWorksheet.FindMergedRange(Cell, AR1, AC1, AR2, AC2);
          DX1:=0;
          DY1:=0;

          for i:=AC1 to AC2 do
            DX1:=DX1 +CalcColWidth(FWorksheet.GetColWidth(I));
          for i:=AR1 to AR2 do
            DY1:=DY1 +CalcRowHeight(FWorksheet.GetRowHeight(I));
        end
        else
        begin
          DX1:=CalcColWidth(FWorksheet.GetColWidth(Col));
          DY1:=DY;
        end;

        T := frCreateObject(gtMemo, '', frDesigner.Page) as TfrMemoView;

        if not CheckBox1.Checked then
          T.CreateUniqueName
        else
          T.Name:=Format('Memo_Imp_%d_%d', [Col, Row]);

        T.x := x;
        T.y := y;
        T.dx:=DX1;
        T.dy:=DY1;

        T.Alignment:=sHAToA(FWorksheet.ReadHorAlignment(Cell));
        T.Layout:=sVAToL(FWorksheet.ReadVertAlignment(Cell));

        T.Frames:=sBorderToBorders(FWorksheet.ReadCellBorders(Cell));

{
        if Cell^.BackgroundColor < FWorkbook.GetPaletteSize then
          T.FillColor:=FWorkbook.GetPaletteColor(Cell^.BackgroundColor);
}
        T.FillColor:=FWorksheet.ReadBackgroundColor(Cell);
        Convert_sFont_to_Font(FWorksheet.ReadCellFont(Cell), T.Font);

        T.MonitorFontChanges;
        T.Memo.Text:=FWorksheet.ReadAsUTF8Text(Cell);

      end
      else
      begin
        T:=nil;
      end;
      Inc(X, CalcColWidth(FWorksheet.GetColWidth(Col)));
    end;
    Inc(Y, DY);
  end;

  // Finalization
  FWorksheet.Free;
end;

function TlrSpreadSheetImportForm.CalcColWidth(AWidth: Single): Integer;
var
  w0: Integer;
begin
  Convert_sFont_to_Font(FWorkbook.GetFont(0), Canvas.Font);
  w0 := Canvas.TextWidth('0');
  Result := Round(AWidth * w0);
end;

function TlrSpreadSheetImportForm.CalcRowHeight(AHeight: Single): Integer;
var
  h_pts: Single;
begin
  h_pts := AHeight * (FWorkbook.GetFont(0).Size + ROW_HEIGHT_CORRECTION);
  Result := PtsToPX(h_pts, Screen.PixelsPerInch) + 4;
end;

procedure TlrSpreadSheetImportForm.Convert_sFont_to_Font(sFont: TsFont;
  AFont: TFont);
begin
  if Assigned(AFont) and Assigned(sFont) then
  begin
    AFont.Name := sFont.FontName;
    AFont.Size := round(sFont.Size);
    AFont.Style := [];
    if fssBold in sFont.Style then AFont.Style := AFont.Style + [fsBold];
    if fssItalic in sFont.Style then AFont.Style := AFont.Style + [fsItalic];
    if fssUnderline in sFont.Style then AFont.Style := AFont.Style + [fsUnderline];
    if fssStrikeout in sFont.Style then AFont.Style := AFont.Style + [fsStrikeout];
    AFont.Color := sFont.Color;
  end;
end;

end.

