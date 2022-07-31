package com.bjpowernode.crm.workbench.service;

import com.bjpowernode.crm.workbench.domain.Activity;

import java.util.List;
import java.util.Map;

public interface ActivityService {

    int saveCreatActivity(Activity activity);

    List<Activity> queryActivityByConditionForPage(Map<String,Object> map);

    Integer queryCountOfActivityByCondition(Map<String,Object> map);

    int deleteActivityById(String[] ids);

    Activity queryActivityById(String id);

    int editActivityById(Activity activity);

    List<Activity> queryAllActivity();

    List<Activity> downLoadActivityById(String[] ids);

    int saveCreatActivityById(List<Activity> activities);

    Activity queryActivityForDetailById(String id);
}
