extends CharacterBody3D

var state_machine
var animation_tree

const SPEED_CROUCH = 4
const SPEED_WALK = 7.5
const SPEED_RUN = 20
const TIME_TURN_WALK = 0.06
#const JUMP_VELOCITY_CROUCH = 39  #Questa non dovrebbe esistere, non deve saltare se in crouch #Faccio cio che L'Alessio comanda -Leon
const JUMP_VELOCITY_WALK = 39 #28
const JUMP_VELOCITY_RUN = 39


#Radio Boy Vars
var rb_last_direction_faced
var rb_angle_is_changing = 0
var rb_last_angle_faced : float = 360

var rb_current_finite_state_machine_state = "Idle"
var rb_player_is_active = 0
var rb_queue_idle = 0
var rb_queue_landing = 0
var rb_dont_allow_jump = 0
var rb_force_crouch = 0
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
	animation_tree = $Radio_Boy_Model/AnimationTree

func _physics_process(delta):
	rb_player_is_active = 0  #This needs to be the first processed variable
	animation_tree.set("parameters/conditions/IsFalling", false)
	animation_tree.set("parameters/conditions/GoInIdle", false)

	#-->Add gravity
	if not is_on_floor():
		rb_player_is_active = 1
		rb_queue_idle = 1
		velocity.y -= gravity * delta
	#<--

	if rb_queue_idle and !rb_player_is_active:
		rb_current_finite_state_machine_state = "Idle"
		rb_queue_idle = 0

	#-->Handle directions
	var input_dir = Input.get_vector("move_up", "move_down", "move_right", "move_left")
	var direction = (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()

	if direction:  #Handle directions (which are only two...)
		rb_player_is_active = 1
		rb_queue_idle = 1
		velocity.z = direction.z * rb_movement_speed

		if direction.z < 0:  #We are moving Right
			rb_last_direction_faced = "Right"
			Smooth_Turn(0, TIME_TURN_WALK)

		if direction.z > 0:  #We are moving Left
			rb_last_direction_faced = "Left"
			Smooth_Turn(180, TIME_TURN_WALK)

		if is_on_floor():
			rb_current_finite_state_machine_state = rb_movement_state

			if is_on_wall():
				animation_tree.set("parameters/conditions/GoInIdle", true)
				rb_current_finite_state_machine_state = "Idle"

	else:
		velocity.z = move_toward(velocity.z, 0, rb_movement_speed) 

		if rb_last_direction_faced == "Right":
			Smooth_Turn(-25, TIME_TURN_WALK)

		elif rb_last_direction_faced == "Left":
			Smooth_Turn(205, TIME_TURN_WALK)
	#<--

	if is_on_floor() and rb_queue_landing:
		rb_player_is_active = 1
		rb_current_finite_state_machine_state = "Landing"
		rb_queue_landing = 0

	#-->Handle jump and falling
	if Input.is_action_just_pressed("move_jump") \
			and is_on_floor() \
			and !rb_dont_allow_jump:
		rb_player_is_active = 1
		velocity.y = rb_movement_jump
		rb_current_finite_state_machine_state = "Jump_On_Floor"

	if !is_on_floor() and velocity.y < 0:
		rb_player_is_active = 1
		animation_tree.set("parameters/conditions/IsFalling", true)
		rb_current_finite_state_machine_state = "Falling"
		rb_queue_landing = 1
	#<--

	#-->Handle walk/run toggle.
	if Input.is_action_just_pressed("toggle_walk_or_run"): 
		rb_player_is_active = 1
		Handle_Movement()
	#<--

	#-->handle crouch
	if Input.is_action_pressed("crouch") and is_on_floor():
		rb_player_is_active = 1
		rb_current_finite_state_machine_state = "Crouch"
		Handle_Movement("Crouch")

	elif Input.is_action_just_released("crouch"):
		rb_player_is_active = 1
		rb_queue_idle = 1
		Handle_Movement("Crouchn't")
	#<--

	state_machine.travel(rb_current_finite_state_machine_state)

	move_and_slide()




###############################################################
#					 Character Functions					  #
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

	elif state == "Crouch" and rb_movement_state != "Crouch":
		rb_dont_allow_jump = 1
		rb_movement_state_previous = rb_movement_state
		rb_movement_speed_previous = rb_movement_speed
		rb_movement_jump_previous = rb_movement_jump
		rb_movement_state = "Crouch"
		rb_movement_speed = SPEED_CROUCH
		$CollisionShape3D.scale.y = 0.5
		$CollisionShape3D.position.y = 1.4

	elif state == "Crouchn't":
		rb_dont_allow_jump = 0
		rb_movement_state = rb_movement_state_previous
		rb_movement_speed = rb_movement_speed_previous
		$CollisionShape3D.scale.y = 1
		$CollisionShape3D.position.y = 2.8

	elif state == "Walk":
		rb_movement_state = "Walk"
		rb_movement_speed = SPEED_WALK
		rb_movement_jump = JUMP_VELOCITY_WALK

	elif state == "Run":
		rb_movement_state = "Run"
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
