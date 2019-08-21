-- Name: FightSceneViewLayer
-- Func: 战斗场景层中的一层
-- #自行管理该层的逻辑，如层层对接，移动速度，边界处理等
--[[ #贴图策略:
	 一个分层的图片从num1-numN命名和排序，初始化分层时，
	 载入所有LayerTile并按照位置排好，根据分层移动的位置来
	 加载/卸载屏幕中和邻近的切块的纹理贴图。
]]
-- Author: Johny

require "FightSystem/Scene/LayerTile"


----------------------局部变量-----------------------------------
local _ENABLE_TILELAYER_ = true
local __TILEWIDTH__ 	 =  228
local _TILE_LOAD_MORE_   =    2	-- 额外加载的地图块数
local _D_SATURATION      =  0.1 -- 降低场景饱和度
local _BLUR_RADIUS       =  3.0
-----------------------------------------------------------------

FightSceneViewLayer = class("FightSceneViewLayer",function()
  return cc.Node:create()
end)


-- 降低场景饱和度
function FightSceneViewLayer:decreaseSaturation(_saturation)
	for k,_tile in pairs(self.mLayerTiles) do
		ShaderManager:decreaseSaturationTo(_tile, _D_SATURATION)
	end
end

-- 场景高斯模糊
function FightSceneViewLayer:blur()
	for k,_tile in pairs(self.mLayerTiles) do
		local _size = _tile:getContentSize()
		ShaderManager:blur(_tile, cc.vec2(_size.width, _size.height), _BLUR_RADIUS)
	end
end


function FightSceneViewLayer:ctor(_tb, _sceneView)
	-- statement
	self.mSceneView = _sceneView
    self.mType = _tb.type
    self.mResDB = DB_ResourceList.getDataById(_tb.resID)

    self.mPaths = {}
    -- 分块数量
    self.mFragCount = 0
    -- 同一时刻仅存在2个分块
    self.mLayer1 = nil
    self.mLayer2 = nil
    -- 分块出生点
    self.mFragBornPos = cc.p(0, 0)

	-- 分块宽度
	self.mFragWidth = 0

	-- 出生位置
	self.mBornPos = cc.p(0, _tb.height)

    -- 移动类型
    -- #1: 相对运动
    -- #2: 绝对运动
    self.mMove_Type = _tb.moveType
	self.mMove_Speed = _tb.moveSpeed
	self.mMove_SpeedY = _tb.moveSpeedY
	-- 绝对运动，按秒计算的速度
	self.mMove_Speed_second = _tb.moveSpeed
	if self.mMove_Type == 2 then
	   self.mMove_Speed_second = self.mMove_Speed_second * MathExt._game_frame
	end

	-- 设置前景检测的透明高度
	if self.mType == "foreground" then
	   self.mForeground_TransParent = _tb.Foreground_TransParent
	end

	-- 层自动移动监测
	self.mMoveTime = 0
	self.mFlag = 0

    -- initial
	self:setLocalZOrder(_tb.zorder)
	self:setPositionY(_tb.height)


	-- 预加载资源, 得到分块数量
	self:initResList()
	-- 初始化分块宽度
	self:SetWidthAndFragWidth(__TILEWIDTH__)
	local _maxOffX = _RESOURCE_DESIGN_RESOLUTION_W_ - self.mWidth

	if self:isAutoMoved() then
		if _maxOffX == 0 then
			_maxOffX = -_RESOURCE_DESIGN_RESOLUTION_W_
		end
	   _maxOffX = _maxOffX * 2000 -- 决定自动移动的时间
	end
	-- pad的两个值不同，由于宽远小于1140，需要拉伸靠近1140
	-- phone的高拉伸后与拉伸前不同，由于高远小于770，需要拉伸靠近770
	local edge = math.abs(GG_GetScaledWinSize().width - GG_GetSceenSize().width)
	-- 根据不同分辨率，乘以系数不同，使减去的补丁大小相同
	_maxOffX = _maxOffX - edge * (_RESOURCE_DESIGN_RESOLUTION_W_ / GG_GetScaledWinSize().width)
	self.mMaxOffset = cc.p(_maxOffX, 0)
	-- 初始化分层
	self:initAllFrags()

	-- 注册监听
	self:registerNotification()
end

function FightSceneViewLayer:registerNotification()
	FightSystem:RegisterNotifaction("keyrolestopmoved", "FightSceneViewLayer", handler(self, self.onKeyRoleStopMoved))
end

function FightSceneViewLayer:unregisterNotification()
	FightSystem:UnRegisterNotification("keyrolestopmoved", "FightSceneViewLayer")
end

function FightSceneViewLayer:Destroy()
	self:unregisterNotification()
	self.mSceneView = nil
    self.mType = nil
    self.mResDB = nil
    self.mPaths = nil
    self.mFragCount = nil
    if self.mLayer1 then
	    self.mLayer1:removeFromParent()
	    self.mLayer1 = nil
	end
	if self.mLayer2 then
	    self.mLayer2:removeFromParent()
	    self.mLayer2 = nil
	end
    self.mFragBornPos = nil
	self.mFragWidth = nil
	self.mBornPos = nil
    self.mMove_Type = nil
	self.mMove_Speed = nil
	self:removeFromParent()
end

function FightSceneViewLayer:Tick(delta)
	-- 自动移动的场景
	if self:isAutoMoved() then
		self:MoveLayerLeft_Auto(self.mMove_Speed_second * delta)
	end

	if self.mMoveTime ~= 0 then
		self.mMoveTime = self.mMoveTime - delta
		if self.mMoveTime <= 0 then
			self.mMoveTime = 0
		end
	end

	self:tickFrag()

	FightSystem:PushNotification("scenelayermoved", self.mType, cc.p(self:getPosition()))
end

-- 是否为自动移动
function FightSceneViewLayer:isAutoMoved()
	return self.mMove_Type == 2
end

-- 初始化资源路径数组
function FightSceneViewLayer:initResList()
	self.mFragCount = self.mResDB.Res_count
end

-- 初始化所有分层
function FightSceneViewLayer:initAllFrags()
	self.mLayerTiles_OriPosX = {}
	self.mLayerTiles = {}
	local _posX = 0
	local _fragCount = math.ceil(self.mFragCount)
	for i = 1, _fragCount do
		local _tile = LayerTile.new(self.mSceneView.mDB.Res_folderName, self.mResDB.Res_path1, i)
		_tile:loadTextureFromIO()
		self:addChild(_tile)
		_tile:setAnchorPoint(cc.p(0,0))
		_tile:setPositionX(_posX)
		table.insert(self.mLayerTiles, _tile)
		table.insert(self.mLayerTiles_OriPosX, _posX)
		_posX = _posX + __TILEWIDTH__
	end 
end

-- 封装setPositionX
-- _x范围-n ~ 0
function FightSceneViewLayer:MysetPositionX(_x)
	self:setPositionX(_x)
end

-- 直接设置位置
function FightSceneViewLayer:setPosDirectly(_posx)
	local movespeed = 1
	if self.mMove_Speed ~= 0 then
		movespeed = self.mMove_Speed
	end
	local _tiled_x = self.mSceneView.mTiledLayer:getPositionX()
	local _posX = _tiled_x * movespeed
	self:MysetPositionX(_posX)
end

-- 设置块宽和总宽
function FightSceneViewLayer:SetWidthAndFragWidth(_fragWidth)
	if self.mFragWidth == 0 or self.mWidth == 0 then
		self.mFragWidth = _fragWidth
		self.mWidth = _fragWidth * self.mResDB.Res_count
		-- cclog("FightSceneViewLayer:SetWidthAndFragWidth == mFragWidth == " .. self.mFragWidth .. "==" .. self.mWidth)
	end
end

-- 向左移动
function FightSceneViewLayer:MoveLayerLeft(_disX,time)
	self:MoveLayerLeft_Auto(_disX,time)
end

-- 垂直移动
function FightSceneViewLayer:MoveLayerVer()
	if self.mMove_SpeedY and self.mMove_SpeedY ~= 0 then
		self:setPositionY(self.mBornPos.y)
		local yy = (self.mSceneView:getPositionY() - getGoldFightPosition_LD().y)*(self.mMove_SpeedY-1)+self:getPositionY()
		self:setPositionY(yy)
	end
end

function FightSceneViewLayer:FinishArrive()
	self.mIsMovingLayer = false
	self:MoveLayerVer()
	if self.mFlag == 1 then
		self.mFlag = 0
		self.mMoveTime = 0
	elseif self.mFlag == 2 then
		self.mFlag = 0
		self.mMoveTime = 0
	end
end

-- 自动移动仅用此函数
function FightSceneViewLayer:MoveLayerLeft_Auto(_disX, time)
	local _increased = 0
	if self:isAutoMoved() then 
	   _increased = _disX
	else
		_increased = _disX*self.mMove_Speed
	end
	local _newPosX = self:getPositionX() - _increased
	if not self:IsPosReachRightLimit(_newPosX) then
		if time then
			if time == FightConfig.CAMERA_SPEED_FIND then
				self.mIsMovingLayer = true
				self:stopActionByTag(1000)
				local act0 = cc.MoveTo:create(time, cc.p(_newPosX,self:getPositionY()))
				local act1 = cc.CallFunc:create(handler(self, self.FinishArrive))
				local act2 = cc.Sequence:create(act0,act1)
				act2:setTag(1000)
				self:runAction(act2)
				self.mFlag = 1
				self.mMoveTime = time
			else
				if not self.mIsMovingLayer then
					self:stopActionByTag(1000)
					local act0 = cc.MoveTo:create(time, cc.p(_newPosX,self:getPositionY()))
					local act4 = cc.EaseOut:create(act0,1.5)
					local act1 = cc.CallFunc:create(handler(self, self.FinishArrive))
					local act2 = cc.Sequence:create(act4,act1)
					act2:setTag(1000)
					self:runAction(act2)
					self.mFlag = 1
					self.mMoveTime = time
				end
			end
		else
			if not self.mIsMovingLayer then
				self:stopActionByTag(1000)
				self:MysetPositionX(_newPosX)
			end
		end
	else
		if time then
			if time == FightConfig.CAMERA_SPEED_FIND then
				self.mIsMovingLayer = true
				self:stopActionByTag(1000)
				local act0 = cc.MoveTo:create(time,cc.p(self:GetMaxOffset().x,self:getPositionY()))
				local act1 = cc.CallFunc:create(handler(self, self.FinishArrive))
				local act2 = cc.Sequence:create(act0,act1)
				act2:setTag(1000)
				self:runAction(act2)
				self.mFlag = 1
				self.mMoveTime = time
			else
				if not self.mIsMovingLayer then
					self:stopActionByTag(1000)
					local act0 = cc.MoveTo:create(time,cc.p(self:GetMaxOffset().x,self:getPositionY()))
					local act4 = cc.EaseOut:create(act0,1.5)
					local act1 = cc.CallFunc:create(handler(self, self.FinishArrive))
					local act2 = cc.Sequence:create(act4,act1)
					act2:setTag(1000)
					self:runAction(act2)
					self.mFlag = 1
					self.mMoveTime = time
				end
			end
		else
			if not self.mIsMovingLayer then
				self:stopActionByTag(1000)
				self:MysetPositionX(self:GetMaxOffset().x)
			end
		end
	end
end


-- 向右移动
function FightSceneViewLayer:MoveLayerRight(_disX,time)
	local _increased = _disX*self.mMove_Speed
	if self:isAutoMoved() then 
	   _increased = _disX
	end
	local _newPosX = self:getPositionX() + _increased
	local con = not self:IsPosReachLeftLimit(_newPosX)
	if con then
		if time then
			if time == FightConfig.CAMERA_SPEED_FIND then
				self.mIsMovingLayer = true
				self:stopActionByTag(1000)
				local act0 = cc.MoveTo:create(time, cc.p(_newPosX,self:getPositionY()))
				local act1 = cc.CallFunc:create(handler(self, self.FinishArrive))
				local act2 = cc.Sequence:create(act0,act1)
				act2:setTag(1000)
				self:runAction(act2)
				self.mFlag = 2
				self.mMoveTime = time
			else
				if not self.mIsMovingLayer then
					self:stopActionByTag(1000)
					local act0 = cc.MoveTo:create(time, cc.p(_newPosX,self:getPositionY()))
					local act4 = cc.EaseOut:create(act0,1.5)
					local act1 = cc.CallFunc:create(handler(self, self.FinishArrive))
					local act2 = cc.Sequence:create(act4,act1)
					act2:setTag(1000)
					self:runAction(act2)
					self.mFlag = 2
					self.mMoveTime = time
				end
			end
		else
			if not self.mIsMovingLayer then
				self:stopActionByTag(1000)
				self:MysetPositionX(_newPosX)
			end
		end
	else
		if time then
			if time == FightConfig.CAMERA_SPEED_FIND then
				self.mIsMovingLayer = true
				self:stopActionByTag(1000)
				local act0 = cc.MoveTo:create(time,cc.p(self:GetBornPos().x,self:getPositionY()))
				local act1 = cc.CallFunc:create(handler(self, self.FinishArrive))
				local act2 = cc.Sequence:create(act0,act1)
				act2:setTag(1000)
				self:runAction(act2)
				self.mFlag = 2
				self.mMoveTime = time
			else
				if not self.mIsMovingLayer then
					self:stopActionByTag(1000)
					local act0 = cc.MoveTo:create(time,cc.p(self:GetBornPos().x,self:getPositionY()))
					local act4 = cc.EaseOut:create(act0,1.5)
					local act1 = cc.CallFunc:create(handler(self, self.FinishArrive))
					local act2 = cc.Sequence:create(act4,act1)
					act2:setTag(1000)
					self:runAction(act2)
					self.mFlag = 2
					self.mMoveTime = time
				end
			end

		else
			if not self.mIsMovingLayer then
				self:stopActionByTag(1000)
				self:MysetPositionX(self:GetBornPos().x)
			end
		end	
	end
end


-- 图层已达最左端？
function FightSceneViewLayer:IsReachLeftLimit()
	return self:getPositionX() >= self:GetBornPos().x
end

-- 图层已达最右端？
function FightSceneViewLayer:IsReachRightLimit()
	return self:getPositionX() <= self:GetMaxOffset().x
end

-- POSX图层已达最左端？
function FightSceneViewLayer:IsPosReachLeftLimit(_posX)
	return _posX >= self:GetBornPos().x
end

-- POSX图层已达最右端？
function FightSceneViewLayer:IsPosReachRightLimit(_posX)
	return _posX <= self:GetMaxOffset().x
end

-- 获得该层出生点
function FightSceneViewLayer:GetBornPos()
	return self.mBornPos
end

-- 获得该层最大偏移点
function FightSceneViewLayer:GetMaxOffset()
	return self.mMaxOffset
end


-----------------------------自动移动层使用-----------------------------------------
-- 实时检测切条
function FightSceneViewLayer:tickFrag()
	local _x = self:getPositionX()
	local function updateLayerTiles()
		local _beginPos = -_x
		local _endPos = _RESOURCE_DESIGN_RESOLUTION_W_ - _x
		-- beginPos~endPos之间的tile都要显示
		local _beginNum = math.ceil(_beginPos / __TILEWIDTH__)
		if _beginNum <=0 then _beginNum = 1 end 
		if _beginNum > 1 then _beginNum = _beginNum - 1 end
		local _endNum = math.floor(_endPos / __TILEWIDTH__)
		for i = 1, self.mFragCount do
			-- 多加载N块，不然会延迟补图
			if i >= _beginNum - _TILE_LOAD_MORE_ and i <= _endNum + _TILE_LOAD_MORE_ then
				self.mLayerTiles[i]:loadTextureFromIO()
			else
				self.mLayerTiles[i]:unloadTextureFromCache()
			end
		end
	end
	local function updateLayerTiles_auto()
		local _beginPos = -_x
		local _endPos = _RESOURCE_DESIGN_RESOLUTION_W_ - _x
		-- beginPos~endPos之间的tile都要显示
		local _beginNum = math.ceil(_beginPos / __TILEWIDTH__)
		if _beginNum <=0 then _beginNum = 1 end 
		if _beginNum > 1 then _beginNum = _beginNum - 1 end
		local _endNum = math.floor(_endPos / __TILEWIDTH__)
		-- 多加载一块，不然会延迟补图
		for i = _beginNum,_endNum + 1 do
		    local _idx = math.fmod(i, self.mFragCount)
		    local _rest = math.floor(i / self.mFragCount)
		    if _idx == 0 then 
		    	_idx = self.mFragCount 
		    	_rest = _rest - 1
		    end
		    local _newPosX = self.mLayerTiles_OriPosX[_idx] + _rest * self.mWidth
		    self.mLayerTiles[_idx]:setPositionX(_newPosX)
		end
	end
	if self:isAutoMoved() then
		updateLayerTiles_auto()
	else
		updateLayerTiles()
	end
end
-------------------------------------------------------------------------------------


-----------------------回调-----------------------------
function FightSceneViewLayer:onKeyRoleStopMoved()
	
end