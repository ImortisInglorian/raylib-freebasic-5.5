/'******************************************************************************************
*
*   raylib [rlgl] example - compute shader - Conway's Game of Life
*
*   NOTE: This example requires raylib OpenGL 4.3 versions for compute shaders support,
*         shaders used in this example are #version 430 (OpenGL 4.3)
*
*   Example originally created with raylib 4.0, last time updated with raylib 2.5
*
*   Example contributed by Teddy Astie (@tsnake41) and reviewed by Ramon Santamaria (@raysan5)
*
*   Example licensed under an unmodified zlib/libpng license, which is an OSI-certified,
*   BSD-like license that allows static linking with closed source software
*
*   Copyright (c) 2021-2024 Teddy Astie (@tsnake41)
*
*******************************************************************************************'/

#include "../../raylib.bi"
#include "../../rlgl.bi"

#include "crt/stdlib.bi"

'' IMPORTANT: This must match gol*.glsl GOL_WIDTH constant.
'' This must be a multiple of 16 (check golLogic compute dispatch).
#define GOL_WIDTH 768

'' Maximum amount of queued draw commands (squares draw from mouse down events).
#define MAX_BUFFERED_TRANSFERTS 48

'' Game Of Life Update Command
type GolUpdateCmd
    as ulong x         '' x coordinate of the gol command
    as ulong y         '' y coordinate of the gol command
    as ulong w         '' width of the filled zone
    as ulong enabled   '' whether to enable or disable zone
end type

'' Game Of Life Update Commands SSBO
type GolUpdateSSBO
    as ulong count
    as GolUpdateCmd commands(MAX_BUFFERED_TRANSFERTS - 1)
end type


'' Initialization
''--------------------------------------------------------------------------------------
InitWindow(GOL_WIDTH, GOL_WIDTH, "raylib [rlgl] example - compute shader - game of life")

dim as Vector2 resolution = Vector2(GOL_WIDTH, GOL_WIDTH)
dim as ulong brushSize = 8

'' Game of Life logic compute shader
dim as zstring ptr golLogicCode = LoadFileText("resources/shaders/glsl430/gol.glsl")
dim as ulong golLogicShader = rlCompileShader(golLogicCode, RL_COMPUTE_SHADER)
dim as ulong golLogicProgram = rlLoadComputeShaderProgram(golLogicShader)
UnloadFileText(golLogicCode)

'' Game of Life logic render shader
dim as Shader golRenderShader = LoadShader(NULL, "resources/shaders/glsl430/gol_render.glsl")
dim as long resUniformLoc = GetShaderLocation(golRenderShader, "resolution")

'' Game of Life transfert shader (CPU<->GPU download and upload)
dim as zstring ptr golTransfertCode = LoadFileText("resources/shaders/glsl430/gol_transfert.glsl")
dim as ulong golTransfertShader = rlCompileShader(golTransfertCode, RL_COMPUTE_SHADER)
dim as ulong golTransfertProgram = rlLoadComputeShaderProgram(golTransfertShader)
UnloadFileText(golTransfertCode)

'' Load shader storage buffer object (SSBO), id returned
dim as ulong ssboA = rlLoadShaderBuffer(GOL_WIDTH*GOL_WIDTH*sizeof(ulong), NULL, RL_DYNAMIC_COPY)
dim as ulong ssboB = rlLoadShaderBuffer(GOL_WIDTH*GOL_WIDTH*sizeof(ulong), NULL, RL_DYNAMIC_COPY)
dim as ulong ssboTransfert = rlLoadShaderBuffer(sizeof(GolUpdateSSBO), NULL, RL_DYNAMIC_COPY)

dim as GolUpdateSSBO transfertBuffer

'' Create a white texture of the size of the window to update
'' each pixel of the window using the fragment shader: golRenderShader
dim as Image whiteImage = GenImageColor(GOL_WIDTH, GOL_WIDTH, WHITE)
dim as Texture whiteTex = LoadTextureFromImage(whiteImage)
UnloadImage(whiteImage)
''--------------------------------------------------------------------------------------

'' Main game loop
do while not WindowShouldClose()
    '' Update
    ''----------------------------------------------------------------------------------
    brushSize += GetMouseWheelMove()

    if (IsMouseButtonDown(MOUSE_BUTTON_LEFT) or IsMouseButtonDown(MOUSE_BUTTON_RIGHT)) _
        and (transfertBuffer.count < MAX_BUFFERED_TRANSFERTS) then
        '' Buffer a new command
        transfertBuffer.commands(transfertBuffer.count).x = GetMouseX() - brushSize/2
        transfertBuffer.commands(transfertBuffer.count).y = GetMouseY() - brushSize/2
        transfertBuffer.commands(transfertBuffer.count).w = brushSize
        transfertBuffer.commands(transfertBuffer.count).enabled = IsMouseButtonDown(MOUSE_BUTTON_LEFT)
        transfertBuffer.count += 1
    elseif transfertBuffer.count > 0 then '' Process transfert buffer
        '' Send SSBO buffer to GPU
        rlUpdateShaderBuffer(ssboTransfert, @transfertBuffer, sizeof(GolUpdateSSBO), 0)

        '' Process SSBO commands on GPU
        rlEnableShader(golTransfertProgram)
        rlBindShaderBuffer(ssboA, 1)
        rlBindShaderBuffer(ssboTransfert, 3)
        rlComputeShaderDispatch(transfertBuffer.count, 1, 1) '' Each GPU unit will process a command!
        rlDisableShader()

        transfertBuffer.count = 0
    else
        '' Process game of life logic
        rlEnableShader(golLogicProgram)
        rlBindShaderBuffer(ssboA, 1)
        rlBindShaderBuffer(ssboB, 2)
        rlComputeShaderDispatch(GOL_WIDTH/16, GOL_WIDTH/16, 1)
        rlDisableShader()

        '' ssboA <-> ssboB
        dim as long temp = ssboA
        ssboA = ssboB
        ssboB = temp
    end if

    rlBindShaderBuffer(ssboA, 1)
    SetShaderValue(golRenderShader, resUniformLoc, @resolution, SHADER_UNIFORM_VEC2)
    ''----------------------------------------------------------------------------------

    '' Draw
    ''----------------------------------------------------------------------------------
    BeginDrawing()

        ClearBackground(BLANK)

        BeginShaderMode(golRenderShader)
            DrawTexture(whiteTex, 0, 0, WHITE)
        EndShaderMode()

        DrawRectangleLines(GetMouseX() - brushSize/2, GetMouseY() - brushSize/2, brushSize, brushSize, RED)

        DrawText("Use Mouse wheel to increase/decrease brush size", 10, 10, 20, WHITE)
        DrawFPS(GetScreenWidth() - 100, 10)

    EndDrawing()
    ''----------------------------------------------------------------------------------
loop

'' De-Initialization
''--------------------------------------------------------------------------------------
'' Unload shader buffers objects.
rlUnloadShaderBuffer(ssboA)
rlUnloadShaderBuffer(ssboB)
rlUnloadShaderBuffer(ssboTransfert)

'' Unload compute shader programs
rlUnloadShaderProgram(golTransfertProgram)
rlUnloadShaderProgram(golLogicProgram)

UnloadTexture(whiteTex)            '' Unload white texture
UnloadShader(golRenderShader)      '' Unload rendering fragment shader

CloseWindow()                      '' Close window and OpenGL context
''--------------------------------------------------------------------------------------