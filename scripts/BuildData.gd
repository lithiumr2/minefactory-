class_name BuildingData
extends Resource

@export_group("Datos Principales")
@export var id: StringName = &"edificio_base"
@export var display_name: String = "Nuevo Edificio"

@export_group("Propiedades Espaciales")
@export var size: Vector2i = Vector2i(1, 1) # Dimensión en casillas (1x1, 2x2, etc.)
@export var layer: GlobalEnumsManager.Layer = GlobalEnumsManager.Layer.BUILDING

@export_group("Recursos Visuales y Físicos")
@export var scene: PackedScene # La escena .tscn que aparecerá en el mundo
@export var texture: Texture2D # La imagen para el menú y el holograma
