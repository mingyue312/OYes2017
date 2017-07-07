
#import "EaseRefreshTableViewController.h"

#import "EaseUserModel.h"
#import "EaseUserCell.h"
#import "EaseSDKHelper.h"

@class EaseUsersListViewController;

@protocol EMUserListViewControllerDelegate <NSObject>

- (void)userListViewController:(EaseUsersListViewController *)userListViewController
            didSelectUserModel:(id<IUserModel>)userModel;

@optional

- (void)userListViewController:(EaseUsersListViewController *)userListViewController
            didDeleteUserModel:(id<IUserModel>)userModel;

@end

@protocol EMUserListViewControllerDataSource <NSObject>

@optional

- (NSInteger)numberOfRowInUserListViewController:(EaseUsersListViewController *)userListViewController;

- (id<IUserModel>)userListViewController:(EaseUsersListViewController *)userListViewController
                           modelForusername:(NSString *)username;

- (id<IUserModel>)userListViewController:(EaseUsersListViewController *)userListViewController
                   userModelForIndexPath:(NSIndexPath *)indexPath;

@end

@interface EaseUsersListViewController : EaseRefreshTableViewController

@property (weak, nonatomic) id<EMUserListViewControllerDelegate> delegate;

@property (weak, nonatomic) id<EMUserListViewControllerDataSource> dataSource;

@property (nonatomic) BOOL showSearchBar;

- (void)tableViewDidTriggerHeaderRefresh;

@end
