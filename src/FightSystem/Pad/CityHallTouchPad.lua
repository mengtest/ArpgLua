-- Name: CityHallTouchPad
-- Func: 主城触摸板
-- Author: Johny


CityHallTouchPad = class("CityHallTouchPad",function()
  return cc.Node:create()
end)

----------------------------------------------@控制板配置表-------------------------------------------------------------
--常量，可以在外部直接获取
-- 方向变化的有效距离
CityHallTouchPad.EFFECT_CHANGE_DIR = 10.0  


--[[
  操控板的指令
]]

-- 0:UNKNOWN  1:方向  2:按钮
CityHallTouchPad.TYPE = {UNKNOWN = 0, DR = 1, BTN = 2}


-- 9：按钮1  10：按钮2  11：按钮3  12：按钮4  13：按钮5
CityHallTouchPad.BTN_CMD = {STOP = 0, BTN1 = 1, BTN2 = 2, BTN3 = 3, BTN4 = 4, BTN5 = 5,BTN6 = 6}

-- 双击事件记录
clicked = false

------------------------------------------------------------------------------------------------------------------------

function CityHallTouchPad:ctor()
  local winsz = GG_GetWinSize()
  self.mRootWidget = nil     --FightUI
  self.mWidgetPadnode = nil  
  self.mWidgetPadMovenode = nil
  self.mPadnode = nil
  self.mPadMovenode = nil
  self._kb = nil
  self.progressblood = nil
  self.mBossBar = nil
  self.mCombotop = nil
  self.mCurDirection = 0
  self.mCurDeg = 0
  self.mBeganFlag = false
  self.mTypeName = "citytouch"
  --取消touch滑动标志
  self.mCancelledFlag = false
end

function CityHallTouchPad:Destroy()
  cclog("CityHallTouchPad:Destroy")
  self.mTouchRegion = nil

  self.mRootWidget = nil

  self.mWidgetPadnode = nil
  self.mWidgetPadMovenode = nil
  self.mPadnode = nil
  self.mPadMovenode = nil
  self.mIsAttackBtnDown = nil
  self._kb = nil 

  self:removeFromParent(true)
  TextureSystem:UnLoadPlist("res/image/fight/fight.plist")
  FightSystem:UnRegisterNotification("scenelayermoved", "CityHallTouchPad")
end


function CityHallTouchPad:onEnter()
   cclog("=====CityHallTouchPad:onEnter=====")
    -- 键盘，仅在PC上有效果
    local KB = require "FightSystem/Pad/PCKeyBoard"
    self._kb = KB.new("cityhall")
    self._kb:Init()
    self:addChild(self._kb)
    ---
end

function CityHallTouchPad:onExit()
   cclog("=====CityHallTouchPad:onExit=====")
   self:removeAllChildren()
end

function CityHallTouchPad:RegisterNodeEvent()
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

function CityHallTouchPad:Tick()
  self:ShowMemory()
end

function CityHallTouchPad:ShowMemory()
  if FightConfig.__DEBUG_MEMORY_ then
    self.mLD_Node:getChildByName("Label_memory"):setVisible(true)
    local count = string.format("%f==%f",EngineSystem.mCppAgent:getUsedMemory(),EngineSystem.mCppAgent:getAvailabeMemory())
    self.mLD_Node:getChildByName("Label_memory"):setString(count)
  end
end


function CityHallTouchPad:Init(zorder)
	cclog("=====CityHallTouchPad:Init=====1")
  TextureSystem:LoadPlist("res/image/fight/fight.plist")
  self:InitWidget()
  --
  self:setLocalZOrder(zorder)
  --
	self:InitLeftPad()

  self:RegisterNodeEvent()

  -- 
  self:initMyRolePos()

  --
  FightSystem:RegisterNotifaction("scenelayermoved", "CityHallTouchPad", handler(self, self.onSceneLayerMoved))
  
	cclog("====CityHallTouchPad:Init=====2")
end

-- 初始化坐标显示
function CityHallTouchPad:initMyRolePos()
    if not FightConfig.__DEBUG_CITYHALL_MYPOS then return end
    local _lb = ccui.Text:create()
    _lb:setLocalZOrder(2)
    self:addChild(_lb, 100)
    _lb:setAnchorPoint(cc.p(0, 0))
    _lb:setPosition(cc.p(0, 530))
    _lb:setFontSize(15)
    self.mMyRolePosDisplay = _lb

    --
    local _lb = ccui.Text:create()
    _lb:setLocalZOrder(2)
    self:addChild(_lb, 100)
    _lb:setAnchorPoint(cc.p(0, 0))
    _lb:setPosition(cc.p(0, 500))
    _lb:setFontSize(15)
    self.mSkyLayerPosDisplay = _lb
end

-- 设置坐标显示
function CityHallTouchPad:setMyRolePosDisplay(_pos)
   if not FightConfig.__DEBUG_CITYHALL_MYPOS then return end
   self.mMyRolePosDisplay:setString(string.format("My Position： (%f, %f)", _pos.x, _pos.y))
end

-- 给符合条件的第一个touch 标记为1
-- 之后判断仅标记为1的touch才给予行动
function CityHallTouchPad:InitLeftPad()
  --####Var
  local mVarDirChange = 0
  local mVarLastDir = -1
  local mHandlerRun = nil

  --####function

  --  检测是否达到有效变化距离
  -- #与上一次方向不同，直接重置
  -- #不然则计算是否移动了有效距离 
  -- #记录的方向永远与本次方向一致
  local function CanTouchMoved(_curPos, _prePos, _dir)
      if mVarLastDir ~= _dir then
         mVarDirChange = 0
         mVarLastDir = _dir
      else
         local _dis = cc.pGetDistance(_curPos, _prePos)
         mVarDirChange = mVarDirChange + _dis
         mVarLastDir = _dir
         return mVarDirChange >= FightTouchPad2.EFFECT_CHANGE_DIR
      end
  end

  -- 通知宿主行动
  local function MoveHolder(_dir, _deg)
      if self.mLastDeg == _deg then
      return end
      --
      self.mLastDir = _dir
      self.mLastDeg = _deg
      mVarDirChange = 0
      mVarLastDir = -1

      -- 指令系统测试
      local _cmd = string.format("cityhall_0_move_%d_%d", _dir, _deg)
      FCmdParseSystem.parseCommand(_cmd)
  end

  local function onTouchMoved(touch, event)
      local curLoc = touch:getLocation()
      -- self.mTouchEffect:setPosition(curLoc)

      -- 判断该触摸是否为有效触摸点
      if self.mCancelledFlag then return end
      if touch.identifier ~= 1 then return end
      local _deg = MathExt.GetDegreeWithTwoPoint(curLoc, self.mTouchFristPoint)
      local _dir = FightConfig.GetDirectionByDegree(_deg)
      self:setCurDirection(_dir, _deg)
      MoveHolder(_dir, _deg)
      --
      self:Movecontroller(curLoc)
  end

    local function onTouchBegan(touch, event)
          local curLoc = touch:getLocation()
          -- test
          -- self.mTouchEffect = cc.ParticleSystemQuad:create("res/particles/dianji.plist")
          -- self.mTouchEffect:setPosition(curLoc)
          -- self:addChild(self.mTouchEffect)
          
          -- if FightConfig.__DEBUG_TOUCH_BEGAN_POINT_ then
          --    local deltaPos = FightSystem:getCurrentViewOffset()
          --     local pos = cc.p(curLoc.x  - deltaPos.x, curLoc.y - deltaPos.y)
          --     doError(string.format("POSX==%f,POSY==%f",pos.x,pos.y))
          --    return false
          -- end
          if not self.mTouchRegion then return false end
          FightSystem:PushNotification("hall_anytouch")
          if cc.rectContainsPoint(self.mTouchRegion, curLoc) then
              --cclog("POSX==" .. curLoc.x .. "POSY==" .. curLoc.y)
              self.mBeganFlag = true
              self.mCancelledFlag = false
              touch.identifier = 1
              mVarDirChange = 0
              mVarLastDir = -1
              self:MoveStart(curLoc) 
              onTouchMoved(touch, event)
              FightSystem.mTaskMainManager.mIsAutoFind = false
          end
          return true
    end

  local function onTouchEnded(touch, event)
      -- self.mTouchEffect:removeFromParent()
      if self.mCancelledFlag then return end
      if touch.identifier == 1 then
          self.mBeganFlag = false
          touch.identifier = nil
          self.mLastDeg = nil
          self:MoveEnd()
          self:setCurDirection(FightConfig.DIRECTION_CMD.STOP, 0)


          -- 指令系统测试
          local _cmd = string.format("cityhall_0_move_%d_%d", 0, 0)
          FCmdParseSystem.parseCommand(_cmd)
      end
  end

  local function onTouchCancelled(touch, event)
      cclog("=====onTouchCancelled======")
      if self.mCancelledFlag then return end
      if touch.identifier == 1 then
        self.mBeganFlag = false
        touch.identifier = nil
        self.mLastDeg = nil
        self:MoveEnd()

      -- 指令系统测试
      local _cmd = string.format("cityhall_0_move_%d_%d", 0, 0)
      FCmdParseSystem.parseCommand(_cmd)
      end
  end
  --#####

  --
	-- register touch event
	local listener = cc.EventListenerTouchOneByOne:create()
    --listener:setSwallowTouches(false)
    listener:registerScriptHandler(onTouchBegan,cc.Handler.EVENT_TOUCH_BEGAN )
    listener:registerScriptHandler(onTouchMoved,cc.Handler.EVENT_TOUCH_MOVED )
    listener:registerScriptHandler(onTouchEnded,cc.Handler.EVENT_TOUCH_ENDED )
    listener:registerScriptHandler(onTouchCancelled,cc.Handler.EVENT_TOUCH_CANCELLED )

    local eventDispatcher = self:getEventDispatcher()
    eventDispatcher:addEventListenerWithSceneGraphPriority(listener, self)
end

function  CityHallTouchPad:InitWidget()
    self.mRootWidget = GUIWidgetPool:createWidget("Fight")

    self:addChild(self.mRootWidget,100)

    self.mWidgetPadnode = self.mRootWidget:getChildByName("Image_Movetouch_pad")
    self.mPadnode = self.mWidgetPadnode:clone()
    self:addChild(self.mPadnode,100)
    self.mPadnode:setVisible(false)
    self.mWidgetPadnode:setVisible(true)
    self.mLD_Node = self.mRootWidget:getChildByName("Leftdown_Node")


    self.mWidgetPadMovenode = self.mRootWidget:getChildByName("Image_Movetouch_node")
    self.mPadMovenode = self.mWidgetPadMovenode:clone()
    self:addChild(self.mPadMovenode,101)
    self.mPadMovenode:setVisible(false)
    self.mWidgetPadMovenode:setVisible(true)

    local a1 = self.mRootWidget:getChildByName("Leftdown_Node")
    a1:setPosition(getGoldFightPosition_LD())

    local x = self.mWidgetPadnode:getPositionX()
    local y = self.mWidgetPadnode:getPositionY()

    local width = self.mWidgetPadnode:getBoundingBox().width
    local height = self.mWidgetPadnode:getBoundingBox().height

    self.mTouchRegion = cc.rect(x-width/2+getGoldFightPosition_LD().x, y-height/2+getGoldFightPosition_LD().y,width,height)

    self.mTouchFristPoint = cc.p(x+getGoldFightPosition_LD().x,y+getGoldFightPosition_LD().y)

    local xx = x-width/2+getGoldFightPosition_LD().x
    local yy = y-height/2+getGoldFightPosition_LD().y

    local a2 = self.mRootWidget:getChildByName("Leftup_Node")
    a2:setVisible(false)
    a2 = self.mRootWidget:getChildByName("Rightup_Node")
    a2:setVisible(false)
    a2 = self.mRootWidget:getChildByName("Rightdown_Node")
    a2:setVisible(false)

end

-- 取消touch滑动
function CityHallTouchPad:setCancelledTouch()
    self.mCancelledFlag = true  
    self.mBeganFlag = false
    self.mLastDeg = nil
    self:MoveEnd()
    self:setCurDirection(FightConfig.DIRECTION_CMD.STOP, 0)
   -- 指令系统测试
   if not FightSystem.mTaskMainManager.mIsAutoFind then
    local _cmd = string.format("cityhall_0_move_%d_%d", 0, 0)
    FCmdParseSystem.parseCommand(_cmd)
   end
end

function CityHallTouchPad:MoveStart(pos)
 -- self.mPadnode:setVisible(true)
  self.mPadMovenode:setVisible(true)
  --self.mPadnode:setPosition(pos)
  self.mPadMovenode:setPosition(pos)
  
  --self.mWidgetPadnode:setVisible(false)
  self.mWidgetPadMovenode:setVisible(false)
end

function CityHallTouchPad:Movecontroller(pos)
    self.mPadMovenode:setPosition(pos)
end

function CityHallTouchPad:MoveEnd()
  --self.mPadnode:setVisible(false)
  self.mPadMovenode:setVisible(false)
  --self.mWidgetPadnode:setVisible(true)
  self.mWidgetPadMovenode:setVisible(true)

  -- 通知HallManager
  FightSystem:PushNotification("hall_myrolestopmove")
  FightSystem:PushNotification("keyrolestopmoved")
end

function CityHallTouchPad:setCurDirection(_dir, _deg)
    self.mCurDirection = _dir
    self.mCurDeg = _deg
end

function CityHallTouchPad:getCurDirection()
     return self.mCurDirection, self.mCurDeg
end

----------------- 保持与touchpad一致的接口----------------
function CityHallTouchPad:normalSkill()

end

function CityHallTouchPad:normalSkillCancel()
   
end
--------------------------------------------------------------

----------------------回调--------------------
function CityHallTouchPad:onSceneLayerMoved(_type, _pos)
  if not FightConfig.__DEBUG_CITYHALL_MYPOS then return end
   if _type == "backbulding" then
      self.mSkyLayerPosDisplay:setString(string.format("backbulding pos:  (%f,%f)", _pos.x, _pos.y))
   end
end