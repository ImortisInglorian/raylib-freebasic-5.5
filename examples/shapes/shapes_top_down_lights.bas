/'******************************************************************************************
*
*   raylib [shapes] example - top down lights
*
*   Example originally created with raylib 4.2, last time updated with raylib 4.2
*
*   Example contributed by Vlad Adrian (@demizdor) and reviewed by Ramon Santamaria (@raysan5)
*
*   Example licensed under an unmodified zlib/libpng license, which is an OSI-certified,
*   BSD-like license that allows static linking with closed source software
*
*   Copyright (c) 2022-2024 Jeffery Myers (@JeffM2501)
*
*******************************************************************************************'/

#include "../../raylib.bi"
#include "../../rlgl.bi"

'' Custom Blend Modes
#define RLGL_SRC_ALPHA &h0302
#define RLGL_MIN &h8007
#define RLGL_MAX &h8008

#define MAX_BOXES     20
#define MAX_SHADOWS   MAX_BOXES * 3         '' MAX_BOXES *3. Each box can cast up to two shadow volumes for the edges it is away from, and one for the box itself
#define MAX_LIGHTS    16

'' Shadow geometry type
type ShadowGeometry
    as Vector2 vertices(3)
end type

'' Light info type
type LightInfo
    as boolean active                '' Is this light slot active?
    as boolean dirty                 '' Does this light need to be updated?
    as boolean valid                 '' Is this light in a valid position?

    as Vector2 position           '' Light position
    as RenderTexture mask         '' Alpha mask for the light
    as single outerRadius          '' The distance the light touches
    as Rectangle bounds           '' A cached rectangle of the light bounds to help with culling

    as ShadowGeometry shadows(MAX_SHADOWS - 1)
    as long shadowCount
end type


dim shared as LightInfo lights(MAX_LIGHTS - 1)

'' Move a light and mark it as dirty so that we update it's mask next frame
sub MoveLight(slot as single, x as single, y as single)
    lights(slot).dirty = true
    lights(slot).position.x = x 
    lights(slot).position.y = y

    '' update the cached bounds
    lights(slot).bounds.x = x - lights(slot).outerRadius
    lights(slot).bounds.y = y - lights(slot).outerRadius
end sub

'' Compute a shadow volume for the edge
'' It takes the edge and projects it back by the light radius and turns it into a quad
sub ComputeShadowVolumeForEdge(slot as long, sp as Vector2, ep as Vector2)
    if lights(slot).shadowCount >= MAX_SHADOWS then return

    dim as single extension = lights(slot).outerRadius * 2

    dim as Vector2 spVector = Vector2Normalize(Vector2Subtract(sp, lights(slot).position))
    dim as Vector2 spProjection = Vector2Add(sp, Vector2Scale(spVector, extension))

    dim as Vector2 epVector = Vector2Normalize(Vector2Subtract(ep, lights(slot).position))
    dim as Vector2 epProjection = Vector2Add(ep, Vector2Scale(epVector, extension))

    lights(slot).shadows(lights(slot).shadowCount).vertices(0) = sp
    lights(slot).shadows(lights(slot).shadowCount).vertices(1) = ep
    lights(slot).shadows(lights(slot).shadowCount).vertices(2) = epProjection
    lights(slot).shadows(lights(slot).shadowCount).vertices(3) = spProjection

    lights(slot).shadowCount += 1
end sub

'' Draw the light and shadows to the mask for a light
sub DrawLightMask(slot as long)
    '' Use the light mask
    BeginTextureMode(lights(slot).mask)

        ClearBackground(WHITE)

        '' Force the blend mode to only set the alpha of the destination
        rlSetBlendFactors(RLGL_SRC_ALPHA, RLGL_SRC_ALPHA, RLGL_MIN)
        rlSetBlendMode(BLEND_CUSTOM)

        '' If we are valid, then draw the light radius to the alpha mask
        if (lights(slot).valid) then DrawCircleGradient(lights(slot).position.x, lights(slot).position.y, lights(slot).outerRadius, ColorAlpha(WHITE, 0), WHITE)
        
        rlDrawRenderBatchActive()

        '' Cut out the shadows from the light radius by forcing the alpha to maximum
        rlSetBlendMode(BLEND_ALPHA)
        rlSetBlendFactors(RLGL_SRC_ALPHA, RLGL_SRC_ALPHA, RLGL_MAX)
        rlSetBlendMode(BLEND_CUSTOM)

        '' Draw the shadows to the alpha mask
        for i as integer = 0 to lights(slot).shadowCount - 1
            DrawTriangleFan(@lights(slot).shadows(i).vertices(0), 4, WHITE)
        next

        rlDrawRenderBatchActive()
        
        '' Go back to normal blend mode
        rlSetBlendMode(BLEND_ALPHA)

    EndTextureMode()
end sub

'' Setup a light
sub SetupLight(slot as long, x as single, y as single, radius as single)
    lights(slot).active = true
    lights(slot).valid = false  '' The light must prove it is valid
    lights(slot).mask = LoadRenderTexture(GetScreenWidth(), GetScreenHeight())
    lights(slot).outerRadius = radius

    lights(slot).bounds.width = radius * 2
    lights(slot).bounds.height = radius * 2

    MoveLight(slot, x, y)

    '' Force the render texture to have something in it
    DrawLightMask(slot)
end sub

'' See if a light needs to update it's mask
function UpdateLight(slot as long, boxes() as Rectangle, count as long) as boolean
    if not lights(slot).active or not lights(slot).dirty then return false

    lights(slot).dirty = false
    lights(slot).shadowCount = 0
    lights(slot).valid = false

    for i as integer = 0 to count - 1
        '' Are we in a box? if so we are not valid
        if CheckCollisionPointRec(lights(slot).position, boxes(i)) then return false

        '' If this box is outside our bounds, we can skip it
        if not CheckCollisionRecs(lights(slot).bounds, boxes(i)) then continue for

        '' Check the edges that are on the same side we are, and cast shadow volumes out from them
        
        '' Top
        dim as Vector2 sp = Vector2(boxes(i).x, boxes(i).y)
        dim as Vector2 ep = Vector2(boxes(i).x + boxes(i).width, boxes(i).y)

        if lights(slot).position.y > ep.y then ComputeShadowVolumeForEdge(slot, sp, ep)

        '' Right
        sp = ep
        ep.y += boxes(i).height
        if lights(slot).position.x < ep.x then ComputeShadowVolumeForEdge(slot, sp, ep)

        '' Bottom
        sp = ep
        ep.x -= boxes(i).width
        if lights(slot).position.y < ep.y then ComputeShadowVolumeForEdge(slot, sp, ep)

        '' Left
        sp = ep
        ep.y -= boxes(i).height
        if lights(slot).position.x > ep.x then ComputeShadowVolumeForEdge(slot, sp, ep)

        '' The box itself
        lights(slot).shadows(lights(slot).shadowCount).vertices(0) = Vector2(boxes(i).x, boxes(i).y)
        lights(slot).shadows(lights(slot).shadowCount).vertices(1) = Vector2(boxes(i).x, boxes(i).y + boxes(i).height)
        lights(slot).shadows(lights(slot).shadowCount).vertices(2) = Vector2(boxes(i).x + boxes(i).width, boxes(i).y + boxes(i).height)
        lights(slot).shadows(lights(slot).shadowCount).vertices(3) = Vector2(boxes(i).x + boxes(i).width, boxes(i).y)
        lights(slot).shadowCount += 1
    next

    lights(slot).valid = true

    DrawLightMask(slot)

    return true
end function

'' Set up some boxes
sub SetupBoxes(boxes() as Rectangle, count as long ptr)
    boxes(0) = Rectangle(150,80, 40, 40)
    boxes(1) = Rectangle(1200, 700, 40, 40)
    boxes(2) = Rectangle(200, 600, 40, 40)
    boxes(3) = Rectangle(1000, 50, 40, 40)
    boxes(4) = Rectangle(500, 350, 40, 40)

    for i as integer = 5 to MAX_BOXES - 1
        boxes(i) = Rectangle(GetRandomValue(0,GetScreenWidth()), GetRandomValue(0,GetScreenHeight()), GetRandomValue(10,100), GetRandomValue(10,100))
    next

    *count = MAX_BOXES
end sub

''------------------------------------------------------------------------------------
'' Program main entry point
''------------------------------------------------------------------------------------
'' Initialization
''--------------------------------------------------------------------------------------
const as long screenWidth = 800
const as long screenHeight = 450

InitWindow(screenWidth, screenHeight, "raylib [shapes] example - top down lights")

'' Initialize our 'world' of boxes
dim as long boxCount = 0
dim as Rectangle boxes(MAX_BOXES - 1)
SetupBoxes(boxes(), @boxCount)

'' Create a checkerboard ground texture
dim as Image img = GenImageChecked(64, 64, 32, 32, DARKBROWN, DARKGRAY)
dim as Texture2D backgroundTexture = LoadTextureFromImage(img)
UnloadImage(img)

'' Create a global light mask to hold all the blended lights
dim as RenderTexture lightMask = LoadRenderTexture(GetScreenWidth(), GetScreenHeight())

'' Setup initial light
SetupLight(0, 600, 400, 300)
dim as long nextLight = 1

dim as boolean showLines = false

SetTargetFPS(60)               '' Set our game to run at 60 frames-per-second
''--------------------------------------------------------------------------------------

'' Main game loop
do while not WindowShouldClose()    '' Detect window close button or ESC key
    '' Update
    ''----------------------------------------------------------------------------------
    '' Drag light 0
    if IsMouseButtonDown(MOUSE_BUTTON_LEFT) then MoveLight(0, GetMousePosition().x, GetMousePosition().y)

    '' Make a new light
    if IsMouseButtonPressed(MOUSE_BUTTON_RIGHT) and (nextLight < MAX_LIGHTS) then
        SetupLight(nextLight, GetMousePosition().x, GetMousePosition().y, 200)
        nextLight += 1
    end if

    '' Toggle debug info
    if IsKeyPressed(KEY_F1) then showLines = not showLines

    '' Update the lights and keep track if any were dirty so we know if we need to update the master light mask
    dim as boolean dirtyLights = false
    for i as integer = 0 to MAX_LIGHTS - 1
        if UpdateLight(i, boxes(), boxCount) then dirtyLights = true
    next

    '' Update the light mask
    if dirtyLights then
        '' Build up the light mask
        BeginTextureMode(lightMask)
        
            ClearBackground(BLACK)

            '' Force the blend mode to only set the alpha of the destination
            rlSetBlendFactors(RLGL_SRC_ALPHA, RLGL_SRC_ALPHA, RLGL_MIN)
            rlSetBlendMode(BLEND_CUSTOM)

            '' Merge in all the light masks
            for i as integer = 0 to MAX_LIGHTS - 1
                if lights(i).active then DrawTextureRec(lights(i).mask.texture, Rectangle(0, 0, GetScreenWidth(), -GetScreenHeight()), Vector2Zero(), WHITE)
            next

            rlDrawRenderBatchActive()

            '' Go back to normal blend
            rlSetBlendMode(BLEND_ALPHA)
        EndTextureMode()
    end if
    ''----------------------------------------------------------------------------------

    '' Draw
    ''----------------------------------------------------------------------------------
    BeginDrawing()

        ClearBackground(BLACK)
        
        '' Draw the tile background
        DrawTextureRec(backgroundTexture, Rectangle(0, 0, GetScreenWidth(), GetScreenHeight()), Vector2Zero(), WHITE)
        
        '' Overlay the shadows from all the lights
        DrawTextureRec(lightMask.texture, Rectangle(0, 0, GetScreenWidth(), -GetScreenHeight()), Vector2Zero(), ColorAlpha(WHITE, iif(showLines, 0.75f, 1.0f)))

        '' Draw the lights
        for i as integer = 0 to MAX_LIGHTS - 1
            if lights(i).active then DrawCircle(lights(i).position.x, lights(i).position.y, 10, iif(i = 0, YELLOW, WHITE))
        next

        if showLines then
            for s as integer = 0 to lights(0).shadowCount - 1
                DrawTriangleFan(@lights(0).shadows(s).vertices(0), 4, DARKPURPLE)
            next

            for b as integer = 0 to boxCount - 1
                if CheckCollisionRecs(boxes(b),lights(0).bounds) then DrawRectangleRec(boxes(b), PURPLE)

                DrawRectangleLines(boxes(b).x, boxes(b).y, boxes(b).width, boxes(b).height, DARKBLUE)
            next

            DrawText("(F1) Hide Shadow Volumes", 10, 50, 10, GREEN)
        else
            DrawText("(F1) Show Shadow Volumes", 10, 50, 10, GREEN)
        end if

        DrawFPS(screenWidth - 80, 10)
        DrawText("Drag to move light #1", 10, 10, 10, DARKGREEN)
        DrawText("Right click to add new light", 10, 30, 10, DARKGREEN)

    EndDrawing()
    ''----------------------------------------------------------------------------------
loop

'' De-Initialization
''--------------------------------------------------------------------------------------
UnloadTexture(backgroundTexture)
UnloadRenderTexture(lightMask)
for i as integer = 0 to MAX_LIGHTS - 1
    if lights(i).active then UnloadRenderTexture(lights(i).mask)
next

CloseWindow()        '' Close window and OpenGL context
''--------------------------------------------------------------------------------------