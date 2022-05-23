unit MainUnit;

{$mode objfpc}{$H+}

interface

uses
  Classes, TypInfo, Forms, Controls, StdCtrls,
  ObjectInspector, PropEdits, PropEditUtils, GraphPropEdits;

type
  { TMyComponent }

  TMyComponent = class(TComponent)
  private
    FAnInteger: integer;
    FWideStr: widestring;
    FUnicodeStr: unicodestring;
    FAnsiStr: ansistring;
    procedure SetAnInteger(const AValue: integer);
  public
  published
    property AnInteger: integer read FAnInteger write SetAnInteger;
    property WideStr: widestring read FWideStr write FWideStr;
    property UnicodeStr: unicodestring read FUnicodeStr write FUnicodeStr;
    property AnsiStr: ansistring read FAnsiStr write FAnsiStr;
  end;

  { TForm1 }

  TForm1 = class(TForm)
    PropGridGroupbox: TGroupBox;
    SetCompAsOIRootButton: TButton;
    SetOIRootFormButton: TButton;
    OIGroupbox: TGroupBox;
    PropertyGrid: TOIPropertyGrid;
    procedure Form1Create(Sender: TObject);
    procedure Form1Destroy(Sender: TObject);
    procedure SetOIRootFormButtonClick(Sender: TObject);
    procedure SetCompAsOIRootButtonClick(Sender: TObject);
  private
    procedure SetObjectInspectorRoot(AComponent: TComponent);
  protected
    function GetOwner: TPersistent; override;
  public
    TheObjectInspector: TObjectInspectorDlg;
    ThePropertyEditorHook: TPropertyEditorHook;
    ARootComponent: TMyComponent;
  end;

var
  Form1: TForm1; 

implementation

{ TForm1 }

procedure TForm1.Form1Create(Sender: TObject);
begin
  // create the PropertyEditorHook (the interface to the properties)
  ThePropertyEditorHook:=TPropertyEditorHook.Create(nil);

  // create the ObjectInspector
  TheObjectInspector:=TObjectInspectorDlg.Create(Application);
  TheObjectInspector.PropertyEditorHook:=ThePropertyEditorHook;
  TheObjectInspector.SetBounds(10,10,240,500);

  // create a second Root component for demonstration
  ARootComponent:=TMyComponent.Create(nil);

  // create the PropertyGrid
  PropertyGrid:=TOIPropertyGrid.CreateWithParams(Self,ThePropertyEditorHook,
                                                 AllTypeKinds,25);
  with PropertyGrid do begin
    Name:='PropertyGrid';
    Parent:=PropGridGroupbox;
    Align:=alClient;
  end;
  
  // select the Form1 in the ObjectInspector
  SetObjectInspectorRoot(Self);
  TheObjectInspector.Show;         // For some reason this is not shown otherwise
end;

procedure TForm1.Form1Destroy(Sender: TObject);
begin
  // TheObjectInspector is owned by Application and therefore destroyed automatically
  ThePropertyEditorHook.Free;
  ARootComponent.Free;
end;

procedure TForm1.SetOIRootFormButtonClick(Sender: TObject);
begin
  SetObjectInspectorRoot(Self);
end;

procedure TForm1.SetCompAsOIRootButtonClick(Sender: TObject);
begin
  SetObjectInspectorRoot(ARootComponent);
end;

procedure TForm1.SetObjectInspectorRoot(AComponent: TComponent);
var
  Selection: TPersistentSelectionList;
begin
  ThePropertyEditorHook.LookupRoot:=AComponent;
  Selection:=TPersistentSelectionList.Create;
  Selection.Add(AComponent);
  TheObjectInspector.Selection:=Selection;
  PropertyGrid.Selection:=Selection;
  Selection.Free;
end;

function TForm1.GetOwner: TPersistent;
begin
  // this form is the LookupRoot => GetOwner must be nil
  // see GetLookupRootForComponent
  Result:=nil;
end;

{ TMyComponent }

procedure TMyComponent.SetAnInteger(const AValue: integer);
begin
  if FAnInteger=AValue then exit;
  FAnInteger:=AValue;
end;

{$R *.lfm}

end.

