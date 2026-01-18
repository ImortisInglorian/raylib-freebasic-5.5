/'******************************************************************************************
*
*   raylib [models] example - Waving cubes
*
*   Example originally created with raylib 2.5, last time updated with raylib 3.7
*
*   Example contributed by Codecat (@codecat) and reviewed by Ramon Santamaria (@raysan5)
*
*   Example licensed under an unmodified zlib/libpng license, which is an OSI-certified,
*   BSD-like license that allows static linking with closed source software
*
*   Copyright (c) 2019-2024 Codecat (@codecat) and Ramon Santamaria (@raysan5)
*
*******************************************************************************************'/

#include "../../raylib.bi"

'' Initialization
''--------------------------------------------------------------------------------------
const as long screenWidth = 800
const as long screenHeight = 450

InitWindow(screenWidth, screenHeight, "raylib [models] example - waving cubes")

'' Initialize the camera
dim as Camera3D cam
with cam
    .position = Vector3(30.0f, 20.0f, 30.0f) '' Camera position
    .target = Vector3(0.0f, 0.0f, 0.0f)      '' Camera looking at point
    .up = Vector3(0.0f, 1.0f, 0.0f)          '' Camera up vector (rotation towards target)
    .fovy = 70.0f                            '' Camera field-of-view Y
    .projection = CAMERA_PERSPECTIVE         '' Camera projection type
end with

'' Specify the amount of blocks in each direction
const as long numBlocks = 15

SetTargetFPS(60)
''--------------------------------------------------------------------------------------

'' Main game loop
do while not WindowShouldClose()    '' Detect window close button or ESC key
    '' Update
    ''----------------------------------------------------------------------------------
    dim as double tim = GetTime()

    '' Calculate time scale for cube position and size
    dim as single scale = (2.0f + sin(tim)) * 0.7f

    '' Move camera around the scene
    dim as double cameraTime = tim * 0.3
    cam.position.x = cos(cameraTime) * 40.0f
    cam.position.z = sin(cameraTime) * 40.0f
    ''----------------------------------------------------------------------------------

    '' Draw
    ''----------------------------------------------------------------------------------
    BeginDrawing()

        ClearBackground(RAYWHITE)

        BeginMode3D(cam)

            DrawGrid(10, 5.0f)

            for x as integer = 0 to numBlocks - 1
                for y as integer = 0 to numBlocks - 1
                    for z as integer = 0 to numBlocks - 1
                        '' Scale of the blocks depends on x/y/z positions
                        dim as single blockScale = (x + y + z) / 30.0f

                        '' Scatter makes the waving effect by adding blockScale over time
                        dim as single scatter = sin(blockScale * 20.0f + (tim * 4.0f))

                        '' Calculate the cube position
                        dim as Vector3 cubePos = Vector3(_
                            (x - numBlocks/2)*(scale*3.0f) + scatter,_
                            (y - numBlocks/2)*(scale*2.0f) + scatter,_
                            (z - numBlocks/2)*(scale*3.0f) + scatter _
                        )

                        '' Pick a color with a hue depending on cube position for the rainbow color effect
                        '' NOTE: This function is quite costly to be done per cube and frame, 
                        '' pre-catching the results into a separate array could improve performance
                        Dim as RLColor cubeColor = ColorFromHSV((((x + y + z) * 18) mod 360), 0.75f, 0.9f)

                        '' Calculate cube size
                        dim as single cubeSize = (2.4f - scale) * blockScale

                        '' And finally, draw the cube!
                        DrawCube(cubePos, cubeSize, cubeSize, cubeSize, cubeColor)
                    next
                next
            next

        EndMode3D()

        DrawFPS(10, 10)

    EndDrawing()
    ''----------------------------------------------------------------------------------
loop

'' De-Initialization
''--------------------------------------------------------------------------------------
CloseWindow()        '' Close window and OpenGL context
''--------------------------------------------------------------------------------------