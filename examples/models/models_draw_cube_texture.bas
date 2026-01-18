/'******************************************************************************************
*
*   raylib [models] example - Draw textured cube
*
*   Example originally created with raylib 4.5, last time updated with raylib 4.5
*
*   Example licensed under an unmodified zlib/libpng license, which is an OSI-certified,
*   BSD-like license that allows static linking with closed source software
*
*   Copyright (c) 2022-2024 Ramon Santamaria (@raysan5)
*
*******************************************************************************************'/

#include "../../raylib.bi"

#include "../../rlgl.bi"       '' Required to define vertex data (immediate-mode style)

''------------------------------------------------------------------------------------
'' Custom Functions Declaration
''------------------------------------------------------------------------------------
declare sub DrawCubeTexture(texture as Texture2D, position as Vector3, wid as single, height as single, length as single, clr as RLColor) '' Draw cube textured
declare sub DrawCubeTextureRec(texture as Texture2D, source as Rectangle, position as Vector3, wid as single, height as single, length as single, clr as RLColor) '' Draw cube with a region of a texture

''------------------------------------------------------------------------------------
'' Program main entry point
''------------------------------------------------------------------------------------
'' Initialization
''--------------------------------------------------------------------------------------
const as long screenWidth = 800
const as long screenHeight = 450

InitWindow(screenWidth, screenHeight, "raylib [models] example - draw cube texture")

'' Define the camera to look into our 3d world
dim as Camera cam
with cam
    .position = Vector3(0.0f, 10.0f, 10.0f)
    .target = Vector3(0.0f, 0.0f, 0.0f)
    .up = Vector3(0.0f, 1.0f, 0.0f)
    .fovy = 45.0f
    .projection = CAMERA_PERSPECTIVE
end with
'' Load texture to be applied to the cubes sides
dim as Texture2D texture = LoadTexture("resources/cubicmap_atlas.png")

SetTargetFPS(60)               '' Set our game to run at 60 frames-per-second
''--------------------------------------------------------------------------------------

'' Main game loop
do while not WindowShouldClose()    '' Detect window close button or ESC key
    '' Update
    ''----------------------------------------------------------------------------------
    '' TODO: Update your variables here
    ''----------------------------------------------------------------------------------

    '' Draw
    ''----------------------------------------------------------------------------------
    BeginDrawing()

        ClearBackground(RAYWHITE)

        BeginMode3D(cam)

            '' Draw cube with an applied texture
            DrawCubeTexture(texture, Vector3(-2.0f, 2.0f, 0.0f), 2.0f, 4.0f, 2.0f, WHITE)

            '' Draw cube with an applied texture, but only a defined rectangle piece of the texture
            DrawCubeTextureRec(texture, Rectangle(0.0f, texture.height/2.0f, texture.width/2.0f, texture.height/2.0f), _
                Vector3(2.0f, 1.0f, 0.0f), 2.0f, 2.0f, 2.0f, WHITE)

            DrawGrid(10, 1.0f)        '' Draw a grid

        EndMode3D()

        DrawFPS(10, 10)

    EndDrawing()
    ''----------------------------------------------------------------------------------
loop

'' De-Initialization
''--------------------------------------------------------------------------------------
UnloadTexture(texture) '' Unload texture

CloseWindow()          '' Close window and OpenGL context
''--------------------------------------------------------------------------------------

''------------------------------------------------------------------------------------
'' Custom Functions Definition
''------------------------------------------------------------------------------------
'' Draw cube textured
'' NOTE: Cube position is the center position
sub DrawCubeTexture(texture as Texture2D, position as Vector3, wid as single, height as single, length as single, clr as RLColor)
    dim as single x = position.x
    dim as single y = position.y
    dim as single z = position.z

    '' Set desired texture to be enabled while drawing following vertex data
    rlSetTexture(texture.id)

    '' Vertex data transformation can be defined with the commented lines,
    '' but in this example we calculate the transformed vertex data directly when calling rlVertex3f()
    ''rlPushMatrix()
        '' NOTE: Transformation is applied in inverse order (scale -> rotate -> translate)
        ''rlTranslatef(2.0f, 0.0f, 0.0f)
        ''rlRotatef(45, 0, 1, 0)
        ''rlScalef(2.0f, 2.0f, 2.0f)

        rlBegin(RL_QUADS)
            rlColor4ub(clr.r, clr.g, clr.b, clr.a)
            '' Front Face
            rlNormal3f(0.0f, 0.0f, 1.0f)       '' Normal Pointing Towards Viewer
            rlTexCoord2f(0.0f, 0.0f): rlVertex3f(x - wid/2, y - height/2, z + length/2)  '' Bottom Left Of The Texture and Quad
            rlTexCoord2f(1.0f, 0.0f): rlVertex3f(x + wid/2, y - height/2, z + length/2)  '' Bottom Right Of The Texture and Quad
            rlTexCoord2f(1.0f, 1.0f): rlVertex3f(x + wid/2, y + height/2, z + length/2)  '' Top Right Of The Texture and Quad
            rlTexCoord2f(0.0f, 1.0f): rlVertex3f(x - wid/2, y + height/2, z + length/2)  '' Top Left Of The Texture and Quad
            '' Back Face
            rlNormal3f(0.0f, 0.0f, - 1.0f)     '' Normal Pointing Away From Viewer
            rlTexCoord2f(1.0f, 0.0f): rlVertex3f(x - wid/2, y - height/2, z - length/2)  '' Bottom Right Of The Texture and Quad
            rlTexCoord2f(1.0f, 1.0f): rlVertex3f(x - wid/2, y + height/2, z - length/2)  '' Top Right Of The Texture and Quad
            rlTexCoord2f(0.0f, 1.0f): rlVertex3f(x + wid/2, y + height/2, z - length/2)  '' Top Left Of The Texture and Quad
            rlTexCoord2f(0.0f, 0.0f): rlVertex3f(x + wid/2, y - height/2, z - length/2)  '' Bottom Left Of The Texture and Quad
            '' Top Face
            rlNormal3f(0.0f, 1.0f, 0.0f)       '' Normal Pointing Up
            rlTexCoord2f(0.0f, 1.0f): rlVertex3f(x - wid/2, y + height/2, z - length/2)  '' Top Left Of The Texture and Quad
            rlTexCoord2f(0.0f, 0.0f): rlVertex3f(x - wid/2, y + height/2, z + length/2)  '' Bottom Left Of The Texture and Quad
            rlTexCoord2f(1.0f, 0.0f): rlVertex3f(x + wid/2, y + height/2, z + length/2)  '' Bottom Right Of The Texture and Quad
            rlTexCoord2f(1.0f, 1.0f): rlVertex3f(x + wid/2, y + height/2, z - length/2)  '' Top Right Of The Texture and Quad
            '' Bottom Face
            rlNormal3f(0.0f, - 1.0f, 0.0f)     '' Normal Pointing Down
            rlTexCoord2f(1.0f, 1.0f): rlVertex3f(x - wid/2, y - height/2, z - length/2)  '' Top Right Of The Texture and Quad
            rlTexCoord2f(0.0f, 1.0f): rlVertex3f(x + wid/2, y - height/2, z - length/2)  '' Top Left Of The Texture and Quad
            rlTexCoord2f(0.0f, 0.0f): rlVertex3f(x + wid/2, y - height/2, z + length/2)  '' Bottom Left Of The Texture and Quad
            rlTexCoord2f(1.0f, 0.0f): rlVertex3f(x - wid/2, y - height/2, z + length/2)  '' Bottom Right Of The Texture and Quad
            '' Right face
            rlNormal3f(1.0f, 0.0f, 0.0f)       '' Normal Pointing Right
            rlTexCoord2f(1.0f, 0.0f): rlVertex3f(x + wid/2, y - height/2, z - length/2)  '' Bottom Right Of The Texture and Quad
            rlTexCoord2f(1.0f, 1.0f): rlVertex3f(x + wid/2, y + height/2, z - length/2)  '' Top Right Of The Texture and Quad
            rlTexCoord2f(0.0f, 1.0f): rlVertex3f(x + wid/2, y + height/2, z + length/2)  '' Top Left Of The Texture and Quad
            rlTexCoord2f(0.0f, 0.0f): rlVertex3f(x + wid/2, y - height/2, z + length/2)  '' Bottom Left Of The Texture and Quad
            '' Left Face
            rlNormal3f( - 1.0f, 0.0f, 0.0f)    '' Normal Pointing Left
            rlTexCoord2f(0.0f, 0.0f): rlVertex3f(x - wid/2, y - height/2, z - length/2)  '' Bottom Left Of The Texture and Quad
            rlTexCoord2f(1.0f, 0.0f): rlVertex3f(x - wid/2, y - height/2, z + length/2)  '' Bottom Right Of The Texture and Quad
            rlTexCoord2f(1.0f, 1.0f): rlVertex3f(x - wid/2, y + height/2, z + length/2)  '' Top Right Of The Texture and Quad
            rlTexCoord2f(0.0f, 1.0f): rlVertex3f(x - wid/2, y + height/2, z - length/2)  '' Top Left Of The Texture and Quad
        rlEnd()
    ''rlPopMatrix()

    rlSetTexture(0)
end sub

'' Draw cube with texture piece applied to all faces
sub DrawCubeTextureRec(texture as Texture2D, source as Rectangle, position as Vector3, wid as single, height as single, length as single, clr as RLColor)
    dim as single x = position.x
    dim as single y = position.y
    dim as single z = position.z
    dim as single texWidth = texture.width
    dim as single texHeight = texture.height

    '' Set desired texture to be enabled while drawing following vertex data
    rlSetTexture(texture.id)

    '' We calculate the normalized texture coordinates for the desired texture-source-rectangle
    '' It means converting from (tex.width, tex.height) coordinates to [0.0f, 1.0f] equivalent 
    rlBegin(RL_QUADS)
        rlColor4ub(clr.r, clr.g, clr.b, clr.a)

        '' Front face
        rlNormal3f(0.0f, 0.0f, 1.0f)
        rlTexCoord2f(source.x/texWidth, (source.y + source.height)/texHeight)
        rlVertex3f(x - wid/2, y - height/2, z + length/2)
        rlTexCoord2f((source.x + source.width)/texWidth, (source.y + source.height)/texHeight)
        rlVertex3f(x + wid/2, y - height/2, z + length/2)
        rlTexCoord2f((source.x + source.width)/texWidth, source.y/texHeight)
        rlVertex3f(x + wid/2, y + height/2, z + length/2)
        rlTexCoord2f(source.x/texWidth, source.y/texHeight)
        rlVertex3f(x - wid/2, y + height/2, z + length/2)

        '' Back face
        rlNormal3f(0.0f, 0.0f, - 1.0f)
        rlTexCoord2f((source.x + source.width)/texWidth, (source.y + source.height)/texHeight)
        rlVertex3f(x - wid/2, y - height/2, z - length/2)
        rlTexCoord2f((source.x + source.width)/texWidth, source.y/texHeight)
        rlVertex3f(x - wid/2, y + height/2, z - length/2)
        rlTexCoord2f(source.x/texWidth, source.y/texHeight)
        rlVertex3f(x + wid/2, y + height/2, z - length/2)
        rlTexCoord2f(source.x/texWidth, (source.y + source.height)/texHeight)
        rlVertex3f(x + wid/2, y - height/2, z - length/2)

        '' Top face
        rlNormal3f(0.0f, 1.0f, 0.0f)
        rlTexCoord2f(source.x/texWidth, source.y/texHeight)
        rlVertex3f(x - wid/2, y + height/2, z - length/2)
        rlTexCoord2f(source.x/texWidth, (source.y + source.height)/texHeight)
        rlVertex3f(x - wid/2, y + height/2, z + length/2)
        rlTexCoord2f((source.x + source.width)/texWidth, (source.y + source.height)/texHeight)
        rlVertex3f(x + wid/2, y + height/2, z + length/2)
        rlTexCoord2f((source.x + source.width)/texWidth, source.y/texHeight)
        rlVertex3f(x + wid/2, y + height/2, z - length/2)

        '' Bottom face
        rlNormal3f(0.0f, - 1.0f, 0.0f)
        rlTexCoord2f((source.x + source.width)/texWidth, source.y/texHeight)
        rlVertex3f(x - wid/2, y - height/2, z - length/2)
        rlTexCoord2f(source.x/texWidth, source.y/texHeight)
        rlVertex3f(x + wid/2, y - height/2, z - length/2)
        rlTexCoord2f(source.x/texWidth, (source.y + source.height)/texHeight)
        rlVertex3f(x + wid/2, y - height/2, z + length/2)
        rlTexCoord2f((source.x + source.width)/texWidth, (source.y + source.height)/texHeight)
        rlVertex3f(x - wid/2, y - height/2, z + length/2)

        '' Right face
        rlNormal3f(1.0f, 0.0f, 0.0f)
        rlTexCoord2f((source.x + source.width)/texWidth, (source.y + source.height)/texHeight)
        rlVertex3f(x + wid/2, y - height/2, z - length/2)
        rlTexCoord2f((source.x + source.width)/texWidth, source.y/texHeight)
        rlVertex3f(x + wid/2, y + height/2, z - length/2)
        rlTexCoord2f(source.x/texWidth, source.y/texHeight)
        rlVertex3f(x + wid/2, y + height/2, z + length/2)
        rlTexCoord2f(source.x/texWidth, (source.y + source.height)/texHeight)
        rlVertex3f(x + wid/2, y - height/2, z + length/2)

        '' Left face
        rlNormal3f( - 1.0f, 0.0f, 0.0f)
        rlTexCoord2f(source.x/texWidth, (source.y + source.height)/texHeight)
        rlVertex3f(x - wid/2, y - height/2, z - length/2)
        rlTexCoord2f((source.x + source.width)/texWidth, (source.y + source.height)/texHeight)
        rlVertex3f(x - wid/2, y - height/2, z + length/2)
        rlTexCoord2f((source.x + source.width)/texWidth, source.y/texHeight)
        rlVertex3f(x - wid/2, y + height/2, z + length/2)
        rlTexCoord2f(source.x/texWidth, source.y/texHeight)
        rlVertex3f(x - wid/2, y + height/2, z - length/2)

    rlEnd()

    rlSetTexture(0)
end sub