extends Camera


var camera_height = 10
var camera_max_dist = 10
var camera_min_dist = 10

var camera_speed = 30
var offset = Vector3(0,0,0)

func _ready():
    update_camera(0)

func _physics_process(dt):
    update_camera(dt)
    move(dt)

func move(dt):
    var direction = Vector3(0,0,0)
    var aim = get_global_transform().basis
    if Input.is_action_pressed("camera_look"):
        if Input.is_action_pressed("move_up"):
            direction -= aim.y
        if Input.is_action_pressed("move_down"):
            direction += aim.y
        if Input.is_action_pressed("move_left"):
            direction += aim.x
        if Input.is_action_pressed("move_right"):
            direction -= aim.x

    if Input.is_action_pressed("look_up"):
        direction -= aim.y
    if Input.is_action_pressed("look_down"):
        direction += aim.y
    if Input.is_action_pressed("look_left"):
        direction += aim.x
    if Input.is_action_pressed("look_right"):
        direction -= aim.x

    if direction.length()>0.0:
        offset+=dt*camera_speed*direction.normalized()


func update_camera(dt):
    var player_pos = get_parent().get_node("Player").get_global_transform().origin
    var player_overhead = player_pos + Vector3(0,camera_height,0)
    var new_pos = get_global_transform().origin+offset
    var new_dist = (new_pos-player_overhead).length()

    var camera_overhead_dir = (new_pos-player_overhead).normalized()
    camera_overhead_dir.y = min(0.7,max(-0.5,camera_overhead_dir.y))

    if new_dist > camera_max_dist:
        new_pos = player_overhead + camera_max_dist*camera_overhead_dir.normalized()
    if new_dist < camera_min_dist:
        new_pos = player_overhead + camera_min_dist*camera_overhead_dir.normalized()

    offset = Vector3(0,0,0)
    look_at_from_position(new_pos,player_pos,Vector3(0,1,0))


