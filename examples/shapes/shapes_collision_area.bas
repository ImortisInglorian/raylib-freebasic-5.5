/'******************************************************************************************
*
*   raylib [shapes] example - collision area
*
*   Example originally created with raylib 2.5, last time updated with raylib 2.5
*
*   Example licensed under an unmodified zlib/libpng license, which is an OSI-certified,
*   BSD-like license that allows static linking with closed source software
*
*   Copyright (c) 2013-2024 Ramon Santamaria (@raysan5)
*
*******************************************************************************************'/

#include "../../raylib.bi"

'' Initialization
''---------------------------------------------------------
const as long screenWidth = 800
const as long screenHeight = 450

InitWindow(screenWidth, screenHeight, "raylib [shapes] example - collision area")

'' Box A: Moving box
dim as Rectangle boxA =  Rectangle(10, GetScreenHeight()/2.0f - 50, 200, 100)
dim as long boxASpeedX = 4

'' Box B: Mouse moved box
dim as Rectangle boxB = Rectangle(GetScreenWidth()/2.0f - 30, GetScreenHeight()/2.0f - 30, 60, 60)

dim as Rectangle boxCollision '' Collision rectangle

dim as long screenUpperLimit = 40      '' Top menu limits

dim as boolean pause = false             '' Movement pause
dim as boolean collision = false         '' Collision detection

SetTargetFPS(60)               '' Set our game to run at 60 frames-per-second
''----------------------------------------------------------

'' Main game loop
do while not WindowShouldClose()    '' Detect window close button or ESC key
    '' Update
    ''-----------------------------------------------------
    '' Move box if not paused
    if not pause then boxA.x += boxASpeedX

    '' Bounce box on x screen limits
    if ((boxA.x + boxA.width) >= GetScreenWidth() or  (boxA.x <= 0)) then boxASpeedX *= -1

    '' Update player-controlled-box (box02)
    boxB.x = GetMouseX() - boxB.width/2
    boxB.y = GetMouseY() - boxB.height/2

    '' Make sure Box B does not go out of move area limits
    if (boxB.x + boxB.width) >= GetScreenWidth() then 
        boxB.x = GetScreenWidth() - boxB.width
    elseif (boxB.x <= 0) then
        boxB.x = 0
    end if

    if (boxB.y + boxB.height) >= GetScreenHeight() then 
        boxB.y = GetScreenHeight() - boxB.height
    elseif boxB.y <= screenUpperLimit then
        boxB.y = screenUpperLimit
    end if

    '' Check boxes collision
    collision = CheckCollisionRecs(boxA, boxB)

    '' Get collision rectangle (only on collision)
    if collision then boxCollision = GetCollisionRec(boxA, boxB)

    '' Pause Box A movement
    if IsKeyPressed(KEY_SPACE) then pause = not pause
    ''-----------------------------------------------------

    '' Draw
    ''-----------------------------------------------------
    BeginDrawing()

        ClearBackground(RAYWHITE)

        DrawRectangle(0, 0, screenWidth, screenUpperLimit, iif(collision, RED, BLACK))

        DrawRectangleRec(boxA, GOLD)
        DrawRectangleRec(boxB, BLUE)

        if collision then
            '' Draw collision area
            DrawRectangleRec(boxCollision, LIME)

            '' Draw collision message
            DrawText("COLLISION!", GetScreenWidth()/2 - MeasureText("COLLISION!", 20)/2, screenUpperLimit/2 - 10, 20, BLACK)

            '' Draw collision area
            DrawText(TextFormat("Collision Area: %i", boxCollision.width*boxCollision.height), GetScreenWidth()/2 - 100, screenUpperLimit + 10, 20, BLACK)
        end if

        '' Draw help instructions
        DrawText("Press SPACE to PAUSE/RESUME", 20, screenHeight - 35, 20, LIGHTGRAY)

        DrawFPS(10, 10)

    EndDrawing()
    ''-----------------------------------------------------
loop

'' De-Initialization
''---------------------------------------------------------
CloseWindow()        '' Close window and OpenGL context
''----------------------------------------------------------