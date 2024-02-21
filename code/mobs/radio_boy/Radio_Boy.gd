extends CharacterBody3D

const SPEED_WALK = 7.5
const TIME_TURN_WALK = 0.05
const JUMP_VELOCITY_WALK = 15


#Radio Boy Vars
var rb_last_direction_faced
var rb_angle_is_changing = 0
var rb_last_angle_faced : float = 360

#Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")


func _physics_process(delta):
	#-->Add gravity
	if not is_on_floor():
		velocity.y -= gravity * delta
	#<--

	#-->Handle jump.
	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		velocity.y = JUMP_VELOCITY_WALK
	#<--

	#-->Handle directions
	var input_dir = Input.get_vector("move_up", "move_down", "move_right", "move_left")
	var direction = (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()

	if direction:  #Handle directions (which are only two...)
		if direction.z < 0:  #We are moving right
			rb_last_direction_faced = "right"
			Smooth_Turn(0, TIME_TURN_WALK)


		if direction.z > 0:  #We are moving left
			rb_last_direction_faced = "left"
			Smooth_Turn(180, TIME_TURN_WALK)


		velocity.z = direction.z * SPEED_WALK
		$Radio_Boy_Model/AnimationPlayer.play("Walk")

	else:
		velocity.z = move_toward(velocity.z, 0, SPEED_WALK)
		$Radio_Boy_Model/AnimationPlayer.play("Idle")
		if rb_last_direction_faced == "right":
			Smooth_Turn(-25, TIME_TURN_WALK)
		elif rb_last_direction_faced == "left":
			Smooth_Turn(205, TIME_TURN_WALK)

	move_and_slide()



#-->Smooth Turn()
#Function that makes the player turn to an angle with a determined speed
#the FPS needed to make it smooth are calculated dynamically
#If time_taken = 0, then rotate istantaneously
#To do list:
#-Add a manual input to force the rotation on user's decision instead of shortest path
func Smooth_Turn(angle_to_reach, time_taken):
	if(!time_taken):
		rb_last_angle_faced = angle_to_reach
		$Radio_Boy_Model.rotation.y = deg_to_rad(angle_to_reach)
		return

	if(angle_to_reach <= 0):
		angle_to_reach = 360 + angle_to_reach

	if((angle_to_reach != rb_last_angle_faced) && not rb_angle_is_changing):
		rb_angle_is_changing = 1
		var fps = time_taken * 100
		var angle_steps : float
		var angle_real_time : float = rb_last_angle_faced
		var time_taken_steps : float = float(time_taken) / float(fps)

		if(angle_to_reach - rb_last_angle_faced > 0):
			angle_steps = float(angle_to_reach - rb_last_angle_faced) / float(fps)
			for i in range(fps):  #60fps
				angle_real_time += angle_steps
				$Radio_Boy_Model.rotation.y = deg_to_rad(angle_real_time)
				await get_tree().create_timer(time_taken_steps).timeout
		
		else:
			angle_steps = float(rb_last_angle_faced - angle_to_reach) / float(fps)
			for i in range(fps):  #60fps
				angle_real_time -= angle_steps
				$Radio_Boy_Model.rotation.y = deg_to_rad(angle_real_time)
				await get_tree().create_timer(time_taken_steps).timeout

		rb_last_angle_faced = angle_to_reach
		$Radio_Boy_Model.rotation.y = deg_to_rad(angle_to_reach)
		rb_angle_is_changing = 0
		return
#<--


#-->Move_Camera()
#To do list:
#-Fucking everything, this one is a mess
func Move_Camera(direction, time_taken_to_move, offset_to_fill):
	var camera_position
	var camera_steps = offset_to_fill * 0.1
	var camera_step_time = time_taken_to_move * 0.01

	if direction == "right":
		if camera_position != direction:
			camera_position = "right"
			while offset_to_fill >= (abs($Camera3D.position.z - $Radio_Boy_Model.position.z)):
				$Camera3D.position.z -= camera_steps
				await get_tree().create_timer(camera_step_time).timeout
				print(camera_step_time)
			$Camera3D.position.z = -offset_to_fill
			return
	
	if direction == "left":
		if camera_position != direction:
			camera_position = "left"
			while offset_to_fill >= (abs($Camera3D.position.z - $Radio_Boy_Model.position.z)):
				$Camera3D.position.z += camera_steps
				await get_tree().create_timer(camera_step_time).timeout
				print(camera_step_time)
			$Camera3D.position.z = +offset_to_fill
			return
#<--
