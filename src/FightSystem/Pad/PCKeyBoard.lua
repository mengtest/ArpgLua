-- Name: PCKeyBoard
-- Func: PC键盘
-- Author: Johny

local PCKeyBoard = class("PCKeyBoard",function()
  return cc.Layer:create()
end)

local clicked = false

function PCKeyBoard:ctor(_tp)
	-- cclog("=====PCKeyBoard:ctor=====")
	self.mType = _tp
end

function PCKeyBoard:Init()
   -- cclog("=====PCKeyBoard:Init=====")
    local function onKeyPressed(keyCode, event)
        local scheduler = cc.Director:getInstance():getScheduler()
        local _dir = 0
        local _deg = 0
        if keyCode == 143 then
            -- cclog("w clicked!")
            self:moveHolder(1, 90)
            _dir = 1
            _deg = 90
        elseif keyCode == 139  then
            -- cclog("s clicked!")
            self:moveHolder(2, -90)
            _dir = 2
            _deg = -90
        elseif keyCode == 121  then
            -- cclog("a clicked!")
            self:moveHolder(3, 180)
            _dir = 3
            _deg = 180
        elseif keyCode == 124  then
            -- cclog("d clicked!")
            self:moveHolder(4, 0)
            _dir = 4
            _deg = 0
        elseif keyCode == 137  then
            -- cclog("q clicked!")
            self:moveHolder(5, 150)
            _dir = 5
            _deg = 135
        elseif keyCode == 125  then
            -- cclog("e clicked!")
            self:moveHolder(6, 30)
            _dir = 6
            _deg = 45
        elseif keyCode == 146  then
            -- cclog("z clicked!")
            self:moveHolder(7, -120)
            _dir = 7
            _deg = -135
        elseif keyCode == 123  then
            -- cclog("c clicked!")
            self:moveHolder(8, -60)
            _dir = 8
            _deg = -45
        elseif keyCode == 56 then
            -- 空格
            self:jumpHolder()
        elseif keyCode == 130 then
            -- J
            FightSystem.mTouchPad:normalSkill()
        elseif keyCode == 131 then
            -- K
            self:skill("special2")
        elseif keyCode == 132 then
            -- L
            self:skill("special3")
        elseif keyCode == 135 then
            -- O
            self:skill("special1")
        elseif keyCode == 74 then
            -- 1
            self:chooseRole(1)
        elseif keyCode == 75 then
            -- 2
            self:chooseRole(2)
        elseif keyCode == 76 then
            -- 3
            self:chooseRole(3)
        elseif keyCode == 32 then
            -- Enter
            self:sendMessageWithinChat()
        end

        FightSystem.mTouchPad:setCurDirection(_dir, _deg)
    end

    local function onKeyReleased(keyCode, event)
    	-- cclog("onKeyReleased")
         if keyCode == 56 then
            self:blockcancelHolder()
         end


    	self:moveHolder(0,0)
        FightSystem.mTouchPad:setCurDirection(0, 0)
        FightSystem.mTouchPad:normalSkillCancel()
        FightSystem:PushNotification("hall_myrolestopmove")
        FightSystem:PushNotification("keyrolestopmoved")
    end

    local listener = cc.EventListenerKeyboard:create()
    listener:registerScriptHandler(onKeyPressed, cc.Handler.EVENT_KEYBOARD_PRESSED)
    listener:registerScriptHandler(onKeyReleased, cc.Handler.EVENT_KEYBOARD_RELEASED)

    local eventDispatcher = self:getEventDispatcher()
    eventDispatcher:addEventListenerWithSceneGraphPriority(listener, self)

end

function PCKeyBoard:moveHolder(_dir, _deg)
    -- 指令系统测试
    if self.mType == "cityhall" then
        local _cmd = string.format("cityhall_0_move_%d_%d", _dir, _deg)
        FCmdParseSystem.parseCommand(_cmd)
    elseif self.mType == "pve" then
        local _cmd = string.format("pve_0_move_%d_%d", _dir, _deg)
        FCmdParseSystem.parseCommand(_cmd)
    end
end

function PCKeyBoard:jumpHolder()
    -- 指令系统测试
    if self.mType == "cityhall" then
        local _cmd = string.format("cityhall_0_jump")
        FCmdParseSystem.parseCommand(_cmd)
    elseif self.mType == "pve" then
        local _cmd = string.format("pve_0_block")
        FCmdParseSystem.parseCommand(_cmd)
    end
end

function PCKeyBoard:blockcancelHolder()
    -- 指令系统测试
    if self.mType == "cityhall" then
        local _cmd = string.format("cityhall_0_cancelblock")
        FCmdParseSystem.parseCommand(_cmd)
    elseif self.mType == "pve" then
        local _cmd = string.format("pve_0_cancelblock")
        FCmdParseSystem.parseCommand(_cmd)
    end
end

function PCKeyBoard:skill(_skillid)
    if self.mType == "pve" then
        local _cmd = string.format("pve_0_skill_roleskill_%s", _skillid)
        FCmdParseSystem.parseCommand(_cmd) 
    end
end

function PCKeyBoard:chooseRole(_num)
    if self.mType == "pve" then
        local _cmd = string.format("pve_0_chooserole_%d", _num)
        FCmdParseSystem.parseCommand(_cmd) 
    end
end

-- 聊天中发送消息
function PCKeyBoard:sendMessageWithinChat()
    GUIEventManager:pushEvent("sendChatInfo")
end

return PCKeyBoard