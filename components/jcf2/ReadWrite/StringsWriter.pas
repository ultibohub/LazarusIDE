unit StringsWriter;

{
  Write converter output to strings
}

{(*}
(*------------------------------------------------------------------------------
 Delphi Code formatter source code 

The Original Code is StringsWriter, released May 2003.
The Initial Developer of the Original Code is Anthony Steele. 
Portions created by Anthony Steele are Copyright (C) 1999-2000 Anthony Steele.
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

{$mode delphi}

interface

uses
  Classes,
  { local }
  CodeWriter;

type
  TStringsWriter = class(TCodeWriter)
  private
    { properties }
    fcOutputStrings: TStrings;

  protected

  public
    constructor Create; override;
    procedure Close; override;

    property OutputStrings: TStrings Read fcOutputStrings Write fcOutputStrings;
  end;

implementation

{ TStringsWriter }
constructor TStringsWriter.Create;
begin
  inherited;
  fcOutputStrings := nil;
end;

procedure TStringsWriter.Close;
begin
  if BOF then
    exit;

  Assert(fcOutputStrings <> nil);

  BeforeWrite;
  fcOutputStrings.Text := fsDestText;
end;


end.
