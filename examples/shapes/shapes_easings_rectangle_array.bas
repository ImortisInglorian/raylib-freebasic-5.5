/'******************************************************************************************
*
*   raylib [shapes] example - easings rectangle array
*
*   NOTE: This example requires 'easings.h' library, provided on raylib/src. Just copy
*   the library to same directory as example or make sure it's available on include path.
*
*   Example originally created with raylib 2.0, last time updated with raylib 2.5
*
*   Example licensed under an unmodified zlib/libpng license, which is an OSI-certified,
*   BSD-like license that allows static linking with closed source software
*
*   Copyright (c) 2014-2024 Ramon Santamaria (@raysan5)
*
*******************************************************************************************'/

#include "../../raylib.bi"
#include "../../reasings.bi"            '' Required for easing functions

#define RECS_WIDTH              50
#define RECS_HEIGHT             50

#define MAX_RECS_X              800/RECS_WIDTH
#define MAX_RECS_Y              450/RECS_HEIGHT

#define PLAY_TIME_IN_FRAMES     240                 '' At 60 fps = 4 seconds

'' Initialization
''--------------------------------------------------------------------------------------
const as long screenWidth = 800
const as long screenHeight = 450

InitWindow(screenWidth, screenHeight, "raylib [shapes] example - easings rectangle array")

dim as Rectangle recs((MAX_RECS_X * MAX_RECS_Y) - 1)

for y as integer = 0 to MAX_RECS_Y - 1
    for x as integer = 0 to MAX_RECS_X - 1
        recs(y*MAX_RECS_X + x).x = RECS_WIDTH/2.0f + RECS_WIDTH*x
        recs(y*MAX_RECS_X + x).y = RECS_HEIGHT/2.0f + RECS_HEIGHT*y
        recs(y*MAX_RECS_X + x).width = RECS_WIDTH
        recs(y*MAX_RECS_X + x).height = RECS_HEIGHT
    next
next

dim as single rotation = 0.0f
dim as long framesCounter = 0
dim as long state = 0                  '' Rectangles animation state: 0-Playing, 1-Finished

SetTargetFPS(60)               '' Set our game to run at 60 frames-per-second
''--------------------------------------------------------------------------------------

'' Main game loop
do while not WindowShouldClose()    '' Detect window close button or ESC key
    '' Update
    ''----------------------------------------------------------------------------------
    if state = 0 then
        framesCounter += 1

        for i as integer = 0 to (MAX_RECS_X * MAX_RECS_Y) - 1
            recs(i).height = EaseCircOut(framesCounter, RECS_HEIGHT, -RECS_HEIGHT, PLAY_TIME_IN_FRAMES)
            recs(i).width = EaseCircOut(framesCounter, RECS_WIDTH, -RECS_WIDTH, PLAY_TIME_IN_FRAMES)

            if recs(i).height < 0 then recs(i).height = 0
            if recs(i).width < 0 then recs(i).width = 0

            if (recs(i).height = 0 and recs(i).width = 0) then state = 1   '' Finish playing

            rotation = EaseLinearIn(framesCounter, 0.0f, 360.0f, PLAY_TIME_IN_FRAMES)
        next
    elseif state = 1 and IsKeyPressed(KEY_SPACE) then
        '' When animation has finished, press space to restart
        framesCounter = 0

        for i as integer = 0 to (MAX_RECS_X * MAX_RECS_Y) - 1
            recs(i).height = RECS_HEIGHT
            recs(i).width = RECS_WIDTH
        next

        state = 0
    end if
    ''----------------------------------------------------------------------------------

    '' Draw
    ''----------------------------------------------------------------------------------
    BeginDrawing()

        ClearBackground(RAYWHITE)

        if state = 0 then
            for i as integer = 0 to (MAX_RECS_X * MAX_RECS_Y) - 1
                DrawRectanglePro(recs(i), Vector2(recs(i).width/2, recs(i).height/2), rotation, RED)
            next
        elseif state = 1 then 
            DrawText("PRESS [SPACE] TO PLAY AGAIN!", 240, 200, 20, GRAY)
        end if

    EndDrawing()
    ''----------------------------------------------------------------------------------
loop

'' De-Initialization
''--------------------------------------------------------------------------------------
CloseWindow()        '' Close window and OpenGL context
''--------------------------------------------------------------------------------------