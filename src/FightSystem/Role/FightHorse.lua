-- Name: FightHorse
-- Author: Johny

FightHorse = class("FightHorse", function()
   return cc.Node:create()
end)

function FightHorse:ctor(_role, _horseID)
	   self.mRole = _role
     self.mArmature = _role.mArmature
     local _DB = DB_HorseConfig.getDataById(_horseID)
     local _resDB = DB_ResourceList.getDataById(_DB.Horse_ResID[1])
     self.mHorseID = _horseID
     self.mName = _DB.Name
     self.mHorseType = _DB.Horse_Type
     self.mSpeed = _DB.Horse_Speed
     self.mSpineNode = cc.Node:create()
     self.mSpine = CommonAnimation.createCacheSpine_commonByResID(_DB.Horse_ResID[1],self.mSpineNode)
     if self.mRole.IsCityKeyRole then
        self.mSpine:registerSpineEventHandler(handler(self, self.onAnimationEvent), 1)
        self.mSpine:registerSpineEventHandler(handler(self, self.onAnimationEvent), 3)
     end

     if _DB.Horse_ResID[2] ~= 0 then
        self.mSpine2 = CommonAnimation.createCacheSpine_commonByResID(_DB.Horse_ResID[2],self.mSpineNode)
        self.mSpine2:setLocalZOrder(2)
     end
     

     self.mScale = 1
     self:addChild(self.mSpineNode)
     self.mInfoDB = _DB
      --[[
      self.mShadow = SpineShadowSprite.new()
      self.mShadow:initWithHorse(self)
      self:addChild(self.mShadow, -1)
      ]]
end

function FightHorse:Tick()
    self:tickHangRole()
end

function FightHorse:Destroy()
    self.mRole = nil
    self.mHorseID = nil
    self.mName =nil
    self.mHorseType = nil
    self.mSpeed = nil
    SpineDataCacheManager:collectFightSpineByAtlas(self.mSpine)
    self.mSpine = nil
    if self.mSpine2 then
      SpineDataCacheManager:collectFightSpineByAtlas(self.mSpine2)
      self.mSpine2 = nil
    end
    if self.mShadow then
       --self.mShadow:destroy()
       self.mShadow = nil
    end
    self:removeFromParent()
end

--向左
function FightHorse:faceLeft()
   self.mSpineNode:setScaleX(-1)
   --self.mShadow:setScaleX(-1)
end
--向右
function FightHorse:faceRight()
   self.mSpineNode:setScaleX(1)
   --self.mShadow:setScaleX(1)
end

-- 设置坐骑的X
function FightHorse:setPositionHorse_X(_x)
   self:setPositionX(_x)
end

-- 设置坐骑的Y
function FightHorse:setPositionHorse_Y(_y)
  self:setPositionY(_y)
  --self:ChangeScaleByPosY(_y)
end

function FightHorse:ChangeScaleByPosY(_y)
    local _scale = self.mRole:getTiledmapScaleByPosY(_y)
    self.mSpine:setScale(_scale*self.mScale)
    --self.mRole.mArmature:ChangeScaleByPosY(_y)
end

-- 挂角色
function FightHorse:hangRole()
   local _posRole = self.mRole:getPosition_pos()
   self.mSpineNode:addChild(self.mArmature)
   self:setPosition(_posRole)
   self:ActionNow("stand", true)
   self.mRole.mPropertyCon:setHorseSpeed(self.mRole.mPropertyCon.mSpeed*self.mSpeed)
   --[[
   self.mRole.mSpineShadow.IsStopTickPosX = true
   self.mRole.mSpineShadow.IsStopTickPosY = true
   ]]
end

-- 解绑角色
function FightHorse:unHangRole(_rolefunc)
   --[[
   self.mRole.mSpineShadow.IsStopTickPosX = false
   self.mRole.mSpineShadow.IsStopTickPosY = false
   ]]
   local function destroy()
       self:removeFromParent()
   end
   local _posHorse =  self.mSpine:getBonePosition("horse")
   local _curPos = cc.p(self:getPosition())
   local _rolePos = cc.p(_posHorse.x + _curPos.x, _posHorse.y + _curPos.y)
   self.mRole.mPropertyCon:resetSpeed()
   self.mRole:addToTiledLayer()
   self.mRole:fixFaceDirection()
   self.mArmature:setPosition_ArmatureX(_rolePos.x)
   self.mArmature:setPosition_ArmatureY(_rolePos.y)
   CommonAnimation.FadeoutToDestroy(self, destroy)
   -- 角色跳跃至影子点
   self.mArmature:ActionNow("jumpEnd")
   local _shadowPos = self.mRole:getShadowPos()
   local _ac = cc.JumpTo:create(0.3, _shadowPos, 20, 1)
   local _callback = cc.CallFunc:create(_rolefunc)
   _ac = cc.Sequence:create(_ac, _callback)
   self.mArmature:runAction(_ac)
end

-- tick绑定人和人影的位置
function FightHorse:tickHangRole()
     --local _roleShadow = self.mRole.mSpineShadow
     local _posHorse =  self.mSpine:getBonePosition("horse")
     pCall(self.mArmature, handler(self.mArmature, self.mArmature.setPositionX), _posHorse.x)
     pCall(self.mArmature, handler(self.mArmature, self.mArmature.setPositionY), _posHorse.y)
     --SpineShadowRenderManager:offSetShadow(self.mRole, _roleShadow, _posHorse)
end

-- 获取角色坐骑指令
local cmdHorseList = {"horseStand1", "horseStand3"}
local cmdHorseStandList = {"horseStand2", "horseStand4"}
function FightHorse:getRoleHorseAction(_state)
  if _state == "idle" then
    return cmdHorseStandList[self.mHorseType]
  else
    return cmdHorseList[self.mHorseType]
  end 
end

function FightHorse:onAnimationEvent(event)
    if event.type == 'event' and event.eventData.name == "sound" then
      local intEffectId = event.eventData.intValue
      if intEffectId and intEffectId > 0 then
        CommonAnimation.PlayEffectId(intEffectId)
      end
    end
end

--[[
  立刻执行动作
]]
function FightHorse:ActionNow(_ani, _loop)
    if not _loop then
      _loop = false
    end
    --
    if _ani == "stand" then
      self.mArmature:ActionNow(self:getRoleHorseAction("idle"), _loop)  
    elseif _ani == "run" then
      self.mArmature:ActionNow(self:getRoleHorseAction(), _loop)
    end
    local _curAni = self.mSpine:getCurrentAniName()
    if _curAni == _ani then
    return end
    self.mSpine:setAnimation(0, _ani, _loop) 
    if self.mSpine2 then
      self.mSpine2:setAnimation(0, _ani, _loop) 
    end 
end

