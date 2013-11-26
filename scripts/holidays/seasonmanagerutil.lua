local SeasonManager = require "components/seasonmanager"

if SeasonManager.GetYearLength == nil then
	function SeasonManager:GetYearLength()
		return self.winterlength + self.summerlength
	end
end