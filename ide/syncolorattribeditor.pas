unit SynColorAttribEditor;

{$mode objfpc}{$H+}

interface

uses
  Classes, Controls, sysutils, types, typinfo, math, FPCanvas,
  // LCL
  LCLIntf, Forms, StdCtrls, ExtCtrls, Graphics, GraphUtil,
  ColorBox, Dialogs, Menus, Spin,
  // IdeIntf
  EditorSyntaxHighlighterDef,
  // SynEdit
  SynEditTypes, SynHighlighterPas, LazEditTextAttributes,
  // IdeConfig
  EnvironmentOpts,
  // IDE
  EditorOptions, SourceMarks, LazarusIDEStrConsts;

type

  { TSynColorAttrEditor }

  TSynColorAttrEditor = class(TFrame)
    BackPriorLabel: TLabel;
    BackPriorSpin: TSpinEdit;
    BackGroundColorBox: TColorBox;
    BackGroundLabel: TLabel;
    ColorDialog1: TColorDialog;
    FeaturePastEOLCheckBox: TCheckBox;
    dropCustomWordKind: TComboBox;
    ForePriorLabel: TLabel;
    ForePriorSpin: TSpinEdit;
    lbFiller1: TLabel;
    lbCustomWords: TLabel;
    lbFiller10: TLabel;
    lbFiller2: TLabel;
    lbFiller3: TLabel;
    lbFiller4: TLabel;
    lbFiller5: TLabel;
    lbFiller6: TLabel;
    lbFiller7: TLabel;
    lbFiller8: TLabel;
    lbFiller9: TLabel;
    lblInfo: TLabel;
    MarkupFoldStyleBox: TComboBox;
    MarkupFoldAlphaSpin: TSpinEdit;
    MarkupFoldAlphaLabel: TLabel;
    MarkupFoldColorUseDefaultCheckBox: TCheckBox;
    MarkupFoldColorBox: TColorBox;
    FramePriorSpin: TSpinEdit;
    FramePriorLabel: TLabel;
    FrameStyleBox: TComboBox;
    FrameEdgesBox: TComboBox;
    FrameColorBox: TColorBox;
    BackGroundUseDefaultCheckBox: TCheckBox;
    FrameColorUseDefaultCheckBox: TCheckBox;
    ForegroundColorBox: TColorBox;
    ForeAlphaLabel: TLabel;
    BackAlphaLabel: TLabel;
    FrameAlphaLabel: TLabel;
    edCustomWord: TMemo;
    Panel1: TPanel;
    Panel10: TPanel;
    Panel11: TPanel;
    Panel12: TPanel;
    Panel13: TPanel;
    Panel14: TPanel;
    Panel15: TPanel;
    Panel16: TPanel;
    Panel17: TPanel;
    Panel18: TPanel;
    Panel19: TPanel;
    Panel2: TPanel;
    Panel20: TPanel;
    Panel21: TPanel;
    Panel22: TPanel;
    PnlFeaturePastEOL: TPanel;
    pnlWords: TPanel;
    Panel3: TPanel;
    Panel4: TPanel;
    Panel5: TPanel;
    Panel6: TPanel;
    Panel7: TPanel;
    Panel8: TPanel;
    Panel9: TPanel;
    pnlFrameHost2: TPanel;
    pnlFrameHost1: TPanel;
    pnlForegroundName: TPanel;
    pnlBackgroundName: TPanel;
    pnlUnderline: TPanel;
    pnlBold: TPanel;
    pnlItalic: TPanel;
    ForeAlphaSpin: TSpinEdit;
    BackAlphaSpin: TSpinEdit;
    FrameAlphaSpin: TSpinEdit;
    TextBoldCheckBox: TCheckBox;
    TextBoldRadioInvert: TRadioButton;
    TextBoldRadioOff: TRadioButton;
    TextBoldRadioOn: TRadioButton;
    TextBoldRadioPanel: TPanel;
    TextItalicCheckBox: TCheckBox;
    TextItalicRadioInvert: TRadioButton;
    TextItalicRadioOff: TRadioButton;
    TextItalicRadioOn: TRadioButton;
    TextItalicRadioPanel: TPanel;
    TextUnderlineCheckBox: TCheckBox;
    TextUnderlineRadioInvert: TRadioButton;
    TextUnderlineRadioOff: TRadioButton;
    TextUnderlineRadioOn: TRadioButton;
    TextUnderlineRadioPanel: TPanel;
    ForeGroundLabel: TLabel;
    ForeGroundUseDefaultCheckBox: TCheckBox;
    procedure dropCustomWordKindChange(Sender: TObject);
    procedure edCustomWordChange(Sender: TObject);
    procedure GeneralAlphaSpinOnChange(Sender: TObject);
    procedure GeneralAlphaSpinOnEnter(Sender: TObject);
    procedure GeneralColorBoxOnChange(Sender: TObject);
    procedure GeneralColorBoxOnGetColors(Sender: TCustomColorBox; Items: TStrings);
    procedure GeneralPriorSpinOnChange(Sender: TObject);
    procedure FrameEdgesBoxDrawItem(Control: TWinControl; Index: Integer; ARect: TRect;
      {%H-}State: TOwnerDrawState);
    procedure GeneralStyleBoxOnDrawItem(Control: TWinControl; Index: Integer; ARect: TRect;
      {%H-}State: TOwnerDrawState);
    procedure GeneralCheckBoxOnChange(Sender: TObject);
    procedure pnlElementAttributesResize(Sender: TObject);
    procedure TextStyleRadioOnChange(Sender: TObject);
  private
    FCurHighlightElement: TColorSchemeAttribute;
    FCurrentColorScheme: TColorSchemeLanguage;
    FOnChanged: TNotifyEvent;
    FShowPrior: Boolean;
    UpdatingColor: Boolean;

    procedure SetCurHighlightElement(AValue: TColorSchemeAttribute);
    procedure DoChanged;
    procedure SetShowPrior(AValue: Boolean);
  public
    constructor Create(TheOwner: TComponent); override;
    procedure Setup;
    procedure UpdateAll;
    procedure DoResized;
    // CurrentColorScheme must be set before CurHighlightElement
    property CurHighlightElement: TColorSchemeAttribute read FCurHighlightElement write SetCurHighlightElement;
    property CurrentColorScheme: TColorSchemeLanguage read FCurrentColorScheme write FCurrentColorScheme;
    property OnChanged: TNotifyEvent read FOnChanged write FOnChanged;
    property ShowPrior: Boolean read FShowPrior write SetShowPrior;
  end;

implementation

{$R *.lfm}

function DefaultToNone(AColor: TColor): TColor;
begin
  if AColor = clDefault then
    Result := clNone
  else
    Result := AColor;
end;

function NoneToDefault(AColor: TColor): TColor;
begin
  if AColor = clNone then
    Result := clDefault
  else
    Result := AColor;
end;

{ TSynColorAttrEditor }

procedure TSynColorAttrEditor.GeneralColorBoxOnChange(Sender: TObject);
begin
  if (FCurHighlightElement = nil) or UpdatingColor then
    exit;
  UpdatingColor := True;

  if Sender = ForegroundColorBox then
  begin
    FCurHighlightElement.Foreground := DefaultToNone(ForeGroundColorBox.Selected);
    ForeGroundUseDefaultCheckBox.Checked := ForeGroundColorBox.Selected <> clDefault;
  end;
  if Sender = BackGroundColorBox then
  begin
    FCurHighlightElement.Background := DefaultToNone(BackGroundColorBox.Selected);
    BackGroundUseDefaultCheckBox.Checked := BackGroundColorBox.Selected <> clDefault;
  end;
  if Sender = FrameColorBox then
  begin
    FCurHighlightElement.FrameColor := DefaultToNone(FrameColorBox.Selected);
    FrameColorUseDefaultCheckBox.Checked := FrameColorBox.Selected <> clDefault;
    FrameEdgesBox.Enabled := FrameColorBox.Selected <> clDefault;
    FrameStyleBox.Enabled := FrameColorBox.Selected <> clDefault;
  end;
  if Sender = MarkupFoldColorBox then
  begin
    FCurHighlightElement.MarkupFoldLineColor := DefaultToNone(MarkupFoldColorBox.Selected);
    MarkupFoldColorUseDefaultCheckBox.Checked := MarkupFoldColorBox.Selected <> clDefault;
    MarkupFoldStyleBox.Enabled := MarkupFoldColorBox.Selected <> clDefault;
  end;
  if Sender = FrameEdgesBox then
  begin
    FCurHighlightElement.FrameEdges := TSynFrameEdges(FrameEdgesBox.ItemIndex);
  end;
  if Sender = FrameStyleBox then
  begin
    FCurHighlightElement.FrameStyle := TSynLineStyle(FrameStyleBox.ItemIndex);
  end;
  if Sender = MarkupFoldStyleBox then
  begin
    FCurHighlightElement.MarkupFoldLineStyle := TSynLineStyle(MarkupFoldStyleBox.ItemIndex);
  end;

  UpdatingColor := False;
  DoChanged;
end;

procedure TSynColorAttrEditor.GeneralAlphaSpinOnChange(Sender: TObject);
var
  v: Integer;
begin
  if UpdatingColor then
    exit;

  UpdatingColor := True;
  v := TSpinEdit(Sender).Value;
  if (v = 256) and (Caption <> dlgEdOff) then TSpinEdit(Sender).Caption := dlgEdOff;
  UpdatingColor := False;

  if (FCurHighlightElement = nil) then
    exit;

  if v = 256 then v := 0;

  if Sender = ForeAlphaSpin then
    FCurHighlightElement.ForeAlpha := v;
  if Sender = BackAlphaSpin then
    FCurHighlightElement.BackAlpha := v;
  if Sender = FrameAlphaSpin then
    FCurHighlightElement.FrameAlpha := v;
  if Sender = MarkupFoldAlphaSpin then
    FCurHighlightElement.MarkupFoldLineAlpha := v;

  DoChanged;
end;

procedure TSynColorAttrEditor.edCustomWordChange(Sender: TObject);
begin
  if (FCurHighlightElement = nil) then
    exit;

  FCurHighlightElement.CustomWords.Text := trim(edCustomWord.Text);
end;

procedure TSynColorAttrEditor.dropCustomWordKindChange(Sender: TObject);
begin
  case dropCustomWordKind.ItemIndex of
    0: FCurHighlightElement.CustomWordTokenKind := tkIdentifier;
    1: FCurHighlightElement.CustomWordTokenKind := tkKey;
    2: FCurHighlightElement.CustomWordTokenKind := tkModifier;
    3: FCurHighlightElement.CustomWordTokenKind := tkNumber;
    4: FCurHighlightElement.CustomWordTokenKind := tkSymbol;
    5: FCurHighlightElement.CustomWordTokenKind := tkString;
    6: FCurHighlightElement.CustomWordTokenKind := tkComment;
    7: FCurHighlightElement.CustomWordTokenKind := tkSlashComment;
    8: FCurHighlightElement.CustomWordTokenKind := tkAnsiComment;
    9: FCurHighlightElement.CustomWordTokenKind := tkBorComment;
  end;
end;

procedure TSynColorAttrEditor.GeneralAlphaSpinOnEnter(Sender: TObject);
begin
  UpdatingColor := True;
  If TSpinEdit(Sender).Value = 256 then
    TSpinEdit(Sender).Caption := '256';
  UpdatingColor := False;
end;

procedure TSynColorAttrEditor.GeneralColorBoxOnGetColors(Sender: TCustomColorBox; Items: TStrings);
var
  i: longint;
begin
  i := Items.IndexOfObject(TObject(PtrInt(clDefault)));
  if i >= 0 then begin
    Items[i] := dlgColorNotModified;
    Items.Move(i, 1);
  end;
end;

procedure TSynColorAttrEditor.GeneralPriorSpinOnChange(Sender: TObject);
var
  v: Integer;
begin
  if (FCurHighlightElement = nil) then
    exit;

  v := TSpinEdit(Sender).Value;

  if Sender = ForePriorSpin then
    FCurHighlightElement.ForePriority := v;
  if Sender = BackPriorSpin then
    FCurHighlightElement.BackPriority := v;
  if Sender = FramePriorSpin then
    FCurHighlightElement.FramePriority := v;

  DoChanged;
end;

procedure TSynColorAttrEditor.FrameEdgesBoxDrawItem(Control: TWinControl; Index: Integer; ARect: TRect;
  State: TOwnerDrawState);
var
  r: TRect;
  PCol: Integer;
begin
  if Index  < 0 then exit;;

  r.top := ARect.top + 3;
  r.bottom := ARect.bottom - 3;
  r.left := ARect.left + 5;
  r.right := ARect.Right - 5;

  with TCustomComboBox(Control).Canvas do
  begin
    FillRect(ARect);
    Pen.Width := 1;
    PCol := pen.Color;
    Pen.Color := clGray;
    Pen.Style := psDot;
    Pen.EndCap := pecFlat;
    Rectangle(r);
    Pen.Width := 2;
    pen.Color := PCol;
    Pen.Style := psSolid;
    case Index of
      ord(sfeAround): Rectangle(r);
      ord(sfeBottom): begin
          MoveTo(r.Left, r.Bottom);
          LineTo(r.Right-1, r.Bottom);
        end;
      ord(sfeLeft): begin
          MoveTo(r.Left, r.Top);
          LineTo(r.Left, r.Bottom-1);
        end;
    end;
  end;
end;

procedure TSynColorAttrEditor.DoResized;
var
  EdCustWidth: Integer;
begin
  EdCustWidth := 0;
  if edCustomWord.Visible then
    EdCustWidth := edCustomWord.Width;

  if Width > Panel1.Width + EdCustWidth - pnlFrameHost1.Width + Max(pnlFrameHost1.Width, pnlFrameHost2.Width) + 15 then begin
    FrameEdgesBox.Parent := pnlFrameHost1;
    FrameStyleBox.Parent := pnlFrameHost1;
  end
  else begin
    FrameEdgesBox.Parent := pnlFrameHost2;
    FrameStyleBox.Parent := pnlFrameHost2;
  end;
end;

procedure TSynColorAttrEditor.GeneralStyleBoxOnDrawItem(Control: TWinControl; Index: Integer; ARect: TRect;
  State: TOwnerDrawState);
var
  p: TPoint;
begin
  if Index  < 0 then exit;;

  with TCustomComboBox(Control).Canvas do
  begin
    FillRect(ARect);
    Pen.Width := 2;
    pen.EndCap := pecFlat;
    case Index of
      0: Pen.Style := psSolid;
      1: Pen.Style := psDash;
      2: Pen.Style := psDot;
      3: Pen.Style := psSolid;
    end;
    if Index = 3 then begin
      MoveToEx(Handle, ARect.Left + 5, (ARect.Top + ARect.Bottom) div 2 - 2, @p);
      WaveTo(Handle, ARect.Right - 5, (ARect.Top + ARect.Bottom) div 2 - 2, 4);
    end else begin
      MoveTo(ARect.Left + 5, (ARect.Top + ARect.Bottom) div 2);
      LineTo(ARect.Right - 5, (ARect.Top + ARect.Bottom) div 2);
    end;
  end;
end;

procedure TSynColorAttrEditor.GeneralCheckBoxOnChange(Sender: TObject);
var
  TheColorBox: TColorBox;
begin
  if FCurHighlightElement = nil then
    exit;

  if UpdatingColor = False then begin
    UpdatingColor := True;

    TheColorBox := nil;
    if Sender = ForeGroundUseDefaultCheckBox then TheColorBox := ForegroundColorBox;
    if Sender = BackGroundUseDefaultCheckBox then TheColorBox := BackGroundColorBox;
    if Sender = FrameColorUseDefaultCheckBox then TheColorBox := FrameColorBox;
    if Sender = MarkupFoldColorUseDefaultCheckBox then TheColorBox := MarkupFoldColorBox;
    if Assigned(TheColorBox) then begin
      if TCheckBox(Sender).Checked then begin
        TheColorBox.Selected := TheColorBox.Tag;
      end
      else begin
        TheColorBox.Tag := TheColorBox.Selected;
        TheColorBox.Selected := clDefault;
      end;

      if (Sender = ForeGroundUseDefaultCheckBox) and
         (DefaultToNone(ForegroundColorBox.Selected) <> FCurHighlightElement.Foreground)
      then begin
        FCurHighlightElement.Foreground := DefaultToNone(ForegroundColorBox.Selected);
        DoChanged;
      end;
      if (Sender = BackGroundUseDefaultCheckBox) and
         (DefaultToNone(BackGroundColorBox.Selected) <> FCurHighlightElement.Background)
      then begin
        FCurHighlightElement.Background := DefaultToNone(BackGroundColorBox.Selected);
        DoChanged;
      end;
      if (Sender = FrameColorUseDefaultCheckBox) and
         (DefaultToNone(FrameColorBox.Selected) <> FCurHighlightElement.FrameColor)
      then begin
        FCurHighlightElement.FrameColor := DefaultToNone(FrameColorBox.Selected);
        FrameEdgesBox.Enabled := TCheckBox(Sender).Checked;
        FrameStyleBox.Enabled := TCheckBox(Sender).Checked;
        DoChanged;
      end;
      if (Sender = MarkupFoldColorUseDefaultCheckBox) and
         (DefaultToNone(MarkupFoldColorBox.Selected) <> FCurHighlightElement.MarkupFoldLineColor)
      then begin
        FCurHighlightElement.MarkupFoldLineColor := DefaultToNone(MarkupFoldColorBox.Selected);
        MarkupFoldStyleBox.Enabled := MarkupFoldColorBox.Selected <> clDefault;
      end;
    end;

    UpdatingColor := False;
  end;

  if Sender = TextBoldCheckBox then begin
    if hafStyleMask in FCurHighlightElement.AttrFeatures then
      TextStyleRadioOnChange(Sender)
    else
    if TextBoldCheckBox.Checked xor (fsBold in FCurHighlightElement.Style) then
    begin
      if TextBoldCheckBox.Checked then
        FCurHighlightElement.Style := FCurHighlightElement.Style + [fsBold]
      else
        FCurHighlightElement.Style := FCurHighlightElement.Style - [fsBold];
      DoChanged;
    end;
  end;

  if Sender = TextItalicCheckBox then begin
    if hafStyleMask in FCurHighlightElement.AttrFeatures then
      TextStyleRadioOnChange(Sender)
    else
    if TextItalicCheckBox.Checked xor (fsItalic in FCurHighlightElement.Style) then
    begin
      if TextItalicCheckBox.Checked then
        FCurHighlightElement.Style := FCurHighlightElement.Style + [fsItalic]
      else
        FCurHighlightElement.Style := FCurHighlightElement.Style - [fsItalic];
      DoChanged;
    end;
  end;

  if Sender = TextUnderlineCheckBox then begin
    if hafStyleMask in FCurHighlightElement.AttrFeatures then
      TextStyleRadioOnChange(Sender)
    else
    if TextUnderlineCheckBox.Checked xor (fsUnderline in FCurHighlightElement.Style) then
    begin
      if TextUnderlineCheckBox.Checked then
        FCurHighlightElement.Style := FCurHighlightElement.Style + [fsUnderline]
      else
        FCurHighlightElement.Style := FCurHighlightElement.Style - [fsUnderline];
      DoChanged;
    end;
  end;

  if Sender = FeaturePastEOLCheckBox then begin
    if FeaturePastEOLCheckBox.Checked xor (lafPastEOL in FCurHighlightElement.Features) then
    begin
      if FeaturePastEOLCheckBox.Checked then
        FCurHighlightElement.Features := FCurHighlightElement.Features + [lafPastEOL]
      else
        FCurHighlightElement.Features := FCurHighlightElement.Features - [lafPastEOL];
      DoChanged;
    end;
  end;

end;

procedure TSynColorAttrEditor.pnlElementAttributesResize(Sender: TObject);
var
  EdCustWidth: Integer;
begin
  EdCustWidth := 0;
  if edCustomWord.Visible then
    EdCustWidth := edCustomWord.Width;

  //Constraints.MinHeight := lblInfo.Top + lblInfo.Height;
  Constraints.MinWidth := Panel1.Width + EdCustWidth - pnlFrameHost1.Width + 15;
end;

procedure TSynColorAttrEditor.TextStyleRadioOnChange(Sender: TObject);
  procedure CalcNewStyle(CheckBox: TCheckBox; RadioOn, RadioOff,
                         RadioInvert: TRadioButton; fs : TFontStyle;
                         Panel: TPanel);
  begin
    if CheckBox.Checked then
    begin
      Panel.Enabled := True;
      if RadioInvert.Checked then
      begin
        FCurHighlightElement.Style     := FCurHighlightElement.Style + [fs];
        FCurHighlightElement.StyleMask := FCurHighlightElement.StyleMask - [fs];
      end
      else
      if RadioOn.Checked then
      begin
        FCurHighlightElement.Style     := FCurHighlightElement.Style + [fs];
        FCurHighlightElement.StyleMask := FCurHighlightElement.StyleMask + [fs];
      end
      else
      if RadioOff.Checked then
      begin
        FCurHighlightElement.Style     := FCurHighlightElement.Style - [fs];
        FCurHighlightElement.StyleMask := FCurHighlightElement.StyleMask + [fs];
      end
    end
    else
    begin
      Panel.Enabled := False;
      FCurHighlightElement.Style     := FCurHighlightElement.Style - [fs];
      FCurHighlightElement.StyleMask := FCurHighlightElement.StyleMask - [fs];
    end;
  end;
begin
  if FCurHighlightElement = nil then
    exit;
  if UpdatingColor or not (hafStyleMask in FCurHighlightElement.AttrFeatures) then
    Exit;

  if (Sender = TextBoldCheckBox) or
     (Sender = TextBoldRadioOn) or
     (Sender = TextBoldRadioOff) or
     (Sender = TextBoldRadioInvert) then
    CalcNewStyle(TextBoldCheckBox, TextBoldRadioOn, TextBoldRadioOff,
                    TextBoldRadioInvert, fsBold, TextBoldRadioPanel);

  if (Sender = TextItalicCheckBox) or
     (Sender = TextItalicRadioOn) or
     (Sender = TextItalicRadioOff) or
     (Sender = TextItalicRadioInvert) then
    CalcNewStyle(TextItalicCheckBox, TextItalicRadioOn, TextItalicRadioOff,
                    TextItalicRadioInvert, fsItalic, TextItalicRadioPanel);

  if (Sender = TextUnderlineCheckBox) or
     (Sender = TextUnderlineRadioOn) or
     (Sender = TextUnderlineRadioOff) or
     (Sender = TextUnderlineRadioInvert) then
    CalcNewStyle(TextUnderlineCheckBox, TextUnderlineRadioOn, TextUnderlineRadioOff,
                    TextUnderlineRadioInvert, fsUnderline, TextUnderlineRadioPanel);

  DoChanged;
end;

procedure TSynColorAttrEditor.UpdateAll;
  function IsAhaElement(Element: TColorSchemeAttribute; aha: TAdditionalHilightAttribute): Boolean;
  begin
    Result := (FCurrentColorScheme <> nil) and
              (FCurrentColorScheme.AttributeByEnum[aha] <> nil) and
              (Element.StoredName = FCurrentColorScheme.AttributeByEnum[aha].StoredName);
  end;
var
  UsingTempAttr: Boolean;
begin
  if UpdatingColor then
    exit;

  UpdatingColor := True;
  DisableAlign;
  try
    UsingTempAttr := FCurHighlightElement = nil;
    if UsingTempAttr then begin
      FCurHighlightElement := TColorSchemeAttribute.Create(nil, nil, '');
      FCurHighlightElement.Clear;
    end;

    // Adjust color captions
    ForeGroundUseDefaultCheckBox.Caption := dlgForecolor;
    BackGroundUseDefaultCheckBox.Caption := dlgBackColor;
    FrameColorUseDefaultCheckBox.Caption := dlgFrameColor;
    if FCurrentColorScheme <> nil then begin
      if IsAhaElement(FCurHighlightElement, ahaModifiedLine) then begin
        ForeGroundUseDefaultCheckBox.Caption := dlgSavedLineColor;
        FrameColorUseDefaultCheckBox.Caption := dlgUnsavedLineColor;
      end else
      if IsAhaElement(FCurHighlightElement, ahaCodeFoldingTree) or
         IsAhaElement(FCurHighlightElement, ahaCodeFoldingTreeCurrent)
      then begin
        FrameColorUseDefaultCheckBox.Caption := dlgGutterCollapsedColor;
      end else
      if IsAhaElement(FCurHighlightElement, ahaCaretColor) then begin
        ForeGroundUseDefaultCheckBox.Caption := dlgCaretForeColor;
        BackGroundUseDefaultCheckBox.Caption := dlgCaretBackColor;
      end else
      if IsAhaElement(FCurHighlightElement, ahaOverviewGutter) then begin
        ForeGroundUseDefaultCheckBox.Caption := dlgOverviewGutterBack1Color;
        BackGroundUseDefaultCheckBox.Caption := dlgOverviewGutterBack2Color;
        FrameColorUseDefaultCheckBox.Caption := dlgOverviewGutterPageColor;
      end;
    end;

    if FCurHighlightElement.Group = agnDefault then begin
      ForegroundColorBox.Style := ForegroundColorBox.Style - [cbIncludeDefault];
      BackGroundColorBox.Style := BackGroundColorBox.Style - [cbIncludeDefault];
    end else begin
      ForegroundColorBox.Style := ForegroundColorBox.Style + [cbIncludeDefault];
      BackGroundColorBox.Style := BackGroundColorBox.Style + [cbIncludeDefault];
    end;

    // Forground
    ForeGroundLabel.Visible              := (hafForeColor in FCurHighlightElement.AttrFeatures) and
                                            (FCurHighlightElement.Group = agnDefault);
    ForeGroundUseDefaultCheckBox.Visible := (hafForeColor in FCurHighlightElement.AttrFeatures) and
                                            not(FCurHighlightElement.Group = agnDefault);
    ForegroundColorBox.Visible           := (hafForeColor in FCurHighlightElement.AttrFeatures);

    ForegroundColorBox.Selected := NoneToDefault(FCurHighlightElement.Foreground);
    if ForegroundColorBox.Selected = clDefault then
      ForegroundColorBox.Tag := ForegroundColorBox.DefaultColorColor
    else
      ForegroundColorBox.Tag := ForegroundColorBox.Selected;
    ForeGroundUseDefaultCheckBox.Checked := ForegroundColorBox.Selected <> clDefault;

    ForeAlphaSpin.Visible  := ForegroundColorBox.Visible and
                             (hafAlpha in FCurHighlightElement.AttrFeatures);
    ForeAlphaLabel.Visible := ForeAlphaSpin.Visible;
    if FCurHighlightElement.ForeAlpha = 0 then begin
      ForeAlphaSpin.Value    := 256; // Off
      ForeAlphaSpin.Caption  := dlgEdOff;
    end
    else
      ForeAlphaSpin.Value    := FCurHighlightElement.ForeAlpha;

    ForePriorSpin.Visible  := ForegroundColorBox.Visible and FShowPrior and
                             (hafPrior in FCurHighlightElement.AttrFeatures);
    ForePriorLabel.Visible := ForePriorSpin.Visible;
    ForePriorSpin.Value    := FCurHighlightElement.ForePriority;


    // BackGround
    BackGroundLabel.Visible              := (hafBackColor in FCurHighlightElement.AttrFeatures) and
                                            (FCurHighlightElement.Group = agnDefault);
    BackGroundUseDefaultCheckBox.Visible := (hafBackColor in FCurHighlightElement.AttrFeatures) and
                                            not(FCurHighlightElement.Group = agnDefault);
    BackGroundColorBox.Visible           := (hafBackColor in FCurHighlightElement.AttrFeatures);

    BackGroundColorBox.Selected := NoneToDefault(FCurHighlightElement.Background);
    if BackGroundColorBox.Selected = clDefault then
      BackGroundColorBox.Tag := BackGroundColorBox.DefaultColorColor
    else
      BackGroundColorBox.Tag := BackGroundColorBox.Selected;
    BackGroundUseDefaultCheckBox.Checked := BackGroundColorBox.Selected <> clDefault;

    BackAlphaSpin.Visible := BackGroundColorBox.Visible and
                             (hafAlpha in FCurHighlightElement.AttrFeatures);
    BackAlphaLabel.Visible := BackAlphaSpin.Visible;
    if FCurHighlightElement.BackAlpha = 0 then begin
      BackAlphaSpin.Value    := 256; // Off
      BackAlphaSpin.Caption  := dlgEdOff;
    end
    else
      BackAlphaSpin.Value    := FCurHighlightElement.BackAlpha;

    BackPriorSpin.Visible  := BackGroundColorBox.Visible and FShowPrior and
                             (hafPrior in FCurHighlightElement.AttrFeatures);
    BackPriorLabel.Visible := BackPriorSpin.Visible;
    BackPriorSpin.Value    := FCurHighlightElement.BackPriority;

    // Frame
    FrameColorUseDefaultCheckBox.Visible := hafFrameColor in FCurHighlightElement.AttrFeatures;
    FrameColorBox.Visible                := hafFrameColor in FCurHighlightElement.AttrFeatures;
    FrameEdgesBox.Visible                := hafFrameEdges in FCurHighlightElement.AttrFeatures;
    FrameStyleBox.Visible                := hafFrameStyle in FCurHighlightElement.AttrFeatures;

    FrameColorBox.Selected := NoneToDefault(FCurHighlightElement.FrameColor);
    if FrameColorBox.Selected = clDefault then
      FrameColorBox.Tag := FrameColorBox.DefaultColorColor
    else
      FrameColorBox.Tag := FrameColorBox.Selected;
    FrameColorUseDefaultCheckBox.Checked := FrameColorBox.Selected <> clDefault;
    FrameEdgesBox.ItemIndex := integer(FCurHighlightElement.FrameEdges);
    FrameStyleBox.ItemIndex := integer(FCurHighlightElement.FrameStyle);
    FrameEdgesBox.Enabled := FrameColorUseDefaultCheckBox.Checked;
    FrameStyleBox.Enabled := FrameColorUseDefaultCheckBox.Checked;

    FrameAlphaSpin.Visible := FrameColorBox.Visible and
                             (hafAlpha in FCurHighlightElement.AttrFeatures);
    FrameAlphaLabel.Visible := FrameAlphaSpin.Visible;
    if FCurHighlightElement.FrameAlpha = 0 then begin
      FrameAlphaSpin.Value    := 256; // Off
      FrameAlphaSpin.Caption  := dlgEdOff;
    end
    else
      FrameAlphaSpin.Value    := FCurHighlightElement.FrameAlpha;

    FramePriorSpin.Visible  := FrameColorBox.Visible and FShowPrior and
                              (hafPrior in FCurHighlightElement.AttrFeatures);
    FramePriorLabel.Visible := FramePriorSpin.Visible;
    FramePriorSpin.Value    := FCurHighlightElement.FramePriority;

    // Markup Fold
    MarkupFoldColorUseDefaultCheckBox.Visible := hafMarkupFoldColor in FCurHighlightElement.AttrFeatures;
    MarkupFoldColorBox.Visible                := hafMarkupFoldColor in FCurHighlightElement.AttrFeatures;
    MarkupFoldAlphaLabel.Visible             := hafMarkupFoldColor in FCurHighlightElement.AttrFeatures;
    MarkupFoldAlphaSpin.Visible              := hafMarkupFoldColor in FCurHighlightElement.AttrFeatures;
    MarkupFoldStyleBox.Visible               := hafMarkupFoldColor in FCurHighlightElement.AttrFeatures;

    MarkupFoldColorBox.Selected := NoneToDefault(FCurHighlightElement.MarkupFoldLineColor);
    if MarkupFoldColorBox.Selected = clDefault then
      MarkupFoldColorBox.Tag := MarkupFoldColorBox.DefaultColorColor
    else
      MarkupFoldColorBox.Tag := MarkupFoldColorBox.Selected;
    MarkupFoldColorUseDefaultCheckBox.Checked := MarkupFoldColorBox.Selected <> clDefault;

    MarkupFoldStyleBox.ItemIndex := integer(FCurHighlightElement.MarkupFoldLineStyle);
    MarkupFoldStyleBox.Enabled := MarkupFoldColorUseDefaultCheckBox.Checked;

    if FCurHighlightElement.MarkupFoldLineAlpha = 0 then begin
      MarkupFoldAlphaSpin.Value    := 256; // Off
      MarkupFoldAlphaSpin.Caption  := dlgEdOff;
    end
    else
      MarkupFoldAlphaSpin.Value    := FCurHighlightElement.MarkupFoldLineAlpha;

    // Styles
    TextBoldCheckBox.Visible      := hafStyle in FCurHighlightElement.AttrFeatures;
    TextItalicCheckBox.Visible    := hafStyle in FCurHighlightElement.AttrFeatures;
    TextUnderlineCheckBox.Visible := hafStyle in FCurHighlightElement.AttrFeatures;

    TextBoldRadioPanel.Visible      := hafStyleMask in FCurHighlightElement.AttrFeatures;
    TextItalicRadioPanel.Visible    := hafStyleMask in FCurHighlightElement.AttrFeatures;
    TextUnderlineRadioPanel.Visible := hafStyleMask in FCurHighlightElement.AttrFeatures;

    if hafStyleMask in FCurHighlightElement.AttrFeatures then begin
      TextBoldCheckBox.Checked   := (fsBold in FCurHighlightElement.Style) or
                                    (fsBold in FCurHighlightElement.StyleMask);
      TextBoldRadioPanel.Enabled := TextBoldCheckBox.Checked;

      if not(fsBold in FCurHighlightElement.StyleMask) then
        TextBoldRadioInvert.Checked := True
      else
      if fsBold in FCurHighlightElement.Style then
        TextBoldRadioOn.Checked := True
      else
        TextBoldRadioOff.Checked := True;

      TextItalicCheckBox.Checked   := (fsItalic in FCurHighlightElement.Style) or
                                      (fsItalic in FCurHighlightElement.StyleMask);
      TextItalicRadioPanel.Enabled := TextItalicCheckBox.Checked;

      if not(fsItalic in FCurHighlightElement.StyleMask) then
        TextItalicRadioInvert.Checked := True
      else
      if fsItalic in FCurHighlightElement.Style then
        TextItalicRadioOn.Checked := True
      else
        TextItalicRadioOff.Checked := True;

      TextUnderlineCheckBox.Checked := (fsUnderline in FCurHighlightElement.Style) or
                                       (fsUnderline in FCurHighlightElement.StyleMask);
      TextUnderlineRadioPanel.Enabled := TextUnderlineCheckBox.Checked;

      if not(fsUnderline in FCurHighlightElement.StyleMask) then
        TextUnderlineRadioInvert.Checked := True
      else
      if fsUnderline in FCurHighlightElement.Style then
        TextUnderlineRadioOn.Checked := True
      else
        TextUnderlineRadioOff.Checked := True;
    end
    else
    begin
      TextBoldCheckBox.Checked      := fsBold in FCurHighlightElement.Style;
      TextItalicCheckBox.Checked    := fsItalic in FCurHighlightElement.Style;
      TextUnderlineCheckBox.Checked := fsUnderline in FCurHighlightElement.Style;
    end;

    PnlFeaturePastEOL.Visible := lafPastEOL in FCurHighlightElement.SupportedFeatures;
    FeaturePastEOLCheckBox.Checked := lafPastEOL in FCurHighlightElement.Features;

    lblInfo.Caption := '';
    if IsAhaElement(FCurHighlightElement, ahaCaretColor) then begin
      lblInfo.Caption := dlgCaretColorInfo;
      lblInfo.Visible := True;
    end;

    // custom words
    lbCustomWords.Visible      := hafCustomWords in FCurHighlightElement.AttrFeatures;
    edCustomWord.Visible       := hafCustomWords in FCurHighlightElement.AttrFeatures;
    dropCustomWordKind.Visible := hafCustomWords in FCurHighlightElement.AttrFeatures;
    edCustomWord.Text := FCurHighlightElement.CustomWords.Text;

    case FCurHighlightElement.CustomWordTokenKind of
      tkIdentifier: dropCustomWordKind.ItemIndex := 0;
      tkKey:        dropCustomWordKind.ItemIndex := 1;
      tkModifier:   dropCustomWordKind.ItemIndex := 2;
      tkNumber:     dropCustomWordKind.ItemIndex := 3;
      tkSymbol:     dropCustomWordKind.ItemIndex := 4;
      tkString:     dropCustomWordKind.ItemIndex := 5;
      tkComment:    dropCustomWordKind.ItemIndex := 6;
      tkSlashComment: dropCustomWordKind.ItemIndex := 7;
      tkAnsiComment:  dropCustomWordKind.ItemIndex := 8;
      tkBorComment:   dropCustomWordKind.ItemIndex := 9;
    end;

    UpdatingColor := False;
  finally
    if UsingTempAttr then
      FreeAndNil(FCurHighlightElement);
    EnableAlign;
  end;
  pnlElementAttributesResize(nil);
end;

procedure TSynColorAttrEditor.SetCurHighlightElement(AValue: TColorSchemeAttribute);
begin
  if FCurHighlightElement = AValue then Exit;
  FCurHighlightElement := AValue;
  UpdateAll;
end;

procedure TSynColorAttrEditor.DoChanged;
begin
  if Assigned(FOnChanged) then
    FOnChanged(Self);
end;

procedure TSynColorAttrEditor.SetShowPrior(AValue: Boolean);
begin
  if FShowPrior = AValue then Exit;
  FShowPrior := AValue;
  UpdateAll;
end;

constructor TSynColorAttrEditor.Create(TheOwner: TComponent);
begin
  inherited Create(TheOwner);
  FShowPrior := False;
  ForegroundColorBox.DropDownCount := EnvironmentOptions.DropDownCount;
  BackGroundColorBox.DropDownCount := EnvironmentOptions.DropDownCount;
  FrameColorBox.DropDownCount := EnvironmentOptions.DropDownCount;
  FrameEdgesBox.DropDownCount := EnvironmentOptions.DropDownCount;
  FrameStyleBox.DropDownCount := EnvironmentOptions.DropDownCount;
  MarkupFoldColorBox.DropDownCount := EnvironmentOptions.DropDownCount;
  MarkupFoldStyleBox.DropDownCount := EnvironmentOptions.DropDownCount;
end;

procedure TSynColorAttrEditor.Setup;
begin
  UpdatingColor := False;
  ForeGroundLabel.Caption := dlgForecolor;
  BackGroundLabel.Caption := dlgBackColor;
  ForeGroundUseDefaultCheckBox.Caption := dlgForecolor;
  BackGroundUseDefaultCheckBox.Caption := dlgBackColor;
  FrameColorUseDefaultCheckBox.Caption := dlgFrameColor;
  MarkupFoldColorUseDefaultCheckBox.Caption := dlgMarkupFoldColor;
  ForeAlphaLabel.Caption := lisAlpha;
  BackAlphaLabel.Caption := lisAlpha;
  FrameAlphaLabel.Caption := lisAlpha;
  MarkupFoldAlphaLabel.Caption := lisAlpha;
  ForePriorLabel.Caption := lisPriority;
  BackPriorLabel.Caption := lisPriority;
  FramePriorLabel.Caption := lisPriority;

  TextBoldCheckBox.Caption := dlgEdBold;
  TextBoldRadioOn.Caption := dlgEdOn;
  TextBoldRadioOff.Caption := dlgEdOff;
  TextBoldRadioInvert.Caption := dlgEdInvert;

  TextItalicCheckBox.Caption := dlgEdItal;
  TextItalicRadioOn.Caption := dlgEdOn;
  TextItalicRadioOff.Caption := dlgEdOff;
  TextItalicRadioInvert.Caption := dlgEdInvert;

  TextUnderlineCheckBox.Caption := dlgEdUnder;
  TextUnderlineRadioOn.Caption := dlgEdOn;
  TextUnderlineRadioOff.Caption := dlgEdOff;
  TextUnderlineRadioInvert.Caption := dlgEdInvert;

  FeaturePastEOLCheckBox.Caption  := dlgColorFeatPastEol;

  lbCustomWords.Caption := dlgMatchWords;
  dropCustomWordKind.Items.Add(lisCodeToolsOptsIdentifier);
  dropCustomWordKind.Items.Add(dlgKeyWord);
  dropCustomWordKind.Items.Add(dlgModifier);
  dropCustomWordKind.Items.Add(lisCodeToolsOptsNumber);
  dropCustomWordKind.Items.Add(lisCodeToolsOptsSymbol);
  dropCustomWordKind.Items.Add(lisCodeToolsOptsString);
  dropCustomWordKind.Items.Add(lisCodeToolsOptsComment);
  dropCustomWordKind.Items.Add(lisCodeToolsOptsCommentSlash);
  dropCustomWordKind.Items.Add(lisCodeToolsOptsCommentAnsi);
  dropCustomWordKind.Items.Add(lisCodeToolsOptsCommentBor);
  dropCustomWordKind.ItemIndex := 0;

  //Constraints.MinHeight := max(Constraints.MinHeight,
  //                             pnlUnderline.Top + pnlUnderline.Height +
  //                             Max(pnlUnderline.BorderSpacing.Around,
  //                                 pnlUnderline.BorderSpacing.Bottom)
  //                            );
end;

end.

