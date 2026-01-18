/'******************************************************************************************
*
*   raylib [shaders] example - Basic PBR
*
*   Example originally created with raylib 5.0, last time updated with raylib 5.1-dev
*
*   Example contributed by Afan OLOVCIC (@_DevDad) and reviewed by Ramon Santamaria (@raysan5)
*
*   Example licensed under an unmodified zlib/libpng license, which is an OSI-certified,
*   BSD-like license that allows static linking with closed source software
*
*   Copyright (c) 2023-2024 Afan OLOVCIC (@_DevDad)
*
*   Model: "Old Rusty Car" (https:''skfb.ly/LxRy) by Renafox, 
*   licensed under Creative Commons Attribution-NonCommercial 
*   (http:''creativecommons.org/licenses/by-nc/4.0/)
*
*******************************************************************************************'/

#include "../../raylib.bi"
#define GLSL_VERSION            330
#define NULL 0
#define MAX_LIGHTS  4           '' Max dynamic lights supported by shader

''----------------------------------------------------------------------------------
'' Types and Structures Definition
''----------------------------------------------------------------------------------

'' Light type
dim as long LightType
enum
    LIGHT_DIRECTIONAL = 0
    LIGHT_POINT
    LIGHT_SPOT
end enum

'' Light data
type Light
    as long type
    as long enabled
    as Vector3 position
    as Vector3 target
    as single color(3)
    as single intensity

    '' Shader light parameters locations
    as long typeLoc
    as long enabledLoc
    as long positionLoc
    as long targetLoc
    as long colorLoc
    as long intensityLoc
end type

''----------------------------------------------------------------------------------
'' Global Variables Definition
''----------------------------------------------------------------------------------
dim shared as long lightCount = 0     '' Current number of dynamic lights that have been created

''----------------------------------------------------------------------------------
'' Module specific Functions Declaration
''----------------------------------------------------------------------------------
'' Create a light and get shader locations
declare function CreateLight(typ as long, position as Vector3, target as Vector3, clr as RLColor, intensity as single, shade as Shader) as Light

'' Update light properties on shader
'' NOTE: Light shader locations should be available
declare sub UpdateLight(shade as Shader, lght as Light)

''----------------------------------------------------------------------------------
'' Main Entry Point
''----------------------------------------------------------------------------------
'' Initialization
''--------------------------------------------------------------------------------------
const as long screenWidth = 800
const as long screenHeight = 450

dim as Shader NullShader
SetConfigFlags(FLAG_MSAA_4X_HINT)
InitWindow(screenWidth, screenHeight, "raylib [shaders] example - basic pbr")

'' Define the camera to look into our 3d world
dim as Camera cam
with cam
    .position = Vector3(2.0f, 2.0f, 6.0f)    '' Camera position
    .target = Vector3(0.0f, 0.5f, 0.0f)      '' Camera looking at point
    .up = Vector3(0.0f, 1.0f, 0.0f)          '' Camera up vector (rotation towards target)
    .fovy = 45.0f                            '' Camera field-of-view Y
    .projection = CAMERA_PERSPECTIVE         '' Camera projection type
end with

'' Load PBR shader and setup all required locations
dim as Shader shade = LoadShader(TextFormat("resources/shaders/glsl%i/pbr.vs", GLSL_VERSION),_
                            TextFormat("resources/shaders/glsl%i/pbr.fs", GLSL_VERSION))
shade.locs[SHADER_LOC_MAP_ALBEDO] = GetShaderLocation(shade, "albedoMap")
'' WARNING: Metalness, roughness, and ambient occlusion are all packed into a MRA texture
'' They are passed as to the SHADER_LOC_MAP_METALNESS location for convenience,
'' shader already takes care of it accordingly
shade.locs[SHADER_LOC_MAP_METALNESS] = GetShaderLocation(shade, "mraMap")
shade.locs[SHADER_LOC_MAP_NORMAL] = GetShaderLocation(shade, "normalMap")
'' WARNING: Similar to the MRA map, the emissive map packs different information 
'' into a single texture: it stores height and emission data
'' It is binded to SHADER_LOC_MAP_EMISSION location an properly processed on shader
shade.locs[SHADER_LOC_MAP_EMISSION] = GetShaderLocation(shade, "emissiveMap")
shade.locs[SHADER_LOC_COLOR_DIFFUSE] = GetShaderLocation(shade, "albedoColor")

'' Setup additional required shader locations, including lights data
shade.locs[SHADER_LOC_VECTOR_VIEW] = GetShaderLocation(shade, "viewPos")
dim as long lightCountLoc = GetShaderLocation(shade, "numOfLights")
dim as long maxLightCount = MAX_LIGHTS
SetShaderValue(shade, lightCountLoc, @maxLightCount, SHADER_UNIFORM_INT)

'' Setup ambient color and intensity parameters
dim as single ambientIntensity = 0.02f
dim as RLColor ambientColor = RLColor(26, 32, 135, 255)
dim as Vector3 ambientColorNormalized = Vector3(ambientColor.r / 255.0f, ambientColor.g / 255.0f, ambientColor.b / 255.0)
SetShaderValue(shade, GetShaderLocation(shade, "ambientColor"), @ambientColorNormalized, SHADER_UNIFORM_VEC3)
SetShaderValue(shade, GetShaderLocation(shade, "ambient"), @ambientIntensity, SHADER_UNIFORM_FLOAT)

'' Get location for shader parameters that can be modified in real time
dim as long emissiveIntensityLoc = GetShaderLocation(shade, "emissivePower")
dim as long emissiveColorLoc = GetShaderLocation(shade, "emissiveColor")
dim as long textureTilingLoc = GetShaderLocation(shade, "tiling")

'' Load old car model using PBR maps and shader
'' WARNING: We know this model consists of a single model.meshes[0] and
'' that model.materials[0] is by default assigned to that mesh
'' There could be more complex models consisting of multiple meshes and
'' multiple materials defined for those meshes... but always 1 mesh = 1 material
dim as Model car = LoadModel("resources/models/old_car_new.glb")

'' Assign already setup PBR shade to model.materials[0], used by models.meshes[0]
car.materials[0].shader = shade

'' Setup materials[0].maps default parameters
car.materials[0].maps[MATERIAL_MAP_ALBEDO].color = WHITE
car.materials[0].maps[MATERIAL_MAP_METALNESS].value = 0.0f
car.materials[0].maps[MATERIAL_MAP_ROUGHNESS].value = 0.0f
car.materials[0].maps[MATERIAL_MAP_OCCLUSION].value = 1.0f
car.materials[0].maps[MATERIAL_MAP_EMISSION].color = RLColor(255, 162, 0, 255)

'' Setup materials[0].maps default textures
car.materials[0].maps[MATERIAL_MAP_ALBEDO].texture = LoadTexture("resources/old_car_d.png")
car.materials[0].maps[MATERIAL_MAP_METALNESS].texture = LoadTexture("resources/old_car_mra.png")
car.materials[0].maps[MATERIAL_MAP_NORMAL].texture = LoadTexture("resources/old_car_n.png")
car.materials[0].maps[MATERIAL_MAP_EMISSION].texture = LoadTexture("resources/old_car_e.png")

'' Load floor model mesh and assign material parameters
'' NOTE: A basic plane shape can be generated instead of being loaded from a model file
dim as Model floorMod = LoadModel("resources/models/plane.glb")
''Mesh floorMesh = GenMeshPlane(10, 10, 10, 10)
''GenMeshTangents(&floorMesh)      '' TODO: Review tangents generation
''Model floor = LoadModelFromMesh(floorMesh)

'' Assign material shader for our floor model, same PBR shader 
floorMod.materials[0].shader = shade

floorMod.materials[0].maps[MATERIAL_MAP_ALBEDO].color = WHITE
floorMod.materials[0].maps[MATERIAL_MAP_METALNESS].value = 0.0f
floorMod.materials[0].maps[MATERIAL_MAP_ROUGHNESS].value = 0.0f
floorMod.materials[0].maps[MATERIAL_MAP_OCCLUSION].value = 1.0f
floorMod.materials[0].maps[MATERIAL_MAP_EMISSION].color = BLACK

floorMod.materials[0].maps[MATERIAL_MAP_ALBEDO].texture = LoadTexture("resources/road_a.png")
floorMod.materials[0].maps[MATERIAL_MAP_METALNESS].texture = LoadTexture("resources/road_mra.png")
floorMod.materials[0].maps[MATERIAL_MAP_NORMAL].texture = LoadTexture("resources/road_n.png")

'' Models texture tiling parameter can be stored in the Material struct if required (CURRENTLY NOT USED)
'' NOTE: Material.params[4] are available for generic parameters storage (float)
dim as Vector2 carTextureTiling = Vector2(0.5f, 0.5f)
dim as Vector2 floorTextureTiling = Vector2(0.5f, 0.5f)

'' Create some lights
dim as Light lights(MAX_LIGHTS - 1)
lights(0) = CreateLight(LIGHT_POINT, Vector3(-1.0f, 1.0f, -2.0f), Vector3(0.0f, 0.0f, 0.0f), YELLOW, 4.0f, shade)
lights(1) = CreateLight(LIGHT_POINT, Vector3(2.0f, 1.0f, 1.0f), Vector3(0.0f, 0.0f, 0.0f), GREEN, 3.3f, shade)
lights(2) = CreateLight(LIGHT_POINT, Vector3(-2.0f, 1.0f, 1.0f), Vector3(0.0f, 0.0f, 0.0f), RED, 8.3f, shade)
lights(3) = CreateLight(LIGHT_POINT, Vector3(1.0f, 1.0f, -2.0f), Vector3(0.0f, 0.0f, 0.0f), BLUE, 2.0f, shade)

'' Setup material texture maps usage in shader
'' NOTE: By default, the texture maps are always used
dim as long usage = 1
SetShaderValue(shade, GetShaderLocation(shade, "useTexAlbedo"), @usage, SHADER_UNIFORM_INT)
SetShaderValue(shade, GetShaderLocation(shade, "useTexNormal"), @usage, SHADER_UNIFORM_INT)
SetShaderValue(shade, GetShaderLocation(shade, "useTexMRA"), @usage, SHADER_UNIFORM_INT)
SetShaderValue(shade, GetShaderLocation(shade, "useTexEmissive"), @usage, SHADER_UNIFORM_INT)

SetTargetFPS(60)                   '' Set our game to run at 60 frames-per-second
''---------------------------------------------------------------------------------------

'' Main game loop
do while not WindowShouldClose()    '' Detect window close button or ESC key
    '' Update
    ''----------------------------------------------------------------------------------
    UpdateCamera(@cam, CAMERA_ORBITAL)

    '' Update the shader with the camera view vector (points towards { 0.0f, 0.0f, 0.0f })
    dim as single cameraPos(...) = {cam.position.x, cam.position.y, cam.position.z}
    SetShaderValue(shade, shade.locs[SHADER_LOC_VECTOR_VIEW], @cameraPos(0), SHADER_UNIFORM_VEC3)

    '' Check key inputs to enable/disable lights
    if IsKeyPressed(KEY_ONE) then lights(2).enabled = lights(2).enabled xor 1
    if IsKeyPressed(KEY_TWO) then lights(1).enabled = lights(1).enabled xor 1
    if IsKeyPressed(KEY_THREE) then lights(3).enabled = lights(3).enabled xor 1
    if IsKeyPressed(KEY_FOUR) then lights(0).enabled = lights(0).enabled xor 1

    '' Update light values on shader (actually, only enable/disable them)
    for i as integer = 0 to MAX_LIGHTS - 1
        UpdateLight(shade, lights(i))
    next
    ''----------------------------------------------------------------------------------

    '' Draw
    ''----------------------------------------------------------------------------------
    BeginDrawing()
    
        ClearBackground(BLACK)
        
        BeginMode3D(cam)
            
            '' Set floor model texture tiling and emissive color parameters on shader
            SetShaderValue(shade, textureTilingLoc, @floorTextureTiling, SHADER_UNIFORM_VEC2)
            dim as Vector4 floorEmissiveColor = ColorNormalize(floorMod.materials[0].maps[MATERIAL_MAP_EMISSION].color)
            SetShaderValue(shade, emissiveColorLoc, @floorEmissiveColor, SHADER_UNIFORM_VEC4)
            
            DrawModel(floorMod, Vector3(0.0f, 0.0f, 0.0f), 5.0f, WHITE)   '' Draw floor model

            '' Set old car model texture tiling, emissive color and emissive intensity parameters on shader
            SetShaderValue(shade, textureTilingLoc, @carTextureTiling, SHADER_UNIFORM_VEC2)
            dim as Vector4 carEmissiveColor = ColorNormalize(car.materials[0].maps[MATERIAL_MAP_EMISSION].color)
            SetShaderValue(shade, emissiveColorLoc, @carEmissiveColor, SHADER_UNIFORM_VEC4)
            dim as single emissiveIntensity = 0.01f
            SetShaderValue(shade, emissiveIntensityLoc, @emissiveIntensity, SHADER_UNIFORM_FLOAT)
            
            DrawModel(car, Vector3(0.0f, 0.0f, 0.0f), 0.25f, WHITE)   '' Draw car model

            '' Draw spheres to show the lights positions
            for i as integer = 0 to MAX_LIGHTS - 1
                dim as RLColor lightColor = RLColor(lights(i).color(0) * 255, lights(i).color(1) * 255, lights(i).color(2) * 255, lights(i).color(3) * 255)
                
                if lights(i).enabled = 1 then
                    DrawSphereEx(lights(i).position, 0.2f, 8, 8, lightColor)
                else 
                    DrawSphereWires(lights(i).position, 0.2f, 8, 8, ColorAlpha(lightColor, 0.3f))
                end if
            next
            
        EndMode3D()
        
        DrawText("Toggle lights: [1][2][3][4]", 10, 40, 20, LIGHTGRAY)

        DrawText("(c) Old Rusty Car model by Renafox (https:''skfb.ly/LxRy)", screenWidth - 320, screenHeight - 20, 10, LIGHTGRAY)
        
        DrawFPS(10, 10)

    EndDrawing()
    ''----------------------------------------------------------------------------------
loop

'' De-Initialization
''--------------------------------------------------------------------------------------
'' Unbind (disconnect) shader from car.material[0] 
'' to avoid UnloadMaterial() trying to unload it automatically
car.materials[0].shader = NullShader
UnloadMaterial(car.materials[0])
car.materials[0].maps = NULL
UnloadModel(car)

floorMod.materials[0].shader = NullShader
UnloadMaterial(floorMod.materials[0])
floorMod.materials[0].maps = NULL
UnloadModel(floorMod)

UnloadShader(shade)       '' Unload Shader

CloseWindow()              '' Close window and OpenGL context
''--------------------------------------------------------------------------------------

'' Create light with provided data
'' NOTE: It updated the global lightCount and it's limited to MAX_LIGHTS
function CreateLight(typ as long, position as Vector3, target as Vector3, clr as RLColor, intensity as single, shade as Shader) as Light
    dim as Light lght

    if lightCount < MAX_LIGHTS then
        lght.enabled = 1
        lght.type = typ
        lght.position = position
        lght.target = target
        lght.color(0) = clr.r/255.0f
        lght.color(1) = clr.g/255.0f
        lght.color(2) = clr.b/255.0f
        lght.color(3) = clr.a/255.0f
        lght.intensity = intensity
        
        '' NOTE: Shader parameters names for lights must match the requested ones
        lght.enabledLoc = GetShaderLocation(shade, TextFormat("lights[%i].enabled", lightCount))
        lght.typeLoc = GetShaderLocation(shade, TextFormat("lights[%i].type", lightCount))
        lght.positionLoc = GetShaderLocation(shade, TextFormat("lights[%i].position", lightCount))
        lght.targetLoc = GetShaderLocation(shade, TextFormat("lights[%i].target", lightCount))
        lght.colorLoc = GetShaderLocation(shade, TextFormat("lights[%i].color", lightCount))
        lght.intensityLoc = GetShaderLocation(shade, TextFormat("lights[%i].intensity", lightCount))
        
        UpdateLight(shade, lght)

        lightCount += 1
    end if

    return light
end function

'' Send light properties to shader
'' NOTE: Light shader locations should be available
sub UpdateLight(shade as Shader, lght as Light)
    SetShaderValue(shade, lght.enabledLoc, @lght.enabled, SHADER_UNIFORM_INT)
    SetShaderValue(shade, lght.typeLoc, @lght.type, SHADER_UNIFORM_INT)
    
    '' Send to shader light position values
    dim as single position(...) = { lght.position.x, lght.position.y, lght.position.z }
    SetShaderValue(shade, lght.positionLoc, @position(0), SHADER_UNIFORM_VEC3)

    '' Send to shader light target position values
    dim as single target(...) = { lght.target.x, lght.target.y, lght.target.z }
    SetShaderValue(shade, lght.targetLoc, @target(0), SHADER_UNIFORM_VEC3)
    SetShaderValue(shade, lght.colorLoc, @lght.color(0), SHADER_UNIFORM_VEC4)
    SetShaderValue(shade, lght.intensityLoc, @lght.intensity, SHADER_UNIFORM_FLOAT)
end sub