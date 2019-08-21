-- Name: FightSceneViewTiledMap
-- Func: 战斗场景的tiledmap层
-- Author: Johny

FightSceneViewTiledMap = class("FightSceneViewTiledMap",function()
  return cc.Node:create()
end)

-- 降低场景饱和度
function FightSceneViewTiledMap:decreaseSaturation(_saturation)
	-- 不处理，为了和其他layer保持统一接口
end

-- 场景高斯模糊
function FightSceneViewTiledMap:blur()
	-- 不处理，为了和其他layer保持统一接口
end

function FightSceneViewTiledMap:ctor(_tb, _sceneView)
	-- statement
	self.mSceneView = _sceneView
    self.mType = _tb.type
    self.mResDB = DB_ResourceList.getDataById(_tb.resID)

    -- 移动类型
    -- #1: 相对运动
    -- #2: 绝对运动
    self.mMove_Type = _tb.moveType
	self.mMove_Speed = _tb.moveSpeed

    -- initial
	self:setLocalZOrder(_tb.zorder)
	self:setPositionY(_tb.height)
	--
	-- cclog(" FightSceneViewTiledMap:ctor=====" .. self.mResDB.Res_path1)
	self.mTiledMap = cc.TMXTiledMap:create(self.mResDB.Res_path1)
	self:addChild(self.mTiledMap)
	--
	self.mWidth = self.mTiledMap:getMapSize().width * 10
	self.mMaxOffsetX = getGoldFightScreenWidth() - self.mWidth
	--
	self.mHeight = self.mTiledMap:getMapSize().height * 10
	self.mMaxOffsetY = GG_GetWinSize().height - self.mHeight

	self.mCameraMaxOffX = math.abs(self.mMaxOffsetX - getGoldFightScreenWidth())

	self:InitTiledMapData()

end

function FightSceneViewTiledMap:InitTiledMapData()
	local flag = false
	for j = 0,76,1 do
		if not flag then
			if self.mTiledMap:getPropertyByGiledPos(0,j) == 1 then
				self.mTiledMapMiny =  j*10
				flag = true
			end
		else
			if self.mTiledMap:getPropertyByGiledPos(0,j) ~= 1 then
				self.mTiledMapMaxy =  j*10-10
				break
			end
		end
	end
end

function FightSceneViewTiledMap:Destroy()
	self.mSceneView = nil
    self.mType = nil
    self.mResDB = nil
    self.mMove_Type = nil
	self.mMove_Speed = nil
	self.mTiledMap:removeFromParent()
	self.mTiledMap = nil
	self.mWidth = nil
	self.mMaxOffsetX = nil
	self.mMaxOffsetX = nil
	self.mHeight = nil
	self.mMaxOffsetY = nil
	self:removeFromParent()
end

function FightSceneViewTiledMap:Tick(delta)
	-- 自动移动的场景
	if self.mMove_Type == 2 then
		self:MoveLayerLeft(self.mMove_Speed)
	end
end

-- 直接设置位置
function FightSceneViewTiledMap:setPosDirectly(_posx)
	local _fragIdx = math.ceil(_posx/1140)
	local _initposx = 0
	-- 见于有半屏图的情况，要做如下判断
	if _posx > self.mWidth then 
		_initposx = self.mWidth - 1140
	else
		_initposx = (_fragIdx - 1) * 1140
	end
	self:setPositionX(- _initposx)
end

function FightSceneViewTiledMap:FinishArrive()
	self.mIsMovingLayer = false
end

-- 向左移动
function FightSceneViewTiledMap:MoveLayerLeft(_disX,time)
	local _x = self:getPositionX()
	local _newPosX = _x - _disX 
	if not self:IsPosReachRightLimit(_newPosX) then
		if time then
			if FightConfig.CAMERA_SPEED_FIND == time then
				self.mIsMovingLayer = true
				self:stopActionByTag(1000)
				local act0 = cc.MoveTo:create(time, cc.p(_newPosX,self:getPositionY()))
				local act1 = cc.CallFunc:create(handler(self, self.FinishArrive))
				local act2 = cc.Sequence:create(act0,act1)
				act2:setTag(1000)
				self:runAction(act2)
			else
				if not self.mIsMovingLayer then
					self:stopActionByTag(1000)
					local act0 = cc.MoveTo:create(time, cc.p(_newPosX,self:getPositionY()))
					local act4 = cc.EaseOut:create(act0,1.5)
					local act1 = cc.CallFunc:create(handler(self, self.FinishArrive))
					local act2 = cc.Sequence:create(act4,act1)
					act2:setTag(1000)
					self:runAction(act2)
				end
			end
		else
			if not self.mIsMovingLayer then
				self:stopActionByTag(1000)
				self:setPositionX(_newPosX)
			end
		end	
	else
		if time then
			if FightConfig.CAMERA_SPEED_FIND == time then
				self.mIsMovingLayer = true
				self:stopActionByTag(1000)
				local act0 = cc.MoveTo:create(time,cc.p(self.mMaxOffsetX,self:getPositionY()))
				local act1 = cc.CallFunc:create(handler(self, self.FinishArrive))
				local act2 = cc.Sequence:create(act0,act1)
				act2:setTag(1000)
				self:runAction(act2)
			else
				if not self.mIsMovingLayer then
					self:stopActionByTag(1000)
					local act0 = cc.MoveTo:create(time,cc.p(self.mMaxOffsetX,self:getPositionY()))
					local act4 = cc.EaseOut:create(act0,1.5)
					local act1 = cc.CallFunc:create(handler(self, self.FinishArrive))
					local act2 = cc.Sequence:create(act4,act1)
					act2:setTag(1000)
					self:runAction(act2)
				end
			end
		else
			if not self.mIsMovingLayer then
				self:stopActionByTag(1000)
				self:setPositionX(self.mMaxOffsetX)
			end
		end	
		
	end
end


-- 向右移动(自动移动仅用此函数)
function FightSceneViewTiledMap:MoveLayerRight(_disX,time)
	local _x = self:getPositionX()
	local _newPosX = _x + _disX
	if not self:IsPosReachLeftLimit(_newPosX) then
		if time then
			if FightConfig.CAMERA_SPEED_FIND == time then
				self.mIsMovingLayer = true
				self:stopActionByTag(1000)
				local act0 = cc.MoveTo:create(time, cc.p(_newPosX,self:getPositionY()))
				local act1 = cc.CallFunc:create(handler(self, self.FinishArrive))
				local act2 = cc.Sequence:create(act0,act1)
				act2:setTag(1000)
				self:runAction(act2)
			else
				if not self.mIsMovingLayer then
					self:stopActionByTag(1000)
					local act0 = cc.MoveTo:create(time, cc.p(_newPosX,self:getPositionY()))
					local act4 = cc.EaseOut:create(act0,1.5)
					local act1 = cc.CallFunc:create(handler(self, self.FinishArrive))
					local act2 = cc.Sequence:create(act4,act1)
					act2:setTag(1000)
					self:runAction(act2)
				end
			end
		else
			if not self.mIsMovingLayer then
				self:stopActionByTag(1000)
				self:setPositionX(_newPosX)
			end
		end	
	else
		if time then
			if FightConfig.CAMERA_SPEED_FIND == time then
				self.mIsMovingLayer = true
				self:stopActionByTag(1000)
				local act0 = cc.MoveTo:create(time,cc.p(0.0,self:getPositionY()))
				local act1 = cc.CallFunc:create(handler(self, self.FinishArrive))
				local act2 = cc.Sequence:create(act0,act1)
				act2:setTag(1000)
				self:runAction(act2)
			else
				if not self.mIsMovingLayer then
					self:stopActionByTag(1000)
					local act0 = cc.MoveTo:create(time,cc.p(0.0,self:getPositionY()))
					local act4 = cc.EaseOut:create(act0,1.5)
					local act1 = cc.CallFunc:create(handler(self, self.FinishArrive))
					local act2 = cc.Sequence:create(act4,act1)
					act2:setTag(1000)
					self:runAction(act2)
				end
			end
		else
			if not self.mIsMovingLayer then
				self:stopActionByTag(1000)
				self:setPositionX(0.0)
			end	
		end	
	end
end

-- 图层已达最左端？
function FightSceneViewTiledMap:IsReachLeftLimit()
	return self:getPositionX() >= 0.0
end

-- 图层已达最右端？
function FightSceneViewTiledMap:IsReachRightLimit()
	return self:getPositionX() <= self.mMaxOffsetX
end

-- 图层已达最左端？
function FightSceneViewTiledMap:IsPosReachLeftLimit(_posX)
	return _posX >= 0.0
end

-- 图层已达最右端？
function FightSceneViewTiledMap:IsPosReachRightLimit(_posX)
	return _posX <= self.mMaxOffsetX
end

-- 图层已达最上端
function FightSceneViewTiledMap:IsReachUpLimit()
	return self:getPositionX() >= 0.0
end

-- 图层已达最下端
function FightSceneViewTiledMap:IsReachDownLimit()
	return self:getPositionY() <= self.mMaxOffsetY
end