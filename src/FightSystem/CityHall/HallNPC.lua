-- Func: 城镇大厅NPC
-- Author: Johny

-- 层级关系
-- 0: spine
-- 1: title


HallNPC = class("HallNPC", function()
   return cc.Node:create()
end)

function HallNPC:ctor(_npcID, _pos, _npcFunc, _npcVoice, _root)
   self.mID = _npcID
   self.mDB = DB_MonsterConfig.getDataById(_npcID)
   self.mBornDirection = self.mDB.Monster_Direction -- 1:左  0：右
   self.mBornPos = cc.p(_pos[1], _pos[2])
   self.mWindowKey = _npcFunc
   self.mVoiceList = _npcVoice
   self.hasPlaySound = false
   self.hasShowDialog = false
   self.mLastVoiceNum = 0
   self.mLastOpenALIndex = 0
   --
   self.TouchFlag = false
   --
   self:setPosition(self.mBornPos)
   self:setLocalZOrder(1440 - self.mBornPos.y)
   _root:addChild(self)
   --
   self:Init()
end

function HallNPC:Destroy()
   FightSystem:UnRegisterNotification("hall_myrolemove", string.format("HallNPC%d",self.mID))
   SpineDataCacheManager:collectFightSpineByAtlas(self.mSpine)
   self.mSpine = nil
   if self.mSpineShadow then
      self.mSpineShadow:destroy()
      self.mSpineShadow = nil
   end
   self:removeFromParent()
end

-- 预加载声音
function HallNPC:preloadVoice()
   for k,v in pairs(self.mVoiceList) do
       Event.SOUNDSYS_EFFECT_PRELOAD.mData = v
       EventSystem:PushEvent(Event.SOUNDSYS_EFFECT_PRELOAD)
   end
end

function HallNPC:Init()
    -- spine
    self:initSpine()
    -- relax
    self:initRolerelax()
    -- shadow
    self:initShadow()
    -- 触摸区域
    self:initRegion()
    -- title
    self:initTitle()
    -- 预加载声音
    self:preloadVoice()
    -- registerNotification
    -- FightSystem:RegisterNotifaction("hall_myrolemove", string.format("HallNPC%d",self.mID), handler(self, self.OnEventTheRoleMove))
end

-- init spine
function HallNPC:initSpine()
    local _resID = self.mDB.Monster_SimpleModel
    local _resScale = self.mDB.Monster_SimpleModelZoom
    if _resID <= 0 then
       _resID = self.mDB.Monster_Model
       _resScale = self.mDB.Monster_ModelZoom
    end
    self.mSpineScale = _resScale
    local _resDB = DB_ResourceList.getDataById(_resID)
    self.mSpine = SpineDataCacheManager:getFightSpineByatlas(_resDB.Res_path2, _resDB.Res_path1, _resScale, self)
    self.mSpine:setSkeletonRenderType(cc.RENDER_TYPE_NPC)
    self.mSpine:setLocalZOrder(1)
    self.mSpine:setAnimation(0, "stand", true)
    self.mSpineNode = cc.Node:create()
    self.mSpineNode:addChild(self.mSpine)
    self:addChild(self.mSpineNode, 1)
    if self.mBornDirection == 1 then
       self.mSpineNode:setScaleX(-1)
    end
    ----
    local function updateSpineBox()
        if not self.mSpine then return end
        local pos = self.mSpine:getBonePosition("name")
        local height = nil
        if pos.y ~= 0 then
          height = pos.y*self.mSpineScale
          if height == 0 then
            height = self.mSpine:getBoundingBox().height + 20
          end
        else
          height = self.mSpine:getBoundingBox().height + 20
        end
        if self.mDB.Name > 0 then
          self.mLbName:setPositionY( height-20)
          height = height + self.mLbName:getContentSize().height     
        end
        if self.mDB.Title > 0 then
          self.mLbTitle:setPositionY(height)
        end
    end
    local act0 = cc.DelayTime:create(1/30)
    local act1 = cc.CallFunc:create(updateSpineBox)
    self:runAction(cc.Sequence:create(act0, act1))
end

-- init relax
function HallNPC:initRolerelax()
  local function ActionCallback(_action)
    if _action.type == 'end' and _action.animation == self.mHallrelax then
      self.mSpine:setAnimation(0, "stand", true)
    end
  end
  self.mHallrelax = "relax"
  self.mTimerelax = 0
  self.mWaitrelaxTime = math.random(10,15)
  self.mSpine:registerSpineEventHandler(ActionCallback,1)
end

-- 大厅人物检测休闲动作
function HallNPC:TickHallRoleIdleTime(delta)
  if self.mTimerelax then
    self.mTimerelax = self.mTimerelax + delta
    if self.mTimerelax >= self.mWaitrelaxTime then
      self.mWaitrelaxTime = math.random(10,15)
      self.mTimerelax = 0
      self.mSpine:setAnimation(0, self.mHallrelax, false)
    end
  end
end

-- init region
function HallNPC:initRegion()
   createSpineTouchRegion(cc.size(self.mDB.Monster_Width, 170), self, handler(self, self.OnTouchEvent))
end

-- init title
function HallNPC:initTitle()
    local _y = 200
    -- name
    if self.mDB.Name > 0 then
        local _nameDB = DB_Text.getDataById(self.mDB.Name)
        self.mLbName = ccui.Text:create()
        self.mLbName:setLocalZOrder(2)
        self.mLbName:setFontName("res/fonts/font_3.ttf")
        --self.mLbName:setColor(cc.c3b(255, 248, 128))
        self.mLbName:setFontSize(_nameDB.Text_CNSize)
        LabelManager:outline(self.mLbName,G_COLOR_C4B.BLACK)
        self:addChild(self.mLbName)
        self.mLbName:setAnchorPoint(cc.p(0.5, 0))
        self.mLbName:setPosition(cc.p(0, _y))
        self.mLbName:setString(_nameDB.Text_CN)
        _y = _y + self.mLbName:getContentSize().height
    end
    -- func
    if self.mDB.Title > 0 then
        local _textDB = DB_Text.getDataById(self.mDB.Title)
        self.mLbTitle = ccui.Text:create()
        self.mLbTitle:setLocalZOrder(2)
        self:addChild(self.mLbTitle)
        self.mLbTitle:setAnchorPoint(cc.p(0.5, 0))
        self.mLbTitle:setPosition(cc.p(0, _y))
        self.mLbTitle:setString(_textDB.Text_CN)
        self.mLbTitle:setFontSize(_textDB.Text_CNSize)
    end
end

-- init shadow
function HallNPC:initShadow()
    if self.mDB.HideBloodShadow == 1 then return end
    --[[
    self.mSpineShadow = SpineShadowSprite.new()
    self.mSpineShadow:initWithSpine(self.mSpine, self.mBornDirection)
    self:addChild(self.mSpineShadow, 0)
    if self.mBornDirection == 1 then
       self.mSpineShadow:setScaleX(-1)
    end
    ]]
    self.mShadowwidth = self.mDB.ShadowSize[1]
    self.mShadowheight = self.mDB.ShadowSize[2]
  
    local Shadow = cc.Sprite:create()
    local _resDB = DB_ResourceList.getDataById(645)
    Shadow:setProperty("Frame", _resDB.Res_path1)
    self:addChild(Shadow)
    Shadow:setScaleX(self.mShadowwidth*self.mDB.Monster_ModelZoom)
    Shadow:setScaleY(self.mShadowheight*self.mDB.Monster_ModelZoom)
    
end

function HallNPC:Tick(delta)
   self:TickHallRoleIdleTime(delta)
end

function HallNPC:playSound()
   if #self.mVoiceList == 0 then return end
   local function onPlayEffect(_openalindex)
      self.mLastOpenALIndex = _openalindex
   end
   CommonAnimation.StopEffectId(self.mLastOpenALIndex)
   local _num = math.random(1, #self.mVoiceList)
   -- 检查是否重复
   if self.mLastVoiceNum == _num then
       _num = _num + 1
       if _num > #self.mVoiceList then 
          _num = 1
       end
   end
   self.mLastVoiceNum = _num
   CommonAnimation.PlayEffectId(self.mVoiceList[_num], onPlayEffect)
end

-- 打开各个window
function HallNPC:openWindow(_key)
      -- if _key == "shangcheng" then
      --    GUISystem:goTo(_key, 1)
      -- else
      --    GUISystem:goTo(_key)
      -- end
      if FightSystem.mTaskMainManager:IsTaskNPC(self.mID) then
        FightSystem.mTaskMainManager:TalkDialog()
      end
end

-- 关注角色移动通知
function HallNPC:OnEventTheRoleMove(_thePos)
   --[[
   local _pos = cc.p(self:getPosition())
   local function playVoice()
         local _rect = cc.rect(_pos.x - 100, _pos.y - 500, 200, 1000)
         if cc.rectContainsPoint(_rect, _thePos) then
            if not self.hasPlaySound then
              self:playSound()
              self.hasPlaySound = true
            end
         else
            self.hasPlaySound = false
         end
   end
   local function showDialog()
       local _rect = cc.rect(_pos.x - 50, _pos.y - 50, 100, 100)
       if cc.rectContainsPoint(_rect, _thePos) then
          if not self.hasShowDialog then
             local function xxx()
                 openWindow(self.mWindowKey)
             end
             nextTick(xxx)
             self.hasShowDialog = true
             FightSystem.mTouchPad:setCancelledTouch()
          end
       else
          self.hasShowDialog = false
       end
   end
   playVoice()
   showDialog()
   ]]
end

-- 触摸回调
function HallNPC:OnTouchEvent(_tr, _pushorrelease)
    if _pushorrelease == 1 then
      -- 按下
      if FightSystem.mTouchPad.mBeganFlag then
          self.TouchFlag = true
      end
    elseif _pushorrelease == 2 then
      -- 抬起
      if self.TouchFlag then 
        self.TouchFlag = false 
        return 
      end
      FightSystem.mTouchPad:setCancelledTouch()
      self:openWindow()
    end
end