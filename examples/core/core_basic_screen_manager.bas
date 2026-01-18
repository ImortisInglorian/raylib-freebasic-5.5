/'******************************************************************************************
*
*   raylib [core] examples - basic screen manager
*
*   NOTE: This example illustrates a very simple screen manager based on a states machines
*
*   Example originally created with raylib 4.0, last time updated with raylib 4.0
*
*   Example licensed under an unmodified zlib/libpng license, which is an OSI-certified,
*   BSD-like license that allows static linking with closed source software
*
*   Copyright (c) 2021-2024 Ramon Santamaria (@raysan5)
*
*******************************************************************************************'/

#include "../../raylib.bi"

''------------------------------------------------------------------------------------------
'' Types and Structures Definition
''------------------------------------------------------------------------------------------
enum GameScreen
    LOGO = 0
    TITLE
    GAMEPLAY
    ENDING
end enum

    '' Initialization
    ''--------------------------------------------------------------------------------------
    const as long screenWidth = 800
    const as long screenHeight = 450

    InitWindow(screenWidth, screenHeight, "raylib [core] example - basic screen manager")

    dim as GameScreen currentScreen = LOGO

    '' TODO: Initialize all required variables and load all required data here!

    dim as long framesCounter = 0          '' Useful to count frames

    SetTargetFPS(60)               '' Set desired framerate (frames-per-second)
    ''--------------------------------------------------------------------------------------

    '' Main game loop
    do while not WindowShouldClose()    '' Detect window close button or ESC key
        '' Update
        ''----------------------------------------------------------------------------------
        select case currentScreen
            case LOGO
                '' TODO: Update LOGO screen variables here!

                framesCounter += 1    '' Count frames

                '' Wait for 2 seconds (120 frames) before jumping to TITLE screen
                if framesCounter > 120 then
                    currentScreen = TITLE
                end if
            case TITLE
                '' TODO: Update TITLE screen variables here!

                '' Press enter to change to GAMEPLAY screen
                if IsKeyPressed(KEY_ENTER) or IsGestureDetected(GESTURE_TAP) then
                    currentScreen = GAMEPLAY
                end if
            case GAMEPLAY
                '' TODO: Update GAMEPLAY screen variables here!

                '' Press enter to change to ENDING screen
                if IsKeyPressed(KEY_ENTER) or IsGestureDetected(GESTURE_TAP) then
                    currentScreen = ENDING
                end if
            case ENDING
                '' TODO: Update ENDING screen variables here!

                '' Press enter to return to TITLE screen
                if IsKeyPressed(KEY_ENTER) or IsGestureDetected(GESTURE_TAP) then
                    currentScreen = TITLE
                end if
        end select
        ''----------------------------------------------------------------------------------

        '' Draw
        ''----------------------------------------------------------------------------------
        BeginDrawing()

            ClearBackground(RAYWHITE)

            select case currentScreen
                case LOGO
                    '' TODO: Draw LOGO screen here!
                    DrawText("LOGO SCREEN", 20, 20, 40, LIGHTGRAY)
                    DrawText("WAIT for 2 SECONDS...", 290, 220, 20, GRAY)
                case TITLE
                    '' TODO: Draw TITLE screen here!
                    DrawRectangle(0, 0, screenWidth, screenHeight, GREEN)
                    DrawText("TITLE SCREEN", 20, 20, 40, DARKGREEN)
                    DrawText("PRESS ENTER or TAP to JUMP to GAMEPLAY SCREEN", 120, 220, 20, DARKGREEN)
                case GAMEPLAY
                    '' TODO: Draw GAMEPLAY screen here!
                    DrawRectangle(0, 0, screenWidth, screenHeight, PURPLE)
                    DrawText("GAMEPLAY SCREEN", 20, 20, 40, MAROON)
                    DrawText("PRESS ENTER or TAP to JUMP to ENDING SCREEN", 130, 220, 20, MAROON)
                case ENDING
                    '' TODO: Draw ENDING screen here!
                    DrawRectangle(0, 0, screenWidth, screenHeight, BLUE)
                    DrawText("ENDING SCREEN", 20, 20, 40, DARKBLUE)
                    DrawText("PRESS ENTER or TAP to RETURN to TITLE SCREEN", 120, 220, 20, DARKBLUE)
            end select

        EndDrawing()
        ''----------------------------------------------------------------------------------
    loop

    '' De-Initialization
    ''--------------------------------------------------------------------------------------

    '' TODO: Unload all loaded data (textures, fonts, audio) here!

    CloseWindow()        '' Close window and OpenGL context
    ''--------------------------------------------------------------------------------------