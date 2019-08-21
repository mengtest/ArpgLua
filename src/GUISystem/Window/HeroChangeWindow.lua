-- Name: 	HeroChangeWindow
-- Func：	英雄更换窗口
-- Author:	WangShengdong
-- Data:	15-5-14

local curSelectedHeroIndex = nil

local preHeroId = nil

-- 英雄列表对象
local HeroItemList = {}

function HeroItemList:new(listType)
	local o = 
	{
		mRootNode 	=	nil,
		mType 		=	listType,
		mHeroList	=	{},
		mTableView	=	nil,
		mDataSource = 	nil,
	}
	o = newObject(o, HeroItemList)
	return o
end

function HeroItemList:init(rootNode)
	self.mRootNode = rootNode
	-- 初始化数据源
	self:initDataSource()

	for i = 1, #self.mDataSource do
		print("数据源", self.mDataSource[i])
	end

	-- 初始化列表容器
	self:initTableView()
end

function HeroItemList:refresh()
	self:switchDataSource(self.mType)
end

function HeroItemList:initTableView()
	self.mTableView = TableViewEx:new()
	self.mTableView:setCellSize(GUIWidgetPool:createWidget("HeroChangeWidget"):getContentSize())
	self.mTableView:setCellCount(30)

	self.mTableView:registerTableCellAtIndexFunc(handler(self, self.tableCellAtIndex))
	self.mTableView:registerTableCellTouchedFunc(handler(self, self.tableCellTouched))

	self.mTableView:init(self.mRootNode:getContentSize(), cc.p(0,0), 0)
	self.mRootNode:addChild(self.mTableView:getRootNode())
end

function HeroItemList:tableCellAtIndex(table, index)

	local function updateHeroInfoById(widget, heroId)
		local heroInfo = DB_HeroConfig.getArrDataByField("ID", heroId)[1]
		widget:getChildByName("Panel_HeroPos"):removeAllChildren()
		local heroAnim = FightSystem.mRoleManager:CreateSpine(heroId)

		-- 缩放
		heroAnim:setScale(heroInfo.UIResouceZoom)
		widget:getChildByName("Panel_HeroPos"):addChild(heroAnim)

		-- 显示名字
		local picResId  = heroInfo.NamePic
		local picData   = DB_ResourceList.getDataById(picResId)
		local picUrl    = picData.Res_path1
		widget:getChildByName("Image_HeroName"):loadTexture(picUrl)

		local function doShaderEffect(widget, boolValue)
			-- 偶数
	--		for i = 1, 6 do
	--			ShaderManager:DoUIWidgetDisabled(widget:getChildByName("Panel_Star2"):getChildByName("Image_Star"..i), boolValue)
	--		end
			-- 奇数
	--		for i = 1, 5 do
	--			ShaderManager:DoUIWidgetDisabled(widget:getChildByName("Panel_Star1"):getChildByName("Image_Star"..i), boolValue)
	--		end
	--		ShaderManager:DoUIWidgetDisabled(widget:getChildByName("Image_Quality1"), boolValue)
	--		ShaderManager:DoUIWidgetDisabled(widget:getChildByName("Image_Quality2"), boolValue)

			if boolValue then
				ShaderManager:Stone_spine(widget:getChildByName("Panel_HeroPos"):getChildren()[1])
			end

		end

		-- 位置信息隐藏
		widget:getChildByName("Image_Position"):setVisible(false)

		if globaldata:isHeroIdExist(heroId) then 	-- 存在英雄
			widget:getChildByName("Image_Quality2"):setOpacity(255)
			widget:getChildByName("Image_Quality1"):setOpacity(255)
			doShaderEffect(widget, false)
			local heroObj = globaldata:findHeroById(heroId)
			local color = heroObj:getKeyValue("quality")
			local function showStar(widget, count, totalCount)
				for i = 1, totalCount do
					if i <= count then
						widget:getChildByName("Image_Star"..i):setVisible(true)
					else
						widget:getChildByName("Image_Star"..i):setVisible(false)
					end
				end
			end

			-- 显示位置
			for i = 1, globaldata:getBattleHeroCount() do
				if heroId == globaldata:getHeroInfoByBattleIndex(i, "id") then
					if 1 == i then
						widget:getChildByName("Image_Position"):loadTexture("public_hero_position_1.png")
					elseif 2 == i or 3 == i then
						widget:getChildByName("Image_Position"):loadTexture("public_hero_position_2.png")
					elseif 4 == i or 5 == i then
						widget:getChildByName("Image_Position"):loadTexture("public_hero_position_3.png")
					end
					widget:getChildByName("Image_Position"):setVisible(true)
					break
				end
			end

			-- 显示星星
			if 1 == math.mod(color, 2) then
				widget:getChildByName("Panel_Star1"):setVisible(true)
				widget:getChildByName("Panel_Star2"):setVisible(false)
				showStar(widget:getChildByName("Panel_Star1"), color, 5)
			else
				widget:getChildByName("Panel_Star1"):setVisible(false)
				widget:getChildByName("Panel_Star2"):setVisible(true)
				showStar(widget:getChildByName("Panel_Star2"), color, 6)
			end

			-- 显示品质
			local function updateQuality()
				local quality = heroObj:getKeyValue("advanceLevel")
				widget:getChildByName("Image_Quality1"):setVisible(true)
				if 0 == quality then
					widget:getChildByName("Image_Quality2"):setVisible(false)
					widget:getChildByName("Image_Quality1"):loadTexture("icon_heroselect_quality_0.png", 1)
				elseif 1 == quality then
					widget:getChildByName("Image_Quality2"):loadTexture("icon_heroselect_quality_1.png", 1)
					widget:getChildByName("Image_Quality2"):setVisible(true)
				elseif 2 == quality then
					widget:getChildByName("Image_Quality1"):loadTexture("icon_heroselect_quality_2.png", 1)
					widget:getChildByName("Image_Quality2"):setVisible(false)
				elseif 3 == quality then
					widget:getChildByName("Image_Quality2"):loadTexture("icon_heroselect_quality_3.png", 1)
					widget:getChildByName("Image_Quality2"):setVisible(true)
				elseif 4 == quality then
					widget:getChildByName("Image_Quality1"):loadTexture("icon_heroselect_quality_4.png", 1)
					widget:getChildByName("Image_Quality2"):setVisible(false)
				elseif 5 == quality then
					widget:getChildByName("Image_Quality2"):loadTexture("icon_heroselect_quality_5.png", 1)
					widget:getChildByName("Image_Quality2"):setVisible(true)
				elseif 6 == quality then
					widget:getChildByName("Image_Quality1"):loadTexture("icon_heroselect_quality_6.png", 1)
					widget:getChildByName("Image_Quality2"):setVisible(false)
				elseif 7 == quality then
					widget:getChildByName("Image_Quality2"):loadTexture("icon_heroselect_quality_7.png", 1)
					widget:getChildByName("Image_Quality2"):setVisible(true)
				elseif 8 == quality then
					widget:getChildByName("Image_Quality1"):loadTexture("icon_heroselect_quality_8.png", 1)
					widget:getChildByName("Image_Quality2"):setVisible(false)
				end
			end
			updateQuality()

			-- 显示级别
			widget:getChildByName("Label_Level"):setString(tostring(heroObj:getKeyValue("level")))
			-- 碎片
			local curChipId = heroObj:getKeyValue("chipId")
			local curChipCount = 0
			local chipObj = globaldata:getItemInfo(nil, curChipId)
			if chipObj then
				curChipCount = chipObj:getKeyValue("itemNum")
			end
			local neecChipCount = heroObj:getKeyValue("chipCount")

			-- 设置控件显示
		--	widget:getChildByName("Image_Quality1"):setVisible(true)
			widget:getChildByName("Label_Level"):setVisible(true)
			widget:getChildByName("Panel_Level"):setVisible(true)
		else
			widget:getChildByName("Image_Quality2"):setOpacity(160)
			widget:getChildByName("Image_Quality1"):setOpacity(160)
			doShaderEffect(widget, true)
			widget:getChildByName("Image_Quality2"):setVisible(false)
			widget:getChildByName("Image_Quality1"):loadTexture("icon_heroselect_quality_0.png", 1)
			-- 设置控件不显示
		--	widget:getChildByName("Image_Quality"):setVisible(false)
			widget:getChildByName("Panel_Level"):setVisible(false)
			widget:getChildByName("Panel_Star1"):setVisible(false)
			widget:getChildByName("Panel_Star2"):setVisible(false)
		end

		local heroData = DB_HeroConfig.getDataById(heroId)
		local groupId  = heroData.HeroGroup

		widget:getChildByName("Image_HeroGroup"):loadTexture(string.format("hero_group%d.png",groupId))


	end

	local heroId = self.mDataSource[index+1]

	local cell = table:dequeueCell()
	if nil == cell then
		cell = cc.TableViewCell:new()
		local heroWidget = GUIWidgetPool:createWidget("HeroChangeWidget")
		-- 换图
		heroWidget:getChildByName("Image_Quality1"):loadTexture("icon_heroselect_quality_0.png", 1)
		heroWidget:setTouchSwallowed(false)
		heroWidget:setTag(1)
		cell:addChild(heroWidget)
		updateHeroInfoById(heroWidget, heroId)
	else
		local heroWidget = cell:getChildByTag(1)
		updateHeroInfoById(heroWidget, heroId)
	end
	return cell
end

-- 初始化数据源
function HeroItemList:initDataSource()
	self.mDataSource = {}
	for i = 1, 24 do
		local heroInfo = DB_HeroConfig.getDataById(i)
		table.insert(self.mDataSource, heroInfo.ID)
	end
end

-- 切换数据源
function HeroItemList:switchDataSource(srcType)
	self.mDataSource = {}

	self.mType = srcType

	-- 第一遍循环，创建存在的
	for i = 1, 24 do
		local heroInfo = DB_HeroConfig.getDataById(i)
		-- if preHeroId ~= heroInfo.ID then
		-- 	if globaldata:isHeroIdExist(heroInfo.ID) then
		-- 		if 0 == srcType then 
		-- 			table.insert(self.mDataSource, heroInfo.ID)
		-- 		elseif 1 == srcType and 1 == heroInfo.College then
		-- 			table.insert(self.mDataSource, heroInfo.ID)
		-- 		elseif 2 == srcType and 2 == heroInfo.College then
		-- 			table.insert(self.mDataSource, heroInfo.ID)
		-- 		elseif 3 == srcType and 3 == heroInfo.College then
		-- 			table.insert(self.mDataSource, heroInfo.ID)
		-- 		end
		-- 	end
		-- end
		if preHeroId then
		--	if globaldata:isHeroIdExist(heroInfo.ID) and not globaldata:isHeroIdInBattle(heroInfo.ID) then
			if preHeroId ~= heroInfo.ID and globaldata:isHeroIdExist(heroInfo.ID) then
				if 0 == srcType then 
					table.insert(self.mDataSource, heroInfo.ID)
				elseif 1 == srcType and 1 == heroInfo.College then
					table.insert(self.mDataSource, heroInfo.ID)
				elseif 2 == srcType and 2 == heroInfo.College then
					table.insert(self.mDataSource, heroInfo.ID)
				elseif 3 == srcType and 3 == heroInfo.College then
					table.insert(self.mDataSource, heroInfo.ID)
				end
			end
		else
			if globaldata:isHeroIdExist(heroInfo.ID) and not globaldata:isHeroIdInBattle(heroInfo.ID) then
				if 0 == srcType then 
					table.insert(self.mDataSource, heroInfo.ID)
				elseif 1 == srcType and 1 == heroInfo.College then
					table.insert(self.mDataSource, heroInfo.ID)
				elseif 2 == srcType and 2 == heroInfo.College then
					table.insert(self.mDataSource, heroInfo.ID)
				elseif 3 == srcType and 3 == heroInfo.College then
					table.insert(self.mDataSource, heroInfo.ID)
				end
			end
		end
	end

	-- 根据战力排序
	local function sortFunc(id1, id2)
		local hero1 = globaldata:findHeroById(id1)
		local hero2 = globaldata:findHeroById(id2)
		return hero1:getKeyValue("combat") > hero2:getKeyValue("combat")
	end
	table.sort(self.mDataSource, sortFunc)

	-- 打印战力
	for i = 1, #self.mDataSource do
		local id = self.mDataSource[i]
		local hero = globaldata:findHeroById(id)
		print("英雄Id:", id, "战力:", hero:getKeyValue("combat"))
	end

	-- 第二遍循环，创建不存在的
	for i = 1, 24 do
		local heroInfo = DB_HeroConfig.getDataById(i)
		if preHeroId ~= heroInfo.ID then
			if not globaldata:isHeroIdExist(heroInfo.ID) then
				if 0 == srcType then 
					table.insert(self.mDataSource, heroInfo.ID)
				elseif 1 == srcType and 1 == heroInfo.College then
					table.insert(self.mDataSource, heroInfo.ID)
				elseif 2 == srcType and 2 == heroInfo.College then
					table.insert(self.mDataSource, heroInfo.ID)
				elseif 3 == srcType and 3 == heroInfo.College then
					table.insert(self.mDataSource, heroInfo.ID)
				end
			end
		end
	end

	self.mTableView:setCellCount(#self.mDataSource)
	self.mTableView:reloadData()
end

function HeroItemList:tableCellTouched(table,cell)
	print("cell touched at index: " .. cell:getIdx())
	local heroId = self.mDataSource[cell:getIdx()+1]
	print("点击的英雄Id", heroId)

	-- 跳转进战队界面
 	local function showInfo()
		if globaldata:isHeroIdExist(heroId) then
		--	local function fineHeroBattleIndex()
		--		for i = 1, 5 do
		--	 		if heroId == globaldata:getHeroInfoByBattleIndex(i, "id") then
		--	 			return i
		--	 		end
		--	 	end
		--	 	return nil
		--	end
		--	local ret = fineHeroBattleIndex()
		--	if ret then -- 在阵上
		--		Event.GUISYSTEM_SHOW_HEROINFOWINDOW.mData = ret
	      -- 		EventSystem:PushEvent(Event.GUISYSTEM_SHOW_HEROINFOWINDOW)
		--	else
				Event.GUISYSTEM_SHOW_HEROCHECKWINDOW.mData = {self.mDataSource, cell:getIdx()+1}
	       		EventSystem:PushEvent(Event.GUISYSTEM_SHOW_HEROCHECKWINDOW)
		--	end
		end
	end

	-- 请求更换英雄
	local function doChange()
		local heroObj = globaldata:findHeroById(heroId)
		local heroOldIndex = heroObj:getKeyValue("index")
		local heroTarId = heroId
		local heroNewIndex = curSelectedHeroIndex

		print("请求更换英雄:", heroObj:getKeyValue("id"), "-->", heroTarId)

		print("老的Index", heroOldIndex)
		print("新的Index", heroNewIndex)

		local packet = NetSystem.mNetManager:GetSPacket()
	    packet:SetType(PacketTyper._PTYPE_CS_REQUEST_EXCHANGEHERO_)
	    packet:PushInt(heroOldIndex)
	    packet:PushInt(heroTarId)
	    packet:PushInt(heroNewIndex)
	    packet:Send() 
	    -- 关闭
	    local function xxx()
	   		EventSystem:PushEvent(Event.GUISYSTEM_HIDE_HEROCHANGEWINDOW)
	   	end
	   	nextTick(xxx)

	    GUISystem:showLoading()
	end

	if curSelectedHeroIndex > 9996 and globaldata:isHeroIdExist(heroId) then
		if GUISystem.Windows["LadderWindow"].mRootNode ~= nil then
			GUISystem.Windows["LadderWindow"]:NotifyChangeHero(heroId)
			local function xxx()
	   			EventSystem:PushEvent(Event.GUISYSTEM_HIDE_HEROCHANGEWINDOW)
	   		end
	   		nextTick(xxx)
		end
	else
		if curSelectedHeroIndex and globaldata:isHeroIdExist(heroId) then
			doChange()
		else
			showInfo()
		end
	end
end

local HeroChangeWindow = 
{
	mName 				=	"HeroChangeWindow",
	mRootNode 			= 	nil,
	mRootWidget 		=	nil,
	mTopRoleInfoPanel 	=	nil,
	------------------------------
	mSchoolWidget 		=	nil,
	------------------------------
	mLastClickedWidget 	=	nil,

	mSchoolPageArr		=   {},
}

function HeroChangeWindow:Release()

end

function HeroChangeWindow:Load(event)
	cclog("=====HeroChangeWindow:Load=====begin")

--	GUIEventManager:registerEvent("battleTeamChanged", self, self.close)
--	GUIEventManager:registerEvent("battleTeamChanged", self, self.refresh)
	GUIEventManager:registerEvent("equipChanged", self, self.refresh)
	GUIEventManager:registerEvent("combatChanged", self, self.refresh)
	GUIEventManager:registerEvent("itemInfoChanged", self, self.refresh)

	if event and event.mData then
		curSelectedHeroIndex = event.mData[1]
		preHeroId = event.mData[2]
	else
		curSelectedHeroIndex = nil
		preHeroId = 1990
	end
	self.mRootNode = cc.Node:create()
	GUISystem:GetRootNode():addChild(self.mRootNode)

	-- local function preloadPlist()
	-- 	TextureSystem:loadPlist_heroqpicborder()
	-- end
	-- preloadPlist()
	
	self:InitLayout()
	cclog("=====HeroChangeWindow:Load=====end")
end

function HeroChangeWindow:close()
	-- 人物界面显示新的人物信息
	GUISystem:GetWindowByName("HeroInfoWindow"):selectHero(GUISystem:GetWindowByName("HeroInfoWindow").mRootWidget:getChildByName("Image_Hero"..tostring(curSelectedHeroIndex)))
	local function doClose() -- 下一阵关闭，防止野指针导致崩溃，2015-5-6 by wangsd
		EventSystem:PushEvent(Event.GUISYSTEM_HIDE_HEROCHANGEWINDOW)
	end
	nextTick(doClose)
end

function HeroChangeWindow:InitLayout()
	self.mRootWidget = GUIWidgetPool:createWidget("NewHeroChange")
	self.mRootNode:addChild(self.mRootWidget)
	local function closeWindow()
		EventSystem:PushEvent(Event.GUISYSTEM_HIDE_HEROCHANGEWINDOW)
	end

	self.mTopRoleInfoPanel = TopRoleInfoPanel:new()
	local topInfoPanel = self.mTopRoleInfoPanel:init(self.mRootNode, ROLE_TITLE_TYPE.TITLE_HERO, closeWindow)

	local function doAdapter()
	--    local topInfoPanelSize = topInfoPanel:getContentSize()
	--    local newHeight = getGoldFightPosition_LU().y - topInfoPanelSize.height - getGoldFightPosition_LD().y
	--    local newPosY = newHeight/2 + getGoldFightPosition_LD().y - self.mRootWidget:getChildByName("Panel_Main"):getContentSize().height/2
	    self.mRootWidget:getChildByName("Panel_Main"):setVisible(false)
		local function doSomething()
			if self.mRootNode then
				self.mRootWidget:getChildByName("Panel_Main"):setPositionX(getGoldFightPosition_LD().x)
				self.mRootWidget:getChildByName("Panel_Main"):setVisible(true)
				-- 战队指引
				if HeroInfoGuide:canGuide() then
					local guideWgt = self.mSchoolWidget.mTableView.mInnerContainer:cellAtIndex(0):getChildByTag(1)
					local size = guideWgt:getContentSize()
				 	local pos = guideWgt:getWorldPosition()
					local touchRect = cc.rect(pos.x, pos.y, size.width, size.height)
					HeroInfoGuide:step(3, touchRect)
				end


			end
		end
		doSomething()
	end
	doAdapter()

	self.mSchoolPageArr[1] = self.mRootWidget:getChildByName("Image_ShowAll")
	self.mSchoolPageArr[2] = self.mRootWidget:getChildByName("Image_ShowSchool1")
	self.mSchoolPageArr[3] = self.mRootWidget:getChildByName("Image_ShowSchool2")
	self.mSchoolPageArr[4] = self.mRootWidget:getChildByName("Image_ShowSchool3")

	registerWidgetPushDownEvent(self.mRootWidget:getChildByName("Image_ShowAll"),handler(self, self.showHero))
	registerWidgetPushDownEvent(self.mRootWidget:getChildByName("Image_ShowSchool1"),handler(self, self.showHero))
	registerWidgetPushDownEvent(self.mRootWidget:getChildByName("Image_ShowSchool2"),handler(self, self.showHero))
	registerWidgetPushDownEvent(self.mRootWidget:getChildByName("Image_ShowSchool3"),handler(self, self.showHero))

	for i=1,#self.mSchoolPageArr do
		self.mSchoolPageArr[i]:setVisible(false)
	end

	if self.mRootNode ~= nil then 
		self:SchoolPageAnimation(self.mSchoolPageArr)
	end

	local function doReSize()
		local curPosX = self.mRootWidget:getChildByName("Panel_Hero"):getWorldPosition().x
		local tarWidth = getGoldFightPosition_RD().x - curPosX
		local contentSize = self.mRootWidget:getChildByName("Panel_Hero"):getContentSize()
		contentSize.width = tarWidth
		self.mRootWidget:getChildByName("Panel_Hero"):setContentSize(contentSize)
	end
	doReSize()

	self.mSchoolWidget = HeroItemList:new(0)
	self.mSchoolWidget:init(self.mRootWidget:getChildByName("Panel_Hero"))

	-- 默认显示全部
	self:showHero(self.mRootWidget:getChildByName("Image_ShowAll"))
	
end

local index = 1

function HeroChangeWindow:SchoolPageAnimation(schoolPageArr)
	local schoolPagePos = cc.p(schoolPageArr[index]:getPosition())
	local schoolPageSize = schoolPageArr[index]:getContentSize()


	local function runBegin()	
		schoolPageArr[index]:setPosition(getGoldFightPosition_LD().x - schoolPageSize.width / 2,schoolPagePos.y)
		schoolPageArr[index]:setVisible(true)
	end

	local function runFinish()
		index = index + 1
		if index <= #schoolPageArr then  
			self:SchoolPageAnimation(schoolPageArr)
		else
			index = 1
		end
	end

	local actBegin = cc.CallFunc:create(runBegin)
	local actMove  =  cc.MoveTo:create(0.2, cc.p(schoolPagePos.x,schoolPagePos.y))
	local actEnd   = cc.CallFunc:create(runFinish)

	schoolPageArr[index]:runAction(cc.Sequence:create(actBegin,actMove,actEnd))
end

function HeroChangeWindow:showHero(widget)
	if self.mLastClickedWidget == widget then
		return
	end

	local norTexture = {"select_all1.png", "select_school1.png", "select_school2.png", "select_school3.png"}
	local pusTexture = {"select_all1_2.png", "select_school1_2.png", "select_school2_2.png", "select_school3_2.png"}

	-- 换普通图
	self.mRootWidget:getChildByName("Image_ShowAll"):loadTexture(norTexture[1])
	self.mRootWidget:getChildByName("Image_ShowSchool1"):loadTexture(norTexture[2])
	self.mRootWidget:getChildByName("Image_ShowSchool2"):loadTexture(norTexture[3])
	self.mRootWidget:getChildByName("Image_ShowSchool3"):loadTexture(norTexture[4])

	-- 换新图
	if "Image_ShowAll" == widget:getName() then
		self.mSchoolWidget:switchDataSource(0)
		widget:loadTexture(pusTexture[1])
	elseif "Image_ShowSchool1" == widget:getName() then
		self.mSchoolWidget:switchDataSource(1)
		widget:loadTexture(pusTexture[2])
	elseif "Image_ShowSchool2" == widget:getName() then
		self.mSchoolWidget:switchDataSource(2)
		widget:loadTexture(pusTexture[3])
	elseif "Image_ShowSchool3" == widget:getName() then
		self.mSchoolWidget:switchDataSource(3)
		widget:loadTexture(pusTexture[4])
	end

	-- 停止旋转
	if self.mLastClickedWidget then
		self.mLastClickedWidget:getChildByName("Image_Circle"):setVisible(false)
		self.mLastClickedWidget:getChildByName("Image_Circle"):stopAllActions()
	end

	-- 开始旋转
	local function doRotate()
		widget:getChildByName("Image_Circle"):setVisible(true)
		local act0 = cc.RotateBy:create(5, 360)
		widget:getChildByName("Image_Circle"):runAction(cc.RepeatForever:create(act0))
		
	end
	doRotate()
	self.mLastClickedWidget = widget
end

function HeroChangeWindow:Destroy()

--	GUIEventManager:unregister("battleTeamChanged", self.close)
--	GUIEventManager:unregister("battleTeamChanged", self.refresh)
	GUIEventManager:unregister("equipChanged", self.refresh)
	GUIEventManager:unregister("combatChanged", self.refresh)
	GUIEventManager:unregister("itemInfoChanged", self.refresh)

	if not self.mRootNode then
		return 
	end

	self.mTopRoleInfoPanel:destroy()
	self.mTopRoleInfoPanel = nil
	
	self.mRootNode:removeFromParent(true)
	self.mRootNode = nil
	self.mRootWidget = nil

	curSelectedHeroIndex = nil
	self.mLastClickedWidget = nil

	index = 1
	--清理缓存
	-- TextureSystem:unloadPlist_heroqpicborder()
	CommonAnimation:clearAllTextures()

	-- 战队指引
	if HeroInfoGuide:canGuide() then
		local guideWgt = GUISystem:GetWindowByName("HeroInfoWindow").mRootWidget:getChildByName("Button_Shengji")
		local size = guideWgt:getContentSize()
	 	local pos = guideWgt:getWorldPosition()
		local touchRect = cc.rect(pos.x - size.width/2, pos.y - size.height/2, size.width, size.height)
		HeroInfoGuide:step(4, touchRect)
	end
end

function HeroChangeWindow:onEventHandler(event)
	if event.mAction == Event.WINDOW_SHOW then
		self:Load(event)
		doLuaMemory()
	elseif event.mAction == Event.WINDOW_HIDE then
		self:Destroy()
		doLuaMemory()
	end
end

return HeroChangeWindow