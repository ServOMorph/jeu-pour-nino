extends Node

# Generateur de sons placeholder : aucune ressource externe, tout en code.
# Chaque effet est une courte onde generee une fois et rejouee a la demande.

const MIX_RATE := 22050

var _streams := {}
var _players: Array[AudioStreamPlayer] = []
var _next := 0

func _ready() -> void:
	_streams["jump"] = _tone(520.0, 0.10, 0.25, "square")
	_streams["hit"] = _tone(300.0, 0.08, 0.30, "square")
	_streams["hurt"] = _tone(150.0, 0.18, 0.35, "saw")
	_streams["boss"] = _tone(90.0, 0.5, 0.35, "saw")
	_streams["victory"] = _tone(660.0, 0.5, 0.30, "sine")
	_streams["gameover"] = _tone(120.0, 0.6, 0.35, "sine")
	_streams["mine"] = _tone(420.0, 0.07, 0.28, "square")
	_streams["mine_break"] = _tone(220.0, 0.14, 0.32, "saw")
	_streams["cant_craft"] = _tone(180.0, 0.12, 0.28, "saw")
	_streams["potion"] = _tone(600.0, 0.18, 0.22, "sine")
	_streams["shoot"] = _tone(700.0, 0.06, 0.22, "square")
	for i in range(6):
		var p := AudioStreamPlayer.new()
		add_child(p)
		_players.append(p)

func play(name: String) -> void:
	if not _streams.has(name):
		return
	var p := _players[_next]
	_next = (_next + 1) % _players.size()
	p.stream = _streams[name]
	p.play()

func _tone(freq: float, duration: float, volume: float, shape: String) -> AudioStreamWAV:
	var count := int(MIX_RATE * duration)
	var data := PackedByteArray()
	data.resize(count * 2)
	for i in range(count):
		var t := float(i) / float(MIX_RATE)
		var phase := fmod(t * freq, 1.0)
		var s := 0.0
		match shape:
			"square":
				s = 1.0 if phase < 0.5 else -1.0
			"saw":
				s = phase * 2.0 - 1.0
			_:
				s = sin(phase * TAU)
		# Enveloppe de decroissance
		var env := 1.0 - float(i) / float(count)
		var val := int(clamp(s * env * volume, -1.0, 1.0) * 32767.0)
		data[i * 2] = val & 0xFF
		data[i * 2 + 1] = (val >> 8) & 0xFF
	var wav := AudioStreamWAV.new()
	wav.format = AudioStreamWAV.FORMAT_16_BITS
	wav.mix_rate = MIX_RATE
	wav.stereo = false
	wav.data = data
	return wav
