/'******************************************************************************************
*
*   raylib example - point rendering
*
*   Example originally created with raylib 5.0, last time updated with raylib 5.0
*
*   Example contributed by Reese Gallagher (@satchelfrost) and reviewed by Ramon Santamaria (@raysan5)
*
*   Example licensed under an unmodified zlib/libpng license, which is an OSI-certified,
*   BSD-like license that allows static linking with closed source software
*
*   Copyright (c) 2024 Reese Gallagher (@satchelfrost)
*
*******************************************************************************************'/

#include "../../raylib.bi"

randomize timer

#define MAX_POINTS 10000000     '' 10 million
#define MIN_POINTS 1000         '' 1 thousand

''Define RAND_MAX as it doesn't exist in FB's CRT headers
#define RAND_MAX 32767

'' Generate mesh using points
declare function GenMeshPoints(numPoints as long) as Mesh

''------------------------------------------------------------------------------------
'' Program main entry point
''------------------------------------------------------------------------------------
'' Initialization
''--------------------------------------------------------------------------------------
const as long screenWidth = 800
const as long screenHeight = 450

InitWindow(screenWidth, screenHeight, "raylib [models] example - point rendering")

dim as Camera cam
with cam
    .position   = Vector3(3.0f, 3.0f, 3.0f)
    .target     = Vector3(0.0f, 0.0f, 0.0f)
    .up         = Vector3(0.0f, 1.0f, 0.0f)
    .fovy       = 45.0f
    .projection = CAMERA_PERSPECTIVE
end with

dim as Vector3 position = Vector3(0.0f, 0.0f, 0.0f)
dim as boolean useDrawModelPoints = true
dim as boolean numPointsChanged = false
dim as long numPoints = 1000

dim as Mesh msh = GenMeshPoints(numPoints)
dim as Model mdl = LoadModelFromMesh(msh)

''SetTargetFPS(60)
''--------------------------------------------------------------------------------------

'' Main game loop
do while not WindowShouldClose()
    '' Update
    ''----------------------------------------------------------------------------------
    UpdateCamera(@cam, CAMERA_ORBITAL)

    if IsKeyPressed(KEY_SPACE) then useDrawModelPoints = not useDrawModelPoints
    if IsKeyPressed(KEY_UP) then
        numPoints = iif(numPoints*10 > MAX_POINTS, MAX_POINTS, numPoints * 10)
        numPointsChanged = true
    end if
    if IsKeyPressed(KEY_DOWN) then
        numPoints = iif(numPoints/10 < MIN_POINTS, MIN_POINTS, numPoints / 10)
        numPointsChanged = true
    end if

    '' Upload a different point cloud size
    if numPointsChanged then
        UnloadModel(mdl)
        msh = GenMeshPoints(numPoints)
        mdl = LoadModelFromMesh(msh)
        numPointsChanged = false
    end if
    ''----------------------------------------------------------------------------------

    '' Draw
    ''----------------------------------------------------------------------------------
    BeginDrawing()
        ClearBackground(BLACK)

        BeginMode3D(cam)

            '' The new method only uploads the points once to the GPU
            if useDrawModelPoints then
                DrawModelPoints(mdl, position, 1.0f, WHITE)
            else
                '' The old method must continually draw the "points" (lines)
                for i as integer = 0 to numPoints - 1
                    dim as Vector3 poss = Vector3( msh.vertices[i*3 + 0], msh.vertices[i*3 + 1], msh.vertices[i*3 + 2])
                    dim as RLColor clr =RLColor(msh.colors[i*4 + 0], msh.colors[i*4 + 1], msh.colors[i*4 + 2], msh.colors[i*4 + 3])
                    
                    DrawPoint3D(poss, clr)
                next
            end if

            '' Draw a unit sphere for reference
            DrawSphereWires(position, 1.0f, 10, 10, YELLOW)
            
        EndMode3D()

        '' Draw UI text
        DrawText(TextFormat("Point Count: %d", numPoints), 20, screenHeight - 50, 40, WHITE)
        DrawText("Up - increase points", 20, 70, 20, WHITE)
        DrawText("Down - decrease points", 20, 100, 20, WHITE)
        DrawText("Space - drawing function", 20, 130, 20, WHITE)
        
        if useDrawModelPoints then
            DrawText("Using: DrawModelPoints()", 20, 160, 20, GREEN)
        else 
            DrawText("Using: DrawPoint3D()", 20, 160, 20, RED)
        end if
        
        DrawFPS(10, 10)
        
    EndDrawing()
    ''----------------------------------------------------------------------------------
loop

'' De-Initialization
''--------------------------------------------------------------------------------------
UnloadModel(model)

CloseWindow()
''--------------------------------------------------------------------------------------

'' Generate a spherical point cloud
function GenMeshPoints(numPoints as long) as Mesh
    dim as Mesh msh
    with msh
        .triangleCount = 1
        .vertexCount = numPoints
        .vertices = MemAlloc(numPoints * 3 * sizeof(single))
        .colors = MemAlloc(numPoints * 4 *sizeof(ubyte))
    end with

    '' https:''en.wikipedia.org/wiki/Spherical_coordinate_system
    for i as integer = 0 to numPoints - 1
        dim as single theta = PI * rnd
        dim as single phi = 2.0f * PI * rnd
        dim as single r = 10.0f * rnd
        
        msh.vertices[i * 3 + 0] = r * sin(theta) * cos(phi)
        msh.vertices[i * 3 + 1] = r * sin(theta) * sin(phi)
        msh.vertices[i * 3 + 2] = r * cos(theta)
        
        dim as RLColor clr = ColorFromHSV(r * 360.0f, 1.0f, 1.0f)
        
        msh.colors[i * 4 + 0] = clr.r
        msh.colors[i * 4 + 1] = clr.g
        msh.colors[i * 4 + 2] = clr.b
        msh.colors[i * 4 + 3] = clr.a
    next

    '' Upload mesh data from CPU (RAM) to GPU (VRAM) memory
    UploadMesh(@msh, RLFALSE)
    
    return msh
end function