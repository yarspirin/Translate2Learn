//
//  Translation+CoreDataProperties.m
//  
//
//  Created by whoami on 3/19/17.
//
//  This file was automatically generated and should not be edited.
//

#import "Translation+CoreDataProperties.h"

@implementation Translation (CoreDataProperties)

+ (NSFetchRequest<Translation *> *)fetchRequest {
	return [[NSFetchRequest alloc] initWithEntityName:@"Translation"];
}

@dynamic translated;
@dynamic word;

@end
