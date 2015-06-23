/**
 * Created by sunfei on 15/6/4.
 */
BestScore = "bestScore"
HPvalue = "HPValue"
var ASGameLayer = cc.Layer.extend({
    _size : null,
    _zhuanPan : null,
    _tuzi : null,
    _bg : null,  //背景
    _isBlue : null,  //判断是否是蓝色背景
    _tishi : null,     //提示
    _isRunning : null,  //是否正在游戏
    _score : null,    //分数
    _scoreLabel : null,  //显示分数Label
    _HP : null,       //生命值
    _HPImage : null,  //生命图标
    _HPLabel : null,  //生命值Label
    _isZhadan : null, //是否是炸弹
    ctor : function () {
        this._super();

        this._size = cc.winSize;

        //游戏背景
        this._isBlue = false;  //默认橘色
        this._bg = new cc.Sprite("#bg_orange.jpg");
        this._bg.setPosition(this._size.width/2, this._size.height/2);
        this.addChild(this._bg);

        this._tishi = new cc.Sprite("#tishi.png");
        this._tishi.setPosition(this._size.width/2, this._size.height/5*4+20);
        this.addChild(this._tishi);

        //转盘
        this._zhuanPan = new ASZhuanPan();
        this._zhuanPan.setPosition(this._size.width/2, this._size.height/2);
        this.addChild(this._zhuanPan);

        //兔子
        this._tuzi = new cc.Sprite("#tuzi_normal.png");
        this._tuzi.setPosition(this._size.width/2,this._zhuanPan.getPositionY()+this._zhuanPan.getBoundingBox().height/2+this._tuzi.getBoundingBox().height/2-10);
        this.addChild(this._tuzi);

        //分数显示
        this._score = 0;
        this._scoreLabel = new cc.LabelBMFont("", res.score_youxi_fnt);
        this._scoreLabel.setPosition(this._size.width/2,this._size.height/8*7);
        this._scoreLabel.setScale(2.5)
        this._scoreLabel.setVisible(false);   //设置隐藏
        this._scoreLabel.setString(this._score)
        this.addChild(this._scoreLabel);
        
        //生命值显示
        this._HPImage = new cc.Sprite("#tuzi_normal.png");
        this._HPImage.setScale(0.4);
        this._HPImage.setVisible(false);
        this._HPImage.setPosition(this._HPImage.getBoundingBox().width, this._size.height - this._HPImage.getBoundingBox().height);
        this.addChild(this._HPImage);
        //label
        this._HP = cc.sys.localStorage.getItem(HPvalue);
        if(this._HP){
        	this._HP = parseInt(this._HP);
        }else{
        	this._HP = 1;
        }
        this._HPLabel = new cc.LabelTTF("x"+this._HP,"Arial",42)
        this._HPLabel.setVisible(false);
        this._HPLabel.setPosition(this._HPImage.getPositionX()+this._HPImage.getBoundingBox().width/2+this._HPLabel.getBoundingBox().width, this._HPImage.getPositionY()-10)
        this.addChild(this._HPLabel)

        //初始游戏未运行
        this._isRunning = false;
        
        //开启定时器
        this.scheduleUpdate();
        //添加点击事件
        cc.eventManager.addListener({
            event : cc.EventListener.TOUCH_ONE_BY_ONE,
            onTouchBegan : function (touch, event) {
           
            	if(event.getCurrentTarget()._isRunning == false){
            		event.getCurrentTarget().startGame();
                }
            	event.getCurrentTarget()._isBlue = true;
                return true;
            },
            onTouchMoved : function (touch, event) {

            },
            onTouchEnded : function (touch, event) {
            	event.getCurrentTarget()._isBlue = false;
            }
        },this);
        
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
    update : function (dt) {
        //更换背景
        this.changeBG();
        if(this._zhuanPan._sprites != null){
            //碰撞检测
            this.collisionRectFunc();
        }
        if(this._HP == 0){
        	this.stopGame();
        	if(this._isZhadan == true){
        		var callFunc = cc.callFunc(function () {
        			this._tuzi.setSpriteFrame(spriteFrameCache.getSpriteFrame("tuzi_die.png"))
        		},this)
        		this._tuzi.runAction(cc.sequence(callFunc, cc.delayTime(1),cc.callFunc(function () {
        		
        			// 跳转结束场景
        			cc.director.runScene(new ASGameOverScene(this._score));
        			cc.director.pushScene(new ASShopScene());
        		},this)))
        	}else{
        		this._tuzi.runAction(cc.sequence(cc.delayTime(1),cc.callFunc(function () {
        			
        			// 跳转结束场景
        			cc.director.runScene(new ASGameOverScene(this._score));
        			cc.director.pushScene(new ASShopScene());
        		},this)))
        	}
        }
 
    },
    //更换背景颜色
    changeBG : function () {
        if(this._isBlue == true){
            this._bg.setSpriteFrame(spriteFrameCache.getSpriteFrame("bg_blue.jpg"))
            this._tuzi.setSpriteFrame(spriteFrameCache.getSpriteFrame("tuzi_yinshen.png"))
        }else{
            this._bg.setSpriteFrame(spriteFrameCache.getSpriteFrame("bg_orange.jpg"))
            this._tuzi.setSpriteFrame(spriteFrameCache.getSpriteFrame("tuzi_normal.png"))
        }
    },
    collisionRectFunc : function () {
        //兔子的矩形
        var _tuziRect = cc.rect(this._tuzi.getPositionX()-this._tuzi.getBoundingBox().width*0.6/2,
            this._tuzi.getPositionY()-this._tuzi.getBoundingBox().height/2,
            this._tuzi.getBoundingBox().width*0.6,this._tuzi.getBoundingBox().height);
        //遍历数组，碰撞检测
        for(var i in this._zhuanPan._sprites){
            var _sprite = this._zhuanPan._sprites[i];
            var _rect = cc.rect(_sprite.convertToWorldSpaceAR().x - _sprite.getBoundingBox().width*0.6/2,
                _sprite.convertToWorldSpaceAR().y - _sprite.getBoundingBox().height/2,
                _sprite.getBoundingBox().width*0.6,
                _sprite.getBoundingBox().height);

            //判断
            if(cc.rectIntersectsRect(_tuziRect,_rect)){
                //分别判断碰撞精灵的类型
                var _tag = _sprite.getTag();
                
                switch(_tag){
                    case 1:
                        //萝卜
                        if(this._isBlue == true){
                            //没吃到萝卜，不得分，游戏结束
                        	this._isZhadan = false;
                        	if(this._HP > 0){
                        		this._HP--;
                        		this._HPLabel.setString("x"+this._HP);
                        	}
                        }else{
                        	cc.log("tag = ",_tag)
                            //迟到萝卜，得分，游戏继续，萝卜消失
                            this._score++;
                            this._scoreLabel.setString(this._score);

                        }
                        break;
                    case 0:
                        //炸弹
                        if(this._isBlue == true){
                            //没碰到炸弹，得分，游戏继续，炸弹消失
                            this._score++;
                            this._scoreLabel.setString(this._score);

                        }else{
                        	cc.log("tag = ",_tag)
                            //碰到炸弹，游戏结束，炸弹消失
                        	this._isZhadan = true;
                        	if(this._HP > 0){
                        		this._HP--;
                        		this._HPLabel.setString("x"+this._HP);
                        	}
                        }
                        break;
                }
                //从数组中删除，从转盘中删除精灵
                this._zhuanPan._sprites.splice(i,1);
                this._zhuanPan._sprite.removeChild(_sprite,true);
            }
        }

    },
    //游戏开始
    startGame : function () {
        // 设置游戏正在运行
        this._isRunning = true;
        //转盘启动
        this._zhuanPan.startRun();

        //提示信息消失
        this._tishi.runAction(new cc.ScaleTo(0.5,0));
        //显示分数
        this._scoreLabel.runAction(cc.sequence(cc.delayTime(0.5),cc.callFunc(function () {
            this._scoreLabel.setVisible(true);
            this._HPImage.setVisible(true);
            this._HPLabel.setVisible(true);
        },this)));
        //兔子向上移动
        this._tuzi.runAction(new cc.MoveTo(1.5,cc.p(this._tuzi.getPositionX(),this._tuzi.getPositionY()+this._zhuanPan._radius/2-20)));

    },
    //游戏结束
    stopGame : function () {
    	cc.log("------stopGame------")
        this._isBlue = false;
    	this.unscheduleUpdate();
        //转盘停止转动
        this._zhuanPan.stopRun();
     
        // 保存最高分数
        var bestScore = cc.sys.localStorage.getItem(BestScore);
        if(bestScore){
        	bestScore = parseInt(bestScore)
        }else{
        	bestScore = 0;
        }
        if(this._score > bestScore){
            cc.sys.localStorage.setItem(BestScore, this._score);
        }else{
            cc.sys.localStorage.setItem(BestScore, bestScore);
        }
    }
})

var ASGameScene = cc.Scene.extend({
    onEnter : function () {
        this._super();
        var layer = new ASGameLayer();
        this.addChild(layer);
    }
})