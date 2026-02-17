extends PanelContainer

@onready var steel_label: Label = %SteelAmount
@onready var flux_label: Label = %FluxAmount
@onready var hydrogen_crystals_label: Label = %HydrogenCrystalsAmount
@onready var plasma_fluids_label: Label = %PlasmaFluidsAmount
@onready var iridium_label: Label = %IridiumAmount

func _ready():
	InventoryManager.currency_changed.connect(_on_currency_changed)

func _on_currency_changed(currency: InventoryManager.Currency, value: int) -> void:
	match currency:
		InventoryManager.Currency.FLUX: set_flux(value)
		InventoryManager.Currency.STEEL: set_steel(value)
		InventoryManager.Currency.HYDROGEN_CRYSTALS: set_hydrogen_crystals(value)
		InventoryManager.Currency.PLASMA_FLUIDS: set_plasma_fluids(value)
		InventoryManager.Currency.IRIDIUM: set_iridium(value)
		

func set_flux(value: int):
	flux_label.set_text(Functions.shorten_number(value))

func set_steel(value: int):
	steel_label.set_text(Functions.shorten_number(value))

func set_hydrogen_crystals(value: int):
	hydrogen_crystals_label.set_text(Functions.shorten_number(value))

func set_plasma_fluids(value: int):
	plasma_fluids_label.set_text(Functions.shorten_number(value))

func set_iridium(value: int):
	iridium_label.set_text(Functions.shorten_number(value))
