-- Name: 	LadderLoadingWindow
-- Func：	天梯加载
-- Author:	lichuan
-- Data:	15-9-8
require "GUISystem/Widget/OlPvpLoadPanel"

GOING_IN  = 1
GOING_OUT = 0

local LadderLoadingWindow = 
{
	mName             = "LadderLoadingWindow",
	mRootNode         = nil,
	mRootWidget       = nil,
}

function LadderLoadingWindow:Load(event)
	self.mRootNode = cc.Node:create()
	GUISystem:GetRootNode():addChild(self.mRootNode)
		-- 层级高于一切窗口
	self.mRootNode:setLocalZOrder(GUISYS_ZORDER_LOADINGWINDOW)
	self:InitLayout(event)
end

function LadderLoadingWindow:InitLayout(event)
	self.mRootWidget = GUIWidgetPool:createWidget("Tianti_Loading")
	self.mRootNode:addChild(self.mRootWidget)
	self.mLoadPanel = OlPvpLoadPanel.new()
	self.mRootWidget:addChild(self.mLoadPanel,10)

	self.mVsAni = AnimManager:createAnimNode(8050)
	self.mLoadPanel.mWidget:getChildByName("Panel_Aniamtion"):addChild(self.mVsAni:getRootNode(), 100)
	self.mVsAni:play("fight_vs_1",false,handler(self,self.VsFinish1))


	local heroIdArr = {}

	for i=1,3 do
		local id = globaldata:getBattleFormationInfoByIndexAndKey(i, "id")
		table.insert(heroIdArr,id) 
	end

	for i=1,3 do
		local id = globaldata:getBattleEnemyFormationInfoByIndexAndKey(i, "id")
		table.insert(heroIdArr,id) 
	end

	for i = 1,6 do
		local id = heroIdArr[i]

		local heroConfigData = DB_HeroConfig.getDataById(id)
		--原画
		local picId          = heroConfigData.PicID
		local picData		 = DB_ResourceList.getDataById(picId)
		local picUrl		 = picData.Res_path1
		local cell  		 = nil

		if i < 4 then 
			cell = self.mRootWidget:getChildByName(string.format("Panel_Self_%d",i))
		else
			cell = self.mRootWidget:getChildByName(string.format("Panel_Enemy_%d",i - 3))
		end
		cell:getChildByName(string.format("Image_HeroPic_%d",id)):setVisible(true)
		cell:getChildByName(string.format("Image_HeroPic_%d",id)):loadTexture(picUrl)
	end

	self:leftCellAnimation(GOING_IN)
	self:rightCellAnimation(GOING_IN)
end

function LadderLoadingWindow:VsFinish1(selfAni)
	selfAni:play("fight_vs_2",true)
end

local leftIndex = 1

function LadderLoadingWindow:leftCellAnimation(inOrOut)
	local cell    = self.mRootWidget:getChildByName(string.format("Panel_Self_%d",leftIndex))
	local cellPos = cc.p(cell:getPosition())
	local cellSize= cell:getContentSize()
	local isEnd   = false

	if inOrOut == GOING_OUT then 
		cellPos.y = 0 - cellSize.height
	end


	local function runBegin()
		leftIndex = leftIndex + 1
		if inOrOut == GOING_IN then
			cell:setPositionY(getGoldFightPosition_LU().y + cellSize.height)
		end		

		if leftIndex < 4 then
			self:leftCellAnimation(inOrOut) 
		else 
			leftIndex = 1
			isEnd = true 
		end
	end

	local function runEnd()
		if inOrOut == GOING_OUT and isEnd == true then
			--EventSystem:PushEvent(Event.GUISYSTEM_HIDE_LADDERLOADINGWINDOW)	
		end
	end

	local actBegin = cc.CallFunc:create(runBegin)
	local actDelay = cc.DelayTime:create(0.1 * leftIndex)
	local actMove  = cc.MoveTo:create(0.2,cellPos)
	local actEnd   = cc.CallFunc:create(runEnd)

	cell:runAction(cc.Sequence:create(actBegin,actDelay,actMove,actEnd))
end

local rightIndex = 1
local finishCnt  = 0
local enterPvP   = false

function LadderLoadingWindow:rightCellAnimation(inOrOut)
	local cell    = self.mRootWidget:getChildByName(string.format("Panel_Enemy_%d",rightIndex))
	local cellPos = cc.p(cell:getPosition())
	local cellSize= cell:getContentSize()
	

	if inOrOut == GOING_OUT then 
		cellPos.y = getGoldFightPosition_LU().y + cellSize.height
	end


	local function runBegin()
		rightIndex = rightIndex + 1
		if inOrOut == GOING_IN then
			cell:setPositionY(0 - cellSize.height)
		end		

		if rightIndex < 4 then
			self:rightCellAnimation(inOrOut) 
		else 
			rightIndex = 1
		end
	end

	local function runEnd()
		if inOrOut == GOING_OUT then
			finishCnt = finishCnt + 1
			if finishCnt == 3 then
				finishCnt = 0
				EventSystem:PushEvent(Event.GUISYSTEM_HIDE_LADDERLOADINGWINDOW)	
			end
		elseif inOrOut == GOING_IN then
			finishCnt = finishCnt + 1
			if finishCnt == 3 then
				finishCnt = 0
				if globaldata.olpvpType == 0 or globaldata.olpvpType == 3 then
					OnlinePvpManager:OnPreEnterPVP(self.pvpmapId)
				else
					OnlinePvpManager:OnPreEnterPVPForMore(self.pvpmapId)
				end
			end
		end
	end

	local actBegin = cc.CallFunc:create(runBegin)
	local actDelay = cc.DelayTime:create(0.1 * rightIndex)
	local actMove  = cc.MoveTo:create(0.2,cellPos)
	local actEnd   = cc.CallFunc:create(runEnd)

	cell:runAction(cc.Sequence:create(actBegin,actDelay,actMove,actEnd))
end

function LadderLoadingWindow:WindowGoOut()
	if self.mVsAni then
		self.mVsAni:play("fight_vs_3",false)
	end
	self:leftCellAnimation(GOING_OUT)
	self:rightCellAnimation(GOING_OUT)	
end

function LadderLoadingWindow:setPercentLoad(index,percent)
	if globaldata.olpvpType == 1 or globaldata.olpvpType == 2 then
		self.mLoadPanel:setPercent3v3ByIndex(index,percent)
	else
		self.mLoadPanel:setPercentByIndex(index,percent)
	end
end

function LadderLoadingWindow:Destroy()
	self.mRootWidget   = nil

	if self.mRootNode then
		self.mRootNode:removeFromParent(true)
		self.mRootNode = nil
	end

	leftIndex  = 1
	rightIndex = 1
	finishCnt  = 0

	CommonAnimation.clearAllTextures()
end

function LadderLoadingWindow:onEventHandler(event)
	if event.mAction == Event.WINDOW_SHOW then
		self:Load(event)
	elseif event.mAction == Event.WINDOW_HIDE then
		self:Destroy()
	end
end

return LadderLoadingWindow