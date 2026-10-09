class_name GhostBuilding
extends Node2D

@export_group("Dependencias")
@export var grid_manager: GridManager # Necesita conocer al gerente de la cuadrícula para hacerle preguntas

var sprite: Sprite2D
var datos_actuales: BuildingData

func _ready() -> void:
	# Creamos el componente visual (Sprite) dinámicamente y lo ocultamos al inicio
	sprite = Sprite2D.new()
	sprite.centered = false # Vital para que la imagen encaje perfecto en la esquina superior izquierda de la celda
	add_child(sprite)
	hide()

# Se ejecuta cuando el jugador selecciona un edificio en el menú
func configurar_holograma(nuevos_datos: BuildingData) -> void:
	datos_actuales = nuevos_datos
	if datos_actuales and datos_actuales.texture:
		sprite.texture = datos_actuales.texture
		show()
	else:
		hide()

# Se ejecuta contínuamente para seguir al ratón
func actualizar_holograma(posicion_raton_mundo: Vector2) -> void:
	if not datos_actuales or not grid_manager:
		hide()
		return
		
	show()
	
	# 1. Ajustar (Snap) la posición libre del ratón a la cuadrícula estricta
	var celda_actual: Vector2i = grid_manager.mundo_a_grilla(posicion_raton_mundo)
	global_position = grid_manager.grilla_a_mundo(celda_actual)
	
	# 2. Consultar al GridManager si podemos construir aquí
	var es_valido: bool = grid_manager.validar_espacio_libre(celda_actual, datos_actuales.size, datos_actuales.layer)
	
	# 3. Dar retroalimentación visual usando la propiedad 'modulate' (Color + Transparencia)
	if es_valido:
		modulate = Color(0.2, 1.0, 0.2, 0.6) # Verde semi-transparente
	else:
		modulate = Color(1.0, 0.2, 0.2, 0.6) # Rojo semi-transparente

# Se ejecuta cuando cancelamos la construcción
func limpiar() -> void:
	datos_actuales = null
	hide()
