//
//  ASStartGame.h
//  Different
//
//  Created by qiyuezhen on 15-4-22.
//
//

#ifndef __Different__ASStartGame__
#define __Different__ASStartGame__

#include "cocos2d.h"
using namespace cocos2d;

class ASStartGame : public cocos2d::Layer
{
public:
    static cocos2d::Scene* createScene();
    
    virtual bool init();
    void startCallback(cocos2d::Ref* pSender);
    CREATE_FUNC(ASStartGame);

    //返回键调用函数
        void onKeyReleased(EventKeyboard::KeyCode keyCode,Event* pEvent);
        //创建是否退出层
        void showIfExitAlert(Ref* pSender);
};


#endif /* defined(__Different__ASStartGame__) */
