unit frmTemplateVariables;

{$mode objfpc}{$H+}

interface

uses
  Classes,
  // LCL
  Controls, Forms, ExtCtrls, Grids, StdCtrls, EditBtn, ButtonPanel,
  // ProjectTemplates
  ProjectTemplates, ptstrconst;

type

  { TProjectVariablesForm }

  TProjectVariablesForm = class(TForm)
    ButtonPanel1: TButtonPanel;
    DEDestDir: TDirectoryEdit;
    EProjectName: TEdit;
    ProjNameLabel: TLabel;
    DEDestDirLabel: TLabel;
    PDescription: TPanel;
    SGVariables: TStringGrid;
    procedure BOKClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure ProjectVariablesFormShow(Sender: TObject);
    procedure SGVariablesSelectEditor(Sender: TObject; aCol, aRow: Integer;
      var Editor: TWinControl);
  private
    FSChanged: Boolean;
    FTemplates: TProjectTemplates;
    FVariables : TStrings;
    function GetProjectDir: String;
    function GetProjectName: String;
    procedure SetVariables(const AValue: TStrings);
  public
    Property Templates : TProjectTemplates Read FTemplates Write FTemplates;
    Property ProjectName : String Read GetProjectName;
    Property ProjectDir : String Read GetProjectDir;
    Property Variables : TStrings Read FVariables Write SetVariables;
    Property SettingsChanged: Boolean Read FSChanged Write FSChanged;
  end;

var
  ProjectVariablesForm: TProjectVariablesForm;

implementation

{$R *.lfm}

{ TProjectVariablesForm }

procedure TProjectVariablesForm.ProjectVariablesFormShow(Sender: TObject);
begin
  SGVariables.Cells[0,0]:=SVariable;
  SGVariables.Cells[1,0]:=SValue;
  SGVariables.Cells[2,0]:=SDescription;
end;

procedure TProjectVariablesForm.SGVariablesSelectEditor(Sender: TObject; aCol,
  aRow: Integer; var Editor: TWinControl);
begin
  if aCol<>1 then
    Editor:=nil;
end;

procedure TProjectVariablesForm.BOKClick(Sender: TObject);

Var
  N,V : String;
  I : Integer;
begin
  For I:=0 to FVariables.Count-1 do
    begin
    V:='';
    N:='';
    FVariables.GetNameValue(I,N,V);
    V:=SGVariables.Cells[1,I+1];
    FVariables[i]:=N+'='+V;
    end;
end;

procedure TProjectVariablesForm.FormCreate(Sender: TObject);
begin
  Caption := SNewFromTemplate;
  ProjNameLabel.Caption:= SNameforProject;
  DEDestDirLabel.Caption:= SCreateinDir;
  PDescription.Caption:= SThisProject;
end;

procedure TProjectVariablesForm.SetVariables(const AValue: TStrings);

Var
  N,V : String;
  I,J : Integer;
  
begin
  FVariables:=AValue;
  If (FVariables.Count=0) then
    begin
    SGVariables.Enabled:=False;
    PDescription.Caption:=SNoAdditionalVars;
    end
  else
    begin
    SGVariables.RowCount:=FVariables.Count+1;
    For I:=1 to FVariables.Count do
      begin
      FVariables.GetNameValue(I-1,N,V);
      SGVariables.Cells[0,I]:=N;
      J:=Pos('|',V);
      if J>0 then
        begin
        SGVariables.Cells[1,I]:=copy(V,J+1,Length(V));
        SGVariables.Cells[2,I]:=copy(V,1,J-1);
        end
      else
        begin
        SGVariables.Cells[1,I]:='';
        SGVariables.Cells[2,I]:=V;
        end;
      end;
    end;
end;

function TProjectVariablesForm.GetProjectDir: String;
begin
  Result:=DEDestDir.Text;
end;

function TProjectVariablesForm.GetProjectName: String;
begin
  Result:=EProjectName.Text;
end;

end.

