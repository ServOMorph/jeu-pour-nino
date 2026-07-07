# enemy_flyer

- default_state: idle
- nb_states: 4

## Etats

### dead

- target_frame_size: 32x24
- fps: 1.0
- loop: false
- frame_count: 1
- sheet: legacy
- frame_size: n/a
- offset: [0.0, 0.0]

### fly

- target_frame_size: 32x24
- fps: 6.0
- loop: true
- frame_count: 1
- sheet: legacy
- frame_size: n/a
- offset: [0.0, 0.0]

### hurt

- target_frame_size: 32x24
- fps: 1.0
- loop: false
- frame_count: 1
- sheet: legacy
- frame_size: n/a
- offset: [0.0, 0.0]

### idle

- target_frame_size: 32x24
- fps: 1.0
- loop: true
- frame_count: 1
- sheet: legacy
- frame_size: n/a
- offset: [0.0, 0.0]

## Anomalies ouvertes

- idle / warning: taille incoherente: res://assets/enemies/enemy_flyer.png = 56x40, attendu 32x24
- fly / warning: taille incoherente: res://assets/enemies/enemy_flyer.png = 56x40, attendu 32x24
- hurt / warning: taille incoherente: res://assets/enemies/enemy_flyer.png = 56x40, attendu 32x24
- dead / warning: taille incoherente: res://assets/enemies/enemy_flyer.png = 56x40, attendu 32x24
- info: placeholder detecte: res://assets/enemies/enemy_flyer.png partage par [idle, fly, hurt, dead]

