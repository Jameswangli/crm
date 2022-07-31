<%--
  Created by IntelliJ IDEA.
  User: 84960
  Date: 2022/7/25
  Time: 17:20
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
    <title>title</title>
</head>
<body>

<form action="workbench/activity/upLoad.do" method="post" enctype="multipart/form-data">
    <input type="file" name="myFile">
    <input type="text" name="mytext">
    <input type="submit" value="提交">
</form>
</body>
</html>
