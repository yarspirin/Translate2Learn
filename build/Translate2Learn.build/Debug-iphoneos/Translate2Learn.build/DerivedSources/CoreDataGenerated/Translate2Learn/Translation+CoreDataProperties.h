//
//  Translation+CoreDataProperties.h
//  
//
//  Created by whoami on 3/19/17.
//
//  This file was automatically generated and should not be edited.
//

#import "Translation+CoreDataClass.h"


NS_ASSUME_NONNULL_BEGIN

@interface Translation (CoreDataProperties)

+ (NSFetchRequest<Translation *> *)fetchRequest;

@property (nullable, nonatomic, copy) NSString *translated;
@property (nullable, nonatomic, copy) NSString *word;

@end

NS_ASSUME_NONNULL_END
