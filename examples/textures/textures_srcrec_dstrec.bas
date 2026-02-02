/'******************************************************************************************
*
*   raylib [textures] example - Texture source and destination rectangles
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

InitWindow(screenWidth, screenHeight, "raylib [textures] examples - texture source and destination rectangles")

'' NOTE: Textures MUST be loaded after Window initialization (OpenGL context is required)

dim as Texture2D scarfy = LoadTexture("resources/scarfy.png")        '' Texture loading

dim as long frameWidth = scarfy.width/6
dim as long frameHeight = scarfy.height

'' Source rectangle (part of the texture to use for drawing)
dim as Rectangle sourceRec = Rectangle(0.0f, 0.0f, frameWidth, frameHeight)

'' Destination rectangle (screen rectangle where drawing part of texture)
dim as Rectangle destRec = Rectangle(screenWidth/2.0f, screenHeight/2.0f, frameWidth*2.0f, frameHeight*2.0f)

'' Origin of the texture (rotation/scale point), it's relative to destination rectangle size
dim as Vector2 origin = Vector2(frameWidth, frameHeight)

dim as long rotation = 0

SetTargetFPS(60)
''--------------------------------------------------------------------------------------

'' Main game loop
do while not WindowShouldClose()    '' Detect window close button or ESC key
    '' Update
    ''----------------------------------------------------------------------------------
    rotation += 1
    ''----------------------------------------------------------------------------------

    '' Draw
    ''----------------------------------------------------------------------------------
    BeginDrawing()

        ClearBackground(RAYWHITE)

        '' NOTE: Using DrawTexturePro() we can easily rotate and scale the part of the texture we draw
        '' sourceRec defines the part of the texture we use for drawing
        '' destRec defines the rectangle where our texture part will fit (scaling it to fit)
        '' origin defines the point of the texture used as reference for rotation and scaling
        '' rotation defines the texture rotation (using origin as rotation point)
        DrawTexturePro(scarfy, sourceRec, destRec, origin, rotation, WHITE)

        DrawLine(destRec.x, 0, destRec.x, screenHeight, GRAY)
        DrawLine(0, destRec.y, screenWidth, destRec.y, GRAY)

        DrawText("(c) Scarfy sprite by Eiden Marsal", screenWidth - 200, screenHeight - 20, 10, GRAY)

    EndDrawing()
    ''----------------------------------------------------------------------------------
loop

'' De-Initialization
''--------------------------------------------------------------------------------------
UnloadTexture(scarfy)        '' Texture unloading

CloseWindow()                '' Close window and OpenGL context
''--------------------------------------------------------------------------------------