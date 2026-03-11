//
//  SearchEngineBridge.h
//  ClipMind
//
//  Created by HappyQi on 2026/3/11.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface SearchEngineBridge : NSObject

- (NSArray<NSString *> *)searchWithQuery:(NSString *)query;
- (NSArray<NSString *> *)allItems;
- (void)addItemWithId:(NSString *)identifier source:(NSString *)source text:(NSString *)text;

@end

NS_ASSUME_NONNULL_END
