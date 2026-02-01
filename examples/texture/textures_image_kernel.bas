/'******************************************************************************************
*
*   raylib [textures] example - Image loading and texture creation
*
*   NOTE: Images are loaded in CPU memory (RAM) textures are loaded in GPU memory (VRAM)
*
*   Example originally created with raylib 1.3, last time updated with raylib 1.3
*
*   Example licensed under an unmodified zlib/libpng license, which is an OSI-certified,
*   BSD-like license that allows static linking with closed source software
*
*   Copyright (c) 2015-2024 Karim Salem (@kimo-s)
*
*******************************************************************************************'/

#include "../../raylib.bi"


sub NormalizeKernel(kernel() as single, size as long)
    dim as single sum = 0.0f
    for i as integer = 0 to size - 1
        sum += kernel(i)
    next

    if sum <> 0.0f then
        for i as integer = 0 to size - 1
            kernel(i) /= sum
        next
    end if
end sub

''------------------------------------------------------------------------------------
'' Program main entry point
''------------------------------------------------------------------------------------
'' Initialization
''--------------------------------------------------------------------------------------
const as long screenWidth = 800
const as long screenHeight = 450

InitWindow(screenWidth, screenHeight, "raylib [textures] example - image convolution")
    
dim as Image img = LoadImage("resources/cat.png")     '' Loaded in CPU memory (RAM)

dim as single gaussiankernel(...) = { _
    1.0f, 2.0f, 1.0f, _
    2.0f, 4.0f, 2.0f, _
    1.0f, 2.0f, 1.0f }

dim as single sobelkernel(...) = { _
    1.0f, 0.0f, -1.0f, _
    2.0f, 0.0f, -2.0f, _
    1.0f, 0.0f, -1.0f }

dim as single sharpenkernel(...) = { _
    0.0f, -1.0f, 0.0f, _
    -1.0f, 5.0f, -1.0f, _
    0.0f, -1.0f, 0.0f }

NormalizeKernel(gaussiankernel(), 9)
NormalizeKernel(sharpenkernel(), 9)
NormalizeKernel(sobelkernel(), 9)

dim as Image catSharpend = ImageCopy(img)
ImageKernelConvolution(@catSharpend, @sharpenkernel(0), 9)

dim as Image catSobel = ImageCopy(img)
ImageKernelConvolution(@catSobel, @sobelkernel(0), 9)

dim as Image catGaussian = ImageCopy(img)

for i as integer = 0 to 5
    ImageKernelConvolution(@catGaussian, @gaussiankernel(0), 9)
next

ImageCrop(@img, Rectangle(0, 0, 200, 450))
ImageCrop(@catGaussian, Rectangle(0, 0, 200, 450))
ImageCrop(@catSobel, Rectangle(0, 0, 200, 450))
ImageCrop(@catSharpend, Rectangle(0, 0, 200, 450))

'' Images converted to texture, GPU memory (VRAM)
dim as Texture2D tex = LoadTextureFromImage(img)
dim as Texture2D catSharpendTexture = LoadTextureFromImage(catSharpend)
dim as Texture2D catSobelTexture = LoadTextureFromImage(catSobel)
dim as Texture2D catGaussianTexture = LoadTextureFromImage(catGaussian)

'' Once images have been converted to texture and uploaded to VRAM, 
'' they can be unloaded from RAM
UnloadImage(img)
UnloadImage(catGaussian)
UnloadImage(catSobel)
UnloadImage(catSharpend)

SetTargetFPS(60)     '' Set our game to run at 60 frames-per-second
''---------------------------------------------------------------------------------------

'' Main game loop
do while not WindowShouldClose()    '' Detect window close button or ESC key
    '' Draw
    ''----------------------------------------------------------------------------------
    BeginDrawing()

        ClearBackground(RAYWHITE)

        DrawTexture(catSharpendTexture, 0, 0, WHITE)
        DrawTexture(catSobelTexture, 200, 0, WHITE)
        DrawTexture(catGaussianTexture, 400, 0, WHITE)
        DrawTexture(tex, 600, 0, WHITE)

    EndDrawing()
    ''----------------------------------------------------------------------------------
loop

'' De-Initialization
''--------------------------------------------------------------------------------------
UnloadTexture(tex)
UnloadTexture(catGaussianTexture)
UnloadTexture(catSobelTexture)
UnloadTexture(catSharpendTexture)

CloseWindow()                '' Close window and OpenGL context
''--------------------------------------------------------------------------------------