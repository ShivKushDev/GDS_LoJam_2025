extends MeshInstance3D

@export var move_distance: float = 1.0
@export var move_speed: float = 0.5
@export var shake_intensity: float = 0.1
@export var is_horizontal: bool = true  # True = X-axis, False = Z-axis

@onready var static_body: StaticBody3D = $StaticBody3D
@onready var front_ray: RayCast3D = $FrontRay
@onready var back_ray: RayCast3D = $BackRay

var mouse_inside := false
var move_direction := Vector3.ZERO
var is_moving := false
signal removed

func _ready():
	static_body.input_ray_pickable = true
	static_body.mouse_entered.connect(_on_mouse_entered)
	static_body.mouse_exited.connect(_on_mouse_exited)
	
	front_ray.add_exception(static_body)
	back_ray.add_exception(static_body)
	
	# Set direction based on is_horizontal and ray target_position
	if is_horizontal:
		move_direction = Vector3.RIGHT if front_ray.target_position.x > 0 else Vector3.LEFT
	else:
		move_direction = Vector3.FORWARD if front_ray.target_position.z > 0 else Vector3.BACK

func _on_mouse_entered():
	mouse_inside = true

func _on_mouse_exited():
	mouse_inside = false

func try_remove():
	if is_moving or not mouse_inside:
		return
	
	# Force ray updates to detect moved pipes
	front_ray.force_raycast_update()
	back_ray.force_raycast_update()
	
	var can_move_front = not front_ray.is_colliding()
	var can_move_back = not back_ray.is_colliding()
	
	print("Front Ray Colliding: ", front_ray.is_colliding())
	print("Back Ray Colliding: ", back_ray.is_colliding())
	
	# Debug colliders
	if front_ray.is_colliding():
		print("Front Collider: ", front_ray.get_collider().name)
	if back_ray.is_colliding():
		print("Back Collider: ", back_ray.get_collider().name)
	
	if can_move_front:
		move_pipe(move_direction)
	elif can_move_back:
		move_pipe(-move_direction)
	else:
		shake_pipe()

func move_pipe(direction: Vector3):
	if is_moving: 
		return
	
	print("Moving Direction: ", direction)  # Debug
	is_moving = true
	var target_position = global_position + (direction * move_distance)
	print("Target Position: ", target_position)  # Debug
	
	var tween = create_tween().set_trans(Tween.TRANS_QUINT).set_ease(Tween.EASE_OUT)
	tween.tween_property(self, "global_position", target_position, move_speed)
	tween.tween_callback(func():
		is_moving = false
		removed.emit()
	)

func shake_pipe():
	var axis = "x" if is_horizontal else "z"
	var orig_pos = global_position
	var tween = create_tween()
	tween.set_parallel(true)
	tween.tween_property(self, "global_position:%s" % axis, orig_pos[axis] + shake_intensity, 0.1)
	tween.chain().tween_property(self, "global_position:%s" % axis, orig_pos[axis] - shake_intensity, 0.1)
	tween.chain().tween_property(self, "global_position:%s" % axis, orig_pos[axis], 0.1)

func _unhandled_input(event):
	if event.is_action_pressed("click") and mouse_inside:
		try_remove()
