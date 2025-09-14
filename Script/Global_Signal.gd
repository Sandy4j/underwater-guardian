extends Node2D

@export var bgm_sound:Array[AudioStreamWAV]
@export var sfx_sound:Array[AudioStreamWAV]
@onready var BGM:AudioStreamPlayer2D = $BGM
@onready var SFX:AudioStreamPlayer2D = $SFX
signal healing(heal:int)
signal activate_buff(buff:Buff_Data)



func play_sfx(v:int):
	match v:
		0:
			SFX.stream = sfx_sound.get(v)
			SFX.play()

func play_bgm(v:int):
	match v:
		0:
			print("memutar main menu")
			BGM.stream = bgm_sound.get(v)
			BGM.play(0)
			
		1:
			BGM.stream = bgm_sound.get(v)
			BGM.play(0)
			print("memutar gameplay")
