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
	self.view.backgroundColor	= [UIColor grayColor];

	_currentLabel				= [[UILabel alloc] initWithFrame:CGRectMake(frame.size.width / 4.0, 100.0, frame.size.width, 44.0)];
	_currentLabel.text			= @"Current Time:";
	_currentLabel.backgroundColor	= [UIColor clearColor];

	[self.view addSubview:_currentLabel];

	_loadingFlow				= [[LoadingFlow alloc] initWithFrame:CGRectMake(0.0, 200.0, self.view.frame.size.width, self.view.frame.size.height - 200.0 - 44.0)];
	_loadingFlow.tintColor		= [UIColor redColor];
	_loadingFlow.delegate		= self;

	[self.view addSubview:_loadingFlow];

	[_loadingFlow addSection:[LoadingFlowSection sectionWithText:@"monkey 3" andDuration:3.0]];
	[_loadingFlow addSection:[LoadingFlowSection sectionWithText:@"monkey 4" andDuration:1.0]];
	[_loadingFlow addSection:[LoadingFlowSection sectionWithText:@"monkey 5" andDuration:1.0]];
	[_loadingFlow addSection:[LoadingFlowSection sectionWithText:@"monkey 6" andDuration:1.0]];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.

	self.navigationItem.rightBarButtonItem	= [[UIBarButtonItem alloc] initWithTitle:@"Wait" style:UIBarButtonItemStylePlain target:self action:@selector(waitFlow)];
	self.navigationItem.leftBarButtonItem	= [[UIBarButtonItem alloc] initWithTitle:@"Message" style:UIBarButtonItemStylePlain target:self action:@selector(messageFlow)];

	[self.navigationController setToolbarHidden:NO];

	UIBarButtonItem *startButton = [[UIBarButtonItem alloc] initWithTitle:@"Start" style:UIBarButtonItemStylePlain target:self action:@selector(startFlow)];
	UIBarButtonItem *stopButton = [[UIBarButtonItem alloc] initWithTitle:@"Stop" style:UIBarButtonItemStylePlain target:self action:@selector(stopFlow)];
	UIBarButtonItem *pauseButton = [[UIBarButtonItem alloc] initWithTitle:@"Pause" style:UIBarButtonItemStylePlain target:self action:@selector(pauseFlow)];
	UIBarButtonItem *skipButton = [[UIBarButtonItem alloc] initWithTitle:@"Skip" style:UIBarButtonItemStylePlain target:self action:@selector(skipSection)];

	[self setToolbarItems:@[startButton,
							[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil],
							stopButton,
							[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil],
							pauseButton,
							[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil],
							skipButton]];
}

- (void)viewDidAppear:(BOOL)animated
{
	[super viewDidAppear:animated];

	[NSTimer scheduledTimerWithTimeInterval:0.1 target:self selector:@selector(displayCurrentTime) userInfo:nil repeats:YES];
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
	[_loadingFlow skipToNextSectionWithDuration:1.0];
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
	[_loadingFlow startWithCompletion:^(LoadingFlow *loadingFlow) {
		
	}];

	self.navigationItem.rightBarButtonItem	= [[UIBarButtonItem alloc] initWithTitle:@"Wait" style:UIBarButtonItemStylePlain target:self action:@selector(waitFlow)];
}

- (void)stopFlow
{
	[_loadingFlow stopWithCompletion:nil];
}

- (void)waitFlow
{
	[_loadingFlow stopWithCompletion:^(LoadingFlow *loadingFlow) {
		[self startWait];
	}];
}

- (void)waitStop
{
	[_loadingFlow stopWaitingWithCompletion:^(LoadingFlow *loadingFlow) {
		self.navigationItem.rightBarButtonItem	= [[UIBarButtonItem alloc] initWithTitle:@"Wait" style:UIBarButtonItemStylePlain target:self action:@selector(waitFlow)];
	}];
}

- (void)startWait
{
	self.navigationItem.rightBarButtonItem	= [[UIBarButtonItem alloc] initWithTitle:@"Stop Waiting" style:UIBarButtonItemStylePlain target:self action:@selector(waitStop)];

	LoadingFlowSection *section				= [LoadingFlowSection sectionWithText:@"Waiting..." andDuration:0.0];
	section.label.textColor					= [UIColor blackColor];
	section.duration						= 3.0;
	[_loadingFlow startWaitingWithSection:section];
}

- (void)messageFlow
{
	// Finished last section
	UILabel *message		= [[UILabel alloc] init];
	message.text			= @"Butts!!!";
	message.textAlignment	= NSTextAlignmentCenter;
	[message sizeToFit];
	[_loadingFlow displayMessageLabel:message duration:2.0 withCompletion:^(LoadingFlow *loadingFlow) {
		NSLog(@"finished!");
	}];
}

#pragma mark LoadingFlowDelegate

- (void)loadingFlow:(LoadingFlow *)loadingFlow hasCompletedSection:(LoadingFlowSection *)section atIndex:(NSInteger)idx
{
	if (idx == loadingFlow.sections.count-1)
	{
		// Finished last section
		UILabel *message		= [[UILabel alloc] init];
		message.text			= @"MONKEYS!!!";
		message.textAlignment	= NSTextAlignmentCenter;
		[message sizeToFit];
		[loadingFlow displayMessageLabel:message duration:2.0 withCompletion:^(LoadingFlow *loadingFlow) {
			NSLog(@"finished!");
		}];
	}
}

- (void)loadingFlowWasTapped:(LoadingFlow *)loadingFlow
{
	NSLog(@"tapped!");
}

@end
