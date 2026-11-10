extends CharacterBody3D

const WALK_SPEED = 5.0
const CROUCH_SPEED = 2.5
const JUMP_VELOCITY = 4.5
const MOUSE_SENSITIVITY = 0.003

@export var stand_height := 1.8
@export var crouch_height := 1.0
@export var crouch_transition := 10.0

@onready var interact_ray: RayCast3D = $Head/Camera3D/InteractRay
@onready var head: Node3D = $Head
@onready var collision: CollisionShape3D = $CollisionShape3D
@onready var ceiling_check: RayCast3D = $CeilingCheck

var is_crouching := false
var prompt: Label


func _ready() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	_create_ui()


func _create_ui() -> void:
	var layer := CanvasLayer.new()
	add_child(layer)

	# White dot in the center (round)
	var dot := Panel.new()
	var style := StyleBoxFlat.new()
	style.bg_color = Color.WHITE
	style.set_corner_radius_all(100)
	dot.add_theme_stylebox_override("panel", style)
	dot.mouse_filter = Control.MOUSE_FILTER_IGNORE
	layer.add_child(dot)
	dot.set_anchors_preset(Control.PRESET_CENTER)
	dot.offset_left = -2
	dot.offset_right = 2
	dot.offset_top = -2
	dot.offset_bottom = 2

	# Prompt text under the dot
	prompt = Label.new()
	prompt.text = "Press E to meow"
	prompt.mouse_filter = Control.MOUSE_FILTER_IGNORE
	prompt.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	prompt.visible = false
	layer.add_child(prompt)
	prompt.set_anchors_preset(Control.PRESET_CENTER)
	prompt.offset_left = -100
	prompt.offset_right = 100
	prompt.offset_top = 15
	prompt.offset_bottom = 45


func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseMotion and Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
		rotate_y(-event.relative.x * MOUSE_SENSITIVITY)
		head.rotate_x(-event.relative.y * MOUSE_SENSITIVITY)
		head.rotation.x = clamp(head.rotation.x, deg_to_rad(-89), deg_to_rad(89))

	if event.is_action_pressed("ui_cancel"):
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE

	if event is InputEventMouseButton and event.pressed:
		Input.mouse_mode = Input.MOUSE_MODE_CAPTURED


func _physics_process(delta: float) -> void:
	handle_crouch(delta)

	var target := interact_ray.get_collider()
	var looking_at_cat: bool = target != null and target.is_in_group("cat")
	prompt.visible = looking_at_cat

	if looking_at_cat and Input.is_action_just_pressed("meow"):
		target.meow()

	# Gravity
	if not is_on_floor():
		velocity += get_gravity() * delta

	# Jump (not while crouching)
	if Input.is_action_just_pressed("jump") and is_on_floor() and not is_crouching:
		velocity.y = JUMP_VELOCITY

	var speed := CROUCH_SPEED if is_crouching else WALK_SPEED

	var input_dir := Input.get_vector("move_left", "move_right", "move_forward", "move_back")
	var direction := (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	if direction:
		velocity.x = direction.x * speed
		velocity.z = direction.z * speed
	else:
		velocity.x = move_toward(velocity.x, 0, speed)
		velocity.z = move_toward(velocity.z, 0, speed)

	move_and_slide()


func handle_crouch(delta: float) -> void:
	if Input.is_action_pressed("crouch"):
		is_crouching = true
	elif is_crouching and not ceiling_check.is_colliding():
		is_crouching = false

	var capsule := collision.shape as CapsuleShape3D
	var target := crouch_height if is_crouching else stand_height
	capsule.height = lerp(capsule.height, target, crouch_transition * delta)

	collision.position.y = capsule.height / 2.0
	head.position.y = capsule.height - 0.2
