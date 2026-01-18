#include "../../raylib.bi"

dim as integer screen_width = 800
dim as integer screen_height = 450

InitWindow(screen_width, screen_height, "raylib-freebasic [core] example - basic window")

SetTargetFPS(60)

do while WindowShouldClose() = false 
  BeginDrawing()

    ClearBackground(RAYWHITE)

    DrawText("Congrats! You created your first window!", 190, 200, 20, BLACK)

  EndDrawing()
loop

CloseWindow()