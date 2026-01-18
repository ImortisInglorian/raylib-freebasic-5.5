/'******************************************************************************************
*
*   raylib [audio] example - Raw audio streaming
*
*   Example originally created with raylib 1.6, last time updated with raylib 4.2
*
*   Example created by Ramon Santamaria (@raysan5) and reviewed by James Hofmann (@triplefox)
*
*   Example licensed under an unmodified zlib/libpng license, which is an OSI-certified,
*   BSD-like license that allows static linking with closed source software
*
*   Copyright (c) 2015-2024 Ramon Santamaria (@raysan5) and James Hofmann (@triplefox)
*
******************************************************************************************'/

#include "../../raylib.bi"

#include "crt/stdlib.bi"         '' Required for: malloc(), free()
#include "crt/math.bi"           '' Required for: sinf()
#include "crt/string.bi"         '' Required for: memcpy()

#define MAX_SAMPLES               512
#define MAX_SAMPLES_PER_UPDATE   4096

'' Cycles per second (hz)
dim shared as single frequency = 440.0f

'' Audio frequency, for smoothing
dim shared as single audioFrequency = 440.0f

'' Previous value, used to test if sine needs to be rewritten, and to smoothly modulate frequency
dim as single oldFrequency = 1.0f

'' Index for audio rendering
dim shared as single sineIdx = 0.0f

'' Audio input processing callback
sub AudioInputCallback(buffer as any ptr, frames as ulong)
    audioFrequency = frequency + (audioFrequency - frequency) * 0.95f

    dim as single incr = audioFrequency / 44100.0f
    dim as short ptr d = buffer

    for i as integer = 0 to frames - 1
        d[i] = 32000.0f * sinf(2 * PI * sineIdx)
        sineIdx += incr
        if (sineIdx > 1.0f) then sineIdx -= 1.0f
    next
end sub

''------------------------------------------------------------------------------------
'' Program main entry point
''------------------------------------------------------------------------------------
'' Initialization
''--------------------------------------------------------------------------------------
const as long screenWidth = 800
const as long screenHeight = 450

InitWindow(screenWidth, screenHeight, "raylib [audio] example - raw audio streaming")

InitAudioDevice()              '' Initialize audio device

SetAudioStreamBufferSizeDefault(MAX_SAMPLES_PER_UPDATE)

'' Init raw audio stream (sample rate: 44100, sample size: 16bit-short, channels: 1-mono)
dim as AudioStream stream = LoadAudioStream(44100, 16, 1)

SetAudioStreamCallback(stream, @AudioInputCallback)

'' Buffer for the single cycle waveform we are synthesizing
dim as short ptr data_ = malloc(sizeof(short) * MAX_SAMPLES)

'' Frame buffer, describing the waveform when repeated over the course of a frame
dim as short ptr writeBuf = malloc(sizeof(short) * MAX_SAMPLES_PER_UPDATE)

PlayAudioStream(stream)        '' Start processing stream buffer (no data loaded currently)

'' Position read in to determine next frequency
dim as Vector2 mousePosition = Vector2(-100.0f, -100.0f)

'' Computed size in samples of the sine wave
dim as long waveLength = 1

dim as Vector2 position = Vector2(0, 0)

SetTargetFPS(30)               '' Set our game to run at 30 frames-per-second
''--------------------------------------------------------------------------------------

'' Main game loop
do while not WindowShouldClose()    '' Detect window close button or ESC key
    '' Update
    ''----------------------------------------------------------------------------------

    '' Sample mouse input.
    mousePosition = GetMousePosition()

    if IsMouseButtonDown(MOUSE_BUTTON_LEFT) then
        dim as single fp = mousePosition.y
        frequency = 40.0f + fp

        dim as single pan = mousePosition.x / screenWidth
        SetAudioStreamPan(stream, pan)
    end if

    '' Rewrite the sine wave
    '' Compute two cycles to allow the buffer padding, simplifying any modulation, resampling, etc.
    if frequency <> oldFrequency then
        '' Compute wavelength. Limit size in both directions.
        waveLength = 22050 / frequency
        if waveLength > MAX_SAMPLES/2 then waveLength = MAX_SAMPLES/2
        if waveLength < 1 then waveLength = 1

        '' Write sine wave
        for i as integer = 0 to waveLength * 2
            data_[i] = sinf(((2 * PI * i / waveLength))) * 32000
        next
        '' Make sure the rest of the line is flat
        for j as integer = waveLength * 2 to MAX_SAMPLES - 1
            data_[j] = 0
        next

        '' Scale read cursor's position to minimize transition artifacts
        oldFrequency = frequency
    end if

    ''----------------------------------------------------------------------------------

    '' Draw
    ''----------------------------------------------------------------------------------
    BeginDrawing()

        ClearBackground(RAYWHITE)

        DrawText(TextFormat("sine frequency: %i",frequency), GetScreenWidth() - 220, 10, 20, RED)
        DrawText("click mouse button to change frequency or pan", 10, 10, 20, DARKGRAY)

        '' Draw the current buffer state proportionate to the screen
        for i as integer = 0 to screenWidth - 1
            position.x = i
            position.y = 250 + 50 * data_[i * MAX_SAMPLES / screenWidth] / 32000.0f

            DrawPixelV(position, RED)
        next

    EndDrawing()
    ''----------------------------------------------------------------------------------
loop

'' De-Initialization
''--------------------------------------------------------------------------------------
free(data_)                 '' Unload sine wave data
free(writeBuf)              '' Unload write buffer

UnloadAudioStream(stream)   '' Close raw audio stream and delete buffers from RAM
CloseAudioDevice()          '' Close audio device (music streaming is automatically stopped)

CloseWindow()               '' Close window and OpenGL context
''--------------------------------------------------------------------------------------