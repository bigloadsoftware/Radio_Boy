extends CharacterBody3D

const SPEED = 8.0
const JUMP_VELOCITY = 4.5

#Camera Vars
var camera_offset_z = 12
var camera_position


#Mob Vars
var last_direction

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = 0 # ProjectSettings.get_setting("physics/3d/default_gravity")


func _physics_process(delta):
	# Add the gravity.
	if not is_on_floor():
		velocity.y -= gravity * delta

	# Handle jump.
	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		velocity.y = JUMP_VELOCITY

	var input_dir = Input.get_vector("move_up", "move_down", "move_right", "move_left")
	var direction = (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()

	if direction:  #Handle directions (which are only two...)
		if direction.z < 0:  #We are moving right
			last_direction = "right"
			$Radio_Boy_Model.rotation.y = 0
			move_camera("right", 0.01, 6)

		if direction.z > 0:  #We are moving left
			last_direction = "left"
			$Radio_Boy_Model.rotation.y = 3.14  #I guess we are not using regular degrees, we are using radians
			move_camera("left", 0.01, 6)

		velocity.z = direction.z * SPEED
		$Radio_Boy_Model/AnimationPlayer.play("Walk test")
	else:
		velocity.z = move_toward(velocity.z, 0, SPEED)
		$Radio_Boy_Model/AnimationPlayer.play("Wink")
		if last_direction == "right":
			$Radio_Boy_Model.rotation.y = -0.611
		elif last_direction == "left":
			$Radio_Boy_Model.rotation.y = 3.751

	move_and_slide()


func move_camera(direction, time_taken_to_move, offset_to_fill):
	var camera_steps = offset_to_fill * 0.05
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
	
