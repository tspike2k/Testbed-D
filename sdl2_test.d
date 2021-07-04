// Copyright (C) 2021 tspike (github.com/tspike2k)
//
// Permission to use, copy, modify, and/or distribute this software for any purpose with or without fee is hereby granted.
//
// THE SOFTWARE IS PROVIDED "AS IS" AND THE AUTHOR DISCLAIMS ALL WARRANTIES WITH REGARD TO THIS SOFTWARE INCLUDING ALL IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS. IN NO EVENT SHALL THE AUTHOR BE LIABLE FOR ANY SPECIAL, DIRECT, INDIRECT, OR CONSEQUENTIAL DAMAGES OR ANY DAMAGES WHATSOEVER RESULTING FROM LOSS OF USE, DATA OR PROFITS, WHETHER IN AN ACTION OF CONTRACT, NEGLIGENCE OR OTHER TORTIOUS ACTION, ARISING OUT OF OR IN CONNECTION WITH THE USE OR PERFORMANCE OF THIS SOFTWARE.

/+
DESCRIPTION:

A bare-bones demonstration of the SDL2 bindings from sdl2.d. Since sdl2.d makes use of pragma(lib, ...) there's no need to manually pass the library name to the linker when compiling. Convenient!
+/

enum WINDOW_WIDTH  = 1024;
enum WINDOW_HEIGHT = 768;

import sdl2;
import core.stdc.stdio;

nothrow @nogc:

void main()
{
    if (SDL_Init(SDL_INIT_VIDEO) < 0)
    {
        fprintf(stderr, "SDL_Init Error: %s\n", SDL_GetError());
        return;
    }
    scope(exit) SDL_Quit();
    
    auto window = SDL_CreateWindow("SDL Test", SDL_WINDOWPOS_CENTERED, SDL_WINDOWPOS_CENTERED, WINDOW_WIDTH, WINDOW_HEIGHT, SDL_WINDOW_SHOWN);
    if(!window)
    {
        fprintf(stderr, "SDL_CreateWindow Error: %s\n", SDL_GetError());
        return;
    }
    scope(exit){ if(!window) SDL_DestroyWindow(window); }
    
    auto renderer = SDL_CreateRenderer(window, -1, SDL_RENDERER_ACCELERATED|SDL_RENDERER_PRESENTVSYNC);
    if (!renderer)
    {
        fprintf(stderr, "SDL_CreateRenderer Error: %s\n", SDL_GetError());
        return;
    }
    scope(exit){ if(!renderer) SDL_DestroyRenderer(renderer); }
    
    void centerRect(ref SDL_Rect r)
    {
        r.x = WINDOW_WIDTH / 2 - r.w / 2;
        r.y = WINDOW_HEIGHT / 2 - r.h / 2;
    }
    
    SDL_Event evt;
    SDL_Rect rect = SDL_Rect(0, 0, 200, 200);
    bool growX, growY;
    float growXTimer = 0.0f;
    float growYTimer = 0.0f;
    auto lastTick = SDL_GetTicks();
    mainLoop: while(true)
    {
        auto currentTick = SDL_GetTicks();
        float dt = cast(float)(currentTick - lastTick) / 1000.0f;
        lastTick = currentTick;
    
        while (SDL_PollEvent(&evt))
        {
            switch(evt.type)
            {
                case SDL_QUIT:
                {
                    break mainLoop;
                } break;
                
                case SDL_KEYDOWN:
                {
                    if(evt.key.repeat) break;
                
                    if(evt.key.keysym.sym == SDLK_LEFT || evt.key.keysym.sym == SDLK_RIGHT)
                    {
                        growX = true;
                        growXTimer = 0.0f;
                    }
                    else if(evt.key.keysym.sym == SDLK_UP || evt.key.keysym.sym == SDLK_DOWN)
                    {
                        growY = true;
                        growYTimer = 0.0f;
                    }
                } break;
                
                case SDL_KEYUP:
                {
                    if(evt.key.keysym.sym == SDLK_LEFT || evt.key.keysym.sym == SDLK_RIGHT)
                    {
                        growX = false;
                    }
                    else if(evt.key.keysym.sym == SDLK_UP || evt.key.keysym.sym == SDLK_DOWN)
                    {
                        growY = false;
                    }
                } break;
                
                default: break;
            }
        }
        
        enum growTime = 0.016f;
        enum growAmount = 5;
        if(growX)
        {
            growXTimer += dt;
            
            if(growXTimer >= growTime)
            {
                rect.w += growAmount;
                growXTimer = growTime - growXTimer;            
            }
        }
        if(growY)
        {
            growYTimer += dt;
            
            if(growYTimer >= growTime)
            {
                rect.h += growAmount;
                growYTimer = growTime - growYTimer;            
            }
        }
        
        centerRect(rect);
        
        SDL_SetRenderDrawColor(renderer, 0x00, 0x20, 0x60, 0xFF);
        SDL_RenderClear(renderer);     
        
        SDL_SetRenderDrawColor(renderer, 0x80, 0x20, 0x00, 0xff);
        SDL_RenderFillRect(renderer, &rect);
        
        SDL_RenderPresent(renderer);
    }
}