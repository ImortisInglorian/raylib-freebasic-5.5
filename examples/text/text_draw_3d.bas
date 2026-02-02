/'******************************************************************************************
*
*   raylib [text] example - Draw 3d
*
*   NOTE: Draw a 2D text in 3D space, each letter is drawn in a quad (or 2 quads if backface is set)
*   where the texture coodinates of each quad map to the texture coordinates of the glyphs
*   inside the font texture.
*
*   A more efficient approach, i believe, would be to render the text in a render texture and
*   map that texture to a plane and render that, or maybe a shader but my method allows more
*   flexibility...for example to change position of each letter individually to make somethink
*   like a wavy text effect.
*    
*   Special thanks to:
*        @Nighten for the DrawTextStyle() code https:''github.com/NightenDushi/Raylib_DrawTextStyle
*        Chris Camacho (codifies - http:''bedroomcoders.co.uk/) for the alpha discard shader
*
*   Example originally created with raylib 3.5, last time updated with raylib 4.0
*
*   Example contributed by Vlad Adrian (@demizdor) and reviewed by Ramon Santamaria (@raysan5)
*
*   Example licensed under an unmodified zlib/libpng license, which is an OSI-certified,
*   BSD-like license that allows static linking with closed source software
*
*   Copyright (c) 2021-2024 Vlad Adrian (@demizdor)
*
*******************************************************************************************'/

#include "../../raylib.bi"
#include "../../rlgl.bi"

#define NULL 0

'' To make it work with the older RLGL module just comment the line below
#define RAYLIB_NEW_RLGL

''--------------------------------------------------------------------------------------
'' Globals
''--------------------------------------------------------------------------------------
#define LETTER_BOUNDRY_SIZE     0.25f
#define TEXT_MAX_LAYERS         32
#define LETTER_BOUNDRY_COLOR    VIOLET

dim shared as boolean SHOW_LETTER_BOUNDRY = false
dim shared as boolean SHOW_TEXT_BOUNDRY = false

''--------------------------------------------------------------------------------------
'' Data Types definition
''--------------------------------------------------------------------------------------

'' Configuration structure for waving the text
type WaveTextConfig
    as Vector3 waveRange
    as Vector3 waveSpeed
    as Vector3 waveOffset
end type

''--------------------------------------------------------------------------------------
'' Module Functions Declaration
''--------------------------------------------------------------------------------------
'' Draw a codepoint in 3D space
declare sub DrawTextCodepoint3D(fnt as Font, codepoint as long, position as Vector3, fontSize as single, backface as RLBOOL, tint as RLColor)
'' Draw a 2D text in 3D space
declare sub DrawText3D(fnt as Font, text as const zstring ptr, position as Vector3, fontSize as single, fontSpacing as single, lineSpacing as single, backface as RLBOOL, tint as RLColor)
'' Measure a text in 3D. For some reason `MeasureTextEx()` just doesn't seem to work so i had to use this instead.
declare function MeasureText3D(fnt as Font, text as const zstring ptr, fontSize as single, fontSpacing as single, lineSpacing as single) as Vector3

'' Draw a 2D text in 3D space and wave the parts that start with `~~` and end with `~~`.
'' This is a modified version of the original code by @Nighten found here https:''github.com/NightenDushi/Raylib_DrawTextStyle
declare sub DrawTextWave3D(fnt as Font, text as const zstring ptr, position as Vector3, fontSize as single, fontSpacing as single, lineSpacing as single, backface as RLBOOL, config as WaveTextConfig ptr, tme as single, tint as RLColor)
'' Measure a text in 3D ignoring the `~~` chars.
declare function MeasureTextWave3D(fnt as Font, text as const zstring ptr, fontSize as single, fontSpacing as single, lineSpacing as single) as Vector3
'' Generates a nice color with a random hue
declare function GenerateRandomColor(s as single, v as single) as RLColor

''------------------------------------------------------------------------------------
'' Program main entry point
''------------------------------------------------------------------------------------
'' Initialization
''--------------------------------------------------------------------------------------
const as long screenWidth = 800
const as long screenHeight = 450

SetConfigFlags(FLAG_MSAA_4X_HINT or FLAG_VSYNC_HINT)
InitWindow(screenWidth, screenHeight, "raylib [text] example - draw 2D text in 3D")

dim as boolean spin = true        '' Spin the camera?
dim as boolean multicolor = false '' Multicolor mode

'' Define the camera to look into our 3d world
dim as Camera3D cam
with cam
    .position = Vector3(-10.0f, 15.0f, -10.0f)   '' Camera position
    .target = Vector3(0.0f, 0.0f, 0.0f)          '' Camera looking at point
    .up = Vector3(0.0f, 1.0f, 0.0f)              '' Camera up vector (rotation towards target)
    .fovy = 45.0f                                    '' Camera field-of-view Y
    .projection = CAMERA_PERSPECTIVE                 '' Camera projection type
end with

dim as long camera_mode = CAMERA_ORBITAL

dim as Vector3 cubePosition = Vector3(0.0f, 1.0f, 0.0f)
dim as Vector3 cubeSize = Vector3(2.0f, 2.0f, 2.0f)

'' Use the default font
dim as Font fnt = GetFontDefault()
dim as single fontSize = 8.0f
dim as single fontSpacing = 0.5f
dim as single lineSpacing = -1.0f

'' Set the text (using markdown!)
dim as zstring * 64 text = "Hello ~~World~~ in 3D!"
dim as Vector3 tbox
dim as long layers = 1
dim as long quads = 0
dim as single layerDistance = 0.01f

dim as WaveTextConfig wcfg
with wcfg
    .waveSpeed.x = 3.0f
    .waveSpeed.y = 3.0f 
    .waveSpeed.z = 0.5f
    .waveOffset.x = 0.35f
    .waveOffset.y = 0.35f
    .waveOffset.z = 0.35f
    .waveRange.x = 0.45f
    .waveRange.y = 0.45f
    .waveRange.z = 0.45f
end with

dim as single tme = 0.0f

'' Setup a light and dark color
dim as RLColor light = MAROON
dim as RLColor dark = RED

'' Load the alpha discard shader
dim as Shader alphaDiscard = LoadShader(NULL, "resources/shaders/glsl330/alpha_discard.fs")

'' Array filled with multiple random colors (when multicolor mode is set)
dim as RLColor multi(TEXT_MAX_LAYERS - 1)

DisableCursor()                    '' Limit cursor to relative movement inside the window

SetTargetFPS(60)                   '' Set our game to run at 60 frames-per-second
''--------------------------------------------------------------------------------------

'' Main game loop
do while not WindowShouldClose()        '' Detect window close button or ESC key
    '' Update
    ''----------------------------------------------------------------------------------
    UpdateCamera(@cam, camera_mode)
    
    '' Handle font files dropped
    if IsFileDropped() then
        dim as FilePathList droppedFiles = LoadDroppedFiles()

        '' NOTE: We only support first ttf file dropped
        if IsFileExtension(droppedFiles.paths[0], ".ttf") then
            UnloadFont(fnt)
            fnt = LoadFontEx(droppedFiles.paths[0], fontSize, 0, 0)
        elseif IsFileExtension(droppedFiles.paths[0], ".fnt") then
            UnloadFont(fnt)
            fnt = LoadFont(droppedFiles.paths[0])
            fontSize = fnt.baseSize
        end if
        
        UnloadDroppedFiles(droppedFiles)    '' Unload filepaths from memory
    end if

    '' Handle Events
    if IsKeyPressed(KEY_F1) then SHOW_LETTER_BOUNDRY =  not SHOW_LETTER_BOUNDRY
    if IsKeyPressed(KEY_F2) then SHOW_TEXT_BOUNDRY =  not SHOW_TEXT_BOUNDRY
    if IsKeyPressed(KEY_F3) then
        '' Handle camera change
        spin =  not spin
        '' we need to reset the camera when changing modes
        with cam
            .target = Vector3(0.0f, 0.0f, 0.0f)          '' Camera looking at point
            .up = Vector3(0.0f, 1.0f, 0.0f)              '' Camera up vector (rotation towards target)
            .fovy = 45.0f                                    '' Camera field-of-view Y
            .projection = CAMERA_PERSPECTIVE                 '' Camera mode type
        

            if spin then
                .position = Vector3(-10.0f, 15.0f, -10.0f)   '' Camera position
                camera_mode = CAMERA_ORBITAL
            else
                .position = Vector3(10.0f, 10.0f, -10.0f)   '' Camera position
                camera_mode = CAMERA_FREE
            end if
        end with
    end if

    '' Handle clicking the cube
    if IsMouseButtonPressed(MOUSE_BUTTON_LEFT) then
        dim as Ray ry = GetScreenToWorldRay(GetMousePosition(), cam)

        '' Check collision between ray and box
        dim as RayCollision collision = GetRayCollisionBox(ry, _
                        BoundingBox(Vector3(cubePosition.x - cubeSize.x/2, cubePosition.y - cubeSize.y/2, cubePosition.z - cubeSize.z/2), _
                                        Vector3(cubePosition.x + cubeSize.x/2, cubePosition.y + cubeSize.y/2, cubePosition.z + cubeSize.z/2 ))) 
        if collision.hit = RLTRUE then
            '' Generate new random colors
            light = GenerateRandomColor(0.5f, 0.78f)
            dark = GenerateRandomColor(0.4f, 0.58f)
        end if
    end if

    '' Handle text layers changes
    if IsKeyPressed(KEY_HOME) then 
        if layers > 1 then layers -= 1
    elseif IsKeyPressed(KEY_END) then 
        if layers < TEXT_MAX_LAYERS then layers += 1
    end if

    '' Handle text changes
    if IsKeyPressed(KEY_LEFT) then 
        fontSize -= 0.5f
    elseif IsKeyPressed(KEY_RIGHT) then 
        fontSize += 0.5f
    elseif IsKeyPressed(KEY_UP) then
        fontSpacing -= 0.1f
    elseif IsKeyPressed(KEY_DOWN) then 
        fontSpacing += 0.1f
    elseif IsKeyPressed(KEY_PAGE_UP) then
        lineSpacing -= 0.1f
    elseif IsKeyPressed(KEY_PAGE_DOWN) then
        lineSpacing += 0.1f
    elseif IsKeyDown(KEY_INSERT) then
        layerDistance -= 0.001f
    elseif IsKeyDown(KEY_DELETE) then
        layerDistance += 0.001f
    elseif IsKeyPressed(KEY_TAB) then
        multicolor = not multicolor   '' Enable /disable multicolor mode

        if multicolor then
            '' Fill color array with random colors
            for i as integer = 0 to TEXT_MAX_LAYERS - 1
                multi(i) = GenerateRandomColor(0.5f, 0.8f)
                multi(i).a = GetRandomValue(0, 255)
            next
        end if
    end if

    '' Handle text input
    dim as long ch = GetCharPressed()
    if IsKeyPressed(KEY_BACKSPACE) then
        '' Remove last char
        dim as long length = TextLength(text)
        if length > 0 then text[length - 1] = asc(!"\0")
    elseif IsKeyPressed(KEY_ENTER) then
        '' handle newline
        dim as long length = TextLength(text)
        if length < len(text) - 1 then
            text[length] = asc(!"\n")
            text[length+1] = asc(!"\0")
        end if
    else
        '' append only printable chars
        dim as long length = TextLength(text)
        if length < len(text) - 1 then
            text[length] = ch
            text[length+1] = asc(!"\0")
        end if
    end if

    '' Measure 3D text so we can center it
    tbox = MeasureTextWave3D(fnt, text, fontSize, fontSpacing, lineSpacing)

    quads = 0                      '' Reset quad counter
    tme += GetFrameTime()          '' Update timer needed by `DrawTextWave3D()`
    ''----------------------------------------------------------------------------------

    '' Draw
    ''----------------------------------------------------------------------------------
    BeginDrawing()

        ClearBackground(RAYWHITE)

        BeginMode3D(cam)
            DrawCubeV(cubePosition, cubeSize, dark)
            DrawCubeWires(cubePosition, 2.1f, 2.1f, 2.1f, light)

            DrawGrid(10, 2.0f)

            '' Use a shader to handle the depth buffer issue with transparent textures
            '' NOTE: more info at https:''bedroomcoders.co.uk/raylib-billboards-advanced-use/
            BeginShaderMode(alphaDiscard)

                '' Draw the 3D text above the red cube
                rlPushMatrix()
                    rlRotatef(90.0f, 1.0f, 0.0f, 0.0f)
                    rlRotatef(90.0f, 0.0f, 0.0f, -1.0f)

                    for i as integer = 0 to layers - 1
                        dim as RLColor clr = light
                        if multicolor then clr = multi(i)
                        DrawTextWave3D(fnt, text, Vector3(-tbox.x/2.0f, layerDistance*i, -4.5f), fontSize, fontSpacing, lineSpacing, true, @wcfg, tme, clr)
                    next

                    '' Draw the text boundry if set
                    if SHOW_TEXT_BOUNDRY then DrawCubeWiresV(Vector3(0.0f, 0.0f, -4.5f + tbox.z/2), tbox, dark)
                rlPopMatrix()

                '' Don't draw the letter boundries for the 3D text below
                dim as boolean slb = SHOW_LETTER_BOUNDRY
                SHOW_LETTER_BOUNDRY = false

                '' Draw 3D options (use default font)
                ''-------------------------------------------------------------------------
                rlPushMatrix()
                    rlRotatef(180.0f, 0.0f, 1.0f, 0.0f)
                    dim as zstring * 64 opt = *TextFormat("< SIZE: %2.1f >", fontSize)
                    quads += TextLength(opt)
                    dim as Vector3 m = MeasureText3D(GetFontDefault(), opt, 8.0f, 1.0f, 0.0f)
                    dim as Vector3 ps = Vector3(-m.x/2.0f, 0.01f, 2.0f)
                    DrawText3D(GetFontDefault(), opt, ps, 8.0f, 1.0f, 0.0f, false, BLUE)
                    ps.z += 0.5f + m.z

                    opt = *TextFormat("< SPACING: %2.1f >", fontSpacing)
                    quads += TextLength(opt)
                    m = MeasureText3D(GetFontDefault(), opt, 8.0f, 1.0f, 0.0f)
                    ps.x = -m.x/2.0f
                    DrawText3D(GetFontDefault(), opt, ps, 8.0f, 1.0f, 0.0f, false, BLUE)
                    ps.z += 0.5f + m.z

                    opt = *TextFormat("< LINE: %2.1f >", lineSpacing)
                    quads += TextLength(opt)
                    m = MeasureText3D(GetFontDefault(), opt, 8.0f, 1.0f, 0.0f)
                    ps.x = -m.x/2.0f
                    DrawText3D(GetFontDefault(), opt, ps, 8.0f, 1.0f, 0.0f, false, BLUE)
                    ps.z += 1.0f + m.z

                    opt = *TextFormat("< LBOX: %3s >", iif(slb, "ON", "OFF"))
                    quads += TextLength(opt)
                    m = MeasureText3D(GetFontDefault(), opt, 8.0f, 1.0f, 0.0f)
                    ps.x = -m.x/2.0f
                    DrawText3D(GetFontDefault(), opt, ps, 8.0f, 1.0f, 0.0f, false, RED)
                    ps.z += 0.5f + m.z

                    opt = *TextFormat("< TBOX: %3s >", iif(SHOW_TEXT_BOUNDRY, "ON", "OFF"))
                    quads += TextLength(opt)
                    m = MeasureText3D(GetFontDefault(), opt, 8.0f, 1.0f, 0.0f)
                    ps.x = -m.x/2.0f
                    DrawText3D(GetFontDefault(), opt, ps, 8.0f, 1.0f, 0.0f, false, RED)
                    ps.z += 0.5f + m.z

                    opt = *TextFormat("< LAYER DISTANCE: %.3f >", layerDistance)
                    quads += TextLength(opt)
                    m = MeasureText3D(GetFontDefault(), opt, 8.0f, 1.0f, 0.0f)
                    ps.x = -m.x/2.0f
                    DrawText3D(GetFontDefault(), opt, ps, 8.0f, 1.0f, 0.0f, false, DARKPURPLE)
                rlPopMatrix()
                ''-------------------------------------------------------------------------

                '' Draw 3D info text (use default font)
                ''-------------------------------------------------------------------------
                opt = "All the text displayed here is in 3D"
                quads += 36
                m = MeasureText3D(GetFontDefault(), opt, 10.0f, 0.5f, 0.0f)
                ps = Vector3(-m.x/2.0f, 0.01f, 2.0f)
                DrawText3D(GetFontDefault(), opt, ps, 10.0f, 0.5f, 0.0f, false, DARKBLUE)
                ps.z += 1.5f + m.z

                opt = "press [Left]/[Right] to change the font size"
                quads += 44
                m = MeasureText3D(GetFontDefault(), opt, 6.0f, 0.5f, 0.0f)
                ps.x = -m.x/2.0f
                DrawText3D(GetFontDefault(), opt, ps, 6.0f, 0.5f, 0.0f, false, DARKBLUE)
                ps.z += 0.5f + m.z

                opt = "press [Up]/[Down] to change the font spacing"
                quads += 44
                m = MeasureText3D(GetFontDefault(), opt, 6.0f, 0.5f, 0.0f)
                ps.x = -m.x/2.0f
                DrawText3D(GetFontDefault(), opt, ps, 6.0f, 0.5f, 0.0f, false, DARKBLUE)
                ps.z += 0.5f + m.z

                opt = "press [PgUp]/[PgDown] to change the line spacing"
                quads += 48
                m = MeasureText3D(GetFontDefault(), opt, 6.0f, 0.5f, 0.0f)
                ps.x = -m.x/2.0f
                DrawText3D(GetFontDefault(), opt, ps, 6.0f, 0.5f, 0.0f, false, DARKBLUE)
                ps.z += 0.5f + m.z

                opt = "press [F1] to toggle the letter boundry"
                quads += 39
                m = MeasureText3D(GetFontDefault(), opt, 6.0f, 0.5f, 0.0f)
                ps.x = -m.x/2.0f
                DrawText3D(GetFontDefault(), opt, ps, 6.0f, 0.5f, 0.0f, false, DARKBLUE)
                ps.z += 0.5f + m.z

                opt = "press [F2] to toggle the text boundry"
                quads += 37
                m = MeasureText3D(GetFontDefault(), opt, 6.0f, 0.5f, 0.0f)
                ps.x = -m.x/2.0f
                DrawText3D(GetFontDefault(), opt, ps, 6.0f, 0.5f, 0.0f, false, DARKBLUE)
                ''-------------------------------------------------------------------------

                SHOW_LETTER_BOUNDRY = slb
            EndShaderMode()

        EndMode3D()

        '' Draw 2D info text & stats
        ''-------------------------------------------------------------------------
        DrawText(!"Drag & drop a font file to change the font!\nType something, see what happens!\n\nPress [F3] to toggle the camera", 10, 35, 10, BLACK)

        quads += TextLength(text)*2*layers
        dim as zstring * 64 tmp = *TextFormat("%2i layer(s) | %s camera | %4i quads (%4i verts)", layers, iif(spin, "ORBITAL", "FREE"), quads, quads*4)
        dim as long wid = MeasureText(tmp, 10)
        DrawText(tmp, screenWidth - 20 - wid, 10, 10, DARKGREEN)

        tmp = "[Home]/[End] to add/remove 3D text layers"
        wid = MeasureText(tmp, 10)
        DrawText(tmp, screenWidth - 20 - wid, 25, 10, DARKGRAY)

        tmp = "[Insert]/[Delete] to increase/decrease distance between layers"
        wid = MeasureText(tmp, 10)
        DrawText(tmp, screenWidth - 20 - wid, 40, 10, DARKGRAY)

        tmp = "click the [CUBE] for a random color"
        wid = MeasureText(tmp, 10)
        DrawText(tmp, screenWidth - 20 - wid, 55, 10, DARKGRAY)

        tmp = "[Tab] to toggle multicolor mode"
        wid = MeasureText(tmp, 10)
        DrawText(tmp, screenWidth - 20 - wid, 70, 10, DARKGRAY)
        ''-------------------------------------------------------------------------

        DrawFPS(10, 10)

    EndDrawing()
    ''----------------------------------------------------------------------------------
loop

'' De-Initialization
''--------------------------------------------------------------------------------------
UnloadFont(fnt)
CloseWindow()        '' Close window and OpenGL context
''--------------------------------------------------------------------------------------

''--------------------------------------------------------------------------------------
'' Module Functions Definitions
''--------------------------------------------------------------------------------------
'' Draw codepoint at specified position in 3D space
sub DrawTextCodepoint3D(fnt as Font, codepoint as long, position as Vector3, fontSize as single, backface as RLBOOL, tint as RLColor)
    '' Character index position in sprite font
    '' NOTE: In case a codepoint is not available in the font, index returned points to '?'
    dim as long index = GetGlyphIndex(fnt, codepoint)
    dim as single scale = fontSize/fnt.baseSize

    '' Character destination rectangle on screen
    '' NOTE: We consider charsPadding on drawing
    position.x += (fnt.glyphs[index].offsetX - fnt.glyphPadding)/fnt.baseSize*scale
    position.z += (fnt.glyphs[index].offsetY - fnt.glyphPadding)/fnt.baseSize*scale

    '' Character source rectangle from font texture atlas
    '' NOTE: We consider chars padding when drawing, it could be required for outline/glow shader effects
    dim as Rectangle srcRec = Rectangle( _
                              fnt.recs[index].x - fnt.glyphPadding, fnt.recs[index].y - fnt.glyphPadding, _
                              fnt.recs[index].width + 2.0f*fnt.glyphPadding, fnt.recs[index].height + 2.0f*fnt.glyphPadding)

    dim as single wid = (fnt.recs[index].width + 2.0f*fnt.glyphPadding)/fnt.baseSize*scale
    dim as single height = (fnt.recs[index].height + 2.0f*fnt.glyphPadding)/fnt.baseSize*scale

    if fnt.texture.id > 0 then
        dim as single x = 0.0f
        dim as single y = 0.0f
        dim as single z = 0.0f

        '' normalized texture coordinates of the glyph inside the font texture (0.0f -> 1.0f)
        dim as single tx = srcRec.x/fnt.texture.width
        dim as single ty = srcRec.y/fnt.texture.height
        dim as single tw = (srcRec.x+srcRec.width)/fnt.texture.width
        dim as single th = (srcRec.y+srcRec.height)/fnt.texture.height

        if (SHOW_LETTER_BOUNDRY) then DrawCubeWiresV(Vector3(position.x + width/2, position.y, position.z + height/2), Vector3(wid, LETTER_BOUNDRY_SIZE, height), LETTER_BOUNDRY_COLOR)

        rlCheckRenderBatchLimit(4 + 4 * backface)
        rlSetTexture(fnt.texture.id)

        rlPushMatrix()
            rlTranslatef(position.x, position.y, position.z)

            rlBegin(RL_QUADS)
                rlColor4ub(tint.r, tint.g, tint.b, tint.a)

                '' Front Face
                rlNormal3f(0.0f, 1.0f, 0.0f)                                   '' Normal Pointing Up
                rlTexCoord2f(tx, ty): rlVertex3f(x,         y, z)              '' Top Left Of The Texture and Quad
                rlTexCoord2f(tx, th): rlVertex3f(x,         y, z + height)     '' Bottom Left Of The Texture and Quad
                rlTexCoord2f(tw, th): rlVertex3f(x + wid, y, z + height)       '' Bottom Right Of The Texture and Quad
                rlTexCoord2f(tw, ty): rlVertex3f(x + wid, y, z)                '' Top Right Of The Texture and Quad

                if backface = RLTRUE then
                    '' Back Face
                    rlNormal3f(0.0f, -1.0f, 0.0f)                              '' Normal Pointing Down
                    rlTexCoord2f(tx, ty): rlVertex3f(x,         y, z)          '' Top Right Of The Texture and Quad
                    rlTexCoord2f(tw, ty): rlVertex3f(x + wid, y, z)            '' Top Left Of The Texture and Quad
                    rlTexCoord2f(tw, th): rlVertex3f(x + wid, y, z + height)   '' Bottom Left Of The Texture and Quad
                    rlTexCoord2f(tx, th): rlVertex3f(x,         y, z + height) '' Bottom Right Of The Texture and Quad
                end if
            rlEnd()
        rlPopMatrix()

        rlSetTexture(0)
    end if
end sub

'' Draw a 2D text in 3D space
sub DrawText3D(fnt as Font, text as const zstring ptr, position as Vector3, fontSize as single, fontSpacing as single, lineSpacing as single, backface as RLBOOL, tint as RLColor)
    dim as long length = TextLength(text)          '' Total length in bytes of the text, scanned by codepoints in loop

    dim as single textOffsetY = 0.0f               '' Offset between lines (on line break '\n')
    dim as single textOffsetX = 0.0f               '' Offset X to next character to draw

    dim as single scale = fontSize/fnt.baseSize

    dim as integer i

    do while i < length - 1
        '' Get next codepoint from byte string and glyph index in font
        dim as long codepointByteCount = 0
        dim as long codepoint = GetCodepoint(@text[i], @codepointByteCount)
        dim as long index = GetGlyphIndex(fnt, codepoint)

        '' NOTE: Normally we exit the decoding sequence as soon as a bad byte is found (and return 0x3f)
        '' but we need to draw all of the bad bytes using the '?' symbol moving one byte
        if codepoint = &h3f then codepointByteCount = 1

        if codepoint = asc(!"\n") then
            '' NOTE: Fixed line spacing of 1.5 line-height
            '' TODO: Support custom line spacing defined by user
            textOffsetY += scale + lineSpacing/fnt.baseSize*scale
            textOffsetX = 0.0f
        else
            if (codepoint <> asc(" ")) and (codepoint <> asc(!"\t")) then
                DrawTextCodepoint3D(fnt, codepoint, Vector3(position.x + textOffsetX, position.y, position.z + textOffsetY), fontSize, backface, tint)
            end if

            if fnt.glyphs[index].advanceX = 0 then 
                textOffsetX += (fnt.recs[index].width + fontSpacing)/fnt.baseSize*scale
            else 
                textOffsetX += (fnt.glyphs[index].advanceX + fontSpacing)/fnt.baseSize*scale
            end if
        end if

        i += codepointByteCount   '' Move text bytes counter to next codepoint
    loop
end sub

'' Measure a text in 3D. For some reason `MeasureTextEx()` just doesn't seem to work so i had to use this instead.
function MeasureText3D(fnt as Font, text as const zstring ptr, fontSize as single, fontSpacing as single, lineSpacing as single) as Vector3
    dim as long length = TextLength(text)
    dim as long tempLen = 0                '' Used to count longer text line num chars
    dim as long lenCounter = 0

    dim as single tempTextWidth = 0.0f     '' Used to count longer text line width

    dim as single scale = fontSize/fnt.baseSize
    dim as single textHeight = scale
    dim as single textWidth = 0.0f

    dim as long letter = 0                 '' Current character
    dim as long index = 0                  '' Index position in sprite font

    for i as integer = 0 to length - 1
        lenCounter += 1

        dim as long nxt = 0
        letter = GetCodepoint(@text[i], @nxt)
        index = GetGlyphIndex(fnt, letter)

        '' NOTE: normally we exit the decoding sequence as soon as a bad byte is found (and return 0x3f)
        '' but we need to draw all of the bad bytes using the '?' symbol so to not skip any we set next = 1
        if letter = &h3f then nxt = 1
        i += nxt - 1

        if letter <> asc(!"\n") then
            if fnt.glyphs[index].advanceX <> 0 then
                textWidth += (fnt.glyphs[index].advanceX+fontSpacing)/fnt.baseSize*scale
            else 
                textWidth += (fnt.recs[index].width + fnt.glyphs[index].offsetX)/fnt.baseSize*scale
            end if
        else
            if tempTextWidth < textWidth then tempTextWidth = textWidth
            lenCounter = 0
            textWidth = 0.0f
            textHeight += scale + lineSpacing/fnt.baseSize*scale
        end if

        if tempLen < lenCounter then tempLen = lenCounter
    next

    if tempTextWidth < textWidth then tempTextWidth = textWidth

    dim as Vector3 vec
    vec.x = tempTextWidth + ((tempLen - 1)*fontSpacing/fnt.baseSize*scale) '' Adds chars spacing to measure
    vec.y = 0.25f
    vec.z = textHeight

    return vec
end function

'' Draw a 2D text in 3D space and wave the parts that start with `~~` and end with `~~`.
'' This is a modified version of the original code by @Nighten found here https:''github.com/NightenDushi/Raylib_DrawTextStyle
sub DrawTextWave3D(fnt as Font, text as const zstring ptr, position as Vector3, fontSize as single, fontSpacing as single, lineSpacing as single, backface as RLBOOL, config as WaveTextConfig ptr, tme as single, tint as RLColor)
    dim as long length = TextLength(text)          '' Total length in bytes of the text, scanned by codepoints in loop
    dim as long i, k
    dim as single textOffsetY = 0.0f               '' Offset between lines (on line break '\n')
    dim as single textOffsetX = 0.0f               '' Offset X to next character to draw

    dim as single scale = fontSize/fnt.baseSize

    dim as boolean wave = false

    do while i < length
        '' Get next codepoint from byte string and glyph index in font
        dim as long codepointByteCount = 0
        dim as long codepoint = GetCodepoint(@text[i], @codepointByteCount)
        dim as long index = GetGlyphIndex(fnt, codepoint)

        '' NOTE: Normally we exit the decoding sequence as soon as a bad byte is found (and return 0x3f)
        '' but we need to draw all of the bad bytes using the '?' symbol moving one byte
        if codepoint = &h3f then codepointByteCount = 1

        if codepoint = asc(!"\n") then
            '' NOTE: Fixed line spacing of 1.5 line-height
            '' TODO: Support custom line spacing defined by user
            textOffsetY += scale + lineSpacing/fnt.baseSize*scale
            textOffsetX = 0.0f
            k = 0
        elseif codepoint = asc("~") then
            if GetCodepoint(@text[i+1], @codepointByteCount) = asc("~") then
                codepointByteCount += 1
                wave = not wave
            end if
        else
            if codepoint <> asc(" ") and codepoint <> asc(!"\t") then
                dim as Vector3 ps = position
                if wave then '' Apply the wave effect
                    ps.x += sin(tme*config->waveSpeed.x-k*config->waveOffset.x)*config->waveRange.x
                    ps.y += sin(tme*config->waveSpeed.y-k*config->waveOffset.y)*config->waveRange.y
                    ps.z += sin(tme*config->waveSpeed.z-k*config->waveOffset.z)*config->waveRange.z
                end if

                DrawTextCodepoint3D(fnt, codepoint, Vector3(ps.x + textOffsetX, ps.y, ps.z + textOffsetY), fontSize, backface, tint)
            end if

            if fnt.glyphs[index].advanceX = 0 then 
                textOffsetX += (fnt.recs[index].width + fontSpacing)/fnt.baseSize*scale
            else 
                textOffsetX += (fnt.glyphs[index].advanceX + fontSpacing)/fnt.baseSize*scale
            end if
        end if

        i += codepointByteCount   '' Move text bytes counter to next codepoint
        k += 1
    loop
end sub

'' Measure a text in 3D ignoring the `~~` chars.
function MeasureTextWave3D(fnt as Font, text as const zstring ptr, fontSize as single, fontSpacing as single, lineSpacing as single) as Vector3
    dim as long length = TextLength(text)
    dim as long tempLen = 0                '' Used to count longer text line num chars
    dim as long lenCounter = 0

    dim as single tempTextWidth = 0.0f     '' Used to count longer text line width

    dim as single scale = fontSize/fnt.baseSize
    dim as single textHeight = scale
    dim as single textWidth = 0.0f

    dim as long letter = 0                 '' Current character
    dim as long index = 0                  '' Index position in sprite font

    for i as integer = 0 to length - 1
        lenCounter += 1

        dim as long nxt = 0
        letter = GetCodepoint(@text[i], @nxt)
        index = GetGlyphIndex(fnt, letter)

        '' NOTE: normally we exit the decoding sequence as soon as a bad byte is found (and return 0x3f)
        '' but we need to draw all of the bad bytes using the '?' symbol so to not skip any we set next = 1
        if letter = &h3f then nxt = 1
        i += nxt - 1

        if letter <> asc(!"\n") then
            if letter = asc("~") and GetCodepoint(@text[i+1], @nxt) = asc("~") then
                i += 1
            else
                if fnt.glyphs[index].advanceX <> 0 then 
                    textWidth += (fnt.glyphs[index].advanceX+fontSpacing)/fnt.baseSize*scale
                else 
                    textWidth += (fnt.recs[index].width + fnt.glyphs[index].offsetX)/fnt.baseSize*scale
                end if
            end if
        else
            if tempTextWidth < textWidth then tempTextWidth = textWidth
            lenCounter = 0
            textWidth = 0.0f
            textHeight += scale + lineSpacing/fnt.baseSize*scale
        end if

        if tempLen < lenCounter then tempLen = lenCounter
    next

    if tempTextWidth < textWidth then tempTextWidth = textWidth

    dim as Vector3 vec
    vec.x = tempTextWidth + ((tempLen - 1)*fontSpacing/fnt.baseSize*scale) '' Adds chars spacing to measure
    vec.y = 0.25f
    vec.z = textHeight

    return vec
end function

'' Generates a nice color with a random hue
function GenerateRandomColor(s as single, v as single) as RLColor
    dim as single Phi = 0.618033988749895f '' Golden ratio conjugate
    dim as single h = GetRandomValue(0, 360)
    h = (h + h*Phi) mod 360.0f
    return ColorFromHSV(h, s, v)
end function