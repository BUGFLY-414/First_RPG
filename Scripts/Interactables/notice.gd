extends StaticBody2D

@onready var interactable: Interactable = $Interactable


@export var dialog_path:String = ""


func _ready():
	interactable.interacted.connect(_on_interact)


func _on_interact():
	pass