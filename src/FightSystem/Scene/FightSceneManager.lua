-- Name: FightSceneManager
-- Func: 战斗场景管理器
-- Author: Johny

require "FightSystem/Scene/FightSceneView"
require "FightSystem/Scene/FightSceneCamera"
require "FightSystem/Scene/AutoMoveManager"

FightSceneManager = {}
FightSceneManager.mSceneView = nil
FightSceneManager.mSceneArenaView = {}
FightSceneManager.mArenaViewIndex = 1
FightSceneManager.mCamera = FightSceneCamera
function FightSceneManager:Init()
	AutoMoveManager:init()
end

function FightSceneManager:Release()
	_G["FightSceneManager"] = nil
  	package.loaded["FightSceneManager"] = nil
  	package.loaded["FightSceneManager/Scene/FightSceneManager"] = nil
end

function FightSceneManager:Tick(delta)

	if self.mSceneView ~= nil then
		self.mSceneView:Tick(delta)
		self.mCamera:Tick(delta)
		self:tickCheckForegroundTransparent()
	end	
	--[[
	if FightSystem.mStatus == "runing" and FightSystem.mFightType == "arena" and globaldata.PvpType == "arena" then
		for i,v in ipairs(self.mSceneArenaView) do
			v:Tick(delta)
		end
		--self.mCamera:Tick(delta)
		self:tickCheckForegroundTransparent()
	else
		if self.mSceneView ~= nil then
			self.mSceneView:Tick(delta)
			self.mCamera:Tick(delta)
			self:tickCheckForegroundTransparent()
		end	
	end
	]]
end

-- 加载场景
function FightSceneManager:LoadSceneView(zorder, rootNode, mapID,_ishallScene)
	self.mSceneView = FightSceneView.new(zorder, mapID,nil,_ishallScene)
	self.mCamera:Init(self.mSceneView)
	rootNode:addChild(self.mSceneView)
end

-- 加载当前多个场景风
function FightSceneManager:LoadSceneArenaView(zorder, rootNode, mapID,index)
	local view = FightSceneView.new(zorder, mapID)
	self.mSceneArenaView[index] = view
	--self.mCamera:Init(view)
	rootNode:addChild(view)
end

function FightSceneManager:GetSceneView(sceneindex)
	--[[
	if FightSystem.mStatus == "runing" and FightSystem.mFightType == "arena" and globaldata.PvpType == "arena" then
		return self.mSceneArenaView[sceneindex]
	end
	]]
	return self.mSceneView
end

-- 卸载场景
function FightSceneManager:UnloadSceneView()
	if self.mSceneView then
		self.mSceneView:stopAllActions()
		self.mSceneView:Destroy()
		self.mSceneView = nil
	end
	for k,v in pairs(self.mSceneArenaView) do
		v:Destroy()
		v = nil
	end
	self.mSceneArenaView = {}
	self.mCamera:Destroy()
end

-- 更换场景
function FightSceneManager:changeSceneView(zorder, rootNode, mapID,_ishallScene)
	if self.mSceneView then self:UnloadSceneView() end
	self:LoadSceneView(zorder, rootNode, mapID,_ishallScene)
end

-- 获取场景的road层
function FightSceneManager:GetTiledLayer(sceneindex)
	if self:GetSceneView(sceneindex) then
		return self:GetSceneView(sceneindex).mTiledLayer
	else
		return nil
	end
end

function FightSceneManager:GetForeground(sceneindex)
	if self:GetSceneView(sceneindex) then
		return self:GetSceneView(sceneindex).mForeGround
	else
		return nil
	end
end

-- 查看前景透明度
function FightSceneManager:tickCheckForegroundTransparent()
	local _keyRole = FightSystem:GetKeyRole()
	if not _keyRole then return end
	--
	local _rolePosY = _keyRole:getPositionY()
	local _fg = self:GetForeground(_keyRole.mSceneIndex)
	if not _fg then return end
	if _rolePosY > _fg.mForeground_TransParent then return end
	--
	local _min = 0.2
	local _max = 1.0
	local _h = _fg.mForeground_TransParent
	local _rate = math.max(_min, _rolePosY / _h)
	_fg:setOpacity(_rate* 255)
end

return FightSceneManager