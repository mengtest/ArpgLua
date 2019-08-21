-- Name: 	BadgeNoticeInnerImpl
-- Func：	徽章界面红点实现(内部)
-- Author: 	wangshengdong
-- Date:	2016-7-13

local window = nil

BadgeNoticeInnerImpl = {}

-- 刷新
function BadgeNoticeInnerImpl:doUpdate()
	window = GUISystem:GetWindowByName("BadgeWindow")

	if window.mRootNode then
		-- 激活按钮
		self:doUpdate_18001()

		-- 宝石孔
		self:doUpdate_18004()
	end
end

-- 激活按钮
function BadgeNoticeInnerImpl:doUpdate_18001()
	local needOpenHoleIndex = window.mData.curBadgeIndex + 1 -- 当前需要开启的洞序号
	local holeInfo = DB_DiamondStar.getDataById(needOpenHoleIndex)
	if holeInfo then
		if holeInfo.Starcost > window.mData.starCnt then -- 不足
			window.mRootWidget:getChildByName("Image_Notice_18001"):setVisible(false)
		else -- 足够
			window.mRootWidget:getChildByName("Image_Notice_18001"):setVisible(true)
		end
	else
		window.mRootWidget:getChildByName("Image_Notice_18001"):setVisible(false)
	end
end

-- 宝石孔
function BadgeNoticeInnerImpl:doUpdate_18004()
	-- 宝石信息
	for i = 101, 120 do
		local parentNode = window.mRootWidget:getChildByName("Panel_Diamond_"..i)
		if window.mData.diamondList[i] then
			if 0 == window.mData.diamondList[i] then -- 开了没宝石
				local holeInfo = DB_DiamondStar.getDataById(i)
				local diamindList = globaldata.itemList[2]
				local newDiamondList = {}
				for j = 1, #diamindList do
					local diamondData = DB_Diamond.getDataById(diamindList[j]:getKeyValue("itemId"))
					local diamondType = diamondData.diamondType
					if holeInfo.Diamondtype1 == diamondType or holeInfo.Diamondtype2 == diamondType then
						table.insert(newDiamondList, j)
					end
				end
				if 0 == #newDiamondList then -- 没有合适的宝石
					parentNode:getChildByName("Image_Notice_18004"):setVisible(false)
				else -- 有合适的宝石
					parentNode:getChildByName("Image_Notice_18004"):setVisible(true)
				end

			else -- 开了有宝石
				local holeInfo = DB_DiamondStar.getDataById(i)
				local curDiamondInfo = DB_Diamond.getDataById(window.mData.diamondList[i])
				local diamindList = globaldata.itemList[2]
				for j = 1, #diamindList do
					local newDiamondInfo = DB_Diamond.getDataById(diamindList[j]:getKeyValue("itemId"))
					if newDiamondInfo.diamondType == holeInfo.Diamondtype1 or newDiamondInfo.diamondType == holeInfo.Diamondtype2 then
						if newDiamondInfo.Level > curDiamondInfo.Level then
							parentNode:getChildByName("Image_Notice_18004"):setVisible(true)
							break
						end
					end 
					parentNode:getChildByName("Image_Notice_18004"):setVisible(false)
				end
			end
		else -- 没开
			parentNode:getChildByName("Image_Notice_18004"):setVisible(false)
		end
	end 
end

-- 左右箭头
function BadgeNoticeInnerImpl:doUpdate_18002_18003()
	window = GUISystem:GetWindowByName("BadgeWindow")

	if window.mRootNode then
		-- 左红点
		local leftRedWidget = window.mRootWidget:getChildByName("Image_Notice_18002")
		leftRedWidget:setVisible(false)
		-- 右红点
		local rightRedWidget = window.mRootWidget:getChildByName("Image_Notice_18003")
		rightRedWidget:setVisible(false)
		for i = 101, 120 do
			local parentNode = window.mRootWidget:getChildByName("Panel_Diamond_"..i)
			local holeInfo = DB_DiamondStar.getDataById(i)
			if holeInfo.SystemID == window.mCurPageIndex - 1 then -- 左
				if parentNode:getChildByName("Image_Notice_18004"):isVisible() then
					leftRedWidget:setVisible(true)
				end
			elseif holeInfo.SystemID == window.mCurPageIndex + 1 then -- 右
				if parentNode:getChildByName("Image_Notice_18004"):isVisible() then
					rightRedWidget:setVisible(true)
				end
			end
		end
	end
end