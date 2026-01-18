/'******************************************************************************************
*
*   raylib [text] example - Codepoints loading
*
*   Example originally created with raylib 4.2, last time updated with raylib 2.5
*
*   Example licensed under an unmodified zlib/libpng license, which is an OSI-certified,
*   BSD-like license that allows static linking with closed source software
*
*   Copyright (c) 2022-2024 Ramon Santamaria (@raysan5)
*
*******************************************************************************************'/

#include "../../raylib.bi"

#include "crt/stdlib.bi"         '' Required for: calloc(), realloc(), free()
#include "crt/string.bi"         '' Required for: memcpy()

'' Text to be displayed, must be UTF-8 (save this code file as UTF-8)
'' NOTE: It can contain all the required text for the game,
'' this text will be scanned to get all the required codepoints
dim shared as wstring * 58 text = !"いろはにほへと　ちりぬるを\nわかよたれそ　つねならむ\nうゐのおくやま　けふこえて\nあさきゆめみし　ゑひもせす"

'' Remove codepoint duplicates if requested
declare function CodepointRemoveDuplicates (codepoints as long ptr, codepointCount as long, codepointResultCount as long ptr) as long ptr

''------------------------------------------------------------------------------------
'' Program main entry point
''------------------------------------------------------------------------------------

'' Initialization
''--------------------------------------------------------------------------------------
const as long screenWidth = 800
const as long screenHeight = 450

InitWindow(screenWidth, screenHeight, "raylib [text] example - codepoints loading")

'' Get codepoints from text
dim as long codepointCount = 0
dim as long ptr codepoints = LoadCodepoints(text, @codepointCount)

'' Removed duplicate codepoints to generate smaller font atlas
dim as long codepointsNoDupsCount = 0
dim as long ptr codepointsNoDups = CodepointRemoveDuplicates(codepoints, codepointCount, @codepointsNoDupsCount)
UnloadCodepoints(codepoints)

'' Load font containing all the provided codepoint glyphs
'' A texture font atlas is automatically generated
dim as Font curFont = LoadFontEx("resources/DotGothic16-Regular.ttf", 36, codepointsNoDups, codepointsNoDupsCount)

'' Set bilinear scale filter for better font scaling
SetTextureFilter(curFont.texture, TEXTURE_FILTER_BILINEAR)

SetTextLineSpacing(20)         '' Set line spacing for multiline text (when line breaks are included '\n')

'' Free codepoints, atlas has already been generated
free(codepointsNoDups)

dim as boolean showFontAtlas = false

dim as long codepointSize = 0
dim as wstring ptr tPtr = @text

SetTargetFPS(60)               '' Set our game to run at 60 frames-per-second
''--------------------------------------------------------------------------------------

'' Main game loop
do while not WindowShouldClose()    '' Detect window close button or ESC key
    '' Update
    ''----------------------------------------------------------------------------------
    if IsKeyPressed(KEY_SPACE) then showFontAtlas = not showFontAtlas

    '' Testing code: getting next and previous codepoints on provided text
    if IsKeyPressed(KEY_RIGHT) then
        '' Get next codepoint in string and move pointer
        GetCodepointNext(tPtr, @codepointSize)
        tPtr += codepointSize
    elseif IsKeyPressed(KEY_LEFT) then
        '' Get previous codepoint in string and move pointer
        GetCodepointPrevious(tPtr, @codepointSize)
        tPtr -= codepointSize
    end if
    ''----------------------------------------------------------------------------------

    '' Draw
    ''----------------------------------------------------------------------------------
    BeginDrawing()

        ClearBackground(RAYWHITE)

        DrawRectangle(0, 0, GetScreenWidth(), 70, BLACK)
        DrawText(TextFormat("Total codepoints contained in provided text: %i", codepointCount), 10, 10, 20, GREEN)
        DrawText(TextFormat("Total codepoints required for font atlas (duplicates excluded): %i", codepointsNoDupsCount), 10, 40, 20, GREEN)

        if showFontAtlas then
            '' Draw generated font texture atlas containing provided codepoints
            DrawTexture(curFont.texture, 150, 100, BLACK)
            DrawRectangleLines(150, 100, curFont.texture.width, curFont.texture.height, BLACK)
        else
            '' Draw provided text with laoded font, containing all required codepoint glyphs
            DrawTextEx(curFont, text, Vector2(160, 110), 48, 5, BLACK)
        end if

        DrawText("Press SPACE to toggle font atlas view!", 10, GetScreenHeight() - 30, 20, GRAY)

    EndDrawing()
    ''----------------------------------------------------------------------------------
loop

'' De-Initialization
''--------------------------------------------------------------------------------------
UnloadFont(curFont)     '' Unload font

CloseWindow()        '' Close window and OpenGL context
''--------------------------------------------------------------------------------------

'' Remove codepoint duplicates if requested
'' WARNING: This process could be a bit slow if there text to process is very long
function CodepointRemoveDuplicates(codepoints as long ptr, codepointCount as long, codepointsResultCount as long ptr) as long ptr
    dim as long codepointsNoDupsCount = codepointCount
    dim as long ptr codepointsNoDups = callocate(codepointCount, sizeof(long))
    memcpy(codepointsNoDups, codepoints, codepointCount*sizeof(long))

    '' Remove duplicates
    for i as integer = 0 to codepointsNoDupsCount - 1
        for j as integer = i + 1 to codepointsNoDupsCount - 1
            if codepointsNoDups[i] = codepointsNoDups[j] then
                for k as integer = j to codepointsNoDupsCount - 1
                    codepointsNoDups[k] = codepointsNoDups[k + 1]
                next
                codepointsNoDupsCount -= 1 
                j -= 1
            end if
        next
    next

    '' NOTE: The size of codepointsNoDups is the same as original array but
    '' only required positions are filled (codepointsNoDupsCount)

    *codepointsResultCount = codepointsNoDupsCount
    return codepointsNoDups
end function