## Helper class to allow editing the lens-flare ghosts in the editor
class_name FlareGhost extends Resource

@export var color : Color = Color(1,1,1,0.25)
@export_range(0,1) var size : float = 1.0
