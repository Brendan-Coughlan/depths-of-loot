extends HBoxContainer

@export var health_component: HealthComponent

@onready var health_bar: TextureProgressBar = $HealthBar

func _ready() -> void:
	if health_component == null:
		push_error("StatusPanel: health_component is not assigned.")
		return

	health_component.health_changed.connect(update_health)
	update_health(health_component.current_health, health_component.max_health)


func update_health(current: int, max_health: int) -> void:
	var percentage := current / float(max_health)
	health_bar.value = percentage
