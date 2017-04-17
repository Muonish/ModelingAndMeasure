//
//  MeasureViewController.m
//  ModelingAndMeasure
//
//  Created by Valeryia Breshko on 4/12/17.
//  Copyright © 2017 Valeria Breshko. All rights reserved.
//

#import "MeasureViewController.h"
#import "VideoProcessor.h"
#import "ShowPictureViewController.h"

@interface MeasureViewController ()

@property (weak, nonatomic) IBOutlet UISegmentedControl *switchModeSegmentedControl;
@property (weak, nonatomic) IBOutlet UIImageView *cameraImageView;
@property (strong, nonatomic) VideoProcessor *videoProcessor;
@property (weak, nonatomic) IBOutlet UIView *heightCostomizationContainer;
@property (strong, nonatomic) UISlider *sliderControl;
@property (weak, nonatomic) IBOutlet UILabel *heightLabel;
@property (strong, nonatomic) NSTimer *takePictureTimer;

@end

@implementation MeasureViewController

- (UIStatusBarStyle)preferredStatusBarStyle {
    return UIStatusBarStyleLightContent;
}

- (void)initSliderControl {
    self.sliderControl = [UISlider new];
    self.sliderControl.tintColor = [UIColor whiteColor];
    self.sliderControl.maximumValue = 200;
    self.sliderControl.minimumValue = 10;
    [self.heightCostomizationContainer addSubview:self.sliderControl];
    [self.sliderControl addTarget:self action:@selector(sliderValueChanged:) forControlEvents:UIControlEventValueChanged];
}

- (IBAction)sliderValueChanged:(UISlider *)sender {
    self.heightLabel.text = [NSString stringWithFormat:@"%d", (int)self.sliderControl.value];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.videoProcessor = [[VideoProcessor alloc] initWithCameraView:self.cameraImageView
                                                               scale:2.0];
    [self initSliderControl];
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    self.sliderControl.translatesAutoresizingMaskIntoConstraints = YES;
    CGSize containerSize = self.heightCostomizationContainer.bounds.size;
    self.sliderControl.frame = CGRectMake(9, containerSize.height - 55, 44, containerSize.height - 160);
    CGAffineTransform trans = CGAffineTransformMakeRotation(-M_PI_2);
    self.sliderControl.layer.anchorPoint = CGPointMake(0, 0);
    self.sliderControl.transform = trans;
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self.videoProcessor startCapture];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self.videoProcessor stopCapture];
}

- (IBAction)onSwitchMode:(id)sender {
    BOOL isAutomatic = _switchModeSegmentedControl.selectedSegmentIndex > 0;
    self.videoProcessor.modelingEnabled = isAutomatic;
    self.heightCostomizationContainer.hidden = isAutomatic;
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"showPictureSegue"]) {
        ShowPictureViewController *pictureVC = (ShowPictureViewController *)segue.destinationViewController;
        pictureVC.inputImage = [self.videoProcessor captureProcessedImage];
        self.cameraImageView.image = pictureVC.inputImage;
    }
}

- (IBAction)onTouchDownTakePicture:(id)sender {
    self.takePictureTimer = [NSTimer scheduledTimerWithTimeInterval:0.5
                                     target:self
                                   selector:@selector(onTouchUpOutsideTakePicture:)
                                   userInfo:nil
                                    repeats:NO];
}

- (IBAction)onTouchUpInsideTakePicture:(id)sender {
    if (self.takePictureTimer && [self.videoProcessor captureProcessedImage]) {
        [self performSegueWithIdentifier:@"showPictureSegue" sender:self];
    } else {

    }
}

- (IBAction)onTouchUpOutsideTakePicture:(id)sender {
    self.takePictureTimer = nil;
}

@end
