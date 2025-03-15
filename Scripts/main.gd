# Main scene script (attached to root node)
extends Node3D

@onready var timer: Timer = $Timer
@onready var time_label: Label = $TimeLabel

var pipes_remaining := 0

func _ready():
	timer.timeout.connect(_on_timer_timeout)
	pipes_remaining = get_tree().get_nodes_in_group("pipes").size()

func _on_pipe_removed():
	pipes_remaining -= 1
	if pipes_remaining <= 0:
		print("win")

func _on_timer_timeout():
	print("lost")

func _physics_process(delta):
	time_label.text = "Time: %.1f" % timer.time_left
