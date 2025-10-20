Config = {}

Config.ProtectedItems = {
    'phone',
    'radio',

}

Config.EnableNotifications = true

Config.Notifications = {
    protectedItem = {
        title = 'Anti-Rob System',
        description = 'This item cannot be stolen',
        type = 'error'
    },
    robAttempt = {
        title = 'Security Alert',
        description = 'Someone tried to steal protected items from you',
        type = 'inform'
    },
    cannotMove = {
        title = 'Protected Item',
        description = 'This item cannot be moved to containers',
        type = 'error'
    },
    cannotDrop = {
        title = 'Protected Item',
        description = 'This item cannot be dropped',
        type = 'error'
    }
}

Config.LogRobAttempts = true

Config.Discord = {
    webhook = '',
    color = 16711680,
    title = 'Anti-Rob Log',
    footer = 'Fearx Anti-Rob System'
}