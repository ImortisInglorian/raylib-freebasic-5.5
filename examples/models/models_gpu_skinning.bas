/'******************************************************************************************
*
*   raylib [core] example - Doing skinning on the gpu using a vertex shader
* 
*   Example originally created with raylib 4.5, last time updated with raylib 4.5
*
*   Example contributed by Daniel Holden (@orangeduck) and reviewed by Ramon Santamaria (@raysan5)
*
*   Example licensed under an unmodified zlib/libpng license, which is an OSI-certified,
*   BSD-like license that allows static linking with closed source software
*
*   Copyright (c) 2024 Daniel Holden (@orangeduck)
* 
*   Note: Due to limitations in the Apple OpenGL driver, this feature does not work on MacOS
*
*******************************************************************************************'/

#include "../../raylib.bi"

#define GLSL_VERSION            330

'' Initialization
''--------------------------------------------------------------------------------------
const as long screenWidth = 800
const as long screenHeight = 450

InitWindow(screenWidth, screenHeight, "raylib [models] example - GPU skinning")

'' Define the camera to look into our 3d world
dim as Camera cam
with cam
    .position = Vector3(5.0f, 5.0f, 5.0f) '' Camera position
    .target = Vector3(0.0f, 2.0f, 0.0f)   '' Camera looking at point
    .up = Vector3(0.0f, 1.0f, 0.0f)       '' Camera up vector (rotation towards target)
    .fovy = 45.0f                         '' Camera field-of-view Y
    .projection = CAMERA_PERSPECTIVE      '' Camera projection type
end with

'' Load gltf model
dim as Model characterModel = LoadModel("resources/models/gltf/greenman.glb") '' Load character model

'' Load skinning shader
dim as Shader skinningShader = LoadShader(TextFormat("resources/shaders/glsl%i/skinning.vs", GLSL_VERSION), _
                                    TextFormat("resources/shaders/glsl%i/skinning.fs", GLSL_VERSION))

characterModel.materials[1].shader = skinningShader

'' Load gltf model animations
dim as long animsCount = 0
dim as ulong animIndex = 0
dim as ulong animCurrentFrame = 0
dim as ModelAnimation ptr modelAnimations = LoadModelAnimations("resources/models/gltf/greenman.glb", @animsCount)

dim as Vector3 position = Vector3(0.0f, 0.0f, 0.0f) '' Set model position

DisableCursor()                    '' Limit cursor to relative movement inside the window

SetTargetFPS(60)                   '' Set our game to run at 60 frames-per-second
''--------------------------------------------------------------------------------------

'' Main game loop
do while not WindowShouldClose()        '' Detect window close button or ESC key
    '' Update
    ''----------------------------------------------------------------------------------
    UpdateCamera(@cam, CAMERA_THIRD_PERSON)
    
    '' Select current animation
    if IsKeyPressed(KEY_T) then 
        animIndex = (animIndex + 1) mod animsCount
    elseif IsKeyPressed(KEY_G) then
        animIndex = (animIndex + animsCount - 1) mod animsCount
    end if

    '' Update model animation
    dim as ModelAnimation anim = modelAnimations[animIndex]
    animCurrentFrame = (animCurrentFrame + 1) mod anim.frameCount
    characterModel.transform = MatrixTranslate(position.x, position.y, position.z)
    UpdateModelAnimationBones(characterModel, anim, animCurrentFrame)
    ''----------------------------------------------------------------------------------

    '' Draw
    ''----------------------------------------------------------------------------------
    BeginDrawing()

        ClearBackground(RAYWHITE)

        BeginMode3D(cam)
        
            '' Draw character mesh, pose calculation is done in shader (GPU skinning)
            DrawMesh(characterModel.meshes[0], characterModel.materials[1], characterModel.transform)

            DrawGrid(10, 1.0f)
            
        EndMode3D()

        DrawText("Use the T/G to switch animation", 10, 10, 20, GRAY)

    EndDrawing()
    ''----------------------------------------------------------------------------------
loop

'' De-Initialization
''--------------------------------------------------------------------------------------
UnloadModelAnimations(modelAnimations, animsCount) '' Unload model animation
UnloadModel(characterModel)    '' Unload model and meshes/material
UnloadShader(skinningShader)   '' Unload GPU skinning shader

CloseWindow()                  '' Close window and OpenGL context
''--------------------------------------------------------------------------------------