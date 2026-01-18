/'******************************************************************************************
*
*   raylib [models] example - Models loading
*
*   NOTE: raylib supports multiple models file formats:
*
*     - OBJ  > Text file format. Must include vertex position-texcoords-normals information,
*              if files references some .mtl materials file, it will be loaded (or try to).
*     - GLTF > Text/binary file format. Includes lot of information and it could
*              also reference external files, raylib will try loading mesh and materials data.
*     - IQM  > Binary file format. Includes mesh vertex data but also animation data,
*              raylib can load .iqm animations.
*     - VOX  > Binary file format. MagikaVoxel mesh format:
*              https:''github.com/ephtracy/voxel-model/blob/master/MagicaVoxel-file-format-vox.txt
*     - M3D  > Binary file format. Model 3D format:
*              https:''bztsrc.gitlab.io/model3d
*
*   Example originally created with raylib 2.0, last time updated with raylib 4.2
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

InitWindow(screenWidth, screenHeight, "raylib [models] example - models loading")

'' Define the camera to look into our 3d world
dim as Camera cam
with cam
    .position = Vector3(50.0f, 50.0f, 50.0f) '' Camera position
    .target = Vector3(0.0f, 10.0f, 0.0f)     '' Camera looking at point
    .up = Vector3(0.0f, 1.0f, 0.0f)          '' Camera up vector (rotation towards target)
    .fovy = 45.0f                            '' Camera field-of-view Y
    .projection = CAMERA_PERSPECTIVE         '' Camera mode type
end with

dim as Model mdl = LoadModel("resources/models/obj/castle.obj")                 '' Load model
dim as Texture2D texture = LoadTexture("resources/models/obj/castle_diffuse.png") '' Load model texture
mdl.materials[0].maps[MATERIAL_MAP_DIFFUSE].texture = texture            '' Set map diffuse texture

dim as Vector3 position = Vector3(0.0f, 0.0f, 0.0f)                    '' Set model position

dim as BoundingBox bounds = GetMeshBoundingBox(mdl.meshes[0])   '' Set model bounds

'' NOTE: bounds are calculated from the original size of the model,
'' if model is scaled on drawing, bounds must be also scaled

dim as boolean selected = false          '' Selected object flag

DisableCursor()                '' Limit cursor to relative movement inside the window

SetTargetFPS(60)               '' Set our game to run at 60 frames-per-second
''--------------------------------------------------------------------------------------

'' Main game loop
do while not WindowShouldClose()    '' Detect window close button or ESC key
    '' Update
    ''----------------------------------------------------------------------------------
    UpdateCamera(@cam, CAMERA_FIRST_PERSON)

    '' Load new models/textures on drag&drop
    if IsFileDropped() then
        dim as FilePathList droppedFiles = LoadDroppedFiles()

        if droppedFiles.count = 1 then '' Only support one file dropped
            if IsFileExtension(droppedFiles.paths[0], ".obj") or _
                IsFileExtension(droppedFiles.paths[0], ".gltf") or _
                IsFileExtension(droppedFiles.paths[0], ".glb") or _
                IsFileExtension(droppedFiles.paths[0], ".vox") or _
                IsFileExtension(droppedFiles.paths[0], ".iqm") or _
                IsFileExtension(droppedFiles.paths[0], ".m3d") then       '' Model file formats supported
                UnloadModel(mdl)                         '' Unload previous model
                mdl = LoadModel(droppedFiles.paths[0])   '' Load new model
                mdl.materials[0].maps[MATERIAL_MAP_DIFFUSE].texture = texture '' Set current map diffuse texture

                bounds = GetMeshBoundingBox(mdl.meshes[0])

                '' TODO: Move camera position from target enough distance to visualize model properly
            elseif IsFileExtension(droppedFiles.paths[0], ".png") then  '' Texture file formats supported
                '' Unload current model texture and load new one
                UnloadTexture(texture)
                texture = LoadTexture(droppedFiles.paths[0])
                mdl.materials[0].maps[MATERIAL_MAP_DIFFUSE].texture = texture
            end if
        end if

        UnloadDroppedFiles(droppedFiles)    '' Unload filepaths from memory
    end if

    '' Select model on mouse click
    if IsMouseButtonPressed(MOUSE_BUTTON_LEFT) then
        '' Check collision between ray and box
        if GetRayCollisionBox(GetScreenToWorldRay(GetMousePosition(), cam), bounds).hit then 
            selected = not selected
        else 
            selected = false
        end if
    end if
    ''----------------------------------------------------------------------------------

    '' Draw
    ''----------------------------------------------------------------------------------
    BeginDrawing()

        ClearBackground(RAYWHITE)

        BeginMode3D(cam)

            DrawModel(mdl, position, 1.0f, WHITE)        '' Draw 3d model with texture

            DrawGrid(20, 10.0f)         '' Draw a grid

            if selected then DrawBoundingBox(bounds, GREEN)   '' Draw selection box

        EndMode3D()

        DrawText("Drag & drop model to load mesh/texture.", 10, GetScreenHeight() - 20, 10, DARKGRAY)
        if selected then DrawText("MODEL SELECTED", GetScreenWidth() - 110, 10, 10, GREEN)

        DrawText("(c) Castle 3D model by Alberto Cano", screenWidth - 200, screenHeight - 20, 10, GRAY)

        DrawFPS(10, 10)

    EndDrawing()
    ''----------------------------------------------------------------------------------
loop

'' De-Initialization
''--------------------------------------------------------------------------------------
UnloadTexture(texture)     '' Unload texture
UnloadModel(mdl)         '' Unload model

CloseWindow()              '' Close window and OpenGL context
''--------------------------------------------------------------------------------------