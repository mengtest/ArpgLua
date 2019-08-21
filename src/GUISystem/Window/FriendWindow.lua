-- Name: 	FriendWindow
-- Func：	好友界面
-- Author:	lichuan
-- Data:	15-4-27

require("GUISystem/Window/FriendModel")

-- 好友列表对象
local FrinedTableView = {}

function FrinedTableView:new(owner,listType)
	local o = 
	{
		mOwner			  = owner,
		mRootNode 	      =	nil,
		mType 		      =	listType,
		mTableView	      =	nil,
	}
	o = newObject(o, FrinedTableView)
	return o
end

function FrinedTableView:Destroy()
	self.mRootNode:removeFromParent(true)
	self.mRootNode   = nil
	self.mTableView  = nil
	self.mOwner      = nil
end

function FrinedTableView:myModel()
	return self.mOwner.mModel
end

function FrinedTableView:init(rootNode)
	self.mRootNode = rootNode
	-- 初始化数据源

	--self:myModel():doLoadDataRequest(PacketTyper._PTYPE_CS_REQUEST_FRIEND_LIST_,nil)

	self:initTableView()
end

function FrinedTableView:initTableView()
	self.mTableView = TableViewEx:new()

	local widget = GUIWidgetPool:createWidget("FriendsPlayer")

	self.mTableView:setCellSize(widget:getContentSize())
	self.mTableView:setCellCount(#self.mOwner.mModel.mFriendDataSource)

	self.mTableView:registerTableCellAtIndexFunc(handler(self, self.tableCellAtIndex))
	self.mTableView:registerTableCellTouchedFunc(handler(self, self.tableCellTouched))

	self.mTableView:init(self.mRootNode:getContentSize(), cc.p(0,0), 1)
	self.mRootNode:addChild(self.mTableView:getRootNode())
end

function FrinedTableView:tableCellAtIndex(table, index)
	local cell = table:dequeueCell()
	local playerItem = nil
	local function addTagToWidget(widget)
		widget:getChildByName("Panel_MyFriends"):getChildByName("Button_SendTili"):setTag(index)
		widget:getChildByName("Panel_MyFriends"):getChildByName("Button_GetTili"):setTag(index)
		widget:getChildByName("Panel_FriendSearch"):getChildByName("Button_Add"):setTag(index)
		widget:getChildByName("Panel_FriendApply"):getChildByName("Button_Add"):setTag(index)
		widget:getChildByName("Panel_FriendApply"):getChildByName("Button_Sub"):setTag(index)
	end

	if nil == cell then
		cell = cc.TableViewCell:new()
		playerItem = GUIWidgetPool:createWidget("FriendsPlayer")

		registerWidgetReleaseUpEvent(playerItem:getChildByName("Panel_MyFriends"):getChildByName("Button_SendTili"),
		function(widget) GUISystem:playSound("homeBtnSound") self:myModel():doSendEnergyRequest(widget:getTag() + 1) end)

		registerWidgetReleaseUpEvent(playerItem:getChildByName("Panel_MyFriends"):getChildByName("Button_GetTili"),
		function(widget) GUISystem:playSound("homeBtnSound") self:myModel():doReceiveEnergyRequest(widget:getTag() + 1) end)

		registerWidgetReleaseUpEvent(playerItem:getChildByName("Panel_FriendSearch"):getChildByName("Button_Add"), 
		function(widget) GUISystem:playSound("homeBtnSound") self:myModel():doAddFriendRequest(widget) end)

		registerWidgetReleaseUpEvent(playerItem:getChildByName("Panel_FriendApply"):getChildByName("Button_Add"), 
		function(widget) GUISystem:playSound("homeBtnSound") self:myModel():doAgreeAddRequest(widget:getTag() + 1) end)

		registerWidgetReleaseUpEvent(playerItem:getChildByName("Panel_FriendApply"):getChildByName("Button_Sub"),
		function(widget) GUISystem:playSound("homeBtnSound") self:myModel():doRefuseAddRequest(widget:getTag() + 1) end)
		
		playerItem:setTouchSwallowed(false)
		playerItem:setTag(1)
		cell:addChild(playerItem)
	else
		playerItem = cell:getChildByTag(1)
	end

	addTagToWidget(playerItem)

	if #self:myModel().mDataSource ~= 0 then
		self:setCellLayOut(playerItem,index)
	end
	
	return cell
end

function FrinedTableView:setCellLayOut(widget,index)
	local playerInfoWidget = GUIWidgetPool:createWidget("PlayerInfo")
	playerInfoWidget:setTouchSwallowed(false)

	local friendInfo = self:myModel().mDataSource[index + 1]

	playerInfoWidget:getChildByName("Image_PlayerHead_Bg"):loadTexture(FindFrameIconbyId(friendInfo.mFriendFrameId))
	playerInfoWidget:getChildByName("Image_PlayerHead"):loadTexture(FindFrameIconbyId(friendInfo.mFriendIconId))
	
	widget:getChildByName("Panel_PlayerHead"):setTouchSwallowed(false)
	widget:getChildByName("Panel_MyFriends"):setTouchSwallowed(false)
	widget:getChildByName("Panel_FriendSearch"):setTouchSwallowed(false)
	widget:getChildByName("Panel_FriendApply"):setTouchSwallowed(false)

	widget:getChildByName("Panel_PlayerHead"):removeAllChildren()
	widget:getChildByName("Panel_PlayerHead"):addChild(playerInfoWidget)

	if #self:myModel().mFriendDataSource ~= 0 then
		widget:getChildByName("Panel_MyFriends"):setVisible(true)   
		widget:getChildByName("Panel_FriendSearch"):setVisible(false)
		widget:getChildByName("Panel_FriendApply"):setVisible(false)
	elseif #self:myModel().mSearchDataSource ~= 0 then
		widget:getChildByName("Panel_MyFriends"):setVisible(false)
		widget:getChildByName("Panel_FriendSearch"):setVisible(true)
		widget:getChildByName("Panel_FriendApply"):setVisible(false)
	elseif #self:myModel().mApplyDataSource ~= 0 then
		widget:getChildByName("Panel_MyFriends"):setVisible(false)
		widget:getChildByName("Panel_FriendSearch"):setVisible(false)
		widget:getChildByName("Panel_FriendApply"):setVisible(true)
	end

	if self:myModel().mDataSource[index + 1] then
		playerInfoWidget:getChildByName("Label_Level"):setString(""..self:myModel().mDataSource[index + 1].mFriendLv)
	    playerInfoWidget:getChildByName("Label_Name"):setString(self:myModel().mDataSource[index + 1].mFriendNameStr)
	    playerInfoWidget:getChildByName("Label_Zhanli"):setString(tostring(self:myModel().mDataSource[index + 1].mFriendFightPower))

	    if self:myModel().mDataSource[index + 1].mFriendCanSend == 0 then
	    	widget:getChildByName("Panel_MyFriends"):getChildByName("Button_SendTili"):setVisible(true)
		else
			widget:getChildByName("Panel_MyFriends"):getChildByName("Button_SendTili"):setVisible(false)
		end

		if self:myModel().mDataSource[index + 1].mFriendCanGet == 0 then
			widget:getChildByName("Panel_MyFriends"):getChildByName("Button_GetTili"):setVisible(true)
		else
			widget:getChildByName("Panel_MyFriends"):getChildByName("Button_GetTili"):setVisible(false)
		end

    	if self:myModel().mDataSource[index + 1].mFriendIsOnline == 0 then
			widget:getChildByName("Panel_MyFriends"):getChildByName("Image_OnLine"):setVisible(true)
			widget:getChildByName("Panel_FriendSearch"):getChildByName("Image_OnLine"):setVisible(true)

			widget:getChildByName("Panel_MyFriends"):getChildByName("Image_OffLine"):setVisible(false)
			widget:getChildByName("Panel_FriendSearch"):getChildByName("Image_OffLine"):setVisible(false)

			widget:getChildByName("Panel_MyFriends"):getChildByName("Label_OnlineTime"):setVisible(false)
			widget:getChildByName("Panel_FriendSearch"):getChildByName("Label_OnlineTime"):setVisible(false)

		else
			widget:getChildByName("Panel_MyFriends"):getChildByName("Image_OnLine"):setVisible(false)
			widget:getChildByName("Panel_FriendSearch"):getChildByName("Image_OnLine"):setVisible(false)

			widget:getChildByName("Panel_MyFriends"):getChildByName("Image_OffLine"):setVisible(true)
			widget:getChildByName("Panel_FriendSearch"):getChildByName("Image_OffLine"):setVisible(true)

			widget:getChildByName("Panel_MyFriends"):getChildByName("Label_OnlineTime"):setVisible(true)
			widget:getChildByName("Panel_FriendSearch"):getChildByName("Label_OnlineTime"):setVisible(true)

			widget:getChildByName("Panel_MyFriends"):getChildByName("Label_OnlineTime"):setString(self:myModel().mDataSource[index + 1].mFriendLastOnlineTime)
			widget:getChildByName("Panel_FriendSearch"):getChildByName("Label_OnlineTime"):setString(self:myModel().mDataSource[index + 1].mFriendLastOnlineTime)
		end

		widget:getChildByName("Panel_FriendApply"):getChildByName("Label_ApplyTime"):setString(""..self:myModel().mDataSource[index + 1].mFriendLastOnlineTime)
	end

end

function FrinedTableView:tableCellTouched(table,cell)
	print("FrinedTableView cell touched at index: " .. cell:getIdx())

    --self.mOwner.mCheckPlayerId = self.mOwner.mModel.mDataSource[cell:getIdx()+1].mFriendIdStr
    self.mOwner.mCheckPlayerIndex = cell:getIdx()+1
    self.mOwner.mModel:doLoadPlayerInfoRequest(cell:getIdx() + 1)
end

function FrinedTableView:UpdateTableView(cellCnt) --move table to cur cell after reload
	self.mTableView:setCellCount(cellCnt)

	--local curOffset = self.mTableView.mInnerContainer:getContentOffset()
	--local curHeight = self.mTableView.mInnerContainer:getContentSize().height
	self.mTableView:reloadData()
	--self.mTableView.mInnerContainer:setContentOffset(cc.p(0,self.mTableView.mInnerContainer:getViewSize().height - self.mTableView.mInnerContainer:getContentSize().height))
	--local height = self.mTableView.mInnerContainer:getContentSize().height
	--curOffset.y = curOffset.y + (curHeight - height)
	--self.mTableView.mInnerContainer:setContentOffset(curOffset)
end


local oldTvSize = nil
local newTvSize = nil

local FriendWindow = 
{
	mName						=	"FriendWindow",
	mRootNode 					= 	nil,
	mRootWidget 				= 	nil,
	mPanelPage					=   nil,
	mFriendTableView			=   nil,
	mSearcgEdit					=   nil,
	mLastClickPageIdx			=   nil,
	mPageCurSel					=   nil,
	mCheckPlayerIndex			=   nil,
	mModel						=   nil,
}

function FriendWindow:Release()

end

function FriendWindow:Load(event)
	cclog("=====FriendWindow:Load=====begin")

	self.mRootNode = cc.Node:create()
	GUISystem:GetRootNode():addChild(self.mRootNode)

	self.mModel = FriendModel:getInstance()
	self.mModel:setOwner(self)

	self:InitLayout(event)
	cclog("=====FriendWindow:Load=====end")
end

function FriendWindow:InitLayout(event)
	self.mRootWidget =  GUIWidgetPool:createWidget("FriendsMain")
	self.mRootNode:addChild(self.mRootWidget)

	if self.mTopRoleInfoPanel == nil then
		cclog("FriendWindow mTopRoleInfoPanel init")
		self.mTopRoleInfoPanel = TopRoleInfoPanel:new()
	    self.mTopRoleInfoPanel:init(self.mRootNode,ROLE_TITLE_TYPE.TITLE_FRIEND,function() GUISystem:playSound("homeBtnSound") EventSystem:PushEvent(Event.GUISYSTEM_HIDE_FRIENDWINDOW) end)
	end

	self.mPanelPage = self.mRootWidget:getChildByName("Panel_Page")

	local mainPanel = self.mRootWidget:getChildByName("Panel_Main")
	local topSize = self.mTopRoleInfoPanel.mTopWidget:getContentSize()
	local y = getGoldFightPosition_Middle().y - topSize.height / 2
	local x = getGoldFightPosition_Middle().x

	mainPanel:setAnchorPoint(cc.p(0.5, 0.5))
	mainPanel:setPosition(cc.p(x,y))
	mainPanel:setOpacity(0)
	mainPanel:setScale(0.5)

	local act0 = cc.ScaleTo:create(0.15, 1)
	local act1 = cc.FadeIn:create(0.15)
	--	local act1 = cc.EaseElasticOut:create(act0)
	mainPanel:runAction(cc.Spawn:create(act0, act1))	

	registerWidgetReleaseUpEvent(self.mPanelPage:getChildByName("Image_PageMyFriends"), handler(self, self.onClickPage))
	registerWidgetReleaseUpEvent(self.mPanelPage:getChildByName("Image_PageFriendSearch"), handler(self, self.onClickPage))
	registerWidgetReleaseUpEvent(self.mPanelPage:getChildByName("Image_PageFriendApply"), handler(self, self.onClickPage))
	registerWidgetReleaseUpEvent(self.mRootWidget:getChildByName("Button_GetAll"), function() GUISystem:playSound("homeBtnSound") self.mModel:doAutoReceiveRequest() end)
	registerWidgetReleaseUpEvent(self.mRootWidget:getChildByName("Button_Search"), 
	function()
		GUISystem:playSound("homeBtnSound")
		local userName = self.mSearcgEdit:getText()
		if "" == userName then
			MessageBox:showMessageBox1("姓名不能为空!")
			return
		end
		self.mModel:doLoadDataRequest(PacketTyper._PTYPE_CS_SEARCH_FRIEND_,tostring(userName))
	end)

	self.mRootWidget:getChildByName("Panel_MyFriends"):getChildByName("Image_TextFieldBg"):setVisible(false)
	self.mRootWidget:getChildByName("Panel_MyFriends"):getChildByName("Button_Search"):setVisible(false)
	self.mRootWidget:getChildByName("Panel_MyFriends"):getChildByName("Button_GetAll"):setVisible(true)

	self.mFriendTableView = FrinedTableView:new(self,0)
	self.mFriendTableView:init(self.mRootWidget:getChildByName("Panel_Main"):getChildByName("Panel_MyFriends"):getChildByName("TableView_Friend"))


	local size = self.mRootWidget:getChildByName("Image_TextFieldBg"):getContentSize()
	local pos = self.mRootWidget:getChildByName("Image_TextFieldBg"):getPosition()

	self.mSearcgEdit = cc.EditBox:create(size, cc.Scale9Sprite:create("editbox_bg.png"))
	self.mSearcgEdit:setFont("res/fonts/font_3.ttf", 20)
	self.mRootWidget:getChildByName("Image_TextFieldBg"):addChild(self.mSearcgEdit)
	self.mSearcgEdit:setAnchorPoint(0,0)
	self.mSearcgEdit:setPosition(pos)


	self.mRootWidget:getChildByName("Panel_MyFriends"):setVisible(true)
	--self.mPanelPage:getChildByName("Image_PageMyFriends"):loadTexture("friends_page_title1_1.png")
	self:onClickPage(self.mPanelPage:getChildByName("Image_PageMyFriends"))
end

function FriendWindow:UpdateLayout()
	local labelTip = self.mRootWidget:getChildByName("Label_NoFriends")

	if self.mPageCurSel == 1 then	
		self.mRootWidget:getChildByName("Panel_Main"):getChildByName("Label_FriendsCount"):setString(string.format("好友数量:%d/100",#self.mModel.mDataSource))
	end

	if #self.mModel.mDataSource == 0 then
		if self.mPageCurSel == 1 then			
			labelTip:setString("您还没有好友哦~快去添加一些好友一起战斗吧！")
			labelTip:setVisible(true)
		elseif self.mPageCurSel == 3 then 
			labelTip:setString("目前并没有什么好友申请~")
			labelTip:setVisible(true)
		elseif self.mPageCurSel == 2 then
			labelTip:setVisible(false)
		end
	else
		labelTip:setVisible(false)
	end

end

function FriendWindow:myTabelView()
	return self.mFriendTableView.mTableView
end

function FriendWindow:onClickPage(widget)
	GUISystem:playSound("tabPageSound")
	if self.mLastClickPageIdx == widget:getTag() then
		return
	end

	self.mPageCurSel = widget:getTag()

	if not oldTvSize then
		oldTvSize = self.mFriendTableView.mTableView:getContentSize()
		newTvSize = cc.size(oldTvSize.width, oldTvSize.height - 45)
	end

	widget:loadTexture(string.format("friends_page_title%d_1.png",self.mPageCurSel))

	if self.mPageCurSel == 1 then
		self.mPanelPage:getChildByName("Image_PageFriendSearch"):loadTexture("friends_page_title2_2.png")
		self.mPanelPage:getChildByName("Image_PageFriendApply"):loadTexture("friends_page_title3_2.png")

		self.mRootWidget:getChildByName("Panel_MyFriends"):getChildByName("Image_TextFieldBg"):setVisible(false)
		self.mRootWidget:getChildByName("Panel_MyFriends"):getChildByName("Button_Search"):setVisible(false)
		self.mRootWidget:getChildByName("Panel_MyFriends"):getChildByName("Button_GetAll"):setVisible(true)

		self:myTabelView():setContentSize(oldTvSize)

		self.mModel:doLoadDataRequest(PacketTyper._PTYPE_CS_REQUEST_FRIEND_LIST_,nil)
	elseif self.mPageCurSel == 2 then
		self.mPanelPage:getChildByName("Image_PageMyFriends"):loadTexture("friends_page_title1_2.png")
		self.mPanelPage:getChildByName("Image_PageFriendApply"):loadTexture("friends_page_title3_2.png")

		self.mRootWidget:getChildByName("Panel_MyFriends"):getChildByName("Image_TextFieldBg"):setVisible(true)
		self.mRootWidget:getChildByName("Panel_MyFriends"):getChildByName("Button_Search"):setVisible(true)
		self.mRootWidget:getChildByName("Panel_MyFriends"):getChildByName("Button_GetAll"):setVisible(false)

		
		self:myTabelView():setContentSize(newTvSize)

		self.mModel:doLoadDataRequest(PacketTyper._PTYPE_CS_REQUEST_FRIEND_RECOMMOND_LIST_,nil)
	elseif self.mPageCurSel == 3 then
		self.mPanelPage:getChildByName("Image_PageFriendSearch"):loadTexture("friends_page_title2_2.png")
		self.mPanelPage:getChildByName("Image_PageMyFriends"):loadTexture("friends_page_title1_2.png")

		self.mRootWidget:getChildByName("Panel_MyFriends"):getChildByName("Image_TextFieldBg"):setVisible(false)
		self.mRootWidget:getChildByName("Panel_MyFriends"):getChildByName("Button_Search"):setVisible(false)
		self.mRootWidget:getChildByName("Panel_MyFriends"):getChildByName("Button_GetAll"):setVisible(false)

		self:myTabelView():setContentSize(oldTvSize)

		self.mModel:doLoadDataRequest(PacketTyper._PTYPE_CS_REQUEST_FRIEND_APPLY_LIST_,nil)
	end
	self.mLastClickPageIdx = self.mPageCurSel
end

function FriendWindow:onReceivePlayInfo()
	local widget =  GUIWidgetPool:createWidget("FriendsPlayerWindow")
	local playerInfoWidget = GUIWidgetPool:createWidget("PlayerInfo")
	widget:getChildByName("Panel_PlayInfo"):addChild(playerInfoWidget)
    self.mRootWidget:addChild(widget)

    -- 关闭窗口
    local function closeWindow()
    	GUISystem:playSound("homeBtnSound")
    	widget:removeFromParent(true)
    	widget = nil 
    end

    widget:getChildByName("Label_Banghui"):setString(globaldata.cityPlayer.banghuiName)

    registerWidgetReleaseUpEvent(widget, closeWindow)
    registerWidgetReleaseUpEvent(widget:getChildByName("Button_Add"),function() closeWindow();self.mModel:doAddFriendByIdxRequest(self.mCheckPlayerIndex) end)
    registerWidgetReleaseUpEvent(widget:getChildByName("Button_Delete"), function() closeWindow();self.mModel:doDelFriendRequest(self.mCheckPlayerIndex) end)
    registerWidgetReleaseUpEvent(widget:getChildByName("Button_Chat"),
    function() 
   	 	closeWindow()
   	 	local friendInfo = self.mModel.mDataSource[self.mCheckPlayerIndex]
   	 	GUISystem:requestTalkToSomebody(friendInfo.mFriendIdStr, friendInfo.mFriendNameStr)
   	 	EventSystem:PushEvent(Event.GUISYSTEM_HIDE_FRIENDWINDOW)
    end)
    registerWidgetReleaseUpEvent(widget:getChildByName("Button_Fight"), function() closeWindow(); self.mModel:doFightRequest(self.mCheckPlayerIndex) end)

    --widget:getChildByName("Button_Chat"):setTouchEnabled(false)
    --widget:getChildByName("Button_Fight"):setTouchEnabled(false)
    --widget:getChildByName("Button_Visit"):setTouchEnabled(false)
    --ShaderManager:DoUIWidgetDisabled(widget:getChildByName("Button_Chat"), true)
    --ShaderManager:DoUIWidgetDisabled(widget:getChildByName("Button_Fight"), true)
    --ShaderManager:DoUIWidgetDisabled(widget:getChildByName("Button_Visit"), true)

    local function setDlgLayOut()

		if globaldata.cityPlayer.isfriend == 0 then
		    widget:getChildByName("Button_Add"):setVisible(false)
		    widget:getChildByName("Button_Delete"):setVisible(true)
		else
		    widget:getChildByName("Button_Add"):setVisible(true)
		    widget:getChildByName("Button_Delete"):setVisible(false)
		end
		playerInfoWidget:getChildByName("Image_PlayerHead_Bg"):loadTexture(FindFrameIconbyId(globaldata.cityPlayer.playerFrame))
   		playerInfoWidget:getChildByName("Image_PlayerHead"):loadTexture(FindFrameIconbyId(globaldata.cityPlayer.playerIcon))
    	playerInfoWidget:getChildByName("Label_Level"):setString(tostring(globaldata.cityPlayer.playerLevel))
    	playerInfoWidget:getChildByName("Label_Name"):setString(globaldata.cityPlayer.playerName)
    	playerInfoWidget:getChildByName("Label_Zhanli"):setString(tostring(globaldata.cityPlayer.playerZhanli))

		for i = 1, globaldata.cityPlayer.heroCount do
		  local heroWidget = createHeroIcon(globaldata.cityPlayer.hero[i].heroId, globaldata.cityPlayer.hero[i].level, globaldata.cityPlayer.hero[i].quality, globaldata.cityPlayer.hero[i].advanceLevel)
		  widget:getChildByName("Panel_Hero"..i):addChild(heroWidget)
		end
		-- 排名
		self.mRootWidget:getChildByName("Label_Ranking"):setString(tostring(globaldata.cityPlayer.playerRank))
    end
    setDlgLayOut()
end


function FriendWindow:Destroy()
	if self.mFriendTableView ~= nil then 
		self.mFriendTableView:Destroy()
		self.mFriendTableView 	= nil
	end
	
	if self.mTopRoleInfoPanel ~= nil then
		self.mTopRoleInfoPanel:destroy()
		self.mTopRoleInfoPanel  = nil
	end

	if self.mRootNode ~= nil then
		self.mRootNode:removeFromParent(true)
		self.mRootNode 			= nil
	end

	self.mRootWidget 		= nil

	self.mLastClickPageIdx  = nil
	self.mCheckPlayerIndex  = nil
	
	self.mModel:destroyInstance()

	CommonAnimation.clearAllTextures()
end

function FriendWindow:onEventHandler(event)
	if event.mAction == Event.WINDOW_SHOW then
		self:Load(event)
		---------停止画主城镇界面
		EventSystem:PushEvent(Event.GUISYSTEM_DISABLEDRAW_HOMEWINDOW)
		---------
		NoticeSystem:doSingleUpdate(self.mName)
	elseif event.mAction == Event.WINDOW_HIDE then
		self:Destroy()
		---------开启画主城镇界面
		EventSystem:PushEvent(Event.GUISYSTEM_EABLEDRAW_HOMEWINDOW)
		---------
	end
end

return FriendWindow