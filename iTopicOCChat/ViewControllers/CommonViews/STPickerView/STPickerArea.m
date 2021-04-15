//
//  STPickerArea.m
//  STPickerView
//
//  Created by https://github.com/STShenZhaoliang/STPickerView on 16/2/15.
//  Copyright © 2016年 shentian. All rights reserved.
//

#import "STPickerArea.h"

@interface STPickerArea()<UIPickerViewDataSource, UIPickerViewDelegate>


/** 2.当前省数组 */
//@property (nonatomic, strong, nullable)NSMutableArray<NSDictionary *> *arrayProvince;
///** 3.当前城市数组 */
//@property (nonatomic, strong, nullable)NSMutableArray<NSDictionary *> *arrayCity;
///** 4.当前地区数组 */
//@property (nonatomic, strong, nullable)NSMutableArray<NSDictionary *> *arrayArea;
/** 5.当前选中数组 */
//@property (nonatomic, strong, nullable)NSMutableArray<NSDictionary *> *arraySelected;

@property (nonatomic, assign)int currentProvinceIndex;
@property (nonatomic, assign)int currentCityIndex;
@property (nonatomic, assign)int currentAreaIndex;

///** 6.省份 */
//@property (nonatomic, strong, nullable)NSDictionary *provinceDictionary;
///** 7.城市 */
//@property (nonatomic, strong, nullable)NSDictionary *cityDictionary;
///** 8.地区 */
//@property (nonatomic, strong, nullable)NSDictionary *areaDictionary;

@end

@implementation STPickerArea

#pragma mark - --- init 视图初始化 ---

- (void)setupUI
{
    // 1.获取数据
//    [self.arrayRoot enumerateObjectsUsingBlock:^(NSDictionary *obj, NSUInteger idx, BOOL * _Nonnull stop) {
//        [self.arrayProvince addObject:obj[@"state"]];
//    }];
//
//    NSMutableArray *citys = [NSMutableArray arrayWithArray:[self.arrayRoot firstObject][@"cities"]];
//    [citys enumerateObjectsUsingBlock:^(NSDictionary *obj, NSUInteger idx, BOOL * _Nonnull stop) {
//        [self.arrayCity addObject:obj[@"city"]];
//    }];
//
//    self.arrayArea = [citys firstObject][@"area"];

//    self.province = self.arrayProvince[0];
//    self.city = self.arrayCity[0];
//    if (self.arrayArea.count != 0) {
//        self.area = self.arrayArea[0];
//    }else{
//        self.area = @"";
//    }
    self.saveHistory = NO;
    
    // 2.设置视图的默认属性
    _heightPickerComponent = 40;
    [self setTitle:@"选择地区"];
    [self.pickerView setDelegate:self];
    [self.pickerView setDataSource:self];
}

#pragma mark - --- delegate 视图委托 ---

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
    return 3;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
    if (component == 0) {
        return self.arrayRoot.count;
    } else if (component == 1) {
        NSArray *cityArray = self.arrayRoot[_currentProvinceIndex][@"items"];
        return cityArray.count;
    } else {
        NSArray *cityArray = self.arrayRoot[_currentProvinceIndex][@"items"];
        NSArray *areaArray = cityArray[_currentCityIndex][@"items"];
        return areaArray.count;
    }
}

- (CGFloat)pickerView:(UIPickerView *)pickerView rowHeightForComponent:(NSInteger)component
{
    return self.heightPickerComponent;
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component
{
    if (component == 0) {
        self.currentProvinceIndex = (int)row;
        self.currentCityIndex = 0;
        self.currentAreaIndex = 0;
//        self.arraySelected = self.arrayRoot[row][@"cities"];
//
//        [self.arrayCity removeAllObjects];
//        [self.arraySelected enumerateObjectsUsingBlock:^(NSDictionary *obj, NSUInteger idx, BOOL * _Nonnull stop) {
//            [self.arrayCity addObject:obj[@"city"]];
//        }];
//
//        self.arrayArea = [NSMutableArray arrayWithArray:[self.arraySelected firstObject][@"areas"]];

        [pickerView reloadComponent:1];
        [pickerView reloadComponent:2];
        [pickerView selectRow:0 inComponent:1 animated:YES];
        [pickerView selectRow:0 inComponent:2 animated:YES];

    } else if (component == 1) {
        self.currentCityIndex = (int)row;
        self.currentAreaIndex = 0;
//        if (self.arraySelected.count == 0) {
//            self.arraySelected = [self.arrayRoot firstObject][@"cities"];
//        }
//
//        self.arrayArea = [NSMutableArray arrayWithArray:[self.arraySelected objectAtIndex:row][@"areas"]];

        [pickerView reloadComponent:2];
        [pickerView selectRow:0 inComponent:2 animated:YES];

    } else {
        self.currentAreaIndex = (int)row;
    }

    [self reloadData];
}

- (UIView *)pickerView:(UIPickerView *)pickerView viewForRow:(NSInteger)row forComponent:(NSInteger)component reusingView:(nullable UIView *)view
{

    //设置分割线的颜色
    [pickerView.subviews enumerateObjectsUsingBlock:^(__kindof UIView * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if (obj.frame.size.height <=1) {
            obj.backgroundColor = self.borderButtonColor;
        }
    }];
    
    
    NSString *text;
    if (component == 0) {
        text = self.arrayRoot[row][@"name"];
    } else if (component == 1) {
        NSArray *cityArray = self.arrayRoot[_currentProvinceIndex][@"items"];
        text = cityArray[row][@"name"];
       
    } else {
        NSArray *cityArray = self.arrayRoot[_currentProvinceIndex][@"items"];
        NSArray *areaArray = cityArray[_currentCityIndex][@"items"];
        text = areaArray[row][@"name"];
    }

    UILabel *label = [[UILabel alloc]init];
    [label setTextAlignment:NSTextAlignmentCenter];
    [label setFont:[UIFont systemFontOfSize:19]];
    [label setText:text];
    label.textColor = [UIColor blackColor];
    return label;
}

#pragma mark - --- event response 事件相应 ---
- (void)selectedOk
{
    NSDictionary *tempProvinceDictionary = self.arrayRoot[_currentProvinceIndex];
    NSDictionary *tempCityDictionary = tempProvinceDictionary[@"items"][_currentCityIndex];
    
    NSDictionary *areaDictionary = nil;
    NSArray *areaArray = tempCityDictionary[@"items"];
    if (areaArray.count > 0) {
        areaDictionary = tempCityDictionary[@"items"][_currentAreaIndex];
    }

    [self.delegate pickerArea:self province:@{@"name":tempProvinceDictionary[@"name"],@"code":tempProvinceDictionary[@"code"]} city:@{@"name":tempCityDictionary[@"name"],@"code":tempCityDictionary[@"code"]} area:areaDictionary?@{@"name":areaDictionary[@"name"],@"code":areaDictionary[@"code"]}:nil];
    
    [super selectedOk];
}

#pragma mark - --- private methods 私有方法 ---

- (void)reloadData
{
//    NSInteger index0 = [self.pickerView selectedRowInComponent:0];
//    NSInteger index1 = [self.pickerView selectedRowInComponent:1];
//    NSInteger index2 = [self.pickerView selectedRowInComponent:2];
    
    
//    NSString *text;
//    if (component == 0) {
//        text = self.arrayRoot[row][@"name"];
//    } else if (component == 1) {
//        NSArray *cityArray = self.arrayRoot[_currentProvinceIndex][@"items"];
//        text = cityArray[row][@"name"];
//
//    } else {
//        NSArray *cityArray = self.arrayRoot[_currentProvinceIndex][@"items"];
//        NSArray *areaArray = cityArray[_currentCityIndex][@"items"];
//        text = areaArray[row][@"name"];
//    }
//
//    self.province = self.arrayProvince[index0];
//    self.city = self.arrayCity[index1];
//    if (self.arrayArea.count != 0) {
//        self.area = self.arrayArea[index2];
//    }else{
//        self.area = @"";
//    }
//
//    NSString *title = [NSString stringWithFormat:@"%@ %@ %@", self.province, self.city, self.area];
//    [self setTitle:title];

}

#pragma mark - --- setters 属性 ---

- (void)setSaveHistory:(BOOL)saveHistory{
//    _saveHistory = saveHistory;
//
//    if (saveHistory) {
//        NSDictionary *dicHistory = [[NSUserDefaults standardUserDefaults] dictionaryForKey:@"STPickerArea"];
//        __block NSUInteger numberProvince = 0;
//        __block NSUInteger numberCity = 0;
//        __block NSUInteger numberArea = 0;
//
//        if (dicHistory) {
//            NSString *province = [NSString stringWithFormat:@"%@", dicHistory[@"province"]];
//            NSString *city = [NSString stringWithFormat:@"%@", dicHistory[@"city"]];
//            NSString *area = [NSString stringWithFormat:@"%@", dicHistory[@"area"]];
//
//            [self.arrayProvince enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
//                if ([obj isEqualToString:province]) {
//                    numberProvince = idx;
//                }
//            }];
//
//            self.arraySelected = self.arrayRoot[numberProvince][@"cities"];
//
//            [self.arrayCity removeAllObjects];
//            [self.arraySelected enumerateObjectsUsingBlock:^(NSDictionary *obj, NSUInteger idx, BOOL * _Nonnull stop) {
//                [self.arrayCity addObject:obj[@"city"]];
//            }];
//
//            [self.arrayCity enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
//                if ([obj isEqualToString:city]) {
//                    numberCity = idx;
//                }
//            }];
//
//
//            if (self.arraySelected.count == 0) {
//                self.arraySelected = [self.arrayRoot firstObject][@"cities"];
//            }
//
//            self.arrayArea = [NSMutableArray arrayWithArray:[self.arraySelected objectAtIndex:numberCity][@"areas"]];
//
//            [self.arrayArea enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
//                if ([obj isEqualToString:area]) {
//                    numberArea = idx;
//                }
//            }];
//
//            [self.pickerView selectRow:numberProvince inComponent:0 animated:NO];
//            [self.pickerView selectRow:numberCity inComponent:1 animated:NO];
//            [self.pickerView selectRow:numberArea inComponent:2 animated:NO];
//            [self.pickerView reloadAllComponents];
//            [self reloadData];
//        }
//    }
}


@end


