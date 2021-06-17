// Copyright (C) 2021 by tspike (github.com/tspike2k)
//
// Permission to use, copy, modify, and/or distribute this software for any purpose with or without fee is hereby granted.
//
// THE SOFTWARE IS PROVIDED "AS IS" AND THE AUTHOR DISCLAIMS ALL WARRANTIES WITH REGARD TO THIS SOFTWARE INCLUDING ALL IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS. IN NO EVENT SHALL THE AUTHOR BE LIABLE FOR ANY SPECIAL, DIRECT, INDIRECT, OR CONSEQUENTIAL DAMAGES OR ANY DAMAGES WHATSOEVER RESULTING FROM LOSS OF USE, DATA OR PROFITS, WHETHER IN AN ACTION OF CONTRACT, NEGLIGENCE OR OTHER TORTIOUS ACTION, ARISING OUT OF OR IN CONNECTION WITH THE USE OR PERFORMANCE OF THIS SOFTWARE.

/+
DESCRIPTION:

An overview of the integer types used by D and their C/C++ equivalents on different architectures.
Based on this page:
https://wiki.dlang.org/D_binding_for_C
+/

version(X86)
{
    alias c_long_double = real;
    alias c_unsigned_long_long = ulong;
    alias c_long_long = long;
    alias c_unsigned_long = uint;
    alias c_long = int;
    alias c_uint = uint;
    alias c_int = int;
    alias c_ushort = ushort;
    alias c_char = byte;
    alias c_uchar = ubyte;
}

version(X86_64)
{
    alias c_long_double = real;
    alias c_unsigned_long_long = ulong;
    alias c_long_long = long;
    
    version(Windows)
    {
        alias c_unsigned_long = uint;
        alias c_long = int;    
    }
    else version(linux)
    {
        alias c_unsigned_long = ulong;
        alias c_long = long;   
    }
    alias c_uint = uint;
    alias c_int = int;
    alias c_ushort = ushort;
    alias c_char = byte;
    alias c_uchar = ubyte;
}