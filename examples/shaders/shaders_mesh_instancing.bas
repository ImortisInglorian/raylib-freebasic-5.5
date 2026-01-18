/'******************************************************************************************
*
*   raylib [shaders] example - Mesh instancing
*
*   Example originally created with raylib 3.7, last time updated with raylib 4.2
*
*   Example contributed by @seanpringle and reviewed by Max (@moliad) and Ramon Santamaria (@raysan5)
*
*   Example licensed under an unmodified zlib/libpng license, which is an OSI-certified,
*   BSD-like license that allows static linking with closed source software
*
*   Copyright (c) 2020-2024 @seanpringle, Max (@moliad) and Ramon Santamaria (@raysan5)
*
*******************************************************************************************'/


#include "../../raylib.bi"
#include "../../rlights.bi"

#define GLSL_VERSION            330

#define MAX_INSTANCES  10000

'' Initialization
''--------------------------------------------------------------------------------------
const as long screenWidth = 800
const as long screenHeight = 450

InitWindow(screenWidth, screenHeight, "raylib [shaders] example - mesh instancing")

'' Define the camera to look into our 3d world
dim as Camera cam
with cam
    .position = Vector3(-125.0f, 125.0f, -125.0f)    '' Camera position
    .target = Vector3(0.0f, 0.0f, 0.0f)              '' Camera looking at point
    .up = Vector3(0.0f, 1.0f, 0.0f)                  '' Camera up vector (rotation towards target)
    .fovy = 45.0f                                    '' Camera field-of-view Y
    .projection = CAMERA_PERSPECTIVE                 '' Camera projection type
end with

'' Define mesh to be instanced
dim as Mesh cube = GenMeshCube(1.0f, 1.0f, 1.0f)

'' Define transforms to be uploaded to GPU for instances
dim as Matrix ptr transforms = callocate(MAX_INSTANCES, sizeof(Matrix))   '' Pre-multiplied transformations passed to rlgl

'' Translate and rotate cubes randomly
for i as integer = 0 to MAX_INSTANCES - 1
    dim as Matrix translation = MatrixTranslate(GetRandomValue(-50, 50), GetRandomValue(-50, 50), GetRandomValue(-50, 50))
    dim as Vector3 axis = Vector3Normalize(Vector3(GetRandomValue(0, 360), GetRandomValue(0, 360), GetRandomValue(0, 360)))
    dim as single angle = GetRandomValue(0, 10)*DEG2RAD
    dim as Matrix rotation = MatrixRotate(axis, angle)
    
    transforms[i] = MatrixMultiply(rotation, translation)
next

'' Load lighting shader
dim as Shader shade = LoadShader(TextFormat("resources/shaders/glsl%i/lighting_instancing.vs", GLSL_VERSION), _
                            TextFormat("resources/shaders/glsl%i/lighting.fs", GLSL_VERSION))
'' Get shader locations
shade.locs[SHADER_LOC_MATRIX_MVP] = GetShaderLocation(shade, "mvp")
shade.locs[SHADER_LOC_VECTOR_VIEW] = GetShaderLocation(shade, "viewPos")
shade.locs[SHADER_LOC_MATRIX_MODEL] = GetShaderLocationAttrib(shade, "instanceTransform")

'' Set shader value: ambient light level
dim as long ambientLoc = GetShaderLocation(shade, "ambient")
dim as single amb(...) = { 0.2f, 0.2f, 0.2f, 1.0f }
SetShaderValue(shade, ambientLoc, @amb(0), SHADER_UNIFORM_VEC4)

'' Create one light
CreateLight(LIGHT_DIRECTIONAL, Vector3(50.0f, 50.0f, 0.0f), Vector3Zero(), WHITE, shade)

'' NOTE: We are assigning the intancing shader to material.shader
'' to be used on mesh drawing with DrawMeshInstanced()
dim as Material matInstances = LoadMaterialDefault()
matInstances.shader = shade
matInstances.maps[MATERIAL_MAP_DIFFUSE].color = RED

'' Load default material (using raylib intenral default shader) for non-instanced mesh drawing
'' WARNING: Default shader enables vertex color attribute BUT GenMeshCube() does not generate vertex colors, so,
'' when drawing the color attribute is disabled and a default color value is provided as input for thevertex attribute
dim as Material matDefault = LoadMaterialDefault()
matDefault.maps[MATERIAL_MAP_DIFFUSE].color = BLUE

SetTargetFPS(60)                   '' Set our game to run at 60 frames-per-second
''--------------------------------------------------------------------------------------

'' Main game loop
do while not WindowShouldClose()        '' Detect window close button or ESC key
    '' Update
    ''----------------------------------------------------------------------------------
    UpdateCamera(@cam, CAMERA_ORBITAL)

    '' Update the light shader with the camera view position
    dim as single cameraPos(...) = { cam.position.x, cam.position.y, cam.position.z }
    SetShaderValue(shade, shade.locs[SHADER_LOC_VECTOR_VIEW], @cameraPos(0), SHADER_UNIFORM_VEC3)
    ''----------------------------------------------------------------------------------

    '' Draw
    ''----------------------------------------------------------------------------------
    BeginDrawing()

        ClearBackground(RAYWHITE)

        BeginMode3D(cam)

            '' Draw cube mesh with default material (BLUE)
            DrawMesh(cube, matDefault, MatrixTranslate(-10.0f, 0.0f, 0.0f))

            '' Draw meshes instanced using material containing instancing shader (RED + lighting),
            '' transforms[] for the instances should be provided, they are dynamically
            '' updated in GPU every frame, so we can animate the different mesh instances
            DrawMeshInstanced(cube, matInstances, transforms, MAX_INSTANCES)

            '' Draw cube mesh with default material (BLUE)
            DrawMesh(cube, matDefault, MatrixTranslate(10.0f, 0.0f, 0.0f))

        EndMode3D()

        DrawFPS(10, 10)

    EndDrawing()
    ''----------------------------------------------------------------------------------
loop

'' De-Initialization
''--------------------------------------------------------------------------------------
deallocate(transforms)    '' Free transforms

CloseWindow()          '' Close window and OpenGL context
''--------------------------------------------------------------------------------------