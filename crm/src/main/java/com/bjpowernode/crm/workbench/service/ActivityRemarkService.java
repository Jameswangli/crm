package com.bjpowernode.crm.workbench.service;

import com.bjpowernode.crm.workbench.domain.ActivityRemark;

import java.util.List;

public interface ActivityRemarkService {

    /**
     * @param null:
     * @return null
     * @author wl
     * @description TODO 使用市场活动的id查询全部备注
     * @date 2022/7/27 10:21
     */
    List<ActivityRemark> queryActivityRemarkForDetailByActivityId(String activityId);

    /**
     * @param remark:
     * @return int
     * @author wl
     * @description TODO 添加市场活动备注
     * @date 2022/7/27 10:22
     */
    int saveActivityRemark(ActivityRemark remark);

    int deleteActivityRemark(String id);

    int saveEditActivityRemark(ActivityRemark remark);
}
