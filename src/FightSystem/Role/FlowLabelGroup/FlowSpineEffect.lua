-- Name: FlowSpineEffect
-- Func: 文字漂浮控制器缓存器
-- Author: Johny

FlowSpineEffect = class("FlowSpineEffect")



function FlowSpineEffect:ctor(_resId, _root)
    local _sp =  CommonAnimation.createCacheSpine_commonByResID(_resId,_root)
	self.mSpine = _sp
    self.mSpine:registerSpineEventHandler(handler(self, self.onAnimationEvent),1)
    self.mSpine:setAnimation(0, "start", false)
end

--[[
spine 回调
]]
function FlowSpineEffect:onAnimationEvent(event)
    if event.type == 'end' then
        if event.animation == "start" then
            self:Destroy()
        end
    end
end

function FlowSpineEffect:Destroy()
    SpineDataCacheManager:collectFightSpineByAtlas(self.mSpine)
    self.mSpine = nil
end

