/'******************************************************************************************
*
*   raylib [shapes] example - Cubic-bezier lines
*
*   Example originally created with raylib 1.7, last time updated with raylib 1.7
*
*   Example licensed under an unmodified zlib/libpng license, which is an OSI-certified,
*   BSD-like license that allows static linking with closed source software
*
*   Copyright (c) 2017-2024 Ramon Santamaria (@raysan5)
*
*******************************************************************************************'/

#include "../../raylib.bi"

'' Initialization
''--------------------------------------------------------------------------------------
const as long screenWidth = 800
const as long screenHeight = 450

SetConfigFlags(FLAG_MSAA_4X_HINT)
InitWindow(screenWidth, screenHeight, "raylib [shapes] example - cubic-bezier lines")

dim as Vector2 startPoint = Vector2(30, 30)
dim as Vector2 endPoint = Vector2(screenWidth - 30, screenHeight - 30)
dim as boolean moveStartPoint = false
dim as boolean moveEndPoint = false

SetTargetFPS(60)               '' Set our game to run at 60 frames-per-second
''--------------------------------------------------------------------------------------

'' Main game loop
do while not WindowShouldClose()    '' Detect window close button or ESC key
    '' Update
    ''----------------------------------------------------------------------------------
    dim as Vector2 mouse = GetMousePosition()

    if CheckCollisionPointCircle(mouse, startPoint, 10.0f) and IsMouseButtonDown(MOUSE_BUTTON_LEFT) then 
        moveStartPoint = true
    elseif CheckCollisionPointCircle(mouse, endPoint, 10.0f) and IsMouseButtonDown(MOUSE_BUTTON_LEFT) then
        moveEndPoint = true
    end if

    if moveStartPoint then
        startPoint = mouse
        if IsMouseButtonReleased(MOUSE_BUTTON_LEFT) then moveStartPoint = false
    end if

    if moveEndPoint then
        endPoint = mouse
        if IsMouseButtonReleased(MOUSE_BUTTON_LEFT) then moveEndPoint = false
    end if
    ''----------------------------------------------------------------------------------

    '' Draw
    ''----------------------------------------------------------------------------------
    BeginDrawing()

        ClearBackground(RAYWHITE)

        DrawText("MOVE START-END POINTS WITH MOUSE", 15, 20, 20, GRAY)

        '' Draw line Cubic Bezier, in-out interpolation (easing), no control points
        DrawLineBezier(startPoint, endPoint, 4.0f, BLUE)
        
        '' Draw start-end spline circles with some details
        DrawCircleV(startPoint, iif(CheckCollisionPointCircle(mouse, startPoint, 10.0f), 14.0f, 8.0f), iif(moveStartPoint, RED, BLUE))
        DrawCircleV(endPoint, iif(CheckCollisionPointCircle(mouse, endPoint, 10.0f), 14.0f, 8.0f), iif(moveEndPoint, RED, BLUE))

    EndDrawing()
    ''----------------------------------------------------------------------------------
loop

'' De-Initialization
''--------------------------------------------------------------------------------------
CloseWindow()        '' Close window and OpenGL context
''--------------------------------------------------------------------------------------