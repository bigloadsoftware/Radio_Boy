extends CharacterBody3D

#Camera Vars
var mouse_vector
var camera_offset = transform.basis * Vector3(0, 7, 0) #our used vars are y and z
var camera_recenter_speed = 10
var camera_aim_reach = 12  #lower number means that character can aim further away

#Outer Node Vars
var rb_state_walk_or_run_previous

func _physics_process(_delta):
	#-->Handle aim
	#To do list:
	#-This one needs a timer so it doesn't get processed every machine cycle (so we can make this a little bit more efficient)
	if Input.is_action_just_pressed("aim"):
		rb_state_walk_or_run_previous = $"..".rb_state_walk_or_run

	if Input.is_action_pressed("aim"):
		mouse_vector = (Vector2(get_viewport().get_mouse_position().x - (get_viewport().size.x/2), get_viewport().get_mouse_position().y - (get_viewport().size.y/2)))
		mouse_vector.x /= get_viewport().size.x
		mouse_vector.y /= get_viewport().size.y
		mouse_vector *= camera_aim_reach

		position.z = -mouse_vector.x
		position.y = -mouse_vector.y + camera_offset.y

	else:
		velocity.z = (camera_offset.z - position.z) * camera_recenter_speed
		velocity.y = (camera_offset.y - position.y) * camera_recenter_speed

	if rb_state_walk_or_run_previous == "Run":
		if Input.is_action_just_pressed("aim"):
			$"..".Handle_Walk_Run_Toggle("Run")
		elif Input.is_action_just_released("aim"):
			$"..".Handle_Walk_Run_Toggle("Walk")

	#<--

	move_and_slide()
