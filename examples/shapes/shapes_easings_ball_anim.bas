/'******************************************************************************************
*
*   raylib [shapes] example - easings ball anim
*
*   Example originally created with raylib 2.5, last time updated with raylib 2.5
*
*   Example licensed under an unmodified zlib/libpng license, which is an OSI-certified,
*   BSD-like license that allows static linking with closed source software
*
*   Copyright (c) 2014-2024 Ramon Santamaria (@raysan5)
*
*******************************************************************************************'/

#include "../../raylib.bi"
#include "../../reasings.bi"                '' Required for easing functions

'' Initialization
''--------------------------------------------------------------------------------------
const as long screenWidth = 800
const as long screenHeight = 450

InitWindow(screenWidth, screenHeight, "raylib [shapes] example - easings ball anim")

'' Ball variable value to be animated with easings
dim as long ballPositionX = -100
dim as long ballRadius = 20
dim as single ballAlpha = 0.0f

dim as long state = 0
dim as long framesCounter = 0

SetTargetFPS(60)               '' Set our game to run at 60 frames-per-second
''--------------------------------------------------------------------------------------

'' Main game loop
do while not WindowShouldClose()    '' Detect window close button or ESC key
    '' Update
    ''----------------------------------------------------------------------------------
    if state = 0 then            '' Move ball position X with easing
        framesCounter += 1
        ballPositionX = EaseElasticOut(framesCounter, -100, screenWidth/2.0f + 100, 120)

        if framesCounter >= 120 then
            framesCounter = 0
            state = 1
        end if
    elseif state = 1 then        '' Increase ball radius with easing
        framesCounter += 1
        ballRadius = EaseElasticIn(framesCounter, 20, 500, 200)

        if framesCounter >= 200 then
            framesCounter = 0
            state = 2
        end if
    elseif state = 2 then        '' Change ball alpha with easing (background color blending)
        framesCounter += 1
        ballAlpha = EaseCubicOut(framesCounter, 0.0f, 1.0f, 200)

        if framesCounter >= 200 then
            framesCounter = 0
            state = 3
        end if
    elseif state = 3 then        '' Reset state to play again
        if IsKeyPressed(KEY_ENTER) then
            '' Reset required variables to play again
            ballPositionX = -100
            ballRadius = 20
            ballAlpha = 0.0f
            state = 0
        end if
    end if

    if IsKeyPressed(KEY_R) then framesCounter = 0
    ''----------------------------------------------------------------------------------

    '' Draw
    ''----------------------------------------------------------------------------------
    BeginDrawing()

        ClearBackground(RAYWHITE)

        if state >= 2 then DrawRectangle(0, 0, screenWidth, screenHeight, GREEN)
        DrawCircle(ballPositionX, 200, ballRadius, Fade(RED, 1.0f - ballAlpha))

        if state = 3 then DrawText("PRESS [ENTER] TO PLAY AGAIN!", 240, 200, 20, BLACK)

    EndDrawing()
    ''----------------------------------------------------------------------------------
loop

'' De-Initialization
''--------------------------------------------------------------------------------------
CloseWindow()        '' Close window and OpenGL context
''--------------------------------------------------------------------------------------