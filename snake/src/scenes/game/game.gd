extends MarginContainer


func _on_game_over_timeout() -> void:
	get_tree().change_scene_to_file("res://src/scenes/game_over/game_over.tscn")


func _on_grid_food_eaten() -> void:
	Global.score += 5
	if Global.score % 25 == 0:
		%Grid.increase_pace()
	%Points.count = Global.score


func _on_grid_game_over() -> void:
	Global.save_high_score()
	%Pause.disabled = true
	%Points.blink_count()
	$GameOver.start()


func _on_pause_toggled(value: bool) -> void:
	%Grid.is_paused = value
	%Grid.visible = not value
	%PauseOverlay.visible = value


func _on_start_timeout() -> void:
	%Pause.disabled = false
	%StartOverlay.visible = false
	%Grid.visible = true
	%Grid.start()


func _on_turn_left_pressed() -> void:
	%Grid.snake_turn_left()


func _on_turn_right_pressed() -> void:
	%Grid.snake_turn_right()

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel"):
		get_tree().quit()

func _ready() -> void:
	Global.score = 0

# Still looking for any player input handling logic, heh?
# That is fully accomplished by the buttons shortcuts and their `pressed`
# signal callbacks. This way you could, for example, export the project to a
# mobile device and don't require a computer keyboard to play the game.
# Just don't rely on it too much...


func _on_turn_up_pressed() -> void:
	pass # Replace with function body.
