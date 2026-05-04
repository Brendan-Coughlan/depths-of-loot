extends Node2D

@export var health_component: HealthComponent
@export var show_time: float = 2.0

@onready var health_bar: TextureProgressBar = $TextureProgressBar

var hide_timer: Timer


func _ready() -> void:
	if health_component == null:
		health_component = get_parent().get_node_or_null("HealthComponent")

	if health_component == null:
		push_warning("EnemyHealthBar: No HealthComponent found.")
		return

	health_bar.max_value = health_component.max_health
	health_bar.value = health_component.current_health

	health_component.health_changed.connect(_on_health_changed)
	health_component.died.connect(_on_died)

	hide_timer = Timer.new()
	hide_timer.one_shot = true
	hide_timer.wait_time = show_time
	add_child(hide_timer)
	hide_timer.timeout.connect(_on_hide_timer_timeout)

	hide()


func _on_health_changed(current: int, max_health: int) -> void:
	health_bar.max_value = max_health
	health_bar.value = current

	if current > 0:
		show()
		hide_timer.start(show_time)


func _on_hide_timer_timeout() -> void:
	hide()


func _on_died() -> void:
	hide()
