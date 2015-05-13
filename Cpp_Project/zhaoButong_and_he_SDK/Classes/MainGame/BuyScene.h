//
//  BuyScene.h
//  ZhaoBuTong
//
//  Created by qiyuezhen on 15-5-11.
//
//

#ifndef __ZhaoBuTong__BuyScene__
#define __ZhaoBuTong__BuyScene__

#include "cocos2d.h"
USING_NS_CC;

class BuyScene : public cocos2d::Layer
{
public:
    // there's no 'id' in cpp, so we recommend returning the class instance pointer
    static cocos2d::Scene* createScene();
    virtual bool init();
    
    // a selector callback
    
    void backCall(cocos2d::Ref* pSender);
    
    void buyCall(cocos2d::Ref* pSender);
    
    
    CREATE_FUNC(BuyScene);

    //返回键调用函数
    void onKeyReleased(EventKeyboard::KeyCode keyCode,Event* pEvent);
    //创建是否退出层
    void showIfExitAlert(Ref* pSender);
    
    //保存购买时间
    void saveTimeByIndex(int index);
};


#endif /* defined(__ZhaoBuTong__BuyScene__) */
