/'******************************************************************************************
*
*   raylib [models] example - Detect basic 3d collisions (box vs sphere vs box)
*
*   Example originally created with raylib 1.3, last time updated with raylib 3.5
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

InitWindow(screenWidth, screenHeight, "raylib [models] example - box collisions")

'' Define the camera to look into our 3d world
dim as Camera cam = Camera(Vector3(0.0f, 10.0f, 10.0f), Vector3(0.0f, 0.0f, 0.0f), Vector3(0.0f, 1.0f, 0.0f), 45.0f, 0)

dim as Vector3 playerPosition = Vector3(0.0f, 1.0f, 2.0f)
dim as Vector3 playerSize = Vector3(1.0f, 2.0f, 1.0f)
dim as RLColor playerColor = GREEN

dim as Vector3 enemyBoxPos = Vector3(-4.0f, 1.0f, 0.0f)
dim as Vector3 enemyBoxSize = Vector3(2.0f, 2.0f, 2.0f)

dim as Vector3 enemySpherePos = Vector3(4.0f, 0.0f, 0.0f)
dim as single enemySphereSize = 1.5f

dim as boolean collision = false

SetTargetFPS(60)               '' Set our game to run at 60 frames-per-second
''--------------------------------------------------------------------------------------

'' Main game loop
do while not WindowShouldClose()    '' Detect window close button or ESC key
    '' Update
    ''----------------------------------------------------------------------------------

    '' Move player
    if IsKeyDown(KEY_RIGHT) then 
        playerPosition.x += 0.2f
    elseif IsKeyDown(KEY_LEFT) then
        playerPosition.x -= 0.2f
    elseif IsKeyDown(KEY_DOWN) then
        playerPosition.z += 0.2f
    elseif IsKeyDown(KEY_UP) then
        playerPosition.z -= 0.2f
    end if

    collision = false

    '' Check collisions player vs enemy-box
    if CheckCollisionBoxes( _
        BoundingBox(_    
            Vector3(playerPosition.x - playerSize.x/2,_
                    playerPosition.y - playerSize.y/2,_
                    playerPosition.z - playerSize.z/2),_
            Vector3(playerPosition.x + playerSize.x/2,_
                    playerPosition.y + playerSize.y/2,_
                    playerPosition.z + playerSize.z/2 )),_
        BoundingBox(_
            Vector3(enemyBoxPos.x - enemyBoxSize.x/2,_
                    enemyBoxPos.y - enemyBoxSize.y/2,_
                    enemyBoxPos.z - enemyBoxSize.z/2),_
            Vector3(enemyBoxPos.x + enemyBoxSize.x/2,_
                    enemyBoxPos.y + enemyBoxSize.y/2,_
                    enemyBoxPos.z + enemyBoxSize.z/2 ))) then collision = true

    '' Check collisions player vs enemy-sphere
    if CheckCollisionBoxSphere(_
        BoundingBox(Vector3(playerPosition.x - playerSize.x/2,_
                                    playerPosition.y - playerSize.y/2,_
                                    playerPosition.z - playerSize.z/2 ),_
                        Vector3(playerPosition.x + playerSize.x/2,_
                                    playerPosition.y + playerSize.y/2,_
                                    playerPosition.z + playerSize.z/2 )),_
        enemySpherePos, enemySphereSize) then collision = true

    if collision then
        playerColor = RED
    else 
        playerColor = GREEN
    end if
    ''----------------------------------------------------------------------------------

    '' Draw
    ''----------------------------------------------------------------------------------
    BeginDrawing()

        ClearBackground(RAYWHITE)

        BeginMode3D(cam)

            '' Draw enemy-box
            DrawCube(enemyBoxPos, enemyBoxSize.x, enemyBoxSize.y, enemyBoxSize.z, GRAY)
            DrawCubeWires(enemyBoxPos, enemyBoxSize.x, enemyBoxSize.y, enemyBoxSize.z, DARKGRAY)

            '' Draw enemy-sphere
            DrawSphere(enemySpherePos, enemySphereSize, GRAY)
            DrawSphereWires(enemySpherePos, enemySphereSize, 16, 16, DARKGRAY)

            '' Draw player
            DrawCubeV(playerPosition, playerSize, playerColor)

            DrawGrid(10, 1.0f)        '' Draw a grid

        EndMode3D()

        DrawText("Move player with arrow keys to collide", 220, 40, 20, GRAY)

        DrawFPS(10, 10)

    EndDrawing()
    ''----------------------------------------------------------------------------------
loop

'' De-Initialization
''--------------------------------------------------------------------------------------
CloseWindow()        '' Close window and OpenGL context
''--------------------------------------------------------------------------------------