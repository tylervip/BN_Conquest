// Author: Savage Game Design
// Base control classes for the keybindings menu UI
#include "ui_def_base.inc"

import RscButton;

class para_RscText
{
idc = -1;
type = 0;
style = 0;
shadow = 0;
x = 0;
y = 0;
h = 0.037;
w = 0.3;
text = "";
font = USEDFONT;
SizeEx = TXT_S;
colorShadow[] = {0,0,0,0.5};
colorText[] = {1,1,1,1.0};
colorBackground[] = {0,0,0,0};
linespacing = 1;
tooltipColorText[] = {1,1,1,1};
tooltipColorBox[] = {1,1,1,1};
tooltipColorShade[] = {0,0,0,0.65};
};

class para_RscListNBox
{
idc = -1;
type = CT_LISTNBOX;
style = ST_LEFT + LB_TEXTURES;
selectWithRMB = 1;
text = "";
blinkingPeriod = 0;
x = UIX_CL(1);
y = UIY_CU(1);
w = UIW(2);
h = UIH(2);
colorSelectBackground[] = {0.5,0.5,0.5,0.4};
colorSelectBackground2[] = {0.5,0.5,0.5,0.4};
sizeEx = TXT_S;
font = USEDFONT;
rowHeight = UIH(1);
borderSize = 0;
shadow = 0;
colorText[] = {PARA_C_DYNAMICGROUPS_COLOR_DEFAULT_CONFIG};
colorDisabled[] = {0.5, 0.5, 0.5, 1.0};
colorSelect[] = {0.5, 0.5, 0.5, 1.0};
colorSelect2[] = {0.5, 0.5, 0.5, 0.6};
colorShadow[] = {0,0,0,0.5};
colorPicture[] = {0.7,0.7,0.7,1};
colorPictureSelected[] = {0.2,0.2,0.2,1};
colorPictureDisabled[] = {0,0,0,1};
tooltip = "";
tooltipColorShade[] = {0,0,0,1};
tooltipColorText[] = {1,1,1,1};
tooltipColorBox[] = {1,1,1,1};
columns[] = {0.0,0.2};
drawSideArrows = 0;
idcLeft = 1000;
idcRight = 1001;
period = 1;
maxHistoryDelay = 1;
soundSelect[] = {"\A3\ui_f\data\sound\RscListbox\soundSelect",0.09,1};
class ListScrollBar
{
width = 0;
height = 0;
scrollSpeed = 0.01;
arrowEmpty = "\A3\ui_f\data\gui\cfg\scrollbar\arrowEmpty_ca.paa";
arrowFull = "\A3\ui_f\data\gui\cfg\scrollbar\arrowFull_ca.paa";
border = "\A3\ui_f\data\gui\cfg\scrollbar\border_ca.paa";
thumb = "\A3\ui_f\data\gui\cfg\scrollbar\thumb_ca.paa";
color[] = {1,1,1,1};
};
onCanDestroy = "";
onDestroy = "";
onSetFocus = "";
onKillFocus = "";
onKeyDown = "";
onKeyUp = "";
onMouseButtonClick = "";
onMouseButtonDblClick = "";
onMouseZChanged = "";
onMouseMoving = "";
onMouseHolding = "";
};

class para_RscShortcutButton
{
idc = -1;
style = 0;
default = 0;
shadow = 1;
w = 0.183825;
h = "(((((safezoneW / safezoneH) min 1.2) / 1.2) / 20))";
color[] = {1,1,1,1.0};
colorFocused[] = {1,1,1,1.0};
color2[] = {0.95,0.95,0.95,1};
colorDisabled[] = {1,1,1,0.25};
colorBackground[] = {"(profilenamespace getvariable ['GUI_BCG_RGB_R',0.13])","(profilenamespace getvariable ['GUI_BCG_RGB_G',0.54])","(profilenamespace getvariable ['GUI_BCG_RGB_B',0.21])",1};
colorBackgroundFocused[] = {"(profilenamespace getvariable ['GUI_BCG_RGB_R',0.13])","(profilenamespace getvariable ['GUI_BCG_RGB_G',0.54])","(profilenamespace getvariable ['GUI_BCG_RGB_B',0.21])",1};
colorBackground2[] = {1,1,1,1};
textSecondary = "";
colorSecondary[] = {1,1,1,1.0};
colorFocusedSecondary[] = {1,1,1,1.0};
color2Secondary[] = {0.95,0.95,0.95,1};
colorDisabledSecondary[] = {1,1,1,0.25};
sizeExSecondary = "(((((safezoneW / safezoneH) min 1.2) / 1.2) / 25) * 1)";
fontSecondary = "RobotoCondensed";
animTextureDefault = "\A3\ui_f\data\GUI\RscCommon\RscShortcutButton\normal_ca.paa";
animTextureNormal = "\A3\ui_f\data\GUI\RscCommon\RscShortcutButton\normal_ca.paa";
animTextureDisabled = "\A3\ui_f\data\GUI\RscCommon\RscShortcutButton\normal_ca.paa";
animTextureOver = "\A3\ui_f\data\GUI\RscCommon\RscShortcutButton\over_ca.paa";
animTextureFocused = "\A3\ui_f\data\GUI\RscCommon\RscShortcutButton\focus_ca.paa";
animTexturePressed = "\A3\ui_f\data\GUI\RscCommon\RscShortcutButton\down_ca.paa";
periodFocus = 1.2;
periodOver = 0.8;
class HitZone { left = 0.0; top = 0.0; right = 0.0; bottom = 0.0; };
class ShortcutPos
{
left = 0;
top = "((((((safezoneW / safezoneH) min 1.2) / 1.2) / 20) - (((((safezoneW / safezoneH) min 1.2) / 1.2) / 25) * 1)) / 2)";
w = "((((((safezoneW / safezoneH) min 1.2) / 1.2) / 25) * 1) * (3/4))";
h = "(((((safezoneW / safezoneH) min 1.2) / 1.2) / 25) * 1)";
};
class TextPos
{
left = "((((((safezoneW / safezoneH) min 1.2) / 1.2) / 25) * 1) * (3/4))";
top = "((((((safezoneW / safezoneH) min 1.2) / 1.2) / 20) - (((((safezoneW / safezoneH) min 1.2) / 1.2) / 25) * 1)) / 2)";
right = 0.005;
bottom = 0.0;
};
period = 0.4;
font = "RobotoCondensed";
size = "(((((safezoneW / safezoneH) min 1.2) / 1.2) / 25) * 1)";
sizeEx = "(((((safezoneW / safezoneH) min 1.2) / 1.2) / 25) * 1)";
text = "";
url = "";
soundEnter[] = {"\A3\ui_f\data\sound\RscButton\soundEnter",0.09,1};
soundPush[] = {"\A3\ui_f\data\sound\RscButton\soundPush",0.09,1};
soundClick[] = {"\A3\ui_f\data\sound\RscButton\soundClick",0.09,1};
soundEscape[] = {"\A3\ui_f\data\sound\RscButton\soundEscape",0.09,1};
action = "";
class Attributes { font = "RobotoCondensed"; color = "#E5E5E5"; align = "left"; shadow = "true"; };
class AttributesImage { font = "RobotoCondensed"; color = "#E5E5E5"; align = "left"; };
};

class para_RscButtonMenu: para_RscShortcutButton
{
idc = -1;
type = 16;
style = "0x02 + 0xC0";
default = 0;
shadow = 0;
x = 0; y = 0;
w = 0.095589;
h = 0.039216;
animTextureNormal = "#(argb,8,8,3)color(1,1,1,1)";
animTextureDisabled = "#(argb,8,8,3)color(1,1,1,1)";
animTextureOver = "#(argb,8,8,3)color(1,1,1,1)";
animTextureFocused = "#(argb,8,8,3)color(1,1,1,1)";
animTexturePressed = "#(argb,8,8,3)color(1,1,1,1)";
animTextureDefault = "#(argb,8,8,3)color(1,1,1,1)";
colorBackground[] = {0,0,0,0.8};
colorBackgroundFocused[] = {1,1,1,1};
colorBackground2[] = {0.75,0.75,0.75,1};
color[] = {1,1,1,1};
colorFocused[] = {0,0,0,1};
color2[] = {0,0,0,1};
colorText[] = {1,1,1,1};
colorDisabled[] = {1,1,1,0.25};
textSecondary = "";
colorSecondary[] = {1,1,1,1};
colorFocusedSecondary[] = {0,0,0,1};
color2Secondary[] = {0,0,0,1};
colorDisabledSecondary[] = {1,1,1,0.25};
sizeExSecondary = "(((((safezoneW / safezoneH) min 1.2) / 1.2) / 25) * 1)";
fontSecondary = USEDFONT;
period = 1.2;
periodFocus = 1.2;
periodOver = 1.2;
size = "(((((safezoneW / safezoneH) min 1.2) / 1.2) / 25) * 1)";
sizeEx = "(((((safezoneW / safezoneH) min 1.2) / 1.2) / 25) * 1)";
tooltipColorText[] = {1,1,1,1};
tooltipColorBox[] = {1,1,1,1};
tooltipColorShade[] = {0,0,0,0.65};
class TextPos
{
left = "0.25 * (((safezoneW / safezoneH) min 1.2) / 40)";
top = "((((((safezoneW / safezoneH) min 1.2) / 1.2) / 25) - (((((safezoneW / safezoneH) min 1.2) / 1.2) / 25) * 1)) / 2)";
right = 0.005;
bottom = 0.0;
};
class Attributes { font = USEDFONT; color = "#E5E5E5"; align = "left"; shadow = "false"; };
class ShortcutPos
{
left = "5.25 * (((safezoneW / safezoneH) min 1.2) / 40)";
top = 0;
w = "1 * (((safezoneW / safezoneH) min 1.2) / 40)";
h = "1 * ((((safezoneW / safezoneH) min 1.2) / 1.2) / 25)";
};
soundEnter[] = {"\A3\ui_f\data\sound\RscButtonMenu\soundEnter",0.09,1};
soundPush[] = {"\A3\ui_f\data\sound\RscButtonMenu\soundPush",0.09,1};
soundClick[] = {"\A3\ui_f\data\sound\RscButtonMenu\soundClick",0.09,1};
soundEscape[] = {"\A3\ui_f\data\sound\RscButtonMenu\soundEscape",0.09,1};
textureNoShortcut = "";
};
