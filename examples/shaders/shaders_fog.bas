/'******************************************************************************************
*
*   raylib [shaders] example - fog
*
*   NOTE: This example requires raylib OpenGL 3.3 or ES2 versions for shaders support,
*         OpenGL 1.1 does not support shaders, recompile raylib to OpenGL 3.3 version.
*
*   NOTE: Shaders used in this example are #version 330 (OpenGL 3.3).
*
*   Example originally created with raylib 2.5, last time updated with raylib 3.7
*
*   Example contributed by Chris Camacho (@chriscamacho) and reviewed by Ramon Santamaria (@raysan5)
*
*   Example licensed under an unmodified zlib/libpng license, which is an OSI-certified,
*   BSD-like license that allows static linking with closed source software
*
*   Copyright (c) 2019-2024 Chris Camacho (@chriscamacho) and Ramon Santamaria (@raysan5)
*
*******************************************************************************************'/

#include "../../raylib.bi"
#include "../../rlights.bi"

#define GLSL_VERSION            330

'' Initialization
''--------------------------------------------------------------------------------------
const as long screenWidth = 800
const as long screenHeight = 450

SetConfigFlags(FLAG_MSAA_4X_HINT)  '' Enable Multi Sampling Anti Aliasing 4x (if available)
InitWindow(screenWidth, screenHeight, "raylib [shaders] example - fog")

'' Define the camera to look into our 3d world
dim as Camera cam
with cam
    .position = Vector3(2.0f, 2.0f, 6.0f)    '' Camera position
    .target = Vector3(0.0f, 0.5f, 0.0f)      '' Camera looking at point
    .up = Vector3(0.0f, 1.0f, 0.0f)          '' Camera up vector (rotation towards target)
    .fovy = 45.0f                            '' Camera field-of-view Y
    .projection = CAMERA_PERSPECTIVE         '' Camera projection type
end with

'' Load models and texture
dim as Model modelA = LoadModelFromMesh(GenMeshTorus(0.4f, 1.0f, 16, 32))
dim as Model modelB = LoadModelFromMesh(GenMeshCube(1.0f, 1.0f, 1.0f))
dim as Model modelC = LoadModelFromMesh(GenMeshSphere(0.5f, 32, 32))
dim as Texture tex = LoadTexture("resources/texel_checker.png")

'' Assign texture to default model material
modelA.materials[0].maps[MATERIAL_MAP_DIFFUSE].texture = tex
modelB.materials[0].maps[MATERIAL_MAP_DIFFUSE].texture = tex
modelC.materials[0].maps[MATERIAL_MAP_DIFFUSE].texture = tex

'' Load shader and set up some uniforms
dim as Shader shade = LoadShader(TextFormat("resources/shaders/glsl%i/lighting.vs", GLSL_VERSION), _
                            TextFormat("resources/shaders/glsl%i/fog.fs", GLSL_VERSION))
shade.locs[SHADER_LOC_MATRIX_MODEL] = GetShaderLocation(shade, "matModel")
shade.locs[SHADER_LOC_VECTOR_VIEW] = GetShaderLocation(shade, "viewPos")

'' Ambient light level
dim as long ambientLoc = GetShaderLocation(shade, "ambient")
dim as single amb(...) = { 0.2f, 0.2f, 0.2f, 1.0f }
SetShaderValue(shade, ambientLoc, @amb(0), SHADER_UNIFORM_VEC4)

dim as single fogDensity = 0.15f
dim as long fogDensityLoc = GetShaderLocation(shade, "fogDensity")
SetShaderValue(shade, fogDensityLoc, @fogDensity, SHADER_UNIFORM_FLOAT)

'' NOTE: All models share the same shader
modelA.materials[0].shader = shade
modelB.materials[0].shader = shade
modelC.materials[0].shader = shade

'' Using just 1 point lights
CreateLight(LIGHT_POINT, Vector3(0, 2, 6), Vector3Zero(), WHITE, shade)

SetTargetFPS(60)                   '' Set our game to run at 60 frames-per-second
''--------------------------------------------------------------------------------------

'' Main game loop
do while not WindowShouldClose()        '' Detect window close button or ESC key
    '' Update
    ''----------------------------------------------------------------------------------
    UpdateCamera(@cam, CAMERA_ORBITAL)

    if IsKeyDown(KEY_UP) then
        fogDensity += 0.001f
        if fogDensity > 1.0f then fogDensity = 1.0f
    end if

    if IsKeyDown(KEY_DOWN) then
        fogDensity -= 0.001f
        if fogDensity < 0.0f then fogDensity = 0.0f
    end if

    SetShaderValue(shade, fogDensityLoc, @fogDensity, SHADER_UNIFORM_FLOAT)

    '' Rotate the torus
    modelA.transform = MatrixMultiply(modelA.transform, MatrixRotateX(-0.025f))
    modelA.transform = MatrixMultiply(modelA.transform, MatrixRotateZ(0.012f))

    '' Update the light shader with the camera view position
    SetShaderValue(shade, shade.locs[SHADER_LOC_VECTOR_VIEW], @cam.position.x, SHADER_UNIFORM_VEC3)
    ''----------------------------------------------------------------------------------

    '' Draw
    ''----------------------------------------------------------------------------------
    BeginDrawing()

        ClearBackground(GRAY)

        BeginMode3D(cam)

            '' Draw the three models
            DrawModel(modelA, Vector3Zero(), 1.0f, WHITE)
            DrawModel(modelB, Vector3(-2.6f, 0, 0), 1.0f, WHITE)
            DrawModel(modelC, Vector3( 2.6f, 0, 0), 1.0f, WHITE)

            for i as integer = -20 to 20 step 2
                DrawModel(modelA,Vector3(i, 0, 2), 1.0f, WHITE)
            next

        EndMode3D()

        DrawText(TextFormat("Use KEY_UP/KEY_DOWN to change fog density [%.2f]", fogDensity), 10, 10, 20, RAYWHITE)

    EndDrawing()
    ''----------------------------------------------------------------------------------
loop

'' De-Initialization
''--------------------------------------------------------------------------------------
UnloadModel(modelA)        '' Unload the model A
UnloadModel(modelB)        '' Unload the model B
UnloadModel(modelC)        '' Unload the model C
UnloadTexture(tex)     '' Unload the texture
UnloadShader(shade)       '' Unload shader

CloseWindow()              '' Close window and OpenGL context
''--------------------------------------------------------------------------------------