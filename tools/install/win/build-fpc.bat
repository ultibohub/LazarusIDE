SET OLDCURDIR=%CD%
SET OLDCURDRIVE=%CD:~,2%

SET FPCSRC_DIR=%FPCGITDIR%\fpcsrc

SET SOURCE_DIR=%BUILDDIR%\fpc-source
mkdir %SOURCE_DIR%
%GIT% -C %FPCSRC_DIR% --work-tree=%SOURCE_DIR% restore .

:: to switch drive
%SOURCE_DIR:~,2%
cd %SOURCE_DIR%

:: apply patch
if [%PATCHFILE%]==[] GOTO NO_PATCH
%PATCHEXE% -p0 -i %PATCHDIR%\%PATCHFILE%

:NO_PATCH 

:: copy fpc source
gmkdir -p %BUILDDIR%\fpc\source
cp -pr %SOURCE_DIR%\rtl %BUILDDIR%\fpc\source\rtl >> %LOGFILE%
cp -pr %SOURCE_DIR%\packages %BUILDDIR%\fpc\source\packages >> %LOGFILE%

:: build compiler
%MAKEEXE% clean PP=%RELEASE_PPC% >> %LOGFILE% 2>&1
%MAKEEXE% compiler_cycle PP=%RELEASE_PPC% >> %LOGFILE% 2>&1

FOR /F %%L IN ('%SOURCE_DIR%\compiler\utils\fpc.exe -PB') DO SET COMPILER=%SOURCE_DIR%\compiler\%%L
FOR /F %%L IN ('%COMPILER% -iV') DO SET FPCVERSION=%%L
FOR /F %%L IN ('%COMPILER% -iW') DO SET FPCFULLVERSION=%%L

%MAKEEXE% rtl_clean PP=%COMPILER% >> %LOGFILE%
%MAKEEXE% rtl packages PP=%COMPILER% OPT="-Ur -CX" >> %LOGFILE%

%MAKEEXE% utils PP=%COMPILER% OPT="-CX -XX -Xs" DATA2INC=%SOURCE_DIR%\utils\data2inc >> %LOGFILE%

SET INSTALL_BASE=%BUILDDIR%\fpc\%FPCVERSION%
SET INSTALL_BINDIR=%INSTALL_BASE%\bin\%FPCFULLTARGET%

SET FPCMAKE=%SOURCE_DIR%\utils\fpcm\bin\%FPCFULLTARGET%\fpcmake.exe
IF "%FPCVERSION:~0,3%" == "2.6" SET FPCMAKE=%SOURCE_DIR%\utils\fpcm\fpcmake.exe

%MAKEEXE% compiler_install rtl_install packages_install utils_install INSTALL_PREFIX=%INSTALL_BASE% PP=%COMPILER% FPCMAKE=%FPCMAKE% >> %LOGFILE%

FOR /F %%L IN ('%INSTALL_BINDIR%\fpc.exe -PB') DO SET COMPILER=%%L

:: move fpc source to final location
mv %BUILDDIR%\fpc\source %INSTALL_BASE% >> %LOGFILE%

%OLDCURDRIVE%
cd %OLDCURDIR%

rm -rf %SOURCE_DIR%
