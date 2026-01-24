/'******************************************************************************************
*
*   raylib [shapes] example - draw circle sector (with gui options)
*
*   Example originally created with raylib 2.5, last time updated with raylib 2.5
*
*   Example contributed by Vlad Adrian (@demizdor) and reviewed by Ramon Santamaria (@raysan5)
*
*   Example licensed under an unmodified zlib/libpng license, which is an OSI-certified,
*   BSD-like license that allows static linking with closed source software
*
*   Copyright (c) 2018-2024 Vlad Adrian (@demizdor) and Ramon Santamaria (@raysan5)
*
*******************************************************************************************'/

#include "../../raylib.bi"
#include "../../raygui.bi"                 '' Required for GUI controls

'' Initialization
''--------------------------------------------------------------------------------------
const as long screenWidth = 800
const as long screenHeight = 450

InitWindow(screenWidth, screenHeight, "raylib [shapes] example - draw circle sector")

dim as Vector2 center = Vector2((GetScreenWidth() - 300)/2.0f, GetScreenHeight()/2.0f)

dim as single outerRadius = 180.0f
dim as single startAngle = 0.0f
dim as single endAngle = 180.0f
dim as single segments = 10.0f
dim as single minSegments = 4

SetTargetFPS(60)               '' Set our game to run at 60 frames-per-second
''--------------------------------------------------------------------------------------

'' Main game loop
do while not WindowShouldClose()    '' Detect window close button or ESC key
    '' Update
    ''----------------------------------------------------------------------------------
    '' NOTE: All variables update happens inside GUI control functions
    ''----------------------------------------------------------------------------------

    '' Draw
    ''----------------------------------------------------------------------------------
    BeginDrawing()

        ClearBackground(RAYWHITE)

        DrawLine(500, 0, 500, GetScreenHeight(), Fade(LIGHTGRAY, 0.6f))
        DrawRectangle(500, 0, GetScreenWidth() - 500, GetScreenHeight(), Fade(LIGHTGRAY, 0.3f))

        DrawCircleSector(center, outerRadius, startAngle, endAngle, segments, Fade(MAROON, 0.3f))
        DrawCircleSectorLines(center, outerRadius, startAngle, endAngle, segments, Fade(MAROON, 0.6f))

        '' Draw GUI controls
        ''------------------------------------------------------------------------------
        GuiSliderBar(Rectangle( 600, 40, 120, 20), "StartAngle", TextFormat("%.2f", startAngle), @startAngle, 0, 720)
        GuiSliderBar(Rectangle( 600, 70, 120, 20), "EndAngle", TextFormat("%.2f", endAngle), @endAngle, 0, 720)

        GuiSliderBar(Rectangle( 600, 140, 120, 20), "Radius", TextFormat("%.2f", outerRadius), @outerRadius, 0, 200)
        GuiSliderBar(Rectangle( 600, 170, 120, 20), "Segments", TextFormat("%.2f", segments), @segments, 0, 100)
        ''------------------------------------------------------------------------------

        minSegments = (-int((endAngle - startAngle) / 90))
        DrawText(TextFormat("MODE: %s", iif(segments >= minSegments, "MANUAL", "AUTO")), 600, 200, 10, iif(segments >= minSegments, MAROON, DARKGRAY))

        DrawFPS(10, 10)

    EndDrawing()
    ''----------------------------------------------------------------------------------
loop

'' De-Initialization
''--------------------------------------------------------------------------------------
CloseWindow()        '' Close window and OpenGL context
''--------------------------------------------------------------------------------------