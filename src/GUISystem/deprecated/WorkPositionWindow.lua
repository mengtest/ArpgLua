-- Name: 	WorkWindow
-- Func：	打工窗口
-- Author:	WangShengdong
-- Data:	14-1-22

local workers  = 5	--打工者数量

local costTime = {10800, 36000}

local payVal   = {}

payVal[1]      = {24000, 72000}
payVal[2]      = {12, 36}
payVal[3]      = {12, 36}

local payName  = {"金币", "钻石", "耐力"}


local HeroExitInfo = {}
function HeroExitInfo:new()
	local o = 
	{
		mHeroId 	 = nil,
		mHeroIsExit  = nil,
	}
	o = newObject(o, HeroExitInfo)
	return o
end

function HeroExitInfo:getKeyValue(key)
	if self[key] then
		return self[key]
	end
	return nil
end

--===============================================================tabelview begin=====================================================================

local HeroTableView = {}

function HeroTableView:new(owner,listType)
	local o = 
	{
		mOwner			  = owner,
		mRootNode 	      =	nil,
		mType 		      =	listType,
		mTableView	      =	nil,
	}
	o = newObject(o, HeroTableView)
	return o
end

function HeroTableView:Destroy()
	self.mRootNode:removeFromParent(true)
	self.mRootNode   = nil
	self.mTableView  = nil
	self.mOwner      = nil
	self.mLastSel    = nil
end

function HeroTableView:init(rootNode)
	self.mRootNode = rootNode
	-- 初始化数据源
	self:initTableView()
end

function HeroTableView:initTableView()
	self.mTableView = TableViewEx:new()

	local widget = GUIWidgetPool:createWidget("WorkHeroData")
	self.mTableView:setCellSize(widget:getContentSize())
	self.mTableView:setCellCount(#self.mOwner.mHeroExitInfoArr)

	self.mTableView:registerTableCellAtIndexFunc(handler(self, self.tableCellAtIndex))
	self.mTableView:registerTableCellTouchedFunc(handler(self, self.tableCellTouched))

	self.mTableView:init(self.mRootNode:getContentSize(), cc.p(0,0), 1)
	self.mRootNode:addChild(self.mTableView:getRootNode())

	self.mTableView:setBounceable(false)
end

function HeroTableView:tableCellAtIndex(table, index)
	local cell = table:dequeueCell()

	local heroItem = nil

	if nil == cell then
		cell = cc.TableViewCell:new()
		heroItem = GUIWidgetPool:createWidget("WorkHeroData")
		
		heroItem:setTouchSwallowed(false)
		heroItem:setTag(1)
		cell:addChild(heroItem)
	else
		heroItem = cell:getChildByTag(1)
		heroItem:getChildByName("Panel_HeroIcon"):removeAllChildren()
		heroItem:getChildByName("Image_Choice"):setVisible(false)
	end

	self:setCellLayOut(heroItem,index+1)

	return cell
end

function HeroTableView:tableCellTouched(table,cell)

	if self.mLastSel then 
		self.mLastSel:getChildByName("Image_Choice"):setVisible(false)
	end

	cell:getChildByTag(1):getChildByName("Image_Choice"):setVisible(true)

	self.mOwner:setPanelLayout(self.mOwner.mHeroExitInfoArr[cell:getIdx() + 1])	
	self.mOwner.mLastSelectedHeroId = self.mOwner.mHeroExitInfoArr[cell:getIdx() + 1].mHeroId

	self.mLastSel = cell:getChildByTag(1)
end

function HeroTableView:UpdateTableView(cellCnt)
	self.mTableView:setCellCount(cellCnt)
	self.mTableView:reloadData()
end

function HeroTableView:setCellLayOut(cell,index)
	local heroInfo = self.mOwner.mHeroExitInfoArr[index]
	local heroData = DB_HeroConfig.getDataById(heroInfo.mHeroId)

	cell:getChildByName("Label_Music"):setString(tostring(heroData.Music))
	cell:getChildByName("Label_Painting"):setString(tostring(heroData.Paint))
	cell:getChildByName("Label_Sport"):setString(tostring(heroData.Sport))

	-- 英雄头像
	local heroIcon = nil

	if heroInfo.mHeroIsExit  == 1 then
		local heroObj = globaldata:findHeroById(heroInfo.mHeroId)
	    heroIcon = createWorkHeroIcon(heroInfo.mHeroId, heroObj:getKeyValue("level"))
		
	else
		heroIcon = createWorkHeroIcon(heroInfo.mHeroId, 0)
		ShaderManager:DoUIWidgetDisabled(heroIcon:getChildByName("Image_HeroHead"), true) 
	end
	
	cell:getChildByName("Panel_HeroIcon"):addChild(heroIcon)
	heroIcon:setTouchEnabled(false)

	--[[if index == 1 then
		self.mOwner:setPanelLayout(self.mOwner.mHeroExitInfoArr[index])	
		cell:getChildByName("Image_Choice"):setVisible(true)
		self.mLastSel = cell
		self.mOwner.mLastSelectedHeroId = self.mOwner.mHeroExitInfoArr[index].mHeroId
	end]]--

end


--===============================================================window begin=====================================================================

local WorkPositionWindow = 
{
	mName						=	"WorkPositionWindow",
	mRootNode 					= 	nil,
	mRootWidget 				= 	nil,
	mTopRoleInfoPanel			=	nil,
	mWorkType					=	nil,			-- 	
	mSelectHeroWindow			=	nil,			-- 选择英雄窗口

	mLastSelectedHeroId 		=	nil,			-- 最后一次选择的英雄Id
	mSortType					=   1,				-- 排序方式
	mPanelModel1				=   nil,
	mPanelModel2				=   nil,
	mListView					=  	nil,

	mHeroExitInfoArr			=   {},
	mPanelIndex					=   nil,
}

function WorkPositionWindow:Release()

end

function WorkPositionWindow:Load(event)
	cclog("=====WorkPositionWindow:Load=====begin")

	self.mRootNode = cc.Node:create()
	GUISystem:GetRootNode():addChild(self.mRootNode)

	self.mWorkType = event.mData
	self.mSortType = self.mWorkType

	self:InitLayout(event)

	cclog("=====WorkPositionWindow:Load=====end")
end

function WorkPositionWindow:InitLayout(event)
	self.mRootWidget =  GUIWidgetPool:createWidget("WorkPlace")
	self.mRootNode:addChild(self.mRootWidget)

	local function closeWindow()
		GUISystem:playSound("homeBtnSound")
		EventSystem:PushEvent(Event.GUISYSTEM_HIDE_WORKPOSITIONWINDOW)
	end

	self.mTopRoleInfoPanel = TopRoleInfoPanel:new()
	local topInfoPanel = self.mTopRoleInfoPanel:init(self.mRootNode, closeWindow)

	local function doAdapter()
	    local newPosX = getGoldFightPosition_LU().x
		local function doSomething()
			self.mRootWidget:getChildByName("Image_Title"):setPositionX(newPosX)
			self.mRootWidget:getChildByName("Image_Title"):setVisible(true)
		end
		doSomething()
		self.mRootWidget:getChildByName("Image_Title"):setVisible(false)
	end

	doAdapter()
	if self.mWorkType == 1 then
		self.mRootWidget:getChildByName("Image_Title"):loadTexture ("work_logo_music.png")
	elseif self.mWorkType == 2 then
		self.mRootWidget:getChildByName("Image_Title"):loadTexture ("work_logo_painting.png")
	elseif self.mWorkType == 3 then
		self.mRootWidget:getChildByName("Image_Title"):loadTexture ("work_logo_sports.png")
	end

	self:showWorkerPosition()
end

function WorkPositionWindow:showWorkerPosition()
	for i = 1,5 do
		--local widget = GUIWidgetPool:createWidget("WorkerItem")
		self.mRootWidget:getChildByName("Panel_Place"):getChildByName("Panel_Position_"..i):removeAllChildren()
	end	
	
	local workerCount = #globaldata.workers[self.mWorkType]

	for i = 1,5 do
		local workobj 	= globaldata.workers[self.mWorkType][i]
		local widget = GUIWidgetPool:createWidget("WorkerItem")
		self.mRootWidget:getChildByName("Panel_Place"):getChildByName("Panel_Position_"..i):addChild(widget)
		widget:getChildByName("Button_Add"):setTag(i)
		widget:getChildByName("Button_Leave"):setTag(i)

		if self.mWorkType == 1 then
			widget:getChildByName("Image_Money"):loadTexture ("public_gold.png")
			widget:getChildByName("Image_Mode"):loadTexture ("public_gold.png")
			widget:getChildByName("Image_Carrier"):loadTexture ("work_carrier_music.png")
		elseif self.mWorkType == 2 then
			widget:getChildByName("Image_Money"):loadTexture ("public_diamond.png")
			widget:getChildByName("Image_Mode"):loadTexture ("public_diamond.png")
			widget:getChildByName("Image_Carrier"):loadTexture ("work_carrier_painting.png")
		elseif self.mWorkType == 3 then
			widget:getChildByName("Image_Money"):loadTexture ("public_energy.png")
			widget:getChildByName("Image_Mode"):loadTexture ("public_energy.png")
			widget:getChildByName("Image_Carrier"):loadTexture ("work_carrier_sports.png")
		end

		widget:getChildByName("Label_MoneyNum"):setVisible(false)
		widget:getChildByName("Label_MoneyGet"):setVisible(false)
		widget:getChildByName("Image_Money"):setVisible(false)	

		if workobj == nil then
			widget:getChildByName("Label_Mode"):setString(tostring(0))
			widget:getChildByName("Button_Add"):setVisible(true)
			widget:getChildByName("Button_Leave"):setVisible(false)
			registerWidgetReleaseUpEvent(widget:getChildByName("Button_Add"),handler(self,self.OnPosotionBtnAdd))
		else
			widget:getChildByName("Label_Mode"):setString(tostring(workobj.mItemCount))
			widget:getChildByName("Button_Add"):setVisible(false)
			widget:getChildByName("Button_Leave"):setVisible(true)
			workobj:setWidget(widget)

			self:setWorkPanel(workobj,widget)
		end		
	end	
end

function WorkPositionWindow:addWorker(workobj,panelIndex)
	local panel = self.mRootWidget:getChildByName("Panel_Place"):getChildByName("Panel_Position_"..panelIndex)

	if self.mWorkType == 1 then
		panel:getChildByName("Image_Money"):loadTexture ("public_gold.png")
		panel:getChildByName("Image_Mode"):loadTexture ("public_gold.png")
		panel:getChildByName("Image_Carrier"):loadTexture ("work_carrier_music.png")
	elseif self.mWorkType == 2 then
		panel:getChildByName("Image_Money"):loadTexture ("public_diamond.png")
		panel:getChildByName("Image_Mode"):loadTexture ("public_diamond.png")
		panel:getChildByName("Image_Carrier"):loadTexture ("work_carrier_painting.png")
	elseif self.mWorkType == 3 then
		panel:getChildByName("Image_Money"):loadTexture ("public_energy.png")
		panel:getChildByName("Image_Mode"):loadTexture ("public_energy.png")
		panel:getChildByName("Image_Carrier"):loadTexture ("work_carrier_sports.png")
	end

	panel:getChildByName("Button_Add"):setVisible(false);
	panel:getChildByName("Button_Leave"):setVisible(true);

	panel:getChildByName("Label_Mode"):setString(tostring(workobj.mItemCount))
	panel:getChildByName("Label_MoneyNum"):setString(tostring(workobj.mTotleCount))

	workobj:setWidget(panel)

	self:setWorkPanel(workobj,panel)
end

function WorkPositionWindow:setWorkPanel(workobj,panel)
	local heroId 	= workobj.mWorkHeroId
	local heroObj 	= globaldata:findHeroById(heroId)
	local heroData  = DB_HeroConfig.getDataById(heroId)
	local heroAnim  = nil

	if self.mWorkType == 3 then
		heroAnim= FightSystem.mRoleManager:CreateRunSpine(heroId)
	else
		heroAnim= FightSystem.mRoleManager:CreateSpine(heroId)
	end
	heroAnim:setScale(heroData.UIResouceZoom)
	panel:getChildByName("Panel_29"):addChild(heroAnim)
	panel:getChildByName("Panel_29"):setScale(1)

	local function btn_Leave_Press(widget)
		GUISystem:playSound("homeBtnSound") 
		-- 请求停止打工回包
		local function onRequestWorkStop(msgPacket)
			local result = msgPacket:GetChar()
			local heroGuid = msgPacket:GetString()
			local heroId = msgPacket:GetInt()
			-- 删除打工者
			globaldata:removeWorker(heroId)

			-- 刷新已打工者界面
			self:delWorker(widget:getTag())

			--self:showWorkerPosition()
			GUISystem:hideLoading()
		end
		-- 接收停止打工信息
		NetSystem.mNetManager:RegisterPacketHandler(PacketTyper._PTYPE_SC_REQUEST_WORK_STOP_, onRequestWorkStop)

		local packet = NetSystem.mNetManager:GetSPacket()
		packet:SetType(PacketTyper._PTYPE_CS_REQUEST_WORK_STOP_)
		packet:PushChar(self.mWorkType)
		packet:PushString(heroObj:getKeyValue("guid"))
		packet:PushInt(heroId)
		packet:Send()
		GUISystem:showLoading()
	end

	local function btn_Get_Press(widget)
		GUISystem:playSound("homeBtnSound") 
		-- 领取奖励回包
		local function onRequestWorkGet(msgPacket)
			local result = msgPacket:GetChar()
			local heroGuid = msgPacket:GetString()
			local heroId = msgPacket:GetInt()
			-- 删除打工者
			globaldata:removeWorker(heroId)
			-- 刷新已打工者界面
			self:delWorker(widget:getTag())
			GUISystem:hideLoading()
		end
		-- 领取奖励
		NetSystem.mNetManager:RegisterPacketHandler(PacketTyper._PTYPE_SC_REQUEST_WORK_GET_, onRequestWorkGet)

		local packet = NetSystem.mNetManager:GetSPacket()
		packet:SetType(PacketTyper._PTYPE_CS_REQUEST_WORK_GET_)
		packet:PushChar(self.mWorkType)
		packet:PushString(heroObj:getKeyValue("guid"))
		packet:PushInt(heroId)
		packet:Send()
		GUISystem:showLoading()
	end

	if workobj.mLeftTime == 0 then
		panel:getChildByName("Label_22"):setString("领取")
		registerWidgetReleaseUpEvent(panel:getChildByName("Button_Leave"), btn_Get_Press)
	else
		panel:getChildByName("Label_22"):setString("离开")
		registerWidgetReleaseUpEvent(panel:getChildByName("Button_Leave"), btn_Leave_Press)
	end
end


function WorkPositionWindow:delWorker(panelIndex)
	local panel = self.mRootWidget:getChildByName("Panel_Place"):getChildByName("Panel_Position_"..panelIndex)

	panel:getChildByName("Panel_29"):removeAllChildren()
	panel:getChildByName("Label_Time"):setString("剩余  00:00")

	if self.mWorkType == 1 then
		panel:getChildByName("Image_Money"):loadTexture ("public_gold.png")
		panel:getChildByName("Image_Mode"):loadTexture ("public_gold.png")
		panel:getChildByName("Image_Carrier"):loadTexture ("work_carrier_music.png")
	elseif self.mWorkType == 2 then
		panel:getChildByName("Image_Money"):loadTexture ("public_diamond.png")
		panel:getChildByName("Image_Mode"):loadTexture ("public_diamond.png")
		panel:getChildByName("Image_Carrier"):loadTexture ("work_carrier_painting.png")
	elseif self.mWorkType == 3 then
		panel:getChildByName("Image_Money"):loadTexture ("public_energy.png")
    	panel:getChildByName("Image_Carrier"):loadTexture ("work_carrier_sports.png") 
	end

	panel:getChildByName("Button_Add"):setVisible(true);
	panel:getChildByName("Button_Leave"):setVisible(false);

	panel:getChildByName("Label_Mode"):setString(tostring(0))
	panel:getChildByName("Label_MoneyNum"):setVisible(false)
	panel:getChildByName("Label_MoneyGet"):setVisible(false)
	panel:getChildByName("Image_Money"):setVisible(false)

	registerWidgetReleaseUpEvent(panel:getChildByName("Button_Add"),handler(self,self.OnPosotionBtnAdd))
end

function WorkPositionWindow:OnPosotionBtnAdd(widget)
	GUISystem:playSound("homeBtnSound") 
	self.mPanelIndex = widget:getTag() 
	self:showIdleHero(self.mPanelIndex)
end

function WorkPositionWindow:showIdleHero(panelIndex)

	self.mTopRoleInfoPanel.mTopWidget:setVisible(false)
	if self.mSelectHeroWindow == nil then
	 	self.mSelectHeroWindow = GUIWidgetPool:createWidget("WorkHeroList")
	 	self.mRootWidget:addChild(self.mSelectHeroWindow,6)
	end

	self.mPanelModel1 = self.mSelectHeroWindow:getChildByName("Panel_Mode_1")
	self.mPanelModel2 = self.mSelectHeroWindow:getChildByName("Panel_Mode_2")

	self.mSelectHeroWindow:getChildByName("Image_Music"):setTag(1)
	self.mSelectHeroWindow:getChildByName("Image_Painting"):setTag(2)
	self.mSelectHeroWindow:getChildByName("Image_Sports"):setTag(3)

	registerWidgetPushDownEvent(self.mSelectHeroWindow:getChildByName("Image_Music"), handler(self, self.onClickListHead))
	registerWidgetPushDownEvent(self.mSelectHeroWindow:getChildByName("Image_Painting"), handler(self, self.onClickListHead))
	registerWidgetPushDownEvent(self.mSelectHeroWindow:getChildByName("Image_Sports"), handler(self, self.onClickListHead))
	registerWidgetReleaseUpEvent(self.mPanelModel1:getChildByName("Button_Start"), handler(self, self.onBtnBeginWork))
	registerWidgetReleaseUpEvent(self.mPanelModel2:getChildByName("Button_Start"), handler(self, self.onBtnBeginWork))

	if self.mWorkType == 1 then
		self.mPanelModel1:getChildByName("Image_Gold"):loadTexture ("public_gold.png")
		self.mPanelModel2:getChildByName("Image_Gold"):loadTexture ("public_gold.png")
		self.mPanelModel1:getChildByName("Label_Time"):setString("24000")
		self.mPanelModel2:getChildByName("Label_Time"):setString("72000")
	elseif self.mWorkType == 2 then
		self.mPanelModel1:getChildByName("Image_Gold"):loadTexture ("public_diamond.png")
		self.mPanelModel2:getChildByName("Image_Gold"):loadTexture ("public_diamond.png")
		self.mPanelModel1:getChildByName("Label_Time"):setString("12")
		self.mPanelModel2:getChildByName("Label_Time"):setString("36")
	elseif self.mWorkType == 3 then
		self.mPanelModel1:getChildByName("Image_Gold"):loadTexture ("public_energy.png")
		self.mPanelModel2:getChildByName("Image_Gold"):loadTexture ("public_energy.png")
		self.mPanelModel1:getChildByName("Label_Time"):setString("12")
		self.mPanelModel2:getChildByName("Label_Time"):setString("36")
	end

	self:UpdateListHead()

	-- 关闭窗口
	local function hideHeroPanel()
		self.mTopRoleInfoPanel.mTopWidget:setVisible(true)
		self.mListView = nil
		self.mSelectHeroWindow:removeFromParent(true)
		self.mSelectHeroWindow = nil
	end
	registerWidgetReleaseUpEvent(self.mSelectHeroWindow, hideHeroPanel)

	local allHeros = globaldata:getTotalHeroTeam()
	local heroIdTable = {}
	local allHeroIdTable = {1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,24,25,26,27,28,}
	for k, v in pairs(allHeros) do
		local heroId = v:getKeyValue("id")
		if not globaldata:isHeroWorking(heroId) then
		--	table.insert(heroIdTable, heroId)
			heroIdTable[heroId] = heroId
		end
	end

	local function sortFunc(id1, id2)
		local heroData1 = DB_HeroConfig.getDataById(id1)
		local heroData2 = DB_HeroConfig.getDataById(id2)
		local val1 = nil
		local val2 = nil
		if 1 == self.mSortType then		-- 音乐
			val1 = heroData1.Music
			val2 = heroData2.Music
		elseif 2 == self.mSortType then	-- 美术
			val1 = heroData1.Paint
			val2 = heroData2.Paint
		elseif 3 == self.mSortType then	-- 体育
			val1 = heroData1.Sport
			val2 = heroData2.Sport
		end
		if val1 > val2 then
			return true
		else
			return false
		end
	end

	table.sort(allHeroIdTable,sortFunc)

	self.mHeroExitInfoArr = {}

	-- 第一遍创建存在的
	for i = 1, #allHeroIdTable do
		if heroIdTable[allHeroIdTable[i]] then -- 存在
			--local widget = createWorkerData(allHeroIdTable[i])
			--self.mListView:pushBackCustomItem(widget)
			local heroExitInfo = HeroExitInfo:new()
			heroExitInfo.mHeroId = allHeroIdTable[i]
			heroExitInfo.mHeroIsExit = 1
			table.insert(self.mHeroExitInfoArr,heroExitInfo) 
		end
	end

	-- 第二遍创建不存在的
	for i = 1, #allHeroIdTable do
		if not heroIdTable[allHeroIdTable[i]] then -- 不存在
			--local widget = createWorkerDataEx(allHeroIdTable[i])
			--self.mListView:pushBackCustomItem(widget)
			local heroExitInfo = HeroExitInfo:new()
			heroExitInfo.mHeroId = allHeroIdTable[i]
			heroExitInfo.mHeroIsExit = 0
			table.insert(self.mHeroExitInfoArr,heroExitInfo) 
		end
	end

	if self.mListView == nil then
		self.mListView = HeroTableView:new(self,0)
		self.mListView:init(self.mSelectHeroWindow:getChildByName("TableView_HeroList"))
	else
		self.mListView.mTableView:reloadData()
	end
end

function WorkPositionWindow:setTime(heroId)
	if heroId ~= nil then
		--local heroObj = globaldata:findHeroById(self.mLastSelectedHeroId)
		--local heroGuid = heroObj:getKeyValue("guid")
		local heroData = DB_HeroConfig.getDataById(heroId)
		local baseVal = 0
    	if 1 == self.mWorkType then
    		baseVal = heroData.Music
    	elseif 2 == self.mWorkType then
    		baseVal = heroData.Paint
    	elseif 3 == self.mWorkType then
    		baseVal = heroData.Sport
    	end

		local widget1 = self.mPanelModel1:getChildByName("Label_Pay")
		local totalTime1 = math.ceil(costTime[1] * 100 / baseVal)
		widget1:setString("打工将耗时  "..secondToHour(totalTime1))

		local widget2 = self.mPanelModel2:getChildByName("Label_Pay")
		local totalTime2 = math.ceil(costTime[2] * 100 / baseVal)
		widget2:setString("打工将耗时  "..secondToHour(totalTime2))
	end
end

function  WorkPositionWindow:setPanelLayout(heroExitInfo)	
	if heroExitInfo.mHeroIsExit == 0 then
		self.mPanelModel1:getChildByName("Button_Start"):setTouchEnabled(false)
		self.mPanelModel2:getChildByName("Button_Start"):setTouchEnabled(false)
		ShaderManager:DoUIWidgetDisabled(self.mPanelModel1:getChildByName("Button_Start"), true)  
		ShaderManager:DoUIWidgetDisabled(self.mPanelModel2:getChildByName("Button_Start"), true)  
	else
		self.mPanelModel1:getChildByName("Button_Start"):setTouchEnabled(true)
		self.mPanelModel2:getChildByName("Button_Start"):setTouchEnabled(true)
		ShaderManager:DoUIWidgetDisabled(self.mPanelModel1:getChildByName("Button_Start"), false)  
		ShaderManager:DoUIWidgetDisabled(self.mPanelModel2:getChildByName("Button_Start"), false) 
	end

	--[[if self.mWorkType == 1 then
		mPanelModel1:getChildByName("Image_Gold"):loadTexture ("public_gold.png")
		mPanelModel2:getChildByName("Image_Gold"):loadTexture ("public_gold.png")
		mPanelModel1:getChildByName("Label_Time"):setString("24000")
		mPanelModel2:getChildByName("Label_Time"):setString("72000")
	elseif self.mWorkType == 2 then
		mPanelModel1:getChildByName("Image_Gold"):loadTexture ("public_diamond.png")
		mPanelModel2:getChildByName("Image_Gold"):loadTexture ("public_diamond.png")
		mPanelModel1:getChildByName("Label_Time"):setString("12")
		mPanelModel2:getChildByName("Label_Time"):setString("36")
	elseif self.mWorkType == 3 then
		mPanelModel1:getChildByName("Image_Gold"):loadTexture ("public_energy.png")
		mPanelModel2:getChildByName("Image_Gold"):loadTexture ("public_energy.png")
		mPanelModel1:getChildByName("Label_Time"):setString("12")
		mPanelModel2:getChildByName("Label_Time"):setString("36")
	end]]--

	self:setTime(heroExitInfo.mHeroId)
end


function WorkPositionWindow:onClickListHead(widget)
	GUISystem:playSound("tabPageSound")
	if self.mSortType ~= widget:getTag() then
		self.mSortType = widget:getTag()
		self:UpdateListHead()
		self:showIdleHero(self.mPanelIndex)
	end
end

function WorkPositionWindow:UpdateListHead()
	if self.mSortType == 1 then
		self.mSelectHeroWindow:getChildByName("Image_Sports_Bg"):setVisible(false)
		self.mSelectHeroWindow:getChildByName("Image_Painting_Bg"):setVisible(false)
		self.mSelectHeroWindow:getChildByName("Image_Music_Bg"):setVisible(true)

		self.mSelectHeroWindow:getChildByName("Image_Music"):loadTexture("work_title_music_2.png")
		self.mSelectHeroWindow:getChildByName("Image_Painting"):loadTexture("work_title_painting_1.png")
		self.mSelectHeroWindow:getChildByName("Image_Sports"):loadTexture("work_title_sports_1.png")
	elseif self.mSortType == 2 then
		self.mSelectHeroWindow:getChildByName("Image_Music_Bg"):setVisible(false)
		self.mSelectHeroWindow:getChildByName("Image_Painting_Bg"):setVisible(true)
		self.mSelectHeroWindow:getChildByName("Image_Sports_Bg"):setVisible(false)
		self.mSelectHeroWindow:getChildByName("Image_Music"):loadTexture("work_title_music_1.png")
		self.mSelectHeroWindow:getChildByName("Image_Painting"):loadTexture("work_title_painting_2.png")
		self.mSelectHeroWindow:getChildByName("Image_Sports"):loadTexture("work_title_sports_1.png")
	elseif self.mSortType == 3 then
		self.mSelectHeroWindow:getChildByName("Image_Music_Bg"):setVisible(false)
		self.mSelectHeroWindow:getChildByName("Image_Painting_Bg"):setVisible(false)
		self.mSelectHeroWindow:getChildByName("Image_Sports_Bg"):setVisible(true )
		self.mSelectHeroWindow:getChildByName("Image_Music"):loadTexture("work_title_music_1.png")
		self.mSelectHeroWindow:getChildByName("Image_Painting"):loadTexture("work_title_painting_1.png")
		self.mSelectHeroWindow:getChildByName("Image_Sports"):loadTexture("work_title_sports_2.png")
	end
end


function WorkPositionWindow:onBtnBeginWork(widget)
	GUISystem:playSound("homeBtnSound")
	if self.mLastSelectedHeroId == nil then MessageBox:showMessageBox1("请选择英雄！！！") return end

	self.mSelectHeroWindow:removeFromParent(true)
	self.mTopRoleInfoPanel.mTopWidget:setVisible(true)

	self.mSelectHeroWindow = nil
	self.mListView = nil

	local packet = NetSystem.mNetManager:GetSPacket()
    packet:SetType(PacketTyper._PTYPE_CS_REQUEST_WORK_EXECUTE_)

    local heroObj = globaldata:findHeroById(self.mLastSelectedHeroId)
	local heroGuid = heroObj:getKeyValue("guid")
	local heroData = DB_HeroConfig.getDataById(self.mLastSelectedHeroId)
    local baseVal = 0
    if 1 == self.mWorkType then
    	baseVal = heroData.Music
    elseif 2 == self.mWorkType then
    	baseVal = heroData.Paint
    elseif 3 == self.mWorkType then
    	baseVal = heroData.Sport
    end

    local totalTime = costTime[widget:getTag()] * 100 / baseVal


    -- 请求执行打工回包
	local function onRequestWorkExecute(msgPacket)
		local result = msgPacket:GetChar()
		-- 添加打工者
		globaldata:addWorkerFromServer(self.mWorkType, msgPacket)
		-- 刷新已打工者界面
		local len 	= #globaldata.workers[self.mWorkType]
		self:addWorker(globaldata.workers[self.mWorkType][len],self.mPanelIndex)
		self.mLastSelectedHeroId = nil
		GUISystem:hideLoading()
	end
    -- 接收执行打工信息
    NetSystem.mNetManager:RegisterPacketHandler(PacketTyper._PTYPE_SC_REQUEST_WORK_EXECUTE_, onRequestWorkExecute)

    packet:PushChar(self.mWorkType)
	packet:PushString(heroGuid)
    packet:PushInt(self.mLastSelectedHeroId)
    packet:PushChar(widget:getTag())
    packet:PushInt(totalTime)
    packet:Send()
    GUISystem:showLoading() 
end

function WorkPositionWindow:Destroy()
	self.mRootNode:removeFromParent(true)
	self.mRootNode              = nil
	self.mRootWidget            = nil

	self.mTopRoleInfoPanel:destroy()
	self.mTopRoleInfoPanel      = nil

	self.mWorkType	            = nil
	self.mSelectHeroWindow      = nil

	self.mLastSelectedHeroId 	= nil
	self.mSortType				= 1
	self.mPanelModel1	    	= nil
	self.mPanelModel2			= nil
	self.mListView	        	= nil

	self.mHeroExitInfoArr   	= {}
	self.mPanelIndex			=   nil
	-- 清除Widget
	globaldata:cleanWidget()


	CommonAnimation:clearAllTextures()
end

function WorkPositionWindow:onEventHandler(event)
	if event.mAction == Event.WINDOW_SHOW then
		self:Load(event)
	elseif event.mAction == Event.WINDOW_HIDE then
		self:Destroy()
	end
end


return WorkPositionWindow