# 看不见的城市 - 第一版白盒说明

## 当前目标

这是一个基于《看不见的城市》灵感的简单体验游戏原型。

当前白盒实现“记忆”和“欲望”两个主题入口，但初始只允许进入“记忆”：

1. 主菜单
2. 剧情幻灯片
3. 选择城市描述/关卡
4. 机制提示
5. 进入主城灰域
6. 通过声音寻找所选主题区域中心
7. 显现对应主题城市并恢复碰撞
8. 记忆主题：寻找中心建筑“回声塔”
9. 欲望主题：收集 5 件欲望物，进入月光迷宫终点
10. 阅读幻灯片
11. 选择“留 / 去”

当前解锁规则：

- 新开局只开放“记忆”。
- 玩家完成记忆之城阅读并进入“留 / 去”选择后，运行时解锁“欲望”。
- 当前还没有跨启动存档；关闭游戏后解锁状态会重置。

## 设计原则

- 核心机制是寻声，不是战斗。
- 不加入战斗、生命值、失败惩罚；移动只保留轻微加速和基础跳跃，服务于白盒通行。
- 当前构建了“记忆”和“欲望”主题，但“欲望”需要先通关记忆后才可选择。
- 记忆主题下目前把 5 个记忆篇章合并为同一座白盒城市。
- 欲望主题下目前把 5 个欲望篇章合并为同一座白盒城市，通关逻辑为拾取物品。
- 每次进入记忆中心后，显现这座合并后的记忆之城。
- 其他主题只作为后续关卡入口展示。
- 白盒城市只使用 Godot 内置基础几何。
- 不导入外部建筑模型。
- 灰域视觉先使用轻量雾效、低对比轮廓和粒子。

## 已有主题

- 记忆
- 欲望
- 标志
- 薄的
- 贸易
- 眼睛
- 姓名
- 死的
- 天空
- 连续的
- 隐

## 当前操作

- W 前进
- S 后退
- A 左移
- D 右移
- Space：跳跃
- Shift：轻微加速
- 按住鼠标左键拖动：转动视角
- E：交互
- Esc：暂停
- H：重新显示操作提示

## 白盒调试说明

当前灰域已经按 11 个主题建立音区结构：

- 场景树中父节点：`MainCityGreyDomain`
- 音区父节点：`SoundZones`
- 每个主题对应一个不可见 `Area3D`
- 白盒可视范围父节点：`GreyZoneDebugVisibleWhitebox`
- 混沌视觉父节点：`GreyChaosShaderRoot`

在 `Main` 节点 Inspector 中可以调整：

- `show_grey_zone_debug`：是否显示 11 个彩色区域范围。后期正式游玩应关闭。
- `grey_zone_debug_alpha`：彩色区域透明度。
- `chaos_shader_enabled`：是否启用灰域混沌 shader。
- `chaos_shader_alpha`：混沌雾幕透明度。
- `chaos_veil_count`：混沌雾幕数量。
- `grey_mote_particle_amount`：灰域细小雾粒数量。
- `grey_sand_particle_amount`：沙漠沙流感粒子数量。
- `grey_current_particle_amount`：海底水流感粒子数量。
- `grey_willow_particle_amount`：柳絮漂浮粒子数量。
- `grey_storm_particle_amount`：风暴横切粒子数量。
- `grey_turbulence_particle_amount`：乱流碎片粒子数量。
- `grey_ash_particle_amount`：灰烬/灾后漂浮粒子数量。
- `grey_pressure_particle_amount`：压力波尘/横向低空乱流数量。
- `grey_rain_particle_amount`：盲雨/垂坠线性粒子数量。
- `grey_blindness_veil_count`：盲视空间雾幕层数。
- `grey_echo_wave_count`：地表回声波纹层数。
- `grey_post_process_enabled`：是否启用灰域全屏视觉后处理。
- `grey_post_effect_strength`：全屏视觉效果总强度。
- `grey_post_grain_strength`：噪点颗粒强度。
- `grey_post_halftone_strength`：网点/半色调强度。
- `grey_post_pixel_strength`：像素化强度。
- `grey_post_flatten_strength`：二维化/灰度平面化强度。
- `grey_post_edge_strength`：边缘描线强度。
- `grey_post_contour_strength`：等高线/轮廓线强度。
- `grey_post_solarize_strength`：日晒化/反相质感强度。
- `grey_post_tear_strength`：画面横向撕裂漂移强度。

记忆区域轻引导：

- `memory_guide_enabled`：是否启用记忆区域弱光团。
- `memory_guide_start_distance`：距离记忆中心多远开始出现。
- `memory_guide_full_distance`：距离多近时光团最明显。
- 该光团不是箭头，也不是地图，只是靠近正确主题区域后在中心附近出现的弱提示。

灰域后处理位于：

`shaders/grey_post_process.gdshader`

显形城市风格化空间层位于：

`shaders/city_style_veil.gdshader`

该 shader 只用于城市内透明雾幕、残影、热浪和海市蜃楼层，不再使用裂纹、网状或密集屏幕纹理。

它会混合以下效果：

- 噪点颗粒
- 网点/半色调（默认关闭，避免出现密集裂纹感）
- 像素化
- 海报化
- 二维灰度平面化
- 扫描线（默认关闭）
- 轻微色散
- 横向撕裂漂移（默认关闭）
- 边缘描线
- 等高线
- 日晒化/短暂反相闪烁
- 波形扰动
- 暗角

不同音乐区域会驱动不同效果比例。后续可以继续按主题调整每个区域的视觉风格。

脚步声：

- 当前脚步声为程序化短音效触发，不是长循环。
- 灰域脚步偏沙、闷、低频噪声。
- 城市显现后脚步偏硬质、清晰。
- Shift 轻微加速时脚步节奏会随速度变快。

运行时快捷键：

- `F2`：切换 11 个彩色调试区域显示/隐藏。

当前白盒约定：

- “记忆”区域在调试可视状态下显示为黄色。
- 玩家每次进入主城灰域时，会从多个固定出生点中随机选择一个；默认会筛掉离回声塔或记忆中心太近的点。
- 所选主题中心现在位于灰域不同区域，显形后玩家不会直接站在关键建筑旁边，需要在更大的城市范围内完成目标。
- 记忆主题不再随机选择 5 个城市变体；五个篇章已经合并为一座更大的记忆之城。
- 回声塔只生成一次，并且周围保留禁建半径，避免与普通建筑重叠。
- 灰域边缘使用对向传送，玩家走出 120m 灰域后会从相反边缘回到灰域，避免掉入虚空。
- 城市显形后使用不可见空气墙限制白盒城市范围。
- 11 个主题音区覆盖整张 120m 灰域，区域之间允许轻微重叠，避免玩家走出一个区域后进入“无声音区”。
- 正式游玩时 11 个区域应全部不可见，只通过声音区分；F2 只用于白盒阶段检查区域覆盖。
- 灰域状态下 `ManifestedCity` 隐藏且碰撞关闭。
- 到达记忆中心后，灰域视觉关闭，`ManifestedCity` 显示并恢复碰撞。
- 回声塔阅读交互同时使用 `Area3D` 触发和距离兜底；选择“留”后，玩家仍可回到塔底按 E 再次打开阅读和“留 / 去”选择。
- 欲望主题不会直接使用回声塔触发通关。玩家需要拾取 `CitronCrate`、`AgateStone`、`WineSkin`、`GlassSphere`、`DreamRoadFragment` 五件欲望物，然后进入 `MoonTrapPlaza` 的 `DesireGoalTrigger` 按 E 阅读。

## 记忆之城白盒规划

当前记忆之城选择方向：雾中高原旧港遗城。

地形结构：

- 平坦高原盆地：`Terrain_FogHighlandDryBasin`
- 干涸港湾：`DryHarborBasin`
- 中心环形广场：`ZoneF_EchoTowerCentralPlaza`
- 主路线：黄昏入口区 -> 历史刻痕区 / 迟到欲望区 -> 静止记忆区 -> 回声塔 -> 新旧叠影区 / 干涸港湾

白盒分区：

- `ZoneA_TwilightEntrance`：黄昏入口区，包含银圆顶屋、炸食店、女声凉台、金鸡塔。
- `ZoneB_LateDesire`：迟到欲望区，包含贝壳螺旋梯、望远镜工坊、小提琴工坊、老人墙。
- `ZoneC_HistoricalScars`：历史刻痕区，包含碉堡、拱廊、绞刑灯柱、红绳、栅栏、斜水槽屋。
- `ZoneD_StaticMemory`：静止记忆区，包含铜钟楼、理发店、九眼喷泉、天文馆、蜂巢墙等。
- `ZoneE_OldNewOverlay`：新旧叠影区，包含公交站、音乐凉台、拱桥、火药厂、新旧叠影墙、神龛。
- `ZoneF_EchoTowerCentralPlaza`：中心区，包含 `EchoTower` 和环形广场。
- `ZoneG_DryHarbor`：干涸港湾，包含干涸码头、破鱼网、三老人码头座。

后续资产替换优先使用这些英文节点名：

- `EchoTower`
- `SilverDomeHouse_*`
- `BronzeGodStatue_Left` / `BronzeGodStatue_Right`
- `CrystalTheater`
- `GoldenRoosterTower`
- `TwilightFryShop`
- `VoiceBalcony`
- `ShellSpiralStair`
- `TelescopeWorkshop`
- `ViolinWorkshop`
- `OldMenWall`
- `TallBastion_*`
- `CurvedArcade_Left` / `CurvedArcade_Right`
- `GallowsLampPost`
- `RedMemoryRope`
- `LoverFence`
- `SlantedGutterHouse`
- `DryDock`
- `TornNetFrame`
- `ThreeEldersDockSeat`
- `GreatBronzeBellTower`
- `StripedBarberShop`
- `NineSpoutFountain`
- `GlassObservatory`
- `WatermelonKiosk`
- `HermitLionStatue`
- `TurkishBath`
- `CornerCafe`
- `HoneycombMemoryWall_Left` / `HoneycombMemoryWall_Right`
- `PostcardRack`
- `BusStation`
- `OldBandstand`
- `NewArchBridge`
- `PowderFactory`
- `WhiteParasolLadies`
- `OldNewOverlayWall`
- `EmptyShrine`
- `ForeignShrine`

记忆城风格化占位：

- `MemoryCityAtmosphere_StyleDirection`
- `CityDustParticles`
- `PaperScrapParticles`
- `OldPhotoFragmentParticles`
- `FaintGoldenMemoryMotes`
- `MemoryAshSlowFall`
- `MemoryFilmAfterimageVeil_*`
- `MemoryResidualSlice_*`
- `AfterimageFrameGhosts_NoCollision`

记忆城风格方向：

- 更强旧胶片残影。
- 低饱和灰金色雾幕。
- 纸屑、旧照片碎片、灰尘和慢落灰烬。
- 城市像从过去的层叠图像中显现。

## 欲望之城白盒规划

当前欲望之城选择方向：沙漠与海港之间的运河白城。

地形结构：

- 外圈沙漠：`DesireTerrain_DesertCanalWhiteCity`
- 城墙与护城河：`DesireCityWall_*`、`Moat_*`
- 绿色十字运河：`GreenCanal_NorthSouth`、`GreenCanal_WestEast`
- 主路线：商队入口区 -> 运河欲望区 -> 沙海双面区 / 理想模型区 -> 月光迷宫区

白盒分区：

- `ZoneA_CaravanEntrance`：商队入口，包含吊桥城门、集市高台、香料货市、彩旗、小号士兵。
- `ZoneB_CanalDesire`：运河欲望区，包含绿色运河街区、宝石切割坊、水池花园、风筝屋顶群。
- `ZoneC_DesertSeaMirage`：沙海双面区，包含沙海双面塔、雷达尖顶楼、烟囱工坊、港口酒馆、白墙瓷院宫。
- `ZoneD_IdealModelMuseum`：理想模型区，包含石灰石旧城、金属博物馆、玻璃球展厅、蓝城模型台。
- `ZoneE_MoonlitMaze`：月光迷宫区，包含月光白城墙、线团迷宫街、封闭拱廊、错位楼梯、无出口墙、女子幻影。
- `ZoneF_CentralCanalPlaza`：中心运河广场，作为城市空间中心，不直接通关。

后续资产替换优先使用这些英文节点名：

- `DesireCity_CanalMirageWhiteCity`
- `DesireCityWall_North` / `DesireCityWall_South` / `DesireCityWall_West` / `DesireCityWall_East`
- `AluminumTower_*`
- `SpringDrawbridgeGate_*`
- `GreenCanalBlock_*`
- `MarketTrumpetPlatform`
- `SpiceMarket_Left` / `SpiceMarket_Right`
- `GemCuttingWorkshop`
- `PoolGarden`
- `KiteRoofCluster`
- `DesertSeaTower`
- `RadarSpireBuilding`
- `SmokingChimneyHouse`
- `HarborTavern`
- `WhiteTilePalace`
- `LimestoneCityBlock_*`
- `MetalMuseum`
- `GlassSphereHall`
- `BlueCityModelTable`
- `MoonlitWhiteWall`
- `TangledMazeStreet`
- `ClosedArcade_Left` / `ClosedArcade_Right`
- `MisplacedStair`
- `NoEscapeWall`
- `MoonTrapPlaza`

欲望主题拾取物：

- `CitronCrate`
- `AgateStone`
- `WineSkin`
- `GlassSphere`
- `DreamRoadFragment`

拾取物可视规则：

- 每件拾取物都有不同颜色的本体和辉光。
- 每件拾取物都有 `PickupGlowDisk`、`PickupVerticalGlow`、`PickupColoredHaloLight`、`PickupGlowParticles`、`PickupColorMarker_*`。
- 拾取后整组隐藏，避免误导玩家。
- 这些辉光只是白盒阶段的可读性辅助，后续可替换为更精细的资产特效。

欲望城风格化占位：

- `DesireCityAtmosphere_StyleDirection`
- `HeatHazeLayer`
- `DesireGoldMote`
- `RedDesireParticles`
- `FarMirageLightSpots`
- `CanalMist`
- `OverexposedEdgeSparks`
- `DesireHeatMirageVeil_*`
- `DesireHorizonOverexposure_*`

欲望城风格方向：

- 更强热浪扭曲。
- 金红色高饱和粒子。
- 运河水汽与远处海市蜃楼。
- 过曝边缘和远景光斑，让城市目标显得真实又可疑。

音频目前仍是占位逻辑。后续真实音频建议放在：

`assets/audio/`

灰域 11 个主题区域建议使用：

- `grey_memory_loop.ogg`
- `grey_desire_loop.ogg`
- `grey_signs_loop.ogg`
- `grey_thin_loop.ogg`
- `grey_trading_loop.ogg`
- `grey_eyes_loop.ogg`
- `grey_names_loop.ogg`
- `grey_dead_loop.ogg`
- `grey_sky_loop.ogg`
- `grey_continuous_loop.ogg`
- `grey_hidden_loop.ogg`

城市显形后建议使用：

- `city_memory_loop.ogg`
- `city_desire_loop.ogg`

旧文件名 `memory_theme_loop.ogg` 仍作为兼容 fallback。

## 后续扩展建议

后续每个主题城市可以更换地形、视觉风格、阅读内容和中心建筑，但建议继续保持同一主循环：

选择主题 -> 进入灰域 -> 听声寻找 -> 城市显形 -> 到达中心建筑 -> 阅读 -> 留 / 去。
