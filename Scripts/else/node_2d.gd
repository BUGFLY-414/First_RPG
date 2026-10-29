extends Node2D

var dialogue = preload("res://dialogs/dialogue/test.dialogue")

func _ready():
	DialogueManager.show_example_dialogue_balloon(dialogue, "start")