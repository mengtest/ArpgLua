-- Name: 	LoadingWindow
-- Func：	伙伴窗口
-- Author:	Johny

local eventCount = 6

local LoadingWindow = 
{
	mName				=	"LoadingWindow",
	mRootNode			=	nil,
	mRootWidget			=	nil,
}

-----------------成员变量-------------------
local curResIdx = 1
local FRAME_LIST = {"res/image/loading/loading_bg_1.jpg", "res/image/loading/loading_bg_2.jpg"}
local textTable = {756,757,758,759,760,761,762,763,764,765,766,767}
local spineList = {2,12,21,22,23,24}
local POS_ROLE = cc.p(700, 80)
local POS_LOADING = cc.p(900,80)
----------------------------------------------

local function nextLoadingImage()
	curResIdx = curResIdx + 1
	if curResIdx > #FRAME_LIST then
	   curResIdx = 1
	end
end

local function getLoadingtext()
	local num = #textTable
	local index = math.random(1,num)
	return textTable[index]
end

function LoadingWindow:Release()

end

function LoadingWindow:Load(Event)
	cclog("=====LoadingWindow:Load=====begin")
	self.mRootNode = cc.Node:create()
	-- 层级高于一切窗口
	self.mRootNode:setLocalZOrder(GUISYS_ZORDER_LOADINGWINDOW)
	GUISystem:GetRootNode():addChild(self.mRootNode)
	--
	-- 载入背景
	local function loadBG()
		local _curImg = FRAME_LIST[curResIdx]
		self.mRootWidget = GUIWidgetPool:createWidget("Loading_1")
		self.mRootWidget:getChildByName("Image_1"):loadTexture(_curImg)
	end
	loadBG()
	self.mRootWidget:getChildByName("Label_3"):setPosition(cc.p(getGoldFightPosition_Middle().x,getGoldFightPosition_RD().y+100))
	self.mRootWidget:getChildByName("Label_3"):setString(getDictionaryText(getLoadingtext()))
	self.mRootNode:addChild(self.mRootWidget)
	nextLoadingImage()

	-- 载入动画
	local function loadAni()
		if not self.mRootNode then return end
		local _sz = self.mRootWidget:getContentSize()
		local _resDB = DB_ResourceList.getDataById(525)
		self.mLoading = CommonAnimation.createSpine_common(_resDB.Res_path2, _resDB.Res_path1)
	    self.mLoading:setLocalZOrder(100)
	    self.mLoading:setPosition(POS_LOADING)
	    self.mRootWidget:addChild(self.mLoading)
	    self.mLoading:setAnimation(0, "loading", true)
	   	-----
	    self.mLoadingShadow = SpineShadowSprite.new()
	    self.mLoadingShadow:initWithSpine(self.mLoading, 0)
	    self.mLoadingShadow:setPosition(POS_LOADING)
	    self.mRootWidget:addChild(self.mLoadingShadow)
	end
	SpineDataCacheManager:applyForAddSpineDataCache(loadAni)

    local function loadSpine()
    	if not self.mRootNode then return end
	    local _rand = math.random(1, #spineList)
	    local _json, _atlas, _scale = globaldata:getSimpleSpineDataByHeroIdx(spineList[_rand])
	    self.mSpine = CommonAnimation.createSpine_common(_json, _atlas)
	    self.mSpine:setScale(_scale*0.75)
	    self.mSpine:setLocalZOrder(100)
	    self.mSpine:setPosition(POS_ROLE)
	    self.mRootWidget:addChild(self.mSpine)
	    self.mSpine:setAnimation(0, "run", true)
	    -----
	    self.mSpineShadow = SpineShadowSprite.new()
	    self.mSpineShadow:initWithSpine(self.mSpine, 0)
	    self.mSpineShadow:setPosition(POS_ROLE)
	    self.mRootWidget:addChild(self.mSpineShadow)
    end
    SpineDataCacheManager:applyForAddSpineDataCache(loadSpine)

    local function loadBiaoYu()
    	-- 添加标语
		local byWidget = GUIWidgetPool:createWidget("Loading_HealthyGame")
		byWidget:setAnchorPoint(cc.p(0, 0))
		byWidget:setPosition(cc.p(getGoldFightPosition_LD().x, getGoldFightPosition_LD().y))
		self.mRootNode:addChild(byWidget,10)
    end
    loadBiaoYu()
    -- 处理跳转到的窗口所需要的特殊处理
    self:handleSpecialEvent(Event)

	cclog("=====LoadingWindow:Load=====end")
end

function LoadingWindow:handleSpecialEvent(_event)
	local _nextWinName = _event.mData[1]
	if _nextWinName == "ArenaWindow" then
	   local function hideSelf()
	   	  self:Destroy()
	   end
	   nextTick_frameCount(hideSelf, 1)
	end
	_event.mData = nil
end

function LoadingWindow:Destroy()
	if not self.mRootNode then return end
	cclog("=====LoadingWindow:Destroy=====")
	if self.mSpineShadow then
	   self.mSpineShadow:destroy()
	   self.mSpineShadow = nil
	end
	if self.mLoadingShadow then
	   self.mLoadingShadow:destroy()
	   self.mLoadingShadow = nil
	end
	self.mRootNode:removeFromParent(true)
	self.mRootNode = nil
end

function LoadingWindow:onEventHandler(event)
	if event.mAction == Event.WINDOW_SHOW then
		self:Load(event)
	elseif event.mAction == Event.WINDOW_HIDE then
		self:Destroy()
	end
end

return LoadingWindow

