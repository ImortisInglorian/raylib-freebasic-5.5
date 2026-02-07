/'******************************************************************************************
*
*   raylib [text] example - Rectangle bounds
*
*   Example originally created with raylib 2.5, last time updated with raylib 4.0
*
*   Example contributed by Vlad Adrian (@demizdor) and reviewed by Ramon Santamaria (@raysan5)
*
*   Example licensed under an unmodified zlib/libpng license, which is an OSI-certified,
*   BSD-like license that allows static linking with closed source software
*
*   Copyright (c) 2018-2024 Vlad Adrian (@demizdor) and Ramon Santamaria (@raysan5)
*
*******************************************************************************************'/

#include "../../raylib.bi"

declare sub DrawTextBoxed(fnt as Font, text as const zstring ptr, rec as Rectangle, fontSize as single, spacing as single, wordWrap as boolean, tint as RLColor)   '' Draw text using font inside rectangle limits
declare sub DrawTextBoxedSelectable(fnt as Font, text as const zstring ptr, rec as Rectangle, fontSize as single, spacing as single, wordWrap as boolean, tint as RLColor, selectStart as long, selectLength as long, selectTint as RLColor, selectBackTint as RLColor)    '' Draw text using font inside rectangle limits with support for text selection

'' Initialization
''--------------------------------------------------------------------------------------
const as long screenWidth = 800
const as long screenHeight = 450

InitWindow(screenWidth, screenHeight, "raylib [text] example - draw text inside a rectangle")

dim as zstring * 512 text = !"Text cannot escape\tthis container\t...word wrap also works when active so here's " _
                            & !"a long text for testing.\n\nLorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod " _
                            & !"tempor incididunt ut labore et dolore magna aliqua. Nec ullamcorper sit amet risus nullam eget felis eget."

dim as boolean resizing = false
dim as boolean wordWrap = true

dim as Rectangle container = Rectangle(25.0f, 25.0f, screenWidth - 50.0f, screenHeight - 250.0f)
dim as Rectangle resizer = Rectangle(container.x + container.width - 17, container.y + container.height - 17, 14, 14)

'' Minimum width and heigh for the container rectangle
const as single minWidth = 60
const as single minHeight = 60
const as single maxWidth = screenWidth - 50.0f
const as single maxHeight = screenHeight - 160.0f

dim as Vector2 lastMouse = Vector2(0.0f, 0.0f) '' Stores last mouse coordinates
dim as RLColor borderColor = MAROON         '' Container border color
dim as Font fnt = GetFontDefault()       '' Get default system font

SetTargetFPS(60)                   '' Set our game to run at 60 frames-per-second
''--------------------------------------------------------------------------------------

'' Main game loop
do while not WindowShouldClose()        '' Detect window close button or ESC key
    '' Update
    ''----------------------------------------------------------------------------------
    if IsKeyPressed(KEY_SPACE) then wordWrap = not wordWrap

    dim as Vector2 mouse = GetMousePosition()

    '' Check if the mouse is inside the container and toggle border color
    if CheckCollisionPointRec(mouse, container) then
        borderColor = Fade(MAROON, 0.4f)
    elseif not resizing then
        borderColor = MAROON
    end if

    '' Container resizing logic
    if resizing then
        if IsMouseButtonReleased(MOUSE_BUTTON_LEFT) then resizing = false

        dim as single widt = container.width + (mouse.x - lastMouse.x)
        container.width = iif(widt > minWidth, iif(widt < maxWidth, widt, maxWidth), minWidth)

        dim as single height = container.height + (mouse.y - lastMouse.y)
        container.height = iif(height > minHeight, iif(height < maxHeight, height, maxHeight),  minHeight)
    else
        '' Check if we're resizing
        if IsMouseButtonDown(MOUSE_BUTTON_LEFT) and CheckCollisionPointRec(mouse, resizer) then resizing = true
    end if

    '' Move resizer rectangle properly
    resizer.x = container.x + container.width - 17
    resizer.y = container.y + container.height - 17

    lastMouse = mouse '' Update mouse
    ''----------------------------------------------------------------------------------

    '' Draw
    ''----------------------------------------------------------------------------------
    BeginDrawing()

        ClearBackground(RAYWHITE)

        DrawRectangleLinesEx(container, 3, borderColor)    '' Draw container border

        '' Draw text in container (add some padding)
        DrawTextBoxed(fnt, text, Rectangle(container.x + 4, container.y + 4, container.width - 4, container.height - 4), 20.0f, 2.0f, wordWrap, GRAY)

        DrawRectangleRec(resizer, borderColor)             '' Draw the resize box

        '' Draw bottom info
        DrawRectangle(0, screenHeight - 54, screenWidth, 54, GRAY)
        DrawRectangleRec(Rectangle(382.0f, screenHeight - 34.0f, 12.0f, 12.0f), MAROON)

        DrawText("Word Wrap: ", 313, screenHeight-115, 20, BLACK)
        if wordWrap then 
            DrawText("ON", 447, screenHeight - 115, 20, RED)
        else 
            DrawText("OFF", 447, screenHeight - 115, 20, BLACK)
        end if

        DrawText("Press [SPACE] to toggle word wrap", 218, screenHeight - 86, 20, GRAY)

        DrawText("Click hold & drag the    to resize the container", 155, screenHeight - 38, 20, RAYWHITE)

    EndDrawing()
    ''----------------------------------------------------------------------------------
loop

'' De-Initialization
''--------------------------------------------------------------------------------------
CloseWindow()        '' Close window and OpenGL context
''--------------------------------------------------------------------------------------

''--------------------------------------------------------------------------------------
'' Module functions definition
''--------------------------------------------------------------------------------------

'' Draw text using font inside rectangle limits
sub DrawTextBoxed(fnt as Font, text as const zstring ptr, rec as Rectangle, fontSize as single, spacing as single, wordWrap as boolean, tint as RLColor)
    DrawTextBoxedSelectable(fnt, text, rec, fontSize, spacing, wordWrap, tint, 0, 0, WHITE, WHITE)
end sub

'' Draw text using font inside rectangle limits with support for text selection
sub DrawTextBoxedSelectable(fnt as Font, text as const zstring ptr, rec as Rectangle, fontSize as single, spacing as single, wordWrap as boolean, tint as RLColor, selectStart as long, selectLength as long, selectTint as RLColor, selectBackTint as RLColor)
    dim as long length = TextLength(text)  '' Total length in bytes of the text, scanned by codepoints in loop

    dim as single textOffsetY = 0          '' Offset between lines (on line break '\n')
    dim as single textOffsetX = 0.0f       '' Offset X to next character to draw

    dim as single scaleFactor = fontSize/fnt.baseSize     '' Character rectangle scaling factor

    '' Word/character wrapping mechanism variables
    enum 
        MEASURE_STATE = 0
        DRAW_STATE = 1
    end enum
    dim as long state = iif(wordWrap, MEASURE_STATE, DRAW_STATE)

    dim as long startLine = -1         '' Index where to begin drawing (where a line begins)
    dim as long endLine = -1           '' Index where to stop drawing (where a line ends)
    dim as long lastk = -1             '' Holds last value of the character position
    dim as long k = 0

    for i as integer = 0 to length - 1
        '' Get next codepoint from byte string and glyph index in font
        dim as long codepointByteCount = 0
        dim as long codepoint = GetCodepoint(text[i], @codepointByteCount)
        dim as long index = GetGlyphIndex(fnt, codepoint)

        '' NOTE: Normally we exit the decoding sequence as soon as a bad byte is found (and return 0x3f)
        '' but we need to draw all of the bad bytes using the '?' symbol moving one byte
        if codepoint = &h3f then codepointByteCount = 1
        i += (codepointByteCount - 1)

        dim as single glyphWidth = 0
        if codepoint <> asc(!"\n") then
            glyphWidth = iif(fnt.glyphs[index].advanceX = 0, fnt.recs[index].width*scaleFactor, fnt.glyphs[index].advanceX*scaleFactor)

            if i + 1 < length then glyphWidth = glyphWidth + spacing
        end if

        '' NOTE: When wordWrap is ON we first measure how much of the text we can draw before going outside of the rec container
        '' We store this info in startLine and endLine, then we change states, draw the text between those two variables
        '' and change states again and again recursively until the end of the text (or until we get outside of the container).
        '' When wordWrap is OFF we don't need the measure state so we go to the drawing state immediately
        '' and begin drawing on the next line before we can get outside the container.
        if state = MEASURE_STATE then
            '' TODO: There are multiple types of spaces in UNICODE, maybe it's a good idea to add support for more
            '' Ref: http:''jkorpela.fi/chars/spaces.html
            if (codepoint = asc(" ")) or (codepoint = asc(!"\t")) or (codepoint = asc(!"\n")) then endLine = i

            if (textOffsetX + glyphWidth) > rec.width then
                endLine = iif(endLine < 1, i, endLine)
                if i = endLine then endLine -= codepointByteCount
                if (startLine + codepointByteCount) = endLine then endLine = (i - codepointByteCount)

                state = DRAW_STATE
            elseif (i + 1) = length then
                endLine = i
                state = DRAW_STATE
            elseif codepoint = asc(!"\n") then 
                state = DRAW_STATE
            end if

            if state = DRAW_STATE then
                textOffsetX = 0
                i = startLine
                glyphWidth = 0

                '' Save character position when we switch states
                dim as long tmp = lastk
                lastk = k - 1
                k = tmp
            end if
        else
            if codepoint = asc(!"\n") then
                if not wordWrap then
                    textOffsetY += (fnt.baseSize + fnt.baseSize/2)*scaleFactor
                    textOffsetX = 0
                end if
            else
                if not(wordWrap) andAlso ((textOffsetX + glyphWidth) > rec.width) then
                    textOffsetY += (fnt.baseSize + fnt.baseSize/2)*scaleFactor
                    textOffsetX = 0
                end if

                '' When text overflows rectangle height limit, just stop drawing
                if (textOffsetY + fnt.baseSize*scaleFactor) > rec.height then exit for

                '' Draw selection background
                dim as boolean isGlyphSelected = false
                if (selectStart >= 0) and (k >= selectStart) and (k < (selectStart + selectLength)) then
                    DrawRectangleRec(Rectangle(rec.x + textOffsetX - 1, rec.y + textOffsetY, glyphWidth, fnt.baseSize*scaleFactor), selectBackTint)
                    isGlyphSelected = true
                end if

                '' Draw current character glyph
                if (codepoint <> asc(" ")) and (codepoint <> asc(!"\t")) then
                    DrawTextCodepoint(fnt, codepoint, Vector2(rec.x + textOffsetX, rec.y + textOffsetY), fontSize, iif(isGlyphSelected, selectTint, tint))
                end if
            end if

            if wordWrap and (i = endLine) then
                textOffsetY += (fnt.baseSize + fnt.baseSize/2)*scaleFactor
                textOffsetX = 0
                startLine = endLine
                endLine = -1
                glyphWidth = 0
                selectStart += lastk - k
                k = lastk

                state = MEASURE_STATE
            end if
        end if

        if (textOffsetX <> 0) or (codepoint <> asc(" ")) then textOffsetX += glyphWidth  '' avoid leading spaces
        k += 1
    next
end sub