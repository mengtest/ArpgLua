-- Name: 	HeroNoticeHelper
-- Func：	战队界面红点工具(内部)
-- Author: 	wangshengdong
-- Date:	2016-1-27

HeroNoticeHelper = {}

-- 判断英雄是否能进行培养操作
function HeroNoticeHelper:isHeroIdCanDoPeiyangFunc(heroId)
	if self:isHeroIdExist(heroId) then
		if self:isHeroIdCanDoShengpinFunc(heroId) then		-- 升品
			return true
		elseif self:isHeroIdCanDoShengxingFunc(heroId) then   -- 升星
			return true
		end
	else
		if self:isHeroIdCanGet(heroId) then -- 能合成
			return true
		end
	end

	return false
end

-- 判断英雄是否能合成
function HeroNoticeHelper:isHeroIdCanGet(heroId)
	-- 碎片信息
	local heroData = DB_HeroConfig.getDataById(heroId)
	local fragmentId     = heroData.Fragment

	-- 获取碎片数量
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

	-- 获取需要数量
	local function getFragmentInfo(heroId)
		local chipInfo = globaldata.heroChipsInfo
		if chipInfo then
			for i=1, #chipInfo do
				if heroId == chipInfo[i].heroId then 
					return chipInfo[i].chipCnt
				end
			end
		end
		return 10
	end
	local needCnt	  = getFragmentInfo(heroId)

	if fragmentCnt >= needCnt then
		return true
	else 
		return false
	end
end

-- 判断英雄是否存在
function HeroNoticeHelper:isHeroIdExist(heroId)
	return globaldata:isHeroIdExist(heroId)
end

-- 获取英雄对象
function HeroNoticeHelper:findHeroById(heroId)
	return globaldata:findHeroById(heroId)
end

-- 判断英雄是否能进行升品操作
function HeroNoticeHelper:isHeroIdCanDoShengpinFunc(heroId)
	local heroObj 	  = self:findHeroById(heroId)

	if heroObj then
		local result      = true

		if 0 == heroObj.isMaxAdvancedLv then
			return false
		end

		for i = 1, #heroObj.advancedCostList do
			if 2 ~= heroObj.advancedCostList[i].itemType then -- 物品
				local val1 = globaldata:getItemOwnCount(heroObj.advancedCostList[i].itemId)
				local val2 = heroObj.advancedCostList[i].itemNum
				if val1 >= val2 then

				else
					result = false
				end
			else  -- 金币
				if heroObj.advancedCostList[i].itemNum > globaldata.money then
					result = false
				end
			end
		end	
		return result
	end
	return false
end

-- 判断英雄是否能进行升星操作
function HeroNoticeHelper:isHeroIdCanDoShengxingFunc(heroId)
	-- 碎片信息
	local heroData 		 = DB_HeroConfig.getDataById(heroId)
	local fragmentId     = heroData.Fragment

	-- 获取碎片数量
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

	local heroObj 	  = self:findHeroById(heroId)
	if heroObj then
		if 12 == heroObj.quality then -- 已进化至顶级
			return false
		end

		local needCnt	  = heroObj.chipCount

		if fragmentCnt >= needCnt then
			return true
		else 
			return false
		end
	else
		return false
	end
end

-- 判断英雄是否能进行技能升级操作
function HeroNoticeHelper:isHeroIdCanDoSkillUpdateFunc(heroId)
	if self:isHeroIdExist(heroId) then -- 有英雄
		local heroObj = self:findHeroById(heroId)
		local heroLevel = heroObj.level
		local skillList = heroObj.skillList
		for i = 1, #skillList do
			if 1 == skillList[i].mSkillType then
				if 1 == skillList[i].mSkillIndex then
					if heroLevel > skillList[i].mSkillLevel and skillList[i].mPrice <= globaldata.money then -- 金钱和级别均满足
						return true
					end
				end
			else
				if heroLevel > skillList[i].mSkillLevel and skillList[i].mPrice <= globaldata.money then -- 金钱和级别均满足
					return true
				end
			end
		end
	else -- 没英雄
		return false
	end
	return false
end

-- 判断英雄是否能进行天赋加点操作
function HeroNoticeHelper:isHeroIdCanDoTalentUpdateFunc(heroId)
	if self:isHeroIdExist(heroId) then -- 有英雄
		local heroObj = self:findHeroById(heroId)
		if heroObj.talentPointCount > 0 then
			return true
		end
	else -- 没英雄
		return false
	end
	return false
end