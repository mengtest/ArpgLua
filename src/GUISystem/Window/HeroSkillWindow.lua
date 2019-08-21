-- Name: 	HeroSkillWindow
-- Func：	英雄技能界面
-- Author:	Wangsd
-- Data:	16-6-12

local function getHeroSkillDescFunc(heroId, skillIndex, heroLevel)
	local _infoDB = DB_HeroWeapon.getDataById(heroId)
	local txt_id = _infoDB["SkillText" .. skillIndex]
	local effect_id = _infoDB["Skill" .. skillIndex]
	local _effectDB = DB_Weapon_Skill.getDataById(effect_id)
	local text = DB_Text.getDataById(txt_id).Text_CN
	local level = heroLevel
	local des_text = text


	if skillIndex == 3 or skillIndex == 5 or skillIndex == 7 then
		if level < skillIndex then
				level = skillIndex
		end

		des_text = string.format("%s #06ff00+%d%%#",text,(level-_effectDB.Param3+1)*_effectDB.Param2/10)
	elseif skillIndex == 9 then
		if level < skillIndex then
				level = skillIndex
		end
		des_text = string.format("%s #06ff00+%d%%#",text,(level-_effectDB.Param2+1)*_effectDB.Param1/10)
	elseif skillIndex == 4  then
		if _effectDB.Param1 == 0 then return text end 
		local skill_name_id = DB_SkillEssence.getDataById(_effectDB.Param1).Name
		local skill_name = DB_Text.getDataById(skill_name_id).Text_CN

		des_text = string.format(text, "#ffff6c" .. skill_name .. "# ")
	elseif skillIndex == 8 then
		if _effectDB.Param1 == 0 then return text end 
		local skill_name_id = DB_SkillEssence.getDataById(_effectDB.Param1).Name
		local skill_name = DB_Text.getDataById(skill_name_id).Text_CN

		des_text = string.format(text, "#ffff6c" .. skill_name .. "# ",_effectDB.Param2)
	end

	if heroLevel < skillIndex then
		return string.gsub(string.gsub(des_text,"ffff6c","ffffff"),"06ff00","ffffff")
	else
		return des_text
	end
end

local bottomHeight 	= 288 -- 下边距
local topHeight 	= 288 -- 上边距
local marginCell 	= 10 -- 间隙
local cellHeight 	= 86 -- 格子大小

HeroSkillWindow = 
{
	mName 							=	"HeroSkillWindow",
	mRootNode						=	nil,
	mRootWidget						=	nil,
	mTopRoleInfoPanel				=	nil,	-- 顶部人物信息面板
	mCurSelectedHeroIndex 			=	nil,
	mCallFuncAfterDestroy			=	nil,
	-----------------------------------------------------------
	mHeroIconListScrollingAnimNode	=	nil,	-- 滑动特效
	mHeroIconListSelectedAnimNode	=	nil,	-- 选中特效
	mHeroIdTbl 						=	{},		-- 英雄Id数组
	mSchedulerEntry 				=	nil,	-- 定时器
	mHeroIconList					=	{},
	mWeaponAnimNode					=	nil,	-- 武器特效
}

function HeroSkillWindow:Load(event)
	if self.mRootNode then
		self.mRootNode:setVisible(true)
	return end

	self.mRootNode = cc.Node:create()
	GUISystem:GetRootNode():addChild(self.mRootNode)

	GUIEventManager:registerEvent("autoSkillUpdate", self, self.onSkillAutoUpdate)
	GUIEventManager:registerEvent("itemInfoChanged", self, self.updateHeroInfo)
	GUIEventManager:registerEvent("roleBaseInfoChanged", self, self.updateHeroInfo)

	-- 预加载大图
	local function preloadTexture()
		TextureSystem:loadPlist_iconskill()
	end
	preloadTexture()

	NetSystem.mNetManager:RegisterPacketHandler(PacketTyper._PTYPE_SC_HERO_WEAPON_UPDATE, handler(self, self.onRequestDoWeaponUpdate))

	--初始化界面
	self:InitLayout()	

	-- 创建滑动控件
	self:createScrollViewWidget()

	-- 载入英雄
	self:loadAllHero()
end

-- 更新所测滑条
function HeroSkillWindow:updateHeroIconTbl()
	if not self.mRootWidget then
		return
	end
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
			self.mHeroIconList[i]:getChildByName("Image_Group"):loadTexture("hero_herolist_group"..heroData.HeroGroup..".png", 1)

			if 1 == heroData.QualityB then
				self.mHeroIconList[i]:getChildByName("Image_SuperHero"):loadTexture("hero_herolist_super_1.png", 1)
			--	local animNode = AnimManager:createAnimNode(8065)
			--	self.mHeroIconList[i]:getChildByName("Panel_SuperHero_Animation"):addChild(animNode:getRootNode(), 100)
			--	animNode:play("hero_list_superhero", true)
			else
				self.mHeroIconList[i]:getChildByName("Image_SuperHero"):loadTexture("hero_herolist_super_0.png", 1)
			end
		end

		
	--	local imgId = heroData.IconID
	--	local imgName = DB_ResourceList.getDataById(imgId).Res_path1
		self.mHeroIconList[i]:getChildByName("Image_HeroList_HeroIcon"):loadTexture("hero_herolist_hero_"..heroId..".png", 1)
		-- 级别

		local heroObj = globaldata:findHeroById(heroId)
		if heroObj then -- 如果存在
			print("英雄id:", heroId, "等级信息:", heroObj.level)
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
		
			ShaderManager:ResumeColor(self.mHeroIconList[i]:getChildByName("Image_HeroList_HeroIcon"):getVirtualRenderer())

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
			ShaderManager:Disabled(self.mHeroIconList[i]:getChildByName("Image_HeroList_HeroIcon"):getVirtualRenderer())
			self.mHeroIconList[i]:getChildByName("Panel_HeroLevel_1"):setVisible(false)
			self.mHeroIconList[i]:getChildByName("Panel_HeroLevel_2"):setVisible(false)

			-- 品阶
			self.mHeroIconList[i]:getChildByName("Image_bg"):loadTexture("hero_herolist_cell_bg_0.png", 1)
		end
	end
end

-- 刷新英雄界面
function HeroSkillWindow:updateHeroInfo()
	-- 刷新英雄宝物信息
	self:updateHeroWeapon()

	-- 刷新英雄技能信息
	self:updateHeroSKill()

	-- 刷新红点
	SkillNoticeInnerImpl:doUpdate()
end

-- 刷新英雄宝物信息
function HeroSkillWindow:updateHeroWeapon()
	local heroId 		= self.mHeroIdTbl[self.mCurSelectedHeroIndex]
	local weaponData 	= DB_HeroWeapon.getDataById(heroId)
	local heroObj 	= globaldata:findHeroById(heroId)
	local nameId 	= weaponData.Name

	if self.mWeaponAnimNode then
		self.mWeaponAnimNode:destroy()
		self.mWeaponAnimNode = nil
	end

	if heroObj.weapon then

		if heroObj.weapon.mLevel < 3 then
			
		elseif heroObj.weapon.mLevel >= 3 and heroObj.weapon.mLevel < 6 then
			-- 特效
			self.mWeaponAnimNode = AnimManager:createAnimNode(weaponData.SkillWeaponAnimationID)
			self.mRootWidget:getChildByName("Panel_Animation_Weapon"):addChild(self.mWeaponAnimNode:getRootNode(), 100)
			self.mWeaponAnimNode:play("skill_weapon_1", true)
		elseif heroObj.weapon.mLevel >= 6 and heroObj.weapon.mLevel < 10 then
			-- 特效
			self.mWeaponAnimNode = AnimManager:createAnimNode(weaponData.SkillWeaponAnimationID)
			self.mRootWidget:getChildByName("Panel_Animation_Weapon"):addChild(self.mWeaponAnimNode:getRootNode(), 100)
			self.mWeaponAnimNode:play("skill_weapon_2", true)
		elseif heroObj.weapon.mLevel >= 10 then
			-- 特效
			self.mWeaponAnimNode = AnimManager:createAnimNode(weaponData.SkillWeaponAnimationID)
			self.mRootWidget:getChildByName("Panel_Animation_Weapon"):addChild(self.mWeaponAnimNode:getRootNode(), 100)
			self.mWeaponAnimNode:play("skill_weapon_3", true)
		end


		self.mRootWidget:getChildByName("Panel_Qianghua"):setVisible(true)
		self.mRootWidget:getChildByName("Panel_None"):setVisible(false)

		local btnWidget = self.mRootWidget:getChildByName("Button_Qianghua")
		local boolValue = true

		-- 名字
		self.mRootWidget:getChildByName("Label_NameLevel"):setString(getDictionaryText(nameId).." Lv."..tostring(heroObj.weapon.mLevel))

		-- 需要金钱
		local labelWidget = self.mRootWidget:getChildByName("Panel_Qianghua"):getChildByName("Panel_Gold"):getChildByName("Label_Gold")
		labelWidget:setString(heroObj.weapon.mMoney)
		if globaldata.money >= heroObj.weapon.mMoney then
			labelWidget:setColor(cc.c3b(162,255,169))
		else
			labelWidget:setColor(cc.c3b(255,162,162))
			boolValue = false
		end

		-- 需要物品数量
		labelWidget = self.mRootWidget:getChildByName("Panel_Qianghua"):getChildByName("Panel_Item1"):getChildByName("Label_Num_Stroke")
		labelWidget:setString(globaldata:getItemOwnCount(weaponData.ItemId).."/"..heroObj.weapon.mItemCnt)
		if globaldata:getItemOwnCount(weaponData.ItemId) >= heroObj.weapon.mItemCnt then
			labelWidget:setColor(cc.c3b(162,255,169))
		else
			labelWidget:setColor(cc.c3b(255,162,162))
			boolValue = false
		end

		-- 需要物品图标
		local parentNode = self.mRootWidget:getChildByName("Panel_Qianghua"):getChildByName("Panel_Item1"):getChildByName("Panel_Icon")
		parentNode:removeAllChildren()
		itemWidget = createItemWidget(weaponData.ItemId, "")
		parentNode:addChild(itemWidget)

		-- 物品来源
		MessageBox:showHowToGetMessage(itemWidget, 0, weaponData.ItemId)
		
		if boolValue then -- 可以强化
		--	ShaderManager:DoUIWidgetDisabled(btnWidget, false)
		--	btnWidget:setTouchEnabled(true)
			registerWidgetReleaseUpEvent(btnWidget, handler(self, self.requestDoWeaponUpdate))
		else -- 不可以强化
		--	ShaderManager:DoUIWidgetDisabled(btnWidget, true)
		--	btnWidget:setTouchEnabled(false)
			if globaldata.money >= heroObj.weapon.mMoney then
				MessageBox:showHowToGetMessage(btnWidget, 0, weaponData.ItemId)
			else
				local function xxx()
					MessageBox:showMessageBox1("金钱不足~")
				end
				registerWidgetReleaseUpEvent(btnWidget, xxx)
			end
		end

		ShaderManager:ResumeColor(self.mRootWidget:getChildByName("Image_WeaponIcon"):getVirtualRenderer())
	else
		self.mRootWidget:getChildByName("Panel_Qianghua"):setVisible(false)
		self.mRootWidget:getChildByName("Panel_None"):setVisible(true)

		-- 需要物品
		local parentNode = self.mRootWidget:getChildByName("Panel_None"):getChildByName("Panel_Item"):getChildByName("Panel_Icon")
		parentNode:removeAllChildren()
		local itemWidget = createItemWidget(weaponData.ItemId, "")
		parentNode:addChild(itemWidget)

		-- 物品来源
		MessageBox:showHowToGetMessage(itemWidget, 0, weaponData.ItemId)

		-- 需要数量
		local labelWidget = self.mRootWidget:getChildByName("Panel_None"):getChildByName("Panel_Item"):getChildByName("Label_Num_Stroke")
		local btnWidget = self.mRootWidget:getChildByName("Button_Get")
		labelWidget:setString(globaldata:getItemOwnCount(weaponData.ItemId).."/1")
		if globaldata:getItemOwnCount(weaponData.ItemId) >= 1 then -- 足够
			labelWidget:setColor(cc.c3b(162,255,169))
		--	ShaderManager:DoUIWidgetDisabled(btnWidget, false)
		--	btnWidget:setTouchEnabled(true)
			registerWidgetReleaseUpEvent(btnWidget, handler(self, self.requestDoWeaponUpdate))
		else -- 不足
			labelWidget:setColor(cc.c3b(255,162,162))
		--	ShaderManager:DoUIWidgetDisabled(btnWidget, true)
		--	btnWidget:setTouchEnabled(false)
			MessageBox:showHowToGetMessage(btnWidget, 0, weaponData.ItemId)
		end

		ShaderManager:ChangeColor(self.mRootWidget:getChildByName("Image_WeaponIcon"):getVirtualRenderer(), G_COLOR_VEC4.BLACK)

		-- 名字
		self.mRootWidget:getChildByName("Label_NameLevel"):setString(getDictionaryText(nameId).."(未拥有)")
	end

	-- 图片
	local iconId 	= weaponData.IconId
	local imgName 	= DB_ResourceList.getDataById(iconId).Res_path1
	self.mRootWidget:getChildByName("Image_WeaponIcon"):loadTexture(imgName)

	local curLevel = 0
	if heroObj.weapon then
		curLevel = heroObj.weapon.mLevel
	end

	-- 武器描述
	for i = 1, 10 do
		-- 移除所有子节点
		local parentNode = self.mRootWidget:getChildByName("Panel_Level_"..i)
		parentNode:getChildByName("Panel_Property"):removeAllChildren()
		-- 描述
		local textId = weaponData["SkillText"..i]
		local textData = DB_Text.getDataById(textId)
		local textStr = textData.Text_CN
	--	local textWidget = richTextCreate(parentNode:getChildByName("Panel_Property"), textStr, false, nil, false)
		local textWidget = richTextCreate(parentNode:getChildByName("Panel_Property"), getHeroSkillDescFunc(heroObj.id, i, curLevel), false, nil, false)
		local labelWidget = parentNode:getChildByName("Label_Level")

		if curLevel >= i then -- 满足等级
			-- 底图
			parentNode:getChildByName("Image_Bg"):loadTexture("skill_property_bg.png")
			-- 等级
			labelWidget:setColor(cc.c3b(255,244,73))
			-- 透明度
			textWidget:setOpacityInner(255)
			labelWidget:setOpacity(255)
		else
			-- 底图
			parentNode:getChildByName("Image_Bg"):loadTexture("skill_property_bg_no.png")
			-- 等级
			labelWidget:setColor(cc.c3b(255,255,255))
			-- 透明度
			textWidget:setOpacityInner(120)
			labelWidget:setOpacity(120)
		end
	end
end

-- 刷新英雄技能信息
function HeroSkillWindow:updateHeroSKill()
	-- 读表
	local heroId    =  self.mHeroIdTbl[self.mCurSelectedHeroIndex]
	local heroObj   = globaldata:findHeroById(heroId)
	local heroData 	= DB_HeroConfig.getDataById(heroId)

	-- 技能链表
	local skillList = heroObj.skillList

	-- 普通
		for i = 1, #skillList do
			local skillObj = skillList[i]
			if 1 == skillObj.mSkillType and 1 == skillObj.mSkillIndex then
				local skillData = DB_SkillEssence.getDataById(skillObj.mSkillId)
				local skillNameId = skillData.Name
				local skillName = getDictionaryText(skillNameId)
				local skillIconId = skillData.IconID
				local skillIcon = DB_ResourceList.getDataById(skillIconId).Res_path1
				-- 控件
				local skillIconWidget = self.mRootWidget:getChildByName(string.format("Panel_Attack_%d", skillObj.mSkillIndex)):getChildByName("Image_Icon")
				local skillBtnWidget = self.mRootWidget:getChildByName(string.format("Panel_Attack_%d", skillObj.mSkillIndex)):getChildByName("Button_Promote")
				local skillPriceWidget = self.mRootWidget:getChildByName(string.format("Panel_Attack_%d", skillObj.mSkillIndex)):getChildByName("Label_UpgradeCost_Stroke_0_34_69")
				-- 控件
				local skillInfoWidget0 = self.mRootWidget:getChildByName(string.format("Panel_Attack_%d", skillObj.mSkillIndex)):getChildByName("Label_NameLevel")
				local skillInfoWidget1 = self.mRootWidget:getChildByName(string.format("Panel_Attack_%d", skillObj.mSkillIndex)):getChildByName("Image_Upgrade")
				-- 锁头
				self.mRootWidget:getChildByName(string.format("Panel_Attack_%d", skillObj.mSkillIndex)):getChildByName("Image_Lock"):setVisible(false)
				-- 升级信息
				local skillUpInfoWidget = self.mRootWidget:getChildByName(string.format("Panel_Attack_%d", skillObj.mSkillIndex)):getChildByName("Panel_Upgrade")
				-- 等级
				if 1 == skillObj.mSkillIndex then
					local labelLevel = self.mRootWidget:getChildByName(string.format("Panel_Attack_%d", skillObj.mSkillIndex)):getChildByName("Label_Level")
					labelLevel:setVisible(true)
					labelLevel:setString(tostring(skillObj.mSkillLevel))
				end

				-- 信息
				skillIconWidget:setTouchEnabled(true)
				MessageBox:showSkillInfo(skillIconWidget, skillObj, heroId)

				local function updateSkillInfo()

					skillIconWidget:loadTexture(skillIcon, 1)
					
					-- 升级按钮
					if skillObj.mSkillLevel < heroObj.level and globaldata.money >= skillObj.mPrice then
						skillBtnWidget:setTouchEnabled(true)
						-- 价格
						skillPriceWidget:setString(string.format("%d", skillObj.mPrice))
						skillUpInfoWidget:setVisible(true)
					else
						skillBtnWidget:setTouchEnabled(false)
						skillUpInfoWidget:setVisible(false)
					end
					-- 级别
					self.mRootWidget:getChildByName(string.format("Panel_Attack_%d", skillObj.mSkillIndex)):getChildByName("Label_Level"):setString(tostring(skillObj.mSkillLevel))
				end
				if 1 == skillObj.mSkillIndex then
					updateSkillInfo()
				end
				
				local function onRequestDoSkillUpgrade(msgPacket)
					-- 扣钱
					globaldata.money = globaldata.money - skillObj.mPrice
					if globaldata.money < 0 then
						globaldata.money = 0
					end
					
					local skillId = msgPacket:GetInt()
					local skillType = msgPacket:GetChar()
					local skillIndex = msgPacket:GetChar()
					local skillSelected = msgPacket:GetChar()
					local skillLevel = msgPacket:GetInt()
					local skillCost = msgPacket:GetInt()

					for i = 1, #heroObj.skillList do
						if skillId == heroObj.skillList[i].mSkillId then
							heroObj.skillList[i].mSkillLevel = skillLevel
							heroObj.skillList[i].mPrice = skillCost
						end
					end

					-- 刷新
					self:updateHeroInfo()

					-- 刷红点
					HeroNoticeInnerImpl:doUpdate()
					
					GUISystem:hideLoading()
					
					-- 特效
					local animNode = AnimManager:createAnimNode(8006)
					local function xxx()
						animNode:destroy()
						animNode = nil
						GUISystem:enableUserInput()
					end
					self.mRootWidget:getChildByName(string.format("Panel_Attack_%d", skillObj.mSkillIndex)):getChildByName("Panel_SkillAnimation"):addChild(animNode:getRootNode(), 100)
					animNode:play("herolist_skill_update", false, xxx)
					GUISystem:disableUserInput()

					NetSystem.mNetManager:UnregisterPacketHandler(PacketTyper._PTYPE_SC_GET_SKILL_UPGRADE_REQUEST_)

					if SkillGuideOne:canGuide() then
						local guideBtn = self.mRootWidget:getChildByName("Button_AutoUpdate")
						local size = guideBtn:getContentSize()
						local pos = guideBtn:getWorldPosition()
						pos.x = pos.x - size.width/2
						pos.y = pos.y - size.height/2
						local touchRect = cc.rect(pos.x, pos.y, size.width, size.height)
						SkillGuideOne:step(5, touchRect)
					end
				end

				-- 请求升级技能
				local function requestDoSkillUpgrade()
					-- 查看金钱是否满足
					if globaldata.money < skillObj.mPrice then
						MessageBox:showMessageBox1("金钱不足~")
						return
					end

					NetSystem.mNetManager:RegisterPacketHandler(PacketTyper._PTYPE_SC_GET_SKILL_UPGRADE_REQUEST_, onRequestDoSkillUpgrade)
					local packet = NetSystem.mNetManager:GetSPacket()
		   			packet:SetType(PacketTyper._PTYPE_CS_GET_SKILL_UPGRADE_REQUEST_)
				    packet:PushInt(heroId)
				    packet:PushInt(skillObj.mSkillId)
				    packet:Send()
					GUISystem:showLoading()
				end
				if 1 == skillObj.mSkillIndex then
					registerWidgetReleaseUpEvent(skillBtnWidget, requestDoSkillUpgrade)
				end
			end
		end

	-- 先加锁
	for i = 1, 3 do
		self.mRootWidget:getChildByName("Panel_Skill_"..i):getChildByName("Image_Lock"):setVisible(true)
		self.mRootWidget:getChildByName("Panel_Skill_"..i):getChildByName("Label_Level"):setVisible(false)
		self.mRootWidget:getChildByName("Panel_Skill_"..i):getChildByName("Panel_Upgrade"):setVisible(false)
	end

	-- 主动
	for i = 1, #skillList do
		local skillObj = skillList[i]
		if 2 == skillObj.mSkillType then
			local skillData = DB_SkillEssence.getDataById(skillObj.mSkillId)
			local skillNameId = skillData.Name
			local skillName = getDictionaryText(skillNameId)
			local skillIconId = skillData.IconID
			local skillIcon = DB_ResourceList.getDataById(skillIconId).Res_path1
			-- 控件
			local skillIconWidget = self.mRootWidget:getChildByName(string.format("Panel_Skill_%d", skillObj.mSkillIndex)):getChildByName("Image_Icon")
			local skillBtnWidget = self.mRootWidget:getChildByName(string.format("Panel_Skill_%d", skillObj.mSkillIndex)):getChildByName("Button_Promote")
			local skillPriceWidget = self.mRootWidget:getChildByName(string.format("Panel_Skill_%d", skillObj.mSkillIndex)):getChildByName("Label_UpgradeCost_Stroke_0_34_69")
			-- 控件
			local skillInfoWidget0 = self.mRootWidget:getChildByName(string.format("Panel_Skill_%d", skillObj.mSkillIndex)):getChildByName("Label_NameLevel")
			local skillInfoWidget1 = self.mRootWidget:getChildByName(string.format("Panel_Skill_%d", skillObj.mSkillIndex)):getChildByName("Image_Upgrade")
			-- 锁头
			self.mRootWidget:getChildByName(string.format("Panel_Skill_%d", skillObj.mSkillIndex)):getChildByName("Image_Lock"):setVisible(false)
			-- 升级信息
			local skillUpInfoWidget = self.mRootWidget:getChildByName(string.format("Panel_Skill_%d", skillObj.mSkillIndex)):getChildByName("Panel_Upgrade")
			-- 等级
			self.mRootWidget:getChildByName(string.format("Panel_Skill_%d", skillObj.mSkillIndex)):getChildByName("Label_Level"):setVisible(true)

			-- 信息
			skillIconWidget:setTouchEnabled(true)
			MessageBox:showSkillInfo(skillIconWidget, skillObj, heroId)

			local function updateSkillInfo()
				skillIconWidget:loadTexture(skillIcon, 1)
				-- 升级按钮
				if skillObj.mSkillLevel < heroObj.level and globaldata.money >= skillObj.mPrice then
					skillBtnWidget:setTouchEnabled(true)
					-- 价格
					skillPriceWidget:setString(string.format("%d", skillObj.mPrice))
					skillUpInfoWidget:setVisible(true)
				else
					skillBtnWidget:setTouchEnabled(false)
					skillUpInfoWidget:setVisible(false)
				end
				-- 级别
				self.mRootWidget:getChildByName(string.format("Panel_Skill_%d", skillObj.mSkillIndex)):getChildByName("Label_Level"):setString(tostring(skillObj.mSkillLevel))
			end
			updateSkillInfo()
			
			local function onRequestDoSkillUpgrade(msgPacket)

				-- 扣钱
				globaldata.money = globaldata.money - skillObj.mPrice
				if globaldata.money < 0 then
					globaldata.money = 0
				end

				local skillId = msgPacket:GetInt()
				local skillType = msgPacket:GetChar()
				local skillIndex = msgPacket:GetChar()
				local skillSelected = msgPacket:GetChar()
				local skillLevel = msgPacket:GetInt()
				local skillCost = msgPacket:GetInt()

				for i = 1, #heroObj.skillList do
					if skillId == heroObj.skillList[i].mSkillId then
						heroObj.skillList[i].mSkillLevel = skillLevel
						heroObj.skillList[i].mPrice = skillCost
					end
				end

				-- 刷新
				self:updateHeroInfo()

				-- 刷红点
				HeroNoticeInnerImpl:doUpdate()

				GUISystem:hideLoading()

				-- 特效
				local animNode = AnimManager:createAnimNode(8006)
				local function xxx()
					animNode:destroy()
					animNode = nil
					GUISystem:enableUserInput()
				end
				self.mRootWidget:getChildByName(string.format("Panel_Skill_%d", skillObj.mSkillIndex)):getChildByName("Panel_SkillAnimation"):addChild(animNode:getRootNode(), 100)
				animNode:play("herolist_skill_update", false, xxx)
				GUISystem:disableUserInput()

				NetSystem.mNetManager:UnregisterPacketHandler(PacketTyper._PTYPE_SC_GET_SKILL_UPGRADE_REQUEST_)
			end

			-- 请求升级技能
			local function requestDoSkillUpgrade()
				-- 查看金钱是否满足
				if globaldata.money < skillObj.mPrice then
					MessageBox:showMessageBox1("金钱不足~")
					return
				end

				NetSystem.mNetManager:RegisterPacketHandler(PacketTyper._PTYPE_SC_GET_SKILL_UPGRADE_REQUEST_, onRequestDoSkillUpgrade)
				local packet = NetSystem.mNetManager:GetSPacket()
	   			packet:SetType(PacketTyper._PTYPE_CS_GET_SKILL_UPGRADE_REQUEST_)
			    packet:PushInt(heroId)
			    packet:PushInt(skillObj.mSkillId)
			    packet:Send()
				GUISystem:showLoading()
			end
			registerWidgetReleaseUpEvent(skillBtnWidget, requestDoSkillUpgrade)	
		end
	end

	-- 闪避
	local function updateDodgeSkill()
		local skillData = DB_SkillEssence.getDataById(heroData.Role_DodgeSkill)
		local skillNameId = skillData.Name
		local skillName = getDictionaryText(skillNameId)
		local skillIconId = skillData.IconID
		local skillIcon = DB_ResourceList.getDataById(skillIconId).Res_path1
		local skillIconWidget = self.mRootWidget:getChildByName("Panel_Career"):getChildByName("Image_Icon")

		local skillObj = skillObject:new()
		skillObj.mSkillId		=	heroData.Role_DodgeSkill	-- 技能ID
		skillObj.mSkillType		=	6	-- 技能类型
		skillObj.mSkillIndex 	= 	1	-- 技能序号
		skillObj.mSkillSelected	=	0 	-- 技能选择  0:选中 1:没选中
		skillObj.mSkillLevel	=	-1	-- 技能等级
		skillObj.mPrice			=	""	-- 价格

		-- 信息
		skillIconWidget:setTouchEnabled(true)
		MessageBox:showSkillInfo(skillIconWidget, skillObj, heroId)
		skillIconWidget:loadTexture(skillIcon, 1)

		if heroObj.level < 5 then
			self.mRootWidget:getChildByName("Panel_Career"):getChildByName("Image_Lock"):setVisible(true)
		else
			self.mRootWidget:getChildByName("Panel_Career"):getChildByName("Image_Lock"):setVisible(false)
		end
	end
	updateDodgeSkill()
end

-- 响应头像点击
function HeroSkillWindow:onHeroIconClicked(widget)
	
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

-- 请求专属武器升级
function HeroSkillWindow:requestDoWeaponUpdate(widget)
	local heroId 		= self.mHeroIdTbl[self.mCurSelectedHeroIndex]

	local packet = NetSystem.mNetManager:GetSPacket()
	packet:SetType(PacketTyper._PTYPE_CS_HERO_WEAPON_UPDATE)
	packet:PushInt(heroId)
	packet:Send()
	GUISystem:showLoading()
end

-- 专属武器升级回包
function HeroSkillWindow:onRequestDoWeaponUpdate(msgPacket)
	local heroId = msgPacket:GetInt()
	local heroObj = globaldata:findHeroById(heroId)
	if not heroObj.weapon then
		heroObj.weapon 				= 	heroWeaponObject:new()
		-- 播放特效
		local animNode = AnimManager:createAnimNode(8073)
		self.mRootWidget:getChildByName("Panel_Animation_Open"):addChild(animNode:getRootNode(), 100)
		animNode:play("skill_open")
	else
		local animNode = AnimManager:createAnimNode(8074)
		self.mRootWidget:getChildByName("Panel_Animation_Open"):addChild(animNode:getRootNode(), 100)
		animNode:play("skill_update", false)
	end
	heroObj.weapon.mId 			=	msgPacket:GetInt()
	heroObj.weapon.mLevel 		=	msgPacket:GetInt()
	heroObj.weapon.mMoney		=	msgPacket:GetInt()
	heroObj.weapon.mItemCnt 	=	msgPacket:GetInt()
	GUISystem:hideLoading()
	-- 刷新界面
	self:updateHeroInfo()
end

-- 载入英雄
function HeroSkillWindow:loadAllHero()

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
		local heroData = DB_HeroConfig.getDataById(i)
		if globaldata:isHeroIdExist(i) and 1 == heroData.Open then 
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


	local function insertHeroUnGet() -- 添加为拥有的英雄
		local tempHeroIdTbl = {}

		for i = 1, maxHeroCount do -- 不存在
			local heroData = DB_HeroConfig.getDataById(i)
			if not globaldata:isHeroIdExist(i) and 1 == heroData.Open then 
				table.insert(tempHeroIdTbl, i)
			end
		end

		local function isHeroIdCanGet(heroId) -- 判断英雄是否能合成
			-- 碎片信息
			local heroData = DB_HeroConfig.getDataById(heroId)
			local fragmentId     = heroData.Fragment

			local function getFragmentCnt(fragmentId)
				local itemList = globaldata:getItemList()
				if not itemList[1] then
					return 0
				end
				for k, v in pairs(itemList[1]) do
					if fragmentId == v:getKeyValue("itemId") then
						return v:getKeyValue("itemNum")
					end
				end
				return 0
			end
			local fragmentCnt = getFragmentCnt(fragmentId)
			local needCnt	  = 10

			local function getFragmentInfo(heroId)
				local chipInfo = globaldata.heroChipsInfo
				for i=1,#chipInfo do
					if heroId == chipInfo[i].heroId then 
						return chipInfo[i].chipCnt
					end
				end
				return 10
			end
			needCnt       = getFragmentInfo(heroId)

			return fragmentCnt >= needCnt 
		end

		-- -- 根据是否能合成排序
		-- local function sortFunc2(id1, id2)
		-- --	if isHeroIdCanGet(id1) then
		-- --		return true
		-- --	elseif isHeroIdCanGet(id2) then
		-- --		return false
		-- --	else
		-- --		return false
		-- --	end
		-- 	if isHeroIdCanGet(id1) and isHeroIdCanGet(id2) then -- 都能合成
		-- 		return true
		-- 	elseif isHeroIdCanGet(id1) and not  isHeroIdCanGet(id2) then-- 前一个合成
		-- 		return true
		-- 	elseif not isHeroIdCanGet(id1) and isHeroIdCanGet(id2) then-- 前一个合成
		-- 		return false
		-- 	elseif not isHeroIdCanGet(id1) and not isHeroIdCanGet(id2) then-- 都不能合成
		-- 		return false	
		-- 	end
		-- end
		-- table.sort(tempHeroIdTbl, sortFunc2)

		local function doSortForHeroCanGet() --能合成的排在前面
			local tempHeroIdTbl2 = {}
			for i = 1, #tempHeroIdTbl do
				if isHeroIdCanGet(tempHeroIdTbl[i]) then -- 能合成
					table.insert(tempHeroIdTbl2, tempHeroIdTbl[i])
				end
			end
			for i = 1, #tempHeroIdTbl do 
				if not isHeroIdCanGet(tempHeroIdTbl[i]) then -- 不能合成
					table.insert(tempHeroIdTbl2, tempHeroIdTbl[i])
				end
			end
			tempHeroIdTbl = tempHeroIdTbl2

			for i = 1, #tempHeroIdTbl do
				table.insert(self.mHeroIdTbl, tempHeroIdTbl2[i])
			end

		end
		doSortForHeroCanGet()
	end
--	insertHeroUnGet()

	-- 更新所测滑条
	self:updateHeroIconTbl()
	
	local function onAutoScrollStartFunc()
		GUISystem:disableUserInput()
	end
	self.mScrollViewWidget:registerAutoScrollStartFunc(onAutoScrollStartFunc)

	local function onAutoScrollStopFunc()
		-- 修正ScrollView位置
    	self:fixScrollViewPos()
    end
	self.mScrollViewWidget:registerAutoScrollStopFunc(onAutoScrollStopFunc)


	local function onScrollViewEvent(sender, evenType)
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

            -- 默认选中队长
			self:setLeaderSelected()

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

-- 修正ScrollView位置
function HeroSkillWindow:fixScrollViewPos()
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
		-- 显示英雄信息
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
	local curHeight = self.mScrollViewWidget:getInnerContainerSize().height - self.mRootWidget:getChildByName("ScrollView_HeroList"):getContentSize().height
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

-- 默认设置队长选中
function HeroSkillWindow:setLeaderSelected()
end

-- 窗口更新
function HeroSkillWindow:tick()
	-- 更新头像透明度
	self:updateHeroIconOpacity()
end

-- 更新头像透明度
function HeroSkillWindow:updateHeroIconOpacity()
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

-- 创建ScrollView
function HeroSkillWindow:createScrollViewWidget()
	self.mScrollViewWidget = ccui.ScrollView:create()
    self.mScrollViewWidget:setTouchEnabled(true)
    self.mScrollViewWidget:setContentSize(cc.size(159, 662))

    self.mRootWidget:getChildByName("ScrollView_HeroList"):setVisible(false)
  
  --   local function getHeroCount()
  --   	local cnt = 0
  --   	for i = 1, maxHeroCount do -- 存在
		-- 	local heroData = DB_HeroConfig.getDataById(i)
		-- 	if 1 == heroData.Open then 
		-- 		cnt = cnt + 1
		-- 	end
		-- end
		-- return cnt
  --   end
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

function HeroSkillWindow:InitLayout()
	self.mRootWidget = GUIWidgetPool:createWidget("Skill")
	self.mRootNode:addChild(self.mRootWidget)

	local function closeWindow()
		EventSystem:PushEvent(Event.GUISYSTEM_HIDE_HEROSKILLWINDOW)
	end

	self.mTopRoleInfoPanel = TopRoleInfoPanel:new()
	local topInfoPanel = self.mTopRoleInfoPanel:init(self.mRootNode,ROLE_TITLE_TYPE.TITLE_HEROSKILL, closeWindow)

	-- 适配
	local function doAdapter()
		local deltaX = 100
		-- 左侧滑动条
		local leftPanel = self.mRootWidget:getChildByName("Panel_Left")
		leftPanel:setPositionX(getGoldFightPosition_LD().x)

		-- 居中操作
		local topInfoPanelSize = self.mTopRoleInfoPanel.mTopWidget:getContentSize()
	    local newHeight = getGoldFightPosition_LU().y - topInfoPanelSize.height - getGoldFightPosition_LD().y
	    local newPosY = newHeight/2 + getGoldFightPosition_LD().y - self.mRootWidget:getChildByName("Panel_Right"):getContentSize().height/2
	    self.mRootWidget:getChildByName("Panel_Right"):setAnchorPoint(cc.p(0, 0.5))
	    local panelSize = self.mRootWidget:getChildByName("Panel_Right"):getContentSize()
		self.mRootWidget:getChildByName("Panel_Right"):setPositionX(getGoldFightPosition_RD().x - self.mRootWidget:getChildByName("Panel_Right"):getContentSize().width + deltaX)
		self.mRootWidget:getChildByName("Panel_Right"):setPositionY(newPosY + panelSize.height/2)
		self.mRootWidget:getChildByName("Panel_Right"):setOpacity(0)

		local function doFadeIn()
			local function onActEnd()
				-- 显示英雄信息
				self:updateHeroInfo()

				if SkillGuideOne:canGuide() then
					local guideBtn = self.mRootWidget:getChildByName("Panel_Attack_1"):getChildByName("Panel_Upgrade"):getChildByName("Button_Promote")
					local size = guideBtn:getContentSize()
					local pos = guideBtn:getWorldPosition()
					pos.x = pos.x - size.width/2
					pos.y = pos.y - size.height/2
					local touchRect = cc.rect(pos.x, pos.y, size.width, size.height)
					SkillGuideOne:step(4, touchRect)
				end

			end

			local tm = 0.25
			local act0 = cc.FadeIn:create(tm)
			local act1 = cc.MoveBy:create(tm, cc.p(-deltaX, 0))
			local act2 = cc.CallFunc:create(onActEnd)
			self.mRootWidget:getChildByName("Panel_Right"):runAction(cc.Sequence:create(cc.Spawn:create(act0, act1), act2))
		end
		doFadeIn()
	end
	doAdapter()

	registerWidgetReleaseUpEvent(self.mRootWidget:getChildByName("Button_Qianghua"), handler(self, self.requestDoWeaponUpdate))
	registerWidgetReleaseUpEvent(self.mRootWidget:getChildByName("Button_Get"), handler(self, self.requestDoWeaponUpdate))

	local function doAutoSkillUpdate()
		local packet = NetSystem.mNetManager:GetSPacket()
		packet:SetType(PacketTyper._PTYPE_CS_SKILL_AUTO_UPDATE)
		packet:PushInt(self.mHeroIdTbl[self.mCurSelectedHeroIndex])
		packet:Send()
		GUISystem:showLoading()
	end
	registerWidgetReleaseUpEvent(self.mRootWidget:getChildByName("Button_AutoUpdate"), doAutoSkillUpdate)
end

-- 自动升级技能
function HeroSkillWindow:onSkillAutoUpdate(index, skillLvUp, skillSelected)
	if skillLvUp or skillSelected then
		self:updateHeroInfo()
	end

	-- 显示特效
	local heroId    = self.mHeroIdTbl[self.mCurSelectedHeroIndex]
	local heroObj   = globaldata:findHeroById(heroId)
	local skillList = heroObj.skillList
	local skillObj  = skillList[index]

	if not skillObj then
		return
	end

	if skillLvUp then -- 技能升级
		if 1 == skillObj.mSkillType and 1 == skillObj.mSkillIndex then -- 普通
			-- 特效
			local animNode = AnimManager:createAnimNode(8006)
			self.mRootWidget:getChildByName(string.format("Panel_Attack_%d", skillObj.mSkillIndex)):getChildByName("Panel_SkillAnimation"):addChild(animNode:getRootNode(), 100)
			animNode:play("herolist_skill_update", false)
		elseif 2 == skillObj.mSkillType then -- 主动
			-- 特效
			local animNode = AnimManager:createAnimNode(8006)
			self.mRootWidget:getChildByName(string.format("Panel_Skill_%d", skillObj.mSkillIndex)):getChildByName("Panel_SkillAnimation"):addChild(animNode:getRootNode(), 100)
			animNode:play("herolist_skill_update", false)
		end
	end

	local function doSkillGuideOne_Stop()
		SkillGuideOne:stop()
	end
	SkillGuideOne:step(6, nil, doSkillGuideOne_Stop)
end


function HeroSkillWindow:destroyRootNode()
	cclog("=====HeroSkillWindow:destroyRootNode=====")
	if not self.mRootNode then return end
	self.mTopRoleInfoPanel:destroy()
	self.mTopRoleInfoPanel = nil

	if self.mWeaponAnimNode then
		self.mWeaponAnimNode:destroy()
		self.mWeaponAnimNode = nil
	end

	GUIEventManager:unregister("autoSkillUpdate", self.onSkillAutoUpdate)
	GUIEventManager:unregister("itemInfoChanged", self.updateHeroInfo)
	GUIEventManager:unregister("roleBaseInfoChanged", self.updateHeroInfo)

	if self.mHeroIconListScrollingAnimNode then
		self.mHeroIconListScrollingAnimNode:destroy()
		self.mHeroIconListScrollingAnimNode = nil
	end

	if self.mHeroIconListSelectedAnimNode then
		self.mHeroIconListSelectedAnimNode:destroy()
		self.mHeroIconListSelectedAnimNode = nil
	end

	if self.mSchedulerEntry then
		local scheduler = cc.Director:getInstance():getScheduler()
		scheduler:unscheduleScriptEntry(self.mSchedulerEntry)
		self.mSchedulerEntry = nil
	end

	self.mCurSelectedHeroIndex	=	nil

	self.mRootNode:removeFromParent(true)
	self.mRootNode = nil
	self.mRootWidget = nil

	self.mHeroIconList = {}
	---
	TextureSystem:unloadPlist_iconskill()
end

function HeroSkillWindow:Destroy()
	cclog("=====HeroSkillWindow:Destroy=====")
	self.mRootNode:setVisible(false)
	CommonAnimation.clearAllTextures()
end

function HeroSkillWindow:onEventHandler(event, func)
	if event.mAction == Event.WINDOW_SHOW then
		GUIWidgetPool:preLoadWidget("Hero_ListCell", true)
		self:Load(event)
		---------停止画主城镇界面
		EventSystem:PushEvent(Event.GUISYSTEM_DISABLEDRAW_HOMEWINDOW)
		self.mCallFuncAfterDestroy = func
	elseif event.mAction == Event.WINDOW_HIDE then
		GUIWidgetPool:preLoadWidget("Hero_ListCell", false)
		self:Destroy()
		-- 主城红点刷新
		HomeNoticeInnerImpl:doUpdate()
		---------开启画主城镇界面
		EventSystem:PushEvent(Event.GUISYSTEM_EABLEDRAW_HOMEWINDOW)
		if self.mCallFuncAfterDestroy then
			self.mCallFuncAfterDestroy()
			self.mCallFuncAfterDestroy = nil
		end
	end
end

return HeroSkillWindow