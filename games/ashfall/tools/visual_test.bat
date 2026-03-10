@echo off
REM ── Ashfall: Automated Fight Scene Visual Test ──
REM Launches the fight scene, simulates player inputs, captures screenshots.
REM Output: games/ashfall/tools/screenshots/fight_test/*.png
REM Author: Ackbar (QA/Playtester)

set GODOT="C:\Users\joperezd\Downloads\Godot_v4.6.1-stable_win64.exe\Godot_v4.6.1-stable_win64_console.exe"
set PROJECT="C:\Users\joperezd\FirstFrameStudios\games\ashfall"
set SCENE=res://scenes/test/fight_visual_test.tscn

echo [visual_test.bat] ==========================================
echo [visual_test.bat]  Running automated fight scene test...
echo [visual_test.bat] ==========================================

%GODOT% --path %PROJECT% --scene %SCENE% -- --visual-test

echo.
echo [visual_test.bat] Done. Check output above for screenshot paths.
