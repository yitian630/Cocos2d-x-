//
//  BuyScene.cpp
//  ZhaoBuTong
//
//  Created by qiyuezhen on 15-5-11.
//
//

#include "BuyScene.h"
#include "ASStartGame.h"
#include "ASMainScene.h"
#include "ASHead.h"
#if (CC_TARGET_PLATFORM == CC_PLATFORM_ANDROID) //判断当前是否为Android平台
#include "../../cocos2d/cocos/platform/android/jni/JniHelper.h"
#endif

USING_NS_CC;
//本地指针
static BuyScene* buyLayer = NULL;
Scene* BuyScene::createScene()
{
    // 'scene' is an autorelease object
    auto scene = Scene::create();
    
    // 'layer' is an autorelease object
    auto layer = BuyScene::create();
    //初始化
    buyLayer = layer;
    // add layer as a child to scene
    scene->addChild(layer);
    
    // return the scene
    return scene;
}

// on "init" you need to initialize your instance
bool BuyScene::init()
{
    //////////////////////////////
    // 1. super init first
    if ( !Layer::init() )
    {
        return false;
    }
    
    Size visibleSize = Director::getInstance()->getVisibleSize();
    //10个背景
    for(int i=0;i<=10;i++)
    {
        //添加label  字符串
        auto bgSprite=Sprite::create("cell_bg.png");
        Label *strLabel=Label::createWithSystemFont("", "宋体", 30);
        Label *numLabel=Label::createWithSystemFont("", "宋体", 30);
        if(i==0)
        {
            strLabel->setString("70秒钟");
            numLabel->setString("2000点");
        }
        else if(i==1)
        {
            strLabel->setString("50秒钟");
            numLabel->setString("1500点");
        }
        else if(i==2)
        {
            strLabel->setString("30秒钟");
            numLabel->setString("1000点");
        }
        else if(i==3)
        {
            strLabel->setString("24秒钟");
            numLabel->setString("800点");
        }
        else if(i==4)
        {
            strLabel->setString("18秒钟");
            numLabel->setString("600点");
        }
        else if(i==5)
        {
            strLabel->setString("14秒钟");
            numLabel->setString("500点");
        }
        else if(i==6)
        {
            strLabel->setString("11秒钟");
            numLabel->setString("400点");
        }
        else if(i==7)
        {
            strLabel->setString("5秒钟");
            numLabel->setString("200点");
        }
        else if(i==8)
        {
            strLabel->setString("2.4秒钟");
            numLabel->setString("100点");
        }
        else if(i==9)
        {
            strLabel->setString("1秒钟");
            numLabel->setString("10点");
        }
        else if(i==10)
        {
        	numLabel->setString("1元=100点");
        }
        
        strLabel->setColor(Color3B::RED);
        strLabel->setPosition(Vec2(60, 40));
        bgSprite->addChild(strLabel,10);

        numLabel->setColor(Color3B::RED);
        numLabel->setPosition(Vec2(300, 40));
        bgSprite->addChild(numLabel,10);

        bgSprite->setPosition(Vec2(visibleSize.width/2.0, i*82+140));
        this->addChild(bgSprite);
    }
    
    Vector<MenuItemImage*> ButtonItems;
    //10个购买按钮,从上到下标签依为1，2，3.
    for(int i=0;i<10;i++)
    {
        auto buyItem = MenuItemImage::create(
                                          "buy.png",
                                          "buy_press.png",
                                          CC_CALLBACK_1(BuyScene::buyCall, this));
        
        buyItem->setPosition(Vec2(visibleSize.width-80,i*82+140));
        buyItem->setTag(10-i);
        ButtonItems.pushBack(buyItem);
    }
    
  
    auto back = MenuItemImage::create(
                                          "back.png",
                                          "back_press.png",
                                          CC_CALLBACK_1(BuyScene::backCall, this));
    
	back->setPosition(Vec2(visibleSize.width/2.0,50));
    auto menu = Menu::create(back,ButtonItems.at(0),ButtonItems.at(1),ButtonItems.at(2),ButtonItems.at(3),ButtonItems.at(4),ButtonItems.at(5),ButtonItems.at(6),ButtonItems.at(7),ButtonItems.at(8),ButtonItems.at(9), NULL);
    
    menu->setPosition(Vec2::ZERO);
    this->addChild(menu, 1);
    
    
    
    //对手机返回键的监听
    auto backKeyListener=EventListenerKeyboard::create();
    //和回调函数绑定
    backKeyListener->onKeyReleased=CC_CALLBACK_2(BuyScene::onKeyReleased, this);
    Director::getInstance()->getEventDispatcher()->addEventListenerWithSceneGraphPriority(backKeyListener, this);

    
    
    return true;
}
void BuyScene::backCall(cocos2d::Ref* pSender)
{
    auto scene=ASStartGame::createScene();
    Director::getInstance()->replaceScene(scene);
}
void BuyScene::buyCall(cocos2d::Ref* pSender)
{
    auto item=static_cast<MenuItem*>(pSender);
    int tag=item->getTag();
    
    log("the tag is %d",tag);

//    JniMethodInfo method;
//
//       //静态函数示例1.无参数，无返回值
//       bool b=JniHelper::getStaticMethodInfo(method,"org/cocos2dx/cpp/AppActivity","showBuy_Static","(I)V");
//
//       if (b)
//       {
//       	log("购买---------------");
//
//
//       	method.env->CallStaticVoidMethod(method.classID,method.methodID,tag);
//       	return;
//       }
    
    #if (CC_TARGET_PLATFORM == CC_PLATFORM_ANDROID) //判断当前是否为Android平台
        JniMethodInfo minfo;
        jobject jobj;
    
        if (JniHelper::getStaticMethodInfo(minfo, "org/cocos2dx/cpp/AppActivity",
                                       "getInstance", "()Ljava/lang/Object;")){
            //获取单例
            jobj = minfo.env->CallStaticObjectMethod(minfo.classID, minfo.methodID);
            if (JniHelper::getStaticMethodInfo(minfo, "org/cocos2dx/cpp/AppActivity",
                                     "showBuy_Static", "(I)V")){
                log("jobj start");
                if(jobj == NULL){
                    return;
                }
//                minfo.env->CallStaticVoidMethod(jobj, minfo.methodID,tag);
                minfo.env->CallStaticVoidMethod(minfo.classID,minfo.methodID,tag);
                log("jobj  end");
            }
        }
    #endif
}
#if (CC_TARGET_PLATFORM == CC_PLATFORM_ANDROID) //判断当前是否为Android平台
extern "C"
{
    void Java_org_cocos2dx_cpp_AppActivity_saveTimeByIndex(JNIEnv*  env, jobject thiz, jint billingIndex)
    {
        log("billingIndex == %d",billingIndex);
        buyLayer->saveTimeByIndex(billingIndex);
    }
}
#endif
void BuyScene::saveTimeByIndex(int index)
{
    log("时间已保存 index = %d",index);
    if(index==1)
    {
        UserDefault::getInstance()->setIntegerForKey(ADDTIME, 1);
    }
    else if (index==2)
    {
        UserDefault::getInstance()->setIntegerForKey(ADDTIME, 2.4);
    }
    else if (index==3)
    {
        UserDefault::getInstance()->setIntegerForKey(ADDTIME, 5);
    }
    else if (index==4)
    {
        UserDefault::getInstance()->setIntegerForKey(ADDTIME, 11);
    }
    else if (index==5)
    {
        UserDefault::getInstance()->setIntegerForKey(ADDTIME, 14);
    }
    else if (index==6)
    {
        UserDefault::getInstance()->setIntegerForKey(ADDTIME, 18);
    }
    else if (index==7)
    {
        UserDefault::getInstance()->setIntegerForKey(ADDTIME, 24);
    }
    else if (index==8)
    {
        UserDefault::getInstance()->setIntegerForKey(ADDTIME, 30);
    }
    else if (index==9)
    {
        UserDefault::getInstance()->setIntegerForKey(ADDTIME, 50);
    }
    else
    {
        UserDefault::getInstance()->setIntegerForKey(ADDTIME, 70);
    }

}

void BuyScene::onKeyReleased(EventKeyboard::KeyCode keyCode,Event* pEvent)
{
    log("Key_ESCAPE pressed");
    if (EventKeyboard::KeyCode::KEY_ESCAPE==keyCode) {
        showIfExitAlert(this);
    }
}
//退出层
void BuyScene::showIfExitAlert(Ref* pSender)
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
