/'******************************************************************************************
*
*   raylib [models] example - loading gltf with animations
*
*   LIMITATIONS:
*     - Only supports 1 armature per file, and skips loading it if there are multiple armatures
*     - Only supports linear interpolation (default method in Blender when checked
*       "Always Sample Animations" when exporting a GLTF file)
*     - Only supports translation/rotation/scale animation channel.path,
*       weights not considered (i.e. morph targets)
*
*   Example originally created with raylib 3.7, last time updated with raylib 4.2
*
*   Example licensed under an unmodified zlib/libpng license, which is an OSI-certified,
*   BSD-like license that allows static linking with closed source software
*
*   Copyright (c) 2020-2024 Ramon Santamaria (@raysan5)
*
*******************************************************************************************'/

#include "../../raylib.bi"

'' Initialization
''--------------------------------------------------------------------------------------
const as long screenWidth = 800
const as long screenHeight = 450

InitWindow(screenWidth, screenHeight, "raylib [models] example - loading gltf animations")

'' Define the camera to look into our 3d world
dim as Camera cam
with cam
    .position = Vector3(6.0f, 6.0f, 6.0f)    '' Camera position
    .target = Vector3(0.0f, 2.0f, 0.0f)      '' Camera looking at point
    .up = Vector3(0.0f, 1.0f, 0.0f)          '' Camera up vector (rotation towards target)
    .fovy = 45.0f                            '' Camera field-of-view Y
    .projection = CAMERA_PERSPECTIVE         '' Camera projection type
end with

'' Load gltf model
dim as Model mdl = LoadModel("resources/models/gltf/robot.glb")
dim as Vector3 position = Vector3(0.0f, 0.0f, 0.0f) '' Set model position

'' Load gltf model animations
dim as long animsCount = 0
dim as ulong animIndex = 0
dim as Ulong animCurrentFrame = 0
dim as ModelAnimation ptr modelAnimations = LoadModelAnimations("resources/models/gltf/robot.glb", @animsCount)

SetTargetFPS(60)                   '' Set our game to run at 60 frames-per-second
''--------------------------------------------------------------------------------------

'' Main game loop
do while not WindowShouldClose()        '' Detect window close button or ESC key
    '' Update
    ''----------------------------------------------------------------------------------
    UpdateCamera(@cam, CAMERA_ORBITAL)

    '' Select current animation
    if IsMouseButtonPressed(MOUSE_BUTTON_RIGHT) then
        animIndex = (animIndex + 1) mod animsCount
    elseif IsMouseButtonPressed(MOUSE_BUTTON_LEFT) then
        animIndex = (animIndex + animsCount - 1) mod animsCount
    end if

    '' Update model animation
    dim as ModelAnimation anim = modelAnimations[animIndex]
    animCurrentFrame = (animCurrentFrame + 1) mod anim.frameCount
    UpdateModelAnimation(mdl, anim, animCurrentFrame)
    ''----------------------------------------------------------------------------------

    '' Draw
    ''----------------------------------------------------------------------------------
    BeginDrawing()

        ClearBackground(RAYWHITE)

        BeginMode3D(cam)
            DrawModel(mdl, position, 1.0f, WHITE)    '' Draw animated model
            DrawGrid(10, 1.0f)
        EndMode3D()

        DrawText("Use the LEFT/RIGHT mouse buttons to switch animation", 10, 10, 20, GRAY)
        DrawText(TextFormat("Animation: %s", anim.name), 10, GetScreenHeight() - 20, 10, DARKGRAY)

    EndDrawing()
    ''----------------------------------------------------------------------------------
loop

'' De-Initialization
''--------------------------------------------------------------------------------------
UnloadModel(mdl)         '' Unload model and meshes/material

CloseWindow()              '' Close window and OpenGL context
''--------------------------------------------------------------------------------------