/'******************************************************************************************
*
*   raylib [core] example - 2d camera
*
*   Example complexity rating: [★★☆☆] 2/4
*
*   Example originally created with raylib 1.5, last time updated with raylib 3.0
*
*   Example licensed under an unmodified zlib/libpng license, which is an OSI-certified,
*   BSD-like license that allows static linking with closed source software
*
*   Copyright (c) 2016-2025 Ramon Santamaria (@raysan5)
*
*******************************************************************************************'/

#include "../../raylib.bi"
#include once "crt/math.bi"

#define MAX_BUILDINGS   100

'' Initialization
''--------------------------------------------------------------------------------------
const as long screenWidth = 800
const as long screenHeight = 450

InitWindow(screenWidth, screenHeight, "raylib [core] example - 2d camera")

dim as Rectangle player = Rectangle(400, 280, 40, 40)
dim as Rectangle buildings(MAX_BUILDINGS - 1)
dim as RLColor buildColors(MAX_BUILDINGS - 1)

dim as long spacing = 0

for i as long = 0 to MAX_BUILDINGS - 1
   with buildings(i)
      .width = GetRandomValue(50, 200)
      .height = GetRandomValue(100, 800)
      .y = screenHeight - 130.0f - .height
      .x = -6000.0f + spacing

      spacing += .width
   end with
   buildColors(i) = RLColor(GetRandomValue(200, 240), GetRandomValue(200, 240), GetRandomValue(200, 250), 255)
next i

dim as Camera2D cam
with cam
   .target = Vector2(player.x + 20.0f, player.y + 20.0f)
   .offset = Vector2(screenWidth/2.0f, screenHeight/2.0f)
   .rotation = 0.0f
   .zoom = 1.0f
end with

SetTargetFPS(60)                   '' Set our game to run at 60 frames-per-second
''--------------------------------------------------------------------------------------

'' Main game loop
do while not WindowShouldClose()       '' Detect window close button or ESC key
    '' Update
    ''----------------------------------------------------------------------------------
    '' Player movement
    dim key as Long = GetKeyPressed()
    if IsKeyDown(KEY_RIGHT) then 
        player.x += 2
    elseif IsKeyDown(KEY_LEFT) then 
        player.x -= 2
    end if

    '' Camera target follows player
    cam.target = Vector2(player.x + 20, player.y + 20)

    '' Camera rotation controls
    if IsKeyDown(KEY_A) then 
        cam.rotation -= 1 
    elseif IsKeyDown(KEY_S) then 
        cam.rotation += 1
    end if

    '' Limit camera rotation to 80 degrees (-40 to 40)
    if cam.rotation > 40 then 
        cam.rotation = 40
    elseif cam.rotation < -40 then 
        cam.rotation = -40
    end if

    '' Camera zoom controls
    '' Uses log scaling to provide consistent zoom speed
    cam.zoom = expf(logf(cam.zoom) + GetMouseWheelMove()*0.1f)

    if cam.zoom > 3.0f then 
        cam.zoom = 3.0f
    elseif cam.zoom < 0.1f then
        cam.zoom = 0.1f
    end if

    '' Camera reset (zoom and rotation)
    if IsKeyPressed(KEY_R) then
        cam.zoom = 1.0f
        cam.rotation = 0.0f
    end if
    ''----------------------------------------------------------------------------------

    '' draw
    ''----------------------------------------------------------------------------------
    BeginDrawing()

        ClearBackground(RAYWHITE)

        BeginMode2D(cam)

            DrawRectangle(-6000, 320, 13000, 8000, DARKGRAY)

            for i as long = 0 to MAX_BUILDINGS - 1 
                DrawRectangleRec(buildings(i), buildColors(i))
            next i

            DrawRectangleRec(player, RED)

            DrawLine(cam.target.x, -screenHeight*10, cam.target.x, screenHeight*10, GREEN)
            DrawLine(-screenWidth*10, cam.target.y, screenWidth*10, cam.target.y, GREEN)

        EndMode2D()

        DrawText("SCREEN AREA", 640, 10, 20, RED)

        DrawRectangle(0, 0, screenWidth, 5, RED)
        DrawRectangle(0, 5, 5, screenHeight - 10, RED)
        DrawRectangle(screenWidth - 5, 5, 5, screenHeight - 10, RED)
        DrawRectangle(0, screenHeight - 5, screenWidth, 5, RED)

        DrawRectangle( 10, 10, 250, 113, Fade(SKYBLUE, 0.5f))
        DrawRectangleLines( 10, 10, 250, 113, BLUE)

        DrawText("Free 2D camera controls:", 20, 20, 10, BLACK)
        DrawText("- Right/Left to move player", 40, 40, 10, DARKGRAY)
        DrawText("- Mouse Wheel to Zoom in-out", 40, 60, 10, DARKGRAY)
        DrawText("- A / S to Rotate", 40, 80, 10, DARKGRAY)
        DrawText("- R to reset Zoom and Rotation", 40, 100, 10, DARKGRAY)

    EndDrawing()
    ''----------------------------------------------------------------------------------
loop

'' De-Initialization
''--------------------------------------------------------------------------------------
CloseWindow()        '' close window and OpenGL context
''--------------------------------------------------------------------------------------