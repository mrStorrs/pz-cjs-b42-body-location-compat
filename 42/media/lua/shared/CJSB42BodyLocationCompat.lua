local MOD_ID = "cjsB42BodyLocationCompat"

local locationIds = CJSB42BodyLocationCompat_LocationIds or {
	"AZ:HeadExtra",
	"AZ:HeadExtraHair",
	"AZ:HeadExtraPlus",
	"AZ:LegsExtra",
	"AZ:NeckExtra",
	"AZ:TorsoExtraPlus1",
	"AZ:TorsoRigPlus2",
	"B42PackMule:EarProtector",
	"B42PackMule:ExtraStrap",
	"B42PackMule:LeftAccessory",
	"B42PackMule:LeftAccessorySmall",
	"B42PackMule:LowerBag",
	"B42PackMule:Pocket",
	"B42PackMule:RightAccessory",
	"B42PackMule:RightAccessorySmall",
	"B42PackMuleBags:BackExtraBag",
	"B42PackMuleBags:RifleBag",
	"cjsTwoWeaponsonBack:Sling",
	"DExC:ShoulderHolsterD",
	"DExC:Shoulders",
	"DExC:ShouldersLeft",
	"DExC:ShouldersRight",
	"DExC:WatchLeft",
	"DExC:WatchRight",
	"Jordanals:BackBeltLeft",
	"Jordanals:BackBeltRight",
	"Jordanals:HipPouchBags",
	"KATTAJ1:BackFanny",
	"KATTAJ1:Balaclava",
	"KATTAJ1:BeltBackLeft",
	"KATTAJ1:BeltBackRight",
	"KATTAJ1:BeltLeft",
	"KATTAJ1:BeltRight",
	"KATTAJ1:ChestRig",
	"KATTAJ1:Elbows",
	"KATTAJ1:Headsets",
	"KATTAJ1:HipProtection",
	"KATTAJ1:Knees",
	"KATTAJ1:LowerArms",
	"KATTAJ1:LowerLegs",
	"KATTAJ1:Mandible",
	"KATTAJ1:ShoulderPads",
	"KATTAJ1:SkinnyPants",
	"KATTAJ1:TacticalFannyPack",
	"KATTAJ1:TacticalFannyPackFront",
	"KATTAJ1:TorsoExtraFull",
	"KATTAJ1:TorsoExtraPelvic",
	"KATTAJ1:TorsoExtraShoulder",
	"KATTAJ1:TorsoExtraShoulderPelvic",
	"KATTAJ1:UpperArms",
	"KATTAJ1:UpperLegs",
	"LegendaryDuffelbag:LowerBack",
	"TABAS:BodyGrime",
	"TABAS:BodyShampoo",
	"TOC:TOC_Arm_L",
	"TOC:TOC_Arm_R",
	"TOC:TOC_ArmAccessory_L",
	"TOC:TOC_ArmAccessory_R",
	"TOC:TOC_ArmProst_L",
	"TOC:TOC_ArmProst_R",
	"TOC:TOC_Leg_L",
	"TOC:TOC_Leg_R",
	"TOC:TOC_LegAccessory_L",
	"TOC:TOC_LegAccessory_R",
	"TOC:TOC_LegProst_L",
	"TOC:TOC_LegProst_R",
}

local warned = {}
local itemPickInfoIds = {
	"inventorymale",
	"inventoryfemale",
	"ATA2InteractiveTrunkRoofRack",
}
local registerCombatHooks

local function warnOnce(key, message)
	if warned[key] then
		return
	end
	warned[key] = true
	print("[" .. MOD_ID .. "] " .. message)
end

local function resolveLocation(id)
	if not id or id == "" then
		return nil
	end

	local ok, location = pcall(function()
		return ItemBodyLocation.get(ResourceLocation.of(id))
	end)
	if not ok then
		warnOnce("get:" .. id, "could not resolve body location " .. tostring(id) .. ": " .. tostring(location))
		return nil
	end

	if location ~= nil then
		return location
	end

	local registerOk, registered = pcall(function()
		return ItemBodyLocation.register(id)
	end)
	if not registerOk then
		warnOnce("register:" .. id, "could not register body location " .. tostring(id) .. ": " .. tostring(registered))
		return nil
	end
	return registered
end

local function ensureHumanLocations(reason)
	if not BodyLocations or not ItemBodyLocation or not ResourceLocation then
		return
	end

	local group = BodyLocations.getGroup("Human")
	if group == nil then
		return
	end

	local added = 0
	for _, id in ipairs(locationIds) do
		local location = resolveLocation(id)
		if location ~= nil and group:getLocation(location) == nil then
			group:getOrCreateLocation(location)
			added = added + 1
		end
	end

	if added > 0 then
		print("[" .. MOD_ID .. "] restored " .. tostring(added) .. " Human body locations during " .. tostring(reason))
	end
end

local tickChecks = 0
local function ensureItemPickInfoIds(reason)
	if ItemConfigurator == nil then
		return
	end

	local added = 0
	for _, id in ipairs(itemPickInfoIds) do
		if ItemConfigurator.GetIdForString(id) == -1 and ItemConfigurator.registerZone(id) then
			added = added + 1
		end
	end

	if added > 0 then
		print("[" .. MOD_ID .. "] registered " .. tostring(added) .. " ItemPickInfo ids during " .. tostring(reason))
	end
end

local function ensureOnTick()
	ensureHumanLocations("OnTick")
	ensureItemPickInfoIds("OnTick")
	tickChecks = tickChecks + 1
	if tickChecks >= 3 then
		Events.OnTick.Remove(ensureOnTick)
	end
end

Events.OnGameBoot.Add(function()
	ensureHumanLocations("OnGameBoot")
	ensureItemPickInfoIds("OnGameBoot")
end)

Events.OnGameStart.Add(function()
	ensureHumanLocations("OnGameStart")
	ensureItemPickInfoIds("OnGameStart")
	if registerCombatHooks ~= nil then
		registerCombatHooks()
	end
	Events.OnTick.Remove(ensureOnTick)
	tickChecks = 0
	Events.OnTick.Add(ensureOnTick)
end)

Events.OnCreatePlayer.Add(function()
	ensureHumanLocations("OnCreatePlayer")
	ensureItemPickInfoIds("OnCreatePlayer")
	if registerCombatHooks ~= nil then
		registerCombatHooks()
	end
end)

local function locationKnown(location)
	if location == nil or BodyLocations == nil then
		return "nil"
	end

	local group = BodyLocations.getGroup("Human")
	if group == nil then
		return "no-human-group"
	end

	local ok, result = pcall(function()
		return group:getLocation(location)
	end)
	if not ok then
		return "check-error:" .. tostring(result)
	end
	return result ~= nil and "known" or "missing"
end

local function getScriptItem(fullType)
	if fullType == nil or ScriptManager == nil or ScriptManager.instance == nil then
		return nil
	end

	return ScriptManager.instance:FindItem(fullType)
end

local function getWearLocation(bodyLocation, canBeEquipped)
	if bodyLocation ~= nil then
		return bodyLocation
	end

	return canBeEquipped
end

local function getVisualInfo(visual)
	local fullType = visual and visual:getItemType() or nil
	local scriptItem = getScriptItem(fullType)

	local bodyLocation = nil
	local canBeEquipped = nil
	if scriptItem ~= nil then
		bodyLocation = scriptItem:getBodyLocation()
		canBeEquipped = scriptItem.canBeEquipped
	end

	return {
		fullType = fullType,
		scriptItem = scriptItem,
		bodyLocation = bodyLocation,
		canBeEquipped = canBeEquipped,
		wearLocation = getWearLocation(bodyLocation, canBeEquipped),
	}
end

local sanitizedVisualCount = 0
local sanitizedVisualLogLimit = 40

local function shouldRemoveVisual(info)
	if info == nil or info.scriptItem == nil then
		return false
	end

	return locationKnown(info.wearLocation) ~= "known"
end

local function sanitizeZombieVisuals(zombie, reason)
	if zombie == nil or not instanceof(zombie, "IsoZombie") then
		return
	end

	local visuals = zombie:getItemVisuals()
	if visuals == nil then
		return
	end

	local removed = 0
	for i = visuals:size() - 1, 0, -1 do
		local visual = visuals:get(i)
		local info = getVisualInfo(visual)
		if shouldRemoveVisual(info) then
			visuals:remove(i)
			removed = removed + 1
			if sanitizedVisualCount < sanitizedVisualLogLimit then
				sanitizedVisualCount = sanitizedVisualCount + 1
				print("[" .. MOD_ID .. "] removed unsafe zombie visual during " .. tostring(reason)
					.. " type=" .. tostring(info.fullType)
					.. " bodyLocation=" .. tostring(info.bodyLocation)
					.. " canBeEquipped=" .. tostring(info.canBeEquipped)
					.. " wearLocation=" .. tostring(info.wearLocation)
					.. " wearKnown=" .. tostring(locationKnown(info.wearLocation)))
			end
		end
	end

	if removed > 0 then
		zombie:resetModelNextFrame()
	end
end

local function onWeaponHitCharacter(attacker, target)
	sanitizeZombieVisuals(target, "OnWeaponHitCharacter")
end

local function onHitZombie(zombie, attacker, bodyPart, weapon)
	sanitizeZombieVisuals(zombie, "OnHitZombie")
end

function registerCombatHooks()
	Events.OnWeaponHitCharacter.Remove(onWeaponHitCharacter)
	Events.OnHitZombie.Remove(onHitZombie)
	Events.OnWeaponHitCharacter.Add(onWeaponHitCharacter)
	Events.OnHitZombie.Add(onHitZombie)
end

registerCombatHooks()
