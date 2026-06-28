extends StaticBody2D

@onready var interactable: Interactable = $Interactable


@export var dialog_path:String = ""

func _ready() -> void:
	interactable.dialog_path = dialog_path
