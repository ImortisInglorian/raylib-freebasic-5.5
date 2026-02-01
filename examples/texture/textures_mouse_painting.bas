/'******************************************************************************************
*
*   raylib [textures] example - Mouse painting
*
*   Example originally created with raylib 3.0, last time updated with raylib 3.0
*
*   Example contributed by Chris Dill (@MysteriousSpace) and reviewed by Ramon Santamaria (@raysan5)
*
*   Example licensed under an unmodified zlib/libpng license, which is an OSI-certified,
*   BSD-like license that allows static linking with closed source software
*
*   Copyright (c) 2019-2024 Chris Dill (@MysteriousSpace) and Ramon Santamaria (@raysan5)
*
*******************************************************************************************'/

#include "../../raylib.bi"

#define MAX_COLORS_COUNT    23          '' Number of colors available

'' Initialization
''--------------------------------------------------------------------------------------
const as long screenWidth = 800
const as long screenHeight = 450

InitWindow(screenWidth, screenHeight, "raylib [textures] example - mouse painting")

'' Colors to choose from
dim as RLColor colors(MAX_COLORS_COUNT - 1) = { _
    RAYWHITE, YELLOW, GOLD, ORANGE, PINK, RED, MAROON, GREEN, LIME, DARKGREEN, _
    SKYBLUE, BLUE, DARKBLUE, PURPLE, VIOLET, DARKPURPLE, BEIGE, BROWN, DARKBROWN, _
    LIGHTGRAY, GRAY, DARKGRAY, BLACK }

'' Define colorsRecs data (for every rectangle)
dim as Rectangle colorsRecs(MAX_COLORS_COUNT - 1)

for i as integer = 0 to MAX_COLORS_COUNT - 1
    colorsRecs(i).x = 10 + 30.0f*i + 2*i
    colorsRecs(i).y = 10
    colorsRecs(i).width = 30
    colorsRecs(i).height = 30
next

dim as long colorSelected = 0
dim as long colorSelectedPrev = colorSelected
dim as long colorMouseHover = 0
dim as single brushSize = 20.0f
dim as boolean mouseWasPressed = false

dim as Rectangle btnSaveRec = Rectangle(750, 10, 40, 30)
dim as boolean btnSaveMouseHover = false
dim as boolean showSaveMessage = false
dim as long saveMessageCounter = 0

'' Create a RenderTexture2D to use as a canvas
dim as RenderTexture2D target = LoadRenderTexture(screenWidth, screenHeight)

'' Clear render texture before entering the game loop
BeginTextureMode(target)
ClearBackground(colors(0))
EndTextureMode()

SetTargetFPS(120)              '' Set our game to run at 120 frames-per-second
''--------------------------------------------------------------------------------------

'' Main game loop
do while not WindowShouldClose()    '' Detect window close button or ESC key
    '' Update
    ''----------------------------------------------------------------------------------
    dim as Vector2 mousePos = GetMousePosition()

    '' Move between colors with keys
    if IsKeyPressed(KEY_RIGHT) then
        colorSelected += 1
    elseif IsKeyPressed(KEY_LEFT) then
        colorSelected -= 1
    end if

    if colorSelected >= MAX_COLORS_COUNT then
        colorSelected = MAX_COLORS_COUNT - 1
    elseif colorSelected < 0 then
        colorSelected = 0
    end if

    '' Choose color with mouse
    for i as integer = 0 to MAX_COLORS_COUNT - 1
        if CheckCollisionPointRec(mousePos, colorsRecs(i)) then
            colorMouseHover = i
            exit for
        else 
            colorMouseHover = -1
        end if
    next

    if (colorMouseHover >= 0) and IsMouseButtonPressed(MOUSE_BUTTON_LEFT) then
        colorSelected = colorMouseHover
        colorSelectedPrev = colorSelected
    end if

    '' Change brush size
    brushSize += GetMouseWheelMove()*5
    if (brushSize < 2) then brushSize = 2
    if (brushSize > 50) then brushSize = 50

    if IsKeyPressed(KEY_C) then
        '' Clear render texture to clear color
        BeginTextureMode(target)
        ClearBackground(colors(0))
        EndTextureMode()
    end if

    if IsMouseButtonDown(MOUSE_BUTTON_LEFT) or (GetGestureDetected() = GESTURE_DRAG) then
        '' Paint circle into render texture
        '' NOTE: To avoid discontinuous circles, we could store
        '' previous-next mouse points and just draw a line using brush size
        BeginTextureMode(target)
        if mousePos.y > 50 then DrawCircle(mousePos.x, mousePos.y, brushSize, colors(colorSelected))
        EndTextureMode()
    end if

    if IsMouseButtonDown(MOUSE_BUTTON_RIGHT) then
        if not mouseWasPressed then
            colorSelectedPrev = colorSelected
            colorSelected = 0
        end if

        mouseWasPressed = true

        '' Erase circle from render texture
        BeginTextureMode(target)
        if mousePos.y > 50 then DrawCircle(mousePos.x, mousePos.y, brushSize, colors(0))
        EndTextureMode()
    elseif IsMouseButtonReleased(MOUSE_BUTTON_RIGHT) and mouseWasPressed then
        colorSelected = colorSelectedPrev
        mouseWasPressed = false
    end if

    '' Check mouse hover save button
    if CheckCollisionPointRec(mousePos, btnSaveRec) then
        btnSaveMouseHover = true
    else 
        btnSaveMouseHover = false
    end if

    '' Image saving logic
    '' NOTE: Saving painted texture to a default named image
    if (btnSaveMouseHover and IsMouseButtonReleased(MOUSE_BUTTON_LEFT)) or IsKeyPressed(KEY_S) then
        dim as Image img = LoadImageFromTexture(target.texture)
        ImageFlipVertical(@img)
        ExportImage(img, "my_amazing_texture_painting.png")
        UnloadImage(img)
        showSaveMessage = true
    end if

    if showSaveMessage then
        '' On saving, show a full screen message for 2 seconds
        saveMessageCounter += 1
        if saveMessageCounter > 240 then
            showSaveMessage = false
            saveMessageCounter = 0
        end if
    end if
    ''----------------------------------------------------------------------------------

    '' Draw
    ''----------------------------------------------------------------------------------
    BeginDrawing()

    ClearBackground(RAYWHITE)

    '' NOTE: Render texture must be y-flipped due to default OpenGL coordinates (left-bottom)
    DrawTextureRec(target.texture, Rectangle(0, 0, target.texture.width, -target.texture.height), Vector2(0, 0), WHITE)

    '' Draw drawing circle for reference
    if mousePos.y > 50 then
        if IsMouseButtonDown(MOUSE_BUTTON_RIGHT) then
            DrawCircleLines(mousePos.x, mousePos.y, brushSize, GRAY)
        else
            DrawCircle(GetMouseX(), GetMouseY(), brushSize, colors(colorSelected))
        end if
    end if

    '' Draw top panel
    DrawRectangle(0, 0, GetScreenWidth(), 50, RAYWHITE)
    DrawLine(0, 50, GetScreenWidth(), 50, LIGHTGRAY)

    '' Draw color selection rectangles
    for i as integer = 0 to MAX_COLORS_COUNT - 1
        DrawRectangleRec(colorsRecs(i), colors(i))
    next
    DrawRectangleLines(10, 10, 30, 30, LIGHTGRAY)

    if colorMouseHover >= 0 then DrawRectangleRec(colorsRecs(colorMouseHover), Fade(WHITE, 0.6f))

    DrawRectangleLinesEx(Rectangle(colorsRecs(colorSelected).x - 2, colorsRecs(colorSelected).y - 2, _
                            colorsRecs(colorSelected).width + 4, colorsRecs(colorSelected).height + 4), 2, BLACK)

    '' Draw save image button
    DrawRectangleLinesEx(btnSaveRec, 2, iif(btnSaveMouseHover, RED, BLACK))
    DrawText("SAVE!", 755, 20, 10, iif(btnSaveMouseHover, RED, BLACK))

    '' Draw save image message
    if showSaveMessage then
        DrawRectangle(0, 0, GetScreenWidth(), GetScreenHeight(), Fade(RAYWHITE, 0.8f))
        DrawRectangle(0, 150, GetScreenWidth(), 80, BLACK)
        DrawText("IMAGE SAVED:  my_amazing_texture_painting.png", 150, 180, 20, RAYWHITE)
    end if

    EndDrawing()
    ''----------------------------------------------------------------------------------
loop

'' De-Initialization
''--------------------------------------------------------------------------------------
UnloadRenderTexture(target)    '' Unload render texture

CloseWindow()                  '' Close window and OpenGL context
''--------------------------------------------------------------------------------------