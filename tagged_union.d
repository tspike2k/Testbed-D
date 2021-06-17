// Copyright (C) 2021 by tspike (github.com/tspike2k)
//
// Permission to use, copy, modify, and/or distribute this software for any purpose with or without fee is hereby granted.
//
// THE SOFTWARE IS PROVIDED "AS IS" AND THE AUTHOR DISCLAIMS ALL WARRANTIES WITH REGARD TO THIS SOFTWARE INCLUDING ALL IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS. IN NO EVENT SHALL THE AUTHOR BE LIABLE FOR ANY SPECIAL, DIRECT, INDIRECT, OR CONSEQUENTIAL DAMAGES OR ANY DAMAGES WHATSOEVER RESULTING FROM LOSS OF USE, DATA OR PROFITS, WHETHER IN AN ACTION OF CONTRACT, NEGLIGENCE OR OTHER TORTIOUS ACTION, ARISING OUT OF OR IN CONNECTION WITH THE USE OR PERFORMANCE OF THIS SOFTWARE.

/+
DESCRIPTION:

A simple implementation of a tagged union in D. The types the tagged union can hold are determined by template arguments.
The "set" method is used to store a value in the tagged union so long as the union has been configured to support data
of that type. Once the "set" method is called, the union is tagged as holding data of the supplied type. The "get" method
is used to retrieve data from the union. If the union is not currently tagged as holding data of the type requested by the
"get" method, an assertion is fired. The isType method is used to test which data type the union is tagged as storing.
Immutable instances are also supported!
+/

nothrow @nogc:

import std.traits : Unqual;
import std.meta: NoDuplicates;

uint indexOfType(T, Types...)()
if(Types.length > 0)
{
    uint result = uint.max;

    static foreach(i; 0 .. Types.length)
    {
        if(is(Types[i] == T))
        {
            result = i;
        }
    }
    
    return result;
}

struct TaggedUnion(Types...)
if(Types.length > 0 && is(NoDuplicates!Types == Types))
{
    union Members
    {
        static foreach(i; 0 .. Types.length)
        {
            mixin(Types[i].stringof ~ " m_" ~ i.stringof ~ ";");
        }
    }

    alias types = Types;
    uint typeIndex = uint.max;
    private Members members;
    
    nothrow @nogc:
    
    static foreach(type; Types)
    {
        this(type t)
        {
            set(t);
        }
    }
    
    inout(T) get(T)() inout
    {
        static assert(indexOfType!(T, Types) != uint.max, "Type " ~ T.stringof ~ " is not a valid type for " ~ typeof(this).stringof);
        
        foreach(ref m; members.tupleof)
        {
            static if(is(Unqual!(typeof(m)) == T))
            {
                assert(isType!T, Unqual!(typeof(this)).stringof ~ " is not currently tagged as a " ~ T.stringof ~ ".");
                return m;
            }
        }
    }
    
    void set(T)(in T t)
    {   
        enum index = indexOfType!(T, Types);
        static assert(index != uint.max, "Type " ~ T.stringof ~ " is not a valid type for " ~ typeof(this).stringof);
        typeIndex = index;
        
        foreach(ref m; members.tupleof)
        {
            static if(is(typeof(m) == T))
            {
                m = t;
            }
        }
    }
    
    bool isType(T)() const
    {
        enum index = indexOfType!(T, Types);
        return typeIndex == index;
    }
}

extern(C) int main()
{
    import core.stdc.stdio;
    
    TaggedUnion!(int, string) test;
    test.set("Abba");
    printf("%s\n", test.get!(string).ptr);
    assert(!test.isType!int);
    assert(test.isType!string);
    assert(!test.isType!ulong);
    test.set(14);
    assert(test.isType!int);
    assert(!test.isType!string);
    assert(!test.isType!ulong);
    
    // NOTE: Any of the following three lines will cause an error, as desired:
    //auto s = test.get!string;
    //test.set('c');
    //auto a = test.get!char;
    
    static foreach(type; test.types)
    {
        if(test.isType!type)
        {
            auto val = test.get!type;
            static if(is(type == string))
            {
                printf("%s\n", val.ptr);
            }
            else static if(is(type == int))
            {
                printf("%d\n", val);
            }
        }
    }

    alias TU_Test = TaggedUnion!(int, string);
    immutable TU_Test const_test = TU_Test("Test string");
    //immutable TU_Test const_test = TU_Test(192);
    static foreach(type; const_test.types)
    {
        if(const_test.isType!type)
        {
            auto val = const_test.get!type;
            static if(is(type == string))
            {
                printf("%s\n", val.ptr);
            }
            else static if(is(type == int))
            {
                printf("%d\n", val);
            }
        }
    }
    
    // NOTE: More verbose, but more efficient means of processing members
    outer: switch(const_test.typeIndex)
    {
        static foreach(i, type; const_test.types)
        {
            case i:
            {
                auto val = const_test.get!type;
                static if(is(type == string))
                {
                    printf("%s\n", val.ptr);
                }
                else static if(is(type == int))
                {
                    printf("%d\n", val);
                }
            } break outer;
        }
        
        default: assert(0); break;
    }
    
    return 0;
}