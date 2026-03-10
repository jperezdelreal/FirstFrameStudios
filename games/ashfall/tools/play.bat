@echo off
REM Launch Ashfall fight scene
REM Usage: play.bat [--quit-after N]
REM   play.bat              → runs until you close the window
REM   play.bat --quit-after 5  → runs for 5 seconds then quits (headless testing)
REM
REM Controls (P1):
REM   WASD or Arrow keys = Move
REM   U = Light Punch, I = Medium Punch, O = Heavy Punch
REM   J = Light Kick,  K = Medium Kick,  L = Heavy Kick
REM   Space = Jump, S/Down = Crouch, Back = Block

setlocal

set GODOT="C:\Users\joperezd\Downloads\Godot_v4.6.1-stable_win64.exe\Godot_v4.6.1-stable_win64_console.exe"
set PROJECT="C:\Users\joperezd\FirstFrameStudios\games\ashfall"
set SCENE="res://scenes/main/fight_scene.tscn"

echo [play.bat] Launching Ashfall fight scene...

if "%~1"=="--quit-after" (
    echo [play.bat] Auto-quit after %2 seconds
    %GODOT% --path %PROJECT% --scene %SCENE% --quit-after %2
) else (
    %GODOT% --path %PROJECT% --scene %SCENE% %*
)

echo [play.bat] Done.
