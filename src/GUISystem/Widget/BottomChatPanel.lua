-- Name: 	BottomChatPanel
-- Func：	底部聊天面板
-- Author:	wangsd
-- Data:	15-6-19
 
BottomChatPanel = {}

--------------------局部变量---------------------------
local CHAT_MAX_WORD_COUNT = 47

local MAX_CHAT_INTERVAL 		= 1  -- 最大时间间隔(秒)
local MAX_CHAT_INTERVAL_VOICE 	= 1  -- 最大时间间隔(秒)

local MAX_CHAT_TEXT_CNT			= 15 -- 每项聊天最大接收消息数量
-------------------------------------------------------

-- 各项聊天数据表，生命周期等同游戏生命周期
local mTextArea_World_DataSource = {}
local mTextArea_Banghui_DataSource = {}
local mTextArea_Team_DataSource = {}
local mTextArea_Personal_DataSource = {}
local mChat_Personal_HasNew = false
----
local mTarPlayerId		=	nil	-- 目标玩家id
local mTarPlayerName 	=	nil	-- 目标玩家姓名

chatElementObject = {}

-- 初始化聊天数据个体对象
function chatElementObject:new()
	local o = 
	{
		mContentType	=	nil,	-- 消息类型
		mChatType		=	nil,	-- 聊天频道
		mSenderLevel	=	nil,	-- 发送者等级
		mChatTime		=	nil,	-- 发送时间
		mSenderName		=	nil,	-- 发送者姓名
		mChatMessage	=	nil,	-- 发送的消息内容
		mMySelf			=	nil,	-- 是否是玩家自己
		mContentLength	=	nil,
		mSenderTitle	=	nil,	
		mSenderId		=	nil,	-- 发送者ID
		mFrameId		=	nil,	-- 相框ID
		mImageId		=	nil,	-- 头像ID
		mTarPlayerName	=	nil,	-- 目标名字

	}
	o = newObject(o, chatElementObject)
	return o
end
-- 初始化聊天界面
function BottomChatPanel:new()
	local o = 
	{	
		mRootNode = nil,
		-----------------------
		mTopWidget 	= 	nil,
		mEditBox	=	nil,
		mTextArea	=	nil,
		mStartPos 	=	nil,
		mEndPos 	=	nil,
		mMainPanel	=	nil,
		mOpened		=	false,
		------------------------
		mTextArea_World		=	nil,
		mTextArea_Banghui	=	nil,
		mTextArea_Team		=	nil,
		mTextArea_Personal	=	nil,
		
		mInfoWidget			=	nil,
		------------------------
		mIsInAudioMode 		=	false, 	-- 是否处于录音模式
		mPanelAudio 		=	nil, 	
		mAudioStatusWgt 	=	nil, 	-- 显示录音状态的icon
		mIsInRecording 		=	nil,	-- 是否需要取消录音
		mCurMovePos 		=	nil,	-- 当前滑动的点
		mPreMovePos 		=	nil,	-- 上一次滑动的点
		------------------------
		mSchedulerEntry 	=	nil,	-- 定时器
		mTickCount 			=	0,		-- 秒数
		mPreTickCount 		=	0, 		-- 录音开始前秒数
		------------------------
		mSendHandler 		=	nil,
		------------------------
		mIsInPlayingAudio	=	false,	-- 正在播放语音
		mCurChannel			=	nil,	-- 当前所处的频道
		mPreSentTime		=	nil,	-- 前一次发出去消息的时间
	}
	o = newObject(o, BottomChatPanel)
	return o
end

-- 取消私聊红点
function BottomChatPanel:cancelPersonalCharNotice()
	self.mTopWidget:getChildByName("Image_Notice_15003"):setVisible(false)
	self.mTopWidget:getChildByName("Image_Notice_15000"):setVisible(false)
	mChat_Personal_HasNew = false
end

--注册接收聊天包handler
function BottomChatPanel:registerReceiveChatDataHandler()
	NetSystem.mNetManager:RegisterPacketHandler(PacketTyper._PTYPE_SC_REQUEST_RECVCHAT_, handler(self,self.onRecvChatInfo_Data))
end

-- 清空聊天数据表
function BottomChatPanel:clearAllChatDataList()
	mTextArea_World_DataSource = {}
	mTextArea_Banghui_DataSource = {}
	mTextArea_Team_DataSource = {}
	mTextArea_Personal_DataSource = {}
	mChat_Personal_HasNew = false
end

-- 接收聊天数据函数
function BottomChatPanel:onRecvChatInfo_Data(msgPacket)
	GUISystem:hideLoading()
	local chatType 		= msgPacket:GetChar()
	local senderId		= msgPacket:GetString()
	local senderName	= msgPacket:GetString()
	local senderLevel   = msgPacket:GetInt()
	local frameId		= msgPacket:GetInt()
	local ImageId       = msgPacket:GetInt()
	local senderTitle   = msgPacket:GetChar()
	local recverId		= msgPacket:GetString()
	local recverName	= msgPacket:GetString()
	local chatTime		= msgPacket:GetString()
	local contentType   = msgPacket:GetChar()
	local contentLength = msgPacket:GetUShort()
	local chatMessage	= msgPacket:GetString()

	
	local mySelf = false
	if senderId == globaldata.playerId then
		mySelf = true
	end

	local chatEleObj = chatElementObject:new()
	chatEleObj.mChatType 		= chatType
	chatEleObj.mSenderLevel 	= senderLevel
	chatEleObj.mChatTime 		= chatTime
	chatEleObj.mSenderName 		= senderName
	chatEleObj.mChatMessage 	= chatMessage
	chatEleObj.mMySelf 			= mySelf
	chatEleObj.mContentLength 	= contentLength
	chatEleObj.mSenderTitle 	= senderTitle
	chatEleObj.mSenderId 		= senderId
	chatEleObj.mFrameId 		= frameId
	chatEleObj.mImageId 		= ImageId
	chatEleObj.mContentType 	= contentType
	if 3 == chatType then -- 私聊
		chatEleObj.mTarPlayerName = mTarPlayerName
	end

	if 0 == chatType then
		if #mTextArea_World_DataSource >= MAX_CHAT_TEXT_CNT then
			table.remove(mTextArea_World_DataSource, 1)
		end
		table.insert(mTextArea_World_DataSource, chatEleObj)
	elseif 1 == chatType then
		if #mTextArea_Banghui_DataSource >= MAX_CHAT_TEXT_CNT then
			table.remove(mTextArea_Banghui_DataSource, 1)
		end
		table.insert(mTextArea_Banghui_DataSource, chatEleObj)
	elseif 2 == chatType then
		-- if #mTextArea_Team_DataSource >= MAX_CHAT_TEXT_CNT then
		-- 	table.remove(mTextArea_Team_DataSource, 1)
		-- end
		-- table.insert(mTextArea_Team_DataSource, chatEleObj)
	elseif 3 == chatType then
		if #mTextArea_Personal_DataSource >= MAX_CHAT_TEXT_CNT then
			table.remove(mTextArea_Personal_DataSource, 1)
		end
		table.insert(mTextArea_Personal_DataSource, chatEleObj)
		mChat_Personal_HasNew = true
	end

	GUIEventManager:pushEvent("chatInfoRecv", chatType, chatEleObj)
end

-- 开关聊天框
function BottomChatPanel:openAndClose()
	local moveTime	= 0.2
	if not self.mOpened then
		local function actEnd()
			self.mOpened = true
			self.mMainPanel:getChildByName("Button_Open"):loadTextureNormal("home_chat_close_1.png")
			self.mMainPanel:getChildByName("Button_Open"):loadTexturePressed("home_chat_close_2.png")
			self.mMainPanel:getChildByName("Button_Open"):setTouchEnabled(true)
			self.mTopWidget:setTouchEnabled(true)
			self.mTopWidget:setTouchEnabled(self.mOpened)
		end
		local function doOpen()
			self:closeInfo()
			local act0 = cc.EaseIn:create(cc.MoveTo:create(moveTime, self.mEndPos), 3)
			local act1 = cc.CallFunc:create(actEnd)
			self.mMainPanel:getChildByName("Button_Open"):setTouchEnabled(false)
			self.mTopWidget:setTouchEnabled(false)
			self.mMainPanel:runAction(cc.Sequence:create(act0, act1))
			if 3 == self.mCurChannel then
				self:setPersonalTalkInfo()
			end

			if 0 == self.mCurChannel then
				self.mTextArea_World:setCellCount(#mTextArea_World_DataSource)
				self.mTextArea_World:reloadData()
				local deltaY = 475 - #mTextArea_World_DataSource*90
				if deltaY < 0 then
					deltaY = 0
				end
				self.mTextArea_World.mInnerContainer:setContentOffset(cc.p(0, deltaY))
				self.mTopWidget:getChildByName("Image_Notice_15001"):setVisible(false)
			--	doError("update world!")
			elseif 1 == self.mCurChannel then
				self.mTextArea_Banghui:setCellCount(#mTextArea_Banghui_DataSource)
				self.mTextArea_Banghui:reloadData()
				local deltaY = 475 - #mTextArea_Banghui_DataSource*90
				if deltaY < 0 then
					deltaY = 0
				end
				self.mTextArea_Banghui.mInnerContainer:setContentOffset(cc.p(0, deltaY))
				self.mTopWidget:getChildByName("Image_Notice_15002"):setVisible(false)
			--	doError("update banghui!")
			elseif 2 == self.mCurChannel then
				-- self.mTextArea_Team:setCellCount(#mTextArea_Team_DataSource)
				-- self.mTextArea_Team:reloadData()
				-- local deltaY = 475 - #mTextArea_Team_DataSource*90
				-- if deltaY < 0 then
				-- 	deltaY = 0
				-- end
				-- self.mTextArea_Team.mInnerContainer:setContentOffset(cc.p(0, deltaY))
			elseif 3 == self.mCurChannel then
				self.mTextArea_Personal:setCellCount(#mTextArea_Personal_DataSource)
				self.mTextArea_Personal:reloadData()
				local deltaY = 475 - #mTextArea_Personal_DataSource*90
				if deltaY < 0 then
					deltaY = 0
				end
				self.mTextArea_Personal.mInnerContainer:setContentOffset(cc.p(0, deltaY))
				self:cancelPersonalCharNotice()
			end

		end
		doOpen()
	else
		local function actEnd()
			self.mOpened = false
			self.mMainPanel:getChildByName("Button_Open"):loadTextureNormal("home_chat_open_1.png")
			self.mMainPanel:getChildByName("Button_Open"):loadTexturePressed("home_chat_open_2.png")
			self.mMainPanel:getChildByName("Button_Open"):setTouchEnabled(true)
			self.mTopWidget:setTouchEnabled(true)
			self.mTopWidget:setTouchEnabled(self.mOpened)
			-- 移除私聊信息
			self:removePersonalTalkInfo()
		end
		local function doClosed()
			local act0 = cc.EaseOut:create(cc.MoveTo:create(moveTime, self.mStartPos), 3)
			local act1 = cc.CallFunc:create(actEnd)
			self.mMainPanel:getChildByName("Button_Open"):setTouchEnabled(false)
			self.mTopWidget:setTouchEnabled(false)
			self.mMainPanel:runAction(cc.Sequence:create(act0, act1))
		end
		doClosed()
	end
end

-- 开启私聊
function BottomChatPanel:talkToSomebody(playerId, playerName)
	if not self.mOpened then
		-- 私人聊天
		self:showTextArea(self.mTopWidget:getChildByName("Image_Personal"))
		-- 开启
		self:openAndClose()
		-- 设置私聊信息
		self:setPersonalTalkInfo(playerId, playerName)
	else
		-- 私人聊天
		self:showTextArea(self.mTopWidget:getChildByName("Image_Personal"))
		-- 设置私聊信息
		self:setPersonalTalkInfo(playerId, playerName)
	end
end

-- 设置帮会聊天信息
function BottomChatPanel:setPartyTalkInfo()
	if "" == globaldata.partyId then -- 未加入公会
		self.mTopWidget:getChildByName("Label_guild_none"):setVisible(true)
		self:setSendBtnEnabled(false)
	else
		self.mTopWidget:getChildByName("Label_guild_none"):setVisible(false)
		self:setSendBtnEnabled(true)
	end
end

-- 移除帮会聊天信息
function BottomChatPanel:removePartyTalkInfo()
	self.mTopWidget:getChildByName("Label_guild_none"):setVisible(false)
	self:setSendBtnEnabled(true)
end

-- 设置私聊信息
function BottomChatPanel:setPersonalTalkInfo(playerId, playerName)
	if mTarPlayerId == globaldata.playerId then
		MessageBox:showMessageBox1("不能跟自己聊天哟~")
		return
	end
	-- 玩家id
	mTarPlayerId = playerId
	-- 玩家姓名
	mTarPlayerName = playerName
	if mTarPlayerName then
		self.mTopWidget:getChildByName("Panel_Chat_Object"):getChildByName("Label_Object"):setString("发送给: "..mTarPlayerName)
		self:setSendBtnEnabled(true)
	else
		self.mTopWidget:getChildByName("Panel_Chat_Object"):getChildByName("Label_Object"):setString("请选择聊天对象")
		self:setSendBtnEnabled(false)
	end
	-- 设置控件显示
	self.mTopWidget:getChildByName("Panel_Chat_Object"):setVisible(true)
end

-- 移除私聊信息
function BottomChatPanel:removePersonalTalkInfo()
	-- 玩家id
	mTarPlayerId = nil
	-- 玩家姓名
	mTarPlayerName = nil
	-- 设置控件显示
	self.mTopWidget:getChildByName("Panel_Chat_Object"):setVisible(false)

	self:setSendBtnEnabled(true)
end

-- 设置按钮能否使用
function BottomChatPanel:setSendBtnEnabled(enabled)
	local btn = self.mTopWidget:getChildByName("Button_Send")
	if enabled then -- 能 
		ShaderManager:DoUIWidgetDisabled(btn, false)
		btn:setTouchEnabled(true)
		self.mTopWidget:getChildByName("Image_InputAudio"):setTouchEnabled(true)
	else -- 不能
		ShaderManager:DoUIWidgetDisabled(btn, true)
		btn:setTouchEnabled(false)
		self.mTopWidget:getChildByName("Image_InputAudio"):setTouchEnabled(false)
	end
end

-- 聊天界面初始化
function BottomChatPanel:init(rootWidget)
	self.mRootNode = rootWidget
	self.mTopWidget = GUIWidgetPool:createWidget("ChatBar")
	rootWidget:addChild(self.mTopWidget, 100)
	self.mTopWidget:setPosition(getGoldFightPosition_LD())

	GUIEventManager:registerEvent("chatInfoRecv", self, self.onRecvChatInfo_UI)

	self.mMainPanel = self.mTopWidget:getChildByName("Panel_Center")
	self.mStartPos = cc.p(self.mMainPanel:getPosition())
	self.mEndPos = cc.p(0, self.mStartPos.y)

	self.mInfoWidget = self.mMainPanel:getChildByName("Image_Info")

	self.mAudioStatusWgt = self.mMainPanel:getChildByName("Image_AudioStatus")
	self.mAudioStatusWgt:setVisible(false)

	self.mTopWidget:setTouchEnabled(self.mOpened)

	local function onTouchRecording(widget, eventType)
		if eventType == ccui.TouchEventType.began then
			local function xxx()
				self:startRecording(widget)
			end
			local act0 = cc.DelayTime:create(0.3)
			local act1 = cc.CallFunc:create(xxx)
			widget:runAction(cc.Sequence:create(act0, act1))
       		widget:loadTexture("chat_btn4_pus.png")
      	elseif eventType == ccui.TouchEventType.ended then
      		widget:stopAllActions()
        	self:stopRecording(widget)
        	widget:loadTexture("chat_btn4_nor.png")
      	elseif eventType == ccui.TouchEventType.moved then
        	self:changeRecording(widget)
      	elseif eventType == ccui.TouchEventType.canceled then
      		widget:stopAllActions()
      		self:stopRecording(widget)
        	widget:loadTexture("chat_btn4_nor.png")
      	end
	end
	self.mTopWidget:getChildByName("Image_InputAudio"):addTouchEventListener(onTouchRecording)

	registerWidgetReleaseUpEvent(self.mMainPanel:getChildByName("Button_Open"), handler(self, self.openAndClose))
	registerWidgetReleaseUpEvent(self.mTopWidget, handler(self, self.openAndClose))

	if not self.mSchedulerEntry then
		local scheduler = cc.Director:getInstance():getScheduler()
		self.mSchedulerEntry = scheduler:scheduleScriptFunc(handler(self, self.tick), 0.1, false)
	end

	-- 初始化Content
	local function initContent()
		-- self.mTextArea_World = self.mTopWidget:getChildByName("ListView_World")
		-- self.mTextArea_World:setVisible(false)
		-- self.mTextArea_Banghui = self.mTopWidget:getChildByName("ListView_Banghui")
		-- self.mTextArea_Banghui:setVisible(false)
		-- self.mTextArea_Team = self.mTopWidget:getChildByName("ListView_Team")
		-- self.mTextArea_Team:setVisible(false)
		-- self.mTextArea_Personal = self.mTopWidget:getChildByName("ListView_Personal")
		-- self.mTextArea_Personal:setVisible(false)

		self.mTopWidget:getChildByName("ListView_World"):setVisible(false)
		self.mTopWidget:getChildByName("ListView_Banghui"):setVisible(false)
		self.mTopWidget:getChildByName("ListView_Team"):setVisible(false)
		self.mTopWidget:getChildByName("ListView_Personal"):setVisible(false)

		local parentNode = self.mTopWidget:getChildByName("Panel_TableView")
		parentNode:setVisible(true)
		local parentSz = parentNode:getContentSize()
		local itemSz = GUIWidgetPool:createWidget("NewHome_ChatCell"):getContentSize()

		self.mTextArea_World = TableViewEx:new()
		self.mTextArea_World:setCellSize(itemSz)
		self.mTextArea_World:registerTableCellAtIndexFunc(handler(self, self.tableCellAtIndex))
		self.mTextArea_World:registerTableCellTouchedFunc(handler(self, self.tableCellTouched))
		self.mTextArea_World:init(parentSz, cc.p(0, 0), 1)
		parentNode:addChild(self.mTextArea_World:getRootNode())

		self.mTextArea_Banghui = TableViewEx:new()
		self.mTextArea_Banghui:setCellSize(itemSz)
		self.mTextArea_Banghui:registerTableCellAtIndexFunc(handler(self, self.tableCellAtIndex))
		self.mTextArea_Banghui:registerTableCellTouchedFunc(handler(self, self.tableCellTouched))
		self.mTextArea_Banghui:init(parentSz, cc.p(0, 0), 1)
		parentNode:addChild(self.mTextArea_Banghui:getRootNode())

		self.mTextArea_Team = TableViewEx:new()
		self.mTextArea_Team:setCellSize(itemSz)
		self.mTextArea_Team:registerTableCellAtIndexFunc(handler(self, self.tableCellAtIndex))
		self.mTextArea_Team:registerTableCellTouchedFunc(handler(self, self.tableCellTouched))
		self.mTextArea_Team:init(parentSz, cc.p(0, 0), 1)
		parentNode:addChild(self.mTextArea_Team:getRootNode())

		self.mTextArea_Personal = TableViewEx:new()
		self.mTextArea_Personal:setCellSize(itemSz)
		self.mTextArea_Personal:registerTableCellAtIndexFunc(handler(self, self.tableCellAtIndex))
		self.mTextArea_Personal:registerTableCellTouchedFunc(handler(self, self.tableCellTouched))
		self.mTextArea_Personal:init(parentSz, cc.p(0, 0), 1)
		parentNode:addChild(self.mTextArea_Personal:getRootNode())

		-- local function tick()
		-- 	print("偏移:", cc.p(self.mTextArea_World.mInnerContainer:getContentOffset()).y)
		-- end
		-- local scheduler = cc.Director:getInstance():getScheduler()
		-- self.mSchedulerEntry = scheduler:scheduleScriptFunc(tick, 0, false)
	end
	initContent()

	-- 初始化顶部菜单栏
	local function initTopMenuList()
		self.mTopWidget:getChildByName("Image_World"):setTag(1)
		self.mTopWidget:getChildByName("Image_Banghui"):setTag(2)
--		self.mTopWidget:getChildByName("Image_Team"):setTag(3)
		self.mTopWidget:getChildByName("Image_Personal"):setTag(4)
		registerWidgetPushDownEvent(self.mTopWidget:getChildByName("Image_World"), handler(self, self.showTextArea))
		registerWidgetPushDownEvent(self.mTopWidget:getChildByName("Image_Banghui"), handler(self, self.showTextArea))
--		registerWidgetPushDownEvent(self.mTopWidget:getChildByName("Image_Team"),handler(self, self.showTextArea))
		registerWidgetPushDownEvent(self.mTopWidget:getChildByName("Image_Personal"), handler(self, self.showTextArea))
	end
	initTopMenuList()

	local function sendText(widget)
		-- 判断世界聊天需要限制
	    if 0 == self.mCurChannel then
			if self.mPreSentTime then
				local curTimeVal = os.time()
				if curTimeVal - self.mPreSentTime <= MAX_CHAT_INTERVAL then
					MessageBox:showMessageBox1("发言过于频繁，请稍后再试")
				return end
			end
		end

		----
		local textImput = self.mEditBox:getText()
		local _textCount = getChineseStringLength(textImput)
		-- cclog("textImput==" .. textImput .. "==" .. _textCount)
		if "" == textImput then
			MessageBox:showMessageBox1("哥们咱能别发空么？!")
		elseif _textCount > CHAT_MAX_WORD_COUNT then
			MessageBox:showMessageBox1(string.format("发送字符个数不能超过%d",CHAT_MAX_WORD_COUNT))
		else
			local packet = NetSystem.mNetManager:GetSPacket()
		    packet:SetType(PacketTyper._PTYPE_CS_REQUEST_SENDCHAT_)
		    packet:PushChar(self.mCurChannel)
		    if 3 ~= self.mCurChannel then
		    	packet:PushString(0)
		    	packet:PushString("")
		    else -- 私聊
		    	packet:PushString(mTarPlayerId)
		    	packet:PushString(mTarPlayerName)
		    end
		    packet:PushChar(1) -- 1:文字 2:语音
		    packet:PushUShort(0)
		    packet:PushString(textImput)
		    GUISystem:showLoading()
		    packet:Send()
		    self.mEditBox:setText("")
		    -- 设置本次发送时间，以至于限制下次发送
		    self.mPreSentTime = os.time()
		end
	end

	local parentNode = self.mTopWidget:getChildByName("Image_InputBar")
	local contentSize = parentNode:getContentSize()
	self.mEditBox = cc.EditBox:create(contentSize, cc.Scale9Sprite:create("chat_input_bar.png"))
	self.mEditBox:setAnchorPoint(cc.p(0, 0))
	self.mEditBox:setFontSize(20)
	self.mEditBox:setFontColor(G_COLOR_C3B.BLACK)
	self.mTextArea = self.mTopWidget:getChildByName("ListView_ChatElement")
	parentNode:addChild(self.mEditBox)
	
	registerWidgetReleaseUpEvent(self.mTopWidget:getChildByName("Button_Send"), sendText)

	registerWidgetReleaseUpEvent(self.mTopWidget:getChildByName("Button_Sound"), handler(self, self.onAudioBtnClicked))

	self.mPanelAudio = self.mTopWidget:getChildByName("Panel_InputAudio")
	self.mPanelAudio:setVisible(false)

	self.mSendHandler = function()
		sendText()
	end
	GUIEventManager:registerEvent("sendChatInfo", self, self.mSendHandler)

	-- 默认显示世界频道
	self:showTextArea(self.mTopWidget:getChildByName("Image_World"))

	-- 初始化界面时，数据表里有数据，显示对应红点
	if #mTextArea_World_DataSource > 0 then
		self.mTopWidget:getChildByName("Image_Notice_15001"):setVisible(true)
	elseif #mTextArea_Banghui_DataSource > 0 then
		self.mTopWidget:getChildByName("Image_Notice_15002"):setVisible(true)
	elseif mChat_Personal_HasNew then
		self.mTopWidget:getChildByName("Image_Notice_15003"):setVisible(true)
		self.mTopWidget:getChildByName("Image_Notice_15000"):setVisible(true)
	end

end

-- 定时器
function BottomChatPanel:tick()
	if self.mIsInRecording then
		self.mTickCount = self.mTickCount + 0.1
		local contentLength = self.mTickCount - self.mPreTickCount
		if contentLength >= 20 then
			local widget = self.mTopWidget:getChildByName("Image_InputAudio")
			widget:stopAllActions()
        	self:stopRecording(widget)
        	widget:loadTexture("chat_btn4_nor.png")
		end
	end
end

-- 点击录音按钮
function BottomChatPanel:onAudioBtnClicked(widget)
	if self.mIsInAudioMode then
		widget:loadTextureNormal("chat_btn1_nor.png")
		widget:loadTexturePressed("chat_btn1_pus.png")
	else
		widget:loadTextureNormal("chat_btn_input1.png")
		widget:loadTexturePressed("chat_btn_input2.png")
	end
	self.mIsInAudioMode = not self.mIsInAudioMode
	self.mPanelAudio:setVisible(self.mIsInAudioMode)
	self.mTopWidget:getChildByName("Image_AudioStatus"):setVisible(false)
end

-- 开始录音
function BottomChatPanel:startRecording(widget)
	if 0 == self.mCurChannel then
		if self.mPreSentTime then
			local preSentTime = self.mPreSentTime
			local curTimeVal = os.time()
		    local interval = curTimeVal - preSentTime
			if interval <= MAX_CHAT_INTERVAL_VOICE then
				MessageBox:showMessageBox1("发言过于频繁，请稍后再试")
				return
			end
		end
	end

	self.mIsInRecording = true
	self.mPanelAudio:setVisible(true)
	self.mPreMovePos = nil
	self.mCurMovePos = nil
	-- 显示正在录音提示
	self.mTopWidget:getChildByName("Image_AudioStatus"):setVisible(true)
	self.mTopWidget:getChildByName("Image_AudioStatus"):loadTexture("chat_btn_status1.png")
	SoundSystem:startRecording()
	self.mPreTickCount = self.mTickCount
	-- 设置本次发送时间，以至于限制下次发送
	self.mPreSentTime = os.time()
end

-- 结束录音
function BottomChatPanel:stopRecording(widget)
	local contentLength = 0
	-- 上传结束
	local function finishUploading(fileName)
		local packet = NetSystem.mNetManager:GetSPacket()
	    packet:SetType(PacketTyper._PTYPE_CS_REQUEST_SENDCHAT_)
	    packet:PushChar(self.mCurChannel)
	    packet:PushString(0)
	    packet:PushString("")
	    packet:PushChar(2) -- 1:文字 2:语音
	    packet:PushUShort(math.ceil(contentLength))
	    packet:PushString(fileName)
	    packet:Send()
	end
	--  取消录音
	local function cancelRecording()
		SoundSystem:cancelRecording()
		self.mPreTickCount = 0
		self.mTickCount = 0
	end
	------
	if self.mIsInRecording then -- 发送
		contentLength = self.mTickCount - self.mPreTickCount
		if contentLength >= 0.5 then
			SoundSystem:finishRecording()
			NetSystem:uploadFile(SoundSystem.mRecordFile, finishUploading)
			GUISystem:showLoading()
		else
			MessageBox:showMessageBox1("太。。。。短了！（>﹏<）")
			cancelRecording()
		end
	else 						-- 取消
		cancelRecording()
	end
	---------------------
	self.mTopWidget:getChildByName("Image_AudioStatus"):setVisible(false)
	self.mIsInRecording = false
	self.mTopWidget:getChildByName("Image_AudioStatus"):loadTexture("chat_btn_status2.png")
end

-- 调整录音状态
function BottomChatPanel:changeRecording(widget)
	local deltaY = 10
	if not self.mPreMovePos then
		self.mPreMovePos = cc.p(widget:getTouchMovePosition())
		self.mPreMovePos.y = self.mPreMovePos.y - 1
	else
		if math.abs(self.mPreMovePos.y - self.mCurMovePos.y) > deltaY then
			self.mPreMovePos = self.mCurMovePos
		end
	end
	self.mCurMovePos = cc.p(widget:getTouchMovePosition())
	if (self.mCurMovePos.y - self.mPreMovePos.y) >= deltaY then -- 手指上
		self.mIsInRecording = false
		self.mTopWidget:getChildByName("Image_AudioStatus"):loadTexture("chat_btn_status2.png")
	elseif (self.mPreMovePos.y - self.mCurMovePos.y) >= deltaY then -- 手指下
		self.mIsInRecording = true
		self.mTopWidget:getChildByName("Image_AudioStatus"):loadTexture("chat_btn_status1.png")
	end
end

function BottomChatPanel:showTextArea(widget)
	-- 换菜单项图片
	local index = widget:getTag()
	local function replaceTexture()
		self.mTopWidget:getChildByName("Image_World"):loadTexture("chat_btn_1_2.png")
		self.mTopWidget:getChildByName("Image_Banghui"):loadTexture("chat_btn_2_2.png")
--		self.mTopWidget:getChildByName("Image_Team"):loadTexture("chat_btn_3_2.png")
		self.mTopWidget:getChildByName("Image_Personal"):loadTexture("chat_btn_4_2.png")
		widget:loadTexture(string.format("chat_btn_%d_1.png",index))
	end
	replaceTexture()
	-- 隐藏
	self.mTextArea_World:setVisible(false)
	self.mTextArea_Banghui:setVisible(false)
	self.mTextArea_Team:setVisible(false)
	self.mTextArea_Personal:setVisible(false)
	-- 显示
	if "Image_World" == widget:getName() then
		self.mCurChannel = 0
		self.mTextArea_World:setVisible(true)
		-- 移除私聊信息
		self:removePersonalTalkInfo()
		-- 移除公会信息
		self:removePartyTalkInfo()
		self.mTopWidget:getChildByName("Image_Notice_15001"):setVisible(false)
	elseif "Image_Banghui" == widget:getName() then
		self.mCurChannel = 1
		self.mTextArea_Banghui:setVisible(true)
		-- 移除私聊信息
		self:removePersonalTalkInfo()
		-- 设置公会信息
		self:setPartyTalkInfo()
--	elseif "Image_Team" == widget:getName() then
--		self.mCurChannel = 2
--		self.mTextArea_Team:setVisible(true)
		self.mTopWidget:getChildByName("Image_Notice_15002"):setVisible(false)
	elseif "Image_Personal" == widget:getName() then
		self.mCurChannel = 3
		self.mTextArea_Personal:setVisible(true)
		-- 移除公会信息
		self:removePartyTalkInfo()
		-- 设置私聊信息
		self:setPersonalTalkInfo()
		self:cancelPersonalCharNotice()
	end

	if 0 == self.mCurChannel then
		self.mTextArea_World:setCellCount(#mTextArea_World_DataSource)
		self.mTextArea_World:reloadData()
		local deltaY = 475 - #mTextArea_World_DataSource*90
		if deltaY < 0 then
			deltaY = 0
		end
		self.mTextArea_World.mInnerContainer:setContentOffset(cc.p(0, deltaY))
		self.mTopWidget:getChildByName("Image_Notice_15001"):setVisible(false)
	elseif 1 == self.mCurChannel then
		self.mTextArea_Banghui:setCellCount(#mTextArea_Banghui_DataSource)
		self.mTextArea_Banghui:reloadData()
		local deltaY = 475 - #mTextArea_Banghui_DataSource*90
		if deltaY < 0 then
			deltaY = 0
		end
		self.mTextArea_Banghui.mInnerContainer:setContentOffset(cc.p(0, deltaY))
		self.mTopWidget:getChildByName("Image_Notice_15002"):setVisible(false)
	elseif 2 == self.mCurChannel then
		-- self.mTextArea_Team:setCellCount(#mTextArea_Team_DataSource)
		-- self.mTextArea_Team:reloadData()
		-- local deltaY = 475 - #mTextArea_Team_DataSource*90
		-- if deltaY < 0 then
		-- 	deltaY = 0
		-- end
		-- self.mTextArea_Team.mInnerContainer:setContentOffset(cc.p(0, deltaY))
	elseif 3 == self.mCurChannel then
		self.mTextArea_Personal:setCellCount(#mTextArea_Personal_DataSource)
		self.mTextArea_Personal:reloadData()
		local deltaY = 475 - #mTextArea_Personal_DataSource*90
		if deltaY < 0 then
			deltaY = 0
		end
		self.mTextArea_Personal.mInnerContainer:setContentOffset(cc.p(0, deltaY))
		self:cancelPersonalCharNotice()
	end
end

-- 根据聊天数据刷UI
function BottomChatPanel:onRecvChatInfo_UI(msgType, eleObject)
	local chatType = msgType
	local mySelf = false
	if eleObject.mSenderId == globaldata.playerId then
		mySelf = true
	end


	if 0 == chatType then
		self.mTextArea_World:setCellCount(#mTextArea_World_DataSource)
		if self.mOpened and chatType == self.mCurChannel then
			self.mTextArea_World:reloadData()
			local deltaY = 475 - #mTextArea_World_DataSource*90
			if deltaY < 0 then
				deltaY = 0
			end
			self.mTextArea_World.mInnerContainer:setContentOffset(cc.p(0, deltaY))
		else
			self.mTopWidget:getChildByName("Image_Notice_15001"):setVisible(true)
		end

		if chatType ~= self.mCurChannel then
			self.mTopWidget:getChildByName("Image_Notice_15001"):setVisible(true)
		end

	elseif 1 == chatType then
		self.mTextArea_Banghui:setCellCount(#mTextArea_Banghui_DataSource)
		if self.mOpened and chatType == self.mCurChannel then
			self.mTextArea_Banghui:reloadData()
			local deltaY = 475 - #mTextArea_Banghui_DataSource*90
			if deltaY < 0 then
				deltaY = 0
			end
			self.mTextArea_Banghui.mInnerContainer:setContentOffset(cc.p(0, deltaY))
		else
			self.mTopWidget:getChildByName("Image_Notice_15002"):setVisible(true)	
		end

		if chatType ~= self.mCurChannel then
			self.mTopWidget:getChildByName("Image_Notice_15002"):setVisible(true)
		end
	elseif 2 == chatType then
		-- self.mTextArea_Team:setCellCount(#mTextArea_Team_DataSource)
		-- if self.mOpened and chatType == self.mCurChannel then
		-- 	self.mTextArea_Team:reloadData()
		-- 	local deltaY = 475 - #mTextArea_Team_DataSource*90
		-- 	if deltaY < 0 then
		-- 		deltaY = 0
		-- 	end
		-- 	self.mTextArea_Team.mInnerContainer:setContentOffset(cc.p(0, deltaY))
		-- else

		-- end
	elseif 3 == chatType then
		self.mTextArea_Personal:setCellCount(#mTextArea_Personal_DataSource)
		if self.mOpened and chatType == self.mCurChannel then
			self.mTextArea_Personal:reloadData()
			local deltaY = 475 - #mTextArea_Personal_DataSource*90
			if deltaY < 0 then
				deltaY = 0
			end
			self.mTextArea_Personal.mInnerContainer:setContentOffset(cc.p(0, deltaY))
		else
			self.mTopWidget:getChildByName("Image_Notice_15003"):setVisible(true)
			self.mTopWidget:getChildByName("Image_Notice_15000"):setVisible(true)
		end

		if chatType ~= self.mCurChannel and not mySelf then -- 非当前频道并且不是自己
			self.mTopWidget:getChildByName("Image_Notice_15003"):setVisible(true)
			self.mTopWidget:getChildByName("Image_Notice_15000"):setVisible(true)
		end
	end

	local function showTextBubble()
		if not mySelf and not self.mOpened then
			local function openInfo()
				local function doAction()
					local function actEnd()
						self.mInfoWidget:setVisible(false)
						self.mInfoWidget:stopAllActions()
					end
					local act0 = cc.DelayTime:create(5)
					local act1 = cc.EaseIn:create(cc.FadeOut:create(2), 3)
					local act2 = cc.CallFunc:create(actEnd)
					self.mInfoWidget:setVisible(true)
					self.mInfoWidget:setOpacity(255)
					self.mInfoWidget:stopAllActions()
					self.mInfoWidget:runAction(cc.Sequence:create(act0, act1, act2))
				end
				doAction()
			end
			openInfo()
			-- 频道
			if 0 == chatType then
				self.mInfoWidget:getChildByName("Label_Channel"):setString("【世界】")
			elseif 1 == chatType then
				self.mInfoWidget:getChildByName("Label_Channel"):setString("【帮会】")
			elseif 3 == chatType then
				self.mInfoWidget:getChildByName("Label_Channel"):setString("【私聊】")
			end
			-- 姓名
			self.mInfoWidget:getChildByName("Label_Name"):setString(eleObject.mSenderName)
			-- 文本
			self.mInfoWidget:getChildByName("Label_Text"):setString(eleObject.mChatMessage)
			self.mInfoWidget:getChildByName("Label_Text"):setColor(G_COLOR_C3B.WHITE)
		end
	end

	local function showAudioBubble()
		if not mySelf and not self.mOpened then
			local function openInfo()
				local function doAction()
					local function actEnd()
						self.mInfoWidget:setVisible(false)
						self.mInfoWidget:stopAllActions()
					end
					local act0 = cc.DelayTime:create(5)
					local act1 = cc.EaseIn:create(cc.FadeOut:create(2), 3)
					local act2 = cc.CallFunc:create(actEnd)
					self.mInfoWidget:setVisible(true)
					self.mInfoWidget:setOpacity(255)
					self.mInfoWidget:stopAllActions()
					self.mInfoWidget:runAction(cc.Sequence:create(act0, act1, act2))
				end
				doAction()
			end
			openInfo()
			-- 频道
			if 0 == chatType then
				self.mInfoWidget:getChildByName("Label_Channel"):setString("【世界】")
			elseif 1 == chatType then
				self.mInfoWidget:getChildByName("Label_Channel"):setString("【帮会】")
			elseif 3 == chatType then
				self.mInfoWidget:getChildByName("Label_Channel"):setString("【私聊】")
			end
			-- 姓名
			self.mInfoWidget:getChildByName("Label_Name"):setString(eleObject.mSenderName)
			-- 文本
			self.mInfoWidget:getChildByName("Label_Text"):setString("发来一段语音~")
			self.mInfoWidget:getChildByName("Label_Text"):setColor(cc.c3b(255,251,148))
		end
	end

	if 1 == eleObject.mContentType then -- 文字
		showTextBubble()
	else -- 语音
		showAudioBubble()
	end
end

-- 文字消息
local CHAT_TEXT_FONTSIZE = 20
local CHAT_TEXTPANEL_SIZE = cc.size(320,25)

function BottomChatPanel:closeInfo()
	self.mInfoWidget:setVisible(false)
	self.mInfoWidget:stopAllActions()
end

function BottomChatPanel:destroy()
	self.mTopWidget:removeFromParent(true)
	self.mTopWidget = 	nil
	self.mEditBox	=	nil
	self.mIsInAudioMode = false
	self.mPreSentTime = nil
	self.mTextArea_Personal = nil
	self.mTextArea_Team = nil
	self.mTextArea_Banghui = nil
	self.mTextArea_World = nil
	self.mRootNode = nil
	---
	if self.mSchedulerEntry then
		local scheduler = cc.Director:getInstance():getScheduler()
		scheduler:unscheduleScriptEntry(self.mSchedulerEntry)
		self.mSchedulerEntry = nil
	end
	----
	GUIEventManager:unregister("sendChatInfo", self.mSendHandler)
	GUIEventManager:unregister("chatInfoRecv", self.onRecvChatInfo_UI)
end

function BottomChatPanel:tableCellAtIndex(table, index)
	local cell = table:dequeueCell()

	local function updateCellInfo() -- 更新格子信息
		local widget = cell:getChildren()[1]
		-- 初始化
		widget:getChildByName("Panel_Text"):setVisible(false)
		widget:getChildByName("Panel_Text"):getChildByName("Panel_Self"):setVisible(false)
		widget:getChildByName("Panel_Text"):getChildByName("Panel_Others"):setVisible(false)

		widget:getChildByName("Panel_Audio"):setVisible(false)
		widget:getChildByName("Panel_Audio"):getChildByName("Panel_Self"):setVisible(false)
		widget:getChildByName("Panel_Audio"):getChildByName("Panel_Others"):setVisible(false)


		local eleObject = nil

		-- 显示
		if 0 == self.mCurChannel then
			eleObject = mTextArea_World_DataSource[index+1]
		elseif 1 == self.mCurChannel then
			eleObject = mTextArea_Banghui_DataSource[index+1]
		elseif 3 == self.mCurChannel then
			eleObject = mTextArea_Personal_DataSource[index+1]
		end

		if 1 == eleObject.mContentType then -- 文字类型
			widget:getChildByName("Panel_Text"):setVisible(true)
			local parentNode = nil
			if eleObject.mMySelf then
				parentNode = widget:getChildByName("Panel_Text"):getChildByName("Panel_Self")
			else
				parentNode = widget:getChildByName("Panel_Text"):getChildByName("Panel_Others")
			end
			parentNode:setVisible(true)

			-- 头像
			local headWidget = nil
			if 0 == #parentNode:getChildByName("Panel_PlayerHead"):getChildren() then
				headWidget = GUIWidgetPool:createWidget("PlayerHead")
				parentNode:getChildByName("Panel_PlayerHead"):addChild(headWidget)
			else
				headWidget = parentNode:getChildByName("Panel_PlayerHead"):getChildren()[1]
			end

			-- 相片
			headWidget:getChildByName("Image_PlayerHead_Bg"):loadTexture(FindFrameIconbyId(eleObject.mFrameId))
			-- 相框
			headWidget:getChildByName("Image_PlayerHead"):loadTexture(FindFrameIconbyId(eleObject.mImageId))

			-- 级别
			headWidget:getChildByName("Label_Level"):setString(eleObject.mSenderLevel)

			if not eleObject.mMySelf then
				-- 查看
				local function getHeroInfo()
					local packet = NetSystem.mNetManager:GetSPacket()
					packet:SetType(PacketTyper._PTYPE_CS_REQUEST_PLAYER_INFO_)
					packet:PushString(eleObject.mSenderId)
					packet:Send()
					globaldata.requestType = "hallcity"

					-- 关闭
				--	self:openAndClose()
				end
				headWidget:setTouchEnabled(true)
				registerWidgetReleaseUpEvent(headWidget, getHeroInfo)
			end

			local nameTimeAlign = 2
			if eleObject.mMySelf then
				nameTimeAlign = 2
			else
				nameTimeAlign = 1
			end

			-- 名字和时间
			parentNode:getChildByName("Panel_Name&Time"):removeAllChildren()
			if 0 == self.mCurChannel then
				richTextCreateSingleLine(parentNode:getChildByName("Panel_Name&Time"), string.format("#fffa66%s# %s", eleObject.mSenderName, eleObject.mChatTime), nameTimeAlign)
			elseif 1 == self.mCurChannel then -- 帮会
					richTextCreateSingleLine(parentNode:getChildByName("Panel_Name&Time"), string.format("#fffa66 %s# #FFBF13%s# #FFFFFF%s#" , eleObject.mSenderName, PARTYROLESTR[eleObject.mSenderTitle], eleObject.mChatTime), nameTimeAlign)
			elseif 3 == self.mCurChannel then -- 私聊
				if eleObject.mMySelf then
					richTextCreateSingleLine(parentNode:getChildByName("Panel_Name&Time"), string.format("#FFFFFF你对# #FFFA66%s# #FFFFFF说 #%s", eleObject.mTarPlayerName, eleObject.mChatTime), nameTimeAlign)
				else
					richTextCreateSingleLine(parentNode:getChildByName("Panel_Name&Time"), string.format("#fffa66%s# #FFFFFF对你说 %s#", eleObject.mSenderName, eleObject.mChatTime), nameTimeAlign)
				end
			end

			-- 内容
			local lb_txt = parentNode:getChildByName("Label_Text")
			lb_txt:setString(eleObject.mChatMessage)

		else -- 语音类型
			widget:getChildByName("Panel_Audio"):setVisible(true)
			local parentNode = nil
			local imageNode = nil
			if eleObject.mMySelf then
				parentNode = widget:getChildByName("Panel_Audio"):getChildByName("Panel_Self")
				imageNode = parentNode:getChildByName("Image_Bg")
				local node_Panel_Name = parentNode:getChildByName("Panel_Name&Time")
				node_Panel_Name:removeAllChildren()
				richTextCreateSingleLine(node_Panel_Name, string.format("#fffa66%s# %s", eleObject.mSenderName, eleObject.mChatTime), 2)
			else
				parentNode = widget:getChildByName("Panel_Audio"):getChildByName("Panel_Others")
				imageNode = parentNode:getChildByName("Image_Bg")
				local node_Panel_Name = parentNode:getChildByName("Panel_Name&Time")
				node_Panel_Name:removeAllChildren()
				richTextCreateSingleLine(node_Panel_Name, string.format("#fffa66%s# %s", eleObject.mSenderName, eleObject.mChatTime), 1)
			end
			parentNode:setVisible(true)

			-- 头像
			local headWidget = nil
			if 0 == #parentNode:getChildByName("Panel_PlayerHead"):getChildren() then
				headWidget = GUIWidgetPool:createWidget("PlayerHead")
				parentNode:getChildByName("Panel_PlayerHead"):addChild(headWidget)
			else
				headWidget = parentNode:getChildByName("Panel_PlayerHead"):getChildren()[1]
			end

			-- 相片
			headWidget:getChildByName("Image_PlayerHead_Bg"):loadTexture(FindFrameIconbyId(eleObject.mFrameId))
			-- 相框
			headWidget:getChildByName("Image_PlayerHead"):loadTexture(FindFrameIconbyId(eleObject.mImageId))

			-- 级别
			headWidget:getChildByName("Label_Level"):setString(eleObject.mSenderLevel)

			if not eleObject.mMySelf then
				-- 查看
				local function getHeroInfo()
					local packet = NetSystem.mNetManager:GetSPacket()
					packet:SetType(PacketTyper._PTYPE_CS_REQUEST_PLAYER_INFO_)
					packet:PushString(eleObject.mSenderId)
					packet:Send()
					globaldata.requestType = "hallcity"

					-- 关闭
				--	self:openAndClose()
				end
				headWidget:setTouchEnabled(true)
				registerWidgetReleaseUpEvent(headWidget, getHeroInfo)
			end

			-- 动画
			local _resDB = DB_ResourceList.getDataById(574)
			local _spine = CommonAnimation.createSpine_common(_resDB.Res_path2, _resDB.Res_path1)
			imageNode:addChild(_spine)
			local oldPos = cc.p(imageNode:getChildByName("Image_Icon"):getPosition())
			_spine:setPosition(cc.p(oldPos.x, oldPos.y - 12))
			if eleObject.mMySelf then
				_spine:setAnimationWithSpeedScale(0, "left", true, 1)
			else
				_spine:setAnimationWithSpeedScale(0, "right", true, 1)
			end
			_spine:setVisible(false)


			-- 秒数
			imageNode:getChildByName("Label_Time"):setString(tostring(eleObject.mContentLength).."'")

			-- 播放结束
			local function onPlayAudioEnd()
				if eleObject.mMySelf then
					imageNode:loadTexture("chatcle_self_bg.png")
				else
					imageNode:loadTexture("chatcle_other_bg.png")
				end
				imageNode:getChildByName("Image_Icon"):setVisible(true)
				_spine:setVisible(false)
				SoundSystem:stopPlayRecording()
				-- 播放结束
				self.mIsInPlayingAudio = false
				GUISystem:enableUserInput()
			end

			-- 开始播放
			local function onPlayAudioBegin()
				if eleObject.mMySelf then
					imageNode:loadTexture("chatcle_self_bg2.png")
				else
					imageNode:loadTexture("chatcle_other_bg2.png")
				end
				imageNode:getChildByName("Image_Icon"):setVisible(false)
				_spine:setVisible(true)

				local act0 = cc.DelayTime:create(eleObject.mContentLength)
				local act1 = cc.CallFunc:create(onPlayAudioEnd)
				imageNode:runAction(cc.Sequence:create(act0, act1))
				GUISystem:disableUserInput()
			end

			local function playAudio()
				if self.mIsInPlayingAudio then
					return
				else
					self.mIsInPlayingAudio = true
				end

				SoundSystem:downloadAndPlayRecording(eleObject.mChatMessage, onPlayAudioBegin)
			end
			registerWidgetReleaseUpEvent(imageNode, playAudio)
		end
	end

	local function createLocalItemWidget() -- 创建物品
		local widget = GUIWidgetPool:createWidget("NewHome_ChatCell")
		return widget
	end

	if nil == cell then
		cell = cc.TableViewCell:new()
		local itemWidget = createLocalItemWidget()
		cell:addChild(itemWidget)
	else
	
	end

	updateCellInfo()

	return cell
end

function BottomChatPanel:tableCellTouched()
	
end
