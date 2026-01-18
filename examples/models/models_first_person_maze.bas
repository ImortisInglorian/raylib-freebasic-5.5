/'******************************************************************************************
*
*   raylib [models] example - first person maze
*
*   Example originally created with raylib 2.5, last time updated with raylib 3.5
*
*   Example licensed under an unmodified zlib/libpng license, which is an OSI-certified,
*   BSD-like license that allows static linking with closed source software
*
*   Copyright (c) 2019-2024 Ramon Santamaria (@raysan5)
*
*******************************************************************************************'/

#include "../../raylib.bi"

'' Initialization
''--------------------------------------------------------------------------------------
const as long screenWidth = 800
const as long screenHeight = 450

InitWindow(screenWidth, screenHeight, "raylib [models] example - first person maze")

'' Define the camera to look into our 3d world
dim as Camera cam
with cam
    .position = Vector3(0.2f, 0.4f, 0.2f)    '' Camera position
    .target = Vector3(0.185f, 0.4f, 0.0f)    '' Camera looking at point
    .up = Vector3(0.0f, 1.0f, 0.0f)          '' Camera up vector (rotation towards target)
    .fovy = 45.0f                            '' Camera field-of-view Y
    .projection = CAMERA_PERSPECTIVE         '' Camera projection type
end with

dim as Image imMap = LoadImage("resources/cubicmap.png")      '' Load cubicmap image (RAM)
dim as Texture2D cubicmap = LoadTextureFromImage(imMap)       '' Convert image to texture to display (VRAM)
dim as Mesh msh = GenMeshCubicmap(imMap, Vector3(1.0f, 1.0f, 1.0f))
dim as Model mdl = LoadModelFromMesh(msh)

'' NOTE: By default each cube is mapped to one part of texture atlas
dim as Texture2D texture = LoadTexture("resources/cubicmap_atlas.png")    '' Load map texture
mdl.materials[0].maps[MATERIAL_MAP_DIFFUSE].texture = texture    '' Set map diffuse texture

'' Get map image data to be used for collision detection
dim as RLColor ptr mapPixels = LoadImageColors(imMap)
UnloadImage(imMap)             '' Unload image from RAM

dim as Vector3 mapPosition = Vector3(-16.0f, 0.0f, -8.0f)  '' Set model position

DisableCursor()                '' Limit cursor to relative movement inside the window

SetTargetFPS(60)               '' Set our game to run at 60 frames-per-second
''--------------------------------------------------------------------------------------

'' Main game loop
do while not WindowShouldClose()    '' Detect window close button or ESC key
    '' Update
    ''----------------------------------------------------------------------------------
    dim as Vector3 oldCamPos = cam.position    '' Store old camera position

    UpdateCamera(@cam, CAMERA_FIRST_PERSON)

    '' Check player collision (we simplify to 2D collision detection)
    dim as Vector2 playerPos = Vector2(cam.position.x, cam.position.z)
    dim as single playerRadius = 0.1f  '' Collision radius (player is modelled as a cilinder for collision)

    dim as long playerCellX = playerPos.x - mapPosition.x + 0.5f
    dim as long playerCellY = playerPos.y - mapPosition.z + 0.5f

    '' Out-of-limits security check
    if playerCellX < 0 then 
        playerCellX = 0
    elseif playerCellX >= cubicmap.width then 
        playerCellX = cubicmap.width - 1
    end if

    if playerCellY < 0 then
        playerCellY = 0
    elseif playerCellY >= cubicmap.height then
        playerCellY = cubicmap.height - 1
    end if

    '' Check map collisions using image data and player position
    '' TODO: Improvement: Just check player surrounding cells for collision
    for y as integer = 0 to cubicmap.height - 1
        for x as integer = 0 to cubicmap.width - 1
            '' Collision: white pixel, only check R channel
            if (mapPixels[y*cubicmap.width + x].r = 255) and _
                (CheckCollisionCircleRec(playerPos, playerRadius,_
                Rectangle(mapPosition.x - 0.5f + x*1.0f, mapPosition.z - 0.5f + y*1.0f, 1.0f, 1.0f))) then
                '' Collision detected, reset camera position
                cam.position = oldCamPos
            end if
        next
    next
    ''----------------------------------------------------------------------------------

    '' Draw
    ''----------------------------------------------------------------------------------
    BeginDrawing()

        ClearBackground(RAYWHITE)

        BeginMode3D(cam)
            DrawModel(mdl, mapPosition, 1.0f, WHITE)                     '' Draw maze map
        EndMode3D()

        DrawTextureEx(cubicmap, Vector2(GetScreenWidth() - cubicmap.width*4.0f - 20, 20.0f), 0.0f, 4.0f, WHITE)
        DrawRectangleLines(GetScreenWidth() - cubicmap.width*4 - 20, 20, cubicmap.width*4, cubicmap.height*4, GREEN)

        '' Draw player position radar
        DrawRectangle(GetScreenWidth() - cubicmap.width*4 - 20 + playerCellX*4, 20 + playerCellY*4, 4, 4, RED)

        DrawFPS(10, 10)

    EndDrawing()
    ''----------------------------------------------------------------------------------
loop

'' De-Initialization
''--------------------------------------------------------------------------------------
UnloadImageColors(mapPixels)   '' Unload color array

UnloadTexture(cubicmap)        '' Unload cubicmap texture
UnloadTexture(texture)         '' Unload map texture
UnloadModel(mdl)             '' Unload map model

CloseWindow()                  '' Close window and OpenGL context
''--------------------------------------------------------------------------------------