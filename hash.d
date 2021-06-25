// Copyright (C) 2021 tspike (github.com/tspike2k)
//
// Permission to use, copy, modify, and/or distribute this software for any purpose with or without fee is hereby granted.
//
// THE SOFTWARE IS PROVIDED "AS IS" AND THE AUTHOR DISCLAIMS ALL WARRANTIES WITH REGARD TO THIS SOFTWARE INCLUDING ALL IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS. IN NO EVENT SHALL THE AUTHOR BE LIABLE FOR ANY SPECIAL, DIRECT, INDIRECT, OR CONSEQUENTIAL DAMAGES OR ANY DAMAGES WHATSOEVER RESULTING FROM LOSS OF USE, DATA OR PROFITS, WHETHER IN AN ACTION OF CONTRACT, NEGLIGENCE OR OTHER TORTIOUS ACTION, ARISING OUT OF OR IN CONNECTION WITH THE USE OR PERFORMANCE OF THIS SOFTWARE.

/+
DESCRIPTION:

A simple hash table. The hash table stores entries using an open addressing scheme and uses linear probing to resolve collisions.
+/

import std.traits;
import std.stdio;

enum HashFlag : ubyte
{
    EMPTY,
    FILLED,
    DELETED,
}

struct FlatHash(Key, T, alias hashLogic)
{
    static if(is(typeof(hashLogic) == string))
    {
        uint hashFunc(in Key key, uint tableLength)
        {
            uint hash;
            mixin(hashLogic);
            return hash;
        }    
    }
    else static if(isCallable!hashLogic)
    {
        alias hashFunc = hashLogic;
    }
    else
    {
        static assert(0, "Invalid hash logic supplied to FlatHash. Must either be a string or a callable.");
    }

    Entry[] table;
    
    struct Entry
    {
        HashFlag flags;
        Key key;
        T val;
    }
    
    void alloc(size_t items)
    {
        import core.stdc.stdlib : malloc;
        Entry* data = cast(Entry*)malloc(Entry.sizeof*items);
        table = data[0 .. items];
    }
    
    void set(in Key key, in T t)
    {
        uint startIndex = hashFunc(key, cast(uint)table.length);
        
        bool succeeded = false;
        auto index = startIndex;
        while(true)
        {
            auto entry = &table[index];
            if(entry.flags != HashFlag.FILLED)
            {
                entry.key = key;
                entry.val = t;
                entry.flags = HashFlag.FILLED;
                succeeded = true;
                break;                
            }
        
            index = (index + 1) % table.length;
            if(index == startIndex) break;
        }
        
        assert(succeeded);
    }
    
    T* get(in Key key)
    {
        uint startIndex = hashFunc(key, cast(uint)table.length);
        
        T* result = null;
        auto index = startIndex;
        while(true)
        {
            auto entry = &table[index];
            if(entry.flags == HashFlag.EMPTY) break;
            
            if(entry.key == key && entry.flags != HashFlag.DELETED)
            {
                static if(!isPointer!T)
                    result = &entry.val;
                else
                    result = entry.val;
                break;
            }
            
            index = (index + 1) % table.length;
            if(index == startIndex) break;
        }
        
        return result;
    }
    
    void remove(in Key key)
    {
        uint startIndex = hashFunc(key, cast(uint)table.length);
        auto index = startIndex;
        while(true)
        {
            auto entry = &table[index];
            if(entry.flags == HashFlag.EMPTY) break;
            
            if(entry.key == key && entry.flags != HashFlag.DELETED)
            {
                entry.flags = HashFlag.DELETED;
                break;
            }
        
            index = (index + 1) % table.length;
            if(index == startIndex) break;
        }
    }
}

struct Tile
{
    int x, y;
}

uint hashFunc(int key, uint len)
{
    return 0;
}

struct HashOfTile
{
    int width;
    uint opCall(in Tile t, uint tableLen)
    {
        return t.x + t.y * width;
    }
}

void main()
{
    FlatHash!(int, char, hashFunc) hash;
    hash.alloc(3);
    hash.set(0, 'a');
    hash.set(1, 'b');
    hash.set(2, 'c');
    
    writeln(hash.table);
    
    hash.remove(1);
    assert(!hash.get(1));
    writeln(hash.table);
    
    hash.remove(0);
    assert(!hash.get(0));
    writeln(hash.table);
    
    writeln("Hash entry for key 2: ", *hash.get(2));
    
    int tileMapW = 4;
    int tileMapH = 5;
    
    HashOfTile tileHasher;
    tileHasher.width = tileMapW;
    FlatHash!(Tile, char, tileHasher) tileMap;
    tileMap.alloc(tileMapW*tileMapH);
    
    tileMap.set(Tile(0, 0), 'x');
    tileMap.set(Tile(3, 4), 'y');
 
    foreach(y; 0 .. tileMapH)
    {
        foreach(x; 0 .. tileMapW)
        {
            auto c = tileMap.get(Tile(x, y));
            if(c)
                write(*c, ", ");
            else
                write("*, ");
        }
        writeln();
    }
}