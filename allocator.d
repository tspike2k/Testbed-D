// Copyright (C) 2021 tspike (github.com/tspike2k)
//
// Permission to use, copy, modify, and/or distribute this software for any purpose with or without fee is hereby granted.
//
// THE SOFTWARE IS PROVIDED "AS IS" AND THE AUTHOR DISCLAIMS ALL WARRANTIES WITH REGARD TO THIS SOFTWARE INCLUDING ALL IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS. IN NO EVENT SHALL THE AUTHOR BE LIABLE FOR ANY SPECIAL, DIRECT, INDIRECT, OR CONSEQUENTIAL DAMAGES OR ANY DAMAGES WHATSOEVER RESULTING FROM LOSS OF USE, DATA OR PROFITS, WHETHER IN AN ACTION OF CONTRACT, NEGLIGENCE OR OTHER TORTIOUS ACTION, ARISING OUT OF OR IN CONNECTION WITH THE USE OR PERFORMANCE OF THIS SOFTWARE.

/+
DESCRIPTION:

An example of how to create a simple allocator "wrapper" type. Using the power of delgates, we can pass pointers to struct member functions WITH their instance data.
In other words, delegates allow us to store callbacks to the member functions of struct instances. This gives us the ability to generated callbacks to any data types
with an allocation method so long as the signature is what we expect. We can pass these callbacks to functions or store them in containers without the need to pass the
concrete allocator type as a template parameter.
+/

@nogc nothrow:
import core.stdc.string : memcpy, memset;
import core.stdc.stdlib : malloc, calloc, free;
import core.stdc.stdio;
import std.traits;

enum defaultAlignment = size_t.sizeof;

mixin template AllocatorCommon()
{
    T[] allocArray(T)(ulong count, size_t alignment = defaultAlignment)
    {
        assert(count > 0);
        T* mem = cast(T*)alloc(T.sizeof*count, alignment);
        T[] result = mem[0 .. count];
        return result;
    }

    T* allocType(T)(size_t alignment = defaultAlignment)
    {
        T* result = cast(T*)alloc(T.sizeof, alignment);

        return result;
    }
}

struct Allocator
{
    @nogc nothrow:
    mixin AllocatorCommon;

    void* delegate(size_t size, size_t alignment = defaultAlignment) alloc;
    //void delegate()  free;
    // TODO: realloc?
}

struct BumpAllocator
{
    nothrow @nogc:
    mixin AllocatorCommon;

    struct BumpAllocatorFrame
    {
        private ulong memoryRollbackLocation;
        BumpAllocatorFrame* nextFrame;
    }

    void* base;
    ulong length;
    ulong used;
    BumpAllocatorFrame* lastFrame;

    void* alloc(size_t size, size_t alignment = defaultAlignment)
    {
        assert(size > 0);
        assert(alignment > 0);

        size_t alignPush = alignment - cast(size_t)(this.base + this.used) & (alignment - 1);
        auto totalSize = size + alignPush;

        assert(this.used + totalSize < this.length);
        assert(this.used + totalSize > this.used);

        void* result = this.base + this.used + alignPush;
        memset(result, 0, totalSize);
        this.used += totalSize;

        return result;
    }

    void pushFrame()
    {
        auto memRestore = this.used;
        BumpAllocatorFrame* topFrame = this.allocType!BumpAllocatorFrame;

        topFrame.memoryRollbackLocation = memRestore;
        topFrame.nextFrame = this.lastFrame;
        this.lastFrame = topFrame;
    }

    void popFrame()
    {
        assert(this.lastFrame);
        this.used = this.lastFrame.memoryRollbackLocation;
        this.lastFrame = this.lastFrame.nextFrame;
    }

    void clear()
    {
        this.used = 0;
        this.lastFrame = null;
    }

    Allocator wrap()
    {
        Allocator result;
        result.alloc = &this.alloc;
        return result;
    }
}

struct LinkedList(T)
{
    Allocator allocator;
    Item* first;
    Item* last;
    struct Item
    {
        T val;
        Item* next;
    }

    this(Allocator a)
    {
        allocator = a;
    }

    Item* push()
    {
        auto newItem = allocator.allocType!Item;
        if(last) last.next = newItem;
        if(!first) first = newItem;
        last = newItem;
        return newItem;
    }
}


int[] genNumbers(Allocator allocator, uint count)
{
    auto result = allocator.allocArray!int(count);
    foreach(i, ref n; result)
    {
        n = cast(int)i;
    }
    return result;
}

void main()
{
    auto memSize = 4096;

    BumpAllocator allocatorA;
    allocatorA.base = malloc(memSize);
    allocatorA.length = memSize;

    BumpAllocator allocatorB;
    allocatorB.base = malloc(memSize);
    allocatorB.length = memSize;

    auto numbers = genNumbers(allocatorA.wrap(), 12);
    printf("allocatorA.used: %lu\n", allocatorA.used);
    printf("numbers: [");
    foreach(ref n; numbers)
    {
        printf("%d, ", n);
    }
    printf("]\n");

    auto ll = LinkedList!(int)(allocatorB.wrap);
    foreach(i; 0 .. 12)
    {
        auto item = ll.push();
        item.val = cast(int)i;
    }

    printf("allocatorB.used: %lu\n", allocatorB.used);
    printf("linked list: [");
    auto item = ll.first;

    while(item)
    {
        printf("%d, ", item.val);

        item = item.next;
    }
    printf("]\n");
}
