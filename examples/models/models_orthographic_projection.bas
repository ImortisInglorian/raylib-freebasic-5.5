/'******************************************************************************************
*
*   raylib [models] example - Show the difference between perspective and orthographic projection
*
*   Example originally created with raylib 2.0, last time updated with raylib 3.7
*
*   Example contributed by Max Danielsson (@autious) and reviewed by Ramon Santamaria (@raysan5)
*
*   Example licensed under an unmodified zlib/libpng license, which is an OSI-certified,
*   BSD-like license that allows static linking with closed source software
*
*   Copyright (c) 2018-2024 Max Danielsson (@autious) and Ramon Santamaria (@raysan5)
*
*******************************************************************************************'/

#include "../../raylib.bi"

#define FOVY_PERSPECTIVE    45.0f
#define WIDTH_ORTHOGRAPHIC  10.0f

'' Initialization
''--------------------------------------------------------------------------------------
const as long screenWidth = 800
const as long screenHeight = 450

InitWindow(screenWidth, screenHeight, "raylib [models] example - geometric shapes")

'' Define the camera to look into our 3d world
dim as Camera cam = Camera(Vector3(0.0f, 10.0f, 10.0f), Vector3(0.0f, 0.0f, 0.0f), Vector3(0.0f, 1.0f, 0.0f), FOVY_PERSPECTIVE, CAMERA_PERSPECTIVE)

SetTargetFPS(60)               '' Set our game to run at 60 frames-per-second
''--------------------------------------------------------------------------------------

'' Main game loop
do while not WindowShouldClose()    '' Detect window close button or ESC key
    '' Update
    ''----------------------------------------------------------------------------------
    if IsKeyPressed(KEY_SPACE) then
        if cam.projection = CAMERA_PERSPECTIVE then
            cam.fovy = WIDTH_ORTHOGRAPHIC
            cam.projection = CAMERA_ORTHOGRAPHIC
        else
            cam.fovy = FOVY_PERSPECTIVE
            cam.projection = CAMERA_PERSPECTIVE
        end if
    end if
    ''----------------------------------------------------------------------------------

    '' Draw
    ''----------------------------------------------------------------------------------
    BeginDrawing()

        ClearBackground(RAYWHITE)

        BeginMode3D(cam)

            DrawCube(Vector3(-4.0f, 0.0f, 2.0f), 2.0f, 5.0f, 2.0f, RED)
            DrawCubeWires(Vector3(-4.0f, 0.0f, 2.0f), 2.0f, 5.0f, 2.0f, GOLD)
            DrawCubeWires(Vector3(-4.0f, 0.0f, -2.0f), 3.0f, 6.0f, 2.0f, MAROON)

            DrawSphere(Vector3(-1.0f, 0.0f, -2.0f), 1.0f, GREEN)
            DrawSphereWires(Vector3(1.0f, 0.0f, 2.0f), 2.0f, 16, 16, LIME)

            DrawCylinder(Vector3(4.0f, 0.0f, -2.0f), 1.0f, 2.0f, 3.0f, 4, SKYBLUE)
            DrawCylinderWires(Vector3(4.0f, 0.0f, -2.0f), 1.0f, 2.0f, 3.0f, 4, DARKBLUE)
            DrawCylinderWires(Vector3(4.5f, -1.0f, 2.0f), 1.0f, 1.0f, 2.0f, 6, BROWN)

            DrawCylinder(Vector3(1.0f, 0.0f, -4.0f), 0.0f, 1.5f, 3.0f, 8, GOLD)
            DrawCylinderWires(Vector3(1.0f, 0.0f, -4.0f), 0.0f, 1.5f, 3.0f, 8, PINK)

            DrawGrid(10, 1.0f)        '' Draw a grid

        EndMode3D()

        DrawText("Press Spacebar to switch camera type", 10, GetScreenHeight() - 30, 20, DARKGRAY)

        if cam.projection = CAMERA_ORTHOGRAPHIC then
            DrawText("ORTHOGRAPHIC", 10, 40, 20, BLACK)
        elseif cam.projection = CAMERA_PERSPECTIVE then
            DrawText("PERSPECTIVE", 10, 40, 20, BLACK)
        end if

        DrawFPS(10, 10)

    EndDrawing()
    ''----------------------------------------------------------------------------------
loop

'' De-Initialization
''--------------------------------------------------------------------------------------
CloseWindow()        '' Close window and OpenGL context
''--------------------------------------------------------------------------------------