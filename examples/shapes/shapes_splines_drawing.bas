/'******************************************************************************************
*
*   raylib [shapes] example - splines drawing
*
*   Example originally created with raylib 5.0, last time updated with raylib 5.0
*
*   Example licensed under an unmodified zlib/libpng license, which is an OSI-certified,
*   BSD-like license that allows static linking with closed source software
*
*   Copyright (c) 2023 Ramon Santamaria (@raysan5)
*
*******************************************************************************************'/

#include "../../raylib.bi"
#include "../../raygui.bi"     '' Required for UI controls

#define NULL 0

#define MAX_SPLINE_POINTS      32

'' Cubic Bezier spline control points
'' NOTE: Every segment has two control points 
type ControlPoint
    as Vector2 start
    as Vector2 end
end type

'' Spline types
type as long SplineType
enum
    SPLINE_LINEAR = 0      '' Linear
    SPLINE_BASIS           '' B-Spline
    SPLINE_CATMULLROM      '' Catmull-Rom
    SPLINE_BEZIER          '' Cubic Bezier
end enum

'' Initialization
''--------------------------------------------------------------------------------------
const as long screenWidth = 800
const as long screenHeight = 450

SetConfigFlags(FLAG_MSAA_4X_HINT)
InitWindow(screenWidth, screenHeight, "raylib [shapes] example - splines drawing")

dim as Vector2 points(MAX_SPLINE_POINTS - 1)
points(0) = Vector2( 50.0f, 400.0f)
points(1) = Vector2(160.0f, 220.0f)
points(2) = Vector2(340.0f, 380.0f)
points(3) = Vector2(520.0f, 60.0f)
points(4) = Vector2(710.0f, 260.0f)

'' Array required for spline bezier-cubic, 
'' including control points interleaved with start-end segment points
dim as Vector2 pointsInterleaved(3 * (MAX_SPLINE_POINTS - 1))

dim as long pointCount = 5
dim as long selectedPoint = -1
dim as long focusedPoint = -1
dim as Vector2 ptr selectedControlPoint
dim as Vector2 ptr focusedControlPoint

'' Cubic Bezier control points initialization
dim as ControlPoint control(MAX_SPLINE_POINTS)
for i as integer = 0 to pointCount - 2
    control(i).start = Vector2(points(i).x + 50, points(i).y)
    control(i).end = Vector2(points(i + 1).x - 50, points(i + 1).y)
next

'' Spline config variables
dim as single splineThickness = 8.0f
dim as long splineTypeActive = SPLINE_LINEAR '' 0-Linear, 1-BSpline, 2-CatmullRom, 3-Bezier
dim as boolean splineTypeEditMode = false 
dim as RLBOOL splineHelpersActive = RLTRUE

SetTargetFPS(60)               '' Set our game to run at 60 frames-per-second
''--------------------------------------------------------------------------------------

'' Main game loop
do while not WindowShouldClose()    '' Detect window close button or ESC key
    '' Update
    ''----------------------------------------------------------------------------------
    '' Spline points creation logic (at the end of spline)
    if IsMouseButtonPressed(MOUSE_RIGHT_BUTTON) and (pointCount < MAX_SPLINE_POINTS) then
        points(pointCount) = GetMousePosition()
        dim as long i = pointCount - 1
        control(i).start = Vector2(points(i).x + 50, points(i).y)
        control(i).end = Vector2(points(i + 1).x - 50, points(i + 1).y)
        pointCount += 1
    end if

    '' Spline point focus and selection logic
    for i as integer = 0 to pointCount - 1
        if CheckCollisionPointCircle(GetMousePosition(), points(i), 8.0f) then
            focusedPoint = i
            if IsMouseButtonDown(MOUSE_LEFT_BUTTON) then selectedPoint = i
            exit for
        else 
            focusedPoint = -1
        end if
    next
    
    '' Spline point movement logic
    if selectedPoint >= 0 then
        points(selectedPoint) = GetMousePosition()
        if IsMouseButtonReleased(MOUSE_LEFT_BUTTON) then selectedPoint = -1
    end if
    
    '' Cubic Bezier spline control points logic
    if (splineTypeActive = SPLINE_BEZIER) and (focusedPoint = -1) then
        '' Spline control point focus and selection logic
        for i as integer = 0 to pointCount - 2
            if CheckCollisionPointCircle(GetMousePosition(), control(i).start, 6.0f) then
                focusedControlPoint = @control(i).start
                if IsMouseButtonDown(MOUSE_LEFT_BUTTON) then selectedControlPoint = @control(i).start 
                exit for
            elseif CheckCollisionPointCircle(GetMousePosition(), control(i).end, 6.0f) then
                focusedControlPoint = @control(i).end
                if IsMouseButtonDown(MOUSE_LEFT_BUTTON) then selectedControlPoint = @control(i).end 
                exit for
            else 
                focusedControlPoint = NULL
            end if
        next
        
        '' Spline control point movement logic
        if selectedControlPoint <> NULL then
            *selectedControlPoint = GetMousePosition()
            if IsMouseButtonReleased(MOUSE_LEFT_BUTTON) then selectedControlPoint = NULL
        end if
    end if
    
    '' Spline selection logic
    if IsKeyPressed(KEY_ONE) then
        splineTypeActive = 0
    elseif IsKeyPressed(KEY_TWO) then 
        splineTypeActive = 1
    elseif IsKeyPressed(KEY_THREE) then 
        splineTypeActive = 2
    elseif IsKeyPressed(KEY_FOUR) then
        splineTypeActive = 3
    end if
    ''----------------------------------------------------------------------------------

    '' Draw
    ''----------------------------------------------------------------------------------
    BeginDrawing()

        ClearBackground(RAYWHITE)
    
        if splineTypeActive = SPLINE_LINEAR then
            '' Draw spline: linear
            DrawSplineLinear(@points(0), pointCount, splineThickness, RED)
        elseif splineTypeActive = SPLINE_BASIS then
            '' Draw spline: basis
            DrawSplineBasis(@points(0), pointCount, splineThickness, RED)  '' Provide connected points array

            /'
            for i as integer = 0 to pointCount - 4
                '' Drawing individual segments, not considering thickness connection compensation
                DrawSplineSegmentBasis(points(i), points(i + 1), points(i + 2), points(i + 3), splineThickness, MAROON)
            next
            '/
        elseif splineTypeActive = SPLINE_CATMULLROM then
            '' Draw spline: catmull-rom
            DrawSplineCatmullRom(@points(0), pointCount, splineThickness, RED) '' Provide connected points array
            
            /'
            for i as integer = 0 to pointCount - 4
                '' Drawing individual segments, not considering thickness connection compensation
                DrawSplineSegmentCatmullRom(points(i), points(i + 1), points(i + 2), points(i + 3), splineThickness, MAROON)
            next
            '/
        elseif splineTypeActive = SPLINE_BEZIER then
            '' NOTE: Cubic-bezier spline requires the 2 control points of each segnment to be 
            '' provided interleaved with the start and end point of every segment
            for i as integer = 0 to pointCount - 2
                pointsInterleaved(3 * i) = points(i)
                pointsInterleaved(3 * i + 1) = control(i).start
                pointsInterleaved(3 * i + 2) = control(i).end
            next
            
            pointsInterleaved(3 * (pointCount - 1)) = points(pointCount - 1)

            '' Draw spline: cubic-bezier (with control points)
            DrawSplineBezierCubic(@pointsInterleaved(0), 3 * (pointCount - 1) + 1, splineThickness, RED)
            
            /'
            for i as integer = 0 to 3 * (pointCount - 2) step 3
                '' Drawing individual segments, not considering thickness connection compensation
                DrawSplineSegmentBezierCubic(pointsInterleaved(i), pointsInterleaved(i + 1), pointsInterleaved(i + 2), pointsInterleaved(i + 3), splineThickness, MAROON)
            next
            '/

            '' Draw spline control points
            for i as integer = 0 to pointCount - 2
                '' Every cubic bezier point have two control points
                DrawCircleV(control(i).start, 6, GOLD)
                DrawCircleV(control(i).end, 6, GOLD)
                if focusedControlPoint = @control(i).start then
                    DrawCircleV(control(i).start, 8, GREEN)
                elseif focusedControlPoint = @control(i).end then 
                    DrawCircleV(control(i).end, 8, GREEN)
                end if
                DrawLineEx(points(i), control(i).start, 1.0f, LIGHTGRAY)
                DrawLineEx(points(i + 1), control(i).end, 1.0f, LIGHTGRAY)
            
                '' Draw spline control lines
                DrawLineV(points(i), control(i).start, GRAY)
                ''DrawLineV(control[i].start, control[i].end, LIGHTGRAY)
                DrawLineV(control(i).end, points(i + 1), GRAY)
            next
        end if

        if splineHelpersActive = RLTRUE then
            '' Draw spline point helpers
            for i as integer = 0 to pointCount - 1
                DrawCircleLinesV(points(i), iif(focusedPoint = i, 12.0f, 8.0f), iif(focusedPoint = i, BLUE, DARKBLUE))
                if (splineTypeActive <> SPLINE_LINEAR) and _
                    (splineTypeActive <> SPLINE_BEZIER) and _
                    (i < pointCount - 1) then DrawLineV(points(i), points(i + 1), GRAY)

                DrawText(TextFormat("[%.0f, %.0f]", points(i).x, points(i).y), points(i).x, points(i).y + 10, 10, BLACK)
            next
        end if

        '' Check all possible UI states that require controls lock
        if splineTypeEditMode then GuiLock()
        
        '' Draw spline config
        GuiLabel(Rectangle(12, 62, 140, 24), TextFormat("Spline thickness: %i", splineThickness))
        GuiSliderBar(Rectangle(12, 60 + 24, 140, 16), NULL, NULL, @splineThickness, 1.0f, 40.0f)

        GuiCheckBox(Rectangle(12, 110, 20, 20), "Show point helpers", @splineHelpersActive)

        GuiUnlock()

        GuiLabel(Rectangle(12, 10, 140, 24), "Spline type:")
        if GuiDropdownBox(Rectangle(12, 8 + 24, 140, 28), "LINEARBSPLINECATMULLROMBEZIER", @splineTypeActive, splineTypeEditMode) then splineTypeEditMode = not splineTypeEditMode

    EndDrawing()
    ''----------------------------------------------------------------------------------
loop

'' De-Initialization
''--------------------------------------------------------------------------------------
CloseWindow()        '' Close window and OpenGL context
''--------------------------------------------------------------------------------------