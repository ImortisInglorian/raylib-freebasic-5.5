#pragma once
/'*********************************************************************************************
*   raylib v5.5 - A simple and easy-to-use library to enjoy videogames programming (www.raylib.com)
*
*   FEATURES:
*       - NO external dependencies, all required libraries included with raylib
*       - Multiplatform: Windows, Linux, FreeBSD, OpenBSD, NetBSD, DragonFly,
*                        MacOS, Haiku, Android, Raspberry Pi, DRM native, HTML5.
*       - Written in plain C code (C99) in PascalCase/camelCase notation
*       - Hardware accelerated with OpenGL (1.1, 2.1, 3.3, 4.3, ES2, ES3 - choose at compile)
*       - Unique OpenGL abstraction layer (usable as standalone module): [rlgl]
*       - Multiple Fonts formats supported (TTF, OTF, FNT, BDF, Sprite fonts)
*       - Outstanding texture formats support, including compressed formats (DXT, ETC, ASTC)
*       - Full 3d support for 3d Shapes, Models, Billboards, Heightmaps and more!
*       - Flexible Materials system, supporting classic maps and PBR maps
*       - Animated 3D models supported (skeletal bones animation) (IQM, M3D, GLTF)
*       - Shaders support, including Model shaders and Postprocessing shaders
*       - Powerful math module for Vector, Matrix and Quaternion operations: [raymath]
*       - Audio loading and playing with streaming support (WAV, OGG, MP3, FLAC, QOA, XM, MOD)
*       - VR stereo rendering with configurable HMD device parameters
*       - Bindings to multiple programming languages available!
*
*   NOTES:
*       - One default Font is loaded on InitWindow()->LoadFontDefault() [core, text]
*       - One default Texture2D is loaded on rlglInit(), 1x1 white pixel R8G8B8A8 [rlgl] (OpenGL 3.3 or ES2)
*       - One default Shader is loaded on rlglInit()->rlLoadShaderDefault() [rlgl] (OpenGL 3.3 or ES2)
*       - One default RenderBatch is loaded on rlglInit()->rlLoadRenderBatch() [rlgl] (OpenGL 3.3 or ES2)
*
*   DEPENDENCIES (included):
*       [rcore][GLFW] rglfw (Camilla Löwy - github.com/glfw/glfw) for window/context management and input
*       [rcore][RGFW] rgfw (ColleagueRiley - github.com/ColleagueRiley/RGFW) for window/context management and input
*       [rlgl] glad/glad_gles2 (David Herberth - github.com/Dav1dde/glad) for OpenGL 3.3 extensions loading
*       [raudio] miniaudio (David Reid - github.com/mackron/miniaudio) for audio device/context management
*
*   OPTIONAL DEPENDENCIES (included):
*       [rcore] msf_gif (Miles Fogle) for GIF recording
*       [rcore] sinfl (Micha Mettke) for DEFLATE decompression algorithm
*       [rcore] sdefl (Micha Mettke) for DEFLATE compression algorithm
*       [rcore] rprand (Ramon Snatamaria) for pseudo-random numbers generation
*       [rtextures] qoi (Dominic Szablewski - https://phoboslab.org) for QOI image manage
*       [rtextures] stb_image (Sean Barret) for images loading (BMP, TGA, PNG, JPEG, HDR...)
*       [rtextures] stb_imagewrite (Sean Barret) for image writing (BMP, TGA, PNG, JPG)
*       [rtextures] stb_imageresize2 (Sean Barret) for image resizing algorithms
*       [rtextures] stb_perlin (Sean Barret) for Perlin Noise image generation
*       [rtext] stb_truetype (Sean Barret) for ttf fonts loading
*       [rtext] stb_rect_pack (Sean Barret) for rectangles packing
*       [rmodels] par_shapes (Philip Rideout) for parametric 3d shapes generation
*       [rmodels] tinyobj_loader_c (Syoyo Fujita) for models loading (OBJ, MTL)
*       [rmodels] cgltf (Johannes Kuhlmann) for models loading (glTF)
*       [rmodels] m3d (bzt) for models loading (M3D, https://bztsrc.gitlab.io/model3d)
*       [rmodels] vox_loader (Johann Nadalutti) for models loading (VOX)
*       [raudio] dr_wav (David Reid) for WAV audio file loading
*       [raudio] dr_flac (David Reid) for FLAC audio file loading
*       [raudio] dr_mp3 (David Reid) for MP3 audio file loading
*       [raudio] stb_vorbis (Sean Barret) for OGG audio loading
*       [raudio] jar_xm (Joshua Reisenauer) for XM audio module loading
*       [raudio] jar_mod (Joshua Reisenauer) for MOD audio module loading
*       [raudio] qoa (Dominic Szablewski - https://phoboslab.org) for QOA audio manage
*
*
*   LICENSE: zlib/libpng
*
*   raylib is licensed under an unmodified zlib/libpng license, which is an OSI-certified,
*   BSD-like license that allows static linking with closed source software:
*
*   Copyright (c) 2013-2024 Ramon Santamaria (@raysan5)
*
*   This software is provided "as-is", without any express or implied warranty. In no event
*   will the authors be held liable for any damages arising from the use of this software.
*
*   Permission is granted to anyone to use this software for any purpose, including commercial
*   applications, and to alter it and redistribute it freely, subject to the following restrictions:
*
*     1. The origin of this software must not be misrepresented; you must not claim that you
*     wrote the original software. If you use this software in a product, an acknowledgment
*     in the product documentation would be appreciated but is not required.
*
*     2. Altered source versions must be plainly marked as such, and must not be misrepresented
*     as being the original software.
*
*     3. This notice may not be removed or altered from any source distribution.
*
*********************************************************************************************'/

#include once "crt/stdarg.bi"  '' Required for: va_list - Only used by TraceLogCallback

'' The following symbols have been renamed:
''     struct Color => RLColor

#inclib "raylib"


#include once "raymath.bi" '' Include the types for Vector2, Vector3, Vector4, Matrix, and Quaternion

extern "C"

type RLBOOL as long
enum
	RLFALSE = 0
	RLTRUE = 1
end enum

#define RAYLIB_H
const RAYLIB_VERSION_MAJOR = 5
const RAYLIB_VERSION_MINOR = 5
const RAYLIB_VERSION_PATCH = 0
#define RAYLIB_VERSION "5.5"

''----------------------------------------------------------------------------------
'' Some basic Defines
''----------------------------------------------------------------------------------
#ifndef PI
	const PI = 3.14159265358979323846
#endif
#ifndef DEG2RAD
	const DEG2RAD = PI / 180.0f
#endif
#ifndef RAD2DEG
	const RAD2DEG = 180.0f / PI
#endif

'' Allow custom memory allocators
'' NOTE: Require recompiling raylib sources
#ifndef RL_MALLOC
    #define RL_MALLOC(sz) 		malloc(sz)
#endif
#ifndef RL_CALLOC
    #define RL_CALLOC(n,sz) 	calloc(n,sz)
#endif
#ifndef RL_REALLOC
    #define RL_REALLOC(ptr,sz) 	realloc(ptr,sz)
#endif
#ifndef RL_FREE
    #define RL_FREE(ptr) 		free(ptr)
#endif

'' NOTE: We set some defines with some data types declared by raylib
'' Other modules (raymath, rlgl) also require some of those types, so,
'' to be able to use those other modules as standalone (not depending on raylib)
'' this defines are very useful for internal check and avoid type (re)definitions
#define RL_COLOR_TYPE
#define RL_RECTANGLE_TYPE

'' Some Basic Colors
'' NOTE: Custom raylib color palette for amazing visuals on WHITE background
#define LIGHTGRAY 	RLColor( 200, 200, 200, 255 )
#define GRAY 		RLColor( 130, 130, 130, 255 )
#define DARKGRAY 	RLColor( 80, 80, 80, 255 )
#define YELLOW 		RLColor( 253, 249, 0, 255 )
#define GOLD 		RLColor( 255, 203, 0, 255 )
#define ORANGE 		RLColor( 255, 161, 0, 255 )
#define PINK 		RLColor( 255, 109, 194, 255 )
#define RED 		RLColor( 230, 41, 55, 255 )
#define MAROON 		RLColor( 190, 33, 55, 255 )
#define GREEN 		RLColor( 0, 228, 48, 255 )
#define LIME 		RLColor( 0, 158, 47, 255 )
#define DARKGREEN 	RLColor( 0, 117, 44, 255 )
#define SKYBLUE 	RLColor( 102, 191, 255, 255 )
#define BLUE 		RLColor( 0, 121, 241, 255 )
#define DARKBLUE 	RLColor( 0, 82, 172, 255 )
#define PURPLE 		RLColor( 200, 122, 255, 255 )
#define VIOLET 		RLColor( 135, 60, 190, 255 )
#define DARKPURPLE 	RLColor( 112, 31, 126, 255 )
#define BEIGE 		RLColor( 211, 176, 131, 255 )
#define BROWN 		RLColor( 127, 106, 79, 255 )
#define DARKBROWN 	RLColor( 76, 63, 47, 255 )
#define WHITE 		RLColor( 255, 255, 255, 255 )
#define BLACK 		RLColor( 0, 0, 0, 255 )
#define BLANK 		RLColor( 0, 0, 0, 0 )
#define MAGENTA 	RLColor( 255, 0, 255, 255 )
#define RAYWHITE 	RLColor( 245, 245, 245, 255 )

'' RLColor, 4 components, R8G8B8A8 (32bit)
type RLColor
	declare constructor()
	declare constructor(r as ubyte, g as ubyte, b as ubyte, a as ubyte)
	r as ubyte	'' Color red value
	g as ubyte	'' Color green value
	b as ubyte	'' Color blue value
	a as ubyte	'' Color alpha value
end type

constructor RLColor(r as ubyte, g as ubyte, b as ubyte, a as ubyte)
	this.r = r
	this.g = g
	this.b = b
	this.a = a
end constructor

constructor RLColor()
end constructor

'' Rectangle, 4 components
type Rectangle
	declare constructor()
	declare constructor(x as single, y as single, wid as single, height as single)
	x as single			'' Rectangle top-left corner position x
	y as single			'' Rectangle top-left corner position y
	width as single		'' Rectangle width
	height as single	'' Rectangle height
end type

constructor Rectangle()
end constructor

constructor Rectangle(x as single, y as single, wid as single, height as single)
	this.x = x
	this.y = y
	this.width = wid
	this.height = height
end constructor

'' Image, pixel data stored in CPU memory (RAM)
type Image
	data as any ptr 	'' Image raw data
	width as long		'' Image base width
	height as long 		'' Image base height
	mipmaps as long 	'' Mipmap levels, 1 by default
	format as long 		'' Data format (PixelFormat type)
end type

'' Texture, tex data stored in GPU memory (VRAM)
type Texture
	id as ulong 	'' OpenGL texture id
	width as long 	'' Texture base width
	height as long 	'' Texture base height
	mipmaps as long '' Mipmap levels, 1 by default
	format as long 	'' Data format (PixelFormat type)
end type

'' Texture2D, same as Texture
type Texture2D as Texture
'' TextureCubemap, same as Texture
type TextureCubemap as Texture

'' RenderTexture, fbo for texture rendering
type RenderTexture
	id as ulong 		'' OpenGL framebuffer object id
	texture as Texture	'' Color buffer attachment texture
	depth as Texture 	'' Depth buffer attachment texture
end type

'' RenderTexture2D, same as RenderTexture
type RenderTexture2D as RenderTexture

'' NPatchInfo, n-patch layout info
type NPatchInfo
	source as Rectangle 	'' Texture source rectangle
	left as long 			'' Left border offset
	top as long 			'' Top border offset
	right as long 			'' Right border offset
	bottom as long 			'' Bottom border offset
	layout as long 			'' Layout of the n-patch: 3x3, 1x3 or 3x1
end type

'' GlyphInfo, font characters glyphs info
type GlyphInfo
	value as long 		'' Character value (Unicode)
	offsetX as long 	'' Character offset X when drawing
	offsetY as long 	'' Character offset Y when drawing
	advanceX as long 	'' Character advance position X
	image as Image 	'' Character image data
end type

'' Font, font texture and GlyphInfo array data
type Font
	baseSize as long 		'' Base size (default chars height)
	glyphCount as long 		'' Number of glyph characters
	glyphPadding as long 	'' Padding around the glyph characters
	texture as Texture2D 	'' Texture atlas containing the glyphs
	recs as Rectangle ptr 	'' Rectangles in texture for the glyphs
	glyphs as GlyphInfo ptr '' Glyphs info data
end type

'' Camera, defines position/orientation in 3d space
type Camera3D
	declare constructor()
	declare constructor(position as Vector3, target as Vector3, up as Vector3, fovy as single, projection as long)
	position as Vector3 '' Camera position
	target as Vector3 	'' Camera target it looks-at
	up as Vector3 		'' Camera up vector (rotation over its axis)
	fovy as single 		'' Camera field-of-view aperture in Y (degrees) in perspective, used as near plane width in orthographic
	projection as long 	'' Camera projection: CAMERA_PERSPECTIVE or CAMERA_ORTHOGRAPHIC
end type

constructor Camera3D() 
end constructor 

constructor Camera3D(position as Vector3, target as Vector3, up as Vector3, fovy as single, projection as long)
	this.position = position
	this.target = target
	this.up = up
	this.fovy = fovy
	this.projection = projection 
end constructor  

'' Camera type fallback, defaults to Camera3D
type Camera as Camera3D

'' Camera2D, defines position/orientation in 2d space
type Camera2D
	declare constructor()
	declare constructor(offset as Vector2, target as Vector2, rototation as single, zoom as single)
	offset as Vector2 	'' Camera offset (displacement from target)
	target as Vector2 	'' Camera target (rotation and zoom origin)
	rotation as single 	'' Camera rotation in degrees
	zoom as single 		'' Camera zoom (scaling), should be 1.0f by default
end type

constructor Camera2D()
end constructor

constructor Camera2D(offset as Vector2, target as Vector2, rotation as single, zoom as single)
	this.offset = offset
	this.target = target
	this.rotation = rotation 
	this.zoom = zoom
end constructor 

'' Mesh, vertex data and vao/vbo
type Mesh
	vertexCount as long 		'' Number of vertices stored in arrays
	triangleCount as long 		'' Number of triangles stored (indexed or not)

	'' Vertex attributes data
	vertices as single ptr 		'' Vertex position (XYZ - 3 components per vertex) (shader-location = 0)
	texcoords as single ptr 	'' Vertex texture coordinates (UV - 2 components per vertex) (shader-location = 1)
	texcoords2 as single ptr 	'' Vertex texture second coordinates (UV - 2 components per vertex) (shader-location = 5)
	normals as single ptr 		'' Vertex normals (XYZ - 3 components per vertex) (shader-location = 2)
	tangents as single ptr 		'' Vertex tangents (XYZW - 4 components per vertex) (shader-location = 4)
	colors as ubyte ptr 		'' Vertex colors (RGBA - 4 components per vertex) (shader-location = 3)
	indices as ushort ptr 		'' Vertex indices (in case vertex data comes indexed)

	'' Animation vertex data
	animVertices as single ptr 	'' Animated vertex positions (after bones transformations)
	animNormals as single ptr 	'' Animated normals (after bones transformations)
	boneIds as ubyte ptr 		'' Vertex bone ids, max 255 bone ids, up to 4 bones influence by vertex (skinning) (shader-location = 6)
	boneWeights as single ptr 	'' Vertex bone weight, up to 4 bones influence by vertex (skinning) (shader-location = 7)
	boneMatrices as Matrix ptr  '' Bones animated transformation matrices
    boneCount as long 			'' Number of bones

	'' OpenGL identifiers
	vaoId as ulong 				'' OpenGL Vertex Array Object id
	vboId as ulong ptr 			'' OpenGL Vertex Buffer Objects id (default vertex data)
end type

'' Shader
type Shader
	id as ulong			''  Shader program id
	locs as long ptr 	'' Shader locations array (RL_MAX_SHADER_LOCATIONS)
end type

'' MaterialMap
type MaterialMap
	texture as Texture2D 	'' Material map texture
	color as RLColor 		'' Material map color
	value as single 		'' Material map value
end type

'' Material, includes shader and maps
type Material
	shader as Shader 			'' Material shader
	maps as MaterialMap ptr 	'' Material maps array (MAX_MATERIAL_MAPS)
	params(3) as single 		'' Material generic parameters (if required)
end type

'' Transform, vertex transformation data
type Transform
	translation as Vector3 	'' Translation
	rotation as Quaternion 	'' Rotation
	scale as Vector3 		'' Scale
end type

'' Bone, skeletal animation bone
type BoneInfo
	name as zstring * 32 	'' Bone name
	parent as long 			'' Bone parent
end type

'' Model, meshes, materials and animation data
type Model
	transform as Matrix 		'' Local transform matrix

	meshCount as long 			'' Number of meshes
	materialCount as long 		'' Number of materials
	meshes as Mesh ptr 			'' Meshes array
	materials as Material ptr 	'' Materials array
	meshMaterial as long ptr 	'' Mesh material number

	'' Animation data
	boneCount as long 			'' Number of bones
	bones as BoneInfo ptr 		'' Bones information (skeleton)
	bindPose as Transform ptr 	'' Bones base transformation (pose)
end type

'' ModelAnimation
type ModelAnimation
	boneCount as long 					'' Number of bones
	frameCount as long 					'' Number of animation frames
	bones as BoneInfo ptr 				'' Bones information (skeleton)
	framePoses as Transform ptr ptr 	'' Poses array by frame
	name as zstring * 32				'' Animation name
end type

'' Ray, ray for raycasting
type Ray
	position as Vector3	 '' Ray position (origin)
	direction as Vector3 '' Ray direction (normalized)
end type

'' RayCollision, ray hit information
type RayCollision
	hit as RLBOOL 		'' Did the ray hit something?
	distance as single 	'' Distance to the nearest hit
	point as Vector3 	'' Point of the nearest hit
	normal as Vector3 	'' Surface normal of hit
end type

'' BoundingBox
type BoundingBox
	declare constructor()
	declare constructor(min as Vector3, max as Vector3)
	min as Vector3 	'' Minimum vertex box-corner
	max as Vector3 	'' Maximum vertex box-corner
end type

constructor BoundingBox()
end constructor

constructor BoundingBox(min as Vector3, max as Vector3)
	this.min = min
	this.max = max
end constructor

'' Wave, audio wave data
type Wave
	frameCount as ulong	'' Total number of frames (considering channels)
	sampleRate as ulong '' Frequency (samples per second)
	sampleSize as ulong '' Bit depth (bits per sample): 8, 16, 32 (24 not supported)
	channels as ulong 	'' Number of channels (1-mono, 2-stereo, ...)
	data as any ptr 	'' Buffer data pointer
end type

'' Opaque structs declaration
'' NOTE: Actual structs are defined internally in raudio module
type as rAudioBuffer rAudioBuffer_
type as rAudioProcessor rAudioProcessor_

'' AudioStream, custom audio stream
type AudioStream
	buffer as rAudioBuffer_ ptr 			'' Pointer to internal data used by the audio system
	processor as rAudioProcessor_ ptr 	'' Pointer to internal data processor, useful for audio effects

	sampleRate as ulong 				'' Frequency (samples per second)
	sampleSize as ulong 				'' Bit depth (bits per sample): 8, 16, 32 (24 not supported)
	channels as ulong 					'' Number of channels (1-mono, 2-stereo, ...)
end type

'' Sound
type Sound
	stream as AudioStream 	'' Audio stream
	frameCount as ulong 	'' Total number of frames (considering channels)
end type

'' Music, audio stream, anything longer than ~10 seconds should be streamed
type Music
	stream as AudioStream 	'' Audio stream
	frameCount as ulong 	'' Total number of frames (considering channels)
	looping as RLBOOL 		'' Music looping enable

	ctxType as long 		'' Type of music context (audio filetype)
	ctxData as any ptr 		'' Audio context data, depends on type
end type

'' VrDeviceInfo, Head-Mounted-Display device parameters
type VrDeviceInfo
	hResolution as long 						'' Horizontal resolution in pixels
	vResolution as long							'' Vertical resolution in pixels
	hScreenSize as single						'' Horizontal size in meters
	vScreenSize as single						'' Vertical size in meters
	eyeToScreenDistance as single				'' Distance between eye and display in meters
	lensSeparationDistance as single			'' Lens separation distance in meters
	interpupillaryDistance as single			'' IPD (distance between pupils) in meters
	lensDistortionValues(3) as single		'' Lens distortion constant parameters
	chromaAbCorrection(3) as single		'' Chromatic aberration correction parameters
end type

'' VrStereoConfig, VR stereo rendering configuration for simulator
type VrStereoConfig
	projection(1) as Matrix		'' VR projection matrices (per eye)
	viewOffset(1) as Matrix		'' VR view offset matrices (per eye)
	leftLensCenter(1) as single	'' VR left lens center
	rightLensCenter(1) as single	'' VR right lens center
	leftScreenCenter(1) as single 	'' VR left screen center
	rightScreenCenter(1) as single	'' VR right screen center
	scale(1) as single				'' VR distortion scale
	scaleIn(1) as single			'' VR distortion scale in
end type

'' File path list
type FilePathList
	capacity as ulong			'' Filepaths max entries
	count as ulong				'' Filepaths entries count
	paths as zstring ptr ptr	'' Filepaths entries
end type

'' Automation event
type AutomationEvent
	frame as ulong			'' Event frame
	type as ulong			'' Event type (AutomationEventType)
	params(3) as long	'' Event parameters (if required)
end type

'' Automation event list
type AutomationEventList
	capacity as ulong				'' Events max entries (MAX_AUTOMATION_EVENTS)
	count as ulong					'' Events entries count
	events as AutomationEvent ptr	'' Events entries
end type

''----------------------------------------------------------------------------------
'' Enumerators Definition
''----------------------------------------------------------------------------------
'' System/Window config flags
'' NOTE: Every bit registers one state (use it with bit masks)
'' By default all flags are set to 0
type ConfigFlags as long
enum
	FLAG_VSYNC_HINT 				= &h00000040 '' Set to try enabling V-Sync on GPU
	FLAG_FULLSCREEN_MODE 			= &h00000002 '' Set to run program in fullscreen
	FLAG_WINDOW_RESIZABLE 			= &h00000004 '' Set to allow resizable window
	FLAG_WINDOW_UNDECORATED 		= &h00000008 '' Set to disable window decoration (frame and buttons)
	FLAG_WINDOW_HIDDEN 				= &h00000080 '' Set to hide window
	FLAG_WINDOW_MINIMIZED 			= &h00000200 '' Set to minimize window (iconify)
	FLAG_WINDOW_MAXIMIZED 			= &h00000400 '' Set to minimize window (iconify)
	FLAG_WINDOW_UNFOCUSED 			= &h00000800 '' Set to window non focused
	FLAG_WINDOW_TOPMOST 			= &h00001000 '' Set to window always on top
	FLAG_WINDOW_ALWAYS_RUN 			= &h00000100 '' Set to allow windows running while minimized
	FLAG_WINDOW_TRANSPARENT 		= &h00000010 '' Set to allow transparent framebuffer
	FLAG_WINDOW_HIGHDPI 			= &h00002000 '' Set to support HighDPI
	FLAG_WINDOW_MOUSE_PASSTHROUGH 	= &h00004000 '' Set to support mouse passthrough, only supported when FLAG_WINDOW_UNDECORATED
	FLAG_BORDERLESS_WINDOWED_MODE 	= &h00008000 '' Set to run program in borderless windowed mode
	FLAG_MSAA_4X_HINT 				= &h00000020 '' Set to try enabling MSAA 4X
	FLAG_INTERLACED_HINT 			= &h00010000 '' Set to try enabling interlaced video format (for V3D)
end enum

'' Trace log level
'' NOTE: Organized by priority level
type TraceLogLevel as long
enum
	LOG_ALL = 0		'' Display all logs
	LOG_TRACE		'' Trace logging, intended for internal use only
	LOG_DEBUG		'' Debug logging, used for internal debugging, it should be disabled on release builds
	LOG_INFO		'' Info logging, used for program execution info
	LOG_WARNING		'' Warning logging, used on recoverable failures
	LOG_ERROR		'' Error logging, used on unrecoverable failures
	LOG_FATAL		'' Fatal logging, used to abort program: exit(EXIT_FAILURE)
	LOG_NONE		'' Disable logging
end enum

'' Keyboard keys (US keyboard layout)
'' NOTE: Use GetKeyPressed() to allow redefining
'' required keys for alternative layouts
type KeyboardKey as long
enum
	KEY_NULL = 0			'' Key: NULL, used for no key pressed
	'' Alphanumeric keys
	KEY_APOSTROPHE = 39		'' Key: '
	KEY_COMMA = 44			'' Key: ,
	KEY_MINUS = 45			'' Key: -
	KEY_PERIOD = 46			'' Key: .
	KEY_SLASH = 47			'' Key: /
	KEY_ZERO = 48			'' Key: 0
	KEY_ONE = 49			'' Key: 1
	KEY_TWO = 50			'' Key: 2
	KEY_THREE = 51			'' Key: 3
	KEY_FOUR = 52			'' Key: 4
	KEY_FIVE = 53			'' Key: 5
	KEY_SIX = 54			'' Key: 6
	KEY_SEVEN = 55			'' Key: 7
	KEY_EIGHT = 56			'' Key: 8
	KEY_NINE = 57			'' Key: 9
	KEY_SEMICOLON = 59		'' Key: ;
	KEY_EQUAL = 61			'' Key: =
	KEY_A = 65				'' Key: A | a
	KEY_B = 66				'' Key: B | b
	KEY_C = 67				'' Key: C | c
	KEY_D = 68				'' Key: D | d
	KEY_E = 69				'' Key: E | e
	KEY_F = 70				'' Key: F | f
	KEY_G = 71				'' Key: G | g
	KEY_H = 72				'' Key: H | h
	KEY_I = 73				'' Key: I | i
	KEY_J = 74				'' Key: J | j
	KEY_K = 75				'' Key: K | k
	KEY_L = 76				'' Key: L | l
	KEY_M = 77				'' Key: M | m
	KEY_N = 78				'' Key: N | n
	KEY_O = 79				'' Key: O | o
	KEY_P = 80				'' Key: P | p
	KEY_Q = 81				'' Key: Q | q
	KEY_R = 82				'' Key: R | r
	KEY_S = 83				'' Key: S | s
	KEY_T = 84				'' Key: T | t
	KEY_U = 85				'' Key: U | u
	KEY_V = 86				'' Key: V | v
	KEY_W = 87				'' Key: W | w
	KEY_X = 88				'' Key: X | x
	KEY_Y = 89				'' Key: Y | y
	KEY_Z = 90				'' Key: Z | z
	KEY_LEFT_BRACKET = 91	'' Key: [
	KEY_BACKSLASH = 92		'' Key: \
	KEY_RIGHT_BRACKET = 93	'' Key: ]
	KEY_GRAVE = 96			'' Key: `
	'' Function Keys
	KEY_SPACE = 32			'' Key: Space
	KEY_ESCAPE = 256		'' Key: Esc
	KEY_ENTER = 257			'' Key: Enter
	KEY_TAB = 258			'' Key: Tab
	KEY_BACKSPACE = 259		'' Key: Backspace
	KEY_INSERT = 260		'' Key: Ins
	KEY_DELETE = 261		'' Key: Del
	KEY_RIGHT = 262			'' Key: Cursor right
	KEY_LEFT = 263			'' Key: Cursor left
	KEY_DOWN = 264			'' Key: Cursor down
	KEY_UP = 265			'' Key: Cursor up
	KEY_PAGE_UP = 266		'' Key: Page up
	KEY_PAGE_DOWN = 267		'' Key: Page down
	KEY_HOME = 268			'' Key: Home
	KEY_END = 269			'' Key: End
	KEY_CAPS_LOCK = 280		'' Key: Caps lock
	KEY_SCROLL_LOCK = 281	'' Key: Scroll lock
	KEY_NUM_LOCK = 282		'' Key: Num lock
	KEY_PRINT_SCREEN = 283	'' Key: Print Screen
	KEY_PAUSE = 284			'' Key: Pause
	KEY_F1 = 290			'' Key: F1
	KEY_F2 = 291			'' Key: F2
	KEY_F3 = 292			'' Key: F3
	KEY_F4 = 293			'' Key: F4
	KEY_F5 = 294			'' Key: F5
	KEY_F6 = 295			'' Key: F6
	KEY_F7 = 296			'' Key: F7
	KEY_F8 = 297			'' Key: F8
	KEY_F9 = 298			'' Key: F9
	KEY_F10 = 299			'' Key: F10
	KEY_F11 = 300			'' Key: F11
	KEY_F12 = 301			'' Key: F12
	KEY_LEFT_SHIFT = 340	'' Key: Shift left
	KEY_LEFT_CONTROL = 341	'' Key: Control left
	KEY_LEFT_ALT = 342		'' Key: Alt left
	KEY_LEFT_SUPER = 343	'' Key: Super left
	KEY_RIGHT_SHIFT = 344	'' Key: Shift right
	KEY_RIGHT_CONTROL = 345 '' Key: Control right
	KEY_RIGHT_ALT = 346		'' Key: Alt right
	KEY_RIGHT_SUPER = 347	'' Key: Super right
	KEY_KB_MENU = 348		'' Key: KB menu
	'' Keypad Keys
	KEY_KP_0 = 320			'' Key: Keypad 0
	KEY_KP_1 = 321			'' Key: Keypad 1
	KEY_KP_2 = 322			'' Key: Keypad 2
	KEY_KP_3 = 323			'' Key: Keypad 3
	KEY_KP_4 = 324			'' Key: Keypad 4
	KEY_KP_5 = 325			'' Key: Keypad 5
	KEY_KP_6 = 326			'' Key: Keypad 6
	KEY_KP_7 = 327			'' Key: Keypad 7
	KEY_KP_8 = 328			'' Key: Keypad 8
	KEY_KP_9 = 329			'' Key: Keypad 9
	KEY_KP_DECIMAL = 330	'' Key: Keypad .
	KEY_KP_DIVIDE = 331		'' Key: Keypad /
	KEY_KP_MULTIPLY = 332	'' Key: Keypad *
	KEY_KP_SUBTRACT = 333	'' Key: Keypad -
	KEY_KP_ADD = 334		'' Key: Keypad +
	KEY_KP_ENTER = 335		'' Key: Keypad Enter
	KEY_KP_EQUAL = 336		'' Key: Keypad =
	'' Android key buttons
	KEY_BACK = 4			'' Key: Android back button
	KEY_MENU = 5			'' Key: Android menu button
	KEY_VOLUME_UP = 24		'' Key: Android volume up
	KEY_VOLUME_DOWN = 25	'' Key: Android volume down
end enum

'' Add backwards compatibility support for deprecated names
#define MOUSE_LEFT_BUTTON   MOUSE_BUTTON_LEFT
#define MOUSE_RIGHT_BUTTON  MOUSE_BUTTON_RIGHT
#define MOUSE_MIDDLE_BUTTON MOUSE_BUTTON_MIDDLE

'' Mouse buttons
type MouseButton as long
enum
	MOUSE_BUTTON_LEFT = 0		'' Mouse button left
	MOUSE_BUTTON_RIGHT = 1		'' Mouse button right
	MOUSE_BUTTON_MIDDLE = 2		'' Mouse button middle (pressed wheel)
	MOUSE_BUTTON_SIDE = 3		'' Mouse button side (advanced mouse device)
	MOUSE_BUTTON_EXTRA = 4		'' Mouse button extra (advanced mouse device)
	MOUSE_BUTTON_FORWARD = 5	'' Mouse button forward (advanced mouse device)
	MOUSE_BUTTON_BACK = 6		'' Mouse button back (advanced mouse device)
end enum

'' Mouse cursor
type MouseCursor as long
enum
	MOUSE_CURSOR_DEFAULT = 0		'' Default pointer shape
	MOUSE_CURSOR_ARROW = 1			'' Arrow shape
	MOUSE_CURSOR_IBEAM = 2			'' Text writing cursor shape
	MOUSE_CURSOR_CROSSHAIR = 3		'' Cross shape
	MOUSE_CURSOR_POINTING_HAND = 4	'' Pointing hand cursor
	MOUSE_CURSOR_RESIZE_EW = 5		'' Horizontal resize/move arrow shape
	MOUSE_CURSOR_RESIZE_NS = 6		'' Vertical resize/move arrow shape
	MOUSE_CURSOR_RESIZE_NWSE = 7	'' Top-left to bottom-right diagonal resize/move arrow shape
	MOUSE_CURSOR_RESIZE_NESW = 8	'' The top-right to bottom-left diagonal resize/move arrow shape
	MOUSE_CURSOR_RESIZE_ALL = 9		'' The omnidirectional resize/move cursor shape
	MOUSE_CURSOR_NOT_ALLOWED = 10	'' The operation-not-allowed shape
end enum

'' Gamepad buttons
type GamepadButton as long
enum
	GAMEPAD_BUTTON_UNKNOWN = 0		'' Unknown button, just for error checking
	GAMEPAD_BUTTON_LEFT_FACE_UP		'' Gamepad left DPAD up button
	GAMEPAD_BUTTON_LEFT_FACE_RIGHT	'' Gamepad left DPAD right button
	GAMEPAD_BUTTON_LEFT_FACE_DOWN	'' Gamepad left DPAD down button
	GAMEPAD_BUTTON_LEFT_FACE_LEFT	'' Gamepad left DPAD left button
	GAMEPAD_BUTTON_RIGHT_FACE_UP	'' Gamepad right button up (i.e. PS3: Triangle, Xbox: Y)
	GAMEPAD_BUTTON_RIGHT_FACE_RIGHT	'' Gamepad right button right (i.e. PS3: Circle, Xbox: B)
	GAMEPAD_BUTTON_RIGHT_FACE_DOWN	'' Gamepad right button down (i.e. PS3: Cross, Xbox: A)
	GAMEPAD_BUTTON_RIGHT_FACE_LEFT	'' Gamepad right button left (i.e. PS3: Square, Xbox: X)
	GAMEPAD_BUTTON_LEFT_TRIGGER_1	'' Gamepad top/back trigger left (first), it could be a trailing button
	GAMEPAD_BUTTON_LEFT_TRIGGER_2	'' Gamepad top/back trigger left (second), it could be a trailing button
	GAMEPAD_BUTTON_RIGHT_TRIGGER_1	'' Gamepad top/back trigger right (first), it could be a trailing button
	GAMEPAD_BUTTON_RIGHT_TRIGGER_2	'' Gamepad top/back trigger right (second), it could be a trailing button
	GAMEPAD_BUTTON_MIDDLE_LEFT		'' Gamepad center buttons, left one (i.e. PS3: Select)
	GAMEPAD_BUTTON_MIDDLE			'' Gamepad center buttons, middle one (i.e. PS3: PS, Xbox: XBOX)
	GAMEPAD_BUTTON_MIDDLE_RIGHT		'' Gamepad center buttons, right one (i.e. PS3: Start)
	GAMEPAD_BUTTON_LEFT_THUMB		'' Gamepad joystick pressed button left
	GAMEPAD_BUTTON_RIGHT_THUMB		'' Gamepad joystick pressed button right
end enum

'' Gamepad axis
type GamepadAxis as long
enum
	GAMEPAD_AXIS_LEFT_X = 0			'' Gamepad left stick X axis
	GAMEPAD_AXIS_LEFT_Y = 1			'' Gamepad left stick Y axis
	GAMEPAD_AXIS_RIGHT_X = 2		'' Gamepad right stick X axis
	GAMEPAD_AXIS_RIGHT_Y = 3		'' Gamepad right stick Y axis
	GAMEPAD_AXIS_LEFT_TRIGGER = 4	'' Gamepad back trigger left, pressure level: [1..-1]
	GAMEPAD_AXIS_RIGHT_TRIGGER = 5	'' Gamepad back trigger right, pressure level: [1..-1]
end enum


'' Material map index
type MaterialMapIndex as long
enum
	MATERIAL_MAP_ALBEDO = 0	'' Albedo material (same as: MATERIAL_MAP_DIFFUSE)
	MATERIAL_MAP_METALNESS	'' Metalness material (same as: MATERIAL_MAP_SPECULAR)
	MATERIAL_MAP_NORMAL		'' Normal material
	MATERIAL_MAP_ROUGHNESS	'' Roughness material
	MATERIAL_MAP_OCCLUSION 	'' Ambient occlusion material
	MATERIAL_MAP_EMISSION	'' Emission material
	MATERIAL_MAP_HEIGHT		'' Heightmap material
	MATERIAL_MAP_CUBEMAP	'' Cubemap material (NOTE: Uses GL_TEXTURE_CUBE_MAP)
	MATERIAL_MAP_IRRADIANCE '' Irradiance material (NOTE: Uses GL_TEXTURE_CUBE_MAP)
	MATERIAL_MAP_PREFILTER 	'' Prefilter material (NOTE: Uses GL_TEXTURE_CUBE_MAP)
	MATERIAL_MAP_BRDF		'' Brdf material
end enum

#define MATERIAL_MAP_DIFFUSE  MATERIAL_MAP_ALBEDO
#define MATERIAL_MAP_SPECULAR MATERIAL_MAP_METALNESS

'' Shader location index
type ShaderLocationIndex as long
enum
	SHADER_LOC_VERTEX_POSITION = 0	'' Shader location: vertex attribute: position
	SHADER_LOC_VERTEX_TEXCOORD01	'' Shader location: vertex attribute: texcoord01
	SHADER_LOC_VERTEX_TEXCOORD02	'' Shader location: vertex attribute: texcoord02
	SHADER_LOC_VERTEX_NORMAL		'' Shader location: vertex attribute: normal
	SHADER_LOC_VERTEX_TANGENT		'' Shader location: vertex attribute: tangent
	SHADER_LOC_VERTEX_COLOR			'' Shader location: vertex attribute: color
	SHADER_LOC_MATRIX_MVP			'' Shader location: matrix uniform: model-view-projection
	SHADER_LOC_MATRIX_VIEW			'' Shader location: matrix uniform: view (camera transform)
	SHADER_LOC_MATRIX_PROJECTION	'' Shader location: matrix uniform: projection
	SHADER_LOC_MATRIX_MODEL			'' Shader location: matrix uniform: model (transform)
	SHADER_LOC_MATRIX_NORMAL		'' Shader location: matrix uniform: normal
	SHADER_LOC_VECTOR_VIEW			'' Shader location: vector uniform: view
	SHADER_LOC_COLOR_DIFFUSE		'' Shader location: vector uniform: diffuse color
	SHADER_LOC_COLOR_SPECULAR		'' Shader location: vector uniform: specular color
	SHADER_LOC_COLOR_AMBIENT		'' Shader location: vector uniform: ambient color
	SHADER_LOC_MAP_ALBEDO			'' Shader location: sampler2d texture: albedo (same as: SHADER_LOC_MAP_DIFFUSE)
	SHADER_LOC_MAP_METALNESS		'' Shader location: sampler2d texture: metalness (same as: SHADER_LOC_MAP_SPECULAR)
	SHADER_LOC_MAP_NORMAL			'' Shader location: sampler2d texture: normal
	SHADER_LOC_MAP_ROUGHNESS		'' Shader location: sampler2d texture: roughness
	SHADER_LOC_MAP_OCCLUSION		'' Shader location: sampler2d texture: occlusion
	SHADER_LOC_MAP_EMISSION			'' Shader location: sampler2d texture: emission
	SHADER_LOC_MAP_HEIGHT			'' Shader location: sampler2d texture: height
	SHADER_LOC_MAP_CUBEMAP			'' Shader location: samplerCube texture: cubemap
	SHADER_LOC_MAP_IRRADIANCE		'' Shader location: samplerCube texture: irradiance
	SHADER_LOC_MAP_PREFILTER		'' Shader location: samplerCube texture: prefilter
	SHADER_LOC_MAP_BRDF				'' Shader location: sampler2d texture: brdf
	SHADER_LOC_VERTEX_BONEIDS		'' Shader location: vertex attribute: boneIds
    SHADER_LOC_VERTEX_BONEWEIGHTS	'' Shader location: vertex attribute: boneWeights
    SHADER_LOC_BONE_MATRICES		'' Shader location: array of matrices uniform: boneMatrices
end enum

#define SHADER_LOC_MAP_DIFFUSE  SHADER_LOC_MAP_ALBEDO
#define SHADER_LOC_MAP_SPECULAR SHADER_LOC_MAP_METALNESS

'' Shader uniform data type
type ShaderUniformDataType as long
enum
	SHADER_UNIFORM_FLOAT = 0	'' Shader uniform type: float
	SHADER_UNIFORM_VEC2			'' Shader uniform type: vec2 (2 float)
	SHADER_UNIFORM_VEC3			'' Shader uniform type: vec3 (3 float)
	SHADER_UNIFORM_VEC4			'' Shader uniform type: vec4 (4 float)
	SHADER_UNIFORM_INT			'' Shader uniform type: int
	SHADER_UNIFORM_IVEC2		'' Shader uniform type: ivec2 (2 int)
	SHADER_UNIFORM_IVEC3		'' Shader uniform type: ivec3 (3 int)
	SHADER_UNIFORM_IVEC4		'' Shader uniform type: ivec4 (4 int)
	SHADER_UNIFORM_SAMPLER2D	'' Shader uniform type: sampler2d
end enum

'' Shader attribute data types
type ShaderAttributeDataType as long
enum
	SHADER_ATTRIB_FLOAT = 0	'' Shader attribute type: float
	SHADER_ATTRIB_VEC2		'' Shader attribute type: vec2 (2 float)
	SHADER_ATTRIB_VEC3		'' Shader attribute type: vec3 (3 float)
	SHADER_ATTRIB_VEC4		'' Shader attribute type: vec4 (4 float)
end enum

'' Pixel formats
'' NOTE: Support depends on OpenGL version and platform
type PixelFormat as long
enum
	PIXELFORMAT_UNCOMPRESSED_GRAYSCALE = 1	'' 8 bit per pixel (no alpha)
	PIXELFORMAT_UNCOMPRESSED_GRAY_ALPHA		'' 8*2 bpp (2 channels)
	PIXELFORMAT_UNCOMPRESSED_R5G6B5			'' 16 bpp
	PIXELFORMAT_UNCOMPRESSED_R8G8B8			'' 24 bpp
	PIXELFORMAT_UNCOMPRESSED_R5G5B5A1		'' 16 bpp (1 bit alpha)
	PIXELFORMAT_UNCOMPRESSED_R4G4B4A4		'' 16 bpp (4 bit alpha)
	PIXELFORMAT_UNCOMPRESSED_R8G8B8A8		'' 32 bpp
	PIXELFORMAT_UNCOMPRESSED_R32			'' 32 bpp (1 channel - float)
	PIXELFORMAT_UNCOMPRESSED_R32G32B32		'' 32*3 bpp (3 channels - float)
	PIXELFORMAT_UNCOMPRESSED_R32G32B32A32	'' 32*4 bpp (4 channels - float)
	PIXELFORMAT_UNCOMPRESSED_R16			'' 16 bpp (1 channel - half float)
	PIXELFORMAT_UNCOMPRESSED_R16G16B16		'' 16*3 bpp (3 channels - half float)
	PIXELFORMAT_UNCOMPRESSED_R16G16B16A16	'' 16*4 bpp (4 channels - half float)
	PIXELFORMAT_COMPRESSED_DXT1_RGB			'' 4 bpp (no alpha)
	PIXELFORMAT_COMPRESSED_DXT1_RGBA		'' 4 bpp (1 bit alpha)
	PIXELFORMAT_COMPRESSED_DXT3_RGBA		'' 8 bpp
	PIXELFORMAT_COMPRESSED_DXT5_RGBA		'' 8 bpp
	PIXELFORMAT_COMPRESSED_ETC1_RGB			'' 4 bpp
	PIXELFORMAT_COMPRESSED_ETC2_RGB			'' 4 bpp
	PIXELFORMAT_COMPRESSED_ETC2_EAC_RGBA	'' 8 bpp
	PIXELFORMAT_COMPRESSED_PVRT_RGB			'' 4 bpp
	PIXELFORMAT_COMPRESSED_PVRT_RGBA		'' 4 bpp
	PIXELFORMAT_COMPRESSED_ASTC_4x4_RGBA	'' 8 bpp
	PIXELFORMAT_COMPRESSED_ASTC_8x8_RGBA	'' 2 bpp
end enum

'' Texture parameters: filter mode
'' NOTE 1: Filtering considers mipmaps if available in the texture
'' NOTE 2: Filter is accordingly set for minification and magnification
type TextureFilter as long
enum
	TEXTURE_FILTER_POINT = 0		'' No filter, just pixel approximation
	TEXTURE_FILTER_BILINEAR			'' Linear filtering
	TEXTURE_FILTER_TRILINEAR		'' Trilinear filtering (linear with mipmaps)
	TEXTURE_FILTER_ANISOTROPIC_4X	'' Anisotropic filtering 4x
	TEXTURE_FILTER_ANISOTROPIC_8X	'' Anisotropic filtering 8x
	TEXTURE_FILTER_ANISOTROPIC_16X	'' Anisotropic filtering 16x
end enum

'' Texture parameters: wrap mode
type TextureWrap as long
enum
	TEXTURE_WRAP_REPEAT = 0		'' Repeats texture in tiled mode
	TEXTURE_WRAP_CLAMP			'' Clamps texture to edge pixel in tiled mode
	TEXTURE_WRAP_MIRROR_REPEAT	'' Mirrors and repeats the texture in tiled mode
	TEXTURE_WRAP_MIRROR_CLAMP	'' Mirrors and clamps to border the texture in tiled mode
end enum

'' Cubemap layouts
type CubemapLayout as long
enum
	CUBEMAP_LAYOUT_AUTO_DETECT = 0		'' Automatically detect layout type
	CUBEMAP_LAYOUT_LINE_VERTICAL		'' Layout is defined by a vertical line with faces
	CUBEMAP_LAYOUT_LINE_HORIZONTAL		'' Layout is defined by a horizontal line with faces
	CUBEMAP_LAYOUT_CROSS_THREE_BY_FOUR	'' Layout is defined by a 3x4 cross with cubemap faces
	CUBEMAP_LAYOUT_CROSS_FOUR_BY_THREE	'' Layout is defined by a 4x3 cross with cubemap faces
end enum

'' Font type, defines generation method
type FontType as long
enum
	FONT_DEFAULT = 0	'' Default font generation, anti-aliased
	FONT_BITMAP			'' Bitmap font generation, no anti-aliasing
	FONT_SDF			'' SDF font generation, requires external shader
end enum

'' Color blending modes (pre-defined)
type BlendMode as long
enum
	BLEND_ALPHA = 0			'' Blend textures considering alpha (default)
	BLEND_ADDITIVE			'' Blend textures adding colors
	BLEND_MULTIPLIED		'' Blend textures multiplying colors
	BLEND_ADD_COLORS		'' Blend textures adding colors (alternative)
	BLEND_SUBTRACT_COLORS	'' Blend textures subtracting colors (alternative)
	BLEND_ALPHA_PREMULTIPLY	'' Blend premultiplied textures considering alpha
	BLEND_CUSTOM			'' Blend textures using custom src/dst factors (use rlSetBlendFactors())
	BLEND_CUSTOM_SEPARATE	'' Blend textures using custom rgb/alpha separate src/dst factors (use rlSetBlendFactorsSeparate())
end enum

'' Gesture
'' NOTE: Provided as bit-wise flags to enable only desired gestures
type Gesture as long
enum
	GESTURE_NONE = 0			'' No gesture
	GESTURE_TAP = 1				'' Tap gesture
	GESTURE_DOUBLETAP = 2		'' Double tap gesture
	GESTURE_HOLD = 4			'' Hold gesture
	GESTURE_DRAG = 8			'' Drag gesture
	GESTURE_SWIPE_RIGHT = 16	'' Swipe right gesture
	GESTURE_SWIPE_LEFT = 32		'' Swipe left gesture
	GESTURE_SWIPE_UP = 64		'' Swipe up gesture
	GESTURE_SWIPE_DOWN = 128	'' Swipe down gesture
	GESTURE_PINCH_IN = 256		'' Pinch in gesture
	GESTURE_PINCH_OUT = 512		'' Pinch out gesture
end enum

'' Camera system modes
type CameraMode as long
enum
	CAMERA_CUSTOM = 0	'' Camera custom, controlled by user (UpdateCamera() does nothing)
	CAMERA_FREE			'' Camera free mode
	CAMERA_ORBITAL		'' Camera orbital, around target, zoom supported
	CAMERA_FIRST_PERSON	'' Camera first person
	CAMERA_THIRD_PERSON	'' Camera third person
end enum

'' Camera projection
type CameraProjection as long
enum
	CAMERA_PERSPECTIVE = 0	'' Perspective projection
	CAMERA_ORTHOGRAPHIC		'' Orthographic projection
end enum

'' N-patch layout
type NPatchLayout as long
enum
	NPATCH_NINE_PATCH = 0			'' Npatch layout: 3x3 tiles
	NPATCH_THREE_PATCH_VERTICAL		'' Npatch layout: 1x3 tiles
	NPATCH_THREE_PATCH_HORIZONTAL	'' Npatch layout: 3x1 tiles
end enum

'' Callbacks to hook some internal functions
'' WARNING: These callbacks are intended for advanced users
type TraceLogCallback as sub(byval logLevel as long, byval text as const zstring ptr, byval args as va_list) '' Logging: Redirect trace log messages
type LoadFileDataCallback as function(byval fileName as const zstring ptr, byval dataSize as long ptr) as ubyte ptr '' FileIO: Load binary data
type SaveFileDataCallback as function(byval fileName as const zstring ptr, byval data_ as any ptr, byval dataSize as long) as boolean '' FileIO: Save binary data
type LoadFileTextCallback as function(byval fileName as const zstring ptr) as zstring ptr '' FileIO: Load text data
type SaveFileTextCallback as function(byval fileName as const zstring ptr, byval text as zstring ptr) as boolean '' FileIO: Save text data

''------------------------------------------------------------------------------------
'' Global Variables Definition
''------------------------------------------------------------------------------------
'' It's lonely here...

''------------------------------------------------------------------------------------
'' Window and Graphics Device Functions (Module: core)
''------------------------------------------------------------------------------------
'' Window-related functions
declare sub InitWindow(byval width as long, byval height_ as long, byval title as const zstring ptr) 	'' Initialize window and OpenGL context
declare sub CloseWindow() 																				'' Close window and unload OpenGL context 
declare function WindowShouldClose() as boolean															'' Check if application should close (KEY_ESCAPE pressed or windows close icon clicked)
declare function IsWindowReady() as boolean 																'' Check if window has been initialized successfully
declare function IsWindowFullscreen() as boolean 														'' Check if window is currently fullscreen
declare function IsWindowHidden() as boolean 															'' Check if window is currently hidden
declare function IsWindowMinimized() as boolean 															'' Check if window is currently minimized
declare function IsWindowMaximized() as boolean 															'' Check if window is currently maximized
declare function IsWindowFocused() as boolean 															'' Check if window is currently focused
declare function IsWindowResized() as boolean 															'' Check if window has been resized last frame
declare function IsWindowState(byval flag as ulong) as boolean											'' Check if one specific window flag is enabled
declare sub SetWindowState(byval flags as ulong)														'' Set window configuration state using flags
declare sub ClearWindowState(byval flags as ulong)														'' Clear window configuration state flags
declare sub ToggleFullscreen()																			'' Toggle window state: fullscreen/windowed, resizes monitor to match window resolution
declare sub ToggleBorderlessWindowed()																	'' Toggle window state: borderless windowed, resizes window to match monitor resolution
declare sub MaximizeWindow()																			'' Set window state: maximized, if resizable
declare sub MinimizeWindow()																			'' Set window state: minimized, if resizable
declare sub RestoreWindow()																				'' Set window state: not minimized/maximized
declare sub SetWindowIcon(byval image as Image)														'' Set icon for window (single image, RGBA 32bit)
declare sub SetWindowIcons(byval images as Image ptr, byval count as long)								'' Set icon for window (multiple images, RGBA 32bit)
declare sub SetWindowTitle(byval title as const zstring ptr)											'' Set title for window
declare sub SetWindowPosition(byval x as long, byval y as long)											'' Set window position on screen
declare sub SetWindowMonitor(byval monitor as long)														'' Set monitor for the current window
declare sub SetWindowMinSize(byval width as long, byval height as long)								'' Set window minimum dimensions (for FLAG_WINDOW_RESIZABLE)
declare sub SetWindowMaxSize(byval width as long, byval height as long)								'' Set window maximum dimensions (for FLAG_WINDOW_RESIZABLE)
declare sub SetWindowSize(byval width as long, byval height as long)									'' Set window dimensions
declare sub SetWindowOpacity(byval opacity as single)													'' Set window opacity [0.0f..1.0f]
declare sub SetWindowFocused()																			'' Set window focused
declare function GetWindowHandle() as any ptr															'' Get native window handle
declare function GetScreenWidth() as long																'' Get current screen width
declare function GetScreenHeight() as long																'' Get current screen height
declare function GetRenderWidth() as long																'' Get current render width (it considers HiDPI)
declare function GetRenderHeight() as long																'' Get current render height (it considers HiDPI)
declare function GetMonitorCount() as long																'' Get number of connected monitors
declare function GetCurrentMonitor() as long															'' Get current monitor where window is placed
declare function GetMonitorPosition(byval monitor as long) as Vector2									'' Get specified monitor position
declare function GetMonitorWidth(byval monitor as long) as long											'' Get specified monitor width (current video mode used by monitor)
declare function GetMonitorHeight(byval monitor as long) as long										'' Get specified monitor height (current video mode used by monitor)
declare function GetMonitorPhysicalWidth(byval monitor as long) as long									'' Get specified monitor physical width in millimetres
declare function GetMonitorPhysicalHeight(byval monitor as long) as long								'' Get specified monitor physical height in millimetres
declare function GetMonitorRefreshRate(byval monitor as long) as long									'' Get specified monitor refresh rate
declare function GetWindowPosition() as Vector2															'' Get window position XY on monitor
declare function GetWindowScaleDPI() as Vector2															'' Get window scale DPI factor
declare function GetMonitorName(byval monitor as long) as const zstring ptr								'' Get the human-readable, UTF-8 encoded name of the specified monitor
declare sub SetClipboardText(byval text as const zstring ptr)											'' Set clipboard text content
declare function GetClipboardText() as const zstring ptr												'' Get clipboard text content
declare function GetClipboardImage() as Image														'' Get clipboard image content  
declare sub EnableEventWaiting()																		'' Enable waiting for events on EndDrawing(), no automatic event polling
declare sub DisableEventWaiting()																		'' Disable waiting for events on EndDrawing(), automatic events polling

'' Cursor-related functions
declare sub ShowCursor()						'' Shows cursor
declare sub HideCursor()						'' Hides cursor
declare function IsCursorHidden() as boolean		'' Check if cursor is not visible
declare sub EnableCursor()						'' Enables cursor (unlock cursor)
declare sub DisableCursor()						'' Disables cursor (lock cursor)
declare function IsCursorOnScreen() as boolean	'' Check if cursor is on the screen

'' Drawing-related functions
declare sub ClearBackground(byval color as RLColor)															'' Set background color (framebuffer clear color)
declare sub BeginDrawing()																					'' Setup canvas (framebuffer) to start drawing
declare sub EndDrawing()																					'' End canvas drawing and swap buffers (double buffering)
declare sub BeginMode2D(ByVal camera As Camera2D)															'' Begin 2D mode with custom camera (2D)
declare sub EndMode2D()																						'' Ends 2D mode with custom camera
declare sub BeginMode3D(byval camera as Camera3D)															'' Begin 3D mode with custom camera (3D)
declare sub EndMode3D()																						'' Ends 3D mode and returns to default 2D orthographic mode
declare sub BeginTextureMode(byval target as RenderTexture2D)												'' Begin drawing to render texture
declare sub EndTextureMode()																				'' Ends drawing to render texture
declare sub BeginShaderMode(byval shader as Shader)															'' Begin custom shader drawing
declare sub EndShaderMode()																					'' End custom shader drawing (use default shader)
declare sub BeginBlendMode(byval mode as long)																'' Begin blending mode (alpha, additive, multiplied, subtract, custom)
declare sub EndBlendMode()																					'' End blending mode (reset to default: alpha blending)
declare sub BeginScissorMode(byval x as long, byval y as long, byval width as long, byval height as long)	'' Begin scissor mode (define screen area for following drawing)
declare sub EndScissorMode()																				'' End scissor mode
declare sub BeginVrStereoMode(byval config as VrStereoConfig)												'' Begin stereo rendering (requires VR simulator)
declare sub EndVrStereoMode()																				'' End stereo rendering (requires VR simulator)

'' VR stereo config functions for VR simulator
declare function LoadVrStereoConfig(byval device as VrDeviceInfo) as VrStereoConfig	'' Load VR stereo config for VR simulator device parameters
declare sub UnloadVrStereoConfig(byval config as VrStereoConfig)					'' Unload VR stereo config

'' Shader management functions
'' NOTE: Shader functionality is not available on OpenGL 1.1
declare function LoadShader(byval vsFileName as const zstring ptr, byval fsFileName as const zstring ptr) as Shader											'' Load shader from files and bind default locations
declare function LoadShaderFromMemory(byval vsCode as const zstring ptr, byval fsCode as const zstring ptr) as Shader										'' Load shader from code strings and bind default locations
declare function IsShaderValid(byval shader as Shader) as boolean																							'' Check if a shader is valid (loaded on GPU)
declare function GetShaderLocation(byval shader as Shader, byval uniformName as const zstring ptr) as long													'' Get shader uniform location
declare function GetShaderLocationAttrib(byval shader as Shader, byval attribName as const zstring ptr) as long												'' Get shader attribute location
declare sub SetShaderValue(byval shader as Shader, byval locIndex as long, byval value as const any ptr, byval uniformType as long)							'' Set shader uniform value
declare sub SetShaderValueV(byval shader as Shader, byval locIndex as long, byval value as const any ptr, byval uniformType as long, byval count as long)	'' Set shader uniform value vector
declare sub SetShaderValueMatrix(byval shader as Shader, byval locIndex as long, byval mat as Matrix)														'' Set shader uniform value (matrix 4x4)
declare sub SetShaderValueTexture(byval shader as Shader, byval locIndex as long, byval texture as Texture2D)												'' Set shader uniform value for texture (sampler2d)
declare sub UnloadShader(byval shader as Shader)																											'' Unload shader from GPU memory (VRAM)

'' Screen-space-related functions
#define GetMouseRay GetScreenToWorldRay     																									'' Compatibility hack for previous raylib versions
declare function GetScreenToWorldRay(byval position as Vector2, byval camera as Camera) as Ray													'' Get a ray trace from screen position (i.e mouse)
declare function GetScreenToWorldRayEx(byval position as Vector2, byval camera as Camera, byval width as long, byval height as long) as Ray 	'' Get a ray trace from screen position (i.e mouse) in a viewport
declare function GetWorldToScreen(byval position as Vector3, byval camera as Camera) as Vector2													'' Get the screen space position for a 3d world space position
declare function GetWorldToScreenEx(byval position as Vector3, byval camera as Camera, byval width as long, byval height_ as long) as Vector2	'' Get size position for a 3d world space position
declare function GetScreenToWorld2D(byval position as Vector2, byval camera as Camera2D) as Vector2												'' Get the screen space position for a 2d camera world space position
declare function GetWorldToScreen2D(byval position as Vector2, byval camera as Camera2D) as Vector2												'' Get the world space position for a 2d camera screen space position
declare function GetCameraMatrix(byval camera as Camera) as Matrix																				'' Get camera transform matrix (view matrix)
declare function GetCameraMatrix2D(byval camera as Camera2D) as Matrix																			'' Get camera 2d transform matrix

'' Timing-related functions
declare sub SetTargetFPS(byval fps as long)	'' Set target FPS (maximum)
declare function GetFrameTime() as single	'' Get time in seconds for last frame drawn (delta time)
declare function GetTime() as double		'' Get elapsed time in seconds since InitWindow()
declare function GetFPS() as long			'' Get current FPS

'' Custom frame control functions
'' NOTE: Those functions are intended for advanced users that want full control over the frame processing
'' By default EndDrawing() does this job: draws everything + SwapScreenBuffer() + manage frame timing + PollInputEvents()
'' To avoid that behaviour and control frame processes manually, enable in config.h: SUPPORT_CUSTOM_FRAME_CONTROL
declare sub SwapScreenBuffer()					'' Swap back buffer with front buffer (screen drawing)
declare sub PollInputEvents()					'' Register all input events
declare sub WaitTime(byval seconds as double)	'' Wait for some time (halt program execution)

'' Random values generation functions
declare sub SetRandomSeed(byval seed as ulong)																	'' Set the seed for the random number generator
declare function GetRandomValue(byval min as long, byval max as long) as long									'' Get a random value between min and max (both included)
declare function LoadRandomSequence(byval count as ulong, byval min as long , byval max as long) as long ptr 	'' Load random values sequence, no values repeated
declare sub UnloadRandomSequence(byval sequence as long ptr)                   									'' Unload random values sequence

'' Misc. functions
declare sub TakeScreenshot(byval fileName as const zstring ptr)	'' Takes a screenshot of current screen (filename extension defines format)
declare sub SetConfigFlags(byval flags as ulong)				'' Setup init configuration flags (view FLAGS)
declare sub OpenURL(byval url as const zstring ptr)				'' Open URL with default system browser (if available)

'' NOTE: Following functions implemented in module [utils]
''------------------------------------------------------------------
declare sub TraceLog(byval logLevel as long, byval text as const zstring ptr, ...)	'' Show trace log messages (LOG_DEBUG, LOG_INFO, LOG_WARNING, LOG_ERROR...)
declare sub SetTraceLogLevel(byval logLevel as long)								'' Set the current threshold (minimum) log level
declare function MemAlloc(byval size as ulong) as any ptr							'' Internal memory allocator
declare function MemRealloc(byval ptr as any ptr, byval size as ulong) as any ptr	'' Internal memory reallocator
declare sub MemFree(byval ptr as any ptr)											'' Internal memory free

'' Set custom callbacks
'' WARNING: Callbacks setup is intended for advanced users
declare sub SetTraceLogCallback(byval callback as TraceLogCallback)			'' Set custom trace log
declare sub SetLoadFileDataCallback(byval callback as LoadFileDataCallback)	'' Set custom file binary data loader
declare sub SetSaveFileDataCallback(byval callback as SaveFileDataCallback)	'' Set custom file binary data saver
declare sub SetLoadFileTextCallback(byval callback as LoadFileTextCallback)	'' Set custom file text data loader
declare sub SetSaveFileTextCallback(byval callback as SaveFileTextCallback)	'' Set custom file text data saver

'' Files management functions
declare function LoadFileData(byval fileName as const zstring ptr, byval dataSize as long ptr) as ubyte ptr									'' Load file data as byte array (read)
declare sub UnloadFileData(byval data as ubyte ptr)																						'' Unload file data allocated by LoadFileData()
declare function SaveFileData(byval fileName as const zstring ptr, byval data as any ptr, byval dataSize as long) as boolean				'' Save data to file from byte array (write), returns true on success
declare function ExportDataAsCode(byval data as const ubyte ptr, byval dataSize as long, byval fileName as const zstring ptr) as boolean	'' Export data to code (.h), returns true on success
declare function LoadFileText(byval fileName as const zstring ptr) as zstring ptr															'' Load text data from file (read), returns a '\0' terminated string
declare sub UnloadFileText(byval text as zstring ptr)																						'' Unload file text data allocated by LoadFileText()
declare function SaveFileText(byval fileName as const zstring ptr, byval text as zstring ptr) as boolean										'' Save text data to file (write), string must be '\0' terminated, returns true on success
''------------------------------------------------------------------

'' File system functions
declare function FileExists(byval fileName as const zstring ptr) as boolean																					'' Check if file exists
declare function DirectoryExists(byval dirPath as const zstring ptr) as boolean																				'' Check if a directory path exists
declare function IsFileExtension(byval fileName as const zstring ptr, byval ext as const zstring ptr) as boolean												'' Check file extension (including point: .png, .wav)
declare function GetFileLength(byval fileName as const zstring ptr) as long																					'' Get file length in bytes (NOTE: GetFileSize() conflicts with windows.h)
declare function GetFileExtension(byval fileName as const zstring ptr) as const zstring ptr																	'' Get pointer to extension for a filename string (includes dot: '.png')
declare function GetFileName(byval filePath as const zstring ptr) as const zstring ptr																		'' Get pointer to filename for a path string
declare function GetFileNameWithoutExt(byval filePath as const zstring ptr) as const zstring ptr															'' Get filename string without extension (uses static string)
declare function GetDirectoryPath(byval filePath as const zstring ptr) as const zstring ptr																	'' Get full path for a given fileName with path (uses static string)
declare function GetPrevDirectoryPath(byval dirPath as const zstring ptr) as const zstring ptr																'' Get previous directory path for a given path (uses static string)
declare function GetWorkingDirectory() as const zstring ptr																									'' Get current working directory (uses static string)
declare function GetApplicationDirectory() as const zstring ptr																								'' Get the directory of the running application (uses static string)
declare function MakeDirectory(byval dirPath as const zstring ptr) as long																					'' Create directories (including full path requested), returns 0 on success
declare function ChangeDirectory(byval dir_ as const zstring ptr) as boolean																					'' Change working directory, return true on success
declare function IsPathFile(byval path as const zstring ptr) as boolean																						'' Check if a given path is a file or a directory
declare function IsFileNameValid(byval fileNam as const zstring ptr) as boolean																				'' Check if fileName is valid for the platform/OS
declare function LoadDirectoryFiles(byval dirPath as const zstring ptr) as FilePathList																		'' Load directory filepaths
declare function LoadDirectoryFilesEx(byval basePath as const zstring ptr, byval filter as const zstring ptr, byval scanSubdirs as boolean) as FilePathList	'' Load directory filepaths with extension filtering and recursive directory scan. Use 'DIR' in the filter string to include directories in the result
declare sub UnloadDirectoryFiles(byval files as FilePathList)																								'' Unload filepaths
declare function IsFileDropped() as boolean																													'' Check if a file has been dropped into window
declare function LoadDroppedFiles() as FilePathList																											'' Load dropped filepaths
declare sub UnloadDroppedFiles(byval files as FilePathList)																									'' Unload dropped filepaths
declare function GetFileModTime(byval fileName as const zstring ptr) as long																				'' Get file modification time (last write time)

'' Compression/Encoding functionality
declare function CompressData(byval data_ as const ubyte ptr, byval dataSize as long, byval compDataSize as long ptr) as ubyte ptr		'' Compress data (DEFLATE algorithm), memory must be MemFree()
declare function DecompressData(byval compData as const ubyte ptr, byval compDataSize as long, byval dataSize as long ptr) as ubyte ptr	'' Decompress data (DEFLATE algorithm), memory must be MemFree()
declare function EncodeDataBase64(byval data_ as const ubyte ptr, byval dataSize as long, byval outputSize as long ptr) as zstring ptr	'' Encode data to Base64 string, memory must be MemFree()
declare function DecodeDataBase64(byval data_ as const ubyte ptr, byval outputSize as long ptr) as ubyte ptr							'' Decode Base64 string data, memory must be MemFree()
declare function ComputeCRC32(byval data_ as const ubyte ptr, byval dataSize as long) as ulong     										'' Compute CRC32 hash code
declare function ComputeMD5(byval data_ as const ubyte ptr, byval dataSize as long) as ulong ptr      									'' Compute MD5 hash code, returns static int[4] (16 bytes)
declare function ComputeSHA1(byval data_ as const ubyte ptr, byval dataSize as long) as ulong ptr      									'' Compute SHA1 hash code, returns static int[5] (20 bytes)

'' Automation events functionality
declare function LoadAutomationEventList(byval fileName as const zstring ptr) as AutomationEventList							'' Load automation events list from file, NULL for empty list, capacity = MAX_AUTOMATION_EVENTS
declare sub UnloadAutomationEventList(byval list_ as AutomationEventList ptr)													'' Unload automation events list from file
declare function ExportAutomationEventList(byval list_ as AutomationEventList, byval fileName as const zstring ptr) as boolean	'' Export automation events list as text file
declare sub SetAutomationEventList(byval list_ as AutomationEventList ptr)														'' Set automation event list to record to
declare sub SetAutomationEventBaseFrame(byval frame_ as long)																	'' Set automation event internal base frame to start recording
declare sub StartAutomationEventRecording()																						'' Start recording automation events (AutomationEventList must be set)
declare sub StopAutomationEventRecording()																						'' Stop recording automation events
declare sub PlayAutomationEvent(byval frame_ as AutomationEvent)																'' Play a recorded automation event

''------------------------------------------------------------------------------------
'' Input Handling Functions (Module: core)
''------------------------------------------------------------------------------------

'' Input-related functions: keyboard
declare function IsKeyPressed(byval key as long) as boolean			'' Check if a key has been pressed once
declare function IsKeyPressedRepeat(byval key as long) as boolean	'' Check if a key has been pressed again
declare function IsKeyDown(byval key as long) as boolean				'' Check if a key is being pressed
declare function IsKeyReleased(byval key as long) as boolean			'' Check if a key has been released once
declare function IsKeyUp(byval key as long) as boolean				'' Check if a key is NOT being pressed
declare function GetKeyPressed() as long							'' Get key pressed (keycode), call it multiple times for keys queued, returns 0 when the queue is empty
declare function GetCharPressed() as long							'' Get char pressed (unicode), call it multiple times for chars queued, returns 0 when the queue is empty
declare sub SetExitKey(byval key as long)							'' Set a custom key to exit program (default is ESC)

'' Input-related functions: gamepads
declare function IsGamepadAvailable(byval gamepad as long) as boolean																	'' Check if a gamepad is available
declare function GetGamepadName(byval gamepad as long) as const zstring ptr																'' Get gamepad internal name id
declare function IsGamepadButtonPressed(byval gamepad as long, byval button as long) as boolean											'' Check if a gamepad button has been pressed once
declare function IsGamepadButtonDown(byval gamepad as long, byval button as long) as boolean												'' Check if a gamepad button is being pressed
declare function IsGamepadButtonReleased(byval gamepad as long, byval button as long) as boolean											'' Check if a gamepad button has been released once
declare function IsGamepadButtonUp(byval gamepad as long, byval button as long) as boolean												'' Check if a gamepad button is NOT being pressed
declare function GetGamepadButtonPressed() as long																						'' Get the last gamepad button pressed
declare function GetGamepadAxisCount(byval gamepad as long) as long																		'' Get gamepad axis count for a gamepad
declare function GetGamepadAxisMovement(byval gamepad as long, byval axis as long) as single											'' Get axis movement value for a gamepad axis
declare function SetGamepadMappings(byval mappings as const zstring ptr) as long														'' Set internal gamepad mappings (SDL_GameControllerDB)
declare sub SetGamepadVibration(byval gamepad as long, byval leftMotor as single, byval rightMotor as single, byval duration as single)	'' Set gamepad vibration for both motors (duration in seconds)

'' Input-related functions: mouse
declare function IsMouseButtonPressed(byval button as long) as boolean		'' Check if a mouse button has been pressed once
declare function IsMouseButtonDown(byval button as long) as boolean			'' Check if a mouse button is being pressed
declare function IsMouseButtonReleased(byval button as long) as boolean		'' Check if a mouse button has been released once
declare function IsMouseButtonUp(byval button as long) as boolean			'' Check if a mouse button is NOT being pressed
declare function GetMouseX() as long										'' Get mouse position X
declare function GetMouseY() as long										'' Get mouse position Y
declare function GetMousePosition() as Vector2								'' Get mouse position XY
declare function GetMouseDelta() as Vector2									'' Get mouse delta between frames
declare sub SetMousePosition(byval x as long, byval y as long)				'' Set mouse position XY
declare sub SetMouseOffset(byval offsetX as long, byval offsetY as long)	'' Set mouse offset
declare sub SetMouseScale(byval scaleX as single, byval scaleY as single)	'' Set mouse scaling
declare function GetMouseWheelMove() as single								'' Get mouse wheel movement for X or Y, whichever is larger
declare function GetMouseWheelMoveV() as Vector2							'' Get mouse wheel movement for both X and Y
declare sub SetMouseCursor(byval cursor as long)							'' Set mouse cursor

''Input-related functions: touch
declare function GetTouchX() as long								'' Get touch position X for touch point 0 (relative to screen size)
declare function GetTouchY() as long								'' Get touch position Y for touch point 0 (relative to screen size)
declare function GetTouchPosition(byval index as long) as Vector2	'' Get touch position XY for a touch point index (relative to screen size)
declare function GetTouchPointId(byval index as long) as long		'' Get touch point identifier for given index
declare function GetTouchPointCount() as long						'' Get number of touch points

''------------------------------------------------------------------------------------
'' Gestures and Touch Handling Functions (Module: rgestures)
''------------------------------------------------------------------------------------
declare sub SetGesturesEnabled(byval flags as ulong)					'' Enable a set of gestures using flags
declare function IsGestureDetected(byval gesture as ulong) as boolean	'' Check if a gesture have been detected
declare function GetGestureDetected() as long							'' Get latest detected gesture
declare function GetGestureHoldDuration() as single						'' Get gesture hold time in seconds
declare function GetGestureDragVector() as Vector2						'' Get gesture drag vector
declare function GetGestureDragAngle() as single						'' Get gesture drag angle
declare function GetGesturePinchVector() as Vector2						'' Get gesture pinch delta
declare function GetGesturePinchAngle() as single						'' Get gesture pinch angle

''------------------------------------------------------------------------------------
'' Camera System Functions (Module: rcamera)
''------------------------------------------------------------------------------------
declare sub UpdateCamera(byval camera as Camera ptr, byval mode as long)															'' Update camera position for selected mode
declare sub UpdateCameraPro(byval camera as Camera ptr, byval movement as Vector3, byval rotation as Vector3, byval zoom as single)	'' Update camera movement/rotation

''------------------------------------------------------------------------------------
'' Basic Shapes Drawing Functions (Module: shapes)
''------------------------------------------------------------------------------------
'' Set texture and rectangle to be used on shapes drawing
'' NOTE: It can be useful when using basic shapes and one single font,
'' defining a font char white rectangle would allow drawing everything in a single draw call
declare sub SetShapesTexture(byval texture as Texture2D, byval source as Rectangle)	'' Set texture and rectangle to be used on shapes drawing
declare function GetShapesTexture() as Texture2D									'' Get texture that is used for shapes drawing
declare function GetShapesTextureRectangle() as Rectangle								'' Get texture source rectangle that is used for shapes drawing

'' Basic shapes drawing functions
declare sub DrawPixel(byval posX as long, byval posY as long, byval color as RLColor)	'' Draw a pixel using geometry [Can be slow, use with care]
declare sub DrawPixelV(byval position as Vector2, byval color as RLColor)				'' Draw a pixel using geometry (Vector version) [Can be slow, use with care]
declare sub DrawLine(byval startPosX as long, byval startPosY as long, byval endPosX as long, byval endPosY as long, byval color as RLColor)	'' Draw a line 
declare sub DrawLineV(byval startPos as Vector2, byval endPos as Vector2, byval color as RLColor)												'' Draw a line (using gl lines)
declare sub DrawLineEx(byval startPos as Vector2, byval endPos as Vector2, byval thick as single, byval color as RLColor)						'' Draw a line (using triangles/quads)
declare sub DrawLineStrip(byval points as const Vector2 ptr, byval pointCount as long, byval color as RLColor)										'' Draw lines sequence (using gl lines)
declare sub DrawLineBezier(byval startPos as Vector2, byval endPos as Vector2, byval thick as single, byval color as RLColor)					'' Draw line segment cubic-bezier in-out interpolation
declare sub DrawCircle(byval centerX as long, byval centerY as long, byval radius as single, byval color as RLColor)																		'' Draw a color-filled circle
declare sub DrawCircleSector(byval center as Vector2, byval radius as single, byval startAngle as single, byval endAngle as single, byval segments as long, byval color as RLColor)			'' Draw a piece of a circle
declare sub DrawCircleSectorLines(byval center as Vector2, byval radius as single, byval startAngle as single, byval endAngle as single, byval segments as long, byval color as RLColor)	'' Draw circle sector outline
declare sub DrawCircleGradient(byval centerX as long, byval centerY as long, byval radius as single, byval inner as RLColor, byval outer as RLColor)										'' Draw a gradient-filled circle
declare sub DrawCircleV(byval center as Vector2, byval radius as single, byval color as RLColor)																							'' Draw a color-filled circle (Vector version)
declare sub DrawCircleLines(byval centerX as long, byval centerY as long, byval radius as single, byval color as RLColor)																	'' Draw circle outline
declare sub DrawCircleLinesV(byval center as Vector2, byval radius as single, byval color as RLColor)																						'' Draw circle outline (Vector version)
declare sub DrawEllipse(byval centerX as long, byval centerY as long, byval radiusH as single, byval radiusV as single, byval color as RLColor)			'' Draw ellipse
declare sub DrawEllipseLines(byval centerX as long, byval centerY as long, byval radiusH as single, byval radiusV as single, byval color as RLColor)	'' Draw ellipse outline
declare sub DrawRing(byval center as Vector2, byval innerRadius as single, byval outerRadius as single, byval startAngle as single, byval endAngle as single, byval segments as long, byval color as RLColor)		'' Draw ring
declare sub DrawRingLines(byval center as Vector2, byval innerRadius as single, byval outerRadius as single, byval startAngle as single, byval endAngle as single, byval segments as long, byval color as RLColor)	'' Draw ring outline
declare sub DrawRectangle(byval posX as long, byval posY as long, byval width as long, byval height_ as long, byval color as RLColor)	'' Draw a color-filled rectangle
declare sub DrawRectangleV(byval position as Vector2, byval size as Vector2, byval color as RLColor)									'' Draw a color-filled rectangle (Vector version)
declare sub DrawRectangleRec(byval rec as Rectangle, byval color as RLColor)															'' Draw a color-filled rectangle
declare sub DrawRectanglePro(byval rec as Rectangle, byval origin as Vector2, byval rotation as single, byval color as RLColor)			'' Draw a color-filled rectangle with pro parameters
declare sub DrawRectangleGradientV(byval posX as long, byval posY as long, byval width as long, byval height_ as long, byval top as RLColor, byval bottom as RLColor)	'' Draw a vertical-gradient-filled rectangle
declare sub DrawRectangleGradientH(byval posX as long, byval posY as long, byval width as long, byval height_ as long, byval left as RLColor, byval right as RLColor)	'' Draw a horizontal-gradient-filled rectangle
declare sub DrawRectangleGradientEx(byval rec as Rectangle, byval topLeft as RLColor, byval bottomLeft as RLColor, byval topRight as RLColor, byval bottomRight as RLColor)						'' Draw a gradient-filled rectangle with custom vertex colors
declare sub DrawRectangleLines(byval posX as long, byval posY as long, byval width as long, byval height_ as long, byval color as RLColor)	'' Draw rectangle outline
declare sub DrawRectangleLinesEx(byval rec as Rectangle, byval lineThick as single, byval color as RLColor)									'' Draw rectangle outline with extended parameters
declare sub DrawRectangleRounded(byval rec as Rectangle, byval roundness as single, byval segments as long, byval color as RLColor)										'' Draw rectangle with rounded edges
declare sub DrawRectangleRoundedLines(byval rec as Rectangle, byval roundness as single, byval segments as long, byval lineThick as single, byval color as RLColor)		'' Draw rectangle lines with rounded edges
declare sub DrawRectangleRoundedLinesEx(byval rec as Rectangle, byval roundness as single, byval segments as long, byval lineThick as single, byval color as RLColor)	'' Draw rectangle with rounded edges outline
declare sub DrawTriangle(byval v1 as Vector2, byval v2 as Vector2, byval v3 as Vector2, byval color as RLColor)			'' Draw a color-filled triangle (vertex in counter-clockwise order!)
declare sub DrawTriangleLines(byval v1 as Vector2, byval v2 as Vector2, byval v3 as Vector2, byval color as RLColor)	'' Draw triangle outline (vertex in counter-clockwise order!)
declare sub DrawTriangleFan(byval points as const Vector2 ptr, byval pointCount as long, byval color as RLColor)				'' Draw a triangle fan defined by points (first vertex is the center)
declare sub DrawTriangleStrip(byval points as const Vector2 ptr, byval pointCount as long, byval color as RLColor)			'' Draw a triangle strip defined by points
declare sub DrawPoly(byval center as Vector2, byval sides as long, byval radius as single, byval rotation as single, byval color as RLColor)									'' Draw a regular polygon (Vector version)
declare sub DrawPolyLines(byval center as Vector2, byval sides as long, byval radius as single, byval rotation as single, byval color as RLColor)								'' Draw a polygon outline of n sides
declare sub DrawPolyLinesEx(byval center as Vector2, byval sides as long, byval radius as single, byval rotation as single, byval lineThick as single, byval color as RLColor)	'' Draw a polygon outline of n sides with extended parameters

'' Splines drawing functions
declare sub DrawSplineLinear(byval points as const Vector2 ptr, byval pointCount as long, byval thick as single, byval color as RLColor)									'' Draw spline: Linear, minimum 2 points
declare sub DrawSplineBasis(byval points as const Vector2 ptr, byval pointCount as long, byval thick as single, byval color as RLColor)										'' Draw spline: B-Spline, minimum 4 points
declare sub DrawSplineCatmullRom(byval points as const Vector2 ptr, byval pointCount as long, byval thick as single, byval color as RLColor)								'' Draw spline: Catmull-Rom, minimum 4 points
declare sub DrawSplineBezierQuadratic(byval points as const Vector2 ptr, byval pointCount as long, byval thick as single, byval color as RLColor)							'' Draw spline: Quadratic Bezier, minimum 3 points (1 control point): [p1, c2, p3, c4...]
declare sub DrawSplineBezierCubic(byval points as const Vector2 ptr, byval pointCount as long, byval thick as single, byval color as RLColor)									'' Draw spline: Cubic Bezier, minimum 4 points (2 control points): [p1, c2, c3, p4, c5, c6...]
declare sub DrawSplineSegmentLinear(byval p1 as Vector2, byval p2 as Vector2, byval thick as single, byval color as RLColor)												'' Draw spline segment: Linear, 2 points
declare sub DrawSplineSegmentBasis(byval p1 as Vector2, byval p2 as Vector2, byval p3 as Vector2, byval p4 as Vector2, byval thick as single, byval color as RLColor)		'' Draw spline segment: B-Spline, 4 points
declare sub DrawSplineSegmentCatmullRom(byval p1 as Vector2, byval p2 as Vector2, byval p3 as Vector2, byval p4 as Vector2, byval thick as single, byval color as RLColor)	'' Draw spline segment: Catmull-Rom, 4 points
declare sub DrawSplineSegmentBezierQuadratic(byval p1 as Vector2, byval c2 as Vector2, byval p3 as Vector2, byval thick as single, byval color as RLColor)					'' Draw spline segment: Quadratic Bezier, 2 points, 1 control point
declare sub DrawSplineSegmentBezierCubic(byval p1 as Vector2, byval c2 as Vector2, byval c3 as Vector2, byval p4 as Vector2, byval thick as Single, byval color as RLColor)	'' Draw spline segment: Cubic Bezier, 2 points, 2 control points

'' Spline segment point evaluation functions, for a given t [0.0f .. 1.0f]
declare function GetSplinePointLinear(byval startPos as Vector2, byval endPos as Vector2, byval t as single) as Vector2											'' Get (evaluate) spline point: Linear
declare function GetSplinePointBasis(byval p1 as Vector2, byval p2 as Vector2, byval p3 as Vector2, byval p4 as Vector2, byval t as single) as Vector2			'' Get (evaluate) spline point: B-Spline
declare function GetSplinePointCatmullRom(byval p1 as Vector2, byval p2 as Vector2, byval p3 as Vector2, byval p4 as Vector2, byval t as single) as Vector2		'' Get (evaluate) spline point: Catmull-Rom
declare function GetSplinePointBezierQuad(byval p1 as Vector2, byval c2 as Vector2, byval p3 as Vector2, byval t as single) as Vector2							'' Get (evaluate) spline point: Quadratic Bezier
declare function GetSplinePointBezierCubic(byval p1 as Vector2, byval c2 as Vector2, byval c3 as Vector2, byval p4 as Vector2, byval t as single) as Vector2	'' Get (evaluate) spline point: Cubic Bezier

'' Basic shapes collision detection functions
declare function CheckCollisionRecs(byval rec1 as Rectangle, byval rec2 as Rectangle) as boolean																									'' Check collision between two rectangles
declare function CheckCollisionCircles(byval center1 as Vector2, byval radius1 as single, byval center2 as Vector2, byval radius2 as single) as boolean											'' Check collision between two circles
declare function CheckCollisionCircleRec(byval center as Vector2, byval radius as single, byval rec as Rectangle) as boolean																		'' Check collision between circle and rectangle
declare function CheckCollisionCircleLine(byval center as Vector2, byval radius as single, byval p1 as Vector2, byval p2 as Vector2) as boolean													'' Check if circle collides with a line created betweeen two points [p1] and [p2]
declare function CheckCollisionPointRec(byval point as Vector2, byval rec as Rectangle) as boolean																								'' Check if point is inside rectangle
declare function CheckCollisionPointCircle(byval point as Vector2, byval center as Vector2, byval radius as single) as boolean																	'' Check if point is inside circle
declare function CheckCollisionPointTriangle(byval point as Vector2, byval p1 as Vector2, byval p2 as Vector2, byval p3 as Vector2) as boolean													'' Check if point is inside a triangle
declare function CheckCollisionPointLine(byval point as Vector2, byval p1 as Vector2, byval p2 as Vector2, byval threshold as long) as boolean													'' Check if point belongs to line created between two points [p1] and [p2] with defined margin in pixels [threshold]
declare function CheckCollisionPointPoly(byval point as Vector2, byval points as const Vector2 ptr, byval pointCount as long) as boolean																'' Check if point is within a polygon described by array of vertices
declare function CheckCollisionLines(byval startPos1 as Vector2, byval endPos1 as Vector2, byval startPos2 as Vector2, byval endPos2 as Vector2, byval collisionPoint as Vector2 ptr) as boolean	'' Check the collision between two lines defined by two points each, returns collision point by reference
declare function GetCollisionRec(byval rec1 as Rectangle, byval rec2 as Rectangle) as Rectangle																									'' Get collision rectangle for two rectangles collision

''------------------------------------------------------------------------------------
'' Texture Loading and Drawing Functions (Module: textures)
''------------------------------------------------------------------------------------

'' Image loading functions
'' NOTE: These functions do not require GPU access
declare function LoadImage(byval fileName as const zstring ptr) as Image																									'' Load image from file into CPU memory (RAM)
declare function LoadImageRaw(byval fileName as const zstring ptr, byval width as long, byval height_ as long, byval format_ as long, byval headerSize as long) as Image	'' Load image from RAW file data
declare function LoadImageAnim(byval fileName as const zstring ptr, byval frames as long ptr) as Image																		'' Load image sequence from file (frames appended to image.data)
declare function LoadImageAnimFromMemory(byval fileType as const zstring ptr, byval fileData as const ubyte ptr, byval dataSize as long, byval frames as long ptr) as Image	'' Load image sequence from memory buffer
declare function LoadImageFromMemory(byval fileType as const zstring ptr, byval fileData as const ubyte ptr, byval dataSize as long) as Image								'' Load image from memory buffer, fileType refers to extension: i.e. '.png'
declare function LoadImageFromTexture(byval texture as Texture2D) as Image																									'' Load image from GPU texture data
declare function LoadImageFromScreen() as Image																																'' Load image from screen buffer and (screenshot)
declare function IsImageValid(byval image as Image) as boolean																			'' Check if an image is valid (data and parameters)
declare sub UnloadImage(byval image as Image)																							'' Unload image from CPU memory (RAM)
declare function ExportImage(byval image as Image, byval fileName as const zstring ptr) as boolean										'' Export image data to file, returns true on success
declare function ExportImageToMemory(byval image as Image, byval fileType as const zstring ptr, byval fileSize as long ptr) as zstring ptr	'' Export image to memory buffer
declare function ExportImageAsCode(byval image as Image, byval fileName as const zstring ptr) as boolean								'' Export image as code file defining an array of bytes, returns true on success

'' Image generation functions
declare function GenImageColor(byval width as long, byval height_ as long, byval color as RLColor) as Image																		'' Generate image: plain color
declare function GenImageGradientLinear(byval width as long, byval height_ as long, byval direction as long, byval start_ as RLColor, byval end_ as RLColor) as Image				'' Generate image: linear gradient, direction in degrees [0..360], 0=Vertical gradient
declare function GenImageGradientRadial(byval width as long, byval height_ as long, byval density as single, byval inner as RLColor, byval outer as RLColor) as Image				'' Generate image: radial gradient
declare function GenImageGradientSquare(byval width as long, byval height_ as long, byval density as single, byval inner as RLColor, byval outer as RLColor) as Image				'' Generate image: square gradient
declare function GenImageChecked(byval width as long, byval height_ as long, byval checksX as long, byval checksY as long, byval col1 as RLColor, byval col2 as RLColor) as Image	'' Generate image: checked
declare function GenImageWhiteNoise(byval width as long, byval height_ as long, byval factor as single) as Image																	'' Generate image: white noise
declare function GenImagePerlinNoise(byval width as long, byval height_ as long, byval offsetX as long, byval offsetY as long, byval scale as single) as Image						'' Generate image: perlin noise
declare function GenImageCellular(byval width as long, byval height_ as long, byval tileSize as long) as Image																		'' Generate image: cellular algorithm, bigger tileSize means bigger cells
declare function GenImageText(byval width as long, byval height_ as long, byval text_ as const zstring ptr) as Image																'' Generate image: grayscale image from text data

'Image manipulation functions
declare function ImageCopy(byval image as Image) as Image																														'' Create an image duplicate (useful for transformations)
declare function ImageFromImage(byval image as Image, byval rec as Rectangle) as Image																							'' Create an image from another image piece
declare function ImageFromChannel(byval image as Image, byval selectedChannel as long) as Image																				'' Create an image from a selected channel of another image (GRAYSCALE)
declare function ImageText(byval text as const zstring ptr, byval fontSize as long, byval color as RLColor) as Image															'' Create an image from text (default font)
declare function ImageTextEx(byval font as Font, byval text as const zstring ptr, byval fontSize as single, byval spacing as single, byval tint as RLColor) as Image			'' Create an image from text (custom sprite font)
declare sub ImageFormat(byval image as Image ptr, byval newFormat as long)																										'' Convert image data to desired format
declare sub ImageToPOT(byval image as Image ptr, byval fill as RLColor)																										'' Convert image to POT (power-of-two)
declare sub ImageCrop(byval image as Image ptr, byval crop as Rectangle)																										'' Crop an image to a defined rectangle
declare sub ImageAlphaCrop(byval image as Image ptr, byval threshold as single)																								'' Crop image depending on alpha value
declare sub ImageAlphaClear(byval image as Image ptr, byval color as RLColor, byval threshold as single)																		'' Clear alpha channel to desired color
declare sub ImageAlphaMask(byval image as Image ptr, byval alphaMask as Image)																									'' Apply alpha mask to image
declare sub ImageAlphaPremultiply(byval image as Image ptr)																													'' Premultiply alpha channel
declare sub ImageBlurGaussian(byval image as Image ptr, byval blurSize as long)																								'' Apply Gaussian blur using a box blur approximation
declare sub ImageKernelConvolution(byval image as Image ptr, byval kernel as const single ptr, byval kernelSize as long) 														'' Apply custom square convolution kernel to image
declare sub ImageResize(byval image as Image ptr, byval newWidth as long, byval newHeight as long)																				'' Resize image (Bicubic scaling algorithm)
declare sub ImageResizeNN(byval image as Image ptr, byval newWidth as long, byval newHeight as long)																			'' Resize image (Nearest-Neighbor scaling algorithm)
declare sub ImageResizeCanvas(byval image as Image ptr, byval newWidth as long, byval newHeight as long, byval offsetX as long, byval offsetY as long, byval fill as RLColor)	'' Resize canvas and fill with color
declare sub ImageMipmaps(byval image as Image ptr)																																'' Compute all mipmap levels for a provided image
declare sub ImageDither(byval image as Image ptr, byval rBpp as long, byval gBpp as long, byval bBpp as long, byval aBpp as long)												'' Dither image data to 16bpp or lower (Floyd-Steinberg dithering)
declare sub ImageFlipVertical(byval image as Image ptr)																														'' Flip image vertically
declare sub ImageFlipHorizontal(byval image as Image ptr)																														'' Flip image horizontally
declare sub ImageRotate(byval image as Image ptr, byval degrees as long)																										'' Rotate image by input angle in degrees (-359 to 359)
declare sub ImageRotateCW(byval image as Image ptr)																															'' Rotate image clockwise 90deg
declare sub ImageRotateCCW(byval image as Image ptr)																															'' Rotate image counter-clockwise 90deg
declare sub ImageColorTint(byval image as Image ptr, byval color as RLColor)																									'' Modify image color: tint
declare sub ImageColorInvert(byval image as Image ptr)																															'' Modify image color: invert
declare sub ImageColorGrayscale(byval image as Image ptr)																														'' Modify image color: grayscale
declare sub ImageColorContrast(byval image as Image ptr, byval contrast as single)																								'' Modify image color: contrast (-100 to 100)
declare sub ImageColorBrightness(byval image as Image ptr, byval brightness as long)																							'' Modify image color: brightness (-255 to 255)
declare sub ImageColorReplace(byval image as Image ptr, byval color as RLColor, byval replace as RLColor)																		'' Modify image color: replace color
declare function LoadImageColors(byval image as Image) as RLColor ptr																											'' Load color data from image as a Color array (RGBA - 32bit)
declare function LoadImagePalette(byval image as Image, byval maxPaletteSize as long, byval colorCount as long ptr) as RLColor ptr												'' Load colors palette from image as a Color array (RGBA - 32bit)
declare sub UnloadImageColors(byval colors as RLColor ptr)																														'' Unload color data loaded with LoadImageColors()
declare sub UnloadImagePalette(byval colors as RLColor ptr)																														'' Unload colors palette loaded with LoadImagePalette()
declare function GetImageAlphaBorder(byval image as Image, byval threshold as single) as Rectangle																				'' Get image alpha border rectangle
declare function GetImageColor(byval image as Image, byval x as long, byval y as long) as RLColor																				'' Get image pixel color at (x, y) position

'' Image drawing functions
'' NOTE: Image software-rendering functions (CPU)
declare sub ImageClearBackground(byval dst as Image ptr, byval color as RLColor)																																'' Clear image background with given color
declare sub ImageDrawPixel(byval dst as Image ptr, byval posX as long, byval posY as long, byval color as RLColor)																								'' Draw pixel within an image
declare sub ImageDrawPixelV(byval dst as Image ptr, byval position as Vector2, byval color as RLColor)																											'' Draw pixel within an image (Vector version)
declare sub ImageDrawLine(byval dst as Image ptr, byval startPosX as long, byval startPosY as long, byval endPosX as long, byval endPosY as long, byval color as RLColor)										'' Draw line within an image
declare sub ImageDrawLineV(byval dst as Image ptr, byval start as Vector2, byval end_ as Vector2, byval color as RLColor)																						'' Draw line within an image (Vector version)
declare sub ImageDrawLineEx(byval dst as Image ptr, byval start as Vector2, byval end_ as Vector2, byval thick as long, byval color as RLColor)																	'' Draw a line defining thickness within an image
declare sub ImageDrawCircle(byval dst as Image ptr, byval centerX as long, byval centerY as long, byval radius as long, byval color as RLColor)																	'' Draw a filled circle within an image
declare sub ImageDrawCircleV(byval dst as Image ptr, byval center as Vector2, byval radius as long, byval color as RLColor)																						'' Draw a filled circle within an image (Vector version)
declare sub ImageDrawCircleLines(byval dst as Image ptr, byval centerX as long, byval centerY as long, byval radius as long, byval color_ as RLColor)															'' Draw circle outline within an image
declare sub ImageDrawCircleLinesV(byval dst as Image ptr, byval center as Vector2, byval radius as long, byval color_ as RLColor)																				'' Draw circle outline within an image (Vector version)
declare sub ImageDrawRectangle(byval dst as Image ptr, byval posX as long, byval posY as long, byval width as long, byval height_ as long, byval color as RLColor)												'' Draw rectangle within an image
declare sub ImageDrawRectangleV(byval dst as Image ptr, byval position as Vector2, byval size as Vector2, byval color as RLColor)																				'' Draw rectangle within an image (Vector version)
declare sub ImageDrawRectangleRec(byval dst as Image ptr, byval rec as Rectangle, byval color as RLColor)																										'' Draw rectangle within an image
declare sub ImageDrawRectangleLines(byval dst as Image ptr, byval rec as Rectangle, byval thick as long, byval color as RLColor)																				'' Draw rectangle lines within an image
declare sub ImageDrawTriangle(byval dst as Image ptr, byval v1 as Vector2, byval v2 as Vector2, byval v3 as Vector2, byval color as RLColor)																	'' Draw triangle within an image
declare sub ImageDrawTriangleEx(byval dst as Image ptr, byval v1 as Vector2, byval v2 as Vector2, byval v3 as Vector2, byval c1 as RLColor, byval c2 as RLColor, byval c3 as RLColor) 							'' Draw triangle with interpolated colors within an image
declare sub ImageDrawTriangleLines(byval dst as Image ptr, byval v1 as Vector2, byval v2 as Vector2, byval v3 as Vector2, byval color as RLColor)																'' Draw triangle outline within an image
declare sub ImageDrawTriangleFan(byval dst as Image ptr, byval points as Vector2 ptr, byval pointCount as long, byval color as RLColor)																			'' Draw a triangle fan defined by points within an image (first vertex is the center)
declare sub ImageDrawTriangleStrip(byval dst as Image ptr, byval points as Vector2 ptr, byval pointCount as long, byval color as RLColor)																		'' Draw a triangle strip defined by points within an image
declare sub ImageDraw(byval dst as Image ptr, byval src as Image, byval srcRec as Rectangle, byval dstRec as Rectangle, byval tint as RLColor)																	'' Draw a source image within a destination image (tint applied to source)
declare sub ImageDrawText(byval dst as Image ptr, byval text as const zstring ptr, byval posX as long, byval posY as long, byval fontSize as long, byval color as RLColor)										'' Draw text (using default font) within an image (destination)
declare sub ImageDrawTextEx(byval dst as Image ptr, byval font as Font, byval text as const zstring ptr, byval position as Vector2, byval fontSize as single, byval spacing as single, byval tint as RLColor)	'' Draw text (custom sprite font) within an image (destination)

'' Texture loading functions
'' NOTE: These functions require GPU access
declare function LoadTexture(byval fileName as const zstring ptr) as Texture2D									'' Load texture from file into GPU memory (VRAM)
declare function LoadTextureFromImage(byval image as Image) as Texture2D										'' Load texture from image data
declare function LoadTextureCubemap(byval image as Image, byval layout as long) as TextureCubemap				'' Load cubemap from image, multiple image cubemap layouts supported
declare function LoadRenderTexture(byval width as long, byval height_ as long) as RenderTexture2D				'' Load texture for rendering (framebuffer)
declare function IsTextureValid(byval texture as Texture2D) as boolean											'' Check if a texture is valid (loaded in GPU)
declare sub UnloadTexture(byval texture as Texture2D)															'' Unload texture from GPU memory (VRAM)
declare function IsRenderTextureValid(byval target as RenderTexture2D) as boolean								'' Check if a render texture is valid (loaded in GPU)
declare sub UnloadRenderTexture(byval target as RenderTexture2D)												'' Unload render texture from GPU memory (VRAM)
declare sub UpdateTexture(byval texture as Texture2D, byval pixels as const any ptr)							'' Update GPU texture with new data
declare sub UpdateTextureRec(byval texture as Texture2D, byval rec as Rectangle, byval pixels as const any ptr)	'' Update GPU texture rectangle with new data

'' Texture configuration functions
declare sub GenTextureMipmaps(byval texture as Texture2D ptr)					'' Generate GPU mipmaps for a texture
declare sub SetTextureFilter(byval texture as Texture2D, byval filter as long)	'' Set texture scaling filter mode
declare sub SetTextureWrap(byval texture as Texture2D, byval wrap as long)		'' Set texture wrapping mode

'' Texture drawing functions
declare sub DrawTexture(byval texture as Texture2D, byval posX as long, byval posY as long, byval tint as RLColor)																				'' Draw a Texture2D
declare sub DrawTextureV(byval texture as Texture2D, byval position as Vector2, byval tint as RLColor)																							'' Draw a Texture2D with position defined as Vector2
declare sub DrawTextureEx(byval texture as Texture2D, byval position as Vector2, byval rotation as single, byval scale as single, byval tint as RLColor)										'' Draw a Texture2D with extended parameters
declare sub DrawTextureRec(byval texture as Texture2D, byval source as Rectangle, byval position as Vector2, byval tint as RLColor)																'' Draw a part of a texture defined by a rectangle
declare sub DrawTexturePro(byval texture as Texture2D, byval source as Rectangle, byval dest as Rectangle, byval origin as Vector2, byval rotation as single, byval tint as RLColor)			'' Draw a part of a texture defined by a rectangle with 'pro' parameters
declare sub DrawTextureNPatch(byval texture as Texture2D, byval nPatchInfo as NPatchInfo, byval dest as Rectangle, byval origin as Vector2, byval rotation as single, byval tint as RLColor)	'' Draws a texture (or part of it) that stretches or shrinks nicely

'' Color/pixel related functions
declare function ColorIsEqual(byval col1 as RLColor, byval col2 as RLColor) as boolean 								'' Check if two colors are equal
declare function Fade(byval color as RLColor, byval alpha_ as single) as RLColor									'' Get color with alpha applied, alpha goes from 0.0f to 1.0f
declare function ColorToInt(byval color_ as RLColor) as long														'' Get hexadecimal value for a Color (&hRRGGBBAA)
declare function ColorNormalize(byval color_ as RLColor) as Vector4													'' Get Color normalized as float [0..1]
declare function ColorFromNormalized(byval normalized as Vector4) as RLColor										'' Get Color from normalized values [0..1]
declare function ColorToHSV(byval color as RLColor) as Vector3														'' Get HSV values for a Color, hue [0..360], saturation/value [0..1]
declare function ColorFromHSV(byval hue as single, byval saturation as single, byval value as single) as RLColor	'' Get a Color from HSV values, hue [0..360], saturation/value [0..1]
declare function ColorTint(byval color_ as RLColor, byval tint as RLColor) as RLColor								'' Get color multiplied with another color
declare function ColorBrightness(byval color_ as RLColor, byval factor as single) as RLColor						'' Get color with brightness correction, brightness factor goes from -1.0f to 1.0f
declare function ColorContrast(byval color_ as RLColor, byval contrast as single) as RLColor						'' Get color with contrast correction, contrast values between -1.0f and 1.0f
declare function ColorAlpha(byval color_ as RLColor, byval alpha_ as single) as RLColor								'' Get color with alpha applied, alpha goes from 0.0f to 1.0f
declare function ColorAlphaBlend(byval dst as RLColor, byval src as RLColor, byval tint as RLColor) as RLColor		'' Get src alpha-blended into dst color with tint
declare function ColorLerp(byval color1 as RLColor, byval color2 as RLColor, byval factor as single) as RLColor     '' Get color lerp interpolation between two colors, factor [0.0f..1.0f]
declare function GetColor(byval hexValue as ulong) as RLColor														'' Get Color structure from hexadecimal value
declare function GetPixelColor(byval srcPtr as any ptr, byval format_ as long) as RLColor							'' Get Color from a source pixel pointer of certain format
declare sub SetPixelColor(byval dstPtr as any ptr, byval color as RLColor, byval format_ as long)					'' Set color formatted into destination pixel pointer
declare function GetPixelDataSize(byval width as long, byval height_ as long, byval format_ as long) as long		'' Get pixel data size in bytes for certain format

''------------------------------------------------------------------------------------
'' Font Loading and Text Drawing Functions (Module: text)
''------------------------------------------------------------------------------------

'' Font loading/unloading functions
declare function GetFontDefault() as Font																																														'' Get the default Font
declare function LoadFont(byval fileName as const zstring ptr) as Font																																							'' Load font from file into GPU memory (VRAM)
declare function LoadFontEx(byval fileName as const zstring ptr, byval fontSize as long, byval codepoints as long ptr, byval codepointCount as long) as Font																	'' Load font from file with extended parameters, use NULL for codepoints and 0 for codepointCount to load the default character set, font size is provided in pixels height
declare function LoadFontFromImage(byval image as Image, byval key as RLColor, byval firstChar as long) as Font																												'' Load font from Image (XNA style)
declare function LoadFontFromMemory(byval fileType as const zstring ptr, byval fileData as const ubyte ptr, byval dataSize as long, byval fontSize as long, byval codepoints as long ptr, byval codepointCount as long) as Font	'' Load font from memory buffer, fileType refers to extension: i.e. '.ttf'
declare function IsFontValid(byval font as Font) as boolean																																										'' Check if a font is valid (font data loaded, WARNING: GPU texture not checked)
declare function LoadFontData(byval fileData as const ubyte ptr, byval dataSize as long, byval fontSize as long, byval codepoints as long ptr, byval codepointCount as long, byval type as long) as GlyphInfo ptr				'' Load font data for further use
declare function GenImageFontAtlas(byval glyphs as const GlyphInfo ptr, byval glyphRecs as Rectangle ptr ptr, byval glyphCount as long, byval fontSize as long, byval padding as long, byval packMethod as long) as Image		'' Generate image font atlas using chars info
declare sub UnloadFontData(byval glyphs as GlyphInfo ptr, byval glyphCount as long)																																				'' Unload font chars info data (RAM)
declare sub UnloadFont(byval font as Font)																																														'' Unload font from GPU memory (VRAM)
declare function ExportFontAsCode(byval font as Font, byval fileName as const zstring ptr) as boolean																															'' Export font as code file, returns true on success

'' Text drawing functions
declare sub DrawFPS(byval posX as long, byval posY as long)																																												'' Draw current FPS
declare sub DrawText(byval text as const zstring ptr, byval posX as long, byval posY as long, byval fontSize as long, byval color as RLColor)																							'' Draw text (using default font)
declare sub DrawTextEx(byval font as Font, byval text as const zstring ptr, byval position as Vector2, byval fontSize as single, byval spacing as single, byval tint as RLColor)														'' Draw text using font and additional parameters
declare sub DrawTextPro(byval font as Font, byval text as const zstring ptr, byval position as Vector2, byval origin as Vector2, byval rotation as single, byval fontSize as single, byval spacing as single, byval tint as RLColor)	'' Draw text using Font and pro parameters (rotation)
declare sub DrawTextCodepoint(byval font as Font, byval codepoint as long, byval position as Vector2, byval fontSize as single, byval tint as RLColor)																					'' Draw one character (codepoint)
declare sub DrawTextCodepoints(byval font as Font, byval codepoints as const long ptr, byval codepointCount as long, byval position as Vector2, byval fontSize as single, byval spacing as single, byval tint as RLColor)				'' Draw multiple character (codepoint)

'' Text font info functions
declare sub SetTextLineSpacing(byval spacing as long)																								'' Set vertical line spacing when drawing with line-breaks
declare function MeasureText(byval text as const zstring ptr, byval fontSize as long) as long														'' Measure string width for default font
declare function MeasureTextEx(byval font as Font, byval text as const zstring ptr, byval fontSize as single, byval spacing as single) as Vector2	'' Measure string size for Font
declare function GetGlyphIndex(byval font as Font, byval codepoint as long) as long																	'' Get glyph index position in font for a codepoint (unicode character), fallback to '?' if not found
declare function GetGlyphInfo(byval font as Font, byval codepoint as long) as GlyphInfo																'' Get glyph font info data for a codepoint (unicode character), fallback to '?' if not found
declare function GetGlyphAtlasRec(byval font as Font, byval codepoint as long) as Rectangle															'' Get glyph rectangle in font atlas for a codepoint (unicode character), fallback to '?' if not found

'' Text codepoints management functions (unicode characters)
declare function LoadUTF8(byval codepoints as const long ptr, byval length_ as long) as zstring ptr				'' Load UTF-8 text encoded from codepoints array
declare sub UnloadUTF8(byval text as zstring ptr)																'' Unload UTF-8 text encoded from codepoints array
declare function LoadCodepoints(byval text as const zstring ptr, byval count as long ptr) as long ptr			'' Load all codepoints from a UTF-8 text string, codepoints count returned by parameter
declare sub UnloadCodepoints(byval codepoints as long ptr)														'' Unload codepoints data from memory
declare function GetCodepointCount(byval text as const zstring ptr) as long										'' Get total number of codepoints in a UTF-8 encoded string
declare function GetCodepoint(byval text as const zstring ptr, byval codepointSize as long ptr) as long			'' Get next codepoint in a UTF-8 encoded string, 0x3f('?') is returned on failure
declare function GetCodepointNext(byval text as const wstring ptr, byval codepointSize as long ptr) as long		'' Get next codepoint in a UTF-8 encoded string, 0x3f('?') is returned on failure
declare function GetCodepointPrevious(byval text as const wstring ptr, byval codepointSize as long ptr) as long	'' Get previous codepoint in a UTF-8 encoded string, 0x3f('?') is returned on failure
declare function CodepointToUTF8(byval codepoint as long, byval utf8Size as long ptr) as const zstring ptr		'' Encode one codepoint into UTF-8 byte array (array length returned as parameter)

'' Text strings management functions (no UTF-8 strings, only byte chars)
'' NOTE: Some strings allocate memory internally for returned strings, just be careful!
declare function TextCopy(byval dst as zstring ptr, byval src as const zstring ptr) as long															'' Copy one string to another, returns bytes copied
declare function TextIsEqual(byval text1 as const zstring ptr, byval text2 as const zstring ptr) as boolean											'' Check if two text string are equal
declare function TextLength(byval text as const zstring ptr) as ulong																				'' Get text length, checks for '\0' ending
declare function TextFormat(byval text as const zstring ptr, ...) as const zstring ptr																'' Text formatting with variables (sprintf() style)
declare function TextSubtext(byval text as const zstring ptr, byval position as long, byval length as long) as const zstring ptr					'' Get a piece of a text string
declare function TextReplace(byval text as const zstring ptr, byval replace as const zstring ptr, byval by as const zstring ptr) as zstring ptr			'' Replace text string (WARNING: memory must be freed!)
declare function TextInsert(byval text as const zstring ptr, byval insert as const zstring ptr, byval position as long) as zstring ptr				'' Insert text in a position (WARNING: memory must be freed!)
declare function TextJoin(byval textList as const zstring ptr ptr, byval count as long, byval delimiter as const zstring ptr) as const zstring ptr	'' Join text strings with delimiter
declare function TextSplit(byval text as const zstring ptr, byval delimiter as byte, byval count as long ptr) as const zstring ptr ptr				'' Split text into multiple strings
declare sub TextAppend(byval text as zstring ptr, byval append as const zstring ptr, byval position as long ptr)									'' Append text at specific position and move cursor!
declare function TextFindIndex(byval text as const zstring ptr, byval find as const zstring ptr) as long											'' Find first text occurrence within a string
declare function TextToUpper(byval text as const zstring ptr) as const zstring ptr																	'' Get upper case version of provided string
declare function TextToLower(byval text as const zstring ptr) as const zstring ptr																	'' Get lower case version of provided string
declare function TextToPascal(byval text as const zstring ptr) as const zstring ptr																	'' Get Pascal case notation version of provided string
declare function TextToSnake(byval text as const zstring ptr) as const zstring ptr																	'' Get Snake case notation version of provided string
declare function TextToCamel(byval text as const zstring ptr) as const zstring ptr                      											'' Get Camel case notation version of provided string

declare function TextToInteger(byval text as const zstring ptr) as long																				'' Get integer value from text (negative values not supported)
declare function TextToFloat(byval text as const zstring ptr) as single 																			'' Get float value from text (negative values not supported)

''------------------------------------------------------------------------------------
'' Basic 3d Shapes Drawing Functions (Module: models)
''------------------------------------------------------------------------------------

'' Basic geometric 3D shapes drawing functions
declare sub DrawLine3D(byval startPos as Vector3, byval endPos as Vector3, byval color as RLColor)																							'' Draw a line in 3D world space
declare sub DrawPoint3D(byval position as Vector3, byval color as RLColor)																													'' Draw a point in 3D space, actually a small line
declare sub DrawCircle3D(byval center as Vector3, byval radius as single, byval rotationAxis as Vector3, byval rotationAngle as single, byval color as RLColor)								'' Draw a circle in 3D world space
declare sub DrawTriangle3D(byval v1 as Vector3, byval v2 as Vector3, byval v3 as Vector3, byval color as RLColor)																			'' Draw a color-filled triangle (vertex in counter-clockwise order!)
declare sub DrawTriangleStrip3D(byval points as const Vector3 ptr, byval pointCount as long, byval color as RLColor)																				'' Draw a triangle strip defined by points
declare sub DrawCube(byval position as Vector3, byval width as single, byval height_ as single, byval length as single, byval color as RLColor)											'' Draw cube
declare sub DrawCubeV(byval position as Vector3, byval size as Vector3, byval color as RLColor)																								'' Draw cube (Vector version)
declare sub DrawCubeWires(byval position as Vector3, byval width as single, byval height_ as single, byval length as single, byval color as RLColor)										'' Draw cube wires
declare sub DrawCubeWiresV(byval position as Vector3, byval size as Vector3, byval color as RLColor)																						'' Draw cube wires (Vector version)
declare sub DrawSphere(byval centerPos as Vector3, byval radius as single, byval color as RLColor)																							'' Draw sphere
declare sub DrawSphereEx(byval centerPos as Vector3, byval radius as single, byval rings as long, byval slices as long, byval color as RLColor)												'' Draw sphere with extended parameters
declare sub DrawSphereWires(byval centerPos as Vector3, byval radius as single, byval rings as long, byval slices as long, byval color as RLColor)											'' Draw sphere wires
declare sub DrawCylinder(byval position as Vector3, byval radiusTop as single, byval radiusBottom as single, byval height_ as single, byval slices as long, byval color as RLColor)			'' Draw a cylinder/cone
declare sub DrawCylinderEx(byval startPos as Vector3, byval endPos as Vector3, byval startRadius as single, byval endRadius as single, byval sides as long, byval color as RLColor)			'' Draw a cylinder with base at startPos and top at endPos
declare sub DrawCylinderWires(byval position as Vector3, byval radiusTop as single, byval radiusBottom as single, byval height_ as single, byval slices as long, byval color as RLColor)	'' Draw a cylinder/cone wires
declare sub DrawCylinderWiresEx(byval startPos as Vector3, byval endPos as Vector3, byval startRadius as single, byval endRadius as single, byval sides as long, byval color as RLColor)	'' Draw a cylinder wires with base at startPos and top at endPos
declare sub DrawCapsule(byval startPos as Vector3, byval endPos as Vector3, byval radius as single, byval slices as long, byval rings as long, byval color_ as RLColor)						'' Draw a capsule with the center of its sphere caps at startPos and endPos
declare sub DrawCapsuleWires(byval startPos as Vector3, byval endPos as Vector3, byval radius as single, byval slices as long, byval rings as long, byval color_ as RLColor)				'' Draw capsule wireframe with the center of its sphere caps at startPos and endPos
declare sub DrawPlane(byval centerPos as Vector3, byval size as Vector2, byval color as RLColor)																							'' Draw a plane XZ
declare sub DrawRay(byval ray as Ray, byval color as RLColor)																																'' Draw a ray line
declare sub DrawGrid(byval slices as long, byval spacing as single)																															'' Draw a grid (centered at (0, 0, 0))

''------------------------------------------------------------------------------------
'' Model 3d Loading and Drawing Functions (Module: models)
''------------------------------------------------------------------------------------

'' Model management functions
declare function LoadModel(byval fileName as const zstring ptr) as Model	'' Load model from files (meshes and materials)
declare function LoadModelFromMesh(byval mesh as Mesh) as Model				'' Load model from generated mesh (default material)
declare function IsModelValid(byval model as Model) as boolean				'' Check if a model is valid (loaded in GPU, VAO/VBOs)
declare sub UnloadModel(byval model as Model)								'' Unload model (including meshes) from memory (RAM and/or VRAM)
declare function GetModelBoundingBox(byval model as Model) as BoundingBox	'' Compute model bounding box limits (considers all meshes)

'' Model drawing functions
declare sub DrawModel(byval model as Model, byval position as Vector3, byval scale as single, byval tint as RLColor)																																			'' Draw a model (with texture if set)
declare sub DrawModelEx(byval model as Model, byval position as Vector3, byval rotationAxis as Vector3, byval rotationAngle as single, byval scale as Vector3, byval tint as RLColor)																			'' Draw a model with extended parameters
declare sub DrawModelWires(byval model as Model, byval position as Vector3, byval scale as single, byval tint as RLColor)																																		'' Draw a model wires (with texture if set)
declare sub DrawModelWiresEx(byval model as Model, byval position as Vector3, byval rotationAxis as Vector3, byval rotationAngle as single, byval scale as Vector3, byval tint as RLColor)																		'' Draw a model wires (with texture if set) with extended parameters
declare sub DrawModelPoints(byval model as Model, byval position as Vector3, byval scale as single, byval tint as RLColor) 																																		'' Draw a model as points
declare sub DrawModelPointsEx(byval model as Model, byval position as Vector3, byval rotationAxis as Vector3, byval rotationAngle as single, byval scale as Vector3, byval tint as RLColor) 																	'' Draw a model as points with extended parameters
declare sub DrawBoundingBox(byval box as BoundingBox, byval color as RLColor)																																													'' Draw bounding box (wires)
declare sub DrawBillboard(byval camera as Camera, byval texture as Texture2D, byval position as Vector3, byval size as single, byval tint as RLColor)																											'' Draw a billboard texture
declare sub DrawBillboardRec(byval camera as Camera, byval texture as Texture2D, byval source as Rectangle, byval position as Vector3, byval size as Vector2, byval tint as RLColor)																			'' Draw a billboard texture defined by source
declare sub DrawBillboardPro(byval camera as Camera, byval texture as Texture2D, byval source as Rectangle, byval position as Vector3, byval up as Vector3, byval size as Vector2, byval origin as Vector2, byval rotation as single, byval tint as RLColor)	'' Draw a billboard texture defined by source and rotation

'' Mesh management functions
declare sub UploadMesh(byval mesh as Mesh ptr, byval dynamic as boolean)																				'' Upload mesh vertex data in GPU and provide VAO/VBO ids
declare sub UpdateMeshBuffer(byval mesh as Mesh, byval index as long, byval data_ as const any ptr, byval dataSize as long, byval offset as long)	'' Update mesh vertex data in GPU for a specific buffer index
declare sub UnloadMesh(byval mesh as Mesh)																											'' Unload mesh data from CPU and GPU
declare sub DrawMesh(byval mesh as Mesh, byval material as Material, byval transform as Matrix)														'' Draw a 3d mesh with material and transform
declare sub DrawMeshInstanced(byval mesh as Mesh, byval material as Material, byval transforms as const Matrix ptr, byval instances as long)		'' Draw multiple mesh instances with material and different transforms
declare function GetMeshBoundingBox(byval mesh as Mesh) as BoundingBox																				'' Compute mesh bounding box limits
declare sub GenMeshTangents(byval mesh as Mesh ptr)																									'' Compute mesh tangents
declare function ExportMesh(byval mesh as Mesh, byval fileName as const zstring ptr) as boolean														'' Export mesh data to file, returns true on success
declare function ExportMeshAsCode(byval mesh as Mesh, byval fileName as const zstring ptr) as boolean												'' Export mesh as code file (.h) defining multiple arrays of vertex attributes

'' Mesh generation functions
declare function GenMeshPoly(byval sides as long, byval radius as single) as Mesh												'' Generate polygonal mesh
declare function GenMeshPlane(byval width as single, byval length as single, byval resX as long, byval resZ as long) as Mesh	'' Generate plane mesh (with subdivisions)
declare function GenMeshCube(byval width as single, byval height_ as single, byval length as single) as Mesh					'' Generate cuboid mesh
declare function GenMeshSphere(byval radius as single, byval rings as long, byval slices as long) as Mesh						'' Generate sphere mesh (standard sphere)
declare function GenMeshHemiSphere(byval radius as single, byval rings as long, byval slices as long) as Mesh					'' Generate half-sphere mesh (no bottom cap)
declare function GenMeshCylinder(byval radius as single, byval height_ as single, byval slices as long) as Mesh					'' Generate cylinder mesh
declare function GenMeshCone(byval radius as single, byval height_ as single, byval slices as long) as Mesh						'' Generate cone/pyramid mesh
declare function GenMeshTorus(byval radius as single, byval size as single, byval radSeg as long, byval sides as long) as Mesh	'' Generate torus mesh
declare function GenMeshKnot(byval radius as single, byval size as single, byval radSeg as long, byval sides as long) as Mesh	'' Generate trefoil knot mesh
declare function GenMeshHeightmap(byval heightmap as Image, byval size as Vector3) as Mesh										'' Generate heightmap mesh from image data
declare function GenMeshCubicmap(byval cubicmap as Image, byval cubeSize as Vector3) as Mesh									'' Generate cubes-based map mesh from image data

'' Material loading/unloading functions
declare function LoadMaterials(byval fileName as const zstring ptr, byval materialCount as long ptr) as Material ptr	'' Load materials from model file
declare function LoadMaterialDefault() as Material																		'' Load default material (Supports: DIFFUSE, SPECULAR, NORMAL maps)
declare function IsMaterialValid(byval material as Material) as boolean													'' Check if a material is valid (shader assigned, map textures loaded in GPU)
declare sub UnloadMaterial(byval material as Material)																	'' Unload material from GPU memory (VRAM)
declare sub SetMaterialTexture(byval material as Material ptr, byval mapType as long, byval texture as Texture2D)		'' Set texture for a material map type (MATERIAL_MAP_DIFFUSE, MATERIAL_MAP_SPECULAR...)
declare sub SetModelMeshMaterial(byval model as Model ptr, byval meshId as long, byval materialId as long)				'' Set material for a mesh

'' Model animations loading/unloading functions
declare function LoadModelAnimations(byval fileName as const zstring ptr, byval animCount as long ptr) as ModelAnimation ptr	'' Load model animations from file
declare sub UpdateModelAnimation(byval model as Model, byval anim as ModelAnimation, byval frame as long)						'' Update model animation pose (CPU)
declare sub UpdateModelAnimationBones(byval model as Model, byval anim as ModelAnimation, byval frame as long)					'' Update model animation mesh bone matrices (GPU skinning)
declare sub UnloadModelAnimation(byval anim as ModelAnimation)																	'' Unload animation data
declare sub UnloadModelAnimations(byval animations as ModelAnimation ptr, byval animCount as long)									'' Unload animation array data
declare function IsModelAnimationValid(byval model as Model, byval anim as ModelAnimation) as boolean							'' Check model animation skeleton match

'' Collision detection functions
declare function CheckCollisionSpheres(byval center1 as Vector3, byval radius1 as single, byval center2 as Vector3, byval radius2 as single) as boolean		'' Check collision between two spheres
declare function CheckCollisionBoxes(byval box1 as BoundingBox, byval box2 as BoundingBox) as boolean														'' Check collision between two bounding boxes
declare function CheckCollisionBoxSphere(byval box as BoundingBox, byval center as Vector3, byval radius as single) as boolean								'' Check collision between box and sphere
declare function GetRayCollisionSphere(byval ray as Ray, byval center as Vector3, byval radius as single) as RayCollision									'' Get collision info between ray and sphere
declare function GetRayCollisionBox(byval ray as Ray, byval box as BoundingBox) as RayCollision																'' Get collision info between ray and box
declare function GetRayCollisionMesh(byval ray as Ray, byval mesh as Mesh, byval transform as Matrix) as RayCollision										'' Get collision info between ray and mesh
declare function GetRayCollisionTriangle(byval ray as Ray, byval p1 as Vector3, byval p2 as Vector3, byval p3 as Vector3) as RayCollision					'' Get collision info between ray and triangle
declare function GetRayCollisionQuad(byval ray as Ray, byval p1 as Vector3, byval p2 as Vector3, byval p3 as Vector3, byval p4 as Vector3) as RayCollision	'' Get collision info between ray and quad

''------------------------------------------------------------------------------------
'' Audio Loading and Playing Functions (Module: audio)
''------------------------------------------------------------------------------------
type AudioCallback as sub(byval bufferData as any ptr, byval frames as ulong)

'' Audio device management functions
declare sub InitAudioDevice()						'' Initialize audio device and context
declare sub CloseAudioDevice()						'' Close the audio device and context
declare function IsAudioDeviceReady() as boolean		'' Check if audio device has been initialized successfully
declare sub SetMasterVolume(byval volume as single)	'' Set master volume (listener)
declare function GetMasterVolume() as single		'' Get master volume (listener)

'' Wave/Sound loading/unloading functions
declare function LoadWave(byval fileName as const zstring ptr) as Wave																		'' Load wave data from file
declare function LoadWaveFromMemory(byval fileType as const zstring ptr, byval fileData as const ubyte ptr, byval dataSize as long) as Wave	'' Load wave from memory buffer, fileType refers to extension: i.e. '.wav'
declare function IsWaveValid(byval wave as Wave) as boolean																					'' Checks if wave data is valid (data loaded and parameters)
declare function LoadSound(byval fileName as const zstring ptr) as Sound																	'' Load sound from file
declare function LoadSoundFromWave(byval wave as Wave) as Sound																				'' Load sound from wave data
declare function LoadSoundAlias(byval source as Sound) as Sound																				'' Create a new sound that shares the same sample data as the source sound, does not own the sound data
declare function IsSoundValid(byval sound as Sound) as boolean																					'' Checks if a sound is valid (data loaded and buffers initialized)
declare sub UpdateSound(byval sound as Sound, byval data as const any ptr, byval sampleCount as long)										'' Update sound buffer with new data
declare sub UnloadWave(byval wave as Wave)																									'' Unload wave data
declare sub UnloadSound(byval sound as Sound)																								'' Unload sound
declare sub UnloadSoundAlias(byval alias as Sound)																							'' Unload a sound alias (does not deallocate sample data)
declare function ExportWave(byval wave as Wave, byval fileName as const zstring ptr) as boolean												'' Export wave data to file, returns true on success
declare function ExportWaveAsCode(byval wave as Wave, byval fileName as const zstring ptr) as boolean										'' Export wave sample data to code (.h), returns true on success

'' Wave/Sound management functions
declare sub PlaySound(byval sound as Sound)																					'' Play a sound
declare sub StopSound(byval sound as Sound)																					'' Stop playing a sound
declare sub PauseSound(byval sound as Sound)																				'' Pause a sound
declare sub ResumeSound(byval sound as Sound)																				'' Resume a paused sound
declare function IsSoundPlaying(byval sound as Sound) as boolean																'' Check if a sound is currently playing
declare sub SetSoundVolume(byval sound as Sound, byval volume as single)													'' Set volume for a sound (1.0 is max level)
declare sub SetSoundPitch(byval sound as Sound, byval pitch as single)														'' Set pitch for a sound (1.0 is base level)
declare sub SetSoundPan(byval sound as Sound, byval pan as single)															'' Set pan for a sound (0.5 is center)
declare function WaveCopy(byval wave as Wave) as Wave																		'' Copy a wave to a new wave
declare sub WaveCrop(byval wave as Wave ptr, byval initFrame as long, byval finalFrame as long)							'' Crop a wave to defined frames range
declare sub WaveFormat(byval wave as Wave ptr, byval sampleRate as long, byval sampleSize as long, byval channels as long)	'' Convert wave data to desired format
declare function LoadWaveSamples(byval wave as Wave) as single ptr															'' Load samples data from wave as a 32bit float data array
declare sub UnloadWaveSamples(byval samples as single ptr)																	'' Unload samples data loaded with LoadWaveSamples()

'' Music management functions
declare function LoadMusicStream(byval fileName as const zstring ptr) as Music																		'' Load music stream from file
declare function LoadMusicStreamFromMemory(byval fileType as const zstring ptr, byval data as const ubyte ptr, byval dataSize as long) as Music	'' Load music stream from data
declare function IsMusicValid(byval music as Music) as boolean																						'' Checks if a music stream is valid (context and buffers initialized)
declare sub UnloadMusicStream(byval music as Music)																									'' Unload music stream
declare sub PlayMusicStream(byval music as Music)																									'' Start music playing
declare function IsMusicStreamPlaying(byval music as Music) as boolean																				'' Check if music is playing
declare sub UpdateMusicStream(byval music as Music)																									'' Updates buffers for music streaming
declare sub StopMusicStream(byval music as Music)																									'' Stop music playing
declare sub PauseMusicStream(byval music as Music)																									'' Pause music playing
declare sub ResumeMusicStream(byval music as Music)																									'' Resume playing paused music
declare sub SeekMusicStream(byval music as Music, byval position as single)																			'' Seek music to a position (in seconds)
declare sub SetMusicVolume(byval music as Music, byval volume as single)																			'' Set volume for music (1.0 is max level)
declare sub SetMusicPitch(byval music as Music, byval pitch as single)																				'' Set pitch for a music (1.0 is base level)
declare sub SetMusicPan(byval music as Music, byval pan as single)																					'' Set pan for a music (0.5 is center)
declare function GetMusicTimeLength(byval music as Music) as single																					'' Get music time length (in seconds)
declare function GetMusicTimePlayed(byval music as Music) as single																					'' Get current music time played (in seconds)

'' AudioStream management functions
declare function LoadAudioStream(byval sampleRate as ulong, byval sampleSize as ulong, byval channels as ulong) as AudioStream	'' Load audio stream (to stream raw audio pcm data)
declare function IsAudioStreamValid(byval stream as AudioStream) as Boolean														'' Checks if an audio stream is valid (buffers initialized)
declare sub UnloadAudioStream(byval stream as AudioStream)																		'' Unload audio stream and free memory
declare sub UpdateAudioStream(byval stream as AudioStream, byval data as const any ptr, byval frameCount as long)				'' Update audio stream buffers with data
declare function IsAudioStreamProcessed(byval stream as AudioStream) as boolean													'' Check if any audio stream buffers requires refill
declare sub PlayAudioStream(byval stream as AudioStream)																		'' Play audio stream
declare sub PauseAudioStream(byval stream as AudioStream)																		'' Pause audio stream
declare sub ResumeAudioStream(byval stream as AudioStream)																		'' Resume audio stream
declare function IsAudioStreamPlaying(byval stream as AudioStream) as boolean													'' Check if audio stream is playing
declare sub StopAudioStream(byval stream as AudioStream)																		'' Stop audio stream
declare sub SetAudioStreamVolume(byval stream as AudioStream, byval volume as single)											'' Set volume for audio stream (1.0 is max level)
declare sub SetAudioStreamPitch(byval stream as AudioStream, byval pitch as single)												'' Set pitch for audio stream (1.0 is base level)
declare sub SetAudioStreamPan(byval stream as AudioStream, byval pan as single)													'' Set pan for audio stream (0.5 is centered)
declare sub SetAudioStreamBufferSizeDefault(byval size as long)																	'' Default size for new audio streams
declare sub SetAudioStreamCallback(byval stream as AudioStream, byval callback as AudioCallback)								'' Audio thread callback to request new data

declare sub AttachAudioStreamProcessor(byval stream as AudioStream, byval processor as AudioCallback)	'' Attach audio stream processor to stream, receives the samples as 'float'
declare sub DetachAudioStreamProcessor(byval stream as AudioStream, byval processor as AudioCallback)	'' Detach audio stream processor from stream

declare sub AttachAudioMixedProcessor(byval processor as AudioCallback)	'' Attach audio stream processor to the entire audio pipeline, receives the samples as 'float'
declare sub DetachAudioMixedProcessor(byval processor as AudioCallback)	'' Detach audio stream processor from the entire audio pipeline

end extern
