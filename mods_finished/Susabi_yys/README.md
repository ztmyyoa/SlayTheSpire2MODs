# 荒 (Susabi) — Slay the Spire 2 角色 Mod
# 作者：ZTMYkun B站地址：【杀戮尖塔2新角色mod阴阳师神启荒（预告版）】 https://www.bilibili.com/video/BV1jP7Z6qEse/?share_source=copy_web&vd_source=82a4c95d79a215d31760a161f21cd66b
# 创意工坊地址：https://steamcommunity.com/sharedfiles/filedetails/?id=3747581844
---

## 简介

将《阴阳师》中的**荒 (Susabi)** 带入《杀戮尖塔 2》。

荒拥有独特的 **星辰之力 (Star Power)** 资源系统：通过卡牌积累星辰之力，消耗它来强化卡牌效果、触发 **星爆 (Star Burst)** 造成范围伤害，或利用 **星痕 (Star Mark)** 向敌人施加 debuff。围绕星辰的获得、消耗和爆发构建了一套高互动的牌组循环玩法。

---

## 角色信息

| 属性 | 值 |
|------|-----|
| 英文名 | Susabi |
| 初始血量 | 70 |
| 初始金币 | 99 |
| 解锁方式 | 开局可用 |
| 初始遗物 | 星之护符（进入战斗获得 2 层星辰之力） |
| 初始卡组 | 4击 + 星罗云布 + 4防 + 星落 + 星月 |

---

## 核心机制

### 星辰之力 (Star Power)

荒的专属战斗资源，显示在能量球旁边。通过卡牌获得，用于触发额外效果：

- **获得**：`GainStarPower` — 战斗内积累，无上限
- **消耗**：`ConsumeStarPower` — 卡牌消耗星辰触发强化效果
- **查询**：`GetStarPower` / `HasStarPower` — 条件判断

### 星爆 (Star Burst)

消耗 1 层星辰之力，对所有敌人造成 **5 点伤害** + 回复 **1 点生命**。触发次数和效果倍率可被能力/遗物修改。


### 星痕 (Star Mark)

施加给敌人的 debuff：下次受到攻击伤害时消耗 1 层，返还 **1 点能量**给攻击者。

### 预见 (Scry)

复用观者的预见机制，查看/排列抽牌堆顶部的牌。

### 陨星 (Meteor Star)

0 费衍生 Token 卡：造成 6 伤 + 获得 1 星 + 抽 1 牌，消耗。

### 御魂 (Souls)

15 张无色能力 Token 卡，通过事件/药水获得，每张提供独特的被动效果。

### 星辰牌 (Star Card)

可通过消耗/当前星辰之力触发强化效果。**皓月天命** 能力可让星辰牌效果翻倍。

---

## 内容统计

| 类别 | 数量 | 说明 |
|------|------|------|
| 卡牌 | 106 | 5 基础 + 31 攻击 + 37 技能 + 18 能力 + 15 御魂 |
| 能力 (Power) | 42 | 卡牌对应 + 关键词 + 御魂 |
| 遗物 | 10 | 1 初始 + 1 升级初始 + 2 普通 + 2 罕见 + 2 稀有 + 2 事件 |
| 药水 | 7 | 2 普通 + 3 罕见 + 2 稀有 |
| 事件 | 3 | 女子会 / 御魂三选一 / 命运抉择 |
---

## 安装方法

1. 下载最新的 `Susabi` 发布包
2. 将 `Susabi` 文件夹放入 `游戏目录/mods/`
3. 将 `BaseLib.dll` 放入游戏根目录（如已安装其他 Mod 可跳过）
4. 启动游戏，在选择角色界面即可看到荒


# 荒(Susabi) — 杀戮尖塔2 角色Mod 设计文档

> 阴阳师 荒 · 高天原天命之神 · 星辰与月之力

---

## 一、角色概述

| 属性 | 值 |
|------|-----|
| 角色ID | `Susabi` |
| 英文名 | Susabi |
| 中文名 | 荒 |
| 来源 | 阴阳师 (Onmyoji) |
| 初始血量 | **70** |
| 初始金币 | **99** |
| 颜色主题 | 深蓝色 `Color(0.05, 0.15, 0.55)` |
| 性别 | 男 |
| 解锁条件 | 开局可用 |
| 依赖 | BaseLib, STS2-RitsuLib |

**角色描述（ZHS）：** 一位来自高天原天命之神，运用星月和预言之力探寻高塔的秘密。

**角色描述（ENG）：** A god of fate from Takamagahara who wields the powers of stars, the moon, and prophecy to uncover the secrets of the Spire.

---

## 二、核心机制

### 2.1 星辰之力（Star Power）

荒的核心资源系统。使用 STS2 内置星星存储（`PlayerCmd.GainStars` / `PlayerCombatState.LoseStars` / `PlayerCombatState.Stars`）。

- **UI 显示：** 始终显示计数器（`ShouldAlwaysShowStarCounter = true`），位于能量图标旁
- **上限：** 无上限
- **用途：** 触发卡牌强化效果、消耗换取额外收益、触发星爆

#### StarPowerCmd API

```csharp
// 叠星 — 为玩家增加星辰之力，广播 IOnStarGained
// source != null 且玩家有辉月(ShineMoonPower)时效果翻倍
StarPowerCmd.GainStarPower(ctx, player, amount, source)

// 消星 — 判断星辰是否足够，消耗并广播 IOnStarConsumed
// consume=false 时跳过实际扣除但仍广播事件（免费打出用）
// 返回 true=成功消耗, false=星辰不足
StarPowerCmd.ConsumeStarPower(ctx, player, amount, source, consume=true)

// 查询
StarPowerCmd.GetStarPower(player)           // int — 当前星辰数
StarPowerCmd.HasStarPower(player, required) // bool — 是否≥required

// 本回合累计消耗星数（用于燃星等卡牌）
SusabiModel.GetStarsConsumedThisTurn(player)
```

### 2.2 星痕（Star Mark）

给敌人的 Debuff（`StarMarkPower`, PowerType=Debuff）。叠加在敌人身上，**下次受到攻击时返还1点能量给攻击者并消耗1层**。

- 关键词：`StarMark`
- 广播事件：`IOnStarMarkTriggered`

### 2.3 星爆（Star Burst）

星辰之力的终极释放方式。默认效果：**消耗1星 → 对全体敌人造成5点伤害 + 回复1点生命**。

```csharp
// 唯一入口
StarPowerCmd.TriggerStarBurst(ctx, player, source, consumeStar=true, burstCount=0, effectMultiplier=0)
```

| 参数 | 说明 |
|------|------|
| `consumeStar` | 是否消耗1星（false=免费星爆） |
| `burstCount` | 触发次数（0=默认1，可由 IModifyStarBurstCount 修改） |
| `effectMultiplier` | 效果倍率（0=默认1，可由 IModifyStarBurstEffect 修改） |

**次数修改器：** `IModifyStarBurstCount` — 星裂Power(+N) / 引星戒指(x2)  
**倍率修改器：** `IModifyStarBurstEffect` — 每层消耗1点计数

### 2.4 预见（Scry）

复用观者的 Scry 机制。执行后广播 `IOnScryPerformed`。

```csharp
ScryCmd.Execute(ctx, player, amount)
```

- 关键词：`Scry`
- 关联接口：`IOnScryPerformed` — 月铭引曜、预言星盘等在此触发
- 增强：命星(FateStarPower)使所有预见效果+1

### 2.5 陨星（Meteor Star）

Token 无色卡。**0费 打6(8) 叠1(2)星 抽1(2) 消耗**。是荒的核心衍生卡资源，大量卡牌往牌组中加入陨星。

### 2.6 御魂（Souls/Tamashii）

无色能力卡系列（20张），通过事件/卡牌/药水获得。每张御魂提供强大的被动效果。详见下方 §4.11 御魂牌。

### 2.7 星辰牌（Star Card）

实现 `IStarCard` 接口的卡牌。这类卡牌的效果可被**皓月天命(StarDoublePower)**翻倍——打出下一张星辰牌时效果翻倍，消耗1层计数。

### 2.8 关键接口

| 接口 | 触发时机 | 说明 |
|------|----------|------|
| `IOnStarGained` | 获得星辰之力时 | 叠星后广播 |
| `IOnStarConsumed` | 消耗星辰之力时 | 消星后广播 |
| `IOnStarBurst` | 星爆触发时 | 星爆后广播 |
| `IOnScryPerformed` | 执行预见后 | Scry后广播 |
| `IOnStarMarkTriggered` | 星痕触发时 | 敌人被攻击触发星痕回能 |
| `IOnCreatureDied` | 任何单位死亡时 | 月曜等在此触发 |
| `IModifyStarBurstCount` | 计算星爆次数时 | 修改 burstCount |
| `IModifyStarBurstEffect` | 计算星爆倍率时 | 修改 effectMultiplier |

---

## 三、角色初始配置

### 3.1 初始牌组（11张）

| 卡牌 | 数量 | 费用 | 类型 | 效果 |
|------|------|------|------|------|
| StrikeSusabi（打击） | 4 | 1 | 攻击 | 打6(9) |
| DefendSusabi（防御） | 4 | 1 | 技能 | 防5(8) |
| StarStrike（星落） | 1 | 1 | 攻击 | 打7(11) 叠1(2)星，星>3给1(2)易伤 |
| StarDefend（星月） | 1 | 1 | 技能 | 防6(9) 叠1(2)星，星>3给全敌1(2)虚弱 |
| StarCloud（星罗云布） | 1 | 2 | 能力 | 叠3(4)星，星≥3时敌方回合结束→未造成伤害的敌人触发星爆 |

### 3.2 初始遗物

**星之护符(StarAmulet)** — 每场战斗开始时获得2层星辰之力。
- 可通过 Orobas 事件升级为**星月护符(StarMoonAmulet)**：战斗开始获4星 + 每回合开始获1星。

---

## 四、卡牌图鉴

> 格式：**中文名(英文名)** 费用 类型 稀有度 — 效果  
> 括号内为升级版数值。⬆标记表示升级后效果变化。

### 4.1 基础牌（Basic）

| 卡牌 | 费 | 类 | 效果 |
|------|-----|-----|------|
| **打击(StrikeSusabi)** | 1 | 攻 | 打6(9) |
| **防御(DefendSusabi)** | 1 | 技 | 防5(8) |
| **星落(StarStrike)** ⭐ | 1 | 攻 | 打7(11)，叠1(2)星。星>3给1(2)易伤 |
| **星月(StarDefend)** ⭐ | 1 | 技 | 防6(9)，叠1(2)星。星>3给全敌1(2)虚弱 |

⭐ = 星辰牌（IStarCard）

### 4.2 攻击-普通（Common Attack, 11张）

| # | 卡牌 | 费 | 效果 |
|---|------|-----|------|
| 1 | **陨星之光(MeteorLight)** ⭐ | 1 | 随机打3(4)×3。耗1星→额外+1(2)次 |
| 2 | **朔星连斩(StarSlash)** | 1 | 打2×3(5)。每次破防伤害叠1星 |
| 3 | **星坠(StarFall)** | 1 | AOE7(8)。每有一敌叠1星。消耗(⬆去消耗) |
| 4 | **星叙(StarNarrate)** | 0 | 打4(5)，抽1。若抽到技能牌→叠1(2)星 |
| 5 | **星惑(StarConfuse)** ⭐ | 1 | AOE3(5)，给全敌1(2)虚。星>4→额外全敌1(2)易 |
| 6 | **凝星(CondenseStar)** | 1 | 打7(11)，叠1(2)星 |
| 7 | **星铭(StarInscribe)** ⭐ | 1 | 打8(11)。星>6→耗2星给1(2)层星痕 |
| 8 | **破月星摧(MoonBreak)** ⭐ | 1 | 打12(15)，耗2星。穿盾（不受格挡影响） |
| 9 | **月陨(MoonFall)** ⭐ | 2 | 打25(35)。需耗5星，每缺1减3(5)伤 |
| 10 | **嘘月(WhisperMoon)** ⭐ | 1 | 打11(15)。下回合叠2(3)星。星>6→下回合+1(2)能 |
| 11 | **星月锁链(StarMoonChain)** ⭐ | 1 | 防8(11)，给全敌1(2)易+1虚。耗1星→额外1(2)层星痕 |

### 4.3 攻击-罕见（Uncommon Attack, 12张）

| # | 卡牌 | 费 | 效果 |
|---|------|-----|------|
| 1 | **星轨(StarTrail)** ⭐ | 1 | 打10(13)，给1层星痕。耗1星→给2层 |
| 2 | **星噬(StarDevour)** ⭐ | 1 | 打5(7)。耗最多3星，每耗1星+3(4)伤 |
| 3 | **星谕(StarOracle)** ⭐ | 1 | 打7(10)，抽1(2)。耗2星→预见3(5) |
| 4 | **星蚀(StarEclipse)** ⭐ | 2 | 打14(20)。目标-2力。耗3星→+2(3)力+2敏 |
| 5 | **天命裁决(FateJudgment)** ⭐ | 2 | 打15(20)，叠2星。星>5→AOE8(10)；否则额外叠3(4)星 |
| 6 | **星咒(StarCurse)** ⭐ | 2 | 打10(12)，1(2)易。星>4→抽1(2)；星>8→+1(2)力 |
| 7 | **月镜星幻(MoonMirror)** ⭐ | 1 | AOE7(9)，给全敌1(2)星痕。耗3星→预见3 |
| 8 | **星绪(StarThread)** | 1 | 打11(16)。抽牌堆加1(2)张陨星(⬆陨星+) |
| 9 | **月海星镜(MoonSeaMirror)** ⭐ | 1 | AOE8(11)。预见3。耗4星→+2能 |
| 10 | **月衡星守(MoonBalance)** ⭐ | 1 | 打9(12)，防9(12)。耗3星→目标-2(3)力 |
| 11 | **月骸(StarMoonRecur)** ⭐ | 2 | 打24(30)。需耗4星。每打出一次本场永久-1费 |
| 12 | **燃星(BurnStar)** ⭐ | 1 | 打8(10)。给目标燃星debuff：每耗1星→失2(3)生命 |

### 4.4 攻击-稀有（Rare Attack, 8张）

| # | 卡牌 | 费 | 效果 |
|---|------|-----|------|
| 1 | **月轨(MoonTrail)** ⭐ | 3 | AOE5(6)。预见2(5)。耗3星→抽1(2)；再耗2星→下回合抽1(2)+1能 |
| 2 | **星骸(MoonRemains)** | 3(2) | 打 星数×4。星辰之力越高伤害越高 |
| 3 | **星流霆击(StarStream)** ⭐ | 3 | AOE3(6)×3。耗全部星，每耗1星+1次 |
| 4 | **星月天罚(StarMoonPunishment)** ⭐ | 3(2) | 打4(5)×3。耗全部星每星+1次。击杀后余段转AOE6(8) |
| 5 | **星启月穹(DivineMoon)** ⭐ | 3 | 打30(45)。耗2星→防14(19)；再耗4星→+2(3)力+2(3)敏 |
| 6 | **妄月破星(MadMoonBreak)** ⭐ | 6 | 打66(88)。每3星本回合-1费（实时更新） |
| 7 | **月绪星流(MoonThread)** | 1 | 抽2(2)，叠2(3)星 |
| 8 | **星月陨坠(StarMoonMeteor)** (古代) | 3 | AOE8(12)，叠2(3)星，给全敌1(2)星痕+1(2)易伤 |

### 4.5 技能-普通（Common Skill, 15张）

| # | 卡牌 | 费 | 效果 |
|---|------|-----|------|
| 1 | **聚星(GatherStar)** | 0 | 叠5(8)。消耗 |
| 2 | **引星(DrawStar)** | 1 | 防5(9)。抽牌堆加1(2)张陨星(⬆陨星+) |
| 3 | **星律(StarLaw)** | 1 | 获得星律Power：本回合每次消星→叠1(2)星 |
| 4 | **星蕴(StarAccumulate)** | 1 | 防7(10)，叠1(2)星 |
| 5 | **揽月(GraspMoon)** ⭐ | 0 | 抽3(4)。耗4(3)星 |
| 6 | **星曜(StarBright)** ⭐ | 1 | 防8(12)。耗4星→下回合防8(12) |
| 7 | **星荧(StarGlimmer)** | 1 | 防5(8)，叠2(3)星 |
| 8 | **星屑(StarDustSusabi)** | 1 | 抽2(3)。全敌本回合-1(2)力。叠2(3)星 |
| 9 | **月璋(MoonMedal)** | 1 | 叠3(5)星。若目标意图攻击→触发星爆；否则给1(2)易+1(2)虚 |
| 10 | **妄星(DelusionStar)** ⭐ | 1 | 选弃牌堆1张消耗，叠3(4)星。星<6→+1能 |
| 11 | **月影(MoonShadow)** | 1 | 防7(10)。从弃牌堆选1张牌回手 |
| 12 | **皓月天命(BrightMoonFate)** ⭐ | 1 | 下1(2)张星辰牌效果翻倍 |
| 13 | **垣月凝坚(SolidMoon)** ⭐ | 1 | 防14(17)。需耗4星，每缺1减2防 |
| 14 | **衍星望月(StarGazeMoon)** (古代) | 2(1) | 预见时抽1，预见后可选择耗1张手牌 |
| 15 | **月绪星流(MoonThread)** | 1 | 抽2(2)，叠2(3)星 |

### 4.6 技能-罕见（Uncommon Skill, 15张）

| # | 卡牌 | 费 | 效果 |
|---|------|-----|------|
| 1 | **星轮(StarWheel)** ⭐ | 0 | 耗3星→+2(3)能。再耗1星→下回合+1(2)能 |
| 2 | **月相(MoonPhase)** ⭐ | 1 | 预见3，抽2(3)。耗4星→+1能 |
| 3 | **星卜(StarDivine)** ⭐ | 1 | 防7(11)。预见2(3)。耗3星→防翻倍+抽2 |
| 4 | **月衍星续(MoonStarContinue)** ⭐ | 1 | 防8(8)。下回合叠3星+1能。星<7→叠5；星>7→+2能 |
| 5 | **星劫(StarRob)** ⭐ | 1 | 耗4星→目标本回合-2(3)力。星≥8→+1(2)力+1敏 |
| 6 | **星衍(StarTransform)** | 1 | 手牌/抽牌堆/弃牌堆各加1陨星(⬆陨星+)。每次打出本场-1费 |
| 7 | **凝月(MoonSolidity)** ⭐ | 1 | 耗4星→+2(3)力。再耗3星→+1(2)敏 |
| 8 | **月域星护(MoonShield)** ⭐ | 1 | 防8(12)，给全敌1星痕。耗1星→防额外+4(5)+星痕+1 |
| 9 | **月鉴星清(MoonFilter)** ⭐ | 1 | 防8(10)。预见2，抽3(4)。弃掉非星辰牌 |
| 10 | **月变星衍(MoonStarMutate)** ⭐ | 1 | 防7(9)。选抽牌堆1张变化为陨星(⬆陨星+)。按原牌类型获增益。星≥4→耗1星改选2张 |
| 11 | **繁星(ManyStars)** | 1 | 防9(11)。每3星额外+3(4)防（不耗星） |
| 12 | **月散星护(MoonStarGuard)** ⭐ | 2 | 耗全部星，每星4(5)防。格挡保留2回合 |
| 13 | **星环(StarRing)** ⭐ | 1 | 本回合消耗≥5星→+3(4)能 |
| 14 | **月蚀(MoonEclipse)** | 1 | 选抽牌堆1张牌变化为陨星(⬆陨星+) |
| 15 | **观命(ObserveFate)** | 2 | 接下来3(4)回合每回合开始预见3 |

### 4.7 技能-稀有（Rare Skill, 7张）

| # | 卡牌 | 费 | 效果 |
|---|------|-----|------|
| 1 | **星祭(StarRitual)** | 1 | 选手牌+抽牌堆各1张消耗。+1(2)能+防8(12)+叠2星 |
| 2 | **群星朝月(StarsGather)** | 3(2) | 抽4(5)。按抽到牌类型获增益。消耗(⬆去消耗) |
| 3 | **星演(StarEvolve)** ⭐ | 1 | 防6(9)。弃牌堆加1(2)陨星(⬆陨星+)。耗3星→给全敌1(2)星痕 |
| 4 | **星月同辉(StarMoonShine)** | 0 | 叠5(8)，+2(3)能，抽2(4)。消耗 |
| 5 | **月谕赦令(MoonPardon)** ⭐ | 2 | 防12(18)。耗4星→下回合第一张牌费用为0 |
| 6 | **大蛇逆鳞×50(SnakeScale)** 🌀 | 3(2) | 随机3张御魂选1张加入手牌免费打出。消耗。⬆御魂+ |
| 7 | **揽月(GraspMoon)** ⭐ | 0 | 抽3(4)。耗4(3)星 |

🌀 = 无色卡

### 4.8 能力牌（Power, 16张）

| # | 卡牌 | 费 | 稀有度 | 效果 |
|---|------|-----|--------|------|
| 1 | **星宿长明(StarHost)** | 1 | 罕见 | 叠2(3)星。每回合开始叠2(3)星 |
| 2 | **流星(Meteor)** | 2(1) | 罕见 | 每消耗6(5)星→+1能 |
| 3 | **星佑(StarGuard)** | 1 | 稀有 | 每次触发星效果（叠星/消星/星爆）→防4(6) |
| 4 | **星罗云布(StarCloud)** | 2 | 稀有 | 叠3(4)星。星≥3时敌方回合结束→未造成伤害的敌人触发星爆(⬆去消耗) |
| 5 | **星辰之境(StarRealm)** | 2 | 罕见 | 叠2(3)星。星>4→受到伤害-20%(30%) |
| 6 | **星临(StarApproach)** | 1(0) | 罕见 | 每回合开始给全敌1层星痕 |
| 7 | **天命(Fate)** | 3 | 稀有 | 星>8时抵消致命伤害，耗全部星每星回1(2)血。每战一次 |
| 8 | **清月涤厄(MoonCleanse)** | 2 | 罕见 | 星>4时每回合开始驱散1(2)个负面效果 |
| 9 | **辉月(ShineMoon)** | 1(0) | 罕见 | 每回合首次通过卡牌叠星→效果翻倍 |
| 10 | **星启(StarStart)** | 2 | 稀有 | +1能上限。回合开始耗2(1)星 |
| 11 | **月铭引曜(MoonInscribe)** | 2(1) | 罕见 | 每次预见→触发1次免费星爆 |
| 12 | **行月聚辰(MoonGather)** | 2(1) | 罕见 | 每打3张牌→叠1星 |
| 13 | **星魂(StarSoul)** | 1 | 稀有 | 每消耗5星→随机打3(4)+防4(5) |
| 14 | **月曜(MoonShine2)** | 1 | 稀有 | 每次有敌人死亡→叠3(4)星 |
| 15 | **星裂(StarBurstDouble)** | 2(1) | 罕见 | 星爆时额外触发1次 |
| 16 | **星辰(StarMorning)** | 1 | 罕见 | 每次预见→叠2(3)星 |
| 17 | **命星(FateStar)** | 1(0) | 罕见 | 所有预见效果+1 |
| 18 | **星月衍阵(StarMoonArray)** | 2 | 稀有 | 回合开始预见1(2)+抽1。按牌类型获增益(攻→AOE2(3)，技→防3(4)，能→+1能，其余→叠1(2)星) |

### 4.9 陨星（Token）

| 卡牌 | 费 | 类 | 效果 |
|------|-----|-----|------|
| **陨星(MeteorStar)** | 0 | 攻 | 打6(8)，叠1(2)星，抽1(2)。消耗 |

### 4.10 古代牌（Ancient）

| # | 卡牌 | 费 | 效果 |
|---|------|-----|------|
| 1 | **星月陨坠(StarMoonMeteor)** | 3 | AOE8(12)，叠2(3)星，给全敌1(2)星痕+1(2)易伤 |
| 2 | **占星望月(StarGazeMoon)** | 2(1) | 每次预见→抽1，预见后可选择消耗1张手牌 |

### 4.11 御魂牌（Souls, 20张）

全部为0费无色能力牌（CardRarity=Token）。通过事件、大蛇逆鳞、大蛇的鳞片药水、招福达摩等方式获得。

| # | 卡牌 | 效果 |
|---|------|------|
| 1 | **破势(BreakPotential)** | +1(2)力，每回合前2次攻击伤害+30%(45%) |
| 2 | **涂佛(BlackBuddha)** | +1(2)力+1(2)敏。打出攻击牌后本回合伤+15%(25%)；未打出则下回合+4(6)临时力 |
| 3 | **鸣屋(ChirpHouse)** | +1(2)力。目标每有1负面→伤害+10%(15%) |
| 4 | **被服(Beifu)** | +1(2)敏。受到伤害-15%(25%) |
| 5 | **网切(NetCut)** | +1(2)力。额外造成本次伤害20%(30%)的真伤 |
| 6 | **镜姬(MirrorHime)** | +2敏。受攻击50%反伤50%(75%)真伤 |
| 7 | **木魅(WoodSpirit)** | 每次被攻击→攻击方失去该伤害15%(20%)力量（含被格挡的伤害） |
| 8 | **凌波(Ripples)** | +1(2)力。回合结束→AOE真伤(本回合伤害×10%+力量值) + 回复(本回合伤害×10%) |
| 9 | **愿满夜(FullMoon)** | +1能上限。回合结束→随机真伤=能量值。每回合首张牌免费 |
| 10 | **如影(LikeShadow)** | +1(2)敏。回合结束→随机真伤=敏捷值。每回合首次失血→+1缓冲 |
| 11 | **招财猫(LuckyCat)** | +1能上限。回合开始随机：+2能/+2力/+2敏/免费消耗随机牌。⬆每回合+10金币 |
| 12 | **伤魂鸟(WoundSoul)** | 敌人死亡→回5(10)%最大生命+2力。战斗结束+2(3)最大生命 |
| 13 | **蚌精(ClamShell)** | +2(3)敏。回合开始+3(4)防。每2回合+1人工制品 |
| 14 | **遗念火(KeepFire)** | 回合开始随机1(2)张手牌-1(2)费 |
| 15 | **轮入道(Rinnendo)** | +1(2)力。回合开始随机1(2)张手牌加重放1 |
| 16 | **预言星盘(ProphetDisk)** | +1(2)力+1(2)敏。回合开始预见2(3)。预见时+3防+AOE3伤 |
| 17 | **涅槃之火(NirvanaFire)** | 每2回合回复5%(8%)最大生命 |
| 18 | **钟灵(BellGhost)** | +1(2)敏。每消耗4(3)能→击晕敌方全体 |
| 19 | **贝吹坊(Kaifukibo)** | +1(2)力。回合结束时无贝甲→+1贝甲；有贝甲→+1力 |
| 20 | **火之车(Hikuruma)** | +1(2)敏。每4(3)回合→获额外回合(+1抽牌+手牌-1费) |

---

## 五、遗物

### 5.1 初始遗物（Starter）

| 遗物 | 效果 |
|------|------|
| **星之护符(StarAmulet)** | 每场战斗开始获2星 |

### 5.2 Orobas升级遗物

| 遗物 | 稀有度 | 效果 |
|------|--------|------|
| **星月护符(StarMoonAmulet)** | Boss | 替换星之护符。战斗开始获4星+每回合开始获1星 |

### 5.3 普通遗物（Common）

| 遗物 | 效果 |
|------|------|
| **观星仪(StarScope)** | 回合开始预见1 |
| **聚星盘(StarDisk)** | 回合开始获2星 |

### 5.4 罕见遗物（Uncommon）

| 遗物 | 效果 |
|------|------|
| **玄天星诏(StarEdict)** | 战斗开始给全敌1层星痕 |
| **星灵戒指(StarSpiritRing)** | 战斗开始抽牌堆加3张陨星 |

### 5.5 稀有遗物（Rare）

| 遗物 | 效果 |
|------|------|
| **引星戒指(StarGuideRing)** | 每次星爆额外触发1次（实现IModifyStarBurstCount） |
| **星辰晶球(StarCrystalOrb)** | 每回合首次通过卡牌叠星→效果翻倍（效果同辉月） |

### 5.6 事件遗物（Special）

| 遗物 | 效果 |
|------|------|
| **星轨护符(StarOrbitAmulet)** | 每3回合获X防；每进3房间回X血 |
| **逆命星核(StarRebirthCore)** | 拾取失15HP。每次击败Boss→额外获1遗物+最大生命+X |

### 5.7 涅奥达摩（Neow Daruma, 4个, Ancient稀有度）

通过 Harmony 补丁等概率注入开局涅奥三选一（对所有角色生效）。

| 达摩 | 效果 |
|------|------|
| **招福达摩(LuckyDaruma)** 🔴 | 拾取→随机获1张御魂卡 |
| **大吉达摩(GreatLuckDaruma)** 🔵 | 每场战斗开始→随机获1张能力牌本回合免费打出 |
| **御行达摩(SkillDaruma)** ⚫ | 拾取→失全部金币+5HP。从普/罕/稀各选1张入牌组，再移除1张+升级1张 |
| **奉为达摩(GradeDaruma)** ⚪ | 拾取→-8最大生命。给每张打击/防御随机附1个附魔效果（18种选1） |

---

## 六、药水

### 6.1 普通（Common, 2个）

| 药水 | 目标 | 效果 |
|------|------|------|
| **陨星灵剂(MeteorSpiritPotion)** | 自身 | 抽牌堆加入3张陨星 |
| **聚星药水(StarGatherPotion)** | 自身 | 获5星 |

### 6.2 罕见（Uncommon, 3个）

| 药水 | 目标 | 效果 |
|------|------|------|
| **星痕药水(StarMarkPotion)** | 敌方 | 给目标敌人3层星痕 |
| **占星药水(AstrologyPotion)** | 自身 | 预见2，抽2 |
| **瓶装星爆(BottledStarBurst)** | 自身 | 触发3次免费星爆 |

### 6.3 稀有（Rare, 2个）

| 药水 | 目标 | 效果 |
|------|------|------|
| **大蛇的鳞片(OrochiScale)** | 自身 | 随机1张御魂加入手牌，本回合免费 |
| **星辉祝福药剂(StarBlessingPotion)** | 自身 | 下1张星辰牌效果翻倍（StarBlessingPower） |

---

## 七、附魔系统

奉为达摩给打击/防御牌随机附加18种效果。每张牌只随机1个效果。

### 7.1 属性修改类（不占附魔槽）

| 效果 | 描述 |
|------|------|
| 减费 | 永久-1费 |
| 重放 | BaseReplayCount+1 |
| 保留 | 添加Retain关键词 |
| 虚无 | 添加Ethereal关键词 |

### 7.2 自定义附魔（CustomEnchantmentModel, 4个）

| 附魔 | 文件 | 效果 |
|------|------|------|
| **倍化(DoubleValueEnchant)** | DoubleValueEnchant.cs | 伤害×2 + 格挡×2 |
| **生长(MomentumPlusEnchant)** | MomentumPlusEnchant.cs | 每打出+3伤害+3格挡（累加） |
| **先机(ImbuedAnyEnchant)** | ImbuedAnyEnchant.cs | 战斗开始自动免费打出 |
| **治疗(HealEnchant)** | HealEnchant.cs | 打出回3HP |

### 7.3 打出时给Buff附魔（OnPlayPowerEnchant, 9个）

| 附魔 | 施加Power | 数值 | 持续 |
|------|-----------|------|------|
| 临时力量 | TempStrengthUpPower | 3 | 临时 |
| 临时敏捷 | TempDexterityUpPower | 3 | 临时 |
| 临时集中 | TempFocusUpPower | 3 | 临时 |
| 永久力量 | StrengthPower | 2 | 永久+消耗 |
| 永久敏捷 | DexterityPower | 2 | 永久+消耗 |
| 永久集中 | FocusPower | 2 | 永久+消耗 |
| 荆棘 | ThornsPower | 3 | 永久+消耗 |
| 缓冲 | BufferPower | 1 | 永久+消耗 |
| 虚化 | IntangiblePower | 2 | 永久+消耗 |

---

## 八、关键词

| 关键词 | 枚举 | 说明 |
|--------|------|------|
| StarPower | `SusabiKeywords.StarPower` | 星辰之力：荒的核心资源 |
| StarMark | `SusabiKeywords.StarMark` | 星痕：敌方Debuff，被攻击回能 |
| StarIf | `SusabiKeywords.StarIf` | 星辰牌接口标记 |
| Scry | `SusabiKeywords.Scry` | 预见：复用观者Scry机制 |

---

## 九、技术架构

### 9.1 命名空间

- 代码：`susabi.Code.*`
- 资源：`res://Susabi/...`

### 9.2 核心文件

| 文件 | 说明 |
|------|------|
| `Code/Character/Susabi.cs` | 角色定义（HP、牌组、遗物、池） |
| `Code/Core/SusabiModel.cs` | 核心模型（星消耗追踪） |
| `Code/Core/SusabiHook.cs` | 事件钩子分发 |
| `Code/Core/SusabiSubscriber.cs` | 事件订阅 |
| `Code/Commands/StarPowerCmd.cs` | 星辰之力操作API |
| `Code/Commands/ScryCmd.cs` | 预见命令 |
| `Code/Events/SusabiInterfaces.cs` | 8个自定义事件接口 |
| `Code/Keywords/SusabiKeywords.cs` | 4个自定义关键词 |
| `Code/Abstract/SusabiCardModel.cs` | 卡牌基类 |

### 9.3 关键Harmony补丁

| 补丁 | 文件 | 说明 |
|------|------|------|
| ModifyDamageMultiplicative桥接 | `Patches/ModifyDamageMultiplicativeBridgePatch.cs` | BaseLib `CustomPowerModel` 的 `new virtual` 6参方法与游戏5参调用之间的桥接，确保所有伤害倍率Power生效 |
| 木魅力量削减 | `Patches/WoodSpiritRawDamagePatch.cs` | 挂6参 `CreatureCmd.Damage` 主方法，攻击后根据伤害扣攻击方力量 |
| 涅奥达摩注入 | `Patches/NeowDarumaPatch.cs` | Prefix重写 `Neow.GenerateInitialOptions`，等概率混入达摩选项 |
| RitsuLib net-id修复 | `Patches/RitsuLibNetIdFixPatch.cs` | 防止ModelId映射遗漏导致启动崩溃 |
| 免费打出不耗星 | `Patches/SetFreePatch.cs` (SusabiCardModel) | 设置ConsumeFree标记 |

### 9.4 御魂卡牌池（20张御魂）

```
Ripples, FullMoon, LikeShadow, LuckyCat, WoundSoul, ClamShell, KeepFire,
BreakPotential, MirrorHime, NetCut, Beifu, WoodSpirit, Rinnendo, NirvanaFire,
ProphetDisk, BellGhost, BlackBuddha, ChirpHouse, Kaifukibo, Hikuruma
```

---

## 十、开发进度

| 阶段 | 状态 |
|------|------|
| 基础框架（基类/接口/命令/关键词） | ✅ 完成 |
| 基础卡牌（打击/防御/星落/星月/陨星） | ✅ 完成 |
| 卡牌库（~85张） | ✅ 完成 |
| 遗物（13个含涅奥达摩） | ✅ 完成 |
| 药水（7个） | ✅ 完成 |
| 事件（改遗物/改牌/女子会/御魂3选1/命运抉择） | ✅ 完成 |
| 附魔系统（18种） | ✅ 完成 |
| Godot场景（8个） | ✅ 完成 |
| 卡牌原画 | ✅ 完成 |
| Power图标 | ✅ 完成 |
| 遗物图集 | ✅ 完成 |
| 动画/战斗模型 | ✅ 完成 |
| 本地化（命名/描述） | ✅ 完成 |

---

## 十一、参考路径

| 资源 | 路径 |
|------|------|
| 游戏源码 | `agent/sts2_agent/data/libs/sts2_decompiled/MegaCrit/sts2/Core/Models/` |
| 观者Mod | `stsmods/The watcher/Code/` |
| 观者本地化 | `stsmods/The watcher/Watcher/localization/zhs/` |
| 当前Mod代码 | `stsmods/susabi yys/Code/` |
| 当前Mod资源 | `stsmods/susabi yys/Susabi/` |
| BaseLib | BaseLib.dll（6参 `CustomPowerModel` 通过 Harmony 桥接） |


## 致谢

- **ZTMYkun** — Mod 作者
- **STS2 Modding 社区** — BaseLib / Harmony / BepInEx 框架
- **观者 Mod (The Watcher)** — C# Mod 开发参考

