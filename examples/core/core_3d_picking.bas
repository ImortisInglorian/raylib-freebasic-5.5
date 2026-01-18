/'******************************************************************************************
*
*   raylib [core] example - Picking in 3d mode
*
*   Example originally created with raylib 1.3, last time updated with raylib 4.0
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

InitWindow(screenWidth, screenHeight, "raylib [core] example - 3d picking")

'' Define the camera to look into our 3d world
dim as Camera cam
with cam
    .position = Vector3(10.0f, 10.0f, 10.0f) '' Camera position
    .target = Vector3(0.0f, 0.0f, 0.0f)      '' Camera looking at point
    .up = Vector3(0.0f, 1.0f, 0.0f)          '' Camera up vector (rotation towards target)
    .fovy = 45.0f                            '' Camera field-of-view Y
    .projection = CAMERA_PERSPECTIVE         '' Camera projection type
end with

dim as Vector3 cubePosition = Vector3(0.0f, 1.0f, 0.0f)
dim as Vector3 cubeSize = Vector3(2.0f, 2.0f, 2.0f)

dim as Ray rayLine                    '' Picking line ray
dim as RayCollision collision         '' Ray collision hit info

SetTargetFPS(60)                   '' Set our game to run at 60 frames-per-second
''--------------------------------------------------------------------------------------

'' Main game loop
do while not WindowShouldClose()        '' Detect window close button or ESC key
    '' Update
    ''----------------------------------------------------------------------------------
    if IsCursorHidden() then UpdateCamera(@cam, CAMERA_FIRST_PERSON)

    '' Toggle camera controls
    if IsMouseButtonPressed(MOUSE_BUTTON_RIGHT) then
        if IsCursorHidden() then
            EnableCursor()
        else 
            DisableCursor()
        end if
    end if

    if IsMouseButtonPressed(MOUSE_BUTTON_LEFT) then
        if collision.hit = RLFALSE then
            rayLine = GetScreenToWorldRay(GetMousePosition(), cam)

            '' Check collision between ray and box
            collision = GetRayCollisionBox(rayLine,_
                        BoundingBox(Vector3(cubePosition.x - cubeSize.x/2, cubePosition.y - cubeSize.y/2, cubePosition.z - cubeSize.z/2),_
                                        Vector3(cubePosition.x + cubeSize.x/2, cubePosition.y + cubeSize.y/2, cubePosition.z + cubeSize.z/2)))
        else 
            collision.hit = RLFALSE
        end if
    end if
    ''----------------------------------------------------------------------------------

    '' Draw
    ''----------------------------------------------------------------------------------
    BeginDrawing()

        ClearBackground(RAYWHITE)

        BeginMode3D(cam)

            if collision.hit = RLTRUE then
                DrawCube(cubePosition, cubeSize.x, cubeSize.y, cubeSize.z, RED)
                DrawCubeWires(cubePosition, cubeSize.x, cubeSize.y, cubeSize.z, MAROON)

                DrawCubeWires(cubePosition, cubeSize.x + 0.2f, cubeSize.y + 0.2f, cubeSize.z + 0.2f, GREEN)
            else
                DrawCube(cubePosition, cubeSize.x, cubeSize.y, cubeSize.z, GRAY)
                DrawCubeWires(cubePosition, cubeSize.x, cubeSize.y, cubeSize.z, DARKGRAY)
            end if

            DrawRay(rayLine, MAROON)
            DrawGrid(10, 1.0f)

        EndMode3D()

        DrawText("Try clicking on the box with your mouse!", 240, 10, 20, DARKGRAY)

        if collision.hit= RLTRUE then DrawText("BOX SELECTED", (screenWidth - MeasureText("BOX SELECTED", 30)) / 2, (screenHeight * 0.1f), 30, GREEN)

        DrawText("Right click mouse to toggle camera controls", 10, 430, 10, GRAY)

        DrawFPS(10, 10)

    EndDrawing()
    ''----------------------------------------------------------------------------------
loop

'' De-Initialization
''--------------------------------------------------------------------------------------
CloseWindow()        '' Close window and OpenGL context
''--------------------------------------------------------------------------------------
