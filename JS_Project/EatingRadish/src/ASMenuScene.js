/**
 * Created by sunfei on 15/6/4.
 */

var spriteFrameCache = cc.spriteFrameCache;
var ASMenuLayer = cc.Layer.extend({
    ctor : function () {
        this._super();

        var size = cc.winSize;
        spriteFrameCache.addSpriteFrames(res.spriteSheet_plist);
        //创建背景
        var bg = new cc.Sprite("#bg_blue.jpg");
        bg.setPosition(size.width/2,size.height/2);
        this.addChild(bg);

        //logo
        var logo = new cc.Sprite("#logo.png");
        logo.setPosition(size.width/2,size.height/7*5);
        this.addChild(logo);

        //开始按钮
        var startItem = new cc.MenuItemImage("#item_kaishi.png","#item_kaishi.png",this.onClick,this);
        var menu = new cc.Menu(startItem);
        menu.setPosition(size.width/2,logo.getPositionY()-size.height/3);
        this.addChild(menu);
        
        //添加键盘监听事件
        cc.eventManager.addListener({
        	event : cc.EventListener.KEYBOARD,
        	onKeyReleased: function (key, event) {
        		if(key == cc.KEY.back){
        			//调用退出游戏
        			JavaHelper.callToJavaKeyBoard();
        		}
        	}
        },this)
    },
    //开始按钮回调
    onClick : function () {
        cc.director.runScene(new ASGameScene())
    }
})

var ASMenuScene = cc.Scene.extend({
    onEnter : function () {
        this._super();
        var layer = new ASMenuLayer();
        this.addChild(layer);
    }
})