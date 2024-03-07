$(function(){	
	var height = $("#content").height();		//计算整体高度
	$("#left,#right").height(height);

	$("#content").resize(function(){			//根据整体高度自动适应
		var reheight = $("#content").height();
		$("#left,#right").height(reheight);
		if($.browser.msie){
			$('#content').unbind('resize');
			$('#content').bind('resize',function(){
				var reheight = $("#content").height();
				$("#left,#right").height(reheight);
			});
		}
	});

	/*$('#menu > li').hover(function(){
		$(this).css('background-image',"url(./html/img/nav02.png)");
	},function(){
		$(this).css('background-image',"url(./html/img/nav01.png)");
	});*/

	$.each($('#menu li ul'),function(){			//二级菜单加圆角
		$(this).children('li:last').hover(function(){
			var li = $(this);
			$('.yesleft,.yesright').show().hover(function(){
				li.css('background-color','#0779C2');
			},function(){
				li.css('background-color','#2794CC');
			});
			$('.noleft,.noright').hide();
		},function(){
			$('.yesleft,.yesright').hide();
			$('.noleft,.noright').show();
		});
	});

	var numble = $("#menu > li").length;		//计算一级菜单宽度自动排列
	$("#menu > li").width(1200/numble);

	$.each($("#menu li ul li a"),function(){	//二级菜单居中
		len = leng($(this).text());
		if(len > 14){
			var width = (len - 14)*6;
			//$(this).parent().parent().width(1120/numble + width).css('left',-width/2 + 'px');
		}
	});

	function leng(str){								//计算字符串占几位
		var len = 0; 
		for (var i = 0; i < str.length; i++) { 
			if (str[i].match(/[^\x00-\xff]/ig) != null){ //全角 
				len += 2; 
			}else{ 
				len += 1;
			}
		} 
		return len; 
	}

	$.each($('#menu > li'),function(i){			//一级菜单点击显示
		$(this).mouseup(function(){
			for(var j = 1 ; j < numble + 1 ; j++){
				$('#tab'+j).hide();
			}
		$('#tab'+i).show();
		tab ='#tab'+i;
		});
	i++;
	});

	for(var j = 1 ; j < numble + 1 ; j++){		//初始化一级菜单显示
		$('#tab'+j).hide();
	}
	$('#tab1').show();
	tab ='#tab1';

	$.each($("#contentmain label"),function(){	//初始化表格或图片的标题
		$(this).width($(this).text().length * 11 + 154);
	});

	$.each($('#contentmain .average tbody'),function(){	//设置td间的宽度
		var tdnu = $(this).children('tr').children('td').length;
		$(this).children('tr').children('td').width(1000/tdnu);
	});

	$.each($('#contentmain table tbody'),function(){	//设置tr间隔的颜色
		$(this).children('tr:even').css('background','#E4F1FC');
		$(this).children('tr:odd').css('background','#EFF6FF');
	});

	$('#menu li a,#pageleft dl a').click(function(){			//二级菜单点击显示
	var hash=$(this).attr('href');
	window.location.hash=hash;
	
				if(location.hash){
			
			
			 var target = $(location.hash);
			 if(target.length==1){
				 var top = target.offset().top-50;
				 if(top > 0){
					 $('html,body').animate({scrollTop:top}, 1000);
				 }
			 }
		  }
		 
	});
	//二维码
	$("#weixin").mouseover(function () {
                $("#wx").css("display","block");
            });
	$("#weixin").mouseleave(function () {
               $("#wx").css("display","none");
            });	
	
	$('#closecode').click(function(){			//关闭二维码
		$('#code').fadeOut('slow');		
		$(this).fadeOut('slow');		
	});	

	$(window).scroll(function(){				//滚动条滑动到200px是出现回顶部
		var scrolltop = $(document).scrollTop();
		if(scrolltop > 200){
			$('#backtop').show();
			$('#topm').addClass('topmenu1');
			$('#topm').removeClass('topmenu');
			//$('#menu').css('position','fixed');//导航菜单不固定
		}
		if(scrolltop < 200){
			$('#backtop').hide();
			$('#topm').addClass('topmenu');
			$('#topm').removeClass('topmenu1');
			$('#menu').css('position','relative');
		}
	});

	$('#backtop').click(function(){				//回顶部效果
		$('html,body').animate({scrollTop:0}, 1000);	
	});

	$.each($('#menu > li'),function(){				//点一二级标题时修改导航内容
		$(this).click(function(){
			$('#closenav,#shownav,#nav').remove();
			$('#backtop').after(navstr);
			var tow = $(this).children('ul').children('li').children('a');
			nav(tow);
		});
	});
	nav($('#menu > li').first().children('ul').children('li').children('a'));
	function nav(tow){	
		var townum = tow.length;
		if(townum == 0){$('#closenav,#shownav,#nav').remove();}
		$.each(tow,function(i){							//导航内容的修改
			if(i==0){
				$('#firstnav').children('img:first-child').after($(this).text());
			}else if(i == townum-1){
				$('#lastnav').children('img:first-child').after($(this).text());
			}else{
				$('#lastnav').before("<div class='nav'>"+ $(this).text() +"</div>");
			}
		});
		$('#nav').css('bottom',(104-townum*13)+'px');	//导航nav的位置矫正
		$('#shownav').css('left',-(25+$('#nav').width())+'px');
		$('#nav').css('left',-($('#nav').width())+'px');
		$('#closenav').click(function(){				//导航nav的滑出效果
			$('#shownav').animate({left: '0px'}, "slow");
			$('#nav').animate({left: '25px'}, "slow");
			$('#closenav').animate({left: '-25px'}, "slow");
		});
		$('#shownav').click(function(){
			$('#shownav').animate({left: -(25+$('#nav').width())+'px'}, "slow");
			$('#nav').animate({left: -($('#nav').width())+'px'}, "slow");
			$('#closenav').delay(400).animate({left: '0px'}, "slow");
		});

		$.each($('#nav').children(),function(i){		//导航滑到位置效果
			$(this).click(function(){
				$("html,body").animate({scrollTop: $(tab+" h2").eq(i).offset().top}, 1000);
			});
		});

		$('#firstnav').hover(function(){				//导航悬停变色
			$(this).children().first().attr('src','html/img/htoplnav.jpg');
			$(this).children().last().attr('src','html/img/htoprnav.jpg');
			$(this).css('background-color','#0578C2');
		},function(){
			$(this).children().first().attr('src','html/img/toplnav.jpg');
			$(this).children().last().attr('src','html/img/toprnav.jpg');
			$(this).css('background-color','#2794CC');		
		});
		$('#lastnav').hover(function(){
			$(this).children().first().attr('src','html/img/hbotlnav.jpg');
			$(this).children().last().attr('src','html/img/hbotrnav.jpg');
			$(this).css('background-color','#0578C2');
		},function(){
			$(this).children().first().attr('src','html/img/botlnav.jpg');
			$(this).children().last().attr('src','html/img/botrnav.jpg');
			$(this).css('background-color','#2794CC');		
		});
		$('.nav').hover(function(){
			$(this).css('background-color','#0578C2');
		},function(){
			$(this).css('background-color','#2794CC');		
		});
	}
	/*var navstr = '<div id="nav"><div id="firstnav"><img src="img/toplnav.jpg"style="float:left;"><img src="img/toprnav.jpg"style="float:right;"></div><div id="lastnav"><img src="img/botlnav.jpg"style="float:left;"><img src="img/botrnav.jpg"style="float:right;"></div></div>';
*/
});
