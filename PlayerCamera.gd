extends Camera


var collision_exception = [] # objects to ignore when autoturning , i.e. the player

var camera_height = 10
var camera_max_dist = camera_height*1.0
var camera_min_dist = camera_height*1.0
var min_angle = 0.5
var max_angle = 1.6
var camera_speed = 30
var autoturn_offset = 10.0
var autoturn_speed = camera_speed*0.5
var offset = Vector3(0,0,0)
var up = Vector3(0, 1, 0)
var camera_dampening = 0.5
var mouselook_speed = 0.07

func _ready():
    collision_exception.append(get_parent().get_node("Player"))
    update_camera(0)

func _physics_process(dt):
    update_camera(dt)
    move(dt)

func _input(event):
    var aim = get_global_transform().basis
    if event is InputEventMouseMotion:
        offset -= aim.x * (mouselook_speed * event.relative.x)
        offset += aim.y * (mouselook_speed * event.relative.y)

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
    var aim = get_global_transform().basis


    var old_pos = get_global_transform().origin
    var delta = old_pos-player_overhead

    # Check autoturn
    var ds = PhysicsServer.space_get_direct_state(get_world().get_space())
    var col_left = ds.intersect_ray(old_pos - aim.x*autoturn_offset, player_pos, collision_exception)
    var col_right = ds.intersect_ray(old_pos + aim.x*autoturn_offset, player_pos, collision_exception)
    var col_up = ds.intersect_ray(old_pos - aim.y*autoturn_offset, player_pos, collision_exception)
    var col_down = ds.intersect_ray(old_pos + aim.y*autoturn_offset, player_pos, collision_exception)

#   #Check left/right
    if (!col_left.empty() and col_right.empty()):
        offset += aim.x*autoturn_speed*dt
    elif (col_left.empty() and !col_right.empty()):
        offset -= aim.x*autoturn_speed*dt

    #Check up/down
    if (!col_down.empty() and col_up.empty()):
        offset -= aim.y*autoturn_speed*dt
    elif (col_down.empty() and !col_up.empty()):
        offset += aim.y*autoturn_speed*dt

    if !col_left.empty() and !col_right.empty() and !col_up.empty() and !col_down.empty():
        offset -= aim.z*autoturn_speed*dt


    var new_pos = get_global_transform().origin+offset*pow(camera_dampening,dt)
    var new_dist = (new_pos-player_overhead).length()

    new_pos.y = min(player_pos.y+camera_height*max_angle,max(player_pos.y+camera_height* min_angle,new_pos.y))
    var camera_overhead_dir = (new_pos-player_overhead).normalized()

    if new_dist > camera_max_dist:
        new_pos = player_overhead + camera_max_dist*camera_overhead_dir.normalized()
    if new_dist < camera_min_dist:
        new_pos = player_overhead + camera_min_dist*camera_overhead_dir.normalized()

    offset = offset * (1-pow(camera_dampening,dt))
    look_at_from_position(new_pos,player_pos,up)


