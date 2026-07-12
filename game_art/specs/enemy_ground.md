# enemy_ground

- default_state: idle
- nb_states: 4

## Etats

### dead

- target_frame_size: 128x128
- fps: 1.0
- loop: false
- frame_count: 1
- sheet: legacy
- frame_size: n/a
- offset: [0.0, 0.0]

### hurt

- target_frame_size: 128x128
- fps: 1.0
- loop: false
- frame_count: 1
- sheet: legacy
- frame_size: n/a
- offset: [0.0, 0.0]

### idle

- target_frame_size: 128x128
- fps: 1.0
- loop: true
- frame_count: 1
- sheet: legacy
- frame_size: n/a
- offset: [0.0, 0.0]

### walk

- target_frame_size: 128x128
- fps: 4.0
- loop: true
- frame_count: 8
- sheet: res://assets/sprites/enemies/enemy_ground_walk_sheet.png
- frame_size: 128x128
- offset: [0.0, 0.0]

## Anomalies ouvertes

- info: placeholder detecte: res://assets/enemies/enemy_ground.png partage par [idle, hurt, dead]

