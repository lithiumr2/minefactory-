extends Node

# Señal emitida por los botones de la UI cuando el jugador elige qué construir
signal edificio_seleccionado(datos_edificio: BuildingData)

# Señal emitida (por la UI o atajos) para limpiar el cursor y salir del modo construcción
signal modo_cancelado()
