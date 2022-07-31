package com.bjpowernode.crm.setting.service.impl;

import com.bjpowernode.crm.setting.domain.User;
import com.bjpowernode.crm.setting.mapper.UserMapper;
import com.bjpowernode.crm.setting.service.UserService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.util.List;
import java.util.Map;

@Service("userService")
public class UserServiceImpl implements UserService {

    @Autowired
    private UserMapper userMapper;

    @Override
    public User queryUserByLoginActAndLoginPwd(Map<String, Object> map) {
        return userMapper.selectUserByLoginActAndPwd(map);
    }

    @Override
    public List<User> queryAllUsers() {
        return userMapper.selectAllUsers();
    }
}
