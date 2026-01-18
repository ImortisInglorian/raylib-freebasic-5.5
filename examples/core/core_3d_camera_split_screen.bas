/'******************************************************************************************
*
*   raylib [core] example - 3d cmaera split screen
*
*   Example originally created with raylib 3.7, last time updated with raylib 4.0
*
*   Example contributed by Jeffery Myers (@JeffM2501) and reviewed by Ramon Santamaria (@raysan5)
*
*   Example licensed under an unmodified zlib/libpng license, which is an OSI-certified,
*   BSD-like license that allows static linking with closed source software
*
*   Copyright (c) 2021-2024 Jeffery Myers (@JeffM2501)
*
*******************************************************************************************'/

#include "../../raylib.bi"

'' Initialization
''--------------------------------------------------------------------------------------
const as long screenWidth = 800
const as long screenHeight = 450

InitWindow(screenWidth, screenHeight, "raylib [core] example - 3d camera split screen")

'' Setup player 1 camera and screen
dim as Camera cameraPlayer1
with cameraPlayer1
    .fovy = 45.0f
    .up.y = 1.0f
    .target.y = 1.0f
    .position.z = -3.0f
    .position.y = 1.0f
end with

dim as RenderTexture screenPlayer1 = LoadRenderTexture(screenWidth/2, screenHeight)

'' Setup player two camera and screen
dim as Camera cameraPlayer2
with cameraPlayer2
    .fovy = 45.0f
    .up.y = 1.0f
    .target.y = 3.0f
    .position.x = -3.0f
    .position.y = 3.0f
end with

dim as RenderTexture screenPlayer2 = LoadRenderTexture(screenWidth / 2, screenHeight)

'' Build a flipped rectangle the size of the split view to use for drawing later
dim as Rectangle splitScreenRect = Rectangle(0.0f, 0.0f, screenPlayer1.texture.width, -screenPlayer1.texture.height)

'' Grid data
dim as long count = 5
dim as single spacing = 4

SetTargetFPS(60)               '' Set our game to run at 60 frames-per-second
''--------------------------------------------------------------------------------------

'' Main game loop
do while not WindowShouldClose()    '' Detect window close button or ESC key
    '' Update
    ''----------------------------------------------------------------------------------
    '' If anyone moves this frame, how far will they move based on the time since the last frame
    '' this moves thigns at 10 world units per second, regardless of the actual FPS
    dim as single offsetThisFrame = 10.0f * GetFrameTime()

    '' Move Player1 forward and backwards (no turning)
    if IsKeyDown(KEY_W) then
        cameraPlayer1.position.z += offsetThisFrame
        cameraPlayer1.target.z += offsetThisFrame
    elseif IsKeyDown(KEY_S) then
        cameraPlayer1.position.z -= offsetThisFrame
        cameraPlayer1.target.z -= offsetThisFrame
    end if

    '' Move Player2 forward and backwards (no turning)
    if IsKeyDown(KEY_UP) then
        cameraPlayer2.position.x += offsetThisFrame
        cameraPlayer2.target.x += offsetThisFrame
    elseif IsKeyDown(KEY_DOWN) then
        cameraPlayer2.position.x -= offsetThisFrame
        cameraPlayer2.target.x -= offsetThisFrame
    end if
    ''----------------------------------------------------------------------------------

    '' Draw
    ''----------------------------------------------------------------------------------
    '' Draw Player1 view to the render texture
    BeginTextureMode(screenPlayer1)
        ClearBackground(SKYBLUE)
        
        BeginMode3D(cameraPlayer1)
        
            '' Draw scene: grid of cube trees on a plane to make a "world"
            DrawPlane(Vector3(0, 0, 0), Vector2(50, 50), BEIGE) '' Simple world plane

            for x as single = -count*spacing to count*spacing step spacing
                for z as single = -count*spacing to count*spacing step spacing
                    DrawCube(Vector3(x, 1.5f, z), 1, 1, 1, LIME)
                    DrawCube(Vector3(x, 0.5f, z), 0.25f, 1, 0.25f, BROWN)
                next
            next

            '' Draw a cube at each player's position
            DrawCube(cameraPlayer1.position, 1, 1, 1, RED)
            DrawCube(cameraPlayer2.position, 1, 1, 1, BLUE)
            
        EndMode3D()
        
        DrawRectangle(0, 0, GetScreenWidth()/2, 40, Fade(RAYWHITE, 0.8f))
        DrawText("PLAYER1: W/S to move", 10, 10, 20, MAROON)
        
    EndTextureMode()

    '' Draw Player2 view to the render texture
    BeginTextureMode(screenPlayer2)
        ClearBackground(SKYBLUE)
        
        BeginMode3D(cameraPlayer2)
        
            '' Draw scene: grid of cube trees on a plane to make a "world"
            DrawPlane(Vector3(0, 0, 0), Vector2(50, 50), BEIGE) '' Simple world plane

            for x as single = -count*spacing to count*spacing step spacing
                for z as single = -count*spacing to count*spacing step spacing
                    DrawCube(Vector3(x, 1.5f, z), 1, 1, 1, LIME)
                    DrawCube(Vector3(x, 0.5f, z), 0.25f, 1, 0.25f, BROWN)
                next
            next

            '' Draw a cube at each player's position
            DrawCube(cameraPlayer1.position, 1, 1, 1, RED)
            DrawCube(cameraPlayer2.position, 1, 1, 1, BLUE)
            
        EndMode3D()
        
        DrawRectangle(0, 0, GetScreenWidth()/2, 40, Fade(RAYWHITE, 0.8f))
        DrawText("PLAYER2: UP/DOWN to move", 10, 10, 20, DARKBLUE)
        
    EndTextureMode()

    '' Draw both views render textures to the screen side by side
    BeginDrawing()
        ClearBackground(BLACK)
        
        DrawTextureRec(screenPlayer1.texture, splitScreenRect, Vector2(0, 0), WHITE)
        DrawTextureRec(screenPlayer2.texture, splitScreenRect, Vector2(screenWidth/2.0f, 0), WHITE)
        
        DrawRectangle(GetScreenWidth()/2 - 2, 0, 4, GetScreenHeight(), LIGHTGRAY)
    EndDrawing()
loop

'' De-Initialization
''--------------------------------------------------------------------------------------
UnloadRenderTexture(screenPlayer1) '' Unload render texture
UnloadRenderTexture(screenPlayer2) '' Unload render texture

CloseWindow()                      '' Close window and OpenGL context
''--------------------------------------------------------------------------------------