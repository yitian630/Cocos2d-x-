
var ASMainLayer = cc.Layer.extend({
    sprite:null,
    ctor:function () {
        //////////////////////////////true
        // 1. super init first
        this._super();

        /////////////////////////////
        // 2. add a menu item with "X" image, which is clicked to quit the program
        //    you may modify it.
        // ask the window size
        var size = cc.winSize;


        cc.MenuItemFont.setFontName("Times New Roman");
        cc.MenuItemFont.setFontSize(60);
        var startItem = new cc.MenuItemFont("开始游戏",this.menuItemCallback, this);
        var menu = new cc.Menu(startItem);
        this.addChild(menu,1);

        this.sprite = new cc.Sprite(res.bg_png);
        this.sprite.attr({
            x: size.width / 2,
            y: size.height / 2
        });
        this.addChild(this.sprite, 0);

        return true;
    },
    menuItemCallback:function(){
        cc.log("touch start Menu Item");
        cc.director.runScene(new ASGameScene())
    }
});

var ASMainScene = cc.Scene.extend({
    onEnter:function () {
        this._super();
        var layer = new ASMainLayer();
        this.addChild(layer);
    }
});

