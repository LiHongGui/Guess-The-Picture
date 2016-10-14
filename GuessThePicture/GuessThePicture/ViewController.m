//
//  ViewController.m
//  GuessThePicture
//
//  Created by MichaelLi on 2016/10/9.
//  Copyright © 2016年 手持POS机. All rights reserved.
//

#import "ViewController.h"
#import "GuessModel.h"
//定义答案按钮的宽
#define kButtonWidth 48
@interface ViewController ()
//检索
@property (weak, nonatomic) IBOutlet UILabel *indexLabel;
//标题
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
//放大图片
@property (weak, nonatomic) IBOutlet UIButton *bigButton;
//提示
@property (weak, nonatomic) IBOutlet UIButton *tipButton;
//帮助
@property (weak, nonatomic) IBOutlet UIButton *helpButton;
//金币
@property (weak, nonatomic) IBOutlet UIButton *goldButton;
//下一题
@property (weak, nonatomic) IBOutlet UIButton *nextButton;
//答案
@property (weak, nonatomic) IBOutlet UIView *answerButton;
//选项
@property (weak, nonatomic) IBOutlet UIView *optionAnswer;
//图片
@property (weak, nonatomic) IBOutlet UIButton *imageButton;

@property(nonatomic,strong) NSArray *dataArray;

@property (weak, nonatomic) UIView*coverView;


//定义检索
@property(nonatomic,assign) NSInteger index;
@end

@implementation ViewController

#pragma mark
#pragma mark -  懒加载数据
-(NSArray *)dataArray
{
    if (nil==_dataArray) {


        //读取文件路径
        NSString *filePath = [[NSBundle mainBundle]pathForResource:@"questions.plist" ofType:nil];
        //读取内容到临时数组
        NSArray *temp = [NSArray arrayWithContentsOfFile:filePath];
        //创建可遍数组
        NSMutableArray *mutb = [NSMutableArray array];
        //遍历临时数组中的字典转换为模型,存放到可变数组中
        for (NSDictionary *dict in temp) {
            GuessModel *guessModel = [GuessModel guessModelWith:dict];


            //添加到可变数组中
            [mutb addObject:guessModel];
        }
        //赋值
        _dataArray = mutb;
    }
    return _dataArray;
}

- (void)viewDidLoad {
    [super viewDidLoad];


    //初始化coverView:只会运行一遍
    [self initWithCoverView];
    //初始化检索
    _index = 1;
    //设置UI界面
    [self setupUI];



//
//    NSArray *array = [NSArray arrayWithObjects:@"wendy",@"andy",@"tom",@"test", nil];
//    [array enumerateObjectsUsingBlock:^(id str,NSUInteger index, BOOL* te){
//        NSLog(@"%@,%lu",str,(unsigned long)index);
//    }];
}
-(void)initWithCoverView
{
    UIView *coverView = [[UIView alloc]initWithFrame:[UIScreen mainScreen].bounds];
    self.coverView = coverView;
    [coverView setBackgroundColor:[UIColor blackColor]];
    coverView.alpha = 0;
    [self.view addSubview:coverView];
}
#pragma mark
#pragma mark -  UI界面
-(void)setupUI
{
    /*
     Label
     */
    //数据在Model中 默认是从0开始的,前面定义_index= 1,所以要_index-1
    GuessModel *guessModel = self.dataArray[_index-1];
    //检索
    _indexLabel.text = [NSString stringWithFormat:@"%ld/%ld", _index,self.dataArray.count];
    //标题
    _titleLabel.text = guessModel.title;
    /*
     设置图片
     */
    NSString *imageNamed = guessModel.icon;
    [_imageButton setImage:[UIImage imageNamed:imageNamed] forState:UIControlStateNormal];
    /*
     设置答案
     */
    //获取答案
    NSString *answer = guessModel.answer;
    //答案长度
    NSInteger answerLength = answer.length;
    //修改后答案
    [self setAnswerWith:answerLength];

    /*
     设置选项区
     */
    [self setOptionWith:guessModel.options];
    //答案
    [self setAnswerUI];
    [self setOptionUI];
}
#pragma mark
#pragma mark -  答案区---修改后
-(void)setAnswerWith:(NSInteger)count
{
    /*
     设置答案区  答案区的的个数 和答案长度有关
     */

//    int answerCount = 5;
    //设置间距
    int answerButtonMargin = 20;
    int startX = (self.view.frame.size.width - count*kButtonWidth -(count-1)*answerButtonMargin)/2;
    //移除上一个答案---在for之前:点击for循环时,就要移除上一个答案
    //1. 让数组中所有元素都执行这个方法(比2好)
    [self.answerButton.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
    //2.
//    for (UIView *view in _answerButton.subviews) {
//        [view removeFromSuperview];
//    }
    for (int i = 0; i < count; i++) {
        //x位置
        CGFloat answerButtonX = answerButtonMargin*(i +1) + kButtonWidth*i +startX;
        UIButton *answerButton = [[UIButton alloc]initWithFrame:CGRectMake(answerButtonX, 0, kButtonWidth,kButtonWidth)];

        //图片及显示状态
        [answerButton setBackgroundImage:[UIImage imageNamed:@"btn_answer"] forState:UIControlStateNormal];
        [answerButton setBackgroundImage:[UIImage imageNamed:@"btn_answer_highlighted"] forState:UIControlStateHighlighted];
        [answerButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        answerButton.titleLabel.font = [UIFont systemFontOfSize:25];

        [_answerButton addSubview:answerButton];

        //添加点击事件
        [answerButton addTarget:self action:@selector(touchAnswerButton:) forControlEvents:UIControlEventTouchUpInside];
    }
    
}
#pragma mark
#pragma mark -  点击答案区文本
-(void)touchAnswerButton:(UIButton *)answerButton
{
    //如果点击没有文本的按钮,就不许要执行下面的代码(虽然现象看不到,但是也要考虑
    if (answerButton.currentTitle.length ==0) {
        return;
    }
    //获取点击的字体
    NSString *str = answerButton.currentTitle;
    //打印:点击无文本答案区,不会打印
//    NSLog(@"%@ %@",str,answerButton.currentTitle);
    //点击移除字体 直接赋值一个空字符串
    [answerButton setTitle:@"" forState:UIControlStateNormal];
    //选项区对应的文本显示出来---遍历21个字
    [_optionAnswer.subviews enumerateObjectsUsingBlock:^(__kindof UIView * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        UIButton *button = obj;
        if ([button.currentTitle isEqualToString:str]) {
            button.hidden = NO;
            *stop = YES;


        }
    }];
    //答案区文本颜色---黑色
    [_answerButton.subviews enumerateObjectsUsingBlock:^(__kindof UIView * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        UIButton *button = obj;
        [button setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        //打开用户交互
        _optionAnswer.userInteractionEnabled = YES;
    }];
}
#pragma mark
#pragma mark -  选项区---修改后
-(void)setOptionWith:(NSArray *)options
{
    int optionCount = 7;
    NSInteger optionNumber = options.count;
//    for (int j = 0; j < 21; j++) {
//        NSLog(@"row:%d column:%d",j/optionCount,j%optionCount);
//    }
    //设置间距
    CGFloat optionMargin = (self.view.frame.size.width -optionCount*kButtonWidth)/(optionCount +1);
    //    CGFloat optionMargin = 45;
    //移除上一题:不移处也会正常显示,但是上一题的选项是被现在所覆盖的,所以看不见
    [_optionAnswer.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
    for (int i = 0; i < optionNumber; i++) {
        //行数
        NSInteger row = i/optionCount;
        //列数
        NSInteger column = i%optionCount;
        //x位置
        CGFloat optionButtonX = optionMargin*(column+1) +kButtonWidth*column;
        //y位置
        CGFloat optionButtonY = optionMargin*(row+1) +kButtonWidth*row;
        UIButton *optionButton = [[UIButton alloc]initWithFrame:CGRectMake(optionButtonX, optionButtonY, kButtonWidth, kButtonWidth)];
        //图片及显示状态
        [optionButton setBackgroundImage:[UIImage imageNamed:@"btn_option"] forState:UIControlStateNormal];
        [optionButton setBackgroundImage:[UIImage imageNamed:@"btn_option_highlighted"] forState:UIControlStateHighlighted];
        //设置文本
        [optionButton setTitle:options[i] forState:UIControlStateNormal];
        [optionButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        optionButton.titleLabel.font = [UIFont systemFontOfSize:25];

        //添加点击按钮事件
        [optionButton addTarget:self action:@selector(touchOptionAnswer:) forControlEvents:UIControlEventTouchUpInside];
        [_optionAnswer addSubview:optionButton];
    }

}

-(void)touchOptionAnswer:(UIButton *)optionButton
{
    //取出被点击按钮的文字
//    NSString *optionText = optionButton.titleLabel.text;
    //currentTitle:当前字体的样式:字体 颜色 亮度
    NSString *optionText = optionButton.currentTitle;
    //隐藏选中的按钮
    optionButton.hidden = YES;
    //添加到答案区
    [_answerButton.subviews enumerateObjectsUsingBlock:^(__kindof UIView * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        UIButton *button = obj;
        if (button.currentTitle.length ==0) {
            [button setTitle:optionText forState:UIControlStateNormal];
            *stop = YES;
        }
    }];

    //判断用户是否输入完成---
    //定义输入完成
    __block BOOL isComplete =YES;

    [_answerButton.subviews enumerateObjectsUsingBlock:^(__kindof UIView * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        UIButton *button = obj;
        //等于0 还没有输入完,可以继续输入
        if (button.currentTitle.length ==0) {
            isComplete = NO;
            *stop = YES;
        }
    }];
    //输入完成后禁止用户交互
    if (isComplete) {
        _optionAnswer.userInteractionEnabled = NO;

        //在这里判断用户输入是否正确
        //定义可变字符串
        NSMutableString *mutb = [NSMutableString string];
        [_answerButton.subviews enumerateObjectsUsingBlock:^(__kindof UIView * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            UIButton *button = obj;
            //拼接字符串
            [mutb appendString:button.currentTitle];

        }];
        //取出正确答案
        GuessModel *guessModel = self.dataArray[_index-1];
        NSString *rightAnswer = guessModel.answer;
        //取出现在的金币
        NSInteger goldCount = self.goldButton.currentTitle.integerValue;
        if ([ rightAnswer isEqualToString:mutb]) {
            //输入正确进行下一题
            //1.
//            ++_index;
//            [self setupUI];
            //2.停顿一秒后进入下一题
            [self performSelector:@selector(nextButton:) withObject:nil afterDelay:1];

            //金币增加100
            goldCount += 100;

            //                self.goldButton.currentTitle.integerValue += 100;
//            NSLog(@"金币:%ld",self.goldButton.currentTitle.integerValue);//打印金币
        }else//输入错误
        {
            //金币减200
            goldCount -= 200;
                //判断金币数量
            if (goldCount < 0) {
                UIAlertController  *alertControler = [UIAlertController alertControllerWithTitle:@"请充值" message:@"金币不够" preferredStyle:UIAlertControllerStyleAlert];
                UIAlertAction *actionCancel = [UIAlertAction actionWithTitle:@"孙子我,没钱" style:UIAlertActionStyleCancel handler:nil];
                UIAlertAction *actionDestructive = [UIAlertAction actionWithTitle:@"爹,去了" style:UIAlertActionStyleDestructive handler:nil];
                [alertControler addAction:actionCancel];
                [alertControler addAction:actionDestructive];
                [self presentViewController:alertControler animated:YES completion:nil];
            return;
        }
            //字体变为红色 ---遍历答案区所有字体
            [_answerButton.subviews enumerateObjectsUsingBlock:^(__kindof UIView * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                UIButton *button = obj;
                [button setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
            }];
            //点击答案区后,字体消失,消失的字体回到选项区,可再次选择答案
        }
        //赋值回去
        //转换为字符串
        NSString *goldString = [NSString stringWithFormat:@"%ld",goldCount];
        [_goldButton setTitle:goldString forState:UIControlStateNormal];
//        NSLog(@"金币:%ld",self.goldButton.currentTitle.integerValue);//打印金币
    }

}
#pragma mark
#pragma mark -  点击图片
- (IBAction)imageButton:(UIButton *)sender {
    /*
     点击图片还原:需要拿到coverView 在不同方法中要使用同一个变量,需要定义一个@property
     */
    //点击放大/缩小---根据coverView.alpha来判断
    if (self.coverView.alpha == 0) {
        [self bigButton:nil];
    }else {

        [UIView animateWithDuration:0.5 animations:^{

            self.coverView.alpha = 0;
            _imageButton.transform = CGAffineTransformIdentity;
        }];
    }

}

#pragma mark
#pragma mark -  放大图片
- (IBAction)bigButton:(UIButton *)sender {
    /*
     1.添加一个遮盖View
     2.让图片放大
     3.点击放大的图片,图片还原
     */
    //1.
//    UIView *coverView = [[UIView alloc]initWithFrame:[UIScreen mainScreen].bounds];
//    self.coverView = coverView;
//    [coverView setBackgroundColor:[UIColor blackColor]];
//    coverView.alpha = 0;
//    [self.view addSubview:coverView];
    [UIView animateWithDuration:0.5 animations:^{
        _coverView.alpha = 0.5;
        _imageButton.transform = CGAffineTransformMakeScale(1.3,1.3);
    }];
    //2.
    //把图片放到遮盖View前面
    [self.view bringSubviewToFront:_imageButton];
}

#pragma mark
#pragma mark -  提示
- (IBAction)tipButton:(UIButton *)sender {
    //测试点击次数
//    self.tipButton.tag += 1;
//    NSLog(@"点击次数:%ld",self.tipButton.tag);
    //获取点击的文本
//    [self.tipButton addTarget:self action:@selector(touchAnswerButton:) forControlEvents:UIControlEventTouchUpInside];
//    NSString *str = self.answerButton.
    /*
     点击提示按钮后:
     1.取出正确答案的第一个字,清空答案区所有文本,正确答案第一个字显示在答案区
     2.清空的文本显示在选项区
     3.扣除500金币
     */
    // 1.取出正确答案的第一个字,清空答案区所有文本,正确答案第一个字显示在答案区
    GuessModel *guessModel = self.dataArray[_index -1];
    NSString *string = guessModel.answer;
    NSLog(@"正确答案:%@ 个数:%lu",string,(unsigned long)string.length);
    NSLog(@"%@",string);
    //抽取正确答案数组中的第一个字符
    NSString *str = [string substringWithRange:NSMakeRange(0, 1)];
    [_answerButton.subviews enumerateObjectsUsingBlock:^(__kindof UIView * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        UIButton *answerButton = obj;

        NSLog(@"idx:%lu  obj:%@",(unsigned long)idx,answerButton.currentTitle);

        if (idx ==0) {//是第一个的话,就赋值给它
            [answerButton setTitle:str forState:UIControlStateNormal];
            //这个设置字体颜色:如果提示后,输入错误,在次点击提示按钮,输入其余的答案,则其余的答案会显示红色,所以在再次遍历答案区(颜色)
//            [answerButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        } else {//清空其他的答案
            [answerButton setTitle:@"" forState:UIControlStateNormal];
        }
    }];

        [_answerButton.subviews enumerateObjectsUsingBlock:^(__kindof UIView * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            UIButton *button = obj;
            [button setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        }];
    //2.清空的文本显示在选项区

    [_optionAnswer.subviews enumerateObjectsUsingBlock:^(__kindof UIView * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        UIButton *optionButton = obj;
        if ([optionButton.currentTitle isEqualToString:str]) {
            optionButton.hidden = YES;
        }else{
            optionButton.hidden = NO;
        }


        _optionAnswer.userInteractionEnabled = YES;
    }];

    //3.扣除500金币
    //获取当前金币数
    NSInteger goldCount = self.goldButton.currentTitle.integerValue;
    //判断提示只可以点击一次
    if (self.tipButton.tag++ < 1){
        NSLog(@"点击次数:%ld",self.tipButton.tag);
        goldCount -= 1000;
    }
    //判断金币数量
    if (goldCount < 0) {
        UIAlertController  *alertControler = [UIAlertController alertControllerWithTitle:@"请充值" message:@"金币不够" preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *actionCancel = [UIAlertAction actionWithTitle:@"孙子我,没钱" style:UIAlertActionStyleCancel handler:nil];
        UIAlertAction *actionDestructive = [UIAlertAction actionWithTitle:@"爹,去了" style:UIAlertActionStyleDestructive handler:nil];
        [alertControler addAction:actionCancel];
        [alertControler addAction:actionDestructive];
        [self presentViewController:alertControler animated:YES completion:nil];

        //这个也能显示,
//        UIAlertView *alertView = [[UIAlertView alloc]initWithTitle:@"温馨提示" message:@"亲,你该去充值了" delegate:self cancelButtonTitle:@"孙子我,没钱" otherButtonTitles:@"爹,去了", nil];
//        [alertView show];
        return;
    }
    NSString *gold = [NSString stringWithFormat:@"%ld",goldCount];
    [self.goldButton setTitle:gold forState:UIControlStateNormal];

}
#pragma mark
#pragma mark -  下一题
- (IBAction)nextButton:(UIButton *)sender {
    //初始化tag(提示按钮可点)
    self.tipButton.tag = 0;
    NSLog(@"下一题:%ld",self.tipButton.tag);
    /*
     点击下一题:检索 标题 图片都要变
     */
    //判断 如果是最后一题的话,就return
    if (_index ==self.dataArray.count) {
        return;
    }
    ++_index;
    NSLog(@"_index:%ld",_index);
    //先++每次++后就与下面作比较
    self.nextButton.enabled = (_index != self.dataArray.count);
    _optionAnswer.userInteractionEnabled = YES;
    [self setupUI];


}
#pragma mark
#pragma mark -  答案区
-(void)setAnswerUI
{
//    /*
//     设置答案区
//     */
//    int answerCount = 5;
//    //设置间距
//    int answerButtonMargin = 20;
//    int startX = (self.view.frame.size.width - answerCount*kButtonWidth -(answerCount-1)*answerButtonMargin)/2;
//    for (int i = 0; i < answerCount; i++) {
//        //x位置
//        CGFloat answerButtonX = answerButtonMargin*(i +1) + kButtonWidth*i +startX;
//        UIButton *answerButton = [[UIButton alloc]initWithFrame:CGRectMake(answerButtonX, 0, kButtonWidth,kButtonWidth)];
//        //图片及显示状态
//        [answerButton setBackgroundImage:[UIImage imageNamed:@"btn_answer"] forState:UIControlStateNormal];
//        [answerButton setBackgroundImage:[UIImage imageNamed:@"btn_answer_highlighted"] forState:UIControlStateHighlighted];
//
//
//        [_answerButton addSubview:answerButton];
//
//    }
//
}
#pragma mark
#pragma mark -  选项区
-(void)setOptionUI
{
//    int optionCount = 7;
//    int optionNumber = 21;
//    for (int j = 0; j < 21; j++) {
//        NSLog(@"row:%d column:%d",j/optionCount,j%optionCount);
//    }
//    //设置间距
//    CGFloat optionMargin = (self.view.frame.size.width -optionCount*kButtonWidth)/(optionCount +1);
//    //    CGFloat optionMargin = 45;
//    for (int i = 0; i < optionNumber; i++) {
//        //行数
//        NSInteger row = i/optionCount;
//        //列数
//        NSInteger column = i%optionCount;
//        //x位置
//        CGFloat optionButtonX = optionMargin*(column+1) +kButtonWidth*column;
//        //y位置
//        CGFloat optionButtonY = optionMargin*(row+1) +kButtonWidth*row;
//        UIButton *optionButton = [[UIButton alloc]initWithFrame:CGRectMake(optionButtonX, optionButtonY, kButtonWidth, kButtonWidth)];
//        //图片及显示状态
//        [optionButton setBackgroundImage:[UIImage imageNamed:@"btn_option"] forState:UIControlStateNormal];
//        [optionButton setBackgroundImage:[UIImage imageNamed:@"btn_option_highlighted"] forState:UIControlStateHighlighted];
//        [_optionAnswer addSubview:optionButton];
//    }
}
#pragma mark
#pragma mark -  顶部状态栏显示样式
-(UIStatusBarStyle)preferredStatusBarStyle
{
    //白色
    return UIStatusBarStyleLightContent;
}
/*------修改状态栏的状态:显示白色------*/
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
