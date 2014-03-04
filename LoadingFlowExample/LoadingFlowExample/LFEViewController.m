//
//  LFEViewController.m
//  LoadingFlowExample
//
//  Created by Mohammed Islam on 3/1/14.
//  Copyright (c) 2014 KSI Technology. All rights reserved.
//

#import "LFEViewController.h"
#import "LoadingFlow.h"
#import "LoadingFlowSection.h"

@interface LFEViewController ()

@end

@implementation LFEViewController

- (void)loadView
{
	[super loadView];

	UIButton *button		= [UIButton buttonWithType:UIButtonTypeRoundedRect];
	button.frame			= CGRectMake(100.0, 100.0, 100.0, 44.0);
	[button setTitle:@"Current Time" forState:UIControlStateNormal];
	[button addTarget:self action:@selector(displayCurrentTime) forControlEvents:UIControlEventTouchDown];

	[self.view addSubview:button];

	_loadingFlow			= [[LoadingFlow alloc] initWithFrame:CGRectMake(0.0, 200.0, self.view.frame.size.width, self.view.frame.size.height - 200.0)];
	_loadingFlow.tintColor	= [UIColor blueColor];

	[self.view addSubview:_loadingFlow];

	[_loadingFlow addSection:[LoadingFlowSection loadingFlowWithText:@"monkey" andDuration:5.0]];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
}

- (void)viewDidAppear:(BOOL)animated
{
	[super viewDidAppear:animated];

	[_loadingFlow start];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)displayCurrentTime
{
	NSLog(@"current time: %f", _loadingFlow.timeSinceStart);
}

@end
