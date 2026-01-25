/'******************************************************************************************
*
*   raylib [shapes] example - bouncing ball
*
*   Example originally created with raylib 2.5, last time updated with raylib 2.5
*
*   Example licensed under an unmodified zlib/libpng license, which is an OSI-certified,
*   BSD-like license that allows static linking with closed source software
*
*   Copyright (c) 2013-2024 Ramon Santamaria (@raysan5)
*
*******************************************************************************************'/

#include "../../raylib.bi"

'' Initialization
''---------------------------------------------------------
const as long screenWidth = 800
const as long screenHeight = 450

SetConfigFlags(FLAG_MSAA_4X_HINT)
InitWindow(screenWidth, screenHeight, "raylib [shapes] example - bouncing ball")

dim as Vector2 ballPosition = Vector2(GetScreenWidth()/2.0f, GetScreenHeight()/2.0f)
dim as Vector2 ballSpeed = Vector2(5.0f, 4.0f)
dim as long ballRadius = 20

dim as boolean pause = 0
dim as long framesCounter = 0

SetTargetFPS(60)               '' Set our game to run at 60 frames-per-second
''----------------------------------------------------------

'' Main game loop
do while not WindowShouldClose()    '' Detect window close button or ESC key
    '' Update
    ''-----------------------------------------------------
    if IsKeyPressed(KEY_SPACE) then pause =  not pause

    if not pause then
        ballPosition.x += ballSpeed.x
        ballPosition.y += ballSpeed.y

        '' Check walls collision for bouncing
        if (ballPosition.x >= (GetScreenWidth() - ballRadius)) or (ballPosition.x <= ballRadius) then ballSpeed.x *= -1.0f
        if (ballPosition.y >= (GetScreenHeight() - ballRadius)) or (ballPosition.y <= ballRadius) then ballSpeed.y *= -1.0f
    else 
        framesCounter += 1
    end if
    ''-----------------------------------------------------

    '' Draw
    ''-----------------------------------------------------
    BeginDrawing()

        ClearBackground(RAYWHITE)

        DrawCircleV(ballPosition, ballRadius, MAROON)
        DrawText("PRESS SPACE to PAUSE BALL MOVEMENT", 10, GetScreenHeight() - 25, 20, LIGHTGRAY)

        '' On pause, we draw a blinking message
        if pause and ((framesCounter/30) mod 2) <> 0 then DrawText("PAUSED", 350, 200, 30, GRAY)

        DrawFPS(10, 10)

    EndDrawing()
    ''-----------------------------------------------------
loop

'' De-Initialization
''---------------------------------------------------------
CloseWindow()        '' Close window and OpenGL context
''----------------------------------------------------------