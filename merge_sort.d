// Copyright (C) 2021 by tspike (github.com/tspike2k)
//
// Permission to use, copy, modify, and/or distribute this software for any purpose with or without fee is hereby granted.
//
// THE SOFTWARE IS PROVIDED "AS IS" AND THE AUTHOR DISCLAIMS ALL WARRANTIES WITH REGARD TO THIS SOFTWARE INCLUDING ALL IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS. IN NO EVENT SHALL THE AUTHOR BE LIABLE FOR ANY SPECIAL, DIRECT, INDIRECT, OR CONSEQUENTIAL DAMAGES OR ANY DAMAGES WHATSOEVER RESULTING FROM LOSS OF USE, DATA OR PROFITS, WHETHER IN AN ACTION OF CONTRACT, NEGLIGENCE OR OTHER TORTIOUS ACTION, ARISING OUT OF OR IN CONNECTION WITH THE USE OR PERFORMANCE OF THIS SOFTWARE.

private template areValidSortArgs(alias compareT, T)
{
    import std.traits;
    enum areValidSortArgs = isArray!T && (is(typeof(compareT) == string) || isCallable!compareT);
}

T min(T)(in T a, in T b)
{
    return a < b ? a : b;
}

// NOTE: Bottom-up merge sort code ripped straight from Wikipedia

void mergeSort(alias compareT = "a < b", T)(ref T src, ref T work)
if(areValidSortArgs!(compareT, T))
{
    assert(work.length >= src.length);
    auto len = src.length;
    for (size_t width = 1; width < len; width = 2 * width)
    {
        for (size_t i = 0; i < len; i = i + 2 * width)
        {
            merge!(compareT)(src, i, min(i+width, len), min(i+2*width, len), work);
        }

        src[0 .. len] = work[0 .. len];
    }
}

void merge(alias compareT, T)(ref T src, size_t iLeft, size_t iRight, size_t iEnd, ref T work)
if(areValidSortArgs!(compareT, T))
{
    static if(is(typeof(compareT) == string))
    {
        alias E = typeof(T.init[0]);
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

    size_t i = iLeft;
    size_t j = iRight;
    for (size_t k = iLeft; k < iEnd; k++) {
        if (i < iRight && (j >= iEnd || compare(src[i], src[j]))) {
            work[k] = src[i];
            i = i + 1;
        } else {
            work[k] = src[j];
            j = j + 1;    
        }
    } 
}

void main()
{
    int[3] arr = [3, 2, 1];
    int[3] work;
    
    import std.stdio;
    mergeSort!"a > b"(arr, work);
    writeln(arr);
}