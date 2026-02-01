/'******************************************************************************************
*
*   raylib [texture] example - Image text drawing using TTF generated font
*
*   Example originally created with raylib 1.8, last time updated with raylib 4.0
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

InitWindow(screenWidth, screenHeight, "raylib [texture] example - image text drawing")

dim as Image parrots = LoadImage("resources/parrots.png") '' Load image in CPU memory (RAM)

'' TTF Font loading with custom generation parameters
dim as Font fnt = LoadFontEx("resources/KAISG.ttf", 64, 0, 0)

'' Draw over image using custom font
ImageDrawTextEx(@parrots, fnt, "[Parrots font drawing]", Vector2(20.0f, 20.0f), fnt.baseSize, 0.0f, RED)

dim as Texture2D tex = LoadTextureFromImage(parrots)  '' Image converted to texture, uploaded to GPU memory (VRAM)
UnloadImage(parrots)   '' Once image has been converted to texture and uploaded to VRAM, it can be unloaded from RAM

dim as Vector2 position = Vector2((screenWidth/2 - tex.width/2), (screenHeight/2 - tex.height/2 - 20))

dim as boolean showFont = false

SetTargetFPS(60)
''--------------------------------------------------------------------------------------

'' Main game loop
do while not WindowShouldClose()    '' Detect window close button or ESC key
    '' Update
    ''----------------------------------------------------------------------------------
    if IsKeyDown(KEY_SPACE) then
        showFont = true
    else
        showFont = false
    end if
    ''----------------------------------------------------------------------------------

    '' Draw
    ''----------------------------------------------------------------------------------
    BeginDrawing()

        ClearBackground(RAYWHITE)

        if not showFont then
            '' Draw texture with text already drawn inside
            DrawTextureV(tex, position, WHITE)

            '' Draw text directly using sprite font
            DrawTextEx(fnt, "[Parrots font drawing]", Vector2(position.x + 20, _
                        position.y + 20 + 280), fnt.baseSize, 0.0f, WHITE)
        else 
            DrawTexture(fnt.texture, screenWidth/2 - fnt.texture.width/2, 50, BLACK)
        end if

        DrawText("PRESS SPACE to SHOW FONT ATLAS USED", 290, 420, 10, DARKGRAY)

    EndDrawing()
    ''----------------------------------------------------------------------------------
loop

'' De-Initialization
''--------------------------------------------------------------------------------------
UnloadTexture(tex)     '' Texture unloading

UnloadFont(fnt)           '' Unload custom font

CloseWindow()              '' Close window and OpenGL context
''--------------------------------------------------------------------------------------