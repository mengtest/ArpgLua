-- Name:    SpineGhost
-- Func：   Spine残影
-- Author:  Johny

SpineGhost = class("SpineGhost", function()
   return cc.Sprite:create()
end)

------------------------局部变量-----------------
local CANVAS_INIT_SIZE          = cc.size(256,256)  --画布初始大小
local CANVAS_INIT_SIZE_MID      = cc.size(512,512)  --画布初始大小
local CANVAS_INIT_SIZE_MAX      = cc.size(1024,1024)  --画布初始大小
-- 需要使用最大size的spine影子
local CANVAS_MAXSIZE_MAP = {}
CANVAS_MAXSIZE_MAP["res/spine/binary/role/huachenyi.atlas"] = true
-- 需要使用中间size的spine影子
local CANVAS_MIDSIZE_MAP = {}
CANVAS_MIDSIZE_MAP["res/spine/binary/role/piyinan.atlas"] = true
CANVAS_MIDSIZE_MAP["res/spine/binary/role/lvjiake.atlas"] = true
--------------------------------------------------

function SpineGhost:ctor()
    -- body
end

--加残影
--@_spine spine
--@_during 持续时间
function SpineGhost:generate(_spine, _during)
    local size = _spine:getBoundingBox()
    local posx,posy = _spine:getPosition()
    if size.width < 1 then
        return
    end
    ------------创建画布，并把主体画上--------
    local _scale = _spine:getScale()
    local canvasSize = CANVAS_INIT_SIZE
    if CANVAS_MAXSIZE_MAP[_spine:getAtlasFileName()] then
        canvasSize = CANVAS_INIT_SIZE_MAX
    elseif CANVAS_MIDSIZE_MAP[_spine:getAtlasFileName()] then
        canvasSize = CANVAS_INIT_SIZE_MID
    end
    local canvas = cc.RenderTexture:create(canvasSize.width , canvasSize.height, cc.PixelFormat.RGBA4444)
    _spine:setPosition(canvasSize.width/2,0)
    canvas:begin()
    _spine:visit()
    canvas:endToLua()
    cc.Director:getInstance():getRenderer():render()
    _spine:setPosition(posx,posy)
    ------------将画布载入精灵并渲染出来--------
    local _tex = canvas:getSprite():getTexture()
    local _texSize = _tex:getContentSize()
    local _rect = cc.rect(0,0,_texSize.width, _texSize.height)
    self:setTexture(_tex)
    self:setTextureRect(_rect)
    self:setAnchorPoint(0.5,0)
    self:setFlippedY(true);
    local fade = cc.Sequence:create(cc.FadeTo:create(_during, 0),cc.CallFunc:create(function ()
        self:removeFromParent()
    end))
    self:runAction(fade)
end