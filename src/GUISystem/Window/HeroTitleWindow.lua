-- Name: 	HeroTitleWindow
-- Func：	称号使用界面
-- Author:	tuanzhang
-- Data:	16-04-20

--==========================================================recordTv begin ==================================================================
TitleTableView = {}

function TitleTableView:new(owner,listType)
	local o = 
	{
		mOwner			  = owner,
		mRootNode 	      =	nil,
		mType 		      =	listType,
		mTableView	      =	nil,
	}
	o = newObject(o, TitleTableView)
	return o
end

function TitleTableView:Destroy()
	self.mRootNode:removeFromParent(true)
	self.mRootNode     = nil
	self.mTableView    = nil
	self.mOwner        = nil
end

function TitleTableView:myModel()
	return self.mOwner.mModel
end

function TitleTableView:init(rootNode)
	self.mRootNode = rootNode
	-- 初始化数据源
	self:initTableView()
end

function TitleTableView:initTableView()
	self.mTableView = TableViewEx:new()
	self.m_CurrIndex = 1
	local widget = GUIWidgetPool:createWidget("Setting_PlayerTitleCell")

	self.mTableView:setCellSize(widget:getContentSize())
	self.mTableView:setCellCount(#self:myModel().mTitlelistTotal)

	self.mTableView:registerTableCellAtIndexFunc(handler(self, self.tableCellAtIndex))
	self.mTableView:registerTableCellTouchedFunc(handler(self, self.tableCellTouched))

	self.mTableView:init(self.mRootNode:getContentSize(), cc.p(0,0), 1)
	self.mRootNode:addChild(self.mTableView:getRootNode())
end

function TitleTableView:tableCellAtIndex(table, index)
	local cell = table:dequeueCell()
	local applyItem = nil

	if nil == cell then
		cell = cc.TableViewCell:new()
		applyItem = GUIWidgetPool:createWidget("Setting_PlayerTitleCell")
		
		applyItem:setTouchSwallowed(false)
		applyItem:setTag(1)
		cell:addChild(applyItem)
	else
		applyItem = cell:getChildByTag(1)
	end
	local datalist = nil
	if self:myModel().mOwner.mCurTabIndex == 1 then
		datalist = self:myModel().mTitlelistTotal
	elseif self:myModel().mOwner.mCurTabIndex == 2 then
		datalist = self:myModel().mTitleGetlist
	elseif self:myModel().mOwner.mCurTabIndex == 3 then
		datalist = self:myModel().mTitleNonelist
	end
	if #datalist ~= 0 then
		self:setCellLayOut(applyItem,index)
	end
	
	return cell
end

function TitleTableView:setCellLayOut(widget,index)
	index = index + 1
	local deque = nil
	if self:myModel().mOwner.mCurTabIndex == 1 then
		deque = self:myModel().mTitlelistTotal[index]
	elseif self:myModel().mOwner.mCurTabIndex == 2 then
		deque = self:myModel().mTitleGetlist[index]
	elseif self:myModel().mOwner.mCurTabIndex == 3 then
		deque = self:myModel().mTitleNonelist[index]
	end
	local data = DB_PlayerTitle.getDataById(deque.Id)
	widget:getChildByName("Label_Name"):setString(getDictionaryText(data.Name))
	widget:getChildByName("Label_Desc"):setString(getDictionaryText(data.Description))
	widget:getChildByName("Image_Icon"):setVisible(false)
	widget:getChildByName("Panel_AnimationIcon"):setVisible(false)
	widget:getChildByName("Image_OnUse"):setVisible(false)

	if data.DisplayMode == 1 then
		local _resDB = DB_ResourceList.getDataById(data.Picture)
		widget:getChildByName("Image_Icon"):loadTexture(_resDB.Res_path1)
		widget:getChildByName("Image_Icon"):setVisible(true)
	else
		widget:getChildByName("Panel_AnimationIcon"):removeAllChildren()
		widget:getChildByName("Panel_AnimationIcon"):setVisible(true)
		local star = AnimManager:createAnimNode(data.Picture)
		widget:getChildByName("Panel_AnimationIcon"):addChild(star:getRootNode(), 100)
		star:play("player_title",true)
	end
	if deque.isHave == 1 then
		widget:getChildByName("Image_Bg"):loadTexture("public_bg_bar_2.png")
		if deque.Id == self:myModel().mCurUseID then
			widget:getChildByName("Image_OnUse"):setVisible(true)
		end
	else
		widget:getChildByName("Image_Bg"):loadTexture("public_bg_bar_3.png")
	end

	if self.m_CurrIndex == index then
		widget:getChildByName("Image_Chose"):setVisible(true)
	else
		widget:getChildByName("Image_Chose"):setVisible(false)
	end
end

function TitleTableView:tableCellTouched(table,cell)
	print("RecordTableView cell touched at index: " .. cell:getIdx())
	local index = cell:getIdx() + 1
	if self.m_CurrIndex == -1 or  self.m_CurrIndex == index then return end
	local deque = nil
	if self:myModel().mOwner.mCurTabIndex == 1 then
		deque = self:myModel().mTitlelistTotal[index]
	elseif self:myModel().mOwner.mCurTabIndex == 2 then
		deque = self:myModel().mTitleGetlist[index]
	elseif self:myModel().mOwner.mCurTabIndex == 3 then
		deque = self:myModel().mTitleNonelist[index]
	end
	local cellold = table:cellAtIndex(self.m_CurrIndex-1)
	if cellold then
		local widget = cellold:getChildByTag(1)
		widget:getChildByName("Image_Chose"):setVisible(false)
	end
	self.m_CurrIndex = index
	cell:getChildByTag(1):getChildByName("Image_Chose"):setVisible(true)
	self:myModel().mOwner:ChangeOnePropertyinfo(deque.Id)

end

function TitleTableView:UpdateTableView(cellCnt,index) --move table to cur cell after reload
	self.mTableView:setCellCount(cellCnt)
	if cellCnt == 0 then
		self.m_CurrIndex = -1
	else
		if index then
		else
			self.m_CurrIndex = 1
		end
	end
	--local curOffset = self.mTableView.mInnerContainer:getContentOffset()
	--local curHeight = self.mTableView.mInnerContainer:getContentSize().height
	self.mTableView:reloadData()
	--self.mTableView.mInnerContainer:setContentOffset(cc.p(0,self.mTableView.mInnerContainer:getViewSize().height - self.mTableView.mInnerContainer:getContentSize().height))
	--local height = self.mTableView.mInnerContainer:getContentSize().height
	--curOffset.y = curOffset.y + (curHeight - height)
	--self.mTableView.mInnerContainer:setContentOffset(curOffset)
end

-- 世界信息
local HeroTitleInstance = nil

HeroTitleModel = class("HeroTitleModel")

function HeroTitleModel:ctor()
	self.mName         			= "HeroTitleModel"
	self.mOwner        			= nil
	self.mCurUseID				= nil
	self.mTitlelistTotal		= {}
	self.mTitleGetlist    		= {}
	self.mTitleNonelist    		= {}
	self.mPropertyTotalNum		= nil
	self.mPropertyTotalList  	= {}
	self.mEnterFun				= nil
	self:registerNetEvent()

end

function HeroTitleModel:getInstance()
	if HeroTitleInstance == nil then  
        HeroTitleInstance = HeroTitleModel.new()
    end  
    return HeroTitleInstance
end

function HeroTitleModel:destroyInstance()
	if HeroTitleInstance then
		HeroTitleInstance:deinit()
    	HeroTitleInstance = nil
    end
end

function HeroTitleModel:deinit()
    self.mOwner        			= nil
    self.mCurUseID				= nil
    self.mTitlelistTotal		= {}
	self.mTitleGetlist    		= {}
	self.mTitleNonelist    		= {}
	self.mEnterFun		= nil
	self:unRegisterNetEvent()
end

function HeroTitleModel:setOwner(owner)
	self.mOwner = owner
end

function HeroTitleModel:IshaveTitleById(_id)
	for k,v in pairs(self.mTitleGetlist) do
		if v.Id == _id then
			return true ,v.Time
		end
	end
	return false
end

function HeroTitleModel:GetTitleByTabIndex(index)
	if index == 1 then
		if #self.mTitlelistTotal > 0 then
			return self.mTitlelistTotal[1].Id
		end
	elseif index == 2 then
		if #self.mTitleGetlist > 0 then
			return self.mTitleGetlist[1].Id
		end
	elseif index == 3 then
		if #self.mTitleNonelist > 0 then
			return self.mTitleNonelist[1].Id
		end
	end
	return 0
end

function HeroTitleModel:registerNetEvent()
	NetSystem.mNetManager:RegisterPacketHandler(PacketTyper._PTYPE_SC_HEROTITLE_RESPONSE, handler(self, self.onTitleEnterInfoResponse))
	NetSystem.mNetManager:RegisterPacketHandler(PacketTyper._PTYPE_SC_USE_HEROTITLE_RESPONSE, handler(self, self.onUseTitle))
	NetSystem.mNetManager:RegisterPacketHandler(PacketTyper._PTYPE_SC_UNLOAD_HEROTITLE_RESPONSE, handler(self, self.onUnloadTitle))

end

function HeroTitleModel:unRegisterNetEvent()
	NetSystem.mNetManager:UnregisterPacketHandler(PacketTyper._PTYPE_SC_HEROTITLE_RESPONSE)
	NetSystem.mNetManager:UnregisterPacketHandler(PacketTyper._PTYPE_SC_USE_HEROTITLE_RESPONSE)
	NetSystem.mNetManager:UnregisterPacketHandler(PacketTyper._PTYPE_SC_UNLOAD_HEROTITLE_RESPONSE)

end

function HeroTitleModel:onTitleEnterInfoResponse(msgPacket)
	GUISystem:hideLoading()
	if self.mEnterFun then
		self.mEnterFun()
		self.mEnterFun = nil
	end
	self.mTitlelistTotal		= {}
	self.mTitleGetlist    		= {}
	self.mTitleNonelist    		= {}
	-- 当前使用的ID
	self.mCurUseID = msgPacket:GetInt() 

	self.mTitleNum = msgPacket:GetUShort()
	-- 总个数
	for i=1,self.mTitleNum do
		local TitleData = {}
		TitleData.Id = msgPacket:GetInt()  -- ID
		TitleData.isHave =  msgPacket:GetInt()	-- 0没有 1拥有 2过期 
		local Db_data = DB_PlayerTitle.getDataById(TitleData.Id)
		if TitleData.isHave == 1 then
			if Db_data.Time ~= 0 then
				TitleData.Time =  msgPacket:GetInt()
			end
			table.insert(self.mTitleGetlist,TitleData)
		else
			table.insert(self.mTitleNonelist,TitleData)
		end
		table.insert(self.mTitlelistTotal,TitleData)
	end

	local function sortFunc(section1, section2)
		return section1.Id < section2.Id
	end
	table.sort(self.mTitlelistTotal, sortFunc)
	table.sort(self.mTitleGetlist, sortFunc)
	table.sort(self.mTitlelistTotal,sortFunc)

	self.mPropertyTotalNum		= msgPacket:GetUShort()
	self.mPropertyTotalList  	= {}
	for i=1,self.mPropertyTotalNum do
		local Data = {}
		Data.Type = msgPacket:GetInt()
		Data.Value = msgPacket:GetInt()
		table.insert(self.mPropertyTotalList,Data)
	end

	if self.mOwner and self.mOwner.mRootNode then
		self.mOwner:UpdateLayout()
	else
		EventSystem:PushEvent(Event.GUISYSTEM_SHOW_HEROTITLEWINDOW)	
	end

end

function HeroTitleModel:onUseTitle(msgPacket)
	GUISystem:hideLoading()
	local result = msgPacket:GetChar() 
	if result == 0 then
		local TitleId = msgPacket:GetInt() 
		local index = self.mOwner.mTitleTableView.m_CurrIndex
		local cell = self.mOwner.mTitleTableView.mTableView.mInnerContainer:cellAtIndex(index-1)
		if cell then
			local widget = cell:getChildByTag(1)
			widget:getChildByName("Image_OnUse"):setVisible(true)
		end
		self.mCurUseID = TitleId
		self.mOwner:ChangeOnePropertyinfo(TitleId)
		self.mOwner:UpdateTableViewByTab()
		globaldata.mytitleId = self.mCurUseID
		FightSystem.mHallManager:onRoleBaseChange()
	else
		self:onTitleEnterRequst()
	end

	if HomeGuideOne:canGuide() then
		local guideBtn = self.mOwner.mTopRoleInfoPanel.mTopWidget:getChildByName("Button_Back")
		local size = guideBtn:getContentSize()
		local pos = guideBtn:getWorldPosition()
		pos.x = pos.x - size.width/2
		pos.y = pos.y - size.height/2
		local touchRect = cc.rect(pos.x, pos.y, size.width, size.height)
		HomeGuideOne:step(6, touchRect)
	end
end

function HeroTitleModel:onUnloadTitle(msgPacket)
	GUISystem:hideLoading()
	local result = msgPacket:GetChar() 
	if result == 0 then
		local TitleId = msgPacket:GetInt() 
		local index = self.mOwner.mTitleTableView.m_CurrIndex
		local cell = self.mOwner.mTitleTableView.mTableView.mInnerContainer:cellAtIndex(index-1)
		if cell then
			local widget = cell:getChildByTag(1)
			widget:getChildByName("Image_OnUse"):setVisible(false)
		end
		self.mCurUseID = 0
		self.mOwner:ChangeOnePropertyinfo(TitleId)
		globaldata.mytitleId = 0
		FightSystem.mHallManager:onRoleBaseChange()
	else
		self:onTitleEnterRequst()
	end
	
end

function HeroTitleModel:onTitleEnterRequst()
	local packet = NetSystem.mNetManager:GetSPacket()
    packet:SetType(PacketTyper._PTYPE_CS_HEROTITLE_REQUEST)
    packet:Send()
    GUISystem:showLoading()
end

function HeroTitleModel:onUseRequst(_id)
	local packet = NetSystem.mNetManager:GetSPacket()
    packet:SetType(PacketTyper._PTYPE_CS_USE_HEROTITLE_REQUEST)
    packet:PushInt(_id) 
    packet:Send()
    GUISystem:showLoading()
end

function HeroTitleModel:onUnloadRequst(_id)
	local packet = NetSystem.mNetManager:GetSPacket()
    packet:SetType(PacketTyper._PTYPE_CS_UNLOAD_HEROTITLE_REQUEST)
    packet:PushInt(_id) 
    packet:Send()
    GUISystem:showLoading()
end

local HeroTitleWindow = 
{
	mName					=	"HeroTitleWindow",
	mRootNode				=	nil,
	mRootWidget				=	nil,
	----------------------------------------	
}

function HeroTitleWindow:Release()

end

function HeroTitleWindow:Load()
	cclog("=====HeroTitleWindow:Load=====begin")

	self.mRootNode = cc.Node:create()
	GUISystem:GetRootNode():addChild(self.mRootNode)
	self:InitModelData()
	------

	self:InitLayout()

	local function doHomeGuide_Step5()
		local guideBtn = self.mRootWidget:getChildByName("Button_Use")
		local size = guideBtn:getContentSize()
		local pos = guideBtn:getWorldPosition()
		pos.x = pos.x - size.width/2
		pos.y = pos.y - size.height/2
		local touchRect = cc.rect(pos.x, pos.y, size.width, size.height)
		HomeGuideOne:step(5, touchRect)
	end
	if HomeGuideOne:canGuide() then
		local guideBtn = self.mTitleTableView.mTableView.mInnerContainer:cellAtIndex(0):getChildByTag(1)
		local size = guideBtn:getContentSize()
		local pos = guideBtn:getWorldPosition()
		local touchRect = cc.rect(pos.x, pos.y, size.width, size.height)
		HomeGuideOne:step(4, touchRect, nil, doHomeGuide_Step5)
	end

	cclog("=====HeroTitleWindow:Load=====end")
end

function HeroTitleWindow:InitModelData()
	self.mModel = HeroTitleModel:getInstance()
	self.mModel:setOwner(self)
end

function HeroTitleWindow:InitLayout()

	self.mRootWidget = GUIWidgetPool:createWidget("Setting_PlayerTitleReplace")
	self.mRootNode:addChild(self.mRootWidget)
	self.mMainWidget = self.mRootWidget:getChildByName("Panel_Main")
	self.mCurTabIndex = 1 -- 全部
	self.mMainWidget:getChildByName("Image_Page_All"):loadTexture("setting_playertitle_page_all_1.png")
	self.mTitleTableView = TitleTableView:new(self,0)
	self.mTitleTableView:init(self.mMainWidget:getChildByName("TableView"))
	self.LeftTimeLabel = self.mMainWidget:getChildByName("Panel_OneProperty"):getChildByName("Label_Time")
	local function closeWindow()
		EventSystem:PushEvent(Event.GUISYSTEM_HIDE_HEROTITLEWINDOW)

		local function doHomeGuide_Stop()
			HomeGuideOne:stop()
		end
		HomeGuideOne:step(7, nil, doHomeGuide_Stop)
	end
	self:ChangeTatalPropertyinfo()
	self:ChangeOnePropertyinfo(self.mModel:GetTitleByTabIndex(self.mCurTabIndex))

	self.mTopRoleInfoPanel = TopRoleInfoPanel:new()
	local topInfoPanel = self.mTopRoleInfoPanel:init(self.mRootNode,ROLE_TITLE_TYPE.TITLE_HEROTITLE, closeWindow)

	local mainPanel = self.mRootWidget:getChildByName("Panel_Window")
	local topSize = self.mTopRoleInfoPanel.mTopWidget:getContentSize()
	local y = getGoldFightPosition_Middle().y - topSize.height / 2
	local x = getGoldFightPosition_Middle().x
	mainPanel:setAnchorPoint(cc.p(0.5, 0.5))
	mainPanel:setPosition(cc.p(x,y))

	registerWidgetReleaseUpEvent(self.mMainWidget:getChildByName("Image_Page_All"), handler(self,self.Page_All))
	registerWidgetReleaseUpEvent(self.mMainWidget:getChildByName("Image_Page_Got"), handler(self,self.Page_Got))
	registerWidgetReleaseUpEvent(self.mMainWidget:getChildByName("Image_Page_Others"), handler(self,self.Page_Others))

	registerWidgetReleaseUpEvent(self.mMainWidget:getChildByName("Button_Use"), handler(self,self.onUseBtn))

	self.mTimeScheduler = cc.Director:getInstance():getScheduler():scheduleScriptFunc(handler(self, self.UpdateTimeLine), 1, false)
end

		
function HeroTitleWindow:UpdateTableViewByTab()

	local cpTableCurOffset = self.mTitleTableView.mTableView.mInnerContainer:getContentOffset()	
	local fTableCurHeight = self.mTitleTableView.mTableView.mInnerContainer:getContentSize().height

	if self.mCurTabIndex == 1 then
		self.mTitleTableView:UpdateTableView(#self.mModel.mTitlelistTotal,true)
	elseif self.mCurTabIndex == 2 then
		self.mTitleTableView:UpdateTableView(#self.mModel.mTitleGetlist,true)
	elseif self.mCurTabIndex == 3 then
		self.mTitleTableView:UpdateTableView(#self.mModel.mTitleNonelist,true)
	end

	local curHeight = self.mTitleTableView.mTableView.mInnerContainer:getContentSize().height;
	cpTableCurOffset.y = cpTableCurOffset.y + (fTableCurHeight - curHeight)
	self.mTitleTableView.mTableView.mInnerContainer:setContentOffset(cpTableCurOffset)

end

function HeroTitleWindow:Page_All()
	if self.mCurTabIndex == 1 then return end
	if self.mCurTabIndex == 2 then
		self.mMainWidget:getChildByName("Image_Page_Got"):loadTexture("setting_playertitle_page_got_2.png")
	elseif self.mCurTabIndex == 3 then
		self.mMainWidget:getChildByName("Image_Page_Others"):loadTexture("setting_playertitle_page_others_2.png")
	end
	self.mCurTabIndex = 1
	self.mTitleTableView:UpdateTableView(#self.mModel.mTitlelistTotal)
	self:ChangeOnePropertyinfo(self.mModel:GetTitleByTabIndex(self.mCurTabIndex))
	self.mMainWidget:getChildByName("Image_Page_All"):loadTexture("setting_playertitle_page_all_1.png")
end

function HeroTitleWindow:Page_Got()
	if self.mCurTabIndex == 2 then return end
	if self.mCurTabIndex == 1 then
		self.mMainWidget:getChildByName("Image_Page_All"):loadTexture("setting_playertitle_page_all_2.png")
	elseif self.mCurTabIndex == 3 then
		self.mMainWidget:getChildByName("Image_Page_Others"):loadTexture("setting_playertitle_page_others_2.png")
	end
	self.mCurTabIndex = 2
	self.mTitleTableView:UpdateTableView(#self.mModel.mTitleGetlist)
	self:ChangeOnePropertyinfo(self.mModel:GetTitleByTabIndex(self.mCurTabIndex))
	self.mMainWidget:getChildByName("Image_Page_Got"):loadTexture("setting_playertitle_page_got_1.png")
end

function HeroTitleWindow:Page_Others()
	if self.mCurTabIndex == 3 then return end
	if self.mCurTabIndex == 1 then
		self.mMainWidget:getChildByName("Image_Page_All"):loadTexture("setting_playertitle_page_all_2.png")
	elseif self.mCurTabIndex == 2 then
		self.mMainWidget:getChildByName("Image_Page_Got"):loadTexture("setting_playertitle_page_got_2.png")
	end
	self.mCurTabIndex = 3
	self.mTitleTableView:UpdateTableView(#self.mModel.mTitleNonelist)
	self:ChangeOnePropertyinfo(self.mModel:GetTitleByTabIndex(self.mCurTabIndex))
	self.mMainWidget:getChildByName("Image_Page_Others"):loadTexture("setting_playertitle_page_others_1.png")
end

function HeroTitleWindow:onUseBtn()

	if self.mBtnState == 1 then
		self.mModel:onUseRequst(self.mShowPropertyinfoId)
	else
		self.mModel:onUnloadRequst(self.mShowPropertyinfoId)
	end
end

function HeroTitleWindow:UpdateLayout()
	self.misWaitUpdate = nil
	self.mCurTabIndex = 1
	self.mMainWidget:getChildByName("Image_Page_All"):loadTexture("setting_playertitle_page_all_1.png")
	self.mMainWidget:getChildByName("Image_Page_Got"):loadTexture("setting_playertitle_page_got_2.png")
	self.mMainWidget:getChildByName("Image_Page_Others"):loadTexture("setting_playertitle_page_others_2.png")
	self:ChangeOnePropertyinfo(self.mModel:GetTitleByTabIndex(self.mCurTabIndex))
	self.mTitleTableView:UpdateTableView(#self.mModel.mTitlelistTotal)
end

function HeroTitleWindow:ChangeTatalPropertyinfo()
	local panelTotalProperty = self.mMainWidget:getChildByName("Panel_TotalProperty")
	for i=1,#self.mModel.mPropertyTotalList do
		local panel = panelTotalProperty:getChildByName(string.format("Panel_Property_%d",i))
		panel:setVisible(true)
		panel:getChildByName("Label_Property"):setString(string.format("+ %d",self.mModel.mPropertyTotalList[i].Value))
		panel:getChildByName("Image_Property"):loadTexture("hero_property_"..self.mModel.mPropertyTotalList[i].Type..".png")
	end
end

function HeroTitleWindow:ChangeOnePropertyinfo(_id)
	self.mCurOnePropertyId = _id
	self.LeftTime = nil
	self.FixTime = nil
	local panelOneProperty = self.mMainWidget:getChildByName("Panel_OneProperty")
	if _id == 0 then
		panelOneProperty:setVisible(false)
	else
		self.mShowPropertyinfoId = _id
		panelOneProperty:setVisible(true)
		local TitleData = DB_PlayerTitle.getDataById(_id)
		panelOneProperty:getChildByName("Image_OnUse"):setVisible(false)
		panelOneProperty:getChildByName("Panel_Property_1"):setVisible(false)
		panelOneProperty:getChildByName("Panel_Property_2"):setVisible(false)
		panelOneProperty:getChildByName("Panel_Property_3"):setVisible(false)
		panelOneProperty:getChildByName("Panel_Property_4"):setVisible(false)
		panelOneProperty:getChildByName("Label_Name"):setString(getDictionaryText(TitleData.Name))
		panelOneProperty:getChildByName("Label_Desc"):setString(getDictionaryText(TitleData.Description))
		panelOneProperty:getChildByName("Image_Icon"):setVisible(false)
		panelOneProperty:getChildByName("Panel_AnimationIcon"):setVisible(false)
		if TitleData.DisplayMode == 1 then
			local _resDB = DB_ResourceList.getDataById(TitleData.Picture)
			panelOneProperty:getChildByName("Image_Icon"):loadTexture(_resDB.Res_path1)
			panelOneProperty:getChildByName("Image_Icon"):setVisible(true)
		else
			panelOneProperty:getChildByName("Panel_AnimationIcon"):removeAllChildren()
			panelOneProperty:getChildByName("Panel_AnimationIcon"):setVisible(true)
			local star = AnimManager:createAnimNode(TitleData.Picture)
			panelOneProperty:getChildByName("Panel_AnimationIcon"):addChild(star:getRootNode(), 100)
			star:play("player_title",true)
		end
		local flag , time = self.mModel:IshaveTitleById(_id)
		if flag then
			if TitleData.Time ~= 0 then
				self.LeftTime = time
			else
				self.FixTime = 0
			end
			panelOneProperty:getChildByName("Button_Use"):setVisible(true)
			if _id == self.mModel.mCurUseID then
				panelOneProperty:getChildByName("Image_OnUse"):setVisible(true)
				panelOneProperty:getChildByName("Button_Use"):getChildByName("Label_Use"):setString("取消显示")
				self.mBtnState = 2
			else
				panelOneProperty:getChildByName("Button_Use"):getChildByName("Label_Use"):setString("显示称号")
				self.mBtnState = 1
			end
		else
			self.FixTime = TitleData.Time
			panelOneProperty:getChildByName("Button_Use"):setVisible(false)
		end

		for i=1,TitleData.Number do
			local panel = panelOneProperty:getChildByName(string.format("Panel_Property_%d",i))
			panel:setVisible(true)
			local Value = TitleData[string.format("Value%d",i)]
			local talentType = TitleData[string.format("Type%d",i)]
			panel:getChildByName("Label_Property"):setString(string.format("+ %d",Value))

			panel:getChildByName("Image_Property"):loadTexture("hero_property_"..talentType..".png")
		end

		if self.LeftTime then
			self.LeftTime = self.LeftTime - 1
			if self.LeftTime >= 0 then
				self.LeftTimeLabel:setString(timeFormat(self.LeftTime))
			end
		else
			if self.FixTime == 0 then
				self.LeftTimeLabel:setString("永久生效")
			else
				self.LeftTimeLabel:setString(timeFormat(self.FixTime))
			end
		end
	end
end

function HeroTitleWindow:UpdateTimeLine()
	if self.misWaitUpdate then return end
	for k,v in pairs(self.mModel.mTitlelistTotal) do
		local data = DB_PlayerTitle.getDataById(v.Id)
		if v.isHave == 1 and data.Time ~= 0 then
			if v.Time > 0 then
				v.Time = v.Time - 1
			else
				if self.mModel.mCurUseID ~= 0 and self.mModel.mCurUseID == self.mCurOnePropertyId and v.Id == self.mModel.mCurUseID then
					self.misWaitUpdate = true
					GUISystem:showLoading()
					HeroTitleModel:getInstance():onTitleEnterRequst()
				end
			end
		end
	end
	if self.mCurOnePropertyId ~= 0 then
		if self.LeftTime then
			self.LeftTime = self.LeftTime - 1
			if self.LeftTime >= 0 then
				self.LeftTimeLabel:setString(timeFormat(self.LeftTime))
			end
		else
			if self.FixTime == 0 then
				self.LeftTimeLabel:setString("永久生效")
			else
				self.LeftTimeLabel:setString(timeFormat(self.FixTime))
			end
		end
	end
end

function HeroTitleWindow:Destroy()
	self.misWaitUpdate = nil
	self.mTopRoleInfoPanel:destroy()
	self.mTopRoleInfoPanel = nil
	if self.mTimeScheduler then
		cc.Director:getInstance():getScheduler():unscheduleScriptEntry(self.mTimeScheduler)
		self.mTimeScheduler = nil
	end

	self.mRootNode:removeFromParent(true)
	self.mRootNode = nil
	self.mRootWidget = nil
	self.mModel:destroyInstance()
	self.mModel = nil

	------------
	CommonAnimation.clearAllTextures()
end

function HeroTitleWindow:onEventHandler(event)
	if event.mAction == Event.WINDOW_SHOW then
		if GUISystem:canShow(self.mName) then
			self:Load(event)
			---------停止画主城镇界面
			EventSystem:PushEvent(Event.GUISYSTEM_DISABLEDRAW_HOMEWINDOW)
		end
	elseif event.mAction == Event.WINDOW_HIDE then
		self:Destroy()
		---------开启画主城镇界面
		EventSystem:PushEvent(Event.GUISYSTEM_EABLEDRAW_HOMEWINDOW)
	end
end

return HeroTitleWindow