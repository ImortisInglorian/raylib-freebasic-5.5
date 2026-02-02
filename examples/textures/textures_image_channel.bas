/'******************************************************************************************
*
*   raylib [textures] example - Retrive image channel (mask)
*
*   NOTE: Images are loaded in CPU memory (RAM) textures are loaded in GPU memory (VRAM)
*
*   Example originally created with raylib 5.1-dev, last time updated with raylib 5.1-dev
*
*   Example contributed by Bruno Cabral (github.com/brccabral) and reviewed by Ramon Santamaria (@raysan5)
*
*   Example licensed under an unmodified zlib/libpng license, which is an OSI-certified,
*   BSD-like license that allows static linking with closed source software
*
*   Copyright (c) 2024-2024 Bruno Cabral (github.com/brccabral) and Ramon Santamaria (@raysan5)
*
*******************************************************************************************'/

#include "../../raylib.bi"

'' Initialization
''--------------------------------------------------------------------------------------

const as long screenWidth = 800
const as long screenHeight = 450

InitWindow(screenWidth, screenHeight, "raylib [textures] example - extract channel from image")

dim as Image fudesumiImage = LoadImage("resources/fudesumi.png")

dim as Image imageAlpha = ImageFromChannel(fudesumiImage, 3)
ImageAlphaMask(@imageAlpha, imageAlpha)

dim as Image imageRed = ImageFromChannel(fudesumiImage, 0)
ImageAlphaMask(@imageRed, imageAlpha)

dim as Image imageGreen = ImageFromChannel(fudesumiImage, 1)
ImageAlphaMask(@imageGreen, imageAlpha)

dim as Image imageBlue = ImageFromChannel(fudesumiImage, 2)
ImageAlphaMask(@imageBlue, imageAlpha)

dim as Image backgroundImage = GenImageChecked(screenWidth, screenHeight, screenWidth/20, screenHeight/20, ORANGE, YELLOW)

dim as Texture2D fudesumiTexture = LoadTextureFromImage(fudesumiImage)
dim as Texture2D textureAlpha = LoadTextureFromImage(imageAlpha)
dim as Texture2D textureRed = LoadTextureFromImage(imageRed)
dim as Texture2D textureGreen = LoadTextureFromImage(imageGreen)
dim as Texture2D textureBlue = LoadTextureFromImage(imageBlue)
dim as Texture2D backgroundTexture = LoadTextureFromImage(backgroundImage)

UnloadImage(fudesumiImage)
UnloadImage(imageAlpha)
UnloadImage(imageRed)
UnloadImage(imageGreen)
UnloadImage(imageBlue)
UnloadImage(backgroundImage)

SetTargetFPS(60)               '' Set our game to run at 60 frames-per-second

dim as Rectangle fudesumiRec = Rectangle(0, 0, fudesumiImage.width, fudesumiImage.height)

dim as Rectangle fudesumiPos = Rectangle(50, 10, fudesumiImage.width*0.8f, fudesumiImage.height*0.8f)
dim as Rectangle redPos = Rectangle(410, 10, fudesumiPos.width / 2, fudesumiPos.height / 2)
dim as Rectangle greenPos = Rectangle(600, 10, fudesumiPos.width / 2, fudesumiPos.height / 2)
dim as Rectangle bluePos = Rectangle(410, 230, fudesumiPos.width / 2, fudesumiPos.height / 2)
dim as Rectangle alphaPos = Rectangle(600, 230, fudesumiPos.width / 2, fudesumiPos.height / 2)

''--------------------------------------------------------------------------------------

'' Main game loop
do while not WindowShouldClose()    '' Detect window close button or ESC key
    '' Draw
    ''----------------------------------------------------------------------------------
    BeginDrawing()

        DrawTexture(backgroundTexture, 0, 0, WHITE)
        DrawTexturePro(fudesumiTexture, fudesumiRec, fudesumiPos, Vector2(0, 0), 0, WHITE)

        DrawTexturePro(textureRed, fudesumiRec, redPos, Vector2(0, 0), 0, RED)
        DrawTexturePro(textureGreen, fudesumiRec, greenPos, Vector2(0, 0), 0, GREEN)
        DrawTexturePro(textureBlue, fudesumiRec, bluePos, Vector2(0, 0), 0, BLUE)
        DrawTexturePro(textureAlpha, fudesumiRec, alphaPos, Vector2(0, 0), 0, WHITE)

    EndDrawing()
    ''----------------------------------------------------------------------------------
loop

'' De-Initialization
''--------------------------------------------------------------------------------------
UnloadTexture(backgroundTexture)
UnloadTexture(fudesumiTexture)
UnloadTexture(textureRed)
UnloadTexture(textureGreen)
UnloadTexture(textureBlue)
UnloadTexture(textureAlpha)
CloseWindow()        '' Close window and OpenGL context
''--------------------------------------------------------------------------------------