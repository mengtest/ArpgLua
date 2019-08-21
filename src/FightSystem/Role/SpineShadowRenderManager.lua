-- Name:    SpineShadowRenderManager
-- Func：   spine影子渲染管理器
-- Author:  Johny

SpineShadowRenderManager = {}

---------------------局部变量----------------------
--------------------------------------------------

function SpineShadowRenderManager:init()
	if EngineSystem:getOS() == "ANDROID" then
		self.ONCE_RENDER_COUNT    =     5  --每次渲染数量
	else
		self.ONCE_RENDER_COUNT    =     10  --每次渲染数量
	end
	self.mShadowList = {}
	self.mCurRenderFlag = true
	self.mRenderTickCount = 0
end

function SpineShadowRenderManager:destroy()
	self.mShadowList = nil
end

function SpineShadowRenderManager:stopAllDrawed(stoped)
	if not self.mShadowList then return end
	for k, _shadow in pairs(self.mShadowList) do
	    if stoped then
	        _shadow:removeCanvas()
	    else
	    	_shadow:reloadCanvas()
	   	end
	end
end

function SpineShadowRenderManager:Tick()
	if #self.mShadowList == 0 then return end
	local _renderCount = 0
	for k,_shadow in pairs(self.mShadowList) do
		if _shadow.mRenderFlag == self.mCurRenderFlag then
		   _shadow:generate()
		   _shadow.mRenderFlag = not _shadow.mRenderFlag
		   _renderCount = _renderCount + 1
		end
		if _renderCount == self.ONCE_RENDER_COUNT then
		break end
	end
	if _renderCount > 0 then
	    cc.Director:getInstance():getRenderer():callRender()
	else
	   self.mCurRenderFlag = not self.mCurRenderFlag
	end
end

function SpineShadowRenderManager:addSpineShadow(_shadow)
	table.insert(self.mShadowList, _shadow)
end

function SpineShadowRenderManager:removeSpineShadow(_shadow)
	for k,v in pairs(self.mShadowList) do
		if v == _shadow then
		   table.remove(self.mShadowList, k)
		break end
	end
end


-- 偏移影子（摩托车上的人，抓投的人）
function SpineShadowRenderManager:offSetShadow(_role, _roleShadow, _posBind)
     local _param1 = math.rad(_roleShadow.mSkewX)
     local _offsetX = _posBind.x
     local _offsetY = math.cos(_param1) * _posBind.y * _roleShadow.mScaleY
     _roleShadow:setPositionX(_offsetX + _role:getPositionX())
     _roleShadow:setPositionY(_offsetY + _role:getPositionY())
end