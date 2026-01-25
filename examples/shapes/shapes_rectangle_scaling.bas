/'******************************************************************************************
*
*   raylib [shapes] example - rectangle scaling by mouse
*
*   Example originally created with raylib 2.5, last time updated with raylib 2.5
*
*   Example contributed by Vlad Adrian (@demizdor) and reviewed by Ramon Santamaria (@raysan5)
*
*   Example licensed under an unmodified zlib/libpng license, which is an OSI-certified,
*   BSD-like license that allows static linking with closed source software
*
*   Copyright (c) 2018-2024 Vlad Adrian (@demizdor) and Ramon Santamaria (@raysan5)
*
*******************************************************************************************'/

#include "../../raylib.bi"

#define MOUSE_SCALE_MARK_SIZE   12

'' Initialization
''--------------------------------------------------------------------------------------
const as long screenWidth = 800
const as long screenHeight = 450

InitWindow(screenWidth, screenHeight, "raylib [shapes] example - rectangle scaling mouse")

dim as Rectangle rec = Rectangle(100, 100, 200, 80)

dim as Vector2 mousePosition

dim as boolean mouseScaleReady = false
dim as boolean mouseScaleMode = false

SetTargetFPS(60)               '' Set our game to run at 60 frames-per-second
''--------------------------------------------------------------------------------------

'' Main game loop
do while not WindowShouldClose()    '' Detect window close button or ESC key
    '' Update
    ''----------------------------------------------------------------------------------
    mousePosition = GetMousePosition()

    if CheckCollisionPointRec(mousePosition, Rectangle(rec.x + rec.width - MOUSE_SCALE_MARK_SIZE, rec.y + rec.height - MOUSE_SCALE_MARK_SIZE, MOUSE_SCALE_MARK_SIZE, MOUSE_SCALE_MARK_SIZE)) then
        mouseScaleReady = true
        if IsMouseButtonPressed(MOUSE_BUTTON_LEFT) then mouseScaleMode = true
    else 
        mouseScaleReady = false
    end if

    if mouseScaleMode then
        mouseScaleReady = true

        rec.width = (mousePosition.x - rec.x)
        rec.height = (mousePosition.y - rec.y)

        '' Check minimum rec size
        if rec.width < MOUSE_SCALE_MARK_SIZE then rec.width = MOUSE_SCALE_MARK_SIZE
        if rec.height < MOUSE_SCALE_MARK_SIZE then rec.height = MOUSE_SCALE_MARK_SIZE
        
        '' Check maximum rec size
        if rec.width > (GetScreenWidth() - rec.x) then rec.width = GetScreenWidth() - rec.x
        if rec.height > (GetScreenHeight() - rec.y) then rec.height = GetScreenHeight() - rec.y

        if IsMouseButtonReleased(MOUSE_BUTTON_LEFT) then mouseScaleMode = false
    end if
    ''----------------------------------------------------------------------------------

    '' Draw
    ''----------------------------------------------------------------------------------
    BeginDrawing()

        ClearBackground(RAYWHITE)

        DrawText("Scale rectangle dragging from bottom-right corner!", 10, 10, 20, GRAY)

        DrawRectangleRec(rec, Fade(GREEN, 0.5f))

        if mouseScaleReady then
            DrawRectangleLinesEx(rec, 1, RED)
            DrawTriangle(Vector2(rec.x + rec.width - MOUSE_SCALE_MARK_SIZE, rec.y + rec.height), _
                            Vector2(rec.x + rec.width, rec.y + rec.height), _
                            Vector2(rec.x + rec.width, rec.y + rec.height - MOUSE_SCALE_MARK_SIZE), RED)
        end if

    EndDrawing()
    ''----------------------------------------------------------------------------------
loop

'' De-Initialization
''--------------------------------------------------------------------------------------
CloseWindow()        '' Close window and OpenGL context
''--------------------------------------------------------------------------------------