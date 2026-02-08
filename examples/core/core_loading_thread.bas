/'******************************************************************************************
*
*   raylib [core] example - loading thread
*
*   NOTE: This example requires linking with pthreads library on MinGW, 
*   it can be accomplished passing -static parameter to compiler
*
*   Example originally created with raylib 2.5, last time updated with raylib 3.0
*
*   Example licensed under an unmodified zlib/libpng license, which is an OSI-certified,
*
*   Copyright (c) 2014-2024 Ramon Santamaria (@raysan5)
*
*******************************************************************************************'/

#include "../../raylib.bi"

declare sub LoadDataThread(arg as any ptr)     '' Loading data thread function declaration

type ThreadData
    as boolean dataLoaded
    as integer dataProgress
end type

''------------------------------------------------------------------------------------
'' Program main entry point
''------------------------------------------------------------------------------------
'' Initialization
''--------------------------------------------------------------------------------------
const as long screenWidth = 800
const as long screenHeight = 450

dim as ThreadData tdata = Type(false, 0)

InitWindow(screenWidth, screenHeight, "raylib [core] example - loading thread")

dim as any ptr threadId     '' Loading data thread id

enum
    STATE_WAITING
    STATE_LOADING
    STATE_FINISHED
end enum

dim as long state = STATE_WAITING

dim as long framesCounter = 0

SetTargetFPS(60)               '' Set our game to run at 60 frames-per-second
''--------------------------------------------------------------------------------------

'' Main game loop
do while not WindowShouldClose()    '' Detect window close button or ESC key
    '' Update
    ''----------------------------------------------------------------------------------
    select case state
        case STATE_WAITING
            if IsKeyPressed(KEY_ENTER) then
                threadId = threadcreate(@LoadDataThread, @tdata)
                if threadId = 0 then
                    TraceLog(LOG_ERROR, "Error creating loading thread")
                else 
                    TraceLog(LOG_INFO, "Loading thread initialized successfully")
                end if

                state = STATE_LOADING
            end if
        case STATE_LOADING
            framesCounter += 1
            if tdata.dataLoaded then
                framesCounter = 0
                threadwait(threadId)
                TraceLog(LOG_INFO, "Loading thread terminated successfully")

                state = STATE_FINISHED
            end if
        case STATE_FINISHED
            if IsKeyPressed(KEY_ENTER) then
                '' Reset everything to launch again
                tdata.dataLoaded =  false
                tdata.dataProgress = 0
                state = STATE_WAITING
            end if
    end select
    ''----------------------------------------------------------------------------------

    '' Draw
    ''----------------------------------------------------------------------------------
    BeginDrawing()

        ClearBackground(RAYWHITE)

        select case state
            case STATE_WAITING
                DrawText("PRESS ENTER to START LOADING DATA", 150, 170, 20, DARKGRAY)
            case STATE_LOADING
                DrawRectangle(150, 200, tdata.dataProgress, 60, SKYBLUE)
                if (framesCounter/15) mod 2 then DrawText("LOADING DATA...", 240, 210, 40, DARKBLUE)
            case STATE_FINISHED
                DrawRectangle(150, 200, 500, 60, LIME)
                DrawText("DATA LOADED!", 250, 210, 40, GREEN)
        end select

        DrawRectangleLines(150, 200, 500, 60, DARKGRAY)

    EndDrawing()
    ''----------------------------------------------------------------------------------
loop

'' De-Initialization
''--------------------------------------------------------------------------------------
CloseWindow()        '' Close window and OpenGL context
''--------------------------------------------------------------------------------------

'' Loading data thread function definition
sub LoadDataThread(arg as any ptr)
    dim as ThreadData ptr tdata = arg
    dim as double timeCounter = 0            '' Time counted in ms
    dim as double prevTime = timer     '' Previous time

    '' We simulate data loading with a time counter for 5 seconds
    do while timeCounter < 5000
        dim as double currentTime = timer - prevTime
        timeCounter = currentTime * 1000

        '' We accumulate time over a global variable to be used in
        '' main thread as a progress bar
        tdata->dataProgress = timeCounter/10
    loop

    '' When data has finished loading, we set global variable
    tdata->dataLoaded = true
end sub
