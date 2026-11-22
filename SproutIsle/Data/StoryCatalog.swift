import Foundation

enum StoryCatalog {
    static let heroOptions: [(name: String, emoji: String)] = [
        ("小兔子米米", "🐰"),
        ("小恐龙咔咔", "🦖"),
        ("小猫咪布丁", "🐱"),
        ("小宇航员豆豆", "🧑‍🚀"),
    ]

    static let settingOptions: [(name: String, emoji: String)] = [
        ("魔法森林", "🌲"),
        ("云朵城堡", "☁️"),
        ("彩虹海底", "🐠"),
        ("星星太空站", "🪐"),
    ]

    static let lessonOptions: [String] = [
        "勇敢尝试",
        "学会分享",
        "爱上刷牙和睡觉",
        "保护大自然",
    ]

    static let builtInStories: [StoryBook] = [
        StoryBook(
            id: "story_snail_star",
            title: "小蜗牛找星星",
            subtitle: "慢一点也没关系，坚持就能看到光芒",
            coverEmoji: "🐌",
            themeTag: "勇敢与耐心",
            accentHex: "7B61FF",
            isAIGenerated: false,
            pages: [
                StoryPage(
                    id: "ss_1",
                    title: "闪闪的愿望",
                    narration: "夜晚来临啦，草地上的小蜗牛背着圆圆的小房子，抬头望着夜空。一颗亮晶晶的小星星眨着眼睛，小蜗牛决定爬上山坡，跟它说一声晚安！",
                    sceneEmoji: "🐌",
                    secondaryEmoji: "✨",
                    gradientHexes: ["4B3F72", "7B61FF"],
                    choicePrompt: nil,
                    choices: []
                ),
                StoryPage(
                    id: "ss_2",
                    title: "小河挡住路",
                    narration: "小蜗牛慢慢爬呀爬，来到了一条亮晶晶的小溪边。小蚂蚁在旁边加油：『小蜗牛，你可以的！』",
                    sceneEmoji: "🌊",
                    secondaryEmoji: "🐜",
                    gradientHexes: ["2A9D8F", "4EA8DE"],
                    choicePrompt: nil,
                    choices: []
                ),
                StoryPage(
                    id: "ss_3",
                    title: "帮小蜗牛选一选！",
                    narration: "溪水有点宽，小蜗牛想过河继续爬山坡。小朋友，你觉得小蜗牛应该怎么过小河呢？",
                    sceneEmoji: "🍃",
                    secondaryEmoji: "🐢",
                    gradientHexes: ["34B37E", "74C69D"],
                    choicePrompt: "帮小蜗牛选一个过河办法吧：",
                    choices: [
                        StoryChoice(id: "ss_c1", label: "坐绿树叶小船", emoji: "🍃",
                                    outcomeText: "哇！绿树叶轻轻飘过水面，微风推着小蜗牛稳稳靠岸啦！", outcomeEmoji: "⛵"),
                        StoryChoice(id: "ss_c2", label: "请乌龟爷爷帮忙", emoji: "🐢",
                                    outcomeText: "善良的乌龟爷爷笑眯眯地背起小蜗牛，一步一步安全过了河！", outcomeEmoji: "💛"),
                    ]
                ),
                StoryPage(
                    id: "ss_4",
                    title: "萤火虫点灯",
                    narration: "天越来越黑，一群暖暖的萤火虫飞了过来，排成一条金色的小路，照亮了小蜗牛前进的每一步。",
                    sceneEmoji: "🌟",
                    secondaryEmoji: "🌿",
                    gradientHexes: ["3A506B", "5BC0BE"],
                    choicePrompt: nil,
                    choices: []
                ),
                StoryPage(
                    id: "ss_5",
                    title: "山顶的星空拥抱",
                    narration: "小蜗牛终于爬到了山顶！满天星星像碎钻一样亮闪闪。原来慢慢走也没关系，只要不放弃，就能看到最美的风景！",
                    sceneEmoji: "🌠",
                    secondaryEmoji: "🐌",
                    gradientHexes: ["5E548E", "9F86C0"],
                    choicePrompt: nil,
                    choices: []
                ),
            ],
            moral: "慢慢来也没关系，认真走好每一步，你也能摘到属于自己的小星星！"
        ),

        StoryBook(
            id: "story_dino_brush",
            title: "爱刷牙的小恐龙",
            subtitle: "咕噜咕噜泡泡秀，打败蛀牙小怪兽",
            coverEmoji: "🦖",
            themeTag: "好习惯养成",
            accentHex: "34B37E",
            isAIGenerated: false,
            pages: [
                StoryPage(
                    id: "db_1",
                    title: "甜甜的晚饭后",
                    narration: "小恐龙咔咔最喜欢吃香香的苹果派和草莓饼干！吃完晚饭，它张大嘴巴哈哈笑，却忘了给牙齿洗澡。",
                    sceneEmoji: "🦖",
                    secondaryEmoji: "🍪",
                    gradientHexes: ["34B37E", "80ED99"],
                    choicePrompt: nil,
                    choices: []
                ),
                StoryPage(
                    id: "db_2",
                    title: "小细菌悄悄来了",
                    narration: "几只调皮的小蛀牙虫躲在牙缝里开派对：『哇，这里有甜甜的饼干屑，我们要盖小房子啦！』",
                    sceneEmoji: "🦠",
                    secondaryEmoji: "🦷",
                    gradientHexes: ["F4A261", "E76F51"],
                    choicePrompt: nil,
                    choices: []
                ),
                StoryPage(
                    id: "db_3",
                    title: "超级牙刷出动！",
                    narration: "小芽宝递给咔咔一把魔法牙刷！小朋友，帮咔咔选一种喜欢的牙膏口味吧！",
                    sceneEmoji: "🪥",
                    secondaryEmoji: "🫧",
                    gradientHexes: ["4EA8DE", "90E0EF"],
                    choicePrompt: "选一支魔法牙膏：",
                    choices: [
                        StoryChoice(id: "db_c1", label: "香甜草莓泡泡", emoji: "🍓",
                                    outcomeText: "粉红草莓泡泡刷刷刷！小细菌滑倒滚出嘴巴啦！", outcomeEmoji: "✨"),
                        StoryChoice(id: "db_c2", label: "清凉薄荷泡泡", emoji: "🌿",
                                    outcomeText: "呼呼清凉泡泡画圆圈！牙齿立刻变得雪白发亮！", outcomeEmoji: "💎"),
                    ]
                ),
                StoryPage(
                    id: "db_4",
                    title: "上刷刷下刷刷",
                    narration: "咔咔跟着口诀刷呀刷：前面画圆圈，里面轻轻扫，咬合面来回擦，咕噜咕噜吐泡泡！",
                    sceneEmoji: "🫧",
                    secondaryEmoji: "😁",
                    gradientHexes: ["48CAE4", "00B4D8"],
                    choicePrompt: nil,
                    choices: []
                ),
                StoryPage(
                    id: "db_5",
                    title: "闪亮晚安微笑",
                    narration: "镜子里的小恐龙露出一口亮晶晶的小白牙！恐龙妈妈亲了亲咔咔：『每天早晚刷牙，真是个健康小卫士！』",
                    sceneEmoji: "✨",
                    secondaryEmoji: "🌙",
                    gradientHexes: ["5E60CE", "64DFDF"],
                    choicePrompt: nil,
                    choices: []
                ),
            ],
            moral: "早晚认真刷牙两分钟，小白牙闪闪亮，吃饭更香甜！"
        ),

        StoryBook(
            id: "story_rainbow_umbrella",
            title: "彩虹雨伞的秘密",
            subtitle: "把快乐分给朋友，世界会变出彩虹",
            coverEmoji: "☂️",
            themeTag: "分享与友谊",
            accentHex: "FF6B6B",
            isAIGenerated: false,
            pages: [
                StoryPage(
                    id: "ru_1",
                    title: "滴答滴答下雨啦",
                    narration: "小兔子撑着一把漂亮的彩色大雨伞出门散步。突然，天空下起了滴答滴答的春雨！",
                    sceneEmoji: "🐰",
                    secondaryEmoji: "🌧️",
                    gradientHexes: ["4EA8DE", "72EFDD"],
                    choicePrompt: nil,
                    choices: []
                ),
                StoryPage(
                    id: "ru_2",
                    title: "湿漉漉的小刺猬",
                    narration: "路边树叶下躲着一只淋湿的小刺猬和一只小花猫，它们没有带雨伞，正冷得缩成一团。",
                    sceneEmoji: "🦔",
                    secondaryEmoji: "🐱",
                    gradientHexes: ["6D6875", "B5838D"],
                    choicePrompt: nil,
                    choices: []
                ),
                StoryPage(
                    id: "ru_3",
                    title: "小雨伞变魔法",
                    narration: "小兔子快步跑过去！小朋友，你想让小兔子怎么邀请朋友们呢？",
                    sceneEmoji: "☂️",
                    secondaryEmoji: "💛",
                    gradientHexes: ["FF6B6B", "FFB703"],
                    choicePrompt: "帮小兔子说一句暖心话：",
                    choices: [
                        StoryChoice(id: "ru_c1", label: "快来我的大伞下吧！", emoji: "🤗",
                                    outcomeText: "神奇的事发生了！雨伞越变越大，刚好罩住所有小伙伴！", outcomeEmoji: "🌈"),
                        StoryChoice(id: "ru_c2", label: "我们一起踩水坑唱歌！", emoji: "🎶",
                                    outcomeText: "大家手拉手躲在彩虹伞下唱起雨滴歌，一点都不冷啦！", outcomeEmoji: "🎵"),
                    ]
                ),
                StoryPage(
                    id: "ru_4",
                    title: "雨停太阳笑",
                    narration: "没过多久，太阳公公探出暖洋洋的小脑袋，天空挂起了一道和雨伞一样漂亮的七色彩虹！",
                    sceneEmoji: "🌈",
                    secondaryEmoji: "☀️",
                    gradientHexes: ["FF9F1C", "FFBF69"],
                    choicePrompt: nil,
                    choices: []
                ),
                StoryPage(
                    id: "ru_5",
                    title: "最好的朋友",
                    narration: "原来彩虹雨伞的秘密就是：只要愿意和朋友分享，小雨伞就会装满大大的温暖和欢笑！",
                    sceneEmoji: "🤝",
                    secondaryEmoji: "🌸",
                    gradientHexes: ["FF758F", "FFB3C1"],
                    choicePrompt: nil,
                    choices: []
                ),
            ],
            moral: "分享不会让快乐变少，反而会让温暖加倍哦！"
        ),

        StoryBook(
            id: "story_moon_rocket",
            title: "小火箭去月球",
            subtitle: "带着好奇心，飞向奇妙的宇宙乐园",
            coverEmoji: "🚀",
            themeTag: "太空探索",
            accentHex: "4EA8DE",
            isAIGenerated: false,
            pages: [
                StoryPage(
                    id: "mr_1",
                    title: "纸箱大火箭",
                    narration: "小熊豆豆用纸箱、贴纸和手电筒，造了一艘亮闪闪的小火箭。倒数三、二、一，咻——冲向星空！",
                    sceneEmoji: "🚀",
                    secondaryEmoji: "🐻",
                    gradientHexes: ["1D3557", "457B9D"],
                    choicePrompt: nil,
                    choices: []
                ),
                StoryPage(
                    id: "mr_2",
                    title: "会唱歌的土星环",
                    narration: "飞过柔软的云海，小火箭遇见了戴着彩色呼啦圈的土星，冰晶叮叮当当像风铃一样好听。",
                    sceneEmoji: "🪐",
                    secondaryEmoji: "🎵",
                    gradientHexes: ["3D405B", "81B29A"],
                    choicePrompt: nil,
                    choices: []
                ),
                StoryPage(
                    id: "mr_3",
                    title: "降落月球表面！",
                    narration: "月球上的重力轻轻的，走一步就能跳得老高！小朋友，你想在月球上做什么呀？",
                    sceneEmoji: "🌕",
                    secondaryEmoji: "👨‍🚀",
                    gradientHexes: ["2B2D42", "8D99AE"],
                    choicePrompt: "选一个太空小任务：",
                    choices: [
                        StoryChoice(id: "mr_c1", label: "在月球上跳超级高", emoji: "🦘",
                                    outcomeText: "嗖的一声！小熊像棉花糖一样轻轻飘了起来，咯咯笑个不停！", outcomeEmoji: "⭐"),
                        StoryChoice(id: "mr_c2", label: "种下一颗梦想小芽", emoji: "🌱",
                                    outcomeText: "太空玻璃罩里的小芽发出了绿绿的荧光，向地球挥挥手！", outcomeEmoji: "🌍"),
                    ]
                ),
                StoryPage(
                    id: "mr_4",
                    title: "望见蓝色地球",
                    narration: "回头看看远方的地球，像一颗蓝白相间的玻璃弹珠。那里有家、有爸爸妈妈，还有香喷喷的晚餐。",
                    sceneEmoji: "🌍",
                    secondaryEmoji: "💙",
                    gradientHexes: ["0077B6", "00B4D8"],
                    choicePrompt: nil,
                    choices: []
                ),
                StoryPage(
                    id: "mr_5",
                    title: "回到温暖小床",
                    narration: "小火箭平稳降落在柔软的枕头上。保持满满的好奇心，明天还有更多神奇世界等着你去探索呢！",
                    sceneEmoji: "🛏️",
                    secondaryEmoji: "🌙",
                    gradientHexes: ["5E548E", "231942"],
                    choicePrompt: nil,
                    choices: []
                ),
            ],
            moral: "好奇心是最棒的小火箭，能带我们飞向无穷无尽的知识宇宙！"
        ),
    ]

    static let whyQAs: [WhyQAItem] = [
        // 天空与宇宙
        WhyQAItem(id: "why_sky", question: "为什么天空是蓝色的？", shortAnswer: "太阳光里的蓝色光最爱在空气里跳舞！",
                  kidExplanation: "太阳光其实藏着红橙黄绿青蓝紫七种颜色。当阳光穿过大气层时，小小的空气宝宝最喜欢把蓝色光四面八方弹来弹去，所以我们抬头就看见了漂亮的蓝天！",
                  funActivity: "傍晚和爸爸妈妈一起看看夕阳，为什么太阳快落山时天空会变成橘红色呢？", emoji: "🌤️", category: .sky),
        WhyQAItem(id: "why_moon", question: "月亮为什么有时圆有时弯？", shortAnswer: "因为月亮绕着地球转，我们看到被太阳照亮的部分不一样。",
                  kidExplanation: "月亮自己不会发光，它像一面大镜子反射太阳光。月亮每天绕着地球慢慢转圈圈，有时候我们能看见它整张亮脸（满月），有时候只能看见弯弯的一小边（月牙）。",
                  funActivity: "关灯用手电筒照一个小球，转一转小球，看看亮的地方怎么变化！", emoji: "🌙", category: .sky),
        WhyQAItem(id: "why_rainbow", question: "彩虹是怎么变出来的？", shortAnswer: "阳光穿过雨后小水珠，分成七种颜色啦！",
                  kidExplanation: "雨刚停时，空气里还飘着好多亮晶晶的小水滴。太阳光钻进小水滴里转个弯，就像打开彩色颜料盒一样，散开成红、橙、黄、绿、青、蓝、紫七道拱桥！",
                  funActivity: "阳光好的时候，背对太阳用喷壶喷水雾，就能在家造出迷你彩虹哦！", emoji: "🌈", category: .sky),
        WhyQAItem(id: "why_stars", question: "星星白天去哪儿了？", shortAnswer: "它们一直在天上，只是太阳公公太亮啦！",
                  kidExplanation: "星星其实白天也没有下班回家哦！只是白天太阳光实在太耀眼了，把蓝天照得亮堂堂的，小星星微弱的亮光就被遮住看不见啦。等晚上太阳落山，它们就又眨眼睛了。",
                  funActivity: "白天打开手电筒照亮墙壁，对比关灯后的样子，感受亮度差别吧！", emoji: "⭐", category: .sky),

        // 动物世界
        WhyQAItem(id: "why_cat", question: "为什么小猫总爱舔自己的毛？", shortAnswer: "小猫正在用带小倒刺的舌头给自己洗澡梳头呢！",
                  kidExplanation: "小猫的舌头摸起来像一把小小的软梳子，上面有好多微小的倒刺。舔毛既能把灰尘梳干净、理顺毛发，还能帮小猫在夏天凉快一点、放松心情！",
                  funActivity: "学小猫轻轻用小手整理自己的衣服和头发，做爱干净的小宝宝！", emoji: "🐱", category: .animals),
        WhyQAItem(id: "why_giraffe", question: "长颈鹿的脖子为什么那么长？", shortAnswer: "为了吃到大树最高处又嫩又甜的树叶！",
                  kidExplanation: "大草原上有很多吃草的动物，矮处的叶子很快就被吃完啦。长颈鹿长出长长的脖子，就可以轻松够到树顶新鲜的嫩叶，还能站得高看得远，提前发现危险呢！",
                  funActivity: "垫起脚尖伸长手臂，学长颈鹿够一够高高的『树叶』吧！", emoji: "🦒", category: .animals),
        WhyQAItem(id: "why_fish", question: "小鱼在水里会睡觉吗？", shortAnswer: "会的！不过小鱼没有眼皮，是睁着眼睛睡觉的。",
                  kidExplanation: "小鱼玩累了也需要睡觉休息哦！但是鱼儿没有像我们一样可以合上的眼皮，所以它们睡觉时眼睛睁得大大的，身子静静浮在水草旁或石缝里不动。",
                  funActivity: "下次去水族馆或公园看金鱼，仔细观察它有没有眼皮眨眼哦！", emoji: "🐠", category: .animals),
        WhyQAItem(id: "why_bee", question: "小蜜蜂为什么要忙着采花蜜？", shortAnswer: "花蜜是小蜜蜂的美味粮食，还能帮花朵结出果子！",
                  kidExplanation: "小蜜蜂把甜甜的花蜜吸进肚子里带回蜂巢，酿成香香的蜂蜜当全家人的食物。同时，它毛茸茸的小脚沾上花粉带到下一朵花，帮果树结出大苹果和甜桃子！",
                  funActivity: "看见小蜜蜂时远远欣赏不打扰它，谢谢勤劳的小自然帮手！", emoji: "🐝", category: .animals),

        // 奇妙身体
        WhyQAItem(id: "why_yawn", question: "为什么困了会打哈欠？", shortAnswer: "大脑想多吸一大口新鲜空气提提神！",
                  kidExplanation: "当我们累了或者屋里空气有点闷，大脑会偷偷发信号：『快张大嘴巴深吸一口氧气吧！』于是我们就打了一个大哈欠。而且哈欠还会像微笑一样传染呢！",
                  funActivity: "伸一个大大懒腰，做三次慢悠悠的深呼吸，给大脑充充电！", emoji: "🥱", category: .body),
        WhyQAItem(id: "why_teeth", question: "为什么小朋友的乳牙会掉下来？", shortAnswer: "因为底下更结实的大牙齿要搬进来住啦！",
                  kidExplanation: "宝宝长大的时候，嘴巴也跟着变大了。小小的乳牙下面藏着更强壮的新牙齿（恒牙），新牙齿往上顶呀顶，乳牙就会晃动光荣退休，这是长大的棒棒勋章！",
                  funActivity: "对着镜子数一数自己现在有多少颗亮晶晶的小白牙！", emoji: "🦷", category: .body),
        WhyQAItem(id: "why_tummy", question: "吃下去的饭跑到哪儿去了？", shortAnswer: "坐着滑梯进到小肚子里，变成力气让你长高高！",
                  kidExplanation: "牙齿把食物嚼碎后，它们顺着食道小滑梯滑进胃里，胃像一个温柔的搅拌机把食物变成营养汤，再被小肠吸收，送给全身长个子、跑得快、变聪明！",
                  funActivity: "吃一口水果，细细嚼 10 下，感受牙齿小磨坊的工作吧！", emoji: "🍽️", category: .body),
        WhyQAItem(id: "why_eyes", question: "为什么不能用脏手揉眼睛？", shortAnswer: "小手上有看不见的细菌，会让眼睛红红痒痒的。",
                  kidExplanation: "我们每天摸玩具、摸地板，小手上藏着肉眼看不见的小灰尘和小细菌。眼睛像娇嫩的小水晶球，用脏手揉会把细菌带进去，还会刮伤透明的眼角膜哦！",
                  funActivity: "眼睛累的时候，一起看向窗外绿绿的远方，慢慢眨眼睛 5 次！", emoji: "👀", category: .body),

        // 生活小科学
        WhyQAItem(id: "why_bubble", question: "肥皂水为什么能吹出彩色泡泡？", shortAnswer: "肥皂让水膜变得有弹性，阳光照上去就像小彩虹！",
                  kidExplanation: "清水太爱抱团啦，吹不出大泡泡。加入肥皂后，水表面变得软软有弹性，就像拉起一层透明小气球。阳光照在薄薄的泡泡膜上反射出五颜六色，特别梦幻！",
                  funActivity: "仔细看看大泡泡和小泡泡，哪个总是圆圆的呢？", emoji: "🫧", category: .life),
        WhyQAItem(id: "why_ice", question: "冰块为什么会慢慢变成水？", shortAnswer: "小水滴变暖和后，解开冰雪冻僵术又自由流动啦！",
                  kidExplanation: "水是个会变身的小魔术师！在很冷的冰箱里，水分子手拉手冻成硬硬的冰块；拿到暖暖的房间里吸收热量，它们就融化重新变回哗啦啦的液态水啦。",
                  funActivity: "把一小块冰放进盘子里，和爸爸妈妈计时看看几分钟会变出小水洼！", emoji: "🧊", category: .life),
        WhyQAItem(id: "why_apple", question: "为什么苹果切开一会儿会变黄？", shortAnswer: "苹果果肉遇见空气里的氧气，穿上了浅棕色外套！",
                  kidExplanation: "苹果里面藏着一些活泼的小营养，原本被果皮保护得好好的。切开后它们和空气里的氧气握手发生氧化反应，就变成浅棕色啦，其实还是甜甜可以吃的哦！",
                  funActivity: "在切开的苹果片上滴一点点柠檬汁或盐水，看看会不会变慢变黄！", emoji: "🍎", category: .life),
        WhyQAItem(id: "why_magnet", question: "磁铁为什么能吸住回形针？", shortAnswer: "磁铁周围藏着看不见的磁力小手，专门爱拉铁朋友！",
                  kidExplanation: "磁铁有一种神奇的看不见的力量叫磁场，它特别喜欢和铁、镍这些金属小伙伴牵手！不过木头、塑料和纸张不是铁做的，所以磁铁就不会吸住它们。",
                  funActivity: "拿一块冰箱贴，猜猜它能吸住勺子、积木还是橡皮擦？", emoji: "🧲", category: .life),
    ]

    static func qas(for category: WhyCategory) -> [WhyQAItem] {
        whyQAs.filter { $0.category == category }
    }

    static func composeOfflineStory(request: StoryCreationRequest) -> StoryBook {
        let hero = request.hero
        let setting = request.setting
        let lesson = request.lesson
        let child = request.childName.isEmpty ? "小朋友" : request.childName

        return StoryBook(
            id: "custom_\(UUID().uuidString.prefix(8))",
            title: "\(hero)的\(setting)奇遇",
            subtitle: "献给 \(child) 的专属童话 · \(lesson)",
            coverEmoji: request.heroEmoji,
            themeTag: lesson,
            accentHex: "9B72CF",
            isAIGenerated: false,
            pages: [
                StoryPage(
                    id: "cs_1",
                    title: "出发去\(setting)",
                    narration: "阳光暖洋洋的一天，\(hero)背上小书包，和\(child)一起来到神奇的\(setting)！空气里飘着甜甜的果香，一场奇妙冒险开始啦。",
                    sceneEmoji: request.heroEmoji,
                    secondaryEmoji: request.settingEmoji,
                    gradientHexes: ["4EA8DE", "72EFDD"],
                    choicePrompt: nil,
                    choices: []
                ),
                StoryPage(
                    id: "cs_2",
                    title: "遇见小小挑战",
                    narration: "走着走着，前面出现了一座闪亮的小桥，一只迷路的小蝴蝶正在发愁。\(hero)想起了今天最重要的小魔法——「\(lesson)」！",
                    sceneEmoji: "🦋",
                    secondaryEmoji: "✨",
                    gradientHexes: ["FFB703", "FB8500"],
                    choicePrompt: nil,
                    choices: []
                ),
                StoryPage(
                    id: "cs_3",
                    title: "\(child)来帮忙选一选！",
                    narration: "接下来\(hero)该怎么做，才能把温暖和快乐带给整个\(setting)呢？",
                    sceneEmoji: request.heroEmoji,
                    secondaryEmoji: "💛",
                    gradientHexes: ["9B72CF", "C77DFF"],
                    choicePrompt: "选一个魔法行动：",
                    choices: [
                        StoryChoice(id: "cs_c1", label: "微笑着大声说：我来帮你！", emoji: "🌟",
                                    outcomeText: "太棒啦！温暖的鼓励让小蝴蝶开心地拍起翅膀，天空飘下闪闪星光！", outcomeEmoji: "🎉"),
                        StoryChoice(id: "cs_c2", label: "分享包里的小饼干一起想办法", emoji: "🍪",
                                    outcomeText: "香香的饼干带来了满满能量，大家手拉手一下子就解决了难题！", outcomeEmoji: "🤝"),
                    ]
                ),
                StoryPage(
                    id: "cs_4",
                    title: "闪闪发光的勋章",
                    narration: "\(setting)里响起了叮叮当当的掌声！\(hero)开心地抱了抱\(child)：『谢谢你陪我学会了\(lesson)，今天我们都是最棒的小探险家！』",
                    sceneEmoji: "🏆",
                    secondaryEmoji: request.heroEmoji,
                    gradientHexes: ["34B37E", "80ED99"],
                    choicePrompt: nil,
                    choices: []
                ),
            ],
            moral: "亲爱的\(child)，记住今天的秘密魔法：\(lesson)会让你每天都闪闪发光！"
        )
    }

    static func searchOfflineWhy(query: String) -> WhyQAItem {
        let cleaned = query.trimmingCharacters(in: .whitespacesAndNewlines)
        if let exact = whyQAs.first(where: {
            $0.question.localizedCaseInsensitiveContains(cleaned) ||
            cleaned.localizedCaseInsensitiveContains($0.question.replacingOccurrences(of: "为什么", with: "").replacingOccurrences(of: "？", with: ""))
        }) {
            return exact
        }

        let keywords: [(String, String)] = [
            ("天", "why_sky"), ("蓝", "why_sky"), ("月", "why_moon"), ("彩虹", "why_rainbow"), ("星", "why_stars"),
            ("猫", "why_cat"), ("长颈鹿", "why_giraffe"), ("鱼", "why_fish"), ("蜜蜂", "why_bee"),
            ("哈欠", "why_yawn"), ("牙", "why_teeth"), ("肚子", "why_tummy"), ("饭", "why_tummy"), ("眼", "why_eyes"),
            ("泡泡", "why_bubble"), ("冰", "why_ice"), ("苹果", "why_apple"), ("磁铁", "why_magnet"),
        ]
        for (key, id) in keywords where cleaned.contains(key) {
            if let match = whyQAs.first(where: { $0.id == id }) {
                return match
            }
        }

        return WhyQAItem(
            id: "why_curious_\(UUID().uuidString.prefix(6))",
            question: cleaned.isEmpty ? "世界为什么这么奇妙？" : cleaned,
            shortAnswer: "哇！这是一个超级棒的好奇问题！",
            kidExplanation: "你就像小小科学家一样爱动脑筋！关于「\(cleaned.isEmpty ? "这个问题" : cleaned)」，大自然里藏着好多有趣的秘密。可以让爸爸妈妈在「家长小屋」里连上 AI 老师，小芽宝就能为你实时解答任何天马行空的为什么哦！",
            funActivity: "和爸爸妈妈一起画一幅画，猜猜这个问题的神奇答案吧！",
            emoji: "🔎",
            category: .life
        )
    }
}
