--[[
	Add strings
]]--

if not STRINGS.PIGHOUSE then STRINGS.PIGHOUSE = {} end
STRINGS.PIGHOUSE.TRICKORTREAT = {
	CHECKCOSTUME = "WHAT YOU DRESSED AS?",
	SEENCOSTUME = "YOU BEEN HERE!",
	--REFUSETREAT = "NO TREAT!",
	--GIVETREAT = "",
}

if not STRINGS.RABBITHOUSE then STRINGS.RABBITHOUSE = {} end
STRINGS.RABBITHOUSE.TRICKORTREAT = {
	CHECKCOSTUME = "COSTUME?",
	SEENCOSTUME = "RECOGNIZE!",
	--REFUSETREAT = "NO!",
	--GIVETREAT = "",
}

STRINGS.CHARACTERS.GENERIC.TRICKORTREAT = {
	HALLOWEEN_STARTED = "It's Halloween! I should go trick-or-treating.",

	TRICK_OR_TREAT = "Trick-or-treat!",
	DRESSED_AS_SOMETHING = "I'm %s!",
	DRESSED_AS_NOTHING = "I don't know.",

	ALREADY_TRICK_OR_TREATING = "I don't want to interrupt.",
	NO_TREATS_TO_GIVE = "They've already been cleaned out.",
	NOT_ALLOWED_DURING_NIGHT = "It's too late for that now.",
	NOT_ALLOWED_DURING_DUSK = "I can't do that now.",
	NOT_ALLOWED_DURING_DAY = "It's too early for that now.",
	NOT_HALLOWEEN = "It's not even Halloween!", -- note: this shouldn't really be possible to trigger
	NOT_HOME = "No one's home.",
}

STRINGS.CHARACTERS.WX78.TRICKORTREAT = {
	HALLOWEEN_STARTED = "HALLOWEEN DETECTED. TRICK-OR-TREAT MODULE PRIMED.",

	TRICK_OR_TREAT = "TRICK-OR-TREAT.",
	DRESSED_AS_SOMETHING = "COSTUME EQUALS %s.",
	DRESSED_AS_NOTHING = "COSTUME NOT FOUND.",

	ALREADY_TRICK_OR_TREATING = "TRICK-OR-TREATING IN PROGRESS.",
	NO_TREATS_TO_GIVE = "THAT TREAT SUPPLY HAS BEEN DEPLETED.",
	NOT_ALLOWED_DURING_NIGHT = "TOO LATE FOR THAT.",
	NOT_ALLOWED_DURING_DUSK = "NOT ALLOWED.",
	NOT_ALLOWED_DURING_DAY = "TOO EARLY FOR THAT.",
	NOT_HALLOWEEN = "HALLOWEEN NOT DETECTED.", -- note: this shouldn't really be possible to trigger
	NOT_HOME = "OCCUPANT NOT FOUND.",
}