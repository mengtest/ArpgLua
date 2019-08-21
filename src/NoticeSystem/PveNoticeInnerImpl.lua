-- Name: 	PveNoticeInnerImpl
-- Func：	副本界面红点实现(内部)
-- Author: 	Wangsd
-- Date:	2016-6-14

local window = nil

local chapterCnt = 10

PveNoticeInnerImpl = {}

-- 刷新
function PveNoticeInnerImpl:doUpdate()
	window = GUISystem:GetWindowByName("PveEntryWindow")
	if window.mRootNode then
		for i = 1, 10 do
			if PveNoticeHelper:isChapterRewardForGet(window.mLevel, i) then
				window.mChapterWidgetList[i]:getChildByName("Image_Notice"):setVisible(true)
			else
				window.mChapterWidgetList[i]:getChildByName("Image_Notice"):setVisible(false)
			end
		end
	end
end