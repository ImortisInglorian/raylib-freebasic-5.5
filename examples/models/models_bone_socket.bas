/'******************************************************************************************
*
*   raylib [core] example - Using bones as socket for calculating the positioning of something
* 
*   Example originally created with raylib 4.5, last time updated with raylib 4.5
*
*   Example contributed by iP (@ipzaur) and reviewed by Ramon Santamaria (@raysan5)
*
*   Example licensed under an unmodified zlib/libpng license, which is an OSI-certified,
*   BSD-like license that allows static linking with closed source software
*
*   Copyright (c) 2024 iP (@ipzaur)
*
*******************************************************************************************'/

#include "../../raylib.bi"

#define BONE_SOCKETS        3
#define BONE_SOCKET_HAT     0
#define BONE_SOCKET_HAND_R  1
#define BONE_SOCKET_HAND_L  2

'' Initialization
''--------------------------------------------------------------------------------------
const as long screenWidth = 800
const as long screenHeight = 450

InitWindow(screenWidth, screenHeight, "raylib [models] example - bone socket")

'' Define the camera to look into our 3d world
dim as Camera cam
with cam
    .position = Vector3(5.0f, 5.0f, 5.0f) '' Camera position
    .target = Vector3(0.0f, 2.0f, 0.0f)  '' Camera looking at point
    .up = Vector3(0.0f, 1.0f, 0.0f)      '' Camera up vector (rotation towards target)
    .fovy = 45.0f                            '' Camera field-of-view Y
    .projection = CAMERA_PERSPECTIVE         '' Camera projection type
end with

'' Load gltf model
dim as Model characterModel = LoadModel("resources/models/gltf/greenman.glb") '' Load character model
dim as Model equipModel(...) = { _
    LoadModel("resources/models/gltf/greenman_hat.glb"), _
    LoadModel("resources/models/gltf/greenman_sword.glb"), _
    LoadModel("resources/models/gltf/greenman_shield.glb") _
}

dim as boolean showEquip(...) = { true, true, true }   '' Toggle on/off equip

'' Load gltf model animations
dim as long animsCount = 0
dim as ulong animIndex = 0
dim as ulong animCurrentFrame = 0
dim as ModelAnimation ptr modelAnimations = LoadModelAnimations("resources/models/gltf/greenman.glb", @animsCount)

'' indices of bones for sockets
dim as long boneSocketIndex(...) = { -1, -1, -1 }

'' search bones for sockets 
for i as integer = 0 to characterModel.boneCount - 1
    if TextIsEqual(characterModel.bones[i].name, "socket_hat") then
        boneSocketIndex(BONE_SOCKET_HAT) = i
        continue for
    end if
    
    if TextIsEqual(characterModel.bones[i].name, "socket_hand_R") then
        boneSocketIndex(BONE_SOCKET_HAND_R) = i
        continue for
    end if
    
    if TextIsEqual(characterModel.bones[i].name, "socket_hand_L") then
        boneSocketIndex(BONE_SOCKET_HAND_L) = i
        continue for
    end if
next

dim as Vector3 position = Vector3(0.0f, 0.0f, 0.0f) '' Set model position
dim as ushort angle = 0           '' Set angle for rotate character

DisableCursor()                    '' Limit cursor to relative movement inside the window

SetTargetFPS(60)                   '' Set our game to run at 60 frames-per-second
''--------------------------------------------------------------------------------------

'' Main game loop
do while not WindowShouldClose()        '' Detect window close button or ESC key
    '' Update
    ''----------------------------------------------------------------------------------
    UpdateCamera(@cam, CAMERA_THIRD_PERSON)
    
    '' Rotate character
    if IsKeyDown(KEY_F) then 
        angle = (angle + 1) mod 360
    elseif IsKeyDown(KEY_H) then
        angle = (360 + angle - 1) mod 360
    end if

    '' Select current animation
    if IsKeyPressed(KEY_T) then 
        animIndex = (animIndex + 1) mod animsCount
    elseif IsKeyPressed(KEY_G) then 
        animIndex = (animIndex + animsCount - 1) mod animsCount
    end if

    '' Toggle shown of equip
    if IsKeyPressed(KEY_ONE) then showEquip(BONE_SOCKET_HAT) =  not showEquip(BONE_SOCKET_HAT)
    if IsKeyPressed(KEY_TWO) then showEquip(BONE_SOCKET_HAND_R) =  not showEquip (BONE_SOCKET_HAND_R)
    if IsKeyPressed(KEY_THREE) then showEquip(BONE_SOCKET_HAND_L)= not showEquip(BONE_SOCKET_HAND_L)
    
    '' Update model animation
    dim as ModelAnimation anim = modelAnimations[animIndex]
    animCurrentFrame = (animCurrentFrame + 1) mod anim.frameCount
    UpdateModelAnimation(characterModel, anim, animCurrentFrame)
    ''----------------------------------------------------------------------------------

    '' Draw
    ''----------------------------------------------------------------------------------
    BeginDrawing()

        ClearBackground(RAYWHITE)

        BeginMode3D(cam)
            '' Draw character
            dim as Quaternion characterRotate = QuaternionFromAxisAngle(Vector3(0.0f, 1.0f, 0.0f), angle*DEG2RAD)
            characterModel.transform = MatrixMultiply(QuaternionToMatrix(characterRotate), MatrixTranslate(position.x, position.y, position.z))
            UpdateModelAnimation(characterModel, anim, animCurrentFrame)
            DrawMesh(characterModel.meshes[0], characterModel.materials[1], characterModel.transform)

            '' Draw equipments (hat, sword, shield)
            for i as integer = 0 to BONE_SOCKETS - 1
                if not showEquip(i) then continue for

                dim as Transform ptr transform = @anim.framePoses[animCurrentFrame][boneSocketIndex(i)]
                dim as Quaternion inRotation = characterModel.bindPose[boneSocketIndex(i)].rotation
                dim as Quaternion outRotation = transform->rotation
                
                '' Calculate socket rotation (angle between bone in initial pose and same bone in current animation frame)
                dim as Quaternion rotate = QuaternionMultiply(outRotation, QuaternionInvert(inRotation))
                dim as Matrix matrixTransform = QuaternionToMatrix(rotate)
                '' Translate socket to its position in the current animation
                matrixTransform = MatrixMultiply(matrixTransform, MatrixTranslate(transform->translation.x, transform->translation.y, transform->translation.z))
                '' Transform the socket using the transform of the character (angle and translate)
                matrixTransform = MatrixMultiply(matrixTransform, characterModel.transform)
                
                '' Draw mesh at socket position with socket angle rotation
                DrawMesh(equipModel(i).meshes[0], equipModel(i).materials[1], matrixTransform)
            next

            DrawGrid(10, 1.0f)
        EndMode3D()

        DrawText("Use the T/G to switch animation", 10, 10, 20, GRAY)
        DrawText("Use the F/H to rotate character left/right", 10, 35, 20, GRAY)
        DrawText("Use the 1,2,3 to toggle shown of hat, sword and shield", 10, 60, 20, GRAY)

    EndDrawing()
    ''----------------------------------------------------------------------------------
loop

'' De-Initialization
''--------------------------------------------------------------------------------------
UnloadModelAnimations(modelAnimations, animsCount)
UnloadModel(characterModel)         '' Unload character model and meshes/material

'' Unload equipment model and meshes/material
for i as integer = 0 to BONE_SOCKETS - 1 
    UnloadModel(equipModel(i))
next

CloseWindow()              '' Close window and OpenGL context
''--------------------------------------------------------------------------------------