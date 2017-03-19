//
//  MVTranslateViewController.m
//  Translate2Learn
//
//  Created by whoami on 3/19/17.
//  Copyright © 2017 Mountain Viewer. All rights reserved.
//

#import "MVTranslateViewController.h"
#import "CoreData/CoreData.h"
#import "AppDelegate.h"

#define APIKEY @"ZDhlMGRjMGItMDlmYi00Nzc4LWFmN2QtOTM1ZGE3Njg0NzFmOjI1YjY5ZDRiOWRkYTQ0M2VhYWQzNTdjYjRiMjQwNTdh"

@interface MVTranslateViewController ()

@property (weak, nonatomic) IBOutlet UIPickerView *translationPicker;
@property (nonatomic, readonly) NSArray *translationOptions;
@property (weak, nonatomic) IBOutlet UITextField *wordToTranslate;
@property (weak, nonatomic) IBOutlet UIButton *translateButton;
@property (weak, nonatomic) IBOutlet UITextField *translation;
@property (weak, nonatomic) IBOutlet UIButton *addToDictionaryButton;
@property (nonatomic) NSString *token;

@end

@implementation MVTranslateViewController

#pragma mark - User Interface Actions -

- (IBAction)translate: (UIButton *)sender {
  NSArray *languageID = [self getLanguageID];
  
  NSUInteger from = [languageID[0] integerValue];
  NSUInteger to = [languageID[1] integerValue];
  
  [_wordToTranslate resignFirstResponder];
  [self performTranslation: self.wordToTranslate.text from: from to: to];
}

- (IBAction)addToDictionary:(UIButton *)sender {
  NSManagedObjectContext *context = ((AppDelegate*) [[UIApplication sharedApplication] delegate]).persistentContainer.viewContext;
  
  NSManagedObject *entityNameObj = [NSEntityDescription insertNewObjectForEntityForName:@"Translation" inManagedObjectContext:context];
  
  [entityNameObj setValue: _wordToTranslate.text forKey: @"word"];
  [entityNameObj setValue: _translation.text forKey: @"translated"];
  
  [((AppDelegate*)[[UIApplication sharedApplication] delegate]) saveContext];
}

#pragma mark - Delegate methods -

-(NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component {
  return [_translationOptions count];
}

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView {
  return 1;
}

- (UIView *)pickerView:(UIPickerView *)pickerView viewForRow:(NSInteger)row
          forComponent:(NSInteger)component reusingView:(UIView *)view {
  
  UILabel *futurePickerView = (UILabel*)view;
  if (!futurePickerView) {
    futurePickerView = [[UILabel alloc] initWithFrame:CGRectMake(0.0f, 0.0f, [pickerView rowSizeForComponent:component].width, [pickerView rowSizeForComponent:component].height)];
  }
  
  futurePickerView.font = [UIFont fontWithName: @"AppleSDGothicNeo-Thin" size: 20];
  futurePickerView.text = _translationOptions[row];
  futurePickerView.textAlignment = NSTextAlignmentCenter;
  futurePickerView.textColor = [UIColor redColor];
  
  return futurePickerView;
}

- (BOOL) textFieldShouldReturn:(UITextField *)textField {
  [_wordToTranslate resignFirstResponder];
  return YES;
}

#pragma mark - Configure methods -

- (void) configureTranslationOptions {
  _translationOptions = [[NSArray alloc] initWithObjects: @"English ➞ Русский", @"Русский ➞ English", nil];
}

- (void) configureTranslationPicker {
  _translationPicker.delegate = self;
}

- (void) configureWordToTranslate {
  _wordToTranslate.layer.borderColor = [[UIColor redColor] CGColor];
  _wordToTranslate.layer.borderWidth = 1.0;
  _wordToTranslate.layer.cornerRadius = 5.0;
  _wordToTranslate.delegate = self;
}

- (void) configureTranslateButton {
  _translateButton.layer.borderColor = [[UIColor redColor] CGColor];
  _translateButton.layer.borderWidth = 1.0;
  _translateButton.layer.cornerRadius = 5.0;
}

- (void) configureTranslation {
  _translation.enabled = NO;
  _translation.layer.borderColor = [[UIColor redColor] CGColor];
  _translation.layer.borderWidth = 1.0;
  _translation.layer.cornerRadius = 5.0;
}

- (void) configureAddToDictionaryButton {
  _addToDictionaryButton.layer.borderColor = [[UIColor redColor] CGColor];
  _addToDictionaryButton.layer.borderWidth = 1.0;
  _addToDictionaryButton.layer.cornerRadius = 5.0;
}

#pragma mark - State methods -

- (void)viewDidLoad {
  [super viewDidLoad];
  
  [self configureTranslationOptions];
  [self configureTranslationPicker];
  [self configureWordToTranslate];
  [self configureTranslateButton];
  [self configureTranslation];
  [self configureAddToDictionaryButton];
  [self loadToken];
}

#pragma mark - Utility methods -

- (NSArray *) getLanguageID {
  if ([_translationPicker selectedRowInComponent: 0]) {
    return [[NSArray alloc] initWithObjects: @"1049", @"1033", nil];
  }

  return [[NSArray alloc] initWithObjects: @"1033", @"1049", nil];
}

- (void) loadToken {
  AFURLSessionManager *manager = [[AFURLSessionManager alloc] initWithSessionConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration]];
  manager.responseSerializer = [AFHTTPResponseSerializer serializer];
  
  NSMutableURLRequest *req = [[AFHTTPRequestSerializer serializer] requestWithMethod: @"POST" URLString:@"https://developers.lingvolive.com/api/v1.1/authenticate" parameters:nil error:nil];
  
  req.timeoutInterval = [[[NSUserDefaults standardUserDefaults] valueForKey: @"timeoutInterval"] longValue];
  [req setValue: [NSString stringWithFormat:@"Basic %@", APIKEY] forHTTPHeaderField: @"Authorization"];
  
  
  [[manager dataTaskWithRequest:req completionHandler:^(NSURLResponse * _Nonnull response, id  _Nullable responseObject, NSError * _Nullable error) {
    
    if (!error) {
      NSString *string = [[NSString alloc] initWithData:responseObject encoding:NSUTF8StringEncoding];
      self.token = string;
    } else {
      NSLog(@"Error: %@, %@, %@", error, response, responseObject);
    }
  }] resume];
}

- (NSString *) firstWordOf: (NSString *) string {
  NSArray *split = [[[string componentsSeparatedByString: @" "][0] componentsSeparatedByString: @","][0] componentsSeparatedByString: @";"];
  return split[0];
}

- (void) performTranslation: (NSString *)text from: (NSUInteger)from to: (NSUInteger)to {
  
  if ([self.token isEqualToString:@""]) {
    return;
  }
  
  [MBProgressHUD showHUDAddedTo: self.view animated:YES];

  AFURLSessionManager *manager = [[AFURLSessionManager alloc] initWithSessionConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration]];
  manager.responseSerializer = [AFJSONResponseSerializer serializer];
  
  text = [text stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLFragmentAllowedCharacterSet]];

  NSMutableURLRequest *req = [[AFHTTPRequestSerializer serializer] requestWithMethod: @"GET" URLString: [NSString stringWithFormat: @"https://developers.lingvolive.com/api/v1/Minicard?text=%@&srcLang=%ld&dstLang=%ld", text, from, to] parameters: nil error: nil];
  
  req.timeoutInterval = [[[NSUserDefaults standardUserDefaults] valueForKey: @"timeoutInterval"] longValue];
  [req setValue: [NSString stringWithFormat: @"Bearer %@", self.token] forHTTPHeaderField: @"Authorization"];
  
  
  [[manager dataTaskWithRequest:req completionHandler:^(NSURLResponse * _Nonnull response, id  _Nullable responseObject, NSError * _Nullable error) {
    
    if (!error) {
      if ([responseObject isKindOfClass:[NSDictionary class]]) {
        [self.translation performSelectorOnMainThread: @selector(setText:) withObject: [self firstWordOf: responseObject[@"Translation"][@"Translation"]] waitUntilDone: YES];
      }
    } else {
      NSLog(@"Error: %@, %@, %@", error, response, responseObject);
      UIAlertController *alertController = [UIAlertController alertControllerWithTitle: @"Request is incorrect" message: @"Please try attempt with another request" preferredStyle: UIAlertControllerStyleAlert];
      
      UIAlertAction *okAction = [UIAlertAction actionWithTitle: @"OK" style: UIAlertActionStyleDefault handler: ^(UIAlertAction * action)
                                 {
                                   [alertController dismissViewControllerAnimated: YES completion: nil];
                                 }];
      
      [alertController addAction: okAction];
      [self presentViewController: alertController animated: YES completion: nil];
    }
    
    dispatch_async(dispatch_get_main_queue(), ^{
      [MBProgressHUD hideHUDForView:self.view animated:YES];
    });
  }] resume];
}

- (void)didReceiveMemoryWarning {
  [super didReceiveMemoryWarning];
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
