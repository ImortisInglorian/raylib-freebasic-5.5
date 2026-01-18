/'******************************************************************************************
*
*   raylib [models] example - rlgl module usage with push/pop matrix transformations
*
*   NOTE: This example uses [rlgl] module functionality (pseudo-OpenGL 1.1 style coding)
*
*   Example originally created with raylib 2.5, last time updated with raylib 4.0
*
*   Example licensed under an unmodified zlib/libpng license, which is an OSI-certified,
*   BSD-like license that allows static linking with closed source software
*
*   Copyright (c) 2018-2024 Ramon Santamaria (@raysan5)
*
*******************************************************************************************'/

#include "../../raylib.bi"
#include "../../rlgl.bi"


''------------------------------------------------------------------------------------
'' Module Functions Declaration
''------------------------------------------------------------------------------------
declare sub DrawSphereBasic(clr as RLColor)      '' Draw sphere without any matrix transformation

''------------------------------------------------------------------------------------
'' Program main entry point
''------------------------------------------------------------------------------------
'' Initialization
''--------------------------------------------------------------------------------------
const as long screenWidth = 800
const as long screenHeight = 450

const as single sunRadius = 4.0f
const as single earthRadius = 0.6f
const as single earthOrbitRadius = 8.0f
const as single moonRadius = 0.16f
const as single moonOrbitRadius = 1.5f

InitWindow(screenWidth, screenHeight, "raylib [models] example - rlgl module usage with push/pop matrix transformations")

'' Define the camera to look into our 3d world
dim as Camera cam
with cam
    .position = Vector3(16.0f, 16.0f, 16.0f) '' Camera position
    .target = Vector3(0.0f, 0.0f, 0.0f)      '' Camera looking at point
    .up = Vector3(0.0f, 1.0f, 0.0f)          '' Camera up vector (rotation towards target)
    .fovy = 45.0f                            '' Camera field-of-view Y
    .projection = CAMERA_PERSPECTIVE         '' Camera projection type
end with

dim as single rotationSpeed = 0.2f         '' General system rotation speed

dim as single earthRotation = 0.0f         '' Rotation of earth around itself (days) in degrees
dim as single earthOrbitRotation = 0.0f    '' Rotation of earth around the Sun (years) in degrees
dim as single moonRotation = 0.0f          '' Rotation of moon around itself
dim as single moonOrbitRotation = 0.0f     '' Rotation of moon around earth in degrees

SetTargetFPS(60)                   '' Set our game to run at 60 frames-per-second
''--------------------------------------------------------------------------------------

'' Main game loop
do while not WindowShouldClose()        '' Detect window close button or ESC key
    '' Update
    ''----------------------------------------------------------------------------------
    UpdateCamera(@cam, CAMERA_ORBITAL)

    earthRotation += (5.0f * rotationSpeed)
    earthOrbitRotation += (365 / 360.0f * (5.0f * rotationSpeed) * rotationSpeed)
    moonRotation += (2.0f * rotationSpeed)
    moonOrbitRotation += (8.0f * rotationSpeed)
    ''----------------------------------------------------------------------------------

    '' Draw
    ''----------------------------------------------------------------------------------
    BeginDrawing()

        ClearBackground(RAYWHITE)

        BeginMode3D(cam)

            rlPushMatrix()
                rlScalef(sunRadius, sunRadius, sunRadius)          '' Scale Sun
                DrawSphereBasic(GOLD)                              '' Draw the Sun
            rlPopMatrix()

            rlPushMatrix()
                rlRotatef(earthOrbitRotation, 0.0f, 1.0f, 0.0f)    '' Rotation for Earth orbit around Sun
                rlTranslatef(earthOrbitRadius, 0.0f, 0.0f)         '' Translation for Earth orbit

                rlPushMatrix()
                    rlRotatef(earthRotation, 0.25, 1.0, 0.0)       '' Rotation for Earth itself
                    rlScalef(earthRadius, earthRadius, earthRadius)'' Scale Earth

                    DrawSphereBasic(BLUE)                          '' Draw the Earth
                rlPopMatrix()

                rlRotatef(moonOrbitRotation, 0.0f, 1.0f, 0.0f)     '' Rotation for Moon orbit around Earth
                rlTranslatef(moonOrbitRadius, 0.0f, 0.0f)          '' Translation for Moon orbit
                rlRotatef(moonRotation, 0.0f, 1.0f, 0.0f)          '' Rotation for Moon itself
                rlScalef(moonRadius, moonRadius, moonRadius)       '' Scale Moon

                DrawSphereBasic(LIGHTGRAY)                         '' Draw the Moon
            rlPopMatrix()

            '' Some reference elements (not affected by previous matrix transformations)
            DrawCircle3D(Vector3(0.0f, 0.0f, 0.0f), earthOrbitRadius, Vector3(1, 0, 0), 90.0f, Fade(RED, 0.5f))
            DrawGrid(20, 1.0f)

        EndMode3D()

        DrawText("EARTH ORBITING AROUND THE SUN!", 400, 10, 20, MAROON)
        DrawFPS(10, 10)

    EndDrawing()
    ''----------------------------------------------------------------------------------
loop

'' De-Initialization
''--------------------------------------------------------------------------------------
CloseWindow()        '' Close window and OpenGL context
''--------------------------------------------------------------------------------------

''--------------------------------------------------------------------------------------------
'' Module Functions Definitions (local)
''--------------------------------------------------------------------------------------------

'' Draw sphere without any matrix transformation
'' NOTE: Sphere is drawn in world position ( 0, 0, 0 ) with radius 1.0f
sub DrawSphereBasic(clr as RLColor)
    dim as long rings = 16
    dim as long slices = 16

    '' Make sure there is enough space in the internal render batch
    '' buffer to store all required vertex, batch is reseted if required
    rlCheckRenderBatchLimit((rings + 2) * slices * 6)

    rlBegin(RL_TRIANGLES)
        rlColor4ub(clr.r, clr.g, clr.b, clr.a)

        for i as integer = 0 to (rings + 1)
            for j as integer = 0 to slices - 1
                rlVertex3f(cos(DEG2RAD*(270+(180/(rings + 1))*i))*sin(DEG2RAD*(j*360/slices)),_
                           sin(DEG2RAD*(270+(180/(rings + 1))*i)),_
                           cos(DEG2RAD*(270+(180/(rings + 1))*i))*cos(DEG2RAD*(j*360/slices)))
                rlVertex3f(cos(DEG2RAD*(270+(180/(rings + 1))*(i+1)))*sin(DEG2RAD*((j+1)*360/slices)),_
                           sin(DEG2RAD*(270+(180/(rings + 1))*(i+1))),_
                           cos(DEG2RAD*(270+(180/(rings + 1))*(i+1)))*cos(DEG2RAD*((j+1)*360/slices)))
                rlVertex3f(cos(DEG2RAD*(270+(180/(rings + 1))*(i+1)))*sin(DEG2RAD*(j*360/slices)),_
                           sin(DEG2RAD*(270+(180/(rings + 1))*(i+1))),_
                           cos(DEG2RAD*(270+(180/(rings + 1))*(i+1)))*cos(DEG2RAD*(j*360/slices)))

                rlVertex3f(cos(DEG2RAD*(270+(180/(rings + 1))*i))*sin(DEG2RAD*(j*360/slices)),_
                           sin(DEG2RAD*(270+(180/(rings + 1))*i)),_
                           cos(DEG2RAD*(270+(180/(rings + 1))*i))*cos(DEG2RAD*(j*360/slices)))
                rlVertex3f(cos(DEG2RAD*(270+(180/(rings + 1))*(i)))*sin(DEG2RAD*((j+1)*360/slices)),_
                           sin(DEG2RAD*(270+(180/(rings + 1))*(i))),_
                           cos(DEG2RAD*(270+(180/(rings + 1))*(i)))*cos(DEG2RAD*((j+1)*360/slices)))
                rlVertex3f(cos(DEG2RAD*(270+(180/(rings + 1))*(i+1)))*sin(DEG2RAD*((j+1)*360/slices)),_
                           sin(DEG2RAD*(270+(180/(rings + 1))*(i+1))),_
                           cos(DEG2RAD*(270+(180/(rings + 1))*(i+1)))*cos(DEG2RAD*((j+1)*360/slices)))
            next
        next
    rlEnd()
end sub