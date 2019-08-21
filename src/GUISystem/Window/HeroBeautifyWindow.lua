-- Name: 	HeroBeautifyWindow
-- Func：	英雄美化界面
-- Author:	WangShengdong
-- Data:	16-3-22

local HeroBeautifyWindow = 
{
	mName 					= "HeroBeautifyWindow",
	mRootNode				=	nil,	
	mRootWidget 			= 	nil,
	mScrollViewWidget		=	nil,
	mHeroIconList			=	{},								-- 英雄头像列表
	mHeroIdTbl 				=	{},								-- 英雄Id数组
	mSchedulerEntry			=	nil,
	mHeroAnimPanel			=	nil,	
	mTopRoleInfoPanel		=	nil,							-- 顶部人物信息面板
	mCurSelectedHeroIndex	=	nil,							-- 当前选择的英雄
	mPreSelectedHeroIndex	=	nil,							-- 前一次选择的英雄
	mHeroQualityBAnimNode 	=	nil,							-- 英雄特效
	mHeroIconListScrollingAnimNode	=	nil,	-- 滑动特效
	mHeroIconListSelectedAnimNode = nil,			
}

function HeroBeautifyWindow:Release()

end

function HeroBeautifyWindow:Load()
	cclog("=====HeroBeautifyWindow:Load=====begin")
	
	self.mRootNode = cc.Node:create()
	GUISystem:GetRootNode():addChild(self.mRootNode)
	
	self:InitLayout()

	-- 创建滑动控件
	self:createScrollViewWidget()

	-- 载入英雄
	self:loadAllHero()

	-- 初始化主角控件
	self:initLeaderWidget()
	
	-- 网络注册协议
	NetSystem.mNetManager:RegisterPacketHandler(PacketTyper._PTYPE_SC_CHANGE_COLOR_REQUEST_, handler(self,self.onChangeColor))
	NetSystem.mNetManager:RegisterPacketHandler(PacketTyper._PTYPE_SC_RESET_COLOR_REQUEST_, handler(self,self.onResetColor))

	cclog("=====HeroBeautifyWindow:Load=====end")
end

local bottomHeight = 288 -- 下边距
local topHeight = 288 -- 上边距
local marginCell = 10 -- 间隙
local cellHeight = 86 -- 格子大小

-- 创建ScrollView
function HeroBeautifyWindow:createScrollViewWidget()
	self.mScrollViewWidget = ccui.ScrollView:create()
    self.mScrollViewWidget:setTouchEnabled(true)
    self.mScrollViewWidget:setContentSize(cc.size(159, 662))
  
    local function getHeroCount()
    	local cnt = 0
    	for i = 1, maxHeroCount do -- 存在
			if globaldata:isHeroIdExist(i) then 
				cnt = cnt + 1
			end
		end
		return cnt
    end
    local heroCount = getHeroCount()
    local innerHeight = bottomHeight + topHeight + heroCount*cellHeight + (heroCount-1)*marginCell
    self.mScrollViewWidget:setInnerContainerSize(cc.size(159, innerHeight))

 	self.mRootWidget:getChildByName("Panel_Left"):addChild(self.mScrollViewWidget, 100)
end

-- 初始化主角控件
function HeroBeautifyWindow:initLeaderWidget()
	local function doSetLeader()

		local function onRequestDoSetLeader(msgPacket)
			globaldata.leaderHeroId = msgPacket:GetInt()
			self:updateLeaderInfo()
			-- 通知大厅换英雄
			FightSystem.mHallManager:OnTeamMemberChanged()
			GUISystem:hideLoading()
		end
		NetSystem.mNetManager:RegisterPacketHandler(PacketTyper._PTYPE_SC_RESET_LEADER_, onRequestDoSetLeader)

		local function requestDoSetLeader()
			local heroId = self.mHeroIdTbl[self.mCurSelectedHeroIndex]
			local heroObj = globaldata:findHeroById(heroId)
			if heroObj then
				local packet = NetSystem.mNetManager:GetSPacket()
				packet:SetType(PacketTyper._PTYPE_CS_RESET_LEADER_)
				packet:PushInt(heroId)
				packet:Send()
				GUISystem:showLoading()
			end
		end
		requestDoSetLeader()
	end
	registerWidgetReleaseUpEvent(self.mRootWidget:getChildByName("Image_Leader"), doSetLeader)
end

-- 载入英雄
function HeroBeautifyWindow:loadAllHero()

	if not self.mHeroIconListScrollingAnimNode then
		self.mHeroIconListScrollingAnimNode = AnimManager:createAnimNode(8068)
		self.mRootWidget:getChildByName("Panel_Middle_Chosen_Animation"):addChild(self.mHeroIconListScrollingAnimNode:getRootNode(), 100)
		self.mHeroIconListScrollingAnimNode:play("herolist_cur_3", true)
		self.mHeroIconListScrollingAnimNode:setVisible(false)
	end

	if not self.mHeroIconListSelectedAnimNode then
		self.mHeroIconListSelectedAnimNode = AnimManager:createAnimNode(8068)
		self.mRootWidget:getChildByName("Panel_Middle_Chosen_Animation"):addChild(self.mHeroIconListSelectedAnimNode:getRootNode(), 100)
		self.mHeroIconListSelectedAnimNode:setVisible(false)
	end

	-- 初始化定时器
	if not self.mSchedulerEntry then
		local scheduler = cc.Director:getInstance():getScheduler()
		self.mSchedulerEntry = scheduler:scheduleScriptFunc(handler(self, self.tick), 0, false)
	end
	-- 英雄ID表
	self.mHeroIdTbl = {}
	for i = 1, maxHeroCount do -- 存在
		if globaldata:isHeroIdExist(i) then 
			table.insert(self.mHeroIdTbl, i)
		end
	end

	-- 根据战力排序
	local function sortFunc(id1, id2)
		local heroObj1 = globaldata:findHeroById(id1)
		local heroObj2 = globaldata:findHeroById(id2)
		return heroObj1.combat > heroObj2.combat
	end
	table.sort(self.mHeroIdTbl, sortFunc)

	local innerHeight = self.mScrollViewWidget:getInnerContainerSize().height
	print("滑动列表总高度:", innerHeight)

	for i = 1, #self.mHeroIdTbl do
		local heroId = self.mHeroIdTbl[i]
		local heroObj = globaldata:findHeroById(heroId)
		
		self.mHeroIconList[i] = GUIWidgetPool:createWidget("Hero_ListCell")
	--	self.mRootWidget:getChildByName("ScrollView_HeroList"):getChildByName("Panel_Hero_"..tostring(i)):addChild(self.mHeroIconList[i])
		self.mScrollViewWidget:addChild(self.mHeroIconList[i])
		
		self.mHeroIconList[i]:setTag(i)
		registerWidgetReleaseUpEvent(self.mHeroIconList[i], handler(self, self.onHeroIconClicked))

		-- 职业
		local heroData = DB_HeroConfig.getDataById(heroId)
		self.mHeroIconList[i]:getChildByName("Image_Group"):loadTexture("hero_herolist_group"..heroData.HeroGroup..".png", 1)

		if 1 == heroData.QualityB then
				self.mHeroIconList[i]:getChildByName("Image_SuperHero"):loadTexture("hero_herolist_super_1.png", 1)
			--	local animNode = AnimManager:createAnimNode(8065)
			--	self.mHeroIconList[i]:getChildByName("Panel_SuperHero_Animation"):addChild(animNode:getRootNode(), 100)
			--	animNode:play("hero_list_superhero", true)
		else
			self.mHeroIconList[i]:getChildByName("Image_SuperHero"):loadTexture("hero_herolist_super_0.png", 1)
		end

		local curPos = cc.p(0, innerHeight - topHeight - (i-1)*marginCell - i*cellHeight)
		self.mHeroIconList[i]:setPosition(curPos)
		print("英雄:", i, "位置:", curPos.x, curPos.y)
		-- 载入头像
		self.mHeroIconList[i]:getChildByName("Image_HeroList_HeroIcon"):loadTexture("hero_herolist_hero_"..heroId..".png", 1)

		if globaldata:findHeroById(heroId) then -- 如果存在
			self.mHeroIconList[i]:getChildByName("Panel_HeroLevel_1"):setVisible(false)
			self.mHeroIconList[i]:getChildByName("Panel_HeroLevel_2"):setVisible(false)
			local l1 = math.floor(heroObj.level/10)
			local l2 = math.fmod(heroObj.level, 10)
			if 0 == l1 then
				self.mHeroIconList[i]:getChildByName("Panel_HeroLevel_1"):setVisible(true)
				self.mHeroIconList[i]:getChildByName("Panel_HeroLevel_1"):getChildByName("Image_level"):loadTexture("hero_level_"..tostring(l2)..".png", 1)
			else 
				self.mHeroIconList[i]:getChildByName("Panel_HeroLevel_2"):setVisible(true)
				self.mHeroIconList[i]:getChildByName("Panel_HeroLevel_2"):getChildByName("Image_level_Left"):loadTexture("hero_level_"..tostring(l1)..".png", 1)
				self.mHeroIconList[i]:getChildByName("Panel_HeroLevel_2"):getChildByName("Image_level_Right"):loadTexture("hero_level_"..tostring(l2)..".png", 1)
			end

			-- 星星
			local starLevel = heroObj.quality
			if 0 == starLevel then

			elseif starLevel >= 1 and starLevel <= 6 then
				for j = 1, starLevel do 
					local starWidget = self.mHeroIconList[i]:getChildByName("Panel_Star"):getChildByName("Image_Star_"..tostring(j))
					starWidget:loadTexture("hero_herolist_star1.png", 1)
					starWidget:setVisible(true)
				end
			elseif starLevel >= 7 and starLevel <= 12 then
				for j = 1, 6 do
					local starWidget = self.mHeroIconList[i]:getChildByName("Panel_Star"):getChildByName("Image_Star_"..tostring(j))
					starWidget:setVisible(true)
					starWidget:loadTexture("hero_herolist_star1.png", 1)
				end

				for j = 1, starLevel - 6 do
					local starWidget = self.mHeroIconList[i]:getChildByName("Panel_Star"):getChildByName("Image_Star_"..tostring(j))
					starWidget:setVisible(true)
					starWidget:loadTexture("hero_herolist_star2.png", 1)
				end
			end

			-- 品阶
			self.mHeroIconList[i]:getChildByName("Image_bg"):loadTexture(string.format("hero_herolist_cell_bg_%d.png", heroObj.advanceLevel), 1)

		else -- 如果不存在
			ShaderManager:blackwhiteFilter(self.mHeroIconList[i]:getChildByName("Image_HeroList_HeroIcon"):getVirtualRenderer())
		end
	end

	local function onAutoScrollStartFunc()
		GUISystem:disableUserInput()
	end
	self.mScrollViewWidget:registerAutoScrollStartFunc(onAutoScrollStartFunc)

	local function onAutoScrollStopFunc()
		self.mXilianEquipWidget = nil
		self.mXiangqianEquipWidget = nil
		-- 修正ScrollView位置
    	self:fixScrollViewPos()
    end
	self.mScrollViewWidget:registerAutoScrollStopFunc(onAutoScrollStopFunc)

	local function onScrollViewEvent(sender, evenType)
		self.mXilianEquipWidget = nil
		self.mXiangqianEquipWidget = nil
		if evenType == ccui.ScrollviewEventType.scrolling then
			self.mHeroIconListScrollingAnimNode:setVisible(true)
			self.mHeroIconListSelectedAnimNode:setVisible(false)
		elseif evenType == ccui.ScrollviewEventType.scrollToBottom then  
			self.mCurSelectedHeroIndex = #self.mHeroIdTbl
			-- 显示英雄信息
			self:updateHeroInfo()
			GUISystem:enableUserInput()
			self.mHeroIconListScrollingAnimNode:setVisible(false)

			local function yyy()
				self.mHeroIconListSelectedAnimNode:play("herolist_cur_2", true)
			end
			self.mHeroIconListSelectedAnimNode:stop()
			self.mHeroIconListSelectedAnimNode:play("herolist_cur_1", false, yyy)
			self.mHeroIconListSelectedAnimNode:setVisible(true)

        elseif evenType ==  ccui.ScrollviewEventType.scrollToTop then
            self.mCurSelectedHeroIndex = 1
			-- 显示英雄信息
			self:updateHeroInfo()
			GUISystem:enableUserInput()
			self.mHeroIconListScrollingAnimNode:setVisible(false)

			local function yyy()
				self.mHeroIconListSelectedAnimNode:play("herolist_cur_2", true)
			end
			self.mHeroIconListSelectedAnimNode:stop()
			self.mHeroIconListSelectedAnimNode:play("herolist_cur_1", false, yyy)
			self.mHeroIconListSelectedAnimNode:setVisible(true)
        end
	end
	self.mScrollViewWidget:addEventListener(onScrollViewEvent)

	-- 修正ScrollView位置
	self:fixScrollViewPos()
	-- 更新头像透明度
	self:updateHeroIconOpacity()
end

-- 更新所测滑条
function HeroBeautifyWindow:updateHeroIconTbl()
	local innerHeight = self.mScrollViewWidget:getInnerContainerSize().height
--	print("滑动列表总高度:", innerHeight)

	for i = 1, #self.mHeroIdTbl do
		local heroId = self.mHeroIdTbl[i]
--		print("英雄id:", i, heroId)

		-- 载入头像
		local heroData = DB_HeroConfig.getDataById(heroId)

		if not self.mHeroIconList[i] then
			self.mHeroIconList[i] = GUIWidgetPool:createWidget("Hero_ListCell")
			self.mScrollViewWidget:addChild(self.mHeroIconList[i])

			local curPos = cc.p(0, innerHeight - topHeight - (i-1)*marginCell - i*cellHeight)
			self.mHeroIconList[i]:setPosition(curPos)
--			print("英雄:", i, "位置:", curPos.x, curPos.y)

			self.mHeroIconList[i]:setTag(i)
			registerWidgetReleaseUpEvent(self.mHeroIconList[i], handler(self, self.onHeroIconClicked))

			-- 职业
			self.mHeroIconList[i]:getChildByName("Image_Group"):loadTexture("heroicon_group"..heroData.HeroGroup..".png")
		end

		
		local imgId = heroData.IconID
		local imgName = DB_ResourceList.getDataById(imgId).Res_path1
		self.mHeroIconList[i]:getChildByName("Image_HeroList_HeroIcon"):loadTexture(imgName,1)
		-- 级别

		local heroObj = globaldata:findHeroById(heroId)
		if heroObj then -- 如果存在
			self.mHeroIconList[i]:getChildByName("Panel_HeroLevel_1"):setVisible(false)
			self.mHeroIconList[i]:getChildByName("Panel_HeroLevel_2"):setVisible(false)
			
			local l1 = math.floor(heroObj.level/10)
			local l2 = math.fmod(heroObj.level, 10)
			if 0 == l1 then
				self.mHeroIconList[i]:getChildByName("Panel_HeroLevel_1"):setVisible(true)
				self.mHeroIconList[i]:getChildByName("Panel_HeroLevel_1"):getChildByName("Image_level"):loadTexture("hero_level_"..tostring(l2)..".png")
			else 
				self.mHeroIconList[i]:getChildByName("Panel_HeroLevel_2"):setVisible(true)
				self.mHeroIconList[i]:getChildByName("Panel_HeroLevel_2"):getChildByName("Image_level_Left"):loadTexture("hero_level_"..tostring(l1)..".png")
				self.mHeroIconList[i]:getChildByName("Panel_HeroLevel_2"):getChildByName("Image_level_Right"):loadTexture("hero_level_"..tostring(l2)..".png")
			end

			ShaderManager:ResumeColor(self.mHeroIconList[i]:getChildByName("Image_HeroList_HeroIcon"):getVirtualRenderer())

			-- 星星
			local starLevel = heroObj.quality
			if 0 == starLevel then

			elseif starLevel >= 1 and starLevel <= 6 then
				for j = 1, starLevel do 
					local starWidget = self.mHeroIconList[i]:getChildByName("Panel_Star"):getChildByName("Image_Star_"..tostring(j))
					starWidget:loadTexture("public_hero_star1_small.png")
					starWidget:setVisible(true)
				end
			elseif starLevel >= 7 and starLevel <= 12 then
				for j = 1, 6 do
					local starWidget = self.mHeroIconList[i]:getChildByName("Panel_Star"):getChildByName("Image_Star_"..tostring(j))
					starWidget:setVisible(true)
					starWidget:loadTexture("public_hero_star1_small.png")
				end

				for j = 1, starLevel - 6 do
					local starWidget = self.mHeroIconList[i]:getChildByName("Panel_Star"):getChildByName("Image_Star_"..tostring(j))
					starWidget:setVisible(true)
					starWidget:loadTexture("public_hero_star2_small.png")
				end
			end

			-- 品阶
			self.mHeroIconList[i]:getChildByName("Image_bg"):loadTexture(string.format("hero_herolist_cell_bg_%d.png", heroObj.advanceLevel))

		else -- 如果不存在
			ShaderManager:Disabled(self.mHeroIconList[i]:getChildByName("Image_HeroList_HeroIcon"):getVirtualRenderer())
			self.mHeroIconList[i]:getChildByName("Panel_HeroLevel_1"):setVisible(false)
			self.mHeroIconList[i]:getChildByName("Panel_HeroLevel_2"):setVisible(false)

			-- 品阶
			self.mHeroIconList[i]:getChildByName("Image_bg"):loadTexture("hero_herolist_cell_bg_0.png")
		end
	end
end

-- 显示主角信息
function HeroBeautifyWindow:updateLeaderInfo()
	local heroId = self.mHeroIdTbl[self.mCurSelectedHeroIndex]
	-- 主角
	if heroId == globaldata.leaderHeroId then -- 是主角
		self.mRootWidget:getChildByName("Image_IfLeader"):setVisible(true)
		self.mRootWidget:getChildByName("Image_Leader"):setTouchEnabled(false)
	else
		self.mRootWidget:getChildByName("Image_IfLeader"):setVisible(false)
		self.mRootWidget:getChildByName("Image_Leader"):setTouchEnabled(true)
	end

	-- ICON主角标志
	for i = 1, #self.mHeroIdTbl do
		if globaldata.leaderHeroId == self.mHeroIdTbl[i] then -- 是主角
			self.mHeroIconList[i]:getChildByName("Image_LeaderMark"):setVisible(true)
		else -- 不是主角
			self.mHeroIconList[i]:getChildByName("Image_LeaderMark"):setVisible(false)
		end
	end
end

-- 响应头像点击
function HeroBeautifyWindow:onHeroIconClicked(widget)
	if 1 == #self.mHeroIdTbl then
		return
	end

	self.mCurSelectedHeroIndex = widget:getTag()
	local tm = 0.3
	-- 自动滑动
	local curHeight = self.mScrollViewWidget:getInnerContainerSize().height - self.mRootWidget:getChildByName("ScrollView_HeroList"):getContentSize().height
	local deltaY = self.mHeroIconList[1]:getPositionY() - self.mHeroIconList[self.mCurSelectedHeroIndex]:getPositionY()
	self.mScrollViewWidget:scrollToPercentVertical(100 - (curHeight-deltaY)/curHeight*100, tm, false)

	local function onScrollEnd()
		-- 更新英雄信息
		self:updateHeroInfo()
		GUISystem:enableUserInput()

		local function xxx()
			if self.mHeroIconListScrollingAnimNode then
				self.mHeroIconListScrollingAnimNode:setVisible(false)

				local function yyy()
					self.mHeroIconListSelectedAnimNode:play("herolist_cur_2", true)
				end
				self.mHeroIconListSelectedAnimNode:stop()
				self.mHeroIconListSelectedAnimNode:play("herolist_cur_1", false, yyy)
				self.mHeroIconListSelectedAnimNode:setVisible(true)
			end
		end
		nextTick(xxx)
	end
	self.mScrollViewWidget:stopAllActions()
	local act0 = cc.DelayTime:create(tm)
	local act1 = cc.CallFunc:create(onScrollEnd)
	self.mScrollViewWidget:runAction(cc.Sequence:create(act0, act1))
	GUISystem:disableUserInput()
end

-- 更新英雄信息
function HeroBeautifyWindow:updateHeroInfo()
	if self.mPreSelectedHeroIndex == self.mCurSelectedHeroIndex then
		return
	end

	-- 显示主角信息
	self:updateLeaderInfo()

	-- 显示英雄动画
	self:updateHeroAnim()

	-- 显示英雄姓名
	self:updateHeroName()

	self.mPreSelectedHeroIndex = self.mCurSelectedHeroIndex
end

-- 显示英雄动画
function HeroBeautifyWindow:updateHeroAnim()
	-- 删除上一个动画
	if self.mHeroAnimNode then
		SpineDataCacheManager:collectFightSpineByAtlas(self.mHeroAnimNode)
		self.mHeroAnimNode = nil
	end
	-- 当前英雄的ID
	local heroId = self.mHeroIdTbl[self.mCurSelectedHeroIndex]
	self.mHeroAnimNode = SpineDataCacheManager:getSimpleSpineByHeroID(heroId, self.mHeroAnimPanel)
	self.mHeroAnimNode:setSkeletonRenderType(cc.RENDER_TYPE_HERO)
	self.mHeroAnimNode:setAnimation(0,"stand",true)

	-- 显示原画大图
	local heroData = DB_HeroConfig.getDataById(heroId)
	self.mHeroAnimNode:setScale(heroData.UIResouceZoom)

	if not self.mHeroQualityBAnimNode then
	--	self.mHeroQualityBAnimNode = AnimManager:createAnimNode(8064)
	--	self.mRootWidget:getChildByName("Panel_Hero"):getChildByName("Panel_SuperHero_Animation"):addChild(self.mHeroQualityBAnimNode:getRootNode(), 100)
	--	self.mHeroQualityBAnimNode:play("hero_halo_superhero", true)
	end

	if 1 == heroData.QualityB then
	--	self.mHeroQualityBAnimNode:setVisible(true)
	else
	--	self.mHeroQualityBAnimNode:setVisible(false)
	end

	self:showdyeRight(heroId)

end

-- 显示英雄姓名
function HeroBeautifyWindow:updateHeroName()
	local heroId    	= self.mHeroIdTbl[self.mCurSelectedHeroIndex]
	local heroData 		= DB_HeroConfig.getDataById(heroId)
	local heroNameId 	= heroData.Name
	local lblWidget 	= self.mRootWidget:getChildByName("Label_HeroName_Stroke_19_48_176")
	lblWidget:setString(getDictionaryText(heroNameId))
end

-- 染色窗口回复
function HeroBeautifyWindow:onChangeColor(msgPacket)
	CommonAnimation.PlayEffectId(5010)
	local function playStarFinish(selfAni)
		if self.star then
			self.star:destroy()
			self.star = nil
		end
	end
	if self.star then
		self.star:play("colorchange_light",false,playStarFinish)
	else
		self.star = AnimManager:createAnimNode(8055)
		self.mRootWidget:getChildByName("Panel_LightAnimation"):addChild(self.star:getRootNode(), 100)
		self.star:play("colorchange_light",false,playStarFinish)
	end
	local heroId = msgPacket:GetInt()
	local Colordata = {}
	Colordata.partType =  msgPacket:GetChar()
	Colordata.colorType = msgPacket:GetChar()
	if Colordata.colorType > 0 then
		Colordata.colorArrCount = msgPacket:GetUShort()
		Colordata.colorArr = {}
		for i=1,Colordata.colorArrCount do
			Colordata.colorArr[i] = msgPacket:GetUShort()
		end
	end
	local changeDataList = globaldata:getHeroInfoByBattleIndex(heroId, "changecolor")
	if not changeDataList then return end
	changeDataList[Colordata.partType] = Colordata
	ShaderManager:changeColorspineByData(self.mHeroAnimNode,Colordata,heroId)
	if heroId == globaldata.leaderHeroId then
		FightSystem.mHallManager:OnMyRoleChangedColor(Colordata)
	end
	GUISystem:hideLoading()
end

-- 还原窗口
function HeroBeautifyWindow:onResetColor(msgPacket)
	local heroId = msgPacket:GetInt()
	local partType = msgPacket:GetChar()
	local changeDataList = globaldata:getHeroInfoByBattleIndex(heroId, "changecolor")
	if not changeDataList then return end
	changeDataList[partType] = nil
	if #self.mHerodyeList == 0 or self.mHerodyeList[partType].Dye_part == 0 then return end
	local data = self.mHerodyeList[partType]
	ShaderManager:ResumeColor_spine(self.mHeroAnimNode,data.Dye_pic)
	if heroId == globaldata.leaderHeroId then
		FightSystem.mHallManager:OnMyRoleResetColor(data.Dye_pic)
	end
	GUISystem:hideLoading()
end

-- 染色窗口
function HeroBeautifyWindow:showdyeRight(heroId)
	local _infoDB = DB_HeroConfig.getDataById(heroId)
	self.mHerodyeList = {}
	self.mCurdyeIndex = nil
	self.mLastBack = nil
	self.mLastChange = nil
	local function pantouch( widget )
		local tag = widget:getTag()
		if #self.mHerodyeList == 0 or self.mHerodyeList[tag].Dye_part == 0 then return end
		if not self.mCurdyeIndex then
			self.mCurdyeIndex = widget:getTag()
			self.mLastBack = widget:getChildByName("Button_Back")
			self.mLastChange = widget:getChildByName("Button_Change")
			self.mLastBack:setVisible(true)
			self.mLastChange:setVisible(true)
			self.mCurdyeIndex = tag
		elseif self.mCurdyeIndex and self.mCurdyeIndex ~= widget:getTag() then
			self.mLastBack:setVisible(false)
			self.mLastChange:setVisible(false)
			self.mLastBack = widget:getChildByName("Button_Back")
			self.mLastChange = widget:getChildByName("Button_Change")
			self.mLastBack:setVisible(true)
			self.mLastChange:setVisible(true)
			self.mCurdyeIndex = tag
		end
	end

	local function panBack( widget )
		local tag = widget:getTag()
		if #self.mHerodyeList == 0 or self.mHerodyeList[tag].Dye_part == 0 then return end
		local packet = NetSystem.mNetManager:GetSPacket()
	    packet:SetType(PacketTyper._PTYPE_CS_RESET_COLOR_REQUEST_)
	    packet:PushInt(self.mHeroIdTbl[self.mCurSelectedHeroIndex])
	    packet:PushChar(tag)
		packet:Send()
		GUISystem:showLoading()
	end

	local function panChange( widget )
		local tag = widget:getTag()
		if #self.mHerodyeList == 0 or self.mHerodyeList[tag].Dye_part == 0 then return end
		local packet = NetSystem.mNetManager:GetSPacket()
	    packet:SetType(PacketTyper._PTYPE_CS_CHANGE_COLOR_REQUEST_)
	    packet:PushInt(self.mHeroIdTbl[self.mCurSelectedHeroIndex])
	    packet:PushChar(tag)
		packet:Send()
		GUISystem:showLoading()


		--[[

		local data = self.mHerodyeList[tag]
		if data.Dye_type == 1 then
			math.randomseed(os.clock()*1000*os.time())
			local saturation = math.random(50,500)
			saturation = saturation /100
			local hue = math.random(0,360)
			ShaderManager:changeHue_spine(self.mHeroAnimNode, hue, saturation, data.Dye_pic)

		else
			math.randomseed(os.clock()*1000*os.time())

			local num = math.random(0,255)
			local colorlist = {}
			local colorlist1 = {num,0,255}
			for i=1,3 do
				local random1= math.random(1,#colorlist1)
				local v = table.remove(colorlist1,random1)
				v = v/255
				local random2= math.random(1,2)
				if random2 == 1 then
					table.insert(colorlist,1,v)
				else
					table.insert(colorlist,v)
				end
			end
			local color = cc.c3b(colorlist[1],colorlist[2],colorlist[3])
			--math.randomseed(os.time())
			local saturation = math.random(250,750)
			saturation = saturation /1000
			--math.randomseed(os.time())
			local light = math.random(500,1000) - 500
			light = light/1000
			debugLog("TIME==="..os.time().."=COLOR==============R="..colorlist[1] .."G=" ..colorlist[2] .."B=" ..colorlist[3] .."=saturation="..saturation.."==light=="..light)
			ShaderManager:changeHueWithShading_spine(self.mHeroAnimNode, color, saturation, light, data.Dye_pic)
		end
		]]
	end

	for i=1,4 do
		local part = _infoDB[string.format("Dye%d_part",i)]
		local Data = {}
		Data.Dye_part = part
		Data.Dye_type = _infoDB[string.format("Dye%d_type",i)]
		Data.Dye_pic = _infoDB[string.format("Dye%d_pic",i)]
		self.mHerodyeList[i] = Data

		local widget = self.mRightPanel:getChildByName(string.format("Panel_Position_chosen_%d",i))
		widget:getChildByName("Label_Name"):setVisible(false)
		widget:getChildByName("Image_None"):setVisible(false)
		if Data.Dye_part ~= 0 then
			widget:getChildByName("Label_Name"):setString(getDictionaryText(Data.Dye_part))
			widget:getChildByName("Label_Name"):setVisible(true)
		else
			widget:getChildByName("Image_None"):setVisible(true)
		end
		registerWidgetReleaseUpEvent(widget,pantouch)
		widget:setTag(i)
		registerWidgetReleaseUpEvent(widget:getChildByName("Button_Back"),panBack)
		widget:getChildByName("Button_Back"):setTag(i)
		widget:getChildByName("Button_Back"):setVisible(false)
		registerWidgetReleaseUpEvent(widget:getChildByName("Button_Change"),panChange)
		widget:getChildByName("Button_Change"):setTag(i)
		widget:getChildByName("Button_Change"):setVisible(false)
		local changeData = globaldata:getHeroInfoByBattleIndex(heroId, "changecolor",i)
		ShaderManager:changeColorspineByData(self.mHeroAnimNode,changeData,heroId)
	end
end

-- 窗口更新
function HeroBeautifyWindow:tick()
	-- 更新头像透明度
	self:updateHeroIconOpacity()
end

-- 更新头像透明度
function HeroBeautifyWindow:updateHeroIconOpacity()
	local curPos = self.mRootWidget:getChildByName("Panel_Hero_Middle"):getWorldPosition()
	-- 十八个头像
	for i = 1, #self.mHeroIdTbl do
		local cellPos = self.mHeroIconList[i]:getWorldPosition()
		local distence = math.abs(cellPos.y - curPos.y)
		if distence <= 150 then
			self.mHeroIconList[i]:setOpacity(255)
		elseif distence > 150 and distence <= 275 then
			self.mHeroIconList[i]:setOpacity(255 - (distence-150)*155/125)
		elseif distence > 275 then
			self.mHeroIconList[i]:setOpacity(100)
		end
	end
	-- 六个地板
	for i = 1, 6 do
		local widget = self.mRootWidget:getChildByName("Panel_Empty_"..tostring(i))
		local cellPos = widget:getWorldPosition()
		local distence = math.abs(cellPos.y - curPos.y)
		if distence <= 150 then
			widget:setOpacity(255)
		elseif distence > 150 and distence <= 275 then
			widget:setOpacity(255 - (distence-150)*155/125)
		elseif distence > 275 then
			widget:setOpacity(100)
		end
	end
end

-- 修正ScrollView位置
function HeroBeautifyWindow:fixScrollViewPos()
	self.mCurSelectedHeroIndex = 1
	local nearestIcon = self.mHeroIconList[self.mCurSelectedHeroIndex]
	local tagWidget = self.mRootWidget:getChildByName("Panel_Hero_Middle")
	for i = 1, #self.mHeroIdTbl do
		local oldDis = math.abs(nearestIcon:getWorldPosition().y - tagWidget:getWorldPosition().y)
		local newDis = math.abs(self.mHeroIconList[i]:getWorldPosition().y - tagWidget:getWorldPosition().y)
		if newDis < oldDis then
			nearestIcon = self.mHeroIconList[i]
			self.mCurSelectedHeroIndex = i
		end
	end

	local function onActEnd()
		self.mXilianEquipWidget = nil
		self.mXiangqianEquipWidget = nil
		-- 显示英雄装备信息
		self:updateHeroInfo()
		local function xxx()
			-- 允许点击
			GUISystem:enableUserInput()
			if self.mHeroIconListScrollingAnimNode then
				self.mHeroIconListScrollingAnimNode:setVisible(false)
			end

			local function yyy()
				if self.mHeroIconListSelectedAnimNode then
					self.mHeroIconListSelectedAnimNode:play("herolist_cur_2", true)
				end
			end
			if self.mHeroIconListSelectedAnimNode then
				self.mHeroIconListSelectedAnimNode:stop()
				self.mHeroIconListSelectedAnimNode:play("herolist_cur_1", false, yyy)
				self.mHeroIconListSelectedAnimNode:setVisible(true)
			end
		end
		nextTick(xxx)
	end

	local moveTime = 0.2
	-- 自动滑动
	local curHeight = self.mScrollViewWidget:getInnerContainerSize().height - self.mScrollViewWidget:getContentSize().height
	local deltaY = self.mHeroIconList[1]:getPositionY() - self.mHeroIconList[self.mCurSelectedHeroIndex]:getPositionY()
	if #self.mHeroIdTbl > 1 then
		self.mScrollViewWidget:scrollToPercentVertical(100 - (curHeight-deltaY)/curHeight*100, moveTime, false)
	end
	
	local act0 = cc.DelayTime:create(moveTime)
	local act1 = cc.CallFunc:create(onActEnd)
	self.mRootWidget:runAction(cc.Sequence:create(act0, act1))
	-- 禁止点击
	GUISystem:disableUserInput()
end

function HeroBeautifyWindow:InitLayout()
	self.mRootWidget = GUIWidgetPool:createWidget("ColorChange")
	self.mRootNode:addChild(self.mRootWidget)

	local function closeWindow()	
		EventSystem:PushEvent(Event.GUISYSTEM_HIDE_HEROBEAUTIFYWINDOW)
	end

	self.mTopRoleInfoPanel = TopRoleInfoPanel:new()
	local topInfoPanel = self.mTopRoleInfoPanel:init(self.mRootNode,ROLE_TITLE_TYPE.TITLE_COLORCHANGE, closeWindow)

	self.mHeroAnimPanel = self.mRootWidget:getChildByName("Panel_HeroAnim")

	self:InitRightPart()

	-- 左面滑动条适配
	local function doAdapter1()
		local leftPanel = self.mRootWidget:getChildByName("Panel_Left")
		leftPanel:setPositionX(getGoldFightPosition_LD().x)
	end
	doAdapter1()
end

function HeroBeautifyWindow:InitRightPart( ... )
	self.mRightPanel = self.mRootWidget:getChildByName("Panel_Right")
	self.mRightPanel:setPositionX(getGoldFightPosition_RD().x - self.mRightPanel:getContentSize().width)
	--self.mRightPanel:setPositionY(getGoldFightPosition_Middle().y - self.mRightPanel:getContentSize().height/2)

end

function HeroBeautifyWindow:Destroy()

	NetSystem.mNetManager:UnregisterPacketHandler(PacketTyper._PTYPE_SC_CHANGE_COLOR_REQUEST_)
	NetSystem.mNetManager:UnregisterPacketHandler(PacketTyper._PTYPE_SC_RESET_COLOR_REQUEST_)

	if self.mSchedulerEntry then
		local scheduler = cc.Director:getInstance():getScheduler()
		scheduler:unscheduleScriptEntry(self.mSchedulerEntry)
		self.mSchedulerEntry = nil
	end
	
	if self.mHeroAnimNode then -- 删除动画节点
		SpineDataCacheManager:collectFightSpineByAtlas(self.mHeroAnimNode)
		self.mHeroAnimNode = nil
	end

	if self.mHeroQualityBAnimNode then
		self.mHeroQualityBAnimNode:destroy()
		self.mHeroQualityBAnimNode = nil
	end

	if self.mHeroIconListScrollingAnimNode then
		self.mHeroIconListScrollingAnimNode:destroy()
		self.mHeroIconListScrollingAnimNode = nil
	end

	if self.mHeroIconListSelectedAnimNode then
		self.mHeroIconListSelectedAnimNode:destroy()
		self.mHeroIconListSelectedAnimNode = nil
	end

	self.mTopRoleInfoPanel:destroy()
	self.mTopRoleInfoPanel = nil

	self.mRootNode:removeFromParent(true)
	self.mRootNode = nil
	self.mRootWidget = nil

	self.mScrollViewWidget	=	nil

	self.mHeroIconList		=	{}						-- 英雄头像列表
	self.mHeroIdTbl 		=	{}						-- 英雄Id数组
	self.mHeroAnimPanel		=	nil

	self.mCurSelectedHeroIndex 	=	nil
	self.mPreSelectedHeroIndex	=	nil
	self.star = nil
end

function HeroBeautifyWindow:onEventHandler(event)
	if event.mAction == Event.WINDOW_SHOW then
		self:Load()
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

return HeroBeautifyWindow