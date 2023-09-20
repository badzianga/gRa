extends CanvasLayer


const ItemOptionScene := preload("res://Scenes/UI/item_option.tscn")

@onready var container := $Background/Container
@onready var coins_label := $Background/CoinsLabel
@onready var stats_label := $Background/StatsBackground/StatsLabel

func _ready() -> void:
	coins_label.text = str(GameController.coins)
	for i in range(3):
		_create_option()
	_show_upgrades()


func _create_option(delayed: bool = false) -> void:
	if len(Upgrades.available_upgrades) <= 0:
		return
	var option := ItemOptionScene.instantiate()
	option.set_info(Upgrades.available_upgrades.pick_random())
	option.item_purchased.connect(_on_item_purchased)
	option.display(delayed)
	# I don't want to create few entries of the same upgrade, so this is necessary
	GameController.remove_available_upgrade(option.item_id)
	container.add_child(option)


func _show_upgrades() -> void:
	stats_label.text = "Max health: " + str(10 + PlayerUpgrades.max_health) + "\n" \
			+ "Movement speed: " + str(int(PlayerUpgrades.speed_multiplier * 100)) + "%\n" \
			+ "Damage: " + str(ceil((5 + PlayerUpgrades.extra_damage) * PlayerUpgrades.damage_multiplier)) + "\n" \
			+ "Projectiles: " + str(1 + PlayerUpgrades.extra_bullets) + "\n" \
			+ "Penetration: " + str(PlayerUpgrades.penetration) + "\n" \
			+ "Cooldown: " + str((1.5 - PlayerUpgrades.cooldown_reduce_sec) * PlayerUpgrades.cooldown_multiplier) + "s\n" \
			+ "Projectile speed: " + str(int(PlayerUpgrades.bullet_speed_multiplier * 100)) + "%\n\n" \
			+ "Djeds: " + str(PlayerUpgrades.djeds) + "\n" \
			+ "Damage: " + str(ceil((5 + PlayerUpgrades.djed_extra_damage) * PlayerUpgrades.djed_damage_multiplier)) + "\n" \
			+ "Projectiles: " + str(1 + PlayerUpgrades.djed_extra_bullets) + "\n" \
			+ "Penetration: " + str(PlayerUpgrades.djed_penetration) + "\n" \
			+ "Cooldown: " + str(1.6 * PlayerUpgrades.djed_cooldown_multiplier) + "s\n" \
			+ "Projectile speed: " + str(int(PlayerUpgrades.djed_bullet_speed_multiplier * 100)) + "%\n"


func _on_item_purchased(item_option: ItemOption) -> void:
	GameController.coins -= item_option.price
	GameController.purchased_upgrades.append(item_option.item_name)
	GameController.upgrade_character(item_option.item_id)
	coins_label.text = str(GameController.coins)
	# I'm removing it from here and adding it to _create_option()
	#GameController.remove_available_upgrade(item_option.item_id)
	item_option.delete()
	_show_upgrades()
	_create_option(true)


func _on_next_wave_button_pressed() -> void:
	# After the bazaar and just before the next wave, retrieve left options
	# and add them again to available_upgrades
	for option in container.get_children():
		Upgrades.available_upgrades.append(option.data)
	GameController.back_to_world()
