// Copyright (C) 2021 tspike (github.com/tspike2k)
//
// Permission to use, copy, modify, and/or distribute this software for any purpose with or without fee is hereby granted.
//
// THE SOFTWARE IS PROVIDED "AS IS" AND THE AUTHOR DISCLAIMS ALL WARRANTIES WITH REGARD TO THIS SOFTWARE INCLUDING ALL IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS. IN NO EVENT SHALL THE AUTHOR BE LIABLE FOR ANY SPECIAL, DIRECT, INDIRECT, OR CONSEQUENTIAL DAMAGES OR ANY DAMAGES WHATSOEVER RESULTING FROM LOSS OF USE, DATA OR PROFITS, WHETHER IN AN ACTION OF CONTRACT, NEGLIGENCE OR OTHER TORTIOUS ACTION, ARISING OUT OF OR IN CONNECTION WITH THE USE OR PERFORMANCE OF THIS SOFTWARE.

/+
DESCRIPTION:

A small example of how to store callbacks as struct members in D.
+/

nothrow @nogc:

import core.stdc.stdio;

struct UserData
{
    int a;
}

alias CommandFunc = void function(in CommandEvent evt, void* userData);

struct Command
{
    CommandFunc fn;    
}

struct CommandEvent
{
    bool pressed;
}

void testFunc(in CommandEvent evt, void* userData)
{
    auto s = cast(UserData*)userData;
    s.a++;
    printf("%d\n", s.a);
}

void main()
{
    Command[12] commands;
    uint commandsCount;
    
    UserData data;
    data.a = 12;
   
    commands[0].fn = &testFunc;
    commandsCount++;
   
    void pushCommand(CommandFunc fn)
    {
        Command* cmd = &commands[commandsCount++];
        cmd.fn = fn;
    }
    
    pushCommand(&testFunc);
    pushCommand(
        // NOTE: Function literal with inferred parameter types. Very nice!
        (evt, userData) 
        {
            auto s = cast(UserData*)userData;
            s.a *= 2;
            printf("%d\n", s.a);
            
            if(evt.pressed)
            {
                printf("pressed!\n");
            }
        }
    );
    
    CommandEvent evt;
    evt.pressed = true;
    foreach(i; 0 .. commandsCount)
    {
        auto cmd = &commands[i];
        cmd.fn(evt, &data);
    }
}