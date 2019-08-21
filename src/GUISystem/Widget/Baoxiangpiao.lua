-- Name: 	Baoxiangpiao
-- Func：	Baoxiangpiao
-- Author:	lvyunlong
-- Data:	14-12-17

Baoxiangpiao = {}
local BaoxiangpiaoZOrder = 200

-- 
function Baoxiangpiao:showBaoxiang(iconfile,pos1,pos)
	local icon = cc.Sprite:create()
	icon:setProperty("Frame", iconfile)
	local function doCleanup()
		FightSystem.mTouchPad:BaoxiangNum()
		FightSystem.mTouchPad:BaoxiangScale()
		icon:removeFromParent(true)
	end
	-- 做动作
	icon:setPosition(pos1)
	FightSystem.mTouchPad:addChild(icon, BaoxiangpiaoZOrder)
	local function doAction()
		local actscale = cc.ScaleTo:create(1, 0.5)
		local act0 = cc.MoveTo:create(1, pos)
		local act1 = cc.EaseSineIn:create(act0)
		local act2 = cc.CallFunc:create(doCleanup)
		icon:runAction(cc.Sequence:create( cc.Spawn:create(actscale,act1), act2 ))	
	end 
	doAction()
end

function Baoxiangpiao:showBaoJinbi(obj,pos1,pos)
	local function doCleanup()
		FightSystem.mTouchPad:JinbiNum()
		FightSystem.mTouchPad:JinbiScale()
		SpineDataCacheManager:collectFightSpineByAtlas(obj)
	end
	-- 做动作
	obj:setPosition(pos1)
	FightSystem.mTouchPad:addChild(obj, BaoxiangpiaoZOrder)
	local function doAction()
		local actscale = cc.ScaleTo:create(1, 0.5)
		local act0 = cc.MoveTo:create(1, pos)
		local act1 = cc.EaseSineIn:create(act0)
		local act2 = cc.CallFunc:create(doCleanup)
		obj:runAction(cc.Sequence:create( cc.Spawn:create(actscale,act1), act2 ))	
	end 
	doAction()
end

