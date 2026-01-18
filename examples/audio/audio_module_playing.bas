/'******************************************************************************************
*
*   raylib [audio] example - Module playing (streaming)
*
*   Example originally created with raylib 1.5, last time updated with raylib 3.5
*
*   Example licensed under an unmodified zlib/libpng license, which is an OSI-certified,
*   BSD-like license that allows static linking with closed source software
*
*   Copyright (c) 2016-2024 Ramon Santamaria (@raysan5)
*
*******************************************************************************************'/

#include "../../raylib.bi"

#define MAX_CIRCLES  64

type CircleWave
    as Vector2 position
    as single radius
    as single alpha
    as single speed
    as RLColor color
end type

'' Initialization
''--------------------------------------------------------------------------------------
const as long screenWidth = 800
const as long screenHeight = 450

SetConfigFlags(FLAG_MSAA_4X_HINT)  '' NOTE: Try to enable MSAA 4X

InitWindow(screenWidth, screenHeight, "raylib [audio] example - module playing (streaming)")

InitAudioDevice()                  '' Initialize audio device

dim as RLColor colors(...) = { ORANGE, RED, GOLD, LIME, BLUE, VIOLET, BROWN, LIGHTGRAY, PINK, YELLOW, GREEN, SKYBLUE, PURPLE, BEIGE }

'' Creates some circles for visual effect
dim as CircleWave circles(MAX_CIRCLES - 1) 

for i as integer = MAX_CIRCLES - 1 to 0 step -1
    with circles(i)
        .alpha = 0.0f
        .radius = GetRandomValue(10, 40)
        .position.x = GetRandomValue(.radius, screenWidth - .radius)
        .position.y = GetRandomValue(.radius, screenHeight - .radius)
        .speed = GetRandomValue(1, 100) / 2000.0f
        .color = colors(GetRandomValue(0, 13))
    end with
next

dim as Music mus = LoadMusicStream("resources/mini1111.xm")
mus.looping = RLFALSE
dim as single pitch = 1.0f

PlayMusicStream(mus)

dim as single timePlayed = 0.0f
dim as boolean pause = false

SetTargetFPS(60)               '' Set our game to run at 60 frames-per-second
''--------------------------------------------------------------------------------------

'' Main game loop
do while not WindowShouldClose()    '' Detect window close button or ESC key
    '' Update
    ''----------------------------------------------------------------------------------
    UpdateMusicStream(mus)      '' Update music buffer with new stream data

    '' Restart music playing (stop and play)
    if IsKeyPressed(KEY_SPACE) then
        StopMusicStream(mus)
        PlayMusicStream(mus)
        pause = false
    end if

    '' Pause/Resume music playing
    if IsKeyPressed(KEY_P) then
        pause = not pause

        if pause then 
            PauseMusicStream(mus)
        else 
            ResumeMusicStream(mus)
        end if
    end if

    if IsKeyDown(KEY_DOWN) then 
        pitch -= 0.01f
    elseif IsKeyDown(KEY_UP) then 
        pitch += 0.01f
    end if

    SetMusicPitch(mus, pitch)

    '' Get timePlayed scaled to bar dimensions
    timePlayed = GetMusicTimePlayed(mus) / GetMusicTimeLength(mus) * (screenWidth - 40)

    '' Color circles animation
    if not pause then
        for i as integer = MAX_CIRCLES - 1 to 0 step -1
            with circles(i)
                .alpha += .speed
                .radius += .speed * 10.0f

                if .alpha > 1.0f then .speed *= -1

                if .alpha <= 0.0f then
                    .alpha = 0.0f
                    .radius = GetRandomValue(10, 40)
                    .position.x = GetRandomValue(.radius, screenWidth - .radius)
                    .position.y = GetRandomValue(.radius, screenHeight - .radius)
                    .color = colors(GetRandomValue(0, 13))
                    .speed = GetRandomValue(1, 100) / 2000.0f
                end if
            end with
        next
    end if
    ''----------------------------------------------------------------------------------

    '' Draw
    ''----------------------------------------------------------------------------------
    BeginDrawing()

        ClearBackground(RAYWHITE)

        for i as integer = MAX_CIRCLES - 1 to 0 step -1
            with circles(i)
                DrawCircleV(.position, .radius, Fade(.color, .alpha))
            end with
        next

        '' Draw time bar
        DrawRectangle(20, screenHeight - 20 - 12, screenWidth - 40, 12, LIGHTGRAY)
        DrawRectangle(20, screenHeight - 20 - 12, timePlayed, 12, MAROON)
        DrawRectangleLines(20, screenHeight - 20 - 12, screenWidth - 40, 12, GRAY)

        '' Draw help instructions
        DrawRectangle(20, 20, 425, 145, WHITE)
        DrawRectangleLines(20, 20, 425, 145, GRAY)
        DrawText("PRESS SPACE TO RESTART MUSIC", 40, 40, 20, BLACK)
        DrawText("PRESS P TO PAUSE/RESUME", 40, 70, 20, BLACK)
        DrawText("PRESS UP/DOWN TO CHANGE SPEED", 40, 100, 20, BLACK)
        DrawText(TextFormat("SPEED: %f", pitch), 40, 130, 20, MAROON)

    EndDrawing()
    ''----------------------------------------------------------------------------------
loop

'' De-Initialization
''--------------------------------------------------------------------------------------
UnloadMusicStream(mus)          '' Unload music stream buffers from RAM

CloseAudioDevice()     '' Close audio device (music streaming is automatically stopped)

CloseWindow()          '' Close window and OpenGL context
''--------------------------------------------------------------------------------------
