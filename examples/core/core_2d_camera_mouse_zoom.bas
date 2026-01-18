/'******************************************************************************************
*
*   raylib [core] example - 2d camera mouse zoom
*
*   Example originally created with raylib 4.2, last time updated with raylib 4.2
*
*   Example licensed under an unmodified zlib/libpng license, which is an OSI-certified,
*   BSD-like license that allows static linking with closed source software
*
*   Copyright (c) 2022-2024 Jeffery Myers (@JeffM2501)
*
*******************************************************************************************'/

#include "../../raylib.bi"
#include "../../rlgl.bi"

'' Initialization
''--------------------------------------------------------------------------------------
const as long screenWidth = 800
const as long screenHeight = 450

InitWindow(screenWidth, screenHeight, "raylib [core] example - 2d camera mouse zoom")

dim as Camera2D cam
cam.zoom = 1.0f

dim as long zoomMode = 0   '' 0-Mouse Wheel, 1-Mouse Move

SetTargetFPS(60)                   '' Set our game to run at 60 frames-per-second
''--------------------------------------------------------------------------------------

'' Main game loop
do while not WindowShouldClose()        '' Detect window close button or ESC key
    '' Update
    ''----------------------------------------------------------------------------------
    if IsKeyPressed(KEY_ONE) then 
        zoomMode = 0
    elseif IsKeyPressed(KEY_TWO) then 
        zoomMode = 1
    end if
    
    '' Translate based on mouse right click
    if IsMouseButtonDown(MOUSE_BUTTON_LEFT) then
        dim as Vector2 delta = GetMouseDelta()
        delta = Vector2Scale(delta, -1.0f/cam.zoom)
        cam.target = Vector2Add(cam.target, delta)
    end if

    if zoomMode = 0 then
        '' Zoom based on mouse wheel
        dim as single wheel = GetMouseWheelMove()
        if wheel <> 0 then
            '' Get the world point that is under the mouse
            dim as Vector2 mouseWorldPos = GetScreenToWorld2D(GetMousePosition(), cam)

            '' Set the offset to where the mouse is
            cam.offset = GetMousePosition()

            '' Set the target to match, so that the camera maps the world space point 
            '' under the cursor to the screen space point under the cursor at any zoom
            cam.target = mouseWorldPos

            '' Zoom increment
            dim as single scaleFactor = 1.0f + (0.25f * fabsf(wheel))
            if wheel < 0 then scaleFactor = 1.0f / scaleFactor
            cam.zoom = Clamp(cam.zoom * scaleFactor, 0.125f, 64.0f)
        end if
    else
        '' Zoom based on mouse right click
        if IsMouseButtonPressed(MOUSE_BUTTON_RIGHT) then
            '' Get the world point that is under the mouse
            dim as Vector2 mouseWorldPos = GetScreenToWorld2D(GetMousePosition(), cam)

            '' Set the offset to where the mouse is
            cam.offset = GetMousePosition()

            '' Set the target to match, so that the camera maps the world space point 
            '' under the cursor to the screen space point under the cursor at any zoom
            cam.target = mouseWorldPos
        end if
        if IsMouseButtonDown(MOUSE_BUTTON_RIGHT) then
            '' Zoom increment
            dim as single deltaX = GetMouseDelta().x
            dim as single scaleFactor = 1.0f + (0.01f * fabsf(deltaX))
            if (deltaX < 0) then scaleFactor = 1.0f / scaleFactor
            cam.zoom = Clamp(cam.zoom * scaleFactor, 0.125f, 64.0f)
        end if
    end if
    ''----------------------------------------------------------------------------------

    '' Draw
    ''----------------------------------------------------------------------------------
    BeginDrawing()
        ClearBackground(RAYWHITE)

        BeginMode2D(cam)

            '' Draw the 3d grid, rotated 90 degrees and centered around 0,0 
            '' just so we have something in the XY plane
            rlPushMatrix()
                rlTranslatef(0, 25 * 50, 0)
                rlRotatef(90, 1, 0, 0)
                DrawGrid(100, 50)
            rlPopMatrix()

            '' Draw a reference circle
            DrawCircle(GetScreenWidth()/2, GetScreenHeight()/2, 50, MAROON)
            
        EndMode2D()
        
        '' Draw mouse reference
        DrawCircleV(GetMousePosition(), 4, DARKGRAY)
        DrawTextEx(GetFontDefault(), TextFormat("[%i, %i]", GetMouseX(), GetMouseY()), _
            Vector2Add(GetMousePosition(), Vector2(-44, -24)), 20, 2, BLACK)

        DrawText("[1][2] Select mouse zoom mode (Wheel or Move)", 20, 20, 20, DARKGRAY)
        if zoomMode = 0 then
            DrawText("Mouse left button drag to move, mouse wheel to zoom", 20, 50, 20, DARKGRAY)
        else 
            DrawText("Mouse left button drag to move, mouse press and move to zoom", 20, 50, 20, DARKGRAY)
        end if
    
    EndDrawing()
    ''----------------------------------------------------------------------------------
loop

'' De-Initialization
''--------------------------------------------------------------------------------------
CloseWindow()        '' Close window and OpenGL context
''--------------------------------------------------------------------------------------