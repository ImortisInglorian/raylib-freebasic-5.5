/'******************************************************************************************
*
*   raylib [core] example - World to screen
*
*   Example originally created with raylib 1.3, last time updated with raylib 1.4
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

InitWindow(screenWidth, screenHeight, "raylib [core] example - core world screen")

'' Define the camera to look into our 3d world
dim as Camera cam
with cam
    .position = Vector3(10.0f, 10.0f, 10.0f) '' Camera position
    .target = Vector3(0.0f, 0.0f, 0.0f)      '' Camera looking at point
    .up = Vector3(0.0f, 1.0f, 0.0f)          '' Camera up vector (rotation towards target)
    .fovy = 45.0f                            '' Camera field-of-view Y
    .projection = CAMERA_PERSPECTIVE         '' Camera projection type
end with

dim as Vector3 cubePosition = Vector3(0.0f, 0.0f, 0.0f)
dim as Vector2 cubeScreenPosition = Vector2(0.0f, 0.0f)

DisableCursor()                    '' Limit cursor to relative movement inside the window

SetTargetFPS(60)                   '' Set our game to run at 60 frames-per-second
''--------------------------------------------------------------------------------------

'' Main game loop
do while not WindowShouldClose()        '' Detect window close button or ESC key
    '' Update
    ''----------------------------------------------------------------------------------
    UpdateCamera(@cam, CAMERA_THIRD_PERSON)

    '' Calculate cube screen space position (with a little offset to be in top)
    cubeScreenPosition = GetWorldToScreen(Vector3(cubePosition.x, cubePosition.y + 2.5f, cubePosition.z), camera)
    ''----------------------------------------------------------------------------------

    '' Draw
    ''----------------------------------------------------------------------------------
    BeginDrawing()

        ClearBackground(RAYWHITE)

        BeginMode3D(cam)

            DrawCube(cubePosition, 2.0f, 2.0f, 2.0f, RED)
            DrawCubeWires(cubePosition, 2.0f, 2.0f, 2.0f, MAROON)

            DrawGrid(10, 1.0f)

        EndMode3D()

        DrawText("Enemy: 100 / 100", cubeScreenPosition.x - MeasureText("Enemy: 100/100", 20)/2, cubeScreenPosition.y, 20, BLACK)
        
        DrawText(TextFormat("Cube position in screen space coordinates: [%i, %i]", cubeScreenPosition.x, cubeScreenPosition.y), 10, 10, 20, LIME)
        DrawText("Text 2d should be always on top of the cube", 10, 40, 20, GRAY)

    EndDrawing()
    ''----------------------------------------------------------------------------------
loop

'' De-Initialization
''--------------------------------------------------------------------------------------
CloseWindow()        '' Close window and OpenGL context
''--------------------------------------------------------------------------------------