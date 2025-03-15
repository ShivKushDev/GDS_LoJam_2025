extends MeshInstance3D

@export var move_speed: float = 2.0
@export var shake_intensity: float = 0.1

@onready var static_body: StaticBody3D = $StaticBody3D
@onready var raycasts: Array[RayCast3D] = [$FrontRay, $BackRay]

var mouse_inside := false
var move_direction := Vector3.ZERO
var target_position := Vector3.ZERO
var is_moving := false
var can_remove := true

func _ready():
	await get_tree().process_frame
	static_body.mouse_entered.connect(_on_mouse_entered)
	static_body.mouse_exited.connect(_on_mouse_exited)
	
	for ray in raycasts:
		if ray:
			ray.target_position = Vector3.ZERO
			ray.force_raycast_update()
	
	if raycasts.size() > 0 && raycasts[0]:
		var local_dir = raycasts[0].global_transform.basis.z
		move_direction = local_dir.normalized()

func _on_mouse_entered():
	mouse_inside = true

func _on_mouse_exited():
	mouse_inside = false

func try_remove():
	if is_moving || !can_remove || !raycasts.all(func(r): return r != null):
		return
	
	for ray in raycasts:
		ray.force_raycast_update()
		if !ray.is_colliding():
			var space_state = get_world_3d().direct_space_state
			var query = PhysicsRayQueryParameters3D.create(
				ray.global_position,
				ray.global_position + ray.target_position
			)
			var result = space_state.intersect_ray(query)
			if result:
				target_position = result.position - move_direction * 0.1
				start_movement()
				return
	shake_pipe()

func start_movement():
	is_moving = true
	var tween = create_tween().set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	tween.tween_property(self, "global_position", target_position, move_speed)
	tween.tween_callback(func(): 
		is_moving = false
		move_direction *= -1
	)

func shake_pipe():
	var orig_pos = global_position
	var tween = create_tween().set_parallel(true)
	tween.tween_property(self, "position:x", orig_pos.x + shake_intensity, 0.1)
	tween.chain().tween_property(self, "position:x", orig_pos.x - shake_intensity, 0.1)
	tween.chain().tween_property(self, "position:x", orig_pos.x, 0.1)

func _unhandled_input(event):
	if event.is_action_pressed("click") && mouse_inside:
		try_remove()
