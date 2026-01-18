/'******************************************************************************************
*
*   raylib [core] example - window scale letterbox (and virtual mouse)
*
*   Example originally created with raylib 2.5, last time updated with raylib 4.0
*
*   Example contributed by Anata (@anatagawa) and reviewed by Ramon Santamaria (@raysan5)
*
*   Example licensed under an unmodified zlib/libpng license, which is an OSI-certified,
*   BSD-like license that allows static linking with closed source software
*
*   Copyright (c) 2019-2024 Anata (@anatagawa) and Ramon Santamaria (@raysan5)
*
*******************************************************************************************'/

#include "../../raylib.bi"

#define MAX(a, b) iif((a)>(b), (a), (b))
#define MIN(a, b) iif((a)<(b), (a), (b))

const as long windowWidth = 800
const as long windowHeight = 450

'' Enable config flags for resizable window and vertical synchro
SetConfigFlags(FLAG_WINDOW_RESIZABLE or FLAG_VSYNC_HINT)
InitWindow(windowWidth, windowHeight, "raylib [core] example - window scale letterbox")
SetWindowMinSize(320, 240)

dim as long gameScreenWidth = 640
dim as long gameScreenHeight = 480

'' Render texture initialization, used to hold the rendering result so we can easily resize it
dim as RenderTexture2D target = LoadRenderTexture(gameScreenWidth, gameScreenHeight)
SetTextureFilter(target.texture, TEXTURE_FILTER_BILINEAR)  '' Texture scale filter to use

dim as RLColor colors(0 to 9)
for i as integer = 0 to 9 
    colors(i) = RLColor(GetRandomValue(100, 250), GetRandomValue(50, 150), GetRandomValue(10, 100), 255)
next

SetTargetFPS(60)                   '' Set our game to run at 60 frames-per-second
''--------------------------------------------------------------------------------------

'' Main game loop
do while not WindowShouldClose()        '' Detect window close button or ESC key
    '' Update
    ''----------------------------------------------------------------------------------
    '' Compute required framebuffer scaling
    dim as single scale = MIN(GetScreenWidth()/gameScreenWidth, GetScreenHeight()/gameScreenHeight)

    if IsKeyPressed(KEY_SPACE) then
        '' Recalculate random colors for the bars
        for i as integer = 0 to 9 
            colors(i) = RLColor(GetRandomValue(100, 250), GetRandomValue(50, 150), GetRandomValue(10, 100), 255)
        next
    end if

    '' Update virtual mouse (clamped mouse value behind game screen)
    dim as Vector2 mouse = GetMousePosition()
    dim as Vector2 virtualMouse
    with virtualMouse
        .x = (mouse.x - (GetScreenWidth() - (gameScreenWidth*scale))*0.5f)/scale
        .y = (mouse.y - (GetScreenHeight() - (gameScreenHeight*scale))*0.5f)/scale
    end with
    virtualMouse = Vector2Clamp(virtualMouse, Vector2(0, 0), Vector2(gameScreenWidth, gameScreenHeight))

    '' Apply the same transformation as the virtual mouse to the real mouse (i.e. to work with raygui)
    ''SetMouseOffset(-(GetScreenWidth() - (gameScreenWidth*scale))*0.5f, -(GetScreenHeight() - (gameScreenHeight*scale))*0.5f)
    ''SetMouseScale(1/scale, 1/scale)
    ''----------------------------------------------------------------------------------

    '' Draw
    ''----------------------------------------------------------------------------------
    '' Draw everything in the render texture, note this will not be rendered on screen, yet
    BeginTextureMode(target)
        ClearBackground(RAYWHITE)  '' Clear render texture background color

        for i as integer = 0 to 9
            DrawRectangle(0, (gameScreenHeight/10)*i, gameScreenWidth, gameScreenHeight/10, colors(i))
        next

        DrawText("If executed inside a window,\nyou can resize the window,\nand see the screen scaling!", 10, 25, 20, WHITE)
        DrawText(TextFormat("Default Mouse: [%i , %i]", mouse.x, mouse.y), 350, 25, 20, GREEN)
        DrawText(TextFormat("Virtual Mouse: [%i , %i]", virtualMouse.x, virtualMouse.y), 350, 55, 20, YELLOW)
    EndTextureMode()
    
    BeginDrawing()
        ClearBackground(BLACK)     '' Clear screen background

        '' Draw render texture to screen, properly scaled
        DrawTexturePro(target.texture, Rectangle(0.0f, 0.0f, target.texture.width, -target.texture.height), _
                        Rectangle((GetScreenWidth() - (gameScreenWidth*scale))*0.5f, (GetScreenHeight() - (gameScreenHeight*scale))*0.5f, _
                        gameScreenWidth*scale, gameScreenHeight*scale), Vector2(0, 0), 0.0f, WHITE)
    EndDrawing()
    ''--------------------------------------------------------------------------------------
loop

'' De-Initialization
''--------------------------------------------------------------------------------------
UnloadRenderTexture(target)        '' Unload render texture

CloseWindow()                      '' Close window and OpenGL context
''--------------------------------------------------------------------------------------