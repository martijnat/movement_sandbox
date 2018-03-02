extends Spatial

func _ready():
    Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
    pass

func _process(delta):
    if Input.is_action_pressed("quit"):
        Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
        print("Quitting...")
        get_tree().quit()
