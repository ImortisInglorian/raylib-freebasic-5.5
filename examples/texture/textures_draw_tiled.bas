/'******************************************************************************************
*
*   raylib [textures] example - Draw part of the texture tiled
*
*   Example originally created with raylib 3.0, last time updated with raylib 4.2
*
*   Example contributed by Vlad Adrian (@demizdor) and reviewed by Ramon Santamaria (@raysan5)
*
*   Example licensed under an unmodified zlib/libpng license, which is an OSI-certified,
*   BSD-like license that allows static linking with closed source software
*
*   Copyright (c) 2020-2024 Vlad Adrian (@demizdor) and Ramon Santamaria (@raysan5)
*
*******************************************************************************************'/

#include "../../raylib.bi"

#define OPT_WIDTH       220       '' Max width for the options container
#define MARGIN_SIZE       8       '' Size for the margins
#define COLOR_SIZE       16       '' Size of the color select buttons

'' Draw part of a texture (defined by a rectangle) with rotation and scale tiled into dest.
declare sub DrawTextureTiled(texture as Texture2D, source as Rectangle, dest as Rectangle, origin as Vector2, rotation as single, scale as single, tint as RLColor)

''------------------------------------------------------------------------------------
'' Program main entry point
''------------------------------------------------------------------------------------
'' Initialization
''--------------------------------------------------------------------------------------
const as long screenWidth = 800
const as long screenHeight = 450

SetConfigFlags(FLAG_WINDOW_RESIZABLE) '' Make the window resizable
InitWindow(screenWidth, screenHeight, "raylib [textures] example - Draw part of a texture tiled")

'' NOTE: Textures MUST be loaded after Window initialization (OpenGL context is required)
dim as Texture texPattern = LoadTexture("resources/patterns.png")
SetTextureFilter(texPattern, TEXTURE_FILTER_TRILINEAR) '' Makes the texture smoother when upscaled

'' Coordinates for all patterns inside the texture
dim as Rectangle recPattern(...) = {_
    Rectangle(3, 3, 66, 66), _
    Rectangle(75, 3, 100, 100), _
    Rectangle(3, 75, 66, 66), _
    Rectangle(7, 156, 50, 50), _
    Rectangle(85, 106, 90, 45), _
    Rectangle(75, 154, 100, 60) _
}

'' Setup colors
dim as RLColor colors(...) = { BLACK, MAROON, ORANGE, BLUE, PURPLE, BEIGE, LIME, RED, DARKGRAY, SKYBLUE }
const as long MAX_COLORS = ubound(colors)
dim as Rectangle colorRec(MAX_COLORS)
dim as long x, y

'' Calculate rectangle for each color
for i as integer = 0 to MAX_COLORS - 1
    colorRec(i).x = 2.0f + MARGIN_SIZE + x
    colorRec(i).y = 22.0f + 256.0f + MARGIN_SIZE + y
    colorRec(i).width = COLOR_SIZE*2.0f
    colorRec(i).height = COLOR_SIZE

    if i = (MAX_COLORS/2 - 1) then
        x = 0
        y += COLOR_SIZE + MARGIN_SIZE
    else
        x += (COLOR_SIZE*2 + MARGIN_SIZE)
    end if
next

dim as long activePattern = 0, activeCol = 0
dim as single scale = 1.0f, rotation = 0.0f

SetTargetFPS(60)
''---------------------------------------------------------------------------------------

'' Main game loop
do while not WindowShouldClose()    '' Detect window close button or ESC key
    '' Update
    ''----------------------------------------------------------------------------------
    '' Handle mouse
    if IsMouseButtonPressed(MOUSE_BUTTON_LEFT) then
        dim as Vector2 mouse = GetMousePosition()

        '' Check which pattern was clicked and set it as the active pattern
        for i as integer = 0 to ubound(recPattern) - 1
            if CheckCollisionPointRec(mouse, Rectangle(2 + MARGIN_SIZE + recPattern(i).x, 40 + MARGIN_SIZE + recPattern(i).y, recPattern(i).width, recPattern(i).height)) then
                activePattern = i
                exit for
            end if
        next

        '' Check to see which color was clicked and set it as the active color
        for i as integer = 0 to MAX_COLORS - 1
            if CheckCollisionPointRec(mouse, colorRec(i)) then
                activeCol = i
                exit for
            end if
        next
    end if

    '' Handle keys

    '' Change scale
    if IsKeyPressed(KEY_UP) then scale += 0.25f
    if IsKeyPressed(KEY_DOWN) then scale -= 0.25f
    if scale > 10.0f then
        scale = 10.0f
    elseif scale <= 0.0f then
        scale = 0.25f
    end if

    '' Change rotation
    if IsKeyPressed(KEY_LEFT) then rotation -= 25.0f
    if IsKeyPressed(KEY_RIGHT) then rotation += 25.0f

    '' Reset
    if IsKeyPressed(KEY_SPACE) then
        rotation = 0.0f
        scale = 1.0f
    end if
    ''----------------------------------------------------------------------------------

    '' Draw
    ''----------------------------------------------------------------------------------
    BeginDrawing()
        ClearBackground(RAYWHITE)

        '' Draw the tiled area
        DrawTextureTiled(texPattern, recPattern(activePattern), Rectangle(OPT_WIDTH+MARGIN_SIZE, MARGIN_SIZE, GetScreenWidth() - OPT_WIDTH - 2.0f*MARGIN_SIZE, GetScreenHeight() - 2.0f*MARGIN_SIZE), _
            Vector2(0.0f, 0.0f), rotation, scale, colors(activeCol))

        '' Draw options
        DrawRectangle(MARGIN_SIZE, MARGIN_SIZE, OPT_WIDTH - MARGIN_SIZE, GetScreenHeight() - 2*MARGIN_SIZE, ColorAlpha(LIGHTGRAY, 0.5f))

        DrawText("Select Pattern", 2 + MARGIN_SIZE, 30 + MARGIN_SIZE, 10, BLACK)
        DrawTexture(texPattern, 2 + MARGIN_SIZE, 40 + MARGIN_SIZE, BLACK)
        DrawRectangle(2 + MARGIN_SIZE + recPattern(activePattern).x, 40 + MARGIN_SIZE + recPattern(activePattern).y, recPattern(activePattern).width, recPattern(activePattern).height, ColorAlpha(DARKBLUE, 0.3f))

        DrawText("Select Color", 2+MARGIN_SIZE, 10+256+MARGIN_SIZE, 10, BLACK)
        for i as integer = 0 to MAX_COLORS - 1
            DrawRectangleRec(colorRec(i), colors(i))
            if (activeCol = i) then DrawRectangleLinesEx(colorRec(i), 3, ColorAlpha(WHITE, 0.5f))
        next

        DrawText("Scale (UP/DOWN to change)", 2 + MARGIN_SIZE, 80 + 256 + MARGIN_SIZE, 10, BLACK)
        DrawText(TextFormat("%.2fx", scale), 2 + MARGIN_SIZE, 92 + 256 + MARGIN_SIZE, 20, BLACK)

        DrawText("Rotation (LEFT/RIGHT to change)", 2 + MARGIN_SIZE, 122 + 256 + MARGIN_SIZE, 10, BLACK)
        DrawText(TextFormat("%.0f degrees", rotation), 2 + MARGIN_SIZE, 134 + 256 + MARGIN_SIZE, 20, BLACK)

        DrawText("Press [SPACE] to reset", 2 + MARGIN_SIZE, 164 + 256 + MARGIN_SIZE, 10, DARKBLUE)

        '' Draw FPS
        DrawText(TextFormat("%i FPS", GetFPS()), 2 + MARGIN_SIZE, 2 + MARGIN_SIZE, 20, BLACK)
    EndDrawing()
    ''----------------------------------------------------------------------------------
loop

'' De-Initialization
''--------------------------------------------------------------------------------------
UnloadTexture(texPattern)        '' Unload texture

CloseWindow()              '' Close window and OpenGL context
''--------------------------------------------------------------------------------------

'' Draw part of a texture (defined by a rectangle) with rotation and scale tiled into dest.
sub DrawTextureTiled(texture as Texture2D, source as Rectangle, dest as Rectangle, origin as Vector2, rotation as single, scale as single, tint as RLColor)
    if (texture.id <= 0) or (scale <= 0.0f) then return  '' Wanna see a infinite loop?!...just delete this line!
    if (source.width = 0) or (source.height = 0) then return

    dim as long tileWidth = source.width*scale, tileHeight = source.height*scale
    if (dest.width < tileWidth) and (dest.height < tileHeight) then
        '' Can fit only one tile
        DrawTexturePro(texture, Rectangle(source.x, source.y, (dest.width/tileWidth)*source.width, (dest.height/tileHeight)*source.height), _
                    Rectangle(dest.x, dest.y, dest.width, dest.height), origin, rotation, tint)
    elseif (dest.width <= tileWidth) then
        '' Tiled vertically (one column)
        dim as long dy = 0
        do while dy+tileHeight < dest.height
            DrawTexturePro(texture, Rectangle(source.x, source.y, (dest.width/tileWidth)*source.width, source.height), Rectangle(dest.x, dest.y + dy, dest.width, tileHeight), origin, rotation, tint)
            dy += tileHeight
        loop

        '' Fit last tile
        if dy < dest.height then
            DrawTexturePro(texture, Rectangle(source.x, source.y, (dest.width/tileWidth)*source.width, ((dest.height - dy)/tileHeight)*source.height), _
                        Rectangle(dest.x, dest.y + dy, dest.width, dest.height - dy), origin, rotation, tint)
        end if
    elseif dest.height <= tileHeight then
        '' Tiled horizontally (one row)
        dim as long dx = 0
        do while dx+tileWidth < dest.width
            DrawTexturePro(texture, Rectangle(source.x, source.y, source.width, (dest.height/tileHeight)*source.height), Rectangle(dest.x + dx, dest.y, tileWidth, dest.height), origin, rotation, tint)
            dx += tileWidth
        loop

        '' Fit last tile
        if dx < dest.width then
            DrawTexturePro(texture, Rectangle(source.x, source.y, ((dest.width - dx)/tileWidth)*source.width, (dest.height/tileHeight)*source.height), _
                        Rectangle(dest.x + dx, dest.y, dest.width - dx, dest.height), origin, rotation, tint)
        end if
    else
        '' Tiled both horizontally and vertically (rows and columns)
        dim as long dx = 0
        do while dx+tileWidth < dest.width
            dim as long dy = 0
            do while dy+tileHeight < dest.height
                DrawTexturePro(texture, source, Rectangle(dest.x + dx, dest.y + dy, tileWidth, tileHeight), origin, rotation, tint)
                dy += tileHeight
            loop

            if dy < dest.height then
                DrawTexturePro(texture, Rectangle(source.x, source.y, source.width, ((dest.height - dy)/tileHeight)*source.height), _
                    Rectangle(dest.x + dx, dest.y + dy, tileWidth, dest.height - dy), origin, rotation, tint)
            end if
            dx += tileWidth
        loop

        '' Fit last column of tiles
        if dx < dest.width then
            dim as long dy = 0
            do while dy+tileHeight < dest.height
                DrawTexturePro(texture, Rectangle(source.x, source.y, ((dest.width - dx)/tileWidth)*source.width, source.height), _
                        Rectangle(dest.x + dx, dest.y + dy, dest.width - dx, tileHeight), origin, rotation, tint)
                dy += tileHeight
            loop

            '' Draw final tile in the bottom right corner
            if dy < dest.height then
                DrawTexturePro(texture, Rectangle(source.x, source.y, ((dest.width - dx)/tileWidth)*source.width, ((dest.height - dy)/tileHeight)*source.height), _
                    Rectangle(dest.x + dx, dest.y + dy, dest.width - dx, dest.height - dy), origin, rotation, tint)
            end if
        end if
    end if
end sub