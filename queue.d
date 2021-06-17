// Permission to use, copy, modify, and/or distribute this software for any purpose with or without fee is hereby granted.
//
// THE SOFTWARE IS PROVIDED "AS IS" AND THE AUTHOR DISCLAIMS ALL WARRANTIES WITH REGARD TO THIS SOFTWARE INCLUDING ALL IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS. IN NO EVENT SHALL THE AUTHOR BE LIABLE FOR ANY SPECIAL, DIRECT, INDIRECT, OR CONSEQUENTIAL DAMAGES OR ANY DAMAGES WHATSOEVER RESULTING FROM LOSS OF USE, DATA OR PROFITS, WHETHER IN AN ACTION OF CONTRACT, NEGLIGENCE OR OTHER TORTIOUS ACTION, ARISING OUT OF OR IN CONNECTION WITH THE USE OR PERFORMANCE OF THIS SOFTWARE.

/+
DESCRIPTION:

A simple queue implementation.
+/

struct Queue(T)
{
    uint back;
    uint front;
    uint count;
    T[] elements;
    
    ref T push()
    {
        assert(count < elements.length);
        auto resultIndex = back;
        back++;
        if(back >= elements.length) back = 0;
        
        count++;
        
        return elements[resultIndex];
    }
    
    ref T pop()
    {
        assert(count > 0);
        size_t prevFront = front;
        count--;
        front++;
        
        if(front >= elements.length) front = 0;
        
        return elements[prevFront];
    }
    
    ref T top()
    {
        return elements[front];
    }
    
    uint capacity() const
    {
        return cast(uint)elements.length;
    }
    
    bool empty()
    {
        return count == 0;
    }
}

void main()
{
    import std.stdio;
    
    int[3] qMemory;
    Queue!(int) q;
    q.elements = qMemory[];
    
    q.push = 1;
    q.push = 2;
    q.push = 3;
    
    writeln(q.pop());
    writeln(q.pop());
    
    q.push = 4;
    q.push = 5;
    writeln(q.pop());
    writeln(q.pop());
    writeln(q.pop());
}