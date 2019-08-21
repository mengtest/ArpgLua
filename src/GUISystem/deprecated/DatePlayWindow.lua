-- Name: 	DatePlayWindpw
-- Func：	伙伴玩法窗口
-- Author:	WangShengdong
-- Data:	15-2-2

DatePlayModel = class("DatePlayModel")

function DatePlayModel:ctor(owner)
	self.mName 		    = "DatePlayModel"
	self.mOwner			= owner
	self.mEventId		= nil
	self.mEventType		= nil
	self.mObjectId		= nil
	self.mResultId		= nil
	self.mPrice			= nil
	self.mLoveVal       = nil 
	self.mLoveMaxVal    = nil
	self:registerNetEvent()
end

function DatePlayModel:registerNetEvent()
	NetSystem.mNetManager:RegisterPacketHandler(PacketTyper._PTYPE_SC_REQUEST_DATE_PLAY_, handler(self, self.onDatePlayInfoResponse))
	-- 更换心情
	NetSystem.mNetManager:RegisterPacketHandler(PacketTyper._PTYPE_SC_REQUEST_DATE_CHANGE_, handler(self, self.onChangeMoodResponse))
	-- 去上学
	NetSystem.mNetManager:RegisterPacketHandler(PacketTyper._PTYPE_SC_REQUEST_DATE_GO_, handler(self, self.onPlayResponse))
end

function DatePlayModel:doDatePlayInfoRequest(eventId,objectId)
	local packet = NetSystem.mNetManager:GetSPacket()
    packet:SetType(PacketTyper._PTYPE_CS_REQUEST_DATE_PLAY_)
    packet:PushInt(eventId)
    packet:PushInt(objectId)
    packet:Send()
    GUISystem:showLoading()
end

function DatePlayModel:onDatePlayInfoResponse(msgPacket)
	self.mEventId     = msgPacket:GetInt()
	self.mEventType	  = msgPacket:GetChar()
	self.mObjectId    = msgPacket:GetInt()
	self.mResultId    = msgPacket:GetInt()
	self.mPrice	      = msgPacket:GetInt()   -- 价格
	self.mLoveVal     = msgPacket:GetInt() 	 -- 好感度
	self.mLoveMaxVal  = msgPacket:GetInt()   -- 好感度最大值

	GUISystem:hideLoading()
	self.mOwner:InitLayout()
end

function DatePlayModel:doChangeMoodRequest(eventId,objectId)
	local packet = NetSystem.mNetManager:GetSPacket()
	packet:SetType(PacketTyper._PTYPE_CS_REQUEST_DATE_CHANGE_)
	packet:PushInt(eventId)
	packet:PushInt(objectId)
	packet:Send()
	GUISystem:showLoading()
end

function DatePlayModel:onChangeMoodResponse(msgPacket)
	local eventId    = msgPacket:GetInt()
	local eventType  = msgPacket:GetChar()
	local objectId   = msgPacket:GetInt()
	self.mResultId   = msgPacket:GetInt()
	self.mPrice      = msgPacket:GetInt()
	self.mLoveVal    = msgPacket:GetInt()
	self.mLoveMaxVal = msgPacket:GetInt()

	GUISystem:hideLoading()
	self.mOwner:showResultDlg()
end

-- 一起上学
function DatePlayModel:doPlayRequest(eventId,objectId)
	local packet = NetSystem.mNetManager:GetSPacket()
	packet:SetType(PacketTyper._PTYPE_CS_REQUEST_DATE_GO_)
	packet:PushInt(eventId)
	packet:PushInt(objectId)
	packet:PushInt(self.mResultId)
	packet:Send()
	GUISystem:showLoading()
end

function DatePlayModel:onPlayResponse(msgPacket)
	GUISystem:hideLoading()
	local success = msgPacket:GetChar()
	if 0 == success then 		-- 成功
		self.mOwner:NotifyPlaySuccess()
	elseif 1 == success then 	-- 失败
		
	end
end


function DatePlayModel:deinit()
	self.mName 		    = nil
	self.mOwner			= nil
	self.mEventId		= nil
	self.mEventType		= nil
	self.mObjectId		= nil
	self.mResultId		= nil
	self.mPrice			= nil
	self.mLoveVal       = nil 
	self.mLoveMaxVal    = nil
end

--==================================================================Window begin========================================================================
local DatePlayWindow = 
{
	mName				=	"DatePlayWindow",
	mRootNode			=	nil,
	mRootWidget			=	nil,
	mEventId 			=	nil,
	mEventType 			=	nil,
	mObjectId 			=	nil,
	mFavorLv			=   nil,
	mFavorExp			=   nil,
	mFavorMaxExp		=   nil,
	mStep 				=	0,
	mModel				=   nil
}

function DatePlayWindow:Release()

end

function DatePlayWindow:Load(event)
	cclog("=====DatePlayWindow:Load=====begin")

	self.mEventId     = event.mData[1]
	self.mEventType	  = event.mData[2]
	self.mObjectId    = event.mData[3]	
	self.mFavorLv     = event.mData[4]	
	self.mFavorExp	  = event.mData[5]	
	self.mFavorMaxExp = event.mData[6]	


	self.mRootNode = cc.Node:create()
	GUISystem:GetRootNode():addChild(self.mRootNode)
	self.mModel = DatePlayModel.new(self)
	
	self.mModel:doDatePlayInfoRequest(self.mEventId,self.mObjectId)

	cclog("=====DatePlayWindow:Load=====end")

end

function DatePlayWindow:InitLayout()
	self.mRootWidget = GUIWidgetPool:createWidget("DatePlayWindow")
	self.mRootNode:addChild(self.mRootWidget)

	self.mTopRoleInfoPanel = TopRoleInfoPanel:new()
	local topInfoPanel = self.mTopRoleInfoPanel:init(self.mRootNode, function() GUISystem:playSound("homeBtnSound") EventSystem:PushEvent(Event.GUISYSTEM_HIDE_DATEPLAYWINDOW) end)

	local function doAdapter()
	    local topInfoPanelSize = topInfoPanel:getContentSize()
	    local newHeight = getGoldFightPosition_LU().y - topInfoPanelSize.height - getGoldFightPosition_LD().y
	    local newPosY = newHeight/2 + getGoldFightPosition_LD().y - self.mRootWidget:getChildByName("Panel_Main"):getContentSize().height/2
	    self.mRootWidget:getChildByName("Panel_Main"):setVisible(false)
		local function doSomething()
			self.mRootWidget:getChildByName("Panel_Main"):setPositionY(newPosY)
			self.mRootWidget:getChildByName("Panel_Main"):setVisible(true)
		end
		doSomething()
	end
	doAdapter()

	-- 刷新心情
	registerWidgetReleaseUpEvent(self.mRootWidget:getChildByName("Button_ChangMood"),function() GUISystem:playSound("homeBtnSound") self.mModel:doChangeMoodRequest(self.mEventId,self.mObjectId) end)
	-- 一起上学
	registerWidgetReleaseUpEvent(self.mRootWidget:getChildByName("Button_Begin"), function() GUISystem:playSound("homeBtnSound") self:UpdatePanelDlg() end)

	local picUrl 	= nil
	local picData 	= nil
	if self.mEventType == 1 then 
		local heroConfigData = DB_HeroConfig.getDataById(self.mObjectId)
		local picId          = heroConfigData.PicID
		picData		 = DB_ResourceList.getDataById(picId)
	else
		picData    = DB_ResourceList.getDataById(self.mObjectId + 20)
	end
	picUrl		 = picData.Res_path1
	self.mRootWidget:getChildByName("Image_Hero"):loadTexture(picUrl,1)

	local eventData = DB_EventTotal.getDataById(self.mEventId)
	local btnDataId = eventData.Event_TotalBtn
	local btnData   = DB_Text.getDataById(btnDataId)
	local btnStr	= btnData.Text_CN

	self.mRootWidget:getChildByName("Label_22"):setString(btnStr)

	self:showResultDlg()
end

local posY = nil

function DatePlayWindow:showResultDlg()
	local objInfo     = DB_EventObject.getDataById(self.mModel.mObjectId)
	local objNameId   = objInfo.Event_ObjectName
	local objName     = getDictionaryText(objNameId)

	local resultInfo  = DB_EventSpecific.getDataById(self.mModel.mResultId)
	local moodId 	  = resultInfo.Event_SpecificResult

	local dateData    = DB_EventObject.getDataById(self.mObjectId)
	local textId      = dateData[string.format("Event_Result%d_text",moodId)]
	local text 	  	  = getDictionaryText(textId)

	if self.mEventType == 2 then
		self.mRootWidget:getChildByName("Image_PrograssBg"):setVisible(false)
		if posY == nil then 
			posY = self.mRootWidget:getChildByName("Label_HeroName_Stroke"):getPositionY()
		end
		self.mRootWidget:getChildByName("Label_HeroName_Stroke"):setPositionY(posY - 14)
	end

	if self.mModel.mPrice <= 0 then 
		self.mRootWidget:getChildByName("Label_ChangNone"):setVisible(true)
		self.mRootWidget:getChildByName("Label_ChangCost"):setVisible(false)
		self.mRootWidget:getChildByName("Image_DiamondCost"):setVisible(false)  
		self.mRootWidget:getChildByName("Button_ChangMood"):setTouchEnabled(false)
		ShaderManager:DoUIWidgetDisabled(self.mRootWidget:getChildByName("Button_ChangMood"), true)
	else
	   self.mRootWidget:getChildByName("Label_ChangNone"):setVisible(false)
	   self.mRootWidget:getChildByName("Label_ChangCost"):setVisible(true)  
	   self.mRootWidget:getChildByName("Image_DiamondCost"):setVisible(true)
	   self.mRootWidget:getChildByName("Button_ChangMood"):setTouchEnabled(true)
	   ShaderManager:DoUIWidgetDisabled(self.mRootWidget:getChildByName("Button_ChangMood"), false)
	end

	self.mRootWidget:getChildByName("Label_HeroName_Stroke"):setString(objName)
	self.mRootWidget:getChildByName("Label_FavorLevel"):setString(tostring(self.mFavorLv))
	self.mRootWidget:getChildByName("Label_FavorNum"):setString(string.format("%d/%d",self.mFavorExp,self.mFavorMaxExp))
	self.mRootWidget:getChildByName("ProgressBar_Level"):setPercent(self.mFavorExp/self.mFavorMaxExp*100)
	self.mRootWidget:getChildByName("Label_Words"):setString(text)
	self.mRootWidget:getChildByName("Label_DimondsNum"):setString(tostring(self.mModel.mPrice))
	self.mRootWidget:getChildByName("Label_Favor"):setString("好感度+"..tostring(self.mModel.mLoveVal))
	self.mRootWidget:getChildByName("Label_MaxFavor"):setString("最大+"..tostring(self.mModel.mLoveMaxVal))
end

function DatePlayWindow:UpdatePanelDlg()
	self.mRootWidget:getChildByName("Panel_mood"):setVisible(false)
	registerWidgetReleaseUpEvent(self.mRootWidget:getChildByName("Panel_Dialogue"), handler(self, self.showTalking))
	self:showTalking(self.mRootWidget:getChildByName("Panel_Dialogue"))
	self.mRootWidget:getChildByName("Panel_Dialogue"):setVisible(true)
end

-- 显示对话
function DatePlayWindow:showTalking(widget)
	self.mStep = self.mStep + 1

	print("步骤", self.mStep)

	local dlg1 = widget:getChildByName("Image_Dialogue1")
	local dlg2 = widget:getChildByName("Image_Dialogue2")


	local resultInfo  = DB_EventSpecific.getDataById(self.mModel.mResultId)
	local moodId 	  = resultInfo.Event_SpecificResult
	local dateData    = DB_EventObject.getDataById(self.mObjectId)

	local talkIds     = dateData[string.format("Event_%d_talk_%d",self.mEventId,moodId)]
	local talkIdArr   = extern_string_split_(talkIds,',')

	local function dlgAnimation(dlg)
		local dlgPos = cc.p(dlg:getPosition())
		local dlgSize = dlg:getContentSize()

		local function runBegin()
			dlg:setVisible(true)
			dlg:setOpacity(0)
			if dlg:getName() == "Image_Dialogue1" then
				dlg:setPositionX(dlgPos.x - dlgSize.width)
			else
				dlg:setPositionX(dlgPos.x + dlgSize.width)
			end
		end
	
		local actBegin   = cc.CallFunc:create(runBegin)
		local fadeIn     = cc.FadeIn:create(1)
		local actMove    = cc.MoveTo:create(0.5, dlgPos)
		local fadeInMove = cc.Spawn:create({fadeIn,actMove})

		local function runFinish()
	   		--dlg1:setVisible(false)
		end

		local actEnd = cc.CallFunc:create(runFinish)

		dlg:runAction(cc.Sequence:create(actBegin,fadeInMove,actEnd))
	end

	if 1 == self.mStep then
		local talkContent = getDictionaryText(tonumber(talkIdArr[1]))
		local talkContent2 = getDictionaryText(tonumber(talkIdArr[2]))
		dlg1:getChildByName("Label_Text"):setString(talkContent)
		dlg2:getChildByName("Label_Text"):setString(talkContent2)
		dlgAnimation(dlg1)
		dlgAnimation(dlg2)
	elseif 2 == self.mStep then
		local talkContent = getDictionaryText(tonumber(talkIdArr[3]))
		local talkContent2 = getDictionaryText(tonumber(talkIdArr[4]))
		dlg1:getChildByName("Label_Text"):setString(talkContent)
		dlg2:getChildByName("Label_Text"):setString(talkContent2)
		dlgAnimation(dlg1)
		dlgAnimation(dlg2)
	elseif 3 == self.mStep then
		local talkContent = getDictionaryText(tonumber(talkIdArr[5]))
		local talkContent2 = getDictionaryText(tonumber(talkIdArr[6]))
		dlg1:getChildByName("Label_Text"):setString(talkContent)
		dlg2:getChildByName("Label_Text"):setString(talkContent2)
		dlgAnimation(dlg1)
		dlgAnimation(dlg2)
	elseif 4 == self.mStep then
		-- 退出
		self.mModel:doPlayRequest(self.mEventId,self.mObjectId)
		GUIEventManager:pushEvent("dateFinish")
		--EventSystem:PushEvent(Event.GUISYSTEM_HIDE_DATESELECTWINDOW)
	end
end

function DatePlayWindow:NotifyPlaySuccess()
	if self.mEventType == 1 then --个人
		local heroData     = DB_HeroConfig.getDataById(self.mObjectId)
		local heroTextId   = heroData.Name
		local heroTextData = DB_Text.getDataById(heroTextId)
		local heroNameStr  = heroTextData.Text_CN
		MessageBox:showMessageBox1(string.format("%s的好感度 +50",heroNameStr))
	else
		local schoolNameStr = nil 
		if self.mObjectId == 31 then 
			schoolNameStr = "铃兰"
		elseif self.mObjectId == 32 then 
			schoolNameStr = "凤仙"
		elseif self.mObjectId == 33 then 
			schoolNameStr = "热血"
		end
		MessageBox:showMessageBox1(string.format("%s高校的全体学员好感度 +60",schoolNameStr))
	end
	EventSystem:PushEvent(Event.GUISYSTEM_HIDE_DATEPLAYWINDOW)
	GUISystem.Windows["DateWindow"].mModel:doPlayerFavorRequest()
end

function DatePlayWindow:Destroy()
	self.mRootNode:removeFromParent(true)
	self.mRootNode         = nil
	self.mRootWidget       = nil
	self.mTopRoleInfoPanel:destroy()
	self.mTopRoleInfoPanel = nil

	self.mEventId          = nil
	self.mEventType	  	   = nil
	self.mObjectId         = nil
	self.mFavorLv		   = nil
	self.mFavorExp		   = nil
	self.mFavorMaxExp	   = nil

	self.mStep             = 0

	self.mModel:deinit()
	self.mModel            = nil
	CommonAnimation:clearAllTextures()
	cclog("=====DatePlayWindow:Destroy=====")
end

function DatePlayWindow:onEventHandler(event)
	if event.mAction == Event.WINDOW_SHOW then
		self:Load(event)
	elseif event.mAction == Event.WINDOW_HIDE then
		self:Destroy()
	end
end

return DatePlayWindow