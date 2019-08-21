-- Name: 	RoleselWindow
-- Func：	创建人物界面
-- Author:	WangShengdong
-- Data:	15-12-16

local badCharacter = 
{
	"!", "@", "#", "$", "%", "^", "&", "*", "(", ")", "-", "+", "=", "/", "?", ",", ".", "<", ">", "[", "]", "{", "}", "|", "/",
}

local function isBadChar(str)
	for k, v in pairs(badCharacter) do
		if str == v then
			return true
		end
  	end
  	return false
end

local function isBadCharExist(str)
	local strLen = string.len(str)
	for i = 1, strLen do
		local char = string.sub(str, i, i+1)
		if isBadChar(char) then
			return true
		end
	end
	return false
end

local RoleselWindow = 
{
	mName 					= 	"RoleselWindow",
	mRootNode 				= 	nil,
	mRootWidget 			= 	nil,
	---------------------------------------------
	mEditWindow 			=	nil,				-- 输入窗口
	mHeroIdTbl				=	{10, 5},				-- 英雄ID
	mLastChooseWidget		=	nil,				-- 最后一次选择的
	mCurSelectedHeroIndex	=	nil,				-- 当前选择的英雄顺序
	mHeroAnim				=	nil,				-- 动画
	--------------------------------------------
	mLeftAnimNode			=	nil,
	mRightAnimNode			=	nil,
	mResetColorCount		=	{0,0},				
}

function RoleselWindow:Load()
	cclog("=====RoleselWindow:Load=====begin")

	TextureSystem:loadPlist_iconskill()

	--登录界面，不能自动登录
	NetSystem:setCanAutoConnnectServer(false)

	-- 请求随机姓名
	NetSystem.mNetManager:RegisterPacketHandler(PacketTyper._PTYPE_SC_RANDOM_NAME_, handler(self,self.onRequestRandomName))
	NetSystem.mNetManager:RegisterPacketHandler(PacketTyper._PTYPE_SC_REGISTER_COLOR_, handler(self,self.onChangeColor))
	NetSystem.mNetManager:RegisterPacketHandler(PacketTyper._PTYPE_SC_REGISTER_RESET_COLOR_, handler(self,self.onResetColor))

	-- 注册请求角色列表回调,该事件不与loginweindow中的并存
	NetSystem.mNetManager:RegisterPacketHandler(PacketTyper._PTYPE_SC_REQUEST_PLAYERLIST_, handler(self,self.onRequestPlayerList))

	self.mRootNode = cc.Node:create()
	GUISystem:GetRootNode():addChild(self.mRootNode)

	self:InitLayout()

	-- 随机一个名字
	self:requestRandomName()

	cclog("=====RoleselWindow:Load=====end")
end

function RoleselWindow:InitLayout()
	self.mRootWidget = GUIWidgetPool:createWidget("NewCreateRole")
	self.mRootNode:addChild(self.mRootWidget)


	local function doAdapter()
		-- Panel_Role贴左边
		self.mRootWidget:getChildByName("Panel_Role"):setPositionX(getGoldFightPosition_LD().x)

		-- Panel_Right贴右边
		self.mRootWidget:getChildByName("Panel_Right"):setPositionX(getGoldFightPosition_RD().x - self.mRootWidget:getChildByName("Panel_Right"):getContentSize().width)

		-- Panel_Light贴顶上
		self.mRootWidget:getChildByName("Panel_Light"):setPositionY(getGoldFightPosition_LU().y - self.mRootWidget:getChildByName("Panel_Light"):getContentSize().height)
	end
	doAdapter()

	-- 显示窗口
	local function showEditWindow()
		self.mEditWindow:setVisible(true)
	end
	registerWidgetReleaseUpEvent(self.mRootWidget:getChildByName("Button_OK"), showEditWindow)

	-- 关闭窗口
	local function hideEditWindow()
		self.mEditWindow:setVisible(false)
	end
	registerWidgetReleaseUpEvent(self.mRootWidget:getChildByName("Button_Cancle"), hideEditWindow)

	self.mEditWindow = self.mRootWidget:getChildByName("Panel_EditLayer")
	self.mEditWindow:setVisible(false)

	-- 创建编辑框
	self:createEditBox()

	local btn = nil
	btn = self.mRootWidget:getChildByName("Panel_Hero_1")
	btn:setTag(1)
	registerWidgetReleaseUpEvent(btn, handler(self, self.showHeroInfo))

	btn = self.mRootWidget:getChildByName("Panel_Hero_2")
	btn:setTag(2)
	registerWidgetReleaseUpEvent(btn, handler(self, self.showHeroInfo))

	-- 随机
	local btn_Random = self.mRootWidget:getChildByName("Button_Random")
	registerWidgetReleaseUpEvent(btn_Random, handler(self, self.requestRandomName))

	-- 创建
	registerWidgetReleaseUpEvent(self.mRootWidget:getChildByName("Button_Create"), handler(self, self.createNewPalyer))
	-- 创建两个角色
	self:createShowSpine()

	--	默认显示1
	self:showHeroInfo(self.mRootWidget:getChildByName("Panel_Hero_2"))

	for i = 1, 3 do
		local btn = self.mRootWidget:getChildByName("Panel_Skill_"..tostring(i))
		btn:setTag(i)
		registerWidgetReleaseUpEvent(btn, handler(self, self.playSkill))
	end

	registerWidgetReleaseUpEvent(self.mRootWidget:getChildByName("Button_ColorChange"), handler(self, self.onBtnColorChange))
	registerWidgetReleaseUpEvent(self.mRootWidget:getChildByName("Button_ColorBack"), handler(self, self.onBtnColorreset))
end

function RoleselWindow:onBtnColorChange()
	local heroId = self.mHeroIdTbl[self.mCurSelectedHeroIndex]
	local packet = NetSystem.mNetManager:GetSPacket()
    packet:SetType(PacketTyper._PTYPE_CS_REGISTER_COLOR_)
    packet:PushInt(heroId)
    packet:Send(false)
    
    ShaderManager:DoUIWidgetDisabled(self.mRootWidget:getChildByName("Button_ColorChange"), true)
    self.mRootWidget:getChildByName("Button_ColorChange"):setEnabled(false)
    local function doSomthing( ... )
    	ShaderManager:DoUIWidgetDisabled(self.mRootWidget:getChildByName("Button_ColorChange"), false)
    	self.mRootWidget:getChildByName("Button_ColorChange"):setEnabled(true)
    end

    local DelayTime = cc.DelayTime:create(0.5)
    local headfun = cc.CallFunc:create(doSomthing)
    self.mRootWidget:getChildByName("Button_ColorChange"):runAction(cc.Sequence:create(DelayTime,headfun))

    GUISystem:showLoading()
end


function RoleselWindow:onBtnColorreset()
	if self.mResetColorCount[self.mCurSelectedHeroIndex] == 0 then return end
	local heroId = self.mHeroIdTbl[self.mCurSelectedHeroIndex]
	local packet = NetSystem.mNetManager:GetSPacket()
    packet:SetType(PacketTyper._PTYPE_CS_REGISTER_RESET_COLOR_)
    packet:PushInt(heroId)
    packet:Send(false)
    GUISystem:showLoading()  
end

function RoleselWindow:onChangeColor(msgPacket)
	local heroId = msgPacket:GetInt()
	local Colordata = {}
	Colordata.partType = msgPacket:GetChar()
	Colordata.colorType = msgPacket:GetChar()
	if Colordata.colorType > 0 then
		Colordata.colorArrCount = msgPacket:GetUShort()
		Colordata.colorArr = {}
		for i=1,Colordata.colorArrCount do
			Colordata.colorArr[i] = msgPacket:GetUShort()
		end
	end
	local spine = nil
	if self.mHeroIdTbl[self.mCurSelectedHeroIndex] == heroId then
		if self.mCurSelectedHeroIndex == 1 then
			spine = self.mHeroAnim1.mSpine
		else
			spine = self.mHeroAnim2.mSpine
		end
		self.mResetColorCount[self.mCurSelectedHeroIndex] = 1
	end
	if spine then
		ShaderManager:changeColorspineByData(spine,Colordata,heroId)
	end

	GUISystem:hideLoading()
end

function RoleselWindow:onResetColor(msgPacket)
	local heroId = msgPacket:GetInt()
	local _infoDB = DB_HeroConfig.getDataById(heroId)
	local partType = msgPacket:GetChar()

	local spine = nil
	if self.mHeroIdTbl[self.mCurSelectedHeroIndex] == heroId then
		if self.mCurSelectedHeroIndex == 1 then
			spine = self.mHeroAnim1.mSpine
		else
			spine = self.mHeroAnim2.mSpine
		end
		self.mResetColorCount[self.mCurSelectedHeroIndex] = 0
	end
	if spine then
		local part = _infoDB[string.format("Dye%d_part",partType)]
		local Data = {}
		Data.Dye_part = part
		Data.Dye_type = _infoDB[string.format("Dye%d_type",partType)]
		Data.Dye_pic = _infoDB[string.format("Dye%d_pic",partType)]
		ShaderManager:ResumeColor_spine(spine,Data.Dye_pic)	
	end
	GUISystem:hideLoading()
end


-- 播放技能
function RoleselWindow:playSkill(widget)
	local curSpine = nil
	if self.mCurSelectedHeroIndex == 1 then
		curSpine = self.mHeroAnim1
	else
		curSpine = self.mHeroAnim2
	end
	if 1 == widget:getTag() then
	   curSpine:showSkill("skill1", false)
	elseif 2 == widget:getTag() then
	   if self.mCurSelectedHeroIndex == 2 then
	      curSpine:showSkill("skill2-3", false)
	   else
		  curSpine:showSkill("skill2", false)
	   end
	elseif 3 == widget:getTag() then
	   curSpine:showSkill("skill3", false)
	end
	-- local videoFiles = 
	-- {
	-- 	{"female_skill1.mp4", "female_skill2.mp4", "female_skill3.mp4"},
	-- 	{"male_skill1.mp4", "male_skill2.mp4", "male_skill3.mp4"}
	-- }

	-- local videoNode = videoObject:new()

	-- local function videoCallFunc(eventType)
	-- 	if eventType == ccexp.VideoPlayerEvent.PLAYING then
 --        	GUISystem:disableUserInput()
 --        elseif eventType == ccexp.VideoPlayerEvent.PAUSED then
            
 --        elseif eventType == ccexp.VideoPlayerEvent.STOPPED then
        	
 --        elseif eventType == ccexp.VideoPlayerEvent.COMPLETED then
 --        	videoNode:destroy()
 --        	videoNode = nil
 --        	GUISystem:enableUserInput()
 --        end
	-- end

	-- videoNode:init(videoCallFunc)
 -- 	self.mRootNode:addChild(videoNode:getRootNode())
 -- 	videoNode:setPosition(cc.p(1140/2, 770/2))
 -- 	videoNode:setContentSize(cc.size(640, 480))
 -- 	videoNode:play("res/movie/"..videoFiles[self.mCurSelectedHeroIndex][widget:getTag()])
end

-- 新建角色
function RoleselWindow:createNewPalyer()
	local userName = self.mEditBox:getText()
	if "" == userName then
		MessageBox:showMessageBox1("姓名不能为空!")
		return
	end

	local packet = NetSystem.mNetManager:GetSPacket()
    packet:SetType(PacketTyper._PTYPE_CS_REQUEST_CREATEPLAYER_)
    packet:PushInt(self.mHeroIdTbl[self.mCurSelectedHeroIndex])
    packet:PushString(userName)
   	-- 创建指引数据
   	GuideSystem:createGuideData(packet)
    packet:Send(false)
    GUISystem:showLoading()  
end

-- 请求随机姓名
function RoleselWindow:requestRandomName()
	local packet = NetSystem.mNetManager:GetSPacket()
    packet:SetType(PacketTyper._PTYPE_CS_RANDOM_NAME_)
    packet:Send(false)    
    GUISystem:showLoading()
end

-- 响应
function RoleselWindow:onRequestRandomName(msgPacket)
	local name = msgPacket:GetString()
	print("随机姓名", name)
	self.mEditBox:setText(name)
	self.mRootWidget:getChildByName("Label_Notice_1"):setVisible(false)
	GUISystem:hideLoading()
end

function RoleselWindow:createShowSpine()
	local function spineEndAni1(event)
		if event.animation ~= "stand3" then
		    if event.animation == "skill2-3" then
		       self.mHeroAnim1:showSkill("skill2-2", false)
		    else
		    	self.mHeroAnim1:executeCmd("stand3", true)
		    end
		end
	end
	local function spineEndAni2(event)
		if event.animation ~= "stand3" then
		    if event.animation == "skill2-3" then
		       self.mHeroAnim2:showSkill("skill2-2", false)
		    else
		    	self.mHeroAnim2:executeCmd("stand3", true)
		    end
		end
	end
	local function xxx()
		self.mHeroAnim1 = PublicShowRole.new(self.mHeroIdTbl[1], self.mRootWidget:getChildByName("Panel_Hero_Anim"))
		self.mHeroAnim1:executeCmd("relax2", false)
		self.mHeroAnim1:registerSpineAniEndFunc(spineEndAni1)

		self.mHeroAnim2 = PublicShowRole.new(self.mHeroIdTbl[2], self.mRootWidget:getChildByName("Panel_Hero_Anim"))
		self.mHeroAnim2:executeCmd("relax2", false)
		self.mHeroAnim2:registerSpineAniEndFunc(spineEndAni2)

		self.mHeroAnim1:setVisibleSpine(false)
		self.mHeroAnim2:setVisibleSpine(false)
	end
	SpineDataCacheManager:applyForAddSpineDataCache(xxx)
end

-- 显示英雄信息
function RoleselWindow:showHeroInfo(widget)
	if self.mLastChooseWidget == widget then
		return
	end

	for i = 1, 2 do
		self.mRootWidget:getChildByName("Panel_Hero_"..tostring(i)):setOpacity(200)
	end

	-- 换菜单项图片
	local function replaceTexture()
		if self.mLastChooseWidget then
			self.mLastChooseWidget = widget
		else
			self.mLastChooseWidget = widget
		end
		widget:setOpacity(255)
	end
	replaceTexture()

	self.mCurSelectedHeroIndex = widget:getTag()
	self:updateHeroInfo()

	-- leftAnim
	local function addLeftAnim()
		if not self.mLeftAnimNode then
			self.mLeftAnimNode = AnimManager:createAnimNode(8017)
			self.mRootWidget:getChildByName("Panel_Light_Animtion"):addChild(self.mLeftAnimNode:getRootNode(), 100)
		end
		local function xxx()
			self.mLeftAnimNode:play("createrole_light_2", true)
		end
		self.mLeftAnimNode:play("createrole_light_1", false, xxx)
	end
	addLeftAnim()

	-- rightAnim
	local function addRightAnim()
		if self.mRightAnimNode then
			self.mRightAnimNode:destroy()
			self.mRightAnimNode = nil
		end
		self.mRightAnimNode = AnimManager:createAnimNode(8018)
		self.mRootWidget:getChildByName("Panel_Hero"..tostring(self.mCurSelectedHeroIndex).."_Animation"):addChild(self.mRightAnimNode:getRootNode(), 100)
		local function xxx()
			self.mRightAnimNode:play("createrole_hero_2", true)
		end
		self.mRightAnimNode:play("createrole_hero_1", false, xxx)
	end
	addRightAnim()
end

-- 请求角色列表回包
function RoleselWindow:onRequestPlayerList(msgPacket)
	NetSystem:handleRoleListResponse(msgPacket)
    -- 没有角色保留在本页面,有角色直接登录
	if NetSystem.mPlayerCount > 0 then
        --  1004
        cclog("有角色, 直接登录")
        NetSystem:requestPlayerLogin()
    else
    	GUISystem:hideLoading()
	end
end

-- 刷新英雄信息
function RoleselWindow:updateHeroInfo()
	-- 人物动画
	local heroId = self.mHeroIdTbl[self.mCurSelectedHeroIndex]
	--[[
	local function spineEndAni(event)
		if event.animation ~= "stand3" then
		    if event.animation == "skill2-3" then
		       self.mHeroAnim:showSkill("skill2-2", false)
		    else
		    	self.mHeroAnim:executeCmd("stand3", true)
		    end
		end
	end
	if self.mHeroAnim then
		self.mHeroAnim:destroy()
		self.mHeroAnim = nil
	end
	local function xxx()
		self.mHeroAnim = PublicShowRole.new(heroId, self.mRootWidget:getChildByName("Panel_Hero_Anim"))
		self.mHeroAnim:executeCmd("relax2", false)
		self.mHeroAnim:registerSpineAniEndFunc(spineEndAni)
	end
	SpineDataCacheManager:applyForAddSpineDataCache(xxx)
	]]

	if 5 == heroId then
		self.mHeroAnim2:setVisibleSpine(true)
		self.mHeroAnim1:setVisibleSpine(false)
		self.mHeroAnim2:executeCmd("relax2", false)
	elseif 10 == heroId then
		self.mHeroAnim1:setVisibleSpine(true)
		self.mHeroAnim2:setVisibleSpine(false)
		self.mHeroAnim1:executeCmd("relax2", false)
	end

	-- 英雄事迹
	local heroData  = DB_HeroConfig.getDataById(heroId)
	local storyId   = heroData.File
	local storyText = getDictionaryText(storyId)
	self.mRootWidget:getChildByName("Label_Story"):setString(storyText)

	-- 技能描述
	if 5 == heroId then
		self.mRootWidget:getChildByName("Label_SkillDesc"):setString(getDictionaryText(390))
	elseif 10 == heroId then
		self.mRootWidget:getChildByName("Label_SkillDesc"):setString(getDictionaryText(391))
	end


	-- 技能对象
	local skillObject = {}
	function skillObject:new()
		local o = 
		{
			mSkillId	=	nil,	-- 技能ID
			mSkillType	=	nil,	-- 技能类型
			mSkillLevel	=	nil,	-- 技能等级
			mPrice		=	nil,	-- 价格
		}
		o = newObject(o, skillObject)
		return o
	end

	function skillObject:getKeyValue(key)
		if self[key] then
			return self[key]
		end
		return nil
	end

	-- 技能
	for i = 1, 3 do
		local skillId = heroData["Role_SpecialSkill"..tostring(i)]
		local skillData = DB_SkillEssence.getDataById(skillId)
		local skillNameId = skillData.Name
		local skillName = getDictionaryText(skillNameId)
		local skillIconId = skillData.IconID
		local skillIcon = DB_ResourceList.getDataById(skillIconId).Res_path1
		-- 控件
		local skillIconWidget = self.mRootWidget:getChildByName("Panel_Skill_"..tostring(i)):getChildByName("Image_Skill_Icon")
		skillIconWidget:loadTexture(skillIcon, 1)
	end
end

-- 创建输入框
function RoleselWindow:createEditBox()
	self.mEditBox = cc.EditBox:create(cc.size(376, 47), cc.Scale9Sprite:create("editbox_bg.png"))
	self.mEditBox:setFont("res/fonts/font_3.ttf", 25)
	local panelEdit = self.mRootWidget:getChildByName("Panel_Edit")
	local contentSize = panelEdit:getContentSize()
	panelEdit:addChild(self.mEditBox)
	self.mEditBox:setPosition(cc.p(contentSize.width/2, contentSize.height/2))

	local function editBoxTextEventHandle(strEventName,pSender)

		if strEventName == "began" then
			self.mRootWidget:getChildByName("Label_Notice_1"):setVisible(false)
		elseif strEventName == "ended" then
				
		elseif strEventName == "return" then
			local text = self.mEditBox:getText()
			if isBadCharExist(text) then
				MessageBox:showMessageBox1("您输入的名字中含有非法字符")
				self.mEditBox:setText("")
				return
			end

			if getChineseStringLength(text) > 7 then
				MessageBox:showMessageBox1("您输入的字符超过了7个最大限制")
				self.mEditBox:setText("")
				return
			end

			if "" == text then
				self.mRootWidget:getChildByName("Label_Notice_1"):setVisible(true)
			else
				self.mRootWidget:getChildByName("Label_Notice_1"):setVisible(false)
			end
			
		elseif strEventName == "changed" then
			
		end
	end
	self.mEditBox:registerScriptEditBoxHandler(editBoxTextEventHandle)
end

function RoleselWindow:Destroy()
	NetSystem:setCanAutoConnnectServer(true)
	-- 解注册请求角色列表收包事件
	NetSystem.mNetManager:UnregisterPacketHandler(PacketTyper._PTYPE_SC_REQUEST_PLAYERLIST_)

	NetSystem.mNetManager:UnregisterPacketHandler(PacketTyper._PTYPE_SC_REGISTER_COLOR_)
	NetSystem.mNetManager:UnregisterPacketHandler(PacketTyper._PTYPE_SC_REGISTER_RESET_COLOR_)
	self.mHeroAnim1:destroy()
	self.mHeroAnim1 = nil

	self.mHeroAnim2:destroy()
	self.mHeroAnim2 = nil

	if self.mLeftAnimNode then
		self.mLeftAnimNode:destroy()
		self.mLeftAnimNode = nil
	end

	if self.mRightAnimNode then
		self.mRightAnimNode:destroy()
		self.mRightAnimNode = nil
	end
	self.mResetColorCount = {0,0}
	self.mRootNode:removeFromParent(true)
	self.mRootNode = nil
	self.mRootWidget = nil
	SpineDataCacheManager:destroyFightSpineList()
	CommonAnimation:clearAllTexturesAndSpineData()
end

function RoleselWindow:onEventHandler(event)
	if event.mAction == Event.WINDOW_SHOW then
		self:Load()
	elseif event.mAction == Event.WINDOW_HIDE then
		self:Destroy()
	end
end

return RoleselWindow