-- Name: 	FashionNoticeHelper
-- Func：	时装界面红点工具(内部)
-- Author: 	wangshengdong
-- Date:	2016-7-13

FashionNoticeHelper = {}

local function getWindow()
	return GUISystem:GetWindowByName("HorseAndGunWindow")
end

-- 判断某个时装能获得
function FashionNoticeHelper:isFashionIdCanGet(fashionId)
	local window = getWindow()
	if window:findItemById(fashionId) then -- 已经拥有
		return false
	else
		local itemData = DB_FashionEquip.getDataById(fashionId)
		if globaldata:getItemOwnCount(itemData.Itemid) >= 1 then -- 足够
			return true
		else
			return false
		end
	end
end

-- 判断某个时装能升级
function FashionNoticeHelper:isFashionCanDoLevelUp(fashionId)
	local window = getWindow()
	if window:findItemById(fashionId) then -- 已经拥有
		local itemObj = window:findItemById(fashionId)
		local itemData = DB_FashionEquip.getDataById(fashionId)
		if 5 == itemObj.mLevel then -- 已经最高级
			return false
		elseif 4 == itemObj.mLevel then
			if globaldata:getItemOwnCount(itemData.Itemid) >= itemObj.equipUpdateItemCnt and globaldata:getItemOwnCount(itemData.Itemid_senior) >= itemObj.equipUpdateMoneyCnt then
				return true
			else
				return false
			end
		else
			if globaldata:getItemOwnCount(itemData.Itemid) >= itemObj.equipUpdateItemCnt and globaldata.money >= itemObj.equipUpdateMoneyCnt then
				return true
			else
				return false
			end
		end
	else
		return false
	end
end

-- 判断某个时装能进阶
function FashionNoticeHelper:isFashionCanDoAdvance(fashionId)
	local window = getWindow()
	if window:findItemById(fashionId) then -- 已经拥有
		local itemObj = window:findItemById(fashionId)
		if itemObj.equipCurSkillPoint >= itemObj.equipMaxSkillPoint then
			return true
		else
			return false
		end
	else
		return false
	end
end