-- chunkname: @./_assets/kr1-desktop/sounds/sounds.lua
local kr1 = {
    ArcaneRaySound = {
        loop = false,
        gain = 0.68,
        source_group = "SPECIALS",
        files = {"Sound_RayArcane.ogg"}
    },
    ArcherMusketeerShrapnelTaunt = {
        loop = false,
        gain = 0.6,
        source_group = "TAUNTS",
        files = {"Muskateer_Event1.ogg"}
    },
    ArcherMusketeerSniperTaunt = {
        loop = false,
        gain = 0.6,
        source_group = "TAUNTS",
        files = {"Muskateer_Snipe.ogg"}
    },
    ArcherMusketeerTaunt = {
        loop = false,
        mode = "sequence",
        gain = 0.6,
        source_group = "TAUNTS",
        files = {"Muskateer_Ready.ogg", "Muskateer_Event1.ogg", "Muskateer_Event2.ogg"}
    },
    ArcherRangerPoisonTaunt = {
        loop = false,
        gain = 0.6,
        source_group = "TAUNTS",
        files = {"Ranger_Taunt1.ogg"}
    },
    ArcherRangerTaunt = {
        loop = false,
        mode = "sequence",
        gain = 0.6,
        source_group = "TAUNTS",
        files = {"Ranger_Ready.ogg", "Ranger_Taunt1.ogg", "Ranger_Taunt2.ogg"}
    },
    ArcherRangerThornTaunt = {
        loop = false,
        gain = 0.6,
        source_group = "TAUNTS",
        files = {"Ranger_Taunt2.ogg"}
    },
    ArcherTaunt = {
        loop = false,
        gain = 0.6,
        ignore = 1.5,
        mode = "sequence",
        source_group = "TAUNTS",
        files = {"Archer_Ready.ogg", "Archer_Taunt1.ogg", "Archer_Taunt2.ogg"}
    },
    AreaAttack = {
        loop = false,
        gain = 1,
        source_group = "BULLETS",
        files = {"Sound_CommonAreaHit.ogg"}
    },
    ArrowSound = {
        loop = false,
        source_group = "BULLETS",
        files = {"Sound_ArrowRelease2.ogg", "Sound_ArrowRelease3.ogg"}
    },
    AxeSound = {
        loop = false,
        source_group = "BULLETS",
        files = {"Sound_BattleAxe.ogg"}
    },
    BarrackBarbarianDoubleAxesTaunt = {
        loop = false,
        gain = 0.6,
        source_group = "TAUNTS",
        files = {"Barbarian_Move.ogg"}
    },
    BarrackBarbarianTaunt = {
        loop = false,
        mode = "sequence",
        gain = 0.6,
        source_group = "TAUNTS",
        files = {"Barbarian_Ready.ogg", "Barbarian_Taunt1.ogg", "Barbarian_Taunt2.ogg", "Barbarian_Move.ogg"}
    },
    BarrackBarbarianThrowingAxesTaunt = {
        loop = false,
        gain = 0.6,
        source_group = "TAUNTS",
        files = {"Barbarian_Ready.ogg"}
    },
    BarrackBarbarianTwisterTaunt = {
        loop = false,
        gain = 0.6,
        source_group = "TAUNTS",
        files = {"Barbarian_Taunt1.ogg"}
    },
    BarrackPaladinHealingTaunt = {
        loop = false,
        gain = 0.6,
        source_group = "TAUNTS",
        files = {"Paladin_Ready.ogg"}
    },
    BarrackPaladinHolyStrikeTaunt = {
        loop = false,
        gain = 0.6,
        source_group = "TAUNTS",
        files = {"Paladin_Taunt1.ogg"}
    },
    BarrackPaladinShieldTaunt = {
        loop = false,
        gain = 0.6,
        source_group = "TAUNTS",
        files = {"Paladin_Taunt2.ogg"}
    },
    BarrackPaladinTaunt = {
        loop = false,
        mode = "sequence",
        gain = 0.6,
        source_group = "TAUNTS",
        files = {"Paladin_Ready.ogg", "Paladin_Taunt1.ogg", "Paladin_Taunt2.ogg", "Paladin_Move.ogg"}
    },
    BarrackTaunt = {
        loop = false,
        gain = 0.6,
        ignore = 1.5,
        mode = "sequence",
        source_group = "TAUNTS",
        files = {"Barrack_Ready.ogg", "Barrack_Taunt1.ogg", "Barrack_Taunt2.ogg", "Barrack_Move.ogg"}
    },
    BlackburnAmbienceBlackburn = {
        loop = false,
        gain = 0.8,
        source_group = "SFX",
        files = {"kr_ambience_cb_aquelarre.ogg", "halloween_werewolf_minormoans.ogg"}
    },
    BlackburnGhosts = {
        loop = false,
        gain = 0.8,
        source_group = "SFX",
        files = {"kr_ambience_cb_ghosts_1.ogg"}
    },
    BoltSorcererSound = {
        loop = false,
        gain = 0.68,
        source_group = "BULLETS",
        files = {"Sound_Sorcerer.ogg"}
    },
    BoltSound = {
        loop = false,
        gain = 0.68,
        source_group = "BULLETS",
        files = {"Sound_MageShot.ogg"}
    },
    BombExplosionSound = {
        loop = false,
        gain = 0.8,
        source_group = "EXPLOSIONS",
        files = {"Sound_Bomb1.ogg"}
    },
    BombShootSound = {
        loop = false,
        gain = 0.75,
        source_group = "EXPLOSIONS",
        files = {"Sound_EngineerShot.ogg"}
    },
    DeathBig = {
        loop = false,
        source_group = "DEATH",
        files = {"Sound_EnemyBigDead.ogg"}
    },
    DeathEplosion = {
        loop = false,
        gain = 0.4,
        source_group = "DEATH",
        files = {"Sound_EnemyExplode1.ogg"}
    },
    DeathGoblin = {
        loop = false,
        source_group = "DEATH",
        files = {"Sound_EnemyGoblinDead.ogg"}
    },
    DeathHuman = {
        loop = false,
        mode = "random",
        source_group = "DEATH",
        files = {"Sound_HumanDead1.ogg", "Sound_HumanDead2.ogg", "Sound_HumanDead3.ogg", "Sound_HumanDead4.ogg"}
    },
    DeathJuggernaut = {
        loop = false,
        gain = 0.9,
        source_group = "DEATH",
        files = {"Sound_JuggernautDeath.ogg"}
    },
    DeathOrc = {
        loop = false,
        source_group = "DEATH",
        files = {"Sound_EnemyOrcDead.ogg"}
    },
    DeathPuff = {
        loop = false,
        gain = 0.8,
        source_group = "DEATH",
        files = {"Sound_EnemyPuffDead.ogg"}
    },
    DeathSkeleton = {
        loop = false,
        source_group = "DEATH",
        files = {"Sound_EnemySkeletonBreak2.ogg"}
    },
    DeathTroll = {
        loop = false,
        source_group = "DEATH",
        files = {"Sound_EnemyTrollDead.ogg"}
    },
    DesintegrateSound = {
        loop = false,
        gain = 1,
        source_group = "SPECIALS",
        files = {"Sound_ArcaneDesintegrate.ogg"}
    },
    ElfTaunt = {
        loop = false,
        mode = "sequence",
        gain = 0.8,
        source_group = "TAUNTS",
        files = {"Elf_Taun1.ogg", "Elf_Taun2.ogg"}
    },
    ElfBleed = {
        loop = false,
        gain = 1,
        source_group = "TAUNTS",
        files = {"Elf_bleed.ogg"}
    },
    ElfCripple = {
        loop = false,
        gain = 1,
        source_group = "TAUNTS",
        files = {"Elf_cripple.ogg"}
    },
    EnemyBlackburnBossDeath = {
        loop = false,
        gain = 0.5,
        source_group = "SFX",
        files = {"kr_sfx_cb_lordblackburn_death.ogg"}
    },
    EnemyBlackburnBossSpecialStomp = {
        loop = false,
        gain = 0.5,
        source_group = "SFX",
        files = {"kr_sfx_cb_lordblackburn_specialstomp.ogg"}
    },
    EnemyBlackburnBossSwing = {
        loop = false,
        gain = 0.5,
        source_group = "SFX",
        files = {"kr_sfx_cb_lordblackburn_swing.ogg"}
    },
    EnemyBlackburnGiantRat = {
        loop = false,
        gain = 0.5,
        source_group = "SFX",
        files = {"kr_sfx_cb_giantrats1.ogg", "kr_sfx_cb_giantrats2.ogg"}
    },
    EnemyBlackburnWitch = {
        loop = false,
        gain = 0.5,
        source_group = "SFX",
        files = {"kr_sfx_cb_witch_fast.ogg", "kr_sfx_cb_witch_slow.ogg"}
    },
    EnemyBlackburnWitchDeath = {
        loop = false,
        gain = 0.5,
        source_group = "SFX",
        files = {"kr_sfx_cb_witchdeath.ogg"}
    },
    EnemyChieftain = {
        loop = false,
        gain = 0.6,
        source_group = "SFX",
        files = {"Sound_Chieftain.ogg"}
    },
    EnemyHealing = {
        loop = false,
        gain = 1,
        source_group = "SFX",
        files = {"Sound_EnemyHealing.ogg"}
    },
    EnemyInfernoBossDeath = {
        loop = false,
        gain = 0.9,
        source_group = "SFX",
        files = {"inferno_boss_death.ogg"}
    },
    EnemyInfernoHorns = {
        loop = false,
        gain = 0.9,
        source_group = "SFX",
        files = {"inferno_boss_horns.ogg"}
    },
    EnemyInfernoStomp = {
        loop = false,
        gain = 0.9,
        source_group = "SFX",
        files = {"inferno_boss_stomp.ogg"}
    },
    EnemyMushroomBorn = {
        loop = false,
        gain = 0.5,
        source_group = "SFX",
        files = {"KR_sfx_mushroomcreep_nacimiento.ogg"}
    },
    EnemyMushroomBossDeath = {
        loop = false,
        gain = 0.5,
        source_group = "SFX",
        files = {"KR_sfx_mushroomboss_muerte.ogg"}
    },
    EnemyMushroomDeath = {
        loop = false,
        gain = 0.5,
        source_group = "SFX",
        files = {"KR_sfx_mushroomcreep_muerte_edit_vanzen.ogg"}
    },
    EnemyMushroomGas = {
        loop = false,
        gain = 0.5,
        source_group = "SFX",
        files = {"KR_sfx_mushroomboss_gas_op1.ogg"}
    },
    EnemyRocketeer = {
        loop = false,
        gain = 0.6,
        source_group = "SFX",
        files = {"Sound_EnemyRocketeer.ogg"}
    },
    EngineerBfgClusterTaunt = {
        loop = false,
        gain = 0.6,
        source_group = "TAUNTS",
        files = {"BFG_Taunt1.ogg"}
    },
    EngineerBfgMissileTaunt = {
        loop = false,
        gain = 0.6,
        source_group = "TAUNTS",
        files = {"BFG_Taunt2.ogg"}
    },
    EngineerBfgTaunt = {
        loop = false,
        gain = 0.6,
        source_group = "TAUNTS",
        files = {"BFG_Ready.ogg"}
    },
    EngineerTaunt = {
        loop = false,
        gain = 0.6,
        ignore = 1.5,
        mode = "sequence",
        source_group = "TAUNTS",
        files = {"Artillery_Ready.ogg", "Artillery_Taunt1.ogg", "Artillery_Taunt2.ogg"}
    },
    EngineerTeslaChargedBoltTaunt = {
        loop = false,
        mode = "sequence",
        gain = 0.6,
        source_group = "TAUNTS",
        files = {"Tesla_Taunt2a.ogg", "Tesla_Taunt2b.ogg", "Tesla_Taunt2c.ogg"}
    },
    EngineerTeslaOverchargeTaunt = {
        loop = false,
        gain = 0.6,
        source_group = "TAUNTS",
        files = {"Tesla_Taunt1.ogg"}
    },
    EngineerTeslaTaunt = {
        loop = false,
        gain = 0.6,
        source_group = "TAUNTS",
        files = {"Tesla_Ready.ogg"}
    },
    ExtraBlackburnCrow = {
        loop = false,
        gain = 0.5,
        source_group = "SFX",
        files = {"kr_sfx_cb_crow.ogg"}
    },
    ExtraBlackburnNessie = {
        loop = false,
        gain = 0.5,
        source_group = "SFX",
        files = {"kr_sfx_cb_nessie.ogg"}
    },
    FireballHit = {
        loop = false,
        gain = 0.5,
        source_group = "SPECIALS",
        files = {"Sound_FireballHit.ogg"}
    },
    FireballRelease = {
        loop = false,
        gain = 0.5,
        source_group = "SPECIALS",
        files = {"Sound_FireballUnleash.ogg"}
    },
    GUIAchievementWin = {
        loop = false,
        gain = 1,
        source_group = "GUI",
        files = {"Sound_AchievementWin.ogg"}
    },
    GUIButtonCommon = {
        loop = false,
        gain = 1,
        source_group = "GUI",
        files = {"Sound_GUIButtonCommon.ogg"}
    },
    GUIBuyUpgrade = {
        loop = false,
        gain = 0.6,
        source_group = "GUI",
        files = {"Sound_GUIBuyUpgrade.ogg"}
    },
    GUICoins = {
        loop = false,
        gain = 1,
        source_group = "GUI",
        files = {"Sound_Coins.ogg"}
    },
    GUILooseLife = {
        loop = false,
        gain = 1,
        source_group = "GUI",
        files = {"Sound_LooseLife.ogg"}
    },
    GUIMapNewFlah = {
        loop = false,
        gain = 1,
        source_group = "GUI",
        files = {"Sound_MapNewFlag.ogg"}
    },
    GUINextWaveIncoming = {
        loop = false,
        gain = 1,
        source_group = "GUI",
        files = {"Sound_WaveIncoming.ogg"}
    },
    GUINextWaveReady = {
        loop = false,
        gain = 1,
        source_group = "GUI",
        files = {"Sound_NextWaveReady.ogg"}
    },
    GUINotificationClose = {
        loop = false,
        gain = 1,
        source_group = "GUI",
        files = {"Sound_NotificationClose.ogg"}
    },
    GUINotificationOpen = {
        loop = false,
        gain = 1,
        source_group = "GUI",
        files = {"Sound_NotificationOpen.ogg"}
    },
    GUINotificationPaperOver = {
        loop = false,
        gain = 1,
        source_group = "GUI",
        files = {"Sound_NotificationPaperOver.ogg"}
    },
    GUINotificationSecondLevel = {
        loop = false,
        gain = 0.8,
        source_group = "GUI",
        files = {"Sound_NotificationSecondLevel.ogg"}
    },
    GUIPlaceRallyPoint = {
        loop = false,
        gain = 0.8,
        source_group = "GUI",
        files = {"Sound_RallyPointPlaced.ogg"}
    },
    GUIQuestCompleted = {
        loop = false,
        gain = 1,
        source_group = "GUI",
        files = {"Sound_QuestCompleted.ogg"}
    },
    GUIQuestFailed = {
        loop = false,
        gain = 1,
        source_group = "GUI",
        files = {"Sound_QuestFailed.ogg"}
    },
    GUIQuickMenuOpen = {
        loop = false,
        gain = 1,
        source_group = "GUI",
        files = {"Sound_GUIOpenTowerMenu.ogg"}
    },
    GUIQuickMenuOver = {
        loop = false,
        gain = 1,
        source_group = "GUI",
        files = {"Sound_GUIMouseOverTowerIcon.ogg"}
    },
    GUISpellRefresh = {
        loop = false,
        gain = 1,
        source_group = "GUI",
        files = {"Sound_SpellRefresh.ogg"}
    },
    GUISpellSelect = {
        loop = false,
        gain = 1,
        source_group = "GUI",
        files = {"Sound_SpellSelect.ogg"}
    },
    GUITowerBuilding = {
        loop = false,
        gain = 1,
        source_group = "GUI",
        files = {"Sound_TowerBuilding.ogg"}
    },
    GUITowerOpenDoor = {
        loop = false,
        gain = 1,
        source_group = "GUI",
        files = {"Sound_TowerOpenDoor.ogg"}
    },
    GUITowerSell = {
        loop = false,
        gain = 1,
        source_group = "GUI",
        files = {"Sound_TowerSell.ogg"}
    },
    GUITransitionClose = {
        loop = false,
        gain = 1,
        source_group = "GUI",
        files = {"GUITransitionClose.ogg"}
    },
    GUITransitionOpen = {
        loop = false,
        gain = 1,
        source_group = "GUI",
        files = {"GUITransitionOpen.ogg"}
    },
    GUIWinStars = {
        loop = false,
        gain = 1,
        source_group = "GUI",
        files = {"Sound_WinStars.ogg"}
    },
    GuimapNewRoad = {
        loop = false,
        gain = 1,
        source_group = "GUI",
        files = {"Sound_MapRoad.ogg"}
    },
    HWAbominationExplosion = {
        loop = false,
        gain = 1,
        source_group = "SFX",
        files = {"halloween_abominationexplosion.ogg"}
    },
    HWAlphaWolf = {
        loop = false,
        gain = 1,
        source_group = "SFX",
        files = {"halloween_werewolf_alfawolf.ogg"}
    },
    HWGhosts = {
        loop = false,
        gain = 0.8,
        ignore = 10,
        source_group = "SFX",
        files = {"halloween_werewolf_minormoans.ogg"}
    },
    HWWerewolfTransformation = {
        loop = false,
        gain = 1,
        source_group = "SFX",
        files = {"halloween_werewolf_transformation.ogg"}
    },
    HealingSound = {
        loop = false,
        gain = 1,
        source_group = "SPECIALS",
        files = {"Sound_PaladinHeal.ogg"}
    },
    HeroArcherDeath = {
        loop = false,
        gain = 1,
        source_group = "TAUNTS",
        files = {"Female-Elven-Archer-Death_a.ogg"}
    },
    HeroArcherShoot = {
        loop = false,
        gain = 1,
        source_group = "BULLETS",
        files = {"Aleria_special_arrow.ogg"}
    },
    HeroArcherSummon = {
        loop = false,
        gain = 1,
        source_group = "BULLETS",
        files = {"Aleria_sumon.ogg"}
    },
    HeroArcherTaunt = {
        loop = false,
        gain = 1,
        ignore = 1,
        mode = "sequence",
        source_group = "TAUNTS",
        files = {"Female-Elven-Archer-04b.ogg", "Female-Elven-Archer-02c.ogg", "Female-Elven-Archer-03a.ogg",
                 "Female-Elven-Archer-01c.ogg"}
    },
    HeroArcherTauntIntro = {
        loop = false,
        gain = 1,
        source_group = "TAUNTS",
        files = {"Level_up.ogg"}
    },
    HeroArcherTauntSelect = {
        loop = false,
        gain = 1,
        source_group = "TAUNTS",
        files = {"Female-Elven-Archer-02c.ogg"}
    },
    HeroArcherWildCatHit = {
        loop = false,
        gain = 1,
        source_group = "BULLETS",
        files = {"Aleria_wildcat_hit.ogg"}
    },
    HeroDenasAttack = {
        loop = false,
        gain = 1,
        source_group = "TAUNTS",
        files = {"KingDenas_sfx_attack.ogg"}
    },
    HeroDenasBuff = {
        loop = false,
        mode = "sequence",
        gain = 1,
        source_group = "TAUNTS",
        files = {"KingDenas_sfx_order1.ogg", "KingDenas_sfx_order3.ogg"}
    },
    HeroDenasDeath = {
        loop = false,
        gain = 1,
        source_group = "TAUNTS",
        files = {"KingDenas-05c.ogg"}
    },
    HeroDenasTaunt = {
        loop = false,
        gain = 1,
        ignore = 1,
        mode = "sequence",
        source_group = "TAUNTS",
        files = {"KingDenas-04e.ogg", "KingDenas-02d.ogg", "KingDenas-03g.ogg", "KingDenas-01d.ogg"}
    },
    HeroDenasTauntIntro = {
        loop = false,
        gain = 1,
        source_group = "TAUNTS",
        files = {"Level_up.ogg"}
    },
    HeroDenasTauntSelect = {
        loop = false,
        gain = 1,
        source_group = "TAUNTS",
        files = {"KingDenas-04e.ogg"}
    },
    HeroFrostDeath = {
        loop = false,
        gain = 1,
        source_group = "TAUNTS",
        files = {"Frost-Mage-Death_01c.ogg"}
    },
    HeroFrostGroundFreeze = {
        loop = false,
        gain = 1,
        source_group = "TAUNTS",
        files = {"Elora_GroundFreeze.ogg"}
    },
    HeroFrostIceRainBreak = {
        loop = false,
        gain = 1,
        source_group = "TAUNTS",
        files = {"Elora_IceShardBreak.ogg"}
    },
    HeroFrostIceRainDrop = {
        loop = false,
        gain = 1,
        source_group = "TAUNTS",
        files = {"Elora_IceShard.ogg"}
    },
    HeroFrostIceRainSummon = {
        loop = false,
        gain = 1,
        source_group = "TAUNTS",
        files = {"Elora_IceShardSummon.ogg"}
    },
    HeroFrostTaunt = {
        loop = false,
        gain = 1,
        ignore = 1,
        mode = "sequence",
        source_group = "TAUNTS",
        files = {"Frost-Mage-04a.ogg", "Frost-Mage-03d.ogg", "Frost-Mage-02c.ogg", "Frost-Mage-01a.ogg"}
    },
    HeroFrostTauntIntro = {
        loop = false,
        gain = 1,
        source_group = "TAUNTS",
        files = {"Level_up.ogg"}
    },
    HeroFrostTauntSelect = {
        loop = false,
        gain = 1,
        source_group = "TAUNTS",
        files = {"Frost-Mage-01a.ogg"}
    },
    HeroLevelUp = {
        loop = false,
        gain = 1,
        source_group = "TAUNTS",
        files = {"Level_up.ogg"}
    },
    HeroMageDeath = {
        loop = false,
        gain = 1,
        source_group = "TAUNTS",
        files = {"Young-Mage-Death_c.ogg"}
    },
    HeroMageRainCharge = {
        loop = false,
        gain = 1,
        source_group = "BULLETS",
        files = {"Mage_blue_rain_charge.ogg"}
    },
    HeroMageRainDrop = {
        loop = false,
        gain = 1,
        source_group = "BULLETS",
        files = {"Mage_blue_rain_drop.ogg"}
    },
    HeroMageShadows = {
        loop = false,
        gain = 1,
        source_group = "BULLETS",
        files = {"Mage_shadows.ogg"}
    },
    HeroMageTaunt = {
        loop = false,
        gain = 1,
        ignore = 1,
        mode = "sequence",
        source_group = "TAUNTS",
        files = {"Young-Mage-04c.ogg", "Young-Mage-02a.ogg", "Young-Mage-03c.ogg", "Young-Mage-01d.ogg"}
    },
    HeroMageTauntIntro = {
        loop = false,
        gain = 1,
        source_group = "TAUNTS",
        files = {"Level_up.ogg"}
    },
    HeroMageTauntSelect = {
        loop = false,
        gain = 1,
        source_group = "TAUNTS",
        files = {"Young-Mage-02a.ogg"}
    },
    HeroPaladinDeath = {
        loop = false,
        gain = 1,
        source_group = "TAUNTS",
        files = {"Holy-Paladin-Death_b.ogg"}
    },
    HeroPaladinDeflect = {
        loop = false,
        gain = 1,
        source_group = "BULLETS",
        files = {"Paladin_deflect.ogg"}
    },
    HeroPaladinTaunt = {
        loop = false,
        gain = 1,
        ignore = 1,
        mode = "sequence",
        source_group = "TAUNTS",
        files = {"Holy-Paladin-04a.ogg", "Holy-Paladin-02c.ogg", "Holy-Paladin-03b.ogg", "Holy-Paladin-01c.ogg"}
    },
    HeroPaladinTauntIntro = {
        loop = false,
        gain = 1,
        source_group = "TAUNTS",
        files = {"Level_up.ogg"}
    },
    HeroPaladinTauntSelect = {
        loop = false,
        gain = 1,
        source_group = "TAUNTS",
        files = {"Holy-Paladin-01c.ogg"}
    },
    HeroPaladinValor = {
        loop = false,
        gain = 1,
        source_group = "BULLETS",
        files = {"Paladin_shield_buff.ogg"}
    },
    HeroRainOfFireArea = {
        loop = false,
        gain = 1,
        source_group = "BULLETS",
        files = {"Cinder_special_area.ogg"}
    },
    HeroRainOfFireDeath = {
        loop = false,
        gain = 1,
        source_group = "TAUNTS",
        files = {"Elemental-Death_c.ogg"}
    },
    HeroRainOfFireFireball1 = {
        loop = false,
        gain = 1,
        source_group = "BULLETS",
        files = {"Cinder_special_fireball_1_start.ogg"}
    },
    HeroRainOfFireFireball2 = {
        loop = false,
        gain = 1,
        source_group = "BULLETS",
        files = {"Cinder_special_fireball_2_end.ogg"}
    },
    HeroRainOfFireTaunt = {
        loop = false,
        gain = 1,
        ignore = 1,
        mode = "sequence",
        source_group = "TAUNTS",
        files = {"Elemental-01c.ogg", "Elemental-02c.ogg", "Elemental-03b.ogg", "Elemental-04c.ogg"}
    },
    HeroRainOfFireTauntIntro = {
        loop = false,
        gain = 1,
        source_group = "TAUNTS",
        files = {"Level_up.ogg"}
    },
    HeroRainOfFireTauntSelect = {
        loop = false,
        gain = 1,
        source_group = "TAUNTS",
        files = {"Elemental-01c.ogg"}
    },
    HeroReinforcementDeath = {
        loop = false,
        gain = 1,
        source_group = "TAUNTS",
        files = {"Reinforcement-Death_c.ogg"}
    },
    HeroReinforcementHit = {
        loop = false,
        gain = 1,
        source_group = "BULLETS",
        files = {"Motumbo_hit.ogg"}
    },
    HeroReinforcementJump = {
        loop = false,
        gain = 1,
        source_group = "BULLETS",
        files = {"Motumbo_jump_special.ogg"}
    },
    HeroReinforcementSpecial = {
        loop = false,
        gain = 1,
        source_group = "BULLETS",
        files = {"Motumbo_charge_special.ogg"}
    },
    HeroReinforcementTaunt = {
        loop = false,
        gain = 1,
        ignore = 1,
        mode = "sequence",
        source_group = "TAUNTS",
        files = {"Reinforcement-04b.ogg", "Reinforcement-02c.ogg", "Reinforcement-03c.ogg", "Reinforcement-01a.ogg"}
    },
    HeroReinforcementTauntIntro = {
        loop = false,
        gain = 1,
        source_group = "TAUNTS",
        files = {"Level_up.ogg"}
    },
    HeroReinforcementTauntSelect = {
        loop = false,
        gain = 1,
        source_group = "TAUNTS",
        files = {"Reinforcement-01a.ogg"}
    },
    HeroRiflemanBrea = {
        loop = false,
        gain = 1,
        source_group = "BULLETS",
        files = {"Dwarf_brea_shot2.ogg"}
    },
    HeroRiflemanBreaHit = {
        loop = false,
        gain = 1,
        source_group = "BULLETS",
        files = {"Dwarf_brea_shot_hit.ogg"}
    },
    HeroRiflemanDeath = {
        loop = false,
        gain = 1,
        source_group = "TAUNTS",
        files = {"Dwarf-Rifleman-Death_c.ogg"}
    },
    HeroRiflemanMine = {
        loop = false,
        gain = 1,
        source_group = "BULLETS",
        files = {"Dwarf_mine.ogg"}
    },
    HeroRiflemanTaunt = {
        loop = false,
        gain = 1,
        ignore = 1,
        mode = "sequence",
        source_group = "TAUNTS",
        files = {"Dwarf-Rifleman-04c.ogg", "Dwarf-Rifleman-02c.ogg", "Dwarf-Rifleman-03c.ogg", "Dwarf-Rifleman-01a.ogg"}
    },
    HeroRiflemanTauntIntro = {
        loop = false,
        gain = 1,
        source_group = "TAUNTS",
        files = {"Level_up.ogg"}
    },
    HeroRiflemanTauntSelect = {
        loop = false,
        gain = 1,
        source_group = "TAUNTS",
        files = {"Dwarf-Rifleman-01a.ogg"}
    },
    HeroRobotDeath = {
        loop = false,
        gain = 1,
        source_group = "TAUNTS",
        files = {"Hacksaw-Death01c.ogg"}
    },
    HeroRobotDrill = {
        loop = false,
        gain = 1,
        source_group = "TAUNTS",
        files = {"inferno_lumberjack_drill.ogg"}
    },
    HeroRobotShoot = {
        loop = false,
        gain = 1,
        source_group = "TAUNTS",
        files = {"inferno_lumberjack_shootSaw.ogg"}
    },
    HeroRobotTaunt = {
        loop = false,
        gain = 1,
        ignore = 1,
        mode = "sequence",
        source_group = "TAUNTS",
        files = {"Hacksaw-01c.ogg", "Hacksaw-02c.ogg", "Hacksaw-03a.ogg", "Hacksaw-04a.ogg"}
    },
    HeroRobotTauntIntro = {
        loop = false,
        gain = 1,
        source_group = "TAUNTS",
        files = {"Level_up.ogg"}
    },
    HeroRobotTauntSelect = {
        loop = false,
        gain = 1,
        source_group = "TAUNTS",
        files = {"Hacksaw-01c.ogg"}
    },
    HeroSamuraiDeath = {
        loop = false,
        gain = 1,
        source_group = "TAUNTS",
        files = {"Oni-Death01a.ogg"}
    },
    HeroSamuraiDeathStrike = {
        loop = false,
        gain = 1,
        source_group = "TAUNTS",
        files = {"inferno_oni_instakill.ogg"}
    },
    HeroSamuraiTaunt = {
        loop = false,
        gain = 1,
        ignore = 1,
        mode = "sequence",
        source_group = "TAUNTS",
        files = {"Oni-04a.ogg", "Oni-03c.ogg", "Oni-02c.ogg", "Oni-01c.ogg"}
    },
    HeroSamuraiTauntIntro = {
        loop = false,
        gain = 1,
        source_group = "TAUNTS",
        files = {"Level_up.ogg"}
    },
    HeroSamuraiTauntSelect = {
        loop = false,
        gain = 1,
        source_group = "TAUNTS",
        files = {"Oni-03c.ogg"}
    },
    HeroSamuraiTorment = {
        loop = false,
        gain = 1,
        source_group = "TAUNTS",
        files = {"inferno_oni_groundSwords.ogg"}
    },
    HeroThorDeath = {
        loop = false,
        gain = 1,
        source_group = "TAUNTS",
        files = {"Thor_05c.ogg", "KR_sfx_thor_muerte.ogg"}
    },
    HeroThorElectricAttack = {
        loop = false,
        gain = 1,
        source_group = "SPECIALS",
        files = {"KR_sfx_thor_ataqueelectrico.ogg"}
    },
    HeroThorHammer = {
        loop = false,
        gain = 1,
        source_group = "SPECIALS",
        files = {"KR_sfx_thor_lanzamartillo_op2.ogg"}
    },
    HeroThorTaunt = {
        loop = false,
        gain = 1,
        ignore = 1,
        mode = "sequence",
        source_group = "TAUNTS",
        files = {"Thor_01a.ogg", "Thor_02a.ogg", "Thor_03c.ogg", "Thor_04c.ogg"}
    },
    HeroThorTauntIntro = {
        loop = false,
        gain = 1,
        source_group = "TAUNTS",
        files = {"Level_up.ogg"}
    },
    HeroThorTauntSelect = {
        loop = false,
        gain = 1,
        source_group = "TAUNTS",
        files = {"Thor_01a.ogg"}
    },
    HeroThorThunder = {
        loop = false,
        gain = 1,
        source_group = "SPECIALS",
        files = {"KR_sfx_thor_thunder.ogg"}
    },
    HeroVikingAttackHit = {
        loop = false,
        gain = 1,
        source_group = "TAUNTS",
        files = {"Viking_Hit.ogg"}
    },
    HeroVikingBearAttackStart = {
        loop = false,
        gain = 1,
        source_group = "TAUNTS",
        files = {"Viking_StartAttack.ogg"}
    },
    HeroVikingBearTransform = {
        loop = false,
        gain = 1,
        source_group = "TAUNTS",
        files = {"Viking_Transform.ogg"}
    },
    HeroVikingCall = {
        loop = false,
        gain = 1,
        source_group = "TAUNTS",
        files = {"Viking_Call.ogg"}
    },
    HeroVikingDeath = {
        loop = false,
        gain = 1,
        source_group = "TAUNTS",
        files = {"Viking-Death_01d.ogg"}
    },
    HeroVikingTaunt = {
        loop = false,
        gain = 1,
        ignore = 1,
        mode = "sequence",
        source_group = "TAUNTS",
        files = {"Viking-01b.ogg", "Viking-03b.ogg", "Viking-02c.ogg", "Viking-01b.ogg"}
    },
    HeroVikingTauntIntro = {
        loop = false,
        gain = 1,
        source_group = "TAUNTS",
        files = {"Level_up.ogg"}
    },
    HeroVikingTauntSelect = {
        loop = false,
        gain = 1,
        source_group = "TAUNTS",
        files = {"Viking-01b.ogg"}
    },
    HitSound = {
        loop = false,
        gain = 0.15,
        source_group = "BULLETS",
        files = {"Sound_ArrowHit2.ogg", "Sound_ArrowHit3.ogg"}
    },
    InAppAtomicBomb = {
        loop = false,
        gain = 1,
        source_group = "SPECIALS",
        files = {"inapp_nuke.ogg"}
    },
    InAppAtomicBombFalling = {
        loop = false,
        gain = 1,
        source_group = "SPECIALS",
        files = {"inapp_nuke_falling.ogg"}
    },
    InAppAtomicFreezeEnd = {
        loop = false,
        gain = 1,
        source_group = "SPECIALS",
        files = {"inapp_atfreezeend.ogg"}
    },
    InAppAtomicFreezeStart = {
        loop = false,
        gain = 1,
        source_group = "SPECIALS",
        files = {"inapp_atfreezestart.ogg"}
    },
    InAppBuyGems = {
        loop = false,
        gain = 1,
        source_group = "SPECIALS",
        files = {"inapp_cash.ogg"}
    },
    InAppBuyInApp = {
        loop = false,
        gain = 1,
        source_group = "SPECIALS",
        files = {"inapp_chin.ogg"}
    },
    InAppEarnGems = {
        loop = false,
        gain = 1,
        source_group = "SPECIALS",
        files = {"inapp_gems.ogg"}
    },
    InAppExtraGold = {
        loop = false,
        gain = 1,
        source_group = "SPECIALS",
        files = {"inapp_gnome.ogg"}
    },
    InAppExtraHearts = {
        loop = false,
        gain = 1,
        source_group = "SPECIALS",
        files = {"inapp_hearts.ogg"}
    },
    InAppFreeze = {
        loop = false,
        gain = 1,
        source_group = "SPECIALS",
        files = {"inapp_freeze.ogg"}
    },
    JtAttack = {
        loop = false,
        gain = 1,
        source_group = "BULLETS",
        files = {"Sound_EnemyJtAttack.ogg"}
    },
    JtDeath = {
        loop = false,
        gain = 1,
        source_group = "BULLETS",
        files = {"Sound_EnemyJtDeath.ogg"}
    },
    JtEat = {
        loop = false,
        gain = 1,
        source_group = "BULLETS",
        files = {"Sound_EnemyJtEat.ogg"}
    },
    JtExplode = {
        loop = false,
        gain = 1,
        source_group = "BULLETS",
        files = {"Sound_EnemyJtExplode.ogg"}
    },
    JtHitIce = {
        loop = false,
        mode = "sequence",
        gain = 1,
        source_group = "SFX",
        files = {"Sound_HitIce1.ogg", "Sound_HitIce2.ogg", "Sound_HitIce3.ogg"}
    },
    JtRest = {
        loop = false,
        gain = 1,
        source_group = "BULLETS",
        files = {"Sound_EnemyJtRest.ogg"}
    },
    MageArcaneDesintegrateTaunt = {
        loop = false,
        gain = 0.6,
        source_group = "TAUNTS",
        files = {"Arcane_Taunt2.ogg"}
    },
    MageArcaneTaunt = {
        loop = false,
        gain = 0.6,
        source_group = "TAUNTS",
        files = {"Arcane_Ready.ogg"}
    },
    MageArcaneTeleporthTaunt = {
        loop = false,
        gain = 0.6,
        source_group = "TAUNTS",
        files = {"Arcane_Taunt1.ogg"}
    },
    MageSorcererAshesToAshesTaunt = {
        loop = false,
        gain = 0.6,
        source_group = "TAUNTS",
        files = {"Sorcerer_Taunt2.ogg"}
    },
    MageSorcererTaunt = {
        loop = false,
        mode = "sequence",
        gain = 0.6,
        source_group = "TAUNTS",
        files = {"Sorcerer_Ready.ogg", "Sorcerer_Taunt1.ogg", "Sorcerer_Taunt2.ogg"}
    },
    MageTaunt = {
        loop = false,
        gain = 0.6,
        ignore = 1.5,
        mode = "sequence",
        source_group = "TAUNTS",
        files = {"Mage_Ready.ogg", "Mage_Taunt1.ogg", "Mage_Taunt2.ogg"}
    },
    PirateBombShootSound = {
        loop = false,
        gain = 1,
        source_group = "EXPLOSIONS",
        files = {"Sound_EngineerShot.ogg"}
    },
    PolymorphSound = {
        loop = false,
        gain = 0.9,
        source_group = "SPECIALS",
        files = {"Sound_Polimorph.ogg"}
    },
    ReinforcementTaunt = {
        loop = false,
        mode = "sequence",
        gain = 0.6,
        source_group = "TAUNTS",
        files = {"Reinforcements_Event1.ogg", "Reinforcements_Event2.ogg", "Reinforcements_Event3.ogg",
                 "Reinforcements_Event4.ogg"}
    },
    RockElementalDeath = {
        loop = false,
        gain = 0.6,
        source_group = "TAUNTS",
        files = {"Sound_RockElementalDeath.ogg"}
    },
    RockElementalRally = {
        loop = false,
        gain = 0.6,
        source_group = "TAUNTS",
        files = {"Sound_RockElementalRally.ogg"}
    },
    RocketLaunchSound = {
        loop = false,
        gain = 0.8,
        source_group = "BULLETS",
        files = {"Sound_RocketLaunt.ogg"}
    },
    SasquashRally = {
        loop = false,
        gain = 0.8,
        source_group = "TAUNTS",
        files = {"Sound_TowerSoldierSasquashReady.ogg"}
    },
    SasquashReady = {
        loop = false,
        gain = 0.8,
        source_group = "TAUNTS",
        files = {"Sound_TowerSoldierSasquashRally.ogg"}
    },
    Sheep = {
        loop = false,
        gain = 0.6,
        ignore = 1.5,
        source_group = "TAUNTS",
        files = {"Sound_Sheep.ogg"}
    },
    ShotgunSound = {
        loop = false,
        source_group = "BULLETS",
        files = {"Sound_Shootgun.ogg"}
    },
    ShrapnelSound = {
        loop = false,
        source_group = "BULLETS",
        files = {"Sound_Shrapnel.ogg"}
    },
    SniperSound = {
        loop = false,
        source_group = "BULLETS",
        files = {"Sound_Sniper.ogg"}
    },
    SpiderAttack = {
        loop = false,
        gain = 0.6,
        ignore = 1.5,
        source_group = "BULLETS",
        files = {"Sound_SpiderAttack2.ogg"}
    },
    TeleporthSound = {
        loop = false,
        gain = 1,
        source_group = "SPECIALS",
        files = {"Sound_Teleport.ogg"}
    },
    TeslaAttack = {
        loop = false,
        gain = 0.6,
        source_group = "BULLETS",
        files = {"Sound_Tesla_attack_1.ogg", "Sound_Tesla_attack_2.ogg"}
    },
    ThornSound = {
        loop = false,
        gain = 0.8,
        source_group = "SPECIALS",
        files = {"Sound_Thorn.ogg"}
    },
    VeznanAttack = {
        loop = false,
        gain = 1,
        source_group = "BULLETS",
        files = {"Sound_EnemyVeznan_attack.ogg"}
    },
    VeznanDeath = {
        loop = false,
        gain = 1,
        source_group = "BULLETS",
        files = {"Sound_EnemyVeznan_death.ogg"}
    },
    VeznanDemonFire = {
        loop = false,
        gain = 1,
        source_group = "BULLETS",
        files = {"Sound_EnemyVeznan_demonFire.ogg"}
    },
    VeznanHoldCast = {
        loop = false,
        gain = 1,
        source_group = "BULLETS",
        files = {"Sound_SpellTowerHold_Cast.ogg"}
    },
    VeznanHoldDissipate = {
        loop = false,
        gain = 1,
        source_group = "BULLETS",
        files = {"Sound_SpellTowerHold_Dissipate.ogg"}
    },
    VeznanHoldHit = {
        loop = false,
        gain = 1,
        source_group = "BULLETS",
        files = {"Sound_SpellTowerHold_Hit.ogg"}
    },
    VeznanHoldTrap = {
        loop = false,
        gain = 1,
        source_group = "BULLETS",
        files = {"Sound_SpellTowerHold_Trap.ogg"}
    },
    VeznanPortalIn = {
        loop = false,
        gain = 1,
        source_group = "BULLETS",
        files = {"Sound_DemonPortal_Telein.ogg"}
    },
    VeznanPortalSummon = {
        loop = false,
        gain = 1,
        source_group = "BULLETS",
        files = {"Sound_DemonPortal_Summon.ogg"}
    },
    VeznanToDemon = {
        loop = false,
        gain = 1,
        source_group = "BULLETS",
        files = {"Sound_EnemyVeznan_toDemon.ogg"}
    },
    WolfAttack = {
        loop = false,
        gain = 0.6,
        ignore = 1.5,
        source_group = "BULLETS",
        files = {"Sound_WolfAttack.ogg", "Sound_WolfAttack2.ogg"}
    }
}

local kr2 = {
    AmazonTaunt = {
        loop = false,
        mode = "sequence",
        gain = 1,
        source_group = "TAUNTS",
        files = {"amazon_taunt_1.ogg", "amazon_taunt_2.ogg"}
    },
    ArcherTaunt = {
        loop = false,
        gain = 0.6,
        ignore = 1.5,
        mode = "sequence",
        source_group = "TAUNTS",
        files = {"Archer_Ready.ogg", "Archer_Taunt1.ogg", "Archer_Taunt2.ogg"}
    },
    ArchmageBoltSummon = {
        loop = false,
        gain = 0.5,
        source_group = "BULLETS",
        files = {"archmage_precharge.ogg"}
    },
    ArchmageBoltTravel = {
        loop = false,
        gain = 0.5,
        source_group = "BULLETS",
        files = {"archmage_attack.ogg"}
    },
    ArchmageCriticalExplosion = {
        loop = false,
        gain = 1,
        source_group = "BULLETS",
        files = {"archmage_explosion.ogg"}
    },
    ArchmageTaunt = {
        loop = false,
        mode = "sequence",
        gain = 0.8,
        source_group = "TAUNTS",
        files = {"archmage_taunt_ready.ogg", "archmage_taunt_explosion.ogg", "archmage_taunt_twister.ogg"}
    },
    ArchmageTauntExplosion = {
        loop = false,
        gain = 1,
        source_group = "TAUNTS",
        files = {"archmage_taunt_explosion.ogg"}
    },
    ArchmageTauntReady = {
        loop = false,
        gain = 0.8,
        source_group = "TAUNTS",
        files = {"archmage_taunt_ready.ogg"}
    },
    ArchmageTauntTwister = {
        loop = false,
        gain = 1,
        source_group = "TAUNTS",
        files = {"archmage_taunt_twister.ogg"}
    },
    ArchmageTwisterTravel = {
        loop = true,
        gain = 0.2,
        source_group = "SFX",
        files = {"archmage_twister.ogg"}
    },
    AreaAttack = {
        loop = false,
        gain = 1,
        source_group = "BULLETS",
        files = {"Sound_CommonAreaHit.ogg"}
    },
    ArrowSound = {
        loop = false,
        source_group = "BULLETS",
        files = {"Sound_ArrowRelease2.ogg", "Sound_ArrowRelease3.ogg"}
    },
    AssassinGold = {
        loop = false,
        gain = 0.6,
        source_group = "SPECIALS",
        files = {"assassin_gold.ogg"}
    },
    AssassinSneakAttack = {
        loop = false,
        gain = 0.3,
        source_group = "SPECIALS",
        files = {"assassin_sneakattack.ogg"}
    },
    AssassinTaunt = {
        loop = false,
        mode = "sequence",
        gain = 1,
        source_group = "TAUNTS",
        files = {"assassin_taunt_sneak.ogg", "assassin_taunt_gold.ogg", "assassin_taunt_counter.ogg",
                 "assassin_taunt_sneak.ogg"}
    },
    AssassinTauntCounter = {
        loop = false,
        gain = 1,
        source_group = "TAUNTS",
        files = {"assassin_taunt_counter.ogg"}
    },
    AssassinTauntGold = {
        loop = false,
        gain = 1,
        source_group = "TAUNTS",
        files = {"assassin_taunt_gold.ogg"}
    },
    AssassinTauntReady = {
        loop = false,
        gain = 1,
        source_group = "TAUNTS",
        files = {"assassin_taunt_counter.ogg"}
    },
    AssassinTauntSneak = {
        loop = false,
        gain = 1,
        source_group = "TAUNTS",
        files = {"assassin_taunt_sneak.ogg"}
    },
    AxeSound = {
        loop = false,
        source_group = "BULLETS",
        files = {"Sound_BattleAxe.ogg"}
    },
    BarrackTaunt = {
        loop = false,
        gain = 0.6,
        ignore = 1.5,
        mode = "sequence",
        source_group = "TAUNTS",
        files = {"Barrack_Ready.ogg", "Barrack_Taunt1.ogg", "Barrack_Taunt2.ogg", "Barrack_Move.ogg"}
    },
    BlackburnAmbienceBlackburn = {
        loop = false,
        gain = 0.8,
        source_group = "SFX",
        files = {"kr_ambience_cb_aquelarre.ogg", "halloween_werewolf_minormoans.ogg"}
    },
    BoltSorcererSound = {
        loop = false,
        gain = 0.68,
        source_group = "BULLETS",
        files = {"Sound_Sorcerer.ogg"}
    },
    BoltSound = {
        loop = false,
        gain = 0.68,
        source_group = "BULLETS",
        files = {"Sound_MageShot.ogg"}
    },
    BombExplosionSound = {
        loop = false,
        gain = 0.8,
        source_group = "EXPLOSIONS",
        files = {"Sound_Bomb1.ogg"}
    },
    BombShootSound = {
        loop = false,
        gain = 0.75,
        source_group = "EXPLOSIONS",
        files = {"Sound_EngineerShot.ogg"}
    },
    BossEfreetiClap = {
        loop = false,
        gain = 1,
        source_group = "SFX",
        files = {"boss_efreeti_clapping.ogg"}
    },
    BossEfreetiDeath = {
        loop = false,
        gain = 1,
        source_group = "SFX",
        files = {"boss_efreeti_death.ogg"}
    },
    BossEfreetiDoors = {
        loop = false,
        gain = 1,
        source_group = "SFX",
        files = {"efreeti_doors.ogg"}
    },
    BossEfreetiLaugh = {
        loop = false,
        gain = 0.8,
        source_group = "SFX",
        files = {"boss_efreeti_evillaugh.ogg"}
    },
    BossEfreetiSnap = {
        loop = false,
        gain = 1,
        source_group = "SFX",
        files = {"boss_efreeti_snapping.ogg"}
    },
    BossEfreetiSpawnBoss = {
        loop = false,
        gain = 1,
        source_group = "SFX",
        files = {"boss_efreeti_summon.ogg"}
    },
    BossEfreetiTowerReleased = {
        loop = false,
        gain = 1,
        source_group = "SFX",
        files = {"efreeti_towers_released.ogg"}
    },
    BossMonkeyChestPounding = {
        loop = false,
        gain = 1,
        source_group = "SFX",
        files = {"boss_mono_chestdrum.ogg"}
    },
    BossMonkeyDeath = {
        loop = false,
        gain = 1,
        source_group = "SFX",
        files = {"boss_mono_death.ogg"}
    },
    BossMonkeyFallSpawn = {
        loop = false,
        gain = 1,
        source_group = "SFX",
        files = {"boss_mono_enterscene.ogg"}
    },
    BossMonkeyJumpToTotem = {
        loop = false,
        gain = 1,
        source_group = "SFX",
        files = {"boss_mono_saltototem.ogg"}
    },
    BossMonkeySmashGround = {
        loop = false,
        gain = 1,
        source_group = "SFX",
        files = {"boss_mono_attack.ogg"}
    },
    BossMonkeyTotemSpawn = {
        loop = false,
        gain = 1,
        source_group = "SFX",
        files = {"boss_mono_totem.ogg"}
    },
    CanibalEating = {
        loop = false,
        gain = 0.6,
        source_group = "SFX",
        files = {"canibal_eating.ogg"}
    },
    CanibalNecromancer = {
        loop = false,
        gain = 0.6,
        source_group = "SFX",
        files = {"canibal_necromancer.ogg"}
    },
    CanibalZombie = {
        loop = false,
        gain = 0.8,
        ignore = 1,
        mode = "random",
        source_group = "SFX",
        files = {"canibal_zombie_one.ogg", "canibal_zombie_two.ogg", "canibal_zombie_three.ogg"}
    },
    CrossbowEagle = {
        loop = false,
        gain = 0.3,
        source_group = "SPECIALS",
        files = {"crossbow_eagle.ogg"}
    },
    CrossbowTaunt = {
        loop = false,
        mode = "sequence",
        gain = 0.8,
        source_group = "TAUNTS",
        files = {"crossbow_taunt_ready.ogg", "crossbow_taunt_eagle.ogg", "crossbow_taunt_multishot.ogg"}
    },
    CrossbowTauntEagle = {
        loop = false,
        gain = 0.8,
        source_group = "TAUNTS",
        files = {"crossbow_taunt_eagle.ogg"}
    },
    CrossbowTauntMultishoot = {
        loop = false,
        gain = 0.8,
        source_group = "TAUNTS",
        files = {"crossbow_taunt_multishot.ogg"}
    },
    CrossbowTauntReady = {
        loop = false,
        gain = 0.8,
        source_group = "TAUNTS",
        files = {"crossbow_taunt_ready.ogg"}
    },
    DeathBig = {
        loop = false,
        source_group = "DEATH",
        files = {"Sound_EnemyBigDead.ogg"}
    },
    DeathEplosion = {
        loop = false,
        gain = 0.4,
        source_group = "DEATH",
        files = {"Sound_EnemyExplode1.ogg"}
    },
    DeathGoblin = {
        loop = false,
        source_group = "DEATH",
        files = {"Sound_EnemyGoblinDead.ogg"}
    },
    DeathHuman = {
        loop = false,
        mode = "random",
        source_group = "DEATH",
        files = {"Sound_HumanDead1.ogg", "Sound_HumanDead2.ogg", "Sound_HumanDead3.ogg", "Sound_HumanDead4.ogg"}
    },
    DeathKnightTaunt = {
        loop = false,
        mode = "sequence",
        gain = 1,
        source_group = "TAUNTS",
        files = {"necromancer_deathknight_taunt_1.ogg", "necromancer_deathknight_taunt_2.ogg"}
    },
    DeathOrc = {
        loop = false,
        source_group = "DEATH",
        files = {"Sound_EnemyOrcDead.ogg"}
    },
    DeathPuff = {
        loop = false,
        gain = 0.8,
        source_group = "DEATH",
        files = {"Sound_EnemyPuffDead.ogg"}
    },
    DeathSkeleton = {
        loop = false,
        source_group = "DEATH",
        files = {"Sound_EnemySkeletonBreak2.ogg"}
    },
    DeathTroll = {
        loop = false,
        source_group = "DEATH",
        files = {"Sound_EnemyTrollDead.ogg"}
    },
    DwarfArcherTaunt = {
        loop = false,
        gain = 1,
        source_group = "TAUNTS",
        files = {"dwarfArcher_taunt_1.ogg", "dwarfArcher_taunt_2.ogg"}
    },
    DwarfHeroTaunt = {
        loop = false,
        gain = 1,
        ignore = 1,
        mode = "sequence",
        source_group = "TAUNTS",
        files = {"dwarfHero_taunt_confirm_1.ogg", "dwarfHero_taunt_confirm_2.ogg", "dwarfHero_taunt_confirm_3.ogg"}
    },
    DwarfHeroTauntSelect = {
        loop = false,
        gain = 1,
        source_group = "TAUNTS",
        files = {"dwarfHero_taunt_confirm_1.ogg"}
    },
    DwarfHeroTauntDeath = {
        loop = false,
        gain = 1,
        source_group = "TAUNTS",
        files = {"dwarfHero_taunt_death.ogg"}
    },
    DwarfTaunt = {
        loop = false,
        mode = "sequence",
        gain = 1,
        source_group = "TAUNTS",
        files = {"dwarf_taunt_1.ogg", "dwarf_taunt_2.ogg", "dwarfBarracks_taunt_1.ogg"}
    },
    EarthquakeAttack = {
        loop = false,
        gain = 1,
        source_group = "SPECIALS",
        files = {"dwaarp_attack.ogg"}
    },
    EarthquakeDrillIn = {
        loop = false,
        gain = 1,
        source_group = "SPECIALS",
        files = {"dwaarp_drillIn.ogg"}
    },
    EarthquakeDrillOut = {
        loop = false,
        gain = 1,
        source_group = "SPECIALS",
        files = {"dwaarp_drillOut.ogg"}
    },
    EarthquakeLavaSmash = {
        loop = false,
        gain = 1,
        source_group = "SPECIALS",
        files = {"dwaarp_lavaSmash.ogg"}
    },
    EarthquakeTaunt = {
        loop = false,
        mode = "sequence",
        gain = 0.8,
        source_group = "TAUNTS",
        files = {"earthquake_taunt_ready.ogg", "earthquake_taunt_drill.ogg", "earthquake_taunt_scorched.ogg"}
    },
    EarthquakeTauntDrill = {
        loop = false,
        gain = 0.8,
        source_group = "TAUNTS",
        files = {"earthquake_taunt_drill.ogg"}
    },
    EarthquakeTauntReady = {
        loop = false,
        gain = 0.8,
        source_group = "TAUNTS",
        files = {"earthquake_taunt_ready.ogg"}
    },
    EarthquakeTauntScorched = {
        loop = false,
        gain = 0.8,
        source_group = "TAUNTS",
        files = {"earthquake_taunt_scorched.ogg"}
    },
    ElvesAshbiteDeath = {
        loop = false,
        gain = 0.6,
        source_group = "SPECIALS",
        files = {"hero_dragon_death.ogg"}
    },
    ElvesAshbiteFireball = {
        loop = false,
        gain = 0.6,
        source_group = "SPECIALS",
        files = {"hero_dragon_fireball_explode.ogg"}
    },
    ElvesAshbiteFlameThrower = {
        loop = false,
        gain = 0.6,
        source_group = "SPECIALS",
        files = {"hero_dragon_flamethrower.ogg"}
    },
    ElvesAshbiteSmoke = {
        loop = false,
        gain = 0.6,
        source_group = "SPECIALS",
        files = {"hero_dragon_smoke.ogg"}
    },
    ElvesAshbiteSpit = {
        loop = false,
        gain = 0.6,
        source_group = "SPECIALS",
        files = {"hero_dragon_spit.ogg"}
    },
    ElvesHeroAlleriaTauntIntro = {
        loop = false,
        gain = 0.3,
        source_group = "TAUNTS",
        files = {"Level_up.ogg"}
    },
    ElvesHeroArivanTaunt = {
        loop = false,
        gain = 1,
        ignore = 1,
        mode = "sequence",
        source_group = "TAUNTS",
        files = {"Arivan_Confirm-01b.ogg", "Arivan_Confirm-02c.ogg", "Arivan_Confirm-03a.ogg",
                 "Arivan_Confirm04-01a.ogg"}
    },
    ElvesHeroArivanTauntIntro = {
        loop = false,
        gain = 1,
        source_group = "TAUNTS",
        files = {"Level_up.ogg"}
    },
    ElvesHeroArivanTauntSelect = {
        loop = false,
        gain = 1,
        source_group = "TAUNTS",
        files = {"Arivan_Confirm04-01a.ogg"}
    },
    ElvesHeroBolverkTauntIntro = {
        loop = false,
        gain = 1,
        source_group = "TAUNTS",
        files = {"Level_up.ogg"}
    },
    ElvesHeroBruceTaunt = {
        loop = false,
        gain = 1,
        ignore = 1,
        mode = "sequence",
        source_group = "TAUNTS",
        files = {"Bruce_confirm[2]-01b.ogg", "Bruce_confirm[2]-02c.ogg", "Bruce_confirm_03d.ogg",
                 "Bruce_confirm[2]-04c.ogg"}
    },
    ElvesHeroBruceTauntIntro = {
        loop = false,
        gain = 1,
        source_group = "TAUNTS",
        files = {"Level_up.ogg"}
    },
    ElvesHeroBruceTauntSelect = {
        loop = false,
        gain = 1,
        source_group = "TAUNTS",
        files = {"Bruce_confirm[2]-04c.ogg"}
    },
    ElvesHeroCathaTaunt = {
        loop = false,
        gain = 1,
        ignore = 1,
        mode = "sequence",
        source_group = "TAUNTS",
        files = {"Catha_Confirm-01c.ogg", "Catha_Confirm-02a.ogg", "Catha_Confirm-03c.ogg", "Catha_Confirm-04d.ogg"}
    },
    ElvesHeroCathaTauntIntro = {
        loop = false,
        gain = 1,
        source_group = "TAUNTS",
        files = {"Level_up.ogg"}
    },
    ElvesHeroCathaTauntSelect = {
        loop = false,
        gain = 1,
        source_group = "TAUNTS",
        files = {"Catha_Confirm-02a.ogg"}
    },
    ElvesHeroDenasTaunt = {
        loop = false,
        gain = 1,
        ignore = 1,
        mode = "sequence",
        source_group = "TAUNTS",
        files = {"PrinceDenas-confirm_01a.ogg", "PrinceDenas-confirm_02c.ogg", "PrinceDenas-confirm_03b.ogg",
                 "PrinceDenas-confirm_04a.ogg"}
    },
    ElvesHeroDenasTauntIntro = {
        loop = false,
        gain = 1,
        source_group = "TAUNTS",
        files = {"Level_up.ogg"}
    },
    ElvesHeroDenasTauntSelect = {
        loop = false,
        gain = 1,
        source_group = "TAUNTS",
        files = {"PrinceDenas-confirm_04a.ogg"}
    },
    ElvesHeroDuraxTaunt = {
        loop = false,
        gain = 1,
        ignore = 1,
        mode = "sequence",
        source_group = "TAUNTS",
        files = {"Durax_01a[wet].ogg", "Durax_02a[wet].ogg", "Durax_03a[wet].ogg", "Durax_04c[wet].ogg"}
    },
    ElvesHeroDuraxTauntIntro = {
        loop = false,
        gain = 1,
        source_group = "TAUNTS",
        files = {"Level_up.ogg"}
    },
    ElvesHeroDuraxTauntSelect = {
        loop = false,
        gain = 1,
        source_group = "TAUNTS",
        files = {"Durax_04c[wet].ogg"}
    },
    ElvesHeroEldritchTaunt = {
        loop = false,
        gain = 1,
        ignore = 1,
        mode = "sequence",
        source_group = "TAUNTS",
        files = {"Reg'son-confirm_01a.ogg", "Reg'son-confirm_02c.ogg", "Reg'son-confirm_03d.ogg",
                 "Reg'son-confirm_04a.ogg"}
    },
    ElvesHeroEldritchTauntIntro = {
        loop = false,
        gain = 1,
        source_group = "TAUNTS",
        files = {"Level_up.ogg"}
    },
    ElvesHeroEldritchTauntSelect = {
        loop = false,
        gain = 1,
        source_group = "TAUNTS",
        files = {"Reg'son-confirm_04a.ogg"}
    },
    ElvesHeroEridanTaunt = {
        loop = false,
        gain = 1,
        ignore = 1,
        mode = "sequence",
        source_group = "TAUNTS",
        files = {"Eridan_Confirm-01d.ogg", "Eridan_Confirm-03b.ogg", "Eridan_Confirm03-01a.ogg",
                 "Eridan_confirmextra-01a.ogg"}
    },
    ElvesHeroEridanTauntIntro = {
        loop = false,
        gain = 1,
        source_group = "TAUNTS",
        files = {"Level_up.ogg"}
    },
    ElvesHeroEridanTauntSelect = {
        loop = false,
        gain = 1,
        source_group = "TAUNTS",
        files = {"Eridan_Confirm-03b.ogg"}
    },
    ElvesHeroFaustusTaunt = {
        loop = false,
        gain = 1,
        ignore = 1,
        mode = "sequence",
        source_group = "TAUNTS",
        files = {"Faustus-confirm_04b2.ogg", "Faustus-confirm_02b2.ogg", "Faustus-confirm_03a2.ogg",
                 "Faustus-confirm_01b2.ogg"}
    },
    ElvesHeroFaustusTauntIntro = {
        loop = false,
        gain = 1,
        source_group = "TAUNTS",
        files = {"Level_up.ogg"}
    },
    ElvesHeroFaustusTauntSelect = {
        loop = false,
        gain = 1,
        source_group = "TAUNTS",
        files = {"Faustus-confirm_01b2.ogg"}
    },
    ElvesHeroForestElementalTaunt = {
        loop = false,
        gain = 1,
        ignore = 1,
        mode = "sequence",
        source_group = "TAUNTS",
        files = {"Bravebark-confirm_01c.ogg", "Bravebark-confirm_02b.ogg", "Bravebark-confirm_03d.ogg",
                 "Bravebark-confirm_04d.ogg"}
    },
    ElvesHeroForestElementalTauntIntro = {
        loop = false,
        gain = 1,
        source_group = "TAUNTS",
        files = {"Level_up.ogg"}
    },
    ElvesHeroForestElementalTauntSelect = {
        loop = false,
        gain = 1,
        source_group = "TAUNTS",
        files = {"Bravebark-confirm_04d.ogg"}
    },
    ElvesHeroGyroTaunt = {
        loop = false,
        gain = 1,
        ignore = 1,
        mode = "sequence",
        source_group = "TAUNTS",
        files = {"Gyro_confirm-01c.ogg", "Gyro_confirm-02c.ogg", "Gyro_confirm-03c.ogg", "Gyro_confirm-04b.ogg"}
    },
    ElvesHeroGyroTauntIntro = {
        loop = false,
        gain = 1,
        source_group = "TAUNTS",
        files = {"Level_up.ogg"}
    },
    ElvesHeroGyroTauntSelect = {
        loop = false,
        gain = 1,
        source_group = "TAUNTS",
        files = {"Gyro_confirm-01c.ogg"}
    },
    ElvesHeroLilithTaunt = {
        loop = false,
        gain = 1,
        ignore = 1,
        mode = "sequence",
        source_group = "TAUNTS",
        files = {"Lilith_confirm-01d[wet].ogg", "Lilith_confirm-02d[wet].ogg", "Lilith_confirm-03f[wet].ogg",
                 "Lilith_confirm-04a[wet].ogg"}
    },
    ElvesHeroLilithTauntIntro = {
        loop = false,
        gain = 1,
        source_group = "TAUNTS",
        files = {"Level_up.ogg"}
    },
    ElvesHeroLilithTauntSelect = {
        loop = false,
        gain = 1,
        source_group = "TAUNTS",
        files = {"Lilith_confirm-01d[wet].ogg"}
    },
    ElvesHeroLynnTaunt = {
        loop = false,
        gain = 1,
        ignore = 1,
        mode = "sequence",
        source_group = "TAUNTS",
        files = {"Lynn_confirm_01a.ogg", "Lynn_confirm_02c.ogg", "Lynn_confirm_03a.ogg", "Lynn_confirm_04d.ogg"}
    },
    ElvesHeroLynnTauntIntro = {
        loop = false,
        gain = 1,
        source_group = "TAUNTS",
        files = {"Level_up.ogg"}
    },
    ElvesHeroLynnTauntSelect = {
        loop = false,
        gain = 1,
        source_group = "TAUNTS",
        files = {"Lynn_confirm_01a.ogg"}
    },
    ElvesHeroPhoenixTaunt = {
        loop = false,
        gain = 0.8,
        ignore = 1,
        mode = "sequence",
        source_group = "TAUNTS",
        files = {"Phoenix2-death_01b.ogg", "Phoenix2-death_01a.ogg"}
    },
    ElvesHeroPhoenixTauntIntro = {
        loop = false,
        gain = 1,
        source_group = "TAUNTS",
        files = {"Level_up.ogg"}
    },
    ElvesHeroPhoenixTauntSelect = {
        loop = false,
        gain = 1,
        source_group = "TAUNTS",
        files = {"Phoenix2-death_01b.ogg"}
    },
    ElvesHeroRagTaunt = {
        loop = false,
        gain = 1,
        ignore = 1,
        mode = "sequence",
        source_group = "TAUNTS",
        files = {"RazzAndRags_01b.ogg", "RazzAndRags_02b.ogg", "RazzAndRags_03d.ogg", "RazzAndRags_04c.ogg"}
    },
    ElvesHeroRagTauntIntro = {
        loop = false,
        gain = 1,
        source_group = "TAUNTS",
        files = {"Level_up.ogg"}
    },
    ElvesHeroRagTauntSelect = {
        loop = false,
        gain = 1,
        source_group = "TAUNTS",
        files = {"RazzAndRags_02b.ogg"}
    },
    ElvesHeroVeznanTaunt = {
        loop = false,
        gain = 1,
        ignore = 1,
        mode = "sequence",
        source_group = "TAUNTS",
        files = {"Veznan-confirm_01e.ogg", "Veznan-confirm_02f.ogg", "Veznan-confirm_03_custom_fb.ogg",
                 "Veznan-confirm_04_custom_ec.ogg"}
    },
    ElvesHeroVeznanTauntIntro = {
        loop = false,
        gain = 1,
        source_group = "TAUNTS",
        files = {"Level_up.ogg"}
    },
    ElvesHeroVeznanTauntSelect = {
        loop = false,
        gain = 1,
        source_group = "TAUNTS",
        files = {"Veznan-confirm_03_custom_fb.ogg"}
    },
    ElvesHeroXinTaunt = {
        loop = false,
        gain = 1,
        ignore = 1,
        mode = "sequence",
        source_group = "TAUNTS",
        files = {"Xin-confirm_01c.ogg", "Xin-confirm_02b.ogg", "Xin-confirm_03a.ogg", "Xin-confirm_04c.ogg"}
    },
    ElvesHeroXinTauntIntro = {
        loop = false,
        gain = 1,
        source_group = "TAUNTS",
        files = {"Level_up.ogg"}
    },
    ElvesHeroXinTauntSelect = {
        loop = false,
        gain = 1,
        source_group = "TAUNTS",
        files = {"Xin-confirm_02b.ogg"}
    },
    EnemyHealing = {
        loop = false,
        gain = 1,
        source_group = "SFX",
        files = {"Sound_EnemyHealing.ogg"}
    },
    EngineerTaunt = {
        loop = false,
        gain = 0.6,
        ignore = 1.5,
        mode = "sequence",
        source_group = "TAUNTS",
        files = {"Artillery_Ready.ogg", "Artillery_Taunt1.ogg", "Artillery_Taunt2.ogg"}
    },
    FireballHit = {
        loop = false,
        gain = 0.5,
        source_group = "SPECIALS",
        files = {"Sound_FireballHit.ogg"}
    },
    FireballRelease = {
        loop = false,
        gain = 0.5,
        source_group = "SPECIALS",
        files = {"Sound_FireballUnleash.ogg"}
    },
    FrontiersEndlessToeeBossAcidGround = {
        loop = false,
        gain = 0.5,
        source_group = "SFX",
        files = {"krf_toee_alienqueen_acid[impact].ogg"}
    },
    FrontiersEndlessToeeBossAcidSpit = {
        loop = false,
        gain = 1,
        source_group = "SFX",
        files = {"krf_toee_aliengoddess_spit.ogg"}
    },
    FrontiersEndlessToeeBossScreech = {
        loop = false,
        gain = 1,
        source_group = "SFX",
        files = {"krf_toee_aliengoddess_screech[op3].ogg"}
    },
    FrontiersEndlessToeeBossSpawnEgg = {
        loop = false,
        gain = 1,
        source_group = "SFX",
        files = {"krf_toee_alienqueen_spawn.ogg"}
    },
    FrontiersEndlessToeeMiniBossAttack = {
        loop = false,
        gain = 0.5,
        source_group = "SFX",
        files = {"krf_toee_reaperlord_attack[op2].ogg"}
    },
    FrontiersEndlessToeeMiniBossDeath = {
        loop = false,
        gain = 0.8,
        source_group = "SFX",
        files = {"krf_toee_reaperlord_death.ogg"}
    },
    FrontiersFinalBossDeath = {
        loop = false,
        gain = 1,
        source_group = "TAUNTS",
        files = {"boss_umbra_death.ogg"}
    },
    FrontiersFinalBossExplode = {
        loop = false,
        gain = 1,
        source_group = "SFX",
        files = {"boss_umbra_explode.ogg"}
    },
    FrontiersFinalBossPiecesRegroup = {
        loop = false,
        gain = 1,
        source_group = "SFX",
        files = {"boss_umbra_sphere_join.ogg"}
    },
    FrontiersFinalBossPiecesRespawn = {
        loop = false,
        gain = 1,
        source_group = "SFX",
        files = {"boss_umbra_sphere_rise.ogg"}
    },
    FrontiersFinalBossPortal = {
        loop = false,
        gain = 1,
        source_group = "SFX",
        files = {"boss_umbra_openportal.ogg"}
    },
    FrontiersFinalBossRay = {
        loop = false,
        gain = 1,
        source_group = "SFX",
        files = {"boss_umbra_shootray.ogg"}
    },
    FrontiersFinalBossRayTower = {
        loop = false,
        gain = 1,
        source_group = "SFX",
        files = {"boss_umbra_tower.ogg"}
    },
    FrontiersFinalBossRespawn = {
        loop = false,
        gain = 1,
        source_group = "TAUNTS",
        files = {"boss_umbra_respawn.ogg"}
    },
    FrontiersFinalBossSpawnCrack = {
        loop = false,
        gain = 1,
        source_group = "SFX",
        files = {"boss_umbra_release_1.ogg"}
    },
    FrontiersFinalBossSpawnExplode = {
        loop = false,
        gain = 1,
        source_group = "SFX",
        files = {"boss_umbra_release_2.ogg"}
    },
    FrontiersFinalBossTeleport = {
        loop = false,
        gain = 1,
        source_group = "SFX",
        files = {"boss_umbra_teleport.ogg"}
    },
    GUIAchievementWin = {
        loop = false,
        gain = 1,
        source_group = "GUI",
        files = {"Sound_AchievementWin.ogg"}
    },
    GUIButtonCommon = {
        loop = false,
        gain = 1,
        source_group = "GUI",
        files = {"Sound_GUIButtonCommon.ogg"}
    },
    GUIBuyUpgrade = {
        loop = false,
        gain = 0.6,
        source_group = "GUI",
        files = {"Sound_GUIBuyUpgrade.ogg"}
    },
    GUICoins = {
        loop = false,
        gain = 1,
        source_group = "GUI",
        files = {"Sound_Coins.ogg"}
    },
    GUILooseLife = {
        loop = false,
        gain = 1,
        source_group = "GUI",
        files = {"Sound_LooseLife.ogg"}
    },
    GUIMapNewFlah = {
        loop = false,
        gain = 1,
        source_group = "GUI",
        files = {"Sound_MapNewFlag.ogg"}
    },
    GUINextWaveIncoming = {
        loop = false,
        gain = 1,
        source_group = "GUI",
        files = {"Sound_WaveIncoming.ogg"}
    },
    GUINextWaveReady = {
        loop = false,
        gain = 1,
        source_group = "GUI",
        files = {"Sound_NextWaveReady.ogg"}
    },
    GUINotificationClose = {
        loop = false,
        gain = 1,
        source_group = "GUI",
        files = {"Sound_NotificationClose.ogg"}
    },
    GUINotificationOpen = {
        loop = false,
        gain = 1,
        source_group = "GUI",
        files = {"Sound_NotificationOpen.ogg"}
    },
    GUINotificationPaperOver = {
        loop = false,
        gain = 1,
        source_group = "GUI",
        files = {"Sound_NotificationPaperOver.ogg"}
    },
    GUINotificationSecondLevel = {
        loop = false,
        gain = 0.8,
        source_group = "GUI",
        files = {"Sound_NotificationSecondLevel.ogg"}
    },
    GUIPlaceRallyPoint = {
        loop = false,
        gain = 0.8,
        source_group = "GUI",
        files = {"Sound_RallyPointPlaced.ogg"}
    },
    GUIQuestCompleted = {
        loop = false,
        gain = 1,
        source_group = "GUI",
        files = {"Sound_QuestCompleted.ogg"}
    },
    GUIQuestFailed = {
        loop = false,
        gain = 1,
        source_group = "GUI",
        files = {"Sound_QuestFailed.ogg"}
    },
    GUIQuickMenuOpen = {
        loop = false,
        gain = 1,
        source_group = "GUI",
        files = {"Sound_GUIOpenTowerMenu.ogg"}
    },
    GUIQuickMenuOver = {
        loop = false,
        gain = 1,
        source_group = "GUI",
        files = {"Sound_GUIMouseOverTowerIcon.ogg"}
    },
    GUISpellRefresh = {
        loop = false,
        gain = 1,
        source_group = "GUI",
        files = {"Sound_SpellRefresh.ogg"}
    },
    GUISpellSelect = {
        loop = false,
        gain = 1,
        source_group = "GUI",
        files = {"Sound_SpellSelect.ogg"}
    },
    GUITowerBuilding = {
        loop = false,
        gain = 1,
        source_group = "GUI",
        files = {"Sound_TowerBuilding.ogg"}
    },
    GUITowerOpenDoor = {
        loop = false,
        gain = 1,
        source_group = "GUI",
        files = {"Sound_TowerOpenDoor.ogg"}
    },
    GUITowerSell = {
        loop = false,
        gain = 1,
        source_group = "GUI",
        files = {"Sound_TowerSell.ogg"}
    },
    GUITransitionClose = {
        loop = false,
        gain = 1,
        source_group = "GUI",
        files = {"GUITransitionClose.ogg"}
    },
    GUITransitionOpen = {
        loop = false,
        gain = 1,
        source_group = "GUI",
        files = {"GUITransitionOpen.ogg"}
    },
    GUIWinStars = {
        loop = false,
        gain = 1,
        source_group = "GUI",
        files = {"Sound_WinStars.ogg"}
    },
    GenieTaunt = {
        loop = false,
        mode = "sequence",
        gain = 1,
        source_group = "TAUNTS",
        files = {"genie_taunt_1.ogg", "genie_taunt_2.ogg"}
    },
    GuimapNewRoad = {
        loop = false,
        gain = 1,
        source_group = "GUI",
        files = {"Sound_MapRoad.ogg"}
    },
    HWAbominationExplosion = {
        loop = false,
        gain = 1,
        source_group = "SFX",
        files = {"halloween_abominationexplosion.ogg"}
    },
    HWAlphaWolf = {
        loop = false,
        gain = 1,
        source_group = "SFX",
        files = {"halloween_werewolf_alfawolf.ogg"}
    },
    HWBossVampireDeath = {
        loop = false,
        gain = 1,
        source_group = "SPECIALS",
        files = {"halloween_vampireboss_death.ogg"}
    },
    HWBossVampireLifesteal = {
        loop = false,
        gain = 1,
        source_group = "SPECIALS",
        files = {"halloween_vampireboss_drainlife.ogg"}
    },
    HWCastleDoorsOpen = {
        loop = false,
        gain = 1,
        source_group = "SPECIALS",
        files = {"halloween_vampireboss_gates.ogg"}
    },
    HWFrankensteinChargeLightning = {
        loop = false,
        gain = 1,
        source_group = "SFX",
        files = {"halloween_tesla_charge.ogg"}
    },
    HWFrankensteinUpgradeFrankenstein = {
        loop = false,
        gain = 0.8,
        source_group = "SPECIALS",
        files = {"FrankyTower-02f.ogg"}
    },
    HWFrankensteinUpgradeLightning = {
        loop = false,
        gain = 0.8,
        source_group = "SPECIALS",
        files = {"FrankyTower-01d.ogg"}
    },
    HWGhosts = {
        loop = false,
        gain = 0.8,
        ignore = 10,
        source_group = "SFX",
        files = {"halloween_werewolf_minormoans.ogg"}
    },
    HWHeadlessHorsemanEntry = {
        loop = false,
        gain = 0.8,
        source_group = "SPECIALS",
        files = {"halloween_headless_sinrisa_conacorde.ogg"}
    },
    HWHeadlessHorsemanLaugh = {
        loop = false,
        gain = 0.8,
        source_group = "SPECIALS",
        files = {"HeadlessHorseman-03a_WET.ogg"}
    },
    HWPreMoon = {
        loop = false,
        gain = 1,
        source_group = "GUI",
        files = {"moon_test_4.ogg"}
    },
    HWVampiressAreaAttack = {
        loop = false,
        gain = 1,
        source_group = "SPECIALS",
        files = {"halloween_vampiress_areaattack_confilo.ogg"}
    },
    HWVampiressDeath = {
        loop = false,
        gain = 1,
        source_group = "SPECIALS",
        files = {"Vampiress-Death02c.ogg"}
    },
    HWVampiressLifesteal = {
        loop = false,
        gain = 1,
        source_group = "SPECIALS",
        files = {"halloween_vampiress_drainlifeOP2.ogg"}
    },
    HWWerewolfTransformation = {
        loop = false,
        gain = 1,
        source_group = "SFX",
        files = {"halloween_werewolf_transformation.ogg"}
    },
    HWZombieAmbient = {
        loop = false,
        gain = 0.6,
        ignore = 3,
        mode = "random",
        source_group = "SFX",
        files = {"canibal_zombie_one.ogg", "canibal_zombie_two.ogg", "canibal_zombie_three.ogg"}
    },
    HeroAlienAbduction = {
        loop = false,
        gain = 1,
        source_group = "SPECIALS",
        files = {"hero_alien_abduction.ogg"}
    },
    HeroAlienDeath = {
        loop = false,
        gain = 0.6,
        source_group = "TAUNTS",
        files = {"alien_taunt_death.ogg"}
    },
    HeroAlienDiscoBounce = {
        loop = false,
        gain = 1,
        source_group = "SPECIALS",
        files = {"hero_alien_disc_bounce.ogg"}
    },
    HeroAlienDiscoThrow = {
        loop = false,
        gain = 1,
        source_group = "SPECIALS",
        files = {"hero_alien_disc_throw.ogg"}
    },
    HeroAlienDrone = {
        loop = false,
        gain = 0.5,
        source_group = "SPECIALS",
        files = {"hero_alien_drone_call.ogg"}
    },
    HeroAlienDroneLeave = {
        loop = false,
        gain = 0.5,
        source_group = "SPECIALS",
        files = {"hero_alien_drone_leave.ogg"}
    },
    HeroAlienDroneLoop = {
        loop = true,
        gain = 0.5,
        source_group = "SPECIALS",
        files = {"hero_alien_drone_ray_loop.ogg"}
    },
    HeroAlienExplosion = {
        loop = false,
        gain = 1,
        source_group = "SPECIALS",
        files = {"hero_alien_death_explosion.ogg"}
    },
    HeroAlienTaunt = {
        loop = false,
        gain = 1,
        ignore = 1,
        mode = "sequence",
        source_group = "TAUNTS",
        files = {"alien_taunt_confirm_1.ogg", "alien_taunt_confirm_2.ogg", "alien_taunt_confirm_3.ogg",
                 "alien_taunt_confirm_4.ogg"}
    },
    HeroAlienTauntIntro = {
        loop = false,
        gain = 1,
        source_group = "TAUNTS",
        files = {"Level_up.ogg"}
    },
    HeroAlienTauntSelect = {
        loop = false,
        gain = 1,
        source_group = "TAUNTS",
        files = {"alien_taunt_confirm_4.ogg"}
    },
    HeroAlricDeath = {
        loop = false,
        gain = 0.6,
        source_group = "TAUNTS",
        files = {"alric_taunt_death.ogg"}
    },
    HeroAlricFlurry = {
        loop = false,
        gain = 1,
        source_group = "SPECIALS",
        files = {"hero_alric_flurry.ogg"}
    },
    HeroAlricSandwarrior = {
        loop = false,
        gain = 0.5,
        source_group = "SPECIALS",
        files = {"hero_alric_sandwarrior.ogg"}
    },
    HeroAlricTaunt = {
        loop = false,
        gain = 1,
        ignore = 1,
        mode = "sequence",
        source_group = "TAUNTS",
        files = {"alric_taunt_confirm_1.ogg", "alric_taunt_confirm_2.ogg", "alric_taunt_confirm_3.ogg",
                 "alric_taunt_confirm_4.ogg"}
    },
    HeroAlricTauntIntro = {
        loop = false,
        gain = 1,
        source_group = "TAUNTS",
        files = {"Level_up.ogg"}
    },
    HeroAlricTauntSelect = {
        loop = false,
        gain = 1,
        source_group = "TAUNTS",
        files = {"alric_taunt_confirm_2.ogg"}
    },
    HeroArcherTauntIntro = {
        loop = false,
        gain = 1,
        source_group = "TAUNTS",
        files = {"Level_up.ogg"}
    },
    HeroBeastMasterAttack = {
        loop = false,
        gain = 1,
        source_group = "SPECIALS",
        files = {"hero_cronan_whiplash.ogg"}
    },
    HeroBeastMasterBoarAttack = {
        loop = false,
        gain = 1,
        source_group = "SPECIALS",
        files = {"hero_beastmaster_jabali_attack2.ogg"}
    },
    HeroBeastMasterDeath = {
        loop = false,
        gain = 0.6,
        source_group = "TAUNTS",
        files = {"beastmaster_taunt_death.ogg"}
    },
    HeroBeastMasterFalconAttack = {
        loop = false,
        gain = 0.3,
        source_group = "SPECIALS",
        files = {"hero_beastmaster_bird_attack.ogg"}
    },
    HeroBeastMasterStampede = {
        loop = true,
        gain = 1,
        source_group = "SPECIALS",
        files = {"hero_beastmaster_rhino_stampede.ogg"}
    },
    HeroBeastMasterSummonBoar = {
        loop = false,
        gain = 1,
        source_group = "SPECIALS",
        files = {"hero_beastmaster_summon_boar.ogg"}
    },
    HeroBeastMasterSummonRhinos = {
        loop = false,
        gain = 1,
        source_group = "SPECIALS",
        files = {"hero_beastmaster_summon_rhino.ogg"}
    },
    HeroBeastMasterTaunt = {
        loop = false,
        gain = 1,
        ignore = 1,
        mode = "sequence",
        source_group = "TAUNTS",
        files = {"beastmaster_taunt_confirm_1.ogg", "beastmaster_taunt_confirm_2.ogg",
                 "beastmaster_taunt_confirm_3.ogg", "beastmaster_taunt_confirm_4.ogg"}
    },
    HeroBeastMasterTauntIntro = {
        loop = false,
        gain = 1,
        source_group = "TAUNTS",
        files = {"Level_up.ogg"}
    },
    HeroBeastMasterTauntSelect = {
        loop = false,
        gain = 1,
        source_group = "TAUNTS",
        files = {"beastmaster_taunt_confirm_3.ogg"}
    },
    HeroCrabBurrowIn = {
        loop = false,
        gain = 1,
        source_group = "SPECIALS",
        files = {"Hero_Karkinos_Burrow_in.ogg"}
    },
    HeroCrabBurrowOut = {
        loop = false,
        gain = 1,
        source_group = "SPECIALS",
        files = {"Hero_Karkinos_Burrow_out.ogg"}
    },
    HeroCrabCannon = {
        loop = false,
        gain = 1,
        source_group = "SPECIALS",
        files = {"Hero_Karkinos_Cannon.ogg"}
    },
    HeroCrabCannonExplosion = {
        loop = false,
        gain = 1,
        source_group = "SPECIALS",
        files = {"Hero_Karkinos_Cannon_explosion.ogg"}
    },
    HeroCrabDeath = {
        loop = false,
        gain = 1,
        source_group = "TAUNTS",
        files = {"Karkinos_Death.ogg"}
    },
    HeroCrabPrincer = {
        loop = false,
        gain = 1,
        source_group = "SPECIALS",
        files = {"Hero_Karkinos_Pincer.ogg"}
    },
    HeroCrabShield = {
        loop = false,
        gain = 1,
        source_group = "SPECIALS",
        files = {"Hero_Karkinos_Shield.ogg"}
    },
    HeroCrabTaunt = {
        loop = false,
        gain = 1,
        ignore = 1,
        mode = "sequence",
        source_group = "TAUNTS",
        files = {"Karkinos_01b.ogg", "Karkinos_02b.ogg", "Karkinos_03d.ogg", "Karkinos_04b.ogg"}
    },
    HeroCrabTauntIntro = {
        loop = false,
        gain = 1,
        source_group = "TAUNTS",
        files = {"Level_up.ogg"}
    },
    HeroCrabTauntSelect = {
        loop = false,
        gain = 1,
        source_group = "TAUNTS",
        files = {"Karkinos_03d.ogg"}
    },
    HeroDenasTauntIntro = {
        loop = false,
        gain = 1,
        source_group = "TAUNTS",
        files = {"Level_up.ogg"}
    },
    HeroDracolichAttack = {
        loop = false,
        gain = 1,
        source_group = "BULLETS",
        files = {"halloween_bonedragon_attack.ogg"}
    },
    HeroDracolichBoneRain = {
        loop = false,
        gain = 1,
        source_group = "BULLETS",
        files = {"halloween_bonedragon_bonerain.ogg"}
    },
    HeroDracolichDeath = {
        loop = false,
        gain = 1,
        source_group = "TAUNTS",
        files = {"Bonehart-Death01c_WET.ogg"}
    },
    HeroDracolichKamikaze = {
        loop = false,
        gain = 1,
        source_group = "SPECIALS",
        files = {"halloween_bonedragon_kamikaze2.ogg"}
    },
    HeroDracolichRespawn = {
        loop = false,
        gain = 1,
        source_group = "SPECIALS",
        files = {"halloween_bonedragon_respawn_simple.ogg"}
    },
    HeroDracolichSoulsPlague = {
        loop = false,
        gain = 1,
        source_group = "SPECIALS",
        files = {"halloween_bonedragon_soulsplague.ogg"}
    },
    HeroDracolichSpawnDog = {
        loop = false,
        gain = 1,
        source_group = "SPECIALS",
        files = {"halloween_bonedragon_spawn_congrowl.ogg"}
    },
    HeroDracolichTaunt = {
        loop = false,
        gain = 1,
        ignore = 1,
        mode = "sequence",
        source_group = "TAUNTS",
        files = {"Bonehart-01a_WET.ogg", "Bonehart-02b_WET.ogg", "Bonehart-03b_WET.ogg", "Bonehart-04c_WET.ogg"}
    },
    HeroDracolichTauntIntro = {
        loop = false,
        gain = 1,
        source_group = "TAUNTS",
        files = {"Level_up.ogg"}
    },
    HeroDracolichTauntSelect = {
        loop = false,
        gain = 1,
        source_group = "TAUNTS",
        files = {"Bonehart-02b_WET.ogg"}
    },
    HeroDragonAttackHit = {
        loop = false,
        gain = 1,
        source_group = "SPECIALS",
        files = {"hero_dragon_fireball_explode.ogg"}
    },
    HeroDragonAttackThrow = {
        loop = false,
        gain = 1,
        source_group = "SPECIALS",
        files = {"hero_dragon_spit.ogg"}
    },
    HeroDragonBorn = {
        loop = false,
        gain = 1,
        source_group = "SPECIALS",
        files = {"hero_dragon_birth.ogg"}
    },
    HeroDragonDeath = {
        loop = false,
        gain = 1,
        source_group = "TAUNTS",
        files = {"hero_dragon_death.ogg"}
    },
    HeroDragonFlame = {
        loop = false,
        gain = 1,
        source_group = "SPECIALS",
        files = {"hero_dragon_flamethrower.ogg"}
    },
    HeroDragonNapalm = {
        loop = false,
        gain = 1,
        source_group = "SPECIALS",
        files = {"hero_dragon_napalm.ogg"}
    },
    HeroDragonSmoke = {
        loop = false,
        gain = 1,
        source_group = "SPECIALS",
        files = {"hero_dragon_smoke.ogg"}
    },
    HeroDragonTaunt = {
        loop = false,
        gain = 1,
        ignore = 1,
        mode = "sequence",
        source_group = "TAUNTS",
        files = {"dragonHero_confirm1.ogg", "dragonHero_confirm2.ogg", "dragonHero_confirm3.ogg",
                 "dragonHero_confirm4.ogg"}
    },
    HeroDragonTauntIntro = {
        loop = false,
        gain = 1,
        source_group = "TAUNTS",
        files = {"Level_up.ogg"}
    },
    HeroDragonTauntSelect = {
        loop = false,
        gain = 1,
        source_group = "TAUNTS",
        files = {"dragonHero_confirm4.ogg"}
    },
    HeroFrostTauntIntro = {
        loop = false,
        gain = 1,
        source_group = "TAUNTS",
        files = {"Level_up.ogg"}
    },
    HeroGiantBoulder = {
        loop = false,
        gain = 1,
        source_group = "SPECIALS",
        files = {"hero_grawl_boulder_throw.ogg"}
    },
    HeroGiantDeath = {
        loop = false,
        gain = 0.6,
        source_group = "TAUNTS",
        files = {"giant_taunt_death.ogg"}
    },
    HeroGiantExplosionRock = {
        loop = false,
        gain = 1,
        source_group = "SPECIALS",
        files = {"hero_grawl_boulder_hit.ogg"}
    },
    HeroGiantMassiveDamage = {
        loop = false,
        gain = 1,
        source_group = "SPECIALS",
        files = {"hero_grawl_bigpunch.ogg"}
    },
    HeroGiantStomp = {
        loop = false,
        gain = 1,
        source_group = "SPECIALS",
        files = {"hero_grawl_stomp.ogg"}
    },
    HeroGiantTaunt = {
        loop = false,
        gain = 1,
        ignore = 1,
        mode = "sequence",
        source_group = "TAUNTS",
        files = {"giant_taunt_confirm_1.ogg", "giant_taunt_confirm_2.ogg", "giant_taunt_confirm_3.ogg",
                 "giant_taunt_confirm_4.ogg"}
    },
    HeroGiantTauntIntro = {
        loop = false,
        gain = 1,
        source_group = "TAUNTS",
        files = {"Level_up.ogg"}
    },
    HeroGiantTauntSelect = {
        loop = false,
        gain = 1,
        source_group = "TAUNTS",
        files = {"giant_taunt_confirm_4.ogg"}
    },
    HeroLevelUp = {
        loop = false,
        gain = 1,
        source_group = "TAUNTS",
        files = {"Level_up.ogg"}
    },
    HeroMageTauntIntro = {
        loop = false,
        gain = 1,
        source_group = "TAUNTS",
        files = {"Level_up.ogg"}
    },
    HeroMinotaurBloodAxe = {
        loop = false,
        gain = 1,
        source_group = "SPECIALS",
        files = {"KRF_sfx_minotauro_ataquefuerte.ogg"}
    },
    HeroMinotaurBullRush = {
        loop = false,
        gain = 1,
        source_group = "SPECIALS",
        files = {"KRF_sfx_minotauro_carga.ogg"}
    },
    HeroMinotaurDaedalusMaze = {
        loop = false,
        gain = 1,
        source_group = "SPECIALS",
        files = {"KRF_sfx_minotauro_portal.ogg"}
    },
    HeroMinotaurDeath = {
        loop = false,
        gain = 1,
        source_group = "TAUNTS",
        files = {"Minotaur_05e_death.ogg"}
    },
    HeroMinotaurDoomSpin = {
        loop = false,
        gain = 1,
        source_group = "SPECIALS",
        files = {"KRF_sfx_minotauro_remolino_2tiempo.ogg"}
    },
    HeroMinotaurRoarOfFury = {
        loop = false,
        gain = 1,
        source_group = "SPECIALS",
        files = {"KRF_sfx_minotauro_grito.ogg"}
    },
    HeroMinotaurTaunt = {
        loop = false,
        gain = 1,
        ignore = 1,
        mode = "sequence",
        source_group = "TAUNTS",
        files = {"Minotaur_01b.ogg", "Minotaur_02c.ogg", "Minotaur_03c.ogg", "Minotaur_04b.ogg"}
    },
    HeroMinotaurTauntIntro = {
        loop = false,
        gain = 1,
        source_group = "TAUNTS",
        files = {"Level_up.ogg"}
    },
    HeroMinotaurTauntSelect = {
        loop = false,
        gain = 1,
        source_group = "TAUNTS",
        files = {"Minotaur_04b.ogg"}
    },
    HeroMirageDeath = {
        loop = false,
        gain = 0.6,
        source_group = "TAUNTS",
        files = {"assassinHero_taunt_death"}
    },
    HeroMirageLethalStrikeCastHit = {
        loop = false,
        gain = 1,
        source_group = "SPECIALS",
        files = {"hero_mirage_lethalstrike_hit.ogg"}
    },
    HeroMirageLethalStrikeCastVanish = {
        loop = false,
        gain = 0.8,
        source_group = "SPECIALS",
        files = {"hero_mirage_lethalstrike_vanish.ogg"}
    },
    HeroMirageShadowDanceCast = {
        loop = false,
        gain = 1,
        source_group = "SPECIALS",
        files = {"hero_mirage_shadowdance_cast.ogg"}
    },
    HeroMirageShadowDanceHit = {
        loop = false,
        gain = 1,
        source_group = "SPECIALS",
        files = {"hero_mirage_shadowdance_hit.ogg"}
    },
    HeroMirageShadowDodge = {
        loop = false,
        gain = 1,
        source_group = "SPECIALS",
        files = {"hero_mirage_shadowdodge.ogg"}
    },
    HeroMirageShadowDodgePuff = {
        loop = false,
        gain = 1,
        source_group = "BULLETS",
        files = {"hero_mirage_shadowdodge_puff.ogg"}
    },
    HeroMirageTaunt = {
        loop = false,
        gain = 1,
        ignore = 1,
        mode = "sequence",
        source_group = "TAUNTS",
        files = {"assassinHero_taunt_confirm_1.ogg", "assassinHero_taunt_confirm_2.ogg",
                 "assassinHero_taunt_confirm_3.ogg", "assassinHero_taunt_confirm_4.ogg"}
    },
    HeroMirageTauntIntro = {
        loop = false,
        gain = 1,
        source_group = "TAUNTS",
        files = {"Level_up.ogg"}
    },
    HeroMirageTauntSelect = {
        loop = false,
        gain = 1,
        source_group = "TAUNTS",
        files = {"assassinHero_taunt_confirm_2.ogg"}
    },
    HeroMonkCounter = {
        loop = false,
        gain = 1,
        source_group = "SPECIALS",
        files = {"Hero_Monk_Counter.ogg"}
    },
    HeroMonkDeath = {
        loop = false,
        gain = 1,
        source_group = "TAUNTS",
        files = {"Monk_Death.ogg"}
    },
    HeroMonkFiredragon = {
        loop = false,
        gain = 1,
        source_group = "SPECIALS",
        files = {"Hero_Monk_Firedragon.ogg"}
    },
    HeroMonkHadoken = {
        loop = false,
        gain = 1,
        source_group = "SPECIALS",
        files = {"Hero_Monk_Hadoken.ogg"}
    },
    HeroMonkMultihitPunch = {
        loop = false,
        gain = 1,
        source_group = "SPECIALS",
        files = {"Hero_Monk_Multihit_punch.ogg"}
    },
    HeroMonkMultihitScreamOne = {
        loop = false,
        gain = 1,
        source_group = "SPECIALS",
        files = {"Hero_Monk_Multihit_scream_1.ogg"}
    },
    HeroMonkMultihitScreamTwo = {
        loop = false,
        gain = 1,
        source_group = "SPECIALS",
        files = {"Hero_Monk_Multihit_scream_2.ogg"}
    },
    HeroMonkSnakeAttack = {
        loop = false,
        gain = 1,
        source_group = "SPECIALS",
        files = {"Hero_Monk_Snake_attack.ogg"}
    },
    HeroMonkTaunt = {
        loop = false,
        gain = 1,
        ignore = 1,
        mode = "sequence",
        source_group = "TAUNTS",
        files = {"Monk_01c.ogg", "Monk_02b.ogg", "Monk_03c.ogg", "Monk_04b.ogg"}
    },
    HeroMonkTauntIntro = {
        loop = false,
        gain = 1,
        source_group = "TAUNTS",
        files = {"Level_up.ogg"}
    },
    HeroMonkTauntSelect = {
        loop = false,
        gain = 1,
        source_group = "TAUNTS",
        files = {"Monk_02b.ogg"}
    },
    HeroMonkeyGodAngryGodLoop = {
        loop = true,
        gain = 0.5,
        source_group = "SPECIALS",
        files = {"krf_toee_saitam_angrygod[flames-loop].ogg"}
    },
    HeroMonkeyGodAngryGodScream = {
        loop = false,
        gain = 1,
        source_group = "SFX",
        files = {"krf_toee_saitam_angrygod[scream].ogg"}
    },
    HeroMonkeyGodAttack1 = {
        loop = false,
        gain = 0.5,
        source_group = "SFX",
        files = {"krf_toee_saitam_attack[op1].ogg"}
    },
    HeroMonkeyGodAttack2 = {
        loop = false,
        gain = 0.5,
        source_group = "SFX",
        files = {"krf_toee_saitam_attack[op2].ogg"}
    },
    HeroMonkeyGodCloudDrop = {
        loop = false,
        gain = 0.1,
        source_group = "SFX",
        files = {"krf_toee_saitam_clouddrop.ogg"}
    },
    HeroMonkeyGodCloudJump = {
        loop = false,
        gain = 0.5,
        source_group = "SFX",
        files = {"krf_toee_saitam_cloudclimb_v2[op2].ogg"}
    },
    HeroMonkeyGodCloudWalkLoop = {
        loop = true,
        gain = 0.1,
        source_group = "SFX",
        files = {"krf_toee_saitam_cloudtransport.ogg"}
    },
    HeroMonkeyGodDeath = {
        loop = false,
        gain = 1,
        source_group = "TAUNTS",
        files = {"Saitam-death_01b[2].ogg"}
    },
    HeroMonkeyGodMonkeyPalm = {
        loop = false,
        gain = 1,
        source_group = "SFX",
        files = {"krf_toee_saitam_monkeypalm[op1].ogg"}
    },
    HeroMonkeyGodSpinningPoleLoop = {
        loop = true,
        gain = 1,
        source_group = "SPECIALS",
        files = {"krf_toee_saitam_polespin[loop].ogg"}
    },
    HeroMonkeyGodSpinningPoleLoopEnd = {
        loop = false,
        gain = 1,
        source_group = "SPECIALS",
        files = {"krf_toee_saitam_polespin[loop-end].ogg"}
    },
    HeroMonkeyGodTaunt = {
        loop = false,
        gain = 1,
        ignore = 1,
        mode = "sequence",
        source_group = "TAUNTS",
        files = {"Saitam-confirm_01b[2].ogg", "Saitam-confirm_02c[2].ogg", "Saitam_confirm-03c.ogg",
                 "Saitam_confirm-04c.ogg", "Saitam_confirm-05c.ogg"}
    },
    HeroMonkeyGodTauntIntro = {
        loop = false,
        gain = 1,
        source_group = "TAUNTS",
        files = {"Level_up.ogg"}
    },
    HeroMonkeyGodTauntSelect = {
        loop = false,
        gain = 1,
        source_group = "TAUNTS",
        files = {"Saitam-confirm_02c[2].ogg"}
    },
    HeroMonkeyGodTetsuboStorm = {
        loop = false,
        gain = 1,
        source_group = "SFX",
        files = {"krf_toee_saitam_tetsubostorm[op1].ogg"}
    },
    HeroPaladinTauntIntro = {
        loop = false,
        gain = 1,
        source_group = "TAUNTS",
        files = {"Level_up.ogg"}
    },
    HeroPirateDeath = {
        loop = false,
        gain = 0.6,
        source_group = "TAUNTS",
        files = {"blackthorne_taunt_death.ogg"}
    },
    HeroPirateExplosiveBarrel = {
        loop = false,
        gain = 1,
        source_group = "SPECIALS",
        files = {"hero_blackthorne_barrel.ogg"}
    },
    HeroPirateKraken = {
        loop = false,
        gain = 1,
        source_group = "SPECIALS",
        files = {"hero_blackthorne_kraken.ogg"}
    },
    HeroPirateTaunt = {
        loop = false,
        gain = 1,
        ignore = 1,
        mode = "sequence",
        source_group = "TAUNTS",
        files = {"blackthorne_taunt_confirm_1.ogg", "blackthorne_taunt_confirm_2.ogg",
                 "blackthorne_taunt_confirm_3.ogg", "blackthorne_taunt_confirm_4.ogg"}
    },
    HeroPirateTauntIntro = {
        loop = false,
        gain = 1,
        source_group = "TAUNTS",
        files = {"Level_up.ogg"}
    },
    HeroPirateTauntSelect = {
        loop = false,
        gain = 1,
        source_group = "TAUNTS",
        files = {"blackthorne_taunt_confirm_3.ogg"}
    },
    HeroPriestConsecrate = {
        loop = false,
        gain = 1,
        source_group = "SPECIALS",
        files = {"hero_priest_consecrate.ogg"}
    },
    HeroPriestDeath = {
        loop = false,
        gain = 0.6,
        source_group = "TAUNTS",
        files = {"priest_taunt_death.ogg"}
    },
    HeroPriestHolyLight = {
        loop = false,
        gain = 0.3,
        source_group = "SPECIALS",
        files = {"hero_priest_healing.ogg"}
    },
    HeroPriestTaunt = {
        loop = false,
        gain = 1,
        ignore = 1,
        mode = "sequence",
        source_group = "TAUNTS",
        files = {"priest_taunt_confirm_1.ogg", "priest_taunt_confirm_2.ogg", "priest_taunt_confirm_3.ogg",
                 "priest_taunt_confirm_4.ogg", "priest_taunt_confirm_5.ogg"}
    },
    HeroPriestTauntIntro = {
        loop = false,
        gain = 1,
        source_group = "TAUNTS",
        files = {"Level_up.ogg"}
    },
    HeroPriestTauntSelect = {
        loop = false,
        gain = 1,
        source_group = "TAUNTS",
        files = {"priest_taunt_confirm_5.ogg"}
    },
    HeroPriestWings = {
        loop = false,
        gain = 1,
        source_group = "SPECIALS",
        files = {"hero_priest_teleport.ogg"}
    },
    HeroRainOfFireTauntIntro = {
        loop = false,
        gain = 1,
        source_group = "TAUNTS",
        files = {"Level_up.ogg"}
    },
    HeroReinforcementTauntIntro = {
        loop = false,
        gain = 1,
        source_group = "TAUNTS",
        files = {"Level_up.ogg"}
    },
    HeroRiflemanTauntIntro = {
        loop = false,
        gain = 1,
        source_group = "TAUNTS",
        files = {"Level_up.ogg"}
    },
    HeroRobotTauntIntro = {
        loop = false,
        gain = 1,
        source_group = "TAUNTS",
        files = {"Level_up.ogg"}
    },
    HeroSamuraiTauntIntro = {
        loop = false,
        gain = 1,
        source_group = "TAUNTS",
        files = {"Level_up.ogg"}
    },
    HeroThorTauntIntro = {
        loop = false,
        gain = 1,
        source_group = "TAUNTS",
        files = {"Level_up.ogg"}
    },
    HeroVanHelsingDeath = {
        loop = false,
        gain = 1,
        source_group = "TAUNTS",
        files = {"Dante-Death01c.ogg"}
    },
    HeroVanHelsingHolyWater = {
        loop = false,
        gain = 1,
        source_group = "SPECIALS",
        files = {"halloween_helsing_holywater_conquemadura.ogg"}
    },
    HeroVanHelsingRelic = {
        loop = false,
        gain = 1,
        source_group = "SPECIALS",
        files = {"halloween_helsing_relic.ogg"}
    },
    HeroVanHelsingShotgun = {
        loop = false,
        gain = 1,
        source_group = "BULLETS",
        files = {"Sound_Sniper.ogg"}
    },
    HeroVanHelsingTaunt = {
        loop = false,
        gain = 1,
        ignore = 1,
        mode = "sequence",
        source_group = "TAUNTS",
        files = {"Dante-01a.ogg", "Dante-02a.ogg", "Dante-03a.ogg", "Dante-04d.ogg"}
    },
    HeroVanHelsingTauntIntro = {
        loop = false,
        gain = 1,
        source_group = "TAUNTS",
        files = {"Level_up.ogg"}
    },
    HeroVanHelsingTauntSelect = {
        loop = false,
        gain = 1,
        source_group = "TAUNTS",
        files = {"Dante-01a.ogg"}
    },
    HeroVikingTauntIntro = {
        loop = false,
        gain = 1,
        source_group = "TAUNTS",
        files = {"Level_up.ogg"}
    },
    HeroVoodooWitchAttack = {
        loop = false,
        gain = 1,
        source_group = "SPECIALS",
        files = {"KRF_sfx_vodoo_ataqueV3.ogg"}
    },
    HeroVoodooWitchDeath = {
        loop = false,
        gain = 1,
        source_group = "TAUNTS",
        files = {"Vodoo_05d.ogg"}
    },
    HeroVoodooWitchSacrificeHit = {
        loop = false,
        gain = 1,
        source_group = "SPECIALS",
        files = {"KRF_sfx_vodoo_kamikazegolpev3.ogg"}
    },
    HeroVoodooWitchSacrificeStart = {
        loop = false,
        gain = 1,
        source_group = "SPECIALS",
        files = {"KRF_sfx_vodoo_kamikazelanza.ogg"}
    },
    HeroVoodooWitchSkullAttack = {
        loop = false,
        gain = 0.3,
        source_group = "SPECIALS",
        files = {"KRF_sfx_vodoo_calaveraV3_op2.ogg"}
    },
    HeroVoodooWitchTaunt = {
        loop = false,
        gain = 1,
        ignore = 1,
        mode = "sequence",
        source_group = "TAUNTS",
        files = {"Vodoo_01c.ogg", "Vodoo_02b.ogg", "Vodoo_03b.ogg", "Vodoo_04b.ogg"}
    },
    HeroVoodooWitchTauntIntro = {
        loop = false,
        gain = 1,
        source_group = "TAUNTS",
        files = {"Level_up.ogg"}
    },
    HeroVoodooWitchTauntSelect = {
        loop = false,
        gain = 1,
        source_group = "TAUNTS",
        files = {"Vodoo_01c.ogg"}
    },
    HeroVoodooWitchVoodooMagic = {
        loop = false,
        gain = 1,
        source_group = "SPECIALS",
        files = {"KRF_sfx_vodoo_munieco.ogg"}
    },
    HeroWizardDeath = {
        loop = false,
        gain = 0.6,
        source_group = "TAUNTS",
        files = {"wizzard_taunt_death.ogg"}
    },
    HeroWizardDesintegrate = {
        loop = false,
        gain = 1,
        source_group = "SPECIALS",
        files = {"hero_nivus_desintegrate.ogg"}
    },
    HeroWizardMissileHit = {
        loop = false,
        gain = 0.5,
        source_group = "SPECIALS",
        files = {"hero_nivus_magicmissile_hit.ogg"}
    },
    HeroWizardMissileSummon = {
        loop = false,
        gain = 1,
        source_group = "SPECIALS",
        files = {"hero_nivus_magicmissile_summon.ogg"}
    },
    HeroWizardShoot = {
        loop = false,
        gain = 0.8,
        source_group = "SPECIALS",
        files = {"hero_nivus_attack.ogg"}
    },
    HeroWizardTaunt = {
        loop = false,
        gain = 1,
        ignore = 1,
        mode = "sequence",
        source_group = "TAUNTS",
        files = {"wizzard_taunt_confirm_1.ogg", "wizzard_taunt_confirm_2.ogg", "wizzard_taunt_confirm_3.ogg",
                 "wizzard_taunt_confirm_4.ogg"}
    },
    HeroWizardTauntIntro = {
        loop = false,
        gain = 1,
        source_group = "TAUNTS",
        files = {"Level_up.ogg"}
    },
    HeroWizardTauntSelect = {
        loop = false,
        gain = 1,
        source_group = "TAUNTS",
        files = {"wizzard_taunt_confirm_1.ogg"}
    },
    HeroWizardTeleport = {
        loop = false,
        gain = 1,
        source_group = "SPECIALS",
        files = {"hero_nivus_teleport.ogg"}
    },
    HitSound = {
        loop = false,
        gain = 0.15,
        source_group = "BULLETS",
        files = {"Sound_ArrowHit2.ogg", "Sound_ArrowHit3.ogg"}
    },
    InAppAtomicBomb = {
        loop = false,
        gain = 1,
        source_group = "SPECIALS",
        files = {"inapp_nuke.ogg"}
    },
    InAppAtomicBombFalling = {
        loop = false,
        gain = 1,
        source_group = "SPECIALS",
        files = {"inapp_nuke_falling.ogg"}
    },
    InAppAtomicFreezeEnd = {
        loop = false,
        gain = 1,
        source_group = "SPECIALS",
        files = {"inapp_atfreezeend.ogg"}
    },
    InAppAtomicFreezeStart = {
        loop = false,
        gain = 1,
        source_group = "SPECIALS",
        files = {"inapp_atfreezestart.ogg"}
    },
    InAppBuyGems = {
        loop = false,
        gain = 1,
        source_group = "SPECIALS",
        files = {"inapp_cash.ogg"}
    },
    InAppBuyInApp = {
        loop = false,
        gain = 1,
        source_group = "SPECIALS",
        files = {"inapp_chin.ogg"}
    },
    InAppEarnGems = {
        loop = false,
        gain = 1,
        source_group = "SPECIALS",
        files = {"inapp_gems.ogg"}
    },
    InAppExtraGold = {
        loop = false,
        gain = 1,
        source_group = "SPECIALS",
        files = {"inapp_gnome.ogg"}
    },
    InAppExtraHearts = {
        loop = false,
        gain = 1,
        source_group = "SPECIALS",
        files = {"inapp_hearts.ogg"}
    },
    InAppFreeze = {
        loop = false,
        gain = 1,
        source_group = "SPECIALS",
        files = {"inapp_freeze.ogg"}
    },
    JungleAmbienceSound = {
        loop = false,
        gain = 0.1,
        source_group = "SFX",
        files = {"jungle_1.ogg"}
    },
    LegionnaireTaunt = {
        loop = false,
        mode = "sequence",
        gain = 1,
        source_group = "TAUNTS",
        files = {"legionnaire_taunt_2.ogg", "legionnaire_taunt_1.ogg"}
    },
    Level1SpecialEndingCinematic = {
        loop = false,
        gain = 1,
        source_group = "SFX",
        files = {"boss_cinematic.ogg"}
    },
    Level1SpecialEndingHoldCast = {
        loop = false,
        gain = 1,
        source_group = "SFX",
        files = {"Sound_SpellTowerHold_Cast.ogg"}
    },
    Level1SpecialEndingHoldDissipate = {
        loop = false,
        gain = 1,
        source_group = "SFX",
        files = {"Sound_SpellTowerHold_Dissipate.ogg"}
    },
    MageTaunt = {
        loop = false,
        gain = 0.6,
        ignore = 1.5,
        mode = "sequence",
        source_group = "TAUNTS",
        files = {"Mage_Ready.ogg", "Mage_Taunt1.ogg", "Mage_Taunt2.ogg"}
    },
    MechOil = {
        loop = false,
        gain = 0.8,
        source_group = "SPECIALS",
        files = {"mecha_dropoil.ogg"}
    },
    MechSpawn = {
        loop = false,
        gain = 0.8,
        source_group = "SPECIALS",
        files = {"mecha_spawn.ogg"}
    },
    MechSteam = {
        loop = false,
        gain = 0.2,
        source_group = "SPECIALS",
        files = {"mecha_steamrelease.ogg"}
    },
    MechTaunt = {
        loop = false,
        mode = "sequence",
        gain = 0.8,
        source_group = "TAUNTS",
        files = {"mecha_taunt_ready.ogg", "mecha_taunt_misc.ogg", "mecha_taunt_missile.ogg", "mecha_taunt_slow.ogg"}
    },
    MechTauntMisc = {
        loop = false,
        gain = 0.8,
        source_group = "TAUNTS",
        files = {"mecha_taunt_misc.ogg"}
    },
    MechTauntMissile = {
        loop = false,
        gain = 0.8,
        source_group = "TAUNTS",
        files = {"mecha_taunt_missile.ogg"}
    },
    MechTauntReady = {
        loop = false,
        gain = 0.8,
        source_group = "TAUNTS",
        files = {"mecha_taunt_ready.ogg"}
    },
    MechTauntSlow = {
        loop = false,
        gain = 0.8,
        source_group = "TAUNTS",
        files = {"mecha_taunt_slow.ogg"}
    },
    MechWalk = {
        loop = true,
        gain = 0.2,
        source_group = "SPECIALS",
        files = {"mecha_walk.ogg"}
    },
    NecromancerBolt = {
        loop = false,
        gain = 0.3,
        source_group = "BULLETS",
        files = {"necromancer_attack.ogg"}
    },
    NecromancerPestilence = {
        loop = false,
        gain = 0.3,
        source_group = "SPECIALS",
        files = {"necromancer_pestilence.ogg"}
    },
    NecromancerSummon = {
        loop = false,
        gain = 0.3,
        source_group = "BULLETS",
        files = {"mecromancer_summon.ogg"}
    },
    NecromancerTaunt = {
        loop = false,
        mode = "sequence",
        gain = 0.9,
        source_group = "TAUNTS",
        files = {"necromancer_taunt_ready.ogg", "necromancer_taunt_dknight.ogg", "necromancer_taunt_pesti.ogg"}
    },
    NecromancerTauntDeath_Knight = {
        loop = false,
        gain = 1,
        source_group = "TAUNTS",
        files = {"necromancer_taunt_dknight.ogg"}
    },
    NecromancerTauntPestilence = {
        loop = false,
        gain = 0.9,
        source_group = "TAUNTS",
        files = {"necromancer_taunt_pesti.ogg"}
    },
    NecromancerTauntReady = {
        loop = false,
        gain = 0.9,
        source_group = "TAUNTS",
        files = {"necromancer_taunt_ready.ogg"}
    },
    PirateBigTaunt = {
        loop = false,
        mode = "sequence",
        gain = 1,
        source_group = "TAUNTS",
        files = {"Pirate_Big_01c.ogg", "Pirate_Big_02c.ogg"}
    },
    PirateBoatTaunt = {
        loop = false,
        gain = 1,
        ignore = 1,
        mode = "sequence",
        source_group = "TAUNTS",
        files = {"PirateBoat_01c.ogg", "PirateBoat_02c.ogg", "PirateBoat_03a.ogg"}
    },
    PirateBoatTauntIntro = {
        loop = false,
        gain = 1,
        source_group = "TAUNTS",
        files = {"PirateBoat_01c.ogg"}
    },
    PirateBombShootSound = {
        loop = false,
        gain = 1,
        source_group = "EXPLOSIONS",
        files = {"Sound_EngineerShot.ogg"}
    },
    PirateTowerTaunt = {
        loop = false,
        gain = 1,
        source_group = "TAUNTS",
        files = {"Pirate_Tower_01a.ogg", "Pirate_Tower_02b.ogg"}
    },
    PiratesTaunt = {
        loop = false,
        mode = "sequence",
        gain = 1,
        source_group = "TAUNTS",
        files = {"pirate_taunt_1.ogg", "pirate_taunt_2.ogg", "pirate_taunt_3.ogg"}
    },
    PolymorphSound = {
        loop = false,
        gain = 0.9,
        source_group = "SPECIALS",
        files = {"Sound_Polimorph.ogg"}
    },
    RTBlacksurgeHoldTower = {
        loop = false,
        gain = 1,
        source_group = "SFX",
        files = {"Blacksurge_holdtower.ogg"}
    },
    RTBluegaleStormAmbience = {
        loop = false,
        gain = 1,
        ignore = 2.33,
        source_group = "SFX",
        files = {"Bluegale_storm_ambience.ogg"}
    },
    RTBluegaleStormSummon = {
        loop = false,
        gain = 1,
        source_group = "SFX",
        files = {"Bluegale_storm_summon.ogg"}
    },
    RTBoatBreak = {
        loop = false,
        gain = 1,
        source_group = "SFX",
        files = {"ship_path_break.ogg"}
    },
    RTBossDeath = {
        loop = false,
        gain = 1,
        source_group = "SFX",
        files = {"boss_death.ogg"}
    },
    RTBossSpawn = {
        loop = false,
        gain = 1,
        source_group = "SFX",
        files = {"boss_spawn.ogg"}
    },
    RTBossTentacle = {
        loop = false,
        gain = 0.1,
        source_group = "SFX",
        files = {"boss_tentacle_spawn.ogg"}
    },
    RTBossTentacleAttack = {
        loop = false,
        gain = 1,
        source_group = "SFX",
        files = {"boss_leviathan_tentacle_grab.ogg"}
    },
    RTGunboatDeath = {
        loop = false,
        gain = 1,
        source_group = "SFX",
        files = {"Gunboat_death.ogg"}
    },
    RTGunboatShooting = {
        loop = false,
        gain = 1,
        source_group = "SFX",
        files = {"Gunboat_shooting.ogg"}
    },
    RTWaterDead = {
        loop = false,
        gain = 1,
        source_group = "SFX",
        files = {"Waterenemy_death.ogg"}
    },
    RTWaterExplosion = {
        loop = false,
        gain = 1,
        source_group = "SFX",
        files = {"Explosion_water.ogg"}
    },
    RTWhaleSpawn = {
        loop = false,
        gain = 1,
        source_group = "SFX",
        files = {"Whale_spawn.ogg"}
    },
    ReinforcementTaunt = {
        loop = false,
        mode = "sequence",
        gain = 0.6,
        source_group = "TAUNTS",
        files = {"Reinforcements_Event1.ogg", "Reinforcements_Event2.ogg", "Reinforcements_Event3.ogg",
                 "Reinforcements_Event4.ogg"}
    },
    RocketLaunchSound = {
        loop = false,
        gain = 0.8,
        source_group = "BULLETS",
        files = {"Sound_RocketLaunt.ogg"}
    },
    SandwraithCoffin = {
        loop = false,
        gain = 1,
        source_group = "SFX",
        files = {"sandwraith_coffin.ogg"}
    },
    SaurianBlazefangAttack = {
        loop = false,
        gain = 1,
        source_group = "SFX",
        files = {"blazefang_attack.ogg"}
    },
    SaurianBlazefangDeath = {
        loop = false,
        gain = 1,
        source_group = "SFX",
        files = {"blazefang_death.ogg"}
    },
    SaurianBruteAttack = {
        loop = false,
        gain = 1,
        source_group = "SFX",
        files = {"saurian_brute_attack.ogg"}
    },
    SaurianDarterTeleporth = {
        loop = false,
        gain = 0.8,
        source_group = "SFX",
        files = {"darter_teleout.ogg"}
    },
    SaurianKingBossDeath = {
        loop = false,
        gain = 1,
        source_group = "SPECIALS",
        files = {"KRF_sfx_saurianboss_muerte.ogg"}
    },
    SaurianKingBossHammer = {
        loop = false,
        gain = 1,
        source_group = "SPECIALS",
        files = {"KRF_sfx_saurianboss_martillo_1t.ogg"}
    },
    SaurianKingBossQuake = {
        loop = false,
        gain = 1,
        source_group = "SPECIALS",
        files = {"KRF_sfx_saurianboss_temblor.ogg"}
    },
    SaurianKingBossTongue = {
        loop = false,
        gain = 1,
        source_group = "SPECIALS",
        files = {"KRF_sfx_saurianboss_op1.ogg"}
    },
    SaurianMyrmidonBite = {
        loop = false,
        gain = 1,
        source_group = "SFX",
        files = {"myrmidon_bite.ogg"}
    },
    SaurianNightscaleInvisible = {
        loop = false,
        gain = 1,
        source_group = "SFX",
        files = {"nightscale_invisibility.ogg"}
    },
    SaurianSavantAttack = {
        loop = false,
        gain = 1,
        source_group = "SFX",
        files = {"savant_attack.ogg"}
    },
    SaurianSavantOpenPortal = {
        loop = false,
        gain = 0.8,
        source_group = "SFX",
        files = {"savant_open_portal.ogg"}
    },
    SaurianSavantPortalLoop = {
        loop = true,
        gain = 0.3,
        source_group = "GUI",
        files = {"savant_portal_loop.ogg"}
    },
    SaurianSavantTeleporth = {
        loop = false,
        gain = 0.3,
        source_group = "SFX",
        files = {"savant_telein.ogg"}
    },
    SaurianSniperBullet = {
        loop = false,
        gain = 1,
        source_group = "SPECIALS",
        files = {"KRF_sfx_suarian_sniper.ogg"}
    },
    ShotgunSound = {
        loop = false,
        source_group = "BULLETS",
        files = {"Sound_Shootgun.ogg"}
    },
    ShrapnelSound = {
        loop = false,
        source_group = "BULLETS",
        files = {"Sound_Shrapnel.ogg"}
    },
    SniperSound = {
        loop = false,
        source_group = "BULLETS",
        files = {"Sound_Sniper.ogg"}
    },
    SpecialAlienEggOpen = {
        loop = false,
        gain = 1,
        source_group = "SFX",
        files = {"alien_egg_open.ogg"}
    },
    SpecialBanthaFart = {
        loop = false,
        gain = 1,
        source_group = "SFX",
        files = {"bantha_fart.ogg"}
    },
    SpecialBanthaRoar = {
        loop = false,
        gain = 1,
        source_group = "SFX",
        files = {"bantha_roar.ogg"}
    },
    SpecialBlackDragonFire = {
        loop = false,
        gain = 1,
        source_group = "SFX",
        files = {"hero_dragon_flamethrower.ogg"}
    },
    SpecialBlackDragonTaunt = {
        loop = false,
        mode = "random",
        gain = 0.3,
        source_group = "TAUNTS",
        files = {"dragonHero_confirm1.ogg", "dragonHero_confirm2.ogg", "dragonHero_confirm3.ogg",
                 "dragonHero_confirm4.ogg"}
    },
    SpecialCarnivorePlant = {
        loop = false,
        gain = 1,
        source_group = "SFX",
        files = {"carnivore_plant.ogg"}
    },
    SpecialCutTrees = {
        loop = false,
        gain = 1,
        source_group = "SFX",
        files = {"cut_trees.ogg"}
    },
    SpecialFrog = {
        loop = false,
        gain = 1,
        source_group = "SFX",
        files = {"frog_dance.ogg"}
    },
    SpecialIndiana = {
        loop = false,
        gain = 1,
        source_group = "SFX",
        files = {"indiana.ogg"}
    },
    SpecialIndianaRuns = {
        loop = false,
        gain = 1,
        source_group = "SFX",
        files = {"indiana_runs.ogg"}
    },
    SpecialIndianaSelect = {
        loop = false,
        gain = 1,
        source_group = "SFX",
        files = {"indiana_select.ogg"}
    },
    SpecialMermaid = {
        loop = false,
        gain = 0.5,
        ignore = 0.5,
        source_group = "SFX",
        files = {"mermaid.ogg"}
    },
    SpecialMountainDoor = {
        loop = false,
        gain = 1,
        source_group = "SFX",
        files = {"mountain_door.ogg"}
    },
    SpecialStargate = {
        loop = false,
        gain = 1,
        source_group = "SFX",
        files = {"stargate.ogg"}
    },
    SpecialTusken = {
        loop = false,
        gain = 1,
        source_group = "SFX",
        files = {"tusken.ogg"}
    },
    SpecialVolcanoLavaShoot = {
        loop = false,
        gain = 1,
        source_group = "SFX",
        files = {"volcano_lavaShot.ogg"}
    },
    SpecialVolcanoLavaShootHit = {
        loop = false,
        gain = 1,
        source_group = "SFX",
        files = {"volcano_lavaShotHit.ogg"}
    },
    SpecialVolcanoThrowSplash = {
        loop = false,
        gain = 1,
        source_group = "SFX",
        files = {"volcano_splash.ogg"}
    },
    SpecialVolcanoVirginScream = {
        loop = false,
        gain = 0.3,
        source_group = "SFX",
        files = {"volcano_virginScream.ogg"}
    },
    SpecialWormBite = {
        loop = false,
        gain = 1,
        source_group = "SFX",
        files = {"worm_bite.ogg"}
    },
    SpecialWormDirtSound = {
        loop = true,
        gain = 1,
        source_group = "SFX",
        files = {"worm_dirtLoop.ogg"}
    },
    SpiderAttack = {
        loop = false,
        gain = 0.6,
        ignore = 1.5,
        source_group = "BULLETS",
        files = {"Sound_SpiderAttack2.ogg"}
    },
    TemplarArterial = {
        loop = false,
        gain = 1,
        source_group = "SPECIALS",
        files = {"templar_arterialStrike.ogg"}
    },
    TemplarHolygrail = {
        loop = false,
        gain = 0.8,
        source_group = "SPECIALS",
        files = {"templar_holyGrail.ogg"}
    },
    TemplarTaunt = {
        loop = false,
        mode = "sequence",
        gain = 0.8,
        source_group = "TAUNTS",
        files = {"templar_taunt_ready.ogg", "templar_taunt_1.ogg", "templar_taunt_2.ogg", "templar_taunt_3.ogg"}
    },
    TemplarTauntReady = {
        loop = false,
        gain = 0.8,
        source_group = "TAUNTS",
        files = {"templar_taunt_3.ogg"}
    },
    TemplarTauntTauntOne = {
        loop = false,
        gain = 0.8,
        source_group = "TAUNTS",
        files = {"templar_taunt_ready.ogg"}
    },
    TemplarTauntTauntTwo = {
        loop = false,
        gain = 0.8,
        source_group = "TAUNTS",
        files = {"templar_taunt_1.ogg"}
    },
    TemplarTauntThree = {
        loop = false,
        gain = 0.8,
        source_group = "TAUNTS",
        files = {"templar_taunt_2.ogg"}
    },
    TeslaAttack = {
        loop = false,
        gain = 0.6,
        source_group = "BULLETS",
        files = {"Sound_Tesla_attack_1.ogg", "Sound_Tesla_attack_2.ogg"}
    },
    TotemSpirits = {
        loop = false,
        gain = 0.8,
        source_group = "SPECIALS",
        files = {"axlethrower_totem_spirits.ogg"}
    },
    TotemTaunt = {
        loop = false,
        mode = "sequence",
        gain = 0.8,
        source_group = "TAUNTS",
        files = {"axlethrower_taunt_ready.ogg", "axlethrower_taunt_totem1.ogg", "axlethrower_taunt_totem2.ogg"}
    },
    TotemTauntReady = {
        loop = false,
        gain = 0.8,
        source_group = "TAUNTS",
        files = {"axlethrower_taunt_ready.ogg"}
    },
    TotemTauntTotemOne = {
        loop = false,
        gain = 0.8,
        source_group = "TAUNTS",
        files = {"axlethrower_taunt_totem1.ogg"}
    },
    TotemTauntTotemTwo = {
        loop = false,
        gain = 0.8,
        source_group = "TAUNTS",
        files = {"axlethrower_taunt_totem2.ogg"}
    },
    TotemVanish = {
        loop = false,
        gain = 0.8,
        source_group = "SPECIALS",
        files = {"axlethrower_totem_vanish.ogg"}
    },
    TotemWeakness = {
        loop = false,
        gain = 0.8,
        source_group = "SPECIALS",
        files = {"axlethrower_totem_weakness.ogg"}
    },
    UndergroundAmbienceSound = {
        loop = false,
        mode = "random",
        gain = 0.3,
        source_group = "SFX",
        files = {"ambience_underground_1.ogg", "ambience_underground_2.ogg"}
    },
    VeznanHoldCast = {
        loop = false,
        gain = 1,
        source_group = "BULLETS",
        files = {"Sound_SpellTowerHold_Cast.ogg"}
    },
    VeznanHoldDissipate = {
        loop = false,
        gain = 1,
        source_group = "BULLETS",
        files = {"Sound_SpellTowerHold_Dissipate.ogg"}
    },
    WaspTaunt = {
        loop = false,
        gain = 0.6,
        ignore = 3,
        mode = "random",
        source_group = "SFX",
        files = {"wasp_1.ogg", "wasp_2.ogg", "wasp_3.ogg"}
    },
    WilhemScream = {
        loop = false,
        gain = 1,
        source_group = "SFX",
        files = {"wilhelm_scream.ogg"}
    },
    WolfAttack = {
        loop = false,
        gain = 0.6,
        ignore = 1.5,
        source_group = "BULLETS",
        files = {"Sound_WolfAttack.ogg", "Sound_WolfAttack2.ogg"}
    }
}

local kr3 = {
    -- chunkname: @./kr3-desktop/assets/sounds/sounds.lua
    AreaAttack = {
        loop = false,
        gain = 1,
        source_group = "BULLETS",
        files = {"Sound_CommonAreaHit.ogg"}
    },
    ArrowSound = {
        loop = false,
        source_group = "BULLETS",
        files = {"Sound_ArrowRelease2.ogg", "Sound_ArrowRelease3.ogg"}
    },
    AxeSound = {
        loop = false,
        source_group = "BULLETS",
        files = {"Sound_BattleAxe.ogg"}
    },
    BoltSorcererSound = {
        loop = false,
        gain = 0.68,
        source_group = "BULLETS",
        files = {"Sound_Sorcerer.ogg"}
    },
    BoltSound = {
        loop = false,
        gain = 0.68,
        source_group = "BULLETS",
        files = {"Sound_MageShot.ogg"}
    },
    BombExplosionSound = {
        loop = false,
        gain = 0.8,
        source_group = "EXPLOSIONS",
        files = {"Sound_Bomb1.ogg"}
    },
    BombShootSound = {
        loop = false,
        gain = 0.75,
        source_group = "EXPLOSIONS",
        files = {"Sound_EngineerShot.ogg"}
    },
    CommonLightning = {
        loop = false,
        mode = "sequence",
        gain = 1,
        source_group = "SPECIALS",
        files = {"kr3_sfx_lightning_op1.ogg", "kr3_sfx_lightning_op2.ogg", "kr3_sfx_lightning_op3.ogg"}
    },
    DeathBig = {
        loop = false,
        source_group = "DEATH",
        files = {"Sound_EnemyBigDead.ogg"}
    },
    DeathEplosion = {
        loop = false,
        gain = 0.4,
        source_group = "DEATH",
        files = {"Sound_EnemyExplode1.ogg"}
    },
    DeathGoblin = {
        loop = false,
        source_group = "DEATH",
        files = {"Sound_EnemyGoblinDead.ogg"}
    },
    DeathHuman = {
        loop = false,
        mode = "random",
        source_group = "DEATH",
        files = {"Sound_HumanDead1.ogg", "Sound_HumanDead2.ogg", "Sound_HumanDead3.ogg", "Sound_HumanDead4.ogg"}
    },
    DeathOrc = {
        loop = false,
        source_group = "DEATH",
        files = {"Sound_EnemyOrcDead.ogg"}
    },
    DeathPuff = {
        loop = false,
        gain = 0.8,
        source_group = "DEATH",
        files = {"Sound_EnemyPuffDead.ogg"}
    },
    DeathSkeleton = {
        loop = false,
        source_group = "DEATH",
        files = {"Sound_EnemySkeletonBreak2.ogg"}
    },
    DeathTroll = {
        loop = false,
        source_group = "DEATH",
        files = {"Sound_EnemyTrollDead.ogg"}
    },
    ElvenWoodsAmbienceSound = {
        loop = false,
        mode = "random",
        gain = 0.3,
        source_group = "SFX",
        files = {"kre_sfx_ambience_singlebirdandstream.ogg", "kro_sfx_ambience_wardrums[op1].ogg",
                 "kro_sfx_ambience_wardrums[op2].ogg", "kro_sfx_ambience_wardrums[op3].ogg",
                 "kre_sfx_ambience_singlebirdandstream.ogg", "kro_sfx_hulkingrage_mining_v2[op1].ogg",
                 "kro_sfx_hulkingrage_mining_v2[op2].ogg", "kro_sfx_hulkingrage_mining_v2[op1].ogg",
                 "kro_sfx_hulkingrage_mining_v2[op2].ogg", "kre_sfx_ambience_singlebirdandstream.ogg"}
    },
    ElvesAchievementDwarfFall = {
        loop = false,
        gain = 0.3,
        source_group = "SFX",
        files = {"kro_sfx_dwarfdeath[barrel].ogg"}
    },
    ElvesAchievementHobbit = {
        loop = false,
        gain = 0.2,
        source_group = "SFX",
        files = {"kre_sfx_achievement_mario.ogg"}
    },
    ElvesAchievementScissorFingers = {
        loop = false,
        gain = 1,
        source_group = "SFX",
        files = {"kre_sfx_achievement_scissorfingers_v2.ogg"}
    },
    ElvesAchievementSorcapprenticeBook = {
        loop = false,
        gain = 0.8,
        source_group = "SFX",
        files = {"kro_sfx_sorcapprentice_book[op1].ogg"}
    },
    ElvesAchievementSorcapprenticeBroom = {
        loop = false,
        gain = 0.8,
        source_group = "SFX",
        files = {"kro_sfx_sorcapprentice_broom.ogg"}
    },
    ElvesAchievementSorcapprenticeHat = {
        loop = false,
        gain = 0.8,
        source_group = "SFX",
        files = {"kro_sfx_sorcapprentice_hat[sinexplo].ogg"}
    },
    ElvesAchievementWilson = {
        loop = false,
        gain = 0.8,
        source_group = "SFX",
        files = {"kro_sfx_wilson[op1].ogg"}
    },
    ElvesAchievementYellowSubmarine = {
        loop = false,
        gain = 0.6,
        source_group = "SFX",
        files = {"kr_yellow_submarine_custom.ogg"}
    },
    ElvesArcherArcaneBurstTaunt = {
        loop = false,
        gain = 0.6,
        source_group = "TAUNTS",
        files = {"ArcaneArcher_BurstArrow-01a.ogg"}
    },
    ElvesArcherArcaneSleepTaunt = {
        loop = false,
        gain = 0.6,
        source_group = "TAUNTS",
        files = {"ArcaneArcher_SleepArrow-01c.ogg"}
    },
    ElvesArcherArcaneTaunt = {
        loop = false,
        gain = 0.6,
        source_group = "TAUNTS",
        files = {"ArcaneArcher_Ready-01a.ogg"}
    },
    ElvesArcherGoldenBowCrimsonTaunt = {
        loop = false,
        gain = 0.6,
        source_group = "TAUNTS",
        files = {"GoldenBows_Crimson-01b.ogg"}
    },
    ElvesArcherGoldenBowMarkTaunt = {
        loop = false,
        gain = 0.6,
        source_group = "TAUNTS",
        files = {"GoldenBows_Mark-01b.ogg"}
    },
    ElvesArcherGoldenBowTaunt = {
        loop = false,
        gain = 0.6,
        source_group = "TAUNTS",
        files = {"GoldenBows_Ready[2]-01d.ogg"}
    },
    -- ElvesArcherTaunt = {
    --     loop = false,
    --     gain = 0.6,
    --     ignore = 1.5,
    --     mode = "sequence",
    --     source_group = "TAUNTS",
    --     files = {"Archers_Taunt-01a.ogg", "Archers_Taunt-02a.ogg", "Archers_Taunt-03e.ogg"}
    -- },
    ElvesAshbiteConfirm = {
        loop = false,
        mode = "sequence",
        gain = 0.6,
        source_group = "SPECIALS",
        files = {"kro_sfx_ashbite_confirm_v1[op1].ogg", "kro_sfx_ashbite_confirm_v1[op2].ogg"}
    },
    ElvesAshbiteDeath = {
        loop = false,
        gain = 0.6,
        source_group = "SPECIALS",
        files = {"hero_dragon_death.ogg"}
    },
    ElvesAshbiteFireball = {
        loop = false,
        gain = 0.6,
        source_group = "SPECIALS",
        files = {"hero_dragon_fireball_explode.ogg"}
    },
    ElvesAshbiteFlameThrower = {
        loop = false,
        gain = 0.6,
        source_group = "SPECIALS",
        files = {"hero_dragon_flamethrower.ogg"}
    },
    ElvesAshbiteSmoke = {
        loop = false,
        gain = 0.6,
        source_group = "SPECIALS",
        files = {"hero_dragon_smoke.ogg"}
    },
    ElvesAshbiteSpit = {
        loop = false,
        gain = 0.6,
        source_group = "SPECIALS",
        files = {"hero_dragon_spit.ogg"}
    },
    ElvesBajNimenBossDeath = {
        loop = false,
        gain = 1,
        source_group = "SFX",
        files = {"kro_sfx_bitteringrancor_boss-death[conriser].ogg"}
    },
    ElvesBajNimenBossHeal = {
        loop = false,
        gain = 1,
        source_group = "SFX",
        files = {"kro_sfx_bitteringrancor_boss-heal.ogg"}
    },
    ElvesBajNimenBossRangedAttack = {
        loop = false,
        gain = 1,
        source_group = "BULLETS",
        files = {"kro_sfx_bitteringrancor_boss-rangedattack[op2].ogg"}
    },
    ElvesBajNimenBossShadowCast = {
        loop = false,
        gain = 0.5,
        source_group = "SFX",
        files = {"kro_sfx_bitteringrancor_boss-shadowstorm[cast].ogg"}
    },
    ElvesBajNimenBossShadowImpact = {
        loop = false,
        gain = 0.3,
        source_group = "BULLETS",
        files = {"kro_sfx_bitteringrancor_boss-shadowstorm[impact].ogg"}
    },
    ElvesBajNimenBossShadowTravel = {
        loop = false,
        gain = 0.5,
        source_group = "BULLETS",
        files = {"kro_sfx_bitteringrancor_boss-shadowstorm[travel].ogg"}
    },
    ElvesBajNimenBossTail = {
        loop = false,
        gain = 1,
        source_group = "SFX",
        files = {"kro_sfx_bitteringrancor_boss-tailwhip.ogg"}
    },
    ElvesBalrogAttack = {
        loop = false,
        gain = 1,
        source_group = "SPECIALS",
        files = {"kro_sfx_godieth_attack.ogg"}
    },
    ElvesBalrogBloodpool = {
        loop = false,
        gain = 1,
        source_group = "SPECIALS",
        files = {"kro_sfx_godieth_bloodpool.ogg"}
    },
    ElvesBalrogDeath = {
        loop = false,
        gain = 1,
        source_group = "SPECIALS",
        files = {"kro_sfx_godieth_death[op2].ogg"}
    },
    ElvesBalrogSpit = {
        loop = false,
        gain = 1,
        source_group = "SPECIALS",
        files = {"kro_sfx_godieth_spit.ogg"}
    },
    ElvesBarrackBladesingerBladeDanceTaunt = {
        loop = false,
        gain = 0.6,
        source_group = "TAUNTS",
        files = {"Bladesinger_BladeDance[2]-01a.ogg"}
    },
    ElvesBarrackBladesingerPerfectParryTaunt = {
        loop = false,
        gain = 0.6,
        source_group = "TAUNTS",
        files = {"Bladesinger_PerfectParry[2]-01d.ogg"}
    },
    ElvesBarrackBladesingerSwirlingEdge = {
        loop = false,
        gain = 0.6,
        source_group = "TAUNTS",
        files = {"Bladesinger_SwirlingEdge[2]-01a.ogg"}
    },
    ElvesBarrackBladesingerSwirlingTaunt = {
        loop = false,
        gain = 0.6,
        source_group = "TAUNTS",
        files = {"ForestProtector_Ancient[2]-01c.ogg"}
    },
    ElvesBarrackBladesingerTaunt = {
        loop = false,
        mode = "sequence",
        gain = 0.6,
        source_group = "TAUNTS",
        files = {"Bladesinger_Ready[2]-01b.ogg", "Bladesinger_PerfectParry[2]-01d.ogg",
                 "Bladesinger_BladeDance[2]-01a.ogg", "Bladesinger_SwirlingEdge[2]-01a.ogg"}
    },
    ElvesBarrackForestKeeperCircleOfLifeTaunt = {
        loop = false,
        gain = 0.6,
        source_group = "TAUNTS",
        files = {"ForestProtector_Circle[2]-01g.ogg"}
    },
    ElvesBarrackForestKeeperEerieTaunt = {
        loop = false,
        gain = 0.6,
        source_group = "TAUNTS",
        files = {"ForestProtector_Eerie[2]-01a.ogg"}
    },
    ElvesBarrackForestKeeperOakSpearTaunt = {
        loop = false,
        gain = 0.6,
        source_group = "TAUNTS",
        files = {"ForestProtector_Ancient[2]-01c.ogg"}
    },
    ElvesBarrackForestKeeperTaunt = {
        loop = false,
        mode = "sequence",
        gain = 0.6,
        source_group = "TAUNTS",
        files = {"ForestProtector_Ready[2]-01c.ogg", "ForestProtector_Eerie[2]-01a.ogg",
                 "ForestProtector_Circle[2]-01g.ogg", "ForestProtector_Ancient[2]-01c.ogg"}
    },
    -- ElvesBarrackTaunt = {
    --     loop = false,
    --     gain = 0.6,
    --     ignore = 1.5,
    --     mode = "sequence",
    --     source_group = "TAUNTS",
    --     files = {"Barrack_Taunt[2]-01c.ogg", "Barrack_Taunt[2]-02c.ogg", "Barrack_Taunt[2]-03c.ogg",
    --              "Barrack_Taunt[2]-04e.ogg"}
    -- },
    ElvesBeanGrow = {
        loop = false,
        gain = 1,
        source_group = "SPECIALS",
        files = {"kro_sfx_bean.ogg"}
    },
    ElvesBeanGrowLoop = {
        loop = true,
        gain = 1,
        source_group = "SPECIALS",
        files = {"kro_sfx_bean_loop.ogg"}
    },
    ElvesBlackBabyFirebreathLoop = {
        loop = true,
        gain = 0.2,
        source_group = "SPECIALS",
        files = {"kro_sfx_barezad_firebreath_v2[loop].ogg"}
    },
    ElvesBlackBabyFirebreathLoopEnd = {
        loop = false,
        gain = 0.2,
        source_group = "SPECIALS",
        files = {"kro_sfx_barezad_firebreath_v2[end].ogg"}
    },
    ElvesBlackBabyFirebreathLoopStart = {
        loop = false,
        gain = 0.2,
        source_group = "SPECIALS",
        files = {"kro_sfx_barezad_firebreath_v2[starter].ogg"}
    },
    ElvesBlackBabyFlyLoop = {
        loop = true,
        gain = 0.2,
        source_group = "SPECIALS",
        files = {"kro_sfx_barezad_fly[loop-op2].ogg"}
    },
    ElvesBossBramCharge = {
        loop = false,
        gain = 1,
        source_group = "SFX",
        files = {"kro_sfx_bram_fistcharge.ogg"}
    },
    ElvesBossBramDeath = {
        loop = false,
        gain = 1,
        source_group = "SFX",
        files = {"kro_sfx_bram_death[conexplo].ogg"}
    },
    ElvesBossBramGroundStomp = {
        loop = false,
        gain = 1,
        source_group = "SFX",
        files = {"kro_sfx_bram_groundstomp.ogg"}
    },
    ElvesBossBramSlap = {
        loop = false,
        gain = 1,
        source_group = "SFX",
        files = {"kro_sfx_bram_sopapo[conwhoosh].ogg"}
    },
    ElvesCreepArachnomancerSpiderSpawn = {
        loop = false,
        gain = 0.3,
        source_group = "SFX",
        files = {"kro_sfx_arachnomancer_spiderspawn[op1].ogg"}
    },
    ElvesCreepAvenger = {
        loop = false,
        gain = 0.3,
        source_group = "SFX",
        files = {"kro_sfx_avenger_lastservice_v2[op2].ogg"}
    },
    ElvesCreepEvokerHeal = {
        loop = false,
        gain = 0.8,
        source_group = "SFX",
        files = {"kro_sfx_evoker_heal[sinshaker].ogg"}
    },
    ElvesCreepGolemAreaAttack = {
        loop = false,
        gain = 0.8,
        source_group = "SFX",
        files = {"kro_sfx_elemental_areaattack.ogg"}
    },
    ElvesCreepGolemDeath = {
        loop = false,
        gain = 0.8,
        source_group = "SFX",
        files = {"kro_sfx_elemental_death.ogg"}
    },
    ElvesCreepHoplite = {
        loop = false,
        gain = 0.3,
        source_group = "SFX",
        files = {"kro_sfx_hoplite_summon_v3[singrowl].ogg"}
    },
    ElvesCreepHyena = {
        loop = false,
        gain = 0.2,
        ignore = 1,
        mode = "random",
        source_group = "SFX",
        files = {"kre_sfx_hyena_ambience_v4[op1_heavysnors].ogg", "kre_sfx_hyena_ambience_v4[op2_consnors].ogg"}
    },
    ElvesCreepMountedAvengerDeath = {
        loop = false,
        gain = 1,
        source_group = "SFX",
        files = {"kro_sfx_bitteringrancor_mountedavanger-death[conexplo].ogg"}
    },
    ElvesCreepRazorboarCharge = {
        loop = false,
        gain = 0.3,
        source_group = "SFX",
        files = {"kro_sfx_razorboar_charge[sinpisadas].ogg"}
    },
    ElvesCreepScreecherDeath = {
        loop = false,
        gain = 1,
        source_group = "SFX",
        files = {"kro_sfx_bitteringrancor_screecher-death.ogg"}
    },
    ElvesCreepScreecherScream = {
        loop = false,
        gain = 0.5,
        source_group = "SFX",
        files = {"kro_sfx_bitteringrancor_screecher-scream[op5].ogg"}
    },
    ElvesCreepServantDeath = {
        loop = false,
        gain = 1,
        source_group = "SFX",
        files = {"kro_sfx_bitteringrancor_servant-death[op2].ogg"}
    },
    ElvesCreepSonOfMactansLanding = {
        loop = false,
        gain = 0.2,
        source_group = "SFX",
        files = {"kro_sfx_sonofmactans[sinlanding].ogg"}
    },
    ElvesCrystalBuff = {
        loop = false,
        gain = 0.6,
        source_group = "SPECIALS",
        files = {"kro_sfx_crystalbuff.ogg"}
    },
    ElvesCrystalIce = {
        loop = false,
        gain = 0.6,
        source_group = "SPECIALS",
        files = {"kro_sfx_crystalice.ogg"}
    },
    ElvesCrystalRay = {
        loop = false,
        gain = 0.3,
        source_group = "SPECIALS",
        files = {"kro_sfx_crystalray[op1].ogg"}
    },
    ElvesCrystalSerpentAttack = {
        loop = false,
        gain = 1,
        source_group = "SPECIALS",
        files = {"kro_sfx_crystalserpent_serpentsattack.ogg"}
    },
    ElvesCrystalSerpentBreakingCrystal = {
        loop = false,
        gain = 1,
        source_group = "SPECIALS",
        files = {"kro_sfx_crystalserpent_crystalshatter.ogg"}
    },
    ElvesCrystalSerpentEmerge = {
        loop = false,
        gain = 1,
        source_group = "SPECIALS",
        files = {"kro_sfx_crystalserpent_emerge.ogg"}
    },
    ElvesCrystalSerpentPassby = {
        loop = false,
        gain = 0.3,
        source_group = "SPECIALS",
        files = {"kro_sfx_crystalserpent_passby[sinsublows]_B.ogg"}
    },
    ElvesCrystalSerpentScream = {
        loop = false,
        gain = 1,
        source_group = "SPECIALS",
        files = {"kro_sfx_crystalserpent_scream[op4_pocodelay].ogg"}
    },
    ElvesCrystalSerpentSubmerge = {
        loop = false,
        gain = 1,
        source_group = "SPECIALS",
        files = {"kro_sfx_crystalserpent_submerge_B.ogg"}
    },
    ElvesCrystalSkull = {
        loop = false,
        gain = 0.5,
        source_group = "SFX",
        files = {"kro_sfx_crystalskull_touch[conrisa].ogg"}
    },
    ElvesCrystallizedGnoll = {
        loop = false,
        gain = 0.5,
        source_group = "SFX",
        files = {"kro_sfx_crystallizedgnoll_v2.ogg"}
    },
    ElvesCrystallizingGnoll = {
        loop = false,
        gain = 0.5,
        source_group = "SFX",
        files = {"kro_sfx_unstablecrystal_crystallize[op1].ogg"}
    },
    ElvesDarkSpitterDeath = {
        loop = false,
        gain = 1,
        source_group = "SPECIALS",
        files = {"kro_sfx_darkspitter_death[op2-sincaida].ogg"}
    },
    ElvesDarkSpitterSpit = {
        loop = false,
        gain = 1,
        source_group = "SPECIALS",
        files = {"krf_sfx_darkspitter_spit.ogg"}
    },
    ElvesDeathGnolls = {
        loop = false,
        gain = 0.3,
        source_group = "SFX",
        files = {"kro_sfx_crystallizedgnoll_v2.ogg"}
    },
    ElvesDrowTaunt = {
        loop = false,
        gain = 0.6,
        ignore = 1,
        mode = "sequence",
        source_group = "SPECIALS",
        files = {"Drow_01c.ogg", "Drow_02c.ogg", "Drow_03b.ogg"}
    },
    ElvesEwokAttack = {
        loop = false,
        gain = 1,
        source_group = "SPECIALS",
        files = {"Awok_02c.ogg"}
    },
    ElvesEwokTaunt = {
        loop = false,
        gain = 1,
        ignore = 1,
        mode = "sequence",
        source_group = "SPECIALS",
        files = {"Awok_01b.ogg", "Awok_02c.ogg"}
    },
    ElvesFaeryDragonAttack = {
        loop = false,
        gain = 0.2,
        source_group = "SPECIALS",
        files = {"kro_sfx_faerydragon_sfx_attack[op2][soloattack]_B.ogg"}
    },
    ElvesFaeryDragonAttackCristalization = {
        loop = false,
        gain = 0.2,
        source_group = "SPECIALS",
        files = {"kro_sfx_faerydragon_attack[solocristalizacion].ogg"}
    },
    ElvesFaeryDragonDragonBuy = {
        loop = false,
        gain = 0.2,
        source_group = "SPECIALS",
        files = {"kro_sfx_faerydragon_buydragon[op1].ogg"}
    },
    ElvesFaeryDragonExtraAbility = {
        loop = false,
        gain = 0.2,
        source_group = "SPECIALS",
        files = {"kro_sfx_faerydragon_extraability[solochimes].ogg"}
    },
    ElvesFinalBossCastSpell = {
        loop = false,
        gain = 1,
        source_group = "SFX",
        files = {"kro_sfx_spidergoddess_castspell.ogg"}
    },
    ElvesFinalBossCastSpellWithLaugh = {
        loop = false,
        gain = 1,
        source_group = "SFX",
        files = {"kro_sfx_spidergoddess_castspellwithlaughter.ogg"}
    },
    ElvesFinalBossDeath = {
        loop = false,
        gain = 1,
        source_group = "SFX",
        files = {"kro_sfx_spidergoddess_death_v2[larga].ogg"}
    },
    ElvesFinalBossGemCrystalBreak = {
        loop = false,
        gain = 1,
        source_group = "SFX",
        files = {"kro_sfx_gemcrystalbreak[solo]_v1.ogg"}
    },
    ElvesFinalBossGemattackMalicia = {
        loop = false,
        gain = 0.3,
        source_group = "SFX",
        files = {"kro_sfx_malicia_gemattack_v1B.ogg"}
    },
    ElvesFinalBossGemattackSpider = {
        loop = false,
        gain = 0.3,
        source_group = "SFX",
        files = {"kro_sfx_mactans_gemattack[op1].ogg"}
    },
    ElvesFinalBossJump = {
        loop = false,
        gain = 1,
        source_group = "SFX",
        files = {"kro_sfx_finalboss_jump.ogg"}
    },
    ElvesFinalBossMactansTouch = {
        loop = false,
        gain = 0.6,
        source_group = "SFX",
        files = {"kr3_sfx_mactans_touch.ogg"}
    },
    ElvesFinalBossSpiderGoddessFall = {
        loop = false,
        gain = 1,
        source_group = "SFX",
        files = {"kro_sfx_spidergoddess_fall_v2.ogg"}
    },
    ElvesFinalBossSpiderGoddessMorph = {
        loop = false,
        gain = 0.6,
        source_group = "SFX",
        files = {"kro_sfx_spidergoddess_morph_v1.ogg"}
    },
    ElvesFinalBossSpiderIn = {
        loop = false,
        gain = 0.3,
        source_group = "SFX",
        files = {"kro_sfx_malicia_spiderin.ogg"}
    },
    ElvesFinalBossSpiderOut = {
        loop = false,
        gain = 0.3,
        source_group = "SFX",
        files = {"kro_sfx_malicia_spiderout.ogg"}
    },
    ElvesFinalBossSpiderSuperrayCharge = {
        loop = false,
        gain = 1,
        source_group = "SFX",
        files = {"kro_sfx_spidergoddess_superray_v4[carga].ogg"}
    },
    ElvesFinalBossSpiderSuperrayDischarge = {
        loop = false,
        gain = 1,
        source_group = "SFX",
        files = {"kro_sfx_spidergoddess_superray_v3[descarga].ogg"}
    },
    ElvesFinalBossWebground = {
        loop = false,
        gain = 1,
        source_group = "SFX",
        files = {"kro_sfx_mactans_webground[conhissing].ogg"}
    },
    ElvesFinalBossWebspin = {
        loop = false,
        gain = 1,
        source_group = "SFX",
        files = {"kro_sfx_mactans_webspin[towers].ogg"}
    },
    ElvesFinalBosskillray = {
        loop = false,
        gain = 1,
        source_group = "SFX",
        files = {"kro_sfx_spidergoddess_killray[conprecarga].ogg"}
    },
    ElvesForgottenTreasureAmbienceSound = {
        loop = false,
        mode = "random",
        gain = 0.8,
        source_group = "SFX",
        files = {"kro_sfx_bubblinglava-AMB.ogg", "kro_sfx_wingflaps-AMB.ogg", "kro_sfx_dripping[conbichos]-AMB.ogg"}
    },
    ElvesGnollTrailOut = {
        loop = false,
        gain = 1,
        source_group = "SFX",
        files = {"kro_sfx_gnoll_outofbush_modif.ogg"}
    },
    ElvesGnomeDeathTaunt = {
        loop = false,
        mode = "sequence",
        gain = 1,
        source_group = "TAUNTS",
        files = {"kro_sfx_gnome_death[op1].ogg", "kro_sfx_gnome_death[op4].ogg", "kro_sfx_gnome_death[op7].ogg"}
    },
    ElvesGnomeDesintegrate = {
        loop = false,
        gain = 1,
        source_group = "SPECIALS",
        files = {"kro_sfx_gnome_desintegrate_v2[comic].ogg"}
    },
    ElvesGnomeNew = {
        loop = false,
        gain = 1,
        source_group = "SPECIALS",
        files = {"Gnome_02a.ogg"}
    },
    ElvesGnomePoison = {
        loop = false,
        gain = 1,
        source_group = "SPECIALS",
        files = {"kro_sfx_gnome_poison_v2[confrasco].ogg"}
    },
    ElvesGnomePolymorf = {
        loop = false,
        gain = 1,
        source_group = "SPECIALS",
        files = {"kro_sfx_gnome_polymorf[conchimes].ogg"}
    },
    ElvesGnomePower = {
        loop = false,
        gain = 1,
        source_group = "SPECIALS",
        files = {"Gnome_01d.ogg"}
    },
    ElvesGnomeSteal = {
        loop = false,
        gain = 1,
        source_group = "SPECIALS",
        files = {"kro_sfx_gnome_polymorf[conchimes].ogg"}
    },
    ElvesGnomeTeleport = {
        loop = false,
        gain = 0.2,
        source_group = "SPECIALS",
        files = {"kro_sfx_veznan_teleport_v1.ogg"}
    },
    ElvesGrimDevourerConsume = {
        loop = false,
        gain = 0.5,
        source_group = "SPECIALS",
        files = {"kro_sfx_grimdevourer_consume.ogg"}
    },
    ElvesGrimDevourerDeath = {
        loop = false,
        gain = 1,
        source_group = "SPECIALS",
        files = {"kro_sfx_grimdevourer_death.ogg"}
    },
    ElvesGryphonsLand = {
        loop = false,
        gain = 1,
        source_group = "SPECIALS",
        files = {"kre_sfx_gryphon_land_v3[op1].ogg"}
    },
    ElvesGryphonsShoot = {
        loop = false,
        gain = 1,
        source_group = "SPECIALS",
        files = {"kre_sfx_gryphon_shot_v2[op3].ogg"}
    },
    ElvesGryphonsShootEnd = {
        loop = false,
        gain = 1,
        source_group = "SPECIALS",
        files = {"kre_sfx_gryphon_shot_v2[end].ogg"}
    },
    ElvesGryphonsShootStart = {
        loop = false,
        gain = 1,
        source_group = "SPECIALS",
        files = {"kre_sfx_gryphon_shot_v2[end].ogg"}
    },
    ElvesGryphonsTakeOff = {
        loop = false,
        gain = 1,
        source_group = "SPECIALS",
        files = {"kre_sfx_gryphon_takeoff_v2.ogg"}
    },
    ElvesHanselAndGretelEscape = {
        loop = false,
        gain = 1,
        source_group = "SPECIALS",
        files = {"kro_sfx_hanselandgretel_escape[arpayrisas].ogg"}
    },
    ElvesHeroAlleriaDeath = {
        loop = false,
        gain = 0.3,
        source_group = "TAUNTS",
        files = {"Female-Elven-Archer-Death_a.ogg"}
    },
    ElvesHeroAlleriaTaunt = {
        loop = false,
        gain = 0.3,
        ignore = 1,
        mode = "sequence",
        source_group = "TAUNTS",
        files = {"Female-Elven-Archer-01c.ogg", "Female-Elven-Archer-02c.ogg", "Female-Elven-Archer-03a.ogg",
                 "Female-Elven-Archer-04b.ogg"}
    },
    ElvesHeroAlleriaTauntIntro = {
        loop = false,
        gain = 0.3,
        source_group = "TAUNTS",
        files = {"Level_up.ogg"}
    },
    ElvesHeroAlleriaTauntSelect = {
        loop = false,
        gain = 0.3,
        source_group = "TAUNTS",
        files = {"Female-Elven-Archer-04b.ogg"}
    },
    ElvesHeroArivanDeath = {
        loop = false,
        gain = 1,
        source_group = "TAUNTS",
        files = {"Arivan_Death-01a.ogg"}
    },
    ElvesHeroArivanFireball = {
        loop = false,
        gain = 1,
        source_group = "SPECIALS",
        files = {"kre_sfx_arivan_fireballshot_v2.ogg"}
    },
    ElvesHeroArivanFireballExplode = {
        loop = false,
        gain = 1,
        source_group = "SPECIALS",
        files = {"kre_sfx_arivan_fireballhit_v3.ogg"}
    },
    ElvesHeroArivanFireballSummon = {
        loop = false,
        gain = 1,
        source_group = "SPECIALS",
        files = {"kre_sfx_arivan_fireballsummon[op2].ogg"}
    },
    ElvesHeroArivanIceShoot = {
        loop = false,
        gain = 1,
        source_group = "SPECIALS",
        files = {"kre_sfx_arivan_iceboltshot_v2[contono].ogg"}
    },
    ElvesHeroArivanIceShootHit = {
        loop = false,
        gain = 1,
        source_group = "SPECIALS",
        files = {"kre_sfx_arivan_icebolt[hit].ogg"}
    },
    ElvesHeroArivanLightingBolt = {
        loop = false,
        gain = 1,
        source_group = "SPECIALS",
        files = {"kre_sfx_arivan_lightningbolt_v2.ogg"}
    },
    ElvesHeroArivanStorm = {
        loop = true,
        gain = 0.3,
        source_group = "GUI",
        files = {"kre_sfx_arivan_elementalstorm_v2_op3.ogg"}
    },
    ElvesHeroArivanSummonRocks = {
        loop = false,
        gain = 1,
        source_group = "SPECIALS",
        files = {"kre_sfx_arivan_stonesummon_v2.ogg"}
    },
    ElvesHeroArivanTaunt = {
        loop = false,
        gain = 1,
        ignore = 1,
        mode = "sequence",
        source_group = "TAUNTS",
        files = {"Arivan_Confirm-01b.ogg", "Arivan_Confirm-02c.ogg", "Arivan_Confirm-03a.ogg",
                 "Arivan_Confirm04-01a.ogg"}
    },
    ElvesHeroArivanTauntIntro = {
        loop = false,
        gain = 1,
        source_group = "TAUNTS",
        files = {"Level_up.ogg"}
    },
    ElvesHeroArivanTauntSelect = {
        loop = false,
        gain = 1,
        source_group = "TAUNTS",
        files = {"Arivan_Confirm04-01a.ogg"}
    },
    ElvesHeroBolverkCry = {
        loop = false,
        gain = 0.8,
        source_group = "TAUNTS",
        files = {"kro_sfx_bolverk_bearcry[op1].ogg"}
    },
    ElvesHeroBolverkDeath = {
        loop = false,
        gain = 1,
        source_group = "TAUNTS",
        files = {"VarlBerserker_death-01c.ogg"}
    },
    ElvesHeroBolverkSlash = {
        loop = false,
        gain = 0.8,
        source_group = "TAUNTS",
        files = {"kro_sfx_bolverk_doubleslash[gore].ogg"}
    },
    ElvesHeroBolverkTaunt = {
        loop = false,
        gain = 1,
        ignore = 1,
        mode = "sequence",
        source_group = "TAUNTS",
        files = {"VarlBerserker_confirm-01a.ogg", "VarlBerserker_confirm-02a.ogg", "VarlBerserker_confirm-03c.ogg",
                 "VarlBerserker_confirm-04a.ogg"}
    },
    ElvesHeroBolverkTauntSelect = {
        loop = false,
        gain = 1,
        source_group = "TAUNTS",
        files = {"VarlBerserker_confirm-01a.ogg"}
    },
    ElvesHeroBolverkTauntIntro = {
        loop = false,
        gain = 1,
        source_group = "TAUNTS",
        files = {"Level_up.ogg"}
    },
    ElvesHeroBruceDeath = {
        loop = false,
        gain = 1,
        source_group = "TAUNTS",
        files = {"Bruce_death[2]-01g.ogg"}
    },
    ElvesHeroBruceGriveousBites = {
        loop = false,
        gain = 1,
        source_group = "SFX",
        files = {"kro_sfx_bruce_griveousbites.ogg"}
    },
    ElvesHeroBruceGuardianLionsCast = {
        loop = false,
        gain = 0.8,
        source_group = "SFX",
        files = {"kro_sfx_bruce_guardianlions[spell+roar].ogg"}
    },
    ElvesHeroBruceGuardianLionsLoop = {
        loop = true,
        gain = 0.3,
        source_group = "SFX",
        files = {"kro_sfx_bruce_guardianlions[loop-v2-op1].ogg"}
    },
    ElvesHeroBruceGuardianLionsLoopEnd = {
        loop = false,
        gain = 0.3,
        source_group = "SFX",
        files = {"kro_sfx_bruce_guardianlions-hit[loop-end].ogg"}
    },
    ElvesHeroBruceGuardianLionsLoopStart = {
        loop = false,
        gain = 0.3,
        source_group = "SFX",
        files = {"kro_sfx_bruce_guardianlions-hit[loop-start].ogg"}
    },
    ElvesHeroBruceKingsRoar = {
        loop = false,
        gain = 0.8,
        source_group = "SFX",
        files = {"kro_sfx_bruce_kingsroar[op1-conimpacto].ogg"}
    },
    ElvesHeroBruceTaunt = {
        loop = false,
        gain = 1,
        ignore = 1,
        mode = "sequence",
        source_group = "TAUNTS",
        files = {"Bruce_confirm[2]-01b.ogg", "Bruce_confirm[2]-02c.ogg", "Bruce_confirm_03d.ogg",
                 "Bruce_confirm[2]-04c.ogg"}
    },
    ElvesHeroBruceTauntIntro = {
        loop = false,
        gain = 1,
        source_group = "TAUNTS",
        files = {"Level_up.ogg"}
    },
    ElvesHeroBruceTauntSelect = {
        loop = false,
        gain = 1,
        source_group = "TAUNTS",
        files = {"Bruce_confirm[2]-04c.ogg"}
    },
    ElvesHeroCathaDeath = {
        loop = false,
        gain = 1,
        source_group = "TAUNTS",
        files = {"Catha_Death-01c.ogg"}
    },
    ElvesHeroCathaDust = {
        loop = false,
        gain = 1,
        source_group = "SPECIALS",
        files = {"kre_sfx_catha_fairydust.ogg"}
    },
    ElvesHeroCathaFuryHit = {
        loop = false,
        gain = 0.1,
        source_group = "SPECIALS",
        files = {"kre_sfx_catha_fairyfury[hit]_v2.ogg"}
    },
    ElvesHeroCathaFurySummon = {
        loop = false,
        gain = 1,
        source_group = "SPECIALS",
        files = {"kre_sfx_catha_fairyfury[summon].ogg"}
    },
    ElvesHeroCathaSoul = {
        loop = false,
        gain = 1,
        source_group = "SPECIALS",
        files = {"kre_sfx_catha_fairysoul_v1.ogg"}
    },
    ElvesHeroCathaTaleDeath = {
        loop = false,
        gain = 0.1,
        source_group = "SPECIALS",
        files = {"kre_sfx_catha_fairytale[death].ogg"}
    },
    ElvesHeroCathaTaleSummon = {
        loop = false,
        gain = 1,
        source_group = "SPECIALS",
        files = {"kre_sfx_catha_fairytale[summon].ogg"}
    },
    ElvesHeroCathaTaunt = {
        loop = false,
        gain = 1,
        ignore = 1,
        mode = "sequence",
        source_group = "TAUNTS",
        files = {"Catha_Confirm-01c.ogg", "Catha_Confirm-02a.ogg", "Catha_Confirm-03c.ogg", "Catha_Confirm-04d.ogg"}
    },
    ElvesHeroCathaTauntIntro = {
        loop = false,
        gain = 1,
        source_group = "TAUNTS",
        files = {"Level_up.ogg"}
    },
    ElvesHeroCathaTauntSelect = {
        loop = false,
        gain = 1,
        source_group = "TAUNTS",
        files = {"Catha_Confirm-02a.ogg"}
    },
    ElvesHeroDenasCelebrity = {
        loop = false,
        gain = 0.8,
        source_group = "SPECIALS",
        files = {"kro_sfx_princedenas_celebrity_v1[severalshots].ogg"}
    },
    ElvesHeroDenasDeath = {
        loop = false,
        gain = 1,
        source_group = "TAUNTS",
        files = {"PrinceDenas-death_01a.ogg"}
    },
    ElvesHeroDenasKingsguardTaunt = {
        loop = false,
        mode = "sequence",
        gain = 1,
        source_group = "TAUNTS",
        files = {"Kingsguard_01d.ogg", "Kingsguard_02c.ogg"}
    },
    ElvesHeroDenasMighty = {
        loop = false,
        gain = 1,
        source_group = "SPECIALS",
        files = {"kro_sfx_princedenas_mighty_v3[convoz_op3].ogg"}
    },
    ElvesHeroDenasSworn = {
        loop = false,
        gain = 1,
        source_group = "SPECIALS",
        files = {"Eridan_Death-01a.ogg"}
    },
    ElvesHeroDenasSybarite = {
        loop = false,
        gain = 1,
        source_group = "SPECIALS",
        files = {"kro_sfx_princedenas_sybarite_v1[op1].ogg"}
    },
    ElvesHeroDenasTaunt = {
        loop = false,
        gain = 1,
        ignore = 1,
        mode = "sequence",
        source_group = "TAUNTS",
        files = {"PrinceDenas-confirm_01a.ogg", "PrinceDenas-confirm_02c.ogg", "PrinceDenas-confirm_03b.ogg",
                 "PrinceDenas-confirm_04a.ogg"}
    },
    ElvesHeroDenasTauntIntro = {
        loop = false,
        gain = 1,
        source_group = "TAUNTS",
        files = {"Level_up.ogg"}
    },
    ElvesHeroDenasTauntSelect = {
        loop = false,
        gain = 1,
        source_group = "TAUNTS",
        files = {"PrinceDenas-confirm_04a.ogg"}
    },
    ElvesHeroDenasWealthy = {
        loop = false,
        gain = 1,
        source_group = "SPECIALS",
        files = {"kro_sfx_princedenas_wealthy_v1[op2].ogg"}
    },
    ElvesHeroDuraxArmblade = {
        loop = false,
        gain = 1,
        source_group = "SPECIALS",
        files = {"kro_sfx_durax_armblade.ogg"}
    },
    ElvesHeroDuraxCrystallites = {
        loop = false,
        gain = 1,
        source_group = "SPECIALS",
        files = {"kro_sfx_durax_crystallites.ogg"}
    },
    ElvesHeroDuraxDeath = {
        loop = false,
        gain = 1,
        source_group = "TAUNTS",
        files = {"kro_sfx_durax_death[op1].ogg"}
    },
    ElvesHeroDuraxLethalPrismShoot = {
        loop = false,
        gain = 1,
        source_group = "SPECIALS",
        files = {"kro_sfx_durax_lethalprism_shot_v2.ogg"}
    },
    ElvesHeroDuraxShardSpearHit = {
        loop = false,
        gain = 1,
        source_group = "SPECIALS",
        files = {"kro_sfx_durax_shardspear[impact].ogg"}
    },
    ElvesHeroDuraxShardSpearThrow = {
        loop = false,
        gain = 1,
        source_group = "SPECIALS",
        files = {"kro_sfx_durax_shardspear[throw].ogg"}
    },
    ElvesHeroDuraxTaunt = {
        loop = false,
        gain = 1,
        ignore = 1,
        mode = "sequence",
        source_group = "TAUNTS",
        files = {"Durax_01a[wet].ogg", "Durax_02a[wet].ogg", "Durax_03a[wet].ogg", "Durax_04c[wet].ogg"}
    },
    ElvesHeroDuraxTauntIntro = {
        loop = false,
        gain = 1,
        source_group = "TAUNTS",
        files = {"Level_up.ogg"}
    },
    ElvesHeroDuraxTauntSelect = {
        loop = false,
        gain = 1,
        source_group = "TAUNTS",
        files = {"Durax_04c[wet].ogg"}
    },
    ElvesHeroDuraxUltimate = {
        loop = false,
        gain = 1,
        source_group = "SPECIALS",
        files = {"kro_sfx_durax_ultimate.ogg"}
    },
    ElvesHeroDuraxWalkLoop = {
        loop = true,
        gain = 0.3,
        source_group = "SPECIALS",
        files = {"kro_sfx_durax_movement[loop_op1].ogg"}
    },
    ElvesHeroDuraxWalkLoopEnd = {
        loop = false,
        gain = 1,
        source_group = "SPECIALS",
        files = {"kro_sfx_durax_movement[loop_end].ogg"}
    },
    ElvesHeroEldritchBlade = {
        loop = false,
        gain = 1,
        source_group = "SPECIALS",
        files = {"kro_sfx_regson_bladescast_v3[conenergia].ogg"}
    },
    ElvesHeroEldritchBladeCharge = {
        loop = false,
        gain = 1,
        source_group = "SPECIALS",
        files = {"kro_sfx_regson_bladescast_v3[sinenergia].ogg"}
    },
    ElvesHeroEldritchDeath = {
        loop = false,
        gain = 1,
        source_group = "TAUNTS",
        files = {"Reg'son-death_01c.ogg"}
    },
    ElvesHeroEldritchShield = {
        loop = false,
        gain = 1,
        source_group = "SPECIALS",
        files = {"Eridan_Death-01a.ogg"}
    },
    ElvesHeroEldritchSlash = {
        loop = false,
        gain = 0.5,
        source_group = "SPECIALS",
        files = {"kro_sfx_regson_slash_v1.ogg"}
    },
    ElvesHeroEldritchTaunt = {
        loop = false,
        gain = 1,
        ignore = 1,
        mode = "sequence",
        source_group = "TAUNTS",
        files = {"Reg'son-confirm_01a.ogg", "Reg'son-confirm_02c.ogg", "Reg'son-confirm_03d.ogg",
                 "Reg'son-confirm_04a.ogg"}
    },
    ElvesHeroEldritchTauntIntro = {
        loop = false,
        gain = 1,
        source_group = "TAUNTS",
        files = {"Level_up.ogg"}
    },
    ElvesHeroEldritchTauntSelect = {
        loop = false,
        gain = 1,
        source_group = "TAUNTS",
        files = {"Reg'son-confirm_04a.ogg"}
    },
    ElvesHeroEldritchVindicator = {
        loop = false,
        gain = 1,
        source_group = "SPECIALS",
        files = {"kro_sfx_regson_vindicator_v3.ogg"}
    },
    ElvesHeroEridanDeath = {
        loop = false,
        gain = 1,
        source_group = "TAUNTS",
        files = {"Eridan_Death-01a.ogg"}
    },
    ElvesHeroEridanDoubleStrike = {
        loop = false,
        gain = 1,
        source_group = "SPECIALS",
        files = {"kre_sfx_eridan_doublestrike_v2[mid].ogg"}
    },
    ElvesHeroEridanNimbleFencing = {
        loop = false,
        gain = 1,
        source_group = "SPECIALS",
        files = {"kre_sfx_eridan_nimblefencing.ogg"}
    },
    ElvesHeroEridanTaunt = {
        loop = false,
        gain = 1,
        ignore = 1,
        mode = "sequence",
        source_group = "TAUNTS",
        files = {"Eridan_Confirm-01d.ogg", "Eridan_Confirm-03b.ogg", "Eridan_Confirm03-01a.ogg",
                 "Eridan_confirmextra-01a.ogg"}
    },
    ElvesHeroEridanTauntIntro = {
        loop = false,
        gain = 1,
        source_group = "TAUNTS",
        files = {"Level_up.ogg"}
    },
    ElvesHeroEridanTauntSelect = {
        loop = false,
        gain = 1,
        source_group = "TAUNTS",
        files = {"Eridan_Confirm-03b.ogg"}
    },
    ElvesHeroFaustusAttack = {
        loop = false,
        gain = 0.3,
        source_group = "TAUNTS",
        files = {"kro_sfx_faustus_normalattack_v1.ogg"}
    },
    ElvesHeroFaustusDeath = {
        loop = false,
        gain = 1,
        source_group = "TAUNTS",
        files = {"Faustus-death_01e2.ogg"}
    },
    ElvesHeroFaustusEnervation = {
        loop = false,
        gain = 1,
        source_group = "TAUNTS",
        files = {"kro_sfx_faustus_enervation_v2_[op1].ogg"}
    },
    ElvesHeroFaustusFire = {
        loop = false,
        gain = 1,
        source_group = "TAUNTS",
        files = {"kro_sfx_faustus_liquidfire_v2_sinchimes.ogg"}
    },
    ElvesHeroFaustusFireLoop = {
        loop = true,
        gain = 0.3,
        source_group = "SPECIALS",
        files = {"kro_sfx_faustus_fireloop_v1.ogg"}
    },
    ElvesHeroFaustusRayKill = {
        loop = false,
        gain = 1,
        source_group = "TAUNTS",
        files = {"kro_sfx_veznan_faustus_killray_v3.ogg"}
    },
    ElvesHeroFaustusTaunt = {
        loop = false,
        gain = 1,
        ignore = 1,
        mode = "sequence",
        source_group = "TAUNTS",
        files = {"Faustus-confirm_04b2.ogg", "Faustus-confirm_02b2.ogg", "Faustus-confirm_03a2.ogg",
                 "Faustus-confirm_01b2.ogg"}
    },
    ElvesHeroFaustusTauntIntro = {
        loop = false,
        gain = 1,
        source_group = "TAUNTS",
        files = {"Level_up.ogg"}
    },
    ElvesHeroFaustusTauntSelect = {
        loop = false,
        gain = 1,
        source_group = "TAUNTS",
        files = {"Faustus-confirm_01b2.ogg"}
    },
    ElvesHeroFaustusTeleport = {
        loop = false,
        gain = 1,
        source_group = "TAUNTS",
        files = {"kro_sfx_faustus_teleport_v1[sinarpa].ogg"}
    },
    ElvesHeroFaustusUltimate = {
        loop = false,
        gain = 1,
        source_group = "TAUNTS",
        files = {"kro_sfx_faustus_activate[op2].ogg"}
    },
    ElvesHeroForestElementalAttack = {
        loop = false,
        gain = 0.3,
        source_group = "DEATH",
        files = {"kre_sfx_hyena_specialstomp.ogg"}
    },
    ElvesHeroForestElementalDeath = {
        loop = false,
        gain = 1,
        source_group = "TAUNTS",
        files = {"Bravebark-death_01a.ogg"}
    },
    ElvesHeroForestElementalHealing = {
        loop = false,
        gain = 1,
        source_group = "SPECIALS",
        files = {"kro_sfx_bravebark_healing_v1.ogg"}
    },
    ElvesHeroForestElementalHomerun = {
        loop = false,
        gain = 1,
        source_group = "SPECIALS",
        files = {"kro_sfx_bravebark_branchball_v1[op1].ogg"}
    },
    ElvesHeroForestElementalSpikes = {
        loop = false,
        gain = 1,
        source_group = "SPECIALS",
        files = {"kro_sfx_bravebark_rootspikes_v1.ogg"}
    },
    ElvesHeroForestElementalTaunt = {
        loop = false,
        gain = 1,
        ignore = 1,
        mode = "sequence",
        source_group = "TAUNTS",
        files = {"Bravebark-confirm_01c.ogg", "Bravebark-confirm_02b.ogg", "Bravebark-confirm_03d.ogg",
                 "Bravebark-confirm_04d.ogg"}
    },
    ElvesHeroForestElementalTauntIntro = {
        loop = false,
        gain = 1,
        source_group = "TAUNTS",
        files = {"Level_up.ogg"}
    },
    ElvesHeroForestElementalTauntSelect = {
        loop = false,
        gain = 1,
        source_group = "TAUNTS",
        files = {"Bravebark-confirm_04d.ogg"}
    },
    ElvesHeroForestElementalTeleportIn = {
        loop = false,
        gain = 1,
        source_group = "SPECIALS",
        files = {"kro_sfx_bravebark_teleport-in_v1.ogg"}
    },
    ElvesHeroForestElementalTeleportOut = {
        loop = false,
        gain = 1,
        source_group = "SPECIALS",
        files = {"kro_sfx_bravebark_teleport-out_v1.ogg"}
    },
    ElvesHeroForestElementalTrees = {
        loop = false,
        gain = 0.3,
        source_group = "SPECIALS",
        files = {"kro_sfx_bravebark_oakseeds_v1.ogg"}
    },
    ElvesHeroForestElementalUltimate = {
        loop = false,
        gain = 1,
        source_group = "SPECIALS",
        files = {"kro_sfx_bravebark_v2[spikesbajos].ogg"}
    },
    ElvesHeroGyroAttack = {
        loop = false,
        gain = 0.5,
        source_group = "SFX",
        files = {"kro_sfx_wilbur_attack[concasquillos].ogg"}
    },
    ElvesHeroGyroBombsMarch = {
        loop = true,
        gain = 0.8,
        source_group = "SFX",
        files = {"kro_sfx_wilbur_bombsmarch[op1].ogg"}
    },
    ElvesHeroGyroBoombBox = {
        loop = false,
        gain = 1,
        source_group = "SFX",
        files = {"kro_sfx_wilbur_boombox.ogg"}
    },
    ElvesHeroGyroBoombBoxTouchdown = {
        loop = false,
        gain = 1,
        source_group = "SFX",
        files = {"kro_sfx_wilbur_boombox_box.ogg"}
    },
    ElvesHeroGyroDeath = {
        loop = false,
        gain = 0.8,
        source_group = "TAUNTS",
        files = {"Gyro_death-01d.ogg"}
    },
    ElvesHeroGyroDronesAttack = {
        loop = false,
        gain = 0.3,
        source_group = "SFX",
        files = {"kro_sfx_wilbur_dronesattack[metralla]_cut.ogg"}
    },
    ElvesHeroGyroDronesSpawn = {
        loop = false,
        gain = 1,
        source_group = "SFX",
        files = {"kro_sfx_wilbur_calldrones.ogg"}
    },
    ElvesHeroGyroSmokeLaunch = {
        loop = false,
        gain = 0.8,
        source_group = "SFX",
        files = {"kro_sfx_wilbur_smokespit.ogg"}
    },
    ElvesHeroGyroTaunt = {
        loop = false,
        gain = 1,
        ignore = 1,
        mode = "sequence",
        source_group = "TAUNTS",
        files = {"Gyro_confirm-01c.ogg", "Gyro_confirm-02c.ogg", "Gyro_confirm-03c.ogg", "Gyro_confirm-04b.ogg"}
    },
    ElvesHeroGyroTauntIntro = {
        loop = false,
        gain = 1,
        source_group = "TAUNTS",
        files = {"Level_up.ogg"}
    },
    ElvesHeroGyroTauntSelect = {
        loop = false,
        gain = 1,
        source_group = "TAUNTS",
        files = {"Gyro_confirm-01c.ogg"}
    },
    ElvesHeroLilithAngelsCast = {
        loop = false,
        gain = 0.8,
        source_group = "SFX",
        files = {"kro_sfx_lilith_ultimate[darkangels-cast].ogg"}
    },
    ElvesHeroLilithAngelsHit = {
        loop = false,
        gain = 0.8,
        source_group = "SFX",
        files = {"kro_sfx_lilith_ultimate[darkangels-hit].ogg"}
    },
    ElvesHeroLilithDeath = {
        loop = false,
        gain = 0.8,
        source_group = "TAUNTS",
        files = {"Lilith_death-01a[wet].ogg"}
    },
    ElvesHeroLilithInfernalWheel = {
        loop = false,
        gain = 0.8,
        source_group = "SFX",
        files = {"kro_sfx_lilith_infernalwheel.ogg"}
    },
    ElvesHeroLilithMeteorsHit = {
        loop = false,
        gain = 0.8,
        source_group = "SFX",
        files = {"kro_sfx_lilith_ultimate[meteors-impact-op1_singlehit].ogg"}
    },
    ElvesHeroLilithRangeShoot = {
        loop = false,
        gain = 0.5,
        source_group = "SFX",
        files = {"kro_sfx_veznan_range_shoot_v1.ogg"}
    },
    ElvesHeroLilithReapersHarvest = {
        loop = false,
        gain = 0.8,
        source_group = "SFX",
        files = {"kro_sfx_lilith_reaperharvest.ogg"}
    },
    ElvesHeroLilithResurrection = {
        loop = false,
        gain = 0.8,
        source_group = "SFX",
        files = {"kro_sfx_lilith_resurrection[op2-conchime].ogg"}
    },
    ElvesHeroLilithSoulEater = {
        loop = false,
        gain = 0.8,
        source_group = "SFX",
        files = {"kro_sfx_lilith_soulreaper[op1].ogg"}
    },
    ElvesHeroLilithTaunt = {
        loop = false,
        gain = 1,
        ignore = 1,
        mode = "sequence",
        source_group = "TAUNTS",
        files = {"Lilith_confirm-01d[wet].ogg", "Lilith_confirm-02d[wet].ogg", "Lilith_confirm-03f[wet].ogg",
                 "Lilith_confirm-04a[wet].ogg"}
    },
    ElvesHeroLilithTauntIntro = {
        loop = false,
        gain = 1,
        source_group = "TAUNTS",
        files = {"Level_up.ogg"}
    },
    ElvesHeroLilithTauntSelect = {
        loop = false,
        gain = 1,
        source_group = "TAUNTS",
        files = {"Lilith_confirm-01d[wet].ogg"}
    },
    ElvesHeroLynnCurseDespair = {
        loop = false,
        gain = 1,
        source_group = "SPECIALS",
        files = {"kro_sfx_bitteringrancor_lynn-curseofdispair[conprecarga].ogg"}
    },
    ElvesHeroLynnDeath = {
        loop = false,
        gain = 1,
        source_group = "TAUNTS",
        files = {"Lynn_death_01b.ogg"}
    },
    ElvesHeroLynnFateSealed = {
        loop = false,
        gain = 1,
        source_group = "SPECIALS",
        files = {"kro_sfx_bitteringrancor_lynn-fatesealed.ogg"}
    },
    ElvesHeroLynnHexfury = {
        loop = false,
        gain = 1,
        source_group = "SPECIALS",
        files = {"kro_sfx_bitteringrancor_lynn-hexfury[op3].ogg"}
    },
    ElvesHeroLynnTaunt = {
        loop = false,
        gain = 1,
        ignore = 1,
        mode = "sequence",
        source_group = "TAUNTS",
        files = {"Lynn_confirm_01a.ogg", "Lynn_confirm_02c.ogg", "Lynn_confirm_03a.ogg", "Lynn_confirm_04d.ogg"}
    },
    ElvesHeroLynnTauntIntro = {
        loop = false,
        gain = 1,
        source_group = "TAUNTS",
        files = {"Level_up.ogg"}
    },
    ElvesHeroLynnTauntSelect = {
        loop = false,
        gain = 1,
        source_group = "TAUNTS",
        files = {"Lynn_confirm_01a.ogg"}
    },
    ElvesHeroLynnWeakening = {
        loop = false,
        gain = 1,
        source_group = "SPECIALS",
        files = {"kro_sfx_bitteringrancor_lynn-weakeningcurse[sincrackle].ogg"}
    },
    ElvesHeroPhoenixAttack = {
        loop = false,
        gain = 0.5,
        source_group = "SFX",
        files = {"kro_sfx_phoenix_basicattack.ogg"}
    },
    ElvesHeroPhoenixBlazingOffspringHit = {
        loop = false,
        gain = 0.5,
        source_group = "SPECIALS",
        files = {"kro_sfx_phoenix_blazingoffspring_hit_v2.ogg"}
    },
    ElvesHeroPhoenixBlazingOffspringShoot = {
        loop = false,
        gain = 0.5,
        source_group = "SPECIALS",
        files = {"kro_sfx_phoenix_blazingoffspring_shot[op1].ogg"}
    },
    ElvesHeroPhoenixDeath = {
        loop = false,
        gain = 1,
        source_group = "TAUNTS",
        files = {"Phoenix2-death_01a.ogg"}
    },
    ElvesHeroPhoenixFireEggActivate = {
        loop = false,
        gain = 0.5,
        source_group = "SPECIALS",
        files = {"kro_sfx_phoenix_fireegg_activate_v2.ogg"}
    },
    ElvesHeroPhoenixFireEggDrop = {
        loop = false,
        gain = 0.5,
        source_group = "SPECIALS",
        files = {"kro_sfx_phoenix_fireegg_v3.ogg"}
    },
    ElvesHeroPhoenixFireEggExplosion = {
        loop = false,
        gain = 0.5,
        source_group = "SPECIALS",
        files = {"kro_sfx_phoenix_eggexplosion.ogg"}
    },
    ElvesHeroPhoenixImmolation = {
        loop = false,
        gain = 0.8,
        source_group = "SPECIALS",
        files = {"kro_sfx_phoenix_immolation_v2.ogg"}
    },
    ElvesHeroPhoenixRingOfFireExplode = {
        loop = false,
        gain = 0.5,
        source_group = "SPECIALS",
        files = {"kro_sfx_phoenix_ringoffire_explode_v2.ogg"}
    },
    ElvesHeroPhoenixRingOfFireSpawn = {
        loop = false,
        gain = 0.5,
        source_group = "SPECIALS",
        files = {"kro_sfx_phoenix_ringoffire_spawn[op2].ogg"}
    },
    ElvesHeroPhoenixTaunt = {
        loop = false,
        gain = 0.8,
        ignore = 1,
        mode = "sequence",
        source_group = "TAUNTS",
        files = {"Phoenix2-death_01b.ogg", "Phoenix2-death_01a.ogg"}
    },
    ElvesHeroPhoenixTauntIntro = {
        loop = false,
        gain = 1,
        source_group = "TAUNTS",
        files = {"Level_up.ogg"}
    },
    ElvesHeroPhoenixTauntSelect = {
        loop = false,
        gain = 1,
        source_group = "TAUNTS",
        files = {"Phoenix2-death_01b.ogg"}
    },
    ElvesHeroRagAttack = {
        loop = false,
        gain = 1,
        source_group = "SPECIALS",
        files = {"kro_sfx_raggified_attack.ogg"}
    },
    ElvesHeroRagDeath = {
        loop = false,
        gain = 1,
        source_group = "TAUNTS",
        files = {"RazzAndRags-death_01a.ogg"}
    },
    ElvesHeroRagGnomeShot = {
        loop = false,
        gain = 1,
        source_group = "SPECIALS",
        files = {"kro_sfx_gnome_shot[op1_conchime].ogg"}
    },
    ElvesHeroRagGroundStomp = {
        loop = false,
        gain = 1,
        source_group = "SPECIALS",
        files = {"kro_sfx_raggified_groundstomp[medium].ogg"}
    },
    ElvesHeroRagHammer = {
        loop = false,
        gain = 0.5,
        source_group = "SPECIALS",
        files = {"kro_sfx_hammertime[op2].ogg"}
    },
    ElvesHeroRagHammerTime = {
        loop = true,
        gain = 0.3,
        source_group = "GUI",
        files = {"kro_sfx_hammertime[op1_12bits].ogg"}
    },
    ElvesHeroRagKamihare = {
        loop = false,
        gain = 1,
        source_group = "SPECIALS",
        files = {"kro_sfx_gnome_kamihare[sinpops].ogg"}
    },
    ElvesHeroRagSpawn = {
        loop = false,
        gain = 1,
        source_group = "SPECIALS",
        files = {"kro_sfx_angrygnome_objectspawn[op2].ogg"}
    },
    ElvesHeroRagTaunt = {
        loop = false,
        gain = 1,
        ignore = 1,
        mode = "sequence",
        source_group = "TAUNTS",
        files = {"RazzAndRags_01b.ogg", "RazzAndRags_02b.ogg", "RazzAndRags_03d.ogg", "RazzAndRags_04c.ogg"}
    },
    ElvesHeroRagTauntIntro = {
        loop = false,
        gain = 1,
        source_group = "TAUNTS",
        files = {"Level_up.ogg"}
    },
    ElvesHeroRagTauntSelect = {
        loop = false,
        gain = 1,
        source_group = "TAUNTS",
        files = {"RazzAndRags_02b.ogg"}
    },
    ElvesHeroRagTransform = {
        loop = false,
        gain = 1,
        source_group = "SPECIALS",
        files = {"kro_sfx_raggified_transform[op2].ogg"}
    },
    ElvesHeroVeznanArcaneNova = {
        loop = false,
        gain = 1,
        source_group = "SPECIALS",
        files = {"kro_sfx_veznan_arcanenova_v1.ogg"}
    },
    ElvesHeroVeznanDarkPact = {
        loop = false,
        gain = 1,
        source_group = "SPECIALS",
        files = {"kro_sfx_veznan_darkpact_v1.ogg"}
    },
    ElvesHeroVeznanDeath = {
        loop = false,
        gain = 1,
        source_group = "TAUNTS",
        files = {"Veznan_death-[new]01b.ogg"}
    },
    ElvesHeroVeznanDemonDeath = {
        loop = false,
        gain = 1,
        source_group = "SPECIALS",
        files = {"kro_sfx_veznan_demondeath_v3.ogg"}
    },
    ElvesHeroVeznanDemonFireballHit = {
        loop = false,
        gain = 1,
        source_group = "SPECIALS",
        files = {"kro_sfx_veznan_demonfireball_hit_v3.1.ogg"}
    },
    ElvesHeroVeznanDemonFireballThrow = {
        loop = false,
        gain = 1,
        source_group = "SPECIALS",
        files = {"kro_sfx_veznan_demonfireball_throw_v3.ogg"}
    },
    ElvesHeroVeznanMagicSchackles = {
        loop = false,
        gain = 1,
        source_group = "SPECIALS",
        files = {"kro_sfx_veznan_magicshackles_v1[op2]-01.ogg"}
    },
    ElvesHeroVeznanRangeShoot = {
        loop = false,
        gain = 0.6,
        source_group = "SPECIALS",
        files = {"kro_sfx_veznan_range_shoot_v1.ogg"}
    },
    ElvesHeroVeznanSoulBurn = {
        loop = false,
        gain = 1,
        source_group = "SPECIALS",
        files = {"kro_sfx_veznan_soulburn_v8[sinimpacto].ogg"}
    },
    ElvesHeroVeznanTaunt = {
        loop = false,
        gain = 1,
        ignore = 1,
        mode = "sequence",
        source_group = "TAUNTS",
        files = {"Veznan-confirm_01e.ogg", "Veznan-confirm_02f.ogg", "Veznan-confirm_03_custom_fb.ogg",
                 "Veznan-confirm_04_custom_ec.ogg"}
    },
    ElvesHeroVeznanTauntIntro = {
        loop = false,
        gain = 1,
        source_group = "TAUNTS",
        files = {"Level_up.ogg"}
    },
    ElvesHeroVeznanTauntSelect = {
        loop = false,
        gain = 1,
        source_group = "TAUNTS",
        files = {"Veznan-confirm_03_custom_fb.ogg"}
    },
    ElvesHeroVeznanTeleport = {
        loop = false,
        gain = 1,
        source_group = "SPECIALS",
        files = {"kro_sfx_veznan_teleport_v1.ogg"}
    },
    ElvesHeroXinAfterTeleportIn = {
        loop = false,
        gain = 1,
        source_group = "SPECIALS",
        files = {"kro_sfx_xin_tele-in_v3[op1].ogg"}
    },
    ElvesHeroXinAfterTeleportOut = {
        loop = false,
        gain = 1,
        source_group = "SPECIALS",
        files = {"kro_sfx_xin_tele-out_v3.ogg"}
    },
    ElvesHeroXinDaringStrikeHit = {
        loop = false,
        gain = 1,
        source_group = "SPECIALS",
        files = {"kro_sfx_xin_daringstrikehit_v1.ogg"}
    },
    ElvesHeroXinDeath = {
        loop = false,
        gain = 1,
        source_group = "TAUNTS",
        files = {"Xin-death_01a.ogg"}
    },
    ElvesHeroXinInspire = {
        loop = false,
        gain = 1,
        source_group = "SPECIALS",
        files = {"kro_sfx_xin_inspire_v3[op1].ogg"}
    },
    ElvesHeroXinMindOverBody = {
        loop = false,
        gain = 1,
        source_group = "SPECIALS",
        files = {"kro_sfx_xin_mindoverbody.ogg"}
    },
    ElvesHeroXinPandaStyle = {
        loop = false,
        gain = 1,
        source_group = "SPECIALS",
        files = {"kro_sfx_xin_pandastyle_v3[op2].ogg"}
    },
    ElvesHeroXinPandamonium = {
        loop = false,
        gain = 1,
        source_group = "SPECIALS",
        files = {"kro_sfx_xin_pandamonium_[op1].ogg"}
    },
    ElvesHeroXinPandamoniumHit = {
        loop = false,
        gain = 1,
        source_group = "SPECIALS",
        files = {"kro_sfx_xin_pandamonium-hit1_v1.ogg", "kro_sfx_xin_pandamonium-hit2_v1.ogg"}
    },
    ElvesHeroXinPoleHit = {
        loop = false,
        gain = 1,
        source_group = "SPECIALS",
        files = {"kro_sfx_xin_polehit1_v3[conhoo].ogg", "kro_sfx_xin_polehit2_v3[conhoo].ogg"}
    },
    ElvesHeroXinTaunt = {
        loop = false,
        gain = 1,
        ignore = 1,
        mode = "sequence",
        source_group = "TAUNTS",
        files = {"Xin-confirm_01c.ogg", "Xin-confirm_02b.ogg", "Xin-confirm_03a.ogg", "Xin-confirm_04c.ogg"}
    },
    ElvesHeroXinTauntIntro = {
        loop = false,
        gain = 1,
        source_group = "TAUNTS",
        files = {"Level_up.ogg"}
    },
    ElvesHeroXinTauntSelect = {
        loop = false,
        gain = 1,
        source_group = "TAUNTS",
        files = {"Xin-confirm_02b.ogg"}
    },
    ElvesHyenaDeath = {
        loop = false,
        gain = 1,
        source_group = "SFX",
        files = {"kre_sfx_hyena_death.ogg"}
    },
    ElvesHyenaGrowl = {
        loop = false,
        gain = 1,
        source_group = "SFX",
        files = {"kre_sfx_hyena_howl[op1_singrowl].ogg"}
    },
    ElvesHyenaStomp = {
        loop = false,
        gain = 1,
        source_group = "SFX",
        files = {"kre_sfx_hyena_specialstomp.ogg"}
    },
    ElvesHyenaWagonEnd = {
        loop = false,
        gain = 1,
        source_group = "SFX",
        files = {"kre_sfx_hyena_wagonloop[ending].ogg"}
    },
    ElvesHyenaWagonExplosion = {
        loop = false,
        gain = 0.6,
        source_group = "SFX",
        files = {"kre_sfx_hyena_wagonexplosion.ogg"}
    },
    ElvesHyenaWagonLoop = {
        loop = true,
        gain = 0.6,
        source_group = "SFX",
        files = {"kre_sfx_hyena_wagonloop[concadenas].ogg"}
    },
    ElvesInAppHandOfMidas = {
        loop = false,
        gain = 0.8,
        source_group = "SPECIALS",
        files = {"kro_sfx_inapp-handofmidas[op1].ogg"}
    },
    ElvesInAppHandOfMidasLoop = {
        loop = true,
        gain = 0.6,
        source_group = "SPECIALS",
        files = {"kro_sfx_inapp-handofmidas-active[op3]C.ogg"}
    },
    ElvesInAppHornOfHeroism = {
        loop = false,
        gain = 0.8,
        source_group = "SPECIALS",
        files = {"kro_sfx_inapp_hornofheroism[op2].ogg"}
    },
    ElvesInAppRodDragon = {
        loop = false,
        gain = 0.8,
        source_group = "SPECIALS",
        files = {"kre_sfx_arivan_fireballhit_v3.ogg"}
    },
    ElvesInAppTearOfElynie = {
        loop = false,
        gain = 0.8,
        source_group = "SPECIALS",
        files = {"kro_sfx_inapp-tearofelynie_v2[conlacrimosa].ogg"}
    },
    ElvesInAppTeleportGemEnemiesIn = {
        loop = false,
        gain = 0.8,
        source_group = "SPECIALS",
        files = {"kro_sfx_inapp-teleportgem_v2[enemiesin].ogg"}
    },
    ElvesInAppTeleportGemEnemiesOut = {
        loop = false,
        gain = 0.8,
        source_group = "SPECIALS",
        files = {"kro_sfx_inapp-teleportgem_v2[enemiesout].ogg"}
    },
    ElvesInAppTeleportScroll = {
        loop = false,
        gain = 0.8,
        source_group = "SPECIALS",
        files = {"kro_sfx_inapp-teleportscroll_v2[sinslam].ogg"}
    },
    ElvesMageHighElvenSentinelTaunt = {
        loop = false,
        gain = 0.6,
        source_group = "TAUNTS",
        files = {"HighMage_ArcaneSentinel-01c.ogg"}
    },
    ElvesMageHighElvenTaunt = {
        loop = false,
        gain = 0.6,
        source_group = "TAUNTS",
        files = {"HighMage_Ready-01a.ogg"}
    },
    ElvesMageHighElvenTimelapseTaunt = {
        loop = false,
        gain = 0.6,
        source_group = "TAUNTS",
        files = {"HighMage_Timelapse-01c.ogg"}
    },
    -- ElvesMageTaunt = {
    --     loop = false,
    --     gain = 0.6,
    --     ignore = 1.5,
    --     mode = "sequence",
    --     source_group = "TAUNTS",
    --     files = {"Mage_Taunt-01e.ogg", "Mage_Taunt-03d.ogg", "Mage_Taunt[2]-02a.ogg"}
    -- },
    ElvesMageWildMagusDoomTaunt = {
        loop = false,
        gain = 0.6,
        source_group = "TAUNTS",
        files = {"WildMagus_Doom[2]-01b.ogg"}
    },
    ElvesMageWildMagusSilenceTaunt = {
        loop = false,
        gain = 0.6,
        source_group = "TAUNTS",
        files = {"WildMagus_Silence-01c.ogg"}
    },
    ElvesMageWildMagusTaunt = {
        loop = false,
        gain = 0.6,
        source_group = "TAUNTS",
        files = {"WildMagus_Ready-01a.ogg"}
    },
    ElvesMaliciaCastSummon = {
        loop = false,
        gain = 0.3,
        source_group = "SFX",
        files = {"kro_sfx_maliciazealot_summon[wololo_op1].ogg"}
    },
    ElvesMaliciaDeath = {
        loop = false,
        gain = 1,
        source_group = "SFX",
        files = {"kro_sfx_malicia_death.ogg"}
    },
    ElvesMaliciaShieldBreak = {
        loop = false,
        gain = 1,
        source_group = "SFX",
        files = {"kro_sfx_malicia_shieldbreak[op1].ogg"}
    },
    ElvesMaliciaSpellCast = {
        loop = false,
        mode = "random",
        gain = 1,
        source_group = "SFX",
        files = {"kro_sfx_malicia_spellcast_[op2].ogg", "kro_sfx_malicia_spellcast_[op2]_nolaugh.ogg"}
    },
    ElvesMaliciaTransformIn = {
        loop = false,
        gain = 1,
        source_group = "SFX",
        files = {"kro_sfx_malicia_comet-start_v3[sinfuego].ogg"}
    },
    ElvesMaliciaTransformOut = {
        loop = false,
        gain = 1,
        source_group = "SFX",
        files = {"kro_sfx_malicia_comet-end_v3.ogg"}
    },
    ElvesMalikHammer = {
        loop = false,
        gain = 1,
        source_group = "SFX",
        files = {"kro_sfx_malik_hammer[concaida].ogg"}
    },
    ElvesObelix = {
        loop = false,
        gain = 1,
        source_group = "SPECIALS",
        files = {"kro_sfx_obelix_feed[comic].ogg"}
    },
    ElvesPeekaboo = {
        loop = false,
        gain = 1,
        source_group = "SPECIALS",
        files = {"kro_sfx_peekaboo_v2[op2].ogg"}
    },
    ElvesPlantMissile = {
        loop = false,
        gain = 0.3,
        source_group = "SFX",
        files = {"kre_sfx_plant_magicmissile.ogg"}
    },
    ElvesPlantReady = {
        loop = false,
        gain = 0.8,
        source_group = "SFX",
        files = {"kre_sfx_plant_ready_conchime.ogg"}
    },
    ElvesRoadRunner = {
        loop = false,
        gain = 1,
        source_group = "SFX",
        files = {"kro_sfx_roadrunner_meepmeep_modif.ogg"}
    },
    ElvesRockEntwoodClobberingTaunt = {
        loop = false,
        gain = 0.6,
        source_group = "TAUNTS",
        files = {"PapaTree_Clobberin[2]-01e.ogg"}
    },
    ElvesRockEntwoodFieryNutsTaunt = {
        loop = false,
        gain = 0.6,
        source_group = "TAUNTS",
        files = {"PapaTree_Fiery[2]-01d.ogg"}
    },
    ElvesRockEntwoodTaunt = {
        loop = false,
        gain = 0.6,
        source_group = "TAUNTS",
        files = {"PapaTree_Ready[2]-01d.ogg"}
    },
    ElvesRockHengeNatureFriendTaunt = {
        loop = false,
        gain = 0.6,
        source_group = "TAUNTS",
        files = {"DruidHenge_Sylvan[2]-01b.ogg"}
    },
    ElvesRockHengeSylvanCurseTaunt = {
        loop = false,
        gain = 0.6,
        source_group = "TAUNTS",
        files = {"DruidHenge_Sylvan[2]-01b.ogg"}
    },
    ElvesRockHengeTaunt = {
        loop = false,
        gain = 0.6,
        source_group = "TAUNTS",
        files = {"DruidHenge_Ready-01a.ogg"}
    },
    -- ElvesRockTaunt = {
    --     loop = false,
    --     gain = 0.6,
    --     ignore = 1.5,
    --     mode = "sequence",
    --     source_group = "TAUNTS",
    --     files = {"StoneDruid_Taunt-01b.ogg", "StoneDruid_Taunt-02b.ogg", "StoneDruid_Taunt-03a.ogg"}
    -- },
    ElvesScourgerDeath = {
        loop = false,
        gain = 0.3,
        source_group = "SFX",
        files = {"kre_sfx_scourger_death.ogg"}
    },
    ElvesShadowChampionAttack = {
        loop = false,
        gain = 1,
        source_group = "SPECIALS",
        files = {"kro_sfx_shadowchampion_attack[confuego].ogg"}
    },
    ElvesShadowChampionDeath = {
        loop = false,
        gain = 1,
        source_group = "SPECIALS",
        files = {"kro_sfx_shadowchampion_death.ogg"}
    },
    ElvesShadowSpawnDeath = {
        loop = false,
        gain = 0.5,
        source_group = "SPECIALS",
        files = {"kro_sfx_shadowspawn_death[op1].ogg"}
    },
    ElvesShadowSpawnSpawn = {
        loop = false,
        gain = 0.8,
        source_group = "SPECIALS",
        files = {"kro_sfx_shadowspawn_spawn[op2].ogg"}
    },
    ElvesSimonActivate = {
        loop = false,
        gain = 1,
        source_group = "SPECIALS",
        files = {"kro_sfx_simon_activate_v2.ogg"}
    },
    ElvesSimonBlue = {
        loop = false,
        gain = 1,
        source_group = "SPECIALS",
        files = {"kro_sfx_simon_blue_v2.ogg"}
    },
    ElvesSimonGreen = {
        loop = false,
        gain = 1,
        source_group = "SPECIALS",
        files = {"kro_sfx_simon_green_v2.ogg"}
    },
    ElvesSimonRed = {
        loop = false,
        gain = 1,
        source_group = "SPECIALS",
        files = {"kro_sfx_simon_red_v2.ogg"}
    },
    ElvesSimonWrong = {
        loop = false,
        gain = 1,
        source_group = "SPECIALS",
        files = {"kro_sfx_simon_wrong_v2.ogg"}
    },
    ElvesSimonYellow = {
        loop = false,
        gain = 1,
        source_group = "SPECIALS",
        files = {"kro_sfx_simon_yellow_v2.ogg"}
    },
    ElvesSpecialDrowBlademail = {
        loop = false,
        gain = 0.5,
        source_group = "SPECIALS",
        files = {"Drow_03b.ogg"}
    },
    ElvesSpecialDrowDaggers = {
        loop = false,
        gain = 0.5,
        source_group = "SPECIALS",
        files = {"Drow_02c.ogg"}
    },
    ElvesSpecialDrowLifeDrain = {
        loop = false,
        gain = 0.5,
        source_group = "SPECIALS",
        files = {"Drow_01c.ogg"}
    },
    ElvesSpecialExplosionPath = {
        loop = false,
        gain = 0.8,
        source_group = "SPECIALS",
        files = {"kr3_sfx_tree_path_explosion.ogg"}
    },
    ElvesSpecialGeorgeFall = {
        loop = false,
        gain = 0.8,
        source_group = "SPECIALS",
        files = {"kro_sfx_georgefall_v1.ogg"}
    },
    ElvesSpecialSpiderEggs = {
        loop = false,
        gain = 0.8,
        source_group = "SPECIALS",
        files = {"kro_sfx_spidereggs[huevo+aranias].ogg"}
    },
    ElvesTowerBastionShot = {
        loop = false,
        gain = 1,
        source_group = "SFX",
        files = {"kro_sfx_bastion_shot[op1]_modif.ogg"}
    },
    ElvesUnstableCrystalHealing = {
        loop = false,
        gain = 1,
        source_group = "SFX",
        files = {"kro_sfx_unstablecrystal_healing_modif.ogg"}
    },
    ElvesUnstableCrystalReady = {
        loop = false,
        gain = 1,
        source_group = "SFX",
        files = {"kro_sfx_unstablecrystal_ready[op4]_modif.ogg"}
    },
    ElvesWaterfallStrong = {
        loop = false,
        gain = 0.6,
        source_group = "SFX",
        files = {"kre_sfx_waterfall_strong.ogg"}
    },
    ElvesWhiteTreeActivate = {
        loop = false,
        gain = 1,
        source_group = "SFX",
        files = {"kro_sfx_bitteringrancor_whitetree-activate.ogg"}
    },
    ElvesWhiteTreeTap = {
        loop = false,
        gain = 1,
        source_group = "SFX",
        files = {"kro_sfx_bitteringrancor_whitetree-tap.ogg"}
    },
    ElvesWitchDeath = {
        loop = false,
        gain = 1,
        source_group = "SPECIALS",
        files = {"kro_sfx_witchdeath_v1[op2].ogg"}
    },
    ElvesWitchOutside = {
        loop = false,
        gain = 1,
        source_group = "SPECIALS",
        files = {"kro_sfx_witch_outsidecurse[op2].ogg"}
    },
    ElvesWitchTouch = {
        loop = false,
        gain = 1,
        source_group = "SPECIALS",
        files = {"kro_sfx_witch_touch[op1].ogg"}
    },
    EndlessAinylDisable = {
        loop = false,
        gain = 1,
        source_group = "SFX",
        files = {"kro_sfx_ainyl_disable.ogg"}
    },
    EndlessAinylShield = {
        loop = false,
        gain = 1,
        source_group = "SFX",
        files = {"kro_sfx_ainyl_shield.ogg"}
    },
    EndlessAinylTeleport = {
        loop = false,
        gain = 1,
        source_group = "SFX",
        files = {"kro_sfx_ainyl_teleport[op2].ogg"}
    },
    EndlessAmbience = {
        loop = false,
        mode = "random",
        gain = 1,
        source_group = "SFX",
        files = {"kro_sfx_ambience_wardrums[op1].ogg", "kro_sfx_ambience_wardrums[op2].ogg",
                 "kro_sfx_ambience_wardrums[op3].ogg"}
    },
    EndlessBruteDeath = {
        loop = false,
        gain = 1,
        source_group = "SFX",
        files = {"kro_sfx_bannerbearer_death[op1-SD].ogg"}
    },
    EndlessHeeHawCall = {
        loop = false,
        gain = 1,
        source_group = "SFX",
        files = {"kro_sfx_heehaw_call[op2].ogg"}
    },
    EndlessHeeHawNetFalling = {
        loop = false,
        gain = 1,
        source_group = "SFX",
        files = {"kro_sfx_heehaw_netfalling_v2[op3].ogg"}
    },
    EndlessHeeHawNetHit = {
        loop = false,
        gain = 1,
        source_group = "SFX",
        files = {"kro_sfx_heehaw_nethitsfloor.ogg"}
    },
    EndlessTwilightAmbience = {
        loop = false,
        mode = "random",
        gain = 1,
        source_group = "SFX",
        files = {"kro_sfx_twlightinvasionambience-2.ogg", "kro_sfx_twlightinvasionambience-3.ogg"}
    },
    EndlessWarleaderDeath = {
        loop = false,
        gain = 0.5,
        source_group = "DEATH",
        files = {"kro_sfx_creep_death[op1].ogg"}
    },
    EndlessWarleaderDoubleSword = {
        loop = false,
        gain = 0.5,
        source_group = "SFX",
        files = {"kro_sfx_creep_doublesword[op1].ogg"}
    },
    EnemyHealing = {
        loop = false,
        gain = 1,
        source_group = "SFX",
        files = {"Sound_EnemyHealing.ogg"}
    },
    FaerieGroveAmbienceSound = {
        loop = false,
        mode = "random",
        gain = 0.8,
        source_group = "SFX",
        files = {"kro_sfx_ambience_windandowls1.ogg", "kro_sfx_ambience_branchesandfaery1.ogg",
                 "kro_sfx_ambience_branchesandfaery2.ogg"}
    },
    FireballHit = {
        loop = false,
        gain = 0.5,
        source_group = "SPECIALS",
        files = {"Sound_FireballHit.ogg"}
    },
    FireballRelease = {
        loop = false,
        gain = 0.5,
        source_group = "SPECIALS",
        files = {"Sound_FireballUnleash.ogg"}
    },
    GUIAchievementWin = {
        loop = false,
        gain = 1,
        source_group = "GUI",
        files = {"Sound_AchievementWin.ogg"}
    },
    GUIButtonCommon = {
        loop = false,
        gain = 1,
        source_group = "GUI",
        files = {"Sound_GUIButtonCommon.ogg"}
    },
    GUIBuyUpgrade = {
        loop = false,
        gain = 0.6,
        source_group = "GUI",
        files = {"Sound_GUIBuyUpgrade.ogg"}
    },
    GUICoins = {
        loop = false,
        gain = 1,
        source_group = "GUI",
        files = {"Sound_Coins.ogg"}
    },
    GUILooseLife = {
        loop = false,
        gain = 1,
        source_group = "GUI",
        files = {"Sound_LooseLife.ogg"}
    },
    GUIMapNewFlah = {
        loop = false,
        gain = 1,
        source_group = "GUI",
        files = {"Sound_MapNewFlag.ogg"}
    },
    GUINextWaveIncoming = {
        loop = false,
        gain = 1,
        source_group = "GUI",
        files = {"Sound_WaveIncoming.ogg"}
    },
    GUINextWaveReady = {
        loop = false,
        gain = 1,
        source_group = "GUI",
        files = {"Sound_NextWaveReady.ogg"}
    },
    GUINotificationClose = {
        loop = false,
        gain = 1,
        source_group = "GUI",
        files = {"Sound_NotificationClose.ogg"}
    },
    GUINotificationOpen = {
        loop = false,
        gain = 1,
        source_group = "GUI",
        files = {"Sound_NotificationOpen.ogg"}
    },
    GUINotificationPaperOver = {
        loop = false,
        gain = 1,
        source_group = "GUI",
        files = {"Sound_NotificationPaperOver.ogg"}
    },
    GUINotificationSecondLevel = {
        loop = false,
        gain = 0.8,
        source_group = "GUI",
        files = {"Sound_NotificationSecondLevel.ogg"}
    },
    GUIPlaceRallyPoint = {
        loop = false,
        gain = 0.8,
        source_group = "GUI",
        files = {"Sound_RallyPointPlaced.ogg"}
    },
    GUIQuestCompleted = {
        loop = false,
        gain = 1,
        source_group = "GUI",
        files = {"Sound_QuestCompleted.ogg"}
    },
    GUIQuestFailed = {
        loop = false,
        gain = 1,
        source_group = "GUI",
        files = {"Sound_QuestFailed.ogg"}
    },
    GUIQuickMenuOpen = {
        loop = false,
        gain = 1,
        source_group = "GUI",
        files = {"Sound_GUIOpenTowerMenu.ogg"}
    },
    GUIQuickMenuOver = {
        loop = false,
        gain = 1,
        source_group = "GUI",
        files = {"Sound_GUIMouseOverTowerIcon.ogg"}
    },
    GUISpellRefresh = {
        loop = false,
        gain = 1,
        source_group = "GUI",
        files = {"Sound_SpellRefresh.ogg"}
    },
    GUISpellSelect = {
        loop = false,
        gain = 1,
        source_group = "GUI",
        files = {"Sound_SpellSelect.ogg"}
    },
    GUITowerBuilding = {
        loop = false,
        gain = 1,
        source_group = "GUI",
        files = {"Sound_TowerBuilding.ogg"}
    },
    GUITowerOpenDoor = {
        loop = false,
        gain = 1,
        source_group = "GUI",
        files = {"Sound_TowerOpenDoor.ogg"}
    },
    GUITowerSell = {
        loop = false,
        gain = 1,
        source_group = "GUI",
        files = {"Sound_TowerSell.ogg"}
    },
    GUITransitionClose = {
        loop = false,
        gain = 1,
        source_group = "GUI",
        files = {"GUITransitionClose.ogg"}
    },
    GUITransitionOpen = {
        loop = false,
        gain = 1,
        source_group = "GUI",
        files = {"GUITransitionOpen.ogg"}
    },
    GUIWinStars = {
        loop = false,
        gain = 1,
        source_group = "GUI",
        files = {"Sound_WinStars.ogg"}
    },
    GuimapNewRoad = {
        loop = false,
        gain = 1,
        source_group = "GUI",
        files = {"Sound_MapRoad.ogg"}
    },
    HeroLevelUp = {
        loop = false,
        gain = 1,
        source_group = "TAUNTS",
        files = {"Level_up.ogg"}
    },
    HeroReinforcementDeath = {
        loop = false,
        gain = 1,
        source_group = "TAUNTS",
        files = {"Reinforcement-Death_c.ogg"}
    },
    HeroReinforcementHit = {
        loop = false,
        gain = 1,
        source_group = "BULLETS",
        files = {"Motumbo_hit.ogg"}
    },
    HeroReinforcementJump = {
        loop = false,
        gain = 1,
        source_group = "BULLETS",
        files = {"Motumbo_jump_special.ogg"}
    },
    HeroReinforcementSpecial = {
        loop = false,
        gain = 1,
        source_group = "BULLETS",
        files = {"Motumbo_charge_special.ogg"}
    },
    HeroReinforcementTaunt = {
        loop = false,
        gain = 1,
        ignore = 1,
        mode = "sequence",
        source_group = "TAUNTS",
        files = {"Reinforcement-04b.ogg", "Reinforcement-02c.ogg", "Reinforcement-03c.ogg", "Reinforcement-01a.ogg"}
    },
    HeroReinforcementTauntIntro = {
        loop = false,
        gain = 1,
        source_group = "TAUNTS",
        files = {"Level_up.ogg"}
    },
    HeroReinforcementTauntSelect = {
        loop = false,
        gain = 1,
        source_group = "TAUNTS",
        files = {"Reinforcement-01a.ogg"}
    },
    HitSound = {
        loop = false,
        gain = 0.15,
        source_group = "BULLETS",
        files = {"Sound_ArrowHit2.ogg", "Sound_ArrowHit3.ogg"}
    },
    InAppBuyGems = {
        loop = false,
        gain = 1,
        source_group = "SPECIALS",
        files = {"inapp_cash.ogg"}
    },
    InAppBuyInApp = {
        loop = false,
        gain = 1,
        source_group = "SPECIALS",
        files = {"inapp_chin.ogg"}
    },
    InAppEarnGems = {
        loop = false,
        gain = 1,
        source_group = "SPECIALS",
        files = {"inapp_gems.ogg"}
    },
    InAppExtraGold = {
        loop = false,
        gain = 1,
        source_group = "SPECIALS",
        files = {"inapp_gnome.ogg"}
    },
    MetropolisAmbienceSound = {
        loop = false,
        mode = "random",
        gain = 0.3,
        source_group = "SFX",
        files = {"kro_sfx_ambience_winds[op1].ogg", "kro_sfx_ambience_winds[op2].ogg",
                 "kro_sfx_ambience_spiders_v2[op1].ogg"}
    },
    PirateBombShootSound = {
        loop = false,
        gain = 1,
        source_group = "EXPLOSIONS",
        files = {"Sound_EngineerShot.ogg"}
    },
    RocketLaunchSound = {
        loop = false,
        gain = 0.8,
        source_group = "BULLETS",
        files = {"Sound_RocketLaunt.ogg"}
    },
    ShotgunSound = {
        loop = false,
        source_group = "BULLETS",
        files = {"Sound_Shootgun.ogg"}
    },
    ShrapnelSound = {
        loop = false,
        source_group = "BULLETS",
        files = {"Sound_Shrapnel.ogg"}
    },
    SniperSound = {
        loop = false,
        source_group = "BULLETS",
        files = {"Sound_Sniper.ogg"}
    },
    SpiderAttack = {
        loop = false,
        gain = 0.6,
        ignore = 1.5,
        source_group = "BULLETS",
        files = {"Sound_SpiderAttack2.ogg"}
    },
    TowerArcaneExplotion = {
        loop = false,
        gain = 0.5,
        source_group = "SPECIALS",
        files = {"kr3_sfx_archanearcher_arcaneexplotion_v3.ogg"}
    },
    TowerArcanePreloadAndTravel = {
        loop = false,
        gain = 0.3,
        source_group = "SPECIALS",
        files = {"kr3_sfx_highmage_preload_and_travel.ogg"}
    },
    TowerArcaneWaterEnergyBlast = {
        loop = false,
        gain = 0.5,
        source_group = "SPECIALS",
        files = {"kr3_sfx_arcanearcher_sleepingarrow-op1.ogg"}
    },
    TowerBarracksBasic = {
        loop = false,
        gain = 0.3,
        source_group = "SWORDS",
        files = {"kr3_sfx_basicbarracks_fight.ogg"}
    },
    TowerBladesingerBladedance = {
        loop = false,
        gain = 0.3,
        source_group = "SPECIALS",
        files = {"kr3_sfx_bladesinger_bladedance_v2-op2.ogg"}
    },
    TowerBladesingerPerfectParry = {
        loop = false,
        gain = 1,
        source_group = "SPECIALS",
        files = {"kr3_sfx_bladesinger_perfectparry_v2-op2-faded.ogg"}
    },
    TowerDruidHengeBearAttack = {
        loop = false,
        gain = 0.3,
        source_group = "SPECIALS",
        files = {"kr3_sfx_druidhenge_bearattack_v4-op1.ogg"}
    },
    TowerDruidHengeBearDeath = {
        loop = false,
        gain = 0.5,
        source_group = "SPECIALS",
        files = {"kr3_sfx_druidhenge_beardeath_v3_op1-condesplome.ogg"}
    },
    TowerDruidHengeBearSummon = {
        loop = false,
        gain = 0.5,
        source_group = "SPECIALS",
        files = {"kr3_sfx_druidhenge_bearsummon_v3-op2.ogg"}
    },
    TowerDruidHengeRockSummon = {
        loop = false,
        gain = 0.5,
        source_group = "BULLETS",
        files = {"kr3_sfx_druidhenge_bouldersummon.ogg"}
    },
    TowerDruidHengeRockThrow = {
        loop = false,
        gain = 0.5,
        source_group = "BULLETS",
        files = {"kr3_sfx_druidhenge_rockthrow_v2-op2-medio.ogg"}
    },
    TowerDruidHengeSylvanCurseCast = {
        loop = false,
        gain = 0.5,
        source_group = "SPECIALS",
        files = {"kr3_sfx_druidhenge_sylvancursecast_v4-op2.ogg"}
    },
    TowerEntwoodClobber = {
        loop = false,
        gain = 0.8,
        source_group = "SPECIALS",
        files = {"kr3_sfx_tree_clobber_v2.ogg"}
    },
    TowerEntwoodCocoExplosion = {
        loop = false,
        gain = 0.8,
        source_group = "EXPLOSIONS",
        files = {"kr3_sfx_tree_cocoexplosion[explofuerte].ogg"}
    },
    TowerEntwoodCocoThrow = {
        loop = false,
        gain = 0.5,
        source_group = "BULLETS",
        files = {"kr3_sfx_tree_cocothrow.ogg"}
    },
    TowerEntwoodFieryExplote = {
        loop = false,
        gain = 0.8,
        source_group = "SPECIALS",
        files = {"kr3_sfx_tree_fierynutexplotion.ogg"}
    },
    TowerEntwoodFieryThrow = {
        loop = false,
        gain = 0.8,
        source_group = "SPECIALS",
        files = {"kr3_sfx_tree_fierynutthrow.ogg"}
    },
    TowerEntwoodLeaves = {
        loop = false,
        gain = 0.1,
        source_group = "BULLETS",
        files = {"kr3_sfx_tree_leaves.ogg"}
    },
    TowerForestKeeperAncientSpear = {
        loop = false,
        gain = 0.5,
        source_group = "SPECIALS",
        files = {"kr3_sfx_forestkeeper_ancientoakspear_LOW_v1+3db.ogg"}
    },
    TowerForestKeeperCircleOfHealing = {
        loop = false,
        gain = 0.5,
        source_group = "SPECIALS",
        files = {"kr3_sfx_forestkeeper_circleofhealing-CONGAITA_HI.ogg"}
    },
    TowerForestKeeperEerieGarden = {
        loop = false,
        gain = 0.5,
        source_group = "SPECIALS",
        files = {"kr3_sfx_forestkeeper_eeriegarden_SINPOPS.ogg"}
    },
    TowerForestKeeperNormalSpear = {
        loop = false,
        gain = 0.5,
        source_group = "SFX",
        files = {"kr3_sfx_forestkeeper_normalspear_v2-op1.ogg"}
    },
    TowerGoldenBowArrowShot = {
        loop = false,
        gain = 0.3,
        source_group = "BULLETS",
        files = {"kr3_sfx_goldenbow_arrowshot.ogg"}
    },
    TowerGoldenBowFlareHit = {
        loop = false,
        gain = 0.5,
        source_group = "SPECIALS",
        files = {"kr3_sfx_goldenbow_flarehit_v2.5.ogg"}
    },
    TowerGoldenBowFlareShot = {
        loop = false,
        gain = 0.5,
        source_group = "SPECIALS",
        files = {"kr3_sfx_goldenbow_flareshot_v2-convoz.ogg"}
    },
    TowerGoldenBowInstakill = {
        loop = false,
        gain = 0.5,
        source_group = "SPECIALS",
        files = {"kr3_sfx_goldenbow_instakill_v2_conchime.ogg"}
    },
    TowerGoldenBowInstakillArrowShot = {
        loop = false,
        gain = 0.5,
        source_group = "SPECIALS",
        files = {"kr3_sfx_goldenbow_instakillarrowshot_v2.ogg"}
    },
    TowerHighMageBoltCast = {
        loop = false,
        gain = 0.3,
        source_group = "BULLETS",
        files = {"kr3_sfx_highmage_shot.ogg"}
    },
    TowerHighMageSentinelActivate = {
        loop = false,
        gain = 0.5,
        source_group = "SPECIALS",
        files = {"kr3_sfx_elvenhighmage_sentinelactivate.ogg"}
    },
    TowerHighMageSentinelShot = {
        loop = false,
        gain = 0.1,
        source_group = "SPECIALS",
        files = {"kr3_sfx_elvenhighmage_sentinelshot_v2-op1.ogg"}
    },
    TowerHighMageTimeCastEnd = {
        loop = false,
        gain = 0.8,
        source_group = "SPECIALS",
        files = {"kr3_sfx_highmage_timecastend.ogg"}
    },
    TowerHighMageTimecast = {
        loop = false,
        gain = 0.8,
        source_group = "SPECIALS",
        files = {"kr3_sfx_highmage_timecast.ogg"}
    },
    TowerStoneDruidBoulderExplote = {
        loop = false,
        gain = 0.5,
        source_group = "EXPLOSIONS",
        files = {"kr3_sfx_stonedruid_boulderexplosion.ogg"}
    },
    TowerStoneDruidBoulderSummon = {
        loop = false,
        gain = 0.3,
        source_group = "BULLETS",
        files = {"kr3_sfx_stonedruid_bouldersummon.ogg"}
    },
    TowerStoneDruidBoulderThrow = {
        loop = false,
        gain = 0.5,
        source_group = "BULLETS",
        files = {"kr3_sfx_stonedruid_boulderthrow-op2.ogg"}
    },
    TowerWildMagusBoltcast = {
        loop = false,
        gain = 0.3,
        ignore = 0.3,
        source_group = "BULLETS",
        files = {"kr3_sfx_wildmagus_boltcast_v2-op1.ogg"}
    },
    TowerWildMagusDisruptionCast = {
        loop = false,
        gain = 0.5,
        source_group = "SPECIALS",
        files = {"kr3_sfx_wildmagus_disruptioncast_v2.ogg"}
    },
    TowerWildMagusDoomCast = {
        loop = false,
        gain = 0.5,
        source_group = "SPECIALS",
        files = {"kr3_sfx_wildmagus_doomcast_v2.ogg"}
    },
    TowerWildMagusDoomExplote = {
        loop = false,
        gain = 0.5,
        source_group = "SPECIALS",
        files = {"kr3_sfx_wildmagus_doomexplotion_v3-op1.ogg"}
    },
    TowerWildMagusDoomLoop = {
        loop = true,
        gain = 0.5,
        source_group = "SPECIALS",
        files = {"kr3_sfx_wildmagus_doomloop_v2-op1.ogg"}
    },
    TowerWizardBasicBolt = {
        loop = false,
        gain = 0.1,
        source_group = "BULLETS",
        files = {"kr3_sfx_basicwizard_doublebolt-op1.ogg"}
    },
    VenomPlantDischarge = {
        loop = false,
        gain = 1,
        source_group = "SPECIALS",
        files = {"kro_sfx_poisonplant_discharge[conacido]_B.ogg"}
    },
    VenomPlantReady = {
        loop = false,
        gain = 1,
        source_group = "SPECIALS",
        files = {"kro_sfx_poisonplant_ready_v2B.ogg"}
    },
    WolfAttack = {
        loop = false,
        gain = 0.6,
        ignore = 1.5,
        source_group = "BULLETS",
        files = {"Sound_WolfAttack.ogg", "Sound_WolfAttack2.ogg"}
    }

}

local merge_conflict_tables = require("script_utils").merge_conflict_tables

local kr_all = merge_conflict_tables(kr1, kr2)
kr_all = merge_conflict_tables(kr_all, kr3)
return kr_all
