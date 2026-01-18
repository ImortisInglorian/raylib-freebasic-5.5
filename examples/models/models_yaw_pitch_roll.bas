/'*****************************************************************************************
*
*   raylib [models] example - Plane rotations (yaw, pitch, roll)
*
*   Example originally created with raylib 1.8, last time updated with raylib 4.0
*
*   Example contributed by Berni (@Berni8k) and reviewed by Ramon Santamaria (@raysan5)
*
*   Example licensed under an unmodified zlib/libpng license, which is an OSI-certified,
*   BSD-like license that allows static linking with closed source software
*
*   Copyright (c) 2017-2024 Berni (@Berni8k) and Ramon Santamaria (@raysan5)
*
*******************************************************************************************'/

#include "../../raylib.bi"

'' Initialization
''--------------------------------------------------------------------------------------
const as long screenWidth = 800
const as long screenHeight = 450

''SetConfigFlags(FLAG_MSAA_4X_HINT | FLAG_WINDOW_HIGHDPI)
InitWindow(screenWidth, screenHeight, "raylib [models] example - plane rotations (yaw, pitch, roll)")

dim as Camera cam
with cam
    .position = Vector3(0.0f, 50.0f, -120.0f)'' Camera position perspective
    .target = Vector3(0.0f, 0.0f, 0.0f)      '' Camera looking at point
    .up = Vector3(0.0f, 1.0f, 0.0f)          '' Camera up vector (rotation towards target)
    .fovy = 30.0f                            '' Camera field-of-view Y
    .projection = CAMERA_PERSPECTIVE         '' Camera type
end with

dim as Model mdl = LoadModel("resources/models/obj/plane.obj")                  '' Load model
dim as Texture2D texture = LoadTexture("resources/models/obj/plane_diffuse.png")  '' Load model texture
mdl.materials[0].maps[MATERIAL_MAP_DIFFUSE].texture = texture            '' Set map diffuse texture

dim as single pitch = 0.0f
dim as single roll = 0.0f
dim as single yaw = 0.0f

SetTargetFPS(60)               '' Set our game to run at 60 frames-per-second
''--------------------------------------------------------------------------------------

'' Main game loop
do while not WindowShouldClose()    '' Detect window close button or ESC key
    '' Update
    ''----------------------------------------------------------------------------------
    '' Plane pitch (x-axis) controls
    if IsKeyDown(KEY_DOWN) then
        pitch += 0.6f
    elseif IsKeyDown(KEY_UP) then 
        pitch -= 0.6f
    else
        if pitch > 0.3f then 
            pitch -= 0.3f
        elseif pitch < -0.3f then
            pitch += -0.3f
        end if
    end if

    '' Plane yaw (y-axis) controls
    if IsKeyDown(KEY_S) then 
        yaw -= 1.0f
    elseif IsKeyDown(KEY_A) then
        yaw += 1.0f
    else
        if yaw > 0.0f then 
            yaw -= 0.5f
        elseif yaw < 0.0f then
            yaw += 0.5f
        end if
    end if

    '' Plane roll (z-axis) controls
    if IsKeyDown(KEY_LEFT) then
        roll -= 1.0f
    elseif IsKeyDown(KEY_RIGHT) then
        roll += 1.0f
    else
        if roll > 0.0f then
            roll -= 0.5f
        elseif roll < 0.0f then
            roll += 0.5f
        end if
    end if

    '' Tranformation matrix for rotations
    mdl.transform = MatrixRotateXYZ(Vector3(DEG2RAD*pitch, DEG2RAD*yaw, DEG2RAD*roll))
    ''----------------------------------------------------------------------------------

    '' Draw
    ''----------------------------------------------------------------------------------
    BeginDrawing()

        ClearBackground(RAYWHITE)

        '' Draw 3D model (recomended to draw 3D always before 2D)
        BeginMode3D(cam)

            DrawModel(mdl, Vector3(0.0f, -8.0f, 0.0f), 1.0f, WHITE)   '' Draw 3d model with texture
            DrawGrid(10, 10.0f)

        EndMode3D()

        '' Draw controls info
        DrawRectangle(30, 370, 260, 70, Fade(GREEN, 0.5f))
        DrawRectangleLines(30, 370, 260, 70, Fade(DARKGREEN, 0.5f))
        DrawText("Pitch controlled with: KEY_UP / KEY_DOWN", 40, 380, 10, DARKGRAY)
        DrawText("Roll controlled with: KEY_LEFT / KEY_RIGHT", 40, 400, 10, DARKGRAY)
        DrawText("Yaw controlled with: KEY_A / KEY_S", 40, 420, 10, DARKGRAY)

        DrawText("(c) WWI Plane Model created by GiaHanLam", screenWidth - 240, screenHeight - 20, 10, DARKGRAY)

    EndDrawing()
    ''----------------------------------------------------------------------------------
loop

'' De-Initialization
''--------------------------------------------------------------------------------------
UnloadModel(mdl)     '' Unload model data
UnloadTexture(texture) '' Unload texture data

CloseWindow()          '' Close window and OpenGL context
''--------------------------------------------------------------------------------------