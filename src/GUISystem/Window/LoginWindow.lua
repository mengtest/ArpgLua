-- Name: 	LoginWindow
-- Func：	进入游戏第一个窗口
-- Author:	WangShengdong
-- Data:	14-11-11

--[[
登录界面，进入游戏后第一个界面，用于选择服务器，注销帐号等操作。
具体联网登录功能需要配合NetSystem使用
]]

local LoginWindow = 
{
	mName 			= "LoginWindow",
	mRootNode 		= nil,
	mRootWidget 	= nil,
	mPanelSeverSel	= nil,
	mPanelLoading	= nil,
	mHasLoaded      = false,
	mEditBox_usn    = nil,
	mEditBox_pwd    = nil,
}

local _BG_SPINE_RESID_  = 809

function LoginWindow:Release()

end

function LoginWindow:Load()
	if self.mHasLoaded then return end
	cclog("LoginWindow:Load=====begin")
	self.mHasLoaded = true
	-- 播放背景音乐
	SoundSystem:forcePlayBGMandEffect(true)
	CommonAnimation.StopBGMAndAllEffect()
	CommonAnimation.PlayBGM(1)
	---------
	local function _registerCallBack()
		GUIEventManager:registerEvent("serverChanged", self, self.onServerChanged)
		GUIEventManager:registerEvent("loadingResource", self, self.updateLoadingBar)
		GUIEventManager:registerEvent("finishLoadingRes", self, self.onLoadingResFinished)
		GUIEventManager:registerEvent("finishUpdating", self, self.onUpdatingResFinished)
		GUIEventManager:registerEvent("failToGetPlayerInfo", self, self.onFaillGetPlayerInfo)
		-- 注册公告回调
		NetSystem.mNetManager:RegisterPacketHandler(PacketTyper._PTYPE_GC_GET_ANNOUNCE_, handler(self,self.onResponseAnnounce))
		-- 检查版本
		NetSystem.mNetManager:RegisterPacketHandler(PacketTyper._PTYPE_GC_CHECK_VERSION_, handler(self,self.onRequestCheckVersion))
		-- 注册账户
		NetSystem.mNetManager:RegisterPacketHandler(PacketTyper._PTYPE_SC_REGISTERACCOUNT_, handler(self,self.onResisterAccount))
		-- 请求角色列表
		NetSystem.mNetManager:RegisterPacketHandler(PacketTyper._PTYPE_SC_REQUEST_PLAYERLIST_, handler(self,self.onRequestPlayerList))
	end
	_registerCallBack()
	self.mRootNode = cc.Node:create()
	GUISystem:GetRootNode():addChild(self.mRootNode)
	--登录界面，不能自动登录
	NetSystem:setCanAutoConnnectServer(false)
	self:InitLayout()
	-- 设置映射-- by wangsd. 2015-10-10
	local director = cc.Director:getInstance()
	director:setProjection(0)

	cclog("LoginWindow:Load=====end")
	----------------------------------测试spine--------------------------------
	-- local spine = CommonAnimation.createSpine_common("res/spine/binary/role/baixifu.skel", "res/spine/binary/role/baixifu.atlas")
	-- spine:setAnimation(0, "stand", true)
	-- spine:setPosition(cc.p(800,300))
	-- self.mRootNode:addChild(spine, 100)
	-- spine:setScale(2)
	-- local function rand()
	-- 	math.randomseed(os.time())
	-- 	local color = cc.c3b(math.random(1,100)/100,math.random(1,100)/100,math.random(1,100)/100)
	-- 	local saturation = math.random(25,75)/100
	-- 	local light = (math.random(50,150)-100)/100
	-- 	-- local color = cc.c3b(0.3,0,0)
	-- 	local saturation = 1
	-- 	local light = 0.2
	-- 	local bright = 0.2
	-- 	local table = {"b-body","body3-2","b-l-arm1","b-l-arm2","body1","body1-2","body3-2","b-r-arm1","b-r-arm2","c-body1","c-body3-2","c-body3-3","c-l-arm1","c-l-arm2","c-r-arm1","c-r-arm2","l-arm1","l-arm2","r-arm1","r-arm2"}
	-- 	ShaderManager:changeHueWithShading_spine(spine, color, saturation, light, bright, table)
	-- 	local table1 = {"b-hair2","b-hair3","b-hair4","b-hair5","b-hair6","b-hair7","b-hair8","b-hair9","c-hair1","c-hair2","c-hair3","c-hair4","c-hair5","c-hair6","c-hair7","c-hair8","c-hair9","hair1","hair2","hair3","hair4","hair5","hair6","hair7","hair8","hair9","head-2"}
	-- 	local color1 = cc.vec4(1.0, 1.0, 1.0, 1.0)
	-- 	local saturation1 = 0
	-- 	math.randomseed(os.time())
	-- 	math.randomseed(os.time())
	-- 	local hue = math.random(0,360)-180
	-- 	-- local hue = 0
	-- 	local bright = -0.5
	-- 	ShaderManager:changeHue_spine(spine, hue,saturation1, light, table1)
	-- end
	-- nextTick_eachSecond(rand, 0.5)

	-- local _node = cc.Node:create()
	-- _node:addChild(spine)
	-- _node:setPosition(cc.p(500,200))
	

	-- local _node2 = cc.Node:create()
	-- _node2:addChild(_node)
	-- _node2:setPosition(cc.p(0,0))
	-- self.mRootNode:addChild(_node2)


	-- 测试spine颜色
	-- local _color1 = cc.vec4(1.0, 1.0, 1.0, 1.0)
	-- local _color2 = cc.vec4(1.0, 1.0, 0.01, 1.0)
	-- CommonAnimation.Spine_ColorChangeBetween2(spine, _color1, _color2)
	--ShaderManager:changeLight_spine(spine, 0.5)

	--测试spine模糊
	-- ShaderManager:blur_spine(spine, cc.vec2(300,300), 3.0)
	----------------------------------测试spine--------------------------------

	-- local _text = "哈哈哈哈哈哈哈啊哈哈啊哈哈"
	-- -- _text = G_AddChangeLineForText(_text, 20, 100)
	-- local _lb = ccui.Text:create("", "font_2.ttf", 20)
	-- _lb:setString(_text)
	-- _lb:setTextAreaSize(cc.size(100,10))
	-- _lb:enableHeightFitable(true)
	-- _lb:setPosition(cc.p(300,300))
	-- self.mRootNode:addChild(_lb)

	-- doError(_lb:getTextAreaSize().height)

	-- local _lb = cc.Label:create()
	-- _lb:setString("adasdsadasdasdasdasdasdasdasdasdadasasdasa")
	-- _lb:setDimensions(100,50)
	-- _lb:setPosition(cc.p(300,300))
	-- self.mRootNode:addChild(_lb)


	----------------------------------测试特效--------------------------------
	-- ccs.ArmatureDataManager:getInstance():addArmatureFileInfo("res/animation/ui_pve_rewardsbox.csb")
 --    local anim = ccs.Armature:create("ui_pve_rewardsbox")
	-- anim:getAnimation():play("pve_rewardsbox1")
	-- anim:setPosition(cc.p(1140/2, 770/2))
 --    self.mRootNode:addChild(anim)


 	----------------------------------测试播放mp4--------------------------------
-- 	local videoNode = videoObject:new()
--	videoNode:init()
 --	self.mRootNode:addChild(videoNode:getRootNode())
 	--videoNode:setPosition(cc.p(1140/2, 770/2))
 --	videoNode:play("female_skill1.mp4")
end


function LoginWindow:InitLayout()
	self.mRootWidget = GUIWidgetPool:createWidget("LoginWindow_1")
	self.mRootNode:addChild(self.mRootWidget, 1)
	-- 设置版本号
	local _version = self.mRootWidget:getChildByName("Label_VersionNumber")
	local versionNum = EngineSystem:getTheLatestVersion()
	_version:setString(string.format("版本号：%s", versionNum))
	--
	local btnLogin = self.mRootWidget:getChildByName("Button_Login")
	registerWidgetReleaseUpEvent(btnLogin, handler(self, self.loginServer))
	--
	local btnLogout = self.mRootWidget:getChildByName("Button_Logout")
	-- 判断release版本无注销
	if GAME_MODE == ENUM_GAMEMODE.release then
	   btnLogout:setVisible(false)
	end
	registerWidgetReleaseUpEvent(btnLogout, handler(self, self.logoutAccount))
	--
	local btnServerlist = self.mRootWidget:getChildByName("Image_serverlist")
	local labelBlink = self.mRootWidget:getChildByName("Label_blinkText")
	local act0 = cc.FadeOut:create(0.6)
	local act1 = cc.FadeIn:create(0.6)
	labelBlink:runAction(cc.RepeatForever:create(cc.Sequence:create(act0, act1)))
	registerWidgetReleaseUpEvent(btnServerlist, handler(self, self.selectServer))
	--
	self.mPanelSeverSel = self.mRootWidget:getChildByName("Panel_ServerSel")
	self.mPanelLoading = self.mRootWidget:getChildByName("Panel_Loading")
	-- 添加标语
	local byWidget = GUIWidgetPool:createWidget("Loading_HealthyGame")
	byWidget:setAnchorPoint(cc.p(0.5,0))
	byWidget:setPosition(cc.p(VisibleRect:center().x, getGoldFightPosition_LD().y))

	self.mRootNode:addChild(byWidget,10)
	
	--
	-- 展示开场动画
	local _bg = nil
	local function endAni(event)
		if event.type == 'end' and event.animation == 'start' then
		   -- 显示所有组件
		   self.mRootWidget:setVisible(true)
		   _bg:setAnimation(0, "loop", true)
		   -- 请求公告
		   LoginWindow:requestAnnounce()
		end
	end
	self.mRootWidget:setVisible(false)
	local function AA()
		_bg = CommonAnimation.createSpine_commonByResID(_BG_SPINE_RESID_)
		_bg:setAnimation(0, "start", false)
		_bg:setPosition(getGoldFightPosition_Middle())
		self.mRootNode:addChild(_bg, 0)
		_bg:registerSpineEventHandler(endAni,1)
	end
	SpineDataCacheManager:applyForAddSpineDataCache(AA)

	local star = AnimManager:createAnimNode(8063)
	self.mRootNode:addChild(star:getRootNode(), 1)
	star:play("denglu_lizi",true)
	star:getRootNode():setPosition(getGoldFightPosition_Middle())

	---载入所有服务器信息，游戏中仅此一次---
	self:loadLatestServerInfo()

	----版号申请专用-----
	if BANSHU_ENABLED then
		local size = cc.size(400,50)
		local fontsize = 15
		local usn = cc.EditBox:create(size, cc.Scale9Sprite:create("editbox_bg.png"))
		usn:setFontSize(fontsize)
		usn:setPlaceholderFontSize(fontsize)
		usn:setPlaceHolder("用户名")
		usn:setPosition(cc.p(GG_GetWinSize().width/2, GG_GetWinSize().height * 0.55))
		self.mRootNode:addChild(usn,30)
		self.mEditBox_usn = usn

		local pwd = cc.EditBox:create(size, cc.Scale9Sprite:create("editbox_bg.png"))
		pwd:setInputFlag(cc.EDITBOX_INPUT_FLAG_PASSWORD)
		pwd:setFontSize(fontsize)
		pwd:setPlaceholderFontSize(fontsize)
		pwd:setPlaceHolder("密码")
		pwd:setPosition(cc.p(GG_GetWinSize().width/2, GG_GetWinSize().height * 0.48))
		self.mRootNode:addChild(pwd,30)
		self.mEditBox_pwd = pwd
	end
end

--@载入最新可登陆服务器信息
function LoginWindow:loadLatestServerInfo()
	NetSystem.mNetManager:RegisterPacketHandler(PacketTyper._PTYPE_GC_REQUEST_SERVERLIST_, handler(self,self.onGetServerList))
	NetSystem:requestServerList()
	GUISystem:showLoading()
end

-- 接收服务器列表
function LoginWindow:onGetServerList(msgPacket)
	local svrCnt = msgPacket:GetUShort()
	for i =1, svrCnt do
		local svr_id = msgPacket:GetInt()
		local svr_name = msgPacket:GetString()
		local svr_ip = msgPacket:GetString()
		local svr_port = msgPacket:GetInt()
		local svr_state = msgPacket:GetUChar()	-- 0:维护 1:流畅 2:爆满
		local svr_level = msgPacket:GetUChar()
		NetSystem.mServerList[i] = {id = svr_id, name=svr_name, state=tostring(svr_state), ip = svr_ip, port = svr_port}
	end
	local lastServerId = DBSystem:Get_Integer_FromSandBox("server_id")
	local lastServerInfo = {}
	if lastServerId == 0 then
	   for k,info in pairs(NetSystem.mServerList) do
	   	   lastServerId = info.id
	   break end
	end
	for k,info in pairs(NetSystem.mServerList) do
		if info.id == lastServerId then
			lastServerInfo = info
		end
	end
	-- 设置选定服务器信息
	NetSystem.mServerInfo = 
	{
		id = lastServerId,
		ip = lastServerInfo.ip,
		port = lastServerInfo.port,
		name = lastServerInfo.name,
		state = lastServerInfo.state,
	}
	local labelName = self.mRootWidget:getChildByName("Label_serverName")
	labelName:setString(NetSystem.mServerInfo.name)
	GUISystem:hideLoading()
end

-- 保存本次登录的服务器信息
function LoginWindow:saveLatestServerId()
	DBSystem:Save_Integer_ToSandBox("server_id", NetSystem.mServerInfo.id)
	DBSystem:flush()
end

-- 加载资源
function LoginWindow:requestLoadingRes()
	self.mPanelSeverSel:setVisible(false)
	self.mPanelLoading:setVisible(true)
	GUIWidgetPool:init()
	GUISystem:hideLoading()
end

-- 请求更新
function LoginWindow:requestDoUpdating()
	UpdateManager:StartUpdate()
	self.mPanelSeverSel:setVisible(false)
	self.mPanelLoading:setVisible(true)
end

-- 更新载入条
function LoginWindow:updateLoadingBar(resPercent, resName)
	local loadingBar = self.mPanelLoading:getChildByName("ProgressBar_LoadingRes")
	loadingBar:setPercent(resPercent)
	local loadingState = self.mPanelLoading:getChildByName("Label_LoadingState")	
	loadingState:setString(resName)
end

-- 进入游戏
function LoginWindow:enterGame()
	if NetSystem.mPlayerCount == 0 then
		cclog("没有角色, 进入创建角色界面")
    	-- 进入创建角色界面
        EventSystem:PushEvent(Event.GUISYSTEM_HIDE_LOGINWINDOW)
		EventSystem:PushEvent(Event.GUISYSTEM_SHOW_ROLESELWINDOW)
	else
        --  1004
        cclog("有角色, 直接登录")
        NetSystem:requestPlayerLogin()
	end
end

-- 载入资源完毕
function LoginWindow:onLoadingResFinished()
	cclog("LoginWindow:onLoadingResFinished===载入资源完毕")
	self:enterGame()
end

-- 更新资源完毕
function LoginWindow:onUpdatingResFinished()
	self.mPanelSeverSel:setVisible(true)
	self.mPanelLoading:setVisible(false)
end

-- 请求角色列表回包
function LoginWindow:onRequestPlayerList(msgPacket)
	NetSystem:handleRoleListResponse(msgPacket)
	self:requestLoadingRes()
end

-- 注册账户回包
function LoginWindow:onResisterAccount(msgPacket)
	local ret = msgPacket:GetUShort()
	if 0 == ret then
		-- 注册成功
		local account = msgPacket:GetString()
		-- 记录帐号
		NetSystem.mAccount = account
		local pwd = msgPacket:GetString()
		local accountFileName = cc.FileUtils:getInstance():getWritablePath().."account.json"
    	local accountFile = io.open(accountFileName, "w")
    	accountFile:setvbuf("no")
    	local luaTable = {}
    	luaTable.account = account
    	luaTable.pwd = pwd
    	local jsonString = json.encode(luaTable)
    	accountFile:write(jsonString)
		io.close(accountFile)
		-- 第一次连接,加载资源
		self:requestLoadingRes()
	end
end

-- 登录游戏服务器
function LoginWindow:loginServer()
	-- 加判断是否正在登录sdk，防止多次重复点击登录
	if AnySDKManager.misLoginingBySDK then return end
	GUISystem:playSound("homeBtnSound")
	local canNormalLogin = true
	if BANSHU_ENABLED then
		local usn = self.mEditBox_usn:getText()
		local pwd = self.mEditBox_pwd:getText()
		if usn ~= "" then
			NetSystem:setUsnAndPwd(usn, pwd)
			if NetSystem:checkUsnAndPwd() then
				NetSystem:connectToGameServer()
			end
			canNormalLogin = false
		end
	end
	----
	if canNormalLogin then
		if NetSystem.mServerInfo.state == '0' then
		   MessageBox:showMessageBox1("服务器正在维护")
		else
		   self:requestCheckVersion()
		end
	end
end

-- 注销
function LoginWindow:logoutAccount()
	local function func()
		local accountFileName = cc.FileUtils:getInstance():getWritablePath().."account.json"
	    local accountFile = io.open(accountFileName, "w")
	    accountFile:setvbuf("no")
		accountFile:write("")
		io.close(accountFile)
		doError("Logout Account Success!!")
	end
	func()
end

-- 请求公告
function LoginWindow:requestAnnounce()
	NetSystem:requestAnnounce()
end

-- 公告回调
function LoginWindow:onResponseAnnounce(msgPacket)
	local str = ""
	local cnt = msgPacket:GetUShort()
	if cnt > 0 then
		local str_hor = "#FFFF0F—————————————————————————#"
		str = string.format("1. %s\n%s\n\n\n\n\n\n\n\n\n", msgPacket:GetString(), msgPacket:GetString())
		for i = 2,cnt do
			str = string.format("%s%s\n%d. %s\n", str, str_hor, i, msgPacket:GetString())
			str = string.format("%s\n%s\n\n\n\n\n\n\n\n\n", str, msgPacket:GetString())
		end
		self:ShowBulletin(str)
		GUISystem:hideLoading()
	end
end

-- 请求版本检查
function LoginWindow:requestCheckVersion()
	if "" ~= NetSystem.mServerInfo.ip then
		NetSystem:requestCheckVersion()
	else
		MessageBox:showMessageBox1("请先选择要登录的服务器")
	end
end

-- 版本检查响应
-- ps: 0 :  无需要更新的版本直接走登录流程
--	   1 :  否则直接更新，更完重载loginwindow界面
function LoginWindow:onRequestCheckVersion(msgPacket)
	GUISystem:hideLoading()
	local ret = msgPacket:GetUChar()
	if 0 == ret then
		NetSystem:loginDispatch()
	elseif 1 == ret then
		local upCnt = msgPacket:GetUShort()
		for i = 1, upCnt do
			local _update = {}
			_update.version = msgPacket:GetString()
			_update.type = msgPacket:GetUChar()
			_update.md5 = msgPacket:GetString()
			_update.url = msgPacket:GetString()
			UpdateManager:PushUpdateVersion(_update)
		end
		self:requestDoUpdating()
	end
end

-- 点击选服按钮
function LoginWindow:selectServer()
	EventSystem:PushEvent(Event.GUISYSTEM_SHOW_SERVERSELWINDOW)
end

-- 更换选择的服务器
function LoginWindow:onServerChanged(serverInfo)
	local labelName = self.mRootWidget:getChildByName("Label_serverName")
	-- 记录选择的服务器
	NetSystem.mServerInfo = 
	{
		id = serverInfo.id,
		ip = serverInfo.ip,
		port = serverInfo.port,
		name = serverInfo.name,
		state = tostring(serverInfo.state),
	}

	labelName:setString(NetSystem.mServerInfo.name)
	self:saveLatestServerId()
end

-- 获取玩家信息失败通知（没有收到1003，而是收到995）
function LoginWindow:onFaillGetPlayerInfo()
   -- 取消加载资源控件显示，显示默认进来时候的控件
   	self.mPanelSeverSel:setVisible(true)
	self.mPanelLoading:setVisible(false)
end

function LoginWindow:ShowBulletin(bulletinStr)
	local bulletin   = GUIWidgetPool:createWidget("LoginWindow_Notice")
	local panel_15   = bulletin:getChildByName("Panel_15")
	local panel_window = bulletin:getChildByName("Panel_Window")
	local textPanel  = bulletin:getChildByName("Panel_Text")
	local sv 		 = bulletin:getChildByName("ScrollView_Text")
	local richText   = richTextCreate(textPanel,bulletinStr,true,nil,false)
	local size 		 = sv:getContentSize()
	local textHeight = richText:getTextHeight()

	sv:setInnerContainerSize(cc.size(size.width,textHeight))
	self.mRootNode:addChild(bulletin,1000)
	registerWidgetReleaseUpEvent(bulletin:getChildByName("Button_Close"),function() bulletin:removeFromParent()  bulletin = nil end) 
	-- 弹出动画
	panel_window:setAnchorPoint(cc.p(0.5,0.5))
	panel_window:setPosition(cc.p(panel_15:getContentSize().width/2, panel_15:getContentSize().height/2))
	panel_window:setScale(0.5)
	local act0 = cc.ScaleTo:create(0.15, 1)
	local act1 = cc.FadeIn:create(0.15)
	panel_window:runAction(cc.Spawn:create(act0, act1))
end

function LoginWindow:Destroy()
	if not self.mHasLoaded then return end
	cclog("LoginWindow:Destroy=====begin")
	SoundSystem:forcePlayBGMandEffect(false)
	-- 记录服务器信息
    local function unregisterFunc()
    	GUIEventManager:unregister("serverChanged", self.onServerChanged)
		GUIEventManager:unregister("loadingResource", self.updateLoadingBar)
		GUIEventManager:unregister("finishLoadingRes", self.onLoadingResFinished)
		GUIEventManager:unregister("finishUpdating", self.onUpdatingResFinished)
		GUIEventManager:unregister("failToGetPlayerInfo", self.onFaillGetPlayerInfo)
		---
		NetSystem.mNetManager:UnregisterPacketHandler(PacketTyper._PTYPE_GC_GET_ANNOUNCE_)
		NetSystem.mNetManager:UnregisterPacketHandler(PacketTyper._PTYPE_GC_CHECK_VERSION_)
		NetSystem.mNetManager:UnregisterPacketHandler(PacketTyper._PTYPE_SC_REGISTERACCOUNT_)
		NetSystem.mNetManager:UnregisterPacketHandler(PacketTyper._PTYPE_SC_REQUEST_PLAYERLIST_)
    end
    unregisterFunc()
	self.mRootNode:removeFromParent()
	self.mRootNode = nil
	self.mRootWidget = nil
	self.mPanelSeverSel = nil
	self.mPanelLoading = nil
	self.mHasLoaded = false
	----
	CommonAnimation.clearAllTexturesAndSpineData()
	--离开登录界面，需要开启自动登录
	NetSystem:setCanAutoConnnectServer(true)
	cclog("LoginWindow:Destroy=====end")
end

function LoginWindow:onEventHandler(event)
	if event.mAction == Event.WINDOW_SHOW then
		self:Load()
	elseif event.mAction == Event.WINDOW_HIDE then
		self:Destroy()
	end
end

return LoginWindow