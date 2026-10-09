extends Button
@export var datos: BuildingData

func _pressed() -> void:
	EventBus.edificio_seleccionado.emit(datos)
