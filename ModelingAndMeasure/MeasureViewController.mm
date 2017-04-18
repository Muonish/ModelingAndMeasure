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
#import "UserDefaultsSerializer.h"
#import "AccelerationHeightMeasuring.h"

static NSString *const kStartMeasureMessage = @"To start measure: Place bottom point in the center of the screen and long tap button.";
static NSString *const kEndMeasureMessage = @"Place top point in the center of the screen and just tap button. ";

@interface MeasureViewController ()

@property (weak, nonatomic) IBOutlet UISegmentedControl *switchModeSegmentedControl;
@property (weak, nonatomic) IBOutlet UIImageView *cameraImageView;
@property (strong, nonatomic) VideoProcessor *videoProcessor;
@property (weak, nonatomic) IBOutlet UIView *heightCostomizationContainer;
@property (strong, nonatomic) UISlider *sliderControl;
@property (weak, nonatomic) IBOutlet UILabel *heightLabel;
@property (weak, nonatomic) IBOutlet UIButton *takePictureButton;
@property (weak, nonatomic) IBOutlet UILabel *statusLabel;

@property (strong, nonatomic) AccelerationHeightMeasuring *accelerationMeasuring;

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
    self.sliderControl.value = [[UserDefaultsSerializer getObjectForKey:kHeightKey] floatValue];
    self.heightLabel.text = [NSString stringWithFormat:@"%d", (int)self.sliderControl.value];
    [self.heightCostomizationContainer addSubview:self.sliderControl];
    [self.sliderControl addTarget:self action:@selector(sliderValueChanged:) forControlEvents:UIControlEventValueChanged];
}

- (IBAction)sliderValueChanged:(UISlider *)sender {
    [UserDefaultsSerializer saveObject:@(self.sliderControl.value) forKey:kHeightKey];
    self.heightLabel.text = [NSString stringWithFormat:@"%d", (int)self.sliderControl.value];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.videoProcessor = [[VideoProcessor alloc] initWithCameraView:self.cameraImageView
                                                               scale:2.0];
    UILongPressGestureRecognizer *longPress = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longTap:)];
    [self.takePictureButton addGestureRecognizer:longPress];
    self.statusLabel.text = kStartMeasureMessage;
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

- (BOOL)isManualMode {
    return _switchModeSegmentedControl.selectedSegmentIndex == 0;
}

- (IBAction)onSwitchMode:(id)sender {
    BOOL isAutomatic = ![self isManualMode];
    self.statusLabel.text = isAutomatic ? nil : kStartMeasureMessage;
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

- (IBAction)onTouchUpInsideTakePicture:(id)sender {
    if ([self isManualMode] && self.accelerationMeasuring) {
        [self.accelerationMeasuring endMeasure];
        self.statusLabel.text = [NSString stringWithFormat:@"%.2f", self.accelerationMeasuring.distance];
        self.accelerationMeasuring = nil;
    } else if ([self.videoProcessor captureProcessedImage]) {
        [self performSegueWithIdentifier:@"showPictureSegue" sender:self];
    }
}

- (void)longTap:(UIGestureRecognizer*)gestureRecognizer {
    if([self isManualMode] && !self.accelerationMeasuring) {
        self.accelerationMeasuring = [[AccelerationHeightMeasuring alloc] initWithHeight:self.sliderControl.value];
        [self.accelerationMeasuring startMeasure];
        self.statusLabel.text = kEndMeasureMessage;
    }
}

@end
