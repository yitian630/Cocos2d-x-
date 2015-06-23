var ASShopLayer = cc.Layer.extend({
	ctor : function() {
		this._super();
		cc.log("----shop--")
		
		var size = cc.winSize;
		//背景
		var bg = new cc.Sprite("#bg_blue.jpg")
		bg.setPosition(size.width/2, size.height/2);
		this.addChild(bg);
		
		for (var i = 1; i < 12; i++) {
			var cell_bg = new cc.Sprite(res.shop_cell);
			cell_bg.setPosition(size.width/2, size.height/5*4-(i-1)*cell_bg.getBoundingBox().height);
			this.addChild(cell_bg);
			if(i < 11){
				var label_d = new cc.LabelBMFont("10点",res.ziti_fnt);
				label_d.setAnchorPoint(cc.p(0.5, 0.5));
				var label_m = new cc.LabelBMFont("1条生命",res.ziti_fnt);
				label_m.setAnchorPoint(cc.p(0.5, 0.5));
				label_d.setPosition(size.width/2-cell_bg.getBoundingBox().width/2+label_d.getBoundingBox().width, cell_bg.getPositionY());
				this.addChild(label_d);
				label_m.setPosition(size.width/2, cell_bg.getPositionY());
				this.addChild(label_m);
				if(i == 2){
					label_d.setString("100点");
					label_m.setString("11条生命");
				}else if(i == 3){
					label_d.setString("200点");
					label_m.setString("25条生命");
				}else if(i == 4){
					label_d.setString("400点");
					label_m.setString("60条生命");
				}else if(i == 5){
					label_d.setString("500点");
					label_m.setString("75条生命");
				}else if(i == 6){
					label_d.setString("600点");
					label_m.setString("100条生命");
				}else if(i == 7){
					label_d.setString("700点");
					label_m.setString("120条生命");
				}else if(i == 8){
					label_d.setString("800点");
					label_m.setString("150条生命");
				}else if(i == 9){
					label_d.setString("900点");
					label_m.setString("180条生命");
				}else if(i == 10){
					label_d.setString("1000点");
					label_m.setString("220条生命");
				}
				var buyItem = new cc.MenuItemImage(res.shop_buy, res.shop_buy_press, this.buyHandler, this);
				buyItem.setTag(i);
				var menu = new cc.Menu(buyItem);
				menu.setPosition(size.width/2+cell_bg.getBoundingBox().width/2-buyItem.getBoundingBox().width/2, cell_bg.getPositionY());
				this.addChild(menu);
			}else if(i == 11){
				var label = new cc.LabelBMFont("1元=100点",res.ziti_fnt);
				label.setPosition(size.width/2, cell_bg.getPositionY());
				this.addChild(label);
			}
		}
		var goBack = new cc.MenuItemImage(res.shop_back, res.shop_back_press, this.goBackHandler, this);
		var menu = new cc.Menu(goBack);
		menu.setPosition(size.width/2, size.height/10);
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

	buyHandler : function(sender) {
		
		var tag = sender.getTag();
		//参数
		var args = this.getString(tag)
		JavaHelper.callToJava(args);

	},
	goBackHandler : function() {
		cc.director.popScene();
	},
	getString : function(i){
		if(i <= 9){
			return "00"+i
		}else{
			return "0"+i
		}
	}
})

var ASShopScene = cc.Scene.extend({
	onEnter : function(){
		this._super();
		var layer = new ASShopLayer()
		this.addChild(layer)
	}
})
