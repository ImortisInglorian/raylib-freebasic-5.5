/'******************************************************************************************
*
*   raylib [text] example - raylib fonts loading
*
*   NOTE: raylib is distributed with some free to use fonts (even for commercial pourposes!)
*         To view details and credits for those fonts, check raylib license file
*
*   Example originally created with raylib 1.7, last time updated with raylib 3.7
*
*   Example licensed under an unmodified zlib/libpng license, which is an OSI-certified,
*   BSD-like license that allows static linking with closed source software
*
*   Copyright (c) 2017-2024 Ramon Santamaria (@raysan5)
*
*******************************************************************************************'/

#include "../../raylib.bi"

#define MAX_FONTS   8

'' Initialization
''--------------------------------------------------------------------------------------
const as long screenWidth = 800
const as long screenHeight = 450

InitWindow(screenWidth, screenHeight, "raylib [text] example - raylib fonts")

'' NOTE: Textures MUST be loaded after Window initialization (OpenGL context is required)
dim as Font fonts(MAX_FONTS - 1)

fonts(0) = LoadFont("resources/fonts/alagard.png")
fonts(1) = LoadFont("resources/fonts/pixelplay.png")
fonts(2) = LoadFont("resources/fonts/mecha.png")
fonts(3) = LoadFont("resources/fonts/setback.png")
fonts(4) = LoadFont("resources/fonts/romulus.png")
fonts(5) = LoadFont("resources/fonts/pixantiqua.png")
fonts(6) = LoadFont("resources/fonts/alpha_beta.png")
fonts(7) = LoadFont("resources/fonts/jupiter_crash.png")

dim as zstring * 50 messages(MAX_FONTS - 1) = { "ALAGARD FONT designed by Hewett Tsoi", _
                            "PIXELPLAY FONT designed by Aleksander Shevchuk", _
                            "MECHA FONT designed by Captain Falcon", _
                            "SETBACK FONT designed by Brian Kent (AEnigma)", _
                            "ROMULUS FONT designed by Hewett Tsoi", _
                            "PIXANTIQUA FONT designed by Gerhard Grossmann", _
                            "ALPHA_BETA FONT designed by Brian Kent (AEnigma)", _
                            "JUPITER_CRASH FONT designed by Brian Kent (AEnigma)" }

dim as long spacings(MAX_FONTS - 1) = { 2, 4, 8, 4, 3, 4, 4, 1 }

dim as Vector2 positions(MAX_FONTS - 1)

for i as integer = 0 to MAX_FONTS - 1
    positions(i).x = screenWidth/2.0f - MeasureTextEx(fonts(i), messages(i), fonts(i).baseSize*2.0f, spacings(i)).x/2.0f
    positions(i).y = 60.0f + fonts(i).baseSize + 45.0f*i
next

'' Small Y position corrections
positions(3).y += 8
positions(4).y += 2
positions(7).y -= 8

dim as RLColor colors(MAX_FONTS - 1) = { MAROON, ORANGE, DARKGREEN, DARKBLUE, DARKPURPLE, LIME, GOLD, RED }

SetTargetFPS(60)               '' Set our game to run at 60 frames-per-second
''--------------------------------------------------------------------------------------

'' Main game loop
do while not WindowShouldClose()    '' Detect window close button or ESC key

    '' Draw
    ''----------------------------------------------------------------------------------
    BeginDrawing()

        ClearBackground(RAYWHITE)

        DrawText("free fonts included with raylib", 250, 20, 20, DARKGRAY)
        DrawLine(220, 50, 590, 50, DARKGRAY)

        for i as integer = 0 to MAX_FONTS - 1
            DrawTextEx(fonts(i), messages(i), positions(i), fonts(i).baseSize*2.0f, spacings(i), colors(i))
        next

    EndDrawing()
    ''----------------------------------------------------------------------------------
loop

'' De-Initialization
''--------------------------------------------------------------------------------------

'' Fonts unloading
for i as integer = 0 to MAX_FONTS - 1
    UnloadFont(fonts(i))
next

CloseWindow()                 '' Close window and OpenGL context
''--------------------------------------------------------------------------------------