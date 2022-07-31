<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" isELIgnored="false" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%
String basePath = request.getScheme() + "://" + request.getServerName() + ":" + request.getServerPort() + request.getContextPath() + "/";
%>

<html>
<head>
	<base href="<%=basePath %>">
<meta charset="UTF-8">

<link href="jquery/bootstrap_3.3.0/css/bootstrap.min.css" type="text/css" rel="stylesheet" />
<link href="jquery/bootstrap-datetimepicker-master/css/bootstrap-datetimepicker.min.css" type="text/css" rel="stylesheet" />
<link rel="stylesheet" type="text/css" href="jquery/bs_pagination-master/css/jquery.bs_pagination.min.css">

<script type="text/javascript" src="jquery/jquery-1.11.1-min.js"></script>
<script type="text/javascript" src="jquery/bootstrap_3.3.0/js/bootstrap.min.js"></script>
<script type="text/javascript" src="jquery/bootstrap-datetimepicker-master/js/bootstrap-datetimepicker.js"></script>
<script type="text/javascript" src="jquery/bootstrap-datetimepicker-master/locale/bootstrap-datetimepicker.zh-CN.js"></script>
<script type="text/javascript" src="jquery/bs_pagination-master/js/jquery.bs_pagination.min.js"></script>
<script type="text/javascript" src="jquery/bs_pagination-master/localization/en.js"></script>

<script type="text/javascript">

	$(function(){

		$("#creatActivityBtn").click(function () {
			$("#creatActivityForm").get(0).reset();
			$("#createActivityModal").modal("show");

		})
		
		$("#saveBtn").click(function () {

			var owner=$("#create-marketActivityOwner").val();
			var name=$.trim($("#create-marketActivityName").val());
			var startDate=$("#create-startTime").val();
			var endDate=$("#create-endTime").val();
			var cost=$.trim($("#create-cost").val());
			var description=$.trim($("#create-describe").val());

			if ( owner == "") {
				alert("所有者不能为空");
				return;
			}
			if(name == ""){
				alert("名称不能为空");
				return;
			}
			if (startDate != "" && endDate != "") {
				if(endDate<startDate){
					alert("结束日期不能晚于开始日期")
					return;
				}
			}
			var regExp=/^(([1-9]\d*)|0)$/;
			if (!regExp.test(cost)) {
				alert("成本必须是正整数")
				return;
			}
			$.ajax({
				url:'workbench/activity/saveCreatActivity.do',
				data:{
					owner:owner,
					name:name,
					startDate:startDate,
					endDate:endDate,
					cost:cost,
					description:description
				},
				type:"post",
				dataType:"json",
				success:function (data) {
					if (data.code == "1") {
						//关闭模态窗口
						$("#createActivityModal").modal("hide");
						//刷新活动页面
						queryActivityByCondition(1,$("#pageList").bs_pagination("getOption","rowsPerPage"));
					}else{
						alert(data.message);
						$("#createActivityModal").modal("show");
					}
				}
			})
		})

		$(".mydate").datetimepicker({
			language:'zh-CN',
			format:'yyyy-mm-dd',
			minView:'month',
			initialDate:new Date(),
			autoclose:true,
			todayBtn:true,
			clearBtn:true
		})

		//第一次进入市场活动页面时，查询数据
		queryActivityByCondition(1,10);

		/*点击查询按钮时*/
		$("#conditionBtn").click(function () {
			queryActivityByCondition(1,$("#pageList").bs_pagination("getOption","rowsPerPage"));
		})

		//给全选按钮加单击事件
		$("#chckAll").click(function () {
			$("#mytbody input[type='checkbox']").prop("checked",this.checked);
		})


		$("#mytbody").on("click","input[type='checkbox']",function () {
			if($("#mytbody input[type='checkbox']").size()==$("#mytbody input[type='checkbox']:checked").size()){
				$("#chckAll").prop("checked",true);
			}else {
				$("#chckAll").prop("checked",false);
			}
		})

		$("#deleteActivityBtn").click(function () {
			var mytbody = $("#mytbody input[type='checkbox']:checked");
			//判断是否选中数据
			if(mytbody.size()==0){
				alert("请选择要删除的市场活动");
				return;//未选中数据结束方法，不继续往下操作
			}


			//弹出窗口，询问是否确定删除
			if (window.confirm("确定要删除吗？")) {
				//收集数据，存到字符串中
				//拼接字符串"id=xxx&id=xxxx&id=xxxx"

				var ids="";

				$.each(mytbody,function () {
					ids+="id="+this.value+"&";
				})
				ids=ids.substr(0,ids.length-1);

				$.ajax({
					url:'workbench/activity/deleteActivityById.do',
					data:ids,
					type:'post',
					dataType:'json',
					success:function (data) {
						if (data.code == "1") {
							queryActivityByCondition(1,$("#pageList").bs_pagination("getOption","rowsPerPage"));
						}else {
							alert(data.message)
						}
					},
				})
			}

		})
		
		$("#updataActivityBtn").click(function () {

			var mytbody = $("#mytbody input[type='checkbox']:checked");

			if (mytbody.size()==0) {
				alert("请选择要修改的市场活动")
				return;


			}else if(mytbody.size()>1){
				alert("只能选择一个市场活动");
				return;
			}else {
				var id=mytbody.get(0).value;

				$.ajax({
					url:'workbench/activity/selectActivityById.do',
					data:{
						id:id
					},
					type:'post',
					dataType:'json',
					success:function (data) {
						$("#edit_id").val(data.id)
						$("#edit-marketActivityOwner").val(data.owner)
						$("#edit-marketActivityName").val(data.name);
						$("#edit-startTime").val(data.startDate)
						$("#edit-endTime").val(data.endDate)
						$("#edit-cost").val(data.cost)
						$("#edit-describe").val(data.description)
						$("#editActivityModal").modal("show");
					}
				})
			}

		})
		
		$("#updateBtn").click(function () {
			var id=$("#edit_id").val();
			var owner=$("#edit-marketActivityOwner").val();
			var name=$.trim($("#edit-marketActivityName").val());
			var startDate=$("#edit-startTime").val();
			var endDate=$("#edit-endTime").val();
			var cost=$.trim($("#edit-cost").val());
			var description=$.trim($("#edit-describe").val());
			if ( owner == "") {
				alert("所有者不能为空");
				return;
			}
			if(name == ""){
				alert("名称不能为空");
				return;
			}
			if (startDate != "" && endDate != "") {
				if(endDate<startDate){
					alert("结束日期不能晚于开始日期")
					return;
				}
			}
			var regExp=/^(([1-9]\d*)|0)$/;
			if (!regExp.test(cost)) {
				alert("成本必须是正整数")
				return;
			}

			$.ajax({
				url:'workbench/activity/updateActivityById.do',
				data:{
					id:id,
					owner:owner,
					name:name,
					startDate:startDate,
					endDate:endDate,
					cost:cost,
					description:description
				},
				type:'post',
				dataType:'json',
				success:function (data) {
					if (data.code == "1") {
						//关闭模态窗口
						$("#editActivityModal").modal("hide");
						//刷新活动页面
						queryActivityByCondition($("#pageList").bs_pagination("getOption","currentPage"),$("#pageList").bs_pagination("getOption","rowsPerPage"));
					}else{
						alert(data.message);
						$("#editActivityModal").modal("show");
					}
				}
			})

		})

		$("#exportActivityAllBtn").click(function () {
			window.location.href="workbench/activity/exportllActivity.do";
		})

		$("#exportActivityXzBtn").click(function () {
			var mytbody = $("#mytbody input[type='checkbox']:checked");
			//判断是否选中数据
			if(mytbody.size()==0){
				alert("请选择要下载的市场活动");
				return;//未选中数据结束方法，不继续往下操作
			}


			//弹出窗口，询问是否确定删除
			if (window.confirm("确定要下载吗？")) {
				//收集数据，存到字符串中
				//拼接字符串"id=xxx&id=xxxx&id=xxxx"

				var ids = "";

				$.each(mytbody, function () {
					ids += "id=" + this.value + "&";
				})
				ids = ids.substr(0, ids.length - 1);

				window.location.href="workbench/activity/downLoadById.do?"+ids
			}
		})
		
		$("#importActivityBtn").click(function () {
			//获取客户上传的文件名
			var activityFilename=$("#activityFile").val();
			var suffix=activityFilename.substr(activityFilename.lastIndexOf(".")+1).toLocaleLowerCase();
			if(suffix!="xls"){
				alert("只能上传xls文件")
				return;
			}

			//获取文件本身，需要获取表单组件的dom对象
			var activityFile=$("#activityFile")[0].files[0];
			if (activityFile.size> 5 * 1024 * 1024) {
				alert("只能上传5M以下的文件");
				return;
			}
			alert("dwwtewetwbgnbfgjfj")
			var formData=new FormData();
			formData.append("activityFile",activityFile);
			formData.append("userName","张三");
			$.ajax({
				url:'workbench/activity/importActivity.do',
				data:formData,
				processData:false,//设置ajax向后台提交参数之前，是否把参数统一转换为字符串。true--是，false--不是。默认是true
				contentType:false,//设置ajax向后台提交参数之前，是否把所有的参数统一按urlencodeed编码：true--是，false--不是。默认是true
				type:'post',
				dataType:'json',
				success:function (data) {
					alert("导入成功？？？？")
					if (data.code == "1") {
						alert("成功导入"+data.retData+"条市场活动")
						$("#importActivityModal").modal("hide")
						queryActivityByCondition(1,$("#pageList").bs_pagination("getOption","rowsPerPage"));
					}else {
						alert(data.message)
						$("#importActivityModal").modal("show")
					}
				}
			})

		})

	});

	function queryActivityByCondition(pageNo,pageSize){
		var name=$("#name").val();
		var owner=$("#owner").val();
		var startDate=$("#startDate").val();
		var endDate=$("#endDate").val();
		/*var pageNo=1;
		var pageSize=10;*/
		
		$.ajax({
			url:'workbench/activity/select.do',
			data:{
				name:name,
				owner:owner,
				startDate:startDate,
				endDate:endDate,
				pageNo:pageNo,
				pageSize:pageSize
			},
			type:'post',
			dataType:'json',
			success:function (data) {
				/*$("#totalRowsB").text(data.totalRows)*/
				var htmlStr="";

				$.each(data.activities,function (index,obj) {
					htmlStr +="<tr class=\"active\">";
					htmlStr +="<td><input type=\"checkbox\" value=\""+obj.id+"\"/ id=\"id\"></td>";
					htmlStr +="<td><a style=\"text-decoration: none; cursor: pointer;\" onclick=\"window.location.href='workbench/activity/detailActivity.do?id="+obj.id+"'\">"+obj.name+"</a></td>";
					htmlStr +="<td>"+obj.owner+"</td>";
					htmlStr +="<td>"+obj.startDate+"</td>";
					htmlStr +="<td>"+obj.endDate+"</td>";
					htmlStr +="</tr>";
				});

				$("#mytbody").html(htmlStr);
				$("#chckAll").prop("checked",false);

				var totalPages=1;

				if (data.totalRows % pageSize == 0) {
					totalPages=data.totalRows/pageSize;
				}else{
					totalPages=parseInt(data.totalRows/pageSize)+1;
				}

				$("#pageList").bs_pagination({
					currentPage:pageNo,/*当前页*/

					rowsPerPage:pageSize,//每页显示的条数
					totalRows:data.totalRows,//总条数
					totalPages:totalPages,//总页数 必填参数

					visiblePageLinks:5,

					showGoToPage: true,
					showRowsPerPage: true,
					showRowsInfo: true,

					onChangePage:function (e,obj) {
						queryActivityByCondition(obj.currentPage,obj.rowsPerPage)
					}

				})

			}
		});
	}
</script>
</head>
<body>

	<!-- 创建市场活动的模态窗口 -->
	<div class="modal fade" id="createActivityModal" role="dialog">
		<div class="modal-dialog" role="document" style="width: 85%;">
			<div class="modal-content">
				<div class="modal-header">
					<button type="button" class="close" data-dismiss="modal">
						<span aria-hidden="true">×</span>
					</button>
					<h4 class="modal-title" id="myModalLabel1">创建市场活动</h4>
				</div>
				<div class="modal-body">
				
					<form class="form-horizontal" id="creatActivityForm" role="form">
					
						<div class="form-group">
							<label for="create-marketActivityOwner" class="col-sm-2 control-label">所有者<span style="font-size: 15px; color: red;">*</span></label>
							<div class="col-sm-10" style="width: 300px;">
								<select class="form-control" id="create-marketActivityOwner">
								  <c:forEach items="${list}" var="user">
									  <option value="${user.id}">${user.name}</option>
								  </c:forEach>
								</select>
							</div>
                            <label for="create-marketActivityName" class="col-sm-2 control-label">名称<span style="font-size: 15px; color: red;">*</span></label>
                            <div class="col-sm-10" style="width: 300px;">
                                <input type="text" class="form-control" id="create-marketActivityName">
                            </div>
						</div>
						
						<div class="form-group">
							<label for="create-startTime" class="col-sm-2 control-label">开始日期</label>
							<div class="col-sm-10" style="width: 300px;">
								<input type="text" class="form-control mydate" id="create-startTime" readonly>
							</div>
							<label for="create-endTime" class="col-sm-2 control-label">结束日期</label>
							<div class="col-sm-10" style="width: 300px;">
								<input type="text" class="form-control mydate" id="create-endTime" readonly>
							</div>
						</div>
                        <div class="form-group">

                            <label for="create-cost" class="col-sm-2 control-label">成本</label>
                            <div class="col-sm-10" style="width: 300px;">
                                <input type="text" class="form-control" id="create-cost">
                            </div>
                        </div>
						<div class="form-group">
							<label for="create-describe" class="col-sm-2 control-label">描述</label>
							<div class="col-sm-10" style="width: 81%;">
								<textarea class="form-control" rows="3" id="create-describe"></textarea>
							</div>
						</div>
						
					</form>
					
				</div>
				<div class="modal-footer">
					<button type="button" class="btn btn-default" data-dismiss="modal">关闭</button>
					<button type="button" class="btn btn-primary" id="saveBtn">保存</button>
				</div>
			</div>
		</div>
	</div>
	
	<!-- 修改市场活动的模态窗口 -->
	<div class="modal fade" id="editActivityModal" role="dialog">
		<div class="modal-dialog" role="document" style="width: 85%;">
			<div class="modal-content">
				<div class="modal-header">
					<button type="button" class="close" data-dismiss="modal">
						<span aria-hidden="true">×</span>
					</button>
					<h4 class="modal-title" id="myModalLabel2">修改市场活动</h4>
				</div>
				<div class="modal-body">
				
					<form class="form-horizontal" role="form">
						<input type="hidden" id="edit_id">
						<div class="form-group">
							<label for="edit-marketActivityOwner" class="col-sm-2 control-label">所有者<span style="font-size: 15px; color: red;">*</span></label>
							<div class="col-sm-10" style="width: 300px;">
								<select class="form-control" id="edit-marketActivityOwner">
									<c:forEach items="${list}" var="user">
										<option value="${user.id}">${user.name}</option>
									</c:forEach>
								</select>
							</div>
                            <label for="edit-marketActivityName" class="col-sm-2 control-label">名称<span style="font-size: 15px; color: red;">*</span></label>
                            <div class="col-sm-10" style="width: 300px;">
                                <input type="text" class="form-control" id="edit-marketActivityName" >
                            </div>
						</div>

						<div class="form-group">
							<label for="edit-startTime" class="col-sm-2 control-label">开始日期</label>
							<div class="col-sm-10" style="width: 300px;">
								<input type="text" class="form-control mydate" id="edit-startTime"  readonly >
							</div>
							<label for="edit-endTime" class="col-sm-2 control-label">结束日期</label>
							<div class="col-sm-10" style="width: 300px;">
								<input type="text" class="form-control mydate" id="edit-endTime"  readonly>
							</div>
						</div>
						
						<div class="form-group">
							<label for="edit-cost" class="col-sm-2 control-label">成本</label>
							<div class="col-sm-10" style="width: 300px;">
								<input type="text" class="form-control" id="edit-cost" >
							</div>
						</div>
						
						<div class="form-group">
							<label for="edit-describe" class="col-sm-2 control-label">描述</label>
							<div class="col-sm-10" style="width: 81%;">
								<textarea class="form-control" rows="3" id="edit-describe"></textarea>
							</div>
						</div>
						
					</form>
					
				</div>
				<div class="modal-footer">
					<button type="button" class="btn btn-default" data-dismiss="modal">关闭</button>
					<button type="button" class="btn btn-primary" id="updateBtn">更新</button>
				</div>
			</div>
		</div>
	</div>
	
	<!-- 导入市场活动的模态窗口 -->
    <div class="modal fade" id="importActivityModal" role="dialog">
        <div class="modal-dialog" role="document" style="width: 85%;">
            <div class="modal-content">
                <div class="modal-header">
                    <button type="button" class="close" data-dismiss="modal">
                        <span aria-hidden="true">×</span>
                    </button>
                    <h4 class="modal-title" id="myModalLabel">导入市场活动</h4>
                </div>
                <div class="modal-body" style="height: 350px;">
                    <div style="position: relative;top: 20px; left: 50px;">
                        请选择要上传的文件：<small style="color: gray;">[仅支持.xls]</small>
                    </div>
                    <div style="position: relative;top: 40px; left: 50px;">
                        <input type="file" id="activityFile">
                    </div>
                    <div style="position: relative; width: 400px; height: 320px; left: 45% ; top: -40px;" >
                        <h3>重要提示</h3>
                        <ul>
                            <li>操作仅针对Excel，仅支持后缀名为XLS的文件。</li>
                            <li>给定文件的第一行将视为字段名。</li>
                            <li>请确认您的文件大小不超过5MB。</li>
                            <li>日期值以文本形式保存，必须符合yyyy-MM-dd格式。</li>
                            <li>日期时间以文本形式保存，必须符合yyyy-MM-dd HH:mm:ss的格式。</li>
                            <li>默认情况下，字符编码是UTF-8 (统一码)，请确保您导入的文件使用的是正确的字符编码方式。</li>
                            <li>建议您在导入真实数据之前用测试文件测试文件导入功能。</li>
                        </ul>
                    </div>
                </div>
                <div class="modal-footer">
                    <button type="button" class="btn btn-default" data-dismiss="modal">关闭</button>
                    <button id="importActivityBtn" type="button" class="btn btn-primary">导入</button>
                </div>
            </div>
        </div>
    </div>
	
	
	<div>
		<div style="position: relative; left: 10px; top: -10px;">
			<div class="page-header">
				<h3>市场活动列表</h3>
			</div>
		</div>
	</div>
	<div style="position: relative; top: -20px; left: 0px; width: 100%; height: 100%;">
		<div style="width: 100%; position: absolute;top: 5px; left: 10px;">
		
			<div class="btn-toolbar" role="toolbar" style="height: 80px;">
				<form class="form-inline" role="form" style="position: relative;top: 8%; left: 5px;">
				  
				  <div class="form-group">
				    <div class="input-group">
				      <div class="input-group-addon">名称</div>
				      <input class="form-control" type="text" id="name">
				    </div>
				  </div>
				  
				  <div class="form-group">
				    <div class="input-group">
				      <div class="input-group-addon">所有者</div>
				      <input class="form-control" type="text" id="owner">
				    </div>
				  </div>


				  <div class="form-group">
				    <div class="input-group">
				      <div class="input-group-addon">开始日期</div>
					  <input class="form-control  mydate" type="text" id="startDate" />
				    </div>
				  </div>
				  <div class="form-group">
				    <div class="input-group">
				      <div class="input-group-addon">结束日期</div>
					  <input class="form-control  mydate" type="text" id="endDate">
				    </div>
				  </div>
				  
				  <button type="button" class="btn btn-default" id="conditionBtn">查询</button>
				  
				</form>
			</div>
			<div class="btn-toolbar" role="toolbar" style="background-color: #F7F7F7; height: 50px; position: relative;top: 5px;">
				<div class="btn-group" style="position: relative; top: 18%;">
				  <button type="button" class="btn btn-primary" id="creatActivityBtn"><span class="glyphicon glyphicon-plus"></span> 创建</button>
				  <button type="button" class="btn btn-default" id="updataActivityBtn" ><span class="glyphicon glyphicon-pencil"></span> 修改</button>
				  <button type="button" class="btn btn-danger" id="deleteActivityBtn"><span class="glyphicon glyphicon-minus" ></span> 删除</button>
				</div>
				<div class="btn-group" style="position: relative; top: 18%;">
                    <button type="button" class="btn btn-default" data-toggle="modal" data-target="#importActivityModal" ><span class="glyphicon glyphicon-import"></span> 上传列表数据（导入）</button>
                    <button id="exportActivityAllBtn" type="button" class="btn btn-default"><span class="glyphicon glyphicon-export"></span> 下载列表数据（批量导出）</button>
                    <button id="exportActivityXzBtn" type="button" class="btn btn-default"><span class="glyphicon glyphicon-export"></span> 下载列表数据（选择导出）</button>
                </div>
			</div>
			<div style="position: relative;top: 10px;">
				<table class="table table-hover">
					<thead>
						<tr style="color: #B3B3B3;">
							<td><input type="checkbox" id="chckAll" /></td>
							<td>名称</td>
                            <td>所有者</td>
							<td>开始日期</td>
							<td>结束日期</td>
						</tr>
					</thead>
					<tbody id="mytbody">
						<%--<tr class="active">
							<td><input type="checkbox" /></td>
							<td><a style="text-decoration: none; cursor: pointer;" onclick="window.location.href='detail.jsp';">发传单</a></td>
                            <td>zhangsan</td>
							<td>2020-10-10</td>
							<td>2020-10-20</td>
						</tr>
                        <tr class="active">
                            <td><input type="checkbox" /></td>
                            <td><a style="text-decoration: none; cursor: pointer;" onclick="window.location.href='detail.jsp';">发传单</a></td>
                            <td>zhangsan</td>
                            <td>2020-10-10</td>
                            <td>2020-10-20</td>
                        </tr>--%>
					</tbody>
				</table>
				<div id="pageList"></div>
			</div>

			<<%--div style="height: 50px; position: relative;top: 30px;">
				<div>
					<button type="button" class="btn btn-default" style="cursor: default;">共<b id="totalRowsB">50</b>条记录</button>
				</div>
				<div class="btn-group" style="position: relative;top: -34px; left: 110px;">
					<button type="button" class="btn btn-default" style="cursor: default;">显示</button>
					<div class="btn-group">
						<button type="button" class="btn btn-default dropdown-toggle" data-toggle="dropdown">
							10
							<span class="caret"></span>
						</button>
						<ul class="dropdown-menu" role="menu">
							<li><a href="#">20</a></li>
							<li><a href="#">30</a></li>
						</ul>
					</div>
					<button type="button" class="btn btn-default" style="cursor: default;">条/页</button>
				</div>
				<div style="position: relative;top: -88px; left: 285px;">
					<nav>
						<ul class="pagination">
							<li class="disabled"><a href="#">首页</a></li>
							<li class="disabled"><a href="#">上一页</a></li>
							<li class="active"><a href="#">1</a></li>
							<li><a href="#">2</a></li>
							<li><a href="#">3</a></li>
							<li><a href="#">4</a></li>
							<li><a href="#">5</a></li>
							<li><a href="#">下一页</a></li>
							<li class="disabled"><a href="#">末页</a></li>
						</ul>
					</nav>
				</div>
			</div>--%>
			
		</div>
		
	</div>
</body>
</html>