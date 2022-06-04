@tool
extends Resource
class_name BlockStyle

@export var cap_type: CapStyles.Type = CapStyles.Type.Flat_Cap: set = set_cap_type

@export var cap_style: Resource: set = set_cap_style

@export var wall_type: WallStyles.Type = WallStyles.Type.Bevel_Wall: set = set_wall_type

@export var wall_style: Resource: set = set_wall_style

@export_range(0.0, 20.0, 0.5) var base_depth = 0.0: set = set_base_depth

@export var base_type: CapStyles.Type = CapStyles.Type.None: set = set_base_type

@export var base_style: Resource: set = set_base_style

var is_dirty = false

func _init() -> void:
	if not cap_style:
		set_cap_style(CapStyles.create_style(cap_type))
	if not wall_style:
		set_wall_style(WallStyles.create_style(wall_type))


func set_cap_type(value: CapStyles.Type):
	cap_type = value
	set_cap_style(CapStyles.create_style(cap_type))


func set_cap_style(value: Resource):
	ResourceUtils.switch_signal(self, "set_dirty", cap_style, value)
	cap_style = value
	set_dirty()
	
	
func set_wall_type(value: WallStyles.Type):
	wall_type = value
	set_wall_style(WallStyles.create_style(wall_type))
	
	
func set_wall_style(value: Resource):
	ResourceUtils.switch_signal(self, "set_dirty", wall_style, value)
	wall_style = value
	set_dirty()
	
	
func set_base_depth(value: float):
	base_depth = value
	set_dirty()
	
	
func set_base_type(value: CapStyles.Type):
	base_type = value
	set_base_style(CapStyles.create_style(base_type))


func set_base_style(value: Resource):
	SceneUtils.switch_signal(self, "changed", "set_dirty", base_style, value)
	base_style = value
	set_dirty()

	
func set_dirty():
	if is_dirty:
		return
	is_dirty = true
	call_deferred("_update")
	
	
func _update():
	is_dirty = false
	emit_changed()
