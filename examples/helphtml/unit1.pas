{
 ***************************************************************************
 *                                                                         *
 *   This source is free software; you can redistribute it and/or modify   *
 *   it under the terms of the GNU General Public License as published by  *
 *   the Free Software Foundation; either version 2 of the License, or     *
 *   (at your option) any later version.                                   *
 *                                                                         *
 *   This code is distributed in the hope that it will be useful, but      *
 *   WITHOUT ANY WARRANTY; without even the implied warranty of            *
 *   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU     *
 *   General Public License for more details.                              *
 *                                                                         *
 *   A copy of the GNU General Public License is available on the World    *
 *   Wide Web at <http://www.gnu.org/copyleft/gpl.html>. You can also      *
 *   obtain it by writing to the Free Software Foundation,                 *
 *   Inc., 51 Franklin Street - Fifth Floor, Boston, MA 02110-1335, USA.   *
 *                                                                         *
 ***************************************************************************

  Abstract:
    This example demonstrates the html help components.
    
    THTMLHelpDatabase is a database - it contains the mapping from Keyword to
    page.

    THTMLBrowserHelpViewer is a viewer for HTML pages. It simply starts a
    browser.
    
  How was the example created:
      Put a THTMLHelpDatabase on a form.
      Set AutoRegister to true.
      Set KeywordPrefix to 'HTML/'
      Set BaseURL to 'file://html/'

      Put a THTMLBrowserHelpViewer on the form.
      Set AutoRegister to true.

      Put a TEdit on a form.
      Set HelpType to htKeyword
      Set HelpKeyword to 'HTML/edit1.html'

      Run the program.
      Focus the edit field and press F1. A browser will be started to show
      the page 'html/edit1.html'.

}
unit Unit1;

{$mode objfpc}{$H+}

interface

uses
  Forms, StdCtrls, LazHelpHTML, HelpIntfs;

type

  { TForm1 }

  TForm1 = class(TForm)
    HelpButton: TButton;
    Edit1: TEdit;
    Edit2: TEdit;
    HTMLBrowserHelpViewer1: THTMLBrowserHelpViewer;
    HTMLHelpDatabase1: THTMLHelpDatabase;
    procedure FormCreate(Sender: TObject);
    procedure HelpButtonClick(Sender: TObject);
  private
    { private declarations }
  public
    { public declarations }
  end; 

var
  Form1: TForm1; 

implementation

{ TForm1 }

procedure TForm1.HelpButtonClick(Sender: TObject);
begin
  // This demonstrates how to show a help item manually:
  ShowHelpOrErrorForKeyword('','HTML/index.html');
end;

procedure TForm1.FormCreate(Sender: TObject);
const
  {$IFDEF Darwin}
  HelpShortcut = #$e2#$8c#$98'?';
  {$ELSE}
  HelpShortcut = 'F1';
  {$ENDIF}
begin
  HTMLHelpDatabase1.BaseURL:='file://html';
  Edit1.Text:='Edit1 - Press '+HelpShortcut+' for help';
  Edit2.Text:='Edit2 - Press '+HelpShortcut+' for help';
end;

{$R *.lfm}

end.

