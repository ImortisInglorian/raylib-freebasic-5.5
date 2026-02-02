/'******************************************************************************************
*
*   raylib [textures] example - sprite explosion
*
*   Example originally created with raylib 2.5, last time updated with raylib 3.5
*
*   Example licensed under an unmodified zlib/libpng license, which is an OSI-certified,
*   BSD-like license that allows static linking with closed source software
*
*   Copyright (c) 2019-2024 Anata and Ramon Santamaria (@raysan5)
*
*******************************************************************************************'/

#include "../../raylib.bi"

#define NUM_FRAMES_PER_LINE     5
#define NUM_LINES               5

'' Initialization
''--------------------------------------------------------------------------------------
const as long screenWidth = 800
const as long screenHeight = 450

InitWindow(screenWidth, screenHeight, "raylib [textures] example - sprite explosion")

InitAudioDevice()

'' Load explosion sound
dim as Sound fxBoom = LoadSound("resources/boom.wav")

'' Load explosion texture
dim as Texture2D explosion = LoadTexture("resources/explosion.png")

'' Init variables for animation
dim as single frameWidth = (explosion.width/NUM_FRAMES_PER_LINE)   '' Sprite one frame rectangle width
dim as single frameHeight = (explosion.height/NUM_LINES)           '' Sprite one frame rectangle height
dim as long currentFrame = 0
dim as long currentLine = 0

dim as Rectangle frameRec = Rectangle(0, 0, frameWidth, frameHeight)
dim as Vector2 position

dim as boolean active = false
dim as long framesCounter = 0

SetTargetFPS(60)               '' Set our game to run at 60 frames-per-second
''---------------------------------------------------------------------------------------

'' Main game loop
do while not WindowShouldClose()    '' Detect window close button or ESC key
    '' Update
    ''----------------------------------------------------------------------------------

    '' Check for mouse button pressed and activate explosion (if not active)
    if IsMouseButtonPressed(MOUSE_BUTTON_LEFT) and not active then
        position = GetMousePosition()
        active = true

        position.x -= frameWidth/2.0f
        position.y -= frameHeight/2.0f

        PlaySound(fxBoom)
    end if

    '' Compute explosion animation frames
    if active then
        framesCounter += 1

        if framesCounter > 2 then
            currentFrame += 1

            if currentFrame >= NUM_FRAMES_PER_LINE then
                currentFrame = 0
                currentLine += 1

                if currentLine >= NUM_LINES then
                    currentLine = 0
                    active = false
                end if
            end if

            framesCounter = 0
        end if
    end if

    frameRec.x = frameWidth*currentFrame
    frameRec.y = frameHeight*currentLine
    ''----------------------------------------------------------------------------------

    '' Draw
    ''----------------------------------------------------------------------------------
    BeginDrawing()

        ClearBackground(RAYWHITE)

        '' Draw explosion required frame rectangle
        if active then DrawTextureRec(explosion, frameRec, position, WHITE)

    EndDrawing()
    ''----------------------------------------------------------------------------------
loop

'' De-Initialization
''--------------------------------------------------------------------------------------
UnloadTexture(explosion)   '' Unload texture
UnloadSound(fxBoom)        '' Unload sound

CloseAudioDevice()

CloseWindow()              '' Close window and OpenGL context
''--------------------------------------------------------------------------------------