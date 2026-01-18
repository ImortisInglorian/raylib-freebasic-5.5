/'******************************************************************************************
*
*   raylib [models] example - Cubicmap loading and drawing
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

InitWindow(screenWidth, screenHeight, "raylib [models] example - cubesmap loading and drawing")

'' Define the camera to look into our 3d world
dim as Camera cam
with cam
    .position = Vector3(16.0f, 14.0f, 16.0f)     '' Camera position
    .target = Vector3(0.0f, 0.0f, 0.0f)         '' Camera looking at point
    .up = Vector3(0.0f, 1.0f, 0.0f)              '' Camera up vector (rotation towards target)
    .fovy = 45.0f                                    '' Camera field-of-view Y
    .projection = CAMERA_PERSPECTIVE                 '' Camera projection type
end with

dim as Image img = LoadImage("resources/cubicmap.png")      '' Load cubicmap image (RAM)
dim as Texture2D cubicmap = LoadTextureFromImage(img)       '' Convert image to texture to display (VRAM)

dim as Mesh msh = GenMeshCubicmap(img, Vector3(1.0f, 1.0f, 1.0f))
dim as Model mdl = LoadModelFromMesh(msh)

'' NOTE: By default each cube is mapped to one part of texture atlas
dim as Texture2D texture = LoadTexture("resources/cubicmap_atlas.png")    '' Load map texture
mdl.materials[0].maps[MATERIAL_MAP_DIFFUSE].texture = texture    '' Set map diffuse texture

dim as Vector3 mapPosition = Vector3(-16.0f, 0.0f, -8.0f)          '' Set model position

UnloadImage(img)     '' Unload cubesmap image from RAM, already uploaded to VRAM

dim as boolean pause = false     '' Pause camera orbital rotation (and zoom)

SetTargetFPS(60)                   '' Set our game to run at 60 frames-per-second
''--------------------------------------------------------------------------------------

'' Main game loop
do while not WindowShouldClose()        '' Detect window close button or ESC key
    '' Update
    ''----------------------------------------------------------------------------------
    if IsKeyPressed(KEY_P) then pause = not pause

    if not pause then UpdateCamera(@cam, CAMERA_ORBITAL)
    ''----------------------------------------------------------------------------------

    '' Draw
    ''----------------------------------------------------------------------------------
    BeginDrawing()

        ClearBackground(RAYWHITE)

        BeginMode3D(cam)

            DrawModel(mdl, mapPosition, 1.0f, WHITE)

        EndMode3D()

        DrawTextureEx(cubicmap, Vector2(screenWidth - cubicmap.width*4.0f - 20, 20.0f), 0.0f, 4.0f, WHITE)
        DrawRectangleLines(screenWidth - cubicmap.width*4 - 20, 20, cubicmap.width*4, cubicmap.height*4, GREEN)

        DrawText("cubicmap image used to", 658, 90, 10, GRAY)
        DrawText("generate map 3d model", 658, 104, 10, GRAY)

        DrawFPS(10, 10)

    EndDrawing()
    ''----------------------------------------------------------------------------------
loop

'' De-Initialization
''--------------------------------------------------------------------------------------
UnloadTexture(cubicmap)    '' Unload cubicmap texture
UnloadTexture(texture)     '' Unload map texture
UnloadModel(mdl)         '' Unload map model

CloseWindow()              '' Close window and OpenGL context
''--------------------------------------------------------------------------------------