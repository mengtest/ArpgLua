-- Name: ShaderManager
-- Func: Shader效果处理器，处理传入的精灵
-- Author: Johny

ShaderManager = {}

local vertDefaultSource = "\n".."\n" ..
                  "attribute vec4 a_position;\n" ..
                  "attribute vec2 a_texCoord;\n" ..
                  "attribute vec4 a_color;\n\n" ..
                  "\n#ifdef GL_ES\n" .. 
                  "varying lowp vec4 v_fragmentColor;\n" ..
                  "varying mediump vec2 v_texCoord;\n" ..
                  "\n#else\n" ..
                  "varying vec4 v_fragmentColor;" ..
                  "varying vec2 v_texCoord;" ..
                  "\n#endif\n" ..
                  "void main()\n" ..
                  "{\n" .. 
                  "   gl_Position = CC_PMatrix * a_position;\n"..
                  "   v_fragmentColor = a_color;\n"..
                  "   v_texCoord = a_texCoord;\n" ..
                  "} \n"

local vertDefaultSource_spine = "\n".."\n" ..
                          "attribute vec4 a_position;\n" ..
                          "attribute vec2 a_texCoord;\n" ..
                          "attribute vec4 a_color;\n\n" ..
                          "\n#ifdef GL_ES\n" .. 
                          "varying lowp vec4 v_fragmentColor;\n" ..
                          "varying mediump vec2 v_texCoord;\n" ..
                          "\n#else\n" ..
                          "varying vec4 v_fragmentColor;" ..
                          "varying vec2 v_texCoord;" ..
                          "\n#endif\n" ..
                          "void main()\n" ..
                          "{\n" .. 
                          "   gl_Position = CC_MVPMatrix * a_position;\n"..
                          "   v_fragmentColor = a_color;\n"..
                          "   v_texCoord = a_texCoord;\n" ..
                          "} \n"

function ShaderManager:Init()

end

function ShaderManager:Release()
  _G["ShaderManager"] = nil
  package.loaded["ShaderManager"] = nil
  package.loaded["GUISystem/ShaderManager"] = nil
end


-- private func
local function _getGLProgram(_vsh, _fshFile, _GlProKey)
  local fshFilekey = _fshFile
  if _GlProKey then
   fshFilekey =  string.format("%s%s",fshFilekey,_GlProKey)
  end
  local _glcache = cc.GLProgramCache:getInstance()
  local glProgram = _glcache:getGLProgram(fshFilekey)
  if not glProgram then
     local fileUtiles = cc.FileUtils:getInstance()
     local fragSource = fileUtiles:getStringFromFile(_fshFile)
	   glProgram = cc.GLProgram:createWithByteArrays(_vsh, fragSource)
     _glcache:addGLProgram(glProgram, fshFilekey)
  end

	return glProgram
end 

-- 清除shader缓存
function ShaderManager:clearShaderCache()
   cclog("ShaderManager:clearShaderCache")
   cc.GLProgramStateCache:getInstance():removeUnusedGLProgramState()
   cc.GLProgramCache:getInstance():purgeSharedShaderCache()
end


-- 还原特效
function ShaderManager:ResumeColor(_sp)
    local glProgramNormal = cc.GLProgramCache:getInstance():getGLProgram("ShaderPositionTextureColor_noMVP")
    _sp:setGLProgram(glProgramNormal)
end

-- 变色
function ShaderManager:ChangeColor(_sp, _vec4Color)
    local program = _getGLProgram(vertDefaultSource, "res/shader/toColor.fsh")
    local _state = cc.GLProgramState:getOrCreateWithGLProgram(program)
    _state:setUniformVec4("u_Color", _vec4Color)
    _sp:setGLProgramState(_state)
end

-- 禁用特效
function ShaderManager:Disabled(_sp)
    local program = _getGLProgram(vertDefaultSource, "res/shader/DisableShader.fsh")
    _sp:setGLProgram(program)
end

-- 黑白滤镜
function ShaderManager:blackwhiteFilter(_sp)
    local program = _getGLProgram(vertDefaultSource, "res/shader/blackwhiteFilter.fsh")
    local _state = cc.GLProgramState:getOrCreateWithGLProgram(program)
    _sp:setGLProgramState(_state)
end

-- 淡蓝滤镜
function ShaderManager:blueFilter(_widget, _toBlue)
    local _sp = _widget:getVirtualRenderer()
    if _toBlue then 
      local program = _getGLProgram(vertDefaultSource, "res/shader/blueFilter.fsh")
      local _state = cc.GLProgramState:getOrCreateWithGLProgram(program)
      _sp:setGLProgramState(_state)
    else
      self:ResumeColor(_sp)
    end
end

-- 羽化
function ShaderManager:fadeUpAndDown(_sp)
    local program = _getGLProgram(vertDefaultSource, "res/shader/fadeUpAndDown.fsh")
    local _state = cc.GLProgramState:getOrCreateWithGLProgram(program)
    _sp:setGLProgramState(_state)
end

-- 降低饱和度
function ShaderManager:decreaseSaturationTo(_sp, _saturation)
    local program = _getGLProgram(vertDefaultSource, "res/shader/decreaseSaturationTo.fsh")
    local _state = cc.GLProgramState:getOrCreateWithGLProgram(program)
    _sp:setGLProgramState(_state)
    _state:setUniformFloat("u_Saturation", _saturation)
end

-- 降低饱和度+羽化
function ShaderManager:decreaseSaturationToAndfadeUpAndDown(_sp, _saturation)
    local program = _getGLProgram(vertDefaultSource, "res/shader/decreaseSaturationToAndfadeUpAndDown.fsh")
    local _state = cc.GLProgramState:getOrCreateWithGLProgram(program)
    _sp:setGLProgramState(_state)
    _state:setUniformFloat("u_Saturation", _saturation)
end


--@MenuItem特效
--#禁用按钮
function ShaderManager:MenuItem_Disabled(_item, _disabled)
    local sp = _item:getNormalImage()
    if _disabled then
        self:Disabled(sp)
    else
        self:ResumeColor(sp)
    end
end


function ShaderManager:DoUIWidgetDisabled(widget, disabled)
    local renderNode = widget:getVirtualRenderer()
    if disabled then
        self:Disabled(renderNode)
    else
        self:ResumeColor(renderNode)
    end
end

--@Etc处理
function ShaderManager:etcHandle(_sp)
      if not ENABLED_TEXTURE_ETC1 then return end
      local _pathShader = "res/shader/etc1composite.fsh"
      local program = _getGLProgram(vertDefaultSource, _pathShader)
      _sp:setGLProgram(program)
end

--@高斯模糊
function ShaderManager:blur(_sp, _resolution, _blurRadius)
    local program = _getGLProgram(vertDefaultSource, "res/shader/blur.fsh")
    local _state = cc.GLProgramState:getOrCreateWithGLProgram(program)
    _sp:setGLProgramState(_state)
    _state:setUniformVec2("resolution", _resolution)
    _state:setUniformFloat("blurRadius", _blurRadius)
    _state:setUniformFloat("sampleNum", 7.0)
end


------------------------------spine shader------------------------------
-- 禁用特效
function ShaderManager:Stone_spine(_sp)
      cclog("ShaderManager:Stone_spine")
      local _pathShader = "res/shader/StoneShader.fsh"
      local program = _getGLProgram(vertDefaultSource_spine, _pathShader)
      _sp:setCurGLProgram(program)
end

-- 变色
function ShaderManager:changeColor_spine(_spine, _vec4Color, _attachList)
    local _pathShader = "res/shader/toColor.fsh"
    local program = _getGLProgram(vertDefaultSource_spine, _pathShader)
    local _state = cc.GLProgramState:getOrCreateWithGLProgram(program)
    _state:setUniformVec4("u_Color", _vec4Color)
    if _attachList then
        for k,v in pairs(_attachList) do
            _spine:setAttachmentAndGLProgram(_state, v)
        end
    else
       _spine:setCurGLProgram(program)
    end
end

-- 融合变色同时改变亮度
-- 会同时存在不一样参数的shader程序，所以不能从缓存中读取，每次new新的
function ShaderManager:combineColor_spine(_spine, _vec4Color, _light, _attachList, _GlProKey)
    local _pathShader = "res/shader/combineColorSpine.fsh"
    local _program = _getGLProgram(vertDefaultSource_spine, _pathShader, _GlProKey)
    local _state = cc.GLProgramState:getOrCreateWithGLProgram(_program)
    _state:setUniformVec4("u_Color", _vec4Color)
    _state:setUniformFloat("u_light", _light)
    if _attachList then
        for k,v in pairs(_attachList) do
            _spine:setAttachmentAndGLProgram(_state, v)
        end
    else
       _spine:setCurGLProgram(_program)
    end
end

-- 色相 hue: -180 ~ 180  _saturation: 0 ~ 2
function ShaderManager:changeHue_spine(_spine, _hue, _saturation, _bright, _attachList)
    if not _light2 then _light2 = 0 end
    ----
    local mat_hue = FightSystem:getHueMat4(math.rad(_hue))
    local pathShader = "res/shader/changeHueSpine.fsh"
    local fileUtiles = cc.FileUtils:getInstance()
    local fragSource = fileUtiles:getStringFromFile(pathShader)
    local program = cc.GLProgram:createWithByteArrays(vertDefaultSource_spine, fragSource)
    local _state = cc.GLProgramState:getOrCreateWithGLProgram(program)
    _state:setUniformMat4("u_hue", mat_hue)
    _state:setUniformFloat("u_Saturation", _saturation)
    _state:setUniformFloat("u_bright", _bright)
    if _attachList then
        for k,v in pairs(_attachList) do
            _spine:setAttachmentAndGLProgram(_state, v)
        end
    else
       _spine:setCurGLProgram(program)
    end
end

-- 着色
-- @saturation: 0 ~ 1.0  @_c3bColor: R,G,B中必有1与0，剩下一个0~1.0
-- @light: -1.0 ~ 1.0
-- ps: 同时使用多个不同参数，无法缓存，使用时临时创建,spine销毁时随之销毁
function ShaderManager:changeHueWithShading_spine(_spine, _c3bColor, _saturation, _light, _bright, _attachList)
    if not _light2 then _light2 = 0 end
    -- 处理饱和度
    local _vec4Color = cc.vec4(0.0,0.0,0.0,1.0)
    _vec4Color.x = 0.5 + _saturation*(_c3bColor.r - 0.5)
    _vec4Color.y = 0.5 + _saturation*(_c3bColor.g - 0.5)
    _vec4Color.z = 0.5 + _saturation*(_c3bColor.b - 0.5)
    --
    local pathShader = "res/shader/changeHueShading.fsh"
    local fileUtiles = cc.FileUtils:getInstance()
    local fragSource = fileUtiles:getStringFromFile(pathShader)
    local program = cc.GLProgram:createWithByteArrays(vertDefaultSource_spine, fragSource)
    local _state = cc.GLProgramState:getOrCreateWithGLProgram(program)
    _state:setUniformVec4("u_Color", _vec4Color)
    _state:setUniformFloat("u_light", _light)
    _state:setUniformFloat("u_bright", _bright)
    if _attachList then
        for k,v in pairs(_attachList) do
            _spine:setAttachmentAndGLProgram(_state, v)
        end
    else
       _spine:setCurGLProgram(program)
    end
end

-- 通过data改变
function ShaderManager:changeColorspineByData(_spine,changeData,heroId)
  local _infoDB = DB_HeroConfig.getDataById(heroId)
  if changeData and changeData.colorType > 0 then
      local i = changeData.partType
      local Dye_pic = _infoDB[string.format("Dye%d_pic",i)]
      local Colorlist = changeData.colorArr
      if changeData.colorType == 1 then
        if not Colorlist[1] then return end
        if not Colorlist[2] then return end
        if not Colorlist[3] then return end
        if not Dye_pic then return end
        --debugLog("色相:" .. Colorlist[1] .. ";饱和度:" .. Colorlist[2] .. ";亮度:" .. Colorlist[3])
        ShaderManager:changeHue_spine(_spine, Colorlist[1]-180, Colorlist[2]/1000,(Colorlist[3]-1000)/1000, Dye_pic)
      else
        if not Colorlist[1] then return end
        if not Colorlist[2] then return end
        if not Colorlist[3] then return end
        if not Colorlist[4] then return end
        if not Colorlist[5] then return end
        if not Colorlist[6] then return end
        if not Dye_pic then return end
        --debugLog("着色:" .. Colorlist[1] .. "," .. Colorlist[2] .. "," .. Colorlist[3] .. ";饱和度:" .. Colorlist[4] .. ",明度:" .. Colorlist[5].. ",亮度:" .. Colorlist[6])
        local color = cc.c3b(Colorlist[1]/255,Colorlist[2]/255,Colorlist[3]/255)
        ShaderManager:changeHueWithShading_spine(_spine, color, Colorlist[4]/1000, (Colorlist[5]-1000)/1000,(Colorlist[6]-1000)/1000, Dye_pic)
        
      end
  end
end

-- 改变亮度
-- _light from -1.0 ~ +1.0
function ShaderManager:changeLight_spine(_spine, _light, _attachList)
    local _pathShader = "res/shader/changelightSpine.fsh"
    local program = _getGLProgram(vertDefaultSource_spine, _pathShader)
    local _state = cc.GLProgramState:getOrCreateWithGLProgram(program)
    _state:setUniformFloat("u_light", _light)
    if _attachList then
        for k,v in pairs(_attachList) do
            _spine:setAttachmentAndGLProgram(_state, v)
        end
    else
       _spine:setCurGLProgram(program)
    end
end

-- 恢复spine原有颜色，可指定部件
function ShaderManager:ResumeColor_spine(_spine, _attachList)
    if _attachList then
        for k,v in pairs(_attachList) do
            _spine:removeAttachmentAndGLProgram(v)
        end
    else
        local glProgramNormal = cc.GLProgramCache:getInstance():getGLProgram("ShaderPositionTextureColor")
        _spine:setCurGLProgram(glProgramNormal)
    end
end

-- 将spine恢复到初始化颜色
function ShaderManager:ResumeColor_spine_all(_spine)
    local glProgramNormal = cc.GLProgramCache:getInstance():getGLProgram("ShaderPositionTextureColor")
    _spine:setCurGLProgram(glProgramNormal)
    _spine:clearAttachmentAndGLProgram()
end

--@高斯模糊,无法缓存,使用时临时创建,spine销毁时随之销毁
function ShaderManager:blur_spine(_spine, _resolution, _blurRadius)
    local fileUtiles = cc.FileUtils:getInstance()
    local fragSource = fileUtiles:getStringFromFile("res/shader/blur.fsh")
    local program = cc.GLProgram:createWithByteArrays(vertDefaultSource_spine, fragSource)
    local _state = cc.GLProgramState:getOrCreateWithGLProgram(program)
    _spine:setCurGLProgram(program)
    _state:setUniformVec2("resolution", _resolution)
    _state:setUniformFloat("blurRadius", _blurRadius)
    _state:setUniformFloat("sampleNum", 7.0)
end
------------------------------------------------------------------------