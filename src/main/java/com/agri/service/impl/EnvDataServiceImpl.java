package com.agri.service.impl;

import com.agri.entity.EnvData;
import com.agri.mapper.EnvDataMapper;
import com.agri.service.EnvDataService;
import com.baomidou.mybatisplus.extension.service.impl.ServiceImpl;
import org.springframework.stereotype.Service;

@Service
public class EnvDataServiceImpl extends ServiceImpl<EnvDataMapper, EnvData> implements EnvDataService {
}
