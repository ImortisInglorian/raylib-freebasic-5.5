/'******************************************************************************************
*
*   raylib [models] example - Drawing billboards
*
*   Example originally created with raylib 1.3, last time updated with raylib 3.5
*
*   Example licensed under an unmodified zlib/libpng license, which is an OSI-certified,
*   BSD-like license that allows static linking with closed source software
*
*   Copyright (c) 2015-2024 Ramon Santamaria (@raysan5)
*
*******************************************************************************************'/

#include "../../raylib.bi"

'' Initialization
''--------------------------------------------------------------------------------------
const as long screenWidth = 800
const as long screenHeight = 450

InitWindow(screenWidth, screenHeight, "raylib [models] example - drawing billboards")

'' Define the camera to look into our 3d world
dim as Camera cam
with cam
    .position = Vector3(5.0f, 4.0f, 5.0f)    '' Camera position
    .target = Vector3(0.0f, 2.0f, 0.0f)      '' Camera looking at point
    .up = Vector3(0.0f, 1.0f, 0.0f)          '' Camera up vector (rotation towards target)
    .fovy = 45.0f                                '' Camera field-of-view Y
    .projection = CAMERA_PERSPECTIVE             '' Camera projection type
end with

dim as Texture2D bill = LoadTexture("resources/billboard.png")    '' Our billboard texture
dim as Vector3 billPositionStatic = Vector3(0.0f, 2.0f, 0.0f)          '' Position of static billboard
dim as Vector3 billPositionRotating = Vector3(1.0f, 2.0f, 1.0f)        '' Position of rotating billboard

'' Entire billboard texture, source is used to take a segment from a larger texture.
dim as Rectangle source = Rectangle(0.0f, 0.0f, bill.width, bill.height)

'' NOTE: Billboard locked on axis-Y
dim as Vector3 billUp = Vector3(0.0f, 1.0f, 0.0f)

'' Set the height of the rotating billboard to 1.0 with the aspect ratio fixed
dim as Vector2 size = Vector2(source.width/source.height, 1.0f)

'' Rotate around origin
'' Here we choose to rotate around the image center
dim as Vector2 origin = Vector2Scale(size, 0.5f)

'' Distance is needed for the correct billboard draw order
'' Larger distance (further away from the camera) should be drawn prior to smaller distance.
dim as single distanceStatic
dim as single distanceRotating
dim as single rotation = 0.0f

SetTargetFPS(60)                   '' Set our game to run at 60 frames-per-second
''--------------------------------------------------------------------------------------

'' Main game loop
do while not WindowShouldClose()        '' Detect window close button or ESC key
    '' Update
    ''----------------------------------------------------------------------------------
    UpdateCamera(@cam, CAMERA_ORBITAL)

    rotation += 0.4f
    distanceStatic = Vector3Distance(cam.position, billPositionStatic)
    distanceRotating = Vector3Distance(cam.position, billPositionRotating)
    ''----------------------------------------------------------------------------------

    '' Draw
    ''----------------------------------------------------------------------------------
    BeginDrawing()

        ClearBackground(RAYWHITE)

        BeginMode3D(cam)

            DrawGrid(10, 1.0f)        '' Draw a grid

            '' Draw order matters!
            if (distanceStatic > distanceRotating) then
                DrawBillboard(cam, bill, billPositionStatic, 2.0f, WHITE)
                DrawBillboardPro(cam, bill, source, billPositionRotating, billUp, size, origin, rotation, WHITE)
            else
                DrawBillboardPro(cam, bill, source, billPositionRotating, billUp, size, origin, rotation, WHITE)
                DrawBillboard(cam, bill, billPositionStatic, 2.0f, WHITE)
            end if
            
        EndMode3D()

        DrawFPS(10, 10)

    EndDrawing()
    ''----------------------------------------------------------------------------------
loop

'' De-Initialization
''--------------------------------------------------------------------------------------
UnloadTexture(bill)        '' Unload texture

CloseWindow()              '' Close window and OpenGL context
''--------------------------------------------------------------------------------------