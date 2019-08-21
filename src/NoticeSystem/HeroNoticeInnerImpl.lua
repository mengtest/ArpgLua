-- Name: 	HeroNoticeInnerImpl
-- Func：	战队界面红点实现(内部)
-- Author: 	wangshengdong
-- Date:	2016-1-27

local window = nil

HeroNoticeInnerImpl = {}

-- 刷新
function HeroNoticeInnerImpl:doUpdate()
	window = GUISystem:GetWindowByName("HeroInfoWindow")

	if window.mRootNode then

		-- 左侧英雄头像
		self:doUpdate_5001()

		-- 培养按钮
		self:doUpdate_5011()

		-- 升品按钮
		self:doUpdate_5012()

		-- 升星按钮
		self:doUpdate_5013()

		-- 天赋按钮
		self:doUpdate_5021()
	end
end


-- 左侧英雄头像(5001)
function HeroNoticeInnerImpl:doUpdate_5001()
	for i = 1, #window.mHeroIdTbl do
		local heroId = window.mHeroIdTbl[i]
		if globaldata:isHeroIdExist(heroId) then -- 存在
		--	if HeroNoticeHelper:isHeroIdCanDoPeiyangFunc(heroId) or HeroNoticeHelper:isHeroIdCanDoSkillUpdateFunc(heroId) or HeroNoticeHelper:isHeroIdCanDoTalentUpdateFunc(heroId) then -- 能培养或者能升级
			if HeroNoticeHelper:isHeroIdCanDoPeiyangFunc(heroId) or HeroNoticeHelper:isHeroIdCanDoTalentUpdateFunc(heroId) then -- 能培养或者能升级
				window.mHeroIconList[i]:getChildByName("Image_Notice_5001"):setVisible(true)
			else
				window.mHeroIconList[i]:getChildByName("Image_Notice_5001"):setVisible(false)
			end
		else -- 不存在
			if HeroNoticeHelper:isHeroIdCanGet(heroId) then -- 能合成
				window.mHeroIconList[i]:getChildByName("Image_Notice_5001"):setVisible(true)
			else	
				window.mHeroIconList[i]:getChildByName("Image_Notice_5001"):setVisible(false)
			end
		end
	end
end

-- 培养页签(5011)
function HeroNoticeInnerImpl:doUpdate_5011()
	local heroId = window.mHeroIdTbl[window.mCurSelectedHeroIndex]
	if HeroNoticeHelper:isHeroIdCanDoPeiyangFunc(heroId) then
		window.mRootWidget:getChildByName("Image_Notice_5011"):setVisible(true)
	else
		window.mRootWidget:getChildByName("Image_Notice_5011"):setVisible(false)
	end
end

-- 升品按钮(5012)
function HeroNoticeInnerImpl:doUpdate_5012()
	local heroId = window.mHeroIdTbl[window.mCurSelectedHeroIndex]
	if HeroNoticeHelper:isHeroIdCanDoShengpinFunc(heroId) then
		window.mRootWidget:getChildByName("Image_Notice_5012"):setVisible(true)
	else
		window.mRootWidget:getChildByName("Image_Notice_5012"):setVisible(false)
	end
end

-- 升星按钮(5013)
function HeroNoticeInnerImpl:doUpdate_5013()
	local heroId = window.mHeroIdTbl[window.mCurSelectedHeroIndex]
	if HeroNoticeHelper:isHeroIdCanDoShengxingFunc(heroId) then
		window.mRootWidget:getChildByName("Image_Notice_5013"):setVisible(true)
	else
		window.mRootWidget:getChildByName("Image_Notice_5013"):setVisible(false)
	end
end

-- 天赋按钮(5013)
function HeroNoticeInnerImpl:doUpdate_5021()
	local heroId = window.mHeroIdTbl[window.mCurSelectedHeroIndex]
	if HeroNoticeHelper:isHeroIdCanDoTalentUpdateFunc(heroId) then
		window.mRootWidget:getChildByName("Image_Notice_5021"):setVisible(true)
	else
		window.mRootWidget:getChildByName("Image_Notice_5021"):setVisible(false)
	end
end