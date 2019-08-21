-- Name: 	PveNoticeHelper
-- Func：	副本界面红点工具(内部)
-- Author: 	Wangsd
-- Date:	2016-6-14

PveNoticeHelper = {}

-- 判断章节是否有奖励可领
function PveNoticeHelper:isChapterRewardForGet(level, index)
	-- 关卡未开启
	if not globaldata:isChapterOpened(index, level) then
		return false
	end

	local chapterObj = globaldata.chapterList[level][index]
	local starRewardInfo = chapterObj:getKeyValue("mStarReward")
	local rewardCnt = nil
	if 1 == level then
		rewardCnt = 3
	elseif 2 == level then
		rewardCnt = 2
	end

	for i = 1, rewardCnt do
		local canGetReward = starRewardInfo[i][2]
		if 1 == canGetReward then -- 可领取
			return true
		end
	end
end