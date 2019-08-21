-- Name: 	AllHeroWindow
-- Func：	所有英雄窗口
-- Author:	lichuan
-- Data:	15-6-19

require("GUISystem/Window/AllHeroModel")

local curSelectedHeroIndex = nil

local bornPosY = 0

--==================================================TableView  Begin========================================================

local AllHeroTableView = {}

function AllHeroTableView:new(owner,listType)
	local o = 
	{
		mOwner			  	= 	owner,
		mRootNode 	      	=	nil,
		mType 		      	=	listType,
		mTableView	      	=	nil,
		mDataSource		  	= 	{},
		mLastIndex			=	nil,
		mCellSize			=   nil,
	}
	o = newObject(o, AllHeroTableView)
	return o
end

function AllHeroTableView:Destroy()
	self.mRootNode:removeFromParent(true)
	self.mRootNode   = nil
	self.mTableView  = nil
	self.mOwner      = nil
	self.mDataSource = {}
	self.mLastIndex	 = nil
	self.mCellSize	 = nil
end

function AllHeroTableView:init(rootNode)
	self.mRootNode   = rootNode
	-- 初始化数据源
	self:initTableView()
end

function AllHeroTableView:myModel()
	return self.mOwner.mModel
end

function AllHeroTableView:initTableView()
	self.mTableView = TableViewEx:new()

	local widget = GUIWidgetPool:createWidget("HeroWidget")
	self.mCellSize = widget:getContentSize()
	self.mCellSize.height = self.mCellSize.height + 40
	self.mTableView:setCellSize(self.mCellSize)
	self.mTableView:setCellCount(#self.mDataSource)


	self.mTableView:registerTableCellAtIndexFunc(handler(self, self.tableCellAtIndex))
	self.mTableView:registerTableCellTouchedFunc(handler(self, self.tableCellTouched))
	self.mTableView:registerScrollViewDidScrollFunc(handler(self, self.scrollViewDidScroll))

	contentSize = self.mRootNode:getContentSize()
	contentSize.height = widget:getContentSize().height + widget:getContentSize().height/3

	self.mTableView:init(contentSize, cc.p(0,0), 0)
	self.mRootNode:addChild(self.mTableView:getRootNode())

	self.mTableView:setWidthEx(self.mRootNode:getContentSize().width/2 - self.mCellSize.width/2)

	self.mTableView:setBounceable(false)
end

local tm = 0.05

function AllHeroTableView:scrollViewDidScroll()
	for i = 0, #self.mDataSource-1 do
		local cell = self.mTableView.mInnerContainer:cellAtIndex(i)
		if cell then
			local widget = cell:getChildByTag(1)
			local curPos = widget:getWorldPosition()
			local contentSize = widget:getContentSize()
			local curPosX = curPos.x + contentSize.width/2
			local deltaX = math.abs(curPosX - 1140/2)
			if deltaX > contentSize.width/2 then
				-- 向下运动
				widget:getChildByName("Panel_HeroIcon"):stopAllActions()
				widget:getChildByName("Panel_HeroIcon"):setPositionY(bornPosY)
				widget:getChildByName("Image_Arrow"):setVisible(false)
				widget:getChildByName("Image_Select"):setVisible(false)
			end
		end
	end

	for i = 0, #self.mDataSource-1 do
		local cell = self.mTableView.mInnerContainer:cellAtIndex(i)
		if cell then
			local widget = cell:getChildByTag(1)
			local curPos = widget:getWorldPosition()
			local contentSize = widget:getContentSize()
			local curPosX = curPos.x + contentSize.width/2
			local deltaX = math.abs(curPosX - 1140/2)
			if deltaX < contentSize.width/2 then
				if i ~= self.mLastIndex then
					-- 向上运动
					local contentSize = widget:getContentSize()
					local act0 = cc.MoveBy:create(tm, cc.p(0, contentSize.height/3 - 10))
					widget:getChildByName("Panel_HeroIcon"):runAction(act0)
					widget:getChildByName("Image_Arrow"):setVisible(true)
					widget:getChildByName("Image_Select"):setVisible(true)
					self.mLastIndex = i
					self:onCurIndex(i)
				end
			end
		end
	end
end

-- 当前激活的序列项
function AllHeroTableView:onCurIndex(index)
	self.mOwner.mSelectHeroId = self.mDataSource[index + 1]
	self.mOwner:UpdateHeroInfoPanel(self.mDataSource[index + 1])
end

function AllHeroTableView:tableCellAtIndex(table, index)
	local cell = table:dequeueCell()
	local heroItem = nil

	if nil == cell then
		cell = cc.TableViewCell:new()
		heroItem = GUIWidgetPool:createWidget("HeroWidget")
		heroItem:setTouchSwallowed(false)
		heroItem:setTag(1)
		cell:addChild(heroItem)
	else
		heroItem = cell:getChildByTag(1)
	end

	self:setCellLayOut(heroItem,index+1)

	return cell
end

function AllHeroTableView:tableCellTouched(table,cell)
	local cellCnt = cell:getIdx()
	local tvWidth = self.mRootNode:getContentSize().width
	self.mTableView.mInnerContainer:setContentOffset(cc.p(tvWidth/2 - self.mCellSize.width*cellCnt - self.mCellSize.width/2,0))

	AllHeroGuide:step(5,self.mOwner.mRootWidget:getChildByName("Button_GetHero"))

end

function AllHeroTableView:setCellLayOut(cell,index)
	local heroId      = self.mDataSource[index]
	--cell:getChildByName("Panel_Hero"):removeAllChildren()

	local widget = nil

	if globaldata:isHeroIdExist(heroId) then
		local heroObj = globaldata:findHeroById(heroId)
		local level	  = heroObj:getKeyValue("level")
		local star    = heroObj:getKeyValue("quality")
		local color   = heroObj:getKeyValue("advanceLevel")
		local exp     = heroObj:getKeyValue("exp")
		local expMax  = heroObj:getKeyValue("maxExp")

		cell:getChildByName("ProgressBar_EXP"):setPercent(exp/expMax*100)
		widget = createHeroIcon(heroId, level, star, color,cell:getChildByName("Panel_Hero"):getChildren()[1])		
		ShaderManager:DoUIWidgetDisabled(widget:getChildByName("Image_HeroHead"), false)   
	else
		local heroData = DB_HeroConfig.getDataById(heroId)
		local star   = heroData.Quality

		widget = createHeroIcon(heroId, 0, 0, 0,cell:getChildByName("Panel_Hero"):getChildren()[1])
		cell:getChildByName("ProgressBar_EXP"):setPercent(0)
		ShaderManager:DoUIWidgetDisabled(widget:getChildByName("Image_HeroHead"), true)   
	end

	widget:setTouchEnabled(false)
	widget:setPositionY(bornPosY)
	cell:setPositionY(13)
	cell:getChildByName("Panel_Hero"):addChild(widget)
end

function AllHeroTableView:UpdateTableView(cellCnt)
	self.mTableView:setCellCount(cellCnt)

	self.mTableView:reloadData()
	--[[local curOffset = self.mTableView.mInnerContainer:getContentOffset()
	local curHeight = self.mTableView.mInnerContainer:getContentSize().height
	self.mTableView:reloadData()
	self.mTableView.mInnerContainer:setContentOffset(cc.p(0,self.mTableView.mInnerContainer:getViewSize().height - self.mTableView.mInnerContainer:getContentSize().height))
	local height = self.mTableView.mInnerContainer:getContentSize().height
	curOffset.y = curOffset.y + (curHeight - height)
	self.mTableView.mInnerContainer:setContentOffset(curOffset)]]--

	self.mTableView.mInnerContainer:setContentOffset(cc.p(self.mRootNode:getContentSize().width/2 - self.mCellSize.width/2,0))
end


--==================================================Window Begin================================================================
local AllHeroWindow = 
{
	mName 				=	"AllHeroWindow",
	mRootNode 			= 	nil,
	mRootWidget 		=	nil,
	mTopRoleInfoPanel 	=	nil,
	mHeroPicPanel		=   nil,
	mHeroInfoPanel		= 	nil,
	------------------------------
	mBtnSwitch			=   nil,
	mPanelHeroList		=   nil,
	mProPertyPageArr	=   {},
	mPropertyPanelArr	=   {},
	mSchoolPageArr		=   {},
	------------------------------
	mHeroTV				=   nil,
	mLastClickedWidget 	=	nil,
	mPrePicShowed 		=	false,
	mSelectHeroId		=   nil,
	mUpdateFuncArr		=   {},
	mPropertyCurSel		=   nil,
	mSkillPanelArr		=   {},

	mModel              =   nil,
	mHeroInfoPanelPos   =   nil,
	mShowPic			=   true,

	mLastSpine			=   nil,
}

function AllHeroWindow:Release()

end

function AllHeroWindow:Load(event)
	cclog("=====AllHeroWindow:Load=====begin")

	GUIEventManager:registerEvent("battleTeamChanged", self, self.close)
	GUIEventManager:registerEvent("battleTeamChanged", self, self.refresh)
	GUIEventManager:registerEvent("equipChanged", self, self.refresh)
	GUIEventManager:registerEvent("combatChanged", self, self.refresh)
	GUIEventManager:registerEvent("updateJinHua", self, self.refresh)
	GUIEventManager:registerEvent("itemInfoChanged", self, self.refresh)
	GUIEventManager:registerEvent("heroAddSync", self, self.refresh)
	

	if event and event.mData then
		curSelectedHeroIndex = event.mData[1]
		preHeroId = event.mData[2]
	else
		curSelectedHeroIndex = nil
		preHeroId = 1990
	end
	self.mRootNode = cc.Node:create()
	GUISystem:GetRootNode():addChild(self.mRootNode)
	GUISystem:showLoading()
	self.mModel = AllHeroModel.new(self)
	self:InitLayout()
	GUISystem:hideLoading()

	TextureSystem:loadPlist_iconskill()

	cclog("=====AllHeroWindow:Load=====end")
end

function AllHeroWindow:close()
	local function doClose() -- 下一阵关闭，防止野指针导致崩溃，2015-5-6 by wangsd
		EventSystem:PushEvent(Event.GUISYSTEM_HIDE_ALLHEROWINDOW)
	end
	nextTick(doClose)
end

function AllHeroWindow:refresh()
	if self.mHeroTV ~= nil then 
		self.mHeroTV:setCellLayOut(self.mHeroTV.mTableView.mInnerContainer:cellAtIndex(self.mHeroTV.mLastIndex):getChildren()[1],self.mHeroTV.mLastIndex + 1)
		self:UpdateUseItemInfo()
		self:UpdateHeroInfoPanel(self.mSelectHeroId)
	end
end

function AllHeroWindow:InitLayout()
	self.mRootWidget = GUIWidgetPool:createWidget("NewHeroSelect") 
	self.mRootNode:addChild(self.mRootWidget)

	local function closeWindow()
		GUISystem:playSound("homeBtnSound")
		EventSystem:PushEvent(Event.GUISYSTEM_HIDE_ALLHEROWINDOW)

		AllHeroGuide:stop()
	end

	self.mTopRoleInfoPanel = TopRoleInfoPanel:new()
	local topInfoPanel = self.mTopRoleInfoPanel:init(self.mRootNode, closeWindow)

	self.mHeroPicPanel	 = self.mRootWidget:getChildByName("Panel_HeroPic")
	self.mHeroInfoPanel	 = self.mRootWidget:getChildByName("Panel_HeroInfo")
	self.mBtnSwitch		 = self.mRootWidget:getChildByName("Button_ToLess")
	self.mPanelHeroList  = self.mRootWidget:getChildByName("Panel_HeroList")

	self.mHeroPicPanel:setVisible(true)
	self.mHeroInfoPanel:setVisible(false)

	local function doAdapter()
		local postion = cc.p(self.mPanelHeroList:getPosition())
		local posY	  = getGoldFightPosition_LD().y + 5
		self.mPanelHeroList:setPositionY(posY)
		self.mRootWidget:getChildByName("Panel_SchoolList"):setPositionX(getGoldFightPosition_LD().x)

		local posX = getGoldFightPosition_RD().x
		local introSize = self.mRootWidget:getChildByName("Image_Introduce"):getContentSize()
		self.mRootWidget:getChildByName("Image_Introduce"):setPositionX(posX - introSize.width/2)
	end
	
	doAdapter()

	self.mUpdateFuncArr[1] = handler(self, self.UpdateTrainPanel)
	self.mUpdateFuncArr[2] = handler(self, self.UpdateSkillPanel)
	self.mUpdateFuncArr[3] = handler(self, self.UpdatePropertyPanel)
	self.mUpdateFuncArr[4] = handler(self, self.UpdateDestinyPanel)
	self.mUpdateFuncArr[5] = handler(self, self.UpdateEquipPanel)

	self.mSchoolPageArr[1] = self.mRootWidget:getChildByName("Image_ShowAll")
	self.mSchoolPageArr[2] = self.mRootWidget:getChildByName("Image_ShowSchool1")
	self.mSchoolPageArr[3] = self.mRootWidget:getChildByName("Image_ShowSchool2")
	self.mSchoolPageArr[4] = self.mRootWidget:getChildByName("Image_ShowSchool3")

	for i=1,#self.mSchoolPageArr do
		self.mSchoolPageArr[i]:setVisible(false)
	end

	self:SchoolPageAnimation(self.mSchoolPageArr)

	self.mHeroTV = AllHeroTableView:new(self)
	self.mHeroTV:init(self.mRootWidget:getChildByName("Panel_HeroList"))

	self.mHeroInfoPanelPos = cc.p(self.mHeroInfoPanel:getPosition())

	for i=1,#self.mSchoolPageArr do
		self.mSchoolPageArr[i]:setTag(i)
		registerWidgetReleaseUpEvent(self.mSchoolPageArr[i],handler(self, self.OnClickSchoolPage))
	end

	registerWidgetReleaseUpEvent(self.mBtnSwitch,handler(self, self.OnPressBtnSwitch))
	registerWidgetReleaseUpEvent(self.mRootWidget:getChildByName("Panel_PicChange"),handler(self, self.showHeroPic))

	-- 默认显示全部
	self:OnClickSchoolPage(self.mRootWidget:getChildByName("Image_ShowAll"))	
	--self.mRootWidget:getChildByName("Panel_HeroList")

	if not AllHeroGuide:isFinished() then
		AllHeroGuide:step(2)
	end
end 

local index = 1

function AllHeroWindow:SchoolPageAnimation(schoolPageArr)
	local schoolPagePos = cc.p(schoolPageArr[index]:getPosition())
	local schoolPageSize = schoolPageArr[index]:getContentSize()


	local function runBegin()	
		schoolPageArr[index]:setPosition(getGoldFightPosition_LD().x - schoolPageSize.width / 2,schoolPagePos.y)
		schoolPageArr[index]:setVisible(true)
	end

	local function runFinish()
		index = index + 1
		if index <= #schoolPageArr then  
			self:SchoolPageAnimation(schoolPageArr)
		else
			index = 1
		end
	end

	local actBegin = cc.CallFunc:create(runBegin)
	local actMove  =  cc.MoveTo:create(0.2, cc.p(schoolPagePos.x,schoolPagePos.y))
	local actEnd   = cc.CallFunc:create(runFinish)

	schoolPageArr[index]:runAction(cc.Sequence:create(actBegin,actMove,actEnd))
end

function AllHeroWindow:OnPressBtnSwitch(widget)
	if #self.mProPertyPageArr == 0 then
		self.mProPertyPageArr[1] = self.mRootWidget:getChildByName("Image_PeiYang")
		self.mProPertyPageArr[2] = self.mRootWidget:getChildByName("Image_JiNeng")
		self.mProPertyPageArr[3] = self.mRootWidget:getChildByName("Image_ShuXing")
		self.mProPertyPageArr[4] = self.mRootWidget:getChildByName("Image_YuanFen")
		self.mProPertyPageArr[5] = self.mRootWidget:getChildByName("Image_Zhuangbei")

		for i=1,#self.mProPertyPageArr do
			self.mProPertyPageArr[i]:setTag(i)
			registerWidgetReleaseUpEvent(self.mProPertyPageArr[i], handler(self, self.OnClickPropertyPage))
		end
	end

	if #self.mPropertyPanelArr == 0 then
		self.mPropertyPanelArr[1] = self.mRootWidget:getChildByName("Panel_PeiYang")
		self.mPropertyPanelArr[2] = self.mRootWidget:getChildByName("Panel_JiNeng")
		self.mPropertyPanelArr[3] = self.mRootWidget:getChildByName("Panel_ShuXing")
		self.mPropertyPanelArr[4] = self.mRootWidget:getChildByName("Panel_YuanFen")
		self.mPropertyPanelArr[5] = self.mRootWidget:getChildByName("Panel_ZhuangBei")

		for i = 1,5 do
			local bShow = false
			if i == 1 then  bShow = true end
			self.mPropertyPanelArr[i]:setVisible(bShow)
		end
	end

	--local bShowPic =  self.mHeroPicPanel:isVisible()

	self:HeroInfoSlide(self.mShowPic)

	self.mBtnSwitch:setRotation(self.mBtnSwitch:getRotation() - 180)

	if globaldata:isHeroIdExist(self.mSelectHeroId) then
		self:OnClickPropertyPage(self.mProPertyPageArr[1])
	else
		self:OnClickPropertyPage(self.mProPertyPageArr[2])
	end
end

function AllHeroWindow:HeroInfoSlide(bIn)
	local panelPos   = cc.p(self.mHeroInfoPanel:getPosition()) 
	local panelSize  = self.mHeroInfoPanel:getContentSize() 
	local showWidget = nil
	local actFade    = nil

	self.mBtnSwitch:setTouchEnabled(false)
	GUISystem:disableUserInput()

	if self.mPrePicShowed then 
		showWidget = self.mRootWidget:getChildByName("Image_PreHeroPic")
	else
		showWidget = self.mRootWidget:getChildByName("Panel_SmallHero")
	end

	if bIn ~= true then 
		panelPos.y = panelPos.y + panelSize.height / 2
		actFade = cc.FadeOut:create(0.2)
	else
		actFade = cc.FadeIn:create(0.2)
	end

	local function runBegin()
		if bIn == true then 
			self.mHeroInfoPanel:setPositionY(panelPos.y + panelSize.height / 2)
			self.mHeroInfoPanel:setOpacity(0)
			self.mHeroInfoPanel:setVisible(true)
			showWidget:runAction(cc.FadeOut:create(0.5))
			self.mHeroPicPanel:setVisible(false)
		end
	end

	local function runFinish()
		if bIn == true then 
			self.mShowPic			=  false
		else	
			self.mHeroInfoPanel:setPositionY(self.mHeroInfoPanelPos.y)
			self.mHeroInfoPanel:setVisible(false)
			showWidget:runAction(cc.FadeIn:create(0.2))
			self.mHeroPicPanel:setVisible(true)
			self.mShowPic			=  true
		end
		self.mBtnSwitch:setTouchEnabled(true)
		GUISystem:enableUserInput()
	end

	local actBegin = cc.CallFunc:create(runBegin)
	local actMove  = cc.MoveTo:create(0.2, panelPos)
	local actSpawn = cc.Spawn:create(actMove,actFade)
	local actEnd   = cc.CallFunc:create(runFinish)

	self.mHeroInfoPanel:runAction(cc.Sequence:create(actBegin,actSpawn,actEnd))
end

function AllHeroWindow:showHeroPic(widget)

	local moveTime	= 0.5

	if self.mPrePicShowed then
		local function actEnd()
			self.mPrePicShowed = not self.mPrePicShowed
			widget:setTouchEnabled(true)
		end

		-- 前景淡出
		local act0 = cc.FadeOut:create(moveTime)
		local act1 = cc.CallFunc:create(actEnd)
		self.mRootWidget:getChildByName("Image_PreHeroPic"):runAction(cc.Sequence:create(act0, act1))
		-- 后景淡入
		local act2 = cc.FadeIn:create(moveTime)
		self.mRootWidget:getChildByName("Panel_SmallHero"):runAction(act2)
	else
		local function actEnd()
			self.mPrePicShowed = not self.mPrePicShowed
			widget:setTouchEnabled(true)
		end
		-- 前景淡入
		local act0 = cc.FadeIn:create(moveTime)
		local act1 = cc.CallFunc:create(actEnd)
		self.mRootWidget:getChildByName("Image_PreHeroPic"):runAction(cc.Sequence:create(act0, act1))
		-- 后景淡出
		local act2 = cc.FadeOut:create(moveTime)
		self.mRootWidget:getChildByName("Panel_SmallHero"):runAction(act2)
	end

	widget:setTouchEnabled(false)
end


function AllHeroWindow:OnClickPropertyPage(widget)
	local tag = widget:getTag()

	if globaldata:isHeroIdExist(self.mSelectHeroId)  == false and (tag == 1 or tag == 5) then return end

	self.mPropertyCurSel  = tag

	widget:loadTexture(string.format("heroselect_page_%d_1.png",tag))

	for i=1,5 do
		local bShow = false
		if tag == i then bShow = true end
		if (tag == 1 or tag == 5)and not globaldata:isHeroIdExist(self.mSelectHeroId) then bShow = false end
		self.mPropertyPanelArr[i]:setVisible(bShow)

		if self.mProPertyPageArr[i] ~= widget then
			self.mProPertyPageArr[i]:loadTexture(string.format("heroselect_page_%d_2.png",i))
		end
	end

	self.mUpdateFuncArr[tag]()
end

function AllHeroWindow:OnClickSchoolPage(widget)
	if self.mLastClickedWidget == widget then
		return
	end

	local norTexture = {"select_all1.png", "select_school1.png", "select_school2.png", "select_school3.png"}
	local pusTexture = {"select_all1_2.png", "select_school1_2.png", "select_school2_2.png", "select_school3_2.png"}

	-- 换普通图
	for i=1,#self.mSchoolPageArr do
		self.mSchoolPageArr[i]:loadTexture(norTexture[i])
	end

	local function sortHeroArrByExist(heroArr)
		local existCnt = 0
		local i = 1
		local temp = heroArr[i] 
		for j = 1,#heroArr do
			if globaldata:isHeroIdExist(heroArr[j]) == true then 
				heroArr[i] = heroArr[j]
				heroArr[j] = temp
				i = i + 1
				temp = heroArr[i]
				existCnt = existCnt + 1
			end
		end
		return existCnt
	end


	local function sortHeroByFightPower(existheroArr)
		local temp = nil
		for i=1,#existheroArr do
			for j=1,#existheroArr - i do
				local heroObj1    = globaldata:findHeroById(existheroArr[j])
				local fightPower1 = heroObj1:getKeyValue("combat")
				local heroObj2    = globaldata:findHeroById(existheroArr[j + 1])
				local fightPower2 = heroObj2:getKeyValue("combat")
				if fightPower1 < fightPower2 then
					temp = existheroArr[j];
					existheroArr[j] = existheroArr[j + 1];
					existheroArr[j + 1] = temp;
				end
			end
		end
	end

	local function sortHeroByHeroFragments(notExistheroArr)

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

		local temp = nil
		for i=1,#notExistheroArr do
			for j=1,#notExistheroArr - i do
				local heroConfigData  = DB_HeroConfig.getDataById(notExistheroArr[j])
				local fragmentId1     = heroConfigData.Fragment
				local fragmentCnt1    = getFragmentCnt(fragmentId1)

				local heroConfigData2 = DB_HeroConfig.getDataById(notExistheroArr[j + 1])
				local fragmentId2     = heroConfigData2.Fragment
				local fragmentCnt2    = getFragmentCnt(fragmentId2)

				if fragmentCnt1 < fragmentCnt2 then
					temp = notExistheroArr[j];
					notExistheroArr[j] = notExistheroArr[j + 1];
					notExistheroArr[j + 1] = temp;
				end
			end
		end
	end

	local tag = widget:getTag()
	local heroArr = self.mModel.mHeroArr[tag]
	local existCnt = sortHeroArrByExist(heroArr)
	local existHeroArr    = {}
	local notExistHeroArr = {}

	for i=1,#heroArr do
		if i < existCnt + 1 then 
			table.insert(existHeroArr,heroArr[i]) 
		else
			table.insert(notExistHeroArr,heroArr[i]) 
		end
	end

	sortHeroByFightPower(existHeroArr)
	sortHeroByHeroFragments(notExistHeroArr)

	local sortHeroArr = {}

	for i=1,#existHeroArr do
		table.insert(sortHeroArr,existHeroArr[i]) 
	end

	for i=1,#notExistHeroArr do
		table.insert(sortHeroArr,notExistHeroArr[i]) 
	end

	self.mHeroTV.mDataSource = sortHeroArr
	self.mHeroTV:UpdateTableView(#sortHeroArr) 
 
	-- 换新图
	widget:loadTexture(pusTexture[tag])
	-- 停止旋转
	if self.mLastClickedWidget then
		self.mLastClickedWidget:getChildByName("Image_Circle"):setVisible(false)
		self.mLastClickedWidget:getChildByName("Image_Circle"):stopAllActions()
	end

	-- 开始旋转
	local function doRotate()
		widget:getChildByName("Image_Circle"):setVisible(true)
		local act0 = cc.RotateBy:create(5, 360)
		widget:getChildByName("Image_Circle"):runAction(cc.RepeatForever:create(act0))
		
	end
	doRotate()
	self.mLastClickedWidget = widget
end

function AllHeroWindow:UpdateHeroInfoPanel(heroId)
	if self.mHeroPicPanel:isVisible() then
		local heroConfigData = DB_HeroConfig.getDataById(heroId)
		--原画
		local picId          = heroConfigData.PicID
		local picData		 = DB_ResourceList.getDataById(picId)
		local picUrl		 = picData.Res_path1
		--名字
		local namePicId      = heroConfigData.NamePic
		local namePicData    = DB_ResourceList.getDataById(namePicId)
		local namePicUrl     = namePicData.Res_path1
		--职业
		local groupId        = heroConfigData.HeroGroup
		--格言
		local wordId		 = heroConfigData.File
		local wordData       = DB_Text.getDataById(wordId)
		local wordStr		 = wordData.Text_CN

		--碎片
		local fragmentId     = heroConfigData.Fragment

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
		local needCnt	  = 10

		local function getFragmentInfo(heroId)
			local chipInfo = globaldata.heroChipsInfo
			for i=1,#chipInfo do
				if heroId == chipInfo[i].heroId then 
					return chipInfo[i].chipCnt
				end
			end
			return 10
		end

		if globaldata:isHeroIdExist(self.mSelectHeroId) then
			local heroObj = globaldata:findHeroById(self.mSelectHeroId)
			needCnt       = heroObj:getKeyValue("chipCount")
		else
			needCnt       = getFragmentInfo(self.mSelectHeroId)
		end

		if globaldata:isHeroIdExist(self.mSelectHeroId) == false then
			local bShowGetBtn = false
			if fragmentCnt >= needCnt then bShowGetBtn = true end
			self.mRootWidget:getChildByName("Button_GetHero"):setVisible(bShowGetBtn)
			registerWidgetReleaseUpEvent(self.mRootWidget:getChildByName("Button_GetHero"),function() self.mModel:doGetHeroRequest(fragmentId) end)

			AllHeroGuide:step(6)
		else
			self.mRootWidget:getChildByName("Button_GetHero"):setVisible(false)
		end

		SpineDataCacheManager:collectFightSpineByAtlas(self.mLastSpine)
	    self.mLastSpine = SpineDataCacheManager:getSimpleSpineByHeroID(heroId,self.mRootWidget:getChildByName("Panel_HeroAnim"))
	    self.mLastSpine:setScale(heroConfigData.UIResouceZoom)

	    --local spine = FightSystem.mRoleManager:CreateSpine(heroId)
	    --spine:setScale(heroConfigData.UIResouceZoom)
	    --self.mRootWidget:getChildByName("Panel_HeroAnim"):removeAllChildren()
	    --self.mRootWidget:getChildByName("Panel_HeroAnim"):addChild(spine)

		self.mRootWidget:getChildByName("Label_Piece"):setString(string.format("%d/%d",fragmentCnt,needCnt))

		local c3b = nil
		if fragmentCnt < needCnt then c3b = cc.c3b(255,0,0) else c3b = cc.c3b(0,255,0) end
		self.mRootWidget:getChildByName("Label_Piece"):setColor(c3b)

		self.mRootWidget:getChildByName("Label_Introduce"):setString(wordStr)
		self.mRootWidget:getChildByName("Image_HeroName"):loadTexture(namePicUrl)
		self.mRootWidget:getChildByName("Image_HeroGroup"):loadTexture(string.format("hero_group%d.png",groupId))

		self.mRootWidget:getChildByName("Image_HeroPic"):loadTexture(picUrl)
		self.mRootWidget:getChildByName("Image_PreHeroPic"):loadTexture(picUrl)
		
		self.mRootWidget:getChildByName("Image_HeroPic"):setOpacity(30)
		ShaderManager:blackwhiteFilter(self.mRootWidget:getChildByName("Image_HeroPic"):getVirtualRenderer())

		if self.mPrePicShowed then
			self.mRootWidget:getChildByName("Image_PreHeroPic"):setOpacity(255)
		else
			self.mRootWidget:getChildByName("Image_PreHeroPic"):setOpacity(0)
		end
	else
		if globaldata:isHeroIdExist(self.mSelectHeroId) == false then
			if self.mPropertyCurSel == 1 or self.mPropertyCurSel == 5 then
				self.mPropertyCurSel = 2
			end	
		end
		--self.mUpdateFuncArr[self.mPropertyCurSel]()
		self:OnClickPropertyPage(self.mProPertyPageArr[self.mPropertyCurSel])
	end
end

function AllHeroWindow:UpdateTrainPanel()
	if self.mSelectHeroId == nil then return end

	--if globaldata:isHeroIdExist(self.mSelectHeroId) then
	--	self.mModel:doJinjieInfoRequest()
	--end

	self:UpdateJnjieInfo()
	self:UpdateJinhuaInfo()
	self:UpdateUseItemInfo()

	registerWidgetReleaseUpEvent(self.mRootWidget:getChildByName("Button_DoJinJie"),function() self.mModel:doJinjieRequest() end)
	registerWidgetReleaseUpEvent(self.mRootWidget:getChildByName("Button_DoJinHua"),function() self.mModel:doJinhuaRequest() end)
end

function AllHeroWindow:UpdateJnjieInfo()
	if self.mSelectHeroId == nil then return end

	local advancedLv  = 0
	if globaldata:isHeroIdExist(self.mSelectHeroId) then
		local heroObj  = globaldata:findHeroById(self.mSelectHeroId)
		advancedLv     = heroObj:getKeyValue("advanceLevel")
		advanceCostArr = heroObj:getKeyValue("advancedCostList")
	end
	--进阶
	self.mRootWidget:getChildByName("Image_CurJinjieLv"):loadTexture("heroselect_qualitynum_"..tostring(advancedLv)..".png")
	if 7 == advancedLv then
		self.mRootWidget:getChildByName("Image_NextJinjieLv"):setVisible(false)
		self.mRootWidget:getChildByName("Button_DoJinJie"):setVisible(false)
	else
		self.mRootWidget:getChildByName("Image_NextJinjieLv"):setVisible(true)
		self.mRootWidget:getChildByName("Image_NextJinjieLv"):loadTexture("heroselect_qualitynum_"..tostring(advancedLv+1)..".png")
		self.mRootWidget:getChildByName("Button_DoJinJie"):setVisible(true)
	end

	for i=1,#advanceCostArr do
		if advanceCostArr[i].itemType == 2 then 
			self.mRootWidget:getChildByName("Label_GoldNum"):setString(advanceCostArr[i].itemNum)
		elseif  advanceCostArr[i].itemType == 0 then 
			self.mRootWidget:getChildByName("Label_JinjieDaojuNum"):setString(advanceCostArr[i].itemNum)
		end
	end
		
	self.mRootWidget:getChildByName("Image_JinjieDaoju"):loadTexture("item_jinjie.png",1)
end

function AllHeroWindow:UpdateJinhuaInfo()
	--碎片
	local heroConfigData = DB_HeroConfig.getDataById(self.mSelectHeroId)
	local fragmentId     = heroConfigData.Fragment

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
	local needCnt	  = 10
	local star        = 0

	if globaldata:isHeroIdExist(self.mSelectHeroId) then
		local heroObj = globaldata:findHeroById(self.mSelectHeroId)
		needCnt       = heroObj:getKeyValue("chipCount")
	 	star          = heroObj:getKeyValue("quality")
	end
	--进化
	for i=1,6 do
		local starPic = nil 
		if i <= star then starPic = "public_star1.png" else starPic = "public_star2.png" end
		self.mRootWidget:getChildByName(string.format("Image_Star_%d",i)):loadTexture(starPic)
	end
	self.mRootWidget:getChildByName("Label_ChipNum_Stroke"):setString(string.format("%d/%d",fragmentCnt,needCnt))
	self.mRootWidget:getChildByName("Label_Piece"):setString(string.format("%d/%d",fragmentCnt,needCnt))

	if fragmentCnt < needCnt then
		self.mRootWidget:getChildByName("Label_ChipNum_Stroke"):setColor(cc.c3b(255,0,0))
	else
		self.mRootWidget:getChildByName("Label_ChipNum_Stroke"):setColor(cc.c3b(0,255,0))
	end

	local value = 0
	if fragmentCnt / needCnt * 100 >= 100 then
		value = 100
	elseif fragmentCnt / needCnt * 100 <= 0 then
		value = 0
	else
		value = fragmentCnt / needCnt * 100
	end

	self.mRootWidget:getChildByName("ProgressBar_jinhua"):setPercent(value)

end

function AllHeroWindow:UpdateUseItemInfo()
	local level	      = 0
	local exp         = 0
	local expMax      = 0

	if globaldata:isHeroIdExist(self.mSelectHeroId) then
		local heroObj = globaldata:findHeroById(self.mSelectHeroId)
		level	      = heroObj:getKeyValue("level")
		exp           = heroObj:getKeyValue("exp")
		expMax        = heroObj:getKeyValue("maxExp")
	end

	self.mRootWidget:getChildByName("Label_LevelVal_Stroke"):setString(string.format("LV.%d",level))
	self.mRootWidget:getChildByName("Label_ExpVal"):setString(string.format("%d/%d",exp,expMax))
	self.mRootWidget:getChildByName("ProgressBar_Peiyang"):setPercent(exp / expMax * 100 )

	local itemId = {20011, 20012, 20013, 20014}
	for i = 1, 4 do
		local itemObj = globaldata:getItemInfo(nil, itemId[i])
		local itemCount = 0
		if itemObj then
			itemCount = itemObj:getKeyValue("itemNum")
		end
		local btn = self.mRootWidget:getChildByName(string.format("Button_Medicine_%d",i))
		btn:getChildByName("Label_LastNum"):setString(string.format("剩余 %d",itemCount))
		btn:setTag(itemId[i])
		btn:getChildByName("Image_Medicine"):loadTexture(string.format("item_yao%d.png",i),1)
		registerWidgetReleaseUpEvent(btn, function(widget) self.mModel:doUseItemRequest(widget:getTag()) end)
	end
end

local skillInfoArr = {}

function AllHeroWindow:UpdateSkillPanel()
	if self.mSelectHeroId == nil then return end
	if globaldata:isHeroIdExist(self.mSelectHeroId) == false then return end


	if #self.mSkillPanelArr == 0 then 
		table.insert(self.mSkillPanelArr ,self.mRootWidget:getChildByName("Image_Skill_PuGong"))

		for i=1,3 do
			table.insert(self.mSkillPanelArr ,self.mRootWidget:getChildByName(string.format("Image_Skill_Zhu%d",i)))
		end

		for i=1,4 do
			table.insert(self.mSkillPanelArr ,self.mRootWidget:getChildByName(string.format("Image_Skill_Bei_%d",i)))
		end

		table.insert(self.mSkillPanelArr ,self.mRootWidget:getChildByName("Image_Skill_HeTi"))
	end

	local heroInfo = globaldata:findHeroById(self.mSelectHeroId)
	local level    = heroInfo:getKeyValue("level")
	skillInfoArr = heroInfo.skillList

	local function sortSkillByType(skillInfoArr)                --1 normal 2  active  3 passive 4 ultimate
		local temp = nil
		for i=1,#skillInfoArr do
			for j=1,#skillInfoArr - i do
				if skillInfoArr[j].mSkillType > skillInfoArr[j + 1].mSkillType then
					temp = skillInfoArr[j]
					skillInfoArr[j] = skillInfoArr[j + 1]
					skillInfoArr[j + 1] = temp
				end
			end
		end
	end
	sortSkillByType(skillInfoArr)

	for i=1,#skillInfoArr do
		local skillData   = DB_SkillEssence.getDataById(skillInfoArr[i].mSkillId)
		local skillNameId = skillData.Name
		local nameData    = DB_Text.getDataById(skillNameId)
		local nameStr     = nameData.Text_CN
		local skillIconId = skillData.IconID
		local skillIcon   = DB_ResourceList.getDataById(skillIconId).Res_path1

		local iconImage = self.mSkillPanelArr[i]:getChildByName("Image_Skill")
		iconImage:loadTexture(skillIcon,1) 
		MessageBox:showSkillInfo(iconImage, skillInfoArr[i],self.mSelectHeroId)

		self.mSkillPanelArr[i]:getChildByName("Label_NameLevel"):setString(string.format("%s Lv.%d",nameStr,skillInfoArr[i].mSkillLevel))
		if skillInfoArr[i].mSkillLevel < level then 
			local upgradeBtn = self.mSkillPanelArr[i]:getChildByName("Button_Promote")
			upgradeBtn:getChildByName("Label_UpgradeCost"):setString(tostring(skillInfoArr[i].mPrice))
			upgradeBtn:setVisible(false)	--btn visiable
			upgradeBtn:setTag(i)
			registerWidgetReleaseUpEvent(upgradeBtn,function(widget)
			if globaldata.money < skillInfoArr[i].mPrice then
				MessageBox:showMessageBox1("金钱不足~")
				return
			end
			self.mModel:doSkillUpgradeRequest(self.mSelectHeroId,skillInfoArr[i].mSkillId,widget:getTag())
			end)
		end
	end
end

function AllHeroWindow:NotifySkillInfo(skillLevel,skillIndex,skillPrice)
	local heroInfo   = globaldata:findHeroById(self.mSelectHeroId)
	local level      = heroInfo:getKeyValue("level")
	local upgradeBtn = self.mSkillPanelArr[skillIndex]:getChildByName("Button_Promote")

	upgradeBtn:getChildByName("Label_UpgradeCost"):setString(tostring(skillPrice))
	
	if skillLevel >= level then 
		upgradeBtn:setVisible(false)
	end
	local skillData   = DB_SkillEssence.getDataById(skillInfoArr[skillIndex].mSkillId)
	local skillNameId = skillData.Name
	local nameData    = DB_Text.getDataById(skillNameId)
	local nameStr     = nameData.Text_CN
	self.mSkillPanelArr[skillIndex]:getChildByName("Label_NameLevel"):setString(string.format("%s %d",nameStr,skillLevel))
end

function AllHeroWindow:UpdatePropertyPanel()
	if self.mSelectHeroId == nil then return end
	local function createRadarGraph()
		local leftProp = GUIWidgetPool:createWidget("HeroShuxingLess")

		local function initRadar()
			self.mRadarWidget = RadarWidget:new()
			self.mRadarWidget:init(leftProp)
		end
		initRadar()

		return leftProp
	end

	-- 属性窗口
	if self.mLeftProp == nil then 
		self.mLeftProp = createRadarGraph()
		self.mRightProp = GUIWidgetPool:createWidget("HeroShuxingMore")
	end

	local heroData = DB_HeroConfig.getDataById(self.mSelectHeroId)
	local val = 
	{
		(heroData.QualityAddArmor+heroData.QualityAddTenacity)/50,  -- 防御
		heroData.QualityAddPhyAttack/25, 							-- 输出
		heroData.QualityAddHP/1000, 	 							-- 生存
		(heroData.QualityAddArmorPene+heroData.QualityAddCrit)/50, 	-- 爆发
		(heroData.QualityAddHit+heroData.QualityAddDodge)/50, 		-- 敏捷
	}
	self.mRadarWidget:drawShape(val)

	local propList 		= nil
	local growPropList  = nil
	-- 属性
	if globaldata:isHeroIdExist(self.mSelectHeroId) then
		local heroObj   = globaldata:findHeroById(self.mSelectHeroId)
		propList        = heroObj:getKeyValue("propList")	
		growPropList    = heroObj:getKeyValue("growPropList")

		for k, v in pairs(growPropList) do
			self.mRightProp:getChildByName("ProgressBar_Prop"..tostring(k)):setPercent(v)
		end
	else
		propList        = {}
		growPropList    = {}
		local heroData  = DB_HeroConfig.getDataById(self.mSelectHeroId)
		propList[0]     = heroData.InitHP
		propList[1]     = heroData.InitPhyAttack
		propList[2]     = heroData.InitArmorPene
		propList[3]     = heroData.InitArmor
		propList[4]     = heroData.InitHit
		propList[5]     = heroData.InitDodge
		propList[6]     = heroData.InitCrit
		propList[7]     = heroData.InitTenacity
		propList[8]     = heroData.InitAttackSpeed
		propList[9]     = heroData.InitMoveSpeed
		propList[10]    = heroData.InitJumpHeight

		growPropList[0] = heroData.LevelAddHP / 1400 * 100
		growPropList[1] = heroData.LevelAddPhyAttack
		growPropList[2] = heroData.LevelAddArmorPene
		growPropList[3] = heroData.LevelAddArmor
		growPropList[4] = heroData.LevelAddHit
		growPropList[5] = heroData.LevelAddDodge
		growPropList[6] = heroData.LevelAddCrit
		growPropList[7] = heroData.LevelAddTenacity	

		for i = 0,7 do
			self.mRightProp:getChildByName("ProgressBar_Prop"..tostring(i)):setPercent(growPropList[i])
		end						
	end
 	-- 生命
	self.mRightProp:getChildByName("Label_LifeVal"):setString(tostring(propList[0]))
	-- 物攻
	self.mRightProp:getChildByName("Label_DamageVal"):setString(tostring(propList[1]))
	-- 破甲
	self.mRightProp:getChildByName("Label_PojiaVal"):setString(tostring(propList[2]))
	-- 护甲
	self.mRightProp:getChildByName("Label_HujiaVal"):setString(tostring(propList[3]))
	-- 命中
	self.mRightProp:getChildByName("Label_MingzhongVal"):setString(tostring(propList[4]))
	-- 闪避
	self.mRightProp:getChildByName("Label_ShanbiVal"):setString(tostring(propList[5]))
	-- 暴击
	self.mRightProp:getChildByName("Label_BaojiVal"):setString(tostring(propList[6]))
	-- 韧性
	self.mRightProp:getChildByName("Label_RenxingVal"):setString(tostring(propList[7]))
	-- 攻击速度
	self.mRightProp:getChildByName("Label_GongjiSpeedVal"):setString(tostring(propList[8]))
	-- 移动速度
	self.mRightProp:getChildByName("Label_YidongSpeedVal"):setString(tostring(propList[9]))
	-- 跳跃力
	self.mRightProp:getChildByName("Label_JumpVal"):setString(tostring(propList[10]))

	self.mRootWidget:getChildByName("Panel_ShuxingMore"):addChild(self.mRightProp)
	self.mRootWidget:getChildByName("Panel_ShuxingLess"):addChild(self.mLeftProp)
end

function AllHeroWindow:UpdateDestinyPanel()
	if self.mSelectHeroId == nil then return end

	local  heroData = DB_HeroConfig.getDataById(self.mSelectHeroId)

	local destinyArr = {{},{},{},{},}
	-- 缘分一
	destinyArr[1].id        = heroData.FateObj1
	destinyArr[1].fateType  = heroData.FateType1
	destinyArr[1].fateValue = heroData.FateValue1
	destinyArr[1].activeType = heroData.FateActiveType1
	-- 缘分二
	destinyArr[2].id        = heroData.FateObj2
	destinyArr[2].fateType  = heroData.FateType2
	destinyArr[2].fateValue = heroData.FateValue2
	destinyArr[2].activeType = heroData.FateActiveType2
	-- 缘分三
	destinyArr[3].id        = heroData.FateObj3
	destinyArr[3].fateType  = heroData.FateType3
	destinyArr[3].fateValue = heroData.FateValue3
	destinyArr[3].activeType = heroData.FateActiveType3
	-- 缘分四
	destinyArr[4].id        = heroData.FateObj4
	destinyArr[4].fateType  = heroData.FateType4
	destinyArr[4].fateValue = heroData.FateValue4
	destinyArr[4].activeType = heroData.FateActiveType4

	for i=1,4 do
		self:UpdateDestinyChildPanel(destinyArr[i].id, destinyArr[i].fateType, destinyArr[i].fateValue,destinyArr[i].activeType,i)
	end
end

function AllHeroWindow:UpdateDestinyChildPanel(heroId, fateType, fateValue,activeType,index)
	local widget = self.mRootWidget:getChildByName(string.format("Panel_Relation_%d",index))
	local idTbl = extern_string_split_(heroId, ",")
	-- 名字
	local heroName = ""
	if 1 == #idTbl then
		-- 英雄1
		local heroData1 = DB_HeroConfig.getDataById(tonumber(idTbl[1]))
		local heroNameId1 = heroData1.Name
		heroName = getDictionaryText(heroNameId1)
	elseif 2 == #idTbl then
		-- 英雄1
		local heroData1 = DB_HeroConfig.getDataById(tonumber(idTbl[1]))
		local heroNameId1 = heroData1.Name
		-- 英雄2
		local heroData2 = DB_HeroConfig.getDataById(tonumber(idTbl[2]))
		local heroNameId2 = heroData2.Name
		heroName = getDictionaryText(heroNameId1).."、"..getDictionaryText(heroNameId2)
	end
	widget:getChildByName("Label_HeroName_Stroke"):setString(heroName)

	-- 头像
	for i = 1, 2 do
		local logoimgWidget = widget:getChildByName("Image_HeroBg"..tostring(i)):getChildByName("Panel_HeroLogo"):getChildByName("Image_HeroLogo")
		if idTbl[i] then
			local heroId = tonumber(idTbl[i])
			local heroData = DB_HeroConfig.getDataById(heroId)
			local imgId = heroData.IconID
			local imgName = DB_ResourceList.getDataById(imgId).Res_path1

			logoimgWidget:loadTexture(imgName,1)

			if globaldata:isHeroIdExist(heroId) == false then
				ShaderManager:decreaseSaturationTo(logoimgWidget:getVirtualRenderer(), 0.2)
			else
				ShaderManager:ResumeColor(logoimgWidget:getVirtualRenderer())	
			end

			local function isInTeam()
				for i = 1, 5 do
					if globaldata:isBattleIndexExist(i) then
						if heroId == globaldata:getHeroInfoByBattleIndex(i, "id") then
							return true
						end
					end
				end
				
				return false
			end

			if isInTeam() == true then
				widget:getChildByName("Label_Addition"):setColor(cc.c3b(255,239,56))
			else
				widget:getChildByName("Label_Addition"):setColor(cc.c3b(184,184,184))
			end

		else
			logoimgWidget:setVisible(false)
		end
	end
	-- 加成
	if 1 == activeType then
		local typeTable = {"生命", "攻击", "破甲", "护甲", "命中", "闪避", "暴击", "韧性", "攻速"}
		widget:getChildByName("Label_Addition"):setString("一同上阵 "..typeTable[fateType].." +"..tostring(fateValue).."%")
	else
		widget:getChildByName("Label_Addition"):setString("一同上阵激活合体技")
	end
end



function AllHeroWindow:UpdateEquipPanel()
	local equipPanelArr = {}

	if #equipPanelArr == 0 then 
		for i=1,6 do
			equipPanelArr[i] = self.mRootWidget:getChildByName(string.format("Panel_ZhuangBei_%d",i))
			equipPanelArr[i]:setTag(i)
		end

		for i=1,3 do
			equipPanelArr[i+6] = self.mRootWidget:getChildByName(string.format("Panel_ShiZhuang_%d",i))
			equipPanelArr[i+6]:removeAllChildren()
			equipPanelArr[i+6]:setTag(i+6)
			equipPanelArr[i+6]:setTouchEnabled(false)
		end
	end

	local heroInfo = globaldata:findHeroById(self.mSelectHeroId)
	local equipInfoArr = heroInfo.equipList

	for i=1,#equipInfoArr do
		print(equipInfoArr[i].type)


		local equipItem = createEquipWidget(equipInfoArr[i].id, equipInfoArr[i].quality,1,equipPanelArr[i]:getChildren()[1])
		equipItem:setTouchSwallowed(false)
		equipPanelArr[equipInfoArr[i].type]:addChild(equipItem)
		equipPanelArr[equipInfoArr[i].type]:setTouchEnabled(true)
		registerWidgetReleaseUpEvent(equipPanelArr[equipInfoArr[i].type],function(widget) self:ShowEquipInfo(widget:getTag()) end)
	end
end

function AllHeroWindow:ShowEquipInfo(infoIndex)
	local equipInfoWidget = GUIWidgetPool:createWidget("HeroEquipInfo")
	self.mRootNode:addChild(equipInfoWidget) 
	-- 按钮
	equipInfoWidget:getChildByName("Panel_DiamondBtn"):setVisible(false)
	equipInfoWidget:getChildByName("Panel_EquipBtn"):setVisible(false)
	equipInfoWidget:getChildByName("Panel_ShizhuangBtn"):setVisible(false)

	local heroInfo = globaldata:findHeroById(self.mSelectHeroId)
	local equipInfoArr = heroInfo.equipList
	local equipInfo = nil
	for i=1,#equipInfoArr do
		if equipInfoArr[i].type == infoIndex then 
			equipInfo = equipInfoArr[i]
		end
	end
	
	local equipItem = createEquipWidget(equipInfo.id, equipInfo.quality)
	equipInfoWidget:getChildByName("Panel_EquipIcon"):addChild(equipItem)

	local equipData = DB_EquipmentConfig.getDataById(equipInfo.id)
	local nameId 	= equipData.Name
	local nameData  = DB_Text.getDataById(nameId)
	local nameStr   = nameData.Text_CN
	equipInfoWidget:getChildByName("Label_Name"):setString(nameStr)

	local descId 	= equipData.EquipText
	local descData  = DB_Text.getDataById(descId)
	local descStr	= descData.Text_CN

	equipInfoWidget:getChildByName("Label_Des"):setString(descStr)

	-- 初始属性
	local propList = equipInfo.propList
	local cnt = 1
	for k, v in pairs(propList) do
		equipInfoWidget:getChildByName(string.format("Label_Init_%d", cnt)):setString(string.format("初始%s +%d", globaldata:getTypeString(k), v))
		cnt = cnt + 1
	end

	-- 成长属性
	local growPropList = equipInfo.growPropList
	cnt = 1
	for k, v in pairs(growPropList) do
		equipInfoWidget:getChildByName(string.format("Label_Add_%d", cnt)):setString(string.format("成长%s +%d", globaldata:getTypeString(k), v))
		cnt = cnt + 1
	end

	-- 成长属性显示
		if 1 == cnt then
			equipInfoWidget:getChildByName("Panel_Add"):setVisible(false)
		else
			for i = 1, 4 do
				if i <= cnt-1 then
					equipInfoWidget:getChildByName(string.format("Label_Add_%d", i)):setVisible(true)
				else
					equipInfoWidget:getChildByName(string.format("Label_Add_%d", i)):setVisible(false)
				end
			end
		end

		-- 宝石
		local diamondCnt = 0
		local diamondId = nil
		local diamondList = equipInfo:getKeyValue("diamondList")
		for i = 1, #diamondList do
			if 0 ~= diamondList[i] then
				local wgt = createDiamondWidget(diamondList[i])
				equipInfoWidget:getChildByName(string.format("Image_Diamond_Bg_%d", i)):getChildByName("Panel_Diamond"):addChild(wgt)
				diamondCnt = diamondCnt + 1
				diamondId = diamondList[i]
			end
		end

		-- 宝石属性加成
		if diamondCnt > 0 then
			local propValue = 0
			local propType = nil
			for i = 1, #diamondList do
				diamondId = diamondList[i]
				if 0 ~= diamondId then
					local diamondData = DB_Diamond.getDataById(diamondId)
					propType = diamondData.Type
					propValue = diamondData.value + propValue
					print("宝石Id:", diamondId, "属性值:", diamondData.value)
				end
			end
			if -1 == propType then
				local heroId = self.mSelectHeroId
				local heroData = DB_HeroConfig.getDataById(heroId)
				equipInfoWidget:getChildByName("Label_Effect"):setString(string.format("%s + %d", globaldata:getTypeString(heroData.HeroGroup), propValue))
			else
				equipInfoWidget:getChildByName("Label_Effect"):setString(string.format("%s + %d", globaldata:getTypeString(propType), propValue))
			end
		else
			equipInfoWidget:getChildByName("Label_Effect"):setVisible(false)
		end

	if infoIndex > 6 then
		for i=1,5 do
			equipInfoWidget:getChildByName(string.format("Image_Diamond_Bg_%d",i)):setVisible(false)
			equipInfoWidget:getChildByName("Label_29"):setVisible(false) 
		end
	end	

	registerWidgetReleaseUpEvent(equipInfoWidget,function(widget) widget:removeFromParent(true); widget = nil end)

end

function AllHeroWindow:Destroy()
	GUIEventManager:unregister("battleTeamChanged", self.close)
	GUIEventManager:unregister("battleTeamChanged", self.refresh)
	GUIEventManager:unregister("equipChanged", self.refresh)
	GUIEventManager:unregister("combatChanged", self.refresh)
	GUIEventManager:unregister("updateJinHua", self.refresh)
	GUIEventManager:unregister("itemInfoChanged", self.UpdateUseItemInfo)
	GUIEventManager:unregister("heroAddSync", self.refresh)

	SpineDataCacheManager:collectFightSpineByAtlas(self.mLastSpine)
	self.mLastSpine = nil
	TextureSystem:unloadPlist_iconskill()

	self.mHeroTV:Destroy()
	self.mHeroTV 	= nil

	self.mTopRoleInfoPanel:destroy()
	self.mTopRoleInfoPanel  = nil

	self.mHeroPicPanel		=   nil
	self.mHeroInfoPanel		= 	nil

	self.mBtnSwitch			=   nil
	self.mPanelHeroList		=   nil
	self.mProPertyPageArr	=   {}
	self.mPropertyPanelArr	=   {}
	self.mSchoolPageArr		=   {}
	
	self.mRootNode:removeFromParent(true)
	self.mRootNode          = nil
	self.mRootWidget        = nil

	curSelectedHeroIndex    = nil
	self.mLastClickedWidget = nil

	self.mPrePicShowed 		=	false
	self.mSelectHeroId		=   nil
	self.mPropertyCurSel	=   nil

	self.mModel:deinit()
	self.mModel = nil

	self.mUpdateFuncArr	    = {}
	self.mSkillPanelArr		=   {}

	self.mShowPic			=  true

	index = 1
	--清理缓存
	CommonAnimation:clearAllTextures()
end

function AllHeroWindow:onEventHandler(event)
	if event.mAction == Event.WINDOW_SHOW then
		--if GUISystem:canShow(self.mName) then
			self:Load(event)
		--end
	elseif event.mAction == Event.WINDOW_HIDE then
		self:Destroy()
	end
end

return AllHeroWindow