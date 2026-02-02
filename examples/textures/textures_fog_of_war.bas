/'******************************************************************************************
*
*   raylib [textures] example - Fog of war
*
*   Example originally created with raylib 4.2, last time updated with raylib 4.2
*
*   Example licensed under an unmodified zlib/libpng license, which is an OSI-certified,
*   BSD-like license that allows static linking with closed source software
*
*   Copyright (c) 2018-2024 Ramon Santamaria (@raysan5)
*
*******************************************************************************************'/

#include "../../raylib.bi"

#define MAP_TILE_SIZE    32         '' Tiles size 32x32 pixels
#define PLAYER_SIZE      16         '' Player size
#define PLAYER_TILE_VISIBILITY  2   '' Player can see 2 tiles around its position

'' Map data type
type MapInfo
    as ulong tilesX            '' Number of tiles in X axis
    as ulong tilesY            '' Number of tiles in Y axis
    as ubyte tileIds(any)      '' Tile ids (tilesX*tilesY), defines type of tile to draw
    as ubyte tileFog(any)      '' Tile fog state (tilesX*tilesY), defines if a tile has fog or half-fog
end type

'' Initialization
''--------------------------------------------------------------------------------------
const as long screenWidth = 800
const as long screenHeight = 450

InitWindow(screenWidth, screenHeight, "raylib [textures] example - fog of war")

dim as MapInfo map
map.tilesX = 25
map.tilesY = 15

'' NOTE: We can have up to 256 values for tile ids and for tile fog state,
'' probably we don't need that many values for fog state, it can be optimized
'' to use only 2 bits per fog state (reducing size by 4) but logic will be a bit more complex
redim map.tileIds((map.tilesX*map.tilesY) - 1)
redim map.tileFog((map.tilesX*map.tilesY) - 1)

'' Load map tiles (generating 2 random tile ids for testing)
'' NOTE: Map tile ids should be probably loaded from an external map file
for i as ulong = 0 to (map.tilesY*map.tilesX) - 1
    map.tileIds(i) = GetRandomValue(0, 1)
next

'' Player position on the screen (pixel coordinates, not tile coordinates)
dim as Vector2 playerPosition = Vector2(180, 130)
dim as long playerTileX = 0
dim as long playerTileY = 0

'' Render texture to render fog of war
'' NOTE: To get an automatic smooth-fog effect we use a render texture to render fog
'' at a smaller size (one pixel per tile) and scale it on drawing with bilinear filtering
dim as RenderTexture2D fogOfWar = LoadRenderTexture(map.tilesX, map.tilesY)
SetTextureFilter(fogOfWar.texture, TEXTURE_FILTER_BILINEAR)

SetTargetFPS(60)               '' Set our game to run at 60 frames-per-second
''--------------------------------------------------------------------------------------

'' Main game loop
do while not WindowShouldClose()    '' Detect window close button or ESC key
    '' Update
    ''----------------------------------------------------------------------------------
    '' Move player around
    if IsKeyDown(KEY_RIGHT) then playerPosition.x += 5
    if IsKeyDown(KEY_LEFT) then playerPosition.x -= 5
    if IsKeyDown(KEY_DOWN) then playerPosition.y += 5
    if IsKeyDown(KEY_UP) then playerPosition.y -= 5

    '' Check player position to avoid moving outside tilemap limits
    if playerPosition.x < 0 then
        playerPosition.x = 0
    elseif (playerPosition.x + PLAYER_SIZE) > (map.tilesX*MAP_TILE_SIZE) then
        playerPosition.x = map.tilesX*MAP_TILE_SIZE - PLAYER_SIZE
    end if
    if playerPosition.y < 0 then
        playerPosition.y = 0
    elseif (playerPosition.y + PLAYER_SIZE) > (map.tilesY*MAP_TILE_SIZE) then
        playerPosition.y = map.tilesY*MAP_TILE_SIZE - PLAYER_SIZE
    end if

    '' Previous visited tiles are set to partial fog
    for i as ulong = 0 to (map.tilesX*map.tilesY) - 1
        if map.tileFog(i) = 1 then map.tileFog(i) = 2
    next

    '' Get current tile position from player pixel position
    playerTileX = (playerPosition.x + MAP_TILE_SIZE/2)/MAP_TILE_SIZE
    playerTileY = (playerPosition.y + MAP_TILE_SIZE/2)/MAP_TILE_SIZE

    '' Check visibility and update fog
    '' NOTE: We check tilemap limits to avoid processing tiles out-of-array-bounds (it could crash program)
    for y as long = (playerTileY - PLAYER_TILE_VISIBILITY) to (playerTileY + PLAYER_TILE_VISIBILITY) - 1
        for x as long = (playerTileX - PLAYER_TILE_VISIBILITY) to (playerTileX + PLAYER_TILE_VISIBILITY) - 1
            if ((x >= 0) and (x < map.tilesX) and (y >= 0) and (y < map.tilesY)) then map.tileFog(y*map.tilesX + x) = 1
        next
    next
    ''----------------------------------------------------------------------------------

    '' Draw
    ''----------------------------------------------------------------------------------
    '' Draw fog of war to a small render texture for automatic smoothing on scaling
    BeginTextureMode(fogOfWar)
        ClearBackground(BLANK)
        for y as ulong = 0 to map.tilesY - 1
            for x as ulong = 0 to map.tilesX - 1
                if map.tileFog(y*map.tilesX + x) = 0 then
                    DrawRectangle(x, y, 1, 1, BLACK)
                elseif map.tileFog(y*map.tilesX + x) = 2 then
                    DrawRectangle(x, y, 1, 1, Fade(BLACK, 0.8f))
                end if
            next
        next
    EndTextureMode()

    BeginDrawing()

        ClearBackground(RAYWHITE)

        for y as ulong = 0 to map.tilesY - 1
            for x as ulong = 0 to map.tilesX - 1
                '' Draw tiles from id (and tile borders)
                DrawRectangle(x*MAP_TILE_SIZE, y*MAP_TILE_SIZE, MAP_TILE_SIZE, MAP_TILE_SIZE, _
                                iif((map.tileIds(y*map.tilesX + x) = 0), BLUE, Fade(BLUE, 0.9f)))
                DrawRectangleLines(x*MAP_TILE_SIZE, y*MAP_TILE_SIZE, MAP_TILE_SIZE, MAP_TILE_SIZE, Fade(DARKBLUE, 0.5f))
            next
        next

        '' Draw player
        DrawRectangleV(playerPosition, Vector2(PLAYER_SIZE, PLAYER_SIZE), RED)


        '' Draw fog of war (scaled to full map, bilinear filtering)
        DrawTexturePro(fogOfWar.texture, Rectangle(0, 0, fogOfWar.texture.width, -fogOfWar.texture.height ), _
                        Rectangle(0, 0, map.tilesX*MAP_TILE_SIZE, map.tilesY*MAP_TILE_SIZE), _
                        Vector2(0, 0), 0.0f, WHITE)

        '' Draw player current tile
        DrawText(TextFormat("Current tile: [%i,%i]", playerTileX, playerTileY), 10, 10, 20, RAYWHITE)
        DrawText("ARROW KEYS to move", 10, screenHeight-25, 20, RAYWHITE)

    EndDrawing()
    ''----------------------------------------------------------------------------------
loop

'' De-Initialization
''--------------------------------------------------------------------------------------
UnloadRenderTexture(fogOfWar)  '' Unload render texture

CloseWindow()          '' Close window and OpenGL context
''--------------------------------------------------------------------------------------