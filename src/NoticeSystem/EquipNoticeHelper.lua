-- Name: 	EquipNoticeHelper
-- Func：	装备界面红点工具(内部)
-- Author: 	wangshengdong
-- Date:	2016-1-28

EquipNoticeHelper = {}

EquipNoticeHelper.level = 6

-- 获取英雄对象
function EquipNoticeHelper:findHeroById(heroId)
	return globaldata:findHeroById(heroId)
end

-- 判断装备是否能强化
function EquipNoticeHelper:isEquipCanDoQianghua(heroId)
	if globaldata.level < self.level then
		return false
	end
	local heroObj = self:findHeroById(heroId)
	local heroLevel = heroObj.level
	local equipList = heroObj.equipList
	for i = 1, #equipList do
		if equipList[i].type <= 6 then -- 不判断时装
			local result = self:isSingleEquipCanDoQianghua(heroId, i)
			if result then
				return result
			end
		end
	end

	return false
end

-- 判断某一件装备能否强化
function EquipNoticeHelper:isSingleEquipCanDoQianghua(heroId, index)
	if globaldata.level < self.level then
		return false
	end
	local heroObj = self:findHeroById(heroId)
	local heroLevel = heroObj.level
	local equipList = heroObj.equipList
	local equipObj = equipList[index]

	if heroLevel > equipObj.level then -- 级别满足
		local strengthGoodList = equipObj.strengthGoodList -- 判断材料
--		local result = true
		for i = 1, #strengthGoodList do
			local itemCnt = strengthGoodList[i].mCount
			local itemId = strengthGoodList[i].mId
			local itemType = strengthGoodList[i].mType

			if 6 == heroId then
				print("判断英雄:", heroId, "itemType:", itemType, "itemId:", itemId, "itemCnt:", itemCnt)
			end

			if 0 == itemType then -- 物品
				if itemCnt > globaldata:getItemOwnCount(itemId) then
				--	result = false
					return false
				end
				if 6 == heroId then
					print("判断英雄:", heroId, "需要物品ID:", itemId, "装备位置:", index, "需要数量:", itemCnt, "拥有数量:", globaldata:getItemOwnCount(itemId))
				end
			elseif 2 == itemType then -- 金币
				if itemCnt > globaldata.money then -- 金币不足
				--	result = false
					return false
				end
				if 6 == heroId then
					print("判断英雄:", heroId, "装备位置:", index, "需要金币数量:", itemCnt, "拥有金币数量:", globaldata.money)
				end
			end

		end
		return true
	else
		return false
	end
end

-- 判断装备是否能镶嵌
function EquipNoticeHelper:isEquipCanDoXiangqian(heroId)
	if globaldata.level < self.level then
		return false
	end
	local heroObj = self:findHeroById(heroId)
	local heroLevel = heroObj.level
	local equipList = heroObj.equipList
	for i = 1, #equipList do
		local result = self:isSingleEquipCanDoXiangqian(heroId, i)
		if result then
			return result
		end
	end

	return false
end

-- 判断某一件装备能否镶嵌
function EquipNoticeHelper:isSingleEquipCanDoXiangqian(heroId, equipIndex)
	if globaldata.level < self.level then
		return false
	end
	local heroObj = self:findHeroById(heroId)
	local heroLevel = heroObj.level
	local equipList = heroObj.equipList
	local equipObj = equipList[equipIndex]
	local diamondList = equipObj.diamondList
	for i = 1, #diamondList do
		if 0 == diamondList[i] then -- 此位置没有宝石
			local equipId = equipObj.id
			local equipData = DB_EquipmentConfig.getDataById(equipId)
			local needType = equipData.Type
			for j = 1, #globaldata.itemList[2] do
				local diamondData = DB_Diamond.getDataById(globaldata.itemList[2][j]:getKeyValue("itemId"))
				if diamondData.diamondType == needType then
					return true
				end
			end
		end
	end
	return false
end

-- 判断某一件装备某一个孔能否镶嵌
function EquipNoticeHelper:isSingleEquipCanDoXiangqianForOneSlot(heroId, equipIndex, slotIndex)
	if globaldata.level < self.level then
		return false
	end
	local heroObj = self:findHeroById(heroId)
	local heroLevel = heroObj.level
	local equipList = heroObj.equipList
	local equipObj = equipList[equipIndex]
	local diamondList = equipObj.diamondList
	
	if 0 == diamondList[slotIndex] then -- 此位置没有宝石
		local equipId = equipObj.id
		local equipData = DB_EquipmentConfig.getDataById(equipId)
		local needType = equipData.Type
		for j = 1, #globaldata.itemList[2] do
			local diamondData = DB_Diamond.getDataById(globaldata.itemList[2][j]:getKeyValue("itemId"))
			if diamondData.diamondType == needType then
				return true
			end
		end
	end
	
	return false
end

-- 判断装备是否能洗练
function EquipNoticeHelper:isEquipCanDoXilian(heroId)
	-- local heroObj = self:findHeroById(heroId)
	-- local heroLevel = heroObj.level
	-- local equipList = heroObj.equipList
	-- for i = 1, #equipList do
	-- 	local result = self:isSingleEquipCanDoXilian(heroId, i)
	-- 	if result then
	-- 		return result
	-- 	end
	-- end

	return false
end

local function getColorByTypeAndVal(propType, propVal)
	local colorData = DB_Refresh.getDataById(propType)
	local function doSplit(str)
		local index = string.find(str, ',')
		local length = string.len(str, ',')
		return tonumber(string.sub(str, 1, index-1)), tonumber(string.sub(str, index+1, length))
	end

	local function findColor()
		for i = 1, 5 do
			local valRange = colorData["area"..tostring(i)]
			local leftVal, rightVal = doSplit(valRange)
			if propVal>=leftVal and propVal<=rightVal then
				return i
			end
		end
	end

	return findColor()
end

-- 判断某种属性颜色
function EquipNoticeHelper:getEquipColorOfOneProp(propType, propVal, level)
	return getColorByTypeAndVal(propType, math.floor(propVal / level))
end

-- 判断某一件装备能否进行洗练(有能洗练的项且品质低于蓝色)
function EquipNoticeHelper:isSingleEquipCanDoXilian(heroId, equipIndex)
	-- local heroObj = self:findHeroById(heroId)
	-- local equipList = heroObj.equipList
	-- local equipObj = equipList[equipIndex]
	-- local equipLevel = equipObj.level

	-- local equipPropList = equipObj.growPropList

	-- local idx = 0
	-- for k, v in pairs(equipPropList) do
	-- 	if self:getEquipColorOfOneProp(k, v, equipLevel) > 3 then
	-- 		idx = idx + 1
	-- 	end
	-- end

	-- if idx > 0 then
	-- 	return true
	-- else
	-- 	return false
	-- end
	return false
end


