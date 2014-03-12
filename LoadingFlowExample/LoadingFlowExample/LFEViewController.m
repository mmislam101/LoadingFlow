//
//  LFEViewController.m
//  LoadingFlowExample
//
//  Created by Mohammed Islam on 3/1/14.
//  Copyright (c) 2014 KSI Technology. All rights reserved.
//

#import "LFEViewController.h"
#import "LoadingFlow.h"

@interface LFEViewController ()

@end

@implementation LFEViewController

- (void)loadView
{
	[super loadView];

	CGRect frame				= self.view.frame;
	self.view.backgroundColor	= [UIColor orangeColor];

	_currentLabel				= [[UILabel alloc] initWithFrame:CGRectMake(frame.size.width / 4.0, 100.0, frame.size.width, 44.0)];
	_currentLabel.text			= @"Current Time:";
	_currentLabel.backgroundColor	= [UIColor clearColor];

	[self.view addSubview:_currentLabel];

	_loadingFlow				= [[LoadingFlow alloc] initWithFrame:CGRectMake(0.0, 200.0, self.view.frame.size.width, self.view.frame.size.height - 200.0)];
	_loadingFlow.tintColor		= [UIColor blueColor];
	_loadingFlow.delegate		= self;

	[self.view addSubview:_loadingFlow];

	[_loadingFlow addSection:[LoadingFlowSection loadingFlowWithText:@"monkey" andDuration:3.0]];
	[_loadingFlow addSection:[LoadingFlowSection loadingFlowWithText:@"butt\ndog" andDuration:1.0]];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.

	self.navigationItem.rightBarButtonItem	= [[UIBarButtonItem alloc] initWithTitle:@"Pause" style:UIBarButtonItemStylePlain target:self action:@selector(pauseFlow)];
	self.navigationItem.leftBarButtonItem	= [[UIBarButtonItem alloc] initWithTitle:@"Start" style:UIBarButtonItemStylePlain target:self action:@selector(startFlow)];
}

- (void)viewDidAppear:(BOOL)animated
{
	[super viewDidAppear:animated];

	[_loadingFlow start];

	[NSTimer scheduledTimerWithTimeInterval:0.1 target:self selector:@selector(displayCurrentTime) userInfo:nil repeats:YES];

	[self performSelector:@selector(skipSection) withObject:nil afterDelay:1.0];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)displayCurrentTime
{
	_currentLabel.text = [NSString stringWithFormat:@"Current Time: %f", _loadingFlow.timeSinceStart];
}

- (void)skipSection
{
	[_loadingFlow skipToNextSection];
}

- (void)pauseFlow
{
	if (_loadingFlow.isRunning)
		[_loadingFlow pause];
	else
		[_loadingFlow resume];
}

- (void)startFlow
{
	[_loadingFlow start];
}

#pragma mark LoadingFlowDelegate

- (void)loadingFlow:(LoadingFlow *)loadingFlow hasCompletedSection:(LoadingFlowSection *)section atIndex:(NSInteger)idx
{
	NSLog(@"finished section:%i %@", idx, section.label.text);
}

@end
