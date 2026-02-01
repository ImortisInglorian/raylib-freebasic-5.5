/'******************************************************************************************
*
*   raylib [textures] example - Image Rotation
*
*   Example originally created with raylib 1.0, last time updated with raylib 1.0
*
*   Example licensed under an unmodified zlib/libpng license, which is an OSI-certified,
*   BSD-like license that allows static linking with closed source software
*
*   Copyright (c) 2014-2024 Ramon Santamaria (@raysan5)
*
*******************************************************************************************'/

#include "../../raylib.bi"

#define NUM_TEXTURES  3

'' Initialization
''--------------------------------------------------------------------------------------
const as long screenWidth = 800
const as long screenHeight = 450

InitWindow(screenWidth, screenHeight, "raylib [textures] example - texture rotation")

'' NOTE: Textures MUST be loaded after Window initialization (OpenGL context is required)
dim as Image image45 = LoadImage("resources/raylib_logo.png")
dim as Image image90 = LoadImage("resources/raylib_logo.png")
dim as Image imageNeg90 = LoadImage("resources/raylib_logo.png")

ImageRotate(@image45, 45)
ImageRotate(@image90, 90)
ImageRotate(@imageNeg90, -90)

dim as Texture2D textures(NUM_TEXTURES - 1)

textures(0) = LoadTextureFromImage(image45)
textures(1) = LoadTextureFromImage(image90)
textures(2) = LoadTextureFromImage(imageNeg90)

dim as long currentTexture = 0

SetTargetFPS(60)               '' Set our game to run at 60 frames-per-second
''---------------------------------------------------------------------------------------

'' Main game loop
do while not WindowShouldClose()    '' Detect window close button or ESC key
    '' Update
    ''----------------------------------------------------------------------------------
    if IsMouseButtonPressed(MOUSE_BUTTON_LEFT) or IsKeyPressed(KEY_RIGHT) then
        currentTexture = (currentTexture + 1) mod NUM_TEXTURES '' Cycle between the textures
    end if
    ''----------------------------------------------------------------------------------

    '' Draw
    ''----------------------------------------------------------------------------------
    BeginDrawing()

        ClearBackground(RAYWHITE)

        DrawTexture(textures(currentTexture), screenWidth/2 - textures(currentTexture).width/2, screenHeight/2 - textures(currentTexture).height/2, WHITE)

        DrawText("Press LEFT MOUSE BUTTON to rotate the image clockwise", 250, 420, 10, DARKGRAY)

    EndDrawing()
    ''----------------------------------------------------------------------------------
loop

'' De-Initialization
''--------------------------------------------------------------------------------------
for i as integer = 0 to NUM_TEXTURES - 1
    UnloadTexture(textures(i))
next

CloseWindow()                '' Close window and OpenGL context
''--------------------------------------------------------------------------------------