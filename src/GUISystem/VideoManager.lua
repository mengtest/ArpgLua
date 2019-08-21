-- Name: 	VideoManager
-- Func：	视频管理
-- Author:	WangShengdong
-- Data:	16-5-3

require("experimentalConstants")

videoObject = {}

function videoObject:new()
	local o = 
	{
		mRootNode		=	nil,    -- 跟节点
		mVideoNode		=	nil,	-- 动画节点
		mCallBackFunc
	}
	o = newObject(o, videoObject)
	return o
end

function videoObject:init(callBackFunc)
	self.mRootNode = cc.Node:create()

	self.mCallBackFunc = callBackFunc

	local function onVideoEventCallback(sener, eventType)
		if self.mCallBackFunc then
			self.mCallBackFunc(eventType)
		end
    end

    self.mVideoNode = ccexp.VideoPlayer:create()
    self.mVideoNode:setPosition(centerPos)
    self.mVideoNode:setAnchorPoint(cc.p(0.5, 0.5))
    self.mVideoNode:addEventListener(onVideoEventCallback)
    self.mRootNode:addChild(self.mVideoNode)
end

function videoObject:destroy()
	self.mRootNode:removeFromParent(true)
	self.mRootNode = true
end

function videoObject:getRootNode()
	return self.mRootNode
end

function videoObject:setPosition(pos)
	self.mRootNode:setPosition(pos)
end

function videoObject:play(fileName)
	self.mVideoNode:setFileName(fileName)
    self.mVideoNode:play()
end

function videoObject:setContentSize(sz)
	self.mVideoNode:setContentSize(sz)
end



