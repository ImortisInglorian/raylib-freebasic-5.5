/'******************************************************************************************
*
*   raylib [core] example - input virtual controls
*
*   Example originally created with raylib 5.0, last time updated with raylib 5.0
*
*   Example create by GreenSnakeLinux (@GreenSnakeLinux),
*   lighter by oblerion (@oblerion) and 
*   reviewed by Ramon Santamaria (@raysan5)
*
*   Example licensed under an unmodified zlib/libpng license, which is an OSI-certified,
*   BSD-like license that allows static linking with closed source software
*
*   Copyright (c) 2024 Ramon Santamaria (@raysan5)
*
*******************************************************************************************'/

#include "../../raylib.bi"
#include "crt/math.bi"

'' Initialization
''--------------------------------------------------------------------------------------
const as long screenWidth = 800
const as long screenHeight = 450

InitWindow(screenWidth, screenHeight, "raylib [core] example - input virtual controls")

const as single dpadX = 90
const as single dpadY = 300
const as single dpadRad = 25.0f''radius of each pad
dim as RLColor dpadColor = BLUE
dim as long dpadKeydown = -1''-1 if not down, else 0,1,2,3 


dim as single dpadCollider(..., ...)= _ '' collider array with x,y position
{{dpadX,dpadY-dpadRad*1.5f}, _
 {dpadX-dpadRad*1.5f,dpadY}, _
 {dpadX+dpadRad*1.5f,dpadY}, _
 {dpadX,dpadY+dpadRad*1.5f}}
dim as zstring * 5 dpadLabel = "XYBA"''label of Dpad

dim as single playerX=100
dim as single playerY=100

SetTargetFPS(60)
''--------------------------------------------------------------------------------------

'' Main game loop
do while not WindowShouldClose()    '' Detect window close button or ESC key
    '' Update 
    ''--------------------------------------------------------------------------
    dpadKeydown = -1 ''reset
    dim as long inputX = 0
    dim as long inputY = 0
    if GetTouchPointCount()>0 then
        ''use touch pos
        inputX = GetTouchX()
        inputY = GetTouchY()
    else
        ''use mouse pos
        inputX = GetMouseX()
        inputY = GetMouseY()
    end if
    for i as integer = 0 to 3
        ''test distance each collider and input < radius
        if fabsf(dpadCollider(i, 1)-inputY) + fabsf(dpadCollider(i, 0)-inputX) < dpadRad then
            dpadKeydown = i
            exit for
        end if
    next
    '' move player
    select case dpadKeydown
        case 0
            playerY -= 50*GetFrameTime()
        case 1
            playerX -= 50*GetFrameTime()
        case 2
            playerX += 50*GetFrameTime()
        case 3
            playerY += 50*GetFrameTime()
    end select
    ''--------------------------------------------------------------------------
    '' Draw 
    ''--------------------------------------------------------------------------
    BeginDrawing()
        ClearBackground(RAYWHITE)
        for i as integer = 0 to 3
            ''draw all pad
            DrawCircleV(Vector2(dpadCollider(i, 0), dpadCollider(i, 1)), dpadRad, dpadColor)
            if i <> dpadKeydown then
                ''draw label
                DrawText(TextSubtext(dpadLabel,i,1), dpadCollider(i, 0) - 7, dpadCollider(i, 1) - 8,20,BLACK)
            end if
        next

        DrawRectangleRec(Rectangle(playerX - 4, playerY - 4, 75, 28), RED)
        DrawText("Player", playerX, playerY, 20, WHITE)
    EndDrawing()
''--------------------------------------------------------------------------
loop

'' De-Initialization
''--------------------------------------------------------------------------------------
CloseWindow()        '' Close window and OpenGL context
''--------------------------------------------------------------------------------------