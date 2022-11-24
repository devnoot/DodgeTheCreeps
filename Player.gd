extends Area2D
# Create a signal called hit
# When the player collides with something, the `hit` signal will be emitted
signal hit

# The player speed
# Using the 'export' keyword allows the speed to be adjusted in the inspector
export var speed = 400
var screen_size

# The ready function is invoked when the node enters the scene tree
func _ready():
	screen_size = get_viewport_rect().size
	# Hide the player when the node is mounted
	hide()
	
# The process function is called every frame
# - Check for input
# - Move in a given direction
# - Play the appropriate animation
func _process(delta):
	var velocity = Vector2.ZERO

	if Input.is_action_pressed("move_right"):
		velocity.x += 1
	if Input.is_action_pressed("move_left"):
		velocity.x -= 1
	if Input.is_action_pressed("move_up"):
		velocity.y -= 1
	if Input.is_action_pressed("move_down"):
		velocity.y += 1
	
	# If the player is moving, normalize player movement
	# Then play the appropriate animation
	if velocity.length() > 0:
		# Normalize the player velocity. This ensures that a player won't
		# move faster by pressing, for example, UP and RIGHT at the same time
		velocity = velocity.normalized() * speed
		# $ is shorthand for get_node()
		$AnimatedSprite.play()
	else:
		$AnimatedSprite.stop()
		
	# Clamp the position to the screen
	position += velocity * delta
	position.x = clamp(position.x, 0, screen_size.x)
	position.y = clamp(position.y, 0, screen_size.y)

	# Set the correct animation
	if velocity.x != 0:
		$AnimatedSprite.animation = "walk"
		$AnimatedSprite.flip_v = false
		# See the note below about boolean assignment.
		$AnimatedSprite.flip_h = velocity.x < 0
	elif velocity.y != 0:
		$AnimatedSprite.animation = "up"
		$AnimatedSprite.flip_v = velocity.y > 0

	# Flip the sprite depending on the velocity
	if velocity.x < 0:
		$AnimatedSprite.flip_h = true
	else:
		$AnimatedSprite.flip_h = false


func _on_Player_body_entered(body):
	hide() # Player disappears after being hit.
	emit_signal("hit")
	# Must be deferred as we can't change physics properties on a physics callback.
	# Disabling the area's collision shape can cause an error if it happens in the middle of the engine's collision processing. Using set_deferred() tells Godot to wait to disable the shape until it's safe to do so.
	$CollisionShape2D.set_deferred("disabled", true)

# reset the player when starting a new game
func start(pos):
	position = pos
	show()
	$CollisionShape2D.disabled = false
