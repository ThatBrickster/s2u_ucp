@ECHO OFF
CLS

:: Automate the injection of relevant S2U BFF assets for the UCP.
::
:: Per request, this script now also works if it is 
:: run as administrator directly from the S2U install folder.
::
:: Authors: ermo@NoGripRacing (S2U Unofficial Community Patch maintainer)
::          matt2380@NoGripRacing (S2U Unofficial Community Patch creator)

:main

:: Let's not pollute the system variable namespace...

SETLOCAL EnableDelayedExpansion

SET _TIME=%TIME%
SET _VER=NoGrip_UCP_v1.1

@ECHO.
@ECHO NFS SHIFT 2: Unleashed Unofficial Community Patch
@ECHO =================================================
@ECHO.

GOTO check


:help

@ECHO.
@ECHO %_MSG%
@ECHO.
@ECHO Usage: %~n0
@ECHO.
@ECHO HINT:
@ECHO.
@ECHO  You can copy the contents of this folder (including subfolders) to
@ECHO  your S2U installation folder and right click this script and choose 
@ECHO  the option 'Run as administrator' (with no parameters).
@ECHO.
@ECHO  OR 
@ECHO.  
@ECHO  Using Windows Explorer, you can drag'n'drop your S2U installation folder
@ECHO  onto the the icon representing this script :)
@ECHO.

GOTO quit


:check

:: get the folder from which this batch file was run
:: and save it for future reference.
:: d = drive letter, p = folder path, 0 = references this file

SET _CWD="%~dp0"

:: This is necessary when the script is run as administrator
:: cd /d also switches drive as appropriate

IF "%CD%"=="%windir%\system32" (
@ECHO + Looks like we were run as administrator --
@ECHO + Changing working folder from: %CD%
@ECHO   to: %_CWD%
@ECHO.
CD /D %_CWD%
)

:: Now we should definitely be in the correct folder, 
:: but we're going to check that assumption anyway, just
:: to be on the safe side.

IF "%CD%"=="%windir%\system32" (
@ECHO - Current working folder is:
@ECHO  %CD%
@ECHO - It is supposed to be:
@ECHO  %_CWD%

SET _MSG=Aborting install because we won't be able to inject properly. Sorry.

 GOTO die
)

@ECHO + Working folder is:
@ECHO %_CWD% -- good.
@ECHO.

:: ensure the S2U install folder was specified as the first argument
:: OR that we were run from the S2U install folder.

:: To begin with, be opportunistic and assume that we are run
:: from the S2U install folder

SET _S2U_DIR=%_CWD%

:: If a parameter was supplied to the script, use that instead

IF NOT [%1]==[] (
    SET _S2U_DIR="%1"
)

IF NOT EXIST %_S2U_DIR%\SHIFT2U.exe (
    SET _MSG=- No SHIFT2U.exe file found in %_S2U_DIR% !
    GOTO help
)

@ECHO + Found SHIFT2U.exe in:
@ECHO %_S2U_DIR% -- good.
@ECHO.

:: check for the unpacking tool before we start

IF NOT EXIST %_CWD%quickbms.exe (
  SET _MSG=- No quickbms.exe S2U unpack tool found in %_CWD% -- aborting!
  GOTO die
)

IF NOT EXIST %_CWD%nfsshift.bms (
  SET _MSG=- No nfsshift.bms S2U BMS script found in %_CWD% -- aborting!
  GOTO die
)

@ECHO + quickbms tool found in:
@ECHO %_CWD% -- good.
@ECHO.

REM check for the injector tool before we start

if not exist %_CWD%\NFSSInjector.exe (
  SET _MSG=- No NFSSInjector.exe tool found in %_CWD% -- aborting!
  GOTO die
)

@ECHO + NFSSInjector.exe tool found in:
@ECHO %_CWD% -- good.
@ECHO.

:: Set up commands

SET INJECT=NFSSInjector.exe
SET UNPACK=%_CWD%quickbms.exe -o nfsshift.bms
SET XCOPY=xcopy /s /i /y /v /q

:: Set up paths

SET _ASSETS=UCP_modified_assets
SET _INSTALL_DIR=MODS\%_VER%_JSGME_install
SET _BACKUP=%_CWD%%_INSTALL_DIR%
SET _SRC=%_CWD%%_ASSETS%


:prepare

REM In this phase, create a full folder structure ready for JSGME activation.
REM We need to support the case where the user copies the folder
REM directly into the S2U installation folder as well.

@ECHO + Preparing JSGME compatible UCP mod installation folder in:
@ECHO %_CWD%%_INSTALL_DIR%
@ECHO.
@ECHO                                   (Press CTRL+C to quit now)
pause
@ECHO.

IF NOT EXIST %_BACKUP% (
  SET _MSG=- Could not create folder %_BACKUP% -- aborting!
  MKDIR %_BACKUP% || GOTO die
)

REM Getting a sense of how long it takes to prepare may be useful to users

SET _PREP_START=%TIME%

REM DLC1 various track fixes (for injection)

SET _DIR=DLC1\Pakfiles\Tracks
SET _SRC=%_S2U_DIR%\%_DIR%
SET _DEST=%_BACKUP%\%_DIR%\
SET _MSG=+ Copying files from %_SRC% ...
if exist %_SRC% (
  @ECHO %_MSG%
  @ECHO.
  FOR %%F in (
  hockenheim_era2.bff
  rouen.bff
  rouen_short.bff
  silverstone_era2.bff
  ) DO (
  @ECHO %%F
  %XCOPY% %_SRC%\%%F %_DEST% || GOTO die 
  )
)
@ECHO.

REM DLC2 various track fixes (for injection)

SET _DIR=DLC2\Pakfiles\Tracks
SET _SRC=%_S2U_DIR%\%_DIR%
SET _DEST=%_BACKUP%\%_DIR%\
SET _MSG=+ Copying files from %_SRC% ...
if exist %_SRC% (
  @ECHO %_MSG%
  @ECHO.
  FOR %%F in (
  asia_drag_strip.bff
  asia_drag_strip_night.bff
  asia_drag_strip2.bff
  asia_drag_strip2_night.bff
  usa_drag_strip.bff
  usa_drag_strip2.bff
  ) DO (
  @ECHO %%F
  %XCOPY% %_SRC%\%%F %_DEST% || GOTO die
  )
)
@ECHO.

REM Stock game various track fixes (for injection)

SET _DIR=Pakfiles\Tracks
SET _SRC=%_S2U_DIR%\%_DIR%
SET _DEST=%_BACKUP%\%_DIR%\
SET _MSG=+ Copying files from %_SRC% ...
@ECHO %_MSG%
@ECHO.
FOR %%F in (
Tokyo_Circuit_Night.bff
Tokyo_Drift_Night.bff
USA_Drift_Night.bff
Shanghai_Circuit2_night.bff
Shanghai_Circuit3_night.bff
Shanghai_Circuit1_night.bff
Tokyo_Short_reverse_night.bff
Nuerburgring_Sprint_Short_night.bff
Port_Boucle_Night.bff
Monument_Loop_Night.bff
Nuerburgring_GP_night.bff
Nuerburgring_Sprint_night.bff
Irwindale_Drift1_Night.bff
Irwindale_Drift2_Night.bff
Irwindale_night.bff
London_Drift_Night.bff
Ebisu_West_Night.bff
glendale_club_Night.bff
glendale_east_Night.bff
Hazyview_Oval_Night.bff
Dubai_GP_Night.bff
Dubai_INT_Night.bff
Dubai_NAT_Night.bff
Dubai_Club_Night.bff
Monte_Grande.bff
Nuerburgring_Sprint_Short.bff
Tokyo_Circuit.bff
Tokyo_Circuit_reverse.bff
Hazyview_Eight_Night.bff
Irwindale.bff
Irwindale_Drift1.bff
Irwindale_Drift2.bff
London_Drift.bff
Casino_Riviera_Night.bff
Dubai_NAT.bff
Ebisu_Touge.bff
Ebisu_West.bff
Barcelona_National.bff
Casino_Riviera.bff
Chesterglen.bff
Hazyview_Eight.bff
Nuerburgring_Sprint.bff
Tokyo_Short_Night.bff
Zolder.bff
Monument_Loop.bff
Nevada_Drift4_Night.bff
Port_Boucle.bff
Willow_springs_Horse_Thief_Mile.bff
Dubai_GP.bff
Dubai_INT.bff
Ebisu_Touge_Night.bff
Monza_Era3.bff
Monza_Era3_jr.bff
Nevada_Drift1.bff
Nevada_Drift1_Night.bff
Nevada_Drift2_Night.bff
Nevada_Drift3_Night.bff
Nevada_Drift4.bff
Tokyo_Drift.bff
Tokyo_Short_reverse.bff
Bathurst_night.bff
Hockenheim_Short_Night.bff
Hockenheim_Short.bff
Nevada_Drift2.bff
Tokyo_Short.bff
Barcelona_CLUB.bff
Hockenheim_GP_Night.bff
Hockenheim_National_Night.bff
Rustle_Creek.bff
Donington_GP.bff
Donington_National.bff
Dubai_Club.bff
Glendale_West_Night.bff
Hockenheim_GP.bff
Monte_Grande_Night.bff
Nevada_Drift3.bff
Nuerburgring_GP.bff
Barcelona_GP.bff
Dijon.bff
Dijon_short.bff
Ebisu_South.bff
Ebisu_South_Night.bff
Hazyview_Oval.bff
Hockenheim_National.bff
) DO (
@ECHO %%F
%XCOPY% %_SRC%\%%F %_DEST% || GOTO die
)
@ECHO.

SET _PREP_FINISH=%TIME%

@ECHO + Done preparing (started at %_PREP_START%, finished at %_PREP_FINISH%) ...
@ECHO.


:inject

REM Ok, so we have prepared the files in the JSGME dir
REM and can now inject the modifed files into the .bffs there.

REM Ensure that we're on the correct drive and in the correct folder
REM when injecting; better safe than sorry and all that jazz...

cd /d %_CWD%

@ECHO.
@ECHO + Ready to inject modified assets into the packed files in:
@ECHO.
@ECHO   %_CWD%%_INSTALL_DIR%\Pakfiles ...
@ECHO.
REM pause 
@ECHO. 

SET _MSG=+ Going to run NFSSInjector.exe -i %_ASSETS%\packed %_INSTALL_DIR% :
@ECHO %_MSG%
@ECHO.

REM Getting a sense of how long it takes to inject may be useful to users

SET _INJECT_START=%TIME%

if exist %_ASSETS%\packed (
%INJECT% -i %_ASSETS%\packed %_INSTALL_DIR% || GOTO die
@ECHO.
) else (
@ECHO - Current working folder is:
@ECHO  "%CD%"
@ECHO - It is supposed to be:
@ECHO  %_CWD%
@ECHO.
@ECHO - Hm. This is not supposed to happen.
@ECHO.
@ECHO - But since it did anyway, we'd better stop here.  Usually, this
@ECHO - indicates that your S2U folder lives on a different drive than
@ECHO - your Windows install and that you ran the script as administrator.
@ECHO.
@ECHO - If the above is true, try running the script normally instead
@ECHO - of with 'run as administrator' and see if that helps any.

GOTO die
)

if exist %_INSTALL_DIR%\DLC1 (
SET _MSG=+ Going to run NFSSInjector.exe -i %_ASSETS%\packedDLC1 %_INSTALL_DIR%\DLC1 :
@ECHO %_MSG%
@ECHO.
%INJECT% -i %_ASSETS%\packedDLC1 %_INSTALL_DIR%\DLC1 || GOTO die
@ECHO.
)

if exist %_INSTALL_DIR%\DLC2 (
SET _MSG=+ Going to run NFSSInjector.exe -i %_ASSETS%\packedDLC2 %_INSTALL_DIR%\DLC2 :
@ECHO %_MSG%
@ECHO.
%INJECT% -i %_ASSETS%\packedDLC2 %_INSTALL_DIR%\DLC2 || GOTO die
@ECHO.
)

SET _INJECT_FINISH=%TIME%
@ECHO.
@ECHO + Done injecting (started at %_INJECT_START%, finished at %_INJECT_FINISH%) ...
@ECHO.


:copy

REM Now copy in the UCP unpacked modified assets

SET _SRC=%_CWD%\%_ASSETS%\unpacked
SET _DEST=%_CWD%\%_INSTALL_DIR%
SET "_MSG=+ Copying modified files from %_ASSETS%\unpacked to the installation folder:"
@ECHO %_MSG%
@ECHO  %_CWD%%_INSTALL_DIR%
cd /d %_CWD%
%XCOPY% %_SRC% %_DEST% || GOTO die 


:finished

@ECHO.
@ECHO.
@ECHO + Successfully prepared the %_VER% JSGME installation folder in:
@ECHO.
@ECHO %_INSTALL_DIR%
@ECHO.
@ECHO. + Preparation phase : from %_PREP_START% to %_PREP_FINISH%
@ECHO. + Injection phase   : from %_INJECT_START% to %_INJECT_FINISH%
:: @ECHO. + Unpacking phase   : from %_UNPACK_START% to %_UNPACK_FINISH%
@ECHO.
REM display the size of the newly created UCP folder?

GOTO quit


:die

:: Set _MSG and GOTO die when something goes wrong.

@ECHO.
@ECHO - Uh Oh! Something went awry...
@ECHO.
@ECHO  The process failed during the following step:
@ECHO.
@ECHO  %_MSG%
@ECHO.
@ECHO - Please review the error message given, act appropriately, and try again :)
@ECHO.

GOTO quit


:quit

REM return to the root folder of the unpacked mod
cd /d "%_CWD%"

REM End local variable scope
ENDLOCAL
pause

:eof