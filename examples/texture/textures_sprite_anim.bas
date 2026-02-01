/'******************************************************************************************
*
*   raylib [textures] example - Sprite animation
*
*   Example originally created with raylib 1.3, last time updated with raylib 1.3
*
*   Example licensed under an unmodified zlib/libpng license, which is an OSI-certified,
*   BSD-like license that allows static linking with closed source software
*
*   Copyright (c) 2014-2024 Ramon Santamaria (@raysan5)
*
*******************************************************************************************'/

#include "../../raylib.bi"

#define MAX_FRAME_SPEED     15
#define MIN_FRAME_SPEED      1

'' Initialization
''--------------------------------------------------------------------------------------
const as long screenWidth = 800
const as long screenHeight = 450

InitWindow(screenWidth, screenHeight, "raylib [texture] example - sprite anim")

'' NOTE: Textures MUST be loaded after Window initialization (OpenGL context is required)
dim as Texture2D scarfy = LoadTexture("resources/scarfy.png")        '' Texture loading

dim as Vector2 position = Vector2(350.0f, 280.0f)
dim as Rectangle frameRec = Rectangle(0.0f, 0.0f, scarfy.width/6, scarfy.height)
dim as long currentFrame = 0

dim as long framesCounter = 0
dim as long framesSpeed = 8            '' Number of spritesheet frames shown by second

SetTargetFPS(60)               '' Set our game to run at 60 frames-per-second
''--------------------------------------------------------------------------------------

'' Main game loop
do while not WindowShouldClose()    '' Detect window close button or ESC key
    '' Update
    ''----------------------------------------------------------------------------------
    framesCounter += 1

    if framesCounter >= (60/framesSpeed) then
        framesCounter = 0
        currentFrame += 1

        if currentFrame > 5 then currentFrame = 0

        frameRec.x = currentFrame*scarfy.width/6
    end if

    '' Control frames speed
    if IsKeyPressed(KEY_RIGHT) then
        framesSpeed += 1
    elseif IsKeyPressed(KEY_LEFT) then
        framesSpeed -= 1
    end if

    if framesSpeed > MAX_FRAME_SPEED then
        framesSpeed = MAX_FRAME_SPEED
    elseif framesSpeed < MIN_FRAME_SPEED then
        framesSpeed = MIN_FRAME_SPEED
    end if
    ''----------------------------------------------------------------------------------

    '' Draw
    ''----------------------------------------------------------------------------------
    BeginDrawing()

        ClearBackground(RAYWHITE)

        DrawTexture(scarfy, 15, 40, WHITE)
        DrawRectangleLines(15, 40, scarfy.width, scarfy.height, LIME)
        DrawRectangleLines(15 + frameRec.x, 40 + frameRec.y, frameRec.width, frameRec.height, RED)

        DrawText("FRAME SPEED: ", 165, 210, 10, DARKGRAY)
        DrawText(TextFormat("%02i FPS", framesSpeed), 575, 210, 10, DARKGRAY)
        DrawText("PRESS RIGHT/LEFT KEYS to CHANGE SPEED!", 290, 240, 10, DARKGRAY)

        for i as integer = 0 to MAX_FRAME_SPEED - 1
            if i < framesSpeed then DrawRectangle(250 + 21*i, 205, 20, 20, RED)
            DrawRectangleLines(250 + 21*i, 205, 20, 20, MAROON)
        next

        DrawTextureRec(scarfy, frameRec, position, WHITE)  '' Draw part of the texture

        DrawText("(c) Scarfy sprite by Eiden Marsal", screenWidth - 200, screenHeight - 20, 10, GRAY)

    EndDrawing()
    ''----------------------------------------------------------------------------------
loop

'' De-Initialization
''--------------------------------------------------------------------------------------
UnloadTexture(scarfy)       '' Texture unloading

CloseWindow()                '' Close window and OpenGL context
''--------------------------------------------------------------------------------------