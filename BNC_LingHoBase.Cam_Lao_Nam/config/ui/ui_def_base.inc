// Author: Savage Game Design
// UI positioning macros
#define CT_STATIC		0
#define CT_BUTTON		1
#define CT_EDIT		2
#define CT_LISTBOX		5
#define CT_CONTROLS_GROUP		15
#define CT_SHORTCUTBUTTON		16
#define CT_LISTNBOX		102

#define ST_LEFT		0x00
#define ST_RIGHT		0x01
#define ST_CENTER		0x02
#define ST_FRAME		0x40
#define LB_TEXTURES		0x10

// UI Scaling macros
#define UIX_CALC_A		(((getResolution select 4) min 1.2) / 40)
#define UIX_CALC_B		(safezoneX + (safezoneW - ((getResolution select 7) min 1.2))/2)
#define UIX_CALC		UIX_CALC_A + UIX_CALC_B

#define UIY_CALC_A		((((getResolution select 4) min 1.2) / 1.2) / 25)
#define UIY_CALC_B		(safezoneY + (safezoneH - (((getResolution select 7) min 1.2) / 1.2))/2)
#define UIY_CALC		UIY_CALC_A + UIY_CALC_B

#define UIX(NUM)		((NUM) * UIX_CALC)
#define UIX_CL(NUM)		((((NUM)*-1) + 20) * UIX_CALC)
#define UIX_CR(NUM)		(((NUM) + 20) * UIX_CALC)
#define UIY(NUM)		((NUM) * UIY_CALC)
#define UIY_CU(NUM)		((((NUM)*-1) + 12.5) * UIY_CALC)
#define UIY_CD(NUM)		(((NUM) + 12.5) * UIY_CALC)
#define UIW(NUM)		((NUM) * UIX_CALC_A)
#define UIH(NUM)		((NUM) * UIY_CALC_A)
#define UIY_TD(NUM)		((UIH(NUM)) + safezoneY)
#define UIX_LR(NUM)		(UIW(NUM) + safeZoneX)

// Text fonts and sizes
#define USEDFONT		"tt2020base_vn"
#define USEDFONT_B		"tt2020base_vn_bold"

#define TXT_XXS		(UIY_CALC_A * 0.2)
#define TXT_XS		(UIY_CALC_A * 0.4)
#define TXT_S		(UIY_CALC_A * 0.65)
#define TXT_M		(UIY_CALC_A * 0.85)
#define TXT_L		(UIY_CALC_A * 1)
#define TXT_XL		(UIY_CALC_A * 1.3)
#define TXT_XXL		(UIY_CALC_A * 1.4)

// Keybindings menu colors
#define COLOR_KEYBINDINGS_NORMAL_SELECTED		[1,1,1,1]
#define COLOR_KEYBINDINGS_NORMAL_UNSELECTED		[1,1,1,0.5]
#define COLOR_KEYBINDINGS_DOUBLEBIND_SELECTED		[1,0,0,1]
#define COLOR_KEYBINDINGS_DOUBLEBIND_UNSELECTED		[1,0,0,0.5]

// Dynamic groups default color (needed by ListNBox base class)
#define PARA_C_DYNAMICGROUPS_COLOR_DEFAULT_CONFIG		1,1,1,1

// IDC definitions
#include "ui_def_idc.inc"