import kg_robot as kgr

urnie = kgr.kg_robot(port=30010, db_host="169.254.150.50")
urnie.set_tcp([0, -0.037898, 0.12552, 0, 0, 0])  # Tip of pincher

print(urnie.getl())

# Toolpoint offset 115.82 vertically, 37.898 horizontally




urnie.close()