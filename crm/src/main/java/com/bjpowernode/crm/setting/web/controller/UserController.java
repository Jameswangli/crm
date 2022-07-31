package com.bjpowernode.crm.setting.web.controller;

import com.bjpowernode.crm.commons.domain.ReturnObject;
import com.bjpowernode.crm.commons.utils.Contants;
import com.bjpowernode.crm.commons.utils.DateUtils;
import com.bjpowernode.crm.setting.domain.User;
import com.bjpowernode.crm.setting.service.UserService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.ResponseBody;

import javax.servlet.http.Cookie;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;
import java.text.ParseException;
import java.text.SimpleDateFormat;
import java.util.Date;
import java.util.HashMap;
import java.util.Map;

@Controller
public class UserController {

    @RequestMapping("/settings/qx/user/toLogin.do")
    public String login(){
        return "settings/qx/user/login";
    }

    @Autowired
    private UserService userService;





    @RequestMapping("/setting/qx/user/dologin.do")
    @ResponseBody
    public Object doLogin(String loginAct, String loginPwd, String isRemPwd, HttpServletRequest request, HttpSession session, HttpServletResponse response) throws ParseException {
        Map<String,Object> map=new HashMap<>();
        map.put("loginAct",loginAct);
        map.put("loginPwd",loginPwd);
        User user = userService.queryUserByLoginActAndLoginPwd(map);


        ReturnObject returnObject = new ReturnObject();
        if(user==null){
            //登录失败,用户名或者密码不对
            returnObject.setCode("0");
            returnObject.setMessage("账号密码错误");
        }else{
            //用户名密码对了
            //进一步判断
            String date1 =user.getExpireTime();//从数据库获取的时间

            String date2 = DateUtils.formatDateTime(new Date());//系统当前时间

            int i = date2.compareTo(date1);
            if(i>0){
                //登录失败,不在有效期
                returnObject.setCode(Contants.RETURN_OBJECT_CODE_FAIL);
                returnObject.setMessage("账号已过期");
            }else if("0".equals(user.getLockState())){
                //登录失败,被锁定
                returnObject.setCode(Contants.RETURN_OBJECT_CODE_FAIL);
                returnObject.setMessage("账号已锁定");
            }else if(!user.getAllowIps().contains(request.getRemoteAddr())){
                //登录失败,IP不被允许
                returnObject.setCode(Contants.RETURN_OBJECT_CODE_FAIL);
                returnObject.setMessage("IP受限");
            }else {
                //登录成功！！！
                returnObject.setCode(Contants.RETURN_OBJECT_CODE_SUCCESS);

                session.setAttribute(Contants.SESSSION_USER,user);

                //如果记住密码，往浏览器写cookie
                if ("true".equals(isRemPwd)) {
                    Cookie c1 = new Cookie("loginAct",user.getLoginAct());
                    c1.setMaxAge(10*24*60*60);
                    c1.setPath(request.getContextPath());
                    response.addCookie(c1);
                    Cookie c2 = new Cookie("loginPwd",user.getLoginPwd());
                    c2.setMaxAge(10*24*60*60);
                    c2.setPath(request.getContextPath());
                    response.addCookie(c2);
                }else {
                    Cookie c1 = new Cookie("loginAct","1");
                    c1.setPath(request.getContextPath());
                    c1.setMaxAge(0);
                    response.addCookie(c1);
                    Cookie c2 = new Cookie("loginPwd","1");
                    c2.setPath(request.getContextPath());
                    c2.setMaxAge(0);
                    response.addCookie(c2);
                }
            }
        }

        return returnObject;
    }

    @RequestMapping("/settings/qx/user/logout.do")
    public String logout(HttpServletResponse response,HttpSession session,HttpServletRequest request){
        Cookie c1 = new Cookie("loginAct","1");
        c1.setMaxAge(0);
        c1.setPath(request.getContextPath());
        response.addCookie(c1);


        Cookie c2 = new Cookie("loginPwd","1");
        c2.setMaxAge(0);
        c2.setPath(request.getContextPath());
        response.addCookie(c2);


        session.invalidate();
        return "redirect:/";


    }

}
