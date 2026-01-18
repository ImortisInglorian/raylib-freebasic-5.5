/'******************************************************************************************
*
*   raylib [shaders] example - Shadowmap
*
*   Example originally created with raylib 5.0, last time updated with raylib 5.0
*
*   Example contributed by @TheManTheMythTheGameDev and reviewed by Ramon Santamaria (@raysan5)
*
*   Example licensed under an unmodified zlib/libpng license, which is an OSI-certified,
*   BSD-like license that allows static linking with closed source software
*
*******************************************************************************************'/

#include "../../raylib.bi"
#include "../../rlgl.bi"

#define GLSL_VERSION            330

#define SHADOWMAP_RESOLUTION 1024

declare function LoadShadowmapRenderTexture(wid as long, height as long) as RenderTexture2D
declare sub UnloadShadowmapRenderTexture(target as RenderTexture2D)
declare sub DrawScene(cube as Model, robot as Model)

''------------------------------------------------------------------------------------
'' Program main entry point
''------------------------------------------------------------------------------------
'' Initialization
''--------------------------------------------------------------------------------------
const as long screenWidth = 800
const as long screenHeight = 450

SetConfigFlags(FLAG_MSAA_4X_HINT)
'' Shadows are a HUGE topic, and this example shows an extremely simple implementation of the shadowmapping algorithm,
'' which is the industry standard for shadows. This algorithm can be extended in a ridiculous number of ways to improve
'' realism and also adapt it for different scenes. This is pretty much the simplest possible implementation.
InitWindow(screenWidth, screenHeight, "raylib [shaders] example - shadowmap")

dim as Camera3D cam
with cam
    .position = Vector3(10.0f, 10.0f, 10.0f)
    .target = Vector3Zero()
    .projection = CAMERA_PERSPECTIVE
    .up = Vector3(0.0f, 1.0f, 0.0f)
    .fovy = 45.0f
end with

dim as Shader shadowShader = LoadShader(TextFormat("resources/shaders/glsl%i/shadowmap.vs", GLSL_VERSION), _
                                    TextFormat("resources/shaders/glsl%i/shadowmap.fs", GLSL_VERSION))
shadowShader.locs[SHADER_LOC_VECTOR_VIEW] = GetShaderLocation(shadowShader, "viewPos")
dim as Vector3 lightDir = Vector3Normalize(Vector3(0.35f, -1.0f, -0.35f))
dim as RLColor lightColor = WHITE
dim as Vector4 lightColorNormalized = ColorNormalize(lightColor)
dim as long lightDirLoc = GetShaderLocation(shadowShader, "lightDir")
dim as long lightColLoc = GetShaderLocation(shadowShader, "lightColor")

SetShaderValue(shadowShader, lightDirLoc, @lightDir, SHADER_UNIFORM_VEC3)
SetShaderValue(shadowShader, lightColLoc, @lightColorNormalized, SHADER_UNIFORM_VEC4)
dim as long ambientLoc = GetShaderLocation(shadowShader, "ambient")
dim as single ambient(...) = {0.1f, 0.1f, 0.1f, 1.0f}
SetShaderValue(shadowShader, ambientLoc, @ambient(0), SHADER_UNIFORM_VEC4)
dim as long lightVPLoc = GetShaderLocation(shadowShader, "lightVP")
dim as long shadowMapLoc = GetShaderLocation(shadowShader, "shadowMap")
dim as long shadowMapResolution = SHADOWMAP_RESOLUTION
SetShaderValue(shadowShader, GetShaderLocation(shadowShader, "shadowMapResolution"), @shadowMapResolution, SHADER_UNIFORM_INT)

dim as Model cube = LoadModelFromMesh(GenMeshCube(1.0f, 1.0f, 1.0f))
cube.materials[0].shader = shadowShader
dim as Model robot = LoadModel("resources/models/robot.glb")
for i as integer = 0 to robot.materialCount - 1
    robot.materials[i].shader = shadowShader
next
dim as long animCount = 0
dim as ModelAnimation ptr robotAnimations = LoadModelAnimations("resources/models/robot.glb", @animCount)

dim as RenderTexture2D shadowMap = LoadShadowmapRenderTexture(SHADOWMAP_RESOLUTION, SHADOWMAP_RESOLUTION)
'' For the shadowmapping algorithm, we will be rendering everything from the light's point of view
dim as Camera3D lightCam
with lightCam
    .position = Vector3Scale(lightDir, -15.0f)
    .target = Vector3Zero()
    '' Use an orthographic projection for directional lights
    .projection = CAMERA_ORTHOGRAPHIC
    .up = Vector3(0.0f, 1.0f, 0.0f)
    .fovy = 20.0f
end with

SetTargetFPS(60)
''--------------------------------------------------------------------------------------
dim as long fc = 0

'' Main game loop
do while not WindowShouldClose()    '' Detect window close button or ESC key
    '' Update
    ''----------------------------------------------------------------------------------
    dim as single dt = GetFrameTime()

    dim as Vector3 cameraPos = cam.position
    SetShaderValue(shadowShader, shadowShader.locs[SHADER_LOC_VECTOR_VIEW], @cameraPos, SHADER_UNIFORM_VEC3)
    UpdateCamera(@cam, CAMERA_ORBITAL)

    fc += 1
    fc mod= robotAnimations[0].frameCount
    UpdateModelAnimation(robot, robotAnimations[0], fc)

    dim as single cameraSpeed = 0.05f
    if IsKeyDown(KEY_LEFT) then
        if lightDir.x < 0.6f then lightDir.x += cameraSpeed * 60.0f * dt
    end if
    if IsKeyDown(KEY_RIGHT) then
        if lightDir.x > -0.6f then lightDir.x -= cameraSpeed * 60.0f * dt
    end if
    if IsKeyDown(KEY_UP) then
        if lightDir.z < 0.6f then lightDir.z += cameraSpeed * 60.0f * dt
    end if
    if IsKeyDown(KEY_DOWN) then
        if lightDir.z > -0.6f then lightDir.z -= cameraSpeed * 60.0f * dt
    end if
    lightDir = Vector3Normalize(lightDir)
    lightCam.position = Vector3Scale(lightDir, -15.0f)
    SetShaderValue(shadowShader, lightDirLoc, @lightDir, SHADER_UNIFORM_VEC3)

    '' Draw
    ''----------------------------------------------------------------------------------
    BeginDrawing()
        '' First, render all objects into the shadowmap
        '' The idea is, we record all the objects' depths (as rendered from the light source's point of view) in a buffer
        '' Anything that is "visible" to the light is in light, anything that isn't is in shadow
        '' We can later use the depth buffer when rendering everything from the player's point of view
        '' to determine whether a given point is "visible" to the light

        '' Record the light matrices for future use!
        dim as Matrix lightView
        dim as Matrix lightProj
        BeginTextureMode(shadowMap)
            ClearBackground(WHITE)
            BeginMode3D(lightCam)
                lightView = rlGetMatrixModelview()
                lightProj = rlGetMatrixProjection()
                DrawScene(cube, robot)
            EndMode3D()
        EndTextureMode()
        dim as Matrix lightViewProj = MatrixMultiply(lightView, lightProj)

        ClearBackground(RAYWHITE)

        SetShaderValueMatrix(shadowShader, lightVPLoc, lightViewProj)

        rlEnableShader(shadowShader.id)
        dim as long slot = 10 '' Can be anything 0 to 15, but 0 will probably be taken up
        rlActiveTextureSlot(10)
        rlEnableTexture(shadowMap.depth.id)
        rlSetUniform(shadowMapLoc, @slot, SHADER_UNIFORM_INT, 1)

        BeginMode3D(cam)

            '' Draw the same exact things as we drew in the shadowmap!
            DrawScene(cube, robot)
        
        EndMode3D()

        DrawText("Shadows in raylib using the shadowmapping algorithm!", screenWidth - 320, screenHeight - 20, 10, GRAY)
        DrawText("Use the arrow keys to rotate the light!", 10, 10, 30, RED)

    EndDrawing()

    if IsKeyPressed(KEY_F) then
        TakeScreenshot("shaders_shadowmap.png")
    end if
    ''----------------------------------------------------------------------------------
loop

'' De-Initialization
''--------------------------------------------------------------------------------------

UnloadShader(shadowShader)
UnloadModel(cube)
UnloadModel(robot)
UnloadModelAnimations(robotAnimations, animCount)
UnloadShadowmapRenderTexture(shadowMap)

CloseWindow()        '' Close window and OpenGL context
''--------------------------------------------------------------------------------------

function LoadShadowmapRenderTexture(wid as long, height as long) as RenderTexture2D
    dim as RenderTexture2D target

    target.id = rlLoadFramebuffer() '' Load an empty framebuffer
    target.texture.width = wid
    target.texture.height = height

    if target.id > 0 then
        rlEnableFramebuffer(target.id)

        '' Create depth texture
        '' We don't need a color texture for the shadowmap
        target.depth.id = rlLoadTextureDepth(wid, height, RLFALSE)
        target.depth.width = wid
        target.depth.height = height
        target.depth.format = 19       ''DEPTH_COMPONENT_24BIT?
        target.depth.mipmaps = 1

        '' Attach depth texture to FBO
        rlFramebufferAttach(target.id, target.depth.id, RL_ATTACHMENT_DEPTH, RL_ATTACHMENT_TEXTURE2D, 0)

        '' Check if fbo is complete with attachments (valid)
        if rlFramebufferComplete(target.id) then TRACELOG(LOG_INFO, "FBO: [ID %i] Framebuffer object created successfully", target.id)

        rlDisableFramebuffer()
    else 
        TRACELOG(LOG_WARNING, "FBO: Framebuffer object can not be created")
    end if

    return target
end function

'' Unload shadowmap render texture from GPU memory (VRAM)
sub UnloadShadowmapRenderTexture(target as RenderTexture2D)
    if target.id > 0 then
        '' NOTE: Depth texture/renderbuffer is automatically
        '' queried and deleted before deleting framebuffer
        rlUnloadFramebuffer(target.id)
    end if
end sub

sub DrawScene(cube as Model, robot as Model)
    DrawModelEx(cube, Vector3Zero(), Vector3(0.0f, 1.0f, 0.0f), 0.0f, Vector3(10.0f, 1.0f, 10.0f), BLUE)
    DrawModelEx(cube, Vector3(1.5f, 1.0f, -1.5f), Vector3(0.0f, 1.0f, 0.0f), 0.0f, Vector3One(), WHITE)
    DrawModelEx(robot, Vector3(0.0f, 0.5f, 0.0f), Vector3(0.0f, 1.0f, 0.0f), 0.0f, Vector3(1.0f, 1.0f, 1.0f), RED)
end sub