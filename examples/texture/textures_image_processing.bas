/'******************************************************************************************
*
*   raylib [textures] example - Image processing
*
*   NOTE: Images are loaded in CPU memory (RAM) textures are loaded in GPU memory (VRAM)
*
*   Example originally created with raylib 1.4, last time updated with raylib 3.5
*
*   Example licensed under an unmodified zlib/libpng license, which is an OSI-certified,
*   BSD-like license that allows static linking with closed source software
*
*   Copyright (c) 2016-2024 Ramon Santamaria (@raysan5)
*
*******************************************************************************************'/

#include "../../raylib.bi"

#define NUM_PROCESSES    9

type  as long ImageProcess
enum
    NONE = 0
    COLOR_GRAYSCALE
    COLOR_TINT
    COLOR_INVERT
    COLOR_CONTRAST
    COLOR_BRIGHTNESS
    GAUSSIAN_BLUR
    FLIP_VERTICAL
    FLIP_HORIZONTAL
end enum

dim as zstring * 20 processText(...) = { _
    "NO PROCESSING", _
    "COLOR GRAYSCALE", _
    "COLOR TINT", _
    "COLOR INVERT", _
    "COLOR CONTRAST", _
    "COLOR BRIGHTNESS", _
    "GAUSSIAN BLUR", _
    "FLIP VERTICAL", _
    "FLIP HORIZONTAL" _
}

'' Initialization
''--------------------------------------------------------------------------------------
const as long screenWidth = 800
const as long screenHeight = 450

InitWindow(screenWidth, screenHeight, "raylib [textures] example - image processing")

'' NOTE: Textures MUST be loaded after Window initialization (OpenGL context is required)

dim as Image imOrigin = LoadImage("resources/parrots.png")   '' Loaded in CPU memory (RAM)
ImageFormat(@imOrigin, PIXELFORMAT_UNCOMPRESSED_R8G8B8A8)         '' Format image to RGBA 32bit (required for texture update) <-- ISSUE
dim as Texture2D tex = LoadTextureFromImage(imOrigin)    '' Image converted to texture, GPU memory (VRAM)

dim as Image imCopy = ImageCopy(imOrigin)

dim as long currentProcess = NONE
dim as boolean textureReload = false

dim as Rectangle toggleRecs(NUM_PROCESSES - 1)
dim as long mouseHoverRec = -1

for i as integer = 0 to NUM_PROCESSES - 1
    toggleRecs(i) = Rectangle(40.0f, (50 + 32*i), 150.0f, 30.0f)
next

SetTargetFPS(60)
''---------------------------------------------------------------------------------------

'' Main game loop
do while not WindowShouldClose()    '' Detect window close button or ESC key
    '' Update
    ''----------------------------------------------------------------------------------

    '' Mouse toggle group logic
    for i as integer = 0 to  NUM_PROCESSES - 1
        if CheckCollisionPointRec(GetMousePosition(), toggleRecs(i)) then
            mouseHoverRec = i

            if IsMouseButtonReleased(MOUSE_BUTTON_LEFT) then
                currentProcess = i
                textureReload = true
            end if
            exit for
        else
            mouseHoverRec = -1
        end if
    next

    '' Keyboard toggle group logic
    if IsKeyPressed(KEY_DOWN) then
        currentProcess += 1
        if currentProcess > (NUM_PROCESSES - 1) then currentProcess = 0
        textureReload = true
    elseif IsKeyPressed(KEY_UP) then
        currentProcess -= 1
        if currentProcess < 0 then currentProcess = 7
        textureReload = true
    end if

    '' Reload texture when required
    if textureReload then
        UnloadImage(imCopy)                '' Unload image-copy data
        imCopy = ImageCopy(imOrigin)     '' Restore image-copy from image-origin

        '' NOTE: Image processing is a costly CPU process to be done every frame,
        '' If image processing is required in a frame-basis, it should be done
        '' with a texture and by shaders
        select case currentProcess
            case COLOR_GRAYSCALE
                ImageColorGrayscale(@imCopy)
            case COLOR_TINT
                ImageColorTint(@imCopy, GREEN)
            case COLOR_INVERT
                ImageColorInvert(@imCopy)
            case COLOR_CONTRAST
                ImageColorContrast(@imCopy, -40)
            case COLOR_BRIGHTNESS
                ImageColorBrightness(@imCopy, -80)
            case GAUSSIAN_BLUR
                ImageBlurGaussian(@imCopy, 10)
            case FLIP_VERTICAL
                ImageFlipVertical(@imCopy)
            case FLIP_HORIZONTAL
                ImageFlipHorizontal(@imCopy)
        end select

        dim as RLColor ptr pixels = LoadImageColors(imCopy)    '' Load pixel data from image (RGBA 32bit)
        UpdateTexture(tex, pixels)             '' Update texture with new image data
        UnloadImageColors(pixels)                  '' Unload pixels data from RAM

        textureReload = false
    end if
    ''----------------------------------------------------------------------------------

    '' Draw
    ''----------------------------------------------------------------------------------
    BeginDrawing()

        ClearBackground(RAYWHITE)

        DrawText("IMAGE PROCESSING:", 40, 30, 10, DARKGRAY)

        '' Draw rectangles
        for i as integer = 0 to NUM_PROCESSES - 1
            DrawRectangleRec(toggleRecs(i), iif(((i = currentProcess) or (i = mouseHoverRec)), SKYBLUE, LIGHTGRAY))
            DrawRectangleLines(toggleRecs(i).x, toggleRecs(i).y, toggleRecs(i).width, toggleRecs(i).height, iif(((i = currentProcess) or (i = mouseHoverRec)), BLUE, GRAY))
            DrawText(processText(i), (toggleRecs(i).x + toggleRecs(i).width/2 - MeasureText(processText(i), 10)/2), toggleRecs(i).y + 11, 10, iif(((i = currentProcess) or (i = mouseHoverRec)), DARKBLUE, DARKGRAY))
        next

        DrawTexture(tex, screenWidth - tex.width - 60, screenHeight/2 - tex.height/2, WHITE)
        DrawRectangleLines(screenWidth - tex.width - 60, screenHeight/2 - tex.height/2, tex.width, tex.height, BLACK)

    EndDrawing()
    ''----------------------------------------------------------------------------------
loop

'' De-Initialization
''--------------------------------------------------------------------------------------
UnloadTexture(tex)       '' Unload texture from VRAM
UnloadImage(imOrigin)        '' Unload image-origin from RAM
UnloadImage(imCopy)          '' Unload image-copy from RAM

CloseWindow()                '' Close window and OpenGL context
''--------------------------------------------------------------------------------------