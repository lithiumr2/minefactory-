class_name GridManager
extends Node2D

@export_group("Configuración de Grilla")
@export var tile_size: int = 32
@export var terreno_colisiones: TileMapLayer # Opcional: Para evitar construir en agua/rocas
@export var direc:Vector2i=Vector2i(0,1)

# Diccionario principal separado por capas para evitar que una cinta bloquee un puente
# Estructura: { Capa : { Vector2i : Node2D (Instancia del edificio) } }
var mapas_de_capas: Dictionary = {}

func _init() -> void:
	# Inicializamos un diccionario vacío por cada capa definida en GlobalEnumsManager
	for capa in GlobalEnumsManager.Layer.values():
		mapas_de_capas[capa] = {}

# Conversión matemática pura sin depender de nodos
func mundo_a_grilla(posicion_mundo: Vector2) -> Vector2i:
	return Vector2i(floor(posicion_mundo.x / float(tile_size)), floor(posicion_mundo.y / float(tile_size)))

func grilla_a_mundo(posicion_grilla: Vector2i) -> Vector2:
	return Vector2(posicion_grilla.x * tile_size, posicion_grilla.y * tile_size)

# Validación de espacio multi-casilla
func validar_espacio_libre(celda_origen: Vector2i, tamano: Vector2i, capa: GlobalEnumsManager.Layer) -> bool:
	var grilla_activa: Dictionary = mapas_de_capas[capa]
	
	for x in range(tamano.x):
		for y in range(tamano.y):
			var celda_evaluada := celda_origen + Vector2i(x, y)
			
			# 1. ¿Hay otro edificio de esta misma capa aquí?
			if grilla_activa.has(celda_evaluada):
				return false
				
			# 2. ¿Hay una colisión estática en el terreno? (Si asignaste el TileMapLayer)
			if terreno_colisiones and capa in [GlobalEnumsManager.Layer.BUILDING, GlobalEnumsManager.Layer.BELT]:
				if terreno_colisiones.get_cell_source_id(celda_evaluada) != -1:
					return false
					
	return true

# Colocación e instanciación del edificio
func colocar_edificio(celda_origen: Vector2i, datos: BuildingData) -> Node2D:
	if not validar_espacio_libre(celda_origen, datos.size, datos.layer):
		return null
		
	if not datos.scene:
		push_error("Error: BuildingData no tiene escena asignada.")
		return null

	# Instanciar el objeto físico
	var instancia := datos.scene.instantiate() as Node2D
	instancia.dirrecion = direc
	instancia.global_position = grilla_a_mundo(celda_origen)
	add_child(instancia) # El GridManager será el padre de todos los edificios

	# Registrar la instancia en todas las celdas que ocupa
	var grilla_activa: Dictionary = mapas_de_capas[datos.layer]
	for x in range(datos.size.x):
		for y in range(datos.size.y):
			grilla_activa[celda_origen + Vector2i(x,y)] = instancia
			
	return instancia

# Destrucción atómica (Borra todo el edificio sin importar en qué parte del 3x3 hiciste clic)
func demoler_edificio_en(celda_clic: Vector2i, capa: GlobalEnumsManager.Layer) -> void:
	var grilla_activa: Dictionary = mapas_de_capas[capa]
	
	if not grilla_activa.has(celda_clic):
		return
		
	var instancia_a_borrar: Node2D = grilla_activa[celda_clic]
	var celdas_a_limpiar: Array[Vector2i] = []
	
	# Buscar todas las celdas que pertenecen a esta instancia exacta
	for celda in grilla_activa.keys():
		if grilla_activa[celda] == instancia_a_borrar:
			celdas_a_limpiar.append(celda)
			
	# Liberar el espacio en la memoria
	for celda in celdas_a_limpiar:
		grilla_activa.erase(celda)
		
	# Destruir el nodo del mundo
	if is_instance_valid(instancia_a_borrar):
		instancia_a_borrar.queue_free()
