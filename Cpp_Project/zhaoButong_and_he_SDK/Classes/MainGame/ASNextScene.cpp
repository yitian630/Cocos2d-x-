//
//  ASNextScene.cpp
//  Different
//
//  Created by qiyuezhen on 15-4-23.
//
//

#include "ASNextScene.h"
#include "ASMainScene.h"
#include "ASStartGame.h"
#include "ASHead.h"
#if (CC_TARGET_PLATFORM == CC_PLATFORM_ANDROID) //判断当前是否为Android平台
#include "../../cocos2d/cocos/platform/android/jni/JniHelper.h"
#endif
USING_NS_CC;
using namespace std;
Scene* ASNextScene::createScene(RenderTexture* sqr)
{
    Size visibleSize=Director::getInstance()->getVisibleSize();
    
    Scene *myscene = Scene::create();
    ASNextScene* mylayer = ASNextScene::create();
    
    
    //增加部分：使用Game界面中截图的sqr纹理图片创建Sprite
    //并将Sprite添加到GamePause场景层中
    Sprite *_spr = Sprite::createWithTexture(sqr->getSprite()->getTexture());
    
    _spr->setPosition(Point(visibleSize.width/2.0,visibleSize.height/2.0));
    //窗口大小(480,320)，这个相对于中心位置。
    _spr->setFlippedY(true);
    //_spr->setFlipY(true);            //翻转，因为UI坐标和OpenGL坐标不同
    //Director::getInstance()->setop
    _spr->setColor(Color3B::GRAY); //图片颜色变灰色
    myscene->addChild(_spr);
    myscene->addChild(mylayer);
    
    return myscene;
    
}

// on "init" you need to initialize your instance
bool ASNextScene::init()
{
    //////////////////////////////
    // 1. super init first
    if ( !Layer::init() )
    {
        return false;
    }
    
    Size visibleSize = Director::getInstance()->getVisibleSize();
    Vec2 origin = Director::getInstance()->getVisibleOrigin();
    bool isGameOver=UserDefault::getInstance()->getBoolForKey(ISGAMEOVER);
    if (isGameOver)
    {
        Sprite *letter=Sprite::create("gameover.png");
        
        
        letter->setPosition(Point(visibleSize.width/2,visibleSize.height/2.0+100));
        
        this->addChild(letter,20);
        
        int score=UserDefault::getInstance()->getIntegerForKey(SCORE);
        string scoreString=StringUtils::format("%d",score*100);
        Label * totalLabe=Label::create();
        totalLabe->setPosition(Vec2(250,250));
        totalLabe->setString(scoreString);
        totalLabe->setSystemFontSize(40);
        letter->addChild(totalLabe);
    }
    
    auto nextItem = MenuItemImage::create(
                                          "button_continue.png",
                                          "button_continue2.png",
                                          CC_CALLBACK_1(ASNextScene::startCallback, this));
    
	nextItem->setPosition(Vec2(visibleSize.width/2.0+200,300));
    auto menuItem = MenuItemImage::create(
                                          "button_menu.png",
                                          "button_menu2.png",
                                         CC_CALLBACK_1(ASNextScene::menuCallback, this));
    
	menuItem->setPosition(Vec2(visibleSize.width/2.0-200,300));
    
    // create menu, it's an autorelease object
    auto menu = Menu::create(nextItem,menuItem, NULL);
    menu->setPosition(Vec2::ZERO);
    this->addChild(menu, 1);
    
   
    //对手机返回键的监听
    auto backKeyListener=EventListenerKeyboard::create();
    //和回调函数绑定
    backKeyListener->onKeyReleased=CC_CALLBACK_2(ASNextScene::onKeyReleased, this);
    Director::getInstance()->getEventDispatcher()->addEventListenerWithSceneGraphPriority(backKeyListener, this);

    
    return true;
    
}
void ASNextScene::startCallback(cocos2d::Ref* pSender)
{
    log("我执行了啊");
    bool isGameOver=UserDefault::getInstance()->getBoolForKey(ISGAMEOVER);
    //游戏失败
    if(isGameOver)
    {
        auto startScene=ASStartGame::createScene();
        Director::getInstance()->replaceScene(startScene);
       
    }
    else
    {
        //让等级提高
        int level=UserDefault::getInstance()->getIntegerForKey(LEVEL);
        UserDefault::getInstance()->setIntegerForKey(LEVEL, level+1);
        auto nextScene=ASMainScene::createScene();
        Director::getInstance()->replaceScene(nextScene);
    }
    
    
    
}
void ASNextScene::menuCallback(cocos2d::Ref* pSender)
{
    bool isGameOver=UserDefault::getInstance()->getBoolForKey(ISGAMEOVER);
    //游戏失败
    if(isGameOver)
    {
        auto startScene=ASStartGame::createScene();
        Director::getInstance()->replaceScene(startScene);
        
    }
    else
    {
        //让等级提高
        int level=UserDefault::getInstance()->getIntegerForKey(LEVEL);
        UserDefault::getInstance()->setIntegerForKey(LEVEL, level+1);
        auto nextScene=ASMainScene::createScene();
        Director::getInstance()->replaceScene(nextScene);
    }
}
void ASNextScene::onKeyReleased(EventKeyboard::KeyCode keyCode,Event* pEvent)
{
    log("Key_ESCAPE pressed");
    if (EventKeyboard::KeyCode::KEY_ESCAPE==keyCode) {
        showIfExitAlert(this);
    }
}
//退出层
void ASNextScene::showIfExitAlert(Ref* pSender)
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
