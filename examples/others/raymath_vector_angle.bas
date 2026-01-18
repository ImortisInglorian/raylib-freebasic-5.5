/'******************************************************************************************
*
*   raylib [shapes] example - Vector Angle
*
*   Example originally created with raylib 1.0, last time updated with raylib 4.6
*
*   Example licensed under an unmodified zlib/libpng license, which is an OSI-certified,
*   BSD-like license that allows static linking with closed source software
*
*   Copyright (c) 2023 Ramon Santamaria (@raysan5)
*
********************************************************************************************'/
 
#include "../../raylib.bi"

'' Initialization
''--------------------------------------------------------------------------------------
const as long screenWidth = 800
const as long screenHeight = 450

InitWindow(screenWidth, screenHeight, "raylib [math] example - vector angle")

dim as Vector2 v0 = Vector2(screenWidth/2, screenHeight/2)
dim as Vector2 v1 = Vector2Add(v0, Vector2(100.0f, 80.0f))
dim as Vector2 v2             '' Updated with mouse position

dim as single angle = 0.0f             '' Angle in degrees
dim as long angleMode = 0              '' 0-Vector2Angle(), 1-Vector2LineAngle()

SetTargetFPS(60)               '' Set our game to run at 60 frames-per-second
''--------------------------------------------------------------------------------------

'' Main game loop
do while not WindowShouldClose()    '' Detect window close button or ESC key
    '' Update
    ''----------------------------------------------------------------------------------
    dim as single startangle = 0.0f

    if angleMode = 0 then startangle = -Vector2LineAngle(v0, v1) * RAD2DEG
    if angleMode = 1 then startangle = 0.0f

    v2 = GetMousePosition()

    if IsKeyPressed(KEY_SPACE) then angleMode = iif(angleMode = 1, 0, 1)
    
    if angleMode = 0 and IsMouseButtonDown(MOUSE_BUTTON_RIGHT) then v1 = GetMousePosition()

    if angleMode = 0 then
        '' Calculate angle between two vectors, considering a common origin (v0)
        dim as Vector2 v1Normal = Vector2Normalize(Vector2Subtract(v1, v0))
        dim as Vector2 v2Normal = Vector2Normalize(Vector2Subtract(v2, v0))

        angle = Vector2Angle(v1Normal, v2Normal)*RAD2DEG
    elseif angleMode = 1 then
        '' Calculate angle defined by a two vectors line, in reference to horizontal line
        angle = Vector2LineAngle(v0, v2)*RAD2DEG
    end if
    ''----------------------------------------------------------------------------------

    '' Draw
    ''----------------------------------------------------------------------------------
    BeginDrawing()

        ClearBackground(RAYWHITE)
        
        if angleMode = 0 then
            DrawText("MODE 0: Angle between V1 and V2", 10, 10, 20, BLACK)
            DrawText("Right Click to Move V2", 10, 30, 20, DARKGRAY)
            
            DrawLineEx(v0, v1, 2.0f, BLACK)
            DrawLineEx(v0, v2, 2.0f, RED)

            DrawCircleSector(v0, 40.0f, startangle, startangle + angle, 32, Fade(GREEN, 0.6f))
        elseif angleMode = 1 then
            DrawText("MODE 1: Angle formed by line V1 to V2", 10, 10, 20, BLACK)
            
            DrawLine(0, screenHeight/2, screenWidth, screenHeight/2, LIGHTGRAY)
            DrawLineEx(v0, v2, 2.0f, RED)

            DrawCircleSector(v0, 40.0f, startangle, startangle - angle, 32, Fade(GREEN, 0.6f))
        end if
        
        DrawText("v0", v0.x, v0.y, 10, DARKGRAY)

        '' If the line from v0 to v1 would overlap the text, move it's position up 10
        if angleMode = 0 and Vector2Subtract(v0, v1).y > 0.0f then DrawText("v1", v1.x, v1.y-10.0f, 10, DARKGRAY)
        if angleMode = 0 and Vector2Subtract(v0, v1).y < 0.0f then DrawText("v1", v1.x, v1.y, 10, DARKGRAY)

        '' If angle mode 1, use v1 to emphasize the horizontal line
        if angleMode = 1 then DrawText("v1", v0.x + 40.0f, v0.y, 10, DARKGRAY)

        '' position adjusted by -10 so it isn't hidden by cursor
        DrawText("v2", v2.x-10.0f, v2.y-10.0f, 10, DARKGRAY)

        DrawText("Press SPACE to change MODE", 460, 10, 20, DARKGRAY)
        DrawText(TextFormat("ANGLE: %2.2f", angle), 10, 70, 20, LIME)
        
    EndDrawing()
    ''----------------------------------------------------------------------------------
loop

'' De-Initialization
''--------------------------------------------------------------------------------------
CloseWindow()        '' Close window and OpenGL context
''--------------------------------------------------------------------------------------