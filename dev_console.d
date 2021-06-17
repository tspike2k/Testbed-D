// Permission to use, copy, modify, and/or distribute this software for any purpose with or without fee is hereby granted.
//
// THE SOFTWARE IS PROVIDED "AS IS" AND THE AUTHOR DISCLAIMS ALL WARRANTIES WITH REGARD TO THIS SOFTWARE INCLUDING ALL IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS. IN NO EVENT SHALL THE AUTHOR BE LIABLE FOR ANY SPECIAL, DIRECT, INDIRECT, OR CONSEQUENTIAL DAMAGES OR ANY DAMAGES WHATSOEVER RESULTING FROM LOSS OF USE, DATA OR PROFITS, WHETHER IN AN ACTION OF CONTRACT, NEGLIGENCE OR OTHER TORTIOUS ACTION, ARISING OUT OF OR IN CONNECTION WITH THE USE OR PERFORMANCE OF THIS SOFTWARE.

/+
DESCRIPTION:

Sometimes it's useful to take text input from the user and treat it as a command, calling any function that matches
the command name and passing it any supplied arguments. In languages like C or C++, this requires a lot of boilerplate
and glue code, but this demonstrates how simple it can be when using D. Any function tagged using the ConsoleCommand
attribute will automatically be "registered" and can be called, by name, from the terminal. Enter "exit" into the
terminal to close the application.

This is inspired by the video "Game Engine Programming: Console commands, Cool metaprogramming" by Jonathan Blow which
can be watched here:
https://www.youtube.com/watch?v=N2UdveBwWY4
+/

import std.typecons : tuple;
import std.traits;
import std.stdio;

enum ConsoleCommand;

@ConsoleCommand
{
    void spawnEntity(float px, float py)
    {
        writeln("Spawning at ", px, " ", py);
    }
    
    void printNum(int n)
    {
        writeln("Printing ", n);
    }
    
    void hello()
    {
        writeln("World!");
    }
}

void main()
{    
    writeln("Please enter a command...");
    
    char[] inputBuffer;
    while(true)
    {   
        write(">");
        auto readLen = readln(inputBuffer);
        auto input = inputBuffer[0 .. readLen-1];
        
        if(input == "exit")
        {
            break;
        }
        else
        {
            import std.array : split;
            auto s = split(input, ' ');
            
            bool commandExists = false;
            alias commands = getSymbolsByUDA!(dev_console, ConsoleCommand);
            foreach(i, cmd; commands)
            {
                if(s[0] == __traits(identifier, cmd))
                {
                    commandExists = true;
                
                    if(s.length - 1 == Parameters!(cmd).length)
                    {
                        import std.conv;
                        static foreach(argIndex, p; Parameters!cmd)
                        {
                            mixin(p.stringof ~ " arg" ~ to!string(argIndex) ~ ";");
                        }
                        
                        foreach(argIndex, p; Parameters!cmd)
                        {
                            mixin("arg" ~ to!string(argIndex) ~ " = to!" ~ p.stringof ~ "(s[argIndex+1]);");
                        }
                        
                        string callFunc(alias cmd)()
                        {
                            string result;
                            result ~= __traits(identifier, cmd) ~ "(";
                            foreach(argIndex, p; Parameters!cmd)
                            {
                                if(argIndex > 0) result ~= ", ";
                                result ~= "arg" ~ to!string(argIndex);
                            }
                            
                            result ~= ");\n";
                            return result;
                        }
                        
                        mixin(callFunc!cmd);
                    }
                    else
                    {
                        writeln("Invalid number of arguments to command '" ~ __traits(identifier, cmd) ~ "'; Expected ", Parameters!(cmd).length, " but got ", s.length - 1, ".");
                    }
                }
            }
            
            if(!commandExists)
            {
                writeln("Unknown command '" ~ s[0] ~ "'.");
            }
        }
    }
}