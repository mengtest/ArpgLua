-- Name: FightTouchPad2
-- Func: 战斗触摸板2
-- Author: Johny


FightTouchPad2 = class("FightTouchPad2",function()
  return cc.Node:create()
end)

----------------------------------------------@控制板配置表-------------------------------------------------------------
--[[
  操控板的指令
]]

-- 0:UNKNOWN  1:方向  2:按钮
FightTouchPad2.TYPE = {UNKNOWN = 0, DR = 1, BTN = 2}


-- 9：按钮1  10：按钮2  11：按钮3  12：按钮4  13：按钮5
FightTouchPad2.BTN_CMD = {STOP = 0, BTN1 = 1, BTN2 = 2, BTN3 = 3, BTN4 = 4, BTN5 = 5,BTN6 = 6}

-- 双击事件记录
clicked = false

-- 方向杆底座半径
_DIRECTION_PAD_R_  =  50
------------------------------------------------------------------------------------------------------------------------


require("FightSystem/Fuben/WidgetProgressBar")
require("FightSystem/Fuben/WidgetProgressBarMonster")
require("FightSystem/Fuben/WidgetProgressBarBoss")
require("FightSystem/Fuben/WidgetCombotop")
require("FightSystem/Pad/TimeLabel")
require "GUISystem/Widget/OlPvpLoadPanel"

function FightTouchPad2:ctor()
  self.mTouchRegion = cc.rect(0, 0, getGoldFightPosition_Middle().x, getGoldFightPosition_Middle().y)
	self.mBtns = {}
  self.mHolder = nil
  --
  self.mRootWidget = nil     --FightUI
  self.mWidgetPadnode = nil  
  self.mWidgetPadMovenode = nil
  self.mPadnode = nil
  self.mPadMovenode = nil
  self.mIsAttackBtnDown = false --循环攻击按钮按下
  self.mPressintervalTime = 0   
  self.mNormalSkill_ID = 0
  self.mNormalSkill_Index = 0
  self.mCallNormalSkill_ID = 0
  self.mDownTime = 0
  self.mUpTime = 0
  self.mEndNum = 0
  self.mCurclick = "none"
  self.mHeadBtnList = nil
  --敌方血条
  self.mEnemyBtnList = nil
  self.mLastHeadTag = nil
  self._kb = nil
  self.progressblood = nil
  self.mBossBar = nil
  self.mCombotop = nil
  self.mCurDirection = 0
  self.mCurDeg = 0
  self.mDisabled = false
  -- 是否正在控制移动
  self.mIsControlMoving = false

  --跳按钮状态
  self.mJumpState = "jump"
  --boss是否出现
  -- 技能展示id
  self.mBeforeSkillId = nil

  self.mBeforeHandler = nil
  --临时变量
  self.mBaoxiangCount = 0
  self.mJinbiCount = 0

  --集气能量
  self.mEnergyCount = 0
  --当前hero ID
  self.mHeroIndex = 0

  self.mScheduler_FlashHead = {}
  -- 自动打断AI计时
  self.mAutoBreakTime = nil
  -- 引用计数
  self.SkillReferenceCount = 0
  self.AttackReferenceCount = 0
  self.MoveReferenceCount = 0
  self.mTypeName = "fighttouch"
end

function FightTouchPad2:Destroy()
  cclog("FightTouchPad2:Destroy")

  -- 解注册所有闪红头像计时器
   for k,_scheduler in pairs(self.mScheduler_FlashHead) do
      G_unSchedule(_scheduler)
   end
   self.mScheduler_FlashHead = nil
   -- 解注册更新ping状态
   GUIEventManager:unregisterAllHandler("updatePingStatus")
   -------
  self.mTouchRegion = nil
  self.mBtns = nil
  self.mRootWidget = nil

  self.mWidgetPadnode = nil
  self.mWidgetPadMovenode = nil
  self.mPadnode = nil
  self.mPadMovenode = nil

  self.mIsAttackBtnDown = nil
  self.mPressintervalTime =nil
  self.mNormalSkill_ID = nil
  self.mNormalSkill_Index =nil
  self.mCallNormalSkill_ID = nil
  self.mDownTime = nil
  self.mEndNum = nil
  self.mCurclick = nil
  self.mHeadBtnList = nil
  self.mLastHeadTag = nil
  self._kb = nil 
  self.mBaoxiangCount = nil
  self.mJinbiCount = nil
  self.mEnergyCount = nil
  self.mAutoTouchAttack = nil
  self.mAutoBreakTime = nil
  self.mAttackTime = nil
  self:removeFromParent()

  TextureSystem:unloadPlist_iconskill()
  TextureSystem:UnLoadPlist("res/image/fight/fight.plist")
  -- TextureSystem:unloadPlist_iconherokof()

end


function FightTouchPad2:onEnter()
   cclog("=====FightTouchPad2:onEnter=====")
    -- 键盘，仅在PC上有效果
    local KB = require "FightSystem/Pad/PCKeyBoard"
    self._kb = KB.new("pve")
    self._kb:Init()
    self:addChild(self._kb)
    ---
end

function FightTouchPad2:onExit()
   cclog("=====FightTouchPad2:onExit=====")
   self:removeAllChildren()
end

function FightTouchPad2:RegisterNodeEvent()
    -- rigister OnEnter and OnExit
  local function onNodeEvent(event)
      if "enter" == event then
          self:onEnter()
      elseif "exit" == event then
          self:onExit()
      end
  end

  self:registerScriptHandler(onNodeEvent)
end



function FightTouchPad2:Init(zorder, holder,time)
	cclog("=====FightTouchPad2:Init=====1")
  TextureSystem:loadPlist_iconskill()
  TextureSystem:LoadPlist("res/image/fight/fight.plist")
  -- TextureSystem:loadPlist_iconherokof()
  self:InitWidget()
  --
  self:setLocalZOrder(zorder)
  --
  self.mHolder = holder

  -- 自动
  self.mAutoTouchAttack = false
  -- 计时间
  self.mAttackTime = 0
  local _count = globaldata:getBattleFormationCount()
  if FightSystem.mFightType == "fuben" then
       self.mHolder.mSkillCon:SetFinishSkillCallBackHandler("FightTouchPad2", handler(self, self.OnSkillFinish))
       self.mSubstitutionCount = FightSystem:GetFightManager().mSubstitutionCount
       self.mCountPlayer = FightSystem:GetFightManager().ShowHeadCount
  elseif FightSystem.mFightType == "arena" then
        if globaldata.PvpType == "brave" then
            self.mHolder.mSkillCon:SetFinishSkillCallBackHandler("FightTouchPad2", handler(self, self.OnSkillFinish))
            -- self.mSubstitutionCount = FightSystem:GetFightManager().mSubstitutionCount
            -- self.mSubstitutionEnemyCount = FightSystem:GetFightManager().mSubstitutionEnemyCount
            self.mHolder.mAI:setOpenAI(false)
            self.mCountPlayer = globaldata:getBattleFormationCount()
        elseif globaldata.PvpType == "pk" then
            self.mSubstitutionCount = FightSystem:GetFightManager().mSubstitutionCount
            self.mSubstitutionEnemyCount = FightSystem:GetFightManager().mSubstitutionEnemyCount
            self.mCountPlayer = globaldata:getBattleFormationCount()
        elseif globaldata.PvpType == "arena" then
            self.mCountPlayer = globaldata:getBattleFormationCount()
            self.mHolder = FightSystem.mRoleManager:getRole("friend",1)
            self.mHolder.mAI:setOpenAI(false)
            self.mHolder.mSkillCon:SetFinishSkillCallBackHandler("FightTouchPad2", handler(self, self.OnSkillFinish))
            -- self.mLD_Node:setVisible(true)
            -- self.mLU_Node:setVisible(true)
            -- self.mRU_Node:setVisible(true)
            -- self.mRD_Node:setVisible(true)
        elseif globaldata.PvpType == "boss" then
            self.mHolder.mSkillCon:SetFinishSkillCallBackHandler("FightTouchPad2", handler(self, self.OnSkillFinish))
            self.mCountPlayer = globaldata:getBattleFormationCount()
        end
  elseif FightSystem.mFightType == "olpvp" then
        self.mHolder.mSkillCon:SetFinishSkillCallBackHandler("FightTouchPad2", handler(self, self.OnSkillFinish))
        self.mSubstitutionCount = FightSystem:GetFightManager().mSubstitutionCount
        self.mSubstitutionEnemyCount = FightSystem:GetFightManager().mSubstitutionEnemyCount
        self.mCountPlayer = globaldata:getBattleFormationCount()
  end

  
  if FightSystem.mFightType == "fuben" and globaldata.PvpType == "fuben" and FightSystem:GetFightManager().mIsFightGuide then
    
  else
    if FightSystem:isEnabledAdvancedJoystick() then
      self:InitLeftPad_MOVE()
    else
      self:InitLeftPad_FIX()
    end
  end

  if self:IsKofVision() then
      self:InitKofFriendHead()
  elseif self:IsArenaVision() then
    self:InitPvpBtns()
    self:InitPlayerHead(self.mCountPlayer)
  else
    self:InitPlayerHead(self.mCountPlayer)
  end
	self:InitBtns()
  self:UpdateFitSkill()
  self:UpdateSkillBtn()
  self:UpdateJumpBtn()

  self:InitTime(time)
  self:InitPingStatus()
  self:RegisterNodeEvent()
  self.mResultTick = true

	cclog("====FightTouchPad2:Init=====2")
end

function FightTouchPad2:IsKofVision()
    if FightSystem.mFightType == "olpvp" then
      return true
    else
      return FightSystem:GetModelByType(4)
    end
end

function FightTouchPad2:IsArenaVision()
    if FightSystem.mFightType == "arena" and (globaldata.PvpType == "arena" or globaldata.PvpType == "brave") then
      return true
    else
      return false
    end
end

function FightTouchPad2:Tick(delta)
    if not self.mResultTick then return end
    if not self.mHolder then return end
    self.mAttackTime = self.mAttackTime + delta
    self:TickAutoTime(delta)
    self:UpdateShoot(delta)
    self:UpdateMp(delta)
    self:UpdateArenaMp(delta)
    self:UpdateSkillCoolDowm(delta)
    self:UpdateJumpBtn(delta)
    if self.mIsAttackBtnDown then
       self:XunhuanGongji(delta)
    end
    self:ShowMemory()
end

function FightTouchPad2:ShowMemory()
  if FightConfig.__DEBUG_MEMORY_ then
    self.mLD_Node:getChildByName("Label_memory"):setVisible(true)
    local count = string.format("%f==%f",EngineSystem.mCppAgent:getUsedMemory(),EngineSystem.mCppAgent:getAvailabeMemory())
    self.mLD_Node:getChildByName("Label_memory"):setString(count)
  end
end

function FightTouchPad2:TickAutoTime(delta)
    if not self.mAutoBreakTime then return end
    self.mAutoBreakTime = self.mAutoBreakTime - delta
    if self.mAutoBreakTime <= 0 then
      if self.mAutoTouchAttack and not self.mHolder.mAI.mOpenAI then
        self.mHolder.mAI:setOpenAI(true)
        self:ResetAttack()
      end
      self.mAutoBreakTime = nil
    end
end

function FightTouchPad2:SetTime(num)
    if self:IsKofVision() then
      self.mLabeltime:setString(tostring(num))
    else
      local secend =  num%60
      local min = math.floor(num/60)
      local  time = string.format("%02d:%02d",min,secend)
      self.mLabeltime:setString(time)
    end
end

-- 上传进入下一个副本提醒
function FightTouchPad2:ShowgoNext()
      local go = self.mRootWidget:getChildByName("Rightup_Node"):getChildByName("Image_go")
      local function doFinishBlink(  )
          go:setVisible(false)
      end
      go:stopAllActions()
      local action1 = cc.Blink:create(3, 3)
      local call = cc.CallFunc:create(doFinishBlink)
      go:runAction(cc.Sequence:create(action1,call))
end

function FightTouchPad2:OnSkillFinish(skillID)
    --cclog("FightTouchPad2:OnSkillFinish == skillID ===" ..skillID .."=====self.mHolder.mRoleData.mRole_DodgeSkill==" ..self.mHolder.mRoleData.mRole_DodgeSkill)
    if not self.mHolder then return end 
    if self.mHolder.mAI.mOpenAI then return end 
    if self.mHolder.mRoleData.mRole_DodgeSkill == skillID then
    else
        self.mCallNormalSkill_ID = skillID
        local flag = false
          for i=1,5 do
            local key = string.format("mRole_NormalSkill%d",i)
            if self.mHolder.mSkillCon:IsSkillInStack(self.mHolder.mRoleData[key]) then
              flag = true
              break
            end
          end
          if not flag then
            for i=1,5 do
              local key = string.format("mRole_NormalSkill%d",i)
              if self.mHolder.mRoleData[key] == self.mCallNormalSkill_ID then
                flag = true
                break
              end
            end
          end
          if not flag then
            self:ResetAttack()
          end
        if self.mIsAttackBtnDown then
             self:XunhuanGongji()
        end
    end  
end  

-- 给符合条件的第一个touch 标记为1
-- 之后判断仅标记为1的touch才给予行动
function FightTouchPad2:InitLeftPad_MOVE()
  local x = self.mWidgetPadnode:getPositionX()
  local y = self.mWidgetPadnode:getPositionY()
  self.mTouchFristPoint = cc.p(x+getGoldFightPosition_LD().x,y+getGoldFightPosition_LD().y)
  local function onTouchBegan(touch, event)
      if self.mIsControlMoving then return false end
      if self.mCancelledFlag then return false end
      if not self.mHolder or self.mDisabled then return false end
      local curLoc = touch:getLocation()

      if FightConfig.__DEBUG_TOUCH_BEGAN_POINT_ then
        local deltaPos = FightSystem:getCurrentViewOffset()
        local pos = cc.p(curLoc.x  - deltaPos.x, curLoc.y - deltaPos.y)
        doError(string.format("POSX==%f,POSY==%f",pos.x,pos.y))
      return end

      if cc.rectContainsPoint(self.mTouchRegion, curLoc) then
            touch.identifier = 1
            self:MoveStart(curLoc)
       return true end
  end

  local function onTouchMoved(touch, event)
      -- 判断该触摸是否为有效触摸点
      if self.mCancelledFlag then return end
      if touch.identifier ~= 1 then return end
      --
      if not self.mHolder then return end
      local curLoc = touch:getLocation()
      self.mTouchMovePoint = curLoc
      --
      self:Movecontroller(curLoc)
  end

  local function onTouchEnded(touch, event)
      cclog("=====onTouchEnded=====")
      if self.mCancelledFlag then return end
      if not self.mHolder then return end
      if touch.identifier == 1 then
        touch.identifier = nil
        self:MoveEnd()
        self:setCurDirection(FightConfig.DIRECTION_CMD.STOP, 0)
        self:stopMove()
        self.mTouchFristPoint = nil
        self.mTouchMovePoint = nil
      end
  end

  local function onTouchCancelled(touch, event)
      cclog("=====onTouchCancelled======")
      if self.mCancelledFlag then return end
      if not self.mHolder then return end
      if touch.identifier == 1 then
        touch.identifier = nil
        self:MoveEnd()
        self:stopMove()
        self.mEndNum = self.mEndNum + 1
        self.mTouchFristPoint = nil
        self.mTouchMovePoint = nil
      end
  end
  --#####
    local eventDispatcher = self:getEventDispatcher()

    if self.ListenerFix then
        eventDispatcher:removeEventListener(self.ListenerFix)
        self.ListenerFix = nil
    end
    if self.ListenerMove then
        eventDispatcher:removeEventListener(self.ListenerMove)
        self.ListenerMove = nil
    end

  	-- register touch event
  	self.ListenerMove = cc.EventListenerTouchOneByOne:create()
    --listener:setSwallowTouches(true)
    self.ListenerMove:registerScriptHandler(onTouchBegan,cc.Handler.EVENT_TOUCH_BEGAN )
    self.ListenerMove:registerScriptHandler(onTouchMoved,cc.Handler.EVENT_TOUCH_MOVED )
    self.ListenerMove:registerScriptHandler(onTouchEnded,cc.Handler.EVENT_TOUCH_ENDED )
    self.ListenerMove:registerScriptHandler(onTouchCancelled,cc.Handler.EVENT_TOUCH_CANCELLED )
    eventDispatcher:addEventListenerWithSceneGraphPriority(self.ListenerMove, self)
end

-- 给符合条件的第一个touch 标记为1
-- 之后判断仅标记为1的touch才给予行动
function FightTouchPad2:InitLeftPad_FIX()
  --####Var
  local mVarDirChange = 0
  local mVarLastDir = -1
  local mHandlerRun = nil
  local x = self.mWidgetPadnode:getPositionX()
  local y = self.mWidgetPadnode:getPositionY()
  self.mTouchFristPoint = cc.p(x+getGoldFightPosition_LD().x,y+getGoldFightPosition_LD().y)
  --####function

  --  检测是否达到有效变化距离
  -- #与上一次方向不同，直接重置
  -- #不然则计算是否移动了有效距离 
  -- #记录的方向永远与本次方向一致
  -- local function CanTouchMoved(_curPos, _prePos, _dir)
  --     if mVarLastDir ~= _dir then
  --        mVarDirChange = 0
  --        mVarLastDir = _dir
  --     else
  --        local _dis = cc.pGetDistance(_curPos, _prePos)
  --        mVarDirChange = mVarDirChange + _dis
  --        mVarLastDir = _dir
  --        return mVarDirChange >= FightTouchPad2.EFFECT_CHANGE_DIR
  --     end
  -- end

  -- 通知宿主行动
  local function MoveHolder(_dir, _deg)
      if self.mLastDeg == _deg then
      return end
      --
      self.mLastDir = _dir
      self.mLastDeg = _deg
      mVarDirChange = 0
      mVarLastDir = -1

      if self.mHolder then
        self.mHolder:OnFTCommand(_dir, _deg)
      end

  end

  local function onTouchMoved(touch, event)
      local curLoc = touch:getLocation()
      -- self.mTouchEffect:setPosition(curLoc)

      -- 判断该触摸是否为有效触摸点
      if self.mCancelledFlag then return end
      if touch.identifier ~= 1 then return end
      local _deg = MathExt.GetDegreeWithTwoPoint(curLoc, self.mTouchFristPoint)
      local _dir = FightConfig.GetDirectionByDegree(_deg)
      self:setCurDirection_Fix(_dir, _deg)
      MoveHolder(_dir, _deg)
      --
      self.mTouchMovePoint = curLoc
      self:Movecontroller_Fix(curLoc)
  end

    local function onTouchBegan(touch, event)
          local curLoc = touch:getLocation()
          if self.mCancelledFlag then return false end
          if not self.mTouchRegion then return false end
          if cc.rectContainsPoint(self.mTouchRegion, curLoc) then
              --cclog("POSX==" .. curLoc.x .. "POSY==" .. curLoc.y)
              self.mBeganFlag = true
              self.mCancelledFlag = false
              touch.identifier = 1
              mVarDirChange = 0
              mVarLastDir = -1
              self:MoveStart_Fix(curLoc) 
              onTouchMoved(touch, event)
          end
          return true
    end

  local function onTouchEnded(touch, event)
      -- self.mTouchEffect:removeFromParent()
      if self.mCancelledFlag then return end
      if touch.identifier == 1 then
          self.mTouchMovePoint = nil
          self.mBeganFlag = false
          touch.identifier = nil
          self.mLastDeg = nil
          self:MoveEnd_Fix()
          self:stopMove()
          self:setCurDirection_Fix(FightConfig.DIRECTION_CMD.STOP, 0)
      end
  end

  local function onTouchCancelled(touch, event)
      cclog("=====onTouchCancelled======")
      if self.mCancelledFlag then return end
      if touch.identifier == 1 then
        self.mTouchMovePoint = nil
        self.mBeganFlag = false
        touch.identifier = nil
        self.mLastDeg = nil
        self:MoveEnd_Fix()
        self:stopMove()
      end
  end
  --#####
    local eventDispatcher = self:getEventDispatcher()

    if self.ListenerFix then 
        eventDispatcher:removeEventListener(self.ListenerFix)
        self.ListenerFix = nil
    end
    if self.ListenerMove then
        eventDispatcher:removeEventListener(self.ListenerMove)
        self.ListenerMove = nil
    end
  --
  -- register touch event
    self.ListenerFix = cc.EventListenerTouchOneByOne:create()
    --listener:setSwallowTouches(false)
    self.ListenerFix:registerScriptHandler(onTouchBegan,cc.Handler.EVENT_TOUCH_BEGAN )
    self.ListenerFix:registerScriptHandler(onTouchMoved,cc.Handler.EVENT_TOUCH_MOVED )
    self.ListenerFix:registerScriptHandler(onTouchEnded,cc.Handler.EVENT_TOUCH_ENDED )
    self.ListenerFix:registerScriptHandler(onTouchCancelled,cc.Handler.EVENT_TOUCH_CANCELLED )
    eventDispatcher:addEventListenerWithSceneGraphPriority(self.ListenerFix, self)
end

function FightTouchPad2:MoveStart_Fix(pos)
  self.mAutoBreakTime = nil
  if self.mAutoTouchAttack and self.mHolder.mAI.mOpenAI then
   self.mHolder.mAI:setOpenAI(false)
   self:ResetAttack()
  end
 -- self.mPadnode:setVisible(true)
  self.mPadMovenode:setVisible(true)
  --self.mPadnode:setPosition(pos)
  self.mPadMovenode:setPosition(pos)
  
  --self.mWidgetPadnode:setVisible(false)
  self.mWidgetPadMovenode:setVisible(false)
end

function FightTouchPad2:Movecontroller_Fix(pos)

    local _PadPos = cc.p(self.mWidgetPadnode:getPosition())
    _PadPos.x = _PadPos.x + getGoldFightPosition_LD().x
    _PadPos.y = _PadPos.y + getGoldFightPosition_LD().y
    --_PadPos.x = _PadPos.x + self.mWidgetPadnode:getBoundingBox().width/2
    local _dis = cc.pGetDistance(pos, _PadPos)
    local _deg = MathExt.GetDegreeWithTwoPoint(pos, _PadPos)
    if _dis > _DIRECTION_PAD_R_ + 30 then
       _PadPos.x = _PadPos.x + (_DIRECTION_PAD_R_+ 30)*math.cos(math.rad(_deg))
       _PadPos.y = _PadPos.y + (_DIRECTION_PAD_R_+ 30)*math.sin(math.rad(_deg))
       self.mPadMovenode:setPosition(_PadPos)
    else
       self.mPadMovenode:setPosition(pos)
    end
end

function FightTouchPad2:MoveEnd_Fix()
  self.mAutoBreakTime = 1
  --self.mPadnode:setVisible(false)
  self.mPadMovenode:setVisible(false)
  --self.mWidgetPadnode:setVisible(true)
  self.mWidgetPadMovenode:setVisible(true)
end

function FightTouchPad2:setCurDirection_Fix(_dir, _deg)
    self.mCurDirection = _dir
    self.mCurDeg = _deg
end




function  FightTouchPad2:InitWidget()
  self.mRootWidget = GUIWidgetPool:createWidget("Fight")
  self:addChild(self.mRootWidget,100)

  self.mWidgetPadnode = self.mRootWidget:getChildByName("Image_Movetouch_pad")
  self.mPadnode = self.mWidgetPadnode:clone()
  self:addChild(self.mPadnode,100)
  self.mPadnode:setVisible(false)
  self.mWidgetPadnode:setVisible(true)



  self.mWidgetPadMovenode = self.mRootWidget:getChildByName("Image_Movetouch_node")
  self.mPadMovenode = self.mWidgetPadMovenode:clone()
  self:addChild(self.mPadMovenode,101)
  self.mPadMovenode:setVisible(false)
  self.mWidgetPadMovenode:setVisible(true)

   local x = self.mWidgetPadnode:getPositionX()
    local y = self.mWidgetPadnode:getPositionY()
    self.mTouchFristPoint = cc.p(x+getGoldFightPosition_LD().x,y+getGoldFightPosition_LD().y)


  self.mLD_Node = self.mRootWidget:getChildByName("Leftdown_Node")
  self.mLU_Node = self.mRootWidget:getChildByName("Leftup_Node")
  self.mRU_Node = self.mRootWidget:getChildByName("Rightup_Node")
  self.mRD_Node = self.mRootWidget:getChildByName("Rightdown_Node")
  self.mMU_Node = self.mRootWidget:getChildByName("Middleup_Node")
  self.mMD_Node = self.mRootWidget:getChildByName("Middledown_Node")

    self.mLD_Node:setPosition(getGoldFightPosition_LD())
    self.mLU_Node:setPosition(getGoldFightPosition_LU())
    self.mRU_Node:setPosition(getGoldFightPosition_RU())
    self.mRD_Node:setPosition(getGoldFightPosition_RD())
    self.mMU_Node:setPosition(cc.p(getGoldFightPosition_Middle().x,getGoldFightPosition_LU().y))
    self.mMD_Node:setPosition(cc.p(getGoldFightPosition_Middle().x,getGoldFightPosition_LD().y))


  local function selectedEvent(sender,eventType)
      if eventType == ccui.CheckBoxEventType.selected then
            self:DetectGuide2_1Step()
            FightSystem.mRoleManager:FriendAiActivatRemove()
            if self.mHolder then
              self.mHolder.mAI:setOpenAI(true)
            end
            self.mAutoTouchAttack = true
            self:ResetAttack()
            for k,role in pairs(FightSystem.mRoleManager:GetFriendTable()) do
              if not role.IsKeyRole and role.mGroup == "friend" and not role.mAI.mOpenAI then
                role.mAI:setOpenAI(true)
              end
            end
            self:setAutoSaveFightType(true)
      elseif eventType == ccui.CheckBoxEventType.unselected then
            if self.mHolder then
              self.mHolder.mAI:setOpenAI(false)
            end
            self.mAutoTouchAttack = false
            self:ResetAttack()
            self:setAutoSaveFightType(false)
      end
  end 
  self.mCheckBoxBtn = self.mRootWidget:getChildByName("CheckBox_Auto")
  self.mCheckBoxBtn:addEventListener(selectedEvent)

  local function selectedWeaponEvent( sender,eventType )
      if eventType == ccui.CheckBoxEventType.selected then
          if not self.mHolder then return end
          if self.mAutoTouchAttack then
            self:setCheckWeapon(false)
            return
          end
          if self.mHolder.mFSM:IsIdle() or self.mHolder.mFSM:IsRuning() then
          else
            if self.mHolder:isEquipGun() then
              self:setCheckWeapon(true)
            else
              self:setCheckWeapon(false)
            end
             return
          end
          if FightSystem.mRoleManager.mFriendBulletCount and FightSystem.mRoleManager.mFriendBulletCount <= 0 then
            self:setCheckWeapon(false)
            return
          end
          self.mHolder.mPickupCon:leavePickup()
          self.mHolder.mSkillCon:FinishCurSkill()
          self.mHolder.mGunCon:FightEquipedGun()
      elseif eventType == ccui.CheckBoxEventType.unselected then
         if not self.mHolder then return end
          if self.mAutoTouchAttack then
            self:setCheckWeapon(false)
            return
          end
          if self.mHolder.mFSM:IsIdle() or self.mHolder.mFSM:IsRuning() then   
          else
              if self.mHolder:isEquipGun() then
                self:setCheckWeapon(true)
              else
                self:setCheckWeapon(false)
              end
             return
          end
          if FightSystem.mRoleManager.mFriendBulletCount and FightSystem.mRoleManager.mFriendBulletCount <= 0 then
            self:setCheckWeapon(false)
            return
          end
          self.mHolder.mGunCon:FightUnloadGun()
      end
  end
  self.mCheckWeaponBtn = self.mRootWidget:getChildByName("CheckBox_Weapon")
  self.mCheckWeaponBtn:addEventListener(selectedWeaponEvent)
  if FightSystem.mFightType == "fuben" and globaldata.PvpType == "fuben" then
    self.mRootWidget:getChildByName("CheckBox_Weapon"):setVisible(true)
  else
    self.mRootWidget:getChildByName("CheckBox_Weapon"):setVisible(false)
  end
  

end

function FightTouchPad2:setAutoSaveFightType(state)
  if globaldata.PvpType == "brave" then
    FightSystem:enableChuangGuanAuto(state)
  elseif globaldata.PvpType == "boss" then
    FightSystem:enableBossAuto(state)
  elseif globaldata.PvpType == "arena" then
    FightSystem:enableWudaoguanAuto(state)
  elseif globaldata.PvpType == "blackMarket" then
    FightSystem:enableHeishiAuto(state)
  elseif globaldata.PvpType == "wealth" then
    FightSystem:enableFangkeAuto(state)
  elseif globaldata.PvpType == "tower" then
    FightSystem:enablePataAuto(state)
  elseif globaldata.PvpType == "fuben" then
   if globaldata:isSectionVisited(1,2,1) then
    FightSystem:enableFubenAuto(state)
   end
  end
end

function FightTouchPad2:setCheckAuto(_state)
  self.mCheckBoxBtn:setSelectedState(_state)
  FightSystem.mRoleManager:FriendAiActivatRemove()
  if self.mHolder then
    self.mHolder.mAI:setOpenAI(true)
  end
  self.mAutoTouchAttack = true
  self:ResetAttack()
  for k,role in pairs(FightSystem.mRoleManager:GetFriendTable()) do
    if not role.IsKeyRole and role.mGroup == "friend" and not role.mAI.mOpenAI then
      role.mAI:setOpenAI(true)
    end
  end
end

function FightTouchPad2:setCheckWeapon(_state)
  self.mCheckWeaponBtn = self.mRootWidget:getChildByName("CheckBox_Weapon")
  self.mCheckWeaponBtn:setSelectedState(_state)
end

function FightTouchPad2:setTouchEnabelCheckWeapon(_state)
  self.mCheckWeaponBtn:setTouchEnabled(_state)
  self.mCheckBoxBtn:setTouchEnabled(_state)
end

--
function FightTouchPad2:setPassText(_str)
end

function FightTouchPad2:Showbeforeskill()
  --[[
    if self.mBeforeHandler then
         G_unSchedule(self.mBeforeHandler)
         self.mBeforeHandler = nil
    end
    if not self.mHolder then return end
    self.mHolder:showSkillRangeByID(self.mBeforeSkillId)
    ]]
end

function FightTouchPad2:OnClick_SkillEvent(widget, eventType)
   --cclog("=====FightTouchPad2:OnClick_SkillEvent=====touch: " .. widget:getTag())
   if self.mDisabled then return end
    if not self.mHolder then return end

    if eventType == ccui.TouchEventType.began then
      --[[
        if self.mBeforeHandler then
             G_unSchedule(self.mBeforeHandler)
             self.mBeforeHandler = nil
        end
        if widget:getTag() == FightTouchPad2.BTN_CMD.BTN1 then
          self.mBeforeSkillId = self.mHolder.mRoleData.mRole_SpecialSkill1
        elseif widget:getTag() == FightTouchPad2.BTN_CMD.BTN2 then
          self.mBeforeSkillId = self.mHolder.mRoleData.mRole_SpecialSkill2
        elseif widget:getTag() == FightTouchPad2.BTN_CMD.BTN3 then
          self.mBeforeSkillId = self.mHolder.mRoleData.mRole_SpecialSkill3
        end
        local scheduler = cc.Director:getInstance():getScheduler()
        self.mBeforeHandler = scheduler:scheduleScriptFunc(handler(self,self.Showbeforeskill), 0.25, false)
        ]]
         self.mHolder.mSkillCon:cancelSkillRange()
      -- if self.mBeforeHandler then
      --      G_unSchedule(self.mBeforeHandler)
      --      self.mBeforeHandler = nil
      -- end
      --self:GongjiChangeFace()
      if widget:getTag() == FightTouchPad2.BTN_CMD.BTN1 then
         self.mHolder.mPickupCon:leavePickup()
         self.mHolder:playSpecialSkill1()
      elseif widget:getTag() == FightTouchPad2.BTN_CMD.BTN2 then
         self.mHolder.mPickupCon:leavePickup()
          self.mHolder:playSpecialSkill2()
      elseif widget:getTag() == FightTouchPad2.BTN_CMD.BTN3 then
         self.mHolder.mPickupCon:leavePickup()
          self.mHolder:playSpecialSkill3()
      end  



    elseif eventType == ccui.TouchEventType.ended then
    --[[
      self.mHolder.mSkillCon:cancelSkillRange()
      if self.mBeforeHandler then
           G_unSchedule(self.mBeforeHandler)
           self.mBeforeHandler = nil
      end
      if widget:getTag() == FightTouchPad2.BTN_CMD.BTN1 then
         self.mHolder.mPickupCon:leavePickup()
         self.mHolder:playSpecialSkill1()
      elseif widget:getTag() == FightTouchPad2.BTN_CMD.BTN2 then
         self.mHolder.mPickupCon:leavePickup()
          self.mHolder:playSpecialSkill2()
      elseif widget:getTag() == FightTouchPad2.BTN_CMD.BTN3 then
         self.mHolder.mPickupCon:leavePickup()
          self.mHolder:playSpecialSkill3()
      end  
      ]]
    elseif eventType == ccui.TouchEventType.canceled then
      --[[
          if self.mBeforeHandler then
             G_unSchedule(self.mBeforeHandler)
             self.mBeforeHandler = nil
          end
          self.mHolder.mSkillCon:cancelSkillRange()
          ]]
    end       
end


function FightTouchPad2:OnClickEvent(tag,eventType)
  --cclog("=====FightTouchPad2:OnClickEvent=====touch: " .. tag:getTag())
    if self.mDisabled then return end
    if not self.mHolder then return end
    if self.mHolder.mSkillCon.isPlayCombineing then return end
    if eventType == ccui.TouchEventType.began then
        self.mAutoBreakTime = nil
        if self.mAutoTouchAttack and self.mHolder.mAI.mOpenAI then
          self.mHolder.mAI:setOpenAI(false)
          self:ResetAttack()
        end
        if self.mJumpState == "throw" then
          self.mHolder.mSkillCon:showThrowSkillRange()
          return
        end
        if self.mJumpState == "jump" then
          --self.mHolder.mSkillCon:cancelSkillRange()
          --self.mHolder:PlayBlock()
          return
        end

    elseif eventType == ccui.TouchEventType.ended then
      self.mAutoBreakTime = 1
      self.mHolder.mSkillCon:cancelSkillRange()
      if not self.mHolder.mPickupCon:throwPickup() then
          if self.mJumpState == "jump" then
            self:DetectGuideStep6()
            if self.mHolder.mFSM:IsBeatingStiff() then
              self.mHolder:ForcePlayBlink(self.mLastDeg)
            else
              self.mHolder:PlayBlink()
            end
           --self.mHolder:StopBlock()
           self:ResetAttack()
          end
      end
    elseif eventType == ccui.TouchEventType.canceled then
      self.mAutoBreakTime = 1
      self.mHolder.mSkillCon:cancelSkillRange()
       if not self.mHolder.mPickupCon:throwPickup() then
          if self.mJumpState == "jump" then
            self:DetectGuideStep6()
            if self.mHolder.mFSM:IsBeatingStiff() then
              self.mHolder:ForcePlayBlink(self.mLastDeg)
            else
              self.mHolder:PlayBlink()
            end
           --self.mHolder:StopBlock()
           self:ResetAttack()
          end
      end
    end
end

function FightTouchPad2:DetectGuideStep6()
  --[[
  if FightSystem.mFightType == "fuben" and globaldata.PvpType == "fuben" then
    if FightSystem:GetFightManager().mDodgeCount and FightSystem:GetFightManager().mDodgeCount == 0 then
      FightSystem:GetFightManager().mDodgeCount = 1
      FightSystem:GetFightManager():GuideStep6()
    end
  end
  ]]
end
 

function FightTouchPad2:OnClickEvent_TimeOut(tag,sender)
    EventSystem:PushEvent(Event.GUISYSTEM_SHOW_FIGHTPAUSEWINDOW)
    GameApp:Pause()
end

function FightTouchPad2:OnClickEvent_KillAllMonster(tag,sender)
    FightSystem.mRoleManager:removeAllFlyEnemy()
end

function FightTouchPad2:OnClickEvent_Tongguan(tag,sender)
      FightSystem:GetFightManager():Result("success")
end

function FightTouchPad2:OnClickEvent_Shibai(tag,sender)
      FightSystem:GetFightManager():Result("fail")
end

function FightTouchPad2:OnFitClickEvent(tag,sender)
    cclog("OnFitClickEvent")
    if self.mDisabled then return end
    if not self.mHolder then return end
    self.mHolder.mPickupCon:leavePickup()
    -- self.mHolder.mSkillCon:playCombineSkill()
    local _cmd = string.format("pve_0_skill_combine")
    FCmdParseSystem.parseCommand(_cmd)
end

-- 普通攻击
function FightTouchPad2:normalSkill()
    -- 看是否有枪
    cclog("FightTouchPad2:OnClickAttack  1")
    if not self.mHolder then return end
    self.mIsAttackBtnDown = true
    self.mAutoBreakTime = nil
    if self.mAutoTouchAttack and self.mHolder.mAI.mOpenAI then
      self.mHolder.mAI:setOpenAI(false)
      self:ResetAttack()
    end

    if self.mHolder.mGunCon:playShootSkill() then 
      self.mNormalSkill_ID = self.mHolder.mGunCon.mBindSkill
      return 
    end
    --拾取屏蔽
    if not self.mHolder.mFSM:IsAttacking() and self.mHolder.mPickupCon:findPickup() then 
      return 
    end
    if self.mHolder.mPickupCon:playPickuping() then
      return
    end
    if self.mHolder.mPickupCon:playPickupSkill() then
        self.mNormalSkill_ID = self.mHolder.mPickupCon.mBind.mBindNormalAttack
        self.mCallNormalSkill_ID = 0
        return 
    end
    --
    if self.mDownTime == 0 then
      self.mDownTime = self.mAttackTime
      self.mNormalSkill_ID = 0
      self.mCallNormalSkill_ID = 0
      self.mNormalSkill_Index = 0
    else
        local DownTime = self.mAttackTime
        self.mDownTime = DownTime
        if DownTime - self.mUpTime  >= 1 then
          self:ResetAttack()
          self.mDownTime = DownTime
        end   
    end 
    self:XunhuanGongji()
end

function FightTouchPad2:normalSkillCancel()
   self.mIsAttackBtnDown = false
   self.mUpTime = self.mAttackTime
   self.mAutoBreakTime = 1
   -- if self.mHolder then
   --   if self.mHolder.mSkillCon.mCurSkill then
   --      self.mHolder.mSkillCon.mCurSkill:setCancelBtn()
   --   end
   -- end
end

function FightTouchPad2:OnClickAttack(widget, eventType)
  if not self.mHolder then return end

  if eventType == ccui.TouchEventType.began then
        -- 先尝试拾取道具
        self:normalSkill()
  elseif eventType == ccui.TouchEventType.ended then
        self:normalSkillCancel()
  elseif eventType == ccui.TouchEventType.canceled then
        self:normalSkillCancel() 
  end       
end

function FightTouchPad2:InitPvpBtns()
      local  killallmonsters = self.mRootWidget:getChildByName("Label_Miaoguai")
      registerWidgetReleaseUpEvent(killallmonsters,handler(self,self.OnClickEvent_KillAllMonster))

      local  tongguan = self.mRootWidget:getChildByName("Label_Tongguan")
      registerWidgetReleaseUpEvent(tongguan,handler(self,self.OnClickEvent_Tongguan))

      local  shibai = self.mRootWidget:getChildByName("Label_Lose")
      registerWidgetReleaseUpEvent(shibai,handler(self,self.OnClickEvent_Shibai))

      if not FightConfig.__DEBUG_FIGHT_GM_ then
          killallmonsters:setVisible(false)
          tongguan:setVisible(false)
          shibai:setVisible(false)
      else
          killallmonsters:setVisible(true)
          tongguan:setVisible(true)
          shibai:setVisible(true)
      end
end

function FightTouchPad2:InitBtns()
      if not self.mHolder then return end
      self.Button_skill_Table = {}
      self.Button_Image_Table = {}

      for i=1,3 do
        local btn = self.mRootWidget:getChildByName(string.format("Button_Skill_%d",i))
        local btn1 = self.mRootWidget:getChildByName(string.format("Image_Fight_Skill_BG%d",i))
        self.Button_skill_Table[i] = {}
        self.Button_skill_Table[i]["btn"] = btn
        self.Button_skill_Table[i]["Image"] = btn1
        self.Button_skill_Table[i]["Image_Circle"] = btn:getChildByName("Image_Circle")
        self:CreateCoolskill(btn,i)
        btn:setTag(i)
        btn:addTouchEventListener(handler(self,self.OnClick_SkillEvent))
      end


      local attbtn = self.mRootWidget:getChildByName("Button_Attack")
      attbtn:setTag(5)
      attbtn:addTouchEventListener(handler(self,self.OnClickAttack))

      self.mJumpbtn = self.mRootWidget:getChildByName("Button_Jump")
      self.mJumpbtn:setTag(6)
      self.mJumpbtn:addTouchEventListener(handler(self,self.OnClickEvent))
      -- 闪烁创建
      self:CreateCoolBlock(self.mJumpbtn,5)

      if FightSystem:GetModelByType(5) then
       --   self.mRootWidget:getChildByName("Button_Jump"):getChildByName("Image_Skill"):loadTexture("fight_jump1_btn.png")  --loadTextureNormal("fight_jump1_btn.png")
          --self.mRootWidget:getChildByName("Button_Jump"):loadTexturePressed("fight_jump1_btn.png")
      else
        if self.mHolder.mRoleData.mRole_DodgeSkill ~= 0 then
          local skillData = DB_SkillEssence.getDataById(self.mHolder.mRoleData.mRole_DodgeSkill)
          local skillIconId = skillData.IconID
          local skillIcon = DB_ResourceList.getDataById(skillIconId).Res_path1
          self.mRootWidget:getChildByName("Button_Jump"):getChildByName("Image_Skill"):loadTexture(skillIcon,1)   --("fight_jump_btn.png")
          --self.mRootWidget:getChildByName("Button_Jump"):loadTexturePressed("fight_jump_btn_2.png")
        else
          self.mRootWidget:getChildByName("Button_Jump"):setVisible(false)
        end
          
      end
      if self:IsKofVision() then
        local  timeoutbtn = self.KofMiddlewidget:getChildByName("Button_Pause")
        registerWidgetReleaseUpEvent(timeoutbtn,handler(self,self.OnClickEvent_TimeOut))
        self.mRootWidget:getChildByName("Button_Timeout"):setVisible(false)
      else
        local  timeoutbtn = self.mRootWidget:getChildByName("Button_Timeout")
        registerWidgetReleaseUpEvent(timeoutbtn,handler(self,self.OnClickEvent_TimeOut))
      end

      local  killallmonsters = self.mRootWidget:getChildByName("Label_Miaoguai")
      registerWidgetReleaseUpEvent(killallmonsters,handler(self,self.OnClickEvent_KillAllMonster))

      local  tongguan = self.mRootWidget:getChildByName("Label_Tongguan")
      registerWidgetReleaseUpEvent(tongguan,handler(self,self.OnClickEvent_Tongguan))

      local  shibai = self.mRootWidget:getChildByName("Label_Lose")
      registerWidgetReleaseUpEvent(shibai,handler(self,self.OnClickEvent_Shibai))

      if not FightConfig.__DEBUG_FIGHT_GM_ then
          killallmonsters:setVisible(false)
          tongguan:setVisible(false)
          shibai:setVisible(false)
      else
          killallmonsters:setVisible(true)
          tongguan:setVisible(true)
          shibai:setVisible(true)
      end

      local fit = self.mRootWidget:getChildByName("Button_Skill_4")
      local fit1 = self.mRootWidget:getChildByName("Image_Fight_Skill_BG4")
      self.Button_skill_Table[4] = {}
      self.Button_skill_Table[4]["btn"] = fit
      self.Button_skill_Table[4]["Image"] = fit1
      self.Button_skill_Table[4]["Image_Circle"] = fit:getChildByName("Image_Circle")

      registerWidgetReleaseUpEvent(fit,handler(self,self.OnFitClickEvent))
      self:CreateCoolskill(fit,4)

      self:hidePropertyBtn()
end

function FightTouchPad2:hidePropertyBtn()
    if FightSystem:GetModelByType(3) then
        self.Button_skill_Table[1]:setVisible(false)
        self.Button_skill_Table[2]:setVisible(false)
        self.Button_skill_Table[3]:setVisible(false)
    end
end


function FightTouchPad2:UpdateFitSkill()
    if not self.mHolder then return end
    if self:IsArenaVision() then return end
    if FightSystem.mFightType == "arena" and globaldata.PvpType == "brave" then
      local fit =  self.Button_skill_Table[4]["Image"]
      local fit1 = self.Button_skill_Table[4]["btn"]
      fit:setVisible(false)
      fit1:setVisible(false)
    else
      if self.mHolder.mSkillCon:IsCommonGSPartner() then
          local fit =  self.Button_skill_Table[4]["Image"]
          local fit1 = self.Button_skill_Table[4]["btn"]
        
          local skillData = DB_SkillEssence.getDataById(self.mHolder.mRoleData.mGSID1)
          local skillNameId = skillData.Name
          local skillName = getDictionaryText(skillNameId)
          local skillIconId = skillData.IconID
          local skillIcon = DB_ResourceList.getDataById(skillIconId).Res_path1
          local btn = self.Button_skill_Table[i]
          fit1:getChildByName("Image_Skill"):loadTexture(skillIcon,1)
          fit:setVisible(true)
          fit1:setVisible(true) 
      else
          local fit =  self.Button_skill_Table[4]["Image"]
          local fit1 = self.Button_skill_Table[4]["btn"]
          fit:setVisible(false)
          fit1:setVisible(false)
      end
    end
end

function FightTouchPad2:UpdateSkillBtn()
      if not self.mHolder then return end
      if FightSystem:GetModelByType(3) then return end
      for i=1,3 do
          local  skillindex =  string.format("mRole_SpecialSkill%d",i)
          local skillid = self.mHolder.mRoleData[skillindex]
          local btn = self.Button_skill_Table[i]["btn"]
          local btn_bg = self.Button_skill_Table[i]["Image"]
          if skillid ~= 0 and self.mHolder.mRoleData:IsSkillActivateById(skillid) then
                local skillData = DB_SkillEssence.getDataById(self.mHolder.mRoleData[skillindex])
                local skillNameId = skillData.Name
                local skillName = getDictionaryText(skillNameId)
                local skillIconId = skillData.IconID
                local skillIcon = DB_ResourceList.getDataById(skillIconId).Res_path1
                btn:getChildByName("Image_Skill"):setVisible(true)
                btn:getChildByName("Image_Skill"):loadTexture(skillIcon,1)
                btn:setVisible(true)
                btn:setEnabled(false)
                btn_bg:setVisible(true)
                self:ShowPowerPoints(0,0,i)
          else
                btn:setVisible(false)
                btn:setEnabled(false)
                btn_bg:setVisible(false)
                btn:getChildByName("Image_Skill"):setVisible(false)
                btn:getChildByName("Image_Circle"):setVisible(false)
                local pro = self.Button_skill_Table[i]["aniBar_100"]
                pro:setVisible(false)
                local time = self.Button_skill_Table[i]["lb_1000"]
                time:setVisible(false)
                --local time1 = self.Button_skill_Table[i]["lben_10000"]
                --time1:setVisible(false)
          end
      end
      self:UpdateBlinkBtn()
      
end

-- 更新闪烁按钮
function FightTouchPad2:UpdateBlinkBtn()

    local skillid = self.mHolder.mRoleData.mRole_DodgeSkill
    local btn = self.Button_skill_Table[5]["btn"]
    local btn_bg = self.Button_skill_Table[5]["Image"]
    if skillid ~= 0 and self.mHolder.mRoleData:IsSkillActivateById(skillid) then
        local skillData = DB_SkillEssence.getDataById(skillid)
        local skillIconId = skillData.IconID
        local skillIcon = DB_ResourceList.getDataById(skillIconId).Res_path1
        btn:getChildByName("Image_Skill"):loadTexture(skillIcon,1)
        btn:getChildByName("Image_Skill"):setVisible(true)
        btn:getChildByName("Image_Circle"):setVisible(true)
        btn:setVisible(true)
        btn:setEnabled(false)
        btn_bg:setVisible(true)
        self:ShowPowerPoints(0,0,5)
    else
        btn:setVisible(false)
        btn:setEnabled(false)
        btn_bg:setVisible(false)
        btn:getChildByName("Image_Skill"):setVisible(false)
        btn:getChildByName("Image_Circle"):setVisible(false)
        local pro = self.Button_skill_Table[5]["aniBar_100"]
        pro:setVisible(false)
        local time = self.Button_skill_Table[5]["lb_1000"]
        time:setVisible(false)
    end 
end

function FightTouchPad2:UpdateJumpBtn(delta)
    if not self.mHolder then return end
    if  self.mHolder.mHorse then
        if self.mJumpState ~= "download" then
         -- self.mRootWidget:getChildByName("Button_Jump"):loadTextureNormal("fight_download_btn.png")
         -- self.mRootWidget:getChildByName("Button_Jump"):loadTexturePressed("fight_download_btn.png")
         -- self.mJumpState = "download"
        end    
    elseif self.mHolder.mPickupCon.mBind then
        if self.mJumpState ~= "throw" then
  
          self.mJumpbtn:getChildByName("Image_Skill"):loadTexture("fight_throw_btn.png")
          --self.mRootWidget:getChildByName("Button_Jump"):loadTexturePressed("fight_throw_btn.png")
          self.mJumpState = "throw" 
          self:ShowPowerPoints(0,0,5)
          local btn = self.Button_skill_Table[5]["btn"]
          local btn_bg = self.Button_skill_Table[5]["Image"]
          btn_bg:setVisible(false)
          self.Button_skill_Table[5]["Image_Circle"]:setVisible(false)
          local pro = self.Button_skill_Table[5]["aniBar_100"]
          pro:setVisible(false)
          local time = self.Button_skill_Table[5]["lb_1000"]
          time:setVisible(false)
          btn:setEnabled(true)
          if self.mHolder.mRoleData.mRole_DodgeSkill == 0 then
             self.mJumpbtn:setVisible(true)
             self.mJumpbtn:getChildByName("Image_Skill"):setVisible(true)
          end
        end   
    else
        if self.mJumpState ~= "jump" then
          if self.mHolder.mRoleData.mRole_DodgeSkill ~= 0 then
            local skillData = DB_SkillEssence.getDataById(self.mHolder.mRoleData.mRole_DodgeSkill)
            local skillIconId = skillData.IconID
            local skillIcon = DB_ResourceList.getDataById(skillIconId).Res_path1
            self.mJumpbtn:getChildByName("Image_Skill"):loadTexture(skillIcon,1)
          end


          --self.mRootWidget:getChildByName("Button_Jump"):loadTexturePressed("fight_jump_btn_2.png")
          self.mJumpState = "jump"
          self:UpdateBlinkBtn()
        end
    end 
end

function FightTouchPad2:UpdatePlayerHead(_index)
   
end



function FightTouchPad2:InitPlayerHead(num)
    for i=1,num do
      self:AddHeroHead(i)
    end

    self.mHeadBtnList[1].btn:getChildByName("Panel_SelectAnimation"):setVisible(true)
    self.mLastHeadTag = 1
end

function FightTouchPad2:InitKofFriendHead()
    self:hideLeftupNode()

    local kof = GUIWidgetPool:createWidget("KOF")

    self.mRootWidget:addChild(kof,100)
    if FightSystem.mFightType == "olpvp" and globaldata.olHoldindex%2 == 0 then

        self.FriendkofBlood = kof:getChildByName("Panel_Right") 
        self.MonsterkofBlood = kof:getChildByName("Panel_Left")
        self.FriendkofBlood:getChildByName("Image_Bg_1"):setVisible(true)
        self.FriendkofBlood:getChildByName("Image_Bg"):setVisible(false)
        self.MonsterkofBlood:getChildByName("Image_Bg_1"):setVisible(true)
        self.MonsterkofBlood:getChildByName("Image_Bg"):setVisible(false)


        self.MonsterkofBlood:setPosition(cc.p(getGoldFightPosition_LU().x,getGoldFightPosition_LU().y - self.MonsterkofBlood:getBoundingBox().height ))
        local _width = self.FriendkofBlood:getBoundingBox().width 
        local _height = self.FriendkofBlood:getBoundingBox().height 
        self.FriendkofBlood:setPosition(cc.p(getGoldFightPosition_RU().x - _width,getGoldFightPosition_LU().y - _height))
    else
        self.FriendkofBlood = kof:getChildByName("Panel_Left") 
        self.MonsterkofBlood = kof:getChildByName("Panel_Right")

        self.FriendkofBlood:setPosition(cc.p(getGoldFightPosition_LU().x,getGoldFightPosition_LU().y - self.FriendkofBlood:getBoundingBox().height ))
        local _width = self.MonsterkofBlood:getBoundingBox().width 
        local _height = self.MonsterkofBlood:getBoundingBox().height 
        self.MonsterkofBlood:setPosition(cc.p(getGoldFightPosition_RU().x - _width,getGoldFightPosition_LU().y - _height))
    end
 
    self.KofMiddlewidget = kof:getChildByName("Panel_Middle") 
    self.KofMiddlewidget:setPositionY(getGoldFightPosition_RU().y -  self.KofMiddlewidget:getBoundingBox().height)
  
    self.FriendKofList = {}
    local _count = FightSystem:GetFightManager().mSubstitutionCount+1
    for i=1,_count do
      local heroid = globaldata:getBattleFormationInfoByIndexAndKey(i,"id")
      local _infoDB = DB_HeroConfig.getDataById(heroid)
      local Icons = {_infoDB.IconID ,_infoDB.IconID }
      if FightSystem.mFightType == "olpvp" and (globaldata.olpvpType == 1 or globaldata.olpvpType == 2 ) then
        local index = globaldata:convertOlindex(globaldata.olHoldindex)
        if index == i then
          table.insert(self.FriendKofList,1,Icons)
        else
          table.insert(self.FriendKofList,Icons)
        end
      else
       table.insert(self.FriendKofList,Icons)
      end
    end

    self.MonsterKofList = {}
    self:createKofBar()
    self:ShowTeamsCount("friend",1)

end

function FightTouchPad2:createSceneAniBlood()
    self.mRootWidget:getChildByName("Panel_FlagKeeping"):setVisible(true)
    local xuetiao = cc.Sprite:create()
    xuetiao:setProperty("Frame", "fight_flagblood_blood.png")
    local xiedu = 0.018
    local xiedu1 = 0.032
     --动画进度条 黑色条
    self.mSceneAniBar = cc.ProgressTimer:create(xuetiao)
    self.mSceneAniBar:setType(1)
    --self.mSceneAniBar:setSlopbarParam(4, xiedu)
    -- Setup for a bar starting from the bottom since the midpoint is 0 for the y
    self.mSceneAniBar:setMidpoint(cc.p(0,1))
    -- Setup for a vertical bar since the bar change rate is 0 for x meaning no horizontal change
    self.mSceneAniBar:setAnchorPoint(cc.p(0,0))
    self.mSceneAniBar:setBarChangeRate(cc.p(1, 0))
    local bg = self.mRootWidget:getChildByName("Panel_FlagKeeping"):getChildByName("Panel_Blood")
    bg:addChild(self.mSceneAniBar,1)
    self.mSceneAniBar:setPercentage(100)
    self.mSceneAniBar:setColor(getBloodColor(100))
end

function FightTouchPad2:createKofBar()
    if FightSystem.mFightType == "olpvp" then
      self.FriendkofBlood:getChildByName("Image_Energy_Bg"):setVisible(false)
      self.FriendkofBlood:getChildByName("Image_HeroBg_2"):getChildByName("Image_Energy_Bg"):setVisible(false)
      self.FriendkofBlood:getChildByName("Image_HeroBg_3"):getChildByName("Image_Energy_Bg"):setVisible(false)

      self.MonsterkofBlood:getChildByName("Image_Energy_Bg"):setVisible(false)
      self.MonsterkofBlood:getChildByName("Image_HeroBg_2"):getChildByName("Image_Energy_Bg"):setVisible(false)
      self.MonsterkofBlood:getChildByName("Image_HeroBg_3"):getChildByName("Image_Energy_Bg"):setVisible(false)
    end

    local xuetiao = cc.Sprite:create()
    xuetiao:setProperty("Frame", "fight_kof_blood.png")
    local nengliangtiao = cc.Sprite:create()
    nengliangtiao:setProperty("Frame", "fight_kof_energy.png")
    local xiedu = 0.029
    local xiedu1 = 0.032
     --动画进度条 黑色条
    self.KofFriendBar = cc.ProgressTimer:create(xuetiao)
    self.KofFriendBar:setType(2)
    self.KofFriendBar:setSlopbarParam(3, xiedu)
    -- Setup for a bar starting from the bottom since the midpoint is 0 for the y
    self.KofFriendBar:setMidpoint(cc.p(0,1))
    -- Setup for a vertical bar since the bar change rate is 0 for x meaning no horizontal change
    self.KofFriendBar:setAnchorPoint(cc.p(0.5,0.5))
    self.KofFriendBar:setBarChangeRate(cc.p(1, 0))
    local friendbg = self.FriendkofBlood:getChildByName("Image_Blood_Bg")
    self.KofFriendBar:setPosition(friendbg:getContentSize().width/2 ,friendbg:getContentSize().height/2)
    friendbg:addChild(self.KofFriendBar,1)
    self.KofFriendBar:setPercentage(100)

    local function doWidgetScale()
   
      local leftPos = self.mRootWidget:getChildByName("Panel_Pos_Left"):getWorldPosition()
      local rightPos = self.mRootWidget:getChildByName("Panel_Pos_Right"):getWorldPosition()
      local midPos = self.mRootWidget:getChildByName("Panel_Pos_Middle"):getWorldPosition()
      local goldDis = midPos.x - leftPos.x

      local srcDis = self.FriendkofBlood:getChildByName("Image_Blood_Bg"):getContentSize().width
      local tarScaleVal = goldDis / srcDis

      -- 左边
      self.FriendkofBlood:getChildByName("Image_Blood_Bg"):setScaleX(tarScaleVal)

      -- 右边
      self.MonsterkofBlood:getChildByName("Image_Blood_Bg"):setScaleX(tarScaleVal)
    end
    doWidgetScale()
    -- 能量进度条
    self.KofFriendEnergyBar = cc.ProgressTimer:create(nengliangtiao)
    self.KofFriendEnergyBar:setType(2)
    self.KofFriendEnergyBar:setSlopbarParam(4, xiedu1)
    -- Setup for a bar starting from the bottom since the midpoint is 0 for the y
    self.KofFriendEnergyBar:setMidpoint(cc.p(0,1))
    -- Setup for a vertical bar since the bar change rate is 0 for x meaning no horizontal change
    self.KofFriendEnergyBar:setAnchorPoint(cc.p(0.5,0.5))
    self.KofFriendEnergyBar:setBarChangeRate(cc.p(1, 0))
    local friendEnbg = self.FriendkofBlood:getChildByName("Image_Energy_Bg")
    self.KofFriendEnergyBar:setPosition(friendEnbg:getContentSize().width/2 ,friendEnbg:getContentSize().height/2)
    friendEnbg:addChild(self.KofFriendEnergyBar,1)
    self.KofFriendEnergyBar:setPercentage(100)

     --动画进度条 黑色条
    self.KofEnemyBar = cc.ProgressTimer:create(xuetiao)
    self.KofEnemyBar:setType(2)
    self.KofEnemyBar:setSlopbarParam(3, xiedu)
    -- Setup for a bar starting from the bottom since the midpoint is 0 for the y
    self.KofEnemyBar:setMidpoint(cc.p(0,1))
    -- Setup for a vertical bar since the bar change rate is 0 for x meaning no horizontal change
    self.KofEnemyBar:setAnchorPoint(cc.p(0.5,0.5))
    self.KofEnemyBar:setBarChangeRate(cc.p(1, 0))
    local friendbg = self.MonsterkofBlood:getChildByName("Image_Blood_Bg")
    self.KofEnemyBar:setPosition(friendbg:getContentSize().width/2 ,friendbg:getContentSize().height/2)
    friendbg:addChild(self.KofEnemyBar,1)
    self.KofEnemyBar:setPercentage(100)
  
    -- 能量进度条
    self.KofEnemyEnergyBar = cc.ProgressTimer:create(nengliangtiao)
    self.KofEnemyEnergyBar:setType(2)
    self.KofEnemyEnergyBar:setSlopbarParam(4, xiedu1)
    -- Setup for a bar starting from the bottom since the midpoint is 0 for the y
    self.KofEnemyEnergyBar:setMidpoint(cc.p(0,1))
    -- Setup for a vertical bar since the bar change rate is 0 for x meaning no horizontal change
    self.KofEnemyEnergyBar:setAnchorPoint(cc.p(0.5,0.5))
    self.KofEnemyEnergyBar:setBarChangeRate(cc.p(1, 0))
    local friendEnbg = self.MonsterkofBlood:getChildByName("Image_Energy_Bg")
    self.KofEnemyEnergyBar:setPosition(friendEnbg:getContentSize().width/2 ,friendEnbg:getContentSize().height/2)
    friendEnbg:addChild(self.KofEnemyEnergyBar,1)
    self.KofEnemyEnergyBar:setPercentage(100)


    if FightSystem.mFightType == "olpvp" and globaldata.olHoldindex%2 == 0 then
      self.KofFriendBar:setScaleX(-1)
      self.KofFriendEnergyBar:setScaleX(-1)
    else
      self.KofEnemyBar:setScaleX(-1)
      self.KofEnemyEnergyBar:setScaleX(-1)
    end


    if FightSystem.mFightType == "olpvp" and (globaldata.olpvpType == 1 or globaldata.olpvpType == 2 ) then
       self.KofOlFriendBarlist = {}
       local index = globaldata:convertOlindex(globaldata.olHoldindex)
       local widgetindex = 1
      for i=1,globaldata:getBattleFormationCount() do
        if i == index then
          self.KofOlFriendBarlist[index] = self.KofFriendBar
        else
          widgetindex = widgetindex + 1
          local xuetiao = cc.Sprite:create()
          xuetiao:setProperty("Frame", "fight_kof_smallhero_blood.png")
          local xiedu = 0.029
          local xiedu1 = 0.032
           --动画进度条 黑色条
          local Bar = cc.ProgressTimer:create(xuetiao)
          Bar:setType(2)
          Bar:setSlopbarParam(3, xiedu)
          -- Setup for a bar starting from the bottom since the midpoint is 0 for the y
          Bar:setMidpoint(cc.p(0,1))
          -- Setup for a vertical bar since the bar change rate is 0 for x meaning no horizontal change
          Bar:setAnchorPoint(cc.p(0.5,0.5))
          Bar:setBarChangeRate(cc.p(1, 0))
          local friendbg = self.FriendkofBlood:getChildByName("Image_HeroBg_"..widgetindex):getChildByName("Image_Blood_Bg")
          self.FriendkofBlood:getChildByName("Image_HeroBg_"..widgetindex):getChildByName("Panel_Blood_Energy"):setVisible(true)
          Bar:setPosition(friendbg:getContentSize().width/2 ,friendbg:getContentSize().height/2)
          friendbg:addChild(Bar,1)
          Bar:setPercentage(100)
          Bar:setColor(getBloodColor(100))
          self.KofOlFriendBarlist[i] = Bar

           if FightSystem.mFightType == "olpvp" and globaldata.olHoldindex%2 == 0 then
              Bar:setScaleX(-1)
           end
        end
      end
      self.KofOlEnemyBarlist = {}
      for i=1,globaldata:getBattleEnemyFormationCount() do
        if i == 1 then
          self.KofOlEnemyBarlist[i] = self.KofEnemyBar
        else
          local xuetiao = cc.Sprite:create()
          xuetiao:setProperty("Frame", "fight_kof_smallhero_blood.png")
          local Bar = cc.ProgressTimer:create(xuetiao)
          Bar:setType(2)
          Bar:setSlopbarParam(3, xiedu)
          -- Setup for a bar starting from the bottom since the midpoint is 0 for the y
          Bar:setMidpoint(cc.p(0,1))
          -- Setup for a vertical bar since the bar change rate is 0 for x meaning no horizontal change
          Bar:setAnchorPoint(cc.p(0.5,0.5))
          Bar:setBarChangeRate(cc.p(1, 0))
          local friendbg = self.MonsterkofBlood:getChildByName("Image_HeroBg_"..i):getChildByName("Image_Blood_Bg")
          self.MonsterkofBlood:getChildByName("Image_HeroBg_"..i):getChildByName("Panel_Blood_Energy"):setVisible(true)
          Bar:setPosition(friendbg:getContentSize().width/2 ,friendbg:getContentSize().height/2)
          friendbg:addChild(Bar,1)
          Bar:setPercentage(100)
          if FightSystem.mFightType == "olpvp" and globaldata.olHoldindex%2 == 0 then
          else
            Bar:setScaleX(-1)
          end
          Bar:setColor(getBloodColor(100))
          self.KofOlEnemyBarlist[i] = Bar
        end
      end 
    end
end

function FightTouchPad2:hideLeftupNode()
    self.mRootWidget:getChildByName("Leftup_Node"):getChildByName("Image_TimeBg"):setVisible(false)
    self.mRootWidget:getChildByName("Leftup_Node"):getChildByName("Panel_Hero"):setVisible(false)
    self.mRootWidget:getChildByName("Leftup_Node"):getChildByName("Label_nengliang"):setVisible(false)
    self.mRootWidget:getChildByName("Leftup_Node"):getChildByName("Image_Drop_Bg"):setVisible(false)
    self.mRootWidget:getChildByName("Leftup_Node"):getChildByName("Image_Gold_Bg"):setVisible(false)
end

function FightTouchPad2:hideRightupNode()
   
end

function FightTouchPad2:InitKofMonsterHead(_isfuben,index)
    if not _isfuben then
      for i=1,globaldata:getBattleEnemyFormationCount() do
          local heroid = globaldata:getBattleEnemyFormationInfoByIndexAndKey(i,"id")
          local _infoDB = DB_HeroConfig.getDataById(heroid)
          local Icons = {_infoDB.IconID ,_infoDB.IconID }
          table.insert(self.MonsterKofList,Icons)
      end
    end
    if index then
      if index == 3 then
        local temp = {}
        local temp1 = {2,3,1}
        for i=1,#self.MonsterKofList do
          temp[i] = self.MonsterKofList[temp1[i]]
        end
        self.MonsterKofList = {}
        for i=1,#temp do
          table.insert(self.MonsterKofList,temp[i])
        end
      end
      self:ShowTeamsCount("monster",index)
    else
      self:ShowTeamsCount("monster",1)
    end
    
  
end

function FightTouchPad2:ShowTeamsCount(_group , _index )
  cclog("FightTouchPad2:ShowTeamsCount===".._group.."====index===".._index)
    if _group == "friend" then
      if _index == 1 then
      elseif _index > #self.FriendKofList then
        return
      else
        local temp = {}
        for i=1,# self.FriendKofList do
           if i == # self.FriendKofList then
            temp[#self.FriendKofList] = self.FriendKofList[1]
          else
            temp[i] = self.FriendKofList[i+1]
          end
        end
        self.FriendKofList = {}
        for i=1,#temp do
          table.insert(self.FriendKofList,temp[i])
        end
      end

      local imgName = DB_ResourceList.getDataById(self.FriendKofList[1][2]).Res_path1
      self.FriendkofBlood:getChildByName("Image_Panel_HeroIcon"):loadTexture(imgName , 1)
      for i=2,#self.FriendKofList do
        local imgName1 = DB_ResourceList.getDataById(self.FriendKofList[i][1]).Res_path1
        self.FriendkofBlood:getChildByName(string.format("Image_HeroBg_%d", i)):setVisible(true)
        self.FriendkofBlood:getChildByName(string.format("Image_HeroBg_%d", i)):getChildByName("Image_HeroIcon"):loadTexture(imgName1 , 1)
        self.FriendkofBlood:getChildByName(string.format("Image_HeroBg_%d", i)):getChildByName("Image_Dead"):setVisible(false)
        if i + (_index-1) > #self.FriendKofList then
          self.FriendkofBlood:getChildByName(string.format("Image_HeroBg_%d", i)):getChildByName("Image_Dead"):setVisible(true)
          ShaderManager:DoUIWidgetDisabled(self.FriendkofBlood:getChildByName(string.format("Image_HeroBg_%d", i)):getChildByName("Image_HeroIcon"), true)

        end
      end
      self.KofFriendIndex = _index
      local role = FightSystem.mRoleManager:FindFriendRoleById(_index)
      local value = role.mPropertyCon.mCurHP / role.mPropertyCon.mMaxHP *100
      self.KofFriendBar:setPercentage(value)
      self.KofFriendBar:setColor(getBloodColor(value))
      self.KofFriendEnergyBar:setPercentage(100)
    else
      if _index == 1 then
      elseif _index > #self.MonsterKofList then
        return
      else
        local temp = {}
        for i=1,#self.MonsterKofList do
          if i == #self.MonsterKofList then
            temp[#self.MonsterKofList] = self.MonsterKofList[1]
          else
            temp[i] = self.MonsterKofList[i+1]
          end
        end
        self.MonsterKofList = {}
        for i=1,#temp do
          table.insert(self.MonsterKofList,temp[i])
        end
      end

      local imgName = DB_ResourceList.getDataById(self.MonsterKofList[1][2]).Res_path1
      self.MonsterkofBlood:getChildByName("Image_Panel_HeroIcon"):loadTexture(imgName , 1)
      for i=2,#self.MonsterKofList do
        local imgName1 = DB_ResourceList.getDataById(self.MonsterKofList[i][1]).Res_path1
        self.MonsterkofBlood:getChildByName(string.format("Image_HeroBg_%d", i)):setVisible(true)
        self.MonsterkofBlood:getChildByName(string.format("Image_HeroBg_%d", i)):getChildByName("Image_HeroIcon"):loadTexture(imgName1 , 1)
        self.MonsterkofBlood:getChildByName(string.format("Image_HeroBg_%d", i)):getChildByName("Image_Dead"):setVisible(false)
        if i + (_index-1) > #self.MonsterKofList then
          ShaderManager:DoUIWidgetDisabled(self.MonsterkofBlood:getChildByName(string.format("Image_HeroBg_%d", i)):getChildByName("Image_HeroIcon"), true)
          self.MonsterkofBlood:getChildByName(string.format("Image_HeroBg_%d", i)):getChildByName("Image_Dead"):setVisible(true)
        end
      end
      self.KofEnemyIndex = _index
      if FightSystem.mFightType == "arena" and globaldata.PvpType == "brave" then
        local role = FightSystem.mRoleManager:FindEnemyRoleById(_index)
        local value = role.mPropertyCon.mCurHP / role.mPropertyCon.mMaxHP *100
        self.KofEnemyBar:setPercentage(value)
        self.KofEnemyBar:setColor(getBloodColor(value))
      else
        self.KofEnemyBar:setPercentage(100)
        self.KofEnemyBar:setColor(getBloodColor(100))
      end
      self.KofEnemyEnergyBar:setPercentage(100)
    end
end

function FightTouchPad2:AddHeroHead(index)

      local widget = GUIWidgetPool:createWidget("FightHero")
      local head ={}
      head.btn = widget
      head.btn:setTag(index)

      local root = self.mRootWidget:getChildByName("Leftup_Node"):getChildByName("Panel_Hero"):getChildByName(string.format("Panel_Hero_%d",index))
      root:addChild(head.btn,100)

      local role = FightSystem.mRoleManager:FindFriendRoleById(index) 
      local data = globaldata:getBattleFormationInfoByIndex(index)
      local Icon = createHeroIcon(data.id, data.level, data.quality, data.advanceLevel)
      Icon:getChildByName("Panel_Star"):setVisible(false)
      head.btn:getChildByName("Panel_HeroIcon"):addChild(Icon)
      head.progress = WidgetProgressBar.new("fight_hero_blood.png","fight_hero_blood_bg.png","right")
      head.progress:setPosition(cc.p(0,0)) ---head.btn:getContentSize().height
      head.HeroIcon = Icon
      local Anim = AnimManager:createAnimNode(8057)
      head.btn:getChildByName("Panel_SelectAnimation"):addChild(Anim:getRootNode(), 100)
      Anim:play("fight_hero_chosen_2",true)
      head.mImage_HeroSelect = Anim
      head.mProgressBar_HeroBar = head.btn:getChildByName("ProgressBar_HeroBar")
      head.mImage_WeaponBg = head.btn:getChildByName("Image_WeaponBg")
      head.mProgressBar_HeroEnergy = head.btn:getChildByName("ProgressBar_HeroEnergy")

      head.btn:getChildByName("Image_Hero_blood_bg"):addChild(head.progress)
      head[index] = head
      head.isLive = true
      head.Posindex = index


      if FightSystem.mFightType == "arena" and globaldata.PvpType == "brave" then
        local curhp = globaldata:getBattleFormationInfoByIndexAndKey(index, "braveCurHp")
        local _prop = globaldata:getBattleFormationInfoByIndexAndKey(index, "propList")
        local maxhp = _prop[0]
        head.progress:setValue(curhp/maxhp*100,curhp/maxhp*100,false)
      else
        head.progress:setValue(100,100,false)
      end

      if not self.mHeadBtnList then
          self.mHeadBtnList = {}
      end  
      table.insert(self.mHeadBtnList,head)
      registerWidgetReleaseUpEvent(head.btn,handler(self,self.OnClickHeadEvent))
end

function FightTouchPad2:AddHeroHeadForArena(index)
      local widget = GUIWidgetPool:createWidget("FightHero")
      local head ={}
      head.btn = widget
      head.btn:setTag(index)

      local root = self.mRootWidget:getChildByName("Rightup_Node"):getChildByName("Panel_Hero_PVP"):getChildByName(string.format("Panel_Hero_%d",index))

      root:addChild(head.btn,100)

      local data = globaldata:getBattleEnemyFormationInfoByIndex(index)
      local Icon = createHeroIcon(data.id, data.level, data.quality, data.advanceLevel)
      Icon:getChildByName("Panel_Star"):setVisible(false)
      head.btn:getChildByName("Panel_HeroIcon"):addChild(Icon)
      head.HeroIcon = Icon
      head.progress = WidgetProgressBar.new("fight_hero_blood.png","fight_hero_blood_bg.png","right")
      head.progress:setPosition(cc.p(0,0)) ---head.btn:getContentSize().height
      head.progress:setValue(100,100,false)
      local Anim = AnimManager:createAnimNode(8057)
      head.btn:getChildByName("Panel_SelectAnimation"):addChild(Anim:getRootNode(), 100)
      Anim:play("fight_hero_chosen_2",true)
      head.mImage_HeroSelect = Anim
      head.mProgressBar_HeroBar = head.btn:getChildByName("ProgressBar_HeroBar")
      head.mImage_WeaponBg = head.btn:getChildByName("Image_WeaponBg")
      head.mProgressBar_HeroEnergy = head.btn:getChildByName("ProgressBar_HeroEnergy")

      head.btn:getChildByName("Image_Hero_blood_bg"):addChild(head.progress)
      head[index] = head
      head.isLive = true
      head.Posindex = index

      if not self.mEnemyBtnList then
          self.mEnemyBtnList = {}
      end  
      table.insert(self.mEnemyBtnList,head)
end

function FightTouchPad2:AddHeroHeadForBrave(index)
      local widget = GUIWidgetPool:createWidget("FightHero")
      local head ={}
      head.btn = widget
      head.btn:setTag(index)

      local root = self.mRootWidget:getChildByName("Rightup_Node"):getChildByName("Panel_Hero_PVP"):getChildByName(string.format("Panel_Hero_%d",index))

      root:addChild(head.btn,100)

      local data = globaldata:getBattleEnemyFormationInfoByIndex(index)
      local Icon = createHeroIcon(data.id, data.level, data.quality, data.advanceLevel)
      Icon:getChildByName("Panel_Star"):setVisible(false)
      head.btn:getChildByName("Panel_HeroIcon"):addChild(Icon)
      head.progress = WidgetProgressBar.new("fight_hero_blood.png","fight_hero_blood_bg.png","right")
      head.progress:setPosition(cc.p(0,0)) ---head.btn:getContentSize().height
      head.HeroIcon = Icon
      local curhp = globaldata:getBattleEnemyFormationInfoByIndexAndKey(index, "braveCurHp")

      local _prop = globaldata:getBattleEnemyFormationInfoByIndexAndKey(index, "propList")
      local maxhp = _prop[0]
      if curhp ~= 0 then
        head.isLive = true
      else
        head.btn:getChildByName("Panel_HeroIcon"):getChildByName("Image_HeroDead"):setVisible(true)
        head.isLive = false
      end
      head.progress:setValue(curhp/maxhp*100,curhp/maxhp*100,false)
      head.mProgressBar_HeroBar = head.btn:getChildByName("ProgressBar_HeroBar")
      head.mImage_WeaponBg = head.btn:getChildByName("Image_WeaponBg")
      head.mProgressBar_HeroEnergy = head.btn:getChildByName("ProgressBar_HeroEnergy")

      head.btn:getChildByName("Image_Hero_blood_bg"):addChild(head.progress)
      head[index] = head
      
      head.Posindex = index

      if not self.mEnemyBtnList then
          self.mEnemyBtnList = {}
      end  
      table.insert(self.mEnemyBtnList,head)
end



function FightTouchPad2:InitTime(time)
      --cclog("FightTouchPad2:InitTime==" .. time)
      if self:IsKofVision() then
          self.mLabeltime =  self.KofMiddlewidget:getChildByName("Label_RemainingTime")
          self.mLabeltime:setVisible(true)
      elseif FightSystem.mFightType == "arena" and globaldata.PvpType == "arena" then
          self.mMD_Node:setVisible(true)
          self.mLabeltime =  self.mMD_Node:getChildByName("BitmapLabel_Time")
          self.mLabeltime:setVisible(true)
      else
           self.mLabeltime = self.mRootWidget:getChildByName("Leftup_Node"):getChildByName("BitmapLabel_Time")
           self.mLabeltime:setVisible(true)
      end
      self:SetTime(time)
end  

-- 初始化ping值状态
function FightTouchPad2:InitPingStatus()
    local function updatePingStatus(_owner, _during)
         -- 可能销毁后才返回包
         if not self.mRootWidget then return end
         local _pingICon = self.mLU_Node:getChildByName("Image_Delay")
         local _pingLabel = self.mLU_Node:getChildByName("Label_Delay")
         _pingLabel:setString(string.format("%d", _during * 1000))
    end
    local _pingICon = self.mLU_Node:getChildByName("Image_Delay")
    _pingICon:setVisible(true)
    GUIEventManager:registerEvent("updatePingStatus", nil, updatePingStatus)
end

function FightTouchPad2:OnClickHeadEvent(widget)
      if self.mHolder.mSkillCon.isPlayCombineing then return end
      if FightSystem.mFightType == "fuben" and FightSystem:GetFightManager().IsShowGuanqia then return end
      self:ChooseRoleIndex(widget:getTag())
      --[[
      if FightSystem.mFightType == "arena" and globaldata.PvpType == "arena" then
        if self.mLastHeadTag == widget:getTag() then return end
        self:ChooseRoleArenaIndex(widget:getTag())
        self.mLastHeadTag = widget:getTag()
      else
        if self.mHolder.mSkillCon.isPlayCombineing then return end
        self:ChooseRoleIndex(widget:getTag())
      end 
      ]]
end

function FightTouchPad2:ChooseRoleIndex(_Index,openAi)
      if self.mLastHeadTag == _Index then return end
      for k,v in pairs(self.mHeadBtnList) do
         if v.btn:getTag() == _Index then
              v.btn:getChildByName("Panel_SelectAnimation"):setVisible(true)
              self:SetRoleKey(_Index,openAi)
              self:DetectGuideStep3()
              local function playStarFinish(selfAnim)
                selfAnim:play("fight_hero_chosen_2",true)  
              end
              v.mImage_HeroSelect:play("fight_hero_chosen_1",false,playStarFinish)  
         else
              v.btn:getChildByName("Panel_SelectAnimation"):setVisible(false)
         end
      end
end

function FightTouchPad2:DetectGuideStep3()
  if FightSystem.mFightType == "fuben" and globaldata.PvpType == "fuben" then
    if FightSystem:GetFightManager().mSelectCount and FightSystem:GetFightManager().mSelectCount == 0 then
      FightSystem:GetFightManager().mSelectCount = 1
      FightSystem:GetFightManager():Guide1_8Step2()
      FightSystem.mRoleManager:AllPlayerAiStopForActivat(false)
      return true
    end
  end
end

function FightTouchPad2:DetectGuide2_1Step()
  if FightSystem.mFightType == "fuben" and globaldata.PvpType == "fuben" then
    if FightSystem:GetFightManager().mIsFightGuide_2_1 and FightSystem:GetFightManager().mSelectCount and FightSystem:GetFightManager().mSelectCount == 0 then
      FightSystem:GetFightManager().mSelectCount = 1
      FightSystem:GetFightManager():Guide2_1Step2()
      return true
    end
  end
end

-- 切换主角来激活AI
function FightTouchPad2:ChooseAIActivat()
  local list  = FightSystem.mRoleManager:GetFriendTable()
  for k,role in pairs(list) do
    
  end
end

function FightTouchPad2:ChooseRoleArenaIndex(_Index)
end

function FightTouchPad2:SetRoleKey(_index,openAi)
    if FightSystem.mFightType == "fuben" then
          self:SetKeyRoleById(_index,openAi)
    elseif FightSystem.mFightType == "arena" then
        if globaldata.PvpType == "brave" then
          self:SetKeyRoleById(_index)
        elseif globaldata.PvpType == "pk" then
          self:SetKeyRoleByIdForPvp(_index)
        elseif globaldata.PvpType == "arena" then
          self:SetKeyRoleById(_index)
          --self:SetKeyRoleByIdForArena(_index)
        elseif globaldata.PvpType == "boss" then
          self:SetKeyRoleById(_index)
        end
    end 
end

function FightTouchPad2:SetKeyRoleById(id,openAi)
        if not self:IsKofVision() then
          local tag = self:FindBtnByPos(id)
          self.mLastHeadTag = tag
        end
        FightSystem.mRoleManager:SetKeyRoleById(id)
        local isKeyAiActivate = nil
        if self.mHolder.mAI.mActivateAIKeyRole then
          self.mHolder.mAI.mActivateAIKeyRole = nil
          isKeyAiActivate = true
        end
        if openAi then
          self.mHolder.mAI:setOpenAI(false)
          self.mHolder.mAI:ResetAttack(true)
        else
          self.mHolder.mAI:setOpenAI(true)
          self.mHolder.mAI:ResetAttack(true)
        end
   
 
        if self.mHolder.mFSM:IsBlock() then
          self.mHolder.mFSM:ChangeToStateWithCondition("block", "idle")
        end
        self.mHolder.mSkillCon:UnRegisterSkillCallBackHandler("FightTouchPad2")
        self.mHolder = FightSystem.mRoleManager:GetKeyRole()
        self:ShowBuffInfoForPad()
        if isKeyAiActivate then
          self.mHolder.mAI.mActivateAIKeyRole = true
          self.mHolder.mAI.mActivateFriendAI = nil
        end
        self.mHolder.mSkillCon:SetFinishSkillCallBackHandler("FightTouchPad2", handler(self, self.OnSkillFinish))
        self:ResetAttack()
        self:UpdateFitSkill()
        self:UpdateSkillBtn()
        self:UpdateSkillCoolDowm()
        local curkeyRolePos = self.mHolder:getShadowPos()
        if not openAi then
          FightSystem.mSceneManager.mCamera:UpdateCameraForKeyRole(curkeyRolePos,self.mHolder.IsFaceLeft) --摄像机定位keyrole
        end
        if FightSystem.mFubenManager:IsautoNextBoard() then
             FightSystem.mRoleManager:SetFriendFollowKeyRole(true)
        end
        if not self.mAutoTouchAttack then
            self.mHolder.mAI:AIAllStop()
            self.mHolder.mAI:setOpenAI(false)
            self.mHolder.mAI:ResetAttack(true)
        end
end
--
function FightTouchPad2:ShowBuffInfoForPad()
    self.SkillReferenceCount = 0
    self.AttackReferenceCount = 0
    self.MoveReferenceCount = 0
    if self.mHolder.mBuffCon:hasSneerBuffNow() then
      self.SkillReferenceCount = self.SkillReferenceCount + 1
      self.AttackReferenceCount = self.AttackReferenceCount + 1
      self.MoveReferenceCount = self.MoveReferenceCount + 1
    end
    if self.mHolder.mBuffCon:hasSilenceBuffNow() then
       self.SkillReferenceCount = self.SkillReferenceCount + 1
    end
    self:DisabledSkill(self.SkillReferenceCount > 0,true)
    self:DisabledAttack(self.AttackReferenceCount > 0,true)
    self:DisabledMove(self.AttackReferenceCount > 0,true)
    
end

function FightTouchPad2:SetKeyRoleByIdForPvp(id)
        local tag = self:FindBtnByPos(id)
        self.mLastHeadTag = tag
        FightSystem.mRoleManager:SetKeyRoleById(id)
        self.mHolder = FightSystem.mRoleManager:GetKeyRole()
        self:UpdateFitSkill()
        self:UpdateSkillBtn()
        self:UpdateSkillCoolDowm()
        local curkeyRolePos = self.mHolder:getShadowPos()
        FightSystem.mSceneManager.mCamera:UpdateCameraForKeyRole(curkeyRolePos,self.mHolder.IsFaceLeft) --摄像机定位keyrole
end

function FightTouchPad2:SetKeyRoleByIdForArena(id)
        FightSystem.mRoleManager:SetKeyRoleById(id)
        if self.mHolder then
            self.mHolder.mAI:setOpenAI(true)
            self.mHolder.mAI:ResetAttack(true)
            if self.mHolder.mFSM:IsBlock() then
              self.mHolder.mFSM:ChangeToStateWithCondition("block", "idle")
            end
            self.mHolder.mSkillCon:UnRegisterSkillCallBackHandler("FightTouchPad2")
        end
        self.mHolder = FightSystem.mRoleManager:GetKeyRole()
        self.mHolder.mSkillCon:SetFinishSkillCallBackHandler("FightTouchPad2", handler(self, self.OnSkillFinish))
        self:ResetAttack()
        self:UpdateSkillBtn()
        self:UpdateSkillCoolDowm()
        if not self.mAutoTouchAttack then
            self.mHolder.mAI:AIAllStop()
            self.mHolder.mAI:setOpenAI(false)
            self.mHolder.mAI:ResetAttack(true)
        end
end

-- 处理开始移动的显示
function FightTouchPad2:MoveStart(pos)
    self.mAutoBreakTime = nil
    if self.mAutoTouchAttack and self.mHolder.mAI.mOpenAI then
      self.mHolder.mAI:setOpenAI(false)
      self:ResetAttack()
    end

    self.mIsControlMoving = true
    self.mPadnode:setVisible(true)
    self.mPadMovenode:setVisible(true)
    self.mPadnode:setPosition(pos)
    self.mPadMovenode:setPosition(pos)
    self.mTouchFristPoint = pos
    self.mTouchMovePoint = pos
    self.mWidgetPadnode:setVisible(false)
    self.mWidgetPadMovenode:setVisible(false)
end

-- 处理移动的显示
function FightTouchPad2:Movecontroller(_curPos)
    local function moveRole(_dir, _deg)
        if self.mLastDeg == _deg then return end
        self.mLastDir = _dir
        self.mLastDeg = _deg
        if self.mHolder then
          self.mHolder:OnFTCommand(_dir, _deg)
        end
    end
    -- 处理显示
    self.mPadMovenode:setPosition(_curPos)
    local _PadPos = cc.p(self.mPadnode:getPosition())
    local _dis = cc.pGetDistance(_curPos, _PadPos)
    local _moveDis = _dis - _DIRECTION_PAD_R_
    local _deg = MathExt.GetDegreeWithTwoPoint(_curPos, _PadPos)
    if _moveDis > 0 then
       _PadPos.x = _PadPos.x + _moveDis*math.cos(math.rad(_deg))
       _PadPos.y = _PadPos.y + _moveDis*math.sin(math.rad(_deg))
       self.mPadnode:setPosition(_PadPos)
    end
    -- 移动角色
    local _dir = FightConfig.GetDirectionByDegree(_deg)
    self:setCurDirection(_dir, _deg)
    moveRole(_dir, _deg)
end

-- 处理结束的显示
function FightTouchPad2:MoveEnd()
    self.mAutoBreakTime = 1
    self.mPadnode:setVisible(false)
    self.mPadMovenode:setVisible(false)
    self.mWidgetPadnode:setVisible(true)
    self.mWidgetPadMovenode:setVisible(true)
    self.mIsControlMoving = false
end

function FightTouchPad2:XunhuanGongji(delta)

   if self.mHolder.mFSM:IsBeatingStiff() then
      self.mNormalSkill_ID = 0
      self.mCallNormalSkill_ID = 0
      self.mNormalSkill_Index = 0
      self.mHolder.mSkillCon:FinishCurSkill()
      return
   end  

  if  self.mNormalSkill_ID ==  self.mCallNormalSkill_ID then
      --self:GongjiChangeFace()
      self.mCallNormalSkill_ID = 0
      if self.mHolder.mGunCon.isEquip then
          if self.mHolder.mGunCon:playShootSkill() then
              self.mNormalSkill_ID = self.mHolder.mGunCon.mBindSkill
          else
            self:ResetAttack()
          end
          return
      elseif self.mHolder.mPickupCon:playPickuping() then
        return
      elseif self.mHolder.mPickupCon:isPickup() then
          --if self.mNormalSkill_ID == 0 then return end
          local bind = self.mHolder.mPickupCon:isPickup()
          if bind.mState == "bind" then
             if not self.mHolder:PlaySkillByID(bind.mBindNormalAttack,"pickup_hit") then
                self:ResetAttack()
                return 
             end
             self.mNormalSkill_ID = bind.mBindNormalAttack
          end
          return
      end
    if self.mNormalSkill_Index == 0 then
      if not self.mHolder:PlaySkillByID(self.mHolder.mRoleData.mRole_NormalSkill1) then

        self:ResetAttack()
        return 
      end
      self.mNormalSkill_ID = self.mHolder.mRoleData.mRole_NormalSkill1

      self.mNormalSkill_Index = 1
    else 
      local nextskill = self.mNormalSkill_Index + 1
      if nextskill > self.mHolder.mRoleData.mNormalSkillMaxCount then
        nextskill = 1
      end
      --[[
      local tempnextskill = nextskill
      if nextskill == 4 then
          local num = 0
          tempnextskill = nextskill + num
      end
      ]]
      local key = string.format("mRole_NormalSkill%d",nextskill)
      if self.mHolder.mRoleData[key] == 0 then
        --没有的从第一个放
            if not self.mHolder:PlaySkillByID(self.mHolder.mRoleData.mRole_NormalSkill1) then
                  self:ResetAttack()
                  return 
            end
            self.mNormalSkill_ID = self.mHolder.mRoleData.mRole_NormalSkill1
      else
          if not self.mHolder:PlaySkillByID(self.mHolder.mRoleData[key]) then
              self:ResetAttack()
              return 
          end 
        self.mNormalSkill_ID = self.mHolder.mRoleData[key]
        self.mNormalSkill_Index = nextskill
      end 
    end
  end 
end

function FightTouchPad2:GongjiChangeFace()
    if not self.mHolder then return end
    if self.mHolder.mFSM:IsAttacking() then
        if self.mTouchMovePoint and self.mTouchFristPoint then
          if self.mTouchMovePoint.x > self.mTouchFristPoint.x then
              self.mHolder:FaceRight()
          elseif self.mTouchMovePoint.x < self.mTouchFristPoint.x then
              self.mHolder:FaceLeft()
          end
        end
    end
end

function FightTouchPad2:ResetAttack()
    self.mNormalSkill_ID = 0
    self.mCallNormalSkill_ID = 0
    self.mDownTime = 0
    self.mUpTime = 0
    self.mNormalSkill_Index = 0
   -- self.mIsAttackBtnDown = false
end

function FightTouchPad2:DoublehitNum(_role, _hiter)

    local function xxx( ... )
        if not self.mCombotop then
          self.mCombotop = WidgetCombotop.new()
          self.mRootWidget:getChildByName("Panel_ComboPos"):addChild(self.mCombotop)
        end
        if _role.mGroup == "monster" or _role.mGroup == "summonmonster" then
            if _hiter.mGroup == "friend" then
              self.mCombotop:setStringNum()
            end
        end
    end

   caculateFuncDuring("DoublehitNum",xxx)
end

function FightTouchPad2:WaitDoublehitNum()
  if self.mCombotop then
    self.mCombotop:AddCombotopTime()
  end
end

-- 属性改变回调事件
function FightTouchPad2:OnRolePropertyChangeEvent(_type, _damage, _role, _hiter)
  if _type == 1 then
      if _role.mGroup == "friend" then
          self:OnFriendPropertyChange(_type, _damage, _role, _hiter)
      elseif  _role.mGroup == "monster" then
          self:OnMonsterPropertyChange(_type, _damage, _role, _hiter)
      elseif _role.mGroup == "enemyplayer" then
          if FightSystem.mFightType == "fuben" and not FightSystem:GetFightManager().IsShowGuanqia then
            self:OnPlunderEnemyPropertyChange(_type, _damage, _role, _hiter)
          else
            self:OnEnemyPropertyChange(_type, _damage, _role, _hiter)
          end
      elseif _role.mGroup == "summonfriend" or _role.mGroup == "summonmonster" then
          self:OnSummonPropertyChange(_type, _damage, _role, _hiter)
      end 
  end 
end

-- 受击头像闪烁
function FightTouchPad2:beatedHeadIConFlash(_sp ,_indexhead)
    local scheduler = cc.Director:getInstance():getScheduler()
    local sp = _sp 
    local function resume()
       if not self.mScheduler_FlashHead then return end
       sp:setColor(G_COLOR_C3B.WHITE)
       G_unSchedule(self.mScheduler_FlashHead[_indexhead])
       self.mScheduler_FlashHead[_indexhead] = nil
    end
    sp:setColor(G_COLOR_C3B.RED)
    self.mScheduler_FlashHead[_indexhead] = scheduler:scheduleScriptFunc(resume, 0.1, false)
end

-- FRIEND回调
function FightTouchPad2:OnFriendPropertyChange(_type, _damage, _role, _hiter)
    local CurHp = _role.mPropertyCon.mCurHP
    if CurHp < 0 then CurHp = 0 end
    if self:IsKofVision() then
       local value = (CurHp) /_role.mPropertyCon.mMaxHP *100
        if FightSystem.mFightType == "olpvp" and (globaldata.olpvpType == 1 or globaldata.olpvpType == 2 ) then
          self.KofOlFriendBarlist[_role.mPosIndex]:setPercentage(value)
          self.KofOlFriendBarlist[_role.mPosIndex]:setColor(getBloodColor(value))
        else
          self.KofFriendBar:setPercentage(value)
          self.KofFriendBar:setColor(getBloodColor(value))
        end
        -- self.FriendkofBlood:getChildByName("ProgressBar_heroHP"):setPercent(value) 
        -- self.FriendkofBlood:getChildByName("ProgressBar_heroHP"):setColor(getBloodColor(value))
    elseif self:IsArenaVision() then
        local  per = ((-_damage + CurHp)/_role.mPropertyCon.mMaxHP)*100
        local  value = 0
        local  indexhead = self:FindBtnByPos(_role.mPosIndex)
        value = (CurHp / _role.mPropertyCon.mMaxHP )*100
        self.mHeadBtnList[indexhead].progress:setValue(per,value,true)
        ----受击者头像闪红------
        if not self.mScheduler_FlashHead[indexhead] then
          local _sp = self.mHeadBtnList[indexhead].btn:getChildByName("Panel_HeroIcon"):getVirtualRenderer()
           self:beatedHeadIConFlash(_sp,indexhead)
        end
        --[[
        local value = (CurHp / _role.mPropertyCon.mMaxHP )*100
        local  per = ((-_damage + CurHp)/_role.mPropertyCon.mMaxHP)*100
        if self.mArenaFriendHead[_role.mPosIndex] then
            if value == 0 then
                ShaderManager:DoUIWidgetDisabled(self.mArenaFriendHead[_role.mPosIndex]:getChildByName("Image_HeroHead"), true)
            end
            self.mArenaFriendHead[_role.mPosIndex]:getChildByName("ProgressBar_Blood"):setPercent(value)
            self.mArenaFriendHead[_role.mPosIndex]:getChildByName("ProgressBar_Blood"):setColor(getBloodColor(value))
        end
        ]]
    else
        local  per = ((-_damage + CurHp)/_role.mPropertyCon.mMaxHP)*100
        local  value = 0
        local  indexhead = self:FindBtnByPos(_role.mPosIndex)
        value = (CurHp / _role.mPropertyCon.mMaxHP )*100
        self.mHeadBtnList[indexhead].progress:setValue(per,value,true)
        ----受击者头像闪红------
        if not self.mScheduler_FlashHead[indexhead] then
          local _sp = self.mHeadBtnList[indexhead].btn:getChildByName("Panel_HeroIcon"):getVirtualRenderer()
           self:beatedHeadIConFlash(_sp,indexhead)
        end 
    end

end

-- 掠夺敌方玩家
function FightTouchPad2:OnPlunderEnemyPropertyChange(_type, _damage, _role, _hiter)
      local CurHp = _role.mPropertyCon.mCurHP
      if CurHp < 0 then CurHp = 0 end
      local value = (CurHp) /_role.mPropertyCon.mMaxHP *100
      _role:setMonsterBloodPro(value)
end

function FightTouchPad2:OnSummonPropertyChange(_type, _damage, _role, _hiter)
    local CurHp = _role.mPropertyCon.mCurHP
    if CurHp < 0 then CurHp = 0 end
    local value = (CurHp) /_role.mPropertyCon.mMaxHP *100
    _role:setMonsterBloodPro(value)
end

-- monster回调
function FightTouchPad2:OnMonsterPropertyChange(_type, _damage, _role, _hiter)
      local CurHp = _role.mPropertyCon.mCurHP
      if CurHp < 0 then CurHp = 0 end
        if self:IsKofVision() then
            local value = (CurHp) /_role.mPropertyCon.mMaxHP *100
            self.KofEnemyBar:setPercentage(value)
            self.KofEnemyBar:setColor(getBloodColor(value))

            -- self.MonsterkofBlood:getChildByName("ProgressBar_heroHP"):setPercent(value)
            -- self.MonsterkofBlood:getChildByName("ProgressBar_heroHP"):setColor(getBloodColor(value))
            return
         end
        if _role.mRoleData.mInfoDB.Monster_Grade ~= 4 then
            local value = (CurHp) /_role.mPropertyCon.mMaxHP *100
            _role:setMonsterBloodPro(value)
        else
            if self.mBossBar.mInstanceID == _role.mRoleData.mInstanceID then
                local pre =  ((CurHp-_damage) % _role.mPropertyCon.mRowHp) /_role.mPropertyCon.mRowHp *100
                if pre == 0 then
                   pre = 100
                end
                local percount = math.ceil((CurHp-_damage)/_role.mPropertyCon.mRowHp) 
                local value = 0
                local valuecount = 0
                if CurHp <=0 then
                    value = 0
                    valuecount = 1
                else
                     value = ((CurHp) % _role.mPropertyCon.mRowHp)/_role.mPropertyCon.mRowHp *100
                      if value == 0 then
                          value = 100
                      end 
                     valuecount = math.ceil((CurHp)/_role.mPropertyCon.mRowHp) 
                end
                self.mBossBar:setValueClean(pre,value,percount,valuecount)
            end
        end
end

-- enemy回调
function FightTouchPad2:OnEnemyPropertyChange(_type, _damage, _role, _hiter)
    local CurHp = _role.mPropertyCon.mCurHP
    if CurHp < 0 then CurHp = 0 end

     if self:IsKofVision() then
      local value = (CurHp) /_role.mPropertyCon.mMaxHP *100
        if FightSystem.mFightType == "olpvp" and (globaldata.olpvpType == 1 or globaldata.olpvpType == 2 ) then
          self.KofOlEnemyBarlist[_role.mPosIndex]:setPercentage(value)
          self.KofOlEnemyBarlist[_role.mPosIndex]:setColor(getBloodColor(value))
        else
          self.KofEnemyBar:setPercentage(value)
          self.KofEnemyBar:setColor(getBloodColor(value))
        end
          -- self.MonsterkofBlood:getChildByName("ProgressBar_heroHP"):setPercent(value)
          -- self.MonsterkofBlood:getChildByName("ProgressBar_heroHP"):setColor(getBloodColor(value))
      elseif self:IsArenaVision() then
        local  per = ((-_damage + CurHp)/_role.mPropertyCon.mMaxHP)*100
        local  value = 0
        local  indexhead = self:FindEnemyBtnByPos(_role.mPosIndex)
        if _role.mPropertyCon.mCurHP <=0 then
             value = 0
        else
             value = (CurHp / _role.mPropertyCon.mMaxHP )*100
        end
        _role:setMonsterBloodPro(value)
        self.mEnemyBtnList[indexhead].progress:setValue(per,value,true)
        --[[
          local value = (CurHp / _role.mPropertyCon.mMaxHP )*100
          if self.mArenaEnemyHead[_role.mPosIndex] then
              local  per = ((-_damage + CurHp)/_role.mPropertyCon.mMaxHP)*100
              if value == 0 then
                ShaderManager:DoUIWidgetDisabled(self.mArenaEnemyHead[_role.mPosIndex]:getChildByName("Image_HeroHead"), true)
              end
              self.mArenaEnemyHead[_role.mPosIndex]:getChildByName("ProgressBar_Blood"):setPercent(value)
              self.mArenaEnemyHead[_role.mPosIndex]:getChildByName("ProgressBar_Blood"):setColor(getBloodColor(value))

              --self.mHeadArenaEnemyList[_role.mPosIndex].progress:setValue(per,value,true)
          end 
          ]]
      elseif FightSystem.mFightType == "fuben" and FightSystem:GetFightManager().IsShowGuanqia then
        local  per = ((-_damage + CurHp)/_role.mPropertyCon.mMaxHP)*100
        local  value = 0
        local  indexhead = self:FindEnemyBtnByPos(_role.mPosIndex)
        if _role.mPropertyCon.mCurHP <=0 then
             value = 0
        else
             value = (CurHp / _role.mPropertyCon.mMaxHP )*100
        end
        _role:setMonsterBloodPro(value)
        self.mEnemyBtnList[indexhead].progress:setValue(per,value,true)
      else
        --[[
        local  per = ((-_damage + CurHp)/_role.mPropertyCon.mMaxHP)*100
        local  value = 0
        local  indexhead = self:FindEnemyBtnByPos(_role.mPosIndex)
        if _role.mPropertyCon.mCurHP <=0 then
             value = 0
        else
             value = (CurHp / _role.mPropertyCon.mMaxHP )*100
        end
        _role:setMonsterBloodPro(value)
        self.mEnemyBtnList[indexhead].progress:setValue(per,value,true)
        ]]
      end
end

function FightTouchPad2:setCurDirection(_dir, _deg)
    self.mCurDirection = _dir
    self.mCurDeg = _deg
end

function FightTouchPad2:getCurDirection()
     return self.mCurDirection, self.mCurDeg
end

-- 取消touch滑动
function FightTouchPad2:setCancelledTouch()
    self.mCancelledFlag = true  
    self.mBeganFlag = false
    self.mLastDeg = nil
    self:MoveEnd()
    self:setCurDirection(FightConfig.DIRECTION_CMD.STOP, 0)
   -- 指令系统测试
    local _cmd = string.format("pve_0_move_%d_%d", 0, 0)
    FCmdParseSystem.parseCommand(_cmd)
end

-- 设置
function FightTouchPad2:setCancelledTouchMove(_state)
    self.mCancelledFlag = _state  
    self.mBeganFlag = false
    self.mLastDeg = nil
    self:MoveEnd()
    self:setCurDirection(FightConfig.DIRECTION_CMD.STOP, 0)
    local _cmd = string.format("pve_0_move_%d_%d", 0, 0)
    FCmdParseSystem.parseCommand(_cmd)
end

-- 更新技能冷却时间
function FightTouchPad2:UpdateSkillCoolDowm(delta)

  for i=1,3 do
     local skillid = self.mHolder.mRoleData[string.format("mRole_SpecialSkill%d",i)]
     if skillid ~= 0 and self.mHolder.mRoleData:IsSkillActivateById(skillid) then
           local cooltime,max,upTimes,upMaxTimes = self.mHolder.mSkillCon:SkillInCoolDownTime(skillid)
           local _db = DB_SkillEssence.getDataById(skillid)
           if _db.CostMp ~= 0 then
              self:UpdateProgressCostMp(cooltime,max,upTimes,upMaxTimes,i)
           elseif _db.PowerUpTimes ~= 0 then
               self:UpdateProgressPowerUp(cooltime,max,upTimes,upMaxTimes,i)
           else
               self:UpdateProgress(cooltime,max,i)
           end 
     end
  end
  -- 闪烁技能
  if self.mJumpState == "jump" then
    local skillblinkid = self.mHolder.mRoleData.mRole_DodgeSkill
    if skillblinkid ~= 0 and self.mHolder.mRoleData:IsSkillActivateById(skillblinkid) then
           local cooltime,max,upTimes,upMaxTimes = self.mHolder.mSkillCon:SkillInCoolDownTime(skillblinkid)
           local _db = DB_SkillEssence.getDataById(skillblinkid)
           if _db.CostMp ~= 0 then
              self:UpdateProgressCostMp(cooltime,max,upTimes,upMaxTimes,5)
           elseif _db.PowerUpTimes ~= 0 then
               self:UpdateProgressPowerUp(cooltime,max,upTimes,upMaxTimes,5)
           else
               self:UpdateProgress(cooltime,max,5)
           end 
     end
  end
  --合体技能
  local fit = self.Button_skill_Table[4]["Image"]
  if fit:isVisible() then
       local cooltime,max,upTimes,upMaxTimes = self.mHolder.mSkillCon:GroupSkillInCoolDownTime()
       if  self.mHolder.mRoleData.mGSID1 ~= 0 then
        local _db = DB_SkillEssence.getDataById(self.mHolder.mRoleData.mGSID1)
         if _db.CostMp ~= 0 then
            self:UpdateProgressCostMp(cooltime,max,upTimes,upMaxTimes,4)
         elseif _db.PowerUpTimes ~= 0 then
             self:UpdateProgressPowerUp(cooltime,max,upTimes,upMaxTimes,4)
         else
             self:UpdateProgress(cooltime,max,4)
         end
       end
  end

end

function FightTouchPad2:UpDateBlock(delta)

  -- local Cooltime = self.mHolder.mMoveCon.mBlockCon.mBlockCoolingtime
  -- local CoolMax = self.mHolder.mMoveCon.mBlockCon.mBlockCoolingMax
  -- if Cooltime <= 0 then
  --   self.mJumpbtn:setEnabled(true)
  --   self.mBlockaniBar_:setVisible(false)
  --   self.mBlocklb:setVisible(false)
  -- else
  --   self.mJumpbtn:setEnabled(false)
  --   self.mBlockaniBar_:setPercentage((Cooltime/CoolMax)*100)

  --   local str = math.ceil(Cooltime)
  --   str = string.format("%d",str)
  --   self.mBlocklb:setString(str)
  --   self.mBlockaniBar_:setVisible(true)
  --   self.mBlocklb:setVisible(true)
  -- end

end

-- 更新子弹数
function FightTouchPad2:UpdateShoot(delta)
    if not self.mHolder then return end
    if FightSystem.mFightType == "arena" and globaldata.PvpType == "arena" then return end
    if FightSystem.mFightType == "fuben" and globaldata.PvpType == "fuben" then
      if self.mHolder.mGunCon.isHaveGun then
          self.mCheckWeaponBtn:setVisible(true)
      else
          self.mCheckWeaponBtn:setVisible(false)
      end
      if not self.mHeadBtnList then return end
        for k,v in pairs(self.mHeadBtnList) do
          if v.isLive then
               local role = FightSystem.mRoleManager:FindFriendRoleById(v.Posindex)
               if role then
                  if role.mGunCon.isHaveGun then
                    v.mImage_WeaponBg:setVisible(true)
                    local cent = role.mGunCon:getCentshoot()
                    v.mProgressBar_HeroBar:setPercent(cent)
                  else
                    v.mImage_WeaponBg:setVisible(false)
                  end
               end
          end
        end
    end
end

function FightTouchPad2:UpdateMp(delta)
  if self:IsKofVision() then
    local role = FightSystem.mRoleManager:FindFriendRoleById(self.KofFriendIndex)
    if role then
       local per = (role.mSkillCon.mMp / 100 )*100
      self.KofFriendEnergyBar:setPercentage(getEnergyPerByMp(per))
    end
    return
  end
   if self.mHeadBtnList then
    for k,v in pairs(self.mHeadBtnList) do
      if v.isLive then
           local role = FightSystem.mRoleManager:FindFriendRoleById(v.Posindex)
           if role then
                local per = (role.mSkillCon.mMp / 100 )*100
                v.mProgressBar_HeroEnergy:setPercent(getEnergyPerByMp(per))
           end
      end
    end
  end
  if self.mEnemyBtnList then
     for k,v in pairs(self.mEnemyBtnList) do
        if v.isLive then
             local role = FightSystem.mRoleManager:FindEnemyRoleById(v.Posindex)
             if role then
                  local per = (role.mSkillCon.mMp / 100 )*100
                  v.mProgressBar_HeroEnergy:setPercent(getEnergyPerByMp(per))
             end
        end
     end
  end
end

function FightTouchPad2:UpdateArenaMp(delta)
   if self:IsKofVision() then
    if FightSystem.mFightType == "fuben" and not FightSystem:GetModelByType(4) then return end
      local role = FightSystem.mRoleManager:FindEnemyRoleById(self.KofEnemyIndex)
      if role then
         local per = (role.mSkillCon.mMp / 100 )*100
        self.KofEnemyEnergyBar:setPercentage(getEnergyPerByMp(per))
      end
      return
    elseif self:IsArenaVision() then
        --[[
        for k,v in pairs(self.mArenaFriendHead) do
          local role = FightSystem.mRoleManager:FindFriendRoleById(k)
          if role then
            local per = (role.mSkillCon.mMp / 100 )*100
            self.mArenaFriendHead[role.mPosIndex]:getChildByName("ProgressBar_Energy"):setPercent(per)
          end
        end

        for k,v in pairs(self.mArenaEnemyHead) do
          local role = FightSystem.mRoleManager:FindEnemyRoleById(k)
          if role then
            local per = (role.mSkillCon.mMp / 100 )*100
            self.mArenaEnemyHead[role.mPosIndex]:getChildByName("ProgressBar_Energy"):setPercent(per)
          end
        end
        ]]
    end
end

-- OlPVP显示每局胜负
function FightTouchPad2:OlPVPRoundResult(result,fun,group,index)
  if self.mRoundResult then
    self.mRoundResult:removeFromParent()
    self.mRoundResult = nil
  end
  self.mRoundResult =  GUIWidgetPool:createWidget("Fight_KOF_Round_Result")
  self:addChild(self.mRoundResult,1001)

  local function playStarFinish( ... )
    if fun then
      fun()
      fun = nil
    end
  end

  local function Finish( evt )
    if evt == "1" then
      if result == 2 then
        self.mRoundResult:getChildByName("Panel_Draw"):setVisible(true)
      else
        self.mRoundResult:getChildByName("Panel_Win"):setVisible(true)
          local data = nil
          if group == "friend" then
              data = globaldata:getBattleFormationInfoByIndex(index)
              Icon = createHeroIcon(data.id, data.level, data.quality, data.advanceLevel)
              local _infoDB = DB_HeroConfig.getDataById(data.id)
              HeroName = getDictionaryText(_infoDB.Name)
          else
              data = globaldata:getBattleEnemyFormationInfoByIndex(index)
              Icon = createHeroIcon(data.id, data.level, data.quality, data.advanceLevel)
              local _infoDB = DB_HeroConfig.getDataById(data.id)
              HeroName = getDictionaryText(_infoDB.Name)
          end
          self.mRoundResult:getChildByName("Panel_WinnerHeroIcon"):addChild(Icon)
          self.mRoundResult:getChildByName("Label_PlayerName"):setString(data.playerName)
          self.mRoundResult:getChildByName("Label_HeroName"):setString(HeroName)
      end
    end
  end
  local RoundAni = AnimManager:createAnimNode(8053)
  self.mRoundResult:getChildByName("Panel_Animation"):addChild(RoundAni:getRootNode(), 100)
  RoundAni:play("fight_roundresult",false,playStarFinish,Finish)


end

function FightTouchPad2:RemoveRoundResult()
    if self.mRoundResult then
      self.mRoundResult:removeFromParent()
      self.mRoundResult = nil
    end
end

-- 第几回合开始
function FightTouchPad2:RoundFight(index,funCall)
  GUISystem:disableUserInput()
  if self.KofMiddlewidget then
    self.KofMiddlewidget:getChildByName("Panel_Round_Num"):setVisible(true)
    self.KofMiddlewidget:getChildByName("Panel_Round_Num"):getChildByName("Label_Round_Num"):setString(string.format("第%d回合",index))
  end 
 
  local function RoundBegin( selfAni )
     selfAni:destroy()
     GUISystem:enableUserInput()
      if funCall then
        funCall()
        funCall = nil
      end
  end

  local function playStarFinish( selfAni )
    selfAni:destroy()
    local Beginfight = AnimManager:createAnimNode(8052)
    self:addChild(Beginfight:getRootNode(), 100)
    Beginfight:getRootNode():setPosition(getGoldFightPosition_Middle())
    Beginfight:play("fight_begin",false,RoundBegin)
  end

  self.mRoundBegin = AnimManager:createAnimNode(8051)
  self:addChild(self.mRoundBegin:getRootNode(), 100)
  self.mRoundBegin:getRootNode():setPosition(getGoldFightPosition_Middle())
  self.mRoundBegin:play(string.format("fight_round_%d",index),false,playStarFinish)
end

-- 回合结束加载下一回合
function FightTouchPad2:LoadNextRoundLoading(fun)
  if self.mLoadPanel then
    self.mLoadPanel:removeFromParent()
    self.mLoadPanel = nil
  end
   self.mLoadPanel = OlPvpLoadPanel.new()
   self.mLoadPanel.mWidget:getChildByName("Image_Bg"):setVisible(true)
   self.mLoadPanel.mWidget:getChildByName("Image_VS"):setVisible(true)
   self:addChild(self.mLoadPanel,1002)
    local act0 = cc.DelayTime:create(0.1)
    local act1 = cc.CallFunc:create(fun)
    self.mLoadPanel:runAction(cc.Sequence:create(act0, act1))
end

function FightTouchPad2:setLoadPanelPer(index,percent)
  if not self.mLoadPanel then return end
  self.mLoadPanel:setPercentByIndex(index,percent)
end

function FightTouchPad2:RemoveLoadNextRound()
   if self.mLoadPanel then
    self.mLoadPanel:removeFromParent()
    self.mLoadPanel = nil
  end
end

-- 宝箱计数
function FightTouchPad2:BaoxiangNum()
    self.mBaoxiangCount = self.mBaoxiangCount + 1
    self.mLU_Node:getChildByName("Label_dropNum"):setString(tostring(self.mBaoxiangCount))
end

-- 金币计数
function FightTouchPad2:JinbiNum()
    self.mJinbiCount = self.mJinbiCount + 1
    self.mLU_Node:getChildByName("Label_GoldNum"):setString(tostring(self.mJinbiCount))
end

-- 宝箱缩放
function FightTouchPad2:BaoxiangScale()
    self.mLU_Node:getChildByName("Image_Drop"):stopAllActions()
    self.mLU_Node:getChildByName("Image_Drop"):setScale(1.3)
    local act0 = cc.ScaleTo:create(0.5, 1)
    self.mLU_Node:getChildByName("Image_Drop"):runAction(act0)
end

-- 金币缩放
function FightTouchPad2:JinbiScale()
    self.mLU_Node:getChildByName("Image_Gold"):stopAllActions()
    self.mLU_Node:getChildByName("Image_Gold"):setScale(1.3)
    local act0 = cc.ScaleTo:create(0.5, 1)
    self.mLU_Node:getChildByName("Image_Gold"):runAction(act0)
end

function FightTouchPad2:CreateCoolBlock(node,index)
      local btn = node
      local btn1 = self.mRootWidget:getChildByName(string.format("Image_Fight_Skill_BG%d",index))
      self.Button_skill_Table[index] = {}
      self.Button_skill_Table[index]["btn"] = btn
      self.Button_skill_Table[index]["Image"] = btn1
      self.Button_skill_Table[index]["Image_Circle"] = btn:getChildByName("Image_Circle")
      self:CreateCoolskill(btn,index)
end

function FightTouchPad2:CreateCoolskill(node,index)
    local xuetiao = nil
    if index == 1 then
      xuetiao = cc.Sprite:create()
      xuetiao:setProperty("Frame", "fight_skill_circle_energy.png")
    else
      xuetiao = cc.Sprite:create()
      xuetiao:setProperty("Frame", "fight_skill_circle_cold.png")
    end
    
    --动画进度条
    local aniBar_ = cc.ProgressTimer:create(xuetiao) 

    local bartag = 100 + index
    --aniBar_:setTag(bartag)
    aniBar_:setType(0)
    if index == 1 then
      aniBar_:setReverseDirection(false)
    else
      aniBar_:setReverseDirection(true)
    end
    
    local _lb = ccui.Text:create()
    _lb:setLocalZOrder(3)
    _lb:setFontSize(26)
    _lb:setFontName("res/fonts/font_3.ttf")
     local ttftag = 1000 + index
    --_lb:setTag(ttftag)
    _lb:setAnchorPoint(0.5,0.5)
    --local _lben = ccui.Text:create()
    --local  _lben = cc.LabelBMFont:create(string.format("%d", 0),  "res/fonts/font_fight_yellow.fnt")
    --_lben:setLocalZOrder(3)
    --_lben:setScale(0.5)
     local ttftag1 = 10000 + index
    --_lben:setTag(ttftag1)

    local _resDB = DB_ResourceList.getDataById(808)
    local mp_nodespine =  CommonAnimation.createSpine_common(_resDB.Res_path2, _resDB.Res_path1)
    mp_nodespine:setVisible(false)
    local ttftag2 = 100000 + index
    --mp_nodespine:setTag(ttftag2)
    mp_nodespine:setAnimation(0, "on", true)
    local btn_bg = self.Button_skill_Table[index]["Image"]
    btn_bg:addChild(mp_nodespine)
    self.Button_skill_Table[index]["aniBar_100"] = aniBar_
    self.Button_skill_Table[index]["lb_1000"] = _lb
    --self.Button_skill_Table[index]["lben_10000"] = _lben
    self.Button_skill_Table[index]["nodespine"] = mp_nodespine
    node:addChild(aniBar_)
    node:addChild(_lb,10)
    --node:addChild(_lben,10)
    self:CreatePowerpoints(node,index)
    mp_nodespine:setPosition(btn_bg:getBoundingBox().width/2,btn_bg:getBoundingBox().height/2)
    mp_nodespine:setScale(node:getScaleX())
    aniBar_:setPosition(node:getContentSize().width/2,node:getContentSize().height/2)
    _lb:setPosition(node:getContentSize().width/2,node:getContentSize().height/2)
    --_lben:setPosition(node:getContentSize().width-32,20)
    aniBar_:setVisible(false)
    _lb:setVisible(false)
    --_lben:setVisible(false)
end

function FightTouchPad2:CreatePowerpoints(node,index)
    if index == 2 or index == 3 or index == 5 then
      self.Button_skill_Table[index]["powerpoint"] = {}
      self.Button_skill_Table[index]["powerpoint_have"] = {}
       for i=1,4 do
          self.Button_skill_Table[index]["powerpoint"][i] = node:getChildByName(string.format("Image_Energy_%d",i))
          self.Button_skill_Table[index]["powerpoint_have"][i] = self.Button_skill_Table[index]["powerpoint"][i]:getChildByName("Image_Bean")
       end
    end
end

function FightTouchPad2:ShowPowerPoints(max,point,index)
    if index == 2 or index == 3 or index == 5 then
      for i=1,4 do
        if max < i then
          self.Button_skill_Table[index]["powerpoint"][i]:setVisible(false)
        else
          self.Button_skill_Table[index]["powerpoint"][i]:setVisible(true)
          if point < i then
            self.Button_skill_Table[index]["powerpoint_have"][i]:setVisible(false)
          else
            self.Button_skill_Table[index]["powerpoint_have"][i]:setVisible(true)
          end
        end
      end
    end
end

function FightTouchPad2:UpdateProgress(cooltime,max,index)
    
    local btn = self.Button_skill_Table[index]["btn"]
    local btn_bg = self.Button_skill_Table[index]["Image"]
    local btn_Circle = self.Button_skill_Table[index]["Image_Circle"]
    local time = self.Button_skill_Table[index]["lb_1000"]
    local pro = self.Button_skill_Table[index]["aniBar_100"]
    --local enery = self.Button_skill_Table[index]["lben_10000"]
    local mp_node = self.Button_skill_Table[index]["nodespine"]
    if cooltime > 0 then
        btn_Circle:setVisible(false)
        if not pro then return  end
        pro:setPercentage((cooltime/max)*100)
        mp_node:setVisible(false)
        --enery:setVisible(false)
        local str = 0
        if cooltime > 1 then
            str = math.floor(cooltime)
            str = string.format("%d",str)
        else
            str = math.floor(cooltime*10)
            str = str / 10
            str = string.format("%2.1f",str)
        end
        time:setString(str)
        pro:setVisible(true)
        time:setVisible(true)
        btn:setEnabled(false)
        btn_Circle:setVisible(true)
    else
        mp_node:setVisible(false)
       -- enery:setVisible(false)
        pro:setVisible(false)
        time:setVisible(false)
        btn:setEnabled(true)
        btn_Circle:setVisible(false)
    end
end

function FightTouchPad2:UpdateProgressPowerUp(cooltime,max,upTimes,upMaxTimes,index)
    local btn = self.Button_skill_Table[index]["btn"]
    local btn_bg = self.Button_skill_Table[index]["Image"]
    local btn_Circle = self.Button_skill_Table[index]["Image_Circle"]
    local pro = self.Button_skill_Table[index]["aniBar_100"]
    if not pro then return  end
    pro:setPercentage((cooltime/max)*100)
    local time = self.Button_skill_Table[index]["lb_1000"]
    --local enery = self.Button_skill_Table[index]["lben_10000"]
    local mp_node = self.Button_skill_Table[index]["nodespine"]
    mp_node:setVisible(false)
    --enery:setVisible(true)
    btn_Circle:setVisible(false)
    if upTimes == 0 and cooltime > 0 then
        local str = 0
        if cooltime > 1 then
            str = math.floor(cooltime)
            str = string.format("%d",str)
        else
            str = math.floor(cooltime*10)
            str = str / 10
            str = string.format("%2.1f",str)
        end
        pro:setVisible(true)
        time:setVisible(true)
        time:setString(str)
        btn:setEnabled(false)
        btn_Circle:setVisible(true)
        --enery:setString(tostring(upTimes))
        self:ShowPowerPoints(upMaxTimes,upTimes,index)
    elseif upTimes == upMaxTimes then
      self:ShowPowerPoints(upMaxTimes,upTimes,index)
        --enery:setString(tostring(upMaxTimes))
        btn:setEnabled(true)
        btn_Circle:setVisible(false)
        pro:setVisible(false)
        time:setVisible(false)
    else
        local str = 0
        if cooltime > 1 then
            str = math.floor(cooltime)
            str = string.format("%d",str)
        else
            str = math.floor(cooltime*10)
            str = str / 10
            str = string.format("%2.1f",str)
        end
        time:setVisible(true)
        pro:setVisible(true)
        time:setString(str)
        btn:setEnabled(true)
        btn_Circle:setVisible(false)
        --enery:setString(tostring(upTimes))
        self:ShowPowerPoints(upMaxTimes,upTimes,index)
    end  
end

function FightTouchPad2:UpdateProgressCostMp(cooltime,max,upTimes,upMaxTimes,index)
    local btn = self.Button_skill_Table[index]["btn"]
    local btn_bg = self.Button_skill_Table[index]["Image"]
    local btn_Circle = self.Button_skill_Table[index]["Image_Circle"]
    local pro = self.Button_skill_Table[index]["aniBar_100"]
    if not pro then return  end
    local time = self.Button_skill_Table[index]["lb_1000"]
    --local enery = self.Button_skill_Table[index]["lben_10000"]
    --enery:setVisible(false)
    local mp_node = self.Button_skill_Table[index]["nodespine"]
    mp_node:setVisible(false)
    
    btn_Circle:setVisible(false)
    if upTimes and upTimes > 0 then
        if not pro then return  end
        pro:setPercentage((upTimes/upMaxTimes)*100)
        local str = 0
        if upTimes > 1 then
            str = math.floor(upTimes)
            str = string.format("%d",str)
        else
            str = math.floor(upTimes*10)
            str = str / 10
            str = string.format("%2.1f",str)
        end
        time:setString(str)
        pro:setVisible(true)
        time:setVisible(true)
        btn:setEnabled(false)
        btn_Circle:setVisible(true)
    else
        pro:setVisible(false)
        time:setVisible(false)
        if cooltime <= 0 then 
          btn:setEnabled(true)
          btn_Circle:setVisible(false)
          mp_node:setVisible(true)
        else
          pro:setVisible(true)
          pro:setPercentage(((max-cooltime)/max)*100)
          btn:setEnabled(false)
          btn_Circle:setVisible(true)
          mp_node:setVisible(false)
        end
    end
end

-- 闯关的时候隐藏按钮
function FightTouchPad2:HideBraveBtn()
    self.mRootWidget:getChildByName("CheckBox_Weapon"):setVisible(false)
end

-- OlPvp隐藏界面暂停按钮
function FightTouchPad2:HideOlPvpBtn()
    if self.KofMiddlewidget then
      self.KofMiddlewidget:getChildByName("Button_Pause"):setVisible(false)
    end
    self.mRootWidget:getChildByName("CheckBox_Auto"):setVisible(false)
    self.mRootWidget:getChildByName("CheckBox_Weapon"):setVisible(false)
end

-- PVP的时候隐藏按钮
function FightTouchPad2:HidePvpBtn()
    local a1 = self.mRootWidget:getChildByName("Leftdown_Node")
    a1:setVisible(false)
    a1 = self.mRootWidget:getChildByName("Rightdown_Node")
    self.mRootWidget:getChildByName("CheckBox_Auto"):setVisible(false)
    self.mRootWidget:getChildByName("CheckBox_Weapon"):setVisible(false)
    a1 = self.mRootWidget:getChildByName("Rightdown_Node")
    a1:setVisible(false)
    self:disabled(true)
end

-- PVP的时候初始化人物血条
function FightTouchPad2:InitPvpPkEnemyHead()
    local a1 = self.mRootWidget:getChildByName("Rightup_Node")
    a1:getChildByName("Panel_Hero_PVP"):setVisible(true)

    local _count = globaldata:getBattleEnemyFormationCount()
    self.EnemyCount = _count
    for i=1,_count do
      self:AddHeroHeadForArena(i)
    end
end

-- PVP游乐园的时候初始化人物血条
function FightTouchPad2:InitBraveHead2()
   self.mLU_Node:getChildByName("Button_Timeout"):setVisible(true)
   self.mLU_Node:getChildByName("Image_TimeBg"):setVisible(true)
   self.mLU_Node:getChildByName("Image_Drop_Bg"):setVisible(false)
   self.mLU_Node:getChildByName("Image_Gold_Bg"):setVisible(false)
   self.mLU_Node:getChildByName("Panel_Hero"):setVisible(true)
   self.mLD_Node:setVisible(true)
   self.mRD_Node:setVisible(true)
   self.mRootWidget:getChildByName("CheckBox_Weapon"):setVisible(false)
    local a1 = self.mRootWidget:getChildByName("Rightup_Node")
    a1:getChildByName("Panel_Hero_PVP"):setVisible(true)

    local _count = globaldata:getBattleEnemyFormationCount()
    self.EnemyCount = _count
    for i=1,_count do
      self:AddHeroHeadForBrave(i)
    end
end

-- 设置竞技场UI显示
function FightTouchPad2:ArenaUI()
   self.mLU_Node:getChildByName("Button_Timeout"):setVisible(false)
   self.mLU_Node:getChildByName("Image_TimeBg"):setVisible(false)
   self.mLU_Node:getChildByName("Image_Drop_Bg"):setVisible(false)
   self.mLU_Node:getChildByName("Image_Gold_Bg"):setVisible(false)
   self.mLU_Node:getChildByName("Panel_Hero"):setVisible(true)
   self.mMD_Node:getChildByName("Image_TimeBg"):setVisible(true)
   self.mLD_Node:setVisible(true)
   self.mRD_Node:setVisible(true)
   self.mRootWidget:getChildByName("CheckBox_Weapon"):setVisible(false)
end


-- 竞技场血条2
function FightTouchPad2:InitArenaHead2()
  self:ArenaUI()
  self:InitPvpPkEnemyHead()
end

-- 世界bossUI
function FightTouchPad2:InitWorldBossUI()
    self.mRootWidget:getChildByName("CheckBox_Weapon"):setVisible(false)
end

-- 展示关卡UI
function FightTouchPad2:InitShowPveUI()
   self.mLD_Node:setVisible(false)
   self.mRD_Node:setVisible(false)
   self.mLU_Node:getChildByName("Button_Timeout"):setVisible(false)
   self.mLU_Node:getChildByName("Image_TimeBg"):setVisible(false)
   self.mLU_Node:getChildByName("Image_Drop_Bg"):setVisible(false)
   self.mLU_Node:getChildByName("Image_Gold_Bg"):setVisible(false)
   self.mLU_Node:getChildByName("Panel_Hero"):setVisible(true)
   self.mRootWidget:getChildByName("CheckBox_Weapon"):setVisible(false)
   self:InitPvpPkEnemyHead()
   local function Tiaoguo( ... )
      if not globaldata.showguanqialayer then
        FightSystem:GetFightManager().mShowPveController:ShowPveOver()
      end
   end
   local  timeoutbtn = self.mLU_Node:getChildByName("Button_TiaoGuo")
   registerWidgetReleaseUpEvent(timeoutbtn,Tiaoguo)
   timeoutbtn:setVisible(true)

   for k,v in pairs(self.mEnemyBtnList) do
     v.HeroIcon:getChildByName("Image_SuperHero"):setVisible(false)
   end

   for k,v in pairs(self.mHeadBtnList) do
     v.HeroIcon:getChildByName("Image_SuperHero"):setVisible(false)
   end



end

-- 竞技场血条
function FightTouchPad2:InitArenaHead()  
  self:ArenaUI()
  self.mMD_Node:setVisible(true)
  self.mArenaBg = GUIWidgetPool:createWidget("FightArena")
  self.mMU_Node:addChild(self.mArenaBg,100)

  local x = self.mArenaBg:getChildByName("Panel_Main"):getBoundingBox().width/2
  local y = self.mArenaBg:getChildByName("Panel_Main"):getBoundingBox().height
  self.mArenaBg:getChildByName("Panel_Main"):setPosition(-x,-y)
  self.mArenaFriendHead = {}
  self.mArenaEnemyHead = {}

  local Leftbtn = self.mArenaBg:getChildByName("Button_ArrowLeft")
  local Rightbtn = self.mArenaBg:getChildByName("Button_ArrowRight")
  registerWidgetReleaseUpEvent(Leftbtn,handler(self,self.OnClickArenaEventLeft))
  registerWidgetReleaseUpEvent(Rightbtn,handler(self,self.OnClickArenaEventRight))

  for i=1,3 do
    local panel = self.mArenaBg:getChildByName(string.format("Panel_Battle_%d",i))
    panel:setTag(i)
    registerWidgetReleaseUpEvent(panel,handler(self,self.OnClickArenaEvent))
    if globaldata:getBattleFormationInfoByIndex(i) then
        local data = globaldata:getBattleFormationInfoByIndex(i)
        local role = FightSystem.mRoleManager:FindFriendRoleById(i)
        local head = GUIWidgetPool:createWidget("FightArenaHead")
        panel:getChildByName("Panel_Hero_1"):addChild(head)
        self.mArenaFriendHead[i] = head
        local Icon = createHeroIcon(data.id, data.level, data.quality, data.advanceLevel)
        Icon:getChildByName("Panel_Star"):setVisible(false)
        head:getChildByName("Panel_Hero"):addChild(Icon)
        local imgName = DB_ResourceList.getDataById(role.mRoleData.mInfoDB.IconID).Res_path1
        head:getChildByName("Image_HeroHead"):loadTexture(imgName, 1)
        head:getChildByName("ProgressBar_Blood"):setPercent(100)
        head:getChildByName("ProgressBar_Blood"):setColor(getBloodColor(100))
        --self:InitFriendsArena(i,1,i,role)
    end
    --[[
    if globaldata:getBattleFormationInfoByIndex(i+3) then
        local data = globaldata:getBattleFormationInfoByIndex(i+3)
        local role = FightSystem.mRoleManager:FindFriendRoleById(i+3)
        local head = GUIWidgetPool:createWidget("FightArenaHead")
        panel:getChildByName("Panel_Hero_2"):addChild(head)
        self.mArenaFriendHead[i+3] = head
        local Icon = createHeroIcon(data.id, data.level, data.quality, data.advanceLevel)
        Icon:getChildByName("Image_LeveBg"):setVisible(false)
        Icon:getChildByName("Panel_Star"):setVisible(false)
        head:getChildByName("Panel_Hero"):addChild(Icon)
        local imgName = DB_ResourceList.getDataById(role.mRoleData.mInfoDB.IconID).Res_path1
        head:getChildByName("Image_HeroHead"):loadTexture(imgName, 1)
        head:getChildByName("ProgressBar_Blood"):setPercent(100)
        head:getChildByName("ProgressBar_Blood"):setColor(getBloodColor(100))
        self:InitFriendsArena(i,2,i+3,role)
    end
    ]]
    if globaldata:getBattleEnemyFormationInfoByIndex(i) then
        local data = globaldata:getBattleEnemyFormationInfoByIndex(i)
        local role = FightSystem.mRoleManager:FindEnemyRoleById(i)
        local head = GUIWidgetPool:createWidget("FightArenaHead")
        panel:getChildByName("Panel_Enemy_1"):addChild(head)
        self.mArenaEnemyHead[i] = head
        local Icon = createHeroIcon(data.id, data.level, data.quality, data.advanceLevel)
        Icon:getChildByName("Panel_Star"):setVisible(false)
        head:getChildByName("Panel_Hero"):addChild(Icon)
        local imgName = DB_ResourceList.getDataById(role.mRoleData.mInfoDB.IconID).Res_path1
        head:getChildByName("Image_HeroHead"):loadTexture(imgName, 1)
        head:getChildByName("ProgressBar_Blood"):setPercent(100)
        head:getChildByName("ProgressBar_Blood"):setColor(getBloodColor(100))
        --self:InitEnemysArena(i,1,i,role)
    end
    --[[
    if globaldata:getBattleEnemyFormationInfoByIndex(i+3) then
        local data = globaldata:getBattleEnemyFormationInfoByIndex(i+3)
        local role = FightSystem.mRoleManager:FindEnemyRoleById(i+3)
        local head = GUIWidgetPool:createWidget("FightArenaHead")
        panel:getChildByName("Panel_Enemy_2"):addChild(head)
        self.mArenaEnemyHead[i+3] = head
        local Icon = createHeroIcon(data.id, data.level, data.quality, data.advanceLevel)
        Icon:getChildByName("Image_LeveBg"):setVisible(false)
        Icon:getChildByName("Panel_Star"):setVisible(false)
        head:getChildByName("Panel_Hero"):addChild(Icon)
        local imgName = DB_ResourceList.getDataById(role.mRoleData.mInfoDB.IconID).Res_path1
        head:getChildByName("Image_HeroHead"):loadTexture(imgName, 1)
        head:getChildByName("ProgressBar_Blood"):setPercent(100)
        head:getChildByName("ProgressBar_Blood"):setColor(getBloodColor(100))
        self:InitEnemysArena(i,2,i+3,role)
    end
    ]]
  end
  self.ArenaTouchTag = 1
  self:setVisArenaHead(self.ArenaTouchTag)
  -- HeroHead
end

function FightTouchPad2:InitFriendsArena2(index,_role)
      
      local widget = GUIWidgetPool:createWidget("FightHero")
      local head ={}
      head.btn = widget
      head.btn:setTag(index)

      local root = self.mLU_Node:getChildByName(string.format("Panel_Pvp_friend%d",_Sceneindex)):getChildByName(string.format("Panel_Head%d",_playindex))
      root:addChild(head.btn,100)
      
      local imgName = DB_ResourceList.getDataById(_role.mRoleData.mInfoDB.IconID).Res_path1

      local data = globaldata:getBattleFormationInfoByIndex(_role.mPosIndex)
      local Icon = createHeroIcon(data.id, data.level, data.quality, data.advanceLevel)
      Icon:getChildByName("Image_LeveBg"):setVisible(false)
      Icon:getChildByName("Panel_Star"):setVisible(false)
      head.btn:getChildByName("Panel_HeroIcon"):addChild(Icon) 
      head.HeroIcon = Icon
      head.progress = WidgetProgressBar.new("fight_hero_blood.png","fight_hero_blood_bg.png","right")
      head.progress:setPosition(cc.p(0,0))
      head.progress:setValue(100,100,false)
      head.btn:getChildByName("Image_Hero_blood_bg"):addChild(head.progress)
      head[index] = head
      head.isLive = true
      head.Posindex = index

      if not self.mHeadArenaFriendList then
          self.mHeadArenaFriendList = {}
      end
      self.mHeadArenaFriendList[index] = head
      registerWidgetReleaseUpEvent(head.btn,handler(self,self.OnClickHeadEvent))
end

function FightTouchPad2:InitEnemysArena2(index,_role)
      local widget = GUIWidgetPool:createWidget("FightHero")
      local head ={}
      head.btn = widget
      head.btn:setTag(index)

      local root = self.mRU_Node:getChildByName(string.format("Panel_Pvp_enemy%d",_Sceneindex)):getChildByName(string.format("Panel_Head%d",_playindex))
      root:addChild(head.btn,100)
      local data = globaldata:getBattleEnemyFormationInfoByIndex(index)
      local Icon = createHeroIcon(data.id, data.level, data.quality, data.advanceLevel)
      Icon:getChildByName("Image_LeveBg"):setVisible(false)
      Icon:getChildByName("Panel_Star"):setVisible(false)
      head.btn:getChildByName("Panel_HeroIcon"):addChild(Icon)
      head.HeroIcon = Icon
      head.progress = WidgetProgressBar.new("fight_hero_blood.png","fight_hero_blood_bg.png","right")
      head.progress:setPosition(cc.p(0,0)) 
      head.progress:setValue(100,100,false)
      head.btn:getChildByName("Image_Hero_blood_bg"):addChild(head.progress)
      head[index] = head
      head.isLive = true
      head.Posindex = index

      if not self.mHeadArenaEnemyList then
          self.mHeadArenaEnemyList = {}
      end 
      self.mHeadArenaEnemyList[index] = head
      
end


function FightTouchPad2:InitFriendsArena(_Sceneindex,_playindex,index,_role)
      --[[
      local widget = GUIWidgetPool:createWidget("FightHero")
      local head ={}
      head.btn = widget:getChildByName("Image_Headframe"):clone()
      head.btn:setTag(index)

      local root = self.mLU_Node:getChildByName(string.format("Panel_Pvp_friend%d",_Sceneindex)):getChildByName(string.format("Panel_Head%d",_playindex))
      root:addChild(head.btn,100)
      
      local imgName = DB_ResourceList.getDataById(_role.mRoleData.mInfoDB.IconID).Res_path1

      local data = globaldata:getBattleFormationInfoByIndex(_role.mPosIndex)
      local Icon = createHeroIcon(data.id, data.level, data.quality, data.advanceLevel)
      Icon:getChildByName("Image_LeveBg"):setVisible(false)
      Icon:getChildByName("Panel_Star"):setVisible(false)
      head.btn:getChildByName("Panel_HeroIcon"):addChild(Icon) 
      head.progress = WidgetProgressBar.new("fight_hero_blood.png","fight_hero_blood_bg.png","right")
      head.progress:setPosition(cc.p(0,0))
      head.progress:setValue(100,100,false)
      head.btn:getChildByName("Image_Hero_blood_bg"):addChild(head.progress)
      head[index] = head
      head.isLive = true
      head.Posindex = index

      if not self.mHeadArenaFriendList then
          self.mHeadArenaFriendList = {}
      end
      self.mHeadArenaFriendList[index] = head
      registerWidgetReleaseUpEvent(head.btn,handler(self,self.OnClickHeadEvent))
      ]]
end

function FightTouchPad2:InitEnemysArena(_Sceneindex,_playindex,index,_role)
      --[[
      local widget = GUIWidgetPool:createWidget("FightHero")
      local head ={}
      head.btn = widget:getChildByName("Image_Headframe"):clone()
      head.btn:setTag(index)

      local root = self.mRootWidget:getChildByName("Rightup_Node"):getChildByName(string.format("Panel_Pvp_enemy%d",_Sceneindex)):getChildByName(string.format("Panel_Head%d",_playindex))

      root:addChild(head.btn,100)


      local data = globaldata:getBattleEnemyFormationInfoByIndex(index)
      local Icon = createHeroIcon(data.id, data.level, data.quality, data.advanceLevel)
      Icon:getChildByName("Image_LeveBg"):setVisible(false)
      Icon:getChildByName("Panel_Star"):setVisible(false)
      head.btn:getChildByName("Panel_HeroIcon"):addChild(Icon)

      head.progress = WidgetProgressBar.new("fight_hero_blood.png","fight_hero_blood_bg.png","right")
      head.progress:setPosition(cc.p(0,0)) 
      head.progress:setValue(100,100,false)
      head.btn:getChildByName("Image_Hero_blood_bg"):addChild(head.progress)
      head[index] = head
      head.isLive = true
      head.Posindex = index

      if not self.mHeadArenaEnemyList then
          self.mHeadArenaEnemyList = {}
      end 
      self.mHeadArenaEnemyList[index] = head
      ]]
end

function FightTouchPad2:setVisArenaHead(_Sceneindex)
  
end

function FightTouchPad2:OnClickArenaEvent(_widget)
    if _widget:getTag() == self.ArenaTouchTag then
        return
    else
        FightSystem.mSceneManager.mArenaViewIndex = _widget:getTag()
        local panel = self.mArenaBg:getChildByName(string.format("Panel_Battle_%d",self.ArenaTouchTag))
        panel:getChildByName("Image_Bg"):setVisible(true)
        panel:getChildByName("Image_Bg1"):setVisible(false)
        _widget:getChildByName("Image_Bg"):setVisible(false)
        _widget:getChildByName("Image_Bg1"):setVisible(true)
        FightSystem.mSceneManager:GetSceneView(self.ArenaTouchTag):setVisible(false)
        FightSystem.mSceneManager:GetSceneView(_widget:getTag()):setVisible(true)
        self.ArenaTouchTag = _widget:getTag()
        self:FindArenaHold(self.ArenaTouchTag)
        self:setVisArenaHead(self.ArenaTouchTag)
    end
end

function FightTouchPad2:FindArenaHold(_sceneindex)
     local CurScenerole = nil
     local friend = FightSystem.mRoleManager:GetFriendTable(_sceneindex)
     if friend and #friend ~= 0 then
      for k,v in pairs(friend) do
        if v.mPosIndex == _sceneindex then
          CurScenerole = v
          break
        else
          CurScenerole = v
        end
      end
      --self:SetRoleKey(CurScenerole.mPosIndex)
      self.mLastHeadTag = CurScenerole.mPosIndex
      --self.mLD_Node:setVisible(true)
      --self.mRD_Node:setVisible(true)
     else
      self.mHolder = nil
      --self.mLD_Node:setVisible(false)
      --self.mRD_Node:setVisible(false)
     end
end

function FightTouchPad2:OnClickArenaEventLeft(_widget)
    local Tag = self.ArenaTouchTag -1
    if Tag <= 0 then
      Tag = 3
    end
    self:ChangeArenaEvent(self.ArenaTouchTag,Tag)
end

function FightTouchPad2:OnClickArenaEventRight(_widget)
    local Tag = self.ArenaTouchTag + 1
    if Tag >= 4 then
      Tag = 1
    end
    self:ChangeArenaEvent(self.ArenaTouchTag,Tag)
end

function FightTouchPad2:FindArenaEvent(_result)

    if _result and _result == self.ArenaTouchTag then
        local Tag = _result + 1
        if Tag >= 4 then
            Tag = 1
        end
        self:ChangeArenaEvent(_result,Tag)
    end
end

function FightTouchPad2:ChangeArenaEvent(_oldindex,_newindex)
        FightSystem.mSceneManager.mArenaViewIndex = _newindex
        local panel = self.mArenaBg:getChildByName(string.format("Panel_Battle_%d",_oldindex))
        panel:getChildByName("Image_Bg"):setVisible(true)
        panel:getChildByName("Image_Bg1"):setVisible(false)
        local widget = self.mArenaBg:getChildByName(string.format("Panel_Battle_%d",_newindex))
        widget:getChildByName("Image_Bg"):setVisible(false)
        widget:getChildByName("Image_Bg1"):setVisible(true)
        FightSystem.mSceneManager:GetSceneView(_oldindex):setVisible(false)
        FightSystem.mSceneManager:GetSceneView(_newindex):setVisible(true)
        self.ArenaTouchTag = _newindex
        self:FindArenaHold(self.ArenaTouchTag)
        self:setVisArenaHead(self.ArenaTouchTag)
end

function FightTouchPad2:disabled(_flag)
   self.mDisabled = _flag
end

-- 玩家死了
function FightTouchPad2:OnFriendDead(_role)
   --cclog("OnFriendDead===" .. _role.mPosIndex)
    if FightSystem:GetFightManager().mResult then return end
    if FightSystem.mFightType == "fuben" then
      self:OnFriendDeadFubenAddsub(_role)
    elseif FightSystem.mFightType == "arena" then
      self:OnFriendDeadArena(_role)
    end
end

-- 闪烁移除玩家
function FightTouchPad2:OnFadeoutFriendDead(_role)
    if FightSystem.mFightType == "arena" and self:IsArenaVision() then

      local friend = FightSystem.mRoleManager:GetFriendTable(_role.mSceneIndex)
      if #friend == 1 then
        self:SetArenaAction(_role.mSceneIndex,2)
      end
    end
end

-- 闪烁移除敌人
function FightTouchPad2:OnFadeoutEnemyplayerDead(_role)
    if FightSystem.mFightType == "arena" and self:IsArenaVision() then
      
      local enemy = FightSystem.mRoleManager:GetEnemyTable(_role.mSceneIndex)
      if #enemy == 1 then
        self:SetArenaAction(_role.mSceneIndex,1)
      end
    end
end

function FightTouchPad2:OnFriendDeadArena(_role)
    if FightSystem.mFightType == "olpvp" then
      return
    end

    if globaldata.fubenstar < 1 then globaldata.fubenstar = 1 end
    if self:IsKofVision() then
      if self.mSubstitutionCount > 0 then
            self.mHolder = FightSystem.mRoleManager:LoadFriendRoles(_role.mPosIndex +1 , self.mHolder:getShadowPos())
            --self.mHolder.IsKeyRole = true
            self.mHolder:Up_Bench(_role:getShadowPos().x,_role:getShadowPos().y)
           -- self.mHolder.mSkillCon:SetFinishSkillCallBackHandler("FightTouchPad2", handler(self, self.OnSkillFinish))
            --self:ResetAttack()
            self.mSubstitutionCount = self.mSubstitutionCount - 1
            self:SetRoleKey(self.mHolder.mPosIndex)
            if FightSystem.mFightType == "arena" and globaldata.PvpType == "brave" then
              FightSystem:GetFightManager():resetTime()
            end
        else
           self.mHolder = nil
           self.mResultTick = false
           self:disabled(true)
           FightSystem:GetFightManager():Result("fail")
        end
        self:ShowTeamsCount(_role.mGroup ,_role.mPosIndex+1)
    elseif self:IsArenaVision() then
        self.mHeadBtnList[_role.mPosIndex].isLive = false
        self.mHeadBtnList[_role.mPosIndex].btn:getChildByName("Panel_SelectAnimation"):setVisible(false)
        self.mHeadBtnList[_role.mPosIndex].btn:setEnabled(false)
        self.mHeadBtnList[_role.mPosIndex].btn:getChildByName("Panel_HeroIcon"):getChildByName("Image_HeroDead"):setVisible(true)
        local x = false
          for k,v in pairs(self.mHeadBtnList) do
              if v.isLive then
                  self.mHeadBtnList[k].btn:setEnabled(true)
                  self.mHeadBtnList[k].btn:getChildByName("Panel_SelectAnimation"):setVisible(true)

                  self:SetRoleKey(v.Posindex)
                  x = true
                  break
              end 
          end
          if not x then 
             self.mHolder = nil
             self.mResultTick = false
             self:disabled(true)

             FightSystem:GetFightManager():Result("fail")     
          end
    else
      self.mHeadBtnList[_role.mPosIndex].isLive = false
      self.mHeadBtnList[_role.mPosIndex].btn:getChildByName("Panel_HeroIcon"):getChildByName("Image_HeroDead"):setVisible(true)
      self.mHeadBtnList[_role.mPosIndex].btn:getChildByName("Panel_SelectAnimation"):setVisible(false)
      self.mHeadBtnList[_role.mPosIndex].btn:setEnabled(false)

      local x = false
        for k,v in pairs(self.mHeadBtnList) do
            if v.isLive then
                self.mHeadBtnList[k].btn:setEnabled(true)
                self.mHeadBtnList[k].btn:getChildByName("Panel_SelectAnimation"):setVisible(true)

                self:SetRoleKey(v.Posindex)
                x = true
                break
            end 
        end
        if not x then 
           self.mHolder = nil
           self.mResultTick = false
           self:disabled(true)

           FightSystem:GetFightManager():Result("fail")     
        end
    end
end

-- 设置胜负特效
function FightTouchPad2:SetArenaAction(_Sceneindex,_type)

    local resultw = self.mArenaBg:getChildByName(string.format("Image_Result_%d",_Sceneindex))
    if not resultw:isVisible() then
      if _type == 2 then
        resultw:loadTexture("arena_result_lose.png")
      end
      resultw:setVisible(true)
      resultw:setScale(5)
      resultw:setOpacity(0)
      local act0 = cc.ScaleTo:create(0.15, 1)
      local act1 = cc.FadeIn:create(0.15)
      local act2 = cc.Spawn:create(act0, act1)
      resultw:runAction(cc.Sequence:create(act2))
    end
end

function FightTouchPad2:GetAreaIndex(index)
    if index == 1 or index == 4 then
      return 1
    elseif index == 2 or index == 5 then
      return 2
    elseif index == 3 or index == 6 then
      return 3
    end 
end

function FightTouchPad2:OnFriendDeadFubenAddsub(_role)
    if self:IsKofVision() then
        if self.mSubstitutionCount > 0 then
            self.mHolder = FightSystem.mRoleManager:LoadFriendRoles(_role.mPosIndex +1 , self.mHolder:getShadowPos())
            --self.mHolder.IsKeyRole = true
            self.mHolder:Up_Bench(_role:getShadowPos().x,_role:getShadowPos().y)
			      --self.mHolder.mSkillCon:SetFinishSkillCallBackHandler("FightTouchPad2", handler(self, self.OnSkillFinish))

            self.mSubstitutionCount = self.mSubstitutionCount - 1
            self:SetRoleKey(self.mHolder.mPosIndex)
        else
           self.mHolder = nil
           self.mResultTick = false
           self:disabled(true)
           FightSystem:GetFightManager():Result("fail")
        end
        self:ShowTeamsCount(_role.mGroup ,_role.mPosIndex+1)
        return
    end
    local btnindex = self:FindBtnByPos(_role.mPosIndex)
    self.mHeadBtnList[btnindex].isLive = false
    self.mHeadBtnList[btnindex].btn:getChildByName("Panel_HeroIcon"):getChildByName("Image_HeroDead"):setVisible(true)
    self.mHeadBtnList[btnindex].btn:getChildByName("Panel_SelectAnimation"):setVisible(false)
    self.mHeadBtnList[btnindex].btn:setEnabled(false)

    if self.mSubstitutionCount > 0 then
         if  _role.mPosIndex == self.mHolder.mPosIndex then

            local index = self:getMaxHeroIndex()

            local role = FightSystem.mRoleManager:LoadFriendRoles(index +1 , self.mHolder:getShadowPos())
            if FightSystem:GetFightManager().mFubenModel == 6 then
              role:AddBuff(103)
            end
            self.mHolder = role
            role:Up_Bench(_role:getShadowPos().x,_role:getShadowPos().y)
            local btnindex = self:FindBtnByPos(_role.mPosIndex)

            self.mHeadBtnList[btnindex].btn:setTag(index +1)

            local imgName = DB_ResourceList.getDataById(role.mRoleData.mInfoDB.IconID).Res_path1

            self.mHeadBtnList[btnindex].btn:getChildByName("Image_HeroIcon"):loadTexture(imgName, 1)
            
            self.mHeadBtnList[btnindex].progress:setValue(100,100,false)
            self.mHeadBtnList[btnindex].isLive = true
            self.mHeadBtnList[btnindex].btn:getChildByName("Panel_SelectAnimation"):setVisible(true)
            self.mHeadBtnList[btnindex].Posindex = index +1
            self.mHeadBtnList[btnindex].btn:setEnabled(true)

            self:SetRoleKey(index +1) 
            self.mSubstitutionCount = self.mSubstitutionCount - 1 
         else
            local index = self:getMaxHeroIndex()

            local role = FightSystem.mRoleManager:LoadFriendRoles(index +1 , _role:getShadowPos())
            if FightSystem:GetFightManager().mFubenModel == 6 then
              role:AddBuff(103)
            end
            role:Up_Bench(_role:getShadowPos().x,_role:getShadowPos().y)
            local btnindex = self:FindBtnByPos(_role.mPosIndex)

            self.mHeadBtnList[btnindex].btn:setTag(index +1)

            local imgName = DB_ResourceList.getDataById(role.mRoleData.mInfoDB.IconID).Res_path1

            self.mHeadBtnList[btnindex].btn:getChildByName("Image_HeroIcon"):loadTexture(imgName, 1)
            
            self.mHeadBtnList[btnindex].progress:setValue(100,100,false)
            self.mHeadBtnList[btnindex].isLive = true
            self.mHeadBtnList[btnindex].btn:getChildByName("Panel_SelectAnimation"):setVisible(false)
            self.mHeadBtnList[btnindex].Posindex = index +1
            self.mHeadBtnList[btnindex].btn:setEnabled(true)
            self.mSubstitutionCount = self.mSubstitutionCount - 1 
         end
    else
        if FightSystem.mFightType == "fuben" then
            if FightSystem:GetFightManager():Seeklive() then
                 self.mHolder = nil
                 self.mResultTick = false
                 self:disabled(true)
                 FightSystem:GetFightManager():Result("fail")     
              return
            end
        end
        if _role.IsKeyRole then 
             local x = false
              for k,v in pairs(self.mHeadBtnList) do
                  if v.isLive then
                      self.mHeadBtnList[k].btn:setEnabled(true)
                      self.mHeadBtnList[k].btn:getChildByName("Panel_SelectAnimation"):setVisible(true)

                      self:SetRoleKey(v.Posindex)
                      x = true
                      break
                  end 
              end
              if not x then 
                 self.mHolder = nil
                 self.mResultTick = false
                 self:disabled(true)
                 FightSystem:GetFightManager():Result("fail")     
              end
        end
    end
    self:UpdateFitSkill()
end

-- 失败处理
function FightTouchPad2:ResultComplete()
     self.mHolder = nil
     self.mResultTick = false
     self:disabled(true)
end

function FightTouchPad2:OnEnemyplayerDead( _role )
    --cclog("OnFriendDead===" .. _role.mPosIndex)
    if FightSystem:GetFightManager().mResult then return end
    if FightSystem.mFightType == "olpvp" or FightSystem.mFightType == "fuben" then
      return
    end
    if self:IsKofVision() then
      if self.mSubstitutionEnemyCount > 0 then
            local role = FightSystem.mRoleManager:LoadEnemyPlayer(_role.mPosIndex +1 , _role:getShadowPos())
            role:Up_Bench(_role:getShadowPos().x,_role:getShadowPos().y)
            self.mSubstitutionEnemyCount = self.mSubstitutionEnemyCount - 1
        end
        self:ShowTeamsCount(_role.mGroup ,_role.mPosIndex+1)
    elseif self:IsArenaVision() then
      --[[
      local enemy = FightSystem.mRoleManager:GetEnemyTable(_role.mSceneIndex)
      if #enemy == 1 then
       local result = FightSystem:GetFightManager():ArenaResult(_role.mSceneIndex,_role.mGroup)
       self:FindArenaEvent(result)
      end
      ]]
      self.mEnemyBtnList[_role.mPosIndex].btn:getChildByName("Panel_HeroIcon"):getChildByName("Image_HeroDead"):setVisible(true)
      self.mEnemyBtnList[_role.mPosIndex].isLive = false
    else
      -- self.mEnemyBtnList[_role.mPosIndex].isLive = false
      -- self.mEnemyBtnList[_role.mPosIndex].btn:getChildByName("Panel_SelectAnimation"):setVisible(false)
      -- self.mEnemyBtnList[_role.mPosIndex].btn:setEnabled(false)
    end
end

function FightTouchPad2:OnMonsterDead( _role )
end

function FightTouchPad2:getMaxHeroIndex()
    local max = 0
    for i=1,self.mCountPlayer do
         i = self.mHeadBtnList[i].Posindex
         if i > max then
            max = i
         end
    end
    return max
end

function FightTouchPad2:getMaxEnemyIndex()
    local max = 0
    for i=1,self.EnemyCount do
         i = self.mEnemyBtnList[i].Posindex
         if i > max then
            max = i
         end
    end
    return max
end

function FightTouchPad2:FindBtnByPos(_posIndex)
    for i=1,self.mCountPlayer do
         if self.mHeadBtnList[i].Posindex == _posIndex then
            return i
         end
    end
    return nil
end

function FightTouchPad2:FindEnemyBtnByPos(_posIndex)
    for i=1,self.EnemyCount do
         if self.mEnemyBtnList[i].Posindex == _posIndex then
            return i
         end
    end
    return nil
end

-- 恢复能按按钮显示
function FightTouchPad2:ResetShowSkill()
  self.SkillReferenceCount = 0
  self.AttackReferenceCount = 0
  self.MoveReferenceCount = 0
  for i=1,3 do
      self.mRD_Node:getChildByName(string.format("Panel_Skill_%d_Cover",i)):setVisible(false)
  end
  self.mRD_Node:getChildByName("Panel_Skill_Jump_Cover"):setVisible(false)
  self.mRD_Node:getChildByName("Panel_Skill_Attack_Cover"):setVisible(false)
  self.mLD_Node:getChildByName("Panel_Movetouch_Cover"):setVisible(false)
end

-- 禁用技能
function FightTouchPad2:DisabledSkill(enable,isreference)
  if not self.mHolder then return end
  if not isreference then
    if enable then
      self.SkillReferenceCount = self.SkillReferenceCount + 1
    else
      self.SkillReferenceCount = self.SkillReferenceCount - 1 
    end
    enable = self.SkillReferenceCount > 0
    for i=1,3 do
      local skillid = self.mHolder.mRoleData[string.format("mRole_SpecialSkill%d",i)]
      if self.mHolder.mRoleData:IsSkillActivateById(skillid) then
        self.mRD_Node:getChildByName(string.format("Panel_Skill_%d_Cover",i)):setVisible(enable)
      end
    end
    self.mRD_Node:getChildByName("Panel_Skill_Jump_Cover"):setVisible(enable)
  else
    for i=1,3 do
      local skillid = self.mHolder.mRoleData[string.format("mRole_SpecialSkill%d",i)]
      if self.mHolder.mRoleData:IsSkillActivateById(skillid) then
        self.mRD_Node:getChildByName(string.format("Panel_Skill_%d_Cover",i)):setVisible(enable)
      end
    end
    self.mRD_Node:getChildByName("Panel_Skill_Jump_Cover"):setVisible(enable)
  end
end

-- 禁用普攻
function FightTouchPad2:DisabledAttack(enable,isreference)
  if not isreference then
    if enable then
      self.AttackReferenceCount = self.AttackReferenceCount + 1
    else
      self.AttackReferenceCount = self.AttackReferenceCount - 1 
    end
    enable = self.AttackReferenceCount > 0
    self.mRD_Node:getChildByName("Panel_Skill_Attack_Cover"):setVisible(enable)
  else
    self.mRD_Node:getChildByName("Panel_Skill_Attack_Cover"):setVisible(enable)
  end
end
 

-- 禁用走
function FightTouchPad2:DisabledMove(enable,isreference)
   if not isreference then
    if enable then
      self.MoveReferenceCount = self.MoveReferenceCount + 1
    else
      self.MoveReferenceCount = self.MoveReferenceCount - 1 
    end
    enable = self.MoveReferenceCount > 0
    self.mIsControlMoving = enable
    self.mLD_Node:getChildByName("Panel_Movetouch_Cover"):setVisible(enable)
  else
    self.mIsControlMoving = enable
    self.mLD_Node:getChildByName("Panel_Movetouch_Cover"):setVisible(enable)
  end

end


--上传boss预警
function FightTouchPad2:BossWarning()
    CommonAnimation.PlayEffectId(5004)
    local function playStarFinish( selfAni )
      selfAni:destroy()
      self.mBossWarning = nil
    end
    self.mBossWarning = AnimManager:createAnimNode(8062)
    self:addChild(self.mBossWarning:getRootNode(), 200)
    self.mBossWarning:getRootNode():setPosition(getGoldFightPosition_Middle())
    self.mBossWarning:play("fight_bosscome",false,playStarFinish)
end

--初始化Boss血条
function FightTouchPad2:InitBossBar(monster)

    if self.mBossBar then
       return 
    end

    local name = getDictionaryText(monster.mRoleData.mInfoDB.Name)
    local headpath = DB_ResourceList.getDataById(monster.mRoleData.mInfoDB.Monster_Icon).Res_path1
    self.mBossBar = WidgetProgressBarBoss.new(headpath,name,"left")
    local xpos =  getGoldFightPosition_RU().x --(getGoldFightPosition_RU().x - getGoldFightPosition_LU().x)/2
    --self.mBossBar:setPosition(cc.p(xpos-50,getGoldFightPosition_RU().y-50))
    self.mRU_Node:getChildByName("Panel_MonsterPos"):addChild(self.mBossBar,1001)

    local pre =  ((monster.mPropertyCon.mCurHP) % monster.mPropertyCon.mRowHp) /monster.mPropertyCon.mRowHp *100
    if pre == 0 then
       pre = 100
    end
    local percount = math.ceil((monster.mPropertyCon.mCurHP)/monster.mPropertyCon.mRowHp)
    self.mBossBar:setValue(pre,percount)
    self.mBossBar.mInstanceID = monster.mRoleData.mInstanceID
end

-- 停止移动
function FightTouchPad2:stopMove()
    if self.mHolder then
      self.mHolder:OnFTCommand(FightConfig.DIRECTION_CMD.STOP)
      FightSystem:PushNotification("keyrolestopmoved")
      
    end
end