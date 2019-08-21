-- Func: 特效控制器
-- Author: Johny

EffectController = class("EffectController")

function EffectController:ctor(_role)
	self.mRole = _role
end

function EffectController:Destroy()
	self.mRole = nil
end

function EffectController:Tick(delta)

end

-- 用_pathID当key去控件缓存中查找
function EffectController:GetEffectByResID(_resID,_root)
	local _spine = CommonAnimation.createCacheSpine_commonByResID(_resID[1],_root)
	_spine:setPosition(cc.p(0,0))
	local function OnAnimationEvent(event)
		SpineDataCacheManager:collectFightSpineByAtlas(_spine)
	end
	_spine:registerSpineEventHandler(OnAnimationEvent, 1)
	_spine:setAnimation(0, _resID[2], false)

	return _spine
end