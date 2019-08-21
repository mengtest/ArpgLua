-- Name: FightSceneView
-- Func: 战斗场景层
-- #主要用于战斗中背景的展示，有多个层组成，每个层有自己的逻辑管理
-- Author: Johny

require "FightSystem/Scene/FightSceneViewLayer"
require "FightSystem/Scene/FightSceneViewTiledMap"

FightSceneView = class("FightSceneView",function()
  return cc.Node:create()
end)


-- 降低场景饱和度
function FightSceneView:decreaseSaturation(_saturation)
    for k,_layer in pairs(self.mLayers) do
        _layer:decreaseSaturation(_saturation)
    end
end

-- 场景高斯模糊
function FightSceneView:blur()
    for k,_layer in pairs(self.mLayers) do
        _layer:blur()
    end
end

--
function FightSceneView:ctor(zorder, mapID, isshow,_isHallScene)
  -- cclog("FightSceneView:ctor==MapID: " .. mapID)
  --
  self.mDB = DB_MapConfig.getDataById(mapID)  --数据表的一行数据，本类中直接使用
  self.mLayers = {}
  self.mtablemonster = {}
  self.mIsshow = isshow
  self.mIsHallScene = _isHallScene
  -- 地图滚动线
  local scaledwinSize = GG_GetScaledWinSize()
  local screenSize = GG_GetSceenSize()
  local winSize = GG_GetWinSize()

  local coefficient_width = winSize.width/screenSize.width
  self.coefficient_height = winSize.height/screenSize.height

  local extra_w = (scaledwinSize.width - screenSize.width) * 0.5
  local extra_h = (scaledwinSize.height - screenSize.height) * 0.5

  self.mTest = screenSize.height/scaledwinSize.height


  self.mScrollLine_L = (self.mDB.Map_Scroll_Line_Left * screenSize.width + extra_w)*coefficient_width
  self.mScrollLine_R = ((1 - self.mDB.Map_Scroll_Line_Right) * screenSize.width - extra_w)*coefficient_width
  self.mScrollLine_U = self.mDB.Map_Scroll_Line_Up * winSize.height
  self.mScrollLine_D = self.mDB.Map_Scroll_Line_Down * winSize.height

  -- cclog("mScrollLine_L == " .. self.mScrollLine_L .. " == mScrollLine_R == " .. self.mScrollLine_R)
  -- cclog("mScrollLine_U == " .. self.mScrollLine_U .. " == mScrollLine_D == " .. self.mScrollLine_D)
  

  -- 场景总高度
  self.mHeight = GG_GetScaledWinSize().height

  -- 出生点位置
  self.mBornPos = cc.p( getGoldFightPosition_LD().x, 0)

  -- initial
  self:Init(zorder)


  -- self:decreaseSaturation(0.1)
  -- self:blur()
end

function FightSceneView:Tick(delta)
   for k,layer in pairs(self.mLayers) do
      layer:Tick(delta)
   end
   self:TickBorn(delta)
end

function FightSceneView:TickBorn(delta)
  if self.mDB.Map_ControllerID == 0 then return end
  if #self.mtablemonster == 0 then return end
  local tempdel = {}
  for i,v in pairs(self.mtablemonster) do
    local isborn = v:TickBorn(delta)
    if isborn then
      self:LoadControllerItem(v)
      table.insert(tempdel,i)
    end
  end
  for k,v in pairs(tempdel) do
    self.mtablemonster[v] = nil
  end
end


function FightSceneView:Init(zorder)
	cclog("FightSceneView:Init1")

	--
	self:setLocalZOrder(zorder)
  self:setPositionX(self.mBornPos.x)
  -- cclog("FightSceneView:Init == " .. self.mBornPos.x)
	--


  -- 初始化各图层
  self:InitTiledMap()
  self:InitSkyLayer()
  self:InitBackBuildingLayer()
  self:InitMainBuildingLayer()
  self:InitWallLayer()
  self:InitRoadLayer()
  self:InitForegroundLayer()
  self:InitMapControll()

	cclog("FightSceneView:Init2")
end

function FightSceneView:InitMapControll()
  if self.mDB.Map_ControllerID ~= 0 then
    local data = DB_ControllerConfig.getDataById(self.mDB.Map_ControllerID)
    self:InitControllerData(data)
    self:PrestrainBornMonster()
  end
end

function FightSceneView:Destroy()
  for k,v in pairs(self.mLayers) do
      v:Destroy()
  end
  self.mtablemonster = nil
  self.mLayers = nil
  self.mTiledLayer = nil
  self.mDB = nil
  self.coefficient_height = nil
  self.mTest = nil
  self.mScrollLine_L = nil
  self.mScrollLine_R = nil
  self.mScrollLine_U = nil
  self.mScrollLine_D = nil
  self.mHeight = nil
  self.mBornPos = nil

  if self.mSunSpineList then
    for i,v in ipairs(self.mSunSpineList) do
       SpineDataCacheManager:collectFightSpineByAtlas(v)
    end
    self.mSunSpineList = nil
  end
  self:removeFromParent()
end

function FightSceneView:InitSkyLayer()
    cclog("FightSceneView:InitSkyLayer")
    local _tb = {}

    _tb.type = "sky"
    _tb.zorder = 0
    _tb.resID = self.mDB.Res_Sky_ID
    if _tb.resID == 0 then
        return
    end  
    _tb.moveType = self.mDB.Sky_Move_Type
    _tb.moveSpeed = self.mDB.Sky_Move_Speed
    _tb.height = self.mDB.Sky_Res_Height

    -- cclog("_tb.resID:  " .. _tb.resID)
  	local _ll = FightSceneViewLayer.new(_tb, self)
  	self:addChild(_ll)

    table.insert(self.mLayers, _ll)
end

function FightSceneView:InitBackBuildingLayer()
    cclog("FightSceneView:InitBackBuildingLayer")
    local _tb = {}

    _tb.type = "backbulding"
    _tb.zorder = 1
    _tb.resID = self.mDB.Res_BackBuilding_ID
    if _tb.resID == 0 then
        return
    end  
    _tb.moveType = self.mDB.BackBuilding_Move_Type
    _tb.moveSpeed = self.mDB.BackBuilding_Move_Speed
    _tb.moveSpeedY = self.mDB.B_SpeedY
    _tb.height = self.mDB.BackBuilding_Res_Height

    local _ll = FightSceneViewLayer.new(_tb, self)
    if self.mDB.Res_folderName == "beach" then
      local gridNode = cc.NodeGrid:create()
      local _action  = cc.Waves:create(30, cc.size(5,2), 10, 6, true, false)
      local _action_forever = cc.RepeatForever:create(_action)
      gridNode:runAction(_action_forever)
      gridNode:addChild(_ll)
      self:addChild(gridNode)
    else
      self:addChild(_ll)
    end

    table.insert(self.mLayers, _ll)
end

function FightSceneView:InitMainBuildingLayer()
    cclog("FightSceneView:InitMainBuildingLayer")
    local _tb = {}

    _tb.type = "mainbulding"
    _tb.zorder = 2
    _tb.resID = self.mDB.Res_MainBuilding_ID
    if _tb.resID == 0 then
        return
    end  
    _tb.moveType = self.mDB.MainBuilding_Move_Type
    _tb.moveSpeed = self.mDB.MainBuilding_Move_Speed
    _tb.moveSpeedY = self.mDB.M_SpeedY
    _tb.height = self.mDB.MainBuilding_Res_Height
    local _ll = FightSceneViewLayer.new(_tb, self)
    self:addChild(_ll)

    table.insert(self.mLayers, _ll)
end

function FightSceneView:InitWallLayer()
    cclog("FightSceneView:InitWallLayer")
    if self.mDB.Res_Wall_ID <= 0 then
    return end
    --
    local _tb = {}

    _tb.type = "wall"
    _tb.zorder = 3
    _tb.resID = self.mDB.Res_Wall_ID
    if _tb.resID == 0 then
        return
    end  
    _tb.moveType = self.mDB.Wall_Move_Type
    _tb.moveSpeed = self.mDB.Wall_Move_Speed
    _tb.moveSpeedY = self.mDB.W_SpeedY
    _tb.height = self.mDB.Wall_Res_Height

    local _ll = FightSceneViewLayer.new(_tb, self)
    if self.mDB.Res_folderName == "beach" then
      local gridNode = cc.NodeGrid:create()
      local _action  = cc.Waves:create(30, cc.size(2,2), 10, 6, true, false)
      local _action_forever = cc.RepeatForever:create(_action)
      gridNode:runAction(_action_forever)
      gridNode:addChild(_ll)
      self:addChild(gridNode)
    else
      self:addChild(_ll)
    end
    table.insert(self.mLayers, _ll)
    self.mWallGround = _ll
end

function FightSceneView:InitRoadLayer()
    cclog("FightSceneView:InitRoadLayer")
    local _tb = {}

    _tb.type = "road"
    _tb.zorder = 4
    _tb.resID = self.mDB.Res_Road_ID
    if _tb.resID == 0 then
        return
    end  
    _tb.moveType = self.mDB.Road_Move_Type
    _tb.moveSpeed = self.mDB.Road_Move_Speed
    _tb.height = self.mDB.Road_Res_Height

    local _ll = FightSceneViewLayer.new(_tb, self)
    self:addChild(_ll)

    table.insert(self.mLayers, _ll)
    self.mRoadGround = _ll
end

function FightSceneView:InitTiledMap()
    cclog("FightSceneView:InitTiledMap")
    local _tb = {}

    _tb.type = "tiledmap"
    _tb.zorder = 5
    _tb.resID = self.mDB.Res_TiledMap_ID
    if _tb.resID == 0 then
        return
    end  
    _tb.moveType = self.mDB.TiledMap_Move_Type
    _tb.moveSpeed = self.mDB.TieldMap_Move_Speed
    _tb.height = 0

    local _ll = FightSceneViewTiledMap.new(_tb, self)
    self:addChild(_ll)


    if type(self.mDB.SunshineEffect) == "table" then
      self.mSunSpineList = {}
      for i,v in ipairs(self.mDB.SunshineEffect) do
        local SunSpine = CommonAnimation.createCacheSpine_commonByResID(v,self)
        SunSpine:setLocalZOrder(6)
        SunSpine:setPosition(getGoldFightPosition_RU())
        SunSpine:setAnimation(0,"start",true)
        table.insert(self.mSunSpineList, SunSpine)
      end
    end
    
    table.insert(self.mLayers, _ll)

    self.mTiledLayer = _ll
  
end

function FightSceneView:setSyncmSunshine(_dis)
  if self.mSunSpineList then
    for i,v in ipairs(self.mSunSpineList) do
      v:setPositionY(getGoldFightPosition_RU().y)
      v:setPositionY(v:getPositionY() - self:getPositionY())
    end
  end
end

function FightSceneView:InitControllerData(data)
  local monsternum = 0
  for i = 1 ,data.Controller_MonsterCount do
    local index = i
    local Controller_ID = string.format("Controller_ID%d",i)
    local Controller_Type = string.format("Controller_Type%d",i)
    local Controller_DelayTime = string.format("Controller_DelayTime%d",i)
    local Controller_PositionX = string.format("Controller_PositionX%d",i)
    local Controller_PositionY = string.format("Controller_PositionY%d",i)
    local monster = MonsterObject.new()

    -- cclog("FubenManager:InitController()0" .. data.Controller_MonsterCount)
    monster.ID = data[Controller_ID]
    monster.Type = data[Controller_Type]
    if monster.Type == 3 then
        -- cclog("FubenManager:InitController()Type=" .. monster.Type)
        monster.DelayTime = data[Controller_DelayTime]
        -- cclog("FubenManager:InitController()DelayTime=" .. monster.DelayTime)
        monster.PositionX = data[Controller_PositionX]
        -- cclog("FubenManager:InitController()monster.PositionX=" .. monster.PositionX)
        monster.PositionY = data[Controller_PositionY]
        -- cclog("FubenManager:InitController()monster.PositionY=" .. monster.PositionY)
        if not self.mtablemonster then
          self.mtablemonster = {}
        end 
        self.mtablemonster[i] = monster
    end 
  end
end

function FightSceneView:PrestrainBornMonster()
  local tempdel = {}
  for i,v in pairs(self.mtablemonster) do
    local isborn = v:PrestrainBorn()
    if isborn then
      self:LoadControllerItem(v)
      table.insert(tempdel,i)
    end
  end
  for k,v in pairs(tempdel) do
    self.mtablemonster[v] = nil
  end
end

function FightSceneView:LoadControllerItem(item)
    if item.Type == 3 then
      local function loadMapAnimation()
       if not FightSystem.mSceneManager:GetTiledLayer() and not self.mTiledLayer then return end
        if self.mIsshow then
          FightSystem.mRoleManager:LoadSceneMapAnimation(item.ID,cc.p(item.PositionX,item.PositionY),nil,self.mTiledLayer,self.mIsHallScene)
        else
          FightSystem.mRoleManager:LoadSceneAnimation(item.ID,cc.p(item.PositionX,item.PositionY),nil,self.mTiledLayer,self.mIsHallScene)
        end
      end
      SpineDataCacheManager:applyForAddSpineDataCache(loadMapAnimation)
    end 
end

function FightSceneView:InitForegroundLayer()
    if self.mDB.Res_Foreground_ID == 0 then return end

    --
    cclog("FightSceneView:InitForegroundLayer")
    local _tb = {}

    _tb.type = "foreground"
    _tb.zorder = 7
    _tb.resID = self.mDB.Res_Foreground_ID
    _tb.moveType = self.mDB.Foreground_Move_Type
    _tb.moveSpeed = self.mDB.Foreground_Move_Speed
    _tb.moveSpeedY = self.mDB.F_SpeedY
    _tb.height = self.mDB.Foreground_Res_Height
    _tb.Foreground_TransParent = self.mDB.Foreground_TransparentHeight

    local _ll = FightSceneViewLayer.new(_tb, self)
    self:addChild(_ll)

    table.insert(self.mLayers, _ll)

    self.mForeGround = _ll
end

function FightSceneView:GetDownLimitPosY()
    return getGoldFightPosition_LD().y 
end

function FightSceneView:GetUpLimitPosY()
   return  -getGoldFightPosition_LD().y
end

-- 直接设置到场景上某点
function FightSceneView:setPosOnSceneDirectly(_posx)
    for k,layer in pairs(self.mLayers) do
        layer:setPosDirectly(_posx)
    end
end

-- 除sky层外,所有层左移
function FightSceneView:MoveAllLayersLeft(_disX , time)
   for k,layer in pairs(self.mLayers) do
       layer:MoveLayerLeft(_disX, time)
   end
end

-- 除sky层外,所有层右移
function FightSceneView:MoveAllLayersRight(_disX , time)
   for k,layer in pairs(self.mLayers) do
       layer:MoveLayerRight(_disX, time)
   end
end

-- 所有层上移动
function FightSceneView:MoveAllLayersVer(_posY,_disY)
   self:setPositionY(_posY)
   for k,layer in pairs(self.mLayers) do
      if layer.mMove_SpeedY then
        layer:MoveLayerVer()
      end    
   end
end

-- 检查层移出了左边
function FightSceneView:CheckMoveOutLeftSide()
   for k,layer in pairs(self.mLayers) do
      if not self:IsSkyLayer(layer) and not self:IsTiledmapLayer(layer) then
         layer:CheckMoveOutLeftSide()
      end
   end
end

-- 是否为自动移动的层
function FightSceneView:IsAutoMoveLayer(_layer)
    return _layer.mMove_Type == 2 
end

-- 是否为Sky层？
function FightSceneView:IsSkyLayer(_layer)
    return _layer.mType == "sky" 
end

-- 是否为tiledmap层？
function FightSceneView:IsTiledmapLayer(_layer)
    return _layer.mType == "tiledmap" 
end

-- road层达到最左端
function FightSceneView:IsRoadLayerReachLeftLimit()
   return self.mTiledLayer:IsReachLeftLimit()
end

-- road层达到最右端
function FightSceneView:IsRoadLayerReachRightLimit()
   return self.mTiledLayer:IsReachRightLimit()
end

-- 是否达到屏幕上方限制
--#需要通过sky层的Y坐标和高度获得整个场景的高度
function FightSceneView:IsReachUpLimit(_posY)
    return _posY <= self:GetUpLimitPosY()
end

-- 是否达到屏幕下方限制
function FightSceneView:IsReachDownLimit(_posY)
    return _posY >= self:GetDownLimitPosY()
end

function FightSceneView:GetSceneWidth()
  return self.mTiledLayer.mWidth
end

function FightSceneView:GetSceneHeight()
  return self.mHeight
end