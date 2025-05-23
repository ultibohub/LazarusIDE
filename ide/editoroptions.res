        ��  ��                  �  8   ��
 C O D E T E M P L A T E S       0	        [arrayd | array declaration (var)]
$(AttributesStart)
EnableMakros=true
RemoveChar=true
!FileVersion=1
$(AttributesEnd)
$Param(VariableName): array[0..$Param(HighNumber)] of $Param(Type);|
[arrayc | array declaration (const)]
$(AttributesStart)
EnableMakros=true
$(AttributesEnd)
array[$Param(0)..$Param(1)] of $Param(Type) = (|);
[cases | case statement]
$(AttributesStart)
EnableMakros=true
$(AttributesEnd)
case $Param(var) of
  : |;
  : ;
end$AddSemicolon()
[be | begin end else begin end]
$(AttributesStart)
EnableMakros=true
$(AttributesEnd)
begin
  |
end else begin

end$AddSemicolon()
[casee | case statement (with else)]
$(AttributesStart)
EnableMakros=true
$(AttributesEnd)
case $Param(var) of
  : |;
  : ;
else ;
end$AddSemicolon()
[classf | class declaration (all parts)]
$(AttributesStart)
EnableMakros=true
RemoveChar=true
$(AttributesEnd)
$Param(ClassName) = class($Param(InheritedClass))
private

public
  |
  constructor Create;
  destructor Destroy; override;
end;
[classd | class declaration (no parts)]
$(AttributesStart)
EnableMakros=true
RemoveChar=true
$(AttributesEnd)
$Param(ClassName) = class($Param(InheritedClass))
  |
end;
[classc | class declaration (with Create/Destroy overrides)]
$(AttributesStart)
EnableMakros=true
RemoveChar=true
$(AttributesEnd)
$Param(ClassName) = class($Param(InheritedClass))
private

protected

public
  |
  constructor Create; override;
  destructor Destroy; override;
published
end;
[d | debugln]
$(AttributesStart)
EnableMakros=true
$(AttributesEnd)
debugln(['$ProcedureName() '|])$AddSemicolon()
[fors | for (no begin/end)]
$(AttributesStart)
EnableMakros=true
RemoveChar=true
$(AttributesEnd)
for $Param(CounterVar) := $Param(0) to Pred($Param(Count)) do
  |
[forb | for statement]
$(AttributesStart)
EnableMakros=true
RemoveChar=true
$(AttributesEnd)
for $Param(CounterVar) := $Param(0) to Pred($Param(Count)) do
begin
  |
end$AddSemicolon()
[function | function declaration]
$(AttributesStart)
EnableMakros=true
$(AttributesEnd)
function $Param(Name)($Param()): $Param(Type);
begin
  |
end;
[hexc | HexStr(Cardinal(),8)]
$(AttributesStart)
EnableMakros=true
$(AttributesEnd)
HexStr(PtrUInt($Param()),8)|
[ifs | if (no begin/end)]
$(AttributesStart)
EnableMakros=true
$(AttributesEnd)
if $Param(Conditional) then
  |
[ifb | if statement]
$(AttributesStart)
EnableMakros=true
RemoveChar=true
$(AttributesEnd)
if $Param(Conditional) then
begin
  |
end$AddSemicolon()
[ife | if then (no begin/end) else (no begin/end)]
$(AttributesStart)
EnableMakros=true
RemoveChar=true
$(AttributesEnd)
if $Param(Conditional) then
  |
else
[ifeb | if then else]
$(AttributesStart)
EnableMakros=true
RemoveChar=true
$(AttributesEnd)
if $Param(Conditional) then
begin
  |
end else begin

end$AddSemicolon()
[procedure | procedure declaration]
$(AttributesStart)
EnableMakros=true
$(AttributesEnd)
procedure $Param(ProcName)($Param());
begin
  |
end;
[ofall | case of all enums]
$(AttributesStart)
EnableMakros=true
$(AttributesEnd)
of
|$OfAll()end$AddSemicolon()
[trye | try except]
$(AttributesStart)
EnableMakros=true
$(AttributesEnd)
try
  | 
except

end$AddSemicolon()
[tryf | try finally]
$(AttributesStart)
EnableMakros=true
RemoveChar=true
$(AttributesEnd)
try
  |
finally
  $Param(FreeStatement,default)
end$AddSemicolon()
[trycf | try finally (with Create/Free)]
$(AttributesStart)
EnableMakros=true
RemoveChar=true
$(AttributesEnd)
$Param(VarName) := $Param(TMyClassName).Create;
try
  |
finally
  $Param(VarName,Sync=1).Free;
end;
[whileb | while statement]
$(AttributesStart)
EnableMakros=true
RemoveChar=true
$(AttributesEnd)
while $Param(LoopCondition) do
begin
  |
end$AddSemicolon()
[whiles | while (no begin)]
$(AttributesStart)
EnableMakros=true
$(AttributesEnd)
while $Param(LoopCondition) do
  |
[withb | with statement]
$(AttributesStart)
EnableMakros=true
RemoveChar=true
$(AttributesEnd)
with $Param(Object) do
begin
  |
end$AddSemicolon()
[b | begin end]
$(AttributesStart)
EnableMakros=true
$(AttributesEnd)
begin
  |
end$AddSemicolon()
[withs | with (no begin)]
$(AttributesStart)
EnableMakros=true
RemoveChar=true
$(AttributesEnd)
with $Param(Object) do
  |
[withc | with for components]
$(AttributesStart)
EnableMakros=true
RemoveChar=true
$(AttributesEnd)
with $Param(Object) do
begin
  Name:='$Param(NameText)';
  Parent:=Self;
  Left:=$Param(0);
  Top:=$Param(0);
  Width:=$Param(0);
  Height:=$Param(0);
  Caption:='$Param(CaptionText)';
end$AddSemicolon()
|
[fpc | Conditional FPC Mode]
$(AttributesStart)
RemoveChar=true
$(AttributesEnd)
{$IFDEF FPC}
  {$mode objfpc}{$H+}
{$ENDIF}
|
[todo | ToDo item creator]
$(AttributesStart)
EnableMakros=true
RemoveChar=true
$(AttributesEnd)
{ TODO -o$Param(Author) : $Param(Note) } |
[w | writeln]
$(AttributesStart)
EnableMakros=true
$(AttributesEnd)
writeln('$ProcedureName() '|)$AddSemicolon()
[prws | property read write]
$(AttributesStart)
!Version=1
EnableMakros=true
$(AttributesEnd)
property $Param(Name) read $Param(Get)$Param(Name,sync=1) write $Param(Set)$Param(Name,sync=1);|
[prwd | property read write default]
$(AttributesStart)
!Version=1
EnableMakros=true
$(AttributesEnd)
property $Param(Name) read $Param(Get)$Param(Name,sync=1) write $Param(Set)$Param(Name,sync=1) default $Param(Const);|
[pirws | property Integer read write]
$(AttributesStart)
!Version=1
EnableMakros=true
$(AttributesEnd)
property $Param(Name): Integer read $Param(Get)$Param(Name,sync=1) write $Param(Set)$Param(Name,sync=1);|
[pirwd | property Integer read write default]
$(AttributesStart)
!Version=1
EnableMakros=true
$(AttributesEnd)
property $Param(Name): Integer read $Param(Get)$Param(Name,sync=1) write $Param(Set)$Param(Name,sync=1) default $Param(Const);|
[psrw | property string read write]
$(AttributesStart)
!Version=1
EnableMakros=true
$(AttributesEnd)
property $Param(Name): string read $Param(Get)$Param(Name,sync=1) write $Param(Set)$Param(Name,sync=1);|
[pdrwd | property Double read write default]
$(AttributesStart)
!Version=1
EnableMakros=true
$(AttributesEnd)
property $Param(Name): Double read $Param(Get)$Param(Name,sync=1) write $Param(Set)$Param(Name,sync=1) default $Param(Const);|
[pdrws | property Double read write]
$(AttributesStart)
!Version=1
EnableMakros=true
$(AttributesEnd)
property $Param(Name): Double read $Param(Get)$Param(Name,sync=1) write $Param(Set)$Param(Name,sync=1);|
[is | IntToStr]
$(AttributesStart)
EnableMakros=true
$(AttributesEnd)
IntToStr($Param())|
[si | StrToInt()]
$(AttributesStart)
EnableMakros=true
$(AttributesEnd)
StrToInt($Param())|
[sid | StrToIntDef]
$(AttributesStart)
EnableMakros=true
$(AttributesEnd)
StrToIntDef($Param(), $Param(-1))|
[bs | BoolToStr]
$(AttributesStart)
EnableMakros=true
$(AttributesEnd)
BoolToStr($Param(), true)|
[sb | StrToBool]
$(AttributesStart)
EnableMakros=true
$(AttributesEnd)
StrToBool($Param())|
[sbd | StrToBoolDef]
$(AttributesStart)
EnableMakros=true
$(AttributesEnd)
StrToBoolDef($Param(), $Param(false))|
[ih | IntToHex]
$(AttributesStart)
EnableMakros=true
$(AttributesEnd)
IntToHex($Param())|  �9  D   ��
 C O L O R S C H E M E D E F A U L T         0	        <?xml version="1.0"?>
<CONFIG>
  <Lazarus>
    <ColorSchemes Version="6">
      <Names Count="1">
        <Item1 Value="Default"/>
      </Names>
      <Globals Version="6">
        <SchemeDefault>
          <ahaDefault Background="clWhite" Foreground="clBlack"/>
          <ahaExecutionPoint Background="clMedGray" Foreground="clWhite"  ForePriority="500" BackPriority="500" FramePriority="500"/>
          <ahaEnabledBreakpoint Background="clRed" Foreground="clBlack" ForePriority="500" BackPriority="500" FramePriority="500"/>
          <ahaDisabledBreakpoint Background="clGreen" Foreground="clBlack" ForePriority="500" BackPriority="500" FramePriority="500"/>
          <ahaInvalidBreakpoint Background="clOlive" Foreground="clGreen" ForePriority="500" BackPriority="500" FramePriority="500"/>
          <ahaUnknownBreakpoint Background="clRed" Foreground="clBlack" ForePriority="500" BackPriority="500" FramePriority="500"/>
          <ahaErrorLine Background="5284095" Foreground="clBlack" ForePriority="500" BackPriority="500" FramePriority="500"/>
          <ahaLineHighlight  ForePriority="500" BackPriority="500" FramePriority="500"/>
          <ahaWordGroup FrameColor="clRed" ForePriority="3000" BackPriority="3000" FramePriority="3000"/>
          <ahaBracketMatch Style="fsBold" ForePriority="3000" BackPriority="3000" FramePriority="3000"/>
          <ahaHighlightWord Background="15132390" FrameColor="clSilver" ForePriority="3000" BackPriority="3000" FramePriority="3000"/>
          <ahaIncrementalSearch Background="3199088" Foreground="clWhite"  ForePriority="4000" BackPriority="4000" FramePriority="4000"/>
          <ahaHighlightAll Background="clYellow" ForePriority="4000" BackPriority="4000" FramePriority="4000"/>
          <ahaTemplateEditCur FrameColor="clAqua" ForePriority="6000" BackPriority="6000" FramePriority="6000"/>
          <ahaTemplateEditSync FrameColor="clFuchsia" ForePriority="6000" BackPriority="6000" FramePriority="6000"/>
          <ahaTemplateEditOther FrameColor="clMaroon" ForePriority="6000" BackPriority="6000" FramePriority="6000"/>
          <ahaSyncroEditCur FrameColor="clFuchsia" ForePriority="2000" BackPriority="2000" FramePriority="2000"/>
          <ahaSyncroEditSync FrameColor="clRed" ForePriority="6000" BackPriority="6000" FramePriority="6000"/>
          <ahaSyncroEditOther FrameColor="9744532" ForePriority="6000" BackPriority="6000" FramePriority="6000"/>
          <ahaSyncroEditArea Background="clMoneyGreen" ForePriority="2000" BackPriority="2000" FramePriority="2000"/>
          <ahaTextBlock Background="clNavy" Foreground="clWhite" ForePriority="7000" BackPriority="7000" FramePriority="7000"/>
          <ahaMouseLink Foreground="clBlue" ForePriority="1500" BackPriority="2500" FramePriority="7500"/>
          <ahaFoldedCode Background="clWhite" Foreground="clSilver" FrameColor="clSilver"  ForePriority="8000" BackPriority="8000" FramePriority="8000"/>
		  <ahaSpecialVisibleChars  ForePriority="8100" BackPriority="8100" FramePriority="8100"/>
          <ahaTopInfoHint Background="clSkyBlue" Foreground="clBlack" FrameColor="clMaroon" FrameStyle="slsDashed" FrameEdges="sfeBottom" ForePriority="8500" BackPriority="8500" FramePriority="8500"/>
          <ahaIfDefBlockInactive Foreground="clSilver" ForeAlpha="165" ForePriority="9050" BackPriority="9050" FramePriority="9050"/>
          <ahaIfDefBlockActive  ForePriority="9000" BackPriority="9000" FramePriority="9000"/>
          <ahaIfDefBlockTmpActive  ForePriority="9000" BackPriority="9000" FramePriority="9000"/>
          <ahaIfDefNodeActive  ForePriority="9050" BackPriority="9050" FramePriority="9050"/>
          <ahaIfDefNodeInactive ForePriority="9150" BackPriority="9150" FramePriority="9150"/>
          <ahaIfDefNodeTmpActive  ForePriority="9050" BackPriority="9050" FramePriority="9050"/>
          <ahaModifiedLine Foreground="clGreen" FrameColor="59900"/>
          <ahaCodeFoldingTree Background="clWhite" Foreground="clSilver"/>
          <ahaGutterSeparator Background="clWhite" Foreground="clGray"/>
          <ahaGutter Background="15790320"/>
          <ahaRightMargin Foreground="clSilver"/>
          <ahaOverviewGutter Foreground="13948116" Background="15263976" FrameColor="12632256"/>
          <ahaIdentComplWindowHighlight Foreground="187"/>
          <ahaIdentComplRecent Foreground="clGreen"/>
          <ahaIdentComplWindowEntryConst Foreground="clOlive"/>
          <ahaIdentComplWindowEntryFunc Foreground="clTeal"/>
          <ahaIdentComplWindowEntryIdent Foreground="clBlack"/>
          <ahaIdentComplWindowEntryKeyword Foreground="clBlack"/>
          <ahaIdentComplWindowEntryEnum Foreground="clOlive"/>
          <ahaIdentComplWindowEntryLabel Foreground="clOlive"/>
          <ahaIdentComplWindowEntryMethAbstract Foreground="clRed"/>
          <ahaIdentComplWindowEntryMethodLowVis Foreground="clGray"/>
          <ahaIdentComplWindowEntryNameSpace Foreground="clBlack"/>
          <ahaIdentComplWindowEntryProc Foreground="clNavy"/>
          <ahaIdentComplWindowEntryProp Foreground="clPurple"/>
          <ahaIdentComplWindowEntryTempl Foreground="clGray"/>
          <ahaIdentComplWindowEntryText Foreground="clGray"/>
          <ahaIdentComplWindowEntryType Foreground="clLime"/>
          <ahaIdentComplWindowEntryUnit Foreground="clBlack"/>
          <ahaIdentComplWindowEntryUnknown Foreground="clGray"/>
          <ahaIdentComplWindowEntryVar Foreground="clMaroon"/>
          <ahaOutlineLevel1Color Foreground="clRed"/>
          <ahaOutlineLevel2Color Foreground="39159"/>
          <ahaOutlineLevel3Color Foreground="2280512"/>
          <ahaOutlineLevel4Color Foreground="13421568"/>
          <ahaOutlineLevel5Color Foreground="16738346"/>
          <ahaOutlineLevel6Color Foreground="13566148"/>
        </SchemeDefault>
      </Globals>
      <LangObjectPascal Version="6">
        <SchemeDefault>
          <Assembler Foreground="clGreen"/>
          <Comment Foreground="clBlue" Style="fsBold"/>
          <Directive Foreground="clRed" Style="fsBold"/>
          <Number Foreground="clNavy"/>
          <Reserved_word Style="fsBold"/>
          <String Foreground="clBlue"/>
          <Symbol Foreground="clRed"/>
          <NestedRoundBracket_1 Foreground="12917458"/>
          <NestedRoundBracket_2 Foreground="8421631"/>
          <NestedRoundBracket_3 Foreground="8301827"/>
        </SchemeDefault>
      </LangObjectPascal>
      <LangLazarus_Form_definition Version="6">
        <SchemeDefault>
          <Comment Foreground="clBlue" Style="fsBold"/>
          <Key Style="fsBold"/>
          <Number Foreground="clNavy"/>
          <String Foreground="clBlue"/>
          <Symbol Foreground="clRed"/>
        </SchemeDefault>
      </LangLazarus_Form_definition>
      <LangXML_document Version="6">
        <SchemeDefault>
          <Attribute_Name Foreground="clMaroon"/>
          <Attribute_Value Foreground="clNavy" Style="fsBold"/>
          <CDATA_Section Foreground="clOlive" Style="fsItalic"/>
          <Comment Foreground="clBlue" Style="fsBold"/>
          <DOCTYPE_Section Foreground="clBlue" Style="fsItalic"/>
          <Element_Name Foreground="clMaroon" Style="fsBold"/>
          <Entity_Reference Foreground="clBlue" Style="fsBold"/>
          <Namespace_Attribute_Name Foreground="clRed"/>
          <Namespace_Attribute_Value Foreground="clRed" Style="fsBold"/>
          <Processing_Instruction Foreground="clBlue"/>
          <Symbol Foreground="clRed"/>
          <Text Foreground="clBlack" Style="fsBold"/>
        </SchemeDefault>
      </LangXML_document>
      <LangHTML_document Version="6">
        <SchemeDefault>
          <Asp Background="clYellow" Foreground="clBlack"/>
          <Comment Foreground="clBlue" Style="fsBold"/>
          <Escape_ampersand Foreground="clLime" Style="fsBold"/>
          <Identifier Style="fsBold"/>
          <Reserved_word Style="fsBold"/>
          <Symbol Foreground="clRed"/>
          <Unknown_word Foreground="clRed" Style="fsBold"/>
          <Value Foreground="16744448"/>
        </SchemeDefault>
      </LangHTML_document>
      <LangC__ Version="6">
        <SchemeDefault>
          <Assembler Foreground="clGreen"/>
          <Comment Foreground="clBlue" Style="fsBold"/>
          <Number Foreground="clNavy"/>
          <Preprocessor Foreground="clBlue" Style="fsBold"/>
          <Reserved_word Style="fsBold"/>
          <Space Foreground="clWindow"/>
          <String Foreground="clBlue"/>
          <Symbol Foreground="clRed"/>
        </SchemeDefault>
      </LangC__>
      <LangPerl Version="6">
        <SchemeDefault>
          <Comment Foreground="clBlue" Style="fsBold"/>
          <Number Foreground="clNavy"/>
          <Pragma Style="fsBold"/>
          <Reserved_word Style="fsBold"/>
          <Space Foreground="clWindow"/>
          <String Foreground="clBlue"/>
          <Symbol Foreground="clRed"/>
          <Variable Style="fsBold"/>
        </SchemeDefault>
      </LangPerl>
      <LangJava Version="6">
        <SchemeDefault>
          <Comment Foreground="clBlue" Style="fsBold"/>
          <Documentation Foreground="clBlue" Style="fsBold"/>
          <Number Foreground="clNavy"/>
          <Reserved_word Style="fsBold"/>
          <Space Foreground="clWindow"/>
          <String Foreground="clBlue"/>
          <Symbol Foreground="clRed"/>
        </SchemeDefault>
      </LangJava>
      <LangUNIX_Shell_Script Version="6">
        <SchemeDefault>
          <Comment Foreground="clBlue" Style="fsBold"/>
          <Number Foreground="clNavy"/>
          <Reserved_word Style="fsBold"/>
          <String Foreground="clBlue"/>
          <Symbol Foreground="clRed"/>
          <Variable Foreground="clPurple"/>
        </SchemeDefault>
      </LangUNIX_Shell_Script>
      <LangPython Version="6">
        <SchemeDefault>
          <Comment Foreground="clBlue" Style="fsBold"/>
          <Documentation Foreground="clBlue" Style="fsBold"/>
          <Float Foreground="clBlue"/>
          <Hexadecimal Foreground="clBlue"/>
          <Non_reserved_keyword Foreground="clNavy" Style="fsBold"/>
          <Number Foreground="clNavy"/>
          <Octal Foreground="clBlue"/>
          <Reserved_word Style="fsBold"/>
          <String Foreground="clBlue"/>
          <Symbol Foreground="clRed"/>
          <SyntaxError Foreground="clRed"/>
          <System_functions_and_variables Style="fsBold"/>
        </SchemeDefault>
      </LangPython>
      <LangPHP Version="6">
        <SchemeDefault>
          <Comment Foreground="clBlue" Style="fsBold"/>
          <Number Foreground="clNavy"/>
          <Reserved_word Style="fsBold"/>
          <String Foreground="clBlue"/>
          <Symbol Foreground="clRed"/>
        </SchemeDefault>
      </LangPHP>
      <LangSQL Version="6">
        <SchemeDefault>
          <Comment Foreground="clBlue" Style="fsBold"/>
          <Data_type Style="fsBold"/>
          <Default_packages Style="fsBold"/>
          <Exception Style="fsItalic"/>
          <Function Style="fsBold"/>
          <Number Foreground="clNavy"/>
          <Reserved_word Style="fsBold"/>
          <Reserved_word__PL_SQL_ Style="fsBold"/>
          <SQL_Plus_command Style="fsBold"/>
          <String Foreground="clBlue"/>
          <Symbol Foreground="clRed"/>
        </SchemeDefault>
      </LangSQL>
      <LangCSS Version="6">
        <SchemeDefault>
          <Comment Foreground="clBlue" />
          <Measurement_Unit Foreground="clNavy" Style="fsBold"/>
          <Number Foreground="clNavy"/>
          <Selector Style="fsBold"/>
          <String Foreground="clPurple"/>
          <Symbol Foreground="clRed"/>
        </SchemeDefault>
      </LangCSS>
      <LangJavascript Version="6">
        <SchemeDefault>
          <Comment Foreground="clBlue" Style="fsBold"/>
          <Number Foreground="clNavy"/>
          <Reserved_word Style="fsBold"/>
          <String Foreground="clBlue"/>
          <Symbol Foreground="clRed"/>
        </SchemeDefault>
      </LangJavascript>
      <LangDiff_File Version="6">
        <SchemeDefault>
          <Diff_Added_line Foreground="clGreen"/>
          <Diff_Changed_Line Foreground="clPurple"/>
          <Diff_Chunk_Line_Counts Foreground="clPurple" Style="fsBold"/>
          <Diff_Chunk_Marker Style="fsBold"/>
          <Diff_Chunk_New_Line_Count Foreground="clGreen" Style="fsBold"/>
          <Diff_Chunk_Original_Line_Count Foreground="clRed" Style="fsBold"/>
          <Diff_New_File Background="clGreen" Style="fsBold"/>
          <Diff_Original_File Background="clRed" Style="fsBold"/>
          <Diff_Removed_Line Foreground="clRed"/>
          <Unknown_word Style="fsItalic"/>
        </SchemeDefault>
      </LangDiff_File>
      <LangMS_DOS_batch_language Version="6">
        <SchemeDefault>
          <Key Style="fsBold"/>
          <Number Foreground="clBlue"/>
          <Comment Foreground="clNavy" Style="fsItalic"/>
          <Variable Foreground="clGreen"/>
        </SchemeDefault>
      </LangMS_DOS_batch_language>
      <LangINI_file Version="6">
        <SchemeDefault>
          <Comment Foreground="clGreen" Style="fsItalic"/>
          <Section Style="fsBold"/>
        </SchemeDefault>
      </LangINI_file>
      <Langpo_language_files Version="8">
        <SchemeDefault>
          <Key Style="fsBold"/>
          <Flags Foreground="clTeal"/>
          <String Foreground="clFuchsia"/>
          <Comment Style="fsItalic" Foreground="clGreen"/>
          <Identifier Style="fsBold" Foreground="clGreen"/>
          <Previous_value Style="fsItalic" Foreground="clOlive"/>
        </SchemeDefault>
      </Langpo_language_files>
      <LangDisassembler_Window Version="13">
        <SchemeDefault>
          <ahaDefault Background="clForm" Foreground="clBlack" UseSchemeGlobals="False"/>
          <ahaAsmSourceFunc Style="fsBold"/>
          <ahaAsmSourceLine Style="fsBold"/>
          <ahaTextBlock Background="clHighlight" Foreground="clHighlightText" UseSchemeGlobals="False" ForePriority="400" BackPriority="400" FramePriority="400"/>
          <ahaLineHighlight Foreground="clHighlightText" FrameColor="clBlack" UseSchemeGlobals="False" Background="clHighlight" ForePriority="1000" BackPriority="1000" FramePriority="1000"/>
          <ahaMouseLink Style="fsUnderline" FrameColor="clNone" UseSchemeGlobals="False"/>
          <ahaAsmLinkTarget Foreground="clHotLight"/>
        </SchemeDefault>
      </LangDisassembler_Window>
    </ColorSchemes>
  </Lazarus>
</CONFIG>
�7  @   ��
 C O L O R S C H E M E D E L P H I       0	        <?xml version="1.0"?>
<CONFIG>
  <Lazarus>
    <ColorSchemes Version="6">
      <Names Count="1">
        <Item1 Value="Delphi"/>
      </Names>
      <Globals Version="6">
        <SchemeDelphi>
          <ahaExecutionPoint Background="10066380" Foreground="clBlack" ForePriority="500" BackPriority="500" FramePriority="500"/>
          <ahaEnabledBreakpoint Background="16762823" Foreground="clBlack" ForePriority="500" BackPriority="500" FramePriority="500"/>
          <ahaDisabledBreakpoint Background="16762823" Foreground="clGray" ForePriority="500" BackPriority="500" FramePriority="500"/>
          <ahaInvalidBreakpoint Background="clGreen" Foreground="clWhite" ForePriority="500" BackPriority="500" FramePriority="500"/>
          <ahaUnknownBreakpoint Background="16762823" Foreground="clBlack" ForePriority="500" BackPriority="500" FramePriority="500"/>
          <ahaErrorLine Background="clRed" Foreground="clWhite" ForePriority="500" BackPriority="500" FramePriority="500"/>
          <ahaLineHighlight Background="15138810" ForePriority="500" BackPriority="500" FramePriority="500"/>
          <ahaWordGroup FrameColor="clRed" ForePriority="3000" BackPriority="3000" FramePriority="3000"/>
          <ahaBracketMatch Background="clAqua" FrameColor="13421782" ForePriority="3000" BackPriority="3000" FramePriority="3000"/>
          <ahaHighlightWord FrameColor="13421782" ForePriority="3000" BackPriority="3000" FramePriority="3000"/>
          <ahaIncrementalSearch Background="clBlack" Foreground="16580045" ForePriority="4000" BackPriority="4000" FramePriority="4000"/>
          <ahaHighlightAll Background="clYellow" ForePriority="4000" BackPriority="4000" FramePriority="4000"/>
          <ahaTemplateEditCur FrameColor="clAqua" ForePriority="6000" BackPriority="6000" FramePriority="6000"/>
          <ahaTemplateEditSync FrameColor="clFuchsia" ForePriority="6000" BackPriority="6000" FramePriority="6000"/>
          <ahaTemplateEditOther FrameColor="clMaroon" ForePriority="6000" BackPriority="6000" FramePriority="6000"/>
          <ahaSyncroEditCur FrameColor="clFuchsia" ForePriority="6000" BackPriority="6000" FramePriority="6000"/>
          <ahaSyncroEditSync FrameColor="clRed" ForePriority="6000" BackPriority="6000" FramePriority="6000"/>
          <ahaSyncroEditOther FrameColor="clBlue" ForePriority="6000" BackPriority="6000" FramePriority="6000"/>
          <ahaSyncroEditArea Background="16449510" ForePriority="2000" BackPriority="2000" FramePriority="2000"/>
          <ahaTextBlock Background="10841427" Foreground="clWhite" ForePriority="7000" BackPriority="7000" FramePriority="7000"/>
          <ahaMouseLink Foreground="clBlue" ForePriority="1500" BackPriority="2500" FramePriority="7500"/>
          <ahaFoldedCode Foreground="13408665" FrameColor="13408665" ForePriority="8000" BackPriority="8000" FramePriority="8000"/>
		  <ahaSpecialVisibleChars  ForePriority="8100" BackPriority="8100" FramePriority="8100"/>
          <ahaTopInfoHint Background="clSkyBlue" Foreground="clBlack" FrameColor="clMaroon" FrameStyle="slsDashed" FrameEdges="sfeBottom" ForePriority="8500" BackPriority="8500" FramePriority="8500"/>
          <ahaIfDefBlockInactive Foreground="clSilver" ForeAlpha="165" ForePriority="9050" BackPriority="9050" FramePriority="9050"/>
          <ahaIfDefBlockActive  ForePriority="9000" BackPriority="9000" FramePriority="9000"/>
          <ahaIfDefBlockTmpActive  ForePriority="9000" BackPriority="9000" FramePriority="9000"/>
          <ahaIfDefNodeActive  ForePriority="9050" BackPriority="9050" FramePriority="9050"/>
          <ahaIfDefNodeInactive ForePriority="9150" BackPriority="9150" FramePriority="9150"/>
          <ahaIfDefNodeTmpActive  ForePriority="9050" BackPriority="9050" FramePriority="9050"/>
          <ahaLineNumber Background="16053492" Foreground="13408665"/>
          <ahaModifiedLine Background="16053492" Foreground="clLime" FrameColor="clYellow"/>
          <ahaCodeFoldingTree Background="16053492" Foreground="13408665"/>
          <ahaGutterSeparator Background="clWhite" Foreground="clGray"/>
          <ahaGutter Background="15790320"/>
          <ahaRightMargin Foreground="clSilver"/>
          <ahaOverviewGutter Foreground="13948116" Background="15263976" FrameColor="12632256"/>
          <ahaIdentComplWindowHighlight Foreground="191"/>
          <ahaIdentComplRecent Foreground="clGreen"/>
          <ahaIdentComplWindowEntryConst Foreground="clOlive"/>
          <ahaIdentComplWindowEntryFunc Foreground="clTeal"/>
          <ahaIdentComplWindowEntryIdent Foreground="clBlack"/>
          <ahaIdentComplWindowEntryKeyword Foreground="clBlack"/>
          <ahaIdentComplWindowEntryEnum Foreground="clOlive"/>
          <ahaIdentComplWindowEntryLabel Foreground="clOlive"/>
          <ahaIdentComplWindowEntryMethAbstract Foreground="clRed"/>
          <ahaIdentComplWindowEntryMethodLowVis Foreground="clGray"/>
          <ahaIdentComplWindowEntryNameSpace Foreground="clBlack"/>
          <ahaIdentComplWindowEntryProc Foreground="clNavy"/>
          <ahaIdentComplWindowEntryProp Foreground="clPurple"/>
          <ahaIdentComplWindowEntryTempl Foreground="clGray"/>
          <ahaIdentComplWindowEntryText Foreground="clGray"/>
          <ahaIdentComplWindowEntryType Foreground="clLime"/>
          <ahaIdentComplWindowEntryUnit Foreground="clBlack"/>
          <ahaIdentComplWindowEntryUnknown Foreground="clGray"/>
          <ahaIdentComplWindowEntryVar Foreground="clMaroon"/>
          <ahaOutlineLevel1Color Foreground="clRed"/>
          <ahaOutlineLevel2Color Foreground="39159"/>
          <ahaOutlineLevel3Color Foreground="2280512"/>
          <ahaOutlineLevel4Color Foreground="13421568"/>
          <ahaOutlineLevel5Color Foreground="16738346"/>
          <ahaOutlineLevel6Color Foreground="13566148"/>
        </SchemeDelphi>
      </Globals>
      <LangObjectPascal Version="6">
        <SchemeDelphi>
          <Assembler Foreground="clBlack"/>
          <Comment Foreground="clGreen" Style="fsItalic"/>
          <Directive Foreground="clTeal"/>
          <Number Foreground="clBlue"/>
          <Modifier Foreground="clNavy" Style="fsBold"/>
          <Reserved_word Foreground="clNavy" Style="fsBold"/>
          <String Foreground="clBlue"/>
          <NestedRoundBracket_1 Foreground="12917458"/>
          <NestedRoundBracket_2 Foreground="8421631"/>
          <NestedRoundBracket_3 Foreground="8301827"/>
        </SchemeDelphi>
      </LangObjectPascal>
      <LangLazarus_Form_definition Version="6">
        <SchemeDelphi>
          <Comment Foreground="clGreen" Style="fsItalic"/>
          <Key Style="fsBold"/>
          <Number Foreground="clBlue"/>
          <String Foreground="clBlue"/>
        </SchemeDelphi>
      </LangLazarus_Form_definition>
      <LangXML_document Version="6">
        <SchemeDelphi>
          <Attribute_Name Foreground="clMaroon"/>
          <Attribute_Value Foreground="clNavy" Style="fsBold"/>
          <CDATA_Section Foreground="clOlive" Style="fsItalic"/>
          <Comment Foreground="clGreen" Style="fsItalic"/>
          <DOCTYPE_Section Foreground="clBlue" Style="fsItalic"/>
          <Element_Name Foreground="clMaroon" Style="fsBold"/>
          <Entity_Reference Foreground="clBlue" Style="fsBold"/>
          <Namespace_Attribute_Name Foreground="clRed"/>
          <Namespace_Attribute_Value Foreground="clRed" Style="fsBold"/>
          <Processing_Instruction Foreground="clBlue"/>
          <Text Foreground="clBlack" Style="fsBold"/>
        </SchemeDelphi>
      </LangXML_document>
      <LangHTML_document Version="6">
        <SchemeDelphi>
          <Asp Background="clYellow" Foreground="clBlack"/>
          <Comment Foreground="clGreen" Style="fsItalic"/>
          <Escape_ampersand Foreground="clLime" Style="fsBold"/>
          <Identifier Style="fsBold"/>
          <Reserved_word Foreground="clNavy" Style="fsBold"/>
          <Unknown_word Foreground="clRed" Style="fsBold"/>
          <Value Foreground="16744448"/>
        </SchemeDelphi>
      </LangHTML_document>
      <LangC__ Version="6">
        <SchemeDelphi>
          <Assembler Foreground="clBlack"/>
          <Comment Foreground="clGreen" Style="fsItalic"/>
          <Number Foreground="clBlue"/>
          <Preprocessor Foreground="clGreen" Style="fsItalic"/>
          <Reserved_word Foreground="clNavy" Style="fsBold"/>
          <Space Foreground="clWindow"/>
          <String Foreground="clBlue"/>
        </SchemeDelphi>
      </LangC__>
      <LangPerl Version="6">
        <SchemeDelphi>
          <Comment Foreground="clGreen" Style="fsItalic"/>
          <Number Foreground="clBlue"/>
          <Pragma Style="fsBold"/>
          <Reserved_word Foreground="clNavy" Style="fsBold"/>
          <Space Foreground="clWindow"/>
          <String Foreground="clBlue"/>
          <Variable Style="fsBold"/>
        </SchemeDelphi>
      </LangPerl>
      <LangJava Version="6">
        <SchemeDelphi>
          <Comment Foreground="clGreen" Style="fsItalic"/>
          <Documentation Foreground="clGreen" Style="fsItalic"/>
          <Number Foreground="clBlue"/>
          <Reserved_word Foreground="clNavy" Style="fsBold"/>
          <Space Foreground="clWindow"/>
          <String Foreground="clBlue"/>
        </SchemeDelphi>
      </LangJava>
      <LangUNIX_Shell_Script Version="6">
        <SchemeDelphi>
          <Comment Foreground="clGreen" Style="fsItalic"/>
          <Number Foreground="clBlue"/>
          <Reserved_word Foreground="clNavy" Style="fsBold"/>
          <String Foreground="clBlue"/>
          <Variable Foreground="clPurple"/>
        </SchemeDelphi>
      </LangUNIX_Shell_Script>
      <LangPython Version="6">
        <SchemeDelphi>
          <Comment Foreground="clGreen" Style="fsItalic"/>
          <Documentation Foreground="clGreen" Style="fsItalic"/>
          <Float Foreground="clBlue"/>
          <Hexadecimal Foreground="clBlue"/>
          <Non_reserved_keyword Foreground="clNavy" Style="fsBold"/>
          <Number Foreground="clBlue"/>
          <Octal Foreground="clBlue"/>
          <Reserved_word Foreground="clNavy" Style="fsBold"/>
          <String Foreground="clBlue"/>
          <SyntaxError Foreground="clRed"/>
          <System_functions_and_variables Style="fsBold"/>
        </SchemeDelphi>
      </LangPython>
      <LangPHP Version="6">
        <SchemeDelphi>
          <Comment Foreground="clGreen" Style="fsItalic"/>
          <Number Foreground="clBlue"/>
          <Reserved_word Foreground="clNavy" Style="fsBold"/>
          <String Foreground="clBlue"/>
        </SchemeDelphi>
      </LangPHP>
      <LangSQL Version="6">
        <SchemeDelphi>
          <Comment Foreground="clGreen" Style="fsItalic"/>
          <Data_type Style="fsBold"/>
          <Default_packages Style="fsBold"/>
          <Exception Style="fsItalic"/>
          <Function Style="fsBold"/>
          <Number Foreground="clBlue"/>
          <Reserved_word Foreground="clNavy" Style="fsBold"/>
          <Reserved_word__PL_SQL_ Style="fsBold"/>
          <SQL_Plus_command Style="fsBold"/>
          <String Foreground="clBlue"/>
        </SchemeDelphi>
      </LangSQL>
      <LangJavascript Version="6">
        <SchemeDelphi>
          <Comment Foreground="clGreen" Style="fsItalic"/>
          <Number Foreground="clBlue"/>
          <Reserved_word Foreground="clNavy" Style="fsBold"/>
          <String Foreground="clBlue"/>
        </SchemeDelphi>
      </LangJavascript>
      <LangDiff_File Version="6">
        <SchemeDelphi>
          <Diff_Added_line Foreground="clGreen"/>
          <Diff_Changed_Line Foreground="clPurple"/>
          <Diff_Chunk_Line_Counts Foreground="clPurple" Style="fsBold"/>
          <Diff_Chunk_Marker Style="fsBold"/>
          <Diff_Chunk_New_Line_Count Foreground="clGreen" Style="fsBold"/>
          <Diff_Chunk_Original_Line_Count Foreground="clRed" Style="fsBold"/>
          <Diff_New_File Background="clGreen" Style="fsBold"/>
          <Diff_Original_File Background="clRed" Style="fsBold"/>
          <Diff_Removed_Line Foreground="clRed"/>
          <Unknown_word Style="fsItalic"/>
        </SchemeDelphi>
      </LangDiff_File>
      <LangMS_DOS_batch_language Version="6">
        <SchemeDelphi>
          <Key Style="fsBold"/>
          <Number Foreground="clBlue"/>
          <Comment Foreground="clNavy" Style="fsItalic"/>
          <Variable Foreground="clGreen"/>
        </SchemeDelphi>
      </LangMS_DOS_batch_language>
      <LangINI_file Version="6">
        <SchemeDelphi>
          <Comment Foreground="clGreen" Style="fsItalic"/>
          <Section Style="fsBold"/>
        </SchemeDelphi>
      </LangINI_file>
      <Langpo_language_files Version="8">
        <SchemeDelphi>
          <Key Style="fsBold"/>
          <Flags Foreground="clTeal"/>
          <String Foreground="clFuchsia"/>
          <Comment Style="fsItalic" Foreground="clGreen"/>
          <Identifier Style="fsBold" Foreground="clGreen"/>
          <Previous_value Style="fsItalic" Foreground="clOlive"/>
        </SchemeDelphi>
      </Langpo_language_files>
      <LangDisassembler_Window Version="13">
        <SchemeDelphi>
          <ahaDefault Background="clForm" Foreground="clBlack" UseSchemeGlobals="False"/>
          <ahaAsmSourceFunc Style="fsBold"/>
          <ahaAsmSourceLine Style="fsBold"/>
          <ahaTextBlock Background="clHighlight" Foreground="clHighlightText" UseSchemeGlobals="False" ForePriority="400" BackPriority="400" FramePriority="400"/>
          <ahaLineHighlight Foreground="clHighlightText" FrameColor="clBlack" UseSchemeGlobals="False" Background="clHighlight" ForePriority="1000" BackPriority="1000" FramePriority="1000"/>
          <ahaMouseLink Style="fsUnderline" FrameColor="clNone" UseSchemeGlobals="False"/>
          <ahaAsmLinkTarget Foreground="clHotLight"/>
        </SchemeDelphi>
      </LangDisassembler_Window>
    </ColorSchemes>
  </Lazarus>
</CONFIG>
5  @   ��
 C O L O R S C H E M E O C E A N         0	        <?xml version="1.0"?>
<CONFIG>
  <Lazarus>
    <ColorSchemes Version="6">
      <Names Count="1">
        <Item1 Value="Ocean"/>
      </Names>
      <Globals Version="6">
        <SchemeOcean>
          <ahaDefault Background="clNavy" Foreground="clYellow"/>
          <ahaExecutionPoint Background="clBlue" Foreground="clWhite" ForePriority="500" BackPriority="500" FramePriority="500"/>
          <ahaEnabledBreakpoint Background="clRed" Foreground="clWhite" ForePriority="500" BackPriority="500" FramePriority="500"/>
          <ahaDisabledBreakpoint Background="clLime" Foreground="clRed" ForePriority="500" BackPriority="500" FramePriority="500"/>
          <ahaInvalidBreakpoint Background="clOlive" Foreground="clGreen" ForePriority="500" BackPriority="500" FramePriority="500"/>
          <ahaUnknownBreakpoint Background="clRed" Foreground="clBlack" ForePriority="500" BackPriority="500" FramePriority="500"/>
          <ahaErrorLine Background="5284095" Foreground="clBlack" ForePriority="500" BackPriority="500" FramePriority="500"/>
          <ahaLineHighlight ForePriority="500" BackPriority="500" FramePriority="500"/>
          <ahaWordGroup FrameColor="clRed" ForePriority="3000" BackPriority="3000" FramePriority="3000"/>
          <ahaBracketMatch Style="fsBold" ForePriority="3000" BackPriority="3000" FramePriority="3000"/>
          <ahaHighlightWord FrameColor="clSilver" ForePriority="3000" BackPriority="3000" FramePriority="3000"/>
          <ahaIncrementalSearch Background="3199088" Foreground="clWhite" ForePriority="4000" BackPriority="4000" FramePriority="4000"/>
          <ahaHighlightAll Background="clYellow" ForePriority="4000" BackPriority="4000" FramePriority="4000"/>
          <ahaTemplateEditCur FrameColor="clAqua" ForePriority="6000" BackPriority="6000" FramePriority="6000"/>
          <ahaTemplateEditSync FrameColor="clFuchsia" ForePriority="6000" BackPriority="6000" FramePriority="6000"/>
          <ahaTemplateEditOther FrameColor="clMaroon" ForePriority="6000" BackPriority="6000" FramePriority="6000"/>
          <ahaSyncroEditCur FrameColor="clFuchsia" ForePriority="6000" BackPriority="6000" FramePriority="6000"/>
          <ahaSyncroEditSync FrameColor="clRed" ForePriority="6000" BackPriority="6000" FramePriority="6000"/>
          <ahaSyncroEditOther FrameColor="9744532" ForePriority="6000" BackPriority="6000" FramePriority="6000"/>
          <ahaSyncroEditArea Background="clGray" ForePriority="2000" BackPriority="2000" FramePriority="2000"/>
          <ahaTextBlock Background="clWhite" Foreground="clBlack" ForePriority="7000" BackPriority="7000" FramePriority="7000"/>
          <ahaMouseLink Foreground="clAqua" ForePriority="1500" BackPriority="2500" FramePriority="7500"/>
          <ahaFoldedCode Foreground="clSilver" FrameColor="clSilver" ForePriority="8000" BackPriority="8000" FramePriority="8000"/>
		  <ahaSpecialVisibleChars  ForePriority="8100" BackPriority="8100" FramePriority="8100"/>
          <ahaTopInfoHint Background="clPurple" Foreground="clYellow" FrameColor="clOlive" FrameStyle="slsDashed" ForePriority="8500" BackPriority="8500" FramePriority="8500"/>
          <ahaIfDefBlockInactive Foreground="clBlack" ForeAlpha="150" ForePriority="9050" BackPriority="9050" FramePriority="9050"/>
          <ahaIfDefBlockActive  ForePriority="9000" BackPriority="9000" FramePriority="9000"/>
          <ahaIfDefBlockTmpActive  ForePriority="9000" BackPriority="9000" FramePriority="9000"/>
          <ahaIfDefNodeActive  ForePriority="9050" BackPriority="9050" FramePriority="9050"/>
          <ahaIfDefNodeInactive ForePriority="9150" BackPriority="9150" FramePriority="9150"/>
          <ahaIfDefNodeTmpActive  ForePriority="9050" BackPriority="9050" FramePriority="9050"/>
          <ahaModifiedLine Foreground="clGreen" FrameColor="59900"/>
          <ahaCodeFoldingTree Foreground="clSilver"/>
          <ahaGutterSeparator Background="clWhite" Foreground="clGray"/>
          <ahaGutter Background="clNavy"/>
          <ahaRightMargin Foreground="clSilver"/>
          <ahaOverviewGutter Foreground="4210752" Background="6579300" FrameColor="clBlue"/>
          <ahaIdentComplWindowHighlight Foreground="clAqua"/>
          <ahaIdentComplRecent Foreground="clLime"/>
          <ahaIdentComplWindowEntryConst Foreground="clOlive"/>
          <ahaIdentComplWindowEntryFunc Foreground="clTeal"/>
          <ahaIdentComplWindowEntryIdent Foreground="clBlack"/>
          <ahaIdentComplWindowEntryKeyword Foreground="clBlack"/>
          <ahaIdentComplWindowEntryEnum Foreground="clOlive"/>
          <ahaIdentComplWindowEntryLabel Foreground="clOlive"/>
          <ahaIdentComplWindowEntryMethAbstract Foreground="clRed"/>
          <ahaIdentComplWindowEntryMethodLowVis Foreground="clGray"/>
          <ahaIdentComplWindowEntryNameSpace Foreground="clBlack"/>
          <ahaIdentComplWindowEntryProc Foreground="clNavy"/>
          <ahaIdentComplWindowEntryProp Foreground="clPurple"/>
          <ahaIdentComplWindowEntryTempl Foreground="clGray"/>
          <ahaIdentComplWindowEntryText Foreground="clGray"/>
          <ahaIdentComplWindowEntryType Foreground="clLime"/>
          <ahaIdentComplWindowEntryUnit Foreground="clBlack"/>
          <ahaIdentComplWindowEntryUnknown Foreground="clGray"/>
          <ahaIdentComplWindowEntryVar Foreground="clMaroon"/>
          <ahaIdentComplWindow Background="8388649"/>
          <ahaOutlineLevel1Color Foreground="clRed"/>
          <ahaOutlineLevel2Color Foreground="39159"/>
          <ahaOutlineLevel3Color Foreground="2280512"/>
          <ahaOutlineLevel4Color Foreground="13421568"/>
          <ahaOutlineLevel5Color Foreground="16738346"/>
          <ahaOutlineLevel6Color Foreground="13566148"/>
        </SchemeOcean>
      </Globals>
      <LangObjectPascal Version="6">
        <SchemeOcean>
          <Assembler Foreground="clLime"/>
          <Comment Foreground="clGray"/>
          <Directive Foreground="clRed"/>
          <Number Foreground="clFuchsia"/>
          <Modifier Foreground="clAqua" Style="fsBold"/>
          <Reserved_word Foreground="clAqua" Style="fsBold"/>
          <String Foreground="clYellow"/>
          <Symbol Foreground="clAqua"/>
          <NestedRoundBracket_1 Foreground="clFuchsia"/>
          <NestedRoundBracket_2 Foreground="2996475"/>
          <NestedRoundBracket_3 Foreground="6814853"/>
        </SchemeOcean>
      </LangObjectPascal>
      <LangLazarus_Form_definition Version="6">
        <SchemeOcean>
          <Comment Foreground="clGray"/>
          <Key Style="fsBold"/>
          <Number Foreground="clFuchsia"/>
          <String Foreground="clYellow"/>
          <Symbol Foreground="clAqua"/>
        </SchemeOcean>
      </LangLazarus_Form_definition>
      <LangXML_document Version="6">
        <SchemeOcean>
          <Attribute_Name Foreground="clMaroon"/>
          <Attribute_Value Foreground="clNavy" Style="fsBold"/>
          <CDATA_Section Foreground="clOlive" Style="fsItalic"/>
          <Comment Foreground="clGray"/>
          <DOCTYPE_Section Foreground="clBlue" Style="fsItalic"/>
          <Element_Name Foreground="clMaroon" Style="fsBold"/>
          <Entity_Reference Foreground="clBlue" Style="fsBold"/>
          <Namespace_Attribute_Name Foreground="clRed"/>
          <Namespace_Attribute_Value Foreground="clRed" Style="fsBold"/>
          <Processing_Instruction Foreground="clBlue"/>
          <Symbol Foreground="clAqua"/>
          <Text Foreground="clBlack" Style="fsBold"/>
        </SchemeOcean>
      </LangXML_document>
      <LangHTML_document Version="6">
        <SchemeOcean>
          <Asp Background="clYellow" Foreground="clBlack"/>
          <Comment Foreground="clGray"/>
          <Escape_ampersand Foreground="clLime" Style="fsBold"/>
          <Identifier Style="fsBold"/>
          <Reserved_word Foreground="clAqua" Style="fsBold"/>
          <Symbol Foreground="clAqua"/>
          <Unknown_word Foreground="clRed" Style="fsBold"/>
          <Value Foreground="16744448"/>
        </SchemeOcean>
      </LangHTML_document>
      <LangC__ Version="6">
        <SchemeOcean>
          <Assembler Foreground="clLime"/>
          <Comment Foreground="clGray"/>
          <Number Foreground="clFuchsia"/>
          <Preprocessor Foreground="clGray"/>
          <Reserved_word Foreground="clAqua" Style="fsBold"/>
          <Space Foreground="clWindow"/>
          <String Foreground="clYellow"/>
          <Symbol Foreground="clAqua"/>
        </SchemeOcean>
      </LangC__>
      <LangPerl Version="6">
        <SchemeOcean>
          <Comment Foreground="clGray"/>
          <Number Foreground="clFuchsia"/>
          <Pragma Style="fsBold"/>
          <Reserved_word Foreground="clAqua" Style="fsBold"/>
          <Space Foreground="clWindow"/>
          <String Foreground="clYellow"/>
          <Symbol Foreground="clAqua"/>
          <Variable Style="fsBold"/>
        </SchemeOcean>
      </LangPerl>
      <LangJava Version="6">
        <SchemeOcean>
          <Comment Foreground="clGray"/>
          <Documentation Foreground="clGray"/>
          <Number Foreground="clFuchsia"/>
          <Reserved_word Foreground="clAqua" Style="fsBold"/>
          <Space Foreground="clWindow"/>
          <String Foreground="clYellow"/>
          <Symbol Foreground="clAqua"/>
        </SchemeOcean>
      </LangJava>
      <LangUNIX_Shell_Script Version="6">
        <SchemeOcean>
          <Comment Foreground="clGray"/>
          <Number Foreground="clFuchsia"/>
          <Reserved_word Foreground="clAqua" Style="fsBold"/>
          <String Foreground="clYellow"/>
          <Symbol Foreground="clAqua"/>
          <Variable Foreground="clPurple"/>
        </SchemeOcean>
      </LangUNIX_Shell_Script>
      <LangPython Version="6">
        <SchemeOcean>
          <Comment Foreground="clGray"/>
          <Documentation Foreground="clGray"/>
          <Float Foreground="clBlue"/>
          <Hexadecimal Foreground="clBlue"/>
          <Non_reserved_keyword Foreground="clNavy" Style="fsBold"/>
          <Number Foreground="clFuchsia"/>
          <Octal Foreground="clBlue"/>
          <Reserved_word Foreground="clAqua" Style="fsBold"/>
          <String Foreground="clYellow"/>
          <Symbol Foreground="clAqua"/>
          <SyntaxError Foreground="clRed"/>
          <System_functions_and_variables Style="fsBold"/>
        </SchemeOcean>
      </LangPython>
      <LangPHP Version="6">
        <SchemeOcean>
          <Comment Foreground="clGray"/>
          <Number Foreground="clFuchsia"/>
          <Reserved_word Foreground="clAqua" Style="fsBold"/>
          <String Foreground="clYellow"/>
          <Symbol Foreground="clAqua"/>
        </SchemeOcean>
      </LangPHP>
      <LangSQL Version="6">
        <SchemeOcean>
          <Comment Foreground="clGray"/>
          <Data_type Style="fsBold"/>
          <Default_packages Style="fsBold"/>
          <Exception Style="fsItalic"/>
          <Function Style="fsBold"/>
          <Number Foreground="clFuchsia"/>
          <Reserved_word Foreground="clAqua" Style="fsBold"/>
          <Reserved_word__PL_SQL_ Style="fsBold"/>
          <SQL_Plus_command Style="fsBold"/>
          <String Foreground="clYellow"/>
          <Symbol Foreground="clAqua"/>
        </SchemeOcean>
      </LangSQL>
      <LangJavascript Version="6">
        <SchemeOcean>
          <Comment Foreground="clGray"/>
          <Number Foreground="clFuchsia"/>
          <Reserved_word Foreground="clAqua" Style="fsBold"/>
          <String Foreground="clYellow"/>
          <Symbol Foreground="clAqua"/>
        </SchemeOcean>
      </LangJavascript>
      <LangDiff_File Version="6">
        <SchemeOcean>
          <Diff_Added_line Foreground="clGreen"/>
          <Diff_Changed_Line Foreground="clPurple"/>
          <Diff_Chunk_Line_Counts Foreground="clPurple" Style="fsBold"/>
          <Diff_Chunk_Marker Style="fsBold"/>
          <Diff_Chunk_New_Line_Count Foreground="clGreen" Style="fsBold"/>
          <Diff_Chunk_Original_Line_Count Foreground="clRed" Style="fsBold"/>
          <Diff_New_File Background="clGreen" Style="fsBold"/>
          <Diff_Original_File Background="clRed" Style="fsBold"/>
          <Diff_Removed_Line Foreground="clRed"/>
          <Unknown_word Style="fsItalic"/>
        </SchemeOcean>
      </LangDiff_File>
      <LangMS_DOS_batch_language Version="6">
        <SchemeOcean>
          <Key Style="fsBold"/>
          <Number Foreground="clFuchsia"/>
          <Comment Foreground="clNavy" Style="fsItalic"/>
          <Variable Foreground="clGreen"/>
        </SchemeOcean>
      </LangMS_DOS_batch_language>
      <LangINI_file Version="6">
        <SchemeOcean>
          <Comment Foreground="clGreen" Style="fsItalic"/>
          <Section Style="fsBold"/>
          <Number Foreground="clFuchsia"/>
        </SchemeOcean>
      </LangINI_file>
      <Langpo_language_files Version="8">
        <SchemeOcean>
          <Key Style="fsBold"/>
          <Flags Foreground="clTeal"/>
          <String Foreground="clFuchsia"/>
          <Comment Style="fsItalic" Foreground="clGreen"/>
          <Identifier Style="fsBold" Foreground="clGreen"/>
          <Previous_value Style="fsItalic" Foreground="clOlive"/>
        </SchemeOcean>
      </Langpo_language_files>
    </ColorSchemes>
  </Lazarus>
</CONFIG>
   i5  P   ��
 C O L O R S C H E M E P A S C A L C L A S S I C         0	        <?xml version="1.0"?>
<CONFIG>
  <Lazarus>
    <ColorSchemes Version="6">
      <Names Count="1">
        <Item1 Value="Pascal_Classic"/>
      </Names>
      <Globals Version="6">
        <SchemePascal_Classic>
          <ahaDefault Background="clNavy" Foreground="clYellow"/>
          <ahaExecutionPoint Background="clAqua" Foreground="clBlack" ForePriority="500" BackPriority="500" FramePriority="500"/>
          <ahaEnabledBreakpoint Background="clRed" Foreground="clWhite" ForePriority="500" BackPriority="500" FramePriority="500"/>
          <ahaDisabledBreakpoint Background="clLime" Foreground="clRed" ForePriority="500" BackPriority="500" FramePriority="500"/>
          <ahaInvalidBreakpoint Background="clOlive" Foreground="clLime" ForePriority="500" BackPriority="500" FramePriority="500"/>
          <ahaErrorLine Background="clMaroon" Foreground="clWhite" ForePriority="500" BackPriority="500" FramePriority="500"/>
          <ahaLineHighlight ForePriority="500" BackPriority="500" FramePriority="500"/>
          <ahaWordGroup FrameColor="clRed" ForePriority="3000" BackPriority="3000" FramePriority="3000"/>
          <ahaBracketMatch Style="fsBold" ForePriority="3000" BackPriority="3000" FramePriority="3000"/>
          <ahaHighlightWord FrameColor="clSilver" ForePriority="3000" BackPriority="3000" FramePriority="3000"/>
          <ahaIncrementalSearch Background="3199088" Foreground="clWhite" ForePriority="4000" BackPriority="4000" FramePriority="4000"/>
          <ahaHighlightAll Background="clYellow" ForePriority="4000" BackPriority="4000" FramePriority="4000"/>
          <ahaTemplateEditCur FrameColor="clAqua" ForePriority="6000" BackPriority="6000" FramePriority="6000"/>
          <ahaTemplateEditSync FrameColor="clFuchsia" ForePriority="6000" BackPriority="6000" FramePriority="6000"/>
          <ahaTemplateEditOther FrameColor="clMaroon" ForePriority="6000" BackPriority="6000" FramePriority="6000"/>
          <ahaSyncroEditCur FrameColor="clFuchsia" ForePriority="6000" BackPriority="6000" FramePriority="6000"/>
          <ahaSyncroEditSync FrameColor="clRed" ForePriority="6000" BackPriority="6000" FramePriority="6000"/>
          <ahaSyncroEditOther FrameColor="9744532" ForePriority="6000" BackPriority="6000" FramePriority="6000"/>
          <ahaSyncroEditArea Background="clGray" ForePriority="2000" BackPriority="2000" FramePriority="2000"/>
          <ahaTextBlock Background="clBlue" Foreground="clWhite" ForePriority="7000" BackPriority="7000" FramePriority="7000"/>
          <ahaMouseLink Foreground="clWhite" ForePriority="1500" BackPriority="2500" FramePriority="7500"/>
          <ahaFoldedCode Foreground="clSilver" FrameColor="clSilver" ForePriority="8000" BackPriority="8000" FramePriority="8000"/>
		  <ahaSpecialVisibleChars  ForePriority="8100" BackPriority="8100" FramePriority="8100"/>
          <ahaTopInfoHint Background="clPurple" Foreground="clYellow" FrameColor="clOlive" FrameStyle="slsDashed" ForePriority="8500" BackPriority="8500" FramePriority="8500"/>
          <ahaIfDefBlockInactive Foreground="clBlack" ForeAlpha="150" ForePriority="9050" BackPriority="9050" FramePriority="9050"/>
          <ahaIfDefBlockActive  ForePriority="9000" BackPriority="9000" FramePriority="9000"/>
          <ahaIfDefBlockTmpActive  ForePriority="9000" BackPriority="9000" FramePriority="9000"/>
          <ahaIfDefNodeActive  ForePriority="9050" BackPriority="9050" FramePriority="9050"/>
          <ahaIfDefNodeInactive ForePriority="9150" BackPriority="9150" FramePriority="9150"/>
          <ahaIfDefNodeTmpActive  ForePriority="9050" BackPriority="9050" FramePriority="9050"/>
          <ahaModifiedLine Foreground="clGreen" FrameColor="59900"/>
          <ahaRightMargin Foreground="clSilver"/>
          <ahaOverviewGutter Foreground="4210752" Background="6579300" FrameColor="clBlue"/>
          <ahaCodeFoldingTree Foreground="clSilver"/>
          <ahaGutterSeparator Background="clWhite" Foreground="clGray"/>
          <ahaGutter Background="clNavy"/>
          <ahaIdentComplWindowHighlight Foreground="clAqua"/>
          <ahaIdentComplRecent Foreground="clLime"/>
          <ahaIdentComplWindowEntryConst Foreground="clOlive"/>
          <ahaIdentComplWindowEntryFunc Foreground="clTeal"/>
          <ahaIdentComplWindowEntryIdent Foreground="clBlack"/>
          <ahaIdentComplWindowEntryKeyword Foreground="clBlack"/>
          <ahaIdentComplWindowEntryEnum Foreground="clOlive"/>
          <ahaIdentComplWindowEntryLabel Foreground="clOlive"/>
          <ahaIdentComplWindowEntryMethAbstract Foreground="clRed"/>
          <ahaIdentComplWindowEntryMethodLowVis Foreground="clGray"/>
          <ahaIdentComplWindowEntryNameSpace Foreground="clBlack"/>
          <ahaIdentComplWindowEntryProc Foreground="clNavy"/>
          <ahaIdentComplWindowEntryProp Foreground="clPurple"/>
          <ahaIdentComplWindowEntryTempl Foreground="clGray"/>
          <ahaIdentComplWindowEntryText Foreground="clGray"/>
          <ahaIdentComplWindowEntryType Foreground="clLime"/>
          <ahaIdentComplWindowEntryUnit Foreground="clBlack"/>
          <ahaIdentComplWindowEntryUnknown Foreground="clGray"/>
          <ahaIdentComplWindowEntryVar Foreground="clMaroon"/>
          <ahaIdentComplWindow Background="10420276"/>
          <ahaOutlineLevel1Color Foreground="clRed"/>
          <ahaOutlineLevel2Color Foreground="39159"/>
          <ahaOutlineLevel3Color Foreground="2280512"/>
          <ahaOutlineLevel4Color Foreground="13421568"/>
          <ahaOutlineLevel5Color Foreground="16738346"/>
          <ahaOutlineLevel6Color Foreground="13566148"/>
        </SchemePascal_Classic>
      </Globals>
      <LangObjectPascal Version="6">
        <SchemePascal_Classic>
          <Assembler Foreground="clLime"/>
          <Comment Foreground="clSilver"/>
          <Directive Foreground="clSilver"/>
          <Number Foreground="clYellow"/>
          <Modifier Foreground="clWhite"/>
          <Reserved_word Foreground="clWhite"/>
          <String Foreground="clYellow"/>
          <Symbol Foreground="clYellow"/>
          <NestedRoundBracket_1 Foreground="clFuchsia"/>
          <NestedRoundBracket_2 Foreground="2996475"/>
          <NestedRoundBracket_3 Foreground="6814853"/>
        </SchemePascal_Classic>
      </LangObjectPascal>
      <LangLazarus_Form_definition Version="6">
        <SchemePascal_Classic>
          <Comment Foreground="clSilver"/>
          <Key Style="fsBold"/>
          <Number Foreground="clYellow"/>
          <String Foreground="clYellow"/>
          <Symbol Foreground="clYellow"/>
        </SchemePascal_Classic>
      </LangLazarus_Form_definition>
      <LangXML_document Version="6">
        <SchemePascal_Classic>
          <Attribute_Name Foreground="clMaroon"/>
          <Attribute_Value Foreground="clNavy" Style="fsBold"/>
          <CDATA_Section Foreground="clOlive" Style="fsItalic"/>
          <Comment Foreground="clSilver"/>
          <DOCTYPE_Section Foreground="clBlue" Style="fsItalic"/>
          <Element_Name Foreground="clMaroon" Style="fsBold"/>
          <Entity_Reference Foreground="clBlue" Style="fsBold"/>
          <Namespace_Attribute_Name Foreground="clRed"/>
          <Namespace_Attribute_Value Foreground="clRed" Style="fsBold"/>
          <Processing_Instruction Foreground="clBlue"/>
          <Symbol Foreground="clYellow"/>
          <Text Foreground="clBlack" Style="fsBold"/>
        </SchemePascal_Classic>
      </LangXML_document>
      <LangHTML_document Version="6">
        <SchemePascal_Classic>
          <Asp Background="clYellow" Foreground="clBlack"/>
          <Comment Foreground="clSilver"/>
          <Escape_ampersand Foreground="clLime" Style="fsBold"/>
          <Identifier Style="fsBold"/>
          <Reserved_word Foreground="clWhite"/>
          <Symbol Foreground="clYellow"/>
          <Unknown_word Foreground="clRed" Style="fsBold"/>
          <Value Foreground="16744448"/>
        </SchemePascal_Classic>
      </LangHTML_document>
      <LangC__ Version="6">
        <SchemePascal_Classic>
          <Assembler Foreground="clLime"/>
          <Comment Foreground="clSilver"/>
          <Number Foreground="clYellow"/>
          <Preprocessor Foreground="clSilver"/>
          <Reserved_word Foreground="clWhite"/>
          <Space Foreground="clWindow"/>
          <String Foreground="clYellow"/>
          <Symbol Foreground="clYellow"/>
        </SchemePascal_Classic>
      </LangC__>
      <LangPerl Version="6">
        <SchemePascal_Classic>
          <Comment Foreground="clSilver"/>
          <Number Foreground="clYellow"/>
          <Pragma Style="fsBold"/>
          <Reserved_word Foreground="clWhite"/>
          <Space Foreground="clWindow"/>
          <String Foreground="clYellow"/>
          <Symbol Foreground="clYellow"/>
          <Variable Style="fsBold"/>
        </SchemePascal_Classic>
      </LangPerl>
      <LangJava Version="6">
        <SchemePascal_Classic>
          <Comment Foreground="clSilver"/>
          <Documentation Foreground="clSilver"/>
          <Number Foreground="clYellow"/>
          <Reserved_word Foreground="clWhite"/>
          <Space Foreground="clWindow"/>
          <String Foreground="clYellow"/>
          <Symbol Foreground="clYellow"/>
        </SchemePascal_Classic>
      </LangJava>
      <LangUNIX_Shell_Script Version="6">
        <SchemePascal_Classic>
          <Comment Foreground="clSilver"/>
          <Number Foreground="clYellow"/>
          <Reserved_word Foreground="clWhite"/>
          <String Foreground="clYellow"/>
          <Symbol Foreground="clYellow"/>
          <Variable Foreground="clPurple"/>
        </SchemePascal_Classic>
      </LangUNIX_Shell_Script>
      <LangPython Version="6">
        <SchemePascal_Classic>
          <Comment Foreground="clSilver"/>
          <Documentation Foreground="clSilver"/>
          <Float Foreground="clBlue"/>
          <Hexadecimal Foreground="clBlue"/>
          <Non_reserved_keyword Foreground="clNavy" Style="fsBold"/>
          <Number Foreground="clYellow"/>
          <Octal Foreground="clBlue"/>
          <Reserved_word Foreground="clWhite"/>
          <String Foreground="clYellow"/>
          <Symbol Foreground="clYellow"/>
          <SyntaxError Foreground="clRed"/>
          <System_functions_and_variables Style="fsBold"/>
        </SchemePascal_Classic>
      </LangPython>
      <LangPHP Version="6">
        <SchemePascal_Classic>
          <Comment Foreground="clSilver"/>
          <Number Foreground="clYellow"/>
          <Reserved_word Foreground="clWhite"/>
          <String Foreground="clYellow"/>
          <Symbol Foreground="clYellow"/>
        </SchemePascal_Classic>
      </LangPHP>
      <LangSQL Version="6">
        <SchemePascal_Classic>
          <Comment Foreground="clSilver"/>
          <Data_type Style="fsBold"/>
          <Default_packages Style="fsBold"/>
          <Exception Style="fsItalic"/>
          <Function Style="fsBold"/>
          <Number Foreground="clYellow"/>
          <Reserved_word Foreground="clWhite"/>
          <Reserved_word__PL_SQL_ Style="fsBold"/>
          <SQL_Plus_command Style="fsBold"/>
          <String Foreground="clYellow"/>
          <Symbol Foreground="clYellow"/>
        </SchemePascal_Classic>
      </LangSQL>
      <LangJavascript Version="6">
        <SchemePascal_Classic>
          <Comment Foreground="clSilver"/>
          <Number Foreground="clYellow"/>
          <Reserved_word Foreground="clWhite"/>
          <String Foreground="clYellow"/>
          <Symbol Foreground="clYellow"/>
        </SchemePascal_Classic>
      </LangJavascript>
      <LangDiff_File Version="6">
        <SchemePascal_Classic>
          <Diff_Added_line Foreground="clGreen"/>
          <Diff_Changed_Line Foreground="clPurple"/>
          <Diff_Chunk_Line_Counts Foreground="clPurple" Style="fsBold"/>
          <Diff_Chunk_Marker Style="fsBold"/>
          <Diff_Chunk_New_Line_Count Foreground="clGreen" Style="fsBold"/>
          <Diff_Chunk_Original_Line_Count Foreground="clRed" Style="fsBold"/>
          <Diff_New_File Background="clGreen" Style="fsBold"/>
          <Diff_Original_File Background="clRed" Style="fsBold"/>
          <Diff_Removed_Line Foreground="clRed"/>
          <Unknown_word Style="fsItalic"/>
        </SchemePascal_Classic>
      </LangDiff_File>
      <LangMS_DOS_batch_language Version="6">
        <SchemePascal_Classic>
          <Key Style="fsBold"/>
          <Number Foreground="clFuchsia"/>
          <Comment Foreground="clNavy" Style="fsItalic"/>
          <Variable Foreground="clGreen"/>
        </SchemePascal_Classic>
      </LangMS_DOS_batch_language>
      <LangINI_file Version="6">
        <SchemePascal_Classic>
          <Comment Foreground="clGreen" Style="fsItalic"/>
          <Number Foreground="clFuchsia"/>
          <Section Style="fsBold"/>
        </SchemePascal_Classic>
      </LangINI_file>
      <Langpo_language_files Version="8">
        <SchemePascal_Classic>
          <Key Style="fsBold"/>
          <Flags Foreground="clTeal"/>
          <String Foreground="clFuchsia"/>
          <Comment Style="fsItalic" Foreground="clGreen"/>
          <Identifier Style="fsBold" Foreground="clGreen"/>
          <Previous_value Style="fsItalic" Foreground="clOlive"/>
        </SchemePascal_Classic>
      </Langpo_language_files>
    </ColorSchemes>
  </Lazarus>
</CONFIG>
   �5  D   ��
 C O L O R S C H E M E T W I L I G H T       0	        <?xml version="1.0"?>
<CONFIG>
  <Lazarus>
    <ColorSchemes Version="6">
      <Names Count="1">
        <Item1 Value="Twilight"/>
      </Names>
      <Globals Version="6">
        <SchemeTwilight>
          <ahaDefault Background="clBlack" Foreground="clWhite"/>
          <ahaExecutionPoint Background="clBlue" Foreground="clWhite" ForePriority="500" BackPriority="500" FramePriority="500"/>
          <ahaEnabledBreakpoint Background="clRed" Foreground="clWhite" ForePriority="500" BackPriority="500" FramePriority="500"/>
          <ahaDisabledBreakpoint Background="clLime" Foreground="clRed" ForePriority="500" BackPriority="500" FramePriority="500"/>
          <ahaInvalidBreakpoint Background="clOlive" Foreground="clGreen" ForePriority="500" BackPriority="500" FramePriority="500"/>
          <ahaUnknownBreakpoint Background="clRed" Foreground="clBlack" ForePriority="500" BackPriority="500" FramePriority="500"/>
          <ahaErrorLine Background="5284095" Foreground="clBlack" ForePriority="500" BackPriority="500" FramePriority="500"/>
          <ahaLineHighlight ForePriority="500" BackPriority="500" FramePriority="500"/>
          <ahaWordGroup FrameColor="clRed" ForePriority="3000" BackPriority="3000" FramePriority="3000"/>
          <ahaBracketMatch Style="fsBold" ForePriority="3000" BackPriority="3000" FramePriority="3000"/>
          <ahaHighlightWord Background="3158064" FrameColor="clSilver" ForePriority="3000" BackPriority="3000" FramePriority="3000"/>
          <ahaIncrementalSearch Background="3199088" Foreground="clWhite" ForePriority="4000" BackPriority="4000" FramePriority="4000"/>
          <ahaHighlightAll Background="clYellow" ForePriority="4000" BackPriority="4000" FramePriority="4000"/>
          <ahaTemplateEditCur FrameColor="clAqua" ForePriority="6000" BackPriority="6000" FramePriority="6000"/>
          <ahaTemplateEditSync FrameColor="clFuchsia" ForePriority="6000" BackPriority="6000" FramePriority="6000"/>
          <ahaTemplateEditOther FrameColor="clMaroon" ForePriority="6000" BackPriority="6000" FramePriority="6000"/>
          <ahaSyncroEditCur FrameColor="clFuchsia" ForePriority="6000" BackPriority="6000" FramePriority="6000"/>
          <ahaSyncroEditSync FrameColor="clRed" ForePriority="6000" BackPriority="6000" FramePriority="6000"/>
          <ahaSyncroEditOther FrameColor="9744532" ForePriority="6000" BackPriority="6000" FramePriority="6000"/>
          <ahaSyncroEditArea Background="clGray" ForePriority="2000" BackPriority="2000" FramePriority="2000"/>
          <ahaTextBlock Background="clWhite" Foreground="clBlack" ForePriority="7000" BackPriority="7000" FramePriority="7000"/>
          <ahaMouseLink Foreground="clAqua" ForePriority="1500" BackPriority="2500" FramePriority="7500"/>
          <ahaFoldedCode Foreground="clSilver" FrameColor="clSilver" ForePriority="8000" BackPriority="8000" FramePriority="8000"/>
		  <ahaSpecialVisibleChars  ForePriority="8100" BackPriority="8100" FramePriority="8100"/>
          <ahaTopInfoHint Background="clPurple" Foreground="clYellow" FrameColor="clOlive" FrameStyle="slsDashed" ForePriority="8500" BackPriority="8500" FramePriority="8500"/>
          <ahaIfDefBlockInactive Foreground="clBlack" ForeAlpha="150" ForePriority="9050" BackPriority="9050" FramePriority="9050"/>
          <ahaIfDefBlockActive  ForePriority="9000" BackPriority="9000" FramePriority="9000"/>
          <ahaIfDefBlockTmpActive  ForePriority="9000" BackPriority="9000" FramePriority="9000"/>
          <ahaIfDefNodeActive  ForePriority="9050" BackPriority="9050" FramePriority="9050"/>
          <ahaIfDefNodeInactive ForePriority="9150" BackPriority="9150" FramePriority="9150"/>
          <ahaIfDefNodeTmpActive  ForePriority="9050" BackPriority="9050" FramePriority="9050"/>
          <ahaModifiedLine Foreground="clGreen" FrameColor="59900"/>
          <ahaCodeFoldingTree Foreground="clSilver"/>
          <ahaGutterSeparator Background="clWhite" Foreground="clGray"/>
          <ahaGutter Background="clBlack"/>
          <ahaRightMargin Foreground="clSilver"/>
          <ahaOverviewGutter Foreground="4210752" Background="6579300" FrameColor="8947848"/>
          <ahaIdentComplWindow Background="3552822"/>
          <ahaIdentComplRecent Foreground="clLime"/>
          <ahaIdentComplWindowEntryConst Foreground="clOlive"/>
          <ahaIdentComplWindowEntryFunc Foreground="clTeal"/>
          <ahaIdentComplWindowEntryIdent Foreground="clBlack"/>
          <ahaIdentComplWindowEntryKeyword Foreground="clBlack"/>
          <ahaIdentComplWindowEntryEnum Foreground="clOlive"/>
          <ahaIdentComplWindowEntryLabel Foreground="clOlive"/>
          <ahaIdentComplWindowEntryMethAbstract Foreground="clRed"/>
          <ahaIdentComplWindowEntryMethodLowVis Foreground="clGray"/>
          <ahaIdentComplWindowEntryNameSpace Foreground="clBlack"/>
          <ahaIdentComplWindowEntryProc Foreground="clNavy"/>
          <ahaIdentComplWindowEntryProp Foreground="clPurple"/>
          <ahaIdentComplWindowEntryTempl Foreground="clGray"/>
          <ahaIdentComplWindowEntryText Foreground="clGray"/>
          <ahaIdentComplWindowEntryType Foreground="clLime"/>
          <ahaIdentComplWindowEntryUnit Foreground="clBlack"/>
          <ahaIdentComplWindowEntryUnknown Foreground="clGray"/>
          <ahaIdentComplWindowEntryVar Foreground="clMaroon"/>
          <ahaIdentComplWindowBorder Foreground="7039851"/>
          <ahaIdentComplWindowHighlight Foreground="clLime"/>
          <ahaOutlineLevel1Color Foreground="clRed"/>
          <ahaOutlineLevel2Color Foreground="39159"/>
          <ahaOutlineLevel3Color Foreground="2280512"/>
          <ahaOutlineLevel4Color Foreground="13421568"/>
          <ahaOutlineLevel5Color Foreground="16738346"/>
          <ahaOutlineLevel6Color Foreground="13566148"/>
        </SchemeTwilight>
      </Globals>
      <LangObjectPascal Version="6">
        <SchemeTwilight>
          <Assembler Foreground="clLime"/>
          <Comment Foreground="clGray"/>
          <Directive Foreground="clRed"/>
          <Number Foreground="clFuchsia"/>
          <Modifier Foreground="clAqua" Style="fsBold"/>
          <Reserved_word Foreground="clAqua" Style="fsBold"/>
          <String Foreground="clYellow"/>
          <Symbol Foreground="clAqua"/>
          <NestedRoundBracket_1 Foreground="clFuchsia"/>
          <NestedRoundBracket_2 Foreground="2996475"/>
          <NestedRoundBracket_3 Foreground="6814853"/>
        </SchemeTwilight>
      </LangObjectPascal>
      <LangLazarus_Form_definition Version="6">
        <SchemeTwilight>
          <Comment Foreground="clGray"/>
          <Key Style="fsBold"/>
          <Number Foreground="clFuchsia"/>
          <String Foreground="clYellow"/>
          <Symbol Foreground="clAqua"/>
        </SchemeTwilight>
      </LangLazarus_Form_definition>
      <LangXML_document Version="6">
        <SchemeTwilight>
          <Attribute_Name Foreground="clMaroon"/>
          <Attribute_Value Foreground="clNavy" Style="fsBold"/>
          <CDATA_Section Foreground="clOlive" Style="fsItalic"/>
          <Comment Foreground="clGray"/>
          <DOCTYPE_Section Foreground="clBlue" Style="fsItalic"/>
          <Element_Name Foreground="clMaroon" Style="fsBold"/>
          <Entity_Reference Foreground="clBlue" Style="fsBold"/>
          <Namespace_Attribute_Name Foreground="clRed"/>
          <Namespace_Attribute_Value Foreground="clRed" Style="fsBold"/>
          <Processing_Instruction Foreground="clBlue"/>
          <Symbol Foreground="clAqua"/>
          <Text Foreground="clBlack" Style="fsBold"/>
        </SchemeTwilight>
      </LangXML_document>
      <LangHTML_document Version="6">
        <SchemeTwilight>
          <Asp Background="clYellow" Foreground="clBlack"/>
          <Comment Foreground="clGray"/>
          <Escape_ampersand Foreground="clLime" Style="fsBold"/>
          <Identifier Style="fsBold"/>
          <Reserved_word Foreground="clAqua" Style="fsBold"/>
          <Symbol Foreground="clAqua"/>
          <Unknown_word Foreground="clRed" Style="fsBold"/>
          <Value Foreground="16744448"/>
        </SchemeTwilight>
      </LangHTML_document>
      <LangC__ Version="6">
        <SchemeTwilight>
          <Assembler Foreground="clLime"/>
          <Comment Foreground="clGray"/>
          <Number Foreground="clFuchsia"/>
          <Preprocessor Foreground="clGray"/>
          <Reserved_word Foreground="clAqua" Style="fsBold"/>
          <Space Foreground="clWindow"/>
          <String Foreground="clYellow"/>
          <Symbol Foreground="clAqua"/>
        </SchemeTwilight>
      </LangC__>
      <LangPerl Version="6">
        <SchemeTwilight>
          <Comment Foreground="clGray"/>
          <Number Foreground="clFuchsia"/>
          <Pragma Style="fsBold"/>
          <Reserved_word Foreground="clAqua" Style="fsBold"/>
          <Space Foreground="clWindow"/>
          <String Foreground="clYellow"/>
          <Symbol Foreground="clAqua"/>
          <Variable Style="fsBold"/>
        </SchemeTwilight>
      </LangPerl>
      <LangJava Version="6">
        <SchemeTwilight>
          <Comment Foreground="clGray"/>
          <Documentation Foreground="clGray"/>
          <Number Foreground="clFuchsia"/>
          <Reserved_word Foreground="clAqua" Style="fsBold"/>
          <Space Foreground="clWindow"/>
          <String Foreground="clYellow"/>
          <Symbol Foreground="clAqua"/>
        </SchemeTwilight>
      </LangJava>
      <LangUNIX_Shell_Script Version="6">
        <SchemeTwilight>
          <Comment Foreground="clGray"/>
          <Number Foreground="clFuchsia"/>
          <Reserved_word Foreground="clAqua" Style="fsBold"/>
          <String Foreground="clYellow"/>
          <Symbol Foreground="clAqua"/>
          <Variable Foreground="clPurple"/>
        </SchemeTwilight>
      </LangUNIX_Shell_Script>
      <LangPython Version="6">
        <SchemeTwilight>
          <Comment Foreground="clGray"/>
          <Documentation Foreground="clGray"/>
          <Float Foreground="clBlue"/>
          <Hexadecimal Foreground="clBlue"/>
          <Non_reserved_keyword Foreground="clNavy" Style="fsBold"/>
          <Number Foreground="clFuchsia"/>
          <Octal Foreground="clBlue"/>
          <Reserved_word Foreground="clAqua" Style="fsBold"/>
          <String Foreground="clYellow"/>
          <Symbol Foreground="clAqua"/>
          <SyntaxError Foreground="clRed"/>
          <System_functions_and_variables Style="fsBold"/>
        </SchemeTwilight>
      </LangPython>
      <LangPHP Version="6">
        <SchemeTwilight>
          <Comment Foreground="clGray"/>
          <Number Foreground="clFuchsia"/>
          <Reserved_word Foreground="clAqua" Style="fsBold"/>
          <String Foreground="clYellow"/>
          <Symbol Foreground="clAqua"/>
        </SchemeTwilight>
      </LangPHP>
      <LangSQL Version="6">
        <SchemeTwilight>
          <Comment Foreground="clGray"/>
          <Data_type Style="fsBold"/>
          <Default_packages Style="fsBold"/>
          <Exception Style="fsItalic"/>
          <Function Style="fsBold"/>
          <Number Foreground="clFuchsia"/>
          <Reserved_word Foreground="clAqua" Style="fsBold"/>
          <Reserved_word__PL_SQL_ Style="fsBold"/>
          <SQL_Plus_command Style="fsBold"/>
          <String Foreground="clYellow"/>
          <Symbol Foreground="clAqua"/>
        </SchemeTwilight>
      </LangSQL>
      <LangJavascript Version="6">
        <SchemeTwilight>
          <Comment Foreground="clGray"/>
          <Number Foreground="clFuchsia"/>
          <Reserved_word Foreground="clAqua" Style="fsBold"/>
          <String Foreground="clYellow"/>
          <Symbol Foreground="clAqua"/>
        </SchemeTwilight>
      </LangJavascript>
      <LangDiff_File Version="6">
        <SchemeTwilight>
          <Diff_Added_line Foreground="clGreen"/>
          <Diff_Changed_Line Foreground="clPurple"/>
          <Diff_Chunk_Line_Counts Foreground="clPurple" Style="fsBold"/>
          <Diff_Chunk_Marker Style="fsBold"/>
          <Diff_Chunk_New_Line_Count Foreground="clGreen" Style="fsBold"/>
          <Diff_Chunk_Original_Line_Count Foreground="clRed" Style="fsBold"/>
          <Diff_New_File Background="clGreen" Style="fsBold"/>
          <Diff_Original_File Background="clRed" Style="fsBold"/>
          <Diff_Removed_Line Foreground="clRed"/>
          <Unknown_word Style="fsItalic"/>
        </SchemeTwilight>
      </LangDiff_File>
      <LangMS_DOS_batch_language Version="6">
        <SchemeTwilight>
          <Key Style="fsBold"/>
          <Number Foreground="clFuchsia"/>
          <Comment Foreground="clNavy" Style="fsItalic"/>
          <Variable Foreground="clGreen"/>
        </SchemeTwilight>
      </LangMS_DOS_batch_language>
      <LangINI_file Version="6">
        <SchemeTwilight>
          <Comment Foreground="clGreen" Style="fsItalic"/>
          <Section Style="fsBold"/>
          <Number Foreground="clFuchsia"/>
        </SchemeTwilight>
      </LangINI_file>
      <Langpo_language_files Version="8">
        <SchemeTwilight>
          <Key Style="fsBold"/>
          <Flags Foreground="clTeal"/>
          <String Foreground="clFuchsia"/>
          <Comment Style="fsItalic" Foreground="clGreen"/>
          <Identifier Style="fsBold" Foreground="clGreen"/>
          <Previous_value Style="fsItalic" Foreground="clOlive"/>
        </SchemeTwilight>
      </Langpo_language_files>
    </ColorSchemes>
  </Lazarus>
</CONFIG>
  