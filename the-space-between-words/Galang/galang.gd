extends CharacterBody2D

class_name Galang

const speed = 30
var is_galang_chase: bool


var health = 80
var health_max = 80
var health_min = 0

var dead: bool = false
var taking_damage: bool = false
var damage_to_deal = 20
var is_dealing_damage: bool = false

var dir: Vector2 = Vector2.ZERO
const gravity = 900
var knockback_force = -30
var is_roaming: bool = false

var player: CharacterBody2D
var player_in_area = false

func _process(delta):
	if !is_on_floor():
		velocity.y += gravity * delta
	else:
		velocity.y = 0 
		
	if Global.PlayerAlive:
		is_galang_chase = true
	elif !Global.PlayerAlive:
		is_galang_chase = false
	
	Global.GalangDamageAmount = damage_to_deal
	Global.GalangDamageZone = $GalangAttack
	player = Global.Playerbody
	
	move(delta)
	move_and_slide() 
	
	handle_animation()

		
func move(delta):
	if !dead:
		if !is_galang_chase:
			velocity += dir * speed * delta
		elif is_galang_chase and !taking_damage:
			var dir_to_player = position.direction_to(player.position) * speed
			velocity.x = dir_to_player.x
			dir.x = abs(velocity.x) / velocity.x
		elif taking_damage:
			var knockback_dir = position.direction_to(player.position) * knockback_force
			velocity.x = knockback_dir.x
		is_roaming = true
	elif dead:
		velocity.x = 0

func handle_animation():
	var anim_sprite = $AnimatedSprite2D
	if !dead and !taking_damage and !is_dealing_damage:
		anim_sprite.play("walk")
		if dir.x == -1:
			anim_sprite.flip_h = true
		elif dir.x == 1:
			anim_sprite.flip_h = false
	elif !dead and taking_damage and !is_dealing_damage:
		anim_sprite.play("hurt")
		await get_tree().create_timer(0.4).timeout
		taking_damage = false 
	elif dead and is_roaming:
		is_roaming = false
		anim_sprite.play("death")
		await get_tree().create_timer(1.0).timeout
		handle_death()
	elif !dead and is_dealing_damage:
		anim_sprite.play("attack")
		
func handle_death():
	self.queue_free()

func _on_direction_timer_timeout():
	$DirectionTimer.wait_time = choose([1.5,2.0,2.5])
	if !is_galang_chase:
		dir = choose([Vector2.RIGHT, Vector2.LEFT])
		velocity.x = 0
	
func _ready():
	$DirectionTimer.start() 
	
func choose(array):
	array.shuffle()
	return array.front()


func _on_galang_hitbox_area_entered(area):
	var damage = Global.PlayerDamageAmount
	if area == Global.PlayerDamageZone:
		take_damage(damage)
		
func take_damage(damage):
	health -= damage
	taking_damage = true
	if health <= health_min:
		health = health_min
		dead = true
	print(str(self), "current health is", health)

func take_damage_cooldown(wait_time):
	taking_damage = false
	await get_tree().create_timer(0.5).timeout
	taking_damage = true

func _on_galang_attack_area_entered(area):
	if area == Global.PlayerHitbox:
		is_dealing_damage = true
		await get_tree().create_timer(1.0).timeout
		is_dealing_damage = false
