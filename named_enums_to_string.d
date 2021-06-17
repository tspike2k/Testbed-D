// Permission to use, copy, modify, and/or distribute this software for any purpose with or without fee is hereby granted.
//
// THE SOFTWARE IS PROVIDED "AS IS" AND THE AUTHOR DISCLAIMS ALL WARRANTIES WITH REGARD TO THIS SOFTWARE INCLUDING ALL IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS. IN NO EVENT SHALL THE AUTHOR BE LIABLE FOR ANY SPECIAL, DIRECT, INDIRECT, OR CONSEQUENTIAL DAMAGES OR ANY DAMAGES WHATSOEVER RESULTING FROM LOSS OF USE, DATA OR PROFITS, WHETHER IN AN ACTION OF CONTRACT, NEGLIGENCE OR OTHER TORTIOUS ACTION, ARISING OUT OF OR IN CONNECTION WITH THE USE OR PERFORMANCE OF THIS SOFTWARE.

/+
DESCRIPTION:

This demonstrates the ability to pass in the value of an enum and get the identifier for the specific enum value in return.
+/

import std.traits: EnumMembers;

enum EnumTypeA
{
    a = 52,
    b = 99,
    c = 35,
}

enum EnumTypeB
{
    Apples,
    Oranges,
    Pears,
}

string enumString(T)(T t)
if(is(T == enum))
{
    // NOTE: There is a way to do this for enum values known at compile-time:
    // https://forum.dlang.org/thread/rjmp61$o70$1@digitalmars.com
    import std.traits : EnumMembers;
    
    alias members = EnumMembers!T;
    outer: final switch(t)
    {
        static foreach (i, member; members)
        {
            case member:
            {
                return __traits(identifier, members[i]);
            } break outer;
        }
    }

    // NOTE: It shouldn't be possible to ever reach this point.
    assert(0, "Unable to find enum member for type " ~ T.stringof ~ ".");
    return "";
}

void main()
{
    import core.stdc.stdio;
    EnumTypeA t1 = EnumTypeA.c;
    printf("%s = %u\n", enumString(t1).ptr, t1);
  
    auto t2 = EnumTypeA.b;
    printf("%s = %u\n", enumString(t2).ptr, t2);
  
    with(EnumTypeB)
    {
        auto t3 = Oranges;
        printf("%s = %u\n", enumString(t3).ptr, t3);
    }
}