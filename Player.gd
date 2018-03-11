extends KinematicBody

var camera_angle_y = 0.0
var camera_angle_x = 0.0
var camera_angle = 0.0
var camera_angle_min = -1.0
var camera_angle_max = 1.0
var mouse_sensitivity = 0.01
var camera_distance = 10
var camera_distance_min = 10
var camera_distance_max = 20

var velocity = Vector3(0,0,0)
var direction = Vector3(1,0,0)
var last_direction = Vector3(1,0,0)
var previously_airborne = false

var move_speed = 30
var move_accel = 5
var max_jumps = 2
var jumps_left = 0

var full_gravity = Vector3(0,-200,0)
var jump_gravity = Vector3(0,-100,0)
var jump_strength = 50
var roll_speed = 0.007
var bounce_speedboost = 3

var pit_depth = -100
var checkpoint = Vector3(0,100,0)
var bounce_factor = 1.0
var min_bounce_speed = 30
var coins_max = 99
var coins_collected = 0
var coin_odd_collection = true
var coin_wiggle = 4

var floor_y = 0
var floor_y_jump = 6
var floor_y_dampening = 0.01

func _ready():
    collect_coin(0)
    checkpoint = get_global_transform().origin
    floor_y = checkpoint.y

func collect_coin(amount):
    if amount>0:
#        if coins_collected==0:
#            get_node("background_music").autoplay = true
#            get_node("background_music").play()
        get_node("CoinSound").play()
        get_node("coin_effect").restart()
        coins_collected+=amount
    get_parent().get_node("CoinText").clear()
    if coin_odd_collection:
        get_parent().get_node("CoinText").margin_left+=coin_wiggle
    else:
        get_parent().get_node("CoinText").margin_left-=coin_wiggle

    coin_odd_collection = not coin_odd_collection
    get_parent().get_node("CoinText").add_text(str(coins_collected) + " out of " + str(coins_max) + " coins")

func _physics_process(dt):
    move(dt)

func _process(dt):
    if Input.is_action_just_pressed("restart"):
        reset_location()

func reset_location():
    var move_amount = checkpoint - get_global_transform().origin
    global_translate(move_amount)
    get_parent().get_node("PlayerCamera").global_translate(move_amount)
    floor_y = checkpoint.y

func move(dt):
    direction = Vector3(0,0,0)
    var up = Vector3(0, 1, 0)
    var aim = get_parent().get_node("PlayerCamera").get_global_transform().basis

    aim.z.y = 0
    aim.z = aim.z.normalized()
    aim.x.y = 0
    aim.x = aim.x.normalized()


    if not Input.is_action_pressed("camera_look"):
        if Input.is_action_pressed("move_up"):
            direction -= aim.z
        if Input.is_action_pressed("move_down"):
            direction += aim.z
        if Input.is_action_pressed("move_left"):
            direction -= aim.x
        if Input.is_action_pressed("move_right"):
            direction += aim.x

    if direction.length()>0:
        last_direction = direction
    direction = direction.normalized()
    if Input.is_action_pressed("jump") and velocity.y>0:
        velocity += jump_gravity * dt
    else:
        velocity += full_gravity * dt

    var temp_velocity = velocity
    temp_velocity.y = 0

    var target_dir = direction * move_speed

    velocity = velocity.linear_interpolate(target_dir, move_accel*dt)

    var old_velocity = velocity

    velocity = move_and_slide(velocity,Vector3(0,1,0))

    rotate_x(velocity.z*roll_speed)

    rotate_z(-velocity.x*roll_speed)

    if is_on_floor():
        jumps_left = max_jumps
        var df = pow(floor_y_dampening,dt)
        floor_y = get_global_transform().origin.y*(1-df) + floor_y*df
        if previously_airborne:
            get_node("LandSound").play()
            previously_airborne = false
            if Input.is_action_pressed("jump") and old_velocity.y<-min_bounce_speed:
                # Bounce when jump key is pressed
                velocity = velocity*bounce_speedboost
                get_node("puff_orange").restart()
                velocity.y = -bounce_factor * old_velocity.y
    else:
        floor_y = max(min(floor_y,get_global_transform().origin.y),get_global_transform().origin.y-floor_y_jump)
        previously_airborne = true

    if Input.is_action_just_pressed("jump") and jumps_left>0:
        velocity.y = jump_strength
        jumps_left-=1
        get_node("JumpSound").play()
        get_node("puff_white").restart()


    if  get_global_transform().origin.y < pit_depth:
        reset_location()



