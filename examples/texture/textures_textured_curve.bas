/'******************************************************************************************
*
*   raylib [textures] example - Draw a texture along a segmented curve
*
*   Example originally created with raylib 4.5, last time updated with raylib 4.5
*
*   Example contributed by Jeffery Myers and reviewed by Ramon Santamaria (@raysan5)
*
*   Example licensed under an unmodified zlib/libpng license, which is an OSI-certified,
*   BSD-like license that allows static linking with closed source software
*
*   Copyright (c) 2022-2024 Jeffery Myers and Ramon Santamaria (@raysan5)
*
*******************************************************************************************'/

#include "../../raylib.bi"
#include "../../rlgl.bi"

''----------------------------------------------------------------------------------
'' Global Variables Definition
''----------------------------------------------------------------------------------
dim shared as Texture texRoad

dim shared as boolean showCurve = false

dim shared as single curveWidth = 50
dim shared as long curveSegments = 24

dim shared as Vector2 curveStartPosition
dim shared as Vector2 curveStartPositionTangent

dim shared as Vector2 curveEndPosition
dim shared as Vector2 curveEndPositionTangent

dim shared as Vector2 ptr curveSelectedPoint

''----------------------------------------------------------------------------------
'' Module Functions Declaration
''----------------------------------------------------------------------------------
declare sub DrawTexturedCurve()

''------------------------------------------------------------------------------------
'' Program main entry point
''------------------------------------------------------------------------------------
'' Initialization
''--------------------------------------------------------------------------------------
const as long screenWidth = 800
const as long screenHeight = 450

SetConfigFlags(FLAG_VSYNC_HINT or FLAG_MSAA_4X_HINT)
InitWindow(screenWidth, screenHeight, "raylib [textures] examples - textured curve")

'' Load the road texture
texRoad = LoadTexture("resources/road.png")
SetTextureFilter(texRoad, TEXTURE_FILTER_BILINEAR)

'' Setup the curve
curveStartPosition = Vector2(80, 100)
curveStartPositionTangent = Vector2(100, 300)

curveEndPosition = Vector2(700, 350)
curveEndPositionTangent = Vector2(600, 100)

SetTargetFPS(60)               '' Set our game to run at 60 frames-per-second
''--------------------------------------------------------------------------------------

'' Main game loop
do while not WindowShouldClose()    '' Detect window close button or ESC key
    '' Update
    ''----------------------------------------------------------------------------------
    '' Curve config options
    if IsKeyPressed(KEY_SPACE) then showCurve = not showCurve
    if IsKeyPressed(KEY_EQUAL) then curveWidth += 2
    if IsKeyPressed(KEY_MINUS) then curveWidth -= 2
    if curveWidth < 2 then curveWidth = 2

    '' Update segments
    if IsKeyPressed(KEY_LEFT) then curveSegments -= 2
    if IsKeyPressed(KEY_RIGHT) then curveSegments += 2

    if curveSegments < 2 then curveSegments = 2

    '' Update curve logic
    '' If the mouse is not down, we are not editing the curve so clear the selection
    if not IsMouseButtonDown(MOUSE_LEFT_BUTTON) then  curveSelectedPoint = 0

    '' If a point was selected, move it
    if curveSelectedPoint <> 0 then *curveSelectedPoint = Vector2Add(*curveSelectedPoint, GetMouseDelta())

    '' The mouse is down, and nothing was selected, so see if anything was picked
    dim as Vector2 mouse = GetMousePosition()
    if CheckCollisionPointCircle(mouse, curveStartPosition, 6) then
        curveSelectedPoint = @curveStartPosition
    elseif CheckCollisionPointCircle(mouse, curveStartPositionTangent, 6) then 
        curveSelectedPoint = @curveStartPositionTangent
    elseif CheckCollisionPointCircle(mouse, curveEndPosition, 6) then
        curveSelectedPoint = @curveEndPosition
    elseif CheckCollisionPointCircle(mouse, curveEndPositionTangent, 6) then
        curveSelectedPoint = @curveEndPositionTangent
    end if
    ''----------------------------------------------------------------------------------

    '' Draw
    ''----------------------------------------------------------------------------------
    BeginDrawing()

        ClearBackground(RAYWHITE)

        DrawTexturedCurve()    '' Draw a textured Spline Cubic Bezier
        
        '' Draw spline for reference
        if showCurve then DrawSplineSegmentBezierCubic(curveStartPosition, curveEndPosition, curveStartPositionTangent, curveEndPositionTangent, 2, BLUE)

        '' Draw the various control points and highlight where the mouse is
        DrawLineV(curveStartPosition, curveStartPositionTangent, SKYBLUE)
        DrawLineV(curveStartPositionTangent, curveEndPositionTangent, Fade(LIGHTGRAY, 0.4f))
        DrawLineV(curveEndPosition, curveEndPositionTangent, PURPLE)
        
        if CheckCollisionPointCircle(mouse, curveStartPosition, 6) then DrawCircleV(curveStartPosition, 7, YELLOW)
        DrawCircleV(curveStartPosition, 5, RED)

        if CheckCollisionPointCircle(mouse, curveStartPositionTangent, 6) then DrawCircleV(curveStartPositionTangent, 7, YELLOW)
        DrawCircleV(curveStartPositionTangent, 5, MAROON)

        if CheckCollisionPointCircle(mouse, curveEndPosition, 6) then DrawCircleV(curveEndPosition, 7, YELLOW)
        DrawCircleV(curveEndPosition, 5, GREEN)

        if CheckCollisionPointCircle(mouse, curveEndPositionTangent, 6) then DrawCircleV(curveEndPositionTangent, 7, YELLOW)
        DrawCircleV(curveEndPositionTangent, 5, DARKGREEN)

        '' Draw usage info
        DrawText("Drag points to move curve, press SPACE to show/hide base curve", 10, 10, 10, DARKGRAY)
        DrawText(TextFormat("Curve width: %2.0f (Use + and - to adjust)", curveWidth), 10, 30, 10, DARKGRAY)
        DrawText(TextFormat("Curve segments: %d (Use LEFT and RIGHT to adjust)", curveSegments), 10, 50, 10, DARKGRAY)
        
    EndDrawing()
    ''----------------------------------------------------------------------------------
loop

'' De-Initialization
''--------------------------------------------------------------------------------------
UnloadTexture(texRoad)

CloseWindow()              '' Close window and OpenGL context
''--------------------------------------------------------------------------------------

''----------------------------------------------------------------------------------
'' Module Functions Definition
''----------------------------------------------------------------------------------

'' Draw textured curve using Spline Cubic Bezier
sub DrawTexturedCurve()
    dim as single stp = 1.0f/curveSegments

    dim as Vector2 previous = curveStartPosition
    dim as Vector2 previousTangent
    dim as single previousV = 0

    '' We can't compute a tangent for the first point, so we need to reuse the tangent from the first segment
    dim as boolean tangentSet = false

    dim as Vector2 current
    dim as single t = 0.0f

    for i as integer = 1 to curveSegments
        t = stp * i

        dim as single a = 1.0f - (t ^ 3)
        dim as single b = 3.0f*(1.0f - t ^ 2) *t
        dim as single c = 3.0f*(1.0f - t)*(t ^ 2)
        dim as single d = t ^ 3

        '' Compute the endpoint for this segment
        current.y = a*curveStartPosition.y + b*curveStartPositionTangent.y + c*curveEndPositionTangent.y + d*curveEndPosition.y
        current.x = a*curveStartPosition.x + b*curveStartPositionTangent.x + c*curveEndPositionTangent.x + d*curveEndPosition.x

        '' Vector from previous to current
        dim as Vector2 delta = Vector2(current.x - previous.x, current.y - previous.y)

        '' The right hand normal to the delta vector
        dim as Vector2 normal = Vector2Normalize(Vector2(-delta.y, delta.x))

        '' The v texture coordinate of the segment (add up the length of all the segments so far)
        dim as single v = previousV + Vector2Length(delta)

        '' Make sure the start point has a normal
        if not tangentSet then
            previousTangent = normal
            tangentSet = true
        end if

        '' Extend out the normals from the previous and current points to get the quad for this segment
        dim as Vector2 prevPosNormal = Vector2Add(previous, Vector2Scale(previousTangent, curveWidth))
        dim as Vector2 prevNegNormal = Vector2Add(previous, Vector2Scale(previousTangent, -curveWidth))

        dim as Vector2 currentPosNormal = Vector2Add(current, Vector2Scale(normal, curveWidth))
        dim as Vector2 currentNegNormal = Vector2Add(current, Vector2Scale(normal, -curveWidth))

        '' Draw the segment as a quad
        rlSetTexture(texRoad.id)
        rlBegin(RL_QUADS)
            rlColor4ub(255,255,255,255)
            rlNormal3f(0.0f, 0.0f, 1.0f)

            rlTexCoord2f(0, previousV)
            rlVertex2f(prevNegNormal.x, prevNegNormal.y)

            rlTexCoord2f(1, previousV)
            rlVertex2f(prevPosNormal.x, prevPosNormal.y)

            rlTexCoord2f(1, v)
            rlVertex2f(currentPosNormal.x, currentPosNormal.y)

            rlTexCoord2f(0, v)
            rlVertex2f(currentNegNormal.x, currentNegNormal.y)
        rlEnd()

        '' The current step is the start of the next step
        previous = current
        previousTangent = normal
        previousV = v
    next
end sub