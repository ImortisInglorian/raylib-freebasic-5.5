/'******************************************************************************************
*
*   raylib [models] example - Skybox loading and drawing
*
*   Example originally created with raylib 1.8, last time updated with raylib 4.0
*
*   Example licensed under an unmodified zlib/libpng license, which is an OSI-certified,
*   BSD-like license that allows static linking with closed source software
*
*   Copyright (c) 2017-2024 Ramon Santamaria (@raysan5)
*
*******************************************************************************************'/

#include "../../raylib.bi"
#include "../../rlgl.bi"

#define GLSL_VERSION            330

'' Generate cubemap (6 faces) from equirectangular (panorama) texture
declare function GenTextureCubemap(shade as Shader, panorama as Texture2D, size as long, frmt as long) as TextureCubemap

''------------------------------------------------------------------------------------
'' Program main entry point
''------------------------------------------------------------------------------------
'' Initialization
''--------------------------------------------------------------------------------------
const as long screenWidth = 800
const as long screenHeight = 450

InitWindow(screenWidth, screenHeight, "raylib [models] example - skybox loading and drawing")

'' Define the camera to look into our 3d world
dim as Camera cam
with cam
    .position = Vector3(1.0f, 1.0f, 1.0f)    '' Camera position
    .target = Vector3(4.0f, 1.0f, 4.0f)      '' Camera looking at point
    .up = Vector3(0.0f, 1.0f, 0.0f)          '' Camera up vector (rotation towards target)
    .fovy = 45.0f                                '' Camera field-of-view Y
    .projection = CAMERA_PERSPECTIVE             '' Camera projection type
end with

'' Load skybox model
dim as Mesh cube = GenMeshCube(1.0f, 1.0f, 1.0f)
dim as Model skybox = LoadModelFromMesh(cube)

'' Set this to true to use an HDR Texture, Note that raylib must be built with HDR Support for this to work SUPPORT_FILEFORMAT_HDR
dim as long useHDR = RLFALSE

'' Load skybox shader and set required locations
'' NOTE: Some locations are automatically set at shader loading
skybox.materials[0].shader = LoadShader(TextFormat("resources/shaders/glsl%i/skybox.vs", GLSL_VERSION),_
                                        TextFormat("resources/shaders/glsl%i/skybox.fs", GLSL_VERSION))

dim as long MMC = MATERIAL_MAP_CUBEMAP

SetShaderValue(skybox.materials[0].shader, GetShaderLocation(skybox.materials[0].shader, "environmentMap"), @MMC, SHADER_UNIFORM_INT)
SetShaderValue(skybox.materials[0].shader, GetShaderLocation(skybox.materials[0].shader, "doGamma"), @useHDR, SHADER_UNIFORM_INT)
SetShaderValue(skybox.materials[0].shader, GetShaderLocation(skybox.materials[0].shader, "vflipped"), @useHDR, SHADER_UNIFORM_INT)

'' Load cubemap shader and setup required shader locations
dim as Shader shdrCubemap = LoadShader(TextFormat("resources/shaders/glsl%i/cubemap.vs", GLSL_VERSION),_
                                TextFormat("resources/shaders/glsl%i/cubemap.fs", GLSL_VERSION))

dim as long Zero = 0
SetShaderValue(shdrCubemap, GetShaderLocation(shdrCubemap, "equirectangularMap"), @Zero, SHADER_UNIFORM_INT)
dim as zstring * 256 skyboxFileName

if useHDR = RLTRUE then
    skyboxFileName = "resources/dresden_square_2k.hdr"

    '' Load HDR panorama (sphere) texture
    dim as Texture2D panorama = LoadTexture(skyboxFileName)

    '' Generate cubemap (texture with 6 quads-cube-mapping) from panorama HDR texture
    '' NOTE 1: New texture is generated rendering to texture, shader calculates the sphere->cube coordinates mapping
    '' NOTE 2: It seems on some Android devices WebGL, fbo does not properly support a FLOAT-based attachment,
    '' despite texture can be successfully created.. so using PIXELFORMAT_UNCOMPRESSED_R8G8B8A8 instead of PIXELFORMAT_UNCOMPRESSED_R32G32B32A32
    skybox.materials[0].maps[MATERIAL_MAP_CUBEMAP].texture = GenTextureCubemap(shdrCubemap, panorama, 1024, PIXELFORMAT_UNCOMPRESSED_R8G8B8A8)

    UnloadTexture(panorama)        '' Texture not required anymore, cubemap already generated
else
    dim as Image img = LoadImage("resources/skybox.png")
    skybox.materials[0].maps[MATERIAL_MAP_CUBEMAP].texture = LoadTextureCubemap(img, CUBEMAP_LAYOUT_AUTO_DETECT)    '' CUBEMAP_LAYOUT_PANORAMA
    UnloadImage(img)
end if

DisableCursor()                    '' Limit cursor to relative movement inside the window

SetTargetFPS(60)                   '' Set our game to run at 60 frames-per-second
''--------------------------------------------------------------------------------------

'' Main game loop
do while not WindowShouldClose()        '' Detect window close button or ESC key
    '' Update
    ''----------------------------------------------------------------------------------
    UpdateCamera(@cam, CAMERA_FIRST_PERSON)

    '' Load new cubemap texture on drag&drop
    if IsFileDropped() then
        dim as FilePathList droppedFiles = LoadDroppedFiles()

        if droppedFiles.count = 1 then         '' Only support one file dropped
            if IsFileExtension(droppedFiles.paths[0], ".png.jpg.hdr.bmp.tga") then
                '' Unload current cubemap texture to load new one
                UnloadTexture(skybox.materials[0].maps[MATERIAL_MAP_CUBEMAP].texture)
                
                if useHDR = RLTRUE then
                    '' Load HDR panorama (sphere) texture
                    dim as Texture2D panorama = LoadTexture(droppedFiles.paths[0])

                    '' Generate cubemap from panorama texture
                    skybox.materials[0].maps[MATERIAL_MAP_CUBEMAP].texture = GenTextureCubemap(shdrCubemap, panorama, 1024, PIXELFORMAT_UNCOMPRESSED_R8G8B8A8)
                    
                    UnloadTexture(panorama)    '' Texture not required anymore, cubemap already generated
                else
                    dim as Image img = LoadImage(droppedFiles.paths[0])
                    skybox.materials[0].maps[MATERIAL_MAP_CUBEMAP].texture = LoadTextureCubemap(img, CUBEMAP_LAYOUT_AUTO_DETECT)
                    UnloadImage(img)
                end if

                TextCopy(skyboxFileName, droppedFiles.paths[0])
            end if
        end if

        UnloadDroppedFiles(droppedFiles)    '' Unload filepaths from memory
    end if
    ''----------------------------------------------------------------------------------

    '' Draw
    ''----------------------------------------------------------------------------------
    BeginDrawing()

        ClearBackground(RAYWHITE)

        BeginMode3D(cam)

            '' We are inside the cube, we need to disable backface culling!
            rlDisableBackfaceCulling()
            rlDisableDepthMask()
                DrawModel(skybox, Vector3(0, 0, 0), 1.0f, WHITE)
            rlEnableBackfaceCulling()
            rlEnableDepthMask()

            DrawGrid(10, 1.0f)

        EndMode3D()

        if useHDR = RLTRUE then
            DrawText(TextFormat("Panorama image from hdrihaven.com: %s", GetFileName(skyboxFileName)), 10, GetScreenHeight() - 20, 10, BLACK)
        else
            DrawText(TextFormat(": %s", GetFileName(skyboxFileName)), 10, GetScreenHeight() - 20, 10, BLACK)
        end if

        DrawFPS(10, 10)

    EndDrawing()
    ''----------------------------------------------------------------------------------
loop

'' De-Initialization
''--------------------------------------------------------------------------------------
UnloadShader(skybox.materials[0].shader)
UnloadTexture(skybox.materials[0].maps[MATERIAL_MAP_CUBEMAP].texture)

UnloadModel(skybox)        '' Unload skybox model

CloseWindow()              '' Close window and OpenGL context
''--------------------------------------------------------------------------------------


'' Generate cubemap texture from HDR texture
function GenTextureCubemap(shade as Shader, panorama as Texture2D, size as long, frmt as long) as TextureCubemap
    dim as TextureCubemap cubemap

    rlDisableBackfaceCulling()     '' Disable backface culling to render inside the cube

    '' STEP 1: Setup framebuffer
    ''------------------------------------------------------------------------------------------
    dim as ulong rbo = rlLoadTextureDepth(size, size, true)
    cubemap.id = rlLoadTextureCubemap(0, size, frmt, 1)

    dim as ulong fbo = rlLoadFramebuffer()
    rlFramebufferAttach(fbo, rbo, RL_ATTACHMENT_DEPTH, RL_ATTACHMENT_RENDERBUFFER, 0)
    rlFramebufferAttach(fbo, cubemap.id, RL_ATTACHMENT_COLOR_CHANNEL0, RL_ATTACHMENT_CUBEMAP_POSITIVE_X, 0)

    '' Check if framebuffer is complete with attachments (valid)
    if rlFramebufferComplete(fbo) then TraceLog(LOG_INFO, "FBO: [ID %i] Framebuffer object created successfully", fbo)
    ''------------------------------------------------------------------------------------------

    '' STEP 2: Draw to framebuffer
    ''------------------------------------------------------------------------------------------
    '' NOTE: Shader is used to convert HDR equirectangular environment map to cubemap equivalent (6 faces)
    rlEnableShader(shade.id)

    '' Define projection matrix and send it to shader
    dim as Matrix matFboProjection = MatrixPerspective(90.0*DEG2RAD, 1.0, rlGetCullDistanceNear(), rlGetCullDistanceFar())
    rlSetUniformMatrix(shade.locs[SHADER_LOC_MATRIX_PROJECTION], matFboProjection)

    '' Define view matrix for every side of the cubemap
    dim as Matrix fboViews(...) = { _
        MatrixLookAt(Vector3(0.0f, 0.0f, 0.0f), Vector3( 1.0f,  0.0f,  0.0f), Vector3(0.0f, -1.0f,  0.0f)),_
        MatrixLookAt(Vector3(0.0f, 0.0f, 0.0f), Vector3(-1.0f,  0.0f,  0.0f), Vector3(0.0f, -1.0f,  0.0f)),_
        MatrixLookAt(Vector3(0.0f, 0.0f, 0.0f), Vector3( 0.0f,  1.0f,  0.0f), Vector3(0.0f,  0.0f,  1.0f)),_
        MatrixLookAt(Vector3(0.0f, 0.0f, 0.0f), Vector3( 0.0f, -1.0f,  0.0f), Vector3(0.0f,  0.0f, -1.0f)),_
        MatrixLookAt(Vector3(0.0f, 0.0f, 0.0f), Vector3( 0.0f,  0.0f,  1.0f), Vector3(0.0f, -1.0f,  0.0f)),_
        MatrixLookAt(Vector3(0.0f, 0.0f, 0.0f), Vector3( 0.0f,  0.0f, -1.0f), Vector3(0.0f, -1.0f,  0.0f))_
    }

    rlViewport(0, 0, size, size)   '' Set viewport to current fbo dimensions
    
    '' Activate and enable texture for drawing to cubemap faces
    rlActiveTextureSlot(0)
    rlEnableTexture(panorama.id)

    for i as integer = 0 to 5
        '' Set the view matrix for the current cube face
        rlSetUniformMatrix(shade.locs[SHADER_LOC_MATRIX_VIEW], fboViews(i))
        
        '' Select the current cubemap face attachment for the fbo
        '' WARNING: This function by default enables->attach->disables fbo!!!
        rlFramebufferAttach(fbo, cubemap.id, RL_ATTACHMENT_COLOR_CHANNEL0, RL_ATTACHMENT_CUBEMAP_POSITIVE_X + i, 0)
        rlEnableFramebuffer(fbo)

        '' Load and draw a cube, it uses the current enabled texture
        rlClearScreenBuffers()
        rlLoadDrawCube()

        '' ALTERNATIVE: Try to use internal batch system to draw the cube instead of rlLoadDrawCube
        '' for some reason this method does not work, maybe due to cube triangles definition? normals pointing out?
        '' TODO: Investigate this issue...
        ''rlSetTexture(panorama.id) '' WARNING: It must be called after enabling current framebuffer if using internal batch system!
        ''rlClearScreenBuffers()
        ''DrawCubeV(Vector3Zero(), Vector3One(), WHITE)
        ''rlDrawRenderBatchActive()
    next
    ''------------------------------------------------------------------------------------------

    '' STEP 3: Unload framebuffer and reset state
    ''------------------------------------------------------------------------------------------
    rlDisableShader()          '' Unbind shader
    rlDisableTexture()         '' Unbind texture
    rlDisableFramebuffer()     '' Unbind framebuffer
    rlUnloadFramebuffer(fbo)   '' Unload framebuffer (and automatically attached depth texture/renderbuffer)

    '' Reset viewport dimensions to default
    rlViewport(0, 0, rlGetFramebufferWidth(), rlGetFramebufferHeight())
    rlEnableBackfaceCulling()
    ''------------------------------------------------------------------------------------------

    cubemap.width = size
    cubemap.height = size
    cubemap.mipmaps = 1
    cubemap.format = frmt

    return cubemap
end function