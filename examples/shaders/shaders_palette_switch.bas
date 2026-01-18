/'******************************************************************************************
*
*   raylib [shaders] example - Color palette switch
*
*   NOTE: This example requires raylib OpenGL 3.3 or ES2 versions for shaders support,
*         OpenGL 1.1 does not support shaders, recompile raylib to OpenGL 3.3 version.
*
*   NOTE: Shaders used in this example are #version 330 (OpenGL 3.3), to test this example
*         on OpenGL ES 2.0 platforms (Android, Raspberry Pi, HTML5), use #version 100 shaders
*         raylib comes with shaders ready for both versions, check raylib/shaders install folder
*
*   Example originally created with raylib 2.5, last time updated with raylib 3.7
*
*   Example contributed by Marco Lizza (@MarcoLizza) and reviewed by Ramon Santamaria (@raysan5)
*
*   Example licensed under an unmodified zlib/libpng license, which is an OSI-certified,
*   BSD-like license that allows static linking with closed source software
*
*   Copyright (c) 2019-2024 Marco Lizza (@MarcoLizza) and Ramon Santamaria (@raysan5)
*
*******************************************************************************************'/

#include "../../raylib.bi"

#define GLSL_VERSION            330


#define MAX_PALETTES            3
#define COLORS_PER_PALETTE      8
#define VALUES_PER_COLOR        3

dim as long palettes(MAX_PALETTES - 1, (COLORS_PER_PALETTE*VALUES_PER_COLOR) - 1) = { _
    { _
        0, 0, 0, _
        255, 0, 0, _
        0, 255, 0, _
        0, 0, 255, _
        0, 255, 255, _
        255, 0, 255, _
        255, 255, 0, _
        255, 255, 255 _
    }, _
    { _
        4, 12, 6, _
        17, 35, 24, _
        30, 58, 41, _
        48, 93, 66, _
        77, 128, 97, _
        137, 162, 87, _
        190, 220, 127, _
        238, 255, 204 _
    }, _
    { _
        21, 25, 26, _
        138, 76, 88, _
        217, 98, 117, _
        230, 184, 193, _
        69, 107, 115, _
        75, 151, 166, _
        165, 189, 194, _
        255, 245, 247 _
    } _
}

dim as zstring * 128 paletteText(...) = { _
    "3-BIT RGB", _
    "AMMO-8 (GameBoy-like)", _
    "RKBV (2-strip film)" _
}

'' Initialization
''--------------------------------------------------------------------------------------
const as long screenWidth = 800
const as long screenHeight = 450

InitWindow(screenWidth, screenHeight, "raylib [shaders] example - color palette switch")

'' Load shader to be used on some parts drawing
'' NOTE 1: Using GLSL 330 shader version, on OpenGL ES 2.0 use GLSL 100 shader version
'' NOTE 2: Defining 0 (NULL) for vertex shader forces usage of internal default vertex shader
dim as Shader shade = LoadShader(0, TextFormat("resources/shaders/glsl%i/palette_switch.fs", GLSL_VERSION))

'' Get variable (uniform) location on the shader to connect with the program
'' NOTE: If uniform variable could not be found in the shader, function returns -1
dim as long paletteLoc = GetShaderLocation(shade, "palette")

dim as long currentPalette = 0
dim as long lineHeight = screenHeight/COLORS_PER_PALETTE

SetTargetFPS(60)                       '' Set our game to run at 60 frames-per-second
''--------------------------------------------------------------------------------------

'' Main game loop
do while not WindowShouldClose()            '' Detect window close button or ESC key
    '' Update
    ''----------------------------------------------------------------------------------
    if IsKeyPressed(KEY_RIGHT) then 
        currentPalette += 1
    elseif IsKeyPressed(KEY_LEFT) then
        currentPalette -= 1
    end if

    if currentPalette >= MAX_PALETTES then
        currentPalette = 0
    elseif currentPalette < 0 then
        currentPalette = MAX_PALETTES - 1
    end if

    '' Send palette data to the shader to be used on drawing
    '' NOTE: We are sending RGB triplets w/o the alpha channel
    SetShaderValueV(shade, paletteLoc, @palettes(currentPalette, 0), SHADER_UNIFORM_IVEC3, COLORS_PER_PALETTE)
    ''----------------------------------------------------------------------------------

    '' Draw
    ''----------------------------------------------------------------------------------
    BeginDrawing()

        ClearBackground(RAYWHITE)

        BeginShaderMode(shade)

            for i as integer = 0 to COLORS_PER_PALETTE - 1
                '' Draw horizontal screen-wide rectangles with increasing "palette index"
                '' The used palette index is encoded in the RGB components of the pixel
                DrawRectangle(0, lineHeight*i, GetScreenWidth(), lineHeight, RLColor(i, i, i, 255))
            next

        EndShaderMode()

        DrawText("< >", 10, 10, 30, DARKBLUE)
        DrawText("CURRENT PALETTE:", 60, 15, 20, RAYWHITE)
        DrawText(paletteText(currentPalette), 300, 15, 20, RED)

        DrawFPS(700, 15)

    EndDrawing()
    ''----------------------------------------------------------------------------------
loop

'' De-Initialization
''--------------------------------------------------------------------------------------
UnloadShader(shade)       '' Unload shader

CloseWindow()              '' Close window and OpenGL context
''--------------------------------------------------------------------------------------