/'******************************************************************************************
*
*   raylib [models] example - Draw some basic geometric shapes (cube, sphere, cylinder...)
*
*   Example originally created with raylib 1.0, last time updated with raylib 3.5
*
*   Example licensed under an unmodified zlib/libpng license, which is an OSI-certified,
*   BSD-like license that allows static linking with closed source software
*
*   Copyright (c) 2014-2024 Ramon Santamaria (@raysan5)
*
*******************************************************************************************'/

#include "../../raylib.bi"

'' Initialization
''--------------------------------------------------------------------------------------
const as long screenWidth = 800
const as long screenHeight = 450

InitWindow(screenWidth, screenHeight, "raylib [models] example - geometric shapes")

'' Define the camera to look into our 3d world
dim as Camera cam
with cam
    .position = Vector3(0.0f, 10.0f, 10.0f)
    .target = Vector3(0.0f, 0.0f, 0.0f)
    .up = Vector3(0.0f, 1.0f, 0.0f)
    .fovy = 45.0f
    .projection = CAMERA_PERSPECTIVE
end with

SetTargetFPS(60)               '' Set our game to run at 60 frames-per-second
''--------------------------------------------------------------------------------------

'' Main game loop
do while not WindowShouldClose()    '' Detect window close button or ESC key
    '' Update
    ''----------------------------------------------------------------------------------
    '' TODO: Update your variables here
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

            DrawCapsule     (Vector3(-3.0f, 1.5f, -4.0f), Vector3(-4.0f, -1.0f, -4.0f), 1.2f, 8, 8, VIOLET)
            DrawCapsuleWires(Vector3(-3.0f, 1.5f, -4.0f), Vector3(-4.0f, -1.0f, -4.0f), 1.2f, 8, 8, PURPLE)

            DrawGrid(10, 1.0f)        '' Draw a grid

        EndMode3D()

        DrawFPS(10, 10)

    EndDrawing()
    ''----------------------------------------------------------------------------------
loop

'' De-Initialization
''--------------------------------------------------------------------------------------
CloseWindow()        '' Close window and OpenGL context
''--------------------------------------------------------------------------------------