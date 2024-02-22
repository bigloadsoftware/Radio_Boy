extends CharacterBody3D

var mouse_vector

func _physics_process(_delta):
	#-->Handle aim.
	#To do list:
	#-This one needs a timer so it doesn't get processed every machine cycle (so we can make this a little bit more efficient)
	if Input.is_action_pressed("aim"):
		mouse_vector = (Vector2(get_viewport().get_mouse_position().x - (get_viewport().size.x/2), get_viewport().get_mouse_position().y - (get_viewport().size.y/2)))
		mouse_vector.x /= get_viewport().size.x
		mouse_vector.y /= get_viewport().size.y
		mouse_vector *= 12

		position.z = -mouse_vector.x
		position.y = -mouse_vector.y + 7

	else:
		position.z = 0
		position.y = 7

	if Input.is_action_just_pressed("aim"):
		$"..".Handle_Walk_Run_Toggle()
	elif Input.is_action_just_released("aim"):
		$"..".Handle_Walk_Run_Toggle()
	#<--

	move_and_slide()
