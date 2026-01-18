/'******************************************************************************************
*
*   raylib [core] example - automation events
*
*   Example originally created with raylib 5.0, last time updated with raylib 5.0
*
*   Example based on 2d_camera_platformer example by arvyy (@arvyy)
*
*   Example licensed under an unmodified zlib/libpng license, which is an OSI-certified,
*   BSD-like license that allows static linking with closed source software
*
*   Copyright (c) 2023 Ramon Santamaria (@raysan5)
*
*******************************************************************************************'/

#include "../../raylib.bi"

#define GRAVITY 400
#define PLAYER_JUMP_SPD 350.0f
#define PLAYER_HOR_SPD 200.0f

#define MAX_ENVIRONMENT_ELEMENTS    5

type Player
    as Vector2 position
    as single speed
    as boolean canJump
end type

type EnvElement
    as Rectangle rect
    as long blocking
    as RLColor color
    
    declare constructor()
    declare constructor(rect as Rectangle, blocking as long, clr as RLColor)
end type

constructor EnvElement()
end constructor

constructor EnvElement(rect as Rectangle, blocking as long, clr as RLColor)
    this.rect = rect
    this.blocking = blocking
    this.color = clr
end constructor

'' Initialization
''--------------------------------------------------------------------------------------
const as long screenWidth = 800
const as long screenHeight = 450

InitWindow(screenWidth, screenHeight, "raylib [core] example - automation events")

'' Define player
dim as Player play
with play
    .position = Vector2(400, 280)
    .speed = 0
    .canJump = false
end with

'' Define environment elements (platforms)
dim as EnvElement envElements(...) = { _
    EnvElement(Rectangle(0, 0, 1000, 400), 0, LIGHTGRAY), _
    EnvElement(Rectangle(0, 400, 1000, 200), 1, GRAY), _
    EnvElement(Rectangle(300, 200, 400, 10), 1, GRAY), _
    EnvElement(Rectangle(250, 300, 100, 10), 1, GRAY), _
    EnvElement(Rectangle(650, 300, 100, 10), 1, GRAY) }


'' Define camera
dim as Camera2D cam
with cam
    .target = play.position
    .offset = Vector2(screenWidth / 2.0f, screenHeight / 2.0f)
    .rotation = 0.0f
    .zoom = 1.0f
end with

'' Automation events
dim as AutomationEventList aelist = LoadAutomationEventList(0)  '' Initialize list of automation events to record new events
SetAutomationEventList(@aelist)
dim as boolean eventRecording = false
dim as boolean eventPlaying = false

dim as ulong frameCounter = 0
dim as ulong playFrameCounter = 0
dim as ulong currentPlayFrame = 0

SetTargetFPS(60)
''--------------------------------------------------------------------------------------

'' Main game loop
do while not WindowShouldClose()
    '' Update
    ''----------------------------------------------------------------------------------
    dim as single deltaTime = 0.015f ''GetFrameTime();
    
    '' Dropped files logic
    ''----------------------------------------------------------------------------------
    if IsFileDropped() then
        dim as FilePathList droppedFiles = LoadDroppedFiles()

        '' Supports loading .rgs style files (text or binary) and .png style palette images
        if IsFileExtension(*droppedFiles.paths[0], ".txt;.rae") then
            'UnloadAutomationEventList(@aelist) ''!!Crashes with double free if there are no recorded events.  Not sure how to test for that, so commented out.
            aelist = LoadAutomationEventList(*droppedFiles.paths[0])
            
            eventRecording = false
            
            '' Reset scene state to play
            eventPlaying = true
            playFrameCounter = 0
            currentPlayFrame = 0
            with play
                .position = Vector2(400, 280)
                .speed = 0
                .canJump = false
            end with
            with cam
                .target = play.position
                .offset = Vector2(screenWidth / 2.0f, screenHeight / 2.0f)
                .rotation = 0.0f
                .zoom = 1.0f
            end with
        end if

        UnloadDroppedFiles(droppedFiles)   '' Unload filepaths from memory
    end if
    ''----------------------------------------------------------------------------------

    '' Update player
    ''----------------------------------------------------------------------------------
    if IsKeyDown(KEY_LEFT) then play.position.x -= PLAYER_HOR_SPD * deltaTime
    if IsKeyDown(KEY_RIGHT) then play.position.x += PLAYER_HOR_SPD * deltaTime
    if IsKeyDown(KEY_SPACE) and play.canJump then
        play.speed = -PLAYER_JUMP_SPD
        play.canJump = false
    end if

    dim as long hitObstacle = 0
    for i as integer = 0 to MAX_ENVIRONMENT_ELEMENTS - 1
        dim as EnvElement ptr element = @envElements(i)
        dim as Vector2 ptr p = @play.position
        if element->blocking = 1 and _
            element->rect.x <= p->x and _
            element->rect.x + element->rect.width >= p->x and _
            element->rect.y >= p->y and _
            element->rect.y <= p->y + play.speed * deltaTime then
            hitObstacle = 1
            play.speed = 0.0f
            p->y = element->rect.y
        end if
    next

    if hitObstacle = 0 then
        play.position.y += play.speed*deltaTime
        play.speed += GRAVITY*deltaTime
        play.canJump = false
    else 
        play.canJump = true
    end if

    if IsKeyPressed(KEY_R) then
        '' Reset game state
        with play
            .position = Vector2(400, 280)
            .speed = 0
            .canJump = false
        end with
        with cam
            .target = play.position
            .offset = Vector2(screenWidth / 2.0f, screenHeight / 2.0f)
            .rotation = 0.0f
            .zoom = 1.0f
        end with
    end if
    ''----------------------------------------------------------------------------------

    '' Events playing
    '' NOTE: Logic must be before Camera update because it depends on mouse-wheel value, 
    '' that can be set by the played event... but some other inputs could be affected
    ''----------------------------------------------------------------------------------
    if eventPlaying then
        '' NOTE: Multiple events could be executed in a single frame
        do while playFrameCounter = aelist.events[currentPlayFrame].frame
            PlayAutomationEvent(aelist.events[currentPlayFrame])
            currentPlayFrame += 1

            if currentPlayFrame = aelist.count then
                eventPlaying = false
                currentPlayFrame = 0
                playFrameCounter = 0

                TraceLog(LOG_INFO, "FINISH PLAYING!")
                exit do
            end if
        loop

        playFrameCounter += 1
    end if
    ''----------------------------------------------------------------------------------

    '' Update camera
    ''----------------------------------------------------------------------------------
    cam.target = play.position
    cam.offset = Vector2(screenWidth / 2.0f, screenHeight / 2.0f)
    dim as single minX = 1000, minY = 1000, maxX = -1000, maxY = -1000

    '' WARNING: On event replay, mouse-wheel internal value is set
    cam.zoom += GetMouseWheelMove() * 0.05f
    if cam.zoom > 3.0f then 
        cam.zoom = 3.0f
    elseif cam.zoom < 0.25f then
        cam.zoom = 0.25f
    end if

    for i as integer = 0 to MAX_ENVIRONMENT_ELEMENTS - 1
        dim as EnvElement ptr element = @envElements(i)
        minX = fminf(element->rect.x, minX)
        maxX = fmaxf(element->rect.x + element->rect.width, maxX)
        minY = fminf(element->rect.y, minY)
        maxY = fmaxf(element->rect.y + element->rect.height, maxY)
    next

    dim as Vector2 max = GetWorldToScreen2D(Vector2(maxX, maxY), cam)
    dim as Vector2 min = GetWorldToScreen2D(Vector2(minX, minY), cam)

    if max.x < screenWidth then cam.offset.x = screenWidth - (max.x - screenWidth / 2)
    if max.y < screenHeight then cam.offset.y = screenHeight - (max.y - screenHeight / 2)
    if min.x > 0 then cam.offset.x = screenWidth / 2 - min.x
    if min.y > 0 then cam.offset.y = screenHeight / 2 - min.y
    ''----------------------------------------------------------------------------------
    
    '' Events management
    if IsKeyPressed(KEY_S) then    '' Toggle events recording
        if not eventPlaying  then
            if eventRecording then
                StopAutomationEventRecording()
                eventRecording = false
                
                ExportAutomationEventList(aelist, "automation.rae")
                
                TraceLog(LOG_INFO, "RECORDED FRAMES: %i", aelist.count)
            else 
                SetAutomationEventBaseFrame(180)
                StartAutomationEventRecording()
                eventRecording = true
            end if
        end if
    elseif IsKeyPressed(KEY_A) then '' Toggle events playing (WARNING: Starts next frame)
        if (not eventRecording) and (aelist.count > 0) then
            '' Reset scene state to play
            eventPlaying = true
            playFrameCounter = 0
            currentPlayFrame = 0

            with play
                .position = Vector2(400, 280)
                .speed = 0
                .canJump = false
            end with

            with cam
                .target = play.position
                .offset = Vector2(screenWidth / 2.0f, screenHeight / 2.0f)
                .rotation = 0.0f
                .zoom = 1.0f
            end with
        end if
    end if

    if eventRecording or eventPlaying then
        frameCounter += 1
    else 
        frameCounter = 0
    end if
    ''----------------------------------------------------------------------------------

    '' Draw
    ''----------------------------------------------------------------------------------
    BeginDrawing()

        ClearBackground(LIGHTGRAY)

        BeginMode2D(cam)

            '' Draw environment elements
            for i as integer = 0 to MAX_ENVIRONMENT_ELEMENTS - 1
                DrawRectangleRec(envElements(i).rect, envElements(i).color)
            next

            '' Draw player rectangle
            DrawRectangleRec(Rectangle(play.position.x - 20, play.position.y - 40, 40, 40), RED)

        EndMode2D()
        
        '' Draw game controls
        DrawRectangle(10, 10, 290, 145, Fade(SKYBLUE, 0.5f))
        DrawRectangleLines(10, 10, 290, 145, Fade(BLUE, 0.8f))

        DrawText("Controls:", 20, 20, 10, BLACK)
        DrawText("- RIGHT | LEFT: Player movement", 30, 40, 10, DARKGRAY)
        DrawText("- SPACE: Player jump", 30, 60, 10, DARKGRAY)
        DrawText("- R: Reset game state", 30, 80, 10, DARKGRAY)

        DrawText("- S: START/STOP RECORDING INPUT EVENTS", 30, 110, 10, BLACK)
        DrawText("- A: REPLAY LAST RECORDED INPUT EVENTS", 30, 130, 10, BLACK)

        '' Draw automation events recording indicator
        if eventRecording then
            DrawRectangle(10, 160, 290, 30, Fade(RED, 0.3f))
            DrawRectangleLines(10, 160, 290, 30, Fade(MAROON, 0.8f))
            DrawCircle(30, 175, 10, MAROON)

            if ((frameCounter / 15) mod 2) = 1 then DrawText(TextFormat("RECORDING EVENTS... [%i]", aelist.count), 50, 170, 10, MAROON)
        elseif eventPlaying then
            DrawRectangle(10, 160, 290, 30, Fade(LIME, 0.3f))
            DrawRectangleLines(10, 160, 290, 30, Fade(DARKGREEN, 0.8f))
            DrawTriangle(Vector2(20, 155 + 10), Vector2(20, 155 + 30), Vector2(40, 155 + 20), DARKGREEN)

            if ((frameCounter / 15) mod 2) = 1 then DrawText(TextFormat("PLAYING RECORDED EVENTS... [%i]", currentPlayFrame), 50, 170, 10, DARKGREEN)
        end if
        

    EndDrawing()
    ''----------------------------------------------------------------------------------
loop

'' De-Initialization
''--------------------------------------------------------------------------------------
CloseWindow()        '' Close window and OpenGL context
''--------------------------------------------------------------------------------------