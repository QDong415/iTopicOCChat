//
//  AboutViewController.m
//当前应用版本 版本比较用
#define APP_CURRENT_VERSION [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"]
//当前应用名字
#define APP_CURRENT_NAME [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleDisplayName"]

#import "AboutViewController.h"

@interface AboutViewController ()
{
    IBOutlet UIImageView *_iconImageView;
    IBOutlet UILabel *_versionLabel;
    IBOutlet UILabel *_nameLabel;
}
@end

@implementation AboutViewController

- (IBAction)returnBack
{
    [self.navigationController popViewControllerAnimated:YES];
}
- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"关于我们";
    if (@available(iOS 11.0, *)) {
        self.view.backgroundColor = [UIColor colorNamed:@"background"];
    }
    // Do any additional setup after loading the view.
    _versionLabel.text = [NSString stringWithFormat:@"版本: %@", APP_CURRENT_VERSION];
    _nameLabel.text = APP_CURRENT_NAME;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
