# 资产接入交接清单

最后自检日期：2026-06-18

## 记忆之城当前状态

- `citycity/assets/models/memory/` 内现有 34 个 `.glb` 已全部被 `scripts/main.gd` 接入。
- 这些资产会以 `Imported_<AssetName>` 的节点名挂在对应白盒节点下，原始白盒主体会自动隐藏，保留少量舞台底座、碰撞代理、细小叙事标记。
- `EchoTower.glb` 已做过异常发光收敛、缩小碰撞代理、扩大阅读触发范围和中心距离兜底。
- `CockfightRing.glb` 已做过横竖轴修正。

## 必须补齐的缺失资产

- `SilverDomeHouse.glb`
  - 设计表中存在，但当前资产目录没有该文件。
  - 当前临时代用品：`TurkishBath.glb` 加银色穹顶点缀。
  - 补齐后建议新增到 `MEMORY_MODEL_PATHS`，并把 `_build_silver_dome_house()` 的代理替换为真实资产。

## 当前仍是临时代用品的叙事物件

这些不是启动阻塞项，但最终资产到位后应替换：

- `GoldenRoosterTower`
  - 目前主体使用 `GreatBellTower.glb`，金鸡仍是小型 CSG 点缀。
- `BronzeGodStatue_Left` / `BronzeGodStatue_Right`
  - 目前使用 `BronzeShrine.glb`，神像身体与手臂仍是 CSG 点缀。
- `WatermelonKiosk`
  - 目前使用 `CornerCafe.glb`，西瓜摊位色块仍是 CSG 点缀。
- `HermitLionStatue`
  - 目前使用 `BronzeShrine.glb`，隐士与狮子仍是 CSG 点缀。
- `WhiteParasolLadies`
  - 目前使用 `ThirdWomanArcade.glb`，人物与阳伞仍是 CSG 点缀。
- `HarborMemoryPost_*` / `CentralPlazaMemoryMarker_*`
  - 目前使用 `BronzeShrine.glb` 作为记忆碑代理，并保留暖色发光细缝。

## 后续资产导入标准

- 格式保持 `.glb` / `.gltf 2.0`。
- Godot 单位保持 1 单位 = 1 米。
- Pivot 建议放在底部中心，便于直接替换现有节点。
- 贴图上限 1024，优先纯色调色板与低频噪点。
- 导入后先确认三个问题：站立轴、落地点、体量尺度。

## 性能风险

- 根目录 `assets/` 是本地原始投放目录，已加入根 `.gitignore`，避免误提交重复源资产。
- 当前 `citycity/assets/models/memory/` 的 34 个 GLB 总体积约 2.62 GB，`citycity/assets/models/` 约 3.78 GB。
- 后续正式版建议压缩目标：
  - 小/中型道具：单文件 5-10 MB 以内。
  - 大型地标：单文件 25 MB 左右优先。
  - 删除未使用高密网格、隐藏历史对象、过大贴图和重复材质。

## 视觉验收重点

- 建筑必须保持实体可读，不要再大面积半透明化。
- 发光只保留局部窗口、缝隙、指引点，避免整栋建筑或整座塔自发光。
- 回声塔附近需继续人工试玩确认：走动不被看不见的碰撞卡住，塔底与中心附近均可按 `E` 阅读。
- 灰域寻声需要用实机耳机验收：目标主题音效应随距离明显增强，非目标区环境音只能作为背景干扰。

## 音频待补

当前已有长音乐：

- `memory_background.mp3`
- `theme_bgm/desire_background.mp3`
- `theme_bgm/signs_background.mp3`
- `theme_bgm/trade_background.wav`

以下主题仍会复用已有长音乐，直到补齐专属文件：

- 轻盈之城
- 眼睛之城
- 姓名之城
- 死者之城
- 天空之城
- 连续之城
- 隐蔽之城

灰域规则：灰域中不播放长背景音乐，只保留寻声主题短音效与区域环境音。
