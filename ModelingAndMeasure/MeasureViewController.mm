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
#import "Model3DBuilder.h"
#import "UserSettings.h"

static NSString *const kStartMeasureMessage = @"To start measure: Place bottom point in the center of the screen and long tap button.";
static NSString *const kEndMeasureMessage = @"Place top point in the center of the screen and just tap button. ";

static NSString *const kAutoStartMeasureMessage = @"To start measure: Place start point in the center of the screen and long tap button.";
static NSString *const kAutoModelingMessage = @"Build 3-D...";

@interface MeasureViewController () <Model3DBuilderDelegate>

@property (weak, nonatomic) IBOutlet UISegmentedControl *switchModeSegmentedControl;
@property (weak, nonatomic) IBOutlet UIImageView *cameraImageView;
@property (strong, nonatomic) VideoProcessor *videoProcessor;
@property (weak, nonatomic) IBOutlet UIView *heightCostomizationContainer;
@property (strong, nonatomic) UISlider *sliderControl;
@property (weak, nonatomic) IBOutlet UILabel *heightLabel;
@property (weak, nonatomic) IBOutlet UIButton *takePictureButton;
@property (weak, nonatomic) IBOutlet UIButton *unitsButton;
@property (weak, nonatomic) IBOutlet UILabel *statusLabel;
@property (weak, nonatomic) IBOutlet UIImageView *modelImageView;

@property (strong, nonatomic) AccelerationHeightMeasuring *accelerationMeasuring;
@property (strong, nonatomic) Model3DBuilder *modelBuilder;

@end

@implementation MeasureViewController

- (UIStatusBarStyle)preferredStatusBarStyle {
    return UIStatusBarStyleLightContent;
}

- (void)initSliderControl {
    self.sliderControl = [UISlider new];
    self.sliderControl.tintColor = [UIColor whiteColor];
    self.sliderControl.maximumValue = 200; // cm
    self.sliderControl.minimumValue = 10;
    self.sliderControl.value = [[UserSettings instance].height floatValue];
    [self.unitsButton setTitle:[UserSettings instance].units.name forState:UIControlStateNormal];
    [self updateHeightWithValue:self.sliderControl.value];
    [self.heightCostomizationContainer addSubview:self.sliderControl];
    [self.sliderControl addTarget:self action:@selector(sliderValueChanged:) forControlEvents:UIControlEventValueChanged];
    [self.sliderControl addTarget:self action:@selector(sliderDidEndSliding:) forControlEvents:(UIControlEventTouchUpInside | UIControlEventTouchUpOutside)];
}

- (IBAction)sliderValueChanged:(UISlider *)sender {
    [self updateHeightWithValue:self.sliderControl.value];
}

- (IBAction)sliderDidEndSliding:(UISlider *)sender {
    UserSettings *settings = [UserSettings instance];
    settings.height = @(self.sliderControl.value);
    [settings save];
    [self updateHeightWithValue:[settings.height floatValue]];
}

- (void)updateHeightWithValue:(CGFloat)value {
    UserSettings *settings = [UserSettings instance];
    value = value * settings.units.multiplier;
    NSString *text;
    switch (settings.units.type) {
        case cmUnits:
            text = [NSString stringWithFormat:@"%3.1f", value];
            break;
        case mUnits:
            text = [NSString stringWithFormat:@"%3.3f", value];
            break;
        case mmUnits:
            text = [NSString stringWithFormat:@"%3.0f", value];
            break;
        default:
            break;
    }

    self.heightLabel.text = text;
}

- (IBAction)onUnitsChange:(id)sender {
    UserSettings *settings = [UserSettings instance];
    settings.units.type = [settings.units nextType];
    [settings save];
    [self.unitsButton setTitle:settings.units.name forState:UIControlStateNormal];
    [self updateHeightWithValue:[settings.height floatValue]];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.videoProcessor = [[VideoProcessor alloc] initWithCameraView:self.cameraImageView scale:2.0];
    UILongPressGestureRecognizer *longPress = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longTap:)];
    [self.takePictureButton addGestureRecognizer:longPress];
    self.statusLabel.text = kStartMeasureMessage;
    self.modelImageView.layer.masksToBounds = YES;
    self.modelImageView.layer.cornerRadius = 4.f;
    self.modelImageView.hidden = YES;
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
    self.statusLabel.text = isAutomatic ? kAutoStartMeasureMessage : kStartMeasureMessage;
    self.videoProcessor.modelingEnabled = isAutomatic;
    self.modelImageView.hidden = !isAutomatic;
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
    if (gestureRecognizer.state == UIGestureRecognizerStateBegan) {
        NSLog(@"long press");
        if ([self isManualMode]) {
            if(!self.accelerationMeasuring) {
                self.accelerationMeasuring = [[AccelerationHeightMeasuring alloc] initWithHeight:self.sliderControl.value];
                [self.accelerationMeasuring startMeasure];
                self.statusLabel.text = kEndMeasureMessage;
            }
        } else {
            self.statusLabel.text = kAutoModelingMessage;
            if (!self.modelBuilder || !self.modelBuilder.isModeling) {
                [self initModelBuilder];
            }
        }
    }
}

- (void)initModelBuilder {
    self.modelBuilder = [[Model3DBuilder alloc] initWithImages:[self.videoProcessor getBufferedImages]
                                                         scale:2.0];
    self.modelBuilder.delegate = self;
    [self.modelBuilder runModeling];
}

#pragma mark <Model3DBuilderDelegate>

- (void)modelBuilder:(Model3DBuilder *)mb didFinishModelingWithModel:(UIImage *)image {
    self.statusLabel.text = @"Finish";
    self.modelImageView.image = image;
}

@end
