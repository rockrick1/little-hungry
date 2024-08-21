extends Control

const UI_SIZE = 4

@export var player : Player

@onready var width := custom_minimum_size.y

var going_back := false

var difficulties := [
	[.5, 80, 150],
	[1, 30, 200],
	[1.5, 25, 250],
	[2, 15, 300],
	[3, 5, 350],
	[6, 3, 400],
	[INF, 2, 1000],
]
var difficulty : int
var speed := 1

func _ready():
	visible = false
	player.try_hunt.connect(_on_try_hunt)
	player.hunt_action.connect(_on_hunt_action)
	player.hunt_failed.connect(_on_hunt_failed)

func _on_try_hunt(animal_size: Vector3):
	var size_difference = animal_size.x / player.current_size.x
	for i in range(len(difficulties)):
		var params = difficulties[i]
		if size_difference > params[0]:
			continue
		
		difficulty = params[1]
		speed = params[2]
		_start()
		return

func _start():
	visible = true
	$ProgressBar.value = 0
	%HitArea.custom_minimum_size.x = difficulty * UI_SIZE

func _on_hunt_action():
	visible = false
	
	if $ProgressBar.value >= 50 - (difficulty / 2) and $ProgressBar.value <= 50 + (difficulty / 2):
		player.hunt_success()
	else:
		player.hunt_failure()

func _on_hunt_failed():
	visible = false

func _process(delta: float) -> void:
	if not visible:
		return
	
	delta *= 10
	var change = delta * speed
	if $ProgressBar.value + change > 100:
		going_back = true
	elif $ProgressBar.value - change < 0:
		going_back = false
	if going_back:
		change *= -1
	$ProgressBar.value += change
