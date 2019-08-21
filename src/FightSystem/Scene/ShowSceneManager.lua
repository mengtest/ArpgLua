-- Name: ShowSceneManager
-- Func: 场景管理器
-- Author: tuanzhang

require "FightSystem/Scene/FightSceneView"

ShowSceneManager = {}
ShowSceneManager.mSceneView = nil
function ShowSceneManager:Init()

end

function ShowSceneManager:Release()
	_G["ShowSceneManager"] = nil
  	package.loaded["ShowSceneManager"] = nil
  	package.loaded["ShowSceneManager/Scene/ShowSceneManager"] = nil
end

function ShowSceneManager:Tick(delta)
	if self.mSceneView ~= nil then
		self.mSceneView:Tick(delta)
		self:tickCheckForegroundTransparent()
	end	
end

-- 加载场景
function ShowSceneManager:LoadSceneView(zorder, rootNode, mapID)
	self.mSceneView = FightSceneView.new(zorder, mapID ,true)
	rootNode:addChild(self.mSceneView)
end

-- 卸载场景
function ShowSceneManager:UnloadSceneView()
	if self.mSceneView then
		self.mSceneView:Destroy()
		self.mSceneView = nil
	end
end

-- 更换场景
function ShowSceneManager:changeSceneView(zorder, rootNode, mapID)
	if self.mSceneView then self:UnloadSceneView() end
	self:LoadSceneView(zorder, rootNode, mapID)
end

function ShowSceneManager:GetWallGround()
	return self.mSceneView.mWallGround
end

-- 获取场景的road层
function ShowSceneManager:GetTiledLayer()
	return self.mSceneView.mTiledLayer
end

function ShowSceneManager:GetForeground()
	return self.mSceneView.mForeGround
end

-- 查看前景透明度
function ShowSceneManager:tickCheckForegroundTransparent()
	-- 先判断有无前景
	local _fg = self:GetForeground()
	if not _fg then return end
	---
	local _keyRole = FightSystem.mRoleManager:GetKeyRole()
	if not _keyRole then return end
	local _rolePosY = _keyRole:getPositionY()
	if _rolePosY > _fg.mForeground_TransParent then return end
	--
	local _min = 0.2
	local _max = 1.0
	local _h = _fg.mForeground_TransParent
	local _rate = math.max(_min, _rolePosY / _h)
	_fg:setOpacity(_rate* 255)
end

return ShowSceneManager