/'******************************************************************************************
*
*   raylib [textures] example - Image loading and texture creation
*
*   NOTE: Images are loaded in CPU memory (RAM) textures are loaded in GPU memory (VRAM)
*
*   Example originally created with raylib 1.3, last time updated with raylib 1.3
*
*   Example licensed under an unmodified zlib/libpng license, which is an OSI-certified,
*   BSD-like license that allows static linking with closed source software
*
*   Copyright (c) 2015-2024 Ramon Santamaria (@raysan5)
*
*******************************************************************************************'/

#include "../../raylib.bi"

'' Initialization
''--------------------------------------------------------------------------------------
const as long screenWidth = 800
const as long screenHeight = 450

InitWindow(screenWidth, screenHeight, "raylib [textures] example - image loading")

'' NOTE: Textures MUST be loaded after Window initialization (OpenGL context is required)

dim as Image img = LoadImage("resources/raylib_logo.png")     '' Loaded in CPU memory (RAM)
dim as Texture2D tex = LoadTextureFromImage(img)          '' Image converted to texture, GPU memory (VRAM)
UnloadImage(img)   '' Once image has been converted to texture and uploaded to VRAM, it can be unloaded from RAM

SetTargetFPS(60)     '' Set our game to run at 60 frames-per-second
''---------------------------------------------------------------------------------------

'' Main game loop
do while not WindowShouldClose()    '' Detect window close button or ESC key
    '' Draw
    ''----------------------------------------------------------------------------------
    BeginDrawing()

        ClearBackground(RAYWHITE)

        DrawTexture(tex, screenWidth/2 - tex.width/2, screenHeight/2 - tex.height/2, WHITE)

        DrawText("this IS a texture loaded from an image!", 300, 370, 10, GRAY)

    EndDrawing()
    ''----------------------------------------------------------------------------------
loop

'' De-Initialization
''--------------------------------------------------------------------------------------
UnloadTexture(tex)       '' Texture unloading

CloseWindow()                '' Close window and OpenGL context
''--------------------------------------------------------------------------------------