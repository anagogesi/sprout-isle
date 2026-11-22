import Foundation

enum HabitStickerCatalog {
    static let defaultHabits: [HabitItem] = [
        HabitItem(id: "hab_brush", title: "早晚刷牙", emoji: "🪥", encourageText: "小白牙刷得亮晶晶，蛀牙虫全跑光啦！", starReward: 2, isCustom: false),
        HabitItem(id: "hab_wash", title: "饭前洗手", emoji: "🧼", encourageText: "泡泡洗小手，干干净净真讲究！", starReward: 1, isCustom: false),
        HabitItem(id: "hab_eat", title: "好好吃饭", emoji: "🥦", encourageText: "蔬菜米饭吃光光，长成大力士！", starReward: 2, isCustom: false),
        HabitItem(id: "hab_toys", title: "自己收玩具", emoji: "🧸", encourageText: "玩具都回家睡觉啦，你真是个整理小能手！", starReward: 2, isCustom: false),
        HabitItem(id: "hab_read", title: "每天读绘本", emoji: "📚", encourageText: "爱看书的小朋友，脑袋里装满魔法故事！", starReward: 2, isCustom: false),
        HabitItem(id: "hab_sleep", title: "按时睡觉", emoji: "🌙", encourageText: "乖乖早睡做美梦，明天精神满满！", starReward: 2, isCustom: false),
        HabitItem(id: "hab_water", title: "乖乖喝水", emoji: "💧", encourageText: "咕嘟咕嘟喝温水，小芽也要喝饱水长大！", starReward: 1, isCustom: false),
        HabitItem(id: "hab_polite", title: "礼貌问好", emoji: "👋", encourageText: "懂礼貌说你好和谢谢，人人都喜欢你！", starReward: 1, isCustom: false),
    ]

    static let stickers: [StickerItem] = [
        // 森林伙伴
        StickerItem(id: "sticker_sprout", name: "小芽芽", emoji: "🌱", category: .forest, starCost: 0, tintHex: "34B37E"),
        StickerItem(id: "sticker_rabbit", name: "跳跳兔", emoji: "🐰", category: .forest, starCost: 3, tintHex: "FF8FAB"),
        StickerItem(id: "sticker_fox", name: "机灵狐", emoji: "🦊", category: .forest, starCost: 4, tintHex: "F4845F"),
        StickerItem(id: "sticker_panda", name: "滚滚熊", emoji: "🐼", category: .forest, starCost: 5, tintHex: "43AA8B"),
        StickerItem(id: "sticker_butterfly", name: "花蝴蝶", emoji: "🦋", category: .forest, starCost: 3, tintHex: "4EA8DE"),
        StickerItem(id: "sticker_dino", name: "萌恐龙", emoji: "🦕", category: .forest, starCost: 6, tintHex: "52B788"),

        // 美味点心
        StickerItem(id: "sticker_cupcake", name: "纸杯蛋糕", emoji: "🧁", category: .sweets, starCost: 3, tintHex: "FF758F"),
        StickerItem(id: "sticker_icecream", name: "甜筒冰", emoji: "🍦", category: .sweets, starCost: 3, tintHex: "FFB703"),
        StickerItem(id: "sticker_donut", name: "甜甜圈", emoji: "🍩", category: .sweets, starCost: 4, tintHex: "E76F51"),
        StickerItem(id: "sticker_strawberry", name: "大草莓", emoji: "🍓", category: .sweets, starCost: 2, tintHex: "FF595E"),
        StickerItem(id: "sticker_lollipop", name: "棒棒糖", emoji: "🍭", category: .sweets, starCost: 4, tintHex: "9B72CF"),
        StickerItem(id: "sticker_watermelon", name: "甜西瓜", emoji: "🍉", category: .sweets, starCost: 3, tintHex: "34B37E"),

        // 梦幻星空
        StickerItem(id: "sticker_sun", name: "暖太阳", emoji: "☀️", category: .space, starCost: 0, tintHex: "FFB703"),
        StickerItem(id: "sticker_rainbow", name: "七彩虹", emoji: "🌈", category: .space, starCost: 5, tintHex: "FF9F1C"),
        StickerItem(id: "sticker_moon", name: "弯月亮", emoji: "🌙", category: .space, starCost: 4, tintHex: "7B61FF"),
        StickerItem(id: "sticker_saturn", name: "小土星", emoji: "🪐", category: .space, starCost: 6, tintHex: "9B72CF"),
        StickerItem(id: "sticker_comet", name: "许愿星", emoji: "🌠", category: .space, starCost: 7, tintHex: "4EA8DE"),
        StickerItem(id: "sticker_unicorn", name: "独角兽", emoji: "🦄", category: .space, starCost: 8, tintHex: "FF8FAB"),

        // 酷炫交通
        StickerItem(id: "sticker_rocket", name: "小火箭", emoji: "🚀", category: .vehicles, starCost: 6, tintHex: "4EA8DE"),
        StickerItem(id: "sticker_train", name: "小火车", emoji: "🚂", category: .vehicles, starCost: 5, tintHex: "FF6B6B"),
        StickerItem(id: "sticker_plane", name: "小飞机", emoji: "✈️", category: .vehicles, starCost: 5, tintHex: "0096C7"),
        StickerItem(id: "sticker_boat", name: "小帆船", emoji: "⛵", category: .vehicles, starCost: 4, tintHex: "2A9D8F"),
        StickerItem(id: "sticker_balloon", name: "热气球", emoji: "🎈", category: .vehicles, starCost: 3, tintHex: "FF595E"),
        StickerItem(id: "sticker_castle", name: "童话堡", emoji: "🏰", category: .vehicles, starCost: 10, tintHex: "9B72CF"),
    ]

    static func sticker(by id: String) -> StickerItem? {
        stickers.first { $0.id == id }
    }

    static func stickers(for category: StickerCategory) -> [StickerItem] {
        stickers.filter { $0.category == category }
    }
}
