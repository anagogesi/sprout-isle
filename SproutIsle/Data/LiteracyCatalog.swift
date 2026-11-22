import Foundation

enum LiteracyCatalog {
    static let hanziCards: [HanziCard] = [
        // 大自然
        HanziCard(id: "hz_ri", character: "日", pinyin: "rì", meaning: "太阳", emoji: "☀️", category: .nature,
                  mnemonic: "圆圆的太阳中间有一道暖暖的光，就像『日』！", words: ["太阳", "日出", "生日"],
                  sentence: "早晨太阳公公出来啦，今天是晴朗的一日！", strokeHint: "竖 → 横折 → 横 → 横"),
        HanziCard(id: "hz_yue", character: "月", pinyin: "yuè", meaning: "月亮", emoji: "🌙", category: .nature,
                  mnemonic: "弯弯的月亮挂在夜空，里面有两朵小云彩。", words: ["月亮", "月饼", "一月"],
                  sentence: "晚上弯弯的月亮像一艘金色小船。", strokeHint: "撇 → 横折钩 → 横 → 横"),
        HanziCard(id: "hz_shan", character: "山", pinyin: "shān", meaning: "高山", emoji: "⛰️", category: .nature,
                  mnemonic: "三座高高矮矮的山峰连在一起，就是『山』！", words: ["大山", "山羊", "山坡"],
                  sentence: "远处有青青的大山，山顶有白白的云。", strokeHint: "竖 → 竖折 → 竖"),
        HanziCard(id: "hz_shui", character: "水", pinyin: "shuǐ", meaning: "清水", emoji: "💧", category: .nature,
                  mnemonic: "中间一条小河水，两边溅起快乐的小水花！", words: ["喝水", "水果", "河水"],
                  sentence: "小朋友多喝温开水，身体棒棒哒！", strokeHint: "竖钩 → 横撇 → 撇 → 捺"),
        HanziCard(id: "hz_huo", character: "火", pinyin: "huǒ", meaning: "火焰", emoji: "🔥", category: .nature,
                  mnemonic: "跳动的小火苗，两边蹦出两点小火星。", words: ["火车", "火焰", "烟火"],
                  sentence: "小火车呜呜呜开过来了！", strokeHint: "点 → 撇 → 撇 → 捺"),
        HanziCard(id: "hz_mu", character: "木", pinyin: "mù", meaning: "树木", emoji: "🌳", category: .nature,
                  mnemonic: "一棵笔直的小树，张开树枝和树根。", words: ["木头", "积木", "树木"],
                  sentence: "我最喜欢搭高高的彩色积木！", strokeHint: "横 → 竖 → 撇 → 捺"),
        HanziCard(id: "hz_feng", character: "风", pinyin: "fēng", meaning: "微风", emoji: "🌬️", category: .nature,
                  mnemonic: "像一把飘扬的小风帆，被风吹得鼓鼓的。", words: ["大风", "风筝", "微风"],
                  sentence: "春风轻轻吹，我们去草地上放风筝！", strokeHint: "撇 → 横斜钩 → 撇 → 点"),
        HanziCard(id: "hz_hua", character: "花", pinyin: "huā", meaning: "花朵", emoji: "🌸", category: .nature,
                  mnemonic: "头上顶着小草字头，春天开出香香的花！", words: ["花朵", "花园", "开花"],
                  sentence: "小芽岛的花园里开满了五颜六色的花。", strokeHint: "草字头 → 化"),

        // 小动物
        HanziCard(id: "hz_mao", character: "猫", pinyin: "māo", meaning: "小猫", emoji: "🐱", category: .animals,
                  mnemonic: "左边反犬旁像小动物，右边『苗』读起来喵喵叫！", words: ["小猫", "熊猫", "猫咪"],
                  sentence: "软软的小猫正眯着眼睛晒太阳，喵呜！", strokeHint: "反犬旁 → 苗"),
        HanziCard(id: "hz_gou", character: "狗", pinyin: "gǒu", meaning: "小狗", emoji: "🐶", category: .animals,
                  mnemonic: "反犬旁加一个『句』，爱摇尾巴的汪汪小狗。", words: ["小狗", "热狗", "海狗"],
                  sentence: "小狗摇着毛茸茸的尾巴欢迎你回家！", strokeHint: "反犬旁 → 句"),
        HanziCard(id: "hz_yu", character: "鱼", pinyin: "yú", meaning: "小鱼", emoji: "🐠", category: .animals,
                  mnemonic: "尖尖的鱼头，方方的鱼身，下面一横是鱼尾巴！", words: ["小鱼", "金鱼", "鲸鱼"],
                  sentence: "彩色的小鱼在水里吐着圆圆的泡泡。", strokeHint: "撇 → 横撇 → 田 → 横"),
        HanziCard(id: "hz_niao", character: "鸟", pinyin: "niǎo", meaning: "小鸟", emoji: "🐦", category: .animals,
                  mnemonic: "里面一点像小鸟亮晶晶的眼睛，长钩像羽毛尾巴。", words: ["小鸟", "飞鸟", "鸵鸟"],
                  sentence: "清晨树梢上的小鸟叽叽喳喳唱歌。", strokeHint: "撇 → 横折钩 → 点 → 竖折折钩 → 横"),
        HanziCard(id: "hz_ma", character: "马", pinyin: "mǎ", meaning: "骏马", emoji: "🐴", category: .animals,
                  mnemonic: "昂起头奔跑的小马，哒哒哒跑得真快！", words: ["小马", "木马", "马路"],
                  sentence: "游乐园里的旋转木马转呀转，真好玩！", strokeHint: "横折 → 竖折折钩 → 横"),
        HanziCard(id: "hz_niu", character: "牛", pinyin: "niú", meaning: "奶牛", emoji: "🐮", category: .animals,
                  mnemonic: "左边一撇像小牛翘起的小犄角，哞哞哞！", words: ["牛奶", "小牛", "蜗牛"],
                  sentence: "每天早上一杯香香的牛奶，长高高！", strokeHint: "撇 → 横 → 横 → 竖"),
        HanziCard(id: "hz_yang", character: "羊", pinyin: "yáng", meaning: "绵羊", emoji: "🐑", category: .animals,
                  mnemonic: "头上两只弯弯的羊角，毛茸茸的咩咩小羊。", words: ["小羊", "山羊", "绵羊"],
                  sentence: "草地上的绵羊像一团白白软软的棉花糖。", strokeHint: "点 → 撇 → 横 → 横 → 横 → 竖"),
        HanziCard(id: "hz_chong", character: "虫", pinyin: "chóng", meaning: "昆虫", emoji: "🐛", category: .animals,
                  mnemonic: "圆圆的小脑袋加扭呀扭的小身体，是可爱小虫。", words: ["毛毛虫", "瓢虫", "萤火虫"],
                  sentence: "绿绿的小毛毛虫长大后会变成蝴蝶哦！", strokeHint: "口 → 竖 → 提 → 点"),

        // 身体与家人
        HanziCard(id: "hz_ba", character: "爸", pinyin: "bà", meaning: "爸爸", emoji: "👨", category: .family,
                  mnemonic: "上面是父字头，下面是巴，强壮温柔的爸爸！", words: ["爸爸", "老爸", "好爸爸"],
                  sentence: "爸爸把我举高高，像坐小飞机一样开心！", strokeHint: "父 → 巴"),
        HanziCard(id: "hz_ma2", character: "妈", pinyin: "mā", meaning: "妈妈", emoji: "👩", category: .family,
                  mnemonic: "女字旁加一个马，最爱我的温柔妈妈！", words: ["妈妈", "好妈妈", "爸妈"],
                  sentence: "妈妈的拥抱软软的，像温暖的小太阳。", strokeHint: "女 → 马"),
        HanziCard(id: "hz_shou", character: "手", pinyin: "shǒu", meaning: "小手", emoji: "✋", category: .family,
                  mnemonic: "张开手指头，弯弯的竖钩就像能干的小手掌！", words: ["小手", "洗手", "拉手"],
                  sentence: "饭前便后洗洗手，小手干净没细菌！", strokeHint: "撇 → 横 → 横 → 竖钩"),
        HanziCard(id: "hz_zu", character: "足", pinyin: "zú", meaning: "脚丫", emoji: "🦶", category: .family,
                  mnemonic: "上面像膝盖，下面像迈开步子跑步的小脚丫！", words: ["足球", "手足", "满足"],
                  sentence: "我们在绿绿的草地上一起踢足球吧！", strokeHint: "口 → 竖 → 横 → 撇 → 捺"),
        HanziCard(id: "hz_kou", character: "口", pinyin: "kǒu", meaning: "嘴巴", emoji: "👄", category: .family,
                  mnemonic: "张大嘴巴说『啊——』，方方圆圆就是『口』！", words: ["张口", "口渴", "入口"],
                  sentence: "大口吃青菜，小嘴巴真能干！", strokeHint: "竖 → 横折 → 横"),
        HanziCard(id: "hz_mu2", character: "目", pinyin: "mù", meaning: "眼睛", emoji: "👀", category: .family,
                  mnemonic: "把眼睛竖起来看，里面两道横就像亮亮的眼珠！", words: ["目光", "耳目", "目录"],
                  sentence: "看书要保持距离，保护亮晶晶的小眼睛。", strokeHint: "竖 → 横折 → 横 → 横 → 横"),
        HanziCard(id: "hz_er", character: "耳", pinyin: "ěr", meaning: "耳朵", emoji: "👂", category: .family,
                  mnemonic: "像一只立起来认真听故事的小耳朵。", words: ["耳朵", "木耳", "耳机"],
                  sentence: "竖起小耳朵，仔细听小鸟在说什么呀？", strokeHint: "横 → 竖 → 竖 → 横 → 横 → 横"),
        HanziCard(id: "hz_xin", character: "心", pinyin: "xīn", meaning: "爱心", emoji: "❤️", category: .family,
                  mnemonic: "一个弯弯的卧钩托着三颗小星星，暖暖的爱心！", words: ["开心", "爱心", "关心"],
                  sentence: "和好朋友分享玩具，心里真开心！", strokeHint: "点 → 卧钩 → 点 → 点"),

        // 生活与水果
        HanziCard(id: "hz_guo", character: "果", pinyin: "guǒ", meaning: "水果", emoji: "🍎", category: .daily,
                  mnemonic: "一棵木头树上面结着圆圆的大果子！", words: ["苹果", "水果", "糖果"],
                  sentence: "红红的大苹果咬一口，咔嚓咔嚓真甜！", strokeHint: "日 → 木"),
        HanziCard(id: "hz_gua", character: "瓜", pinyin: "guā", meaning: "西瓜", emoji: "🍉", category: .daily,
                  mnemonic: "藤蔓弯弯挂在两边，中间垂着一个甜大瓜！", words: ["西瓜", "南瓜", "黄瓜"],
                  sentence: "夏天吃冰凉甜脆的大西瓜最解暑啦！", strokeHint: "撇 → 撇 → 竖提 → 点 → 捺"),
        HanziCard(id: "hz_mi", character: "米", pinyin: "mǐ", meaning: "大米", emoji: "🍚", category: .daily,
                  mnemonic: "中间十字架，四周撒着香香的小米粒！", words: ["米饭", "玉米", "小米"],
                  sentence: "白白香香的大米饭，粒粒都要吃光光！", strokeHint: "点 → 撇 → 横 → 竖 → 撇 → 捺"),
        HanziCard(id: "hz_shu", character: "书", pinyin: "shū", meaning: "绘本", emoji: "📚", category: .daily,
                  mnemonic: "叠得整整齐齐的绘本故事书，上面有一支小笔！", words: ["看书", "书包", "图画书"],
                  sentence: "每天睡前读一本绘本，梦里都是童话故事。", strokeHint: "横折 → 横折钩 → 竖 → 点"),
        HanziCard(id: "hz_men", character: "门", pinyin: "mén", meaning: "大门", emoji: "🚪", category: .daily,
                  mnemonic: "两扇宽宽的门框，推开就是温暖的家！", words: ["大门", "开门", "出门"],
                  sentence: "进门换拖鞋，出门和家人挥手说再见！", strokeHint: "点 → 竖 → 横折钩"),
        HanziCard(id: "hz_che", character: "车", pinyin: "chē", meaning: "小车", emoji: "🚗", category: .daily,
                  mnemonic: "方方的小车身，一根车轴穿中间，滴滴滴出发！", words: ["汽车", "火车", "自行车"],
                  sentence: "坐小汽车要系好安全带，遵守交通规则！", strokeHint: "横 → 撇折 → 横 → 竖"),
        HanziCard(id: "hz_xing", character: "星", pinyin: "xīng", meaning: "星星", emoji: "⭐", category: .daily,
                  mnemonic: "上面一个太阳『日』，下面一个『生』，夜空里亮闪闪！", words: ["星星", "星空", "星期"],
                  sentence: "每次完成学习，小芽岛就会奖励一颗亮星星！", strokeHint: "日 → 生"),
        HanziCard(id: "hz_tian", character: "田", pinyin: "tián", meaning: "农田", emoji: "🌾", category: .daily,
                  mnemonic: "方方正正的土地分成四块，种满金黄的稻谷！", words: ["农田", "田野", "水田"],
                  sentence: "小青蛙在绿油油的田野里呱呱唱着歌。", strokeHint: "竖 → 横折 → 横 → 竖 → 横"),
    ]

    static let vowels: [PinyinItem] = [
        PinyinItem(id: "py_a", symbol: "a", tones: ["ā", "á", "ǎ", "à"], sampleChar: "阿", sampleWord: "阿姨", emoji: "👩", isInitial: false),
        PinyinItem(id: "py_o", symbol: "o", tones: ["ō", "ó", "ǒ", "ò"], sampleChar: "喔", sampleWord: "公鸡喔喔叫", emoji: "🐓", isInitial: false),
        PinyinItem(id: "py_e", symbol: "e", tones: ["ē", "é", "ě", "è"], sampleChar: "鹅", sampleWord: "大白鹅", emoji: "🦢", isInitial: false),
        PinyinItem(id: "py_i", symbol: "i", tones: ["ī", "í", "ǐ", "ì"], sampleChar: "衣", sampleWord: "新衣服", emoji: "👕", isInitial: false),
        PinyinItem(id: "py_u", symbol: "u", tones: ["ū", "ú", "ǔ", "ù"], sampleChar: "乌", sampleWord: "小乌龟", emoji: "🐢", isInitial: false),
        PinyinItem(id: "py_v", symbol: "ü", tones: ["ǖ", "ǘ", "ǚ", "ǜ"], sampleChar: "鱼", sampleWord: "小金鱼", emoji: "🐠", isInitial: false),
    ]

    static let initials: [PinyinItem] = [
        PinyinItem(id: "py_b", symbol: "b", tones: ["b"], sampleChar: "爸", sampleWord: "爸爸", emoji: "👨", isInitial: true),
        PinyinItem(id: "py_p", symbol: "p", tones: ["p"], sampleChar: "爬", sampleWord: "爬山", emoji: "⛰️", isInitial: true),
        PinyinItem(id: "py_m", symbol: "m", tones: ["m"], sampleChar: "妈", sampleWord: "妈妈", emoji: "👩", isInitial: true),
        PinyinItem(id: "py_f", symbol: "f", tones: ["f"], sampleChar: "风", sampleWord: "大风", emoji: "🌬️", isInitial: true),
        PinyinItem(id: "py_d", symbol: "d", tones: ["d"], sampleChar: "大", sampleWord: "大象", emoji: "🐘", isInitial: true),
        PinyinItem(id: "py_t", symbol: "t", tones: ["t"], sampleChar: "兔", sampleWord: "小兔", emoji: "🐰", isInitial: true),
        PinyinItem(id: "py_n", symbol: "n", tones: ["n"], sampleChar: "牛", sampleWord: "小牛", emoji: "🐮", isInitial: true),
        PinyinItem(id: "py_l", symbol: "l", tones: ["l"], sampleChar: "梨", sampleWord: "大梨", emoji: "🍐", isInitial: true),
        PinyinItem(id: "py_g", symbol: "g", tones: ["g"], sampleChar: "瓜", sampleWord: "西瓜", emoji: "🍉", isInitial: true),
        PinyinItem(id: "py_k", symbol: "k", tones: ["k"], sampleChar: "口", sampleWord: "张口", emoji: "👄", isInitial: true),
        PinyinItem(id: "py_h", symbol: "h", tones: ["h"], sampleChar: "花", sampleWord: "花朵", emoji: "🌸", isInitial: true),
        PinyinItem(id: "py_x", symbol: "x", tones: ["x"], sampleChar: "星", sampleWord: "星星", emoji: "⭐", isInitial: true),
    ]

    static let blendingPairs: [PinyinBlend] = [
        PinyinBlend(id: "bl_ma", initial: "m", finalPart: "ā", combined: "mā", character: "妈", word: "妈妈", emoji: "👩"),
        PinyinBlend(id: "bl_ba", initial: "b", finalPart: "à", combined: "bà", character: "爸", word: "爸爸", emoji: "👨"),
        PinyinBlend(id: "bl_hua", initial: "h", finalPart: "uā", combined: "huā", character: "花", word: "花朵", emoji: "🌸"),
        PinyinBlend(id: "bl_mao", initial: "m", finalPart: "āo", combined: "māo", character: "猫", word: "小猫", emoji: "🐱"),
        PinyinBlend(id: "bl_gou", initial: "g", finalPart: "ǒu", combined: "gǒu", character: "狗", word: "小狗", emoji: "🐶"),
        PinyinBlend(id: "bl_niu", initial: "n", finalPart: "iú", combined: "niú", character: "牛", word: "奶牛", emoji: "🐮"),
        PinyinBlend(id: "bl_gua", initial: "g", finalPart: "uā", combined: "guā", character: "瓜", word: "西瓜", emoji: "🍉"),
        PinyinBlend(id: "bl_huo", initial: "h", finalPart: "uǒ", combined: "huǒ", character: "火", word: "火车", emoji: "🚂"),
        PinyinBlend(id: "bl_mu", initial: "m", finalPart: "ù", combined: "mù", character: "木", word: "积木", emoji: "🌳"),
        PinyinBlend(id: "bl_mi", initial: "m", finalPart: "ǐ", combined: "mǐ", character: "米", word: "米饭", emoji: "🍚"),
    ]

    static func cards(for category: HanziCategory) -> [HanziCard] {
        hanziCards.filter { $0.category == category }
    }

    static func makeQuizQuestion(excluding lastId: String? = nil) -> WordQuizQuestion {
        let pool = hanziCards.filter { $0.id != lastId }
        let target = pool.randomElement() ?? hanziCards[0]
        let distractors = hanziCards
            .filter { $0.id != target.id }
            .shuffled()
            .prefix(3)
        let options = ([target] + distractors).shuffled()

        let sampleWord = target.words.first(where: { $0.contains(target.character) }) ?? target.character
        let maskedWord = sampleWord.replacingOccurrences(of: target.character, with: " ？ ")
        let prompt = "找出组成「\(sampleWord)」的字"
        let spokenPrompt = "小朋友，请找出「\(sampleWord)」里面的「\(target.character)」字吧！"

        return WordQuizQuestion(
            id: UUID(),
            prompt: prompt,
            spokenPrompt: spokenPrompt,
            wordHint: maskedWord,
            targetHanzi: target,
            options: options
        )
    }
}
