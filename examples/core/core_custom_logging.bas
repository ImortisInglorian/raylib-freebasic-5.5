/'******************************************************************************************
*
*   raylib [core] example - Custom logging
*
*   Example originally created with raylib 2.5, last time updated with raylib 2.5
*
*   Example contributed by Pablo Marcos Oltra (@pamarcos) and reviewed by Ramon Santamaria (@raysan5)
*
*   Example licensed under an unmodified zlib/libpng license, which is an OSI-certified,
*   BSD-like license that allows static linking with closed source software
*
*   Copyright (c) 2018-2024 Pablo Marcos Oltra (@pamarcos) and Ramon Santamaria (@raysan5)
*
*******************************************************************************************'/

#include "../../raylib.bi"

#include "crt/stdio.bi"                  '' Required for: fopen(), fclose(), fputc(), fwrite(), printf(), fprintf(), funopen()
#include "crt/time.bi"                   '' Required for: time_t, tm, time(), localtime(), strftime()

'' Custom logging function
sub CustomLog(byval msgType as long, byval text as const zstring ptr, byval args as va_list)
    dim as zstring * 64 timeStr 
    dim as time_t nowVar = time_(NULL)
    dim as tm ptr tm_info = localtime(@nowVar)

    strftime(timeStr, sizeof(timeStr), "%Y-%m-%d %H:%M:%S", tm_info)
    printf("[%s] ", timeStr)

    select case msgType
        case LOG_INFO
            printf("[INFO] : ")
        case LOG_ERROR
            printf("[ERROR]: ")
        case LOG_WARNING
            printf("[WARN] : ")
        case LOG_DEBUG
            printf("[DEBUG]: ")
    end select

    vprintf(text, args)
    printf(!"\n")
end sub

''------------------------------------------------------------------------------------
'' Program main entry point
''------------------------------------------------------------------------------------

'' Initialization
''--------------------------------------------------------------------------------------
const as long screenWidth = 800
const as long screenHeight = 450

'' Set custom logger
SetTraceLogCallback(@CustomLog)

InitWindow(screenWidth, screenHeight, "raylib [core] example - custom logging")

SetTargetFPS(60)               '' Set our game to run at 60 frames-per-second
''--------------------------------------------------------------------------------------

'' Main game loop
do while not WindowShouldClose()    '' Detect window close button or ESC key
    '' Update
    ''----------------------------------------------------------------------------------
    '' TODO: Update your variables here
    ''----------------------------------------------------------------------------------

    '' Draw
    ''----------------------------------------------------------------------------------
    BeginDrawing()

    ClearBackground(RAYWHITE)

    DrawText("Check out the console output to see the custom logger in action!", 60, 200, 20, LIGHTGRAY)

    EndDrawing()
    ''----------------------------------------------------------------------------------
loop

'' De-Initialization
''--------------------------------------------------------------------------------------
CloseWindow()        '' Close window and OpenGL context
''--------------------------------------------------------------------------------------