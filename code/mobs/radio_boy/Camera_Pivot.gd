extends CharacterBody3D

#Camera Vars
var mouse_vector
var camera_offset = transform.basis * Vector3(0, 7, 0) #our used vars are y and z
var camera_aim_speed = 10 #what is this variable exactly?
var camera_recenter_character_speed = 6
var camera_center_cursor_speed = 12
var camera_aim_reach = 20  #(i think that it is higher) #You're right.... -Leon

#Outer Node Vars
var rb_movement_state_previous

func _physics_process(_delta):
	#-->Handle aim
	#To do list:
	#-This one needs a timer so it doesn't get processed every machine cycle (so we can make this a little bit more efficient)
	if Input.is_action_just_pressed("aim"):
		rb_movement_state_previous = $"..".rb_movement_state
		$"..".Handle_Movement("Walk", 1)

	if Input.is_action_just_released("aim"):
		$"..".Handle_Movement("Previous")

	if Input.is_action_pressed("aim"):
		mouse_vector = (Vector2(get_viewport().get_mouse_position().x - (get_viewport().size.x/2), get_viewport().get_mouse_position().y - (get_viewport().size.y/2)))
		mouse_vector.x /= get_viewport().size.x
		mouse_vector.y /= get_viewport().size.y
		mouse_vector *= camera_aim_reach

		velocity.z = (-mouse_vector.x - position.z) * camera_center_cursor_speed
		velocity.y = (-mouse_vector.y + camera_offset.y - position.y) * camera_center_cursor_speed

	else:
		velocity.z = (camera_offset.z - position.z) * camera_recenter_character_speed
		velocity.y = (camera_offset.y - position.y) * camera_recenter_character_speed

	#<--

	move_and_slide()
