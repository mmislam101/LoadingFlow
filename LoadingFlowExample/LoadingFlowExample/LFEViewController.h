//
//  LFEViewController.h
//  LoadingFlowExample
//
//  Created by Mohammed Islam on 3/1/14.
//  Copyright (c) 2014 KSI Technology. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LoadingFlow.h"

@interface LFEViewController : UIViewController <LoadingFlowDelegate>
{
	LoadingFlow *_loadingFlow;
	UILabel *_currentLabel;
}

@end
