/'******************************************************************************************
*
*   raylib [easings] example - Easings Testbed
*
*   Example originally created with raylib 2.5, last time updated with raylib 2.5
*
*   Example contributed by Juan Miguel López (@flashback-fx) and reviewed by Ramon Santamaria (@raysan5)
*
*   Example licensed under an unmodified zlib/libpng license, which is an OSI-certified,
*   BSD-like license that allows static linking with closed source software
*
*   Copyright (c) 2019-2024 Juan Miguel López (@flashback-fx ) and Ramon Santamaria (@raysan5)
*
*******************************************************************************************'/

#include "../../raylib.bi"

#include "../../reasings.bi"       '' Required for easing functions

#define FONT_SIZE         20

#define D_STEP         20.0f
#define D_STEP_FINE     2.0f
#define D_MIN           1.0f
#define D_MAX       10000.0f

'' Easing types
enum EasingTypes
    EASE_LINEAR_NONE = 0
    EASE_LINEAR_IN
    EASE_LINEAR_OUT
    EASE_LINEAR_IN_OUT
    EASE_SINE_IN
    EASE_SINE_OUT
    EASE_SINE_IN_OUT
    EASE_CIRC_IN
    EASE_CIRC_OUT
    EASE_CIRC_IN_OUT
    EASE_CUBIC_IN
    EASE_CUBIC_OUT
    EASE_CUBIC_IN_OUT
    EASE_QUAD_IN
    EASE_QUAD_OUT
    EASE_QUAD_IN_OUT
    EASE_EXPO_IN
    EASE_EXPO_OUT
    EASE_EXPO_IN_OUT
    EASE_BACK_IN
    EASE_BACK_OUT
    EASE_BACK_IN_OUT
    EASE_BOUNCE_OUT
    EASE_BOUNCE_IN
    EASE_BOUNCE_IN_OUT
    EASE_ELASTIC_IN
    EASE_ELASTIC_OUT
    EASE_ELASTIC_IN_OUT
    NUM_EASING_TYPES
    EASING_NONE = NUM_EASING_TYPES
end enum

declare function NoEase(byval t as single, b as single, c as single, d as single) as single  '' NoEase function declaration, function used when "no easing" is selected for any axis

'' Easing functions reference data
type EasingsRef
    as string name
    as function (byval t as single, b as single, c as single, d as single) as single func
end type

dim as EasingsRef Easings(0 to 28)    
Easings(EASE_LINEAR_NONE).name = "EaseLinearNone": Easings(EASE_LINEAR_NONE).func = @EaseLinearNone
Easings(EASE_LINEAR_IN).name = "EaseLinearIn": Easings(EASE_LINEAR_IN).func = @EaseLinearIn
Easings(EASE_LINEAR_OUT).name = "EaseLinearOut": Easings(EASE_LINEAR_OUT).func = @EaseLinearOut
Easings(EASE_LINEAR_IN_OUT).name = "EaseLinearInOut": Easings(EASE_LINEAR_IN_OUT).func = @EaseLinearInOut
Easings(EASE_SINE_IN).name = "EaseSineIn": Easings(EASE_SINE_IN).func = @EaseSineIn
Easings(EASE_SINE_OUT).name = "EaseSineOut": Easings(EASE_SINE_OUT).func = @EaseSineOut
Easings(EASE_SINE_IN_OUT).name = "EaseSineInOut": Easings(EASE_SINE_IN_OUT).func = @EaseSineInOut
Easings(EASE_CIRC_IN).name = "EaseCircIn": Easings(EASE_CIRC_IN).func = @EaseCircIn
Easings(EASE_CIRC_OUT).name = "EaseCircOut": Easings(EASE_CIRC_OUT).func = @EaseCircOut
Easings(EASE_CIRC_IN_OUT).name = "EaseCircInOut": Easings(EASE_CIRC_IN_OUT).func = @EaseCircInOut
Easings(EASE_CUBIC_IN).name = "EaseCubicIn": Easings(EASE_CUBIC_IN).func = @EaseCubicIn
Easings(EASE_CUBIC_OUT).name = "EaseCubicOut": Easings(EASE_CUBIC_OUT).func = @EaseCubicOut
Easings(EASE_CUBIC_IN_OUT).name = "EaseCubicInOut": Easings(EASE_CUBIC_IN_OUT).func = @EaseCubicInOut
Easings(EASE_QUAD_IN).name = "EaseQuadIn": Easings(EASE_QUAD_IN).func = @EaseQuadIn
Easings(EASE_QUAD_OUT).name = "EaseQuadOut": Easings(EASE_QUAD_OUT).func = @EaseQuadOut
Easings(EASE_QUAD_IN_OUT).name = "EaseQuadInOut": Easings(EASE_QUAD_IN_OUT).func = @EaseQuadInOut
Easings(EASE_EXPO_IN).name = "EaseExpoIn": Easings(EASE_EXPO_IN).func = @EaseExpoIn
Easings(EASE_EXPO_OUT).name = "EaseExpoOut": Easings(EASE_EXPO_OUT).func = @EaseExpoOut
Easings(EASE_EXPO_IN_OUT).name = "EaseExpoInOut": Easings(EASE_EXPO_IN_OUT).func = @EaseExpoInOut
Easings(EASE_BACK_IN).name = "EaseBackIn": Easings(EASE_BACK_IN).func = @EaseBackIn
Easings(EASE_BACK_OUT).name = "EaseBackOut": Easings(EASE_BACK_OUT).func = @EaseBackOut
Easings(EASE_BACK_IN_OUT).name = "EaseBackInOut": Easings(EASE_BACK_IN_OUT).func = @EaseBackInOut
Easings(EASE_BOUNCE_OUT).name = "EaseBounceOut": Easings(EASE_BOUNCE_OUT).func = @EaseBounceOut
Easings(EASE_BOUNCE_IN).name = "EaseBounceIn": Easings(EASE_BOUNCE_IN).func = @EaseBounceIn
Easings(EASE_BOUNCE_IN_OUT).name = "EaseBounceInOut": Easings(EASE_BOUNCE_IN_OUT).func = @EaseBounceInOut
Easings(EASE_ELASTIC_IN).name = "EaseElasticIn": Easings(EASE_ELASTIC_IN).func = @EaseElasticIn
Easings(EASE_ELASTIC_OUT).name = "EaseElasticOut": Easings(EASE_ELASTIC_OUT).func = @EaseElasticOut
Easings(EASE_ELASTIC_IN_OUT).name = "EaseElasticInOut": Easings(EASE_ELASTIC_IN_OUT).func = @EaseElasticInOut
Easings(EASING_NONE).name = "None": Easings(EASING_NONE).func = @NoEase


''------------------------------------------------------------------------------------
'' Program main entry point
''------------------------------------------------------------------------------------
'' Initialization
''--------------------------------------------------------------------------------------
const as long screenWidth = 800
const as long screenHeight = 450

InitWindow(screenWidth, screenHeight, "raylib [easings] example - easings testbed")

dim as Vector2 ballPosition = Vector2(100.0f, 100.0f)

dim as single t = 0.0f             '' Current time (in any unit measure, but same unit as duration)
dim as single d = 300.0f           '' Total time it should take to complete (duration)
dim as boolean paused = true
dim as boolean boundedT = true     '' If true, t will stop when d >= td, otherwise t will keep adding td to its value every loop

dim as long easingX = EASING_NONE  '' Easing selected for x axis
dim as long easingY = EASING_NONE  '' Easing selected for y axis

SetTargetFPS(60)
''--------------------------------------------------------------------------------------

'' Main game loop
do while not WindowShouldClose()    '' Detect window close button or ESC key
    '' Update
    ''----------------------------------------------------------------------------------
    if IsKeyPressed(KEY_T) then boundedT =  not boundedT

    '' Choose easing for the X axis
    if IsKeyPressed(KEY_RIGHT) then
        easingX += 1
        if easingX > EASING_NONE then easingX = 0
    elseif IsKeyPressed(KEY_LEFT) then
        if easingX = 0 then 
            easingX = EASING_NONE
        else 
            easingX -= 1
        end if
    end if

    '' Choose easing for the Y axis
    if IsKeyPressed(KEY_DOWN) then
        easingY += 1
        if easingY > EASING_NONE then easingY = 0
    elseif IsKeyPressed(KEY_UP) then
        if easingY = 0 then 
            easingY = EASING_NONE
        else 
            easingY -= 1
        end if
    end if

    '' Change d (duration) value
    if IsKeyPressed(KEY_W) and d < D_MAX - D_STEP then 
        d += D_STEP
    elseif IsKeyPressed(KEY_Q) and d > D_MIN + D_STEP then
        d -= D_STEP
    end if

    if IsKeyDown(KEY_S) and d < D_MAX - D_STEP_FINE then 
        d += D_STEP_FINE
    elseif IsKeyDown(KEY_A) and d > D_MIN + D_STEP_FINE then 
        d -= D_STEP_FINE
    end if

    '' Play, pause and restart controls
    if  IsKeyPressed(KEY_SPACE) or IsKeyPressed(KEY_T) or _
        IsKeyPressed(KEY_RIGHT) or IsKeyPressed(KEY_LEFT) or _
        IsKeyPressed(KEY_DOWN) or IsKeyPressed(KEY_UP) or _
        IsKeyPressed(KEY_W) or IsKeyPressed(KEY_Q) or _
        IsKeyDown(KEY_S)  or IsKeyDown(KEY_A) or _
        (IsKeyPressed(KEY_ENTER) and (boundedT = true) and (t >= d)) then
        t = 0.0f
        ballPosition.x = 100.0f
        ballPosition.y = 100.0f
        paused = true
    end if

    if IsKeyPressed(KEY_ENTER) then paused = not paused

    '' Movement computation
    if  not paused and ((boundedT and t < d) or not boundedT) then
        ballPosition.x = Easings(easingX).func(t, 100.0f, 700.0f - 170.0f, d)
        ballPosition.y = Easings(easingY).func(t, 100.0f, 400.0f - 170.0f, d)
        t += 1.0f
    end if
    ''----------------------------------------------------------------------------------

    '' Draw
    ''----------------------------------------------------------------------------------
    BeginDrawing()

        ClearBackground(RAYWHITE)

        '' Draw information text
        DrawText(TextFormat("Easing x: %s", Easings(easingX).name), 20, FONT_SIZE, FONT_SIZE, LIGHTGRAY)
        DrawText(TextFormat("Easing y: %s", Easings(easingY).name), 20, FONT_SIZE*2, FONT_SIZE, LIGHTGRAY)
        DrawText("t (" & iif(boundedT = true, "b", "u") & ") = " & t & " d = " & d, 20, FONT_SIZE*3, FONT_SIZE, LIGHTGRAY)

        '' Draw instructions text
        DrawText("Use ENTER to play or pause movement, use SPACE to restart", 20, GetScreenHeight() - FONT_SIZE*2, FONT_SIZE, LIGHTGRAY)
        DrawText("Use Q and W or A and S keys to change duration", 20, GetScreenHeight() - FONT_SIZE*3, FONT_SIZE, LIGHTGRAY)
        DrawText("Use LEFT or RIGHT keys to choose easing for the x axis", 20, GetScreenHeight() - FONT_SIZE*4, FONT_SIZE, LIGHTGRAY)
        DrawText("Use UP or DOWN keys to choose easing for the y axis", 20, GetScreenHeight() - FONT_SIZE*5, FONT_SIZE, LIGHTGRAY)

        '' Draw ball
        DrawCircleV(ballPosition, 16.0f, MAROON)

    EndDrawing()
    ''----------------------------------------------------------------------------------
loop

'' De-Initialization
''--------------------------------------------------------------------------------------
CloseWindow()
''--------------------------------------------------------------------------------------


' NoEase function, used when "no easing" is selected for any axis. It just ignores all parameters besides b.
function NoEase(byval t as single, b as single, c as single, d as single) as single
    'dim as single burn = t + b + c + d  '' Hack to avoid compiler warning (about unused variables)
    'd += burn

    return b
end function
