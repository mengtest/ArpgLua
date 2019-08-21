-- Func: 城镇大厅传送点
-- Author: Johny

HallTranspoint = class("HallTranspoint")

-------------------局部变量----------------------
-- 传送最大时间
local _DURING_TRANSFER_     =   3
-------------------------------------------------


function HallTranspoint:ctor(_id, _srcpos, _srcsize, _cg, _targetid, _targetpos)
   self.mID = _id
   self.mSrcPos = _srcpos
   self.mSrcSize = _srcsize
   self.mCG = _cg
   self.mTargetID = _targetid
   self.mTargetPos = cc.p(_targetpos[1], _targetpos[2])
   self.mIsTransfering = false
   self.mTransferHandler = nil
   --
   self:Init()
   self:DrawRect(FightSystem.mSceneManager:GetTiledLayer(), _srcpos, self.mSrcSize)
end

function HallTranspoint:Destroy()
    G_unSchedule(self.mTransferHandler)
    FightSystem:UnRegisterNotification("hall_myrolemove", string.format("HallTranspoint%d",self.mID))
end

function HallTranspoint:Init()
    -- registerNotification
    FightSystem:RegisterNotifaction("hall_myrolemove", string.format("HallTranspoint%d",self.mID), handler(self, self.OnEventTheRoleMove))
    -- draw 区域

end

function HallTranspoint:Tick()
   
end

-- 传送走
function HallTranspoint:toCity(_cityid, _newPos)
    -- 临时，如果是帮派传送点，则记录要返回的cityid
    local cityDB = DB_CityConfig.getDataById(_cityid)
    if HallManager:isUnionHall(cityDB.PublicMap) then
       if globaldata.partyId == "" then
          MessageBox:showMessageBox1("大哥，你还没有帮派呢！")
          return
       end
       UnionSubManager.BACK_CITYID = globaldata:getCityHallData("cityid")
    end
    ---
    local function xxx()
        local function callFun()
          GUISystem:HideAllWindow()
          showLoadingWindow("HomeWindow")
        end
        FightSystem:sendChangeCity(_cityid,callFun)
    end
    nextTick(xxx)
end

-- 显示debug区域
function HallTranspoint:DrawRect(_root, _pos, _sz)
    if not FightConfig.__DEBUG_SKILLRANGE then return end
    local _debug = quickCreate9ImageView("debug_rectangle.png", _sz[1], _sz[2])
    _debug:setAnchorPoint(cc.p(0, 0))
    _debug:setPosition(cc.p(_pos[1], _pos[2]))
    _root:addChild(_debug,100)
end


-------------回调------------------------------------
-- 关注角色移动通知
function HallTranspoint:OnEventTheRoleMove(_thePos)
   local function resetTransferFlag()
      self.mIsTransfering = false
   end
   local _rect = cc.rect(self.mSrcPos[1], self.mSrcPos[2], self.mSrcSize[1], self.mSrcSize[2])
   if cc.rectContainsPoint(_rect, _thePos) and not self.mIsTransfering then
      self.mIsTransfering = true
      self.mTransferHandler = nextTick_frameCount(resetTransferFlag, _DURING_TRANSFER_)
      -- 过图强制停止移动
      HallManager:OnMyRoleStopMove()
      -- 转移城镇
      self:toCity(self.mTargetID, self.mTargetPos)
   end
end