/'******************************************************************************************
*
*   raylib [models] example - Mesh picking in 3d mode, ground plane, triangle, mesh
*
*   Example originally created with raylib 1.7, last time updated with raylib 4.0
*
*   Example contributed by Joel Davis (@joeld42) and reviewed by Ramon Santamaria (@raysan5)
*
*   Example licensed under an unmodified zlib/libpng license, which is an OSI-certified,
*   BSD-like license that allows static linking with closed source software
*
*   Copyright (c) 2017-2024 Joel Davis (@joeld42) and Ramon Santamaria (@raysan5)
*
*******************************************************************************************'/

#include "../../raylib.bi"

#define FLT_MAX     3.402823e+38     '' Maximum value of a single

'' Initialization
''--------------------------------------------------------------------------------------
const as long screenWidth = 800
const as long screenHeight = 450

InitWindow(screenWidth, screenHeight, "raylib [models] example - mesh picking")

'' Define the camera to look into our 3d world
dim as Camera cam
with cam
    .position = Vector3(20.0f, 20.0f, 20.0f) '' Camera position
    .target = Vector3(0.0f, 8.0f, 0.0f)      '' Camera looking at point
    .up = Vector3(0.0f, 1.6f, 0.0f)          '' Camera up vector (rotation towards target)
    .fovy = 45.0f                            '' Camera field-of-view Y
    .projection = CAMERA_PERSPECTIVE         '' Camera projection type
end with

dim as Ray rayPick        '' Picking ray

dim as Model tower = LoadModel("resources/models/obj/turret.obj")                 '' Load OBJ model
dim as Texture2D texture = LoadTexture("resources/models/obj/turret_diffuse.png") '' Load model texture
tower.materials[0].maps[MATERIAL_MAP_DIFFUSE].texture = texture            '' Set model diffuse texture

dim as Vector3 towerPos = Vector3(0.0f, 0.0f, 0.0f)                        '' Set model position
dim as BoundingBox towerBBox = GetMeshBoundingBox(tower.meshes[0])    '' Get mesh bounding box

'' Ground quad
dim as Vector3 g0 = Vector3(-50.0f, 0.0f, -50.0f)
dim as Vector3 g1 = Vector3(-50.0f, 0.0f,  50.0f)
dim as Vector3 g2 = Vector3( 50.0f, 0.0f,  50.0f)
dim as Vector3 g3 = Vector3( 50.0f, 0.0f, -50.0f)

'' Test triangle
dim as Vector3 ta = Vector3(-25.0f, 0.5f, 0.0f)
dim as Vector3 tb = Vector3( -4.0f, 2.5f, 1.0f)
dim as Vector3 tc = Vector3( -8.0f, 6.5f, 0.0f)

dim as Vector3 bary = Vector3(0.0f, 0.0f, 0.0f)

'' Test sphere
dim as Vector3 sp = Vector3(-30.0f, 5.0f, 5.0f)
dim as single sr = 4.0f

SetTargetFPS(60)                   '' Set our game to run at 60 frames-per-second
''--------------------------------------------------------------------------------------
'' Main game loop
do while not WindowShouldClose()        '' Detect window close button or ESC key
    '' Update
    ''----------------------------------------------------------------------------------
    if IsCursorHidden() then UpdateCamera(@cam, CAMERA_FIRST_PERSON)          '' Update camera

    '' Toggle camera controls
    if IsMouseButtonPressed(MOUSE_BUTTON_RIGHT) then
        if IsCursorHidden() then
            EnableCursor()
        else 
            DisableCursor()
        end if
    end if

    '' Display information about closest hit
    dim as RayCollision collision
    dim as zstring * 128 hitObjectName = "None"
    collision.distance = FLT_MAX
    collision.hit = false
    dim as RLColor cursorColor = WHITE

    '' Get ray and test against objects
    rayPick = GetScreenToWorldRay(GetMousePosition(), cam)

    '' Check ray collision against ground quad
    dim as RayCollision groundHitInfo = GetRayCollisionQuad(rayPick, g0, g1, g2, g3)

    if (groundHitInfo.hit = RLTRUE) and (groundHitInfo.distance < collision.distance) then
        collision = groundHitInfo
        cursorColor = GREEN
        hitObjectName = "Ground"
    end if

    '' Check ray collision against test triangle
    dim as RayCollision triHitInfo = GetRayCollisionTriangle(rayPick, ta, tb, tc)

    if (triHitInfo.hit = RLTRUE) and (triHitInfo.distance < collision.distance) then
        collision = triHitInfo
        cursorColor = PURPLE
        hitObjectName = "Triangle"

        bary = Vector3Barycenter(collision.point, ta, tb, tc)
    end if

    '' Check ray collision against test sphere
    dim as RayCollision sphereHitInfo = GetRayCollisionSphere(rayPick, sp, sr)

    if (sphereHitInfo.hit = RLTRUE) and (sphereHitInfo.distance < collision.distance) then
        collision = sphereHitInfo
        cursorColor = ORANGE
        hitObjectName = "Sphere"
    end if

    '' Check ray collision against bounding box first, before trying the full ray-mesh test
    dim as RayCollision boxHitInfo = GetRayCollisionBox(rayPick, towerBBox)

    if (boxHitInfo.hit = RLTRUE) and (boxHitInfo.distance < collision.distance) then
        collision = boxHitInfo
        cursorColor = ORANGE
        hitObjectName = "Box"

        '' Check ray collision against model meshes
        dim as RayCollision meshHitInfo
        for m as integer = 0 to tower.meshCount -1
            '' NOTE: We consider the model.transform for the collision check but 
            '' it can be checked against any transform Matrix, used when checking against same
            '' model drawn multiple times with multiple transforms
            meshHitInfo = GetRayCollisionMesh(rayPick, tower.meshes[m], tower.transform)
            if meshHitInfo.hit = RLTrue then
                '' Save the closest hit mesh
                if (collision.hit = RLFALSE) or (collision.distance > meshHitInfo.distance) then collision = meshHitInfo
                
                exit for  '' Stop once one mesh collision is detected, the colliding mesh is m
            end if
        next

        if meshHitInfo.hit = RLTRUE then
            collision = meshHitInfo
            cursorColor = ORANGE
            hitObjectName = "Mesh"
        end if
    end if
    ''----------------------------------------------------------------------------------

    '' Draw
    ''----------------------------------------------------------------------------------
    BeginDrawing()

        ClearBackground(RAYWHITE)

        BeginMode3D(cam)

            '' Draw the tower
            '' WARNING: If scale is different than 1.0f,
            '' not considered by GetRayCollisionModel()
            DrawModel(tower, towerPos, 1.0f, WHITE)

            '' Draw the test triangle
            DrawLine3D(ta, tb, PURPLE)
            DrawLine3D(tb, tc, PURPLE)
            DrawLine3D(tc, ta, PURPLE)

            '' Draw the test sphere
            DrawSphereWires(sp, sr, 8, 8, PURPLE)

            '' Draw the mesh bbox if we hit it
            if boxHitInfo.hit = RLTRUE then DrawBoundingBox(towerBBox, LIME)

            '' If we hit something, draw the cursor at the hit point
            if collision.hit = RLTRUE then
                DrawCube(collision.point, 0.3f, 0.3f, 0.3f, cursorColor)
                DrawCubeWires(collision.point, 0.3f, 0.3f, 0.3f, RED)

                dim as Vector3 normalEnd
                normalEnd.x = collision.point.x + collision.normal.x
                normalEnd.y = collision.point.y + collision.normal.y
                normalEnd.z = collision.point.z + collision.normal.z

                DrawLine3D(collision.point, normalEnd, RED)
            end if

            DrawRay(rayPick, MAROON)

            DrawGrid(10, 10.0f)

        EndMode3D()

        '' Draw some debug GUI text
        DrawText(TextFormat("Hit Object: %s", hitObjectName), 10, 50, 10, BLACK)

        if collision.hit = RLTRUE then
            dim as long ypos = 70

            DrawText(TextFormat("Distance: %3.2f", collision.distance), 10, ypos, 10, BLACK)

            DrawText(TextFormat("Hit Pos: %3.2f %3.2f %3.2f",_
                                collision.point.x,_
                                collision.point.y,_
                                collision.point.z), 10, ypos + 15, 10, BLACK)

            DrawText(TextFormat("Hit Norm: %3.2f %3.2f %3.2f",_
                                collision.normal.x,_
                                collision.normal.y,_
                                collision.normal.z), 10, ypos + 30, 10, BLACK)

            if triHitInfo.hit = RLTRUE and TextIsEqual(hitObjectName, "Triangle") then
                DrawText(TextFormat("Barycenter: %3.2f %3.2f %3.2f",  bary.x, bary.y, bary.z), 10, ypos + 45, 10, BLACK)
            end if
        end if

        DrawText("Right click mouse to toggle camera controls", 10, 430, 10, GRAY)

        DrawText("(c) Turret 3D model by Alberto Cano", screenWidth - 200, screenHeight - 20, 10, GRAY)

        DrawFPS(10, 10)

    EndDrawing()
    ''----------------------------------------------------------------------------------
loop

'' De-Initialization
''--------------------------------------------------------------------------------------
UnloadModel(tower)         '' Unload model
UnloadTexture(texture)     '' Unload texture

CloseWindow()              '' Close window and OpenGL context
''--------------------------------------------------------------------------------------