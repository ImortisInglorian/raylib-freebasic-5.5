/'******************************************************************************************
*
*   raylib [audio] example - Playing sound multiple times
*
*   Example originally created with raylib 4.6
*
*   Example licensed under an unmodified zlib/libpng license, which is an OSI-certified,
*   BSD-like license that allows static linking with closed source software
*
*   Copyright (c) 2023 Jeffery Myers (@JeffM2501)
*
*******************************************************************************************'/

#include "../../raylib.bi"

#define MAX_SOUNDS 10
dim as Sound soundArray(MAX_SOUNDS - 1)
dim as long currentSound

'' Initialization
''--------------------------------------------------------------------------------------
const as long screenWidth = 800
const as long screenHeight = 450

InitWindow(screenWidth, screenHeight, "raylib [audio] example - playing sound multiple times")

InitAudioDevice()      '' Initialize audio device

'' load the sound list
soundArray(0) = LoadSound("resources/sound.wav")         '' Load WAV audio file into the first slot as the 'source' sound
                                                            '' this sound owns the sample data
for i as integer = 1 to MAX_SOUNDS - 1
    soundArray(i) = LoadSoundAlias(soundArray(0))        '' Load an alias of the sound into slots 1-9. These do not own the sound data, but can be played
next
currentSound = 0                                         '' set the sound list to the start

SetTargetFPS(60)               '' Set our game to run at 60 frames-per-second
''--------------------------------------------------------------------------------------

'' Main game loop
do while not WindowShouldClose()    '' Detect window close button or ESC key
    '' Update
    ''----------------------------------------------------------------------------------
    if IsKeyPressed(KEY_SPACE) then
        PlaySound(soundArray(currentSound))            '' play the next open sound slot
        currentSound += 1                              '' increment the sound slot
        if currentSound >= MAX_SOUNDS then             '' if the sound slot is out of bounds, go back to 0
            currentSound = 0
        end if
        '' Note: a better way would be to look at the list for the first sound that is not playing and use that slot
    end if

    ''----------------------------------------------------------------------------------

    '' Draw
    ''----------------------------------------------------------------------------------
    BeginDrawing()

        ClearBackground(RAYWHITE)

        DrawText("Press SPACE to PLAY a WAV sound!", 200, 180, 20, LIGHTGRAY)

    EndDrawing()
    ''----------------------------------------------------------------------------------
loop

'' De-Initialization
''--------------------------------------------------------------------------------------
for i as integer = 1 to MAX_SOUNDS - 1
    UnloadSoundAlias(soundArray(i))     '' Unload sound aliases
next
UnloadSound(soundArray(0))              '' Unload source sound data

CloseAudioDevice()     '' Close audio device

CloseWindow()          '' Close window and OpenGL context
''--------------------------------------------------------------------------------------