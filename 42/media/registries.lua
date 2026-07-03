CJSB42BodyLocationCompat_LocationIds = {
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

local function canRegister(id)
	return string.find(id, ":", 1, true) ~= nil
end

local function registerBodyLocation(id)
	if not canRegister(id) then
		return
	end

	local ok, location = pcall(function()
		return ItemBodyLocation.get(ResourceLocation.of(id))
	end)
	if ok and location == nil then
		pcall(function()
			ItemBodyLocation.register(id)
		end)
	end
end

for _, id in ipairs(CJSB42BodyLocationCompat_LocationIds) do
	registerBodyLocation(id)
end
