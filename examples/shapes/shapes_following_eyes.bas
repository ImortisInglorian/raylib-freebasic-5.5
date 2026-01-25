/'******************************************************************************************
*
*   raylib [shapes] example - following eyes
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
''--------------------------------------------------------------------------------------
const as long screenWidth = 800
const as long screenHeight = 450

InitWindow(screenWidth, screenHeight, "raylib [shapes] example - following eyes")

dim as Vector2 scleraLeftPosition = Vector2(GetScreenWidth()/2.0f - 100.0f, GetScreenHeight()/2.0f)
dim as Vector2 scleraRightPosition = Vector2(GetScreenWidth()/2.0f + 100.0f, GetScreenHeight()/2.0f)
dim as single scleraRadius = 80

dim as Vector2 irisLeftPosition = Vector2(GetScreenWidth()/2.0f - 100.0f, GetScreenHeight()/2.0f)
dim as Vector2 irisRightPosition = Vector2(GetScreenWidth()/2.0f + 100.0f, GetScreenHeight()/2.0f)
dim as single irisRadius = 24

dim as single angle = 0.0f
dim as single dx = 0.0f, dy = 0.0f, dxx = 0.0f, dyy = 0.0f

SetTargetFPS(60)               '' Set our game to run at 60 frames-per-second
''--------------------------------------------------------------------------------------

'' Main game loop
do while not WindowShouldClose()    '' Detect window close button or ESC key
    '' Update
    ''----------------------------------------------------------------------------------
    irisLeftPosition = GetMousePosition()
    irisRightPosition = GetMousePosition()

    '' Check not inside the left eye sclera
    if not CheckCollisionPointCircle(irisLeftPosition, scleraLeftPosition, scleraRadius - irisRadius) then
        dx = irisLeftPosition.x - scleraLeftPosition.x
        dy = irisLeftPosition.y - scleraLeftPosition.y

        angle = atan2(dy, dx)

        dxx = (scleraRadius - irisRadius)*cos(angle)
        dyy = (scleraRadius - irisRadius)*sin(angle)

        irisLeftPosition.x = scleraLeftPosition.x + dxx
        irisLeftPosition.y = scleraLeftPosition.y + dyy
    end if

    '' Check not inside the right eye sclera
    if not CheckCollisionPointCircle(irisRightPosition, scleraRightPosition, scleraRadius - irisRadius) then
        dx = irisRightPosition.x - scleraRightPosition.x
        dy = irisRightPosition.y - scleraRightPosition.y

        angle = atan2(dy, dx)

        dxx = (scleraRadius - irisRadius)*cos(angle)
        dyy = (scleraRadius - irisRadius)*sin(angle)

        irisRightPosition.x = scleraRightPosition.x + dxx
        irisRightPosition.y = scleraRightPosition.y + dyy
    end if
    ''----------------------------------------------------------------------------------

    '' Draw
    ''----------------------------------------------------------------------------------
    BeginDrawing()

        ClearBackground(RAYWHITE)

        DrawCircleV(scleraLeftPosition, scleraRadius, LIGHTGRAY)
        DrawCircleV(irisLeftPosition, irisRadius, BROWN)
        DrawCircleV(irisLeftPosition, 10, BLACK)

        DrawCircleV(scleraRightPosition, scleraRadius, LIGHTGRAY)
        DrawCircleV(irisRightPosition, irisRadius, DARKGREEN)
        DrawCircleV(irisRightPosition, 10, BLACK)

        DrawFPS(10, 10)

    EndDrawing()
    ''----------------------------------------------------------------------------------
loop

'' De-Initialization
''--------------------------------------------------------------------------------------
CloseWindow()        '' Close window and OpenGL context
''--------------------------------------------------------------------------------------