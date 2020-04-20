extends Control

func _ready():
	init_vars()
	
func init_vars():
	$PlanetInfo.set_age_value(0)
	$PlanetInfo.set_energy_value(0)
	$PlanetInfo.set_animals_value(0)
	$PlanetInfo.set_plants_value(0)
	$PlanetInfo.set_species_value(0)
	$PlanetInfo.set_time_value(1)
	$PlanetInfo.set_all_value(0,0)

signal restart_game
func _on_PlanetInfo_restart_game(config):
	init_vars()
	emit_signal("restart_game", config)

func game_over(score, why):
	$GameOver.set_score(score)
	$GameOver.set_why(why)
	$GameOver.visible = true
