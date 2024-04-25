extends PanelContainer

@onready var steel_label: Label = %SteelAmount
@onready var hydrogen_crystals_label: Label = %HydrogenCrystalsAmount
@onready var plasma_fluids_label: Label = %PlasmaFluidsAmount
@onready var iridium_label: Label = %IridiumAmount

func _ready():
	InventoryManager.steel_changed.connect(_on_steel_changed)
	InventoryManager.hydrogen_crystals_changed.connect(_on_hydrogen_crystals_changed)
	InventoryManager.plasma_fluids_changed.connect(_on_plasma_fluids_changed)
	InventoryManager.iridium_changed.connect(_on_iridium_changed)


func _on_steel_changed():
	var amount := InventoryManager.steel
	steel_label.set_text(Functions.shorten_number(amount))

func _on_hydrogen_crystals_changed():
	var amount := InventoryManager.hydrogen_crystals
	hydrogen_crystals_label.set_text(Functions.shorten_number(amount))

func _on_plasma_fluids_changed():
	var amount := InventoryManager.plasma_fluids
	plasma_fluids_label.set_text(Functions.shorten_number(amount))

func _on_iridium_changed():
	var amount := InventoryManager.iridium
	iridium_label.set_text(Functions.shorten_number(amount))

