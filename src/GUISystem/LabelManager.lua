-- Name: 	LabelManager
-- Func：	标签管理器,均为静态方法
-- Author:	Johny

--------------局部变量----------------
local OUTLINE_SCALE  =  0.08

--------------------------------------

LabelManager = {}

-- _label: CCLabelTTF
function LabelManager:removeOutline(_label)
	_label:enableOutline(G_COLOR_C4B.CLEAR, 0)
end

--[[ 
	_label: UIText
	_color4b: cc.c4b
	设置字体size需要在调用该函数之前
]]
function LabelManager:outline(_label, _color4b)
	if not _color4b then 
		_color4b = G_COLOR_C4B.BLACK
	end
	local _fs = _label:getFontSize()
	local _outlineSize = _fs * OUTLINE_SCALE
	_label:enableOutline(_color4b, _outlineSize)
end

--[[
	_label: UIText
	_color3b: cc.c4b
]]
function LabelManager:setFontColor(_label, _color4b)
	_label:enableGlow(_color4b)
end
