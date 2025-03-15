extends Node3D

@onready var timer: Timer = $Timer
@onready var time_label: Label = $TimeLabel

@onready var exit: MeshInstance3D = $Exit
@onready var reactor: MeshInstance3D = $Reactor

@onready var victory_screen: CanvasLayer = $CanvasLayer

var pipes_remaining := 0

func _ready():
	# Initialize pipes
	pipes_remaining = get_tree().get_nodes_in_group("pipes").size()
	victory_screen.set_visible(false)
	timer.start()
	
	# Connect all pipes
	for pipe in get_tree().get_nodes_in_group("pipes"):
		pipe.removed.connect(_on_pipe_removed)

func _on_pipe_removed():
	pipes_remaining -= 1
	if pipes_remaining <= 0:
		show_victory()

func _on_timer_timeout():
	show_game_over()

func _physics_process(_delta):
	time_label.text = "Time: %.1f" % timer.time_left

func show_victory():
	time_label.set_visible(false)
	timer.stop()
	# Add your victory logic here
	var tween = create_tween().set_trans(Tween.TRANS_QUINT).set_ease(Tween.EASE_IN_OUT)
	tween.set_parallel()
	tween.tween_property(reactor, "global_position:y", 10.0, 4.0)
	tween.tween_property(exit, "global_position:y", 9.0, 4.0)
	await tween.finished
	await get_tree().create_timer(1.0, false).timeout
	victory_screen.set_visible(true)

func show_game_over():
	victory_screen.set_visible(true)
	var label = victory_screen.get_node("VBoxContainer/Label")
	label.set_text("You Lose!")
	label.set_visible(true)
	# Add your loss logic here


func _on_area_3d_body_entered(body: Node3D) -> void:
	if body.get_parent().name == "Reactor":
		show_victory()
	else:
		print(body, " ", body.get_parent())


func _on_button_pressed() -> void:
	get_tree().reload_current_scene()
