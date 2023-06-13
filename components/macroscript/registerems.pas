unit RegisterEMS;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils,
  // LCL
  Dialogs,
  // LazUtils
  LazUtilities,
  // IdeIntf
  SrcEditorIntf, IDEOptionsIntf, IDEOptEditorIntf,
  // MacroScript
  EMScriptMacro, EMSSelfTest, EMSIdeOptions, EMSStrings;

procedure Register;

implementation

procedure Register;
var
  conf: TEMSConfig;
  ok: Boolean;
  OptionsGroup: Integer;
begin
  OptionsGroup := GetFreeIDEOptionsGroupIndex(GroupEditor);
  RegisterIDEOptionsGroup(OptionsGroup, TEMSConfig);
  RegisterIDEOptionsEditor(OptionsGroup, TEMSIdeOptionsFrame, 1);

  if not EMSSupported then {%H-}exit;

  if not (GetSkipCheckByKey('MacroScript') or GetSkipCheckByKey('All')) then begin

    conf := GetEMSConf;
    try
      conf.Load;
    except
      try
        conf.SelfTestFailed := EMSVersion;
        conf.SelfTestActive := False;
        conf.SelfTestError := 'load error';
        conf.Save;
      except
      end;
      MessageDlg(EmsSelfTestErrCaption,
                 format(EmsSelfTestFailedLastTime, [LineEnding]),
                 mtError, [mbOK], 0);
      MacroListViewerWarningText := EMSNotActiveVerbose;
      exit;
    end;

    if conf.SelfTestActive then begin
      conf.SelfTestFailed := EMSVersion;
      conf.SelfTestActive := False;
      conf.SelfTestError := 'failed last time';
      conf.Save;
      MessageDlg(EmsSelfTestErrCaption,
                 format(EmsSelfTestFailedLastTime, [LineEnding]),
                 mtError, [mbOK], 0);
    end;
    if conf.SelfTestFailed >= EMSVersion then begin
      MacroListViewerWarningText := EMSNotActiveVerbose;
      exit;
    end;

    conf.SelfTestActive := True;
    conf.Save;

    ok := False;
    try
      ok := DoSelfTest;
    except
    end;

    if not ok then begin
      conf.SelfTestFailed := EMSVersion;
      conf.SelfTestActive := False;
      conf.SelfTestError := SelfTestErrorMsg;
      conf.Save;
      MessageDlg(EmsSelfTestErrCaption,
                 format(EmsSelfTestFailed, [LineEnding, SelfTestErrorMsg]),
                 mtError, [mbOK], 0);

      MacroListViewerWarningText := EMSNotActiveVerbose;
      exit;
    end;

    conf.SelfTestActive := False;
    conf.SelfTestError := '';
    conf.SelfTestFailed := 0;
    conf.Save;
  end;

  EditorMacroPlayerClass := TEMSEditorMacro;
end;

end.

