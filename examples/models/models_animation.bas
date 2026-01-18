/'******************************************************************************************
*
*   raylib [models] example - Load 3d model with animations and play them
*
*   Example originally created with raylib 2.5, last time updated with raylib 3.5
*
*   Example contributed by Culacant (@culacant) and reviewed by Ramon Santamaria (@raysan5)
*
*   Example licensed under an unmodified zlib/libpng license, which is an OSI-certified,
*   BSD-like license that allows static linking with closed source software
*
*   Copyright (c) 2019-2024 Culacant (@culacant) and Ramon Santamaria (@raysan5)
*
********************************************************************************************
*
*   NOTE: To export a model from blender, make sure it is not posed, the vertices need to be 
*         in the same position as they would be in edit mode and the scale of your models is 
*         set to 0. Scaling can be done from the export menu.
*
*******************************************************************************************'/

#include "../../raylib.bi"

'' Initialization
''--------------------------------------------------------------------------------------
const as long screenWidth = 800
const as long screenHeight = 450

InitWindow(screenWidth, screenHeight, "raylib [models] example - model animation")

'' Define the camera to look into our 3d world
dim as Camera cam
with cam
    .position = Vector3(10.0f, 10.0f, 10.0f) '' Camera position
    .target = Vector3(0.0f, 0.0f, 0.0f)      '' Camera looking at point
    .up = Vector3(0.0f, 1.0f, 0.0f)          '' Camera up vector (rotation towards target)
    .fovy = 45.0f                            '' Camera field-of-view Y
    .projection = CAMERA_PERSPECTIVE         '' Camera mode type
end with

dim as Model model = LoadModel("resources/models/iqm/guy.iqm")             '' Load the animated model mesh and basic data
dim as Texture2D texture = LoadTexture("resources/models/iqm/guytex.png")  '' Load model texture and set material
SetMaterialTexture(@model.materials[0], MATERIAL_MAP_DIFFUSE, texture)     '' Set model material map texture

dim as Vector3 position = Vector3(0.0f, 0.0f, 0.0f)            '' Set model position

'' Load animation data
dim as long animsCount = 0
dim as ModelAnimation ptr anims = LoadModelAnimations("resources/models/iqm/guyanim.iqm", @animsCount)
dim as long animFrameCounter = 0

DisableCursor()                    '' Catch cursor
SetTargetFPS(60)                  '' Set our game to run at 60 frames-per-second
''--------------------------------------------------------------------------------------

'' Main game loop
do while not WindowShouldClose()        '' Detect window close button or ESC key
    '' Update
    ''----------------------------------------------------------------------------------
    UpdateCamera(@camera, CAMERA_FIRST_PERSON)

    '' Play animation when spacebar is held down
    if IsKeyDown(KEY_SPACE) then
        animFrameCounter += 1
        UpdateModelAnimation(model, anims[0], animFrameCounter)
        if animFrameCounter >= anims[0].frameCount then animFrameCounter = 0
    end if
    ''----------------------------------------------------------------------------------

    '' Draw
    ''----------------------------------------------------------------------------------
    BeginDrawing()

        ClearBackground(RAYWHITE)

        BeginMode3D(cam)

            DrawModelEx(model, position, Vector3(1.0f, 0.0f, 0.0f), -90.0f, Vector3(1.0f, 1.0f, 1.0f), WHITE)

            for i as integer = 0 to model.boneCount
                DrawCube(anims[0].framePoses[animFrameCounter][i].translation, 0.2f, 0.2f, 0.2f, RED)
            next

            DrawGrid(10, 1.0f)         '' Draw a grid

        EndMode3D()

        DrawText("PRESS SPACE to PLAY MODEL ANIMATION", 10, 10, 20, MAROON)
        DrawText("(c) Guy IQM 3D model by @culacant", screenWidth - 200, screenHeight - 20, 10, GRAY)

    EndDrawing()
    ''----------------------------------------------------------------------------------
loop

'' De-Initialization
''--------------------------------------------------------------------------------------
UnloadTexture(texture)                     '' Unload texture
UnloadModelAnimations(anims, animsCount)   '' Unload model animations data
UnloadModel(model)                         '' Unload model

CloseWindow()                  '' Close window and OpenGL context
''--------------------------------------------------------------------------------------