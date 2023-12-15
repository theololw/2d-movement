extends CharacterBody2D

# dash variables
@export var dashSpeed = 6000
@export var dashLength = 0.05
@export var dashCooldown = 1.5
var dashReady = 1

# speed variables
@export var speed = 1201
var normalSpeed


@export var jump_speed = -1000

# gravity variables
@export var gravity = 2500
var normalGravity = gravity
@export var jumpTimer = 0.1
@export_range(0.0, 1.0) var friction = 0.3
@export_range(0.0 , 1.0) var acceleration = 0.25
@onready var CoyoteTimer = $CoyoteTimer
func _ready():
	normalSpeed = speed
	normalGravity = gravity

func _physics_process(delta):
	dashMode()
	platformerMovement(delta)
	jumpMode(delta)
	godMode()
	
	
func platformerMovement(delta):
	# left right controls with gravity, speed, acceleration and friction
	
	velocity.y += gravity * delta
	
	var dir = Input.get_axis("walk_left", "walk_right")
	
	if dir != 0:
		velocity.x = lerp(velocity.x, dir * speed, acceleration)
	else:
		velocity.x = lerp(velocity.x, 0.0, friction)
func jumpMode(delta):
	# 2d platformer jump mechanic with coyote timer and jump buffering
	
	var was_on_floor = is_on_floor()
	move_and_slide()
	if was_on_floor and !is_on_floor():
		CoyoteTimer.start()
	if Input.is_action_just_pressed("jump"):
		jumpTimer = 0.1
	
	jumpTimer -= delta
	
	if jumpTimer > 0 and (is_on_floor() or !CoyoteTimer.is_stopped()):
		velocity.y = jump_speed
func dashMode():
	# super simple dash. dash once in the air, reset on ground. Dash = velocity+
	if is_on_floor():
		dashReady = 1
	print(dashReady)
	if Input.is_action_just_pressed("dash") and dashReady == 1:
		# dash
		dashReady = 0
		gravity = 0
		speed = dashSpeed
		velocity.y = 0
		await get_tree().create_timer(dashLength).timeout
		speed = normalSpeed
		await get_tree().create_timer(dashLength + 0.15).timeout
		gravity = normalGravity
		
func godMode():
	# godmode stuff
	
	# respawn mechanic
	if Input.is_action_just_pressed("r"):
		get_tree().reload_current_scene()
		print("pressed r")
	
	# gravity toggle
	if Input.is_action_just_pressed("f") and gravity == normalGravity:
		gravity = 0
		velocity.y = 0
		print("gravity off")
	elif Input.is_action_just_pressed("f") and gravity != normalGravity:
		gravity = normalGravity
		print("gravity on")
