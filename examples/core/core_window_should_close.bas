/'******************************************************************************************
*
*   raylib [core] example - Window should close
*
*   Example originally created with raylib 4.2, last time updated with raylib 4.2
*
*   Example licensed under an unmodified zlib/libpng license, which is an OSI-certified,
*   BSD-like license that allows static linking with closed source software
*
*   Copyright (c) 2013-2024 Ramon Santamaria (@raysan5)
*
*******************************************************************************************'/

#include "../../raylib.bi"

'' Initialization
''--------------------------------------------------------------------------------------
const as long screenWidth = 800
const as long screenHeight = 450

InitWindow(screenWidth, screenHeight, "raylib [core] example - window should close")

SetExitKey(KEY_NULL)       '' Disable KEY_ESCAPE to close window, X-button still works

dim as boolean exitWindowRequested = false   '' Flag to request window to exit
dim as boolean exitWindow = false    '' Flag to set window to exit

SetTargetFPS(60)           '' Set our game to run at 60 frames-per-second
''--------------------------------------------------------------------------------------

'' Main game loop
do while not exitWindow
    '' Update
    ''----------------------------------------------------------------------------------
    '' Detect if X-button or KEY_ESCAPE have been pressed to close window
    if WindowShouldClose() or IsKeyPressed(KEY_ESCAPE) then exitWindowRequested = true
    
    if (exitWindowRequested) then
        '' A request for close window has been issued, we can save data before closing
        '' or just show a message asking for confirmation
        
        if IsKeyPressed(KEY_Y) then 
            exitWindow = true
        elseif IsKeyPressed(KEY_N) then
            exitWindowRequested = false
        end if
    end if
    ''----------------------------------------------------------------------------------

    '' Draw
    ''----------------------------------------------------------------------------------
    BeginDrawing()

        ClearBackground(RAYWHITE)

        if (exitWindowRequested) then
            DrawRectangle(0, 100, screenWidth, 200, BLACK)
            DrawText("Are you sure you want to exit program? [Y/N]", 40, 180, 30, WHITE)
        else 
            DrawText("Try to close the window to get confirmation message!", 120, 200, 20, LIGHTGRAY)
        end if

    EndDrawing()
    ''----------------------------------------------------------------------------------
loop

'' De-Initialization
''--------------------------------------------------------------------------------------
CloseWindow()        '' Close window and OpenGL context
''--------------------------------------------------------------------------------------