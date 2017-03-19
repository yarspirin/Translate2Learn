//
//  MVLearnViewController.m
//  Translate2Learn
//
//  Created by whoami on 3/19/17.
//  Copyright © 2017 Mountain Viewer. All rights reserved.
//

#import "MVLearnViewController.h"
#import "CoreData/CoreData.h"
#import "Translation+CoreDataClass.h"
#import "AppDelegate.h"

@interface MVLearnViewController ()

@property (nonatomic) NSArray *translations;
@property (weak, nonatomic) IBOutlet UITableView *translationTableView;

@end

@implementation MVLearnViewController

#pragma mark - Cell Retrieval Method -
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
  UIAlertController *controller = [UIAlertController alertControllerWithTitle: [_translations[indexPath.row] translated]  message: nil preferredStyle: UIAlertControllerStyleAlert];
  
  UIAlertAction *action = [UIAlertAction actionWithTitle: @"Learned!" style: UIAlertActionStyleDefault handler: nil];
  
  [controller addAction: action];
  [self presentViewController: controller animated: YES completion: nil];
}

#pragma mark - Table View Data Source -

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
  return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
  return _translations.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
  UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier: @"cell"];
  
  if (!cell) {
    cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier: @"cell"];
  }
  
  [cell.textLabel setText: [_translations[indexPath.row] word]];
  [cell.textLabel setTextColor: [UIColor blackColor]];
  [cell.textLabel setTextAlignment: NSTextAlignmentCenter];
  [cell.textLabel setFont: [UIFont fontWithName: @"AppleSDGothicNeo-Thin" size: 20]];
  
  return cell;
}

#pragma mark - Database Retrieval Method -

- (void) retrieveData {
  NSFetchRequest<Translation *> *fetchRequest = [Translation fetchRequest];
  NSError *error = nil;
  
  NSManagedObjectContext *context = ((AppDelegate*) [[UIApplication sharedApplication] delegate]).persistentContainer.viewContext;
  
  _translations = [context executeFetchRequest:fetchRequest error:&error];
  NSLog(@"%ld", [_translations count]);
  [self.translationTableView reloadData];
}

#pragma mark - State methods -

- (void)viewDidLoad {
  [super viewDidLoad];
  [self.translationTableView setDelegate: self];
  [self.translationTableView setDataSource: self];
}

- (void)viewWillAppear:(BOOL)animated {
  [super viewWillAppear: animated];
  [self retrieveData];
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
