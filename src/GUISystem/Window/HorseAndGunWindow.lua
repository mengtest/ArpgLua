-- Name: 	HorseAndGunWindow
-- Func：	时装坐骑
-- Author:	Wangsd
-- Data:	16-6-12

local HorseAndGunWindow = 
{
	mName 						= "HorseAndGunWindow",
	mRootNode					=	nil,	
	mRootWidget 				= 	nil,
	mTopRoleInfoPanel			=	nil,		-- 顶部人物信息面板
	mData 						=	nil,
	mEquipIdTbl					=	{},			-- ID表
	mCurSelectedPageWidget		=	nil,		-- 当前选择页签
	mCurSelectedEquipId			=	nil,		-- 当前选择的时装ID
	mCurSelectedEquipWidget		=	nil,		-- 当前点击的装备
	mCurSelcetedEquipLevel		=	nil,		-- 当前选择的装备预览阶段
	mCurSelectedEquipLevelAnimNode	=	nil,	-- 当前选择的装备预览阶段动画节点
	mCurSelectedEquipAnimNode	=	nil,		-- 当前模型
	mSchedulerHandler 			=	nil,		-- 定时器
}

HorseAndGunWindow.level = 31



function HorseAndGunWindow:Load(event)
	cclog("=====HorseAndGunWindow:Load=====begin")

	NetSystem.mNetManager:RegisterPacketHandler(PacketTyper._PTYPE_SC_FASHION_EQUIP_UPDATE, handler(self, self.onRequestDoEquipUpdate))
	NetSystem.mNetManager:RegisterPacketHandler(PacketTyper._PTYPE_SC_FASHION_EQUIP_USE, handler(self, self.onRequestUseEquip))
	NetSystem.mNetManager:RegisterPacketHandler(PacketTyper._PTYPE_SC_FASHION_EQUIP_SKILL_LVUP, handler(self, self.onRequestDoEquipSkillUpdate))
	NetSystem.mNetManager:RegisterPacketHandler(PacketTyper._PTYPE_SC_FASHION_EQUIP_ADVANCE, handler(self, self.onRequestDoEquipAdvance))

	GUIEventManager:registerEvent("itemInfoChanged", self, self.onItemInfoChanged)
	GUIEventManager:registerEvent("roleBaseInfoChanged", self, self.onItemInfoChanged)

	self.mRootNode = cc.Node:create()
	GUISystem:GetRootNode():addChild(self.mRootNode)

	if not self.mSchedulerHandler then
		local scheduler = cc.Director:getInstance():getScheduler()
		self.mSchedulerHandler = scheduler:scheduleScriptFunc(handler(self, self.tick), 0, false)
	end

	-- 载入时装
	self:loadAllFashionItem()
	
	self:InitLayout(event)

	local function doHeroHorseGuide_Stop()
		HeroHorseGuide:stop()
	end
	HeroHorseGuide:step(1, nil, doHeroHorseGuide_Stop)
	
	if HeroWeaponGuide:canGuide() then
		local guideBtn = self.mRootWidget:getChildByName("Image_Guns")
		local size = guideBtn:getContentSize()
		local pos = guideBtn:getWorldPosition()
		pos.x = pos.x - size.width/2
		pos.y = pos.y - size.height/2
		local touchRect = cc.rect(pos.x, pos.y, size.width, size.height)
		HeroWeaponGuide:step(1, touchRect)
	end

	cclog("=====HorseAndGunWindow:Load=====end")
end

function HorseAndGunWindow:onItemInfoChanged()
	self:updateEquipInfo()
end

function HorseAndGunWindow:tick()
	if self.mCurSelectedEquipAnimNode then
		self.mCurSelectedEquipAnimNode:Tick()
	end
end

-- 根据id查找物品
function HorseAndGunWindow:findItemById(itemId)
	for k, v in pairs(self.mData) do
		if itemId == v.mId then
			return v
		end
	end
	return nil
end

-- 点击页面
function HorseAndGunWindow:onPageClicked(widget)
	if self.mCurSelectedPageWidget == widget then
		return
	end
	self.mCurSelectedPageWidget = widget
	local itemType = widget:getTag() -- 类型
	local listView = self.mRootWidget:getChildByName("ListView_List")
	listView:removeAllItems()
	-- 前一次选中清空
	self.mCurSelectedEquipId = nil
	self.mCurSelectedEquipWidget = nil
	self.mCurSelcetedEquipLevel = nil

	for i = 1, #self.mEquipIdTbl do
		local itemId = self.mEquipIdTbl[i]
		local itemData = DB_FashionEquip.getDataById(itemId)
		if itemType == itemData.type then
			local fashionWidgwt = GUIWidgetPool:createWidget("MountsGuns_ListCell")
			-- tag
			fashionWidgwt:setTag(itemId)

			-- 名称
			fashionWidgwt:getChildByName("Label_Name"):setString(getDictionaryText(itemData.name))
			-- 不存在置灰
			local itemObj = self:findItemById(itemId)
			if itemObj then -- 存在
				-- 名称
				fashionWidgwt:getChildByName("Label_Level"):setString("Lv."..tostring(itemObj.mLevel))
				if 5 == itemObj.mLevel then
					fashionWidgwt:getChildByName("Label_Level"):setString("Lv.MAX")
				end
				if itemObj.equipAdvanceLevel > 0 then
					fashionWidgwt:getChildByName("Label_Name"):setString(getDictionaryText(itemData.name).." +"..tostring(itemObj.equipAdvanceLevel))
				end
			else -- 不存在
--				ShaderManager:DoUIWidgetDisabled(fashionWidgwt:getChildByName("Image_Bg"), true)
				-- 名称
				fashionWidgwt:getChildByName("Label_Level"):setString("未拥有")
			end

			-- icon
			local itemWidget = createFashionItemWidget(itemId, itemData.IconID)
			fashionWidgwt:getChildByName("Panel_Icon"):addChild(itemWidget)

			-- 添加
			listView:pushBackCustomItem(fashionWidgwt)

			-- 选中
		--	if globaldata.fashionEquipList[self.mCurSelectedPageWidget:getTag()][1] == itemId then
		--		fashionWidgwt:getChildByName("Image_Use"):setVisible(true)
		--	end

			registerWidgetReleaseUpEvent(fashionWidgwt, handler(self, self.onEquipClicked))
		end
	end

	-- 默认选中第一项
	self:onEquipClicked(listView:getItem(0))

	-- 刷新左侧列表
	self:updateEquipList()

	local function doHeroHorseGuide_Stop()
		HeroWeaponGuide:stop()
	end
	HeroWeaponGuide:step(2, nil, doHeroHorseGuide_Stop)
end

-- 点击装备
function HorseAndGunWindow:onEquipClicked(widget)
	if self.mCurSelectedEquipWidget == widget then
		return
	end
	self.mCurSelectedEquipId = widget:getTag()
	self.mCurSelcetedEquipLevel = nil
	if self.mCurSelectedEquipWidget then -- 换图
		self.mCurSelectedEquipWidget:getChildByName("Image_Bg"):loadTexture("public_bg_page_2.png")
	end
	self.mCurSelectedEquipWidget = widget
	self.mCurSelectedEquipWidget:getChildByName("Image_Bg"):loadTexture("public_bg_page_1.png")
	
	-- 刷新界面
	self:updateEquipInfo()
end

-- 点击显示类型 
function HorseAndGunWindow:onLevelBtnClicked(widget)
	if self.mCurSelcetedEquipLevel == widget:getTag() then
		return
	end

	local itemId = self.mCurSelectedEquipId
	local itemData = DB_FashionEquip.getDataById(itemId)
	local itemObj = self:findItemById(itemId)
	local limitLevel = nil

	if 1 == widget:getTag() then
		limitLevel = 1
	elseif 2 == widget:getTag() then
		limitLevel = itemData.newlevel1
		if not itemObj then
			MessageBox:showMessageBox1("您还未拥有此件时装")
			return
		end
		if itemObj.mLevel < limitLevel then
			MessageBox:showMessageBox1("此件时装还未达到"..limitLevel.."级")
			return
		end
	elseif 3 == widget:getTag() then
		limitLevel = itemData.newlevel2
		if not itemObj then
			MessageBox:showMessageBox1("您还未拥有此件时装")
			return
		end
		if itemObj.mLevel < limitLevel then
			MessageBox:showMessageBox1("此件时装还未达到"..limitLevel.."级")
			return
		end
	end

	self.mCurSelcetedEquipLevel = widget:getTag()

	if self.mCurSelectedEquipLevelAnimNode then
		self.mCurSelectedEquipLevelAnimNode:destroy()
		self.mCurSelectedEquipLevelAnimNode = nil
	end
	local function xxx()
		self.mCurSelectedEquipLevelAnimNode:play("bagpack_item_chosen2", true)
	end
	self.mCurSelectedEquipLevelAnimNode = AnimManager:createAnimNode(8002)
	self.mRootWidget:getChildByName("Panel_Appearance_"..self.mCurSelcetedEquipLevel):getChildByName("Panel_Animation"):addChild(self.mCurSelectedEquipLevelAnimNode:getRootNode(), 100)
	self.mCurSelectedEquipLevelAnimNode:play("bagpack_item_chosen1", false, xxx)

	-- 刷新模型
	self:updateAnimNode()

	-- 刷新选中信息
	self:updateEquipUseInfo()
end

-- 刷新当前模型
function HorseAndGunWindow:updateAnimNode()
	if self.mCurSelectedEquipAnimNode then
		self.mCurSelectedEquipAnimNode:Destroy()
		self.mCurSelectedEquipAnimNode = nil
	end
	self.mCurSelectedEquipAnimNode  = SpineDataCacheManager:getFashionSpineByItemId(self.mRootWidget:getChildByName("Panel_HeroSpine"), 
		globaldata.leaderHeroId, self.mCurSelectedPageWidget:getTag(), self.mCurSelectedEquipWidget:getTag() ,self.mCurSelcetedEquipLevel)
end

-- 刷新左侧武器列表
function HorseAndGunWindow:updateEquipList()
	local listView = self.mRootWidget:getChildByName("ListView_List")
	local equipWidgetTbl = listView:getItems()
	for i = 1, #equipWidgetTbl do
		equipWidgetTbl[i]:getChildByName("Image_Use"):setVisible(false)
		if globaldata.fashionEquipList[self.mCurSelectedPageWidget:getTag()] and globaldata.fashionEquipList[self.mCurSelectedPageWidget:getTag()][1] == equipWidgetTbl[i]:getTag() then
			equipWidgetTbl[i]:getChildByName("Image_Use"):setVisible(true)
		end
	end
end

-- 刷新技能信息
function HorseAndGunWindow:updateEquipSkillInfo(itemObj)
	-- 技能升级消耗
	local skillUpdateNeedItemId = nil
	-- 技能
	for i = 1, itemObj.mSkillCnt do
		local skillData = DB_FashionTrain.getDataById(itemObj.mSkillList[i].mSkillId)
		-- 名称
		self.mRootWidget:getChildByName("Panel_Skill_"..i):getChildByName("Label_NameLevel"):setString(getDictionaryText(skillData.name).." Lv."..tostring(itemObj.mSkillList[i].mSkillBigLevel))
		-- 物品
		skillUpdateNeedItemId = skillData.consumeid
		local itemData = DB_ItemConfig.getDataById(skillUpdateNeedItemId)
		local itemIcon = itemData.IconID
		local imgName = DB_ResourceList.getDataById(itemIcon).Res_path1
		self.mRootWidget:getChildByName("Panel_Skill_"..i):getChildByName("Image_Cost_Currency"):loadTexture(imgName, 1)
		-- 数量
		local labelWidget = self.mRootWidget:getChildByName("Panel_Skill_"..i):getChildByName("Label_Cost_Currency")
		labelWidget:setString(tostring(globaldata:getItemOwnCount(skillUpdateNeedItemId)).."/"..itemObj.mSkillList[i].mSkillUpdateItemCnt)
		if globaldata:getItemOwnCount(skillUpdateNeedItemId) >= itemObj.mSkillList[i].mSkillUpdateItemCnt then -- 足够
			labelWidget:setColor(cc.c3b(162,255,169))
			registerWidgetReleaseUpEvent(self.mRootWidget:getChildByName("Panel_Skill_"..i):getChildByName("Button_Upgrade"), handler(self, self.requestDoEquipSkillUpdate))
		else
			MessageBox:showHowToGetMessage(self.mRootWidget:getChildByName("Panel_Skill_"..i):getChildByName("Button_Upgrade"), 0, skillUpdateNeedItemId)
			labelWidget:setColor(cc.c3b(255,162,162))
		end
		-- 描述
		self.mRootWidget:getChildByName("Panel_Skill_"..i):getChildByName("Label_Desc"):setString(string.format(getDictionaryText(skillData.textid), skillData.value+(itemObj.mSkillList[i].mSkillBigLevel-1)*skillData.valueadd/10))
		-- 进度条
		local value = 100*itemObj.mSkillList[i].mSkillSmallLevel/itemObj.mSkillList[i].mSkillSmallLevelCnt
		if value >= 100 then
			value = 100
		end
		self.mRootWidget:getChildByName("Panel_Skill_"..i):getChildByName("ProgressBar_EXP"):setPercent(value)
	end

	-- 战力
	self.mRootWidget:getChildByName("Panel_Middle"):getChildByName("Label_Zhanli"):setString(itemObj.mPower)
	-- 进阶经验条
	local value = 100*itemObj.equipCurSkillPoint/itemObj.equipMaxSkillPoint
	if value >= 100 then
		value = 100
	end
	self.mRootWidget:getChildByName("Panel_Middle"):getChildByName("Panel_Jinjie"):getChildByName("ProgressBar_EXP"):setPercent(value)
	self.mRootWidget:getChildByName("Panel_Middle"):getChildByName("Panel_Jinjie"):getChildByName("Label_EXP"):setString(tostring(itemObj.equipCurSkillPoint).."/"..tostring(itemObj.equipMaxSkillPoint))
end

-- 刷新当前界面
function HorseAndGunWindow:updateEquipInfo()
	local itemId = self.mCurSelectedEquipId
	local itemData = DB_FashionEquip.getDataById(itemId)

	local itemObj = self:findItemById(itemId)
	if itemObj then -- 拥有
		self.mRootWidget:getChildByName("Panel_Right"):getChildByName("Panel_Info_Have"):setVisible(true)
		self.mRootWidget:getChildByName("Panel_Right"):getChildByName("Panel_Info_No"):setVisible(false)
		-- 名称
		self.mRootWidget:getChildByName("Panel_Middle"):getChildByName("Label_Name"):setString(getDictionaryText(itemData.name))
		if itemObj.equipAdvanceLevel > 0 then
			self.mRootWidget:getChildByName("Panel_Middle"):getChildByName("Label_Name"):setString(getDictionaryText(itemData.name).." +"..tostring(itemObj.equipAdvanceLevel))
		end
		-- 级别
		self.mRootWidget:getChildByName("Panel_Middle"):getChildByName("Label_Level"):setString("Lv."..tostring(itemObj.mLevel))
		if 5 == itemObj.mLevel then
			self.mRootWidget:getChildByName("Panel_Middle"):getChildByName("Label_Level"):setString("Lv.MAX")
		end
		self.mRootWidget:getChildByName("Button_Use"):setVisible(true)
		
		if 4 == itemObj.mLevel then -- 需要物品
			self.mRootWidget:getChildByName("Panel_Gold"):getChildByName("Image_Gold"):setVisible(false)
			self.mRootWidget:getChildByName("Panel_Gold"):getChildByName("Panel_Icon"):setVisible(true)
			self.mRootWidget:getChildByName("Panel_Gold"):getChildByName("Panel_Icon"):removeAllChildren()
			local iconWidget = createItemWidget(itemData.Itemid_senior, "")
			self.mRootWidget:getChildByName("Panel_Gold"):getChildByName("Panel_Icon"):addChild(iconWidget)
			MessageBox:showHowToGetMessage(iconWidget, 0, itemData.Itemid_senior)
			-- 升级需要金钱
			self.mRootWidget:getChildByName("Panel_Gold"):getChildByName("Label_Num"):setString(globaldata:getItemOwnCount(itemData.Itemid_senior).."/"..itemObj.equipUpdateMoneyCnt)
		else -- 需要金钱
			self.mRootWidget:getChildByName("Panel_Gold"):getChildByName("Image_Gold"):setVisible(true)
			self.mRootWidget:getChildByName("Panel_Gold"):getChildByName("Panel_Icon"):setVisible(false)
			-- 升级需要金钱
			self.mRootWidget:getChildByName("Panel_Gold"):getChildByName("Label_Num"):setString(itemObj.equipUpdateMoneyCnt)
		end
		-- 升级所需物品
		local iconWidget = createFashionItemWidget(itemId, itemData.IconID)
		self.mRootWidget:getChildByName("Panel_Upgrade"):getChildByName("Panel_Item"):getChildByName("Panel_Icon"):addChild(iconWidget)
		local needItemId = itemData.Itemid
		MessageBox:showHowToGetMessage(iconWidget, 0, needItemId)

		-- 数量
		local labelWidget = self.mRootWidget:getChildByName("Panel_Upgrade"):getChildByName("Panel_Item"):getChildByName("Label_Num")
		local btnWidget = self.mRootWidget:getChildByName("Panel_Upgrade"):getChildByName("Button_Upgrade")
		labelWidget:setString(globaldata:getItemOwnCount(needItemId).."/"..tostring(itemObj.equipUpdateItemCnt))
		if globaldata:getItemOwnCount(needItemId) >= itemObj.equipUpdateItemCnt then
		--	labelWidget:setColor(cc.c3b(162,255,169))
		--	ShaderManager:DoUIWidgetDisabled(btnWidget, false)
		--	btnWidget:setTouchEnabled(true)
			registerWidgetReleaseUpEvent(btnWidget, handler(self, self.requestDoEquipUpdate))
		else
		--	labelWidget:setColor(cc.c3b(255,162,162))
		--	ShaderManager:DoUIWidgetDisabled(btnWidget, true)
		--	btnWidget:setTouchEnabled(false)
			MessageBox:showHowToGetMessage(btnWidget, 0, needItemId)
		end

		-- 刷新技能
		self:updateEquipSkillInfo(itemObj)

	else -- 未拥有
		self.mRootWidget:getChildByName("Panel_Right"):getChildByName("Panel_Info_Have"):setVisible(false)
		self.mRootWidget:getChildByName("Panel_Right"):getChildByName("Panel_Info_No"):setVisible(true)
		self.mRootWidget:getChildByName("Button_Use"):setVisible(false)

		local needItemId = itemData.Itemid
		-- 数量
		local labelWidget = self.mRootWidget:getChildByName("Panel_Info_No"):getChildByName("Panel_Item"):getChildByName("Label_Num")
		labelWidget:setString(globaldata:getItemOwnCount(needItemId).."/1")
		-- 按钮
		local btnWidget = self.mRootWidget:getChildByName("Button_Born")
		if globaldata:getItemOwnCount(needItemId) >= 1 then -- 足够
		--	labelWidget:setColor(cc.c3b(162,255,169))
		--	-- 置灰
		--	ShaderManager:DoUIWidgetDisabled(btnWidget, false)
		--	btnWidget:setTouchEnabled(true)
			registerWidgetReleaseUpEvent(btnWidget, handler(self, self.requestDoEquipUpdate))
		else
		--	labelWidget:setColor(cc.c3b(255,162,162))
		--	-- 置灰
		--	ShaderManager:DoUIWidgetDisabled(btnWidget, true)
		--	btnWidget:setTouchEnabled(false)
			-- 物品来源
			MessageBox:showHowToGetMessage(btnWidget, 0, needItemId)
		end
		-- 图标
		local itemWidget = createFashionItemWidget(itemId, itemData.IconID)
		local parentNode = self.mRootWidget:getChildByName("Panel_Info_No"):getChildByName("Panel_Item"):getChildByName("Panel_Icon")
		parentNode:removeAllChildren()
		parentNode:addChild(itemWidget)
		MessageBox:showHowToGetMessage(itemWidget, 0, needItemId)
	end

	-- 三个外观图标
	for i = 1, 3 do
		local parentNode = self.mRootWidget:getChildByName("Panel_Top"):getChildByName("Panel_Appearances"):getChildByName("Panel_Appearance_"..i):getChildByName("Panel_Icon")
		parentNode:removeAllChildren()
		local itemWidget = nil
		if 1 == i then
			itemWidget = createFashionItemWidget(itemId, itemData.IconID)
		elseif 2 == i then
			itemWidget = createFashionItemWidget(itemId, itemData.newIconID1)
		elseif 3 == i then
			itemWidget = createFashionItemWidget(itemId, itemData.newIconID2)
		end
		parentNode:addChild(itemWidget)
		itemWidget:setTag(i)
		itemWidget:setTouchEnabled(true)
		registerWidgetReleaseUpEvent(itemWidget, handler(self, self.onLevelBtnClicked))
	end	

	for i = 1, 3 do
		local parentNode = self.mRootWidget:getChildByName("Panel_Top"):getChildByName("Panel_Appearances"):getChildByName("Panel_Appearance_"..i)
		local limitLevel = 1
		if 1 ~= i then
			limitLevel = itemData["newlevel"..(i-1)]
		end
		if itemObj then
			if itemObj.mLevel < limitLevel then
				parentNode:getChildByName("Panel_LevelLimit"):setVisible(true)
			else
				parentNode:getChildByName("Panel_LevelLimit"):setVisible(false)
			end
		else
			parentNode:getChildByName("Panel_LevelLimit"):setVisible(true)
		end
	end

	-- 背景
	local imgBgId = itemData.ResourceId
	local imgName = DB_ResourceList.getDataById(imgBgId).Res_path1
	self.mRootWidget:getChildByName("Panel_Top"):getChildByName("Image_Bg"):loadTexture(imgName)

	-- 默认选中第一个外观
	self:onLevelBtnClicked(self.mRootWidget:getChildByName("Panel_Appearance_1"):getChildByName("Panel_Icon"):getChildren()[1])

	-- 刷新当前装备属性
	self:updateEquipProp()

	-- 刷新红点
	FashionNoticeInnerImpl:doUpdate()
end

-- 刷新当前装备属性
function HorseAndGunWindow:updateEquipProp()
	local itemId = self.mCurSelectedEquipId
	local itemData = DB_FashionEquip.getDataById(itemId)
	local itemObj = self:findItemById(itemId)
	local curJinjieLv = 0
	if itemObj then
		curJinjieLv = itemObj.equipAdvanceLevel
	end

	-- 进阶属性
	for i = 1, 3 do
		--进阶等级要求
		local needLv = itemData["Advancelevel"..i]
		self.mRootWidget:getChildByName("Panel_Right"):getChildByName("Panel_Property"):getChildByName("Panel_Jinjie"):getChildByName("Panel_Property_"..i):getChildByName("Label_Jinjie"):setString("进阶+"..needLv)
		--属性加成图片
		self.mRootWidget:getChildByName("Panel_Right"):getChildByName("Panel_Property"):getChildByName("Panel_Jinjie"):getChildByName("Panel_Property_"..i):getChildByName("Image_Property"):loadTexture("hero_property_"..itemData["Advancetype"..i]..".png")
		--属性加成值
		local labelWidget = self.mRootWidget:getChildByName("Panel_Property"):getChildByName("Panel_Jinjie"):getChildByName("Panel_Property_"..i):getChildByName("Label_Init")
		labelWidget:setString(itemData["Advancevalue"..i])
		if curJinjieLv >= needLv then
			labelWidget:setColor(cc.c3b(255,255,0))
		else
			labelWidget:setColor(cc.c3b(255,255,255))
		end
	end
	
	-- 基础属性
	if itemObj then
		for i = 1, 3 do
			local parentNode = self.mRootWidget:getChildByName("Panel_Basic"):getChildByName("Panel_Property_"..i)
			if i <= itemObj.initPropCnt then
				parentNode:setVisible(true)
				-- 属性加成图片
				parentNode:getChildByName("Image_Property"):loadTexture("hero_property_"..tostring(itemObj.initPropList[i].propType)..".png")
				-- 属性加成值
				parentNode:getChildByName("Label_Init"):setString(itemObj.initPropList[i].propValue)
				if itemObj.propPercent > 0 then
					-- 属性加成百分比
					parentNode:getChildByName("Label_Advance"):setString("+"..tostring(itemObj.propPercent).."%")
				else
					parentNode:getChildByName("Label_Advance"):setString("")
				end
			else
				parentNode:setVisible(false)
			end
		end
	else
		local basicPropCnt = itemData.InitNumber
		for i = 1, 3 do
			local parentNode = self.mRootWidget:getChildByName("Panel_Basic"):getChildByName("Panel_Property_"..i)
			if i <= basicPropCnt then
				parentNode:setVisible(true)
				-- 属性加成图片
				parentNode:getChildByName("Image_Property"):loadTexture("hero_property_"..tostring(itemData["InitType"..i])..".png")
				-- 属性加成值
				parentNode:getChildByName("Label_Init"):setString(itemData["InitValue"..i])
				-- 属性加成百分比
				parentNode:getChildByName("Label_Advance"):setString("")
			else
				parentNode:setVisible(false)
			end
		end
	end
end

function HorseAndGunWindow:updateEquipUseInfo()
	-- 是否处于选择中
	for i = 1, 3 do
		self.mRootWidget:getChildByName("Panel_Appearance_"..i):getChildByName("Image_Use"):setVisible(false)
	end

	if globaldata.fashionEquipList[self.mCurSelectedPageWidget:getTag()] then
		if globaldata.fashionEquipList[self.mCurSelectedPageWidget:getTag()][1] == self.mCurSelectedEquipId then
			self.mRootWidget:getChildByName("Panel_Appearance_"..globaldata.fashionEquipList[self.mCurSelectedPageWidget:getTag()][2]):getChildByName("Image_Use"):setVisible(true)
		else
		
		end

		if globaldata.fashionEquipList[self.mCurSelectedPageWidget:getTag()][1] == self.mCurSelectedEquipId and globaldata.fashionEquipList[self.mCurSelectedPageWidget:getTag()][2] == self.mCurSelcetedEquipLevel then
			self.mRootWidget:getChildByName("Button_Use"):loadTextureNormal("mountsguns_use_2.png")
		else
			self.mRootWidget:getChildByName("Button_Use"):loadTextureNormal("mountsguns_use_1.png")
		end
	else
		self.mRootWidget:getChildByName("Button_Use"):loadTextureNormal("mountsguns_use_1.png")
	end
end

-- 点击技能升级
function HorseAndGunWindow:requestDoEquipSkillUpdate(widget)
	local index = widget:getTag()
	local itemId = self.mCurSelectedEquipId
	local itemObj = self:findItemById(itemId)
	local packet = NetSystem.mNetManager:GetSPacket()
	packet:SetType(PacketTyper._PTYPE_CS_FASHION_EQUIP_SKILL_LVUP)
	packet:PushInt(itemId)
	packet:PushInt(itemObj.mSkillList[index].mSkillId)
	packet:Send()
	GUISystem:showLoading()
end

-- 点击时装进阶
function HorseAndGunWindow:requestDoEquipAdvance(widget)
	local packet = NetSystem.mNetManager:GetSPacket()
	packet:SetType(PacketTyper._PTYPE_CS_FASHION_EQUIP_ADVANCE)
	packet:PushInt(self.mCurSelectedEquipId)
	packet:Send()
	GUISystem:showLoading()
end

-- 时装进阶回包
function HorseAndGunWindow:onRequestDoEquipAdvance(msgPacket)
	local itemId = msgPacket:GetInt()
	local itemObj = self:findItemById(itemId)
	itemObj.mType 		= msgPacket:GetChar()
	itemObj.mPower 		= msgPacket:GetInt()	-- 时装战力
	itemObj.mLevel  	= msgPacket:GetInt()
	-- 时装升级部分
	itemObj.equipUpdateItemCnt	=	msgPacket:GetInt()
	itemObj.equipUpdateMoneyCnt	=	msgPacket:GetInt()
	itemObj.equipAdvanceLevel	=	msgPacket:GetInt()
	itemObj.equipCurSkillPoint	=	msgPacket:GetInt()
	itemObj.equipMaxSkillPoint	=	msgPacket:GetInt()
	itemObj.propPercent			=	msgPacket:GetInt()	

	if itemObj.equipAdvanceLevel > 0 then
		local itemData = DB_FashionEquip.getDataById(itemId)
		self.mCurSelectedEquipWidget:getChildByName("Label_Name"):setString(getDictionaryText(itemData.name).." +"..tostring(itemObj.equipAdvanceLevel))
	end

	-- 刷新界面
	self:updateEquipInfo()
	GUISystem:hideLoading()
end

-- 响应技能升级
function HorseAndGunWindow:onRequestDoEquipSkillUpdate(msgPacket)
	local equipId 					= 	msgPacket:GetInt()
	local equipCurSkillPoint		= 	msgPacket:GetInt()
	local equipSkillId 				= 	msgPacket:GetInt()
	local equipSkillBigLevel 		=	msgPacket:GetInt()		-- 时装技能大等级
	local equipSkillSmallLevel 		=	msgPacket:GetInt()		-- 时装技能小等级
	local equipSkillSmallLevelCnt 	=	msgPacket:GetInt()		-- 时装技能小等级数量
	local equipSkillUpdateItemCnt 	=	msgPacket:GetInt()		-- 时装技能升级需要物品数量
	GUISystem:hideLoading()

	local itemObj = self:findItemById(equipId)
	itemObj.equipCurSkillPoint = equipCurSkillPoint -- 技能升级会增加装备的技能点
	for i = 1, itemObj.mSkillCnt do
		if equipSkillId == itemObj.mSkillList[i].mSkillId then
			itemObj.mSkillList[i] = {}
			itemObj.mSkillList[i].mSkillId				=	equipSkillId				-- 时装技能ID
			itemObj.mSkillList[i].mSkillBigLevel		=	equipSkillBigLevel			-- 时装技能大等级
			itemObj.mSkillList[i].mSkillSmallLevel		=	equipSkillSmallLevel		-- 时装技能小等级
			itemObj.mSkillList[i].mSkillSmallLevelCnt	=	equipSkillSmallLevelCnt		-- 时装技能小等级数量
			itemObj.mSkillList[i].mSkillUpdateItemCnt	=	equipSkillUpdateItemCnt		-- 时装技能升级需要物品数量
			-- 刷新界面
			self:updateEquipSkillInfo(itemObj)
			return
		end
	end
end

-- 点击进化
function HorseAndGunWindow:requestDoEquipUpdate(widget)
	local packet = NetSystem.mNetManager:GetSPacket()
	packet:SetType(PacketTyper._PTYPE_CS_FASHION_EQUIP_UPDATE)
	packet:PushInt(self.mCurSelectedEquipId)
	packet:Send()
	GUISystem:showLoading()
end

-- 使用时装
function HorseAndGunWindow:requestUseEquip(widget)
	local packet = NetSystem.mNetManager:GetSPacket()
	packet:SetType(PacketTyper._PTYPE_CS_FASHION_EQUIP_USE)
	packet:PushInt(self.mCurSelectedEquipId)
	packet:PushInt(self.mCurSelcetedEquipLevel)
	packet:Send()
	GUISystem:showLoading()
end

-- 使用时装回包
function HorseAndGunWindow:onRequestUseEquip(msgPacket)
	local equipType = msgPacket:GetChar()
	globaldata.fashionEquipList[equipType] = {msgPacket:GetInt(), msgPacket:GetChar()}
	if 0 == globaldata.fashionEquipList[equipType][1] and 0 == globaldata.fashionEquipList[equipType][2] then
		globaldata.fashionEquipList[equipType] = nil
	end 
	FightSystem.mHallManager:OnTeamMemberChanged()
	GUISystem:hideLoading()
	-- 刷新选中信息
	self:updateEquipUseInfo()
	-- 刷新左侧列表
	self:updateEquipList()
end

-- 进化回包
function HorseAndGunWindow:onRequestDoEquipUpdate(msgPacket)
	local mId = msgPacket:GetInt()
	local itemObj = self:findItemById(mId)
	if not itemObj then
		itemObj = {}
	end

	itemObj.mId 		= 	mId
	itemObj.mType		= 	msgPacket:GetChar()
	itemObj.mPower 		= msgPacket:GetInt()	-- 时装战力
	itemObj.mLevel		=	msgPacket:GetInt()
	-- 时装升级部分
	itemObj.equipUpdateItemCnt	=	msgPacket:GetInt()
	itemObj.equipUpdateMoneyCnt	=	msgPacket:GetInt()
	itemObj.equipAdvanceLevel	=	msgPacket:GetInt()
	itemObj.equipCurSkillPoint	=	msgPacket:GetInt()
	itemObj.equipMaxSkillPoint	=	msgPacket:GetInt()
	-- 时装基础属性
	itemObj.propPercent			=	msgPacket:GetInt()
	itemObj.initPropCnt 		=	msgPacket:GetUShort()
	itemObj.initPropList		=	{}
	for j = 1, itemObj.initPropCnt do
		itemObj.initPropList[j] = {}
		itemObj.initPropList[j].propType 	= 	msgPacket:GetChar()
		itemObj.initPropList[j].propValue	=	msgPacket:GetInt()
	end
	-- 时装技能部分
	itemObj.mSkillCnt	=	msgPacket:GetUShort()
	itemObj.mSkillList	=	{}
	for i = 1, itemObj.mSkillCnt do
		itemObj.mSkillList[i] = {}
		itemObj.mSkillList[i].mSkillId				=	msgPacket:GetInt()		-- 时装技能ID
		itemObj.mSkillList[i].mSkillBigLevel		=	msgPacket:GetInt()		-- 时装技能大等级
		itemObj.mSkillList[i].mSkillSmallLevel		=	msgPacket:GetInt()		-- 时装技能小等级
		itemObj.mSkillList[i].mSkillSmallLevelCnt	=	msgPacket:GetInt()		-- 时装技能小等级数量
		itemObj.mSkillList[i].mSkillUpdateItemCnt	=	msgPacket:GetInt()		-- 时装技能升级需要物品数量
	end
	table.insert(self.mData, itemObj)
	GUISystem:hideLoading()

	-- 刷新图标列表
	self.mCurSelectedEquipWidget:getChildByName("Label_Level"):setString("Lv."..tostring(itemObj.mLevel))
	if 5 == itemObj.mLevel then
		self.mCurSelectedEquipWidget:getChildByName("Label_Level"):setString("Lv.MAX")
	end
	-- 刷新界面
	self:updateEquipInfo()
end

-- 载入时装
function HorseAndGunWindow:loadAllFashionItem()
	self.mEquipIdTbl = {}
	for k, v in pairs(DB_FashionEquip.FashionEquip) do
		table.insert(self.mEquipIdTbl, k)
	end
end

function HorseAndGunWindow:InitLayout(event)
	self.mData = event.mData

	if self.mRootWidget == nil then
		self.mRootWidget = GUIWidgetPool:createWidget("MountsGuns_Main")
    	self.mRootNode:addChild(self.mRootWidget,100)
    end

    local function closeWindow()
    	GUISystem:playSound("homeBtnSound")
		EventSystem:PushEvent(Event.GUISYSTEM_HIDE_HORSEANDGUNWINDOW)
   	end  
	self.mTopRoleInfoPanel = TopRoleInfoPanel:new()
	local topInfoPanel = self.mTopRoleInfoPanel:init(self.mRootNode,ROLE_TITLE_TYPE.TITLE_FASHIONEQUIP, closeWindow)


	self.mPageHorse = self.mRootWidget:getChildByName("Image_Mounts")
	self.mPageGun   = self.mRootWidget:getChildByName("Image_Guns")

	if globaldata.level < self.level then
		self.mPageGun:setVisible(false)
	end
	
	self.mPageHorse:setTag(1)
	self.mPageGun:setTag(2)

	local function OnClickPage(page)
		if page == self.mPageHorse then
			self.mPageHorse:loadTexture("mountsguns_pages_mounts_1.png")
			self.mPageGun:loadTexture("mountsguns_pages_guns_2.png")
		else
			self.mPageHorse:loadTexture("mountsguns_pages_mounts_2.png")
			self.mPageGun:loadTexture("mountsguns_pages_guns_1.png")
		end
		self:onPageClicked(page)
	end

	registerWidgetReleaseUpEvent(self.mPageHorse,OnClickPage)
	registerWidgetReleaseUpEvent(self.mPageGun,OnClickPage)

	registerWidgetReleaseUpEvent(self.mRootWidget:getChildByName("Panel_Upgrade"):getChildByName("Button_Upgrade"), handler(self, self.requestDoEquipUpdate))
	registerWidgetReleaseUpEvent(self.mRootWidget:getChildByName("Button_Born"), handler(self, self.requestDoEquipUpdate))
	registerWidgetReleaseUpEvent(self.mRootWidget:getChildByName("Button_Use"), handler(self, self.requestUseEquip))
	registerWidgetReleaseUpEvent(self.mRootWidget:getChildByName("Button_Jinjie"), handler(self, self.requestDoEquipAdvance))

	for i = 1, 3 do
		local btnWidget = self.mRootWidget:getChildByName("Panel_Skill_"..i):getChildByName("Button_Upgrade")
		btnWidget:setTag(i)
		registerWidgetReleaseUpEvent(btnWidget, handler(self, self.requestDoEquipSkillUpdate))
	end

	if event.defaultParam then
		if 1 == event.defaultParam then
			OnClickPage(self.mPageHorse)
		elseif 2 == event.defaultParam then
			OnClickPage(self.mPageGun)
		end
	else
		OnClickPage(self.mPageHorse)
	end

	

	-- 适配
	local function doAdapter()
		-- 居中操作
		local topInfoPanelSize = self.mTopRoleInfoPanel.mTopWidget:getContentSize()
	    local newHeight = getGoldFightPosition_LU().y - topInfoPanelSize.height - getGoldFightPosition_LD().y
	    local newPosY = newHeight/2 + getGoldFightPosition_LD().y - self.mRootWidget:getChildByName("Panel_Window"):getContentSize().height/2
	    self.mRootWidget:getChildByName("Panel_Window"):setAnchorPoint(cc.p(0.5, 0.5))
	    local panelSize = self.mRootWidget:getChildByName("Panel_Window"):getContentSize()
	    local curPosX = self.mRootWidget:getChildByName("Panel_Window"):getPositionX()
	    self.mRootWidget:getChildByName("Panel_Window"):setPositionX(curPosX + panelSize.width/2)
		self.mRootWidget:getChildByName("Panel_Window"):setPositionY(newPosY + panelSize.height/2)
	end
	doAdapter()

end

function HorseAndGunWindow:Destroy()
	self.mTopRoleInfoPanel:destroy()
	self.mTopRoleInfoPanel = nil

	GUIEventManager:unregister("itemInfoChanged", self.onItemInfoChanged)
	GUIEventManager:unregister("roleBaseInfoChanged", self.onItemInfoChanged)

	if self.mSchedulerHandler then
		local scheduler = cc.Director:getInstance():getScheduler()
		scheduler:unscheduleScriptEntry(self.mSchedulerHandler)
		self.mSchedulerHandler = nil
	end

	if self.mCurSelectedEquipAnimNode then
		self.mCurSelectedEquipAnimNode:Destroy()
		self.mCurSelectedEquipAnimNode = nil
	end

	if self.mCurSelectedEquipLevelAnimNode then
		self.mCurSelectedEquipLevelAnimNode:destroy()
		self.mCurSelectedEquipLevelAnimNode = nil
	end

	self.mEquipIdTbl					=	{}
	self.mCurSelectedPageWidget			=	nil
	self.mCurSelectedEquipId			=	nil
	self.mCurSelectedEquipWidget		=	nil
	self.mCurSelcetedEquipLevel			=	nil
	self.mData 							= 	nil
	self.mRootWidget 					= 	nil
	self.mRootNode:removeFromParent(true)
	self.mRootNode = nil
	
	CommonAnimation.clearAllTextures()
end

function HorseAndGunWindow:onEventHandler(event)
	if event.mAction == Event.WINDOW_SHOW then
		self:Load(event)
		GUIWidgetPool:preLoadWidget("MountsGuns_ListCell", true)
		GUIWidgetPool:preLoadWidget("MountsGuns_Icon", true)
		EventSystem:PushEvent(Event.GUISYSTEM_DISABLEDRAW_HOMEWINDOW)
	elseif event.mAction == Event.WINDOW_HIDE then
		GUIWidgetPool:preLoadWidget("MountsGuns_ListCell", false)
		GUIWidgetPool:preLoadWidget("MountsGuns_Icon", false)
		self:Destroy()
		EventSystem:PushEvent(Event.GUISYSTEM_EABLEDRAW_HOMEWINDOW)
	end
end

return HorseAndGunWindow