:: check all the necessary parameters are given
if [%1]==[] goto USAGE
if [%2]==[] goto USAGE
if [%3]==[] goto USAGE
if [%4]==[] goto USAGE
if [%5]==[] goto USAGE

:: Set some environment variables from the command line
:: Path to the fpc sources checked out of fpcbuild git repository
SET FPCGITDIR=%1

:: Path to the lazarus sources checked out of subversion
SET LAZGITDIR=%2

:: Path to latest release compiler
SET RELEASE_PPC=%3

SET TARGETCPU=%4
SET TARGETOS=%5

SET LAZGITBINDIR=%6
SET SKIPCROSS=%7
SET LOCAL_INST_PREFIX=%8
if [%LOCAL_INST_PREFIX%] == [] SET LOCAL_INST_PREFIX=i386-win32

::=====================================================================
:: Find required programs
:: These settings are dependent on the configuration of the build machine

:: Path to the directory containing the binutils for each target in a 
:: separate directory, for example arm-wince for the arm-wince target
if [%BINUTILSDIR%]==[] SET BINUTILSDIR=c:\lazarus\source\binutils

:: Path to build directory. 
:: In this directory an image of the installation will be built.
SET BUILDDIR=c:\temp\lazbuild

::---------------------------------------------------------------------
:: Path to the Inno Setup Compiler
:: It may or may not have quotes, make sure it has.
SET ISCC="%ISCC%"
SET ISCC=%ISCC:"=%
SET ISCC="%ISCC%"
if not [%ISCC%]==[""] goto ISCC_DONE
SET ISCC="%ProgramFiles32bits%\Inno Setup 5\iscc.exe"
if not exist %ISCC% SET SET ISCC="%ProgramFiles%\Inno Setup 5\iscc.exe"
:: NO fallback to PATH
:ISCC_DONE

::---------------------------------------------------------------------
:: Path to the git executable; make sure it has quotes
SET GIT="%GIT%"
SET GIT=%GIT:"=%
SET GIT="%GIT%"
if not [%GIT%]==[""] GOTO GIT_DONE
:: set Subversion; if it doesn't exist try TortoiseGIT 32bits and 64bits else error info
SET GIT="%ProgramFiles%\Git\bin\git.exe"
if not exist %GIT% SET GIT="%ProgramFiles%\Git\mingw64\bin\git.exe"
if not exist %GIT% SET GIT="%ProgramFiles32bits%\Git\bin\git.exe"
:: Use GIT in Path
if not exist %GIT% SET GIT=git.exe
:GIT_DONE

:: Some internal variables
SET OLDCURDIR=%CD%
SET OLDCURDRIVE=%CD:~,2%
SET FPCGITDRIVE=%FPCGITDIR:~,2%
SET BUILDDRIVE=%BUILDDIR:~,2%


SET FPCBINDIR=%FPCGITDIR%\install\binw32
FOR /F %%L IN ('%FPCBINDIR%\gdate.exe +%%Y%%m%%d') DO SET DATESTAMP=%%L
SET FPCFULLTARGET=%TARGETCPU%-%TARGETOS%
FOR /F %%F IN ('"%GIT% -C %LAZGITDIR% log -1 --pretty=format:%%h" ') DO set LAZREVISION=%%F

SET TIMESTAMP=%date:~9,4%%date:~6,2%%date:~3,2%-%time:~,2%%time:~3,2%%time:~6,2%
SET MAKEEXE=%FPCBINDIR%\make.exe

:: set path to make sure the right tools are used
SET OLDPATH=%PATH%
PATH=%FPCBINDIR%;
%FPCGITDRIVE%
cd %FPCGITDIR%\fpcsrc

::=====================================================================
:: Build a native FPC

%MAKEEXE% distclean FPC=%RELEASE_PPC% 
rm -rf %FPCGITDIR%\fpcsrc\compiler\*.exe
:: create a native compiler + utils
%MAKEEXE% compiler_cycle FPC=%RELEASE_PPC%

FOR /F %%L IN ('%FPCGITDIR%\fpcsrc\compiler\utils\fpc.exe -PB') DO SET COMPILER=%FPCGITDIR%\fpcsrc\compiler\%%L
FOR /F %%L IN ('%COMPILER% -iSO') DO SET FPCSourceOS=%%L
FOR /F %%L IN ('%COMPILER% -iSP') DO SET FPCSourceCPU=%%L
FOR /F %%L IN ('%FPCGITDIR%\fpcsrc\compiler\utils\fpc.exe -P%TARGETCPU% -PB') DO SET PPCNAME=%%L
SET FPCFPMAKE=%COMPILER%

:: rebuild the rtl without WPO information
%MAKEEXE% rtl_clean PP=%COMPILER%
:: 271 needs packages too
%MAKEEXE% rtl packages PP=%COMPILER% OPT="-Ur -CX"
%MAKEEXE% utils PP=%COMPILER% OPT="-Ur -CX -XX -Xs" DATA2INC=%FPCGITDIR%\fpcsrc\utils\data2inc

:: do NOT clean => or 2.7.1 will try to build a fpmake.exe for arm-wince (and fail)

:: find fpcmake
FOR /F %%L IN ('%COMPILER% -iV') DO SET FPCVERSION=%%L
FOR /F %%L IN ('%COMPILER% -iTO') DO SET FPCTARGETOS=%%L
FOR /F %%L IN ('%COMPILER% -iTP') DO SET FPCTARGETCPU=%%L
SET FPCFULLNATIVE=%FPCTARGETCPU%-%FPCTARGETOS%

SET FPCMAKE=%FPCGITDIR%\fpcsrc\utils\fpcm\bin\%FPCFULLNATIVE%\fpcmake.exe
IF "%FPCVERSION:~0,3%" == "2.6" SET FPCMAKE=%FPCGITDIR%\fpcsrc\utils\fpcm\fpcmake.exe

::=====================================================================
:: Build cross FPC

:: CROSSBINDIR and are used in the FPC makefiles
SET CROSSBINDIR=%BINUTILSDIR%\%FPCFULLTARGET%
SET BINUTILSPREFIX=%FPCFULLTARGET%-

if NOT [%SKIPCROSS%] == [] GOTO NOCROSS

%MAKEEXE% compiler FPC=%COMPILER% PPC_TARGET=%TARGETCPU% EXENAME=%PPCNAME%
IF ERRORLEVEL 1 GOTO CLEANUP
SET COMPILER=%FPCGITDIR%\fpcsrc\compiler\%PPCNAME%
SET CPU_TARGET=%TARGETCPU%
SET OS_TARGET=%TARGETOS%

%MAKEEXE% rtl packages FPC=%COMPILER% 
IF ERRORLEVEL 1 GOTO CLEANUP

:NOCROSS

FOR /F %%L IN ('%COMPILER% -iV') DO SET FPCVERSION=%%L
FOR /F %%L IN ('%COMPILER% -iW') DO SET FPCFULLVERSION=%%L

SET INSTALL_BASE=%BUILDDIR%\image\fpc\%FPCVERSION%
SET INSTALL_BINDIR=%INSTALL_BASE%\bin\%LOCAL_INST_PREFIX%

:: copy the binutils
rmdir /s /q %BUILDDIR%
gmkdir -p %INSTALL_BINDIR%

%MAKEEXE% rtl_install packages_install FPCMAKE=%FPCMAKE% INSTALL_PREFIX=%INSTALL_BASE% FPC=%COMPILER%

:: delete any binaries: they will cause conflicts with existing native
rm -f %INSTALL_BINDIR%\*.*

cp %CROSSBINDIR%\* %INSTALL_BINDIR%
copy %COMPILER% %INSTALL_BINDIR%\%PPCNAME%

:: Path to the directory containing the mingw gdb debugger installation
:: it should have the debugger with the name gdb.exe in its bin subdirectory
SET GDBDIR=%LAZGITBINDIR%\%FPCFULLTARGET%\gdb
::---------------------------------------------------------------------
:: copy gdb into build dir
if NOT exist %GDBDIR% goto NOGDB
gmkdir -p %BUILDDIR%\image\mingw\%FPCFULLTARGET%
cp -pr  %GDBDIR%\*  %BUILDDIR%\image\mingw\%FPCFULLTARGET%
rem %GIT% export -q %GDBDIR% %BUILDDIR%\image\mingw\%FPCFULLTARGET%
:NOGDB

::=====================================================================
:: Re-Build some of the native FPC

::%MAKEEXE% -C packages\fcl-base all FPC=%FPCFPMAKE% OS_TARGET=%FPCSourceOS% CPU_TARGET=%FPCSourceCPU%
::%MAKEEXE% -C packages\fcl-process all FPC=%FPCFPMAKE% OS_TARGET=%FPCSourceOS% CPU_TARGET=%FPCSourceCPU%
::%MAKEEXE% -C utils fpcmkcfg_all FPC=%FPCFPMAKE% OS_TARGET=%FPCSourceOS% CPU_TARGET=%FPCSourceCPU%

:: Create fpc.cfg
IF "%FPCVERSION:~0,3%" == "2.6" GOTO M262
%FPCGITDIR%\fpcsrc\utils\fpcmkcfg\bin\%FPCFULLNATIVE%\fpcmkcfg.exe -d "basepath=%INSTALL_BASE%" -o %INSTALL_BINDIR%\fpc.cfg
GOTO MCONT
:M262
%FPCGITDIR%\fpcsrc\utils\fpcmkcfg\fpcmkcfg.exe -d "basepath=%INSTALL_BASE%" -o %INSTALL_BINDIR%\fpc.cfg
:MCONT

SET COMPILER=%INSTALL_BINDIR%\%PPCNAME%

::=====================================================================
:: Build Lazarus

gmkdir -p %BUILDDIR%\packager
%GIT% -C %LAZGITDIR% --work-tree=%BUILDDIR% restore packager\registration
%BUILDDRIVE%
cd %BUILDDIR%\packager\registration
%MAKEEXE% FPC=%compiler%
IF ERRORLEVEL 1 GOTO CLEANUP
gmkdir -p %BUILDDIR%\image\packager\units
cp -pr %BUILDDIR%\packager\units\%FPCFULLTARGET% %BUILDDIR%\image\packager\units\%FPCFULLTARGET%

gmkdir -p %BUILDDIR%\components
%GIT% -C %LAZGITDIR% --work-tree=%BUILDDIR% restore components\lazutils
%BUILDDRIVE%
cd %BUILDDIR%\components\lazutils
%MAKEEXE% FPC=%compiler%
IF ERRORLEVEL 1 GOTO CLEANUP
gmkdir -p %BUILDDIR%\image\components\lazutils
cp -pr %BUILDDIR%\components\lazutils\lib %BUILDDIR%\image\components\lazutils\lib

%GIT% -C %LAZGITDIR% --work-tree=%BUILDDIR% restore components\freetype
%BUILDDRIVE%
cd %BUILDDIR%\components\freetype
%MAKEEXE% FPC=%compiler%
IF ERRORLEVEL 1 GOTO CLEANUP
gmkdir -p %BUILDDIR%\image\components\freetype
cp -pr %BUILDDIR%\components\freetype\lib %BUILDDIR%\image\components\freetype\lib

%GIT% -C %LAZGITDIR% --work-tree=%BUILDDIR% restore lcl
%BUILDDRIVE%
cd %BUILDDIR%\lcl
%MAKEEXE% FPC=%compiler%
IF ERRORLEVEL 1 GOTO CLEANUP
gmkdir -p %BUILDDIR%\image\lcl\units
cp -pr %BUILDDIR%\lcl\units\%FPCFULLTARGET% %BUILDDIR%\image\lcl\units\%FPCFULLTARGET%

%GIT% -C %LAZGITDIR% --work-tree=%BUILDDIR% restore components\lazcontrols
%BUILDDRIVE%
cd %BUILDDIR%\components\lazcontrols
%MAKEEXE% FPC=%compiler%
IF ERRORLEVEL 1 GOTO CLEANUP
gmkdir -p %BUILDDIR%\image\components\lazcontrols
cp -pr %BUILDDIR%\components\lazcontrols\lib %BUILDDIR%\image\components\lazcontrols\lib

gmkdir -p %BUILDDIR%\components
%GIT% -C %LAZGITDIR% --work-tree=%BUILDDIR% restore components\buildintf
:: export images dir, the buildintf includes them
%GIT% -C %LAZGITDIR% --work-tree=%BUILDDIR% restore images
cd %BUILDDIR%\components\buildintf
IF ERRORLEVEL 1 GOTO CLEANUP
%MAKEEXE% FPC=%compiler%
gmkdir -p %BUILDDIR%\image\components\buildintf\units
cp -pr %BUILDDIR%\components\buildintf\units\%FPCFULLTARGET% %BUILDDIR%\image\components\buildintf\units\%FPCFULLTARGET%

gmkdir -p %BUILDDIR%\components
%GIT% -C %LAZGITDIR% --work-tree=%BUILDDIR% restore components\ideintf
cd %BUILDDIR%\components\ideintf
IF ERRORLEVEL 1 GOTO CLEANUP
%MAKEEXE% FPC=%compiler%
gmkdir -p %BUILDDIR%\image\components\ideintf\units
cp -pr %BUILDDIR%\components\ideintf\units\%FPCFULLTARGET% %BUILDDIR%\image\components\ideintf\units\%FPCFULLTARGET%

%GIT% -C %LAZGITDIR% --work-tree=%BUILDDIR% restore components\synedit
cd %BUILDDIR%\components\synedit
IF ERRORLEVEL 1 GOTO CLEANUP
%MAKEEXE% FPC=%compiler%
gmkdir -p %BUILDDIR%\image\components\synedit\units
cp -pr %BUILDDIR%\components\synedit\units\%FPCFULLTARGET% %BUILDDIR%\image\components\synedit\units\%FPCFULLTARGET%

del %INSTALL_BINDIR%\fpc.cfg

%OLDCURDRIVE%
cd %OLDCURDIR%
FOR /F %%F IN ('%LAZGITDIR%\tools\install\get_lazarus_version.bat') DO set LAZVERSION=%%F

SET OutputFileName=lazarus-%LAZVERSION%-fpc-%FPCFULLVERSION%-cross-%FPCFULLTARGET%-%FPCSourceOS%
if [%BUILDLAZRELEASE%]==[] SET OutputFileName=lazarus-%LAZVERSION%-%LAZREVISION%-fpc-%FPCFULLVERSION%-%DATESTAMP%-cross-%FPCFULLTARGET%-%FPCSourceOS%

SET OutputFileName=%OutputFileName::=_%

:: %LAZBUILD_HOOK_DIR% is a directory, that can contain scripts to be hooked into the build process. Further hooks can be defined the same way
if not [%LAZBUILD_HOOK_DIR%]==[] if exist %LAZBUILD_HOOK_DIR%\lazhook_before_iscc.bat call %LAZBUILD_HOOK_DIR%\lazhook_cross_before_iscc.bat

if  [%LAZBUILD_REPLACE_TEXT%]==[] GOTO NO_REPLACE
if not exist %LAZBUILD_REPLACE_TEXT% GOTO NO_REPLACE

%LAZBUILD_REPLACE_TEXT% %BUILDDIR%\image\packager\units\%TARGETCPU%-%TARGETOS%\FCL.compiled "-MObjFPC" "-T%TARGETOS% -P%TARGETCPU% -MObjFPC"
%LAZBUILD_REPLACE_TEXT% %BUILDDIR%\image\lcl\units\%TARGETCPU%-%TARGETOS%\LCLBase.compiled "-MObjFPC" "-T%TARGETOS% -P%TARGETCPU% -MObjFPC"
%LAZBUILD_REPLACE_TEXT% %BUILDDIR%\image\components\lazutils\lib\%TARGETCPU%-%TARGETOS%\LazUtils.compiled "-MObjFPC" "-T%TARGETOS% -P%TARGETCPU% -MObjFPC"
%LAZBUILD_REPLACE_TEXT% %BUILDDIR%\image\components\freetype\lib\%TARGETCPU%-%TARGETOS%\freetypelaz.compiled "-MObjFPC" "-T%TARGETOS% -P%TARGETCPU% -MObjFPC"

%LAZBUILD_REPLACE_TEXT% %BUILDDIR%\image\lcl\units\%TARGETCPU%-%TARGETOS%\%LCL_PLATFORM%\LCL.compiled "-MObjFPC" "-T%TARGETOS% -P%TARGETCPU% -MObjFPC"
%LAZBUILD_REPLACE_TEXT% %BUILDDIR%\image\components\synedit\units\%TARGETCPU%-%TARGETOS%\%LCL_PLATFORM%\SynEdit.compiled "-MObjFPC" "-T%TARGETOS% -P%TARGETCPU% -MObjFPC"
%LAZBUILD_REPLACE_TEXT% %BUILDDIR%\image\components\lazcontrols\lib\%TARGETCPU%-%TARGETOS%\%LCL_PLATFORM%\LazControls.compiled "-MObjFPC" "-T%TARGETOS% -P%TARGETCPU% -MObjFPC"
%LAZBUILD_REPLACE_TEXT% %BUILDDIR%\image\components\buildintf\units\%TARGETCPU%-%TARGETOS%\BuildIntf.compiled "-MObjFPC" "-T%TARGETOS% -P%TARGETCPU% -MObjFPC"
%LAZBUILD_REPLACE_TEXT% %BUILDDIR%\image\components\ideintf\units\%TARGETCPU%-%TARGETOS%\%LCL_PLATFORM%\IDEIntf.compiled "-MObjFPC" "-T%TARGETOS% -P%TARGETCPU% -MObjFPC"

:GOTO NO_REPLACE

%ISCC% lazarus-cross.iss 

:CLEANUP
SET FPCFPMAKE=
SET CPU_TARGET=
SET OS_TARGET=
SET CROSSBINDIR=
SET BINUTILSPREFIX=
SET PATH=%OLDPATH%

goto STOP

:USAGE
@echo off
echo Usage:
echo build-cross.bat FPCGITDIR LAZGITDIR RELEASECOMPILER TARGETCPU TARGETOS [LAZGITBINDIR] [SKIPCROSS] [LOCAL_INST_PREFIX]
echo FPCGITDIR: directory that contains a git version of the fpcbuild repository
echo LAZGITDIR: directory that contains a git version of the lazarus repository
echo RELEASECOMPILER: bootstrapping compiler for building fpc
echo TARGETCPU: target CPU
echo TARGETOS: target operating system
echo LAZGITBINDIR (optional) Include GDB, if present for target // git co http://svn.freepascal.org/svn/lazarus/binaries
echo SKIPCROSS (optional) build normal, instead of cross. Needed to build i386 on win64
echo LOCAL_INST_PREFIX (optional / default i386-win32) the prefix of the system on which it will be installed.

:STOP
