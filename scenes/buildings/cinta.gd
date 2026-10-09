# Estructura abstracta de la cinta (Node2D)
extends Node2D
class_name cinta

# 1. REFERENCIAS Y PARÁMETROS
@export var catalogo_items: Resource # Tu recurso 'Items' con el diccionario
@export var velocidad: float = 0.5   # Unidades de progreso por segundo
@export var capacidad_maxima: int = 4
@export var dirrecion:Vector2i = Vector2i (0,1)
var grid_position

var items: Array[Dictionary] = [{"id": &"hierro", "progress": 0.0}]    # Lista de ítems:
var tamano_casilla: float = 32.0

func _ready() -> void:
	$Sprite2D.show_behind_parent = true


# 2. BUCLE PRINCIPAL (Movimiento independiente de fotogramas)
func _process(delta: float) -> void:
	if items.is_empty():
		return
		
	var hubo_movimiento: bool = false
	var distancia_minima: float = 1.0 / capacidad_maxima
	
	for i in range(items.size()):
		var item = items[i]
		
		# Determinar el límite de avance:
		# El primer ítem (i = 0) puede llegar a 1.0. 
		# Los demás están limitados por el ítem que tienen enfrente.
		var limite_maximo: float = 1.0
		if i > 0:
			limite_maximo = items[i - 1]["progress"] - distancia_minima
			
		# Si no ha llegado a su límite, lo avanzamos con delta
		if item["progress"] < limite_maximo:
			var nuevo_progreso = item["progress"] + (velocidad * delta)
			item["progress"] = min(nuevo_progreso, limite_maximo)
			hubo_movimiento = true
			
	# Redibujamos el lienzo solo si algún ítem cambió de posición
	if hubo_movimiento:
		queue_redraw()

# 3. DIBUJADO EN PANTALLA
func _draw() -> void:
	var pos_inicio = Vector2(tamano_casilla / 2.0,0)  # Entrada (0, 16)
	var pos_final = Vector2(tamano_casilla / 2.0, tamano_casilla) # Salida (32, 16)
	
	for item in items:
		var clave_id: StringName = item["id"]
		
		# Validamos que el ítem existe en el diccionario del recurso
		if catalogo_items and catalogo_items.items.has(clave_id):
			var textura: Texture2D = catalogo_items.items[clave_id]["texture"]
			
			if textura != null:
				# Calculamos posición con lerp y centramos el gráfico
				var pos_calculada = pos_inicio.lerp(pos_final, item["progress"])
				var pos_centrada = pos_calculada - (textura.get_size() / 2.0)
				
				draw_texture(textura, pos_centrada)

# 4. FUNCIÓN PARA RECIBIR UN ÍTEM NUEVO
func ingresar_item(nuevo_id: StringName) -> bool:
	# Verificamos si hay espacio disponible
	if items.size() >= capacidad_maxima:
		return false # Cinta llena
		
	# Si ya hay ítems, el último debe haber avanzado lo suficiente para no encimarse
	var distancia_minima: float = 1.0 / capacidad_maxima
	if not items.is_empty() and items.back()["progress"] < distancia_minima:
		return false # Entrada bloqueada por el ítem anterior
		
	# Añadimos el nuevo ítem al inicio de la cinta (progreso 0.0)
	items.append({"id": nuevo_id, "progress": 0.0})
	queue_redraw()
	return true
# Pseudocódigo dentro de ConveyorBelt.gd
var siguiente_cinta = null

func actualizar_conexion() -> void:
	# 1. Calculamos la casilla objetivo en la grilla
	var casilla_destino: Vector2i = grid_position + dirrecion
	
	# 2. Consultamos al GridManager global
	var edificio_encontrado = GridManager.get_building_at(casilla_destino)
	
	# 3. Comprobamos si el objeto existe y es una cinta
	if edificio_encontrado is cinta:
		siguiente_cinta = edificio_encontrado
	else:
		siguiente_cinta = null # No hay cinta enfrente o se eliminó
