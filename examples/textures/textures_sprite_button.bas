/'******************************************************************************************
*
*   raylib [textures] example - sprite button
*
*   Example originally created with raylib 2.5, last time updated with raylib 2.5
*
*   Example licensed under an unmodified zlib/libpng license, which is an OSI-certified,
*   BSD-like license that allows static linking with closed source software
*
*   Copyright (c) 2019-2024 Ramon Santamaria (@raysan5)
*
*******************************************************************************************'/

#include "../../raylib.bi"

#define NUM_FRAMES  3       '' Number of frames (rectangles) for the button sprite texture

'' Initialization
''--------------------------------------------------------------------------------------
const as long screenWidth = 800
const as long screenHeight = 450

InitWindow(screenWidth, screenHeight, "raylib [textures] example - sprite button")

InitAudioDevice()      '' Initialize audio device

dim as Sound fxButton = LoadSound("resources/buttonfx.wav")   '' Load button sound
dim as Texture2D button = LoadTexture("resources/button.png") '' Load button texture

'' Define frame rectangle for drawing
dim as single frameHeight = button.height/NUM_FRAMES
dim as Rectangle sourceRec = Rectangle(0, 0, button.width, frameHeight)

'' Define button bounds on screen
dim as Rectangle btnBounds = Rectangle(screenWidth/2.0f - button.width/2.0f, screenHeight/2.0f - button.height/NUM_FRAMES/2.0f, button.width, frameHeight)

dim as long btnState = 0               '' Button state: 0-NORMAL, 1-MOUSE_HOVER, 2-PRESSED
dim as boolean btnAction = false         '' Button action should be activated

dim as Vector2 mousePoint

SetTargetFPS(60)
''--------------------------------------------------------------------------------------

'' Main game loop
do while not WindowShouldClose()    '' Detect window close button or ESC key
    '' Update
    ''----------------------------------------------------------------------------------
    mousePoint = GetMousePosition()
    btnAction = false

    '' Check button state
    if CheckCollisionPointRec(mousePoint, btnBounds) then
        if IsMouseButtonDown(MOUSE_BUTTON_LEFT) then
            btnState = 2
        else 
            btnState = 1
        end if

        if IsMouseButtonReleased(MOUSE_BUTTON_LEFT) then btnAction = true
    else
        btnState = 0
    end if

    if btnAction then
        PlaySound(fxButton)
    end if

    '' Calculate button frame rectangle to draw depending on button state
    sourceRec.y = btnState*frameHeight
    ''----------------------------------------------------------------------------------

    '' Draw
    ''----------------------------------------------------------------------------------
    BeginDrawing()

        ClearBackground(RAYWHITE)

        DrawTextureRec(button, sourceRec, Vector2(btnBounds.x, btnBounds.y), WHITE) '' Draw button frame

    EndDrawing()
    ''----------------------------------------------------------------------------------
loop

'' De-Initialization
''--------------------------------------------------------------------------------------
UnloadTexture(button)  '' Unload button texture
UnloadSound(fxButton)  '' Unload sound

CloseAudioDevice()     '' Close audio device

CloseWindow()          '' Close window and OpenGL context
''--------------------------------------------------------------------------------------