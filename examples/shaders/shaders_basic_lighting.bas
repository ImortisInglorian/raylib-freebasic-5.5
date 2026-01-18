/'******************************************************************************************
*
*   raylib [shaders] example - basic lighting
*
*   NOTE: This example requires raylib OpenGL 3.3 or ES2 versions for shaders support,
*         OpenGL 1.1 does not support shaders, recompile raylib to OpenGL 3.3 version.
*
*   NOTE: Shaders used in this example are #version 330 (OpenGL 3.3).
*
*   Example originally created with raylib 3.0, last time updated with raylib 4.2
*
*   Example contributed by Chris Camacho (@codifies) and reviewed by Ramon Santamaria (@raysan5)
*
*   Example licensed under an unmodified zlib/libpng license, which is an OSI-certified,
*   BSD-like license that allows static linking with closed source software
*
*   Copyright (c) 2019-2024 Chris Camacho (@codifies) and Ramon Santamaria (@raysan5)
*
*******************************************************************************************'/

#include "../../raylib.bi"
#include "../../rlights.bi"

'' Initialization
''--------------------------------------------------------------------------------------
const as long screenWidth = 800
const as long screenHeight = 450

SetConfigFlags(FLAG_MSAA_4X_HINT)  '' Enable Multi Sampling Anti Aliasing 4x (if available)
InitWindow(screenWidth, screenHeight, "raylib [shaders] example - basic lighting")

'' Define the camera to look into our 3d world
dim as Camera cam
with cam
    .position = Vector3(2.0f, 4.0f, 6.0f)    '' Camera position
    .target = Vector3(0.0f, 0.5f, 0.0f)      '' Camera looking at point
    .up = Vector3(0.0f, 1.0f, 0.0f)          '' Camera up vector (rotation towards target)
    .fovy = 45.0f                            '' Camera field-of-view Y
    .projection = CAMERA_PERSPECTIVE         '' Camera projection type
end with 
'' Load basic lighting shader
dim as Shader shade = LoadShader("resources/shaders/glsl330/lighting.vs",_
                                 "resources/shaders/glsl330/lighting.fs")
'' Get some required shader locations
shade.locs[SHADER_LOC_VECTOR_VIEW] = GetShaderLocation(shade, "viewPos")
'' NOTE: "matModel" location name is automatically assigned on shader loading, 
'' no need to get the location again if using that uniform name
''shader.locs[SHADER_LOC_MATRIX_MODEL] = GetShaderLocation(shader, "matModel")

'' Ambient light level (some basic lighting)
dim as long ambientLoc = GetShaderLocation(shade, "ambient")
dim as single ambient(0 to 3) = {0.1f, 0.1f, 0.1f, 1.0f}
'SetShaderValue(shade, ambientLoc, @ambient(0), SHADER_UNIFORM_VEC4)
SetShaderValue(shade, ambientLoc, @Vector4(0.1f, 0.1f, 0.1f, 1.0f), SHADER_UNIFORM_VEC4)

'' Create lights
dim as Light lights(0 to MAX_LIGHTS -1)
lights(0) = CreateLight(LIGHT_POINT, Vector3(-2, 1, -2), Vector3Zero(), YELLOW, shade)
lights(1) = CreateLight(LIGHT_POINT, Vector3(2, 1, 2), Vector3Zero(), RED, shade)
lights(2) = CreateLight(LIGHT_POINT, Vector3(-2, 1, 2), Vector3Zero(), GREEN, shade)
lights(3) = CreateLight(LIGHT_POINT, Vector3(2, 1, -2), Vector3Zero(), BLUE, shade)

SetTargetFPS(60)                   '' Set our game to run at 60 frames-per-second
''--------------------------------------------------------------------------------------

'' Main game loop
do while not WindowShouldClose()        ' Detect window close button or ESC key
    '' Update
    ''----------------------------------------------------------------------------------
    UpdateCamera(@cam, CAMERA_ORBITAL)

    '' Update the shader with the camera view vector (points towards { 0.0f, 0.0f, 0.0f })
    dim as single cameraPos(0 to 2) = { cam.position.x, cam.position.y, cam.position.z }
    SetShaderValue(shade, shade.locs[SHADER_LOC_VECTOR_VIEW], @cameraPos(0), SHADER_UNIFORM_VEC3)
    
    '' Check key inputs to enable/disable lights
    if IsKeyPressed(KEY_Y) then lights(0).enabled = lights(0).enabled xor 1
    if IsKeyPressed(KEY_R) then lights(1).enabled = lights(1).enabled xor 1
    if IsKeyPressed(KEY_G) then lights(2).enabled = lights(2).enabled xor 1
    if IsKeyPressed(KEY_B) then lights(3).enabled = lights(3).enabled xor 1
    
    '' Update light values (actually, only enable/disable them)
    for i as integer = 0 to MAX_LIGHTS-1:UpdateLightValues(shade, lights(i)):next
    ''----------------------------------------------------------------------------------

    '' Draw
    ''----------------------------------------------------------------------------------
    BeginDrawing()

        ClearBackground(RAYWHITE)

        BeginMode3D(cam)

            BeginShaderMode(shade)

                DrawPlane(Vector3Zero(), Vector2(10.0, 10.0), WHITE)
                DrawCube(Vector3Zero(), 2.0, 4.0, 2.0, WHITE)

            EndShaderMode()

            '' Draw spheres to show where the lights are
            for i as integer = 0 to MAX_LIGHTS - 1
                if lights(i).enabled = 1 then 
                    DrawSphereEx(lights(i).position, 0.2f, 8, 8, lights(i).color)
                else 
                    DrawSphereWires(lights(i).position, 0.2f, 8, 8, ColorAlpha(lights(i).color, 0.3f))
                end if
            next

            DrawGrid(10, 1.0f)

        EndMode3D()

        DrawFPS(10, 10)

        DrawText("Use keys [Y][R][G][B] to toggle lights", 10, 40, 20, DARKGRAY)

    EndDrawing()
    ''----------------------------------------------------------------------------------
loop

'' De-Initialization
''--------------------------------------------------------------------------------------
UnloadShader(shade)   '' Unload shader

CloseWindow()          '' Close window and OpenGL context
''--------------------------------------------------------------------------------------