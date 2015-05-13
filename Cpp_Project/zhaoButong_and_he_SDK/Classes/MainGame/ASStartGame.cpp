//
//  ASStartGame.cpp
//  Different
//
//  Created by qiyuezhen on 15-4-22.
//
//

#include "ASStartGame.h"
#include "ASMainScene.h"
#include "ASHead.h"
#if (CC_TARGET_PLATFORM == CC_PLATFORM_ANDROID) //判断当前是否为Android平台
#include "../../cocos2d/cocos/platform/android/jni/JniHelper.h"
#endif
USING_NS_CC;

Scene* ASStartGame::createScene()
{
    // 'scene' is an autorelease object
    auto scene = Scene::create();
    
    // 'layer' is an autorelease object
    auto layer = ASStartGame::create();
    
    // add layer as a child to scene
    scene->addChild(layer);
    
    // return the scene
    return scene;
}

// on "init" you need to initialize your instance
bool ASStartGame::init()
{
    //////////////////////////////
    // 1. super init first
    if ( !Layer::init() )
    {
        return false;
    }
    
    UserDefault::getInstance()->setIntegerForKey(SCORE, 0);
    UserDefault::getInstance()->setIntegerForKey(LEVEL, 0);
    
    //判断是否是第一次安装
    int first=UserDefault::getInstance()->getIntegerForKey(FISTINSTALL,0);
    if(first==0)
    {
        UserDefault::getInstance()->setIntegerForKey(ADDTIME, 0);
        UserDefault::getInstance()->setIntegerForKey(FISTINSTALL, 1);
    }
    log("teh time install is %d",first);
    
    
    

    
    
    
    
    Size visibleSize = Director::getInstance()->getVisibleSize();
    Vec2 origin = Director::getInstance()->getVisibleOrigin();
    float ratioY=visibleSize.height/1136.0;
    
    
    auto  bg=Sprite::create("bg_start.png");
    bg->setPosition(Vec2(0, 0));
    bg->setScaleY(ratioY);
    bg->setAnchorPoint(Vec2::ZERO);
    this->addChild(bg);
    
    
    
    
    
    
    auto startItem = MenuItemImage::create(
                                           "button_play.png",
                                           "button_play2.png",
                                           CC_CALLBACK_1(ASStartGame::startCallback, this));
    
	startItem->setPosition(Vec2(visibleSize.width/2.0,visibleSize.height/2.0-200));
    // create menu, it's an autorelease object
    auto menu = Menu::create(startItem, NULL);
    menu->setPosition(Vec2::ZERO);
    this->addChild(menu, 1);
    //
    
   //对手机返回键的监听
       auto backKeyListener=EventListenerKeyboard::create();
       //和回调函数绑定
       backKeyListener->onKeyReleased=CC_CALLBACK_2(ASStartGame::onKeyReleased, this);
       Director::getInstance()->getEventDispatcher()->addEventListenerWithSceneGraphPriority(backKeyListener, this);

    
    
    return true;
}

void ASStartGame::startCallback(cocos2d::Ref* pSender)
{
    
    auto mainScene=ASMainScene::createScene();
    auto director = Director::getInstance();
    director->replaceScene(mainScene);
}
void ASStartGame::onKeyReleased(EventKeyboard::KeyCode keyCode,Event* pEvent)
{
    log("Key_ESCAPE pressed");
    if (EventKeyboard::KeyCode::KEY_ESCAPE==keyCode) {
        showIfExitAlert(this);
    }
}
//退出层
void ASStartGame::showIfExitAlert(Ref* pSender)
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
