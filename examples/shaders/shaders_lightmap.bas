/'******************************************************************************************
*
*   raylib [shaders] example - lightmap
*
*   NOTE: This example requires raylib OpenGL 3.3 or ES2 versions for shaders support,
*         OpenGL 1.1 does not support shaders, recompile raylib to OpenGL 3.3 version.
*
*   NOTE: Shaders used in this example are #version 330 (OpenGL 3.3).
*
*   Example contributed by Jussi Viitala (@nullstare) and reviewed by Ramon Santamaria (@raysan5)
*
*   Example licensed under an unmodified zlib/libpng license, which is an OSI-certified,
*   BSD-like license that allows static linking with closed source software
*
*   Copyright (c) 2019-2024 Jussi Viitala (@nullstare) and Ramon Santamaria (@raysan5)
*
*******************************************************************************************'/

#include "../../raylib.bi"
#include "../../rlgl.bi"

#define GLSL_VERSION            330
#define MAP_SIZE 10

'' Initialization
''--------------------------------------------------------------------------------------
const as long screenWidth = 800
const as long screenHeight = 450

SetConfigFlags(FLAG_MSAA_4X_HINT)  '' Enable Multi Sampling Anti Aliasing 4x (if available)
InitWindow(screenWidth, screenHeight, "raylib [shaders] example - lightmap")

'' Define the camera to look into our 3d world
dim as Camera cam
with cam
    .position = Vector3(4.0f, 6.0f, 8.0f)    '' Camera position
    .target = Vector3(0.0f, 0.0f, 0.0f)      '' Camera looking at point
    .up = Vector3(0.0f, 1.0f, 0.0f)          '' Camera up vector (rotation towards target)
    .fovy = 45.0f                            '' Camera field-of-view Y
    .projection = CAMERA_PERSPECTIVE         '' Camera projection type
end with

dim as Mesh msh = GenMeshPlane(MAP_SIZE, MAP_SIZE, 1, 1)

'' GenMeshPlane doesn't generate texcoords2 so we will upload them separately
msh.texcoords2 = allocate(msh.vertexCount * 2 * sizeof(single))

'' X                          '' Y
msh.texcoords2[0] = 0.0f:     msh.texcoords2[1] = 0.0f
msh.texcoords2[2] = 1.0f:     msh.texcoords2[3] = 0.0f
msh.texcoords2[4] = 0.0f:     msh.texcoords2[5] = 1.0f
msh.texcoords2[6] = 1.0f:     msh.texcoords2[7] = 1.0f

'' Load a new texcoords2 attributes buffer
msh.vboId[SHADER_LOC_VERTEX_TEXCOORD02] = rlLoadVertexBuffer(msh.texcoords2, msh.vertexCount * 2 * sizeof(single), RLFALSE)
rlEnableVertexArray(msh.vaoId)

'' Index 5 is for texcoords2
rlSetVertexAttribute(5, 2, RL_FLOAT, 0, 0, 0)
rlEnableVertexAttribute(5)
rlDisableVertexArray()

'' Load lightmap shader
dim as Shader shade = LoadShader(TextFormat("resources/shaders/glsl%i/lightmap.vs", GLSL_VERSION), _
                            TextFormat("resources/shaders/glsl%i/lightmap.fs", GLSL_VERSION))

dim as Texture tex = LoadTexture("resources/cubicmap_atlas.png")
dim as Texture light = LoadTexture("resources/spark_flame.png")

GenTextureMipmaps(@tex)
SetTextureFilter(tex, TEXTURE_FILTER_TRILINEAR)

dim as RenderTexture lightmap = LoadRenderTexture(MAP_SIZE, MAP_SIZE)

SetTextureFilter(lightmap.texture, TEXTURE_FILTER_TRILINEAR)

dim as Material mat = LoadMaterialDefault()
mat.shader = shade
mat.maps[MATERIAL_MAP_ALBEDO].texture = tex
mat.maps[MATERIAL_MAP_METALNESS].texture = lightmap.texture

'' Drawing to lightmap
BeginTextureMode(lightmap)
    ClearBackground(BLACK)

    BeginBlendMode(BLEND_ADDITIVE)
        DrawTexturePro( _
            light, _
            Rectangle(0, 0, light.width, light.height), _
            Rectangle(0, 0, 20, 20), _
            Vector2(10.0, 10.0), _
            0.0, _
            RED _
        )
        DrawTexturePro( _
            light, _
            Rectangle(0, 0, light.width, light.height), _
            Rectangle(8, 4, 20, 20), _
            Vector2(10.0, 10.0), _
            0.0, _
            BLUE _
        )
        DrawTexturePro( _
            light, _
            Rectangle(0, 0, light.width, light.height), _
            Rectangle(8, 8, 10, 10), _
            Vector2(5.0, 5.0), _
            0.0, _
            GREEN _
        )
    BeginBlendMode(BLEND_ALPHA)
EndTextureMode()

SetTargetFPS(60)                   '' Set our game to run at 60 frames-per-second
''--------------------------------------------------------------------------------------

'' Main game loop
do while not WindowShouldClose()        '' Detect window close button or ESC key
    '' Update
    ''----------------------------------------------------------------------------------
    UpdateCamera(@cam, CAMERA_ORBITAL)
    ''----------------------------------------------------------------------------------

    '' Draw
    ''----------------------------------------------------------------------------------
    BeginDrawing()
        ClearBackground(RAYWHITE)

        BeginMode3D(cam)
            DrawMesh(msh, mat, MatrixIdentity())
        EndMode3D()

        DrawFPS(10, 10)

        DrawTexturePro( _
            lightmap.texture, _
            Rectangle(0, 0, -MAP_SIZE, -MAP_SIZE), _
            Rectangle(GetRenderWidth() - MAP_SIZE*8 - 10, 10, MAP_SIZE*8, MAP_SIZE*8), _
            Vector2(0.0, 0.0), _
            0.0, _
            WHITE)
            
        DrawText("lightmap", GetRenderWidth() - 66, 16 + MAP_SIZE*8, 10, GRAY)
        DrawText("10x10 pixels", GetRenderWidth() - 76, 30 + MAP_SIZE*8, 10, GRAY)
            
    EndDrawing()
    ''----------------------------------------------------------------------------------
loop

'' De-Initialization
''--------------------------------------------------------------------------------------
UnloadMesh(msh)       '' Unload the mesh
UnloadShader(shade)   '' Unload shader
UnloadTexture(tex) '' Unload texture
UnloadTexture(light)   '' Unload texture

CloseWindow()          '' Close window and OpenGL context
''--------------------------------------------------------------------------------------