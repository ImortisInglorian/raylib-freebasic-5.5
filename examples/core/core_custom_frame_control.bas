/'******************************************************************************************
*
*   raylib [core] example - custom frame control
*
*   NOTE: WARNING: This is an example for advanced users willing to have full control over
*   the frame processes. By default, EndDrawing() calls the following processes:
*       1. Draw remaining batch data: rlDrawRenderBatchActive()
*       2. SwapScreenBuffer()
*       3. Frame time control: WaitTime()
*       4. PollInputEvents()
*
*   To avoid steps 2, 3 and 4, flag SUPPORT_CUSTOM_FRAME_CONTROL can be enabled in
*   config.h (it requires recompiling raylib). This way those steps are up to the user.
*
*   Note that enabling this flag invalidates some functions:
*       - GetFrameTime()
*       - SetTargetFPS()
*       - GetFPS()
*
*   Example originally created with raylib 4.0, last time updated with raylib 4.0
*
*   Example licensed under an unmodified zlib/libpng license, which is an OSI-certified,
*   BSD-like license that allows static linking with closed source software
*
*   Copyright (c) 2021-2024 Ramon Santamaria (@raysan5)
*
*******************************************************************************************'/

#include "../../raylib.bi"

'' Initialization
''--------------------------------------------------------------------------------------
const as long screenWidth = 800
const as long screenHeight = 450

InitWindow(screenWidth, screenHeight, "raylib [core] example - custom frame control")

'' Custom timming variables
dim as double previousTime = GetTime()    '' Previous time measure
dim as double currentTime = 0.0           '' Current time measure
dim as double updateDrawTime = 0.0        '' Update + Draw time
dim as double waitTme = 0.0              '' Wait time (if target fps required)
dim as single deltaTime = 0.0f             '' Frame time (Update + Draw + Wait time)

dim as single timeCounter = 0.0f           '' Accumulative time counter (seconds)
dim as single position = 0.0f              '' Circle position
dim as boolean pause = false                 '' Pause control flag

dim as long targetFPS = 60                 '' Our initial target fps
''--------------------------------------------------------------------------------------

'' Main game loop
do while not WindowShouldClose()        '' Detect window close button or ESC key
    '' Update
    ''----------------------------------------------------------------------------------
    PollInputEvents()              '' Poll input events (SUPPORT_CUSTOM_FRAME_CONTROL)
    
    if IsKeyPressed(KEY_SPACE) then pause = not pause
    
    if IsKeyPressed(KEY_UP) then 
        targetFPS += 20
    elseif IsKeyPressed(KEY_DOWN) then
        targetFPS -= 20
    end if
    
    if targetFPS < 0 then targetFPS = 0

    if not pause then
        position += 200 * deltaTime  '' We move at 200 pixels per second
        if position >= GetScreenWidth() then position = 0
        timeCounter += deltaTime   '' We count time (seconds)
    end if
    ''----------------------------------------------------------------------------------

    '' Draw
    ''----------------------------------------------------------------------------------
    BeginDrawing()

        ClearBackground(RAYWHITE)

        for i as integer = 0 to (GetScreenWidth() / 200) - 1  
            DrawRectangle(200 * i, 0, 1, GetScreenHeight(), SKYBLUE)
        next
        
        DrawCircle(position, GetScreenHeight() / 2 - 25, 50, RED)
        
        DrawText(TextFormat("%03.0f ms", timeCounter*1000.0f), position - 40, GetScreenHeight()/2 - 100, 20, MAROON)
        DrawText(TextFormat("PosX: %03.0f", position), position - 50, GetScreenHeight()/2 + 40, 20, BLACK)
        
        DrawText("Circle is moving at a constant 200 pixels/sec,\nindependently of the frame rate.", 10, 10, 20, DARKGRAY)
        DrawText("PRESS SPACE to PAUSE MOVEMENT", 10, GetScreenHeight() - 60, 20, GRAY)
        DrawText("PRESS UP | DOWN to CHANGE TARGET FPS", 10, GetScreenHeight() - 30, 20, GRAY)
        DrawText(TextFormat("TARGET FPS: %i", targetFPS), GetScreenWidth() - 220, 10, 20, LIME)
        DrawText(TextFormat("CURRENT FPS: %i", 1.0f/deltaTime), GetScreenWidth() - 220, 40, 20, GREEN)

    EndDrawing()

    '' NOTE: In case raylib is configured to SUPPORT_CUSTOM_FRAME_CONTROL, 
    '' Events polling, screen buffer swap and frame time control must be managed by the user

    SwapScreenBuffer()         '' Flip the back buffer to screen (front buffer)
    
    currentTime = GetTime()
    updateDrawTime = currentTime - previousTime
    
    if targetFPS > 0 then          '' We want a fixed frame rate
        waitTme = (1.0f / targetFPS) - updateDrawTime
        if waitTme > 0.0 then 
            WaitTime(waitTme)
            currentTime = GetTime()
            deltaTime = currentTime - previousTime
        end if
    else 
        deltaTime = updateDrawTime    '' Framerate could be variable
    end if

    previousTime = currentTime
    ''----------------------------------------------------------------------------------
loop

'' De-Initialization
''--------------------------------------------------------------------------------------
CloseWindow()        '' Close window and OpenGL context
''--------------------------------------------------------------------------------------