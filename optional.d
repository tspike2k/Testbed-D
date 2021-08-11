// Copyright (C) 2021 by tspike (github.com/tspike2k)
//
// Permission to use, copy, modify, and/or distribute this software for any purpose with or without fee is hereby granted.
//
// THE SOFTWARE IS PROVIDED "AS IS" AND THE AUTHOR DISCLAIMS ALL WARRANTIES WITH REGARD TO THIS SOFTWARE INCLUDING ALL IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS. IN NO EVENT SHALL THE AUTHOR BE LIABLE FOR ANY SPECIAL, DIRECT, INDIRECT, OR CONSEQUENTIAL DAMAGES OR ANY DAMAGES WHATSOEVER RESULTING FROM LOSS OF USE, DATA OR PROFITS, WHETHER IN AN ACTION OF CONTRACT, NEGLIGENCE OR OTHER TORTIOUS ACTION, ARISING OUT OF OR IN CONNECTION WITH THE USE OR PERFORMANCE OF THIS SOFTWARE.

/+
DESCRIPTION:

A very simple example of how to make something like std::optional in D.
+/

struct Optional(T)
{
    private T value;
    bool isSet;
    
    ref T get()
    {
        assert(isSet);
        return value;
    }
    
    void opAssign(in T t)
    {
        value = t;
        isSet = true;
    }
}

Optional!int testFunc()
{
    Optional!int result;
    //result = 42;
    return result;
}

void main()
{
    import core.stdc.stdio;
    auto r = testFunc();
    if(r.isSet)
    {
        int n = r.get();
        printf("%d\n", n);    
    }
    else
    {
        printf("testFunc result was not set.\n");
    }
}