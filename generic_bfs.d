// Permission to use, copy, modify, and/or distribute this software for any purpose with or without fee is hereby granted.
//
// THE SOFTWARE IS PROVIDED "AS IS" AND THE AUTHOR DISCLAIMS ALL WARRANTIES WITH REGARD TO THIS SOFTWARE INCLUDING ALL IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS. IN NO EVENT SHALL THE AUTHOR BE LIABLE FOR ANY SPECIAL, DIRECT, INDIRECT, OR CONSEQUENTIAL DAMAGES OR ANY DAMAGES WHATSOEVER RESULTING FROM LOSS OF USE, DATA OR PROFITS, WHETHER IN AN ACTION OF CONTRACT, NEGLIGENCE OR OTHER TORTIOUS ACTION, ARISING OUT OF OR IN CONNECTION WITH THE USE OR PERFORMANCE OF THIS SOFTWARE.

/+
DESCRIPTION:

An example of a generic version of the Breadth-First Search algorithm. Much more verbose than I initially intended. Could use a lot of work.
+/

enum maxTilesX = 6;
enum maxTilesY = 6;
enum maxTiles = maxTilesX * maxTilesY;

struct Queue(T)
{
    uint back;
    uint front;
    uint count;
    T[maxTilesX] elements;
    
    void push(T item)
    {
        assert(count < elements.length);
        elements[back] = item;
        back++;
        count++;
        
        if(back >= elements.length) back = 0;
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
    
    uint length()
    {
        return count;
    }
    
    uint capacity() const
    {
        return cast(uint)elements.length;
    }
    
    alias opDollar = length;
}

struct TilePos
{
    int x, y;

    bool opEquals()(auto ref const TilePos p) const
    {
        return x == p.x && y == p.y;
    }
}

enum TilePos nullTile = TilePos(-1, -1);

version(none)
{
    __gshared uint[maxTiles] tiles = 
    [
        1, 1, 0, 0, 0, 0,
        1, 1, 0, 0, 0, 0,
        1, 0, 1, 1, 1, 1,
        1, 0, 0, 0, 0, 0,
        1, 1, 1, 1, 1, 1,
        1, 1, 1, 1, 1, 1,
    ];
}
else
{
    __gshared uint[maxTiles] tiles = 
    [
        0, 0, 0, 0, 0, 0,
        0, 0, 0, 0, 0, 0,
        0, 0, 0, 0, 0, 0,
        0, 0, 0, 0, 0, 0,
        0, 0, 0, 0, 0, 0,
        0, 0, 0, 0, 0, 0,
    ];
}


bool isValidTile(in TilePos p)
{
    return p.x >= 0 && p.x < maxTilesX && p.y >= 0 && p.y < maxTilesY;
}

struct TileSearch
{
    enum maxEdges = 4;
    alias none = nullTile;
    
    bool[maxTiles]    discovered;
    TilePos[maxTiles] tilesVisited;
    TilePos[maxTiles] parentTiles;
    int[maxTiles]     distances;
    uint tilesVisitedCount;
    
    bool shouldMark(in TilePos p)
    {
        return isValidTile(p) && !discovered[p.x + p.y * maxTilesX]
            && tiles[p.x + p.y * maxTilesX] == 0;
    }

    void mark(in TilePos next)
    {
        assert(next != nullTile);
        discovered[next.x + next.y * maxTilesX] = true;
        tilesVisited[tilesVisitedCount] = next;
        tilesVisitedCount++;
    }
    
    void mark(in TilePos next, in TilePos prev)
    {
        assert(next != nullTile);
        assert(prev != nullTile);
        mark(next);
        parentTiles[next.x + next.y * maxTilesX] = prev;
        distances[next.x + next.y * maxTilesX] = distances[prev.x + prev.y * maxTilesX] + 1;
    }
    
    void getNeighbors(ref TilePos[maxEdges] neighbors, in TilePos p)
    {
        neighbors[0] = TilePos(p.x + 1, p.y);
        neighbors[1] = TilePos(p.x - 1, p.y);
        neighbors[2] = TilePos(p.x, p.y + 1);
        neighbors[3] = TilePos(p.x, p.y - 1);
    }
}

void breadthFirstSearch(Result, T)(ref Result r, in T root)
{
    T[Result.maxEdges] neighbors;
    Queue!T frontier;
    frontier.push(root);
    r.mark(root);
    
    while(frontier.length > 0)
    {
        auto current = frontier.pop();
        
        r.getNeighbors(neighbors, current);
        static foreach(i; 0 .. neighbors.length)
        {
            if(r.shouldMark(neighbors[i]))
            {
                r.mark(neighbors[i], current);
                frontier.push(neighbors[i]);
            }
        }
    }
}

void main()
{
    import core.stdc.stdio;

    TileSearch r;
    r.parentTiles[] = nullTile;
    breadthFirstSearch(r, TilePos(0, 0));
    foreach(i; 0 .. r.tilesVisitedCount)
    {
        auto t = r.tilesVisited[i];
        printf("(%d, %d), ", t.x, t.y);
    }
    printf("\n\n");
    
    TilePos walkTile = TilePos(5, 3);
    while(walkTile != nullTile)
    {
        printf("(%d, %d) + %d, ", walkTile.x, walkTile.y, r.distances[walkTile.x + walkTile.y * maxTilesX]);
        walkTile = r.parentTiles[walkTile.x + walkTile.y * maxTilesX];
    }
    printf("\n\n");
}