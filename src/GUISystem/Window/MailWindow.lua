-- Name: 	MailWindow
-- Func：	邮件窗口
-- Author:	lichuan
-- Data:	15-7-24

-- 邮件对象
local mailObject = {}
function mailObject:new()
	local o = 
	{
		mailId 		= 	nil, 	-- 邮件ID
		mailType 	=	nil,	-- 邮件类型
		mailRead 	=	nil, 	-- 是否读过
		mailItem 	=	nil, 	-- 是否带附件
		mailTile 	=	nil,	-- 邮件标题
		mailDate 	=	nil, 	-- 邮件日期
	}
	o = newObject(o, mailObject)
	return o
end

function mailObject:getKeyValue(key)
	if self[key] then
		return self[key]
	end
	return nil
end

MailModel = class("MailModel")

function MailModel:ctor(owner)
	self.mName 		    = "MailModel"
	self.mOwner			= owner
	self.mMailArr		= {}
	self:registerNetEvent()
end

function MailModel:registerNetEvent()
	NetSystem.mNetManager:RegisterPacketHandler(PacketTyper._PTYPE_SC_REQUEST_GET_MAILINFO_, handler(self, self.onLoadMailInfoResponse))
	NetSystem.mNetManager:RegisterPacketHandler(PacketTyper._PTYPE_SC_REQUEST_OPEN_MAIL_, handler(self, self.onOpenMailResponse))
	NetSystem.mNetManager:RegisterPacketHandler(PacketTyper._PTYPE_SC_REQUEST_GET_MAILItem_, handler(self, self.onGetItemResponse))
	NetSystem.mNetManager:RegisterPacketHandler(PacketTyper._PTYPE_SC_REQUEST_DELETE_MAIL_, handler(self, self.onDeleteMailResponse))
	NetSystem.mNetManager:RegisterPacketHandler(PacketTyper._PTYPE_SC_REQUEST_DELETE_ALLMAIL_, handler(self, self.onDeleteAllMailResponse))
	NetSystem.mNetManager:RegisterPacketHandler(PacketTyper._PTYPE_SC_REQUEST_READ_ALLMAIL_, handler(self, self.onGetAllItemResponse))
end

function MailModel:doLoadMailInfoRequest()
	local packet = NetSystem.mNetManager:GetSPacket()
	packet:SetType(PacketTyper._PTYPE_CS_REQUEST_GET_MAILINFO_)
	packet:Send()
	GUISystem:showLoading()
end

function MailModel:onLoadMailInfoResponse(msgPacket)
	self.mMailArr = {}
	local count = msgPacket:GetUShort()
	for i = 1, count do
		local newMail = mailObject:new()
		newMail.mailId 		= 	msgPacket:GetString()
		newMail.mailType 	=	msgPacket:GetChar()
		newMail.mailRead 	=	msgPacket:GetChar()
		newMail.mailItem 	=	msgPacket:GetChar() 	-- 0：没有 1:有
		newMail.mailTile 	=	msgPacket:GetString()
		newMail.mailDate 	=	msgPacket:GetString()
		self.mMailArr[i] 	= newMail
	end

	table.sort(self.mMailArr,function(mail1,mail2) return mail1.mailRead < mail2.mailRead end)

	GUISystem:hideLoading()
	if self.mOwner ~= nil then 
		self.mOwner.mMailTv:UpdateTableView(#self.mMailArr)
		self.mOwner.mRootWidget:getChildByName("Label_None"):setVisible(#self.mMailArr == 0)
	end
end

function MailModel:doOpenMailRequest(index)
	local packet = NetSystem.mNetManager:GetSPacket()
	packet:SetType(PacketTyper._PTYPE_CS_REQUEST_OPEN_MAIL_)
	packet:PushString(self.mMailArr[index].mailId)
	packet:Send()
	GUISystem:showLoading()
end

function MailModel:onOpenMailResponse(msgPacket )
	local mailId 		= msgPacket:GetString()
	local mailType 		= msgPacket:GetChar()
	local mailRead  	= msgPacket:GetChar()
	local mailTitle 	= msgPacket:GetString()
	local mailSrcId 	= msgPacket:GetString()
	local mailSrcName 	= msgPacket:GetString()
	local mailTime 		= msgPacket:GetString()
	local mailContent   = msgPacket:GetString()
	local mailItemCount = msgPacket:GetUShort()

	for i=1,#self.mMailArr do
		if self.mMailArr[i].mailId == mailId then 
			self.mMailArr[i].mailRead = 1
			break
		end
	end

	local itemList  = {}
	for i = 1, mailItemCount do
		local item = {}
		item.mRewardType = msgPacket:GetInt()
		item.mItemId   = msgPacket:GetInt()
		item.mItemCnt  = msgPacket:GetInt()
		table.insert(itemList,item)
	end

	GUISystem:hideLoading()

	local detail = {itemList,mailTitle,mailContent,mailTime,mailSrcName}

	if self.mOwner ~= nil then 
		self.mOwner:UpdateMailDetail(detail)
	end
end

function MailModel:doGetItemRequest(index)
	local packet = NetSystem.mNetManager:GetSPacket()
    packet:SetType(PacketTyper._PTYPE_CS_REQUEST_GET_MAILITEM_)
    packet:PushString(self.mMailArr[index].mailId)
    packet:Send()
    GUISystem:showLoading()
end

function MailModel:onGetItemResponse(msgPacket)
	local id = msgPacket:GetString()
	local ret = msgPacket:GetChar()
	if 0 == ret then
		for i = 1, #self.mMailArr do
			if id == self.mMailArr[i]:getKeyValue("mailId") then
				self.mMailArr[i].mailItem = 0 -- 没有附件
				break
			end
		end
	end

	GUISystem:hideLoading()
	if self.mOwner ~= nil then 
		self.mOwner:NotifyGetItem()
	end
end

function MailModel:doDeleteMailRequest(index)
	if index == 0 then MessageBox:showMessageBox1("请选择要删除的邮件！") end 
	if self.mMailArr[index].mailItem ~= 0 then MessageBox:showMessageBox1("请领取附件！") return end

	local packet = NetSystem.mNetManager:GetSPacket()
    packet:SetType(PacketTyper._PTYPE_CS_REQUEST_DELETE_MAIL_)
    packet:PushString(self.mMailArr[index].mailId)
    packet:Send()
    GUISystem:showLoading()
end

function MailModel:onDeleteMailResponse(msgPacket)
	local id = msgPacket:GetString()
	local ret = msgPacket:GetChar()
	if 0 == ret then
		for i = 1, #self.mMailArr do
			if id == self.mMailArr[i]:getKeyValue("mailId") then
				table.remove(self.mMailArr, i)
				break
			end
		end
	end
	GUISystem:hideLoading()

	if self.mOwner ~= nil then 
		self.mOwner:Reload()
	end
end

function MailModel:doDeleteAllMailRequest()
	if #self.mMailArr == 0 then MessageBox:showMessageBox1("邮箱中没有邮件！") return end

	local function isAllItemGet()
		for i=1,#self.mMailArr do
			if self.mMailArr[i].mailItem ~= 0 then 
				return false
			end
		end
		return true
	end

	if false == isAllItemGet() then MessageBox:showMessageBox1("请领取附件！") return end

	local packet = NetSystem.mNetManager:GetSPacket()
    packet:SetType(PacketTyper._PTYPE_CS_REQUEST_DELETE_ALLMAIL_)
    packet:Send()
    GUISystem:showLoading()
end

function MailModel:onDeleteAllMailResponse(msgPacket)
	local ret = msgPacket:GetChar()
	if 0 == ret then
		self.mMailArr = {}
	end
	GUISystem:hideLoading()

	if self.mOwner ~= nil then 
		self.mOwner:Reload()
	end
end

function MailModel:doGetAllItemRequest()
	if #self.mMailArr == 0 then MessageBox:showMessageBox1("邮箱中没有邮件！") return end

	local packet = NetSystem.mNetManager:GetSPacket()
    packet:SetType(PacketTyper._PTYPE_CS_REQUEST_READ_ALLMAIL_)
    packet:Send()
    GUISystem:showLoading()
end

function MailModel:onGetAllItemResponse(msgPacket)
	local ret = msgPacket:GetChar()
	if 0 == ret then
		for i = 1, #self.mMailArr do	
			self.mMailArr[i].mailItem = 0 -- 没有附件
			self.mMailArr[i].mailRead = 1 -- 已读
		end
	end
	GUISystem:hideLoading()
	if self.mOwner ~= nil then 
		self.mOwner:Reload()
		self.mOwner:NotifyGetItem()
	end
end

function MailModel:deinit()
	self.mName 		    = nil
	self.mOwner			= nil
	self.mMailArr		= nil
end
--===============================================================tabelview begin=====================================================================

local MailTableView = {}

function MailTableView:new(owner,listType)
	local o = 
	{
		mOwner			  = owner,
		mRootNode 	      =	nil,
		mType 		      =	listType,
		mTableView	      =	nil,
		mCurSel	  		  = nil,
		mLstSelCell		  = nil
	}
	o = newObject(o, MailTableView)
	return o
end

function MailTableView:Destroy()
	self.mRootNode:removeFromParent(true)
	self.mRootNode      = nil
	self.mTableView     = nil
	self.mOwner         = nil
	self.mCurSel 		= nil
	self.mLstSelCell	= nil
end

function MailTableView:init(rootNode)
	self.mRootNode = rootNode
	-- 初始化数据源
	self:initTableView()
end

function MailTableView:initTableView()
	self.mTableView = TableViewEx:new()

	local widget = GUIWidgetPool:createWidget("MailLetter")
	self.mTableView:setCellSize(widget:getContentSize())
	self.mTableView:setCellCount(#self.mOwner.mModel.mMailArr)

	self.mTableView:registerTableCellAtIndexFunc(handler(self, self.tableCellAtIndex))
	self.mTableView:registerTableCellTouchedFunc(handler(self, self.tableCellTouched))

	self.mTableView:init(self.mRootNode:getContentSize(), cc.p(0,0), 1)
	self.mRootNode:addChild(self.mTableView:getRootNode())

	self.mTableView:setBounceable(true)
end

function MailTableView:tableCellAtIndex(table, index)
	local cell = table:dequeueCell()

	local mailItem = nil

	if nil == cell then
		cell = cc.TableViewCell:new()
		mailItem = GUIWidgetPool:createWidget("MailLetter")
		
		mailItem:setTouchSwallowed(false)
		mailItem:setTag(1)
		cell:addChild(mailItem)
	else
		mailItem = cell:getChildByTag(1)
		mailItem:getChildByName("Image_bg"):loadTexture("mail_bar_bg.png")
	end

	self:setCellLayOut(mailItem,index+1)

	return cell
end

function MailTableView:tableCellTouched(table,cell)
	if self.mLstSelCell == cell then return end

	if self.mLstSelCell ~= nil then  
		self.mLstSelCell:getChildren()[1]:getChildByName("Image_bg"):loadTexture("mail_bar_bg.png")
	end
	cell:getChildren()[1]:getChildByName("Image_bg"):loadTexture("mail_bar_bg2.png")
	cell:getChildren()[1]:getChildByName("Image_Condition"):loadTexture("mail_logoread.png")

	self.mCurSel = cell:getIdx() + 1
	self.mOwner.mModel:doOpenMailRequest(cell:getIdx()+1)

	self.mLstSelCell = cell
end

function MailTableView:UpdateTableView(cellCnt)
	self.mCurSel = 0
	self.mLstSelCell = nil
	self.mTableView:setCellCount(cellCnt)
	self.mTableView:reloadData()
end

function MailTableView:setCellLayOut(cell,index)
	local mailObj = self.mOwner.mModel.mMailArr[index]

	cell:getChildByName("Label_LetterTitle"):setString(mailObj:getKeyValue("mailTile"))

	cell:getChildByName("Image_Gift"):setTouchEnabled(false)

	if 0 == mailObj:getKeyValue("mailItem") then
		cell:getChildByName("Image_Gift"):setVisible(false)
	elseif 1 == mailObj:getKeyValue("mailItem") then
		cell:getChildByName("Image_Gift"):setVisible(true)
	end
	-- 是否阅读
	if 0 == mailObj:getKeyValue("mailRead") then
		cell:getChildByName("Image_Condition"):loadTexture("mail_logounread.png")
	elseif 1 == mailObj:getKeyValue("mailRead") then
		cell:getChildByName("Image_Condition"):loadTexture("mail_logoread.png")
	end
end

function MailTableView:OnGetItem()
	if self.mLstSelCell ~= nil then 
		self.mLstSelCell:getChildren()[1]:getChildByName("Image_Condition"):loadTexture("mail_logoread.png")
		self.mLstSelCell:getChildren()[1]:getChildByName("Image_Gift"):setVisible(false)
	end
end

--============================================================ windwo begin ===================================================================


local MailWindow = 
{
	mName					=	"MailWindow",
	mRootNode 				= 	nil,
	mRootWidget 			= 	nil,
	mTopRoleInfoPanel		=	nil,

	mPanelLetter 			=	nil, 	-- 邮件信息面板
	mPanelGift 				=	nil, 	-- 附件面板
	mModel                  =   nil,

	mCurSel  				=   nil,
	mMailTv                 =   nil,
}

function MailWindow:Load(event)
	cclog("=====MailWindow:Load=====begin")
	self.mRootNode = cc.Node:create()
	GUISystem:GetRootNode():addChild(self.mRootNode)


	self.mModel = MailModel.new(self)
	self:InitLayout(event)
	cclog("=====MailWindow:Load=====end")
end

function MailWindow:InitLayout(event)
	self.mRootWidget =  GUIWidgetPool:createWidget("MailWindow")
	self.mRootNode:addChild(self.mRootWidget)

	local function closeWindow()
		GUISystem:playSound("homeBtnSound")
		EventSystem:PushEvent(Event.GUISYSTEM_HIDE_MAILWINDOW)
	end

	local topInfoPanel = nil 

	if self.mTopRoleInfoPanel == nil then
		cclog("MailWindow mTopRoleInfoPanel init")
		self.mTopRoleInfoPanel = TopRoleInfoPanel:new()
		topInfoPanel = self.mTopRoleInfoPanel:init(self.mRootNode,ROLE_TITLE_TYPE.TITLE_MAIL, closeWindow)
	end

	local function doAdapter()
		local mainPanel = self.mRootWidget:getChildByName("Panel_Main")
		local mainSize = mainPanel:getContentSize()
		local topSize = self.mTopRoleInfoPanel.mTopWidget:getContentSize()
		local y = getGoldFightPosition_Middle().y - topSize.height / 2
		local x = getGoldFightPosition_Middle().x

		mainPanel:setAnchorPoint(cc.p(0.5, 0.5))
		mainPanel:setPosition(cc.p(x,y))

		mainPanel:setOpacity(0)
		mainPanel:setScale(0.5)
		local act0 = cc.ScaleTo:create(0.15, 1)
		local act1 = cc.FadeIn:create(0.15)
		--local act1 = cc.EaseElasticOut:create(act0)
		mainPanel:runAction(cc.Spawn:create(act0, act1))
	end
	doAdapter()

	self.mPanelLetter  = self.mRootWidget:getChildByName("Panel_Letter")
	self.mPanelGift    = self.mPanelLetter:getChildByName("Panel_GiftPanel")

	self.mPanelLetter:setVisible(false)

	self.mMailTv = MailTableView:new(self,0)
	self.mMailTv:init(self.mRootWidget:getChildByName("Panel_TV"))

	self.mModel:doLoadMailInfoRequest()

	registerWidgetReleaseUpEvent(self.mRootWidget:getChildByName("Button_Get"), function() GUISystem:playSound("homeBtnSound") self.mModel:doGetItemRequest(self.mMailTv.mCurSel) end)
	registerWidgetReleaseUpEvent(self.mRootWidget:getChildByName("Button_Delete"), function() GUISystem:playSound("homeBtnSound") self.mModel:doDeleteMailRequest(self.mMailTv.mCurSel) end)
	registerWidgetReleaseUpEvent(self.mRootWidget:getChildByName("Button_GetAll"), function()  GUISystem:playSound("homeBtnSound") self.mModel:doGetAllItemRequest() end)
	registerWidgetReleaseUpEvent(self.mRootWidget:getChildByName("Button_DeleteAll"), function() GUISystem:playSound("homeBtnSound") self.mModel:doDeleteAllMailRequest() end)


end

function MailWindow:Reload()
	local mailArr = self.mModel.mMailArr
	self.mMailTv:UpdateTableView(#mailArr)
	self.mRootWidget:getChildByName("Button_Delete"):setVisible(false)

	self.mRootWidget:getChildByName("Label_None"):setVisible(#self.mModel.mMailArr == 0)
	if #mailArr == 0 then 
		self.mPanelLetter:setVisible(false)
		self.mRootWidget:getChildByName("Button_Delete"):setVisible(false)
		self.mRootWidget:getChildByName("Button_GetAll"):setVisible(false)
		self.mRootWidget:getChildByName("Button_DeleteAll"):setVisible(false)
	end 
end

function MailWindow:UpdateMailDetail(detail)
	local itemList = detail[1]
	local giftLv   = self.mPanelGift:getChildByName("ListView_Gift")

	giftLv:removeAllItems()

	for i=1, #itemList do
		local widget = createCommonWidget(itemList[i].mRewardType,itemList[i].mItemId,itemList[i].mItemCnt)
		giftLv:pushBackCustomItem(widget)
	end

	-- 邮件标题{itemList,mailTitle,mailContent,mailTime,mailSrcName,mailItemCount}
	self.mPanelLetter:getChildByName("Label_LetterTitle"):setString(detail[2])
	-- 邮件内容
	self.mPanelLetter:getChildByName("Label_LetterText"):setString(detail[3])
	-- 日期和发件人
	self.mPanelLetter:getChildByName("Label_From"):setString(string.format("%s %s",detail[4],detail[5]))
	-- 设置邮件信息显示
	self.mPanelLetter:setVisible(true)

	self.mRootWidget:getChildByName("Button_Delete"):setVisible(true)
	-- 附件
	self.mPanelGift:getChildByName("Button_Get"):setVisible(#itemList > 0)
	self.mPanelGift:getChildByName("ListView_Gift"):setVisible(#itemList > 0)
end

function MailWindow:NotifyGetItem()
	self.mPanelGift:getChildByName("Button_Get"):setVisible(false)
	self.mPanelGift:getChildByName("ListView_Gift"):setVisible(false)
	self.mMailTv:OnGetItem()
end

function MailWindow:Destroy()
	if self.mMailTv ~= nil then 
		self.mMailTv:Destroy()
		self.mMailTv 	= nil
	end

	self.mPanelGift:getChildByName("ListView_Gift"):removeAllItems()

	if self.mTopRoleInfoPanel ~= nil then
		self.mTopRoleInfoPanel:destroy()
		self.mTopRoleInfoPanel = nil
	end

	if self.mRootNode ~= nil then
		self.mRootNode:removeFromParent(true)
		self.mRootNode         = nil
	end

	self.mRootWidget       = nil

	self.mMailListView 	   = nil
	self.mPanelLetter 	   = nil
	self.mPanelGift 	   = nil

	if self.mModel ~= nil then
		self.mModel:deinit()
		self.mModel            = nil
	end
	
	self.mCurSel           = nil

	CommonAnimation.clearAllTextures()
end

function MailWindow:onEventHandler(event)
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

return MailWindow
