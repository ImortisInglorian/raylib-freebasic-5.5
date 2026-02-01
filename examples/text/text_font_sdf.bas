/'******************************************************************************************
*
*   raylib [text] example - Font SDF loading
*
*   Example originally created with raylib 1.3, last time updated with raylib 4.0
*
*   Example licensed under an unmodified zlib/libpng license, which is an OSI-certified,
*   BSD-like license that allows static linking with closed source software
*
*   Copyright (c) 2015-2024 Ramon Santamaria (@raysan5)
*
*******************************************************************************************'/

#include "../../raylib.bi"

#define GLSL_VERSION            330

'' Initialization
''--------------------------------------------------------------------------------------
const as long screenWidth = 800
const as long screenHeight = 450

InitWindow(screenWidth, screenHeight, "raylib [text] example - SDF fonts")

'' NOTE: Textures/Fonts MUST be loaded after Window initialization (OpenGL context is required)

dim as zstring * 50 msg = "Signed Distance Fields"

'' Loading file to memory
dim as long fileSize = 0
dim as zstring ptr fileData = LoadFileData("resources/anonymous_pro_bold.ttf", @fileSize)

'' Default font generation from TTF font
dim as Font fontDefault
fontDefault.baseSize = 16
fontDefault.glyphCount = 95

'' Loading font data from memory data
'' Parameters > font size: 16, no glyphs array provided (0), glyphs count: 95 (autogenerate chars array)
fontDefault.glyphs = LoadFontData(fileData, fileSize, 16, 0, 95, FONT_DEFAULT)
'' Parameters > glyphs count: 95, font size: 16, glyphs padding in image: 4 px, pack method: 0 (default)
dim as Image atlas = GenImageFontAtlas(fontDefault.glyphs, @fontDefault.recs, 95, 16, 4, 0)
fontDefault.texture = LoadTextureFromImage(atlas)
UnloadImage(atlas)

'' SDF font generation from TTF font
dim as Font fontSDF
fontSDF.baseSize = 16
fontSDF.glyphCount = 95
'' Parameters > font size: 16, no glyphs array provided (0), glyphs count: 0 (defaults to 95)
fontSDF.glyphs = LoadFontData(fileData, fileSize, 16, 0, 0, FONT_SDF)
'' Parameters > glyphs count: 95, font size: 16, glyphs padding in image: 0 px, pack method: 1 (Skyline algorythm)
atlas = GenImageFontAtlas(fontSDF.glyphs, @fontSDF.recs, 95, 16, 0, 1)
fontSDF.texture = LoadTextureFromImage(atlas)
UnloadImage(atlas)

UnloadFileData(fileData)      '' Free memory from loaded file

'' Load SDF required shader (we use default vertex shader)
dim as Shader shade = LoadShader(0, TextFormat("resources/shaders/glsl%i/sdf.fs", GLSL_VERSION))
SetTextureFilter(fontSDF.texture, TEXTURE_FILTER_BILINEAR)    '' Required for SDF font

dim as Vector2 fontPosition = Vector2(40, screenHeight/2.0f - 50)
dim as Vector2 textSize = Vector2(0.0f, 0.0f)
dim as single fontSize = 16.0f
dim as long currentFont = 0            '' 0 - fontDefault, 1 - fontSDF

SetTargetFPS(60)               '' Set our game to run at 60 frames-per-second
''--------------------------------------------------------------------------------------

'' Main game loop
do while not WindowShouldClose()    '' Detect window close button or ESC key
    '' Update
    ''----------------------------------------------------------------------------------
    fontSize += GetMouseWheelMove()*8.0f

    if fontSize < 6 then fontSize = 6

    if IsKeyDown(KEY_SPACE) then
        currentFont = 1
    else 
        currentFont = 0
    end if

    if currentFont = 0 then 
        textSize = MeasureTextEx(fontDefault, msg, fontSize, 0)
    else 
        textSize = MeasureTextEx(fontSDF, msg, fontSize, 0)
    end if

    fontPosition.x = GetScreenWidth()/2 - textSize.x/2
    fontPosition.y = GetScreenHeight()/2 - textSize.y/2 + 80
    ''----------------------------------------------------------------------------------

    '' Draw
    ''----------------------------------------------------------------------------------
    BeginDrawing()

        ClearBackground(RAYWHITE)

        if currentFont = 1 then
            '' NOTE: SDF fonts require a custom SDf shader to compute fragment color
            BeginShaderMode(shade)    '' Activate SDF font shader
                DrawTextEx(fontSDF, msg, fontPosition, fontSize, 0, BLACK)
            EndShaderMode()            '' Activate our default shader for next drawings

            DrawTexture(fontSDF.texture, 10, 10, BLACK)
        else
            DrawTextEx(fontDefault, msg, fontPosition, fontSize, 0, BLACK)
            DrawTexture(fontDefault.texture, 10, 10, BLACK)
        end if

        if currentFont = 1 then 
            DrawText("SDF!", 320, 20, 80, RED)
        else
            DrawText("default font", 315, 40, 30, GRAY)
        end if

        DrawText("FONT SIZE: 16.0", GetScreenWidth() - 240, 20, 20, DARKGRAY)
        DrawText(TextFormat("RENDER SIZE: %02.02f", fontSize), GetScreenWidth() - 240, 50, 20, DARKGRAY)
        DrawText("Use MOUSE WHEEL to SCALE TEXT!", GetScreenWidth() - 240, 90, 10, DARKGRAY)

        DrawText("HOLD SPACE to USE SDF FONT VERSION!", 340, GetScreenHeight() - 30, 20, MAROON)

    EndDrawing()
    ''----------------------------------------------------------------------------------
loop

'' De-Initialization
''--------------------------------------------------------------------------------------
UnloadFont(fontDefault)    '' Default font unloading
UnloadFont(fontSDF)        '' SDF font unloading

UnloadShader(shade)       '' Unload SDF shader

CloseWindow()              '' Close window and OpenGL context
''--------------------------------------------------------------------------------------