class_name Player
extends CharacterBody3D

const LERP_VALUE : float = 0.25
const ANIMATION_BLEND : float = 7
const SCALE_ANIMATION_TIME := 1

@export var gravity : float = 50.0

@onready var character_component := $CharacterComponent
@onready var spring_arm_pivot := $SpringArmPivot
@onready var mesh : Node3D = $LookAtPivot/Mesh
@onready var animator := $AnimationTree
@onready var movement_state_machine := $MovementStateMachine
@onready var consumption_area := $LookAtPivot/ConsumptionArea

var using_ability := false
var current_size := scale

var cc : CharacterComponent:
	get:
		return character_component
var snap_vector : Vector3 = Vector3.DOWN
var h_speed : float

func _ready():
	cc.died.connect(_on_died)
	cc.damaged.connect(_on_damaged)
	#primary_weapon.shot_fired.connect(_on_primary_shot_fired)
	#secondary_weapon.shot_fired.connect(_on_secondary_shot_fired)
	movement_state_machine.initialize()

func _process(_delta):
	_look_at_cursor()
	
	using_ability = false
	
	if Input.is_action_just_pressed("left_click"):
		_try_consume()
	
	if Input.is_action_pressed("left_click"):
		using_ability = true
		
	if Input.is_action_just_pressed("right_click"):
		_try_use_ability()

func update_rotation():
	$LookAtPivot.rotation.y = lerp_angle($LookAtPivot.rotation.y, atan2(velocity.x, velocity.z), LERP_VALUE)

#func get_weapon_target_vector() -> Vector3:
	#var target : Vector3
	#if weapon_ray.is_colliding() and (weapon_ray.get_collision_point() - weapon_ray.global_transform.origin).length() > 0.2:
		#target = weapon_ray.get_collision_point()
	#else:
		#target = (weapon_ray.target_position.z * weapon_ray.global_transform.basis.z) + weapon_ray.global_transform.origin
	#return target

func _look_at_cursor():
	if not using_ability:
		return
	
	var ray_origin
	var ray_end
	
	var space_state = get_world_3d().direct_space_state
	var mouse_position = get_viewport().get_mouse_position()
	ray_origin = %Camera3D.project_ray_origin(mouse_position)
	ray_end = ray_origin + %Camera3D.project_ray_normal(mouse_position) * 20000
	var query = PhysicsRayQueryParameters3D.new()
	query.from = ray_origin
	query.to = ray_end
	query.collide_with_bodies = true
	query.collision_mask = 128
	var intersection = space_state.intersect_ray(query)
	
	if not intersection.is_empty():
		var pos = intersection.position
		$LookAtPivot.look_at(pos)
		$LookAtPivot.rotation.y += PI
	

func _try_consume():
	for body in consumption_area.get_overlapping_bodies():
		if body is not BaseAnimal:
			continue
		_consume(body)
		return

func _try_use_ability():
	
	pass

func _consume(animal: BaseAnimal):
	animal.consume()
	_change_size(animal.size_value)
	cc.add_ability(animal.ability)
	pass

func _change_size(amount: float):
	current_size += Vector3(amount, amount, amount)
	var tween = create_tween()
	tween.set_ease(Tween.EASE_IN_OUT)
	tween.set_trans(Tween.TRANS_CUBIC)
	tween.tween_property(self, "scale", current_size, SCALE_ANIMATION_TIME)

func _on_damaged(amount: int):
	pass

func _on_died():
	print("YOU DIED!!!")
