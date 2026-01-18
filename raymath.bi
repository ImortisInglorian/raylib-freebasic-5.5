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
#include once "crt/math.bi" '' Required for: sinf(), cosf(), tan(), atan2f(), sqrtf(), floor(), fminf(), fmaxf(), fabsf()

extern "C"

#define RAYMATH_H

''----------------------------------------------------------------------------------
'' Defines and Macros
''----------------------------------------------------------------------------------
#ifndef PI
	const PI = 3.14159265358979323846
#endif
#ifndef EPSILON
	const EPSILON = 0.000001f
#endif
#ifndef DEG2RAD
	const DEG2RAD = PI / 180.0f
#endif
#ifndef RAD2DEG
	const RAD2DEG = 180.0f / PI
#endif

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
    as single m0, m4, m8,  m12 '' Matrix first row (4 components)
    as single m1, m5, m9,  m13 '' Matrix second row (4 components)
    as single m2, m6, m10, m14 '' Matrix third row (4 components)
    as single m3, m7, m11, m15 '' Matrix fourth row (4 components)
    declare constructor()
    declare constructor(m0 as single, m4 as single, m8 as single, m12 as single, _
                        m1 as single, m5 as single, m9 as single, m13 as single, _
                        m2 as single, m6 as single, m10 as single, m14 as single, _
                        m3 as single, m7 as single, m11 as single, m15 as single)
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
    x as single
    y as single
    declare constructor()
    declare constructor(x as single, y as single)
end type

constructor Vector2(x as single, y as single)
    this.x = x
    this.y = y
end constructor
    
constructor Vector2()
end constructor

'' Vector3, 3 components
type Vector3
    x as single
    y as single
    z as single
    declare constructor()
    declare constructor(x as single, y as single, z as single)
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
    x as single
    y as single
    z as single
    w as single
    declare constructor()
    declare constructor(x as single, y as single, z as single, w as single)
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
    x as single
    y as single
    z as single
    w as single
    declare constructor()
    declare constructor(x as single, y as single, z as single, w as single)
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
	v(0 to 2) as single
end type

type float16
	v(0 to 15) as single
end type

''----------------------------------------------------------------------------------
'' Module Functions Definition - Utils math
''----------------------------------------------------------------------------------

'' Clamp float value
private function Clamp(byval value as single, byval min as single, byval max as single) as single
	dim result as single = iif(value < min, min, value)
	if result > max then
		result = max
	end if
	return result
end function

'' Calculate linear interpolation between two floats
private function Lerp(byval start as single, byval end_ as single, byval amount as single) as single
	dim result as single = start + (amount * (end_ - start))
	return result
end function

'' Normalize input value within input range
private function Normalize(byval value as single, byval start as single, byval end_ as single) as single
	dim result as single = (value - start) / (end_ - start)
	return result
end function

'' Remap input value within input range to output range
private function Remap(byval value as single, byval inputStart as single, byval inputEnd as single, byval outputStart as single, byval outputEnd as single) as single
	dim result as single = (((value - inputStart) / (inputEnd - inputStart)) * (outputEnd - outputStart)) + outputStart
	return result
end function

'' Wrap input value from min to max
private function Wrap(byval value as single, byval min as single, byval max as single) as single
	dim result as single = value - ((max - min) * floorf((value - min) / (max - min)))
	return result
end function

'' Check whether two given floats are almost equal
private function FloatEquals(byval x as single, byval y as single) as long
	dim result as long = -(fabsf(x - y) <= (0.000001f * fmaxf(1.0f, fmaxf(fabsf(x), fabsf(y)))))
	return result
end function

''----------------------------------------------------------------------------------
'' Module Functions Definition - Vector2 math
''----------------------------------------------------------------------------------

'' Vector with components value 0.0f
private function Vector2Zero() as Vector2
	dim result as Vector2 = Vector2(0.0f, 0.0f)
	return result
end function

'' Vector with components value 1.0f
private function Vector2One() as Vector2
	dim result as Vector2 = Vector2(1.0f, 1.0f)
	return result
end function

'' Add two vectors (v1 + v2)
private function Vector2Add(byval v1 as Vector2, byval v2 as Vector2) as Vector2
	dim result as Vector2 = Vector2(v1.x + v2.x, v1.y + v2.y)
	return result
end function

'' Add vector and float value
private function Vector2AddValue(byval v as Vector2, byval add as single) as Vector2
	dim result as Vector2 = Vector2(v.x + add, v.y + add)
	return result
end function

'' Subtract two vectors (v1 - v2)
private function Vector2Subtract(byval v1 as Vector2, byval v2 as Vector2) as Vector2
	dim result as Vector2 = Vector2(v1.x - v2.x, v1.y - v2.y)
	return result
end function

'' Subtract vector by float value
private function Vector2SubtractValue(byval v as Vector2, byval sub_ as single) as Vector2
	dim result as Vector2 = Vector2(v.x - sub_, v.y - sub_)
	return result
end function

'' Calculate vector length
private function Vector2Length(byval v as Vector2) as single
	dim result as single = sqrtf((v.x * v.x) + (v.y * v.y))
	return result
end function

'' Calculate vector square length
private function Vector2LengthSqr(byval v as Vector2) as single
	dim result as single = (v.x * v.x) + (v.y * v.y)
	return result
end function

'' Calculate two vectors dot product
private function Vector2DotProduct(byval v1 as Vector2, byval v2 as Vector2) as single
	dim result as single = (v1.x * v2.x) + (v1.y * v2.y)
	return result
end function

'' Calculate distance between two vectors
private function Vector2Distance(byval v1 as Vector2, byval v2 as Vector2) as single
	dim result as single = sqrtf(((v1.x - v2.x) * (v1.x - v2.x)) + ((v1.y - v2.y) * (v1.y - v2.y)))
	return result
end function

'' Calculate square distance between two vectors
private function Vector2DistanceSqr(byval v1 as Vector2, byval v2 as Vector2) as single
	dim result as single = ((v1.x - v2.x) * (v1.x - v2.x)) + ((v1.y - v2.y) * (v1.y - v2.y))
	return result
end function

'' Calculate angle between two vectors
'' NOTE: Angle is calculated from origin point (0, 0)
private function Vector2Angle(byval v1 as Vector2, byval v2 as Vector2) as single
	dim result as single = atan2f(v2.y, v2.x) - atan2f(v1.y, v1.x)
	return result
end function

'' Calculate angle defined by a two vectors line
'' NOTE: Parameters need to be normalized
'' Current implementation should be aligned with glm::angle
private function Vector2LineAngle(byval start as Vector2, byval end_ as Vector2) as single
    dim result as single = 0.0f
    '' TODO(10/9/2023): Currently angles move clockwise, determine if this is wanted behavior
    result = -atan2f(end_.y - start.y, end_.x - start.x)
    return result
end function

'' Scale vector (multiply by value)
private function Vector2Scale(byval v as Vector2, byval scale as single) as Vector2
	dim result as Vector2 = Vector2(v.x * scale, v.y * scale)
	return result
end function

'' Multiply vector by vector
private function Vector2Multiply(byval v1 as Vector2, byval v2 as Vector2) as Vector2
	dim result as Vector2 = Vector2(v1.x * v2.x, v1.y * v2.y)
	return result
end function

'' Negate vector
private function Vector2Negate(byval v as Vector2) as Vector2
	dim result as Vector2 = Vector2(-v.x, -v.y)
	return result
end function

'' Divide vector by vector
private function Vector2Divide(byval v1 as Vector2, byval v2 as Vector2) as Vector2
	dim result as Vector2 = Vector2(v1.x / v2.x, v1.y / v2.y)
	return result
end function

'' Normalize provided vector
private function Vector2Normalize(byval v as Vector2) as Vector2
	dim result as Vector2
	dim length as single = sqrtf((v.x * v.x) + (v.y * v.y))
	if length > 0 then
		dim ilength as single = 1.0f / length
		result.x = v.x * ilength
		result.y = v.y * ilength
	end if
	return result
end function

'' Transforms a Vector2 by a given Matrix
private function Vector2Transform(byval v as Vector2, byval mat as Matrix) as Vector2
	dim result as Vector2
	dim x as single = v.x
	dim y as single = v.y
	dim z as single = 0
	result.x = (((mat.m0 * x) + (mat.m4 * y)) + (mat.m8 * z)) + mat.m12
	result.y = (((mat.m1 * x) + (mat.m5 * y)) + (mat.m9 * z)) + mat.m13
	return result
end function

'' Calculate linear interpolation between two vectors
private function Vector2Lerp(byval v1 as Vector2, byval v2 as Vector2, byval amount as single) as Vector2
	dim result as Vector2
	result.x = v1.x + (amount * (v2.x - v1.x))
	result.y = v1.y + (amount * (v2.y - v1.y))
	return result
end function

'' Calculate reflected vector to normal
private function Vector2Reflect(byval v as Vector2, byval normal as Vector2) as Vector2
	dim result as Vector2
	dim dotProduct as single = (v.x * normal.x) + (v.y * normal.y) '' Dot product
	result.x = v.x - ((2.0f * normal.x) * dotProduct)
	result.y = v.y - ((2.0f * normal.y) * dotProduct)
	return result
end function

'' Get min value for each pair of components
private function Vector2Min(byval v1 as Vector2, byval v2 as Vector2) as Vector2
    dim result as Vector2 = Vector2(0.0f, 0.0f)
    result.x = fminf(v1.x, v2.x)
    result.y = fminf(v1.y, v2.y)
    return result
end function

'' Get max value for each pair of components
private function Vector2Max(byval v1 as Vector2, byval v2 as Vector2) as Vector2
    dim result as Vector2 = Vector2(0.0f, 0.0f)
    result.x = fmaxf(v1.x, v2.x)
    result.y = fmaxf(v1.y, v2.y)
    return result
end function

'' Rotate vector by angle
private function Vector2Rotate(byval v as Vector2, byval angle as single) as Vector2
	dim result as Vector2
	dim cosres as single = cosf(angle)
	dim sinres as single = sinf(angle)
	result.x = (v.x * cosres) - (v.y * sinres)
	result.y = (v.x * sinres) + (v.y * cosres)
	return result
end function

'' Move Vector towards target
private function Vector2MoveTowards(byval v as Vector2, byval target as Vector2, byval maxDistance as single) as Vector2
	dim result as Vector2
	dim dx as single = target.x - v.x
	dim dy as single = target.y - v.y
	dim value as single = (dx * dx) + (dy * dy)
	if (value = 0) orelse ((maxDistance >= 0) andalso (value <= (maxDistance * maxDistance))) then
		return target
	end if
	dim dist as single = sqrtf(value)
	result.x = v.x + ((dx / dist) * maxDistance)
	result.y = v.y + ((dy / dist) * maxDistance)
	return result
end function

'' Invert the given vector
private function Vector2Invert(byval v as Vector2) as Vector2
	dim result as Vector2 = Vector2(1.0f / v.x, 1.0f / v.y)
	return result
end function

'' Clamp the components of the vector between
'' min and max values specified by the given vectors
private function Vector2Clamp(byval v as Vector2, byval min as Vector2, byval max as Vector2) as Vector2
	dim result as Vector2
	result.x = fminf(max.x, fmaxf(min.x, v.x))
	result.y = fminf(max.y, fmaxf(min.y, v.y))
	return result
end function

'' Clamp the magnitude of the vector between two min and max values
private function Vector2ClampValue(byval v as Vector2, byval min as single, byval max as single) as Vector2
	dim result as Vector2 = v
	dim length as single = (v.x * v.x) + (v.y * v.y)
	if length > 0.0f then
		length = sqrtf(length)
		if length < min then
			dim scale as single = min / length
			result.x = v.x * scale
			result.y = v.y * scale
		elseif length > max then
			dim scale as single = max / length
			result.x = v.x * scale
			result.y = v.y * scale
		end if
	end if
	return result
end function

'' Check whether two given vectors are almost equal
private function Vector2Equals(byval p as Vector2, byval q as Vector2) as long
	dim result as long = -((fabsf(p.x - q.x) <= (0.000001f * fmaxf(1.0f, fmaxf(fabsf(p.x), fabsf(q.x))))) andalso (fabsf(p.y - q.y) <= (0.000001f * fmaxf(1.0f, fmaxf(fabsf(p.y), fabsf(q.y))))))
	return result
end function

'' Compute the direction of a refracted ray
'' v: normalized direction of the incoming ray
'' n: normalized normal vector of the interface of two optical media
'' r: ratio of the refractive index of the medium from where the ray comes
''    to the refractive index of the medium on the other side of the surface
private function Vector2Refract(byval v as Vector2, byval n as Vector2, byval r as single) as Vector2
    dim result as Vector2 = Vector2(0.0f, 0.0f)
    dim dot as single = v.x*n.x + v.y*n.y
    dim d as single = 1.0f - r*r*(1.0f - dot*dot)
    if d >= 0.0f then
        d = sqrtf(d)
        v.x = r*v.x - (r*dot + d)*n.x
        v.y = r*v.y - (r*dot + d)*n.y

        result = v
    end if
    return result
end function

''----------------------------------------------------------------------------------
'' Module Functions Definition - Vector3 math
''----------------------------------------------------------------------------------

'' Vector with components value 0.0f
private function Vector3Zero() as Vector3
	dim result as Vector3 = Vector3(0.0f, 0.0f, 0.0f)
	return result
end function

'' Vector with components value 1.0f
private function Vector3One() as Vector3
	dim result as Vector3 = Vector3(1.0f, 1.0f, 1.0f)
	return result
end function

'' Add two vectors
private function Vector3Add(byval v1 as Vector3, byval v2 as Vector3) as Vector3
	dim result as Vector3 = Vector3(v1.x + v2.x, v1.y + v2.y, v1.z + v2.z)
	return result
end function

'' Add vector and float value
private function Vector3AddValue(byval v as Vector3, byval add as single) as Vector3
	dim result as Vector3 = Vector3(v.x + add, v.y + add, v.z + add)
	return result
end function

'' Subtract two vectors
private function Vector3Subtract(byval v1 as Vector3, byval v2 as Vector3) as Vector3
	dim result as Vector3 = Vector3(v1.x - v2.x, v1.y - v2.y, v1.z - v2.z)
	return result
end function

'' Subtract vector by float value
private function Vector3SubtractValue(byval v as Vector3, byval sub_ as single) as Vector3
	dim result as Vector3 = Vector3(v.x - sub_, v.y - sub_, v.z - sub_)
	return result
end function

'' Multiply vector by scalar
private function Vector3Scale(byval v as Vector3, byval scalar as single) as Vector3
	dim result as Vector3 = Vector3(v.x * scalar, v.y * scalar, v.z * scalar)
	return result
end function

'' Multiply vector by vector
private function Vector3Multiply(byval v1 as Vector3, byval v2 as Vector3) as Vector3
	dim result as Vector3 = Vector3(v1.x * v2.x, v1.y * v2.y, v1.z * v2.z)
	return result
end function

'' Calculate two vectors cross product
private function Vector3CrossProduct(byval v1 as Vector3, byval v2 as Vector3) as Vector3
	dim result as Vector3 = Vector3((v1.y * v2.z) - (v1.z * v2.y), (v1.z * v2.x) - (v1.x * v2.z), (v1.x * v2.y) - (v1.y * v2.x))
	return result
end function

'' Calculate one vector perpendicular vector
private function Vector3Perpendicular(byval v as Vector3) as Vector3
	dim result as Vector3
	dim min as single = csng(fabs(v.x))
	dim cardinalAxis as Vector3 = Vector3(1.0f, 0.0f, 0.0f)
	if fabsf(v.y) < min then
		min = csng(fabs(v.y))
		dim tmp as Vector3 = Vector3(0.0f, 1.0f, 0.0f)
		cardinalAxis = tmp
	end if
	if fabsf(v.z) < min then
		dim tmp as Vector3 = Vector3(0.0f, 0.0f, 1.0f)
		cardinalAxis = tmp
	end if
	result.x = (v.y * cardinalAxis.z) - (v.z * cardinalAxis.y)
	result.y = (v.z * cardinalAxis.x) - (v.x * cardinalAxis.z)
	result.z = (v.x * cardinalAxis.y) - (v.y * cardinalAxis.x)
	return result
end function

'' Calculate vector length
private function Vector3Length(byval v as const Vector3) as single
	dim result as single = sqrtf(((v.x * v.x) + (v.y * v.y)) + (v.z * v.z))
	return result
end function

'' Calculate vector square length
private function Vector3LengthSqr(byval v as const Vector3) as single
	dim result as single = ((v.x * v.x) + (v.y * v.y)) + (v.z * v.z)
	return result
end function

'' Calculate two vectors dot product
private function Vector3DotProduct(byval v1 as Vector3, byval v2 as Vector3) as single
	dim result as single = ((v1.x * v2.x) + (v1.y * v2.y)) + (v1.z * v2.z)
	return result
end function

'' Calculate distance between two vectors
private function Vector3Distance(byval v1 as Vector3, byval v2 as Vector3) as single
	dim result as single = 0.0f
	dim dx as single = v2.x - v1.x
	dim dy as single = v2.y - v1.y
	dim dz as single = v2.z - v1.z
	result = sqrtf(((dx * dx) + (dy * dy)) + (dz * dz))
	return result
end function

'' Calculate square distance between two vectors
private function Vector3DistanceSqr(byval v1 as Vector3, byval v2 as Vector3) as single
	dim result as single = 0.0f
	dim dx as single = v2.x - v1.x
	dim dy as single = v2.y - v1.y
	dim dz as single = v2.z - v1.z
	result = ((dx * dx) + (dy * dy)) + (dz * dz)
	return result
end function

'' Calculate angle between two vectors
private function Vector3Angle(byval v1 as Vector3, byval v2 as Vector3) as single
	dim result as single = 0.0f
	dim cross as Vector3 = Vector3((v1.y * v2.z) - (v1.z * v2.y), (v1.z * v2.x) - (v1.x * v2.z), (v1.x * v2.y) - (v1.y * v2.x))
	dim len_ as single = sqrtf(((cross.x * cross.x) + (cross.y * cross.y)) + (cross.z * cross.z))
	dim dot as single = ((v1.x * v2.x) + (v1.y * v2.y)) + (v1.z * v2.z)
	result = atan2f(len_, dot)
	return result
end function

'' Negate provided vector (invert direction)
private function Vector3Negate(byval v as Vector3) as Vector3
	dim result as Vector3 = Vector3(-v.x, -v.y, -v.z)
	return result
end function

'' Divide vector by vector
private function Vector3Divide(byval v1 as Vector3, byval v2 as Vector3) as Vector3
	dim result as Vector3 = Vector3(v1.x / v2.x, v1.y / v2.y, v1.z / v2.z)
	return result
end function

'' Normalize provided vector
private function Vector3Normalize(byval v as Vector3) as Vector3
	dim result as Vector3 = v
	dim length as single = sqrtf(((v.x * v.x) + (v.y * v.y)) + (v.z * v.z))
	if length = 0.0f then
		length = 1.0f
	end if
	dim ilength as single = 1.0f / length
	result.x *= ilength
	result.y *= ilength
	result.z *= ilength
	return result
end function

'' Calculate the projection of the vector v1 on to v2
private function Vector3Project(byval v1 as Vector3, byval v2 as Vector3) as Vector3
    dim result as Vector3 = Vector3(0.0f, 0.0f, 0.0f)
    dim v1dv2 as single = (v1.x*v2.x + v1.y*v2.y + v1.z*v2.z)
    dim v2dv2 as single = (v2.x*v2.x + v2.y*v2.y + v2.z*v2.z)
    dim mag as single = v1dv2/v2dv2
    result.x = v2.x*mag
    result.y = v2.y*mag
    result.z = v2.z*mag
    return result
end function

'' Calculate the rejection of the vector v1 on to v2
private function Vector3Reject(byval v1 as Vector3, byval v2 as Vector3) as Vector3
    dim result as Vector3 = Vector3(0.0f, 0.0f, 0.0f)
    dim v1dv2 as Single = (v1.x*v2.x + v1.y*v2.y + v1.z*v2.z)
    dim v2dv2 as single = (v2.x*v2.x + v2.y*v2.y + v2.z*v2.z)
    dim mag as single = v1dv2/v2dv2
    result.x = v1.x - (v2.x*mag)
    result.y = v1.y - (v2.y*mag)
    result.z = v1.z - (v2.z*mag)
    return result
end function

'' Orthonormalize provided vectors
'' Makes vectors normalized and orthogonal to each other
'' Gram-Schmidt function implementation
private sub Vector3OrthoNormalize(byval v1 as Vector3 ptr, byval v2 as Vector3 ptr)
	dim length as single = 0.0f
	dim ilength as single = 0.0f
	'' Vector3Normalize(*v1);
	dim v as Vector3 = *v1
	length = sqrtf(((v.x * v.x) + (v.y * v.y)) + (v.z * v.z))
	if length = 0.0f then
		length = 1.0f
	end if
	ilength = 1.0f / length
	v1->x *= ilength
	v1->y *= ilength
	v1->z *= ilength
	'' Vector3CrossProduct(*v1, *v2)
	dim vn1 as Vector3 = Vector3((v1->y * v2->z) - (v1->z * v2->y), (v1->z * v2->x) - (v1->x * v2->z), (v1->x * v2->y) - (v1->y * v2->x))
	'' Vector3Normalize(vn1);
	v = vn1
	length = sqrtf(((v.x * v.x) + (v.y * v.y)) + (v.z * v.z))
	if length = 0.0f then
		length = 1.0f
	end if
	ilength = 1.0f / length
	vn1.x *= ilength
	vn1.y *= ilength
	vn1.z *= ilength
	'' Vector3CrossProduct(vn1, *v1)
	dim vn2 as Vector3 = Vector3((vn1.y * v1->z) - (vn1.z * v1->y), (vn1.z * v1->x) - (vn1.x * v1->z), (vn1.x * v1->y) - (vn1.y * v1->x))
	(*v2) = vn2
end sub

'' Transforms a Vector3 by a given Matrix
private function Vector3Transform(byval v as Vector3, byval mat as Matrix) as Vector3
	dim result as Vector3
	dim x as single = v.x
	dim y as single = v.y
	dim z as single = v.z
	result.x = (((mat.m0 * x) + (mat.m4 * y)) + (mat.m8 * z)) + mat.m12
	result.y = (((mat.m1 * x) + (mat.m5 * y)) + (mat.m9 * z)) + mat.m13
	result.z = (((mat.m2 * x) + (mat.m6 * y)) + (mat.m10 * z)) + mat.m14
	return result
end function

'' Transform a vector by quaternion rotation
private function Vector3RotateByQuaternion(byval v as Vector3, byval q as Quaternion) as Vector3
	dim result as Vector3
	result.x = ((v.x * ((((q.x * q.x) + (q.w * q.w)) - (q.y * q.y)) - (q.z * q.z))) + (v.y * (((2 * q.x) * q.y) - ((2 * q.w) * q.z)))) + (v.z * (((2 * q.x) * q.z) + ((2 * q.w) * q.y)))
	result.y = ((v.x * (((2 * q.w) * q.z) + ((2 * q.x) * q.y))) + (v.y * ((((q.w * q.w) - (q.x * q.x)) + (q.y * q.y)) - (q.z * q.z)))) + (v.z * ((((-2) * q.w) * q.x) + ((2 * q.y) * q.z)))
	result.z = ((v.x * ((((-2) * q.w) * q.y) + ((2 * q.x) * q.z))) + (v.y * (((2 * q.w) * q.x) + ((2 * q.y) * q.z)))) + (v.z * ((((q.w * q.w) - (q.x * q.x)) - (q.y * q.y)) + (q.z * q.z)))
	return result
end function

'' Rotates a vector around an axis
private function Vector3RotateByAxisAngle(byval v as Vector3, byval axis as Vector3, byval angle as single) as Vector3
	'' Using Euler-Rodrigues Formula
    '' Ref.: https://en.wikipedia.org/w/index.php?title=Euler%E2%80%93Rodrigues_formula
	dim result as Vector3 = v
	'' Vector3Normalize(axis)
	dim length as single = sqrtf(((axis.x * axis.x) + (axis.y * axis.y)) + (axis.z * axis.z))
	if length = 0.0f then
		length = 1.0f
	end if
	dim ilength as single = 1.0f / length
	axis.x *= ilength
	axis.y *= ilength
	axis.z *= ilength
	angle /= 2.0f
	dim a as single = sinf(angle)
	dim b as single = axis.x * a
	dim c as single = axis.y * a
	dim d as single = axis.z * a
	a = cosf(angle)
	dim w as Vector3 = Vector3(b, c, d)
	'' Vector3CrossProduct(w, v)
	dim wv as Vector3 = Vector3((w.y * v.z) - (w.z * v.y), (w.z * v.x) - (w.x * v.z), (w.x * v.y) - (w.y * v.x))
	'' Vector3CrossProduct(w, wv)
	dim wwv as Vector3 = Vector3((w.y * wv.z) - (w.z * wv.y), (w.z * wv.x) - (w.x * wv.z), (w.x * wv.y) - (w.y * wv.x))
	'' Vector3Scale(wv, 2*a)
	a *= 2
	wv.x *= a
	wv.y *= a
	wv.z *= a
	'' Vector3Scale(wwv, 2)
	wwv.x *= 2
	wwv.y *= 2
	wwv.z *= 2
	result.x += wv.x
	result.y += wv.y
	result.z += wv.z
	result.x += wwv.x
	result.y += wwv.y
	result.z += wwv.z
	return result
end function

'' Move Vector towards target
private function Vector3MoveTowards(byval v as Vector3, byval target as Vector3, byval maxDistance as single) as Vector3
    dim result as Vector3 = Vector3(0.0f, 0.0f, 0.0f)
    dim dx as single = target.x - v.x
    dim dy as single = target.y - v.y
    dim dz as single = target.z - v.z
    dim value as single = (dx*dx) + (dy*dy) + (dz*dz)
    if ((value = 0) or ((maxDistance >= 0) and (value <= maxDistance*maxDistance))) then return target
    dim dist as single = sqrtf(value)
    result.x = v.x + dx/dist*maxDistance
    result.y = v.y + dy/dist*maxDistance
    result.z = v.z + dz/dist*maxDistance
    return result
end function

'' Calculate linear interpolation between two vectors
private function Vector3Lerp(byval v1 as Vector3, byval v2 as Vector3, byval amount as single) as Vector3
	dim result as Vector3 = Vector3(0.0f, 0.0f, 0.0f)
	result.x = v1.x + (amount * (v2.x - v1.x))
	result.y = v1.y + (amount * (v2.y - v1.y))
	result.z = v1.z + (amount * (v2.z - v1.z))
	return result
end function

'' Calculate cubic hermite interpolation between two vectors and their tangents
'' as described in the GLTF 2.0 specification: https://registry.khronos.org/glTF/specs/2.0/glTF-2.0.html#interpolation-cubic
private function Vector3CubicHermite(byval v1 as Vector3, byval tangent1 as Vector3, byval v2 as Vector3, byval tangent2 as Vector3, byval amount as single) as Vector3
    dim result as Vector3 = Vector3(0.0f, 0.0f, 0.0f)
    dim amountPow2 as single = amount*amount
    dim amountPow3 as single = amount*amount*amount
    result.x = (2*amountPow3 - 3*amountPow2 + 1)*v1.x + (amountPow3 - 2*amountPow2 + amount)*tangent1.x + (-2*amountPow3 + 3*amountPow2)*v2.x + (amountPow3 - amountPow2)*tangent2.x
    result.y = (2*amountPow3 - 3*amountPow2 + 1)*v1.y + (amountPow3 - 2*amountPow2 + amount)*tangent1.y + (-2*amountPow3 + 3*amountPow2)*v2.y + (amountPow3 - amountPow2)*tangent2.y
    result.z = (2*amountPow3 - 3*amountPow2 + 1)*v1.z + (amountPow3 - 2*amountPow2 + amount)*tangent1.z + (-2*amountPow3 + 3*amountPow2)*v2.z + (amountPow3 - amountPow2)*tangent2.z
    return result
end function

'' Calculate reflected vector to normal
private function Vector3Reflect(byval v as Vector3, byval normal as Vector3) as Vector3
	dim result as Vector3 = Vector3(0.0f, 0.0f, 0.0f)

	'' I is the original vector
    '' N is the normal of the incident plane
    '' R = I - (2*N*(DotProduct[I, N]))

	dim dotProduct as single = ((v.x * normal.x) + (v.y * normal.y)) + (v.z * normal.z)
	result.x = v.x - ((2.0f * normal.x) * dotProduct)
	result.y = v.y - ((2.0f * normal.y) * dotProduct)
	result.z = v.z - ((2.0f * normal.z) * dotProduct)
	return result
end function

'' Get min value for each pair of components
private function Vector3Min(byval v1 as Vector3, byval v2 as Vector3) as Vector3
	dim result as Vector3 = Vector3(0.0f, 0.0f, 0.0f)
	result.x = fminf(v1.x, v2.x)
	result.y = fminf(v1.y, v2.y)
	result.z = fminf(v1.z, v2.z)
	return result
end function

'' Get max value for each pair of components
private function Vector3Max(byval v1 as Vector3, byval v2 as Vector3) as Vector3
	dim result as Vector3 = Vector3(0.0f, 0.0f, 0.0f)
	result.x = fmaxf(v1.x, v2.x)
	result.y = fmaxf(v1.y, v2.y)
	result.z = fmaxf(v1.z, v2.z)
	return result
end function

'' Compute barycenter coordinates (u, v, w) for point p with respect to triangle (a, b, c)
'' NOTE: Assumes P is on the plane of the triangle
private function Vector3Barycenter(byval p as Vector3, byval a as Vector3, byval b as Vector3, byval c as Vector3) as Vector3
	dim result as Vector3 = Vector3(0.0f, 0.0f, 0.0f)
	dim v0 as Vector3 = Vector3(b.x - a.x, b.y - a.y, b.z - a.z)		'' Vector3Subtract(b, a)
	dim v1 as Vector3 = Vector3(c.x - a.x, c.y - a.y, c.z - a.z) 		'' Vector3Subtract(c, a)
	dim v2 as Vector3 = Vector3(p.x - a.x, p.y - a.y, p.z - a.z) 		'' Vector3Subtract(p, a)
	dim d00 as single = ((v0.x * v0.x) + (v0.y * v0.y)) + (v0.z * v0.z)	'' Vector3DotProduct(v0, v0)
	dim d01 as single = ((v0.x * v1.x) + (v0.y * v1.y)) + (v0.z * v1.z)	'' Vector3DotProduct(v0, v1)
	dim d11 as single = ((v1.x * v1.x) + (v1.y * v1.y)) + (v1.z * v1.z)	'' Vector3DotProduct(v1, v1)
	dim d20 as single = ((v2.x * v0.x) + (v2.y * v0.y)) + (v2.z * v0.z)	'' Vector3DotProduct(v2, v0)
	dim d21 as single = ((v2.x * v1.x) + (v2.y * v1.y)) + (v2.z * v1.z)	'' Vector3DotProduct(v2, v1)
	dim denom as single = (d00 * d11) - (d01 * d01)
	result.y = ((d11 * d20) - (d01 * d21)) / denom
	result.z = ((d00 * d21) - (d01 * d20)) / denom
	result.x = 1.0f - (result.z + result.y)
	return result
end function

'' Projects a Vector3 from screen space into object space
'' NOTE: We are avoiding calling other raymath functions despite available
private function Vector3Unproject(byval source as Vector3, byval projection as Matrix, byval view_ as Matrix) as Vector3
	dim result as Vector3 = Vector3(0.0f, 0.0f, 0.0f)
	'' Calculate unprojected matrix (multiply view matrix by projection matrix) and invert it
	'' MatrixMultiply(view, projection);
	dim matViewProj as Matrix = Matrix(_
		(((view_.m0 * projection.m0) + (view_.m1 * projection.m4)) + (view_.m2 * projection.m8)) + (view_.m3 * projection.m12),_ 
		(((view_.m0 * projection.m1) + (view_.m1 * projection.m5)) + (view_.m2 * projection.m9)) + (view_.m3 * projection.m13),_
		(((view_.m0 * projection.m2) + (view_.m1 * projection.m6)) + (view_.m2 * projection.m10)) + (view_.m3 * projection.m14),_
		(((view_.m0 * projection.m3) + (view_.m1 * projection.m7)) + (view_.m2 * projection.m11)) + (view_.m3 * projection.m15),_
		(((view_.m4 * projection.m0) + (view_.m5 * projection.m4)) + (view_.m6 * projection.m8)) + (view_.m7 * projection.m12),_
		(((view_.m4 * projection.m1) + (view_.m5 * projection.m5)) + (view_.m6 * projection.m9)) + (view_.m7 * projection.m13),_
		(((view_.m4 * projection.m2) + (view_.m5 * projection.m6)) + (view_.m6 * projection.m10)) + (view_.m7 * projection.m14),_
		(((view_.m4 * projection.m3) + (view_.m5 * projection.m7)) + (view_.m6 * projection.m11)) + (view_.m7 * projection.m15),_
		(((view_.m8 * projection.m0) + (view_.m9 * projection.m4)) + (view_.m10 * projection.m8)) + (view_.m11 * projection.m12),_
		(((view_.m8 * projection.m1) + (view_.m9 * projection.m5)) + (view_.m10 * projection.m9)) + (view_.m11 * projection.m13),_
		(((view_.m8 * projection.m2) + (view_.m9 * projection.m6)) + (view_.m10 * projection.m10)) + (view_.m11 * projection.m14),_
		(((view_.m8 * projection.m3) + (view_.m9 * projection.m7)) + (view_.m10 * projection.m11)) + (view_.m11 * projection.m15),_
		(((view_.m12 * projection.m0) + (view_.m13 * projection.m4)) + (view_.m14 * projection.m8)) + (view_.m15 * projection.m12),_
		(((view_.m12 * projection.m1) + (view_.m13 * projection.m5)) + (view_.m14 * projection.m9)) + (view_.m15 * projection.m13),_
		(((view_.m12 * projection.m2) + (view_.m13 * projection.m6)) + (view_.m14 * projection.m10)) + (view_.m15 * projection.m14),_
		(((view_.m12 * projection.m3) + (view_.m13 * projection.m7)) + (view_.m14 * projection.m11)) + (view_.m15 * projection.m15))
	'' Calculate inverted matrix -> MatrixInvert(matViewProj);
    '' Cache the matrix values (speed optimization)
	dim a00 as single = matViewProj.m0
	dim a01 as single = matViewProj.m1
	dim a02 as single = matViewProj.m2
	dim a03 as single = matViewProj.m3
	dim a10 as single = matViewProj.m4
	dim a11 as single = matViewProj.m5
	dim a12 as single = matViewProj.m6
	dim a13 as single = matViewProj.m7
	dim a20 as single = matViewProj.m8
	dim a21 as single = matViewProj.m9
	dim a22 as single = matViewProj.m10
	dim a23 as single = matViewProj.m11
	dim a30 as single = matViewProj.m12
	dim a31 as single = matViewProj.m13
	dim a32 as single = matViewProj.m14
	dim a33 as single = matViewProj.m15
	dim b00 as single = (a00 * a11) - (a01 * a10)
	dim b01 as single = (a00 * a12) - (a02 * a10)
	dim b02 as single = (a00 * a13) - (a03 * a10)
	dim b03 as single = (a01 * a12) - (a02 * a11)
	dim b04 as single = (a01 * a13) - (a03 * a11)
	dim b05 as single = (a02 * a13) - (a03 * a12)
	dim b06 as single = (a20 * a31) - (a21 * a30)
	dim b07 as single = (a20 * a32) - (a22 * a30)
	dim b08 as single = (a20 * a33) - (a23 * a30)
	dim b09 as single = (a21 * a32) - (a22 * a31)
	dim b10 as single = (a21 * a33) - (a23 * a31)
	dim b11 as single = (a22 * a33) - (a23 * a32)
	'' Calculate the invert determinant (inlined to avoid double-caching)
	dim invDet as single = 1.0f / ((((((b00 * b11) - (b01 * b10)) + (b02 * b09)) + (b03 * b08)) - (b04 * b07)) + (b05 * b06))
	dim matViewProjInv as Matrix = Matrix(_
		(((a11 * b11) - (a12 * b10)) + (a13 * b09)) * invDet,_ 
		((((-a01) * b11) + (a02 * b10)) - (a03 * b09)) * invDet,_
		(((a31 * b05) - (a32 * b04)) + (a33 * b03)) * invDet,_
		((((-a21) * b05) + (a22 * b04)) - (a23 * b03)) * invDet,_
		((((-a10) * b11) + (a12 * b08)) - (a13 * b07)) * invDet,_ 
		(((a00 * b11) - (a02 * b08)) + (a03 * b07)) * invDet,_
		((((-a30) * b05) + (a32 * b02)) - (a33 * b01)) * invDet,_ 
		(((a20 * b05) - (a22 * b02)) + (a23 * b01)) * invDet,_ 
		(((a10 * b10) - (a11 * b08)) + (a13 * b06)) * invDet,_ 
		((((-a00) * b10) + (a01 * b08)) - (a03 * b06)) * invDet,_ 
		(((a30 * b04) - (a31 * b02)) + (a33 * b00)) * invDet,_ 
		((((-a20) * b04) + (a21 * b02)) - (a23 * b00)) * invDet,_ 
		((((-a10) * b09) + (a11 * b07)) - (a12 * b06)) * invDet,_ 
		(((a00 * b09) - (a01 * b07)) + (a02 * b06)) * invDet,_ 
		((((-a30) * b03) + (a31 * b01)) - (a32 * b00)) * invDet,_ 
		(((a20 * b03) - (a21 * b01)) + (a22 * b00)) * invDet)
	'' Create quaternion from source point
	dim quat as Quaternion = Quaternion(source.x, source.y, source.z, 1.0f)
	'' Multiply quat point by unprojecte matrix
	'' QuaternionTransform(quat, matViewProjInv)
	dim qtransformed as Quaternion = Quaternion((((matViewProjInv.m0 * quat.x) + (matViewProjInv.m4 * quat.y)) + (matViewProjInv.m8 * quat.z)) + (matViewProjInv.m12 * quat.w), (((matViewProjInv.m1 * quat.x) + (matViewProjInv.m5 * quat.y)) + (matViewProjInv.m9 * quat.z)) + (matViewProjInv.m13 * quat.w), (((matViewProjInv.m2 * quat.x) + (matViewProjInv.m6 * quat.y)) + (matViewProjInv.m10 * quat.z)) + (matViewProjInv.m14 * quat.w), (((matViewProjInv.m3 * quat.x) + (matViewProjInv.m7 * quat.y)) + (matViewProjInv.m11 * quat.z)) + (matViewProjInv.m15 * quat.w))
	'' Normalized world points in vectors
	result.x = qtransformed.x / qtransformed.w
	result.y = qtransformed.y / qtransformed.w
	result.z = qtransformed.z / qtransformed.w
	return result
end function

'' Get Vector3 as float array
private function Vector3ToFloatV(byval v as Vector3) as float3
	dim buffer as float3
	buffer.v(0) = v.x
	buffer.v(1) = v.y
	buffer.v(2) = v.z
	return buffer
end function

'' Invert the given vector
private function Vector3Invert(byval v as Vector3) as Vector3
	dim result as Vector3 = Vector3(1.0f / v.x, 1.0f / v.y, 1.0f / v.z)
	return result
end function

'' Clamp the components of the vector between
'' min and max values specified by the given vectors
private function Vector3Clamp(byval v as Vector3, byval min as Vector3, byval max as Vector3) as Vector3
	dim result as Vector3 = Vector3(0.0f, 0.0f, 0.0f)
	result.x = fminf(max.x, fmaxf(min.x, v.x))
	result.y = fminf(max.y, fmaxf(min.y, v.y))
	result.z = fminf(max.z, fmaxf(min.z, v.z))
	return result
end function

'' Clamp the magnitude of the vector between two values
private function Vector3ClampValue(byval v as Vector3, byval min as single, byval max as single) as Vector3
    dim result as Vector3 = Vector3(0.0f, 0.0f, 0.0f)
    dim length as single = (v.x*v.x) + (v.y*v.y) + (v.z*v.z)
    if (length > 0.0f) then
        length = sqrtf(length)
        dim scale as single = 1.0f    '' By default, 1 as the neutral element.
        if (length < min) then
            scale = min/length
        elseif (length > max) then
            scale = max/length
        end if
        result.x = v.x*scale
        result.y = v.y*scale
        result.z = v.z*scale
    end if
    return result
end function

'' Check whether two given vectors are almost equal
private function Vector3Equals(byval p as Vector3, byval q as Vector3) as long
	dim result as long = -(((fabsf(p.x - q.x) <= (0.000001f * fmaxf(1.0f, fmaxf(fabsf(p.x), fabsf(q.x))))) andalso (fabsf(p.y - q.y) <= (0.000001f * fmaxf(1.0f, fmaxf(fabsf(p.y), fabsf(q.y)))))) andalso (fabsf(p.z - q.z) <= (0.000001f * fmaxf(1.0f, fmaxf(fabsf(p.z), fabsf(q.z))))))
	return result
end function

'' Compute the direction of a refracted ray
'' v: normalized direction of the incoming ray
'' n: normalized normal vector of the interface of two optical media
'' r: ratio of the refractive index of the medium from where the ray comes
''    to the refractive index of the medium on the other side of the surface
private function Vector3Refract(byval v as Vector3, byval n as Vector3, byval r as single) as Vector3
	dim result as Vector3
	dim dot as single = ((v.x * n.x) + (v.y * n.y)) + (v.z * n.z)
	dim d as single = 1.0f - ((r * r) * (1.0f - (dot * dot)))
	if d >= 0.0f then
		d = sqrtf(d)
		v.x = (r * v.x) - (((r * dot) + d) * n.x)
		v.y = (r * v.y) - (((r * dot) + d) * n.y)
		v.z = (r * v.z) - (((r * dot) + d) * n.z)
		result = v
	end if
	return result
end function

''----------------------------------------------------------------------------------
'' Module Functions Definition - Vector4 math
''----------------------------------------------------------------------------------
private function Vector4Zero() as Vector4
    dim result as Vector4 = Vector4(0.0f, 0.0f, 0.0f, 0.0f)
    return result
end function

private function Vector4One() as Vector4
    dim result as Vector4 = Vector4(1.0f, 1.0f, 1.0f, 1.0f)
    return result
end function

private function Vector4Add(byval v1 as Vector4, byval v2 as Vector4) as Vector4
    dim result as Vector4 = Vector4(v1.x + v2.x, v1.y + v2.y, v1.z + v2.z, v1.w + v2.w)
    return result
end function

private function Vector4AddValue(byval v as Vector4, byval add as single) as Vector4
    dim result as Vector4 = Vector4(v.x + add, v.y + add, v.z + add, v.w + add)
    return result
end function

private function Vector4Subtract(byval v1 as Vector4, byval v2 as Vector4) as Vector4
    dim result as Vector4 = Vector4(v1.x - v2.x, v1.y - v2.y, v1.z - v2.z, v1.w - v2.w)
    return result
end function

private function Vector4SubtractValue(byval v as Vector4, byval add as single) as Vector4
    dim result as Vector4 = Vector4(v.x - add, v.y - add, v.z - add, v.w - add)
    return result
end function

private function Vector4Length(byval v as Vector4) as single
    dim result as single = sqrtf((v.x*v.x) + (v.y*v.y) + (v.z*v.z) + (v.w*v.w))
    return result
end function

private function Vector4LengthSqr(byval v as Vector4) as single
    dim result as single = (v.x*v.x) + (v.y*v.y) + (v.z*v.z) + (v.w*v.w)
    return result
end function

private function Vector4DotProduct(byval v1 as Vector4, byval v2 as Vector4) as single
    dim result as single = (v1.x*v2.x + v1.y*v2.y + v1.z*v2.z + v1.w*v2.w)
    return result
end function

'' Calculate distance between two vectors
private function Vector4Distance(byval v1 as Vector4, byval v2 as Vector4) as single
    dim result as single = sqrtf((v1.x - v2.x)*(v1.x - v2.x) + (v1.y - v2.y)*(v1.y - v2.y) +(v1.z - v2.z)*(v1.z - v2.z) + (v1.w - v2.w)*(v1.w - v2.w))
    return result
end function

'' Calculate square distance between two vectors
private function Vector4DistanceSqr(byval v1 as Vector4, byval v2 as Vector4) as single
    dim result as single = (v1.x - v2.x)*(v1.x - v2.x) + (v1.y - v2.y)*(v1.y - v2.y) + (v1.z - v2.z)*(v1.z - v2.z) + (v1.w - v2.w)*(v1.w - v2.w)
    return result
end function

private function Vector4Scale(byval v as Vector4, byval scale as single) as Vector4
    dim result as Vector4 = Vector4(v.x*scale, v.y*scale, v.z*scale, v.w*scale)
    return result
end function

'' Multiply vector by vector
private function Vector4Multiply(byval v1 as Vector4, byval v2 as Vector4) as Vector4
    dim result as Vector4 = Vector4(v1.x*v2.x, v1.y*v2.y, v1.z*v2.z, v1.w*v2.w)
    return result
end function

'' Negate vector
private function Vector4Negate(byval v as Vector4) as Vector4
    dim result as Vector4 = Vector4(-v.x, -v.y, -v.z, -v.w)
    return result
end function

'' Divide vector by vector
private function Vector4Divide(byval v1 as Vector4, byval v2 as Vector4) as Vector4
    dim result as Vector4 = Vector4(v1.x/v2.x, v1.y/v2.y, v1.z/v2.z, v1.w/v2.w)
    return result
end function

'' Normalize provided vector
private function Vector4Normalize(byval v as Vector4) as Vector4
    dim result as Vector4 = Vector4(0.0f, 0.0f, 0.0f, 0.0f)
    dim length as single = sqrtf((v.x*v.x) + (v.y*v.y) + (v.z*v.z) + (v.w*v.w))
    if length > 0 then
        dim ilength as single = 1.0f/length
        result.x = v.x*ilength
        result.y = v.y*ilength
        result.z = v.z*ilength
        result.w = v.w*ilength
    end if
    return result
end function

'' Get min value for each pair of components
private function Vector4Min(byval v1 as Vector4, byval v2 as Vector4) as Vector4
    dim result as Vector4 = Vector4(0.0f, 0.0f, 0.0f, 0.0f)
    result.x = fminf(v1.x, v2.x)
    result.y = fminf(v1.y, v2.y)
    result.z = fminf(v1.z, v2.z)
    result.w = fminf(v1.w, v2.w)
    return result
end function

'' Get max value for each pair of components
private function Vector4Max(byval v1 as Vector4, byval v2 as Vector4) as Vector4
    dim result as Vector4 = Vector4(0.0f, 0.0f, 0.0f, 0.0f)
    result.x = fmaxf(v1.x, v2.x)
    result.y = fmaxf(v1.y, v2.y)
    result.z = fmaxf(v1.z, v2.z)
    result.w = fmaxf(v1.w, v2.w)
    return result
end function

'' Calculate linear interpolation between two vectors
private function Vector4Lerp(byval v1 as Vector4, byval v2 as Vector4, byval amount as single) as Vector4
    dim result as Vector4 = Vector4(0.0f, 0.0f, 0.0f, 0.0f)
    result.x = v1.x + amount*(v2.x - v1.x)
    result.y = v1.y + amount*(v2.y - v1.y)
    result.z = v1.z + amount*(v2.z - v1.z)
    result.w = v1.w + amount*(v2.w - v1.w)
    return result
end function

'' Move Vector towards target
private function Vector4MoveTowards(byval v as Vector4, byval target as Vector4, byval maxDistance as single) as Vector4
    dim result as Vector4 = Vector4(0.0f, 0.0f, 0.0f, 0.0f)
    dim dx as single = target.x - v.x
    dim dy as single = target.y - v.y
    dim dz as single = target.z - v.z
    dim dw as single = target.w - v.w
    dim value as single = (dx*dx) + (dy*dy) + (dz*dz) + (dw*dw)
    if ((value = 0) or ((maxDistance >= 0) and (value <= maxDistance*maxDistance))) then return target
    dim dist as single = sqrtf(value)
    result.x = v.x + dx/dist*maxDistance
    result.y = v.y + dy/dist*maxDistance
    result.z = v.z + dz/dist*maxDistance
    result.w = v.w + dw/dist*maxDistance
    return result
end function

'' Invert the given vector
private function Vector4Invert(byval v as Vector4) as Vector4
    dim result as Vector4 = Vector4(1.0f/v.x, 1.0f/v.y, 1.0f/v.z, 1.0f/v.w)
    return result
end function

'' Check whether two given vectors are almost equal
private function Vector4Equals(byval p as Vector4, byval q as Vector4) as long
    dim result as long = ((fabsf(p.x - q.x)) <= (EPSILON*fmaxf(1.0f, fmaxf(fabsf(p.x), fabsf(q.x))))) and ((fabsf(p.y - q.y)) <= (EPSILON*fmaxf(1.0f, fmaxf(fabsf(p.y), fabsf(q.y))))) and ((fabsf(p.z - q.z)) <= (EPSILON*fmaxf(1.0f, fmaxf(fabsf(p.z), fabsf(q.z))))) and ((fabsf(p.w - q.w)) <= (EPSILON*fmaxf(1.0f, fmaxf(fabsf(p.w), fabsf(q.w)))))
    return result
end function

''----------------------------------------------------------------------------------
'' Module Functions Definition - Matrix math
''----------------------------------------------------------------------------------

'' Compute matrix determinant
private function MatrixDeterminant(byval mat as Matrix) as single
	dim result as single = 0.0f
	'' Cache the matrix values (speed optimization)
	dim a00 as single = mat.m0
	dim a01 as single = mat.m1
	dim a02 as single = mat.m2
	dim a03 as single = mat.m3
	dim a10 as single = mat.m4
	dim a11 as single = mat.m5
	dim a12 as single = mat.m6
	dim a13 as single = mat.m7
	dim a20 as single = mat.m8
	dim a21 as single = mat.m9
	dim a22 as single = mat.m10
	dim a23 as single = mat.m11
	dim a30 as single = mat.m12
	dim a31 as single = mat.m13
	dim a32 as single = mat.m14
	dim a33 as single = mat.m15
	result = (((((((((((((((((((((((((a30 * a21) * a12) * a03) - (((a20 * a31) * a12) * a03)) - (((a30 * a11) * a22) * a03)) + (((a10 * a31) * a22) * a03)) + (((a20 * a11) * a32) * a03)) - (((a10 * a21) * a32) * a03)) - (((a30 * a21) * a02) * a13)) + (((a20 * a31) * a02) * a13)) + (((a30 * a01) * a22) * a13)) - (((a00 * a31) * a22) * a13)) - (((a20 * a01) * a32) * a13)) + (((a00 * a21) * a32) * a13)) + (((a30 * a11) * a02) * a23)) - (((a10 * a31) * a02) * a23)) - (((a30 * a01) * a12) * a23)) + (((a00 * a31) * a12) * a23)) + (((a10 * a01) * a32) * a23)) - (((a00 * a11) * a32) * a23)) - (((a20 * a11) * a02) * a33)) + (((a10 * a21) * a02) * a33)) + (((a20 * a01) * a12) * a33)) - (((a00 * a21) * a12) * a33)) - (((a10 * a01) * a22) * a33)) + (((a00 * a11) * a22) * a33)
	return result
end function

''Get the trace of the matrix (sum of the values along the diagonal)
private function MatrixTrace(byval mat as Matrix) as single
	dim result as single = ((mat.m0 + mat.m5) + mat.m10) + mat.m15
	return result
end function

'' Transposes provided matrix
private function MatrixTranspose(byval mat as Matrix) as Matrix
	dim result as Matrix
	result.m0 = mat.m0
	result.m1 = mat.m4
	result.m2 = mat.m8
	result.m3 = mat.m12
	result.m4 = mat.m1
	result.m5 = mat.m5
	result.m6 = mat.m9
	result.m7 = mat.m13
	result.m8 = mat.m2
	result.m9 = mat.m6
	result.m10 = mat.m10
	result.m11 = mat.m14
	result.m12 = mat.m3
	result.m13 = mat.m7
	result.m14 = mat.m11
	result.m15 = mat.m15
	return result
end function

'' Invert provided matrix
private function MatrixInvert(byval mat as Matrix) as Matrix
	dim result as Matrix
	'' Cache the matrix values (speed optimization)
	dim a00 as single = mat.m0
	dim a01 as single = mat.m1
	dim a02 as single = mat.m2
	dim a03 as single = mat.m3
	dim a10 as single = mat.m4
	dim a11 as single = mat.m5
	dim a12 as single = mat.m6
	dim a13 as single = mat.m7
	dim a20 as single = mat.m8
	dim a21 as single = mat.m9
	dim a22 as single = mat.m10
	dim a23 as single = mat.m11
	dim a30 as single = mat.m12
	dim a31 as single = mat.m13
	dim a32 as single = mat.m14
	dim a33 as single = mat.m15
	dim b00 as single = (a00 * a11) - (a01 * a10)
	dim b01 as single = (a00 * a12) - (a02 * a10)
	dim b02 as single = (a00 * a13) - (a03 * a10)
	dim b03 as single = (a01 * a12) - (a02 * a11)
	dim b04 as single = (a01 * a13) - (a03 * a11)
	dim b05 as single = (a02 * a13) - (a03 * a12)
	dim b06 as single = (a20 * a31) - (a21 * a30)
	dim b07 as single = (a20 * a32) - (a22 * a30)
	dim b08 as single = (a20 * a33) - (a23 * a30)
	dim b09 as single = (a21 * a32) - (a22 * a31)
	dim b10 as single = (a21 * a33) - (a23 * a31)
	dim b11 as single = (a22 * a33) - (a23 * a32)
	'' Calculate the invert determinant (inlined to avoid double-caching)
	dim invDet as single = 1.0f / ((((((b00 * b11) - (b01 * b10)) + (b02 * b09)) + (b03 * b08)) - (b04 * b07)) + (b05 * b06))
	result.m0 = (((a11 * b11) - (a12 * b10)) + (a13 * b09)) * invDet
	result.m1 = ((((-a01) * b11) + (a02 * b10)) - (a03 * b09)) * invDet
	result.m2 = (((a31 * b05) - (a32 * b04)) + (a33 * b03)) * invDet
	result.m3 = ((((-a21) * b05) + (a22 * b04)) - (a23 * b03)) * invDet
	result.m4 = ((((-a10) * b11) + (a12 * b08)) - (a13 * b07)) * invDet
	result.m5 = (((a00 * b11) - (a02 * b08)) + (a03 * b07)) * invDet
	result.m6 = ((((-a30) * b05) + (a32 * b02)) - (a33 * b01)) * invDet
	result.m7 = (((a20 * b05) - (a22 * b02)) + (a23 * b01)) * invDet
	result.m8 = (((a10 * b10) - (a11 * b08)) + (a13 * b06)) * invDet
	result.m9 = ((((-a00) * b10) + (a01 * b08)) - (a03 * b06)) * invDet
	result.m10 = (((a30 * b04) - (a31 * b02)) + (a33 * b00)) * invDet
	result.m11 = ((((-a20) * b04) + (a21 * b02)) - (a23 * b00)) * invDet
	result.m12 = ((((-a10) * b09) + (a11 * b07)) - (a12 * b06)) * invDet
	result.m13 = (((a00 * b09) - (a01 * b07)) + (a02 * b06)) * invDet
	result.m14 = ((((-a30) * b03) + (a31 * b01)) - (a32 * b00)) * invDet
	result.m15 = (((a20 * b03) - (a21 * b01)) + (a22 * b00)) * invDet
	return result
end function

'' Get identity matrix
private function MatrixIdentity() as Matrix
	dim result as Matrix = Matrix(1.0f, 0.0f, 0.0f, 0.0f, 0.0f, 1.0f, 0.0f, 0.0f, 0.0f, 0.0f, 1.0f, 0.0f, 0.0f, 0.0f, 0.0f, 1.0f)
	return result
end function

'' Add two matrices
private function MatrixAdd(byval left_ as Matrix, byval right_ as Matrix) as Matrix
	dim result as Matrix
	result.m0 = left_.m0 + right_.m0
	result.m1 = left_.m1 + right_.m1
	result.m2 = left_.m2 + right_.m2
	result.m3 = left_.m3 + right_.m3
	result.m4 = left_.m4 + right_.m4
	result.m5 = left_.m5 + right_.m5
	result.m6 = left_.m6 + right_.m6
	result.m7 = left_.m7 + right_.m7
	result.m8 = left_.m8 + right_.m8
	result.m9 = left_.m9 + right_.m9
	result.m10 = left_.m10 + right_.m10
	result.m11 = left_.m11 + right_.m11
	result.m12 = left_.m12 + right_.m12
	result.m13 = left_.m13 + right_.m13
	result.m14 = left_.m14 + right_.m14
	result.m15 = left_.m15 + right_.m15
	return result
end function

'' Subtract two matrices (left - right)
private function MatrixSubtract(byval left_ as Matrix, byval right_ as Matrix) as Matrix
	dim result as Matrix
	result.m0 = left_.m0 - right_.m0
	result.m1 = left_.m1 - right_.m1
	result.m2 = left_.m2 - right_.m2
	result.m3 = left_.m3 - right_.m3
	result.m4 = left_.m4 - right_.m4
	result.m5 = left_.m5 - right_.m5
	result.m6 = left_.m6 - right_.m6
	result.m7 = left_.m7 - right_.m7
	result.m8 = left_.m8 - right_.m8
	result.m9 = left_.m9 - right_.m9
	result.m10 = left_.m10 - right_.m10
	result.m11 = left_.m11 - right_.m11
	result.m12 = left_.m12 - right_.m12
	result.m13 = left_.m13 - right_.m13
	result.m14 = left_.m14 - right_.m14
	result.m15 = left_.m15 - right_.m15
	return result
end function

'' Get two matrix multiplication
'' NOTE: When multiplying matrices... the order matters!
private function MatrixMultiply(byval left_ as Matrix, byval right_ as Matrix) as Matrix
	dim result as Matrix
	result.m0 = (((left_.m0 * right_.m0) + (left_.m1 * right_.m4)) + (left_.m2 * right_.m8)) + (left_.m3 * right_.m12)
	result.m1 = (((left_.m0 * right_.m1) + (left_.m1 * right_.m5)) + (left_.m2 * right_.m9)) + (left_.m3 * right_.m13)
	result.m2 = (((left_.m0 * right_.m2) + (left_.m1 * right_.m6)) + (left_.m2 * right_.m10)) + (left_.m3 * right_.m14)
	result.m3 = (((left_.m0 * right_.m3) + (left_.m1 * right_.m7)) + (left_.m2 * right_.m11)) + (left_.m3 * right_.m15)
	result.m4 = (((left_.m4 * right_.m0) + (left_.m5 * right_.m4)) + (left_.m6 * right_.m8)) + (left_.m7 * right_.m12)
	result.m5 = (((left_.m4 * right_.m1) + (left_.m5 * right_.m5)) + (left_.m6 * right_.m9)) + (left_.m7 * right_.m13)
	result.m6 = (((left_.m4 * right_.m2) + (left_.m5 * right_.m6)) + (left_.m6 * right_.m10)) + (left_.m7 * right_.m14)
	result.m7 = (((left_.m4 * right_.m3) + (left_.m5 * right_.m7)) + (left_.m6 * right_.m11)) + (left_.m7 * right_.m15)
	result.m8 = (((left_.m8 * right_.m0) + (left_.m9 * right_.m4)) + (left_.m10 * right_.m8)) + (left_.m11 * right_.m12)
	result.m9 = (((left_.m8 * right_.m1) + (left_.m9 * right_.m5)) + (left_.m10 * right_.m9)) + (left_.m11 * right_.m13)
	result.m10 = (((left_.m8 * right_.m2) + (left_.m9 * right_.m6)) + (left_.m10 * right_.m10)) + (left_.m11 * right_.m14)
	result.m11 = (((left_.m8 * right_.m3) + (left_.m9 * right_.m7)) + (left_.m10 * right_.m11)) + (left_.m11 * right_.m15)
	result.m12 = (((left_.m12 * right_.m0) + (left_.m13 * right_.m4)) + (left_.m14 * right_.m8)) + (left_.m15 * right_.m12)
	result.m13 = (((left_.m12 * right_.m1) + (left_.m13 * right_.m5)) + (left_.m14 * right_.m9)) + (left_.m15 * right_.m13)
	result.m14 = (((left_.m12 * right_.m2) + (left_.m13 * right_.m6)) + (left_.m14 * right_.m10)) + (left_.m15 * right_.m14)
	result.m15 = (((left_.m12 * right_.m3) + (left_.m13 * right_.m7)) + (left_.m14 * right_.m11)) + (left_.m15 * right_.m15)
	return result
end function

'' Get translation matrix
private function MatrixTranslate(byval x as single, byval y as single, byval z as single) as Matrix
	dim result as Matrix = Matrix(1.0f, 0.0f, 0.0f, x, 0.0f, 1.0f, 0.0f, y, 0.0f, 0.0f, 1.0f, z, 0.0f, 0.0f, 0.0f, 1.0f)
	return result
end function

'' Create rotation matrix from axis and angle
'' NOTE: Angle should be provided in radians
private function MatrixRotate(byval axis as Vector3, byval angle as single) as Matrix
	dim result as Matrix
	dim x as single = axis.x
	dim y as single = axis.y
	dim z as single = axis.z
	dim lengthSquared as single = ((x * x) + (y * y)) + (z * z)
	if (lengthSquared <> 1.0f) andalso (lengthSquared <> 0.0f) then
		dim ilength as single = 1.0f / sqrtf(lengthSquared)
		x *= ilength
		y *= ilength
		z *= ilength
	end if
	dim sinres as single = sinf(angle)
	dim cosres as single = cosf(angle)
	dim t as single = 1.0f - cosres
	result.m0 = ((x * x) * t) + cosres
	result.m1 = ((y * x) * t) + (z * sinres)
	result.m2 = ((z * x) * t) - (y * sinres)
	result.m3 = 0.0f
	result.m4 = ((x * y) * t) - (z * sinres)
	result.m5 = ((y * y) * t) + cosres
	result.m6 = ((z * y) * t) + (x * sinres)
	result.m7 = 0.0f
	result.m8 = ((x * z) * t) + (y * sinres)
	result.m9 = ((y * z) * t) - (x * sinres)
	result.m10 = ((z * z) * t) + cosres
	result.m11 = 0.0f
	result.m12 = 0.0f
	result.m13 = 0.0f
	result.m14 = 0.0f
	result.m15 = 1.0f
	return result
end function

'' Get x-rotation matrix
'' NOTE: Angle must be provided in radians
private function MatrixRotateX(byval angle as single) as Matrix
	dim result as Matrix = Matrix(1.0f, 0.0f, 0.0f, 0.0f, 0.0f, 1.0f, 0.0f, 0.0f, 0.0f, 0.0f, 1.0f, 0.0f, 0.0f, 0.0f, 0.0f, 1.0f)
	dim cosres as single = cosf(angle)
	dim sinres as single = sinf(angle)
	result.m5 = cosres
	result.m6 = sinres
	result.m9 = -sinres
	result.m10 = cosres
	return result
end function

'' Get y-rotation matrix
'' NOTE: Angle must be provided in radians
private function MatrixRotateY(byval angle as single) as Matrix
	dim result as Matrix = Matrix(1.0f, 0.0f, 0.0f, 0.0f, 0.0f, 1.0f, 0.0f, 0.0f, 0.0f, 0.0f, 1.0f, 0.0f, 0.0f, 0.0f, 0.0f, 1.0f)
	dim cosres as single = cosf(angle)
	dim sinres as single = sinf(angle)
	result.m0 = cosres
	result.m2 = -sinres
	result.m8 = sinres
	result.m10 = cosres
	return result
end function

'' Get z-rotation matrix
'' NOTE: Angle must be provided in radians
private function MatrixRotateZ(byval angle as single) as Matrix
	dim result as Matrix = Matrix(1.0f, 0.0f, 0.0f, 0.0f, 0.0f, 1.0f, 0.0f, 0.0f, 0.0f, 0.0f, 1.0f, 0.0f, 0.0f, 0.0f, 0.0f, 1.0f)
	dim cosres as single = cosf(angle)
	dim sinres as single = sinf(angle)
	result.m0 = cosres
	result.m1 = sinres
	result.m4 = -sinres
	result.m5 = cosres
	return result
end function

'' Get xyz-rotation matrix
'' NOTE: Angle must be provided in radians
private function MatrixRotateXYZ(byval angle as Vector3) as Matrix
	dim result as Matrix = Matrix(1.0f, 0.0f, 0.0f, 0.0f, 0.0f, 1.0f, 0.0f, 0.0f, 0.0f, 0.0f, 1.0f, 0.0f, 0.0f, 0.0f, 0.0f, 1.0f)
	dim cosz as single = cosf(-angle.z)
	dim sinz as single = sinf(-angle.z)
	dim cosy as single = cosf(-angle.y)
	dim siny as single = sinf(-angle.y)
	dim cosx as single = cosf(-angle.x)
	dim sinx as single = sinf(-angle.x)
	result.m0 = cosz * cosy
	result.m1 = ((cosz * siny) * sinx) - (sinz * cosx)
	result.m2 = ((cosz * siny) * cosx) + (sinz * sinx)
	result.m4 = sinz * cosy
	result.m5 = ((sinz * siny) * sinx) + (cosz * cosx)
	result.m6 = ((sinz * siny) * cosx) - (cosz * sinx)
	result.m8 = -siny
	result.m9 = cosy * sinx
	result.m10 = cosy * cosx
	return result
end function

'' Get zyx-rotation matrix
'' NOTE: Angle must be provided in radians
private function MatrixRotateZYX(byval angle as Vector3) as Matrix
	dim result as Matrix
	dim cz as single = cosf(angle.z)
	dim sz as single = sinf(angle.z)
	dim cy as single = cosf(angle.y)
	dim sy as single = sinf(angle.y)
	dim cx as single = cosf(angle.x)
	dim sx as single = sinf(angle.x)
	result.m0 = cz * cy
	result.m4 = ((cz * sy) * sx) - (cx * sz)
	result.m8 = (sz * sx) + ((cz * cx) * sy)
	result.m12 = 0
	result.m1 = cy * sz
	result.m5 = (cz * cx) + ((sz * sy) * sx)
	result.m9 = ((cx * sz) * sy) - (cz * sx)
	result.m13 = 0
	result.m2 = -sy
	result.m6 = cy * sx
	result.m10 = cy * cx
	result.m14 = 0
	result.m3 = 0
	result.m7 = 0
	result.m11 = 0
	result.m15 = 1
	return result
end function

'' Get scaling matrix
private function MatrixScale(byval x as single, byval y as single, byval z as single) as Matrix
	dim result as Matrix = Matrix(x, 0.0f, 0.0f, 0.0f, 0.0f, y, 0.0f, 0.0f, 0.0f, 0.0f, z, 0.0f, 0.0f, 0.0f, 0.0f, 1.0f)
	return result
end function

''Get perspective projection matrix
private function MatrixFrustum(byval left_ as double, byval right_ as double, byval bottom as double, byval top as double, byval near as double, byval far as double) as Matrix
	dim result as Matrix
	dim rl as single = csng(right_ - left_)
	dim tb as single = csng(top - bottom)
	dim fn as single = csng(far - near)
	result.m0 = (csng(near) * 2.0f) / rl
	result.m1 = 0.0f
	result.m2 = 0.0f
	result.m3 = 0.0f
	result.m4 = 0.0f
	result.m5 = (csng(near) * 2.0f) / tb
	result.m6 = 0.0f
	result.m7 = 0.0f
	result.m8 = (csng(right_) + csng(left_)) / rl
	result.m9 = (csng(top) + csng(bottom)) / tb
	result.m10 = (-(csng(far) + csng(near))) / fn
	result.m11 = -1.0f
	result.m12 = 0.0f
	result.m13 = 0.0f
	result.m14 = (-((csng(far) * csng(near)) * 2.0f)) / fn
	result.m15 = 0.0f
	return result
end function

'' Get perspective projection matrix
'' NOTE: Fovy angle must be provided in radians
private function MatrixPerspective(byval fovy as double, byval aspect as double, byval near as double, byval far as double) as Matrix
	dim result as Matrix
	dim top as double = near * tan(fovy * 0.5)
	dim bottom as double = -top
	dim right_ as double = top * aspect
	dim left_ as double = -right_
	'' MatrixFrustum(-right, right, -top, top, near, far)
	dim rl as single = csng(right_ - left_)
	dim tb as single = csng(top - bottom)
	dim fn as single = csng(far - near)
	result.m0 = (csng(near) * 2.0f) / rl
	result.m5 = (csng(near) * 2.0f) / tb
	result.m8 = (csng(right_) + csng(left_)) / rl
	result.m9 = (csng(top) + csng(bottom)) / tb
	result.m10 = (-(csng(far) + csng(near))) / fn
	result.m11 = -1.0f
	result.m14 = (-((csng(far) * csng(near)) * 2.0f)) / fn
	return result
end function

'' Get orthographic projection matrix
private function MatrixOrtho(byval left_ as double, byval right_ as double, byval bottom as double, byval top as double, byval near as double, byval far as double) as Matrix
	dim result as Matrix
	dim rl as single = csng(right_ - left_)
	dim tb as single = csng(top - bottom)
	dim fn as single = csng(far - near)
	result.m0 = 2.0f / rl
	result.m1 = 0.0f
	result.m2 = 0.0f
	result.m3 = 0.0f
	result.m4 = 0.0f
	result.m5 = 2.0f / tb
	result.m6 = 0.0f
	result.m7 = 0.0f
	result.m8 = 0.0f
	result.m9 = 0.0f
	result.m10 = (-2.0f) / fn
	result.m11 = 0.0f
	result.m12 = (-(csng(left_) + csng(right_))) / rl
	result.m13 = (-(csng(top) + csng(bottom))) / tb
	result.m14 = (-(csng(far) + csng(near))) / fn
	result.m15 = 1.0f
	return result
end function

'' Get camera look-at matrix (view matrix)
private function MatrixLookAt(byval eye as Vector3, byval target as Vector3, byval up as Vector3) as Matrix
	dim result as Matrix
	dim length as single = 0.0f
	dim ilength as single = 0.0f
	dim vz as Vector3 = Vector3(eye.x - target.x, eye.y - target.y, eye.z - target.z)
	dim v as Vector3 = vz
	length = sqrtf(((v.x * v.x) + (v.y * v.y)) + (v.z * v.z))
	if length = 0.0f then
		length = 1.0f
	end if
	ilength = 1.0f / length
	vz.x *= ilength
	vz.y *= ilength
	vz.z *= ilength
	dim vx as Vector3 = Vector3((up.y * vz.z) - (up.z * vz.y), (up.z * vz.x) - (up.x * vz.z), (up.x * vz.y) - (up.y * vz.x))
	v = vx
	length = sqrtf(((v.x * v.x) + (v.y * v.y)) + (v.z * v.z))
	if length = 0.0f then
		length = 1.0f
	end if
	ilength = 1.0f / length
	vx.x *= ilength
	vx.y *= ilength
	vx.z *= ilength
	dim vy as Vector3 = Vector3((vz.y * vx.z) - (vz.z * vx.y), (vz.z * vx.x) - (vz.x * vx.z), (vz.x * vx.y) - (vz.y * vx.x))
	result.m0 = vx.x
	result.m1 = vy.x
	result.m2 = vz.x
	result.m3 = 0.0f
	result.m4 = vx.y
	result.m5 = vy.y
	result.m6 = vz.y
	result.m7 = 0.0f
	result.m8 = vx.z
	result.m9 = vy.z
	result.m10 = vz.z
	result.m11 = 0.0f
	result.m12 = -(((vx.x * eye.x) + (vx.y * eye.y)) + (vx.z * eye.z))
	result.m13 = -(((vy.x * eye.x) + (vy.y * eye.y)) + (vy.z * eye.z))
	result.m14 = -(((vz.x * eye.x) + (vz.y * eye.y)) + (vz.z * eye.z))
	result.m15 = 1.0f
	return result
end function

'' Get float array of matrix data
private function MatrixToFloatV(byval mat as Matrix) as float16
	dim result as float16
	result.v(0) = mat.m0
	result.v(1) = mat.m1
	result.v(2) = mat.m2
	result.v(3) = mat.m3
	result.v(4) = mat.m4
	result.v(5) = mat.m5
	result.v(6) = mat.m6
	result.v(7) = mat.m7
	result.v(8) = mat.m8
	result.v(9) = mat.m9
	result.v(10) = mat.m10
	result.v(11) = mat.m11
	result.v(12) = mat.m12
	result.v(13) = mat.m13
	result.v(14) = mat.m14
	result.v(15) = mat.m15
	return result
end function

''----------------------------------------------------------------------------------
'' Module Functions Definition - Quaternion math
''----------------------------------------------------------------------------------

'' Add two quaternions
private function QuaternionAdd(byval q1 as Quaternion, byval q2 as Quaternion) as Quaternion
	dim result as Quaternion = Quaternion(q1.x + q2.x, q1.y + q2.y, q1.z + q2.z, q1.w + q2.w)
	return result
end function

'' Add quaternion and float value
private function QuaternionAddValue(byval q as Quaternion, byval add as single) as Quaternion
	dim result as Quaternion = Quaternion(q.x + add, q.y + add, q.z + add, q.w + add)
	return result
end function

'' Subtract two quaternions
private function QuaternionSubtract(byval q1 as Quaternion, byval q2 as Quaternion) as Quaternion
	dim result as Quaternion = Quaternion(q1.x - q2.x, q1.y - q2.y, q1.z - q2.z, q1.w - q2.w)
	return result
end function

'' Subtract quaternion and float value
private function QuaternionSubtractValue(byval q as Quaternion, byval sub_ as single) as Quaternion
	dim result as Quaternion = Quaternion(q.x - sub_, q.y - sub_, q.z - sub_, q.w - sub_)
	return result
end function

'' Get identity quaternion
private function QuaternionIdentity() as Quaternion
	dim result as Quaternion = Quaternion(0.0f, 0.0f, 0.0f, 1.0f)
	return result
end function

'' Computes the length of a quaternion
private function QuaternionLength(byval q as Quaternion) as single
	dim result as single = sqrtf((((q.x * q.x) + (q.y * q.y)) + (q.z * q.z)) + (q.w * q.w))
	return result
end function

'' Normalize provided quaternion
private function QuaternionNormalize(byval q as Quaternion) as Quaternion
	dim result as Quaternion
	dim length as single = sqrtf((((q.x * q.x) + (q.y * q.y)) + (q.z * q.z)) + (q.w * q.w))
	if length = 0.0f then
		length = 1.0f
	end if
	dim ilength as single = 1.0f / length
	result.x = q.x * ilength
	result.y = q.y * ilength
	result.z = q.z * ilength
	result.w = q.w * ilength
	return result
end function

''Invert provided quaternion
private function QuaternionInvert(byval q as Quaternion) as Quaternion
	dim result as Quaternion = q
	dim lengthSq as single = (((q.x * q.x) + (q.y * q.y)) + (q.z * q.z)) + (q.w * q.w)
	if lengthSq <> 0.0f then
		dim invLength as single = 1.0f / lengthSq
		result.x *= -invLength
		result.y *= -invLength
		result.z *= -invLength
		result.w *= invLength
	end if
	return result
end function

'' Calculate two quaternion multiplication
private function QuaternionMultiply(byval q1 as Quaternion, byval q2 as Quaternion) as Quaternion
	dim result as Quaternion
	dim qax as single = q1.x
	dim qay as single = q1.y
	dim qaz as single = q1.z
	dim qaw as single = q1.w
	dim qbx as single = q2.x
	dim qby as single = q2.y
	dim qbz as single = q2.z
	dim qbw as single = q2.w
	result.x = (((qax * qbw) + (qaw * qbx)) + (qay * qbz)) - (qaz * qby)
	result.y = (((qay * qbw) + (qaw * qby)) + (qaz * qbx)) - (qax * qbz)
	result.z = (((qaz * qbw) + (qaw * qbz)) + (qax * qby)) - (qay * qbx)
	result.w = (((qaw * qbw) - (qax * qbx)) - (qay * qby)) - (qaz * qbz)
	return result
end function

'' Scale quaternion by float value
private function QuaternionScale(byval q as Quaternion, byval mul as single) as Quaternion
	dim result as Quaternion
	result.x = q.x * mul
	result.y = q.y * mul
	result.z = q.z * mul
	result.w = q.w * mul
	return result
end function

'' Divide two quaternions
private function QuaternionDivide(byval q1 as Quaternion, byval q2 as Quaternion) as Quaternion
	dim result as Quaternion = Quaternion(q1.x / q2.x, q1.y / q2.y, q1.z / q2.z, q1.w / q2.w)
	return result
end function

'' Calculate linear interpolation between two quaternions
private function QuaternionLerp(byval q1 as Quaternion, byval q2 as Quaternion, byval amount as single) as Quaternion
	dim result as Quaternion
	result.x = q1.x + (amount * (q2.x - q1.x))
	result.y = q1.y + (amount * (q2.y - q1.y))
	result.z = q1.z + (amount * (q2.z - q1.z))
	result.w = q1.w + (amount * (q2.w - q1.w))
	return result
end function

'' Calculate slerp-optimized interpolation between two quaternions
private function QuaternionNlerp(byval q1 as Quaternion, byval q2 as Quaternion, byval amount as single) as Quaternion
	dim result as Quaternion
	result.x = q1.x + (amount * (q2.x - q1.x))
	result.y = q1.y + (amount * (q2.y - q1.y))
	result.z = q1.z + (amount * (q2.z - q1.z))
	result.w = q1.w + (amount * (q2.w - q1.w))
	dim q as Quaternion = result
	dim length as single = sqrtf((((q.x * q.x) + (q.y * q.y)) + (q.z * q.z)) + (q.w * q.w))
	if length = 0.0f then
		length = 1.0f
	end if
	dim ilength as single = 1.0f / length
	result.x = q.x * ilength
	result.y = q.y * ilength
	result.z = q.z * ilength
	result.w = q.w * ilength
	return result
end function

'' Calculates spherical linear interpolation between two quaternions
private function QuaternionSlerp(byval q1 as Quaternion, byval q2 as Quaternion, byval amount as single) as Quaternion
	dim result as Quaternion
	dim cosHalfTheta as single = (((q1.x * q2.x) + (q1.y * q2.y)) + (q1.z * q2.z)) + (q1.w * q2.w)
	if cosHalfTheta < 0 then
		q2.x = -q2.x
		q2.y = -q2.y
		q2.z = -q2.z
		q2.w = -q2.w
		cosHalfTheta = -cosHalfTheta
	end if
	if fabsf(cosHalfTheta) >= 1.0f then
		result = q1
	elseif cosHalfTheta > 0.95f then
		result = QuaternionNlerp(q1, q2, amount)
	else
		dim halfTheta as single = acosf(cosHalfTheta)
		dim sinHalfTheta as single = sqrtf(1.0f - (cosHalfTheta * cosHalfTheta))
		if fabsf(sinHalfTheta) < 0.001f then
			result.x = (q1.x * 0.5f) + (q2.x * 0.5f)
			result.y = (q1.y * 0.5f) + (q2.y * 0.5f)
			result.z = (q1.z * 0.5f) + (q2.z * 0.5f)
			result.w = (q1.w * 0.5f) + (q2.w * 0.5f)
		else
			dim ratioA as single = sinf((1 - amount) * halfTheta) / sinHalfTheta
			dim ratioB as single = sinf(amount * halfTheta) / sinHalfTheta
			result.x = (q1.x * ratioA) + (q2.x * ratioB)
			result.y = (q1.y * ratioA) + (q2.y * ratioB)
			result.z = (q1.z * ratioA) + (q2.z * ratioB)
			result.w = (q1.w * ratioA) + (q2.w * ratioB)
		end if
	end if
	return result
end function

'' Calculate quaternion cubic spline interpolation using Cubic Hermite Spline algorithm
'' as described in the GLTF 2.0 specification: https://registry.khronos.org/glTF/specs/2.0/glTF-2.0.html#interpolation-cubic
private function QuaternionCubicHermiteSpline(byval q1 as Quaternion, byval outTangent1 as Quaternion, byval q2 as Quaternion, byval inTangent2 as Quaternion, byval t as single) as Quaternion
    dim t2 as single = t*t
    dim t3 as single = t2*t
    dim h00 as single = 2*t3 - 3*t2 + 1
    dim h10 as single = t3 - 2*t2 + t
    dim h01 as single = -2*t3 + 3*t2
    dim h11 as single = t3 - t2

    dim p0 as Quaternion = QuaternionScale(q1, h00)
    dim m0 as Quaternion = QuaternionScale(outTangent1, h10)
    dim p1 as Quaternion = QuaternionScale(q2, h01)
    dim m1 as Quaternion = QuaternionScale(inTangent2, h11)

    dim result as Quaternion
    result = QuaternionAdd(p0, m0)
    result = QuaternionAdd(result, p1)
    result = QuaternionAdd(result, m1)
    result = QuaternionNormalize(result)
    return result
end function

'' Calculate quaternion based on the rotation from one vector to another
private function QuaternionFromVector3ToVector3(byval from as Vector3, byval to_ as Vector3) as Quaternion
	dim result as Quaternion
	dim cos2Theta as single = ((from.x * to_.x) + (from.y * to_.y)) + (from.z * to_.z)
	dim cross as Vector3 = Vector3((from.y * to_.z) - (from.z * to_.y), (from.z * to_.x) - (from.x * to_.z), (from.x * to_.y) - (from.y * to_.x))
	result.x = cross.x
	result.y = cross.y
	result.z = cross.z
	result.w = 1.0f + cos2Theta
	dim q as Quaternion = result
	dim length as single = sqrtf((((q.x * q.x) + (q.y * q.y)) + (q.z * q.z)) + (q.w * q.w))
	if length = 0.0f then
		length = 1.0f
	end if
	dim ilength as single = 1.0f / length
	result.x = q.x * ilength
	result.y = q.y * ilength
	result.z = q.z * ilength
	result.w = q.w * ilength
	return result
end function

'' Get a quaternion for a given rotation matrix
private function QuaternionFromMatrix(byval mat as Matrix) as Quaternion
	dim result as Quaternion
	dim fourWSquaredMinus1 as single = (mat.m0 + mat.m5) + mat.m10
	dim fourXSquaredMinus1 as single = (mat.m0 - mat.m5) - mat.m10
	dim fourYSquaredMinus1 as single = (mat.m5 - mat.m0) - mat.m10
	dim fourZSquaredMinus1 as single = (mat.m10 - mat.m0) - mat.m5
	dim biggestIndex as long = 0
	dim fourBiggestSquaredMinus1 as single = fourWSquaredMinus1
	if fourXSquaredMinus1 > fourBiggestSquaredMinus1 then
		fourBiggestSquaredMinus1 = fourXSquaredMinus1
		biggestIndex = 1
	end if
	if fourYSquaredMinus1 > fourBiggestSquaredMinus1 then
		fourBiggestSquaredMinus1 = fourYSquaredMinus1
		biggestIndex = 2
	end if
	if fourZSquaredMinus1 > fourBiggestSquaredMinus1 then
		fourBiggestSquaredMinus1 = fourZSquaredMinus1
		biggestIndex = 3
	end if
	dim biggestVal as single = sqrtf(fourBiggestSquaredMinus1 + 1.0f) * 0.5f
	dim mult as single = 0.25f / biggestVal
	'' TODO: switch (biggestIndex) { case 0: result.w = biggestVal; result.x = (mat.m6 - mat.m9) * mult; result.y = (mat.m8 - mat.m2) * mult; result.z = (mat.m1 - mat.m4) * mult; break; case 1: result.x = biggestVal; result.w = (mat.m6 - mat.m9) * mult; result.y = (mat.m1 + mat.m4) * mult; result.z = (mat.m8 + mat.m2) * mult; break; case 2: result.y = biggestVal; result.w = (mat.m8 - mat.m2) * mult; result.x = (mat.m1 + mat.m4) * mult; result.z = (mat.m6 + mat.m9) * mult; break; case 3: result.z = biggestVal; result.w = (mat.m1 - mat.m4) * mult; result.x = (mat.m8 + mat.m2) * mult; result.y = (mat.m6 + mat.m9) * mult; break; }
	return result
end function

'' Get a matrix for a given quaternion
private function QuaternionToMatrix(byval q as Quaternion) as Matrix
	dim result as Matrix = Matrix(1.0f, 0.0f, 0.0f, 0.0f, 0.0f, 1.0f, 0.0f, 0.0f, 0.0f, 0.0f, 1.0f, 0.0f, 0.0f, 0.0f, 0.0f, 1.0f)
	dim a2 as single = q.x * q.x
	dim b2 as single = q.y * q.y
	dim c2 as single = q.z * q.z
	dim ac as single = q.x * q.z
	dim ab as single = q.x * q.y
	dim bc as single = q.y * q.z
	dim ad as single = q.w * q.x
	dim bd as single = q.w * q.y
	dim cd as single = q.w * q.z
	result.m0 = 1 - (2 * (b2 + c2))
	result.m1 = 2 * (ab + cd)
	result.m2 = 2 * (ac - bd)
	result.m4 = 2 * (ab - cd)
	result.m5 = 1 - (2 * (a2 + c2))
	result.m6 = 2 * (bc + ad)
	result.m8 = 2 * (ac + bd)
	result.m9 = 2 * (bc - ad)
	result.m10 = 1 - (2 * (a2 + b2))
	return result
end function

'' Get rotation quaternion for an angle and axis
'' NOTE: Angle must be provided in radians
private function QuaternionFromAxisAngle(byval axis as Vector3, byval angle as single) as Quaternion
	dim result as Quaternion = Quaternion(0.0f, 0.0f, 0.0f, 1.0f)
	dim axisLength as single = sqrtf(((axis.x * axis.x) + (axis.y * axis.y)) + (axis.z * axis.z))
	if axisLength <> 0.0f then
		angle *= 0.5f
		dim length as single = 0.0f
		dim ilength as single = 0.0f
		dim v as Vector3 = axis
		length = sqrtf(((v.x * v.x) + (v.y * v.y)) + (v.z * v.z))
		if length = 0.0f then
			length = 1.0f
		end if
		ilength = 1.0f / length
		axis.x *= ilength
		axis.y *= ilength
		axis.z *= ilength
		dim sinres as single = sinf(angle)
		dim cosres as single = cosf(angle)
		result.x = axis.x * sinres
		result.y = axis.y * sinres
		result.z = axis.z * sinres
		result.w = cosres
		dim q as Quaternion = result
		length = sqrtf((((q.x * q.x) + (q.y * q.y)) + (q.z * q.z)) + (q.w * q.w))
		if length = 0.0f then
			length = 1.0f
		end if
		ilength = 1.0f / length
		result.x = q.x * ilength
		result.y = q.y * ilength
		result.z = q.z * ilength
		result.w = q.w * ilength
	end if
	return result
end function

'' Get rotation quaternion for an angle and axis
'' NOTE: Angle must be provided in radians
private sub QuaternionToAxisAngle(byval q as Quaternion, byval outAxis as Vector3 ptr, byval outAngle as single ptr)
	if fabsf(q.w) > 1.0f then
		dim length as single = sqrtf((((q.x * q.x) + (q.y * q.y)) + (q.z * q.z)) + (q.w * q.w))
		if length = 0.0f then
			length = 1.0f
		end if
		dim ilength as single = 1.0f / length
		q.x = q.x * ilength
		q.y = q.y * ilength
		q.z = q.z * ilength
		q.w = q.w * ilength
	end if
	dim resAxis as Vector3 = Vector3(0.0f, 0.0f, 0.0f)
	dim resAngle as single = 2.0f * acosf(q.w)
	dim den as single = sqrtf(1.0f - (q.w * q.w))
	if den > 0.0001f then
		resAxis.x = q.x / den
		resAxis.y = q.y / den
		resAxis.z = q.z / den
	else
		resAxis.x = 1.0f
	end if
	(*outAxis) = resAxis
	(*outAngle) = resAngle
end sub

'' Get the quaternion equivalent to Euler angles
'' NOTE: Rotation order is ZYX
private function QuaternionFromEuler(byval pitch as single, byval yaw as single, byval roll as single) as Quaternion
	dim result as Quaternion
	dim x0 as single = cosf(pitch * 0.5f)
	dim x1 as single = sinf(pitch * 0.5f)
	dim y0 as single = cosf(yaw * 0.5f)
	dim y1 as single = sinf(yaw * 0.5f)
	dim z0 as single = cosf(roll * 0.5f)
	dim z1 as single = sinf(roll * 0.5f)
	result.x = ((x1 * y0) * z0) - ((x0 * y1) * z1)
	result.y = ((x0 * y1) * z0) + ((x1 * y0) * z1)
	result.z = ((x0 * y0) * z1) - ((x1 * y1) * z0)
	result.w = ((x0 * y0) * z0) + ((x1 * y1) * z1)
	return result
end function

'' Get the Euler angles equivalent to quaternion (roll, pitch, yaw)
'' NOTE: Angles are returned in a Vector3 struct in radians
private function QuaternionToEuler(byval q as Quaternion) as Vector3
	dim result as Vector3
	dim x0 as single = 2.0f * ((q.w * q.x) + (q.y * q.z))
	dim x1 as single = 1.0f - (2.0f * ((q.x * q.x) + (q.y * q.y)))
	result.x = atan2f(x0, x1)
	dim y0 as single = 2.0f * ((q.w * q.y) - (q.z * q.x))
	y0 = iif(y0 > 1.0f, 1.0f, y0)
	y0 = iif(y0 < (-1.0f), -1.0f, y0)
	result.y = asinf(y0)
	dim z0 as single = 2.0f * ((q.w * q.z) + (q.x * q.y))
	dim z1 as single = 1.0f - (2.0f * ((q.y * q.y) + (q.z * q.z)))
	result.z = atan2f(z0, z1)
	return result
end function

'' Transform a quaternion given a transformation matrix
private function QuaternionTransform(byval q as Quaternion, byval mat as Matrix) as Quaternion
	dim result as Quaternion
	result.x = (((mat.m0 * q.x) + (mat.m4 * q.y)) + (mat.m8 * q.z)) + (mat.m12 * q.w)
	result.y = (((mat.m1 * q.x) + (mat.m5 * q.y)) + (mat.m9 * q.z)) + (mat.m13 * q.w)
	result.z = (((mat.m2 * q.x) + (mat.m6 * q.y)) + (mat.m10 * q.z)) + (mat.m14 * q.w)
	result.w = (((mat.m3 * q.x) + (mat.m7 * q.y)) + (mat.m11 * q.z)) + (mat.m15 * q.w)
	return result
end function

'' Check whether two given quaternions are almost equal
private function QuaternionEquals(byval p as Quaternion, byval q as Quaternion) as long
	dim result as long = -(((((fabsf(p.x - q.x) <= (0.000001f * fmaxf(1.0f, fmaxf(fabsf(p.x), fabsf(q.x))))) andalso (fabsf(p.y - q.y) <= (0.000001f * fmaxf(1.0f, fmaxf(fabsf(p.y), fabsf(q.y)))))) andalso (fabsf(p.z - q.z) <= (0.000001f * fmaxf(1.0f, fmaxf(fabsf(p.z), fabsf(q.z)))))) andalso (fabsf(p.w - q.w) <= (0.000001f * fmaxf(1.0f, fmaxf(fabsf(p.w), fabsf(q.w)))))) orelse ((((fabsf(p.x + q.x) <= (0.000001f * fmaxf(1.0f, fmaxf(fabsf(p.x), fabsf(q.x))))) andalso (fabsf(p.y + q.y) <= (0.000001f * fmaxf(1.0f, fmaxf(fabsf(p.y), fabsf(q.y)))))) andalso (fabsf(p.z + q.z) <= (0.000001f * fmaxf(1.0f, fmaxf(fabsf(p.z), fabsf(q.z)))))) andalso (fabsf(p.w + q.w) <= (0.000001f * fmaxf(1.0f, fmaxf(fabsf(p.w), fabsf(q.w)))))))
	return result
end function

'' Decompose a transformation matrix into its rotational, translational and scaling components
private sub MatrixDecompose(byval mat as Matrix, byval translation as Vector3 ptr, byval rotation as Quaternion ptr, byval scale as Vector3 ptr)
    '' Extract translation.
    translation->x = mat.m12
    translation->y = mat.m13
    translation->z = mat.m14
    '' Extract upper-left for determinant computation
    dim a as single = mat.m0
    dim b as single = mat.m4
    dim c as single = mat.m8
    dim d as single = mat.m1
    dim e as single = mat.m5
    dim f as single = mat.m9
    dim g as single = mat.m2
    dim h as single = mat.m6
    dim i as single = mat.m10
    dim A_ as single = e*i - f*h
    dim B_ as single = f*g - d*i
    dim C_ as single = d*h - e*g

    '' Extract scale
    dim det as single = a*A_ + b*B_ + c*C_
    dim abc as Vector3 = Vector3(a, b, c)
    dim def as Vector3 = Vector3(d, e, f)
    dim ghi as Vector3 = Vector3(g, h, i)

    dim scalex as single = Vector3Length(abc)
    dim scaley as single = Vector3Length(def)
    dim scalez as single = Vector3Length(ghi)
    dim s as Vector3 = Vector3(scalex, scaley, scalez)

    if det < 0 then s = Vector3Negate(s)

    *scale = s

    '' Remove scale from the matrix if it is not close to zero
    dim clone as Matrix = mat
    if FloatEquals(det, 0) = false then
        clone.m0 /= s.x
        clone.m4 /= s.x
        clone.m8 /= s.x
        clone.m1 /= s.y
        clone.m5 /= s.y
        clone.m9 /= s.y
        clone.m2 /= s.z
        clone.m6 /= s.z
        clone.m10 /= s.z
        '' Extract rotation
        *rotation = QuaternionFromMatrix(clone)
    else
        '' Set to identity if close to zero
        *rotation = QuaternionIdentity()
    end if
end sub

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
