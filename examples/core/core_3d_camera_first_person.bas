/'******************************************************************************************
*
*   raylib [core] example - 3d camera first person
*
*   Example originally created with raylib 1.3, last time updated with raylib 1.3
*
*   Example licensed under an unmodified zlib/libpng license, which is an OSI-certified,
*   BSD-like license that allows static linking with closed source software
*
*   Copyright (c) 2015-2024 Ramon Santamaria (@raysan5)
*
*******************************************************************************************'/

#include "../../raylib.bi"
#include "../../rcamera.bi"

#define MAX_COLUMNS 20

'' Initialization
''--------------------------------------------------------------------------------------
const as long screenWidth = 800
const as long screenHeight = 450

InitWindow(screenWidth, screenHeight, "raylib [core] example - 3d camera first person")

'' Define the camera to look into our 3d world (position, target, up vector)
dim as Camera cam
with cam
    .position = Vector3(0.0f, 2.0f, 4.0f)    '' Camera position
    .target = Vector3(0.0f, 2.0f, 0.0f)      '' Camera looking at point
    .up = Vector3(0.0f, 1.0f, 0.0f)          '' Camera up vector (rotation towards target)
    .fovy = 60.0f                            '' Camera field-of-view Y
    .projection = CAMERA_PERSPECTIVE         '' Camera projection type
end with

dim as long cameraMode = CAMERA_FIRST_PERSON

'' Generates some random columns
dim as single heights(MAX_COLUMNS - 1)
dim as Vector3 positions(MAX_COLUMNS - 1)
dim as RLColor colors(MAX_COLUMNS - 1)

for i as integer = 0 to MAX_COLUMNS - 1
    heights(i) = GetRandomValue(1, 12)
    positions(i) = Vector3(GetRandomValue(-15, 15), heights(i) / 2.0f, GetRandomValue(-15, 15))
    colors(i) = RLColor(GetRandomValue(20, 255), GetRandomValue(10, 55), 30, 255)
next

DisableCursor()                    '' Limit cursor to relative movement inside the window

SetTargetFPS(60)                   '' Set our game to run at 60 frames-per-second
''--------------------------------------------------------------------------------------

'' Main game loop
do while not WindowShouldClose()        '' Detect window close button or ESC key
    '' Update
    ''----------------------------------------------------------------------------------
    '' Switch camera mode
    if IsKeyPressed(KEY_ONE) then
        cameraMode = CAMERA_FREE
        cam.up = Vector3(0.0f, 1.0f, 0.0f) '' Reset roll
    end if

    if IsKeyPressed(KEY_TWO) then
        cameraMode = CAMERA_FIRST_PERSON
        cam.up = Vector3(0.0f, 1.0f, 0.0f) '' Reset roll
    end if

    if IsKeyPressed(KEY_THREE) then
        cameraMode = CAMERA_THIRD_PERSON
        cam.up = Vector3(0.0f, 1.0f, 0.0f) '' Reset roll
    end if

    if IsKeyPressed(KEY_FOUR) then
        cameraMode = CAMERA_ORBITAL
        cam.up = Vector3(0.0f, 1.0f, 0.0f) '' Reset roll
    end if

    '' Switch camera projection
    if IsKeyPressed(KEY_P) then
        if cam.projection = CAMERA_PERSPECTIVE then
            '' Create isometric view
            cameraMode = CAMERA_THIRD_PERSON
            '' Note: The target distance is related to the render distance in the orthographic projection
            with cam
                .position = Vector3(0.0f, 2.0f, -100.0f)
                .target = Vector3(0.0f, 2.0f, 0.0f)
                .up = Vector3(0.0f, 1.0f, 0.0f)
                .projection = CAMERA_ORTHOGRAPHIC
                .fovy = 20.0f '' near plane width in CAMERA_ORTHOGRAPHIC
            end with
            CameraYaw(@cam, -135 * DEG2RAD, true)
            CameraPitch(@cam, -45 * DEG2RAD, true, true, false)
        elseif cam.projection = CAMERA_ORTHOGRAPHIC then
            '' Reset to default view
            cameraMode = CAMERA_THIRD_PERSON
            with cam
                .position = Vector3(0.0f, 2.0f, 10.0f)
                .target = Vector3(0.0f, 2.0f, 0.0f)
                .up = Vector3(0.0f, 1.0f, 0.0f)
                .projection = CAMERA_PERSPECTIVE
                .fovy = 60.0f
            end with
        end if
    end if

    '' Update camera computes movement internally depending on the camera mode
    '' Some default standard keyboard/mouse inputs are hardcoded to simplify use
    '' For advance camera controls, it's reecommended to compute camera movement manually
    UpdateCamera(@cam, cameraMode)                  '' Update camera

    /'
    '' Camera PRO usage example (EXPERIMENTAL)
    '' This new camera function allows custom movement/rotation values to be directly provided
    '' as input parameters, with this approach, rcamera module is internally independent of raylib inputs
    UpdateCameraPro(&camera,
        (Vector3){
            (IsKeyDown(KEY_W) || IsKeyDown(KEY_UP))*0.1f -      '' Move forward-backward
            (IsKeyDown(KEY_S) || IsKeyDown(KEY_DOWN))*0.1f,    
            (IsKeyDown(KEY_D) || IsKeyDown(KEY_RIGHT))*0.1f -   '' Move right-left
            (IsKeyDown(KEY_A) || IsKeyDown(KEY_LEFT))*0.1f,
            0.0f                                                '' Move up-down
        },
        (Vector3){
            GetMouseDelta().x*0.05f,                            '' Rotation: yaw
            GetMouseDelta().y*0.05f,                            '' Rotation: pitch
            0.0f                                                '' Rotation: roll
        },
        GetMouseWheelMove()*2.0f);                              '' Move to target (zoom)
    '/
    ''----------------------------------------------------------------------------------

    '' Draw
    ''----------------------------------------------------------------------------------
    BeginDrawing()

        ClearBackground(RAYWHITE)

        BeginMode3D(cam)

            DrawPlane(Vector3(0.0f, 0.0f, 0.0f), Vector2(32.0f, 32.0f), LIGHTGRAY)  '' Draw ground
            DrawCube(Vector3(-16.0f, 2.5f, 0.0f), 1.0f, 5.0f, 32.0f, BLUE)          '' Draw a blue wall
            DrawCube(Vector3(16.0f, 2.5f, 0.0f), 1.0f, 5.0f, 32.0f, LIME)           '' Draw a green wall
            DrawCube(Vector3(0.0f, 2.5f, 16.0f), 32.0f, 5.0f, 1.0f, GOLD)           '' Draw a yellow wall

            '' Draw some cubes around
            for i as integer = 0 to MAX_COLUMNS - 1
                DrawCube(positions(i), 2.0f, heights(i), 2.0f, colors(i))
                DrawCubeWires(positions(i), 2.0f, heights(i), 2.0f, MAROON)
            next

            '' Draw player cube
            if cameraMode = CAMERA_THIRD_PERSON then
                DrawCube(cam.target, 0.5f, 0.5f, 0.5f, PURPLE)
                DrawCubeWires(cam.target, 0.5f, 0.5f, 0.5f, DARKPURPLE)
            end if

        EndMode3D()

        '' Draw info boxes
        DrawRectangle(5, 5, 330, 100, Fade(SKYBLUE, 0.5f))
        DrawRectangleLines(5, 5, 330, 100, BLUE)

        DrawText("Camera controls:", 15, 15, 10, BLACK)
        DrawText("- Move keys: W, A, S, D, Space, Left-Ctrl", 15, 30, 10, BLACK)
        DrawText("- Look around: arrow keys or mouse", 15, 45, 10, BLACK)
        DrawText("- Camera mode keys: 1, 2, 3, 4", 15, 60, 10, BLACK)
        DrawText("- Zoom keys: num-plus, num-minus or mouse scroll", 15, 75, 10, BLACK)
        DrawText("- Camera projection key: P", 15, 90, 10, BLACK)

        DrawRectangle(600, 5, 195, 100, Fade(SKYBLUE, 0.5f))
        DrawRectangleLines(600, 5, 195, 100, BLUE)

        DrawText("Camera status:", 610, 15, 10, BLACK)
        dim as string modeText = "- Mode: "
        select case cameraMode
            case CAMERA_FREE
                modeText &= "FREE"
            case CAMERA_FIRST_PERSON
                modeText &= "FIRST_PERSON"
            case CAMERA_THIRD_PERSON
                modeText &= "THIRD_PERSON"
            case CAMERA_ORBITAL
                modeText &= "ORBITAL"
            case else
                modeText &= "CUSTOM"
        end select
        DrawText(modeText, 610, 30, 10, BLACK)
        dim as string projText = "- Projection: "
        select case cam.projection
            case CAMERA_PERSPECTIVE
                projText &= "PERSPECTIVE"
            case CAMERA_ORTHOGRAPHIC
                projText &= "ORTHOGRAPHIC"
            case else
                projText &= "CUSTOM"
        end select
        DrawText(projText, 610, 45, 10, BLACK)
        with cam
            DrawText(TextFormat("- Position: (%06.3f, %06.3f, %06.3f)", .position.x, .position.y, .position.z), 610, 60, 10, BLACK)
            DrawText(TextFormat("- Target: (%06.3f, %06.3f, %06.3f)", .target.x, .target.y, .target.z), 610, 75, 10, BLACK)
            DrawText(TextFormat("- Up: (%06.3f, %06.3f, %06.3f)", .up.x, .up.y, .up.z), 610, 90, 10, BLACK)
        end with
    EndDrawing()
    ''----------------------------------------------------------------------------------
loop

'' De-Initialization
''--------------------------------------------------------------------------------------
CloseWindow()        '' Close window and OpenGL context
''--------------------------------------------------------------------------------------