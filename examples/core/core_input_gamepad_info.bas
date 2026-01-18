/'******************************************************************************************
*
*   raylib [core] example - Gamepad information
*
*   NOTE: This example requires a Gamepad connected to the system
*         Check raylib.h for buttons configuration
*
*   Example originally created with raylib 4.6, last time updated with raylib 4.6
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

SetConfigFlags(FLAG_MSAA_4X_HINT)  '' Set MSAA 4X hint before windows creation

InitWindow(screenWidth, screenHeight, "raylib [core] example - gamepad information")

SetTargetFPS(60)                   '' Set our game to run at 60 frames-per-second
dim as long y
''--------------------------------------------------------------------------------------

'' Main game loop
do while not WindowShouldClose()    '' Detect window close button or ESC key
    '' Update
    ''----------------------------------------------------------------------------------
    '' TODO: Update your variables here
    ''----------------------------------------------------------------------------------

    '' Draw
    ''----------------------------------------------------------------------------------
    BeginDrawing()

        ClearBackground(RAYWHITE)
        y = 5
        for i as integer = 0 to 3     '' MAX_GAMEPADS = 4
            if IsGamepadAvailable(i) then
                DrawText(TextFormat("Gamepad name: %s", GetGamepadName(i)), 10, y, 10, BLACK)
                y += 11
                DrawText(TextFormat("\tAxis count:   %d", GetGamepadAxisCount(i)), 10, y, 10, BLACK)
                y += 11

                for axis as integer = 0 to GetGamepadAxisCount(i) - 1
                    DrawText(TextFormat("\tAxis %d = %f", axis, GetGamepadAxisMovement(i, axis)), 10, y, 10, BLACK)
                    y += 11
                next

                for button as integer = 0 to 31
                    DrawText(TextFormat("\tButton %d = %d", button, IsGamepadButtonDown(i, button)), 10, y, 10, BLACK)
                    y += 11
                next
            end if
        next

        DrawFPS(GetScreenWidth() - 100, 100)

    EndDrawing()
    ''----------------------------------------------------------------------------------
loop

'' De-Initialization
''--------------------------------------------------------------------------------------
CloseWindow()        '' Close window and OpenGL context
''--------------------------------------------------------------------------------------