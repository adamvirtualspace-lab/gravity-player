extends RigidBody3D



### ----- Defining Variables Starts Here ----- ###
### ----- Defining Variables Starts Here ----- ###

# Movement settings
var movement_speed: float = 1.0
var movement_force: float = 30.0

# Reference to camera pivots
var CamPivot_LR: Node3D

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	# Get reference to CamPivot_LR
	CamPivot_LR = get_node("CamPivotManager/CamPivot_RotateLeftRight")
	linear_damp = 2.0  # Add this - creates friction

### ----- Defining Variables Ends Here ----- ###
### ----- Defining Variables Ends Here ----- ###




# Called every physics frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta: float) -> void:

	# Defining Input Direction and set it 0 in every tick
	var input_direction = Vector3.ZERO
	# Overriding Input Direction if movement keys are pressed
	if Input.is_action_pressed("MoveForward"):
		input_direction.z -= 1.0
	if Input.is_action_pressed("MoveBackward"):
		input_direction.z += 1.0
	if Input.is_action_pressed("MoveLeft"):
		input_direction.x += 1.0
	if Input.is_action_pressed("MoveRight"):
		input_direction.x -= 1.0

	# If there's input, apply movement
	if input_direction != Vector3.ZERO:
		# Normalize the input direction
		input_direction = input_direction.normalized()

		# Get forward and right vectors from CamPivot_LR
		var pivot_forward = -CamPivot_LR.global_transform.basis.z
		var pivot_right = CamPivot_LR.global_transform.basis.x

		# Flatten the forward vector to the ground plane (ignore Y)
		pivot_forward.y = 0
		pivot_forward = pivot_forward.normalized()

		# Calculate movement direction relative to CamPivot_LR
		var move_direction = (pivot_forward * input_direction.z) + (pivot_right * input_direction.x)
		move_direction = move_direction.normalized()

		# Apply central impulse for movement
		# We use delta to make it framerate-independent
		#apply_central_impulse(move_direction * movement_force * delta)
		
		# NEW - applies continuous force (friction will balance it out)
		apply_central_force(move_direction * movement_force)
