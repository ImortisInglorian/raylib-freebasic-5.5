/'******************************************************************************************
*
*   raylib [text] example - Unicode
*
*   Example originally created with raylib 2.5, last time updated with raylib 4.0
*
*   Example contributed by Vlad Adrian (@demizdor) and reviewed by Ramon Santamaria (@raysan5)
*
*   Example licensed under an unmodified zlib/libpng license, which is an OSI-certified,
*   BSD-like license that allows static linking with closed source software
*
*   Copyright (c) 2019-2024 Vlad Adrian (@demizdor) and Ramon Santamaria (@raysan5)
*
*******************************************************************************************'/

#include "../../raylib.bi"
#include "crt/mem.bi"

#define EMOJI_PER_WIDTH 8
#define EMOJI_PER_HEIGHT 4

'' String containing 180 emoji codepoints separated by a '\0' char
dim as ubyte emojiCodepoints(...) = { _
        &hF0,&h9F,&h8C,&h80,&h00,&hF0,&h9F,&h98,&h80,&h00,&hF0,&h9F,&h98,&h82,&h00,&hF0,&h9F,&hA4, _
        &hA3,&h00,&hF0,&h9F,&h98,&h83,&h00,&hF0,&h9F,&h98,&h86,&h00,&hF0,&h9F,&h98,&h89,&h00,&hF0, _
        &h9F,&h98,&h8B,&h00,&hF0,&h9F,&h98,&h8E,&h00,&hF0,&h9F,&h98,&h8D,&h00,&hF0,&h9F,&h98,&h98, _
        &h00,&hF0,&h9F,&h98,&h97,&h00,&hF0,&h9F,&h98,&h99,&h00,&hF0,&h9F,&h98,&h9A,&h00,&hF0,&h9F, _
        &h99,&h82,&h00,&hF0,&h9F,&hA4,&h97,&h00,&hF0,&h9F,&hA4,&hA9,&h00,&hF0,&h9F,&hA4,&h94,&h00, _
        &hF0,&h9F,&hA4,&hA8,&h00,&hF0,&h9F,&h98,&h90,&h00,&hF0,&h9F,&h98,&h91,&h00,&hF0,&h9F,&h98, _
        &hB6,&h00,&hF0,&h9F,&h99,&h84,&h00,&hF0,&h9F,&h98,&h8F,&h00,&hF0,&h9F,&h98,&hA3,&h00,&hF0, _
        &h9F,&h98,&hA5,&h00,&hF0,&h9F,&h98,&hAE,&h00,&hF0,&h9F,&hA4,&h90,&h00,&hF0,&h9F,&h98,&hAF, _
        &h00,&hF0,&h9F,&h98,&hAA,&h00,&hF0,&h9F,&h98,&hAB,&h00,&hF0,&h9F,&h98,&hB4,&h00,&hF0,&h9F, _
        &h98,&h8C,&h00,&hF0,&h9F,&h98,&h9B,&h00,&hF0,&h9F,&h98,&h9D,&h00,&hF0,&h9F,&hA4,&hA4,&h00, _
        &hF0,&h9F,&h98,&h92,&h00,&hF0,&h9F,&h98,&h95,&h00,&hF0,&h9F,&h99,&h83,&h00,&hF0,&h9F,&hA4, _
        &h91,&h00,&hF0,&h9F,&h98,&hB2,&h00,&hF0,&h9F,&h99,&h81,&h00,&hF0,&h9F,&h98,&h96,&h00,&hF0, _
        &h9F,&h98,&h9E,&h00,&hF0,&h9F,&h98,&h9F,&h00,&hF0,&h9F,&h98,&hA4,&h00,&hF0,&h9F,&h98,&hA2, _
        &h00,&hF0,&h9F,&h98,&hAD,&h00,&hF0,&h9F,&h98,&hA6,&h00,&hF0,&h9F,&h98,&hA9,&h00,&hF0,&h9F, _
        &hA4,&hAF,&h00,&hF0,&h9F,&h98,&hAC,&h00,&hF0,&h9F,&h98,&hB0,&h00,&hF0,&h9F,&h98,&hB1,&h00, _
        &hF0,&h9F,&h98,&hB3,&h00,&hF0,&h9F,&hA4,&hAA,&h00,&hF0,&h9F,&h98,&hB5,&h00,&hF0,&h9F,&h98, _
        &hA1,&h00,&hF0,&h9F,&h98,&hA0,&h00,&hF0,&h9F,&hA4,&hAC,&h00,&hF0,&h9F,&h98,&hB7,&h00,&hF0, _
        &h9F,&hA4,&h92,&h00,&hF0,&h9F,&hA4,&h95,&h00,&hF0,&h9F,&hA4,&hA2,&h00,&hF0,&h9F,&hA4,&hAE, _
        &h00,&hF0,&h9F,&hA4,&hA7,&h00,&hF0,&h9F,&h98,&h87,&h00,&hF0,&h9F,&hA4,&hA0,&h00,&hF0,&h9F, _
        &hA4,&hAB,&h00,&hF0,&h9F,&hA4,&hAD,&h00,&hF0,&h9F,&hA7,&h90,&h00,&hF0,&h9F,&hA4,&h93,&h00, _
        &hF0,&h9F,&h98,&h88,&h00,&hF0,&h9F,&h91,&hBF,&h00,&hF0,&h9F,&h91,&hB9,&h00,&hF0,&h9F,&h91, _
        &hBA,&h00,&hF0,&h9F,&h92,&h80,&h00,&hF0,&h9F,&h91,&hBB,&h00,&hF0,&h9F,&h91,&hBD,&h00,&hF0, _
        &h9F,&h91,&hBE,&h00,&hF0,&h9F,&hA4,&h96,&h00,&hF0,&h9F,&h92,&hA9,&h00,&hF0,&h9F,&h98,&hBA, _
        &h00,&hF0,&h9F,&h98,&hB8,&h00,&hF0,&h9F,&h98,&hB9,&h00,&hF0,&h9F,&h98,&hBB,&h00,&hF0,&h9F, _
        &h98,&hBD,&h00,&hF0,&h9F,&h99,&h80,&h00,&hF0,&h9F,&h98,&hBF,&h00,&hF0,&h9F,&h8C,&hBE,&h00, _
        &hF0,&h9F,&h8C,&hBF,&h00,&hF0,&h9F,&h8D,&h80,&h00,&hF0,&h9F,&h8D,&h83,&h00,&hF0,&h9F,&h8D, _
        &h87,&h00,&hF0,&h9F,&h8D,&h93,&h00,&hF0,&h9F,&hA5,&h9D,&h00,&hF0,&h9F,&h8D,&h85,&h00,&hF0, _
        &h9F,&hA5,&hA5,&h00,&hF0,&h9F,&hA5,&h91,&h00,&hF0,&h9F,&h8D,&h86,&h00,&hF0,&h9F,&hA5,&h94, _
        &h00,&hF0,&h9F,&hA5,&h95,&h00,&hF0,&h9F,&h8C,&hBD,&h00,&hF0,&h9F,&h8C,&hB6,&h00,&hF0,&h9F, _
        &hA5,&h92,&h00,&hF0,&h9F,&hA5,&hA6,&h00,&hF0,&h9F,&h8D,&h84,&h00,&hF0,&h9F,&hA5,&h9C,&h00, _
        &hF0,&h9F,&h8C,&hB0,&h00,&hF0,&h9F,&h8D,&h9E,&h00,&hF0,&h9F,&hA5,&h90,&h00,&hF0,&h9F,&hA5, _
        &h96,&h00,&hF0,&h9F,&hA5,&hA8,&h00,&hF0,&h9F,&hA5,&h9E,&h00,&hF0,&h9F,&hA7,&h80,&h00,&hF0, _
        &h9F,&h8D,&h96,&h00,&hF0,&h9F,&h8D,&h97,&h00,&hF0,&h9F,&hA5,&hA9,&h00,&hF0,&h9F,&hA5,&h93, _
        &h00,&hF0,&h9F,&h8D,&h94,&h00,&hF0,&h9F,&h8D,&h9F,&h00,&hF0,&h9F,&h8D,&h95,&h00,&hF0,&h9F, _
        &h8C,&hAD,&h00,&hF0,&h9F,&hA5,&hAA,&h00,&hF0,&h9F,&h8C,&hAE,&h00,&hF0,&h9F,&h8C,&hAF,&h00, _
        &hF0,&h9F,&hA5,&h99,&h00,&hF0,&h9F,&hA5,&h9A,&h00,&hF0,&h9F,&h8D,&hB3,&h00,&hF0,&h9F,&hA5, _
        &h98,&h00,&hF0,&h9F,&h8D,&hB2,&h00,&hF0,&h9F,&hA5,&hA3,&h00,&hF0,&h9F,&hA5,&h97,&h00,&hF0, _
        &h9F,&h8D,&hBF,&h00,&hF0,&h9F,&hA5,&hAB,&h00,&hF0,&h9F,&h8D,&hB1,&h00,&hF0,&h9F,&h8D,&h98, _
        &h00,&hF0,&h9F,&h8D,&h9D,&h00,&hF0,&h9F,&h8D,&hA0,&h00,&hF0,&h9F,&h8D,&hA2,&h00,&hF0,&h9F, _
        &h8D,&hA5,&h00,&hF0,&h9F,&h8D,&hA1,&h00,&hF0,&h9F,&hA5,&h9F,&h00,&hF0,&h9F,&hA5,&hA1,&h00, _
        &hF0,&h9F,&h8D,&hA6,&h00,&hF0,&h9F,&h8D,&hAA,&h00,&hF0,&h9F,&h8E,&h82,&h00,&hF0,&h9F,&h8D, _
        &hB0,&h00,&hF0,&h9F,&hA5,&hA7,&h00,&hF0,&h9F,&h8D,&hAB,&h00,&hF0,&h9F,&h8D,&hAF,&h00,&hF0, _
        &h9F,&h8D,&hBC,&h00,&hF0,&h9F,&hA5,&h9B,&h00,&hF0,&h9F,&h8D,&hB5,&h00,&hF0,&h9F,&h8D,&hB6, _
        &h00,&hF0,&h9F,&h8D,&hBE,&h00,&hF0,&h9F,&h8D,&hB7,&h00,&hF0,&h9F,&h8D,&hBB,&h00,&hF0,&h9F, _
        &hA5,&h82,&h00,&hF0,&h9F,&hA5,&h83,&h00,&hF0,&h9F,&hA5,&hA4,&h00,&hF0,&h9F,&hA5,&hA2,&h00, _
        &hF0,&h9F,&h91,&h81,&h00,&hF0,&h9F,&h91,&h85,&h00,&hF0,&h9F,&h91,&h84,&h00,&hF0,&h9F,&h92, _
        &h8B,&h00,&hF0,&h9F,&h92,&h98,&h00,&hF0,&h9F,&h92,&h93,&h00,&hF0,&h9F,&h92,&h97,&h00,&hF0, _
        &h9F,&h92,&h99,&h00,&hF0,&h9F,&h92,&h9B,&h00,&hF0,&h9F,&hA7,&hA1,&h00,&hF0,&h9F,&h92,&h9C, _
        &h00,&hF0,&h9F,&h96,&hA4,&h00,&hF0,&h9F,&h92,&h9D,&h00,&hF0,&h9F,&h92,&h9F,&h00,&hF0,&h9F, _
        &h92,&h8C,&h00,&hF0,&h9F,&h92,&hA4,&h00,&hF0,&h9F,&h92,&hA2,&h00,&hF0,&h9F,&h92,&hA3,&h00 _
    }
#define FIXSTRINGS(a) a,len(a)
type Message
    declare constructor()
    declare constructor(txt as zstring ptr, txtlen as integer, lang as string)
    as string text
    as string language
end type

constructor Message()
end constructor

constructor Message(txt as zstring ptr, txtlen as integer, lang as string)
    this.text = space(txtlen)
    memcpy(strptr(this.text), txt, txtlen)
    this.language = lang
end constructor

'' Array containing all of the emojis messages
dim shared as Message messages(...) = { _
    Type(FIXSTRINGS(!"\&h46\&h61\&h6C\&h73\&h63\&h68\&h65\&h73\&h20\&hC3\&h9C\&h62\&h65\&h6E\&h20" _
        !"\&h76\&h6F\&h6E\&h20\&h58\&h79\&h6C\&h6F\&h70\&h68\&h6F\&h6E\&h6D\&h75\&h73\&h69\&h6B\&h20" _
        !"\&h71\&h75\&hC3\&hA4\&h6C\&h74\&h20\&h6A\&h65\&h64\&h65\&h6E\&h20\&h67\&h72\&hC3\&hB6\&hC3" _
        !"\&h9F\&h65\&h72\&h65\&h6E\&h20\&h5A\&h77\&h65\&h72\&h67"), "German"), _
    Type(FIXSTRINGS(!"\&h42\&h65\&h69\&hC3\&h9F\&h20\&h6E\&h69\&h63\&h68\&h74\&h20\&h69\&h6E\&h20" _
        !"\&h64\&h69\&h65\&h20\&h48\&h61\&h6E\&h64\&h2C\&h20\&h64\&h69\&h65\&h20\&h64\&h69\&h63\&h68" _
        !"\&h20\&h66\&hC3\&hBC\&h74\&h74\&h65\&h72\&h74\&h2E"), "German"), _
    Type(FIXSTRINGS(!"\&h41\&h75\&hC3\&h9F\&h65\&h72\&h6F\&h72\&h64\&h65\&h6E\&h74\&h6C\&h69\&h63" _ 
        !"\&h68\&h65\&h20\&hC3\&h9C\&h62\&h65\&h6C\&h20\&h65\&h72\&h66\&h6F\&h72\&h64\&h65\&h72\&h6E" _
        !"\&h20\&h61\&h75\&hC3\&h9F\&h65\&h72\&h6F\&h72\&h64\&h65\&h6E\&h74\&h6C\&h69\&h63\&h68\&h65" _
        !"\&h20\&h4D\&h69\&h74\&h74\&h65\&h6C\&h2E"), "German"), _
    Type(FIXSTRINGS(!"\&hD4\&hBF\&hD6\&h80\&hD5\&hB6\&hD5\&hA1\&hD5\&hB4\&h20\&hD5\&hA1\&hD5\&hBA" _
        !"\&hD5\&hA1\&hD5\&hAF\&hD5\&hAB\&h20\&hD5\&hB8\&hD6\&h82\&hD5\&hBF\&hD5\&hA5\&hD5\&hAC\&h20" _
        !"\&hD6\&h87\&h20\&hD5\&hAB\&hD5\&hB6\&hD5\&hAE\&hD5\&hAB\&h20\&hD5\&hA1\&hD5\&hB6\&hD5\&hB0" _
        !"\&hD5\&hA1\&hD5\&hB6\&hD5\&hA3\&hD5\&hAB\&hD5\&hBD\&hD5\&hBF\&h20\&hD5\&hB9\&hD5\&hA8\&hD5" _
        !"\&hB6\&hD5\&hA5\&hD6\&h80"), "Armenian"), _
    Type(FIXSTRINGS(!"\&hD4\&hB5\&hD6\&h80\&hD5\&hA2\&h20\&hD5\&hB8\&hD6\&h80\&h20\&hD5\&hAF\&hD5" _
        !"\&hA1\&hD6\&h81\&hD5\&hAB\&hD5\&hB6\&hD5\&hA8\&h20\&hD5\&hA5\&hD5\&hAF\&hD5\&hA1\&hD6\&h82" _
        !"\&h20\&hD5\&hA1\&hD5\&hB6\&hD5\&hBF\&hD5\&hA1\&hD5\&hBC\&h2C\&h20\&hD5\&hAE\&hD5\&hA1\&hD5" _
        !"\&hBC\&hD5\&hA5\&hD6\&h80\&hD5\&hA8\&h20\&hD5\&hA1\&hD5\&hBD\&hD5\&hA1\&hD6\&h81\&hD5\&hAB" _
        !"\&hD5\&hB6\&h2E\&h2E\&h2E\&h20\&hC2\&hAB\&hD4\&hBF\&hD5\&hB8\&hD5\&hBF\&hD5\&hA8\&h20\&hD5" _
        !"\&hB4\&hD5\&hA5\&hD6\&h80\&hD5\&hB8\&hD5\&hB6\&hD6\&h81\&hD5\&hAB\&hD6\&h81\&h20\&hD5\&hA7" _
        !"\&h3A\&hC2\&hBB"), "Armenian"), _
    Type(FIXSTRINGS(!"\&hD4\&hB3\&hD5\&hA1\&hD5\&hBC\&hD5\&hA8\&hD5\&h9D\&h20\&hD5\&hA3\&hD5\&hA1" _
        !"\&hD6\&h80\&hD5\&hB6\&hD5\&hA1\&hD5\&hB6\&h2C\&h20\&hD5\&hB1\&hD5\&hAB\&hD6\&h82\&hD5\&hB6" _
        !"\&hD5\&hA8\&hD5\&h9D\&h20\&hD5\&hB1\&hD5\&hB4\&hD5\&hBC\&hD5\&hA1\&hD5\&hB6"), "Armenian"), _
    Type(FIXSTRINGS(!"\&h4A\&h65\&hC5\&hBC\&h75\&h20\&h6B\&h6C\&hC4\&h85\&h74\&h77\&h2C\&h20\&h73" _
        !"\&h70\&hC5\&h82\&hC3\&hB3\&h64\&hC5\&hBA\&h20\&h46\&h69\&h6E\&h6F\&h6D\&h20\&h63\&h7A\&hC4" _
        !"\&h99\&hC5\&h9B\&hC4\&h87\&h20\&h67\&h72\&h79\&h20\&h68\&h61\&hC5\&h84\&h62\&h21"), "Polish"), _
    Type(FIXSTRINGS(!"\&h44\&h6F\&h62\&h72\&h79\&h6D\&h69\&h20\&h63\&h68\&hC4\&h99\&h63\&h69\&h61" _
        !"\&h6D\&h69\&h20\&h6A\&h65\&h73\&h74\&h20\&h70\&h69\&h65\&h6B\&hC5\&h82\&h6F\&h20\&h77\&h79" _
        !"\&h62\&h72\&h75\&h6B\&h6F\&h77\&h61\&h6E\&h65\&h2E"), "Polish"), _
    Type(FIXSTRINGS(!"\&hC3\&h8E\&hC8\&h9B\&h69\&h20\&h6D\&h75\&h6C\&hC8\&h9B\&h75\&h6D\&h65\&h73" _
        !"\&h63\&h20\&h63\&hC4\&h83\&h20\&h61\&h69\&h20\&h61\&h6C\&h65\&h73\&h20\&h72\&h61\&h79\&h6C" _
        !"\&h69\&h62\&h2E\&h0A\&hC8\&h98\&h69\&h20\&h73\&h70\&h65\&h72\&h20\&h73\&hC4\&h83\&h20\&h61" _
        !"\&h69\&h20\&h6F\&h20\&h7A\&h69\&h20\&h62\&h75\&h6E\&hC4\&h83\&h21"), "Romanian"), _
    Type(FIXSTRINGS(!"\&hD0\&hAD\&hD1\&h85\&h2C\&h20\&hD1\&h87\&hD1\&h83\&hD0\&hB6\&hD0\&hB0\&hD0" _
        !"\&hBA\&h2C\&h20\&hD0\&hBE\&hD0\&hB1\&hD1\&h89\&hD0\&hB8\&hD0\&hB9\&h20\&hD1\&h81\&hD1\&h8A" _
        !"\&hD1\&h91\&hD0\&hBC\&h20\&hD1\&h86\&hD0\&hB5\&hD0\&hBD\&h20\&hD1\&h88\&hD0\&hBB\&hD1\&h8F" _
        !"\&hD0\&hBF\&h20\&h28\&hD1\&h8E\&hD1\&h84\&hD1\&h82\&hD1\&h8C\&h29\&h20\&hD0\&hB2\&hD0\&hB4" _
        !"\&hD1\&h80\&hD1\&h8B\&hD0\&hB7\&hD0\&hB3\&h21"), "Russian"), _
    Type(FIXSTRINGS(!"\&hD0\&hAF\&h20\&hD0\&hBB\&hD1\&h8E\&hD0\&hB1\&hD0\&hBB\&hD1\&h8E\&h20\&h72" _
        !"\&h61\&h79\&h6C\&h69\&h62\&h21"), "Russian"), _
    Type(FIXSTRINGS(!"\&hD0\&h9C\&hD0\&hBE\&hD0\&hBB\&hD1\&h87\&hD0\&hB8\&h2C\&h20\&hD1\&h81\&hD0" _
        !"\&hBA\&hD1\&h80\&hD1\&h8B\&hD0\&hB2\&hD0\&hB0\&hD0\&hB9\&hD1\&h81\&hD1\&h8F\&h20\&hD0\&hB8" _
        !"\&h20\&hD1\&h82\&hD0\&hB0\&hD0\&hB8\&h0A\&hD0\&h98\&h20\&hD1\&h87\&hD1\&h83\&hD0\&hB2\&hD1" _
        !"\&h81\&hD1\&h82\&hD0\&hB2\&hD0\&hB0\&h20\&hD0\&hB8\&h20\&hD0\&hBC\&hD0\&hB5\&hD1\&h87\&hD1" _
        !"\&h82\&hD1\&h8B\&h20\&hD1\&h81\&hD0\&hB2\&hD0\&hBE\&hD0\&hB8\&h20\&hE2\&h80\&h93\&h0A\&hD0" _
        !"\&h9F\&hD1\&h83\&hD1\&h81\&hD0\&hBA\&hD0\&hB0\&hD0\&hB9\&h20\&hD0\&hB2\&h20\&hD0\&hB4\&hD1" _
        !"\&h83\&hD1\&h88\&hD0\&hB5\&hD0\&hB2\&hD0\&hBD\&hD0\&hBE\&hD0\&hB9\&h20\&hD0\&hB3\&hD0\&hBB" _
        !"\&hD1\&h83\&hD0\&hB1\&hD0\&hB8\&hD0\&hBD\&hD0\&hB5\&h0A\&hD0\&h98\&h20\&hD0\&hB2\&hD1\&h81" _
        !"\&hD1\&h85\&hD0\&hBE\&hD0\&hB4\&hD1\&h8F\&hD1\&h82\&h20\&hD0\&hB8\&h20\&hD0\&hB7\&hD0\&hB0" _
        !"\&hD0\&hB9\&hD0\&hB4\&hD1\&h83\&hD1\&h82\&h20\&hD0\&hBE\&hD0\&hBD\&hD0\&hB5\&h0A\&hD0\&h9A" _
        !"\&hD0\&hB0\&hD0\&hBA\&h20\&hD0\&hB7\&hD0\&hB2\&hD0\&hB5\&hD0\&hB7\&hD0\&hB4\&hD1\&h8B\&h20" _
        !"\&hD1\&h8F\&hD1\&h81\&hD0\&hBD\&hD1\&h8B\&hD0\&hB5\&h20\&hD0\&hB2\&h20\&hD0\&hBD\&hD0\&hBE" _
        !"\&hD1\&h87\&hD0\&hB8\&h2D\&h0A\&hD0\&h9B\&hD1\&h8E\&hD0\&hB1\&hD1\&h83\&hD0\&hB9\&hD1\&h81" _
        !"\&hD1\&h8F\&h20\&hD0\&hB8\&hD0\&hBC\&hD0\&hB8\&h20\&hE2\&h80\&h93\&h20\&hD0\&hB8\&h20\&hD0" _
        !"\&hBC\&hD0\&hBE\&hD0\&hBB\&hD1\&h87\&hD0\&hB8\&h2E"), "Russian"), _
    Type(FIXSTRINGS(!"\&h56\&h6F\&h69\&h78\&h20\&h61\&h6D\&h62\&h69\&h67\&h75\&hC3\&hAB\&h20\&h64" _
        !"\&hE2\&h80\&h99\&h75\&h6E\&h20\&h63\&hC5\&h93\&h75\&h72\&h20\&h71\&h75\&h69\&h20\&h61\&h75" _
        !"\&h20\&h7A\&hC3\&hA9\&h70\&h68\&h79\&h72\&h20\&h70\&h72\&hC3\&hA9\&h66\&hC3\&hA8\&h72\&h65" _
        !"\&h20\&h6C\&h65\&h73\&h20\&h6A\&h61\&h74\&h74\&h65\&h73\&h20\&h64\&h65\&h20\&h6B\&h69\&h77" _
        !"\&h69"), "French"), _
    Type(FIXSTRINGS(!"\&h42\&h65\&h6E\&h6A\&h61\&h6D\&hC3\&hAD\&h6E\&h20\&h70\&h69\&h64\&h69\&hC3" _
        !"\&hB3\&h20\&h75\&h6E\&h61\&h20\&h62\&h65\&h62\&h69\&h64\&h61\&h20\&h64\&h65\&h20\&h6B\&h69" _
        !"\&h77\&h69\&h20\&h79\&h20\&h66\&h72\&h65\&h73\&h61\&h3B\&h20\&h4E\&h6F\&hC3\&hA9\&h2C\&h20" _
        !"\&h73\&h69\&h6E\&h20\&h76\&h65\&h72\&h67\&hC3\&hBC\&h65\&h6E\&h7A\&h61\&h2C\&h20\&h6C\&h61" _
        !"\&h20\&h6D\&hC3\&hA1\&h73\&h20\&h65\&h78\&h71\&h75\&h69\&h73\&h69\&h74\&h61\&h20\&h63\&h68" _
        !"\&h61\&h6D\&h70\&h61\&hC3\&hB1\&h61\&h20\&h64\&h65\&h6C\&h20\&h6D\&h65\&h6E\&hC3\&hBA\&h2E" _
        ), "Spanish"), _
    Type(FIXSTRINGS(!"\&hCE\&hA4\&hCE\&hB1\&hCF\&h87\&hCE\&hAF\&hCF\&h83\&hCF\&h84\&hCE\&hB7\&h20" _
        !"\&hCE\&hB1\&hCE\&hBB\&hCF\&h8E\&hCF\&h80\&hCE\&hB7\&hCE\&hBE\&h20\&hCE\&hB2\&hCE\&hB1\&hCF" _
        !"\&h86\&hCE\&hAE\&hCF\&h82\&h20\&hCF\&h88\&hCE\&hB7\&hCE\&hBC\&hCE\&hAD\&hCE\&hBD\&hCE\&hB7" _
        !"\&h20\&hCE\&hB3\&hCE\&hB7\&h2C\&h20\&hCE\&hB4\&hCF\&h81\&hCE\&hB1\&hCF\&h83\&hCE\&hBA\&hCE" _
        !"\&hB5\&hCE\&hBB\&hCE\&hAF\&hCE\&hB6\&hCE\&hB5\&hCE\&hB9\&h20\&hCF\&h85\&hCF\&h80\&hCE\&hAD" _
        !"\&hCF\&h81\&h20\&hCE\&hBD\&hCF\&h89\&hCE\&hB8\&hCF\&h81\&hCE\&hBF\&hCF\&h8D\&h20\&hCE\&hBA" _
        !"\&hCF\&h85\&hCE\&hBD\&hCF\&h8C\&hCF\&h82"), "Greek"), _
    Type(FIXSTRINGS(!"\&hCE\&h97\&h20\&hCE\&hBA\&hCE\&hB1\&hCE\&hBB\&hCF\&h8D\&hCF\&h84\&hCE\&hB5" _
        !"\&hCF\&h81\&hCE\&hB7\&h20\&hCE\&hAC\&hCE\&hBC\&hCF\&h85\&hCE\&hBD\&hCE\&hB1\&h20\&hCE\&hB5" _
        !"\&hCE\&hAF\&hCE\&hBD\&hCE\&hB1\&hCE\&hB9\&h20\&hCE\&hB7\&h20\&hCE\&hB5\&hCF\&h80\&hCE\&hAF" _
        !"\&hCE\&hB8\&hCE\&hB5\&hCF\&h83\&hCE\&hB7\&h2E"), "Greek"), _ 
    Type(FIXSTRINGS(!"\&hCE\&hA7\&hCF\&h81\&hCF\&h8C\&hCE\&hBD\&hCE\&hB9\&hCE\&hB1\&h20\&hCE\&hBA" _
        !"\&hCE\&hB1\&hCE\&hB9\&h20\&hCE\&hB6\&hCE\&hB1\&hCE\&hBC\&hCE\&hAC\&hCE\&hBD\&hCE\&hB9\&hCE" _
        !"\&hB1\&h21"), "Greek"), _
    Type(FIXSTRINGS(!"\&hCE\&hA0\&hCF\&h8E\&hCF\&h82\&h20\&hCF\&h84\&hCE\&hB1\&h20\&hCF\&h80\&hCE" _
        !"\&hB1\&hCF\&h82\&h20\&hCF\&h83\&hCE\&hAE\&hCE\&hBC\&hCE\&hB5\&hCF\&h81\&hCE\&hB1\&h3B"), _
        "Greek"), _
    Type(FIXSTRINGS(!"\&hE6\&h88\&h91\&hE8\&h83\&hBD\&hE5\&h90\&h9E\&hE4\&hB8\&h8B\&hE7\&h8E\&hBB" _
        !"\&hE7\&h92\&h83\&hE8\&h80\&h8C\&hE4\&hB8\&h8D\&hE4\&hBC\&hA4\&hE8\&hBA\&hAB\&hE4\&hBD\&h93" _
        !"\&hE3\&h80\&h82"), "Chinese"), _
    Type(FIXSTRINGS(!"\&hE4\&hBD\&hA0\&hE5\&h90\&h83\&hE4\&hBA\&h86\&hE5\&h90\&h97\&hEF\&hBC\&h9F"), _
        "Chinese"), _
    Type(FIXSTRINGS(!"\&hE4\&hB8\&h8D\&hE4\&hBD\&h9C\&hE4\&hB8\&h8D\&hE6\&hAD\&hBB\&hE3\&h80\&h82"), _
        "Chinese"), _
    Type(FIXSTRINGS(!"\&hE6\&h9C\&h80\&hE8\&hBF\&h91\&hE5\&hA5\&hBD\&hE5\&h90\&h97\&hEF\&hBC\&h9F"), _
        "Chinese"), _
    Type(FIXSTRINGS(!"\&hE5\&hA1\&h9E\&hE7\&hBF\&h81\&hE5\&hA4\&hB1\&hE9\&hA9\&hAC\&hEF\&hBC\&h8C" _
        !"\&hE7\&h84\&h89\&hE7\&h9F\&hA5\&hE9\&h9D\&h9E\&hE7\&hA6\&h8F\&hE3\&h80\&h82"), "Chinese"), _
    Type(FIXSTRINGS(!"\&hE5\&h8D\&h83\&hE5\&h86\&h9B\&hE6\&h98\&h93\&hE5\&hBE\&h97\&h2C\&h20\&hE4" _
        !"\&hB8\&h80\&hE5\&hB0\&h86\&hE9\&h9A\&hBE\&hE6\&hB1\&h82"), "Chinese"), _
    Type(FIXSTRINGS(!"\&hE4\&hB8\&h87\&hE4\&hBA\&h8B\&hE5\&hBC\&h80\&hE5\&hA4\&hB4\&hE9\&h9A\&hBE" _
        !"\&hE3\&h80\&h82"), "Chinese"), _
    Type(FIXSTRINGS(!"\&hE9\&hA3\&h8E\&hE6\&h97\&hA0\&hE5\&hB8\&hB8\&hE9\&hA1\&hBA\&hEF\&hBC\&h8C" _
        !"\&hE5\&h85\&hB5\&hE6\&h97\&hA0\&hE5\&hB8\&hB8\&hE8\&h83\&h9C\&hE3\&h80\&h82"), "Chinese"), _
    Type(FIXSTRINGS(!"\&hE6\&hB4\&hBB\&hE5\&h88\&hB0\&hE8\&h80\&h81\&hEF\&hBC\&h8C\&hE5\&hAD\&hA6" _
        !"\&hE5\&h88\&hB0\&hE8\&h80\&h81\&hE3\&h80\&h82"), "Chinese"), _
    Type(FIXSTRINGS(!"\&hE4\&hB8\&h80\&hE8\&hA8\&h80\&hE6\&h97\&hA2\&hE5\&h87\&hBA\&hEF\&hBC\&h8C" _
        !"\&hE9\&hA9\&hB7\&hE9\&hA9\&hAC\&hE9\&h9A\&hBE\&hE8\&hBF\&hBD\&hE3\&h80\&h82"), "Chinese"), _
    Type(FIXSTRINGS(!"\&hE8\&hB7\&hAF\&hE9\&h81\&hA5\&hE7\&h9F\&hA5\&hE9\&hA9\&hAC\&hE5\&h8A\&h9B" _
        !"\&hEF\&hBC\&h8C\&hE6\&h97\&hA5\&hE4\&hB9\&h85\&hE8\&hA7\&h81\&hE4\&hBA\&hBA\&hE5\&hBF\&h83"), _
        "Chinese"), _
    Type(FIXSTRINGS(!"\&hE6\&h9C\&h89\&hE7\&h90\&h86\&hE8\&hB5\&hB0\&hE9\&h81\&h8D\&hE5\&hA4\&hA9" _
        !"\&hE4\&hB8\&h8B\&hEF\&hBC\&h8C\&hE6\&h97\&hA0\&hE7\&h90\&h86\&hE5\&hAF\&hB8\&hE6\&hAD\&hA5" _
        !"\&hE9\&h9A\&hBE\&hE8\&hA1\&h8C\&hE3\&h80\&h82"), "Chinese"), _
    Type(FIXSTRINGS(!"\&hE7\&h8C\&hBF\&hE3\&h82\&h82\&hE6\&h9C\&hA8\&hE3\&h81\&h8B\&hE3\&h82\&h89" _
        !"\&hE8\&h90\&hBD\&hE3\&h81\&hA1\&hE3\&h82\&h8B"), "Japanese"), _
    Type(FIXSTRINGS(!"\&hE4\&hBA\&h80\&hE3\&h81\&hAE\&hE7\&h94\&hB2\&hE3\&h82\&h88\&hE3\&h82\&h8A" _
        !"\&hE5\&hB9\&hB4\&hE3\&h81\&hAE\&hE5\&h8A\&h9F"), "Japanese"), _
    Type(FIXSTRINGS(!"\&hE3\&h81\&h86\&hE3\&h82\&h89\&hE3\&h82\&h84\&hE3\&h81\&hBE\&hE3\&h81\&h97" _
        !"\&h20\&h20\&hE6\&h80\&h9D\&hE3\&h81\&hB2\&hE5\&h88\&h87\&hE3\&h82\&h8B\&hE6\&h99\&h82\&h20" _
        !"\&h20\&hE7\&h8C\&hAB\&hE3\&h81\&hAE\&hE6\&h81\&h8B"), "Japanese"), _
    Type(FIXSTRINGS(!"\&hE8\&h99\&h8E\&hE7\&hA9\&hB4\&hE3\&h81\&hAB\&hE5\&h85\&hA5\&hE3\&h82\&h89" _
        !"\&hE3\&h81\&h9A\&hE3\&h82\&h93\&hE3\&h81\&hB0\&hE8\&h99\&h8E\&hE5\&hAD\&h90\&hE3\&h82\&h92" _
        !"\&hE5\&hBE\&h97\&hE3\&h81\&h9A\&hE3\&h80\&h82"), "Japanese"), _
    Type(FIXSTRINGS(!"\&hE4\&hBA\&h8C\&hE5\&h85\&h8E\&hE3\&h82\&h92\&hE8\&hBF\&hBD\&hE3\&h81\&h86" _
        !"\&hE8\&h80\&h85\&hE3\&h81\&hAF\&hE4\&hB8\&h80\&hE5\&h85\&h8E\&hE3\&h82\&h92\&hE3\&h82\&h82" _
        !"\&hE5\&hBE\&h97\&hE3\&h81\&h9A\&hE3\&h80\&h82"), "Japanese"), _
    Type(FIXSTRINGS(!"\&hE9\&hA6\&hAC\&hE9\&hB9\&hBF\&hE3\&h81\&hAF\&hE6\&hAD\&hBB\&hE3\&h81\&hAA" _
        !"\&hE3\&h81\&hAA\&hE3\&h81\&h8D\&hE3\&h82\&h83\&hE6\&hB2\&hBB\&hE3\&h82\&h89\&hE3\&h81\&hAA" _
        !"\&hE3\&h81\&h84\&hE3\&h80\&h82"), "Japanese"), _
    Type(FIXSTRINGS(!"\&hE6\&h9E\&hAF\&hE9\&h87\&h8E\&hE8\&hB7\&hAF\&hE3\&h81\&hAB\&hE3\&h80\&h80" _
        !"\&hE5\&hBD\&hB1\&hE3\&h81\&h8B\&hE3\&h81\&h95\&hE3\&h81\&hAA\&hE3\&h82\&h8A\&hE3\&h81\&hA6" _
        !"\&hE3\&h80\&h80\&hE3\&h82\&h8F\&hE3\&h81\&h8B\&hE3\&h82\&h8C\&hE3\&h81\&h91\&hE3\&h82\&h8A"), _
        "Japanese"), _
    Type(FIXSTRINGS(!"\&hE7\&hB9\&hB0\&hE3\&h82\&h8A\&hE8\&hBF\&h94\&hE3\&h81\&h97\&hE9\&hBA\&hA6" _
        !"\&hE3\&h81\&hAE\&hE7\&h95\&h9D\&hE7\&hB8\&hAB\&hE3\&h81\&hB5\&hE8\&h83\&hA1\&hE8\&h9D\&hB6" _
        !"\&hE5\&h93\&h89"), "Japanese"), _
    Type(FIXSTRINGS(!"\&hEC\&h95\&h84\&hEB\&h93\&h9D\&hED\&h95\&h9C\&h20\&hEB\&hB0\&h94\&hEB\&h8B" _
        !"\&hA4\&h20\&hEC\&h9C\&h84\&hEC\&h97\&h90\&h20\&hEA\&hB0\&h88\&hEB\&hA7\&hA4\&hEA\&hB8\&hB0" _
        !"\&h20\&hEB\&h91\&h90\&hEC\&h97\&h87\&h20\&hEB\&h82\&hA0\&hEC\&h95\&h84\&h20\&hEB\&h8F\&h88" _
        !"\&hEB\&h8B\&hA4\&h2E\&h0A\&hEB\&h84\&h88\&hED\&h9B\&h8C\&hEB\&h84\&h88\&hED\&h9B\&h8C\&h20" _
        !"\&hEC\&h8B\&h9C\&hEB\&hA5\&hBC\&h20\&hEC\&h93\&hB4\&hEB\&h8B\&hA4\&h2E\&h20\&hEB\&hAA\&hA8" _
        !"\&hEB\&hA5\&hB4\&hEB\&h8A\&h94\&h20\&hEB\&h82\&h98\&hEB\&h9D\&hBC\&h20\&hEA\&hB8\&h80\&hEC" _
        !"\&h9E\&h90\&hEB\&h8B\&hA4\&h2E\&h0A\&hEB\&h84\&h90\&hEB\&h94\&hB0\&hEB\&h9E\&h80\&h20\&hED" _
        !"\&h95\&h98\&hEB\&h8A\&h98\&h20\&hEB\&hB3\&hB5\&hED\&h8C\&h90\&hEC\&h97\&h90\&h20\&hEB\&h82" _
        !"\&h98\&hEB\&h8F\&h84\&h20\&hEA\&hB0\&h99\&hEC\&h9D\&hB4\&h20\&hEC\&h8B\&h9C\&hEB\&hA5\&hBC" _
        !"\&h20\&hEC\&h93\&hB4\&hEB\&h8B\&hA4\&h2E"), "Korean"), _
    Type(FIXSTRINGS(!"\&hEC\&hA0\&h9C\&h20\&hEB\&h88\&h88\&hEC\&h97\&h90\&h20\&hEC\&h95\&h88\&hEA" _
        !"\&hB2\&hBD\&hEC\&h9D\&hB4\&hEB\&h8B\&hA4"), "Korean"), _
    Type(FIXSTRINGS(!"\&hEA\&hBF\&hA9\&h20\&hEB\&hA8\&hB9\&hEA\&hB3\&hA0\&h20\&hEC\&h95\&h8C\&h20" _
        !"\&hEB\&hA8\&hB9\&hEB\&h8A\&h94\&hEB\&h8B\&hA4"), "Korean"), _
    Type(FIXSTRINGS(!"\&hEB\&hA1\&h9C\&hEB\&hA7\&h88\&hEB\&h8A\&h94\&h20\&hED\&h95\&h98\&hEB\&hA3" _
        !"\&hA8\&hEC\&h95\&h84\&hEC\&hB9\&hA8\&hEC\&h97\&h90\&h20\&hEC\&h9D\&hB4\&hEB\&hA3\&hA8\&hEC" _
        !"\&h96\&hB4\&hEC\&hA7\&h84\&h20\&hEA\&hB2\&h83\&hEC\&h9D\&hB4\&h20\&hEC\&h95\&h84\&hEB\&h8B" _
        !"\&h88\&hEB\&h8B\&hA4"), "Korean"), _
    Type(FIXSTRINGS(!"\&hEA\&hB3\&hA0\&hEC\&h83\&h9D\&h20\&hEB\&h81\&h9D\&hEC\&h97\&h90\&h20\&hEB" _
        !"\&h82\&h99\&hEC\&h9D\&hB4\&h20\&hEC\&h98\&hA8\&hEB\&h8B\&hA4"), "Korean"), _
    Type(FIXSTRINGS(!"\&hEA\&hB0\&h9C\&hEC\&hB2\&h9C\&hEC\&h97\&h90\&hEC\&h84\&h9C\&h20\&hEC\&h9A" _
        !"\&hA9\&h20\&hEB\&h82\&h9C\&hEB\&h8B\&hA4"), "Korean"), _
    Type(FIXSTRINGS(!"\&hEC\&h95\&h88\&hEB\&h85\&h95\&hED\&h95\&h98\&hEC\&h84\&hB8\&hEC\&h9A\&h94" _
        !"\&h3F"), "Korean"), _
    Type(FIXSTRINGS(!"\&hEB\&hA7\&h8C\&hEB\&h82\&h98\&hEC\&h84\&h9C\&h20\&hEB\&hB0\&h98\&hEA\&hB0" _
        !"\&h91\&hEC\&h8A\&hB5\&hEB\&h8B\&h88\&hEB\&h8B\&hA4"), "Korean"), _
    Type(FIXSTRINGS(!"\&hED\&h95\&h9C\&hEA\&hB5\&hAD\&hEB\&hA7\&h90\&h20\&hED\&h95\&h98\&hEC\&h8B" _
        !"\&hA4\&h20\&hEC\&hA4\&h84\&h20\&hEC\&h95\&h84\&hEC\&h84\&hB8\&hEC\&h9A\&h94\&h3F"), "Korean") _
}


''--------------------------------------------------------------------------------------
'' Module functions declaration
''--------------------------------------------------------------------------------------
declare sub RandomizeEmoji()    '' Fills the emoji array with random emojis

declare sub DrawTextBoxed(fnt as Font, text as const zstring ptr, rec as Rectangle, fontSize as single, spacing as single, wordWrap as boolean, tint as RLColor)   '' Draw text using font inside rectangle limits
declare sub DrawTextBoxedSelectable(fnt as Font, text as const zstring ptr, rec as Rectangle, fontSize as single, spacing as single, wordWrap as boolean, tint as RLColor, selectStart as long, selectLength as long, selectTint as RLColor, selectBackTint as RLColor)    '' Draw text using font inside rectangle limits with support for text selection

''--------------------------------------------------------------------------------------
'' Global variables
''--------------------------------------------------------------------------------------
'' Arrays that holds the random emojis
type RandEmoji
    as long index
    as long message
    as RLColor color
end type
dim shared as RandEmoji emoji((EMOJI_PER_WIDTH * EMOJI_PER_HEIGHT) - 1)

dim shared as long hovered = -1, selected = -1

'' Initialization
''--------------------------------------------------------------------------------------
const as long screenWidth = 800
const as long screenHeight = 450

SetConfigFlags(FLAG_MSAA_4X_HINT or FLAG_VSYNC_HINT)
InitWindow(screenWidth, screenHeight, "raylib [text] example - unicode")

'' Load the font resources
'' NOTE: fontAsian is for asian languages,
'' fontEmoji is the emojis and fontDefault is used for everything else
dim as Font fontDefault = LoadFont("resources/dejavu.fnt")
dim as Font fontAsian = LoadFont("resources/noto_cjk.fnt")
dim as Font fontEmoji = LoadFont("resources/symbola.fnt")

dim as Vector2 hoveredPos = Vector2(0.0f, 0.0f)
dim as Vector2 selectedPos = Vector2(0.0f, 0.0f)

'' Set a random set of emojis when starting up
RandomizeEmoji()

SetTargetFPS(60)               '' Set our game to run at 60 frames-per-second
''--------------------------------------------------------------------------------------

'' Main loop
do while not WindowShouldClose()    '' Detect window close button or ESC key
    '' Update
    ''----------------------------------------------------------------------------------
    '' Add a new set of emojis when SPACE is pressed
    if IsKeyPressed(KEY_SPACE) then RandomizeEmoji()

    '' Set the selected emoji
    if IsMouseButtonPressed(MOUSE_BUTTON_LEFT) and (hovered <> -1) and (hovered <> selected) then
        selected = hovered
        selectedPos = hoveredPos
    end if

    dim as Vector2 mouse = GetMousePosition()
    dim as Vector2 position = Vector2(28.8f, 10.0f)
    hovered = -1
    ''----------------------------------------------------------------------------------

    '' Draw
    ''----------------------------------------------------------------------------------
    BeginDrawing()

        ClearBackground(RAYWHITE)

        '' Draw random emojis in the background
        ''------------------------------------------------------------------------------
        for i as integer = 0 to ubound(emoji) - 1
            dim as zstring ptr txt = @emojiCodepoints(emoji(i).index)
            dim as Rectangle emojiRect = Rectangle(position.x, position.y, fontEmoji.baseSize, fontEmoji.baseSize)

            if not CheckCollisionPointRec(mouse, emojiRect) then
                DrawTextEx(fontEmoji, txt, position, fontEmoji.baseSize, 1.0f, iif(selected = i, emoji(i).color, Fade(LIGHTGRAY, 0.4f)))
            else
                DrawTextEx(fontEmoji, txt, position, fontEmoji.baseSize, 1.0f, emoji(i).color )
                hovered = i
                hoveredPos = position
            end if

            if (i <> 0) and (i mod EMOJI_PER_WIDTH = 0) then 
                position.y += fontEmoji.baseSize + 24.25f 
                position.x = 28.8f
            else 
                position.x += fontEmoji.baseSize + 28.8f
            end if
        next
        ''------------------------------------------------------------------------------

        '' Draw the message when a emoji is selected
        ''------------------------------------------------------------------------------
        if selected <> -1 then
            dim as long mess = emoji(selected).message
            dim as long horizontalPadding = 20, verticalPadding = 30
            dim as Font ptr fnt = @fontDefault

            '' Set correct font for asian languages
            if TextIsEqual(messages(mess).language, "Chinese") or _
                TextIsEqual(messages(mess).language, "Korean") or _
                TextIsEqual(messages(mess).language, "Japanese") then fnt = @fontAsian

            '' Calculate size for the message box (approximate the height and width)
            dim as Vector2 sz = MeasureTextEx(*fnt, messages(mess).text, fnt->baseSize, 1.0f)
            if sz.x > 300 then
                sz.y *= sz.x/300 
                sz.x = 300
            elseif sz.x < 160 then
                sz.x = 160
            end if

            dim as Rectangle msgRect = Rectangle(selectedPos.x - 38.8f, selectedPos.y, 2 * horizontalPadding + sz.x, 2 * verticalPadding + sz.y)
            msgRect.y -= msgRect.height

            '' Coordinates for the chat bubble triangle
            dim as Vector2 a = Vector2(selectedPos.x, msgRect.y + msgRect.height), b = Vector2(a.x + 8, a.y + 10), c = Vector2(a.x + 10, a.y)

            '' Don't go outside the screen
            if msgRect.x < 10 then msgRect.x += 28
            if msgRect.y < 10 then
                msgRect.y = selectedPos.y + 84
                a.y = msgRect.y
                c.y = a.y
                b.y = a.y - 10

                '' Swap values so we can actually render the triangle :(
                dim as Vector2 tmp = a
                a = b
                b = tmp
            end if

            if msgRect.x + msgRect.width > screenWidth then msgRect.x -= (msgRect.x + msgRect.width) - screenWidth + 10

            '' Draw chat bubble
            DrawRectangleRec(msgRect, emoji(selected).color)
            DrawTriangle(a, b, c, emoji(selected).color)

            '' Draw the main text message
            dim as Rectangle textRect = Rectangle(msgRect.x + horizontalPadding/2, msgRect.y + verticalPadding/2, msgRect.width - horizontalPadding, msgRect.height)
            DrawTextBoxed(*fnt, @messages(mess).text[0], textRect, fnt->baseSize, 1.0f, true, WHITE)

            '' Draw the info text below the main message
            dim as long size = len(messages(mess).text)
            dim as ulong length = GetCodepointCount(messages(mess).text)
            dim as const zstring ptr info = TextFormat("%s %u characters %i bytes", messages(mess).language, length, size)
            sz = MeasureTextEx(GetFontDefault(), info, 10, 1.0f)
            
            DrawText(info, (textRect.x + textRect.width - sz.x), (msgRect.y + msgRect.height - sz.y - 2), 10, RAYWHITE)
        end if
        ''------------------------------------------------------------------------------

        '' Draw the info text
        DrawText("These emojis have something to tell you, click each to find out!", (screenWidth - 650)/2, screenHeight - 40, 20, GRAY)
        DrawText("Each emoji is a unicode character from a font, not a texture... Press [SPACEBAR] to refresh", (screenWidth - 484)/2, screenHeight - 16, 10, GRAY)

    EndDrawing()
    ''----------------------------------------------------------------------------------
loop

'' De-Initialization
''--------------------------------------------------------------------------------------
UnloadFont(fontDefault)    '' Unload font resource
UnloadFont(fontAsian)      '' Unload font resource
UnloadFont(fontEmoji)      '' Unload font resource

CloseWindow()              '' Close window and OpenGL context
''--------------------------------------------------------------------------------------

'' Fills the emoji array with random emoji (only those emojis present in fontEmoji)
sub RandomizeEmoji
    hovered = -1
    selected = -1
    dim as long start = GetRandomValue(45, 360)

    for i as integer = 0 to ubound(emoji) - 1
        '' 0-179 emoji codepoints (from emoji char array) each 4bytes + null char
        emoji(i).index = GetRandomValue(0, 179) * 5

        '' Generate a random color for this emoji
        emoji(i).color = Fade(ColorFromHSV(((start * (i + 1)) mod 360), 0.6f, 0.85f), 0.8f)

        '' Set a random message for this emoji
        emoji(i).message = GetRandomValue(0, ubound(messages) - 1)
    next
end sub

''--------------------------------------------------------------------------------------
'' Module functions definition
''--------------------------------------------------------------------------------------

'' Draw text using font inside rectangle limits
sub DrawTextBoxed(fnt as Font, text as const zstring ptr, rec as Rectangle, fontSize as single, spacing as single, wordWrap as boolean, tint as RLColor)
    DrawTextBoxedSelectable(fnt, text, rec, fontSize, spacing, wordWrap, tint, 0, 0, WHITE, WHITE)
end sub

'' Draw text using font inside rectangle limits with support for text selection
sub DrawTextBoxedSelectable(fnt as Font, text as const zstring ptr, rec as Rectangle, fontSize as single, spacing as single, wordWrap as boolean, tint as RLColor, selectStart as long, selectLength as long, selectTint as RLColor, selectBackTint as RLColor)
    dim as long length = TextLength(text)  '' Total length in bytes of the text, scanned by codepoints in loop

    dim as single textOffsetY = 0.0f       '' Offset between lines (on line break '\n')
    dim as single textOffsetX = 0.0f       '' Offset X to next character to draw

    dim as single scaleFactor = fontSize/fnt.baseSize     '' Character rectangle scaling factor

    '' Word/character wrapping mechanism variables
    enum
        MEASURE_STATE = 0
        DRAW_STATE = 1
    end enum

    dim as long state = iif(wordWrap, MEASURE_STATE, DRAW_STATE)

    dim as long startLine = -1         '' Index where to begin drawing (where a line begins)
    dim as long endLine = -1           '' Index where to stop drawing (where a line ends)
    dim as long lastk = -1             '' Holds last value of the character position
    dim as long k = 0

    for i as integer = 0 to length - 1
        '' Get next codepoint from byte string and glyph index in font
        dim as long codepointByteCount = 0
        dim as long codepoint = GetCodepoint(text[i], @codepointByteCount)
        dim as long index = GetGlyphIndex(fnt, codepoint)

        '' NOTE: Normally we exit the decoding sequence as soon as a bad byte is found (and return 0x3f)
        '' but we need to draw all of the bad bytes using the '?' symbol moving one byte
        if codepoint = &h3f then codepointByteCount = 1
        i += (codepointByteCount - 1)

        dim as single glyphWidth = 0
        if codepoint <> asc(!"\n") then
            glyphWidth = iif((fnt.glyphs[index].advanceX = 0), fnt.recs[index].width*scaleFactor, fnt.glyphs[index].advanceX*scaleFactor)

            if i + 1 < length then glyphWidth += spacing
        end if

        '' NOTE: When wordWrap is ON we first measure how much of the text we can draw before going outside of the rec container
        '' We store this info in startLine and endLine, then we change states, draw the text between those two variables
        '' and change states again and again recursively until the end of the text (or until we get outside of the container).
        '' When wordWrap is OFF we don't need the measure state so we go to the drawing state immediately
        '' and begin drawing on the next line before we can get outside the container.
        if state = MEASURE_STATE then
            '' TODO: There are multiple types of spaces in UNICODE, maybe it's a good idea to add support for more
            '' Ref: http:''jkorpela.fi/chars/spaces.html
            if (codepoint = asc(" ")) or (codepoint = asc(!"\t")) or (codepoint = asc(!"\n")) then endLine = i

            if (textOffsetX + glyphWidth) > rec.width then
                endLine = iif(endLine < 1, i, endLine)
                if i = endLine then endLine -= codepointByteCount
                if (startLine + codepointByteCount) = endLine then endLine = (i - codepointByteCount)

                state = DRAW_STATE
            elseif (i + 1) = length then
                endLine = i
                state =  DRAW_STATE
            elseif codepoint = asc(!"\n") then
                state = DRAW_STATE
            end if

            if state = DRAW_STATE then
                textOffsetX = 0
                i = startLine
                glyphWidth = 0

                '' Save character position when we switch states
                dim as long tmp = lastk
                lastk = k - 1
                k = tmp
            end if
        else
            if codepoint = asc(!"\n") then
                if not wordWrap then
                    textOffsetY += (fnt.baseSize + fnt.baseSize/2)*scaleFactor
                    textOffsetX = 0
                end if
            else
                if not(wordWrap) andalso ((textOffsetX + glyphWidth) > rec.width) then
                    textOffsetY += (fnt.baseSize + fnt.baseSize/2)*scaleFactor
                    textOffsetX = 0
                end if

                '' When text overflows rectangle height limit, just stop drawing
                if (textOffsetY + fnt.baseSize*scaleFactor) > rec.height then exit for

                '' Draw selection background
                dim as boolean isGlyphSelected = false
                if (selectStart >= 0) and (k >= selectStart) and (k < (selectStart + selectLength)) then
                    DrawRectangleRec(Rectangle(rec.x + textOffsetX - 1, rec.y + textOffsetY, glyphWidth, fnt.baseSize*scaleFactor), selectBackTint)
                    isGlyphSelected = true
                end if

                '' Draw current character glyph
                if (codepoint <> asc(" ")) and (codepoint <> asc(!"\t")) then
                    DrawTextCodepoint(fnt, codepoint, Vector2(rec.x + textOffsetX, rec.y + textOffsetY), fontSize, iif(isGlyphSelected, selectTint, tint))
                end if
            end if

            if wordWrap and (i = endLine) then
                textOffsetY += (fnt.baseSize + fnt.baseSize/2)*scaleFactor
                textOffsetX = 0
                startLine = endLine
                endLine = -1
                glyphWidth = 0
                selectStart += lastk - k
                k = lastk

                state = MEASURE_STATE
            end if
        end if

        textOffsetX += glyphWidth
        k += 1
    next
end sub