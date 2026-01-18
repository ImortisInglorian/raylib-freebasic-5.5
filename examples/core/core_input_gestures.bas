/'******************************************************************************************
*
*   raylib [core] example - Input Gestures Detection
*
*   Example originally created with raylib 1.4, last time updated with raylib 4.2
*
*   Example licensed under an unmodified zlib/libpng license, which is an OSI-certified,
*   BSD-like license that allows static linking with closed source software
*
*   Copyright (c) 2016-2024 Ramon Santamaria (@raysan5)
*
*******************************************************************************************'/

#include "../../raylib.bi"

#define MAX_GESTURE_STRINGS   20

'' Initialization
''--------------------------------------------------------------------------------------
const as long screenWidth = 800
const as long screenHeight = 450

InitWindow(screenWidth, screenHeight, "raylib [core] example - input gestures")

dim as Vector2 touchPosition = Vector2(0, 0)
dim as Rectangle touchArea = Rectangle(220, 10, screenWidth - 230.0f, screenHeight - 20.0f)

dim as long gesturesCount = 0
dim as zstring * MAX_GESTURE_STRINGS gestureStrings(0 to 31)

dim as long currentGesture = GESTURE_NONE
dim as long lastGesture = GESTURE_NONE

''SetGesturesEnabled(0b0000000000001001)   '' Enable only some gestures to be detected

SetTargetFPS(60)               '' Set our game to run at 60 frames-per-second
''--------------------------------------------------------------------------------------

'' Main game loop
do while not WindowShouldClose()    '' Detect window close button or ESC key
    '' Update
    ''----------------------------------------------------------------------------------
    lastGesture = currentGesture
    currentGesture = GetGestureDetected()
    touchPosition = GetTouchPosition(0)

    if CheckCollisionPointRec(touchPosition, touchArea) and (currentGesture <> GESTURE_NONE) then
        if currentGesture <> lastGesture then
            '' Store gesture string
            select case currentGesture
                case GESTURE_TAP
                    TextCopy(gestureStrings(gesturesCount), "GESTURE TAP")
                case GESTURE_DOUBLETAP
                    TextCopy(gestureStrings(gesturesCount), "GESTURE DOUBLETAP")
                case GESTURE_HOLD
                    TextCopy(gestureStrings(gesturesCount), "GESTURE HOLD")
                case GESTURE_DRAG
                    TextCopy(gestureStrings(gesturesCount), "GESTURE DRAG")
                case GESTURE_SWIPE_RIGHT
                    TextCopy(gestureStrings(gesturesCount), "GESTURE SWIPE RIGHT")
                case GESTURE_SWIPE_LEFT
                    TextCopy(gestureStrings(gesturesCount), "GESTURE SWIPE LEFT")
                case GESTURE_SWIPE_UP
                    TextCopy(gestureStrings(gesturesCount), "GESTURE SWIPE UP")
                case GESTURE_SWIPE_DOWN
                    TextCopy(gestureStrings(gesturesCount), "GESTURE SWIPE DOWN")
                case GESTURE_PINCH_IN
                    TextCopy(gestureStrings(gesturesCount), "GESTURE PINCH IN")
                case GESTURE_PINCH_OUT
                    TextCopy(gestureStrings(gesturesCount), "GESTURE PINCH OUT")
            end select

            gesturesCount += 1

            '' Reset gestures strings
            if gesturesCount >= MAX_GESTURE_STRINGS then
                for i as integer = 0 to MAX_GESTURE_STRINGS - 1 
                    TextCopy(gestureStrings(i), !"\0")
                next

                gesturesCount = 0
            end if
        end if
    end if
    ''----------------------------------------------------------------------------------

    '' Draw
    ''----------------------------------------------------------------------------------
    BeginDrawing()

        ClearBackground(RAYWHITE)

        DrawRectangleRec(touchArea, GRAY)
        DrawRectangle(225, 15, screenWidth - 240, screenHeight - 30, RAYWHITE)

        DrawText("GESTURES TEST AREA", screenWidth - 270, screenHeight - 40, 20, Fade(GRAY, 0.5f))

        for i as integer = 0 to gesturesCount - 1
            if (i mod 2 = 0) then
                DrawRectangle(10, 30 + 20*i, 200, 20, Fade(LIGHTGRAY, 0.5f))
            else 
                DrawRectangle(10, 30 + 20*i, 200, 20, Fade(LIGHTGRAY, 0.3f))
            end if

            if i < gesturesCount - 1 then
                DrawText(gestureStrings(i), 35, 36 + 20*i, 10, DARKGRAY)
            else 
                DrawText(gestureStrings(i), 35, 36 + 20*i, 10, MAROON)
            end if
        next

        DrawRectangleLines(10, 29, 200, screenHeight - 50, GRAY)
        DrawText("DETECTED GESTURES", 50, 15, 10, GRAY)

        if (currentGesture <> GESTURE_NONE) then DrawCircleV(touchPosition, 30, MAROON)

    EndDrawing()
    ''----------------------------------------------------------------------------------
loop

'' De-Initialization
''--------------------------------------------------------------------------------------
CloseWindow()        '' Close window and OpenGL context
''--------------------------------------------------------------------------------------