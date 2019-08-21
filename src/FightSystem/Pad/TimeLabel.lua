-- Name: TimeLabelController
-- Func: 时间显示器
-- Author: tuanzhang

TimeLabelController = class("TimeLabelController",function()
  return cc.Node:create()
end)


function TimeLabelController:ctor(_num)
    self:InitNum(_num)
end

function TimeLabelController:Destroy()

end

function TimeLabelController:InitNum(_num)

   local secend =  _num%60
   local min = math.floor(_num/60)
   local  secend_str = string.format("%02d",secend)
   local  min_str = string.format("%02d",min)
    local nodeLabel = cc.Node:create()
    self:addChild(nodeLabel)
        
    self._lbsec = cc.LabelBMFont:create(secend_str,  "res/fonts/font_arena_ranking1.fnt")
    self._lbsec:setAnchorPoint(cc.p(0,0.5))
    nodeLabel:addChild(self._lbsec)

    self._lbmin = cc.LabelBMFont:create(min_str,  "res/fonts/font_arena_ranking1.fnt") 
    self._lbmin:setAnchorPoint(cc.p(1,0.5))
    nodeLabel:addChild(self._lbmin)
end


function TimeLabelController:SetTime(_num)

   local secend =  _num%60
   local min = math.floor(_num/60)
   local  secend_str = string.format("%02d",secend)
   local  min_str = string.format("%02d",min)
   self._lbsec:setString(secend_str)
   self._lbmin:setString(min_str)
end