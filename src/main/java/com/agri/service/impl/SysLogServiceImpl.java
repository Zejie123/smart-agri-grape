package com.agri.service.impl;

import com.agri.entity.SysLog;
import com.agri.mapper.SysLogMapper;
import com.agri.service.SysLogService;
import com.baomidou.mybatisplus.extension.service.impl.ServiceImpl;
import org.springframework.stereotype.Service;

@Service
public class SysLogServiceImpl extends ServiceImpl<SysLogMapper, SysLog> implements SysLogService {
}
