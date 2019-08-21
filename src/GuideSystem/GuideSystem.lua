-- Name: 	GuideSystem
-- Func：	指引系统
-- Author:	WangShengdong
-- Data:	15-6-1

require "GuideSystem/HomeGuideOne"                        -- 主城指引1
require "GuideSystem/PveGuideOne" 				          -- 副本指引1
require "GuideSystem/PveGuideTwo"                         -- 副本指引2
require "GuideSystem/PveGuideThree"                       -- 副本指引3
require "GuideSystem/PveGuideFour"                        -- 副本指引4
require "GuideSystem/PveGuideFive"                        -- 副本指引5
require "GuideSystem/SkillGuideOne"                       -- 技能指引1
require "GuideSystem/LevelRewardGuideOne"                 -- 等级奖励指引1
require "GuideSystem/LotteryGuideOne"                     -- 抽卡指引1
require "GuideSystem/HeroGuideOneEx"                      -- 英雄指引1
require "GuideSystem/PveGuideSix"                         -- 副本指引6
require "GuideSystem/LevelRewardGuideTwo"                 -- 等级奖励指引2
require "GuideSystem/HeroGuideTwo"                        -- 英雄指引2
require "GuideSystem/ArenaGuideOne"                       -- 竞技场指引1
require "GuideSystem/ArenaGuideTwo"                       -- 竞技场指引2
require "GuideSystem/TaskGuideOne"                        -- 任务指引1
require "GuideSystem/EquipGuideOne"                       -- 装备指引1
require "GuideSystem/FuckTimeGuideOne"                    -- 放课时间指引1
require "GuideSystem/GonghuiGuideOne"                     -- 公会指引1
require "GuideSystem/DayDayUpGuideOne"                    -- 升学试炼指引1
require "GuideSystem/EquipGuideTwo"                       -- 装备指引2
require "GuideSystem/HardPveGuideOne"                     -- 精英指引1
require "GuideSystem/WorldBossGuideOne"                   -- 世界BOSS指引1
require "GuideSystem/ParkGuideOne"                        -- 游乐园指引1
require "GuideSystem/TiantiGuideOne"                      -- 天梯指引1
require "GuideSystem/LevelRewardGuideZero"                 -- 等级奖励指引0
require "GuideSystem/PveGuide1_5"                         -- 副本指引1-5
require "GuideSystem/PveGuide1_6"                         -- 副本指引1-6
require "GuideSystem/PveGuide1_7"                         -- 副本指引1-7
require "GuideSystem/LevelRewardGuideOnePointFive"        -- 等级奖励指引0
require "GuideSystem/TaskGuideZero"                       -- 任务指引1
require "GuideSystem/HeroHorseGuide"                      -- 任务指引1
require "GuideSystem/HeroWeaponGuide"                     -- 任务指引1
require "GuideSystem/BadgeGuideOne"                       -- 任务指引1
require "GuideSystem/BlackMarketGuide"                    -- 任务指引1
require "GuideSystem/TechnologyGuideOne"                  -- 任务指引1
-- require "GuideSystem/RealTimePkGuideOne"                -- Hero指引2
-- require "GuideSystem/EquipGuideThree"                   -- Equip指引2

-- require "GuideSystem/VerticalTowerGuideOne"             -- 竖版闯关指引
-- require "GuideSystem/FuckTimeGuideOne"                  -- 放课时间指引

-- require "GuideSystem/GonghuiGuideOne"                   -- 公会指引
-- require "GuideSystem/TechnologyGuideOne"                -- 科技指引
-- require "GuideSystem/HorizonTowerGuideOne"              -- 横版闯关指引
-- require "GuideSystem/BlackMarketGuideOne"               -- 横版闯关指引
-- require "GuideSystem/HardPveGuideOne"                   -- 精英副本指引
-- require "GuideSystem/PveGuideFive"                   -- PVE指引5

-- require "GuideSystem/PveGuideSeven"                  -- PVE指引7
-- require "GuideSystem/PveGuideEight"                  -- PVE指引8
-- require "GuideSystem/PveGuideNine"                   -- PVE指引9
-- require "GuideSystem/HeroGuideThree"                 -- Hero指引3
-- require "GuideSystem/PveGuideTen"                    -- PVE指引10
-- require "GuideSystem/PveGuideEleven"                 -- PVE指引11
-- require "GuideSystem/HeroGuideFour"                  -- Hero指引4



local guideObj = {}

function guideObj:new()
	local o = 
	{
		mId 	= 	0,
		mStep 	=	0,
		mFinish	=	0,
	}
	o = newObject(o, guideObj)
	return o
end

GuideSystem = {}

GuideSystem.guideData = nil

function GuideSystem:reloadLuaFile(filename)
    _G[filename] = nil
    package.loaded[filename] = nil
    require(filename)
end

-- 重载新手所有lua文件
function GuideSystem:reloadGuideAllLuaFile()
    GuideSystem:reloadLuaFile("GuideSystem/HomeGuideOne")
    GuideSystem:reloadLuaFile("GuideSystem/PveGuideOne" )                        -- 副本指引1
    GuideSystem:reloadLuaFile("GuideSystem/PveGuideTwo"  )                       -- 副本指引2
    GuideSystem:reloadLuaFile("GuideSystem/PveGuideThree" )                      -- 副本指引3
    GuideSystem:reloadLuaFile("GuideSystem/PveGuideFour"  )                      -- 副本指引4
    GuideSystem:reloadLuaFile("GuideSystem/PveGuideFive"   )                     -- 副本指引5
    GuideSystem:reloadLuaFile("GuideSystem/SkillGuideOne"   )                    -- 技能指引1
    GuideSystem:reloadLuaFile("GuideSystem/LevelRewardGuideOne")                 -- 等级奖励指引1
    GuideSystem:reloadLuaFile("GuideSystem/LotteryGuideOne" )                    -- 抽卡指引1
    GuideSystem:reloadLuaFile("GuideSystem/HeroGuideOneEx"  )                    -- 英雄指引1
    GuideSystem:reloadLuaFile("GuideSystem/PveGuideSix"      )                   -- 副本指引6
    GuideSystem:reloadLuaFile("GuideSystem/LevelRewardGuideTwo")                 -- 等级奖励指引2
    GuideSystem:reloadLuaFile("GuideSystem/HeroGuideTwo"        )                -- 英雄指引2
    GuideSystem:reloadLuaFile("GuideSystem/ArenaGuideOne"   )                    -- 竞技场指引1
    GuideSystem:reloadLuaFile("GuideSystem/ArenaGuideTwo"   )                    -- 竞技场指引2
    GuideSystem:reloadLuaFile("GuideSystem/TaskGuideOne"     )                   -- 任务指引1
    GuideSystem:reloadLuaFile("GuideSystem/EquipGuideOne"    )                   -- 装备指引1
    GuideSystem:reloadLuaFile("GuideSystem/FuckTimeGuideOne"  )                  -- 放课时间指引1
    GuideSystem:reloadLuaFile("GuideSystem/GonghuiGuideOne"   )                  -- 公会指引1
    GuideSystem:reloadLuaFile("GuideSystem/DayDayUpGuideOne"  )                  -- 升学试炼指引1
    GuideSystem:reloadLuaFile("GuideSystem/EquipGuideTwo"    )                   -- 装备指引2
    GuideSystem:reloadLuaFile("GuideSystem/HardPveGuideOne"   )                  -- 精英指引1
    GuideSystem:reloadLuaFile("GuideSystem/WorldBossGuideOne"  )                 -- 世界BOSS指引1
    GuideSystem:reloadLuaFile("GuideSystem/ParkGuideOne"      )                  -- 游乐园指引1
    GuideSystem:reloadLuaFile("GuideSystem/TiantiGuideOne"     )                 -- 天梯指引1
    GuideSystem:reloadLuaFile("GuideSystem/LevelRewardGuideZero")                 -- 等级奖励指引0
    GuideSystem:reloadLuaFile("GuideSystem/PveGuide1_5"          )               -- 副本指引1-5
    GuideSystem:reloadLuaFile("GuideSystem/PveGuide1_6"         )                -- 副本指引1-6
    GuideSystem:reloadLuaFile("GuideSystem/PveGuide1_7"        )                 -- 副本指引1-7
    GuideSystem:reloadLuaFile("GuideSystem/LevelRewardGuideOnePointFive" )       -- 等级奖励指引0
    GuideSystem:reloadLuaFile("GuideSystem/TaskGuideZero"         )              -- 任务指引1
    GuideSystem:reloadLuaFile("GuideSystem/HeroHorseGuide"         )             -- 任务指引1
    GuideSystem:reloadLuaFile("GuideSystem/HeroWeaponGuide"      )               -- 任务指引1
    GuideSystem:reloadLuaFile("GuideSystem/BadgeGuideOne"        )               -- 任务指引1
    GuideSystem:reloadLuaFile("GuideSystem/BlackMarketGuide"     )               -- 任务指引1
    GuideSystem:reloadLuaFile("GuideSystem/TechnologyGuideOne"   )               -- 任务指引1
    ----
    GuideSystem:reloadLuaFile("GuideSystem/GuideSystem")
end

-- 初始化
function GuideSystem:init(msgPacket)
	self.guideData = {}
	self.mDialogTable = {}
	self.CGPlaySpeed = 0.03
	local guideCount = msgPacket:GetUShort()

	-- 初始化数据
	for i = 1, guideCount do
		self.guideData[i] = guideObj:new()
		self.guideData[i].mId = msgPacket:GetChar()
		self.guideData[i].mStep = msgPacket:GetChar()
		self.guideData[i].mFinish = msgPacket:GetChar()
        if not needUseGuide then
            self.guideData[i].mFinish = 1
        end
		print("指引数据:", self.guideData[i].mId, self.guideData[i].mStep, self.guideData[i].mFinish)
	end
	-- 指引系统中断恢复
	self:recoverInterrupt()
end

-- 是否处于新手指引中
function GuideSystem:isInGuidingState()

    if HomeGuideOne.isInGuiding or
        PveGuideOne.isInGuiding or
        PveGuideTwo.isInGuiding or
        PveGuideThree.isInGuiding or
        PveGuideFour.isInGuiding or
        PveGuideFive.isInGuiding or
        SkillGuideOne.isInGuiding or
        LevelRewardGuideOne.isInGuiding or
        LotteryGuideOne.isInGuiding or
        HeroGuideOneEx.isInGuiding or
        PveGuideSix.isInGuiding or
        LevelRewardGuideTwo.isInGuiding or
        HeroGuideTwo.isInGuiding or
        ArenaGuideOne.isInGuiding or
        ArenaGuideTwo.isInGuiding or
        TaskGuideOne.isInGuiding or
        EquipGuideOne.isInGuiding or
        FuckTimeGuideOne.isInGuiding or
        GonghuiGuideOne.isInGuiding or
        DayDayUpGuideOne.isInGuiding or
        EquipGuideTwo.isInGuiding or
        HardPveGuideOne.isInGuiding or
        WorldBossGuideOne.isInGuiding or
        ParkGuideOne.isInGuiding or
        TiantiGuideOne.isInGuiding or
        LevelRewardGuideZero.isInGuiding or
        PveGuide1_5.isInGuiding or
        PveGuide1_6.isInGuiding or
        PveGuide1_7.isInGuiding or
        LevelRewardGuideOnePointFive.isInGuiding or
        TaskGuideZero.isInGuiding or
        HeroHorseGuide.isInGuiding or
        HeroWeaponGuide.isInGuiding or
        BadgeGuideOne.isInGuiding or
        BlackMarketGuide.isInGuiding or
        TechnologyGuideOne.isInGuiding then
            return true
    else
            return false
    end

end

-- 创建指引数据
function GuideSystem:createGuideData(msgPacket)
    -- 生成默认指引信息
    msgPacket:PushUShort(40)

    for i = 1, 40 do
        msgPacket:PushChar(i)

        -- 初始开始步骤 
        if 3 == i or 4 == i or 6 == i or 7 == i or 17 == i then
            msgPacket:PushChar(1)
        else
            msgPacket:PushChar(0)
        end

        msgPacket:PushChar(0)
    end
end

-- 中断处理
function GuideSystem:recoverInterrupt()
    if needUseGuide then
    	-- 恢复中断
        HomeGuideOne:recoverInterrupt()
        PveGuideOne:recoverInterrupt()
        PveGuideTwo:recoverInterrupt()
        PveGuideThree:recoverInterrupt()
        PveGuideFour:recoverInterrupt()
        PveGuideFive:recoverInterrupt()
        SkillGuideOne:recoverInterrupt()
        LevelRewardGuideOne:recoverInterrupt()
        LotteryGuideOne:recoverInterrupt()
        HeroGuideOneEx:recoverInterrupt()
        PveGuideSix:recoverInterrupt()
        LevelRewardGuideTwo:recoverInterrupt()
        HeroGuideTwo:recoverInterrupt()
        ArenaGuideOne:recoverInterrupt()
        ArenaGuideTwo:recoverInterrupt()
        TaskGuideOne:recoverInterrupt()
        EquipGuideOne:recoverInterrupt()
        FuckTimeGuideOne:recoverInterrupt()
        GonghuiGuideOne:recoverInterrupt()
        DayDayUpGuideOne:recoverInterrupt()
        EquipGuideTwo:recoverInterrupt()
        HardPveGuideOne:recoverInterrupt()
        WorldBossGuideOne:recoverInterrupt()
        ParkGuideOne:recoverInterrupt()
        TiantiGuideOne:recoverInterrupt()
        LevelRewardGuideZero:recoverInterrupt()
        PveGuide1_5:recoverInterrupt()
        PveGuide1_6:recoverInterrupt()
        PveGuide1_7:recoverInterrupt()
        LevelRewardGuideOnePointFive:recoverInterrupt()
        TaskGuideZero:recoverInterrupt()
        HeroHorseGuide:recoverInterrupt()
        HeroWeaponGuide:recoverInterrupt()
        BadgeGuideOne:recoverInterrupt()
        BlackMarketGuide:recoverInterrupt()
        TechnologyGuideOne:recoverInterrupt()
        -- PveGuideOne:recoverInterrupt()
        -- PveGuideTwo:recoverInterrupt()
        -- RealTimePkGuideOne:recoverInterrupt()
        -- EquipGuideThree:recoverInterrupt()
        -- ArenaGuideTwo:recoverInterrupt()
        -- PveGuideFive:recoverInterrupt()
        -- PveGuideSeven:recoverInterrupt()
        -- PveGuideEight:recoverInterrupt()
        -- PveGuideNine:recoverInterrupt()
        -- HeroGuideThree:recoverInterrupt()
        -- PveGuideTen:recoverInterrupt()
        -- PveGuideEleven:recoverInterrupt()
        -- HeroGuideFour:recoverInterrupt()
    end
end

-- 中断处理(针对PVE)
function GuideSystem:recoverInterrupt_PVE()
    if needUseGuide then
        PveGuideOne:recoverInterrupt_PVE()
        PveGuideTwo:recoverInterrupt_PVE()
        PveGuideThree:recoverInterrupt_PVE()
        PveGuideFive:recoverInterrupt_PVE()
        LevelRewardGuideOne:recoverInterrupt_PVE()
        PveGuideSix:recoverInterrupt_PVE()
        LevelRewardGuideTwo:recoverInterrupt_PVE()
        ArenaGuideOne:recoverInterrupt_PVE()
        TaskGuideOne:recoverInterrupt_PVE()
        EquipGuideOne:recoverInterrupt_PVE()
        HardPveGuideOne:recoverInterrupt_PVE()
        PveGuide1_5:recoverInterrupt_PVE()
        PveGuide1_6:recoverInterrupt_PVE()
        PveGuide1_7:recoverInterrupt_PVE()
        LevelRewardGuideOnePointFive:recoverInterrupt_PVE()
        TaskGuideZero:recoverInterrupt_PVE()
        -- PveGuideTwo:recoverInterrupt_PVE()
        -- PveGuideFour:recoverInterrupt_PVE()
        -- PveGuideSeven:recoverInterrupt_PVE()
        -- PveGuideEight:recoverInterrupt_PVE()
        -- PveGuideTen:recoverInterrupt_PVE()
    end
end

-- 获取指定指引的步数
function GuideSystem:getStepByGuideType(guideType)
--	if self.guideData[guideType] then
--		return self.guideData[guideType].mStep
--	end
    for i = 1, #self.guideData do
        if guideType == self.guideData[i].mId then
            return self.guideData[i].mStep
        end
    end
end

-- 设置指定指引的步数
function GuideSystem:setStepByGuideType(guideType, guideStep)
--	if self.guideData[guideType] then
--		self.guideData[guideType].mStep = guideStep
--	end
    for i = 1, #self.guideData do
        if guideType == self.guideData[i].mId then
            self.guideData[i].mStep = guideStep
            return
        end
    end
end

-- 获取指定指引的结果
function GuideSystem:getFinishByGuideType(guideType)
--	if self.guideData[guideType] then
--		return self.guideData[guideType].mFinish
--	end
    for i = 1, #self.guideData do
        if guideType == self.guideData[i].mId then
            return self.guideData[i].mFinish
        end
    end
end

-- 设置指定指引的结果
function GuideSystem:setFinishByGuideType(guideType, guideFinish)
--	if self.guideData[guideType] then
--		self.guideData[guideType].mFinish = guideFinish
--	end
    for i = 1, #self.guideData do
        if guideType == self.guideData[i].mId then
            self.guideData[i].mFinish = guideFinish
            return
        end
    end
end

-- 创建指引层
function GuideSystem:createGuideLayer(touchRect, animName)
	local mainLayer = cc.Layer:create()

--	local guideLayer = cc.ClippingNode:create()
    local drawNode = cc.Sprite:create("guide_area.png")
    drawNode:setAnchorPoint(cc.p(0.5, 0.5))
    drawNode:setScale(4)

    mainLayer:addChild(drawNode)
    drawNode:setPosition(cc.p(touchRect.x + touchRect.width/2, touchRect.y + touchRect.height/2)) 

	local function onTouchBegan(touch, event)
		local location = touch:getLocation()
		if cc.rectContainsPoint(touchRect, location) then -- 点击矩形框
			return false
		else
			return true
		end
	end

	local function onTouchMoved(touch, event)
	end

	local function onTouchEnded(touch, event)
	end

	local function onTouchCancelled(touch, event)
	end


	local colorLayer = cc.LayerColor:create(G_COLOR_C4B.WHITE)
	local listener = cc.EventListenerTouchOneByOne:create()
	listener:setSwallowTouches(true)
	listener:registerScriptHandler(onTouchBegan,cc.Handler.EVENT_TOUCH_BEGAN )
    listener:registerScriptHandler(onTouchMoved,cc.Handler.EVENT_TOUCH_MOVED )
    listener:registerScriptHandler(onTouchEnded,cc.Handler.EVENT_TOUCH_ENDED )
    listener:registerScriptHandler(onTouchCancelled,cc.Handler.EVENT_TOUCH_CANCELLED )
    local eventDispatcher = colorLayer:getEventDispatcher()
    eventDispatcher:addEventListenerWithSceneGraphPriority(listener, mainLayer)

    -- 创建箭头
    local arrowLayer = cc.Layer:create()
    local animNode = AnimManager:createAnimNode(8024)
    arrowLayer:addChild(animNode:getRootNode(), 100)
    animNode:setPosition(cc.p(touchRect.x+touchRect.width/2, touchRect.y+touchRect.height/2))
    if not animName then
        animNode:play("guide_hand", true)
    else
        animNode:play(animName, true)
    end
    mainLayer:addChild(arrowLayer)

    return mainLayer
end

-- 创建指引层
function GuideSystem:createGuideLayerForcircle(touchRect)
    local mainLayer = cc.Layer:create()

--  local guideLayer = cc.ClippingNode:create()
    local drawNode = cc.Sprite:create("guide_area.png")
    drawNode:setAnchorPoint(cc.p(0.5, 0.5))
    drawNode:setScale(4)

    mainLayer:addChild(drawNode)
    drawNode:setPosition(cc.p(touchRect.x + touchRect.width/2, touchRect.y + touchRect.height/2)) 

    local function onTouchBegan(touch, event)
        local location = touch:getLocation()
        if cc.rectContainsPoint(touchRect, location) then -- 点击矩形框
            return false
        else
            return true
        end
    end

    local function onTouchMoved(touch, event)
    end

    local function onTouchEnded(touch, event)
    end

    local function onTouchCancelled(touch, event)
    end


    local colorLayer = cc.LayerColor:create(G_COLOR_C4B.WHITE)
    local listener = cc.EventListenerTouchOneByOne:create()
    listener:setSwallowTouches(true)
    listener:registerScriptHandler(onTouchBegan,cc.Handler.EVENT_TOUCH_BEGAN )
    listener:registerScriptHandler(onTouchMoved,cc.Handler.EVENT_TOUCH_MOVED )
    listener:registerScriptHandler(onTouchEnded,cc.Handler.EVENT_TOUCH_ENDED )
    listener:registerScriptHandler(onTouchCancelled,cc.Handler.EVENT_TOUCH_CANCELLED )
    local eventDispatcher = colorLayer:getEventDispatcher()
    eventDispatcher:addEventListenerWithSceneGraphPriority(listener, mainLayer)

    -- 创建箭头
    local arrowLayer = cc.Layer:create()
    local animNode = AnimManager:createAnimNode(8049)
    arrowLayer:addChild(animNode:getRootNode(), 100)
    animNode:setPosition(cc.p(touchRect.x+touchRect.width/2, touchRect.y+touchRect.height/2))
    animNode:play("guide_circle", true)
    mainLayer:addChild(arrowLayer)

    return mainLayer
end

-- 创建指引层
function GuideSystem:createNoneLayer(touchRect, callBackFunc)
    local mainLayer = cc.Layer:create()

--  local guideLayer = cc.ClippingNode:create()
--    local drawNode = cc.Sprite:create("guide_area.png")
--    drawNode:setAnchorPoint(cc.p(0.5, 0.5))
--    drawNode:setScale(4)

--    mainLayer:addChild(drawNode)
--    drawNode:setPosition(cc.p(touchRect.x + touchRect.width/2, touchRect.y + touchRect.height/2)) 

    local function onTouchBegan(touch, event)
    --    local location = touch:getLocation()
    --    if cc.rectContainsPoint(touchRect, location) then -- 点击矩形框
    --        return false
    --    else
            return true
    --    end
    end

    local function onTouchMoved(touch, event)
    end

    local function onTouchEnded(touch, event)
        if callBackFunc then
            callBackFunc()
        end
    end

    local function onTouchCancelled(touch, event)
    end


    local colorLayer = cc.LayerColor:create(G_COLOR_C4B.WHITE)
    local listener = cc.EventListenerTouchOneByOne:create()
--    listener:setSwallowTouches(true)
    listener:registerScriptHandler(onTouchBegan,cc.Handler.EVENT_TOUCH_BEGAN )
    listener:registerScriptHandler(onTouchMoved,cc.Handler.EVENT_TOUCH_MOVED )
    listener:registerScriptHandler(onTouchEnded,cc.Handler.EVENT_TOUCH_ENDED )
    listener:registerScriptHandler(onTouchCancelled,cc.Handler.EVENT_TOUCH_CANCELLED )
    local eventDispatcher = colorLayer:getEventDispatcher()
    eventDispatcher:addEventListenerWithSceneGraphPriority(listener, mainLayer)

    -- 创建箭头
    -- local arrowLayer = cc.Layer:create()
    -- local animNode = AnimManager:createAnimNode(8024)
    -- arrowLayer:addChild(animNode:getRootNode(), 100)
    -- animNode:setPosition(cc.p(touchRect.x+touchRect.width/2, touchRect.y+touchRect.height/2))
    -- animNode:play("guide_hand", true)
    -- mainLayer:addChild(arrowLayer)

    return mainLayer
end

-- 创建矩形框
function GuideSystem:createOriginalShowLayer(touchRect, callBackFunc)
    local mainLayer = cc.Layer:create()

    local layout = ccui.Layout:create()
    layout:setContentSize(cc.size(1140, 770))
    layout:setTouchEnabled(true)
    mainLayer:addChild(layout)
    layout:setPosition(cc.p(0, 0))

    -- 遮罩层
    local guideLayer = cc.ClippingNode:create()
    local drawNode = cc.DrawNode:create()
    guideLayer:setStencil(drawNode)
    guideLayer:setInverted(true)
    local vertices = 
    {   
        cc.p(touchRect.x, touchRect.y), 
        cc.p(touchRect.x, touchRect.y + touchRect.height), 
        cc.p(touchRect.x + touchRect.width, touchRect.y + touchRect.height), 
        cc.p(touchRect.x + touchRect.width, touchRect.y)
    }
    drawNode:drawPolygon(vertices, table.getn(vertices), cc.c4f(1,0,0,0.5), 4, cc.c4f(0,0,1,1))
    mainLayer:addChild(guideLayer)

    -- 颜色层
    local colorLayer = cc.LayerColor:create(cc.c4b(0,0,0,180))
    guideLayer:addChild(colorLayer)

    registerWidgetReleaseUpEvent(layout, callBackFunc)
    return mainLayer
end

-- 創建展示層
function GuideSystem:createShowLayer(touchRect, callBackFunc, noAnimNode)
    local mainLayer = cc.Layer:create()

    -- 遮罩
    if not noAnimNode then
        local drawNode = cc.Sprite:create("guide_area.png")
        drawNode:setAnchorPoint(cc.p(0.5, 0.5))
        drawNode:setScale(4)
        mainLayer:addChild(drawNode)
        drawNode:setPosition(cc.p(touchRect.x + touchRect.width/2, touchRect.y + touchRect.height/2))
    end

    local layout = ccui.Layout:create()
    layout:setContentSize(cc.size(1140, 770))
    layout:setTouchEnabled(true)
    mainLayer:addChild(layout)
    layout:setPosition(cc.p(0, 0))

    registerWidgetReleaseUpEvent(layout, callBackFunc)

    -- 创建箭头
    -- local arrowLayer = cc.Layer:create()
    -- local animNode = AnimManager:createAnimNode(8024)
    -- arrowLayer:addChild(animNode:getRootNode(), 100)
    -- animNode:setPosition(cc.p(touchRect.x+touchRect.width/2, touchRect.y+touchRect.height/2))
    -- animNode:play("guide_hand", true)
    -- mainLayer:addChild(arrowLayer)

    -- 创建特效
    if not noAnimNode then
        local arrowLayer = cc.Layer:create()
        local animNode = AnimManager:createAnimNode(8049)
        arrowLayer:addChild(animNode:getRootNode(), 100)
        animNode:setPosition(cc.p(touchRect.x+touchRect.width/2, touchRect.y+touchRect.height/2))
        animNode:play("guide_circle", true)
        mainLayer:addChild(arrowLayer)
    end

    return mainLayer
end

-- 創建展示層
function GuideSystem:createShowLayerWithoutColor(touchRect, callBackFunc)
    local mainLayer = cc.Layer:create()

--    local drawNode = cc.Sprite:create("guide_area.png")
--    drawNode:setAnchorPoint(cc.p(0.5, 0.5))
--    drawNode:setScale(4)

--    mainLayer:addChild(drawNode)
--    drawNode:setPosition(cc.p(touchRect.x + touchRect.width/2, touchRect.y + touchRect.height/2))

    local layout = ccui.Layout:create()
    layout:setContentSize(cc.size(1140, 770))
    layout:setTouchEnabled(true)
    mainLayer:addChild(layout)
    layout:setPosition(cc.p(0, 0))

    registerWidgetReleaseUpEvent(layout, callBackFunc)

    -- 创建箭头
    -- local arrowLayer = cc.Layer:create()
    -- local animNode = AnimManager:createAnimNode(8024)
    -- arrowLayer:addChild(animNode:getRootNode(), 100)
    -- animNode:setPosition(cc.p(touchRect.x+touchRect.width/2, touchRect.y+touchRect.height/2))
    -- animNode:play("guide_hand", true)
    -- mainLayer:addChild(arrowLayer)

    return mainLayer
end

-- 创建指引小姑娘
function GuideSystem:createGuideGirl(guideText)
	local widget = GUIWidgetPool:createWidget("Guide")
	--widget:setScale(0.7)
    local richText = richTextCreateWithFont(widget:getChildByName("Panel_Text"), guideText, true, 20, "font_3.ttf")
    richText:setVerAlignmentType(cc.RICHTEXT_VERALIGN_MIDDLE)
    return widget
end

-- 创建CG对话层
function GuideSystem:createGuideCGLayer(cgId, funcCallBack)
	self.mTalkOverfuncCall = funcCallBack
	local panel = self:CreateAllDialog()
	self:InitTalkList(cgId)
	if #self.mTalkList ~= 0 then
		local data = table.remove(self.mTalkList,1)
		self:PlayTalk(data[1],data[2])
	end
	return panel
end

-- 存对话表
function GuideSystem:InitTalkList(cgId)
    self.mTalkList = {}
    local data = DB_GuideCGSpeak.getDataById(cgId)
    for i=1,data.Number do
        local data = data[string.format("Speak_%d",i)]
        table.insert(self.mTalkList,data)
    end
end

function GuideSystem:TalkNext()
    if #self.mTalkList ~= 0 then
    	local data = table.remove(self.mTalkList,1)
        self:PlayTalk(data[1],data[2])
    else
    	if self.mTalkOverfuncCall then
            self.layer = nil
    		self.mTalkOverfuncCall()
    		self.mTalkOverfuncCall = nil
    	end
    end
end

--对话点击
function GuideSystem:TouchEventTalk()
    --
    if self.mRunLabel then
        richTextCreateWithFont(self.mLabel,self.Strtext , true,25)
        self.mLabel:stopAllActions()
        self.mRunLabel = false
        self:StopTalkAction(self.Curplace)
    else
        if self.layer then
            self.layer:setEnabled(false)
        end
        self:TalkNext()
    end
end

function GuideSystem:StopTalkAction(index)
    local head1 = self.mDialogTable[1]["head"]
    local head2 = self.mDialogTable[2]["head"]
    if index == 1 then
        self.mTalkBoxLeft:stopAllActions()
        self.mTalkBoxRight:stopAllActions()
        head1:stopAllActions()
        head2:stopAllActions()
        self.mTalkBoxLeft:setVisible(true)
        self.mTalkBoxRight:setVisible(false)
        head1:setVisible(true)
        head1:setOpacity(255)
        head2:setVisible(false)
        self.mTalkBoxLeft:setOpacity(255)
        self.mTalkBoxRight:setOpacity(255)
        head1:setPosition(self.CurHeadpos1)
    elseif index == 2 then
        self.mTalkBoxLeft:stopAllActions()
        self.mTalkBoxRight:stopAllActions()
        head1:stopAllActions()
        head2:stopAllActions()
        self.mTalkBoxLeft:setVisible(false)
        self.mTalkBoxRight:setVisible(true)
        head1:setVisible(false)
        head2:setVisible(true)
        head2:setOpacity(255)
        self.mTalkBoxLeft:setOpacity(255)
        self.mTalkBoxRight:setOpacity(255)
        head2:setPosition(self.CurHeadpos2)
    end
end


--播放对话
function GuideSystem:PlayTalk(id,Param1)
    if id == 0 or id== -1 then
        self.Curplace = 1
    else
        self.Curplace = 2
    end
    local _resDB = nil
    local heroName = nil
    if id == -1 then
        local _heroID = globaldata:getBattleFormationInfoByIndexAndKey(1, "id")
        local _infoDB = DB_HeroConfig.getDataById(_heroID)
        heroName = getDictionaryText(_infoDB.Name)
        _resDB = DB_ResourceList.getDataById(_infoDB.IconCG)
    elseif id == 0 then
        local _heroID = globaldata.registerHeroId
        local _infoDB = DB_HeroConfig.getDataById(_heroID)
        heroName = getDictionaryText(_infoDB.Name)
        _resDB = DB_ResourceList.getDataById(_infoDB.IconCG)
    else
        local _infoDB = DB_MonsterConfig.getDataById(id)
        heroName = getDictionaryText(_infoDB.Name)
        _resDB = DB_ResourceList.getDataById(_infoDB.IconCG)
    end
    local head = self.mDialogTable[self.Curplace]["head"]

    self.mLabel = self.mDialogTable[self.Curplace]["labeltalk"]

    self.Strtext = getDictionaryCGText(Param1)
    self.Strtext = TextParseManager:parseText(self.Strtext)
    
    self.tableText = splitChineseString( self.Strtext)

    self.index = 0

    self.mRunLabel = true
    self.mLabel:stopAllActions()
    self.mLabel:removeAllChildren()

    local function ShowBoxFinish()
         local function doSomthing()
            if self.index == #self.tableText then
                self.mLabel:stopAllActions()
                richTextCreateWithFont(self.mLabel,self.Strtext , true,25)
                CommonAnimation.PlayEffectId(35)
                self.mRunLabel = false
            else
                self.index = self.index + 1
                --self.mLabel:setString(self.tableText[self.index])
                richTextCreateWithFont(self.mLabel,self.tableText[self.index] , true,25)
                if self.index%2 == 1 then
                    CommonAnimation.PlayEffectId(35)
                end
            end
          end

        local headfun = cc.CallFunc:create(doSomthing)
        local DelayTime = cc.DelayTime:create(self.CGPlaySpeed)
        self.mLabel:runAction(cc.RepeatForever:create(cc.Sequence:create(headfun, DelayTime)))
    end 
    head:setVisible(true)
    head:loadTexture(_resDB.Res_path1)--"skill_22_1.png"
    local width = 0--head:getBoundingBox().width/2
    local height = 0--head:getBoundingBox().height/2
    local Flag = false
    if not self.mTalkBoxLeft:isVisible() and not self.mTalkBoxRight:isVisible() then
        self.mArrow_l:setVisible(true)
        self.mArrow_l:setOpacity(0)
        local actionTo1 = cc.FadeIn:create(0.2)
        self.mArrow_l:runAction(actionTo1)
    end

    if self.Curplace == 1 then
        self.mDialogTable[1]["labelname"]:setString(heroName)
        self.Movepos1 = cc.p(0,0)
        local time = 0
        if self.mTalkBoxRight:isVisible() then
            local act1 = cc.FadeOut:create(0.2)
            local act2 = cc.Hide:create()
            local action1 = cc.Sequence:create(act1,act2)
            self.mTalkBoxRight:runAction(action1)
            local player = self.mDialogTable[2]["head"]
            local pos = cc.p(player:getPosition())
            local move = cc.MoveTo:create(0.2,cc.p(self.CurHeadpos2.x+player:getBoundingBox().width,self.CurHeadpos2.y))
            local act1 = cc.FadeOut:create(0.2)
            local acthide = cc.Hide:create()
            local act3 = cc.Spawn:create(move,act1)
            player:runAction(cc.Sequence:create(act3,acthide))
            time = 0.2
        end
        if  not self.mTalkBoxLeft:isVisible() then
            self.mTalkBoxLeft:setVisible(true)
            self.mTalkBoxLeft:setOpacity(0)
            local actionTo1 = cc.FadeIn:create(time+0.2)
            self.mTalkBoxLeft:runAction(actionTo1)

            head:setPositionX(self.CurHeadpos1.x - head:getBoundingBox().width)
            local DelayTime = cc.DelayTime:create(time+0.2)
            local function Func()
                head:setOpacity(0) 
            end
            local headfun = cc.CallFunc:create(Func)
            local act1 = cc.FadeIn:create(0.2)
            local move = cc.MoveTo:create(0.2,self.CurHeadpos1)
            local act2 = cc.Spawn:create(move,act1)
            local call1 = cc.CallFunc:create(ShowBoxFinish)
            local action1 = cc.Sequence:create(DelayTime,headfun,act2,call1)
            head:runAction(action1)
            Flag = true
        end

    elseif self.Curplace == 2 then
        self.mDialogTable[2]["labelname"]:setString(heroName)
        local time = 0
        if self.mTalkBoxLeft:isVisible() then
            local act1 = cc.FadeOut:create(0.2)
            local act2 = cc.Hide:create()
            local action1 = cc.Sequence:create(act1,act2)
            self.mTalkBoxLeft:runAction(action1)
            local player = self.mDialogTable[1]["head"]
            local pos = cc.p(player:getPosition())
            local move = cc.MoveTo:create(0.2,cc.p(self.CurHeadpos1.x-player:getBoundingBox().width,self.CurHeadpos1.y))
            local act1 = cc.FadeOut:create(0.2)
            local acthide = cc.Hide:create()
            local act3 = cc.Spawn:create(move,act1)
            player:runAction(cc.Sequence:create(act3,acthide))
            time = 0.2
        end
        if  not self.mTalkBoxRight:isVisible() then
            self.mTalkBoxRight:setVisible(true)
            self.mTalkBoxRight:setOpacity(0)
            head:setPositionX(self.CurHeadpos2.x + head:getBoundingBox().width)
            local actionTo1 = cc.FadeIn:create(time+0.2)
            self.mTalkBoxRight:runAction(actionTo1)
            head:setVisible(true)
            local DelayTime = cc.DelayTime:create(time+0.2)
            local function Func()
                head:setOpacity(0) 
            end
            local headfun = cc.CallFunc:create(Func)
            local act1 = cc.FadeIn:create(0.2)
            local move = cc.MoveTo:create(0.2,self.CurHeadpos2)
            local act2 = cc.Spawn:create(move,act1)
            local call1 = cc.CallFunc:create(ShowBoxFinish)
            local action1 = cc.Sequence:create(DelayTime,headfun,act2,call1)
            head:runAction(action1)
            Flag = true
        end
    end
    if not Flag  then
        local function doSomthing1()
            if self.index == #self.tableText then
                self.mLabel:stopAllActions()
                richTextCreateWithFont(self.mLabel,self.Strtext , true,25)
                CommonAnimation.PlayEffectId(35)
                self.mRunLabel = false
            else
                self.index = self.index + 1
                --self.mLabel:setString(self.tableText[self.index])
                richTextCreateWithFont(self.mLabel,self.tableText[self.index] , true,25)
                if self.index%2 == 1 then
                    CommonAnimation.PlayEffectId(35)
                end
            end
        end
        local headfun = cc.CallFunc:create(doSomthing1)
        local DelayTime = cc.DelayTime:create(self.CGPlaySpeed)
        self.mLabel:runAction(cc.RepeatForever:create(cc.Sequence:create(headfun, DelayTime)))
    end
    self.layer:setEnabled(true)
end

-- 创建当前对话框
function GuideSystem:CreateAllDialog()
   -- local Widget1 = GUIWidgetPool:createWidget("CGShade")
    local WidgetTalk = GUIWidgetPool:createWidget("CGTalkText")
    self.mTalkBoxLeft = WidgetTalk:getChildByName("Image_Talk_BoxLeft")
    self.mArrow_l = WidgetTalk:getChildByName("Panel_Arrow") 
    local _resDB = DB_ResourceList.getDataById(612)
    
    local animNode = AnimManager:createAnimNode(8022)
    self.mArrow_l:addChild(animNode:getRootNode(), 100)
    animNode:play("cg_arrow_next", true)

    self.mTalkBoxRight = WidgetTalk:getChildByName("Image_Talk_BoxRight")
   
    for i=1,2 do
        local  head = nil
        local point = nil
        local labeltalk = nil
        local labelname = nil
        if i == 1 then
            --point =  cc.p(getGoldFightPosition_LD().x+130,getGoldFightPosition_LD().y-200)
            labeltalk = self.mTalkBoxLeft:getChildByName("Label_CG_Talk")
            labelname = self.mTalkBoxLeft:getChildByName("Label_Name")
            head = WidgetTalk:getChildByName("Panel_Main_Left"):getChildByName("Image_CG_HalfHead")
            head:setVisible(false)
        elseif i == 2 then
            --point =  cc.p(getGoldFightPosition_RD().x-130,getGoldFightPosition_RD().y-200)
            labeltalk = self.mTalkBoxRight:getChildByName("Label_CG_Talk")
            labelname = self.mTalkBoxRight:getChildByName("Label_Name")
            head = WidgetTalk:getChildByName("Panel_Main_Right"):getChildByName("Image_CG_HalfHead")
            head:setVisible(false)
        end
        self.mDialogTable[i] = {["head"] = head,["labeltalk"] = labeltalk,["labelname"] = labelname}
        --head:setPosition(point)
    end
    self.CurHeadpos1 = cc.p(self.mDialogTable[1]["head"]:getPositionX()-150,self.mDialogTable[1]["head"]:getPositionY())
    self.CurHeadpos2 = cc.p(self.mDialogTable[2]["head"]:getPositionX()+150,self.mDialogTable[2]["head"]:getPositionY())

    self.mDialogTable[1]["head"]:setPosition(self.CurHeadpos1)
    self.mDialogTable[2]["head"]:setPosition(self.CurHeadpos2)
    --WidgetTalk:setPosition(cc.p(getGoldFightPosition_Middle().x,getGoldFightPosition_LD().y))
    local function doSomething()
        WidgetTalk:getChildByName("Panel_Main_Left"):setPosition(getGoldFightPosition_LD())
        WidgetTalk:getChildByName("Panel_Main_Right"):setPosition(getGoldFightPosition_RD())
        WidgetTalk:getChildByName("Panel_Next"):setPosition(getGoldFightPosition_RD())
    end 
    doSomething()
    self.layer = WidgetTalk:getChildByName("Panel_Shade_layer")
    registerWidgetReleaseUpEvent(self.layer,handler(self,self.TouchEventTalk))
    self.layer:setEnabled(false)
    return WidgetTalk
end
