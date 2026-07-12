# enemy_flyer

- default_state: idle
- nb_states: 4

## Etats

### dead

- target_frame_size: 112x80
- fps: 1.0
- loop: false
- frame_count: 1
- sheet: legacy
- frame_size: n/a
- offset: [0.0, 0.0]

### fly

- target_frame_size: 112x80
- fps: 6.0
- loop: true
- frame_count: 6
- sheet: res://assets/sprites/enemies/enemy_flyer_fly_sheet.png
- frame_size: 112x80
- offset: [0.0, 0.0]

### hurt

- target_frame_size: 112x80
- fps: 1.0
- loop: false
- frame_count: 1
- sheet: legacy
- frame_size: n/a
- offset: [0.0, 0.0]

### idle

- target_frame_size: 112x80
- fps: 1.0
- loop: true
- frame_count: 1
- sheet: legacy
- frame_size: n/a
- offset: [0.0, 0.0]

## Anomalies ouvertes

- info: placeholder detecte: res://assets/enemies/enemy_flyer.png partage par [idle, hurt, dead]

