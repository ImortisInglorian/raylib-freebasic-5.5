/'******************************************************************************************
*
*   raylib [textures] example - Bunnymark
*
*   Example originally created with raylib 1.6, last time updated with raylib 2.5
*
*   Example licensed under an unmodified zlib/libpng license, which is an OSI-certified,
*   BSD-like license that allows static linking with closed source software
*
*   Copyright (c) 2014-2024 Ramon Santamaria (@raysan5)
*
*******************************************************************************************'/

#include "../../raylib.bi"

#define MAX_BUNNIES        50000    '' 50K bunnies limit

'' This is the maximum amount of elements (quads) per batch
'' NOTE: This value is defined in [rlgl] module and can be changed there
#define MAX_BATCH_ELEMENTS  8192

type Bunny
    as Vector2 position
    as Vector2 speed
    as RLColor color
end type

'' Initialization
''--------------------------------------------------------------------------------------
const as long screenWidth = 800
const as long screenHeight = 450

InitWindow(screenWidth, screenHeight, "raylib [textures] example - bunnymark")

'' Load bunny texture
dim as Texture2D texBunny = LoadTexture("resources/wabbit_alpha.png")

dim as Bunny bunnies(MAX_BUNNIES - 1)

dim as long bunniesCount = 0           '' Bunnies counter

SetTargetFPS(60)               '' Set our game to run at 60 frames-per-second
''--------------------------------------------------------------------------------------

'' Main game loop
do while not WindowShouldClose()    '' Detect window close button or ESC key
    '' Update
    ''----------------------------------------------------------------------------------
    if IsMouseButtonDown(MOUSE_BUTTON_LEFT) then
        '' Create more bunnies
        for i as integer = 0 to 99
            if bunniesCount < MAX_BUNNIES then
                bunnies(bunniesCount).position = GetMousePosition()
                bunnies(bunniesCount).speed.x = GetRandomValue(-250, 250)/60.0f
                bunnies(bunniesCount).speed.y = GetRandomValue(-250, 250)/60.0f
                bunnies(bunniesCount).color = RLColor(GetRandomValue(50, 240), _
                                                    GetRandomValue(80, 240), _
                                                    GetRandomValue(100, 240), 255)
                bunniesCount += 1
            end if
        next
    end if

    '' Update bunnies
    for i as integer = 0 to bunniesCount - 1
        bunnies(i).position.x += bunnies(i).speed.x
        bunnies(i).position.y += bunnies(i).speed.y

        if (((bunnies(i).position.x + texBunny.width/2) > GetScreenWidth()) or _
            ((bunnies(i).position.x + texBunny.width/2) < 0)) then bunnies(i).speed.x *= -1
        if (((bunnies(i).position.y + texBunny.height/2) > GetScreenHeight()) or _
            ((bunnies(i).position.y + texBunny.height/2 - 40) < 0)) then bunnies(i).speed.y *= -1
    next
    ''----------------------------------------------------------------------------------

    '' Draw
    ''----------------------------------------------------------------------------------
    BeginDrawing()

        ClearBackground(RAYWHITE)

        for i as integer = 0 to bunniesCount - 1
            '' NOTE: When internal batch buffer limit is reached (MAX_BATCH_ELEMENTS),
            '' a draw call is launched and buffer starts being filled again
            '' before issuing a draw call, updated vertex data from internal CPU buffer is send to GPU...
            '' Process of sending data is costly and it could happen that GPU data has not been completely
            '' processed for drawing while new data is tried to be sent (updating current in-use buffers)
            '' it could generates a stall and consequently a frame drop, limiting the number of drawn bunnies
            DrawTexture(texBunny, bunnies(i).position.x, bunnies(i).position.y, bunnies(i).color)
        next

        DrawRectangle(0, 0, screenWidth, 40, BLACK)
        DrawText(TextFormat("bunnies: %i", bunniesCount), 120, 10, 20, GREEN)
        DrawText(TextFormat("batched draw calls: %i", 1 + bunniesCount/MAX_BATCH_ELEMENTS), 320, 10, 20, MAROON)

        DrawFPS(10, 10)

    EndDrawing()
    ''----------------------------------------------------------------------------------
loop

'' De-Initialization
''--------------------------------------------------------------------------------------
UnloadTexture(texBunny)    '' Unload bunny texture

CloseWindow()              '' Close window and OpenGL context
''--------------------------------------------------------------------------------------