-- Func: 帮派大厅场景按钮
-- Author: Johny

UnionSceneButton = class("UnionSceneButton", function()
   return ccui.Button:create()
end)

-----------------局部变量--------------------
local FUNCS = {}
FUNCS.UNIONINFO   =  "guildinfo"
FUNCS.UNIONFIGHT  =  "guildwar"
FUNCS.UNIONBUILD  =  "guildbuild"
FUNCS.UNIONSKILL  =  "guildskill"
FUNCS.UNIONSHOP   =  "guildshop"
FUNCS.UNIONHELLO  =  "guildhello"
---------------------------------------------

function UnionSceneButton:ctor(resId, pos, funcid, _root)
   self.mBornPos = cc.p(pos[1], pos[2])
   self.mFuncID = funcid
   --
   self:setPosition(self.mBornPos)
   self:setLocalZOrder(1440 - self.mBornPos.y)
   _root:addChild(self)
   --
   self:Init(resId)
end

function UnionSceneButton:Destroy()
   self:removeFromParent()
end

function UnionSceneButton:Tick()
   
end

function UnionSceneButton:Init(resId)
    local function onCliked(widget, tp)
       if tp == 1 then --begin

       elseif tp == 2 then --end
          if self.mFuncID == FUNCS.UNIONFIGHT then
             self:showBattle()
          elseif self.mFuncID == FUNCS.UNIONINFO then
             self:showInfo()
          elseif self.mFuncID == FUNCS.UNIONBUILD then
             self:showBuild()
          elseif self.mFuncID == FUNCS.UNIONSKILL then
             self:showSkill()
          elseif self.mFuncID == FUNCS.UNIONSHOP then
            self:showShop()
          elseif self.mFuncID == FUNCS.UNIONHELLO then
             self:showHello()
          end
       end
    end
    local resDB = DB_ResourceList.getDataById(resId)
    self:setAnchorPoint(cc.p(0.5, 0))
    self:setTouchEnabled(true)
    self:loadTextureNormal(resDB.Res_path1)
    registerWidgetPushAndReleaseEvent(self, onCliked)
end

-- 显示帮战
function UnionSceneButton:showBattle()
   GUISystem:goTo("banghuihall")
end

-- 显示帮派信息
function UnionSceneButton:showInfo()
  GUISystem:goTo("partyMain")
end

-- 帮派建设
function UnionSceneButton:showBuild()
  GUISystem:goTo("partyBuild")
end

-- 帮派技能
function UnionSceneButton:showSkill()
  GUISystem:goTo("partySkill")
end

-- 帮派商城
function UnionSceneButton:showShop()
   local function onRequestEnterShop(msgPacket)
      globaldata:updateGoodsInfoFromServerPacket(msgPacket)
      Event.GUISYSTEM_SHOW_SHOPWINDOW.mData = 5
      EventSystem:PushEvent(Event.GUISYSTEM_SHOW_SHOPWINDOW)
      GUISystem:hideLoading()
    end

    NetSystem.mNetManager:RegisterPacketHandler(PacketTyper._PTYPE_SC_REQUEST_GOODSINFO_, onRequestEnterShop)

    local function requestEnterShop()
      local packet = NetSystem.mNetManager:GetSPacket()
        packet:SetType(PacketTyper._PTYPE_CS_REQUEST_GOODSINFO_)
        packet:PushChar(5)
        packet:Send()
        GUISystem:showLoading()
    end
    requestEnterShop()
end

-- 帮派问好
function UnionSceneButton:showHello()
  GUISystem:goTo("partyHello")
end