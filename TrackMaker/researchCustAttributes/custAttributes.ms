delete $trackController*
trackControllerObj = sphere()
trackControllerObj.name = uniquename "trackControllerObj"



weaponDataCA = attributes weaponData
(
parameters main rollout:params
(
hitPoints type:#float ui:hits default:10
cost type:#float ui:cost default:100
sound type:#string
)
 
rollout params "Weapon Parameters"
(
spinner hits "Hit Points" type:#float
spinner cost "Cost" type:#float
dropdownlist sound_dd "Sound" items:#("boom", "sparkle", "zap", "fizzle")
 
on sound_dd selected i do 
(
	sound = sound_dd.items[i]
	print "d"
)
)
)
emptyMod = (EmptyModifier())
addmodifier trackControllerObj emptyMod

custAttributes.add emptyMod weaponDataCA 
select trackControllerObj