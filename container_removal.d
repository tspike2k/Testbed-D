// Copyright (C) 2021 by tspike (github.com/tspike2k)
//
// Permission to use, copy, modify, and/or distribute this software for any purpose with or without fee is hereby granted.
//
// THE SOFTWARE IS PROVIDED "AS IS" AND THE AUTHOR DISCLAIMS ALL WARRANTIES WITH REGARD TO THIS SOFTWARE INCLUDING ALL IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS. IN NO EVENT SHALL THE AUTHOR BE LIABLE FOR ANY SPECIAL, DIRECT, INDIRECT, OR CONSEQUENTIAL DAMAGES OR ANY DAMAGES WHATSOEVER RESULTING FROM LOSS OF USE, DATA OR PROFITS, WHETHER IN AN ACTION OF CONTRACT, NEGLIGENCE OR OTHER TORTIOUS ACTION, ARISING OUT OF OR IN CONNECTION WITH THE USE OR PERFORMANCE OF THIS SOFTWARE.

/+
DESCRIPTION:

Removing items directly from a container while iterating over the items it holds will usually have undesirable results. To get the same effect,
the common approach is to mark items for removal during the iteration and only remove the items once the iteration has concluded. The strategy
for removing items is different for each container, but there are commonalities. This is an attempt to create a common interface for marking
items in a container for removal and the cleanup process.
+/

import std.stdio;

struct ArrayRemover
{
    // TODO: Right now we're allocating a parallel array that marks which elements should be removed from the source array.
    // If we're only removing a few items, this is a waste of memory, but lookups should be quite fast. We could
    // change this to something like a hash map so we could have sparse storage.
    bool[] toRemove;

    void mark(size_t index)
    {
        toRemove[index] = true;
    }
}

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

    ArrayRemover makeRemover()
    {
        ArrayRemover result = void;
        result.toRemove = new bool[count];
        return result;
    }

    void cleanup(ArrayRemover* remover)
    {
        uint i = 0;
        while(i < count)
        {
            if(remover.toRemove[i])
            {
                count--;
                elements[i] = elements[count];
                remover.toRemove[i] = remover.toRemove[count];
            }
            else
            {
                i++;
            }
        }

        remover.toRemove = null;
    }
}

struct LinkedListRemover
{
    struct Entry
    {
        size_t toRemoveAddress;
        Entry* next;
    }

    Entry* first;
    Entry* last;

    void mark(void* ptr)
    {
        Entry* result = new Entry;
        result.toRemoveAddress = cast(size_t)ptr;
        result.next = null;

        if(!first)
        {
            first = result;
            last = first;
        }
        else
        {
            last.next = result;
            last = result;
        }
    }
}

struct LinkedList(T)
{
    struct Item
    {
        T val;
        Item* next;
        Item* prev;
    }

    Item* first;
    Item* last;

    void push(ref T val)
    {
        Item* result = new Item;
        result.val = val;
        result.next = null;

        if(!first)
        {
            first = result;
            last = first;
        }
        else
        {
            last.next = result;
            result.prev = last;
            last = result;
        }
    }

    struct Range
    {
        Item* current;

        bool empty() const
        {
            return !current;
        }

        void popFront()
        {
            current = current.next;
        }

        Item* front()
        {
            return current;
        }
    }

    Range opSlice()
    {
        Range result;
        result.current = first;
        return result;
    }

    LinkedListRemover makeRemover()
    {
        LinkedListRemover result;
        return result;
    }

    void cleanup(LinkedListRemover* remover)
    {
        auto e = remover.first;
        while(e)
        {
            auto item = cast(Item*)e.toRemoveAddress;
            if(item == first)
            {
                first = first.next;
            }
            else if(item == last)
            {
                last = last.prev;
            }
            else
            {
                item.prev.next = item.next;
            }

            e = e.next;
        }
    }
}

struct FixedArray2(T, uint length)
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

    struct Remover
    {
        FixedArray2!(T, length)* source;
        size_t index;

        bool empty() const
        {
            return index >= source.count;
        }

        ref T next()
        {
            auto i = index;
            index++;
            return source.elements[i];
        }

        auto remove()
        {
            struct Result
            {
                size_t source;
                size_t dest;
            }

            // NOTE: Since next() increments the index for the next iteration, calling remove should remove the previous item from the array
            // and set the current index back to the previous one.

            source.count--;
            Result result = Result(source.count, index - 1);
            source.elements[result.dest] = source.elements[result.source];
            index--;
            return result;
        }
    }

    Remover makeRemover()
    {
        Remover result = void;
        result.source = &this;
        result.index = 0;
        return result;
    }
}

struct LinkedList2(T)
{
    struct Item
    {
        T val;
        Item* next;
        Item* prev;
    }

    Item* first;
    Item* last;

    void push(ref T val)
    {
        Item* result = new Item;
        result.val = val;
        result.next = null;

        if(!first)
        {
            first = result;
            last = first;
        }
        else
        {
            last.next = result;
            result.prev = last;
            last = result;
        }
    }

    struct Range
    {
        Item* current;

        bool empty() const
        {
            return !current;
        }

        void popFront()
        {
            current = current.next;
        }

        Item* front()
        {
            return current;
        }
    }

    Range opSlice()
    {
        Range result;
        result.current = first;
        return result;
    }

    struct Remover
    {
        LinkedList2!T* source;
        Item* item;

        bool empty() const
        {
            return !item;
        }

        Item* next()
        {
            auto result = item;
            item = item.next;
            return result;
        }

        void remove()
        {
            // NOTE: If we weren't using the GC, we'd need to free the node we remove.
            auto toRemove = item.prev;
            if(toRemove == source.first)
            {
                source.first = source.first.next;
            }
            else if(toRemove == source.last)
            {
                source.last = source.last.prev;
            }
            else
            {
                toRemove.prev.next = toRemove.next;
                if(toRemove.next)
                    toRemove.next.prev = toRemove.prev;
            }
        }
    }

    Remover makeRemover()
    {
        Remover result;
        result.item = first;
        result.source = &this;
        return result;
    }
}

void main()
{
    writeln("---Array removal---");

    {
        FixedArray!(int, 12) arr;
        foreach(i; 0 .. arr.elements.length)
        {
            arr.push(cast(int)i);
        }

        writeln("Before: ", arr.elements);

        auto remover = arr.makeRemover();
        foreach(i; 0 .. arr.count)
        {
            auto val = arr.elements[i];
            if(val % 2 == 0)
            {
                remover.mark(i);
            }
        }

        arr.cleanup(&remover);
        writeln("After: ", arr.elements[0 .. arr.count]);
    }
    writeln();

    writeln("---Linked List removal---");
    {
        LinkedList!int list;
        foreach(i; 0 .. 12)
        {
            list.push(i);
        }

        write("Before: [");
        foreach(ref e; list)
        {
            write(e.val, ", ");
        }
        writeln("]");

        auto remover = list.makeRemover;
        foreach(ref e; list)
        {
            if(e.val % 2 == 0)
            {
                remover.mark(e);
            }
        }
        list.cleanup(&remover);

        write("After: [");
        foreach(ref e; list)
        {
            write(e.val, ", ");
        }
        writeln("]");
    }
    writeln();

    writeln("---Improved Array removal---");
    {
        FixedArray2!(int, 12) arr;
        foreach(i; 0 .. arr.elements.length)
        {
            arr.push(cast(int)i);
        }

        writeln("Before: ", arr.elements);

        auto remover = arr.makeRemover();
        while(!remover.empty())
        {
            auto n = remover.next();
            if(n % 2 == 0)
            {
                // NOTE: You may need to know which elements were swapped during the removal. For instance, if a HashMap uses keys to map to
                // indeces in the array, you'll need to inform the HashMap of the swap.
                auto swapInfo = remover.remove();
                //writeln(swapInfo);
            }
        }

        writeln("After: ", arr.elements[0 .. arr.count]);
    }
    writeln();

    writeln("---Improved Linked List removal---");
    {
        LinkedList2!int list;
        foreach(i; 0 .. 12)
        {
            list.push(i);
        }

        write("Before: [");
        foreach(ref e; list)
        {
            write(e.val, ", ");
        }
        writeln("]");

        auto remover = list.makeRemover;
        while(!remover.empty())
        {
            auto e = remover.next();
            if(e.val % 2 == 0)
            {
                remover.remove();
            }
        }

        write("After: [");
        foreach(ref e; list)
        {
            write(e.val, ", ");
        }
        writeln("]");
    }
    writeln();
}
