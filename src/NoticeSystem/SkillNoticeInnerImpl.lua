-- Name: 	SkillNoticeInnerImpl
-- Func：	技能界面红点实现(内部)
-- Author: 	wangshengdong
-- Date:	2016-7-13

local window = nil

SkillNoticeInnerImpl = {}

-- 刷新
function SkillNoticeInnerImpl:doUpdate()
	window = GUISystem:GetWindowByName("HeroSkillWindow")

	if window.mRootNode then
		
		-- 装备按钮
		self:doUpdate_16003()

		-- 强化按钮
		self:doUpdate_16004()

		-- 技能按钮
		self:doUpdate_16002()

		-- 左侧列表
		self:doUpdate_16001()
	end
end

-- 装备按钮
function SkillNoticeInnerImpl:doUpdate_16003()
	local heroId 		= window.mHeroIdTbl[window.mCurSelectedHeroIndex]
	if SkillNoticeHelper:isHeroCanGetEquip(heroId) then
		window.mRootWidget:getChildByName("Image_Notice_16003"):setVisible(true)
	else
		window.mRootWidget:getChildByName("Image_Notice_16003"):setVisible(false)
	end
end

-- 强化按钮
function SkillNoticeInnerImpl:doUpdate_16004()
	local heroId 		= window.mHeroIdTbl[window.mCurSelectedHeroIndex]
	if SkillNoticeHelper:isHeroEquipCanLevelUp(heroId) then
		window.mRootWidget:getChildByName("Image_Notice_16004"):setVisible(true)
	else
		window.mRootWidget:getChildByName("Image_Notice_16004"):setVisible(false)
	end
end

-- 技能按钮
function SkillNoticeInnerImpl:doUpdate_16002()
	local heroId 		= window.mHeroIdTbl[window.mCurSelectedHeroIndex]
	if HeroNoticeHelper:isHeroIdCanDoSkillUpdateFunc(heroId) then
		window.mRootWidget:getChildByName("Image_Notice_16002"):setVisible(true)
	else
		window.mRootWidget:getChildByName("Image_Notice_16002"):setVisible(false)
	end
end

-- 左侧列表
function SkillNoticeInnerImpl:doUpdate_16001()
	for i = 1, #window.mHeroIdTbl do
		local heroId = window.mHeroIdTbl[i]
		if SkillNoticeHelper:isHeroCanGetEquip(heroId) or SkillNoticeHelper:isHeroEquipCanLevelUp(heroId) or HeroNoticeHelper:isHeroIdCanDoSkillUpdateFunc(heroId) then
			window.mHeroIconList[i]:getChildByName("Image_Notice_16001"):setVisible(true)
		else
			window.mHeroIconList[i]:getChildByName("Image_Notice_16001"):setVisible(false)
		end
	end
end