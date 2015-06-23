/**
 * Created by sunfei on 15/6/5.
 */

var MAX_NUMBER = 6;

var ASZhuanPan = cc.Sprite.extend({
    _sprite : null,
    _isRun : null,
    _addSprite : null,
    _sprites : null,   //存放添加的精灵
    _radius : null,   //转盘半径
    _turns : null,    //转盘圈数
    _spriteNumbers : null,
    ctor : function () {
        this._super();

        //设置转盘状态
        this._isRun = false;

        this._sprite = new cc.Sprite("#zhuanquan.png");
        //求出转盘半径
        this._radius = this._sprite.getBoundingBox().width/2;
        this.addChild(this._sprite);
        //初始转盘缩放
        this._sprite.setScale(0.6);

        this._sprites = [];

    },
    //获取转盘BoundingBox
    getBoundingBox : function () {
        return this._sprite.getBoundingBox()
    },
    //获取转盘角度
    getRotation : function () {
        return this._sprite.getRotation()
    },
    //获取显示精灵的个数
    getSpriteNumbers_Show : function () {
        var spriteNumbers_show = 0;
        //按当前圈数 添加精灵个数=圈数+2
        if(this._turns < MAX_NUMBER-1){
            spriteNumbers_show = this._turns+2;
        }else{
            spriteNumbers_show = MAX_NUMBER;
        }

        return spriteNumbers_show;
    },
    //开始动画
    startRun : function () {
        //回调
        var func = cc.callFunc(function () {
        	
            this._isRun = true;
            this._sprite.setRotation(0)
            this._turns = 1;
            //得到当前圈数对应的精灵数
            this._spriteNumbers = this.getSpriteNumbers_Show();
            //启动定时器
            this.scheduleUpdate();
        },this);
        this._sprite.runAction(cc.sequence(cc.spawn(new cc.ScaleTo(1.5,1), new cc.RotateBy(1.5,360)),func));
    },
    //转盘持续转动，每帧转2度
    update : function(dt) {  
    	this._sprite.setRotation(this.getRotation()+2);
    	if(this.getRotation() == 360){
    		//当角度达到360度时重置为0度
    		this._sprite.setRotation(0)
    		this._turns ++;
    		this._spriteNumbers = this.getSpriteNumbers_Show();
    	}
    	//得到当前圈数 应显示的精灵数

    	//添加萝卜
    	if(this.getRotation()%(360/this._spriteNumbers) == 0){

    		this.addRadishAndBomb(this.getRotation()-30);
    	}
    },
    
    //停止动画
    stopRun : function () {
    	cc.log("------stopRun-----")
        this._isRun = false;
    	this.unscheduleUpdate();
        this._sprite.stopAllActions();
    },

    //添加萝卜和炸弹
    addRadishAndBomb : function (angle) {
        //取值0-1
        var index = Math.floor(cc.random0To1()*2);
        switch(index){
            case 0:
                //炸弹,并根据添加角度旋转
                this._addSprite = new cc.Sprite("#zhadan.png");
                this._addSprite.setRotation(360-angle+180);
                this._addSprite.setTag(0);
                break;
            case 1:

                //萝卜,并根据添加角度旋转
                this._addSprite = new cc.Sprite("#luobo.png");
                this._addSprite.setRotation(360-angle);
                this._addSprite.setTag(1);
                break;
        }

        //求出圆上相应角度对应的坐标
        var _x = 211.5+this._radius * Math.cos(angle*Math.PI/180);
        var _y = 211.5+this._radius * Math.sin(angle*Math.PI/180);
        this._addSprite.setPosition(_x,_y);

        this._sprite.addChild(this._addSprite);
        //把对象添加到数组
        this._sprites.push(this._addSprite);
    }
})
