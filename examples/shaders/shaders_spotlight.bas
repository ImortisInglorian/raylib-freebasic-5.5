/'******************************************************************************************
*
*   raylib [shaders] example - Simple shader mask
*
*   Example originally created with raylib 2.5, last time updated with raylib 3.7
*
*   Example contributed by Chris Camacho (@chriscamacho) and reviewed by Ramon Santamaria (@raysan5)
*
*   Example licensed under an unmodified zlib/libpng license, which is an OSI-certified,
*   BSD-like license that allows static linking with closed source software
*
*   Copyright (c) 2019-2024 Chris Camacho (@chriscamacho) and Ramon Santamaria (@raysan5)
*
********************************************************************************************
*
*   The shader makes alpha holes in the forground to give the appearance of a top
*   down look at a spotlight casting a pool of light...
*
*   The right hand side of the screen there is just enough light to see whats
*   going on without the spot light, great for a stealth type game where you
*   have to avoid the spotlights.
*
*   The left hand side of the screen is in pitch dark except for where the spotlights are.
*
*   Although this example doesn't scale like the letterbox example, you could integrate
*   the two techniques, but by scaling the actual colour of the render texture rather
*   than using alpha as a mask.
*
*******************************************************************************************'/

#include "../../raylib.bi"

#define GLSL_VERSION            330

#define MAX_SPOTS         3        '' NOTE: It must be the same as define in shader
#define MAX_STARS       400

'' Spot data
type Spot
    as Vector2 position
    as Vector2 speed
    as single inner
    as single radius

    '' Shader locations
    as ulong positionLoc
    as ulong innerLoc
    as ulong radiusLoc
end type

'' Stars in the star field have a position and velocity
type Star
    as Vector2 position
    as Vector2 speed
end type

declare sub UpdateStar(s as Star ptr)
declare sub ResetStar(s as Star ptr)

'' Initialization
''--------------------------------------------------------------------------------------
const as long screenWidth = 800
const as long screenHeight = 450

InitWindow(screenWidth, screenHeight, "raylib [shaders] example - shader spotlight")
HideCursor()

dim as Texture texRay = LoadTexture("resources/raysan.png")

dim as Star stars(MAX_STARS - 1)

for n as integer = 0 to MAX_STARS - 1 
    ResetStar(@stars(0))
next

'' Progress all the stars on, so they don't all start in the centre
for m as integer = 0 to (screenWidth/2.0) - 1
    for n as integer = 0 to MAX_STARS - 1 
        UpdateStar(@stars(n))
    next
next

dim as long frameCounter = 0

'' Use default vert shader
dim as Shader shdrSpot = LoadShader(0, TextFormat("resources/shaders/glsl%i/spotlight.fs", GLSL_VERSION))

'' Get the locations of spots in the shader
dim as Spot spots(MAX_SPOTS - 1)

for i as integer = 0 to MAX_SPOTS - 1
    dim as zstring * 32 posName = !"spots[x].pos\0"
    dim as zstring * 32 innerName = !"spots[x].inner\0"
    dim as zstring * 32 radiusName = !"spots[x].radius\0"

    posName[6] = i
    innerName[6] = i
    radiusName[6] = i

    spots(i).positionLoc = GetShaderLocation(shdrSpot, posName)
    spots(i).innerLoc = GetShaderLocation(shdrSpot, innerName)
    spots(i).radiusLoc = GetShaderLocation(shdrSpot, radiusName)
next

'' Tell the shader how wide the screen is so we can have
'' a pitch black half and a dimly lit half.
dim as ulong wLoc = GetShaderLocation(shdrSpot, "screenWidth")
dim as single sw = GetScreenWidth()
SetShaderValue(shdrSpot, wLoc, @sw, SHADER_UNIFORM_FLOAT)

'' Randomize the locations and velocities of the spotlights
'' and initialize the shader locations
for i as integer = 0 to MAX_SPOTS - 1
    spots(i).position.x = GetRandomValue(64, screenWidth - 64)
    spots(i).position.y = GetRandomValue(64, screenHeight - 64)
    spots(i).speed = Vector2(0, 0)

    do while (abs(spots(i).speed.x) + abs(spots(i).speed.y)) < 2
        spots(i).speed.x = GetRandomValue(-400, 40) / 10.0f
        spots(i).speed.y = GetRandomValue(-400, 40) / 10.0f
    loop

    spots(i).inner = 28.0f * (i + 1)
    spots(i).radius = 48.0f * (i + 1)

    SetShaderValue(shdrSpot, spots(i).positionLoc, @spots(i).position.x, SHADER_UNIFORM_VEC2)
    SetShaderValue(shdrSpot, spots(i).innerLoc, @spots(i).inner, SHADER_UNIFORM_FLOAT)
    SetShaderValue(shdrSpot, spots(i).radiusLoc, @spots(i).radius, SHADER_UNIFORM_FLOAT)
next

SetTargetFPS(60)               '' Set  to run at 60 frames-per-second
''--------------------------------------------------------------------------------------

'' Main game loop
do while not WindowShouldClose()    '' Detect window close button or ESC key
    '' Update
    ''----------------------------------------------------------------------------------
    frameCounter += 1

    '' Move the stars, resetting them if the go offscreen
    for n as integer = 0 to MAX_STARS - 1
        UpdateStar(@stars(0))
    next

    '' Update the spots, send them to the shader
    for i as integer = 0 to MAX_SPOTS - 1
        if i = 0 then
            dim as Vector2 mp = GetMousePosition()
            spots(i).position.x = mp.x
            spots(i).position.y = screenHeight - mp.y
        else
            spots(i).position.x += spots(i).speed.x
            spots(i).position.y += spots(i).speed.y

            if spots(i).position.x < 64 then spots(i).speed.x = -spots(i).speed.x
            if spots(i).position.x > (screenWidth - 64) then spots(i).speed.x = -spots(i).speed.x
            if spots(i).position.y < 64 then spots(i).speed.y = -spots(i).speed.y
            if spots(i).position.y > (screenHeight - 64) then spots(i).speed.y = -spots(i).speed.y
        end if

        SetShaderValue(shdrSpot, spots(i).positionLoc, @spots(i).position.x, SHADER_UNIFORM_VEC2)
    next

    '' Draw
    ''----------------------------------------------------------------------------------
    BeginDrawing()

        ClearBackground(DARKBLUE)

        '' Draw stars and bobs
        for n as integer = 0 to MAX_STARS - 1
            '' Single pixel is just too small these days!
            DrawRectangle(stars(n).position.x, stars(n).position.y, 2, 2, WHITE)
        next

        for i as integer = 0 to 15
            DrawTexture(texRay, _
                (screenWidth/2.0f) + cos((frameCounter + i*8)/51.45f)*(screenWidth/2.2f) - 32, _
                (screenHeight/2.0f) + sin((frameCounter + i*8)/17.87f)*(screenHeight/4.2f), WHITE)
        next

        '' Draw spot lights
        BeginShaderMode(shdrSpot)
            '' Instead of a blank rectangle you could render here
            '' a render texture of the full screen used to do screen
            '' scaling (slight adjustment to shader would be required
            '' to actually pay attention to the colour!)
            DrawRectangle(0, 0, screenWidth, screenHeight, WHITE)
        EndShaderMode()

        DrawFPS(10, 10)

        DrawText("Move the mouse!", 10, 30, 20, GREEN)
        DrawText("Pitch Black", screenWidth*0.2f, screenHeight/2, 20, GREEN)
        DrawText("Dark", screenWidth*.66f, screenHeight/2, 20, GREEN)

    EndDrawing()
    ''----------------------------------------------------------------------------------
loop

'' De-Initialization
''--------------------------------------------------------------------------------------
UnloadTexture(texRay)
UnloadShader(shdrSpot)

CloseWindow()        '' Close window and OpenGL context
''--------------------------------------------------------------------------------------

sub ResetStar(s as Star ptr)
    s->position = Vector2(GetScreenWidth()/2.0f, GetScreenHeight()/2.0f)

    do
        s->speed.x = GetRandomValue(-1000, 1000)/100.0f
        s->speed.y = GetRandomValue(-1000, 1000)/100.0f

    loop while  not (abs(s->speed.x) + (abs(s->speed.y) > 1))

    s->position = Vector2Add(s->position, Vector2Multiply(s->speed, Vector2(8.0f, 8.0f)))
end sub

sub UpdateStar(s as Star ptr)
    s->position = Vector2Add(s->position, s->speed)

    if (s->position.x < 0) or (s->position.x > GetScreenWidth()) or _
        (s->position.y < 0) or (s->position.y > GetScreenHeight()) then
        ResetStar(s)
    end if
end sub