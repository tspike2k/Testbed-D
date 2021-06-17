// Copyright (C) 2021 by tspike (github.com/tspike2k)
//
// Permission to use, copy, modify, and/or distribute this software for any purpose with or without fee is hereby granted.
//
// THE SOFTWARE IS PROVIDED "AS IS" AND THE AUTHOR DISCLAIMS ALL WARRANTIES WITH REGARD TO THIS SOFTWARE INCLUDING ALL IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS. IN NO EVENT SHALL THE AUTHOR BE LIABLE FOR ANY SPECIAL, DIRECT, INDIRECT, OR CONSEQUENTIAL DAMAGES OR ANY DAMAGES WHATSOEVER RESULTING FROM LOSS OF USE, DATA OR PROFITS, WHETHER IN AN ACTION OF CONTRACT, NEGLIGENCE OR OTHER TORTIOUS ACTION, ARISING OUT OF OR IN CONNECTION WITH THE USE OR PERFORMANCE OF THIS SOFTWARE.

/+
DESCRIPTION:

A small, terminal-based example of how to create a property editor for arbitrary data types in D. Property editors are
common in game engines such as Unity or Unreal that allow devs to inspect the values of each member of an object and adjust
them as desired at runtime. Thanks to the powerful introspection provided by the language, this turns out to be rather
simple. 

USAGE:

Enter any compatible value into the terminal and it will assign the value to the currently selected struct member.
Note that no error checking is in place, so if the string cannot be converted, the application will crash. To advance to
the next member enter "n". To select the previous member, enter "p". Enter "exit" in the terminal to quit.
+/

struct Test
{
    int a;
    float b;
    char c;
}

void main()
{
    import std.stdio;
    
    Test t = Test(120, 912.0f, 'x');
    
    uint selectedProperty;
    char[] inputBuffer;
    
    while(true)
    {
        writeln();
        writeln("Test: {");
        enum membersLength = Test.tupleof.length;
        foreach(i, ref member; t.tupleof)
        {
            if (selectedProperty == i) write("->  ");
            else write ("    ");
            writeln(typeof(member).stringof, " ",  __traits(identifier, t.tupleof[i]), " = ", member, ";");
        }
        writeln("}");
        
        auto readLen = readln(inputBuffer);
        auto input = inputBuffer[0 .. readLen-1];
        
        if(input == "exit")
        {
            break;
        }
        else if(input == "n")
        {
            selectedProperty = (selectedProperty + 1) % membersLength;
        }
        else if(input == "p")
        {
            if(selectedProperty == 0) selectedProperty = membersLength - 1;
            else selectedProperty--;
        }
        else
        {
            import std.conv;
            
            outer: switch(selectedProperty)
            {
                static foreach(i, _; typeof(t).tupleof)
                {
                    case i:
                    {
                        t.tupleof[i] = to!(typeof(t.tupleof[i]))(input);
                    } break outer;
                }
            
                default: assert(0); break;
            }
        }
    }
}