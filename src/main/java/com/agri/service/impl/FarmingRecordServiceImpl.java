package com.agri.service.impl;

import com.agri.entity.FarmingRecord;
import com.agri.mapper.FarmingRecordMapper;
import com.agri.service.FarmingRecordService;
import com.baomidou.mybatisplus.extension.service.impl.ServiceImpl;
import org.springframework.stereotype.Service;

@Service
public class FarmingRecordServiceImpl extends ServiceImpl<FarmingRecordMapper, FarmingRecord> implements FarmingRecordService {
}
