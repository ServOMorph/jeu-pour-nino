# boss

- default_state: sleep
- nb_states: 9

## Etats

### charge

- target_frame_size: 96x128
- fps: 8.0
- loop: true
- frame_count: 1
- sheet: legacy
- frame_size: n/a
- offset: [0.0, 0.0]

### dead

- target_frame_size: 96x128
- fps: 1.0
- loop: false
- frame_count: 1
- sheet: legacy
- frame_size: n/a
- offset: [0.0, 0.0]

### hurt

- target_frame_size: 96x128
- fps: 1.0
- loop: false
- frame_count: 1
- sheet: legacy
- frame_size: n/a
- offset: [0.0, 0.0]

### idle

- target_frame_size: 96x128
- fps: 1.0
- loop: true
- frame_count: 1
- sheet: legacy
- frame_size: n/a
- offset: [0.0, 0.0]

### pause

- target_frame_size: 96x128
- fps: 1.0
- loop: true
- frame_count: 1
- sheet: legacy
- frame_size: n/a
- offset: [0.0, 0.0]

### slam_fall

- target_frame_size: 96x128
- fps: 6.0
- loop: true
- frame_count: 1
- sheet: legacy
- frame_size: n/a
- offset: [0.0, 0.0]

### slam_rise

- target_frame_size: 96x128
- fps: 6.0
- loop: true
- frame_count: 1
- sheet: legacy
- frame_size: n/a
- offset: [0.0, 0.0]

### sleep

- target_frame_size: 96x128
- fps: 1.0
- loop: true
- frame_count: 1
- sheet: legacy
- frame_size: n/a
- offset: [0.0, 0.0]

### volley

- target_frame_size: 96x128
- fps: 6.0
- loop: true
- frame_count: 1
- sheet: legacy
- frame_size: n/a
- offset: [0.0, 0.0]

## Anomalies ouvertes

- sleep / warning: taille incoherente: res://assets/enemies/boss_guardian.png = 112x144, attendu 96x128
- idle / warning: taille incoherente: res://assets/enemies/boss_guardian.png = 112x144, attendu 96x128
- charge / warning: taille incoherente: res://assets/enemies/boss_guardian.png = 112x144, attendu 96x128
- volley / warning: taille incoherente: res://assets/enemies/boss_guardian.png = 112x144, attendu 96x128
- slam_rise / warning: taille incoherente: res://assets/enemies/boss_guardian.png = 112x144, attendu 96x128
- slam_fall / warning: taille incoherente: res://assets/enemies/boss_guardian.png = 112x144, attendu 96x128
- pause / warning: taille incoherente: res://assets/enemies/boss_guardian.png = 112x144, attendu 96x128
- hurt / warning: taille incoherente: res://assets/enemies/boss_guardian.png = 112x144, attendu 96x128
- dead / warning: taille incoherente: res://assets/enemies/boss_guardian.png = 112x144, attendu 96x128
- info: placeholder detecte: res://assets/enemies/boss_guardian.png partage par [sleep, idle, charge, volley, slam_rise, slam_fall, pause, hurt, dead]

