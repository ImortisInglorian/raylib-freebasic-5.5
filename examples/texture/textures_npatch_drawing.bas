/'******************************************************************************************
*
*   raylib [textures] example - N-patch drawing
*
*   NOTE: Images are loaded in CPU memory (RAM) textures are loaded in GPU memory (VRAM)
*
*   Example originally created with raylib 2.0, last time updated with raylib 2.5
*
*   Example contributed by Jorge A. Gomes (@overdev) and reviewed by Ramon Santamaria (@raysan5)
*
*   Example licensed under an unmodified zlib/libpng license, which is an OSI-certified,
*   BSD-like license that allows static linking with closed source software
*
*   Copyright (c) 2018-2024 Jorge A. Gomes (@overdev) and Ramon Santamaria (@raysan5)
*
*******************************************************************************************'/

#include "../../raylib.bi"

'' Initialization
''--------------------------------------------------------------------------------------
const as long screenWidth = 800
const as long screenHeight = 450

InitWindow(screenWidth, screenHeight, "raylib [textures] example - N-patch drawing")

'' NOTE: Textures MUST be loaded after Window initialization (OpenGL context is required)
dim as Texture2D nPatchTexture = LoadTexture("resources/ninepatch_button.png")

dim as Vector2 mousePosition
dim as Vector2 origin = Vector2(0.0f, 0.0f)

'' Position and size of the n-patches
dim as Rectangle dstRec1 = Rectangle(480.0f, 160.0f, 32.0f, 32.0f)
dim as Rectangle dstRec2 = Rectangle(160.0f, 160.0f, 32.0f, 32.0f)
dim as Rectangle dstRecH = Rectangle(160.0f, 93.0f, 32.0f, 32.0f)
dim as Rectangle dstRecV = Rectangle(92.0f, 160.0f, 32.0f, 32.0)

'' A 9-patch (NPATCH_NINE_PATCH) changes its sizes in both axis
dim as NPatchInfo ninePatchInfo1 = NPatchInfo(Rectangle(0.0f, 0.0f, 64.0f, 64.0f), 12, 40, 12, 12, NPATCH_NINE_PATCH)
dim as NPatchInfo ninePatchInfo2 = NPatchInfo(Rectangle(0.0f, 128.0f, 64.0f, 64.0f), 16, 16, 16, 16, NPATCH_NINE_PATCH)

'' A horizontal 3-patch (NPATCH_THREE_PATCH_HORIZONTAL) changes its sizes along the x axis only
dim as NPatchInfo h3PatchInfo = NPatchInfo(Rectangle(0.0f,  64.0f, 64.0f, 64.0f), 8, 8, 8, 8, NPATCH_THREE_PATCH_HORIZONTAL)

'' A vertical 3-patch (NPATCH_THREE_PATCH_VERTICAL) changes its sizes along the y axis only
dim as NPatchInfo v3PatchInfo = NPatchInfo(Rectangle(0.0f, 192.0f, 64.0f, 64.0f), 6, 6, 6, 6, NPATCH_THREE_PATCH_VERTICAL)

SetTargetFPS(60)
''---------------------------------------------------------------------------------------

'' Main game loop
do while not WindowShouldClose()    '' Detect window close button or ESC key
    '' Update
    ''----------------------------------------------------------------------------------
    mousePosition = GetMousePosition()

    '' Resize the n-patches based on mouse position
    dstRec1.width = mousePosition.x - dstRec1.x
    dstRec1.height = mousePosition.y - dstRec1.y
    dstRec2.width = mousePosition.x - dstRec2.x
    dstRec2.height = mousePosition.y - dstRec2.y
    dstRecH.width = mousePosition.x - dstRecH.x
    dstRecV.height = mousePosition.y - dstRecV.y

    '' Set a minimum width and/or height
    if (dstRec1.width < 1.0f) then dstRec1.width = 1.0f
    if (dstRec1.width > 300.0f) then dstRec1.width = 300.0f
    if (dstRec1.height < 1.0f) then dstRec1.height = 1.0f
    if (dstRec2.width < 1.0f) then dstRec2.width = 1.0f
    if (dstRec2.width > 300.0f) then dstRec2.width = 300.0f
    if (dstRec2.height < 1.0f) then dstRec2.height = 1.0f
    if (dstRecH.width < 1.0f) then dstRecH.width = 1.0f
    if (dstRecV.height < 1.0f) then dstRecV.height = 1.0f
    ''----------------------------------------------------------------------------------

    '' Draw
    ''----------------------------------------------------------------------------------
    BeginDrawing()

        ClearBackground(RAYWHITE)

        '' Draw the n-patches
        DrawTextureNPatch(nPatchTexture, ninePatchInfo2, dstRec2, origin, 0.0f, WHITE)
        DrawTextureNPatch(nPatchTexture, ninePatchInfo1, dstRec1, origin, 0.0f, WHITE)
        DrawTextureNPatch(nPatchTexture, h3PatchInfo, dstRecH, origin, 0.0f, WHITE)
        DrawTextureNPatch(nPatchTexture, v3PatchInfo, dstRecV, origin, 0.0f, WHITE)

        '' Draw the source texture
        DrawRectangleLines(5, 88, 74, 266, BLUE)
        DrawTexture(nPatchTexture, 10, 93, WHITE)
        DrawText("TEXTURE", 15, 360, 10, DARKGRAY)

        DrawText("Move the mouse to stretch or shrink the n-patches", 10, 20, 20, DARKGRAY)

    EndDrawing()
    ''----------------------------------------------------------------------------------
loop

'' De-Initialization
''--------------------------------------------------------------------------------------
UnloadTexture(nPatchTexture)       '' Texture unloading

CloseWindow()                '' Close window and OpenGL context
''--------------------------------------------------------------------------------------