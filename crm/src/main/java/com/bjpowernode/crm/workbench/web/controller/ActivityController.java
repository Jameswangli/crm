package com.bjpowernode.crm.workbench.web.controller;

import com.bjpowernode.crm.commons.domain.ReturnObject;
import com.bjpowernode.crm.commons.utils.Contants;
import com.bjpowernode.crm.commons.utils.DateUtils;
import com.bjpowernode.crm.commons.utils.HSSFUtils;
import com.bjpowernode.crm.commons.utils.UUIDUtils;
import com.bjpowernode.crm.setting.domain.User;
import com.bjpowernode.crm.setting.service.UserService;
import com.bjpowernode.crm.workbench.domain.Activity;
import com.bjpowernode.crm.workbench.domain.ActivityRemark;
import com.bjpowernode.crm.workbench.service.ActivityRemarkService;
import com.bjpowernode.crm.workbench.service.ActivityService;
import org.apache.poi.hssf.usermodel.HSSFCell;
import org.apache.poi.hssf.usermodel.HSSFRow;
import org.apache.poi.hssf.usermodel.HSSFSheet;
import org.apache.poi.hssf.usermodel.HSSFWorkbook;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.ResponseBody;
import org.springframework.web.multipart.MultipartFile;

import javax.servlet.ServletOutputStream;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;
import java.io.*;
import java.util.*;

@Controller
public class ActivityController {

    @Autowired
    private ActivityService activityService;

    @Autowired
    private UserService userService;

    @Autowired
    private ActivityRemarkService activityRemarkService;



    @RequestMapping("/workbench/activity/index.do")
    public String index(HttpServletRequest request){
        List<User> list=userService.queryAllUsers();
        request.setAttribute("list",list);
        return "workbench/activity/index";
    }

    @RequestMapping("/workbench/activity/saveCreatActivity.do")
    @ResponseBody
    public Object saveCreatActivity(Activity activity, HttpSession session){

        User user = (User) session.getAttribute(Contants.SESSSION_USER);

        //设置前端没有传过来的activity类的属性
        activity.setId(UUIDUtils.getUUID());
        activity.setCreateTime(DateUtils.formatDateTime(new Date()));
        activity.setCreateBy(user.getId());



        ReturnObject returnObject=new ReturnObject();

        try{
            int ret = activityService.saveCreatActivity(activity);
            if (ret>0) {
                returnObject.setCode(Contants.RETURN_OBJECT_CODE_SUCCESS);
            }else {
                returnObject.setCode(Contants.RETURN_OBJECT_CODE_FAIL);
                returnObject.setMessage("系统忙，请稍后重试！！！");
            }
        }catch (Exception e){
            e.printStackTrace();
            returnObject.setCode(Contants.RETURN_OBJECT_CODE_FAIL);
            returnObject.setMessage("系统忙，请稍后重试！！！");
        }
        return returnObject;
    }

    @RequestMapping("/workbench/activity/select.do")
    @ResponseBody
    public Object select(String name,String owner,String startDate,String endDate,int pageNo,int pageSize){
        Map<String,Object> map=new HashMap<>();
        map.put("name",name);
        map.put("owner",owner);
        map.put("startDate",startDate);
        map.put("endDate",endDate);
        map.put("beginNo",(pageNo-1)*pageSize);
        map.put("pageSize",pageSize);

        List<Activity> activities = activityService.queryActivityByConditionForPage(map);
        Integer totalRows =activityService.queryCountOfActivityByCondition(map);

        Map<String,Object> retMap=new HashMap<>();
        retMap.put("activities",activities);
        retMap.put("totalRows",totalRows);

        return retMap;

    }


    @RequestMapping("/workbench/activity/deleteActivityById.do")
    @ResponseBody
    public Object deleteActivityById(String[] id){
        ReturnObject returnObject=new ReturnObject();
        try{
            int i = activityService.deleteActivityById(id);
            if(i==id.length){
                returnObject.setCode(Contants.RETURN_OBJECT_CODE_SUCCESS);
            }else {
                returnObject.setCode(Contants.RETURN_OBJECT_CODE_FAIL);
                returnObject.setMessage("系统繁忙请稍后再试");

            }
        }catch (Exception e){
            e.printStackTrace();
            returnObject.setCode(Contants.RETURN_OBJECT_CODE_FAIL);
            returnObject.setMessage("系统繁忙请稍后再试");

        }

        return returnObject;
    }

    @RequestMapping("/workbench/activity/selectActivityById.do")
    @ResponseBody
    public Object selectActivityById(String id){
        Activity activity = activityService.queryActivityById(id);
        return activity;//自动转为json
    }

    @RequestMapping("/workbench/activity/updateActivityById.do")
    @ResponseBody
    public Object updateActivityById(Activity activity,HttpSession session){
        ReturnObject returnObject=new ReturnObject();
        User user = (User) session.getAttribute(Contants.SESSSION_USER);
        activity.setEditBy(user.getId());
        activity.setEditTime(DateUtils.formatDateTime(new Date()));


        try{
            int i = activityService.editActivityById(activity);
            if (i==1) {
                returnObject.setCode(Contants.RETURN_OBJECT_CODE_SUCCESS);
            }else {
                returnObject.setCode(Contants.RETURN_OBJECT_CODE_FAIL);
                returnObject.setMessage("系统繁忙，请稍后重试！！！");
            }
        }catch (Exception e){
            e.printStackTrace();
            returnObject.setCode(Contants.RETURN_OBJECT_CODE_FAIL);
            returnObject.setMessage("系统繁忙，请稍后重试！！！");
        }

        return returnObject;
    }

    @RequestMapping("/workbench/activity/fileDownLoad.do")
    public void fileDownLoad(HttpServletResponse response) throws IOException {
        //1、设置响应类型
        response.setContentType("application/octet-stream;charset=utf-8");
        //2、获取输出流
        OutputStream out=response.getOutputStream();
        //设置响应头信息，是浏览器接受到响应信息之后，直接激活文件下载窗口，及时能打开也不打开
        response.addHeader("Content-Disposition","attachment;filename=mystudentList.xls");
        //3、读取文件
        InputStream is = new FileInputStream("D:\\JAVA\\SSM-CRM\\serviceDir\\myList.xls");
        //4、输出文件
        byte[] buff=new byte[256];
        int len=0;
        while ((len=is.read(buff))!=-1){
            out.write(buff,0,len);
        }
        is.close();
        out.flush();
    }

    @RequestMapping("/workbench/activity/exportllActivity.do")
    public void exportllActivity(HttpServletResponse response) throws IOException {

        List<Activity> activityList=activityService.queryAllActivity();


        HSSFWorkbook wb = new HSSFWorkbook();

        HSSFSheet sheet = wb.createSheet("市场活动列表");
        HSSFRow row = sheet.createRow(0);
        HSSFCell cell = row.createCell(0);
        cell.setCellValue("ID");
        cell= row.createCell(1);
        cell.setCellValue("所有者");
        cell= row.createCell(2);
        cell.setCellValue("名称");
        cell= row.createCell(3);
        cell.setCellValue("开始时间");
        cell= row.createCell(4);
        cell.setCellValue("结束时间");
        cell= row.createCell(5);
        cell.setCellValue("成本");
        cell= row.createCell(6);
        cell.setCellValue("描述");
        cell= row.createCell(7);
        cell.setCellValue("创建时间");
        cell= row.createCell(8);
        cell.setCellValue("创建人");
        cell= row.createCell(9);
        cell.setCellValue("修改时间");
        cell= row.createCell(10);
        cell.setCellValue("修改人");
        Activity activity;
        if(activityList !=null && activityList.size()>0){
            for(int i=0;i<activityList.size();i++){
                activity= activityList.get(i);
                row = sheet.createRow(i+1);
                cell = row.createCell(0);
                cell.setCellValue(activity.getId());
                cell= row.createCell(1);
                cell.setCellValue(activity.getOwner());
                cell= row.createCell(2);
                cell.setCellValue(activity.getName());
                cell= row.createCell(3);
                cell.setCellValue(activity.getStartDate());
                cell= row.createCell(4);
                cell.setCellValue(activity.getEndDate());
                cell= row.createCell(5);
                cell.setCellValue(activity.getCost());
                cell= row.createCell(6);
                cell.setCellValue(activity.getDescription());
                cell= row.createCell(7);
                cell.setCellValue(activity.getCreateTime());
                cell= row.createCell(8);
                cell.setCellValue(activity.getCreateBy());
                cell= row.createCell(9);
                cell.setCellValue(activity.getEditTime());
                cell= row.createCell(10);
                cell.setCellValue(activity.getEditBy());
            }
        }


        response.setContentType("application/octet-stream;charset=UTF-8");
        response.addHeader("Content-Disposition", "attachment;filename=activityList.xls");
        OutputStream out= response.getOutputStream();

        wb.write(out);
        wb.close();
        out.flush();
    }

    @RequestMapping("/workbench/activity/downLoadById.do")
    public void downLoadById(String[] id,HttpServletResponse response) throws IOException {
        List<Activity> activityList = activityService.downLoadActivityById(id);


        HSSFWorkbook wb = new HSSFWorkbook();

        HSSFSheet sheet = wb.createSheet("市场活动列表");
        HSSFRow row = sheet.createRow(0);
        HSSFCell cell = row.createCell(0);
        cell.setCellValue("ID");
        cell= row.createCell(1);
        cell.setCellValue("所有者");
        cell= row.createCell(2);
        cell.setCellValue("名称");
        cell= row.createCell(3);
        cell.setCellValue("开始时间");
        cell= row.createCell(4);
        cell.setCellValue("结束时间");
        cell= row.createCell(5);
        cell.setCellValue("成本");
        cell= row.createCell(6);
        cell.setCellValue("描述");
        cell= row.createCell(7);
        cell.setCellValue("创建时间");
        cell= row.createCell(8);
        cell.setCellValue("创建人");
        cell= row.createCell(9);
        cell.setCellValue("修改时间");
        cell= row.createCell(10);
        cell.setCellValue("修改人");
        Activity activity;
        if(activityList !=null && activityList.size()>0){
            for(int i=0;i<activityList.size();i++){
                activity= activityList.get(i);
                row = sheet.createRow(i+1);
                cell = row.createCell(0);
                cell.setCellValue(activity.getId());
                cell= row.createCell(1);
                cell.setCellValue(activity.getOwner());
                cell= row.createCell(2);
                cell.setCellValue(activity.getName());
                cell= row.createCell(3);
                cell.setCellValue(activity.getStartDate());
                cell= row.createCell(4);
                cell.setCellValue(activity.getEndDate());
                cell= row.createCell(5);
                cell.setCellValue(activity.getCost());
                cell= row.createCell(6);
                cell.setCellValue(activity.getDescription());
                cell= row.createCell(7);
                cell.setCellValue(activity.getCreateTime());
                cell= row.createCell(8);
                cell.setCellValue(activity.getCreateBy());
                cell= row.createCell(9);
                cell.setCellValue(activity.getEditTime());
                cell= row.createCell(10);
                cell.setCellValue(activity.getEditBy());
            }
        }


        response.setContentType("application/octet-stream;charset=UTF-8");
        response.addHeader("Content-Disposition", "attachment;filename=activityListById.xls");
        OutputStream out= response.getOutputStream();

        wb.write(out);
        wb.close();
        out.flush();
    }

    @RequestMapping("/workbench/activity/upLoad.do")
    public String upLoad(String mytext, MultipartFile myFile) throws IOException {

        System.out.println(mytext);

        String originalFilename = myFile.getOriginalFilename();
        File file=new File("D:\\JAVA\\SSM-CRM\\upLoad\\"+originalFilename);
        myFile.transferTo(file);

        System.out.println("ddddddd");
        return "workbench/index";
    }

    @RequestMapping("/workbench/activity/importActivity.do")
    @ResponseBody
    public Object importActivity(MultipartFile activityFile,String userName,HttpSession session){
        System.out.println(userName);
        User user= (User) session.getAttribute(Contants.SESSSION_USER);
        ReturnObject returnObject=new ReturnObject();
        try {
            /*
            把文件写入磁盘
            String originalFilename = activityFile.getOriginalFilename();
            File file=new File("D:\\JAVA\\SSM-CRM\\upLoad\\"+originalFilename);
            activityFile.transferTo(file);

            InputStream is = new FileInputStream("D:\\JAVA\\SSM-CRM\\upLoad\\" + originalFilename);*/

            InputStream is = activityFile.getInputStream();
            HSSFWorkbook wb = new HSSFWorkbook(is);
            HSSFSheet sheet = wb.getSheetAt(0);


            List<Activity> activityList=new ArrayList<>();
            Activity activity=null;
            HSSFRow row=null;
            HSSFCell cell=null;
            for(int i=1;i<=sheet.getLastRowNum();i++){
                row = sheet.getRow(i);
                activity=new Activity();
                activity.setId(UUIDUtils.getUUID());
                activity.setOwner(user.getId());
                activity.setCreateTime(DateUtils.formatDateTime(new Date()));
                activity.setCreateBy(user.getId());
                for (int j = 0; j < row.getLastCellNum(); j++) {
                    //根据列的下标,得到每一列
                    cell = row.getCell(j);
                    //利用工具类，取出，每一列的值
                    String cellValue = HSSFUtils.getCellValueForstr(cell);
                    if(j==0){
                        activity.setName(cellValue);
                    }else if(j==1){
                        activity.setStartDate(cellValue);
                    }else if(j==2){
                        activity.setEndDate(cellValue);
                    }else if(j==3){
                        activity.setCost(cellValue);
                    }else if(j==4){
                        activity.setDescription(cellValue);
                    }
                }
                activityList.add(activity);
                System.out.println("sgddsgsdgsdgsg");
            }
            int ret = activityService.saveCreatActivityById(activityList);

            returnObject.setCode(Contants.RETURN_OBJECT_CODE_SUCCESS);
            returnObject.setRetData(ret);
        } catch (IOException e) {
            e.printStackTrace();
            returnObject.setCode(Contants.RETURN_OBJECT_CODE_FAIL);
            returnObject.setMessage("系统繁忙请稍后访问");
        }
        System.out.println("dasdadasdaetwertr6tertyerdyhrftrhryfuryut5yt");

        return returnObject;
    }

    @RequestMapping("/workbench/activity/detailActivity.do")
    public String detailActivity(String id,HttpServletRequest request){
        Activity activity = activityService.queryActivityForDetailById(id);
        List<ActivityRemark> activityRemarks = activityRemarkService.queryActivityRemarkForDetailByActivityId(id);

        request.setAttribute("activity",activity);
        request.setAttribute("activityRemarks",activityRemarks);

        return "workbench/activity/detail";
    }
}










