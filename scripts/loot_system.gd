extends Node
class_name LootSystem

func roll_loot(table: LootTable) -> Array:
	var results: Array = []

	for drop in table.drops:
		if randf() <= drop.chance:
			var amount = randi_range(drop.min_amount, drop.max_amount)
			results.append({
				"item": drop.item,
				"amount": amount
			})

	return results
