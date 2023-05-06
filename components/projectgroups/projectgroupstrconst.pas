unit ProjectGroupStrConst;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils;

Resourcestring
  lisErrTargetDoesNotExist      = 'Target does not exist. Remove?';
  lisErrNoSuchFile              = 'Could not find target file'+sLineBreak+
                                  '"%s"'+sLineBreak+
                                  'What do you want to do?';
  lisRemoveTarget                = 'Remove target';
  lisAbortLoadingProjectGroup    = 'Abort loading project group';
  lisSkipAllTargets              = 'Remove all invalid targets';
  lisErrOnlyProjectGroupAllowed  = 'Only target type "projectgroup" is allowed for root project group.';
  lisAllFiles = 'All files';
  lisProjectGroupModified        = 'Project group modified';
  lisProjectGroupModifiedConfirm = 'Project group "%s" is modified.'+sLineBreak+
                                   'What do you want to do?';

  lisSavePG  = 'Save project group';
  lisDiscard = 'Discard changes';
  lisAbort   = 'Abort';

  lisTargetAdd          = 'Add target';
  lisTargetRemove       = 'Remove target';
  lisUndo = 'Undo';
  lisRedo = 'Redo';
  lisOptions = 'Options';
  lisTargetCompile      = 'Compile';
  lisProjectGroups = 'Project Groups';
  lisTargetCompileClean = 'Compile clean';
  lisTargetCompileFromHere = 'Compile from here';
  lisTargetInstall      = 'Install';
  lisTargetUnInstall    = 'Uninstall';
  lisTargetActivate     = 'Activate target';
  lisTargetOpen         = 'Open Target';
  lisTargetRun          = 'Run Target';
  lisTargetProperties   = 'Target properties';
  lisTargetLater        = 'Compile target later';
  lisTargetEarlier      = 'Compile target earlier';
  lisNewProjectGroup    = 'New project group';
  lisNewProjectGroupMenuC    = 'New Project group ...';
  lisOpenProjectGroup   = 'Open Project Group ...';
  lisOpenRecentProjectGroup = 'Open Recent Project Group';
  lisSaveProjectGroup   = 'Save Project Group';
  lisSaveProjectGroupAs = 'Save Project Group As ...';
  lisTargetCopyFilename = 'Copy Filename';

  lisProjectGroup            = 'Project group %s';
  lisNodeTargets             = 'Targets';
  lisNodeRemovedTargets      = 'Removed targets';
  lisNodeBuildModes          = 'Build Modes';
  lisNodeFiles               = 'Files';
  lisNodeRemovedFiles        = 'Removed files';
  lisNodeDependencies        = 'Dependencies';
  lisNodeRemovedDependencies = 'Removed dependencies';
  lisTargetCount             = '%d targets';
  lisActiveTarget            = 'Target: %s';

  lisProjectGroupSaveCaption   = 'Save';
  lisProjectGroupSaveHint      = 'Save project group';
  lisProjectGroupSaveAsCaption = 'Save As ...';
  lisProjectGroupSaveAsHint    = 'Save project group with a new name';
  lisProjectGroupNewCaption = 'New';
  lisProjectGroupNewHint    = 'New project group';
  lisAddAllFromDirectoryCaption = 'Add all from directory recursively';
  lisAddAllFromDirectoryHint = 'Add all existing '
    +'targets from directory and its subdirectories to project group';
  lisProjectGroupAddCaption = 'Add';
  lisProjectGroupAddHint    = 'Add targets to project group';
  lisProjectGroupAddExistingCaption = 'Add from file';
  lisProjectGroupAddExistingHint    = 'Add existing target to project group';
  lisProjectGroupAddCurrentProjectCaption = 'Add current project';
  lisProjectGroupAddCurrentProjectHint    = 'Add current project to project group';
  lisProjectGroupDeleteCaption = 'Remove';
  lisProjectGroupDeleteHint    = 'Remove target from project group';
  lisProjectGroupAddNewCaption = 'New';
  lisProjectGroupAddNewHint    = 'Add new target to project group';
  lisTargetEarlierCaption      = 'Earlier';
  lisTargetEarlierHint         = 'Build target earlier';
  lisTargetLaterCaption        = 'Later';
  lisTargetLaterHint           = 'Build target later';
  lisTargetCompileCaption      = 'Compile';
  lisTargetCompileHint         = 'Compile selected target';
  lisTargetCompileCleanCaption = 'Compile clean';
  lisTargetCompileCleanHint    = 'Compile selected target clean';
  lisTargetPropertiesCaption   = 'Properties';
  lisTargetPropertiesHint      = 'Show property dialog for selected target';
  lisTargetRunCaption          = 'Run';
  lisTargetRunHint             = 'Run selected target';
  lisTargetInstallCaption      = 'Install';
  lisTargetInstallHint         = 'Install selected target';
  lisTargetUninstallCaption    = 'Uninstall';
  lisTargetUninstallHint       = 'Uninstall selected target';
  lisTargetActivateCaption     = 'Activate';
  lisTargetActivateHint        = 'Activate selected target';
  lisTargetOpenCaption         = 'Open';
  lisTargetOpenHint            = 'Open selected target';
  lisTargetInfoCaption         = 'Info ...';
  lisInvalidFile = 'Invalid File';
  lisInvalidXmlFileName = 'Invalid XML file name "%s".';
  lisReadError = 'Read error';
  lisUnableToLoadFile = 'Unable to load file "%s"';
  lisXMLSyntaxErrorInFile = 'XML syntax error in file "%s": %s';
  lisWriteError = 'Write error';
  lisUnableToCreateFile = 'Unable to create file "%s": %s';
  lisInvalidCycleAProjectGroupCannotHaveItselfAsTarget = 'Invalid cycle. A project group cannot have itself as target.';
  lisErrorReadingProjectGroupFile = 'Error reading project group file "%s"%s%s';
  lisUnableToWriteProjectGroupFile = 'Unable to write project group file "%s"%s%s';
  lisLazbuildNotFound = 'lazbuild not found';
  lisTheLazbuildWasNotFound = 'The lazbuild%s was not found.';
  lisProjectGroup2 = 'Project Group: %s';
  lisBePatient = 'Be patient!';
  lisThereIsStillAnotherBuildInProgress = 'There is still another build in progress.';
  lisCompileProject = 'Compile Project %s';
  lisBuildMode = ', build mode "%s"';
  lisCompilePackage = 'Compile Package %s';
  lisOtherProject = 'Other Project';
  lisPackage = 'Package';
  lisBuildModeNotFound = 'Build mode not found';
  lisBuildModeNotFound2 = 'Build mode "%s" not found.';
  lisPackageNotFound = 'Package not found';
  lisPackageNotFound2 = 'Package "%s" not found.';
  lisBuildMode2 = 'Build Mode "%s"';
  lisLazarusSupportedInProjectGroups = 'Lazarus files (*.lpi;*.lpk;*.lpg;*.pas;*.pp;*.p)';
  lisLazarusProjectsLpi = 'Lazarus projects (*.lpi)';
  lisLazarusPackagesLpk = 'Lazarus packages (*.lpk)';
  lisLazarusProjectGroupsLpg = 'Lazarus project groups (*.lpg)';
  lisPascalFilePasPpP = 'Pascal files (*.pas;*.pp;*.p)';
  lisChangesGetLostAtReload = 'There are unsaved changes that get lost if you reload the project group. '+
    'Do you really want to reload?';
  lisProjectGroupReload = 'Reload';
  lisMore = 'More';

  lisOpenLastGroupOnStart = 'Open last group on start';
  lisOnIDEStartReopenLastOpenGroup = 'On IDE start reopen last open group.';
  lisShowTargetPaths = 'Show target paths';
  lisEnableToShowTargetFilenamesWithPaths = 'Enable to show target filenames '
    +'with paths.';
  lisCompileAndBuildCompileTarget = '"Compile" and "Build" compile target';
  lisIDECommandsCompileAndBuildInvokeCompileBuildSelect = 'IDE commands "'
    +'Compile" and "Build" invoke compile/build selected target in project '
    +'group editor';

  lisInfo = 'Info';
  lisSourceDirectoriesOfProjectGroup = 'Source directories of project group:';

  lisProjectGroupsSourcePaths = 'Project group''s source paths';

implementation

end.

