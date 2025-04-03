class_name SellableComponent
extends Node

enum Rarities {
	Common,
	Uncommon,
	Rare
}

@export var cost: int = 100
@export var rarity: Rarities = Rarities.Common
