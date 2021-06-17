// Copyright (C) 2021 by tspike (github.com/tspike2k)
//
// Permission to use, copy, modify, and/or distribute this software for any purpose with or without fee is hereby granted.
//
// THE SOFTWARE IS PROVIDED "AS IS" AND THE AUTHOR DISCLAIMS ALL WARRANTIES WITH REGARD TO THIS SOFTWARE INCLUDING ALL IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS. IN NO EVENT SHALL THE AUTHOR BE LIABLE FOR ANY SPECIAL, DIRECT, INDIRECT, OR CONSEQUENTIAL DAMAGES OR ANY DAMAGES WHATSOEVER RESULTING FROM LOSS OF USE, DATA OR PROFITS, WHETHER IN AN ACTION OF CONTRACT, NEGLIGENCE OR OTHER TORTIOUS ACTION, ARISING OUT OF OR IN CONNECTION WITH THE USE OR PERFORMANCE OF THIS SOFTWARE.

/+
DESCRIPTION:

A quick test to see how TypeInfo (runtime time information) works in D.

Note that you cannot compare TypeInfo objects in a @nogc block as
runtime type information in D requires the use of the garbage collector.
+/

import std.stdio;

struct Position
{
    float x, y;
};

struct Cat
{
    Position pos;
    int furColor;
    bool striped;
    
    alias pos this;
};

struct Dog
{
    Position pos;
    int barkVolume;
    
    alias pos this;
}

void main()
{
    Cat tim;
    Cat alice;
    
    TypeInfo typeTim   = typeid(tim);
    TypeInfo typeAlice = typeid(alice);
    if (typeTim == typeAlice)
    {
        printf("Tim and Alice are both cats!\n");
    }
    
    Dog bruno;
    TypeInfo typeBruno = typeid(bruno);
    if (typeBruno != typeAlice && typeBruno != typeTim)
    {
        printf("Bruno is not a cat like Tim and Alice\n");
    }
    
    typeof(bruno) rex;
    rex.x = 32;
    rex.y = 45;
    if (typeBruno == typeid(rex))
    {
        printf("Rex is a dog like Bruno\n");
    }
}