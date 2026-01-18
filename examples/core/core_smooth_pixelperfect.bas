/'******************************************************************************************
*
*   raylib [core] example - Smooth Pixel-perfect camera
*
*   Example originally created with raylib 3.7, last time updated with raylib 4.0
*   
*   Example contributed by Giancamillo Alessandroni (@NotManyIdeasDev) and
*   reviewed by Ramon Santamaria (@raysan5)
*
*   Example licensed under an unmodified zlib/libpng license, which is an OSI-certified,
*   BSD-like license that allows static linking with closed source software
*
*   Copyright (c) 2021-2024 Giancamillo Alessandroni (@NotManyIdeasDev) and Ramon Santamaria (@raysan5)
*
*******************************************************************************************'/

#include "../../raylib.bi"

#include "crt/math.bi"       '' Required for: sinf(), cosf()

'' Initialization
''--------------------------------------------------------------------------------------
const as long screenWidth = 800
const as long screenHeight = 450

const as long virtualScreenWidth = 160
const as long virtualScreenHeight = 90

const as single virtualRatio = screenWidth/virtualScreenWidth

InitWindow(screenWidth, screenHeight, "raylib [core] example - smooth pixel-perfect camera")

dim as Camera2D worldSpaceCamera  '' Game world camera
worldSpaceCamera.zoom = 1.0f

dim as Camera2D screenSpaceCamera  '' Smoothing camera
screenSpaceCamera.zoom = 1.0f

dim as RenderTexture2D target = LoadRenderTexture(virtualScreenWidth, virtualScreenHeight) '' This is where we'll draw all our objects.

dim as Rectangle rec01 = Rectangle(70.0f, 35.0f, 20.0f, 20.0f)
dim as Rectangle rec02 = Rectangle(90.0f, 55.0f, 30.0f, 10.0f)
dim as Rectangle rec03 = Rectangle(80.0f, 65.0f, 15.0f, 25.0f)

'' The target's height is flipped (in the source Rectangle), due to OpenGL reasons
dim as Rectangle sourceRec = Rectangle(0.0f, 0.0f, target.texture.width, -target.texture.height)
dim as Rectangle destRec = Rectangle(-virtualRatio, -virtualRatio, screenWidth + (virtualRatio*2), screenHeight + (virtualRatio*2))

dim as Vector2 origin = Vector2(0.0f, 0.0f)

dim as single rotation = 0.0f

dim as single cameraX = 0.0f
dim as single cameraY = 0.0f

SetTargetFPS(60)
''--------------------------------------------------------------------------------------

'' Main game loop
do while not WindowShouldClose()    '' Detect window close button or ESC key
    '' Update
    ''----------------------------------------------------------------------------------
    rotation += 60.0f*GetFrameTime()   '' Rotate the rectangles, 60 degrees per second

    '' Make the camera move to demonstrate the effect
    cameraX = (sinf(GetTime())*50.0f) - 10.0f
    cameraY = cosf(GetTime())*30.0f

    '' Set the camera's target to the values computed above
    screenSpaceCamera.target = Vector2(cameraX, cameraY)

    '' Round worldSpace coordinates, keep decimals into screenSpace coordinates
    worldSpaceCamera.target.x = truncf(screenSpaceCamera.target.x)
    screenSpaceCamera.target.x -= worldSpaceCamera.target.x
    screenSpaceCamera.target.x *= virtualRatio

    worldSpaceCamera.target.y = truncf(screenSpaceCamera.target.y)
    screenSpaceCamera.target.y -= worldSpaceCamera.target.y
    screenSpaceCamera.target.y *= virtualRatio
    ''----------------------------------------------------------------------------------

    '' Draw
    ''----------------------------------------------------------------------------------
    BeginTextureMode(target)
        ClearBackground(RAYWHITE)

        BeginMode2D(worldSpaceCamera)
            DrawRectanglePro(rec01, origin, rotation, BLACK)
            DrawRectanglePro(rec02, origin, -rotation, RED)
            DrawRectanglePro(rec03, origin, rotation + 45.0f, BLUE)
        EndMode2D()
    EndTextureMode()

    BeginDrawing()
        ClearBackground(RED)

        BeginMode2D(screenSpaceCamera)
            DrawTexturePro(target.texture, sourceRec, destRec, origin, 0.0f, WHITE)
        EndMode2D()

        DrawText(TextFormat("Screen resolution: %ix%i", screenWidth, screenHeight), 10, 10, 20, DARKBLUE)
        DrawText(TextFormat("World resolution: %ix%i", virtualScreenWidth, virtualScreenHeight), 10, 40, 20, DARKGREEN)
        DrawFPS(GetScreenWidth() - 95, 10)
    EndDrawing()
    ''----------------------------------------------------------------------------------
loop

'' De-Initialization
''--------------------------------------------------------------------------------------
UnloadRenderTexture(target)    '' Unload render texture

CloseWindow()                  '' Close window and OpenGL context
''--------------------------------------------------------------------------------------