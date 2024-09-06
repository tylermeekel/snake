package snake

import rl "vendor:raylib"
import "core:fmt"
import "core:math/rand"
import "core:math"

// Segment size in pixels
SEGMENT_SIZE :: 10

Direction :: enum {
    Up,
    Down,
    Left,
    Right
}

Direction_Vectors := [Direction]rl.Vector2 {
    .Up = {0, -SEGMENT_SIZE},
    .Down = {0, SEGMENT_SIZE},
    .Left = {-SEGMENT_SIZE, 0},
    .Right = {SEGMENT_SIZE, 0},
}

Segment :: struct {
    position: rl.Vector2
}

random_apple_pos :: proc() -> rl.Vector2 {
    xpos := f32(rand.int31_max(50) * 10)
    ypos := f32(rand.int31_max(50) * 10)

    return {xpos, ypos}
}

Game_State :: struct {
    player_direction: Direction,
    snake_segments: [dynamic]Segment,
    apple_pos: rl.Vector2,
    tick_length: f32,
    started: bool
}

initialized_game_state :: proc() -> Game_State {
    return {
        Direction.Up,
        [dynamic]Segment{
            {
                {250, 250},
            },
            {
                {250, 250},
            },
            {
                {250, 250},
            },
        },
        random_apple_pos(),
        0.1,
        false
    },
}

main :: proc() {
    // INIT
    rl.InitWindow(500, 500, "Snake")
    defer rl.CloseWindow()

    game_state := initialized_game_state()
    defer delete(game_state.snake_segments)

    tick_timer: f32 = 0.0

    for !rl.WindowShouldClose() {
        if !game_state.started {
            // Wait for an input
            if rl.IsKeyPressed(.UP) {
                game_state.started = true
                game_state.player_direction = .Up
            }

            if rl.IsKeyPressed(.DOWN) {
                game_state.started = true
                game_state.player_direction = .Down
            }

            if rl.IsKeyPressed(.RIGHT) {
                game_state.started = true
                game_state.player_direction = .Right
            }

            if rl.IsKeyPressed(.LEFT) {
                game_state.started = true
                game_state.player_direction = .Left
            }
        }

        rl.BeginDrawing()
        rl.ClearBackground(rl.BLUE)

        // INPUT
        dt := rl.GetFrameTime()
        if !game_state.started {
            dt = 0
        }
        
        if rl.IsKeyPressed(.UP) && game_state.player_direction != .Down {
            game_state.player_direction = .Up
        }

        if rl.IsKeyPressed(.DOWN) && game_state.player_direction != .Up {
            game_state.player_direction = .Down
        }

        if rl.IsKeyPressed(.RIGHT) && game_state.player_direction != .Left {
            game_state.player_direction = .Right
        }

        if rl.IsKeyPressed(.LEFT) && game_state.player_direction != .Right {
            game_state.player_direction = .Left
        }

        // UPDATE
        tick_timer += dt
        if tick_timer >= game_state.tick_length {
            tick_timer = 0

            for i in 1..<len(game_state.snake_segments) {
                reverse := len(game_state.snake_segments) - i
                game_state.snake_segments[reverse].position = game_state.snake_segments[reverse-1].position
            }

            game_state.snake_segments[0].position += Direction_Vectors[game_state.player_direction]

            // Check for death
            for segment in game_state.snake_segments[1:] {
                if game_state.snake_segments[0].position == segment.position {
                    // Die
                    delete(game_state.snake_segments)
                    game_state = initialized_game_state()
                }
            }

            // Check for apple get
            if game_state.snake_segments[0].position == game_state.apple_pos {
                new_segment := game_state.snake_segments[len(game_state.snake_segments) - 1]
                append(&game_state.snake_segments, new_segment)

                game_state.apple_pos = random_apple_pos()
                game_state.tick_length = max(0.05, game_state.tick_length - 0.005)
            }

            // Check if going off frame, loop around
            if game_state.snake_segments[0].position.x < 0 {
                game_state.snake_segments[0].position.x = 490
            }

            if game_state.snake_segments[0].position.x > 490 {
                game_state.snake_segments[0].position.x = 0
            }

            if game_state.snake_segments[0].position.y < 0 {
                game_state.snake_segments[0].position.y = 490
            }

            if game_state.snake_segments[0].position.y > 490 {
                game_state.snake_segments[0].position.y = 0
            }
        }

        // DRAW 
        apple_rec := rl.Rectangle {
            game_state.apple_pos.x,
            game_state.apple_pos.y,
            SEGMENT_SIZE,
            SEGMENT_SIZE
        }
        rl.DrawRectangleRec(apple_rec, rl.RED)

        for segment in game_state.snake_segments {
            segment_rect := rl.Rectangle {
                segment.position.x,
                segment.position.y,
                SEGMENT_SIZE,
                SEGMENT_SIZE,
            }

            rl.DrawRectangleRec(segment_rect, rl.WHITE)
        }

        rl.EndDrawing()
    }
}