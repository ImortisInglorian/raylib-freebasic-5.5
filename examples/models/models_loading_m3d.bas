/'******************************************************************************************
*
*   raylib [models] example - Load models M3D
*
*   Example originally created with raylib 4.5, last time updated with raylib 4.5
*
*   Example contributed by bzt (@bztsrc) and reviewed by Ramon Santamaria (@raysan5)
*
*   NOTES:
*     - Model3D (M3D) fileformat specs: https:''gitlab.com/bztsrc/model3d
*     - Bender M3D exported: https:''gitlab.com/bztsrc/model3d/-/tree/master/blender
*
*   Example licensed under an unmodified zlib/libpng license, which is an OSI-certified,
*   BSD-like license that allows static linking with closed source software
*
*   Copyright (c) 2022-2024 bzt (@bztsrc)
*
*******************************************************************************************'/

#include "../../raylib.bi"

'' Initialization
''--------------------------------------------------------------------------------------
const as long screenWidth = 800
const as long screenHeight = 450

InitWindow(screenWidth, screenHeight, "raylib [models] example - M3D model loading")

'' Define the camera to look into our 3d world
dim as Camera cam
with cam
    .position = Vector3(1.5f, 1.5f, 1.5f)    '' Camera position
    .target = Vector3(0.0f, 0.4f, 0.0f)      '' Camera looking at point
    .up = Vector3(0.0f, 1.0f, 0.0f)          '' Camera up vector (rotation towards target)
    .fovy = 45.0f                            '' Camera field-of-view Y
    .projection = CAMERA_PERSPECTIVE         '' Camera projection type
end with

dim as Vector3 position = Vector3(0.0f, 0.0f, 0.0f)            '' Set model position

dim as zstring * 128 modelFileName = "resources/models/m3d/cesium_man.m3d"
dim as boolean drawMsh = true
dim as boolean drawSkeleton = true
dim as boolean animPlaying = false   '' Store anim state, what to draw

'' Load model
dim as Model mdl = LoadModel(modelFileName) '' Load the bind-pose model mesh and basic data

'' Load animations
dim as long animsCount = 0
dim as long animFrameCounter = 0, animId = 0
dim as ModelAnimation ptr anims = LoadModelAnimations(modelFileName, @animsCount) '' Load skeletal animation data

DisableCursor()                    '' Limit cursor to relative movement inside the window

SetTargetFPS(60)                   '' Set our game to run at 60 frames-per-second
''--------------------------------------------------------------------------------------

'' Main game loop
do while not WindowShouldClose()        '' Detect window close button or ESC key
    '' Update
    ''----------------------------------------------------------------------------------
    UpdateCamera(@cam, CAMERA_FIRST_PERSON)

    if animsCount > 0 then
        '' Play animation when spacebar is held down (or step one frame with N)
        if IsKeyDown(KEY_SPACE) or IsKeyPressed(KEY_N) then
            animFrameCounter += 1

            if (animFrameCounter >= anims[animId].frameCount) then animFrameCounter = 0

            UpdateModelAnimation(mdl, anims[animId], animFrameCounter)
            animPlaying = true
        end if

        '' Select animation by pressing C
        if IsKeyPressed(KEY_C) then
            animFrameCounter = 0
            animId += 1

            if animId >= animsCount then animId = 0
            UpdateModelAnimation(mdl, anims[animId], 0)
            animPlaying = true
        end if
    end if

    '' Toggle skeleton drawing
    if IsKeyPressed(KEY_B) then drawSkeleton = not drawSkeleton

    '' Toggle mesh drawing
    if IsKeyPressed(KEY_M) then drawMsh = not drawMsh
    ''----------------------------------------------------------------------------------

    '' Draw
    ''----------------------------------------------------------------------------------
    BeginDrawing()

        ClearBackground(RAYWHITE)

        BeginMode3D(cam)

            '' Draw 3d model with texture
            if drawMsh then DrawModel(mdl, position, 1.0f, WHITE)

            '' Draw the animated skeleton
            if drawSkeleton then
                '' Loop to (boneCount - 1) because the last one is a special "no bone" bone,
                '' needed to workaround buggy models
                '' without a -1, we would always draw a cube at the origin
                for i as integer = 0 to model.boneCount - 1
                    '' By default the model is loaded in bind-pose by LoadModel().
                    '' But if UpdateModelAnimation() has been called at least once
                    '' then the model is already in animation pose, so we need the animated skeleton
                    if not animPlaying or (animsCount <= 0) then

                        '' Display the bind-pose skeleton
                        DrawCube(mdl.bindPose[i].translation, 0.04f, 0.04f, 0.04f, RED)

                        if mdl.bones[i].parent >= 0 then
                            DrawLine3D(mdl.bindPose[i].translation, _
                                mdl.bindPose[mdl.bones[i].parent].translation, RED)
                        end if
                    else
                        '' Display the frame-pose skeleton
                        DrawCube(anims[animId].framePoses[animFrameCounter][i].translation, 0.05f, 0.05f, 0.05f, RED)

                        if anims[animId].bones[i].parent >= 0 then
                            DrawLine3D(anims[animId].framePoses[animFrameCounter][i].translation, _
                                anims[animId].framePoses[animFrameCounter][anims[animId].bones[i].parent].translation, RED)
                        end if
                    end if
                next
            end if

            DrawGrid(10, 1.0f)         '' Draw a grid

        EndMode3D()

        DrawText("PRESS SPACE to PLAY MODEL ANIMATION", 10, GetScreenHeight() - 80, 10, MAROON)
        DrawText("PRESS N to STEP ONE ANIMATION FRAME", 10, GetScreenHeight() - 60, 10, DARKGRAY)
        DrawText("PRESS C to CYCLE THROUGH ANIMATIONS", 10, GetScreenHeight() - 40, 10, DARKGRAY)
        DrawText("PRESS M to toggle MESH, B to toggle SKELETON DRAWING", 10, GetScreenHeight() - 20, 10, DARKGRAY)
        DrawText("(c) CesiumMan model by KhronosGroup", GetScreenWidth() - 210, GetScreenHeight() - 20, 10, GRAY)

    EndDrawing()
    ''----------------------------------------------------------------------------------
loop

'' De-Initialization
''--------------------------------------------------------------------------------------

'' Unload model animations data
UnloadModelAnimations(anims, animsCount)

UnloadModel(mdl)         '' Unload model

CloseWindow()              '' Close window and OpenGL context
''--------------------------------------------------------------------------------------