-- Name: 	HomeNoticeInnerImpl
-- Func：	主城界面红点实现(内部)
-- Author: 	wangshengdong
-- Date:	2016-1-29

local window = nil

HomeNoticeInnerImpl = {}

-- 刷新
function HomeNoticeInnerImpl:doUpdate()
	window = GUISystem:GetWindowByName("HomeWindow")

	if window.mRootNode then --窗口处于显示状态
		-- 战队
		self:doUpdate_5000()

		-- 强化
		self:doUpdate_6000()

		-- 技能
		self:doUpdate_16000()

		-- 学员按钮
		self:doUpdate_3103()
	else

	end
end

-- 战队
function HomeNoticeInnerImpl:doUpdate_5000()
	if HomeNoticeHelper:isHeroCanDoPeiyangOfSkillUpFunc() then
		window.mRootWidget:getChildByName("Image_Notice_5000"):setVisible(true)
	else
		window.mRootWidget:getChildByName("Image_Notice_5000"):setVisible(false)
	end
end

-- 强化
function HomeNoticeInnerImpl:doUpdate_6000()
	if HomeNoticeHelper:isHeroCanDoQianghuaForEquipFunc() then
		window.mRootWidget:getChildByName("Image_Notice_6000"):setVisible(true)
	else
		window.mRootWidget:getChildByName("Image_Notice_6000"):setVisible(false)
	end
end

-- 技能
function HomeNoticeInnerImpl:doUpdate_16000()
	if HomeNoticeHelper:isHeroSkillCanDoLevelUp() then
		window.mRootWidget:getChildByName("Image_Notice_16000"):setVisible(true)
	else
		window.mRootWidget:getChildByName("Image_Notice_16000"):setVisible(false)
	end
end

-- 学员按钮
function HomeNoticeInnerImpl:doUpdate_3103()
	if HomeNoticeHelper:isHeroCanDoPeiyangOfSkillUpFunc() or HomeNoticeHelper:isHeroSkillCanDoLevelUp() or HomeNoticeHelper:isHeroCanDoQianghuaForEquipFunc() then
		window.mRootWidget:getChildByName("Image_Notice_3103"):setVisible(true)
	else
		window.mRootWidget:getChildByName("Image_Notice_3103"):setVisible(false)
	end
end