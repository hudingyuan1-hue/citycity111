extends Node3D

const PlayerController := preload("res://scripts/player_controller.gd")

enum GamePhase { MAIN_MENU, STORY, THEME_SELECT, MECHANIC_PROMPT, GREY_VOID, MANIFESTING, CITY, READING, CHOICE, PAUSED, OPTIONS }

const THEME_MEMORY := 0
const THEME_DESIRE := 1
const THEME_SIGNS := 2
const THEME_THIN := 3
const THEME_TRADE := 4
const THEME_EYES := 5
const THEME_NAMES_CITY := 6
const THEME_DEAD := 7
const THEME_SKY := 8
const THEME_CONTINUOUS := 9
const THEME_HIDDEN := 10
const MEMORY_POS := Vector3(48.0, 0.0, -46.0)
const PLAYER_SPAWN := Vector3(-56.0, 0.0, -54.0)
const GREY_WRAP_DEFAULT_HALF_EXTENT := 60.0
const CITY_BOUNDARY_DEFAULT_HALF_EXTENT := 126.0
const MIN_GPU_PARTICLE_AMOUNT := 1
const PLAYER_SPAWN_POINTS := [
	Vector3(-56, 0, -54),
	Vector3(-58, 0, 48),
	Vector3(-12, 0, 58),
	Vector3(56, 0, 54),
	Vector3(-58, 0, 4),
	Vector3(4, 0, 58),
	Vector3(58, 0, 20),
	Vector3(-4, 0, -58)
]
const LEGACY_MEMORY_AUDIO_PATH := "res://assets/audio/memory_theme_loop.ogg"
const CITY_MEMORY_AUDIO_PATH := "res://assets/audio/city_memory_loop.ogg"
const MEMORY_LONG_BGM_AUDIO_PATH := "res://assets/audio/memory_long_bgm.ogg"
const THEME_SFX_AUDIO_PATHS := [
	["res://assets/audio/theme_sfx/memory_a.ogg", "res://assets/audio/theme_sfx/memory_b.ogg", "res://assets/audio/theme_sfx/memory_c.ogg", "res://assets/audio/theme_sfx/memory_d.ogg"],
	["res://assets/audio/theme_sfx/desire_a.ogg", "res://assets/audio/theme_sfx/desire_b.ogg", "res://assets/audio/theme_sfx/desire_c.ogg"],
	["res://assets/audio/theme_sfx/signs_a.ogg", "res://assets/audio/theme_sfx/signs_b.ogg", "res://assets/audio/theme_sfx/signs_c.ogg"],
	["res://assets/audio/theme_sfx/thin_a.ogg", "res://assets/audio/theme_sfx/thin_b.ogg", "res://assets/audio/theme_sfx/thin_c.ogg"],
	["res://assets/audio/theme_sfx/trading_a.ogg", "res://assets/audio/theme_sfx/trading_b.ogg", "res://assets/audio/theme_sfx/trading_c.ogg"],
	["res://assets/audio/theme_sfx/eyes_a.ogg", "res://assets/audio/theme_sfx/eyes_b.ogg", "res://assets/audio/theme_sfx/eyes_c.ogg"],
	["res://assets/audio/theme_sfx/names_a.ogg", "res://assets/audio/theme_sfx/names_b.ogg", "res://assets/audio/theme_sfx/names_c.ogg"],
	["res://assets/audio/theme_sfx/dead_a.ogg", "res://assets/audio/theme_sfx/dead_b.ogg", "res://assets/audio/theme_sfx/dead_c.ogg"],
	["res://assets/audio/theme_sfx/sky_a.ogg", "res://assets/audio/theme_sfx/sky_b.ogg", "res://assets/audio/theme_sfx/sky_c.ogg"],
	["res://assets/audio/theme_sfx/continuous_a.ogg", "res://assets/audio/theme_sfx/continuous_b.ogg", "res://assets/audio/theme_sfx/continuous_c.ogg"],
	["res://assets/audio/theme_sfx/hidden_a.ogg", "res://assets/audio/theme_sfx/hidden_b.ogg", "res://assets/audio/theme_sfx/hidden_c.ogg"]
]
const THEME_SFX_TEXTS := [
	["远处有灯同时亮起。", "一声呼喊停在黄昏。", "街道把脚步吞回雾里。", "塔顶的金色报晓还没有发生。"],
	["欲望在雾里绕行。", "第二个选择尚未结束。", "第三个身影从旁边经过。"],
	["标志先于道路出现。", "名字贴在不可见的墙上。", "符号互相遮蔽。"],
	["空桥在雾里轻轻晃动。", "细柱把脚步传到很远。", "云丝穿过未完成的房间。"],
	["交换还没有发生。", "摊位在雾后响动。", "空手与空手相遇。"],
	["有目光从白雾里回看。", "窗后没有脸。", "视线比道路更早抵达。"],
	["名字被反复念错。", "称呼落在地面。", "陌生人带走一半声音。"],
	["旧声沉入地面。", "没有脚步回答。", "冷的回响停在身后。"],
	["天空在低处流动。", "云层贴近耳边。", "高处传来潮声。"],
	["道路连续到无法分辨。", "一段声音接上另一段。", "没有停顿的街。"],
	["隐藏之物先发出声音。", "雾后有门。", "不可见处正在靠近。"]
]
const THEME_NAMES := [
	"记忆", "欲望", "符号", "轻盈", "贸易", "眼睛", "姓名", "死的", "天空", "连续", "隐蔽"
]
const ZONE_POSITIONS := [
	Vector3(48, 0, -46),
	Vector3(-42, 0, 36),
	Vector3(24, 0, 43),
	Vector3(-48, 0, 2),
	Vector3(47, 0, 8),
	Vector3(-40, 0, -34),
	Vector3(-10, 0, -44),
	Vector3(18, 0, -43),
	Vector3(-5, 0, 52),
	Vector3(-8, 0, -5),
	Vector3(4, 0, 20)
]
const ZONE_SHAPES := [
	Vector2(46, 44),
	Vector2(54, 54),
	Vector2(70, 50),
	Vector2(44, 52),
	Vector2(44, 84),
	Vector2(50, 58),
	Vector2(56, 46),
	Vector2(52, 58),
	Vector2(50, 54),
	Vector2(70, 30),
	Vector2(52, 54)
]
const ZONE_ROTATIONS := [12.0, -12.0, 18.0, 4.0, -7.0, 10.0, -16.0, 8.0, -5.0, 28.0, -22.0]
const ZONE_COLORS := [
	Color(1.00, 0.86, 0.06, 1.0),
	Color(0.78, 0.35, 0.86, 1.0),
	Color(0.36, 0.58, 0.95, 1.0),
	Color(0.58, 0.74, 0.86, 1.0),
	Color(0.92, 0.73, 0.32, 1.0),
	Color(0.32, 0.88, 0.42, 1.0),
	Color(0.90, 0.42, 0.62, 1.0),
	Color(0.38, 0.38, 0.44, 1.0),
	Color(0.48, 0.78, 1.00, 1.0),
	Color(0.76, 0.74, 0.50, 1.0),
	Color(0.82, 0.82, 0.86, 1.0)
]
const READING_PAGES := [
	["你抵达的不是城市。", "是一段留下来的回声。"],
	["门开过很多次。", "每一次，都通向从前。"],
	["街道记得脚步。", "窗户记得名字。"],
	["你以为你在寻找它。", "其实它一直等你听见。"],
	["要把这座城留下吗？"]
]
const MEMORY_CITY_TITLES := [
	"记忆之城：五重回声",
	"欲望之城：沙海白城",
	"符号之城：无名广场",
	"轻盈之城：将断之网",
	"贸易之城：五重交换",
	"眼睛之城：双面镜湖",
	"姓名之城：消逝名字碑",
	"死者之城：三重劳多米亚",
	"天空之城：星图工地城",
	"连续之城：无边郊区",
	"隐蔽之城：层中暗城"
]
const MEMORY_CITY_READING_PAGES := [
	[
		["银色圆顶、螺旋楼梯、高堡、乐谱街巷和明信片，在同一座城里互相覆盖。"],
		["这里不是五座城市。", "是记忆从五个方向折回同一个中心。"],
		["有人在黄昏里羡慕幸福。", "有人抵达梦中之城时已经老去。"],
		["街角、栅栏、码头、钟楼和旧照片，都把过去藏进白盒的尺度。"],
		["回声塔站在唯一的空地上。", "它不属于任何一段记忆，却召回所有记忆。"],
		["要把这座城留下吗？"]
	],
	[
		["你收集到的不是物品。", "是欲望给自己留下的形状。"],
		["香柠檬、玛瑙、酒囊、玻璃球和梦路碎片，都把你引向更深处。"],
		["你以为自己在选择它们。", "其实它们在排列你的道路。"],
		["月光迷宫没有出口。", "无出口墙只是最后一个诚实的标志。"],
		["要把这座城留下吗？"]
	],
	[
		["你看见的不是城市。", "是城市为自己贴上的名字。"],
		["牙钳、陶罐、戟、天平。", "它们指向事物，也遮住事物。"],
		["重复让记忆变得可靠。", "也让谎言变得可靠。"],
		["在这里，湖不是湖。", "宫殿也不是宫殿。"],
		["当所有符号都失效。", "城市才第一次沉默。"],
		["要把这座城留下吗？"]
	],
	[
		["你进入的不是地面上的城市。", "它被拉在两面悬崖之间，像一张还没有断的网。"],
		["细柱、脚手架和悬空房间把重量分散到看不见的线上。"],
		["吊桥不是道路。", "只是风暂时允许你踩过去的几根横梁。"],
		["淡蓝灰的墙半透明地晃动，边缘像线框一样露出骨架。"],
		["走到网心时，你才明白这座城不是轻。", "它只是一直在承受。"],
		["要把这座城留下吗？"]
	],
	[
		["生姜、棉花、开心果和罂粟籽在黄席子上换手。", "入夜后，人们交换的却是狼、妹妹和隐蔽的宝藏。"],
		["长街上的人互不问候。", "目光只相遇一秒，却已经交换了所有可能发生的故事。"],
		["空城在高原上等待迁移者。", "职业、窗景、妻子、朋友和口音都可以被重新分配。"],
		["房屋消失之后，黑白灰绳仍留在木桩之间。", "交易、亲缘、权威和代表关系继续寻找形式。"],
		["水路和陆路互相交织。", "最短的路线不是直线，而是可以反复选择的曲线。"],
		["要把这座城留下吗？"]
	],
	[
		["你看见了一座城市。", "湖里也看见了一座城市。"],
		["岸上的不比倒影更真实。", "倒影也不比岸上更虚假。"],
		["抬头的人看见窗帘和喷泉。", "低头的人看见水沟和废纸。"],
		["有些城市住在高处。", "它们用望远镜确认地面仍然存在。"],
		["第一次看见的桥和窗。", "久住以后，会变成一条最快的路。"],
		["正面与背面不能分开。", "它们合起来，才薄得像一张纸。"],
		["要把这座城留下吗？"]
	],
	[
		["这座城不是由石头固定的。", "它先被名字固定。"],
		["传说替它说话。", "于是亲眼所见反而变得无声。"],
		["有些名字属于门口。", "有些名字藏在厨房和壁炉下。"],
		["你曾把一座想象中的城叫作皮拉。", "后来真实的皮拉夺走了这个名字。"],
		["旧物被搬走、重组、供奉。", "名字却留在原地。"],
		["远方那座城叫伊莱那。", "走近以后，它也许不再叫这个名字。"],
		["要把这座城留下吗？"]
	],
	[
		["这里没有终点。", "只有角色被另一个人接过。"],
		["你看见的面孔并不属于他们。", "它们带着你已经失去的人。"],
		["地下的城市模仿生者。", "后来，生者开始模仿地下。"],
		["有一座城在土里。", "你看不见它，只能听见门声。"],
		["劳多米亚有三座。", "生者、死者，以及还没有出生的人。"],
		["每一粒沙都在等待通过。", "最后一粒还停在上方。"],
		["要把这座城留下吗？"]
	],
	[
		["城市把混乱藏进地毯。", "又把秩序挂到星上。"],
		["天上的城并不纯洁。", "地下的城也不一定卑劣。"],
		["他们不断建造。", "仿佛停下，毁灭就会开始。"],
		["月蚀被框在城门里。", "畸形的影子也被算进天象。"],
		["每一次街道改变。", "远处都有一颗星回应。"],
		["天空不是答案。", "它也在模仿城市。"],
		["要把这座城留下吗？"]
	],
	[
		["莱奥尼亚每天醒来都像新城。", "昨日的一切却被塑料袋送到城外，堆成不能腐烂的堡垒。"],
		["特鲁德没有真正的抵达。", "机场名牌在更换，郊区、宾馆、商品和酒杯却一模一样。"],
		["普罗科比亚的窗景一年比一年拥挤。", "最后，整扇窗只剩一张张礼貌的圆脸。"],
		["切奇利雅吞没牧场。", "牧羊人和羊群走进城市，很多年后仍然找不到出口。"],
		["潘特熙莱雅没有城门，也没有中心。", "你从一个郊区走向另一个郊区，终于放弃分辨城内和城外。"],
		["连续之城不是一座城在扩大。", "是所有边界都在被同一种城市填平。"],
		["要把这座城留下吗？"]
	],
	[
		["欧林达的中心不是中心。", "放大镜下，针头大的光点里已经长出下一座城市。"],
		["莱萨的表面充满噩梦。", "但每时每刻都有一根快乐细线，把一个生命短暂地接到另一个生命。"],
		["马洛奇亚的铅灰巷像老鼠的城。", "偶然的裂缝里，却会闪出水晶般透明的燕子城市。"],
		["特奥朵拉把被驱逐的物种收藏进书里。", "地下书库醒来时，怪兽重新从名字里走出。"],
		["贝莱尼切的不公正城里藏着公正机械。", "公正胚胎里又有毒种，准备长成下一座不公正的城。"],
		["隐蔽之城不是被建造出来的。", "它已经在暗处存在，只等你发现。"],
		["要把这座城留下吗？"]
	]
]
const DESIRE_RELICS := [
	["CitronCrate", "香柠檬箱", "一只香柠檬箱：集市的早晨把荒漠变成可拥有的东西。"],
	["AgateStone", "玛瑙原石", "一块玛瑙原石：劳动替欲望塑形，欲望也替劳动塑形。"],
	["WineSkin", "酒囊", "一个旧酒囊：海港和商队在同一座幻影城市里互相投射。"],
	["GlassSphere", "玻璃圆球", "一个玻璃圆球：理想城市被收藏成手心里的玩具。"],
	["DreamRoadFragment", "梦路碎片", "一段梦路碎片：追逐消失后，迷宫留下来。"]
]
const DESIRE_RELIC_GLOW_COLORS := [
	Color(1.0, 0.86, 0.16, 1.0),
	Color(0.72, 0.28, 1.0, 1.0),
	Color(0.90, 0.16, 0.12, 1.0),
	Color(0.22, 0.82, 1.0, 1.0),
	Color(0.88, 0.90, 1.0, 1.0)
]
const SIGN_FRACTURE_NODES := [
	["TamaraSignNode", "塔马拉：招牌过载", "所有东西都被标明，真实却退到标牌后面。"],
	["ZirmaRepeatNode", "吉尔玛：重复夸张", "同一符号反复出现，记忆因此变得可疑。"],
	["ZoeAmbiguityNode", "佐艾：功能混淆", "王宫、监狱、市场和住处可以是同一座房屋。"],
	["HypatiaInversionNode", "伊帕奇亚：符号反译", "湖不是湖，宫殿不是宫殿，语言改换了事物。"],
	["OliviaFalseDescriptionNode", "奥利维亚：虚假描述", "华丽词语越准确，现实越污浊。"]
]
const SIGN_FRACTURE_COLORS := [
	Color(0.95, 0.92, 0.78, 1.0),
	Color(0.42, 0.64, 1.0, 1.0),
	Color(0.92, 0.80, 0.24, 1.0),
	Color(0.74, 0.28, 0.98, 1.0),
	Color(0.12, 0.12, 0.12, 1.0)
]
const THIN_ASCENT_NODES := [
	["CliffEdgeAnchorNode", "悬崖边缘：第一根锚线", "空城从悬崖边缘开始，所有桥都先向虚空借一点重量。"],
	["StiltScaffoldNode", "高脚架城：细柱承重", "细柱、斜撑和脚手架把房间抬起，也把不安放大。"],
	["SuspendedRoomNode", "悬空房间：吊索居住", "房间不在地上，也不在天上，只被几根绳索暂时说服。"],
	["CloudThreadBridgeNode", "云丝桥群：风中通行", "桥面像被风吹薄的布，边缘的线框比木板更诚实。"],
	["WebCityKnotNode", "网心奥塔维亚：将断之城", "蛛网承着整座城市，每一条细线都在提醒你它不是永恒的。"]
]
const THIN_ASCENT_COLORS := [
	Color(0.54, 0.78, 0.98, 1.0),
	Color(0.80, 0.88, 0.92, 1.0),
	Color(0.64, 0.90, 1.0, 1.0),
	Color(0.72, 0.78, 0.92, 1.0),
	Color(0.86, 0.92, 1.0, 1.0)
]
const TRADE_EXCHANGE_NODES := [
	["EuphemiaMemoryExchangeNode", "欧菲米亚：货物换记忆", "货物在白天交换，入夜后篝火旁交换的是狼、妹妹、宝藏、战斗和情人。"],
	["ChloeGazeExchangeNode", "克洛艾：目光换幻想", "陌生人没有开口，视线却在一秒钟里换走了约会、诱惑、误解和冲突。"],
	["EutropiaVocationExchangeNode", "埃乌特洛比亚：职业换生活", "居民迁入新的空城，换掉职业、窗景、朋友和口音，却重复同样的生活。"],
	["ErsiliaRelationExchangeNode", "艾尔西里亚：关系换废墟", "城市搬走以后，亲缘、交易、权威和代表关系只剩绳索继续纠缠。"],
	["SmeraldinaRouteExchangeNode", "斯麦拉尔迪那：路线换选择", "水路和陆路彼此交织，两点之间的交换不是直线，而是不断分岔的路线。"]
]
const TRADE_EXCHANGE_COLORS := [
	Color(1.0, 0.58, 0.22, 1.0),
	Color(0.95, 0.32, 0.72, 1.0),
	Color(0.86, 0.78, 0.38, 1.0),
	Color(0.72, 0.72, 0.68, 1.0),
	Color(0.24, 0.78, 0.68, 1.0)
]
const EYE_OBSERVATION_NODES := [
	["ValdradaMirrorNode", "瓦尔德拉达：镜湖双城", "你看见岸上的城市，湖中那座并不更虚假。"],
	["ZemrudeLowSightNode", "珍茹德：低视街区", "抬头的人看见窗帘和喷泉，低头的人只看见水沟、鱼鳞和废纸。"],
	["BaucisEarthwatchNode", "宝琪：云端观察", "城市不触碰地面，它只用望远镜确认地球仍在那里。"],
	["PhyllisMemorySightNode", "菲利德：桥窗记忆", "第一次看见时桥与窗都在闪光，住久之后只剩最快的路线。"],
	["MorianaTwoFaceNode", "莫里亚纳：正反双面", "正面是玻璃、珊瑚和水母灯，背面是铁板、煤灰和废罐。"]
]
const EYE_OBSERVATION_COLORS := [
	Color(0.62, 0.90, 1.0, 1.0),
	Color(0.38, 0.64, 0.82, 1.0),
	Color(0.86, 0.94, 1.0, 1.0),
	Color(0.72, 0.82, 1.0, 1.0),
	Color(0.74, 0.78, 0.82, 1.0)
]
const NAME_SEAL_NODES := [
	["LegendNameSeal", "阿格劳拉：传说封词", "传说替城市说话，亲眼所见被封在词外。"],
	["HouseholdSpiritSeal", "莱安德拉：宅神低语", "门口的神灵与厨房里的神灵争辩同一座城的名字。"],
	["WrongNameSeal", "皮拉：错名之城", "想象里的城堡失去了名字，真实皮拉只剩黄尘和泵声。"],
	["ReassembledRelicSeal", "克拉莉切：旧物重组", "宫殿碎片被搬进茅舍、鸡舍和展柜，名字仍留在原地。"],
	["DistantCitySeal", "伊莱那：远望之名", "高原上看到的城市叫伊莱那，走近以后它就变成另一座城。"]
]
const NAME_SEAL_COLORS := [
	Color(0.88, 0.84, 0.72, 1.0),
	Color(0.78, 0.72, 0.58, 1.0),
	Color(0.92, 0.76, 0.42, 1.0),
	Color(0.86, 0.86, 0.78, 1.0),
	Color(0.94, 0.62, 0.52, 1.0)
]
const DEAD_ECHO_NODES := [
	["RoleEchoMarker", "梅拉尼亚：角色轮替", "角色换人，对话没有停止。"],
	["FamiliarFaceEchoMarker", "阿德尔玛：旧面孔码头", "每一张脸都像某个已经离开的人。"],
	["SisterCityEchoMarker", "埃乌萨皮娅：地下姊妹城", "地下城正在改写地上的城市。"],
	["BuriedDoorEchoMarker", "阿尔嘉：埋土门声", "门在土层下面响了一声。"],
	["TripleLaudomiaEchoMarker", "劳多米亚：三重城市", "未生者比死者更多。"]
]
const DEAD_ECHO_COLORS := [
	Color(0.70, 0.82, 1.0, 1.0),
	Color(0.58, 0.72, 0.86, 1.0),
	Color(0.78, 0.86, 1.0, 1.0),
	Color(0.46, 0.54, 0.64, 1.0),
	Color(0.92, 0.86, 0.74, 1.0)
]
const SKY_ANCHOR_NODES := [
	["CarpetShrineAnchor", "埃乌多西亚：地毯神殿", "一张地毯把弯曲小巷、台阶和死胡同压成对称图案。"],
	["SkyUnderProjectionAnchor", "贝尔萨贝阿：天地投影", "黄金上城与地下机械城互相解释，真正的废物在天上拖成彗星。"],
	["StarBlueprintAnchor", "泰克拉：星空蓝图", "工地不能停下。夜色落下时，蓝图就是满天繁星。"],
	["EclipseGateAnchor", "佩林奇亚：月蚀城门", "黄道与天空轴线被刻进城墙，现实的阴影也被框在其中。"],
	["PlanetOrbitAnchor", "安德里亚：行星轨道", "每条街道都循着星轨变化，城市的改动会在远方点亮新星。"]
]
const SKY_ANCHOR_COLORS := [
	Color(0.64, 0.76, 1.0, 1.0),
	Color(1.0, 0.78, 0.26, 1.0),
	Color(0.38, 0.72, 1.0, 1.0),
	Color(0.74, 0.64, 1.0, 1.0),
	Color(0.96, 0.92, 1.0, 1.0)
]
const CONTINUOUS_SPRAWL_NODES := [
	["LeoniaWastePressureNode", "莱奥尼亚：更新与丢弃", "新床单、新香皂和未开罐头让城市每天更新；城外的垃圾却把过去保存成堡垒。"],
	["TrudeIdenticalRepeatNode", "特鲁德：同款城市", "你以为离开了机场，其实抵达另一座完全相同的特鲁德。"],
	["ProcopiaCrowdWindowNode", "普罗科比亚：窗景增殖", "土坑、树木和天空被圆脸人群一年年挤掉，最后房间也被填满。"],
	["CeciliaSwallowedPastureNode", "切奇利雅：牧场被吞没", "牧人认得草场，却认不出城市；多年后，到处都混成切奇利雅。"],
	["PenthesileaCenterlessNode", "潘特熙莱雅：中心消散", "你走过工场、仓库、墓地、游艺场和荒草，却始终不能确定城市在哪里。"]
]
const CONTINUOUS_SPRAWL_COLORS := [
	Color(0.86, 0.76, 0.50, 1.0),
	Color(0.64, 0.72, 0.46, 1.0),
	Color(0.82, 0.80, 0.70, 1.0),
	Color(0.54, 0.64, 0.42, 1.0),
	Color(0.78, 0.60, 0.46, 1.0)
]
const HIDDEN_REVEAL_NODES := [
	["OlindaInnerCityRevealNode", "欧林达：针点内生城", "针头大的光点被放大后，屋顶、天线、花园、水池和下一座欧林达开始向外生长。"],
	["RaissaJoyThreadRevealNode", "莱萨：悲伤中的快乐线", "不幸的街区并不知道，孩子、小狗、玉米饼、女招待、阳伞和飞鸟已经被快乐细线连成另一座城。"],
	["MaroziaCrystalCrackRevealNode", "马洛奇亚：老鼠城与燕子城", "铅灰巷里挤满老鼠时代，厚墙偶然裂开时，水晶般透明的新城一闪而过。"],
	["TheodoraSpeciesReturnRevealNode", "特奥朵拉：物种复苏书库", "被驱逐和消灭的动物藏在图书馆的名字里，从地下书库重新醒来。"],
	["BereniceJustSeedRevealNode", "贝莱尼切：公正胚胎与毒种", "不公正的城里藏着正义机械，正义胚胎内部又有一颗准备扩大为新暴力的毒种。"]
]
const HIDDEN_REVEAL_COLORS := [
	Color(0.42, 0.92, 0.60, 1.0),
	Color(0.96, 0.84, 0.44, 1.0),
	Color(0.72, 0.94, 1.0, 1.0),
	Color(0.50, 0.78, 0.42, 1.0),
	Color(0.84, 0.62, 0.34, 1.0)
]
const STORY_PAGES := [
	["有些城市并不消失。", "它们只是拒绝被看见。"],
	["灰域是一座主城。", "十一种声音在里面互相遮蔽。"],
	["你要先听见。", "再走向属于那个主题的城市。"]
]

@export_group("Manifestation Polish")
@export var manifestation_duration := 8.0
@export var fog_start_value := 0.075
@export var fog_end_value := 0.0
@export var particle_fade_start := 1.0
@export var particle_fade_end := 7.2
@export var camera_framing_enabled := true
@export var manifestation_camera_pitch_offset := 7.0
@export var manifestation_camera_framing_duration := 7.0

@export_group("Player Feel")
@export var mouse_sensitivity := 0.0025
@export var mouse_smoothing_enabled := true
@export_range(1.0, 40.0, 0.5) var mouse_smoothing_factor := 14.0
@export var pitch_min := -78.0
@export var pitch_max := 78.0
@export var mouse_drag_rotate_enabled := true
@export var mouse_enabled_in_exploration := true
@export var mouse_disabled_in_ui := true
@export var sprint_enabled := true
@export_range(1.0, 1.8, 0.05) var sprint_multiplier := 1.28
@export var jump_enabled := true
@export var jump_velocity := 4.4
@export var gravity := 14.0
@export var head_bob_enabled := true
@export var head_bob_amplitude := 0.035
@export var head_bob_frequency := 8.0
@export var head_bob_return_speed := 8.0
@export var footstep_enabled := true
@export var footstep_interval := 0.56
@export var footstep_volume := -12.0
@export var footstep_pitch_random_min := 0.92
@export var footstep_pitch_random_max := 1.08

@export_group("UI Fade")
@export var ui_fade_in_duration := 1.6
@export var ui_hold_duration := 3.0
@export var ui_fade_out_duration := 2.0
@export var choice_fade_in_duration := 1.0
@export var operation_hint_display_duration := 8.0
@export var quick_start_hint_duration := 5.0
@export_range(0.0, 1.0, 0.01) var quick_start_hint_alpha := 0.72
@export var grey_guidance_delay := 60.0
@export var grey_guidance_fade_in_duration := 4.0
@export var grey_guidance_line_count := 7
@export var grey_guidance_line_spacing := 42.0
@export_range(0.0, 1.0, 0.01) var grey_guidance_line_alpha := 0.42

@export_group("Interaction")
@export var reading_interact_radius := 5.0
@export var min_spawn_distance_from_echo_tower := 58.0
@export var min_spawn_distance_from_memory_center := 42.0
@export var echo_tower_clear_radius := 30.0

@export_group("World Bounds")
@export var grey_wrap_enabled := true
@export var grey_wrap_half_extent := GREY_WRAP_DEFAULT_HALF_EXTENT
@export var grey_wrap_margin := 1.5
@export var grey_fall_reset_y := -8.0
@export var city_boundary_enabled := true
@export var city_boundary_half_extent := CITY_BOUNDARY_DEFAULT_HALF_EXTENT
@export var city_boundary_wall_height := 10.0

@export_group("Dynamic Reverb")
@export var reverb_wet_min := 0.12
@export var reverb_wet_max := 0.48
@export var reverb_room_size_min := 0.28
@export var reverb_room_size_max := 0.86
@export var reverb_transition_speed := 2.2
@export var city_reverb_wet := 0.18
@export var city_reverb_room_size := 0.42

@export_group("Grey Audio SFX")
@export var selected_theme_index := 0
@export var zone_sfx_min_interval := 2.6
@export var zone_sfx_max_interval := 6.4
@export var zone_sfx_generated_duration := 0.75
@export var zone_sfx_volume_db := -13.0
@export var theme_sfx_min_interval := 2.0
@export var theme_sfx_max_interval := 4.8
@export var theme_sfx_generated_duration := 1.05
@export var theme_sfx_hearing_distance := 180.0
@export var theme_sfx_volume_far_db := -33.0
@export var theme_sfx_volume_near_db := -3.0
@export var theme_sfx_text_trigger_distance := 58.0
@export var theme_sfx_text_fade_in_duration := 0.55
@export var theme_sfx_text_hold_duration := 1.7
@export var theme_sfx_text_fade_out_duration := 1.15
@export var intro_bgm_volume_db := -13.0
@export var city_bgm_volume_db := -9.0
@export var grey_bgm_fade_out_duration := 1.0
@export var city_bgm_fade_in_duration := 6.0

@export_group("Grey Domain Debug")
@export var show_grey_zone_debug := true
@export_range(0.0, 1.0, 0.01) var grey_zone_debug_alpha := 0.28
@export var grey_zone_area_height := 5.0
@export var chaos_shader_enabled := true
@export_range(0.0, 1.0, 0.01) var chaos_shader_alpha := 0.52
@export var chaos_veil_count := 16
@export var chaos_veil_height := 3.0
@export var grey_mote_particle_amount := 1500
@export var grey_sand_particle_amount := 2200
@export var grey_current_particle_amount := 1600
@export var grey_willow_particle_amount := 1000
@export var grey_storm_particle_amount := 1700
@export var grey_turbulence_particle_amount := 1300
@export var grey_ash_particle_amount := 1600
@export var grey_pressure_particle_amount := 1100
@export var grey_rain_particle_amount := 1400
@export var grey_micro_glimmer_particle_amount := 900
@export var grey_film_speck_particle_amount := 1250
@export var grey_color_drift_particle_amount := 760
@export var grey_ember_particle_amount := 680
@export var grey_blindness_veil_count := 14
@export var grey_echo_wave_count := 9
@export var grey_post_process_enabled := true
@export_range(0.0, 1.5, 0.01) var grey_post_effect_strength := 0.55
@export_range(0.0, 1.0, 0.01) var grey_post_grain_strength := 0.24
@export_range(0.0, 1.0, 0.01) var grey_post_halftone_strength := 0.0
@export_range(0.0, 1.0, 0.01) var grey_post_pixel_strength := 0.08
@export_range(0.0, 1.0, 0.01) var grey_post_flatten_strength := 0.14
@export_range(0.0, 1.0, 0.01) var grey_post_edge_strength := 0.0
@export_range(0.0, 1.0, 0.01) var grey_post_contour_strength := 0.0
@export_range(0.0, 1.0, 0.01) var grey_post_solarize_strength := 0.0
@export_range(0.0, 1.0, 0.01) var grey_post_ink_outline_strength := 0.46
@export_range(0.0, 1.0, 0.01) var grey_post_stylized_shadow_strength := 0.36
@export_range(0.0, 1.0, 0.01) var grey_post_color_variation_strength := 0.22
@export_range(0.0, 1.0, 0.01) var grey_post_soft_glow_strength := 0.10

@export_group("Memory Guidance")
@export var memory_guide_enabled := true
@export var memory_guide_start_distance := 46.0
@export var memory_guide_full_distance := 15.0
@export var memory_guide_particle_amount := 180
@export_range(0.0, 3.0, 0.05) var memory_guide_light_energy := 1.15

@export_group("City Style Layers")
@export_range(0.0, 2.0, 0.01) var memory_city_style_intensity := 1.0
@export_range(0.0, 2.0, 0.01) var desire_city_style_intensity := 1.15
@export_range(0.0, 2.5, 0.05) var desire_relic_glow_energy := 1.35
@export_range(0.0, 2.0, 0.05) var desire_relic_particle_scale := 1.0
@export_range(0.0, 2.0, 0.01) var signs_city_style_intensity := 1.25
@export_range(0.0, 2.5, 0.05) var sign_fracture_glow_energy := 1.25
@export_range(0.0, 2.0, 0.05) var sign_fracture_particle_scale := 1.0
@export_range(0.0, 2.0, 0.01) var thin_city_style_intensity := 1.15
@export_range(0.0, 2.5, 0.05) var thin_node_glow_energy := 1.18
@export_range(0.0, 2.0, 0.05) var thin_node_particle_scale := 1.0
@export_range(0.0, 2.0, 0.01) var trade_city_style_intensity := 1.18
@export_range(0.0, 2.5, 0.05) var trade_exchange_glow_energy := 1.22
@export_range(0.0, 2.0, 0.05) var trade_exchange_particle_scale := 1.0
@export_range(0.0, 2.0, 0.01) var eyes_city_style_intensity := 1.22
@export_range(0.0, 2.5, 0.05) var eye_observation_glow_energy := 1.28
@export_range(0.0, 2.0, 0.05) var eye_observation_particle_scale := 1.0
@export_range(0.0, 2.0, 0.01) var names_city_style_intensity := 1.12
@export_range(0.0, 2.5, 0.05) var name_seal_glow_energy := 1.18
@export_range(0.0, 2.0, 0.05) var name_seal_particle_scale := 1.0
@export_range(0.0, 2.0, 0.01) var dead_city_style_intensity := 1.18
@export_range(0.0, 2.5, 0.05) var dead_echo_glow_energy := 1.20
@export_range(0.0, 2.0, 0.05) var dead_echo_particle_scale := 1.0
@export_range(0.0, 2.0, 0.01) var sky_city_style_intensity := 1.22
@export_range(0.0, 2.5, 0.05) var sky_anchor_glow_energy := 1.26
@export_range(0.0, 2.0, 0.05) var sky_anchor_particle_scale := 1.0
@export_range(0.0, 2.0, 0.01) var continuous_city_style_intensity := 1.14
@export_range(0.0, 2.5, 0.05) var continuous_node_glow_energy := 1.10
@export_range(0.0, 2.0, 0.05) var continuous_node_particle_scale := 1.0
@export_range(0.0, 2.0, 0.01) var hidden_city_style_intensity := 1.18
@export_range(0.0, 2.5, 0.05) var hidden_node_glow_energy := 1.16
@export_range(0.0, 2.0, 0.05) var hidden_node_particle_scale := 1.0
@export var city_post_process_enabled := true
@export_range(0.0, 1.0, 0.01) var city_post_effect_strength := 0.34
@export_range(0.0, 1.0, 0.01) var city_residual_grey_chaos_strength := 0.18
@export_range(0.0, 1.0, 0.01) var city_residual_grey_grain_strength := 0.09
@export_range(0.0, 1.0, 0.01) var city_residual_halftone_strength := 0.025
@export_range(0.0, 1.0, 0.01) var city_residual_wave_strength := 0.0012
@export_range(0.0, 1.0, 0.01) var city_post_ink_outline_strength := 0.38
@export_range(0.0, 1.0, 0.01) var city_post_stylized_shadow_strength := 0.24
@export_range(0.0, 1.0, 0.01) var city_post_color_variation_strength := 0.14
@export_range(0.0, 1.0, 0.01) var city_post_soft_glow_strength := 0.08
@export var city_guidance_delay := 60.0
@export var city_guidance_repeat_delay := 45.0

var phase := GamePhase.MAIN_MENU
var previous_phase := GamePhase.MAIN_MENU
var player
var world_environment: WorldEnvironment
var environment: Environment
var ui_root: Control
var main_menu: Control
var story_panel: Control
var story_text: Label
var story_next_button: Button
var mechanic_prompt: Control
var options_panel: Control
var theme_select: Control
var theme_select_status_label: Label
var theme_buttons: Array[Button] = []
var hint_label: Label
var reading_panel: Control
var reading_text: Label
var reading_next_button: Button
var choice_panel: Control
var pause_menu: Control
var operation_hint_panel: Control
var operation_hint_label: Label
var quick_hint_label: Label
var grey_countdown_label: Label
var grey_guidance_root: Control
var grey_guidance_lines: Array[ColorRect] = []
var grey_post_process_rect: ColorRect
var grey_post_process_material: ShaderMaterial
var direction_tint: ColorRect
var grey_visual_root: Node3D
var grey_particles: GPUParticles3D
var grey_sand_particles: GPUParticles3D
var grey_current_particles: GPUParticles3D
var grey_willow_particles: GPUParticles3D
var grey_storm_particles: GPUParticles3D
var grey_turbulence_particles: GPUParticles3D
var grey_extra_particles: Array[GPUParticles3D] = []
var grey_silhouettes: Node3D
var grey_zone_debug_root: Node3D
var grey_chaos_root: Node3D
var grey_environment_root: Node3D
var memory_guide_particles: GPUParticles3D
var memory_guide_light: OmniLight3D
var sound_zones: Node3D
var memory_center_trigger: Area3D
var manifested_city: Node3D
var city_visual_root: Node3D
var city_collision_root: Node3D
var reading_trigger: Area3D
var memory_city_variant_roots: Array = []
var selected_memory_city_index := 0
var active_memory_city_build_index := 0
var active_city_visual_parent: Node3D
var echo_tower_built := false
var memory_courtyard_built := false
var desire_relic_visuals: Array[Node3D] = []
var desire_relic_areas: Array[Area3D] = []
var desire_collected_relics: Array[int] = []
var desire_active_relic_index := -1
var desire_goal_trigger: Area3D
var sign_node_visuals: Array[Node3D] = []
var sign_node_areas: Array[Area3D] = []
var sign_completed_nodes: Array[int] = []
var sign_active_node_index := -1
var sign_goal_trigger: Area3D
var thin_node_visuals: Array[Node3D] = []
var thin_node_areas: Array[Area3D] = []
var thin_completed_nodes: Array[int] = []
var thin_active_node_index := -1
var thin_goal_trigger: Area3D
var trade_node_visuals: Array[Node3D] = []
var trade_node_areas: Array[Area3D] = []
var trade_completed_nodes: Array[int] = []
var trade_active_node_index := -1
var trade_goal_trigger: Area3D
var eye_observation_visuals: Array[Node3D] = []
var eye_observation_areas: Array[Area3D] = []
var eye_completed_observations: Array[int] = []
var eye_active_observation_index := -1
var eye_goal_trigger: Area3D
var name_seal_visuals: Array[Node3D] = []
var name_seal_areas: Array[Area3D] = []
var name_completed_seals: Array[int] = []
var name_active_seal_index := -1
var name_goal_trigger: Area3D
var dead_echo_visuals: Array[Node3D] = []
var dead_echo_areas: Array[Area3D] = []
var dead_completed_echoes: Array[int] = []
var dead_active_echo_index := -1
var dead_goal_trigger: Area3D
var sky_anchor_visuals: Array[Node3D] = []
var sky_anchor_areas: Array[Area3D] = []
var sky_completed_anchors: Array[int] = []
var sky_active_anchor_index := -1
var sky_goal_trigger: Area3D
var continuous_node_visuals: Array[Node3D] = []
var continuous_node_areas: Array[Area3D] = []
var continuous_completed_nodes: Array[int] = []
var continuous_active_node_index := -1
var continuous_goal_trigger: Area3D
var hidden_node_visuals: Array[Node3D] = []
var hidden_node_areas: Array[Area3D] = []
var hidden_completed_nodes: Array[int] = []
var hidden_active_node_index := -1
var hidden_goal_trigger: Area3D
var memory_zone_player: AudioStreamPlayer3D
var theme_sfx_player: AudioStreamPlayer3D
var global_music_player: AudioStreamPlayer
var zone_audio_players: Array[AudioStreamPlayer3D] = []
var generated_audio_players: Array[Node] = []
var generator_playbacks: Array = []
var generator_phases: Array[float] = []
var zone_sfx_timers: Array[float] = []
var theme_sfx_timer := 0.0
var hint_cache := ""
var story_page := 0
var reading_page := 0
var can_read_tower := false
var manifest_started := false
var memory_completed := false
var memory_bus_index := -1
var world_reverb_bus_index := -1
var memory_lowpass: AudioEffectLowPassFilter
var world_reverb: AudioEffectReverb
var hint_tween: Tween
var story_tween: Tween
var operation_hint_tween: Tween
var quick_hint_tween: Tween
var theme_sfx_text_tween: Tween
var global_music_tween: Tween
var quick_start_hint_locked := false
var manifest_camera_applied_offset := 0.0
var grey_search_elapsed := 0.0
var city_guidance_timer := 0.0
var city_guidance_has_shown := false
var rng := RandomNumberGenerator.new()

func _ready() -> void:
	rng.randomize()
	_ensure_input_actions()
	_setup_audio_bus()
	_build_world()
	_build_ui()
	_enter_main_menu()

func _process(delta: float) -> void:
	_fill_generated_audio()
	_update_generated_sfx_stops(delta)
	if phase == GamePhase.GREY_VOID:
		_update_grey_wrap()
		_update_grey_post_process()
		_update_memory_guide()
		_update_grey_guidance(delta)
		_update_memory_audio()
		_update_grey_audio_sfx(delta)
		_update_direction_feedback()
		_update_dynamic_reverb(delta)
	elif phase == GamePhase.MANIFESTING:
		_update_grey_post_process()
		_hide_memory_guide()
		_hide_grey_guidance()
	elif phase == GamePhase.CITY:
		_update_city_post_process()
		_update_city_guidance(delta)
		_hide_memory_guide()
		_hide_grey_guidance()
		direction_tint.color.a = lerp(direction_tint.color.a, 0.0, delta * 3.0)
		_update_city_reverb(delta)
	else:
		_set_grey_post_process_visible(false)
		_hide_memory_guide()
		_hide_grey_guidance()

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel"):
		if phase in [GamePhase.GREY_VOID, GamePhase.CITY]:
			_show_pause_menu()
		elif phase == GamePhase.PAUSED:
			_hide_pause_menu()
	if event.is_action_pressed("toggle_zone_debug"):
		_toggle_grey_debug_visibility()
	if event.is_action_pressed("repeat_hint") and hint_cache != "":
		if phase in [GamePhase.GREY_VOID, GamePhase.CITY]:
			_show_operation_hint()
		else:
			_show_hint(hint_cache, 3.0)
	if event.is_action_pressed("interact") and phase == GamePhase.CITY:
		if selected_theme_index == THEME_DESIRE and desire_active_relic_index >= 0:
			_collect_desire_relic(desire_active_relic_index)
		elif selected_theme_index == THEME_SIGNS and sign_active_node_index >= 0:
			_activate_sign_fracture_node(sign_active_node_index)
		elif selected_theme_index == THEME_THIN and thin_active_node_index >= 0:
			_activate_thin_ascent_node(thin_active_node_index)
		elif selected_theme_index == THEME_TRADE and trade_active_node_index >= 0:
			_activate_trade_exchange_node(trade_active_node_index)
		elif selected_theme_index == THEME_EYES and eye_active_observation_index >= 0:
			_activate_eye_observation_node(eye_active_observation_index)
		elif selected_theme_index == THEME_NAMES_CITY and name_active_seal_index >= 0:
			_activate_name_seal_node(name_active_seal_index)
		elif selected_theme_index == THEME_DEAD and dead_active_echo_index >= 0:
			_activate_dead_echo_node(dead_active_echo_index)
		elif selected_theme_index == THEME_SKY and sky_active_anchor_index >= 0:
			_activate_sky_anchor_node(sky_active_anchor_index)
		elif selected_theme_index == THEME_CONTINUOUS and continuous_active_node_index >= 0:
			_activate_continuous_sprawl_node(continuous_active_node_index)
		elif selected_theme_index == THEME_HIDDEN and hidden_active_node_index >= 0:
			_activate_hidden_reveal_node(hidden_active_node_index)
		elif can_read_tower or _is_player_near_reading_trigger():
			_open_reading()

func _setup_audio_bus() -> void:
	world_reverb_bus_index = AudioServer.get_bus_index("WorldReverb")
	if world_reverb_bus_index == -1:
		AudioServer.add_bus()
		world_reverb_bus_index = AudioServer.get_bus_count() - 1
		AudioServer.set_bus_name(world_reverb_bus_index, "WorldReverb")
	world_reverb = AudioEffectReverb.new()
	world_reverb.wet = reverb_wet_max
	world_reverb.room_size = reverb_room_size_max
	AudioServer.add_bus_effect(world_reverb_bus_index, world_reverb)

	memory_bus_index = AudioServer.get_bus_index("MemoryZone")
	if memory_bus_index == -1:
		AudioServer.add_bus()
		memory_bus_index = AudioServer.get_bus_count() - 1
		AudioServer.set_bus_name(memory_bus_index, "MemoryZone")
	AudioServer.set_bus_send(memory_bus_index, "WorldReverb")
	memory_lowpass = AudioEffectLowPassFilter.new()
	memory_lowpass.cutoff_hz = 650.0
	AudioServer.add_bus_effect(memory_bus_index, memory_lowpass)

func _ensure_input_actions() -> void:
	_add_key_action("move_forward", KEY_W)
	_add_key_action("move_back", KEY_S)
	_add_key_action("move_left", KEY_A)
	_add_key_action("move_right", KEY_D)
	_add_key_action("sprint", KEY_SHIFT)
	_add_key_action("jump", KEY_SPACE)
	_add_key_action("interact", KEY_E)
	_add_key_action("repeat_hint", KEY_H)
	_add_key_action("toggle_zone_debug", KEY_F2)
	_add_key_action("ui_cancel", KEY_ESCAPE)

func _add_key_action(action_name: String, keycode: Key) -> void:
	if not InputMap.has_action(action_name):
		InputMap.add_action(action_name)
	if InputMap.action_get_events(action_name).is_empty():
		var event := InputEventKey.new()
		event.keycode = keycode
		InputMap.action_add_event(action_name, event)

func _apply_player_polish_settings() -> void:
	player.mouse_sensitivity = mouse_sensitivity
	player.mouse_smoothing_enabled = mouse_smoothing_enabled
	player.mouse_smoothing_factor = mouse_smoothing_factor
	player.pitch_min = pitch_min
	player.pitch_max = pitch_max
	player.mouse_drag_rotate_enabled = mouse_drag_rotate_enabled
	player.mouse_enabled_in_exploration = mouse_enabled_in_exploration
	player.mouse_disabled_in_ui = mouse_disabled_in_ui
	player.sprint_enabled = sprint_enabled
	player.sprint_multiplier = sprint_multiplier
	player.jump_enabled = jump_enabled
	player.jump_velocity = jump_velocity
	player.gravity = gravity
	player.head_bob_enabled = head_bob_enabled
	player.head_bob_amplitude = head_bob_amplitude
	player.head_bob_frequency = head_bob_frequency
	player.head_bob_return_speed = head_bob_return_speed
	player.footstep_enabled = footstep_enabled
	player.footstep_interval = footstep_interval
	player.footstep_volume = footstep_volume
	player.footstep_pitch_random_min = footstep_pitch_random_min
	player.footstep_pitch_random_max = footstep_pitch_random_max

func _build_world() -> void:
	world_environment = WorldEnvironment.new()
	world_environment.name = "WorldEnvironment"
	environment = Environment.new()
	environment.background_mode = Environment.BG_COLOR
	environment.background_color = Color(0.55, 0.56, 0.55)
	environment.ambient_light_source = Environment.AMBIENT_SOURCE_COLOR
	environment.ambient_light_color = Color(0.64, 0.64, 0.62)
	environment.ambient_light_energy = 0.9
	environment.fog_enabled = true
	environment.fog_light_color = Color(0.65, 0.66, 0.65)
	environment.fog_density = 0.12
	environment.fog_sky_affect = 0.75
	environment.adjustment_enabled = true
	environment.adjustment_saturation = 0.16
	environment.adjustment_contrast = 0.52
	world_environment.environment = environment
	add_child(world_environment)

	var sun := DirectionalLight3D.new()
	sun.name = "MutedSun"
	sun.rotation_degrees = Vector3(-45, -35, 0)
	sun.light_energy = 1.2
	add_child(sun)

	player = CharacterBody3D.new()
	player.name = "Player"
	player.set_script(PlayerController)
	add_child(player)
	player.global_position = PLAYER_SPAWN
	_apply_player_polish_settings()
	player.set_footstep_bus("WorldReverb")

	var level := Node3D.new()
	level.name = "MainCityGreyDomain"
	add_child(level)

	_build_grey_void(level)
	_build_sound_zones(level)
	_build_manifested_city()
	_build_audio_players()

func _build_grey_void(level: Node3D) -> void:
	grey_visual_root = Node3D.new()
	grey_visual_root.name = "GreyVisualRoot"
	level.add_child(grey_visual_root)

	var ground_mesh := MeshInstance3D.new()
	ground_mesh.name = "GreyGround"
	var plane := PlaneMesh.new()
	plane.size = Vector2(120, 120)
	ground_mesh.mesh = plane
	ground_mesh.material_override = _grey_chaos_material(Color(0.42, 0.43, 0.42, 1.0), 0.55, 3.8, 0.05, 0.06, 1.0)
	grey_visual_root.add_child(ground_mesh)

	var ground_body := StaticBody3D.new()
	ground_body.name = "GreyGroundCollision"
	ground_body.collision_layer = 1
	ground_body.collision_mask = 2
	level.add_child(ground_body)
	var ground_collision := CollisionShape3D.new()
	var ground_shape := BoxShape3D.new()
	ground_shape.size = Vector3(120, 0.2, 120)
	ground_collision.shape = ground_shape
	ground_collision.position.y = -0.1
	ground_body.add_child(ground_collision)

	grey_silhouettes = Node3D.new()
	grey_silhouettes.name = "HiddenCitySilhouetteDisabled"
	grey_visual_root.add_child(grey_silhouettes)

	grey_particles = GPUParticles3D.new()
	grey_particles.name = "GreyMoteParticles"
	grey_particles.amount = grey_mote_particle_amount
	grey_particles.lifetime = 6.5
	grey_particles.visibility_aabb = AABB(Vector3(-60, -4, -60), Vector3(120, 12, 120))
	var particle_mesh := QuadMesh.new()
	particle_mesh.size = Vector2(0.045, 0.045)
	grey_particles.draw_pass_1 = particle_mesh
	var particle_process := ParticleProcessMaterial.new()
	particle_process.emission_shape = ParticleProcessMaterial.EMISSION_SHAPE_BOX
	particle_process.emission_box_extents = Vector3(55, 4, 55)
	particle_process.gravity = Vector3.ZERO
	particle_process.initial_velocity_min = 0.35
	particle_process.initial_velocity_max = 1.35
	particle_process.direction = Vector3(1, 0, 0)
	particle_process.spread = 80.0
	particle_process.color = Color(0.82, 0.82, 0.78, 0.22)
	grey_particles.process_material = particle_process
	grey_particles.emitting = true
	grey_visual_root.add_child(grey_particles)

	grey_sand_particles = _make_grey_particle_layer(
		"DesertSandFlowParticles",
		grey_sand_particle_amount,
		Vector2(0.038, 0.012),
		Vector3(58, 1.4, 58),
		Vector3(1.0, 0.02, 0.18),
		Color(0.82, 0.76, 0.62, 0.34),
		0.9,
		2.6,
		72.0,
		4.2
	)
	grey_visual_root.add_child(grey_sand_particles)

	grey_current_particles = _make_grey_particle_layer(
		"UnderwaterCurrentParticles",
		grey_current_particle_amount,
		Vector2(0.11, 0.024),
		Vector3(58, 4.8, 58),
		Vector3(-0.25, 0.05, 1.0),
		Color(0.58, 0.70, 0.76, 0.24),
		0.35,
		1.45,
		58.0,
		8.0
	)
	grey_visual_root.add_child(grey_current_particles)

	grey_willow_particles = _make_grey_particle_layer(
		"WillowFluffParticles",
		grey_willow_particle_amount,
		Vector2(0.10, 0.10),
		Vector3(58, 5.5, 58),
		Vector3(0.18, 0.08, 0.35),
		Color(0.92, 0.92, 0.84, 0.30),
		0.12,
		0.52,
		95.0,
		12.0
	)
	grey_visual_root.add_child(grey_willow_particles)

	grey_storm_particles = _make_grey_particle_layer(
		"StormShearParticles",
		grey_storm_particle_amount,
		Vector2(0.18, 0.018),
		Vector3(60, 7.0, 60),
		Vector3(1.0, 0.10, -0.35),
		Color(0.64, 0.63, 0.58, 0.30),
		1.9,
		4.4,
		36.0,
		3.0
	)
	grey_visual_root.add_child(grey_storm_particles)

	grey_turbulence_particles = _make_grey_particle_layer(
		"TurbulenceShardParticles",
		grey_turbulence_particle_amount,
		Vector2(0.045, 0.045),
		Vector3(56, 6.0, 56),
		Vector3(-0.55, 0.22, -0.40),
		Color(0.76, 0.78, 0.76, 0.26),
		0.6,
		2.2,
		100.0,
		5.4
	)
	grey_visual_root.add_child(grey_turbulence_particles)

	_build_memory_guide_light()

	_build_grey_zone_debug()
	_build_grey_chaos_veils()
	_build_grey_environment_layers()

func _build_sound_zones(level: Node3D) -> void:
	sound_zones = Node3D.new()
	sound_zones.name = "SoundZones"
	level.add_child(sound_zones)
	for i in range(THEME_NAMES.size()):
		var zone := Area3D.new()
		zone.name = "Zone_%s_AudioArea" % _ascii_zone_name(THEME_NAMES[i], i)
		zone.position = ZONE_POSITIONS[i]
		zone.rotation_degrees.y = ZONE_ROTATIONS[i]
		zone.collision_layer = 0
		zone.collision_mask = 2
		var zone_shape := CollisionShape3D.new()
		var box := BoxShape3D.new()
		box.size = Vector3(ZONE_SHAPES[i].x, grey_zone_area_height, ZONE_SHAPES[i].y)
		zone_shape.shape = box
		zone_shape.position.y = grey_zone_area_height * 0.5
		zone.add_child(zone_shape)
		sound_zones.add_child(zone)

	memory_center_trigger = Area3D.new()
	memory_center_trigger.name = "MemoryCenterTrigger"
	memory_center_trigger.position = MEMORY_POS
	memory_center_trigger.collision_layer = 0
	memory_center_trigger.collision_mask = 2
	var trigger_shape := CollisionShape3D.new()
	var sphere := SphereShape3D.new()
	sphere.radius = 5.0
	trigger_shape.shape = sphere
	memory_center_trigger.add_child(trigger_shape)
	memory_center_trigger.body_entered.connect(_on_memory_center_entered)
	sound_zones.add_child(memory_center_trigger)

func _build_grey_zone_debug() -> void:
	grey_zone_debug_root = Node3D.new()
	grey_zone_debug_root.name = "GreyZoneDebugVisibleWhitebox"
	grey_zone_debug_root.visible = show_grey_zone_debug
	grey_visual_root.add_child(grey_zone_debug_root)

	for i in range(THEME_NAMES.size()):
		var zone_mesh := MeshInstance3D.new()
		zone_mesh.name = "Debug_%s_Range" % _ascii_zone_name(THEME_NAMES[i], i)
		var cylinder := CylinderMesh.new()
		cylinder.top_radius = 1.0
		cylinder.bottom_radius = 1.0
		cylinder.height = 0.035
		cylinder.radial_segments = 64
		zone_mesh.mesh = cylinder
		zone_mesh.position = ZONE_POSITIONS[i] + Vector3(0, 0.04 + float(i) * 0.006, 0)
		zone_mesh.rotation_degrees.y = ZONE_ROTATIONS[i]
		zone_mesh.scale = Vector3(ZONE_SHAPES[i].x * 0.5, 1.0, ZONE_SHAPES[i].y * 0.5)
		zone_mesh.material_override = _zone_debug_material(ZONE_COLORS[i], grey_zone_debug_alpha)
		grey_zone_debug_root.add_child(zone_mesh)

		var label := Label3D.new()
		label.name = "Label_%s" % _ascii_zone_name(THEME_NAMES[i], i)
		label.text = THEME_NAMES[i]
		label.position = zone_mesh.position + Vector3(0, 0.35, 0)
		label.billboard = BaseMaterial3D.BILLBOARD_ENABLED
		label.modulate = Color(0.95, 0.95, 0.9, 0.86)
		label.font_size = 28
		grey_zone_debug_root.add_child(label)

func _build_grey_chaos_veils() -> void:
	grey_chaos_root = Node3D.new()
	grey_chaos_root.name = "GreyChaosShaderRoot"
	grey_chaos_root.visible = chaos_shader_enabled
	grey_visual_root.add_child(grey_chaos_root)

	for i in range(chaos_veil_count):
		var veil := MeshInstance3D.new()
		veil.name = "ChaosVeil_%02d" % i
		var plane := PlaneMesh.new()
		plane.size = Vector2(120, 16 + (i % 3) * 7)
		veil.mesh = plane
		var angle: float = TAU * float(i) / max(float(chaos_veil_count), 1.0)
		veil.position = Vector3(cos(angle) * 8.0, chaos_veil_height + float(i % 4) * 0.65, sin(angle) * 8.0)
		veil.rotation_degrees = Vector3(90.0, rad_to_deg(angle) + 20.0 * float(i % 2), 0.0)
		veil.material_override = _grey_chaos_material(Color(0.68, 0.70, 0.68, 1.0), chaos_shader_alpha, 5.0 + float(i % 4), 0.08 + float(i) * 0.01, 0.22, float(i) * 3.71 + 2.0)
		grey_chaos_root.add_child(veil)

func _build_grey_environment_layers() -> void:
	grey_environment_root = Node3D.new()
	grey_environment_root.name = "GreyEnvironmentalChaosRoot"
	grey_visual_root.add_child(grey_environment_root)

	_register_grey_extra_particle_layer(_make_grey_particle_layer(
		"AshfallParticles",
		grey_ash_particle_amount,
		Vector2(0.032, 0.032),
		Vector3(58, 8.0, 58),
		Vector3(0.18, -1.0, 0.12),
		Color(0.72, 0.72, 0.68, 0.28),
		0.25,
		0.95,
		82.0,
		9.0
	), grey_ash_particle_amount)

	_register_grey_extra_particle_layer(_make_grey_particle_layer(
		"BlindRainStreakParticles",
		grey_rain_particle_amount,
		Vector2(0.014, 0.34),
		Vector3(58, 7.5, 58),
		Vector3(-0.08, -1.0, 0.16),
		Color(0.70, 0.74, 0.74, 0.24),
		1.1,
		2.9,
		22.0,
		3.8
	), grey_rain_particle_amount)

	_register_grey_extra_particle_layer(_make_grey_particle_layer(
		"PressureWaveDustParticles",
		grey_pressure_particle_amount,
		Vector2(0.22, 0.036),
		Vector3(58, 2.0, 58),
		Vector3(0.72, 0.02, -0.44),
		Color(0.80, 0.78, 0.70, 0.20),
		0.45,
		1.25,
		96.0,
		7.0
	), grey_pressure_particle_amount)

	_register_grey_extra_particle_layer(_make_grey_particle_layer(
		"MemoryGoldMicroGlimmerParticles",
		grey_micro_glimmer_particle_amount,
		Vector2(0.026, 0.026),
		Vector3(55, 5.6, 55),
		Vector3(0.08, 0.18, -0.04),
		Color(1.0, 0.76, 0.24, 0.30),
		0.05,
		0.30,
		100.0,
		8.5
	), grey_micro_glimmer_particle_amount)

	_register_grey_extra_particle_layer(_make_grey_particle_layer(
		"OldFilmSpeckParticles",
		grey_film_speck_particle_amount,
		Vector2(0.020, 0.020),
		Vector3(58, 6.2, 58),
		Vector3(-0.03, 0.05, 0.02),
		Color(0.86, 0.84, 0.76, 0.18),
		0.01,
		0.16,
		100.0,
		6.0
	), grey_film_speck_particle_amount)

	_register_grey_extra_particle_layer(_make_grey_particle_layer(
		"ColorDriftMistParticles",
		grey_color_drift_particle_amount,
		Vector2(0.070, 0.030),
		Vector3(58, 5.0, 58),
		Vector3(0.10, 0.04, 0.22),
		Color(0.52, 0.62, 0.78, 0.20),
		0.04,
		0.24,
		100.0,
		12.0
	), grey_color_drift_particle_amount)

	_register_grey_extra_particle_layer(_make_grey_particle_layer(
		"LowRedEmberParticles",
		grey_ember_particle_amount,
		Vector2(0.030, 0.050),
		Vector3(56, 3.6, 56),
		Vector3(0.16, 0.22, -0.08),
		Color(0.92, 0.30, 0.16, 0.22),
		0.06,
		0.34,
		100.0,
		9.5
	), grey_ember_particle_amount)

	for i in range(grey_blindness_veil_count):
		var veil := MeshInstance3D.new()
		veil.name = "BlindnessDepthVeil_%02d" % i
		var plane := PlaneMesh.new()
		plane.size = Vector2(150, 18 + float(i % 4) * 4.0)
		veil.mesh = plane
		var angle: float = TAU * float(i) / max(float(grey_blindness_veil_count), 1.0)
		veil.position = Vector3(cos(angle) * 18.0, 2.6 + float(i % 5) * 0.55, sin(angle) * 18.0)
		veil.rotation_degrees = Vector3(90.0, rad_to_deg(angle) + 90.0, 0.0)
		veil.material_override = _grey_chaos_material(Color(0.76, 0.78, 0.74, 1.0), 0.18, 2.8 + float(i % 3), 0.035 + float(i) * 0.003, 0.34, 41.0 + float(i) * 5.3)
		grey_environment_root.add_child(veil)

	for i in range(grey_echo_wave_count):
		var wave := MeshInstance3D.new()
		wave.name = "GroundEchoWave_%02d" % i
		var disk := CylinderMesh.new()
		var radius := 10.0 + float(i) * 7.0
		disk.top_radius = radius
		disk.bottom_radius = radius
		disk.height = 0.018
		disk.radial_segments = 96
		wave.mesh = disk
		wave.position = Vector3(sin(float(i) * 1.7) * 9.0, 0.055 + float(i) * 0.004, cos(float(i) * 1.3) * 9.0)
		wave.material_override = _grey_chaos_material(Color(0.62, 0.68, 0.70, 1.0), 0.055, 1.4 + float(i % 3) * 0.4, 0.018 + float(i) * 0.002, 0.05, 83.0 + float(i) * 2.1)
		grey_environment_root.add_child(wave)

func _register_grey_extra_particle_layer(particles: GPUParticles3D, base_amount: int) -> void:
	particles.set_meta("base_amount", base_amount)
	grey_extra_particles.append(particles)
	if grey_environment_root != null:
		grey_environment_root.add_child(particles)
	else:
		grey_visual_root.add_child(particles)

func _make_grey_particle_layer(layer_name: String, amount: int, quad_size: Vector2, extents: Vector3, direction: Vector3, color: Color, velocity_min: float, velocity_max: float, spread: float, lifetime: float) -> GPUParticles3D:
	var particles := GPUParticles3D.new()
	particles.name = layer_name
	particles.amount = amount
	particles.lifetime = lifetime
	particles.visibility_aabb = AABB(Vector3(-65, -5, -65), Vector3(130, 16, 130))
	var mesh := QuadMesh.new()
	mesh.size = quad_size
	particles.draw_pass_1 = mesh
	var process := ParticleProcessMaterial.new()
	process.emission_shape = ParticleProcessMaterial.EMISSION_SHAPE_BOX
	process.emission_box_extents = extents
	process.gravity = Vector3.ZERO
	process.initial_velocity_min = velocity_min
	process.initial_velocity_max = velocity_max
	process.direction = direction.normalized()
	process.spread = spread
	process.color = color
	particles.process_material = process
	particles.emitting = true
	return particles

func _build_memory_guide_light() -> void:
	var guide_root := Node3D.new()
	guide_root.name = "MemoryGuideOrb"
	guide_root.position = MEMORY_POS + Vector3(0, 2.2, 0)
	grey_visual_root.add_child(guide_root)

	memory_guide_particles = GPUParticles3D.new()
	memory_guide_particles.name = "MemoryGuideParticles"
	memory_guide_particles.amount = memory_guide_particle_amount
	memory_guide_particles.lifetime = 2.8
	memory_guide_particles.visibility_aabb = AABB(Vector3(-8, -4, -8), Vector3(16, 10, 16))
	var mesh := QuadMesh.new()
	mesh.size = Vector2(0.16, 0.16)
	memory_guide_particles.draw_pass_1 = mesh
	var process := ParticleProcessMaterial.new()
	process.emission_shape = ParticleProcessMaterial.EMISSION_SHAPE_SPHERE
	process.emission_sphere_radius = 4.5
	process.gravity = Vector3.ZERO
	process.initial_velocity_min = 0.08
	process.initial_velocity_max = 0.42
	process.direction = Vector3.UP
	process.spread = 100.0
	process.color = Color(1.0, 0.84, 0.18, 0.0)
	memory_guide_particles.process_material = process
	memory_guide_particles.emitting = false
	guide_root.add_child(memory_guide_particles)

	memory_guide_light = OmniLight3D.new()
	memory_guide_light.name = "MemoryGuideLight"
	memory_guide_light.light_color = Color(1.0, 0.84, 0.26)
	memory_guide_light.light_energy = 0.0
	memory_guide_light.omni_range = 10.0
	guide_root.add_child(memory_guide_light)

func _build_manifested_city() -> void:
	manifested_city = Node3D.new()
	manifested_city.name = "ManifestedCity"
	manifested_city.visible = false
	add_child(manifested_city)

	city_visual_root = Node3D.new()
	city_visual_root.name = "CityVisualRoot"
	manifested_city.add_child(city_visual_root)

	city_collision_root = Node3D.new()
	city_collision_root.name = "CityCollisionRoot"
	manifested_city.add_child(city_collision_root)

	_build_merged_memory_city()
	_build_desire_city()
	_build_signs_city()
	_build_thin_city()
	_build_trade_city()
	_build_eyes_city()
	_build_names_city()
	_build_dead_city()
	_build_sky_city()
	_build_continuous_city()
	_build_hidden_city()
	_select_memory_city_variant(0)
	_set_city_collision_enabled(false)

func _build_merged_memory_city() -> void:
	active_memory_city_build_index = 0
	echo_tower_built = false
	memory_courtyard_built = false
	var root := Node3D.new()
	root.name = "MemoryCity_MergedFiveChapters"
	root.visible = false
	city_visual_root.add_child(root)
	memory_city_variant_roots.append(root)
	active_city_visual_parent = root

	_build_memory_city_planned_whitebox(root)
	_build_city_boundary_walls()
	active_city_visual_parent = null

func _build_desire_city() -> void:
	active_memory_city_build_index = THEME_DESIRE
	var root := Node3D.new()
	root.name = "DesireCity_CanalMirageWhiteCity"
	root.visible = false
	city_visual_root.add_child(root)
	memory_city_variant_roots.append(root)
	active_city_visual_parent = root

	_build_desire_city_whitebox(root)
	_build_city_boundary_walls()
	active_city_visual_parent = null

func _build_signs_city() -> void:
	active_memory_city_build_index = THEME_SIGNS
	var root := Node3D.new()
	root.name = "SignsCity_SignWasteland"
	root.visible = false
	city_visual_root.add_child(root)
	memory_city_variant_roots.append(root)
	active_city_visual_parent = root

	_build_signs_city_whitebox(root)
	_build_city_boundary_walls()
	active_city_visual_parent = null

func _build_thin_city() -> void:
	active_memory_city_build_index = THEME_THIN
	var root := Node3D.new()
	root.name = "ThinCity_CityOfLightness"
	root.visible = false
	city_visual_root.add_child(root)
	memory_city_variant_roots.append(root)
	active_city_visual_parent = root

	_build_thin_city_whitebox(root)
	_build_city_boundary_walls()
	active_city_visual_parent = null

func _build_trade_city() -> void:
	active_memory_city_build_index = THEME_TRADE
	var root := Node3D.new()
	root.name = "TradeCity_CityOfFiveExchanges"
	root.visible = false
	city_visual_root.add_child(root)
	memory_city_variant_roots.append(root)
	active_city_visual_parent = root

	_build_trade_city_whitebox(root)
	_build_city_boundary_walls()
	active_city_visual_parent = null

func _build_eyes_city() -> void:
	active_memory_city_build_index = THEME_EYES
	var root := Node3D.new()
	root.name = "EyesCity_MirrorLakeDoubleCity"
	root.visible = false
	city_visual_root.add_child(root)
	memory_city_variant_roots.append(root)
	active_city_visual_parent = root

	_build_eyes_city_whitebox(root)
	_build_city_boundary_walls()
	active_city_visual_parent = null

func _build_names_city() -> void:
	active_memory_city_build_index = THEME_NAMES_CITY
	var root := Node3D.new()
	root.name = "NamesCity_VanishedNameHighland"
	root.visible = false
	city_visual_root.add_child(root)
	memory_city_variant_roots.append(root)
	active_city_visual_parent = root

	_build_names_city_whitebox(root)
	_build_city_boundary_walls()
	active_city_visual_parent = null

func _build_dead_city() -> void:
	active_memory_city_build_index = THEME_DEAD
	var root := Node3D.new()
	root.name = "DeadCity_TripleLaudomiaNecropolis"
	root.visible = false
	city_visual_root.add_child(root)
	memory_city_variant_roots.append(root)
	active_city_visual_parent = root

	_build_dead_city_whitebox(root)
	_build_city_boundary_walls()
	active_city_visual_parent = null

func _build_sky_city() -> void:
	active_memory_city_build_index = THEME_SKY
	var root := Node3D.new()
	root.name = "SkyCity_CelestialBlueprintHighland"
	root.visible = false
	city_visual_root.add_child(root)
	memory_city_variant_roots.append(root)
	active_city_visual_parent = root

	_build_sky_city_whitebox(root)
	_build_city_boundary_walls()
	active_city_visual_parent = null

func _build_continuous_city() -> void:
	active_memory_city_build_index = THEME_CONTINUOUS
	var root := Node3D.new()
	root.name = "ContinuousCity_InfiniteSprawlPlain"
	root.visible = false
	city_visual_root.add_child(root)
	memory_city_variant_roots.append(root)
	active_city_visual_parent = root

	_build_continuous_city_whitebox(root)
	_build_city_boundary_walls()
	active_city_visual_parent = null

func _build_hidden_city() -> void:
	active_memory_city_build_index = THEME_HIDDEN
	var root := Node3D.new()
	root.name = "HiddenCity_NestedDarkRevelation"
	root.visible = false
	city_visual_root.add_child(root)
	memory_city_variant_roots.append(root)
	active_city_visual_parent = root

	_build_hidden_city_whitebox(root)
	_build_city_boundary_walls()
	active_city_visual_parent = null

func _build_memory_city_variant(index: int) -> void:
	active_memory_city_build_index = index
	var root := Node3D.new()
	root.name = "MemoryCity_%d" % (index + 1)
	root.visible = false
	city_visual_root.add_child(root)
	memory_city_variant_roots.append(root)
	active_city_visual_parent = root

	match index:
		0:
			_build_memory_city_diomira()
		1:
			_build_memory_city_isidora()
		2:
			_build_memory_city_zaira()
		3:
			_build_memory_city_zora()
		_:
			_build_memory_city_maurilia()

	_build_outer_city_expansion(root, index)
	active_city_visual_parent = null

func _active_city_parent() -> Node3D:
	return active_city_visual_parent if active_city_visual_parent != null else city_visual_root

func _select_memory_city_variant(index: int) -> void:
	selected_memory_city_index = clampi(index, 0, MEMORY_CITY_TITLES.size() - 1)
	for i in range(memory_city_variant_roots.size()):
		memory_city_variant_roots[i].visible = i == selected_memory_city_index

func _build_memory_city_planned_whitebox(parent: Node3D) -> void:
	_build_memory_city_terrain(parent)
	_build_memory_city_twilight_entrance(parent)
	_build_memory_city_late_desire(parent)
	_build_memory_city_historical_scars(parent)
	_build_memory_city_static_memory(parent)
	_build_memory_city_overlay_exit(parent)
	_build_memory_city_dry_harbor(parent)
	_build_memory_city_center(parent)
	_build_memory_city_atmosphere(parent)

func _build_memory_city_terrain(parent: Node3D) -> void:
	var terrain := Node3D.new()
	terrain.name = "Terrain_FogHighlandDryBasin"
	parent.add_child(terrain)
	_add_city_block(terrain, "HighlandPlateauGround", Vector3(0, -0.06, 0), Vector3(235, 0.12, 235), 0.0, Color(0.43, 0.43, 0.39))
	_add_city_block(terrain, "DryBasinFloor", Vector3(0, 0.015, -6), Vector3(150, 0.07, 176), 0.0, Color(0.48, 0.46, 0.40))
	_add_city_block(terrain, "DryHarborBasin", Vector3(0, 0.02, 92), Vector3(116, 0.08, 34), 0.0, Color(0.34, 0.33, 0.30))
	_add_city_block(terrain, "MemoryMainStreet_SouthNorth", Vector3(0, 0.07, -40), Vector3(8, 0.08, 150), 0.0, Color(0.50, 0.49, 0.45))
	_add_city_block(terrain, "MemoryCrossStreet_WestEast", Vector3(0, 0.075, 6), Vector3(150, 0.08, 7), 0.0, Color(0.50, 0.49, 0.45))
	_add_city_block(terrain, "DryHarborRoad", Vector3(0, 0.08, 63), Vector3(74, 0.08, 6), 0.0, Color(0.47, 0.46, 0.42))
	for i in range(9):
		var wall := _make_city_asset(terrain, "SemiBuriedOldWall_%02d" % i, Vector3(-70.0 + float(i) * 17.5, 0.0, -74.0 + sin(float(i)) * 8.0), -12.0 + float(i % 5) * 6.0)
		_add_local_city_block(wall, "WallMass", Vector3(0, 1.05, 0), Vector3(9.0, 2.1, 1.1), 0.0, Color(0.42, 0.42, 0.38))
	for i in range(6):
		var door := _make_city_asset(terrain, "BrokenDoor_%02d" % i, Vector3(-48.0 + float(i) * 18.0, 0.0, -50.0 + float(i % 2) * 8.0), 0.0)
		_add_local_city_block(door, "LeftPost", Vector3(-1.25, 1.7, 0), Vector3(0.5, 3.4, 0.6), 0.0, Color(0.47, 0.45, 0.40))
		_add_local_city_block(door, "RightPost", Vector3(1.25, 1.7, 0), Vector3(0.5, 3.4, 0.6), 0.0, Color(0.47, 0.45, 0.40))

func _build_memory_city_twilight_entrance(parent: Node3D) -> void:
	var zone := _make_city_zone(parent, "ZoneA_TwilightEntrance")
	for i in range(9):
		var x := 28.0 + float(i % 3) * 13.5
		var z := -92.0 + float(i / 3) * 13.5
		_build_silver_dome_house(zone, "SilverDomeHouse_%02d" % i, Vector3(x, 0, z), -8.0 + float(i) * 5.0)
	_build_twilight_fry_shop(zone, Vector3(37, 0, -54), -16.0)
	_build_voice_balcony(zone, Vector3(55, 0, -48), 90.0)
	_build_golden_rooster_tower(zone, Vector3(28, 0, -31), -10.0)
	_build_bronze_god_statue(zone, "BronzeGodStatue_Left", Vector3(-10, 0, -39), 0.0)
	_build_bronze_god_statue(zone, "BronzeGodStatue_Right", Vector3(12, 0, -39), 0.0)
	_build_postcard_rack(zone, Vector3(46, 0, -72), 22.0)

func _build_memory_city_late_desire(parent: Node3D) -> void:
	var zone := _make_city_zone(parent, "ZoneB_LateDesire")
	_build_shell_spiral_stair(zone, Vector3(-70, 0, -21), 18.0)
	_build_telescope_workshop(zone, Vector3(-57, 0, -32), -8.0)
	_build_violin_workshop(zone, Vector3(-45, 0, -28), 6.0)
	_build_old_men_wall_planned(zone, Vector3(-64, 0, 8), 90.0)
	for i in range(5):
		_build_repeated_courtyard(zone, "DesireCourtyard_%02d" % i, Vector3(-78.0 + float(i) * 12.0, 0, -4.0 + float(i % 2) * 12.0), float(i) * 4.0)

func _build_memory_city_historical_scars(parent: Node3D) -> void:
	var zone := _make_city_zone(parent, "ZoneC_HistoricalScars")
	for i in range(5):
		_build_tall_bastion(zone, "TallBastion_%02d" % i, Vector3(-34.0 + float(i) * 17.0, 0, 42.0 + float(i % 2) * 10.0), float(i) * 11.0)
	_build_curved_arcade(zone, Vector3(-37, 0, 23), 0.0)
	_build_curved_arcade(zone, Vector3(37, 0, 23), 180.0)
	_build_gallows_lamp_post(zone, Vector3(0, 0, 35), 0.0)
	_build_red_memory_rope(zone, Vector3(10, 2.8, 35), 0.0)
	_build_lover_fence(zone, Vector3(32, 0, 50), 8.0)
	_build_slanted_gutter_house(zone, Vector3(-38, 0, 54), -12.0)

func _build_memory_city_static_memory(parent: Node3D) -> void:
	var zone := _make_city_zone(parent, "ZoneD_StaticMemory")
	_build_great_bronze_bell_tower(zone, Vector3(-38, 0, -24), -8.0)
	_build_striped_barber_shop(zone, Vector3(36, 0, -25), 6.0)
	_build_nine_spout_fountain(zone, Vector3(0, 0, 39), 0.0)
	_build_glass_observatory(zone, Vector3(-56, 0, 20), 12.0)
	_build_watermelon_kiosk(zone, Vector3(48, 0, 28), -18.0)
	_build_hermit_lion_statue(zone, Vector3(22, 0, 37), 0.0)
	_build_turkish_bath(zone, Vector3(58, 0, 39), -12.0)
	_build_corner_cafe(zone, Vector3(-52, 0, 37), 22.0)
	_build_honeycomb_memory_wall(zone, Vector3(-43, 0, 6), 90.0)
	_build_honeycomb_memory_wall(zone, Vector3(43, 0, 6), -90.0)

func _build_memory_city_overlay_exit(parent: Node3D) -> void:
	var zone := _make_city_zone(parent, "ZoneE_OldNewOverlay")
	_build_bus_station(zone, Vector3(72, 0, 3), -90.0)
	_build_old_bandstand(zone, Vector3(77, 0, -15), 0.0)
	_build_new_arch_bridge(zone, Vector3(78, 0, 26), 0.0)
	_build_powder_factory(zone, Vector3(96, 0, 43), -8.0)
	_build_white_parasol_ladies(zone, Vector3(70, 0, -32), 0.0)
	_build_old_new_overlay_wall(zone, Vector3(102, 0, 0), 90.0)
	_build_empty_shrine(zone, Vector3(83, 0, 54), -20.0)
	_build_foreign_shrine(zone, Vector3(104, 0, -45), 16.0)

func _build_memory_city_dry_harbor(parent: Node3D) -> void:
	var zone := _make_city_zone(parent, "ZoneG_DryHarbor")
	_build_crystal_theater(zone, Vector3(66, 0, 72), -18.0)
	_build_dry_dock(zone, Vector3(-18, 0, 92), 0.0)
	_build_torn_net_frame(zone, Vector3(7, 0, 91), 8.0)
	_build_three_elders_dock_seat(zone, Vector3(28, 0, 87), -12.0)
	for i in range(5):
		var post := _make_city_asset(zone, "HarborMemoryPost_%02d" % i, Vector3(-44.0 + float(i) * 21.0, 0, 103.0), 0.0)
		_add_local_city_block(post, "Post", Vector3(0, 1.5, 0), Vector3(0.55, 3.0, 0.55), 0.0, Color(0.34, 0.32, 0.28))

func _build_memory_city_center(parent: Node3D) -> void:
	var zone := _make_city_zone(parent, "ZoneF_EchoTowerCentralPlaza")
	var disk := CSGCylinder3D.new()
	disk.name = "EchoTowerRingPlaza"
	disk.radius = 25.5
	disk.height = 0.12
	disk.sides = 72
	disk.position.y = 0.065
	disk.material = _mat(Color(0.55, 0.54, 0.49), 1.0)
	zone.add_child(disk)
	_add_box_collision("EchoTowerRingPlazaCollision", Vector3(0, 0.055, 0), Vector3(51, 0.11, 51), 0.0)
	for i in range(16):
		var angle := TAU * float(i) / 16.0
		var marker := _make_city_asset(zone, "CentralPlazaMemoryMarker_%02d" % i, Vector3(cos(angle) * 23.0, 0, sin(angle) * 23.0), rad_to_deg(-angle))
		_add_local_city_block(marker, "Stone", Vector3(0, 0.25, 0), Vector3(1.0, 0.5, 2.8), 0.0, Color(0.46, 0.45, 0.41), false)
	_build_echo_tower()

func _make_city_zone(parent: Node3D, zone_name: String) -> Node3D:
	var zone := Node3D.new()
	zone.name = zone_name
	parent.add_child(zone)
	return zone

func _make_city_asset(parent: Node3D, asset_name: String, pos: Vector3, yaw_degrees: float) -> Node3D:
	var asset := Node3D.new()
	asset.name = asset_name
	asset.position = pos
	asset.rotation_degrees.y = yaw_degrees
	parent.add_child(asset)
	return asset

func _asset_global_pos(asset: Node3D, local_pos: Vector3) -> Vector3:
	return asset.position + local_pos.rotated(Vector3.UP, deg_to_rad(asset.rotation_degrees.y))

func _asset_global_yaw(asset: Node3D, local_yaw_degrees: float) -> float:
	return asset.rotation_degrees.y + local_yaw_degrees

func _add_local_city_block(asset: Node3D, part_name: String, local_pos: Vector3, size: Vector3, local_yaw_degrees: float, color: Color, collision := true) -> void:
	var global_pos := _asset_global_pos(asset, local_pos)
	var global_yaw := _asset_global_yaw(asset, local_yaw_degrees)
	var full_name := "%s_%s" % [asset.name, part_name]
	if _should_keep_clear_for_echo_tower(full_name, global_pos, size):
		return
	var box := CSGBox3D.new()
	box.name = part_name
	box.position = local_pos
	box.size = size
	box.rotation_degrees.y = local_yaw_degrees
	box.material = _mat(color, color.a)
	asset.add_child(box)
	if collision:
		_add_box_collision(full_name + "Collision", global_pos, size, global_yaw)

func _add_local_cylinder(asset: Node3D, part_name: String, local_pos: Vector3, radius: float, height: float, color: Color, sides := 24, collision := false) -> void:
	var global_pos := _asset_global_pos(asset, local_pos)
	var size := Vector3(radius * 2.0, height, radius * 2.0)
	var full_name := "%s_%s" % [asset.name, part_name]
	if _should_keep_clear_for_echo_tower(full_name, global_pos, size):
		return
	var cylinder := CSGCylinder3D.new()
	cylinder.name = part_name
	cylinder.radius = radius
	cylinder.height = height
	cylinder.sides = sides
	cylinder.position = local_pos
	cylinder.material = _mat(color, color.a)
	asset.add_child(cylinder)
	if collision:
		_add_box_collision(full_name + "Collision", global_pos, size, _asset_global_yaw(asset, 0.0))

func _build_silver_dome_house(parent: Node3D, asset_name: String, pos: Vector3, yaw: float) -> void:
	var asset := _make_city_asset(parent, asset_name, pos, yaw)
	_add_local_city_block(asset, "WhiteboxReplaceRoot", Vector3(0, 2.0, 0), Vector3(8.0, 4.0, 7.0), 0.0, Color(0.54, 0.54, 0.50))
	_add_local_cylinder(asset, "SilverDomeRoof", Vector3(0, 4.5, 0), 4.1, 1.1, Color(0.78, 0.79, 0.75), 32)

func _build_bronze_god_statue(parent: Node3D, asset_name: String, pos: Vector3, yaw: float) -> void:
	var asset := _make_city_asset(parent, asset_name, pos, yaw)
	_add_local_cylinder(asset, "Pedestal", Vector3(0, 0.45, 0), 1.25, 0.9, Color(0.35, 0.34, 0.30), 18, true)
	_add_local_city_block(asset, "BronzeBody", Vector3(0, 2.0, 0), Vector3(0.9, 2.5, 0.7), 0.0, Color(0.33, 0.47, 0.39))
	_add_local_city_block(asset, "RaisedArm", Vector3(0.65, 2.6, 0), Vector3(0.35, 1.5, 0.35), -18.0, Color(0.32, 0.45, 0.36), false)

func _build_crystal_theater(parent: Node3D, pos: Vector3, yaw: float) -> void:
	var asset := _make_city_asset(parent, "CrystalTheater", pos, yaw)
	_add_local_city_block(asset, "TranslucentStageHall", Vector3(0, 3.5, 0), Vector3(18, 7, 12), 0.0, Color(0.62, 0.76, 0.80, 0.46))
	_add_local_city_block(asset, "OpenStageBlock", Vector3(0, 1.0, -5.0), Vector3(14, 2, 2), 0.0, Color(0.50, 0.58, 0.60))

func _build_golden_rooster_tower(parent: Node3D, pos: Vector3, yaw: float) -> void:
	var asset := _make_city_asset(parent, "GoldenRoosterTower", pos, yaw)
	_add_local_city_block(asset, "NarrowTower", Vector3(0, 5.0, 0), Vector3(3.4, 10.0, 3.4), 0.0, Color(0.48, 0.47, 0.42))
	_add_local_cylinder(asset, "ClockCap", Vector3(0, 10.6, 0), 2.1, 1.2, Color(0.43, 0.42, 0.37), 20)
	_add_local_city_block(asset, "GoldenRoosterPlaceholder", Vector3(0, 12.0, 0), Vector3(1.8, 0.8, 0.45), 0.0, Color(0.94, 0.72, 0.22), false)

func _build_twilight_fry_shop(parent: Node3D, pos: Vector3, yaw: float) -> void:
	var asset := _make_city_asset(parent, "TwilightFryShop", pos, yaw)
	_add_local_city_block(asset, "ShopBody", Vector3(0, 2.0, 0), Vector3(8, 4, 7), 0.0, Color(0.52, 0.45, 0.36))
	_add_local_city_block(asset, "WarmWindow", Vector3(0, 2.3, -3.55), Vector3(4.8, 1.4, 0.12), 0.0, Color(1.0, 0.68, 0.28, 0.78), false)
	var light := OmniLight3D.new()
	light.name = "WarmShopLight"
	light.position = Vector3(0, 2.4, -3.8)
	light.light_color = Color(1.0, 0.62, 0.25)
	light.light_energy = 0.65
	light.omni_range = 9.0
	asset.add_child(light)

func _build_voice_balcony(parent: Node3D, pos: Vector3, yaw: float) -> void:
	var asset := _make_city_asset(parent, "VoiceBalcony", pos, yaw)
	_add_local_city_block(asset, "TwoStoryHouse", Vector3(0, 3.2, 0), Vector3(7, 6.4, 6), 0.0, Color(0.49, 0.47, 0.42))
	_add_local_city_block(asset, "BalconySlab", Vector3(0, 4.1, -3.9), Vector3(5.2, 0.35, 2.0), 0.0, Color(0.42, 0.40, 0.36))
	_add_local_city_block(asset, "BalconyRail", Vector3(0, 4.75, -4.8), Vector3(5.4, 0.7, 0.25), 0.0, Color(0.35, 0.34, 0.31), false)

func _build_shell_spiral_stair(parent: Node3D, pos: Vector3, yaw: float) -> void:
	var asset := _make_city_asset(parent, "ShellSpiralStair", pos, yaw)
	_add_local_city_block(asset, "OldWallAnchor", Vector3(0, 2.8, 1.6), Vector3(6, 5.6, 1), 0.0, Color(0.46, 0.44, 0.39))
	for step in range(9):
		var angle := float(step) * 0.72
		var local := Vector3(cos(angle) * 2.4, 0.35 + float(step) * 0.32, sin(angle) * 2.4 - 1.0)
		_add_local_city_block(asset, "ShellStep_%02d" % step, local, Vector3(2.2, 0.28, 0.75), rad_to_deg(angle), Color(0.69, 0.66, 0.58))

func _build_telescope_workshop(parent: Node3D, pos: Vector3, yaw: float) -> void:
	var asset := _make_city_asset(parent, "TelescopeWorkshop", pos, yaw)
	_add_local_city_block(asset, "WorkshopBody", Vector3(0, 2.3, 0), Vector3(9, 4.6, 7), 0.0, Color(0.50, 0.49, 0.44))
	_add_local_cylinder(asset, "TelescopeTube", Vector3(0, 4.9, -3.6), 0.35, 4.0, Color(0.28, 0.31, 0.32), 12)
	var tube := asset.get_node_or_null("TelescopeTube") as CSGCylinder3D
	if tube != null:
		tube.rotation_degrees.x = 90.0

func _build_violin_workshop(parent: Node3D, pos: Vector3, yaw: float) -> void:
	var asset := _make_city_asset(parent, "ViolinWorkshop", pos, yaw)
	_add_local_city_block(asset, "WorkshopBody", Vector3(0, 2.1, 0), Vector3(8, 4.2, 7), 0.0, Color(0.48, 0.42, 0.34))
	_add_local_city_block(asset, "ViolinSignBoard", Vector3(0, 3.6, -3.65), Vector3(3.8, 0.85, 0.18), 0.0, Color(0.68, 0.42, 0.24), false)
	_add_local_city_block(asset, "ViolinNeckLine", Vector3(0, 3.6, -3.8), Vector3(0.25, 1.45, 0.10), 0.0, Color(0.28, 0.20, 0.14), false)

func _build_old_men_wall_planned(parent: Node3D, pos: Vector3, yaw: float) -> void:
	var asset := _make_city_asset(parent, "OldMenWall", pos, yaw)
	_add_local_city_block(asset, "LongLowWall", Vector3(0, 0.9, 0), Vector3(28, 1.8, 1.4), 0.0, Color(0.42, 0.39, 0.34))
	for i in range(5):
		_add_local_city_block(asset, "Seat_%02d" % i, Vector3(-10.0 + float(i) * 5.0, 0.45, -1.35), Vector3(2.2, 0.45, 1.2), 0.0, Color(0.34, 0.32, 0.29))

func _build_repeated_courtyard(parent: Node3D, asset_name: String, pos: Vector3, yaw: float) -> void:
	var asset := _make_city_asset(parent, asset_name, pos, yaw)
	_add_local_city_block(asset, "CourtyardFloor", Vector3(0, 0.05, 0), Vector3(10, 0.1, 8), 0.0, Color(0.47, 0.46, 0.42))
	_add_local_city_block(asset, "BackWall", Vector3(0, 2.0, 3.8), Vector3(10, 4, 0.6), 0.0, Color(0.43, 0.42, 0.38))
	_add_local_city_block(asset, "LeftWall", Vector3(-4.8, 1.5, 0), Vector3(0.6, 3, 8), 0.0, Color(0.43, 0.42, 0.38))
	_add_local_city_block(asset, "RightWall", Vector3(4.8, 1.5, 0), Vector3(0.6, 3, 8), 0.0, Color(0.43, 0.42, 0.38))

func _build_tall_bastion(parent: Node3D, asset_name: String, pos: Vector3, yaw: float) -> void:
	var asset := _make_city_asset(parent, asset_name, pos, yaw)
	_add_local_city_block(asset, "ThickBase", Vector3(0, 4.0, 0), Vector3(9, 8, 9), 0.0, Color(0.40, 0.40, 0.37))
	_add_local_city_block(asset, "UpperBlock", Vector3(0, 10.0, 0), Vector3(7, 4, 7), 0.0, Color(0.36, 0.37, 0.34))

func _build_curved_arcade(parent: Node3D, pos: Vector3, yaw: float) -> void:
	var asset := _make_city_asset(parent, "CurvedArcade_%s" % ("Left" if pos.x < 0.0 else "Right"), pos, yaw)
	for i in range(7):
		var z := -12.0 + float(i) * 4.0
		_add_local_city_block(asset, "PillarA_%02d" % i, Vector3(-1.8, 1.8, z), Vector3(0.55, 3.6, 0.75), 0.0, Color(0.45, 0.44, 0.40))
		_add_local_city_block(asset, "PillarB_%02d" % i, Vector3(1.8, 1.8, z), Vector3(0.55, 3.6, 0.75), 0.0, Color(0.45, 0.44, 0.40))
		_add_local_city_block(asset, "Lintel_%02d" % i, Vector3(0, 3.65, z), Vector3(4.2, 0.45, 0.75), 0.0, Color(0.45, 0.44, 0.40))

func _build_gallows_lamp_post(parent: Node3D, pos: Vector3, yaw: float) -> void:
	var asset := _make_city_asset(parent, "GallowsLampPost", pos, yaw)
	_add_local_city_block(asset, "Post", Vector3(0, 3.0, 0), Vector3(0.45, 6, 0.45), 0.0, Color(0.24, 0.23, 0.20))
	_add_local_city_block(asset, "CrossBeam", Vector3(1.6, 5.5, 0), Vector3(3.2, 0.35, 0.35), 0.0, Color(0.24, 0.23, 0.20))
	_add_local_city_block(asset, "SmallLamp", Vector3(3.0, 4.8, 0), Vector3(0.55, 0.8, 0.55), 0.0, Color(0.85, 0.62, 0.28), false)

func _build_red_memory_rope(parent: Node3D, pos: Vector3, yaw: float) -> void:
	var asset := _make_city_asset(parent, "RedMemoryRope", pos, yaw)
	_add_local_city_block(asset, "RopeSpan", Vector3(0, 0, 0), Vector3(20, 0.12, 0.12), 0.0, Color(0.72, 0.08, 0.05), false)

func _build_lover_fence(parent: Node3D, pos: Vector3, yaw: float) -> void:
	var asset := _make_city_asset(parent, "LoverFence", pos, yaw)
	for i in range(9):
		_add_local_city_block(asset, "FencePost_%02d" % i, Vector3(-8.0 + float(i) * 2.0, 1.8, 0), Vector3(0.25, 3.6, 0.25), 0.0, Color(0.29, 0.28, 0.25))
	_add_local_city_block(asset, "FenceRail", Vector3(0, 2.5, 0), Vector3(18, 0.25, 0.2), 0.0, Color(0.29, 0.28, 0.25))

func _build_slanted_gutter_house(parent: Node3D, pos: Vector3, yaw: float) -> void:
	var asset := _make_city_asset(parent, "SlantedGutterHouse", pos, yaw)
	_add_local_city_block(asset, "OldHouseBody", Vector3(0, 3.0, 0), Vector3(9, 6, 7), 0.0, Color(0.45, 0.43, 0.38))
	_add_local_city_block(asset, "SlantedGutter", Vector3(0.5, 6.3, -3.7), Vector3(8.5, 0.3, 0.35), -10.0, Color(0.25, 0.27, 0.27), false)

func _build_great_bronze_bell_tower(parent: Node3D, pos: Vector3, yaw: float) -> void:
	var asset := _make_city_asset(parent, "GreatBronzeBellTower", pos, yaw)
	_add_local_city_block(asset, "BellTowerFrame", Vector3(0, 4.0, 0), Vector3(5, 8, 5), 0.0, Color(0.43, 0.42, 0.38))
	_add_local_cylinder(asset, "GreatBronzeBell", Vector3(0, 7.2, -0.2), 1.3, 1.4, Color(0.55, 0.39, 0.18), 24)

func _build_striped_barber_shop(parent: Node3D, pos: Vector3, yaw: float) -> void:
	var asset := _make_city_asset(parent, "StripedBarberShop", pos, yaw)
	_add_local_city_block(asset, "ShopBody", Vector3(0, 2.2, 0), Vector3(8, 4.4, 7), 0.0, Color(0.54, 0.52, 0.48))
	for i in range(5):
		_add_local_city_block(asset, "StripedFront_%02d" % i, Vector3(-3.2 + float(i) * 1.6, 2.4, -3.6), Vector3(0.8, 2.0, 0.12), 0.0, Color(0.68, 0.20, 0.18) if i % 2 == 0 else Color(0.86, 0.84, 0.74), false)

func _build_nine_spout_fountain(parent: Node3D, pos: Vector3, yaw: float) -> void:
	var asset := _make_city_asset(parent, "NineSpoutFountain", pos, yaw)
	_add_local_cylinder(asset, "FountainBasin", Vector3(0, 0.35, 0), 4.4, 0.7, Color(0.44, 0.45, 0.42), 36, true)
	_add_local_cylinder(asset, "CenterColumn", Vector3(0, 1.45, 0), 0.8, 2.2, Color(0.39, 0.40, 0.38), 24)
	for i in range(9):
		var angle := TAU * float(i) / 9.0
		_add_local_city_block(asset, "Spout_%02d" % i, Vector3(cos(angle) * 2.25, 1.35, sin(angle) * 2.25), Vector3(0.8, 0.18, 0.18), rad_to_deg(-angle), Color(0.32, 0.34, 0.34), false)

func _build_glass_observatory(parent: Node3D, pos: Vector3, yaw: float) -> void:
	var asset := _make_city_asset(parent, "GlassObservatory", pos, yaw)
	_add_local_cylinder(asset, "GlassTower", Vector3(0, 6.5, 0), 3.4, 13.0, Color(0.56, 0.70, 0.74, 0.42), 28, true)
	_add_local_cylinder(asset, "ObservationCap", Vector3(0, 13.6, 0), 4.2, 1.4, Color(0.62, 0.74, 0.76, 0.50), 28)

func _build_watermelon_kiosk(parent: Node3D, pos: Vector3, yaw: float) -> void:
	var asset := _make_city_asset(parent, "WatermelonKiosk", pos, yaw)
	_add_local_city_block(asset, "KioskBody", Vector3(0, 1.3, 0), Vector3(4.4, 2.6, 3.6), 0.0, Color(0.42, 0.48, 0.32))
	_add_local_city_block(asset, "MelonCounter", Vector3(0, 1.2, -2.0), Vector3(4.0, 0.6, 0.8), 0.0, Color(0.28, 0.52, 0.24), false)

func _build_hermit_lion_statue(parent: Node3D, pos: Vector3, yaw: float) -> void:
	var asset := _make_city_asset(parent, "HermitLionStatue", pos, yaw)
	_add_local_city_block(asset, "Pedestal", Vector3(0, 0.35, 0), Vector3(4.5, 0.7, 2.4), 0.0, Color(0.35, 0.34, 0.31), true)
	_add_local_city_block(asset, "HermitFigure", Vector3(-1.0, 1.5, 0), Vector3(0.7, 1.8, 0.5), 0.0, Color(0.46, 0.44, 0.39), false)
	_add_local_city_block(asset, "LionFigure", Vector3(1.0, 1.0, 0), Vector3(1.5, 0.9, 0.65), 0.0, Color(0.50, 0.45, 0.33), false)

func _build_turkish_bath(parent: Node3D, pos: Vector3, yaw: float) -> void:
	var asset := _make_city_asset(parent, "TurkishBath", pos, yaw)
	_add_local_city_block(asset, "LowBathHouse", Vector3(0, 1.7, 0), Vector3(12, 3.4, 8), 0.0, Color(0.50, 0.48, 0.43))
	_add_local_cylinder(asset, "BathDome", Vector3(0, 3.8, 0), 4.8, 1.2, Color(0.58, 0.56, 0.50), 32)

func _build_corner_cafe(parent: Node3D, pos: Vector3, yaw: float) -> void:
	var asset := _make_city_asset(parent, "CornerCafe", pos, yaw)
	_add_local_city_block(asset, "CornerBuilding", Vector3(0, 2.2, 0), Vector3(9, 4.4, 8), 0.0, Color(0.48, 0.42, 0.36))
	_add_local_city_block(asset, "CafeSign", Vector3(0, 3.5, -4.1), Vector3(5, 0.65, 0.16), 0.0, Color(0.64, 0.44, 0.25), false)

func _build_honeycomb_memory_wall(parent: Node3D, pos: Vector3, yaw: float) -> void:
	var asset := _make_city_asset(parent, "HoneycombMemoryWall_%s" % ("Left" if pos.x < 0.0 else "Right"), pos, yaw)
	_add_local_city_block(asset, "WallBack", Vector3(0, 2.7, 0), Vector3(1.0, 5.4, 15), 0.0, Color(0.42, 0.41, 0.37))
	for row in range(3):
		for col in range(5):
			_add_local_city_block(asset, "MemoryCell_%d_%d" % [row, col], Vector3(-0.58, 1.1 + float(row) * 1.3, -5.0 + float(col) * 2.5), Vector3(0.22, 0.65, 1.1), 0.0, Color(0.62, 0.58, 0.45), false)

func _build_postcard_rack(parent: Node3D, pos: Vector3, yaw: float) -> void:
	var asset := _make_city_asset(parent, "PostcardRack", pos, yaw)
	_add_local_city_block(asset, "RackFrame", Vector3(0, 1.9, 0), Vector3(5.5, 3.8, 0.5), 0.0, Color(0.30, 0.28, 0.24), true)
	for i in range(6):
		_add_local_city_block(asset, "Postcard_%02d" % i, Vector3(-2.0 + float(i % 3) * 2.0, 2.0 + float(i / 3) * 0.9, -0.35), Vector3(1.4, 0.7, 0.08), 0.0, Color(0.55 + float(i % 2) * 0.15, 0.38 + float(i % 3) * 0.08, 0.34 + float(i % 4) * 0.07), false)

func _build_bus_station(parent: Node3D, pos: Vector3, yaw: float) -> void:
	var asset := _make_city_asset(parent, "BusStation", pos, yaw)
	_add_local_city_block(asset, "ShelterBack", Vector3(0, 2.0, 1.5), Vector3(8, 4, 0.5), 0.0, Color(0.39, 0.40, 0.39))
	_add_local_city_block(asset, "ShelterRoof", Vector3(0, 4.1, 0), Vector3(8.5, 0.35, 4.2), 0.0, Color(0.32, 0.33, 0.32))
	_add_local_city_block(asset, "Bench", Vector3(0, 0.65, -0.6), Vector3(5.2, 0.45, 1.0), 0.0, Color(0.32, 0.28, 0.22))

func _build_old_bandstand(parent: Node3D, pos: Vector3, yaw: float) -> void:
	var asset := _make_city_asset(parent, "OldBandstand", pos, yaw)
	_add_local_cylinder(asset, "RoundStage", Vector3(0, 0.45, 0), 4.5, 0.9, Color(0.48, 0.45, 0.38), 28, true)
	_add_local_cylinder(asset, "Roof", Vector3(0, 4.4, 0), 4.8, 0.7, Color(0.38, 0.34, 0.30), 28)
	for i in range(6):
		var angle := TAU * float(i) / 6.0
		_add_local_city_block(asset, "Post_%02d" % i, Vector3(cos(angle) * 3.7, 2.4, sin(angle) * 3.7), Vector3(0.25, 3.8, 0.25), 0.0, Color(0.36, 0.33, 0.29), false)

func _build_new_arch_bridge(parent: Node3D, pos: Vector3, yaw: float) -> void:
	var asset := _make_city_asset(parent, "NewArchBridge", pos, yaw)
	_add_local_city_block(asset, "BridgeDeck", Vector3(0, 1.1, 0), Vector3(20, 1.0, 4.6), 0.0, Color(0.50, 0.50, 0.47), true)
	_add_local_city_block(asset, "LeftArchMass", Vector3(-6, 0.8, 0), Vector3(3, 1.6, 4.8), 0.0, Color(0.44, 0.44, 0.41))
	_add_local_city_block(asset, "RightArchMass", Vector3(6, 0.8, 0), Vector3(3, 1.6, 4.8), 0.0, Color(0.44, 0.44, 0.41))

func _build_powder_factory(parent: Node3D, pos: Vector3, yaw: float) -> void:
	var asset := _make_city_asset(parent, "PowderFactory", pos, yaw)
	_add_local_city_block(asset, "FactoryBody", Vector3(0, 2.5, 0), Vector3(16, 5, 10), 0.0, Color(0.38, 0.39, 0.38))
	_add_local_city_block(asset, "Chimney", Vector3(5.5, 5.8, 2.6), Vector3(1.4, 6.0, 1.4), 0.0, Color(0.28, 0.28, 0.26))

func _build_white_parasol_ladies(parent: Node3D, pos: Vector3, yaw: float) -> void:
	var asset := _make_city_asset(parent, "WhiteParasolLadies", pos, yaw)
	for i in range(2):
		var x := -1.2 + float(i) * 2.4
		_add_local_city_block(asset, "Lady_%02d" % i, Vector3(x, 1.45, 0), Vector3(0.55, 1.9, 0.45), 0.0, Color(0.68, 0.62, 0.56), false)
		_add_local_cylinder(asset, "Parasol_%02d" % i, Vector3(x, 2.7, 0), 1.1, 0.18, Color(0.86, 0.84, 0.76), 20)

func _build_old_new_overlay_wall(parent: Node3D, pos: Vector3, yaw: float) -> void:
	var asset := _make_city_asset(parent, "OldNewOverlayWall", pos, yaw)
	_add_local_city_block(asset, "OldHalf", Vector3(0, 2.4, -4.1), Vector3(1.0, 4.8, 8.2), 0.0, Color(0.42, 0.36, 0.30))
	_add_local_city_block(asset, "NewHalf", Vector3(0, 2.7, 4.1), Vector3(1.0, 5.4, 8.2), 0.0, Color(0.54, 0.56, 0.56))

func _build_empty_shrine(parent: Node3D, pos: Vector3, yaw: float) -> void:
	var asset := _make_city_asset(parent, "EmptyShrine", pos, yaw)
	_add_local_city_block(asset, "ShrineFrame", Vector3(0, 2.0, 0), Vector3(5.0, 4.0, 3.6), 0.0, Color(0.44, 0.42, 0.38))
	_add_local_city_block(asset, "EmptyNiche", Vector3(0, 2.2, -1.9), Vector3(2.4, 2.4, 0.12), 0.0, Color(0.08, 0.08, 0.07), false)

func _build_foreign_shrine(parent: Node3D, pos: Vector3, yaw: float) -> void:
	var asset := _make_city_asset(parent, "ForeignShrine", pos, yaw)
	_add_local_city_block(asset, "ForeignBase", Vector3(0, 1.5, 0), Vector3(5.4, 3.0, 4.0), 0.0, Color(0.36, 0.39, 0.44))
	_add_local_city_block(asset, "StrangeCap", Vector3(0, 3.35, 0), Vector3(6.2, 0.8, 4.8), 0.0, Color(0.26, 0.28, 0.34))

func _build_dry_dock(parent: Node3D, pos: Vector3, yaw: float) -> void:
	var asset := _make_city_asset(parent, "DryDock", pos, yaw)
	_add_local_city_block(asset, "DockDeck", Vector3(0, 0.55, 0), Vector3(28, 0.7, 8), 0.0, Color(0.32, 0.29, 0.24), true)
	for i in range(5):
		_add_local_city_block(asset, "DockPlank_%02d" % i, Vector3(-11.0 + float(i) * 5.5, 1.0, 0), Vector3(0.35, 0.25, 8.8), 0.0, Color(0.26, 0.24, 0.20), false)

func _build_torn_net_frame(parent: Node3D, pos: Vector3, yaw: float) -> void:
	var asset := _make_city_asset(parent, "TornNetFrame", pos, yaw)
	_add_local_city_block(asset, "LeftPost", Vector3(-3.5, 2.2, 0), Vector3(0.35, 4.4, 0.35), 0.0, Color(0.28, 0.25, 0.21))
	_add_local_city_block(asset, "RightPost", Vector3(3.5, 2.2, 0), Vector3(0.35, 4.4, 0.35), 0.0, Color(0.28, 0.25, 0.21))
	_add_local_city_block(asset, "TornNetSheet", Vector3(0, 2.5, 0), Vector3(6.2, 2.4, 0.08), 0.0, Color(0.62, 0.61, 0.52, 0.42), false)

func _build_three_elders_dock_seat(parent: Node3D, pos: Vector3, yaw: float) -> void:
	var asset := _make_city_asset(parent, "ThreeEldersDockSeat", pos, yaw)
	for i in range(3):
		_add_local_city_block(asset, "Seat_%02d" % i, Vector3(-2.8 + float(i) * 2.8, 0.55, 0), Vector3(1.8, 0.55, 1.4), 0.0, Color(0.30, 0.27, 0.23), true)
		_add_local_city_block(asset, "Back_%02d" % i, Vector3(-2.8 + float(i) * 2.8, 1.25, 0.55), Vector3(1.8, 1.0, 0.25), 0.0, Color(0.27, 0.24, 0.20), false)

func _build_memory_city_atmosphere(parent: Node3D) -> void:
	var atmosphere := Node3D.new()
	atmosphere.name = "MemoryCityAtmosphere_StyleDirection"
	parent.add_child(atmosphere)
	atmosphere.add_child(_make_city_particle_layer("CityDustParticles", 2200, Vector2(0.040, 0.040), Vector3(116, 6.5, 116), Vector3(0.28, 0.05, -0.12), Color(0.70, 0.68, 0.60, 0.22), 0.12, 0.72, 96.0, 10.0))
	atmosphere.add_child(_make_city_particle_layer("PaperScrapParticles", 520, Vector2(0.18, 0.08), Vector3(106, 5.5, 106), Vector3(0.16, 0.08, 0.28), Color(0.84, 0.79, 0.64, 0.30), 0.08, 0.42, 100.0, 13.0))
	atmosphere.add_child(_make_city_particle_layer("OldPhotoFragmentParticles", 420, Vector2(0.14, 0.075), Vector3(110, 5.2, 110), Vector3(-0.18, 0.04, 0.22), Color(0.58, 0.46, 0.35, 0.28), 0.06, 0.32, 100.0, 14.0))
	atmosphere.add_child(_make_city_particle_layer("FaintGoldenMemoryMotes", 1120, Vector2(0.045, 0.045), Vector3(92, 6.0, 92), Vector3(0.08, 0.18, -0.04), Color(1.0, 0.78, 0.26, 0.34), 0.04, 0.26, 100.0, 11.0))
	atmosphere.add_child(_make_city_particle_layer("MemoryAshSlowFall", 900, Vector2(0.032, 0.080), Vector3(114, 8.0, 114), Vector3(-0.05, -0.22, 0.03), Color(0.55, 0.53, 0.47, 0.22), 0.04, 0.22, 92.0, 16.0))
	atmosphere.add_child(_make_city_particle_layer("BlueAfterimageMotes", 680, Vector2(0.035, 0.035), Vector3(104, 6.2, 104), Vector3(-0.06, 0.08, 0.18), Color(0.42, 0.58, 0.82, 0.20), 0.03, 0.20, 100.0, 12.5))
	atmosphere.add_child(_make_city_particle_layer("SepiaDustSecondPass", 1350, Vector2(0.026, 0.026), Vector3(116, 4.8, 116), Vector3(0.10, 0.04, -0.08), Color(0.78, 0.58, 0.34, 0.16), 0.02, 0.18, 100.0, 9.0))
	atmosphere.add_child(_make_city_particle_layer("MemoryRustNeedleParticles", 440, Vector2(0.16, 0.014), Vector3(108, 5.8, 108), Vector3(0.22, 0.06, 0.04), Color(0.56, 0.34, 0.24, 0.22), 0.04, 0.24, 100.0, 13.5))
	for i in range(8):
		var angle := TAU * float(i) / 8.0
		var pos := Vector3(cos(angle) * 42.0, 5.4 + float(i % 3) * 1.4, sin(angle) * 42.0)
		_add_city_style_veil(atmosphere, "MemoryFilmAfterimageVeil_%02d" % i, pos, Vector2(82.0, 13.0 + float(i % 2) * 6.0), rad_to_deg(angle) + 90.0, Color(0.82, 0.76, 0.58, 0.22), 0.0, 20.0 + float(i) * 3.7, memory_city_style_intensity)
	for i in range(5):
		var x := -56.0 + float(i) * 28.0
		_add_city_style_veil(atmosphere, "MemoryResidualSlice_%02d" % i, Vector3(x, 4.8, -18.0 + float(i % 2) * 46.0), Vector2(42.0, 11.0), 8.0 + float(i) * 11.0, Color(0.66, 0.66, 0.60, 0.18), 0.0, 60.0 + float(i) * 4.1, memory_city_style_intensity * 0.85)
	var afterimage := Node3D.new()
	afterimage.name = "AfterimageFrameGhosts_NoCollision"
	atmosphere.add_child(afterimage)
	for i in range(5):
		var ghost := _make_city_asset(afterimage, "ResidualFrame_%02d" % i, Vector3(-44.0 + float(i) * 22.0, 0, -28.0 + float(i % 2) * 54.0), float(i) * 7.0)
		_add_local_city_block(ghost, "LowSaturationGhostBlock", Vector3(0, 2.5, 0), Vector3(9, 5, 0.22), 0.0, Color(0.74, 0.74, 0.68, 0.12), false)

func _make_city_particle_layer(layer_name: String, amount: int, quad_size: Vector2, extents: Vector3, direction: Vector3, color: Color, velocity_min: float, velocity_max: float, spread: float, lifetime: float) -> GPUParticles3D:
	var particles := _make_grey_particle_layer(layer_name, amount, quad_size, extents, direction, color, velocity_min, velocity_max, spread, lifetime)
	particles.visibility_aabb = AABB(Vector3(-130, -8, -130), Vector3(260, 24, 260))
	return particles

func _build_thin_city_whitebox(parent: Node3D) -> void:
	_build_thin_city_terrain(parent)
	_build_thin_cliff_arrival(parent)
	_build_thin_scaffold_zone(parent)
	_build_thin_suspended_rooms(parent)
	_build_thin_cloud_bridge_zone(parent)
	_build_thin_web_chasm(parent)
	_build_thin_center(parent)
	_build_thin_atmosphere(parent)

func _build_thin_city_terrain(parent: Node3D) -> void:
	var terrain := _make_city_zone(parent, "ThinCity_CliffVoidAndHighSpans")
	_add_thin_block(terrain, "LowerCloudChasmPlane", Vector3(0, -7.8, 0), Vector3(238, 0.10, 238), 0.0, Color(0.34, 0.45, 0.54, 0.14), false, 0.14, 0.018, 0.35)
	_add_thin_block(terrain, "LeftSheerCliffFace", Vector3(-92, -2.2, 0), Vector3(10, 15, 178), -2.0, Color(0.42, 0.50, 0.56, 0.50), true, 0.50, 0.010, 0.58)
	_add_thin_block(terrain, "RightDistantCliffFace", Vector3(92, -2.4, 8), Vector3(10, 16, 166), 2.0, Color(0.38, 0.47, 0.55, 0.36), true, 0.36, 0.012, 0.52)
	_add_thin_block(terrain, "NorthCloudCliffWall", Vector3(0, -2.8, -92), Vector3(176, 13, 8), 0.0, Color(0.39, 0.48, 0.56, 0.32), true, 0.32, 0.012, 0.48)
	_add_thin_block(terrain, "SouthCloudCliffWall", Vector3(4, -2.9, 92), Vector3(168, 13, 8), 0.0, Color(0.39, 0.48, 0.56, 0.28), true, 0.28, 0.012, 0.48)

	var route_points: Array[Vector3] = [
		Vector3(-52, 0, 2),
		Vector3(-42, 0, -16),
		Vector3(-18, 0, -9),
		Vector3(0, 0, 0),
		Vector3(24, 0, -20),
		Vector3(48, 0, 14),
		Vector3(20, 0, 26),
		Vector3(-18, 0, 18),
		Vector3(-42, 0, 8)
	]
	for i in range(route_points.size() - 1):
		_build_thin_bridge_span(terrain, "MainSuspendedThreadBridge_%02d" % i, route_points[i], route_points[i + 1], 4.8, Color(0.58, 0.72, 0.82, 0.48))
	_build_thin_bridge_span(terrain, "CrossNetBridge_CenterToRooms", Vector3(0, 0, 0), Vector3(-18, 0, 18), 4.4, Color(0.62, 0.78, 0.88, 0.46))
	_build_thin_bridge_span(terrain, "CrossNetBridge_CenterToWeb", Vector3(0, 0, 0), Vector3(48, 0, 14), 4.4, Color(0.60, 0.76, 0.88, 0.46))
	_build_thin_bridge_span(terrain, "CrossNetBridge_CenterToScaffold", Vector3(0, 0, 0), Vector3(-42, 0, -16), 4.4, Color(0.58, 0.74, 0.86, 0.46))
	for i in range(route_points.size()):
		_build_thin_support_cluster(terrain, "SuspensionNeedleCluster_%02d" % i, route_points[i], 5.0 + float(i % 3) * 1.7)

func _build_thin_cliff_arrival(parent: Node3D) -> void:
	var zone := _make_city_zone(parent, "ZoneA_CliffArrivalAndAnchorLines")
	_build_thin_platform(zone, "CliffEdgeArrivalDeck", Vector3(-52, 0, 2), Vector2(28, 15), -4.0, Color(0.56, 0.70, 0.80, 0.48))
	_add_thin_block(zone, "CliffArrivalWindGate_Left", Vector3(-64, 2.8, -5), Vector3(0.18, 5.6, 0.18), 0.0, Color(0.82, 0.92, 0.98, 0.72), false, 0.72, 0.035, 0.95)
	_add_thin_block(zone, "CliffArrivalWindGate_Right", Vector3(-45, 2.8, 9), Vector3(0.18, 5.6, 0.18), 0.0, Color(0.82, 0.92, 0.98, 0.72), false, 0.72, 0.035, 0.95)
	_build_thin_line_span(zone, "FirstAnchorCable", Vector3(-64, 5.5, -5), Vector3(-45, 5.5, 9), Color(0.86, 0.94, 1.0, 0.72), 0.085)
	for i in range(5):
		_add_thin_block(zone, "WindFrayedFlag_%02d" % i, Vector3(-62.0 + float(i) * 3.8, 4.0 + float(i % 2) * 0.6, -3.5 + float(i) * 2.6), Vector3(1.6, 0.06, 0.72), float(i) * 12.0, Color(0.70, 0.86, 0.96, 0.34), false, 0.34, 0.085, 0.86)
	_build_thin_ascent_node(zone, 0, Vector3(-50, 0, 2), 18.0)

func _build_thin_scaffold_zone(parent: Node3D) -> void:
	var zone := _make_city_zone(parent, "ZoneB_StiltScaffoldForest")
	_build_thin_platform(zone, "ScaffoldNeedleDeck", Vector3(-42, 0, -16), Vector2(20, 18), 9.0, Color(0.56, 0.70, 0.78, 0.44))
	for i in range(6):
		var pos := Vector3(-52.0 + float(i % 3) * 9.0, 0, -25.0 + float(i / 3) * 15.0)
		_build_thin_scaffold_tower(zone, "ThinScaffoldTower_%02d" % i, pos, float(i) * 11.0, 7.0 + float(i % 3) * 2.2)
	for i in range(7):
		_build_thin_line_span(zone, "ScaffoldTensionLine_%02d" % i, Vector3(-56 + float(i) * 4.6, 5.8 + float(i % 2), -29), Vector3(-48 + float(i) * 5.4, 4.6, -3), Color(0.82, 0.92, 1.0, 0.55), 0.060)
	_build_thin_ascent_node(zone, 1, Vector3(-41, 0, -15), -8.0)

func _build_thin_suspended_rooms(parent: Node3D) -> void:
	var zone := _make_city_zone(parent, "ZoneC_SuspendedRoomsAndBalconies")
	_build_thin_platform(zone, "SuspendedRoomLanding", Vector3(-18, 0, 18), Vector2(21, 16), -7.0, Color(0.62, 0.76, 0.86, 0.42))
	var rooms := [
		[Vector3(-31, 4.8, 24), -8.0, Vector3(6.0, 3.0, 5.2)],
		[Vector3(-18, 6.2, 31), 9.0, Vector3(7.2, 3.2, 4.8)],
		[Vector3(-4, 4.2, 22), -16.0, Vector3(5.8, 2.8, 5.0)],
		[Vector3(-23, 7.8, 8), 18.0, Vector3(5.4, 3.0, 4.6)]
	]
	for i in range(rooms.size()):
		_build_thin_suspended_room(zone, "SuspendedRoom_%02d" % i, rooms[i][0], float(rooms[i][1]), rooms[i][2])
	_build_thin_ascent_node(zone, 2, Vector3(-18, 0, 18), 4.0)

func _build_thin_cloud_bridge_zone(parent: Node3D) -> void:
	var zone := _make_city_zone(parent, "ZoneD_CloudThreadBridges")
	_build_thin_platform(zone, "CloudThreadBridgeDeck", Vector3(24, 0, -20), Vector2(20, 13), 6.0, Color(0.58, 0.76, 0.90, 0.40))
	for i in range(5):
		var a := Vector3(10.0 + float(i) * 5.0, 0.0, -34.0 + float(i % 2) * 6.0)
		var b := Vector3(32.0 + float(i) * 5.0, 0.0, -6.0 - float(i % 2) * 4.0)
		_build_thin_bridge_span(zone, "ParallelCloudFootbridge_%02d" % i, a, b, 1.6 + float(i % 2) * 0.45, Color(0.62, 0.80, 0.94, 0.36), false)
		_build_thin_line_span(zone, "HighCloudCable_%02d" % i, a + Vector3(0, 4.6 + float(i) * 0.25, 0), b + Vector3(0, 4.8, 0), Color(0.84, 0.94, 1.0, 0.52), 0.055)
	for i in range(4):
		_add_city_style_veil(zone, "CloudSilkVeil_%02d" % i, Vector3(12.0 + float(i) * 9.0, 4.2 + float(i % 2) * 1.1, -28.0 + float(i) * 6.0), Vector2(32.0, 8.0), -18.0 + float(i) * 8.0, Color(0.76, 0.88, 1.0, 0.18), 0.0, 260.0 + float(i) * 5.0, thin_city_style_intensity)
	_build_thin_ascent_node(zone, 3, Vector3(24, 0, -20), -16.0)

func _build_thin_web_chasm(parent: Node3D) -> void:
	var zone := _make_city_zone(parent, "ZoneE_WebCityOverChasm")
	_build_thin_platform(zone, "WebCityOuterKnotDeck", Vector3(48, 0, 14), Vector2(22, 17), 12.0, Color(0.58, 0.74, 0.88, 0.42))
	var center := Vector3(48, 0, 14)
	for i in range(14):
		var angle := TAU * float(i) / 14.0
		var outer := center + Vector3(cos(angle) * (15.0 + float(i % 2) * 5.0), 0, sin(angle) * (12.0 + float(i % 3) * 4.0))
		_build_thin_line_span(zone, "WebRadialLine_%02d" % i, center + Vector3(0, 2.8, 0), outer + Vector3(0, 3.0 + float(i % 3) * 0.4, 0), Color(0.86, 0.94, 1.0, 0.58), 0.060)
		if i % 2 == 0:
			_build_thin_bridge_span(zone, "OuterWebWalkLine_%02d" % i, center.lerp(outer, 0.38), outer, 1.5, Color(0.64, 0.78, 0.90, 0.34), false)
	for ring in range(3):
		var radius := 8.0 + float(ring) * 5.0
		for i in range(10):
			var a_angle := TAU * float(i) / 10.0 + float(ring) * 0.15
			var b_angle := TAU * float(i + 1) / 10.0 + float(ring) * 0.15
			_build_thin_line_span(zone, "WebRing_%02d_%02d" % [ring, i], center + Vector3(cos(a_angle) * radius, 2.6 + float(ring) * 0.55, sin(a_angle) * radius), center + Vector3(cos(b_angle) * radius, 2.6 + float(ring) * 0.55, sin(b_angle) * radius), Color(0.80, 0.90, 1.0, 0.42), 0.050)
	_build_thin_ascent_node(zone, 4, center, 24.0)

func _build_thin_center(parent: Node3D) -> void:
	var zone := _make_city_zone(parent, "ZoneF_CentralNetLookout")
	_build_thin_platform(zone, "CentralNetLookout", Vector3(0, 0, 0), Vector2(24, 24), 0.0, Color(0.60, 0.76, 0.88, 0.46))
	for i in range(16):
		var angle := TAU * float(i) / 16.0
		_build_thin_line_span(zone, "CentralLookoutTensionRay_%02d" % i, Vector3(0, 3.8, 0), Vector3(cos(angle) * 24.0, 3.0 + float(i % 3) * 0.35, sin(angle) * 24.0), Color(0.86, 0.94, 1.0, 0.48), 0.050)
	_add_thin_cylinder(zone, "CentralWindCompassRing", Vector3(0, 0.16, 0), 8.2, 0.08, Color(0.82, 0.92, 1.0, 0.26), 64, false, 0.26, 0.045, 0.86)
	_add_thin_block(zone, "NetHeartNeedle", Vector3(0, 3.6, 0), Vector3(0.22, 7.2, 0.22), 0.0, Color(0.86, 0.94, 1.0, 0.66), false, 0.66, 0.045, 0.96)
	thin_goal_trigger = Area3D.new()
	thin_goal_trigger.name = "ThinGoalTrigger"
	thin_goal_trigger.position = Vector3(0, 0.9, 0)
	thin_goal_trigger.collision_layer = 0
	thin_goal_trigger.collision_mask = 2
	var shape := CollisionShape3D.new()
	var sphere := SphereShape3D.new()
	sphere.radius = 8.0
	shape.shape = sphere
	thin_goal_trigger.add_child(shape)
	thin_goal_trigger.body_entered.connect(_on_thin_goal_entered)
	thin_goal_trigger.body_exited.connect(_on_thin_goal_exited)
	manifested_city.add_child(thin_goal_trigger)

func _build_thin_atmosphere(parent: Node3D) -> void:
	var atmosphere := Node3D.new()
	atmosphere.name = "ThinCityAtmosphere_StyleDirection"
	parent.add_child(atmosphere)
	atmosphere.add_child(_make_city_particle_layer("WindDustParticles", 1500, Vector2(0.030, 0.030), Vector3(118, 9.0, 118), Vector3(0.34, 0.08, -0.18), Color(0.72, 0.80, 0.84, 0.22), 0.08, 0.46, 100.0, 12.0))
	atmosphere.add_child(_make_city_particle_layer("CloudSilkParticles", 820, Vector2(0.20, 0.020), Vector3(116, 10.0, 116), Vector3(0.18, 0.04, 0.12), Color(0.82, 0.92, 1.0, 0.30), 0.04, 0.24, 100.0, 15.0))
	atmosphere.add_child(_make_city_particle_layer("ThinLineParticles", 620, Vector2(0.28, 0.012), Vector3(112, 8.0, 112), Vector3(-0.10, 0.12, 0.18), Color(0.86, 0.94, 1.0, 0.34), 0.04, 0.26, 100.0, 13.5))
	atmosphere.add_child(_make_city_particle_layer("FallingDustParticles", 1050, Vector2(0.035, 0.080), Vector3(112, 12.0, 112), Vector3(0.05, -0.30, -0.02), Color(0.62, 0.68, 0.70, 0.24), 0.04, 0.22, 88.0, 17.0))
	atmosphere.add_child(_make_city_particle_layer("PaleBlueMicroMotes", 980, Vector2(0.026, 0.026), Vector3(104, 8.0, 104), Vector3(0.04, 0.10, 0.02), Color(0.58, 0.78, 1.0, 0.26), 0.02, 0.18, 100.0, 11.0))
	for i in range(9):
		var angle := TAU * float(i) / 9.0
		_add_city_style_veil(atmosphere, "ThinCloudThreadVeil_%02d" % i, Vector3(cos(angle) * 48.0, 5.8 + float(i % 3) * 0.9, sin(angle) * 48.0), Vector2(72.0, 10.0 + float(i % 2) * 4.0), rad_to_deg(angle) + 90.0, Color(0.72, 0.86, 1.0, 0.20), 0.0, 300.0 + float(i) * 6.0, thin_city_style_intensity)

func _add_thin_block(parent: Node3D, name: String, pos: Vector3, size: Vector3, yaw: float, color: Color, collision := true, alpha := -1.0, sway := 0.035, edge_strength := 0.78) -> Node3D:
	var final_alpha := color.a if alpha < 0.0 else alpha
	var box := CSGBox3D.new()
	box.name = name
	box.position = pos
	box.size = size
	box.rotation_degrees.y = yaw
	box.material = _thin_net_material(color, final_alpha, pos.x + pos.z + size.length(), sway, edge_strength)
	parent.add_child(box)
	if collision:
		_add_box_collision(name + "Collision", pos, size, yaw)
	return box

func _add_local_thin_block(asset: Node3D, part_name: String, local_pos: Vector3, size: Vector3, local_yaw: float, color: Color, collision := true, alpha := -1.0, sway := 0.035, edge_strength := 0.78) -> Node3D:
	var global_pos := _asset_global_pos(asset, local_pos)
	var global_yaw := _asset_global_yaw(asset, local_yaw)
	var full_name := "%s_%s" % [asset.name, part_name]
	if _should_keep_clear_for_echo_tower(full_name, global_pos, size):
		return null
	var final_alpha := color.a if alpha < 0.0 else alpha
	var box := CSGBox3D.new()
	box.name = part_name
	box.position = local_pos
	box.size = size
	box.rotation_degrees.y = local_yaw
	box.material = _thin_net_material(color, final_alpha, global_pos.x + global_pos.z + size.length(), sway, edge_strength)
	asset.add_child(box)
	if collision:
		_add_box_collision(full_name + "Collision", global_pos, size, global_yaw)
	return box

func _add_thin_cylinder(parent: Node3D, name: String, pos: Vector3, radius: float, height: float, color: Color, sides := 32, collision := false, alpha := -1.0, sway := 0.035, edge_strength := 0.78) -> Node3D:
	var final_alpha := color.a if alpha < 0.0 else alpha
	var cylinder := CSGCylinder3D.new()
	cylinder.name = name
	cylinder.radius = radius
	cylinder.height = height
	cylinder.sides = sides
	cylinder.position = pos
	cylinder.material = _thin_net_material(color, final_alpha, pos.x + pos.z + radius + height, sway, edge_strength)
	parent.add_child(cylinder)
	if collision:
		_add_box_collision(name + "Collision", pos, Vector3(radius * 2.0, height, radius * 2.0), 0.0)
	return cylinder

func _build_thin_platform(parent: Node3D, name: String, pos: Vector3, size: Vector2, yaw: float, color: Color) -> Node3D:
	var asset := _make_city_asset(parent, name, pos, yaw)
	_add_local_thin_block(asset, "SuspendedDeck", Vector3(0, 0.06, 0), Vector3(size.x, 0.14, size.y), 0.0, color, true, color.a, 0.030, 0.82)
	_add_local_thin_block(asset, "LeftEdgeCable", Vector3(-size.x * 0.5, 0.92, 0), Vector3(0.08, 0.08, size.y), 0.0, Color(0.86, 0.94, 1.0, 0.62), false, 0.62, 0.055, 0.96)
	_add_local_thin_block(asset, "RightEdgeCable", Vector3(size.x * 0.5, 0.92, 0), Vector3(0.08, 0.08, size.y), 0.0, Color(0.86, 0.94, 1.0, 0.62), false, 0.62, 0.055, 0.96)
	_add_local_thin_block(asset, "FrontEdgeCable", Vector3(0, 0.92, -size.y * 0.5), Vector3(size.x, 0.08, 0.08), 0.0, Color(0.86, 0.94, 1.0, 0.56), false, 0.56, 0.055, 0.96)
	_add_local_thin_block(asset, "BackEdgeCable", Vector3(0, 0.92, size.y * 0.5), Vector3(size.x, 0.08, 0.08), 0.0, Color(0.86, 0.94, 1.0, 0.56), false, 0.56, 0.055, 0.96)
	for x in [-0.42, 0.42]:
		for z in [-0.42, 0.42]:
			_add_local_thin_block(asset, "LongDropLine_%s_%s" % [str(x), str(z)], Vector3(size.x * x, -2.6, size.y * z), Vector3(0.09, 5.3, 0.09), 0.0, Color(0.80, 0.90, 0.98, 0.40), false, 0.40, 0.060, 0.84)
	return asset

func _build_thin_bridge_span(parent: Node3D, name: String, a: Vector3, b: Vector3, width: float, color: Color, collision := true) -> Node3D:
	var delta := b - a
	var flat_length := Vector2(delta.x, delta.z).length()
	var yaw := rad_to_deg(atan2(delta.x, delta.z))
	var mid := (a + b) * 0.5
	var asset := _make_city_asset(parent, name, mid, yaw)
	_add_local_thin_block(asset, "FlexibleDeck", Vector3(0, 0.07, 0), Vector3(width, 0.12, flat_length), 0.0, color, collision, color.a, 0.060, 0.86)
	_add_local_thin_block(asset, "LeftTensionCable", Vector3(-width * 0.55, 1.05, 0), Vector3(0.07, 0.07, flat_length), 0.0, Color(0.86, 0.94, 1.0, 0.62), false, 0.62, 0.075, 0.96)
	_add_local_thin_block(asset, "RightTensionCable", Vector3(width * 0.55, 1.05, 0), Vector3(0.07, 0.07, flat_length), 0.0, Color(0.86, 0.94, 1.0, 0.62), false, 0.62, 0.075, 0.96)
	var hanger_count := maxi(2, int(flat_length / 6.0))
	for i in range(hanger_count + 1):
		var z := -flat_length * 0.5 + flat_length * float(i) / float(hanger_count)
		_add_local_thin_block(asset, "LeftHanger_%02d" % i, Vector3(-width * 0.55, 0.50, z), Vector3(0.045, 1.1, 0.045), 0.0, Color(0.84, 0.94, 1.0, 0.46), false, 0.46, 0.080, 0.92)
		_add_local_thin_block(asset, "RightHanger_%02d" % i, Vector3(width * 0.55, 0.50, z), Vector3(0.045, 1.1, 0.045), 0.0, Color(0.84, 0.94, 1.0, 0.46), false, 0.46, 0.080, 0.92)
	return asset

func _build_thin_line_span(parent: Node3D, name: String, a: Vector3, b: Vector3, color: Color, thickness := 0.06) -> Node3D:
	var delta := b - a
	var flat_length := Vector2(delta.x, delta.z).length()
	var yaw := rad_to_deg(atan2(delta.x, delta.z))
	var mid := (a + b) * 0.5
	var size := Vector3(thickness, thickness, maxf(flat_length, 0.1))
	return _add_thin_block(parent, name, mid, size, yaw, color, false, color.a, 0.090, 0.98)

func _build_thin_support_cluster(parent: Node3D, name: String, pos: Vector3, height: float) -> void:
	var asset := _make_city_asset(parent, name, pos, 0.0)
	for i in range(5):
		var angle := TAU * float(i) / 5.0
		var radius := 1.6 + float(i % 2) * 0.9
		_add_local_thin_block(asset, "NeedleSupport_%02d" % i, Vector3(cos(angle) * radius, -height * 0.5, sin(angle) * radius), Vector3(0.10, height, 0.10), 0.0, Color(0.78, 0.88, 0.94, 0.36), false, 0.36, 0.065, 0.86)
		_add_local_thin_block(asset, "NeedleCapLine_%02d" % i, Vector3(cos(angle) * radius * 0.5, 1.8 + float(i % 3) * 0.3, sin(angle) * radius * 0.5), Vector3(0.08, 0.08, radius * 2.0), rad_to_deg(angle), Color(0.82, 0.92, 1.0, 0.34), false, 0.34, 0.080, 0.92)

func _build_thin_scaffold_tower(parent: Node3D, name: String, pos: Vector3, yaw: float, height: float) -> void:
	var asset := _make_city_asset(parent, name, pos, yaw)
	for x in [-1.8, 1.8]:
		for z in [-1.8, 1.8]:
			_add_local_thin_block(asset, "ScaffoldLeg_%s_%s" % [str(x), str(z)], Vector3(x, height * 0.5, z), Vector3(0.12, height, 0.12), 0.0, Color(0.78, 0.88, 0.94, 0.50), false, 0.50, 0.050, 0.90)
	for level in range(4):
		var y := 1.2 + float(level) * height / 4.0
		_add_local_thin_block(asset, "ScaffoldCrossX_%02d" % level, Vector3(0, y, -1.8), Vector3(4.0, 0.10, 0.10), 0.0, Color(0.84, 0.94, 1.0, 0.42), false, 0.42, 0.065, 0.92)
		_add_local_thin_block(asset, "ScaffoldCrossZ_%02d" % level, Vector3(-1.8, y, 0), Vector3(0.10, 0.10, 4.0), 0.0, Color(0.84, 0.94, 1.0, 0.42), false, 0.42, 0.065, 0.92)

func _build_thin_suspended_room(parent: Node3D, name: String, pos: Vector3, yaw: float, size: Vector3) -> void:
	var asset := _make_city_asset(parent, name, pos, yaw)
	_add_local_thin_block(asset, "TransparentRoomShell", Vector3(0, 0, 0), size, 0.0, Color(0.66, 0.82, 0.92, 0.28), false, 0.28, 0.055, 0.96)
	_add_local_thin_block(asset, "RoomFloorLine", Vector3(0, -size.y * 0.5 - 0.05, 0), Vector3(size.x * 1.08, 0.08, size.z * 1.08), 0.0, Color(0.86, 0.94, 1.0, 0.44), false, 0.44, 0.070, 0.95)
	for x in [-0.45, 0.45]:
		for z in [-0.45, 0.45]:
			_add_local_thin_block(asset, "SuspensionCable_%s_%s" % [str(x), str(z)], Vector3(size.x * x, size.y * 0.5 + 2.2, size.z * z), Vector3(0.055, 4.4, 0.055), 0.0, Color(0.84, 0.94, 1.0, 0.52), false, 0.52, 0.085, 0.98)

func _thin_node_color(node_index: int) -> Color:
	return THIN_ASCENT_COLORS[clampi(node_index, 0, THIN_ASCENT_COLORS.size() - 1)]

func _build_thin_ascent_node(parent: Node3D, node_index: int, pos: Vector3, yaw: float) -> void:
	var data: Array = THIN_ASCENT_NODES[node_index]
	var color := _thin_node_color(node_index)
	var asset := _make_city_asset(parent, String(data[0]), pos, yaw)
	_add_local_thin_block(asset, "ReadingNeedle", Vector3(0, 2.1, 0), Vector3(0.28, 4.2, 0.28), 0.0, Color(0.84, 0.94, 1.0, 0.70), true, 0.70, 0.055, 0.98)
	_add_local_thin_block(asset, "ActiveNetFrame", Vector3(0, 4.3, -0.28), Vector3(4.2, 2.0, 0.10), 0.0, color, false, 0.45, 0.075, 1.0)
	var resolved := _add_local_thin_block(asset, "ResolvedTensionFrame", Vector3(0, 4.3, -0.45), Vector3(4.2, 2.0, 0.10), 0.0, Color(0.88, 0.94, 0.98, 0.28), false, 0.28, 0.020, 0.42)
	if resolved != null:
		resolved.visible = false
	_add_thin_node_glow(asset, color, node_index)
	while thin_node_visuals.size() <= node_index:
		thin_node_visuals.append(null)
	thin_node_visuals[node_index] = asset

	var area := Area3D.new()
	area.name = "%sArea" % String(data[0])
	area.position = pos + Vector3(0, 1.2, 0)
	area.collision_layer = 0
	area.collision_mask = 2
	var shape := CollisionShape3D.new()
	var sphere := SphereShape3D.new()
	sphere.radius = 4.4
	shape.shape = sphere
	area.add_child(shape)
	area.body_entered.connect(func(body: Node3D): _on_thin_node_entered(body, node_index))
	area.body_exited.connect(func(body: Node3D): _on_thin_node_exited(body, node_index))
	manifested_city.add_child(area)
	while thin_node_areas.size() <= node_index:
		thin_node_areas.append(null)
	thin_node_areas[node_index] = area

func _add_thin_node_glow(asset: Node3D, color: Color, node_index: int) -> void:
	var halo := CSGCylinder3D.new()
	halo.name = "ThinNodeActiveGlow"
	halo.radius = 3.4
	halo.height = 0.035
	halo.sides = 48
	halo.position = Vector3(0, 0.10, 0)
	halo.material = _emissive_mat(color, 0.28, thin_node_glow_energy)
	asset.add_child(halo)
	var light := OmniLight3D.new()
	light.name = "ThinNodeLight"
	light.position = Vector3(0, 3.8, 0)
	light.light_color = color
	light.light_energy = thin_node_glow_energy
	light.omni_range = 8.5
	asset.add_child(light)
	var particles := GPUParticles3D.new()
	particles.name = "ThinNodeThreadParticles"
	particles.amount = int(maxf(1.0, 78.0 * thin_node_particle_scale))
	particles.lifetime = 2.7
	particles.visibility_aabb = AABB(Vector3(-5, -1, -5), Vector3(10, 8, 10))
	var mesh := QuadMesh.new()
	mesh.size = Vector2(0.18, 0.018)
	particles.draw_pass_1 = mesh
	var process := ParticleProcessMaterial.new()
	process.emission_shape = ParticleProcessMaterial.EMISSION_SHAPE_SPHERE
	process.emission_sphere_radius = 2.8
	process.gravity = Vector3(0.0, -0.04, 0.0)
	process.initial_velocity_min = 0.04
	process.initial_velocity_max = 0.24
	process.spread = 100.0
	process.color = Color(color.r, color.g, color.b, 0.70)
	particles.process_material = process
	particles.position = Vector3(0, 2.8, 0)
	particles.emitting = true
	asset.add_child(particles)

func _set_thin_node_visual_state(node_index: int, resolved: bool) -> void:
	if node_index < 0 or node_index >= thin_node_visuals.size():
		return
	var asset := thin_node_visuals[node_index]
	if asset == null:
		return
	var active := asset.get_node_or_null("ActiveNetFrame")
	if active != null:
		active.visible = not resolved
	var resolved_frame := asset.get_node_or_null("ResolvedTensionFrame")
	if resolved_frame != null:
		resolved_frame.visible = resolved
	for name in ["ThinNodeActiveGlow", "ThinNodeLight", "ThinNodeThreadParticles"]:
		var child := asset.get_node_or_null(name)
		if child != null:
			child.visible = not resolved

func _build_trade_city_whitebox(parent: Node3D) -> void:
	_build_trade_city_terrain(parent)
	_build_trade_memory_market(parent)
	_build_trade_glance_avenue(parent)
	_build_trade_migration_city(parent)
	_build_trade_string_ruin(parent)
	_build_trade_water_route_city(parent)
	_build_trade_center_core(parent)
	_build_trade_atmosphere(parent)

func _build_trade_city_terrain(parent: Node3D) -> void:
	var terrain := _make_city_zone(parent, "TradeCity_EstuaryWetMarketTerrain")
	_add_trade_block(terrain, "WetEstuaryGround", Vector3(0, -0.06, 0), Vector3(238, 0.12, 238), 0.0, Color(0.45, 0.39, 0.29), true, 0.62, 0.06, 0.36)
	_add_trade_block(terrain, "RiverMouthWater_East", Vector3(76, 0.015, 18), Vector3(50, 0.05, 146), -4.0, Color(0.10, 0.42, 0.36, 0.74), false, 0.88, 0.16, 0.42)
	_add_trade_block(terrain, "CanalGreenWater_South", Vector3(24, 0.03, 63), Vector3(84, 0.05, 9), 0.0, Color(0.12, 0.50, 0.40, 0.70), false, 0.86, 0.14, 0.38)
	_add_trade_block(terrain, "HighPlateauShelf_West", Vector3(-62, 0.14, 0), Vector3(48, 0.22, 68), 0.0, Color(0.56, 0.47, 0.32), true, 0.28, 0.02, 0.30)
	_add_trade_block(terrain, "NorthernPlainRuinFloor", Vector3(0, 0.02, -65), Vector3(82, 0.08, 50), 0.0, Color(0.36, 0.35, 0.32), true, 0.36, 0.02, 0.52)
	_build_trade_route_span(terrain, "MarketToCoreWetStreet", Vector3(0, 0, 72), Vector3(0, 0, 0), 9.5, Color(0.58, 0.46, 0.30))
	_build_trade_route_span(terrain, "CoreToGlanceAvenueWetStreet", Vector3(0, 0, 0), Vector3(54, 0, 4), 9.0, Color(0.42, 0.36, 0.31))
	_build_trade_route_span(terrain, "CoreToMigratingCityRoad", Vector3(0, 0, 0), Vector3(-56, 0, 0), 8.2, Color(0.50, 0.43, 0.30))
	_build_trade_route_span(terrain, "CoreToStringRuinCauseway", Vector3(0, 0, 0), Vector3(0, 0, -64), 7.6, Color(0.42, 0.40, 0.36))
	_build_trade_route_span(terrain, "CoreToWaterStreetRoad", Vector3(0, 0, 0), Vector3(42, 0, 50), 8.6, Color(0.34, 0.42, 0.38))

func _build_trade_memory_market(parent: Node3D) -> void:
	var zone := _make_city_zone(parent, "ZoneA_EuphemiaMemoryMarket")
	_build_trade_seasonal_plaza(zone, Vector3(0, 0, 72), 0.0)
	_build_trade_seven_nations_bazaar(zone, Vector3(0, 0, 72), 0.0)
	_build_trade_river_dock(zone, Vector3(34, 0, 76), 90.0)
	_build_trade_caravan_gate(zone, Vector3(-36, 0, 74), -90.0)
	_build_trade_campfire_yard(zone, Vector3(0, 0, 72), 0.0)
	var goods := [
		["GingerCrate", Vector3(-15, 0, 60), Color(0.78, 0.46, 0.20)],
		["CottonBale", Vector3(22, 0, 78), Color(0.86, 0.82, 0.68)],
		["PistachioSack", Vector3(-8, 0, 58), Color(0.46, 0.62, 0.24)],
		["PoppySeedJar", Vector3(9, 0, 58), Color(0.22, 0.18, 0.16)],
		["NutmegBox", Vector3(-31, 0, 69), Color(0.54, 0.30, 0.14)],
		["RaisinSack", Vector3(13, 0, 84), Color(0.36, 0.20, 0.16)],
		["GoldenGauze", Vector3(-24, 0, 82), Color(1.0, 0.72, 0.22, 0.52)]
	]
	for item in goods:
		_build_trade_simple_prop(zone, String(item[0]), item[1], 0.0, Vector3(2.4, 1.1, 1.8), item[2], true)
	_build_trade_simple_prop(zone, "YellowMat", Vector3(0, 0.10, 59), 0.0, Vector3(24, 0.05, 8), Color(0.82, 0.62, 0.22), false)
	_build_trade_simple_prop(zone, "FlyClothCanopy", Vector3(0, 4.2, 64), 0.0, Vector3(32, 0.12, 12), Color(0.84, 0.78, 0.56, 0.42), false)
	_build_trade_simple_prop(zone, "MemorySack", Vector3(-5, 0, 74), 0.0, Vector3(1.4, 1.0, 1.2), Color(0.48, 0.34, 0.20), true)
	_build_trade_simple_prop(zone, "MemoryBarrel", Vector3(6, 0, 73), 0.0, Vector3(1.3, 1.5, 1.3), Color(0.36, 0.24, 0.14), true)
	_build_trade_simple_prop(zone, "WolfToken", Vector3(-2, 0.65, 68), 0.0, Vector3(1.0, 0.22, 1.0), Color(0.18, 0.18, 0.16), false)
	_build_trade_simple_prop(zone, "HiddenTreasureChest", Vector3(8, 0, 66), 0.0, Vector3(2.4, 1.1, 1.5), Color(0.42, 0.24, 0.10), true)
	_build_trade_exchange_node(zone, 0, Vector3(0, 0, 70), 0.0)

func _build_trade_glance_avenue(parent: Node3D) -> void:
	var zone := _make_city_zone(parent, "ZoneB_ChloeGlanceAvenue")
	_build_trade_route_span(zone, "GlanceAvenue", Vector3(54, 0, -38), Vector3(54, 0, 44), 12.0, Color(0.38, 0.33, 0.32))
	for z in [-30, -16, -2, 12, 26, 40]:
		_build_trade_rain_arcade(zone, Vector3(44, 0, float(z)), 0.0, "Left")
		_build_trade_rain_arcade(zone, Vector3(64, 0, float(z)), 180.0, "Right")
	_build_trade_umbrella_market(zone, Vector3(70, 0, -12), -8.0)
	_build_trade_band_plaza(zone, Vector3(54, 0, 20), 0.0)
	_build_trade_carousel_hall(zone, Vector3(54, 0, 4), 0.0)
	var figures := [
		["ParasolGirlFigure", Vector3(47, 0, -31), Color(0.95, 0.74, 0.42)],
		["BlackVeilWoman", Vector3(61, 0, -22), Color(0.06, 0.05, 0.05)],
		["TattooedGiant", Vector3(45, 0, -6), Color(0.58, 0.42, 0.34)],
		["CoralTwins", Vector3(63, 0, 10), Color(0.92, 0.28, 0.24)],
		["BlindLeopardKeeper", Vector3(48, 0, 29), Color(0.28, 0.24, 0.18)],
		["OstrichFan", Vector3(64, 0, 31), Color(0.92, 0.86, 0.72)]
	]
	for item in figures:
		_build_trade_figure(zone, String(item[0]), item[1], item[2])
	for i in range(figures.size() - 1):
		_build_trade_line_span(zone, "GlanceLineParticle_%02d" % i, figures[i][1] + Vector3(0, 2.1, 0), figures[i + 1][1] + Vector3(0, 2.1, 0), Color(0.95, 0.42, 0.78, 0.50), 0.05)
	_build_trade_ground_mark(zone, "TriangleGazeMark", Vector3(54, 0.18, -10), Vector2(8, 0.08), Color(0.95, 0.38, 0.74, 0.48))
	_build_trade_ground_mark(zone, "StarGazeMark", Vector3(54, 0.18, 24), Vector2(11, 0.08), Color(0.16, 0.82, 0.72, 0.44))
	_build_trade_exchange_node(zone, 1, Vector3(54, 0, 4), 0.0)

func _build_trade_migration_city(parent: Node3D) -> void:
	var zone := _make_city_zone(parent, "ZoneC_EutropiaMigratingCities")
	_build_trade_empty_plateau_city(zone, Vector3(-70, 0, -18), -6.0)
	_build_trade_migrating_main_city(zone, Vector3(-48, 0, 12), 5.0)
	_build_trade_empty_city_grid(zone, Vector3(-56, 0, -2), 0.0)
	_build_trade_new_vocation_street(zone, Vector3(-52, 0, 25), 0.0)
	_build_trade_mercury_temple(zone, Vector3(-52, 0, 0), 0.0)
	for i in range(4):
		_build_trade_simple_prop(zone, "MigrationCart_%02d" % i, Vector3(-75 + float(i) * 9.0, 0, 19 + float(i % 2) * 7.0), float(i) * 8.0, Vector3(3.4, 1.5, 2.2), Color(0.36, 0.25, 0.15), true)
		_build_trade_simple_prop(zone, "NewJobSign_%02d" % i, Vector3(-61 + float(i) * 5.5, 0, 31), 0.0, Vector3(1.6, 2.4, 0.18), Color(0.88, 0.70, 0.34), false)
		_build_trade_simple_prop(zone, "NewViewFrame_%02d" % i, Vector3(-75 + float(i) * 7.0, 2.6, -12), 0.0, Vector3(2.4, 2.0, 0.16), Color(0.36, 0.62, 0.70, 0.40), false)
	_build_trade_simple_prop(zone, "MercuryIdol", Vector3(-52, 1.1, 0), 0.0, Vector3(1.5, 2.2, 1.0), Color(0.86, 0.72, 0.30), false)
	_build_trade_exchange_node(zone, 2, Vector3(-52, 0, 0), 0.0)

func _build_trade_string_ruin(parent: Node3D) -> void:
	var zone := _make_city_zone(parent, "ZoneD_ErsiliaStringWebRuin")
	_build_trade_string_web_ruin(zone, Vector3(0, 0, -64), 0.0)
	_build_trade_stake_plaza(zone, Vector3(0, 0, -64), 0.0)
	_build_trade_relation_support_frame(zone, Vector3(12, 0, -74), 10.0)
	_build_trade_hillside_refuge_camp(zone, Vector3(-34, 0, -72), -12.0)
	_build_trade_second_ersilia(zone, Vector3(36, 0, -88), 8.0)
	for i in range(11):
		var a := Vector3(-24.0 + float(i % 4) * 15.0, 2.4 + float(i % 3) * 0.4, -78.0 + float(i / 4) * 11.0)
		var b := Vector3(-18.0 + float((i + 2) % 5) * 13.0, 2.9, -52.0 + float(i % 3) * 8.0)
		var color := Color(0.05, 0.05, 0.045, 0.62) if i % 4 == 0 else (Color(0.86, 0.84, 0.78, 0.48) if i % 4 == 1 else Color(0.46, 0.46, 0.42, 0.55))
		_build_trade_line_span(zone, "RelationString_%02d" % i, a, b, color, 0.07)
	_build_trade_exchange_node(zone, 3, Vector3(0, 0, -64), 0.0)

func _build_trade_water_route_city(parent: Node3D) -> void:
	var zone := _make_city_zone(parent, "ZoneE_SmeraldinaWaterStreetCity")
	_build_trade_water_street_city(zone, Vector3(42, 0, 50), 0.0)
	_build_trade_canal_district(zone, Vector3(42, 0, 50), 0.0)
	_build_trade_zigzag_bridge_road(zone, Vector3(42, 0, 50), 0.0)
	_build_trade_boat_alley(zone, Vector3(62, 0, 52), 0.0)
	_build_trade_simple_prop(zone, "SmallBoat", Vector3(62, 0.22, 52), 8.0, Vector3(5.5, 0.8, 1.5), Color(0.30, 0.18, 0.10), false)
	_build_trade_simple_prop(zone, "StoneBridge", Vector3(41, 0.65, 42), 20.0, Vector3(12, 1.0, 2.2), Color(0.58, 0.56, 0.50), true)
	_build_trade_simple_prop(zone, "WaterFork", Vector3(52, 0.18, 60), 0.0, Vector3(8, 0.08, 8), Color(0.08, 0.44, 0.38, 0.74), false)
	_build_trade_simple_prop(zone, "StreetFork", Vector3(32, 0.18, 42), 0.0, Vector3(8, 0.08, 8), Color(0.50, 0.42, 0.30), false)
	_build_trade_simple_prop(zone, "SecretRatPath", Vector3(38, -0.35, 66), 0.0, Vector3(18, 0.45, 2.2), Color(0.08, 0.07, 0.055), false)
	_build_trade_line_span(zone, "SwallowRoute", Vector3(26, 8.0, 39), Vector3(70, 9.2, 66), Color(0.70, 0.90, 1.0, 0.50), 0.055)
	_build_trade_exchange_node(zone, 4, Vector3(42, 0, 50), 0.0)

func _build_trade_center_core(parent: Node3D) -> void:
	var zone := _make_city_zone(parent, "ZoneF_CentralTradeCore")
	_build_trade_multi_route_plaza(zone, Vector3(0, 0, 0), 0.0)
	_build_trade_river_dock(zone, Vector3(18, 0, 0), 90.0)
	_build_trade_simple_prop(zone, "MemoryTradeParticleCluster", Vector3(0, 1.2, 0), 0.0, Vector3(2.4, 2.4, 2.4), Color(1.0, 0.62, 0.20, 0.28), false)
	for i in range(10):
		var angle := TAU * float(i) / 10.0
		_build_trade_line_span(zone, "ExchangeRouteLine_%02d" % i, Vector3(0, 0.55, 0), Vector3(cos(angle) * 18.0, 0.55, sin(angle) * 18.0), Color(0.18, 0.76, 0.62, 0.34), 0.045)
	trade_goal_trigger = Area3D.new()
	trade_goal_trigger.name = "TradeGoalTrigger"
	trade_goal_trigger.position = Vector3(0, 0.9, 0)
	trade_goal_trigger.collision_layer = 0
	trade_goal_trigger.collision_mask = 2
	var shape := CollisionShape3D.new()
	var sphere := SphereShape3D.new()
	sphere.radius = 9.0
	shape.shape = sphere
	trade_goal_trigger.add_child(shape)
	trade_goal_trigger.body_entered.connect(_on_trade_goal_entered)
	trade_goal_trigger.body_exited.connect(_on_trade_goal_exited)
	manifested_city.add_child(trade_goal_trigger)

func _build_trade_atmosphere(parent: Node3D) -> void:
	var atmosphere := Node3D.new()
	atmosphere.name = "TradeCityAtmosphere_StyleDirection"
	parent.add_child(atmosphere)
	atmosphere.add_child(_make_city_particle_layer("WaterVaporParticles", 1320, Vector2(0.12, 0.040), Vector3(116, 5.5, 116), Vector3(0.16, 0.04, -0.10), Color(0.54, 0.76, 0.72, 0.28), 0.04, 0.26, 100.0, 14.0))
	atmosphere.add_child(_make_city_particle_layer("MarketClothStripParticles", 520, Vector2(0.22, 0.055), Vector3(112, 7.0, 112), Vector3(0.22, 0.06, 0.05), Color(0.96, 0.62, 0.22, 0.30), 0.05, 0.30, 100.0, 12.0))
	atmosphere.add_child(_make_city_particle_layer("TradeTicketParticles", 760, Vector2(0.14, 0.075), Vector3(110, 6.5, 110), Vector3(-0.10, 0.09, 0.18), Color(0.86, 0.78, 0.56, 0.34), 0.05, 0.32, 100.0, 13.0))
	atmosphere.add_child(_make_city_particle_layer("CopperCoinGlimmerParticles", 920, Vector2(0.040, 0.040), Vector3(106, 5.8, 106), Vector3(0.06, 0.08, 0.04), Color(1.0, 0.56, 0.16, 0.40), 0.03, 0.22, 100.0, 10.0))
	atmosphere.add_child(_make_city_particle_layer("MemoryTradeParticle", 980, Vector2(0.036, 0.036), Vector3(104, 6.8, 104), Vector3(0.03, 0.12, -0.05), Color(1.0, 0.68, 0.28, 0.34), 0.03, 0.22, 100.0, 12.0))
	for i in range(9):
		var angle := TAU * float(i) / 9.0
		_add_city_style_veil(atmosphere, "TradeCrowdFlowVeil_%02d" % i, Vector3(cos(angle) * 46.0, 4.8 + float(i % 3) * 0.8, sin(angle) * 46.0), Vector2(70.0, 12.0 + float(i % 2) * 4.0), rad_to_deg(angle) + 90.0, Color(1.0, 0.52, 0.18, 0.20), 1.0, 360.0 + float(i) * 5.0, trade_city_style_intensity)
		_add_city_style_veil(atmosphere, "CanalReflectionVeil_%02d" % i, Vector3(52.0 + float(i % 3) * 8.0, 2.2, -42.0 + float(i) * 13.0), Vector2(36.0, 6.0), 4.0 + float(i) * 7.0, Color(0.08, 0.70, 0.62, 0.18), 1.0, 420.0 + float(i) * 4.0, trade_city_style_intensity * 0.85)

func _add_trade_block(parent: Node3D, name: String, pos: Vector3, size: Vector3, yaw: float, color: Color, collision := true, wetness := 0.55, neon := 0.08, material_mix := 0.35) -> Node3D:
	var box := CSGBox3D.new()
	box.name = name
	box.position = pos
	box.size = size
	box.rotation_degrees.y = yaw
	box.material = _trade_wet_material(color, color.a, pos.x + pos.z + size.length(), wetness, neon, material_mix)
	parent.add_child(box)
	if collision:
		_add_box_collision(name + "Collision", pos, size, yaw)
	return box

func _add_local_trade_block(asset: Node3D, part_name: String, local_pos: Vector3, size: Vector3, local_yaw: float, color: Color, collision := true, wetness := 0.55, neon := 0.08, material_mix := 0.35) -> Node3D:
	var global_pos := _asset_global_pos(asset, local_pos)
	var global_yaw := _asset_global_yaw(asset, local_yaw)
	var full_name := "%s_%s" % [asset.name, part_name]
	var box := CSGBox3D.new()
	box.name = part_name
	box.position = local_pos
	box.size = size
	box.rotation_degrees.y = local_yaw
	box.material = _trade_wet_material(color, color.a, global_pos.x + global_pos.z + size.length(), wetness, neon, material_mix)
	asset.add_child(box)
	if collision:
		_add_box_collision(full_name + "Collision", global_pos, size, global_yaw)
	return box

func _add_local_trade_cylinder(asset: Node3D, part_name: String, local_pos: Vector3, radius: float, height: float, color: Color, sides := 32, collision := false, wetness := 0.45, neon := 0.05, material_mix := 0.30) -> Node3D:
	var global_pos := _asset_global_pos(asset, local_pos)
	var cylinder := CSGCylinder3D.new()
	cylinder.name = part_name
	cylinder.radius = radius
	cylinder.height = height
	cylinder.sides = sides
	cylinder.position = local_pos
	cylinder.material = _trade_wet_material(color, color.a, global_pos.x + global_pos.z + radius + height, wetness, neon, material_mix)
	asset.add_child(cylinder)
	if collision:
		_add_box_collision("%s_%sCollision" % [asset.name, part_name], global_pos, Vector3(radius * 2.0, height, radius * 2.0), asset.rotation_degrees.y)
	return cylinder

func _build_trade_route_span(parent: Node3D, name: String, a: Vector3, b: Vector3, width: float, color: Color, collision := true) -> void:
	var delta := b - a
	var flat_length := Vector2(delta.x, delta.z).length()
	var yaw := rad_to_deg(atan2(delta.x, delta.z))
	var mid := (a + b) * 0.5
	_add_trade_block(parent, name, mid + Vector3(0, 0.04, 0), Vector3(width, 0.08, flat_length), yaw, color, collision, 0.72, 0.05, 0.46)

func _build_trade_line_span(parent: Node3D, name: String, a: Vector3, b: Vector3, color: Color, thickness := 0.06) -> void:
	var delta := b - a
	var flat_length := Vector2(delta.x, delta.z).length()
	var yaw := rad_to_deg(atan2(delta.x, delta.z))
	var mid := (a + b) * 0.5
	_add_trade_block(parent, name, mid, Vector3(thickness, thickness, maxf(flat_length, 0.1)), yaw, color, false, 0.34, 0.24, 0.50)

func _build_trade_simple_prop(parent: Node3D, name: String, pos: Vector3, yaw: float, size: Vector3, color: Color, collision := false) -> Node3D:
	var asset := _make_city_asset(parent, name, pos, yaw)
	_add_local_trade_block(asset, "WhiteboxReplaceRoot", Vector3(0, size.y * 0.5, 0), size, 0.0, color, collision, 0.40, 0.05, 0.36)
	return asset

func _build_trade_seasonal_plaza(parent: Node3D, pos: Vector3, yaw: float) -> void:
	var asset := _make_city_asset(parent, "SeasonalTradePlaza", pos, yaw)
	_add_local_trade_cylinder(asset, "RoundMarketDisk", Vector3(0, 0.08, 0), 17.0, 0.14, Color(0.66, 0.50, 0.25), 64, true, 0.76, 0.05, 0.40)
	for i in range(4):
		var angle := TAU * float(i) / 4.0
		_add_local_trade_block(asset, "SeasonMarker_%02d" % i, Vector3(cos(angle) * 13.5, 0.34, sin(angle) * 13.5), Vector3(2.6, 0.35, 1.2), rad_to_deg(angle), Color(0.90, 0.68, 0.28), false, 0.50, 0.04, 0.34)

func _build_trade_seven_nations_bazaar(parent: Node3D, pos: Vector3, yaw: float) -> void:
	var asset := _make_city_asset(parent, "SevenNationsBazaar", pos, yaw)
	for i in range(7):
		var angle := TAU * float(i) / 7.0
		var stall_pos := Vector3(cos(angle) * 22.0, 0, sin(angle) * 17.0)
		_add_local_trade_block(asset, "BazaarStall_%02d" % i, stall_pos + Vector3(0, 1.0, 0), Vector3(5.0, 2.0, 3.4), rad_to_deg(-angle), Color(0.62, 0.42, 0.22), true, 0.52, 0.05, 0.45)
		_add_local_trade_block(asset, "ClothAwning_%02d" % i, stall_pos + Vector3(0, 2.45, 0), Vector3(5.8, 0.18, 4.0), rad_to_deg(-angle), Color(0.92, 0.62, 0.24, 0.64), false, 0.42, 0.12, 0.52)

func _build_trade_river_dock(parent: Node3D, pos: Vector3, yaw: float) -> void:
	var asset := _make_city_asset(parent, "RiverDock", pos, yaw)
	_add_local_trade_block(asset, "DockDeck", Vector3(0, 0.38, 0), Vector3(20, 0.55, 6.0), 0.0, Color(0.30, 0.20, 0.12), true, 0.82, 0.04, 0.52)
	for i in range(5):
		_add_local_trade_block(asset, "DockPost_%02d" % i, Vector3(-8.0 + float(i) * 4.0, 1.2, -2.8), Vector3(0.32, 2.4, 0.32), 0.0, Color(0.22, 0.14, 0.08), false, 0.75, 0.04, 0.44)

func _build_trade_caravan_gate(parent: Node3D, pos: Vector3, yaw: float) -> void:
	var asset := _make_city_asset(parent, "CaravanGate", pos, yaw)
	_add_local_trade_block(asset, "LeftTower", Vector3(-4.2, 3.0, 0), Vector3(2.6, 6.0, 3.2), 0.0, Color(0.58, 0.42, 0.24), true, 0.36, 0.04, 0.38)
	_add_local_trade_block(asset, "RightTower", Vector3(4.2, 3.0, 0), Vector3(2.6, 6.0, 3.2), 0.0, Color(0.58, 0.42, 0.24), true, 0.36, 0.04, 0.38)
	_add_local_trade_block(asset, "GateLintel", Vector3(0, 5.8, 0), Vector3(9.8, 1.0, 3.0), 0.0, Color(0.74, 0.56, 0.28), false, 0.32, 0.05, 0.36)

func _build_trade_campfire_yard(parent: Node3D, pos: Vector3, yaw: float) -> void:
	var asset := _make_city_asset(parent, "CampfireStoryYard", pos, yaw)
	_add_local_trade_cylinder(asset, "CampfireRing", Vector3(0, 0.18, 0), 5.4, 0.12, Color(0.30, 0.23, 0.16), 32, false, 0.32, 0.02, 0.26)
	_add_local_trade_block(asset, "Campfire", Vector3(0, 0.55, 0), Vector3(2.2, 1.1, 2.2), 0.0, Color(1.0, 0.36, 0.08, 0.68), false, 0.22, 0.24, 0.30)
	for i in range(8):
		var angle := TAU * float(i) / 8.0
		_add_local_trade_block(asset, "StorySeat_%02d" % i, Vector3(cos(angle) * 7.6, 0.40, sin(angle) * 7.6), Vector3(2.0, 0.65, 1.2), rad_to_deg(angle), Color(0.36, 0.24, 0.14), true, 0.45, 0.04, 0.40)

func _build_trade_rain_arcade(parent: Node3D, pos: Vector3, yaw: float, side: String) -> void:
	var asset := _make_city_asset(parent, "RainArcade_%s_%s" % [side, str(int(pos.z))], pos, yaw)
	for i in range(4):
		_add_local_trade_block(asset, "ArcadePillar_%02d" % i, Vector3(-5.4 + float(i) * 3.6, 2.0, 0), Vector3(0.42, 4.0, 0.42), 0.0, Color(0.44, 0.38, 0.34), true, 0.84, 0.08, 0.48)
	_add_local_trade_block(asset, "RainRoof", Vector3(0, 4.25, 0), Vector3(13.2, 0.55, 3.0), 0.0, Color(0.30, 0.30, 0.32), false, 0.88, 0.08, 0.52)

func _build_trade_umbrella_market(parent: Node3D, pos: Vector3, yaw: float) -> void:
	var asset := _make_city_asset(parent, "UmbrellaMarket", pos, yaw)
	for i in range(9):
		var local := Vector3(-8.0 + float(i % 3) * 8.0, 2.5, -6.0 + float(i / 3) * 6.0)
		_add_local_trade_cylinder(asset, "UmbrellaCanopy_%02d" % i, local, 2.4, 0.18, Color(0.84, 0.32 + float(i % 3) * 0.12, 0.28), 24, false, 0.34, 0.16, 0.58)
		_add_local_trade_block(asset, "UmbrellaPole_%02d" % i, local + Vector3(0, -1.15, 0), Vector3(0.16, 2.3, 0.16), 0.0, Color(0.28, 0.20, 0.12), false, 0.56, 0.04, 0.30)

func _build_trade_band_plaza(parent: Node3D, pos: Vector3, yaw: float) -> void:
	var asset := _make_city_asset(parent, "BandPlaza", pos, yaw)
	_add_local_trade_cylinder(asset, "BandstandDisk", Vector3(0, 0.25, 0), 7.2, 0.35, Color(0.56, 0.42, 0.24), 40, true, 0.60, 0.12, 0.40)
	for i in range(5):
		_add_local_trade_block(asset, "MusicStand_%02d" % i, Vector3(-4.0 + float(i) * 2.0, 1.1, -1.5), Vector3(0.7, 1.3, 0.12), 0.0, Color(0.12, 0.10, 0.08), false, 0.44, 0.06, 0.28)

func _build_trade_carousel_hall(parent: Node3D, pos: Vector3, yaw: float) -> void:
	var asset := _make_city_asset(parent, "DesireCarouselHall", pos, yaw)
	_add_local_trade_cylinder(asset, "CarouselFloor", Vector3(0, 0.20, 0), 8.0, 0.26, Color(0.54, 0.28, 0.32), 48, true, 0.66, 0.20, 0.46)
	_add_local_trade_cylinder(asset, "CarouselCanopy", Vector3(0, 4.2, 0), 8.5, 0.22, Color(0.92, 0.38, 0.24, 0.70), 48, false, 0.44, 0.22, 0.56)
	for i in range(8):
		var angle := TAU * float(i) / 8.0
		_add_local_trade_block(asset, "CarouselGhost_%02d" % i, Vector3(cos(angle) * 5.2, 1.45, sin(angle) * 5.2), Vector3(0.6, 2.0, 0.35), rad_to_deg(-angle), Color(0.92, 0.72, 0.62, 0.30), false, 0.34, 0.18, 0.50)

func _build_trade_figure(parent: Node3D, name: String, pos: Vector3, color: Color) -> void:
	var asset := _make_city_asset(parent, name, pos, 0.0)
	_add_local_trade_block(asset, "FigureBody", Vector3(0, 1.1, 0), Vector3(0.75, 2.2, 0.50), 0.0, color, false, 0.38, 0.08, 0.42)
	_add_local_trade_block(asset, "FigureHead", Vector3(0, 2.55, 0), Vector3(0.65, 0.65, 0.65), 0.0, color.lerp(Color(0.90, 0.74, 0.58), 0.45), false, 0.34, 0.06, 0.38)

func _build_trade_ground_mark(parent: Node3D, name: String, pos: Vector3, size: Vector2, color: Color) -> void:
	var asset := _make_city_asset(parent, name, pos, 0.0)
	for i in range(3):
		_add_local_trade_block(asset, "GazeStroke_%02d" % i, Vector3(0, 0, 0), Vector3(size.x, size.y, 0.08), float(i) * 60.0, color, false, 0.42, 0.30, 0.60)

func _build_trade_empty_plateau_city(parent: Node3D, pos: Vector3, yaw: float) -> void:
	var asset := _make_city_asset(parent, "EmptyPlateauCity", pos, yaw)
	for i in range(8):
		_add_local_trade_block(asset, "EmptyHouse_%02d" % i, Vector3(-12.0 + float(i % 4) * 8.0, 2.0, -6.0 + float(i / 4) * 12.0), Vector3(5.0, 4.0, 4.4), 0.0, Color(0.58, 0.52, 0.42, 0.60), true, 0.32, 0.03, 0.44)

func _build_trade_migrating_main_city(parent: Node3D, pos: Vector3, yaw: float) -> void:
	var asset := _make_city_asset(parent, "MigratingMainCity", pos, yaw)
	for i in range(6):
		_add_local_trade_block(asset, "OccupiedBlock_%02d" % i, Vector3(-10.0 + float(i % 3) * 10.0, 2.4, -6.0 + float(i / 3) * 10.0), Vector3(6.2, 4.8, 5.0), 0.0, Color(0.64, 0.48, 0.28), true, 0.42, 0.08, 0.46)

func _build_trade_empty_city_grid(parent: Node3D, pos: Vector3, yaw: float) -> void:
	var asset := _make_city_asset(parent, "EmptyCityGrid", pos, yaw)
	for i in range(5):
		_add_local_trade_block(asset, "GridStreetX_%02d" % i, Vector3(0, 0.10, -18.0 + float(i) * 9.0), Vector3(38, 0.08, 0.55), 0.0, Color(0.32, 0.30, 0.26), false, 0.30, 0.02, 0.34)
		_add_local_trade_block(asset, "GridStreetZ_%02d" % i, Vector3(-18.0 + float(i) * 9.0, 0.11, 0), Vector3(0.55, 0.08, 38), 0.0, Color(0.32, 0.30, 0.26), false, 0.30, 0.02, 0.34)

func _build_trade_new_vocation_street(parent: Node3D, pos: Vector3, yaw: float) -> void:
	var asset := _make_city_asset(parent, "NewVocationStreet", pos, yaw)
	_add_local_trade_block(asset, "StreetDeck", Vector3(0, 0.06, 0), Vector3(32, 0.10, 7.0), 0.0, Color(0.48, 0.38, 0.24), true, 0.44, 0.06, 0.42)
	for i in range(6):
		_add_local_trade_block(asset, "VocationBooth_%02d" % i, Vector3(-13.0 + float(i) * 5.2, 1.2, 3.8), Vector3(3.0, 2.4, 2.0), 0.0, Color(0.62, 0.42, 0.24), true, 0.38, 0.05, 0.44)

func _build_trade_mercury_temple(parent: Node3D, pos: Vector3, yaw: float) -> void:
	var asset := _make_city_asset(parent, "MercuryTemple", pos, yaw)
	_add_local_trade_block(asset, "TempleBase", Vector3(0, 0.8, 0), Vector3(13, 1.6, 10), 0.0, Color(0.58, 0.48, 0.30), true, 0.36, 0.06, 0.42)
	_add_local_trade_block(asset, "TempleBody", Vector3(0, 3.8, 0), Vector3(10, 6.0, 7.5), 0.0, Color(0.70, 0.58, 0.34), true, 0.34, 0.08, 0.44)
	_add_local_trade_block(asset, "MercuryWingSign", Vector3(0, 7.1, -3.9), Vector3(7.5, 1.0, 0.16), 0.0, Color(0.96, 0.72, 0.24, 0.70), false, 0.32, 0.18, 0.52)

func _build_trade_string_web_ruin(parent: Node3D, pos: Vector3, yaw: float) -> void:
	var asset := _make_city_asset(parent, "StringWebRuin", pos, yaw)
	for i in range(9):
		var p := Vector3(-24.0 + float(i % 3) * 24.0, 1.6, -14.0 + float(i / 3) * 14.0)
		_add_local_trade_block(asset, "RuinCornerStake_%02d" % i, p, Vector3(0.32, 3.2, 0.32), 0.0, Color(0.22, 0.18, 0.14), true, 0.34, 0.02, 0.32)

func _build_trade_stake_plaza(parent: Node3D, pos: Vector3, yaw: float) -> void:
	var asset := _make_city_asset(parent, "StakePlaza", pos, yaw)
	_add_local_trade_cylinder(asset, "StakePlazaDisk", Vector3(0, 0.08, 0), 12.5, 0.12, Color(0.36, 0.34, 0.30), 48, true, 0.44, 0.04, 0.38)

func _build_trade_relation_support_frame(parent: Node3D, pos: Vector3, yaw: float) -> void:
	var asset := _make_city_asset(parent, "RelationSupportFrame", pos, yaw)
	for i in range(4):
		_add_local_trade_block(asset, "SupportPost_%02d" % i, Vector3(-6.0 + float(i) * 4.0, 2.6, 0), Vector3(0.32, 5.2, 0.32), 0.0, Color(0.20, 0.17, 0.13), true, 0.32, 0.02, 0.30)
	_add_local_trade_block(asset, "SupportTopLine", Vector3(0, 5.2, 0), Vector3(15, 0.22, 0.22), 0.0, Color(0.72, 0.70, 0.64), false, 0.24, 0.04, 0.34)

func _build_trade_hillside_refuge_camp(parent: Node3D, pos: Vector3, yaw: float) -> void:
	var asset := _make_city_asset(parent, "HillsideRefugeCamp", pos, yaw)
	for i in range(5):
		_add_local_trade_block(asset, "RefugeTent_%02d" % i, Vector3(-10.0 + float(i) * 5.0, 1.1, float(i % 2) * 5.0), Vector3(3.8, 2.2, 3.0), 0.0, Color(0.50, 0.42, 0.32), true, 0.34, 0.03, 0.42)
		_build_trade_simple_prop(asset, "RefugeeBelongings_%02d" % i, Vector3(-10.0 + float(i) * 5.0, 0, 4.0 + float(i % 2) * 3.0), 0.0, Vector3(1.8, 0.8, 1.4), Color(0.30, 0.22, 0.16), false)

func _build_trade_second_ersilia(parent: Node3D, pos: Vector3, yaw: float) -> void:
	var asset := _make_city_asset(parent, "SecondErsilia", pos, yaw)
	for i in range(6):
		_add_local_trade_block(asset, "SecondCityFrame_%02d" % i, Vector3(-9.0 + float(i % 3) * 9.0, 2.4, float(i / 3) * 9.0), Vector3(4.4, 4.8, 0.24), float(i) * 12.0, Color(0.56, 0.54, 0.48, 0.34), false, 0.24, 0.04, 0.42)

func _build_trade_water_street_city(parent: Node3D, pos: Vector3, yaw: float) -> void:
	var asset := _make_city_asset(parent, "WaterStreetCity", pos, yaw)
	_add_local_trade_block(asset, "WaterStreetBase", Vector3(0, 0.06, 0), Vector3(36, 0.10, 28), 0.0, Color(0.35, 0.43, 0.35), true, 0.78, 0.08, 0.45)

func _build_trade_canal_district(parent: Node3D, pos: Vector3, yaw: float) -> void:
	var asset := _make_city_asset(parent, "CanalDistrict", pos, yaw)
	for i in range(4):
		_add_local_trade_block(asset, "Canal_%02d" % i, Vector3(-13.5 + float(i) * 9.0, 0.12, 0), Vector3(2.0, 0.06, 28), 0.0, Color(0.08, 0.48, 0.40, 0.74), false, 0.86, 0.12, 0.42)
		_add_local_trade_block(asset, "CanalHouse_%02d" % i, Vector3(-15.0 + float(i) * 10.0, 2.0, -10), Vector3(5.2, 4.0, 4.5), 0.0, Color(0.52, 0.42, 0.30), true, 0.58, 0.08, 0.48)

func _build_trade_zigzag_bridge_road(parent: Node3D, pos: Vector3, yaw: float) -> void:
	var asset := _make_city_asset(parent, "ZigzagBridgeRoad", pos, yaw)
	var points := [Vector3(-16, 0, -10), Vector3(-7, 0, 1), Vector3(6, 0, -3), Vector3(15, 0, 9)]
	for i in range(points.size() - 1):
		_build_trade_route_span(asset, "ZigzagBridgeSegment_%02d" % i, points[i], points[i + 1], 3.0, Color(0.58, 0.52, 0.44), false)

func _build_trade_boat_alley(parent: Node3D, pos: Vector3, yaw: float) -> void:
	var asset := _make_city_asset(parent, "BoatAlley", pos, yaw)
	_add_local_trade_block(asset, "BoatAlleyWater", Vector3(0, 0.12, 0), Vector3(26, 0.06, 5.0), 0.0, Color(0.08, 0.42, 0.36, 0.76), false, 0.88, 0.12, 0.42)
	for i in range(4):
		_add_local_trade_block(asset, "LowWaterDoor_%02d" % i, Vector3(-10.0 + float(i) * 6.5, 1.5, -3.0), Vector3(3.2, 3.0, 0.35), 0.0, Color(0.38, 0.30, 0.22), false, 0.72, 0.08, 0.46)

func _build_trade_multi_route_plaza(parent: Node3D, pos: Vector3, yaw: float) -> void:
	var asset := _make_city_asset(parent, "MultiRoutePlaza", pos, yaw)
	_add_local_trade_cylinder(asset, "MultiRouteDisk", Vector3(0, 0.10, 0), 14.0, 0.14, Color(0.50, 0.42, 0.28), 64, true, 0.68, 0.10, 0.48)
	for i in range(8):
		var angle := TAU * float(i) / 8.0
		_add_local_trade_block(asset, "RouteChoiceMarker_%02d" % i, Vector3(cos(angle) * 10.5, 0.35, sin(angle) * 10.5), Vector3(3.2, 0.32, 0.8), rad_to_deg(angle), Color(0.14, 0.70, 0.60, 0.62), false, 0.56, 0.24, 0.50)

func _trade_exchange_color(node_index: int) -> Color:
	return TRADE_EXCHANGE_COLORS[clampi(node_index, 0, TRADE_EXCHANGE_COLORS.size() - 1)]

func _build_trade_exchange_node(parent: Node3D, node_index: int, pos: Vector3, yaw: float) -> void:
	var data: Array = TRADE_EXCHANGE_NODES[node_index]
	var color := _trade_exchange_color(node_index)
	var asset := _make_city_asset(parent, String(data[0]), pos, yaw)
	_add_local_trade_block(asset, "LedgerPost", Vector3(0, 1.8, 0), Vector3(0.42, 3.6, 0.42), 0.0, Color(0.24, 0.16, 0.10), true, 0.42, 0.06, 0.38)
	_add_local_trade_block(asset, "ActiveTradeOffer", Vector3(0, 3.9, -0.32), Vector3(4.6, 2.0, 0.16), 0.0, color, false, 0.44, 0.24, 0.58)
	var settled := _add_local_trade_block(asset, "SettledLedger", Vector3(0, 3.9, -0.52), Vector3(4.6, 2.0, 0.16), 0.0, Color(0.86, 0.78, 0.56, 0.32), false, 0.34, 0.08, 0.44)
	settled.visible = false
	_add_trade_exchange_glow(asset, color, node_index)
	while trade_node_visuals.size() <= node_index:
		trade_node_visuals.append(null)
	trade_node_visuals[node_index] = asset

	var area := Area3D.new()
	area.name = "%sArea" % String(data[0])
	area.position = pos + Vector3(0, 1.2, 0)
	area.collision_layer = 0
	area.collision_mask = 2
	var shape := CollisionShape3D.new()
	var sphere := SphereShape3D.new()
	sphere.radius = 4.5
	shape.shape = sphere
	area.add_child(shape)
	area.body_entered.connect(func(body: Node3D): _on_trade_node_entered(body, node_index))
	area.body_exited.connect(func(body: Node3D): _on_trade_node_exited(body, node_index))
	manifested_city.add_child(area)
	while trade_node_areas.size() <= node_index:
		trade_node_areas.append(null)
	trade_node_areas[node_index] = area

func _add_trade_exchange_glow(asset: Node3D, color: Color, node_index: int) -> void:
	var halo := CSGCylinder3D.new()
	halo.name = "TradeExchangeGlow"
	halo.radius = 3.4
	halo.height = 0.035
	halo.sides = 48
	halo.position = Vector3(0, 0.10, 0)
	halo.material = _emissive_mat(color, 0.30, trade_exchange_glow_energy)
	asset.add_child(halo)
	var light := OmniLight3D.new()
	light.name = "TradeExchangeLight"
	light.position = Vector3(0, 3.6, 0)
	light.light_color = color
	light.light_energy = trade_exchange_glow_energy
	light.omni_range = 8.5
	asset.add_child(light)
	var particles := GPUParticles3D.new()
	particles.name = "TradeExchangeParticles"
	particles.amount = int(maxf(1.0, 84.0 * trade_exchange_particle_scale))
	particles.lifetime = 2.4
	particles.visibility_aabb = AABB(Vector3(-5, -1, -5), Vector3(10, 8, 10))
	var mesh := QuadMesh.new()
	mesh.size = Vector2(0.09, 0.09)
	particles.draw_pass_1 = mesh
	var process := ParticleProcessMaterial.new()
	process.emission_shape = ParticleProcessMaterial.EMISSION_SHAPE_SPHERE
	process.emission_sphere_radius = 2.6
	process.gravity = Vector3(0, 0.02, 0)
	process.initial_velocity_min = 0.04
	process.initial_velocity_max = 0.26
	process.spread = 100.0
	process.color = Color(color.r, color.g, color.b, 0.72)
	particles.process_material = process
	particles.position = Vector3(0, 2.4, 0)
	particles.emitting = true
	asset.add_child(particles)

func _set_trade_exchange_visual_state(node_index: int, resolved: bool) -> void:
	if node_index < 0 or node_index >= trade_node_visuals.size():
		return
	var asset := trade_node_visuals[node_index]
	if asset == null:
		return
	var active := asset.get_node_or_null("ActiveTradeOffer")
	if active != null:
		active.visible = not resolved
	var settled := asset.get_node_or_null("SettledLedger")
	if settled != null:
		settled.visible = resolved
	for name in ["TradeExchangeGlow", "TradeExchangeLight", "TradeExchangeParticles"]:
		var child := asset.get_node_or_null(name)
		if child != null:
			child.visible = not resolved

func _build_desire_city_whitebox(parent: Node3D) -> void:
	_build_desire_terrain_and_wall(parent)
	_build_desire_caravan_entrance(parent)
	_build_desire_canal_zone(parent)
	_build_desire_desert_sea_zone(parent)
	_build_desire_model_museum(parent)
	_build_desire_moon_maze(parent)
	_build_desire_central_plaza(parent)
	_build_desire_atmosphere(parent)

func _build_desire_terrain_and_wall(parent: Node3D) -> void:
	var terrain := _make_city_zone(parent, "DesireTerrain_DesertCanalWhiteCity")
	_add_city_block(terrain, "DesertPlainGround", Vector3(0, -0.055, 0), Vector3(238, 0.11, 238), 0.0, Color(0.66, 0.53, 0.31))
	_add_city_block(terrain, "MirageCityFloor", Vector3(0, 0.02, 4), Vector3(176, 0.06, 188), 0.0, Color(0.72, 0.64, 0.43))
	_build_moat(terrain)
	_build_green_canal(terrain, "GreenCanal_NorthSouth", Vector3(0, 0.07, 5), Vector3(7, 0.08, 150), 0.0)
	_build_green_canal(terrain, "GreenCanal_WestEast", Vector3(0, 0.075, 4), Vector3(138, 0.08, 7), 0.0)
	_build_desire_city_wall(terrain)
	for i in range(4):
		var sx := -82.0 if i % 2 == 0 else 82.0
		var sz := -82.0 if i < 2 else 82.0
		_build_aluminum_tower(terrain, "AluminumTower_%02d" % i, Vector3(sx, 0, sz), 0.0)
	var gates := [
		Vector3(0, 0, -84), Vector3(-42, 0, -84), Vector3(42, 0, -84),
		Vector3(-84, 0, 0), Vector3(84, 0, 0),
		Vector3(-32, 0, 84), Vector3(0, 0, 84), Vector3(32, 0, 84)
	]
	for i in range(gates.size()):
		var yaw := 0.0 if abs(gates[i].z) > abs(gates[i].x) else 90.0
		_build_spring_drawbridge_gate(terrain, "SpringDrawbridgeGate_%02d" % i, gates[i], yaw)

func _build_desire_caravan_entrance(parent: Node3D) -> void:
	var zone := _make_city_zone(parent, "ZoneA_CaravanEntrance")
	_build_market_trumpet_platform(zone, Vector3(0, 0, -62), 0.0)
	_build_spice_market(zone, Vector3(-20, 0, -58), 6.0)
	_build_spice_market(zone, Vector3(22, 0, -56), -8.0)
	for i in range(9):
		_build_color_banner(zone, "ColorBanner_%02d" % i, Vector3(-38.0 + float(i) * 9.5, 0, -69.0 + float(i % 2) * 8.0), 0.0)
	_build_trumpet_soldier(zone, Vector3(0, 0, -62), 0.0)
	_build_wheel_track(zone, Vector3(0, 0, -96), 0.0)
	_build_simple_desire_prop(zone, "CaviarJar", Vector3(-25, 0, -50), 0.0, Vector3(1.2, 1.5, 1.2), Color(0.17, 0.18, 0.20), true)
	_build_simple_desire_prop(zone, "AmethystCrate", Vector3(-17, 0, -49), 0.0, Vector3(2.3, 1.2, 1.8), Color(0.42, 0.20, 0.60), true)
	_add_desire_relic(zone, 0, Vector3(-8, 0, -49), 0.0)
	_build_simple_desire_prop(zone, "GoldenPheasantDish", Vector3(28, 0, -49), 0.0, Vector3(2.2, 0.35, 1.5), Color(0.94, 0.66, 0.20), false)
	_build_simple_desire_prop(zone, "MyrtleGrill", Vector3(34, 0, -48), 0.0, Vector3(2.4, 1.2, 1.6), Color(0.25, 0.18, 0.12), true)

func _build_desire_canal_zone(parent: Node3D) -> void:
	var zone := _make_city_zone(parent, "ZoneB_CanalDesire")
	for i in range(6):
		_build_green_canal_block(zone, "GreenCanalBlock_%02d" % i, Vector3(-36.0 + float(i) * 14.5, 0, -20.0 + float(i % 2) * 14.0), float(i) * 5.0)
	_build_gem_cutting_workshop(zone, Vector3(-30, 0, -4), -10.0)
	_build_pool_garden(zone, Vector3(25, 0, -2), 8.0)
	_build_kite_roof_cluster(zone, Vector3(12, 0, -22), 0.0)
	_add_desire_relic(zone, 1, Vector3(-24, 0, 5), 0.0)
	_build_simple_desire_prop(zone, "ChrysopraseStone", Vector3(-20, 0, 7), 0.0, Vector3(1.4, 0.9, 1.1), Color(0.36, 0.72, 0.48), false)
	_build_simple_desire_prop(zone, "PoolReflection", Vector3(25, 0.15, -2), 0.0, Vector3(8.0, 0.08, 5.5), Color(0.30, 0.68, 0.58, 0.48), false)
	for i in range(5):
		_build_kite(zone, "Kite_%02d" % i, Vector3(-12.0 + float(i) * 10.0, 7.0 + float(i % 2) * 2.0, -22.0 + float(i % 3) * 4.0), float(i) * 16.0)

func _build_desire_desert_sea_zone(parent: Node3D) -> void:
	var zone := _make_city_zone(parent, "ZoneC_DesertSeaMirage")
	_build_desert_sea_tower(zone, Vector3(0, 0, 22), 0.0)
	_build_radar_spire_building(zone, Vector3(-54, 0, 18), 10.0)
	_build_smoking_chimney_house(zone, Vector3(-67, 0, 36), -8.0)
	_build_harbor_tavern(zone, Vector3(58, 0, 20), -12.0)
	_build_white_tile_palace(zone, Vector3(66, 0, 42), 8.0)
	_build_red_white_windsock(zone, Vector3(-54, 13.5, 18), 0.0)
	_build_simple_desire_prop(zone, "EmbroideredSaddle", Vector3(-73, 0, 48), 14.0, Vector3(3.2, 0.7, 2.0), Color(0.58, 0.15, 0.18), false)
	_add_desire_relic(zone, 2, Vector3(73, 0, 18), 0.0)
	for i in range(4):
		_build_simple_desire_prop(zone, ["CandiedFruitJar", "DateWineJar", "TobaccoBundle", "HarborCrate"][i], Vector3(60.0 + float(i) * 3.2, 0, 30.0 + float(i % 2) * 3.0), 0.0, Vector3(1.4, 1.2, 1.4), Color(0.55, 0.34, 0.18), true)

func _build_desire_model_museum(parent: Node3D) -> void:
	var zone := _make_city_zone(parent, "ZoneD_IdealModelMuseum")
	for i in range(7):
		_build_limestone_city_block(zone, "LimestoneCityBlock_%02d" % i, Vector3(-42.0 + float(i) * 14.0, 0, 52.0 + float(i % 2) * 8.0), float(i) * 4.0)
	_build_metal_museum(zone, Vector3(0, 0, 64), 0.0)
	_build_glass_sphere_hall(zone, Vector3(0, 0, 76), 0.0)
	_build_blue_city_model_table(zone, Vector3(0, 0, 77), 0.0)
	_add_desire_relic(zone, 3, Vector3(6, 0, 76), 0.0)
	_build_simple_desire_prop(zone, "BlueMiniCity", Vector3(0, 1.9, 77), 0.0, Vector3(2.2, 0.7, 2.2), Color(0.12, 0.34, 0.88), false)
	_build_simple_desire_prop(zone, "JellyfishPoolModel", Vector3(-4, 1.5, 76), 0.0, Vector3(1.8, 0.35, 1.8), Color(0.26, 0.62, 0.82), false)
	_build_simple_desire_prop(zone, "ElephantRoadModel", Vector3(4, 1.5, 80), 0.0, Vector3(3.4, 0.25, 0.8), Color(0.46, 0.46, 0.42), false)

func _build_desire_moon_maze(parent: Node3D) -> void:
	var zone := _make_city_zone(parent, "ZoneE_MoonlitMaze")
	_build_moonlit_white_wall(zone, Vector3(0, 0, 98), 0.0)
	_build_tangled_maze_street(zone, Vector3(0, 0, 103), 0.0)
	_build_closed_arcade(zone, Vector3(-32, 0, 96), 8.0)
	_build_closed_arcade(zone, Vector3(32, 0, 98), -8.0)
	_build_misplaced_stair(zone, Vector3(-18, 0, 112), -12.0)
	_build_no_escape_wall(zone, Vector3(0, 0, 120), 0.0)
	_build_long_haired_woman_ghost(zone, Vector3(10, 0, 112), 0.0)
	_build_moonlit_white_mist(zone, Vector3(0, 0.12, 106), 0.0)
	_add_desire_relic(zone, 4, Vector3(0, 0, 111), 0.0)
	_build_moon_trap_plaza(zone, Vector3(0, 0, 116), 0.0)

func _build_desire_central_plaza(parent: Node3D) -> void:
	var zone := _make_city_zone(parent, "ZoneF_CentralCanalPlaza")
	var disk := CSGCylinder3D.new()
	disk.name = "CentralCanalPlaza"
	disk.radius = 18.0
	disk.height = 0.12
	disk.sides = 64
	disk.position = Vector3(0, 0.08, 8)
	disk.material = _mat(Color(0.76, 0.65, 0.36), 1.0)
	zone.add_child(disk)
	_add_box_collision("CentralCanalPlazaCollision", Vector3(0, 0.08, 8), Vector3(36, 0.12, 36), 0.0)
	_build_simple_desire_prop(zone, "DesireGoldMoteCluster", Vector3(0, 0.6, 8), 0.0, Vector3(2.2, 1.2, 2.2), Color(1.0, 0.72, 0.18, 0.35), false)

func _build_desire_atmosphere(parent: Node3D) -> void:
	var atmosphere := Node3D.new()
	atmosphere.name = "DesireCityAtmosphere_StyleDirection"
	parent.add_child(atmosphere)
	atmosphere.add_child(_make_city_particle_layer("HeatHazeLayer", 980, Vector2(0.34, 0.060), Vector3(112, 5.5, 112), Vector3(0.35, 0.06, -0.18), Color(1.0, 0.70, 0.22, 0.20), 0.05, 0.38, 100.0, 13.0))
	atmosphere.add_child(_make_city_particle_layer("DesireGoldMote", 1750, Vector2(0.042, 0.042), Vector3(112, 6.8, 112), Vector3(0.12, 0.10, 0.05), Color(1.0, 0.74, 0.18, 0.38), 0.06, 0.48, 100.0, 11.0))
	atmosphere.add_child(_make_city_particle_layer("RedDesireParticles", 1120, Vector2(0.036, 0.036), Vector3(110, 5.8, 110), Vector3(-0.08, 0.12, 0.18), Color(0.92, 0.18, 0.10, 0.30), 0.04, 0.34, 100.0, 12.0))
	atmosphere.add_child(_make_city_particle_layer("FarMirageLightSpots", 520, Vector2(0.16, 0.16), Vector3(122, 8.5, 122), Vector3(0.03, 0.02, -0.02), Color(1.0, 0.88, 0.52, 0.30), 0.01, 0.10, 100.0, 18.0))
	atmosphere.add_child(_make_city_particle_layer("CanalMist", 820, Vector2(0.16, 0.045), Vector3(78, 2.8, 78), Vector3(0.10, 0.04, 0.10), Color(0.48, 0.76, 0.62, 0.26), 0.03, 0.22, 100.0, 12.5))
	atmosphere.add_child(_make_city_particle_layer("OverexposedEdgeSparks", 720, Vector2(0.070, 0.032), Vector3(118, 7.0, 118), Vector3(0.20, 0.02, 0.10), Color(1.0, 0.92, 0.62, 0.38), 0.04, 0.22, 100.0, 15.0))
	atmosphere.add_child(_make_city_particle_layer("GreenCanalSparkParticles", 660, Vector2(0.038, 0.038), Vector3(82, 4.0, 82), Vector3(0.04, 0.10, 0.16), Color(0.20, 0.86, 0.58, 0.26), 0.04, 0.28, 100.0, 10.0))
	atmosphere.add_child(_make_city_particle_layer("WhiteMirageDustParticles", 1180, Vector2(0.030, 0.030), Vector3(122, 7.6, 122), Vector3(0.08, 0.06, -0.05), Color(1.0, 0.92, 0.76, 0.18), 0.02, 0.18, 100.0, 12.0))
	atmosphere.add_child(_make_city_particle_layer("ScarletNeedleParticles", 520, Vector2(0.14, 0.014), Vector3(112, 6.2, 112), Vector3(0.24, 0.08, 0.04), Color(1.0, 0.22, 0.10, 0.26), 0.05, 0.30, 100.0, 11.5))
	for i in range(10):
		var z := -74.0 + float(i) * 16.5
		var x := -58.0 if i % 2 == 0 else 58.0
		_add_city_style_veil(atmosphere, "DesireHeatMirageVeil_%02d" % i, Vector3(x, 5.6 + float(i % 3) * 0.8, z), Vector2(74.0, 16.0), 90.0 if x < 0.0 else -90.0, Color(1.0, 0.55, 0.16, 0.26), 1.0, 100.0 + float(i) * 4.2, desire_city_style_intensity)
	for i in range(6):
		_add_city_style_veil(atmosphere, "DesireHorizonOverexposure_%02d" % i, Vector3(-52.0 + float(i) * 21.0, 6.2, -76.0 + float(i % 2) * 152.0), Vector2(46.0, 12.0), float(i) * 7.0, Color(1.0, 0.82, 0.36, 0.20), 1.0, 160.0 + float(i) * 5.4, desire_city_style_intensity * 0.8)

func _build_moat(parent: Node3D) -> void:
	_add_city_block(parent, "Moat_North", Vector3(0, 0.025, -91), Vector3(184, 0.05, 8), 0.0, Color(0.16, 0.46, 0.36))
	_add_city_block(parent, "Moat_South", Vector3(0, 0.025, 91), Vector3(184, 0.05, 8), 0.0, Color(0.16, 0.46, 0.36))
	_add_city_block(parent, "Moat_West", Vector3(-91, 0.025, 0), Vector3(8, 0.05, 184), 0.0, Color(0.16, 0.46, 0.36))
	_add_city_block(parent, "Moat_East", Vector3(91, 0.025, 0), Vector3(8, 0.05, 184), 0.0, Color(0.16, 0.46, 0.36))

func _build_green_canal(parent: Node3D, name: String, pos: Vector3, size: Vector3, yaw: float) -> void:
	_add_city_block(parent, name, pos, size, yaw, Color(0.12, 0.54, 0.38))

func _build_desire_city_wall(parent: Node3D) -> void:
	var wall_color := Color(0.73, 0.68, 0.58)
	var north_segments := [
		["DesireCityWall_North_WestWing", Vector3(-64.25, 4.0, -84), Vector3(31.5, 8, 2.4)],
		["DesireCityWall_North_LeftCenter", Vector3(-21.0, 4.0, -84), Vector3(29.0, 8, 2.4)],
		["DesireCityWall_North_RightCenter", Vector3(21.0, 4.0, -84), Vector3(29.0, 8, 2.4)],
		["DesireCityWall_North_EastWing", Vector3(64.25, 4.0, -84), Vector3(31.5, 8, 2.4)]
	]
	for segment in north_segments:
		_add_city_block(parent, String(segment[0]), segment[1], segment[2], 0.0, wall_color)
	var south_segments := [
		["DesireCityWall_South_WestWing", Vector3(-59.5, 4.0, 84), Vector3(41.0, 8, 2.4)],
		["DesireCityWall_South_LeftCenter", Vector3(-16.0, 4.0, 84), Vector3(18.0, 8, 2.4)],
		["DesireCityWall_South_RightCenter", Vector3(16.0, 4.0, 84), Vector3(18.0, 8, 2.4)],
		["DesireCityWall_South_EastWing", Vector3(59.5, 4.0, 84), Vector3(41.0, 8, 2.4)]
	]
	for segment in south_segments:
		_add_city_block(parent, String(segment[0]), segment[1], segment[2], 0.0, wall_color)
	for z in [-43.5, 43.5]:
		_add_city_block(parent, "DesireCityWall_West_%s" % ("North" if z < 0.0 else "South"), Vector3(-84, 4.0, z), Vector3(2.4, 8, 73.0), 0.0, wall_color)
		_add_city_block(parent, "DesireCityWall_East_%s" % ("North" if z < 0.0 else "South"), Vector3(84, 4.0, z), Vector3(2.4, 8, 73.0), 0.0, wall_color)

func _build_aluminum_tower(parent: Node3D, name: String, pos: Vector3, yaw: float) -> void:
	var asset := _make_city_asset(parent, name, pos, yaw)
	_add_local_city_block(asset, "AluminumShaft", Vector3(0, 8.0, 0), Vector3(6, 16, 6), 0.0, Color(0.72, 0.72, 0.70))
	_add_local_city_block(asset, "ReflectiveCap", Vector3(0, 16.8, 0), Vector3(7, 1.6, 7), 0.0, Color(0.86, 0.84, 0.76), false)

func _build_spring_drawbridge_gate(parent: Node3D, name: String, pos: Vector3, yaw: float) -> void:
	var asset := _make_city_asset(parent, name, pos, yaw)
	_add_local_city_block(asset, "GatePillar_Left", Vector3(-4.8, 3.5, 0), Vector3(0.75, 7, 1.4), 0.0, Color(0.60, 0.56, 0.48), true)
	_add_local_city_block(asset, "GatePillar_Right", Vector3(4.8, 3.5, 0), Vector3(0.75, 7, 1.4), 0.0, Color(0.60, 0.56, 0.48), true)
	_add_local_city_block(asset, "GateLintel", Vector3(0, 6.8, 0), Vector3(10, 0.9, 1.4), 0.0, Color(0.60, 0.56, 0.48), true)
	_add_local_city_block(asset, "DrawbridgeDeck", Vector3(0, 0.35, -5.0), Vector3(10, 0.7, 10), 0.0, Color(0.44, 0.32, 0.20), true)
	_add_local_city_block(asset, "SpringBar", Vector3(-5.4, 4.2, 0), Vector3(0.35, 2.6, 0.35), 0.0, Color(0.80, 0.80, 0.75), false)
	_add_local_city_block(asset, "SpringBarMirror", Vector3(5.4, 4.2, 0), Vector3(0.35, 2.6, 0.35), 0.0, Color(0.80, 0.80, 0.75), false)

func _build_market_trumpet_platform(parent: Node3D, pos: Vector3, yaw: float) -> void:
	var asset := _make_city_asset(parent, "MarketTrumpetPlatform", pos, yaw)
	_add_local_city_block(asset, "RaisedPlatform", Vector3(0, 1.0, 0), Vector3(15, 2, 9), 0.0, Color(0.66, 0.50, 0.28), true)
	_add_local_city_block(asset, "BackStep", Vector3(0, 0.35, 5.4), Vector3(13, 0.7, 2.0), 0.0, Color(0.56, 0.42, 0.24), true)

func _build_spice_market(parent: Node3D, pos: Vector3, yaw: float) -> void:
	var asset := _make_city_asset(parent, "SpiceMarket_%s" % ("Left" if pos.x < 0.0 else "Right"), pos, yaw)
	for i in range(5):
		_add_local_city_block(asset, "SpiceStall_%02d" % i, Vector3(-6.0 + float(i) * 3.0, 1.1, 0), Vector3(2.2, 2.2, 3.2), 0.0, Color(0.66, 0.35 + float(i % 3) * 0.08, 0.18))
		_add_local_city_block(asset, "Awning_%02d" % i, Vector3(-6.0 + float(i) * 3.0, 2.5, -0.15), Vector3(2.6, 0.25, 3.6), 0.0, Color(0.84, 0.58, 0.20), false)

func _build_color_banner(parent: Node3D, name: String, pos: Vector3, yaw: float) -> void:
	var asset := _make_city_asset(parent, name, pos, yaw)
	_add_local_city_block(asset, "Pole", Vector3(0, 2.0, 0), Vector3(0.18, 4, 0.18), 0.0, Color(0.30, 0.24, 0.18), false)
	_add_local_city_block(asset, "BannerCloth", Vector3(0.9, 3.2, 0), Vector3(1.8, 0.9, 0.08), 0.0, Color(0.80, 0.18 + rng.randf() * 0.25, 0.16), false)

func _build_trumpet_soldier(parent: Node3D, pos: Vector3, yaw: float) -> void:
	var asset := _make_city_asset(parent, "TrumpetSoldier", pos + Vector3(0, 2.1, -1.5), yaw)
	_add_local_city_block(asset, "SoldierBody", Vector3(0, 0.3, 0), Vector3(0.55, 1.2, 0.45), 0.0, Color(0.55, 0.42, 0.22), false)
	_add_local_city_block(asset, "Trumpet", Vector3(0, 0.65, -0.75), Vector3(0.25, 0.18, 1.4), 0.0, Color(0.92, 0.68, 0.22), false)

func _build_wheel_track(parent: Node3D, pos: Vector3, yaw: float) -> void:
	var asset := _make_city_asset(parent, "WheelTrack", pos, yaw)
	_add_local_city_block(asset, "LeftTrack", Vector3(-1.2, 0.08, 0), Vector3(0.35, 0.06, 28), 0.0, Color(0.35, 0.25, 0.15), false)
	_add_local_city_block(asset, "RightTrack", Vector3(1.2, 0.08, 0), Vector3(0.35, 0.06, 28), 0.0, Color(0.35, 0.25, 0.15), false)

func _build_simple_desire_prop(parent: Node3D, name: String, pos: Vector3, yaw: float, size: Vector3, color: Color, collision := false) -> Node3D:
	var asset := _make_city_asset(parent, name, pos, yaw)
	_add_local_city_block(asset, "WhiteboxReplaceRoot", Vector3(0, size.y * 0.5, 0), size, 0.0, color, collision)
	return asset

func _build_green_canal_block(parent: Node3D, name: String, pos: Vector3, yaw: float) -> void:
	var asset := _make_city_asset(parent, name, pos, yaw)
	_add_local_city_block(asset, "CanalHouse", Vector3(0, 2.4, 0), Vector3(8, 4.8, 7), 0.0, Color(0.60, 0.55, 0.42))
	_add_local_city_block(asset, "GreenWaterEdge", Vector3(0, 0.2, -4.4), Vector3(8, 0.1, 1.4), 0.0, Color(0.14, 0.54, 0.38), false)

func _build_gem_cutting_workshop(parent: Node3D, pos: Vector3, yaw: float) -> void:
	var asset := _make_city_asset(parent, "GemCuttingWorkshop", pos, yaw)
	_add_local_city_block(asset, "WorkshopBody", Vector3(0, 2.5, 0), Vector3(10, 5, 8), 0.0, Color(0.55, 0.47, 0.35))
	_add_local_city_block(asset, "CuttingTable", Vector3(0, 1.0, -4.6), Vector3(5, 0.8, 1.4), 0.0, Color(0.34, 0.28, 0.20), false)

func _build_pool_garden(parent: Node3D, pos: Vector3, yaw: float) -> void:
	var asset := _make_city_asset(parent, "PoolGarden", pos, yaw)
	_add_local_city_block(asset, "GardenFloor", Vector3(0, 0.05, 0), Vector3(15, 0.1, 11), 0.0, Color(0.48, 0.54, 0.34), true)
	_add_local_city_block(asset, "Pool", Vector3(0, 0.16, 0), Vector3(9, 0.08, 5.5), 0.0, Color(0.22, 0.62, 0.52, 0.72), false)
	for i in range(4):
		_add_local_city_block(asset, "GardenPillar_%02d" % i, Vector3(-6.0 + float(i) * 4.0, 1.1, 4.2), Vector3(0.55, 2.2, 0.55), 0.0, Color(0.70, 0.64, 0.50), false)

func _build_kite_roof_cluster(parent: Node3D, pos: Vector3, yaw: float) -> void:
	var asset := _make_city_asset(parent, "KiteRoofCluster", pos, yaw)
	for i in range(7):
		_add_local_city_block(asset, "LowRoof_%02d" % i, Vector3(-9.0 + float(i % 4) * 6.0, 2.0, float(i / 4) * 5.0), Vector3(5.2, 4.0, 4.6), 0.0, Color(0.62, 0.50, 0.32))

func _build_kite(parent: Node3D, name: String, pos: Vector3, yaw: float) -> void:
	var asset := _make_city_asset(parent, name, pos, yaw)
	_add_local_city_block(asset, "KiteCloth", Vector3(0, 0, 0), Vector3(1.5, 0.05, 2.2), 45.0, Color(0.90, 0.28, 0.18), false)

func _build_desert_sea_tower(parent: Node3D, pos: Vector3, yaw: float) -> void:
	var asset := _make_city_asset(parent, "DesertSeaTower", pos, yaw)
	_add_local_city_block(asset, "SandFace", Vector3(-1.7, 7.0, 0), Vector3(3.4, 14, 5), 0.0, Color(0.70, 0.54, 0.28))
	_add_local_city_block(asset, "SeaFace", Vector3(1.7, 7.0, 0), Vector3(3.4, 14, 5), 0.0, Color(0.24, 0.45, 0.52))

func _build_radar_spire_building(parent: Node3D, pos: Vector3, yaw: float) -> void:
	var asset := _make_city_asset(parent, "RadarSpireBuilding", pos, yaw)
	_add_local_city_block(asset, "SpireBody", Vector3(0, 8.0, 0), Vector3(6, 16, 6), 0.0, Color(0.62, 0.64, 0.62))
	_add_local_city_block(asset, "RadarAntenna", Vector3(0, 17.0, 0), Vector3(0.3, 4.0, 0.3), 20.0, Color(0.88, 0.88, 0.82), false)

func _build_smoking_chimney_house(parent: Node3D, pos: Vector3, yaw: float) -> void:
	var asset := _make_city_asset(parent, "SmokingChimneyHouse", pos, yaw)
	_add_local_city_block(asset, "WorkshopBody", Vector3(0, 2.5, 0), Vector3(10, 5, 8), 0.0, Color(0.42, 0.36, 0.30))
	_add_local_city_block(asset, "SmokingChimney", Vector3(3, 6.0, 2), Vector3(1.1, 7, 1.1), 0.0, Color(0.25, 0.24, 0.22), false)

func _build_harbor_tavern(parent: Node3D, pos: Vector3, yaw: float) -> void:
	var asset := _make_city_asset(parent, "HarborTavern", pos, yaw)
	_add_local_city_block(asset, "TavernBody", Vector3(0, 2.4, 0), Vector3(11, 4.8, 8), 0.0, Color(0.46, 0.32, 0.22))
	_add_local_city_block(asset, "LitWindow", Vector3(0, 2.6, -4.1), Vector3(5.5, 1.4, 0.12), 0.0, Color(1.0, 0.58, 0.22, 0.68), false)

func _build_white_tile_palace(parent: Node3D, pos: Vector3, yaw: float) -> void:
	var asset := _make_city_asset(parent, "WhiteTilePalace", pos, yaw)
	_add_local_city_block(asset, "PalaceBody", Vector3(0, 3.4, 0), Vector3(16, 6.8, 12), 0.0, Color(0.86, 0.82, 0.72))
	_add_local_cylinder(asset, "WhiteDome", Vector3(0, 7.2, 0), 6.2, 1.6, Color(0.92, 0.88, 0.78), 36)

func _build_red_white_windsock(parent: Node3D, pos: Vector3, yaw: float) -> void:
	var asset := _make_city_asset(parent, "RedWhiteWindsock", pos, yaw)
	_add_local_city_block(asset, "Pole", Vector3(0, 0, 0), Vector3(0.22, 4.5, 0.22), 0.0, Color(0.72, 0.72, 0.68), false)
	_add_local_city_block(asset, "Sock", Vector3(1.2, 1.9, 0), Vector3(2.2, 0.45, 0.45), 0.0, Color(0.90, 0.15, 0.12), false)

func _build_limestone_city_block(parent: Node3D, name: String, pos: Vector3, yaw: float) -> void:
	var asset := _make_city_asset(parent, name, pos, yaw)
	_add_local_city_block(asset, "LimestoneBody", Vector3(0, 3.0, 0), Vector3(9, 6, 8), 0.0, Color(0.74, 0.70, 0.60))

func _build_metal_museum(parent: Node3D, pos: Vector3, yaw: float) -> void:
	var asset := _make_city_asset(parent, "MetalMuseum", pos, yaw)
	_add_local_city_block(asset, "MetalMuseumBody", Vector3(0, 4.5, 0), Vector3(24, 9, 16), 0.0, Color(0.58, 0.60, 0.60))
	_add_local_city_block(asset, "ReflectiveFront", Vector3(0, 4.4, -8.2), Vector3(18, 5, 0.18), 0.0, Color(0.82, 0.78, 0.65, 0.42), false)

func _build_glass_sphere_hall(parent: Node3D, pos: Vector3, yaw: float) -> void:
	var asset := _make_city_asset(parent, "GlassSphereHall", pos, yaw)
	_add_local_city_block(asset, "TransparentHall", Vector3(0, 3.0, 0), Vector3(14, 6, 10), 0.0, Color(0.55, 0.76, 0.88, 0.38), true)

func _build_blue_city_model_table(parent: Node3D, pos: Vector3, yaw: float) -> void:
	var asset := _make_city_asset(parent, "BlueCityModelTable", pos, yaw)
	_add_local_city_block(asset, "Table", Vector3(0, 0.9, 0), Vector3(8, 0.8, 5), 0.0, Color(0.32, 0.28, 0.22), true)

func _build_moonlit_white_wall(parent: Node3D, pos: Vector3, yaw: float) -> void:
	var asset := _make_city_asset(parent, "MoonlitWhiteWall", pos, yaw)
	_add_local_city_block(asset, "WhiteWall", Vector3(0, 3.2, 0), Vector3(58, 6.4, 1.2), 0.0, Color(0.86, 0.84, 0.80))

func _build_tangled_maze_street(parent: Node3D, pos: Vector3, yaw: float) -> void:
	var asset := _make_city_asset(parent, "TangledMazeStreet", pos, yaw)
	for i in range(13):
		var x := -27.0 + float(i % 7) * 9.0
		var z := -8.0 + float(i / 7) * 11.0
		_add_local_city_block(asset, "MazeWall_%02d" % i, Vector3(x, 2.4, z), Vector3(7.5, 4.8, 1.0), float((i % 4) * 22), Color(0.78, 0.76, 0.72))

func _build_closed_arcade(parent: Node3D, pos: Vector3, yaw: float) -> void:
	var asset := _make_city_asset(parent, "ClosedArcade_%s" % ("Left" if pos.x < 0 else "Right"), pos, yaw)
	for i in range(5):
		_add_local_city_block(asset, "SealedArch_%02d" % i, Vector3(0, 2.3, -8.0 + float(i) * 4.0), Vector3(5, 4.6, 0.8), 0.0, Color(0.76, 0.74, 0.70))

func _build_misplaced_stair(parent: Node3D, pos: Vector3, yaw: float) -> void:
	var asset := _make_city_asset(parent, "MisplacedStair", pos, yaw)
	for i in range(7):
		_add_local_city_block(asset, "WrongStep_%02d" % i, Vector3(float(i) * 1.1, 0.18 + float(i) * 0.28, sin(float(i)) * 1.3), Vector3(2.4, 0.35, 1.1), float(i) * 13.0, Color(0.80, 0.78, 0.74), true)

func _build_no_escape_wall(parent: Node3D, pos: Vector3, yaw: float) -> void:
	var asset := _make_city_asset(parent, "NoEscapeWall", pos, yaw)
	_add_local_city_block(asset, "EndWall", Vector3(0, 4.0, 0), Vector3(34, 8, 1.4), 0.0, Color(0.82, 0.80, 0.76))

func _build_long_haired_woman_ghost(parent: Node3D, pos: Vector3, yaw: float) -> void:
	var asset := _make_city_asset(parent, "LongHairedWomanGhost", pos, yaw)
	_add_local_city_block(asset, "RunningGhostBody", Vector3(0, 1.4, 0), Vector3(0.55, 1.8, 0.35), 0.0, Color(0.92, 0.86, 0.80, 0.28), false)
	_add_local_city_block(asset, "LongHairTrail", Vector3(0, 1.9, 0.8), Vector3(0.35, 1.1, 2.2), 0.0, Color(0.10, 0.08, 0.06, 0.30), false)

func _build_moonlit_white_mist(parent: Node3D, pos: Vector3, yaw: float) -> void:
	_build_simple_desire_prop(parent, "MoonlitWhiteMist", pos, yaw, Vector3(44, 0.05, 24), Color(0.86, 0.88, 0.92, 0.20), false)

func _build_moon_trap_plaza(parent: Node3D, pos: Vector3, yaw: float) -> void:
	var asset := _make_city_asset(parent, "MoonTrapPlaza", pos, yaw)
	_add_local_cylinder(asset, "WhiteTrapDisk", Vector3(0, 0.08, 0), 10.0, 0.12, Color(0.84, 0.82, 0.78), 48, true)
	desire_goal_trigger = Area3D.new()
	desire_goal_trigger.name = "DesireGoalTrigger"
	desire_goal_trigger.position = pos + Vector3(0, 0.9, 0)
	desire_goal_trigger.collision_layer = 0
	desire_goal_trigger.collision_mask = 2
	var shape := CollisionShape3D.new()
	var sphere := SphereShape3D.new()
	sphere.radius = 7.5
	shape.shape = sphere
	desire_goal_trigger.add_child(shape)
	desire_goal_trigger.body_entered.connect(_on_desire_goal_entered)
	desire_goal_trigger.body_exited.connect(_on_desire_goal_exited)
	manifested_city.add_child(desire_goal_trigger)

func _desire_relic_color(relic_index: int) -> Color:
	return DESIRE_RELIC_GLOW_COLORS[clampi(relic_index, 0, DESIRE_RELIC_GLOW_COLORS.size() - 1)]

func _add_desire_relic_glow(asset: Node3D, color: Color, relic_index: int) -> void:
	var base := CSGCylinder3D.new()
	base.name = "PickupGlowDisk"
	base.radius = 2.8
	base.height = 0.035
	base.sides = 48
	base.position = Vector3(0, 0.08, 0)
	base.material = _emissive_mat(color, 0.38, 1.1 * desire_relic_glow_energy)
	asset.add_child(base)

	var core := CSGCylinder3D.new()
	core.name = "PickupVerticalGlow"
	core.radius = 0.72
	core.height = 3.2
	core.sides = 32
	core.position = Vector3(0, 1.75, 0)
	core.material = _emissive_mat(color, 0.18, 1.5 * desire_relic_glow_energy)
	asset.add_child(core)

	var halo := OmniLight3D.new()
	halo.name = "PickupColoredHaloLight"
	halo.position = Vector3(0, 2.0, 0)
	halo.light_color = color
	halo.light_energy = desire_relic_glow_energy
	halo.omni_range = 7.0
	asset.add_child(halo)

	var particles := GPUParticles3D.new()
	particles.name = "PickupGlowParticles"
	particles.amount = int(maxf(1.0, 72.0 * desire_relic_particle_scale))
	particles.lifetime = 2.4
	particles.visibility_aabb = AABB(Vector3(-4, -1, -4), Vector3(8, 7, 8))
	var mesh := QuadMesh.new()
	mesh.size = Vector2(0.10, 0.10)
	particles.draw_pass_1 = mesh
	var process := ParticleProcessMaterial.new()
	process.emission_shape = ParticleProcessMaterial.EMISSION_SHAPE_SPHERE
	process.emission_sphere_radius = 2.1
	process.gravity = Vector3(0, 0.08, 0)
	process.initial_velocity_min = 0.08
	process.initial_velocity_max = 0.32
	process.spread = 100.0
	process.color = Color(color.r, color.g, color.b, 0.75)
	particles.process_material = process
	particles.position = Vector3(0, 1.15, 0)
	particles.emitting = true
	asset.add_child(particles)

	var label_marker := CSGBox3D.new()
	label_marker.name = "PickupColorMarker_%02d" % relic_index
	label_marker.size = Vector3(0.9, 0.9, 0.9)
	label_marker.position = Vector3(0, 2.65, 0)
	label_marker.material = _emissive_mat(color, 0.85, 0.85 * desire_relic_glow_energy)
	asset.add_child(label_marker)

func _add_desire_relic(parent: Node3D, relic_index: int, pos: Vector3, yaw: float) -> void:
	var data: Array = DESIRE_RELICS[relic_index]
	var relic_color := _desire_relic_color(relic_index)
	var asset := _build_simple_desire_prop(parent, String(data[0]), pos, yaw, Vector3(2.1, 1.25, 1.7), relic_color.lerp(Color(1.0, 0.78, 0.36), 0.28), false)
	asset.set_meta("desire_relic_index", relic_index)
	_add_desire_relic_glow(asset, relic_color, relic_index)
	while desire_relic_visuals.size() <= relic_index:
		desire_relic_visuals.append(null)
	desire_relic_visuals[relic_index] = asset

	var area := Area3D.new()
	area.name = "%sPickupArea" % String(data[0])
	area.position = pos + Vector3(0, 0.9, 0)
	area.collision_layer = 0
	area.collision_mask = 2
	var shape := CollisionShape3D.new()
	var sphere := SphereShape3D.new()
	sphere.radius = 2.4
	shape.shape = sphere
	area.add_child(shape)
	area.body_entered.connect(func(body: Node3D): _on_desire_relic_entered(body, relic_index))
	area.body_exited.connect(func(body: Node3D): _on_desire_relic_exited(body, relic_index))
	manifested_city.add_child(area)
	while desire_relic_areas.size() <= relic_index:
		desire_relic_areas.append(null)
	desire_relic_areas[relic_index] = area

func _build_signs_city_whitebox(parent: Node3D) -> void:
	_build_signs_terrain(parent)
	_build_signs_tamara_entrance(parent)
	_build_signs_zirma_repetition(parent)
	_build_signs_zoe_ambiguity(parent)
	_build_signs_hypatia_inversion(parent)
	_build_signs_olivia_false_description(parent)
	_build_signs_center(parent)
	_build_signs_atmosphere(parent)

func _build_signs_terrain(parent: Node3D) -> void:
	var terrain := _make_city_zone(parent, "SignsTerrain_SignWastelandPlain")
	_add_sign_toon_block(terrain, "EmptyPlainGround", Vector3(0, -0.06, 0), Vector3(238, 0.12, 238), 0.0, Color(0.63, 0.61, 0.50), true, 4.0)
	_add_sign_toon_block(terrain, "BlackWhiteCentralAxis", Vector3(0, 0.025, -16), Vector3(13, 0.05, 182), 0.0, Color(0.82, 0.80, 0.66), true, 5.0)
	_add_sign_toon_block(terrain, "CrossMeaningRoad", Vector3(0, 0.03, 2), Vector3(152, 0.05, 11), 0.0, Color(0.18, 0.18, 0.16), true, 6.0)
	for i in range(10):
		var x := -68.0 + float(i % 5) * 34.0
		var z := -96.0 + float(i / 5) * 22.0
		_build_simple_sign_prop(terrain, "TreeStoneSign_%02d" % i, Vector3(x, 0, z), float(i) * 9.0, Vector3(3.6, 2.1, 2.4), Color(0.38, 0.38, 0.32), true)
	for i in range(5):
		_build_sign_panel(terrain, "RawTraceSign_%02d" % i, Vector3(-36.0 + float(i) * 18.0, 0, -104.0), float(i % 2) * 8.0, Color(0.93, 0.90, 0.76), i)

func _build_signs_tamara_entrance(parent: Node3D) -> void:
	var zone := _make_city_zone(parent, "ZoneA_TamaraSignEntrance")
	_build_signboard_alley(zone, Vector3(0, 0, -72), 0.0)
	_build_sign_market(zone, Vector3(0, 0, -54), 0.0)
	_build_symbol_temple(zone, Vector3(34, 0, -44), -10.0)
	_build_symbol_palace(zone, Vector3(0, 0, -24), 0.0)
	_build_simple_sign_prop(zone, "SymbolPrison", Vector3(-38, 0, -34), -8.0, Vector3(13, 8, 11), Color(0.26, 0.26, 0.24), true)
	_build_simple_sign_prop(zone, "MintHouse", Vector3(-26, 0, -52), 4.0, Vector3(10, 5.5, 9), Color(0.66, 0.58, 0.28), true)
	_build_simple_sign_prop(zone, "SignSchool", Vector3(24, 0, -58), 8.0, Vector3(11, 5, 8), Color(0.78, 0.75, 0.58), true)
	var signs := [
		["ToothPliersSign", Vector3(-28, 0, -72), 0, 0],
		["JarTavernSign", Vector3(-17, 0, -70), 0, 1],
		["HalberdSign", Vector3(-6, 0, -72), 0, 2],
		["ScaleSign", Vector3(7, 0, -70), 0, 3],
		["NoEntrySign", Vector3(19, 0, -73), 0, 4],
		["NoFishingSign", Vector3(31, 0, -70), 0, 5]
	]
	for item in signs:
		_build_sign_panel(zone, String(item[0]), item[1], float(item[2]), Color(0.94, 0.91, 0.75), int(item[3]))
	_build_simple_sign_prop(zone, "HornIdol", Vector3(29, 0, -38), 0.0, Vector3(1.8, 3.0, 1.8), Color(0.20, 0.20, 0.18), false)
	_build_simple_sign_prop(zone, "HourglassIdol", Vector3(34, 0, -36), 0.0, Vector3(1.6, 3.2, 1.6), Color(0.20, 0.20, 0.18), false)
	_build_simple_sign_prop(zone, "MedusaIdol", Vector3(39, 0, -38), 0.0, Vector3(1.9, 2.8, 1.9), Color(0.20, 0.20, 0.18), false)
	_build_sign_fracture_node(zone, 0, Vector3(0, 0, -48), 0.0)

func _build_signs_zirma_repetition(parent: Node3D) -> void:
	var zone := _make_city_zone(parent, "ZoneB_ZirmaRepetition")
	for i in range(5):
		_build_skyscraper_tower(zone, "SkyscraperTower_%02d" % i, Vector3(-76, 0, -18 + float(i) * 18.0), 5.0 + float(i % 2) * 4.0)
	for i in range(4):
		_build_simple_sign_prop(zone, "LedgeTower_%02d" % i, Vector3(-54, 0, -6 + float(i) * 22.0), -8.0, Vector3(9, 13 + float(i) * 2.5, 8), Color(0.52, 0.53, 0.50), true)
	_build_simple_sign_prop(zone, "TattooAlley", Vector3(-42, 0, 20), 4.0, Vector3(9, 5, 36), Color(0.20, 0.20, 0.18), true)
	_build_simple_sign_prop(zone, "UndergroundStation", Vector3(-56, 0, 46), 0.0, Vector3(25, 2.0, 14), Color(0.12, 0.12, 0.11), true)
	for i in range(5):
		_build_airship(zone, "AirshipCopy_%02d" % i, Vector3(-72.0 + float(i) * 8.0, 19.0 + float(i % 2) * 2.0, 44.0 + float(i) * 4.5), float(i) * 12.0)
		_build_simple_sign_prop(zone, "BlindManCane_%02d" % i, Vector3(-49, 0, -18 + float(i) * 9.0), 12.0, Vector3(0.25, 2.7, 0.25), Color(0.03, 0.03, 0.03), false)
		_build_simple_sign_prop(zone, "JaguarSymbol_%02d" % i, Vector3(-65, 0, -12 + float(i) * 10.0), -8.0, Vector3(2.8, 1.2, 1.0), Color(0.04, 0.04, 0.03), false)
	_build_sign_fracture_node(zone, 1, Vector3(-50, 0, 6), 90.0)

func _build_signs_zoe_ambiguity(parent: Node3D) -> void:
	var zone := _make_city_zone(parent, "ZoneC_ZoeAmbiguity")
	for i in range(12):
		var x := 35.0 + float(i % 4) * 14.0
		var z := -28.0 + float(i / 4) * 22.0
		_build_pyramid_house(zone, "AmbiguousPyramidHouse_%02d" % i, Vector3(x, 0, z), float(i) * 11.0)
	_build_simple_sign_prop(zone, "ConfusedHouseCluster", Vector3(60, 0, 28), 0.0, Vector3(31, 4.2, 24), Color(0.64, 0.62, 0.48), true)
	_build_simple_sign_prop(zone, "WolfBoundaryStone", Vector3(84, 0, 6), 0.0, Vector3(3, 4.2, 2), Color(0.16, 0.16, 0.15), true)
	_build_simple_sign_prop(zone, "WheelSoundMark", Vector3(42, 0.12, 44), 0.0, Vector3(32, 0.08, 2.2), Color(0.06, 0.06, 0.055), false)
	_build_sign_fracture_node(zone, 2, Vector3(54, 0, 0), -90.0)

func _build_signs_hypatia_inversion(parent: Node3D) -> void:
	var zone := _make_city_zone(parent, "ZoneD_HypatiaInversion")
	_build_simple_sign_prop(zone, "MagnoliaLakeGarden", Vector3(24, 0, 48), 0.0, Vector3(30, 0.22, 20), Color(0.26, 0.52, 0.74), true)
	for i in range(6):
		_build_simple_sign_prop(zone, "MagnoliaTree_%02d" % i, Vector3(12 + float(i) * 4.8, 0, 37 + float(i % 2) * 19.0), 0.0, Vector3(1.2, 5.0, 1.2), Color(0.60, 0.62, 0.52), false)
	_build_simple_sign_prop(zone, "UnderwaterCrab", Vector3(20, 0.35, 48), 0.0, Vector3(2.1, 0.6, 1.4), Color(0.28, 0.05, 0.04), false)
	_build_simple_sign_prop(zone, "GreenSeaweed", Vector3(28, 0.4, 51), 0.0, Vector3(1.3, 2.2, 1.3), Color(0.08, 0.34, 0.14), false)
	_build_great_dome_palace(zone, Vector3(0, 0, 72), 0.0)
	_build_simple_sign_prop(zone, "UndergroundQuarry", Vector3(-8, -1.2, 82), 0.0, Vector3(26, 2.2, 16), Color(0.12, 0.12, 0.13), true)
	_build_simple_sign_prop(zone, "BlackShackles", Vector3(-18, 0, 78), 0.0, Vector3(3.4, 0.5, 1.0), Color(0.02, 0.02, 0.02), false)
	_build_great_library(zone, Vector3(-38, 0, 62), -8.0)
	_build_simple_sign_prop(zone, "ChildrenPlayground", Vector3(-60, 0, 72), 4.0, Vector3(16, 1.0, 11), Color(0.72, 0.62, 0.22), true)
	_build_simple_sign_prop(zone, "Swing", Vector3(-62, 0, 72), 0.0, Vector3(3.8, 4.0, 1.0), Color(0.12, 0.12, 0.10), false)
	_build_simple_sign_prop(zone, "SpinningTop", Vector3(-55, 0, 70), 0.0, Vector3(1.2, 1.2, 1.2), Color(0.32, 0.10, 0.10), false)
	_build_simple_sign_prop(zone, "CemeteryMusicYard", Vector3(48, 0, 78), 0.0, Vector3(24, 0.4, 18), Color(0.18, 0.18, 0.17), true)
	_build_simple_sign_prop(zone, "FluteTombSound", Vector3(42, 0, 78), 0.0, Vector3(4.0, 0.22, 0.22), Color(0.78, 0.78, 0.70), false)
	_build_simple_sign_prop(zone, "HarpTombSound", Vector3(52, 0, 80), 0.0, Vector3(2.0, 3.0, 0.28), Color(0.78, 0.78, 0.70), false)
	_build_castle_spire(zone, Vector3(0, 0, 104), 0.0)
	_build_sign_fracture_node(zone, 3, Vector3(-28, 0, 72), 0.0)

func _build_signs_olivia_false_description(parent: Node3D) -> void:
	var zone := _make_city_zone(parent, "ZoneE_OliviaFalseDescription")
	_build_simple_sign_prop(zone, "GildedPalace", Vector3(0, 0, 30), 0.0, Vector3(28, 9, 16), Color(0.86, 0.70, 0.22), true)
	_build_simple_sign_prop(zone, "DoubleWindowHouse_Left", Vector3(-26, 0, 26), 6.0, Vector3(12, 5, 9), Color(0.76, 0.72, 0.56), true)
	_build_simple_sign_prop(zone, "DoubleWindowHouse_Right", Vector3(26, 0, 26), -6.0, Vector3(12, 5, 9), Color(0.76, 0.72, 0.56), true)
	_build_simple_sign_prop(zone, "LawnCourtyard", Vector3(0, 0.08, 14), 0.0, Vector3(38, 0.12, 16), Color(0.24, 0.52, 0.22), true)
	_build_simple_sign_prop(zone, "WhitePeacock", Vector3(-10, 0, 12), 0.0, Vector3(2.4, 2.0, 1.2), Color(0.95, 0.93, 0.84), false)
	_build_simple_sign_prop(zone, "RotatingSprinkler", Vector3(9, 0, 13), 0.0, Vector3(4.5, 0.25, 0.25), Color(0.30, 0.44, 0.55), false)
	_build_simple_sign_prop(zone, "SaddleShop", Vector3(-44, 0, 28), 0.0, Vector3(10, 5, 9), Color(0.38, 0.22, 0.12), true)
	_build_simple_sign_prop(zone, "MatWeavingWorkshop", Vector3(-58, 0, 20), 0.0, Vector3(11, 4.5, 8), Color(0.52, 0.42, 0.22), true)
	_build_simple_sign_prop(zone, "WaterwheelMill", Vector3(48, 0, 32), 0.0, Vector3(13, 6, 10), Color(0.42, 0.35, 0.23), true)
	_build_simple_sign_prop(zone, "CanoeDock", Vector3(60, 0, 46), 0.0, Vector3(18, 0.8, 5), Color(0.22, 0.18, 0.12), true)
	_build_simple_sign_prop(zone, "BlueGreenEstuary", Vector3(72, 0.05, 54), 0.0, Vector3(32, 0.08, 18), Color(0.10, 0.42, 0.44), false)
	_build_simple_sign_prop(zone, "LitCanoe", Vector3(70, 0.25, 52), 0.0, Vector3(7.5, 0.6, 1.3), Color(0.95, 0.72, 0.28), false)
	_build_simple_sign_prop(zone, "SootDistrict", Vector3(-42, 0, 54), 0.0, Vector3(34, 6.5, 18), Color(0.05, 0.05, 0.045), true)
	_build_simple_sign_prop(zone, "CoalDustLayer", Vector3(-42, 0.15, 44), 0.0, Vector3(42, 0.12, 34), Color(0.02, 0.02, 0.018), false)
	_build_simple_sign_prop(zone, "CargoCart", Vector3(-22, 0, 44), 0.0, Vector3(5.5, 2.2, 3.2), Color(0.22, 0.16, 0.10), true)
	_build_simple_sign_prop(zone, "MillingGear", Vector3(-57, 0, 26), 0.0, Vector3(2.8, 2.8, 0.4), Color(0.12, 0.12, 0.12), false)
	_build_simple_sign_prop(zone, "OilSmokeCloud", Vector3(-42, 8, 56), 0.0, Vector3(20, 7, 10), Color(0.04, 0.04, 0.04, 0.34), false)
	_build_simple_sign_prop(zone, "FlySwarm", Vector3(-34, 3, 47), 0.0, Vector3(10, 4, 6), Color(0.01, 0.01, 0.01, 0.45), false)
	_build_sign_fracture_node(zone, 4, Vector3(-20, 0, 36), 180.0)

func _build_signs_center(parent: Node3D) -> void:
	var zone := _make_city_zone(parent, "ZoneF_NamelessSignPlaza")
	var disk := CSGCylinder3D.new()
	disk.name = "NamelessPlaza"
	disk.radius = 19.0
	disk.height = 0.14
	disk.sides = 64
	disk.position = Vector3(0, 0.08, 0)
	disk.material = _sign_toon_material(Color(0.86, 0.84, 0.70, 1.0), 230.0, 0.82)
	zone.add_child(disk)
	_add_box_collision("NamelessPlazaCollision", Vector3(0, 0.08, 0), Vector3(38, 0.14, 38), 0.0)
	_build_simple_sign_prop(zone, "CentralBlankSignPillar", Vector3(0, 0, 0), 0.0, Vector3(4, 13, 4), Color(0.95, 0.94, 0.86), true)
	_build_simple_sign_prop(zone, "SignFractureRing", Vector3(0, 0.18, 0), 0.0, Vector3(26, 0.12, 26), Color(0.03, 0.03, 0.03, 0.46), false)
	sign_goal_trigger = Area3D.new()
	sign_goal_trigger.name = "SignsGoalTrigger"
	sign_goal_trigger.position = Vector3(0, 1.0, 0)
	sign_goal_trigger.collision_layer = 0
	sign_goal_trigger.collision_mask = 2
	var shape := CollisionShape3D.new()
	var sphere := SphereShape3D.new()
	sphere.radius = 8.5
	shape.shape = sphere
	sign_goal_trigger.add_child(shape)
	sign_goal_trigger.body_entered.connect(_on_sign_goal_entered)
	sign_goal_trigger.body_exited.connect(_on_sign_goal_exited)
	manifested_city.add_child(sign_goal_trigger)

func _build_signs_atmosphere(parent: Node3D) -> void:
	var atmosphere := Node3D.new()
	atmosphere.name = "SignsCityAtmosphere_StyleDirection"
	parent.add_child(atmosphere)
	atmosphere.add_child(_make_city_particle_layer("FloatingLetterParticles", 1120, Vector2(0.052, 0.085), Vector3(112, 8, 112), Vector3(0.05, 0.12, -0.03), Color(0.02, 0.02, 0.02, 0.32), 0.04, 0.26, 100.0, 13.0))
	atmosphere.add_child(_make_city_particle_layer("InkDotParticles", 1500, Vector2(0.030, 0.030), Vector3(114, 6.0, 114), Vector3(-0.08, 0.06, 0.04), Color(0.02, 0.02, 0.018, 0.35), 0.05, 0.34, 100.0, 10.0))
	atmosphere.add_child(_make_city_particle_layer("SymbolFragmentParticles", 740, Vector2(0.11, 0.045), Vector3(108, 6.5, 108), Vector3(0.18, 0.06, 0.08), Color(0.86, 0.82, 0.58, 0.28), 0.06, 0.28, 100.0, 12.0))
	atmosphere.add_child(_make_city_particle_layer("GlowingLineParticles", 520, Vector2(0.22, 0.024), Vector3(106, 7.0, 106), Vector3(0.10, 0.10, 0.10), Color(0.30, 0.56, 1.0, 0.32), 0.05, 0.22, 100.0, 14.0))
	atmosphere.add_child(_make_city_particle_layer("PaleLabelDustParticles", 920, Vector2(0.026, 0.026), Vector3(108, 5.4, 108), Vector3(0.04, 0.05, -0.06), Color(0.94, 0.90, 0.72, 0.18), 0.02, 0.18, 100.0, 11.0))
	atmosphere.add_child(_make_city_particle_layer("BlackStrokeNeedleParticles", 440, Vector2(0.15, 0.012), Vector3(108, 6.2, 108), Vector3(-0.16, 0.04, 0.10), Color(0.02, 0.02, 0.018, 0.30), 0.04, 0.24, 100.0, 13.0))
	for i in range(10):
		var angle := TAU * float(i) / 10.0
		_add_sign_projection_veil(atmosphere, "SignProjectionVeil_%02d" % i, Vector3(cos(angle) * 48.0, 5.8 + float(i % 3) * 1.1, sin(angle) * 48.0), Vector2(72, 16 + float(i % 2) * 4.0), rad_to_deg(angle) + 90.0, Color(0.34, 0.58, 1.0, 0.30), 300.0 + float(i) * 7.0, float(i % 3) * 0.25)
	_add_sign_projection_veil(atmosphere, "BlackWhiteContrastFog", Vector3(0, 4.8, 0), Vector2(116, 20), 0.0, Color(0.96, 0.94, 0.78, 0.20), 380.0, 0.35)
	_add_sign_projection_veil(atmosphere, "FalseDescriptionSmokeLayer", Vector3(-42, 7.5, 50), Vector2(44, 18), -8.0, Color(0.04, 0.04, 0.04, 0.34), 412.0, 0.8)
	_add_sign_projection_veil(atmosphere, "BlankMeaningPulse", Vector3(0, 7.0, 0), Vector2(38, 14), 0.0, Color(1.0, 0.96, 0.72, 0.32), 450.0, 1.0)

func _add_sign_toon_block(parent: Node3D, name: String, pos: Vector3, size: Vector3, yaw: float, color: Color, collision := true, seed := 0.0) -> Node3D:
	var box := CSGBox3D.new()
	box.name = name
	box.position = pos
	box.size = size
	box.rotation_degrees.y = yaw
	box.material = _sign_toon_material(color, seed, 0.78)
	parent.add_child(box)
	if collision:
		_add_box_collision(name + "Collision", pos, size, yaw)
	return box

func _build_simple_sign_prop(parent: Node3D, name: String, pos: Vector3, yaw: float, size: Vector3, color: Color, collision := false) -> Node3D:
	var asset := _make_city_asset(parent, name, pos, yaw)
	_add_local_sign_block(asset, "WhiteboxReplaceRoot", Vector3(0, size.y * 0.5, 0), size, 0.0, color, collision)
	return asset

func _add_local_sign_block(asset: Node3D, part_name: String, local_pos: Vector3, size: Vector3, local_yaw: float, color: Color, collision := true) -> Node3D:
	var global_pos := _asset_global_pos(asset, local_pos)
	var global_yaw := _asset_global_yaw(asset, local_yaw)
	var box := CSGBox3D.new()
	box.name = part_name
	box.position = local_pos
	box.size = size
	box.rotation_degrees.y = local_yaw
	box.material = _sign_toon_material(color, global_pos.x + global_pos.z + size.y, 0.78)
	asset.add_child(box)
	if collision:
		_add_box_collision("%s_%sCollision" % [asset.name, part_name], global_pos, size, global_yaw)
	return box

func _build_sign_panel(parent: Node3D, name: String, pos: Vector3, yaw: float, color: Color, symbol_kind: int) -> Node3D:
	var asset := _make_city_asset(parent, name, pos, yaw)
	_add_local_sign_block(asset, "Post", Vector3(0, 1.8, 0), Vector3(0.28, 3.6, 0.28), 0.0, Color(0.05, 0.05, 0.045), false)
	_add_local_sign_block(asset, "Panel", Vector3(0, 3.5, 0), Vector3(3.8, 2.1, 0.18), 0.0, color, false)
	var glyph_color := Color(0.02, 0.02, 0.018)
	match symbol_kind % 6:
		0:
			_add_local_sign_block(asset, "GlyphVertical", Vector3(0, 3.5, -0.12), Vector3(0.32, 1.4, 0.08), 0.0, glyph_color, false)
			_add_local_sign_block(asset, "GlyphHandle", Vector3(0.5, 3.0, -0.12), Vector3(0.95, 0.26, 0.08), 0.0, glyph_color, false)
		1:
			_add_local_sign_block(asset, "GlyphJar", Vector3(0, 3.38, -0.12), Vector3(1.0, 1.3, 0.08), 0.0, glyph_color, false)
			_add_local_sign_block(asset, "GlyphNeck", Vector3(0, 4.15, -0.12), Vector3(0.55, 0.34, 0.08), 0.0, glyph_color, false)
		2:
			_add_local_sign_block(asset, "GlyphShaft", Vector3(0, 3.5, -0.12), Vector3(0.22, 1.7, 0.08), 0.0, glyph_color, false)
			_add_local_sign_block(asset, "GlyphBlade", Vector3(0.35, 4.05, -0.12), Vector3(0.75, 0.35, 0.08), 28.0, glyph_color, false)
		3:
			_add_local_sign_block(asset, "GlyphBalance", Vector3(0, 3.85, -0.12), Vector3(1.6, 0.22, 0.08), 0.0, glyph_color, false)
			_add_local_sign_block(asset, "GlyphStem", Vector3(0, 3.3, -0.12), Vector3(0.18, 1.2, 0.08), 0.0, glyph_color, false)
		4:
			_add_local_sign_block(asset, "GlyphNoEntry", Vector3(0, 3.5, -0.12), Vector3(1.6, 0.30, 0.08), 0.0, glyph_color, false)
		_:
			_add_local_sign_block(asset, "GlyphSlashA", Vector3(0, 3.5, -0.12), Vector3(1.8, 0.22, 0.08), 35.0, glyph_color, false)
			_add_local_sign_block(asset, "GlyphSlashB", Vector3(0, 3.5, -0.12), Vector3(1.8, 0.22, 0.08), -35.0, glyph_color, false)
	return asset

func _build_signboard_alley(parent: Node3D, pos: Vector3, yaw: float) -> void:
	var asset := _make_city_asset(parent, "SignboardAlley", pos, yaw)
	_add_local_sign_block(asset, "LeftWall", Vector3(-7, 2.4, 0), Vector3(1.0, 4.8, 34), 0.0, Color(0.70, 0.67, 0.53), true)
	_add_local_sign_block(asset, "RightWall", Vector3(7, 2.4, 0), Vector3(1.0, 4.8, 34), 0.0, Color(0.70, 0.67, 0.53), true)
	for i in range(8):
		var side := -6.3 if i % 2 == 0 else 6.3
		_build_sign_panel(asset, "AlleyWallSign_%02d" % i, Vector3(side, 0, -14.0 + float(i) * 4.0), 90.0 if side < 0.0 else -90.0, Color(0.91, 0.88, 0.70), i)

func _build_sign_market(parent: Node3D, pos: Vector3, yaw: float) -> void:
	var asset := _make_city_asset(parent, "SignMarket", pos, yaw)
	for i in range(8):
		_add_local_sign_block(asset, "MarketStall_%02d" % i, Vector3(-14.0 + float(i % 4) * 9.5, 1.1, -4.0 + float(i / 4) * 8.0), Vector3(5.5, 2.2, 4.0), 0.0, Color(0.72, 0.64, 0.40), true)
		_add_local_sign_block(asset, "MarketLabel_%02d" % i, Vector3(-14.0 + float(i % 4) * 9.5, 2.8, -6.1 + float(i / 4) * 8.0), Vector3(4.3, 1.1, 0.16), 0.0, Color(0.95, 0.92, 0.70), false)

func _build_symbol_temple(parent: Node3D, pos: Vector3, yaw: float) -> void:
	var asset := _make_city_asset(parent, "SymbolTemple", pos, yaw)
	_add_local_sign_block(asset, "TempleBase", Vector3(0, 1.0, 0), Vector3(17, 2, 12), 0.0, Color(0.72, 0.70, 0.58), true)
	_add_local_sign_block(asset, "TempleBody", Vector3(0, 4.2, 0), Vector3(13, 6.4, 9), 0.0, Color(0.82, 0.80, 0.64), true)
	_add_local_sign_block(asset, "BlackGlyphFrieze", Vector3(0, 7.8, -4.6), Vector3(12, 1.0, 0.18), 0.0, Color(0.02, 0.02, 0.018), false)

func _build_symbol_palace(parent: Node3D, pos: Vector3, yaw: float) -> void:
	var asset := _make_city_asset(parent, "SymbolPalace", pos, yaw)
	_add_local_sign_block(asset, "PalaceBody", Vector3(0, 5.0, 0), Vector3(28, 10, 16), 0.0, Color(0.78, 0.72, 0.48), true)
	_add_local_sign_block(asset, "PalaceSignWall", Vector3(0, 6.0, -8.2), Vector3(22, 6, 0.22), 0.0, Color(0.95, 0.92, 0.70), false)
	for i in range(5):
		_add_local_sign_block(asset, "ShieldGlyph_%02d" % i, Vector3(-8.0 + float(i) * 4.0, 6.1, -8.45), Vector3(1.7, 2.0, 0.12), 0.0, Color(0.03, 0.03, 0.025), false)

func _build_skyscraper_tower(parent: Node3D, name: String, pos: Vector3, yaw: float) -> void:
	var asset := _make_city_asset(parent, name, pos, yaw)
	_add_local_sign_block(asset, "SkyscraperShaft", Vector3(0, 13, 0), Vector3(8, 26, 7), 0.0, Color(0.58, 0.60, 0.56), true)
	for i in range(6):
		_add_local_sign_block(asset, "RepeatedWindowSymbol_%02d" % i, Vector3(0, 4.5 + float(i) * 3.4, -3.65), Vector3(5.8, 0.8, 0.12), 0.0, Color(0.02, 0.02, 0.018), false)

func _build_airship(parent: Node3D, name: String, pos: Vector3, yaw: float) -> void:
	var asset := _make_city_asset(parent, name, pos, yaw)
	_add_local_sign_block(asset, "AirshipHull", Vector3(0, 0, 0), Vector3(8, 1.8, 2.2), 0.0, Color(0.80, 0.78, 0.64), false)
	_add_local_sign_block(asset, "AirshipFin", Vector3(4.6, 0.35, 0), Vector3(1.2, 1.0, 0.18), 0.0, Color(0.04, 0.04, 0.035), false)

func _build_pyramid_house(parent: Node3D, name: String, pos: Vector3, yaw: float) -> void:
	var asset := _make_city_asset(parent, name, pos, yaw)
	_add_local_sign_block(asset, "AmbiguousBase", Vector3(0, 1.8, 0), Vector3(8, 3.6, 8), 0.0, Color(0.64, 0.62, 0.50), true)
	_add_local_sign_block(asset, "AmbiguousRoofStepA", Vector3(0, 4.0, 0), Vector3(6, 1.4, 6), 0.0, Color(0.54, 0.53, 0.45), true)
	_add_local_sign_block(asset, "AmbiguousRoofStepB", Vector3(0, 5.2, 0), Vector3(3.6, 1.0, 3.6), 0.0, Color(0.42, 0.42, 0.38), false)

func _build_great_dome_palace(parent: Node3D, pos: Vector3, yaw: float) -> void:
	var asset := _make_city_asset(parent, "GreatDomePalace", pos, yaw)
	_add_local_sign_block(asset, "DomePalaceBase", Vector3(0, 3, 0), Vector3(22, 6, 14), 0.0, Color(0.82, 0.76, 0.58), true)
	_add_local_sign_block(asset, "PorphyrySteps", Vector3(0, 0.5, -9), Vector3(18, 1, 4), 0.0, Color(0.28, 0.20, 0.22), true)
	_add_local_cylinder(asset, "GreatDome", Vector3(0, 7.0, 0), 8.2, 2.4, Color(0.88, 0.84, 0.62), 36, false)

func _build_great_library(parent: Node3D, pos: Vector3, yaw: float) -> void:
	var asset := _make_city_asset(parent, "GreatLibrary", pos, yaw)
	_add_local_sign_block(asset, "LibraryBody", Vector3(0, 4.2, 0), Vector3(23, 8.4, 18), 0.0, Color(0.62, 0.58, 0.42), true)
	for i in range(7):
		_add_local_sign_block(asset, "ScrollStack_%02d" % i, Vector3(-9.0 + float(i) * 3.0, 8.8, -9.2), Vector3(1.8, 2.6, 0.35), 0.0, Color(0.92, 0.86, 0.62), false)
	_build_simple_sign_prop(asset, "PapyrusCell", Vector3(5, 0, 7), 0.0, Vector3(5, 3.5, 4), Color(0.86, 0.78, 0.48), false)
	_build_simple_sign_prop(asset, "ParchmentScroll", Vector3(-4, 0, 8), 0.0, Vector3(3.8, 0.45, 0.45), Color(0.94, 0.88, 0.62), false)
	_build_simple_sign_prop(asset, "OpiumPipe", Vector3(7, 0, 6), 0.0, Vector3(2.8, 0.25, 0.25), Color(0.08, 0.05, 0.04), false)

func _build_castle_spire(parent: Node3D, pos: Vector3, yaw: float) -> void:
	var asset := _make_city_asset(parent, "CastleSpire", pos, yaw)
	_add_local_sign_block(asset, "SpireBody", Vector3(0, 12, 0), Vector3(7, 24, 7), 0.0, Color(0.48, 0.48, 0.42), true)
	_add_local_sign_block(asset, "SpireNeedle", Vector3(0, 26, 0), Vector3(2.2, 8, 2.2), 0.0, Color(0.03, 0.03, 0.028), false)

func _sign_fracture_color(node_index: int) -> Color:
	return SIGN_FRACTURE_COLORS[clampi(node_index, 0, SIGN_FRACTURE_COLORS.size() - 1)]

func _build_sign_fracture_node(parent: Node3D, node_index: int, pos: Vector3, yaw: float) -> void:
	var data: Array = SIGN_FRACTURE_NODES[node_index]
	var color := _sign_fracture_color(node_index)
	var asset := _make_city_asset(parent, String(data[0]), pos, yaw)
	_add_local_sign_block(asset, "FracturePillar", Vector3(0, 2.1, 0), Vector3(1.4, 4.2, 1.4), 0.0, Color(0.04, 0.04, 0.035), true)
	_add_local_sign_block(asset, "ActiveSymbolPanel", Vector3(0, 4.8, -0.35), Vector3(4.8, 2.4, 0.16), 0.0, color, false)
	var blank := _add_local_sign_block(asset, "ResolvedBlankPanel", Vector3(0, 4.8, -0.55), Vector3(4.8, 2.4, 0.16), 0.0, Color(0.96, 0.94, 0.86), false)
	blank.visible = false
	_add_sign_fracture_glow(asset, color, node_index)
	while sign_node_visuals.size() <= node_index:
		sign_node_visuals.append(null)
	sign_node_visuals[node_index] = asset

	var area := Area3D.new()
	area.name = "%sArea" % String(data[0])
	area.position = pos + Vector3(0, 1.2, 0)
	area.collision_layer = 0
	area.collision_mask = 2
	var shape := CollisionShape3D.new()
	var sphere := SphereShape3D.new()
	sphere.radius = 4.2
	shape.shape = sphere
	area.add_child(shape)
	area.body_entered.connect(func(body: Node3D): _on_sign_node_entered(body, node_index))
	area.body_exited.connect(func(body: Node3D): _on_sign_node_exited(body, node_index))
	manifested_city.add_child(area)
	while sign_node_areas.size() <= node_index:
		sign_node_areas.append(null)
	sign_node_areas[node_index] = area

func _add_sign_fracture_glow(asset: Node3D, color: Color, node_index: int) -> void:
	var halo := CSGCylinder3D.new()
	halo.name = "SignFractureActiveGlow"
	halo.radius = 3.2
	halo.height = 0.04
	halo.sides = 48
	halo.position = Vector3(0, 0.12, 0)
	halo.material = _emissive_mat(color, 0.34, sign_fracture_glow_energy)
	asset.add_child(halo)
	var light := OmniLight3D.new()
	light.name = "SignFractureLight"
	light.position = Vector3(0, 4.5, 0)
	light.light_color = color
	light.light_energy = sign_fracture_glow_energy
	light.omni_range = 8.0
	asset.add_child(light)
	var particles := GPUParticles3D.new()
	particles.name = "SignFractureParticles"
	particles.amount = int(maxf(1.0, 66.0 * sign_fracture_particle_scale))
	particles.lifetime = 2.5
	particles.visibility_aabb = AABB(Vector3(-5, -1, -5), Vector3(10, 8, 10))
	var mesh := QuadMesh.new()
	mesh.size = Vector2(0.12, 0.055)
	particles.draw_pass_1 = mesh
	var process := ParticleProcessMaterial.new()
	process.emission_shape = ParticleProcessMaterial.EMISSION_SHAPE_SPHERE
	process.emission_sphere_radius = 2.6
	process.gravity = Vector3.ZERO
	process.initial_velocity_min = 0.04
	process.initial_velocity_max = 0.26
	process.spread = 100.0
	process.color = Color(color.r, color.g, color.b, 0.72)
	particles.process_material = process
	particles.position = Vector3(0, 3.2, 0)
	particles.emitting = true
	asset.add_child(particles)

func _set_sign_fracture_visual_state(node_index: int, resolved: bool) -> void:
	if node_index < 0 or node_index >= sign_node_visuals.size():
		return
	var asset := sign_node_visuals[node_index]
	if asset == null:
		return
	var active := asset.get_node_or_null("ActiveSymbolPanel")
	if active != null:
		active.visible = not resolved
	var blank := asset.get_node_or_null("ResolvedBlankPanel")
	if blank != null:
		blank.visible = resolved
	for name in ["SignFractureActiveGlow", "SignFractureLight", "SignFractureParticles"]:
		var child := asset.get_node_or_null(name)
		if child != null:
			child.visible = not resolved

func _build_eyes_city_whitebox(parent: Node3D) -> void:
	_build_eyes_terrain(parent)
	_build_eyes_valdrada_mirror_lake(parent)
	_build_eyes_zemrude_low_sight(parent)
	_build_eyes_baucis_cloud_stilt(parent)
	_build_eyes_phyllis_bridge_window(parent)
	_build_eyes_moriana_two_face(parent)
	_build_eyes_center_core(parent)
	_build_eyes_atmosphere(parent)

func _build_eyes_terrain(parent: Node3D) -> void:
	var terrain := _make_city_zone(parent, "EyesTerrain_MirrorLakeDoubleCity")
	_add_eye_block(terrain, "ColdStoneBasinGround", Vector3(0, -0.06, 0), Vector3(238, 0.12, 238), 0.0, Color(0.42, 0.50, 0.54), true, 0.0)
	_add_eye_water_plane(terrain, "MirrorLakeSurface", Vector3(0, 0.035, -46), Vector2(150, 58), 0.0, Color(0.28, 0.62, 0.82, 0.64), 3.0)
	_add_eye_block(terrain, "CentralViewAxis", Vector3(0, 0.035, 0), Vector3(12, 0.05, 168), 0.0, Color(0.72, 0.80, 0.84, 0.72), true, 4.0)
	_add_eye_block(terrain, "MirrorViewAxis", Vector3(0, 0.055, 0), Vector3(128, 0.04, 4), 0.0, Color(0.86, 0.94, 1.0, 0.38), false, 6.0)

func _build_eyes_valdrada_mirror_lake(parent: Node3D) -> void:
	var zone := _make_city_zone(parent, "ZoneA_ValdradaMirrorLake")
	_build_eye_simple_prop(zone, "MirrorLakeShore", Vector3(0, 0, -76), 0.0, Vector3(82, 1.4, 8), Color(0.50, 0.58, 0.60), true)
	for i in range(7):
		_build_stacked_balcony_house(zone, "StackedBalconyHouse_%02d" % i, Vector3(-42.0 + float(i) * 14.0, 0, -64.0 + float(i % 2) * 6.0), float(i % 3) * 3.0)
	_build_eye_simple_prop(zone, "HighStreetRailing", Vector3(0, 2.1, -54), 0.0, Vector3(92, 1.2, 0.8), Color(0.78, 0.88, 0.92), false)
	_build_reflected_lake_city(zone, Vector3(0, -2.2, -34), 0.0)
	_build_eye_simple_prop(zone, "MirrorInteriorHouse", Vector3(46, 0, -52), -8.0, Vector3(14, 6, 12), Color(0.62, 0.86, 0.94, 0.58), true)
	_build_eye_simple_prop(zone, "InteriorMirror", Vector3(46, 3.2, -58.3), -8.0, Vector3(8, 3.8, 0.18), Color(0.84, 0.96, 1.0, 0.44), false)
	_build_eye_simple_prop(zone, "ReliefWallPattern", Vector3(-50, 3.2, -58), 0.0, Vector3(8, 2.8, 0.18), Color(0.80, 0.86, 0.84), false)
	_build_eye_simple_prop(zone, "BloodReflection", Vector3(-22, 0.09, -38), 0.0, Vector3(14, 0.05, 6), Color(0.55, 0.02, 0.03, 0.42), false)
	_build_eye_simple_prop(zone, "EmbraceReflection", Vector3(22, 0.10, -38), 0.0, Vector3(12, 0.05, 6), Color(0.90, 0.78, 0.72, 0.34), false)
	_build_eye_observation_node(zone, 0, Vector3(0, 0, -50), 0.0)

func _build_eyes_zemrude_low_sight(parent: Node3D) -> void:
	var zone := _make_city_zone(parent, "ZoneB_ZemrudeLowSight")
	for i in range(5):
		_build_eye_simple_prop(zone, "HighWindowHouse_%02d" % i, Vector3(-72, 0, -22 + float(i) * 16), 4.0, Vector3(10, 8, 9), Color(0.58, 0.68, 0.70), true)
		_build_eye_simple_prop(zone, "FlutteringCurtain_%02d" % i, Vector3(-66.8, 5.3, -23 + float(i) * 16), 4.0, Vector3(0.16, 2.2, 2.4), Color(0.82, 0.92, 1.0, 0.48), false)
	_build_eye_simple_prop(zone, "LowGutterStreet", Vector3(-50, 0.04, 5), 0.0, Vector3(12, 0.08, 86), Color(0.18, 0.28, 0.30), true)
	_build_eye_simple_prop(zone, "CellarEntranceHouse", Vector3(-56, 0, 36), -6.0, Vector3(13, 4.5, 10), Color(0.30, 0.34, 0.34), true)
	_build_eye_simple_prop(zone, "WellCourtyard", Vector3(-72, 0, 42), 0.0, Vector3(18, 0.28, 18), Color(0.42, 0.46, 0.44), true)
	_build_eye_cylinder_prop(zone, "Fountain", Vector3(-66, 0.4, -36), 2.8, 0.8, Color(0.44, 0.72, 0.84, 0.72), false)
	_build_eye_cylinder_prop(zone, "SewerCover", Vector3(-48, 0.14, 5), 2.0, 0.12, Color(0.05, 0.06, 0.06), false)
	_build_eye_simple_prop(zone, "FishScale", Vector3(-44, 0.2, 16), 12.0, Vector3(1.8, 0.08, 1.0), Color(0.80, 0.92, 0.94, 0.48), false)
	_build_eye_simple_prop(zone, "WastePaper", Vector3(-51, 0.2, -10), 24.0, Vector3(2.2, 0.06, 1.2), Color(0.72, 0.72, 0.66), false)
	_build_eye_simple_prop(zone, "DrainPipe", Vector3(-60, 1.0, 2), 0.0, Vector3(0.8, 2.0, 0.8), Color(0.12, 0.14, 0.14), false)
	_build_eye_simple_prop(zone, "PebblePavement", Vector3(-50, 0.16, 28), 0.0, Vector3(16, 0.08, 20), Color(0.34, 0.36, 0.34), false)
	_build_eye_observation_node(zone, 1, Vector3(-50, 0, 6), 90.0)

func _build_eyes_baucis_cloud_stilt(parent: Node3D) -> void:
	var zone := _make_city_zone(parent, "ZoneC_BaucisCloudStilt")
	_build_eye_simple_prop(zone, "CloudLadderGate", Vector3(0, 0, 52), 0.0, Vector3(12, 7, 4), Color(0.74, 0.86, 0.88), true)
	for i in range(14):
		var x := -42.0 + float(i % 7) * 14.0
		var z := 70.0 + float(i / 7) * 22.0
		_build_eye_simple_prop(zone, "SlenderStiltFrame_%02d" % i, Vector3(x, 0, z), 0.0, Vector3(0.7, 20, 0.7), Color(0.70, 0.82, 0.84), true)
	_build_eye_simple_prop(zone, "CloudStiltCity", Vector3(0, 20, 82), 0.0, Vector3(88, 2.2, 42), Color(0.78, 0.90, 0.94, 0.68), true)
	for i in range(6):
		_build_eye_simple_prop(zone, "SkyDwellingPlatform_%02d" % i, Vector3(-35.0 + float(i) * 14.0, 21.4, 82.0 + float(i % 2) * 12.0), 0.0, Vector3(10, 2.8, 9), Color(0.56, 0.70, 0.74), true)
	_build_eye_simple_prop(zone, "EarthwatchTower", Vector3(50, 0, 86), 0.0, Vector3(9, 25, 9), Color(0.62, 0.78, 0.84), true)
	_build_eye_simple_prop(zone, "Telescope", Vector3(50, 26, 80), 0.0, Vector3(1.4, 1.0, 6), Color(0.82, 0.92, 0.96), false)
	_build_eye_simple_prop(zone, "LeafObservationPoint", Vector3(-40, 0.15, 58), 0.0, Vector3(8, 0.08, 5), Color(0.12, 0.35, 0.18), false)
	_build_eye_simple_prop(zone, "AntObservationPoint", Vector3(-28, 0.15, 64), 0.0, Vector3(5, 0.08, 3), Color(0.05, 0.04, 0.035), false)
	_build_eye_simple_prop(zone, "PerforatedPolygonShadow", Vector3(0, 0.14, 66), 0.0, Vector3(44, 0.06, 18), Color(0.02, 0.03, 0.03, 0.34), false)
	_build_eye_observation_node(zone, 2, Vector3(18, 0, 58), 0.0)

func _build_eyes_phyllis_bridge_window(parent: Node3D) -> void:
	var zone := _make_city_zone(parent, "ZoneD_PhyllisBridgeWindow")
	_build_eye_simple_prop(zone, "ManyBridgesCanalCity", Vector3(58, 0, 4), 0.0, Vector3(32, 0.3, 78), Color(0.34, 0.52, 0.58), true)
	_add_eye_water_plane(zone, "CanalMirrorStrip", Vector3(58, 0.08, 4), Vector2(22, 80), 0.0, Color(0.18, 0.56, 0.72, 0.62), 72.0)
	_build_eye_simple_prop(zone, "HumpbackBridge", Vector3(58, 1.0, -18), 0.0, Vector3(28, 2.0, 5), Color(0.62, 0.66, 0.62), true)
	_build_eye_simple_prop(zone, "CoveredBridge", Vector3(58, 2.2, 8), 0.0, Vector3(26, 4.4, 5), Color(0.46, 0.56, 0.60), true)
	_build_eye_simple_prop(zone, "HangingBridge", Vector3(58, 7.0, 34), 0.0, Vector3(30, 1.0, 4), Color(0.78, 0.86, 0.90, 0.58), true)
	for i in range(6):
		_build_eye_simple_prop(zone, "StainedWindowHouse_%02d" % i, Vector3(36.0 + float(i % 2) * 44.0, 0, -28.0 + float(i / 2) * 24.0), 0.0, Vector3(10, 7, 9), Color(0.56, 0.62, 0.62), true)
		_build_eye_simple_prop(zone, "RoseStainedWindow_%02d" % i, Vector3(36.0 + float(i % 2) * 44.0, 4.4, -32.5 + float(i / 2) * 24.0), 0.0, Vector3(4.2, 2.0, 0.16), Color(0.42, 0.74, 1.0, 0.58), false)
	_build_eye_simple_prop(zone, "OnionDomeTower", Vector3(90, 0, 42), 0.0, Vector3(9, 18, 9), Color(0.58, 0.66, 0.74), true)
	_build_eye_cylinder_prop(zone, "OnionSpire", Vector3(90, 19.5, 42), 4.2, 3.0, Color(0.42, 0.58, 0.86), false)
	_build_eye_simple_prop(zone, "CaperCastleWall", Vector3(88, 4, -42), 0.0, Vector3(42, 8, 3), Color(0.30, 0.42, 0.30), true)
	for i in range(5):
		_build_eye_simple_prop(zone, "MemoryRoutePoint_%02d" % i, Vector3(40.0 + float(i) * 8.0, 0.18, 44.0), 0.0, Vector3(1.6, 0.12, 1.6), Color(0.90, 0.92, 0.86, 0.44), false)
	_build_eye_observation_node(zone, 3, Vector3(58, 0, 6), -90.0)

func _build_eyes_moriana_two_face(parent: Node3D) -> void:
	var zone := _make_city_zone(parent, "ZoneE_MorianaTwoFace")
	_build_eye_simple_prop(zone, "AlabasterGate", Vector3(0, 0, 26), 0.0, Vector3(22, 11, 4), Color(0.82, 0.94, 1.0, 0.50), true)
	_build_eye_simple_prop(zone, "CoralColonnade", Vector3(-24, 0, 32), 0.0, Vector3(4, 8, 34), Color(0.78, 0.44, 0.42), true)
	_build_eye_simple_prop(zone, "SerpentinePediment", Vector3(0, 12, 25), 0.0, Vector3(24, 3, 3), Color(0.32, 0.58, 0.52), false)
	_build_eye_simple_prop(zone, "GlassVilla", Vector3(18, 0, 42), 6.0, Vector3(18, 8, 14), Color(0.64, 0.92, 1.0, 0.42), true)
	_build_eye_simple_prop(zone, "AquariumDanceHall", Vector3(-18, 0, 48), -6.0, Vector3(18, 7, 14), Color(0.30, 0.70, 0.86, 0.48), true)
	_build_eye_simple_prop(zone, "MedusaChandelier", Vector3(-18, 7.2, 48), 0.0, Vector3(3.2, 1.0, 3.2), Color(0.84, 0.96, 1.0, 0.62), false)
	_build_eye_simple_prop(zone, "SilverScaleDancer", Vector3(-18, 0, 44), 0.0, Vector3(1.2, 3.0, 0.8), Color(0.82, 0.88, 0.92), false)
	_build_eye_simple_prop(zone, "TwoSidedPaperWall", Vector3(0, 4, 64), 0.0, Vector3(54, 8, 0.8), Color(0.88, 0.90, 0.86, 0.62), true)
	_build_eye_simple_prop(zone, "RustedIronBackstreet", Vector3(0, 0, 78), 0.0, Vector3(54, 5, 16), Color(0.18, 0.10, 0.06), true)
	_build_eye_simple_prop(zone, "SootPipeAlley", Vector3(-24, 0, 86), 0.0, Vector3(8, 7, 28), Color(0.04, 0.04, 0.04), true)
	_build_eye_simple_prop(zone, "TinCanWallDistrict", Vector3(24, 0, 86), 0.0, Vector3(18, 6, 28), Color(0.16, 0.17, 0.16), true)
	for i in range(6):
		_build_eye_simple_prop(zone, "ScrapTinCan_%02d" % i, Vector3(16.0 + float(i % 3) * 4.0, 0.35, 76.0 + float(i / 3) * 5.0), 0.0, Vector3(1.2, 0.8, 1.2), Color(0.20, 0.20, 0.18), false)
	_build_eye_simple_prop(zone, "RustedIronSheet", Vector3(-4, 3.2, 78), 0.0, Vector3(12, 5, 0.2), Color(0.26, 0.12, 0.06), false)
	_build_eye_simple_prop(zone, "SackclothSheet", Vector3(-14, 3.0, 77.5), 0.0, Vector3(8, 4, 0.18), Color(0.34, 0.28, 0.18), false)
	_build_eye_simple_prop(zone, "NailedWoodenBoard", Vector3(8, 2.6, 77.2), 0.0, Vector3(10, 1.2, 0.18), Color(0.20, 0.12, 0.07), false)
	_build_eye_simple_prop(zone, "FadedSignboard", Vector3(24, 4.8, 72), 0.0, Vector3(9, 2.4, 0.18), Color(0.34, 0.34, 0.28), false)
	_build_eye_simple_prop(zone, "BrokenWickerChair", Vector3(32, 0, 82), 0.0, Vector3(2.4, 2.2, 1.8), Color(0.22, 0.14, 0.08), false)
	_build_eye_simple_prop(zone, "RottenBeamRope", Vector3(-28, 5.8, 83), 0.0, Vector3(0.35, 5.0, 0.35), Color(0.12, 0.08, 0.04), false)
	_build_eye_observation_node(zone, 4, Vector3(0, 0, 66), 180.0)

func _build_eyes_center_core(parent: Node3D) -> void:
	var zone := _make_city_zone(parent, "ZoneF_CentralEyeCore")
	_add_eye_water_plane(zone, "CentralEyeCore", Vector3(0, 0.08, 0), Vector2(32, 32), 0.0, Color(0.40, 0.76, 0.96, 0.62), 160.0)
	_build_eye_cylinder_prop(zone, "PupilRippleRing", Vector3(0, 0.22, 0), 15.0, 0.06, Color(0.84, 0.96, 1.0, 0.42), false)
	_build_eye_simple_prop(zone, "ColdWhiteGleam", Vector3(0, 1.2, 0), 0.0, Vector3(2.8, 2.8, 2.8), Color(0.88, 0.96, 1.0, 0.42), false)
	for i in range(5):
		var angle := TAU * float(i) / 5.0
		_build_eye_simple_prop(zone, "SightLine_%02d" % i, Vector3(cos(angle) * 7.5, 0.42, sin(angle) * 7.5), rad_to_deg(angle), Vector3(0.12, 0.10, 15.0), Color(0.78, 0.92, 1.0, 0.38), false)
	eye_goal_trigger = Area3D.new()
	eye_goal_trigger.name = "EyeGoalTrigger"
	eye_goal_trigger.position = Vector3(0, 1.0, 0)
	eye_goal_trigger.collision_layer = 0
	eye_goal_trigger.collision_mask = 2
	var shape := CollisionShape3D.new()
	var sphere := SphereShape3D.new()
	sphere.radius = 8.5
	shape.shape = sphere
	eye_goal_trigger.add_child(shape)
	eye_goal_trigger.body_entered.connect(_on_eye_goal_entered)
	eye_goal_trigger.body_exited.connect(_on_eye_goal_exited)
	manifested_city.add_child(eye_goal_trigger)

func _build_eyes_atmosphere(parent: Node3D) -> void:
	var atmosphere := Node3D.new()
	atmosphere.name = "EyesCityAtmosphere_StyleDirection"
	parent.add_child(atmosphere)
	atmosphere.add_child(_make_city_particle_layer("WaterMistParticles", 980, Vector2(0.16, 0.045), Vector3(112, 4.8, 112), Vector3(0.12, 0.03, -0.08), Color(0.58, 0.82, 0.92, 0.28), 0.04, 0.26, 100.0, 14.0))
	atmosphere.add_child(_make_city_particle_layer("LensShardParticles", 560, Vector2(0.11, 0.055), Vector3(110, 7.0, 110), Vector3(-0.08, 0.12, 0.06), Color(0.78, 0.94, 1.0, 0.36), 0.04, 0.24, 100.0, 12.0))
	atmosphere.add_child(_make_city_particle_layer("EyeLightParticles", 860, Vector2(0.045, 0.045), Vector3(108, 6.8, 108), Vector3(0.06, 0.10, 0.04), Color(0.70, 0.90, 1.0, 0.38), 0.03, 0.22, 100.0, 11.0))
	atmosphere.add_child(_make_city_particle_layer("PupilRippleParticles", 420, Vector2(0.22, 0.035), Vector3(96, 3.5, 96), Vector3(0.04, 0.03, 0.04), Color(0.86, 0.96, 1.0, 0.30), 0.02, 0.12, 100.0, 16.0))
	for i in range(9):
		var angle := TAU * float(i) / 9.0
		_add_eye_offset_veil(atmosphere, "MirrorOffsetVeil_%02d" % i, Vector3(cos(angle) * 46.0, 5.2 + float(i % 3) * 1.0, sin(angle) * 46.0), Vector2(68, 13 + float(i % 2) * 4), rad_to_deg(angle) + 90.0, Color(0.60, 0.86, 1.0, 0.22), 500.0 + float(i) * 5.1, 0.35)

func _add_eye_block(parent: Node3D, name: String, pos: Vector3, size: Vector3, yaw: float, color: Color, collision := true, seed := 0.0) -> Node3D:
	var box := CSGBox3D.new()
	box.name = name
	box.position = pos
	box.size = size
	box.rotation_degrees.y = yaw
	box.material = _eye_glass_material(color, color.a, 0.12 + eyes_city_style_intensity * 0.08)
	parent.add_child(box)
	if collision:
		_add_box_collision(name + "Collision", pos, size, yaw)
	return box

func _build_eye_simple_prop(parent: Node3D, name: String, pos: Vector3, yaw: float, size: Vector3, color: Color, collision := false) -> Node3D:
	var asset := _make_city_asset(parent, name, pos, yaw)
	_add_local_eye_block(asset, "WhiteboxReplaceRoot", Vector3(0, size.y * 0.5, 0), size, 0.0, color, collision)
	return asset

func _add_local_eye_block(asset: Node3D, part_name: String, local_pos: Vector3, size: Vector3, local_yaw: float, color: Color, collision := true) -> Node3D:
	var global_pos := _asset_global_pos(asset, local_pos)
	var global_yaw := _asset_global_yaw(asset, local_yaw)
	var box := CSGBox3D.new()
	box.name = part_name
	box.position = local_pos
	box.size = size
	box.rotation_degrees.y = local_yaw
	box.material = _eye_glass_material(color, color.a, 0.12 + eyes_city_style_intensity * 0.08)
	asset.add_child(box)
	if collision:
		_add_box_collision("%s_%sCollision" % [asset.name, part_name], global_pos, size, global_yaw)
	return box

func _build_eye_cylinder_prop(parent: Node3D, name: String, pos: Vector3, radius: float, height: float, color: Color, collision := false) -> Node3D:
	var cylinder := CSGCylinder3D.new()
	cylinder.name = name
	cylinder.radius = radius
	cylinder.height = height
	cylinder.sides = 48
	cylinder.position = pos
	cylinder.material = _eye_glass_material(color, color.a, 0.16 + eyes_city_style_intensity * 0.08)
	parent.add_child(cylinder)
	if collision:
		_add_box_collision(name + "Collision", pos, Vector3(radius * 2.0, height, radius * 2.0), 0.0)
	return cylinder

func _add_eye_water_plane(parent: Node3D, name: String, pos: Vector3, size: Vector2, yaw: float, color: Color, seed: float) -> void:
	var mesh_instance := MeshInstance3D.new()
	mesh_instance.name = name
	var plane := PlaneMesh.new()
	plane.size = size
	mesh_instance.mesh = plane
	mesh_instance.position = pos
	mesh_instance.rotation_degrees = Vector3(0.0, yaw, 0.0)
	mesh_instance.material_override = _eye_mirror_water_material(color, color.a, seed, 0.08, 0.44)
	parent.add_child(mesh_instance)

func _build_stacked_balcony_house(parent: Node3D, name: String, pos: Vector3, yaw: float) -> void:
	var asset := _make_city_asset(parent, name, pos, yaw)
	_add_local_eye_block(asset, "HouseBody", Vector3(0, 4.0, 0), Vector3(10, 8, 8), 0.0, Color(0.52, 0.66, 0.70), true)
	for i in range(3):
		_add_local_eye_block(asset, "StackedBalcony_%02d" % i, Vector3(0, 2.0 + float(i) * 2.2, -4.6), Vector3(10.8, 0.32, 1.6), 0.0, Color(0.82, 0.94, 0.98, 0.54), false)

func _build_reflected_lake_city(parent: Node3D, pos: Vector3, yaw: float) -> void:
	var asset := _make_city_asset(parent, "ReflectedLakeCity", pos, yaw)
	for i in range(7):
		_add_local_eye_block(asset, "InvertedFacade_%02d" % i, Vector3(-42.0 + float(i) * 14.0, -2.5, float(i % 2) * 5.0), Vector3(9, 5, 7), 0.0, Color(0.30, 0.64, 0.82, 0.28), false)
	_add_eye_offset_veil(asset, "ReflectionMisalignmentLayer", Vector3(0, 1.2, 0), Vector2(92, 12), 0.0, Color(0.58, 0.88, 1.0, 0.20), 540.0, 0.55)

func _eye_observation_color(node_index: int) -> Color:
	return EYE_OBSERVATION_COLORS[clampi(node_index, 0, EYE_OBSERVATION_COLORS.size() - 1)]

func _build_eye_observation_node(parent: Node3D, node_index: int, pos: Vector3, yaw: float) -> void:
	var data: Array = EYE_OBSERVATION_NODES[node_index]
	var color := _eye_observation_color(node_index)
	var asset := _make_city_asset(parent, String(data[0]), pos, yaw)
	_add_local_eye_block(asset, "ObservationPillar", Vector3(0, 2.1, 0), Vector3(1.6, 4.2, 1.6), 0.0, Color(0.10, 0.18, 0.22), true)
	_add_local_eye_block(asset, "ActiveEyePanel", Vector3(0, 4.7, -0.35), Vector3(5.2, 2.4, 0.18), 0.0, color, false)
	var resolved := _add_local_eye_block(asset, "ResolvedBlindPanel", Vector3(0, 4.7, -0.58), Vector3(5.2, 2.4, 0.18), 0.0, Color(0.92, 0.96, 1.0, 0.42), false)
	resolved.visible = false
	_add_eye_observation_glow(asset, color)
	while eye_observation_visuals.size() <= node_index:
		eye_observation_visuals.append(null)
	eye_observation_visuals[node_index] = asset

	var area := Area3D.new()
	area.name = "%sArea" % String(data[0])
	area.position = pos + Vector3(0, 1.3, 0)
	area.collision_layer = 0
	area.collision_mask = 2
	var shape := CollisionShape3D.new()
	var sphere := SphereShape3D.new()
	sphere.radius = 4.4
	shape.shape = sphere
	area.add_child(shape)
	area.body_entered.connect(func(body: Node3D): _on_eye_observation_entered(body, node_index))
	area.body_exited.connect(func(body: Node3D): _on_eye_observation_exited(body, node_index))
	manifested_city.add_child(area)
	while eye_observation_areas.size() <= node_index:
		eye_observation_areas.append(null)
	eye_observation_areas[node_index] = area

func _add_eye_observation_glow(asset: Node3D, color: Color) -> void:
	var halo := CSGCylinder3D.new()
	halo.name = "EyeObservationGlow"
	halo.radius = 3.4
	halo.height = 0.04
	halo.sides = 48
	halo.position = Vector3(0, 0.12, 0)
	halo.material = _emissive_mat(color, 0.30, eye_observation_glow_energy)
	asset.add_child(halo)
	var light := OmniLight3D.new()
	light.name = "EyeObservationLight"
	light.position = Vector3(0, 4.3, 0)
	light.light_color = color
	light.light_energy = eye_observation_glow_energy
	light.omni_range = 8.5
	asset.add_child(light)
	var particles := GPUParticles3D.new()
	particles.name = "EyeObservationParticles"
	particles.amount = int(maxf(1.0, 72.0 * eye_observation_particle_scale))
	particles.lifetime = 2.6
	particles.visibility_aabb = AABB(Vector3(-5, -1, -5), Vector3(10, 8, 10))
	var mesh := QuadMesh.new()
	mesh.size = Vector2(0.08, 0.08)
	particles.draw_pass_1 = mesh
	var process := ParticleProcessMaterial.new()
	process.emission_shape = ParticleProcessMaterial.EMISSION_SHAPE_SPHERE
	process.emission_sphere_radius = 2.7
	process.gravity = Vector3.ZERO
	process.initial_velocity_min = 0.04
	process.initial_velocity_max = 0.28
	process.spread = 100.0
	process.color = Color(color.r, color.g, color.b, 0.72)
	particles.process_material = process
	particles.position = Vector3(0, 3.2, 0)
	particles.emitting = true
	asset.add_child(particles)

func _set_eye_observation_visual_state(node_index: int, resolved: bool) -> void:
	if node_index < 0 or node_index >= eye_observation_visuals.size():
		return
	var asset := eye_observation_visuals[node_index]
	if asset == null:
		return
	var active := asset.get_node_or_null("ActiveEyePanel")
	if active != null:
		active.visible = not resolved
	var blank := asset.get_node_or_null("ResolvedBlindPanel")
	if blank != null:
		blank.visible = resolved
	for name in ["EyeObservationGlow", "EyeObservationLight", "EyeObservationParticles"]:
		var child := asset.get_node_or_null(name)
		if child != null:
			child.visible = not resolved

func _build_names_city_whitebox(parent: Node3D) -> void:
	_build_names_terrain(parent)
	_build_names_aglaura_grey_city(parent)
	_build_names_leandra_household(parent)
	_build_names_pyrrha_wrong_name(parent)
	_build_names_clarice_reassembled(parent)
	_build_names_irene_overlook(parent)
	_build_names_center_core(parent)
	_build_names_atmosphere(parent)

func _build_names_terrain(parent: Node3D) -> void:
	var terrain := _make_city_zone(parent, "NamesTerrain_HighlandMisnamedValley")
	_add_name_block(terrain, "StoneGreyHighlandGround", Vector3(0, -0.06, 0), Vector3(238, 0.12, 238), 0.0, Color(0.48, 0.47, 0.42), true, 0.0)
	_add_name_block(terrain, "YellowDustPyrrhaRoad", Vector3(-44, 0.025, -30), Vector3(46, 0.05, 64), -8.0, Color(0.62, 0.52, 0.34), true, 12.0)
	_add_name_block(terrain, "CentralArchiveAxis", Vector3(0, 0.04, -16), Vector3(10, 0.06, 156), 0.0, Color(0.58, 0.56, 0.49), true, 24.0)
	_add_name_block(terrain, "CrossNamedRoad", Vector3(0, 0.045, 5), Vector3(142, 0.06, 8), 0.0, Color(0.54, 0.53, 0.48), true, 36.0)
	_add_name_block(terrain, "IreneValleyMistFloor", Vector3(0, -0.02, 92), Vector3(128, 0.06, 36), 0.0, Color(0.34, 0.36, 0.34, 0.44), false, 48.0)

func _build_names_aglaura_grey_city(parent: Node3D) -> void:
	var zone := _make_city_zone(parent, "ZoneA_AglauraLegendGreyCity")
	_build_name_simple_prop(zone, "LegendGate", Vector3(0, 0, -88), 0.0, Vector3(28, 12, 4), Color(0.46, 0.44, 0.39), true)
	_build_name_simple_prop(zone, "LegendGateInscription", Vector3(0, 8.8, -90.2), 0.0, Vector3(22, 2.0, 0.18), Color(0.82, 0.78, 0.62, 0.72), false)
	_build_name_simple_prop(zone, "SpokenPlaza", Vector3(0, 0, -62), 0.0, Vector3(42, 0.35, 32), Color(0.52, 0.50, 0.45), true)
	for i in range(12):
		var side := -1.0 if i % 2 == 0 else 1.0
		var z := -82.0 + float(i / 2) * 7.6
		_build_name_simple_prop(zone, "ProverbCorridor_%02d" % i, Vector3(side * 17.0, 0, z), 0.0, Vector3(8, 4.2, 1.2), Color(0.42, 0.41, 0.38), true)
		_build_name_simple_prop(zone, "MoralProverbSign_%02d" % i, Vector3(side * 17.0, 3.0, z - 0.72), 0.0, Vector3(6.2, 1.1, 0.12), Color(0.78, 0.74, 0.58, 0.60), false)
	for i in range(10):
		var x := -45.0 + float(i % 5) * 22.0
		var z := -76.0 + float(i / 5) * 14.0
		_build_name_simple_prop(zone, "NamelessGreyCity_%02d" % i, Vector3(x, 0, z), float(i % 4) * 3.5, Vector3(10, 5 + float(i % 3) * 1.4, 9), Color(0.40, 0.40, 0.38), true)
	_build_name_simple_prop(zone, "LegendStele", Vector3(-23, 0, -58), 10.0, Vector3(2.8, 5.8, 0.8), Color(0.38, 0.37, 0.34), true)
	_build_name_simple_prop(zone, "SealedWordSlab", Vector3(18, 0.18, -58), -8.0, Vector3(9, 0.12, 5), Color(0.58, 0.54, 0.42, 0.58), false)
	_build_name_simple_prop(zone, "RareGloryGleam", Vector3(31, 1.4, -71), 0.0, Vector3(2.5, 2.5, 2.5), Color(1.0, 0.82, 0.30, 0.46), false)
	_build_name_seal_node(zone, 0, Vector3(0, 0, -54), 0.0)

func _build_names_leandra_household(parent: Node3D) -> void:
	var zone := _make_city_zone(parent, "ZoneB_LeandraHouseholdSpirits")
	for i in range(6):
		var x := 44.0 + float(i % 2) * 22.0
		var z := -30.0 + float(i / 2) * 20.0
		_build_name_simple_prop(zone, "PenatesDoorHouse_%02d" % i, Vector3(x, 0, z), -8.0 + float(i) * 3.0, Vector3(13, 5.2, 10), Color(0.46, 0.41, 0.35), true)
		_build_name_simple_prop(zone, "UmbrellaHall_%02d" % i, Vector3(x - 4.2, 1.0, z - 5.2), 0.0, Vector3(2.4, 2.0, 1.2), Color(0.30, 0.25, 0.20), false)
		_build_name_simple_prop(zone, "PenatesSpirit_%02d" % i, Vector3(x + 4.4, 2.4, z - 5.4), 0.0, Vector3(0.8, 1.2, 0.25), Color(0.86, 0.78, 0.54, 0.50), false)
	_build_name_simple_prop(zone, "LaresKitchen", Vector3(74, 0, 20), 8.0, Vector3(15, 4.6, 12), Color(0.40, 0.34, 0.28), true)
	_build_name_simple_prop(zone, "Cookware", Vector3(70, 1.4, 14), 0.0, Vector3(3, 1.0, 1.8), Color(0.22, 0.20, 0.18), false)
	_build_name_simple_prop(zone, "LaresSpirit", Vector3(76, 2.0, 14), 0.0, Vector3(0.9, 1.1, 0.25), Color(0.80, 0.74, 0.58, 0.48), false)
	_build_name_simple_prop(zone, "FireplaceHoodHouse", Vector3(44, 0, 38), -4.0, Vector3(16, 5.5, 11), Color(0.43, 0.35, 0.30), true)
	_build_name_simple_prop(zone, "BroomCloset", Vector3(58, 0, 42), 0.0, Vector3(5, 3.4, 4), Color(0.30, 0.25, 0.20), true)
	_build_name_simple_prop(zone, "EavePipeHouse", Vector3(70, 0, -8), 0.0, Vector3(14, 7.5, 9), Color(0.42, 0.40, 0.36), true)
	_build_name_simple_prop(zone, "RustedTinCan", Vector3(83, 0.35, 32), 0.0, Vector3(1.3, 0.7, 1.3), Color(0.42, 0.20, 0.10), false)
	_build_name_seal_node(zone, 1, Vector3(58, 0, 6), -90.0)

func _build_names_pyrrha_wrong_name(parent: Node3D) -> void:
	var zone := _make_city_zone(parent, "ZoneC_PyrrhaWrongName")
	_build_name_simple_prop(zone, "ImaginedCastle", Vector3(-72, 0, -48), 10.0, Vector3(24, 14, 16), Color(0.50, 0.48, 0.44, 0.62), true)
	_build_name_cylinder_prop(zone, "ImaginedCastleTowerA", Vector3(-84, 7.5, -58), 3.0, 15.0, Color(0.48, 0.46, 0.42, 0.62), true)
	_build_name_cylinder_prop(zone, "ImaginedCastleTowerB", Vector3(-60, 7.5, -38), 3.0, 15.0, Color(0.48, 0.46, 0.42, 0.62), true)
	_build_name_cylinder_prop(zone, "DeepWellMouth", Vector3(-72, 0.35, -28), 5.2, 0.7, Color(0.18, 0.16, 0.13), true)
	_build_name_cylinder_prop(zone, "DeepWellDarkness", Vector3(-72, 0.78, -28), 4.2, 0.08, Color(0.02, 0.018, 0.014), false)
	_build_name_simple_prop(zone, "DuneStraightStreet", Vector3(-42, 0.12, -25), -8.0, Vector3(10, 0.16, 72), Color(0.68, 0.56, 0.34), true)
	for i in range(5):
		_build_name_simple_prop(zone, "SandDune_%02d" % i, Vector3(-62.0 + float(i) * 14.0, 0.3, -2.0 + sin(float(i)) * 4.0), -12.0 + float(i) * 5.0, Vector3(13, 0.6, 5.4), Color(0.72, 0.60, 0.38, 0.70), false)
	_build_name_simple_prop(zone, "TimberYard", Vector3(-31, 0, -8), 4.0, Vector3(22, 2.4, 13), Color(0.38, 0.25, 0.15), true)
	for i in range(6):
		_build_name_simple_prop(zone, "TimberStack_%02d" % i, Vector3(-39.0 + float(i) * 3.6, 1.9, -11.5), 0.0, Vector3(2.8, 1.0, 9), Color(0.34, 0.22, 0.12), false)
	_build_name_simple_prop(zone, "CarpentryWorkshop", Vector3(-24, 0, 10), -6.0, Vector3(16, 5.5, 12), Color(0.42, 0.31, 0.20), true)
	_build_name_simple_prop(zone, "PumpHouse", Vector3(-55, 0, 18), 10.0, Vector3(10, 4.2, 8), Color(0.48, 0.43, 0.34), true)
	_build_name_cylinder_prop(zone, "PumpWheel", Vector3(-50, 2.8, 14), 2.2, 0.35, Color(0.25, 0.25, 0.22), false)
	_build_name_simple_prop(zone, "WrongNamePlate", Vector3(-62, 3.4, -37), 10.0, Vector3(7, 1.7, 0.18), Color(0.94, 0.72, 0.28, 0.58), false)
	_build_name_seal_node(zone, 2, Vector3(-52, 0, -20), 72.0)

func _build_names_clarice_reassembled(parent: Node3D) -> void:
	var zone := _make_city_zone(parent, "ZoneD_ClariceReassembledRelics")
	_build_name_simple_prop(zone, "DecayedPalace", Vector3(-34, 0, 42), -7.0, Vector3(32, 12, 18), Color(0.42, 0.39, 0.34), true)
	_build_name_simple_prop(zone, "CollapsedPalaceWing", Vector3(-54, 3.5, 52), 16.0, Vector3(20, 7, 7), Color(0.34, 0.32, 0.29), true)
	_build_name_simple_prop(zone, "CellarRefuge", Vector3(-62, 0, 30), 0.0, Vector3(16, 3.2, 12), Color(0.22, 0.20, 0.18), true)
	_build_name_simple_prop(zone, "NewClariceHut", Vector3(-12, 0, 46), 8.0, Vector3(11, 3.6, 9), Color(0.46, 0.34, 0.22), true)
	_build_name_simple_prop(zone, "DrainageSlum", Vector3(-12, 0, 70), 0.0, Vector3(34, 3.8, 16), Color(0.20, 0.18, 0.15), true)
	_build_name_simple_prop(zone, "PigeonCoopHouse", Vector3(-46, 0, 72), -8.0, Vector3(13, 9, 9), Color(0.33, 0.31, 0.28), true)
	_build_name_simple_prop(zone, "CapitalMuseum", Vector3(18, 0, 52), 6.0, Vector3(24, 8, 16), Color(0.56, 0.54, 0.48), true)
	_build_name_simple_prop(zone, "GlassDisplayHall", Vector3(18, 0, 68), 0.0, Vector3(20, 5.4, 10), Color(0.74, 0.78, 0.72, 0.36), true)
	_build_name_simple_prop(zone, "HenhouseCapitalHouse", Vector3(42, 0, 62), -12.0, Vector3(12, 5, 10), Color(0.48, 0.42, 0.30), true)
	for i in range(5):
		_build_name_simple_prop(zone, "MixedRelicFragment_%02d" % i, Vector3(-8.0 + float(i) * 10.0, 0.8, 37.0 + float(i % 2) * 11.0), float(i) * 14.0, Vector3(3.8, 1.6, 2.4), Color(0.70, 0.66, 0.52, 0.62), false)
	_build_name_cylinder_prop(zone, "MarbleUrn", Vector3(15, 1.0, 66), 1.6, 2.0, Color(0.78, 0.76, 0.68), false)
	_build_name_simple_prop(zone, "GreekCapital", Vector3(23, 1.6, 66), 0.0, Vector3(4.0, 1.6, 3.0), Color(0.72, 0.70, 0.62), false)
	_build_name_simple_prop(zone, "VelvetCushion", Vector3(18, 1.2, 70), 0.0, Vector3(4.5, 0.35, 2.8), Color(0.42, 0.08, 0.10), false)
	_build_name_seal_node(zone, 3, Vector3(-10, 0, 58), 180.0)

func _build_names_irene_overlook(parent: Node3D) -> void:
	var zone := _make_city_zone(parent, "ZoneE_IreneDistantOverlook")
	_build_name_simple_prop(zone, "PlateauViewpoint", Vector3(0, 0, 86), 0.0, Vector3(42, 1.2, 16), Color(0.44, 0.43, 0.38), true)
	_build_name_simple_prop(zone, "ViewpointRailing", Vector3(0, 2.3, 94), 0.0, Vector3(44, 1.2, 0.8), Color(0.34, 0.32, 0.28), false)
	for i in range(12):
		var x := -48.0 + float(i % 6) * 19.0
		var z := 108.0 + float(i / 6) * 8.0
		_build_name_simple_prop(zone, "RoseHousingDistrict_%02d" % i, Vector3(x, 0, z), 0.0, Vector3(10, 5.0 + float(i % 3), 6), Color(0.58, 0.34, 0.36, 0.42), false)
		_build_name_simple_prop(zone, "RoseLitWindow_%02d" % i, Vector3(x, 3.4, z - 3.1), 0.0, Vector3(4, 1.2, 0.12), Color(1.0, 0.48, 0.42, 0.62), false)
	_build_name_simple_prop(zone, "SparseLightAlley", Vector3(0, 0.12, 104), 0.0, Vector3(9, 0.10, 38), Color(0.30, 0.30, 0.28, 0.50), false)
	_build_name_simple_prop(zone, "SignalFireTower", Vector3(52, 0, 96), 0.0, Vector3(8, 18, 8), Color(0.34, 0.32, 0.30), true)
	_build_name_simple_prop(zone, "SignalFireGlow", Vector3(52, 19.5, 96), 0.0, Vector3(3.8, 2.4, 3.8), Color(1.0, 0.22, 0.08, 0.62), false)
	_build_name_simple_prop(zone, "ValleyMistCity", Vector3(-48, 0, 104), 0.0, Vector3(34, 7, 10), Color(0.40, 0.44, 0.42, 0.28), false)
	_build_name_simple_prop(zone, "PlateauShepherd", Vector3(-32, 0, 88), 0.0, Vector3(1.0, 2.4, 0.8), Color(0.30, 0.26, 0.20), false)
	_build_name_simple_prop(zone, "BirdNet", Vector3(-42, 1.4, 91), 10.0, Vector3(7, 0.12, 4), Color(0.72, 0.68, 0.54, 0.42), false)
	_build_name_simple_prop(zone, "HerbHermit", Vector3(32, 0, 88), 0.0, Vector3(1.2, 2.2, 0.9), Color(0.28, 0.32, 0.24), false)
	_build_name_seal_node(zone, 4, Vector3(0, 0, 82), 180.0)

func _build_names_center_core(parent: Node3D) -> void:
	var zone := _make_city_zone(parent, "ZoneF_CentralNamingCore")
	_build_name_cylinder_prop(zone, "ArchiveRingFloor", Vector3(0, 0.10, 0), 18.0, 0.20, Color(0.48, 0.46, 0.40), true)
	for i in range(10):
		var angle := TAU * float(i) / 10.0
		_build_name_simple_prop(zone, "ArchiveShelf_%02d" % i, Vector3(cos(angle) * 17.0, 0, sin(angle) * 17.0), rad_to_deg(angle) + 90.0, Vector3(5.0, 5.6, 1.1), Color(0.36, 0.30, 0.22), true)
		_build_name_simple_prop(zone, "BlankNamePlate_%02d" % i, Vector3(cos(angle) * 11.0, 2.1, sin(angle) * 11.0), rad_to_deg(angle) + 90.0, Vector3(3.4, 1.2, 0.12), Color(0.82, 0.78, 0.62, 0.38), false)
	_build_name_simple_prop(zone, "VanishedNameStele", Vector3(0, 0, 0), 0.0, Vector3(4.4, 8.4, 1.2), Color(0.30, 0.30, 0.28), true)
	_build_name_simple_prop(zone, "VanishedNameInscription", Vector3(0, 5.2, -0.82), 0.0, Vector3(5.8, 2.0, 0.14), Color(0.90, 0.86, 0.72, 0.44), false)
	_build_name_simple_prop(zone, "MisnamedMistCore", Vector3(0, 2.0, 0), 0.0, Vector3(22, 3.2, 22), Color(0.86, 0.84, 0.74, 0.14), false)
	name_goal_trigger = Area3D.new()
	name_goal_trigger.name = "NameGoalTrigger"
	name_goal_trigger.position = Vector3(0, 1.0, 0)
	name_goal_trigger.collision_layer = 0
	name_goal_trigger.collision_mask = 2
	var shape := CollisionShape3D.new()
	var sphere := SphereShape3D.new()
	sphere.radius = 8.5
	shape.shape = sphere
	name_goal_trigger.add_child(shape)
	name_goal_trigger.body_entered.connect(_on_name_goal_entered)
	name_goal_trigger.body_exited.connect(_on_name_goal_exited)
	manifested_city.add_child(name_goal_trigger)

func _build_names_atmosphere(parent: Node3D) -> void:
	var atmosphere := Node3D.new()
	atmosphere.name = "NamesCityAtmosphere_StyleDirection"
	parent.add_child(atmosphere)
	atmosphere.add_child(_make_city_particle_layer("WhiteDustParticles", 1150, Vector2(0.10, 0.035), Vector3(112, 5.2, 112), Vector3(0.04, 0.08, -0.03), Color(0.84, 0.82, 0.72, 0.30), 0.03, 0.18, 100.0, 13.0))
	atmosphere.add_child(_make_city_particle_layer("CarvedNameChipParticles", 760, Vector2(0.08, 0.045), Vector3(108, 4.8, 108), Vector3(-0.05, 0.10, 0.04), Color(0.72, 0.68, 0.56, 0.34), 0.04, 0.22, 100.0, 12.0))
	atmosphere.add_child(_make_city_particle_layer("InkLineParticles", 520, Vector2(0.20, 0.035), Vector3(104, 5.5, 104), Vector3(0.08, 0.04, 0.02), Color(0.08, 0.07, 0.06, 0.28), 0.03, 0.18, 100.0, 15.0))
	atmosphere.add_child(_make_city_particle_layer("FloatingNameFragments", 640, Vector2(0.16, 0.05), Vector3(110, 6.5, 110), Vector3(0.03, 0.06, 0.04), Color(0.92, 0.86, 0.64, 0.28), 0.03, 0.20, 100.0, 16.0))
	atmosphere.add_child(_make_city_particle_layer("RelicReassemblyGlowParticles", 420, Vector2(0.10, 0.10), Vector3(78, 5.2, 84), Vector3(0.02, 0.08, 0.02), Color(0.95, 0.82, 0.42, 0.26), 0.02, 0.16, 100.0, 11.0))
	for i in range(8):
		var angle := TAU * float(i) / 8.0
		_add_name_text_veil(atmosphere, "MisnamedWordVeil_%02d" % i, Vector3(cos(angle) * 48.0, 5.0 + float(i % 3) * 1.0, sin(angle) * 48.0), Vector2(68, 12 + float(i % 2) * 4), rad_to_deg(angle) + 90.0, Color(0.84, 0.80, 0.62, 0.22), 700.0 + float(i) * 5.3, 0.42)

func _add_name_block(parent: Node3D, name: String, pos: Vector3, size: Vector3, yaw: float, color: Color, collision := true, seed := 0.0) -> Node3D:
	var box := CSGBox3D.new()
	box.name = name
	box.position = pos
	box.size = size
	box.rotation_degrees.y = yaw
	box.material = _name_carved_stone_material(color, color.a, seed)
	parent.add_child(box)
	if collision:
		_add_box_collision(name + "Collision", pos, size, yaw)
	return box

func _build_name_simple_prop(parent: Node3D, name: String, pos: Vector3, yaw: float, size: Vector3, color: Color, collision := false) -> Node3D:
	var asset := _make_city_asset(parent, name, pos, yaw)
	_add_local_name_block(asset, "WhiteboxReplaceRoot", Vector3(0, size.y * 0.5, 0), size, 0.0, color, collision)
	return asset

func _add_local_name_block(asset: Node3D, part_name: String, local_pos: Vector3, size: Vector3, local_yaw: float, color: Color, collision := true) -> Node3D:
	var global_pos := _asset_global_pos(asset, local_pos)
	var global_yaw := _asset_global_yaw(asset, local_yaw)
	var box := CSGBox3D.new()
	box.name = part_name
	box.position = local_pos
	box.size = size
	box.rotation_degrees.y = local_yaw
	box.material = _name_carved_stone_material(color, color.a, global_pos.x * 0.31 + global_pos.z * 0.17)
	asset.add_child(box)
	if collision:
		_add_box_collision("%s_%sCollision" % [asset.name, part_name], global_pos, size, global_yaw)
	return box

func _build_name_cylinder_prop(parent: Node3D, name: String, pos: Vector3, radius: float, height: float, color: Color, collision := false) -> Node3D:
	var cylinder := CSGCylinder3D.new()
	cylinder.name = name
	cylinder.radius = radius
	cylinder.height = height
	cylinder.sides = 32
	cylinder.position = pos
	cylinder.material = _name_carved_stone_material(color, color.a, pos.x * 0.21 + pos.z * 0.37)
	parent.add_child(cylinder)
	if collision:
		_add_box_collision(name + "Collision", pos, Vector3(radius * 2.0, height, radius * 2.0), 0.0)
	return cylinder

func _name_seal_color(node_index: int) -> Color:
	return NAME_SEAL_COLORS[clampi(node_index, 0, NAME_SEAL_COLORS.size() - 1)]

func _build_name_seal_node(parent: Node3D, node_index: int, pos: Vector3, yaw: float) -> void:
	var data: Array = NAME_SEAL_NODES[node_index]
	var color := _name_seal_color(node_index)
	var asset := _make_city_asset(parent, String(data[0]), pos, yaw)
	_add_local_name_block(asset, "SealColumn", Vector3(0, 2.2, 0), Vector3(1.8, 4.4, 1.1), 0.0, Color(0.30, 0.29, 0.26), true)
	_add_local_name_block(asset, "ActiveNamePlate", Vector3(0, 4.8, -0.62), Vector3(5.6, 2.3, 0.16), 0.0, color, false)
	var resolved := _add_local_name_block(asset, "ResolvedEmptyNamePlate", Vector3(0, 4.8, -0.82), Vector3(5.6, 2.3, 0.16), 0.0, Color(0.86, 0.84, 0.76, 0.30), false)
	resolved.visible = false
	_add_name_seal_glow(asset, color)
	while name_seal_visuals.size() <= node_index:
		name_seal_visuals.append(null)
	name_seal_visuals[node_index] = asset

	var area := Area3D.new()
	area.name = "%sArea" % String(data[0])
	area.position = pos + Vector3(0, 1.3, 0)
	area.collision_layer = 0
	area.collision_mask = 2
	var shape := CollisionShape3D.new()
	var sphere := SphereShape3D.new()
	sphere.radius = 4.8
	shape.shape = sphere
	area.add_child(shape)
	area.body_entered.connect(func(body: Node3D): _on_name_seal_entered(body, node_index))
	area.body_exited.connect(func(body: Node3D): _on_name_seal_exited(body, node_index))
	manifested_city.add_child(area)
	while name_seal_areas.size() <= node_index:
		name_seal_areas.append(null)
	name_seal_areas[node_index] = area

func _add_name_seal_glow(asset: Node3D, color: Color) -> void:
	var halo := CSGCylinder3D.new()
	halo.name = "NameSealGlow"
	halo.radius = 3.5
	halo.height = 0.04
	halo.sides = 48
	halo.position = Vector3(0, 0.12, 0)
	halo.material = _emissive_mat(color, 0.26, name_seal_glow_energy)
	asset.add_child(halo)
	var light := OmniLight3D.new()
	light.name = "NameSealLight"
	light.position = Vector3(0, 4.3, 0)
	light.light_color = color
	light.light_energy = name_seal_glow_energy
	light.omni_range = 8.0
	asset.add_child(light)
	var particles := GPUParticles3D.new()
	particles.name = "NameSealParticles"
	particles.amount = int(maxf(1.0, 76.0 * name_seal_particle_scale))
	particles.lifetime = 3.0
	particles.visibility_aabb = AABB(Vector3(-5, -1, -5), Vector3(10, 8, 10))
	var mesh := QuadMesh.new()
	mesh.size = Vector2(0.10, 0.035)
	particles.draw_pass_1 = mesh
	var process := ParticleProcessMaterial.new()
	process.emission_shape = ParticleProcessMaterial.EMISSION_SHAPE_BOX
	process.emission_box_extents = Vector3(2.6, 2.8, 0.35)
	process.gravity = Vector3.ZERO
	process.initial_velocity_min = 0.02
	process.initial_velocity_max = 0.20
	process.spread = 80.0
	process.color = Color(color.r, color.g, color.b, 0.68)
	particles.process_material = process
	particles.position = Vector3(0, 3.1, -0.55)
	particles.emitting = true
	asset.add_child(particles)

func _set_name_seal_visual_state(node_index: int, resolved: bool) -> void:
	if node_index < 0 or node_index >= name_seal_visuals.size():
		return
	var asset := name_seal_visuals[node_index]
	if asset == null:
		return
	var active := asset.get_node_or_null("ActiveNamePlate")
	if active != null:
		active.visible = not resolved
	var blank := asset.get_node_or_null("ResolvedEmptyNamePlate")
	if blank != null:
		blank.visible = resolved
	for name in ["NameSealGlow", "NameSealLight", "NameSealParticles"]:
		var child := asset.get_node_or_null(name)
		if child != null:
			child.visible = not resolved

func _build_dead_city_whitebox(parent: Node3D) -> void:
	_build_dead_terrain(parent)
	_build_dead_melania_role_plaza(parent)
	_build_dead_adelma_dusk_dock(parent)
	_build_dead_eusapia_sister_city(parent)
	_build_dead_argia_buried_city(parent)
	_build_dead_laudomia_triple_city(parent)
	_build_dead_center_core(parent)
	_build_dead_atmosphere(parent)

func _build_dead_terrain(parent: Node3D) -> void:
	var terrain := _make_city_zone(parent, "DeadTerrain_UndergroundSaltValley")
	_add_dead_block(terrain, "BoneSaltGround", Vector3(0, -0.06, 0), Vector3(238, 0.12, 238), 0.0, Color(0.48, 0.47, 0.43), true, 0.0)
	_add_dead_block(terrain, "DuskDockCauseway", Vector3(48, 0.025, -28), Vector3(38, 0.05, 90), 0.0, Color(0.34, 0.34, 0.32), true, 13.0)
	_add_dead_block(terrain, "BuriedDustFloor", Vector3(-52, 0.015, 20), Vector3(54, 0.05, 90), -4.0, Color(0.32, 0.29, 0.24), true, 27.0)
	_add_dead_block(terrain, "CentralDeathAxis", Vector3(0, 0.04, -12), Vector3(10, 0.06, 160), 0.0, Color(0.40, 0.40, 0.38), true, 38.0)
	_add_dead_block(terrain, "LaudomiaGraveRoad", Vector3(0, 0.05, 75), Vector3(132, 0.06, 11), 0.0, Color(0.42, 0.42, 0.39), true, 52.0)

func _build_dead_melania_role_plaza(parent: Node3D) -> void:
	var zone := _make_city_zone(parent, "ZoneA_MelaniaRolePlaza")
	_build_dead_cylinder_prop(zone, "RolePlaza", Vector3(0, 0.12, -78), 27.0, 0.24, Color(0.44, 0.43, 0.40), true)
	_build_dead_cylinder_prop(zone, "RotatingStage", Vector3(0, 0.7, -78), 8.0, 1.2, Color(0.34, 0.32, 0.30), true)
	for i in range(12):
		var angle := TAU * float(i) / 12.0
		var pos := Vector3(cos(angle) * 28.0, 0.0, -78 + sin(angle) * 21.0)
		_build_dead_simple_prop(zone, "DialogueArcade_%02d" % i, pos, rad_to_deg(angle) + 90.0, Vector3(4.2, 5.2, 1.0), Color(0.38, 0.37, 0.35), true)
		_build_dead_simple_prop(zone, "RoleNamePlate_%02d" % i, pos + Vector3(0, 3.2, 0), rad_to_deg(angle) + 90.0, Vector3(2.6, 0.9, 0.12), Color(0.70, 0.64, 0.48, 0.54), false)
	_build_dead_simple_prop(zone, "ThresholdHouse", Vector3(-31, 0, -58), 12.0, Vector3(13, 5.0, 10), Color(0.36, 0.32, 0.28), true)
	var mask_specs := [
		["SoldierMask", Vector3(-7, 2.5, -74), Color(0.58, 0.66, 0.78, 0.58)],
		["FatherMask", Vector3(-32, 3.1, -63), Color(0.72, 0.62, 0.48, 0.58)],
		["DaughterMask", Vector3(11, 2.5, -82), Color(0.78, 0.66, 0.72, 0.58)],
		["ServantMask", Vector3(23, 2.5, -69), Color(0.66, 0.64, 0.58, 0.58)]
	]
	for spec in mask_specs:
		_build_dead_simple_prop(zone, String(spec[0]), spec[1], 0.0, Vector3(1.8, 2.2, 0.22), spec[2], false)
	_build_dead_simple_prop(zone, "DialogueSoundSource", Vector3(0, 2.0, -78), 0.0, Vector3(2.4, 2.4, 2.4), Color(0.58, 0.72, 1.0, 0.26), false)
	_build_dead_echo_node(zone, 0, Vector3(0, 0, -66), 0.0)

func _build_dead_adelma_dusk_dock(parent: Node3D) -> void:
	var zone := _make_city_zone(parent, "ZoneB_AdelmaDuskDock")
	_build_dead_simple_prop(zone, "DuskDock", Vector3(58, 0, -40), 0.0, Vector3(36, 1.1, 18), Color(0.28, 0.23, 0.18), true)
	for i in range(7):
		_build_dead_simple_prop(zone, "FishMarketShed_%02d" % i, Vector3(40.0 + float(i % 2) * 28.0, 0, -18.0 + float(i / 2) * 11.0), -4.0 + float(i) * 2.0, Vector3(12, 4.0, 8), Color(0.34, 0.31, 0.27), true)
	_build_dead_simple_prop(zone, "NarrowAlley", Vector3(52, 0.12, 14), 0.0, Vector3(9, 0.10, 54), Color(0.20, 0.20, 0.19), true)
	for i in range(8):
		_build_dead_simple_prop(zone, "PorterStoneStep_%02d" % i, Vector3(52, 0.18 + float(i) * 0.12, 31.0 + float(i) * 2.2), 0.0, Vector3(12, 0.24, 2.0), Color(0.40, 0.39, 0.36), true)
	_build_dead_cylinder_prop(zone, "MooringBollard", Vector3(42, 0.8, -49), 1.0, 1.6, Color(0.22, 0.20, 0.18), true)
	_build_dead_simple_prop(zone, "SeaUrchinBasket", Vector3(68, 0.7, -16), 0.0, Vector3(2.4, 1.4, 2.0), Color(0.12, 0.10, 0.09), false)
	_build_dead_simple_prop(zone, "CabbageBasket", Vector3(40, 0.7, 2), 0.0, Vector3(2.6, 1.2, 2.0), Color(0.32, 0.46, 0.28), false)
	_build_dead_simple_prop(zone, "BalconyBasket", Vector3(66, 4.6, 4), 0.0, Vector3(2.4, 1.0, 1.6), Color(0.44, 0.31, 0.18), false)
	_build_dead_simple_prop(zone, "SackHood", Vector3(50, 2.2, 42), 0.0, Vector3(1.4, 1.9, 0.36), Color(0.44, 0.38, 0.28), false)
	for i in range(5):
		_build_dead_simple_prop(zone, "FamiliarFaceGhost_%02d" % i, Vector3(36.0 + float(i) * 8.0, 1.8, -5.0 + float(i % 2) * 18.0), 0.0, Vector3(1.0, 2.6, 0.18), Color(0.60, 0.70, 0.82, 0.26), false)
	_build_dead_echo_node(zone, 1, Vector3(54, 0, -4), -90.0)

func _build_dead_eusapia_sister_city(parent: Node3D) -> void:
	var zone := _make_city_zone(parent, "ZoneC_EusapiaSisterCity")
	_build_dead_simple_prop(zone, "UpperEusapia", Vector3(0, 0, -22), 0.0, Vector3(42, 6.0, 22), Color(0.38, 0.35, 0.31), true)
	_build_dead_simple_prop(zone, "LowerSisterCity", Vector3(0, -2.2, 4), 0.0, Vector3(50, 3.0, 34), Color(0.20, 0.22, 0.24, 0.72), false)
	_build_dead_simple_prop(zone, "UpDownPassage", Vector3(-24, 0, -2), 0.0, Vector3(8, 7.5, 8), Color(0.16, 0.18, 0.20), true)
	_build_dead_simple_prop(zone, "UndergroundBanquetHall", Vector3(0, 0, 16), 0.0, Vector3(28, 4.6, 14), Color(0.24, 0.22, 0.20), true)
	_build_dead_simple_prop(zone, "DeadDanceHall", Vector3(22, 0, 2), 6.0, Vector3(18, 5.2, 18), Color(0.26, 0.25, 0.27), true)
	_build_dead_simple_prop(zone, "StoppedClockShop", Vector3(-18, 0, 20), -8.0, Vector3(12, 4.2, 9), Color(0.30, 0.28, 0.24), true)
	_build_dead_simple_prop(zone, "DryBarberShop", Vector3(18, 0, 22), 8.0, Vector3(12, 4.0, 9), Color(0.31, 0.29, 0.25), true)
	_build_dead_simple_prop(zone, "HoodedBrotherhoodHall", Vector3(0, 0, -2), 0.0, Vector3(17, 6.8, 12), Color(0.16, 0.15, 0.16), true)
	_build_dead_simple_prop(zone, "DriedSkeleton", Vector3(0, 2.4, 16), 0.0, Vector3(1.2, 3.0, 0.4), Color(0.78, 0.74, 0.62), false)
	_build_dead_simple_prop(zone, "StoppedClock", Vector3(-18, 3.2, 15.2), 0.0, Vector3(3.0, 3.0, 0.20), Color(0.70, 0.66, 0.52), false)
	_build_dead_simple_prop(zone, "DryBrush", Vector3(19, 2.2, 17.2), 0.0, Vector3(0.4, 2.0, 0.2), Color(0.58, 0.48, 0.32), false)
	_build_dead_simple_prop(zone, "HollowEyedScript", Vector3(23, 1.2, 2), 0.0, Vector3(2.8, 0.18, 1.8), Color(0.80, 0.76, 0.60), false)
	_build_dead_simple_prop(zone, "CalfSkeleton", Vector3(8, 1.2, 26), 0.0, Vector3(3.8, 1.6, 1.0), Color(0.72, 0.70, 0.62), false)
	_build_dead_simple_prop(zone, "HoodedMask", Vector3(0, 4.7, -8.3), 0.0, Vector3(2.2, 2.0, 0.20), Color(0.03, 0.03, 0.04), false)
	_build_dead_echo_node(zone, 2, Vector3(0, 0, 8), 0.0)

func _build_dead_argia_buried_city(parent: Node3D) -> void:
	var zone := _make_city_zone(parent, "ZoneD_ArgiaBuriedBlackCity")
	_build_dead_simple_prop(zone, "BuriedStreet", Vector3(-58, 0.08, 18), -4.0, Vector3(12, 0.14, 74), Color(0.22, 0.20, 0.17), true)
	for i in range(7):
		_build_dead_simple_prop(zone, "DustFilledRoom_%02d" % i, Vector3(-78.0 + float(i % 2) * 32.0, 0, -2.0 + float(i / 2) * 17.0), 4.0, Vector3(17, 4.0, 13), Color(0.28, 0.25, 0.21), true)
		_build_dead_simple_prop(zone, "RockLayerRoof_%02d" % i, Vector3(-78.0 + float(i % 2) * 32.0, 5.6, -2.0 + float(i / 2) * 17.0), 4.0, Vector3(20, 1.6, 16), Color(0.18, 0.18, 0.17), false)
	_build_dead_simple_prop(zone, "InvertedStair", Vector3(-58, 2.8, 42), -8.0, Vector3(16, 1.1, 5.0), Color(0.30, 0.28, 0.24), true)
	for i in range(8):
		_build_dead_simple_prop(zone, "BurrowPassage_%02d" % i, Vector3(-88.0 + float(i) * 8.0, 1.4, 59.0), 0.0, Vector3(5.0, 2.8, 2.0), Color(0.18, 0.16, 0.14), true)
	_build_dead_simple_prop(zone, "ThickDustLayer", Vector3(-58, 0.18, 18), 0.0, Vector3(54, 0.12, 78), Color(0.54, 0.46, 0.34, 0.42), false)
	_build_dead_simple_prop(zone, "RootGap", Vector3(-76, 2.4, 46), 18.0, Vector3(14, 0.5, 0.5), Color(0.17, 0.10, 0.06), false)
	_build_dead_simple_prop(zone, "InsectBurrow", Vector3(-42, 1.2, 38), 0.0, Vector3(1.8, 1.2, 0.22), Color(0.04, 0.035, 0.03), false)
	_build_dead_simple_prop(zone, "UndergroundDoorSound", Vector3(-58, 1.6, 56), 0.0, Vector3(3.2, 3.2, 0.20), Color(0.36, 0.44, 0.58, 0.32), false)
	_build_dead_echo_node(zone, 3, Vector3(-58, 0, 46), 90.0)

func _build_dead_laudomia_triple_city(parent: Node3D) -> void:
	var zone := _make_city_zone(parent, "ZoneE_TripleLaudomia")
	_build_dead_simple_prop(zone, "LivingLaudomia", Vector3(-38, 0, 74), 0.0, Vector3(34, 6.0, 22), Color(0.38, 0.36, 0.32), true)
	_build_dead_simple_prop(zone, "DeadLaudomia", Vector3(0, 0, 76), 0.0, Vector3(34, 4.2, 22), Color(0.34, 0.34, 0.33), true)
	_build_dead_simple_prop(zone, "UnbornLaudomia", Vector3(38, 0, 74), 0.0, Vector3(34, 6.8, 22), Color(0.44, 0.43, 0.39), true)
	_build_dead_simple_prop(zone, "TombstoneStreet", Vector3(0, 0.16, 88), 0.0, Vector3(90, 0.12, 8), Color(0.30, 0.30, 0.29), true)
	for i in range(14):
		var x := -40.0 + float(i % 7) * 13.0
		var z := 84.0 + float(i / 7) * 9.0
		_build_dead_simple_prop(zone, "StoneTombstone_%02d" % i, Vector3(x, 0, z), 0.0, Vector3(2.0, 3.2, 0.6), Color(0.48, 0.48, 0.44), true)
		_build_dead_simple_prop(zone, "FamilyNameStone_%02d" % i, Vector3(x, 2.2, z - 0.38), 0.0, Vector3(1.5, 0.6, 0.10), Color(0.72, 0.68, 0.56, 0.42), false)
	for i in range(10):
		_build_dead_simple_prop(zone, "NicheBuilding_%02d" % i, Vector3(24.0 + float(i % 5) * 6.8, 2.2 + float(i / 5) * 3.4, 64.0), 0.0, Vector3(4.8, 2.8, 0.8), Color(0.56, 0.54, 0.48, 0.48), false)
	_build_dead_cylinder_prop(zone, "FunnelHall", Vector3(38, 2.0, 90), 11.0, 4.0, Color(0.46, 0.45, 0.42), true)
	_build_dead_simple_prop(zone, "PoreCrowd", Vector3(38, 4.7, 84.4), 0.0, Vector3(12.0, 2.2, 0.12), Color(0.12, 0.12, 0.11, 0.36), false)
	_build_dead_simple_prop(zone, "HourglassTower", Vector3(0, 0, 108), 0.0, Vector3(9, 30, 9), Color(0.38, 0.36, 0.32), true)
	_build_dead_simple_prop(zone, "HourglassNeck", Vector3(0, 16.0, 108), 0.0, Vector3(4.0, 4.0, 4.0), Color(0.78, 0.72, 0.54, 0.42), false)
	_build_dead_simple_prop(zone, "SandGrainGlow", Vector3(0, 27.5, 108), 0.0, Vector3(2.5, 1.2, 2.5), Color(0.92, 0.82, 0.46, 0.58), false)
	_build_dead_echo_node(zone, 4, Vector3(0, 0, 88), 180.0)
	dead_goal_trigger = Area3D.new()
	dead_goal_trigger.name = "DeadGoalTrigger"
	dead_goal_trigger.position = Vector3(0, 1.0, 108)
	dead_goal_trigger.collision_layer = 0
	dead_goal_trigger.collision_mask = 2
	var shape := CollisionShape3D.new()
	var sphere := SphereShape3D.new()
	sphere.radius = 9.0
	shape.shape = sphere
	dead_goal_trigger.add_child(shape)
	dead_goal_trigger.body_entered.connect(_on_dead_goal_entered)
	dead_goal_trigger.body_exited.connect(_on_dead_goal_exited)
	manifested_city.add_child(dead_goal_trigger)

func _build_dead_center_core(parent: Node3D) -> void:
	var zone := _make_city_zone(parent, "ZoneF_CentralDeathCore")
	_build_dead_cylinder_prop(zone, "CentralColdMistBasin", Vector3(0, 0.08, 34), 18.0, 0.16, Color(0.26, 0.30, 0.34, 0.46), false)
	_build_dead_simple_prop(zone, "TripleCityMarker", Vector3(0, 0, 34), 0.0, Vector3(5.0, 7.2, 1.4), Color(0.44, 0.42, 0.36), true)
	_build_dead_simple_prop(zone, "DeadEchoSource", Vector3(0, 2.6, 34), 0.0, Vector3(2.6, 2.6, 2.6), Color(0.50, 0.66, 1.0, 0.24), false)
	for i in range(3):
		var angle := TAU * float(i) / 3.0
		_build_dead_simple_prop(zone, "ThreeCityLine_%02d" % i, Vector3(cos(angle) * 9.0, 0.36, 34 + sin(angle) * 9.0), rad_to_deg(angle), Vector3(0.16, 0.10, 18.0), Color(0.72, 0.76, 0.78, 0.32), false)

func _build_dead_atmosphere(parent: Node3D) -> void:
	var atmosphere := Node3D.new()
	atmosphere.name = "DeadCityAtmosphere_StyleDirection"
	parent.add_child(atmosphere)
	atmosphere.add_child(_make_city_particle_layer("ColdMistParticles", 1200, Vector2(0.18, 0.045), Vector3(112, 4.2, 112), Vector3(0.04, 0.04, -0.03), Color(0.44, 0.58, 0.74, 0.26), 0.03, 0.16, 100.0, 15.0))
	atmosphere.add_child(_make_city_particle_layer("AshParticles", 980, Vector2(0.10, 0.045), Vector3(112, 7.2, 112), Vector3(-0.03, 0.08, 0.02), Color(0.42, 0.42, 0.38, 0.34), 0.04, 0.22, 100.0, 13.0))
	atmosphere.add_child(_make_city_particle_layer("WhiteSaltDustParticles", 940, Vector2(0.07, 0.035), Vector3(108, 4.5, 108), Vector3(0.05, 0.05, 0.04), Color(0.82, 0.80, 0.72, 0.32), 0.03, 0.18, 100.0, 12.0))
	atmosphere.add_child(_make_city_particle_layer("PaleBlueGlowParticles", 520, Vector2(0.11, 0.11), Vector3(104, 5.4, 104), Vector3(0.02, 0.05, 0.03), Color(0.48, 0.66, 1.0, 0.30), 0.02, 0.14, 100.0, 14.0))
	atmosphere.add_child(_make_city_particle_layer("UnbornDustMotes", 620, Vector2(0.055, 0.055), Vector3(80, 5.8, 70), Vector3(0.02, 0.05, 0.02), Color(0.84, 0.82, 0.76, 0.22), 0.03, 0.18, 100.0, 16.0))
	for i in range(9):
		var angle := TAU * float(i) / 9.0
		_add_dead_cold_mist_veil(atmosphere, "DeadColdMistVeil_%02d" % i, Vector3(cos(angle) * 50.0, 3.0 + float(i % 3) * 0.8, sin(angle) * 50.0), Vector2(72, 12 + float(i % 2) * 4), rad_to_deg(angle) + 90.0, Color(0.44, 0.58, 0.76, 0.20), 800.0 + float(i) * 5.7, 0.45)

func _add_dead_block(parent: Node3D, name: String, pos: Vector3, size: Vector3, yaw: float, color: Color, collision := true, seed := 0.0) -> Node3D:
	var box := CSGBox3D.new()
	box.name = name
	box.position = pos
	box.size = size
	box.rotation_degrees.y = yaw
	box.material = _dead_bone_dissolve_material(color, color.a, seed)
	parent.add_child(box)
	if collision:
		_add_box_collision(name + "Collision", pos, size, yaw)
	return box

func _build_dead_simple_prop(parent: Node3D, name: String, pos: Vector3, yaw: float, size: Vector3, color: Color, collision := false) -> Node3D:
	var asset := _make_city_asset(parent, name, pos, yaw)
	_add_local_dead_block(asset, "WhiteboxReplaceRoot", Vector3(0, size.y * 0.5, 0), size, 0.0, color, collision)
	return asset

func _add_local_dead_block(asset: Node3D, part_name: String, local_pos: Vector3, size: Vector3, local_yaw: float, color: Color, collision := true) -> Node3D:
	var global_pos := _asset_global_pos(asset, local_pos)
	var global_yaw := _asset_global_yaw(asset, local_yaw)
	var box := CSGBox3D.new()
	box.name = part_name
	box.position = local_pos
	box.size = size
	box.rotation_degrees.y = local_yaw
	box.material = _dead_bone_dissolve_material(color, color.a, global_pos.x * 0.19 + global_pos.z * 0.23)
	asset.add_child(box)
	if collision:
		_add_box_collision("%s_%sCollision" % [asset.name, part_name], global_pos, size, global_yaw)
	return box

func _build_dead_cylinder_prop(parent: Node3D, name: String, pos: Vector3, radius: float, height: float, color: Color, collision := false) -> Node3D:
	var cylinder := CSGCylinder3D.new()
	cylinder.name = name
	cylinder.radius = radius
	cylinder.height = height
	cylinder.sides = 48
	cylinder.position = pos
	cylinder.material = _dead_bone_dissolve_material(color, color.a, pos.x * 0.11 + pos.z * 0.29)
	parent.add_child(cylinder)
	if collision:
		_add_box_collision(name + "Collision", pos, Vector3(radius * 2.0, height, radius * 2.0), 0.0)
	return cylinder

func _dead_echo_color(node_index: int) -> Color:
	return DEAD_ECHO_COLORS[clampi(node_index, 0, DEAD_ECHO_COLORS.size() - 1)]

func _build_dead_echo_node(parent: Node3D, node_index: int, pos: Vector3, yaw: float) -> void:
	var data: Array = DEAD_ECHO_NODES[node_index]
	var color := _dead_echo_color(node_index)
	var asset := _make_city_asset(parent, String(data[0]), pos, yaw)
	_add_local_dead_block(asset, "EchoBoneColumn", Vector3(0, 2.0, 0), Vector3(1.5, 4.0, 1.1), 0.0, Color(0.32, 0.32, 0.30), true)
	_add_local_dead_block(asset, "ActiveDeadEchoPanel", Vector3(0, 4.5, -0.58), Vector3(5.2, 2.2, 0.16), 0.0, color, false)
	var settled := _add_local_dead_block(asset, "SettledBoneWhitePanel", Vector3(0, 4.5, -0.78), Vector3(5.2, 2.2, 0.16), 0.0, Color(0.82, 0.80, 0.70, 0.32), false)
	settled.visible = false
	_add_dead_echo_glow(asset, color)
	while dead_echo_visuals.size() <= node_index:
		dead_echo_visuals.append(null)
	dead_echo_visuals[node_index] = asset

	var area := Area3D.new()
	area.name = "%sArea" % String(data[0])
	area.position = pos + Vector3(0, 1.3, 0)
	area.collision_layer = 0
	area.collision_mask = 2
	var shape := CollisionShape3D.new()
	var sphere := SphereShape3D.new()
	sphere.radius = 4.8
	shape.shape = sphere
	area.add_child(shape)
	area.body_entered.connect(func(body: Node3D): _on_dead_echo_entered(body, node_index))
	area.body_exited.connect(func(body: Node3D): _on_dead_echo_exited(body, node_index))
	manifested_city.add_child(area)
	while dead_echo_areas.size() <= node_index:
		dead_echo_areas.append(null)
	dead_echo_areas[node_index] = area

func _add_dead_echo_glow(asset: Node3D, color: Color) -> void:
	var candle := CSGCylinder3D.new()
	candle.name = "DeadEchoGlow"
	candle.radius = 3.2
	candle.height = 0.04
	candle.sides = 48
	candle.position = Vector3(0, 0.12, 0)
	candle.material = _emissive_mat(color, 0.24, dead_echo_glow_energy)
	asset.add_child(candle)
	var light := OmniLight3D.new()
	light.name = "DeadEchoLight"
	light.position = Vector3(0, 4.0, 0)
	light.light_color = color
	light.light_energy = dead_echo_glow_energy
	light.omni_range = 8.0
	asset.add_child(light)
	var particles := GPUParticles3D.new()
	particles.name = "DeadEchoParticles"
	particles.amount = int(maxf(1.0, 80.0 * dead_echo_particle_scale))
	particles.lifetime = 3.2
	particles.visibility_aabb = AABB(Vector3(-5, -1, -5), Vector3(10, 8, 10))
	var mesh := QuadMesh.new()
	mesh.size = Vector2(0.08, 0.08)
	particles.draw_pass_1 = mesh
	var process := ParticleProcessMaterial.new()
	process.emission_shape = ParticleProcessMaterial.EMISSION_SHAPE_SPHERE
	process.emission_sphere_radius = 2.6
	process.gravity = Vector3.ZERO
	process.initial_velocity_min = 0.02
	process.initial_velocity_max = 0.22
	process.spread = 100.0
	process.color = Color(color.r, color.g, color.b, 0.64)
	particles.process_material = process
	particles.position = Vector3(0, 3.0, 0)
	particles.emitting = true
	asset.add_child(particles)

func _set_dead_echo_visual_state(node_index: int, settled: bool) -> void:
	if node_index < 0 or node_index >= dead_echo_visuals.size():
		return
	var asset := dead_echo_visuals[node_index]
	if asset == null:
		return
	var active := asset.get_node_or_null("ActiveDeadEchoPanel")
	if active != null:
		active.visible = not settled
	var settled_panel := asset.get_node_or_null("SettledBoneWhitePanel")
	if settled_panel != null:
		settled_panel.visible = settled
	for name in ["DeadEchoGlow", "DeadEchoLight", "DeadEchoParticles"]:
		var child := asset.get_node_or_null(name)
		if child != null:
			child.visible = not settled

func _build_sky_city_whitebox(parent: Node3D) -> void:
	_build_sky_terrain(parent)
	_build_sky_eudoxia_maze(parent)
	_build_sky_bersabea_projection(parent)
	_build_sky_thekla_construction(parent)
	_build_sky_perinthia_zodiac(parent)
	_build_sky_andria_orbit(parent)
	_build_sky_center_core(parent)
	_build_sky_atmosphere(parent)

func _build_sky_terrain(parent: Node3D) -> void:
	var terrain := _make_city_zone(parent, "SkyCity_AstralHighlandTerrain")
	_build_sky_simple_prop(terrain, "AstralHighlandGround", Vector3(0, -0.04, 0), 0.0, Vector3(238, 0.08, 238), Color(0.09, 0.12, 0.23), true)
	_build_sky_simple_prop(terrain, "CloudSeaBelow_NoCollision", Vector3(0, -5.8, 0), 0.0, Vector3(236, 0.08, 236), Color(0.35, 0.48, 0.72, 0.18), false)
	_build_sky_simple_prop(terrain, "MainCelestialCauseway_SouthNorth", Vector3(0, 0.04, 10), 0.0, Vector3(9, 0.08, 204), Color(0.16, 0.20, 0.34), true)
	_build_sky_simple_prop(terrain, "CrossSkyCauseway_EastWest", Vector3(0, 0.05, 0), 0.0, Vector3(164, 0.08, 8), Color(0.15, 0.19, 0.32), true)
	_build_sky_simple_prop(terrain, "ZodiacNorthCauseway", Vector3(-20, 0.055, 52), 15.0, Vector3(8, 0.08, 70), Color(0.16, 0.19, 0.34), true)
	_build_sky_simple_prop(terrain, "OrbitApproachCauseway", Vector3(12, 0.06, 82), -8.0, Vector3(8, 0.08, 60), Color(0.17, 0.20, 0.35), true)
	for i in range(10):
		var angle := TAU * float(i) / 10.0
		_add_sky_line_span(terrain, "GroundStarTrack_%02d" % i, Vector3(cos(angle) * 12.0, 0.14, sin(angle) * 12.0), Vector3(cos(angle) * 105.0, 0.14, sin(angle) * 105.0), Color(0.38, 0.66, 1.0, 0.28), 0.08)

func _build_sky_eudoxia_maze(parent: Node3D) -> void:
	var zone := _make_city_zone(parent, "ZoneA_EudoxiaVerticalMaze")
	_build_sky_simple_prop(zone, "VerticalMazeCity", Vector3(0, 0, -78), 0.0, Vector3(34, 9.0, 24), Color(0.18, 0.18, 0.28), true)
	for i in range(7):
		var x := -20.0 + float(i % 4) * 12.0
		var z := -96.0 + float(i / 4) * 16.0
		_build_sky_simple_prop(zone, "CurvedAlley_%02d" % i, Vector3(x, 0.10, z), -18.0 + float(i) * 11.0, Vector3(15, 0.12, 3.2), Color(0.14, 0.17, 0.28), true)
	_build_sky_simple_prop(zone, "DeadEndHut", Vector3(-28, 0, -72), 12.0, Vector3(9, 4.6, 8), Color(0.16, 0.14, 0.18), true)
	_build_sky_simple_prop(zone, "CarpetShrine", Vector3(0, 0, -58), 0.0, Vector3(22, 7.6, 14), Color(0.24, 0.20, 0.38), true)
	_build_sky_cylinder_prop(zone, "SpiralPatternPlaza", Vector3(0, 0.12, -66), 15.0, 0.12, Color(0.19, 0.22, 0.38), true)
	_build_sky_simple_prop(zone, "SymmetricCarpet", Vector3(0, 0.22, -58), 0.0, Vector3(14, 0.08, 9), Color(0.36, 0.18, 0.54, 0.86), false)
	for i in range(8):
		var angle := TAU * float(i) / 8.0
		_add_sky_line_span(zone, "ColorSpiralMotif_%02d" % i, Vector3(cos(angle) * 1.6, 0.30, -58 + sin(angle) * 1.2), Vector3(cos(angle) * 6.6, 0.30, -58 + sin(angle) * 4.0), Color(0.86, 0.72, 1.0, 0.62), 0.10)
	_build_sky_simple_prop(zone, "MuleSoundSource", Vector3(18, 1.2, -76), 0.0, Vector3(2.8, 2.2, 2.8), Color(0.62, 0.54, 0.42, 0.36), false)
	_build_sky_simple_prop(zone, "SootStain", Vector3(-28, 2.2, -76.2), 12.0, Vector3(4.0, 3.2, 0.12), Color(0.02, 0.02, 0.02, 0.42), false)
	_build_sky_simple_prop(zone, "FishySeafoodStall", Vector3(24, 0, -86), -8.0, Vector3(8, 2.6, 5), Color(0.16, 0.26, 0.34), true)
	_build_sky_anchor_node(zone, 0, Vector3(0, 0, -50), 0.0)

func _build_sky_bersabea_projection(parent: Node3D) -> void:
	var zone := _make_city_zone(parent, "ZoneB_BersabeaSkyUnderCity")
	_build_sky_simple_prop(zone, "GoldenSkyCity", Vector3(66, 15.0, -28), -6.0, Vector3(36, 8.0, 24), Color(0.92, 0.66, 0.18, 0.58), false)
	_build_sky_simple_prop(zone, "DiamondGate", Vector3(48, 5.0, -24), -12.0, Vector3(8, 10, 1.2), Color(0.82, 0.92, 1.0, 0.64), false)
	_build_sky_simple_prop(zone, "SilverLockTower", Vector3(82, 0, -16), 7.0, Vector3(8, 16, 8), Color(0.68, 0.72, 0.82), true)
	_build_sky_simple_prop(zone, "UndergroundMachineCity", Vector3(62, -1.4, 6), 0.0, Vector3(46, 2.8, 30), Color(0.04, 0.05, 0.07, 0.88), false)
	_build_sky_simple_prop(zone, "GearPipePalace", Vector3(62, 0, 4), 0.0, Vector3(26, 8.4, 16), Color(0.12, 0.12, 0.15), true)
	for i in range(6):
		var angle := TAU * float(i) / 6.0
		_build_sky_cylinder_prop(zone, "GearWheel_%02d" % i, Vector3(62 + cos(angle) * 10.0, 3.2, 4 + sin(angle) * 5.5), 1.9, 0.34, Color(0.44, 0.42, 0.48), false)
	_build_sky_simple_prop(zone, "CometWasteDepot", Vector3(92, 18.0, -54), -18.0, Vector3(24, 4.0, 9), Color(0.44, 0.34, 0.18, 0.46), false)
	_add_sky_line_span(zone, "CometTailDust", Vector3(82, 18.0, -54), Vector3(48, 12.0, -44), Color(0.94, 0.76, 0.42, 0.38), 0.18)
	_build_sky_simple_prop(zone, "PreciousMetalPile", Vector3(58, 0, -36), 0.0, Vector3(6, 1.2, 4), Color(1.0, 0.74, 0.24), false)
	_build_sky_simple_prop(zone, "RareGem", Vector3(65, 1.2, -38), 0.0, Vector3(2.4, 2.4, 2.4), Color(0.40, 0.86, 1.0, 0.72), false)
	_build_sky_simple_prop(zone, "TrashCanRoof", Vector3(44, 3.0, 10), 0.0, Vector3(5, 1.0, 5), Color(0.22, 0.22, 0.23), false)
	for i in range(5):
		var debris_names := ["PotatoPeel", "BrokenUmbrella", "OldSock", "GlassShard", "UsedTicket"]
		_build_sky_simple_prop(zone, String(debris_names[i]), Vector3(86.0 + float(i) * 2.4, 19.0 + float(i % 2), -58.0 + float(i % 3) * 3.0), float(i) * 12.0, Vector3(1.8, 0.4, 0.8), Color(0.72, 0.62, 0.46, 0.48), false)
	_build_sky_anchor_node(zone, 1, Vector3(62, 0, -18), -90.0)

func _build_sky_thekla_construction(parent: Node3D) -> void:
	var zone := _make_city_zone(parent, "ZoneC_TheklaConstruction")
	_build_sky_simple_prop(zone, "EndlessConstructionCity", Vector3(-62, 0, 0), 0.0, Vector3(44, 6.0, 30), Color(0.20, 0.18, 0.17), true)
	_build_sky_simple_prop(zone, "PlankFence_North", Vector3(-62, 1.7, -20), 0.0, Vector3(48, 3.4, 0.8), Color(0.38, 0.28, 0.16), true)
	_build_sky_simple_prop(zone, "PlankFence_South", Vector3(-62, 1.7, 20), 0.0, Vector3(48, 3.4, 0.8), Color(0.38, 0.28, 0.16), true)
	_build_sky_simple_prop(zone, "CanvasBarrier", Vector3(-38, 2.2, 0), 0.0, Vector3(0.8, 4.4, 38), Color(0.72, 0.68, 0.56, 0.42), false)
	for i in range(5):
		_build_sky_scaffold_tower(zone, "ScaffoldTower_%02d" % i, Vector3(-78.0 + float(i % 3) * 14.0, 0, -10.0 + float(i / 3) * 18.0), float(i) * 8.0, 9.0 + float(i % 2) * 3.0)
	for i in range(3):
		_build_sky_crane(zone, "CraneCluster_%02d" % i, Vector3(-86.0 + float(i) * 22.0, 0, 20.0), float(i) * 12.0)
	_build_sky_simple_prop(zone, "StarBlueprintPlatform", Vector3(-58, 0, 6), 0.0, Vector3(28, 0.5, 18), Color(0.12, 0.28, 0.54), true)
	for i in range(9):
		var angle := TAU * float(i) / 9.0
		_add_sky_line_span(zone, "StarBlueprintLine_%02d" % i, Vector3(-58, 0.60, 6), Vector3(-58 + cos(angle) * 13.0, 0.60, 6 + sin(angle) * 8.0), Color(0.48, 0.86, 1.0, 0.56), 0.08)
	for i in range(4):
		var tool_names := ["Bucket", "PlumbLine", "LongBrush", "RebarFrame"]
		_build_sky_simple_prop(zone, String(tool_names[i]), Vector3(-74.0 + float(i) * 9.0, 0, 16.0), 0.0, Vector3(2.2, 1.6 + float(i), 1.2), Color(0.46, 0.42, 0.36), false)
	_build_sky_anchor_node(zone, 2, Vector3(-58, 0, 8), 90.0)

func _build_sky_perinthia_zodiac(parent: Node3D) -> void:
	var zone := _make_city_zone(parent, "ZoneD_PerinthiaZodiac")
	_build_sky_cylinder_prop(zone, "ZodiacCityWall", Vector3(-28, 0.18, 52), 30.0, 0.18, Color(0.22, 0.20, 0.36, 0.55), false)
	for i in range(12):
		var angle := TAU * float(i) / 12.0
		var pos := Vector3(-28 + cos(angle) * 28.0, 0, 52 + sin(angle) * 28.0)
		_build_sky_simple_prop(zone, "ZodiacTemple_%02d" % i, pos, rad_to_deg(angle), Vector3(5.2, 5.5, 4.2), Color(0.22, 0.20, 0.34), true)
		_add_sky_line_span(zone, "ZodiacLine_%02d" % i, Vector3(-28, 0.45, 52), pos + Vector3(0, 0.45, 0), Color(0.70, 0.62, 1.0, 0.32), 0.055)
	_build_sky_simple_prop(zone, "EclipseGate", Vector3(-28, 0, 22), 0.0, Vector3(14, 12, 1.2), Color(0.36, 0.31, 0.58), true)
	_build_sky_cylinder_prop(zone, "EclipseFrame", Vector3(-28, 7.0, 21.2), 4.2, 0.22, Color(0.92, 0.86, 1.0, 0.62), false)
	_build_sky_cylinder_prop(zone, "CelestialAxisPlaza", Vector3(-28, 0.16, 52), 12.0, 0.12, Color(0.17, 0.22, 0.40), true)
	_add_sky_line_span(zone, "SkyAxisLine_NorthSouth", Vector3(-28, 0.50, 20), Vector3(-28, 0.50, 84), Color(0.70, 0.76, 1.0, 0.52), 0.09)
	_add_sky_line_span(zone, "SkyAxisLine_EastWest", Vector3(-60, 0.50, 52), Vector3(4, 0.50, 52), Color(0.70, 0.76, 1.0, 0.52), 0.09)
	_build_sky_simple_prop(zone, "ZodiacPlan", Vector3(-48, 0.7, 44), 12.0, Vector3(5.0, 0.20, 3.6), Color(0.74, 0.68, 0.52), false)
	_build_sky_simple_prop(zone, "DeformedAttic", Vector3(-8, 7.0, 58), -8.0, Vector3(9, 4.0, 7), Color(0.10, 0.08, 0.14), false)
	_build_sky_simple_prop(zone, "DeformedCellar", Vector3(-8, -1.0, 66), 6.0, Vector3(10, 2.0, 8), Color(0.04, 0.035, 0.05, 0.72), false)
	_build_sky_simple_prop(zone, "DeformedShadow", Vector3(-11, 0.4, 61), 12.0, Vector3(8, 0.10, 5), Color(0.02, 0.02, 0.03, 0.46), false)
	_build_sky_simple_prop(zone, "HoarseHowlSource", Vector3(-8, 1.2, 66), 0.0, Vector3(2.4, 2.2, 2.4), Color(0.40, 0.26, 0.62, 0.34), false)
	_build_sky_anchor_node(zone, 3, Vector3(-28, 0, 34), 0.0)

func _build_sky_andria_orbit(parent: Node3D) -> void:
	var zone := _make_city_zone(parent, "ZoneE_AndriaOrbitCity")
	_build_sky_cylinder_prop(zone, "ConstellationForum", Vector3(18, 0.14, 78), 20.0, 0.12, Color(0.14, 0.22, 0.42), true)
	for ring in range(4):
		var radius := 8.0 + float(ring) * 5.0
		for i in range(12):
			var a := TAU * float(i) / 12.0
			var b := TAU * float(i + 1) / 12.0
			_add_sky_line_span(zone, "PlanetOrbitStreet_%02d_%02d" % [ring, i], Vector3(18 + cos(a) * radius, 0.42, 78 + sin(a) * radius), Vector3(18 + cos(b) * radius, 0.42, 78 + sin(b) * radius), Color(0.50, 0.82, 1.0, 0.36), 0.06)
	_build_sky_simple_prop(zone, "FloatingNewStreet", Vector3(32, 7.2, 82), -12.0, Vector3(38, 0.6, 4.2), Color(0.42, 0.66, 1.0, 0.30), false)
	_build_sky_simple_prop(zone, "ShadowTheater", Vector3(48, 0, 70), -8.0, Vector3(16, 6.0, 11), Color(0.12, 0.10, 0.18), true)
	_build_sky_simple_prop(zone, "RiverPort", Vector3(52, 0, 94), 0.0, Vector3(22, 1.0, 9), Color(0.12, 0.25, 0.38), true)
	_build_sky_simple_prop(zone, "ThalesStatuePlaza", Vector3(0, 0.12, 78), 0.0, Vector3(18, 0.12, 14), Color(0.18, 0.20, 0.34), true)
	_build_sky_simple_prop(zone, "ThalesStatue", Vector3(0, 0, 78), 0.0, Vector3(2.6, 6.4, 2.2), Color(0.62, 0.62, 0.68), true)
	_build_sky_simple_prop(zone, "BambooGrove", Vector3(40, 0, 58), 0.0, Vector3(18, 4.8, 10), Color(0.18, 0.42, 0.32, 0.58), false)
	_build_sky_simple_prop(zone, "SkiSlope", Vector3(60, 0.7, 110), -12.0, Vector3(26, 1.4, 12), Color(0.78, 0.82, 0.92, 0.52), false)
	_build_sky_simple_prop(zone, "AntaresSign", Vector3(10, 1.9, 60), 0.0, Vector3(4.4, 1.2, 0.18), Color(1.0, 0.42, 0.24, 0.72), false)
	_build_sky_simple_prop(zone, "CapellaSign", Vector3(26, 1.9, 62), 0.0, Vector3(4.4, 1.2, 0.18), Color(1.0, 0.88, 0.42, 0.72), false)
	_build_sky_simple_prop(zone, "SupernovaGlow", Vector3(18, 20.0, 78), 0.0, Vector3(3.2, 3.2, 3.2), Color(1.0, 0.82, 0.38, 0.50), false)
	_build_star_observatory_tower(zone, Vector3(0, 0, 108), 0.0)
	_build_sky_anchor_node(zone, 4, Vector3(18, 0, 78), 180.0)
	sky_goal_trigger = Area3D.new()
	sky_goal_trigger.name = "SkyGoalTrigger"
	sky_goal_trigger.position = Vector3(0, 1.1, 108)
	sky_goal_trigger.collision_layer = 0
	sky_goal_trigger.collision_mask = 2
	var shape := CollisionShape3D.new()
	var sphere := SphereShape3D.new()
	sphere.radius = 9.0
	shape.shape = sphere
	sky_goal_trigger.add_child(shape)
	sky_goal_trigger.body_entered.connect(_on_sky_goal_entered)
	sky_goal_trigger.body_exited.connect(_on_sky_goal_exited)
	manifested_city.add_child(sky_goal_trigger)

func _build_sky_center_core(parent: Node3D) -> void:
	var zone := _make_city_zone(parent, "ZoneF_CelestialCore")
	_build_sky_cylinder_prop(zone, "CelestialDial", Vector3(0, 0.16, 0), 18.0, 0.12, Color(0.12, 0.18, 0.36), true)
	for i in range(16):
		var angle := TAU * float(i) / 16.0
		_add_sky_line_span(zone, "CelestialDialSpoke_%02d" % i, Vector3(0, 0.52, 0), Vector3(cos(angle) * 17.0, 0.52, sin(angle) * 17.0), Color(0.44, 0.74, 1.0, 0.38), 0.055)
	_build_sky_simple_prop(zone, "BlueprintLightLineCore", Vector3(0, 2.8, 0), 0.0, Vector3(0.28, 5.6, 0.28), Color(0.70, 0.88, 1.0, 0.52), false)
	_build_sky_simple_prop(zone, "GoldenSkyGlowCore", Vector3(0, 5.8, 0), 0.0, Vector3(7.0, 1.0, 7.0), Color(1.0, 0.72, 0.28, 0.22), false)

func _build_sky_atmosphere(parent: Node3D) -> void:
	var atmosphere := Node3D.new()
	atmosphere.name = "SkyCityAtmosphere_StyleDirection"
	parent.add_child(atmosphere)
	atmosphere.add_child(_make_city_particle_layer("StarDustParticles", 1700, Vector2(0.040, 0.040), Vector3(118, 16, 118), Vector3(0.04, 0.10, -0.02), Color(0.76, 0.88, 1.0, 0.36), 0.03, 0.22, 100.0, 15.0))
	atmosphere.add_child(_make_city_particle_layer("CloudMoteParticles", 1200, Vector2(0.10, 0.045), Vector3(124, 8, 124), Vector3(0.12, 0.02, 0.06), Color(0.46, 0.62, 0.92, 0.18), 0.04, 0.26, 100.0, 18.0))
	atmosphere.add_child(_make_city_particle_layer("FallingLightMotes", 760, Vector2(0.050, 0.050), Vector3(108, 20, 108), Vector3(-0.02, -0.14, 0.03), Color(1.0, 0.82, 0.36, 0.30), 0.02, 0.16, 80.0, 18.0))
	atmosphere.add_child(_make_city_particle_layer("BlueprintLightLineParticles", 540, Vector2(0.22, 0.020), Vector3(108, 10, 108), Vector3(0.08, 0.06, 0.12), Color(0.42, 0.78, 1.0, 0.36), 0.04, 0.22, 100.0, 14.0))
	for i in range(9):
		var angle := TAU * float(i) / 9.0
		_add_sky_stardust_veil(atmosphere, "AstralGradientVeil_%02d" % i, Vector3(cos(angle) * 46.0, 8.0 + float(i % 3) * 2.6, sin(angle) * 46.0), Vector2(74, 18), rad_to_deg(angle) + 90.0, Color(0.28, 0.44, 1.0, 0.20), 500.0 + float(i) * 9.0, 0.45)
	_add_sky_stardust_veil(atmosphere, "DarkUnderMist", Vector3(62, 3.4, 4), Vector2(54, 14), 0.0, Color(0.05, 0.06, 0.12, 0.38), 608.0, 0.72)
	_add_sky_stardust_veil(atmosphere, "GoldenUpperCityGlow", Vector3(66, 17.2, -28), Vector2(58, 16), -8.0, Color(1.0, 0.74, 0.22, 0.28), 612.0, 0.32)

func _build_sky_simple_prop(parent: Node3D, name: String, pos: Vector3, yaw: float, size: Vector3, color: Color, collision := false) -> Node3D:
	var asset := _make_city_asset(parent, name, pos, yaw)
	_add_local_sky_block(asset, "WhiteboxReplaceRoot", Vector3(0, size.y * 0.5, 0), size, 0.0, color, collision)
	return asset

func _add_local_sky_block(asset: Node3D, part_name: String, local_pos: Vector3, size: Vector3, local_yaw: float, color: Color, collision := true) -> Node3D:
	var global_pos := _asset_global_pos(asset, local_pos)
	var global_yaw := _asset_global_yaw(asset, local_yaw)
	var box := CSGBox3D.new()
	box.name = part_name
	box.position = local_pos
	box.size = size
	box.rotation_degrees.y = local_yaw
	box.material = _sky_star_material(color, color.a, global_pos.x * 0.17 + global_pos.z * 0.21, 0.34, 0.28)
	asset.add_child(box)
	if collision:
		_add_box_collision("%s_%sCollision" % [asset.name, part_name], global_pos, size, global_yaw)
	return box

func _build_sky_cylinder_prop(parent: Node3D, name: String, pos: Vector3, radius: float, height: float, color: Color, collision := false) -> Node3D:
	var cylinder := CSGCylinder3D.new()
	cylinder.name = name
	cylinder.radius = radius
	cylinder.height = height
	cylinder.sides = 64
	cylinder.position = pos
	cylinder.material = _sky_star_material(color, color.a, pos.x * 0.13 + pos.z * 0.23, 0.42, 0.38)
	parent.add_child(cylinder)
	if collision:
		_add_box_collision(name + "Collision", pos, Vector3(radius * 2.0, height, radius * 2.0), 0.0)
	return cylinder

func _add_sky_line_span(parent: Node3D, name: String, a: Vector3, b: Vector3, color: Color, thickness := 0.06) -> Node3D:
	var delta := b - a
	var flat_length := Vector2(delta.x, delta.z).length()
	var yaw := rad_to_deg(atan2(delta.x, delta.z))
	var mid := (a + b) * 0.5
	return _build_sky_simple_prop(parent, name, mid, yaw, Vector3(thickness, thickness, maxf(flat_length, 0.1)), color, false)

func _build_sky_scaffold_tower(parent: Node3D, name: String, pos: Vector3, yaw: float, height: float) -> void:
	var asset := _make_city_asset(parent, name, pos, yaw)
	for x in [-2.0, 2.0]:
		for z in [-2.0, 2.0]:
			_add_local_sky_block(asset, "ScaffoldLeg_%s_%s" % [str(x), str(z)], Vector3(x, height * 0.5, z), Vector3(0.18, height, 0.18), 0.0, Color(0.52, 0.62, 0.80, 0.64), false)
	for level in range(4):
		var y := 1.2 + float(level) * height / 4.0
		_add_local_sky_block(asset, "ScaffoldCrossX_%02d" % level, Vector3(0, y, -2.0), Vector3(4.4, 0.12, 0.12), 0.0, Color(0.46, 0.70, 1.0, 0.44), false)
		_add_local_sky_block(asset, "ScaffoldCrossZ_%02d" % level, Vector3(-2.0, y, 0), Vector3(0.12, 0.12, 4.4), 0.0, Color(0.46, 0.70, 1.0, 0.44), false)

func _build_sky_crane(parent: Node3D, name: String, pos: Vector3, yaw: float) -> void:
	var asset := _make_city_asset(parent, name, pos, yaw)
	_add_local_sky_block(asset, "CraneMast", Vector3(0, 8.0, 0), Vector3(0.6, 16.0, 0.6), 0.0, Color(0.56, 0.54, 0.44), false)
	_add_local_sky_block(asset, "CraneBoom", Vector3(8.0, 15.4, 0), Vector3(18.0, 0.34, 0.34), 0.0, Color(0.72, 0.64, 0.38), false)
	_add_local_sky_block(asset, "CraneCounterweight", Vector3(-3.8, 14.9, 0), Vector3(3.0, 1.4, 1.0), 0.0, Color(0.42, 0.36, 0.24), false)

func _build_star_observatory_tower(parent: Node3D, pos: Vector3, yaw: float) -> void:
	var asset := _make_city_asset(parent, "StarObservatoryTower", pos, yaw)
	_add_local_sky_block(asset, "TowerBase", Vector3(0, 2.0, 0), Vector3(13, 4.0, 13), 0.0, Color(0.18, 0.19, 0.30), true)
	_add_local_sky_block(asset, "ObservatoryShaft", Vector3(0, 15.0, 0), Vector3(7.0, 26.0, 7.0), 0.0, Color(0.20, 0.23, 0.36), true)
	_add_local_sky_block(asset, "ObservationDeck", Vector3(0, 29.0, 0), Vector3(16, 2.0, 16), 0.0, Color(0.28, 0.34, 0.52), false)
	_add_local_sky_block(asset, "StarDome", Vector3(0, 32.0, 0), Vector3(11, 4.0, 11), 0.0, Color(0.46, 0.58, 0.86, 0.54), false)
	_add_local_sky_block(asset, "TelescopeTube", Vector3(3.6, 33.2, -2.2), Vector3(1.0, 1.0, 8.0), -28.0, Color(0.62, 0.72, 0.88), false)
	_add_local_sky_block(asset, "HighestStarMarker", Vector3(0, 36.0, 0), Vector3(2.0, 2.0, 2.0), 0.0, Color(1.0, 0.86, 0.34, 0.66), false)
	var light := OmniLight3D.new()
	light.name = "ObservatoryStarLight"
	light.position = Vector3(0, 34.0, 0)
	light.light_color = Color(0.64, 0.78, 1.0)
	light.light_energy = 1.05
	light.omni_range = 24.0
	asset.add_child(light)

func _sky_anchor_color(node_index: int) -> Color:
	return SKY_ANCHOR_COLORS[clampi(node_index, 0, SKY_ANCHOR_COLORS.size() - 1)]

func _build_sky_anchor_node(parent: Node3D, node_index: int, pos: Vector3, yaw: float) -> void:
	var data: Array = SKY_ANCHOR_NODES[node_index]
	var color := _sky_anchor_color(node_index)
	var asset := _make_city_asset(parent, String(data[0]), pos, yaw)
	_add_local_sky_block(asset, "AnchorColumn", Vector3(0, 2.2, 0), Vector3(1.4, 4.4, 1.4), 0.0, Color(0.12, 0.16, 0.30), true)
	_add_local_sky_block(asset, "ActiveSkyAnchorPanel", Vector3(0, 4.9, -0.45), Vector3(5.2, 2.2, 0.16), 0.0, color, false)
	var calibrated := _add_local_sky_block(asset, "CalibratedStarPanel", Vector3(0, 4.9, -0.65), Vector3(5.2, 2.2, 0.16), 0.0, Color(0.92, 0.96, 1.0, 0.34), false)
	calibrated.visible = false
	_add_sky_anchor_glow(asset, color)
	while sky_anchor_visuals.size() <= node_index:
		sky_anchor_visuals.append(null)
	sky_anchor_visuals[node_index] = asset

	var area := Area3D.new()
	area.name = "%sArea" % String(data[0])
	area.position = pos + Vector3(0, 1.3, 0)
	area.collision_layer = 0
	area.collision_mask = 2
	var shape := CollisionShape3D.new()
	var sphere := SphereShape3D.new()
	sphere.radius = 4.8
	shape.shape = sphere
	area.add_child(shape)
	area.body_entered.connect(func(body: Node3D): _on_sky_anchor_entered(body, node_index))
	area.body_exited.connect(func(body: Node3D): _on_sky_anchor_exited(body, node_index))
	manifested_city.add_child(area)
	while sky_anchor_areas.size() <= node_index:
		sky_anchor_areas.append(null)
	sky_anchor_areas[node_index] = area

func _add_sky_anchor_glow(asset: Node3D, color: Color) -> void:
	var halo := CSGCylinder3D.new()
	halo.name = "SkyAnchorGlow"
	halo.radius = 3.4
	halo.height = 0.04
	halo.sides = 48
	halo.position = Vector3(0, 0.12, 0)
	halo.material = _emissive_mat(color, 0.28, sky_anchor_glow_energy)
	asset.add_child(halo)
	var light := OmniLight3D.new()
	light.name = "SkyAnchorLight"
	light.position = Vector3(0, 4.4, 0)
	light.light_color = color
	light.light_energy = sky_anchor_glow_energy
	light.omni_range = 10.0
	asset.add_child(light)
	var particles := GPUParticles3D.new()
	particles.name = "SkyAnchorParticles"
	particles.amount = int(maxf(1.0, 86.0 * sky_anchor_particle_scale))
	particles.lifetime = 3.0
	particles.visibility_aabb = AABB(Vector3(-5, -1, -5), Vector3(10, 9, 10))
	var mesh := QuadMesh.new()
	mesh.size = Vector2(0.075, 0.075)
	particles.draw_pass_1 = mesh
	var process := ParticleProcessMaterial.new()
	process.emission_shape = ParticleProcessMaterial.EMISSION_SHAPE_SPHERE
	process.emission_sphere_radius = 2.9
	process.gravity = Vector3.ZERO
	process.initial_velocity_min = 0.03
	process.initial_velocity_max = 0.26
	process.spread = 100.0
	process.color = Color(color.r, color.g, color.b, 0.72)
	particles.process_material = process
	particles.position = Vector3(0, 3.2, 0)
	particles.emitting = true
	asset.add_child(particles)

func _set_sky_anchor_visual_state(node_index: int, calibrated: bool) -> void:
	if node_index < 0 or node_index >= sky_anchor_visuals.size():
		return
	var asset := sky_anchor_visuals[node_index]
	if asset == null:
		return
	var active := asset.get_node_or_null("ActiveSkyAnchorPanel")
	if active != null:
		active.visible = not calibrated
	var done := asset.get_node_or_null("CalibratedStarPanel")
	if done != null:
		done.visible = calibrated
	for name in ["SkyAnchorGlow", "SkyAnchorLight", "SkyAnchorParticles"]:
		var child := asset.get_node_or_null(name)
		if child != null:
			child.visible = not calibrated

func _build_continuous_city_whitebox(parent: Node3D) -> void:
	_build_continuous_city_terrain(parent)
	_build_continuous_leonia_daily_zone(parent)
	_build_continuous_trude_repeat_zone(parent)
	_build_continuous_procopia_crowd_zone(parent)
	_build_continuous_cecilia_pasture_zone(parent)
	_build_continuous_penthesilea_centerless_zone(parent)
	_build_continuous_center_core(parent)
	_build_continuous_atmosphere(parent)

func _build_continuous_city_terrain(parent: Node3D) -> void:
	var terrain := _make_city_zone(parent, "ContinuousCity_InfinitePlainTerrain")
	_add_continuous_block(terrain, "PollutionPlainGround", Vector3(0, -0.055, 0), Vector3(238, 0.11, 238), 0.0, Color(0.46, 0.43, 0.30), true, 0.72, 0.92)
	_add_continuous_block(terrain, "LowAsphaltCitySkin", Vector3(0, 0.01, -2), Vector3(186, 0.04, 194), 0.0, Color(0.28, 0.28, 0.24), true, 0.68, 1.10)
	_add_continuous_block(terrain, "MainContinuousRoad_SouthNorth", Vector3(0, 0.08, 0), Vector3(10, 0.08, 206), 0.0, Color(0.22, 0.22, 0.20), true, 0.82, 1.35)
	_add_continuous_block(terrain, "CrossContinuousRoad_EastWest", Vector3(0, 0.09, -12), Vector3(178, 0.08, 9), 0.0, Color(0.22, 0.22, 0.20), true, 0.82, 1.35)
	for i in range(12):
		var z := -96.0 + float(i) * 17.0
		_add_continuous_block(terrain, "RepeatedSideStreet_%02d" % i, Vector3(0, 0.095, z), Vector3(164, 0.06, 3.2), 0.0, Color(0.25, 0.25, 0.22), true, 0.76, 1.18)
	for i in range(12):
		var x := -90.0 + float(i) * 16.5
		_add_continuous_block(terrain, "RepeatedLongBlockLane_%02d" % i, Vector3(x, 0.10, -6), Vector3(3.0, 0.06, 188), 0.0, Color(0.24, 0.24, 0.21), true, 0.74, 1.12)
	for i in range(22):
		var side := -1.0 if i % 2 == 0 else 1.0
		var z := -96.0 + float(i) * 8.8
		_build_repeated_streetlight(terrain, "RepeatedStreetlight_%02d" % i, Vector3(side * 8.2, 0, z), 0.0)

func _build_continuous_leonia_daily_zone(parent: Node3D) -> void:
	var zone := _make_city_zone(parent, "ZoneA_LeoniaDailyRenewal")
	_build_new_goods_apartment(zone, Vector3(-10, 0, -82), 0.0)
	_build_sanitation_altar(zone, Vector3(-32, 0, -68), 8.0)
	_build_waste_fortress(zone, Vector3(30, 0, -70), -12.0)
	_build_garbage_ridge(zone, "GarbageRidge_South", Vector3(0, 0, -106), 0.0)
	var daily_props := [
		["NewSheet", Vector3(-20, 0, -84), Vector3(4.0, 0.10, 2.6), Color(0.86, 0.84, 0.74)],
		["NewSoapBox", Vector3(-6, 0, -76), Vector3(1.6, 0.7, 1.0), Color(0.92, 0.90, 0.78)],
		["UnopenedCan", Vector3(-2, 0, -88), Vector3(1.0, 1.1, 1.0), Color(0.70, 0.72, 0.64)],
		["NewRadio", Vector3(-17, 0, -75), Vector3(2.3, 1.4, 1.1), Color(0.18, 0.18, 0.16)],
		["PlasticGarbageBag", Vector3(8, 0, -66), Vector3(2.4, 1.3, 1.9), Color(0.74, 0.76, 0.70, 0.82)],
		["ToothpasteTube", Vector3(24, 0, -60), Vector3(2.2, 0.4, 0.5), Color(0.78, 0.74, 0.60)],
		["BurntBulb", Vector3(36, 0, -62), Vector3(0.9, 0.9, 0.9), Color(0.62, 0.60, 0.50)],
		["OldEncyclopedia", Vector3(38, 0, -74), Vector3(2.8, 0.55, 2.0), Color(0.28, 0.22, 0.16)],
		["DiscardedPiano", Vector3(42, 0, -82), Vector3(5.0, 2.2, 2.0), Color(0.10, 0.09, 0.08)],
		["WasteTire", Vector3(22, 0, -78), Vector3(2.0, 0.7, 2.0), Color(0.05, 0.05, 0.045)],
		["BelliedBottle", Vector3(50, 0, -68), Vector3(1.0, 1.8, 1.0), Color(0.26, 0.50, 0.34, 0.70)]
	]
	for prop in daily_props:
		_build_continuous_simple_prop(zone, String(prop[0]), prop[1], 0.0, prop[2], prop[3], false)
	_build_continuous_sprawl_node(zone, 0, Vector3(24, 0, -56), -10.0)

func _build_continuous_trude_repeat_zone(parent: Node3D) -> void:
	var zone := _make_city_zone(parent, "ZoneB_TrudeIdenticalAirport")
	_build_airport_entrance_hall(zone, Vector3(64, 0, -58), -90.0)
	_build_airport_name_sign(zone, Vector3(52, 0, -43), -90.0)
	for i in range(10):
		var x := 44.0 + float(i % 2) * 18.0
		var z := -32.0 + float(i / 2) * 12.0
		_build_identical_suburb_house(zone, "IdenticalSuburbHouse_%02d" % i, Vector3(x, 0, z), 0.0)
	for i in range(8):
		_build_continuous_simple_prop(zone, "IdenticalCommercialStreet_%02d" % i, Vector3(72, 0, -28.0 + float(i) * 9.0), -90.0, Vector3(8.5, 4.2, 6.0), Color(0.58, 0.56, 0.42), true)
	_build_continuous_simple_prop(zone, "IdenticalHotel", Vector3(52, 0, 26), 0.0, Vector3(18, 13, 12), Color(0.52, 0.56, 0.46), true)
	for i in range(6):
		_build_continuous_simple_prop(zone, "IdenticalRoadSign_%02d" % i, Vector3(38.0 + float(i % 2) * 30.0, 0, -20.0 + float(i / 2) * 19.0), 0.0, Vector3(3.8, 2.8, 0.16), Color(0.72, 0.70, 0.52), false)
	for i in range(4):
		_build_continuous_simple_prop(zone, "IdenticalFlowerbed_%02d" % i, Vector3(52.0 + float(i) * 6.0, 0.08, -4), 0.0, Vector3(4.2, 0.18, 2.4), Color(0.34, 0.44, 0.24), false)
	_build_continuous_simple_prop(zone, "IdenticalGlass", Vector3(61, 0, 30), 0.0, Vector3(0.8, 1.3, 0.8), Color(0.82, 0.90, 0.86, 0.36), false)
	_build_continuous_sprawl_node(zone, 1, Vector3(58, 0, -8), -90.0)

func _build_continuous_procopia_crowd_zone(parent: Node3D) -> void:
	var zone := _make_city_zone(parent, "ZoneC_ProcopiaCrowdWindow")
	_build_procopia_hotel_room(zone, Vector3(-66, 0, -18), 90.0)
	_build_continuous_simple_prop(zone, "LowWallBridgeView", Vector3(-44, 0, -18), 90.0, Vector3(20, 1.2, 2.2), Color(0.52, 0.50, 0.42), true)
	_build_continuous_simple_prop(zone, "CornfieldView", Vector3(-46, 0.08, -2), 0.0, Vector3(26, 0.16, 14), Color(0.62, 0.58, 0.22), false)
	for i in range(12):
		_build_continuous_simple_prop(zone, "CornCob_%02d" % i, Vector3(-56.0 + float(i % 4) * 5.2, 0.2, -7.0 + float(i / 4) * 5.4), 0.0, Vector3(0.42, 1.2, 0.42), Color(0.76, 0.62, 0.18), false)
	_build_procopia_window_crowd(zone, Vector3(-55, 0, -20), 0.0)
	_build_continuous_simple_prop(zone, "Ditch", Vector3(-32, 0.02, -26), 0.0, Vector3(14, 0.10, 3.0), Color(0.18, 0.16, 0.12), false)
	_build_continuous_simple_prop(zone, "RowanTree", Vector3(-38, 0, -6), 0.0, Vector3(1.2, 6.0, 1.2), Color(0.36, 0.30, 0.18), false)
	_build_continuous_simple_prop(zone, "BlackberryBramble", Vector3(-30, 0.4, -2), 0.0, Vector3(8.0, 0.8, 2.2), Color(0.12, 0.18, 0.08), false)
	_build_continuous_simple_prop(zone, "ChickenCoop", Vector3(-36, 0, 8), 0.0, Vector3(5.0, 2.4, 4.0), Color(0.42, 0.30, 0.18), true)
	_build_continuous_simple_prop(zone, "YellowHillock", Vector3(-18, 0.3, 12), 0.0, Vector3(14, 0.6, 8), Color(0.58, 0.48, 0.24), false)
	_build_continuous_simple_prop(zone, "WhiteCloud", Vector3(-40, 12.0, 14), 0.0, Vector3(12, 1.2, 4.0), Color(0.84, 0.84, 0.78, 0.30), false)
	_build_continuous_sprawl_node(zone, 2, Vector3(-58, 0, -4), 90.0)

func _build_continuous_cecilia_pasture_zone(parent: Node3D) -> void:
	var zone := _make_city_zone(parent, "ZoneD_CeciliaEndlessBlocks")
	for i in range(24):
		var x := -72.0 + float(i % 6) * 13.0
		var z := 44.0 + float(i / 6) * 12.0
		var height := 5.0 + float((i * 5) % 8)
		_build_continuous_simple_prop(zone, "EndlessCityBlocks_%02d" % i, Vector3(x, 0, z), float(i % 5) * 2.0, Vector3(9.0, height, 8.0), Color(0.44, 0.44, 0.36), true)
	_build_continuous_simple_prop(zone, "TrafficIsland", Vector3(-20, 0.10, 48), 0.0, Vector3(16, 0.2, 7), Color(0.36, 0.38, 0.30), true)
	_build_continuous_simple_prop(zone, "SheepStreet", Vector3(-28, 0.10, 68), 0.0, Vector3(58, 0.18, 6), Color(0.26, 0.26, 0.23), true)
	for i in range(14):
		_build_bell_sheep(zone, "BellSheep_%02d" % i, Vector3(-52.0 + float(i) * 4.3, 0, 68.0 + sin(float(i)) * 2.0), 0.0)
	_build_continuous_simple_prop(zone, "WanderingShepherd", Vector3(-15, 0, 60), 0.0, Vector3(1.2, 3.6, 1.0), Color(0.34, 0.26, 0.16), false)
	_build_continuous_simple_prop(zone, "Sheepdog", Vector3(-10, 0, 66), 0.0, Vector3(2.4, 1.0, 0.8), Color(0.10, 0.10, 0.08), false)
	_build_continuous_simple_prop(zone, "TrashBinCorner", Vector3(-4, 0, 42), 0.0, Vector3(5.0, 2.5, 4.0), Color(0.18, 0.20, 0.17), true)
	_build_continuous_simple_prop(zone, "PaperTrashBin", Vector3(-1, 0, 45), 0.0, Vector3(2.2, 2.6, 2.2), Color(0.22, 0.23, 0.20), false)
	_build_continuous_simple_prop(zone, "SageGrassPatch", Vector3(-26, 0.12, 52), 0.0, Vector3(10.0, 0.24, 4.0), Color(0.38, 0.46, 0.28), false)
	_build_continuous_sprawl_node(zone, 3, Vector3(-20, 0, 54), 0.0)

func _build_continuous_penthesilea_centerless_zone(parent: Node3D) -> void:
	var zone := _make_city_zone(parent, "ZoneE_PenthesileaCenterlessSuburb")
	_build_continuous_simple_prop(zone, "DilutedSuburbCity", Vector3(36, 0, 62), 0.0, Vector3(36, 4.4, 24), Color(0.48, 0.46, 0.36), true)
	for i in range(9):
		_build_continuous_simple_prop(zone, "BrokenCombStreet_%02d" % i, Vector3(20.0 + float(i) * 6.0, 0.10, 44.0 + float(i % 2) * 8.0), 0.0, Vector3(4.0, 0.16, 12.0), Color(0.25, 0.25, 0.22), true)
	for i in range(8):
		_build_continuous_simple_prop(zone, "PlankFenceDistrict_%02d" % i, Vector3(12.0 + float(i) * 7.0, 1.4, 76.0 + sin(float(i)) * 4.0), 6.0, Vector3(5.4, 2.8, 0.28), Color(0.34, 0.24, 0.12), true)
	for i in range(7):
		_build_continuous_simple_prop(zone, "TinShackCluster_%02d" % i, Vector3(58.0 + float(i % 3) * 9.0, 0, 58.0 + float(i / 3) * 10.0), -8.0 + float(i) * 3.0, Vector3(6.2, 3.2, 5.0), Color(0.46, 0.46, 0.42), true)
	_build_continuous_simple_prop(zone, "WorkshopWarehouseZone", Vector3(30, 0, 90), 0.0, Vector3(36, 8.0, 18), Color(0.36, 0.34, 0.28), true)
	_build_cemetery_fairground(zone, Vector3(70, 0, 90), 0.0)
	_build_continuous_simple_prop(zone, "Slaughterhouse", Vector3(78, 0, 52), -10.0, Vector3(20, 6.0, 12), Color(0.36, 0.20, 0.16), true)
	_build_continuous_simple_prop(zone, "CenterlessAlley", Vector3(38, 0.10, 78), 32.0, Vector3(64, 0.14, 3.4), Color(0.23, 0.23, 0.20), true)
	for i in range(11):
		_build_continuous_simple_prop(zone, "WastelandGrass_%02d" % i, Vector3(10.0 + float(i) * 8.5, 0.12, 102.0 + sin(float(i) * 1.7) * 8.0), 0.0, Vector3(5.0, 0.24, 2.8), Color(0.32, 0.40, 0.20), false)
	_build_continuous_simple_prop(zone, "ShopAlley", Vector3(18, 0, 62), 18.0, Vector3(20, 3.6, 6), Color(0.46, 0.38, 0.28), true)
	_build_continuous_simple_prop(zone, "HorizonShadow", Vector3(8, 2.6, 112), 0.0, Vector3(92, 5.2, 0.16), Color(0.06, 0.06, 0.05, 0.32), false)
	_build_continuous_simple_prop(zone, "SparseLitWindow", Vector3(50, 4.0, 61), 0.0, Vector3(2.0, 1.1, 0.14), Color(0.92, 0.72, 0.34, 0.54), false)
	_build_continuous_sprawl_node(zone, 4, Vector3(38, 0, 78), 32.0)

func _build_continuous_center_core(parent: Node3D) -> void:
	var zone := _make_city_zone(parent, "ZoneF_ContinuousCenterCore")
	_build_continuous_cylinder_prop(zone, "ContinuousCoreRoundabout", Vector3(0, 0.12, 0), 18.0, 0.12, Color(0.32, 0.32, 0.25), true)
	for i in range(12):
		var angle := TAU * float(i) / 12.0
		_add_continuous_line_span(zone, "CenterlessRouteLine_%02d" % i, Vector3(0, 0.36, 0), Vector3(cos(angle) * 23.0, 0.36, sin(angle) * 23.0), Color(0.66, 0.62, 0.42, 0.42), 0.16)
	_build_centerless_sign(zone, Vector3(0, 0, 0), 0.0)
	continuous_goal_trigger = Area3D.new()
	continuous_goal_trigger.name = "ContinuousGoalTrigger"
	continuous_goal_trigger.position = Vector3(0, 1.1, 0)
	continuous_goal_trigger.collision_layer = 0
	continuous_goal_trigger.collision_mask = 2
	var shape := CollisionShape3D.new()
	var sphere := SphereShape3D.new()
	sphere.radius = 9.0
	shape.shape = sphere
	continuous_goal_trigger.add_child(shape)
	continuous_goal_trigger.body_entered.connect(_on_continuous_goal_entered)
	continuous_goal_trigger.body_exited.connect(_on_continuous_goal_exited)
	manifested_city.add_child(continuous_goal_trigger)

func _build_continuous_atmosphere(parent: Node3D) -> void:
	var atmosphere := Node3D.new()
	atmosphere.name = "ContinuousCityAtmosphere_StyleDirection"
	parent.add_child(atmosphere)
	atmosphere.add_child(_make_city_particle_layer("PlasticBagParticles", 760, Vector2(0.18, 0.10), Vector3(112, 8, 112), Vector3(0.14, 0.05, -0.08), Color(0.82, 0.82, 0.74, 0.30), 0.04, 0.26, 100.0, 15.0))
	atmosphere.add_child(_make_city_particle_layer("WastePaperParticles", 980, Vector2(0.13, 0.075), Vector3(118, 7, 118), Vector3(-0.08, 0.04, 0.16), Color(0.76, 0.72, 0.58, 0.32), 0.04, 0.32, 100.0, 13.0))
	atmosphere.add_child(_make_city_particle_layer("SmokeDustParticles", 1400, Vector2(0.075, 0.075), Vector3(124, 9, 124), Vector3(0.05, 0.12, 0.02), Color(0.48, 0.45, 0.34, 0.22), 0.02, 0.18, 100.0, 17.0))
	atmosphere.add_child(_make_city_particle_layer("IndustrialPowderParticles", 1200, Vector2(0.038, 0.038), Vector3(124, 5, 124), Vector3(-0.03, 0.04, 0.05), Color(0.58, 0.54, 0.40, 0.24), 0.02, 0.16, 100.0, 12.0))
	for i in range(10):
		var angle := TAU * float(i) / 10.0
		_add_city_style_veil(atmosphere, "PollutionFogVeil_%02d" % i, Vector3(cos(angle) * 48.0, 4.0 + float(i % 3) * 0.9, sin(angle) * 48.0), Vector2(78, 13), rad_to_deg(angle) + 90.0, Color(0.66, 0.62, 0.42, 0.18), 0.0, 720.0 + float(i) * 5.7, continuous_city_style_intensity * 0.82)
	for i in range(8):
		_add_continuous_block(atmosphere, "DirtyDecalStrip_%02d" % i, Vector3(-78.0 + float(i) * 22.0, 0.16, -28.0 + float(i % 2) * 62.0), Vector3(14.0, 0.035, 2.2), -8.0 + float(i) * 5.0, Color(0.08, 0.07, 0.05, 0.24), false, 0.95, 1.6)

func _build_new_goods_apartment(parent: Node3D, pos: Vector3, yaw: float) -> void:
	var asset := _make_city_asset(parent, "NewGoodsApartment", pos, yaw)
	_add_local_continuous_block(asset, "ApartmentBody", Vector3(0, 8.0, 0), Vector3(20, 16, 13), 0.0, Color(0.60, 0.58, 0.48), true, 0.48, 0.92)
	for floor in range(4):
		for col in range(4):
			_add_local_continuous_block(asset, "WrappedWindow_%02d_%02d" % [floor, col], Vector3(-7.2 + float(col) * 4.8, 3.2 + float(floor) * 3.2, -6.62), Vector3(2.1, 1.2, 0.12), 0.0, Color(0.78, 0.78, 0.66, 0.58), false, 0.24, 0.70)
	_add_local_continuous_block(asset, "FreshFacadePanel", Vector3(0, 16.6, -6.8), Vector3(16, 1.4, 0.16), 0.0, Color(0.82, 0.80, 0.64), false, 0.18, 0.80)

func _build_sanitation_altar(parent: Node3D, pos: Vector3, yaw: float) -> void:
	var asset := _make_city_asset(parent, "SanitationAltar", pos, yaw)
	_add_local_continuous_block(asset, "RitualPlatform", Vector3(0, 0.35, 0), Vector3(12, 0.7, 8), 0.0, Color(0.44, 0.42, 0.34), true, 0.54, 0.90)
	_add_local_continuous_block(asset, "SilentCollectorPillar", Vector3(-3.5, 2.2, 0), Vector3(1.2, 4.4, 1.2), 0.0, Color(0.62, 0.60, 0.48), true, 0.46, 0.82)
	_add_local_continuous_block(asset, "SilentCollectorPillar", Vector3(3.5, 2.2, 0), Vector3(1.2, 4.4, 1.2), 0.0, Color(0.62, 0.60, 0.48), true, 0.46, 0.82)
	_add_local_continuous_block(asset, "OfferingWasteBundle", Vector3(0, 1.1, 0), Vector3(5.2, 1.4, 3.6), 0.0, Color(0.34, 0.32, 0.24), false, 0.88, 1.15)

func _build_waste_fortress(parent: Node3D, pos: Vector3, yaw: float) -> void:
	var asset := _make_city_asset(parent, "WasteFortress", pos, yaw)
	for i in range(18):
		var x := -10.0 + float(i % 6) * 4.0
		var z := -4.0 + float(i / 6) * 4.2
		var h := 1.8 + float((i * 3) % 5) * 0.9
		_add_local_continuous_block(asset, "CompressedWasteBlock_%02d" % i, Vector3(x, h * 0.5, z), Vector3(4.6, h, 3.6), float(i) * 5.0, Color(0.36, 0.34, 0.25), true, 0.96, 1.38)
	_add_local_continuous_block(asset, "FortressCrest", Vector3(0, 7.0, 4.5), Vector3(23, 2.0, 4.0), 0.0, Color(0.28, 0.27, 0.20), false, 1.0, 1.5)

func _build_garbage_ridge(parent: Node3D, name: String, pos: Vector3, yaw: float) -> void:
	var asset := _make_city_asset(parent, name, pos, yaw)
	for i in range(16):
		var x := -70.0 + float(i) * 9.2
		var h := 2.0 + float(i % 5) * 0.9
		_add_local_continuous_block(asset, "GarbageRidgeChunk_%02d" % i, Vector3(x, h * 0.5, sin(float(i)) * 2.2), Vector3(10.5, h, 7.0), float(i % 3) * 4.0, Color(0.30, 0.29, 0.22), true, 0.98, 1.44)

func _build_airport_entrance_hall(parent: Node3D, pos: Vector3, yaw: float) -> void:
	var asset := _make_city_asset(parent, "AirportEntranceHall", pos, yaw)
	_add_local_continuous_block(asset, "TerminalSlab", Vector3(0, 5.0, 0), Vector3(28, 10, 14), 0.0, Color(0.56, 0.58, 0.48), true, 0.42, 0.92)
	_add_local_continuous_block(asset, "SlidingDoorBand", Vector3(0, 2.1, -7.2), Vector3(18, 2.6, 0.18), 0.0, Color(0.22, 0.26, 0.24, 0.52), false, 0.22, 0.72)
	_add_local_continuous_block(asset, "GiantLetterSign", Vector3(0, 10.8, -7.4), Vector3(22, 2.1, 0.18), 0.0, Color(0.72, 0.18, 0.12), false, 0.34, 0.90)

func _build_airport_name_sign(parent: Node3D, pos: Vector3, yaw: float) -> void:
	var asset := _make_city_asset(parent, "AirportNameSign", pos, yaw)
	_add_local_continuous_block(asset, "SignPoleA", Vector3(-5, 2.5, 0), Vector3(0.6, 5, 0.6), 0.0, Color(0.30, 0.30, 0.26), true, 0.62, 0.95)
	_add_local_continuous_block(asset, "SignPoleB", Vector3(5, 2.5, 0), Vector3(0.6, 5, 0.6), 0.0, Color(0.30, 0.30, 0.26), true, 0.62, 0.95)
	_add_local_continuous_block(asset, "ChangeableCityNamePanel", Vector3(0, 5.2, 0), Vector3(14, 3.0, 0.28), 0.0, Color(0.74, 0.72, 0.54), false, 0.48, 0.82)

func _build_identical_suburb_house(parent: Node3D, name: String, pos: Vector3, yaw: float) -> void:
	var asset := _make_city_asset(parent, name, pos, yaw)
	_add_local_continuous_block(asset, "YellowGreenHouseBody", Vector3(0, 2.3, 0), Vector3(7.6, 4.6, 6.4), 0.0, Color(0.60, 0.62, 0.38), true, 0.44, 0.86)
	_add_local_continuous_block(asset, "RepeatedRoof", Vector3(0, 5.0, 0), Vector3(8.6, 1.2, 7.2), 0.0, Color(0.34, 0.38, 0.22), false, 0.46, 0.88)
	_add_local_continuous_block(asset, "SameWindow", Vector3(-2.2, 2.8, -3.3), Vector3(1.4, 1.2, 0.12), 0.0, Color(0.78, 0.76, 0.58, 0.48), false, 0.24, 0.72)
	_add_local_continuous_block(asset, "SameWindow", Vector3(2.2, 2.8, -3.3), Vector3(1.4, 1.2, 0.12), 0.0, Color(0.78, 0.76, 0.58, 0.48), false, 0.24, 0.72)

func _build_procopia_hotel_room(parent: Node3D, pos: Vector3, yaw: float) -> void:
	var asset := _make_city_asset(parent, "HotelRoom", pos, yaw)
	_add_local_continuous_block(asset, "RoomFloor", Vector3(0, 0.1, 0), Vector3(28, 0.2, 18), 0.0, Color(0.34, 0.32, 0.26), true, 0.64, 0.90)
	_add_local_continuous_block(asset, "BackWall", Vector3(0, 4.0, 8.8), Vector3(28, 8, 0.4), 0.0, Color(0.52, 0.50, 0.42), true, 0.58, 0.92)
	_add_local_continuous_block(asset, "LeftWall", Vector3(-14, 4.0, 0), Vector3(0.4, 8, 18), 0.0, Color(0.48, 0.46, 0.38), true, 0.58, 0.92)
	_add_local_continuous_block(asset, "RightWall", Vector3(14, 4.0, 0), Vector3(0.4, 8, 18), 0.0, Color(0.48, 0.46, 0.38), true, 0.58, 0.92)
	_add_local_continuous_block(asset, "WindowViewFrame", Vector3(0, 4.2, -9.0), Vector3(16, 7.0, 0.32), 0.0, Color(0.24, 0.22, 0.18), false, 0.42, 0.86)
	_add_local_continuous_block(asset, "WindowOpening", Vector3(0, 4.2, -9.18), Vector3(12, 4.8, 0.12), 0.0, Color(0.74, 0.72, 0.58, 0.22), false, 0.28, 0.72)

func _build_procopia_window_crowd(parent: Node3D, pos: Vector3, yaw: float) -> void:
	var asset := _make_city_asset(parent, "CrowdFilledRoom", pos, yaw)
	for i in range(30):
		var x := -11.0 + float(i % 6) * 4.2
		var z := -5.0 + float(i / 6) * 2.6
		var y := 1.0 + float((i / 6) % 2) * 0.55
		_add_local_continuous_block(asset, "RoundFacedCrowd_%02d" % i, Vector3(x, y, z), Vector3(2.0, 2.0, 0.42), 0.0, Color(0.76, 0.70, 0.58), false, 0.36, 0.78)
		if i % 4 == 0:
			_add_local_continuous_block(asset, "BlackberryStain_%02d" % i, Vector3(x + 0.3, y - 0.22, z - 0.24), Vector3(0.42, 0.18, 0.06), 0.0, Color(0.18, 0.05, 0.08), false, 0.20, 0.50)

func _build_bell_sheep(parent: Node3D, name: String, pos: Vector3, yaw: float) -> void:
	var asset := _make_city_asset(parent, name, pos, yaw)
	_add_local_continuous_block(asset, "SheepBody", Vector3(0, 0.85, 0), Vector3(2.2, 1.2, 1.1), 0.0, Color(0.74, 0.72, 0.62), false, 0.42, 0.76)
	_add_local_continuous_block(asset, "SheepHead", Vector3(1.35, 0.95, 0), Vector3(0.7, 0.7, 0.7), 0.0, Color(0.58, 0.54, 0.44), false, 0.44, 0.76)
	_add_local_continuous_block(asset, "CopperBell", Vector3(0.6, 0.36, 0), Vector3(0.36, 0.42, 0.24), 0.0, Color(0.76, 0.42, 0.16), false, 0.26, 0.68)

func _build_cemetery_fairground(parent: Node3D, pos: Vector3, yaw: float) -> void:
	var asset := _make_city_asset(parent, "CemeteryFairground", pos, yaw)
	_add_local_continuous_block(asset, "FairgroundBase", Vector3(0, 0.12, 0), Vector3(24, 0.24, 16), 0.0, Color(0.28, 0.30, 0.22), true, 0.76, 1.05)
	_add_local_continuous_block(asset, "FerrisWheelMast", Vector3(0, 5.5, 0), Vector3(0.5, 11.0, 0.5), 0.0, Color(0.36, 0.34, 0.30), false, 0.58, 0.90)
	for i in range(8):
		var angle := TAU * float(i) / 8.0
		_add_local_continuous_block(asset, "FerrisWheelSpoke_%02d" % i, Vector3(cos(angle) * 3.2, 5.5 + sin(angle) * 3.2, 0), Vector3(0.18, 6.6, 0.18), -rad_to_deg(angle), Color(0.48, 0.46, 0.38), false, 0.54, 0.86)
		_add_local_continuous_block(asset, "FerrisWheelCabin_%02d" % i, Vector3(cos(angle) * 6.0, 5.5 + sin(angle) * 6.0, 0), Vector3(1.2, 0.7, 1.0), 0.0, Color(0.60, 0.36, 0.24), false, 0.48, 0.82)
	for i in range(7):
		_add_local_continuous_block(asset, "CemeteryMarker_%02d" % i, Vector3(-10.0 + float(i) * 3.2, 0.7, 6.0), Vector3(0.8, 1.4, 0.24), 0.0, Color(0.42, 0.42, 0.36), false, 0.72, 0.92)

func _build_centerless_sign(parent: Node3D, pos: Vector3, yaw: float) -> void:
	var asset := _make_city_asset(parent, "CenterlessSign", pos, yaw)
	_add_local_continuous_block(asset, "CenterlessSignPole", Vector3(0, 3.0, 0), Vector3(0.7, 6.0, 0.7), 0.0, Color(0.24, 0.24, 0.20), true, 0.68, 0.92)
	for i in range(8):
		var angle := float(i) * 45.0
		_add_local_continuous_block(asset, "ContradictoryDirectionPanel_%02d" % i, Vector3(cos(deg_to_rad(angle)) * 1.4, 5.4 + float(i % 2) * 0.55, sin(deg_to_rad(angle)) * 1.4), Vector3(5.2, 1.0, 0.18), -angle, Color(0.72, 0.66, 0.42), false, 0.66, 1.00)
	_build_continuous_simple_prop(parent, "CrowdNoiseSource", pos + Vector3(-7, 0, 4), 0.0, Vector3(2.8, 2.8, 2.8), Color(0.64, 0.60, 0.48, 0.42), false)

func _build_repeated_streetlight(parent: Node3D, name: String, pos: Vector3, yaw: float) -> void:
	var asset := _make_city_asset(parent, name, pos, yaw)
	_add_local_continuous_block(asset, "LampPost", Vector3(0, 2.6, 0), Vector3(0.28, 5.2, 0.28), 0.0, Color(0.24, 0.24, 0.20), false, 0.62, 0.86)
	_add_local_continuous_block(asset, "WarmLampBox", Vector3(0, 5.4, 0), Vector3(1.0, 0.8, 1.0), 0.0, Color(0.82, 0.66, 0.36, 0.42), false, 0.28, 0.62)

func _continuous_node_color(node_index: int) -> Color:
	return CONTINUOUS_SPRAWL_COLORS[clampi(node_index, 0, CONTINUOUS_SPRAWL_COLORS.size() - 1)]

func _build_continuous_sprawl_node(parent: Node3D, node_index: int, pos: Vector3, yaw: float) -> void:
	var data: Array = CONTINUOUS_SPRAWL_NODES[node_index]
	var color := _continuous_node_color(node_index)
	var asset := _make_city_asset(parent, String(data[0]), pos, yaw)
	_add_local_continuous_block(asset, "NodeColumn", Vector3(0, 2.0, 0), Vector3(1.3, 4.0, 1.3), 0.0, Color(0.26, 0.25, 0.20), true, 0.78, 1.0)
	_add_local_continuous_block(asset, "ActiveSprawlPanel", Vector3(0, 4.5, -0.48), Vector3(5.2, 2.0, 0.16), 0.0, color, false, 0.48, 0.92)
	var settled := _add_local_continuous_block(asset, "SettledDustPanel", Vector3(0, 4.5, -0.66), Vector3(5.2, 2.0, 0.16), 0.0, Color(0.82, 0.78, 0.62, 0.28), false, 0.85, 1.20)
	settled.visible = false
	_add_continuous_node_glow(asset, color)
	while continuous_node_visuals.size() <= node_index:
		continuous_node_visuals.append(null)
	continuous_node_visuals[node_index] = asset

	var area := Area3D.new()
	area.name = "%sArea" % String(data[0])
	area.position = pos + Vector3(0, 1.2, 0)
	area.collision_layer = 0
	area.collision_mask = 2
	var shape := CollisionShape3D.new()
	var sphere := SphereShape3D.new()
	sphere.radius = 4.8
	shape.shape = sphere
	area.add_child(shape)
	area.body_entered.connect(func(body: Node3D): _on_continuous_node_entered(body, node_index))
	area.body_exited.connect(func(body: Node3D): _on_continuous_node_exited(body, node_index))
	manifested_city.add_child(area)
	while continuous_node_areas.size() <= node_index:
		continuous_node_areas.append(null)
	continuous_node_areas[node_index] = area

func _add_continuous_node_glow(asset: Node3D, color: Color) -> void:
	var halo := CSGCylinder3D.new()
	halo.name = "ContinuousNodeGlow"
	halo.radius = 3.4
	halo.height = 0.035
	halo.sides = 48
	halo.position = Vector3(0, 0.10, 0)
	halo.material = _emissive_mat(color, 0.26, continuous_node_glow_energy)
	asset.add_child(halo)
	var light := OmniLight3D.new()
	light.name = "ContinuousNodeLight"
	light.position = Vector3(0, 3.7, 0)
	light.light_color = color
	light.light_energy = continuous_node_glow_energy
	light.omni_range = 8.5
	asset.add_child(light)
	var particles := GPUParticles3D.new()
	particles.name = "ContinuousNodeDustParticles"
	particles.amount = int(maxf(1.0, 88.0 * continuous_node_particle_scale))
	particles.lifetime = 2.6
	particles.visibility_aabb = AABB(Vector3(-5, -1, -5), Vector3(10, 8, 10))
	var mesh := QuadMesh.new()
	mesh.size = Vector2(0.11, 0.07)
	particles.draw_pass_1 = mesh
	var process := ParticleProcessMaterial.new()
	process.emission_shape = ParticleProcessMaterial.EMISSION_SHAPE_SPHERE
	process.emission_sphere_radius = 2.8
	process.gravity = Vector3(0, -0.02, 0)
	process.initial_velocity_min = 0.03
	process.initial_velocity_max = 0.24
	process.spread = 100.0
	process.color = Color(color.r, color.g, color.b, 0.70)
	particles.process_material = process
	particles.position = Vector3(0, 2.8, 0)
	particles.emitting = true
	asset.add_child(particles)

func _set_continuous_node_visual_state(node_index: int, recorded: bool) -> void:
	if node_index < 0 or node_index >= continuous_node_visuals.size():
		return
	var asset := continuous_node_visuals[node_index]
	if asset == null:
		return
	var active := asset.get_node_or_null("ActiveSprawlPanel")
	if active != null:
		active.visible = not recorded
	var settled := asset.get_node_or_null("SettledDustPanel")
	if settled != null:
		settled.visible = recorded
	for name in ["ContinuousNodeGlow", "ContinuousNodeLight", "ContinuousNodeDustParticles"]:
		var child := asset.get_node_or_null(name)
		if child != null:
			child.visible = not recorded

func _build_continuous_simple_prop(parent: Node3D, name: String, pos: Vector3, yaw: float, size: Vector3, color: Color, collision := false) -> Node3D:
	var asset := _make_city_asset(parent, name, pos, yaw)
	_add_local_continuous_block(asset, "WhiteboxReplaceRoot", Vector3(0, size.y * 0.5, 0), size, 0.0, color, collision, 0.56, 0.92)
	return asset

func _add_continuous_block(parent: Node3D, name: String, pos: Vector3, size: Vector3, yaw: float, color: Color, collision := false, grime := 0.58, repetition := 0.92) -> Node3D:
	var box := CSGBox3D.new()
	box.name = name
	box.position = pos
	box.size = size
	box.rotation_degrees.y = yaw
	box.material = _continuous_pollution_material(color, color.a, pos.x * 0.17 + pos.z * 0.21, grime, repetition)
	parent.add_child(box)
	if collision:
		_add_box_collision(name + "Collision", pos, size, yaw)
	return box

func _add_local_continuous_block(asset: Node3D, part_name: String, local_pos: Vector3, size: Vector3, local_yaw: float, color: Color, collision := true, grime := 0.58, repetition := 0.92) -> Node3D:
	var global_pos := _asset_global_pos(asset, local_pos)
	var global_yaw := _asset_global_yaw(asset, local_yaw)
	var box := CSGBox3D.new()
	box.name = part_name
	box.position = local_pos
	box.size = size
	box.rotation_degrees.y = local_yaw
	box.material = _continuous_pollution_material(color, color.a, global_pos.x * 0.17 + global_pos.z * 0.21, grime, repetition)
	asset.add_child(box)
	if collision:
		_add_box_collision("%s_%sCollision" % [asset.name, part_name], global_pos, size, global_yaw)
	return box

func _build_continuous_cylinder_prop(parent: Node3D, name: String, pos: Vector3, radius: float, height: float, color: Color, collision := false) -> Node3D:
	var cylinder := CSGCylinder3D.new()
	cylinder.name = name
	cylinder.radius = radius
	cylinder.height = height
	cylinder.sides = 56
	cylinder.position = pos
	cylinder.material = _continuous_pollution_material(color, color.a, pos.x * 0.13 + pos.z * 0.23, 0.54, 0.90)
	parent.add_child(cylinder)
	if collision:
		_add_box_collision(name + "Collision", pos, Vector3(radius * 2.0, height, radius * 2.0), 0.0)
	return cylinder

func _add_continuous_line_span(parent: Node3D, name: String, a: Vector3, b: Vector3, color: Color, thickness := 0.08) -> Node3D:
	var delta := b - a
	var flat_length := Vector2(delta.x, delta.z).length()
	var yaw := rad_to_deg(atan2(delta.x, delta.z))
	var mid := (a + b) * 0.5
	return _add_continuous_block(parent, name, mid, Vector3(thickness, thickness, maxf(flat_length, 0.1)), yaw, color, false, 0.62, 1.1)

func _build_hidden_city_whitebox(parent: Node3D) -> void:
	_build_hidden_city_terrain(parent)
	_build_hidden_olinda_growth_zone(parent)
	_build_hidden_raissa_joy_zone(parent)
	_build_hidden_marozia_crack_zone(parent)
	_build_hidden_theodora_species_zone(parent)
	_build_hidden_berenice_justice_zone(parent)
	_build_hidden_center_core(parent)
	_build_hidden_atmosphere(parent)

func _build_hidden_city_terrain(parent: Node3D) -> void:
	var terrain := _make_city_zone(parent, "HiddenCity_RainforestRiftTerrain")
	_add_hidden_block(terrain, "DarkJungleRuinGround", Vector3(0, -0.06, 0), Vector3(238, 0.12, 238), 0.0, Color(0.10, 0.18, 0.11), true, 0.66, 0.55)
	_add_hidden_block(terrain, "UndergroundRiftShadow", Vector3(0, -1.25, 20), Vector3(38, 2.4, 180), 5.0, Color(0.02, 0.035, 0.03, 0.88), false, 0.42, 0.88)
	_add_hidden_block(terrain, "HiddenMainPath_SouthNorth", Vector3(0, 0.04, 4), Vector3(7.5, 0.08, 206), 0.0, Color(0.12, 0.16, 0.11), true, 0.54, 0.62)
	_add_hidden_block(terrain, "HiddenCrossPath_EastWest", Vector3(0, 0.05, -10), Vector3(178, 0.08, 7.0), 0.0, Color(0.12, 0.16, 0.11), true, 0.54, 0.62)
	for i in range(18):
		var x := -96.0 + float(i % 6) * 38.0
		var z := -92.0 + float(i / 6) * 66.0
		_build_hidden_tree_pillar(terrain, "RainforestRootPillar_%02d" % i, Vector3(x, 0, z), float(i) * 11.0)
	for i in range(11):
		var z := -92.0 + float(i) * 18.0
		_add_hidden_line_span(terrain, "RootCoveredPathLine_%02d" % i, Vector3(-8, 0.20, z), Vector3(8, 0.20, z + 7.0), Color(0.22, 0.48, 0.24, 0.34), 0.18)

func _build_hidden_olinda_growth_zone(parent: Node3D) -> void:
	var zone := _make_city_zone(parent, "ZoneA_OlindaConcentricGrowth")
	_build_concentric_city_wall(zone, Vector3(0, 0, -74), 0.0)
	_build_needlepoint_mini_city(zone, Vector3(0, 0, -74), 0.0)
	_build_inner_growing_city(zone, Vector3(0, 0, -56), 0.0)
	_build_hidden_simple_prop(zone, "MagnifyingGlass", Vector3(-22, 0, -88), -16.0, Vector3(7.0, 0.35, 4.2), Color(0.74, 0.86, 0.78, 0.44), false)
	_build_hidden_cylinder_prop(zone, "NeedlepointGlow", Vector3(0, 1.2, -74), 1.3, 0.08, Color(0.42, 1.0, 0.62, 0.70), false)
	for i in range(5):
		_build_hidden_simple_prop(zone, "TinyRoof_%02d" % i, Vector3(-4.0 + float(i) * 2.0, 0.55, -76.0 + float(i % 2) * 3.0), float(i) * 8.0, Vector3(1.2, 0.32, 0.8), Color(0.32, 0.48, 0.28), false)
	for i in range(4):
		_build_hidden_simple_prop(zone, "TinyAntenna_%02d" % i, Vector3(-3.0 + float(i) * 2.0, 1.35, -72.0), 0.0, Vector3(0.08, 1.0, 0.08), Color(0.70, 0.82, 0.72, 0.70), false)
	_build_hidden_cylinder_prop(zone, "TinyPool", Vector3(3.5, 0.25, -70.5), 1.1, 0.06, Color(0.26, 0.74, 0.64, 0.56), false)
	_build_hidden_simple_prop(zone, "StreetBanner", Vector3(0, 2.2, -71.5), 0.0, Vector3(5.6, 0.18, 0.08), Color(0.84, 0.70, 0.28, 0.74), false)
	_build_hidden_simple_prop(zone, "Newsstand", Vector3(-2.8, 0, -69.5), 0.0, Vector3(1.4, 1.2, 1.0), Color(0.48, 0.36, 0.20), false)
	_build_hidden_reveal_node(zone, 0, Vector3(0, 0, -50), 0.0)

func _build_hidden_raissa_joy_zone(parent: Node3D) -> void:
	var zone := _make_city_zone(parent, "ZoneB_RaissaSadnessJoy")
	_build_hidden_simple_prop(zone, "SadnessDistrict", Vector3(64, 0, -12), 0.0, Vector3(42, 8.0, 28), Color(0.16, 0.17, 0.16), true)
	_build_hidden_simple_prop(zone, "RiverRailing", Vector3(40, 1.3, -30), 0.0, Vector3(42, 2.6, 0.35), Color(0.20, 0.26, 0.22), false)
	_build_hidden_simple_prop(zone, "LowTavern", Vector3(82, 0, -30), -8.0, Vector3(14, 3.6, 9), Color(0.22, 0.16, 0.12), true)
	_build_scaffold_house(zone, Vector3(54, 0, 8), 5.0)
	_build_hidden_simple_prop(zone, "HiddenHappyCity", Vector3(66, 0, 12), 0.0, Vector3(24, 5.0, 18), Color(0.28, 0.46, 0.26, 0.42), false)
	_build_hidden_simple_prop(zone, "CryingChild", Vector3(48, 0, -20), 0.0, Vector3(1.2, 2.2, 0.7), Color(0.28, 0.30, 0.30, 0.62), false)
	_build_hidden_simple_prop(zone, "BrokenDishes", Vector3(74, 0.12, -18), 0.0, Vector3(4.0, 0.24, 2.4), Color(0.74, 0.70, 0.62, 0.38), false)
	_build_hidden_simple_prop(zone, "CornCake", Vector3(58, 5.2, 6), 0.0, Vector3(1.4, 0.22, 1.0), Color(0.84, 0.62, 0.24), false)
	_build_hidden_simple_prop(zone, "RooftopDog", Vector3(62, 5.7, 6), 0.0, Vector3(2.0, 0.9, 0.7), Color(0.26, 0.18, 0.10), false)
	_build_hidden_simple_prop(zone, "TomatoPastaPlate", Vector3(78, 1.2, -22), 0.0, Vector3(1.6, 0.22, 1.2), Color(0.82, 0.18, 0.08), false)
	_build_hidden_simple_prop(zone, "WhiteLaceParasol", Vector3(86, 2.6, 8), 0.0, Vector3(4.0, 0.20, 4.0), Color(0.92, 0.90, 0.82, 0.46), false)
	_build_hidden_simple_prop(zone, "Partridge", Vector3(72, 7.0, 22), 22.0, Vector3(1.6, 0.6, 0.9), Color(0.66, 0.42, 0.20, 0.64), false)
	var joy_points := [Vector3(48, 2.2, -20), Vector3(62, 5.8, 6), Vector3(78, 1.4, -22), Vector3(86, 2.8, 8), Vector3(72, 7.2, 22)]
	for i in range(joy_points.size() - 1):
		_add_hidden_line_span(zone, "JoyThread_%02d" % i, joy_points[i], joy_points[i + 1], Color(0.96, 0.78, 0.28, 0.72), 0.08)
	_build_hidden_reveal_node(zone, 1, Vector3(66, 0, 6), -90.0)

func _build_hidden_marozia_crack_zone(parent: Node3D) -> void:
	var zone := _make_city_zone(parent, "ZoneC_MaroziaRatSwallowCrack")
	_build_hidden_simple_prop(zone, "LeadGreyAlley", Vector3(-60, 0.10, -8), 0.0, Vector3(54, 0.20, 7), Color(0.22, 0.23, 0.23), true)
	_build_hidden_simple_prop(zone, "RatCity", Vector3(-72, 0, -20), 0.0, Vector3(24, 2.4, 16), Color(0.08, 0.08, 0.075), true)
	_build_hidden_simple_prop(zone, "SwallowCity", Vector3(-58, 12.0, 10), 0.0, Vector3(32, 4.0, 16), Color(0.38, 0.56, 0.62, 0.30), false)
	_build_wall_crack_gate(zone, Vector3(-36, 0, -8), 90.0)
	_build_hidden_simple_prop(zone, "CrystalMomentCity", Vector3(-24, 2.4, -8), 0.0, Vector3(18, 4.8, 12), Color(0.74, 0.96, 1.0, 0.34), false)
	for i in range(8):
		_build_hidden_simple_prop(zone, "RatShadow_%02d" % i, Vector3(-80.0 + float(i) * 4.5, 0.18, -15.0 + sin(float(i)) * 3.0), 0.0, Vector3(2.2, 0.10, 0.7), Color(0.02, 0.02, 0.018, 0.58), false)
	for i in range(7):
		_build_hidden_simple_prop(zone, "SwallowShadow_%02d" % i, Vector3(-72.0 + float(i) * 6.0, 14.0 + sin(float(i)) * 1.4, 12.0), 18.0 + float(i) * 9.0, Vector3(2.4, 0.16, 0.7), Color(0.42, 0.76, 0.88, 0.50), false)
	_build_hidden_simple_prop(zone, "BatCloak", Vector3(-48, 1.8, -20), 0.0, Vector3(2.8, 3.0, 0.24), Color(0.04, 0.04, 0.05, 0.68), false)
	_build_hidden_simple_prop(zone, "DragonflyGleam", Vector3(-27, 4.8, -8), 0.0, Vector3(1.8, 0.12, 0.7), Color(0.72, 1.0, 0.92, 0.80), false)
	_build_hidden_simple_prop(zone, "MoldyRoof", Vector3(-66, 3.0, -28), 0.0, Vector3(22, 0.5, 10), Color(0.18, 0.30, 0.16), false)
	_build_hidden_reveal_node(zone, 2, Vector3(-36, 0, -8), 90.0)

func _build_hidden_theodora_species_zone(parent: Node3D) -> void:
	var zone := _make_city_zone(parent, "ZoneD_TheodoraSpeciesReturn")
	_build_hidden_simple_prop(zone, "AnimalGraveCity", Vector3(0, 0, 70), 0.0, Vector3(48, 2.2, 26), Color(0.18, 0.19, 0.15), true)
	_build_hidden_simple_prop(zone, "UndergroundArchive", Vector3(-18, -1.0, 44), 0.0, Vector3(34, 3.0, 20), Color(0.06, 0.08, 0.06, 0.72), false)
	_build_hidden_simple_prop(zone, "SpeciesLibrary", Vector3(20, 0, 48), 0.0, Vector3(32, 8.0, 18), Color(0.22, 0.18, 0.12), true)
	_build_hidden_simple_prop(zone, "MonsterRevivalAlley", Vector3(0, 0.10, 34), 0.0, Vector3(64, 0.20, 5), Color(0.08, 0.10, 0.08), true)
	_build_hidden_simple_prop(zone, "SewerRatBurrow", Vector3(-34, -0.4, 54), 0.0, Vector3(10, 1.0, 6), Color(0.02, 0.025, 0.02, 0.82), false)
	for i in range(10):
		_build_hidden_simple_prop(zone, "AnimalGraveMarker_%02d" % i, Vector3(-20.0 + float(i) * 4.4, 0.9, 72.0 + sin(float(i)) * 5.0), 0.0, Vector3(0.8, 1.8, 0.24), Color(0.34, 0.34, 0.28), false)
	_build_hidden_simple_prop(zone, "VultureFeather", Vector3(-18, 0.4, 60), 20.0, Vector3(2.6, 0.12, 0.4), Color(0.18, 0.18, 0.16), false)
	_build_hidden_simple_prop(zone, "SnakeScale", Vector3(-6, 0.18, 62), 0.0, Vector3(1.0, 0.08, 0.8), Color(0.28, 0.46, 0.22, 0.58), false)
	_build_hidden_simple_prop(zone, "SpiderWeb", Vector3(28, 3.2, 39), 0.0, Vector3(5.0, 0.08, 5.0), Color(0.70, 0.78, 0.70, 0.28), false)
	_build_hidden_simple_prop(zone, "RatCorpse", Vector3(-32, 0.10, 50), 0.0, Vector3(2.2, 0.30, 0.9), Color(0.10, 0.08, 0.06), false)
	_build_hidden_simple_prop(zone, "BuffonBook", Vector3(12, 2.0, 43), 0.0, Vector3(2.0, 0.35, 1.3), Color(0.42, 0.24, 0.12), false)
	_build_hidden_simple_prop(zone, "LinnaeusBook", Vector3(16, 2.6, 43), 0.0, Vector3(2.0, 0.35, 1.3), Color(0.34, 0.22, 0.14), false)
	_build_hidden_simple_prop(zone, "SphinxFigure", Vector3(2, 1.2, 35), 0.0, Vector3(2.8, 2.4, 1.4), Color(0.52, 0.44, 0.30), false)
	_build_hidden_simple_prop(zone, "GriffinFigure", Vector3(10, 1.4, 35), 0.0, Vector3(2.8, 2.8, 1.4), Color(0.48, 0.40, 0.28), false)
	_build_hidden_simple_prop(zone, "HydraShadow", Vector3(24, 3.0, 34), 0.0, Vector3(8.0, 3.0, 0.16), Color(0.02, 0.05, 0.025, 0.62), false)
	_build_hidden_simple_prop(zone, "UnicornBone", Vector3(-20, -0.1, 46), 14.0, Vector3(4.0, 0.25, 0.45), Color(0.78, 0.74, 0.62), false)
	_build_hidden_reveal_node(zone, 3, Vector3(0, 0, 44), 180.0)

func _build_hidden_berenice_justice_zone(parent: Node3D) -> void:
	var zone := _make_city_zone(parent, "ZoneE_BereniceJusticeMachinery")
	_build_hidden_simple_prop(zone, "UnjustHall", Vector3(36, 0, 74), 0.0, Vector3(34, 9.0, 18), Color(0.20, 0.16, 0.13), true)
	_build_grinder_palace(zone, Vector3(62, 0, 74), -12.0)
	_build_hidden_simple_prop(zone, "JustBackAlley", Vector3(22, 0.10, 88), 24.0, Vector3(44, 0.20, 4.0), Color(0.08, 0.12, 0.08), true)
	_build_mechanical_vine_city(zone, Vector3(22, 0, 104), 0.0)
	_build_hidden_simple_prop(zone, "HiddenStairShadow", Vector3(42, 1.2, 92), -24.0, Vector3(14, 2.4, 3.0), Color(0.03, 0.04, 0.03, 0.72), false)
	_build_hidden_simple_prop(zone, "JustEmbryoCity", Vector3(20, 2.0, 104), 0.0, Vector3(10, 4.0, 8), Color(0.36, 0.62, 0.32, 0.42), false)
	_build_hidden_simple_prop(zone, "PoisonSeedCity", Vector3(20, 4.8, 104), 0.0, Vector3(4.2, 3.0, 3.4), Color(0.16, 0.34, 0.10, 0.58), false)
	for i in range(6):
		_add_hidden_line_span(zone, "SteelWire_%02d" % i, Vector3(4.0 + float(i) * 6.0, 2.2, 92), Vector3(12.0 + float(i) * 5.0, 4.5, 108), Color(0.56, 0.66, 0.58, 0.56), 0.06)
	for i in range(5):
		_build_hidden_simple_prop(zone, "Pipe_%02d" % i, Vector3(8.0 + float(i) * 6.0, 1.4, 100.0 + sin(float(i)) * 4.0), 20.0, Vector3(5.0, 0.45, 0.45), Color(0.34, 0.30, 0.22), false)
	_build_hidden_cylinder_prop(zone, "Pulley", Vector3(38, 4.2, 98), 1.4, 0.34, Color(0.46, 0.34, 0.18), false)
	_build_hidden_simple_prop(zone, "Piston", Vector3(30, 2.2, 106), 0.0, Vector3(1.2, 4.4, 1.2), Color(0.42, 0.36, 0.26), false)
	_build_hidden_cylinder_prop(zone, "Counterweight", Vector3(14, 1.8, 98), 1.8, 1.2, Color(0.38, 0.32, 0.24), false)
	_build_hidden_cylinder_prop(zone, "GiantGear", Vector3(22, 3.4, 96), 4.0, 0.36, Color(0.54, 0.34, 0.16), false)
	_build_hidden_simple_prop(zone, "SoupBowl", Vector3(10, 0.6, 90), 0.0, Vector3(1.5, 0.35, 1.5), Color(0.82, 0.58, 0.26), false)
	_build_hidden_simple_prop(zone, "BeanPlate", Vector3(14, 0.6, 90), 0.0, Vector3(1.8, 0.22, 1.3), Color(0.48, 0.72, 0.32), false)
	_build_hidden_reveal_node(zone, 4, Vector3(22, 0, 100), 0.0)

func _build_hidden_center_core(parent: Node3D) -> void:
	var zone := _make_city_zone(parent, "ZoneF_HiddenCore")
	_build_hidden_cylinder_prop(zone, "HiddenCoreRootDisk", Vector3(0, 0.10, 0), 18.0, 0.10, Color(0.06, 0.14, 0.08, 0.74), true)
	_build_hidden_simple_prop(zone, "HiddenCrackLight", Vector3(0, 3.0, 0), 0.0, Vector3(1.4, 6.0, 0.18), Color(0.42, 1.0, 0.58, 0.70), false)
	for i in range(14):
		var angle := TAU * float(i) / 14.0
		_add_hidden_line_span(zone, "HiddenRootLine_%02d" % i, Vector3(0, 0.48, 0), Vector3(cos(angle) * 20.0, 0.48, sin(angle) * 20.0), Color(0.16, 0.54, 0.24, 0.42), 0.10)
	_build_hidden_simple_prop(zone, "DarkGreenSporeCore", Vector3(0, 5.8, 0), 0.0, Vector3(6.0, 1.0, 6.0), Color(0.18, 0.80, 0.34, 0.24), false)
	hidden_goal_trigger = Area3D.new()
	hidden_goal_trigger.name = "HiddenGoalTrigger"
	hidden_goal_trigger.position = Vector3(0, 1.1, 0)
	hidden_goal_trigger.collision_layer = 0
	hidden_goal_trigger.collision_mask = 2
	var shape := CollisionShape3D.new()
	var sphere := SphereShape3D.new()
	sphere.radius = 9.0
	shape.shape = sphere
	hidden_goal_trigger.add_child(shape)
	hidden_goal_trigger.body_entered.connect(_on_hidden_goal_entered)
	hidden_goal_trigger.body_exited.connect(_on_hidden_goal_exited)
	manifested_city.add_child(hidden_goal_trigger)

func _build_hidden_atmosphere(parent: Node3D) -> void:
	var atmosphere := Node3D.new()
	atmosphere.name = "HiddenCityAtmosphere_StyleDirection"
	parent.add_child(atmosphere)
	atmosphere.add_child(_make_city_particle_layer("FireflyParticles", 860, Vector2(0.055, 0.055), Vector3(116, 12, 116), Vector3(0.04, 0.08, -0.03), Color(0.72, 1.0, 0.42, 0.44), 0.02, 0.18, 100.0, 13.0))
	atmosphere.add_child(_make_city_particle_layer("DarkGreenSporeParticles", 1500, Vector2(0.038, 0.038), Vector3(124, 8, 124), Vector3(-0.03, 0.06, 0.04), Color(0.22, 0.78, 0.32, 0.26), 0.02, 0.16, 100.0, 16.0))
	atmosphere.add_child(_make_city_particle_layer("LeafDriftParticles", 900, Vector2(0.15, 0.075), Vector3(118, 10, 118), Vector3(0.12, -0.03, 0.08), Color(0.20, 0.42, 0.16, 0.34), 0.04, 0.26, 100.0, 15.0))
	atmosphere.add_child(_make_city_particle_layer("HiddenGlimmerParticles", 720, Vector2(0.045, 0.045), Vector3(112, 9, 112), Vector3(0.02, 0.04, 0.02), Color(0.56, 1.0, 0.72, 0.30), 0.01, 0.12, 90.0, 12.0))
	for i in range(9):
		var angle := TAU * float(i) / 9.0
		_add_city_style_veil(atmosphere, "MaskRevealMistVeil_%02d" % i, Vector3(cos(angle) * 46.0, 4.2 + float(i % 3) * 1.1, sin(angle) * 46.0), Vector2(70, 14), rad_to_deg(angle) + 90.0, Color(0.16, 0.62, 0.28, 0.16), 0.0, 820.0 + float(i) * 6.3, hidden_city_style_intensity * 0.78)

func _build_concentric_city_wall(parent: Node3D, pos: Vector3, yaw: float) -> void:
	var asset := _make_city_asset(parent, "ConcentricCityWall", pos, yaw)
	for i in range(4):
		var radius := 23.0 - float(i) * 4.6
		_add_local_hidden_cylinder(asset, "GrowingWallRing_%02d" % i, Vector3(0, 0.18 + float(i) * 0.03, 0), radius, 0.22, Color(0.18, 0.32, 0.18, 0.46), false, 0.58, 0.54)
		for s in range(12):
			var angle := TAU * float(s) / 12.0
			_add_local_hidden_block(asset, "RingRuinBlock_%02d_%02d" % [i, s], Vector3(cos(angle) * radius, 0.8, sin(angle) * radius), Vector3(1.6, 1.6, 0.5), -rad_to_deg(angle), Color(0.22, 0.30, 0.20, 0.62), false, 0.62, 0.62)

func _build_needlepoint_mini_city(parent: Node3D, pos: Vector3, yaw: float) -> void:
	var asset := _make_city_asset(parent, "NeedlepointMiniCity", pos, yaw)
	_add_local_hidden_block(asset, "NeedlepointBase", Vector3(0, 0.08, 0), Vector3(8, 0.16, 8), 0.0, Color(0.16, 0.26, 0.14, 0.62), false, 0.42, 0.70)
	_add_local_hidden_cylinder(asset, "MiniaturePlaza", Vector3(0, 0.22, 0), 2.5, 0.08, Color(0.26, 0.42, 0.22, 0.58), false, 0.38, 0.62)
	_add_local_hidden_cylinder(asset, "MiniRacecourse", Vector3(4.0, 0.24, 0), 2.0, 0.06, Color(0.32, 0.26, 0.16, 0.54), false, 0.44, 0.60)
	for i in range(9):
		_add_local_hidden_block(asset, "NeedlepointTinyHouse_%02d" % i, Vector3(-3.2 + float(i % 3) * 3.2, 0.55, -3.2 + float(i / 3) * 3.2), Vector3(1.2, 1.1, 1.0), 0.0, Color(0.30, 0.42, 0.24), false, 0.42, 0.62)

func _build_inner_growing_city(parent: Node3D, pos: Vector3, yaw: float) -> void:
	var asset := _make_city_asset(parent, "InnerGrowingCity", pos, yaw)
	for i in range(10):
		var angle := TAU * float(i) / 10.0
		_add_local_hidden_block(asset, "InnerGrowthBuilding_%02d" % i, Vector3(cos(angle) * 8.0, 2.0 + float(i % 3) * 0.6, sin(angle) * 8.0), Vector3(2.6, 4.0 + float(i % 3), 2.2), rad_to_deg(angle), Color(0.18, 0.38, 0.20, 0.52), true, 0.60, 0.74)
		_add_hidden_line_span(asset, "InnerGrowthVine_%02d" % i, Vector3(0, 1.2, 0), Vector3(cos(angle) * 9.5, 4.0, sin(angle) * 9.5), Color(0.20, 0.74, 0.28, 0.42), 0.08)

func _build_scaffold_house(parent: Node3D, pos: Vector3, yaw: float) -> void:
	var asset := _make_city_asset(parent, "ScaffoldHouse", pos, yaw)
	_add_local_hidden_block(asset, "DarkHouseBody", Vector3(0, 3.0, 0), Vector3(12, 6.0, 9), 0.0, Color(0.16, 0.18, 0.15), true, 0.58, 0.72)
	for x in [-6.8, 6.8]:
		for z in [-4.8, 4.8]:
			_add_local_hidden_block(asset, "ScaffoldPole_%s_%s" % [str(x), str(z)], Vector3(x, 3.8, z), Vector3(0.24, 7.6, 0.24), 0.0, Color(0.30, 0.24, 0.16), false, 0.48, 0.70)
	for level in range(3):
		_add_local_hidden_block(asset, "ScaffoldCross_%02d" % level, Vector3(0, 1.8 + float(level) * 2.2, -5.0), Vector3(14.0, 0.20, 0.20), 0.0, Color(0.32, 0.25, 0.16), false, 0.48, 0.70)

func _build_wall_crack_gate(parent: Node3D, pos: Vector3, yaw: float) -> void:
	var asset := _make_city_asset(parent, "WallCrackGate", pos, yaw)
	_add_local_hidden_block(asset, "ThickWallLeft", Vector3(-3.0, 4.0, 0), Vector3(3.0, 8.0, 2.0), 0.0, Color(0.24, 0.24, 0.22), true, 0.60, 0.70)
	_add_local_hidden_block(asset, "ThickWallRight", Vector3(3.0, 4.0, 0), Vector3(3.0, 8.0, 2.0), 0.0, Color(0.24, 0.24, 0.22), true, 0.60, 0.70)
	_add_local_hidden_block(asset, "HiddenCrackLightSliver", Vector3(0, 4.0, -0.8), Vector3(0.34, 7.0, 0.18), 0.0, Color(0.72, 1.0, 0.92, 0.72), false, 0.10, 0.42)

func _build_grinder_palace(parent: Node3D, pos: Vector3, yaw: float) -> void:
	var asset := _make_city_asset(parent, "GrinderPalace", pos, yaw)
	_add_local_hidden_block(asset, "PalaceBody", Vector3(0, 6.0, 0), Vector3(22, 12, 14), 0.0, Color(0.25, 0.20, 0.16), true, 0.64, 0.72)
	for i in range(3):
		_add_local_hidden_block(asset, "ThreeLinePattern_%02d" % i, Vector3(-4.0 + float(i) * 4.0, 6.5, -7.2), Vector3(0.32, 8.0, 0.18), 0.0, Color(0.52, 0.36, 0.18), false, 0.36, 0.68)
	_add_local_hidden_cylinder(asset, "CylindricalCap", Vector3(0, 12.8, 0), 8.2, 1.2, Color(0.34, 0.26, 0.18), false, 0.52, 0.70)

func _build_mechanical_vine_city(parent: Node3D, pos: Vector3, yaw: float) -> void:
	var asset := _make_city_asset(parent, "MechanicalVineCity", pos, yaw)
	for i in range(12):
		var angle := TAU * float(i) / 12.0
		_add_local_hidden_block(asset, "MechanicalVineBuilding_%02d" % i, Vector3(cos(angle) * 10.0, 2.2, sin(angle) * 8.0), Vector3(2.2, 4.4, 2.2), rad_to_deg(angle), Color(0.18, 0.36, 0.18, 0.52), false, 0.52, 0.76)
		_add_hidden_line_span(asset, "MechanicalVine_%02d" % i, Vector3(0, 2.0, 0), Vector3(cos(angle) * 12.0, 5.0, sin(angle) * 10.0), Color(0.22, 0.70, 0.25, 0.46), 0.12)

func _build_hidden_tree_pillar(parent: Node3D, name: String, pos: Vector3, yaw: float) -> void:
	var asset := _make_city_asset(parent, name, pos, yaw)
	_add_local_hidden_block(asset, "Trunk", Vector3(0, 4.0, 0), Vector3(1.4, 8.0, 1.4), 0.0, Color(0.16, 0.10, 0.06), false, 0.62, 0.50)
	_add_local_hidden_block(asset, "LeafCanopy", Vector3(0, 8.6, 0), Vector3(7.0, 2.2, 6.0), 0.0, Color(0.08, 0.24, 0.10, 0.58), false, 0.50, 0.44)

func _hidden_node_color(node_index: int) -> Color:
	return HIDDEN_REVEAL_COLORS[clampi(node_index, 0, HIDDEN_REVEAL_COLORS.size() - 1)]

func _build_hidden_reveal_node(parent: Node3D, node_index: int, pos: Vector3, yaw: float) -> void:
	var data: Array = HIDDEN_REVEAL_NODES[node_index]
	var color := _hidden_node_color(node_index)
	var asset := _make_city_asset(parent, String(data[0]), pos, yaw)
	_add_local_hidden_block(asset, "ConcealedMarkerColumn", Vector3(0, 2.0, 0), Vector3(1.2, 4.0, 1.2), 0.0, Color(0.04, 0.11, 0.06, 0.72), true, 0.68, 0.58)
	_add_local_hidden_block(asset, "MaskedRevealPanel", Vector3(0, 4.5, -0.48), Vector3(5.2, 2.0, 0.16), 0.0, color, false, 0.24, 0.64)
	var revealed := _add_local_hidden_block(asset, "RevealedInnerCityPanel", Vector3(0, 4.5, -0.66), Vector3(5.2, 2.0, 0.16), 0.0, Color(0.82, 1.0, 0.74, 0.34), false, 0.16, 0.42)
	revealed.visible = false
	_add_hidden_node_glow(asset, color)
	while hidden_node_visuals.size() <= node_index:
		hidden_node_visuals.append(null)
	hidden_node_visuals[node_index] = asset

	var area := Area3D.new()
	area.name = "%sArea" % String(data[0])
	area.position = pos + Vector3(0, 1.2, 0)
	area.collision_layer = 0
	area.collision_mask = 2
	var shape := CollisionShape3D.new()
	var sphere := SphereShape3D.new()
	sphere.radius = 4.8
	shape.shape = sphere
	area.add_child(shape)
	area.body_entered.connect(func(body: Node3D): _on_hidden_node_entered(body, node_index))
	area.body_exited.connect(func(body: Node3D): _on_hidden_node_exited(body, node_index))
	manifested_city.add_child(area)
	while hidden_node_areas.size() <= node_index:
		hidden_node_areas.append(null)
	hidden_node_areas[node_index] = area

func _add_hidden_node_glow(asset: Node3D, color: Color) -> void:
	var halo := CSGCylinder3D.new()
	halo.name = "HiddenNodeGlow"
	halo.radius = 3.5
	halo.height = 0.035
	halo.sides = 48
	halo.position = Vector3(0, 0.10, 0)
	halo.material = _emissive_mat(color, 0.26, hidden_node_glow_energy)
	asset.add_child(halo)
	var light := OmniLight3D.new()
	light.name = "HiddenNodeLight"
	light.position = Vector3(0, 3.7, 0)
	light.light_color = color
	light.light_energy = hidden_node_glow_energy
	light.omni_range = 9.0
	asset.add_child(light)
	var particles := GPUParticles3D.new()
	particles.name = "HiddenNodeSporeParticles"
	particles.amount = int(maxf(1.0, 90.0 * hidden_node_particle_scale))
	particles.lifetime = 2.8
	particles.visibility_aabb = AABB(Vector3(-5, -1, -5), Vector3(10, 8, 10))
	var mesh := QuadMesh.new()
	mesh.size = Vector2(0.08, 0.08)
	particles.draw_pass_1 = mesh
	var process := ParticleProcessMaterial.new()
	process.emission_shape = ParticleProcessMaterial.EMISSION_SHAPE_SPHERE
	process.emission_sphere_radius = 2.9
	process.gravity = Vector3(0, -0.01, 0)
	process.initial_velocity_min = 0.02
	process.initial_velocity_max = 0.22
	process.spread = 100.0
	process.color = Color(color.r, color.g, color.b, 0.72)
	particles.process_material = process
	particles.position = Vector3(0, 2.8, 0)
	particles.emitting = true
	asset.add_child(particles)

func _set_hidden_node_visual_state(node_index: int, revealed: bool) -> void:
	if node_index < 0 or node_index >= hidden_node_visuals.size():
		return
	var asset := hidden_node_visuals[node_index]
	if asset == null:
		return
	var masked := asset.get_node_or_null("MaskedRevealPanel")
	if masked != null:
		masked.visible = not revealed
	var inner := asset.get_node_or_null("RevealedInnerCityPanel")
	if inner != null:
		inner.visible = revealed
	for name in ["HiddenNodeGlow", "HiddenNodeLight", "HiddenNodeSporeParticles"]:
		var child := asset.get_node_or_null(name)
		if child != null:
			child.visible = not revealed

func _build_hidden_simple_prop(parent: Node3D, name: String, pos: Vector3, yaw: float, size: Vector3, color: Color, collision := false) -> Node3D:
	var asset := _make_city_asset(parent, name, pos, yaw)
	_add_local_hidden_block(asset, "WhiteboxReplaceRoot", Vector3(0, size.y * 0.5, 0), size, 0.0, color, collision, 0.56, 0.64)
	return asset

func _add_hidden_block(parent: Node3D, name: String, pos: Vector3, size: Vector3, yaw: float, color: Color, collision := false, reveal := 0.50, growth := 0.62) -> Node3D:
	var box := CSGBox3D.new()
	box.name = name
	box.position = pos
	box.size = size
	box.rotation_degrees.y = yaw
	box.material = _hidden_growth_material(color, color.a, pos.x * 0.17 + pos.z * 0.21, reveal, growth)
	parent.add_child(box)
	if collision:
		_add_box_collision(name + "Collision", pos, size, yaw)
	return box

func _add_local_hidden_block(asset: Node3D, part_name: String, local_pos: Vector3, size: Vector3, local_yaw: float, color: Color, collision := true, reveal := 0.50, growth := 0.62) -> Node3D:
	var global_pos := _asset_global_pos(asset, local_pos)
	var global_yaw := _asset_global_yaw(asset, local_yaw)
	var box := CSGBox3D.new()
	box.name = part_name
	box.position = local_pos
	box.size = size
	box.rotation_degrees.y = local_yaw
	box.material = _hidden_growth_material(color, color.a, global_pos.x * 0.17 + global_pos.z * 0.21, reveal, growth)
	asset.add_child(box)
	if collision:
		_add_box_collision("%s_%sCollision" % [asset.name, part_name], global_pos, size, global_yaw)
	return box

func _build_hidden_cylinder_prop(parent: Node3D, name: String, pos: Vector3, radius: float, height: float, color: Color, collision := false) -> Node3D:
	var cylinder := CSGCylinder3D.new()
	cylinder.name = name
	cylinder.radius = radius
	cylinder.height = height
	cylinder.sides = 56
	cylinder.position = pos
	cylinder.material = _hidden_growth_material(color, color.a, pos.x * 0.13 + pos.z * 0.23, 0.46, 0.66)
	parent.add_child(cylinder)
	if collision:
		_add_box_collision(name + "Collision", pos, Vector3(radius * 2.0, height, radius * 2.0), 0.0)
	return cylinder

func _add_local_hidden_cylinder(asset: Node3D, part_name: String, local_pos: Vector3, radius: float, height: float, color: Color, collision := false, reveal := 0.46, growth := 0.66) -> Node3D:
	var global_pos := _asset_global_pos(asset, local_pos)
	var cylinder := CSGCylinder3D.new()
	cylinder.name = part_name
	cylinder.radius = radius
	cylinder.height = height
	cylinder.sides = 56
	cylinder.position = local_pos
	cylinder.material = _hidden_growth_material(color, color.a, global_pos.x * 0.13 + global_pos.z * 0.23, reveal, growth)
	asset.add_child(cylinder)
	if collision:
		_add_box_collision("%s_%sCollision" % [asset.name, part_name], global_pos, Vector3(radius * 2.0, height, radius * 2.0), _asset_global_yaw(asset, 0.0))
	return cylinder

func _add_hidden_line_span(parent: Node3D, name: String, a: Vector3, b: Vector3, color: Color, thickness := 0.08) -> Node3D:
	var delta := b - a
	var flat_length := delta.length()
	var yaw := rad_to_deg(atan2(delta.x, delta.z))
	var mid := (a + b) * 0.5
	return _add_hidden_block(parent, name, mid, Vector3(thickness, thickness, maxf(flat_length, 0.1)), yaw, color, false, 0.32, 0.82)

func _build_memory_city_diomira() -> void:
	_build_memory_courtyard()
	_build_repeated_doors()
	_build_corridor_blocks()
	_build_diomira_landmarks()
	_build_echo_tower()

func _build_memory_courtyard() -> void:
	if memory_courtyard_built:
		return
	memory_courtyard_built = true
	var root := Node3D.new()
	root.name = "MemoryCourtyard"
	_active_city_parent().add_child(root)

	var disk := CSGCylinder3D.new()
	disk.name = "RingPlaza"
	disk.radius = 18.0
	disk.height = 0.18
	disk.sides = 48
	disk.position.y = 0.02
	disk.material = _mat(Color(0.62, 0.61, 0.56), 1.0)
	root.add_child(disk)
	_add_box_collision("RingPlazaCollision", Vector3(0, 0.08, 0), Vector3(36, 0.18, 36))

	for i in range(12):
		var angle := TAU * float(i) / 12.0
		var stone := CSGBox3D.new()
		stone.name = "PlazaMarker_%02d" % i
		stone.size = Vector3(1.1, 0.3, 3.4)
		stone.position = Vector3(cos(angle) * 17.0, 0.25, sin(angle) * 17.0)
		stone.rotation.y = -angle
		stone.material = _mat(Color(0.47, 0.47, 0.44), 1.0)
		root.add_child(stone)

func _build_repeated_doors() -> void:
	var root := Node3D.new()
	root.name = "RepeatedDoors"
	_active_city_parent().add_child(root)
	for row in range(2):
		for i in range(7):
			var x := -24.0 + i * 8.0
			var z := -24.0 if row == 0 else 24.0
			_add_door_frame(root, Vector3(x, 0, z), 0.0 if row == 0 else 180.0)

func _build_corridor_blocks() -> void:
	var root := Node3D.new()
	root.name = "CorridorBlocks"
	_active_city_parent().add_child(root)

	var block_specs := [
		[Vector3(-30, 2.2, -8), Vector3(7, 4.4, 10), 8.0],
		[Vector3(-28, 1.8, 12), Vector3(9, 3.6, 7), -13.0],
		[Vector3(28, 2.4, -12), Vector3(8, 4.8, 9), -6.0],
		[Vector3(31, 1.7, 11), Vector3(6, 3.4, 12), 11.0],
		[Vector3(-8, 1.6, 31), Vector3(18, 3.2, 5), 0.0],
		[Vector3(9, 2.0, -33), Vector3(16, 4.0, 5), 0.0]
	]
	for i in range(block_specs.size()):
		var box := CSGBox3D.new()
		box.name = "EmptyRoomBlock_%02d" % i
		box.position = block_specs[i][0]
		box.size = block_specs[i][1]
		box.rotation_degrees.y = block_specs[i][2]
		box.material = _mat(Color(0.52, 0.53, 0.50), 1.0)
		root.add_child(box)
		_add_box_collision(box.name + "Collision", box.position, box.size, box.rotation_degrees.y)

	for i in range(5):
		var wall := CSGBox3D.new()
		wall.name = "LeaningOldWall_%02d" % i
		wall.size = Vector3(1.0, 4.6, 8.0)
		wall.position = Vector3(-18 + i * 9, 2.3, 38)
		wall.rotation_degrees = Vector3(0, -18 + i * 8, -5 + i * 2)
		wall.material = _mat(Color(0.45, 0.46, 0.44), 1.0)
		root.add_child(wall)
		_add_box_collision(wall.name + "Collision", wall.position, wall.size, wall.rotation_degrees.y)

	for i in range(8):
		var z := -8.0 + i * 2.4
		_add_arch(root, Vector3(42, 0, z), 90.0, i)

func _build_diomira_landmarks() -> void:
	var root := Node3D.new()
	root.name = "DiomiraSilverDomes"
	_active_city_parent().add_child(root)
	for i in range(18):
		var angle: float = TAU * float(i) / 18.0
		var radius := 36.0 + float(i % 3) * 11.0
		var pos := Vector3(cos(angle) * radius, 0, sin(angle) * radius)
		_add_city_tower(root, "SilverDome_%02d" % i, pos, 3.2 + float(i % 2), 7.0 + float(i % 4) * 2.5, Color(0.67, 0.69, 0.66), true)
	for i in range(5):
		_add_city_block(root, "CrystalTheatre_%02d" % i, Vector3(-52 + i * 8, 4.0, -54), Vector3(5, 8, 9), 12.0, Color(0.62, 0.74, 0.78))

func _build_memory_city_isidora() -> void:
	var root := Node3D.new()
	root.name = "IsidoraShellStairs"
	_active_city_parent().add_child(root)
	_build_memory_courtyard()
	for ring in range(3):
		for i in range(12):
			var angle: float = TAU * float(i) / 12.0 + float(ring) * 0.22
			var radius := 26.0 + ring * 18.0
			var pos := Vector3(cos(angle) * radius, 0, sin(angle) * radius)
			_add_city_block(root, "Workshop_%d_%02d" % [ring, i], pos + Vector3(0, 2.5, 0), Vector3(6, 5 + ring * 2, 6), rad_to_deg(-angle), Color(0.56, 0.54, 0.50))
	for i in range(16):
		var angle: float = TAU * float(i) / 16.0
		var pos := Vector3(cos(angle) * 48.0, 0, sin(angle) * 48.0)
		_add_spiral_marker(root, pos, rad_to_deg(angle))
	_build_old_men_wall(root)
	_build_echo_tower()

func _build_memory_city_zaira() -> void:
	var root := Node3D.new()
	root.name = "ZairaFortressAndDocks"
	_active_city_parent().add_child(root)
	for i in range(28):
		var x := -64.0 + float(i % 7) * 20.0
		var z := -50.0 + float(i / 7) * 30.0
		var h := 10.0 + float((i * 7) % 9) * 2.8
		_add_city_block(root, "TallFortress_%02d" % i, Vector3(x, h * 0.5, z), Vector3(8, h, 8), float(i * 11), Color(0.44, 0.45, 0.43))
	for i in range(10):
		_add_city_block(root, "RaisedStreet_%02d" % i, Vector3(-58 + i * 13, 1.0, 18 + sin(i) * 9), Vector3(11, 2, 4), 8.0, Color(0.50, 0.50, 0.47))
	for i in range(12):
		_add_city_block(root, "DockMemory_%02d" % i, Vector3(-66 + i * 12, 0.6, 66), Vector3(8, 1.2, 10), 0.0, Color(0.36, 0.35, 0.32))
	_build_echo_tower()

func _build_memory_city_zora() -> void:
	var root := Node3D.new()
	root.name = "ZoraMnemonicGrid"
	_active_city_parent().add_child(root)
	for x in range(-4, 5):
		_add_city_block(root, "EastWestStreet_%d" % x, Vector3(0, 0.12, x * 13), Vector3(112, 0.24, 3.2), 0.0, Color(0.46, 0.47, 0.45))
	for z in range(-4, 5):
		_add_city_block(root, "NorthSouthStreet_%d" % z, Vector3(z * 13, 0.14, 0), Vector3(3.2, 0.28, 112), 0.0, Color(0.47, 0.48, 0.46))
	for i in range(36):
		var x := -52.0 + float(i % 9) * 13.0
		var z := -52.0 + float(i / 9) * 17.0
		var h := 3.5 + float(i % 5) * 1.7
		_add_city_block(root, "MemoryCell_%02d" % i, Vector3(x, h * 0.5, z), Vector3(6, h, 6), 0.0, Color(0.54, 0.55, 0.51))
	_add_city_tower(root, "GlassAstronomyTower", Vector3(48, 0, -42), 3.0, 18.0, Color(0.50, 0.66, 0.72), false)
	_build_echo_tower()

func _build_memory_city_maurilia() -> void:
	var root := Node3D.new()
	root.name = "MauriliaPostcardCity"
	_active_city_parent().add_child(root)
	for i in range(20):
		var x := -62.0 + float(i % 5) * 31.0
		var z := -50.0 + float(i / 5) * 28.0
		var h := 8.0 + float((i * 3) % 8) * 3.0
		_add_city_block(root, "NewCityBlock_%02d" % i, Vector3(x, h * 0.5, z), Vector3(12, h, 10), float(i * 7), Color(0.46, 0.48, 0.50))
	for i in range(12):
		var x := -50.0 + float(i % 4) * 18.0
		var z := 48.0 + float(i / 4) * 11.0
		_add_city_block(root, "OldPostcardBlock_%02d" % i, Vector3(x, 2.0, z), Vector3(9, 4, 7), -8.0, Color(0.62, 0.56, 0.48))
	for i in range(7):
		_add_city_block(root, "PostcardPanel_%02d" % i, Vector3(58, 4.5, -42 + i * 14), Vector3(0.5, 9, 8), 0.0, Color(0.70, 0.63, 0.52))
	_build_echo_tower()

func _build_outer_city_expansion(parent: Node3D, variant_index: int) -> void:
	var root := Node3D.new()
	root.name = "OuterCityExpansion"
	parent.add_child(root)

	var palette := [
		Color(0.54, 0.54, 0.50),
		Color(0.52, 0.50, 0.46),
		Color(0.46, 0.47, 0.45),
		Color(0.50, 0.52, 0.49),
		Color(0.50, 0.49, 0.47)
	]
	var base_color: Color = palette[variant_index % palette.size()]
	_add_city_block(root, "ExpandedCityGround", Vector3(0, -0.015, 0), Vector3(240, 0.06, 240), 0.0, base_color.darkened(0.16))

	for i in range(8):
		var yaw := 22.5 * float(i) + float(variant_index) * 4.0
		var length := 190.0 + float(i % 3) * 18.0
		_add_city_block(root, "OuterAvenue_%02d" % i, Vector3(0, 0.035 + float(i) * 0.002, 0), Vector3(length, 0.07, 3.4), yaw, base_color.darkened(0.08))

	for i in range(42):
		var angle: float = TAU * float(i) / 42.0 + float(variant_index) * 0.09
		var ring := 78.0 + float(i % 4) * 12.0
		var pos := Vector3(cos(angle) * ring, 0, sin(angle) * ring)
		if _is_inside_echo_tower_clear_zone(pos, Vector3(10, 10, 10)):
			continue
		var height := 6.0 + float((i * 5 + variant_index * 3) % 11) * 2.2
		var width := 6.0 + float(i % 3) * 2.0
		var depth := 7.0 + float((i + 1) % 4) * 1.8
		var color := base_color.lerp(Color(0.68, 0.68, 0.62), float(i % 5) * 0.06)
		_add_city_block(root, "OuterMemoryBlock_%02d" % i, Vector3(pos.x, height * 0.5, pos.z), Vector3(width, height, depth), rad_to_deg(-angle) + float(i % 7) * 3.0, color)

func _build_city_boundary_walls() -> void:
	if not city_boundary_enabled:
		return
	var h := city_boundary_wall_height
	var half := city_boundary_half_extent
	var thickness := 2.0
	_add_box_collision("CityBoundary_North", Vector3(0, h * 0.5, -half), Vector3(half * 2.0, h, thickness), 0.0)
	_add_box_collision("CityBoundary_South", Vector3(0, h * 0.5, half), Vector3(half * 2.0, h, thickness), 0.0)
	_add_box_collision("CityBoundary_West", Vector3(-half, h * 0.5, 0), Vector3(thickness, h, half * 2.0), 0.0)
	_add_box_collision("CityBoundary_East", Vector3(half, h * 0.5, 0), Vector3(thickness, h, half * 2.0), 0.0)

func _build_echo_tower() -> void:
	if echo_tower_built:
		return
	echo_tower_built = true
	var root := Node3D.new()
	root.name = "EchoTower"
	_active_city_parent().add_child(root)

	var base := CSGCylinder3D.new()
	base.name = "TowerBase"
	base.radius = 4.4
	base.height = 1.4
	base.sides = 32
	base.position.y = 0.55
	base.material = _mat(Color(0.50, 0.50, 0.47), 1.0)
	root.add_child(base)
	_add_box_collision("EchoTowerBaseCollision", Vector3(0, 0.55, 0), Vector3(9, 1.1, 9))

	var shaft := CSGCylinder3D.new()
	shaft.name = "CylinderMainTower"
	shaft.radius = 2.65
	shaft.height = 28.0
	shaft.sides = 40
	shaft.position.y = 15.4
	shaft.material = _mat(Color(0.58, 0.58, 0.53), 1.0)
	root.add_child(shaft)
	_add_box_collision("EchoTowerShaftCollision", Vector3(0, 15.4, 0), Vector3(5.6, 28, 5.6))

	for i in range(6):
		var angle := TAU * float(i) / 6.0
		var win := CSGBox3D.new()
		win.name = "BlackWindow_%02d" % i
		win.size = Vector3(0.08, 1.6, 0.8)
		win.position = Vector3(cos(angle) * 2.72, 18.0, sin(angle) * 2.72)
		win.rotation.y = -angle
		win.material = _mat(Color(0.03, 0.035, 0.04), 1.0)
		root.add_child(win)

	var bell := CSGCylinder3D.new()
	bell.name = "SimpleBellTop"
	bell.radius = 3.0
	bell.height = 2.2
	bell.sides = 32
	bell.position.y = 30.3
	bell.material = _mat(Color(0.43, 0.43, 0.39), 1.0)
	root.add_child(bell)

	var cap := CSGCylinder3D.new()
	cap.name = "FlatCap"
	cap.radius = 1.6
	cap.height = 1.2
	cap.sides = 24
	cap.position.y = 32.0
	cap.material = _mat(Color(0.36, 0.36, 0.34), 1.0)
	root.add_child(cap)

	if reading_trigger == null:
		reading_trigger = Area3D.new()
		reading_trigger.name = "ReadingTrigger"
		reading_trigger.position = Vector3(0, 0.8, 6.2)
		reading_trigger.collision_layer = 0
		reading_trigger.collision_mask = 2
		var shape := CollisionShape3D.new()
		var sphere := SphereShape3D.new()
		sphere.radius = 4.0
		shape.shape = sphere
		reading_trigger.add_child(shape)
		reading_trigger.body_entered.connect(_on_reading_trigger_entered)
		reading_trigger.body_exited.connect(_on_reading_trigger_exited)
		manifested_city.add_child(reading_trigger)

func _build_audio_players() -> void:
	global_music_player = AudioStreamPlayer.new()
	global_music_player.name = "GlobalThemeMusic"
	global_music_player.volume_db = intro_bgm_volume_db
	global_music_player.bus = "WorldReverb"
	global_music_player.stream = _audio_stream_or_generator([MEMORY_LONG_BGM_AUDIO_PATH, CITY_MEMORY_AUDIO_PATH, LEGACY_MEMORY_AUDIO_PATH], true)
	add_child(global_music_player)
	_register_generator(global_music_player, 146.0)

	theme_sfx_player = AudioStreamPlayer3D.new()
	theme_sfx_player.name = "ThemeSeekingSFX"
	theme_sfx_player.position = MEMORY_POS
	theme_sfx_player.max_distance = theme_sfx_hearing_distance
	theme_sfx_player.unit_size = 22.0
	theme_sfx_player.attenuation_model = AudioStreamPlayer3D.ATTENUATION_INVERSE_DISTANCE
	theme_sfx_player.volume_db = theme_sfx_volume_far_db
	theme_sfx_player.bus = "MemoryZone"
	add_child(theme_sfx_player)
	memory_zone_player = theme_sfx_player
	_register_generator(theme_sfx_player, 220.0)

	for i in range(THEME_NAMES.size()):
		var p := AudioStreamPlayer3D.new()
		p.name = "ZoneSFX_%s" % _ascii_zone_name(THEME_NAMES[i], i)
		p.position = ZONE_POSITIONS[i]
		p.max_distance = max(ZONE_SHAPES[i].x, ZONE_SHAPES[i].y) * 0.62
		p.unit_size = 14.0
		p.attenuation_model = AudioStreamPlayer3D.ATTENUATION_INVERSE_DISTANCE
		p.volume_db = zone_sfx_volume_db
		p.bus = "WorldReverb"
		add_child(p)
		zone_audio_players.append(p)
		_register_generator(p, 180.0 + float(i) * 19.0)
		zone_sfx_timers.append(rng.randf_range(zone_sfx_min_interval, zone_sfx_max_interval))

func _build_ui() -> void:
	ui_root = Control.new()
	ui_root.name = "UI"
	ui_root.set_anchors_preset(Control.PRESET_FULL_RECT)
	add_child(ui_root)

	grey_post_process_rect = ColorRect.new()
	grey_post_process_rect.name = "GreyPostProcess"
	grey_post_process_rect.set_anchors_preset(Control.PRESET_FULL_RECT)
	grey_post_process_rect.mouse_filter = Control.MOUSE_FILTER_IGNORE
	grey_post_process_rect.visible = false
	grey_post_process_material = ShaderMaterial.new()
	grey_post_process_material.shader = load("res://shaders/grey_post_process.gdshader")
	grey_post_process_rect.material = grey_post_process_material
	ui_root.add_child(grey_post_process_rect)

	direction_tint = ColorRect.new()
	direction_tint.name = "DirectionFeedbackController"
	direction_tint.set_anchors_preset(Control.PRESET_FULL_RECT)
	direction_tint.mouse_filter = Control.MOUSE_FILTER_IGNORE
	direction_tint.color = Color(0.72, 0.62, 0.45, 0.0)
	ui_root.add_child(direction_tint)

	main_menu = _center_panel("MainMenu")
	var title := _label("看不见的城市\nInvisible Cities", 38)
	main_menu.add_child(title)
	main_menu.add_child(_button("开始", _on_start_pressed))
	main_menu.add_child(_button("选项", _open_options))
	main_menu.add_child(_button("退出", func(): get_tree().quit()))
	ui_root.add_child(main_menu)

	story_panel = _center_panel("StoryIntro")
	story_text = _label("", 28)
	story_panel.add_child(story_text)
	story_next_button = _button("继续", _advance_story)
	story_panel.add_child(story_next_button)
	ui_root.add_child(story_panel)

	options_panel = _center_panel("OptionsPanel")
	options_panel.add_child(_label("选项", 30))
	options_panel.add_child(_label("第一版保留基础参数：鼠标灵敏度、视角平滑、音量可在 Main 节点 Inspector 中调整。", 18))
	options_panel.add_child(_button("返回", _enter_main_menu))
	ui_root.add_child(options_panel)

	theme_select = _center_panel("ThemeSelect")
	theme_select.add_child(_label("选择城市的描述", 30))
	theme_select_status_label = _label("", 17)
	theme_select.add_child(theme_select_status_label)
	theme_buttons.clear()
	for i in range(THEME_NAMES.size()):
		var callback: Callable = _disabled_theme_pressed
		if i == THEME_MEMORY:
			callback = _on_memory_theme_pressed
		elif i == THEME_DESIRE:
			callback = _on_desire_theme_pressed
		elif i == THEME_SIGNS:
			callback = _on_signs_theme_pressed
		elif i == THEME_THIN:
			callback = _on_thin_theme_pressed
		elif i == THEME_TRADE:
			callback = _on_trade_theme_pressed
		elif i == THEME_EYES:
			callback = _on_eyes_theme_pressed
		elif i == THEME_NAMES_CITY:
			callback = _on_names_theme_pressed
		elif i == THEME_DEAD:
			callback = _on_dead_theme_pressed
		elif i == THEME_SKY:
			callback = _on_sky_theme_pressed
		elif i == THEME_CONTINUOUS:
			callback = _on_continuous_theme_pressed
		elif i == THEME_HIDDEN:
			callback = _on_hidden_theme_pressed
		var b := _button(THEME_NAMES[i], callback)
		theme_buttons.append(b)
		theme_select.add_child(b)
	ui_root.add_child(theme_select)
	_update_theme_unlocks()

	mechanic_prompt = _center_panel("MechanicPrompt")
	mechanic_prompt.add_child(_label("跟随声的指引，寻找你所往的城市。", 26))
	mechanic_prompt.add_child(_label("主城被划分为十一片灰域。每片区域都有自己的声音；越靠近正确主题的中心，声音越清晰、越强。", 18))
	mechanic_prompt.add_child(_button("进入主城", _begin_memory_level))
	ui_root.add_child(mechanic_prompt)

	hint_label = Label.new()
	hint_label.name = "HintText"
	hint_label.text = ""
	hint_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	hint_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	hint_label.add_theme_font_size_override("font_size", 24)
	hint_label.set_anchors_preset(Control.PRESET_BOTTOM_WIDE)
	hint_label.offset_top = -120
	hint_label.offset_bottom = -48
	hint_label.modulate.a = 0.0
	ui_root.add_child(hint_label)

	quick_hint_label = Label.new()
	quick_hint_label.name = "QuickStartHint"
	quick_hint_label.text = ""
	quick_hint_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	quick_hint_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	quick_hint_label.add_theme_font_size_override("font_size", 17)
	quick_hint_label.add_theme_color_override("font_color", Color(0.90, 0.88, 0.78, 0.88))
	quick_hint_label.add_theme_color_override("font_shadow_color", Color(0.0, 0.0, 0.0, 0.38))
	quick_hint_label.add_theme_constant_override("shadow_offset_x", 1)
	quick_hint_label.add_theme_constant_override("shadow_offset_y", 1)
	quick_hint_label.set_anchors_preset(Control.PRESET_TOP_WIDE)
	quick_hint_label.offset_top = 24
	quick_hint_label.offset_bottom = 58
	quick_hint_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	quick_hint_label.modulate.a = 0.0
	quick_hint_label.visible = false
	ui_root.add_child(quick_hint_label)

	grey_countdown_label = Label.new()
	grey_countdown_label.name = "GreySearchCountdown"
	grey_countdown_label.text = "寻声 01:00"
	grey_countdown_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_LEFT
	grey_countdown_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	grey_countdown_label.add_theme_font_size_override("font_size", 17)
	grey_countdown_label.add_theme_color_override("font_color", Color(0.92, 0.90, 0.78, 0.82))
	grey_countdown_label.add_theme_color_override("font_shadow_color", Color(0.0, 0.0, 0.0, 0.42))
	grey_countdown_label.add_theme_constant_override("shadow_offset_x", 1)
	grey_countdown_label.add_theme_constant_override("shadow_offset_y", 1)
	grey_countdown_label.set_anchors_preset(Control.PRESET_TOP_LEFT)
	grey_countdown_label.offset_left = 24
	grey_countdown_label.offset_right = 210
	grey_countdown_label.offset_top = 22
	grey_countdown_label.offset_bottom = 52
	grey_countdown_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	grey_countdown_label.visible = false
	ui_root.add_child(grey_countdown_label)

	grey_guidance_root = Control.new()
	grey_guidance_root.name = "GreyTimedLineGuidance"
	grey_guidance_root.set_anchors_preset(Control.PRESET_FULL_RECT)
	grey_guidance_root.mouse_filter = Control.MOUSE_FILTER_IGNORE
	grey_guidance_root.visible = false
	ui_root.add_child(grey_guidance_root)
	grey_guidance_lines.clear()
	for i in range(grey_guidance_line_count):
		var line := ColorRect.new()
		line.name = "GuideLine_%02d" % i
		line.color = Color(0.88, 0.84, 0.64, 0.0)
		line.size = Vector2(46.0 + float(i % 3) * 10.0, 2.0)
		line.pivot_offset = Vector2(0.0, 1.0)
		line.mouse_filter = Control.MOUSE_FILTER_IGNORE
		grey_guidance_root.add_child(line)
		grey_guidance_lines.append(line)

	reading_panel = _center_panel("ReadingPanel")
	reading_text = _label("", 28)
	reading_panel.add_child(reading_text)
	reading_next_button = _button("继续", _advance_reading)
	reading_panel.add_child(reading_next_button)
	ui_root.add_child(reading_panel)

	choice_panel = _center_panel("ChoicePanel")
	choice_panel.add_child(_label("要把这座城留下吗？", 28))
	choice_panel.add_child(_button("留：让它成为我的城市", _choose_stay))
	choice_panel.add_child(_button("去：前往下一座看不见的城市", _choose_leave))
	ui_root.add_child(choice_panel)

	pause_menu = _center_panel("PauseMenu")
	pause_menu.add_child(_label("暂停", 30))
	pause_menu.add_child(_button("继续", _hide_pause_menu))
	pause_menu.add_child(_button("返回主题选择", _return_to_theme_select))
	ui_root.add_child(pause_menu)

	operation_hint_panel = PanelContainer.new()
	operation_hint_panel.name = "OperationHint"
	operation_hint_panel.set_anchors_preset(Control.PRESET_TOP_RIGHT)
	operation_hint_panel.offset_left = -260
	operation_hint_panel.offset_right = -24
	operation_hint_panel.offset_top = 24
	operation_hint_panel.offset_bottom = 252
	operation_hint_panel.mouse_filter = Control.MOUSE_FILTER_IGNORE
	operation_hint_panel.modulate.a = 0.0
	var hint_style := StyleBoxFlat.new()
	hint_style.bg_color = Color(0.04, 0.045, 0.05, 0.34)
	hint_style.corner_radius_top_left = 6
	hint_style.corner_radius_top_right = 6
	hint_style.corner_radius_bottom_left = 6
	hint_style.corner_radius_bottom_right = 6
	operation_hint_panel.add_theme_stylebox_override("panel", hint_style)
	operation_hint_label = Label.new()
	operation_hint_label.text = "前进：W\n后退：S\n左移：A\n右移：D\n跳跃：Space\n轻微加速：Shift\n转动视角：按住鼠标左键拖动\n交互：E\n暂停：Esc\n帮助：H\n调试区域：F2"
	operation_hint_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_LEFT
	operation_hint_label.vertical_alignment = VERTICAL_ALIGNMENT_TOP
	operation_hint_label.add_theme_font_size_override("font_size", 16)
	operation_hint_label.add_theme_color_override("font_color", Color(0.88, 0.88, 0.82, 0.88))
	operation_hint_label.set("theme_override_constants/line_spacing", 4)
	operation_hint_panel.add_child(operation_hint_label)
	ui_root.add_child(operation_hint_panel)

	_hide_all_ui()

func _enter_main_menu() -> void:
	phase = GamePhase.MAIN_MENU
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	player.set_locked(true)
	player.set_look_locked(true)
	_hide_operation_hint()
	_hide_all_ui()
	main_menu.visible = true

func _on_start_pressed() -> void:
	phase = GamePhase.STORY
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	player.set_locked(true)
	player.set_look_locked(true)
	_hide_operation_hint()
	_hide_all_ui()
	story_page = 0
	_show_story_page()
	_show_panel_fade(story_panel, ui_fade_in_duration)

func _open_options() -> void:
	phase = GamePhase.OPTIONS
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	player.set_locked(true)
	player.set_look_locked(true)
	_hide_operation_hint()
	_hide_all_ui()
	_show_panel_fade(options_panel, choice_fade_in_duration)

func _show_story_page() -> void:
	story_text.text = "\n".join(STORY_PAGES[story_page])
	story_next_button.text = "选择城市" if story_page == STORY_PAGES.size() - 1 else "继续"

func _advance_story() -> void:
	if story_page < STORY_PAGES.size() - 1:
		story_page += 1
		_show_story_page()
	else:
		_enter_theme_select()

func _enter_theme_select() -> void:
	if story_tween != null:
		story_tween.kill()
	phase = GamePhase.THEME_SELECT
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	player.set_locked(true)
	player.set_look_locked(true)
	_hide_operation_hint()
	_reset_level_state()
	_hide_all_ui()
	_update_theme_unlocks()
	theme_select.visible = true

func _on_memory_theme_pressed() -> void:
	_on_theme_pressed(THEME_MEMORY)

func _on_desire_theme_pressed() -> void:
	_on_theme_pressed(THEME_DESIRE)

func _on_signs_theme_pressed() -> void:
	_on_theme_pressed(THEME_SIGNS)

func _on_thin_theme_pressed() -> void:
	_on_theme_pressed(THEME_THIN)

func _on_trade_theme_pressed() -> void:
	_on_theme_pressed(THEME_TRADE)

func _on_eyes_theme_pressed() -> void:
	_on_theme_pressed(THEME_EYES)

func _on_names_theme_pressed() -> void:
	_on_theme_pressed(THEME_NAMES_CITY)

func _on_dead_theme_pressed() -> void:
	_on_theme_pressed(THEME_DEAD)

func _on_sky_theme_pressed() -> void:
	_on_theme_pressed(THEME_SKY)

func _on_continuous_theme_pressed() -> void:
	_on_theme_pressed(THEME_CONTINUOUS)

func _on_hidden_theme_pressed() -> void:
	_on_theme_pressed(THEME_HIDDEN)

func _on_theme_pressed(theme_index: int) -> void:
	if theme_index != THEME_MEMORY and not memory_completed:
		_update_theme_unlocks()
		_show_hint("先完成记忆之城，再选择其他城市。", 2.4)
		return
	selected_theme_index = theme_index
	phase = GamePhase.MECHANIC_PROMPT
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	player.set_locked(true)
	player.set_look_locked(true)
	_hide_operation_hint()
	_hide_all_ui()
	_play_intro_bgm()
	_show_panel_fade(mechanic_prompt, choice_fade_in_duration)

func _begin_memory_level() -> void:
	phase = GamePhase.GREY_VOID
	_hide_all_ui()
	memory_center_trigger.position = _selected_theme_position()
	if memory_guide_light != null and memory_guide_light.get_parent() is Node3D:
		var guide_parent := memory_guide_light.get_parent() as Node3D
		guide_parent.position = _selected_theme_position() + Vector3(0, 2.2, 0)
	player.global_position = _random_player_spawn()
	player.rotation = Vector3.ZERO
	player.head.rotation = Vector3.ZERO
	player.sync_look_targets()
	player.set_footstep_set("grey")
	player.set_look_locked(false)
	player.set_locked(false)
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	manifested_city.visible = false
	grey_visual_root.visible = true
	grey_particles.emitting = true
	if grey_sand_particles != null:
		grey_sand_particles.emitting = true
	if grey_current_particles != null:
		grey_current_particles.emitting = true
	if grey_willow_particles != null:
		grey_willow_particles.emitting = true
	if grey_storm_particles != null:
		grey_storm_particles.emitting = true
	if grey_turbulence_particles != null:
		grey_turbulence_particles.emitting = true
	_set_extra_grey_environment_active(true)
	_stop_intro_bgm_for_grey()
	_reset_grey_sfx_timers()
	_reset_grey_guidance()
	_show_quick_start_hint()

func _disabled_theme_pressed() -> void:
	_show_hint("先完成记忆之城，再选择其他城市。", 2.4)

func _update_theme_unlocks() -> void:
	if theme_select_status_label != null:
		if memory_completed:
			theme_select_status_label.text = "记忆已完成。当前 11 座主题城市均可选择。"
		else:
			theme_select_status_label.text = "先完成“记忆”，再自由选择其他城市。"
	for i in range(theme_buttons.size()):
		var button := theme_buttons[i]
		var playable_after_memory := i == THEME_DESIRE or i == THEME_SIGNS or i == THEME_THIN or i == THEME_TRADE or i == THEME_EYES or i == THEME_NAMES_CITY or i == THEME_DEAD or i == THEME_SKY or i == THEME_CONTINUOUS or i == THEME_HIDDEN
		var unlocked := i == THEME_MEMORY or (memory_completed and playable_after_memory)
		button.disabled = not unlocked
		button.text = THEME_NAMES[i]
		if playable_after_memory and not memory_completed:
			button.text = "%s（完成记忆后解锁）" % THEME_NAMES[i]
		elif i != THEME_MEMORY and not playable_after_memory:
			button.text = "%s（后续）" % THEME_NAMES[i]
			unlocked = false
			button.disabled = true
		button.modulate = Color(1.0, 1.0, 1.0, 1.0) if not button.disabled else Color(0.55, 0.55, 0.55, 0.75)

func _on_memory_center_entered(body: Node3D) -> void:
	if body == player and phase == GamePhase.GREY_VOID and not manifest_started:
		_start_manifest_sequence()

func _random_player_spawn() -> Vector3:
	for i in range(24):
		var candidate: Vector3 = PLAYER_SPAWN_POINTS[rng.randi_range(0, PLAYER_SPAWN_POINTS.size() - 1)]
		if _is_valid_spawn_point(candidate):
			return candidate
	return PLAYER_SPAWN

func _is_valid_spawn_point(candidate: Vector3) -> bool:
	var flat := Vector2(candidate.x, candidate.z)
	var theme_pos := _selected_theme_position()
	var theme_flat := Vector2(theme_pos.x, theme_pos.z)
	if flat.distance_to(Vector2.ZERO) < min_spawn_distance_from_echo_tower:
		return false
	if flat.distance_to(theme_flat) < min_spawn_distance_from_memory_center:
		return false
	return true

func _update_grey_wrap() -> void:
	if not grey_wrap_enabled or player == null:
		return
	var half := maxf(grey_wrap_half_extent, 8.0)
	var margin := clampf(grey_wrap_margin, 0.2, half * 0.25)
	var pos: Vector3 = player.global_position
	var warped := false
	if pos.x > half:
		pos.x = -half + margin
		warped = true
	elif pos.x < -half:
		pos.x = half - margin
		warped = true
	if pos.z > half:
		pos.z = -half + margin
		warped = true
	elif pos.z < -half:
		pos.z = half - margin
		warped = true
	if pos.y < grey_fall_reset_y:
		pos.y = 0.35
		warped = true
	if warped:
		player.global_position = pos

func _start_manifest_sequence() -> void:
	manifest_started = true
	phase = GamePhase.MANIFESTING
	player.set_locked(true)
	player.set_look_locked(true)
	_hide_operation_hint()
	_hide_quick_start_hint()
	_stop_grey_sfx()
	manifest_camera_applied_offset = 0.0
	_select_memory_city_variant(selected_theme_index)
	manifested_city.visible = true
	_set_city_collision_enabled(false)
	var tween := create_tween()
	tween.set_parallel(true)
	tween.tween_property(environment, "fog_density", fog_end_value, manifestation_duration).from(fog_start_value).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_IN)
	tween.tween_property(environment, "adjustment_saturation", 1.0, manifestation_duration).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	tween.tween_property(environment, "adjustment_contrast", 1.0, manifestation_duration).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	tween.tween_property(grey_particles, "amount", MIN_GPU_PARTICLE_AMOUNT, max(particle_fade_end - particle_fade_start, 0.1)).set_delay(particle_fade_start).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_IN)
	if grey_sand_particles != null:
		tween.tween_property(grey_sand_particles, "amount", MIN_GPU_PARTICLE_AMOUNT, max(particle_fade_end - particle_fade_start, 0.1)).set_delay(particle_fade_start).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_IN)
	if grey_current_particles != null:
		tween.tween_property(grey_current_particles, "amount", MIN_GPU_PARTICLE_AMOUNT, max(particle_fade_end - particle_fade_start, 0.1)).set_delay(particle_fade_start).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_IN)
	if grey_willow_particles != null:
		tween.tween_property(grey_willow_particles, "amount", MIN_GPU_PARTICLE_AMOUNT, max(particle_fade_end - particle_fade_start, 0.1)).set_delay(particle_fade_start).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_IN)
	if grey_storm_particles != null:
		tween.tween_property(grey_storm_particles, "amount", MIN_GPU_PARTICLE_AMOUNT, max(particle_fade_end - particle_fade_start, 0.1)).set_delay(particle_fade_start).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_IN)
	if grey_turbulence_particles != null:
		tween.tween_property(grey_turbulence_particles, "amount", MIN_GPU_PARTICLE_AMOUNT, max(particle_fade_end - particle_fade_start, 0.1)).set_delay(particle_fade_start).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_IN)
	_fade_extra_grey_particles(tween)
	if grey_environment_root != null:
		tween.tween_callback(func(): grey_environment_root.visible = false).set_delay(max(manifestation_duration - 1.0, 0.1))
	tween.tween_callback(func(): grey_silhouettes.visible = false).set_delay(max(manifestation_duration - 1.4, 0.1))
	tween.tween_property(world_reverb, "wet", city_reverb_wet, manifestation_duration).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	tween.tween_property(world_reverb, "room_size", city_reverb_room_size, manifestation_duration).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	if camera_framing_enabled:
		tween.tween_method(_apply_manifest_camera_offset, 0.0, manifestation_camera_pitch_offset, manifestation_camera_framing_duration).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	await tween.finished
	grey_visual_root.visible = false
	grey_particles.emitting = false
	if grey_sand_particles != null:
		grey_sand_particles.emitting = false
	if grey_current_particles != null:
		grey_current_particles.emitting = false
	if grey_willow_particles != null:
		grey_willow_particles.emitting = false
	if grey_storm_particles != null:
		grey_storm_particles.emitting = false
	if grey_turbulence_particles != null:
		grey_turbulence_particles.emitting = false
	_set_extra_grey_environment_active(false)
	_set_city_collision_enabled(true)
	phase = GamePhase.CITY
	_reset_city_guidance_timer()
	player.set_footstep_set("city")
	player.set_look_locked(false)
	player.sync_look_targets()
	player.set_locked(false)
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	_play_city_bgm()
	_show_hint("%s 已显现。\n通关玩法：%s" % [MEMORY_CITY_TITLES[selected_memory_city_index], _city_entry_objective_text()], 6.0)

func _apply_manifest_camera_offset(offset_degrees: float) -> void:
	var delta := offset_degrees - manifest_camera_applied_offset
	manifest_camera_applied_offset = offset_degrees
	player.add_pitch_offset(delta)

func _on_reading_trigger_entered(body: Node3D) -> void:
	if body == player and phase == GamePhase.CITY and selected_theme_index == THEME_MEMORY:
		can_read_tower = true
		_show_hint("按 E 阅读回声塔。", 2.5)

func _on_reading_trigger_exited(body: Node3D) -> void:
	if body == player and selected_theme_index == THEME_MEMORY:
		can_read_tower = false

func _is_player_near_reading_trigger() -> bool:
	if player == null or not manifested_city.visible:
		return false
	if selected_theme_index == THEME_DESIRE:
		return desire_goal_trigger != null and _is_desire_collection_complete() and player.global_position.distance_to(desire_goal_trigger.global_position) <= reading_interact_radius + 3.0
	if selected_theme_index == THEME_SIGNS:
		return sign_goal_trigger != null and _is_sign_fracture_complete() and player.global_position.distance_to(sign_goal_trigger.global_position) <= reading_interact_radius + 3.0
	if selected_theme_index == THEME_THIN:
		return thin_goal_trigger != null and _is_thin_ascent_complete() and player.global_position.distance_to(thin_goal_trigger.global_position) <= reading_interact_radius + 3.0
	if selected_theme_index == THEME_TRADE:
		return trade_goal_trigger != null and _is_trade_exchange_complete() and player.global_position.distance_to(trade_goal_trigger.global_position) <= reading_interact_radius + 3.0
	if selected_theme_index == THEME_EYES:
		return eye_goal_trigger != null and _is_eye_observation_complete() and player.global_position.distance_to(eye_goal_trigger.global_position) <= reading_interact_radius + 3.0
	if selected_theme_index == THEME_NAMES_CITY:
		return name_goal_trigger != null and _is_name_seal_complete() and player.global_position.distance_to(name_goal_trigger.global_position) <= reading_interact_radius + 3.0
	if selected_theme_index == THEME_DEAD:
		return dead_goal_trigger != null and _is_dead_echo_complete() and player.global_position.distance_to(dead_goal_trigger.global_position) <= reading_interact_radius + 3.0
	if selected_theme_index == THEME_SKY:
		return sky_goal_trigger != null and _is_sky_anchor_complete() and player.global_position.distance_to(sky_goal_trigger.global_position) <= reading_interact_radius + 3.0
	if selected_theme_index == THEME_CONTINUOUS:
		return continuous_goal_trigger != null and _is_continuous_sprawl_complete() and player.global_position.distance_to(continuous_goal_trigger.global_position) <= reading_interact_radius + 3.0
	if selected_theme_index == THEME_HIDDEN:
		return hidden_goal_trigger != null and _is_hidden_reveal_complete() and player.global_position.distance_to(hidden_goal_trigger.global_position) <= reading_interact_radius + 3.0
	if reading_trigger == null:
		return false
	return player.global_position.distance_to(reading_trigger.global_position) <= reading_interact_radius

func _on_desire_relic_entered(body: Node3D, relic_index: int) -> void:
	if body != player or phase != GamePhase.CITY or selected_theme_index != THEME_DESIRE:
		return
	if _is_desire_relic_collected(relic_index):
		return
	desire_active_relic_index = relic_index
	var data: Array = DESIRE_RELICS[relic_index]
	_show_hint("按 E 拾取：%s" % String(data[1]), 2.0)

func _on_desire_relic_exited(body: Node3D, relic_index: int) -> void:
	if body == player and desire_active_relic_index == relic_index:
		desire_active_relic_index = -1

func _collect_desire_relic(relic_index: int) -> void:
	if relic_index < 0 or relic_index >= DESIRE_RELICS.size():
		return
	if _is_desire_relic_collected(relic_index):
		return
	desire_collected_relics.append(relic_index)
	desire_active_relic_index = -1
	_reset_city_guidance_timer()
	var data: Array = DESIRE_RELICS[relic_index]
	if relic_index < desire_relic_visuals.size() and desire_relic_visuals[relic_index] != null:
		desire_relic_visuals[relic_index].visible = false
	if relic_index < desire_relic_areas.size() and desire_relic_areas[relic_index] != null:
		desire_relic_areas[relic_index].set_deferred("monitoring", false)
		desire_relic_areas[relic_index].set_deferred("monitorable", false)
	var count := desire_collected_relics.size()
	if _is_desire_collection_complete():
		_show_hint("%s\n欲望物已集齐。前往月光迷宫最深处。" % String(data[2]), 4.5)
	else:
		_show_hint("%s\n已收集 %d / %d。" % [String(data[2]), count, DESIRE_RELICS.size()], 4.0)

func _is_desire_relic_collected(relic_index: int) -> bool:
	return desire_collected_relics.has(relic_index)

func _is_desire_collection_complete() -> bool:
	return desire_collected_relics.size() >= DESIRE_RELICS.size()

func _reset_desire_relics() -> void:
	desire_collected_relics.clear()
	desire_active_relic_index = -1
	for relic in desire_relic_visuals:
		if relic != null:
			relic.visible = true
	for area in desire_relic_areas:
		if area != null:
			area.monitoring = true
			area.monitorable = true

func _on_desire_goal_entered(body: Node3D) -> void:
	if body != player or phase != GamePhase.CITY or selected_theme_index != THEME_DESIRE:
		return
	if _is_desire_collection_complete():
		can_read_tower = true
		_show_hint("按 E 阅读月光陷阱广场。", 2.5)
	else:
		var missing := DESIRE_RELICS.size() - desire_collected_relics.size()
		_show_hint("这里还没有回应。还需收集 %d 件欲望物。" % missing, 3.0)

func _on_desire_goal_exited(body: Node3D) -> void:
	if body == player and selected_theme_index == THEME_DESIRE:
		can_read_tower = false

func _on_sign_node_entered(body: Node3D, node_index: int) -> void:
	if body != player or phase != GamePhase.CITY or selected_theme_index != THEME_SIGNS:
		return
	if _is_sign_node_completed(node_index):
		return
	sign_active_node_index = node_index
	var data: Array = SIGN_FRACTURE_NODES[node_index]
	_show_hint("按 E 读取符号断点：%s" % String(data[1]), 2.4)

func _on_sign_node_exited(body: Node3D, node_index: int) -> void:
	if body == player and sign_active_node_index == node_index:
		sign_active_node_index = -1

func _activate_sign_fracture_node(node_index: int) -> void:
	if node_index < 0 or node_index >= SIGN_FRACTURE_NODES.size():
		return
	if _is_sign_node_completed(node_index):
		return
	sign_completed_nodes.append(node_index)
	sign_active_node_index = -1
	_reset_city_guidance_timer()
	_set_sign_fracture_visual_state(node_index, true)
	if node_index < sign_node_areas.size() and sign_node_areas[node_index] != null:
		sign_node_areas[node_index].set_deferred("monitoring", false)
		sign_node_areas[node_index].set_deferred("monitorable", false)
	var data: Array = SIGN_FRACTURE_NODES[node_index]
	var count := sign_completed_nodes.size()
	if _is_sign_fracture_complete():
		_show_hint("%s\n五处符号断点已沉默。前往中心无名广场。" % String(data[2]), 4.6)
	else:
		_show_hint("%s\n已读取 %d / %d。" % [String(data[2]), count, SIGN_FRACTURE_NODES.size()], 4.0)

func _is_sign_node_completed(node_index: int) -> bool:
	return sign_completed_nodes.has(node_index)

func _is_sign_fracture_complete() -> bool:
	return sign_completed_nodes.size() >= SIGN_FRACTURE_NODES.size()

func _reset_sign_fracture_nodes() -> void:
	sign_completed_nodes.clear()
	sign_active_node_index = -1
	for i in range(sign_node_visuals.size()):
		_set_sign_fracture_visual_state(i, false)
	for area in sign_node_areas:
		if area != null:
			area.monitoring = true
			area.monitorable = true

func _on_sign_goal_entered(body: Node3D) -> void:
	if body != player or phase != GamePhase.CITY or selected_theme_index != THEME_SIGNS:
		return
	if _is_sign_fracture_complete():
		can_read_tower = true
		_show_hint("按 E 阅读无名广场。", 2.5)
	else:
		var missing := SIGN_FRACTURE_NODES.size() - sign_completed_nodes.size()
		_show_hint("无名广场仍被符号覆盖。还需读取 %d 处符号断点。" % missing, 3.2)

func _on_sign_goal_exited(body: Node3D) -> void:
	if body == player and selected_theme_index == THEME_SIGNS:
		can_read_tower = false

func _on_thin_node_entered(body: Node3D, node_index: int) -> void:
	if body != player or phase != GamePhase.CITY or selected_theme_index != THEME_THIN:
		return
	if _is_thin_node_completed(node_index):
		return
	thin_active_node_index = node_index
	var data: Array = THIN_ASCENT_NODES[node_index]
	_show_hint("按 E 读取悬空节点：%s" % String(data[1]), 2.4)

func _on_thin_node_exited(body: Node3D, node_index: int) -> void:
	if body == player and thin_active_node_index == node_index:
		thin_active_node_index = -1

func _activate_thin_ascent_node(node_index: int) -> void:
	if node_index < 0 or node_index >= THIN_ASCENT_NODES.size():
		return
	if _is_thin_node_completed(node_index):
		return
	thin_completed_nodes.append(node_index)
	thin_active_node_index = -1
	_reset_city_guidance_timer()
	_set_thin_node_visual_state(node_index, true)
	if node_index < thin_node_areas.size() and thin_node_areas[node_index] != null:
		thin_node_areas[node_index].set_deferred("monitoring", false)
		thin_node_areas[node_index].set_deferred("monitorable", false)
	var data: Array = THIN_ASCENT_NODES[node_index]
	var count := thin_completed_nodes.size()
	if _is_thin_ascent_complete():
		_show_hint("%s\n五个悬空节点已经绷紧。回到中心网心瞭望台。" % String(data[2]), 4.6)
	else:
		_show_hint("%s\n已读取 %d / %d。" % [String(data[2]), count, THIN_ASCENT_NODES.size()], 4.0)

func _is_thin_node_completed(node_index: int) -> bool:
	return thin_completed_nodes.has(node_index)

func _is_thin_ascent_complete() -> bool:
	return thin_completed_nodes.size() >= THIN_ASCENT_NODES.size()

func _reset_thin_ascent_nodes() -> void:
	thin_completed_nodes.clear()
	thin_active_node_index = -1
	for i in range(thin_node_visuals.size()):
		_set_thin_node_visual_state(i, false)
	for area in thin_node_areas:
		if area != null:
			area.monitoring = true
			area.monitorable = true

func _on_thin_goal_entered(body: Node3D) -> void:
	if body != player or phase != GamePhase.CITY or selected_theme_index != THEME_THIN:
		return
	if _is_thin_ascent_complete():
		can_read_tower = true
		_show_hint("按 E 阅读网心瞭望台。", 2.5)
	else:
		var missing := THIN_ASCENT_NODES.size() - thin_completed_nodes.size()
		_show_hint("网心还没有完全绷紧。还需读取 %d 个悬空节点。" % missing, 3.2)

func _on_thin_goal_exited(body: Node3D) -> void:
	if body == player and selected_theme_index == THEME_THIN:
		can_read_tower = false

func _on_trade_node_entered(body: Node3D, node_index: int) -> void:
	if body != player or phase != GamePhase.CITY or selected_theme_index != THEME_TRADE:
		return
	if _is_trade_node_completed(node_index):
		return
	trade_active_node_index = node_index
	var data: Array = TRADE_EXCHANGE_NODES[node_index]
	_show_hint("按 E 完成交换：%s" % String(data[1]), 2.4)

func _on_trade_node_exited(body: Node3D, node_index: int) -> void:
	if body == player and trade_active_node_index == node_index:
		trade_active_node_index = -1

func _activate_trade_exchange_node(node_index: int) -> void:
	if node_index < 0 or node_index >= TRADE_EXCHANGE_NODES.size():
		return
	if _is_trade_node_completed(node_index):
		return
	trade_completed_nodes.append(node_index)
	trade_active_node_index = -1
	_reset_city_guidance_timer()
	_set_trade_exchange_visual_state(node_index, true)
	if node_index < trade_node_areas.size() and trade_node_areas[node_index] != null:
		trade_node_areas[node_index].set_deferred("monitoring", false)
		trade_node_areas[node_index].set_deferred("monitorable", false)
	var data: Array = TRADE_EXCHANGE_NODES[node_index]
	var count := trade_completed_nodes.size()
	if _is_trade_exchange_complete():
		_show_hint("%s\n五次交换已经写入账本。回到中心交易核。" % String(data[2]), 4.6)
	else:
		_show_hint("%s\n已完成交换 %d / %d。" % [String(data[2]), count, TRADE_EXCHANGE_NODES.size()], 4.0)

func _is_trade_node_completed(node_index: int) -> bool:
	return trade_completed_nodes.has(node_index)

func _is_trade_exchange_complete() -> bool:
	return trade_completed_nodes.size() >= TRADE_EXCHANGE_NODES.size()

func _reset_trade_exchange_nodes() -> void:
	trade_completed_nodes.clear()
	trade_active_node_index = -1
	for i in range(trade_node_visuals.size()):
		_set_trade_exchange_visual_state(i, false)
	for area in trade_node_areas:
		if area != null:
			area.monitoring = true
			area.monitorable = true

func _on_trade_goal_entered(body: Node3D) -> void:
	if body != player or phase != GamePhase.CITY or selected_theme_index != THEME_TRADE:
		return
	if _is_trade_exchange_complete():
		can_read_tower = true
		_show_hint("按 E 阅读中心交易核。", 2.5)
	else:
		var missing := TRADE_EXCHANGE_NODES.size() - trade_completed_nodes.size()
		_show_hint("中心交易核还没有开账。还需完成 %d 次交换。" % missing, 3.2)

func _on_trade_goal_exited(body: Node3D) -> void:
	if body == player and selected_theme_index == THEME_TRADE:
		can_read_tower = false

func _on_eye_observation_entered(body: Node3D, node_index: int) -> void:
	if body != player or phase != GamePhase.CITY or selected_theme_index != THEME_EYES:
		return
	if _is_eye_observation_completed(node_index):
		return
	eye_active_observation_index = node_index
	var data: Array = EYE_OBSERVATION_NODES[node_index]
	_show_hint("按 E 校准视线：%s" % String(data[1]), 2.4)

func _on_eye_observation_exited(body: Node3D, node_index: int) -> void:
	if body == player and eye_active_observation_index == node_index:
		eye_active_observation_index = -1

func _activate_eye_observation_node(node_index: int) -> void:
	if node_index < 0 or node_index >= EYE_OBSERVATION_NODES.size():
		return
	if _is_eye_observation_completed(node_index):
		return
	eye_completed_observations.append(node_index)
	eye_active_observation_index = -1
	_reset_city_guidance_timer()
	_set_eye_observation_visual_state(node_index, true)
	if node_index < eye_observation_areas.size() and eye_observation_areas[node_index] != null:
		eye_observation_areas[node_index].set_deferred("monitoring", false)
		eye_observation_areas[node_index].set_deferred("monitorable", false)
	var data: Array = EYE_OBSERVATION_NODES[node_index]
	var count := eye_completed_observations.size()
	if _is_eye_observation_complete():
		_show_hint("%s\n五处观察点已经校准。回到中心观景核。" % String(data[2]), 4.6)
	else:
		_show_hint("%s\n已校准 %d / %d。" % [String(data[2]), count, EYE_OBSERVATION_NODES.size()], 4.0)

func _is_eye_observation_completed(node_index: int) -> bool:
	return eye_completed_observations.has(node_index)

func _is_eye_observation_complete() -> bool:
	return eye_completed_observations.size() >= EYE_OBSERVATION_NODES.size()

func _reset_eye_observation_nodes() -> void:
	eye_completed_observations.clear()
	eye_active_observation_index = -1
	for i in range(eye_observation_visuals.size()):
		_set_eye_observation_visual_state(i, false)
	for area in eye_observation_areas:
		if area != null:
			area.monitoring = true
			area.monitorable = true

func _on_eye_goal_entered(body: Node3D) -> void:
	if body != player or phase != GamePhase.CITY or selected_theme_index != THEME_EYES:
		return
	if _is_eye_observation_complete():
		can_read_tower = true
		_show_hint("按 E 阅读中心观景核。", 2.5)
	else:
		var missing := EYE_OBSERVATION_NODES.size() - eye_completed_observations.size()
		_show_hint("中心观景核还没有对焦。还需校准 %d 处观察点。" % missing, 3.2)

func _on_eye_goal_exited(body: Node3D) -> void:
	if body == player and selected_theme_index == THEME_EYES:
		can_read_tower = false

func _on_name_seal_entered(body: Node3D, node_index: int) -> void:
	if body != player or phase != GamePhase.CITY or selected_theme_index != THEME_NAMES_CITY:
		return
	if _is_name_seal_completed(node_index):
		return
	name_active_seal_index = node_index
	var data: Array = NAME_SEAL_NODES[node_index]
	_show_hint("按 E 解名：%s" % String(data[1]), 2.4)

func _on_name_seal_exited(body: Node3D, node_index: int) -> void:
	if body == player and name_active_seal_index == node_index:
		name_active_seal_index = -1

func _activate_name_seal_node(node_index: int) -> void:
	if node_index < 0 or node_index >= NAME_SEAL_NODES.size():
		return
	if _is_name_seal_completed(node_index):
		return
	name_completed_seals.append(node_index)
	name_active_seal_index = -1
	_reset_city_guidance_timer()
	_set_name_seal_visual_state(node_index, true)
	if node_index < name_seal_areas.size() and name_seal_areas[node_index] != null:
		name_seal_areas[node_index].set_deferred("monitoring", false)
		name_seal_areas[node_index].set_deferred("monitorable", false)
	var data: Array = NAME_SEAL_NODES[node_index]
	var count := name_completed_seals.size()
	if _is_name_seal_complete():
		_show_hint("%s\n五处命名封印已经松动。回到消逝名字碑。" % String(data[2]), 4.6)
	else:
		_show_hint("%s\n已解名 %d / %d。" % [String(data[2]), count, NAME_SEAL_NODES.size()], 4.0)

func _is_name_seal_completed(node_index: int) -> bool:
	return name_completed_seals.has(node_index)

func _is_name_seal_complete() -> bool:
	return name_completed_seals.size() >= NAME_SEAL_NODES.size()

func _reset_name_seal_nodes() -> void:
	name_completed_seals.clear()
	name_active_seal_index = -1
	for i in range(name_seal_visuals.size()):
		_set_name_seal_visual_state(i, false)
	for area in name_seal_areas:
		if area != null:
			area.monitoring = true
			area.monitorable = true

func _on_name_goal_entered(body: Node3D) -> void:
	if body != player or phase != GamePhase.CITY or selected_theme_index != THEME_NAMES_CITY:
		return
	if _is_name_seal_complete():
		can_read_tower = true
		_show_hint("按 E 阅读消逝名字碑。", 2.5)
	else:
		var missing := NAME_SEAL_NODES.size() - name_completed_seals.size()
		_show_hint("消逝名字碑还被传说覆盖。还需解开 %d 处命名封印。" % missing, 3.2)

func _on_name_goal_exited(body: Node3D) -> void:
	if body == player and selected_theme_index == THEME_NAMES_CITY:
		can_read_tower = false

func _on_dead_echo_entered(body: Node3D, node_index: int) -> void:
	if body != player or phase != GamePhase.CITY or selected_theme_index != THEME_DEAD:
		return
	if _is_dead_echo_completed(node_index):
		return
	dead_active_echo_index = node_index
	var data: Array = DEAD_ECHO_NODES[node_index]
	_show_hint("按 E 安放回声：%s" % String(data[1]), 2.4)

func _on_dead_echo_exited(body: Node3D, node_index: int) -> void:
	if body == player and dead_active_echo_index == node_index:
		dead_active_echo_index = -1

func _activate_dead_echo_node(node_index: int) -> void:
	if node_index < 0 or node_index >= DEAD_ECHO_NODES.size():
		return
	if _is_dead_echo_completed(node_index):
		return
	dead_completed_echoes.append(node_index)
	dead_active_echo_index = -1
	_reset_city_guidance_timer()
	_set_dead_echo_visual_state(node_index, true)
	if node_index < dead_echo_areas.size() and dead_echo_areas[node_index] != null:
		dead_echo_areas[node_index].set_deferred("monitoring", false)
		dead_echo_areas[node_index].set_deferred("monitorable", false)
	var data: Array = DEAD_ECHO_NODES[node_index]
	var count := dead_completed_echoes.size()
	if _is_dead_echo_complete():
		_show_hint("%s\n五处亡者回声已经归位。前往沙漏塔。" % String(data[2]), 4.6)
	else:
		_show_hint("%s\n已安放 %d / %d。" % [String(data[2]), count, DEAD_ECHO_NODES.size()], 4.0)

func _is_dead_echo_completed(node_index: int) -> bool:
	return dead_completed_echoes.has(node_index)

func _is_dead_echo_complete() -> bool:
	return dead_completed_echoes.size() >= DEAD_ECHO_NODES.size()

func _reset_dead_echo_nodes() -> void:
	dead_completed_echoes.clear()
	dead_active_echo_index = -1
	for i in range(dead_echo_visuals.size()):
		_set_dead_echo_visual_state(i, false)
	for area in dead_echo_areas:
		if area != null:
			area.monitoring = true
			area.monitorable = true

func _on_dead_goal_entered(body: Node3D) -> void:
	if body != player or phase != GamePhase.CITY or selected_theme_index != THEME_DEAD:
		return
	if _is_dead_echo_complete():
		can_read_tower = true
		_show_hint("按 E 阅读沙漏塔。", 2.5)
	else:
		var missing := DEAD_ECHO_NODES.size() - dead_completed_echoes.size()
		_show_hint("沙漏塔仍在等待。还需安放 %d 处亡者回声。" % missing, 3.2)

func _on_dead_goal_exited(body: Node3D) -> void:
	if body == player and selected_theme_index == THEME_DEAD:
		can_read_tower = false

func _on_sky_anchor_entered(body: Node3D, node_index: int) -> void:
	if body != player or phase != GamePhase.CITY or selected_theme_index != THEME_SKY:
		return
	if _is_sky_anchor_completed(node_index):
		return
	sky_active_anchor_index = node_index
	var data: Array = SKY_ANCHOR_NODES[node_index]
	_show_hint("按 E 校准天体锚点：%s" % String(data[1]), 2.4)

func _on_sky_anchor_exited(body: Node3D, node_index: int) -> void:
	if body == player and sky_active_anchor_index == node_index:
		sky_active_anchor_index = -1

func _activate_sky_anchor_node(node_index: int) -> void:
	if node_index < 0 or node_index >= SKY_ANCHOR_NODES.size():
		return
	if _is_sky_anchor_completed(node_index):
		return
	sky_completed_anchors.append(node_index)
	sky_active_anchor_index = -1
	_reset_city_guidance_timer()
	_set_sky_anchor_visual_state(node_index, true)
	if node_index < sky_anchor_areas.size() and sky_anchor_areas[node_index] != null:
		sky_anchor_areas[node_index].set_deferred("monitoring", false)
		sky_anchor_areas[node_index].set_deferred("monitorable", false)
	var data: Array = SKY_ANCHOR_NODES[node_index]
	var count := sky_completed_anchors.size()
	if _is_sky_anchor_complete():
		_show_hint("%s\n五处天体锚点已经校准。前往星空观测塔。" % String(data[2]), 4.6)
	else:
		_show_hint("%s\n已校准 %d / %d。" % [String(data[2]), count, SKY_ANCHOR_NODES.size()], 4.0)

func _is_sky_anchor_completed(node_index: int) -> bool:
	return sky_completed_anchors.has(node_index)

func _is_sky_anchor_complete() -> bool:
	return sky_completed_anchors.size() >= SKY_ANCHOR_NODES.size()

func _reset_sky_anchor_nodes() -> void:
	sky_completed_anchors.clear()
	sky_active_anchor_index = -1
	for i in range(sky_anchor_visuals.size()):
		_set_sky_anchor_visual_state(i, false)
	for area in sky_anchor_areas:
		if area != null:
			area.monitoring = true
			area.monitorable = true

func _on_sky_goal_entered(body: Node3D) -> void:
	if body != player or phase != GamePhase.CITY or selected_theme_index != THEME_SKY:
		return
	if _is_sky_anchor_complete():
		can_read_tower = true
		_show_hint("按 E 阅读星空观测塔。", 2.5)
	else:
		var missing := SKY_ANCHOR_NODES.size() - sky_completed_anchors.size()
		_show_hint("星空观测塔还没有对齐。还需校准 %d 处天体锚点。" % missing, 3.2)

func _on_sky_goal_exited(body: Node3D) -> void:
	if body == player and selected_theme_index == THEME_SKY:
		can_read_tower = false

func _on_continuous_node_entered(body: Node3D, node_index: int) -> void:
	if body != player or phase != GamePhase.CITY or selected_theme_index != THEME_CONTINUOUS:
		return
	if _is_continuous_node_completed(node_index):
		return
	continuous_active_node_index = node_index
	var data: Array = CONTINUOUS_SPRAWL_NODES[node_index]
	_show_hint("按 E 记录连续节点：%s" % String(data[1]), 2.4)

func _on_continuous_node_exited(body: Node3D, node_index: int) -> void:
	if body == player and continuous_active_node_index == node_index:
		continuous_active_node_index = -1

func _activate_continuous_sprawl_node(node_index: int) -> void:
	if node_index < 0 or node_index >= CONTINUOUS_SPRAWL_NODES.size():
		return
	if _is_continuous_node_completed(node_index):
		return
	continuous_completed_nodes.append(node_index)
	continuous_active_node_index = -1
	_reset_city_guidance_timer()
	_set_continuous_node_visual_state(node_index, true)
	if node_index < continuous_node_areas.size() and continuous_node_areas[node_index] != null:
		continuous_node_areas[node_index].set_deferred("monitoring", false)
		continuous_node_areas[node_index].set_deferred("monitorable", false)
	var data: Array = CONTINUOUS_SPRAWL_NODES[node_index]
	var count := continuous_completed_nodes.size()
	if _is_continuous_sprawl_complete():
		_show_hint("%s\n五处连续压力已经被记录。回到中心无中心指示牌。" % String(data[2]), 4.6)
	else:
		_show_hint("%s\n已记录 %d / %d。" % [String(data[2]), count, CONTINUOUS_SPRAWL_NODES.size()], 4.0)

func _is_continuous_node_completed(node_index: int) -> bool:
	return continuous_completed_nodes.has(node_index)

func _is_continuous_sprawl_complete() -> bool:
	return continuous_completed_nodes.size() >= CONTINUOUS_SPRAWL_NODES.size()

func _reset_continuous_sprawl_nodes() -> void:
	continuous_completed_nodes.clear()
	continuous_active_node_index = -1
	for i in range(continuous_node_visuals.size()):
		_set_continuous_node_visual_state(i, false)
	for area in continuous_node_areas:
		if area != null:
			area.monitoring = true
			area.monitorable = true

func _on_continuous_goal_entered(body: Node3D) -> void:
	if body != player or phase != GamePhase.CITY or selected_theme_index != THEME_CONTINUOUS:
		return
	if _is_continuous_sprawl_complete():
		can_read_tower = true
		_show_hint("按 E 阅读无中心指示牌。", 2.5)
	else:
		var missing := CONTINUOUS_SPRAWL_NODES.size() - continuous_completed_nodes.size()
		_show_hint("无中心指示牌仍指向太多方向。还需记录 %d 处连续节点。" % missing, 3.2)

func _on_continuous_goal_exited(body: Node3D) -> void:
	if body == player and selected_theme_index == THEME_CONTINUOUS:
		can_read_tower = false

func _on_hidden_node_entered(body: Node3D, node_index: int) -> void:
	if body != player or phase != GamePhase.CITY or selected_theme_index != THEME_HIDDEN:
		return
	if _is_hidden_node_completed(node_index):
		return
	hidden_active_node_index = node_index
	var data: Array = HIDDEN_REVEAL_NODES[node_index]
	_show_hint("按 E 发现隐蔽节点：%s" % String(data[1]), 2.4)

func _on_hidden_node_exited(body: Node3D, node_index: int) -> void:
	if body == player and hidden_active_node_index == node_index:
		hidden_active_node_index = -1

func _activate_hidden_reveal_node(node_index: int) -> void:
	if node_index < 0 or node_index >= HIDDEN_REVEAL_NODES.size():
		return
	if _is_hidden_node_completed(node_index):
		return
	hidden_completed_nodes.append(node_index)
	hidden_active_node_index = -1
	_reset_city_guidance_timer()
	_set_hidden_node_visual_state(node_index, true)
	if node_index < hidden_node_areas.size() and hidden_node_areas[node_index] != null:
		hidden_node_areas[node_index].set_deferred("monitoring", false)
		hidden_node_areas[node_index].set_deferred("monitorable", false)
	var data: Array = HIDDEN_REVEAL_NODES[node_index]
	var count := hidden_completed_nodes.size()
	if _is_hidden_reveal_complete():
		_show_hint("%s\n五处隐蔽节点已经显形。回到中心隐蔽裂光。" % String(data[2]), 4.6)
	else:
		_show_hint("%s\n已发现 %d / %d。" % [String(data[2]), count, HIDDEN_REVEAL_NODES.size()], 4.0)

func _is_hidden_node_completed(node_index: int) -> bool:
	return hidden_completed_nodes.has(node_index)

func _is_hidden_reveal_complete() -> bool:
	return hidden_completed_nodes.size() >= HIDDEN_REVEAL_NODES.size()

func _reset_hidden_reveal_nodes() -> void:
	hidden_completed_nodes.clear()
	hidden_active_node_index = -1
	for i in range(hidden_node_visuals.size()):
		_set_hidden_node_visual_state(i, false)
	for area in hidden_node_areas:
		if area != null:
			area.monitoring = true
			area.monitorable = true

func _on_hidden_goal_entered(body: Node3D) -> void:
	if body != player or phase != GamePhase.CITY or selected_theme_index != THEME_HIDDEN:
		return
	if _is_hidden_reveal_complete():
		can_read_tower = true
		_show_hint("按 E 阅读隐蔽裂光。", 2.5)
	else:
		var missing := HIDDEN_REVEAL_NODES.size() - hidden_completed_nodes.size()
		_show_hint("裂光仍被暗处遮住。还需发现 %d 处隐蔽节点。" % missing, 3.2)

func _on_hidden_goal_exited(body: Node3D) -> void:
	if body == player and selected_theme_index == THEME_HIDDEN:
		can_read_tower = false

func _open_reading() -> void:
	_reset_city_guidance_timer()
	phase = GamePhase.READING
	player.set_locked(true)
	player.set_look_locked(true)
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	_hide_operation_hint()
	reading_page = 0
	_hide_all_ui()
	_show_reading_page()
	_show_panel_fade(reading_panel, choice_fade_in_duration)

func _show_reading_page() -> void:
	var pages: Array = _current_reading_pages()
	reading_text.text = "\n".join(pages[reading_page])
	reading_next_button.text = "完成" if reading_page == pages.size() - 1 else "继续"

func _advance_reading() -> void:
	var pages: Array = _current_reading_pages()
	if reading_page < pages.size() - 1:
		reading_page += 1
		_show_reading_page()
	else:
		_mark_current_theme_completed()
		phase = GamePhase.CHOICE
		reading_panel.visible = false
		_show_panel_fade(choice_panel, choice_fade_in_duration)

func _current_reading_pages() -> Array:
	if selected_memory_city_index >= 0 and selected_memory_city_index < MEMORY_CITY_READING_PAGES.size():
		return MEMORY_CITY_READING_PAGES[selected_memory_city_index]
	return READING_PAGES

func _mark_current_theme_completed() -> void:
	if selected_theme_index == THEME_MEMORY and not memory_completed:
		memory_completed = true
		_update_theme_unlocks()

func _choose_stay() -> void:
	phase = GamePhase.CITY
	choice_panel.visible = false
	player.set_look_locked(false)
	player.set_locked(false)
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	can_read_tower = _is_player_near_reading_trigger()
	if selected_theme_index == THEME_DESIRE:
		_show_hint("你仍在欲望之城。回到月光陷阱广场可再次阅读。", 3.0)
	elif selected_theme_index == THEME_SIGNS:
		_show_hint("你仍在符号之城。回到无名广场可再次阅读。", 3.0)
	elif selected_theme_index == THEME_THIN:
		_show_hint("你仍在轻盈之城。回到网心瞭望台可再次阅读。", 3.0)
	elif selected_theme_index == THEME_TRADE:
		_show_hint("你仍在贸易之城。回到中心交易核可再次阅读。", 3.0)
	elif selected_theme_index == THEME_EYES:
		_show_hint("你仍在眼睛之城。回到中心观景核可再次阅读。", 3.0)
	elif selected_theme_index == THEME_NAMES_CITY:
		_show_hint("你仍在姓名之城。回到消逝名字碑可再次阅读。", 3.0)
	elif selected_theme_index == THEME_DEAD:
		_show_hint("你仍在死者之城。回到沙漏塔可再次阅读。", 3.0)
	elif selected_theme_index == THEME_SKY:
		_show_hint("你仍在天空之城。回到星空观测塔可再次阅读。", 3.0)
	elif selected_theme_index == THEME_CONTINUOUS:
		_show_hint("你仍在连续之城。回到无中心指示牌可再次阅读。", 3.0)
	elif selected_theme_index == THEME_HIDDEN:
		_show_hint("你仍在隐蔽之城。回到隐蔽裂光可再次阅读。", 3.0)
	else:
		_show_hint("你仍在记忆之城。回到塔底可再次阅读。", 3.0)

func _choose_leave() -> void:
	_enter_theme_select()

func _return_to_theme_select() -> void:
	_hide_pause_menu()
	_enter_theme_select()

func _show_pause_menu() -> void:
	previous_phase = phase
	phase = GamePhase.PAUSED
	player.set_locked(true)
	player.set_look_locked(true)
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	_hide_operation_hint()
	_hide_quick_start_hint()
	pause_menu.visible = true

func _hide_pause_menu() -> void:
	pause_menu.visible = false
	phase = previous_phase
	if phase in [GamePhase.GREY_VOID, GamePhase.CITY]:
		player.set_look_locked(false)
		player.set_locked(false)
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	else:
		player.set_locked(true)
		player.set_look_locked(true)
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)

func _reset_level_state() -> void:
	manifest_started = false
	can_read_tower = false
	_reset_city_guidance_timer()
	_reset_desire_relics()
	_reset_sign_fracture_nodes()
	_reset_thin_ascent_nodes()
	_reset_trade_exchange_nodes()
	_reset_eye_observation_nodes()
	_reset_name_seal_nodes()
	_reset_dead_echo_nodes()
	_reset_sky_anchor_nodes()
	_reset_continuous_sprawl_nodes()
	_reset_hidden_reveal_nodes()
	manifested_city.visible = false
	_set_city_collision_enabled(false)
	grey_visual_root.visible = true
	grey_silhouettes.visible = false
	if grey_zone_debug_root != null:
		grey_zone_debug_root.visible = show_grey_zone_debug
	if grey_chaos_root != null:
		grey_chaos_root.visible = chaos_shader_enabled
	grey_particles.amount = grey_mote_particle_amount
	grey_particles.emitting = true
	if grey_sand_particles != null:
		grey_sand_particles.amount = grey_sand_particle_amount
		grey_sand_particles.emitting = true
	if grey_current_particles != null:
		grey_current_particles.amount = grey_current_particle_amount
		grey_current_particles.emitting = true
	if grey_willow_particles != null:
		grey_willow_particles.amount = grey_willow_particle_amount
		grey_willow_particles.emitting = true
	if grey_storm_particles != null:
		grey_storm_particles.amount = grey_storm_particle_amount
		grey_storm_particles.emitting = true
	if grey_turbulence_particles != null:
		grey_turbulence_particles.amount = grey_turbulence_particle_amount
		grey_turbulence_particles.emitting = true
	_reset_extra_grey_environment()
	_hide_memory_guide()
	environment.fog_enabled = true
	environment.fog_density = 0.12
	environment.adjustment_saturation = 0.16
	environment.adjustment_contrast = 0.52
	world_reverb.wet = reverb_wet_max
	world_reverb.room_size = reverb_room_size_max
	player.set_footstep_set("grey")
	direction_tint.color.a = 0.0
	_hide_grey_guidance()
	if global_music_tween != null:
		global_music_tween.kill()
	global_music_player.stop()
	global_music_player.volume_db = intro_bgm_volume_db
	_stop_grey_sfx()
	_reset_grey_sfx_timers()

func _update_memory_audio() -> void:
	var theme_pos := _selected_theme_position()
	var distance: float = player.global_position.distance_to(theme_pos)
	var closeness: float = clamp(1.0 - distance / max(theme_sfx_hearing_distance, 1.0), 0.0, 1.0)
	memory_lowpass.cutoff_hz = lerp(520.0, 7400.0, closeness)
	if theme_sfx_player != null:
		theme_sfx_player.position = theme_pos
		theme_sfx_player.volume_db = lerp(theme_sfx_volume_far_db, theme_sfx_volume_near_db, closeness)

func _update_grey_audio_sfx(delta: float) -> void:
	_update_theme_seeking_sfx(delta)
	_update_zone_random_sfx(delta)

func _update_theme_seeking_sfx(delta: float) -> void:
	theme_sfx_timer -= delta
	if theme_sfx_timer > 0.0:
		return
	var sfx_index := _random_sfx_index(selected_theme_index)
	_play_theme_sfx(sfx_index)
	theme_sfx_timer = rng.randf_range(theme_sfx_min_interval, theme_sfx_max_interval)

func _update_zone_random_sfx(delta: float) -> void:
	_ensure_zone_sfx_timers()
	var zone_index := _nearest_zone_index(player.global_position)
	if zone_index == selected_theme_index:
		return
	if zone_index < 0 or zone_index >= zone_audio_players.size():
		return
	zone_sfx_timers[zone_index] -= delta
	if zone_sfx_timers[zone_index] <= 0.0:
		_play_zone_sfx(zone_index)
		zone_sfx_timers[zone_index] = rng.randf_range(zone_sfx_min_interval, zone_sfx_max_interval)

func _play_theme_sfx(sfx_index: int) -> void:
	if theme_sfx_player == null:
		return
	var paths := _sfx_paths_for_theme(selected_theme_index)
	var stream := _audio_stream_or_generator([paths[sfx_index]])
	theme_sfx_player.stream = stream
	_set_generated_frequency(theme_sfx_player, _generated_theme_sfx_frequency(selected_theme_index, sfx_index))
	theme_sfx_player.play()
	_mark_generated_sfx_stop(theme_sfx_player, theme_sfx_generated_duration)
	if _should_show_theme_sfx_text():
		_show_theme_sfx_text(selected_theme_index, sfx_index)

func _play_zone_sfx(zone_index: int) -> void:
	if zone_index < 0 or zone_index >= zone_audio_players.size():
		return
	var paths := _sfx_paths_for_theme(zone_index)
	var sfx_index := rng.randi_range(0, paths.size() - 1)
	var player_node := zone_audio_players[zone_index]
	player_node.stream = _audio_stream_or_generator([paths[sfx_index]])
	player_node.volume_db = zone_sfx_volume_db
	_set_generated_frequency(player_node, _generated_theme_sfx_frequency(zone_index, sfx_index))
	player_node.play()
	_mark_generated_sfx_stop(player_node, zone_sfx_generated_duration)

func _sfx_paths_for_theme(theme_index: int) -> Array:
	var index := clampi(theme_index, 0, THEME_SFX_AUDIO_PATHS.size() - 1)
	return THEME_SFX_AUDIO_PATHS[index]

func _random_sfx_index(theme_index: int) -> int:
	var paths := _sfx_paths_for_theme(theme_index)
	return rng.randi_range(0, paths.size() - 1)

func _generated_theme_sfx_frequency(theme_index: int, sfx_index: int) -> float:
	return 170.0 + float(theme_index) * 31.0 + float(sfx_index) * 43.0

func _selected_theme_position() -> Vector3:
	var index := clampi(selected_theme_index, 0, ZONE_POSITIONS.size() - 1)
	return ZONE_POSITIONS[index]

func _should_show_theme_sfx_text() -> bool:
	if quick_start_hint_locked:
		return false
	var distance: float = player.global_position.distance_to(_selected_theme_position())
	return distance <= theme_sfx_text_trigger_distance or _is_inside_zone(selected_theme_index, player.global_position)

func _show_theme_sfx_text(theme_index: int, sfx_index: int) -> void:
	if quick_hint_label == null:
		return
	var texts: Array = THEME_SFX_TEXTS[clampi(theme_index, 0, THEME_SFX_TEXTS.size() - 1)]
	if texts.is_empty():
		return
	var text := String(texts[clampi(sfx_index, 0, texts.size() - 1)])
	if theme_sfx_text_tween != null:
		theme_sfx_text_tween.kill()
	quick_hint_label.text = text
	quick_hint_label.visible = true
	quick_hint_label.modulate.a = 0.0
	theme_sfx_text_tween = create_tween()
	theme_sfx_text_tween.tween_property(quick_hint_label, "modulate:a", quick_start_hint_alpha, theme_sfx_text_fade_in_duration)
	theme_sfx_text_tween.tween_interval(theme_sfx_text_hold_duration)
	theme_sfx_text_tween.tween_property(quick_hint_label, "modulate:a", 0.0, theme_sfx_text_fade_out_duration)
	theme_sfx_text_tween.tween_callback(func(): quick_hint_label.visible = false)

func _play_intro_bgm() -> void:
	if global_music_player == null:
		return
	if global_music_tween != null:
		global_music_tween.kill()
	global_music_player.volume_db = intro_bgm_volume_db
	if not global_music_player.playing:
		global_music_player.play()

func _stop_intro_bgm_for_grey() -> void:
	if global_music_player == null or not global_music_player.playing:
		return
	if global_music_tween != null:
		global_music_tween.kill()
	global_music_tween = create_tween()
	global_music_tween.tween_property(global_music_player, "volume_db", -42.0, grey_bgm_fade_out_duration)
	global_music_tween.tween_callback(func(): global_music_player.stop())

func _play_city_bgm() -> void:
	if global_music_player == null:
		return
	if global_music_tween != null:
		global_music_tween.kill()
	global_music_player.volume_db = -42.0
	if not global_music_player.playing:
		global_music_player.play()
	global_music_tween = create_tween()
	global_music_tween.tween_property(global_music_player, "volume_db", city_bgm_volume_db, city_bgm_fade_in_duration)

func _ensure_zone_sfx_timers() -> void:
	while zone_sfx_timers.size() < zone_audio_players.size():
		zone_sfx_timers.append(rng.randf_range(zone_sfx_min_interval, zone_sfx_max_interval))

func _reset_grey_sfx_timers() -> void:
	theme_sfx_timer = rng.randf_range(0.35, 1.35)
	zone_sfx_timers.clear()
	for i in range(zone_audio_players.size()):
		zone_sfx_timers.append(rng.randf_range(0.4, zone_sfx_max_interval))

func _stop_grey_sfx() -> void:
	if theme_sfx_player != null:
		theme_sfx_player.stop()
		theme_sfx_player.set_meta("generated_sfx_time_left", -1.0)
	for p in zone_audio_players:
		p.stop()
		p.set_meta("generated_sfx_time_left", -1.0)

func _mark_generated_sfx_stop(player_node: Node, duration: float) -> void:
	if player_node.get("stream") is AudioStreamGenerator:
		player_node.set_meta("generated_sfx_time_left", duration)
	else:
		player_node.set_meta("generated_sfx_time_left", -1.0)

func _update_generated_sfx_stops(delta: float) -> void:
	for player_node in generated_audio_players:
		var time_left := float(player_node.get_meta("generated_sfx_time_left", -1.0))
		if time_left < 0.0:
			continue
		time_left -= delta
		if time_left <= 0.0:
			if player_node.has_method("stop"):
				player_node.call("stop")
			player_node.set_meta("generated_sfx_time_left", -1.0)
		else:
			player_node.set_meta("generated_sfx_time_left", time_left)

func _update_dynamic_reverb(delta: float) -> void:
	var distance: float = player.global_position.distance_to(_selected_theme_position())
	var closeness: float = clamp(1.0 - distance / 70.0, 0.0, 1.0)
	var target_wet: float = lerp(reverb_wet_max, reverb_wet_min, closeness)
	var target_room_size: float = lerp(reverb_room_size_max, reverb_room_size_min, closeness)
	var weight: float = 1.0 - exp(-reverb_transition_speed * delta)
	world_reverb.wet = lerp(world_reverb.wet, target_wet, weight)
	world_reverb.room_size = lerp(world_reverb.room_size, target_room_size, weight)

func _update_city_reverb(delta: float) -> void:
	var weight: float = 1.0 - exp(-reverb_transition_speed * delta)
	world_reverb.wet = lerp(world_reverb.wet, city_reverb_wet, weight)
	world_reverb.room_size = lerp(world_reverb.room_size, city_reverb_room_size, weight)

func _reset_city_guidance_timer() -> void:
	city_guidance_timer = 0.0
	city_guidance_has_shown = false

func _update_city_guidance(delta: float) -> void:
	if not is_instance_valid(player) or phase != GamePhase.CITY:
		return
	if can_read_tower or _is_player_near_reading_trigger():
		_reset_city_guidance_timer()
		return
	city_guidance_timer += delta
	var target_delay := city_guidance_repeat_delay if city_guidance_has_shown else city_guidance_delay
	if city_guidance_timer >= maxf(target_delay, 1.0):
		_show_hint(_city_guidance_text(), 5.0)
		city_guidance_timer = 0.0
		city_guidance_has_shown = true

func _city_guidance_text() -> String:
	match selected_theme_index:
		THEME_DESIRE:
			if _is_desire_collection_complete():
				return "欲望物已经集齐。去月光迷宫最深处，寻找白色陷阱广场。"
			return "寻找带彩色辉光的欲望物。靠近后按 E 拾取。"
		THEME_SIGNS:
			if _is_sign_fracture_complete():
				return "五处符号断点已沉默。回到中心无名广场。"
			return "寻找发光的符号断点。靠近后按 E 读取。"
		THEME_THIN:
			if _is_thin_ascent_complete():
				return "五个悬空节点已绷紧。回到中心网心瞭望台。"
			return "寻找轻盈城中的悬空发光节点。靠近后按 E 读取。"
		THEME_TRADE:
			if _is_trade_exchange_complete():
				return "五次交换已经完成。回到中心交易核。"
			return "寻找发光的交换节点。靠近后按 E 完成交换。"
		THEME_EYES:
			if _is_eye_observation_complete():
				return "五处观察点已经校准。回到中心观景核。"
			return "寻找冷白辉光的观察点。靠近后按 E 校准视线。"
		THEME_NAMES_CITY:
			if _is_name_seal_complete():
				return "五处命名封印已经松动。回到中心消逝名字碑。"
			return "寻找发光铭牌或石碑。靠近后按 E 解名。"
		THEME_DEAD:
			if _is_dead_echo_complete():
				return "五处亡者回声已经归位。前往北侧沙漏塔。"
			return "寻找冷蓝烛火或骨白回声标记。靠近后按 E 安放。"
		THEME_SKY:
			if _is_sky_anchor_complete():
				return "五处天体锚点已经校准。前往北侧星空观测塔。"
			return "寻找蓝白星尘和天体锚点。靠近后按 E 校准。"
		THEME_CONTINUOUS:
			if _is_continuous_sprawl_complete():
				return "五处连续压力已经记录。回到中心无中心指示牌。"
			return "寻找灰黄辉光的连续节点。靠近后按 E 记录扩张压力。"
		THEME_HIDDEN:
			if _is_hidden_reveal_complete():
				return "五处隐蔽节点已经显形。回到中心隐蔽裂光。"
			return "寻找暗绿微光与裂缝。靠近后按 E 发现隐藏城市。"
		_:
			return "寻找城市最高处的回声塔。到塔底后按 E 阅读。"

func _city_entry_objective_text() -> String:
	match selected_theme_index:
		THEME_DESIRE:
			return "寻找 5 件带彩色辉光的欲望物，全部拾取后进入月光迷宫最深处阅读。"
		THEME_SIGNS:
			return "读取 5 处发光符号断点，然后回到中心无名广场阅读。"
		THEME_THIN:
			return "读取 5 个悬空节点，然后回到网心瞭望台阅读。"
		THEME_TRADE:
			return "完成 5 次交换节点，然后回到中心交易核阅读。"
		THEME_EYES:
			return "校准 5 处冷白观察点，然后回到中心观景核阅读。"
		THEME_NAMES_CITY:
			return "解开 5 处命名封印，然后回到消逝名字碑阅读。"
		THEME_DEAD:
			return "安放 5 处亡者回声，然后前往北侧沙漏塔阅读。"
		THEME_SKY:
			return "校准 5 处天体锚点，然后前往北侧星空观测塔阅读。"
		THEME_CONTINUOUS:
			return "记录 5 处连续节点，然后回到中心无中心指示牌阅读。"
		THEME_HIDDEN:
			return "发现 5 处隐蔽节点，然后回到中心隐蔽裂光阅读。"
		_:
			return "寻找最高处的回声塔，到塔底后按 E 阅读。"

func _set_grey_post_process_visible(visible: bool) -> void:
	if grey_post_process_rect != null:
		grey_post_process_rect.visible = visible and grey_post_process_enabled

func _update_city_post_process() -> void:
	if grey_post_process_material == null or grey_post_process_rect == null:
		return
	grey_post_process_rect.visible = city_post_process_enabled
	if not city_post_process_enabled:
		return
	var zone_index := clampi(selected_theme_index, 0, ZONE_COLORS.size() - 1)
	var theme_color: Color = ZONE_COLORS[zone_index]
	var desire_heat := 1.0 if selected_theme_index == THEME_DESIRE else 0.0
	var signs_flatten := 1.0 if selected_theme_index == THEME_SIGNS else 0.0
	var thin_air := 1.0 if selected_theme_index == THEME_THIN else 0.0
	var trade_wet := 1.0 if selected_theme_index == THEME_TRADE else 0.0
	var eye_reflect := 1.0 if selected_theme_index == THEME_EYES else 0.0
	var name_carve := 1.0 if selected_theme_index == THEME_NAMES_CITY else 0.0
	var dead_cold := 1.0 if selected_theme_index == THEME_DEAD else 0.0
	var sky_cosmic := 1.0 if selected_theme_index == THEME_SKY else 0.0
	var continuous_dirty := 1.0 if selected_theme_index == THEME_CONTINUOUS else 0.0
	var hidden_growth := 1.0 if selected_theme_index == THEME_HIDDEN else 0.0
	var residual := clampf(city_residual_grey_chaos_strength, 0.0, 1.0)
	grey_post_process_material.set_shader_parameter("effect_strength", city_post_effect_strength)
	grey_post_process_material.set_shader_parameter("grain_strength", city_residual_grey_grain_strength * residual + 0.025 * signs_flatten + 0.015 * thin_air + 0.015 * trade_wet + 0.012 * eye_reflect + 0.018 * name_carve + 0.020 * dead_cold + 0.012 * sky_cosmic + 0.030 * continuous_dirty + 0.016 * hidden_growth)
	grey_post_process_material.set_shader_parameter("halftone_strength", minf(city_residual_halftone_strength * residual + 0.02 * signs_flatten + 0.01 * name_carve, 0.08))
	grey_post_process_material.set_shader_parameter("pixel_strength", 0.0)
	grey_post_process_material.set_shader_parameter("posterize_strength", 0.10 + 0.04 * signs_flatten - 0.03 * thin_air + 0.02 * trade_wet - 0.015 * eye_reflect + 0.025 * name_carve + 0.015 * dead_cold - 0.010 * sky_cosmic + 0.035 * continuous_dirty - 0.010 * hidden_growth)
	grey_post_process_material.set_shader_parameter("flatten_strength", 0.10 + 0.12 * signs_flatten - 0.02 * thin_air - 0.01 * eye_reflect + 0.035 * name_carve + 0.025 * dead_cold - 0.015 * sky_cosmic + 0.045 * continuous_dirty - 0.010 * hidden_growth)
	grey_post_process_material.set_shader_parameter("scanline_strength", 0.0)
	grey_post_process_material.set_shader_parameter("chromatic_strength", 0.00025 + 0.00020 * residual + 0.00050 * desire_heat + 0.00018 * thin_air + 0.00032 * trade_wet + 0.00036 * eye_reflect + 0.00016 * name_carve + 0.00022 * dead_cold + 0.00024 * sky_cosmic + 0.00010 * continuous_dirty + 0.00022 * hidden_growth)
	grey_post_process_material.set_shader_parameter("wave_strength", city_residual_wave_strength * residual + 0.0008 * desire_heat + 0.00045 * thin_air + 0.0007 * trade_wet + 0.00075 * eye_reflect + 0.00032 * name_carve + 0.00042 * dead_cold + 0.00048 * sky_cosmic + 0.00030 * continuous_dirty + 0.00055 * hidden_growth)
	grey_post_process_material.set_shader_parameter("edge_strength", 0.04 + 0.03 * signs_flatten + 0.03 * thin_air + 0.025 * eye_reflect + 0.030 * name_carve + 0.020 * dead_cold + 0.020 * sky_cosmic + 0.018 * continuous_dirty + 0.020 * hidden_growth)
	grey_post_process_material.set_shader_parameter("contour_strength", 0.015 + 0.035 * signs_flatten + 0.025 * thin_air + 0.02 * trade_wet + 0.025 * eye_reflect + 0.030 * name_carve + 0.025 * dead_cold + 0.030 * sky_cosmic + 0.020 * continuous_dirty + 0.018 * hidden_growth)
	grey_post_process_material.set_shader_parameter("solarize_strength", 0.0)
	grey_post_process_material.set_shader_parameter("inversion_flicker_strength", 0.0)
	grey_post_process_material.set_shader_parameter("vignette_strength", 0.10 - 0.03 * thin_air + 0.02 * eye_reflect + 0.02 * name_carve + 0.050 * dead_cold - 0.020 * sky_cosmic + 0.025 * continuous_dirty + 0.040 * hidden_growth)
	grey_post_process_material.set_shader_parameter("zone_tint_strength", 0.05 + 0.04 * desire_heat + 0.08 * thin_air + 0.07 * trade_wet + 0.06 * eye_reflect + 0.05 * name_carve + 0.060 * dead_cold + 0.070 * sky_cosmic + 0.055 * continuous_dirty + 0.065 * hidden_growth)
	grey_post_process_material.set_shader_parameter("zone_tint", Vector3(theme_color.r, theme_color.g, theme_color.b))
	grey_post_process_material.set_shader_parameter("ink_outline_strength", city_post_ink_outline_strength)
	grey_post_process_material.set_shader_parameter("ink_outline_width", 1.15)
	grey_post_process_material.set_shader_parameter("stylized_shadow_strength", city_post_stylized_shadow_strength - 0.06 * thin_air + 0.040 * dead_cold - 0.030 * sky_cosmic + 0.035 * continuous_dirty + 0.020 * hidden_growth)
	grey_post_process_material.set_shader_parameter("color_variation_strength", city_post_color_variation_strength + 0.025 * residual + 0.03 * thin_air + 0.06 * trade_wet + 0.04 * eye_reflect + 0.035 * name_carve + 0.030 * dead_cold + 0.050 * sky_cosmic + 0.045 * continuous_dirty + 0.040 * hidden_growth)
	grey_post_process_material.set_shader_parameter("soft_glow_strength", city_post_soft_glow_strength + 0.02 * residual + 0.04 * desire_heat + 0.06 * thin_air + 0.07 * trade_wet + 0.08 * eye_reflect + 0.04 * name_carve + 0.035 * dead_cold + 0.090 * sky_cosmic + 0.010 * continuous_dirty + 0.070 * hidden_growth)
	var ink_color := Vector3(0.035, 0.034, 0.030).lerp(Vector3(0.06, 0.08, 0.10), thin_air)
	ink_color = ink_color.lerp(Vector3(0.04, 0.055, 0.045), trade_wet)
	ink_color = ink_color.lerp(Vector3(0.035, 0.070, 0.095), eye_reflect)
	ink_color = ink_color.lerp(Vector3(0.08, 0.07, 0.055), name_carve)
	ink_color = ink_color.lerp(Vector3(0.025, 0.040, 0.090), sky_cosmic)
	ink_color = ink_color.lerp(Vector3(0.070, 0.065, 0.045), continuous_dirty)
	ink_color = ink_color.lerp(Vector3(0.025, 0.060, 0.040), hidden_growth)
	grey_post_process_material.set_shader_parameter("ink_color", ink_color.lerp(Vector3(0.030, 0.040, 0.060), dead_cold))
	var shadow_color := Vector3(0.13, 0.12, 0.10).lerp(Vector3(0.18, 0.08, 0.045), desire_heat)
	shadow_color = shadow_color.lerp(Vector3(0.10, 0.13, 0.16), thin_air)
	shadow_color = shadow_color.lerp(Vector3(0.10, 0.16, 0.13), trade_wet)
	shadow_color = shadow_color.lerp(Vector3(0.08, 0.15, 0.19), eye_reflect)
	shadow_color = shadow_color.lerp(Vector3(0.18, 0.15, 0.10), name_carve)
	shadow_color = shadow_color.lerp(Vector3(0.045, 0.055, 0.14), sky_cosmic)
	shadow_color = shadow_color.lerp(Vector3(0.18, 0.16, 0.09), continuous_dirty)
	shadow_color = shadow_color.lerp(Vector3(0.020, 0.095, 0.050), hidden_growth)
	grey_post_process_material.set_shader_parameter("shadow_color", shadow_color.lerp(Vector3(0.055, 0.070, 0.10), dead_cold))

func _update_grey_post_process() -> void:
	if grey_post_process_material == null:
		return
	_set_grey_post_process_visible(true)
	var zone_index := _nearest_zone_index(player.global_position)
	var closeness: float = _zone_closeness(zone_index, player.global_position)
	var style := _zone_visual_style(zone_index)
	var phase_strength := grey_post_effect_strength
	if phase == GamePhase.MANIFESTING:
		phase_strength *= max(environment.fog_density / max(fog_start_value, 0.001), 0.0)

	grey_post_process_material.set_shader_parameter("effect_strength", phase_strength)
	grey_post_process_material.set_shader_parameter("grain_strength", grey_post_grain_strength * style.x)
	grey_post_process_material.set_shader_parameter("halftone_strength", grey_post_halftone_strength * style.y)
	grey_post_process_material.set_shader_parameter("pixel_strength", grey_post_pixel_strength * style.z)
	grey_post_process_material.set_shader_parameter("posterize_strength", 0.06 + 0.10 * style.w)
	grey_post_process_material.set_shader_parameter("flatten_strength", grey_post_flatten_strength + 0.08 * style.w)
	grey_post_process_material.set_shader_parameter("scanline_strength", 0.0)
	grey_post_process_material.set_shader_parameter("chromatic_strength", 0.0008 + 0.0014 * style.x)
	grey_post_process_material.set_shader_parameter("wave_strength", 0.0015 + 0.0035 * (1.0 - closeness))
	grey_post_process_material.set_shader_parameter("edge_strength", grey_post_edge_strength * style.y)
	grey_post_process_material.set_shader_parameter("contour_strength", grey_post_contour_strength * style.w)
	grey_post_process_material.set_shader_parameter("solarize_strength", grey_post_solarize_strength * style.z)
	grey_post_process_material.set_shader_parameter("inversion_flicker_strength", 0.0)
	grey_post_process_material.set_shader_parameter("vignette_strength", 0.12 + 0.10 * style.y)
	grey_post_process_material.set_shader_parameter("zone_tint_strength", 0.08 + 0.14 * closeness)
	grey_post_process_material.set_shader_parameter("zone_tint", Vector3(ZONE_COLORS[zone_index].r, ZONE_COLORS[zone_index].g, ZONE_COLORS[zone_index].b))
	grey_post_process_material.set_shader_parameter("ink_outline_strength", grey_post_ink_outline_strength * (0.78 + 0.30 * style.y))
	grey_post_process_material.set_shader_parameter("ink_outline_width", 1.0 + style.w * 0.75)
	grey_post_process_material.set_shader_parameter("stylized_shadow_strength", grey_post_stylized_shadow_strength * (0.75 + 0.40 * closeness))
	grey_post_process_material.set_shader_parameter("color_variation_strength", grey_post_color_variation_strength * (0.80 + 0.35 * style.x))
	grey_post_process_material.set_shader_parameter("soft_glow_strength", grey_post_soft_glow_strength)
	grey_post_process_material.set_shader_parameter("ink_color", Vector3(0.025, 0.027, 0.024))
	grey_post_process_material.set_shader_parameter("shadow_color", Vector3(0.075, 0.078, 0.072))

func _update_memory_guide() -> void:
	if not memory_guide_enabled or memory_guide_particles == null or memory_guide_light == null:
		return
	var distance: float = player.global_position.distance_to(_selected_theme_position())
	var denom: float = max(memory_guide_start_distance - memory_guide_full_distance, 0.01)
	var strength: float = clamp((memory_guide_start_distance - distance) / denom, 0.0, 1.0)
	memory_guide_particles.emitting = strength > 0.02
	var process := memory_guide_particles.process_material as ParticleProcessMaterial
	if process != null:
		process.color = Color(1.0, 0.84, 0.18, 0.08 + strength * 0.58)
	memory_guide_light.light_energy = memory_guide_light_energy * strength

func _hide_memory_guide() -> void:
	if memory_guide_particles != null:
		memory_guide_particles.emitting = false
	if memory_guide_light != null:
		memory_guide_light.light_energy = 0.0

func _set_extra_grey_environment_active(active: bool) -> void:
	if grey_environment_root != null:
		grey_environment_root.visible = active
	for particles in grey_extra_particles:
		if particles != null:
			particles.emitting = active

func _reset_extra_grey_environment() -> void:
	if grey_environment_root != null:
		grey_environment_root.visible = true
	for particles in grey_extra_particles:
		if particles == null:
			continue
		particles.amount = int(particles.get_meta("base_amount", particles.amount))
		particles.emitting = true

func _fade_extra_grey_particles(tween: Tween) -> void:
	for particles in grey_extra_particles:
		if particles != null:
			tween.tween_property(particles, "amount", MIN_GPU_PARTICLE_AMOUNT, max(particle_fade_end - particle_fade_start, 0.1)).set_delay(particle_fade_start).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_IN)

func _nearest_zone_index(pos: Vector3) -> int:
	var best_index := 0
	var best_score := INF
	for i in range(ZONE_POSITIONS.size()):
		var size: Vector2 = ZONE_SHAPES[i]
		var local: Vector3 = (pos - ZONE_POSITIONS[i]).rotated(Vector3.UP, -deg_to_rad(ZONE_ROTATIONS[i]))
		var nx: float = abs(local.x) / max(size.x * 0.5, 0.01)
		var nz: float = abs(local.z) / max(size.y * 0.5, 0.01)
		var score: float = max(nx, nz)
		if score < best_score:
			best_score = score
			best_index = i
	return best_index

func _zone_closeness(zone_index: int, pos: Vector3) -> float:
	var size: Vector2 = ZONE_SHAPES[zone_index]
	var local: Vector3 = (pos - ZONE_POSITIONS[zone_index]).rotated(Vector3.UP, -deg_to_rad(ZONE_ROTATIONS[zone_index]))
	var nx: float = abs(local.x) / max(size.x * 0.5, 0.01)
	var nz: float = abs(local.z) / max(size.y * 0.5, 0.01)
	return clamp(1.0 - max(nx, nz), 0.0, 1.0)

func _is_inside_zone(zone_index: int, pos: Vector3, padding: float = 0.0) -> bool:
	if zone_index < 0 or zone_index >= ZONE_POSITIONS.size():
		return false
	var size: Vector2 = ZONE_SHAPES[zone_index]
	var local: Vector3 = (pos - ZONE_POSITIONS[zone_index]).rotated(Vector3.UP, -deg_to_rad(ZONE_ROTATIONS[zone_index]))
	return abs(local.x) <= size.x * 0.5 + padding and abs(local.z) <= size.y * 0.5 + padding

func _zone_visual_style(zone_index: int) -> Vector4:
	match zone_index:
		0:
			return Vector4(0.80, 1.00, 0.35, 0.85)
		1:
			return Vector4(1.00, 0.35, 0.30, 0.45)
		2:
			return Vector4(0.45, 0.90, 0.55, 0.80)
		3:
			return Vector4(0.25, 0.55, 0.35, 1.00)
		4:
			return Vector4(0.55, 0.42, 0.95, 0.35)
		5:
			return Vector4(0.40, 0.65, 0.25, 0.70)
		6:
			return Vector4(0.70, 0.80, 0.45, 0.55)
		7:
			return Vector4(0.95, 0.35, 0.25, 0.90)
		8:
			return Vector4(0.32, 0.55, 0.85, 0.40)
		9:
			return Vector4(0.60, 0.70, 1.00, 0.65)
		_:
			return Vector4(0.95, 0.95, 0.65, 0.95)

func _update_direction_feedback() -> void:
	var theme_pos := _selected_theme_position()
	var to_memory: Vector3 = (theme_pos - player.global_position).normalized()
	var forward: Vector3 = -player.global_transform.basis.z.normalized()
	var facing: float = clamp((forward.dot(to_memory) + 1.0) * 0.5, 0.0, 1.0)
	var distance: float = player.global_position.distance_to(theme_pos)
	var near: float = clamp(1.0 - distance / 75.0, 0.0, 1.0)
	direction_tint.color.a = lerp(direction_tint.color.a, facing * near * 0.14, 0.08)
	var process_material := grey_particles.process_material as ParticleProcessMaterial
	process_material.initial_velocity_min = lerp(0.15, 0.55, facing)
	process_material.initial_velocity_max = lerp(0.5, 1.6, facing)

func _show_hint(text: String, seconds: float) -> void:
	hint_cache = text
	hint_label.text = text
	if hint_tween != null:
		hint_tween.kill()
	hint_label.modulate.a = 0.0
	hint_tween = create_tween()
	hint_tween.tween_property(hint_label, "modulate:a", 1.0, ui_fade_in_duration)
	hint_tween.tween_interval(max(seconds, ui_hold_duration))
	hint_tween.tween_property(hint_label, "modulate:a", 0.0, ui_fade_out_duration)

func _show_panel_fade(panel: Control, duration: float) -> void:
	panel.visible = true
	panel.modulate.a = 0.0
	var tween := create_tween()
	tween.tween_property(panel, "modulate:a", 1.0, duration)

func _show_operation_hint() -> void:
	if operation_hint_panel == null:
		return
	if operation_hint_tween != null:
		operation_hint_tween.kill()
	operation_hint_panel.visible = true
	operation_hint_panel.modulate.a = 0.0
	operation_hint_tween = create_tween()
	operation_hint_tween.tween_property(operation_hint_panel, "modulate:a", 1.0, ui_fade_in_duration)
	operation_hint_tween.tween_interval(operation_hint_display_duration)
	operation_hint_tween.tween_property(operation_hint_panel, "modulate:a", 0.0, ui_fade_out_duration)
	operation_hint_tween.tween_callback(func(): operation_hint_panel.visible = false)

func _hide_operation_hint() -> void:
	if operation_hint_tween != null:
		operation_hint_tween.kill()
	if operation_hint_panel != null:
		operation_hint_panel.visible = false
		operation_hint_panel.modulate.a = 0.0

func _show_quick_start_hint() -> void:
	if quick_hint_label == null:
		return
	if quick_hint_tween != null:
		quick_hint_tween.kill()
	if theme_sfx_text_tween != null:
		theme_sfx_text_tween.kill()
	quick_start_hint_locked = true
	quick_hint_label.text = "听声找城 | WASD 移动 | Space 跳跃 | Shift 轻跑 | 按住左键看向 | E 交互 | Esc 暂停"
	quick_hint_label.visible = true
	quick_hint_label.modulate.a = 0.0
	var total: float = maxf(quick_start_hint_duration, 0.1)
	var fade_in: float = minf(0.55, total * 0.25)
	var fade_out: float = minf(1.45, total * 0.35)
	var hold: float = maxf(total - fade_in - fade_out, 0.0)
	quick_hint_tween = create_tween()
	quick_hint_tween.tween_property(quick_hint_label, "modulate:a", quick_start_hint_alpha, fade_in)
	quick_hint_tween.tween_interval(hold)
	quick_hint_tween.tween_property(quick_hint_label, "modulate:a", 0.0, fade_out)
	quick_hint_tween.tween_callback(func():
		quick_hint_label.visible = false
		quick_start_hint_locked = false
	)

func _hide_quick_start_hint() -> void:
	if quick_hint_tween != null:
		quick_hint_tween.kill()
	if theme_sfx_text_tween != null:
		theme_sfx_text_tween.kill()
	quick_start_hint_locked = false
	if quick_hint_label != null:
		quick_hint_label.visible = false
		quick_hint_label.modulate.a = 0.0

func _reset_grey_guidance() -> void:
	grey_search_elapsed = 0.0
	if grey_countdown_label != null:
		grey_countdown_label.visible = true
		grey_countdown_label.modulate.a = 1.0
	if grey_guidance_root != null:
		grey_guidance_root.visible = false
	for line in grey_guidance_lines:
		if line != null:
			line.color.a = 0.0

func _hide_grey_guidance() -> void:
	if grey_countdown_label != null:
		grey_countdown_label.visible = false
	if grey_guidance_root != null:
		grey_guidance_root.visible = false

func _update_grey_guidance(delta: float) -> void:
	grey_search_elapsed += delta
	var remaining := maxf(grey_guidance_delay - grey_search_elapsed, 0.0)
	if grey_countdown_label != null:
		var seconds := int(ceil(remaining))
		grey_countdown_label.visible = true
		grey_countdown_label.text = "寻声 %02d:%02d" % [seconds / 60, seconds % 60]
		grey_countdown_label.modulate.a = 0.82 if remaining > 0.0 else 0.48
	if grey_guidance_root == null:
		return
	if grey_search_elapsed < grey_guidance_delay:
		grey_guidance_root.visible = false
		return
	grey_guidance_root.visible = true
	var fade: float = clamp((grey_search_elapsed - grey_guidance_delay) / maxf(grey_guidance_fade_in_duration, 0.1), 0.0, 1.0)
	var to_target: Vector3 = _selected_theme_position() - player.global_position
	to_target.y = 0.0
	if to_target.length_squared() < 0.001:
		to_target = -player.global_transform.basis.z
	var target_dir: Vector3 = to_target.normalized()
	var forward: Vector3 = -player.global_transform.basis.z
	forward.y = 0.0
	forward = forward.normalized()
	var right: Vector3 = player.global_transform.basis.x
	right.y = 0.0
	right = right.normalized()
	var screen_dir: Vector2 = Vector2(right.dot(target_dir), -forward.dot(target_dir))
	if screen_dir.length_squared() < 0.001:
		screen_dir = Vector2(0.0, -1.0)
	screen_dir = screen_dir.normalized()
	var viewport_size: Vector2 = get_viewport().get_visible_rect().size
	var center: Vector2 = viewport_size * 0.5
	var drift: Vector2 = Vector2(-screen_dir.y, screen_dir.x)
	var time: float = float(Time.get_ticks_msec()) / 1000.0
	var base: Vector2 = center + screen_dir * minf(viewport_size.x, viewport_size.y) * 0.10
	for i in range(grey_guidance_lines.size()):
		var line := grey_guidance_lines[i]
		if line == null:
			continue
		var index := float(i)
		var pulse := 0.5 + 0.5 * sin(time * 2.1 + index * 0.76)
		var offset := screen_dir * (index - float(grey_guidance_lines.size() - 1) * 0.5) * grey_guidance_line_spacing
		var side := drift * sin(time * 0.9 + index * 1.3) * 10.0
		line.position = base + offset + side
		line.rotation = screen_dir.angle()
		line.size = Vector2(38.0 + float(i % 4) * 9.0, 1.4 + float(i % 2) * 0.7)
		line.pivot_offset = Vector2(0.0, line.size.y * 0.5)
		line.color = Color(0.88, 0.84, 0.64, grey_guidance_line_alpha * fade * (0.45 + pulse * 0.55))

func _toggle_grey_debug_visibility() -> void:
	show_grey_zone_debug = not show_grey_zone_debug
	if grey_zone_debug_root != null:
		grey_zone_debug_root.visible = show_grey_zone_debug
	_show_hint("调试区域：%s" % ("显示" if show_grey_zone_debug else "隐藏"), 1.5)

func _hide_all_ui() -> void:
	_hide_quick_start_hint()
	_hide_grey_guidance()
	for c in [main_menu, story_panel, options_panel, theme_select, mechanic_prompt, reading_panel, choice_panel, pause_menu]:
		if c != null:
			c.visible = false
			c.modulate.a = 1.0

func _set_city_collision_enabled(enabled: bool) -> void:
	for child in city_collision_root.get_children():
		if child is CollisionObject3D:
			var variant := int(child.get_meta("memory_city_variant", selected_memory_city_index))
			var active := enabled and variant == selected_memory_city_index
			child.collision_layer = 1 if active else 0
			child.collision_mask = 2 if active else 0

func _should_keep_clear_for_echo_tower(name: String, pos: Vector3, size: Vector3) -> bool:
	if active_memory_city_build_index != THEME_MEMORY:
		return false
	if not _is_inside_echo_tower_clear_zone(pos, size):
		return false
	if name.begins_with("EchoTower"):
		return false
	for allowed in ["Ground", "Street", "Avenue", "Plaza", "Road", "Marker", "Boundary"]:
		if name.contains(allowed):
			return false
	if size.y <= 0.9:
		return false
	return true

func _is_inside_echo_tower_clear_zone(pos: Vector3, size: Vector3) -> bool:
	var flat_distance := Vector2(pos.x, pos.z).length()
	var footprint_radius: float = maxf(size.x, size.z) * 0.5
	return flat_distance < echo_tower_clear_radius + footprint_radius

func _add_city_block(parent: Node3D, name: String, pos: Vector3, size: Vector3, yaw_degrees: float, color: Color) -> void:
	if _should_keep_clear_for_echo_tower(name, pos, size):
		return
	var box := CSGBox3D.new()
	box.name = name
	box.position = pos
	box.size = size
	box.rotation_degrees.y = yaw_degrees
	box.material = _mat(color, 1.0)
	parent.add_child(box)
	_add_box_collision(name + "Collision", pos, size, yaw_degrees)

func _add_city_tower(parent: Node3D, name: String, pos: Vector3, radius: float, height: float, color: Color, dome: bool) -> void:
	if active_memory_city_build_index == THEME_MEMORY and not name.begins_with("EchoTower") and _is_inside_echo_tower_clear_zone(pos, Vector3(radius * 2.0, height, radius * 2.0)):
		return
	var tower := CSGCylinder3D.new()
	tower.name = name
	tower.radius = radius
	tower.height = height
	tower.sides = 24
	tower.position = pos + Vector3(0, height * 0.5, 0)
	tower.material = _mat(color, 1.0)
	parent.add_child(tower)
	_add_box_collision(name + "Collision", tower.position, Vector3(radius * 2.0, height, radius * 2.0))
	if dome:
		var cap := CSGCylinder3D.new()
		cap.name = name + "_Dome"
		cap.radius = radius * 1.25
		cap.height = radius * 0.75
		cap.sides = 24
		cap.position = pos + Vector3(0, height + radius * 0.35, 0)
		cap.material = _mat(Color(0.72, 0.74, 0.72), 1.0)
		parent.add_child(cap)

func _add_spiral_marker(parent: Node3D, pos: Vector3, yaw_degrees: float) -> void:
	for step in range(5):
		_add_city_block(
			parent,
			"ShellSpiralStep_%02d" % step,
			pos + Vector3(cos(float(step) * 0.9) * 1.5, 0.35 + float(step) * 0.32, sin(float(step) * 0.9) * 1.5),
			Vector3(2.4, 0.35, 0.8),
			yaw_degrees + float(step) * 28.0,
			Color(0.66, 0.62, 0.55)
		)

func _build_old_men_wall(parent: Node3D) -> void:
	_add_city_block(parent, "OldMenWall", Vector3(-56, 1.1, 0), Vector3(2.0, 2.2, 46.0), 0.0, Color(0.45, 0.42, 0.38))
	for i in range(8):
		_add_city_block(parent, "WallSeat_%02d" % i, Vector3(-53.8, 0.45, -18 + i * 5.2), Vector3(2.8, 0.9, 2.2), 0.0, Color(0.38, 0.36, 0.34))

func _add_door_frame(parent: Node3D, pos: Vector3, yaw_degrees: float) -> void:
	if active_memory_city_build_index == THEME_MEMORY and _is_inside_echo_tower_clear_zone(pos, Vector3(4.0, 4.4, 1.0)):
		return
	var frame := Node3D.new()
	frame.name = "WhiteboxDoorFrame"
	frame.position = pos
	frame.rotation_degrees.y = yaw_degrees
	parent.add_child(frame)
	var parts: Array = [
		[Vector3(-1.6, 2.0, 0), Vector3(0.55, 4.0, 0.65)],
		[Vector3(1.6, 2.0, 0), Vector3(0.55, 4.0, 0.65)],
		[Vector3(0, 4.0, 0), Vector3(3.75, 0.55, 0.65)]
	]
	for i in range(parts.size()):
		var box := CSGBox3D.new()
		box.name = "DoorPart_%02d" % i
		box.position = parts[i][0]
		box.size = parts[i][1]
		box.material = _mat(Color(0.56, 0.55, 0.51), 1.0)
		frame.add_child(box)
		var collision_pos: Vector3 = pos + parts[i][0].rotated(Vector3.UP, deg_to_rad(yaw_degrees))
		_add_box_collision("DoorPartCollision", collision_pos, parts[i][1], yaw_degrees)

func _add_arch(parent: Node3D, pos: Vector3, yaw_degrees: float, index: int) -> void:
	var arch := Node3D.new()
	arch.name = "ContinuousArch_%02d" % index
	arch.position = pos
	arch.rotation_degrees.y = yaw_degrees
	parent.add_child(arch)
	for x in [-1.35, 1.35]:
		var pillar := CSGBox3D.new()
		pillar.size = Vector3(0.6, 3.3, 0.7)
		pillar.position = Vector3(x, 1.65, 0)
		pillar.material = _mat(Color(0.53, 0.52, 0.49), 1.0)
		arch.add_child(pillar)
		var pillar_pos := pos + pillar.position.rotated(Vector3.UP, deg_to_rad(yaw_degrees))
		_add_box_collision("ArchPillarCollision_%02d" % index, pillar_pos, pillar.size, yaw_degrees)
	var top := CSGCylinder3D.new()
	top.radius = 1.65
	top.height = 0.65
	top.sides = 24
	top.position = Vector3(0, 3.25, 0)
	top.rotation_degrees.x = 90
	top.material = _mat(Color(0.53, 0.52, 0.49), 1.0)
	arch.add_child(top)
	var top_pos := pos + top.position.rotated(Vector3.UP, deg_to_rad(yaw_degrees))
	_add_box_collision("ArchTopCollision_%02d" % index, top_pos, Vector3(3.8, 0.65, 0.8), yaw_degrees)

func _add_box_collision(name: String, pos: Vector3, size: Vector3, yaw_degrees := 0.0) -> void:
	var body := StaticBody3D.new()
	body.name = name
	body.position = pos
	body.rotation_degrees.y = yaw_degrees
	body.collision_layer = 0
	body.collision_mask = 0
	body.set_meta("memory_city_variant", active_memory_city_build_index)
	city_collision_root.add_child(body)
	var shape := CollisionShape3D.new()
	var box := BoxShape3D.new()
	box.size = size
	shape.shape = box
	body.add_child(shape)

func _button(text: String, callback: Callable) -> Button:
	var button := Button.new()
	button.text = text
	button.custom_minimum_size = Vector2(300, 44)
	button.pressed.connect(callback)
	return button

func _label(text: String, size: int) -> Label:
	var label := Label.new()
	label.text = text
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	label.add_theme_font_size_override("font_size", size)
	return label

func _center_panel(name: String) -> VBoxContainer:
	var panel := VBoxContainer.new()
	panel.name = name
	panel.set_anchors_preset(Control.PRESET_CENTER)
	panel.offset_left = -260
	panel.offset_right = 260
	panel.offset_top = -190
	panel.offset_bottom = 190
	panel.alignment = BoxContainer.ALIGNMENT_CENTER
	panel.add_theme_constant_override("separation", 14)
	return panel

func _mat(color: Color, alpha: float) -> StandardMaterial3D:
	var material := StandardMaterial3D.new()
	material.albedo_color = Color(color.r, color.g, color.b, alpha)
	material.roughness = 0.85
	if alpha < 1.0:
		material.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	return material

func _emissive_mat(color: Color, alpha: float, energy: float) -> StandardMaterial3D:
	var material := _mat(color, alpha)
	material.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	material.emission_enabled = true
	material.emission = Color(color.r, color.g, color.b)
	material.emission_energy_multiplier = energy
	material.no_depth_test = alpha < 0.45
	return material

func _thin_net_material(color: Color, alpha: float, seed: float, sway := 0.035, edge_strength := 0.78) -> Material:
	var shader := load("res://shaders/thin_net_surface.gdshader") as Shader
	if shader == null:
		return _mat(color, alpha)
	var material := ShaderMaterial.new()
	material.shader = shader
	material.set_shader_parameter("base_color", Color(color.r, color.g, color.b, alpha))
	material.set_shader_parameter("edge_color", Color(0.86, 0.94, 1.0, 0.92))
	material.set_shader_parameter("alpha", alpha)
	material.set_shader_parameter("edge_strength", edge_strength)
	material.set_shader_parameter("wire_density", 6.0 + fmod(abs(seed), 5.0))
	material.set_shader_parameter("sway_amount", sway)
	material.set_shader_parameter("sway_speed", 0.65 + fmod(abs(seed), 4.0) * 0.12)
	material.set_shader_parameter("seed", seed)
	return material

func _trade_wet_material(color: Color, alpha: float, seed: float, wetness := 0.58, neon_mix := 0.10, material_mix := 0.42) -> Material:
	var shader := load("res://shaders/trade_wet_market_surface.gdshader") as Shader
	if shader == null:
		return _mat(color, alpha)
	var material := ShaderMaterial.new()
	material.shader = shader
	material.set_shader_parameter("base_color", Color(color.r, color.g, color.b, alpha))
	material.set_shader_parameter("lantern_color", Color(1.0, 0.48, 0.16, 1.0))
	material.set_shader_parameter("neon_color", Color(0.08, 0.72, 0.62, 1.0))
	material.set_shader_parameter("alpha", alpha)
	material.set_shader_parameter("wetness", wetness)
	material.set_shader_parameter("lantern_glow", 0.16 + trade_city_style_intensity * 0.08)
	material.set_shader_parameter("neon_mix", neon_mix)
	material.set_shader_parameter("material_mix", material_mix)
	material.set_shader_parameter("seed", seed)
	return material

func _eye_mirror_water_material(color: Color, alpha: float, seed: float, wave := 0.10, mirror := 0.38) -> Material:
	var shader := load("res://shaders/eye_mirror_water.gdshader") as Shader
	if shader == null:
		return _emissive_mat(color, alpha, 0.25)
	var material := ShaderMaterial.new()
	material.shader = shader
	material.set_shader_parameter("water_color", Color(color.r, color.g, color.b, alpha))
	material.set_shader_parameter("gleam_color", Color(0.88, 0.96, 1.0, 0.42))
	material.set_shader_parameter("alpha", alpha)
	material.set_shader_parameter("wave_strength", wave)
	material.set_shader_parameter("mirror_brightness", mirror)
	material.set_shader_parameter("seed", seed)
	return material

func _eye_glass_material(color: Color, alpha: float, energy := 0.34) -> StandardMaterial3D:
	var material := _emissive_mat(color, alpha, energy)
	material.roughness = 0.12
	material.metallic = 0.0
	return material

func _eye_offset_veil_material(color: Color, alpha: float, seed: float, split := 0.35) -> Material:
	var shader := load("res://shaders/eye_mirror_offset_veil.gdshader") as Shader
	if shader == null:
		return _emissive_mat(color, alpha, 0.25)
	var material := ShaderMaterial.new()
	material.shader = shader
	material.set_shader_parameter("tint", Color(color.r, color.g, color.b, alpha))
	material.set_shader_parameter("alpha", alpha)
	material.set_shader_parameter("intensity", eyes_city_style_intensity)
	material.set_shader_parameter("offset_strength", 0.12 + split * 0.12)
	material.set_shader_parameter("seed", seed)
	material.set_shader_parameter("split", split)
	return material

func _add_eye_offset_veil(parent: Node3D, name: String, pos: Vector3, size: Vector2, yaw: float, color: Color, seed: float, split := 0.35) -> void:
	var veil := MeshInstance3D.new()
	veil.name = name
	var plane := PlaneMesh.new()
	plane.size = size
	veil.mesh = plane
	veil.position = pos
	veil.rotation_degrees = Vector3(90.0, yaw, 0.0)
	veil.material_override = _eye_offset_veil_material(color, color.a, seed, split)
	parent.add_child(veil)

func _name_carved_stone_material(color: Color, alpha: float, seed: float, carving := 0.42) -> Material:
	var shader := load("res://shaders/name_carved_stone.gdshader") as Shader
	if shader == null:
		return _mat(color, alpha)
	var material := ShaderMaterial.new()
	material.shader = shader
	material.set_shader_parameter("base_color", Color(color.r, color.g, color.b, alpha))
	material.set_shader_parameter("rune_color", Color(0.90, 0.84, 0.62, 1.0))
	material.set_shader_parameter("alpha", alpha)
	material.set_shader_parameter("carving_strength", carving)
	material.set_shader_parameter("inscription_glow", 0.10 + names_city_style_intensity * 0.08)
	material.set_shader_parameter("seed", seed)
	return material

func _name_misnamed_veil_material(color: Color, alpha: float, seed: float, drift := 0.42) -> Material:
	var shader := load("res://shaders/name_misnamed_veil.gdshader") as Shader
	if shader == null:
		return _emissive_mat(color, alpha, 0.22)
	var material := ShaderMaterial.new()
	material.shader = shader
	material.set_shader_parameter("tint", Color(color.r, color.g, color.b, alpha))
	material.set_shader_parameter("alpha", alpha)
	material.set_shader_parameter("intensity", names_city_style_intensity)
	material.set_shader_parameter("name_drift", drift)
	material.set_shader_parameter("seed", seed)
	return material

func _add_name_text_veil(parent: Node3D, name: String, pos: Vector3, size: Vector2, yaw: float, color: Color, seed: float, drift := 0.42) -> void:
	var veil := MeshInstance3D.new()
	veil.name = name
	var plane := PlaneMesh.new()
	plane.size = size
	veil.mesh = plane
	veil.position = pos
	veil.rotation_degrees = Vector3(90.0, yaw, 0.0)
	veil.material_override = _name_misnamed_veil_material(color, color.a, seed, drift)
	parent.add_child(veil)

func _dead_bone_dissolve_material(color: Color, alpha: float, seed: float, dissolve := 0.22) -> Material:
	var shader := load("res://shaders/dead_bone_dissolve.gdshader") as Shader
	if shader == null:
		return _mat(color, alpha)
	var material := ShaderMaterial.new()
	material.shader = shader
	material.set_shader_parameter("base_color", Color(color.r, color.g, color.b, alpha))
	material.set_shader_parameter("bone_color", Color(0.82, 0.80, 0.70, 1.0))
	material.set_shader_parameter("cold_glow_color", Color(0.38, 0.58, 1.0, 1.0))
	material.set_shader_parameter("alpha", alpha)
	material.set_shader_parameter("dissolve_strength", dissolve)
	material.set_shader_parameter("cold_glow", 0.08 + dead_city_style_intensity * 0.06)
	material.set_shader_parameter("seed", seed)
	return material

func _dead_cold_mist_material(color: Color, alpha: float, seed: float, drift := 0.45) -> Material:
	var shader := load("res://shaders/dead_cold_mist_veil.gdshader") as Shader
	if shader == null:
		return _emissive_mat(color, alpha, 0.18)
	var material := ShaderMaterial.new()
	material.shader = shader
	material.set_shader_parameter("tint", Color(color.r, color.g, color.b, alpha))
	material.set_shader_parameter("alpha", alpha)
	material.set_shader_parameter("intensity", dead_city_style_intensity)
	material.set_shader_parameter("mist_drift", drift)
	material.set_shader_parameter("seed", seed)
	return material

func _add_dead_cold_mist_veil(parent: Node3D, name: String, pos: Vector3, size: Vector2, yaw: float, color: Color, seed: float, drift := 0.45) -> void:
	var veil := MeshInstance3D.new()
	veil.name = name
	var plane := PlaneMesh.new()
	plane.size = size
	veil.mesh = plane
	veil.position = pos
	veil.rotation_degrees = Vector3(90.0, yaw, 0.0)
	veil.material_override = _dead_cold_mist_material(color, color.a, seed, drift)
	parent.add_child(veil)

func _sky_star_material(color: Color, alpha: float, seed: float, star_strength := 0.34, line_strength := 0.28) -> Material:
	var shader := load("res://shaders/sky_star_surface.gdshader") as Shader
	if shader == null:
		return _emissive_mat(color, alpha, 0.16)
	var material := ShaderMaterial.new()
	material.shader = shader
	material.set_shader_parameter("base_color", Color(color.r, color.g, color.b, alpha))
	material.set_shader_parameter("star_color", Color(0.72, 0.86, 1.0, 1.0))
	material.set_shader_parameter("gold_color", Color(1.0, 0.76, 0.28, 1.0))
	material.set_shader_parameter("alpha", alpha)
	material.set_shader_parameter("star_strength", star_strength * sky_city_style_intensity)
	material.set_shader_parameter("line_strength", line_strength * sky_city_style_intensity)
	material.set_shader_parameter("seed", seed)
	return material

func _sky_stardust_veil_material(color: Color, alpha: float, seed: float, drift := 0.45) -> Material:
	var shader := load("res://shaders/sky_stardust_veil.gdshader") as Shader
	if shader == null:
		return _emissive_mat(color, alpha, 0.24)
	var material := ShaderMaterial.new()
	material.shader = shader
	material.set_shader_parameter("tint", Color(color.r, color.g, color.b, alpha))
	material.set_shader_parameter("star_color", Color(0.74, 0.88, 1.0, 1.0))
	material.set_shader_parameter("alpha", alpha)
	material.set_shader_parameter("intensity", sky_city_style_intensity)
	material.set_shader_parameter("drift", drift)
	material.set_shader_parameter("seed", seed)
	return material

func _add_sky_stardust_veil(parent: Node3D, name: String, pos: Vector3, size: Vector2, yaw: float, color: Color, seed: float, drift := 0.45) -> void:
	var veil := MeshInstance3D.new()
	veil.name = name
	var plane := PlaneMesh.new()
	plane.size = size
	veil.mesh = plane
	veil.position = pos
	veil.rotation_degrees = Vector3(90.0, yaw, 0.0)
	veil.material_override = _sky_stardust_veil_material(color, color.a, seed, drift)
	parent.add_child(veil)

func _continuous_pollution_material(color: Color, alpha: float, seed: float, grime := 0.58, repetition := 0.92) -> Material:
	var shader := load("res://shaders/continuous_pollution_surface.gdshader") as Shader
	if shader == null:
		return _mat(color, alpha)
	var material := ShaderMaterial.new()
	material.shader = shader
	material.set_shader_parameter("base_color", Color(color.r, color.g, color.b, alpha))
	material.set_shader_parameter("fog_color", Color(0.62, 0.58, 0.38, 1.0))
	material.set_shader_parameter("dirt_color", Color(0.10, 0.09, 0.065, 1.0))
	material.set_shader_parameter("alpha", alpha)
	material.set_shader_parameter("grime_strength", grime * continuous_city_style_intensity)
	material.set_shader_parameter("repeat_strength", repetition)
	material.set_shader_parameter("low_contrast", 0.36 + continuous_city_style_intensity * 0.10)
	material.set_shader_parameter("seed", seed)
	return material

func _hidden_growth_material(color: Color, alpha: float, seed: float, reveal := 0.50, growth := 0.62) -> Material:
	var shader := load("res://shaders/hidden_growth_reveal_surface.gdshader") as Shader
	if shader == null:
		return _mat(color, alpha)
	var material := ShaderMaterial.new()
	material.shader = shader
	material.set_shader_parameter("base_color", Color(color.r, color.g, color.b, alpha))
	material.set_shader_parameter("growth_color", Color(0.10, 0.54, 0.18, 1.0))
	material.set_shader_parameter("glow_color", Color(0.50, 1.0, 0.62, 1.0))
	material.set_shader_parameter("alpha", alpha)
	material.set_shader_parameter("reveal_strength", reveal * hidden_city_style_intensity)
	material.set_shader_parameter("growth_strength", growth * hidden_city_style_intensity)
	material.set_shader_parameter("mask_softness", 0.28)
	material.set_shader_parameter("seed", seed)
	return material

func _city_style_veil_material(color: Color, alpha: float, style_mode: float, seed: float, intensity: float) -> Material:
	var shader := load("res://shaders/city_style_veil.gdshader") as Shader
	if shader == null:
		return _emissive_mat(color, alpha, 0.35)
	var material := ShaderMaterial.new()
	material.shader = shader
	material.set_shader_parameter("tint", color)
	material.set_shader_parameter("alpha", alpha)
	material.set_shader_parameter("style_mode", style_mode)
	material.set_shader_parameter("seed", seed)
	material.set_shader_parameter("intensity", intensity)
	material.set_shader_parameter("flow_speed", 0.12 + style_mode * 0.16)
	material.set_shader_parameter("noise_scale", 3.2 + style_mode * 2.4)
	material.set_shader_parameter("vertical_wave", 0.12 + style_mode * 0.38)
	material.set_shader_parameter("ink_strength", 0.16 + intensity * 0.08)
	material.set_shader_parameter("shadow_strength", 0.18 + style_mode * 0.10)
	material.set_shader_parameter("color_variation_strength", 0.12 + intensity * 0.05)
	return material

func _add_city_style_veil(parent: Node3D, name: String, pos: Vector3, size: Vector2, yaw_degrees: float, color: Color, style_mode: float, seed: float, intensity: float) -> void:
	var veil := MeshInstance3D.new()
	veil.name = name
	var plane := PlaneMesh.new()
	plane.size = size
	veil.mesh = plane
	veil.position = pos
	veil.rotation_degrees = Vector3(90.0, yaw_degrees, 0.0)
	veil.material_override = _city_style_veil_material(color, color.a, style_mode, seed, intensity)
	parent.add_child(veil)

func _sign_toon_material(color: Color, seed: float, contrast := 0.72) -> Material:
	var shader := load("res://shaders/sign_toon_surface.gdshader") as Shader
	if shader == null:
		return _mat(color, color.a)
	var material := ShaderMaterial.new()
	material.shader = shader
	material.set_shader_parameter("base_color", color)
	material.set_shader_parameter("ink_color", Color(0.025, 0.025, 0.022, 1.0))
	material.set_shader_parameter("contrast", contrast)
	material.set_shader_parameter("rim_strength", 0.42)
	material.set_shader_parameter("hatch_strength", 0.16)
	material.set_shader_parameter("seed", seed)
	return material

func _sign_projection_material(color: Color, alpha: float, seed: float, failure := 0.0) -> Material:
	var shader := load("res://shaders/sign_projection_veil.gdshader") as Shader
	if shader == null:
		return _emissive_mat(color, alpha, 0.35)
	var material := ShaderMaterial.new()
	material.shader = shader
	material.set_shader_parameter("ink_color", Color(0.025, 0.025, 0.022, alpha))
	material.set_shader_parameter("glow_color", color)
	material.set_shader_parameter("alpha", alpha)
	material.set_shader_parameter("seed", seed)
	material.set_shader_parameter("intensity", signs_city_style_intensity)
	material.set_shader_parameter("failure", failure)
	material.set_shader_parameter("symbol_scale", 10.0 + fmod(seed, 7.0))
	return material

func _add_sign_projection_veil(parent: Node3D, name: String, pos: Vector3, size: Vector2, yaw_degrees: float, color: Color, seed: float, failure := 0.0) -> void:
	var veil := MeshInstance3D.new()
	veil.name = name
	var plane := PlaneMesh.new()
	plane.size = size
	veil.mesh = plane
	veil.position = pos
	veil.rotation_degrees = Vector3(90.0, yaw_degrees, 0.0)
	veil.material_override = _sign_projection_material(color, color.a, seed, failure)
	parent.add_child(veil)

func _zone_debug_material(color: Color, alpha: float) -> StandardMaterial3D:
	var material := StandardMaterial3D.new()
	material.albedo_color = Color(color.r, color.g, color.b, alpha)
	material.emission_enabled = true
	material.emission = Color(color.r, color.g, color.b)
	material.emission_energy_multiplier = 0.25
	material.roughness = 1.0
	material.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	material.no_depth_test = true
	return material

func _grey_chaos_material(color: Color, alpha: float, noise_scale: float, flow_speed: float, distortion: float, seed: float) -> Material:
	if not chaos_shader_enabled:
		return _mat(color, min(alpha, 1.0))
	var shader := load("res://shaders/grey_chaos.gdshader") as Shader
	if shader == null:
		return _mat(color, min(alpha, 1.0))
	var material := ShaderMaterial.new()
	material.shader = shader
	material.set_shader_parameter("base_color", color)
	material.set_shader_parameter("alpha", alpha)
	material.set_shader_parameter("noise_scale", noise_scale)
	material.set_shader_parameter("flow_speed", flow_speed)
	material.set_shader_parameter("distortion", distortion)
	material.set_shader_parameter("seed", seed)
	material.set_shader_parameter("ink_strength", 0.14 + alpha * 0.16)
	material.set_shader_parameter("shadow_strength", 0.14 + distortion * 0.30)
	material.set_shader_parameter("color_variation_strength", 0.08 + alpha * 0.12)
	return material

func _audio_stream_or_generator(paths: Array, loop_stream := false) -> AudioStream:
	for path in paths:
		var audio_path := String(path)
		if ResourceLoader.exists(audio_path):
			var loaded := load(audio_path)
			if loaded is AudioStream:
				var stream := loaded as AudioStream
				if loop_stream:
					_set_audio_stream_loop(stream, true)
				return stream
	var generator := AudioStreamGenerator.new()
	generator.mix_rate = 22050
	generator.buffer_length = 0.5
	return generator

func _set_audio_stream_loop(stream: AudioStream, enabled: bool) -> void:
	for property in stream.get_property_list():
		var property_name := String(property.get("name", ""))
		if property_name == "loop":
			stream.set("loop", enabled)
			return
		if property_name == "loop_mode":
			stream.set("loop_mode", 1 if enabled else 0)
			return

func _register_generator(player_node: Node, frequency: float) -> void:
	generated_audio_players.append(player_node)
	generator_phases.append(frequency)
	generator_playbacks.append(null)

func _set_generated_frequency(player_node: Node, frequency: float) -> void:
	var index := generated_audio_players.find(player_node)
	if index == -1:
		return
	generator_phases[index] = frequency
	generator_playbacks[index] = null

func _fill_generated_audio() -> void:
	for i in range(generated_audio_players.size()):
		var p = generated_audio_players[i]
		if p == null or not bool(p.get("playing")) or not (p.get("stream") is AudioStreamGenerator):
			continue
		if generator_playbacks[i] == null:
			generator_playbacks[i] = p.call("get_stream_playback")
		var playback: AudioStreamGeneratorPlayback = generator_playbacks[i]
		if playback == null:
			continue
		var frames := playback.get_frames_available()
		var phase_hz := generator_phases[i]
		for f in range(frames):
			var t := float(Time.get_ticks_msec() % 100000) / 1000.0 + float(f) / 22050.0
			var sample := sin(t * TAU * phase_hz) * 0.05 + sin(t * TAU * phase_hz * 1.5) * 0.025
			playback.push_frame(Vector2(sample, sample))

func _ascii_zone_name(_label_text: String, index: int) -> String:
	var names := ["Memory", "Desire", "Signs", "Thin", "Trading", "Eyes", "Names", "Dead", "Sky", "Continuous", "Hidden"]
	return names[index]
