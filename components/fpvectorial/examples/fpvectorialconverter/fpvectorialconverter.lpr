program fpvectorialconverter;

{$mode objfpc}{$H+}

uses
  Interfaces, // this includes the LCL widgetset
  Forms, fpvc_mainform, fpvectorialpkg;

{$R *.res}

begin
  Application.Initialize;
  Application.CreateForm(TformVectorialConverter, formVectorialConverter);
  Application.Run;
end.

