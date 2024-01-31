extends Node2D
class_name Thruster

@onready var idle = $Idle
@onready var light = $Light
@onready var spark = $Spark
@onready var speeding = $Speeding
@onready var accelerate = $Accelerate

func startState(b : bool):
	spark.emitting = b

func activeState(b : bool):
	light.emitting = b

func idleState():
	idle.emitting = true

func init():
	idle.emitting = true
	light.emitting = false
	spark.emitting = false
	speeding.emitting = false
	accelerate.emitting = false

func runningState(b : bool):
	accelerate.emitting = b
	speeding.emitting = b
	idle.emitting = false
