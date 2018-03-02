extends RigidBody

# class member variables go here, for example:
# var a = 2
# var b = "textvar"


var initial_position
var last_pos
var idle_dist = 0.001
var max_dist = 100.0
var current_idle_time = 0.0
var max_idle_time = 1.0
var up = Vector3(0,1,0)

func _ready():
    initial_position = get_global_transform().origin
    last_pos = initial_position

func _physics_process(dt):
    var new_pos = get_global_transform().origin
    var dist_moved = (new_pos-last_pos).length()
    last_pos = new_pos
    var dist_from_init = (new_pos-initial_position).length()

    if dist_moved < idle_dist:
        current_idle_time += dt
    else:
        current_idle_time = 0

    if current_idle_time >= max_idle_time or dist_from_init >= max_dist:
        look_at_from_position(initial_position,initial_position+up,up)