/'******************************************************************************************
*
*   raylib [models] example - Load models vox (MagicaVoxel)
*
*   Example originally created with raylib 4.0, last time updated with raylib 4.0
*
*   Example contributed by Johann Nadalutti (@procfxgen) and reviewed by Ramon Santamaria (@raysan5)
*
*   Example licensed under an unmodified zlib/libpng license, which is an OSI-certified,
*   BSD-like license that allows static linking with closed source software
*
*   Copyright (c) 2021-2024 Johann Nadalutti (@procfxgen) and Ramon Santamaria (@raysan5)
*
*******************************************************************************************'/

#include "../../raylib.bi"

#define MAX_VOX_FILES  4

#include "../../rlights.bi"

#define GLSL_VERSION            330

'' Initialization
''--------------------------------------------------------------------------------------
const as long screenWidth = 800
const as long screenHeight = 450

dim as zstring * 128 voxFileNames(...) = {_
	"resources/models/vox/chr_knight.vox",_
	"resources/models/vox/chr_sword.vox",_
	"resources/models/vox/monu9.vox",_
	"resources/models/vox/fez.vox"_
}

InitWindow(screenWidth, screenHeight, "raylib [models] example - magicavoxel loading")

'' Define the camera to look into our 3d world
dim as Camera cam
with cam
	.position = Vector3(10.0f, 10.0f, 10.0f) '' Camera position
	.target = Vector3(0.0f, 0.0f, 0.0f)      '' Camera looking at point
	.up = Vector3(0.0f, 1.0f, 0.0f)          '' Camera up vector (rotation towards target)
	.fovy = 45.0f                            '' Camera field-of-view Y
	.projection = CAMERA_PERSPECTIVE         '' Camera projection type
end with

''--------------------------------------------------------------------------------------
'' Load MagicaVoxel files
dim as Model models(MAX_VOX_FILES - 1)

for i as integer = 0 to MAX_VOX_FILES - 1
	'' Load VOX file and measure time
	dim as double t0 = GetTime() * 1000.0
	models(i) = LoadModel(voxFileNames(i))
	DIM AS double t1 = GetTime() * 1000.0

	TraceLog(LOG_WARNING, TextFormat("[%s] File loaded in %.3f ms", voxFileNames(i), t1 - t0))

	'' Compute model translation matrix to center model on draw position (0, 0 , 0)
	dim as BoundingBox bb = GetModelBoundingBox(models(i))
	dim as Vector3 center
	center.x = bb.min.x + (((bb.max.x - bb.min.x) / 2))
	center.z = bb.min.z + (((bb.max.z - bb.min.z) / 2))

	dim as Matrix matTranslate = MatrixTranslate(-center.x, 0, -center.z)
	models(i).transform = matTranslate
next

dim as long currentModel = 0

''--------------------------------------------------------------------------------------
'' Load voxel shader
dim as Shader shade = LoadShader(TextFormat("resources/shaders/glsl%i/voxel_lighting.vs", GLSL_VERSION), _
	TextFormat("resources/shaders/glsl%i/voxel_lighting.fs", GLSL_VERSION))

'' Get some required shader locations
shade.locs[SHADER_LOC_VECTOR_VIEW] = GetShaderLocation(shade, "viewPos")
'' NOTE: "matModel" location name is automatically assigned on shader loading, 
'' no need to get the location again if using that uniform name
''shader.locs[SHADER_LOC_MATRIX_MODEL] = GetShaderLocation(shader, "matModel")

'' Ambient light level (some basic lighting)
dim as long ambientLoc = GetShaderLocation(shade, "ambient")
dim as Vector4 vec4 = Vector4(0.1f, 0.1f, 0.1f, 1.0f)
SetShaderValue(shade, ambientLoc, @vec4, SHADER_UNIFORM_VEC4)

'' Assign out lighting shader to model
for i as integer = 0 to MAX_VOX_FILES - 1
	dim as Model m = models(i)
	for j as integer = 0 to m.materialCount - 1
		m.materials[j].shader = shade
	next
next

'' Create lights
dim as Light lights(MAX_LIGHTS - 1)
lights(0) = CreateLight(LIGHT_POINT, Vector3(-20, 20, -20), Vector3Zero(), GRAY, shade)
lights(1) = CreateLight(LIGHT_POINT, Vector3(20, -20, 20), Vector3Zero(), GRAY, shade)
lights(2) = CreateLight(LIGHT_POINT, Vector3(-20, 20, 20), Vector3Zero(), GRAY, shade)
lights(3) = CreateLight(LIGHT_POINT, Vector3(20, -20, -20), Vector3Zero(), GRAY, shade)


SetTargetFPS(60)               '' Set our game to run at 60 frames-per-second

''--------------------------------------------------------------------------------------
dim as Vector3 modelpos
dim as Vector3 camerarot

'' Main game loop
do while not WindowShouldClose()    '' Detect window close button or ESC key
	'' Update
	''----------------------------------------------------------------------------------
	if IsMouseButtonDown(MOUSE_BUTTON_MIDDLE) then
		dim as Vector2 mouseDelta = GetMouseDelta()
		camerarot.x = mouseDelta.x * 0.05f
		camerarot.y = mouseDelta.y * 0.05f
	else
		camerarot.x = 0
		camerarot.y = 0
	end if

	'' Move forward-backward
	dim as single fwdBack = iif(IsKeyDown(KEY_W) or IsKeyDown(KEY_UP), 1, 0) * 0.1f - iif(IsKeyDown(KEY_S) or IsKeyDown(KEY_DOWN), 1, 0) * 0.1f
	'' Move right-left
	dim as single leftRight = IIF(IsKeyDown(KEY_D) or IsKeyDown(KEY_RIGHT), 1, 0) * 0.1f - iif(IsKeyDown(KEY_A) or IsKeyDown(KEY_LEFT), 1, 0) * 0.1f
	'' Move up-down
	dim as single upDown = 0.0f
	'' Move to target (zoom)
	dim as single zoom = GetMouseWheelMove() * -2.0f
	UpdateCameraPro(@cam, Vector3(fwdBack, leftRight, upDown), camerarot, zoom)

	'' Cycle between models on mouse click
	if IsMouseButtonPressed(MOUSE_BUTTON_LEFT) then currentModel = (currentModel + 1) mod MAX_VOX_FILES

	'' Update the shader with the camera view vector (points towards { 0.0f, 0.0f, 0.0f })
	dim as single cameraPos(...) = {cam.position.x, cam.position.y, cam.position.z}
	SetShaderValue(shade, shade.locs[SHADER_LOC_VECTOR_VIEW], @cameraPos(0), SHADER_UNIFORM_VEC3)

	'' Update light values (actually, only enable/disable them)
	for i as integer = 0 to MAX_LIGHTS - 1
		UpdateLightValues(shade, lights(i))
	next

	''----------------------------------------------------------------------------------
	'' Draw
	''----------------------------------------------------------------------------------
	BeginDrawing()

	ClearBackground(RAYWHITE)

	'' Draw 3D model
	BeginMode3D(cam)

	DrawModel(models(currentModel), modelpos, 1.0f, WHITE)
	DrawGrid(10, 1.0)

	'' Draw spheres to show where the lights are
	for i as integer = 0 to MAX_LIGHTS - 1
		if lights(i).enabled = RLTRUE then 
			DrawSphereEx(lights(i).position, 0.2f, 8, 8, lights(i).color)
		else 
			DrawSphereWires(lights(i).position, 0.2f, 8, 8, ColorAlpha(lights(i).color, 0.3f))
		end if
	next

	EndMode3D()

	'' Display info
	DrawRectangle(10, 400, 340, 60, Fade(SKYBLUE, 0.5f))
	DrawRectangleLines(10, 400, 340, 60, Fade(DARKBLUE, 0.5f))
	DrawText("MOUSE LEFT BUTTON to CYCLE VOX MODELS", 40, 410, 10, BLUE)
	DrawText("MOUSE MIDDLE BUTTON to ZOOM OR ROTATE CAMERA", 40, 420, 10, BLUE)
	DrawText("UP-DOWN-LEFT-RIGHT KEYS to MOVE CAMERA", 40, 430, 10, BLUE)
	DrawText(TextFormat("File: %s", GetFileName(voxFileNames(currentModel))), 10, 10, 20, GRAY)

	EndDrawing()
	''----------------------------------------------------------------------------------
loop

'' De-Initialization
''--------------------------------------------------------------------------------------
'' Unload models data (GPU VRAM)
for i as integer = 0 to MAX_VOX_FILES - 1
	UnloadModel(models(i))
next

CloseWindow()          '' Close window and OpenGL context
''--------------------------------------------------------------------------------------