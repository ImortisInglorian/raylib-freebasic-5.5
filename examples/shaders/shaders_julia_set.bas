/'******************************************************************************************
*
*   raylib [shaders] example - Julia sets
*
*   NOTE: This example requires raylib OpenGL 3.3 or ES2 versions for shaders support,
*         OpenGL 1.1 does not support shaders, recompile raylib to OpenGL 3.3 version.
*
*   NOTE: Shaders used in this example are #version 330 (OpenGL 3.3).
*
*   Example originally created with raylib 2.5, last time updated with raylib 4.0
*
*   Example contributed by Josh Colclough (@joshcol9232) and reviewed by Ramon Santamaria (@raysan5)
*
*   Example licensed under an unmodified zlib/libpng license, which is an OSI-certified,
*   BSD-like license that allows static linking with closed source software
*
*   Copyright (c) 2019-2024 Josh Colclough (@joshcol9232) and Ramon Santamaria (@raysan5)
*
*******************************************************************************************'/

#include "../../raylib.bi"

#define GLSL_VERSION            330

'' A few good julia sets
dim as single pointsOfInterest(5, 1) = _
{_
    { -0.348827f, 0.607167f }, _
    { -0.786268f, 0.169728f }, _
    { -0.8f, 0.156f }, _ 
    { 0.285f, 0.0f }, _ 
    { -0.835f, -0.2321f }, _ 
    { -0.70176f, -0.3842f } _ 
}

const as long screenWidth = 800
const as long screenHeight = 450
const as single zoomSpeed = 1.01f
const as single offsetSpeedMul = 2.0f

const as single startingZoom = 0.75f

'' Initialization
''--------------------------------------------------------------------------------------
InitWindow(screenWidth, screenHeight, "raylib [shaders] example - julia sets")

'' Load julia set shader
'' NOTE: Defining 0 (NULL) for vertex shader forces usage of internal default vertex shader
dim as Shader shade = LoadShader(0, TextFormat("resources/shaders/glsl%i/julia_set.fs", GLSL_VERSION))

'' Create a RenderTexture2D to be used for render to texture
dim as RenderTexture2D target = LoadRenderTexture(GetScreenWidth(), GetScreenHeight())

'' c constant to use in z^2 + c
dim as single c(...) = { pointsOfInterest(0,0), pointsOfInterest(0,1) }

'' Offset and zoom to draw the julia set at. (centered on screen and default size)
dim as single offset(...) = { 0.0f, 0.0f }
dim as single zoom = startingZoom

'' Get variable (uniform) locations on the shader to connect with the program
'' NOTE: If uniform variable could not be found in the shader, function returns -1
dim as long cLoc = GetShaderLocation(shade, "c")
dim as long zoomLoc = GetShaderLocation(shade, "zoom")
dim as long offsetLoc = GetShaderLocation(shade, "offset")

'' Upload the shader uniform values!
SetShaderValue(shade, cLoc, @c(0), SHADER_UNIFORM_VEC2)
SetShaderValue(shade, zoomLoc, @zoom, SHADER_UNIFORM_FLOAT)
SetShaderValue(shade, offsetLoc, @offset(0), SHADER_UNIFORM_VEC2)

dim as long incrementSpeed = 0             '' Multiplier of speed to change c value
dim as boolean showControls = true           '' Show controls

SetTargetFPS(60)                   '' Set our game to run at 60 frames-per-second
''--------------------------------------------------------------------------------------

'' Main game loop
do while not WindowShouldClose()        '' Detect window close button or ESC key
    '' Update
    ''----------------------------------------------------------------------------------
    '' Press [1 - 6] to reset c to a point of interest
    if IsKeyPressed(KEY_ONE) or _
        IsKeyPressed(KEY_TWO) or _
        IsKeyPressed(KEY_THREE) or _
        IsKeyPressed(KEY_FOUR) or _
        IsKeyPressed(KEY_FIVE) or _
        IsKeyPressed(KEY_SIX) then
        if IsKeyPressed(KEY_ONE) then
            c(0) = pointsOfInterest(0,0)
            c(1) = pointsOfInterest(0,1)
        elseif IsKeyPressed(KEY_TWO) then
            c(0) = pointsOfInterest(1,0)
            c(1) = pointsOfInterest(1,1)
        elseif IsKeyPressed(KEY_THREE) then
            c(0) = pointsOfInterest(2,0)
            c(1) = pointsOfInterest(2,1)
        elseif IsKeyPressed(KEY_FOUR) then
            c(0) = pointsOfInterest(3,0)
            c(1) = pointsOfInterest(3,1)
        elseif IsKeyPressed(KEY_FIVE) then
            c(0) = pointsOfInterest(4,0)
            c(1) = pointsOfInterest(4,1)
        elseif IsKeyPressed(KEY_SIX) then
            c(0) = pointsOfInterest(5,0)
            c(1) = pointsOfInterest(5,1)
        end if

        SetShaderValue(shade, cLoc, @c(0), SHADER_UNIFORM_VEC2)
    end if

    '' If "R" is pressed, reset zoom and offset.
    if IsKeyPressed(KEY_R) then
        zoom = startingZoom
        offset(0) = 0.0f
        offset(1) = 0.0f
        SetShaderValue(shade, zoomLoc, @zoom, SHADER_UNIFORM_FLOAT)
        SetShaderValue(shade, offsetLoc, @offset(0), SHADER_UNIFORM_VEC2)
    end if

    if IsKeyPressed(KEY_SPACE) then incrementSpeed = 0         '' Pause animation (c change)
    if IsKeyPressed(KEY_F1) then showControls =  not showControls  '' Toggle whether or not to show controls

    if IsKeyPressed(KEY_RIGHT) then
        incrementSpeed += 1
    elseif IsKeyPressed(KEY_LEFT) then 
        incrementSpeed -= 1
    end if

    '' If either left or right button is pressed, zoom in/out.
    if IsMouseButtonDown(MOUSE_BUTTON_LEFT) or IsMouseButtonDown(MOUSE_BUTTON_RIGHT) then
        '' Change zoom. If Mouse left -> zoom in. Mouse right -> zoom out.
        zoom *= iif(IsMouseButtonDown(MOUSE_BUTTON_LEFT), zoomSpeed, 1.0f/zoomSpeed)

        dim as Vector2 mousePos = GetMousePosition()
        dim as Vector2 offsetVelocity
        '' Find the velocity at which to change the camera. Take the distance of the mouse
        '' from the center of the screen as the direction, and adjust magnitude based on
        '' the current zoom.
        offsetVelocity.x = (mousePos.x/screenWidth - 0.5f)*offsetSpeedMul/zoom
        offsetVelocity.y = (mousePos.y/screenHeight - 0.5f)*offsetSpeedMul/zoom

        '' Apply move velocity to camera
        offset(0) += GetFrameTime()*offsetVelocity.x
        offset(1) += GetFrameTime()*offsetVelocity.y

        '' Update the shader uniform values!
        SetShaderValue(shade, zoomLoc, @zoom, SHADER_UNIFORM_FLOAT)
        SetShaderValue(shade, offsetLoc, @offset(0), SHADER_UNIFORM_VEC2)
    end if

    '' Increment c value with time
    dim as single dc = GetFrameTime()*incrementSpeed*0.0005f
    c(0) += dc
    c(1) += dc
    SetShaderValue(shade, cLoc, @c(0), SHADER_UNIFORM_VEC2)
    ''----------------------------------------------------------------------------------

    '' Draw
    ''----------------------------------------------------------------------------------
    '' Using a render texture to draw Julia set
    BeginTextureMode(target)       '' Enable drawing to texture
        ClearBackground(BLACK)     '' Clear the render texture

        '' Draw a rectangle in shader mode to be used as shader canvas
        '' NOTE: Rectangle uses font white character texture coordinates,
        '' so shader can not be applied here directly because input vertexTexCoord
        '' do not represent full screen coordinates (space where want to apply shader)
        DrawRectangle(0, 0, GetScreenWidth(), GetScreenHeight(), BLACK)
    EndTextureMode()
        
    BeginDrawing()
        ClearBackground(BLACK)     '' Clear screen background

        '' Draw the saved texture and rendered julia set with shader
        '' NOTE: We do not invert texture on Y, already considered inside shader
        BeginShaderMode(shade)
            '' WARNING: If FLAG_WINDOW_HIGHDPI is enabled, HighDPI monitor scaling should be considered
            '' when rendering the RenderTexture2D to fit in the HighDPI scaled Window
            DrawTextureEx(target.texture, Vector2(0.0f, 0.0f), 0.0f, 1.0f, WHITE)
        EndShaderMode()

        if showControls then
            DrawText("Press Mouse buttons right/left to zoom in/out and move", 10, 15, 10, RAYWHITE)
            DrawText("Press KEY_F1 to toggle these controls", 10, 30, 10, RAYWHITE)
            DrawText("Press KEYS [1 - 6] to change point of interest", 10, 45, 10, RAYWHITE)
            DrawText("Press KEY_LEFT | KEY_RIGHT to change speed", 10, 60, 10, RAYWHITE)
            DrawText("Press KEY_SPACE to stop movement animation", 10, 75, 10, RAYWHITE)
            DrawText("Press KEY_R to recenter the camera", 10, 90, 10, RAYWHITE)
        end if
    EndDrawing()
    ''----------------------------------------------------------------------------------
loop

'' De-Initialization
''--------------------------------------------------------------------------------------
UnloadShader(shade)               '' Unload shader
UnloadRenderTexture(target)        '' Unload render texture

CloseWindow()                      '' Close window and OpenGL context
''--------------------------------------------------------------------------------------