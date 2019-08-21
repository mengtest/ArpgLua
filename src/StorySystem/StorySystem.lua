-- Name: StorySystem
-- Func: 剧情系统
-- Author: Johny

StorySystem = {}
StorySystem.mType = "STORYSYSTEM"


function StorySystem:Init()
    cclog("=====StorySystem:Init=====1")
    self.mCGManager = require("StorySystem/StoryCGManager")
	cclog("=====StorySystem:Init=====2")
end


function StorySystem:Tick(delta)
	self.mCGManager:Tick(delta)
end

function StorySystem:Release()
	self.mCGManager:Release()
	--
	_G["StorySystem"] = nil
 	package.loaded["StorySystem"] = nil
 	package.loaded["StorySystem/StorySystem"] = nil
end



return StorySystem