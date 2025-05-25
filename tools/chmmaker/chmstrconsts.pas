unit CHMStrConsts;

{$mode ObjFPC}{$H+}

interface

uses
  Classes, SysUtils;

var
  Lang: String = '';

resourcestring
  rsCHMMakerCaption = 'CHM Help File Maker';

  // Common
  rsClose = 'Close';
  rsSave = 'Save';

  // CHMMain
  rsNew = 'New project...';
  rsOpen = 'Open project...';
  rsSaveAs = 'Save as...';
  rsQuit = 'Quit';
  rsCompile = 'Compile';
  rsEdit = 'Edit...';
  rsCompileAndView = 'Compile and view';
  rsAbout = 'About...';
  rsFileNotFound = 'File "%s" not found.';
  rsFileAlreadyExists_Overwrite = 'File "%s" already exists. Overwrite?';
  rsLHelpCouldNotBeLocatedAt = 'LHelp could not be located at "%s".';
  rsTryToBuildUsingLazBuild = 'Try to build using Lazbuild?';
  rsLazBuildCouldNotBeFound = 'Lazbuild could not be found.';
  rsLHelpFailedToBuild = 'LHelp failed to build.';
  rsThisWillAddAllFiles = 'This will add all files in the project directory recursively.';
  rsDoYouWantToContinue = 'Do you want to continue?';
  rsSaveChanges = 'Save changes?';
  rsProjectHasBeenModified = 'Project has been modified.';
  rsFileNameNeeded = 'You must set a filename for the output CHM file.';
  rsTableOfContentsFileNameNeeded = 'The name of the table-of-contents-file (.hhc) is not specified.';
  rsFileCreated = 'CHM file "%s" was created successfully.';
  rsBuildingLHelp = 'Building LHelp...';
  rsFiles = 'Files';
  rsNoName = '[no name]';

  rsNew_Hint = 'New project';
  rsOpen_Hint = 'Open project file';
  rsSave_Hint = 'Save project';
  rsSaveAs_Hint = 'Save project under a new name';
  rsClose_Hint = 'Close project';
  rsQuit_Hint = 'Quit program';
  rsCompile_Hint = 'Compile project';
  rsCompileAndView_Hint = 'Compile project and view generated CHM file';
  rsAbout_Hint = 'Information about this application';

  rsCreateSearchableHTML_Hint =
    'Only files added to the project manually are indexed, ' +
    'files added automatically are not indexed.';

  rsHelpProjectFiles = 'Help Project Files (*.hfp; *.hhp)';
  rsHelpFileProjectHfp = 'Help File Project (*.hfp)';
  rsHelpWorkshopProjectHHP = 'Help Workshop Project (*.hhp)';
  rsTOCFiles = 'Table of Contents files (*.hhc)';
  rsIndexFiles = 'Index files (*.hhk)';
  rsCompressedHTMLHelpFiles = 'Compressed HTML Help files';
  rsAllFiles = 'All files';

  // CHMSiteMapEditor
  rsSiteMapEditor = 'Sitemap Editor';
  rsSiteMap = 'Sitemap (Tree/List)';
  rsSelectLocalFile = 'You must select a local file first.';
  rsUntitled = 'Untitled';
  rsDescription = 'Description';
  rsFromTitle = 'From title';
  rsLocalLink = 'Local link (in CHM)';
  rsURL = 'URL (HTTP)';
  rsAddItem = 'Add item';
  rsBefore = 'Before';
  rsAfter = 'After';
  rsDelete = 'Delete';
  rsSubItem = 'Subitem';
  rsGlobalProperties = 'Global properties';
  rsFont = 'Font';
  rsBackgroundColor = 'Background color';
  rsForegroundColor = 'Foreground color';
  rsUseFolderIcons = 'Use folder icons';
  rsCancel = 'Cancel';

  // CHMAbout
  rsAboutCaption = 'About CHMMaker';
  rsVersion = 'Version:';
  rsCreatedWith = 'Created with ';  // space required
  rsAnd = ' and ';                  // spaces required
  rsOperatingSystem = 'Operating system:';
  rsTargetCPU = 'Target CPU:';
  rsTargetOS = 'Target OS:';
  rsTargetPlatform = 'Target platform:';

implementation

end.

