/'******************************************************************************************
*
*   raylib [core] example - Scissor test
*
*   Example originally created with raylib 2.5, last time updated with raylib 3.0
*
*   Example contributed by Chris Dill (@MysteriousSpace) and reviewed by Ramon Santamaria (@raysan5)
*
*   Example licensed under an unmodified zlib/libpng license, which is an OSI-certified,
*   BSD-like license that allows static linking with closed source software
*
*   Copyright (c) 2019-2024 Chris Dill (@MysteriousSpace)
*
*******************************************************************************************'/

#include "../../raylib.bi"

'' Initialization
''--------------------------------------------------------------------------------------
const as long screenWidth = 800
const as long screenHeight = 450

InitWindow(screenWidth, screenHeight, "raylib [core] example - scissor test")

dim as Rectangle scissorArea = Rectangle(0, 0, 300, 300)
dim as boolean scissorMode = true

SetTargetFPS(60)               '' Set our game to run at 60 frames-per-second
''--------------------------------------------------------------------------------------

'' Main game loop
do while not WindowShouldClose()    '' Detect window close button or ESC key
    '' Update
    ''----------------------------------------------------------------------------------
    if IsKeyPressed(KEY_S) then scissorMode =  not scissorMode

    '' Centre the scissor area around the mouse position
    scissorArea.x = GetMouseX() - scissorArea.width/2
    scissorArea.y = GetMouseY() - scissorArea.height/2
    ''----------------------------------------------------------------------------------

    '' Draw
    ''----------------------------------------------------------------------------------
    BeginDrawing()

        ClearBackground(RAYWHITE)

        if (scissorMode) then BeginScissorMode(scissorArea.x, scissorArea.y, scissorArea.width, scissorArea.height)

        '' Draw full screen rectangle and some text
        '' NOTE: Only part defined by scissor area will be rendered
        DrawRectangle(0, 0, GetScreenWidth(), GetScreenHeight(), RED)
        DrawText("Move the mouse around to reveal this text!", 190, 200, 20, LIGHTGRAY)

        if (scissorMode) then EndScissorMode()

        DrawRectangleLinesEx(scissorArea, 1, BLACK)
        DrawText("Press S to toggle scissor test", 10, 10, 20, BLACK)

    EndDrawing()
    ''----------------------------------------------------------------------------------
loop

'' De-Initialization
''--------------------------------------------------------------------------------------
CloseWindow()        '' Close window and OpenGL context
''--------------------------------------------------------------------------------------
