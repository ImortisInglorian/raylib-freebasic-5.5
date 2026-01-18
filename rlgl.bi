/'*********************************************************************************************
*
*   rlgl v5.0 - A multi-OpenGL abstraction layer with an immediate-mode style API
*
*   DESCRIPTION:
*       An abstraction layer for multiple OpenGL versions (1.1, 2.1, 3.3 Core, 4.3 Core, ES 2.0)
*       that provides a pseudo-OpenGL 1.1 immediate-mode style API (rlVertex, rlTranslate, rlRotate...)
*
*   ADDITIONAL NOTES:
*       When choosing an OpenGL backend different than OpenGL 1.1, some internal buffer are
*       initialized on rlglInit() to accumulate vertex data
*
*       When an internal state change is required all the stored vertex data is renderer in batch,
*       additionally, rlDrawRenderBatchActive() could be called to force flushing of the batch
*
*       Some resources are also loaded for convenience, here the complete list:
*          - Default batch (RLGL.defaultBatch): RenderBatch system to accumulate vertex data
*          - Default texture (RLGL.defaultTextureId): 1x1 white pixel R8G8B8A8
*          - Default shader (RLGL.State.defaultShaderId, RLGL.State.defaultShaderLocs)
*
*       Internal buffer (and resources) must be manually unloaded calling rlglClose()
*
*   CONFIGURATION:
*       #define GRAPHICS_API_OPENGL_11
*       #define GRAPHICS_API_OPENGL_21
*       #define GRAPHICS_API_OPENGL_33
*       #define GRAPHICS_API_OPENGL_43
*       #define GRAPHICS_API_OPENGL_ES2
*       #define GRAPHICS_API_OPENGL_ES3
*           Use selected OpenGL graphics backend, should be supported by platform
*           Those preprocessor defines are only used on rlgl module, if OpenGL version is
*           required by any other module, use rlGetVersion() to check it
*
*       #define RLGL_IMPLEMENTATION
*           Generates the implementation of the library into the included file
*           If not defined, the library is in header only mode and can be included in other headers
*           or source files without problems. But only ONE file should hold the implementation
*
*       #define RLGL_RENDER_TEXTURES_HINT
*           Enable framebuffer objects (fbo) support (enabled by default)
*           Some GPUs could not support them despite the OpenGL version
*
*       #define RLGL_SHOW_GL_DETAILS_INFO
*           Show OpenGL extensions and capabilities detailed logs on init
*
*       #define RLGL_ENABLE_OPENGL_DEBUG_CONTEXT
*           Enable debug context (only available on OpenGL 4.3)
*
*       rlgl capabilities could be customized just defining some internal
*       values before library inclusion (default values listed):
*
*       #define RL_DEFAULT_BATCH_BUFFER_ELEMENTS   8192    '' Default internal render batch elements limits
*       #define RL_DEFAULT_BATCH_BUFFERS              1    '' Default number of batch buffers (multi-buffering)
*       #define RL_DEFAULT_BATCH_DRAWCALLS          256    '' Default number of batch draw calls (by state changes: mode, texture)
*       #define RL_DEFAULT_BATCH_MAX_TEXTURE_UNITS    4    '' Maximum number of textures units that can be activated on batch drawing (SetShaderValueTexture())
*
*       #define RL_MAX_MATRIX_STACK_SIZE             32    '' Maximum size of internal Matrix stack
*       #define RL_MAX_SHADER_LOCATIONS              32    '' Maximum number of shader locations supported
*       #define RL_CULL_DISTANCE_NEAR              0.01    '' Default projection matrix near cull distance
*       #define RL_CULL_DISTANCE_FAR             1000.0    '' Default projection matrix far cull distance
*
*       When loading a shader, the following vertex attributes and uniform
*       location names are tried to be set automatically:
*
*       #define RL_DEFAULT_SHADER_ATTRIB_NAME_POSITION     "vertexPosition"    '' Bound by default to shader location: RL_DEFAULT_SHADER_ATTRIB_LOCATION_POSITION
*       #define RL_DEFAULT_SHADER_ATTRIB_NAME_TEXCOORD     "vertexTexCoord"    '' Bound by default to shader location: RL_DEFAULT_SHADER_ATTRIB_LOCATION_TEXCOORD
*       #define RL_DEFAULT_SHADER_ATTRIB_NAME_NORMAL       "vertexNormal"      '' Bound by default to shader location: RL_DEFAULT_SHADER_ATTRIB_LOCATION_NORMAL
*       #define RL_DEFAULT_SHADER_ATTRIB_NAME_COLOR        "vertexColor"       '' Bound by default to shader location: RL_DEFAULT_SHADER_ATTRIB_LOCATION_COLOR
*       #define RL_DEFAULT_SHADER_ATTRIB_NAME_TANGENT      "vertexTangent"     '' Bound by default to shader location: RL_DEFAULT_SHADER_ATTRIB_LOCATION_TANGENT
*       #define RL_DEFAULT_SHADER_ATTRIB_NAME_TEXCOORD2    "vertexTexCoord2"   '' Bound by default to shader location: RL_DEFAULT_SHADER_ATTRIB_LOCATION_TEXCOORD2
*       #define RL_DEFAULT_SHADER_ATTRIB_NAME_BONEIDS      "vertexBoneIds"     '' Bound by default to shader location: RL_DEFAULT_SHADER_ATTRIB_LOCATION_BONEIDS
*       #define RL_DEFAULT_SHADER_ATTRIB_NAME_BONEWEIGHTS  "vertexBoneWeights" '' Bound by default to shader location: RL_DEFAULT_SHADER_ATTRIB_LOCATION_BONEWEIGHTS
*       #define RL_DEFAULT_SHADER_UNIFORM_NAME_MVP         "mvp"               '' model-view-projection matrix
*       #define RL_DEFAULT_SHADER_UNIFORM_NAME_VIEW        "matView"           '' view matrix
*       #define RL_DEFAULT_SHADER_UNIFORM_NAME_PROJECTION  "matProjection"     '' projection matrix
*       #define RL_DEFAULT_SHADER_UNIFORM_NAME_MODEL       "matModel"          '' model matrix
*       #define RL_DEFAULT_SHADER_UNIFORM_NAME_NORMAL      "matNormal"         '' normal matrix (transpose(inverse(matModelView)))
*       #define RL_DEFAULT_SHADER_UNIFORM_NAME_COLOR       "colDiffuse"        '' color diffuse (base tint color, multiplied by texture color)
*       #define RL_DEFAULT_SHADER_UNIFORM_NAME_BONE_MATRICES  "boneMatrices"   '' bone matrices
*       #define RL_DEFAULT_SHADER_SAMPLER2D_NAME_TEXTURE0  "texture0"          '' texture0 (texture slot active 0)
*       #define RL_DEFAULT_SHADER_SAMPLER2D_NAME_TEXTURE1  "texture1"          '' texture1 (texture slot active 1)
*       #define RL_DEFAULT_SHADER_SAMPLER2D_NAME_TEXTURE2  "texture2"          '' texture2 (texture slot active 2)
*
*   DEPENDENCIES:
*      - OpenGL libraries (depending on platform and OpenGL version selected)
*      - GLAD OpenGL extensions loading library (only for OpenGL 3.3 Core, 4.3 Core)
*
*
*   LICENSE: zlib/libpng
*
*   Copyright (c) 2014-2024 Ramon Santamaria (@raysan5)
*
*   This software is provided "as-is", without any express or implied warranty. In no event
*   will the authors be held liable for any damages arising from the use of this software.
*
*   Permission is granted to anyone to use this software for any purpose, including commercial
*   applications, and to alter it and redistribute it freely, subject to the following restrictions:
*
*     1. The origin of this software must not be misrepresented you must not claim that you
*     wrote the original software. If you use this software in a product, an acknowledgment
*     in the product documentation would be appreciated but is not required.
*
*     2. Altered source versions must be plainly marked as such, and must not be misrepresented
*     as being the original software.
*
*     3. This notice may not be removed or altered from any source distribution.
*
*********************************************************************************************'/

#ifndef RLGL_H
#define RLGL_H

#define RLGL_VERSION  "5.0"

'' Security check in case no GRAPHICS_API_OPENGL_* defined
#if not defined(GRAPHICS_API_OPENGL_11) and _
    not defined(GRAPHICS_API_OPENGL_21) and _
    not defined(GRAPHICS_API_OPENGL_33) and _
    not defined(GRAPHICS_API_OPENGL_43) and _
    not defined(GRAPHICS_API_OPENGL_ES2) and _
    not defined(GRAPHICS_API_OPENGL_ES3)
        #define GRAPHICS_API_OPENGL_33
#endif

'' Security check in case multiple GRAPHICS_API_OPENGL_* defined
#if defined(GRAPHICS_API_OPENGL_11)
    #if defined(GRAPHICS_API_OPENGL_21)
        #undef GRAPHICS_API_OPENGL_21
    #endif
    #if defined(GRAPHICS_API_OPENGL_33)
        #undef GRAPHICS_API_OPENGL_33
    #endif
    #if defined(GRAPHICS_API_OPENGL_43)
        #undef GRAPHICS_API_OPENGL_43
    #endif
    #if defined(GRAPHICS_API_OPENGL_ES2)
        #undef GRAPHICS_API_OPENGL_ES2
    #endif
#endif

'' OpenGL 2.1 uses most of OpenGL 3.3 Core functionality
'' WARNING: Specific parts are checked with #if defines
#if defined(GRAPHICS_API_OPENGL_21)
    #define GRAPHICS_API_OPENGL_33
#endif

'' OpenGL 4.3 uses OpenGL 3.3 Core functionality
#if defined(GRAPHICS_API_OPENGL_43)
    #define GRAPHICS_API_OPENGL_33
#endif

'' OpenGL ES 3.0 uses OpenGL ES 2.0 functionality (and more)
#if defined(GRAPHICS_API_OPENGL_ES3)
    #define GRAPHICS_API_OPENGL_ES2
#endif

'' Support framebuffer objects by default
'' NOTE: Some driver implementation do not support it, despite they should
#define RLGL_RENDER_TEXTURES_HINT

'''----------------------------------------------------------------------------------
'' Defines and Macros
''----------------------------------------------------------------------------------

'' Default internal render batch elements limits
#ifndef RL_DEFAULT_BATCH_BUFFER_ELEMENTS
    #if defined(GRAPHICS_API_OPENGL_11) or defined(GRAPHICS_API_OPENGL_33)
        '' This is the maximum amount of elements (quads) per batch
        '' NOTE: Be careful with text, every letter maps to a quad
        #define RL_DEFAULT_BATCH_BUFFER_ELEMENTS  8192
    #endif
    #if defined(GRAPHICS_API_OPENGL_ES2)
        '' We reduce memory sizes for embedded systems (RPI and HTML5)
        '' NOTE: On HTML5 (emscripten) this is allocated on heap,
        '' by default it's only 16MB!...just take care...
        #define RL_DEFAULT_BATCH_BUFFER_ELEMENTS  2048
    #endif
#endif
#ifndef RL_DEFAULT_BATCH_BUFFERS
    #define RL_DEFAULT_BATCH_BUFFERS                 1      '' Default number of batch buffers (multi-buffering)
#endif
#ifndef RL_DEFAULT_BATCH_DRAWCALLS
    #define RL_DEFAULT_BATCH_DRAWCALLS             256      '' Default number of batch draw calls (by state changes: mode, texture)
#endif
#ifndef RL_DEFAULT_BATCH_MAX_TEXTURE_UNITS
    #define RL_DEFAULT_BATCH_MAX_TEXTURE_UNITS       4      '' Maximum number of textures units that can be activated on batch drawing (SetShaderValueTexture())
#endif

'' Internal Matrix stack
#ifndef RL_MAX_MATRIX_STACK_SIZE
    #define RL_MAX_MATRIX_STACK_SIZE                32      '' Maximum size of Matrix stack
#endif

'' Shader limits
#ifndef RL_MAX_SHADER_LOCATIONS
    #define RL_MAX_SHADER_LOCATIONS                 32      '' Maximum number of shader locations supported
#endif

'' Projection matrix culling
#ifndef RL_CULL_DISTANCE_NEAR
    #define RL_CULL_DISTANCE_NEAR                 0.01      '' Default near cull distance
#endif
#ifndef RL_CULL_DISTANCE_FAR
    #define RL_CULL_DISTANCE_FAR                1000.0      '' Default far cull distance
#endif

'' Texture parameters (equivalent to OpenGL defines)
#define RL_TEXTURE_WRAP_S                       &h2802      '' GL_TEXTURE_WRAP_S
#define RL_TEXTURE_WRAP_T                       &h2803      '' GL_TEXTURE_WRAP_T
#define RL_TEXTURE_MAG_FILTER                   &h2800      '' GL_TEXTURE_MAG_FILTER
#define RL_TEXTURE_MIN_FILTER                   &h2801      '' GL_TEXTURE_MIN_FILTER

#define RL_TEXTURE_FILTER_NEAREST               &h2600      '' GL_NEAREST
#define RL_TEXTURE_FILTER_LINEAR                &h2601      '' GL_LINEAR
#define RL_TEXTURE_FILTER_MIP_NEAREST           &h2700      '' GL_NEAREST_MIPMAP_NEAREST
#define RL_TEXTURE_FILTER_NEAREST_MIP_LINEAR    &h2702      '' GL_NEAREST_MIPMAP_LINEAR
#define RL_TEXTURE_FILTER_LINEAR_MIP_NEAREST    &h2701      '' GL_LINEAR_MIPMAP_NEAREST
#define RL_TEXTURE_FILTER_MIP_LINEAR            &h2703      '' GL_LINEAR_MIPMAP_LINEAR
#define RL_TEXTURE_FILTER_ANISOTROPIC           &h3000      '' Anisotropic filter (custom identifier)
#define RL_TEXTURE_MIPMAP_BIAS_RATIO            &h4000      '' Texture mipmap bias, percentage ratio (custom identifier)

#define RL_TEXTURE_WRAP_REPEAT                  &h2901      '' GL_REPEAT
#define RL_TEXTURE_WRAP_CLAMP                   &h812F      '' GL_CLAMP_TO_EDGE
#define RL_TEXTURE_WRAP_MIRROR_REPEAT           &h8370      '' GL_MIRRORED_REPEAT
#define RL_TEXTURE_WRAP_MIRROR_CLAMP            &h8742      '' GL_MIRROR_CLAMP_EXT

'' Matrix modes (equivalent to OpenGL)
#define RL_MODELVIEW                            &h1700      '' GL_MODELVIEW
#define RL_PROJECTION                           &h1701      '' GL_PROJECTION
#define RL_TEXTURE                              &h1702      '' GL_TEXTURE

'' Primitive assembly draw modes
#define RL_LINES                                &h0001      '' GL_LINES
#define RL_TRIANGLES                            &h0004      '' GL_TRIANGLES
#define RL_QUADS                                &h0007      '' GL_QUADS

'' GL equivalent data types
#define RL_UNSIGNED_BYTE                        &h1401      '' GL_UNSIGNED_BYTE
#define RL_FLOAT                                &h1406      '' GL_FLOAT

'' GL buffer usage hint
#define RL_STREAM_DRAW                          &h88E0      '' GL_STREAM_DRAW
#define RL_STREAM_READ                          &h88E1      '' GL_STREAM_READ
#define RL_STREAM_COPY                          &h88E2      '' GL_STREAM_COPY
#define RL_STATIC_DRAW                          &h88E4      '' GL_STATIC_DRAW
#define RL_STATIC_READ                          &h88E5      '' GL_STATIC_READ
#define RL_STATIC_COPY                          &h88E6      '' GL_STATIC_COPY
#define RL_DYNAMIC_DRAW                         &h88E8      '' GL_DYNAMIC_DRAW
#define RL_DYNAMIC_READ                         &h88E9      '' GL_DYNAMIC_READ
#define RL_DYNAMIC_COPY                         &h88EA      '' GL_DYNAMIC_COPY

'' GL Shader type
#define RL_FRAGMENT_SHADER                      &h8B30      '' GL_FRAGMENT_SHADER
#define RL_VERTEX_SHADER                        &h8B31      '' GL_VERTEX_SHADER
#define RL_COMPUTE_SHADER                       &h91B9      '' GL_COMPUTE_SHADER

'' GL blending factors
#define RL_ZERO                                 0           '' GL_ZERO
#define RL_ONE                                  1           '' GL_ONE
#define RL_SRC_COLOR                            &h0300      '' GL_SRC_COLOR
#define RL_ONE_MINUS_SRC_COLOR                  &h0301      '' GL_ONE_MINUS_SRC_COLOR
#define RL_SRC_ALPHA                            &h0302      '' GL_SRC_ALPHA
#define RL_ONE_MINUS_SRC_ALPHA                  &h0303      '' GL_ONE_MINUS_SRC_ALPHA
#define RL_DST_ALPHA                            &h0304      '' GL_DST_ALPHA
#define RL_ONE_MINUS_DST_ALPHA                  &h0305      '' GL_ONE_MINUS_DST_ALPHA
#define RL_DST_COLOR                            &h0306      '' GL_DST_COLOR
#define RL_ONE_MINUS_DST_COLOR                  &h0307      '' GL_ONE_MINUS_DST_COLOR
#define RL_SRC_ALPHA_SATURATE                   &h0308      '' GL_SRC_ALPHA_SATURATE
#define RL_CONSTANT_COLOR                       &h8001      '' GL_CONSTANT_COLOR
#define RL_ONE_MINUS_CONSTANT_COLOR             &h8002      '' GL_ONE_MINUS_CONSTANT_COLOR
#define RL_CONSTANT_ALPHA                       &h8003      '' GL_CONSTANT_ALPHA
#define RL_ONE_MINUS_CONSTANT_ALPHA             &h8004      '' GL_ONE_MINUS_CONSTANT_ALPHA

'' GL blending functions/equations
#define RL_FUNC_ADD                             &h8006      '' GL_FUNC_ADD
#define RL_MIN                                  &h8007      '' GL_MIN
#define RL_MAX                                  &h8008      '' GL_MAX
#define RL_FUNC_SUBTRACT                        &h800A      '' GL_FUNC_SUBTRACT
#define RL_FUNC_REVERSE_SUBTRACT                &h800B      '' GL_FUNC_REVERSE_SUBTRACT
#define RL_BLEND_EQUATION                       &h8009      '' GL_BLEND_EQUATION
#define RL_BLEND_EQUATION_RGB                   &h8009      '' GL_BLEND_EQUATION_RGB   '' (Same as BLEND_EQUATION)
#define RL_BLEND_EQUATION_ALPHA                 &h883D      '' GL_BLEND_EQUATION_ALPHA
#define RL_BLEND_DST_RGB                        &h80C8      '' GL_BLEND_DST_RGB
#define RL_BLEND_SRC_RGB                        &h80C9      '' GL_BLEND_SRC_RGB
#define RL_BLEND_DST_ALPHA                      &h80CA      '' GL_BLEND_DST_ALPHA
#define RL_BLEND_SRC_ALPHA                      &h80CB      '' GL_BLEND_SRC_ALPHA
#define RL_BLEND_COLOR                          &h8005      '' GL_BLEND_COLOR

#define RL_READ_FRAMEBUFFER                     &h8CA8      '' GL_READ_FRAMEBUFFER
#define RL_DRAW_FRAMEBUFFER                     &h8CA9      '' GL_DRAW_FRAMEBUFFER

'' Default shader vertex attribute locations
#ifndef RL_DEFAULT_SHADER_ATTRIB_LOCATION_POSITION
    #define RL_DEFAULT_SHADER_ATTRIB_LOCATION_POSITION    0
#endif
#ifndef RL_DEFAULT_SHADER_ATTRIB_LOCATION_TEXCOORD
    #define RL_DEFAULT_SHADER_ATTRIB_LOCATION_TEXCOORD    1
#endif
#ifndef RL_DEFAULT_SHADER_ATTRIB_LOCATION_NORMAL
    #define RL_DEFAULT_SHADER_ATTRIB_LOCATION_NORMAL      2
#endif
#ifndef RL_DEFAULT_SHADER_ATTRIB_LOCATION_COLOR
    #define RL_DEFAULT_SHADER_ATTRIB_LOCATION_COLOR       3
#endif
    #ifndef RL_DEFAULT_SHADER_ATTRIB_LOCATION_TANGENT
#define RL_DEFAULT_SHADER_ATTRIB_LOCATION_TANGENT         4
#endif
#ifndef RL_DEFAULT_SHADER_ATTRIB_LOCATION_TEXCOORD2
    #define RL_DEFAULT_SHADER_ATTRIB_LOCATION_TEXCOORD2   5
#endif
#ifndef RL_DEFAULT_SHADER_ATTRIB_LOCATION_INDICES
    #define RL_DEFAULT_SHADER_ATTRIB_LOCATION_INDICES     6
#endif
#ifdef RL_SUPPORT_MESH_GPU_SKINNING
#ifndef RL_DEFAULT_SHADER_ATTRIB_LOCATION_BONEIDS
    #define RL_DEFAULT_SHADER_ATTRIB_LOCATION_BONEIDS     7
#endif
#ifndef RL_DEFAULT_SHADER_ATTRIB_LOCATION_BONEWEIGHTS
    #define RL_DEFAULT_SHADER_ATTRIB_LOCATION_BONEWEIGHTS 8
#endif
#endif

''----------------------------------------------------------------------------------
'' Types and Structures Definition
''----------------------------------------------------------------------------------
'' Dynamic vertex buffers (position + texcoords + colors + indices arrays)
type rlVertexBuffer
    as long elementCount           '' Number of elements in the buffer (QUADS)

    as single ptr vertices         '' Vertex position (XYZ - 3 components per vertex) (shader-location = 0)
    as single ptr texcoords        '' Vertex texture coordinates (UV - 2 components per vertex) (shader-location = 1)
    as single ptr normals          '' Vertex normal (XYZ - 3 components per vertex) (shader-location = 2)
    as ubyte ptr colors            '' Vertex colors (RGBA - 4 components per vertex) (shader-location = 3)
#if defined(GRAPHICS_API_OPENGL_11) or defined(GRAPHICS_API_OPENGL_33)
    as ulong ptr indices          '' Vertex indices (in case vertex data comes indexed) (6 indices per quad)
#endif
#if defined(GRAPHICS_API_OPENGL_ES2)
    as ubyte ptr indices           '' Vertex indices (in case vertex data comes indexed) (6 indices per quad)
#endif
    as ulong vaoId                 '' OpenGL Vertex Array Object id
    as ulong vboId(0 to 3)         '' OpenGL Vertex Buffer Objects id (5 types of vertex data)
end type

'' Draw call type
'' NOTE: Only texture changes register a new draw, other state-change-related elements are not
'' used at this moment (vaoId, shaderId, matrices), raylib just forces a batch draw call if any
'' of those state-change happens (this is done in core module)
type rlDrawCall
    as long mode                   '' Drawing mode: LINES, TRIANGLES, QUADS
    as long vertexCount            '' Number of vertex of the draw
    as long vertexAlignment        '' Number of vertex required for index alignment (LINES, TRIANGLES)
    as ulong textureId             '' Texture id to be used on the draw -> Use to create new draw call if changes
end type

'' rlRenderBatch type
type rlRenderBatch
    as long bufferCount                '' Number of vertex buffers (multi-buffering support)
    as long currentBuffer              '' Current buffer tracking in case of multi-buffering
    as rlVertexBuffer ptr vertexBuffer   '' Dynamic buffer(s) for vertex data

    as rlDrawCall ptr draws          '' Draw calls array, depends on textureId
    as long drawCounter            '' Draw calls counter
    as single currentDepth         '' Current depth value for next draw
end type

'' OpenGL version
type rlGlVersion as long
enum
    RL_OPENGL_11 = 1           '' OpenGL 1.1
    RL_OPENGL_21               '' OpenGL 2.1 (GLSL 120)
    RL_OPENGL_33               '' OpenGL 3.3 (GLSL 330)
    RL_OPENGL_43               '' OpenGL 4.3 (using GLSL 330)
    RL_OPENGL_ES_20            '' OpenGL ES 2.0 (GLSL 100)
    RL_OPENGL_ES_30            '' OpenGL ES 3.0 (GLSL 300 es)
end enum

'' Trace log level
'' NOTE: Organized by priority level
type rlTraceLogLevel as long
enum
    RL_LOG_ALL = 0             '' Display all logs
    RL_LOG_TRACE               '' Trace logging, intended for internal use only
    RL_LOG_DEBUG               '' Debug logging, used for internal debugging, it should be disabled on release builds
    RL_LOG_INFO                '' Info logging, used for program execution info
    RL_LOG_WARNING             '' Warning logging, used on recoverable failures
    RL_LOG_ERROR               '' Error logging, used on unrecoverable failures
    RL_LOG_FATAL               '' Fatal logging, used to abort program: exit(EXIT_FAILURE)
    RL_LOG_NONE                '' Disable logging
end enum

'' Texture pixel formats
'' NOTE: Support depends on OpenGL version
type rlPixelFormat as long
enum
    RL_PIXELFORMAT_UNCOMPRESSED_GRAYSCALE = 1     '' 8 bit per pixel (no alpha)
    RL_PIXELFORMAT_UNCOMPRESSED_GRAY_ALPHA        '' 8*2 bpp (2 channels)
    RL_PIXELFORMAT_UNCOMPRESSED_R5G6B5            '' 16 bpp
    RL_PIXELFORMAT_UNCOMPRESSED_R8G8B8            '' 24 bpp
    RL_PIXELFORMAT_UNCOMPRESSED_R5G5B5A1          '' 16 bpp (1 bit alpha)
    RL_PIXELFORMAT_UNCOMPRESSED_R4G4B4A4          '' 16 bpp (4 bit alpha)
    RL_PIXELFORMAT_UNCOMPRESSED_R8G8B8A8          '' 32 bpp
    RL_PIXELFORMAT_UNCOMPRESSED_R32               '' 32 bpp (1 channel - float)
    RL_PIXELFORMAT_UNCOMPRESSED_R32G32B32         '' 32*3 bpp (3 channels - float)
    RL_PIXELFORMAT_UNCOMPRESSED_R32G32B32A32      '' 32*4 bpp (4 channels - float)
    RL_PIXELFORMAT_UNCOMPRESSED_R16               '' 16 bpp (1 channel - half float)
    RL_PIXELFORMAT_UNCOMPRESSED_R16G16B16         '' 16*3 bpp (3 channels - half float)
    RL_PIXELFORMAT_UNCOMPRESSED_R16G16B16A16      '' 16*4 bpp (4 channels - half float)
    RL_PIXELFORMAT_COMPRESSED_DXT1_RGB            '' 4 bpp (no alpha)
    RL_PIXELFORMAT_COMPRESSED_DXT1_RGBA           '' 4 bpp (1 bit alpha)
    RL_PIXELFORMAT_COMPRESSED_DXT3_RGBA           '' 8 bpp
    RL_PIXELFORMAT_COMPRESSED_DXT5_RGBA           '' 8 bpp
    RL_PIXELFORMAT_COMPRESSED_ETC1_RGB            '' 4 bpp
    RL_PIXELFORMAT_COMPRESSED_ETC2_RGB            '' 4 bpp
    RL_PIXELFORMAT_COMPRESSED_ETC2_EAC_RGBA       '' 8 bpp
    RL_PIXELFORMAT_COMPRESSED_PVRT_RGB            '' 4 bpp
    RL_PIXELFORMAT_COMPRESSED_PVRT_RGBA           '' 4 bpp
    RL_PIXELFORMAT_COMPRESSED_ASTC_4x4_RGBA       '' 8 bpp
    RL_PIXELFORMAT_COMPRESSED_ASTC_8x8_RGBA       '' 2 bpp
end enum

'' Texture parameters: filter mode
'' NOTE 1: Filtering considers mipmaps if available in the texture
'' NOTE 2: Filter is accordingly set for minification and magnification
type rlTextureFilter as long
enum
    RL_TEXTURE_FILTER_POINT = 0        '' No filter, just pixel approximation
    RL_TEXTURE_FILTER_BILINEAR         '' Linear filtering
    RL_TEXTURE_FILTER_TRILINEAR        '' Trilinear filtering (linear with mipmaps)
    RL_TEXTURE_FILTER_ANISOTROPIC_4X   '' Anisotropic filtering 4x
    RL_TEXTURE_FILTER_ANISOTROPIC_8X   '' Anisotropic filtering 8x
    RL_TEXTURE_FILTER_ANISOTROPIC_16X  '' Anisotropic filtering 16x
end enum

'' Color blending modes (pre-defined)
type rlBlendMode as long
enum
    RL_BLEND_ALPHA = 0                 '' Blend textures considering alpha (default)
    RL_BLEND_ADDITIVE                  '' Blend textures adding colors
    RL_BLEND_MULTIPLIED                '' Blend textures multiplying colors
    RL_BLEND_ADD_COLORS                '' Blend textures adding colors (alternative)
    RL_BLEND_SUBTRACT_COLORS           '' Blend textures subtracting colors (alternative)
    RL_BLEND_ALPHA_PREMULTIPLY         '' Blend premultiplied textures considering alpha
    RL_BLEND_CUSTOM                    '' Blend textures using custom src/dst factors (use rlSetBlendFactors())
    RL_BLEND_CUSTOM_SEPARATE           '' Blend textures using custom src/dst factors (use rlSetBlendFactorsSeparate())
end enum

'' Shader location point type
type rlShaderLocationIndex as long
enum
    RL_SHADER_LOC_VERTEX_POSITION = 0  '' Shader location: vertex attribute: position
    RL_SHADER_LOC_VERTEX_TEXCOORD01    '' Shader location: vertex attribute: texcoord01
    RL_SHADER_LOC_VERTEX_TEXCOORD02    '' Shader location: vertex attribute: texcoord02
    RL_SHADER_LOC_VERTEX_NORMAL        '' Shader location: vertex attribute: normal
    RL_SHADER_LOC_VERTEX_TANGENT       '' Shader location: vertex attribute: tangent
    RL_SHADER_LOC_VERTEX_COLOR         '' Shader location: vertex attribute: color
    RL_SHADER_LOC_MATRIX_MVP           '' Shader location: matrix uniform: model-view-projection
    RL_SHADER_LOC_MATRIX_VIEW          '' Shader location: matrix uniform: view (camera transform)
    RL_SHADER_LOC_MATRIX_PROJECTION    '' Shader location: matrix uniform: projection
    RL_SHADER_LOC_MATRIX_MODEL         '' Shader location: matrix uniform: model (transform)
    RL_SHADER_LOC_MATRIX_NORMAL        '' Shader location: matrix uniform: normal
    RL_SHADER_LOC_VECTOR_VIEW          '' Shader location: vector uniform: view
    RL_SHADER_LOC_COLOR_DIFFUSE        '' Shader location: vector uniform: diffuse color
    RL_SHADER_LOC_COLOR_SPECULAR       '' Shader location: vector uniform: specular color
    RL_SHADER_LOC_COLOR_AMBIENT        '' Shader location: vector uniform: ambient color
    RL_SHADER_LOC_MAP_ALBEDO           '' Shader location: sampler2d texture: albedo (same as: RL_SHADER_LOC_MAP_DIFFUSE)
    RL_SHADER_LOC_MAP_METALNESS        '' Shader location: sampler2d texture: metalness (same as: RL_SHADER_LOC_MAP_SPECULAR)
    RL_SHADER_LOC_MAP_NORMAL           '' Shader location: sampler2d texture: normal
    RL_SHADER_LOC_MAP_ROUGHNESS        '' Shader location: sampler2d texture: roughness
    RL_SHADER_LOC_MAP_OCCLUSION        '' Shader location: sampler2d texture: occlusion
    RL_SHADER_LOC_MAP_EMISSION         '' Shader location: sampler2d texture: emission
    RL_SHADER_LOC_MAP_HEIGHT           '' Shader location: sampler2d texture: height
    RL_SHADER_LOC_MAP_CUBEMAP          '' Shader location: samplerCube texture: cubemap
    RL_SHADER_LOC_MAP_IRRADIANCE       '' Shader location: samplerCube texture: irradiance
    RL_SHADER_LOC_MAP_PREFILTER        '' Shader location: samplerCube texture: prefilter
    RL_SHADER_LOC_MAP_BRDF             '' Shader location: sampler2d texture: brdf
end enum

#define RL_SHADER_LOC_MAP_DIFFUSE       RL_SHADER_LOC_MAP_ALBEDO
#define RL_SHADER_LOC_MAP_SPECULAR      RL_SHADER_LOC_MAP_METALNESS

'' Shader uniform data type
type rlShaderUniformDataType as long
enum
    RL_SHADER_UNIFORM_FLOAT = 0        '' Shader uniform type: float
    RL_SHADER_UNIFORM_VEC2             '' Shader uniform type: vec2 (2 float)
    RL_SHADER_UNIFORM_VEC3             '' Shader uniform type: vec3 (3 float)
    RL_SHADER_UNIFORM_VEC4             '' Shader uniform type: vec4 (4 float)
    RL_SHADER_UNIFORM_INT              '' Shader uniform type: int
    RL_SHADER_UNIFORM_IVEC2            '' Shader uniform type: ivec2 (2 int)
    RL_SHADER_UNIFORM_IVEC3            '' Shader uniform type: ivec3 (3 int)
    RL_SHADER_UNIFORM_IVEC4            '' Shader uniform type: ivec4 (4 int)
    RL_SHADER_UNIFORM_UINT             '' Shader uniform type: unsigned int
    RL_SHADER_UNIFORM_UIVEC2           '' Shader uniform type: uivec2 (2 unsigned int)
    RL_SHADER_UNIFORM_UIVEC3           '' Shader uniform type: uivec3 (3 unsigned int)
    RL_SHADER_UNIFORM_UIVEC4           '' Shader uniform type: uivec4 (4 unsigned int)
    RL_SHADER_UNIFORM_SAMPLER2D        '' Shader uniform type: sampler2d
end enum

'' Shader attribute data types
type rlShaderAttributeDataType as long
enum
    RL_SHADER_ATTRIB_FLOAT = 0,         '' Shader attribute type: float
    RL_SHADER_ATTRIB_VEC2,              '' Shader attribute type: vec2 (2 float)
    RL_SHADER_ATTRIB_VEC3,              '' Shader attribute type: vec3 (3 float)
    RL_SHADER_ATTRIB_VEC4               '' Shader attribute type: vec4 (4 float)
end enum

'' Framebuffer attachment type
'' NOTE: By default up to 8 color channels defined, but it can be more
type rlFramebufferAttachType as long
enum
    RL_ATTACHMENT_COLOR_CHANNEL0 = 0       '' Framebuffer attachment type: color 0
    RL_ATTACHMENT_COLOR_CHANNEL1 = 1       '' Framebuffer attachment type: color 1
    RL_ATTACHMENT_COLOR_CHANNEL2 = 2       '' Framebuffer attachment type: color 2
    RL_ATTACHMENT_COLOR_CHANNEL3 = 3       '' Framebuffer attachment type: color 3
    RL_ATTACHMENT_COLOR_CHANNEL4 = 4       '' Framebuffer attachment type: color 4
    RL_ATTACHMENT_COLOR_CHANNEL5 = 5       '' Framebuffer attachment type: color 5
    RL_ATTACHMENT_COLOR_CHANNEL6 = 6       '' Framebuffer attachment type: color 6
    RL_ATTACHMENT_COLOR_CHANNEL7 = 7       '' Framebuffer attachment type: color 7
    RL_ATTACHMENT_DEPTH = 100              '' Framebuffer attachment type: depth
    RL_ATTACHMENT_STENCIL = 200            '' Framebuffer attachment type: stencil
end enum

'' Framebuffer texture attachment type
type rlFramebufferAttachTextureType as long
enum
    RL_ATTACHMENT_CUBEMAP_POSITIVE_X = 0   '' Framebuffer texture attachment type: cubemap, +X side
    RL_ATTACHMENT_CUBEMAP_NEGATIVE_X = 1   '' Framebuffer texture attachment type: cubemap, -X side
    RL_ATTACHMENT_CUBEMAP_POSITIVE_Y = 2   '' Framebuffer texture attachment type: cubemap, +Y side
    RL_ATTACHMENT_CUBEMAP_NEGATIVE_Y = 3   '' Framebuffer texture attachment type: cubemap, -Y side
    RL_ATTACHMENT_CUBEMAP_POSITIVE_Z = 4   '' Framebuffer texture attachment type: cubemap, +Z side
    RL_ATTACHMENT_CUBEMAP_NEGATIVE_Z = 5   '' Framebuffer texture attachment type: cubemap, -Z side
    RL_ATTACHMENT_TEXTURE2D = 100          '' Framebuffer texture attachment type: texture2d
    RL_ATTACHMENT_RENDERBUFFER = 200       '' Framebuffer texture attachment type: renderbuffer
end enum

'' Face culling mode
type rlCullMode as long
enum
    RL_CULL_FACE_FRONT = 0
    RL_CULL_FACE_BACK
end enum

''------------------------------------------------------------------------------------
'' Functions Declaration - Matrix operations
''------------------------------------------------------------------------------------

extern "C"            '' Prevents name mangling of functions

declare sub rlMatrixMode(byval mode as long)                                                            '' Choose the current matrix to be transformed
declare sub rlPushMatrix()                                                                              '' Push the current matrix to stack
declare sub rlPopMatrix()                                                                               '' Pop latest inserted matrix from stack
declare sub rlLoadIdentity()                                                                            '' Reset current matrix to identity matrix
declare sub rlTranslatef(byval x as single, byval y as single, byval z as single)                       '' Multiply the current matrix by a translation matrix
declare sub rlRotatef(byval angle as single, byval x as single, byval y as single, byval z as single)   '' Multiply the current matrix by a rotation matrix
declare sub rlScalef(byval x as single, byval y as single, byval z as single)                           '' Multiply the current matrix by a scaling matrix
declare sub rlMultMatrixf(byval matf as const single ptr)                                               '' Multiply the current matrix by another matrix
declare sub rlFrustum(byval left as double, byval right as double, byval bottom as double, byval top as double, byval znear as double, byval zfar as double)
declare sub rlOrtho(byval left as double, byval right as double, byval bottom as double, byval top as double, byval znear as double, byval zfar as double)
declare sub rlViewport(byval x as long, byval y as long, byval width as long, byval height as long)     '' Set the viewport area
declare sub rlSetClipPlanes(byval nearPlane as double, byval farPlane as double)                                          '' Set clip planes distances
declare function rlGetCullDistanceNear() as double                                                      '' Get cull plane distance near
declare function rlGetCullDistanceFar() as double                                                       '' Get cull plane distance far

''------------------------------------------------------------------------------------
'' Functions Declaration - Vertex level operations
''------------------------------------------------------------------------------------
declare sub rlBegin(byval mode as long)                                                             '' Initialize drawing mode (how to organize vertex)
declare sub rlEnd()                                                                                 '' Finish vertex providing
declare sub rlVertex2i(byval x as long, byval y as long)                                            '' Define one vertex (position) - 2 int
declare sub rlVertex2f(byval x as single, byval y as single)                                        '' Define one vertex (position) - 2 float
declare sub rlVertex3f(byval x as single, byval y as single, byval z as single)                     '' Define one vertex (position) - 3 float
declare sub rlTexCoord2f(byval x as single, byval y as single)                                      '' Define one vertex (texture coordinate) - 2 float
declare sub rlNormal3f(byval x as single, byval y as single, byval z as single)                     '' Define one vertex (normal) - 3 float
declare sub rlColor4ub(byval r as ubyte, byval g as ubyte, byval b as ubyte, byval a as ubyte)      '' Define one vertex (color) - 4 byte
declare sub rlColor3f(byval x as single, byval y as single, byval z as single)                      '' Define one vertex (color) - 3 float
declare sub rlColor4f(byval x as single, byval y as single, byval z as single, byval w as single)   '' Define one vertex (color) - 4 float

''------------------------------------------------------------------------------------
'' Functions Declaration - OpenGL style functions (common to 1.1, 3.3+, ES2)
'' NOTE: This functions are used to completely abstract raylib code from OpenGL layer,
'' some of them are direct wrappers over OpenGL calls, some others are custom
''------------------------------------------------------------------------------------

'' Vertex buffers state
declare function rlEnableVertexArray(byval vaoId as ulong) as boolean                       '' Enable vertex array (VAO, if supported)
declare sub rlDisableVertexArray()                                                          '' Disable vertex array (VAO, if supported)
declare sub rlEnableVertexBuffer(byval id as ulong)                                         '' Enable vertex buffer (VBO)
declare sub rlDisableVertexBuffer()                                                         '' Disable vertex buffer (VBO)
declare sub rlEnableVertexBufferElement(byval id as ulong)                                  '' Enable vertex buffer element (VBO element)
declare sub rlDisableVertexBufferElement()                                                  '' Disable vertex buffer element (VBO element)
declare sub rlEnableVertexAttribute(byval index as ulong)                                   '' Enable vertex attribute index
declare sub rlDisableVertexAttribute(byval index as ulong)                                  '' Disable vertex attribute index
#if defined(GRAPHICS_API_OPENGL_11)
declare sub rlEnableStatePointer(byval vertexAttribType as long, byval buffer as any ptr)   '' Enable attribute state pointer
declare sub rlDisableStatePointer(byval vertexAttribType as long)                           '' Disable attribute state pointer
#endif

'' Textures state
declare sub rlActiveTextureSlot(byval slot as long)                                             '' Select and active a texture slot
declare sub rlEnableTexture(byval id as ulong)                                                  '' Enable texture
declare sub rlDisableTexture()                                                                  '' Disable texture
declare sub rlEnableTextureCubemap(byval id as ulong)                                           '' Enable texture cubemap
declare sub rlDisableTextureCubemap()                                                           '' Disable texture cubemap
declare sub rlTextureParameters(byval id as ulong, byval param as long, byval value as long)    '' Set texture parameters (filter, wrap)
declare sub rlCubemapParameters(byval id as ulong, byval param as long, byval value as long)    '' Set cubemap parameters (filter, wrap)

'' Shader state
declare sub rlEnableShader(byval id as ulong)   '' Enable shader program
declare sub rlDisableShader()                   '' Disable shader program

'' Framebuffer state
declare sub rlEnableFramebuffer(byval id as ulong)                                  '' Enable render texture (fbo)
declare sub rlDisableFramebuffer()                                                  '' Disable render texture (fbo), return to default framebuffer
declare function rlGetActiveFramebuffer() as ulong                              '' Get the currently active render texture (fbo), 0 for default framebuffer
declare sub rlActiveDrawBuffers(byval count as long)                                '' Activate multiple draw color buffers
declare sub rlBlitFramebuffer(byval srcX as long, byval srcY as long, byval srcWidth as long, byval srcHeight as long, byval dstX as long, byval dstY as long, byval dstWidth as long, byval dstHeight as long, byval bufferMask as long) '' Blit active framebuffer to main framebuffer
declare sub rlBindFramebuffer(byval target as ulong, byval framebuffer as ulong)    '' Bind framebuffer (FBO)

'' General render state
declare sub rlEnableColorBlend()                                                                    '' Enable color blending
declare sub rlDisableColorBlend()                                                                   '' Disable color blending
declare sub rlEnableDepthTest()                                                                     '' Enable depth test
declare sub rlDisableDepthTest()                                                                    '' Disable depth test
declare sub rlEnableDepthMask()                                                                     '' Enable depth write
declare sub rlDisableDepthMask()                                                                    '' Disable depth write
declare sub rlEnableBackfaceCulling()                                                               '' Enable backface culling
declare sub rlDisableBackfaceCulling()                                                              '' Disable backface culling
declare sub rlColorMask(byval r as long, byval g as long, byval b as long, byval a as long)         '' Color mask control
declare sub rlSetCullFace(byval mode as long)                                                       '' Set face culling mode
declare sub rlEnableScissorTest()                                                                   '' Enable scissor test
declare sub rlDisableScissorTest()                                                                  '' Disable scissor test
declare sub rlScissor(byval x as long, byval y as long, byval width as long, byval height as long)  '' Scissor test
declare sub rlEnableWireMode()                                                                      '' Enable wire mode
declare sub rlEnablePointMode()                                                                     '' Enable point mode
declare sub rlDisableWireMode()                                                                     '' Disable wire (and point) mode
declare sub rlSetLineWidth(byval width as single)                                                   '' Set the line drawing width
declare function rlGetLineWidth() as single                                                         '' Get the line drawing width
declare sub rlEnableSmoothLines()                                                                   '' Enable line aliasing
declare sub rlDisableSmoothLines()                                                                  '' Disable line aliasing
declare sub rlEnableStereoRender()                                                                  '' Enable stereo rendering
declare sub rlDisableStereoRender()                                                                 '' Disable stereo rendering
declare function rlIsStereoRenderEnabled() as boolean                                               '' Check if stereo render is enabled

declare sub rlClearColor(byval r as ubyte, byval g as ubyte, byval b as ubyte, byval a as ubyte)    '' Clear color buffer with color
declare sub rlClearScreenBuffers()                                                                  '' Clear used screen buffers (color and depth)
declare sub rlCheckErrors()                                                                         '' Check and log OpenGL error codes
declare sub rlSetBlendMode(byval mode as long)                                                      '' Set blending mode
declare sub rlSetBlendFactors(byval glSrcFactor as long, byval glDstFactor as long, byval glEquation as long) '' Set blending mode factor and equation (using OpenGL factors)
declare sub rlSetBlendFactorsSeparate(byval glSrcRGB as long, byval glDstRGB as long, byval glSrcAlpha as long, byval glDstAlpha as long, byval glEqRGB as long, byval glEqAlpha as long) '' Set blending mode factors and equations separately (using OpenGL factors)

''------------------------------------------------------------------------------------
'' Functions Declaration - rlgl functionality
''------------------------------------------------------------------------------------
'' rlgl initialization functions
declare sub rlglInit(byval width as long, byval height as long) '' Initialize rlgl (buffers, shaders, textures, states)
declare sub rlglClose()                                         '' De-initialize rlgl (buffers, shaders, textures)
declare sub rlLoadExtensions(byval loader as any ptr)           '' Load OpenGL extensions (loader function required)
declare function rlGetVersion() as long                         '' Get current OpenGL version
declare sub rlSetFramebufferWidth(byval width as long)          '' Set current framebuffer width
declare function rlGetFramebufferWidth() as long                '' Get default framebuffer width
declare sub rlSetFramebufferHeight(byval height as long)        '' Set current framebuffer height
declare function rlGetFramebufferHeight() as long               '' Get default framebuffer height

declare function rlGetTextureIdDefault() as ulong               '' Get default texture id
declare function rlGetShaderIdDefault() as ulong                '' Get default shader id
declare function rlGetShaderLocsDefault() as long ptr           '' Get default shader locations

'' Render batch management
'' NOTE: rlgl provides a default render batch to behave like OpenGL 1.1 immediate mode
'' but this render batch API is exposed in case of custom batches are required
declare function rlLoadRenderBatch(byval numBuffers as long, byval bufferElements as long) as rlRenderBatch '' Load a render batch system
declare sub rlUnloadRenderBatch(byval batch as rlRenderBatch)                                               '' Unload render batch system
declare sub rlDrawRenderBatch(byval batch as rlRenderBatch ptr)                                             '' Draw render batch data (Update->Draw->Reset)
declare sub rlSetRenderBatchActive(byval batch as rlRenderBatch)                                            '' Set the active render batch for rlgl (NULL for default internal)
declare sub rlDrawRenderBatchActive()                                                                       '' Update and draw internal render batch
declare function rlCheckRenderBatchLimit(byval vCount as long) as boolean                                   '' Check internal buffer overflow for a given number of vertex

declare sub rlSetTexture(byval id as ulong) '' Set current texture for render batch and check buffers limits

''------------------------------------------------------------------------------------------------------------------------

'' Vertex buffers management
declare function rlLoadVertexArray() as ulong                                                                                                       '' Load vertex array (vao) if supported
declare function rlLoadVertexBuffer(byval buffer as const any ptr, byval size as long, byval dynamic as long) as ulong                              '' Load a vertex buffer object
declare function rlLoadVertexBufferElement(byval buffer as const any ptr, byval size as long, byval dynamic as long) as ulong                       '' Load vertex buffer elements object
declare sub rlUpdateVertexBuffer(byval bufferId as ulong, byval data as const any ptr, byval dataSize as long, byval offset as long)                '' Update vertex buffer object data on GPU buffer
declare sub rlUpdateVertexBufferElements(byval id as ulong, byval data as const any ptr, byval dataSize as long, byval offset as long)              '' Update vertex buffer elements data on GPU buffer
declare sub rlUnloadVertexArray(byval vaoId as ulong)                                                                                               '' Unload vertex array (vao)
declare sub rlUnloadVertexBuffer(byval vboId as ulong)                                                                                              '' Unload vertex buffer object
declare sub rlSetVertexAttribute(byval index as ulong, byval compSize as long, byval type as long, byval normalized as long, byval stride as long, byval offset as long) '' Set vertex attribute data configuration
declare sub rlSetVertexAttributeDivisor(byval index as ulong, byval divisor as long)                                                                '' Set vertex attribute data divisor
declare sub rlSetVertexAttributeDefault(byval locIndex as long, byval value as const any ptr, byval attribType as long, byval count as long)        '' Set vertex attribute default value, when attribute to provided
declare sub rlDrawVertexArray(byval offset as long, byval count as long)                                                                            '' Draw vertex array (currently active vao)
declare sub rlDrawVertexArrayElements(byval offset as long, byval count as long, byval buffer as const any ptr)                                     '' Draw vertex array elements
declare sub rlDrawVertexArrayInstanced(byval offset as long, byval count as long, byval instances as long)                                          '' Draw vertex array (currently active vao) with instancing
declare sub rlDrawVertexArrayElementsInstanced(byval offset as long, byval count as long, byval buffer as const any ptr, byval instances as long)   '' Draw vertex array elements with instancing

'' Textures management
declare function rlLoadTexture(byval data as const any ptr, byval width as long, byval height as long, byval format as long, byval mipmapCount as long) as ulong    '' Load texture data
declare function rlLoadTextureDepth(byval width as long, byval height as long, byval useRenderBuffer as long) as ulong                                              '' Load depth texture/renderbuffer (to be attached to fbo)
declare function rlLoadTextureCubemap(byval data as const any ptr, byval size as long, byval format as long, byval mipmapCount as long) as ulong                    '' Load texture cubemap data
declare sub rlUpdateTexture(byval id as ulong, byval offsetX as long, byval offsetY as long, byval width as long, byval height as long, byval format as long, byval data as const any ptr) '' Update texture with new data on GPU
declare sub rlGetGlTextureFormats(byval format as long, byval glInternalFormat as ulong ptr, byval glFormat as ulong ptr, byval glType as ulong ptr)                '' Get OpenGL internal formats
declare function rlGetPixelFormatName(byval format as ulong ptr) as zstring ptr                                                                                     '' Get name string for pixel format
declare sub rlUnloadTexture(byval id as ulong ptr)                                                                                                                  '' Unload texture from GPU memory
declare sub rlGenTextureMipmaps(byval id as ulong, byval width as long, byval height as long, byval format as long, byval mipmaps as long ptr)                      '' Generate mipmap data for selected texture
declare sub rlReadTexturePixels(byval id as ulong, byval width as long, byval height as long, byval format as long)                                                 '' Read texture pixel data
declare function rlReadScreenPixels(byval width as long, byval height as long) as ubyte ptr                                                                         '' Read screen pixel data (color buffer)

'' Framebuffer management (fbo)
declare function rlLoadFramebuffer() as ulong                               '' Load an empty framebuffer
declare sub rlFramebufferAttach(byval fboId as ulong, byval texId as ulong, byval attachType as long, byval texType as long, byval mipLevel as long) '' Attach texture/renderbuffer to a framebuffer
declare function rlFramebufferComplete(byval id as ulong) as boolean        '' Verify framebuffer is complete
declare sub rlUnloadFramebuffer(byval id as ulong)                          '' Delete framebuffer from GPU

'' Shaders management
declare function rlLoadShaderCode(byval vsCode as const zstring ptr, byval cfsCode as const zstring ptr) as ulong               '' Load shader from code strings
declare function rlCompileShader(byval shaderCode as const zstring ptr, byval type as long) as ulong                            '' Compile custom shader and return shader id (type: RL_VERTEX_SHADER, RL_FRAGMENT_SHADER, RL_COMPUTE_SHADER)
declare function rlLoadShaderProgram(byval vShaderId as ulong, byval fShaderId as ulong) as ulong                               '' Load custom shader program
declare sub rlUnloadShaderProgram(byval id as ulong)                                                                            '' Unload shader program
declare function rlGetLocationUniform(byval shaderId as ulong, byval uniformName as const zstring ptr) as long                  '' Get shader location uniform
declare function rlGetLocationAttrib(byval shaderId as ulong, byval attribName as const zstring ptr) as long                    '' Get shader location attribute
declare sub rlSetUniform(byval locIndex as long, byval value as const any ptr, byval uniformType as long, byval count as long)  '' Set shader value uniform
declare sub rlSetUniformMatrix(byval locIndex as long, byval mat as Matrix)                                                     '' Set shader value matrix
declare sub rlSetUniformMatrices(byval locIndex as long, byval mat as const Matrix ptr, byval count as long)                    '' Set shader value matrices
declare sub rlSetUniformSampler(byval locIndex as long, byval textureId as ulong)                                               '' Set shader value sampler
declare sub rlSetShader(byval id as ulong, byval locs as long ptr)                                                              '' Set shader currently active (id and locations)

'' Compute shader management
declare function rlLoadComputeShaderProgram(byval shaderId as ulong) as ulong                               '' Load compute shader program
declare sub rlComputeShaderDispatch(byval groupX as ulong, byval groupY as ulong, byval groupZ as ulong)    '' Dispatch compute shader (equivalent to *draw* for graphics pipeline)

'' Shader buffer storage object management (ssbo)
declare function rlLoadShaderBuffer(byval size as ulong, byval data as const any ptr, byval usageHint as long) as ulong                                 '' Load shader storage buffer object (SSBO)
declare sub rlUnloadShaderBuffer(byval ssboId as ulong)                                                                                                 '' Unload shader storage buffer object (SSBO)
declare sub rlUpdateShaderBuffer(byval id as ulong, byval data as const any ptr, byval dataSize as ulong, byval offset as ulong)                        '' Update SSBO buffer data
declare sub rlBindShaderBuffer(byval id as ulong, byval index as ulong)                                                                                 '' Bind SSBO buffer
declare sub rlReadShaderBuffer(byval id as ulong, byval dest as any ptr, byval count as ulong, byval offset as ulong)                                   '' Read SSBO buffer data (GPU->CPU)
declare sub rlCopyShaderBuffer(byval destId as ulong, byval srcId as ulong, byval destOffset as ulong, byval srcOffset as ulong, byval count as ulong)  '' Copy SSBO data between buffers
declare function rlGetShaderBufferSize(byval id as ulong) as ulong                                                                                      '' Get SSBO buffer size

'' Buffer management
declare sub rlBindImageTexture(byval id as ulong, byval index as ulong, byval format as long, byval readonly as long)  '' Bind image texture

'' Matrix state management
declare function rlGetMatrixModelview() as Matrix                                       '' Get internal modelview matrix
declare function rlGetMatrixProjection() as Matrix                                      '' Get internal projection matrix
declare function rlGetMatrixTransform() as Matrix                                       '' Get internal accumulated transform matrix
declare function rlGetMatrixProjectionStereo(byval eye as long) as Matrix               '' Get internal projection matrix for stereo render (selected eye)
declare function rlGetMatrixViewOffsetStereo(byval eye as long) as Matrix               '' Get internal view offset matrix for stereo render (selected eye)
declare sub rlSetMatrixProjection(byval proj as Matrix)                                 '' Set a custom projection matrix (replaces internal projection matrix)
declare sub rlSetMatrixModelview(byval view as Matrix)                                  '' Set a custom modelview matrix (replaces internal modelview matrix)
declare sub rlSetMatrixProjectionStereo(byval right as Matrix, byval left as Matrix)    '' Set eyes projection matrices for stereo rendering
declare sub rlSetMatrixViewOffsetStereo(byval right as Matrix, byval left as Matrix)    '' Set eyes view offsets matrices for stereo rendering

'' Quick and dirty cube/quad buffers load->draw->unload
declare sub rlLoadDrawCube()     '' Load and draw a cube
declare sub rlLoadDrawQuad()     '' Load and draw a quad
end extern
#endif '' RLGL_H