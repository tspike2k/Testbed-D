// Copyright (C) 2021 by tspike (github.com/tspike2k)
//
// Permission to use, copy, modify, and/or distribute this software for any purpose with or without fee is hereby granted.
//
// THE SOFTWARE IS PROVIDED "AS IS" AND THE AUTHOR DISCLAIMS ALL WARRANTIES WITH REGARD TO THIS SOFTWARE INCLUDING ALL IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS. IN NO EVENT SHALL THE AUTHOR BE LIABLE FOR ANY SPECIAL, DIRECT, INDIRECT, OR CONSEQUENTIAL DAMAGES OR ANY DAMAGES WHATSOEVER RESULTING FROM LOSS OF USE, DATA OR PROFITS, WHETHER IN AN ACTION OF CONTRACT, NEGLIGENCE OR OTHER TORTIOUS ACTION, ARISING OUT OF OR IN CONNECTION WITH THE USE OR PERFORMANCE OF THIS SOFTWARE.

/+
DESCRIPTION:

This is a simple example of how to use a foreach loop to iterate over the items in a container.
The key to making this work is to overload the opSlice operator since a foreach loop will try
to take a slice of whatever data type you pass to it.
+/

struct FixedArray(T, uint length)
{
    T[length] elements;
    size_t count;

    void push(T item)
    {
        elements[count] = item;
        count++;
    }

    T[] opSlice()
    {
        return elements[0 .. count];
    }
}

void main()
{
    FixedArray!(int, 32) ints;
    ints.push(0);
    ints.push(1);
    ints.push(2);
    ints.push(3);

    import core.stdc.stdio;

    printf("[");
    foreach(ref i; ints)
    {
        printf("%d, ", i);
    }
    printf("]\n");
}
