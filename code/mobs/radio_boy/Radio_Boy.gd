extends CharacterBody3D

const SPEED_WALK = 5.0
const JUMP_VELOCITY_WALK = 15

#Camera Vars
var camera_offset_z = 12
var camera_position


#Monitor Textures
var image = Image.load_from_file("res://models/mobs/radio_boy/Monitor_Blank_V1.png")
var blank_monitor_texture = ImageTexture.create_from_image(image)
var image_2 = Image.load_from_file("res://models/mobs/radio_boy/Radio_Boy_V1_1.png")
var default_monitor_texture = ImageTexture.create_from_image(image_2)



#Mob Vars
var last_direction

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")


func _physics_process(delta):
	# Add the gravity.
	if not is_on_floor():
		velocity.y -= gravity * delta

	# Handle jump.
	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		velocity.y = JUMP_VELOCITY_WALK

	var input_dir = Input.get_vector("move_up", "move_down", "move_right", "move_left")
	var direction = (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	$Radio_Boy_Model.rotation.y = deg_to_rad(270)


	#$Radio_Boy_Model/Node/Root/Torso2/Neck2/Head2/Monitor/Sprite3D.texture = blank_monitor_texture
	#await get_tree().create_timer(1).timeout
	#
	#$Radio_Boy_Model/Node/Root/Torso2/Neck2/Head2/Monitor/Sprite3D.texture = default_monitor_texture
	#await get_tree().create_timer(1).timeout

	if direction:  #Handle directions (which are only two...)
		if direction.z < 0:  #We are moving right
			last_direction = "right"
			$Radio_Boy_Model.rotation.y = 0
			#move_camera("right", 0.2, 6)  

		if direction.z > 0:  #We are moving left
			last_direction = "left"
			$Radio_Boy_Model.rotation.y = deg_to_rad(180)  #I guess we are not using regular degrees, we are using radians
			#move_camera("left", 0.2, 6)

		velocity.z = direction.z * SPEED_WALK
		$Radio_Boy_Model/AnimationPlayer.play("Walk")
	else:
		velocity.z = move_toward(velocity.z, 0, SPEED_WALK)
		$Radio_Boy_Model/AnimationPlayer.play("Idle")
		if last_direction == "right":
			$Radio_Boy_Model.rotation.y = deg_to_rad(325)
		elif last_direction == "left":
			$Radio_Boy_Model.rotation.y = deg_to_rad(215)

	move_and_slide()


func move_camera(direction, time_taken_to_move, offset_to_fill):
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

