class_name State
extends Node

var actor: Actor
var state_machine: StateMachine

func enter(_prev): pass
func exit(_next): pass
func update(_delta): pass
func physics_update(_delta): pass

func request_state(new_state: String):
  state_machine.request_state(new_state)
