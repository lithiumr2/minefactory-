class_name BuildController
extends Node2D

enum Modo { NINGUNO, CONSTRUIR }

@export_group("Dependencias")
@export var grid_manager: GridManager
@export var ghost_building: GhostBuilding

var modo_actual: Modo = Modo.NINGUNO
var datos_edificio_activo: BuildingData

func _ready() -> void:
	# Nos suscribimos a la emisora de radio global (EventBus)
	if EventBus:
		EventBus.edificio_seleccionado.connect(_al_recibir_edificio)
		EventBus.modo_cancelado.connect(_cancelar_modo)

func _al_recibir_edificio(datos: BuildingData) -> void:
	datos_edificio_activo = datos
	if datos_edificio_activo:
		modo_actual = Modo.CONSTRUIR
		if ghost_building:
			ghost_building.configurar_holograma(datos_edificio_activo)
	else:
		_cancelar_modo()

func _unhandled_input(event: InputEvent) -> void:
	# Si no estamos construyendo nada, ignoramos el ratón
	if modo_actual == Modo.NINGUNO:
		return

	var posicion_raton: Vector2 = get_global_mouse_position()

	# 1. Si movemos el ratón -> Actualizamos el holograma visual
	if event is InputEventMouseMotion:
		if modo_actual == Modo.CONSTRUIR and ghost_building:
			ghost_building.actualizar_holograma(posicion_raton)

	# 2. Si hacemos clic -> Ejecutamos acción
	elif event is InputEventMouseButton and event.pressed:
		
		# Clic Izquierdo: Confirmar construcción
		if event.button_index == MOUSE_BUTTON_LEFT:
			if modo_actual == Modo.CONSTRUIR and datos_edificio_activo and grid_manager:
				var celda_objetivo: Vector2i = grid_manager.mundo_a_grilla(posicion_raton)
				
				# Ordenamos colocar el edificio
				var edificio_creado: Node2D = grid_manager.colocar_edificio(celda_objetivo, datos_edificio_activo)
				
				# Si se construyó con éxito, forzamos al holograma a refrescarse (por si queremos poner otro ahí mismo y ahora está bloqueado)
				if edificio_creado and ghost_building:
					ghost_building.actualizar_holograma(posicion_raton)
		
		# Clic Derecho: Cancelar y soltar el edificio
		elif event.button_index == MOUSE_BUTTON_RIGHT:
			_cancelar_modo()

func _cancelar_modo() -> void:
	modo_actual = Modo.NINGUNO
	datos_edificio_activo = null
	if ghost_building:
		ghost_building.limpiar()
