extends CharacterBody2D

const GRAVITY : int = 4200
const JUMP_SPEED : int = -1800
const JUMP_BACK : int = 20

@onready var camera = $"../Camera2D"
	

func jump_back():
	if Input.is_action_pressed("ui_left") or Input.is_key_pressed(KEY_A):
		position.x = position.x - JUMP_BACK
		camera.position.x = camera.position.x - JUMP_BACK

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta):
	velocity.y += GRAVITY * delta
	jump_back()
	if is_on_floor():
		if not get_parent().game_running:
			$AnimatedSprite2D.play("idle")
		else:
			$RunCol.disabled = false
			if Input.is_action_pressed("ui_accept") or Input.is_key_pressed(KEY_W):
				velocity.y = JUMP_SPEED
				#$JumpSound.play()
			elif Input.is_action_pressed("ui_down") or Input.is_key_pressed(KEY_S):
				$AnimatedSprite2D.play("duck")
				$RunCol.disabled = true
			else:
				$AnimatedSprite2D.play("run")
	else:
		$AnimatedSprite2D.play("jump")
		
	move_and_slide()
