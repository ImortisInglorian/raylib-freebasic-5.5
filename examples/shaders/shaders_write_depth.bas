/'******************************************************************************************
*
*   raylib [shaders] example - Depth buffer writing
*
*   Example originally created with raylib 4.2, last time updated with raylib 4.2
*
*   Example contributed by Buğra Alptekin Sarı (@BugraAlptekinSari) and reviewed by Ramon Santamaria (@raysan5)
*
*   Example licensed under an unmodified zlib/libpng license, which is an OSI-certified,
*   BSD-like license that allows static linking with closed source software
*
*   Copyright (c) 2022-2024 Buğra Alptekin Sarı (@BugraAlptekinSari)
*
*******************************************************************************************'/

#include "../../raylib.bi"
#include "../../rlgl.bi"

#define GLSL_VERSION            330

''------------------------------------------------------------------------------------
'' Declare custom functions required for the example
''------------------------------------------------------------------------------------
'' Load custom render texture, create a writable depth texture buffer
declare function LoadRenderTextureDepthTex(wid as long, height as long) as RenderTexture2D

'' Unload render texture from GPU memory (VRAM)
declare sub UnloadRenderTextureDepthTex(target as RenderTexture2D) 

''------------------------------------------------------------------------------------
'' Program main entry point
''------------------------------------------------------------------------------------
'' Initialization
''--------------------------------------------------------------------------------------
const as long screenWidth = 800
const as long screenHeight = 450

InitWindow(screenWidth, screenHeight, "raylib [shaders] example - write depth buffer")

'' The shader inverts the depth buffer by writing into it by `gl_FragDepth = 1 - gl_FragCoord.z`
dim as Shader shade = LoadShader(0, TextFormat("resources/shaders/glsl%i/write_depth.fs", GLSL_VERSION))

'' Use Customized function to create writable depth texture buffer
dim as RenderTexture2D target = LoadRenderTextureDepthTex(screenWidth, screenHeight)

'' Define the camera to look into our 3d world
dim as Camera cam
with cam
    .position = Vector3(2.0f, 2.0f, 3.0f)    '' Camera position
    .target = Vector3(0.0f, 0.5f, 0.0f)      '' Camera looking at point
    .up = Vector3(0.0f, 1.0f, 0.0f)          '' Camera up vector (rotation towards target)
    .fovy = 45.0f                                '' Camera field-of-view Y
    .projection = CAMERA_PERSPECTIVE              '' Camera projection type
end with

SetTargetFPS(60)                   '' Set our game to run at 60 frames-per-second
''--------------------------------------------------------------------------------------

'' Main game loop
do while not WindowShouldClose()        '' Detect window close button or ESC key
    '' Update
    ''----------------------------------------------------------------------------------
    UpdateCamera(@cam, CAMERA_ORBITAL)
    ''----------------------------------------------------------------------------------
    
    '' Draw
    ''----------------------------------------------------------------------------------
    
    '' Draw into our custom render texture (framebuffer)
    BeginTextureMode(target)
        ClearBackground(WHITE)
        
        BeginMode3D(cam)
            BeginShaderMode(shade)
                DrawCubeWiresV(Vector3(0.0f, 0.5f, 1.0f), Vector3(1.0f, 1.0f, 1.0f), RED)
                DrawCubeV(Vector3(0.0f, 0.5f, 1.0f), Vector3(1.0f, 1.0f, 1.0f), PURPLE)
                DrawCubeWiresV(Vector3(0.0f, 0.5f, -1.0f), Vector3(1.0f, 1.0f, 1.0f), DARKGREEN)
                DrawCubeV(Vector3(0.0f, 0.5f, -1.0f), Vector3(1.0f, 1.0f, 1.0f), YELLOW)
                DrawGrid(10, 1.0f)
            EndShaderMode()
        EndMode3D()
    EndTextureMode()

    '' Draw into screen our custom render texture 
    BeginDrawing()
        ClearBackground(RAYWHITE)
    
        DrawTextureRec(target.texture, Rectangle(0, 0, screenWidth, -screenHeight), Vector2(0, 0), WHITE)
        DrawFPS(10, 10)
    EndDrawing()
    ''----------------------------------------------------------------------------------
loop

'' De-Initialization
''--------------------------------------------------------------------------------------
UnloadRenderTextureDepthTex(target)
UnloadShader(shade)

CloseWindow()        '' Close window and OpenGL context
''--------------------------------------------------------------------------------------

''------------------------------------------------------------------------------------
'' Define custom functions required for the example
''------------------------------------------------------------------------------------
'' Load custom render texture, create a writable depth texture buffer
function LoadRenderTextureDepthTex(wid as long, height as long) as RenderTexture2D
    dim as RenderTexture2D target

    target.id = rlLoadFramebuffer() '' Load an empty framebuffer

    if target.id > 0 then
        rlEnableFramebuffer(target.id)

        '' Create color texture (default to RGBA)
        target.texture.id = rlLoadTexture(0, wid, height, PIXELFORMAT_UNCOMPRESSED_R8G8B8A8, 1)
        target.texture.width = wid
        target.texture.height = height
        target.texture.format = PIXELFORMAT_UNCOMPRESSED_R8G8B8A8
        target.texture.mipmaps = 1

        '' Create depth texture buffer (instead of raylib default renderbuffer)
        target.depth.id = rlLoadTextureDepth(wid, height, false)
        target.depth.width = wid
        target.depth.height = height
        target.depth.format = 19       ''DEPTH_COMPONENT_24BIT?
        target.depth.mipmaps = 1

        '' Attach color texture and depth texture to FBO
        rlFramebufferAttach(target.id, target.texture.id, RL_ATTACHMENT_COLOR_CHANNEL0, RL_ATTACHMENT_TEXTURE2D, 0)
        rlFramebufferAttach(target.id, target.depth.id, RL_ATTACHMENT_DEPTH, RL_ATTACHMENT_TEXTURE2D, 0)

        '' Check if fbo is complete with attachments (valid)
        if rlFramebufferComplete(target.id) then TRACELOG(LOG_INFO, "FBO: [ID %i] Framebuffer object created successfully", target.id)

        rlDisableFramebuffer()
    else 
        TRACELOG(LOG_WARNING, "FBO: Framebuffer object can not be created")
    end if

    return target
end function

'' Unload render texture from GPU memory (VRAM)
sub UnloadRenderTextureDepthTex(target as RenderTexture2D) 
    if target.id > 0 then
        '' Color texture attached to FBO is deleted
        rlUnloadTexture(@target.texture.id)
        rlUnloadTexture(@target.depth.id)

        '' NOTE: Depth texture is automatically
        '' queried and deleted before deleting framebuffer
        rlUnloadFramebuffer(target.id)
    end if
end sub