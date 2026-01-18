/'******************************************************************************************
*
*   reasings - raylib easings library, based on Robert Penner library
*
*   Useful easing functions for values animation
*
*   This header uses:
*       #define REASINGS_STATIC_INLINE      // Inlines all functions code, so it runs faster.
*                                           // This requires lots of memory on system.
*   How to use:
*   The four inputs t,b,c,d are defined as follows:
*   t = current time (in any unit measure, but same unit as duration)
*   b = starting value to interpolate
*   c = the total change in value of b that needs to occur
*   d = total time it should take to complete (duration)
*
*   Example:
*
*   int currentTime = 0;
*   int duration = 100;
*   float startPositionX = 0.0f;
*   float finalPositionX = 30.0f;
*   float currentPositionX = startPositionX;
*
*   while (currentPositionX < finalPositionX)
*   {
*       currentPositionX = EaseSineIn(currentTime, startPositionX, finalPositionX - startPositionX, duration);
*       currentTime++;
*   }
*
*   A port of Robert Penner's easing equations to C (http://robertpenner.com/easing/)
*
*   Robert Penner License
*   ---------------------------------------------------------------------------------
*   Open source under the BSD License.
*
*   Copyright (c) 2001 Robert Penner. All rights reserved.
*
*   Redistribution and use in source and binary forms, with or without modification,
*   are permitted provided that the following conditions are met:
*
*       - Redistributions of source code must retain the above copyright notice,
*         this list of conditions and the following disclaimer.
*       - Redistributions in binary form must reproduce the above copyright notice,
*         this list of conditions and the following disclaimer in the documentation
*         and/or other materials provided with the distribution.
*       - Neither the name of the author nor the names of contributors may be used
*         to endorse or promote products derived from this software without specific
*         prior written permission.
*
*   THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
*   ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
*   WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED.
*   IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT,
*   INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING,
*   BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE,
*   DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF
*   LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE
*   OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED
*   OF THE POSSIBILITY OF SUCH DAMAGE.
*   ---------------------------------------------------------------------------------
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

#ifndef REASINGS_H
#define REASINGS_H


#include "crt/math.bi"       '' Required for: sinf(), cosf(), sqrtf(), powf()

'' Linear Easing functions

function EaseLinearNone(t as single, b as single, c as single, d as single) as single '' Ease: Linear
    return c * t / d + b
end function

function EaseLinearIn(t as single, b as single, c as single, d as single) as single '' Ease: Linear In
    return c * t / d + b
end function

function EaseLinearOut(t as single, b as single, c as single, d as single) as single '' Ease: Linear Out
    return c * t / d + b
end function

function EaseLinearInOut(t as single, b as single, c as single, d as single) as single ''Ease: Linear In Out
    return c * t / d + b
end function

'' Sine Easing functions
function EaseSineIn(t as single, b as single, c as single, d as single) as single '' Ease: Sine In
    return -c * cosf(t / d * (PI / 2.0f)) + c + b
end function

function EaseSineOut(t as single, b as single, c as single, d as single) as single '' Ease: Sine Out
    return c * sinf(t / d * (PI / 2.0f)) + b
end function

function EaseSineInOut(t as single, b as single, c as single, d as single) as single '' Ease: Sine In Out
    return -c / 2.0f * (cosf(PI * t / d) - 1.0f) + b
end function

'' Circular Easing functions
function EaseCircIn(byval t as single, b as single, c as single, d as single) as single '' Ease: Circular In
    t /= d
    return -c * (sqrtf(1.0f - t * t) - 1.0f) + b
end function

function EaseCircOut(byval t as single, b as single, c as single, d as single) as single '' Ease: Circular Out
    t = t / d - 1.0f
    return c * sqrtf(1.0f - t * t) + b
end function

function EaseCircInOut(byval t as single, b as single, c as single, d as single) as single '' Ease: Circular In Out
    t /= d
    if t / 2.0f < 1.0f then return -c / 2.0f * (sqrtf(1.0f - t * t) - 1.0f) + b
    t -= 2.0f
    return c / 2.0f * (sqrtf(1.0f - t * t) + 1.0f) + b
end function

'' Cubic Easing functions
function EaseCubicIn(byval t as single, b as single, c as single, d as single) as single '' Ease: Cubic In
    t /= d
    return c * t * t * t + b
end function

function EaseCubicOut(byval t as single, b as single, c as single, d as single) as single '' Ease: Cubic Out
    t = t / d - 1.0f
    return c * (t * t * t + 1.0f) + b
end function

function EaseCubicInOut(byval t as single, b as single, c as single, d as single) as single '' Ease: Cubic In Out
    t /= d
    if t / 2.0f < 1.0f then return c / 2.0f * t * t * t + b
    t -= 2.0f
    return c / 2.0f * (t * t * t + 2.0f) + b
end function

'' Quadratic Easing functions
function EaseQuadIn(byval t as single, b as single, c as single, d as single) as single '' Ease: Quadratic In
    t /= d
    return c * t * t + b
end function

function EaseQuadOut(byval t as single, b as single, c as single, d as single) as single '' Ease: Quadratic Out
    t /= d
    return -c * t * (t - 2.0f) + b
end function

function EaseQuadInOut(byval t as single, b as single, c as single, d as single) as single '' Ease: Quadratic In Out
    t /= d
    if t / 2 < 1 then return ((c / 2) * (t * t)) + b
    return -c / 2.0f * (((t - 1.0f) * (t - 3.0f)) - 1.0f) + b
end function

'' Exponential Easing functions
function EaseExpoIn(t as single, b as single, c as single, d as single) as single '' Ease: Exponential In
    return iif(t = 0.0f, b, c * powf(2.0f, 10.0f * (t / d - 1.0f)) + b)
end function

function EaseExpoOut(t as single, b as single, c as single, d as single) as single '' Ease: Exponential Out
    return iif(t = d, b + c, c * (-powf(2.0f, -10.0f * t / d) + 1.0f) + b)
end function

function EaseExpoInOut(byval t as single, b as single, c as single, d as single) as single '' Ease: Exponential In Out
    if t = 0.0f then return b
    if t = d then return b + c
    t /= d
    if t / 2.0f < 1.0f then return c / 2.0f * powf(2.0f, 10.0f * (t - 1.0f)) + b

    return c / 2.0f * (-powf(2.0f, -10.0f * (t - 1.0f)) + 2.0f) + b
end function

'' Back Easing functions
function EaseBackIn(byval t as single, b as single, c as single, d as single) as single '' Ease: Back In
    dim as single s = 1.70158f
    t /= d
    dim as single postFix = t
    return c * postFix * t * ((s + 1.0f) * t - s) + b
end function

function EaseBackOut(byval t as single, b as single, c as single, d as single) as single '' Ease: Back Out
    dim as single s = 1.70158f
    t = t / d - 1.0f
    return c * (t * t * ((s + 1.0f) * t + s) + 1.0f) + b
end function

function EaseBackInOut(byval t as single, b as single, c as single, d as single) as single '' Ease: Back In Out
    dim as single s = 1.70158f
    t /= d
    if t / 2.0f < 1.0f then
        s *= 1.525f
        return c / 2.0f * (t * t * ((s + 1.0f) * t - s)) + b
    end if

    t -= 2.0f
    dim as single postFix = t
    s *= 1.525f
    return c / 2.0f * (postFix * t * ((s + 1.0f) * t + s) + 2.0f) + b
end function

'' Bounce Easing functions
function EaseBounceOut(byval t as single, b as single, c as single, d as single) as single '' Ease: Bounce Out
    t /= d
    if t < 1.0f / 2.75f then
        return c* ( 7.5625f * t * t) + b
    elseif t < 2.0f / 2.75f then
        t -= (1.5f / 2.75f)
        dim as single postFix = t
        return c * (7.5625f * postFix * t + 0.75f) + b
    elseif t < 2.5 / 2.75 then
        t -= (2.25f / 2.75f)
        dim as single postFix = t
        return c * (7.5625f * postFix * t + 0.9375f) + b
    else
        t-= 2.625f / 2.75f
        dim as single postFix = t
        return c * (7.5625f * postFix * t + 0.984375f) + b
    end if
end function

function EaseBounceIn(t as single, b as single, c as single, d as single) as single '' Ease: Bounce In
    return c - EaseBounceOut(d - t, 0.0f, c, d) + b
end function

function EaseBounceInOut(t as single, b as single, c as single, d as single) as single '' Ease: Bounce In Out
    if t < d / 2.0f then 
        return EaseBounceIn(t * 2.0f, 0.0f, c, d) * 0.5f + b
    else 
        return EaseBounceOut(t * 2.0f - d, 0.0f, c, d) * 0.5f + c * 0.5f + b
    end if
end function

'' Elastic Easing functions
function EaseElasticIn(byval t as single, b as single, c as single, d as single) as single '' Ease: Elastic In
    if t = 0.0f then return b
    t /= d
    if t = 1.0f then return b + c

    dim as single p = d * 0.3f
    dim as single a = c
    dim as single s = p / 4.0f
    t -= 1.0f
    dim as single postFix = a * powf(2.0f, 10.0f * t)

    return -(postFix * sinf((t * d - s) * (2.0f * PI) / p)) + b
end function

function EaseElasticOut(byval t as single, b as single, c as single, d as single) as single '' Ease: Elastic Out
    if t = 0.0f then return b
    t /= d
    if t = 1.0f then return b + c

    dim as single p = d * 0.3f
    dim as single a = c
    dim as single s = p / 4.0f

    return a * powf(2.0f,-10.0f * t) * sinf((t * d - s) * (2.0f * PI) / p) + c + b
end function

function EaseElasticInOut(byval t as single, b as single, c as single, d as single) as single '' Ease: Elastic In Out
    if t = 0.0f then return b
    t /= d
    if t / 2.0f = 2.0f then return b + c

    dim as single p = d * (0.3f * 1.5f)
    dim as single a = c
    dim as single s = p / 4.0f

    if t < 1.0f then
        t -= 1.0f
        dim as single postFix = a * powf(2.0f, 10.0f * t)
        return -0.5f * (postFix * sinf((t * d - s) * (2.0f * PI) / p)) + b
    end if
    t -= 1.0f
    dim as single postFix = a * powf(2.0f, -10.0f * t)

    return postFix * sinf((t * d - s) * (2.0f * PI) / p) * 0.5f + c + b
end function

#endif '' REASINGS_H