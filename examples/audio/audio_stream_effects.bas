/'******************************************************************************************
*
*   raylib [audio] example - Music stream processing effects
*
*   Example originally created with raylib 4.2, last time updated with raylib 5.0
*
*   Example licensed under an unmodified zlib/libpng license, which is an OSI-certified,
*   BSD-like license that allows static linking with closed source software
*
*   Copyright (c) 2022-2024 Ramon Santamaria (@raysan5)
*
*******************************************************************************************'/

#include "../../raylib.bi"

#define NULL 0

'' Required delay effect variables
dim shared as single ptr delayBuffer = NULL
dim shared as ulong delayBufferSize = 0
dim shared as ulong delayReadIndex = 2
dim shared as ulong delayWriteIndex = 0

''------------------------------------------------------------------------------------
'' Module Functions Declaration
''------------------------------------------------------------------------------------
declare sub AudioProcessEffectLPF(buffer as any ptr, frames as ulong)   '' Audio effect: lowpass filter
declare sub AudioProcessEffectDelay(buffer as any ptr, frames as ulong) '' Audio effect: delay

''------------------------------------------------------------------------------------
'' Program main entry point
''------------------------------------------------------------------------------------
'' Initialization
''--------------------------------------------------------------------------------------
const as long screenWidth = 800
const as long screenHeight = 450

InitWindow(screenWidth, screenHeight, "raylib [audio] example - stream effects")

InitAudioDevice()              '' Initialize audio device

dim as Music mus = LoadMusicStream("resources/country.mp3")

'' Allocate buffer for the delay effect
delayBufferSize = 48000 * 2      '' 1 second delay (device sampleRate*channels)
delayBuffer = callocate(delayBufferSize, sizeof(single))

PlayMusicStream(mus)

dim as single timePlayed = 0.0f        '' Time played normalized [0.0f..1.0f]
dim as boolean pause = false           '' Music playing paused

dim as boolean enableEffectLPF = false   '' Enable effect low-pass-filter
dim as boolean enableEffectDelay = false '' Enable effect delay (1 second)

SetTargetFPS(60)               '' Set our game to run at 60 frames-per-second
''--------------------------------------------------------------------------------------

'' Main game loop
do while  not WindowShouldClose()    '' Detect window close button or ESC key
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

        if (pause) then 
            PauseMusicStream(mus)
        else 
            ResumeMusicStream(mus)
        end if
    end if

    '' Add/Remove effect: lowpass filter
    if IsKeyPressed(KEY_F) then
        enableEffectLPF =  not enableEffectLPF
        if enableEffectLPF then 
            AttachAudioStreamProcessor(mus.stream, @AudioProcessEffectLPF)
        else 
            DetachAudioStreamProcessor(mus.stream, @AudioProcessEffectLPF)
        end if
    end if

    '' Add/Remove effect: delay
    if IsKeyPressed(KEY_D) then
        enableEffectDelay = not enableEffectDelay
        if enableEffectDelay then 
            AttachAudioStreamProcessor(mus.stream, @AudioProcessEffectDelay)
        else 
            DetachAudioStreamProcessor(mus.stream, @AudioProcessEffectDelay)
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

        DrawText("MUSIC SHOULD BE PLAYING!", 245, 150, 20, LIGHTGRAY)

        DrawRectangle(200, 180, 400, 12, LIGHTGRAY)
        DrawRectangle(200, 180, timePlayed * 400.0f, 12, MAROON)
        DrawRectangleLines(200, 180, 400, 12, GRAY)

        DrawText("PRESS SPACE TO RESTART MUSIC", 215, 230, 20, LIGHTGRAY)
        DrawText("PRESS P TO PAUSE/RESUME MUSIC", 208, 260, 20, LIGHTGRAY)
        
        DrawText(TextFormat("PRESS F TO TOGGLE LPF EFFECT: %s", iif(enableEffectLPF, "ON", "OFF")), 200, 320, 20, GRAY)
        DrawText(TextFormat("PRESS D TO TOGGLE DELAY EFFECT: %s", iif(enableEffectDelay, "ON", "OFF")), 180, 350, 20, GRAY)

    EndDrawing()
    ''----------------------------------------------------------------------------------
loop

'' De-Initialization
''--------------------------------------------------------------------------------------
UnloadMusicStream(mus)   '' Unload music stream buffers from RAM

CloseAudioDevice()         '' Close audio device (music streaming is automatically stopped)

deallocate(delayBuffer)       '' Free delay buffer

CloseWindow()              '' Close window and OpenGL context
''--------------------------------------------------------------------------------------

''------------------------------------------------------------------------------------
'' Module Functions Definition
''------------------------------------------------------------------------------------
'' Audio effect: lowpass filter
sub AudioProcessEffectLPF(buffer as any ptr, frames as ulong)
    static as single low(...) = { 0.0f, 0.0f }
    static as const single cutoff = 70.0f / 44100.0f '' 70 Hz lowpass filter
    dim as const single k = cutoff / (cutoff + 0.1591549431f) '' RC filter formula

    '' Converts the buffer data before using it
    dim as single ptr bufferData = buffer
    for i as integer = 0 to frames * 2 step 2
        dim as const single l = bufferData[i]
        dim as const single r = bufferData[i + 1]

        low(0) += k * (l - low(0))
        low(1) += k * (r - low(1))
        bufferData[i] = low(0)
        bufferData[i + 1] = low(1)
    next
end sub

'' Audio effect: delay
sub AudioProcessEffectDelay(buffer as any ptr, frames as ulong)
    for i as integer = 0 to frames * 2 step 2
        delayWriteIndex += 1
        dim as single leftDelay = delayBuffer[delayReadIndex]    '' ERROR: Reading buffer -> WHY??? Maybe thread related???
        delayWriteIndex += 1
        dim as single rightDelay = delayBuffer[delayReadIndex]

        if delayReadIndex = delayBufferSize then delayReadIndex = 0
        dim as single ptr bufferData = buffer
        bufferData[i] = 0.5f * bufferData[i] + 0.5f * leftDelay
        bufferData[i + 1] = 0.5f * bufferData[i + 1] + 0.5f * rightDelay
        delayWriteIndex += 1
        delayBuffer[delayWriteIndex] = bufferData[i]
        delayWriteIndex += 1
        delayBuffer[delayWriteIndex] = bufferData[i + 1]
        if (delayWriteIndex = delayBufferSize) then delayWriteIndex = 0
    next
end sub
