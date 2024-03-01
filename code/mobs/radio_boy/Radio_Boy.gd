extends CharacterBody3D

var state_machine

const SPEED_WALK = 7.5
const SPEED_RUN = 20
const TIME_TURN_WALK = 0.06
const JUMP_VELOCITY_WALK = 28
const JUMP_VELOCITY_RUN = 39


#Radio Boy Vars
var rb_last_direction_faced
var rb_angle_is_changing = 0
var rb_last_angle_faced : float = 360

var rb_current_finite_state_machine_state = "Idle"
var rb_touchdown = 0
var rb_movement_state = "Run"
var rb_movement_speed = SPEED_RUN
var rb_movement_jump = JUMP_VELOCITY_RUN

var rb_movement_state_previous = "Run"
var rb_movement_speed_previous = SPEED_RUN
var rb_movement_jump_previous = JUMP_VELOCITY_RUN

#Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")

func _ready():
	$Radio_Boy_Model/AnimationTree.active = 1
	state_machine = $Radio_Boy_Model/AnimationTree.get("parameters/playback")

func _physics_process(delta):
	#-->Add gravity
	if not is_on_floor():
		velocity.y -= gravity * delta
	#<--

	#-->Handle jump and falling
	if Input.is_action_just_pressed("move_jump") and is_on_floor():
		velocity.y = rb_movement_jump
		rb_current_finite_state_machine_state = "Jump_On_Floor"

	if not is_on_floor():
		if velocity.y > 0:
			rb_current_finite_state_machine_state = "Jump_On_Floor"
		else:
			rb_current_finite_state_machine_state = "Falling"
			rb_touchdown = 1
	#<--

	#-->Handle walk/run toggle.
	if Input.is_action_just_pressed("toggle_walk_or_run"):
		Handle_Movement()
	#<--

	#-->Handle directions
	var input_dir = Input.get_vector("move_up", "move_down", "move_right", "move_left")
	var direction = (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()

	if direction:  #Handle directions (which are only two...)
		if direction.z < 0:  #We are moving Right
			rb_last_direction_faced = "Right"
			Smooth_Turn(0, TIME_TURN_WALK)

		if direction.z > 0:  #We are moving Left
			rb_last_direction_faced = "Left"
			Smooth_Turn(180, TIME_TURN_WALK)

		velocity.z = direction.z * rb_movement_speed
		
		if is_on_floor():
			rb_current_finite_state_machine_state = rb_movement_state

	else:
		velocity.z = move_toward(velocity.z, 0, rb_movement_speed)

		if is_on_floor():   
			if !rb_touchdown:
				rb_current_finite_state_machine_state = "Idle"  
			else:
				rb_current_finite_state_machine_state = "Idle"
				#rb_touchdown = 0

		if rb_last_direction_faced == "Right":
			Smooth_Turn(-25, TIME_TURN_WALK)
		elif rb_last_direction_faced == "Left":
			Smooth_Turn(205, TIME_TURN_WALK)
	#<--

	#-->handle crouch
	if Input.is_action_pressed("crouch") and is_on_floor():
		rb_current_finite_state_machine_state = "Crouch"
	#<--

	state_machine.travel(rb_current_finite_state_machine_state)


	move_and_slide()




###############################################################
#						Game Functions						  #
###############################################################

#-->Handle_Movement()
#To do list:
func Handle_Movement(state = "Toggle", memorize_last_movement = 0):
	if memorize_last_movement:
		rb_movement_state_previous = rb_movement_state
		rb_movement_speed_previous = rb_movement_speed
		rb_movement_jump_previous = rb_movement_jump

	if state == "Toggle":
		if rb_movement_state == "Run":
			rb_movement_state = "Walk"
			rb_movement_speed = SPEED_WALK
			rb_movement_jump = JUMP_VELOCITY_WALK
		elif rb_movement_state == "Walk":
			rb_movement_state = "Run"
			rb_movement_speed = SPEED_RUN
			rb_movement_jump = JUMP_VELOCITY_RUN

	elif state == "Walk":
		rb_movement_speed = SPEED_WALK
		rb_movement_jump = JUMP_VELOCITY_WALK

	elif state == "Run":
		rb_movement_speed = SPEED_RUN
		rb_movement_jump = JUMP_VELOCITY_RUN

	elif state == "Previous":
		rb_movement_state = rb_movement_state_previous
		rb_movement_speed = rb_movement_speed_previous
		rb_movement_jump = rb_movement_jump_previous

	return
#<--


#-->Smooth_Turn()
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

	if direction == "Right":
		if camera_position != direction:
			camera_position = "Right"
			while offset_to_fill >= (abs($Camera3D.position.z - $Radio_Boy_Model.position.z)):
				$Camera3D.position.z -= camera_steps
				await get_tree().create_timer(camera_step_time).timeout
				print(camera_step_time)
			$Camera3D.position.z = -offset_to_fill
			return

	if direction == "Left":
		if camera_position != direction:
			camera_position = "Left"
			while offset_to_fill >= (abs($Camera3D.position.z - $Radio_Boy_Model.position.z)):
				$Camera3D.position.z += camera_steps
				await get_tree().create_timer(camera_step_time).timeout
				print(camera_step_time)
			$Camera3D.position.z = +offset_to_fill
			return
#<--
