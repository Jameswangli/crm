<%--
  Created by IntelliJ IDEA.
  User: 84960
  Date: 2022/7/23
  Time: 18:52
  To change this template use File | Settings | File Templates.
--%>
<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" isELIgnored="false" %>
<%
    String basePath = request.getScheme() + "://" + request.getServerName() + ":" + request.getServerPort() + request.getContextPath() + "/";
%>
<!DOCTYPE html>
<html>
<head>
    <base href="<%=basePath %>">
    <meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
    <script type="text/javascript" src="jquery/jquery-1.11.1-min.js"></script>
    <title>title</title>
    <script type="text/javascript">
        $(function (){
           $("#Btn").click(function () {
               window.location.href="workbench/activity/fileDownLoad.do"
           })
        })
    </script>
</head>
<body>

<input type="button" id="Btn" value="下载">
</body>
</html>
