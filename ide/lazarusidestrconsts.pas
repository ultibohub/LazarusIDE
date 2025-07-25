{
 /***************************************************************************
                          lazarusidestrconsts.pas
                          -----------------------
              This unit contains all resource strings of the IDE


 ***************************************************************************/

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
}
{
  Note: All resource strings should be prefixed with 'lis' (Lazarus IDE String)

}
unit LazarusIDEStrConsts;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils;

resourcestring
  // *** Common single word resources that can be safely shared around Lazarus ***

  lisApply = 'Apply';
  lisBtnApply = '&Apply';
  lisInsert = 'Insert';
  lisChange  = 'Change';
  lisRemove = 'Remove';
  lisBtnRemove = '&Remove';
  lisRename = 'Rename';
  lisBtnRename = '&Rename';
  lisRename2 = 'Rename ...';
  lisReplace = 'Replace';
  lisBtnReplace = '&Replace';
  lisBtnDlgReplace = '&Replace ...';
  lisEdit = 'Edit';
  lisDlgEdit = 'Edit ...';
  lisClear = 'Clear';
  lisOpen = 'Open';
  lisSave = 'Save';
  lisSaveAll = 'Save All';
  lisFile = 'File';
  lisNew = 'New';
  lisClose = 'Close';
  lisBtnClose = '&Close';
  lisExit = 'Exit';
  lisQuit = 'Quit';
  lisBtnQuit = '&Quit';
  lisRestart = 'Restart';
  lisUndo = 'Undo';
  lisRedo = 'Redo';
  lisDown = 'Down';
  lisUp   = 'Up';
  lisRight = 'Right';
  lisLeft = 'Left';
  lisTop = 'Top';
  lisBottom = 'Bottom';
  lisName = 'Name';
  lisKey = 'Key';
  lisValue = 'Value';
  lisVariable = 'Variable';
  lisPath = 'Path';
  lisId = 'ID';
  lisPage = 'Page';
  lisPackage = 'Package';
  lisCompile = 'Compile';
  lisCompileStage = 'Compile';
  lisBuild = '&Build';
  lisBuildCaption = 'Build';
  lisBuildStage = 'Build';
  lisRun = 'Run';
  lisRunStage = 'Run';
  lisPause = 'Pause';
  lisStop = 'Stop';
  lisContents = 'Contents';
  lisSorting = 'Sorting';
  lisAppearance = 'Appearance';
  lisBuilding = 'Building';
  lisOptions = 'Options';
  lisLess = 'Less';
  lisMore = 'More';
  lisMoreSub = 'More';
  lisDlgMore = 'More ...';
  lisDefault = 'Default';
  lisClone = 'Clone';
  lisExport = 'Export';
  lisDlgExport = 'Export ...';
  lisExportSub = 'Export >>';
  lisImport = 'Import';
  lisDlgImport = 'Import ...';
  lisSuccess = 'Success';
  lisAborted = 'Aborted';

  // *** Common sentence resources that can be safely shared around Lazarus ***
  //  Be careful, sharing sentences can lead to wrong translations in some places.

  lisExportHtml = 'Export as HTML';
  lisMoveFiles = 'Move Files';
  lisMoveFiles2 = 'Move files?';
  lrsPLDDeleteSelected = 'Delete selected';
  lisMoveUp = 'Move Up';
  lisMoveDown = 'Move Down';

  // *** Rest of the resource strings ***

  lisImportPackageListXml = 'Import package list';
  lisExportPackageListXml = 'Export package list';
  lrsRescanLplFiles = 'Rescan lpl files';
  lisRenameShowResult = 'Show list of renamed Identifiers';
  lisResourceNameMustBeUnique = 'Resource name must be unique.';
  lisFailedToAddNNotUniqueResources = 'Failed to add %d not unique resource(s)';
  lisTheIDEIsStillBuilding = 'The IDE is still building.';

  lisSaveShownMessagesToFile = 'Save Shown Messages to File ...';
  lisMMAddsCustomOptions = 'Adds custom options:';
  lisMMDoesNotAddCustomOptions = 'Does not add custom options:';
  lisUnusedUnitsOf = 'Unused units of %s';
  lisSaveAllOriginalMessagesToFile = 'Save All/Original Messages to File ...';

  // errors
  lisErrInvalidOption = 'Invalid option at position %d: "%s"';
  lisErrNoOptionAllowed = 'Option at position %d does not allow an argument: %s';
  lisErrOptionNeeded = 'Option at position %d needs an argument : %s';

  // command line help
  lisThisHelpMessage = 'This help message.';
  lisPrimaryConfigDirectoryWhereLazarusStoresItsConfig = 'Primary config '+
    'directory where Lazarus stores its config files. Default is "%s".';
  lisLazarusOptionsProjectFilename = 'lazarus [options] <project-filename>';
  lisIDEOptions = 'IDE Options:';
  lisCmdLineLCLInterfaceSpecificOptions = 'LCL Interface specific options:';
  lisDoNotShowSplashScreen = 'Do not show splash screen.';
  lisSkipLoadingLastProject = 'Skip loading last project.';
  lisDoNotCheckIfAnotherIDEInstanceIsAlreadyRunning = 'Do not check if '
    +'another IDE instance is already running.';
  lisOverrideLanguage = 'Override language. '+
    'For possible values see files in the "languages" directory. Example: "--language=de".';
  lisSecondaryConfigDirectoryWhereLazarusSearchesFor = 'Secondary config '+
    'directory where Lazarus searches for config template files. Default is "%s".';
  lisFileWhereDebugOutputIsWritten =
    'File where debug output is written to. Default is write to the console.';
  lisDebugLogCloseOptDescr =
    'Close log file between writes. Prevents loss of unsaved data when the IDE crashes. '+
    'By default, writes are buffered by the OS for performance.';
  lisSkipStartupChecks = 'Skip selected checks at startup. Valid options are:';
  lisGroupsForDebugOutput = 'Enable or disable groups of debug output. ' +
    'Valid options are:';
  lisLazarusDirOverride = 'Directory to be used as a basedirectory.';

  lisMaximumNumberOfThreadsForCompilingInParallelDefaul = 'Maximum number of '
    +'threads for compiling in parallel. Default is 0 which guesses the '
    +'number of cores in the system.';
  lisDoNotWriteUpdatedProjectInfoAfterBuild = 'Do not write updated project '+
    'info file after build. If not specified, build number will be incremented '+
    'if configured.';

  lisExtraOpts = 'Pass additional options to the compiler. Can be given '+
    'multiple times. If compilation options are also specified in --build-ide, '+
    'then the options from --opt will be added after them.';
  lisGetExpandText = 'Print the result of substituting macros in the text. '+
    'The absence of macros means the name of the macro. '+
    'In case of an error, returns only the text with partially expanded macros '+
    'and sets the error code (also for an empty string). '+
    'Takes into account the active (or specified via --bm option) build mode.';
  lisGetBuildModes = 'Print a list of build modes in the project. Active mode is listed first.';

  lisLazbuildOptionsSyntax = 'lazbuild [options] <project/package filename or package name>';

  // component palette
  lisSelectionTool = 'Selection tool';
  lisClickToSelectPalettePage = 'Click to Select Palette Page';
  lisTotalPages = 'Total Pages: %s';
  lisKeepOpen = 'Keep open';
  
  // macros
  lisCursorColumnInCurrentEditor = 'Cursor column in current editor';
  lisCursorRowInCUrrentEditor = 'Cursor row in current editor';
  lisCompilerFilename = 'Compiler filename';
  lisShortFormOfTargetCPUParamTargetOSParamSubTargetPar = 'Short form of $'
    +'TargetCPU(Param)-$TargetOS(Param)-$SubTarget(Param). Subtarget is '
    +'omitted if empty.';
  lisWordAtCursorInCurrentEditor = 'Word at cursor in current editor';
  lisExpandedFilenameOfCurrentEditor = 'Expanded filename of current editor file';
  lisFreePascalSourceDirectory = 'Free Pascal source directory';
  lisLazarusDirectory = 'Lazarus directory';
  lisLazarusLanguageID = 'Lazarus language ID (e.g. en, de, br, fi)';
  lisLazarusLanguageName = 'Lazarus language name (e.g. english, deutsch)';
  lisLCLWidgetType = 'LCL &widget type';
  lisTargetCPU = 'Target CPU';
  lisTargetOS = 'Target OS';
  lisSubtarget = 'Subtarget';
  lisSrcOS = 'Src OS';
  lisCommandLineParamsOfProgram = 'Command line parameters of program';
  lisPromptForValue = 'Prompt for value';
  lisProjectFilename = 'Project filename';
  lisProjectDirectory = 'Project directory';
  lisSaveCurrentEditorFile = 'Save current editor file';
  lisSaveAllModified = 'Save all modified files';
  lisTargetFilenameOfProject = 'Target filename of project';
  lisTargetFilenamePlusParams = 'Target filename + params';
  lisOutputFilenameOfProject = 'Output filename of project';
  lisTestDirectory = 'Test directory';
  lisLaunchingCmdLine = 'Launching target command line';
  lisPublishProjDir = 'Publish project directory';
  lisProjectUnitPath = 'Project Unit Path';
  lisProjectNamespaces = 'Project Namespaces';
  lisProjectIncPath = 'Project Include Path';
  lisProjectSrcPath = 'Project Src Path';
  lisProjectOutDir = 'Project Output directory (e.g. the ppu directory)';
  lisProjectVer = 'Project version';
  lisEnvironmentVariableNameAsParameter = 'Environment variable, name as parameter';
  lisUserSHomeDirectory = 'User''s home directory';
  lisMakeExe = 'Make Executable';
  lisPathOfTheMakeUtility = 'Path of the make utility';
  lisProjectMacroProperties = 'Project macro properties';
  lisOpenProject2 = 'Open project';
  lisKMOpenRecentProject = 'Open recent project';
  lisFileHasNoProject = 'File has no project';
  lisTheFileIsNotALazarusProjectCreateANewProjectForThi =
     'The file "%s" is not a Lazarus project.'
    +'%sCreate a new project for this "%s"?';
  lisCreateProject = 'Create project';
  lisKMSaveProject = 'Save project';
  lisKMCloseProject = 'Close project';
  lisKMSaveProjectAs = 'Save project as';
  lisKMPublishProject = 'Publish project';
  lisOpenTheFileAsNormalSource = 'Open the file as normal source';
  lisOpenAsXmlFile = 'Open as XML file';
  lisAnErrorOccurredAtLastStartupWhileLoadingLoadThisPro = 'An error occurred '
    +'at last startup while loading %s!'
    +'%sLoad this project again?';
  lisOpenProjectAgain = 'Open project again';
  lisStartWithANewProject = 'Start with a new project';
  lisConfigDirectory = 'Lazarus config directory';

  // main bar menu
  lisMenuFile = '&File';
  lisMenuEdit = '&Edit';
  lisMenuSearch = '&Search';
  lisMenuSource = 'S&ource';
  lisMenuView = '&View';
  lisMenuProject = '&Project';
  lisMenuRun = '&Run';
  lisMenuPackage = 'Pa&ckage';
  lisMenuTools = '&Tools';
  lisMenuWindow = '&Window';
  lisMenuHelp = '&Help';
  lisThisWillAllowChangingAllBuildModesAtOnceNotImpleme = 'This will allow '
    +'changing all build modes at once. Not implemented yet.';
  
  lisMenuNewUnit = 'New Unit';
  lisMenuNewCustom = 'New %s';
  lisMenuNewForm = 'New Form';
  lisMenuNewOther = 'New ...';
  lisMenuOpen = '&Open ...';
  lisMenuOpenUnit = 'Open Unit ...';
  lisMenuRevert = 'Revert';
  lisMenuRevertConfirm = 'Discard all unsaved changes in' + LineEnding + '"%s"?' + LineEnding + LineEnding + 'This action cannot be undone and will affect all editor tabs with the file.';
  lisPESavePackageAs = 'Save Package As ...';
  lisPkgEditPublishPackage = 'Publish Package';
  lisPERevertPackage = 'Revert Package';
  lisMenuOpenRecent = 'Open &Recent';
  lisMenuSave = '&Save';
  lisMenuSaveAs = 'Save &As ...';
  lisKMSaveAs = 'Save As';
  lisKMSaveAll = 'Save All';
  lisDiscardChanges = 'Discard changes';
  lisDiscardChangesAll = 'Discard all changes';
  lisDoNotCloseTheProject = 'Do not close the project';
  lisErrorSavingForm = 'Error saving form';
  lisCannotSaveForm = 'Cannot save form "%s".';
  lisErrorOpeningForm = 'Error opening form';
  lisCannotOpenForm = 'Cannot open form "%s".';
  lisConvert = 'Convert';
  lisPLDShowGlobalLinksIn = 'Show global links in ';
  lisPLDShowOnlineLinks = 'Show online links';
  lisPLDShowUserLinksIn = 'Show user links in ';
  lrsPLDLpkFileValid = 'lpk file valid (%s)';
  lrsPLDLpkFileInvalid = 'lpk file invalid (%s)';
  lisCTDefDefineTemplates = 'Define templates';
  lisMenuCloseEditorFile = '&Close Editor File';
  lisMenuCleanDirectory = 'Clean Directory ...';

  lisMenuIndentSelection = 'Indent Selection';
  lisMenuUnindentSelection = 'Unindent Selection';
  lisMenuUpperCaseSelection = 'Uppercase Selection';
  lisMenuLowerCaseSelection = 'Lowercase Selection';
  lisMenuSwapCaseSelection = 'Swap Case in Selection';
  lisMenuTabsToSpacesSelection = 'Tabs to Spaces in Selection';
  lisKMEncloseSelection   = 'Enclose Selection';
  lisMenuEncloseSelection = 'Enclose Selection ...';
  lisEncloseInIFDEF     = 'Enclose in $IFDEF';
  lisMenuEncloseInIFDEF = 'Enclose in $IFDEF ...';
  lisMenuCommentSelection = 'Comment Selection';
  lisMenuUncommentSelection = 'Uncomment Selection';
  lisMenuToggleComment = 'Toggle Comment in Selection';
  lisMenuSortSelection = 'Sort Selection ...';
  lisMenuBeakLinesInSelection = 'Break Lines in Selection';
  lisMenuPasteFromClipboard = 'Paste from clipboard';
  lisMenuSelect = 'Select';
  lisMenuMultiPaste = 'MultiPaste ...';
  lisMenuSelectAll = 'Select All';
  lisCheckAll = 'Check All';
  lisUncheckAll = 'Uncheck All';
  dlgFiles = '%s files';
  lisSAMAbstractMethodsNotYetOverridden = 'Abstract Methods - not yet overridden';
  lisMenuSelectToBrace = 'Select to Brace';
  lisMenuSelectCodeBlock = 'Select Code Block';
  lisMenuSelectWord = 'Select Word';
  lisMenuSelectLine = 'Select Line';
  lisMenuSelectParagraph = 'Select Paragraph';
  lisMenuInsertCharacter = 'Insert from Character Map ...';
  lisMenuInsertCVSKeyword = 'Insert CVS Keyword';
  lisMenuInsertGeneral = 'Insert General';
  lisGeneral = 'General';
  lisUnitPaths = 'Unit paths';
  lisIncludePaths = 'Include paths';
  lisSourcePaths = 'Source paths';

  lisMenuInsertGPLNotice = 'GPL Notice';
  lisMenuInsertGPLNoticeTranslated = 'GPL Notice (translated)';
  lisMenuInsertLGPLNotice = 'LGPL Notice';
  lisMenuInsertLGPLNoticeTranslated = 'LGPL Notice (translated)';
  lisMenuInsertModifiedLGPLNotice = 'Modified LGPL Notice';
  lisMenuInsertModifiedLGPLNoticeTranslated = 'Modified LGPL Notice (translated)';
  lisMenuInsertMITNotice = 'MIT Notice';
  lisMenuInsertMITNoticeTranslated = 'MIT Notice (translated)';
  lisMenuInsertUserName = 'Current Username';
  lisMenuInsertDateTime = 'Current Date and Time';
  lisMenuInsertChangeLogEntry = 'ChangeLog Entry';

  lisMenuFind = 'Find';
  lisExpand = 'Expand';
  lisExpandAll2 = 'Expand All';
  lisCollapse = 'Collapse';
  lisCollapseAll2 = 'Collapse All';
  lisBtnFind = '&Find';
  lisMenuFindNext = 'Find &Next';
  lisMenuFind2 = '&Find ...';
  lisMenuFindPrevious = 'Find &Previous';
  lisMenuFindInFiles = 'Find &in Files ...';
  lisMenuIncrementalFind = 'Incremental Find';
  lisMenuGotoLine = 'Goto Line ...';
  lisMenuJumpBack = 'Jump Back';
  lisMenuJumpForward = 'Jump Forward';
  lisMenuAddJumpPointToHistory = 'Add Jump Point to History';
  lisMenuViewJumpHistory = 'Jump History';
  lisMenuMacroListView = 'Editor Macros';
  lisMenuFindBlockOtherEndOfCodeBlock = 'Find Other End of Code Block';
  lisMenuFindCodeBlockStart = 'Find Start of Code Block';
  lisMenuFindDeclarationAtCursor = 'Find Declaration at Cursor';
  lisMenuOpenFilenameAtCursor = 'Open Filename at Cursor';
  lisMenuGotoIncludeDirective = 'Goto Include Directive';
  lisMenuJumpToNextError = 'Jump to Next Error';
  lisMenuJumpToPrevError = 'Jump to Previous Error';
  lisMenuSetFreeBookmark = 'Set a Free Bookmark';
  lisMenuJumpToNextBookmark = 'Jump to Next Bookmark';
  lisMenuJumpToPrevBookmark = 'Jump to Previous Bookmark';
  lisMenuProcedureList = 'Procedure List ...';
  lisMenuOpenFolder = 'Open Folder ...';

  lisMenuViewObjectInspector = 'Object Inspector';
  lisMenuViewSourceEditor = 'Source Editor';
  lisMenuViewCodeExplorer = 'Code Explorer';
  lisMenuViewCodeBrowser = 'Code Browser';
  lisMenuViewRestrictionBrowser = 'Restriction Browser';
  lisMenuViewComponents = '&Components';
  lisMenuJumpTo = 'Jump to';
  lisMenuJumpToInterface = 'Jump to Interface';
  lisMenuJumpToInterfaceUses = 'Jump to Interface uses';
  lisMenuJumpToImplementation = 'Jump to Implementation';
  lisMenuJumpToImplementationUses = 'Jump to Implementation uses';
  lisMenuJumpToInitialization = 'Jump to Initialization';
  lisMenuJumpToProcedureHeader = 'Jump to Procedure header';
  lisMenuJumpToProcedureBegin = 'Jump to Procedure begin';
  lisMenuViewUnits = 'Units ...';
  lisMenuViewForms = 'Forms ...';
  lisMenuViewUnitDependencies = 'Unit Dependencies';
  lisKMViewUnitInfo = 'View Unit Info';
  lisMenuViewUnitInfo = 'Unit Information ...';
  lisMenuViewToggleFormUnit = 'Toggle Form/Unit View';
  lisMenuViewMessages = 'Messages';
  lisProjectOption = 'Project Option';
  lisPackageOption = 'Package "%s" Option';
  lisAbout2 = 'About %s';
  lisCopySelectedMessagesToClipboard = 'Copy Selected Messages to Clipboard';
  lisCopyFileNameToClipboard = 'Copy File Name to Clipboard';
  lisFind = 'Find ...';
  lisAbout = 'About';
  lisRemoveCompilerOptionHideMessage = 'Remove Compiler Option Hide Message';
  lisRemoveMessageTypeFilter = 'Remove Message Type Filter';
  lisRemoveAllMessageTypeFilters = 'Remove all message type filters';
  lisFilterNonUrgentMessages = 'Filter non urgent Messages';
  lisFilterWarningsAndBelow = 'Filter Warnings and below';
  lisFilterNotesAndBelow = 'Filter Notes and below';
  lisFilterHintsAndBelow = 'Filter Hints and below';
  lisFilterVerboseMessagesAndBelow = 'Filter Verbose Messages and below';
  lisFilterDebugMessagesAndBelow = 'Filter Debug Messages and below';
  lisFilterNoneDoNotFilterByUrgency = 'Filter None, do not filter by urgency';
  lisFilterHintsWithoutSourcePosition = 'Filter Hints without Source Position';
  lisSwitchFilterSettings = 'Switch Filter Settings';
  lisAddFilter = 'Add Filter ...';
  lisCopyAllShownMessagesToClipboard = 'Copy All Shown Messages to Clipboard';
  lisCopyAllOriginalMessagesToClipboard = 'Copy All/Original Messages to Clipboard';
  lisCopyItemToClipboard = 'Copy Item to Clipboard';
  lisCopySelectedItemToClipboard = 'Copy Selected Items to Clipboard';
  lisCopyAllItemsToClipboard = 'Copy All Items to Clipboard';
  lisExpandAll = 'Expand All [Ctrl+Plus]';
  lisCollapseAll = 'Collapse All [Ctrl+Minus]';
  lisEditHelp = 'Edit help';
  lisMenuViewSearchResults = 'Search Results';
  lisMenuViewAnchorEditor = 'Anchor Editor';
  lisMenuViewTabOrder = 'Tab Order';
  lisKMToggleViewComponentPalette = 'Toggle View Component Palette';
  lisMenuViewComponentPalette = 'Component Palette';
  lisMenuDebugWindows = 'Debug Windows';
  lisMenuViewWatches = 'Watches';
  lisMenuViewLocalVariables = 'Local Variables';
  lisMenuViewPseudoTerminal = 'Console In/Output';
  lisMenuViewRegisters = 'Registers';
  lisMenuViewThreads = 'Threads';
  lisMenuViewHistory = 'History';
  lisMenuViewDebugOutput = 'Debug Output';
  lisMenuViewDebugEvents = 'Event Log';
  lisMenuIDEInternals = 'IDE Internals';
  lisMenuPackageLinks = 'Package Links ...';
  lisMenuAboutFPC = 'About FPC';
  lisAboutIDE = 'About IDE';
  lisMenuWhatNeedsBuilding = 'What Needs Building';

  lisMenuNewProject = 'New Project ...';
  lisMenuNewProjectFromFile = 'New Project from File ...';
  lisMenuOpenProject = 'Open Project ...';
  lisMenuCloseProject = 'Close Project';
  lisMenuOpenRecentProject = 'Open Recent Project';
  lisMenuSaveProject = 'Save Project';
  lisMenuSaveProjectAs = 'Save Project As ...';
  lisMenuResaveFormsWithI18n = 'Resave forms with enabled i18n';
  lisMenuPublishProject = 'Publish Project ...';
  lisPublishProject = 'Publish Project';
  lisMenuProjectInspector = 'Project Inspector';
  lisProject3 = 'project';
  lisKMRemoveActiveFileFromProject = 'Remove Active File from Project';
  lisKMViewProjectSource = 'View Project Source';
  lisMenuAddToProject = 'Add Editor File to Project';
  lisMenuRemoveFromProject = 'Remove from Project ...';
  lisMenuRenameLowerCase = 'Rename Unit Files to LowerCase ...';
  lisMenuViewProjectSource = '&View Project Source';
  lisMenuProjectOptions = 'Project Options ...';

  lisBFWorkingDirectoryLeaveEmptyForFilePath = 'Working directory (leave empty for file path)';
  lisShowOutput = 'Show output';
  lisBFBuildCommand = 'Build Command';
  lisMenuQuickCompile = 'Quick Compile';
  lisMenuCleanUpAndBuild = 'Clean up and Build ...';
  lisMenuCompileManyModes = 'Compile many Modes ...';
  lisMenuAbortBuild = 'Abort Build';
  lisMenuProjectRun = '&Run';
  lisBFAlwaysBuildBeforeRun = 'Always build before run';

  lisBFRunCommand = 'Run Command';
  lisMenuShowExecutionPoint = 'S&how Execution Point';
  lisMenuRunToCursor = 'Run to Cursor';
  lisKMStopProgram = 'Stop Program';
  lisContinueAndDoNotAskAgain = 'Continue and do not ask again';
  lisSuspiciousUnitPath = 'Suspicious unit path';
  lisThePackageAddsThePathToTheUnitPathOfTheIDEThisIsPr = 'The package %s '
    +'adds the path "%s" to the unit path of the IDE.'
    +'%sThis is probably a misconfiguration of the package.';
  lisMenuResetDebugger = 'Reset Debugger';
  lisMenuRunParameters = 'Run &Parameters ...';
  lisMenuBuildFile = 'Build File';
  lisMenuRunWithoutDebugging = 'Run without Debugging';
  lisMenuRunWithDebugging = 'Run with Debugging';
  lisMenuRunFile = 'Run File';
  lisKMConfigBuildFile = 'Config "Build File"';
  lisKMInspect = 'Inspect';
  lisKMEvaluateModify = 'Evaluate/Modify';
  lisKMAddWatch = 'Add watch';
  lisKMAddBpSource = 'Add Source Breakpoint';
  lisKMAddBpAddress = 'Add Address Breakpoint';
  lisKMAddBpWatchPoint = 'Add Data/WatchPoint';
  lisMenuConfigBuildFile = 'Configure Build+Run File ...';
  lisMenuInspect = '&Inspect ...';
  lisMenuEvaluate = 'E&valuate/Modify ...';
  lisMenuAddWatch = 'Add &Watch ...';
  lisMenuAddBreakpoint = 'Add &Breakpoint';

  lisMenuNewPackage = 'New Package ...';
  lisMenuOpenPackage = 'Open Loaded Package ...';
  lisMenuOpenRecentPkg = 'Open Recent Package';
  lisMenuOpenPackageFile = 'Open Package File (.lpk) ...';
  lisMenuOpenPackageOfCurUnit = 'Open Package of Current Unit';
  lisMenuAddCurFileToPkg = 'Add Active File to Package ...';
  lisKMConfigureCustomComponents = 'Configure Custom Components';
  lisMenuConfigCustomComps = 'Configure Custom Components ...';

  lisMenuConfigExternalTools = 'Configure External Tools ...';
  lisMenuQuickSyntaxCheck = 'Quick Syntax Check';
  lisMenuQuickSyntaxCheckOk = 'Quick syntax check OK';
  lisMenuGuessUnclosedBlock = 'Guess Unclosed Block';
  lisMenuGuessMisplacedIFDEF = 'Guess Misplaced IFDEF/ENDIF';
  lisMenuMakeResourceString = 'Make Resource String ...';
  lisCaptionCompareFiles = 'Compare files (not for creating patches)';
  lisMenuCompareFiles = 'Compare files ...';
  lisMenuConvertDFMtoLFM = 'Convert Binary DFM to LFM ...';
  lisMenuCheckLFM = 'Check LFM File in Editor';
  lisMenuDelphiConversion = 'Delphi Conversion';
  lisMenuConvertDelphiUnit = 'Convert Delphi Unit to Lazarus Unit ...';
  lisMenuConvertDelphiProject = 'Convert Delphi Project to Lazarus Project ...';
  lisMenuConvertDelphiPackage = 'Convert Delphi Package to Lazarus Package ...';
  lisMenuConvertEncoding = 'Convert Encoding of Projects/Packages ...';
  lisConvertEncodingOfProjectsPackages = 'Convert encoding of projects/packages';
  lisMenuBuildLazarus = 'Build Lazarus with Current Profile';
  lisMenuBuildLazarusProf = 'Build Lazarus with Profile: %s';
  lisMenuConfigureBuildLazarus = 'Configure "Build Lazarus" ...';
  lisManageSourceEditors = 'Manage Source Editors ...';
  lisSourceEditorWindowManager = 'Source Editor Window Manager';
  lisMEOther = 'Other tabs';
  lisTabsFor = 'Tabs for %s';
  lisRecentTabs = 'Recent tabs';
  lisMenuGeneralOptions = 'Options ...';
  lisMacPreferences = 'Preferences...'; // used only for macOS, instead of lisMenuGeneralOptions
                                        // there should not be space between Preferences and ellipsis
  lisWindowStaysOnTop = 'Window stays on top';
  lisFilenameStyle = 'Filename Style';
  lisShortNoPath = 'Short, no path';
  lisRelative = 'Relative';
  lisFull = 'Full';
  lisTranslateTheEnglishMessages = 'Translate the English Messages';
  lisShowMessageTypeID = 'Show Message Type ID';
  lisToolStoppedWithExitCodeUseContextMenuToGetMoreInfo = 'tool stopped with '
    +'exit code %s. Use context menu to get more information.';
  lisToolStoppedWithExitStatusUseContextMenuToGetMoreInfo = 'tool stopped with '
    +'ExitCode 0 and ExitStatus %s. Use context menu to get more information.';
  lisErrors2 = ', Errors: %s';
  lisWarnings = ', Warnings: %s';
  lisHints = ', Hints: %s';
  lisInternalError = 'internal error: %s';
  lisMenuEditCodeTemplates = 'Code Templates ...';
  dlgEdCodeTempl = 'Code Templates';

  lisMenuUltiboHelp = 'Ultibo.org'; //Ultibo
  lisMenuUltiboForum = 'Ultibo Forum'; //Ultibo
  lisMenuUltiboWiki = 'Ultibo Wiki'; //Ultibo
  lisUltiboURL = 'https://ultibo.org/'; //Ultibo
  lisUltiboForumURL = 'https://ultibo.org/forum/index.php'; //Ultibo
  lisUltiboWikiURL = 'https://ultibo.org/wiki/Main_Page'; //Ultibo

  lisMenuOnlineHelp = 'Online Help';
  lisMenuReportingBug = 'Reporting a Bug';
  lisReportingBugURL = 'http://wiki.lazarus.freepascal.org/How_do_I_create_a_bug_report';
  lisKMContextSensitiveHelp = 'Context sensitive help';
  lisKMEditContextSensitiveHelp = 'Edit context sensitive help';
  lisMenuContextHelp = 'Context sensitive Help';
  lisMenuEditContextHelp = 'Edit context sensitive Help';
  lisMenuShowSmartHint = 'Context sensitive smart hint';

  lisDsgCopyComponents = 'Copy selected components to clipboard';
  lisDsgCutComponents = 'Cut selected components to clipboard';
  lisDsgPasteComponents = 'Paste selected components from clipboard';
  lisDsgSelectParentComponent = 'Select parent component';
  lisDsgOrderMoveToFront = 'Move component to front';
  lisDsgOrderMoveToBack = 'Move component to back';
  lisDsgOrderForwardOne = 'Move component one forward';
  lisDsgOrderBackOne = 'Move component one back';

  // main
  lisChooseProgramSourcePpPasLpr = 'Choose program source (*.pp,*.pas,*.lpr)';
  lisProgramSourceMustHaveAPascalExtensionLikePasPpOrLp = 'Program source '
    +'must have a Pascal extension like .pas, .pp or .lpr';
  lisChooseDelphiUnit = 'Choose Delphi unit (*.pas)';
  lisChooseDelphiProject = 'Choose Delphi project (*.dpr)';
  lisChooseDelphiPackage = 'Choose Delphi package (*.dpk)';
  lisFormatError = 'Format error';
  lisLFMFileCorrupt = 'LFM file corrupt';
  lisUnableToFindAValidClassnameIn = 'Unable to find a valid classname in "%s"';
  lisUnableToConvertFileError = 'Unable to convert file "%s"%sError: %s';
  lisMissingUnitsComment = 'Comment Out';
  lisMissingUnitsForDelphi = 'For Delphi only';
  lisMissingUnitsSearch = 'Search Unit Path';
  lisMissingUnitsSkip = 'Skip';
  lisTheseUnitsWereNotFound = 'These units were not found:';
  lisMissingUnitsChoices = 'Your choices are:';
  lisMissingUnitsInfo1 = '1) Comment out the selected units.';
  lisMissingUnitsInfo1b = '1) Use the units only for Delphi.';
  lisMissingUnitsInfo2 = '2) Search for units. Found paths are added to project settings.';
  lisMissingUnitsInfo3 = '3) Leave these units in uses sections as they are.';
  lisUnitNotFoundInFile = 'A unit not found in file %s';
  lisUnitsNotFoundInFile = 'Units not found in file %s';
  lisProjectPathHint = 'Directory where project''s main file must be';
  lisAddDelphiDefine = 'Add defines simulating Delphi7';
  lisAddDelphiDefineHint = 'Useful when the code has checks for supported compiler versions';
  lisBackupChangedFiles = 'Make backup of changed files';
  lisBackupHint = 'Creates a Backup directory under project directory';

  lisStartConversion = 'Start Conversion';
  lisConvertTarget = 'Target';
  lisConvertTargetHint = 'Converter adds conditional compilation to support different targets';
  lisConvertOtherHint = 'Other options affecting the conversion';
  lisConvertTargetCrossPlatform = 'Cross-platform';
  lisConvertTargetCrossPlatformHint = 'Cross-platform versus Windows-only';
  lisConvertTargetSupportDelphi = 'Support Delphi';
  lisConvertTargetSupportDelphiHint = 'Use conditional compilation to support Delphi';
  lisConvertTargetSameDfmFile = 'Use the same DFM form file';
  lisConvertTargetSameDfmFileHint = 'Same DFM file for Lazarus and Delphi instead of copying it to LFM';
  lisKeepFileOpen = 'Keep converted files open in editor';
  lisKeepFileOpenHint = 'All project files will be open in editor after conversion';
  lisScanFilesInParentDir = 'Scan files in parent directory';
  lisScanFilesInParentDirHint = 'Search for source files in sibling directories'
    +' (parent directory and its children)';

  //Delphi converter
  lisConvDelphiConvertDelphiUnit = 'Convert Delphi unit';
  lisConvDelphiConvertDelphiProject = 'Convert Delphi project';
  lisConvDelphiConvertDelphiPackage = 'Convert Delphi package';
  lisConvDelphiFoundAllUnitFiles = 'Found all unit files';
  lisConvDelphiRepairingFormFiles = '*** Fixing used units and Repairing form files ***';
  lisConvDelphiConvertingProjPackUnits = '*** Converting unit files belonging to project/package ***';
  lisConvDelphiConvertingFoundUnits = '*** Converting unit files found during conversion ***';
  lisConvDelphiChangedEncodingToUTF8 = 'Changed encoding from %s to UTF-8';
  lisConvDelphiAllSubDirsScanned = 'All sub-directories will be scanned for unit files';
  lisConvDelphiMissingIncludeFile = '%s(%s,%s) missing include file';
  lisConvDelphiFixedUnitCase = 'Fixed character case of unit "%s" to "%s".';
  lisConvDelphiReplacedUnitInUsesSection = 'Replaced unit "%s" with "%s" in uses section.';
  lisConvDelphiRemovedUnitFromUsesSection = 'Removed unit "%s" from uses section.';
  lisConvDelphiAddedUnitToUsesSection = 'Added unit "%s" to uses section.';
  lisConvDelphiAddedCustomOptionDefines = 'Added defines %s in custom options';
  lisConvDelphiUnitsToReplaceIn = 'Units to replace in %s';
  lisConvDelphiConversionTook = 'Conversion took: %s';
  lisConvDelphiConversionReady = 'Conversion Ready.';
  lisConvDelphiConversionAborted = 'Conversion Aborted.';
  lisConvDelphiBeginCodeToolsFailed = 'BeginCodeTools failed!';
  lisConvDelphiError = 'Error="%s"';
  lisConvDelphiFailedConvertingUnit = 'Failed converting unit';
  lisConvDelphiFailedToConvertUnit = 'Failed to convert unit "%s"';
  lisConvDelphiExceptionDuringConversion = 'Exception happened during unit conversion.'
    +' Continuing with form files of already converted units...';
  lisConvDelphiUnitnameExistsInLCL = 'Unitname exists in LCL';
  lisConvDelphiUnitWithNameExistsInLCL = 'LCL already has a unit with name %s.'
    +' Delete local file %s?';
  lisConvDelphiPackageNameExists = 'Package name exists';
  lisConvDelphiProjOmittedUnit = 'Omitted unit %s from project';
  lisConvDelphiAddedPackageDependency = 'Added Package %s as a dependency.';
  lisConvDelphiPackageRequired = 'Package %s is required but not installed in Lazarus! Install it later.';
  lisConvDelphiThereIsAlreadyAPackageWithTheNamePleaseCloseThisPa = 'There is '
    +'already a package with the name "%s"%sPlease close this package first.';
  lisConvUnknownProps = 'Unknown properties';
  lisConvTypesToReplace = 'Types to replace';
  lisConvTypeReplacements = 'Type Replacements';
  lisConvUnitsToReplace = 'Units to replace';
  lisConvUnitReplacements = 'Unit Replacements';
  lisConvUnitReplHint = 'Unit names in uses section of a source unit';
  lisConvTypeReplHint = 'Unknown types in form file (DFM/LFM)';
  lisConvCoordOffs = 'Coordinate offsets';
  lisConvCoordHint = 'An offset is added to Top coordinate of controls inside visual containers';
  lisConvFuncsToReplace = 'Functions / procedures to replace';
  lisConvDelphiCategories = 'Categories:';
  lisConvFuncReplacements = 'Function Replacements';
  lisConvFuncReplHint = 'Some Delphi functions can be replaced with LCL function';
  lisConvAddCommentAfterReplacement = 'Add comment after replacement';
  lisConvDelphiName = 'Delphi Name';
  lisConvNewName = 'New Name';
  lisConvParentContainer = 'Parent Container';
  lisConvTopOff = 'Top offset';
  lisConvLeftOff = 'Left offset';
  lisConvDelphiFunc = 'Delphi Function';
  lisConvAddingFlagForRegister = 'Adding flag for "Register" procedure in unit %s.';
  lisConvDeletedFile = 'Deleted file %s';
  lisConvBracketNotFound = 'Bracket not found';
  lisConvDprojFileNotSupportedYet =
    '.dproj file is not supported yet. The file is used by Delphi 2007 and newer.'+
    ' Please select a .dpr file for projects or .dpk file for packages.';
  lisConvRepairingIncludeFiles = 'Repairing include files : ';
  lisConvUserSelectedToEndConversion = 'User selected to end conversion with file %s';
  lisConvFixedUnitName = 'Fixed unit name from %s to %s.';
  lisConvAddedModeDelphiModifier = 'Added MODE Delphi syntax modifier after unit name.';
  lisConvShouldBeFollowedByNumber = '"$" should be followed by a number: %s';
  lisConvReplacedCall = 'Replaced call %s with %s';
  lisConvReplFuncParameterNum = 'Replacement function parameter number should be >= 1: %s';
  lisConvBracketMissingFromReplFunc = '")" is missing from replacement function: %s';
  lisConvProblemsFindingAllUnits = 'Problems when trying to find all units from project file %s';
  lisConvProblemsRepairingFormFile = 'Problems when repairing form file %s';
  lisConvProblemsFixingIncludeFile = 'Problems when fixing include files in file %s';
  lisConvStoppedBecauseThereIsPackage  = 'Stopped because there already is a package with the same name';
  lisConvConvertedFrom = ' { *Converted from %s* }';
  lisConvThisLogWasSaved = 'This log was saved to %s';
  lisScanParentDir = 'Scanning parent directory';
  lisReplacement = 'Replacement';
  lisReplacements = 'Replacements';
  lisInteractive = 'Interactive';
  lisAutomatic = 'Automatic';
  lisProperties = 'Properties (replace or remove)';
  lisTypes = 'Types (not removed if no replacement)';
  lisReplaceRemoveUnknown = 'Fix unknown properties and types';
  lisReplacementFuncs = 'Replacement functions';
  lisFilesHaveRightEncoding = '*** All found files already have the right encoding ***';
  lisEncodingNumberOfFilesFailed = 'Number of files failed to convert: %d';
  lisnoname = 'noname'; // default unit name, must be a valid identifier
  lisTheDestinationDirectoryDoesNotExist = 'The destination directory%s"%s" does not exist.';
  lisRenameFile = 'Rename file?';
  lisThisLooksLikeAPascalFileItIsRecommendedToUseLowerC = 'This looks like a Pascal file.'
    +'%sIt is recommended to use lower case filenames to avoid '
    +'various problems on some filesystems and different compilers.'
    +'%sRename it to lowercase?';
  lisRenameToLowercase = 'Rename to lowercase';
  lisDFilesWereRenamedToL = '%d files were renamed to lowercase.';
  lisKeepName = 'Keep name';
  lisThereAreOtherFilesInTheDirectoryWithTheSameName = 'There are other files in '
    +'the directory with the same name,'
    +'%swhich only differ in case:'
    +'%s%s'
    +'%sDelete them?';
  lisDeleteOldFile = 'Delete old file "%s"?';
  lisStreamingError = 'Streaming error';
  lisUnableToStreamT = 'Unable to stream %s:T%s.';
  lisPathToInstance = 'Path to failed Instance:';
  lisResourceSaveError = 'Resource save error';
  lisUnableToAddResourceHeaderCommentToResourceFile = 'Unable to add resource '
    +'header comment to resource file %s"%s".%sProbably a syntax error.';
  lisUnableToAddResourceTFORMDATAToResourceFileProbably = 'Unable to add '
    +'resource T%s:FORMDATA to resource file %s"%s".%sProbably a syntax error.';
  lisContinueWithoutLoadingForm = 'Continue without loading form';
  lisCancelLoadingUnit = 'Cancel loading unit';
  lisAbortAllLoading = 'Abort all loading';
  lisSkipFile = 'Skip file';
  lisUnableToTransformBinaryComponentStreamOfTIntoText = 'Unable to transform '
    +'binary component stream of %s:T%s into text.';
  lisTheFileWasNotFoundIgnoreWillGoOnLoadingTheProject = 'The file "%s" was not found.'
    +'%sIgnore will go on loading the project,'
    +'%sAbort  will stop the loading.';
  lisSkipFileAndContinueLoading = 'Skip file and continue loading';
  lisAbortLoadingProject = 'Abort loading project';
  lisFileNotFoundDoYouWantToCreateIt = 'File "%s" not found.%sDo you want to create it?';
  lisProjectInfoFileDetected = 'Project info file detected';
  lisTheFileSeemsToBeTheProgramFileOfAnExistingLazarusP = 'The file %s seems '
    +'to be the program file of an existing Lazarus Project.';
  lisTheFileSeemsToBeAProgramCloseCurrentProject = 'The file "%s" seems to be a program.'
    +'%sClose current project and create a new Lazarus project for this program?'
    +'%s"No" will load the file as normal source.';
  lisProgramDetected = 'Program detected';
  lisUnableToConvertTextFormDataOfFileIntoBinaryStream = 'Unable to convert '
    +'text form data of file %s"%s"%sinto binary stream. (%s)';
  lisSaveProject = 'Save project %s (*%s)';
  lisRemoveUnitPath = 'Remove unit path?';
  lisTheDirectoryContainsNoProjectUnitsAnyMoreRemoveThi = 'The directory "%s" '
    +'contains no project units any more. Remove this directory from the '
    +'project''s unit search path?';
  lisInvalidExecutable = 'Invalid Executable';
  lisInvalidExecutableMessageText = 'The file "%s" is not executable.';
  lisInvalidProjectFilename = 'Invalid project filename';
  lisisAnInvalidProjectNamePleaseChooseAnotherEGProject = '"%s" is an '
    +'invalid project name.%sPlease choose another (e.g. project1.lpi)';
  lisChooseADifferentName = 'Choose a different name';
  lisChooseADifferentName2 = 'Choose a different name';
  lisUseInstead = 'Use "%s" instead';
  lisUseAnyway = 'Use "%s" anyway';
  lisTheProjectInfoFileIsEqualToTheProjectMainSource = 'The project info '
    +'file "%s"%sis equal to the project main source file!';
  lisUnitIdentifierExists = 'Unit identifier exists';
  lisThereIsAUnitWithTheNameInTheProjectPleaseChoose = 'There is a unit with the '
    +'name "%s" in the project.%sPlease choose a different name';
  lisErrorCreatingFile = 'Error creating file';
  lisCopyError2 = 'Copy error';
  lisSourceDirectoryDoesNotExist = 'Source directory "%s" does not exist.';
  lisSorryThisTypeIsNotYetImplemented = 'Sorry, this type is not yet implemented';
  lisFileHasChangedSave = 'File "%s" has changed. Save?';
  lisUnitHasChangedSave = 'Unit "%s" has changed. Save?';
  lisSourceOfPageHasChangedSave = 'Source of page "%s" has changed. Save?';
  lisSourceOfPageHasChangedSaveEx = 'Sources of pages have changed. Save page "%s"? (%d more)';
  lisSourceModified = 'Source modified';
  lisOpenProject = 'Open Project?';
  lisOpenTheProject = 'Open the project "%s"?' + LineEnding + LineEnding + 'The "Project" menu has separate commands for opening projects and a list of recent ones.';
  lisOpenPackage = 'Open Package?';
  lisOpenThePackage = 'Open the package "%s"?' + LineEnding + LineEnding + 'The "Package" menu has separate commands for opening packages and a list of recent ones.';
  lisRevertFailed = 'Revert failed';
  lisFileIsVirtual = 'File "%s" is virtual.';
  lisByte = '%s byte';
  lisUnableToAddToProjectBecauseThereIsAlreadyAUnitWith = 'Unable to add %s '
    +'to project because there is already a unit with the same name in the Project.';
  lisAddToProject = 'Add %s to project?';
  lisTheFile = 'The file "%s"';
  lisAddToUnitSearchPath = 'Add to unit search path?';
  lisAddToIncludeSearchPath = 'Add to include search path?';
  lisTheNewIncludeFileIsNotYetInTheIncludeSearchPathAdd =
    'The new include file is not yet in the include search path.%sAdd directory %s?';
  lisTheNewUnitIsNotYetInTheUnitSearchPathAddDirectory =
    'The new unit is not yet in the unit search path.%sAdd directory %s?';
  lisisAlreadyPartOfTheProject = '%s is already part of the Project.';
  lisRemoveFromProject = 'Remove from Project';
  lisShouldTheComponentBeAutoCreatedWhenTheApplicationS = 'Should the '
    +'component "%s" be auto created when the application starts?';
  lisAddToStartupComponents = 'Add to startup components?';
  lisCreateAProjectFirst = 'Create a project first!';
  lisTheTestDirectoryCouldNotBeFoundSeeIDEOpt = 'The Test Directory '
    +'could not be found:%s"%s"%s(see IDE options)';
  lisBuildNewProject = 'Build new project';
  lisTheProjectMustBeSavedBeforeBuildingIfYouSetTheTest = 'The project must be saved before building'
    +'%sIf you set the Test Directory in the IDE options,'
    +'%syou can create new projects and build them at once.'
    +'%sSave project?';
  lisBusy = 'Busy';
  lisCanNotTestTheCompilerWhileDebuggingOrCompiling = 'Cannot test the '
    +'compiler while debugging or compiling.';
  lisNothingToDo = 'Nothing to do';
  lisTheProjectHasNoCompileCommandSeePr = 'The project '
    +'has no compile command.%sSee Project -> Project Options'
    +' -> Compiler Options -> Compiler Commands';
  lisProject2 = 'Project: ';
  lisNoProgramFileSFound = 'No program file "%s" found.';
  lisNotNow = 'Not now';
  lisYouCanNotBuildLazarusWhileDebuggingOrCompiling = 'You cannot build '
    +'Lazarus while debugging or compiling.';
  lisMajorChangesDetected = 'Major changes detected';
  lisTheLazarusSourcesUse = 'The Lazarus sources use a different list of base '
    +'packages.%sIt is recommended to compile the IDE clean using lazbuild.';
  lisCleanUpLazbuild = 'Clean up + lazbuild';
  lisLazbuild = 'lazbuild';
  lisCompileNormally = 'Compile normally';
  lisTheUnitExistsTwiceInTheUnitPathOfThe = 'The unit %s exists twice in the '
    +'unit path of the %s:';
  lisHintCheckIfTwoPackagesContainAUnitWithTheSameName = 'Hint: Check if two '
    +'packages contain a unit with the same name.';
  lisIgnoreAll = 'Ignore all';
  lisUnableToRemoveOldBackupFile = 'Unable to remove old backup file "%s"!';
  lisRenameFileFailed = 'Rename file failed';
  lisBackupFileFailed = 'Backup file failed';
  lisUnableToBackupFileTo = 'Unable to backup file "%s" to "%s"!';
  lisFileNotLowercase = 'File not lowercase';
  lisTheUnitIsNotLowercaseTheFreePascalCompiler = 'The unit filename "%s" is not lowercase.'
    +'%sThe Free Pascal compiler does not search for all cases.'
    +' It is recommended to use lowercase filename.'
    +'%sRename file lowercase?';
  lisDeleteAmbiguousFile = 'Delete ambiguous file?';
  lisAmbiguousFileFoundThisFileCanBeMistakenWithDelete = 'Ambiguous file '
    +'found: "%s"%sThis file can be mistaken with "%s"%sDelete the ambiguous file?';
  lisLazarusEditorV = 'Lazarus IDE (Ultibo Edition) v%s'; //'Lazarus IDE v%s'; //Ultibo
  lisnewProject = '(new project)';
  liscompiling = '%s (compiling ...)';
  lisdebugging = '%s (debugging ...)';
  lisRunning = '%s (running ...)';
  lisUnableToFindFile = 'Unable to find file "%s".';
  lisUnableToFindFileCheckSearchPathInProjectCompilerOption = 'Unable to find file "%s".'
    +'%sIf it belongs to your project, check search path in'
    +'%sProject -> Compiler Options -> Search Paths -> Other Unit Files.'
    +' If this file belongs to a package, check the appropriate package compiler'
    +' options. If this file belongs to Lazarus, make sure compiling clean.'
    +' If the file belongs to FPC then check fpc.cfg.'
    +' If unsure, check Project -> CompilerOptions -> Test';
  lisNOTECouldNotCreateDefineTemplateForFreePascal = 'NOTE: Could not create '
    +'Define Template for Free Pascal Sources';
  lisClassNotFound = 'Class not found';
  lisClassNotFoundAt = 'Class %s not found at %s(%s,%s)';
  lisRemoveUses = 'Remove uses "%s"';
  lisCreateLocalVariable = 'Create local variable "%s"';
  lisHideAllHintsAndWarningsByInsertingIDEDirectivesH = 'Hide all hints and '
    +'warnings by inserting IDE directives {%H-}';
  lisHideMessageAtByInsertingIDEDirectiveH = 'Hide message at %s by inserting '
    +'IDE directive {%H-}';
  lisHideMessageByInsertingIDEDirectiveH = 'Hide message by inserting IDE directive {%H-}';
  lisOIFClassNotFound = 'Class "%s" not found.';
  lisClassIsNotARegisteredComponentClassUnableToPaste = 'Class "%s" is not '
    +'a registered component class.%sUnable to paste.';
  lisControlNeedsParent = 'Control needs parent';
  lisTheClassIsATControlAndCanNotBePastedOntoANonContro = 'The class "%s" '
    +'is a TControl and cannot be pasted onto a non control.%sUnable to paste.';
  lisConversionError = 'Conversion error';
  lisUnableToConvertComponentTextIntoBinaryFormat = 'Unable to convert '
    +'component text into binary format:%s%s';
  lisInsufficientEncoding = 'Insufficient encoding';
  lisUnableToConvertToEncoding = 'Unable to convert to encoding "%s"';
  lisSavingFileAsLoosesCharactersAtLineColumn = 'Saving file "%s" as "%s" '
    +'looses characters at line %s, column %s.';
  lisNOTECouldNotCreateDefineTemplateForLazarusSources = 'NOTE: Could not '
    +'create Define Template for Lazarus Sources';
  lisOwnerIsAlreadyUsedByTReaderTWriterPleaseChooseAnot = '''Owner'' is '
    +'already used by TReader/TWriter. Please choose another name.';
  lisDuplicateNameAComponentNamedAlreadyExistsInTheInhe = 'Duplicate name: A '
    +'component named "%s" already exists in the inherited component %s';
  lisComponentNameIsKeyword = 'Component name "%s" is keyword';
  lisThereIsAlreadyAComponentClassWithTheName = 'There is already a component '
    +'class with the name %s.';
  lisTheUnitItselfHasAlreadyTheNamePascalIdentifiersMus = 'The unit itself '
    +'has already the name "%s". Pascal identifiers must be unique.';
  lisUnableToRenameVariableInSource = 'Unable to rename variable in source.';
  lisUnableToUpdateCreateFormStatementInProjectSource = 'Unable to update '
    +'CreateForm statement in project source';
  lisThereIsAlreadyAFormWithTheName = 'There is already a form with the name "%s"';
  lisThereIsAlreadyAUnitWithTheNamePascalIdentifiersMus = 'There is already a '
    +'unit with the name "%s". Pascal identifiers must be unique.';
  lisThisComponentAlreadyContainsAClassWithTheName = 'This component already '
    +'contains a class with the name %s.';
  lisSeeMessages = 'See messages.';
  lisError = 'Error: ';
  lisWarning = 'Warning: ';
  lisFile2 = 'File: ';
  lisDirectory = 'Directory: ';
  lisYouCanDownloadFPCAndTheFPCSourcesFromHttpSourcefor = 'You can download '
    +'FPC and the FPC sources from http://sourceforge.net/projects/lazarus/?'
    +'source=directory';
  lisSaveChanges = 'Save changes?';
  lisSaveFileBeforeClosingForm = 'Save file "%s"%sbefore closing form "%s"?';
  lisUnableToRenameFormInSource = 'Unable to rename form in source.';
  lisTheComponentIsInheritedFromToRenameAnInheritedComp = 'The component %s '
    +'is inherited from %s.%sTo rename an inherited component open the '
    +'ancestor and rename it there.';
  lisUnableToFindMethod = 'Unable to find method.';
  //lisUnableToCreateNewMethod = 'Unable to create new method.';
  lisUnableToShowMethod = 'Unable to show method.';
  lisPleaseFixTheErrorInTheMessageWindow = 'Please fix the error shown in the'
    +' message window which is normally below the source editor.';
  lisMethodClassNotFound = 'Method class not found';
  lisClassOfMethodNotFound = 'Class "%s" of method "%s" not found.';
  lisUnableToRenameMethodPleaseFixTheErrorShownInTheMessag = 'Unable to rename '
    +'method. Please fix the error shown in the message window.';
  lisStopDebugging = 'Stop Debugging?';
  lisStopTheDebugging = 'Stop the debugging?';
  lisCannotFindLazarusStarter = 'Cannot find Lazarus starter:%s%s';
  lisFPCTooOld = 'FPC too old';
  lisTheProjectUsesFPCResourcesWhichRequireAtLeast = 'The project uses '
    +'FPC resources which require at least FPC 2.4';
  lisCreateDirectory = 'Create directory?';
  lisFileFound = 'File found';
  lisTheTargetDirectoryIsAFile = 'The target directory is a file:%s';
  lisTheOutputDirectoryIsMissing = 'The output directory "%s" is missing.';
  lisCreateIt = 'Create it';
  lisInvalidFileName = 'Invalid file name';
  lisTheTargetFileNameIsADirectory = 'The target file name is a directory.';
  lisNotAValidFppkgPrefix ='Free Pascal compiler not found at the given prefix.';
  lisIncorrectFppkgConfiguration = 'there is a problem with the Fppkg configuration. (%s)';
  lisFppkgCompilerProblem = 'there is a problem with the Free Pascal compiler executable, ';
  lisFppkgInstallationPath = 'The prefix of the Free Pascal Compiler installation ' +
    'is required. For example it has the units "%s" and/or "%s"';
  lisSelectFPCPath = 'Select the path where FPC is installed';
  lisCreateFppkgConfig = 'Restore Fppkg configuration';
  lisFppkgProblem = 'Problem with Fppkg configuration';
  lisFreePascalPrefix = 'Free Pascal compiler prefix';
  lisFppkgWriteConfException = 'A problem occurred while trying to create a new ' +
    'Fppkg configuration: %s';
  lisFppkgWriteConfFailed = 'Failed to create a new Fppkg configuration (%s) You ' +
    'will have to fix the configuration manually or reinstall Free Pascal.';
  lisNoFppkgPrefix = 'empty Free Pascal compiler prefix.';
  lisFppkgCreateFileFailed = 'Failed to generate the configuration file "%s": %s';
  lisFppkgRecentFpcmkcfgNeeded = 'Make sure a recent version is installed and ' +
    'available in the path or alongside the compiler-executable.';
  lisFppkgFpcmkcfgCheckFailed = 'Failed to retrieve the version of the fpcmkcfg ' +
    'configuration tool.';
  lisFppkgFpcmkcfgNeeded = 'An up-to-date version is needed to create the ' +
    'configuration files.';
  lisFppkgFpcmkcfgTooOld = 'The fpcmkcfg configuration tool it too old [%s].';
  lisFppkgFpcmkcfgProbTooOld = 'It is probably too old to create the configuration files.';
  lisFppkgFpcmkcfgMissing = 'Could not find the fpcmkcfg configuration tool, ' +
    'which is needed to create the configuration files.';
  lisGenerateFppkgConfigurationCaption = 'Generate new Fppkg configuration files';
  lisGenerateFppkgConfiguration = 'Use this screen to generate new Fppkg configuration files ' +
    'with the fpcmkcfg tool.';
  lisFppkgConfGenProblems = 'Warnings have to be resolved first';
  lisFppkgFilesToBeWritten = 'Files to be written:';
  lisGenerateFppkgCfg = 'Fppkg configuration: %s';
  lisGenerateFppkgCompCfg = 'Fppkg compiler configuration: %s';
  lisFppkgWriteConfigFile = 'Write new configuration files';
  lisFppkgPrefix = 'Fpc prefix: %s';
  lisFppkgLibPrefix = 'Fpc library prefix: %s';
  lisFppkgConfiguration = 'The configuration file typically has the name "fppkg.cfg". ' +
    'When incorrect it may be impossible to resolve dependencies on Free Pascal ' +
    'packages. Leave empty to use the default.';
  lisFppkgFixConfiguration = 'You could try to restore the configuration files automatically, ' +
    'or adapt the configuration file manually.';

  // file dialogs
  lisOpenFile = 'Open File';
  lisOpenFile2 = 'Open file';
  lisProjectSRaisedExceptionClassS = 'Project %s raised exception class ''%s''.';
  lisProjectSRaisedExceptionClassSWithMessageSS = 'Project %s raised '
    +'exception class ''%s'' with message:%s%s';
  lisProjectSRaisedExceptionInFileLineSrc = '%0:s%0:s In file ''%1:s'' at line %2:d:%0:s%3:s';
  lisProjectSRaisedExceptionInFileLine    = '%0:s%0:s In file ''%1:s'' at line %2:d';
  lisProjectSRaisedExceptionInFileAddress = '%0:s%0:s In file ''%1:s'' at address %2:x';
  lisProjectSRaisedExceptionAtAddress     = '%0:s%0:s At address %1:x';
  lisPEEditVirtualUnit = 'Edit Virtual Unit';
  lisIECOExportFileExists = 'Export file exists';
  lisIECOExportFileExistsOpenFileAndReplaceOnlyCompilerOpti = 'Export file "%s" exists.'
    +'%sOpen file and replace only compiler options?'
    +'%s(Other settings will be kept.)';
  lisIECOImportCompilerOptions = 'Import Compiler Options';
  lisIECOExportCompilerOptions = 'Export Compiler Options';
  lisIECOCompilerOptionsOf = 'Compiler options of';
  lisIECOCurrentBuildMode = 'Current build mode';
  lisIECOAllBuildModes = 'All build modes';

  lisIECOErrorOpeningXml = 'Error opening XML';
  lisIECOErrorOpeningXmlFile = 'Error opening XML file "%s":%s%s';
  lisImportingBuildModesNotSupported = 'Importing BuildModes is not supported for packages.';
  lisSuccessfullyImportedBuildModes = 'Successfully imported %d BuildModes from "%s".';
  lisSuccessfullyExportedBuildModes = 'Successfully exported %d BuildModes to "%s".';
  lisSuccessfullyImportedCompilerOptions = 'Successfully imported compiler options from "%s".';
  lisSuccessfullyExportedCompilerOptions = 'Successfully exported compiler options to "%s".';
  lisIECONoCompilerOptionsInFile = 'File "%s" does not contain compiler options.';
  lisIECOSaveToFile = 'Save to file';
  lisIECOLoadFromFile = 'Load from file';
  lisDebugUnableToLoadFile = 'Unable to load file';
  lisDebugUnableToLoadFile2 = 'Unable to load file "%s".';
  lisOpenProjectFile = 'Open Project File';
  lisSelectFile = 'Select the file';
  lisClickHereToBrowseTheFileHint = 'Click here to browse the file';
  lisOpenPackageFile = 'Open Package File';
  lisSaveSpace = 'Save ';
  lisSelectDFMFiles = 'Select Delphi form files (*.dfm|*.fmx)';
  lisChooseLazarusSourceDirectory = 'Choose Lazarus Directory';
  lisChooseCompilerExecutable = 'Choose compiler executable (%s)';
  lisChooseFPCSourceDir = 'Choose FPC source directory';
  lisChooseCompilerMessages = 'Choose compiler messages file';
  lisChooseMakeExecutable = 'Choose "make" executable';
  lisChooseDebuggerExecutable = 'Choose debugger executable';
  lisChooseTestBuildDir = 'Choose the directory for tests';
  lisChooseExecutable = 'Choose an executable';
  lisChooseFppkgConfigurationFile = 'Choose the fppkg configuration file';

  // dialogs
  lisProjectChanged = 'Project changed';
  lisSaveChangesToProject = 'Save changes to project %s?';
  lisProjectSessionChanged = 'Project session changed';
  lisSaveSessionChangesToProject = 'Save session changes to project %s?';

  lisAboutLazarus = 'About Lazarus';
  lisVersion = 'Version';
  lisVerToClipboard = 'Copy version information to clipboard';
  lisBuildDate = 'Build Date';
  lisFPCVersion = 'FPC Version: ';
  lisRevision = 'Revision: ';
  lisPrior = 'prior %s';
  lisWelcomeToLazarusThereIsAlreadyAConfigurationFromVe = 'Welcome to Lazarus %s'
    +'%sThere is already a configuration from version %s in'
    +'%s%s';
  lisTheOldConfigurationWillBeUpgraded = 'The old configuration will be '
    +'upgraded.';
  lisTheConfigurationWillBeDowngradedConverted = 'The configuration will be '
    +'downgraded/converted.';
  lisIfYouWantToUseTwoDifferentLazarusVersionsYouMustSt = 'If you want to use '
    +'two different Lazarus versions you must start the second Lazarus with '
    +'the command line parameter primary-config-path or pcp.'
    +'%sFor example:';
  lisUpgradeConfiguration = 'Upgrade configuration';
  lisUpgrade = 'Upgrade';
  lisDowngradeConfiguration = 'Downgrade configuration';
  lisDowngrade = 'Downgrade';
  lisAboutLazarusMsg =
       'License: GPL/LGPL. See Lazarus and Free Pascal sources for license details.'
      +'%s'
      +'Lazarus is an IDE to create graphical and console applications '
      +'with Free Pascal. Free Pascal is a Pascal and Object Pascal '
      +'compiler that runs on Windows, Linux, macOS, FreeBSD and more.'
      +'%s'
      +'Lazarus is the missing part of the puzzle that will allow you to '
      +'develop programs for all of the above platforms in a Delphi-like '
      +'environment. The IDE is a RAD tool that includes a form designer.'
      +'%s'
      +'As Lazarus is growing, we need more developers.';
  lisAboutNoContributors = 'Cannot find contributors list.';
  lisUnitNameAlreadyExistsCap = 'Unitname already in project';
  lisTheUnitAlreadyExists = 'The unit "%s" already exists.';
  lisForceRenaming = 'Force renaming';
  lisCancelRenaming = 'Cancel renaming';
  lisInvalidPascalIdentifierCap = 'Invalid Pascal Identifier';
  lisTheNameContainsAPascalKeyword = 'The name "%s" contains a Pascal keyword.';
  lisInvalidPascalIdentifierName = 'The name "%s" is not a valid Pascal identifier.'
      +'%sUse it anyway?';

  lisCloseAllTabsTitle = 'Close Source Editor Window';
  lisCloseAllTabsQuestion = 'Closing a Source Editor Window. Do you want close all files or hide the window?';
  lisCloseAllTabsClose = 'Close files';
  lisCloseAllChecked = 'Close All Checked';
  lisCloseAllTabsHide = 'Hide window';
  lisSaveAllChecked = 'Save All Checked';
  lisActivate = 'Activate';
  lisActivateSelected = 'Activate Selected';

  // hints
  lisHintViewUnits = 'View Units';
  lisHintViewForms = 'View Forms';

  lisGPLNotice =
    '<description>' + sLineBreak + sLineBreak
   +'Copyright (C) <year> <name of author> <contact>'  + sLineBreak + sLineBreak
   +'This source is free software; you can redistribute it and/or modify '
   +'it under the terms of the GNU General Public License as published by '
   +'the Free Software Foundation; either version 2 of the License, or '
   +'(at your option) any later version. '  + sLineBreak + sLineBreak
   +'This code is distributed in the hope that it will be useful, but '
   +'WITHOUT ANY WARRANTY; without even the implied warranty of '
   +'MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU '
   +'General Public License for more details. ' + sLineBreak + sLineBreak
   +'A copy of the GNU General Public License is available on the World '
   +'Wide Web at <http://www.gnu.org/copyleft/gpl.html>. You can also '
   +'obtain it by writing to the Free Software Foundation, '
   +'Inc., 51 Franklin Street - Fifth Floor, Boston, MA 02110-1335, USA.';

  lisLGPLNotice =
    '<description>' + sLineBreak + sLineBreak
   +'Copyright (C) <year> <name of author> <contact>'  + sLineBreak + sLineBreak
   +'This library is free software; you can redistribute it and/or modify '
   +'it under the terms of the GNU Library General Public License as published '
   +'by the Free Software Foundation; either version 2 of the License, or '
   +'(at your option) any later version. ' + sLineBreak + sLineBreak
   +'This program is distributed in the hope that it will be useful, '
   +'but WITHOUT ANY WARRANTY; without even the implied warranty of '
   +'MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the '
   +'GNU Library General Public License for more details. ' + sLineBreak + sLineBreak
   +'You should have received a copy of the GNU Library General Public License '
   +'along with this library; if not, write to the Free Software '
   +'Foundation, Inc., 51 Franklin Street - Fifth Floor, Boston, MA 02110-1335, USA.';

  lisModifiedLGPLNotice =
    '<description>' + sLineBreak + sLineBreak
   +'Copyright (C) <year> <name of author> <contact>' + sLineBreak + sLineBreak
   +'This library is free software; you can redistribute it and/or modify '
   +'it under the terms of the GNU Library General Public License as published '
   +'by the Free Software Foundation; either version 2 of the License, or '
   +'(at your option) any later version with the following modification:' + sLineBreak + sLineBreak
   +'As a special exception, the copyright holders of this library give you '
   +'permission to link this library with independent modules to produce an '
   +'executable, regardless of the license terms of these independent modules,'
   +'and to copy and distribute the resulting executable under terms of your '
   +'choice, provided that you also meet, for each linked independent module, '
   +'the terms and conditions of the license of that module. An independent '
   +'module is a module which is not derived from or based on this library. If '
   +'you modify this library, you may extend this exception to your version of '
   +'the library, but you are not obligated to do so. If you do not wish to do '
   +'so, delete this exception statement from your version.' + sLineBreak + sLineBreak
   +'This program is distributed in the hope that it will be useful, '
   +'but WITHOUT ANY WARRANTY; without even the implied warranty of '
   +'MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the '
   +'GNU Library General Public License for more details. ' + sLineBreak + sLineBreak
   +'You should have received a copy of the GNU Library General Public License '
   +'along with this library; if not, write to the Free Software '
   +'Foundation, Inc., 51 Franklin Street - Fifth Floor, Boston, MA 02110-1335, USA.';

  // MIT license aka Expat license see: http://www.opensource.org/licenses/MIT
  lisMITNotice =
    '<description>' + sLineBreak + sLineBreak
    +'Copyright (c) <year> <copyright holders>' + sLineBreak + sLineBreak
    +'Permission is hereby granted, free of charge, to any person obtaining a copy of '
    +'this software and associated documentation files (the "Software"), to deal in '
    +'the Software without restriction, including without limitation the rights to '
    +'use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of '
    +'the Software, and to permit persons to whom the Software is furnished to do so, '
    +'subject to the following conditions:' + sLineBreak + sLineBreak
    +'The above copyright notice and this permission notice shall be included in all '
    +'copies or substantial portions of the Software.' + sLineBreak + sLineBreak
    +'THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR '
    +'IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, '
    +'FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE '
    +'AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER '
    +'LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, '
    +'OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE '
    +'SOFTWARE.';

  // Options dialog groups
  dlgGroupEnvironment = 'Environment';
  dlgGroupEditor = 'Editor';
  dlgGroupCodetools = 'Codetools';
  dlgGroupCodeExplorer = 'Code Explorer';
  dlgGroupDebugger = 'Debugger';
  // Options dialog
  dlgIDEOptions = 'IDE Options';
  dlgBakNoSubDirectory = '(no subdirectory)';
  dlgEOFocusMessagesAtCompilation = 'Focus messages at compilation';
  lisMaximumParallelProcesses0MeansDefault = 'Maximum parallel processes, 0 '
    +'means default (%s)';
  lisShowFPCMessageLinesCompiled = 'Show FPC message "lines compiled"';
  lisElevateTheMessagePriorityToAlwaysShowItByDefaultIt = 'Elevate the message'
    +' priority to always show it (by default it has low priority "verbose")';
  lisMessagesWindow = 'Messages Window';
  lisCheckForDiskFileChangesViaContent =
    'Check for disk file changes via content rather than timestamp';
  lisSlowerButMoreAccurate = 'Slower but more accurate.';

  // Search dialog
  dlgSearchCaption = 'Searching ...';
  dlgSearchAbort = 'Search terminated by user.';
  dlgSeachDirectoryNotFound = 'Search directory "%s" not found.';
  lissMatches = 'Matches';
  lissSearching = 'Searching';
  lissSearchText = 'Search text';

  dlgWindow = 'Window';
  dlgFrmEditor = 'Form Editor';
  dlgObjInsp = 'Object Inspector';
  dlgEnvFiles = 'Files';
  dlgEnvIdeStartup = 'IDE Startup';
  dlgEnvBckup = 'Backup';
  dlgNaming = 'Naming';
  lisInformation = 'Information';
  lisQuickFixes = 'Quick fixes';
  lisAutoCompletionOn = 'Auto completion: on';
  lisAutoCompletionOff = 'Auto completion: off';
  lisSAMSelectNone = 'Select none';
  lisKMClassic = 'Classic';
  lisKMLazarusDefault = 'Lazarus default';
  lisKMMacOSXApple = 'macOS, Apple style';
  lisKMMacOSXLaz = 'macOS, Lazarus style';
  lisKMDefaultToOSX = 'Default adapted to macOS';
  lisPEFilename = 'Filename:';
  lisPEUnitname = 'Unitname:';
  lisPEInvalidUnitFilename = 'Invalid unit filename';
  lisPVUAPascalUnitMustHaveTheExtensionPpOrPas = 'A Pascal unit must have the '
    +'extension .pp or .pas';
  lisPEInvalidUnitname = 'Invalid unitname';
  lisPVUTheUnitnameIsNotAValidPascalIdentifier = 'The unitname is not a valid '
    +'Pascal identifier.';
  lisPVUUnitnameAndFilenameDoNotMatchExampleUnit1PasAndUni = 'Unitname and '
    +'Filename do not match.%sExample: unit1.pas and Unit1';
  lisPEConflictFound = 'Conflict found';
  lisPVUThereIsAlreadyAnUnitWithThisNameFile = 'There is already an unit with '
    +'this name.%sFile: %s';
  lisCMParameter = 'Parameter';
  lisInsertMacro = 'Insert Macro';
  lisCTPleaseSelectAMacro = 'please select a macro';
  dlgEnvProject = 'Tabs for project';
  lisCenterALostWindow = 'Center a lost window';
  lisNumberOfFilesToConvert = 'Number of files to convert: %s';
  lisConvertEncoding = 'Convert Encoding';
  lisConvertProjectOrPackage = 'Convert project or package';
  lisEdtDefCurrentProject = 'Current Project';
  lisNewEncoding = 'New encoding:';
  lisFileFilter = 'File filter';
  lisFilesInASCIIOrUTF8Encoding = 'Files in ASCII or UTF-8 encoding';
  lisFilesNotInASCIINorUTF8Encoding = 'Files not in ASCII nor UTF-8 encoding';
  podAddPackageUnitToUsesSection = 'Add package unit to uses section';
  lisLPKCompatibilityModeCheckBox = 'Maximize compatibility of package file (LPK)';
  lisLPKCompatibilityModeCheckBoxHint = 'Check this if you want to open your package in legacy (2.0 and older) Lazarus versions.';
  lisCodeBrowser = 'Code Browser';

  // IDE General options
  dlgEnvLanguage = 'Language';
  dlgEnvLanguageRestartHint = 'Restart the IDE to complete the language change.'; // If changed update the copy in procedure TDesktopOptionsFrame.LanguageComboBoxChange
  dlgCheckAndAutoSaveFiles = 'Check and Auto Save Files';
  lisAskBeforeSavingProjectSSession = 'Ask before saving project''s session';
  lisIfOnlySessionInfoChangedThenAsk = 'If only the session info changed, ask about saving it.';
  dlgEdFiles = 'Editor Files';
  dlgIntvInSec = 'Interval in secs';
  dlgDesktopHints = 'Hints';
  dlgDesktopButtons = 'Buttons - ';
  dlgDesktopMenus = 'Menus - ';
  dlgPalHints = 'Hints for component palette';
  dlgSpBHints = 'Hints for main speed buttons (open, save, ...)';
  dlgMouseAction = 'Mouse Action';
  dlgPreferDoubleClickOverSingleClick = 'Prefer double-click over single-click';
  dlgCurrentlyRespectedByMessagesWindow = 'Currently respected by messages window, '
    +'jump history and search results.';
  lisExportEnvironmentOptions = 'Export environment options';
  lisImportEnvironmentOptions = 'Import environment options';
  lisComboBoxes = 'Combo Boxes';
  lisDropDownCount = 'Drop Down Count';
  lisDropDownCountHint = 'Used for all ComboBoxes in IDE dialogs';

  // Desktop options
  dlgManageDesktops = 'Manage desktops';
  dlgSaveCurrentDesktop = 'Save current desktop';
  dlgSaveCurrentDesktopAs = 'Save current desktop as';
  dlgSaveCurrentDesktopAsBtnCaption = 'Save active desktop as ...';
  dlgSaveCurrentDesktopAsBtnHint = 'Save active desktop as';
  dlgDeleteSelectedDesktopBtnCaption = 'Delete';
  dlgDeleteSelectedDesktopBtnHint = 'Delete selected desktop';
  dlgRenameSelectedDesktopBtnCaption = 'Rename';
  dlgRenameSelectedDesktopBtnHint = 'Rename selected desktop';
  dlgReallyDeleteDesktop = 'Really delete desktop "%s"?';
  dlgCannotUseDockedUndockedDesktop = 'You cannot use docked desktop in undocked environment and vice versa.';
  dlgRenameDesktop = 'Rename desktop';
  dlgNewDesktop = 'New desktop ...';
  dlgSetActiveDesktopBtnCaption = 'Set active';
  dlgSetActiveDesktopBtnHint = 'Set active';
  dlgResetActiveDesktopBtnCaption = 'Restore active';
  dlgResetActiveDesktopBtnHint = 'Restore window layout of active desktop';
  dlgToggleDebugDesktopBtnCaption = 'Toggle as debug desktop';
  dlgToggleDebugDesktopBtnHint = 'Toggle as debug desktop';
  dlgDesktopName = 'Desktop name';
  dlgOverwriteDesktop = 'Desktop with the name "%s" was found.'+sLineBreak+'Should the old desktop be overwritten?';
  dlgDebugDesktop = 'debug';
  dlgActiveDesktop = 'active';
  dlgImportDesktopExists = 'A desktop with the same name already exists.'+sLineBreak+'Please confirm the desktop name:';
  dlgDesktopsImported = '%d desktop(s) successfully imported from "%s"';
  dlgDesktopsExported = '%d desktop(s) successfully exported to "%s"';
  lisExportSelected = 'Export selected';
  lisExportAll = 'Export all';
  dlgGrayedDesktopsDocked = 'Grayed desktops are for docked environment.';
  dlgGrayedDesktopsUndocked = 'Grayed desktops are for undocked environment.';
  dlgAutoSaveActiveDesktop = 'Auto save active desktop';
  dlgAutoSaveActiveDesktopHint = 'Save active desktop on IDE close'+sLineBreak+'Save debug desktop on IDE close and debug end';
  dlgAssociatedDebugDesktop = 'Associated debug desktop for "%s"';
  dlgAssociatedDebugDesktopHint = 'If you select the desktop, the associated debug desktop will be selected as well.';

  // Window options
  dlgShowingWindows = 'Showing Windows';
  dlgSingleTaskBarButton  = 'Show single button in TaskBar';
  dlgHideIDEOnRun = 'Hide IDE windows on Run/Debug';
  dlgHideIDEOnRunHint = 'Do not show the IDE at all while program is running.';
  lisShowOnlyOneButtonInTheTaskbarForTheWholeIDEInstead = 'Show only one '
    +'button in the taskbar for the whole IDE instead of one per window. Some'
    +' Linux Window Managers like Cinnamon do not support this and always show'
    +' one button per window.';
  lisIDETitleStartsWithProjectName = 'Show custom IDE title before built-in IDE title or info';
  lisIDETitleOptions = 'IDE main window and taskbar title';
  lisIDETitleCustom = 'Custom IDE title';
  lisIDECaptionCustomHint = 'Additional info to display in the IDE title';
  lisAutoAdjustIDEHeight = 'Automatically adjust IDE main window height';
  lisAutoAdjustIDEHeightHint = '';
  lisAutoAdjustIDEHeightFullComponentPalette = 'Show complete component palette';
  lisAutoAdjustIDEHeightFullComponentPaletteHint =
    'If component palette spans over more lines, show them all and not only one.';
  lisProjectInspectorShowProps = 'Show properties pane in Project Inspector';
  lisWindowMenuWithNameForDesignedForm = 'Window menu shows designed form''s name instead of caption';
  lisWindowMenuWithNameForDesignedFormHint = 'Useful especially if the caption is left empty.';
  lisTitleInTaskbarShowsForExampleProject1LpiLazarus = 'Show the custom IDE title ' +
    'before the IDE''s name and other info in the title. Example: project1 - Lazarus.';

  // Message window options
  dlgShowMessagesIcons = 'Show Messages Icons';
  dlgAnIconForErrorWarningHintIsShown = 'An icon for error/warning/hint is shown '
    +'in front of a message. The same icon shows in source editor gutter in any case.';
  lisAlwaysDrawSelectedItemsFocused = 'Always draw selected items focused';
  lisDrawTheSelectionFocusedEvenIfTheMessagesWindowHasN = 'Draw the selection '
    +'focused even if the Messages window has no focus. Use this if your '
    +'theme has a hardly visible unfocused drawing.';
  lisEditorColors = 'Editor Colors';
  lisPastelColors = 'Pastel Colors';

  dlgProjFiles = 'Project Files';
  dlgEnvType = 'Type';
  dlgEnvNone = 'None';
  srkmecKeyMapLeft = 'Left';
  srkmecKeyMapRight = 'Right';
  dlgSmbFront = 'Symbol in front (.~pp)';
  lisNoBackupFiles = 'No backup files';
  dlgSmbBehind = 'Symbol behind (.pp~)';
  dlgSmbCounter = 'Counter (.pp;1)';
  dlgCustomExt = 'User defined extension (.pp.xxx)';
  dlgBckUpSubDir = 'Same name (in subdirectory)';
  dlgEdCustomExt = 'User defined extension';
  dlgMaxCntr = 'Maximum counter';
  dlgEdBSubDir = 'Sub directory';
  dlgEnvOtherFiles = 'Other Files';
  dlgMaxRecentFiles = 'Max recent files';
  dlgMaxRecentProjs = 'Max recent project files';
  dlgMaxRecentHint = 'Value 0 means unlimited.';
  dlgLazarusDir = 'Lazarus directory (default for all projects)';
  lisLazarusDirHint = 'Lazarus sources. This path is relative to primary config directory (%s).';
  dlgFpcExecutable = 'Compiler executable (e.g. %s)';
  dlgFpcSrcPath = 'FPC source directory';
  dlgMakeExecutable = '"Make" executable';
  dlgCompilerMessages = 'Compiler messages language file (*.msg)';
  dlgFppkgConfigurationFile = 'Fppkg configuration file (e.g. fppkg.cfg)';
  lisSetThisToTranslateTheCompilerMessagesToAnotherLang = 'Set this to '
    +'translate the compiler messages to another language (i.e. not English). '
    +'For example: German: $(FPCSrcDir)/compiler/msg/errordu.msg.';

  dlgDebugType = 'Debugger type and path';
  dlgTestPrjDir = 'Directory for building test projects';

  dlgQShowGrid = 'Show grid';
  dlgGridConsistsOfSmallDots = 'Grid consists of small dots which help aligning controls.';
  dlgQShowBorderSpacing = 'Show border spacing';
  dlgBorderSpaceCanBeSetInAnchorEditor = 'Border space can be set in Anchor editor. '
    +'A colored line is shown if spacing > 0.';
  dlgQSnapToGrid = 'Snap to grid';
  dlgDistanceBetweenGridPointsIsSmallestStep = 'Distance between grid points is '
    +'the smallest step when moving a control.';
  dlgGridX = 'Grid size X';
  dlgGridXHint = 'Horizontal grid step size';
  dlgGridY = 'Grid size Y';
  dlgGridYHint = 'Vertical grid step size';
  dlgGuideLines = 'Show Guide Lines';
  dlgGuideLinesHint = 'When a control is aligned horizontally or vertically '
    +'with another controls, a blue guide line is shown.';
  dlgSnapGuideLines = 'Snap to Guide Lines';
  dlgSnapGuideLinesHint = 'When a control is close to being aligned '
    +'with another control, it snaps to the aligned position.';
  dlgGridColor = 'Grid color';
  dlgLeftTopClr = 'Guide lines Left,Top';
  dlgRightBottomClr = 'Guide lines Right,Bottom';
  dlgGrabberColor = 'Grabber color';
  dlgMarkerColor = 'Marker color';
  dlgBorderSpacingColor = 'BorderSpacing frame';
  dlgNonFormBackgroundColor = 'Other Designer background (e. g. TDataModule)';
  dlgRuberbandSelectionColor = 'Rubberband Selection';
  dlgRuberbandCreationColor = 'Rubberband Creation';
  dlgRubberbandSelectsGrandChildren = 'Select grandchildren';
  dlgSelectAllChildControls = 'Select all child controls together with their parent.';
  dlgShowCaptionsOfNonVisuals = 'Show captions of nonvisual components';
  dlgDrawComponentsNameBelowIt = 'Draw the component''s name below it.';
  dlgShowDesignerHints = 'Show designer hints';
  dlgShowDesignerHintsHint = 'Hint shows control''s position or size while moving or resizing it.';
  lisOpenDesignerOnOpenUnit = 'Open designer on open unit';
  lisOpenDesignerOnOpenUnitHint = 'Form is loaded in designer always when source unit is opened.';
  dlgrightClickSelects = 'Right click selects';
  dlgComponentUnderMouseCursorIsFirstSelected = 'Component under mouse cursor '
    +'is first selected, then the popup menu commands work on it.';
  lisAskNameOnCreate = 'Ask name on create';
  lisAskForComponentNameAfterPuttingItOnForm = 'Ask for component '
    +'name after putting it on a designer form.';
  lisOFESwitchToObjectInspectorFavoritesTab = 'Switch to Object Inspector Favorites tab';
  lisSwitchToFavoritesTabAfterAsking = 'Switch to Favorites tab after asking for component name.';
  dlgCheckPackagesOnFormCreate = 'Check packages on form create';
  dlgCheckPackagesOnFormCreateHint = 'The form may require a package to work. '
    +'Install such a package automatically.';
  dlgFormTitleBarChangesObjectInspector = 'Change Object Inspector contents on clicking form title bar';
  dlgFormTitleBarChangesObjectInspectorHint = 'Show a form''s properties in Object Inspector '
    +'by clicking on its title bar.';
  dlgForceDPIScalingInDesignTime = 'Force DPI scaling in design-time';
  dlgForceDPIScalingInDesignTimeHint = 'When checked the project scaling settings will be ignored - only the form/frame/datamodule Scaled property will be taken into account.';

  dlgEnvGrid = 'Grid';
  dlgEnvLGuideLines = 'Guide lines';
  dlgEnvMisc = 'Miscellaneous';
  dlgPasExt = 'Default Pascal extension';
  dlgCharCaseFileAct = 'Save As - auto rename Pascal files lower case';
  dlgAmbigFileAct = 'Ambiguous file action:';
  dlgEnvAsk = 'Ask';
  dlgAutoDel = 'Auto delete file';
  dlgAutoRen = 'Auto rename file lowercase';
  dlgnoAutomaticRenaming = 'No automatic renaming';
  lisWhenAUnitIsRenamedUpdateReferences = 'When a unit is renamed, update references';
  dlgAmbigWarn = 'Warn on compile';
  lisAlwaysIgnore = 'Always ignore';
  // OI colors
  dlgBackColor = 'Background';
  lisToolHeaderRunning = 'Tool Header: Running';
  lisToolHeaderSuccess = 'Tool Header: Success';
  lisToolHeaderFailed = 'Tool Header: Failed';
  lisToolHeaderScrolledUp = 'Tool Header: Scrolled up';
  dlgSubPropColor = 'SubProperties';
  dlgReferenceColor = 'Reference';
  lisAllBuildModes = '<All build modes>';
  lisNameOfActiveBuildMode = 'Name of active build mode';
  lisCaptionOfActiveBuildMode = 'Caption of active build mode';
  dlfReadOnlyColor = 'Read Only';
  dlgHighlightColor = 'Highlight Color';
  dlgHighlightFontColor = 'Highlight Font Color';
  dlgValueColor = 'Value';
  dlgDefValueColor = 'Default Value';
  dlgDifferentValueBackgroundColor = 'Different values background';
  dlgPropNameColor = 'Property Name';
  dlgGutterEdgeColor = 'Gutter Edge Color';

  dlgOIMiscellaneous = 'Miscellaneous';
  dlgOISpeedSettings = 'Speed settings';
  dlgOIItemHeight = 'Item height (0 = auto)';
  dlgHeightOfOnePropertyInGrid = 'Height of one property in the grid.';
  dlgOIUseDefaultLazarusSettings = 'Use default Lazarus settings';
  dlgOIUseDefaultDelphiSettings = 'Use default Delphi settings';
  lisShowComponentTreeInObjectInspector = 'Show component tree';
  lisShowsAllControlsInTreeHierarchy = 'Shows all controls in tree hierarchy.';
  lisShowHintsInObjectInspector = 'Show hints';
  lisHintAtPropertysNameShowsDescription = 'A hint at property''s name shows its description.';
  lisUseCheckboxForBooleanValues = 'Use CheckBox for Boolean values';
  lisDefaultIsComboboxWithTrueAndFalse = 'The default is ComboBox with "True" and "False" selections';
  lisAutoShowObjectInspector = 'Auto show';
  lisObjectInspectorBecomesVisible = 'Object Inspector becomes visible '
    +'when components are selected in designer.';
  lisBoldNonDefaultObjectInspector = 'Bold non default values';
  lisValuesThatAreChangedFromDefault = 'Values that are changed from the default '
    +'are stored in .lfm file and are shown differently in Object Inspector.';
  lisDrawGridLinesObjectInspector = 'Draw grid lines';
  lisHorizontalLinesBetweenProperties = 'Horizontal lines between properties.';
  lisShowGutterInObjectInspector = 'Show gutter';
  lisShowStatusBarInObjectInspector = 'Show statusbar';
  lisStatusBarShowsPropertysNameAndClass = 'Statusbar shows the property''s '
    +'name and the class where it is published.';
  lisShowInfoBoxInObjectInspector = 'Show information box';
  lisShowsDescriptionForSelectedProperty = 'A box at the bottom shows '
    +'description for the selected property.';
  lisShowPropertyFilterInObjectInspector = 'Show property filter';

  dlgEnvBackupHelpNote = 'Notes: Project files are all files in the project directory';
  lisEnvOptDlgInvalidDebuggerFilename = 'Invalid debugger filename';
  lisEnvOptDlgInvalidDebuggerFilenameMsg = 'The debugger file "%s" is not an executable.';
  lisDirectoryNotFound = 'Directory "%s" not found.';
  lisRemoveFromSearchPath = 'Remove from search path';
  lisEnvOptDlgTestDirNotFoundMsg = 'Test directory "%s" not found.';

  // Ide Startup options
  dlgFileAssociationInOS = 'Opening Files from OS';
  dlgLazarusInstances = 'Lazarus instances';
  dlgMultipleInstances_AlwaysStartNew = 'always start a new instance';
  dlgMultipleInstances_OpenFilesInRunning = 'open files in a running instance';
  dlgMultipleInstances_ForceSingleInstance = 'do not allow multiple instances';
  dlgRunningInstanceModalError = 'The running Lazarus instance cannot accept any files.'
    +sLineBreak+'Do you want to open them in a new IDE instance?'+sLineBreak+sLineBreak+'%s';
  dlgForceUniqueInstanceModalError = 'The running Lazarus instance cannot accept any files.';
  dlgRunningInstanceNotRespondingError = 'Lazarus instance is running but not responding.';
  dlgProjectToOpenOrCreate = 'Project to Open or Create';
  dlgQOpenLastPrj = 'Open last project and packages at start';
  dlgNewProjectType = 'New Project Type';
  lisInitialChecks = 'Initial Checks';
  lisQuickCheckFppkgConfigurationAtStart = 'Quick check Fppkg configuration at'
    +' start';

  lisConfirmReplace = 'Confirm Replace';
  lisAlreadyContainsTheHe = '%s already contains the help:'+LineEnding+'%s';
  lisInvalidDeclaration = 'Invalid Declaration';
  lisPleasePlaceTheEditorCaretOnAnIdentifierIfThisIsANe = 'Please place the editor caret on an '
    +'identifier. If this is a new unit, please save the file first.';

  // open-dialog filters
  dlgFilterAll = 'All files';
  dlgFilterXML = 'XML files';
  dlgFilterHTML = 'HTML files';
  dlgFilterPrograms = 'Programs';
  dlgFilterExecutable = 'Executable';
  dlgFilterLazarusFile = 'Lazarus file';
  dlgFilterLazarusEditorFile = 'Editor file types';
  dlgFilterLazarusUnit = 'Lazarus unit';
  dlgFilterLazarusInclude = 'Lazarus include file';
  dlgFilterLazarusProject = 'Lazarus project';
  dlgFilterLazarusForm = 'Lazarus form';
  dlgFilterLazarusPackage = 'Lazarus package';
  dlgFilterLazarusProjectSource = 'Lazarus project source';
  dlgFilterLazarusOtherFile = 'Lazarus other file';
  dlgFilterLazarusSession = 'Lazarus session';
  dlgFilterLazarusDesktopSettings = 'Lazarus Desktop Settings';
  dlgFilterDelphiUnit = 'Delphi unit';
  dlgFilterDelphiProject = 'Delphi project';
  dlgFilterDelphiPackage = 'Delphi package';
  dlgFilterDelphiForm = 'Delphi form';
  dlgFilterPascalFile = 'Pascal file';
  dlgFilterDciFile = 'DCI file';
  dlgFilterFPCMessageFile = 'FPC message file';
  dlgFilterFppkgConfigurationFile = 'Fppkg configuration file';
  dlgFilterCodetoolsTemplateFile = 'CodeTools template file';
  dlgFilterImagesPng = 'PNG images';
  dlgFilterImagesBitmap = 'Bitmap images';
  dlgFilterImagesPixmap = 'Pixmap images';
  dlgFilterPackageListFiles = 'Package list files';

  // editor options
  dlgEdMisc = 'Miscellaneous';
  dlgEdTabIndent = 'Tab and Indent';
  dlgEdDisplay = 'Display';
  dlgKeyMapping = 'Key Mappings';
  dlgKeyMappingErrors = 'Key mapping errors';
  dlgEdBack = 'Back';
  dlgReport = 'Report';
  dlgDelTemplate = 'Delete template ';
  dlgChsCodeTempl = 'Choose code template file (*.dci)';
  lisPkgMgrNew = 'new';
  lisUninstallFail = 'Uninstall failed';
  lisThePackageIsUsedBy = 'The package "%s" is used by';
  lisUninstallThemToo = 'Uninstall them too';
  lisPkgMgrRemove = 'remove';
  lisPkgMgrKeep = 'keep';
  lisConfirmNewPackageSetForTheIDE = 'Confirm new package set for the IDE';
  lisConfirmPackageNewPackageSet = 'New package set';
  lisConfirmPackageOldPackageSet = 'Old package set';
  lisConfirmPackageAction = 'Action';
  lisOpenExistingFile = 'Open existing file';

  dlgUndoGroupOptions = 'Undo / Redo';
  dlgScrollGroupOptions = 'Scrolling';
  dlgCommentIndentGroupOptions = 'Comments and Strings';
  dlgCaretGroupOptions = 'Caret (Text Cursor)';
  dlgCaretScrollGroupOptions = 'Caret (Text Cursor) past end of line';
  dlgMultiCaretGroupOptions = 'Multi-caret';
  dlgBlockGroupOptions = 'Selection';
  dlgAlwaysVisibleCursor = 'Always keep caret in visible area of editor';
  dlgAutoHideCursor  = 'Hide mouse pointer when typing';
  dlgGroupUndo = 'Group Undo';
  dlgHalfPageScroll = 'Half page scroll';
  dlgKeepCursorX = 'Keep caret X position when navigating up/down';
  dlgPersistentCursor = 'Visible caret in unfocused editor';
  dlgPersistentCursorNoBlink = 'Caret in unfocused editor does not blink';
  dlgPersistentBlock = 'Persistent block';
  dlgOverwriteBlock = 'Overwrite block';
  dlgCursorSkipsSelection = 'Caret skips selection';
  dlgCursorMoveClearsSelection = 'Caret left/right clears selection (no move)';
  dlgCursorSkipsTab = 'Caret skips tabs';
  dlgScrollByOneLess = 'Scroll by one less';
  dlgScrollPastEndFile = 'Scroll past end of file';
  dlgScrollPastEndLine = 'Allow Caret to move past the end of line';
  dlgScrollBarPastEOLNone = 'Do not add any permanent space to horizontal scroll range';
  dlgScrollBarPastEOLPage = 'Always add one page to horizontal scroll range';
  dlgScrollBarPastEOLFixed = 'Force 1024 columns minimum for horizontal scroll range';
  dlgScrollHint = 'Show scroll hint';
  lisShowSpecialCharacters = 'Show special characters';
  dlgCloseButtonsNotebook = 'Show close buttons in notebook';
  dlgMiddleTabCloseOtherPagesMod = 'Middle-click-modifier to close all other tabs';
  dlgMiddleTabCloseRightPagesMod = 'Middle-click-modifier to close tabs on the right';
  dlgShowFileNameInCaption = 'Show file name in caption';
  dlgSourceEditTabMultiLine = 'Multiline tabs';
  dlgHideSingleTabInNotebook = 'Hide tab in single page windows';
  dlgTabNumbersNotebook = 'Show tab numbers in notebook';
  dlgNotebookTabPos = 'Source notebook tabs position';
  lisNotebookTabPosTop = 'Top';
  lisNotebookTabPosBottom = 'Bottom';
  lisNotebookTabPosLeft = 'Left';
  lisNotebookTabPosRight = 'Right';
  dlgUseTabsHistory = 'Use tab history when closing tabs';
  dlgShowGutterHints = 'Show gutter hints';
  dlgTrimTrailingSpaces = 'Trim trailing spaces';
  dlgAnsiCommentTab = 'ANSI (* *)';
  dlgCurlyCommentTab = 'Curly { }';
  dlgSlashCommentTab = 'Slash //';
  dlgStringBreakIndentTab = 'String ''''';

  // Tab & Indent
  dlgIndentsTabsWidthsOptions = 'Tabs widths (Tab stop position)';
  dlgIndentsTabsKeyOptions    = 'Tab key';
  dlgIndentsTabIndentGroupOptions = 'Indent (Tab key on Selection)';
  dlgIndentsLineIndentGroupOptions = 'Indent (New line)';

  dlgTabWidths         = 'Tab widths';
  dlgElasticTabs       = 'Elastic tabstops';
  dlgElasticTabsWidths = 'Elastic min Widths';

  dlgTabsToSpaces = 'Tabs to spaces';
  dlgSmartTabs    = 'Smart tabs';

  dlgTabIndent               = 'Tab indents blocks';
  dlgBlockIndentSpaces       = 'Amount of spaces';
  dlgBlockIndentTabs         = 'Amount of tabs (tab stops)';
  dlgBlockIndentTabs2Spaces  = 'Amount of spaces (tab stops)';
  dlgBlockIndentKeys         = 'Block indent';
  dlgBlockIndentLink         = '(edit keys)';
  dlgBlockIndentTypeSpace    = 'Spaces';
  dlgBlockIndentTypeCopy     = 'Space/tab as prev Line';
  dlgBlockIndentTypePos      = 'Position only';
  dlgBlockIndentTypeTabSpace = 'Tabs, then spaces';
  dlgBlockIndentTypeTabOnly  = 'Tabs, cut off';

  dlgAutoIndent     = 'Auto indent';
  dlgAutoIndentLink = '(Set up smart indent)';

  dlgCommentContinue = 'Prefix comments on linebreak';
  dlgCommentContinueMatch  = 'Match current line';
  dlgCommentContinuePrefix = 'Prefix new line';
  dlgCommentAlignMaxDefault = 'Max indent for new line if prefix is based on start of comment on first comment line:';
  dlgCommentAlignMaxToken   = 'Limit indent to';
  dlgCommentContinueMatchText = 'Match text after token "%s"';
  dlgCommentContinueMatchToken = 'Match text including token "%s"';
  dlgCommentContinueMatchLine = 'Match whole line';
  dlgCommentContinueMatchAsterisk = 'Match text including "*" of token "(*"';
  dlgCommentContinuePrefixIndDefault = 'Align Prefix at indent of previous line';
  dlgCommentContinuePrefixIndMatch = 'Align Prefix below start of comment on first comment line';
  dlgCommentContinuePrefixIndNone = 'Do not indent prefix';
  dlgCommentShlashExtendMatch = 'Extend if matched';
  dlgCommentShlashExtendMatchSplit = 'Extend if matched and caret in the middle of text (not at EOL)';
  dlgCommentShlashExtendAlways = 'Extend if matched or not matched';
  dlgCommentShlashExtendAlwaysSplit = 'Extend if matched or not matched (not at EOL)';
  dlgStringEnableAutoContinue = 'Extend strings on linebreak';
  dlgStringAutoAppend = 'Append text to close string';
  dlgStringAutoPrefix = 'Prefix string on new line';
  dlgStringContAlignAlignSecondLineRegEx = 'Align second line (reg-ex):';
  dlgStringContAlignMaxIndentForSecondLineIfB = 'Max indent for second line if based on reg-ex:';
  dlgStringContAlignAlignSecondLineAfterFirst = 'Align second line (after first break) with the '
    +'position of the lowest matching group in the pattern, or the match position of the pattern '
    +'itself.';

  dlgUndoAfterSave = 'Undo after save';
  dlgFindTextatCursor = 'Find text at cursor';
  dlgUseHighlight = 'Use Highlight';
  dlgUseSyntaxHighlight = 'Use syntax highlight';
  dlgUseCodeFolding = 'Code Folding';
  dlgCodeFoldEnableFold = 'Fold';
  dlgCodeFoldEnableHide = 'Hide';
  dlgCodeFoldEnableBoth = 'Both';
  dlgCodeFoldPopUpOrder = 'Reverse fold-order in Popup';

  dlgOptWordWrap = 'Word-wrap';
  dlgOptWordWrapUseWordwrap = 'Use Word-wrap';
  dlgOptWordWrapAllHL = 'Select all';
  dlgOptWordWrapNoneHL = 'Clear selection';
  dlgOptWordWrapDisplayCaretAtWrapPositio = 'Display caret at wrap-position...';
  dlgOptWordWrapEndOfLine = 'end of line';
  dlgOptWordWrapStartOfNextLine = 'start of next line';
  dlgOptWordWrapHomeEndKey = 'Force default home/end keys to subline start/end';
  dlgOptWordWrapSectionColumn = 'Wrap column settings';
  dlgOptWordWrapCheckFixedLength = 'Wrap at fixed column';
  dlgOptWordWrapFixedLineLength = 'Fixed line length';
  dlgOptWordWrapMinimumLineLength = 'Minimum line length';
  dlgOptWordWrapMaximumLineLength = 'Maximum line length';
  dlgOptWordWrapSectionIndent = 'Indent settings';
  dlgOptWordWrapIndent = 'Indent width';
  dlgOptWordWrapIndentIsOffset = 'Indent relative to text';
  dlgOptWordWrapIndentMin = 'Minimum indent width';
  dlgOptWordWrapIndentMax = 'Maximum indent width';
  dlgOptWordWrapIndentMaxRel = 'Maximum indent width (percent)';

  dlfMousePredefinedScheme = 'Use predefined scheme';
  dlfNoPredefinedScheme = '< None >';
  dlfMouseSimpleGenericSect = 'General';
  dlfMouseSimpleGutterSect = 'Gutter';
  dlfMouseSimpleGutterLeftDown = 'Standard, All actions (breakpoint, fold) on mouse down';
  dlfMouseSimpleGutterLeftUp = 'Extended, Actions (breakpoint, fold) on mouse up. Selection on mouse down and move';
  dlfMouseSimpleGutterLeftUpRight = 'Extended, Actions, right gutter half only';
  dlfMouseSimpleGutterLines = 'Use line numbers to select lines';
  dlfMouseSimpleTextSect = 'Text';
  dlfMouseSimpleTextSectDrag = 'Drag selection (copy/paste)';
  dlfMouseSimpleRightMoveCaret = 'Right button click includes caret move';
  dlfMouseSimpleTextSectMidLabel = 'Middle Button';
  dlfMouseSimpleTextSectWheelLabel = 'Wheel';
  dlfMouseSimpleTextSectRightLabel = 'Right Button';
  dlfMouseSimpleTextSectExtra1Label = 'Extra-1 Button';
  dlfMouseSimpleTextSectExtra2Label = 'Extra-2 Button';
  dlfMouseSimpleTextSectCtrlWheelLabel = 'Ctrl Wheel';
  dlfMouseSimpleTextSectAltWheelLabel = 'Alt Wheel';
  dlfMouseSimpleTextShiftSectWheelLabel = 'Shift Wheel';
  dlfMouseSimpleTextSectAltCtrlWheelLabel = 'Alt-Ctrl Wheel';
  dlfMouseSimpleTextSectShiftAltWheelLabel = 'Shift-Alt Wheel';
  dlfMouseSimpleTextSectShiftCtrlWheelLabel = 'Shift-Ctrl Wheel';
  dlfMouseSimpleTextSectShiftAltCtrlWheelLabel = 'Shift-Alt-Ctrl';

  dlfMouseSimpleTextSectPageLMod = 'Left 1';
  dlfMouseSimpleTextSectPageLMulti = 'Left 2';
  dlfMouseSimpleTextSectPageBtn = 'Middle';
  dlfMouseSimpleTextSectPageWheel = 'Wheel';
  dlfMouseSimpleTextSectPageHorizWheel = 'Horizontal-Wheel';
  dlfMouseSimpleTextSectPageRight = 'Right';
  dlfMouseSimpleTextSectPageExtra1 = 'Extra 1';
  dlfMouseSimpleTextSectPageExtra2 = 'Extra 2';

  dlfMouseSimpleTextSectLDoubleLabel      = 'Double';
  dlfMouseSimpleTextSectLTripleLabel      = 'Triple';
  dlfMouseSimpleTextSectLQuadLabel        = 'Quad';
  dlfMouseSimpleTextSectLDoubleShiftLabel = 'Shift Double';
  dlfMouseSimpleTextSectLDoubleAltLabel   = 'Alt Double';
  dlfMouseSimpleTextSectLDoubleCtrlLabel  = 'Ctrl Double';
  dlfMouseSimpleTextSectShiftLabel        = 'Shift Button';
  dlfMouseSimpleTextSectAltLabel          = 'Alt Button';
  dlfMouseSimpleTextSectCtrlLabel         = 'Ctrl Button';
  dlfMouseSimpleTextSectAltCtrlLabel      = 'Alt-Ctrl Button';
  dlfMouseSimpleTextSectShiftAltLabel     = 'Shift-Alt Button';
  dlfMouseSimpleTextSectShiftCtrlLabel    = 'Shift-Ctrl Button';
  dlfMouseSimpleTextSectShiftAltCtrlLabel = 'Shift-Alt-Ctrl Button';

  dlfMouseSimpleButtonNothing          = 'Nothing/Default';
  dlfMouseSimpleButtonSelContinuePlain = 'Continue %0:s';
  dlfMouseSimpleButtonSelContinue      = 'Continue %0:s (Bound to: %1:s)';
  dlfMouseSimpleButtonSelect           = 'Select text';
  dlfMouseSimpleButtonSelectColumn     = 'Select text (Column mode)';
  dlfMouseSimpleButtonSelectLine       = 'Select text (Line mode)';
  dlfMouseSimpleButtonSelectByToken    = 'Select text (tokens)';
  dlfMouseSimpleButtonSelectByWord     = 'Select text (words)';
  dlfMouseSimpleButtonSelectByLine     = 'Select text (lines)';
  dlfMouseSimpleButtonSetWord          = 'Select current Word';
  dlfMouseSimpleButtonSetLineSmart     = 'Select current Line (Text)';
  dlfMouseSimpleButtonSetLineFull      = 'Select current Line (Full)';
  dlfMouseSimpleButtonSetPara          = 'Select current Paragraph';
  dlfMouseSimpleButtonPaste            = 'Paste';
  dlfMouseSimpleButtonDeclaration      = 'Jumps to implementation';
  dlfMouseSimpleButtonDeclarationBlock = 'Jumps to implementation/other block end';
  dlfMouseSimpleButtonAddHistoryPoint  = 'Add history point';
  dlfMouseSimpleButtonHistBack = 'History back';
  dlfMouseSimpleButtonHistForw = 'History forward';
  dlfMouseSimpleButtonSetFreeBookmark  = 'Set a free bookmark';
  dlfMouseSimpleButtonZoomReset        = 'Reset zoom';
  dlfMouseSimpleButtonContextMenu      = 'Context Menu';
  dlfMouseSimpleButtonContextMenuDbg   = 'Context Menu (debug)';
  dlfMouseSimpleButtonContextMenuTab   = 'Context Menu (tab)';
  dlfMouseSimpleButtonMultiCaretToggle = 'Toggle extra Caret';

  dlfMouseSimpleWheelNothing           = 'Nothing/Default';
  dlfMouseSimpleWheelSrollDef          = 'Scroll (System speed)';
  dlfMouseSimpleWheelSrollLine         = 'Scroll (Single line)';
  dlfMouseSimpleWheelSrollPage         = 'Scroll (Page)';
  dlfMouseSimpleWheelSrollPageLess     = 'Scroll (Page, less one line)';
  dlfMouseSimpleWheelSrollPageHalf     = 'Scroll (Half page)';
  dlfMouseSimpleWheelHSrollDef         = 'Scroll horizontal (System speed)';
  dlfMouseSimpleWheelHSrollLine        = 'Scroll horizontal (Single line)';
  dlfMouseSimpleWheelHSrollPage        = 'Scroll horizontal (Page)';
  dlfMouseSimpleWheelHSrollPageLess    = 'Scroll horizontal (Page, less one line)';
  dlfMouseSimpleWheelHSrollPageHalf    = 'Scroll horizontal (Half page)';
  dlfMouseSimpleWheelZoom              = 'Zoom';

  dlfMouseSimpleWarning = 'You have unsaved changes. Using this page will undo changes made on the advanced page';
  dlfMouseSimpleDiff = 'This page does not represent your current settings. See advanced page. Use this page to reset any advanced changes';
  dlfMouseResetAll = 'Reset all settings';
  dlfMouseResetText = 'Reset all text settings';
  dlfMouseResetGutter = 'Reset all gutter settings';

  dlgMouseOptions = 'Mouse';
  dlgMouseOptionsAdv = 'Advanced';
  dlgMouseOptNodeAll = 'All';
  dlgMouseOptNodeMain = 'Text';
  dlgMouseOptNodeSelect = 'Selection';
  dlgMouseOptNodeGutter = 'Gutter';
  dlgMouseOptNodeGutterFold = 'Fold Tree';
  dlgMouseOptNodeGutterFoldCol = 'Collapsed [+]';
  dlgMouseOptNodeGutterFoldExp = 'Expanded [-]';
  dlgMouseOptNodeGutterLines = 'Line Numbers';
  dlgMouseOptNodeGutterChanges = 'Line Changes';
  dlgMouseOptNodeGutterLineOverview = 'Overview';
  dlgMouseOptNodeGutterLineOverviewMarks = 'Overview Mark';
  dlgMouseOptHeadOrder = 'Order';
  dlgMouseOptHeadContext = 'Context';
  dlgMouseOptHeadDesc = 'Action';
  dlgMouseOptHeadBtn = 'Button';
  dlgMouseOptHeadCount = 'Click';
  dlgMouseOptHeadDir = 'Up/Down';
  dlgMouseOptHeadShift = 'Shift';
  dlgMouseOptHeadAlt = 'Alt';
  dlgMouseOptHeadCtrl = 'Ctrl';
  dlgMouseOptHeadCaret = 'Caret';
  dlgMouseOptHeadPriority = 'Priority';
  dlgMouseOptHeadOpt = 'Option';
  dlgMouseOptBtnLeft   = 'Left';
  dlgMouseOptBtnMiddle = 'Middle';
  dlgMouseOptBtnRight  = 'Right';
  dlgMouseOptBtnExtra1 = 'Extra 1';
  dlgMouseOptBtnExtra2 = 'Extra 2';
  dlgMouseOptBtnWheelUp = 'Wheel up';
  dlgMouseOptBtnWheelDown = 'Wheel down';
  dlgMouseOptBtnWheelLeft = 'Wheel left';
  dlgMouseOptBtnWheelRight = 'Wheel right';
  dlgMouseOptBtn1   = 'Single';
  dlgMouseOptBtn2   = 'Double';
  dlgMouseOptBtn3   = 'Triple';
  dlgMouseOptBtn4   = 'Quad';
  dlgMouseOptBtnAny = 'Any';
  dlgMouseOptMoveMouseTrue   = 'Y';
  dlgMouseOptMoveMouseFalse  = '';
  dlgMouseOptModKeyFalse   = 'n';
  dlgMouseOptModKeyTrue    = 'Y';
  dlgMouseOptModKeyIgnore  = '-';
  dlgMouseOptCheckUpDown   = 'Act on Mouse up';
  dlgMouseOptModShift = 'Shift';
  dlgMouseOptModAlt   = 'Alt';
  dlgMouseOptModCtrl  = 'Ctrl';
  dlgMouseOptOtherAct  = 'Other actions using the same button';
  dlgMouseOptOtherActHint  = 'They may be executed depending on the Modifier Keys, Fallthrough settings, Single/Double, Up/Down ...';
  dlgMouseOptOtherActToggle = 'Filter Mod-Keys';
  lisDoNotShowThisMessageAgain = 'Do not show this message again';
  dlgMouseOptBtnModDef = 'Make Fallback';
  dlgMouseOptPriorLabel = 'Priority';
  dlgMouseOptOpt2Label = 'Opt';
  dlgMouseOptDlgTitle = 'Edit Mouse';
  dlgMouseOptCapture = 'Capture';
  dlgMouseOptCaretMove = 'Move Caret (extra)';
  dlgMouseOptErrorDup = 'Duplicate Entry';
  dlgMouseOptErrorDupText = 'This entry conflicts with an existing entry';
  dlgMouseOptDescAction = 'Action';
  dlgMouseOptDescButton = 'Click';
  dlgMouseOptionsynCommand = 'IDE-Command';
  dlgUseDividerDraw = 'Divider Drawing';
  dlgEditorOptions = 'Editor options';
  dlgCopyWordAtCursorOnCopyNone = 'Copy current word when no selection exists';
  dlgHomeKeyJumpsToNearestStart = 'Home key jumps to nearest start';
  dlgEndKeyJumpsToNearestStart = 'End key jumps to nearest end';
  dlgSelectAllNoScroll = 'Do not scroll on Select-All / Paragraph or To-Brace';
  dlgMultiCaretOnColumnSelection = 'Enable multi-caret for column selection';
  dlgMultiCaretColumnMode = 'Navigation keys move all carets (column-select)';
  dlgMultiCaretMode = 'Navigation keys move all carets';
  dlgMultiCaretDelSkipCr = 'Skip delete key at EOL (do not join lines)';
  dlgColorLink = '(Edit Color)';
  dlgEditMaxLength = '(Edit Max Length)';
  dlgKeyLink = '(Edit Key)';
  dlgBracketHighlight = 'Bracket highlight';
  dlgNoBracketHighlight = 'No Highlight';
  dlgHighlightLeftOfCursor = 'Left Of Caret';
  dlgHighlightRightOfCursor = 'Right Of Caret';
  gldHighlightBothSidesOfCursor = 'On Both Sides';
  dlgTrimSpaceTypeCaption = 'Trim spaces style';
  dlgTrimSpaceTypeLeaveLine = 'Leave line';
  dlgTrimSpaceTypeEditLine = 'Line Edited';
  dlgTrimSpaceTypeCaretMove = 'Caret or Edit';
  dlgTrimSpaceTypePosOnly = 'Position Only';
  dlgCopyPasteKeepFolds = 'Copy/Paste with fold info';
  dlgUseMinimumIme = 'IME handled by System';
  dlgEditExportBackColor = 'Use Background color in HTML export';
  dlgBookmarkSetScroll = 'Restore scroll position for bookmarks';
  dlgUndoLimit = 'Undo limit';
  dlgMarginGutter = 'Margin and gutter';
  dlgVisibleRightMargin = 'Visible right margin';
  dlgVisibleGutter = 'Visible gutter';
  dlgGutterSeparatorIndex = 'Gutter separator index';
  dlgShowLineNumbers = 'Show line numbers';
  dlgShowCompilingLineNumbers = 'Show line numbers';
  dlgRightMargin = 'Right margin';
  dlgGutter = 'Gutter';
  dlgGutterColor = 'Gutter Color';
  dlgDefaultEditorFont='Default editor font';
  dlgEditorFontSize = 'Editor font size';
  dlgDefaultTabFont='Default tab font';
  dlgExtraCharSpacing = 'Extra character spacing';
  dlgExtraLineSpacing = 'Extra line spacing';
  dlgDisableAntialiasing = 'Disable anti-aliasing';
  lisEdOptsLoadAScheme = 'Load a scheme';
  lisFindKeyCombination = 'Find key combination';
  lisSelectedCommandsMapping = 'Selected Command''s Mapping';
  lisNowLoadedScheme = 'Now loaded: ';
  dlgLang = 'Language';
  dlgEditSchemDefaults = 'Scheme globals';
  lis0No1DrawDividerLinesOnlyForTopLevel2DrawLinesForFi = '0 = no, 1 = draw '
    +'divider lines only for top level, 2 = draw lines for first two levels, ...';
  dlgClrScheme = 'Color Scheme';
  dlgFileExts = 'File extensions';
  dlgSetElementDefault = 'Set element to default';
  dlgSetAllElementDefault = 'Set all elements to default';
  dlgReset = 'Reset';
  dlgResetAll = 'Reset all';
  dlgThisElementUsesColor = 'The element uses (and edits) the schemes:';
  dlgUseSchemeDefaults = '- Scheme globals -';
  dlgUseSchemeLocal    = 'selected language';
  dlgColors = 'Colors';
  dlgColorsTml = 'TML Setup';
  dlgColorsTmlRefresh = 'Reload';
  dlgColorsTmlInfo = 'Below is a list of Highlighter (Textmate) found in the folder %1:s.%0:s' +
    'This list may include files with errors and files not yet active in the IDE.%0:s' +
    'To activate newly added/changed files restart the IDE.%0:s' +
    'The "Reload" button will update the list below, checking if any errors were fixed.';
  dlgColorsTmlNoFilesFound = 'No files found.';
  dlgColorsTmlMissingInclude = 'Did not find all includes: %1:s';
  dlgColorsTmlFromFile = 'File:';
  dlgColorsTmlNoSampleTxt = 'No sample text configured';
  dlgColorsTmlBadSampleTxtFile = 'Sample text file not found: %1:s';
  dlgColorsTmlOk = 'OK';
  dlgColorsTmlError = 'Error:';
  lisHeaderColors = 'Header colors';
  lisMsgColors = 'Message colors';
  lisSetAllColors = 'Set all colors:';
  lisLazarusDefault = 'Lazarus Default';
  dlgColorNotModified = 'Not modified';
  dlgPriorities = 'Priorities';

  dlgMsgWinColorUrgentNone      = 'Normal';
  dlgMsgWinColorUrgentProgress  = 'Time and statistics';
  dlgMsgWinColorUrgentDebug     = 'Debug';
  dlgMsgWinColorUrgentVerbose3  = 'Verbose 3';
  dlgMsgWinColorUrgentVerbose2  = 'Verbose 2';
  dlgMsgWinColorUrgentVerbose   = 'Verbose';
  dlgMsgWinColorUrgentHint      = 'Hint';
  dlgMsgWinColorUrgentNote      = 'Note';
  dlgMsgWinColorUrgentWarning   = 'Warning';
  lisPackageIsDesigntimeOnlySoItShouldOnlyBeCompiledInt = 'Package "%s" is '
    +'designtime only, so it should only be compiled into the IDE, and not '
    +'with the project settings.%sPlease use "Install" or "Tools / Build '
    +'Lazarus" to build the IDE packages.';
  lisCompileWithProjectSettings = 'Compile with project settings';
  lisCompileAndDoNotAskAgain = 'Compile and do not ask again';
  dlgMsgWinColorUrgentImportant = 'Important';
  dlgMsgWinColorUrgentError     = 'Error';
  dlgMsgWinColorUrgentFatal     = 'Fatal';
  dlgMsgWinColorUrgentPanic     = 'Panic';

  dlgForecolor = 'Foreground';
  dlgFrameColor = 'Text-mark';
  dlgMarkupFoldColor = 'Vertical-mark';
  dlgTextStyle = 'Text-Style';
  dlgUnsavedLineColor = 'Unsaved line';
  dlgSavedLineColor = 'Saved line';
  dlgColorFeatPastEol        = 'Extend past EOL';
  dlgGutterCollapsedColor = 'Collapsed';
  dlgCaretForeColor = 'Main or primary caret';
  dlgCaretBackColor = 'Secondary carets (multi-caret mode)';
  dlgCaretColorInfo = 'The caret color depends on the colors of text and background under the caret. '
    + 'Each pixel''s RGB are bitwise inverted and XOR''ed with the chosen color''s RGB.';
  dlgOverviewGutterBack1Color = 'Background 1';
  dlgOverviewGutterBack2Color = 'Background 2';
  dlgOverviewGutterPageColor = 'Page';
  dlgElementAttributes = 'Element Attributes';
  dlgEdBold = 'Bold';
  dlgEdItal = 'Italic';
  dlgEdUnder = 'Underline';
  dlgEdOn = 'On';
  dlgEdOff = 'Off';
  dlgEdInvert = 'Invert';
  dlgEdIdComlet = 'Identifier completion';
  dlgEdCompleteBlocks = 'Add close statement for Pascal blocks';
  lisShowValueHintsWhileDebugging = 'Show value hints while debugging';
  lisDebugHintAutoTypeCastClass = 'Automatic typecast for objects';
  dlgMarkupGroup = 'Highlight all occurrences of Word under Caret';
  dlgBracketMatchGroup = 'Matching bracket and quote pairs';
  dlgPasExtHighlightGroup = 'Extended Pascal Highlight Options';
  dlgPasKeywordsMatches = 'Matching Keywords';
  dlgPasKeywordsMarkup = 'Markup (on caret)';
  dlgPasKeywordsOutline = 'Outline';
  dlgMarkupWordBracket = 'Keyword brackets on caret (global)';
  dlgMarkupOutline = 'Outline (global)';
  dlgMarkupOutlineWarnNoColor = 'Warning: There are no colors configured for the selected language';
  dlgPasExtKeywords = 'Highlight flow control statements (break, continue, exit) as keywords';
  dlgPasCaseLabelForOtherwise = 'Color otherwise/else as case-label';
  dlgPasDeclaredTypeAttrMode = 'Extend of type-highlight in declarations';
  dlgPasDeclaredTypeValueMode = 'Extend of initial-value-highlight in declarations';
  dlgPasDeclaredTypeValueModeLiteral = 'Include literals (Number, String) in initial-value-highlight in declarations';
  dlgPasDeclaredTypeAttrModeIdent = 'Identifier only';
  dlgPasDeclaredTypeAttrModeNames = 'Identifier and built-in (types/values)';
  dlgPasDeclaredTypeAttrModeKeywords = 'Identifier, built-in and keywords';
  dlgPasDeclaredTypeAttrModeKeyAndSym = 'All, including symbols';

  dlgPasStringKeywords = 'Highlight "String" types as keyword';
  dlgPasStringKeywordsOptDefault = 'Default';
  dlgPasStringKeywordsOptString = 'Only "String"';
  dlgPasStringKeywordsOptNone = 'None';
  dlgMarkupWordFullLen = 'Match whole words, if length is less or equal to:';
  dlgMarkupWordNoKeyword = 'Ignore keywords';
  dlgMarkupWordTrim = 'Trim spaces (when highlighting current selection)';
  dlgMarkupWordOnCaretMove = 'Automatically markup current word on caret move';
  dlgMarkupWordKeyCombo = 'Markup current word by key: %s';
  dlgAutoRemoveEmptyMethods = 'Auto remove empty methods';
  dlgAutoDisplayFuncProto = 'Auto Display Function Prototypes';
  lisShowDeclarationHints = 'Show declaration hints';
  dlgMarkupCurrentWordDelayInSec = '(%s sec delay after caret move)';
  dlgEdDelayInSec = '(%s sec delay)';
  lisDelayForCompletionBox = 'Delay for completion box';
  lisDelayForHints = 'Delay for hints';
  lisDelayForCompletionLongLineHint = 'Delay for long line hints in completion box';
  lisCompletionLongLineHintType = 'Show long line hints';
  lisCompletionLongLineHintTypeNone = 'Never';
  lisCompletionLongLineHintTypeRightOnly = 'Extend right only';
  lisCompletionLongLineHintTypeLittleLeft = 'Extend some left';
  lisCompletionLongLineHintTypeFullLeft = 'Extend far left';
  dlgIncludeIdentifiersContainingPrefix = 'Include identifiers containing prefix';
  lisAutomaticFeatures = 'Completion and Hints';
  lisAutoMarkup = 'Markup and Matches';
  dlgUseIconsInCompletionBox = 'Icons in code completion box';
  dlgIncludeWordsToIdentCompl = 'Include words';
  dlgIncludeWordsToIdentCompl_IncludeFromAllUnits = 'from all units';
  dlgIncludeWordsToIdentCompl_IncludeFromCurrentUnit = 'from current unit';
  dlgIncludeWordsToIdentCompl_DontInclude = 'don''t include';
  dlgIncludeKeywordsToIdentCompl = 'Include all keywords and operators';
  dlgIncludeCodeTemplatesToIdentCompl = 'Include code templates';

  dlgMarkupUserDefined = 'User defined markup';
  dlgMarkupUserDefinedDivSelect = 'Create or Select list';
  dlgMarkupUserDefinedDivEdit   = 'Edit list';
  dlgMarkupUserDefinedNoLists = 'No lists';
  dlgMarkupUserDefinedNoListsSel = 'Select ...';
  dlgMarkupUserDefinedNewName = 'New list';
  dlgMarkupUserDefinedListNew = 'Add list';
  dlgMarkupUserDefinedListDel = 'Delete list';
  dlgMarkupUserDefinedPageMain = 'Main settings';
  dlgMarkupUserDefinedPageKeys = 'Key mappings';
  dlgMarkupUserDefinedMatchCase = 'Case sensitive';
  dlgMarkupUserDefinedMatchStartBound = 'Set bound at term start';
  dlgMarkupUserDefinedMatchEndBound = 'Set bound at term end';
  dlgMarkupUserDefinedDivKeyAdd = 'Add Word or Term by key';
  dlgMarkupUserDefinedDivKeyRemove = 'Remove Word or Term by key';
  dlgMarkupUserDefinedDivKeyToggle = 'Toggle Word or Term by key';
  dlgMarkupUserDefinedDelCaption = 'Delete';
  dlgMarkupUserDefinedDelPrompt = 'Delete list "%s"?';
  dlgMarkupUserDefinedListName = 'Name';
  dlgMarkupUserDefinedNewByKeyOpts = 'Settings for terms added by key';
  dlgMarkupUserDefinedNewByKeyLen = 'Ignore bounds for terms longer than';
  dlgMarkupUserDefinedNewByKeyLenWord = 'current word';
  dlgMarkupUserDefinedNewByKeyLenSelect = 'selection';
  dlgMarkupUserDefinedNewByKeySmartSelect = 'Smart match selection bounds';
  dlgMarkupUserDefinedGlobalList = 'Add/Remove in all editors';
  dlgMarkupUserDefinedDuplicate = 'Duplicate Term';
  dlgMarkupUserDefinedDuplicateMsg = 'The term %s already exists. Duplicates will be removed when the list is saved.';

  lisUserDefinedMarkupKeyGroup = 'User defined text markup';
  lisUserDefinedMarkupKeyAdd = 'Add to list "%s"';
  lisUserDefinedMarkupKeyRemove = 'Remove from list "%s"';
  lisUserDefinedMarkupKeyToggle = 'Toggle on list "%s"';

  dlgMultiWinOptions = 'Pages and Windows';
  dlgMultiWinTabGroup = 'Notebook Tabs';
  dlgMultiWinAccessGroup = 'Jump target priority between multiple editors';
  dlgMultiWinAccessOrder    = 'Order to use for editors matching the same criteria';
  dlgMultiWinAccessOrderEdit= 'Most recent focused editor for this file';
  dlgMultiWinAccessOrderWin = 'Editor (for file) in most recent focused window';
  dlgMultiWinAccessType     = 'Priority list of criteria to choose an editor:';

  dlgDividerDrawDepth       = 'Draw divider level';
  dlgDividerTopColor        = 'Line color';
  dlgDividerColorDefault    = 'Use right margin color';
  dlgDividerNestColor       = 'Nested line color';

  dlgDivPasUnitSectionName  = 'Unit sections';
  dlgDivPasUsesName         = 'Uses clause';
  dlgDivPasVarGlobalName    = 'Var/Type';
  dlgDivPasVarLocalName     = 'Var/Type (local)';
  dlgDivPasStructGlobalName = 'Class/Struct';
  dlgDivPasStructLocalName  = 'Class/Struct (local)';
  dlgDivPasProcedureName    = 'Procedure/Function';
  dlgDivPasBeginEndName     = 'Begin/End';
  dlgDivPasTryName          = 'Try/Except';

  dlgFoldPasBeginEnd        = 'Begin/End (nested)';
  dlgFoldPasProcBeginEnd    = 'Begin/End (procedure)';
  dlgFoldPasNestedComment   = 'Nested Comment';
  dlgFoldPasIfThen          = 'If/Then/Else';
  dlgFoldPasForDo           = 'For/Do';
  dlgFoldPasWhileDo         = 'While/Do';
  dlgFoldPasWithDo          = 'With/Do';
  dlgFoldPasProcedure       = 'Procedure';
  dlgFoldPasAnonProcedure   = 'Anonymous Procedure';
  dlgFoldPasUses            = 'Uses';
  dlgFoldPasVarType         = 'Var/Type (global)';
  dlgFoldLocalPasVarType    = 'Var/Type (local)';
  dlgFoldPasClass           = 'Class/Object';
  dlgFoldPasClassSection    = 'public/private';
  dlgFoldPasUnitSection     = 'Unit section';
  dlgFoldPasProgram         = 'Program';
  dlgFoldPasUnit            = 'Unit';
  dlgFoldPasRecord          = 'Record';
  dlgFoldPasRecordCase      = 'Record case';
  dlgFoldPasRecordCaseSect  = 'Record case section';
  dlgFoldPasTry             = 'Try';
  dlgFoldPasExcept          = 'Except/Finally';
  dlgFoldPasRepeat          = 'Repeat';
  dlgFoldPasCase            = 'Case';
  dlgFoldPasAsm             = 'Asm';
  dlgFoldPasIfDef           = '{$IfDef}';
  dlgFoldPasUserRegion      = '{%Region}';
  dlgFoldPasAnsiComment     = 'Comment (* *)';
  dlgFoldPasBorComment      = 'Comment { }';
  dlgFoldPasSlashComment    = 'Comment //';

  dlgFoldLfmObject      = 'Object (inherited, inline)';
  dlgFoldLfmList        = 'List <>';
  dlgFoldLfmItem        = 'Item';

  dlgFoldXmlNode        = 'Node';
  dlgFoldXmlComment     = 'Comment';
  dlgFoldXmlCData       = 'CData';
  dlgFoldXmlDocType     = 'DocType';
  dlgFoldXmlProcess     = 'Processing Instruction';

  dlgFoldHtmlNode        = 'Node';
  dlgFoldHtmlComment     = 'Comment';
  dlgFoldHtmlAsp         = 'ASP';

  dlgFoldDiffChunk     = 'Chunk';
  dlgFoldDiffChunkSect = 'Chunk section';

  dlgAddHiAttrDefault             = 'Default Text';
  dlgAddHiAttrTextBlock           = 'Selected text';
  dlgAddHiAttrExecutionPoint      = 'Execution point';
  dlgAddHiAttrEnabledBreakpoint   = 'Enabled breakpoint';
  dlgAddHiAttrDisabledBreakpoint  = 'Disabled breakpoint';
  dlgAddHiAttrInvalidBreakpoint   = 'Invalid breakpoint';
  dlgAddHiAttrUnknownBreakpoint   = 'Unknown breakpoint';
  dlgAddHiAttrErrorLine           = 'Error line';
  dlgAddHiAttrIncrementalSearch   = 'Incremental search';
  dlgAddHiAttrHighlightAll        = 'Incremental others';
  dlgAddHiAttrBracketMatch        = 'Brackets highlight';
  dlgAddHiAttrMouseLink           = 'Mouse link';
  dlgAddHiAttrLineNumber          = 'Line number';
  dlgAddHiAttrLineHighlight       = 'Current line highlight';
  dlgAddHiAttrModifiedLine        = 'Modified line';
  dlgAddHiAttrCodeFoldingTree     = 'Code folding tree';
  dlgAddHiAttrCodeFoldingTreeCur  = 'Code folding (current)';
  dlgAddHiAttrHighlightWord       = 'Highlight current word';
  dlgAddHiAttrFoldedCode          = 'Folded code marker';
  dlgAddHiAttrFoldedCodeLine      = 'Fold start-line';
  dlgAddHiAttrHiddenCodeLine      = 'Hide start-line';
  dlgAddHiAttrWordGroup           = 'Word-Brackets';
  dlgAddHiAttrTemplateEditCur     = 'Active Cell';
  dlgAddHiAttrTemplateEditSync    = 'Syncronized Cells';
  dlgAddHiAttrTemplateEditOther   = 'Other Cells';
  dlgAddHiAttrSyncroEditCur       = 'Active Cell';
  dlgAddHiAttrSyncroEditSync      = 'Syncronized Cells';
  dlgAddHiAttrSyncroEditOther     = 'Other Cells';
  dlgAddHiAttrSyncroEditArea      = 'Selected Area';
  dlgAddHiAttrGutterSeparator     = 'Gutter Separator';
  dlgAddHiAttrDefaultWindow       = 'Default Text / Window';
  dlgAddHiAttrRecentlyUsed        = 'Recently used item';
  dlgAddHiAttrWindowBorder        = 'Window border';
  dlgAddHiAttrHighlightPrefix     = 'Highlight prefix';
  dlgAddHiAttrOutlineLevelColor   = 'Level %s';
  dlgAddHiAttrWrapIndent  = 'Indent';
  dlgAddHiAttrWrapEol     = 'EOL';
  dlgAddHiAttrWrapSubLine = 'Sub-line';
  dlgAddHiSpecialVisibleChars     = 'Visualized Special Chars';
  dlgTopInfoHint                  = 'Current Class/Proc Hint';
  dlgCaretColor                   = 'Caret (Text-Cursor)';
  dlgOverviewGutterColor          = 'Overview Gutter';
  dlgGutterCurrentLineOther       = 'Current Line (other)';
  dlgGutterCurrentLineNumber      = 'Current Line (number)';
  dlgIfDefBlockInactive           = 'Inactive $IFDEF code';
  dlgIfDefBlockActive             = 'Active $IFDEF code';
  dlgIfDefBlockTmpActive          = 'Included mixed state $IFDEF code';
  dlgIfDefNodeInactive            = 'Inactive $IFDEF node';
  dlgIfDefNodeActive              = 'Active $IFDEF node';
  dlgIfDefNodeTmpActive           = 'Included mixed state $IFDEF node';
  dlgAddHiAttrCustom              = 'Custom %d';
  dlgAddHiAttrNestedBracket       = 'Nested bracket %d';

  dbgAsmWindowSourceLine          = 'Source line';
  dbgAsmWindowSourceFunc          = 'Function name';
  dbgAsmWindowLinkTarget          = 'Link target line';

  dlgAddHiAttrGroupDefault  = 'Global';
  dlgAddHiAttrGroupText     = 'Text';
  dlgAddHiAttrGroupLine     = 'Line';
  dlgAddHiAttrGroupGutter   = 'Gutter';
  dlgAddHiAttrGroupWrap     = 'Wrapping';
  dlgAddHiAttrGroupSyncroEdit    = 'Syncron Edit';
  dlgAddHiAttrGroupTemplateEdit  = 'Template Edit';
  dlgAddHiAttrGroupIfDef    = 'IfDef';
  dlgAddHiAttrGroupOutlineColors = 'Outline Colors';
  dlgAddHiAttrGroup_Suffix_Extended  = '(Extended)';
  dlgAddHiAttrGroup_Suffix_Custom  = '(Custom)';
  dlgAddHiAttrGroup_Suffix_NBrackets  = '(Nested Brackets)';
  dlgAddHiAttrGroup_Suffix_EntryType  = '(entry type)';
  dlgAddHiAttrGroup_Comment      = 'Comments';
  dlgAddHiAttrGroup_ProgHeader   = 'Procedure Header';
  dlgAddHiAttrGroup_DeclSection  = 'Declaration Blocks';


  dlgEditAccessCaptionLockedInView            = 'Locked, if text in view';
  dlgEditAccessCaptionUnLockedInSoftView      = 'Unlocked, if text in centered view';
  dlgEditAccessCaptionUnLocked                = 'Unlocked';
  dlgEditAccessCaptionUnLockedOpenNewInOldWin = 'New tab in existing window';
  dlgEditAccessCaptionUnLockedOpenNewInNewWin = 'New tab in new window';
  dlgEditAccessCaptionIgnLockedOldEdit        = 'Ignore Locks, use longest unused editor';
  dlgEditAccessCaptionIgnLockedOnlyActEdit    = 'Ignore Locks, if editor is current';
  dlgEditAccessCaptionIgnLockedOnlyActWin     = 'Ignore Locks, if editor in current window';
  dlgEditAccessCaptionUnLockedOpenNewInAnyWin = 'New tab, existing or new window';

  dlgEditAccessDescLockedInView =
    'This option will use a locked (and only a locked) Editor '+
    'which does not need to scroll in order to display the target jump point '+
    '(target jump point is already in visible screen area).';
  dlgEditAccessDescUnLockedInSoftView = 'This option will use a not locked Editor '+
    'which does not need to scroll in order to display the target jump point '+
    '(target jump point is already in visible screen center area, excluding 2-5 lines at the top/bottom).';
  dlgEditAccessDescUnLocked = 'This option will use any not locked Editor.';
  dlgEditAccessDescUnLockedOpenNewInOldWin =
    'If no unlocked tab is found, then this option will open a new Tab in an existing '+
    '(and only in an existing) Window. '+
    'A tab is only opened if there is a window that has no editor for the target file yet.';
  dlgEditAccessDescUnLockedOpenNewInNewWin =
    'If no unlocked tab is found, then this option will open a new Tab in a new '+
    'Window (even if other existing windows could be used for the new tab). '+
    'This option will always succeed, further options are never tested.';
  dlgEditAccessDescIgnLockedOldEdit =
    'This option will use the longest unused editor for the file, '+
    'even if it is locked and/or needs scrolling. '+
    'The determination of the longest unused editor does not look at the order in which the windows were focused, '+
    'even if this is set by the setting for "same criteria order". ' +
    'This option will always succeed, further options are never tested.';
  dlgEditAccessDescIgnLockedOnlyActEdit =
    'This option will check if the current active editor has the target file '+
    'and if it is, it will use the current editor, even if it is locked and/or needs scrolling.';
  dlgEditAccessDescIgnLockedOnlyActWin =
    'This option will check if there is an editor for the target file in the current window '+
    'and if there is, it will use this editor, even if it is locked and/or needs scrolling.';
  dlgEditAccessDescUnLockedOpenNewInAnyWin =
    'This option will open a new Tab in an existing or new Window if no unlocked tab is found. '+
    'This option will always succeed, further options are never tested.';

  // CodeTools dialog
  dlgCodeCreation = 'Code Creation';
  dlgWordsPolicies = 'Words';
  dlgLineSplitting = 'Line Splitting';
  dlgSpaceNotCosmos{:)} = 'Space';
  dlgIdentifierCompletion = 'Identifier Completion';
  dlgJumpingETC = 'Jumping (e.g. Method Jumping)';
  dlgAdjustTopLine = 'Adjust top line due to comment in front';
  dlgJumpSingleLinePos = 'Vertical position for a single line jump in % (0=top, 100=bottom)';
  dlgJumpCodeBlockPos = 'Vertical position for a code block jump in % (0=top, 100=bottom)';
  dlgAvoidUnnecessaryJumps = 'Avoid unnecessary jumps';
  dlgCursorBeyondEOL = 'Cursor beyond EOL';
  dlgSkipForwardClassDeclarations = 'Skip forward class declarations';
  dlgJumpToMethodBody = 'Jump directly to method body';
  dlgInsertClassParts = 'Insert class parts';
  lisNewMethodsAndMembersAreInsertedAlphabeticallyOrAdd = 'New method and '
    +'member declarations in the class..end sections are inserted alphabetically or added last.';
  lisClassCompletion = 'Class Completion';
  dlgAlphabetically = 'Alphabetically';
  dlgCDTLast = 'Last';
  dlgMixMethodsAndProperties = 'Mix methods and properties';
  dlgForwardProcsInsertPolicy = 'Procedure insert policy';
  dlgLast = 'Last (i.e. at end of source)';
  dlgInFrontOfMethods = 'In front of methods';
  dlgBehindMethods = 'Behind methods';
  dlgForwardProcsKeepOrder = 'Keep order of procedures';
  lisNewUnitsAreAddedToUsesSections = 'New units are added to uses sections';
  lisFirst = 'First';
  lisInFrontOfRelated = 'In front of related';
  lisBehindRelated = 'Behind related';
  dlgInsertMethods = 'Insert method implementations';
  lisNewMethodImplementationsAreInsertedBetweenExisting = 'New method '
    +'implementations are inserted between existing methods of this class. '
    +'Either alphabetically, or as last, or in declaration order.';
  dlgCDTClassOrder = 'Class order';
  lisDefaultSectionOfMethods = 'Default section of methods';
  lisDefaultClassVisibilitySectionOfNewMethodsForExampl = 'Default class '
    +'visibility section of new methods. For example code completion on OnShow'
    +':=';
  dlgKeywordPolicy = 'Keyword policy';
  dlgCDTLower = 'lowercase';
  dlgCDTUPPERCASE = 'UPPERCASE';
  dlg1UP2low = 'Lowercase, first letter up';
  dlgIdentifierPolicy = 'Identifier policy';
  dlgWordExceptions = 'Exceptions';
  dlgPropertyCompletion = 'Property completion';
  lisHeaderCommentForClass = 'Header comment for class';
  lisImplementationCommentForClass = 'Implementation comment for class';
  dlgCompleteProperties = 'Complete properties';
  dlgCDTReadPrefix = 'Read prefix';
  dlgCDTWritePrefix = 'Write prefix';
  dlgCDTStoredPostfix = 'Stored postfix';
  dlgCDTVariablePrefix = 'Variable prefix';
  dlgSetPropertyVariable = 'Set property Variable';
  dlgSetPropertyVariableHint = 'The parameter name for the default setter procedure.';
  dlgSetPropertyVariableIsPrefix = 'is prefix';
  dlgSetPropertyVariableIsPrefixHint = 'If checked, the "Set property Variable" is a prefix. Otherwise it is a fixed name.';
  dlgSetPropertyVariableUseConst = 'use const';
  dlgSetPropertyVariableUseConstHint = 'If checked, the setter parameter is marked with "const".';
  dlgMaxLineLength = 'Max line length:';
  dlgNotSplitLineFront = 'Do not split line in front of';
  dlgNotSplitLineAfter = 'Do not split line after';
  dlgCDTPreview = 'Preview (max line length = 1)';
  dlgInsSpaceFront = 'Insert space in front of';
  dlgInsSpaceAfter = 'Insert space after';
  dlgWRDPreview = 'Preview';
  lisIdCAddition = 'Addition';
  dlgAddSemicolon = 'Add semicolon';
  dlgAddAssignmentOperator = 'Add assignment operator :=';
  lisAddKeywordDo = 'Add keyword "do"';
  dlgUserSchemeError = 'Failed to load user-scheme file %s';

  // source editor
  locwndSrcEditor = 'Source Editor';
  
  // compiler options
  dlgCOSetAsDefault = 'Set compiler options as default';
  lisWhenEnabledTheCurrentOptionsAreSavedToTheTemplateW = 'When enabled the current '
    +'options are saved to the template which is used when creating new projects';
  dlgSearchPaths = 'Paths';
  lisIWonderHowYouDidThatErrorInTheBaseDirectory = 'I wonder how you did '
    +'that: Error in the base directory:';
  lisErrorInTheSearchPathForOtherUnitFiles = 'Error in the search path for "'
    +'Other unit files":';
  lisErrorInTheSearchPathForIncludeFiles = 'Error in the search path for "Include files":';
  lisErrorInTheSearchPathForObjectFiles = 'Error in the search path for "Object files":';
  lisErrorInTheSearchPathForLibraries = 'Error in the search path for "Libraries":';
  lisErrorInTheSearchPathForOtherSources = 'Error in the search path for "Other sources":';
  lisErrorInTheCustomLinkerOptionsLinkingPassOptionsToL = 'Error in the '
    +'custom linker options (Compilation and Linking / Pass options to linker):';
  lisErrorInTheCustomCompilerOptionsOther = 'Error in the custom compiler options (Other):';
  lisErrorInTheUnitOutputDirectory = 'Error in the "unit output directory":';
  lisErrorInTheCompilerFileName = 'Error in the compiler file name:';
  lisErrorInTheDebuggerPathAddition = 'Error in the "Debugger path addition":';
  lisIWonderHowYouDidThatErrorInThe = 'I wonder how you did that. Error in the %s:';
  lisValue3 = 'Value: ';
  dlgConfigAndTarget = 'Config and Target';
  dlgCOParsing = 'Parsing';
  dlgCompilationAndLinking = 'Compilation and Linking';
  dlgCOLinking = 'Linking';
  dlgCODebugging = 'Debugging';
  dlgCOVerbosity = 'Verbosity';
  dlgCOCfgCmpMessages = 'Messages';
  lisChooseAnFPCMessageFile = 'Choose an FPC message file';
  lisChooseAFileWithCodeToolsTemplates = 'Choose a file with CodeTools templates';
  dlgCOCompilerCommands = 'Compiler Commands';
  lisUnitOutputDirectory = 'Unit Output directory';
  lisSelectANode = 'Select a node';
  dlgCOAsmStyle = 'Assembler style';
  lisNoCompilerOptionsInherited = 'No compiler options inherited.';
  lisExcludedAtRunTime = '%s excluded at run time';
  lisExecuteBefore = 'Execute Before';
  lisExecuteAfter = 'Execute After';
  lisAllInheritedOptions = 'All inherited options';
  lisunitPath = 'unit path';
  lisincludePath = 'include path';
  lisobjectPath = 'object path';
  lislibraryPath = 'library path';
  lislinkerOptions = 'linker options';
  liscustomOptions = 'custom options';
  dlgSyntaxOptions = 'Syntax options';
  dlgCOCOps = 'C style operators (*=, +=, /= and -=)';
  dlgAssertCode = 'Include assertion code';
  dlgLabelGoto = 'Allow LABEL and GOTO';
  dlgCppInline = 'C++ styled INLINE';
  dlgCMacro = 'C style macros (global)';
  dlgInitDoneOnly = 'Constructor name must be ''' + 'init' + ''' (destructor must be ''' + 'done' + ''')';
  dlgPointerTypeCheck = '@<pointer> returns a typed pointer';
  dlgCOAnsiStr = 'Use Ansistrings';
  dlgCOUnitStyle = 'Unit style';
  dlgCOSmartLinkable = 'Smart linkable';
  dlgCORelocatable = 'Relocatable';
  dlgCOChecksAndAssertion = 'Checks and assertion';
  dlgCORange = 'Range';
  dlgCOOverflow = 'Overflow';
  dlgCOStack = 'Stack';
  dlgHeapAndStackSize = 'Heap and stack sizes';
  dlgHeapSize = 'Heap size';
  dlgStackSize = 'Stack size';
  dlgTargetProc = 'Target processor';
  dlgTargetController = 'Target controller';  //Ultibo
  dlgTargetPlatform = 'Target platform';
  dlgOptimizationLevels = 'Optimization levels';
  dlgOtherOptimizations = 'Other optimizations';
  lisSmallerRatherThanFaster = 'Smaller rather than faster';
  dlgLevelNoneOpt = '0 (no optimization, for debugging)';
  dlgLevel1Opt = '1 (quick, debugger friendly with small limitations)';
  dlgLevel2Opt = '2 (-O1 + quick optimizations)';
  dlgLevel3Opt = '3 (-O2 + slow optimizations)';
  dlgLevel4Opt = '4 (-O3 + aggressive optimizations, beware)';
  dlgTargetOS = 'Target OS';
  dlgTargetCPUFamily = 'Target CPU family';
  dlgCOInfoForGDB = 'Debugger info';
  dlgCOOtherDebuggingInfo = 'Other debugging info';
  dlgCOGDB = 'Generate info for the debugger (slower / increases exe-size)';
  dlgRunWithDebug = 'Run uses the debugger (disable for release-mode)';
  dlgCOSymbolType = 'Type of debug info';
  dlgCOSymbolTypeAuto = 'Automatic';
  dlgCOSymbolTypeStabs = 'Stabs';
  dlgCOSymbolTypeDwarf2 = 'Dwarf 2';
  dlgCOSymbolTypeDwarf2Set = 'Dwarf 2 with sets';
  dlgCOSymbolTypeDwarf3 = 'Dwarf 3 (beta)';
  dlgLNumsBct = 'Display line numbers in run-time error backtraces';
  dlgCOHeaptrc = 'Use Heaptrc unit (check for mem-leaks)';
  dlgCOTrashVariables = 'Trash variables';
  dlgCOValgrind = 'Generate code for valgrind';
  dlgGPROF = 'Generate code for gprof';
  lisOnly32bit = 'only 32bit';
  dlgCOStrip = 'Strip symbols from executable';
  dlgExtSymb = 'Use external debug symbols file';
  dlgLinkSmart = 'Link smart';
  dlgPassOptsLinker = 'Pass options to linker with "-k", delimiter is space';
  dlgWin32GUIApp = 'Win32 gui application';
  lisOptionValueIgnored = 'ignored';
  lisCannotSubstituteMacroS = 'Cannot substitute macro "%s".';
  dlgTargetSpecificOptions = 'Target-specific options';
  dlgVerbosity = 'Verbosity during compilation:';
  dlgShowWarnings = 'Show warnings';
  dlgShowNotes = 'Show notes';
  dlgShowHint = 'Show hints';
  dlgShowGeneralInfo = 'Show general info';
  dlgShowEverything ='Show everything';
  dlgShowDebugInfo = 'Show debug info';
  dlgShowUsedFiles = 'Show used files';
  dlgShowTriedFiles = 'Show tried files';
  dlgShowCompiledProcedures = 'Show compiled procedures';
  dlgShowConditionals = 'Show conditionals';
  dlgShowExecutableInfo = 'Show executable info (Win32 only)';
  dlgWriteFPCLogo = 'Write FPC logo';
  dlgHintsUnused = 'Show hints for unused units in main';
  dlgHintsParameterSenderNotUsed = 'Show hints for parameter "Sender" not used';
  dlgConfigFiles = 'Config files';
  dlgUseFpcCfg = 'Use standard compiler config file (fpc.cfg)';
  lisIfNotChecked = 'If not checked:';
  lisWriteConfigInsteadOfCommandLineParameters = 'Write config instead of '
    +'command line parameters';
  dlgUseCustomConfig = 'Use additional compiler config file';
  lisAllOptions = 'All options of FPC%s ("%s")';
  lisCheckCompilerPath = 'Please make sure that the path to the compiler in the IDE options is correct.';
  lisFilterTheAvailableOptionsList = 'Filter the available options list';
  lisClearTheFilterForOptions = 'Clear the filter for options';
  lisShowOnlyModified = 'Show only modified';
  lisUseCommentsInCustomOptions = 'Use comments in custom options';
  lisCustomOptions2 = 'Custom options';
  lisCustomOptions3 = 'Custom Options';
  lisCustomOptHint = 'These options are passed to the compiler after macros are replaced.';
  dlgStopAfterNrErr = 'Stop after number of errors:';

  lisApplyConventions = 'Apply conventions';
  lisApplyConventionsHint = 'Adjust name extension and character case for platform and file type.';
  dlgOtherUnitFiles = 'Other unit files (-Fu):';
  dlgCOIncFiles = 'Include files (-Fi):';
  dlgCOLibraries = 'Libraries (-Fl):';
  dlgUnitOutp = 'Unit output directory (-FU):';
  lisTargetFileNameEmptyUseUnitOutputDirectory = 'Target file name: (-o, empty = '
    +'use unit output directory)';
  lisTargetFileNameO = 'Target file name (-o):';
  dlgCOSources = 'Other sources (.pp/.pas files, used only by IDE not by compiler)';
  dlgCODebugPath = 'Debugger path addition (none):';
  lisDelimiterIsSemicolon = 'Delimiter is semicolon.';

  // Initial setup dialog
  lisScanning = 'Scanning';
  lisCompiler = 'Compiler';
  lisParsers = 'Parsers:';
  lisDebugger = 'Debugger';

  lisToFPCPath = 'Path:';
  lisCOSkipCallingCompiler = 'Skip calling compiler';
  lisCOAmbiguousAdditionalCompilerConfigFile = 'Ambiguous additional compiler config file';
  lisCOWarningTheAdditionalCompilerConfigFileHasTheSameNa = 'Warning: The '
    +'additional compiler config file has the same name, as one of the '
    +'standard config filenames the Free Pascal compiler is looking for. This '
    +'can result in ONLY parsing the additional config and skipping the standard config.';
  lisCOClickOKIfAreSureToDoThat = '%s%sClick OK if you definitely want to do that.';
  lisCOCallOn = 'Call on:';
  dlgCOCreateMakefile = 'Create Makefile';
  lisEnabledOnlyForPackages = 'Enabled only for packages.';
  lisCOExecuteAfter = 'Execute after';
  lisCOExecuteBefore = 'Execute before';
  lisCOCommand = 'Command:';
  lisBrowseAndSelectACompiler = 'Browse and select a compiler (e.g. ppcx64';
  lisCOScanForFPCMessages = 'Scan for FPC messages';
  lisCOScanForMakeMessages = 'Scan for Make messages';
  dlgCOShowOptions = '&Show Options';
  lisCompTest = '&Test';
  dlgCOLoadSaveHint = 'Compiler options can be saved to an XML file.';
  dlgMainViewForms = 'View Project Forms';
  dlgMainViewUnits = 'View Project Units';
  dlgMainViewFrames = 'View Project Frames';
  dlgMultiSelect = 'Multi Select';

  // check compiler options dialog
  dlgCCOCaption = 'Checking compiler options';
  dlgCCOTest = 'Test';
  dlgCCOResults = 'Results';
  lisCCOCopyOutputToCliboard = 'Copy output to clipboard';
  lisCCOContains = 'contains ';
  lisCCOSpecialCharacters = 'special characters';
  lisCCONonASCII = 'non ASCII';
  lisCCOWrongPathDelimiter = 'wrong path delimiter';
  lisCCOUnusualChars = 'unusual characters';
  lisCCOHasNewLine = 'new line symbols';
  lisCCOInvalidSearchPath = 'Invalid search path';
  lisCCOSkip = 'Skip';
  dlgCCOTestCheckingCompiler = 'Test: Checking compiler ...';
  lisDoesNotExists = '%s does not exist: %s';
  lisCCOInvalidCompiler = 'Invalid compiler';
  lisCCOCompilerNotAnExe = 'The compiler "%s" is not an executable file.%sDetails: %s';
  lisCCOAmbiguousCompiler = 'Ambiguous compiler';
  lisCCOSeveralCompilers = 'There are several Free Pascal Compilers in your path.%s%s%s'
    +'Maybe you forgot to delete an old compiler?';
  lisCCONoCfgFound = 'no fpc.cfg found';
  lisCCOMultipleCfgFound = 'multiple compiler configs found: ';
  dlgCCOUsingConfigFile = 'using config file %s';
  dlgCCOTestCompilingEmptyFile = 'Test: Compiling an empty file ...';
  lisCCOInvalidTestDir = 'Invalid Test Directory';
  lisCCOCheckTestDir = 'Please check the Test directory under %s'
    +'Tools -> Options -> Files -> Directory for building test projects';
  lisCCOUnableToCreateTestFile = 'Unable to create Test File';
  lisCCOUnableToCreateTestPascalFile = 'Unable to create Test Pascal file "%s".';
  dlgCCOTestToolCompilingEmptyFile = 'Test: Compiling an empty file';
  dlgCCOTestCheckingCompilerConfig = 'Test: Checking compiler configuration ...';
  lisCCOMsgRTLUnitNotFound = 'RTL unit not found: %s';
  lisCCOMissingUnit = 'Missing unit';
  lisCCORTLUnitNotFoundDetailed = 'The RTL unit %s was not found.%s'
    +'This typically means your %s has wrong unit paths. Or your installation is broken.';
  dlgCCOTestRTLUnits = 'Test: Checking RTL units ...';
  dlgCCOTestCompilerDate = 'Test: Checking compiler date ...';
  lisThereIsNoFreePascalCompilerEGFpcOrPpcCpuConfigured = 'There is no Free '
    +'Pascal Compiler (e. g. fpc%0:s or ppc<cpu>%0:s) configured in the project '
    +'options. CodeTools will not work properly.%1:s%1:sError message:%1:s%2:s';
  lisFatal = 'Fatal';
  lisPanic = 'Panic';
  lisHideSearch = 'Hide Search';
  lisInvalidMacrosInExternalTool = 'Invalid macros "%s" in external tool "%s"';
  lisCanNotExecute = 'cannot execute "%s"';
  lisMissingDirectory = 'missing directory "%s"';
  lisUnableToExecute = 'unable to execute: %s';
  lisUnableToReadProcessExitStatus = 'unable to read process ExitStatus';
  lisFreeingBufferLines = 'freeing buffer lines: %s';
  lisCompilerMessagesFileNotFound = 'Compiler messages file not found:%s%s';
  lisFppkgConfigurationFileNotFound = 'Fppkg configuration file not found:%s%s';
  lisUnableToOpen = 'Unable to open "%s"';
  lisCompilerDoesNotSupportTarget = 'Compiler "%s" does not support target %s-%s';
  lisInvalidMode = 'Invalid mode %s';
  lisTheProjectCompilerOptionsAndTheDirectivesInTheMain = 'The project '
    +'compiler options and the directives in the main source differ. For the '
    +'new unit the mode and string type of the project options are used:';
  lisThereIsAlreadyAnIDEMacroWithTheName = 'There is already an IDE macro '
    +'with the name "%s"';
  lisInvalidLineColumnInMessage = 'Invalid line, column in message%s%s';
  lisQuickFixSearchIdentifier = 'Search identifier';
  lisFailedToCreateApplicationBundleFor = 'Failed to create Application '
    +'Bundle for "%s"';
  lisThisProjectHasNoMainSourceFile = 'This project has no main source file';
  lisNoneClickToChooseOne = 'none, click to choose one';
  lisTreeNeedsRefresh = 'Tree needs refresh';
  lisEMDEmptyMethods = 'Empty Methods';
  lisEMDSearchInTheseClassSections = 'Search in these class sections:';
  lisUnableToLoadPackage = 'Unable to load package "%s"';
  lisSAMThisMethodCanNotBeOverriddenBecauseItIsDefinedInTh = 'This method can '
    +'not be overridden because it is defined in the current class';
  lisSAMIsAnAbstractClassItHasAbstractMethods = '%s is an abstract class, it '
    +'has %s abstract methods.';
  lisSAMAbstractMethodsOf = 'Abstract methods of %s';
  lisSAMThereAreAbstractMethodsToOverrideSelectTheMethodsF = 'There are %s '
    +'abstract methods to override.%sSelect the methods for which stubs '
    +'should be created:';
  lisSAMNoAbstractMethodsFound = 'No abstract methods found';
  lisSAMCursorIsNotInAClassDeclaration = 'Cursor is not in a class declaration';
  lisSAMIDEIsBusy = 'IDE is busy';
  lisSAMThereAreNoAbstractMethodsLeftToOverride = 'There are no abstract '
    +'methods left to override.';
  lisSAMUnableToShowAbstractMethodsOfTheCurrentClassBecaus = 'Unable to show '
    +'abstract methods of the current class, because';
  lisCCOWarningCaption = 'Warning';
  lisHintClickOnShowOptionsToFindOutWhereInheritedPaths = 'Hint: Click on "'
    +'Show Options" to find out where inherited paths are coming from.';
  lisFileNotFound5 = 'File not found:%s%s';
  lisMovingTheseUnitsWillBreakTheirUsesSectionsSeeMessa = 'Moving these units '
    +'will break their uses sections. See Messages window for details.';
  lisImportant = 'Important';
  lisMB = '%s MB';
  lisKB = '%s KB';
  lisThisWillPutALotOfTextOnTheClipboardProceed = 'This will put a lot of text'
    +' (%s) on the clipboard.%sProceed?';
  lisThePathOfMakeIsNotCorrect = 'The path of "make" is not correct: "%s"';
  lisTheCompilerFileDoesNotLookCorrect = 'The compiler file "%s" does not look'
    +' correct:%s%s';
  lisTheFPCSourceDirectoryDoesNotLookCorrect = 'The FPC source directory "%s" '
    +'does not look correct:%s%s';
  lisTheLazarusDirectoryDoesNotLookCorrect = 'The Lazarus directory "%s" does '
    +'not look correct:%s%s';
  lisTheFppkgConfigurationFileDoesNotLookCorrect = 'The Fppkg configuration file '
    +'"%s" does not look correct:%s%s';
  lisTheContainsANotExistingDirectory = 'The %s contains a nonexistent directory:%s%s';
  lisTheProjectDoesNotUseTheLCLUnitInterfacesButItSeems = 'The project does '
    +'not use the LCL unit interfaces, which is required by LCLBase.%sYou will '
    +'get strange linker errors if you use the LCL without interfaces.';
  lisAddUnitInterfaces = 'Add unit interfaces';
  lisCCODatesDiffer = 'The dates of the .ppu files of FPC differ by more than one hour.'
    +'%sThis can mean, they are from two different installations.'
    +'%sFile1: %s'
    +'%sFile2: %s';
  lisCCOPPUOlderThanCompiler = 'There is a .ppu file older than the compiler itself:%s%s';
  lisCCOPPUExistsTwice = 'ppu exists twice: %s, %s';
  dlgCCOTestSrcInPPUPaths = 'Test: Checking sources in fpc ppu search paths ...';
  lisCCOFPCUnitPathHasSource = 'FPC unit path contains a source: ';
  lisTheOutputDirectoryOfIsListedInTheUnitSearchPathOf = 'The output '
    +'directory of %s is listed in the unit search path of %s.';
  lisTheOutputDirectoryShouldBeASeparateDirectoryAndNot = ' The output '
    +'directory should be a separate directory and not contain any source files.';
  dlgCCOOrphanedFileFound = 'orphaned file found: %s';
  lisTheOutputDirectoryOfIsListedInTheIncludeSearchPath = 'The output '
    +'directory of %s is listed in the include search path of %s.';
  lisTheOutputDirectoryOfIsListedInTheInheritedUnitSear = 'The output '
    +'directory of %s is listed in the inherited unit search path of %s.';
  lisTheOutputDirectoryOfIsListedInTheInheritedIncludeS = 'The output '
    +'directory of %s is listed in the inherited include search path of %s.';
  lisCCOTestsSuccess = 'All tests succeeded.';
  lisCCOWarningMsg = 'WARNING: ';
  lisCCOHintMsg = 'HINT: ';
  lisCCOErrorMsg = 'ERROR: ';
  
  // custom messages
  dlgCompilerMessage = 'Compiler messages';

  // project options dialog
  dlgProjectOptionsFor = 'Options for Project: %s';
  dlgPOApplication = 'Application';
  dlgPOFroms = 'Forms';
  dlgPOResources = 'Resources';
  rsResourceFileName = 'File name';
  rsResourceType = 'Type';
  rsResource = 'Resource';
  rsResourceClear = 'Delete all resources?';
  dlgPOMisc = 'Miscellaneous';
  dlgPOI18n = 'i18n';
  rsEnableI18n = 'Enable i18n';
  lisEnableInternationalizationAndTranslationSupport = 'Enable internationalization '
    +'and translation support';
  rsI18nOptions = 'i18n Options';
  rsPOOutputDirectory = 'PO Output Directory:';
  lisDirectoryWhereTheIDEPutsThePoFiles = 'Directory where the IDE puts the .po files';
  lisCreateUpdatePoFileWhenSavingALfmFile = 'Create/update .po file when '
    +'saving a lfm file';
  lisYouCanDisableThisForIndividualFormsViaThePackageEd = 'You can disable '
    +'this for individual forms via the package editor';
  lisYouCanDisableThisForIndividualFormsViaThePopupMenu = 'You can disable '
    +'this for individual forms via the popup menu in the project inspector';
  rsI18nExcluded = 'Excluded';
  rsI18nIdentifiers = 'Identifiers:';
  rsI18nOriginals = 'Originals:';
  rsI18nForceUpdatePoFilesOnNextBuild = 'Force update PO files on next build';

  rsIncludeVersionInfoInExecutable = 'Include version info in executable';
  rsIncludeVersionInfoHint = 'Version info is stored if the executable format supports it.';
  rsVersionNumbering = 'Version numbering';
  rsMajorVersion = '&Major version:';
  rsMinorVersion = 'Mi&nor version:';
  rsRevision = '&Revision:';
  rsBuild = '&Build:';
  rsAutomaticallyIncreaseBuildNumber = 'Automatically increase build number';
  rsAutomaticallyIncreaseBuildNumberHint = 'Increased every time the project is compiled.';
  rsAttributes = 'Attributes';
  rsLanguageOptions = 'Language options';
  rsLanguageSelection = 'Language selection:';
  rsCharacterSet = 'Character set:';
  rsOtherInfo = 'Other info';

  dlgPOSaveSession = 'Session';
  dlgApplicationSettings = 'Application settings';
  dlgPOTitle = 'Title:';
  lisHint = 'Hint';
  lisNote = 'Note';
  dlgPOUseLCLScaling = 'Use LCL scaling (Hi-DPI)';
  lisTheContainsAStarCharacterLazarusUsesThisAsNormalCh = 'The %s contains a '
    +'star * character.%sLazarus uses this as normal character and does not '
    +'expand this as file mask.';
  lisDuplicateSearchPath = 'Duplicate search path';
  lisTheOtherSourcesContainsADirectoryWhichIsAlreadyInT = 'The "Other sources" '
    +'contains a directory which is already in the "Other unit files".%s%s';
  lisRemoveThePathsFromOtherSources = 'Remove the paths from "Other sources"';
  lisForWindows = 'For Windows';
  lisForMacOSDarwin = 'For macOS (Darwin)';
  dlgPOUseAppBundle = 'Use Application Bundle for running and debugging';
  dlgNSPrincipalClass = 'NSPrincipalClass';
  dlgPOCreateAppBundle = 'Create Application Bundle';
  dlgPOUseManifest = 'Use manifest resource (and enable themes)';
  dlgPODpiAwareness = 'DPI awareness';
  dlgPODpiAwarenessOff = 'off';
  dlgPODpiAwarenessOn = 'on';
  dlgPODpiAwarenessOldOffNewPerMonitor = 'Vista-8: off, 8.1+: per monitor';
  dlgPODpiAwarenessOldOnNewPerMonitor = 'Vista-8: on, 8.1+: per monitor';
  dlgPODpiAwarenessOldOnNewPerMonitorV2 = 'Vista-8: on, 8.1/10+: per monitor/V2';
  dlgPOUIAccess = 'UI Access (uiAccess)';
  dlgPOLongPathAware = 'Long path awareness (Windows 10 1607+)';
  dlgPOAnsiUTF8  = 'ANSI codepage is UTF-8 (Windows 10 1903+)';
  dlgPOAsInvoker = 'as invoker (asInvoker)';
  dlgPOHighestAvailable = 'highest available (highestAvailable)';
  dlgPORequireAdministrator = 'require administrator (requireAdministrator)';
  dlgPOExecutionLevel = 'Execution Level';
  dlgPOIcon = 'Icon:';
  dlgPOLoadIcon = '&Load Icon';
  dlgPODefaultIcon = 'Load &Default';
  dlgPOSaveIcon = '&Save Icon';
  dlgPOClearIcon = '&Clear Icon';
  dlgPOIconDesc = '(size: %d:%d, bpp: %d)';
  dlgPOIconDescNone = '(none)';

  dlgAutoCreateForms = 'Auto-create forms:';
  dlgAutoCreateFormsHint = 'Main .lpr unit creates each form with Application.CreateForm(). '
    +'They are also freed automatically.';
  dlgAvailableForms = 'Available forms:';
  dlgAvailableFormsHint = 'These forms must be created and freed in the program code.';
  dlgAutoCreateNewForms = 'Auto-create new forms';

  dlgSaveEditorInfo = 'Save editor info for closed files';
  dlgSaveEditorInfoHint = 'The files are available in the "Open Recent" history list.';
  dlgSaveEditorInfoProject = 'Save editor info only for project files';
  dlgSaveEditorInfoProjectHint = 'Only files that belong to this project.';
  lisSaveSessionJumpHistory = 'Save jump history';
  lisSaveSessionJumpHistoryHint = 'Ctrl-Click on an identifier in code editor is stored in jump history.';
  lisSaveSessionFoldState = 'Save fold info';
  lisSaveSessionFoldStateHint = 'Code editor supports folding (temporarily hiding) blocks of code.';
  lisPOSaveInLpiFil = 'Save in .lpi file';
  lisPOSaveInLpsFileInProjectDirectory = 'Save in .lps file in project directory';
  lisPOSaveInIDEConfigDirectory = 'Save in .lps file in IDE config directory';
  lisPODoNotSaveAnySessionInfo = 'Do not save any session info';
  lisPOSaveSessionInformationIn = 'Save session information in';
  lisPOSaveSessionInformationInHint = '.lpi is the project main info file, '
    +'.lps is a separate file for session data only.';

  lisMainUnitIsPascalSource = 'Main unit is Pascal source';
  lisMainUnitIsPascalSourceHint = 'Assume Pascal even if it does not end with .pas/.pp suffix.';
  lisMainUnitHasUsesSectionContainingAllUnitsOfProject = 'Main unit has Uses '
    +'section containing all units of project';
  lisUpdateApplicationCreateForm = 'Update Application.CreateForm statements in main unit';
  lisUsedForAutoCreatedForms = 'Used for auto-created forms.';
  lisUpdateApplicationTitleStatement = 'Update Application.Title statement in main unit';
  lisIdeMaintainsTheTitleInMainUnit = 'The IDE maintains the title in main unit.';
  lisUpdateApplicationScaledStatement = 'Update Application.Scaled statement in main unit';
  lisIdeMaintainsScaledInMainUnit = 'The IDE maintains Application.Scaled (Hi-DPI) in main unit.';
  lisLPICompatibilityModeCheckBox = 'Maximize compatibility of project files (LPI and LPS)';
  lisLPICompatibilityModeCheckBoxHint = 'Check this if you want to open your project in legacy (2.0 and older) Lazarus versions.';
  lisProjectIsRunnable = 'Project is runnable';
  lisProjectIsRunnableHint = 'Generates a binary executable which can be run.';
  lisUseDesignTimePackages = 'Use design time packages';
  lisThisIsTestProjectForDesignTimePackage = 'This is a test project for a '
    +'design time package, testing it outside the IDE.';
  lisProjOptsAlwaysBuildEvenIfNothingChanged = 'Always build (even if nothing changed)';
  lisProjOptsAlwaysBuildHint = 'May be needed if there is a bug in dependency check, normally not needed.';
  lisPutLrsFilesInOutputDirectory = 'Save .lrs files in the output directory';
  lisPutLrsFilesInOutputDirectoryHint = 'The resource will be available for FPC.';
  lisResourceTypeOfNewFiles = 'Resource type of project';
  lisLrsIncludeFiles = 'Lazarus resources (.lrs) include files';
  lisAutomaticallyConvertLfmToLrs = 'Automatically convert .lfm files to .lrs resource files';
  lisFPCResources = 'FPC resources (.res)';
  lisDelphiCompatibleResources = 'Delphi compatible resources. Recommended.';
  lisStorePathDelimitersAndAs = 'Store path delimiters \ and / as';
  lisDoNotChange = 'Do not change';
  lisChangeToUnix = 'Change to Unix /';
  lisChangeToWindows = 'Change to Windows \';

  dlgRunParameters = 'Run Parameters';
  dlgRunOLocal = 'Local';
  dlgRunOEnvironment = 'Environment';
  dlgHostApplication = 'Host application';
  dlgCommandLineParams = 'Command line parameters (without application name)';
  dlgUseLaunchingApp = 'Use launching application';
  lisUseLaunchingApplicationGroupBox = 'Launching application';
  dlgCreateNewRunParametersSettings = 'Create new Run Parameters settings';
  lisDuplicateModeName = 'Mode "%s" is already present in the list.';
  lisCannotDeleteLastMode = 'Cannot delete last mode.';
  dlgMode = 'Mode';
  dlgSaveIn = 'Save in';
  dlgAddNewMode = 'Add new mode';
  dlgDeleteMode = 'Delete mode';
  dlgROWorkingDirectory = 'Working directory';
  dlgRunODisplay = 'Display (not for win32, e.g. 198.112.45.11:0, x.org:1, hydra:0.1)';
  dlgRunOUsedisplay = 'Use display';
  dlgDefaultWinPos = 'Default Window/Console position and size';
  dlgUseConsolePos    = 'Set Left/Top';
  dlgUseConsoleSize   = 'Set Width/Height';
  dlgUseConsoleBuffer = 'Set Columns/Rows';
  dlgConsoleSizeNotSupported = 'Current debugger does not support this.';
  dlgRedirStdIn  = 'Redirect StdIn';
  dlgRedirStdOut = 'Redirect StdOut';
  dlgRedirStdErr = 'Redirect StdErr';
  dlgRedirOff  = 'No redirection';
  dlgRedirAppend  = 'To file (append)';
  dlgRedirOverWrite  = 'To file (overwrite)';
  dlgRedirInput  = 'From file';
  dlgRedirInputEnd  = 'From file (at EOF)';

  dlgRedirStdNotSupported = 'Current debugger does not support redirection.';
  dlgRunOSystemVariables = 'System variables';
  dlgRunOUserOverrides = 'User overrides';
  dlgIncludeSystemVariables = 'Include system variables';
  lisRunParamsFileNotExecutable = 'File not executable';
  lisRunParamsTheHostApplicationIsNotExecutable = 'The host application "%s" is not executable.';
  dlgTextToFind = 'Search s&tring';
  dlgReplaceWith = 'Replace wit&h';
  lisBFWhenThisFileIsActiveInSourceEditor = 'When this file is active in source editor';
  lisBFOnBuildProjectExecuteTheBuildFileCommandInstead = 'On build project '
    +'execute the Build File command instead';
  lisBFOnRunProjectExecuteTheRunFileCommandInstead = 'On run project execute '
    +'the Run File command instead';
  lisCEFilter = '(filter)';
  lrsPLDUnableToDeleteFile = 'Unable to delete file "%s"';
  lisPLDSomePackagesCannotBeDeleted = 'Some packages cannot be deleted';
  lisPLDOnlinePackagesCannotBeDeleted = 'Online packages cannot be deleted';
  lisPESortFilesAlphabetically = 'Sort files alphabetically';
  lisPEShowDirectoryHierarchy = 'Show directory hierarchy';
  lisPEOffSortForReorder = 'Please disable alphabetical sorting if you need to reorder items manually.';
  lisPEShowPropsPanel = 'Show properties panel';
  lisClearFilter = 'Clear filter';
  dlgCaseSensitive = '&Case sensitive';
  lisDistinguishBigAndSmallLettersEGAAndA = 'Distinguish big and small letters e.g. A and a';
  dlgWholeWordsOnly = '&Whole words only';
  lisOnlySearchForWholeWords = 'Only search for whole words';
  dlgRegularExpressions = 'Regular e&xpressions';
  lisActivateRegularExpressionSyntaxForTextAndReplaceme = 'Activate regular '
    +'expression syntax for text and replacement (pretty much like perl)';
  lisAllowSearchingForMultipleLines = 'Allow searching for multiple lines';
  dlgPromptOnReplace = '&Prompt on replace';
  lisAskBeforeReplacingEachFoundText = 'Ask before replacing each found text';
  dlgSROrigin = 'Origin';
  dlgFromCursor = 'From c&ursor';
  dlgFromBeginning = 'From b&eginning';
  dlgSearchScope = 'Search scope';
  dlgProject = 'Other Project'; //Ultibo
  dlgUltiboProject = 'Ultibo Project'; //Ultibo
  lisProjectSession = 'Project Session';
  lisWithRequiredPackages = 'With required packages';
  lisLevels = 'Levels';
  lisShowPackages = 'Show packages';
  lisShowUnits = 'Show units';
  lisShowIdentifiers = 'Show identifiers';
  lisPrivate = 'Private';
  lisProtected = 'Protected';
  lisEMDPublic = 'Public';
  lisEMDPublished = 'Published';
  lisEMDAll = 'All';
  lisEMDOnlyPublished = 'Only published';
  lisEMDFoundEmptyMethods = 'Found empty methods:';
  lisEMDRemoveMethods = 'Remove methods';
  lisEMDNoClass = 'No class';
  lisEMDNoClassAt = 'No class at %s(%s,%s)';
  lisEMDUnableToShowEmptyMethodsOfTheCurrentClassBecause = 'Unable to show '
    +'empty methods of the current class, because%s%s';
  lisCopyDescription = 'Copy description to clipboard';
  lisUseIdentifierInAt = 'Use identifier %s in %s at %s';
  lisCopyIdentifier = 'Copy "%s" to clipboard';
  lisExpandAllPackages = 'Expand all packages';
  lisCollapseAllPackages = 'Collapse all packages';
  lisExpandAllUnits = 'Expand all units';
  lisCollapseAllUnits = 'Collapse all units';
  lisExpandAllClasses = 'Expand all classes';
  lisCollapseAllClasses = 'Collapse all classes';
  lisBegins = 'begins';
  lisIdentifierBeginsWith = 'Identifier begins with ...';
  lisUnitNameBeginsWith = 'Unit name begins with ...';
  lisPackageNameBeginsWith = 'Package name begins with ...';
  lisContains = 'contains';
  lisIdentifierContains = 'Identifier contains ...';
  lisUnitNameContains = 'Unit name contains ...';
  lisPackageNameContains = 'Package name contains ...';
  lisFRIinCurrentUnit = 'in current unit';
  lisFRIinMainProject = 'in main project';
  lisFRIinProjectPackageOwningCurrentUnit = 'in project/package owning current unit';
  lisFRIinAllOpenPackagesAndProjects = 'in all open packages and projects';
  lisFRIRenameAllReferences = 'Rename all References';
  dlgGlobal = '&Global';
  lisPLDGlobal = 'Global';
  lisPLDOnline = 'Online';
  lisPLDUser = 'User';
  lrsPLDValid = 'valid';
  lrsPLDInvalid = 'invalid';
  dlgSelectedText = '&Selected text';
  dlgDirection = 'Direction';
  lisFRForwardSearch = 'Forwar&d search';
  lisFRBackwardSearch = '&Backward search';
  dlgReplaceAll = 'Replace &All';

  // IDEOptionDefs
  dlgWidthPos    = 'Width:';
  DlgHeightPos   = 'Height:';

  // Code Explorer
  lisCode = 'Code';

  // Unit editor
  uemFindDeclaration = '&Find Declaration';
  uemOpenFileAtCursor = '&Open File at Cursor';
  uemProcedureJump = 'Procedure Jump';
  uemClosePage = '&Close Page';
  uemCloseOtherPages = 'Close All &Other Pages';
  uemCloseOtherPagesRight = 'Close Pages on the &Right';
  uemCloseOtherPagesPlain = 'Close All Other Pages';
  uemCloseOtherPagesRightPlain = 'Close Pages on the Right';
  uemLockPage = '&Lock Page';
  uemCopyToNewWindow = 'Clone to New Window';
  uemCopyToOtherWindow = 'Clone to Other Window';
  uemCopyToOtherWindowNew = 'New Window';
  uemMoveToNewWindow = 'Move to New Window';
  uemMoveToOtherWindow = 'Move to Other Window';
  uemMoveToOtherWindowNew = 'New Window';
  uemFindInOtherWindow = 'Find in other Window';
  uemCopyFilename = 'Copy Filename';
  lisCopyFilename = 'Copy Filename %s';
  uemGotoBookmark = '&Goto Bookmark';
  uemGotoBookmarks = 'Goto Bookmark ...';
  uemNextBookmark = 'Goto Next Bookmark';
  uemPrevBookmark = 'Goto Previous Bookmark';
  uemBookmarkNUnSetDisabled = 'Bookmark %s';
  uemBookmarkNUnSet = 'Bookmark &%s';
  uemBookmarkNSet   = 'Bookmark &%s: %s';
  lisChangeEncoding = 'Change Encoding';
  lisChangeFile = 'Change file';
  lisEncodingOfFileOnDiskIsNewEncodingIs = 'Encoding of file "%s"%son disk is %s. New encoding is %s.';
  lisReopenWithAnotherEncoding = 'Reopen with another encoding';
  lisAbandonChanges = 'Abandon changes?';
  lisAllYourModificationsToWillBeLostAndTheFileReopened = 'All your modifications '
    +'to "%s"%swill be lost and the file reopened.';
  lisOpenLfm = 'Open %s';
  lisUtf8WithBOM = 'UTF-8 with BOM';
  uemToggleBookmark = '&Toggle Bookmark';
  uemToggleBookmarkNUnset = 'Toggle Bookmark &%s';
  uemToggleBookmarkNset = 'Toggle Bookmark &%s: %s';
  uemToggleBookmarks = 'Toggle Bookmark ...';
  uemReadOnly = 'Read Only';
  uemShowLineNumbers = 'Show Line Numbers';
  lisDisableI18NForLFM = 'Disable I18N for LFM';
  lisEnableI18NForLFM = 'Enable I18N for LFM';
  uemDebugWord = 'Debug';
  lisExtremelyVerbose = 'Extremely Verbose';
  lisDebug = 'Debug';
  lisVeryVerbose = 'Very Verbose';
  lisVerbose = 'Verbose';
  uemToggleBreakpoint = 'Toggle &Breakpoint';
  uemEvaluateModify = '&Evaluate/Modify ...';
  uemAddWatchAtCursor = 'Add &Watch At Cursor';
  uemAddWatchPointAtCursor = 'Add Watch&Point At Cursor';
  uemInspect = '&Inspect ...';
  uemViewCallStack = 'View Call Stack';
  uemMovePageLeft='Move Page Left';
  uemMovePageRight='Move Page Right';
  uemMovePageLeftmost='Move Page Leftmost';
  uemMovePageRightmost='Move Page Rightmost';
  uemSource = 'Source';
  uemRefactor = 'Refactoring';
  ueNotImplCap='Not implemented yet';
  ueFileROCap= 'File is readonly';
  ueFileROText1='The file "';
  ueFileROText2='" is not writable.';
  ueModified='Modified';
  ueLocked='Locked';
  ueMacroRecording = 'Recording';
  ueMacroRecordingPaused = 'Rec-pause';
  uepReadonly= 'Readonly';
  uepIns='INS';
  uepOvr='OVR';
  uepSelNorm='DEF';
  uepSelLine='LINE';
  uepSelCol ='COL';
  uepSelChars ='%d';
  uepSelCxChars ='%d * %d';
  lisUEFontWith = 'Font without UTF-8';
  lisUETheCurre = 'The current editor font does not support UTF-8 but your system seems to use it.'
    +'%sThat means non ASCII characters will probably be shown incorrectly.'
    +'%sYou can select another font in the editor options.';
  lisUEDoNotSho = 'Do not show this message again.';
  uemHighlighter = 'Highlighter';
  uemEncoding = 'Encoding';
  uemLineEnding = 'Line Ending';

  // Form designer
  lisInvalidMultiselection = 'Invalid multiselection';
  lisUnableConvertBinaryStreamToText = 'Unable convert binary stream to text';
  lisUnableToStreamSelectedComponents = 'Unable to stream selected components';
  lisCanNotCopyTopLevelComponent = 'Cannot copy top level component.';
  lisCopyingAWholeFormIsNotImplemented = 'Copying a whole form is not implemented.';
  lisThereWasAnErrorDuringWritingTheSelectedComponent = 'There was an error '
    +'during writing the selected component %s:%s:%s%s';
  lisThereWasAnErrorWhileConvertingTheBinaryStreamOfThe = 'There was an error '
    +'while converting the binary stream of the selected component %s:%s:%s%s';
  lisUnableCopyComponentsToClipboard = 'Unable copy components to clipboard';
  lisThereWasAnErrorWhileCopyingTheComponentStreamToCli = 'There was an error '
    +'while copying the component stream to clipboard:%s%s';
  lisErrorIn = 'Error in %s';
  lisTheComponentEditorOfClassInvokedWithVerbHasCreated = 'The component editor of class "%s"'
    +'%sinvoked with verb #%s "%s"'
    +'%shas created the error:'
    +'%s"%s"';
  lisReset = 'Reset';
  lisResetLeftTopWidthHeightOfSelectedComponentsToTheir = 'Reset Left, Top, '
    +'Width, Height of selected components to their ancestor values?';
  lisTheComponentEditorOfClassHasCreatedTheError = 'The component editor of '
    +'class "%s" has created the error:%s"%s"';
  fdInvalidMultiselectionText='Multiselected components must be of a single form.';
  lisInvalidDelete = 'Invalid delete';
  lisTheComponentIsInheritedFromToDeleteAnInheritedComp = 'The component %s '
    +'is inherited from %s.%sTo delete an inherited component open the '
    +'ancestor and delete it there.';
  lisTheRootComponentCanNotBeDeleted = 'The root component cannot be deleted.';
  fdmAlignMenu='Align ...';
  fdmMirrorHorizontal='Mirror Horizontal';
  fdmMirrorVertical='Mirror Vertical';
  fdmScaleWord='Scale';
  fdmScaleMenu='Scale ...';
  fdmSizeWord='Size';
  fdmSizeMenu='Size ...';
  fdmResetMenu = 'Reset ...';
  fdmZOrder='Z-order';
  fdmOrderMoveTofront='Move to Front';
  fdmOrderMoveToback='Move to Back';
  fdmOrderForwardOne='Forward One';
  fdmOrderBackOne='Back One';
  fdmDeleteSelection='Delete Selection';
  fdmSelectAll='Select All';
  lisChangeClass = 'Change Class';
  lisDlgChangeClass = 'Change Class ...';
  fdmSnapToGridOption='Option: Snap to grid';
  fdmSnapToGuideLinesOption='Option: Snap to guide lines';
  lisViewSourceLfm = 'View Source (.lfm)';
  lisCenterForm = 'Center Form';
  fdmSaveFormAsXML = 'Save Form as XML';

  // keyMapping
  srkmCommand  = 'Command:';
  lisKeyOr2KeySequence = 'Key (or 2 key sequence)';
  lisTheKeyIsAlreadyAssignedToRemoveTheOldAssignmentAnd = 'The key %s'
    +' is already assigned to %s%s.'
    +'%s%sRemove the old assignment and assign the key to the new function %s?';
  lisAlternativeKeyOr2KeySequence = 'Alternative key (or 2 key sequence)';
  srkmConflic  = 'Conflict ';
  srkmEditForCmd = 'Edit keys of command';
  lisChooseAKey = 'Choose a key ...';

  //Commands
  srkmecLeft                  = 'Move cursor left';
  srkmecRight                 = 'Move cursor right';
  srkmecUp                    = 'Move cursor up';
  srkmecDown                  = 'Move cursor down';
  srkmecWordLeft              = 'Move cursor word left';
  srkmecWordRight             = 'Move cursor word right';
  srkmecWordEndLeft           = 'Move cursor word-end left';
  srkmecWordEndRight          = 'Move cursor word-end right';
  srkmecHalfWordLeft          = 'Move cursor part-word left (e.g. CamelCase)';
  srkmecHalfWordRight         = 'Move cursor part-word right (e.g. CamelCase)';
  srkmecSmartWordLeft         = 'Smart move cursor left (start/end of word)';
  srkmecSmartWordRight        = 'Smart move cursor right (start/end of word)';
  srkmecLineStart             = 'Move cursor to line start';
  srkmecLineEnd               = 'Move cursor to line end';
  srkmecPageUp                = 'Move cursor up one page';
  srkmecPageDown              = 'Move cursor down one page';
  srkmecPageLeft              = 'Move cursor left one page';
  srkmecPageRight             = 'Move cursor right one page';
  srkmecPageTop               = 'Move cursor to top of page';
  srkmecPageBottom            = 'Move cursor to bottom of page';
  srkmecEditorTop             = 'Move cursor to absolute beginning';
  srkmecEditorBottom          = 'Move cursor to absolute end';
  srkmecGotoXY                = 'Goto XY';
  srkmecLineTextStart         = 'Move cursor to text start in line';
  srkmecSelSticky             = 'Start sticky selecting';
  srkmecSelStickyCol          = 'Start sticky selecting (Columns)';
  srkmecSelStickyLine         = 'Start sticky selecting (Line)';
  srkmecSelStickyStop         = 'Stop sticky selecting';
  srkmecSelLeft               = 'Select Left';
  srkmecSelRight              = 'Select Right';
  srkmecSelUp                 = 'Select Up';
  srkmecSelDown               = 'Select Down';
  srkmecSelWordLeft           = 'Select Word Left';
  srkmecSelWordRight          = 'Select Word Right';
  srkmecSelWordEndLeft        = 'Select word-end left';
  srkmecSelWordEndRight       = 'Select word-end right';
  srkmecSelHalfWordLeft       = 'Select part-word left (e.g. CamelCase)';
  srkmecSelHalfWordRight      = 'Select part-word right (e.g. CamelCase)';
  srkmecSelSmartWordLeft      = 'Smart select word left (start/end of word)';
  srkmecSelSmartWordRight     = 'Smart select word right (start/end of word)';
  srkmecSelLineStart          = 'Select Line Start';
  srkmecSelLineEnd            = 'Select Line End';
  srkmecSelPageUp             = 'Select Page Up';
  srkmecSelPageDown           = 'Select Page Down';
  srkmecSelPageLeft           = 'Select Page Left';
  srkmecSelPageRight          = 'Select Page Right';
  srkmecSelPageTop            = 'Select Page Top';
  srkmecSelPageBottom         = 'Select Page Bottom';
  srkmecSelEditorTop          = 'Select to absolute beginning';
  srkmecSelEditorBottom       = 'Select to absolute end';
  srkmecSelLineTextStart      = 'Select to text start in line';
  srkmecColSelUp              = 'Column Select Up';
  srkmecColSelDown            = 'Column Select Down';
  srkmecColSelLeft            = 'Column Select Left';
  srkmecColSelRight           = 'Column Select Right';
  srkmecColSelWordLeft        = 'Column Select Word Left';
  srkmecColSelWordRight       = 'Column Select Word Right';
  srkmecColSelPageDown        = 'Column Select Page Down';
  srkmecColSelPageBottom      = 'Column Select Page Bottom';
  srkmecColSelPageUp          = 'Column Select Page Up';
  srkmecColSelPageTop         = 'Column Select Page Top';
  srkmecColSelLineStart       = 'Column Select Line Start';
  srkmecColSelLineEnd         = 'Column Select Line End';
  srkmecColSelEditorTop       = 'Column Select to absolute beginning';
  srkmecColSelEditorBottom    = 'Column Select to absolute end';
  srkmecColSelLineTextStart   = 'Column Select to text start in line';
  srkmecSelGotoXY             = 'Select Goto XY';
  srkmecSelectAll             = 'Select All';
  srkmecDeleteLastChar        = 'Delete Last Char';
  srkmecDeletechar            = 'Delete char at cursor';
  srkmecDeleteWord            = 'Delete to end of word';
  srkmecDeleteLastWord        = 'Delete to start of word';
  srkmecDeleteBOL             = 'Delete to beginning of line';
  srkmecDeleteEOL             = 'Delete to end of line';
  srkmecDeleteLine            = 'Delete current line (keep caret at BOL)';
  srkmecDeleteLineKeepX       = 'Delete current line (restore caret x-pos)';
  srkmecClearAll              = 'Delete whole text';
  srkmecLineBreak             = 'Break line and move cursor';
  srkmecInsertLine            = 'Break line, leave cursor';
  srkmecChar                  = 'Char';
  srkmecImeStr                = 'Ime Str';
  srkmecCut                   = 'Cut';
  srkmecCopy                  = 'Copy';
  srkmecPaste                 = 'Paste';
  srkmecPasteAsColumns        = 'Paste (as Columns)';
  srkmecCopyAdd               = 'Copy to clipboard (append)';
  srkmecCutAdd                = 'Cut to clipboard (append)';
  srkmecCopyCurrentLine       = 'Copy current line to clipboard';
  srkmecCopyAddCurrentLine    = 'Copy current line to clipboard (append)';
  srkmecCutCurrentLine        = 'Cut current line to clipboard';
  srkmecCutAddCurrentLine     = 'Cut current line to clipboard (append)';
  srkmecMoveLineUp            = 'Move line up';
  srkmecMoveLineDown          = 'Move line down';
  srkmecDuplicateLine         = 'Duplicate line (or lines in selection)';
  srkmecDuplicateSelection    = 'Duplicate selection';
  srkmecMoveSelectUp          = 'Move selection up';
  srkmecMoveSelectDown        = 'Move selection down';
  srkmecMoveSelectLeft        = 'Move selection left';
  srkmecMoveSelectRight       = 'Move selection right';

  srkmecMultiPaste            = 'MultiPaste';
  srkmecScrollUp              = 'Scroll up one line';
  srkmecScrollDown            = 'Scroll down one line';
  srkmecScrollLeft            = 'Scroll left one char';
  srkmecScrollRight           = 'Scroll right one char';
  srkmecInsertMode            = 'Insert Mode';
  srkmecOverwriteMode         = 'Overwrite Mode';
  srkmecToggleMode            = 'Toggle Mode';
  srkmecBlockIndent           = 'Indent line/block';
  srkmecBlockUnindent         = 'Unindent line/block';
  srkmecBlockIndentMove       = 'Indent line/block (move columns)';
  srkmecBlockUnindentMove     = 'Unindent line/block (move columns)';
  srkmecColumnBlockShiftRight = 'Shift column-block right (delete in columns)';
  srkmecColumnBlockMoveRight  = 'Move column-block right (delete after columns)';
  srkmecColumnBlockShiftLeft  = 'Shift column-block left (delete in columns)';
  srkmecColumnBlockMoveLeft   = 'Move column-block left (delete before columns)';
  srkmecPluginMultiCaretSetCaret         = 'Add extra caret';
  srkmecPluginMultiCaretUnsetCaret       = 'Remove extra caret';
  srkmecPluginMultiCaretToggleCaret      = 'Toggle extra caret';
  srkmecPluginMultiCaretClearAll         = 'Clear all extra carets';
  srkmecPluginMultiCaretModeCancelOnMove = 'Cursor keys clear all extra carets';
  srkmecPluginMultiCaretModeMoveAll      = 'Cursor keys move all extra carets';

  srkmecBlockSetBegin   = 'Set block begin';
  srkmecBlockSetEnd     = 'Set block end';
  srkmecBlockToggleHide = 'Toggle block';
  srkmecBlockHide       = 'Hide Block';
  srkmecBlockShow       = 'Show Block';
  srkmecBlockMove       = 'Move Block';
  srkmecBlockCopy       = 'Copy Block';
  srkmecBlockDelete     = 'Delete Block';
  srkmecBlockGotoBegin  = 'Goto Block begin';
  srkmecBlockGotoEnd    = 'Goto Block end';

  srkmecZoomIn    = 'Zoom in';
  srkmecZoomOut   = 'Zoom out';

  srkmecShiftTab              = 'Shift Tab';
  lisTab                      = 'Tab';
  srkmecMatchBracket          = 'Go to matching bracket';
  srkmecNormalSelect          = 'Normal selection mode';
  srkmecColumnSelect          = 'Column selection mode';
  srkmecLineSelect            = 'Line selection mode';
  srkmecAutoCompletion        = 'Code template completion';
  srkmecSetFreeBookmark       = 'Set a free Bookmark';
  srkmecClearBookmarkForFile  = 'Clear Bookmarks for current file';
  srkmecClearAllBookmark      = 'Clear all Bookmarks';
  srkmecPrevBookmark          = 'Previous Bookmark';
  srkmecNextBookmark          = 'Next Bookmark';
  srkmecGotoMarker   = 'Go to bookmark %d';
  srkmecSetMarker    = 'Set bookmark %d';
  srkmecToggleMarker = 'Toggle bookmark %d';

  // sourcenotebook
  lisKMToggleBetweenUnitAndForm = 'Toggle between Unit and Form';
  srkmecNextEditor            = 'Go to next editor';
  srkmecPrevEditor            = 'Go to prior editor';
  srkmecMoveEditorLeft        = 'Move editor left';
  srkmecMoveEditorRight       = 'Move editor right';
  srkmecMoveEditorLeftmost    = 'Move editor leftmost';
  srkmecMoveEditorRightmost   = 'Move editor rightmost';
  srkmecPrevEditorInHistory   = 'Go to previous editor in history';
  srkmecNextEditorInHistory   = 'Go to next editor in history';

  srkmecNextSharedEditor         = 'Go to next editor with same Source';
  srkmecPrevSharedEditor         = 'Go to prior editor with same Source';
  srkmecNextWindow               = 'Go to next window';
  srkmecPrevWindow               = 'Go to prior window';
  srkmecMoveEditorNextWindow     = 'Move editor to next free window';
  srkmecMoveEditorPrevWindow     = 'Move editor to prior free window';
  srkmecMoveEditorNewWindow      = 'Move editor to new window';
  srkmecCopyEditorNextWindow     = 'Copy editor to next free window';
  srkmecCopyEditorPrevWindow     = 'Copy editor to prior free window';
  srkmecCopyEditorNewWindow      = 'Copy editor to new window';
  srkmecLockEditor               = 'Lock Editor';

  srkmecGotoEditor            = 'Go to source editor %d';
  srkmEcFoldLevel             = 'Fold to Level %d';
  srkmecUnFoldAll             = 'Unfold all';
  srkmecFoldCurrent           = 'Fold at Cursor';
  srkmecFoldToggle            = 'Toggle Fold at Cursor';
  srkmecUnFoldCurrent         = 'Unfold at Cursor';
  srkmecToggleMarkupWord      = 'Toggle Current-Word highlight';

  // edit menu
  srkmecSelectionTabs2Spaces     = 'Convert tabs to spaces in selection';
  srkmecInsertCharacter          = 'Insert from Charactermap';
  srkmecInsertGPLNotice          = 'Insert GPL notice';
  srkmecInsertGPLNoticeTranslated = 'Insert GPL notice (translated)';
  srkmecInsertLGPLNotice         = 'Insert LGPL notice';
  srkmecInsertLGPLNoticeTranlated = 'Insert LGPL notice (translated)';
  srkmecInsertModifiedLGPLNotice = 'Insert modified LGPL notice';
  srkmecInsertModifiedLGPLNoticeTranslated = 'Insert modified LGPL notice (translated)';
  srkmecInsertMITNotice          = 'Insert MIT notice';
  srkmecInsertMITNoticeTranslated = 'Insert MIT notice (translated)';
  srkmecInsertUserName           = 'Insert current username';
  srkmecInsertDateTime           = 'Insert current date and time';
  srkmecInsertChangeLogEntry     = 'Insert ChangeLog entry';
  srkmecInsertCVSAuthor          = 'Insert CVS keyword Author';
  srkmecInsertCVSDate            = 'Insert CVS keyword Date';
  srkmecInsertCVSHeader          = 'Insert CVS keyword Header';
  srkmecInsertCVSID              = 'Insert CVS keyword ID';
  srkmecInsertCVSLog             = 'Insert CVS keyword Log';
  srkmecInsertCVSName            = 'Insert CVS keyword Name';
  srkmecInsertCVSRevision        = 'Insert CVS keyword Revision';
  srkmecInsertCVSSource          = 'Insert CVS keyword Source';
  srkmecInsertGUID               = 'Insert a GUID';
  srkmecInsertFilename           = 'Insert Full Filename';
  lisMenuInsertFilename          = 'Insert Full Filename ...';

  // search menu
  srkmecFind                      = 'Find Text';
  srkmecFindNext                  = 'Find Next';
  srkmecFindPrevious              = 'Find Previous';
  srkmecFindInFiles               = 'Find in Files';
  srkmecJumpToNextSearchResult    = 'Jump to next search result';
  srkmecJumpToPrevSearchResult    = 'Jump to previous search result';
  srkmecReplace                   = 'Replace Text';
  lisKMFindIncremental            = 'Find Incremental';
  srkmecFindProcedureDefinition   = 'Find Procedure Definiton';
  srkmecFindProcedureMethod       = 'Find Procedure Method';
  srkmecGotoLineNumber            = 'Go to Line Number';
  srkmecFindNextWordOccurrence    = 'Find Next Word Occurrence';
  srkmecFindPrevWordOccurrence    = 'Find Previous Word Occurrence';
  srkmecAddJumpPoint              = 'Add Jump Point';
  srkmecOpenFileAtCursor          = 'Open File at Cursor';
  srkmecGotoIncludeDirective      = 'Go to include directive of current include file';
  
  // view menu
  srkmecToggleFormUnit            = 'Switch between form and unit';
  srkmecToggleObjectInsp          = 'View Object Inspector';
  srkmecToggleSourceEditor        = 'View Source Editor';
  srkmecToggleCodeExpl            = 'View Code Explorer';
  srkmecToggleFPDocEditor         = 'View Documentation Editor';
  srkmecToggleMessages            = 'View messages';
  srkmecToggleSearchResults       = 'View Search Results';
  lisKMToggleViewWatches          = 'View Watches';
  lisKMToggleViewBreakpoints      = 'View Breakpoints';
  lisKMToggleViewLocalVariables   = 'View Local Variables';
  lisKMToggleViewDebuggerOutput   = 'View Debugger Output';
  lisKMToggleViewThreads          = 'View Threads';
  lisKMToggleViewHistory          = 'View History';
  lisKMToggleViewPseudoTerminal   = 'View Console In/Output';
  lisKMToggleViewCallStack        = 'View Call Stack';
  lisKMToggleViewRegisters        = 'View Registers';
  lisKMToggleViewAssembler        = 'View Assembler';
  srkmecToggleMemViewer           = 'View Memory Viewer';
  srkmecViewUnits                 = 'View units';
  srkmecViewForms                 = 'View forms';
  srkmecViewComponents            = 'View components';
  srkmecViewEditorMacros          = 'View editor macros';
  lisKMViewJumpHistory            = 'View jump history';
  srkmecViewUnitDependencies      = 'View unit dependencies';
  srkmecViewUnitInfo              = 'View unit information';
  srkmecViewAnchorEditor          = 'View anchor editor';
  srkmecViewTabOrder              = 'View Tab Order';
  srkmecToggleCodeBrowser         = 'View code browser';
  srkmecToggleRestrictionBrowser  = 'View restriction browser';
  srkmecToggleCompPalette         = 'View component palette';
  srkmecToggleIDESpeedBtns        = 'View IDE speed buttons';

  // codetools
  srkmecWordCompletion            = 'Word Completion';
  lisMenuCompleteCode             = 'Complete Code';
  lisMenuCompleteCodeInteractive  = 'Complete Code (with dialog)';
  lisUseUnit                      = 'Add Unit to Uses Section';
  lisMenuUseUnit                  = 'Add Unit to Uses Section ...';
  srkmecShowCodeContext           = 'Show Code Context';
  srkmecExtractProc               = 'Extract Procedure';
  lisMenuExtractProc              = 'Extract Procedure ...';
  srkmecFindIdentifierRefs        = 'Find Identifier References';
  lisMenuFindIdentifierRefs       = 'Find Identifier References ...';
  lisMenuFindReferencesOfUsedUnit = 'Find References Of Used Unit';
  srkmecRenameIdentifier          = 'Rename Identifier';
  lisMenuRenameIdentifier         = 'Rename Identifier ...';
  srkmecInvertAssignment          = 'Invert Assignment';
  uemInvertAssignment             = 'Invert Assignment';
  srkmecSyntaxCheck               = 'Syntax Check';
  srkmecGuessMisplacedIFDEF       = 'Guess Misplaced $IFDEF';
  srkmecFindDeclaration           = 'Find Declaration';
  srkmecFindBlockOtherEnd         = 'Find block other end';
  srkmecFindBlockStart            = 'Find block start';
  srkmecAbstractMethods           = 'Abstract Methods ...';
  srkmecShowAbstractMethods       = 'Show Abstract Methods';
  srkmecEmptyMethods              = 'Empty Methods ...';
  srkmecRemoveEmptyMethods        = 'Remove Empty Methods';
  srkmecUnusedUnits               = 'Unused Units ...';
  srkmecRemoveUnusedUnits         = 'Remove Unused Units';
  srkmecFindOverloads             = 'Find Overloads';
  srkmecFindOverloadsCapt         = 'Find Overloads ...';

  // Macro edit
  srkmecSynMacroRecord            = 'Record Macro';
  srkmecSynMacroPlay              = 'Play Macro';

  //Plugin template Edit
  srkmecSynPTmplEdNextCell           = 'Next Cell';
  srkmecSynPTmplEdNextCellSel        = 'Next Cell (all selected)';
  srkmecSynPTmplEdNextCellRotate     = 'Next Cell (rotate)';
  srkmecSynPTmplEdNextCellSelRotate  = 'Next Cell (rotate / all selected)';
  srkmecSynPTmplEdPrevCell           = 'Previous Cell';
  srkmecSynPTmplEdPrevCellSel        = 'Previous Cell (all selected)';
  srkmecSynPTmplEdNextFirstCell           = 'Next Cell (firsts only)';
  srkmecSynPTmplEdNextFirstCellSel        = 'Next Cell (all selected / firsts only)';
  srkmecSynPTmplEdNextFirstCellRotate     = 'Next Cell (rotate / firsts only)';
  srkmecSynPTmplEdNextFirstCellSelRotate  = 'Next Cell (rotate / all selected / firsts only)';
  srkmecSynPTmplEdPrevFirstCell           = 'Previous Cell (firsts only)';
  srkmecSynPTmplEdPrevFirstCellSel        = 'Previous Cell (all selected / firsts only)';
  srkmecSynPTmplEdCellHome           = 'Goto first pos in cell';
  srkmecSynPTmplEdCellEnd            = 'Goto last pos in cell';
  srkmecSynPTmplEdCellSelect         = 'Select cell';
  srkmecSynPTmplEdFinish             = 'Finish';
  srkmecSynPTmplEdEscape             = 'Escape';

  // Plugin Syncro Edit
  srkmecSynPSyncroEdNextCell         = 'Next Cell';
  srkmecSynPSyncroEdNextCellSel      = 'Next Cell (all selected)';
  srkmecSynPSyncroEdPrevCell         = 'Previous Cell';
  srkmecSynPSyncroEdPrevCellSel      = 'Previous Cell (all selected)';
  srkmecSynPSyncroEdNextFirstCell    = 'Next Cell (firsts only)';
  srkmecSynPSyncroEdNextFirstCellSel = 'Next Cell (all selected / firsts only)';
  srkmecSynPSyncroEdPrevFirstCell    = 'Previous Cell (firsts only)';
  srkmecSynPSyncroEdPrevFirstCellSel = 'Previous Cell (all selected / firsts only)';
  srkmecSynPSyncroEdCellHome         = 'Goto first pos in cell';
  srkmecSynPSyncroEdCellEnd          = 'Goto last pos in cell';
  srkmecSynPSyncroEdCellSelect       = 'Select Cell';
  srkmecSynPSyncroEdEscape           = 'Escape';
  srkmecSynPSyncroEdStart            = 'Start Syncro edit';
  srkmecSynPSyncroEdStartCase        = 'Start Syncro edit (case-sensitive)';
  srkmecSynPSyncroEdStartCtx         = 'Start Syncro edit (context-sensitive)';
  srkmecSynPSyncroEdStartCtxCase     = 'Start Syncro edit (context & case-sensitive)';
  srkmecSynPSyncroEdGrowCellLeft     = 'Grow cell on the left';
  srkmecSynPSyncroEdShrinkCellLeft   = 'Shrink cell on the left';
  srkmecSynPSyncroEdGrowCellRight    = 'Grow cell on the right';
  srkmecSynPSyncroEdShrinkCellRight  = 'Shrink cell on the right';
  srkmecSynPSyncroEdAddCell          = 'Add Cell';
  srkmecSynPSyncroEdAddCellCase      = 'Add Cell (case-sensitive)';
  srkmecSynPSyncroEdAddCellCtx       = 'Add Cell (context-sensitive)';
  srkmecSynPSyncroEdAddCellCtxCase   = 'Add Cell (context & case-sensitive)';
  srkmecSynPSyncroEdDelCell          = 'Remove current Cell';


  srkmecSynPLineWrapLineStart             = 'Move cursor to wrapped line start';
  srkmecSynPLineWrapLineEnd               = 'Move cursor to wrapped line end';
  srkmecSynPLineWrapSelLineStart          = 'Select to wrapped line start';
  srkmecSynPLineWrapSelLineEnd            = 'Select to wrapped line end';
  srkmecSynPLineWrapColSelLineStart       = 'Column Select to wrapped line start';
  srkmecSynPLineWrapColSelLineEnd         = 'Column Select to wrapped line end';

  // run menu
  srkmecCompile                   = 'compile program/project';
  srkmecBuild                     = 'build program/project';
  srkmecQuickCompile              = 'quick compile, no linking';
  srkmecCleanUpAndBuild           = 'clean up and build';
  srkmecBuildManyModes            = 'build many modes';
  srkmecAbortBuild                = 'abort build';
  srkmecRunWithoutDebugging       = 'run without debugging';
  srkmecRunWithDebugging          = 'run with debugging';
  srkmecRun                       = 'run program';
  srkmecPause                     = 'pause program';
  srkmecShowExecutionPoint        = 'show execution point';
  srkmecStopProgram               = 'stop program';
  srkmecResetDebugger             = 'reset debugger';
  srkmecToggleBreakPoint          = 'toggle breakpoint';
  srkmecToggleBreakPointEnabled   = 'enable/disable breakpoint';
  srkmecBreakPointProperties      = 'show breakpoint properties';
  srkmecRemoveBreakPoint          = 'remove breakpoint';
  srkmecAttach                    = 'Attach to program';
  srkmecDetach                    = 'Detach from program';
  srkmecRunParameters             = 'run parameters';
  srkmecBuildFile                 = 'build file';
  srkmecRunFile                   = 'run file';
  srkmecConfigBuildFile           = 'config build file';
  srkmecInspect                   = 'inspect';
  srkmecEvaluate                  = 'evaluate/modify';
  srkmecAddWatch                  = 'add watch';
  srkmecAddBpSource               = 'add source breakpoint';
  srkmecAddBpAddress              = 'add address breakpoint';
  srkmecAddBpWatchPoint           = 'add data/watchpoint';

  // tools menu
  srkmecExtToolSettings           = 'External tools settings';
  srkmecBuildLazarus              = 'Build Lazarus';
  srkmecExtTool                   = 'External tool %d';
  srkmecEnvironmentOptions        = 'IDE options';
  lisKMEditCodeTemplates          = 'Edit Code Templates';
  lisKMCodeToolsDefinesEditor            = 'CodeTools defines editor';
  lisCodeToolsDefsCodeToolsDefinesEditor = 'CodeTools Defines Editor';
  lisMenuCodeToolsDefinesEditor          = 'CodeTools Defines Editor ...';
  lisMenuRescanFPCSourceDirectory = 'Rescan FPC Source Directory';
  lisMenuBuildUltiboRTL           = 'Build Ultibo RTL ...'; //Ultibo
  lisMenuRunInQEMU                = 'Run in QEMU ...'; //Ultibo
  srkmecMakeResourceString        = 'Make Resource String';
  lisDesktops                     = 'Desktops ...';
  lisKMDiffEditorFiles            = 'Diff Editor Files';
  lisKMConvertDFMFileToLFM        = 'Convert DFM File to LFM';
  lisKMConvertDelphiUnitToLazarusUnit = 'Convert Delphi Unit to Lazarus Unit';
  lisKMConvertDelphiProjectToLazarusProject = 'Convert Delphi Project to Lazarus Project';
  srkmecDiff                      = 'Diff';
  
  // help menu
  srkmecunknown                   = 'unknown editor command';
  srkmecReportingBug              = 'Reporting a bug';
  lisFocusHint = 'Focus hint';
   
  // Category
  srkmCatCursorMoving   = 'Cursor moving commands';
  srkmCatSelection      = 'Text selection commands';
  srkmCatColSelection   = 'Text column selection commands';
  srkmCatEditing        = 'Text editing commands';
  srkmCatClipboard      = 'Clipboard commands';
  lisKMDeleteLastChar   = 'Delete last char';
  srkmCatCmdCmd         = 'Command commands';
  srkmCatMultiCaret     = 'Multi caret commands';
  srkmCatSearchReplace  = 'Text search and replace commands';
  srkmCatMarker         = 'Text bookmark commands';
  srkmCatFold           = 'Text folding commands';
  srkmCatCodeTools      = 'CodeTools commands';
  srkmCatMacroRecording = 'Macros';
  srkmCatTemplateEdit   = 'Template Editing';
  srkmCatTemplateEditOff= 'Template Editing (not in Cell)';
  srkmCatSyncroEdit     = 'Syncron Editing';
  srkmCatSyncroEditOff  = 'Syncron Editing (not in Cell)';
  srkmCatSyncroEditSel  = 'Syncron Editing (while selecting)';
  srkmCatLineWrap       = 'Line wrapping';

  srkmCatSrcNoteBook    = 'Source Notebook commands';
  srkmCatFileMenu       = 'File menu commands';
  srkmCatViewMenu       = 'View menu commands';
  lisKMToggleViewObjectInspector = 'Toggle view Object Inspector';
  lisKMToggleViewSourceEditor = 'Toggle view Source Editor';
  lisKMToggleViewCodeExplorer = 'Toggle view Code Explorer';
  lisKMToggleViewCodeBrowser = 'Toggle view Code Browser';
  lisKMToggleViewDocumentationEditor = 'Toggle view Documentation Editor';
  lisKMToggleViewMessages = 'Toggle view Messages';
  lisKMToggleViewSearchResults = 'Toggle view Search Results';
  lisKMToggleViewDebugEvents = 'View Debugger Event Log';
  srkmCatProjectMenu    = 'Project menu commands';
  lisKMNewProject = 'New project';
  lisKMNewProjectFromFile = 'New project from file';
  lisKMToggleViewIDESpeedButtons = 'Toggle view IDE speed buttons';
  srkmCatRunMenu        = 'Run menu commands';
  lisKMCompileProjectProgram = 'Compile project/program';
  lisKMBuildProjectProgram = 'Build project/program';
  lisKMQuickCompileNoLinking = 'Quick compile, no linking';
  lisKMCleanUpAndBuild = 'Clean up and build';
  lisKMBuildManyModes = 'Build many modes';
  lisKMAbortBuilding = 'Abort building';
  lisContinueBuilding = 'Continue building';
  lisKMRunProgram = 'Run program';
  lisKMPauseProgram = 'Pause program';
  lisKMViewProjectOptions = 'View project options';
  srkmCatPackageMenu = 'Package menu commands';
  srkmCatToolMenu       = 'Tools menu commands';
  lisKMExternalToolsSettings = 'External Tools settings';
  lisKMConvertDelphiPackageToLazarusPackage = 'Convert Delphi package to Lazarus package';
  srkmCarHelpMenu       = 'Help menu commands';
  lisKeyCatDesigner     = 'Designer commands';
  lisKMCopySelectedComponentsToClipboard = 'Copy selected components';
  lisKMCutSelectedComponentsToClipboard = 'Cut selected components';
  lisKMPasteComponentsFromClipboard = 'Paste Components';
  lisKeyCatObjInspector = 'Object Inspector commands';
  lisKeyCatCustom       = 'Custom commands';

  // Unit dependencies
  dlgUnitDepRefresh      = 'Refresh';

  // Build Lazarus dialog
  lisConfirmLazarusRebuild = 'Do you want to rebuild Lazarus with profile: %s?';
  lisConfirmation = 'Confirmation';
  lisPkgTheProjectOverridesTheOutputDirectoryOfTheFollowin = 'The project '
    +'overrides the output directory of the following packages.'
    +'%sSee Project / Project Options (compiler options section) / Additions and Overrides'
    +'%s%s';
  lisConfirmBuildAllProfiles = 'Lazarus will be rebuilt with the following profiles:%sContinue?';
  lisNoBuildProfilesSelected = 'No profiles are selected to be built.';
  lisCleanLazarusSource = 'Clean Lazarus Source';
  lisBuildIDE = 'Build IDE';
  lisMakeNotFound = 'Make not found';
  lisTheProgramMakeWasNotFoundThisToolIsNeededToBuildLa = 'The program "make" '
    +'was not found.%sThis tool is needed to build Lazarus.';
  lisIDE = 'IDE';
  lisConfigureBuildLazarus = 'Configure "Build Lazarus"';
  lisLazBuildOptions = '&Options:';
  lisLazBuildTargetOS = 'Target OS:';
  lisLazBuildTargetCPU = 'Target CPU:';
  lisLazBuildTargetDirectory = 'Target directory:';
  lisLazBuildRestartAfterBuild = '&Restart after building IDE';
  lisLazBuildUpdateRevInc = 'Update revision.inc';
  lisLazBuildCommonSettings = 'Common Settings';
  lisLazBuildConfirmBuild = 'Confirm before build';
  lisPERemoveFiles = 'Remove files';
  lisLazBuildNewProf = 'Add New Profile';
  lisLazBuildNewProfInfo = 'Current build options will be associated with:';
  lisKeep2 = 'Keep';
  lisRemoveIncludePath = 'Remove include path?';
  lisTheDirectoryContainsNoProjectIncludeFilesAnyMoreRe = 'The directory "%s" '
    +'contains no project include files any more. Remove this directory from '
    +'the project''s include search path?';
  lisLazBuildRenameProf = 'Rename Profile';
  lisLazBuildRenameProfInfo = 'New name for profile:';
  lisCTDTemplates = 'Templates';
  lisSaveSettings = '&Save Settings';
  lisCleanUpMode = 'Clean up mode';
  lisLazBuildBuildMany = 'Build &Many';
  lisAutomatically = 'Automatic';
  lisCleanAll = '&Clean all';
  lisCleanOnlyOnce = 'Switch to "automatic" mode after building';
  lisAfterCleaningUpSwitchToAutomaticClean = 'After building with cleaning all switch to '
    +'"automatic" clean up mode';
  lisLazBuildManageProfiles ='Manage Build Profiles';
  lisLazBuildProfile ='&Profile to build';
  lisLazBuildErrorWritingFile = 'Error writing file';
  lisLazBuildUnableToWriteFile = 'Unable to write file "%s":%s';
  lisLazBuildNormalIDE = 'Normal IDE';
  lisLazBuildDebugIDE = 'Debug IDE';
  lisLazBuildOptimizedIDE = 'Optimized IDE';
  lisLazCleanUpBuildAll = 'Clean Up + Build all';

  lisLazBuildABOChooseOutputDir = 'Choose output directory of the IDE executable ';
  lisLazBuildDefines = '&Defines';
  lisLazBuildEditDefines = 'Edit Defines';
  lisLazBuildNameOfTheActiveProfile = 'Name of the active profile';
  lisLazBuildManageProfiles2 = 'Manage profiles';
  lisLazBuildDefinesWithoutD = 'Defines without -d';
  lisLazBuildOptionsPassedToCompiler = 'Options passed to compiler';
  lisLazBuildShowOptionsAndDefinesForCommandLine = 'Show options and defines '
    +'for command line';
  lisLazBuildUpdateRevisionInfoInAboutLazarusDialog = 'Update revision info '
    +'in "About Lazarus" dialog';
  lisLazBuildRestartLazarusAutomatically = 'Restart Lazarus automatically after '+
    'building the IDE (has no effect when building other parts)';
  lisLazBuildShowConfirmationDialogWhenBuilding = 'Show confirmation dialog when '+
    'building directly from Tools menu';
  lisLazBuildEditListOfDefinesWhichCanBeUsedByAnyProfile = 'Edit list of '
    +'defines which can be used by any profile';
  lisLazBuildConfirmDeletion = 'Confirm deletion';
  lisLazBuildAreYouSureYouWantToDeleteThisBuildProfile = 'Are you sure you '
    +'want to delete this build profile?';
  lisLazBuildSelectProfilesToBuild = 'Select profiles to build';


  // compiler
  lisCompilerErrorInvalidCompiler = 'Error: invalid compiler: %s';
  lisCompilerHintYouCanSetTheCompilerPath = 'Hint: you can set the compiler '
    +'path in Tools -> Options-> Files -> Compiler Path';
  lisCompileProject = 'Compile Project';
  lisMode = ', Mode: %s';
  lisOS = ', OS: %s';
  lisCPU = ', CPU: %s';
  lisTarget2 = ', Target: %s';
  lisCompilerNOTELoadingOldCodetoolsOptionsFile = 'NOTE: loading old '
    +'codetools options file: ';
  lisCompilerNOTECodetoolsConfigFileNotFoundUsingDefaults = 'NOTE: codetools '
    +'config file not found - using defaults';
     
  // codetools options dialog
  lisCodeToolsOptsNone        = 'None';
  lisCodeToolsOptsKeyword     = 'Keyword';
  lisCodeToolsOptsIdentifier  = 'Identifier';
  lisFRIAdditionalFilesToSearchEGPathPasPath2Pp = 'Additional files to '
    +'search (e.g. /path/*.pas;/path2/*.pp)';
  lisFRIFindReferences = 'Find References';
  lisFRIInvalidIdentifier = 'Invalid Identifier';
  lisFRIRenaming = 'Renaming';
  lisFRISearchInCommentsToo = 'Search in comments too';
  lisFRISearch = 'Search';
  lisFindOverridesToo = 'Find overrides too';
  lisIncludeLFMs = 'Including LFM files';
  lisCodeToolsOptsColon       = 'Colon';
  lisCodeToolsOptsSemicolon   = 'Semicolon';
  lisCodeToolsOptsComma       = 'Comma';
  lisCodeToolsOptsPoint       = 'Point';
  lisCodeToolsOptsAt          = 'At';
  lisCodeToolsOptsNumber      = 'Number';
  lisCodeToolsOptsStringConst = 'String constant';
  lisCodeToolsOptsNewLine     = 'Newline';
  lisCodeToolsOptsSpace       = 'Space';
  lisCodeToolsOptsSymbol      = 'Symbol';
  lisCodeToolsOptsString      = 'String';
  lisCodeToolsOptsComment= 'Comment';
  lisCodeToolsOptsCommentSlash= 'Slash Comment: //';
  lisCodeToolsOptsCommentAnsi = 'ANSI Comment: (*';
  lisCodeToolsOptsCommentBor  = 'Curly Comment: {';
  lisCodeToolsOptsBracket     = 'Bracket';
  lisCodeToolsOptsCaret       = 'Caret (^)';

  // codetools defines
  lisErrorWritingFile = 'Error writing file "%s"';
  lisFPDocErrorWriting = 'Error writing "%s"%s%s';
  lisFPDocFPDocSyntaxError = 'FPDoc syntax error';
  lisFPDocThereIsASyntaxErrorInTheFpdocElement = 'There is a syntax error in '
    +'the fpdoc element "%s":%s%s';
  lisChooseAnExampleFile = 'Choose an example file';
  lisStopDebugging2 = 'Stop debugging?';
  lisStopCurrentDebuggingAndRebuildProject = 'Stop current debugging and rebuild project?';
  lisErrorWritingPackageListToFile = 'Error writing package list to file%s%s%s%s';
  lisUnableToRead = 'Unable to read %s';
  lisErrorReadingPackageListFromFile = 'Error reading package list from file%s%s%s%s';
  lisDuplicate = 'Duplicate';
  lisThePackageIsAlreadyInTheList = 'The package %s is already in the list';
  lisConflict = 'Conflict';
  lisThereIsAlreadyAPackageInTheList = 'There is already a package %s in the list';
  lisDownload = 'Download';
  lisDonwloadOnlinePackages = 'The following package(s) are not available locally: %s.' + sLineBreak +
    'In order to install it, you must download them first. Download now?';
  lisNotADesigntimePackage = 'Not a designtime package';
  lisThePackageCanNotBeInstalledBecauseItRequiresWhichI = 'The package %s cannot be '
    +'installed because it requires the package "%s" which is a runtime only package.';
  lisUninstall = 'Uninstall %s';
  lisThePackageIsNotADesignTimePackageItCanNotBeInstall = 'The package %s is '
    +'not a design time package. It cannot be installed in the IDE.';
  lisUninstallImpossible = 'Uninstall impossible';
  lisThePackageCanNotBeUninstalledBecauseItIsNeededByTh = 'The package %s can '
    +'not be uninstalled because it is needed by the IDE itself.';
  lisUninstBasePackagesSkipped =
    'Some packages were not uninstalled because they are needed by the IDE itself.';
  lisCodeToolsDefsNodeIsReadonly = 'Node is readonly';
  lisCodeToolsDefsAutoGeneratedNodesCanNotBeEdited = 'Auto generated nodes '
    +'cannot be edited.';
  lisCodeToolsDefsInvalidPreviousNode = 'Invalid previous node';
  lisCodeToolsDefsPreviousNodeCanNotContainChildNodes = 'Previous node can '
    +'not contain child nodes.';
  lisCodeToolsDefsCreateFPCMacrosAndPathsForAFPCProjectDirectory = 'Create '
    +'FPC Macros and paths for a fpc project directory';
  lisCodeToolsDefsTheFreePascalProjectDirectory = 'The Free Pascal project directory.';
  lisCodeToolsDefscompilerPath = 'Compiler path';
  lisCodeToolsDefsThePathToTheFreePascalCompilerForThisProject = 'The path to '
    +'the Free Pascal compiler for this project. Only required if you set the '
    +'FPC Git source below. Used to autocreate macros.';
  lisCodeToolsDefsFPCSVNSourceDirectory = 'FPC Git source directory';
  lisCodeToolsDefsTheFreePascalCVSSourceDirectory = 'The Free Pascal Git source '
    +'directory. Not required. This will improve find declaration and debugging.';
  lisCodeToolsDefsCreateDefinesForFreePascalCompiler = 'Create Defines for '
    +'Free Pascal Compiler';
  lisCodeToolsDefsThePathToTheFreePascalCompilerForThisSourceUsedToA = 'The path to '
    +'the Free Pascal compiler for this source.%sUsed to autocreate macros.';
  lisCodeToolsDefsValueIsInvalid = '%s:%svalue "%s" is invalid.';
  lisCodeToolsDefsThePathToTheFreePascalCompilerForExample = 'The '
    +'path to the Free Pascal compiler.%s For example %s/usr/bin/%s -n%s '
    +'or %s/usr/local/bin/fpc @/etc/fpc.cfg%s.';
  lisCodeToolsDefsCreateDefinesForFreePascalSVNSources = 'Create Defines for '
    +'Free Pascal Git Sources';
  lisCodeToolsDefsTheFreePascalSVNSourceDir = 'The Free Pascal Git source directory.';
  lisCodeToolsDefsCreateDefinesForDirectory = 'Create Defines for %s Directory';
  lisCodeToolsDefsdirectory = '%s directory';
  lisCodeToolsDefsDelphiMainDirectoryDesc = 'The %s main directory,%swhere '
    +'Borland has installed all %s sources.%sFor example: C:/Programme/'
    +'Borland/Delphi%s';
  lisCodeToolsDefsKylixMainDirectoryDesc = 'The %s main directory,%swhere '
    +'Borland has installed all %s sources.%sFor example: /home/user/kylix%s';
  lisCodeToolsDefsCreateDefinesForProject = 'Create Defines for %s Project';
  lisCodeToolsDefsProjectDirectory = 'Project directory';
  lisCodeToolsDefsprojectDirectory2 = '%s project directory';
  lisCodeToolsDefsTheProjectDirectory = 'The %s project directory,%swhich '
    +'contains the .dpr, dpk file.';
  lisCodeToolsDefsDelphiMainDirectoryForProject = 'The %s main directory,%s'
    +'where Borland has installed all %s sources,%swhich are used by this %s '
    +'project.%sFor example: C:/Programme/Borland/Delphi%s';
  lisCodeToolsDefsKylixMainDirectoryForProject = 'The %s main directory,%s'
    +'where Borland has installed all %s sources,%swhich are used by this %s '
    +'project.%sFor example: /home/user/kylix%s';
  lisCodeToolsDefsMoveNodeUp = 'Move node up';
  lisCodeToolsDefsMoveNodeDown = 'Move node down';
  lisCodeToolsDefsMoveNodeOneLevelUp = 'Move node one level up';
  lisCodeToolsDefsMoveNodeOneLevelDown = 'Move node one level down';
  lisCodeToolsDefsInsertNodeBelow = 'Insert node below';
  lisCodeToolsDefsInsertNodeAsChild = 'Insert node as child';
  lisCodeToolsDefsDeleteNode = 'Delete node';
  lisCodeToolsDefsConvertNode = 'Convert node';
  lisCodeToolsDefsDefine = 'Define';
  lisCodeToolsDefsDefineRecurse = 'Define Recurse';
  lisCodeToolsDefsUndefine = 'Undefine';
  lisCodeToolsDefsUndefineRecurse = 'Undefine Recurse';
  lisCodeToolsDefsUndefineAll = 'Undefine All';
  lisCodeToolsDefsBlock = 'Block';
  lisCodeToolsDefsInsertBehindDirectory = 'Directory';
  lisCodeToolsDefsIf = 'If';
  lisCodeToolsDefsIfDef = 'IfDef';
  lisCodeToolsDefsIfNDef = 'IfNDef';
  lisCodeToolsDefsElseIf = 'ElseIf';
  lisCodeToolsDefsElse = 'Else';
  lisCTDefsTools = 'Tools';
  lisCTDefsOpenPreview = 'Open Preview';
  lisCodeToolsDefsInsertTemplate = 'Insert Template';
  lisCodeToolsDefsInsertFreePascalProjectTe = 'Insert Free Pascal Project Template';
  lisCodeToolsDefsInsertFreePascalCompilerT = 'Insert Free Pascal Compiler Template';
  lisCodeToolsDefsInsertFreePascalSVNSource = 'Insert Free Pascal Git Source Template';
  lisCodeToolsDefsInsertDelphi5CompilerTemp = 'Insert Delphi 5 Compiler Template';
  lisCodeToolsDefsInsertDelphi5DirectoryTem = 'Insert Delphi 5 Directory Template';
  lisCodeToolsDefsInsertDelphi5ProjectTempl = 'Insert Delphi 5 Project Template';
  lisCodeToolsDefsInsertDelphi6CompilerTemp = 'Insert Delphi 6 Compiler Template';
  lisCodeToolsDefsInsertDelphi6DirectoryTem = 'Insert Delphi 6 Directory Template';
  lisCodeToolsDefsInsertDelphi6ProjectTempl = 'Insert Delphi 6 Project Template';
  lisCodeToolsDefsInsertDelphi7CompilerTemp = 'Insert Delphi 7 Compiler Template';
  lisCodeToolsDefsInsertDelphi7DirectoryTem = 'Insert Delphi 7 Directory Template';
  lisCodeToolsDefsInsertDelphi7ProjectTempl = 'Insert Delphi 7 Project Template';
  lisCodeToolsDefsInsertKylix3CompilerTemp = 'Insert Kylix 3 Compiler Template';
  lisCodeToolsDefsInsertKylix3DirectoryTem = 'Insert Kylix 3 Directory Template';
  lisCodeToolsDefsInsertKylix3ProjectTempl = 'Insert Kylix 3 Project Template';
  lisCodeToolsDefsSelectedNode = 'Selected Node:';
  lisCodeToolsDefsName = 'Name:';
  lisOnlyMessagesWithTheseFPCIDsCommaSeparated = 'Only messages with these FPC'
    +' IDs (comma separated):';
  lisOnlyMessagesFittingThisRegularExpression = 'Only messages fitting this regular expression:';
  lisURLOnWikiTheBaseUrlIs = 'URL on wiki (the base url is %s)';
  lisTestURL = 'Test URL';
  lisDeleteThisAddition = 'Delete this addition';
  lisDelete2 = 'Delete?';
  lisDeleteAddition = 'Delete addition "%s"?';
  lisNoneSelected = '(None selected)';
  lisSelectedAddition = 'Selected addition:';
  lisNoMessageSelected = '(no message selected)';
  lisAdditionFitsTheCurrentMessage = 'Addition fits the current message';
  lisAdditionDoesNotFitTheCurrentMessage = 'Addition does not fit the current message';
  lisFilterAlreadyExists = 'Filter already exists';
  lisAFilterWithTheNameAlreadyExists = 'A filter with the name "%s" already exists.';
  lisSaveMessages = 'Save messages';
  lisCodeToolsDefsDescription = 'Description:';
  lisCodeToolsDefsVariable = 'Variable:';
  lisCodeToolsDefsValueAsText = 'Value as Text';
  lisCodeToolsDefsValueAsFilePaths = 'Value as File Paths';
  lisCodeToolsDefsAction = 'Action: %s';
  lisCodeToolsDefsautoGenerated = '%s, auto generated';
  lisCodeToolsDefsnoneSelected = 'none selected';
  lisCodeToolsDefsInvalidParent = 'Invalid parent';
  lisACanNotHoldTControlsYouCanOnlyPutNonVisualComponen = 'A %s cannot hold TControls.'
    +'%sYou can only put nonvisual components on it.';
  lisUpdateReferences = 'Update references?';
  lisTheUnitIsUsedByOtherFilesUpdateReferencesAutomatic = 'The unit %s is used by other files.'
    +'%sUpdate references automatically?';
  lisCodeToolsDefsAutoCreatedNodesReadOnly = 'Auto created nodes cannot be edited,'
    +'%snor can they have non auto created child nodes.';
  lisCodeToolsDefsInvalidParentNode = 'Invalid parent node';
  lisCodeToolsDefsParentNodeCanNotContainCh = 'Parent node cannot contain child nodes.';
  lisCodeToolsDefsNewNode = 'NewNode';

  // code template dialog
  lisCodeTemplAddCodeTemplate = 'Add code template';
  lisCodeTemplAdd = 'Add template ...';
  lisCodeTemplEditCodeTemplate = 'Edit code template';
  lisCodeTemplAutoCompleteOn = 'Auto complete on';
  lisCodeTemplToken = 'Token:';
  lisCodeTemplComment = 'Comment:';
  lisCodeTemplErrorAlreadyExists = 'A token already exists.';
  lisCodeTemplErrorInvalidName = 'The token can only contain Latin letters, numbers and underscores, and cannot begin with a number.';
  lisCodeTemplErrorEmptyName = 'The token cannot be empty.';
  lisCodeTemplError = 'Error';
  lisUnableToFindTheComponentClassItIsNotRegisteredViaR = 'Unable to find the component class "%s".'
    +'%sIt is not registered via RegisterClass and no lfm was found.'
    +'%sIt is needed by unit:'
    +'%s%s';
  lisNoTemplateSelected = 'no template selected';
  lisUnableToOpenDesignerTheClassDoesNotDescendFromADes = 'Unable to open '
    +'designer.%sThe class %s does not descend from a designable class like '
    +'TForm or TDataModule.';
  lisIgnoreUseAsAncestor = 'Ignore, use %s as ancestor';
  lisUnableToLoadTheComponentClassBecauseItDependsOnIts = 'Unable to load the '
    +'component class "%s" because it depends on itself.';
  lisCancelLoadingThisComponent = 'Cancel loading this component';
  lisTheResourceClassDescendsFromProbablyThisIsATypoFor = 'The resource '
    +'class "%s" descends from "%s". Probably this is a typo for TForm.';

  // make resourcestring
  lisMakeResourceString = 'Make ResourceString';
  lisMakeResStrInvalidResourcestringSect = 'Invalid Resourcestring section';
  lisMakeResStrPleaseChooseAResourcestring = 'Please choose a resourcestring '
    +'section from the list.';
  lisMakeResStrResourcestringAlreadyExis = 'Resourcestring already exists';
  lisMakeResStrChooseAnotherName = 'The resourcestring "%s" already exists.'
    +'%sPlease choose another name.'
    +'%sUse Ignore to add it anyway.';
  lisMakeResStrStringConstantInSource = 'String constant in source';
  lisMakeResStrConversionOptions = 'Conversion Options';
  lisMakeResStrIdentifierPrefix = 'Identifier prefix:';
  lisMakeResStrIdentifierLength = 'Identifier length:';
  lisMakeResStrDialogIdentifier = 'Identifier';
  lisMakeResStrCustomIdentifier = 'Custom identifier';
  lisMakeResStrResourcestringSection = 'Resourcestring section:';
  lisMakeResStrStringsWithSameValue = 'Strings with same value:';
  lisMakeResStrAppendToSection = 'Append to section';
  lisMakeResStrInsertAlphabetically = 'Insert alphabetically';
  lisMakeResStrInsertContexttSensitive = 'Insert context sensitive';
  lisMakeResStrSourcePreview = 'Source preview';
  lisNoStringConstantFound = 'No string constant found';
  lisSelectionExceedsStringConstant = 'Selection exceeds string constant';
  lisInvalidExpressionHintTheMakeResourcestringFunction = 'Invalid expression.'
    +'%sHint: The "Make Resourcestring" function expects a string constant in a '
    +'single file. Please select the expression and try again.';
  lisHintTheMakeResourcestringFunctionExpectsAStringCon =
    'Hint: The "Make Resourcestring" function expects a string constant.'
    +'%sPlease select the expression and try again.';
  lisNoResourceStringSectionFound = 'No ResourceString Section found';
  lisUnableToFindAResourceStringSectionInThisOrAnyOfThe = 'Unable to find a '
    +'ResourceString section in this or any of the used units.';

  lisFailedToResolveMacros = 'failed to resolve macros';
  lisToolHasNoExecutable = 'tool "%s" has no executable';
  lisCanNotFindExecutable = 'cannot find executable "%s"';
  lisMissingExecutable = 'missing executable "%s"';
  lisExecutableIsADirectory = 'executable "%s" is a directory';
  lisExecutableLacksThePermissionToRun = 'executable "%s" lacks the permission to run';
  lisParser = 'parser "%s": %s';
  lisInvalidMacrosIn = 'Invalid macros in "%s"';
  lisAllBlocksLooksOk = 'All blocks look ok.';
  lisTheApplicationBundleWasCreatedFor = 'The Application Bundle was created for "%s"';

  //codetools ChooseClassSectionDlg
  lisCodeCreationDialogCaption = 'Code creation options';
  lisCodeCreationDialogLocation = 'Location';
  lisLocal = '&Local';
  lisClass = '&Class';
  lisYouCanSelectItemsBySimplyPressingUnderscoredLetter = 'You can select '
    +'items by simply pressing underscored letters';
  lisCodeCreationDialogClassSection = 'Class section';

  // diff dialog
  lisDiffDlgFile1 = 'File1';
  lisDiffDlgOnlySelection = 'Only selection';
  lisDiffDlgFile2 = 'File2';
  lisDiffDlgCaseInsensitive = 'Case Insensitive';
  lisDiffDlgIgnoreIfEmptyLinesWereAdd = 'Ignore if empty lines were added or removed';
  lisDiffDlgIgnoreSpacesAtStartOfLine = 'Ignore spaces at start of line';
  lisDiffDlgIgnoreSpacesAtEndOfLine = 'Ignore spaces at end of line';
  lisDiffDlgIgnoreIfLineEndCharsDiffe = 'Ignore difference in line ends (e.'
    +'g. #10 = #13#10)';
  lisDiffDlgIgnoreIfSpaceCharsWereAdd = 'Ignore amount of space chars';
  lisDiffDlgIgnoreSpaces = 'Ignore spaces (newline chars not included)';
  lisDiffDlgOpenDiffInEditor = 'Open difference in editor';

  // packages
  lisCreateNewPackage = '(Create new package)';
  lisCreateNewPackageComponent = 'Create new package component';
  lisMenuNewComponent = 'New Component';
  lisPkgSelectAPackage = 'Select a package';

  // unit info dialog
  lisInformationAboutUnit = 'Information about %s';
  lisUIDyes = 'yes';
  lisUIDno = 'no';
  lisUIDbytes = '%s bytes';
  lisUIDName = 'Name:';
  lisUIDType = 'Type:';
  lisUIDinProject = 'In project:';
  lisUIDIncludedBy = 'Included by:';
  lisUIDSize = 'Size:';
  lisUIDLines = 'Lines:';
  lisUIShowCodeToolsValues = 'Show CodeTools Values';
  
  // unit editor
  lisUEErrorInRegularExpression = 'Error in regular expression';
  lisUENotFound = 'Not found';
  lisUESearchStringNotFound = 'Search string ''%s'' not found!';
  lisUESearchStringContinueBeg = 'Continue search from the beginning?';
  lisUESearchStringContinueEnd = 'Continue search from the end?';
  lisUEReplaceThisOccurrenceOfWith = 'Replace this occurrence of "%s"%s with "%s"?';
  lisUESearching = 'Searching: %s';
  lisUEModeSeparator = '/';
  lisUEGotoLine = 'Goto line:';
  lisGotoLine = 'Goto Line';
  
  // System Variables Override Dialog
  lisSVUOInvalidVariableName = 'Invalid variable name';
  lisSVUOisNotAValidIdentifier = '"%s" is not a valid identifier.';
  lisFRIIdentifier = 'Identifier: %s';
  lisSVUOOverrideSystemVariable = 'Override system variable';
  
  // sort selection dialog
  lisSortSelSortSelection = 'Sort selection';
  lisSortSelPreview = 'Preview';
  lisSortSelAscending = 'Ascending';
  lisSortSelDescending = 'Descending';
  lisSortSelDomain = 'Domain';
  lisSortSelLines = 'Lines';
  lisSortSelWords = 'Words';
  lisSortSelParagraphs = 'Paragraphs';
  lisSortSelOptions = 'Options';
  lisSortSelCaseSensitive = '&Case Sensitive';
  lisSortSelIgnoreSpace = 'Ignore Space';
  lisSortSelSort = 'Accept';

  // Publish project/package + Add dir to package
  lisDestinationDirectory = 'Destination directory';
  lisChooseDirectory = 'Choose directory';
  lisCompress = 'Compress';
  lisCompressHint = 'The resulting directory will be compressed into a ZIP file.';
  lisOpenInFileMan = 'Open in file manager';
  lisOpenInFileManHint = 'Open destination directory in file manager';
  lisPublishModuleNote = 'Files belonging to project / package will be included automatically.';
  lisSimpleSyntax = 'Simple syntax';
  lisNormallyTheFilterIsARegularExpressionInSimpleSynta = 'Normally the '
    +'filter is a regular expression. In simple syntax a . is a normal '
    +'character, a * stands for anything, a ? stands for any character, and '
    +'comma and semicolon separates alternatives. For example: Simple '
    +'syntax *.pas;*.pp corresponds to ^(.*\.pas|.*\.pp)$';
  lisUseFilterForExtraFiles = 'Use filter to include extra files';
  lisCopyFilesFailed = 'Copying files failed.';
  lisWriteProjectInfoFailed = 'Writing the project info file failed.';
  lisWritePackageInfoFailed = 'Writing the package info file failed.';
  lisPublishedTo = 'Published to %s';
  lisInvalidPublishingDirectory = 'Invalid publishing Directory';
  lisEmptyDestinationForPublishing = 'Destination directory for publishing'
    +' is either a relative path or empty.';
  lisSourceAndDestinationAreSame = 'Source "%s"'
    +'%sand Destination "%s"'
    +'%sdirectories are the same. Please select another directory.';
  lisClearDirectory = 'Clear Directory?';
  lisInOrderToCreateACleanCopyOfTheProjectPackageAllFil = 'In order to create '
    +'a clean copy of the project/package, all files in the following '
    +'directory will be deleted and all its content will be lost.'
    +'%sDelete all files in "%s"?';
  lisUnableToCleanUpDestinationDirectory = 'Unable to clean up destination directory';
  lisUnableToCleanUpPleaseCheckPermissions = 'Unable to clean up "%s".%sPlease check permissions.';
  lisFilter = 'Filter';
  lisCreateFilter = 'Create Filter';
  lisIssues = 'Issues';
  lisRegularExpression = 'Regular expression';
  lisInvalidFilter = 'Invalid filter';

  // project options
  lisProjOptsUnableToChangeTheAutoCreateFormList = 'Unable to change the auto '
    +'create form list in the program source.%sPlease fix errors first.';
  lisProjOptsError = 'Error';
  lisUnableToChangeProjectTitleInSource = 'Unable to change project title in '
    +'source.%s%s';
  lisUnableToRemoveProjectTitleFromSource = 'Unable to remove project title '
    +'from source.%s%s';
  lisUnableToChangeProjectScaledInSource = 'Unable to change project scaled in '
    +'source.%s%s';
  lisUnableToRemoveProjectScaledFromSource = 'Unable to remove project scaled '
    +'from source.%s%s';

  // path edit dialog
  lisPathEditSearchPaths = 'Search paths:';
  lisPckSearchPathsForFpdocXmlFilesMultiplePathsMustBeSepa = 'Search paths for'
    +' fpdoc xml files. Multiple paths must be separated by semicolon.';
  lisPathEditMovePathDown = 'Move path down (Ctrl+Down)';
  lisPathEditMovePathUp = 'Move path up (Ctrl+Up)';
  lisPathEditBrowse = 'Browse';
  lisPathEditorReplaceHint = 'Replace the selected path with a new path';
  lisPathEditorAddHint = 'Add new path to the list';
  lisPathEditDeleteInvalidPaths = 'Delete Invalid Paths';
  lisPathEditorDeleteHint = 'Delete the selected path';
  lisPathEditorDeleteInvalidHint = 'Remove non-existent (gray) paths from the list';
  lisPathEditPathTemplates = 'Path templates';
  lisPathEditorTemplAddHint = 'Add template to the list';

  // new dialog
  lisNewDlgNoItemSelected = 'No item selected';
  lisUnitMustSaveBeforeInherit = 'Unit "%s" must be saved before it can be inherited from. Save now?';
  lisErrorOpeningComponent = 'Error opening component';
  lisUnableToOpenAncestorComponent = 'Unable to open ancestor component';
  lisNewDlgPleaseSelectAnItemFirst = 'Please select an item first.';
  lisNewDlgCreateANewEditorFileChooseAType = 'Create a new editor file.%s'
    +'Choose a type.';
  lisNewDlgCreateANewProjectChooseAType = 'Create a new project.%sChoose a type.';
  lisChooseOneOfTheseItemsToCreateANewFile = 'Choose one of these items to '
    +'create a new File';
  lisChooseOneOfTheseItemsToInheritFromAnExistingOne = 'Choose one of these items to '
    +'inherit from an existing one';
  lisInheritedItem = 'Inherited Item';
  lisChooseOneOfTheseItemsToCreateANewProject = 'Choose one of these items to '
    +'create a new Project';
  lisChooseOneOfTheseItemsToCreateANewPackage = 'Choose one of these items to '
    +'create a new Package';
  lisNewDlgCreateANewUnitWithALCLForm = 'Create a new unit with a LCL form.';
  lisNewDlgCreateANewUnitWithADataModule = 'Create a new unit with a datamodule.';
  lisNewDlgCreateANewUnitWithAFrame = 'Create a new unit with a frame.';
  lisNewDlgCreateANewEmptyTextFile = 'Create a new empty text file.';
  lisNewDlgCreateANewStandardPackageAPackageIsACollectionOfUn = 'Create a new '
    +'standard package.%sA package is a collection of units and components.';

  // file checks
  lisCanNotCreateFile = 'Cannot create file "%s"';
  lisErrorDeletingFile = 'Error deleting file';
  lisInvalidMask = 'Invalid Mask';
  lisTheFileMaskIsNotAValidRegularExpression = 'The file mask "%s" is not a '
    +'valid regular expression.';
  lisTheFileMaskIsInvalid = 'The file mask "%s" is invalid.';
  lisUnableToDeleteAmbiguousFile = 'Unable to delete ambiguous file "%s"';
  lisErrorRenamingFile = 'Error renaming file';
  lisUnableToRenameAmbiguousFileTo = 'Unable to rename ambiguous file "%s"%sto "%s"';
  lisAmbiguousFileFound = 'Ambiguous file found';
  lisThereIsAFileWithTheSameNameAndASimilarExtension = 'There is a file with '
    +'the same name and a similar extension on disk%sFile: %s%sAmbiguous '
    +'File: %s%sDelete ambiguous file?';

  // add to project dialog
  lisProjAddInvalidMinMaxVersion = 'Invalid Min-Max version';
  lisProjAddTheMaximumVersionIsLowerThanTheMinimimVersion = 'The Maximum '
    +'Version is lower than the Minimim Version.';
  lisProjAddDependencyAlreadyExists = 'Dependency already exists';
  lisVersionMismatch = 'Version mismatch';
  lisUnableToAddTheDependencyBecauseThePackageHasAlread = 'Unable to add the '
    +'dependency %s because the package %s has already a dependency %s';
  lisCircularDependencyDetected = 'Circular dependency detected';
  lisUnableToAddTheDependencyBecauseThisWouldCreateA = 'Unable to add the '
    +'dependency %s because this would create a circular dependency. Dependency %s';
  lisProjAddTheProjectHasAlreadyADependency = 'The project has already a '
    +'dependency for the package "%s".';
  lisProjAddPackageNotFound = 'Package not found';
  lisLDTheUnitIsNotOwnedBeAnyPackageOrProjectPleaseAddThe = 'The unit %s is '
    +'not owned be any package or project.%sPlease add the unit to a package '
    +'or project.%sUnable to create the fpdoc file.';
  lisLDNoValidFPDocPath = 'No valid FPDoc path';
  lisTheUnitIsPartOfTheFPCSourcesButTheCorrespondingFpd = 'The unit %s is part'
    +' of the FPC sources but the corresponding fpdoc xml file was not found.'
    +'%sEither you have not yet added the fpcdocs directory to the search path or the '
    +'unit is not yet documented.%sThe fpdoc files for the FPC sources can be'
    +' downloaded from: %s%sPlease add the directory in the '
    +'fpdoc editor options.%sIn order to create a new file the directory must '
    +'be writable.';
  lisLDDoesNotHaveAnyValidFPDocPathUnableToCreateTheFpdo = '%s does not have '
    +'any valid FPDoc path.%sUnable to create the fpdoc file for %s';
  lisErrorReadingXML = 'Error reading XML';
  lisErrorReadingXmlFile = 'Error reading xml file "%s"%s%s';
  lisPkgThisFileIsNotInAnyLoadedPackage = 'This file is not in any loaded package.';
  lisProjAddTheDependencyWasNotFound = 'The dependency "%s" was not found.%sPlease choose an existing package.';
  lisProjAddInvalidVersion = 'Invalid version';
  lisProjAddTheMinimumVersionIsInvalid = 'The Minimum Version "%s" is invalid.'
    +'%sPlease use the format major.minor.release.build'
    +'%sFor example: 1.0.20.10';
  lisProjAddTheMaximumVersionIsInvalid = 'The Maximum Version "%s" is invalid.'
    +'%sPlease use the format major.minor.release.build'
    +'%sFor example: 1.0.20.10';
  lisProjAddUnitNameAlreadyExists = 'Unit name already exists';
  lisProjAddTheUnitNameAlreadyExistsInTheProject = 'The unit name "%s" '
    +'already exists in the project%swith file: "%s".';
  lisProjAddTheUnitNameAlreadyExistsInTheSelection = 'The unit name "%s" '
    +'already exists in the selection%swith file: "%s".';
  lisProjAddNewRequirement = 'New Requirement';
  lisProjAddNewFPMakeRequirement = 'New FPMake Requirement';
  lisProjAddEditorFile = 'Add Editor Files';
  lisProjAddPackageName = 'Package Name:';
  lisProjAddPackageType = 'Package Type:';
  lisProjAddLocalPkg = 'Local (%s)';
  lisProjAddOnlinePkg = 'Online (%s)';
  lisProjAddMinimumVersionOptional = 'Minimum Version (optional):';
  lisProjAddMaximumVersionOptional = 'Maximum Version (optional):';

  // component palette
  lisKMNewPackage = 'New package';
  lisCompPalOpenPackage = 'Open package';
  lisKMOpenPackageFile = 'Open package file';
  lisKMOpenRecentPackage = 'Open recent package';
  lisCPOpenPackage = 'Open Package %s';
  lisFilterAllMessagesOfType = 'Filter all messages of type %s';
  lisFilterAllMessagesOfCertainType = 'Filter all messages of certain type';
  lisOpenToolOptions = 'Open Tool Options';
  lisCPOpenUnit = 'Open Unit %s';
  lisCompPalOpenUnit = 'Open unit';
  lisCompPalComponentList = 'View All';

  // macro promp dialog
  lisMacroPromptEnterData = 'Enter data';
  lisMacroPromptEnterRunParameters = 'Enter run parameters';
  
  // debugger
  lisDebuggerErrorOoopsTheDebuggerEnteredTheErrorState =
    'The debugger encountered an internal error.'
    +'%0:s%0:sSave your work.'
    +'%0:sYou may then hit "Stop", or "Reset debugger" to terminate the debug session.';
  lisExecutionStopped = 'Execution stopped';
  lisExecutionStoppedExitCode = 'Execution stopped with exit-code %1:d ($%2:s)';
  lisFileNotFound = 'File not found';
  lisDisableOptionXg = 'Disable Option -Xg?';
  lisTheProjectWritesTheDebugSymbolsToAnExternalFileThe = 'The project writes '
    +'the debug symbols to an external file. The "%s" supports only symbols '
    +'within the executable.';
  lisDisableOptionXg2 = 'Disable option -Xg';
  lisEnableOptionXg = 'Enable Option -Xg?';
  lisTheProjectWritesTheDebugSymbolsToTheExexcutable = 'The project writes '
    +'the debug symbols into the executable rather than to an external file. '
    + 'The "%s" supports only symbols in an external file.';
  lisEnableOptionDwarf2 = 'Enable Dwarf 2 (-gw)';
  lisEnableOptionDwarf2Sets = 'Enable Dwarf 2 with sets';
  lisEnableOptionDwarf3 = 'Enable Dwarf 3 (-gw3)';

  lisTheProjectDoesNotUseDwarf_TaskDlg_Caption = 'Running your application with debugger';
  lisTheProjectDoesNotUseDwarf_TaskDlg_Title = 'Choose Debug Information format';
  lisTheProjectDoesNotUseDwarf_TaskDlg_TextExplain = '"%s" can only run your application'
      + ' when it was compiled with a suitable Debug Information enabled.';
  lisTheProjectDoesNotUseDwarf_TaskDlg_NoDebugBtn_Caption = 'Run with no debugger';
  lisTheProjectDoesNotUseDwarf_TaskDlg_Footer = 'This choice can be later changed'
       + ' in Project -> Project Options -> Compiler Options -> Debugging.';

  lisCleanUpUnitPath = 'Clean up unit path?';
  lisTheDirectoryIsNoLongerNeededInTheUnitPathRemoveIt =
    'The directory "%s" is no longer needed in the unit path.%sRemove it?';
  lisTheFileWasNotFoundDoYouWantToLocateItYourself = 'The file "%s" was '
    +'not found.%sDo you want to locate it yourself?';
  lisRunToFailed = 'Run-to failed';
  lisDbgMangNoDebuggerSpecified = 'No debugger specified';
  lisDbgMangThereIsNoDebuggerSpecifiedSettingBreakpointsHaveNo = 'There is no '
    +'debugger specified.%sSetting breakpoints have no effect until you set up '
    +'a Debugger in the debugger options dialog in the menu.';
  lisDbgMangSetTheBreakpointAnyway = 'Set the breakpoint anyway';
  lisLaunchingApplicationInvalid = 'Launching application invalid';
  lisTheLaunchingApplicationDoesNotExistsOrIsNotExecuta = 'The launching application "%s"'
    +'%sdoes not exist or is not executable.'
    +'%sSee Run -> Run parameters -> Local';
  lisTheLaunchingApplicationBundleDoesNotExists = 'The Application Bundle %s'
    +'%sneeded for execution does not exist or is not executable.'
    +'%sDo you want to create one?'
    +'%sSee Project -> Project Options -> Application for settings.';
  lisDebuggerInvalid = 'Debugger invalid';
  lisTheDebuggerDoesNotExistsOrIsNotExecutableSeeEnviro = 'The debugger "%s"'
    +'%sdoes not exist or is not executable.'
    +'%sSee Tools -> Options -> Debugger options';
  lisUnableToRun = 'Unable to run';
  lisTheWorkingDirectoryDoesNotExistPleaseCheckTheWorki = 'The working '
    +'directory "%s" does not exist.%sPlease check the working directory in '
    +'Menu > Run > Run parameters.';
  lisPleaseOpenAUnitBeforeRun = 'Please open a unit before run.';

  lisDBGENDefaultColor = 'Default Color';
  lisDBGENBreakpointEvaluation = 'Breakpoint Evaluation';
  lisDBGENBreakpointHit = 'Breakpoint Hit';
  lisDBGENBreakpointMessage = 'Breakpoint Message';
  lisDBGENBreakpointStackDump = 'Breakpoint Stack Dump';
  lisDBGENExceptionRaised = 'Exception Raised';
  lisDBGENModuleLoad = 'Module Load';
  lisDBGENModuleUnload = 'Module Unload';
  lisDBGENOutputDebugString = 'Output Debug String';
  lisDBGENProcessExit = 'Process Exit';
  lisDBGENProcessStart = 'Process Start';
  lisDBGENThreadExit = 'Thread Exit';
  lisDBGENThreadStart = 'Thread Start';
  lisDBGENWindowsMessagePosted = 'Windows Message Posted';
  lisDBGENWindowsMessageSent = 'Windows Message Sent';

  // disk diff dialog
  lisDiskDiffErrorReadingFile = 'Error reading file: %s';
  lisLpkHasVanishedOnDiskUsingAsAlternative = 'lpk has vanished on disk. Using'
    +' as alternative%s';
  lisDiskDiffSomeFilesHaveChangedOnDisk = 'Some files have changed on disk:';
  lisDiskDiffClickOnOneOfTheAboveItemsToSeeTheDiff = 'Click on one of the '
    +'above items to see the diff';
  lisDiskDiffSomeFilesHaveLocalChanges = 'Some files have local changes.'
    +' Either local or external changes will be overwritten.';
  lisDiskDiffReloadCheckedFilesFromDisk = 'Reload checked files from disk';
  lisDiskDiffIgnoreAllDiskChanges = 'Ignore all disk changes';
  
  // external tools
  lisExtToolExternalTools = 'External Tools';
  lisTheseSettingsAreStoredWithTheProject = 'These settings are stored with '
    +'the project.';
  lisKeepThemAndContinue = 'Keep them and continue';
  lisRemoveThem = 'Remove them';
  lisExtToolMaximumToolsReached = 'Maximum Tools reached';
  lisExtToolThereIsAMaximumOfTools = 'There is a maximum of %s tools.';

  // edit external tools
  lisEdtExtToolEditTool = 'Edit Tool';
  lisEdtExtToolProgramfilename = 'Program Filename:';
  lisEdtExtToolParameters = 'Parameters:';
  lisEdtExtToolWorkingDirectory = 'Working Directory:';
  lisEdtExtToolScanOutputForFreePascalCompilerMessages = 'Scan output for '
    +'FPC messages';
  lisEdtExtToolScanOutputForMakeMessages = 'Scan output for "make" messages';
  lisShowConsole = 'Show console';
  lisOnlyAvailableOnWindowsRunToolInANewConsole = 'Only available on Windows. '
    +'Run tool in a new console.';
  lisEdtExtToolKey = 'Key';
  lisOnlyAvailableOnWindowsRunTheToolHidden = 'Only available on Windows. Run '
    +'the tool hidden.';
  lisHideWindow = 'Hide window';
  lisAlternativeKey = 'Alternative key';
  lisEdtExtToolMacros = 'Macros';
  lisWorkingDirectoryForBuilding = 'Working directory for building';
  lisWorkingDirectoryForRun = 'Working directory for run';
  lisConfigureBuild = 'Configure Build %s';
  lisEdtExtToolTitleAndFilenameRequired = 'Title and Filename required';
  lisEdtExtToolAValidToolNeedsAtLeastATitleAndAFilename = 'A valid tool needs '
    +'at least a title and a filename.';
    
  // find in files dialog
  lisFindFileMultiLinePattern = '&Multiline pattern';
  lisFindFileWhere = 'Search location';
  lisFindFilesearchAllFilesInProject = 'all files in &project';
  lisFindFilesearchAllOpenFiles = 'all &open files';
  lisFindFilesSearchInProjectGroup = 'project &group';
  lisFindFilesearchInActiveFile = '&active file';
  lisFindFilesearchInDirectories = '&directories';
  lisFindFileDirectories = 'D&irectories';
  lisMultipleDirectoriesAreSeparatedWithSemicolons = 'Multiple directories are'
    +' separated with semicolons';
  lisDirectories = 'Directories';
  lisFindFileFileMask = 'Fi&le mask';
  lisFindFileIncludeSubDirectories = 'Include &sub directories';
  lisFindFileReplacementIsNotPossible = 'This file contains characters that have '
    + 'different lengths in upper and lower case. The current implementation does '
    + 'not allow for correct replacement in this case (but you can use '
    + 'case-sensitive replacement). This file will have to be skipped:';

  // package manager
  lisPkgMangPackage = 'Package: %s';
  lisPkgMangProject = 'Project: %s';
  lisPkgMangDependencyWithoutOwner = 'Dependency without Owner: %s';
  lisLazbuildIsNonInteractiveAbortingNow = '%s'
    +'%s%s'
    +'%slazbuild is non interactive, aborting now.';
  lisPkgMangSavePackageLpk = 'Save Package %s (*.lpk)';
  lisPkgMangSaveAsAlreadyOpenedPackage = 'The package %s is already open in the IDE.'+sLineBreak+'You cannot save a package with the same name.';
  lisPkgMangInvalidPackageFileExtension = 'Invalid package file extension';
  lisPkgMangPackagesMustHaveTheExtensionLpk = 'Packages must have the '
    +'extension .lpk';
  lisPkgMangInvalidPackageName = 'Invalid package name';
  lisPkgMangInvalidPackageName2 = 'Invalid Package Name';
  lisPkgMangThePackageNameIsNotAValidPackageNamePleaseChooseAn = 'The package name '
    +'"%s" is not a valid package name%sPlease choose another name (e.g. package1.lpk)';
  lisPkgMangRenameFileLowercase = 'Rename File lowercase?';
  lisPkgMangShouldTheFileRenamedLowercaseTo = 'Should the file be renamed '
    +'lowercase to%s"%s"?';
  lisPkgMangPackageNameAlreadyExists = 'Package name already exists';
  lisNameConflict = 'Name conflict';
  lisThePackageAlreadyContainsAUnitWithThisName = 'The package already '
    +'contains a unit with this name.';
  lisPkgMangThereIsAlreadyAnotherPackageWithTheName = 'There is already '
    +'another package with the name "%s".%sConflict package: "%s"%sFile: "%s"';
  lisPkgMangFilenameIsUsedByProject = 'Filename is used by project';
  lisPkgMangTheFileNameIsPartOfTheCurrentProject = 'The file name "%s" is '
    +'part of the current project.%sProjects and Packages should not share files.';
  lisPkgMangFilenameIsUsedByOtherPackage = 'Filename is used by other package';
  lisPkgMangTheFileNameIsUsedByThePackageInFile = 'The file name "%s" is '
    +'used by%sthe package "%s"%sin file "%s".';
  lisPkgMangReplaceFile = 'Replace File';
  lisPkgMangReplaceExistingFile = 'Replace existing file "%s"?';
  lisPkgMangDeleteOldPackageFile = 'Delete Old Package File?';
  lisPkgMangDeleteOldPackageFile2 = 'Delete old package file "%s"?';
  lisSkipErrors = 'Skip errors';
  lisDeleteAllTheseFiles = 'Delete all these files?';
  lisCheckUncheckAll = 'Check/uncheck all';
  lisPkgMangUnsavedPackage = 'Unsaved package';
  lisPkgMangThereIsAnUnsavedPackageInTheRequiredPackages = 'There is an '
    +'unsaved package in the required packages. See package graph.';
  lisPkgMangBrokenDependency = 'Broken dependency';
  lisPkgMangTheProjectRequiresThePackageButItWasNotFound = 'The project requires '
    +'the package "%s".%sBut it was not found. See Project -> Project Inspector.';
  lisPkgMangRequiredPackagesWereNotFound = 'One or more required packages were not '
    +'found. See package graph for details.';
  lisPkgMangCircularDependencies = 'Circular dependencies found';
  lisPkgMangThePackageIsCompiledAutomaticallyAndItsOutputDirec = 'The package "%s" '
    +'is compiled automatically and its output directory is "%s" which is in the '
    +'default unit search path of the compiler. The package uses other packages which '
    +'also use the default unit search of the compiler. This creates an endless loop.'
    +'%sYou can fix this issue by removing the path from your compiler config (e.g. fpc.cfg)'
    +'%sor by disabling the auto update of this package or by removing dependencies.';
  lisPkgMangThereIsACircularDependency = 'There is a circular dependency in the '
    +'packages. See package graph.';
  lisPkgMangThereAreTwoUnitsWithTheSameName1From2From = 'There are two units with the same name:'
    +'%s1. "%s" from %s'
    +'%s2. "%s" from %s';
  lisPkgMangThereIsAUnitWithTheSameNameAsAPackage1From2 = 'There is a unit with the same name as a package:'
    +'%s1. "%s" from %s'
    +'%s2. "%s"';
  lisPkgMangAmbiguousUnitsFound = 'Ambiguous units found';
  lisPkgMangBothPackagesAreConnectedThisMeansEitherOnePackageU = '%sBoth '
    +'packages are connected. This means, either one package uses the other, '
    +'or they are both used by a third package.';
  lisPkgMangThereIsAFPCUnitWithTheSameNameFrom = 'There is a FPC unit with '
    +'the same name as:%s"%s" from %s';
  lisPkgMangThereIsAFPCUnitWithTheSameNameAsAPackage = 'There is a FPC unit '
    +'with the same name as a package:'
    +'%s"%s"';
  lisOpenPackage2 = 'Open package %s';
  lisPkgMangThePackageNameOfTheFileIsInvalid = 'The package name "%s" of'
    +'%sthe file "%s" is invalid.';
  lisPkgMangPackageConflicts = 'Package conflicts';
  lisPkgMangThereIsAlreadyAPackageLoadedFromFile = 'There is already a package "%s" loaded'
    +'%sfrom file "%s".'
    +'%sSee Package -> Package Graph.'
    +'%sReplace is impossible.';
  lisPkgMangSavePackage = 'Save package?';
  lisPkgMangLoadingPackageWillReplacePackage = 'Loading package %s will replace package %s'
    +'%sfrom file %s.'
    +'%sThe old package is modified.'
    +'%sSave old package %s?';
  lisProbablyYouNeedToInstallSomePackagesForBeforeConti = 'Probably you need to '
    +'install some packages before continuing.'
    +'%sWarning:'
    +'%sThe project uses the following design time packages which might be needed '
    +'to open the form in the designer. If you continue, you might get errors '
    +'about missing components and the form loading will probably create very '
    +'unpleasant results.'
    +'%sIt is recommended to cancel and install these packages first.';
  lisPackageNeedsInstallation = 'Package needs installation';
  lisUnitInPackage = '%s unit %s in package %s';
  lisPkgMangSkipThisPackage = 'Skip this package';
  lisPkgMangInvalidFileExtension = 'Invalid file extension';
  lisPkgMangTheFileIsNotALazarusPackage = 'The file "%s" is not a Lazarus package.';
  lisPkgMangInvalidPackageFilename = 'Invalid package filename';
  lisPkgMangThePackageFileNameInIsNotAValidLazarusPackageName = 'The package '
    +'file name "%s" in%s"%s" is not a valid Lazarus package name.';
  lisPkgMangFileNotFound = 'File "%s" not found.';
  lisOpenFileAtCursor = 'Open file at cursor';
  lisPkgMangErrorReadingPackage = 'Error Reading Package';
  lisPkgUnableToReadPackageFileError = 'Unable to read package file "%s".%sError: %s';
  lisPkgMangFilenameDiffersFromPackagename = 'Filename differs from Packagename';
  lisPkgMangTheFilenameDoesNotCorrespondToThePackage = 'The filename "%s" does not '
    +'correspond to the package name "%s" in the file.%sChange package name to "%s"?';
  lisSuspiciousIncludePath = 'Suspicious include path';
  lisThePackageAddsThePathToTheIncludePathOfTheIDEThisI = 'The package %s '
    +'adds the path "%s" to the include path of the IDE.%sThis is probably a '
    +'misconfiguration of the package.';
  lisPkgMangErrorWritingPackage = 'Error Writing Package';
  lisPkgMangUnableToWritePackageToFileError = 'Unable to write package "%s"%sto '
    +'file "%s".%sError: %s';
  lisSeeProjectProjectInspector = '%sSee Project -> Project Inspector';
  lisPkgMangTheFollowingPackageFailedToLoad = 'The following package failed to load:';
  lisPkgMangTheFollowingPackagesFailedToLoad = 'The following packages failed to load:';
  lisMissingPackages = 'Missing Packages';
  lisNotInstalledPackages = 'Not installed packages';
  lisInstallPackagesMsg = 'The following packages are not installed, but available in the main repository: %s.' +
    sLineBreak + 'Do you wish to install missing packages?';
  lisOtherSourcesPathOfPackageContainsDirectoryWhichIsA = 'other sources path of '
    +'package "%s" contains directory "%s" which is already in the unit search path.';
  lisOutputDirectoryOfContainsPascalUnitSource = 'output directory of %s '
    +'contains Pascal unit source "%s"';
  lisInsertAssignment = 'Insert Assignment %s := ...';
  lisErrorLoadingFile = 'Error loading file';
  lisErrorLoadingFile2 = 'Error loading file "%s":';
  lisLoadingFailed = 'Loading %s failed.';
  lisPkgMangAddingNewDependencyForProjectPackage = '%sAdding new Dependency '
    +'for project %s: package %s';
  lisPkgMangAddingNewDependencyForPackagePackage = '%sAdding new Dependency '
    +'for package %s: package %s';
  lisPkgMangTheFollowingUnitsWillBeAddedToTheUsesSectionOf = '%sThe following '
    +'units will be added to the uses section of'
    +'%s%s:'
    +'%s%s';
  lisConfirmChanges = 'Confirm changes';
  lisPkgMangFileNotSaved = 'File not saved';
  lisPkgMangPleaseSaveTheFileBeforeAddingItToAPackage = 'Please save the file '
    +'before adding it to a package.';
  lisPkgMangFileIsInProject = 'File is in Project';
  lisPkgMangWarningTheFileBelongsToTheCurrentProject = 'Warning: The file "%s"'
    +'%sbelongs to the current project.';
  lisPkgMangFileIsAlreadyInPackage = 'File is already in package';
  lisPkgMangTheFileIsAlreadyInThePackage = 'The file "%s"%sis already in the package %s.';
  lisPkgMangPackageIsNoDesigntimePackage = 'Package is not a designtime package';
  lisPkgMangThePackageIsARuntimeOnlyPackageRuntimeOnlyPackages = 'The package %s '
    +'is a runtime only package.%sRuntime only packages cannot be installed in the IDE.';
  lisPkgMangAutomaticallyInstalledPackages = 'Automatically installed packages';
  lisPkgMangInstallingThePackageWillAutomaticallyInstallThePac2 = 'Installing '
    +'the package %s will automatically install the packages:';
  lisPkgMangInstallingThePackageWillAutomaticallyInstallThePac = 'Installing '
    +'the package %s will automatically install the package:';
  lisPkgMangRebuildLazarus = 'Rebuild Lazarus?';
  lisPkgMangThePackageWasMarkedForInstallationCurrentlyLazarus = 'The package "%s" '
    +'was marked for installation.'
    +'%sCurrently Lazarus only supports static linked packages. '
    +'The real installation needs rebuilding and restarting of Lazarus.'
    +'%sDo you want to rebuild Lazarus now?';
  lisPkgMangPackageIsRequired = 'Package is required';
  lisPkgMangThePackageIsRequiredByWhichIsMarkedForInstallation = 'The package %s '
    +'is required by %s which is marked for installation.'
    +'%sSee package graph.';
  lisPkgMangUninstallPackage = 'Uninstall package?';
  lisPkgMangUninstallPackage2 = 'Uninstall package %s?';
  lisPkgMangThePackageWasMarkedCurrentlyLazarus = 'The package "%s" was marked.'
    +'%sCurrently Lazarus only supports static linked packages. The real un-installation '
    +'needs rebuilding and restarting of Lazarus.'
    +'%sDo you want to rebuild Lazarus now?';
  lisPkgMangThisIsAVirtualPackageItHasNoSourceYetPleaseSaveThe = 'This is a '
    +'virtual package. It has no source yet. Please save the package first.';
  lisPkgMangPleaseCompileThePackageFirst = 'Please compile the package first.';
  lisPkgMangThePackageIsMarkedForInstallationButCanNotBeFound = 'The package "%s" '
    +'is marked for installation but cannot be found.'
    +'%sRemove dependency from the installation list of packages?';
  lisERRORInvalidBuildMode = 'Error: invalid build mode "%s"';
  lisAvailableProjectBuildModes = 'Available project build modes';
  lisThisProjectHasOnlyTheDefaultBuildMode = 'This project has only the default build mode.';
  lisPkgMangUnableToCreateTargetDirectoryForLazarus = 'Unable to create '
    +'target directory for Lazarus:'
    +'%s"%s".'
    +'%sThis directory is needed for the new changed Lazarus IDE with your custom packages.';

  // add active file to package dialog
  lisAF2PInvalidPackage = 'Invalid Package';
  lisAF2PInvalidPackageID = 'Invalid package ID: "%s"';
  lisAF2PPackageNotFound = 'Package "%s" not found.';
  lisAF2PPackageIsReadOnly = 'Package is read only';
  lisAF2PThePackageIsReadOnly = 'The package %s is read only.';
  lisAF2PFileType = 'File type';
  lisPEExpandDirectory = 'Expand directory';
  lisPECollapseDirectory = 'Collapse directory';
  lisPEUseAllUnitsInDirectory = 'Use all units in directory';
  lisPEUseNoUnitsInDirectory = 'Use no units in directory';
  lisAF2PDestinationPackage = 'Destination package';
  lisAF2PShowAll = 'Show all';
  lisAF2PAddFileToAPackage = 'Add File to Package';
  
  // add to package dialog
  lisA2PInvalidFilename = 'Invalid filename';
  lisA2PTheFilenameIsAmbiguousPleaseSpecifiyAFilename = 'The filename "%s" '
    +'is ambiguous because the package has no default directory yet.'
    +'%sPlease specify a filename with full path.';
  lisA2PFileNotUnit = 'File not unit';
  lisA2PisNotAValidUnitName = '"%s" is not a valid unit name.';
  lisA2PUnitnameAlreadyExists = 'Unitname already exists';
  lisA2PTheUnitnameAlreadyExistsInThisPackage = 'The unitname "%s" already '
    +'exists in this package.';
  lisA2PTheUnitnameAlreadyExistsInThePackage = 'The unitname "%s" already '
    +'exists in the package:%s%s';
  lisA2PFileAlreadyExistsInThePackage = 'File "%s" already exists in the package.';
  lisA2PAmbiguousUnitName = 'Ambiguous Unit Name';
  lisA2PTheUnitNameIsTheSameAsAnRegisteredComponent = 'The unit name "%s" is the '
    +'same as a registered component.'
    +'%sUsing this can cause strange error messages.';
  lisA2PExistingFile2 = 'Existing file: "%s"';
  lisA2PFileAlreadyExists = 'File already exists';
  lisA2PFileIsUsed = 'File is used';
  lisA2PTheFileIsPartOfTheCurrentProjectItIsABadIdea = 'The file "%s" is part of the '
    +'current project.'
    +'%sIt is a bad idea to share files between projects and packages.';
  lisA2PTheMaximumVersionIsLowerThanTheMinimimVersion = 'The Maximum Version '
    +'is lower than the Minimim Version.';
  lisA2PThePackageHasAlreadyADependencyForThe = 'The package already has a '
    +'dependency on the package "%s".';
  lisA2PNoPackageFoundForDependencyPleaseChooseAnExisting = 'No package found '
    +'for dependency "%s".%sPlease choose an existing package.';
  lisA2PInvalidUnitName = 'Invalid Unit Name';
  lisA2PTheUnitNameAndFilenameDiffer = 'The unit name "%s"%sand filename "%s" differ.';
  lisA2PInvalidFile = 'Invalid file';
  lisA2PInvalidAncestorType = 'Invalid Ancestor Type';
  lisA2PTheAncestorTypeIsNotAValidPascalIdentifier = 'The ancestor type "%s" '
    +'is not a valid Pascal identifier.';
  lisA2PPageNameTooLong = 'Page Name too long';
  lisA2PThePageNameIsTooLongMax100Chars = 'The page name "%s" is too long (max 100 chars).';
  lisA2PInvalidClassName = 'Invalid Class Name';
  lisA2PTheClassNameIsNotAValidPascalIdentifier = 'The class name "%s" is '
    +'not a valid Pascal identifier.';
  lisA2PInvalidCircularDependency = 'Invalid Circular Dependency';
  lisA2PTheClassNameAndAncestorTypeAreTheSame = 'The class name "%s" and '
    +'ancestor type "%s" are the same.';
  lisA2PAmbiguousAncestorType = 'Ambiguous Ancestor Type';
  lisA2PTheAncestorTypeHasTheSameNameAsTheUnit = 'The ancestor type "%s" '
    +'has the same name as%sthe unit "%s".';
  lisA2PAmbiguousClassName = 'Ambiguous Class Name';
  lisA2PTheClassNameHasTheSameNameAsTheUnit = 'The class name "%s" has the '
    +'same name as%sthe unit "%s".';
  lisA2PClassNameAlreadyExists = 'Class Name already exists';
  lisA2PTheClassNameExistsAlreadyInPackageFile = 'The class name "%s" exists already in'
    +'%sPackage %s'
    +'%sFile: "%s"';
  lisA2PNewFile = 'New File';
  lisA2PAddFiles = 'Add Files';
  lisA2PAncestorType = 'Ancestor type';
  lisA2PShowAll = 'Show all';
  lisA2PNewClassName = 'New class name:';
  lisA2PPalettePage = 'Palette page:';
  lisA2PDirectoryForUnitFile = 'Directory for unit file:';
  lisA2PUnitName = 'Unit name:';
  lisA2PShortenOrExpandFilename = 'Shorten or expand filename';
  lisA2PIcon24x24 = 'Icon 24x24:';
  lisA2PIcon36x36 = 'Icon 36x36:';
  lisA2PIcon48x48 = 'Icon 48x48:';

  lisMoveSelectedUp = 'Move selected item up (Ctrl+Up)';
  lisMoveSelectedDown = 'Move selected item down (Ctrl+Down)';

  // broken dependencies dialog
  lisBDDChangingThePackageNameOrVersionBreaksDependencies = 'Changing the package name '
    +'or version breaks dependencies. Should these dependencies be changed as well?'
    +'%sSelect Yes to change all listed dependencies.'
    +'%sSelect Ignore to break the dependencies and continue.';
  lisA2PDependency = 'Dependency';
  lisA2PPackageOrProject = 'Package/Project';
  lisA2PBrokenDependencies = 'Broken Dependencies';
  
  // open installed packages dialog
  lisOIPFilename = 'Filename:  %s';
  lisCurrentState = 'Current state: ';
  lisSelectedForInstallation = 'selected for installation';
  lisSelectedForUninstallation = 'selected for uninstallation';
  lisInstalled = 'installed';
  lisNotInstalled = 'not installed';
  lisOnlinePackage = 'available in the main repository';
  lisOIPThisPackageIsInstalledButTheLpkFileWasNotFound = '%sThis package is '
    +'installed but the lpk file was not found';
  lisOIPDescriptionDescription = '%sDescription:  %s';
  lisOIPDescription = 'Description:  ';
  lisOIPLicenseLicense = '%sLicense:  %s';
  lisOIPPleaseSelectAPackage = 'Please select a package';
  lisOIPPackageName = 'Package Name';
  lisOIPState = 'State';
  lisOIPmodified = 'modified';
  lisOIPmissing = 'missing';
  lisOIPinstalledStatic = 'installed static';
  lisOIPinstalledDynamic = 'installed dynamic';
  lisOIPautoInstallStatic = 'auto install static';
  lisOIPautoInstallDynamic = 'auto install dynamic';
  lisOIPreadonly = 'readonly';
  lisOIPOpenLoadedPackage = 'Open Loaded Package';
  
  // package editor
  lisPckEditRemoveFile = 'Remove file';
  lisPckEditReAddFile = 'Re-Add file';
  lisPESortFiles = 'Sort Files Permanently';
  lisPEFixFilesCase = 'Fix Files Case';
  lisPEShowMissingFiles = 'Show Missing Files';
  lisPckEditRemoveDependency = 'Remove dependency';
  lisPckEditMoveDependencyUp = 'Move dependency up';
  lisPckEditMoveDependencyDown = 'Move dependency down';
  lisPckEditStoreFileNameAsDefaultForThisDependency = 'Store file name as '
    +'default for this dependency';
  lisPckEditStoreFileNameAsPreferredForThisDependency = 'Store file name as '
    +'preferred for this dependency';
  lisPckEditClearDefaultPreferredFilenameOfDependency = 'Clear default/'
    +'preferred filename of dependency';
  lisRemoveNonExistingFiles = 'Remove nonexistent files';
  lisPckEditReAddDependency = 'Re-Add dependency';
  lisPckEditRecompileClean = 'Recompile Clean';
  lisPckEditRecompileAllRequired = 'Recompile All Required';
  lisPckEditCreateMakefile = 'Create Makefile';
  lisPckEditCreateFpmakeFile = 'Create fpmake.pp';
  lisPckEditAddToProject = 'Add to Project';
  lisPckEditInstall = 'Install';
  lisPckEditUninstall = 'Uninstall';
  lisNoNewFileFound = 'No new file found';
  lisAllPasPpPIncInUnitIncludePathAreAlreadyInAProjectP = 'All .pas, .pp, .p, '
    +'.inc in unit/include path are already in a project/package.';
  lisAddTheFollowingFiles = 'Add the following files:';
  lisAddNewDiskFiles = 'Add new disk files?';
  lisPckEditViewPackageSource = 'View Package Source';
  lisPckEditPackageHasChangedSavePackage = 'Package "%s" has changed.'
    +'%sSave package?';
  lisPckEditPage = '%s, Page: %s';
  lisPckEditRemoveFile2 = 'Remove file?';
  lisPckEditRemoveFileFromPackage = 'Remove file "%s"%sfrom package "%s"?';
  lisPckEditRemoveDependencyFromPackage = 'Remove dependency "%s"'
    +'%sfrom package "%s"?';
  lisRemoveDependenciesFromPackage = 'Remove %s dependencies from package "%s"?';
  lisRemove2 = 'Remove?';
  lisPckEditInvalidMinimumVersion = 'Invalid minimum version';
  lisPckEditTheMinimumVersionIsNotAValidPackageVersion = 'The minimum '
    +'version "%s" is not a valid package version.%s(good example 1.2.3.4)';
  lisPckEditInvalidMaximumVersion = 'Invalid maximum version';
  lisPckEditTheMaximumVersionIsNotAValidPackageVersion = 'The maximum '
    +'version "%s" is not a valid package version.%s(good example 1.2.3.4)';
  lisPckEditCompileEverything = 'Compile everything?';
  lisPckEditReCompileThisAndAllRequiredPackages = 'Re-Compile this and all '
   +'required packages?';
  lisPckEditOptionsForPackage = 'Options for Package %s';
  lisPckEditSavePackage = 'Save Package';
  lisPckEditCompilePackage = 'Compile package';
  lisPckEditAddFilesFromFileSystem = 'Add Files from File System';
  lisAddNewFilesFromFileSystem = 'Add New Files from File System';
  lisPckEditRemoveSelectedItem = 'Remove selected item';
  lisUse = 'Use';
  lisClickToSeeTheChoices = 'Click to see the choices';
  lisPckEditEditGeneralOptions = 'Edit general options';
  lisPkgEdMoreFunctionsForThePackage = 'More functions for the package';
  lisPckEditRequiredPackages = 'Required Packages';
  lisPckEditFileProperties = 'File Properties';
  lisPckEditCommonOptions = 'Common';
  lisPckEditRegisterUnit = 'Register unit';
  lisPckEditCallRegisterProcedureOfSelectedUnit = 'Call %sRegister%s '
    +'procedure of selected unit';
  lisPckEditRegisteredPlugins = 'Registered plugins';
  lisPkgMangAddUnitToUsesClause = 'Add unit to uses clause of package main file.'
    +' Disable this only for units that should not be compiled in all cases.';
  lisPckDisableI18NOfLfm = 'Disable I18N of lfm';
  lisPckWhenTheFormIsSavedTheIDECanStoreAllTTranslateString = 'When the form is'
    +' saved, the IDE can store all TTranslateString properties to the package '
    +'po file. For this you must enable I18N for this package, provide a po '
    +'output directory and leave this option unchecked.';
  lisPkgMangUseUnit = 'Use unit';
  lisPckEditMinimumVersion = 'Minimum Version:';
  lisPckEditMaximumVersion = 'Maximum Version:';
  lisPckEditApplyChanges = 'Apply changes';
  lisPckEditPackage = 'Package %s';
  lisPckEditRemovedFiles = 'Removed Files';
  lisPckEditRemovedRequiredPackages = 'Removed required packages';
  lisPckEditCheckAvailabilityOnline = 'Check availability online';
  lisPckEditAvailableOnline = '(available online)';
  lisPckEditDependencyProperties = 'Dependency Properties';
  lisFilesHasRegisterProcedureInPackageUsesSection = 'Files: %s, has Register '
    +'procedure: %s, in package uses section: %s';
  lisPckEditpackageNotSaved = 'package %s not saved';
  lisPckEditReadOnly = 'Read Only: %s';
  lisPckEditModified = 'Modified: %s';
  lisPkgEditNewUnitNotInUnitpath = 'New unit not in unitpath';
  lisPkgEditTheFileIsCurrentlyNotInTheUnitpathOfThePackage = 'The file "%s"'
    +'%sis currently not in the unit path of the package.'
    +'%sAdd "%s" to unit path?';
  lisPENewFileNotInIncludePath = 'New file not in include path';
  lisPETheFileIsCurrentlyNotInTheIncludePathOfThePackageA = 'The file "%s" is '
    +'currently not in the include path of the package.%sAdd "%s" to the '
    +'include path?';
  lisConflictDetected = 'Conflict detected';
  lisThereIsAlreadyAFileIn = 'There is already a file%s%s%sin %s';
  lisDuplicateUnit = 'Duplicate Unit';
  lisThereIsAlreadyAUnitInOldNewYouHaveToMakeSur = 'There is already a '
    +'unit "%s" in %s%sOld: %s%sNew: %s%sYou have to make sure that '
    +'the unit search path contains only one of them.%s%sContinue?';
  lisDuplicateFileName = 'Duplicate File Name';
  lisThereIsAlreadyAFileInOldNewContinue = 'There is already a file "%s'
    +'" in %s%sOld: %s%sNew: %s%s%sContinue?';
  lisUnitNotFoundAtNewPosition = 'unit %s not found at new position "%s"';
  lisUnitRequiresPackage = 'unit %s requires package %s';
  lisDifferentUnitFoundAtNewPosition = 'different unit %s found at new position "%s"';
  lisUnitNotFound = 'unit %s not found';
  lisTwoMovedFilesWillHaveTheSameFileNameIn = 'Two moved files will '
    +'have the same file name:%s%s%s%s%sin %s';
  lisPkgEditRevertPackage = 'Revert package?';
  lisMoveOrCopyFiles = 'Move or Copy files?';
  lisTargetIsReadOnly = 'Target is read only';
  lisTheTargetIsNotWritable = 'The target %s is not writable.';
  lisMoveOrCopyFileSFromToTheDirectoryOfPackage = 'Move or copy %s file'
    +'(s) from %s to the directory%s%s%sof %s?';
  lisMoveFileSFromToTheDirectoryOf = 'Move %s file(s) from %s to the directory%s%s%sof %s?';
  lisMove = 'Move';
  lisPkgEditDoYouReallyWantToForgetAllChangesToPackageAnd = 'Do you really '
    +'want to forget all changes to package %s and reload it from file?';
  lisNotAnInstallPackage = 'Not an install package';
  lisThePackageDoesNotHaveAnyRegisterProcedureWhichTypi = 'The package %s '
    +'does not have any "Register" procedure which typically means it does '
    +'not provide any IDE addon. Installing it will probably only increase '
    +'the size of the IDE and may even make it unstable.'
    +'%sHint: If you want to use a package in your project, use the "Add to project" menu item.';
  lisInstallItILikeTheFat = 'Install it, I like the fat';

  // package options dialog
  lisPckOptsUsage = 'Usage';
  lisPOChoosePoFileDirectory = 'Choose .po file directory';
  lisPckOptsIDEIntegration = 'IDE Integration';
  lisPckOptsProvides = 'Provides';
  lisPckOptsDescriptionAbstract = 'Description / Abstract';
  lisPckOptsAuthor = 'Author';
  lisPckOptsLicense = 'License';
  lisPckOptsMajor = 'Major';
  lisPckOptsMinor = 'Minor';
  lisPckOptsRelease = 'Release';
  lisBuildNumber = 'Build number';
  lisPckOptsPackageType = 'Package type';
  lisPckOptsDesigntime = 'Designtime';
  lisPckOptsRuntime = 'Runtime';
  lisPckOptsDesigntimeAndRuntime = 'Designtime and runtime';
  lisRuntimeOnlyCanNotBeInstalledInIDE = 'Runtime only, cannot be installed in IDE';
  lisPckOptsUpdateRebuild = 'Update / Rebuild';
  lisPckOptsAutomaticallyRebuildAsNeeded = 'Automatically rebuild as needed';
  lisPckOptsAutoRebuildWhenRebuildingAll = 'Auto rebuild when rebuilding all';
  lisPckOptsManualCompilationNeverAutomatically = 'Manual compilation (never automatically)';
  lisPckPackage = 'Package:';
  lisPckClearToUseThePackageName = 'Clear to use the package name';
  lisPckOptsAddPathsToDependentPackagesProjects = 'Add paths to dependent packages/projects';
  lisPckOptsInclude = 'Include';
  lisPckOptsObject = 'Object';
  lisPckOptsLibrary = 'Library';
  lisPckOptsAddOptionsToDependentPackagesAndProjects = 'Add options to dependent packages and projects';
  lisPckOptsLinker = 'Linker';
  lisPckOptsCustom = 'Custom';
  lisPckOptsInvalidPackageType = 'Invalid package type';
  lisPckOptsThePackageHasTheAutoInstallFlagThisMeans = 'The package "%s" has the auto install flag.'
    +'%sThis means it will be installed in the IDE.'
    +'%sInstallation packages must be designtime Packages.';

  // package explorer (package graph)
  lisMenuPackageGraph = 'Package Graph';
  lisPckExplUninstallPackage = 'Uninstall package %s';
  lisPckShowUnneededDependencies = 'Show unneeded dependencies';
  lisPckExplState = '%sState: ';
  lisPckExplInstalled = 'Installed';
  lisLpkIsMissing = 'lpk is missing';
  lisPckExplInstallOnNextStart = 'Install on next start';
  lisPckExplUninstallOnNextStart = 'Uninstall on next start (unless needed by an installed package)';
  lisPckExplBase = 'Base, cannot be uninstalled';

  // project inspector
  lisProjInspConfirmDeletingDependency = 'Confirm deleting dependency';
  lisProjInspRemoveItemsF = 'Remove %s items from project?';
  lisProjInspConfirmRemovingFile = 'Confirm removing file';
  lisProjInspDeleteDependencyFor = 'Delete dependency for %s?';
  lisProjInspRemoveFileFromProject = 'Remove file %s from project?';
  lisProjInspRemovedRequiredPackages = 'Removed required packages';
  lisProjInspProjectInspector = 'Project Inspector - %s';
  
  // IDE Coolbar
  lisCoolbarOptions = 'IDE CoolBar';
  lisCoolbarDeleteToolBar = 'Are you sure you want to delete the selected toolbar?';
  lisCoolbarSelectToolBar = 'Please select a toolbar first!';
  lisCoolbarAddSelected = 'Add selected item to toolbar';
  lisCoolbarRemoveSelected = 'Remove selected item from toolbar';
  lisCoolbarMoveSelectedUp = 'Move selected toolbar item up';
  lisCoolbarMoveSelectedDown = 'Move selected toolbar item down';
  lisCoolbarAddDivider = 'Add Divider';
  lisToolbarConfiguration = 'Toolbar Configuration';
  lisCoolbarAvailableCommands = 'Available commands';
  lisCoolbarToolbarCommands = 'Toolbar commands';
  // Command root nodes
  lisCoolbarIDEMainMenu = 'IDE Main Menu';
  lisCoolbarSourceTab = 'Source Tab';
  lisCoolbarSourceEditor = 'Source Editor';
  lisCoolbarMessages = 'Messages';
  lisCoolbarCodeExplorer = 'Code Explorer';
  lisCoolbarCodeTemplates = 'Code Templates';
  lisCoolbarDesigner = 'Designer';
  lisCoolbarPackageEditor = 'Package Editor';
  lisCoolbarPackageEditorFiles = 'Package Editor Files';

  lisCoolbarAddConfigDelete = 'Add/Config/Delete Toolbar(s)';
  lisCoolbarGeneralSettings = 'General Coolbar Settings';
  lisCoolbarConfigure = '&Configure';
  lisCoolbarVisible = 'Coolbar is &visible';
  lisCoolbarWidth = 'Coolbar width';
  lisCoolbarGrabStyle = 'Toolbars grab style';
  lisCoolbarGrabStyleItem0 = 'Simple';
  lisCoolbarGrabStyleItem1 = 'Double';
  lisCoolbarGrabStyleItem2 = 'HorLines';
  lisCoolbarGrabStyleItem3 = 'VerLines';
  lisCoolbarGrabStyleItem4 = 'Gripper';
  lisCoolbarGrabStyleItem5 = 'Button';
  lisCoolbarGrabWidth = 'Grab width';
  lisCoolbarBorderStyle = 'Toolbars border style';
  lisCoolbarBorderStyleItem0 = 'None';
  lisCoolbarBorderStyleItem1 = 'Single';
  lisCoolbarDeleteWarning = 'There must be at least one toolbar!';
  lisCoolbarRestoreDefaults = 'Restore defaults';

  // Editor Toolbar
  lisEditorToolbar = 'Editor ToolBar';
  lisConfigureEditorToolbar = 'Configure Toolbar';
  lisEditorToolbarVisible = 'Editor Toolbar is &visible';
  lisEditorToolbarSettings = 'Editor Toolbar Settings';
  lisPosition = 'Position';
  lisNoAutoSaveActiveDesktop = '''Auto save active desktop'' option is turned off, you will need to save current desktop manually.';

  // components palette settings and list form
  lisCmpPages = 'Pages';
  lisCmpLstComponents = 'Components';
  lisCmpPaletteVisible = 'Palette is &visible';
  lisCmpRestoreDefaults = '&Restore defaults';
  lisCmpLstList = 'List';
  lisCmpLstPalette = 'Palette';
  lisCmpLstInheritance = 'Inheritance';
  lisExportImport = 'Export / Import';
  lisSuccessfullyImported = 'Successfully imported from "%s".';
  lisSuccessfullyExported = 'Successfully exported to "%s".';

  // menu editor
  lisMenuEditorMenuEditor = 'Menu Editor';
  lisAddANewSeparatorAboveSelectedItem = 'Add a new separator above selected '
    +'item';
  lisAddANewSeparatorBelowSelectedItem = 'Add a new separator below selected '
    +'item';
  lisMenuEditorAcceleratorKeySNeedsChanging = 'Accelerator(&&) key "%s" needs changing';
  lisMenuEditorAddANewItemAboveSelectedItem = 'Add a new item above selected item';
  lisMenuEditorAddANewItemAfterSelectedItem = 'Add a new item after selected item';
  lisMenuEditorAddANewItemBeforeSelectedItem = 'Add a new item before selected item';
  lisMenuEditorAddANewItemBelowSelectedItem = 'Add a new item below selected item';
  lisMenuEditorAddASubmenuAtTheRightOfSelectedItem = 'Add a submenu at the right of selected item';
  lisMenuEditorAddASubmenuBelowSelectedItem = 'Add a submenu below selected item';
  lisMenuEditorAddFromTemplate = '&Add from template ...';
  lisMenuEditorAddIconFromS = 'Add icon from %s';
  lisMenuEditorAddImagelistIcon = 'Add imagelist &icon';
  lisMenuEditorAddNewItemAbove = '&Add new item above';
  lisMenuEditorAddNeWItemAfter = 'Add ne&w item after';
  lisMenuEditorAddNewItemBefore = '&Add new item before';
  lisMenuEditorAddNeWItemBelow = 'Add ne&w item below';
  lisMenuEditorAddOnClickHandler = 'Add &OnClick handler';
  lisMenuEditorAddSeparatorBefore = 'Add separator &before';
  lisMenuEditorAddSeparatorAfter = 'Add separator &after';
  lisMenuEditorAddSubmenuBelow = 'Add &submenu below';
  lisMenuEditorAddSubmenuRight = 'Add &submenu right';
  lisMenuEditorANewMenuTemplateHasBeenSaved = 'A new '
    +'menu template described as "%s" has been saved based on %s, with %d sub items';
  lisMenuEditorBasicEditMenuTemplate = '&Edit,Basic edit menu,' +
    '&Undo,Ctrl+Z,&Redo,,-,,Select &All,Ctrl+A,C&ut,Ctrl+X,C&opy,Ctrl+C,P&aste,Ctrl+V,' +
    'Paste &Special,,-,,F&ind,,R&eplace,,&Go to ...,,';
  lisMenuEditorBasicFileMenuTemplate = '&File,Basic file menu,' +
    '&New,,&Open ...,,&Save,,Save &As,,-,,&Print,,P&rint Setup ...,,-,,E&xit,,';
  lisMenuEditorBasicHelpMenuTemplate = '&Help,Basic help menu,' +
    'Help &Contents,F1,Help &Index,,&Online Help,,-,,' +
    '&Licence Information,,&Check for Updates,,-,,&About,,';
  lisMenuEditorBasicWindowMenuTemplate = '&Window,Basic window menu,' +
    '&New Window,,&Tile,,&Cascade,,&Arrange all,,-,,&Hide,,&Show,,';
  lisMenuEditorCaption = 'Caption';
  lisMenuEditorCaptionedItemsS = 'Captioned items: %s';
  lisMenuEditorCaptionShouldNotBeBlank = 'Caption should not be blank';
  lisMenuEditorChangeConflictingAcceleratorS = 'Change conflicting accelerator "%s"';
  lisMenuEditorChangeImagelistIcon = 'Change imagelist &icon';
  lisMenuEditorChangeShortcutCaptionForComponent = 'Change %s for %s';
  lisMenuEditorChangeShortcutConflictS = 'Change shortcut conflict "%s"';
  lisMenuEditorChangeTheShortCutForS = 'Change the shortCut for %s';
  lisMenuEditorChangeTheShortCutKey2ForS = 'Change the shortCutKey2 for %s';
  lisMenuEditorChooseTemplateToInsert = 'Choose template to insert';
  lisMenuEditorChooseTemplateToDelete = 'Choose template to delete';
  lisMenuEditorClickANonGreyedItemToEditItsShortcut = 'Click a non-greyed item '
    +'to edit its shortcut or click header to sort by that column';
  lisMenuEditorComponentIsUnexpectedKind = 'Component is unexpected kind';
  lisMenuEditorComponentIsUnnamed = 'Component is unnamed';
  lisMenuEditorConflictResolutionComplete = '<conflict resolution complete>';
  lisMenuEditorDeleteItem = '&Delete item';
  lisMenuEditorDeepestNestedMenuLevelS = 'Deepest nested menu level: %s';
  lisMenuEditorDeleteMenuTemplate = '&Delete menu template ...';
  lisMenuEditorDeleteSavedMenuTemplate = 'Delete saved menu template';
  lisMenuEditorDeleteSelectedMenuTemplate = 'Delete selected menu template';
  lisMenuEditorDeleteThisItemAndItsSubitems = 'Delete this item and its subitems?';
  lisMenuEditorDisplayPreviewAsPopupMenu = 'Display preview as &Popup menu';
  lisMenuEditorEditCaption = 'Edit &Caption';
  lisMenuEditorEditingCaptionOfS = 'Editing Caption of %s';
  lisMenuEditorEditingSForS = 'Editing %s for %s';
  lisMenuEditorEditingSdotS = 'To resolve conflict edit %s.%s';
  lisMenuEditorEditingSSNoMenuItemSelected = 'Editing %s.%s - no menuitem selected';
  lisMenuEditorEnterAMenuDescription = 'Enter a menu &Description:';
  lisMenuEditorEnterANewShortCutForS = 'Enter a new ShortCut for %s';
  lisMenuEditorEnterANewShortCutKey2ForS = 'Enter a new ShortCutKey2 for %s';
  lisMenuEditorExistingSavedTemplates = 'Existing saved templates';
  lisMenuEditorFurtherShortcutConflict = 'Further shortcut conflict';
  lisMenuEditorGrabKey = '&Grab key';
  lisMenuEditorInadequateDescription = 'Inadequate Description';
  lisMenuEditorInsertMenuTemplateIntoRootOfS = 'Insert menu template into root of %s';
  lisMenuEditorInsertSelectedMenuTemplate = 'Insert selected menu template';
  lisMenuEditorIsNotAssigned = 'is not assigned';
  lisMenuEditorItemsWithIconS = 'Items with icon: %s';
  lisMenuEditorListShortcutsAndAccelerators = 'List shortcuts and &accelerators for %s ...';
  lisMenuEditorListShortcutsForS = 'List shortcuts for %s ...';
  lisMenuEditorMenuitemShortcutConflictsInS = 'Menuitem shortcut conflicts in %s';
  lisMenuEditorMoVeItemDown = 'Mo&ve item down';
  lisMenuEditorMoveItemLeft = '&Move item left';
  lisMenuEditorMoVeItemRight = 'Mo&ve item right';
  lisMenuEditorMoveItemUp = '&Move item up';
  lisMenuEditorMoveSelectedItemDown = 'Move selected item down';
  lisMenuEditorMoveSelectedItemToTheLeft = 'Move selected item to the left';
  lisMenuEditorMoveSelectedItemToTheRight = 'Move selected item to the right';
  lisMenuEditorMoveSelectedItemUp = 'Move selected item up';
  lisMenuEditorMenuItemActions = 'Menu Item actions';
  lisMenuEditorNA = 'n/a';
  lisMenuEditorNoMenuSelected = '(no menu selected)';
  lisMenuEditorNone = '<none>';
  lisMenuEditorNoneNone = '<none>,<none>';
  lisMenuEditorNoShortcutConflicts = '<no shortcut conflicts>';
  lisMenuEditorNoUserSavedTemplates = 'No user-saved templates';
  lisMenuEditorPickAnIconFromS = 'Pick an icon from %s';
  lisMenuEditorPopupAssignmentsS = 'Popup assignments: %s';
  lisMenuEditorRemainingConflictsS = 'Remaining conflicts: %s';
  lisMenuEditorRemoveAllSeparators = '&Remove all separators';
  lisMenuEditorResolvedConflictsS = 'Resolved conflicts: %s';
  lisMenuEditorShortcutItemsS = 'Shortcut items: %s';
  lisMenuEditorResolveSelectedConflict = 'Resolve selected conflict';
  lisMenuEditorResolveShortcutConflicts = '&Resolve shortcut conflicts ...';
  lisMenuEditorGroupIndexValuesS = 'Values in use: %s';
  lisMenuEditorGroupIndexD = 'GroupIndex: %d';
  lisMenuEditorRadioItem = 'RadioItem';
  lisMenuEditorSavedTemplates = 'Saved templates';
  lisMenuEditorSaveMenuAsATemplate = '&Save menu as a template ...';
  lisMenuEditorSaveMenuAsTemplate = 'Save menu as template';
  lisMenuEditorSaveMenuAsTemplateForFutureUse = 'Save menu as template for future use';
  lisMenuEditorSaveMenuShownAsANewTemplate = 'Save menu shown as a new template';
  lisMenuEditorSConflictsWithS = '%s conflicts with %s';
  lisMenuEditorSeParators = 'Se&parators';
  lisMenuEditorConflictsFoundInitiallyD = 'Conflicts found initially: %d';
  lisMenuEditorShortcutNotYetChanged = 'Shortcut not yet changed';
  lisMenuEditorShortcutSourceProperty = 'Shortcut,Source Property';
  lisMenuEditorShortcuts = 'Shortcuts';
  lisMenuEditorShortcUts2 = 'Shortc&uts';
  lisMenuEditorShortcutsAndAcceleratorKeys = 'Shortcuts and Accelerator keys';
  lisMenuEditorShortcutsD = 'Shortcuts (%d)';
  lisMenuEditorShortcutsDAndAcceleratorKeysD = 'Shortcuts (%d) and Accelerator keys (%d)';
  lisMenuEditorShortcutsUsedInS = 'Shortcuts used in %s';
  lisMenuEditorShortcutsUsedInSD = 'Shortcuts used in %s (%d)';
  lisMenuEditorSInS = '"%s" in %s';
  lisMenuEditorSIsAlreadyInUse = '"%s" is '
    +'already in use in %s as a shortcut.' + sLineBreak + 'Try a different shortcut.';
  lisMenuEditorSIsNotASufficientDescriptionPleaseExpand = 'Please expand: "%s" is not a '
    +'sufficient Description';
  lisMenuEditorSShortcuts = '%s: Shortcuts';
  lisMenuEditorSShortcutsAndAcceleratorKeys = '%s: Shortcuts and accelerator keys';
  lisMenuEditorSSSOnClickS = '%s.%s.%s - OnClick: %s';
  lisMenuEditorStandardTemplates = 'Standard templates';
  lisMenuEditorAddMenuItem = 'Add menu item';
  lisMenuEditorAddSubmenu = 'Add submenu';
  lisMenuEditorTemplateDescription = 'Template description:';
  lisMenuEditorTemplates = '&Templates';
  lisMenuEditorTemplateSaved = 'Template saved';
  lisMenuEditorThereAreNoUserSavedMenuTemplates = 'There are no user-saved menu templates.' + sLineBreak + sLineBreak
    +  'Only standard default templates are available.';
  lisMenuEditorTSCListGetScanListCompNameInvalidIndexDForFScanLis = 'TSCList.'
    +'GetScanListCompName: invalid index %d for FScanList';
  lisMenuEditorYouHaveToChangeTheShortcutFromSStoAvoidAConflict = 'You have to'
    +' change the shortcut from %s' + sLineBreak + 'to avoid a conflict';
  lisMenuEditorYouMustEnterTextForTheCaption = 'You must enter text for the Caption';

  // Standard File menu
  lisKMNewUnit = 'New Unit';
  lisKMOpenRecent = 'Open Recent';

  // Standard Help menu
  lisMenuTemplateAbout = 'About';
  lisContributors = 'Contributors';
  lisAcknowledgements = 'Acknowledgements';
  lisAboutOfficial = 'Official:';
  lisAboutDocumentation = 'Documentation:';

  // codetools defines value dialog
  lisCTDefChooseDirectory = 'Choose Directory';
  lisCTDefCodeToolsDirectoryValues = 'CodeTools Directory Values';
  lisCTDefVariable = 'Variable: %s';
  lisCTDefnoVariableSelected = '<no variable selected>';
  lisCTDefVariableName = 'Variable Name';

  // clean directory dialog
  lisClDirCleanSubDirectories = 'Clean sub directories';
  lisClDirRemoveFilesMatchingFilter = 'Remove files matching filter';
  lisClDirSimpleSyntaxEGInsteadOf = 'Simple Syntax (e.g. * instead of .*)';
  lisClDirKeepAllTextFiles = 'Keep all text files';
  lisClDirKeepFilesMatchingFilter = 'Keep files matching filter';
  lisClDirCleanDirectory = 'Clean Directory';
  lisClDirClean = 'Clean';
  
  // LFM repair wizard
  lisTheLFMLazarusFormFileContainsInvalidPropertiesThis = 'The LFM (Lazarus '
    +'form) file contains invalid properties. This means for example it '
    +'contains some properties/classes which do not exist in the current LCL. '
    +'The normal fix is to remove these properties from the lfm and fix '
    +'the Pascal code manually.';
  lisFixLFMFile = 'Fix LFM file';
  lisMissingEvents = 'Missing Events';
  lisTheFollowingMethodsUsedByAreNotInTheSourceRemoveTh = 'The following methods '
    +'used by %s are not in the source'
    +'%s%s'
    +'%s%s'
    +'%sRemove the dangling references?';
  lisLFMFileContainsInvalidProperties = 'The LFM file contains unknown'
    +' properties/classes which do not exist in the LCL. They can be replaced or removed.';

  lisFileSIsConvertedToTextFormat = 'File %s was converted to text format.';
  lisFileSCountConvertedToTextFormat = '%d files were converted to text format.';
  lisFileSHasIncorrectSyntax = 'File %s has incorrect syntax.';
  lisAddedMissingObjectSToPascalSource = 'Added missing object "%s" to pascal source.';
  lisReplacedTypeSWithS = 'Replaced type "%s" with "%s".';
  lisRemovedPropertyS = 'Removed property "%s".';
  lisReplacedPropertySWithS = 'Replaced property "%s" with "%s".';
  lisChangedSCoordOfSFromDToDInsideS = 'Changed %s coord of %s from "%d" to "%d" inside %s.';
  lisAddedPropertySForS = 'Added property "%s" for %s.';

  // extract proc dialog
  lisNoCodeSelected = 'No code selected';
  lisPleaseSelectSomeCodeToExtractANewProcedureMethod = 'Please select some '
    +'code to extract a new procedure/method.';
  lisInvalidSelection = 'Invalid selection';
  lisThisStatementCanNotBeExtractedPleaseSelectSomeCode = 'This statement can '
    +'not be extracted.%sPlease select some code to extract a new procedure/method.';
  lisExtractProcedure = 'Extract Procedure';
  lisNameOfNewProcedure = 'Name of new procedure';
  lisExtract = 'Extract';
  lisInvalidProcName = 'Invalid proc name';
  lisPublicMethod = 'Public Method';
  lisPrivateMethod = 'Private Method';
  lisProtectedMethod = 'Protected Method';
  lisPublishedMethod = 'Published Method';
  lisProcedure = 'Procedure';
  lisProcedureWithInterface = 'Procedure with interface';
  lisSubProcedure = 'Sub Procedure';
  lisSubProcedureOnSameLevel = 'Sub Procedure on same level';

  // Help Options
  lisHlpOptsHelpOptions = 'Help Options';
  lisHlpOptsViewers = 'Viewers';
  lisHOFPCDocHTMLPath = 'FPC Doc HTML Path';
  lisHlpOptsProperties = 'Properties:';
  lisHlpOptsDatabases = 'Databases';
  lisOpenContextHelpInBrowser = 'Open context help in the browser';

  // enclose selection dialog
  lisChooseStructureToEncloseSelection = 'Choose structure to enclose selection';
    
  lisErrors = 'Errors';
  lisLFMFile = 'LFM file';
  lisRemoveAllInvalidProperties = 'Remove all invalid properties';

  lisA2PCreateNewComp = 'Create New Component';
  lisA2PFilename2 = 'Filename/URL';
  lisLastOpened = 'Last opened';
  lisFRIFindOrRenameIdentifier = 'Find or Rename Identifier';
  lisHelpSelectorDialog = 'Help selector';
  lisSelectAHelpItem = 'Select a help item:';
  lisErrorMovingComponent = 'Error moving component';
  lisErrorNamingComponent = 'Error naming component';
  lisErrorSettingTheNameOfAComponentTo = 'Error setting the name of a component %s to %s';
  lisErrorMovingComponent2 = 'Error moving component %s:%s';
  lisInstallUninstallPackages = 'Install/Uninstall Packages';
  lisMenuEditInstallPkgs = 'Install/Uninstall Packages ...';
  lisAvailableForInstallation = 'Available for installation';
  lisUninstallSelection = 'Uninstall selection';
  lisInstallSelection = 'Install selection';
  lisPackageInfo = 'Package info';
  lisSaveAndRebuildIDE = 'Rebuild IDE';
  lisSaveAndExitDialog = 'Only Save';
  lisAlignment = 'Alignment';
  lisHorizontal = 'Horizontal';
  lisNoChange = 'No change';
  lisTops = 'Tops';
  lisLeftSides = 'Left sides';
  lisCenters = 'Centers';
  lisBottoms = 'Bottoms';
  lisRightSides = 'Right sides';
  lisCenterInWindow = 'Center in window';
  lisSpaceEqually = 'Space equally';
  lisTopSpaceEqually = 'Top space equally';
  lisBottomSpaceEqually = 'Bottom space equally';
  lisLeftSpaceEqually = 'Left space equally';
  lisRightSpaceEqually = 'Right space equally';
  lisVertical = 'Vertical';
  lisScalingFactor = 'Scaling factor:';
  lisTabOrderUpHint = 'Move the selected control up in tab order';
  lisTabOrderDownHint = 'Move the selected control down in tab order';
  lisTabOrderSortHint = 'Calculate tab order for controls by their X- and Y- positions';
  lisTabOrderRecursively = 'recursively';
  lisTabOrderRecursionHint = 'Calculate tab order recursively for child controls';
  lisTabOrderConfirmSort = 'Sort tab orders of all child controls of "%s" by their positions?';

  lisRaspberryPiProgram = 'Raspberry Pi A/B/A+/B+ Application'; //Ultibo
  lisRaspberryPi2Program = 'Raspberry Pi 2B Application'; //Ultibo
  lisRaspberryPi3Program = 'Raspberry Pi 3B/3B+/3A+/Zero2W Application'; //Ultibo
  lisRaspberryPi4Program = 'Raspberry Pi 4B/400 Application'; //Ultibo
  lisRaspberryPiZeroProgram = 'Raspberry Pi Zero/ZeroW Application'; //Ultibo
  lisQEMUVersatilePBProgram = 'QEMU VersatilePB Application'; //Ultibo

  lisCustomProgram = 'Custom Program';
  lisSimpleProgram = 'Simple Program';
  lisSimpleUltiboProgram = 'Simple Ultibo Program'; //Ultibo
  lisProgram = 'Program';
  lisUltiboProgram = 'Ultibo Program'; //Ultibo
  lisConsoleApplication = 'Console application';

  lisApplicationProgramDescriptor = 'A graphical Free Pascal application using'
    +' the cross-platform LCL library for its GUI.';
  lisSimpleProgramProgramDescriptor = 'A most simple Free Pascal command line program.';
  lisSimpleUltiboProgramProgramDescriptor = 'A simple Ultibo program.'; //Ultibo
  lisProgramProgramDescriptor = 'A Free Pascal command line program with some useful settings added.';
  lisUltiboProgramProgramDescriptor = 'An Ultibo program with some useful settings added.'; //Ultibo
  lisConsoleApplicationProgramDescriptor = 'A Free Pascal command line program using'
    +' TCustomApplication to easily check command line options, handling exceptions, etc.';
  lisCustomProgramProgramDescriptor = 'A Custom Free Pascal program.';
  lisLibraryProgramDescriptor = 'A Free Pascal shared library (.dll under Windows,'
    +' .so under Linux, .dylib under macOS).';

  lisRaspberryPiProgramProgramDescriptor = 'An application with Raspberry Pi A/B/A+/B+ or QEMU specific settings.'; //Ultibo
  lisRaspberryPi2ProgramProgramDescriptor = 'An application with Raspberry Pi 2B or QEMU specific settings.'; //Ultibo
  lisRaspberryPi3ProgramProgramDescriptor = 'An application with Raspberry Pi 3B/3B+/3A+/Zero2W or QEMU specific settings.'; //Ultibo
  lisRaspberryPi4ProgramProgramDescriptor = 'An application with Raspberry Pi 4B/400 specific settings.'; //Ultibo
  lisRaspberryPiZeroProgramProgramDescriptor = 'An application with Raspberry Pi Zero/ZeroW or QEMU specific settings.'; //Ultibo
  lisQEMUVersatilePBProgramProgramDescriptor = 'An application with QEMU VersatilePB specific settings.'; //Ultibo

  lisNPCreateANewProject = 'Create a new project';
  lisOIFChooseABaseClassForTheFavoriteProperty = 'Choose a base class for the favorite property "%s".';
  lisOIFAddToFavoriteProperties = 'Add to favorite properties';
  lisOIFRemoveFromFavoriteProperties = 'Remove from favorite properties';
  lisReplacingSelectionFailed = 'Replacing selection failed.';
  lisUnableToFindInLFMStream = 'Unable to find %s in LFM Stream.';
  lisErrorParsingLfmComponentStream = 'Error parsing lfm component stream.';
  lisUnableToCreateTemporaryLfmBuffer = 'Unable to create temporary lfm buffer.';
  lisUnableToGetSourceForDesigner = 'Unable to get source for designer.';
  lisUnableToGatherEditorChanges = 'Unable to gather editor changes.';
  lisUnableToStreamSelectedComponents2 = 'Unable to stream selected components.';
  lisUnableToChangeClassOfTo = '%s%sUnable to change class of %s to %s';
  lisCanOnlyChangeTheClassOfTComponents = 'Can only change the class of TComponents.';
  lisOldClass = 'Old Class';
  lisNewClass = 'New Class';
  lisCEModeShowCategories = 'Show Categories';
  lisCEModeShowSourceNodes = 'Show Source Nodes';
  lisCESurrounding = 'Surrounding';
  lisCEOUpdate = 'Update';
  lisCEORefreshAutomatically = 'Refresh automatically';
  lisCEONeverOnlyManually = 'Never, only manually';
  lisCEOWhenSwitchingFile = 'When switching file in source editor';
  lisCEOOnIdle = 'On idle';
  lisCEFollowCursor = 'Follow cursor';
  lisWhenTheSourceEditorCursorMovesShowTheCurrentNodeIn = 'When the source '
    +'editor cursor moves, show the current node in the code explorer';
  lisCECategories = 'Categories';
  lisCEUses = 'Uses';
  lisCEOnlyUsedInCategoryMode = 'Only used in category mode';
  lisCETypes = 'Types';
  lisCEVariables = 'Variables';
  lisCEConstants = 'Constants';
  lisCEProcedures = 'Procedures';
  lisCEProperties = 'Properties';
  lisCodeObserver = 'Code Observer';
  lisCEOMode = 'Preferred exhibition mode';
  lisCEOModeCategory = 'Category';
  lisCEOModeSource = 'Source';

  lisFPDocEditor = 'FPDoc Editor';
  lisCodeHelpMainFormCaption = 'FPDoc Editor';
  lisCodeHelpNoTagCaption = '<NONE>';
  lisCodeHelpnoinheriteddescriptionfound = '(no inherited description found)';
  lisCodeHelpShortdescriptionOf = 'Short description of';
  lisCodeHelpInherited = 'Inherited';
  lisCodeHelpShortTag = 'Short';
  lisCodeHelpDescrTag = 'Description';
  lisCodeHelpErrorsTag = 'Errors';
  lisCodeHelpSeeAlsoTag = 'See also';
  lisCodeHelpAddPathButton = 'Add path';
  lisSearchPaths2 = 'Search paths';
  lisFPDocPackageName = 'FPDoc package name:';
  lisFPDocPackageNameDefaultIsProjectFileName = 'FPDoc package name. Default '
    +'is project file name.';
  lisCodeHelpDeletePathButton = 'Remove path';
  lisDefaultPlaceholder = '(default)';
  lisEditAdditionalHelpForMessages = 'Edit additional help for messages';
  lisGlobalSettings = 'Global settings';
  lisFPCMessageFile2 = 'FPC message file:';
  lisConfigFileOfAdditions = 'Config file of additions:';
  lisSelectedMessageInMessagesWindow = 'Selected message in messages window:';
  lisAdditions = 'Additions';
  lisCreateNewAddition = 'Create new addition';
  lisCodeHelpConfirmreplace = 'Confirm replace';
  lisCodeHelpGroupBox = 'FPDoc settings';
  lisCodeHelpHintBoldFormat = 'Insert bold formatting tag';
  lisCodeHelpHintItalicFormat = 'Insert italic formatting tag';
  lisCodeHelpHintUnderlineFormat = 'Insert underline formatting tag';
  lisCodeHelpHintInsertCodeTag = 'Insert code formatting tag';
  lisCodeHelpHintRemarkTag = 'Insert remark formatting tag';
  lisCodeHelpHintVarTag = 'Insert var formatting tag';
  lisCodeHelpCreateButton = 'Create help item';
  lisOpenXML = 'Open XML';
  lisCodeHelpInsertALink = 'Insert a link ...';
  lisCodeHelpInsertParagraphFormattingTag = 'Insert paragraph formatting tag';
  lisCodeHelpExampleTag = 'Example';
  lisCodeHelpBrowseExampleButton = 'Browse';
  lisLDMoveEntriesToInherited = 'Move entries to inherited';
  lisLDCopyFromInherited = 'Copy from inherited';
  lisLDAddLinkToInherited = 'Add link to inherited';
  lisEnableMacros = 'Enable Macros';
  lisCTSelectCodeMacro = 'Select Code Macro';
  lisPDProgress = 'Progress';
  lisPDAbort = 'Abort';
  lisMVSaveMessagesToFileTxt = 'Save messages to file (*.txt)';
  lisTabOrderOf = 'Tab Order of %s';

  lisAnchorEnabledHint = 'Enabled = Include %s in Anchors';
  lisAroundBorderSpaceHint = 'Borderspace around the control. The other four borderspaces are added to this value.';
  lisTopBorderSpaceSpinEditHint = 'Top borderspace. This value is added to base borderspace and used for the space above the control.';
  lisBottomBorderSpaceSpinEditHint = 'Bottom borderspace. This value is added to base borderspace and used for the space below the control.';
  lisLeftBorderSpaceSpinEditHint = 'Left borderspace. This value is added to base borderspace and used for the space left to the control.';
  lisRightBorderSpaceSpinEditHint = 'Right borderspace. This value is added to base borderspace and used for the space right to the control.';
  lisCenterControlVerticallyRelativeToSibling = 'Center control vertically relative to the given sibling. BorderSpacing is ignored.';
  lisCenterControlHorizontallyRelativeToSibling = 'Center control horizontally relative to the given sibling. BorderSpacing is ignored.';
  lisAnchorBottomToTopSide = 'Anchor bottom side to top side of sibling. The kept distance is defined by both BorderSpacing properties of this and sibling.';
  lisAnchorBottomToBottomSide = 'Anchor bottom side to bottom side of sibling. Use BorderSpacing to set a distance. BorderSpacing of sibling is ignored.';
  lisAnchorTopToTopSide = 'Anchor top side to top side of sibling. Use BorderSpacing to set a distance. BorderSpacing of sibling is ignored.';
  lisAnchorTopToBottomSide = 'Anchor top side to bottom side of sibling. The kept distance is defined by both BorderSpacing properties of this and sibling.';
  lisAnchorLeftToLeftSide = 'Anchor left side to left side of sibling. Use BorderSpacing to set a distance. BorderSpacing of sibling is ignored.';
  lisAnchorLeftToRightSide = 'Anchor left side to right side of sibling. The kept distance is defined by both BorderSpacing properties of this and sibling.';
  lisAnchorRightToLeftSide = 'Anchor right side to left side of sibling. The kept distance is defined by both BorderSpacing properties of this and sibling.';
  lisAnchorRightToRightSide = 'Anchor right side to right side of sibling. Use BorderSpacing to set a distance. BorderSpacing of sibling is ignored.';
  lisTopSiblingComboBoxHint = 'This is the sibling control to which the top side is anchored. Leave empty for anchoring to parent in Delphi style (BorderSpacing and ReferenceSide do not matter).';
  lisBottomSiblingComboBoxHint = 'This is the sibling control to which the bottom side is anchored. Leave empty for anchoring to parent in Delphi style (BorderSpacing and ReferenceSide do not matter).';
  lisRightSiblingComboBoxHint = 'This is the sibling control to which the right side is anchored. Leave empty for anchoring to parent in Delphi style (BorderSpacing and ReferenceSide do not matter).';
  lisLeftSiblingComboBoxHint = 'This is the sibling control to which the left side is anchored. Leave empty for anchoring to parent in Delphi style (BorderSpacing and ReferenceSide do not matter).';
  lisBorderSpace = 'Border space';
  lisSibling = 'Sibling';
  lisRightAnchoring = 'Right anchoring';
  lisTopAnchoring = 'Top anchoring';
  lisLeftGroupBoxCaption = 'Left anchoring';
  lisBottomGroupBoxCaption = 'Bottom anchoring';
  lisUnableToSetAnchorSideControl = 'Unable to set AnchorSide Control';
  lisThisWillCreateACircularDependency = 'This will create a circular dependency.';
  lisAnchorEditorNoControlSelected = 'Anchor Editor - no control selected';
  lisAnchorsOfSelectedControls = 'Anchors of selected controls';
  lisAnchorsOf = 'Anchors of %s';
  lisDebugOptionsFrmName = 'Name:';
  lisDebugOptionsFrmEditClass = 'Change type';
  lisDebugOptionsFrmEditClassWarn = 'Changing the type for the current debugger backend. Use "Add" or "Copy" to create a new backend with a new type.';
  lisDebugOptionsFrmAdditionalSearchPath = 'Additional search path';
  lisDebugOptionsFrmDebuggerGeneralOptions = 'Debugger general options';
  lisDebugOptionsFrmDebuggerDialogSettings = 'Debugger dialogs';
  lisDebugOptionsFrmShowMessageOnStop = 'Show message on stop';
  lisDebugOptionsFrmShowExitCodeOnStop = 'Show message on stop with Error (Exit-code <> 0)';
  lisDebugDialogConfirmDelWatches = 'Confirm to delete all Watches';
  lisDebugDialogConfirmDelBreaks = 'Confirm to delete all Breakpoints';
  lisDebugDialogConfirmDelBreaksFile = 'Confirm to delete Breakpoints in same file';
  lisDebugDialogConfirmDelHistory = 'Confirm to clear History';

  lisDebugOptionsFrmResetDebuggerOnEachRun = 'Reset Debugger after each run';
  lisDebugOptionsFrmAutoCloseAsm = 'Automatically close the assembler window, after source not found';
  lisDebugOptionsFrmAutoInstanceClass = 'Automatically set "use instance class type" for new watches';
  lisDebugOptionsFrmAllowFunctionCalls = 'BETA: Allow function calls in watches (if supported by backend)';
  lisDebugOptionsFrmDialogsToFront = 'Always bring debug-windows (watches, locals) to front when adding items';
  lisDebugOptionsFrmDebuggerSpecific = 'Debugger specific options (depends on '
    +'type of debugger)';
  lisDebugOptionsFrmEventLog = 'Event Log';
  lisDebugOptionsFrmClearLogOnRun = 'Clear log on run';
  lisDebugOptionsFrmLimitLinecountTo = 'Limit line count to';
  lisDebugOptionsFrmUseEventLogColors = 'Use event log colors';
  lisDebugOptionsFrmBreakpoint = 'Breakpoint';
  lisDebugOptionsFrmProcess = 'Process';
  lisDebugOptionsFrmThread = 'Thread';
  lisDebugOptionsFrmModule = 'Other Module'; //Ultibo
  lisDebugOptionsFrmUltiboModule = 'Ultibo Module'; //Ultibo
  lisDebugOptionsFrmOutput = 'Output';
  lisDebugOptionsFrmWindows = 'Windows';
  lisDebugOptionsFrmDebugger = 'Debugger';
  lisDebugOptionsFrmLanguageExceptions = 'Language Exceptions';
  lisDebugOptionsFrmIgnoreTheseExceptions = 'Ignore these exceptions';
  lisDebugOptionsFrmNotifyOnLazarusExceptions = 'Notify on Exceptions';
  lisDebugOptionsFrmOSExceptions = 'OS Exceptions';
  lisDebugOptionsFrmSignals = 'Signals';
  lisDebugOptionsFrmHandledBy = 'Handled by';
  lisDebugOptionsFrmHandledByProgram = 'Handled by Program';
  lisDebugOptionsFrmHandledByDebugger = 'Handled by Debugger';
  lisDebugOptionsFrmAddException = 'Add Exception';
  lisDebugOptionsFrmEnterExceptionName = 'Enter the name of the exception';
  lisDebugOptionsFrmDuplicateExceptionName = 'Duplicate Exception name';
  dlgDebugOptionsPathEditorDlgCaption = 'Path Editor';
  lisHFMHelpForFreePascalCompilerMessage = 'Help for Free Pascal Compiler message';
  lisThereAreAdditionalNotesForThisMessageOn = '%sThere are additional notes '
    +'for this message on%s';
  lisOpenURL = 'Open URL';
  lisFPCMessagesAppendix = 'FPC messages: Appendix';
  lisInheritedParameters = 'Inherited parameters';
  lisShowMultipleLines = 'Show multiple lines';
  lisShowRelativePaths = 'Show relative paths';
  lisCommandLineParameters = 'Command line parameters';
  lisKMChooseKeymappingScheme = 'Choose Keymapping scheme';
  lisKMNoteAllKeysWillBeSetToTheValuesOfTheChosenScheme = 'Note: All keys '
    +'will be set to the values of the chosen scheme.';
  lisKMKeymappingScheme = 'Keymapping Scheme';
  lisPVUEditVirtualUnit = 'Edit virtual unit';
  lisExportAllItemsToFile = 'Export All Items to File';
  lisImportFromFile = 'Import from File';
  lisIncludeRecursive = 'Include, recursive';
  lisExclude = 'Exclude';

  // cocoa Modern Form Style ToolBar Item Config
  cocoaMFSTBIJumpBack = 'Jump Back';
  cocoaMFSTBIJumpForward = 'Jump Forward';
  cocoaMFSTBISearch = 'Search Instantly';
  cocoaMFSTBICommand = 'Command';

  // version info tab
  VersionInfoTitle = 'Version Info';
  
  // Procedure List dialog
  lisPListProcedureList         = 'Procedure List';
  lisPListObjects               = '&Objects';
  lisPListJumpToSelection       = 'Jump To Selection';
  lisPListFilterAny             = 'Filter by matching any part of method';
  lisPListFilterStart           = 'Filter by matching with start of method';
  lisPListChangeFont            = 'Change Font';
  lisPListCopyMethodToClipboard = 'Copy method name to the clipboard';
  lisPListType                  = 'Type';
  lisPListAll                   = '<All>';
  lisPListNone                  = '<None>';

  //conditional defines dialog
  rsCreateNewDefine = 'Create new define';
  rsConditionalDefines = 'Conditional defines';
  lisFirstTest = '&First test';
  lisSecondTest = '&Second test';
  rsAddInverse = 'Add Inverse';
  lisAutomaticallyOnLineBreak = 'line break';
  lisAutomaticallyOnSpace = 'space';
  lisAutomaticallyOnTab = 'tab';
  lisAutomaticallyOnWordEnd = 'word end';
  lisAutomaticallyIgnoreForSelection = 'do not complete selection';
  lisAutomaticallyRemoveCharacter = 'do not add character';
  lisKeepSubIndentation = 'Absolute indentation';
  lisPckOptsThisPackageProvidesTheSameAsTheFollowingPackages = 'This package '
    +'provides the same as the following packages:';
  lisPLDPackageLinks = 'Package Links';
  lisSAMOverrideFirstSelected = 'Override first selected';
  lisSAMOverrideAllSelected = 'Override all selected';
  lisCCDNoClass = 'no class';
  lisCCDChangeClassOf = 'Change Class of %s';

  // View Search Results dialog
  rsFoundButNotListedHere = 'Found but not listed here: ';
  rsRefreshTheSearch = 'Refresh the search (F5)';
  rsNewSearchWithSameCriteria = 'New search with same criteria (Ctrl+N)';
  rsShowPathMode = 'Path display mode (Ctrl+P)';
  rsShowAbsPath = 'Absolute path';
  rsShowRelPath = 'Relative path';
  rsShowFileName = 'File name';
  rsFilterTheListWithString = 'Filter the lines in list with a string (Ctrl+F)';
  rsCloseCurrentPage = 'Close current page (Ctrl+F4)∥(Ctrl+W)';
  rsCloseLeft = 'Close page(s) on the left';
  rsCloseRight = 'Close page(s) on the right';
  rsCloseOthers = 'Close other page(s)';
  rsCloseAll = 'Close all pages';

  // Application Bundle
  lisMovePage = 'Move Page';
  lisFileSettings = 'File Settings';

  lisFunction = 'Function';
  lisCondition = 'Condition';
  lisGroup = 'Group';
  lisDeleteAll = '&Delete All';

  // Designer Size Components Dialog
  lisShrinkToSmal = 'Shrink to smallest';
  lisGrowToLarges = 'Grow to Largest';

  // ProjectWizard Dialog
  lisProjectWizard = 'Project Wizard';
  lisPWNewProject = '&New Project';
  lisPWOpenProject = '&Open Project';
  lisPWOpenRecentProject = 'Open &Recent Project';
  lisPWViewExampleProjects = 'View &Example Projects';
  lisPWConvertProject = 'Convert &Delphi Project';
  lisQuitLazarus = '&Quit Lazarus';
  lisIsAThisCircularDependencyIsNotAllowed = '%s is a %s.%sThis circular '
    +'dependency is not allowed.';
  lisTheComponentCanNotBeDeletedBecauseItIsNotOwnedBy = 'The component %s can '
    +'not be deleted because it is not owned by %s.';
  lisFilter3 = 'Filter: %s';
  lisFileExtensionOfPrograms = 'File extension of programs';
  lisEveryNThLineNumber = 'Show every n-th line number';
  lisShowOverviewGutter = 'Show overview gutter';
  lisTopInfoView = 'Show Class/Procedure hint';
  lisLeftGutter = 'Left';
  lisRightGutter = 'Right';
  lisGutterPartVisible = 'Visible';
  lisGutterPartWidth = 'Width';
  lisGutterPartMargin = 'Margin';
  lisLink = 'Link:';
  lisShort = 'Short:';
  lisInsertUrlTag = 'Insert url tag';
  lisInsertPrintshortTag2 = 'Insert printshort tag';
  lisTheUnitSearchPathOfContainsTheSourceDirectoryOfPac = 'The unit search '
    +'path of "%s" contains the source directory "%s" of package %s';
  lisFPCVersionEG222 = 'FPC Version (e.g. 2.2.2)';
  lisFPCFullVersionEG20701 = 'FPC version as one number (e.g. 20701)';
  lisLAZVer = 'Lazarus Version (e.g. 1.2.4)';
  lisMissingIdentifiers = 'Missing identifiers';
  lisChooseAFPDocLink = 'Choose a FPDoc link';
  lisLinkTarget = 'Link target';
  lisExamplesIdentifierTMyEnumEnumUnitnameIdentifierPac = 'Examples:'
    +'%sIdentifier'
    +'%sTMyEnum.Enum'
    +'%sUnitname.Identifier'
    +'%s#PackageName.UnitName.Identifier';
  lisTitleLeaveEmptyForDefault = 'Title (leave empty for default)';
  lisPackageUnit = 'package unit';
  lisPackage2 = 'package %s';
  lisIdentifier = 'identifier';
  lisProjectUnit = 'project unit';
  lisSyntaxMode = 'Syntax mode';
  lisUseAnsistrings = 'Use Ansistrings';
  lisDoNotShowThisDialogForThisProject = 'Do not show this dialog for this project';
  lisObjectPascalDefault = 'Object Pascal - default';
  lisVerifyMethodCalls = 'Verify method calls';
  lisBuildAllFilesOfProjectPackageIDE = 'Build all files of project/package/IDE.';
  lisCompilePackageTwiceAndCheckIfAnyUnitWasCompiledAga = 'Compile package twice and check if any '
    +'unit was compiled again.';
  lisApplyBuildFlagsBToDependenciesToo = 'Apply build flags (-B) to dependencies too.';
  lisDoNotCompileDependencies = 'Do not compile dependencies.';
  lisAddPackageSToListOfInstalledPackagesCombineWithBui = 'Add package(s) to the '
    +'list of installed packages (combine with --build-ide to rebuild IDE).';
  lisWriteWhatPackageFilesAreS = 'Write what package files are searched and '
    +'found.';
  lisBuildIDEWithPackages = 'Build IDE with packages. Optional compiler options '+
    'will be passed after the options from used build mode and can be specified here or '+
    'with the --opt option.';
  lisShowVersionAndExit = 'Show version and exit.';
  lisBeLessVerboseCanBeGivenMultipleTimes = 'Be less verbose. Can be given '
    +'multiple times.';
  lisPassingQuietTwoTimesWillP = 'Passing --quiet two times will pass -vw-n-h-'
    +'i-l-d-u-t-p-c-x- to the compiler.';
  lisBeMoreVerboseCanBeGivenMultipleTimes = 'Be more verbose. Can be given '
    +'multiple times.';
  lisOverrideTheProjectOperatingSystemEGWin32LinuxDefau = 'Override the '
    +'project operating system. For example: win32 linux. Default: %s.';
  lisOverrideTheProjectWidgetsetEGDefault = 'Override the project widgetset. ' +
    'For example: %s. Default: %s.';
  lisOverrideTheProjectCpuEGI386X86_64PowerpcPowerpc_64 = 'Override the '
    +'project CPU. For example: i386 x86_64 powerpc powerpc_64. Default: %s.';
  lisOverrideTheDefaultCompilerEGPpc386Ppcx64PpcppcEtcD = 'Override the '
    +'default compiler. For example: ppc386 ppcx64 ppcppc. Default value is stored in '
    +'environmentoptions.xml.';
  lisOverrideTheProjectBuildMode = 'Override the project or IDE build mode.';
  lisOverrideTheProjectSubtarg = 'Override the project subtarget.';
  lisProjectChangedOnDisk = 'Project changed on disk';
  lisTheProjectInformationFileHasChangedOnDisk = 'The project information file "%s"%shas changed on disk.';
  lisReopenProject = 'Reopen project';
  rsSelectAnInheritedEntry = 'Select an inherited entry';

  // New console application dialog (CustomApplicationOptionsForm.pas)
  lisApplicationClassName = '&Application class name';
  lisTitle = '&Title';
  lisCodeGenerationOptions = 'Code generation options';
  lisUsageMessageHOption = 'Usage message (-h option)';
  lisStopOnException = 'Stop on exception';
  lisConstructorCode = 'Constructor code';
  lisDestructorCode = 'Destructor code';
  lisCheckOptions = 'Check options';
  lisNewConsoleApplication = 'New console application';

  // Edit context help dialog (IDEContextHelpEdit.pas)
  lisHelpEntries = 'Help entries';
  lisCEIsARootControl = 'Is a root control';
  lisHasHelp = 'Has Help';
  lisCreateHelpNode = 'Create Help node';
  lisDlgOpen = 'Open ...';
  lisEditContextHelp = 'Edit context help';
  lisNoNodeSelected = 'no node selected';
  lisNoIDEWindowSelected = 'No IDE window selected';

  // Messages Editor dialog (MsgViewEditor.pas)
  lisAddNewSet = 'Add new set';
  lisActiveFilter = 'Active Filter';
  lisFilterSets = 'Filter Sets';
  lisMessagesEditor = 'Messages Editor';

  lisSetDefault = 'Set default';
  lisYouCanNotChangeTheBuildModeWhileCompiling = 'You cannot change the build'
    +' mode while compiling.';
  lisSelectedLeftNeighbour = '(selected left neighbour)';
  lisSelectedRightNeighbour = '(selected right neighbour)';
  lisSelectedTopNeighbour = '(selected top neighbour)';
  lisSelectedBottomNeighbour = '(selected bottom neighbour)';

  lisAction = 'Action:';
  lisValues = 'Values';
  lisIDEMacros = 'IDE Macros';
  lisConfirmDelete = 'Confirm delete';
  lisDeleteMacro = 'Delete macro "%s"?';
  lisValue2 = 'Value%s';
  lisDeleteValue = 'Delete value "%s"?';
  lisInvalidMacroTheMacroMustBeAPascalIdentifie = 'Invalid '
    +'macro "%s". The macro name must be a Pascal identifier.';
  lisThereIsAlreadyAMacroWithTheName = 'There is already a macro with the name "%s".';
  lisDuplicateFoundOfValue = 'Duplicate found of value "%s".';
  lisCreateFunction = 'Create function';
  lisResult2 = 'Result:';
  lisTheIdentifierIsAUnitPleaseUseTheFileSaveAsFunction = 'The identifier is '
    +'a unit. Please use the File - Save as function to rename a unit.';
  lisTheIdentifierIsAUnitProceedAnyway = 'The identifier is a %s.'
    +'%sNew file(s) will be created, old can be deleted.'
    +'%sProceed anyway?';
  lisRenamingAborted = 'Renaming aborted';
  lisRenamingConflict = 'Renaming conflict';
  lisFileAlreadyExists = 'File "%s" already exists.';
  lisIdentifierIsAlreadyUsed = 'Identifier "%s" is already used';
  lisIdentifierIsAlreadyUsed2 = 'Identifier "%s" is already used.';
  lisIdentifierCannotBeDotted = 'Identifier "%s" cannot be dotted';
  lisIdentifierCannotBeEmpty = 'Identifier cannot be empty';
  lisIdentifierIsInvalid = 'Identifier '
    + '"%s" is invalid';
  lisIdentifierIsReservedWord = 'Identifier '
    + '"%s" is a reserved word';
  lisIdentifierIsDeclaredCompilerProcedure = 'Identifier '
    + '"%s" is a declared compiler procedure.';
  lisIdentifierIsDeclaredCompilerFunction = 'Identifier '
    + '"%s" is a declared compiler function.';

  lisShowUnitsWithInitialization = 'Show units with initialization/finalization sections';
  lisShowUnitsWithInitializationHint = 'These units may initialize global data '
    +'used by the program/application. Remove with care.';
  lisRemoveSelectedUnits = 'Remove selected units';
  lisRemoveAllUnits = 'Remove all units';
  lisCEShowCodeObserver = 'Show observations about';
  lisCELongProcedures = 'Long procedures';
  lisCEManyParameters = 'Many parameters';
  lisCEUnnamedConstants = 'Unnamed constants';
  lisCEEmptyProcedures = 'Empty procedures';
  lisCEManyNestedProcedures = 'Many nested procedures';
  lisCEPublishedPropertyWithoutDefault = 'Published properties without default';
  lisCEUnsortedVisibility = 'Unsorted visibility';
  lisCEUnsortedMembers = 'Unsorted members';
  lisCEToDos = 'ToDos';
  lisCEEmptyClassSections = 'Empty class sections';
  lisCELongProcLineCount = 'Line count of procedure treated as "long"';
  lisCELongParamListCount = 'Parameters count treated as "many"';
  lisCENestedProcCount = 'Nested procedures count treated as "many"';
  lisCodeObsCharConst = 'Search for unnamed char constants';
  lisCodeObsIgnoreeConstants = 'Ignore next unnamed constants';
  lisShow = 'Show';
  lisCodeObIgnoreConstInFuncs = 'Ignore constants in next functions';
  lisCEEmptyBlocks = 'Empty blocks';
  lisCEComplexityGroup = 'Complexity';
  lisCEEmptyGroup = 'Empty constructs';
  lisCEStyleGroup = 'Style';
  lisCEOtherGroup = 'Other';
  lisCEWrongIndentation = 'Wrong indentation';
  lisTheProjectUsesTargetOSAndCPUTheSystemPpuForThisTar = 'The project uses '
    +'target OS=%s and CPU=%s.'
    +'%sThe system.ppu for this target was not found in the FPC binary directories.'
    +'%sMake sure fpc is installed correctly '
    +'for this target and the fpc.cfg contains the right directories.';
  lisFailedToLoadFoldStat = 'Failed to load fold state';
  lisUppercaseString = 'uppercase string';
  lisUppercaseStringGivenAsParameter = 'Uppercase string given as parameter.';
  lisLowercaseString = 'lowercase string';
  lisLowercaseStringGivenAsParameter = 'Lowercase string given as parameter.';
  lisPasteClipboard = 'paste clipboard';
  lisPasteFromClipboard = 'Paste from clipboard.';
  lisInsertProcedureHead = 'insert procedure head';
  lisInsertHeaderOfCurrentProcedure = 'Insert header of current procedure.'#13
    +#13
    +'Optional Parameters (comma separated):'#13
    +'WithStart,          // proc keyword e.g. ''function'', ''class procedure'''#13
    +'WithoutClassKeyword,// without ''class'' proc keyword'#13
    +'AddClassName,       // extract/add ClassName.'#13
    +'WithoutClassName,   // skip classname'#13
    +'WithoutName,        // skip function name'#13
    +'WithoutParamList,   // skip param list'#13
    +'WithVarModifiers,   // extract ''var'', ''out'', ''const'''#13
    +'WithParameterNames, // extract parameter names'#13
    +'WithoutParamTypes,  // skip colon, param types and default values'#13
    +'WithDefaultValues,  // extract default values'#13
    +'WithResultType,     // extract colon + result type'#13
    +'WithOfObject,       // extract ''of object'''#13
    +'WithCallingSpecs,   // extract cdecl; inline;'#13
    +'WithProcModifiers,  // extract forward; alias; external;'#13
    +'WithComments,       // extract comments and spaces'#13
    +'InUpperCase,        // turn to uppercase'#13
    +'CommentsToSpace,    // replace comments with a single space'#13
    +'                      //  (default is to skip unnecessary space,'#13
    +'                      //    e.g ''Do   ;'' normally becomes ''Do;'''#13
    +'                      //    with this option you get ''Do ;'')'#13
    +'WithoutBrackets,    // skip start- and end-bracket of parameter list'#13
    +'WithoutSemicolon,   // skip semicolon at end'#13;
  lisInsertProcedureName = 'insert procedure name';
  lisInsertNameOfCurrentProcedure = 'Insert name of current procedure.';
  lisInsertDate = 'insert date';
  lisInsertDateOptionalFormatString = 'Insert date. Optional: format string.';
  lisInsertTime = 'insert time';
  lisInsertTimeOptionalFormatString = 'Insert time. Optional: format string.';
  lisInsertDateAndTime = 'insert date and time';
  lisInsertDateAndTimeOptionalFormatString = 'Insert date and time. Optional: '
    +'format string.';
  lisInsertEndIfNeeded = 'insert end if needed';
  lisCheckIfTheNextTokenInSourceIsAnEndAndIfNotReturnsL = 'Check if the next '
    +'token in source is an "end" and if not return "LineEnding + end; + LineEnding".';
  lisInsertSemicolonIfNeeded = 'Insert semicolon if needed';
  lisCheckTheNextTokenInSourceAndAddASemicolonIfNeeded = 'Check the next '
    +'token in source and add a semicolon if needed.';
  lisListOfAllCaseValues = 'list of all case values';
  lisReturnsListOfAllValuesOfCaseVariableInFrontOfVaria = 'Return the list of '
    +'all values of case variable in front of variable.'#13
    +#13
    +'Optional Parameters (comma separated):'#13
    +'WithoutExtraIndent    // the case list will be generated without extra indentation';

  lisGetWordAtCurrentCursorPosition = 'get word at current cursor position';
  lisGetWordAtCurrentCursorPosition2 = 'Get word at current cursor position.';
  lisTemplateEditParamCell = 'Editable Cell';
  lisTemplateEditParamCellHelp =
     'Insert an editable Cell. Cells can be navigated using the tab key.%0:s' +
     'The "param" macro takes a list of comma separated arguments.%0:s' +
     'The first argument is the default value.%0:s' +
     'The 2nd argument (optional) can be used to link the cell to another cell (syncro edit).%0:s' +
     '%0:s' +
     '  while param("foo") do param(foo);%0:s' +
     'Inserts 2 independent cells, both with the default text "foo".%0:s' +
     'The quotes are optional.%0:s' +
     '%0:s' +
     '  if param("foo") > 0 and param("foo",sync=1) < 99 then%0:s' +
     'Inserts 2 linked cells, editing either one, will change the other one too.%0:s' +
     'The value "1" refers to the position of the other "param()", so if there are more params:%0:s' +
     '  if param("bar") and param(foo) > 0 and param(foo,sync=2) < 99 then%0:s' +
     'The 2nd and third are linked (the 3rd refers to "2").%0:s' +
     '%0:s' +
     '"Sync" can be shortened to "s":%0:s' +
     '  if param("foo") > 0 and param("foo",s=1) < 99 then%0:s' +
     '%0:s' +
     '  if param("bar") and param("foo") > 0 and param("foo",sync) < 99 then%0:s' +
     'The 2nd and third are linked.%0:s' +
     'Note: "Sync" has no position and no "=", so it syncs to the previous cell with the same default (in this case "foo").' ;

  lisPrecedingWord = 'Preceding word';
  lisReturnParameterIndexedWord = 'Return parameter-indexed word from the current line preceding cursor position.'+#13+#13+
                    'Words in a line are numbered 1,2,3,... from left to right, but the last word'+#13+
                    'which is always a macro command to be expanded has number 0, thus $PrevWord(0)'+#13+
                    'is always the current macro.'+#13+#13+
                    'Example line:'+#13+
                    'i 0 count-1 forb|'+#13+
                    'Here $PrevWord(0)=forb, $PrevWord(1)=i, $PrevWord(2)=0, $PrevWord(3)=count-1'+#13+#13+
                    'In the end of your template use $PrevWord(-1) which expands to an empty string, but performs an '+
                    'important operation of wiping off all of the $PrevWords found. In addition here is a regexp that is used '+
                    'to detect words for this macro: [\w\-+*\(\)\[\].^@]+';
  lisForm = 'Form';
  lisInheritedProjectComponent = 'Inherited project component';
  lisNewDlgInheritFromAProjectFormComponent = 'Inherit from a project form or component';
  lisFrame = 'Frame';
  lisDataModule = 'Data Module';
  lisNoLFMFile = 'No LFM file';
  lisThisFunctionNeedsAnOpenLfmFileInTheSourceEditor = 'This function needs '
    +'an open .lfm file in the source editor.';
  lisNoPascalFile = 'No Pascal file';
  lisUnableToFindPascalUnitPasPpForLfmFile = 'Unable to find Pascal unit (.pas, .pp) for .lfm file%s"%s"';
  lisLFMIsOk = 'LFM is ok';
  lisClassesAndPropertiesExistValuesWereNotChecked = 'Classes and properties '
    +'exist. Values were not checked.';
  lisIdCOpening = 'Opening';
  lisAutomaticallyInvokeOnType = 'Automatically invoke on typing';
  lisAutomaticallyInvokeOnTypeUseTimer = 'Use completion box delay';
  lisAutomaticallyInvokeOnTypeOnlyWordEnd = 'Only complete when at end of word';
  lisAutomaticallyInvokeOnTypeMinLength = 'Only complete if word is longer or equal';
  lisAutomaticallyInvokeAfterPoint = 'Automatically invoke after point';
  lisAutomaticallyUseSinglePossibleIdent = 'Automatically use single possible identifier';
  lisWhenThereIsOnlyOnePossibleCompletionItemUseItImmed = 'When there is only '
    +'one possible completion item use it immediately, without showing the '
    +'completion box';
  lisAddParameterBrackets = 'Add parameter brackets';
  lisReplaceWholeIdentifier = 'Replace whole identifier';
  lisEnableReplaceWholeIdentifierDisableReplacePrefix = 'Enable = pressing'
    +' Return replaces whole identifier and Shift+Return replaces prefix,'
    +' Disable = pressing Return replaces prefix and Shift+Return replaces'
    +' whole identifier';
  lisJumpToError = 'Jump to error';
  lisJumpToErrorAtIdentifierCompletion =
    'When an error in the sources is found at identifier completion, jump to it.';
  lisShowHelp = 'Show help';
  lisBestViewedByInstallingAHTMLControlLikeTurbopowerip = 'Best viewed by '
    +'installing a HTML control like turbopoweriprodsgn';
  lisShowRecentlyUsedIdentifiersAtTop = 'Show recently used identifiers at top';
  lisForExampleShowAtTopTheLocalVariablesThenTheMembers = '"Scoped" sorting will show'
    +' local variables on top, then the members of current class, then of the'
    +' ancestors, then the current unit, then of used units';
  lisSortHistoryLimit = 'History items limit';
  lisSortOrderTitle = 'Order by';
  lisSortOrderDefinition = 'Definition (Scoped)';
  lisSortOrderScopedAlphabetic = 'Alphabetic (Scoped)';
  lisSortOrderAlphabetic = 'Alphabetic';
  lisShowEmptyUnitsPackages = 'Show empty units/packages';
  lisUsePackageInProject = 'Use package %s in project';
  lisUsePackageInProject2 = 'Use package in project';
  lisUsePackageInPackage = 'Use package %s in package %s';
  lisUsePackageInPackage2 = 'Use package in package';
  lisRescan = 'Rescan';
  lisUseUnitInUnit = 'Use unit %s in unit %s';
  lisUseIdentifier = 'Use identifier';
  lisFindMissingUnit = 'Find missing unit';
  lisSearchUnit = 'Search Unit "%s"';
  lisEmpty = 'Empty';
  lisThereIsAlreadyAComponentWithThisName = 'There is already a component '
    +'with this name';
  lisTheOwnerHasThisName = 'The owner has this name';
  lisTheOwnerClassHasThisName = 'The owner class has this name';
  lisTheUnitHasThisName = 'The unit has this name';
  lisChooseNameAndText = 'Choose name and text';
  lisTheComponentNameMustBeUniqueInAllComponentsOnTheFo = 'The component name '
    +'must be unique in all components on the form/datamodule.The name is '
    +'compared case insensitive like a normal Pascal identifier.';
  lisChooseANameForTheComponent = 'Choose a name for the component';
  lisProperty = '%s property';
  lisAskForFileNameOnNewFile = 'Ask for file name on new file';
  lisSuggestDefaultNameOfNewFileInLowercase = 'Suggest default name of new '
    +'file in lowercase';
  lisAlwaysConvertSuggestedDefaultFileNameToLowercase = 'Always convert '
    +'suggested default file name to lowercase';
  lisExampleFile = 'Example file:';
  lisChooseAPascalFileForIndentationExamples = 'Choose a Pascal file for '
    +'indentation examples';
  lisContextSensitive = 'Context sensitive';
  lisImitateIndentationOfCurrentUnitProjectOrPackage = 'Imitate indentation '
    +'of current unit, project or package';
  lisAddPackageRequirement = 'Add package requirement?';
  lisTheUnitBelongsToPackage = 'The unit belongs to package %s.';
  lisAddUnitNotRecommended = 'Add unit (not recommended)';
  lisAddPackageToProject2 = 'Add package to project';
  lisOnBreakLineIEReturnOrEnterKey = 'On break line (i.e. return or enter key)';
  lisSetupDefaultIndentation = '(Set up default indentation)';
  lisIndentationForPascalSources = 'Indentation for Pascal sources';
  lisOnPasteFromClipboard = 'On paste from clipboard';
  lisImpossible = 'Impossible';
  lisAProjectUnitCanNotBeUsedByOtherPackagesProjects = 'A project unit can '
    +'not be used by other packages/projects';
  lisPackagesUnitsIdentifiersLinesBytes = 'packages=%s/%s units=%s/%s '
    +'identifiers=%s/%s lines=%s bytes=%s';
  lisScanning2 = '%s. Scanning ...';
  lisShowGlyphsFor = 'Show Glyphs for';
  lisBuildingLazarusFailed = 'Building Lazarus failed';
  lisThisSetOfOptionsToBuildLazarusIsNotSupportedByThis = 'This set of '
    +'options to build Lazarus is not supported by this installation.%sThe '
    +'directory "%s" is not writable.%sSee the Lazarus website for other '
    +'ways to install Lazarus.';
  lisIDEBuildOptions = 'IDE build options';
  lisPathOfTheInstantfpcCache = 'path of the instantfpc cache';
  lisPrimaryConfigPath = 'Primary config path';
  lisSecondaryConfigPath = 'Secondary config path';
  lisSelected = 'Selected';
  lisSelectedAndChildControls = 'Selected and child controls';

  //Jump History dialog
  lisJHJumpHistory = 'Jump History';
  lisNoHints = 'no hints';
  lisAllParametersOfThisFunctionAreAlreadySetAtThisCall = 'All parameters of '
    +'this function are already set at this call. Nothing to add.';
  lisIDECompileAndRestart = 'The IDE will be recompiled and restarted during installation/uninstallation of packages.';

  synfUnfoldAllInSelection                          = 'Unfold all in selection';
  synfUnfoldCommentsInSelection                     = 'Unfold comments in selection';
  synfFoldCommentsInSelection                       = 'Fold comments in selection';
  synfHideCommentsInSelection                       = 'Hide comments in selection';
  synfUnfoldAllIfdefInSelection                     = 'Unfold all Ifdef in selection';
  synfUnfoldActiveIfdefInSelection                  = 'Unfold active Ifdef in selection';
  synfUnfoldInactiveIfdefInSelection                = 'Unfold inactive Ifdef in selection';
  synfFoldInactiveIfdefInSelection                  = 'Fold inactive Ifdef in selection';
  synfFoldInactiveIfdefInSelectionExcludeMixedState = 'Fold inactive Ifdef in selection ('
    +'exclude mixed state)';

  synfUnfoldAll                           = 'Unfold all';
  synfUnfoldComments                      = 'Unfold comments';
  synfFoldComments                        = 'Fold comments';
  synfHideComments                        = 'Hide comments';
  synfUnfoldAllIfdef                      = 'Unfold all Ifdef';
  synfUnfoldActiveIfdef                   = 'Unfold active Ifdef';
  synfUnfoldInactiveIfdef                 = 'Unfold inactive Ifdef';
  synfFoldInactiveIfdef                   = 'Fold inactive Ifdef';
  synfFoldInactiveIfdefExcludeMixedState  = 'Fold inactive Ifdef (exclude mixed state)';

  lisCanNotCompileProject = 'Cannot compile project';
  lisTheProjectHasNoMainSourceFile = 'The project has no main source file.';
  lisInvalidMacroTheNameIsAKeyword = 'Invalid macro name "%s". The name is a keyword.';
  lisTheMacroDoesNotBeginWith = 'The macro "%s" does not begin with "%s".';
  lisRenameTo = 'Rename to %s';
  lisAddValueToMacro = 'Add value to macro %s';
  lisDeleteValue2 = 'Delete value %s';
  lisNoMacroSelected = 'No macro selected';
  lisMacro = 'Macro %s';
  lisAddNewMacro = 'Add new macro';
  lisHintADefaultValueCanBeDefinedInTheConditionals = 'Hint: A default value '
    +'can be defined in the conditionals.';
  lisConditionals = 'Conditionals';
  lisDlgAllOptions = 'All options ...';
  lisDlgDefines = 'Defines ...';
  lisWithIncludes2 = ', with includes ';
  lisParsed = ', parsed ';
  lisCreatingFileIndexOfFPCSources = 'Creating file index of FPC sources %s ...';
  lisTheFileIndexIsNeededForFunctionsLikeFindDeclaratio = 'The file index is '
    +'needed for functions like find declaration. While scanning you can edit '
    +'sources and compile, but functions like find declaration will show unit-'
    +'not-found errors. This can take a minute.';
  lisActive = 'Active';
  lisBuildModes = 'Build mode';
  lisEditBuildModes = 'Edit build modes';
  lisSelectBuildMode = 'Select build mode';
  lisFindOption = 'Find option';
  lisAddFcUTF8 = 'Add -FcUTF8';
  lisAddFcUTF8Hint = 'May be needed if source files have non-ansistring literals.';
  lisInSession = 'In session';
  lisTheDefaultModeMustBeStoredInProject =
    'The default mode must be stored in project, not in session.';
  lisThereMustBeAtLeastOneBuildMode = 'There must be at least one build mode.';
  lisDuplicateEntry = 'Duplicate entry';
  lisThereIsAlreadyABuildModeWithThisName = 'There is already a build mode with this name.';
  lisAddNewBuildModeCopyingSettingsFrom = 'Add new build mode, copying settings from "%s"';
  lisDeleteMode = 'Delete mode "%s"';
  lisMoveOnePositionUp = 'Move "%s" one position up';
  lisMoveOnePositionDown = 'Move "%s" one position down';
  lisShowDifferencesBetweenModes = 'Show differences between modes ...';
  lisBuildMode = 'Build Mode: %s';
  lisCreateDebugAndReleaseModes = 'Create Debug and Release modes';
  lisChangeBuildMode = 'Change build mode';
  lisWarningThisIsTheMainUnitTheNewMainUnitWillBePas = '%sWarning: This is '
    +'the main unit. The new main unit will be %s.pas.';
  lisRemoveFilesFromPackage = 'Remove %s files from package "%s"?';
  lisDirectivesForNewUnit = 'Directives for new unit';
  lisInformationAboutUsedFPC = 'Information about used FPC';

  //Build mode differences dialog
  lisBuildModeDiffDifferencesBetweenBuildModes = 'Differences between build modes';
  lisMMWas = '(was "%s")';
  lisMMIDEMacro2 = 'IDE Macro %s:=%s';
  lisMMFromTo = 'From %s to %s';
  lisMMDoesNotHaveIDEMacro = 'Does not have IDE Macro %s:=%s';
  lisMMDoesNotOverrideOutDirFU = 'Does not override OutDir (-FU)';
  lisMMOverrideOutDirFU = 'Override OutDir (-FU): %s';
  lisBuildModeDiffMode = 'Mode:';
  lisBuildModeDiffDifferencesToOtherBuildModes = 'Differences from other build modes';

  //IDE info dialog
  lisIDEInfoInformationAboutTheIDE = 'Information about the IDE';

  lisKeepRelativeIndentationOfMultiLineTemplate = 'Keep absolute indentation, regardless '
    +'of the current cursor indentation in the text.';
  lisTheCurrentFPCHasNoConfigFileItWillProbablyMissSome = 'The current FPC '
    +'has no config file. It will probably miss some units. Check your '
    +'installation of fpc.';
  lisInFPCUnitSearchPathProbablyInstalledByTheFPCPackag = 'In FPC unit search '
    +'path. Probably installed by the FPC package. Check if the compiler and '
    +'the ppu file are from the same installation.';
  lisInASourceDirectoryOfTheProjectCheckForDuplicates = 'In a source '
    +'directory of the project. Check for duplicates.';
  lisInASourceDirectoryOfThePackage = 'In a source directory of the package "%s".';
  lisCheckTheTargetOSCPULCLWidgetTypeMaybeYouHaveToReco = '%s Check the '
    +'target (OS, CPU, LCL widget type). Maybe you have to recompile the '
    +'package for this target or set another target for the project.';
  lisMaybeYouHaveToRecompileThePackage = '%s Maybe you have to recompile the package.';
  lisDuplicatePpuFilesDeleteOneOrMakeSureAllSearchPaths = 'Duplicate ppu '
    +'files. Delete one or make sure all search paths have correct order ('
    +'Hint: FPC uses last path first).';
  lisDuplicateSourcesDeleteOneOrMakeSureAllSearchPathsH = 'Duplicate sources. '
    +'Delete one or make sure all search paths have correct order (Hint: FPC '
    +'uses last path first).';
  lisPEMissingFilesOfPackage = 'Missing files of package %s';
  lisPENoFilesMissingAllFilesExist = 'No files missing. All files exist.';
  lisCurrentLCLWidgetSet = 'Current LCL widgetset: "%s"';
  lisSelectAnotherLCLWidgetSet = 'Select another LCL widgetset (macro LCLWidgetType)';

  // Uses Unit dialog
  dlgUseUnitCaption = 'Add unit to Uses section';
  dlgShowAllUnits = 'Show all units';
  dlgInsertSection = 'Insert into Uses section of';
  dlgInsertInterface = 'Interface';
  dlgInsertImplementation = 'Implementation';
  dlgNoAvailableUnits = 'No available units to add.';
  lisOpenUnit = 'Open Unit';
  lisOpenPackage3 = 'Open Package';
  lisInsteadOfCompilePackageCreateASimpleMakefile = 'Instead of compiling a '
    +'package create a simple Makefile.';
  lisOnlyRegisterTheLazarusPackageFilesLpkDoNotBuild = 'Only register the '
    +'Lazarus package files (.lpk). Do not build.';

  // Custom form editor
  lisCFEAnExceptionOccurredDuringDeletionOf = 'An exception occurred during '
    +'deletion of%s"%s:%s"%s%s';
  lisCFETCustomFormEditorDeleteComponentWhereIsTheTCustomN = 'TCustomFormEditor'
    +'.DeleteComponent  Where is the TCustomNonFormDesignerForm? %s';
  lisCFEUnableToClearTheFormEditingSelection = 'Unable to clear the form '
    +'editing selection%s%s';
  lisCFEDoNotKnowHowToDeleteThisFormEditingSelection = 'Do not know how to '
    +'delete this form editing selection';
  lisCFEDoNotKnowHowToCopyThisFormEditingSelection = 'Do not know how to copy '
    +'this form editing selection';
  lisCFEDoNotKnowHowToCutThisFormEditingSelection = 'Do not know how to cut '
    +'this form editing selection';
  lisCFETCustomFormEditorCreateNonFormFormUnknownType = 'TCustomFormEditor.'
    +'CreateNonFormForm Unknown type %s';
  lisCFETCustomFormEditorCreateNonFormFormAlreadyExists = 'TCustomFormEditor.'
    +'CreateNonFormForm already exists';
  lisCFETCustomFormEditorRegisterDesignerMediatorAlreadyRe = 'TCustomFormEditor'
    +'.RegisterDesignerMediator already registered: %s';
  lisCFEErrorCreatingComponent = 'Error creating component';
  lisCFEErrorCreatingComponent2 = 'Error creating component: %s%s%s';
  lisCFEInvalidComponentOwner = 'Invalid component owner';
  lisCFETheComponentOfTypeFailedToSetItsOwnerTo = 'The component of type %s '
    +'failed to set its owner to %s:%s';
  lisCFEErrorDestroyingMediatorOfUnit = 'Error destroying mediator %s of '
    +'unit %s:%s%s';
  lisCFEErrorDestroyingMediator = 'Error destroying mediator';
  lisCFEErrorDestroyingComponentOfTypeOfUnit = 'Error destroying component of '
    +'type %s of unit %s:%s%s';
  lisCFEErrorDestroyingComponent = 'Error destroying component';
  lisCFEInFile = 'In file %s';
  lisCFETheComponentEditorOfClassHasCreatedTheError = 'The component editor '
    +'of class "%s"has created the error:%s"%s"';
  lisShowSetupDialogForMostImportantSettings = 'Show setup dialog for most '
    +'important settings.';
  lisShowPositionOfSourceEditor = 'Show position of source editor';

  //Initial setup dialog
  lisTheSourcesOfTheFreePascalPackagesAreRequiredForBro = 'The sources of the '
    +'Free Pascal packages are required for browsing and code completion. For '
    +'example it has the file "%s".';
  lisSelectPathTo = 'Select path to %s';
  lisSelectFPCSourceDirectory = 'Select FPC source directory';
  lisSelectLazarusSourceDirectory = 'Select Lazarus source directory';
  lisWithoutAProperLazarusDirectoryYouWillGetALotOfWarn = 'Without a proper '
    +'Lazarus directory you will get a lot of warnings.';
  lisWithoutAProperCompilerTheCodeBrowsingAndCompilingW = 'Without a proper '
    +'compiler the code browsing and compiling will be disappointing.';
  lisWithoutAProperDebuggerDebuggingWillBeDisappointing = 'Without a proper '
    +'debugger, debugging will be disappointing.';
  lisWithoutTheProperFPCSourcesCodeBrowsingAndCompletio = 'Without the proper '
    +'FPC sources code browsing and completion will be very limited.';
  lisWithoutAProperMakeExecutableTheCompilingOfTheIDEIs = 'Without a proper "'
    +'make" executable the compiling of the IDE is not possible.';
  lisTheLazarusDirectoryContainsTheSourcesOfTheIDEAndTh = 'The Lazarus directory '
    +'contains the sources of the IDE and the package files of LCL and many '
    +'standard packages. For example it contains the file "ide%slazarus.lpi". '
    +'The translation files are located there too.';
  lisTheFreePascalCompilerExecutableTypicallyHasTheName = 'The Free Pascal '
    +'compiler executable typically has the name "%s". You can also use the '
    +'target specific compiler like "%s". Please give the full file path.';
  lisTheMakeExecutableTypicallyHasTheName = 'The "make" executable typically '
    +'has the name "%s". It is needed for building the IDE. Please give the full file path.';
  lisFoundVersionExpected = 'Found version %s, expected %s';
  lisInvalidVersionIn = 'invalid version in %s';
  lisWrongVersionIn = 'wrong version in %s: %s';
  lisFPCSources = 'FPC sources';
  lisConfigureLazarusIDE = 'Configure Lazarus IDE (Ultibo Edition)'; //'Configure Lazarus IDE'; //Ultibo
  lisFileIsNotAnExecutable = 'File is not an executable';
  lisUnusualPas2jsCompilerFileNameUsuallyItStartsWithPa = 'Unusual pas2js '
    +'compiler file name. Usually it starts with pas2js.';
  lisThereIsNoFpcExeInTheDirectoryOfUsuallyTheMakeExecu = 'There is no fpc.exe'
    +' in the directory of %s. Usually the make executable is installed '
    +'together with the FPC compiler.';
  lisUnusualCompilerFileNameUsuallyItStartsWithFpcPpcOr = 'Unusual compiler '
    +'file name. Usually it starts with fpc, ppc or ppcross.';
  lisCompilerCfgIsMissing = '%s is missing.';
  lisSystemPpuNotFoundCheckYourFpcCfg = 'system.ppu not found. Check your fpc.cfg.';
  lisWelcomeToLazarusIDE = 'Welcome to Lazarus IDE (Ultibo Edition) %s'; //'Welcome to Lazarus IDE %s'; //Ultibo
  lisStartIDE = 'Start IDE';
  lisUnableToLoadFile2 = 'unable to load file %s: %s';
  lisDirectoryNotFound2 = 'directory %s not found';
  lisFileNotFound3 = 'file %s not found';
  lisFileNotFound4 = 'file not found';
  lisPpuNotFoundCheckYourFpcCfg = '%s.ppu not found. Check your fpc.cfg.';
  lisISDDirectoryNotFound = 'directory not found';

  lisCleanUpAndBuildProject = 'Clean up and build project';
  // Many Build Modes
  lisCompileFollowingModes = 'Compile the following modes';
  lisSelectedModesWereCompiled  = 'Selected %d modes were successfully compiled.';
  // Clean Build Project Dialog
  lisProjectOutputDirectory = 'Project output directory';
  lisProjectSourceDirectories = 'Project source directories';
  lisPackageOutputDirectories = 'Package output directories';
  lisPackageSourceDirectories = 'Package source directories';
  lisTheseFilesWillBeDeleted = 'These files will be deleted';
  lisCleanUpAndBuild = 'Clean up and build';
  lisCBPFiles = '%s (%s files)';
  lisCBPReallyDeleteSourceFiles = 'Really delete %s source files%s%s';

  lisChangesWereNotSaved = 'Changes were not saved';
  lisDoYouStillWantToOpenAnotherProject = 'Do you still want to open another project?';
  lisDiscardChangesAndOpenProject = 'Discard changes and open project';
  lisDoYouStillWantToCreateTheNewProject = 'Do you still want to create the '
    +'new project?';
  lisDiscardChangesCreateNewProject = 'Discard changes, create new project';
  lisDoYouStillWantToQuit = 'Do you still want to quit?';
  lisDiscardChangesAndQuit = 'Discard changes and quit';
  lisFileIsDirectory = 'File is directory';
  lisPathIsNoDirectory = 'is not a directory';
  lisUnableToCreateNewFileBecauseThereIsAlreadyADirecto = 'Unable to create '
    +'new file because there is already a directory with this name.';

  //Toolbar options

  // File Filters - Environment options
  lisFileFiltersTitle ='These are file filters that will appear in all File Open dialogs';
  lisFileFilters = 'File Filters';
  lisConfirm = 'Confirm';
  lisResetAllFileFiltersToDefaults = 'Reset all file filters to defaults?';
  lisFileFiltersMask = 'File mask';
  lisFileFiltersAddRow = 'Add Row';
  lisFileFiltersDeleteRow = 'Delete Row';
  lisFileFiltersInsertRow = 'Insert Row';
  lisFileFiltersSetDefaults = 'Set defaults';
  lisMenuPkgNewPackageComponent = 'New package component';
  lisSaveChangedFiles = 'Save changed files?';

  lisExcludesForStars =
    'Excludes for * and ** in unit and include search paths';

  lisUIClearIncludedByReference = 'Clear include cache';
  lisChangeParent = 'Change Parent';
  lisLazarusIDE = 'Lazarus IDE (Ultibo Edition)'; //'Lazarus IDE'; //Ultibo
  lisProject = 'Project %s';
  lisWhatNeedsBuilding = 'What needs building';
  lisTarget = 'Target:';
  lisDirectives = 'Directives';
  lisRecordedMacros = 'Recorded';
  lisNewMacroName = 'Macro %d';
  lisEditorMacros = 'Editor Macros';
  lisMakeCurrent = 'Current';
  lisPlay = 'Play';
  lisRecord = 'Record';
  lisRepeat = 'Repeat';
  lisCreateAndEdit = 'Create and edit';
  lisDeleteSelectedMacro = 'Delete selected macro?';
  lisReallyDelete = 'Really delete?';
  lisSaveMacroAs = 'Save macro as';
  lisLoadMacroFrom = 'Load macro from';
  lisProjectMacro = 'Project';
  lisNewRecordedMacrosNotToBeSaved = 'New recorded macros. Not to be saved';
  lisSavedWithProjectSession = 'Saved with project session';
  lisSavedWithIDESettings = 'Saved with IDE settings';
  lisMoveTo = 'Move to: ';
  lisFailedToSaveFile = 'Failed to save file.';
  lisEditKey = 'Edit Key';
  lisDuplicateName = 'Duplicate Name';
  lisAMacroWithThisNameAlreadyExists = 'A macro with this name already exists.';
  lisNewMacroname2 = 'New Macroname';
  lisEnterNewNameForMacroS = 'Enter new name for Macro "%s"';
  lisFreePascalCompilerMessages = 'Free Pascal Compiler messages';
  lisRunAndDesignTimePackagesHaveNoLimitations = '"Run and Design time" '
    +'packages have no limitations.';
  lisDesignTimePackagesAddComponentsAndMenuItemsToTheID = '"Design time" '
    +'packages add components and menu items to the IDE. They can be used by '
    +'projects but are not compiled into the project. The compiler will not '
    +'find units of this package when compiling the project.';
  lisRunTimePackagesCanBeUsedByProjectsTheyCanNotBeInst = '"Run time" packages '
    +'can be used by projects. They cannot be installed in the IDE unless '
    +'some design time package requires them.';
  lisRunTimeOnlyPackagesAreOnlyForProjectsTheyCanNotBeI = '"Run time only" '
    +'packages are only for projects. They cannot be installed in the IDE, '
    +'not even indirectly.';
  lisPckEditCleanUpDependencies = 'Clean up dependencies ...';
  lisPkgCleanUpPackageDependencies = 'Clean up package dependencies';
  lisPkgTheFollowingDependenciesAreNotNeededBecauseOfTheAu = 'The following '
    +'dependencies are not needed because of the automatic transitivity '
    +'between package dependencies.';
  lisPkgDeleteDependencies = 'Delete dependencies';
  lisPkgClearSelection = 'Clear Selection';
  lisAlpha = 'Alpha';
  lisMMAppendArbitraryFpcOptionsEGO1GhtlDFlag = 'Append arbitrary fpc options,'
    +' e.g. -O1 -ghtl -dFlag';
  lisMMOverrideOutputDirectoryFUOfTarget = 'Override output directory -FU of target';
  lisMMSetAnIDEMacroEGLCLWidgetTypeWin32 = 'Set an IDE macro, e.g.: LCLWidgetType:=win32';
  lisMMMissingMacroName = 'missing macro name';
  lisMMExpectedMacroNameButFound = 'expected macro name but found "%s"';
  lisMMInvalidCharacterInMacroValue = 'invalid character in macro value "%s"';
  lisMMExpectedAfterMacroNameButFound = 'expected ":=" after macro name but found "%s"';
  lisMMApplyToAllPackages = 'Apply to all packages.';
  lisMMTargets = 'Targets: ';
  lisMMApplyToAllPackagesAndProjects = 'Apply to all packages and projects.';
  lisMMApplyToProject = 'Apply to project.';
  lisMMApplyToAllPackagesMatching = 'Apply to all packages matching name "%s"';
  lisMMExcludeAllPackagesMatching = 'Exclude all packages matching name "%s"';
  lisMMStoredInIDEEnvironmentoptionsXml = 'Stored in IDE (environmentoptions.xml)';
  lisMMStoredInProjectLpi = 'Stored in project (.lpi)';
  lisMMStoredInSessionOfProjectLps = 'Stored in session of project (.lps)';
  lisMMMoveSelectedItemUp = 'Move selected item up';
  lisMMMoveSelectedItemDown = 'Move selected item down';
  lisMMNewTarget = 'New Target';
  lisMMUndoLastChangeToThisGrid = 'Undo last change to this grid';
  lisMMRedoLastUndoToThisGrid = 'Redo last undo to this grid';
  lisMMCreateANewGroupOfOptions = 'Create a new group of options';
  lisMMDeleteTheSelectedTargetOrOption = 'Delete the selected target or option';
  lisMMSetS = 'Set "%s"';
  lisMMValueS = 'Value "%s"';
  lisMMAdditionsAndOverrides = 'Additions and Overrides';
  lisMMInvalidCharacterAt = 'invalid character "%s" at %s';
  lisMMCustomOption = 'Custom Option';
  lisMMIDEMacro = 'IDE Macro';
  lisMMOverrideOutputDirectory = 'Override output directory (-FU)';
  lisMMWidgetSetAvailableForLCLProject = 'WidgetSet change is available only for LCL projects';
  lisPriority = 'Priority';
  lisUDScanningUnits = 'Scanning: %s units ...';
  lisUDFile = 'File: %s';
  lisUDInterfaceUses = 'Interface Uses: %s';
  lisUDInterfaceUses2 = 'interface uses: %s';
  lisUDImplementationUses = 'Implementation Uses: %s';
  lisUDUsedByInterfaces = 'Used by Interfaces: %s';
  lisUDUsedByImplementations = 'Used by Implementations: %s';
  lisUDScanning = 'Scanning ...';
  lisUDImplementationUses2 = 'implementation uses: %s';
  lisUDUsedByInterfaces2 = 'used by interfaces: %s';
  lisUDUsedByImplementations2 = 'used by implementations: %s';
  lisUDProjectsAndPackages = 'Projects and packages';
  lisUDUnits = 'Units';
  lisUDAdditionalDirectories = 'Additional directories:';
  lisUDByDefaultOnlyTheProjectUnitsAndTheSourceEditorUnit = 'By default only '
    +'the project units and the source editor units are searched. Add here a '
    +'list of directories separated by semicolon to search as well.';
  lisUDAllPackageUnits = 'All package units';
  lisUDAllSourceEditorUnits = 'All source editor units';
  lisUDAllUnits = 'All units';
  lisUDShowNodesForDirectories = 'Show nodes for directories';
  lisUDShowNodesForProjectAndPackages = 'Show nodes for project and packages';
  lisUDSearchNextOccurrenceOfThisPhrase = 'Find next occurrence of this phrase';
  lisUDSearchPreviousOccurrenceOfThisPhrase = 'Find previous occurrence of this phrase';
  lisUDSelectedUnits = 'Selected units';
  lisUDSearchNextUnitOfThisPhrase = 'Find next unit with this phrase';
  lisUDSearchPreviousUnitOfThisPhrase = 'Find previous unit with this phrase';
  lisUDExpandAllNodes = 'Expand all nodes';
  lisShowUnusedUnits = 'Show unused units ...';
  lisUDCollapseAllNodes = 'Collapse all nodes';
  lisUDFilter = '(Filter)';
  lisUDSearch = '(Search)';
  lisUDUnits2 = 'Units: %s';
  lisCTOUpdateAllMethodSignatures = 'Update all method signatures';
  lisCTOUpdateMultipleProcedureSignatures = 'Update multiple procedure signatures';
  lisGroupLocalVariables = 'Group automatically defined local variables';
  lisOverrideStringTypesWithFirstParamType = 'Override function result string types with the first parameter expression type';
  lisUpdateOtherProcedureSignaturesWhenOnlyLetterCaseHa = 'Update other '
    +'procedure signatures when only letter case has changed';
  lisTemplateFile = 'Template file';
  lisIncorrectConfigurationDirectoryFound = 'Incorrect configuration directory found';
  lisIDEConficurationFoundMayBelongToOtherLazarus = 'Welcome to Lazarus.%0:s'
    + 'The IDE configuration found was previously used by another '
    + 'installation of Lazarus.%0:s'
    + 'If you have two or more separate installations of Lazarus, they should not '
    + 'share the same configuration. This may lead to conflicts and your '
    + 'Lazarus installations may become unusable.%0:s%0:s'
    + 'If you have only one installation and copied or moved the Lazarus '
    + 'executable, then you may upgrade this configuration.%0:s'
    + '%1:s%0:s%0:s'       // %1:s = ConfDirWarning
    + 'Choose:%0:s%0:s'
    + '* Update info: Use this configuration and update it for being used with this '
    + 'Lazarus in future. The old installation will no longer use this.%0:s'
    + '* Ignore: Use this configuration but keep the warning. This may lead to '
    + 'conflicts with the other installation.%0:s'
    + '* Abort: Exit now. You can then fix the problem by starting this Lazarus '
    + 'with the correct configuration.%0:s%0:s'
    + 'Additional information:%0:s'
    + 'This configuration is at: %2:s%0:s'                     // %2:s = PrimaryConfPath
    + 'It belongs to the Lazarus installation at: %3:s%0:s'     // %3:s = old install path
    + 'The current IDE was started from: %4:s%0:s'             // %4:s = current
    ;
  lisUpdateInfo = 'Update info';

  lisExitCode = 'Exit code %s';
  lisCanTFindAValidPpu = 'Can''t find a valid %s.ppu';
  lisCannotFind = 'Cannot find %s';
  lisUsedBy = ' used by %s';
  lisCleanUpPackage = 'Clean up package "%s".';
  lisPpuInWrongDirectory = 'ppu in wrong directory=%s.';
  lisPackageNeedsAnOutputDirectory = 'Package needs an output directory.';
  lisMakeSureAllPpuFilesOfAPackageAreInItsOutputDirecto = 'Make sure all ppu '
    +'files of a package are in its output directory.';
  lisCheckSearchPathPackageTryACleanRebuildCheckImpleme = '. Check search path of'
    +' package %s, try a clean rebuild, check implementation uses sections.';
  lisCheckIfPackageIsInTheDependencies = '. Check if package %s is in the '
    +'dependencies';
  lisCheckIfPackageCreatesPpuCheckNothingDeletesThisFil = '. Check if package '
    +'%s creates %s.ppu, check nothing deletes this file and check that no two'
    +' packages have access to the unit source.';
  lisEnableFlagUseUnitOfUnitInPackage = '. Enable flag "Use Unit" of unit %s in package %s';
  lisOfTheProjectInspector = ' of the Project Inspector';
  lisOfPackage = ' of package %s';
  lisCompileWithVdForMoreDetailsCheckForDuplicates = 'Compile with -vd '
    +'for more details. Check for duplicates.';
  lisIncompatiblePpu = ', incompatible ppu=%s';
  lisPackage3 = ', package %s';
  lisMultiplePack = ', multiple packages: ';
  lisQuickFixError = 'QuickFix error';
  lisPositionOutsideOfSource = '%s (position outside of source)';
  lisHideMessageByInsertingWarnOffToUnit = 'Hide message by inserting {$warn %'
    +'s off} to unit "%s"';
  lisAddModifierOverload = 'Add modifier "overload"';
  lisAddModifierReintroduce = 'Add modifier "reintroduce"';
  lisAddModifierOverride = 'Add modifier "override"';
  lisHideWithProjectOptionVm = 'Hide with project option (-vm%s)';
  lisHideWithPackageOptionVm = 'Hide with package option (-vm%s)';
  lisRemoveLocalVariable3 = 'Remove local variable "%s"';
  lisShowAbstractMethodsOf = 'Show abstract methods of "%s"';
  lisCopyMoveFileToDirectory = 'Copy/Move File to Directory';
  lisSelectTargetDirectory = 'Select target directory';
  lisNewPage = 'New page';
  lisPageName = 'Page name';
  lis_All_ = '<All>';
  lisPageNameAlreadyExists = 'Page name "%s" already exists. Not added.';
  lisJumpToProcedure = 'Jump to procedure %s';
  lisFindDeclarationOf = 'Find Declaration of %s';
  lisInitializeLocalVariable = 'Initialize Local Variable';
  synfMatchActionPosOfMouseDown = 'Match action pos of mouse down';
  synfMatchActionLineOfMouseDown = 'Match action line of mouse down';
  synfSearchAllActionOfMouseDown = 'Search all action of mouse down';
  synfMatchActionButtonOfMouseDown = 'Match action button of mouse down';
  synfMatchActionModifiersOfMouseDown = 'Match action modifiers of mouse down';
  synfContinueWithNextMouseUpAction = 'Continue with next mouse up action';
  lisDuplicateUnitIn = 'Duplicate unit "%s" in "%s"';

  lismpMultiPaste = 'MultiPaste';
  lismpPasteOptions = 'Paste &options';
  lismpTextBeforeEachLine = 'Text &before each line';
  lismpTextAfterEachLine = 'Text &after each line';
  lismpEscapeQuotes = 'Escape &quotes';
  lismpPascalStyle = 'Pascal style: '' => ''''';
  lismpCStyle = 'C style: " => \"';
  lismpTrimClipboardContents = '&Trim clipboard contents';
  lismpPreview = '&Preview';
  lisUnableToRun2 = 'Unable to run "%s"';

  lisSelectFrame = 'Select Frame';
  lisDsgToggleShowingNonVisualComponents = 'Toggle showing nonvisual components';
  lisDsgShowNonVisualComponents = 'Show nonvisual components';

  // * Debug Event Log *
  // Snippet for break location: .... at $04123456: unit1.pas line 15 ...
  dbgEventBreakAtAddressSourceLine = 'at $%s: %s line %d';
  dbgEventBreakAtAddressOriginSourceOriginLine = 'at $%s: from origin %s line %d'; // Source/Line from Breakpoint (origin)
  dbgEventBreakAtAddress = 'at $%s'; // unknows source/line
  // Breakpoint hit events (first param is location): "Source Breakpoint at $0x00000..."
  dbgEventBreakSourceBreakPoint = 'Source Breakpoint %s';
  dbgEventBreakAddressBreakPoint = 'Address Breakpoint %s';
  dbgEventBreakUnknownBreakPoint = 'Unknown Breakpoint %s';
  dbgEventBreakWatchPoint = 'Watchpoint %s';
  dbgEventWatchTriggered = 'Watchpoint for "%s" was triggered %s. Old value "%s", New Value "%s"';
  dbgEventUnknownWatchPointTriggered = 'Unknown Watchpoint triggered %s. Old value "%s", New Value "%s"';
  dbgEventWatchScopeEnded = 'Watchpoint for "%s" out of scope %s';
  dbgEventUnknownWatchPointScopeEnded = 'Unknown Watchpoint out of scope %s';
  rsAddNewTerm = 'Add new term';
  LvlGraphSplitNone = 'None';
  LvlGraphSplitSeparate = 'Separate';
  LvlGraphSplitMergeAtSourc = 'Merge at source';
  LvlGraphSplitMergeAtTarge = 'Merge at target';
  LvlGraphSplitMergeAtHighe = 'Merge at highest';
  LvlGraphShapeStraight = 'Straight';
  LvlGraphShapeCurved = 'Curved';
  LvlGraphShapeMinimizeEdge = 'Minimize edges len';
  LvlGraphShapeCalculateLay = 'Calculate layout from high-edge';
  LvlGraphStraightenGraph = 'Straighten graph';
  LvlGraphNamesAboveNode = 'Names above node';
  LvlGraphExtraSpacing = 'Extra spacing (x/y)';
  LvlGraphAddHorizontalSpacing = 'Add horizontal spacing between columns';
  LvlGraphAddVerticalSpacingAr = 'Add vertical spacing around nodes';
  LvlGraphShapeEdgesSplitMo = 'Edges split mode';
  LvlGraphShapeEdgesShape = 'Edges shape';
  LvlGraphShapeNodes = 'Nodes';
  LvlGraphOptEdges = 'Edges';
  LvlGraphOptEdgeLen = 'Edge len';
  LvlGraphOptLevels = 'Levels';
  LvlGraphOptCrossings = 'Crossings';
  LvlGraphOptSplitpoints = 'Splitpoints';
  LvlGraphOptInfo = 'Info';
  LvlGraphOptLimitHeightOfLvl = 'Limit height of Levels';
  LvlGraphOptAbsoluteLimi = 'Absolute limit for height of levels';
  LvlGraphOptLimitRelativ = 'Limit relative to node-count for height of levels.%0s'
    +'Limit = min(3, val*sqrt(NodeCount))';
  ShowOptions = 'Show options';
  UnitDepOptionsForPackage = 'Options for Package graph';
  UnitDepOptionsForUnit = 'Options for Unit graph';
  LvlGraphReduceBackedges = 'Reduce backedges';
  lisDebugOptionsFrmBackend = 'Debugger backend';
  dlgPODebugger = 'Debugger';
  lisDebugOptionsFrmDebuggerBackend = 'Debugger Backend:';
  lisDebugOptionsFrmUseProjectDebugger = '-- Use project Debugger --';
  lisDebugOptionsFrmUseIDEDebugger = '-- Use IDE default Debugger --';
  lisDebugOptionsFrmUnknownDebuggerBacke = 'Unknown Debugger backend "%s"';
  lisDynPkgAutoScrollOnDeletePa = 'Auto Scroll on delete past left border';
  lisDynPkgAutoScrollOnTypePast = 'Auto Scroll on type past right border';
  lisDynPkgTriggerOnMinCharsVis = 'Trigger on min chars visible';
  lisDynPkgTriggerOnMinCharsOfW = 'Trigger on min chars (% of width)';
  lisDynPkgAmountToScrollIn = 'Amount to scroll in';
  lisDynPkgAmountToScrollIn2 = 'Amount to scroll in (%)';
  lisDynPkgAmountToScrollInMax = 'Amount to scroll in (Max)';
  drsUsingIDEDefaultDebuggerSe = 'Using IDE default debugger settings';
  drsUsingSelectedIDEDebuggerS = 'Using selected IDE debugger settings';
  drsIgnoringProjectDebuggerSettings = ' (Ignoring project settings below)';
  drsStoreProjectDebuggerConfi = 'Store project debugger configs in session';
  drsTheDebuggerBackendSelecti = 'The "Debugger Backend" selection from the '
    +'dropdown (list of IDE debugger backends) is always stored in the session'
    +'. The project specific backends (below) are by default stored in the LPI.';
  drsStoreConverterConfigInSes = 'Store converter config in session';
  drsThisOnlyAffectsTheListOfC = 'This only affects the list of converters '
    +'below. The settings which list to use are always stored in the session.';
  drsUseTheIDEGlobalListOfConv = 'Use the IDE-Global list of converters';
  drsUseTheProjectListOfConver = 'Use the project list of converters';
  drsStoreFormatterConfigInSes = 'Store formatter config in session';
  drsThisOnlyAffectsTheListOfFormatter = 'This only affects the list of formatters '
    +'below. The settings which list to use are always stored in the session.';
  drsUseTheIDEGlobalListOfFormatter  = 'Use the IDE-Global list of formatters';
  drsUseTheProjectListOfFormatter = 'Use the project list of formatters';
  drsStoreDispFormatConfigInSes = 'Store display formats config in session';
  drsThisOnlyAffectsDispFormats = 'This only affects the display formats '
    +'below. The settings which formats to use are always stored in the session.';
  drsUseIDEGlobalDispFormats  = 'Use the IDEs-global display formats';
  drsUseProjecfDispFormats = 'Use the projects display formats';

  InitDlgDebugPopupInformation = 'A backend provides OS and architecture '
    +'specific implementations for the debugger.%0:s'
    +'Default for your OS/Arch is: "%1:s".%0:s%0:s'
    +'Other backends are provided for special tasks (e.g. '
    +'cross debugging on some platforms) or as generic alternatives.%0:sThe '
    +'debugger can have different features, depending on the backend.%0:s%0:s'
    +'Some backends require an external exe (such as gdb or lldb). This exe '
    +'may be part of your OS (Linux/Mac), or be provided by the Lazarus '
    +'installer (Windows).%0:s%0:s'
    +'If you have just upgraded your installation,'
    +' you may have to rebuild the IDE before your previously configured '
    +'backend can be used (if you used a 3rd-party or optional backend). In '
    +'that case you may choose "Ignore".';

  InitDlgDebugExternalExePathDisplay = 'The selected backend uses the external'
    +' executable:';
  InitDlgDebugExternalExePathPrompt = 'The selected backend requires an '
    +'external executable: "%s"';
  InitDlgDebugClassNoteErrorNotSupported = 'Error: Your current config uses a '
    +'backend that is not supported on your OS/Arch.';
  InitDlgDebugClassNoteErrorNotConfigured = 'Error: The backend is not configured.';
  InitDlgDebugClassNoteErrorNotConfiguredMissingPackage = '(The configured '
    +'backend''s package is not installed.)';
  InitDlgDebugClassNoteHintNotRecommended = 'Hint: The backend type is OK, but'
    +' not the recommended type.';
  InitDlgDebugPathNoteErrorNoDefaultFound = 'Error: No default for external '
    +'executable found.';
  InitDlgDebugPathNoteErrorNoExeSpecified = 'Error: No external executable specified.';
  InitDlgDebugPathNoteErrorExeNotFound = 'Error: External executable not found.';
  InitDlgDebugPathNoteErrorExeIsDirectory = 'Error: External executable is a '
    +'directory, not a file.';
  InitDlgDebugPathNoteErrorExeNotRunnable = 'Error: External file is not '
    +'executable.';
  InitDlgDebugHeaderDefaultForYourOSArchIsS = 'Default for your OS/Arch is: "%'
    +'s".';
  InitDlgDebugKeepBackend = 'Keep backend';
  InitDlgDebugChangePath = 'Change path';
  InitDlgDebugCreateANewRecommendedBack = 'Create a new recommended backend';
  InitDlgDebugSelectAnExistingBackend = 'Select an existing backend';
  InitDlgDebugIgnore = 'Ignore';
  InitDlgDebugCurrent = 'Current';
  InitDlgDebugNew = 'New';

  InitDlgDebugStateMissingPackages = 'There may be packages (LPK) missing '
    +'from your IDE installation. You may need to rebuild the IDE and install '
    +'them, before making changes to the setup.';
  InitDlgDebugStateUpdateBackend = 'You are using an older backend. This may'
    +' not give you the best debugging experience. Consider upgrading to '
    +'the recommended backend.';
  InitDlgDebugStateRecommendedNotInList = 'There is no backend of '
    +'recommended type in the list of existing debuggers. Consider creating a '
    +'new backend.';
  InitDlgDebugStateRecommendedFoundInList = 'There is a backend of '
    +'recommended type in the list of existing debuggers. You may pick this '
    +'instead of creating a new backend.';
  InitDlgDebugStateSetupOk = 'Setup is OK.';
  InitDlgDebugStateMissingPackageRebuild = 'If you decide to rebuild the IDE'
    +' first and install missing packages, then select "Ignore" for now.%0:s'
    +'After the rebuild, the debugger backend can be changed in the menu: '
    +'Tools -> Options.';
  InitDlgDebugStateMissingPackageFooter = 'Note: There are more backend '
    +'configurations available, but their packages (LPK) are not installed. '
    +'You may want to rebuild the IDE with the packages installed. After the '
    +'rebuild, the debugger backend can be changed in the menu: Tools -> '
    +'Options.';
  optDispGutterMarks = 'Marks';
  optDispGutterChanges = 'Changes';
  optDispGutterSeparator = 'Separator';
  optDispGutterFolding = 'Folding';
  optDispGutterNoCurrentLineColor = 'No current line color';
  optDispGutterUseCurrentLineColor = 'Use current line color (gutter: other)';
  optDispGutterUseCurrentLineNumberColor = 'Use current line number color (gutter: number)';
  dlgMatchWords = 'Match words';
  dlgKeyWord = 'Keyword';
  dlgModifier = 'Modifier';
  dlgIAhadentifierComplEntryVar = 'Var';
  dlgIAhadentifierComplEntryType = 'Type';
  dlgIAhadentifierComplEntryConst = 'Const';
  dlgIAhadentifierComplEntryProc = 'Procedure';
  dlgIAhadentifierComplEntryFunc = 'Function';
  dlgIAhadentifierComplEntryAbstractProcFunc = 'Abstract proc/func';
  dlgIAhadentifierComplEntryLowerVisibilityProcFunc = 'Lower visibility proc/func';
  dlgIAhadentifierComplEntryProperty = 'Property';
  dlgIAhadentifierComplEntryIdent = 'Identifier';
  dlgIAhadentifierComplEntryLabel = 'Label';
  dlgIAhadentifierComplEntryUnit = 'Unit';
  dlgIAhadentifierComplEntryNamespace = 'Namespace';
  dlgIAhadentifierComplEntryText = 'Text';
  dlgIAhadentifierComplEntryCodeTemplate = 'Template';
  dlgIAhadentifierComplEntryKeyword = 'Keyword';
  dlgIAhadentifierComplEntryOther = 'Other';
  dlgIAhadentifierComplEntryEnum = 'Enum';
  dlgOptDebugBackendSelectDebuggerBackend = 'Select debugger backend';
  dlgOptDebugBackendEditDebuggerBackend = 'Edit debugger backend';
  dlgOptDebugBackendTheProjectOptionsHaveBeen = 'The project options have been set to use a '
    +'different debugger backend';
  dlgSrcEdColorLabelInTheSourceAreOnlyCo = 'Label in the source are only colored if the colon ":"'
    +' is placed immediately after the label.';
  dlgSrcEdColorMemberColorIsAppliedToAny = '"Member" color is applied to any identifier behind a '
    +'dot ".".';
  lisFailedToSaveMacro = 'Failed to save macro.';

implementation

end.
