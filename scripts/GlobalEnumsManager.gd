class_name GlobalEnums
extends RefCounted

# Capas estructurales de la cuadrícula
enum Layer {
	GROUND,      # Suelo base (ej. baldosas de asfalto)
	BELT,        # Logística superficial (cintas transportadoras)
	BUILDING,    # Estructuras principales (taladros, ensambladoras)
	UNDERGROUND  # Tuberías o cintas subterráneas
}

# Direcciones para manejar la rotación matemática de forma limpia
enum Direction {
	UP,      # 0 grados
	RIGHT,   # 90 grados
	DOWN,    # 180 grados
	LEFT     # 270 grados
}
