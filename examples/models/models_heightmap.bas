/'******************************************************************************************
*
*   raylib [models] example - Heightmap loading and drawing
*
*   Example originally created with raylib 1.8, last time updated with raylib 3.5
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

InitWindow(screenWidth, screenHeight, "raylib [models] example - heightmap loading and drawing")

'' Define our custom camera to look into our 3d world
dim as Camera cam
with cam
    .position = Vector3(18.0f, 21.0f, 18.0f)     '' Camera position
    .target = Vector3(0.0f, 0.0f, 0.0f)          '' Camera looking at point
    .up = Vector3(0.0f, 1.0f, 0.0f)              '' Camera up vector (rotation towards target)
    .fovy = 45.0f                                '' Camera field-of-view Y
    .projection = CAMERA_PERSPECTIVE             '' Camera projection type
end with

dim as Image img = LoadImage("resources/heightmap.png")     '' Load heightmap image (RAM)
dim as Texture2D texture = LoadTextureFromImage(img)        '' Convert image to texture (VRAM)

dim as Mesh msh = GenMeshHeightmap(img, Vector3(16, 8, 16)) '' Generate heightmap mesh (RAM and VRAM)
dim as Model mdl = LoadModelFromMesh(msh)                  '' Load model from generated mesh

mdl.materials[0].maps[MATERIAL_MAP_DIFFUSE].texture = texture '' Set map diffuse texture
dim as Vector3 mapPosition = Vector3(-8.0f, 0.0f, -8.0f)           '' Define model position

UnloadImage(img)             '' Unload heightmap image from RAM, already uploaded to VRAM

SetTargetFPS(60)               '' Set our game to run at 60 frames-per-second
''--------------------------------------------------------------------------------------

'' Main game loop
do while not WindowShouldClose()    '' Detect window close button or ESC key
    '' Update
    ''----------------------------------------------------------------------------------
    UpdateCamera(@cam, CAMERA_ORBITAL)
    ''----------------------------------------------------------------------------------

    '' Draw
    ''----------------------------------------------------------------------------------
    BeginDrawing()

        ClearBackground(RAYWHITE)

        BeginMode3D(cam)

            DrawModel(mdl, mapPosition, 1.0f, RED)

            DrawGrid(20, 1.0f)

        EndMode3D()

        DrawTexture(texture, screenWidth - texture.width - 20, 20, WHITE)
        DrawRectangleLines(screenWidth - texture.width - 20, 20, texture.width, texture.height, GREEN)

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