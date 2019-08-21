-- Name: 	PlayerFunctionController
-- Func: 	功能开启控制器
-- Author: 	Wangsd
-- Data:	15-9-21
-- PS:  在GUIWidgetPool中初始化


PlayerFunctionController = 
{
	mFuncCnt	=	0,	-- 需要控制的功能数
}

-- 初始化
function PlayerFunctionController:init()
	self.mFuncCnt = 0
	for k, v in pairs(DB_PlayerEXP.PlayerEXP) do
		self.mFuncCnt = self.mFuncCnt + 1	
	end
end

-- 刷新
function PlayerFunctionController:update()
	local window = GUISystem:GetWindowByName("HomeWindow")
	if not window.mRootNode then -- 窗口不在，就返回
		return
	end

	local parentNode = window.mRootWidget

	for i = 1, self.mFuncCnt do
		local expData = DB_PlayerEXP.getDataById(i)
		if expData.Player_Level > globaldata.level then -- 未达到等级
			if 1 == expData.Lock then
			-- 按钮置灰
			ShaderManager:DoUIWidgetDisabled(parentNode:getChildByName(expData.Function_Button), true)	
			-- 按钮禁用
			parentNode:getChildByName(expData.Function_Button):setTouchEnabled(false)
			local lockWidget = parentNode:getChildByName(expData.Function_Father):getChildByName("Image_Lock")
			-- 显示锁头
			lockWidget:setVisible(true)
			-- 锁头
			lockWidget:setTouchEnabled(true)

			local function showLockInfo()
				local infoWidget = GUIWidgetPool:createWidget("NewHome_FunctionLock")	
				GUISystem.RootNode:addChild(infoWidget, GUISYS_ZORDER_MESSAGEBOXWINDOW)

				-- 关闭
				local function delWindow()
					infoWidget:removeFromParent(true)
					infoWidget = nil
				end
				
				infoWidget:getChildByName("Panel_Main"):setOpacity(0)

				local act0 = cc.FadeIn:create(0.03)
				local act1 = cc.DelayTime:create(2)
				local act2 = cc.FadeOut:create(0.03)
				local act3 = cc.CallFunc:create(delWindow)
				infoWidget:runAction(cc.Sequence:create(act0, act1, act2, act3))

				-- 文字
				richTextCreateWithFont(infoWidget:getChildByName("Panel_FunctionLock"), string.format("达到 #51fdff%d# 级,可以进入 #45ff41%s#。", expData.Player_Level, getDictionaryText(expData.Function_Name)), true, 22)

				-- 图标
				infoWidget:getChildByName("Image_Icon"):loadTexture(expData.Player_Icon)
			end
			registerWidgetPushDownEvent(lockWidget, showLockInfo)

			elseif 2 == expData.Lock then
				parentNode:getChildByName(expData.Function_Father):setVisible(false)
			end
		elseif expData.Player_Level <= globaldata.level then -- 达到等级
			if 1 == expData.Lock then
				-- 按钮恢复
				ShaderManager:DoUIWidgetDisabled(parentNode:getChildByName(expData.Function_Button), false)	
				-- 按钮恢复
				parentNode:getChildByName(expData.Function_Button):setTouchEnabled(true)
				local lockWidget = parentNode:getChildByName(expData.Function_Father):getChildByName("Image_Lock")
				-- 隐藏锁头
				lockWidget:setVisible(false)
				-- 锁头禁用
				lockWidget:setTouchEnabled(false)
			elseif 2 == expData.Lock then
				parentNode:getChildByName(expData.Function_Father):setVisible(true)
			end

			
		end
	end
end