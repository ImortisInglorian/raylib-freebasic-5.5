/'******************************************************************************************
*
*   raylib [shaders] example - Vertex displacement
*
*   Example originally created with raylib 5.0, last time updated with raylib 4.5
*
*   Example contributed by <Alex ZH> (@ZzzhHe) and reviewed by Ramon Santamaria (@raysan5)
*
*   Example licensed under an unmodified zlib/libpng license, which is an OSI-certified,
*   BSD-like license that allows static linking with closed source software
*
*   Copyright (c) 2023 <Alex ZH> (@ZzzhHe)
*
*******************************************************************************************'/

#include "../../raylib.bi"
#include "../../rlgl.bi"
#include "../../rlights.bi"

#define GLSL_VERSION            330

'' Initialization
''--------------------------------------------------------------------------------------
const as long screenWidth = 800
const as long screenHeight = 450

InitWindow(screenWidth, screenHeight, "raylib [shaders] example - vertex displacement")

'' set up camera
dim as Camera cam
with cam
    .position = Vector3(20.0f, 5.0f, -20.0f)
    .target = Vector3(0.0f, 0.0f, 0.0f)
    .up = Vector3(0.0f, 1.0f, 0.0f)
    .fovy = 60.0f
    .projection = CAMERA_PERSPECTIVE
end with

'' Load vertex and fragment shaders
dim as Shader shade = LoadShader( _
    TextFormat("resources/shaders/glsl%i/vertex_displacement.vs", GLSL_VERSION), _
    TextFormat("resources/shaders/glsl%i/vertex_displacement.fs", GLSL_VERSION))

'' Load perlin noise texture
dim as Image perlinNoiseImage = GenImagePerlinNoise(512, 512, 0, 0, 1.0f)
dim as Texture perlinNoiseMap = LoadTextureFromImage(perlinNoiseImage)
UnloadImage(perlinNoiseImage)

'' Set shader uniform location
dim as long perlinNoiseMapLoc = GetShaderLocation(shade, "perlinNoiseMap")
rlEnableShader(shade.id)
rlActiveTextureSlot(1)
rlEnableTexture(perlinNoiseMap.id)
rlSetUniformSampler(perlinNoiseMapLoc, 1)

'' Create a plane mesh and model
dim as Mesh planeMesh = GenMeshPlane(50, 50, 50, 50)
dim as Model planeModel = LoadModelFromMesh(planeMesh)
'' Set plane model material
planeModel.materials[0].shader = shade

dim as single tme = 0.0f

SetTargetFPS(60)
''--------------------------------------------------------------------------------------

'' Main game loop
do while not WindowShouldClose()    '' Detect window close button or ESC key
    '' Update
    ''----------------------------------------------------------------------------------
    UpdateCamera(@cam, CAMERA_FREE) '' Update camera

    tme += GetFrameTime() '' Update time variable
    SetShaderValue(shade, GetShaderLocation(shade, "tme"), @tme, SHADER_UNIFORM_FLOAT) '' Send time value to shader

    '' Draw
    ''----------------------------------------------------------------------------------
    BeginDrawing()

        ClearBackground(RAYWHITE)

        BeginMode3D(cam)

            BeginShaderMode(shade)
                '' Draw plane model
                DrawModel(planeModel, Vector3(0.0f, 0.0f, 0.0f), 1.0f, RLColor(255, 255, 255, 255))
            EndShaderMode()

        EndMode3D()

        DrawText("Vertex displacement", 10, 10, 20, DARKGRAY)
        DrawFPS(10, 40)

    EndDrawing()
    ''----------------------------------------------------------------------------------
loop

'' De-Initialization
''--------------------------------------------------------------------------------------
UnloadShader(shade)
UnloadModel(planeModel)
UnloadTexture(perlinNoiseMap)

CloseWindow()        '' Close window and OpenGL context
''--------------------------------------------------------------------------------------