// Copyright (C) 2021 by tspike (github.com/tspike2k)
//
// Permission to use, copy, modify, and/or distribute this software for any purpose with or without fee is hereby granted.
//
// THE SOFTWARE IS PROVIDED "AS IS" AND THE AUTHOR DISCLAIMS ALL WARRANTIES WITH REGARD TO THIS SOFTWARE INCLUDING ALL IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS. IN NO EVENT SHALL THE AUTHOR BE LIABLE FOR ANY SPECIAL, DIRECT, INDIRECT, OR CONSEQUENTIAL DAMAGES OR ANY DAMAGES WHATSOEVER RESULTING FROM LOSS OF USE, DATA OR PROFITS, WHETHER IN AN ACTION OF CONTRACT, NEGLIGENCE OR OTHER TORTIOUS ACTION, ARISING OUT OF OR IN CONNECTION WITH THE USE OR PERFORMANCE OF THIS SOFTWARE.

/+
DESCRIPTION:

An attempt at making a simple, reusable, stub function. Based on a discussion from this thread:
https://forum.dlang.org/thread/oxtlstdenjqrjoqhkqfi@forum.dlang.org?page=1
+/

version(none)
{
    void printStuff(string stuff)
    {    
        import core.stdc.stdio;
        printf("%s", stuff.ptr);    
    }   
}
else
{
    pragma(inline, true) void stubFunction(Args...)(Args args) {};
    alias printStuff = stubFunction;
}

void main()
{
    printStuff("printing!\n");
}