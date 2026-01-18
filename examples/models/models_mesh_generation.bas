/'******************************************************************************************
*
*   raylib example - procedural mesh generation
*
*   Example originally created with raylib 1.8, last time updated with raylib 4.0
*
*   Example licensed under an unmodified zlib/libpng license, which is an OSI-certified,
*   BSD-like license that allows static linking with closed source software
*
*   Copyright (c) 2017-2024 Ramon Santamaria (@raysan5)
*
*******************************************************************************************'/

#include "../../raylib.bi"

#define NUM_MODELS  9               '' Parametric 3d shapes to generate

declare function GenMeshCustom() as Mesh    '' Generate a simple triangle mesh from code

''------------------------------------------------------------------------------------
'' Program main entry point
''------------------------------------------------------------------------------------
'' Initialization
''--------------------------------------------------------------------------------------
const as long screenWidth = 800
const as long screenHeight = 450

InitWindow(screenWidth, screenHeight, "raylib [models] example - mesh generation")

'' We generate a checked image for texturing
dim as Image checked = GenImageChecked(2, 2, 1, 1, RED, GREEN)
dim as Texture2D texture = LoadTextureFromImage(checked)
UnloadImage(checked)

dim as Model models(NUM_MODELS - 1)

models(0) = LoadModelFromMesh(GenMeshPlane(2, 2, 4, 3))
models(1) = LoadModelFromMesh(GenMeshCube(2.0f, 1.0f, 2.0f))
models(2) = LoadModelFromMesh(GenMeshSphere(2, 32, 32))
models(3) = LoadModelFromMesh(GenMeshHemiSphere(2, 16, 16))
models(4) = LoadModelFromMesh(GenMeshCylinder(1, 2, 16))
models(5) = LoadModelFromMesh(GenMeshTorus(0.25f, 4.0f, 16, 32))
models(6) = LoadModelFromMesh(GenMeshKnot(1.0f, 2.0f, 16, 128))
models(7) = LoadModelFromMesh(GenMeshPoly(5, 2.0f))
models(8) = LoadModelFromMesh(GenMeshCustom())

'' Generated meshes could be exported as .obj files
''ExportMesh(models[0].meshes[0], "plane.obj")
''ExportMesh(models[1].meshes[0], "cube.obj")
''ExportMesh(models[2].meshes[0], "sphere.obj")
''ExportMesh(models[3].meshes[0], "hemisphere.obj")
''ExportMesh(models[4].meshes[0], "cylinder.obj")
''ExportMesh(models[5].meshes[0], "torus.obj")
''ExportMesh(models[6].meshes[0], "knot.obj")
''ExportMesh(models[7].meshes[0], "poly.obj")
''ExportMesh(models[8].meshes[0], "custom.obj")

'' Set checked texture as default diffuse component for all models material
for i as integer = 0 to NUM_MODELS - 1
    models(i).materials[0].maps[MATERIAL_MAP_DIFFUSE].texture = texture
next

'' Define the camera to look into our 3d world
dim as Camera cam = Camera(Vector3(5.0f, 5.0f, 5.0f), Vector3(0.0f, 0.0f, 0.0f), Vector3(0.0f, 1.0f, 0.0f), 45.0f, 0)

'' Model drawing position
dim as Vector3 position = Vector3(0.0f, 0.0f, 0.0f)

dim as long currentModel = 0

SetTargetFPS(60)               '' Set our game to run at 60 frames-per-second
''--------------------------------------------------------------------------------------

'' Main game loop
do while not WindowShouldClose()    '' Detect window close button or ESC key
    '' Update
    ''----------------------------------------------------------------------------------
    UpdateCamera(@cam, CAMERA_ORBITAL)

    if IsMouseButtonPressed(MOUSE_BUTTON_LEFT) then
        currentModel = (currentModel + 1) mod NUM_MODELS '' Cycle between the textures
    end if

    if IsKeyPressed(KEY_RIGHT) then
        currentModel += 1
        if currentModel >= NUM_MODELS then currentModel = 0
    elseif IsKeyPressed(KEY_LEFT) then
        currentModel -= 1
        if currentModel < 0 then currentModel = NUM_MODELS - 1
    end if
    ''----------------------------------------------------------------------------------

    '' Draw
    ''----------------------------------------------------------------------------------
    BeginDrawing()

        ClearBackground(RAYWHITE)

        BeginMode3D(cam)

            DrawModel(models(currentModel), position, 1.0f, WHITE)
            DrawGrid(10, 1.0)

        EndMode3D()

        DrawRectangle(30, 400, 310, 30, Fade(SKYBLUE, 0.5f))
        DrawRectangleLines(30, 400, 310, 30, Fade(DARKBLUE, 0.5f))
        DrawText("MOUSE LEFT BUTTON to CYCLE PROCEDURAL MODELS", 40, 410, 10, BLUE)

        select case currentModel
            case 0
                DrawText("PLANE", 680, 10, 20, DARKBLUE)
            case 1
                DrawText("CUBE", 680, 10, 20, DARKBLUE)
            case 2
                DrawText("SPHERE", 680, 10, 20, DARKBLUE)
            case 3 
                DrawText("HEMISPHERE", 640, 10, 20, DARKBLUE)
            case 4
                DrawText("CYLINDER", 680, 10, 20, DARKBLUE)
            case 5
                DrawText("TORUS", 680, 10, 20, DARKBLUE)
            case 6
                DrawText("KNOT", 680, 10, 20, DARKBLUE)
            case 7
                DrawText("POLY", 680, 10, 20, DARKBLUE)
            case 8
                DrawText("Custom (triangle)", 580, 10, 20, DARKBLUE)
        end select

    EndDrawing()
    ''----------------------------------------------------------------------------------
loop

'' De-Initialization
''--------------------------------------------------------------------------------------
UnloadTexture(texture) '' Unload texture

'' Unload models data (GPU VRAM)
for i as integer = 0 to NUM_MODELS - 1
    UnloadModel(models(i))
next

CloseWindow()          '' Close window and OpenGL context
''--------------------------------------------------------------------------------------

'' Generate a simple triangle mesh from code
function GenMeshCustom() as Mesh
    dim as Mesh msh
    msh.triangleCount = 1
    msh.vertexCount = msh.triangleCount * 3
    msh.vertices = MemAlloc(msh.vertexCount * 3 * sizeof(single))    '' 3 vertices, 3 coordinates each (x, y, z)
    msh.texcoords = MemAlloc(msh.vertexCount * 2 * sizeof(single))   '' 3 vertices, 2 coordinates each (x, y)
    msh.normals = MemAlloc(msh.vertexCount * 3 * sizeof(single))     '' 3 vertices, 3 coordinates each (x, y, z)

    '' Vertex at (0, 0, 0)
    msh.vertices[0] = 0
    msh.vertices[1] = 0
    msh.vertices[2] = 0
    msh.normals[0] = 0
    msh.normals[1] = 1
    msh.normals[2] = 0
    msh.texcoords[0] = 0
    msh.texcoords[1] = 0

    '' Vertex at (1, 0, 2)
    msh.vertices[3] = 1
    msh.vertices[4] = 0
    msh.vertices[5] = 2
    msh.normals[3] = 0
    msh.normals[4] = 1
    msh.normals[5] = 0
    msh.texcoords[2] = 0.5f
    msh.texcoords[3] = 1.0f

    '' Vertex at (2, 0, 0)
    msh.vertices[6] = 2
    msh.vertices[7] = 0
    msh.vertices[8] = 0
    msh.normals[6] = 0
    msh.normals[7] = 1
    msh.normals[8] = 0
    msh.texcoords[4] = 1
    msh.texcoords[5] =0

    '' Upload mesh data from CPU (RAM) to GPU (VRAM) memory
    UploadMesh(@msh, false)

    return msh
end function
