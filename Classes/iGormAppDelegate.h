#import <UIKit/UIKit.h>

@interface iGormAppDelegate : NSObject <UIApplicationDelegate, UITabBarControllerDelegate> {
  UIWindow *window;
  IBOutlet UITabBarController *rootController;
  IBOutlet UIActivityIndicatorView *waiting;
}

@property(nonatomic, retain) IBOutlet UIWindow *window;
@property(nonatomic, retain) UITabBarController *rootController;
@property(nonatomic, retain) UIActivityIndicatorView *waiting;

@end
