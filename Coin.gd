extends Area

# class member variables go here, for example:
# var a = 2
# var b = "textvar"

func _ready():
    # Called every time the node is added to the scene.
    # Initialization here
    pass

func _process(delta):
    # Called every frame. Delta is time since last frame.
    # Update game logic here.
    pass


func _on_Coin_body_entered( body ):
    if body is KinematicBody:
        body.collect_coin(1)
        queue_free()
