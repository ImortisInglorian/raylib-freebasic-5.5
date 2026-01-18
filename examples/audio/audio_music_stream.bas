/'******************************************************************************************
*
*   raylib [audio] example - Music playing (streaming)
*
*   Example originally created with raylib 1.3, last time updated with raylib 4.0
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

InitWindow(screenWidth, screenHeight, "raylib [audio] example - music playing (streaming)")

InitAudioDevice()              '' Initialize audio device

dim as Music mus = LoadMusicStream("resources/country.mp3")

PlayMusicStream(mus)

dim as single timePlayed = 0.0f          '' Time played normalized [0.0f..1.0f]
dim as boolean pause = false             '' Music playing paused

SetTargetFPS(30)               '' Set our game to run at 30 frames-per-second
''--------------------------------------------------------------------------------------

'' Main game loop
do while not WindowShouldClose()    '' Detect window close button or ESC key
    '' Update
    ''----------------------------------------------------------------------------------
    UpdateMusicStream(mus)   '' Update music buffer with new stream data
    
    '' Restart music playing (stop and play)
    if IsKeyPressed(KEY_SPACE) then
        StopMusicStream(mus)
        PlayMusicStream(mus)
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

    '' Get normalized time played for current music stream
    timePlayed = GetMusicTimePlayed(mus) / GetMusicTimeLength(mus)

    if timePlayed > 1.0f then timePlayed = 1.0f   '' Make sure time played is no longer than music
    ''----------------------------------------------------------------------------------

    '' Draw
    ''----------------------------------------------------------------------------------
    BeginDrawing()

        ClearBackground(RAYWHITE)

        DrawText("MUSIC SHOULD BE PLAYING!", 255, 150, 20, LIGHTGRAY)

        DrawRectangle(200, 200, 400, 12, LIGHTGRAY)
        DrawRectangle(200, 200, timePlayed * 400.0f, 12, MAROON)
        DrawRectangleLines(200, 200, 400, 12, GRAY)

        DrawText("PRESS SPACE TO RESTART MUSIC", 215, 250, 20, LIGHTGRAY)
        DrawText("PRESS P TO PAUSE/RESUME MUSIC", 208, 280, 20, LIGHTGRAY)

    EndDrawing()
    ''----------------------------------------------------------------------------------
loop

'' De-Initialization
''--------------------------------------------------------------------------------------
UnloadMusicStream(mus)   '' Unload music stream buffers from RAM

CloseAudioDevice()         '' Close audio device (music streaming is automatically stopped)

CloseWindow()              '' Close window and OpenGL context
''--------------------------------------------------------------------------------------