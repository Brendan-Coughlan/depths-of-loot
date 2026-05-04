extends CanvasLayer

@export var health_component: HealthComponent
@export var player_inventory: Inventory

@onready var health_bar: TextureProgressBar = $StatusPanel/HealthBar
@onready var gold_label: Label = $StatusPanel/GoldLabel

func _ready() -> void:
	if health_component == null:
		push_error("StatusPanel: health_component is not assigned.")
		return

	health_component.health_changed.connect(update_health)
	update_health(health_component.current_health, health_component.max_health)

func _process(delta: float) -> void:
	update_gold_amount()

func update_health(current: int, max_health: int) -> void:
	var percentage := current / float(max_health) * 100
	health_bar.value = percentage

func update_gold_amount() -> void:
	gold_label.text = str(player_inventory.gold)
