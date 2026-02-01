/'******************************************************************************************
*
*   raylib [shapes] example - Draw Textured Polygon
*
*   Example originally created with raylib 3.7, last time updated with raylib 3.7
*
*   Example contributed by Chris Camacho (@codifies) and reviewed by Ramon Santamaria (@raysan5)
*
*   Example licensed under an unmodified zlib/libpng license, which is an OSI-certified,
*   BSD-like license that allows static linking with closed source software
*
*   Copyright (c) 2021-2024 Chris Camacho (@codifies) and Ramon Santamaria (@raysan5)
*
*******************************************************************************************'/

#include "../../raylib.bi"
#include "../../rlgl.bi"           '' Required for: Vertex definition

#define MAX_POINTS  11      '' 10 points and back to the start

'' Draw textured polygon, defined by vertex and texture coordinates
declare sub DrawTexturePoly(tex as Texture2D, center as Vector2, points() as Vector2, texcoords() as Vector2, pointCount as long, tint as RLColor)

''------------------------------------------------------------------------------------
'' Program main entry point
''------------------------------------------------------------------------------------
'' Initialization
''--------------------------------------------------------------------------------------
const as long screenWidth = 800
const as long screenHeight = 450

InitWindow(screenWidth, screenHeight, "raylib [textures] example - textured polygon")

'' Define texture coordinates to map our texture to poly
dim as Vector2 texcoords(MAX_POINTS - 1) = { _
    Vector2(0.75f, 0.0f), _
    Vector2(0.25f, 0.0f), _
    Vector2(0.0f, 0.5f), _
    Vector2(0.0f, 0.75f), _
    Vector2(0.25f, 1.0f), _
    Vector2(0.375f, 0.875f), _
    Vector2(0.625f, 0.875f), _
    Vector2(0.75f, 1.0f), _
    Vector2(1.0f, 0.75f), _
    Vector2(1.0f, 0.5f), _
    Vector2(0.75f, 0.0f) _
}

'' Define the base poly vertices from the UV's
'' NOTE: They can be specified in any other way
dim as Vector2 points(MAX_POINTS - 1)
for i as integer = 0 to MAX_POINTS - 1
    points(i).x = (texcoords(i).x - 0.5f)*256.0f
    points(i).y = (texcoords(i).y - 0.5f)*256.0f
next

'' Define the vertices drawing position
'' NOTE: Initially same as points but updated every frame
dim as Vector2 positions(MAX_POINTS - 1)
for i as integer = 0 to MAX_POINTS - 1
    positions(i) = points(i)
next

'' Load texture to be mapped to poly
dim as Texture tex = LoadTexture("resources/cat.png")

dim as single angle = 0.0f             '' Rotation angle (in degrees)

SetTargetFPS(60)               '' Set our game to run at 60 frames-per-second
''--------------------------------------------------------------------------------------

'' Main game loop
do while not WindowShouldClose()    '' Detect window close button or ESC key
    '' Update
    ''----------------------------------------------------------------------------------
    '' Update points rotation with an angle transform
    '' NOTE: Base points position are not modified
    angle += 1
    for i as integer = 0 to MAX_POINTS - 1
        positions(i) = Vector2Rotate(points(i), angle*DEG2RAD)
    next
    ''----------------------------------------------------------------------------------

    '' Draw
    ''----------------------------------------------------------------------------------
    BeginDrawing()

        ClearBackground(RAYWHITE)

        DrawText("textured polygon", 20, 20, 20, DARKGRAY)

        DrawTexturePoly(tex, Vector2(GetScreenWidth()/2.0f, GetScreenHeight()/2.0f), _
                        positions(), texcoords(), MAX_POINTS, WHITE)

    EndDrawing()
    ''----------------------------------------------------------------------------------
loop

'' De-Initialization
''--------------------------------------------------------------------------------------
UnloadTexture(tex) '' Unload texture

CloseWindow()          '' Close window and OpenGL context
    ''--------------------------------------------------------------------------------------

'' Draw textured polygon, defined by vertex and texture coordinates
'' NOTE: Polygon center must have straight line path to all points
'' without crossing perimeter, points must be in anticlockwise order
sub DrawTexturePoly(tex as Texture2D, center as Vector2, points() as Vector2, texcoords() as Vector2, pointCount as long, tint as RLColor)
    rlSetTexture(tex.id)

    '' Texturing is only supported on RL_QUADS
    rlBegin(RL_QUADS)

        rlColor4ub(tint.r, tint.g, tint.b, tint.a)

        for i as integer = 0 to pointCount - 2
            rlTexCoord2f(0.5f, 0.5f)
            rlVertex2f(center.x, center.y)

            rlTexCoord2f(texcoords(i).x, texcoords(i).y)
            rlVertex2f(points(i).x + center.x, points(i).y + center.y)

            rlTexCoord2f(texcoords(i + 1).x, texcoords(i + 1).y)
            rlVertex2f(points(i + 1).x + center.x, points(i + 1).y + center.y)

            rlTexCoord2f(texcoords(i + 1).x, texcoords(i + 1).y)
            rlVertex2f(points(i + 1).x + center.x, points(i + 1).y + center.y)
        next
    rlEnd()

    rlSetTexture(0)
end sub
