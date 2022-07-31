package com.bjpowernode.crm.setting.service;

import com.bjpowernode.crm.setting.domain.User;

import java.util.List;
import java.util.Map;

public interface UserService {

    User queryUserByLoginActAndLoginPwd(Map<String,Object> map);

    List<User> queryAllUsers();
}
