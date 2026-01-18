/'******************************************************************************************
*
*   raylib [core] example - Storage save/load values
*
*   Example originally created with raylib 1.4, last time updated with raylib 4.2
*
*   Example licensed under an unmodified zlib/libpng license, which is an OSI-certified,
*   BSD-like license that allows static linking with closed source software
*
*   Copyright (c) 2015-2024 Ramon Santamaria (@raysan5)
*
*******************************************************************************************'/

#include "../../raylib.bi"

#define STORAGE_DATA_FILE   "storage.data"   '' Storage file
#define NULL 0

'' NOTE: Storage positions must start with 0, directly related to file memory layout
type StorageData as long
enum
    STORAGE_POSITION_SCORE      = 0
    STORAGE_POSITION_HISCORE    = 1
end enum

'' Persistent storage functions
declare function SaveStorageValue(byval position as ulong, byval value as long) as boolean
declare function LoadStorageValue(byval position as ulong) as long

''------------------------------------------------------------------------------------
'' Program main entry point
''------------------------------------------------------------------------------------

'' Initialization
''--------------------------------------------------------------------------------------
const as long screenWidth = 800
const as long screenHeight = 450

InitWindow(screenWidth, screenHeight, "raylib [core] example - storage save/load values")

dim as long score = 0
dim as long hiscore = 0
dim as long framesCounter = 0

SetTargetFPS(60)               '' Set our game to run at 60 frames-per-second
''--------------------------------------------------------------------------------------

'' Main game loop
do while not WindowShouldClose()    '' Detect window close button or ESC key
    '' Update
    ''----------------------------------------------------------------------------------
    if IsKeyPressed(KEY_R) then
        score = GetRandomValue(1000, 2000)
        hiscore = GetRandomValue(2000, 4000)
    end if

    if IsKeyPressed(KEY_ENTER) then
        SaveStorageValue(STORAGE_POSITION_SCORE, score)
        SaveStorageValue(STORAGE_POSITION_HISCORE, hiscore)
    elseif IsKeyPressed(KEY_SPACE) then
        '' NOTE: If requested position could not be found, value 0 is returned
        score = LoadStorageValue(STORAGE_POSITION_SCORE)
        hiscore = LoadStorageValue(STORAGE_POSITION_HISCORE)
    end if

    framesCounter += 1
    ''----------------------------------------------------------------------------------

    '' Draw
    ''----------------------------------------------------------------------------------
    BeginDrawing()

        ClearBackground(RAYWHITE)

        DrawText(TextFormat("SCORE: %i", score), 280, 130, 40, MAROON)
        DrawText(TextFormat("HI-SCORE: %i", hiscore), 210, 200, 50, BLACK)

        DrawText(TextFormat("frames: %i", framesCounter), 10, 10, 20, LIME)

        DrawText("Press R to generate random numbers", 220, 40, 20, LIGHTGRAY)
        DrawText("Press ENTER to SAVE values", 250, 310, 20, LIGHTGRAY)
        DrawText("Press SPACE to LOAD values", 252, 350, 20, LIGHTGRAY)

    EndDrawing()
    ''----------------------------------------------------------------------------------
loop

'' De-Initialization
''--------------------------------------------------------------------------------------
CloseWindow()        '' Close window and OpenGL context
''--------------------------------------------------------------------------------------

'' Save integer value to storage file (to defined position)
'' NOTE: Storage positions is directly related to file memory layout (4 bytes each integer)
function SaveStorageValue(byval position as ulong, byval value as long) as boolean
    dim as boolean success = false
    dim as long dataSize = 0
    dim as ulong newDataSize = 0
    dim as ubyte ptr fileData = LoadFileData(STORAGE_DATA_FILE, @dataSize)
    dim as ubyte ptr newFileData = NULL

    if fileData <> NULL then
        if dataSize <= (position*sizeof(long)) then
            '' Increase data size up to position and store value
            newDataSize = (position + 1)*sizeof(long)
            newFileData = callocate(*fileData, newDataSize)

            if newFileData <> NULL then
                '' callocate succeded
                dim as long ptr dataPtr = cast(long ptr, newFileData)
                dataPtr[position] = value
            else
                '' callocate failed
                TraceLog(LOG_WARNING, "FILEIO: [%s] Failed to realloc data (%u), position in bytes (%u) bigger than actual file size", STORAGE_DATA_FILE, dataSize, position*sizeof(long))

                '' We store the old size of the file
                newFileData = fileData
                newDataSize = dataSize
            end if
        else
            '' Store the old size of the file
            newFileData = fileData
            newDataSize = dataSize

            '' Replace value on selected position
            dim as long ptr dataPtr = cast(long ptr, newFileData)
            dataPtr[position] = value
        end if

        success = SaveFileData(STORAGE_DATA_FILE, newFileData, newDataSize)
        deallocate(newFileData)

        TraceLog(LOG_INFO, "FILEIO: [%s] Saved storage value: %i", STORAGE_DATA_FILE, value)
    else
        TraceLog(LOG_INFO, "FILEIO: [%s] File created successfully", STORAGE_DATA_FILE)

        dataSize = (position + 1)*sizeof(long)
        fileData = allocate(dataSize)
        dim as long ptr dataPtr = cast(long ptr, fileData)
        dataPtr[position] = value

        success = SaveFileData(STORAGE_DATA_FILE, fileData, dataSize)
        UnloadFileData(fileData)

        TraceLog(LOG_INFO, "FILEIO: [%s] Saved storage value: %i", STORAGE_DATA_FILE, value)
    end if

    return success
end function

'' Load integer value from storage file (from defined position)
'' NOTE: If requested position could not be found, value 0 is returned
function LoadStorageValue(byval position as ulong) as long
    dim as long value = 0
    dim as long dataSize = 0
    dim as ubyte ptr fileData = LoadFileData(STORAGE_DATA_FILE, @dataSize)

    if fileData <> NULL then
        if dataSize < (position*4) then
            TraceLog(LOG_WARNING, "FILEIO: [%s] Failed to find storage position: %i", STORAGE_DATA_FILE, position)
        else
            dim as long ptr dataPtr = cast(long ptr, fileData)
            value = dataPtr[position]
        end if

        UnloadFileData(fileData)

        TraceLog(LOG_INFO, "FILEIO: [%s] Loaded storage value: %i", STORAGE_DATA_FILE, value)
    end if

    return value
end function