extends CharacterBody3D

#Camera Vars
var mouse_vector
var joypad_vector = Vector2(0, 0)
var joypad_trigger_threshold : float = 0.05
var camera_offset = transform.basis * Vector3(0, 7, 0) #our used vars are y and z
var camera_aim_speed = 10 #what is this variable exactly?
var camera_recenter_character_speed = 10
var camera_center_cursor_speed = 12
var camera_center_cursor_speed_joystick = 6
var camera_aim_reach = 20  #(i think that it is higher) #You're right.... -Leon
var camera_aim_reach_joystick = 14

#Outer Node Vars
var rb_movement_state_previous

func _physics_process(_delta):
	#-->Handle aim
	#Right Joystick input
	joypad_vector.x = Input.get_action_strength("joypad_aim_right") - Input.get_action_strength("joypad_aim_left")
	joypad_vector.y = -Input.get_action_strength("joypad_aim_up") + Input.get_action_strength("joypad_aim_down")

	if Input.is_action_pressed("aim"):
		mouse_vector = (Vector2(get_viewport().get_mouse_position().x - (get_viewport().size.x/2), get_viewport().get_mouse_position().y - (get_viewport().size.y/2)))
		mouse_vector.x /= get_viewport().size.x
		mouse_vector.y /= get_viewport().size.y
		mouse_vector *= camera_aim_reach

		velocity.z = (-mouse_vector.x - position.z) * camera_center_cursor_speed
		velocity.y = (-mouse_vector.y + camera_offset.y - position.y) * camera_center_cursor_speed

	elif abs(joypad_vector.x) > joypad_trigger_threshold or abs(joypad_vector.y) > joypad_trigger_threshold:
		joypad_vector *= camera_aim_reach_joystick

		velocity.z = (-joypad_vector.x - position.z) * camera_center_cursor_speed_joystick
		velocity.y = (-joypad_vector.y + camera_offset.y - position.y) * camera_center_cursor_speed_joystick

	else:
		velocity.z = (camera_offset.z - position.z) * camera_recenter_character_speed
		velocity.y = (camera_offset.y - position.y) * camera_recenter_character_speed
	#<--

	move_and_slide()
