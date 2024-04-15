# rudimental animal crossing like speech acls

extends AudioStreamPlayer3D

var speech_string = "hello world! it's nice to be alive!"  #change this line and start the game! (I know I have to make it less lazy))))
var spacebar_pointer = 0
var spacebar_counter

func _ready():
	
	#while speech_string.length() > spacebar_pointer:
		#if speech_string.find(" ", spacebar_pointer) > 0:
			#spacebar_pointer = speech_string.find(" ", spacebar_pointer)
			#spacebar_counter.append(spacebar_pointer)
#
		#spacebar_pointer += 1


	for i in round(speech_string.length()/5):
		pitch_scale = randf_range(0.5, 1.2)
		playing = true
		await get_tree().create_timer(randf_range(0.1, 0.3)).timeout
	pass


func _process(_delta):
	pass
