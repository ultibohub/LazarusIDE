unit EditorConverter;

{(*}
(*------------------------------------------------------------------------------
 Delphi Code formatter source code

The Original Code is EditorConverter.pas, released January 2001.
The Initial Developer of the Original Code is Anthony Steele.
Portions created by Anthony Steele are Copyright (C) 2001 Anthony Steele.
All Rights Reserved. 
Contributor(s): Anthony Steele.

The contents of this file are subject to the Mozilla Public License Version 1.1
(the "License"). you may not use this file except in compliance with the License.
You may obtain a copy of the License at http://www.mozilla.org/NPL/

Software distributed under the License is distributed on an "AS IS" basis,
WITHOUT WARRANTY OF ANY KIND, either express or implied.
See the License for the specific language governing rights and limitations
under the License.

Alternatively, the contents of this file may be used under the terms of
the GNU General Public License Version 2 or later (the "GPL") 
See http://www.gnu.org/licenses/gpl.html
------------------------------------------------------------------------------*)
{*)}

{ AFS 12 Jan 2K
  Converter class for the IDE pluggin
}

{$I JcfGlobal.inc}

interface

uses
  Classes, SysUtils,
  SrcEditorIntf,
  { local }
  Converter, ConvertTypes;

type

  TEditorConverter = class(TObject)
  private
    { the string -> string converter }
    fcConverter: TConverter;
    { state }
    fOnStatusMessage: TStatusMessageProc;
    fsCurrentUnitName: string;
    fiConvertCount: integer;
    fOnIncludeFile: TOnIncludeFile;
    prOcedure SendStatusMessage(const psUnit, psMessage: string;
      const peMessageType: TStatusMessageType;
      const piY, piX: integer);

    function GetOnStatusMessage: TStatusMessageProc;
    procedure SetOnStatusMessage(const Value: TStatusMessageProc);

    function ReadFromIDE(const pcUnit: TSourceEditorInterface): string;
    procedure WriteToIDE(const pcUnit: TSourceEditorInterface; const psText: string);

    procedure FinalSummary;
    function OriginalFileName: string;

  protected

  public
    constructor Create;
    destructor Destroy; override;
    procedure Convert(const pciUnit: TSourceEditorInterface);
    procedure Clear;
    function ConvertError: Boolean;
    function TokenCount: integer;

    procedure BeforeConvert;
    procedure AfterConvert;

    property OnStatusMessage: TStatusMessageProc read GetOnStatusMessage write SetOnStatusMessage;
    property OnIncludeFile: TOnIncludeFile Read fOnIncludeFile Write fOnIncludeFile;
  end;


implementation

uses
  { local }
  JcfLog, JcfRegistrySettings, diffmerge;

constructor TEditorConverter.Create;
begin
  inherited;
  
  fcConverter := TConverter.Create;
  fcConverter.OnStatusMessage := SendStatusMessage;
end;

destructor TEditorConverter.Destroy;
begin
  FreeAndNil(fcConverter);
  inherited;
end;

procedure TEditorConverter.Convert(const pciUnit: TSourceEditorInterface);
begin
  Assert(pciUnit <> nil);

  if not GetRegSettings.HasRead then
    GetRegSettings.ReadAll;

  { check for read-only  }
  if pciUnit.ReadOnly then
  begin
    SendStatusMessage(pciUnit.FileName, 'Unit is read only. Cannot format ',
      mtInputError, -1, -1);
    exit;
  end;

  fsCurrentUnitName := pciUnit.FileName;
  fcConverter.InputCode := ReadFromIDE(pciUnit);

  // now convert
  fcConverter.FileName := fsCurrentUnitName;
  fcConverter.OnIncludeFile := OnIncludeFile;
  fcConverter.Convert;
  fsCurrentUnitName := '';
  if not ConvertError then
  begin
    WriteToIDE(pciUnit, fcConverter.OutputCode);
    SendStatusMessage(pciUnit.FileName, 'Formatted unit', mtProgress, -1, -1);
    Inc(fiConvertCount);
  end;
end;

function TEditorConverter.ReadFromIDE(const pcUnit: TSourceEditorInterface): string;
begin
  Result := pcUnit.Lines.Text;
end;

procedure TEditorConverter.WriteToIDE(const pcUnit: TSourceEditorInterface; const psText: string);
begin
  if pcUnit = nil then
    exit;
  if psText <> fcConverter.InputCode then
    DiffMergeEditor(pcUnit, psText);
end;

procedure TEditorConverter.AfterConvert;
begin
  FinalSummary;
  Log.CloseLog;

  if GetRegSettings.ViewLogAfterRun then
    GetRegSettings.ViewLog;
end;

procedure TEditorConverter.Clear;
begin
  fcConverter.Clear;
end;

function TEditorConverter.ConvertError: Boolean;
begin
  Result := fcConverter.ConvertError;
end;

function TEditorConverter.GetOnStatusMessage: TStatusMessageProc;
begin
  Result := fOnStatusMessage;
end;

function TEditorConverter.OriginalFileName: string;
begin
  if fsCurrentUnitName <> '' then
    Result := fsCurrentUnitName
  else
    Result := 'IDE';
end;

procedure TEditorConverter.SendStatusMessage(const psUnit, psMessage: string;
  const peMessageType: TStatusMessageType;
  const piY, piX: integer);
var
  lsUnit: string;
begin
  lsUnit := psUnit;
  if lsUnit = '' then
    lsUnit := OriginalFileName;

  if Assigned(fOnStatusMessage) then
    fOnStatusMessage(lsUnit, psMessage, peMessageType, piY, piX);
end;

procedure TEditorConverter.SetOnStatusMessage(const Value: TStatusMessageProc);
begin
  fOnStatusMessage := Value;
end;

function TEditorConverter.TokenCount: integer;
begin
  Result := fcConverter.TokenCount;
end;

procedure TEditorConverter.FinalSummary;
var
  lsMessage: string;
begin
  if fiConvertCount = 0 then
  begin
    if ConvertError then
      lsMessage := 'Aborted due to error'
    else
      lsMessage := 'Nothing done';
  end
  {
  else if fbAbort then
    lsMessage := 'Aborted after ' + DescribeFileCount(fiConvertCount)
  }
  else if fiConvertCount > 1 then
    lsMessage := 'Finished processing ' + DescribeFileCount(fiConvertCount)
  else
    lsMessage := '';

  if lsMessage <> '' then
    SendStatusMessage('', lsMessage, mtFinalSummary, -1, -1);

  Log.EmptyLine;
  Log.Write(lsMessage);
end;

procedure TEditorConverter.BeforeConvert;
begin
  fiConvertCount := 0;
end;

end.
