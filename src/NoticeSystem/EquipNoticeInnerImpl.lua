-- Name: 	EquipNoticeInnerImpl
-- Func：	装备界面红点实现(内部)
-- Author: 	wangshengdong
-- Date:	2016-1-28

local window = nil

EquipNoticeInnerImpl = {}

-- 刷新
function EquipNoticeInnerImpl:doUpdate()
	window = GUISystem:GetWindowByName("EquipInfoWindow")

	-- 左侧英雄头像
	self:doUpdate_6001()

	-- 强化页签
	self:doUpdate_6010()

	-- 装备强化按钮
	self:doUpdate_6011()

	-- 一键强化按钮
	self:doUpdate_6012()

	-- 镶嵌页签
--	self:doUpdate_6020()

	-- 镶嵌装备
--	self:doUpdate_6021()

	-- 一键镶嵌
--	self:doUpdate_6022()

	-- 宝石孔(All)
--  self:doUpdate_DiamondSlot()

	-- 洗练页签
--	self:doUpdate_6030()

	-- 洗练装备
--	self:doUpdate_6031()
end

-- 左侧英雄头像(6001)
function EquipNoticeInnerImpl:doUpdate_6001()
	window = GUISystem:GetWindowByName("EquipInfoWindow")
	for i = 1, #window.mHeroIdTbl do
		local heroId = window.mHeroIdTbl[i]
	--	if EquipNoticeHelper:isEquipCanDoQianghua(heroId) or EquipNoticeHelper:isEquipCanDoXiangqian(heroId) or EquipNoticeHelper:isEquipCanDoXilian(heroId) then
		if EquipNoticeHelper:isEquipCanDoQianghua(heroId) or EquipNoticeHelper:isEquipCanDoXilian(heroId) then
			window.mHeroIconList[i]:getChildByName("Image_Notice_6001"):setVisible(true)
		else
			window.mHeroIconList[i]:getChildByName("Image_Notice_6001"):setVisible(false)
		end
	end
end

-- 强化页签(6010)
function EquipNoticeInnerImpl:doUpdate_6010()
	window = GUISystem:GetWindowByName("EquipInfoWindow")
	local heroId = window.mHeroIdTbl[window.mCurSelectedHeroIndex]
	if EquipNoticeHelper:isEquipCanDoQianghua(heroId) then
		window.mRootWidget:getChildByName("Image_Notice_6010"):setVisible(true)
	else
		window.mRootWidget:getChildByName("Image_Notice_6010"):setVisible(false)
	end
end

-- 装备强化按钮(6011)
function EquipNoticeInnerImpl:doUpdate_6011()
	window = GUISystem:GetWindowByName("EquipInfoWindow")
	local heroId = window.mHeroIdTbl[window.mCurSelectedHeroIndex]
	local equipWidgetList = window.mQianghuaWidgetList
	for i = 1, #equipWidgetList do
		if EquipNoticeHelper:isSingleEquipCanDoQianghua(heroId, i) then
			equipWidgetList[i]:getChildByName("Image_Notice_6011"):setVisible(true)
		else
			equipWidgetList[i]:getChildByName("Image_Notice_6011"):setVisible(false)
		end
	end
end

-- 一键强化按钮(6012)
function EquipNoticeInnerImpl:doUpdate_6012()
	window = GUISystem:GetWindowByName("EquipInfoWindow")
	local heroId = window.mHeroIdTbl[window.mCurSelectedHeroIndex]
	if EquipNoticeHelper:isEquipCanDoQianghua(heroId) then
		window.mRootWidget:getChildByName("Image_Notice_6012"):setVisible(true)
	else
		window.mRootWidget:getChildByName("Image_Notice_6012"):setVisible(false)
	end
end

-- 镶嵌页签(6020)
function EquipNoticeInnerImpl:doUpdate_6020()
	window = GUISystem:GetWindowByName("EquipInfoWindow")
	local heroId = window.mHeroIdTbl[window.mCurSelectedHeroIndex]
	if EquipNoticeHelper:isEquipCanDoXiangqian(heroId) then
		window.mRootWidget:getChildByName("Image_Notice_6020"):setVisible(true)
	else
		window.mRootWidget:getChildByName("Image_Notice_6020"):setVisible(false)
	end
end

-- 镶嵌装备(6021)
function EquipNoticeInnerImpl:doUpdate_6021()
	window = GUISystem:GetWindowByName("EquipInfoWindow")
	local heroId = window.mHeroIdTbl[window.mCurSelectedHeroIndex]
	local equipWidgetList = window.mXiangqianWidgetList
	for i = 1, #equipWidgetList do
		if EquipNoticeHelper:isSingleEquipCanDoXiangqian(heroId, i) then
			equipWidgetList[i]:getChildByName("Image_Notice_6021"):setVisible(true)
		else
			equipWidgetList[i]:getChildByName("Image_Notice_6021"):setVisible(false)
		end
	end
end

-- 一键镶嵌(6022)
function EquipNoticeInnerImpl:doUpdate_6022()
	window = GUISystem:GetWindowByName("EquipInfoWindow")
	local heroId = window.mHeroIdTbl[window.mCurSelectedHeroIndex]
	local equipWidget = window.mXiangqianEquipWidget
	if equipWidget then
		if EquipNoticeHelper:isSingleEquipCanDoXiangqian(heroId, equipWidget:getTag()) then
			window.mRootWidget:getChildByName("Image_Notice_6022"):setVisible(true)
		else
			window.mRootWidget:getChildByName("Image_Notice_6022"):setVisible(false)
		end
	else
		window.mRootWidget:getChildByName("Image_Notice_6022"):setVisible(false)
	end
end

-- 宝石孔(All)
function EquipNoticeInnerImpl:doUpdate_DiamondSlot()
	window = GUISystem:GetWindowByName("EquipInfoWindow")
	-- 宝石孔1
	self:doUpdate_6023()

	-- 宝石孔2
	self:doUpdate_6024()

	-- 宝石孔3
	self:doUpdate_6025()

	-- 宝石孔4
	self:doUpdate_6026()

	-- 宝石孔5
	self:doUpdate_6027()
end

-- 宝石孔1(6023)
function EquipNoticeInnerImpl:doUpdate_6023()
	local heroId = window.mHeroIdTbl[window.mCurSelectedHeroIndex]
	local equipWidget = window.mXiangqianEquipWidget
	if equipWidget then
		if EquipNoticeHelper:isSingleEquipCanDoXiangqianForOneSlot(heroId, equipWidget:getTag(), 1) then
			window.mRootWidget:getChildByName("Image_Notice_6023"):setVisible(true)
		else
			window.mRootWidget:getChildByName("Image_Notice_6023"):setVisible(false)
		end
	else
		window.mRootWidget:getChildByName("Image_Notice_6023"):setVisible(false)
	end
end

-- 宝石孔2(6024)
function EquipNoticeInnerImpl:doUpdate_6024()
	local heroId = window.mHeroIdTbl[window.mCurSelectedHeroIndex]
	local equipWidget = window.mXiangqianEquipWidget
	if equipWidget then
		if EquipNoticeHelper:isSingleEquipCanDoXiangqianForOneSlot(heroId, equipWidget:getTag(), 2) then
			window.mRootWidget:getChildByName("Image_Notice_6024"):setVisible(true)
		else
			window.mRootWidget:getChildByName("Image_Notice_6024"):setVisible(false)
		end
	else
		window.mRootWidget:getChildByName("Image_Notice_6024"):setVisible(false)
	end
end

-- 宝石孔3(6025)
function EquipNoticeInnerImpl:doUpdate_6025()
	local heroId = window.mHeroIdTbl[window.mCurSelectedHeroIndex]
	local equipWidget = window.mXiangqianEquipWidget
	if equipWidget then
		if EquipNoticeHelper:isSingleEquipCanDoXiangqianForOneSlot(heroId, equipWidget:getTag(), 3) then
			window.mRootWidget:getChildByName("Image_Notice_6025"):setVisible(true)
		else
			window.mRootWidget:getChildByName("Image_Notice_6025"):setVisible(false)
		end
	else
		window.mRootWidget:getChildByName("Image_Notice_6025"):setVisible(false)
	end
end

-- 宝石孔4(6026)
function EquipNoticeInnerImpl:doUpdate_6026()
	local heroId = window.mHeroIdTbl[window.mCurSelectedHeroIndex]
	local equipWidget = window.mXiangqianEquipWidget
	if equipWidget then
		if EquipNoticeHelper:isSingleEquipCanDoXiangqianForOneSlot(heroId, equipWidget:getTag(), 4) then
			window.mRootWidget:getChildByName("Image_Notice_6026"):setVisible(true)
		else
			window.mRootWidget:getChildByName("Image_Notice_6026"):setVisible(false)
		end
	else
		window.mRootWidget:getChildByName("Image_Notice_6026"):setVisible(false)
	end
end

-- 宝石孔5(6027)
function EquipNoticeInnerImpl:doUpdate_6027()
	local heroId = window.mHeroIdTbl[window.mCurSelectedHeroIndex]
	local equipWidget = window.mXiangqianEquipWidget
	if equipWidget then
		if EquipNoticeHelper:isSingleEquipCanDoXiangqianForOneSlot(heroId, equipWidget:getTag(), 5) then
			window.mRootWidget:getChildByName("Image_Notice_6027"):setVisible(true)
		else
			window.mRootWidget:getChildByName("Image_Notice_6027"):setVisible(false)
		end
	else
		window.mRootWidget:getChildByName("Image_Notice_6027"):setVisible(false)
	end
end

-- 洗练页签
function EquipNoticeInnerImpl:doUpdate_6030()
	window = GUISystem:GetWindowByName("EquipInfoWindow")
	local heroId = window.mHeroIdTbl[window.mCurSelectedHeroIndex]
	if EquipNoticeHelper:isEquipCanDoXilian(heroId) then
		window.mRootWidget:getChildByName("Image_Notice_6030"):setVisible(true)
	else
		window.mRootWidget:getChildByName("Image_Notice_6030"):setVisible(false)
	end
end

-- 洗练装备
function EquipNoticeInnerImpl:doUpdate_6031()
	window = GUISystem:GetWindowByName("EquipInfoWindow")
	local heroId = window.mHeroIdTbl[window.mCurSelectedHeroIndex]
	local equipWidgetList = window.mXilianWidgetList
	for i = 1, #equipWidgetList do
		if EquipNoticeHelper:isSingleEquipCanDoXilian(heroId, i) then
			equipWidgetList[i]:getChildByName("Image_Notice_6031"):setVisible(true)
		else
			equipWidgetList[i]:getChildByName("Image_Notice_6031"):setVisible(false)
		end
	end
end


