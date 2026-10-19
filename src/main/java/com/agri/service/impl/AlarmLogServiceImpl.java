package com.agri.service.impl;

import com.agri.entity.AlarmLog;
import com.agri.mapper.AlarmLogMapper;
import com.agri.service.AlarmLogService;
import com.baomidou.mybatisplus.extension.service.impl.ServiceImpl;
import org.springframework.stereotype.Service;

@Service
public class AlarmLogServiceImpl extends ServiceImpl<AlarmLogMapper, AlarmLog> implements AlarmLogService {
}
