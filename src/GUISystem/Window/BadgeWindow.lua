-- Name: 	BadgeWindow
-- Func：	英雄技能界面
-- Author:	Wangsd
-- Data:	16-6-22

-- 徽章总数
local totalBadgeCnt = 55

local BadgeWindow = 
{
	mName 					=	"BadgeWindow",
	mRootNode				=	nil,
	mRootWidget				=	nil,
	mTopRoleInfoPanel		=	nil,
	mData 					=	nil,
	mCallFuncAfterDestroy	=	nil,
	--------------------------------------------
	mCurPageIndex			=	1,		-- 当前页
	mMaxPageIndex			=	5,		-- 最大页
	mLeftAnimNode			=	nil,	-- 左滑动特效
	mRightAnimNode			=	nil,	-- 右滑动特效
	mBagWindow				=	nil,	-- 背包
	mDetailWidget			=	nil,	-- 宝石详情窗口
	mDiamondComposeWindow 	=	nil,	-- 宝石合成窗口
	mDiamondHoleAnimList	=	{},		-- 宝石特效链表
	mDiamondStoneAnimList	=	{},		-- 宝石本身特效
	mBadgeInfoWindow		=	nil,	-- 宝石信息窗口
}

function BadgeWindow:Load(event)
	TextureSystem:LoadPlist("res/image/iconitem/icon_badge.plist")

	GUIEventManager:registerEvent("itemInfoChanged", self, self.refresh)

	self.mRootNode = cc.Node:create()
	GUISystem:GetRootNode():addChild(self.mRootNode)

	NetSystem.mNetManager:RegisterPacketHandler(PacketTyper._PTYPE_SC_BADGE_OPEN, handler(self, self.onRequestOpenBadge))
	NetSystem.mNetManager:RegisterPacketHandler(PacketTyper._PTYPE_SC_BADGE_GEM_PUTON, handler(self, self.onRequestDoDiamondPutOn))
	NetSystem.mNetManager:RegisterPacketHandler(PacketTyper._PTYPE_SC_BADGE_GEM_PUTOFF, handler(self, self.onRequestDoDiamondPutOn))
	NetSystem.mNetManager:RegisterPacketHandler(PacketTyper._PTYPE_SC_BADGE_GEM_COM, handler(self, self.onRequestDoDiamondPutOn))

	self.mData = event.mData
	self.mCurPageIndex		=	1

	--初始化界面
	self:InitLayout()

	-- 刷新徽章信息
	self:updateBadgeInfo()

	-- 读图
	self:loadAllBadgeIcon()

	if BadgeGuideOne:canGuide() then
		local guideBtn = self.mRootWidget:getChildByName("Panel_Badge_1"):getChildByName("Button_Badge")
		local size = guideBtn:getContentSize()
		local pos = guideBtn:getWorldPosition()
		pos.x = pos.x - size.width/2
		pos.y = pos.y - size.height/2
		local touchRect = cc.rect(pos.x, pos.y, size.width, size.height)
		BadgeGuideOne:step(1, touchRect)
	end
end

function BadgeWindow:InitLayout()
	self.mRootWidget = GUIWidgetPool:createWidget("Badge")
	self.mRootNode:addChild(self.mRootWidget)

	local function closeWindow()
		EventSystem:PushEvent(Event.GUISYSTEM_HIDE_BADGEWINDOW)
	end

	self.mTopRoleInfoPanel = TopRoleInfoPanel:new()
	local topInfoPanel = self.mTopRoleInfoPanel:init(self.mRootNode, ROLE_TITLE_TYPE.TITLE_BADGE, closeWindow)

	local function doAdapter()
		-- 居中操作
		local topInfoPanelSize = self.mTopRoleInfoPanel.mTopWidget:getContentSize()
	    local newHeight = getGoldFightPosition_LU().y - topInfoPanelSize.height - getGoldFightPosition_LD().y
	    local newPosY = newHeight/2 + getGoldFightPosition_LD().y - self.mRootWidget:getChildByName("Panel_Main"):getContentSize().height/2
	    self.mRootWidget:getChildByName("Panel_Main"):setAnchorPoint(cc.p(0.5, 0.5))
	    local panelSize = self.mRootWidget:getChildByName("Panel_Main"):getContentSize()
	    local curPosX = self.mRootWidget:getChildByName("Panel_Main"):getPositionX()
	    self.mRootWidget:getChildByName("Panel_Main"):setPositionX(curPosX + panelSize.width/2)
		self.mRootWidget:getChildByName("Panel_Main"):setPositionY(newPosY + panelSize.height/2)
	end
	doAdapter()

	self.mRootWidget:getChildByName("Panel_Table_1"):setVisible(true)

	-- 左特效
	self.mLeftAnimNode = AnimManager:createAnimNode(8031)
	self.mRootWidget:getChildByName("Panel_Turn_Left"):getChildByName("Panel_Arrow_Animation"):addChild(self.mLeftAnimNode:getRootNode(), 100)
	self.mLeftAnimNode:play("shop_arraw", true)

	-- 右特效
	self.mRightAnimNode = AnimManager:createAnimNode(8031)
	self.mRootWidget:getChildByName("Panel_Turn_Right"):getChildByName("Panel_Arrow_Animation"):addChild(self.mRightAnimNode:getRootNode(), 100)
	self.mRightAnimNode:play("shop_arraw", true)

	-- 左滑按钮
	local switchBtn = self.mRootWidget:getChildByName("Panel_Turn_Left")
	switchBtn:setTag(-1)
	registerWidgetReleaseUpEvent(switchBtn, handler(self, self.switchPage))

	switchBtn = self.mRootWidget:getChildByName("Panel_Turn_Right")
	switchBtn:setTag(1)
	registerWidgetReleaseUpEvent(switchBtn, handler(self, self.switchPage))

	-- 宝石合成窗口
	self.mDiamondComposeWindow = GUIWidgetPool:createWidget("Bagpack_DiamondCom")
	self.mRootNode:addChild(self.mDiamondComposeWindow, 100)
	self.mDiamondComposeWindow:setVisible(false)

	registerWidgetReleaseUpEvent(self.mRootWidget:getChildByName("Button_AllProperty"), handler(self, self.showPropInfo))
	registerWidgetReleaseUpEvent(self.mRootWidget:getChildByName("Button_Unlock"), handler(self, self.requestOpenBadge))

end

-- 属性信息
function BadgeWindow:showPropInfo()

	local window = GUIWidgetPool:createWidget("Badge_AllProperty")
	self.mRootNode:addChild(window, 1000)

	local function closeWindow()
		window:removeFromParent(true)
		window = nil
	end
	registerWidgetReleaseUpEvent(window, closeWindow)

	for i = 1, self.mData.propCnt do
		window:getChildByName("Panel_Property_"..i):setVisible(true)
		-- 换图
		window:getChildByName("Panel_Property_"..i):getChildByName("Image_Property"):loadTexture(string.format("hero_property_%d.png", self.mData.propList[i].propType))
		-- 数值
		window:getChildByName("Panel_Property_"..i):getChildByName("Label_Init"):setString("+"..self.mData.propList[i].propValue)
	end
end

-- 读图
function BadgeWindow:loadAllBadgeIcon()
	-- 徽章
	for i = 1, 55 do
		local holeInfo = DB_DiamondStar.getDataById(i)
		local itemIcon = holeInfo.IconID
		local imgName = DB_ResourceList.getDataById(itemIcon).Res_path1
		self.mRootWidget:getChildByName("Panel_Badge_"..i):getChildByName("Image_Icon"):loadTexture(imgName, 1)
	end
	-- 宝石
	for i = 101, 120 do
		local holeInfo = DB_DiamondStar.getDataById(i)
		self.mRootWidget:getChildByName("Panel_Diamond_"..i):getChildByName("Image_Quality_Left"):loadTexture("badge_diamond_quality_"..holeInfo.Diamondtype1..".png")
		self.mRootWidget:getChildByName("Panel_Diamond_"..i):getChildByName("Image_Quality_Right"):loadTexture("badge_diamond_quality_"..holeInfo.Diamondtype2..".png")
	end
end

-- 翻页
function BadgeWindow:switchPage(widget)

	local actWidget = self.mRootWidget:getChildByName("Panel_Main")
	local moveTime = 0.15
	local deltaX = 200
	local midPos = cc.p(actWidget:getPosition())
	local leftPos = cc.p(midPos.x - deltaX, midPos.y)
	local rightPos = cc.p(midPos.x + deltaX, midPos.y)


	if -1 == widget:getTag() then
		if self.mCurPageIndex <= 1 then
			return
		end
		self.mCurPageIndex = self.mCurPageIndex - 1

		local function leftAnim()
			local function onActEnd()
				actWidget:setPosition(leftPos)
				-- 刷新页面信息
				self:updatePageInfo()
				local function onActEnd1()
					GUISystem:enableUserInput()
				end
				
				local act0 = cc.MoveTo:create(moveTime, midPos)
				local act1 = cc.FadeIn:create(moveTime)
				local act2 = cc.Spawn:create(act0, act1)
				local act3 = cc.CallFunc:create(onActEnd1)
				actWidget:runAction(cc.Sequence:create(act2, act3))
			end
			
			local act0 = cc.MoveTo:create(moveTime, rightPos)
			local act1 = cc.FadeOut:create(moveTime)
			local act2 = cc.Spawn:create(act0, act1)
			local act3 = cc.CallFunc:create(onActEnd)
			GUISystem:disableUserInput()
			actWidget:runAction(cc.Sequence:create(act2, act3))
		end
		leftAnim()
	elseif 1 == widget:getTag() then
		if self.mCurPageIndex >= self.mMaxPageIndex then
			return
		end
		self.mCurPageIndex = self.mCurPageIndex + 1

		local function rightAnim()
			local function onActEnd()
				actWidget:setPosition(rightPos)
				-- 刷新页面信息
				self:updatePageInfo()
				local function onActEnd1()
					GUISystem:enableUserInput()
				end
				local act0 = cc.MoveTo:create(moveTime, midPos)
				local act1 = cc.FadeIn:create(moveTime)
				local act2 = cc.Spawn:create(act0, act1)
				local act3 = cc.CallFunc:create(onActEnd1)
				actWidget:runAction(cc.Sequence:create(act2, act3))
			end
			
			local act0 = cc.MoveTo:create(moveTime, leftPos)
			local act1 = cc.FadeOut:create(moveTime)
			local act2 = cc.Spawn:create(act0, act1)
			local act3 = cc.CallFunc:create(onActEnd)
			GUISystem:disableUserInput()
			actWidget:runAction(cc.Sequence:create(act2, act3))
		end
		rightAnim()
	end
end

-- 刷新徽章信息
function BadgeWindow:updateBadgeInfo()
	local needOpenHoleIndex = self.mData.curBadgeIndex + 1 -- 当前需要开启的洞序号
	local holeInfo = DB_DiamondStar.getDataById(needOpenHoleIndex)
	local labelWidget = self.mRootWidget:getChildByName("Label_LastBadgePoint")
	if holeInfo then
		-- 星星数
		labelWidget:setString(self.mData.starCnt.."/"..holeInfo.Starcost)
		if holeInfo.Starcost > self.mData.starCnt then
			labelWidget:setColor(cc.c3b(255,162,162))
		else
			labelWidget:setColor(cc.c3b(162,255,169))
		end
	else
		labelWidget:setString(self.mData.starCnt)
		labelWidget:setColor(cc.c3b(162,255,169))
	end
	-- 徽章信息
	for i = 1, totalBadgeCnt do
		local badgeInfo = DB_DiamondStar.getDataById(i)
		local parentNode = self.mRootWidget:getChildByName("Panel_Badge_"..i)
		parentNode:getChildByName("Button_Badge"):setVisible(true)
		parentNode:getChildByName("Image_Icon"):setVisible(true)
		if i <= self.mData.curBadgeIndex then -- 开启已点
			parentNode:getChildByName("Button_Badge"):loadTextureNormal("badge_btn_diamond_2.png")
			parentNode:getChildByName("Button_Badge"):setTag(i)
			registerWidgetReleaseUpEvent(parentNode:getChildByName("Button_Badge"), handler(self, self.onBadgeWidgetClicked))

			-- 特效
			if not self.mDiamondHoleAnimList[i] then
				self.mDiamondHoleAnimList[i] = AnimManager:createAnimNode(8070)
				parentNode:getChildByName("Panel_Animation"):addChild(self.mDiamondHoleAnimList[i]:getRootNode(), 100)
				self.mDiamondHoleAnimList[i]:play("badge_badge_lock", true)
			else
				self.mDiamondHoleAnimList[i]:play("badge_badge_lock", true)
			end
		elseif i == self.mData.curBadgeIndex + 1 then -- 开启未点
			parentNode:getChildByName("Button_Badge"):loadTextureNormal("badge_btn_diamond_1.png")
			registerWidgetReleaseUpEvent(parentNode:getChildByName("Button_Badge"), handler(self, self.requestOpenBadge))

			-- 特效
			if not self.mDiamondHoleAnimList[i] then
				self.mDiamondHoleAnimList[i] = AnimManager:createAnimNode(8070)
				parentNode:getChildByName("Panel_Animation"):addChild(self.mDiamondHoleAnimList[i]:getRootNode(), 100)
				self.mDiamondHoleAnimList[i]:play("badge_badge_open", true)
			end
		else -- 未开启
			parentNode:getChildByName("Button_Badge"):setVisible(false)
			parentNode:getChildByName("Image_Icon"):setVisible(false)
		end
	end
	-- 宝石信息
	for i = 101, 120 do
		local parentNode = self.mRootWidget:getChildByName("Panel_Diamond_"..i)
		if self.mData.diamondList[i] then
			if 0 == self.mData.diamondList[i] then -- 开了没宝石
				parentNode:getChildByName("Image_Diamond"):setVisible(false)
				-- 注册按钮
				parentNode:setTag(i)
				registerWidgetReleaseUpEvent(parentNode, handler(self, self.openBag))

				-- 特效
				if not self.mDiamondStoneAnimList[i] then
					self.mDiamondStoneAnimList[i] = AnimManager:createAnimNode(8071)
					parentNode:getChildByName("Panel_Animation"):addChild(self.mDiamondStoneAnimList[i]:getRootNode(), 100)
					self.mDiamondStoneAnimList[i]:play("badge_diamond_add", true)
				else
					self.mDiamondStoneAnimList[i]:play("badge_diamond_add", true)
				end

			else -- 开了有宝石
				parentNode:getChildByName("Image_Diamond"):setVisible(true)
				-- 更换宝石图
				local diamondData = DB_Diamond.getDataById(self.mData.diamondList[i])
				local diamondIconId = diamondData.Icon
				local imgName = DB_ResourceList.getDataById(diamondIconId).Res_path1
				parentNode:getChildByName("Image_Diamond"):loadTexture(imgName, 1)
				-- 注册按钮
				parentNode:setTag(i)
				registerWidgetReleaseUpEvent(parentNode, handler(self, self.showDiamondInfo))

				-- 特效
				if not self.mDiamondStoneAnimList[i] then
					self.mDiamondStoneAnimList[i] = AnimManager:createAnimNode(8071)
					parentNode:getChildByName("Panel_Animation"):addChild(self.mDiamondStoneAnimList[i]:getRootNode(), 100)
					self.mDiamondStoneAnimList[i]:play("badge_diamond_set", true)
				else
					self.mDiamondStoneAnimList[i]:play("badge_diamond_set", true)
				end
			end
		else -- 没开
			parentNode:getChildByName("Image_Diamond"):setVisible(false)
		end
	end 
	-- 页面信息
	self:updatePageInfo()
	-- 显示最新属性信息
	self:updateNextPropInfo()
	-- 刷新红点
	BadgeNoticeInnerImpl:doUpdate()
end

function BadgeWindow:refresh()
	-- 刷新红点
	BadgeNoticeInnerImpl:doUpdate()
end

function BadgeWindow:updateNextPropInfo()
	local needOpenHoleIndex = self.mData.curBadgeIndex + 1 -- 当前需要开启的洞序号
	local holeInfo = DB_DiamondStar.getDataById(needOpenHoleIndex)
	if holeInfo then
		for i = 1, 3 do
			self.mRootWidget:getChildByName("Panel_CurBadge"):getChildByName("Panel_Property_"..i):setVisible(false)
		end
		for i = 1, 3 do
			if -1 ~= holeInfo["type"..i] then
				local parentNode = self.mRootWidget:getChildByName("Panel_CurBadge"):getChildByName("Panel_Property_"..i)
				parentNode:setVisible(true)
				-- 换图
				parentNode:getChildByName("Image_Property"):loadTexture(string.format("hero_property_%d.png", holeInfo["type"..i]))
				-- 数值
				parentNode:getChildByName("Panel_Property_"..i):getChildByName("Label_Init"):setString("+"..holeInfo["value"..i])
			end
		end
	else

	end
end

local margin_top 	= 0		-- 顶边距
local margin_left 	= 5		-- 左边距
local margin_cell	= 8		-- 元素边距

function BadgeWindow:showDiamondInfo(widget)
	self.mDetailWidget = GUIWidgetPool:createWidget("HeroEquipInfo")
	self.mRootNode:addChild(self.mDetailWidget, 100)

	self.mDetailWidget:getChildByName("Panel_Equip"):setVisible(false)
	self.mDetailWidget:getChildByName("Panel_DiamondsCom"):setVisible(true)
	self.mDetailWidget:getChildByName("Panel_Sources"):setVisible(false)
	self.mDetailWidget:getChildByName("Panel_EquipBtn"):setVisible(false)
	self.mDetailWidget:getChildByName("Panel_DiamondBtn"):setVisible(true)
	self.mDetailWidget:getChildByName("Panel_ShizhuangBtn"):setVisible(false)
	self.mDetailWidget:getChildByName("Panel_SourcesBtn"):setVisible(false)

	local infoWindow = self.mDetailWidget:getChildByName("Panel_EquipInfo")
	infoWindow:setVisible(true)

	-- 显示
	self.mDetailWidget:getChildByName("Panel_DiamondsCom"):setVisible(true)

	-- 宝石信息
	local diamondId = self.mData.diamondList[widget:getTag()]
	local diamondData = DB_Diamond.getDataById(diamondId)
	local diamondNameId = diamondData.Name
	local name = getDictionaryText(diamondNameId)
	-- 名称
	self.mDetailWidget:getChildByName("Label_Name"):setString(name)

	-- 图标
--	local icon = widget:clone()
	local icon = createDiamondWidget(diamondId)
	icon:setTouchEnabled(false)
	icon:setScale(1)
	self.mDetailWidget:getChildByName("Panel_EquipIcon"):addChild(icon)

	-- 描述
	local itemDescId = diamondData.description
	local DescText = getDictionaryText(itemDescId)

--	self.mDetailWidget:getChildByName("Label_Des"):setString(DescText)
	richTextCreate(self.mDetailWidget:getChildByName("Panel_Des"), DescText, true)

	local function requestRemoveDiamond()
		local packet = NetSystem.mNetManager:GetSPacket()
	    packet:SetType(PacketTyper._PTYPE_CS_BADGE_GEM_PUTOFF)
		packet:PushInt(widget:getTag())
		GUISystem:showLoading()
		packet:Send()
		-- 关闭界面
		self:closeInfo()
	end

	local count = globaldata:getItemOwnCount(diamondId)
	if count >= 4 then
		count = 4
	end

	-- 显示合成信息
	local function showComposeInfo()
		
		local function createDiamondFunc(id)
			local itemWidget = createDiamondWidget(id, 0)
			itemWidget:getChildByName("Image_Quality"):setVisible(true)
			itemWidget:getChildByName("Label_Count_Stroke"):setString("")
			return itemWidget
		end

		-- 显示目标宝石
		local itemData = DB_Diamond.getDataById(diamondId)
		local targetId = itemData.NextID

		if -1 ~= targetId then 
			local diamondWidget = createDiamondFunc(targetId)
			self.mDetailWidget:getChildByName("Panel_Diamond_Mid"):removeAllChildren()
			self.mDetailWidget:getChildByName("Panel_Diamond_Mid"):addChild(diamondWidget)
		end

		-- 显示材料宝石
		for i = 1, count do
			local diamondWidget = createDiamondFunc(diamondId)
			self.mDetailWidget:getChildByName(string.format("Panel_Diamond_%d",i)):addChild(diamondWidget)
		end

		-- 显示自身
		local diamondWidget = createDiamondFunc(diamondId)
		self.mDetailWidget:getChildByName("Panel_Diamond_Self"):addChild(diamondWidget)

	end
	showComposeInfo()
		
	local moveTime	= 0.2
	local opened    = -1

	-- 显示合成窗口
	local function showComposeWindow()
		-- 显示目标宝石
		local itemData = DB_Diamond.getDataById(diamondId)
		local targetId = itemData.NextID
		if -1 == targetId then
			MessageBox:showMessageBox1("当前宝石已经是最高级,无法再进行合成操作哟~")
			return
		end

		self:closeInfo()
		self.mDiamondComposeWindow:setVisible(true)

		local function createDiamondFunc(id)
			local itemWidget = createDiamondWidget(id, 0)
			itemWidget:getChildByName("Image_Quality"):setVisible(true)
			itemWidget:getChildByName("Label_Count_Stroke"):setString("")
			return itemWidget
		end

		local diamondWidget = createDiamondFunc(targetId)
		self.mDiamondComposeWindow:getChildByName("Panel_Diamond_Mid"):removeAllChildren()
		self.mDiamondComposeWindow:getChildByName("Panel_Diamond_Mid"):addChild(diamondWidget)
		diamondWidget:getChildByName("Image_Quality_Bg"):setVisible(false)
		diamondWidget:getChildByName("Image_Quality"):setVisible(false)
		-- 更换品质图片
		local diamondData = DB_Diamond.getDataById(targetId)
		local quality = diamondData.Quality
		self.mDiamondComposeWindow:getChildByName("Image_Dianond_Mid_Bg"):loadTexture(string.format("backpack_diamond_quality_%d.png", quality))
			
		local function updateDiamondCnt()
			local totalCnt = globaldata:getItemOwnCount(diamondId) + 1
			count = totalCnt
			if count >= 5 then
				count = 5
			end

			-- 清理
			for i = 1, 5 do
				self.mDiamondComposeWindow:getChildByName(string.format("Panel_Diamond_%d",i)):removeAllChildren()
			end

			-- 还原图
			for i = 1, 5 do
				self.mDiamondComposeWindow:getChildByName(string.format("Image_Dianond_%d_Bg",i)):loadTexture("backpack_diamond_com_itembg.png")
			end

			-- 显示材料宝石
			for i = 1, count do
				local diamondWidget = createDiamondFunc(diamondId)
				self.mDiamondComposeWindow:getChildByName(string.format("Panel_Diamond_%d",i)):addChild(diamondWidget)
				diamondWidget:getChildByName("Image_Quality_Bg"):setVisible(false)
				diamondWidget:getChildByName("Image_Quality"):setVisible(false)
				-- 更换品质图片
				local diamondData = DB_Diamond.getDataById(diamondId)
				local quality = diamondData.Quality
				self.mDiamondComposeWindow:getChildByName(string.format("Image_Dianond_%d_Bg",i)):loadTexture(string.format("backpack_diamond_quality_%d.png", quality))
			end

			-- 显示文字
			self.mDiamondComposeWindow:getChildByName("Label_Com_Most"):setString("合成"..tostring(math.floor(totalCnt/5)).."个")
			self.mDiamondComposeWindow:setVisible(true)
		end
		updateDiamondCnt()

		local function closeComposeWindow()

			if self.mOnDiamondComFunc then
				GUIEventManager:unregister("itemInfoChanged", self.mOnDiamondComFunc)
				self.mOnDiamondComFunc = nil
			end

			self.mDiamondComposeWindow:setVisible(false)
		end
		registerWidgetReleaseUpEvent(self.mDiamondComposeWindow:getChildByName("Button_Back"), closeComposeWindow)

		local function onRequestDoCompose(info)
			if self.mRootNode then
				if self.mItemDetailWindow then
					self.mItemDetailWindow:setVisible(false)
				end

				-- if self.mOnDiamondComFunc then
				-- 	GUIEventManager:unregister("itemInfoChanged", self.mOnDiamondComFunc)
				-- 	self.mOnDiamondComFunc = nil
				-- end
				
				-- 显示文字
				self.mDiamondComposeWindow:getChildByName("Label_Com_Most"):setString("合成"..tostring(math.floor(globaldata:getItemOwnCount(diamondId)/5)).."个")
			end

			local animNode = AnimManager:createAnimNode(8041)
			self.mDiamondComposeWindow:getChildByName("Panel_Animation_Top"):addChild(animNode:getRootNode(), 100)

			local function onAnimPlayEnd()
				-- 刷新出下一次的
			--	updateDiamondCnt()
				-- 销毁动画
				animNode:destroy()
				-- 关闭界面
				closeComposeWindow()
			end

			local function onAnimPlayBegin(evtName)
				if "happen" == evtName then
					for i = 1, 5 do
					--	local childTbl = self.mDiamondComposeWindow:getChildByName(string.format("Panel_Diamond_%d",i)):getChildren()
					--	if childTbl[1] then
					--		childTbl[1]:setVisible(false)
					--	end
						self.mDiamondComposeWindow:getChildByName(string.format("Panel_Diamond_%d",i)):removeAllChildren()
					end
				end
			end

			animNode:play("bagpack_diamond_com_top", false, onAnimPlayEnd, onAnimPlayBegin)
		end

		if self.mOnDiamondComFunc then
			GUIEventManager:unregister("itemInfoChanged", self.mOnDiamondComFunc)
			self.mOnDiamondComFunc = nil
		end

		GUIEventManager:registerEvent("itemInfoChanged", nil, onRequestDoCompose)
		self.mOnDiamondComFunc = onRequestDoCompose

		local function requestDoCompose(requestBtn)
			local count = globaldata:getItemOwnCount(diamondId) + 1
			if count < 5 then
				MessageBox:showMessageBox1("宝石数量不够哦亲~~")
				return 
			end
			local packet = NetSystem.mNetManager:GetSPacket()
	   	    packet:SetType(PacketTyper._PTYPE_CS_BADGE_GEM_COM)
		    packet:PushInt(widget:getTag())
		    packet:PushInt(1)
			packet:Send()
			GUISystem:showLoading()
			-- 关闭界面
			self:closeInfo()
		end
		registerWidgetReleaseUpEvent(self.mDiamondComposeWindow:getChildByName("Button_Com_1"), requestDoCompose)
		self.mDiamondComposeWindow:getChildByName("Button_Com_1"):setTag(1)
		registerWidgetReleaseUpEvent(self.mDiamondComposeWindow:getChildByName("Button_Com_Most"), requestDoCompose)
		self.mDiamondComposeWindow:getChildByName("Button_Com_Most"):setTag(2)
		self.mDiamondComposeWindow:getChildByName("Button_Com_Most"):setVisible(false)
	end
	registerWidgetReleaseUpEvent(self.mDetailWidget:getChildByName("Button_Hecheng"), showComposeWindow)


	local function requestExchangeDiamond()
		-- 装备列表窗口
	    local function act0End()
	   		opened = -1*opened
	   		infoWindow:getChildByName("Button_Exchange"):setTouchEnabled(true)
	    end

	    local function doAction0()
	   		if -1 == opened then
	   			infoWindow:getChildByName("Button_Exchange"):loadTextureNormal("public_btn2.png")
	   			infoWindow:getChildByName("Button_Exchange"):loadTexturePressed("public_btn1.png")
	   		else
	   			infoWindow:getChildByName("Button_Exchange"):loadTextureNormal("public_btn1.png")
	   			infoWindow:getChildByName("Button_Exchange"):loadTexturePressed("public_btn2.png")
	   		end

	    end
	    doAction0()

	    -- 装备信息窗口
--	    local function doAction1()
--	   		local act0 = cc.MoveBy:create(moveTime, cc.p(opened*220, 0))
--	   		infoWindow:runAction(act0)
--	   		infoWindow:getChildByName("Button_Exchange"):setTouchEnabled(false)
--	    end
--	    doAction1()

		self:openBag(widget)
		infoWindow:setVisible(true)
	end

	local deltaX = 1000

	local function doAdapter()
		registerWidgetReleaseUpEvent(self.mDetailWidget:getChildByName("Panel_DiamondBtn"):getChildByName("Button_Exchange"), requestExchangeDiamond)
		registerWidgetReleaseUpEvent(self.mDetailWidget:getChildByName("Panel_DiamondBtn"):getChildByName("Button_Unload"), requestRemoveDiamond)
		registerWidgetReleaseUpEvent(self.mDetailWidget, handler(self, self.closeInfo))	
	end
	nextTick(doAdapter)
end

-- 关闭宝石详情
function BadgeWindow:closeInfo(widget)
	if self.mDetailWidget then
		self.mDetailWidget:removeFromParent(true)
		self.mDetailWidget = nil
	end
end

-- 打开背包
function BadgeWindow:openBag(widget)
	if not self.mBagWindow then
		self.mBagWindow = GUIWidgetPool:createWidget("Badge_DiamondSelect")
		self.mRootNode:addChild(self.mBagWindow, 100)
	end

	self.mBagWindow:getChildByName("Label_None"):setVisible(false)

	registerWidgetReleaseUpEvent(self.mBagWindow, handler(self, self.closeBag))

	local holeInfo = DB_DiamondStar.getDataById(widget:getTag())
	local diamindList = globaldata.itemList[2]
	local newDiamondList = {}
	for i = 1, #diamindList do
		local diamondData = DB_Diamond.getDataById(diamindList[i]:getKeyValue("itemId"))
		local diamondType = diamondData.diamondType
		if holeInfo.Diamondtype1 == diamondType or holeInfo.Diamondtype2 == diamondType then
			table.insert(newDiamondList, i)
		end
	end

	local listView = self.mBagWindow:getChildByName("ScrollView_Diamond")
	listView:removeAllChildren()
	local listContainerSize = listView:getInnerContainerSize()
	local listContentSize = listView:getContentSize()
	local itemContentSize = cc.size(90, 90)
	local newContentHeight = nil
	local function doResize()
		local needGridCount = #newDiamondList
		local columnNums = math.ceil(needGridCount/4)
		newContentHeight = columnNums*(itemContentSize.height+margin_cell)
		if newContentHeight > listContentSize.height then
			listView:setInnerContainerSize(cc.size(listContainerSize.width, newContentHeight))
		else
			listView:setInnerContainerSize(cc.size(listContainerSize.width, listContentSize.height))
		end
	end
	doResize()

	local function requestDoEquipXiangqian(diamond)
		local packet = NetSystem.mNetManager:GetSPacket()
	    packet:SetType(PacketTyper._PTYPE_CS_BADGE_GEM_PUTON)
	  	packet:PushInt(widget:getTag()) -- 宝石位置
	    packet:PushInt(diamond:getTag()) -- 宝石id
	    packet:Send()
	    GUISystem:showLoading()
	    -- 关闭宝石窗口
	    self:closeBag()
	    -- 关闭宝石详情窗口
	    self:closeInfo()
	end

	for i = 1, #newDiamondList do
		local diamindWidget = createDiamondWidget(diamindList[newDiamondList[i]]:getKeyValue("itemId"), diamindList[newDiamondList[i]]:getKeyValue("itemNum"))
		listView:addChild(diamindWidget)
		registerWidgetReleaseUpEvent(diamindWidget, requestDoEquipXiangqian)
		local posX = ((i-1)%4)*(itemContentSize.width+margin_cell) + margin_left
		local posY = 0
		if newContentHeight > listContentSize.height then
			posY = listContentSize.height - math.ceil(i/4)*(itemContentSize.height+margin_cell) + newContentHeight - listContentSize.height
		else
			posY = listContentSize.height - math.ceil(i/4)*(itemContentSize.height+margin_cell)
		end
		diamindWidget:setPosition(cc.p(posX, posY))
	end

	if 0 == #newDiamondList then
		self.mBagWindow:getChildByName("Label_None"):setVisible(true)
		self.mBagWindow:getChildByName("Label_None"):setString("当前没有适合该装备的宝石")
	end
end

-- 关闭背包
function BadgeWindow:closeBag(widget)
	if self.mBagWindow then
		self.mBagWindow:removeFromParent(true)
		self.mBagWindow = nil
	end
end

-- 刷新翻页信息
function BadgeWindow:updatePageInfo()
	local needOpenHoleIndex = self.mData.curBadgeIndex + 1 -- 当前需要开启的洞序号
	local holeInfo = DB_DiamondStar.getDataById(needOpenHoleIndex)
	if holeInfo then
		self.mMaxPageIndex = holeInfo.SystemID
	else
		self.mMaxPageIndex = 5
	end

	-- 隐藏显示左滑按钮
	if self.mCurPageIndex <= 1 then
		self.mRootWidget:getChildByName("Panel_Turn_Left"):setVisible(false)
	else
		self.mRootWidget:getChildByName("Panel_Turn_Left"):setVisible(true)
	end
	-- 隐藏显示右滑按钮
	if self.mCurPageIndex >= self.mMaxPageIndex then
		self.mRootWidget:getChildByName("Panel_Turn_Right"):setVisible(false)
	else
		self.mRootWidget:getChildByName("Panel_Turn_Right"):setVisible(true)
	end

	-- 显示页号
	self.mRootWidget:getChildByName("Label_Num"):setString(self.mCurPageIndex.."/5")

	-- 显示页面
	for i = 1, 5 do
		if i == self.mCurPageIndex then
			self.mRootWidget:getChildByName("Panel_Table_"..i):setVisible(true)
		else
			self.mRootWidget:getChildByName("Panel_Table_"..i):setVisible(false)
		end
	end
	-- 刷新左右按钮
	BadgeNoticeInnerImpl:doUpdate_18002_18003()
end

-- 点击徽章
function BadgeWindow:onBadgeWidgetClicked(btnWidget)
	if self.mBadgeInfoWindow then
		if btnWidget:getTag() == self.mBadgeInfoWindow:getTag() then -- 点击同一个窗口
			self.mBadgeInfoWindow:removeFromParent(true)
			self.mBadgeInfoWindow = nil
			return
		else
			self.mBadgeInfoWindow:removeFromParent(true)
			self.mBadgeInfoWindow = nil
		end
	end

	self.mBadgeInfoWindow = GUIWidgetPool:createWidget("Badge_OneProperty")

	local panelWidget = self.mRootWidget:getChildByName("Panel_Badge_"..btnWidget:getTag())
	local curPos 	= cc.p(panelWidget:getPosition())
	local curSize 	= panelWidget:getContentSize()
	local wndSize   = self.mBadgeInfoWindow:getContentSize()
	local newX = curPos.x - (wndSize.width-curSize.width)/2
	local newY = curPos.y + curSize.height

	local maxTopValue = self.mRootWidget:getChildByName("Panel_Tables"):getContentSize().height
	
	-- 显示信息
	local bageInfo = DB_DiamondStar.getDataById(btnWidget:getTag())
	if 1 == bageInfo.ValueNum then
		self.mBadgeInfoWindow:setContentSize(cc.size(wndSize.width, 65))
		self.mBadgeInfoWindow:getChildByName("Image_Bg"):setContentSize(cc.size(wndSize.width, 65))
	elseif 2 == bageInfo.ValueNum then
		self.mBadgeInfoWindow:setContentSize(cc.size(wndSize.width, 100))
		self.mBadgeInfoWindow:getChildByName("Image_Bg"):setContentSize(cc.size(wndSize.width, 100))
	elseif 3 == bageInfo.ValueNum then
		self.mBadgeInfoWindow:setContentSize(cc.size(wndSize.width, 140))
		self.mBadgeInfoWindow:getChildByName("Image_Bg"):setContentSize(cc.size(wndSize.width, 140))
	end

	wndSize   = self.mBadgeInfoWindow:getContentSize()
	if newY + wndSize.height >= maxTopValue then -- 衣橱屏幕
		newY = curPos.y - wndSize.height
	end

	for i = 1, 3 do
		if -1 ~= bageInfo["type"..i] then
			-- 类型
			local imgWidget = self.mBadgeInfoWindow:getChildByName("Image_Property_"..i)
			imgWidget:setVisible(true)
			imgWidget:loadTexture(string.format("hero_property_%d.png", bageInfo["type"..i]))
			-- 值
			local labelWidget = self.mBadgeInfoWindow:getChildByName("Label_Property_"..i)
			labelWidget:setVisible(true)
			labelWidget:setString("+"..bageInfo["value"..i])
		end
	end

	self.mBadgeInfoWindow:setTag(btnWidget:getTag())
	panelWidget:getParent():addChild(self.mBadgeInfoWindow, 1000)
	self.mBadgeInfoWindow:setPosition(cc.p(newX, newY+15))
end

-- 请求点亮徽章
function BadgeWindow:requestOpenBadge(widget)
	local packet = NetSystem.mNetManager:GetSPacket()
	packet:SetType(PacketTyper._PTYPE_CS_BADGE_OPEN)
	packet:Send()
	GUISystem:showLoading()
end

-- 镶嵌宝石回包
function BadgeWindow:onRequestDoDiamondPutOn(msgPacket)
	local pos 	= msgPacket:GetInt()
	local id 	= msgPacket:GetInt()
	self.mData.diamondList[pos] = 	id -- 宝石位置和宝石ID
	self.mData.propCnt 			=	msgPacket:GetUShort()	-- 属性数量
	self.mData.propList 		=	{}
	for i = 1, self.mData.propCnt do
		self.mData.propList[i] = {}
		self.mData.propList[i].propType		=	msgPacket:GetChar()		-- 属性类型
		self.mData.propList[i].propValue	=	msgPacket:GetInt()		-- 属性值
	end
	-- 刷新界面
	self:updateBadgeInfo()

	local parentNode = self.mRootWidget:getChildByName("Panel_Diamond_"..pos)
	if 0 == id then -- 无宝石
		
	else -- 有宝石
		-- 特效
		if self.mDiamondStoneAnimList[pos] then
			self.mDiamondStoneAnimList[pos]:destroy()
		end
		local function xxx()
			self.mDiamondStoneAnimList[pos]:play("badge_diamond_set", true)
		end
		self.mDiamondStoneAnimList[pos] = AnimManager:createAnimNode(8071)
		parentNode:getChildByName("Panel_Animation"):addChild(self.mDiamondStoneAnimList[pos]:getRootNode(), 100)
		self.mDiamondStoneAnimList[pos]:play("badge_diamond_setting", false, xxx)
	end
	BadgeNoticeInnerImpl:doUpdate()
end

-- 点亮徽章回包
function BadgeWindow:onRequestOpenBadge(msgPacket)
	local badgeInfo = {}
	badgeInfo.starCnt 		= 	msgPacket:GetInt() 		-- 星星数量
	badgeInfo.curBadgeIndex	=	msgPacket:GetUShort()	-- 当前徽章数
	badgeInfo.diamondCnt	=	msgPacket:GetUShort()	-- 宝石数
	badgeInfo.diamondList	=	{}
	for i = 1, badgeInfo.diamondCnt do
		local diamondPos = msgPacket:GetInt()	-- 宝石位置
		local diamondId	 = msgPacket:GetInt()	-- 宝石ID
		badgeInfo.diamondList[diamondPos] = diamondId
	end
	badgeInfo.propCnt 		=	msgPacket:GetUShort()	-- 属性数量
	badgeInfo.propList 		=	{}
	for i = 1, badgeInfo.propCnt do
		badgeInfo.propList[i] = {}
		badgeInfo.propList[i].propType	=	msgPacket:GetChar()		-- 属性类型
		badgeInfo.propList[i].propValue	=	msgPacket:GetInt()		-- 属性值
	end
	self.mData    = badgeInfo
	-- 刷新界面
	self:updateBadgeInfo()
	GUISystem:hideLoading()

	-- 播放开启特效
	local index = badgeInfo.curBadgeIndex
	local parentNode = self.mRootWidget:getChildByName("Panel_Badge_"..index)
	self.mDiamondHoleAnimList[index]:destroy()
	self.mDiamondHoleAnimList[index] = nil
	local function xxx()
		self.mDiamondHoleAnimList[index]:play("badge_badge_lock", true)
	end	
	self.mDiamondHoleAnimList[index] = AnimManager:createAnimNode(8070)
	parentNode:getChildByName("Panel_Animation"):addChild(self.mDiamondHoleAnimList[index]:getRootNode(), 100)
	self.mDiamondHoleAnimList[index]:play("badge_badge_opening", false, xxx)


	local function doBadgeGuideOne_Stop()
		BadgeGuideOne:stop()
	end

	local function doBadgeGuideOne_Step3()
		BadgeGuideOne:step(3, nil, doBadgeGuideOne_Stop)
	end

	if BadgeGuideOne:canGuide() then
		local guideBtn = self.mRootWidget:getChildByName("Panel_Diamond_101")
		local size = guideBtn:getContentSize()
		local pos = guideBtn:getWorldPosition()
		local touchRect = cc.rect(pos.x, pos.y, size.width, size.height)
		BadgeGuideOne:step(2, touchRect, nil, doBadgeGuideOne_Step3)
	end

end

function BadgeWindow:onEventHandler(event, func)
	if event.mAction == Event.WINDOW_SHOW then
		self:Load(event)
		---------停止画主城镇界面
		EventSystem:PushEvent(Event.GUISYSTEM_DISABLEDRAW_HOMEWINDOW)
		self.mCallFuncAfterDestroy = func
	elseif event.mAction == Event.WINDOW_HIDE then
		self:Destroy()
		---------开启画主城镇界面
		EventSystem:PushEvent(Event.GUISYSTEM_EABLEDRAW_HOMEWINDOW)
		if self.mCallFuncAfterDestroy then
			self.mCallFuncAfterDestroy()
			self.mCallFuncAfterDestroy = nil
		end
	end
end

function BadgeWindow:Destroy()
	TextureSystem:UnLoadPlist("res/image/iconitem/icon_badge.plist")

	GUIEventManager:unregister("itemInfoChanged", self.refresh)

	self.mTopRoleInfoPanel:destroy()
	self.mTopRoleInfoPanel = nil

	self.mDiamondHoleAnimList = {}

	self.mDiamondStoneAnimList = {}

	self.mData = nil
	self.mBagWindow = nil
	self.mDetailWidget = nil
	self.mDiamondComposeWindow 		= 	nil

	self.mBadgeInfoWindow = nil

	self.mRootNode:removeFromParent(true)
	self.mRootNode = nil
	self.mRootWidget = nil

	TextureSystem:unloadPlist_iconskill()
	CommonAnimation.clearAllTextures()
end

return BadgeWindow