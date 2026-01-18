/'******************************************************************************************
*
*   raylib [shaders] example - Model shader
*
*   NOTE: This example requires raylib OpenGL 3.3 or ES2 versions for shaders support,
*         OpenGL 1.1 does not support shaders, recompile raylib to OpenGL 3.3 version.
*
*   NOTE: Shaders used in this example are #version 330 (OpenGL 3.3), to test this example
*         on OpenGL ES 2.0 platforms (Android, Raspberry Pi, HTML5), use #version 100 shaders
*         raylib comes with shaders ready for both versions, check raylib/shaders install folder
*
*   Example originally created with raylib 1.3, last time updated with raylib 3.7
*
*   Example licensed under an unmodified zlib/libpng license, which is an OSI-certified,
*   BSD-like license that allows static linking with closed source software
*
*   Copyright (c) 2014-2024 Ramon Santamaria (@raysan5)
*
*******************************************************************************************'/

#include "../../raylib.bi"
#define GLSL_VERSION            330

'' Initialization
''--------------------------------------------------------------------------------------
const as long screenWidth = 800
const as long screenHeight = 450

SetConfigFlags(FLAG_MSAA_4X_HINT)      '' Enable Multi Sampling Anti Aliasing 4x (if available)

InitWindow(screenWidth, screenHeight, "raylib [shaders] example - model shader")

'' Define the camera to look into our 3d world
dim as Camera cam
with cam
    .position = Vector3(4.0f, 4.0f, 4.0f)    '' Camera position
    .target = Vector3(0.0f, 1.0f, -1.0f)     '' Camera looking at point
    .up = Vector3(0.0f, 1.0f, 0.0f)          '' Camera up vector (rotation towards target)
    .fovy = 45.0f                            '' Camera field-of-view Y
    .projection = CAMERA_PERSPECTIVE         '' Camera projection type
end with

dim as Model mdl = LoadModel("resources/models/watermill.obj")                   '' Load OBJ model
dim as Texture2D tex = LoadTexture("resources/models/watermill_diffuse.png")   '' Load model texture

'' Load shader for model
'' NOTE: Defining 0 (NULL) for vertex shader forces usage of internal default vertex shader
dim as Shader shade = LoadShader(0, TextFormat("resources/shaders/glsl%i/grayscale.fs", GLSL_VERSION))

mdl.materials[0].shader = shade                     '' Set shader effect to 3d model
mdl.materials[0].maps[MATERIAL_MAP_DIFFUSE].texture = tex '' Bind texture to model

dim as Vector3 position = Vector3(0.0f, 0.0f, 0.0f)    '' Set model position

DisableCursor()                    '' Limit cursor to relative movement inside the window
SetTargetFPS(60)                   '' Set our game to run at 60 frames-per-second
''--------------------------------------------------------------------------------------

'' Main game loop
do while not WindowShouldClose()        '' Detect window close button or ESC key
    '' Update
    ''----------------------------------------------------------------------------------
    UpdateCamera(@cam, CAMERA_FREE)
    ''----------------------------------------------------------------------------------

    '' Draw
    ''----------------------------------------------------------------------------------
    BeginDrawing()

        ClearBackground(RAYWHITE)

        BeginMode3D(cam)

            DrawModel(mdl, position, 0.2f, WHITE)   '' Draw 3d model with texture

            DrawGrid(10, 1.0f)     '' Draw a grid

        EndMode3D()

        DrawText("(c) Watermill 3D model by Alberto Cano", screenWidth - 210, screenHeight - 20, 10, GRAY)

        DrawFPS(10, 10)

    EndDrawing()
    ''----------------------------------------------------------------------------------
loop

'' De-Initialization
''--------------------------------------------------------------------------------------
UnloadShader(shade)       '' Unload shader
UnloadTexture(tex)     '' Unload texture
UnloadModel(mdl)         '' Unload model

CloseWindow()              '' Close window and OpenGL context
''--------------------------------------------------------------------------------------