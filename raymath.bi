#pragma once
/'*********************************************************************************************
*   raymath v2.0 - Math functions to work with Vector2, Vector3, Matrix and Quaternions
*	FreeBASIC headers: Imortis Inglorian 2026
*   CONVENTIONS:
*     - Matrix structure is defined as row-major (memory layout) but parameters naming AND all
*       math operations performed by the library consider the structure as it was column-major
*       It is like transposed versions of the matrices are used for all the maths
*       It benefits some functions making them cache-friendly and also avoids matrix
*       transpositions sometimes required by OpenGL
*       Example: In memory order, row0 is [m0 m4 m8 m12] but in semantic math row0 is [m0 m1 m2 m3]
*     - Functions are always self-contained, no function use another raymath function inside,
*       required code is directly re-implemented inside
*     - Functions input parameters are always received by value (2 unavoidable exceptions)
*     - Functions use always a "result" variable for return (except C++ operators)
*     - Functions are always defined inline
*     - Angles are always in radians (DEG2RAD/RAD2DEG macros provided for convenience)
*     - No compound literals used to make sure libray is compatible with C++
*
*   CONFIGURATION:
*       #define RAYMATH_IMPLEMENTATION
*           Generates the implementation of the library into the included file.
*           If not defined, the library is in header only mode and can be included in other headers
*           or source files without problems. But only ONE file should hold the implementation.
*
*       #define RAYMATH_STATIC_INLINE
*           Define static inline functions code, so #include header suffices for use.
*           This may use up lots of memory.
*
*       #define RAYMATH_DISABLE_CPP_OPERATORS
*           Disables C++ operator overloads for raymath types.
*
*   LICENSE: zlib/libpng
*
*   Copyright (c) 2015-2024 Ramon Santamaria (@raysan5)
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

extern "C"

#define RAYMATH_H

''----------------------------------------------------------------------------------
'' Defines and Macros
''----------------------------------------------------------------------------------

'' Get float vector for Matrix
#ifndef MatrixToFloat
	#define MatrixToFloat(mat) MatrixToFloatV(mat).v
#endif
'' Get float vector for Vector3
#ifndef Vector3ToFloat
	#define Vector3ToFloat(vec) Vector3ToFloatV(vec).v
#endif

''----------------------------------------------------------------------------------
'' Types and Structures Definition
''----------------------------------------------------------------------------------
'' Matrix, 4x4 components, column major, OpenGL style, right-handed
type Matrix
    declare constructor()
    declare constructor(m0 as single, m4 as single, m8 as single, m12 as single, _
                        m1 as single, m5 as single, m9 as single, m13 as single, _
                        m2 as single, m6 as single, m10 as single, m14 as single, _
                        m3 as single, m7 as single, m11 as single, m15 as single)
    as single m0, m4, m8,  m12 '' Matrix first row (4 components)
    as single m1, m5, m9,  m13 '' Matrix second row (4 components)
    as single m2, m6, m10, m14 '' Matrix third row (4 components)
    as single m3, m7, m11, m15 '' Matrix fourth row (4 components)
end type

constructor Matrix(m0 as single, m4 as single, m8 as single, m12 as single, _
                        m1 as single, m5 as single, m9 as single, m13 as single, _
                        m2 as single, m6 as single, m10 as single, m14 as single, _
                        m3 as single, m7 as single, m11 as single, m15 as single)
    this.m0 = m0
    this.m1 = m1
    this.m2 = m2
    this.m3 = m3
    this.m4 = m4
    this.m5 = m5
    this.m6 = m6
    this.m7 = m7
    this.m8 = m8
    this.m9 = m9
    this.m10 = m10
    this.m11 = m11
    this.m12 = m12
    this.m13 = m13
    this.m14 = m14
    this.m15 = m15
end constructor
constructor Matrix()
end constructor

'' Vector2, 2 components
type Vector2
	declare constructor()
    declare constructor(x as single, y as single)
    x as single
    y as single
end type

constructor Vector2(x as single, y as single)
    this.x = x
    this.y = y
end constructor
    
constructor Vector2()
end constructor

'' Vector3, 3 components
type Vector3
    declare constructor()
    declare constructor(x as single, y as single, z as single)
    x as single
    y as single
    z as single
end type

constructor Vector3()
end constructor

constructor Vector3(x as single, y as single, z as single)
    this.x = x
    this.y = y
    this.z = z
end constructor

'' Vector4, 4 components
type Vector4
    declare constructor()
    declare constructor(x as single, y as single, z as single, w as single)
    x as single
    y as single
    z as single
    w as single
end type

constructor Vector4()
end constructor

constructor Vector4(x as single, y as single, z as single, w as single)
    this.x = x
    this.y = y
    this.z = z
    this.w = w
end constructor


'' Quaternion, 4 components (Vector4 alias)
type Quaternion
    declare constructor()
    declare constructor(x as single, y as single, z as single, w as single)
    x as single
    y as single
    z as single
    w as single
end type

constructor Quaternion()
end constructor

constructor Quaternion(x as single, y as single, z as single, w as single)
    this.x = x
    this.y = y
    this.z = z
    this.w = w
end constructor

#define RL_MATRIX_TYPE
#define RL_QUATERNION_TYPE
#define RL_VECTOR4_TYPE
#define RL_VECTOR3_TYPE
#define RL_VECTOR2_TYPE

'' NOTE: Helper types to be used instead of array return types for *ToFloat functions
type float3
	v(2) as single
end type

type float16
	v(15) as single
end type

''----------------------------------------------------------------------------------
'' Module Functions Definition - Utils math
''----------------------------------------------------------------------------------

'' Clamp float value
declare function Clamp(byval value as single, byval min as single, byval max as single) as single
'' Calculate linear interpolation between two floats
declare function Lerp(byval start as single, byval end_ as single, byval amount as single) as single
'' Normalize input value within input range
declare function Normalize(byval value as single, byval start as single, byval end_ as single) as single
'' Remap input value within input range to output range
declare function Remap(byval value as single, byval inputStart as single, byval inputEnd as single, byval outputStart as single, byval outputEnd as single) as single
'' Wrap input value from min to max
declare function Wrap(byval value as single, byval min as single, byval max as single) as single
'' Check whether two given floats are almost equal
declare function FloatEquals(byval x as single, byval y as single) as long

''----------------------------------------------------------------------------------
'' Module Functions Definition - Vector2 math
''----------------------------------------------------------------------------------

'' Vector with components value 0.0f
declare function Vector2Zero() as Vector2
'' Vector with components value 1.0f
declare function Vector2One() as Vector2
'' Add two vectors (v1 + v2)
declare function Vector2Add(byval v1 as Vector2, byval v2 as Vector2) as Vector2
'' Add vector and float value
declare function Vector2AddValue(byval v as Vector2, byval add as single) as Vector2
'' Subtract two vectors (v1 - v2)
declare function Vector2Subtract(byval v1 as Vector2, byval v2 as Vector2) as Vector2
'' Subtract vector by float value
declare function Vector2SubtractValue(byval v as Vector2, byval sub_ as single) as Vector2
'' Calculate vector length
declare function Vector2Length(byval v as Vector2) as single
'' Calculate vector square length
declare function Vector2LengthSqr(byval v as Vector2) as single
'' Calculate two vectors dot product
declare function Vector2DotProduct(byval v1 as Vector2, byval v2 as Vector2) as single
'' Calculate distance between two vectors
declare function Vector2Distance(byval v1 as Vector2, byval v2 as Vector2) as single
'' Calculate square distance between two vectors
declare function Vector2DistanceSqr(byval v1 as Vector2, byval v2 as Vector2) as single
'' Calculate angle between two vectors
'' NOTE: Angle is calculated from origin point (0, 0)
declare function Vector2Angle(byval v1 as Vector2, byval v2 as Vector2) as single
'' Calculate angle defined by a two vectors line
'' NOTE: Parameters need to be normalized
'' Current implementation should be aligned with glm::angle
declare function Vector2LineAngle(byval start as Vector2, byval end_ as Vector2) as single
'' Scale vector (multiply by value)
declare function Vector2Scale(byval v as Vector2, byval scale as single) as Vector2
'' Multiply vector by vector
declare function Vector2Multiply(byval v1 as Vector2, byval v2 as Vector2) as Vector2
'' Negate vector
declare function Vector2Negate(byval v as Vector2) as Vector2
'' Divide vector by vector
declare function Vector2Divide(byval v1 as Vector2, byval v2 as Vector2) as Vector2
'' Normalize provided vector
declare function Vector2Normalize(byval v as Vector2) as Vector2
'' Transforms a Vector2 by a given Matrix
declare function Vector2Transform(byval v as Vector2, byval mat as Matrix) as Vector2
'' Calculate linear interpolation between two vectors
declare function Vector2Lerp(byval v1 as Vector2, byval v2 as Vector2, byval amount as single) as Vector2
'' Calculate reflected vector to normal
declare function Vector2Reflect(byval v as Vector2, byval normal as Vector2) as Vector2
'' Get min value for each pair of components
declare function Vector2Min(byval v1 as Vector2, byval v2 as Vector2) as Vector2
'' Get max value for each pair of components
declare function Vector2Max(byval v1 as Vector2, byval v2 as Vector2) as Vector2
'' Rotate vector by angle
declare function Vector2Rotate(byval v as Vector2, byval angle as single) as Vector2
'' Move Vector towards target
declare function Vector2MoveTowards(byval v as Vector2, byval target as Vector2, byval maxDistance as single) as Vector2
'' Invert the given vector
declare function Vector2Invert(byval v as Vector2) as Vector2
'' Clamp the components of the vector between
'' min and max values specified by the given vectors
declare function Vector2Clamp(byval v as Vector2, byval min as Vector2, byval max as Vector2) as Vector2
'' Clamp the magnitude of the vector between two min and max values
declare function Vector2ClampValue(byval v as Vector2, byval min as single, byval max as single) as Vector2
'' Check whether two given vectors are almost equal
declare function Vector2Equals(byval p as Vector2, byval q as Vector2) as long
'' Compute the direction of a refracted ray
'' v: normalized direction of the incoming ray
'' n: normalized normal vector of the interface of two optical media
'' r: ratio of the refractive index of the medium from where the ray comes
''    to the refractive index of the medium on the other side of the surface

''----------------------------------------------------------------------------------
'' Module Functions Definition - Vector3 math
''----------------------------------------------------------------------------------
'' Vector with components value 0.0f
declare function Vector3Zero() as Vector3
'' Vector with components value 1.0f
declare function Vector3One() as Vector3
'' Add two vectors
declare function Vector3Add(byval v1 as Vector3, byval v2 as Vector3) as Vector3
'' Add vector and float value
declare function Vector3AddValue(byval v as Vector3, byval add as single) as Vector3
'' Subtract two vectors
declare function Vector3Subtract(byval v1 as Vector3, byval v2 as Vector3) as Vector3
' Subtract vector by float value
declare function Vector3SubtractValue(byval v as Vector3, byval sub_ as single) as Vector3
'' Multiply vector by scalar
declare function Vector3Scale(byval v as Vector3, byval scalar as single) as Vector3
'' Multiply vector by vector
declare function Vector3Multiply(byval v1 as Vector3, byval v2 as Vector3) as Vector3
' Calculate two vectors cross product
declare function Vector3CrossProduct(byval v1 as Vector3, byval v2 as Vector3) as Vector3
'' Calculate one vector perpendicular vector
declare function Vector3Perpendicular(byval v as Vector3) as Vector3
'' Calculate vector length
declare function Vector3Length(byval v as const Vector3) as single
'' Calculate vector square length
declare function Vector3LengthSqr(byval v as const Vector3) as single
'' Calculate two vectors dot product
declare function Vector3DotProduct(byval v1 as Vector3, byval v2 as Vector3) as single
'' Calculate distance between two vectors
declare function Vector3Distance(byval v1 as Vector3, byval v2 as Vector3) as single
'' Calculate square distance between two vectors
declare function Vector3DistanceSqr(byval v1 as Vector3, byval v2 as Vector3) as single
'' Calculate angle between two vectors
declare function Vector3Angle(byval v1 as Vector3, byval v2 as Vector3) as single
'' Negate provided vector (invert direction)
declare function Vector3Negate(byval v as Vector3) as Vector3
'' Divide vector by vector
declare function Vector3Divide(byval v1 as Vector3, byval v2 as Vector3) as Vector3
'' Normalize provided vector
declare function Vector3Normalize(byval v as Vector3) as Vector3
'' Calculate the projection of the vector v1 on to v2
declare function Vector3Project(byval v1 as Vector3, byval v2 as Vector3) as Vector3
'' Calculate the rejection of the vector v1 on to v2
declare function Vector3Reject(byval v1 as Vector3, byval v2 as Vector3) as Vector3
'' Orthonormalize provided vectors
'' Makes vectors normalized and orthogonal to each other
'' Gram-Schmidt function implementation
declare sub Vector3OrthoNormalize(byval v1 as Vector3 ptr, byval v2 as Vector3 ptr)
'' Transforms a Vector3 by a given Matrix
declare function Vector3Transform(byval v as Vector3, byval mat as Matrix) as Vector3
'' Transform a vector by quaternion rotation
declare function Vector3RotateByQuaternion(byval v as Vector3, byval q as Quaternion) as Vector3
'' Rotates a vector around an axis
declare function Vector3RotateByAxisAngle(byval v as Vector3, byval axis as Vector3, byval angle as single) as Vector3
'' Move Vector towards target
declare function Vector3MoveTowards(byval v as Vector3, byval target as Vector3, byval maxDistance as single) as Vector3
'' Calculate linear interpolation between two vectors
declare function Vector3Lerp(byval v1 as Vector3, byval v2 as Vector3, byval amount as single) as Vector3
'' Calculate cubic hermite interpolation between two vectors and their tangents
'' as described in the GLTF 2.0 specification: https://registry.khronos.org/glTF/specs/2.0/glTF-2.0.html#interpolation-cubic
declare function Vector3CubicHermite(byval v1 as Vector3, byval tangent1 as Vector3, byval v2 as Vector3, byval tangent2 as Vector3, byval amount as single) as Vector3
'' Calculate reflected vector to normal
declare function Vector3Reflect(byval v as Vector3, byval normal as Vector3) as Vector3
'' Get min value for each pair of components
declare function Vector3Min(byval v1 as Vector3, byval v2 as Vector3) as Vector3
'' Get max value for each pair of components
declare function Vector3Max(byval v1 as Vector3, byval v2 as Vector3) as Vector3
' Compute barycenter coordinates (u, v, w) for point p with respect to triangle (a, b, c)
'' NOTE: Assumes P is on the plane of the triangle
declare function Vector3Barycenter(byval p as Vector3, byval a as Vector3, byval b as Vector3, byval c as Vector3) as Vector3
'' Projects a Vector3 from screen space into object space
'' NOTE: We are avoiding calling other raymath functions despite available
declare function Vector3Unproject(byval source as Vector3, byval projection as Matrix, byval view_ as Matrix) as Vector3
'' Get Vector3 as float array
declare function Vector3ToFloatV(byval v as Vector3) as float3
'' Invert the given vector
declare function Vector3Invert(byval v as Vector3) as Vector3
'' Clamp the components of the vector between
'' min and max values specified by the given vectors
declare function Vector3Clamp(byval v as Vector3, byval min as Vector3, byval max as Vector3) as Vector3
'' Clamp the magnitude of the vector between two values
declare function Vector3ClampValue(byval v as Vector3, byval min as single, byval max as single) as Vector3
'' Check whether two given vectors are almost equal
declare function Vector3Equals(byval p as Vector3, byval q as Vector3) as long
'' Compute the direction of a refracted ray
'' v: normalized direction of the incoming ray
'' n: normalized normal vector of the interface of two optical media
'' r: ratio of the refractive index of the medium from where the ray comes
''    to the refractive index of the medium on the other side of the surface
declare function Vector3Refract(byval v as Vector3, byval n as Vector3, byval r as single) as Vector3

''----------------------------------------------------------------------------------
'' Module Functions Definition - Vector4 math
''----------------------------------------------------------------------------------
declare function Vector4Zero() as Vector4
declare function Vector4One() as Vector4
declare function Vector4Add(byval v1 as Vector4, byval v2 as Vector4) as Vector4
declare function Vector4AddValue(byval v as Vector4, byval add as single) as Vector4
declare function Vector4Subtract(byval v1 as Vector4, byval v2 as Vector4) as Vector4
declare function Vector4SubtractValue(byval v as Vector4, byval add as single) as Vector4
declare function Vector4Length(byval v as Vector4) as single
declare function Vector4LengthSqr(byval v as Vector4) as single
declare function Vector4DotProduct(byval v1 as Vector4, byval v2 as Vector4) as single
declare function Vector4Distance(byval v1 as Vector4, byval v2 as Vector4) as single
declare function Vector4DistanceSqr(byval v1 as Vector4, byval v2 as Vector4) as single
declare function Vector4Scale(byval v as Vector4, byval scale as single) as Vector4
'' Multiply vector by vector
declare function Vector4Multiply(byval v1 as Vector4, byval v2 as Vector4) as Vector4
'' Negate vector
declare function Vector4Negate(byval v as Vector4) as Vector4
'' Divide vector by vector
declare function Vector4Divide(byval v1 as Vector4, byval v2 as Vector4) as Vector4
'' Normalize provided vector
declare function Vector4Normalize(byval v as Vector4) as Vector4
'' Get min value for each pair of components
declare function Vector4Min(byval v1 as Vector4, byval v2 as Vector4) as Vector4
'' Get max value for each pair of components
declare function Vector4Max(byval v1 as Vector4, byval v2 as Vector4) as Vector4
'' Calculate linear interpolation between two vectors
declare function Vector4Lerp(byval v1 as Vector4, byval v2 as Vector4, byval amount as single) as Vector4
'' Move Vector towards target
declare function Vector4MoveTowards(byval v as Vector4, byval target as Vector4, byval maxDistance as single) as Vector4
'' Invert the given vector
declare function Vector4Invert(byval v as Vector4) as Vector4
'' Check whether two given vectors are almost equal
declare function Vector4Equals(byval p as Vector4, byval q as Vector4) as long

''----------------------------------------------------------------------------------
'' Module Functions Definition - Matrix math
''----------------------------------------------------------------------------------
'' Compute matrix determinant
declare function MatrixDeterminant(byval mat as Matrix) as single
'Get the trace of the matrix (sum of the values along the diagonal)
declare function MatrixTrace(byval mat as Matrix) as single
'' Transposes provided matrix
declare function MatrixTranspose(byval mat as Matrix) as Matrix
'' Invert provided matrix
declare function MatrixInvert(byval mat as Matrix) as Matrix
'' Get identity matrix
declare function MatrixIdentity() as Matrix
'' Add two matrices
declare function MatrixAdd(byval left_ as Matrix, byval right_ as Matrix) as Matrix
'' Subtract two matrices (left - right)
declare function MatrixSubtract(byval left_ as Matrix, byval right_ as Matrix) as Matrix
'' Get two matrix multiplication
'' NOTE: When multiplying matrices... the order matters!
declare function MatrixMultiply(byval left_ as Matrix, byval right_ as Matrix) as Matrix
'' Get translation matrix
declare function MatrixTranslate(byval x as single, byval y as single, byval z as single) as Matrix
'' Create rotation matrix from axis and angle
'' NOTE: Angle should be provided in radians
declare function MatrixRotate(byval axis as Vector3, byval angle as single) as Matrix
'' Get x-rotation matrix
'' NOTE: Angle must be provided in radians
declare function MatrixRotateX(byval angle as single) as Matrix
'' Get y-rotation matrix
'' NOTE: Angle must be provided in radians
declare function MatrixRotateY(byval angle as single) as Matrix
'' Get z-rotation matrix
'' NOTE: Angle must be provided in radians
declare function MatrixRotateZ(byval angle as single) as Matrix
'' Get xyz-rotation matrix
'' NOTE: Angle must be provided in radians
declare function MatrixRotateXYZ(byval angle as Vector3) as Matrix
'' Get zyx-rotation matrix
'' NOTE: Angle must be provided in radians
declare function MatrixRotateZYX(byval angle as Vector3) as Matrix
'' Get scaling matrix
declare function MatrixScale(byval x as single, byval y as single, byval z as single) as Matrix
''Get perspective projection matrix
declare function MatrixFrustum(byval left_ as double, byval right_ as double, byval bottom as double, byval top as double, byval near as double, byval far as double) as Matrix
'' Get perspective projection matrix
'' NOTE: Fovy angle must be provided in radians
declare function MatrixPerspective(byval fovy as double, byval aspect as double, byval near as double, byval far as double) as Matrix
'' Get orthographic projection matrix
declare function MatrixOrtho(byval left_ as double, byval right_ as double, byval bottom as double, byval top as double, byval near as double, byval far as double) as Matrix
'' Get camera look-at matrix (view matrix)
declare function MatrixLookAt(byval eye as Vector3, byval target as Vector3, byval up as Vector3) as Matrix
'' Get float array of matrix data
declare function MatrixToFloatV(byval mat as Matrix) as float16

''----------------------------------------------------------------------------------
'' Module Functions Definition - Quaternion math
''----------------------------------------------------------------------------------
'' Add two quaternions
declare function QuaternionAdd(byval q1 as Quaternion, byval q2 as Quaternion) as Quaternion
'' Add quaternion and float value
declare function QuaternionAddValue(byval q as Quaternion, byval add as single) as Quaternion
'' Subtract two quaternions
declare function QuaternionSubtract(byval q1 as Quaternion, byval q2 as Quaternion) as Quaternion
'' Subtract quaternion and float value
declare function QuaternionSubtractValue(byval q as Quaternion, byval sub_ as single) as Quaternion
'' Get identity quaternion
declare function QuaternionIdentity() as Quaternion
'' Computes the length of a quaternion
declare function QuaternionLength(byval q as Quaternion) as single
'' Normalize provided quaternion
declare function QuaternionNormalize(byval q as Quaternion) as Quaternion
''Invert provided quaternion
declare function QuaternionInvert(byval q as Quaternion) as Quaternion
'' Calculate two quaternion multiplication
declare function QuaternionMultiply(byval q1 as Quaternion, byval q2 as Quaternion) as Quaternion
'' Scale quaternion by float value
declare function QuaternionScale(byval q as Quaternion, byval mul as single) as Quaternion
'' Divide two quaternions
declare function QuaternionDivide(byval q1 as Quaternion, byval q2 as Quaternion) as Quaternion
'' Calculate linear interpolation between two quaternions
declare function QuaternionLerp(byval q1 as Quaternion, byval q2 as Quaternion, byval amount as single) as Quaternion
' Calculate slerp-optimized interpolation between two quaternions
declare function QuaternionNlerp(byval q1 as Quaternion, byval q2 as Quaternion, byval amount as single) as Quaternion
'' Calculates spherical linear interpolation between two quaternions
declare function QuaternionSlerp(byval q1 as Quaternion, byval q2 as Quaternion, byval amount as single) as Quaternion
'' Calculate quaternion cubic spline interpolation using Cubic Hermite Spline algorithm
'' as described in the GLTF 2.0 specification: https://registry.khronos.org/glTF/specs/2.0/glTF-2.0.html#interpolation-cubic
declare function QuaternionCubicHermiteSpline(byval q1 as Quaternion, byval outTangent1 as Quaternion, byval q2 as Quaternion, byval inTangent2 as Quaternion, byval t as single) as Quaternion
'' Calculate quaternion based on the rotation from one vector to another
declare function QuaternionFromVector3ToVector3(byval from as Vector3, byval to_ as Vector3) as Quaternion
'' Get a quaternion for a given rotation matrix
declare function QuaternionFromMatrix(byval mat as Matrix) as Quaternion
'' Get a matrix for a given quaternion
declare function QuaternionToMatrix(byval q as Quaternion) as Matrix
'' Get rotation quaternion for an angle and axis
'' NOTE: Angle must be provided in radians
declare function QuaternionFromAxisAngle(byval axis as Vector3, byval angle as single) as Quaternion
'' Get rotation quaternion for an angle and axis
'' NOTE: Angle must be provided in radians
declare sub QuaternionToAxisAngle(byval q as Quaternion, byval outAxis as Vector3 ptr, byval outAngle as single ptr)
'' Get the quaternion equivalent to Euler angles
'' NOTE: Rotation order is ZYX
declare function QuaternionFromEuler(byval pitch as single, byval yaw as single, byval roll as single) as Quaternion
'' Get the Euler angles equivalent to quaternion (roll, pitch, yaw)
'' NOTE: Angles are returned in a Vector3 struct in radians
declare function QuaternionToEuler(byval q as Quaternion) as Vector3
'' Transform a quaternion given a transformation matrix
declare function QuaternionTransform(byval q as Quaternion, byval mat as Matrix) as Quaternion
'' Check whether two given quaternions are almost equal
declare function QuaternionEquals(byval p as Quaternion, byval q as Quaternion) as long
'' Decompose a transformation matrix into its rotational, translational and scaling components
declare sub MatrixDecompose(byval mat as Matrix, byval translation as Vector3 ptr, byval rotation as Quaternion ptr, byval scale as Vector3 ptr)

end extern

'' Operator overloads
'' Matrix operators
operator + (lhs as Matrix, rhs as Matrix) as Matrix
    return MatrixAdd(lhs, rhs)
end operator

operator - (lhs as Matrix, rhs as Matrix) as Matrix
    return MatrixSubtract(lhs, rhs)
end operator

operator * (lhs as Matrix, rhs as Matrix) as Matrix
    return MatrixMultiply(lhs, rhs)
end operator

'' Quaternion operators
operator + (lhs as Quaternion,rhs as single) as Quaternion
    return QuaternionAddValue(lhs, rhs)
end operator

operator - (lhs as Quaternion, rhs as single) as Quaternion
    return QuaternionSubtractValue(lhs, rhs)
end operator

operator * (lhs as Quaternion, rhs as Matrix) as Quaternion
    return QuaternionTransform(lhs, rhs)
end operator

static as const Quaternion QuaternionZeros = Quaternion (0.0f, 0.0f, 0.0f, 0.0f)
static as const Quaternion QuaternionOnes  = Quaternion (1.0f, 1.0f, 1.0f, 1.0f)
static as const Quaternion QuaternionUnitX = Quaternion (0.0f, 0.0f, 0.0f, 1.0f)

'' Vector4 operators
operator + (lhs as Vector4, rhs as Vector4) as Vector4
    return Vector4Add(lhs, rhs)
end operator

operator - (lhs as Vector4, rhs as Vector4) as Vector4
    return Vector4Subtract(lhs, rhs)
end operator

operator * (lhs as Vector4, rhs as Single) as Vector4
    return Vector4Scale(lhs, rhs)
end operator

operator * (lhs as Vector4, rhs as Vector4) as Vector4
    return Vector4Multiply(lhs, rhs)
end operator

operator / (lhs as Vector4, rhs as Single) as Vector4
    return Vector4Scale(lhs, 1.0f / rhs)
end operator

operator / (lhs as Vector4, rhs as Vector4) as Vector4
    return Vector4Divide(lhs, rhs)
end operator

operator = (lhs as Vector4, rhs as Vector4) as boolean
    return iif(FloatEquals(lhs.x, rhs.x) = true and FloatEquals(lhs.y, rhs.y) = true and FloatEquals(lhs.z, rhs.z) = true and FloatEquals(lhs.w, rhs.w) = true, true, false)
end operator

operator <> (lhs as Vector4, rhs as Vector4) as boolean
    return iif(FloatEquals(lhs.x, rhs.x) = false or FloatEquals(lhs.y, rhs.y) = false or FloatEquals(lhs.z, rhs.z) = false or FloatEquals(lhs.w, rhs.w) = false, true, false)
end operator

static as const Vector4 Vector4Zeros = Vector4(0.0f, 0.0f, 0.0f, 0.0f)
static as const Vector4 Vector4Ones =  Vector4(1.0f, 1.0f, 1.0f, 1.0f)
static as const Vector4 Vector4UnitX = Vector4(1.0f, 0.0f, 0.0f, 0.0f)
static as const Vector4 Vector4UnitY = Vector4(0.0f, 1.0f, 0.0f, 0.0f)
static as const Vector4 Vector4UnitZ = Vector4(0.0f, 0.0f, 1.0f, 0.0f)
static as const Vector4 Vector4UnitW = Vector4(0.0f, 0.0f, 0.0f, 1.0f)

'' Vector3 operators
operator + (lhs as Vector3, rhs as Vector3) as Vector3
    return Vector3Add(lhs, rhs)
end operator

operator - (lhs as Vector3, rhs as Vector3) as Vector3
    return Vector3Subtract(lhs, rhs)
end operator

operator * (lhs as Vector3, rhs as single) as Vector3
    return Vector3Scale(lhs, rhs)
end operator

operator * (lhs as Vector3, rhs as Vector3) as Vector3
    return Vector3Multiply(lhs, rhs)
end operator

operator * (lhs as Vector3, rhs as Matrix) as Vector3
    return Vector3Transform(lhs, rhs)
end operator

operator / (lhs as Vector3, rhs as single) as Vector3
    return Vector3Scale(lhs, 1.0f / rhs)
end operator

operator / (lhs as Vector3, rhs as Vector3) as Vector3
    return Vector3Divide(lhs, rhs)
end operator

operator = (lhs as Vector3, rhs as Vector3) as boolean
    return iif(FloatEquals(lhs.x, rhs.x) = true and FloatEquals(lhs.y, rhs.y) = true and FloatEquals(lhs.z, rhs.z) = true, true, false)
end operator

operator <> (lhs as Vector3, rhs as Vector3) as boolean
    return iif(FloatEquals(lhs.x, rhs.x) = false or FloatEquals(lhs.y, rhs.y) = false or FloatEquals(lhs.z, rhs.z) = false, true, false)
end operator

'' Vector 2 operators
operator + (lhs as Vector2, rhs as Vector2) as Vector2
    return Vector2Add(lhs, rhs)
end operator

operator - (lhs as Vector2, rhs as Vector2) as Vector2
    return Vector2Subtract(lhs, rhs)
end operator

operator * (lhs as Vector2, rhs as single) as Vector2
    return Vector2Scale(lhs, rhs)
end operator

operator * (lhs as Vector2, rhs as Vector2) as Vector2
    return Vector2Multiply(lhs, rhs)
end operator

operator * (lhs as Vector2, rhs as Matrix) as Vector2
    return Vector2Transform(lhs, rhs)
end operator

operator / (lhs as Vector2, rhs as single) as Vector2
    return Vector2Scale(lhs, 1.0f / rhs)
end operator

operator / (lhs as Vector2, rhs as Vector2) as Vector2
    return Vector2Divide(lhs, rhs)
end operator

operator = (lhs as Vector2, rhs as Vector2) as boolean
    return iif(FloatEquals(lhs.x, rhs.x) = true and FloatEquals(lhs.y, rhs.y) = true, true, false)
end operator

operator <> (lhs as Vector2, rhs as Vector2) as boolean
    return iif(FloatEquals(lhs.x, rhs.x) = false or FloatEquals(lhs.y, rhs.y) = false, true, false)
end operator

static as const Vector2 Vector2Zeros = Vector2(0.0f, 0.0f)
static as const Vector2 Vector2Ones =  Vector2(1.0f, 1.0f)
static as const Vector2 Vector2UnitX = Vector2(1.0f, 0.0f)
static as const Vector2 Vector2UnitY = Vector2(0.0f, 1.0f)
