-- Name: 	PartyHelloWindow
-- Func：	帮会问好界面
-- Author:	lichuan
-- Data:	16-2-28

--==========================================================helloTv begin ==================================================================
HelloTableView = {}

function HelloTableView:new(owner,listType)
	local o = 
	{
		mOwner			  = owner,
		mRootNode 	      =	nil,
		mType 		      =	listType,
		mTableView	      =	nil,
	}
	o = newObject(o, HelloTableView)
	return o
end

function HelloTableView:Destroy()
	self.mRootNode:removeFromParent(true)
	self.mRootNode     = nil
	self.mTableView    = nil
	self.mOwner        = nil
end

function HelloTableView:myModel()
	return self.mOwner.mModel
end

function HelloTableView:init(rootNode)
	self.mRootNode = rootNode
	-- 初始化数据源
	--self:myModel():doLoadDataRequest(PacketTyper._PTYPE_CS_REQUEST_FRIEND_LIST_,nil)
	self:initTableView()
end

function HelloTableView:initTableView()
	self.mTableView = TableViewEx:new()

	local widget = GUIWidgetPool:createWidget("Guild_Hello_Cell")

	self.mTableView:setCellSize(widget:getContentSize())
	self.mTableView:setCellCount(#self.mOwner.mModel.mSeniorInfoArr)

	self.mTableView:registerTableCellAtIndexFunc(handler(self, self.tableCellAtIndex))
	self.mTableView:registerTableCellTouchedFunc(handler(self, self.tableCellTouched))

	self.mTableView:init(self.mRootNode:getContentSize(), cc.p(0,0), 1)
	self.mRootNode:addChild(self.mTableView:getRootNode())
end

function HelloTableView:tableCellAtIndex(table, index)
	local cell = table:dequeueCell()
	local helloItem = nil

	if nil == cell then
		cell = cc.TableViewCell:new()
		helloItem = GUIWidgetPool:createWidget("Guild_Hello_Cell")
		
		helloItem:setTouchSwallowed(false)
		helloItem:setTag(1)
		cell:addChild(helloItem)
	else
		helloItem = cell:getChildByTag(1)
	end

	helloItem:getChildByName("Button_Hello"):setTag(index)

	if #self:myModel().mSeniorInfoArr ~= 0 then
		self:setCellLayOut(helloItem,index)
	end
	
	return cell
end

function HelloTableView:setCellLayOut(widget,index)
	local seniorInfo = self:myModel().mSeniorInfoArr[index + 1]
	local helloBtn   = widget:getChildByName("Button_Hello")

	registerWidgetReleaseUpEvent(helloBtn,function(widget) GUISystem:playSound("homeBtnSound") self:myModel():doSayHelloRequest(widget:getTag()) end)

	if seniorInfo.mHelloed == 1 then
		ShaderManager:DoUIWidgetDisabled(helloBtn,true)
		helloBtn:setTouchEnabled(false)
	else
		ShaderManager:DoUIWidgetDisabled(helloBtn,false)
		helloBtn:setTouchEnabled(true)
	end

	local playerInfoWidget = GUIWidgetPool:createWidget("PlayerInfo")
	playerInfoWidget:setTouchSwallowed(false)

	playerInfoWidget:getChildByName("Image_PlayerHead_Bg"):loadTexture(FindFrameIconbyId(seniorInfo.mPlayerFrameId))
	playerInfoWidget:getChildByName("Image_PlayerHead"):loadTexture(FindFrameIconbyId(seniorInfo.mPlayerIconId))

	widget:getChildByName("Panel_PlayerInfo"):removeAllChildren()
	widget:getChildByName("Panel_PlayerInfo"):addChild(playerInfoWidget)

	
	widget:getChildByName("Label_Position"):setString(PARTYROLESTR[seniorInfo.mPosition])

	
	playerInfoWidget:getChildByName("Label_Level"):setString(tostring(seniorInfo.mPlayerLv))
	playerInfoWidget:getChildByName("Label_Name"):setString(seniorInfo.mPlayerNameStr)
	playerInfoWidget:getChildByName("Label_Zhanli"):setString(tostring(seniorInfo.mPlayerFightPower))
	
end

function HelloTableView:tableCellTouched(table,cell)
	print("HelloTableView cell touched at index: " .. cell:getIdx())
end

function HelloTableView:UpdateTableView(cellCnt) --move table to cur cell after reload
	self.mTableView:setCellCount(cellCnt)

	--local curOffset = self.mTableView.mInnerContainer:getContentOffset()
	--local curHeight = self.mTableView.mInnerContainer:getContentSize().height
	self.mTableView:reloadData()
	--self.mTableView.mInnerContainer:setContentOffset(cc.p(0,self.mTableView.mInnerContainer:getViewSize().height - self.mTableView.mInnerContainer:getContentSize().height))
	--local height = self.mTableView.mInnerContainer:getContentSize().height
	--curOffset.y = curOffset.y + (curHeight - height)
	--self.mTableView.mInnerContainer:setContentOffset(curOffset)
end
--==================================================================model begin=========================================================================

local PHMInstance = nil

PartyHelloModel = class("PartyHelloModel")

function PartyHelloModel:ctor()
	self.mName		    = "PartyHelloModel"
	self.mOwner         = nil
	self.mLeftCnt       = nil
	self.mMaxCnt 		= nil
	self.mSeniorInfoArr = {}

	self:registerNetEvent()
end

function PartyHelloModel:deinit()
	self.mName  	     = nil
	self.mOwner 	     = nil
	self.mLeftCnt       = nil
	self.mMaxCnt 		= nil
	self.mSeniorInfoArr = {}

	self:unRegisterNetEvent()
end

function PartyHelloModel:getInstance()
	if PHMInstance == nil then  
        PHMInstance = PartyHelloModel.new()
    end  
    return PHMInstance
end

function PartyHelloModel:destroyInstance()
	if PHMInstance then
		PHMInstance:deinit()
    	PHMInstance = nil
    end
end

function PartyHelloModel:registerNetEvent()
	NetSystem.mNetManager:RegisterPacketHandler(PacketTyper._PTYPE_SC_PARTY_SENIORS_RESPONSE, handler(self, self.onLoadSeniorsResponse))
	NetSystem.mNetManager:RegisterPacketHandler(PacketTyper._PTYPE_SC_SAY_HELLO_RESPONSE, handler(self, self.onSayHelloResponse))
end

function PartyHelloModel:unRegisterNetEvent()
	NetSystem.mNetManager:UnregisterPacketHandler(PacketTyper._PTYPE_SC_PARTY_SENIORS_RESPONSE)
	NetSystem.mNetManager:UnregisterPacketHandler(PacketTyper._PTYPE_SC_SAY_HELLO_RESPONSE)
end

function PartyHelloModel:setOwner(owner)
	self.mOwner = owner
end

function PartyHelloModel:doLoadSeniorsRequest()
	local packet = NetSystem.mNetManager:GetSPacket()
    packet:SetType(PacketTyper._PTYPE_CS_PARTY_SENIORS_REQUEST)
    packet:Send()
    GUISystem:showLoading()	
end

function PartyHelloModel:onLoadSeniorsResponse(msgPacket)
	local seniorsCnt = msgPacket:GetChar()
	self.mSeniorInfoArr = {}
	for i=1,seniorsCnt do
		local helloInfo                  = {}
		helloInfo.mPlayerIdStr           = msgPacket:GetString()
		helloInfo.mPlayerNameStr         = msgPacket:GetString()
		helloInfo.mPlayerIconId          = msgPacket:GetInt()
		helloInfo.mPlayerFrameId         = msgPacket:GetInt()
		helloInfo.mPlayerFightPower		 = msgPacket:GetInt()
		helloInfo.mPlayerLv				 = msgPacket:GetInt()
		helloInfo.mPosition              = msgPacket:GetInt()
		helloInfo.mHelloed				 = msgPacket:GetChar()
		table.insert(self.mSeniorInfoArr,helloInfo)
	end

	self.mLeftCnt       = msgPacket:GetChar()
	self.mMaxCnt 		= msgPacket:GetChar()

	GUISystem:hideLoading()
	EventSystem:PushEvent(Event.GUISYSTEM_SHOW_PARTYHELLOWINDOW)
end

function PartyHelloModel:doSayHelloRequest(index)
	self.mHelloIndex = index
	local packet = NetSystem.mNetManager:GetSPacket()
    packet:SetType(PacketTyper._PTYPE_CS_SAY_HELLO_REQUEST)
    packet:PushChar(position)
    packet:PushString(self.mSeniorInfoArr[index + 1].mPlayerIdStr)
    packet:Send()
    GUISystem:showLoading()
end

function PartyHelloModel:onSayHelloResponse(msgPacket)
	local ret = msgPacket:GetChar()
	GUISystem:hideLoading()
	if ret == 0 then
		self.mSeniorInfoArr[self.mHelloIndex + 1].mHelloed = 1
		self.mLeftCnt = self.mLeftCnt - 1

		if self.mOwner then
			self.mOwner.mRootWidget:getChildByName("Label_LastHelloTimes"):setString(string.format("%d/%d",self.mLeftCnt,self.mMaxCnt))
			if self.mOwner.mHelloTV ~= nil then
				self.mOwner.mHelloTV:UpdateTableView(#self.mSeniorInfoArr)
			end
		end
	end
end

--==================================================================window begin=========================================================================
local PartyHelloWindow = 
{
	mName 				= "PartyHelloWindow",
	mRootNode			=	nil,	
	mRootWidget 		= 	nil,
	mTopRoleInfoPanel	=	nil,	-- 顶部人物信息面板
	mModel				=   nil,
	mHelloTV			=   nil,
}

function PartyHelloWindow:Load(event)
	cclog("=====PartyHelloWindow:Load=====begin")

	self.mRootNode = cc.Node:create()
	GUISystem:GetRootNode():addChild(self.mRootNode)

	--self.mEventData    = event.mData
	self.mModel = PartyHelloModel:getInstance()
	self.mModel:setOwner(self)
	
	self:InitLayout()
	
	cclog("=====PartyHelloWindow:Load=====end")
end

function PartyHelloWindow:InitLayout()
	if self.mRootWidget == nil then
		self.mRootWidget = GUIWidgetPool:createWidget("Guild_Hello")
   		self.mRootNode:addChild(self.mRootWidget)
   	end

   	if self.mTopRoleInfoPanel == nil then
		cclog("PartyHelloWindow mTopRoleInfoPanel init")
		self.mTopRoleInfoPanel = TopRoleInfoPanel:new()
		self.mTopRoleInfoPanel:init(self.mRootNode, ROLE_TITLE_TYPE.TITLE_PARTY_HELLO,
		function()
			GUISystem:playSound("homeBtnSound")		
			EventSystem:PushEvent(Event.GUISYSTEM_HIDE_PARTYHELLOWINDOW)	
		end)
	end

	local topSize   = self.mTopRoleInfoPanel.mTopWidget:getContentSize()
	local y         = getGoldFightPosition_Middle().y - topSize.height / 2
	local x         = getGoldFightPosition_Middle().x
	local mainPanel = self.mRootWidget:getChildByName("Panel_Window")
	local desData   = DB_Text.getDataById(239)
	local desStr    = desData.Text_CN

	mainPanel:setAnchorPoint(0.5,0.5)
	mainPanel:setPosition(cc.p(x,y))

	self.mRootWidget:getChildByName("Label_Des"):setString(desStr)
	self.mRootWidget:getChildByName("Label_LastHelloTimes"):setString(string.format("%d/%d",self.mModel.mLeftCnt,self.mModel.mMaxCnt))
	self:UpdateHelloTV()
end

function PartyHelloWindow:UpdateHelloTV()
	if self.mHelloTV == nil then
		self.mHelloTV = HelloTableView:new(self,0)
		self.mHelloTV:init(self.mRootWidget:getChildByName("Panel_MenberList"))
	else
		self.mHelloTV:UpdateTableView(#self.mModel.mSeniorInfoArr)
	end

	if #self.mModel.mSeniorInfoArr == 0 then
		self.mRootWidget:getChildByName("Label_Nobody"):setVisible(true)
	else
		self.mRootWidget:getChildByName("Label_Nobody"):setVisible(false)
	end
end

function PartyHelloWindow:Destroy()
	if self.mTopRoleInfoPanel ~= nil then
		self.mTopRoleInfoPanel:destroy()
		self.mTopRoleInfoPanel = nil
	end

	self.mModel:destroyInstance()

	if self.mHelloTV ~= nil then
		self.mHelloTV:Destroy()
		self.mHelloTV	     = nil
	end

    self.mRootWidget = nil
    
	if self.mRootNode then
		self.mRootNode:removeFromParent(true)
		self.mRootNode = nil
	end

	----------------
	CommonAnimation.clearAllTextures()
end

function PartyHelloWindow:onEventHandler(event)
	if event.mAction == Event.WINDOW_SHOW then
		self:Load(event)
		---------停止画帮派界面
		EventSystem:PushEvent(Event.GUISYSTEM_DISABLEDRAW_UNIONHALLWINDOW)
		---------
	elseif event.mAction == Event.WINDOW_HIDE then
		self:Destroy()
		---------开启画帮派界面
		EventSystem:PushEvent(Event.GUISYSTEM_ENABLEDRAW_UNIONHALLWINDOW)
		---------
	end
end

return PartyHelloWindow