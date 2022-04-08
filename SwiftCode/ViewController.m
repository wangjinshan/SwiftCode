//
//  ViewController.m
//  SwiftCode
//
//  Created by 王金山 on 2022/3/4.
//

#import "ViewController.h"
#import "SwiftCode-Swift.h"
#import "NSString+Demo.h"

@interface ViewController ()
@property(strong) NSTimer *timer;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    
    self.timer = [NSTimer scheduledTimerWithTimeInterval:1 repeats: YES block:^(NSTimer * _Nonnull timer) {
       id temp = [self stringToAttributedString: @"dsacadfadW"];
    }];
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    CrashDemoController *vc = [[CrashDemoController alloc] init];
    [self presentViewController:vc animated:true completion:nil];
}


- (NSMutableAttributedString *)stringToAttributedString:(NSString *)source {
    // 替换\n为换行符,</br>, 闭合标签引起多余的换行
    source = [source stringByReplacingOccurrencesOfString:@"\n" withString:@"</br>"];
    
    return [source toHtmlString];
}

@end
