package com.agri.service.impl;

import com.agri.entity.SysUser;
import com.agri.mapper.SysUserMapper;
import com.agri.service.SysUserService;
import com.baomidou.mybatisplus.extension.service.impl.ServiceImpl;
import org.springframework.stereotype.Service;

@Service
public class SysUserServiceImpl extends ServiceImpl<SysUserMapper, SysUser> implements SysUserService {
}
