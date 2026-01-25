#include "../../raylib.bi"
#include "../../rlgl.bi"

'' Draw rectangle with rounded edges and horizontal gradient, with options to choose side of roundness
'' Adapted from both `DrawRectangleRounded` and `DrawRectangleGradientH`
sub DrawRectangleRoundedGradientH(rec as Rectangle, roundnessLeft as single, roundnessRight as single, segments as long, lft as RLColor, rght as RLColor)
    '' Neither side is rounded
    if (roundnessLeft <= 0.0f and roundnessRight <= 0.0f) or (rec.width < 1) or (rec.height < 1 ) then
        DrawRectangleGradientEx(rec, lft, lft, rght, rght)
        return
    end if

    if roundnessLeft  >= 1.0f then roundnessLeft  = 1.0f
    if roundnessRight >= 1.0f then roundnessRight = 1.0f

    '' Calculate corner radius both from right and left
    dim as single recSize = iif(rec.width > rec.height, rec.height, rec.width)
    dim as single radiusLeft  = (recSize*roundnessLeft)/2
    dim as single radiusRight = (recSize*roundnessRight)/2

    if radiusLeft <= 0.0f then radiusLeft = 0.0f
    if radiusRight <= 0.0f then radiusRight = 0.0f

    if radiusRight <= 0.0f and radiusLeft <= 0.0f then return

    dim as single stepLength = 90.0f / segments

    /'
    Diagram Copied here for reference, original at `DrawRectangleRounded` source code

          P0____________________P1
          /|                    |\
         /1|          2         |3\
     P7 /__|____________________|__\ P2
       |   |P8                P9|   |
       | 8 |          9         | 4 |
       | __|____________________|__ |
     P6 \  |P11              P10|  / P3
         \7|          6         |5/
          \|____________________|/
          P5                    P4
    '/

    '' Coordinates of the 12 points also apdated from `DrawRectangleRounded`
    dim as Vector2 points(11) = { _
        Vector2(rec.x + radiusLeft, rec.y), Vector2((rec.x + rec.width) - radiusRight, rec.y), Vector2(rec.x + rec.width, rec.y + radiusRight), _
        Vector2(rec.x + rec.width, (rec.y + rec.height) - radiusRight), Vector2((rec.x + rec.width) - radiusRight, rec.y + rec.height), _
        Vector2(rec.x + radiusLeft, rec.y + rec.height), Vector2(rec.x, (rec.y + rec.height) - radiusLeft), Vector2(rec.x, rec.y + radiusLeft), _
        Vector2(rec.x + radiusLeft, rec.y + radiusLeft), Vector2((rec.x + rec.width) - radiusRight, rec.y + radiusRight), _ 
        Vector2((rec.x + rec.width) - radiusRight, (rec.y + rec.height) - radiusRight), Vector2(rec.x + radiusLeft, (rec.y + rec.height) - radiusLeft) _
    }

    dim as Vector2 centers(3) = {points(8), points(9), points(10), points(11)}
    dim as single angles(3) = { 180.0f, 270.0f, 0.0f, 90.0f }

#if defined(SUPPORT_QUADS_DRAW_MODE)
    rlSetTexture(GetShapesTexture().id)
    dim as Rectangle shapeRect = GetShapesTextureRectangle()

    rlBegin(RL_QUADS)
        '' Draw all the 4 corners: [1] Upper Left Corner, [3] Upper Right Corner, [5] Lower Right Corner, [7] Lower Left Corner
        for k as integer = 0 to 3
            dim as RLColor clr
            dim as single radius
            if k = 0 then '' [1] Upper Left Corner
                clr = lft
                radius = radiusLeft
            end if     
            if k = 1 then '' [3] Upper Right Corner
                clr = rght
                radius = radiusRight
            then
            if k = 2 then '' [5] Lower Right Corner
                clr = rght
                radius = radiusRight
            end if
            if k = 3 then '' [7] Lower Left Corner
                clr = lft
                radius = radiusLeft
            end if
            dim as single angle = angles(k)
            dim as Vector2 center = centers(k)

            for i as integer = 0 to segments/2
                rlColor4ub(clr.r, clr.g, clr.b, clr.a)
                rlTexCoord2f(shapeRect.x/texShapes.width, shapeRect.y/texShapes.height)
                rlVertex2f(center.x, center.y)

                rlTexCoord2f((shapeRect.x + shapeRect.width)/texShapes.width, shapeRect.y/texShapes.height)
                rlVertex2f(center.x + cos(DEG2RAD*(angle + stepLength*2))*radius, center.y + sin(DEG2RAD*(angle + stepLength*2))*radius)

                rlTexCoord2f((shapeRect.x + shapeRect.width)/texShapes.width, (shapeRect.y + shapeRect.height)/texShapes.height)
                rlVertex2f(center.x + cos(DEG2RAD*(angle + stepLength))*radius, center.y + sin(DEG2RAD*(angle + stepLength))*radius)

                rlTexCoord2f(shapeRect.x/texShapes.width, (shapeRect.y + shapeRect.height)/texShapes.height)
                rlVertex2f(center.x + cos(DEG2RAD*angle)*radius, center.y + sin(DEG2RAD*angle)*radius)

                angle += (stepLength * 2)
            next

            '' End one even segments
            if segments mod 2 <> 0 then
                rlTexCoord2f(shapeRect.x/texShapes.width, shapeRect.y/texShapes.height)
                rlVertex2f(center.x, center.y)

                rlTexCoord2f((shapeRect.x + shapeRect.width)/texShapes.width, (shapeRect.y + shapeRect.height)/texShapes.height)
                rlVertex2f(center.x + cos(DEG2RAD*(angle + stepLength))*radius, center.y + sin(DEG2RAD*(angle + stepLength))*radius)

                rlTexCoord2f(shapeRect.x/texShapes.width, (shapeRect.y + shapeRect.height)/texShapes.height)
                rlVertex2f(center.x + cos(DEG2RAD*angle)*radius, center.y + sin(DEG2RAD*angle)*radius)

                rlTexCoord2f((shapeRect.x + shapeRect.width)/texShapes.width, shapeRect.y/texShapes.height)
                rlVertex2f(center.x, center.y)
            end if
        next

        ''
        '' Here we use the `Diagram` to guide ourselves to which point receives what color.
        ''
        '' By choosing the color correctly associated with a pointe the gradient effect 
        '' will naturally come from OpenGL interpolation.
        ''

        '' [2] Upper Rectangle
        rlColor4ub(lft.r, lft.g, lft.b, lft.a)
        rlTexCoord2f(shapeRect.x/texShapes.width, shapeRect.y/texShapes.height)
        rlVertex2f(points(0).x, points(0).y)
        rlTexCoord2f(shapeRect.x/texShapes.width, (shapeRect.y + shapeRect.height)/texShapes.height)
        rlVertex2f(points(8).x, points(8).y)

        rlColor4ub(rght.r, rght.g, rght.b, rght.a)
        rlTexCoord2f((shapeRect.x + shapeRect.width)/texShapes.width, (shapeRect.y + shapeRect.height)/texShapes.height)
        rlVertex2f(points(9).x, points(9).y)

        rlColor4ub(rght.r, rght.g, rght.b, rght.a)
        rlTexCoord2f((shapeRect.x + shapeRect.width)/texShapes.width, shapeRect.y/texShapes.height)
        rlVertex2f(points(1).x, points(1).y)

        '' [4] Left Rectangle
        rlColor4ub(rght.r, rght.g, rght.b, rght.a)
        rlTexCoord2f(shapeRect.x/texShapes.width, shapeRect.y/texShapes.height)
        rlVertex2f(points(2).x, points(2).y)
        rlTexCoord2f(shapeRect.x/texShapes.width, (shapeRect.y + shapeRect.height)/texShapes.height)
        rlVertex2f(points(9).x, points(9).y)
        rlTexCoord2f((shapeRect.x + shapeRect.width)/texShapes.width, (shapeRect.y + shapeRect.height)/texShapes.height)
        rlVertex2f(points(10).x, points(10).y)
        rlTexCoord2f((shapeRect.x + shapeRect.width)/texShapes.width, shapeRect.y/texShapes.height)
        rlVertex2f(points(3).x, points(3).y)

        '' [6] Bottom Rectangle
        rlColor4ub(lft.r, lft.g, lft.b, lft.a)
        rlTexCoord2f(shapeRect.x/texShapes.width, shapeRect.y/texShapes.height)
        rlVertex2f(points(11).x, points(11).y)
        rlTexCoord2f(shapeRect.x/texShapes.width, (shapeRect.y + shapeRect.height)/texShapes.height)
        rlVertex2f(points(5).x, points(5).y)

        rlColor4ub(rght.r, rght.g, rght.b, rght.a)
        rlTexCoord2f((shapeRect.x + shapeRect.width)/texShapes.width, (shapeRect.y + shapeRect.height)/texShapes.height)
        rlVertex2f(points(4).x, points(4).y)
        rlTexCoord2f((shapeRect.x + shapeRect.width)/texShapes.width, shapeRect.y/texShapes.height)
        rlVertex2f(points(10).x, points(10).y)

        '' [8] left Rectangle
        rlColor4ub(lft.r, lft.g, lft.b, lft.a)
        rlTexCoord2f(shapeRect.x/texShapes.width, shapeRect.y/texShapes.height)
        rlVertex2f(points(7).x, points(7).y)
        rlTexCoord2f(shapeRect.x/texShapes.width, (shapeRect.y + shapeRect.height)/texShapes.height)
        rlVertex2f(points(6).x, points(6).y)
        rlTexCoord2f((shapeRect.x + shapeRect.width)/texShapes.width, (shapeRect.y + shapeRect.height)/texShapes.height)
        rlVertex2f(points(11).x, points(11).y)
        rlTexCoord2f((shapeRect.x + shapeRect.width)/texShapes.width, shapeRect.y/texShapes.height)
        rlVertex2f(points(8).x, points(8).y)

        '' [9] Middle Rectangle
        rlColor4ub(lft.r, lft.g, lft.b, lft.a)
        rlTexCoord2f(shapeRect.x/texShapes.width, shapeRect.y/texShapes.height)
        rlVertex2f(points(8).x, points(8).y)
        rlTexCoord2f(shapeRect.x/texShapes.width, (shapeRect.y + shapeRect.height)/texShapes.height)
        rlVertex2f(points(11).x, points(11).y)

        rlColor4ub(rght.r, rght.g, rght.b, rght.a)
        rlTexCoord2f((shapeRect.x + shapeRect.width)/texShapes.width, (shapeRect.y + shapeRect.height)/texShapes.height)
        rlVertex2f(points(10).x, points(10).y)
        rlTexCoord2f((shapeRect.x + shapeRect.width)/texShapes.width, shapeRect.y/texShapes.height)
        rlVertex2f(points(9).x, points(9).y)

    rlEnd()
    rlSetTexture(0)
#else

    ''
    '' Here we use the `Diagram` to guide ourselves to which point receives what color.
    ''
    '' By choosing the color correctly associated with a pointe the gradient effect 
    '' will naturally come from OpenGL interpolation.
    '' But this time instead of Quad, we think in triangles.
    ''

    rlBegin(RL_TRIANGLES)

        '' Draw all of the 4 corners: [1] Upper Left Corner, [3] Upper Right Corner, [5] Lower Right Corner, [7] Lower Left Corner
        for k as integer = 0 to 3
            dim as RLColor clr
            dim as single radius
            if k = 0 then '' [1] Upper Left Corner
                clr = lft
                radius = radiusLeft
            end if
            if k = 1 then '' [3] Upper Right Corner
                clr = rght
                radius = radiusRight
            end if
            if k = 2 then '' [5] Lower Right Corner
                clr = rght
                radius = radiusRight
            end if
            if k = 3 then '' [7] Lower Left Corner
                clr = lft
                radius = radiusLeft
            end if
            dim as single angle = angles(k)
            dim as Vector2 center = centers(k)
            for i as integer = 0 to segments - 1
                rlColor4ub(clr.r, clr.g, clr.b, clr.a)
                rlVertex2f(center.x, center.y)
                rlVertex2f(center.x + cos(DEG2RAD*(angle + stepLength))*radius, center.y + sin(DEG2RAD*(angle + stepLength))*radius)
                rlVertex2f(center.x + cos(DEG2RAD*angle)*radius, center.y + sin(DEG2RAD*angle)*radius)
                angle += stepLength
            next
        next

        '' [2] Upper Rectangle
        rlColor4ub(lft.r, lft.g, lft.b, lft.a)
        rlVertex2f(points(0).x, points(0).y)
        rlVertex2f(points(8).x, points(8).y)
        rlColor4ub(rght.r, rght.g, rght.b, rght.a)
        rlVertex2f(points(9).x, points(9).y)
        rlVertex2f(points(1).x, points(1).y)
        rlColor4ub(lft.r, lft.g, lft.b, lft.a)
        rlVertex2f(points(0).x, points(0).y)
        rlColor4ub(rght.r, rght.g, rght.b, rght.a)
        rlVertex2f(points(9).x, points(9).y)

        '' [4] Right Rectangle
        rlColor4ub(rght.r, rght.g, rght.b, rght.a)
        rlVertex2f(points(9).x, points(9).y)
        rlVertex2f(points(10).x, points(10).y)
        rlVertex2f(points(3).x, points(3).y)
        rlVertex2f(points(2).x, points(2).y)
        rlVertex2f(points(9).x, points(9).y)
        rlVertex2f(points(3).x, points(3).y)

        '' [6] Bottom Rectangle
        rlColor4ub(lft.r, lft.g, lft.b, lft.a)
        rlVertex2f(points(11).x, points(11).y)
        rlVertex2f(points(5).x, points(5).y)
        rlColor4ub(rght.r, rght.g, rght.b, rght.a)
        rlVertex2f(points(4).x, points(4).y)
        rlVertex2f(points(10).x, points(10).y)
        rlColor4ub(lft.r, lft.g, lft.b, lft.a)
        rlVertex2f(points(11).x, points(11).y)
        rlColor4ub(rght.r, rght.g, rght.b, rght.a)
        rlVertex2f(points(4).x, points(4).y)

        '' [8] Left Rectangle
        rlColor4ub(lft.r, lft.g, lft.b, lft.a)
        rlVertex2f(points(7).x, points(7).y)
        rlVertex2f(points(6).x, points(6).y)
        rlVertex2f(points(11).x, points(11).y)
        rlVertex2f(points(8).x, points(8).y)
        rlVertex2f(points(7).x, points(7).y)
        rlVertex2f(points(11).x, points(11).y)

        '' [9] Middle Rectangle
        rlColor4ub(lft.r, lft.g, lft.b, lft.a)
        rlVertex2f(points(8).x, points(8).y)
        rlVertex2f(points(11).x, points(11).y)
        rlColor4ub(rght.r, rght.g, rght.b, rght.a)
        rlVertex2f(points(10).x, points(10).y)
        rlVertex2f(points(9).x, points(9).y)
        rlColor4ub(lft.r, lft.g, lft.b, lft.a)
        rlVertex2f(points(8).x, points(8).y)
        rlColor4ub(rght.r, rght.g, rght.b, rght.a)
        rlVertex2f(points(10).x, points(10).y)
    rlEnd()
#endif
end sub

'' Initialization
''--------------------------------------------------------------------------------------
const as long screenWidth = 800
const as long screenHeight = 450
InitWindow(screenWidth, screenHeight, "raylib [shapes] example - rectangle avanced")
SetTargetFPS(60)
''--------------------------------------------------------------------------------------

'' Main game loop
do while not WindowShouldClose()     '' Detect window close button or ESC key
    '' Update rectangle bounds
    ''----------------------------------------------------------------------------------
    dim as single wid = GetScreenWidth()/2.0f, height = GetScreenHeight()/6.0f
    dim as Rectangle rec = Rectangle(GetScreenWidth() / 2.0f - wid/2, GetScreenHeight() / 2.0f - (5)*(height/2), wid, height)
    ''--------------------------------------------------------------------------------------

    '' Draw
    ''----------------------------------------------------------------------------------
    BeginDrawing()
        ClearBackground(RAYWHITE)

        '' Draw All Rectangles with different roundess  for each side and different gradients
        DrawRectangleRoundedGradientH(rec, 0.8f, 0.8f, 36, BLUE, RED)

        rec.y += rec.height + 1
        DrawRectangleRoundedGradientH(rec, 0.5f, 1.0f, 36, RED, PINK)

        rec.y += rec.height + 1
        DrawRectangleRoundedGradientH(rec, 1.0f, 0.5f, 36, RED, BLUE)

        rec.y += rec.height + 1
        DrawRectangleRoundedGradientH(rec, 0.0f, 1.0f, 36, BLUE, BLACK)

        rec.y += rec.height + 1
        DrawRectangleRoundedGradientH(rec, 1.0f, 0.0f, 36, BLUE, PINK)
    EndDrawing()
    ''--------------------------------------------------------------------------------------
loop

'' De-Initialization
''--------------------------------------------------------------------------------------
CloseWindow()        '' Close window and OpenGL context
''--------------------------------------------------------------------------------------