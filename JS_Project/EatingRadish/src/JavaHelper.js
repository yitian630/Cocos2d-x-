
var JavaHelper = JavaHelper||{};
JavaHelper.callClassName = "org/cocos2dx/javascript/AppActivity";

JavaHelper.javascriptMethod=function(index) {
//	var _hp = cc.sys.localStorage.getItem(HPvalue);
	if(index == "001"){
		cc.sys.localStorage.setItem(HPvalue,1)
	}else if(index == "002"){
		cc.sys.localStorage.setItem(HPvalue,11)
	}else if(index == "003"){
		cc.sys.localStorage.setItem(HPvalue,25)
	}else if(index == "004"){
		cc.sys.localStorage.setItem(HPvalue,60)
	}else if(index == "005"){
		cc.sys.localStorage.setItem(HPvalue,75)
	}else if(index == "006"){
		cc.sys.localStorage.setItem(HPvalue,100)
	}else if(index == "007"){
		cc.sys.localStorage.setItem(HPvalue,120)
	}else if(index == "008"){
		cc.sys.localStorage.setItem(HPvalue,150)
	}else if(index == "009"){
		cc.sys.localStorage.setItem(HPvalue,180)
	}else if(index == "010"){
		cc.sys.localStorage.setItem(HPvalue,220)
	}
}

JavaHelper.callToJava=function(args) {//【javascript调用java方法】
	var methodName = "showBuyStatic";
	var signature = "(Ljava/lang/String;)V";
	var param1=args;

	var result = jsb.reflection.callStaticMethod(JavaHelper.callClassName, methodName, signature, param1);
	cc.log(result);//"no=30,description=hello world, from javascript"
}
//返回键退出游戏
JavaHelper.callToJavaKeyBoard = function() {
	var methodName = "exitGameStatic";
	var signature = "()V";
	var result = jsb.reflection.callStaticMethod(JavaHelper.callClassName, methodName, signature);
}