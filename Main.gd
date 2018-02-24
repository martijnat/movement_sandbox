extends Spatial

func _ready():
    Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

func _process(delta):
    if Input.is_action_pressed("ui_cancel"):
        Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
        print("Quitting...")
        get_tree().quit()
    if Input.is_action_just_pressed("restart"):
        print("Restarting...")
        get_tree().reload_current_scene()
