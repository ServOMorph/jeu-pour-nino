# enemy_ground

- default_state: idle
- nb_states: 4

## Etats

### dead

- target_frame_size: 32x32
- fps: 1.0
- loop: false
- frame_count: 1
- sheet: legacy
- frame_size: n/a
- offset: [0.0, 0.0]

### hurt

- target_frame_size: 32x32
- fps: 1.0
- loop: false
- frame_count: 1
- sheet: legacy
- frame_size: n/a
- offset: [0.0, 0.0]

### idle

- target_frame_size: 32x32
- fps: 1.0
- loop: true
- frame_count: 1
- sheet: legacy
- frame_size: n/a
- offset: [0.0, 0.0]

### walk

- target_frame_size: 32x32
- fps: 4.0
- loop: true
- frame_count: 1
- sheet: legacy
- frame_size: n/a
- offset: [0.0, 0.0]

## Anomalies ouvertes

- idle / warning: taille incoherente: res://assets/enemies/enemy_ground.png = 64x64, attendu 32x32
- walk / warning: taille incoherente: res://assets/enemies/enemy_ground.png = 64x64, attendu 32x32
- hurt / warning: taille incoherente: res://assets/enemies/enemy_ground.png = 64x64, attendu 32x32
- dead / warning: taille incoherente: res://assets/enemies/enemy_ground.png = 64x64, attendu 32x32
- info: placeholder detecte: res://assets/enemies/enemy_ground.png partage par [idle, walk, hurt, dead]

