//
//  ASMainScene.cpp
//  Different
//
//  Created by qiyuezhen on 15-4-21.
//
//

#include "ASMainScene.h"
#include "ASNextScene.h"
#include "ASHead.h"
#include "BuyScene.h"
#if (CC_TARGET_PLATFORM == CC_PLATFORM_ANDROID) //判断当前是否为Android平台
#include "../../cocos2d/cocos/platform/android/jni/JniHelper.h"
#endif
USING_NS_CC;
using namespace std;
Scene* ASMainScene::createScene()
{
    // 'scene' is an autorelease object
    auto scene = Scene::create();
    
    // 'layer' is an autorelease object
    auto layer = ASMainScene::create();
    
    // add layer as a child to scene
    scene->addChild(layer);
    
    // return the scene
    return scene;
}

// on "init" you need to initialize your instance
bool ASMainScene::init()
{
    //////////////////////////////
    // 1. super init first
    if ( !Layer::init() )
    {
        return false;
    }
    
    Size visibleSize = Director::getInstance()->getVisibleSize();
    Vec2 origin = Director::getInstance()->getVisibleOrigin();
    
    log("th e screnn %f,%f",visibleSize.width,visibleSize.height);
    
    
    //添加最上层的图片背景
    Sprite *bgUp=Sprite::create("bgUp.png");
    bgUp->setPosition(Vec2(0, visibleSize.height));
    bgUp->setAnchorPoint(Vec2(0, 1));
    this->addChild(bgUp,-1);
    
    
    
    
    //获取总成绩进行显示
    totalScore=0;
    //totalScore=UserDefault::getInstance()->getIntegerForKey(SCORE);
    
    
    scoreLabel=Label::create();
    scoreLabel->setPosition(Vec2(visibleSize.width-130, visibleSize.height-30));
    scoreLabel->setString("成绩:");
    scoreLabel->setSystemFontSize(30);
    this->addChild(scoreLabel);
    
    score=0;
    string scoreString=StringUtils::format("%d",totalScore);
    totalLabe=Label::create();
    totalLabe->setPosition(Vec2(visibleSize.width-70, visibleSize.height-30));
    totalLabe->setString(scoreString);
    totalLabe->setSystemFontSize(30);
    this->addChild(totalLabe);
    
    countNum=0;  //开始时找到的个数为0
    
    
    //设置图片缩放系数 高度缩放
    ratioY=visibleSize.height/860.0;
    log("the ratioYn is %f",ratioY);
    
    //加载文件的格式化数字
    //随机数
    /*srand(time(0));
    int  random=rand()%10;
     */
    //按顺序出现
    int  random=UserDefault::getInstance()->getIntegerForKey(LEVEL);
    if(random>=10)
    {
        random=0;
        UserDefault::getInstance()->setIntegerForKey(LEVEL, 0);
    }
    log("the random is %d",random);
    string randomImage1=StringUtils::format("%d_1.jpg",random);
    string randomImage2=StringUtils::format("%d_2.jpg",random);
    
    
    auto down=Sprite::create(randomImage1);
    down->setScaleY(ratioY);
    down->setPosition(Vec2(0, 0));
    down->setAnchorPoint(Vec2::ZERO);
    this->addChild(down);

    float Height=400*ratioY;
    //中间的分割线
    auto divide=Sprite::create("divide.png");
    divide->setPosition(Vec2(0, Height));
    divide->setAnchorPoint(Vec2::ZERO);
    this->addChild(divide);

    
    //得打下面图片缩放以后的高度
    auto up=Sprite::create(randomImage2);
    up->setScaleY(ratioY);
    up->setAnchorPoint(Vec2::ZERO);
    up->setPosition(Vec2(0, Height+20));
    this->addChild(up);
    

    //时间精灵
    auto  time=Sprite::create("progress_bg.png");
    time->setScale(0.8);
    time->setScaleX(1.1);
    time->setPosition(Vec2(200, visibleSize.height-30));
    this->addChild(time);
    
    //进度条
    loadingBar = ui::LoadingBar::create("progress.png");
    loadingBar->setScale(0.8);
    loadingBar->setScaleX(1.1);
    loadingBar->setTag(0);
    loadingBar->setScale9Enabled(false);
    loadingBar->setDirection(ui::LoadingBar::Direction::LEFT);
    loadingBar->setPosition(Vec2(200, visibleSize.height-30));
    this->addChild(loadingBar,10);
    //进度条的计数器
    _count = 100;
    //获取用户购买的时间数
    int  addTime=UserDefault::getInstance()->getIntegerForKey(ADDTIME);

    //获取等级
    int level=UserDefault::getInstance()->getIntegerForKey(LEVEL);
    float updateTime;
    if(level<2)
    {
        updateTime=(20.0+addTime)/100.0;
    }
    else if(level>=2&&level<4)
    {
        updateTime=(15.0+addTime)/100.0;
    }
    else if(level>=4&&level<6)
    {
        updateTime=(12.0+addTime)/100.0;
    }
    else if(level>=6)
    {
        updateTime=(10.0+addTime)/100.0;
    }
    
    //当从头0开始玩时，等级0为默认20秒走完，每次0.2秒调用一次
    log("the time is %f",updateTime);

    this->schedule(schedule_selector(ASMainScene::loadingbarUpdate),updateTime);
    

    
    
    
    //读取文件字符串
    auto pFileUtils=FileUtils::getInstance();
    string randomFile=StringUtils::format("%d.txt",random);
    std::string fullPathName=pFileUtils->fullPathForFilename(randomFile);
    readData(fullPathName);
    log("the size is %d",posInfo.size());
    
    
    //触摸事件
    listener=EventListenerTouchOneByOne::create();
    listener->onTouchBegan = CC_CALLBACK_2(ASMainScene::onTouchBegan, this);
    listener->onTouchMoved = CC_CALLBACK_2(ASMainScene::onTouchMoved, this);
    listener->onTouchEnded = CC_CALLBACK_2(ASMainScene::onTouchEnded, this);
    listener->setSwallowTouches(true);
    _eventDispatcher->addEventListenerWithSceneGraphPriority(listener, this);
    
    
    
    //对手机返回键的监听
    auto backKeyListener=EventListenerKeyboard::create();
    //和回调函数绑定
    backKeyListener->onKeyReleased=CC_CALLBACK_2(ASMainScene::onKeyReleased, this);
    Director::getInstance()->getEventDispatcher()->addEventListenerWithSceneGraphPriority(backKeyListener, this);
    
    
    
    return true;

}
void ASMainScene::onKeyReleased(EventKeyboard::KeyCode keyCode,Event* pEvent)
{
    log("Key_ESCAPE pressed");
    if (EventKeyboard::KeyCode::KEY_ESCAPE==keyCode) {
        showIfExitAlert(this);
    }
}
//退出层
void ASMainScene::showIfExitAlert(Ref* pSender)
{
    log("退出+++_______");
    #if (CC_TARGET_PLATFORM == CC_PLATFORM_ANDROID) //判断当前是否为Android平台
        JniMethodInfo method;
    
        //静态函数示例1.无参数，无返回值
        bool b=JniHelper::getStaticMethodInfo(method,"org/cocos2dx/cpp/AppActivity","exitGameStatic","()V");
    
        if (b)
        {
            log("退出---------------");
            method.env->CallStaticVoidMethod(method.classID,method.methodID);
            return;
        }
    #endif

}
void ASMainScene::readData(string myString)
{
     auto pFileUtils=FileUtils::getInstance();
    std::string content=pFileUtils->getStringFromFile(myString);
    char s[200];
    strcpy(s, content.c_str());
    const char *d = ",";
    char *p;
    p = strtok(s,d);
    //将字符串分割成数字，插入到向量中
    //一个x值，一个y值存放
    while(p)
    {
        string str=StringUtils::format("%s",p);
        int item=std::atoi(str.c_str());
        posInfo.push_back(item);
        
        p=strtok(NULL,d);
    }
    //将y值缩放比例系数
    for(int i=0;i<posInfo.size();i++)
    {
        if(i%2==1)
        {
            posInfo.at(i)=posInfo.at(i)*ratioY;
        }
    }
    //将左上角的图像坐标系转换为左下角的opengl坐标系
    //x值不变，y值相应的为图片高度减去y
    for(int i=0;i<posInfo.size();i++)
    {
        if(i%2==1)
        {
            posInfo.at(i)=400*ratioY-posInfo.at(i);
        }
    }
    
    
}
void ASMainScene::loadingbarUpdate(float delta)
{
    _count--;
    
    if (_count  <0)
    {
        //去除触摸监听事件
        Director::getInstance()->getEventDispatcher()->removeEventListener(listener);
        //当进度条走到头，弹框消失
        //log("结束了");
        
        for(int i=0;i<posInfo.size()-1;i+=2)
        {
            auto call1=CallFunc::create([this,i]()
            {
                int x=posInfo.at(i);
                int y=posInfo.at(i+1);
                auto sp=Sprite::create("72.png");
                sp->setPosition(Vec2(x, y));
                this->addChild(sp,20);
                auto sp2=Sprite::create("72.png");
                sp2->setPosition(Vec2(x, y+400*ratioY+20));
                this->addChild(sp2,20);
               
                
            });
            auto seq=Sequence::create(call1, NULL);
            
            this->runAction(seq);


        }
        auto call2=CallFunc::create([this]()
                                    {
                                        
                                        //succeedNext();
                                        auto buyScene=BuyScene::createScene();
                                        Director::getInstance()->pushScene(buyScene);
                                    });
        UserDefault::getInstance()->setBoolForKey(ISGAMEOVER, true);
        auto seq2=Sequence::create(DelayTime::create(0.5),call2, NULL);
        this->runAction(seq2);
        
        
        
        
    }
    loadingBar->setPercent(_count);
    
}
/*
 x1 ,y1 点
 x2,y2矩形点   w快  h 高
 */
bool ASMainScene::isCollsion(int x1, int y1)
{
    int  distanceY=400*ratioY+20;
    for(int i=0;i<posInfo.size()-1;i+=2)
    {
        int x=posInfo.at(i);
        int y=posInfo.at(i+1);
        bool flag=false;   //判断是否在区域内的标示
        if(y1>distanceY)
        {
            if((x1>=x-25)&&(x1<=x+25)&&(y1>=y-45+distanceY)&&(y1<=y+45+distanceY))
            {
                log("哈哈哈。碰到了");
                auto sp=Sprite::create("green72.png");
                sp->setPosition(Vec2(x, y));
                this->addChild(sp);
                
                auto sp2=Sprite::create("green72.png");
                sp2->setPosition(Vec2(x, y+distanceY));
                this->addChild(sp2);
                
                //修改成绩
                totalScore++;
                string scoreString=StringUtils::format("%d",totalScore*100);
                totalLabe->setString(scoreString);
                
                countNum++;
                flag=true;
            }
        }
        else if(y1<distanceY)
        {
            if((x1>=x-25)&&(x1<=x+25)&&(y1>=y-45)&&(y1<=y+45))
            {
                log("哈哈哈。碰到了");
                auto sp=Sprite::create("green72.png");
                sp->setPosition(Vec2(x, y));
                this->addChild(sp);
                
                auto sp2=Sprite::create("green72.png");
                sp2->setPosition(Vec2(x, y+distanceY));
                this->addChild(sp2);
                //修改成绩
                totalScore++;
                string scoreString=StringUtils::format("%d",totalScore*100);
                totalLabe->setString(scoreString);
                countNum++;
                flag=true;
            }
        }
        if(flag==true)
        {
            log("the i %d",i);
            vector <int>::iterator position=posInfo.begin()+i;
            posInfo.erase(position+1);
            posInfo.erase(position);
            
            //判断是否全找到
            if(countNum==5)
            {
                UserDefault::getInstance()->setIntegerForKey(SCORE, totalScore);
//                int level=UserDefault::getInstance()->getIntegerForKey(LEVEL);
//                UserDefault::getInstance()->setIntegerForKey(LEVEL, level+1);
                UserDefault::getInstance()->setBoolForKey(ISGAMEOVER, false);
                //自定义动作
                
                
                auto call1=CallFunc::create([this]()
                {
                   succeedNext();
                    
                });
                auto seq=Sequence::create(DelayTime::create(0.5),call1, NULL);
                
                this->runAction(seq);
                
                
                
            }
            
            
            
//            //当向量中元素为空时，返回
//            if(posInfo.size()==0)
//            {
//                return true;
//            }
            i=i-2;
            return true;
            
        }
        
        
    }
    
    
    return false;
}
void ASMainScene::succeedNext(void)
{
    //设置分数
    UserDefault::getInstance()->setIntegerForKey(SCORE, totalScore);
    //创建CCRenderTexture，纹理画布大小为窗口大小(480,320)
    Size visibleSize=Director::getInstance()->getVisibleSize();
	RenderTexture *renderTexture = RenderTexture::create(visibleSize.width,visibleSize.height);
    
	//遍历Game类的所有子节点信息，画入renderTexture中。
	//这里类似截图。
	renderTexture->begin();
	this->getParent()->visit();
	renderTexture->end();
	
	//将游戏界面暂停，压入场景堆栈。并切换到GamePause界面
    auto scene=ASNextScene::createScene(renderTexture);
    
    
    
	//将游戏界面暂停，压入场景堆栈。并切换到GamePause界面
    Director::getInstance()->pushScene(scene);
}
bool ASMainScene::onTouchBegan(Touch *touch, cocos2d::Event *unused_event)
{
    float x=touch->getLocation().x;
    float y=touch->getLocation().y;
//    log("the x   y  is %f,%f",x,y);
    //当向量中有元素时
    if(posInfo.size()>0)
    {
        bool isTrue=isCollsion(x,y);
        if(isTrue== false)
        {
            
             _count=_count-3;
        }
    }

   
    
    return true;
}
void ASMainScene::onTouchMoved(Touch *touch, Event *unused_event)
{
    
}
void ASMainScene::onTouchEnded(Touch *touch, Event *unused_event)
{
    
}
