extends CharacterBody3D

@onready var ray_cast_3d: RayCast3D = $RayCast3D
@onready var gun: AnimatedSprite2D = $CanvasLayer/Gun_Hold/Gun
@onready var shoot_sound: AudioStreamPlayer = $Shoot_Sound

const SPEED = 0.3
const Mouse_Sens = 0.5

var can_shoot = true
var dead = false

func _ready() -> void:
	pass
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	gun.animation_finished.connect(shoot_anim_done)
	$CanvasLayer/DeathScreen/Death_Panel/Restart_Button.button_up.connect(restart)

func _input(event: InputEvent) -> void:
	pass 
	if dead:
		return
	if event is InputEventMouseMotion:
		rotation_degrees.y -= event.relative.x * Mouse_Sens
 
func _process(delta: float) -> void:
	if Input.is_action_just_pressed('Exit'):
		get_tree().quit()
	if Input.is_action_just_pressed('Restart'):
		restart()
	if Input.is_action_just_pressed("Shoot"):
		shoot()
	
	if dead:
		return

func _physics_process(delta: float) -> void:
	if dead:
		return
	
	var input_dir := Input.get_vector('Move_Left','Move_Right','Move_Forward','Move_Backward')
	var direction := (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	
	if direction:
		velocity.x = direction.x * SPEED
		velocity.z = direction.z * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		velocity.z = move_toward(velocity.z, 0, SPEED)

	move_and_slide()

func restart():
	get_tree().reload_current_scene()

func shoot():
	if !can_shoot:
		return
	can_shoot = false
	gun.play("shoot")
	shoot_sound.play()
	if ray_cast_3d.is_colliding() and ray_cast_3d.get_collider().has_method('kill'):
		ray_cast_3d.get_collider().kill()

func shoot_anim_done():
	can_shoot = true
	
	
func kill():
	dead = true
	$CanvasLayer/DeathScreen.show()
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
