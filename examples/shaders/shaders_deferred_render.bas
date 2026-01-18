/'******************************************************************************************
*
*   raylib [shaders] example - deferred rendering
*
*   NOTE: This example requires raylib OpenGL 3.3 or OpenGL ES 3.0
*
*   Example originally created with raylib 4.5, last time updated with raylib 4.5
*
*   Example contributed by Justin Andreas Lacoste (@27justin) and reviewed by Ramon Santamaria (@raysan5)
*
*   Example licensed under an unmodified zlib/libpng license, which is an OSI-certified,
*   BSD-like license that allows static linking with closed source software
*
*   Copyright (c) 2023 Justin Andreas Lacoste (@27justin)
*
*******************************************************************************************'/

#include "../../raylib.bi"
#include "../../rlgl.bi"
#include "../../rlights.bi"

#define GLSL_VERSION    330
#define NULL            0
#define MAX_CUBES       30

randomize timer

'' GBuffer data
type GBuffer
    as ulong framebuffer

    as ulong positionTexture
    as ulong normalTexture
    as ulong albedoSpecTexture
    
    as ulong depthRenderbuffer
end type

'' Deferred mode passes
type as long DeferredMode
enum
   DEFERRED_POSITION
   DEFERRED_NORMAL
   DEFERRED_ALBEDO
   DEFERRED_SHADING
end enum

'' Initialization
'' -------------------------------------------------------------------------------------
const as long screenWidth = 800
const as long screenHeight = 450

InitWindow(screenWidth, screenHeight, "raylib [shaders] example - deferred render")

dim as Camera cam
with cam
    .position = Vector3(5.0f, 4.0f, 5.0f)    '' Camera position
    .target = Vector3(0.0f, 1.0f, 0.0f)      '' Camera looking at point
    .up = Vector3(0.0f, 1.0f, 0.0f)          '' Camera up vector (rotation towards target)
    .fovy = 60.0f                            '' Camera field-of-view Y
    .projection = CAMERA_PERSPECTIVE         '' Camera projection type
end with

'' Load plane model from a generated mesh
dim as Model mdl = LoadModelFromMesh(GenMeshPlane(10.0f, 10.0f, 3, 3))
dim as Model cube = LoadModelFromMesh(GenMeshCube(2.0f, 2.0f, 2.0f))

'' Load geometry buffer (G-buffer) shader and deferred shader
dim as Shader gbufferShader = LoadShader("resources/shaders/glsl330/gbuffer.vs",_
                            "resources/shaders/glsl330/gbuffer.fs")

dim as Shader deferredShader = LoadShader("resources/shaders/glsl330/deferred_shading.vs",_
                            "resources/shaders/glsl330/deferred_shading.fs")
deferredShader.locs[SHADER_LOC_VECTOR_VIEW] = GetShaderLocation(deferredShader, "viewPosition")

'' Initialize the G-buffer
dim as GBuffer gBuffer
gBuffer.framebuffer = rlLoadFramebuffer()

if gBuffer.framebuffer = 0 then
    TraceLog(LOG_WARNING, "Failed to create framebuffer")
    end(1)
end if

rlEnableFramebuffer(gBuffer.framebuffer)

'' Since we are storing position and normal data in these textures, 
'' we need to use a floating point format.
gBuffer.positionTexture = rlLoadTexture(NULL, screenWidth, screenHeight, RL_PIXELFORMAT_UNCOMPRESSED_R32G32B32, 1)

gBuffer.normalTexture = rlLoadTexture(NULL, screenWidth, screenHeight, RL_PIXELFORMAT_UNCOMPRESSED_R32G32B32, 1)
'' Albedo (diffuse color) and specular strength can be combined into one texture.
'' The color in RGB, and the specular strength in the alpha channel.
gBuffer.albedoSpecTexture = rlLoadTexture(NULL, screenWidth, screenHeight, RL_PIXELFORMAT_UNCOMPRESSED_R8G8B8A8, 1)

'' Activate the draw buffers for our framebuffer
rlActiveDrawBuffers(3)

'' Now we attach our textures to the framebuffer.
rlFramebufferAttach(gBuffer.framebuffer, gBuffer.positionTexture, RL_ATTACHMENT_COLOR_CHANNEL0, RL_ATTACHMENT_TEXTURE2D, 0)
rlFramebufferAttach(gBuffer.framebuffer, gBuffer.normalTexture, RL_ATTACHMENT_COLOR_CHANNEL1, RL_ATTACHMENT_TEXTURE2D, 0)
rlFramebufferAttach(gBuffer.framebuffer, gBuffer.albedoSpecTexture, RL_ATTACHMENT_COLOR_CHANNEL2, RL_ATTACHMENT_TEXTURE2D, 0)

'' Finally we attach the depth buffer.
gBuffer.depthRenderbuffer = rlLoadTextureDepth(screenWidth, screenHeight, true)
rlFramebufferAttach(gBuffer.framebuffer, gBuffer.depthRenderbuffer, RL_ATTACHMENT_DEPTH, RL_ATTACHMENT_RENDERBUFFER, 0)

'' Make sure our framebuffer is complete.
'' NOTE: rlFramebufferComplete() automatically unbinds the framebuffer, so we don't have
'' to rlDisableFramebuffer() here.
if rlFramebufferComplete(gBuffer.framebuffer) = 0 then
    TraceLog(LOG_WARNING, "Framebuffer is not complete")
    end(1)
end if

'' Now we initialize the sampler2D uniform's in the deferred shader.
'' We do this by setting the uniform's value to the color channel slot we earlier
'' bound our textures to.
rlEnableShader(deferredShader.id)

    rlSetUniformSampler(rlGetLocationUniform(deferredShader.id, "gPosition"), 0)
    rlSetUniformSampler(rlGetLocationUniform(deferredShader.id, "gNormal"), 1)
    rlSetUniformSampler(rlGetLocationUniform(deferredShader.id, "gAlbedoSpec"), 2)

rlDisableShader()

'' Assign out lighting shader to model
mdl.materials[0].shader = gbufferShader
cube.materials[0].shader = gbufferShader

'' Create lights
''--------------------------------------------------------------------------------------
dim as Light lights(MAX_LIGHTS - 1)
lights(0) = CreateLight(LIGHT_POINT, Vector3(-2, 1, -2), Vector3Zero(), YELLOW, deferredShader)
lights(1) = CreateLight(LIGHT_POINT, Vector3( 2, 1,  2), Vector3Zero(), RED, deferredShader)
lights(2) = CreateLight(LIGHT_POINT, Vector3(-2, 1,  2), Vector3Zero(), GREEN, deferredShader)
lights(3) = CreateLight(LIGHT_POINT, Vector3( 2, 1, -2), Vector3Zero(), BLUE, deferredShader)

const as single CUBE_SCALE = 0.25
dim as Vector3 cubePositions(MAX_CUBES - 1)
dim as single cubeRotations(MAX_CUBES - 1)

for i as integer = 0 to MAX_CUBES - 1
    cubePositions(i) = Vector3(_
        (rnd * 10) - 5, _
        (rnd * 5), _ 
        (rnd * 10) - 5, _
    )
    
    cubeRotations(i) = rnd * 360
next

dim as DeferredMode mode = DEFERRED_SHADING

rlEnableDepthTest()

SetTargetFPS(60)                   '' Set our game to run at 60 frames-per-second
''---------------------------------------------------------------------------------------

'' Main game loop
do while not WindowShouldClose()
    '' Update
    ''----------------------------------------------------------------------------------
    UpdateCamera(@cam, CAMERA_ORBITAL)

    '' Update the shader with the camera view vector (points towards { 0.0f, 0.0f, 0.0f })
    dim as single cameraPos(...) = { cam.position.x, cam.position.y, cam.position.z }
    SetShaderValue(deferredShader, deferredShader.locs[SHADER_LOC_VECTOR_VIEW], @cameraPos(0), SHADER_UNIFORM_VEC3)
    
    '' Check key inputs to enable/disable lights
    if IsKeyPressed(KEY_Y) then lights(0).enabled = lights(0).enabled xor 1
    if IsKeyPressed(KEY_R) then lights(1).enabled = lights(1).enabled xor 1
    if IsKeyPressed(KEY_G) then lights(2).enabled = lights(2).enabled xor 1
    if IsKeyPressed(KEY_B) then lights(3).enabled = lights(3).enabled xor 1

    '' Check key inputs to switch between G-buffer textures
    if IsKeyPressed(KEY_ONE) then mode = DEFERRED_POSITION
    if IsKeyPressed(KEY_TWO) then mode = DEFERRED_NORMAL
    if IsKeyPressed(KEY_THREE) then mode = DEFERRED_ALBEDO
    if IsKeyPressed(KEY_FOUR) then mode = DEFERRED_SHADING

    '' Update light values (actually, only enable/disable them)
    for i as integer = 0 to MAX_LIGHTS - 1
        UpdateLightValues(deferredShader, lights(i))
    next
    ''----------------------------------------------------------------------------------

    '' Draw
    '' ---------------------------------------------------------------------------------
    BeginDrawing()
    
        ClearBackground(RAYWHITE)
    
        '' Draw to the geometry buffer by first activating it
        rlEnableFramebuffer(gBuffer.framebuffer)
        rlClearScreenBuffers()  '' Clear color and depth buffer
        
        rlDisableColorBlend()
        BeginMode3D(cam)
            '' NOTE: We have to use rlEnableShader here. `BeginShaderMode` or thus `rlSetShader`
            '' will not work, as they won't immediately load the shader program.
            rlEnableShader(gbufferShader.id)
                '' When drawing a model here, make sure that the material's shaders
                '' are set to the gbuffer shader!
                DrawModel(mdl, Vector3Zero(), 1.0f, WHITE)
                DrawModel(cube, Vector3(0.0, 1.0f, 0.0), 1.0f, WHITE)

                for i as integer = 0 to MAX_CUBES - 1
                    dim as Vector3 position = cubePositions(i)
                    DrawModelEx(cube, position, Vector3(1, 1, 1), cubeRotations(i), Vector3(CUBE_SCALE, CUBE_SCALE, CUBE_SCALE), WHITE)
                next

            rlDisableShader()
        EndMode3D()
        rlEnableColorBlend()

        '' Go back to the default framebuffer (0) and draw our deferred shading.
        rlDisableFramebuffer()
        rlClearScreenBuffers() '' Clear color & depth buffer
        dim as Texture2D temp
        temp.width = screenWidth
        temp.height = screenHeight

        select case mode
            case DEFERRED_SHADING
                BeginMode3D(cam)
                    rlDisableColorBlend()
                    rlEnableShader(deferredShader.id)
                        '' Activate our g-buffer textures
                        '' These will now be bound to the sampler2D uniforms `gPosition`, `gNormal`,
                        '' and `gAlbedoSpec`
                        rlActiveTextureSlot(0)
                        rlEnableTexture(gBuffer.positionTexture)
                        rlActiveTextureSlot(1)
                        rlEnableTexture(gBuffer.normalTexture)
                        rlActiveTextureSlot(2)
                        rlEnableTexture(gBuffer.albedoSpecTexture)

                        '' Finally, we draw a fullscreen quad to our default framebuffer
                        '' This will now be shaded using our deferred shader
                        rlLoadDrawQuad()
                    rlDisableShader()
                    rlEnableColorBlend()
                EndMode3D()

                '' As a last step, we now copy over the depth buffer from our g-buffer to the default framebuffer.
                rlBindFramebuffer(RL_READ_FRAMEBUFFER, gBuffer.framebuffer)
                rlBindFramebuffer(RL_DRAW_FRAMEBUFFER, 0)
                rlBlitFramebuffer(0, 0, screenWidth, screenHeight, 0, 0, screenWidth, screenHeight, &h00000100)    '' GL_DEPTH_BUFFER_BIT
                rlDisableFramebuffer()

                '' Since our shader is now done and disabled, we can draw our lights in default
                '' forward rendering
                BeginMode3D(cam)
                    rlEnableShader(rlGetShaderIdDefault())
                        for i as integer = 0 to MAX_LIGHTS - 1
                            if lights(i).enabled = 1 then
                                DrawSphereEx(lights(i).position, 0.2f, 8, 8, lights(i).color)
                            else 
                                DrawSphereWires(lights(i).position, 0.2f, 8, 8, ColorAlpha(lights(i).color, 0.3f))
                            end if
                        next
                    rlDisableShader()
                EndMode3D()
                
                DrawText("FINAL RESULT", 10, screenHeight - 30, 20, DARKGREEN)
            case DEFERRED_POSITION
                temp.id = gBuffer.positionTexture
                DrawTextureRec(temp, Rectangle(0, 0, screenWidth, -screenHeight), Vector2Zero(), RAYWHITE)
                
                DrawText("POSITION TEXTURE", 10, screenHeight - 30, 20, DARKGREEN)
            case DEFERRED_NORMAL
                temp.id = gBuffer.normalTexture
                DrawTextureRec(temp, Rectangle(0, 0, screenWidth, -screenHeight), Vector2Zero(), RAYWHITE)
                
                DrawText("NORMAL TEXTURE", 10, screenHeight - 30, 20, DARKGREEN)
            case DEFERRED_ALBEDO
                temp.id = gBuffer.albedoSpecTexture
                DrawTextureRec(temp, Rectangle(0, 0, screenWidth, -screenHeight ), Vector2Zero(), RAYWHITE)
                
                DrawText("ALBEDO TEXTURE", 10, screenHeight - 30, 20, DARKGREEN)
        end select

        DrawText("Toggle lights keys: [Y][R][G][B]", 10, 40, 20, DARKGRAY)
        DrawText("Switch G-buffer textures: [1][2][3][4]", 10, 70, 20, DARKGRAY)

        DrawFPS(10, 10)
        
    EndDrawing()
    '' -----------------------------------------------------------------------------
loop

'' De-Initialization
''--------------------------------------------------------------------------------------
UnloadModel(mdl)     '' Unload the models
UnloadModel(cube)

UnloadShader(deferredShader) '' Unload shaders
UnloadShader(gbufferShader)

'' Unload geometry buffer and all attached textures
rlUnloadFramebuffer(gBuffer.framebuffer)
rlUnloadTexture(@gBuffer.positionTexture)
rlUnloadTexture(@gBuffer.normalTexture)
rlUnloadTexture(@gBuffer.albedoSpecTexture)
rlUnloadTexture(@gBuffer.depthRenderbuffer)

CloseWindow()          '' Close window and OpenGL context
''--------------------------------------------------------------------------------------