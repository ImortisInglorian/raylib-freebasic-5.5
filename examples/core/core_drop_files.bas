/'******************************************************************************************
*
*   raylib [core] example - Windows drop files
*
*   NOTE: This example only works on platforms that support drag & drop (Windows, Linux, OSX, Html5?)
*
*   Example originally created with raylib 1.3, last time updated with raylib 4.2
*
*   Example licensed under an unmodified zlib/libpng license, which is an OSI-certified,
*   BSD-like license that allows static linking with closed source software
*
*   Copyright (c) 2015-2024 Ramon Santamaria (@raysan5)
*
*******************************************************************************************'/

#include "../../raylib.bi"

#include "crt/stdlib.bi"         '' Required for: calloc(), free()

#define MAX_FILEPATH_RECORDED   4096
#define MAX_FILEPATH_SIZE       2048

''------------------------------------------------------------------------------------
'' Program main entry point
''------------------------------------------------------------------------------------

'' Initialization
''--------------------------------------------------------------------------------------
const as long screenWidth = 800
const as long screenHeight = 450

InitWindow(screenWidth, screenHeight, "raylib [core] example - drop files")

dim as long filePathCounter = 0
dim as zstring ptr filePaths(MAX_FILEPATH_RECORDED - 1) '' We will register a maximum of filepaths

'' Allocate space for the required file paths
for i as integer = 0 to MAX_FILEPATH_RECORDED -1
    filePaths(i) = callocate(MAX_FILEPATH_SIZE, 1)
next


SetTargetFPS(60)               '' Set our game to run at 60 frames-per-second
''--------------------------------------------------------------------------------------

'' Main game loop
do while not WindowShouldClose()    '' Detect window close button or ESC key
    '' Update
    ''----------------------------------------------------------------------------------
    if IsFileDropped() then
        dim as FilePathList droppedFiles = LoadDroppedFiles()
        for i as integer = 0 to droppedFiles.count - 1
            if filePathCounter < (MAX_FILEPATH_RECORDED - 1) then
                TextCopy(filePaths(i), droppedFiles.paths[i])
                filePathCounter += 1
            end if
        next

        UnloadDroppedFiles(droppedFiles)    '' Unload filepaths from memory
    end if
    ''----------------------------------------------------------------------------------

    '' Draw
    ''----------------------------------------------------------------------------------
    BeginDrawing()

        ClearBackground(RAYWHITE)

        if filePathCounter = 0 then 
            DrawText("Drop your files to this window!", 100, 40, 20, DARKGRAY)
        else
            DrawText("Dropped files:", 100, 40, 20, DARKGRAY)

            for i as integer = 0 to filePathCounter
                if (i mod 2 = 0) then
                    DrawRectangle(0, 85 + 40*i, screenWidth, 40, Fade(LIGHTGRAY, 0.5f))
                else
                    DrawRectangle(0, 85 + 40*i, screenWidth, 40, Fade(LIGHTGRAY, 0.3f))
                end if

                DrawText(filePaths(i), 120, 100 + 40*i, 10, GRAY)
            next

            DrawText("Drop new files...", 100, 110 + 40*filePathCounter, 20, DARKGRAY)
        end if

    EndDrawing()
    ''----------------------------------------------------------------------------------
loop

'' De-Initialization
''--------------------------------------------------------------------------------------
for i as integer = 0 to MAX_FILEPATH_RECORDED - 1
    deallocate(filePaths(i)) '' Free allocated memory for all filepaths
next

CloseWindow()          '' Close window and OpenGL context
''--------------------------------------------------------------------------------------