-- Func: Union子管理器
-- Author: Johny

require "FightSystem/CityHall/UnionSceneButton"

UnionSubManager = {}
UnionSubManager.UNION_CITYID = 5
UnionSubManager.BACK_CITYID = -1

--进入帮派大厅
function UnionSubManager:enterUnionHall()
	local unionHallCityID = self.UNION_CITYID
    local cityDB = DB_CityConfig.getDataById(unionHallCityID)
    if HallManager:isUnionHall(cityDB.PublicMap) then
       if globaldata.partyId == "" then
          MessageBox:showMessageBox1("大哥，你还没有帮派呢！")
          return
       end
       UnionSubManager.BACK_CITYID = globaldata:getCityHallData("cityid")
    end
    ---
    local function callFun()
      GUISystem:HideAllWindow()
      showLoadingWindow("UnionHallWindow")
    end
    FightSystem:sendChangeCity(unionHallCityID,callFun)
end

-- 离开帮派大厅
function UnionSubManager:leaveUnionHall()
	local function callFun()
	      GUISystem:HideAllWindow()
	      showLoadingWindow("HomeWindow")
    end
    FightSystem:sendChangeCity(UnionSubManager.BACK_CITYID,callFun)
end

---------
function UnionSubManager:Release()
	self:Destroy()
	-----
	_G["UnionSubManager"] = nil
  	package.loaded["UnionSubManager"] = nil
  	package.loaded["FightSystem/CityHall/UnionSubManager"] = nil
end

function UnionSubManager:init(_hallManager)
	self.mHallManager = _hallManager
	self.mSceneBunttonList = {} -- 存放所有可以点击的场景按钮
end

function UnionSubManager:Tick(delta)

end

-- 载入
function UnionSubManager:Load(_root, _pos, _cityDB)
	local function loadSceneBtns()
		for i = 1, 8 do
		    local resID = _cityDB[string.format("Button%dID", i)]
		    local pos = _cityDB[string.format("Button%dPos", i)]
		    local func = _cityDB[string.format("Button%dFunction", i)]
		    if resID > 0 then
		       local btn = UnionSceneButton.new(resID, pos, func, _root)
		       table.insert(self.mSceneBunttonList, _npc)
		   	else
		    	break
		    end
		end
	end
	loadSceneBtns()
end

-- 销毁
function UnionSubManager:Destroy()
	self.mSceneBunttonList = {}
end