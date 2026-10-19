package com.agri.service.impl;

import com.agri.entity.SysConfig;
import com.agri.mapper.SysConfigMapper;
import com.agri.service.SysConfigService;
import com.baomidou.mybatisplus.extension.service.impl.ServiceImpl;
import org.springframework.stereotype.Service;

@Service
public class SysConfigServiceImpl extends ServiceImpl<SysConfigMapper, SysConfig> implements SysConfigService {
}
