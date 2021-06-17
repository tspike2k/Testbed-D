// Copyright (C) 2021 by tspike (github.com/tspike2k)
//
// Permission to use, copy, modify, and/or distribute this software for any purpose with or without fee is hereby granted.
//
// THE SOFTWARE IS PROVIDED "AS IS" AND THE AUTHOR DISCLAIMS ALL WARRANTIES WITH REGARD TO THIS SOFTWARE INCLUDING ALL IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS. IN NO EVENT SHALL THE AUTHOR BE LIABLE FOR ANY SPECIAL, DIRECT, INDIRECT, OR CONSEQUENTIAL DAMAGES OR ANY DAMAGES WHATSOEVER RESULTING FROM LOSS OF USE, DATA OR PROFITS, WHETHER IN AN ACTION OF CONTRACT, NEGLIGENCE OR OTHER TORTIOUS ACTION, ARISING OUT OF OR IN CONNECTION WITH THE USE OR PERFORMANCE OF THIS SOFTWARE.

/+
DESCRIPTION:

A very simple demonstration of how one can approach serialization/deserialization in D. Note this only handles structs containing primitive types and arrays of primitives.
Handling pointers, dynamic arrays, unions, and anonymous unions would be a bit trickier.
+/

enum NoSerialize;

import core.stdc.stdio;

struct Vect2
{
    float x, y;
}

struct Entity
{
    @NoSerialize const(char)[] name;
    ulong id;
    Vect2 pos;
    uint[3] equipment;
}

nothrow @nogc void serialize(T)(FILE* file, in T t)
{
    import std.traits;
    static if(is(T == struct))
    {
        foreach(i, ref member; t.tupleof)
        {
            static if(!hasUDA!(t.tupleof[i], NoSerialize))
            {
                serialize(file, member);
            }
        }
    }
    else static if(isStaticArray!T && isScalarType!(typeof(t[0])))
    {
        fwrite(t.ptr, t[0].sizeof*t.length, 1, file);   
    }
    else static if(isScalarType!T)
    {
        fwrite(&t, t.sizeof, 1, file);
    }
    else
    {
        static assert(0, "Unable to serialize type " ~ T.stringof ~ ".");
    }
}

nothrow @nogc void deserialize(T)(FILE* file, ref T t)
{
    import std.traits;
    static if(is(T == struct))
    {
        foreach(i, ref member; t.tupleof)
        {
            static if(!hasUDA!(t.tupleof[i], NoSerialize))
            {
                deserialize(file, member);
            }
        }
    }
    else static if(isStaticArray!T && isScalarType!(typeof(t[0])))
    {
        fread(t.ptr, t[0].sizeof*t.length, 1, file);   
    }
    else static if(isScalarType!T)
    {
        fread(&t, t.sizeof, 1, file);
    }
    else
    {
        static assert(0, "Unable to deserialize type " ~ T.stringof ~ ".");
    }
}

void main()
{
    import std.stdio;
    Entity e1;
    e1.name = "Jack";
    e1.id = 1;
    e1.pos = Vect2(3, 4);
    e1.equipment = [9, 8, 2];
    
    writeln("Before serializing: ", e1);
    
    auto file = fopen("test.dat", "w+b");
    if(file)
    {
        scope(exit) fclose(file);
        serialize(file, e1);
        e1 = Entity.init;
        fseek(file, 0, SEEK_SET);
        deserialize(file, e1);
        writeln("After deserializing: ", e1);
    }
}
