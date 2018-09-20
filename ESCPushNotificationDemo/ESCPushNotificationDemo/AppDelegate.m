//
//  AppDelegate.m
//  ESCPushNotificationDemo
//
//  Created by xiang on 2018/9/20.
//  Copyright © 2018年 xiang. All rights reserved.
//

#import "AppDelegate.h"
#ifdef NSFoundationVersionNumber_iOS_9_x_Max
#import <UserNotifications/UserNotifications.h>
#endif

/*
 
 APP收到推送调用方法：
 
                            iOS8、iOS9                                iOS10及以上系统
 点击推送启动APP           调用function 1及function 2                 调用function 1及function 4
 APP在前台收到推送         调用function 2                             调用function 3
 APP在前台点击推送         调用function 2                             调用function 4
 APP在后台点击推送         调用function 2                             调用function 4
 
 */

@interface AppDelegate () <UNUserNotificationCenterDelegate>

@end

@implementation AppDelegate

#pragma mark - function 1
- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    [self replyPushNotificationAuthorization:application];
    NSLog(@"launchOptions == %@",launchOptions);
    return YES;
}

#pragma mark - function 2 iOS 10之前以前的用户
- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo fetchCompletionHandler:(void (^)(UIBackgroundFetchResult))completionHandler {
    NSLog(@"push notification did receive remote notification:%@", userInfo);
    completionHandler(UIBackgroundFetchResultNewData);
}

#pragma mark - function 3 iOS10及以后的用户
- (void)userNotificationCenter:(UNUserNotificationCenter *)center willPresentNotification:(UNNotification *)notification withCompletionHandler:(void (^)(UNNotificationPresentationOptions))completionHandler {
    NSLog(@"push notification did receive remote notification:%@",notification.request.content.userInfo);
    // 需要执行这个方法，选择是否提醒用户，有Badge、Sound、Alert三种类型可以设置,决定是否再显示此通知来提醒用户
    completionHandler(UNNotificationPresentationOptionBadge|UNNotificationPresentationOptionSound|UNNotificationPresentationOptionAlert);
}

#pragma mark - function 4 iOS10及以后的用户
- (void)userNotificationCenter:(UNUserNotificationCenter *)center didReceiveNotificationResponse:(UNNotificationResponse *)response withCompletionHandler:(void(^)(void))completionHandler {
    NSLog(@"push notification did receive remote notification:%@",response.notification.request.content.userInfo);
}

#pragma mark - 申请推送权限
- (void)replyPushNotificationAuthorization:(UIApplication *)application{
    
    if ([[UIDevice currentDevice].systemVersion floatValue] >= 10.0) {
        //iOS 10 later
        UNUserNotificationCenter *center = [UNUserNotificationCenter currentNotificationCenter];
        //必须写代理，不然无法监听通知的接收与点击事件
        center.delegate = self;
        [center requestAuthorizationWithOptions:(UNAuthorizationOptionBadge | UNAuthorizationOptionSound | UNAuthorizationOptionAlert) completionHandler:^(BOOL granted, NSError * _Nullable error) {
            if (!error && granted) {
                //用户点击允许
                NSLog(@"PushNotification====注册成功");
            }else{
                //用户点击不允许
                NSLog(@"PushNotification====注册失败");
            }
        }];
        
        //获取通知注册状态
        //        [center getNotificationSettingsWithCompletionHandler:^(UNNotificationSettings * _Nonnull settings) {
        //            NSLog(@"PushNotification====%@",settings);
        //        }];
    }else if ([[UIDevice currentDevice].systemVersion floatValue] >8.0){
        //iOS 8 - iOS 9系统
        UIUserNotificationSettings *settings = [UIUserNotificationSettings settingsForTypes:UIUserNotificationTypeAlert | UIUserNotificationTypeBadge | UIUserNotificationTypeSound categories:nil];
        [application registerUserNotificationSettings:settings];
    }
    //注册远端消息通知获取device token
    [application registerForRemoteNotifications];
}

#pragma mark - 授权申请token回调
//token获取成功
- (void) application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken {
    NSData  *apnsToken = [NSData dataWithData:deviceToken];
    
    NSString *tokenString = [[[apnsToken description]
                              stringByReplacingOccurrencesOfString: @"<" withString: @""]
                             stringByReplacingOccurrencesOfString: @">" withString: @""];
    NSLog(@"My token = %@", tokenString);
    
}

//token获取失败
- (void)application:(UIApplication *)application didFailToRegisterForRemoteNotificationsWithError:(NSError *)error {
    NSLog(@"did Fail To Register For Remote Notifications With Error: %@", error);
}

@end
