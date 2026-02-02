/'******************************************************************************************
*
*   raylib example - particles blending
*
*   Example originally created with raylib 1.7, last time updated with raylib 3.5
*
*   Example licensed under an unmodified zlib/libpng license, which is an OSI-certified,
*   BSD-like license that allows static linking with closed source software
*
*   Copyright (c) 2017-2024 Ramon Santamaria (@raysan5)
*
*******************************************************************************************'/

#include "../../raylib.bi"

#define MAX_PARTICLES 200

'' Particle structure with basic data
type Particle
    as Vector2 position
    as RLColor color
    as single alpha
    as single size
    as single rotation
    as boolean active        '' NOTE: Use it to activate/deactive particle
end type

'' Initialization
''--------------------------------------------------------------------------------------
const as long screenWidth = 800
const as long screenHeight = 450

InitWindow(screenWidth, screenHeight, "raylib [textures] example - particles blending")

'' Particles pool, reuse them!
dim as Particle mouseTail(MAX_PARTICLES - 1)

'' Initialize particles
for i as integer = 0 to MAX_PARTICLES - 1
    mouseTail(i).position = Vector2(0, 0)
    mouseTail(i).color = RLColor(GetRandomValue(0, 255), GetRandomValue(0, 255), GetRandomValue(0, 255), 255)
    mouseTail(i).alpha = 1.0f
    mouseTail(i).size = GetRandomValue(1, 30)/20.0f
    mouseTail(i).rotation = GetRandomValue(0, 360)
    mouseTail(i).active = false
next

dim as single gravity = 3.0f

dim as Texture2D smoke = LoadTexture("resources/spark_flame.png")

dim as long blending = BLEND_ALPHA

SetTargetFPS(60)
''--------------------------------------------------------------------------------------

'' Main game loop
do while not WindowShouldClose()    '' Detect window close button or ESC key
    '' Update
    ''----------------------------------------------------------------------------------

    '' Activate one particle every frame and Update active particles
    '' NOTE: Particles initial position should be mouse position when activated
    '' NOTE: Particles fall down with gravity and rotation... and disappear after 2 seconds (alpha = 0)
    '' NOTE: When a particle disappears, active = false and it can be reused.
    for i as integer = 0 to MAX_PARTICLES - 1
        if not mouseTail(i).active then
            mouseTail(i).active = true
            mouseTail(i).alpha = 1.0f
            mouseTail(i).position = GetMousePosition()
            i = MAX_PARTICLES
        end if
    next

    for i as integer = 0 to MAX_PARTICLES - 1
        if mouseTail(i).active then
            mouseTail(i).position.y += gravity/2
            mouseTail(i).alpha -= 0.005f

            if mouseTail(i).alpha <= 0.0f then mouseTail(i).active = false

            mouseTail(i).rotation += 2.0f
        end if
    next

    if IsKeyPressed(KEY_SPACE) then
        if blending = BLEND_ALPHA then
            blending = BLEND_ADDITIVE
        else
            blending = BLEND_ALPHA
        end if
    end if
    ''----------------------------------------------------------------------------------

    '' Draw
    ''----------------------------------------------------------------------------------
    BeginDrawing()

        ClearBackground(DARKGRAY)

        BeginBlendMode(blending)

            '' Draw active particles
            for i as integer = 0 to MAX_PARTICLES - 1
                if mouseTail(i).active then 
                    DrawTexturePro(smoke, Rectangle(0.0f, 0.0f, smoke.width, smoke.height), _
                                    Rectangle(mouseTail(i).position.x, mouseTail(i).position.y, smoke.width*mouseTail(i).size, smoke.height*mouseTail(i).size), _
                                    Vector2((smoke.width*mouseTail(i).size/2.0f), (smoke.height*mouseTail(i).size/2.0f)), mouseTail(i).rotation, _
                                    Fade(mouseTail(i).color, mouseTail(i).alpha))
                end if
            next

        EndBlendMode()

        DrawText("PRESS SPACE to CHANGE BLENDING MODE", 180, 20, 20, BLACK)

        if blending = BLEND_ALPHA then
            DrawText("ALPHA BLENDING", 290, screenHeight - 40, 20, BLACK)
        else
            DrawText("ADDITIVE BLENDING", 280, screenHeight - 40, 20, RAYWHITE)
        end if

    EndDrawing()
    ''----------------------------------------------------------------------------------
loop

'' De-Initialization
''--------------------------------------------------------------------------------------
UnloadTexture(smoke)

CloseWindow()        '' Close window and OpenGL context
''--------------------------------------------------------------------------------------