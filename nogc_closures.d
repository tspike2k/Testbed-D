// Copyright (C) 2021 tspike (github.com/tspike2k)
//
// Permission to use, copy, modify, and/or distribute this software for any purpose with or without fee is hereby granted.
//
// THE SOFTWARE IS PROVIDED "AS IS" AND THE AUTHOR DISCLAIMS ALL WARRANTIES WITH REGARD TO THIS SOFTWARE INCLUDING ALL IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS. IN NO EVENT SHALL THE AUTHOR BE LIABLE FOR ANY SPECIAL, DIRECT, INDIRECT, OR CONSEQUENTIAL DAMAGES OR ANY DAMAGES WHATSOEVER RESULTING FROM LOSS OF USE, DATA OR PROFITS, WHETHER IN AN ACTION OF CONTRACT, NEGLIGENCE OR OTHER TORTIOUS ACTION, ARISING OUT OF OR IN CONNECTION WITH THE USE OR PERFORMANCE OF THIS SOFTWARE.

/+
DESCRIPTION:

An attemp to make a NOGC version of closures in D. Inspired by the following forum post:
https://forum.dlang.org/post/equwciamxgenjlqssllp@forum.dlang.org

Here's another interesting topic to look into:
https://forum.dlang.org/post/elcxmqurjwqdkztbnccj@forum.dlang.org
+/

// NOTE: This all works, but it IS a little combersome. We need to write code that takes into account the closure members are 
// pointers. For example, we need to write "*x = 1" instead of "x = 1". This could cause serious bugs, so it's probably
// best not to do anything like this in production code.

nothrow @nogc:

template Closure(Args...)
if(Args.length > 1 && is(typeof(Args[$-1]) == string))
{
    struct ClosureT
    {
        static foreach(a; Args[0 .. $-1])
        {
            mixin(typeof(a).stringof ~ "* " ~ __traits(identifier, a) ~ ";\n");
        }
        
        void opCall()
        {
            mixin(Args[$-1]);
        }
    }
    
    ClosureT Closure()
    {
        import std.conv;
        ClosureT result = void;
        static foreach(i, a; Args[0 .. $-1])
        {
            mixin("result." ~ __traits(identifier, a) ~ " = &Args[" ~ to!string(i) ~"]" ~ ";\n");
        }
    
        return result;
    }
}

// NOTE: Honestly, writing a struct as-needed is probably a cleaner solution than trying to make an all-in-one 
// template for this sort of thing... At least this way the types of each struct member are quite obvious.

struct Test
{
    int* x;
    
    nothrow @nogc void opCall()
    {
        *x += 42;
    }
}

void foo(alias fn)()
{
    fn();
}

void main()
{
    import core.stdc.stdio;

    int x = 4;
    auto c = Closure!(x, q{*x += 42; *x = *x+99;});
    c();
    printf("%d\n", x);
    foo!c();
    printf("%d\n", x);
    
    Test test = {&x}; // NOTE: Since we defined opCall on Test, we can't call it's constructor. We can, however, use this constructor syntax instead.
    foo!(test);
    printf("%d\n", x);
}