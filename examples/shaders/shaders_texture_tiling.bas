/'******************************************************************************************
*
*   raylib [shaders] example - texture tiling
*
*   Example demonstrates how to tile a texture on a 3D model using raylib.
*
*   Example contributed by Luis Almeida (@luis605) and reviewed by Ramon Santamaria (@raysan5)
*
*   Example licensed under an unmodified zlib/libpng license, which is an OSI-certified,
*   BSD-like license that allows static linking with closed source software
*
*   Copyright (c) 2023 Luis Almeida (@luis605)
*
*******************************************************************************************'/

#include "../../raylib.bi"

#define GLSL_VERSION            330

'' Initialization
''--------------------------------------------------------------------------------------
const as long screenWidth = 800
const as long screenHeight = 450

InitWindow(screenWidth, screenHeight, "raylib [shaders] example - texture tiling")

'' Define the camera to look into our 3d world
dim as Camera3D cam
with cam
    .position = Vector3(4.0f, 4.0f, 4.0f) '' Camera position
    .target = Vector3(0.0f, 0.5f, 0.0f)      '' Camera looking at point
    .up = Vector3(0.0f, 1.0f, 0.0f)          '' Camera up vector (rotation towards target)
    .fovy = 45.0f                                '' Camera field-of-view Y
    .projection = CAMERA_PERSPECTIVE             '' Camera projection type
end with

'' Load a cube model
dim as Mesh cube = GenMeshCube(1.0f, 1.0f, 1.0f)
dim as Model mdl = LoadModelFromMesh(cube)

'' Load a texture and assign to cube model
dim as Texture2D tex = LoadTexture("resources/cubicmap_atlas.png")
mdl.materials[0].maps[MATERIAL_MAP_DIFFUSE].texture = tex

'' Set the texture tiling using a shader
dim as single tiling(1) = {3.0f, 3.0f}
dim as Shader shade = LoadShader(0, TextFormat("resources/shaders/glsl%i/tiling.fs", GLSL_VERSION))
SetShaderValue(shade, GetShaderLocation(shade, "tiling"), @tiling(0), SHADER_UNIFORM_VEC2)
mdl.materials[0].shader = shade

DisableCursor()                    '' Limit cursor to relative movement inside the window

SetTargetFPS(60)                   '' Set our game to run at 60 frames-per-second
''--------------------------------------------------------------------------------------

'' Main game loop
do while not WindowShouldClose()        '' Detect window close button or ESC key
    '' Update
    ''----------------------------------------------------------------------------------
    UpdateCamera(@cam, CAMERA_FREE)

    if IsKeyPressed(KEY_Z) then cam.target = Vector3(0.0f, 0.5f, 0.0f)
    ''----------------------------------------------------------------------------------

    '' Draw
    ''----------------------------------------------------------------------------------
    BeginDrawing()
    
        ClearBackground(RAYWHITE)

        BeginMode3D(cam)
        
            BeginShaderMode(shade)
                DrawModel(mdl, Vector3(0.0f, 0.0f, 0.0f), 2.0f, WHITE)
            EndShaderMode()

            DrawGrid(10, 1.0f)
            
        EndMode3D()

        DrawText("Use mouse to rotate the camera", 10, 10, 20, DARKGRAY)

    EndDrawing()
    ''----------------------------------------------------------------------------------
loop

'' De-Initialization
''--------------------------------------------------------------------------------------
UnloadModel(mdl)         '' Unload model
UnloadShader(shade)       '' Unload shader
UnloadTexture(tex)     '' Unload texture

CloseWindow()              '' Close window and OpenGL context
''--------------------------------------------------------------------------------------