//
//  ASNextScene.h
//  Different
//
//  Created by qiyuezhen on 15-4-23.
//
//

#ifndef __Different__ASNextScene__
#define __Different__ASNextScene__
#include "cocos2d.h"
using namespace cocos2d;
class ASNextScene : public cocos2d::Layer
{
public:
    // there's no 'id' in cpp, so we recommend returning the class instance pointer
    static cocos2d::Scene* createScene(RenderTexture* sqr);
    virtual bool init();
    
    // a selector callback
    
    void startCallback(cocos2d::Ref* pSender);
    void menuCallback(cocos2d::Ref* pSender);
    

    CREATE_FUNC(ASNextScene);
    
    //返回键调用函数
    void onKeyReleased(EventKeyboard::KeyCode keyCode,Event* pEvent);
    //创建是否退出层
    void showIfExitAlert(Ref* pSender);
};



#endif /* defined(__Different__ASNextScene__) */
