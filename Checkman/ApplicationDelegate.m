#import "ApplicationDelegate.h"
#import "CheckDebuggingWindow.h"
#import "CheckManager.h"
#import "MenuController.h"
#import "NotificationsController.h"
#import "Settings.h"

@interface ApplicationDelegate () <MenuControllerDelegate, SettingsDelegate>
@property (nonatomic, strong) CheckManager *checkManager;
@property (nonatomic, strong) MenuController *menuController;
@property (nonatomic, strong) NotificationsController *notificationsController;
@property (nonatomic, strong) Settings *settings;
@end

@implementation ApplicationDelegate

@synthesize
    checkManager = _checkManager,
    menuController = _menuController,
    notificationsController = _notificationsController,
    settings = _settings;

- (void)applicationDidFinishLaunching:(NSNotification *)notification {
    [self _announceGitSha];
    [self performSelector:@selector(_setUp) withObject:nil afterDelay:0];
}

- (void)_setUp {
    [self _setUpSettings];
    [self _setUpMenu];
    [self _setUpNotifications];
    [self _setUpCheckManager];
}

- (void)_setUpSettings {
    self.settings = Settings.userSettings;
    self.settings.delegate = self;
    [self.settings trackChanges];
}

- (void)_setUpMenu {
    self.menuController = [[MenuController alloc] init];
    self.menuController.delegate = self;
}

- (void)_setUpNotifications {
    self.notificationsController = [[NotificationsController alloc] init];
    [self _configureNotificationsController];
}

- (void)_configureNotificationsController {
    self.notificationsController.allowGrowl =
        self.settings.allowGrowlNotifications;
    self.notificationsController.allowNotificationCenter =
        self.settings.allowNotificationCenterNotifications;
}

- (void)_setUpCheckManager {
    self.checkManager =
        [[CheckManager alloc]
            initWithMenuController:self.menuController
            notificationsController:self.notificationsController
            settings:self.settings];
    [self.checkManager loadCheckfiles];
}

#pragma mark - MenuControllerDelegate

- (void)menuController:(MenuController *)controller showDebugOutputForCheck:(Check *)check {
    CheckDebuggingWindow *window = [[CheckDebuggingWindow alloc] initWithCheck:check];
    [window keepOpenUntilClosed];
    [window show];
}

#pragma mark - SettingsDelegate

- (void)settingsDidChange:(Settings *)settings {
    [self.checkManager reloadCheckfiles];
    [self _configureNotificationsController];
}

#pragma mark - Git SHA

- (void)_announceGitSha {
    NSLog(@"ApplicationDelegate - Git SHA: %@", self.gitSha);
}

- (NSString *)gitSha {
    return [[[NSBundle mainBundle] infoDictionary] objectForKey:@"Git SHA"];
}
@end
