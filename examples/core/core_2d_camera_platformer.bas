/'******************************************************************************************
*
*   raylib [core] example - 2d camera platformer
*
*   Example complexity rating: [★★★☆] 3/4
*
*   Example originally created with raylib 2.5, last time updated with raylib 3.0
*
*   Example contributed by arvyy (@arvyy) and reviewed by Ramon Santamaria (@raysan5)
*
*   Example licensed under an unmodified zlib/libpng license, which is an OSI-certified,
*   BSD-like license that allows static linking with closed source software
*
*   Copyright (c) 2019-2025 arvyy (@arvyy)
*
*******************************************************************************************'/

#include "../../raylib.bi"

#define G 400
#define PLAYER_JUMP_SPD 350.0f
#define PLAYER_HOR_SPD 200.0f

''----------------------------------------------------------------------------------
'' Types and Structures Definition
''----------------------------------------------------------------------------------
type Player
    as Vector2 position
    as single speed
    as boolean canJump
end type

type EnvItem
    as Rectangle rect
    as long blocking
    as RLColor clr
    declare constructor()
    declare constructor(rect as Rectangle, block as long, clr as RLColor)
end type

constructor EnvItem()
end constructor

constructor EnvItem(rect as Rectangle, block as long, clr as RLColor)
    this.rect = rect
    this.blocking = block
    this.clr = clr
end constructor

''----------------------------------------------------------------------------------
'' Module Functions Declaration
''----------------------------------------------------------------------------------
declare sub UpdatePlayer(play as Player ptr, envItems() as EnvItem, envItemsLength as long, delta as single)
declare sub UpdateCameraCenter(cam as Camera2D ptr, play as Player ptr, envItems() as EnvItem, envItemsLength as long, delta as single, wid as long, height as long)
declare sub UpdateCameraCenterInsideMap(cam as Camera2D ptr, play as Player ptr, envItems() as EnvItem, envItemsLength as long, delta as single, wid as long, height as long)
declare sub UpdateCameraCenterSmoothFollow(cam as Camera2D ptr, play as Player ptr, envItems() as EnvItem, envItemsLength as long, delta as single, wid as long, height as long)
declare sub UpdateCameraEvenOutOnLanding(cam as Camera2D ptr, play as Player ptr, envItems() as EnvItem, envItemsLength as long, delta as single, wid as long, height as long)
declare sub UpdateCameraPlayerBoundsPush(cam as Camera2D ptr, play as Player ptr, envItems() as EnvItem, envItemsLength as long, delta as single, wid as long, height as long)

''------------------------------------------------------------------------------------
'' Program main entry point
''------------------------------------------------------------------------------------
'' Initialization
''--------------------------------------------------------------------------------------
const as long screenWidth = 800
const as long screenHeight = 450

InitWindow(screenWidth, screenHeight, "raylib [core] example - 2d camera platformer")

dim as Player play
play.position = Vector2(400, 280)
play.speed = 0
play.canJump = false
dim as EnvItem envItems(0 to 4)
envItems(0) = EnvItem(Rectangle(0, 0, 1000, 400), 0, LIGHTGRAY)
envItems(1) = EnvItem(Rectangle(0, 400, 1000, 200), 1, GRAY )
envItems(2) = EnvItem(Rectangle(300, 200, 400, 10), 1, GRAY )
envItems(3) = EnvItem(Rectangle(250, 300, 100, 10), 1, GRAY )
envItems(4) = EnvItem(Rectangle(650, 300, 100, 10), 1, GRAY )

dim as long envItemsLength = 5

dim as Camera2D cam
cam.target = player.position
cam.offset = Vector2(screenWidth/2.0f, screenHeight/2.0f)
cam.rotation = 0.0f
cam.zoom = 1.0f

'' Store pointers to the multiple update camera functions
dim as Sub(cam as Camera2D ptr, play as Player ptr, envItems() as EnvItem, envItemsLength as long, delta as single, wid as long, height as long) cameraUpdaters(0 to 4)
cameraUpdaters(0) = @UpdateCameraCenter
cameraUpdaters(1) = @UpdateCameraCenterInsideMap
cameraUpdaters(2) = @UpdateCameraCenterSmoothFollow
cameraUpdaters(3) = @UpdateCameraEvenOutOnLanding
cameraUpdaters(4) = @UpdateCameraPlayerBoundsPush


dim as long cameraOption = 0
dim as long cameraUpdatersLength = 5

Dim as string cameraDescriptions(0 to 4)
cameraDescriptions(0) = "Follow player center"
cameraDescriptions(1) = "Follow player center, but clamp to map edges"
cameraDescriptions(2) = "Follow player center; smoothed"
cameraDescriptions(3) = "Follow player center horizontally; update player center vertically after landing"
cameraDescriptions(4) = "Player push camera on getting too close to screen edge"

SetTargetFPS(60)
''--------------------------------------------------------------------------------------

'' Main game loop
do while WindowShouldClose() = false
    '' Update
    ''----------------------------------------------------------------------------------
    dim as single deltaTime = GetFrameTime()

    UpdatePlayer(@play, envItems(), envItemsLength, deltaTime)

    cam.zoom += cast(single, GetMouseWheelMove()) * 0.05f

    if cam.zoom > 3.0f then 
        cam.zoom = 3.0f
    elseif cam.zoom < 0.25f then 
        cam.zoom = 0.25f
    end if

    if IsKeyPressed(KEY_R) then
        cam.zoom = 1.0f
        play.position = Vector2(400, 280)
    end if

    if IsKeyPressed(KEY_C) then cameraOption = (cameraOption + 1) mod cameraUpdatersLength

    '' Call update camera function by its pointer
    cameraUpdaters(cameraOption)(@cam, @play, envItems(), envItemsLength, deltaTime, screenWidth, screenHeight)
    ''----------------------------------------------------------------------------------

    '' Draw
    ''----------------------------------------------------------------------------------
    BeginDrawing()

        ClearBackground(LIGHTGRAY)

        BeginMode2D(cam)

            for i as integer = 0 to envItemsLength - 1 
                DrawRectangleRec(envItems(i).rect, envItems(i).clr)
            next

            dim as Rectangle playerRect = Rectangle(play.position.x - 20, play.position.y - 40, 40.0f, 40.0f)
            DrawRectangleRec(playerRect, RED)

            DrawCircleV(play.position, 5.0f, GOLD)

        EndMode2D()

        DrawText("Controls:", 20, 20, 10, BLACK)
        DrawText("- Right/Left to move", 40, 40, 10, DARKGRAY)
        DrawText("- Space to jump", 40, 60, 10, DARKGRAY)
        DrawText("- Mouse Wheel to Zoom in-out, R to reset zoom", 40, 80, 10, DARKGRAY)
        DrawText("- C to change camera mode", 40, 100, 10, DARKGRAY)
        DrawText("Current camera mode:", 20, 120, 10, BLACK)
        DrawText(cameraDescriptions(cameraOption), 40, 140, 10, DARKGRAY)

    EndDrawing()
    ''----------------------------------------------------------------------------------
loop

'' De-Initialization
''--------------------------------------------------------------------------------------
CloseWindow()        '' Close window and OpenGL context
''--------------------------------------------------------------------------------------


sub UpdatePlayer(play as Player ptr, envItems() as EnvItem, envItemsLength as long, delta as single)
    if IsKeyDown(KEY_LEFT) then play->position.x -= PLAYER_HOR_SPD*delta
    if IsKeyDown(KEY_RIGHT) then play->position.x += PLAYER_HOR_SPD*delta
    if IsKeyDown(KEY_SPACE) and play->canJump then
        play->speed = -PLAYER_JUMP_SPD
        play->canJump = false
    end if

    dim as boolean hitObstacle = false
    for i as integer = 0 to envItemsLength - 1
        dim as Vector2 ptr p = @(play->position)
        if envItems(i).blocking and _
            envItems(i).rect.x <= p->x and _
            envItems(i).rect.x + envItems(i).rect.width >= p->x and _
            envItems(i).rect.y >= p->y and _
            envItems(i).rect.y <= p->y + play->speed*delta then
            hitObstacle = true
            play->speed = 0.0f
            p->y = envItems(i).rect.y
            exit for
        end if
    next

    if hitObstacle = false then
        play->position.y += play->speed*delta
        play->speed += G*delta
        play->canJump = false
    else 
        play->canJump = true
    end if
end sub

sub UpdateCameraCenter(cam as Camera2D ptr, play as Player ptr, envItems() as EnvItem, envItemsLength as long, delta as single, wid as long, height as long)
    cam->offset = Vector2(wid/2.0f, height/2.0f)
    cam->target = play->position
end sub

sub UpdateCameraCenterInsideMap(cam as Camera2D ptr, play as Player ptr, envItems() as EnvItem, envItemsLength as long, delta as single, wid as long, height as long)
    cam->target = play->position
    cam->offset = Vector2(wid/2.0f, height/2.0f)
    dim as single minX = 1000, minY = 1000, maxX = -1000, maxY = -1000

    for i as integer = 0 to envItemsLength - 1
        minX = fminf(envItems(i).rect.x, minX)
        maxX = fmaxf(envItems(i).rect.x + envItems(i).rect.width, maxX)
        minY = fminf(envItems(i).rect.y, minY)
        maxY = fmaxf(envItems(i).rect.y + envItems(i).rect.height, maxY)
    next

    dim as Vector2 max = GetWorldToScreen2D(Vector2(maxX, maxY), *cam)
    dim as Vector2 min = GetWorldToScreen2D(Vector2(minX, minY), *cam)

    if max.x < wid then cam->offset.x = wid - (max.x - wid/2)
    if max.y < height then cam->offset.y = height - (max.y - height/2)
    if min.x > 0 then cam->offset.x = wid/2 - min.x
    if min.y > 0 then cam->offset.y = height/2 - min.y
end sub

sub UpdateCameraCenterSmoothFollow(cam as Camera2D ptr, play as Player ptr, envItems() as EnvItem, envItemsLength as long, delta as single, wid as long, height as long)
    static as single minSpeed = 30
    static as single minEffectLength = 10
    static as single fractionSpeed = 0.8f

    cam->offset = Vector2(wid/2.0f, height/2.0f)
    dim as Vector2 diff = Vector2Subtract(play->position, cam->target)
    dim as single length = Vector2Length(diff)

    if length > minEffectLength then
        dim as single speed = fmaxf(fractionSpeed*length, minSpeed)
        cam->target = Vector2Add(cam->target, Vector2Scale(diff, speed*delta/length))
    end if
end sub

sub UpdateCameraEvenOutOnLanding(cam as Camera2D ptr, play as Player ptr, envItems() as EnvItem, envItemsLength as long, delta as single, wid as long, height as long)
    static as single evenOutSpeed = 700
    static as long eveningOut = false
    static as single evenOutTarget

    cam->offset = Vector2(wid/2.0f, height/2.0f)
    cam->target.x = play->position.x

    if eveningOut = 1 then
        if evenOutTarget > cam->target.y then
            cam->target.y += evenOutSpeed*delta

            if cam->target.y > evenOutTarget then
                cam->target.y = evenOutTarget
                eveningOut = 0
            end if
        else
            cam->target.y -= evenOutSpeed*delta

            if cam->target.y < evenOutTarget then
                cam->target.y = evenOutTarget
                eveningOut = 0
            end if
        end if
    else
        if play->canJump and (play->speed = 0) and (play->position.y <> cam->target.y) then
            eveningOut = 1
            evenOutTarget = play->position.y
        end if
    end if
end sub

sub UpdateCameraPlayerBoundsPush(cam as Camera2D ptr, play as Player ptr, envItems() as EnvItem, envItemsLength as long, delta as single, wid as long, height as long)
    static as Vector2 bbox = Vector2(0.2f, 0.2f)

    dim as Vector2 bboxWorldMin = GetScreenToWorld2D(Vector2((1 - bbox.x)*0.5f*wid, (1 - bbox.y)*0.5f*height), *cam)
    dim as Vector2 bboxWorldMax = GetScreenToWorld2D(Vector2((1 + bbox.x)*0.5f*wid, (1 + bbox.y)*0.5f*height), *cam)
    cam->offset = Vector2((1 - bbox.x)*0.5f*wid, (1 - bbox.y)*0.5f*height)

    if play->position.x < bboxWorldMin.x then cam->target.x = play->position.x
    if play->position.y < bboxWorldMin.y then cam->target.y = play->position.y
    if play->position.x > bboxWorldMax.x then cam->target.x = bboxWorldMin.x + (play->position.x - bboxWorldMax.x)
    if play->position.y > bboxWorldMax.y then cam->target.y = bboxWorldMin.y + (play->position.y - bboxWorldMax.y)
end sub