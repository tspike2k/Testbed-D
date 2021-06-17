// Copyright (C) 2021 by tspike (github.com/tspike2k)
//
// Permission to use, copy, modify, and/or distribute this software for any purpose with or without fee is hereby granted.
//
// THE SOFTWARE IS PROVIDED "AS IS" AND THE AUTHOR DISCLAIMS ALL WARRANTIES WITH REGARD TO THIS SOFTWARE INCLUDING ALL IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS. IN NO EVENT SHALL THE AUTHOR BE LIABLE FOR ANY SPECIAL, DIRECT, INDIRECT, OR CONSEQUENTIAL DAMAGES OR ANY DAMAGES WHATSOEVER RESULTING FROM LOSS OF USE, DATA OR PROFITS, WHETHER IN AN ACTION OF CONTRACT, NEGLIGENCE OR OTHER TORTIOUS ACTION, ARISING OUT OF OR IN CONNECTION WITH THE USE OR PERFORMANCE OF THIS SOFTWARE.

/+
DESCRIPTION:

A demonstration of how to write an iterator in D for containers that are more than just a wrapper over a flat array. 
In D, the foreach loop can iterate over a struct if one of the following conditions are met:
a) The struct provides an opApply operator (this uses a delegate which requires the GC)
b) The struct implements the opSlice operator to return a Range (in this case an InputRange)

See the following for more information on this topic:
http://ddili.org/ders/d.en/foreach_opapply.html
http://ddili.org/ders/d.en/ranges.html
http://ddili.org/ders/d.en/ranges_more.html
+/

@nogc nothrow:

struct IntBlock
{
    nothrow @nogc:

    int[4] ints;
    IntBlock* next;

    struct Iterator
    {
        nothrow @nogc:

        IntBlock* block;
        size_t index;

        bool empty() const
        {
            return !block;
        }

        void popFront()
        {
            ++index;
            if(index >= ints.length)
            {
                index = 0;
                block = block.next;
            }
        }

        ref int front()
        {
            return block.ints[index];
        }
    }

    Iterator opSlice()
    {
        Iterator i = void;
        i.block = &this;
        i.index = 0;
        return i;
    }

    /*
    int opApply(scope int delegate(ref int) dg)
    {
        int result = 0;

        IntBlock* block = &this;
        outer: while(block)
        {
            foreach(ref num; block.ints)
            {
                result = dg(num);
                if(result) break outer;
            }

            block = block.next;
        }

        return result;
    }
    */
}

void main()
{
    import core.stdc.stdlib;

    IntBlock ib;
    ib.next = cast(IntBlock*)malloc(IntBlock.sizeof);
    ib.next.next = null;

    int i = 0;
    foreach(ref num; ib)
    {
        num = i;
        i++;
    }

    foreach(num; ib)
    {
        import core.stdc.stdio;
        printf("%d\n", num);
    }

    foreach(ref num; ib)
    {
        assert(&num == &ib.ints[0]);
        break;
    }
}
