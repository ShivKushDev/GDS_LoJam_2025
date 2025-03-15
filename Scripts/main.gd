extends Node3D

@onready var timer: Timer = $Timer
@onready var time_label: Label = $TimeLabel

var pipes_remaining := 0

func _ready():
	# Initialize pipes
	pipes_remaining = get_tree().get_nodes_in_group("pipes").size()
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
	print("All pipes removed! You win!")
	# Add your victory logic here

func show_game_over():
	print("Time's up! Game Over!")
	# Add your loss logic here
