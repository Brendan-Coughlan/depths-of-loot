extends Area2D

@export var item: ItemData
@export var amount: int = 1

@onready var sprite: Sprite2D = $Sprite2D

func _ready():
	if item and item.icon:
		sprite.texture = item.icon
