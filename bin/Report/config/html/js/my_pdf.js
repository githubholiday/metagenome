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

	$("#contenttop").height(130);
	$.each($('#menu').children(),function(i){			//pdf显示一级标题
		$('#tab'+(i+1)).before("<h3>"+ $(this).children('a').html() +"</h3>");
	});
	$('#menu').hide();
});
