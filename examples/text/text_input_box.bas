/'******************************************************************************************
*
*   raylib [text] example - Input Box
*
*   Example originally created with raylib 1.7, last time updated with raylib 3.5
*
*   Example licensed under an unmodified zlib/libpng license, which is an OSI-certified,
*   BSD-like license that allows static linking with closed source software
*
*   Copyright (c) 2017-2024 Ramon Santamaria (@raysan5)
*
*******************************************************************************************'/

#include "../../raylib.bi"

#define MAX_INPUT_CHARS     9

'' Initialization
''--------------------------------------------------------------------------------------
const as long screenWidth = 800
const as long screenHeight = 450

InitWindow(screenWidth, screenHeight, "raylib [text] example - input box")

dim as zstring * MAX_INPUT_CHARS + 1 nme = !"\0"      '' NOTE: One extra space required for null terminator char '\0'
dim as long letterCount = 0

dim as Rectangle textBox = Rectangle(screenWidth/2.0f - 100, 180, 225, 50)
dim as boolean mouseOnText = false

dim as long framesCounter = 0

SetTargetFPS(60)               '' Set our game to run at 60 frames-per-second
''--------------------------------------------------------------------------------------

'' Main game loop
do while not WindowShouldClose()    '' Detect window close button or ESC key
    '' Update
    ''----------------------------------------------------------------------------------
    if CheckCollisionPointRec(GetMousePosition(), textBox) then 
        mouseOnText = true
    else 
        mouseOnText = false
    end if

    if mouseOnText then
        '' Set the window's cursor to the I-Beam
        SetMouseCursor(MOUSE_CURSOR_IBEAM)

        '' Get char pressed (unicode character) on the queue
        dim as long key = GetCharPressed()

        '' Check if more characters have been pressed on the same frame
        do while key > 0
            '' NOTE: Only allow keys in range [32..125]
            if (key >= 32) and (key <= 125) and (letterCount < MAX_INPUT_CHARS) then
                nme[letterCount] = key
                nme[letterCount+1] = 0 '' Add null terminator at the end of the string.
                letterCount += 1
            end if

            key = GetCharPressed()  '' Check next character in the queue
        loop

        if IsKeyPressed(KEY_BACKSPACE) then
            letterCount -= 1
            if letterCount < 0 then letterCount = 0
            nme[letterCount] = 0
        end if
    else 
        SetMouseCursor(MOUSE_CURSOR_DEFAULT)
    end if

    if mouseOnText then 
        framesCounter += 1
    else 
        framesCounter = 0
    end if
    ''----------------------------------------------------------------------------------

    '' Draw
    ''----------------------------------------------------------------------------------
    BeginDrawing()

        ClearBackground(RAYWHITE)

        DrawText("PLACE MOUSE OVER INPUT BOX!", 240, 140, 20, GRAY)

        DrawRectangleRec(textBox, LIGHTGRAY)
        if mouseOnText then
            DrawRectangleLines(textBox.x, textBox.y, textBox.width, textBox.height, RED)
        else 
            DrawRectangleLines(textBox.x, textBox.y, textBox.width, textBox.height, DARKGRAY)
        end if

        DrawText(nme, textBox.x + 5, textBox.y + 8, 40, MAROON)

        DrawText(TextFormat("INPUT CHARS: %i/%i", letterCount, MAX_INPUT_CHARS), 315, 250, 20, DARKGRAY)

        if mouseOnText then
            if letterCount < MAX_INPUT_CHARS then
                '' Draw blinking underscore char
                if ((framesCounter / 20) mod 2) = 0 then DrawText("_", textBox.x + 8 + MeasureText(nme, 40), textBox.y + 12, 40, MAROON)
            else 
                DrawText("Press BACKSPACE to delete chars...", 230, 300, 20, GRAY)
            end if
        end if

    EndDrawing()
    ''----------------------------------------------------------------------------------
loop

'' De-Initialization
''--------------------------------------------------------------------------------------
CloseWindow()        '' Close window and OpenGL context
''--------------------------------------------------------------------------------------