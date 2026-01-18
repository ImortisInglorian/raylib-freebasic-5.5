/'******************************************************************************************
*
*   raylib [core] example - Generates a random sequence
*
*   Example originally created with raylib 5.0, last time updated with raylib 5.0
*
*   Example contributed by Dalton Overmyer (@REDl3east) and reviewed by Ramon Santamaria (@raysan5)
*
*   Example licensed under an unmodified zlib/libpng license, which is an OSI-certified,
*   BSD-like license that allows static linking with closed source software
*
*   Copyright (c) 2023 Dalton Overmyer (@REDl3east)
*
*******************************************************************************************'/

#include "../../raylib.bi"

type ColorRect
    as RLColor c
    as Rectangle r
end type

declare function GenerateRandomColor() as RLColor
declare function GenerateRandomColorRectSequence(rectCount as long, rectWidth as single, screenWidth as single, screenHeight as single) as ColorRect Ptr
declare sub ShuffleColorRectSequence(rectangles as ColorRect ptr, rectCount as long)
declare sub DrawTextCenterKeyHelp(key as const string, text as string, posX as long, posY as long, fontSize as long, clr as RLColor)

''------------------------------------------------------------------------------------
'' Program main entry point
''------------------------------------------------------------------------------------
'' Initialization
''--------------------------------------------------------------------------------------
const as long screenWidth = 800
const as long screenHeight = 450

InitWindow(screenWidth, screenHeight, "raylib [core] example - Generates a random sequence")

dim as long rectCount = 20
dim as single rectSize = screenWidth/rectCount
dim as ColorRect ptr rectangles = GenerateRandomColorRectSequence(rectCount, rectSize, screenWidth, 0.75f * screenHeight)

SetTargetFPS(60)
''--------------------------------------------------------------------------------------

'' Main game loop
do while not WindowShouldClose() '' Detect window close button or ESC key
    '' Update
    ''----------------------------------------------------------------------------------

    if IsKeyPressed(KEY_SPACE) then
       ShuffleColorRectSequence(rectangles, rectCount)
    end if

    if IsKeyPressed(KEY_UP) then
        rectCount += 1
        rectSize = screenWidth/rectCount
        deallocate(rectangles)
        rectangles = GenerateRandomColorRectSequence(rectCount, rectSize, screenWidth, 0.75f * screenHeight)
    end if

    if IsKeyPressed(KEY_DOWN) then
        if rectCount >= 4 then
            rectCount -= 1
            rectSize = screenWidth/rectCount
            deallocate(rectangles)
            rectangles = GenerateRandomColorRectSequence(rectCount, rectSize, screenWidth, 0.75f * screenHeight)
        end if
    end if

    '' Draw
    ''----------------------------------------------------------------------------------
    BeginDrawing()

    ClearBackground(RAYWHITE)
    
    dim as long fontSize = 20
    for x as integer = 0 to rectCount - 1
        DrawRectangleRec(rectangles[x].r, rectangles[x].c)
        DrawTextCenterKeyHelp("SPACE", "to shuffle the sequence.", 10, screenHeight - 96, fontSize, BLACK)
        DrawTextCenterKeyHelp("UP", "to add a rectangle and generate a new sequence.", 10, screenHeight - 64, fontSize, BLACK)
        DrawTextCenterKeyHelp("DOWN", "to remove a rectangle and generate a new sequence.", 10, screenHeight - 32, fontSize, BLACK)
    next

    dim as const zstring ptr rectCountText = TextFormat("%d rectangles", rectCount)
    dim as long rectCountTextSize = MeasureText(rectCountText, fontSize)
    DrawText(rectCountText, screenWidth - rectCountTextSize - 10, 10, fontSize, BLACK)

    DrawFPS(10, 10)

    EndDrawing()
    ''----------------------------------------------------------------------------------
loop
'' De-Initialization
''--------------------------------------------------------------------------------------

deallocate(rectangles)
CloseWindow() '' Close window and OpenGL context
''--------------------------------------------------------------------------------------

function GenerateRandomColor() as RLColor
    return RLColor(GetRandomValue(0, 255), GetRandomValue(0, 255), GetRandomValue(0, 255),255)
end function

function GenerateRandomColorRectSequence(rectCount as long, rectWidth as single, screenWid as single, screenHeigh as single) as ColorRect Ptr
    dim as long ptr seq = LoadRandomSequence(rectCount, 0, rectCount - 1)
    dim as ColorRect ptr rectangles = allocate(rectCount*sizeof(ColorRect))

    dim as single rectSeqWidth = rectCount * rectWidth
    dim as single startX = (screenWid - rectSeqWidth) * 0.5f

    for x as integer = 0 to rectCount - 1
        dim as long rectHeight = Remap(seq[x], 0, rectCount-1, 0, screenHeigh)
        rectangles[x].c = GenerateRandomColor()
        rectangles[x].r = Rectangle(startX + x * rectWidth, screenHeigh - rectHeight, rectWidth, rectHeight)
    next
    UnloadRandomSequence(seq)
    return rectangles
end function

sub ShuffleColorRectSequence(rectangles as ColorRect ptr, rectCount as long)
    dim as long ptr seq = LoadRandomSequence(rectCount, 0, rectCount-1)
    for i1 as integer = 0 to rectCount - 1
        dim as ColorRect ptr r1 = @rectangles[i1]
        dim as ColorRect ptr r2 = @rectangles[seq[i1]]

        '' swap only the color and height
        dim as ColorRect tmp = *r1
        r1->c = r2->c
        r1->r.height = r2->r.height
        r1->r.y = r2->r.y
        r2->c = tmp.c
        r2->r.height = tmp.r.height
        r2->r.y = tmp.r.y

    next
    UnloadRandomSequence(seq)
end sub

sub DrawTextCenterKeyHelp(key as const string, text as string, posX as long, posY as long, fontSize as long, clr as RLColor)
    dim as long spaceSize = MeasureText(" ", fontSize) 
    dim as long pressSize = MeasureText("Press", fontSize) 
    dim as long keySize = MeasureText(key, fontSize) 
    dim as long textSize = MeasureText(text, fontSize) 
    dim as long totalSize = pressSize + 2 * spaceSize + keySize + 2 * spaceSize + textSize
    dim as long textSizeCurrent = 0

    DrawText("Press", posX, posY, fontSize, clr)
    textSizeCurrent += pressSize + 2 * spaceSize
    DrawText(key, posX + textSizeCurrent, posY, fontSize, RED)
    DrawRectangle(posX + textSizeCurrent, posY + fontSize, keySize, 3, RED)
    textSizeCurrent += keySize + 2 * spaceSize
    DrawText(text, posX + textSizeCurrent, posY, fontSize, clr)
end sub