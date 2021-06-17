// Permission to use, copy, modify, and/or distribute this software for any purpose with or without fee is hereby granted.
//
// THE SOFTWARE IS PROVIDED "AS IS" AND THE AUTHOR DISCLAIMS ALL WARRANTIES WITH REGARD TO THIS SOFTWARE INCLUDING ALL IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS. IN NO EVENT SHALL THE AUTHOR BE LIABLE FOR ANY SPECIAL, DIRECT, INDIRECT, OR CONSEQUENTIAL DAMAGES OR ANY DAMAGES WHATSOEVER RESULTING FROM LOSS OF USE, DATA OR PROFITS, WHETHER IN AN ACTION OF CONTRACT, NEGLIGENCE OR OTHER TORTIOUS ACTION, ARISING OUT OF OR IN CONNECTION WITH THE USE OR PERFORMANCE OF THIS SOFTWARE.

/+
DESCRIPTION:

An example of how to convert a string to an integer (with error handling!).
+/

import std.stdio;
import std.traits;
import std.math : pow;

// NOTE: To ignore the error value, call this function. Can be used for compile-time evaluation (see example below).
nothrow @nogc T stringToInt(T)(const(char)[] str)
{
    T result;
    auto success = stringToInt(str, &result);
    assert(success);
    return result;
}

nothrow @nogc bool stringToInt(T)(const(char)[] str, T* dest)
if(isIntegral!T)
{
    static if(isSigned!T)
    {
        alias resultT = long;
        resultT sign = 1;
    }
    else
    {
        alias resultT = ulong;
    }
    
    resultT base = 10;
    resultT result = 0;
    uint place = 0;
    
    if(str.length > 2 && str[0] == '0' && str[1] == 'x')
    {
        base = 16;
        str = str[2..$];
    }
    else if(str.length > 1 && str[0] == '-')
    {
        static if(!isSigned!T)
        {
            goto failedConversion;
        }
        else
        {
            sign = -1;
            str = str[1..$];        
        }
    }
    
    foreach_reverse(ref c; str)
    {
        if(c == '_' || c == ',')
        {
            continue;
        }
        else if(c >= '0' && c <= '9')
        {
            result += cast(resultT)(c - '0') * pow(base, place);
            place++;
        }
        else if(base == 16 && c >= 'a' && c <= 'f')
        {
            result += cast(resultT)(c - 'a' + 10) * pow(base, place);
            place++;
        }
        else if(base == 16 && c >= 'A' && c <= 'F')
        {
            result += cast(resultT)(c - 'A' + 10) * pow(base, place);
            place++;
        }
        else
        {
            goto failedConversion;
        }
    }
    
    static if(isSigned!T) result = result * sign;
    
    assert(result <= T.max && result >= T.min, "Conversion from string to " ~ T.stringof ~ " results in truncation.");
    *dest = cast(T)result;
    
    return true;
    
failedConversion:
    
    *dest = 0;
    return false;
}

void main()
{
    byte b;
    char[3] c = "127";
    assert(stringToInt(c, &b));
    writeln(b);
    assert(stringToInt("-128", &b));
    writeln(b);
    assert(!stringToInt("Testing", &b));
    int i;
    assert(stringToInt("123_999", &i));
    writeln(i);
    assert(stringToInt("499", &i));
    writeln(i);
    
    enum e = stringToInt!int("986");
    writeln(e);
}