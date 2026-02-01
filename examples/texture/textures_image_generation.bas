/'******************************************************************************************
*
*   raylib [textures] example - Procedural images generation
*
*   Example originally created with raylib 1.8, last time updated with raylib 1.8
*
*   Example licensed under an unmodified zlib/libpng license, which is an OSI-certified,
*   BSD-like license that allows static linking with closed source software
*
*   Copyright (c) 2O17-2024 Wilhem Barbier (@nounoursheureux) and Ramon Santamaria (@raysan5)
*
*******************************************************************************************'/

#include "../../raylib.bi"

#define NUM_TEXTURES  9      '' Currently we have 8 generation algorithms but some have multiple purposes (Linear and Square Gradients)

'' Initialization
''--------------------------------------------------------------------------------------
const as long screenWidth = 800
const as long screenHeight = 450

InitWindow(screenWidth, screenHeight, "raylib [textures] example - procedural images generation")

dim as Image verticalGradient = GenImageGradientLinear(screenWidth, screenHeight, 0, RED, BLUE)
dim as Image horizontalGradient = GenImageGradientLinear(screenWidth, screenHeight, 90, RED, BLUE)
dim as Image diagonalGradient = GenImageGradientLinear(screenWidth, screenHeight, 45, RED, BLUE)
dim as Image radialGradient = GenImageGradientRadial(screenWidth, screenHeight, 0.0f, WHITE, BLACK)
dim as Image squareGradient = GenImageGradientSquare(screenWidth, screenHeight, 0.0f, WHITE, BLACK)
dim as Image checked = GenImageChecked(screenWidth, screenHeight, 32, 32, RED, BLUE)
dim as Image whiteNoise = GenImageWhiteNoise(screenWidth, screenHeight, 0.5f)
dim as Image perlinNoise = GenImagePerlinNoise(screenWidth, screenHeight, 50, 50, 4.0f)
dim as Image cellular = GenImageCellular(screenWidth, screenHeight, 32)

dim as Texture2D textures(NUM_TEXTURES - 1)

textures(0) = LoadTextureFromImage(verticalGradient)
textures(1) = LoadTextureFromImage(horizontalGradient)
textures(2) = LoadTextureFromImage(diagonalGradient)
textures(3) = LoadTextureFromImage(radialGradient)
textures(4) = LoadTextureFromImage(squareGradient)
textures(5) = LoadTextureFromImage(checked)
textures(6) = LoadTextureFromImage(whiteNoise)
textures(7) = LoadTextureFromImage(perlinNoise)
textures(8) = LoadTextureFromImage(cellular)

'' Unload image data (CPU RAM)
UnloadImage(verticalGradient)
UnloadImage(horizontalGradient)
UnloadImage(diagonalGradient)
UnloadImage(radialGradient)
UnloadImage(squareGradient)
UnloadImage(checked)
UnloadImage(whiteNoise)
UnloadImage(perlinNoise)
UnloadImage(cellular)

dim as long currentTexture = 0

SetTargetFPS(60)
''---------------------------------------------------------------------------------------

'' Main game loop
do while not WindowShouldClose()
    '' Update
    ''----------------------------------------------------------------------------------
    if IsMouseButtonPressed(MOUSE_BUTTON_LEFT) or IsKeyPressed(KEY_RIGHT) then
        currentTexture = (currentTexture + 1) mod NUM_TEXTURES '' Cycle between the textures
    end if
    ''----------------------------------------------------------------------------------

    '' Draw
    ''----------------------------------------------------------------------------------
    BeginDrawing()

        ClearBackground(RAYWHITE)

        DrawTexture(textures(currentTexture), 0, 0, WHITE)

        DrawRectangle(30, 400, 325, 30, Fade(SKYBLUE, 0.5f))
        DrawRectangleLines(30, 400, 325, 30, Fade(WHITE, 0.5f))
        DrawText("MOUSE LEFT BUTTON to CYCLE PROCEDURAL TEXTURES", 40, 410, 10, WHITE)

        select case currentTexture
            case 0
                DrawText("VERTICAL GRADIENT", 560, 10, 20, RAYWHITE)
            case 1
                DrawText("HORIZONTAL GRADIENT", 540, 10, 20, RAYWHITE)
            case 2
                DrawText("DIAGONAL GRADIENT", 540, 10, 20, RAYWHITE)
            case 3
                DrawText("RADIAL GRADIENT", 580, 10, 20, LIGHTGRAY)
            case 4
                DrawText("SQUARE GRADIENT", 580, 10, 20, LIGHTGRAY)
            case 5
                DrawText("CHECKED", 680, 10, 20, RAYWHITE)
            case 6
                DrawText("WHITE NOISE", 640, 10, 20, RED)
            case 7
                DrawText("PERLIN NOISE", 640, 10, 20, RED)
            case 8
                DrawText("CELLULAR", 670, 10, 20, RAYWHITE)
        end select

    EndDrawing()
    ''----------------------------------------------------------------------------------
loop

'' De-Initialization
''--------------------------------------------------------------------------------------

'' Unload textures data (GPU VRAM)
for i as integer = 0 to NUM_TEXTURES - 1
    UnloadTexture(textures(i))
next

CloseWindow()                '' Close window and OpenGL context
''--------------------------------------------------------------------------------------