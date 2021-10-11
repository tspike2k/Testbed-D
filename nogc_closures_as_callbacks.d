// Copyright (C) 2021 tspike (github.com/tspike2k)
//
// Permission to use, copy, modify, and/or distribute this software for any purpose with or without fee is hereby granted.
//
// THE SOFTWARE IS PROVIDED "AS IS" AND THE AUTHOR DISCLAIMS ALL WARRANTIES WITH REGARD TO THIS SOFTWARE INCLUDING ALL IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS. IN NO EVENT SHALL THE AUTHOR BE LIABLE FOR ANY SPECIAL, DIRECT, INDIRECT, OR CONSEQUENTIAL DAMAGES OR ANY DAMAGES WHATSOEVER RESULTING FROM LOSS OF USE, DATA OR PROFITS, WHETHER IN AN ACTION OF CONTRACT, NEGLIGENCE OR OTHER TORTIOUS ACTION, ARISING OUT OF OR IN CONNECTION WITH THE USE OR PERFORMANCE OF THIS SOFTWARE.

/+
DESCRIPTION:

A small demonstration of using a struct as a replacement for a closure and storing it as a delegate to call at a later date.
Since the delegate take a pointer to the stack frame, I worried that having "n" go out of scope would cause undefined behavior.
Everything seems to work despite this, but I do wonder why. Needless to say, beware as thar be dragons here! Do NOT use code like
this unless you really know what you're doing.
+/
import core.stdc.stdio;

@nogc nothrow:

struct Test
{
    @nogc nothrow:

    char[256] data;
    void delegate() fn;

    void update()
    {
        assert(data[0] == '0');
        this.fn();
    }
}

void main()
{
    @nogc nothrow void delegate() fn;

    struct Closure
    {
        @nogc nothrow:

        int* n;
        void opCall()
        {
            (*n)++;
            printf("%d\n", *(n));
        }
    }

    {
        int n = 0;

        Closure c;
        c.n = &n;
        fn = &c.opCall;
    }

    Test test;
    test.data[] = '0';
    test.fn = fn;
    test.update();
    test.update();
}
