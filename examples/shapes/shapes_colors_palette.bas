/'******************************************************************************************
*
*   raylib [shapes] example - Colors palette
*
*   Example originally created with raylib 1.0, last time updated with raylib 2.5
*
*   Example licensed under an unmodified zlib/libpng license, which is an OSI-certified,
*   BSD-like license that allows static linking with closed source software
*
*   Copyright (c) 2014-2024 Ramon Santamaria (@raysan5)
*
*******************************************************************************************'/

#include "../../raylib.bi"

#define MAX_COLORS_COUNT    21          '' Number of colors available

'' Initialization
''--------------------------------------------------------------------------------------
const as long screenWidth = 800
const as long screenHeight = 450

InitWindow(screenWidth, screenHeight, "raylib [shapes] example - colors palette")

dim as RLColor colors(MAX_COLORS_COUNT - 1) = { _
    DARKGRAY, MAROON, ORANGE, DARKGREEN, DARKBLUE, DARKPURPLE, DARKBROWN, _
    GRAY, RED, GOLD, LIME, BLUE, VIOLET, BROWN, LIGHTGRAY, PINK, YELLOW, _
    GREEN, SKYBLUE, PURPLE, BEIGE }

dim as zstring * 32 colorNames(MAX_COLORS_COUNT - 1) = { _
    "DARKGRAY", "MAROON", "ORANGE", "DARKGREEN", "DARKBLUE", "DARKPURPLE", _
    "DARKBROWN", "GRAY", "RED", "GOLD", "LIME", "BLUE", "VIOLET", "BROWN", _
    "LIGHTGRAY", "PINK", "YELLOW", "GREEN", "SKYBLUE", "PURPLE", "BEIGE" }

dim as Rectangle colorsRecs(MAX_COLORS_COUNT - 1)     '' Rectangles array

'' Fills colorsRecs data (for every rectangle)
for i as integer = 0 to MAX_COLORS_COUNT - 1
    colorsRecs(i).x = 20.0f + 100.0f * (i mod 7) + 10.0f * (i mod 7)
    colorsRecs(i).y = 80.0f + 100.0f * (i \ 7) + 10.0f * (i \ 7)
    colorsRecs(i).width = 100.0f
    colorsRecs(i).height = 100.0f
next

dim as long colorState(MAX_COLORS_COUNT - 1)           '' Color state: 0-DEFAULT, 1-MOUSE_HOVER

dim as Vector2 mousePoint = Vector2(0.0f, 0.0f)

SetTargetFPS(60)               '' Set our game to run at 60 frames-per-second
''--------------------------------------------------------------------------------------

'' Main game loop
do while not WindowShouldClose()    '' Detect window close button or ESC key
    '' Update
    ''----------------------------------------------------------------------------------
    mousePoint = GetMousePosition()

    for i as integer = 0 to MAX_COLORS_COUNT - 1
        if CheckCollisionPointRec(mousePoint, colorsRecs(i)) then 
            colorState(i) = 1
        else 
            colorState(i) = 0
        end if
    next
    ''----------------------------------------------------------------------------------

    '' Draw
    ''----------------------------------------------------------------------------------
    BeginDrawing()

        ClearBackground(RAYWHITE)

        DrawText("raylib colors palette", 28, 42, 20, BLACK)
        DrawText("press SPACE to see all colors", GetScreenWidth() - 180, GetScreenHeight() - 40, 10, GRAY)

        for i as integer = 0 to MAX_COLORS_COUNT - 1    '' Draw all rectangles
            DrawRectangleRec(colorsRecs(i), Fade(colors(i), iif(colorState(i), 0.6f, 1.0f)))

            if IsKeyDown(KEY_SPACE) or colorState(i) <> 0 then
                DrawRectangle(colorsRecs(i).x, colorsRecs(i).y + colorsRecs(i).height - 26, colorsRecs(i).width, 20, BLACK)
                DrawRectangleLinesEx(colorsRecs(i), 6, Fade(BLACK, 0.3f))
                DrawText(colorNames(i), (colorsRecs(i).x + colorsRecs(i).width - MeasureText(colorNames(i), 10) - 12), _
                    (colorsRecs(i).y + colorsRecs(i).height - 20), 10, colors(i))
            end if
        next

    EndDrawing()
    ''----------------------------------------------------------------------------------
loop

'' De-Initialization
''--------------------------------------------------------------------------------------
CloseWindow()                '' Close window and OpenGL context
''--------------------------------------------------------------------------------------