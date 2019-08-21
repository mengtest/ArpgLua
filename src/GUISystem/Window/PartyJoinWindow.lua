-- Name: 	PartyJoinWindow
-- Func：	加入帮会界面
-- Author:	lichuan
-- Data:	16-1-28
--==========================================================partyTv begin ==================================================================
PartyTableView = {}

function PartyTableView:new(owner,listType)
	local o = 
	{
		mOwner			  = owner,
		mRootNode 	      =	nil,
		mType 		      =	listType,
		mTableView	      =	nil,
	}
	o = newObject(o, PartyTableView)
	return o
end

function PartyTableView:Destroy()
	self.mRootNode:removeFromParent(true)
	self.mRootNode     = nil
	self.mTableView    = nil
	self.mOwner        = nil
end

function PartyTableView:myModel()
	return self.mOwner.mModel
end

function PartyTableView:init(rootNode)
	self.mRootNode = rootNode
	-- 初始化数据源
	--self:myModel():doLoadDataRequest(PacketTyper._PTYPE_CS_REQUEST_FRIEND_LIST_,nil)
	self:initTableView()
end

function PartyTableView:initTableView()
	self.mTableView = TableViewEx:new()

	local widget = GUIWidgetPool:createWidget("Guild_GuildCell")

	self.mTableView:setCellSize(widget:getContentSize())
	if self.mOwner.mType == 1 then
		self.mTableView:setCellCount(#self.mOwner.mModel.mPartyInfoArr)
	else
		self.mTableView:setCellCount(#self.mOwner.mModel.mSearchInfoArr)
	end

	self.mTableView:registerTableCellAtIndexFunc(handler(self, self.tableCellAtIndex))
	self.mTableView:registerTableCellTouchedFunc(handler(self, self.tableCellTouched))

	self.mTableView:init(self.mRootNode:getContentSize(), cc.p(0,0), 1)
	self.mRootNode:addChild(self.mTableView:getRootNode())
end

function PartyTableView:tableCellAtIndex(table, index)
	local cell = table:dequeueCell()
	local partyItem = nil

	if nil == cell then
		cell = cc.TableViewCell:new()
		partyItem = GUIWidgetPool:createWidget("Guild_GuildCell")
		
		partyItem:setTouchSwallowed(false)
		partyItem:setTag(1)
		cell:addChild(partyItem)
	else
		partyItem = cell:getChildByTag(1)
	end

	--if #self:myModel().mPartyInfoArr ~= 0 then
		self:setCellLayOut(partyItem,index)
	--end
	
	return cell
end

function PartyTableView:setCellLayOut(widget,index)
	local partyInfo = nil
	if self.mOwner.mType == 1 then
		partyInfo = self:myModel().mPartyInfoArr[index + 1]
	else
		partyInfo = self:myModel().mSearchInfoArr[index + 1]
	end
	if partyInfo == nil then return end

	widget:getChildByName("Label_Name"):setString(partyInfo.mPartyNameStr)
	widget:getChildByName("Label_RequiredLevel"):setString(string.format("需要组织等级 %d", partyInfo.mJoinLimitLv))
	local memberCnt    = partyInfo.mMemberCnt
	local memberMaxCnt = partyInfo.mMemberMaxCnt
	local partyLv      = partyInfo.mPartyLv

	widget:getChildByName("Label_Level"):setString(string.format("Lv %d",partyLv))
	widget:getChildByName("Label_Member"):setString(string.format("成员 %d/%d",memberCnt,memberMaxCnt))

	local resId = DB_GuildIcon.getDataById(partyInfo.mPartyIconId).ResourceListID
	local resData = DB_ResourceList.getDataById(resId)
	widget:getChildByName("Image_GuildIcon"):loadTexture(resData.Res_path1)

	local btnJoin = widget:getChildByName("Button_Join")
	btnJoin:setTag(index)

	if partyInfo.mIsApplyed == 1 then
		btnJoin:setTouchEnabled(false)
		btnJoin:getChildByName("Label_8"):setString("已申请") 
		ShaderManager:DoUIWidgetDisabled(btnJoin, true)  
	else
		btnJoin:setTouchEnabled(memberCnt ~= memberMaxCnt)
		btnJoin:getChildByName("Label_8"):setString("申请")  
		ShaderManager:DoUIWidgetDisabled(btnJoin,memberCnt == memberMaxCnt)  
	end

	registerWidgetReleaseUpEvent(btnJoin,
	function(widget) 
		GUISystem:playSound("homeBtnSound")
		--if self.mOwner.mModel.mApplyCnt >= 3 then MessageBox:showMessageBox1("您已申请的帮会不能超过3个！") return end
		-- btnJoin:setTouchEnabled(false)
		-- btnJoin:getChildByName("Label_8"):setString("已申请")  
		-- ShaderManager:DoUIWidgetDisabled(btnJoin, true)  
		self:myModel():doJoinPartyRequest(btnJoin:getTag() + 1) 
	end)
end

function PartyTableView:tableCellTouched(table,cell)
	print("PartyTableView cell touched at index: " .. cell:getIdx())

end

function PartyTableView:UpdateTableView(cellCnt) --move table to cur cell after reload
	self.mTableView:setCellCount(cellCnt)

	--local curOffset = self.mTableView.mInnerContainer:getContentOffset()
	--local curHeight = self.mTableView.mInnerContainer:getContentSize().height
	self.mTableView:reloadData()
	--self.mTableView.mInnerContainer:setContentOffset(cc.p(0,self.mTableView.mInnerContainer:getViewSize().height - self.mTableView.mInnerContainer:getContentSize().height))
	--local height = self.mTableView.mInnerContainer:getContentSize().height
	--curOffset.y = curOffset.y + (curHeight - height)
	--self.mTableView.mInnerContainer:setContentOffset(curOffset)
end

--==========================================================model begin ==================================================================

local PartyInfo = {}
function PartyInfo:new()
	local o = 
	{
		mPartyIdStr 			    = nil,	-- 帮派ID
		mPartyIconId				= nil,	-- 帮派Icon
		mPartyNameStr			    = nil,	-- 帮派名字
		mPartyLv                    = 0,	-- 帮派等级
		mBuildValue 				= 0,	-- 建设点数
		mMemberCnt			        = 0,	-- 帮派当前人数
		mMemberMaxCnt		        = 0,	-- 帮派人数上限
		mBulletin                   = "",	-- 帮派宣言
		mIsApplyed					= 0	,   -- 是否申请
		mJoinLimitLv				= 0,	-- 加入等级		
	}
	o = newObject(o, PartyInfo)
	return o
end

function PartyInfo:getKeyValue(key)
	if self[key] then
		return self[key]
	end
	return nil
end

local PJMInstance = nil

PartyJoinModel = class("PartyJoinModel")

function PartyJoinModel:ctor()
	self.mName		    = "PartyJoinModel"
	self.mOwner         = nil

	self.mPartyInfoArr  = {}
	self.mSearchInfoArr = {}
	self.mApplyCnt      = 0

	self:registerNetEvent()
end

function PartyJoinModel:deinit()
	self.mName  	     = nil
	self.mOwner 	     = nil

	self.mPartyInfoArr   = {}
	self.mSearchInfoArr  = {}
	self.mApplyCnt       = 0

	self:unRegisterNetEvent()
end

function PartyJoinModel:getInstance()
	if PJMInstance == nil then  
        PJMInstance = PartyJoinModel.new()
    end  
    return PJMInstance
end

function PartyJoinModel:destroyInstance()
	if PJMInstance then
		PJMInstance:deinit()
    	PJMInstance = nil
    end
end

function PartyJoinModel:registerNetEvent()
	NetSystem.mNetManager:RegisterPacketHandler(PacketTyper._PARTY_SC_PARTYARR_INFO_RESPONSE, handler(self, self.onPartyArrInfoResponse))
	NetSystem.mNetManager:RegisterPacketHandler(PacketTyper._PARTY_SC_SEARCH_PARTY_RESPONSE, handler(self, self.onSearchPartyResponse))
	NetSystem.mNetManager:RegisterPacketHandler(PacketTyper._PTYPE_SC_CREATE_PARTY_RESPONSE, handler(self, self.onCreatePartyResponse))
	NetSystem.mNetManager:RegisterPacketHandler(PacketTyper._PARTY_SC_JOIN_PARTY_RESPONSE, handler(self, self.onJoinPartyResponse))
end

function PartyJoinModel:unRegisterNetEvent()
	NetSystem.mNetManager:UnregisterPacketHandler(PacketTyper._PARTY_SC_PARTYARR_INFO_RESPONSE)
	NetSystem.mNetManager:UnregisterPacketHandler(PacketTyper._PARTY_SC_SEARCH_PARTY_RESPONSE)
	NetSystem.mNetManager:UnregisterPacketHandler(PacketTyper._PTYPE_SC_CREATE_PARTY_RESPONSE)
	NetSystem.mNetManager:UnregisterPacketHandler(PacketTyper._PARTY_SC_JOIN_PARTY_RESPONSE)
end

function PartyJoinModel:setOwner(owner)
	self.mOwner = owner
end

function PartyJoinModel:doLoadPartyArrInfo()
	if #self.mPartyInfoArr ~= 0 then return end
	local packet = NetSystem.mNetManager:GetSPacket()
    packet:SetType(PacketTyper._PARTY_CS_PARTYARR_INFO_REQUEST)
    packet:Send()
    GUISystem:showLoading()
end

function PartyJoinModel:onPartyArrInfoResponse(msgPacket)
	local partyCnt = msgPacket:GetChar()

	for i=1,partyCnt do
		local partyInfo                     = PartyInfo:new()
		partyInfo.mPartyIdStr 			    = msgPacket:GetString()
		partyInfo.mPartyIconId				= msgPacket:GetInt()
		partyInfo.mPartyNameStr			    = msgPacket:GetString()
		partyInfo.mPartyLv                  = msgPacket:GetInt()
		partyInfo.mBuildValue               = msgPacket:GetInt()
		partyInfo.mMemberCnt			    = msgPacket:GetUShort()
		partyInfo.mMemberMaxCnt		        = msgPacket:GetUShort()
		partyInfo.mBulletin					= msgPacket:GetString()	
		partyInfo.mIsApplyed				= msgPacket:GetInt()
		partyInfo.mJoinLimitLv              = msgPacket:GetInt()
		if partyInfo.mIsApplyed == 1 then
			self.mApplyCnt = self.mApplyCnt + 1
		end

		table.insert(self.mPartyInfoArr,partyInfo)
	end

	self.mCreateCost     = msgPacket:GetInt()

	if self.mOwner then
		self.mOwner.mRootWidget:getChildByName("Label_CreatCost"):setString(tostring(self.mCreateCost))
		if self.mOwner.mPartyTV ~= nil then
			self.mOwner.mPartyTV:UpdateTableView(#self.mPartyInfoArr)
		end
	end
	GUISystem:hideLoading()
end

function PartyJoinModel:doSearchPartyRequest(partyName)
	if partyName == "" then return end
	local packet = NetSystem.mNetManager:GetSPacket()
    packet:SetType(PacketTyper._PARTY_CS_SEARCH_PARTY_REQUEST)
    packet:PushString(partyName)
    packet:Send()
    GUISystem:showLoading()
end

function PartyJoinModel:onSearchPartyResponse(msgPacket)
	local partyCnt = msgPacket:GetChar()
	self.mSearchInfoArr = {}
	for i=1,partyCnt do
		local partyInfo                     = PartyInfo:new()
		partyInfo.mPartyIdStr 			    = msgPacket:GetString()
		partyInfo.mPartyIconId				= msgPacket:GetInt()
		partyInfo.mPartyNameStr			    = msgPacket:GetString()
		partyInfo.mPartyLv                  = msgPacket:GetInt()
		partyInfo.mBuildValue               = msgPacket:GetInt()
		partyInfo.mMemberCnt			    = msgPacket:GetUShort()
		partyInfo.mMemberMaxCnt		        = msgPacket:GetUShort()
		partyInfo.mBulletin					= msgPacket:GetString()	
		partyInfo.mIsApplyed				= msgPacket:GetInt()
		partyInfo.mJoinLimitLv              = msgPacket:GetInt()
		if partyInfo.mIsApplyed == 1 then
			self.mApplyCnt = self.mApplyCnt + 1
		end

		table.insert(self.mSearchInfoArr,partyInfo)
		print(partyInfo.mPartyNameStr)

	end

	if self.mOwner.mSearchTV ~= nil then
		self.mOwner.mSearchTV:UpdateTableView(#self.mSearchInfoArr)
	end
	GUISystem:hideLoading()
end

function PartyJoinModel:doCreatePartyRequest(partyName,iconId)
	local name = string.gsub(partyName, " ", "")
	if name == ""  then MessageBox:showMessageBox1("名字不能为空！")  return end
	if globaldata.money < self.mCreateCost then MessageBox:showMessageBox1("金钱不足！")  return end  

	self.mPartyIconIdTmp = iconId

	local packet = NetSystem.mNetManager:GetSPacket()
	packet:SetType(PacketTyper._PTYPE_CS_CREATE_PARTY_REQUEST)
	packet:PushInt(iconId)
	packet:PushString(name)
	packet:Send()
	GUISystem:showLoading()
end

function PartyJoinModel:onCreatePartyResponse(msgPacket)
	local ret = msgPacket:GetChar()

	if ret == 0 then 
		self.mPartyName        = msgPacket:GetString()
		globaldata.partyName   = self.mPartyName
		self.mMemberCnt        = msgPacket:GetInt()
		self.mPartyId          = msgPacket:GetString()
		globaldata.partyId     = self.mPartyId
		globaldata.partyIconId = self.mPartyIconIdTmp
		self.mPartyRole        = msgPacket:GetChar()
		self.mBulletin		   = msgPacket:GetString()
		self.mJoinLimitType    = msgPacket:GetInt()
		self.mJoinLimitLv      = msgPacket:GetInt()
		self.mMemberMaxCnt     = msgPacket:GetInt()
		self.mPartyLv          = msgPacket:GetInt()
		self.mCurExp           = msgPacket:GetInt()
		self.mMaxExp           = msgPacket:GetInt()

		local msgCnt = msgPacket:GetChar()

		self.mMsgdeque		 = {}
		for i=1,msgCnt do
			local msgTime    = msgPacket:GetString()
			local msgPlayer  = msgPacket:GetString()
			local msgContent = msgPacket:GetString()
			local msg        = {msgTime,msgPlayer,msgContent}
			table.insert(self.mMsgdeque,msg)
		end

		GUISystem:hideLoading()
		UnionSubManager:enterUnionHall()
	else
		GUISystem:hideLoading()
		MessageBox:showMessageBox1("创建失败！")
	end
end

function PartyJoinModel:doJoinPartyRequest(index)
	--if self.mApplyCnt > 3 then MessageBox:showMessageBox1("申请次数不足！") return end
	self.mApplyIndex = index

	local partyInfo = nil
	if self.mOwner.mType == 1 then
		partyInfo = self.mPartyInfoArr[index]
	elseif self.mOwner.mType == 2 then 
		partyInfo = self.mSearchInfoArr[index]
	else

	end

	local packet = NetSystem.mNetManager:GetSPacket()
    packet:SetType(PacketTyper._PARTY_CS_JOIN_PARTY_REQUEST)
    packet:PushString(partyInfo.mPartyIdStr)
    packet:Send()
    GUISystem:showLoading()
end

function PartyJoinModel:onJoinPartyResponse(msgPacket)
	local ret = msgPacket:GetChar()

	if ret == SUCCESS then
		self.mPartyInfoArr[self.mApplyIndex].mIsApplyed = 1
		self.mApplyCnt =  msgPacket:GetInt()
	end

	GUISystem:hideLoading()
	if self.mOwner.mPartyTV ~= nil then 
		if self.mOwner.mType == 1 then
			self.mOwner.mPartyTV:UpdateTableView(#self.mPartyInfoArr)
		elseif self.mOwner.mType == 2 then 
			self.mOwner.mSearchTV:UpdateTableView(#self.mSearchInfoArr)
		else

		end
	end
end

--==================================================================window begin=========================================================================

local PartyJoinWindow = 
{
	mName 				= "PartyJoinWindow",
	mRootNode			=	nil,	
	mRootWidget 		= 	nil,
	mTopRoleInfoPanel	=	nil,	-- 顶部人物信息面板
	mPartyTV	        =   nil,
	mSearchTV	        =   nil,
	mSearchEdit			=   nil,
	mCreateEdit         =   nil, 
	mModel				=   nil,
}

function PartyJoinWindow:Load(event)
	cclog("=====PartyJoinWindow:Load=====begin")

	self.mRootNode = cc.Node:create()
	GUISystem:GetRootNode():addChild(self.mRootNode)

	--self.mEventData    = event.mData
	self.mModel = PartyJoinModel:getInstance()
	self.mModel:setOwner(self)
	
	self:InitLayout()

	local function doGonghuiGuideOne_Stop()
		GonghuiGuideOne:stop()
	end
	GonghuiGuideOne:step(1, nil, doGonghuiGuideOne_Stop)
	
	cclog("=====PartyJoinWindow:Load=====end")
end

function PartyJoinWindow:InitLayout()
	if self.mRootWidget == nil then
		self.mRootWidget = GUIWidgetPool:createWidget("Guild_Join")
   		self.mRootNode:addChild(self.mRootWidget)
   	end

   	if self.mTopRoleInfoPanel == nil then
		cclog("PartyJoinWindow mTopRoleInfoPanel init")
		self.mTopRoleInfoPanel = TopRoleInfoPanel:new()
		self.mTopRoleInfoPanel:init(self.mRootNode, ROLE_TITLE_TYPE.TITLE_PARTY_JOIN,
		function()
			GUISystem:playSound("homeBtnSound")		
			EventSystem:PushEvent(Event.GUISYSTEM_HIDE_PARTYJOINWINDOW)	
		end)
	end

	local topSize = self.mTopRoleInfoPanel.mTopWidget:getContentSize()
	local y = getGoldFightPosition_Middle().y - topSize.height / 2
	local x = getGoldFightPosition_Middle().x

	local mainPanel = self.mRootWidget:getChildByName("Panel_Main")
	mainPanel:setAnchorPoint(0.5,0.5)
	mainPanel:setPosition(cc.p(x,y))

	local tvParty = self.mRootWidget:getChildByName("Panel_ListBg"):getChildByName("Panel_List")
	if self.mPartyTV == nil then
		self.mPartyTV = PartyTableView:new(self,0)
		self.mPartyTV:init(tvParty)
	end


	local tvParty1 = self.mRootWidget:getChildByName("Panel_Search"):getChildByName("Panel_List")
	if self.mSearchTV == nil then
		self.mSearchTV = PartyTableView:new(self,0)
		self.mSearchTV:init(tvParty1)
	end

	self:InitPages()
end

function PartyJoinWindow:InitPages()
	local pap = {{},{},{}}
	pap[1][1] = self.mRootWidget:getChildByName("Image_RankingList")
	pap[2][1] = self.mRootWidget:getChildByName("Image_Search")
	pap[3][1] = self.mRootWidget:getChildByName("Image_Creat")
	pap[1][2] = self.mRootWidget:getChildByName("Panel_ListBg")
	pap[2][2] = self.mRootWidget:getChildByName("Panel_Search")
	pap[3][2] = self.mRootWidget:getChildByName("Panel_Creat")
	
	local funcs = { function() self.mModel:doLoadPartyArrInfo() end ,function() end ,function() end }
	local imgs = {{"guild_join_page_ranking_1.png","guild_join_page_ranking_2.png"},
				  {"guild_join_page_search_1.png","guild_join_page_search_2.png"},
				  {"guild_join_page_creat_1.png","guild_join_page_creat_2.png"}}

	local function OnPressPages(widget)	
		for i=1,#pap do
			if pap[i][1] == widget then
				pap[i][1]:loadTexture(imgs[i][1])
				pap[i][2]:setVisible(true)
				funcs[i]()
				self.mType = i
			else
				pap[i][1]:loadTexture(imgs[i][2])
				pap[i][2]:setVisible(false)
			end
		end
	end

	for i=1,#pap do
		registerWidgetReleaseUpEvent(pap[i][1],OnPressPages)
	end

	OnPressPages(pap[1][1])


	local size = pap[2][2]:getChildByName("Image_InputBg"):getContentSize()
	local pos = pap[2][2]:getChildByName("Image_InputBg"):getPosition()

	self.mSearchEdit = cc.EditBox:create(size, cc.Scale9Sprite:create("editbox_bg.png"))
	self.mSearchEdit:setFont("res/fonts/font_3.ttf", 20)
	--self.mSearchEdit:setFontSize(20)
	pap[2][2]:getChildByName("Image_InputBg"):addChild(self.mSearchEdit)
	self.mSearchEdit:setAnchorPoint(0,0)
	self.mSearchEdit:setPosition(pos)

	local function editBoxTextEventHandle(strEventName,pSender)

		if strEventName == "began" then
			
		elseif strEventName == "ended" then
				
		elseif strEventName == "return" then
			
		elseif strEventName == "changed" then
			
		end

	end

	pap[2][2]:getChildByName("Label_77"):setVisible(false)
	self.mSearchEdit:registerScriptEditBoxHandler(editBoxTextEventHandle)

	registerWidgetReleaseUpEvent(pap[2][2]:getChildByName("Button_Search"), function() self.mModel:doSearchPartyRequest(self.mSearchEdit:getText()) end)

	local size1 = pap[3][2]:getChildByName("Image_NameInputBg"):getContentSize()
	local pos1 = pap[3][2]:getChildByName("Image_NameInputBg"):getPosition()

	self.mCreateEdit = cc.EditBox:create(size, cc.Scale9Sprite:create("editbox_bg.png"))
	self.mCreateEdit:setFont("res/fonts/font_3.ttf", 20)
	pap[3][2]:getChildByName("Image_NameInputBg"):addChild(self.mCreateEdit)
	self.mCreateEdit:setAnchorPoint(0,0)
	self.mCreateEdit:setPosition(pos)

	local function editBoxTextEventHandle(strEventName,pSender)
		if strEventName == "began" then	

		elseif strEventName == "ended" then	

		elseif strEventName == "return" then	

		elseif strEventName == "changed" then		
		end
	end

	self.mCreateEdit:registerScriptEditBoxHandler(editBoxTextEventHandle)
	pap[3][2]:getChildByName("Label_20"):setVisible(false)

	local iconId = 1

	local resId = DB_GuildIcon.getDataById(iconId).ResourceListID
	local resData = DB_ResourceList.getDataById(resId)
	pap[3][2]:getChildByName("Image_Icon"):loadTexture(resData.Res_path1)

	local function ShowPartyIcon()
		local iconChosePanel = GUIWidgetPool:createWidget("Guild_IconReplace")
		iconChosePanel:setTouchEnabled(true)

		local function closeWindow()
			local resId = DB_GuildIcon.getDataById(iconId).ResourceListID
			local resData = DB_ResourceList.getDataById(resId)
			pap[3][2]:getChildByName("Image_Icon"):loadTexture(resData.Res_path1)

			iconChosePanel:removeFromParent() 
			iconChosePanel = nil 
		end

		registerWidgetReleaseUpEvent(iconChosePanel,closeWindow)
		registerWidgetReleaseUpEvent(iconChosePanel:getChildByName("Button_Close"),closeWindow)
		registerWidgetReleaseUpEvent(iconChosePanel:getChildByName("Button_Save"),closeWindow)

		self.mRootNode:addChild(iconChosePanel,1000)

		local lastSel = nil

		local function OnSelectIcon(widget)
			if lastSel then 
				lastSel:getChildByName("Image_Chose"):setVisible(false)
			end
			iconId = widget:getTag()
			widget:getChildByName("Image_Chose"):setVisible(true) 
			lastSel = widget
		end

		for i=1,12 do
			local resId = DB_GuildIcon.getDataById(i).ResourceListID
			local resData = DB_ResourceList.getDataById(resId)
			local icon = iconChosePanel:getChildByName(string.format("Panel_icon_%d",i))

			icon:setTag(i)
			icon:getChildByName("Image_Icon"):loadTexture(resData.Res_path1)

			registerWidgetReleaseUpEvent(icon,OnSelectIcon)
		end

		OnSelectIcon(iconChosePanel:getChildByName(string.format("Panel_icon_%d",iconId)))
	end

	registerWidgetReleaseUpEvent(pap[3][2]:getChildByName("Button_ChangeIcon"),ShowPartyIcon)
	registerWidgetReleaseUpEvent(pap[3][2]:getChildByName("Button_Creat"), function() self.mModel:doCreatePartyRequest(self.mCreateEdit:getText(),iconId) end)	
end

function PartyJoinWindow:Destroy()
	if self.mTopRoleInfoPanel ~= nil then
		self.mTopRoleInfoPanel:destroy()
		self.mTopRoleInfoPanel = nil
	end

	self.mModel:destroyInstance()

	if self.mPartyTV ~= nil then
		self.mPartyTV:Destroy()
		self.mPartyTV        = nil
	end

	if self.mSearchTV ~= nil then
		self.mSearchTV:Destroy()
		self.mSearchTV        = nil
	end

	if self.mSearchEdit ~= nil then
		self.mSearchEdit:removeFromParent(true)
		self.mSearchEdit = nil 
	end

	if self.mCreateEdit ~= nil then
		self.mCreateEdit:removeFromParent(true)
		self.mCreateEdit = nil 
	end

    self.mRootWidget = nil
    
	if self.mRootNode then
		self.mRootNode:removeFromParent(true)
		self.mRootNode = nil
	end

	----------------
	CommonAnimation.clearAllTextures()
end

function PartyJoinWindow:onEventHandler(event)
	if event.mAction == Event.WINDOW_SHOW then
		self:Load(event)
		---------停止画主城镇界面
		EventSystem:PushEvent(Event.GUISYSTEM_DISABLEDRAW_HOMEWINDOW)
		---------
	elseif event.mAction == Event.WINDOW_HIDE then
		self:Destroy()
		---------开启画主城镇界面
		EventSystem:PushEvent(Event.GUISYSTEM_EABLEDRAW_HOMEWINDOW)
		---------
	end
end

return PartyJoinWindow