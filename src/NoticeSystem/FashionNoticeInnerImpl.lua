-- Name: 	FashionNoticeInnerImpl
-- Func：	时装界面红点实现(内部)
-- Author: 	wangshengdong
-- Date:	2016-7-13

local window = nil

FashionNoticeInnerImpl = {}

-- 刷新
function FashionNoticeInnerImpl:doUpdate()
	window = GUISystem:GetWindowByName("HorseAndGunWindow")

	if window.mRootNode then

		-- 解锁按钮
		self:doUpdate_17002()

		-- 升级按钮
		self:doUpdate_17003()

		-- 升级按钮
		self:doUpdate_17004()

		-- 左侧列表
		self:doUpdate_17001()

		-- 页签
		self:doUpdate_17010_17020()
	end
end

-- 解锁按钮
function FashionNoticeInnerImpl:doUpdate_17002()
	if FashionNoticeHelper:isFashionIdCanGet(window.mCurSelectedEquipId) then
		window.mRootWidget:getChildByName("Image_Notice_17002"):setVisible(true)
	else
		window.mRootWidget:getChildByName("Image_Notice_17002"):setVisible(false)
	end
end

-- 升级按钮
function FashionNoticeInnerImpl:doUpdate_17003()
	if FashionNoticeHelper:isFashionCanDoLevelUp(window.mCurSelectedEquipId) then
		window.mRootWidget:getChildByName("Image_Notice_17003"):setVisible(true)
	else
		window.mRootWidget:getChildByName("Image_Notice_17003"):setVisible(false)
	end
end

-- 进阶按钮
function FashionNoticeInnerImpl:doUpdate_17004()
	if FashionNoticeHelper:isFashionCanDoAdvance(window.mCurSelectedEquipId) then
		window.mRootWidget:getChildByName("Image_Notice_17004"):setVisible(true)
	else
		window.mRootWidget:getChildByName("Image_Notice_17004"):setVisible(false)
	end
end

-- 左侧列表
function FashionNoticeInnerImpl:doUpdate_17001()
	local listView = window.mRootWidget:getChildByName("ListView_List")
	local cellCnt = #listView:getItems()
	for i = 1, cellCnt do
		local cellWidget = listView:getItem(i-1)
		local fashionId = cellWidget:getTag()
		if FashionNoticeHelper:isFashionIdCanGet(fashionId) or 
			 FashionNoticeHelper:isFashionCanDoLevelUp(fashionId) or
			 	FashionNoticeHelper:isFashionCanDoAdvance(fashionId) then	
			cellWidget:getChildByName("Image_Notice_17001"):setVisible(true)
		else
			
			cellWidget:getChildByName("Image_Notice_17001"):setVisible(false)
		end
	end
end

-- 页签
function FashionNoticeInnerImpl:doUpdate_17010_17020()
	window.mRootWidget:getChildByName("Image_Notice_17010"):setVisible(false)
	window.mRootWidget:getChildByName("Image_Notice_17020"):setVisible(false)
	for i = 1, #window.mEquipIdTbl do
		local fashionId = window.mEquipIdTbl[i]
		local itemData = DB_FashionEquip.getDataById(fashionId)
		if 1 == itemData.type then
			if FashionNoticeHelper:isFashionIdCanGet(fashionId) or 
				 FashionNoticeHelper:isFashionCanDoLevelUp(fashionId) or
				 	FashionNoticeHelper:isFashionCanDoAdvance(fashionId) then	
				window.mRootWidget:getChildByName("Image_Notice_17010"):setVisible(true)
			end
		elseif 2 == itemData.type then
			if FashionNoticeHelper:isFashionIdCanGet(fashionId) or 
				 FashionNoticeHelper:isFashionCanDoLevelUp(fashionId) or
				 	FashionNoticeHelper:isFashionCanDoAdvance(fashionId) then	
				window.mRootWidget:getChildByName("Image_Notice_17020"):setVisible(true)
			end
		end
	end
end

