// Copyright (C) 2021 by tspike (github.com/tspike2k)
//
// Permission to use, copy, modify, and/or distribute this software for any purpose with or without fee is hereby granted.
//
// THE SOFTWARE IS PROVIDED "AS IS" AND THE AUTHOR DISCLAIMS ALL WARRANTIES WITH REGARD TO THIS SOFTWARE INCLUDING ALL IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS. IN NO EVENT SHALL THE AUTHOR BE LIABLE FOR ANY SPECIAL, DIRECT, INDIRECT, OR CONSEQUENTIAL DAMAGES OR ANY DAMAGES WHATSOEVER RESULTING FROM LOSS OF USE, DATA OR PROFITS, WHETHER IN AN ACTION OF CONTRACT, NEGLIGENCE OR OTHER TORTIOUS ACTION, ARISING OUT OF OR IN CONNECTION WITH THE USE OR PERFORMANCE OF THIS SOFTWARE.

/+
DESCRIPTION:

An example of how to write a quicksort algorithm in D. I'm still not sure I like the idea of a global "swap" function 
and relying on UFCS to choose between the global function or a swap method (if one exists). 
+/

import core.stdc.stdio;
import std.traits;

alias ArrayTarget(T : T[]) = T;

template areValidSortArgs(alias compareT, T)
{
    enum areValidSortArgs = isArray!T && (is(typeof(compareT) == string) || isCallable!compareT);
}

void sort(alias compareT = "a < b", T)(auto ref T t)
if(areValidSortArgs!(compareT, T))
{
    quickSort!compareT(t, 0, t.length - 1);
}

void swap(T)(ref T a, ref T b)
{
    pragma(inline, true);
    printf("Default swap.\n");
    auto temp = a;
    a = b;
    b = temp; 
}

void quickSort(alias compareT = "a < b", T)(auto ref T t, ptrdiff_t start, ptrdiff_t end)
if(areValidSortArgs!(compareT, T))
{
    alias E = ArrayTarget!T;
    
    static if(is(typeof(compareT) == string))
    {
        bool compare(ref E a, ref E b)
        {
            pragma(inline, true);
            return mixin(compareT);
        }    
    }
    else
    {
        alias compare = compareT;
    }
    
    // TODO: We are relying on the overloading bahavior where, when resolving UFCs, methods
    // are selected before the global swap() template. Can this behavior be relied on or is
    // this an implementation detail? Try other compilers and look at the spec.
    
    size_t partition(ref T t, ptrdiff_t start, ptrdiff_t end)
    {
        // TODO: Better quicksort? Pivot from the middle?
        auto pivotValue = &t[end];
        auto i = (start - 1);

        foreach(j; start .. end)
        {
            if(compare(t[j], *pivotValue))
            {
                i++;
                t[i].swap(t[j]);
            }
        }
        
        t[i + 1].swap(t[end]);

        return i + 1;
    }

    if(start < end)
    {
        auto partitionIndex = partition(t, start, end);
        quickSort!compareT(t, start, partitionIndex - 1);
        quickSort!compareT(t, partitionIndex + 1, end);
    }
}


struct Test
{
    struct Inner
    {
        size_t index;
    }

    Inner inner;
/*
    int opCmp(in Test t)
    {
        if (index < t.index) return -1;
        else if (index > t.index) return 1;
        else return 0;
    }
  
    void opAssign(ref Test t)
    {
        this.inner.index = t.inner.index;
    }
*/

    // NOTE: If we need custom element swapping code, the simplest 
    // way to do this is with a swap() method. 
    version(all) void swap(ref Test b)
    {
        pragma(inline, true);
        auto temp = this;
        this = b;
        b = temp;
        printf("Custom swap\n");
    }
}

void main()
{
    auto array = [1, 8, 22, 4, 6];

    auto arrayOfTest = [Test(Test.Inner(29)), Test(Test.Inner(43)), Test(Test.Inner(29)), Test(Test.Inner(1)), Test(Test.Inner(420)), Test(Test.Inner(0)), Test(Test.Inner(1))];

    sort(array[]);

    printf("array: [");
    foreach(i, ref e; array)
    {
        printf("%d", e);
        if(i != array.length - 1)
        printf(", ");
    }
    printf("]\n");
    
    
    sort!"a.inner.index > b.inner.index"(arrayOfTest);
    printf("arrayOfTest: [");
    foreach(i, ref e; arrayOfTest)
    {
        printf("%lu", e.inner.index);
        if(i != arrayOfTest.length - 1)
        printf(", ");
    }
    printf("]\n");
    
    struct LeaveForLast
    {
        int value;
        bool opCall(ref Test a, ref Test b)
        {   
            if(a.inner.index == value) return false;
            if(b.inner.index == value) return true;
            
            return a.inner.index < b.inner.index;
        }
    }
    
    LeaveForLast leaveForLast;
    leaveForLast.value = 29;
    
    sort!leaveForLast(arrayOfTest);
    
    printf("arrayOfTest: [");
    foreach(i, ref e; arrayOfTest)
    {
        printf("%lu", e.inner.index);
        if(i != arrayOfTest.length - 1)
        printf(", ");
    }
    printf("]\n");
}