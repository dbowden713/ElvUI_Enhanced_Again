local E, L, V, P, G = unpack(ElvUI);
local EEL = E:GetModule("ElvuiEnhancedAgain");
local EQ = E:GetModule("Equipment");

local tsort = table.sort

V["eel"]["equipment"] = {
	['specialization'] = {
        ['enable'] = false,
        ['spec1'] = 'none',
        ['spec2'] = 'none',
        ['spec3'] = 'none',
        ['spec4'] = 'none',
        ['equipmentset'] = 'none',
	},
	['battleground'] = {
		['enable'] = false,
	},
	['durability'] = {
		enable = false,
		onlydamaged = true,
	},
	['itemlevel'] = {
		enable = false,
	},
	['misc'] = {
		setoverlay = false,
	}
}

local function GetAllEquipmentSets()
	local sets = { ["none"] = L["No Change"] }
	local equipmentSetIDs = C_EquipmentSet.GetEquipmentSetIDs();
	for key,value in pairs(equipmentSetIDs) do
		local name = C_EquipmentSet.GetEquipmentSetInfo(value)
		if name then
			sets[name] = name
		end
	end
	tsort(sets, function(a, b) return a < b end)
	return sets
end

local function UpdateTalentConfiguration()
    local numSpecs = GetNumSpecializations(false, E.isPet);
    local sex = E.isPet and UnitSex("pet") or UnitSex("player");

    for i = 1, numSpecs do
        local _, name, description, icon = GetSpecializationInfo(i, false, E.isPet, nil, sex);
        E.Options.args.eel.args.equipment.args.specialization.args["spec"..i].name = name
    end
end

local function ConfigTable()
    local sets = GetAllEquipmentSets()
    local numSpecs = GetNumSpecializations(false, E.isPet);

	E.Options.args.eel.args.equipment = {
        order = 40,
        type = 'group',
        name = L['Equipment'],
        childGroups = 'tab',
        get = function(info) return E.private.eel.equipment[ info[#info] ] end,
		set = function(info, value) E.private.eel.equipment[ info[#info] ] = value end,
        args = {
			header1 = {
				order = 1,
				type = 'description',
				fontSize = 'medium',
				name = "\n"..L["Setup automatic spec switching"],
            },
            header2 = {
				order = 2,
				type = "header",
				name = "",
            },
            specialization = {
				order = 2,
				type = "group",
				name = L["Specialization"],
				guiInline = true,
                disabled = function() return C_EquipmentSet.GetNumEquipmentSets() == 0 end,
                get = function(info) return E.private.eel.equipment.specialization[ info[#info] ] end,
                set = function(info, value) E.private.eel.equipment.specialization[ info[#info] ] = value end,
				args = {
					enable = {
						type = "toggle",
						order = 1,
						name = L["Enable"],
						desc = L['Enable/Disable the specialization switch.'],
						get = function(info) return E.private.eel.equipment.specialization.enable end,
						set = function(info, value) E.private.eel.equipment.specialization.enable = value end
                    },
                    spacer = {
                        order = 2,
                        type = "header",
                        name = "",
                    },
					spec1 = {
						type = "select",
						order = 2,
						name = L["First Talent"],
						desc = L["Choose the equipment set to use for your primary specialization."],
						disabled = function() return not E.private.eel.equipment.specialization.enable end,
						values = sets,
					},
					spec2 = {
						type = "select",
						order = 3,
						name = L["Secondary Talent"],
                        desc = L["Choose the equipment set to use for your secondary specialization."],
                        disabled = function() return not E.private.eel.equipment.specialization.enable end,
						hidden = function() return numSpecs < 2 end,
						values = sets,
					},
					spec3 = {
						type = "select",
						order = 4,
						name = L["Tertiary Talent"],
                        desc = L["Choose the equipment set to use for your thirth specialization."],
                        disabled = function() return not E.private.eel.equipment.specialization.enable end,
						hidden = function() return numSpecs < 3 end,
						values = sets,
					},
					spec4 = {
						type = "select",
						order = 5,
						name = L["Quaternary Talent"],
                        desc = L["Choose the equipment set to use for your quaternary specialization."],
                        disabled = function() return not E.private.eel.equipment.specialization.enable end,
						hidden = function() return numSpecs < 4 end,
						values = sets,
					},
				},
			},
			battleground = {
				order = 3,
				type = "group",
				name = L["Battleground"],
				guiInline = true,
				disabled = function() return C_EquipmentSet.GetNumEquipmentSets() == 0 end,
				args = {
					enable = {
						type = "toggle",
						order = 1,
						name = L["Enable"],
						desc = L['Enable/Disable the battleground switch.'],
						get = function(info) return E.private.eel.equipment.battleground.enable end,
						set = function(info, value) E.private.eel.equipment.battleground.enable = value; EQ:ToggleBattleground() end
					},
					equipmentset = {
						type = "select",
						order = 2,
						name = L["Equipment Set"],
						desc = L["Choose the equipment set to use when you enter a battleground or arena."],
						disabled = function() return not E.private.eel.equipment.battleground.enable end,
						values = sets,
					},
				},
			},
        }
    }
    UpdateTalentConfiguration()
end

EEL.config["equipment"] = ConfigTable