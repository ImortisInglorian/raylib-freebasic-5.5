/'******************************************************************************************
*
*   raylib [shapes] example - draw rectangle rounded (with gui options)
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

InitWindow(screenWidth, screenHeight, "raylib [shapes] example - draw rectangle rounded")

dim as single roundness = 0.2f
dim as single wid = 200.0f
dim as single height = 100.0f
dim as single segments = 0.0f
dim as single lineThick = 1.0f

dim as RLBOOL drawRect = RLFALSE
dim as RLBOOL drawRoundedRect = RLTRUE
dim as RLBOOL drawRoundedLines = RLFALSE

SetTargetFPS(60)               '' Set our game to run at 60 frames-per-second
''--------------------------------------------------------------------------------------

'' Main game loop
do while not WindowShouldClose()    '' Detect window close button or ESC key
    '' Update
    ''----------------------------------------------------------------------------------
    dim as Rectangle rec = Rectangle((GetScreenWidth() - wid - 250)/2, (GetScreenHeight() - height)/2.0f, wid, height)
    ''----------------------------------------------------------------------------------

    '' Draw
    ''----------------------------------------------------------------------------------
    BeginDrawing()

        ClearBackground(RAYWHITE)

        DrawLine(560, 0, 560, GetScreenHeight(), Fade(LIGHTGRAY, 0.6f))
        DrawRectangle(560, 0, GetScreenWidth() - 500, GetScreenHeight(), Fade(LIGHTGRAY, 0.3f))

        if drawRect = RLTRUE then DrawRectangleRec(rec, Fade(GOLD, 0.6f))
        if drawRoundedRect = RLTRUE then DrawRectangleRounded(rec, roundness, segments, Fade(MAROON, 0.2f))
        if drawRoundedLines = RLTRUE then DrawRectangleRoundedLinesEx(rec, roundness, segments, lineThick, Fade(MAROON, 0.4f))

        '' Draw GUI controls
        ''------------------------------------------------------------------------------
        GuiSliderBar(Rectangle(640,  40, 105, 20), "Width", TextFormat("%.2f", wid), @wid, 0, GetScreenWidth() - 300)
        GuiSliderBar(Rectangle(640,  70, 105, 20), "Height", TextFormat("%.2f", height), @height, 0, GetScreenHeight() - 50)
        GuiSliderBar(Rectangle(640, 140, 105, 20), "Roundness", TextFormat("%.2f", roundness), @roundness, 0.0f, 1.0f)
        GuiSliderBar(Rectangle(640, 170, 105, 20), "Thickness", TextFormat("%.2f", lineThick), @lineThick, 0, 20)
        GuiSliderBar(Rectangle(640, 240, 105, 20), "Segments", TextFormat("%.2f", segments), @segments, 0, 60)

        GuiCheckBox(Rectangle(640, 320, 20, 20), "DrawRoundedRect", @drawRoundedRect)
        GuiCheckBox(Rectangle(640, 350, 20, 20), "DrawRoundedLines", @drawRoundedLines)
        GuiCheckBox(Rectangle(640, 380, 20, 20), "DrawRect", @drawRect)
        ''------------------------------------------------------------------------------

        DrawText(TextFormat("MODE: %s", Iif(segments >= 4, "MANUAL", "AUTO")), 640, 280, 10, iif(segments >= 4, MAROON, DARKGRAY))

        DrawFPS(10, 10)

    EndDrawing()
    ''----------------------------------------------------------------------------------
loop

'' De-Initialization
''--------------------------------------------------------------------------------------
CloseWindow()        '' Close window and OpenGL context
''--------------------------------------------------------------------------------------