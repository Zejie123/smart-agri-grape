package com.agri.controller;

import com.agri.common.Result;
import com.agri.entity.AlarmLog;
import com.agri.entity.FarmingRecord;
import com.agri.entity.GrapeVariety;
import com.agri.entity.SysConfig;
import com.agri.service.AlarmLogService;
import com.agri.service.FarmingRecordService;
import com.agri.service.GrapeVarietyService;
import com.agri.service.SysConfigService;
import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.web.bind.annotation.*;

import javax.annotation.Resource;
import java.util.List;

@RestController
@RequestMapping("/dashboard")
public class DashboardController {

    @Resource
    private GrapeVarietyService grapeVarietyService;

    @Resource
    private FarmingRecordService farmingRecordService;

    @Resource
    private SysConfigService sysConfigService;

    @Resource
    private AlarmLogService alarmLogService;

    /**
     * 葡萄品种列表（品种占比）
     */
    @GetMapping("/grape/list")
    public Result<List<GrapeVariety>> getGrapeList() {
        List<GrapeVariety> list = grapeVarietyService.list();
        return Result.success(list);
    }

    /**
     * 农事记录列表
     */
    @GetMapping("/farming/list")
    public Result<List<FarmingRecord>> farmingList() {
        LambdaQueryWrapper<FarmingRecord> wrapper = new LambdaQueryWrapper<>();
        wrapper.orderByDesc(FarmingRecord::getFarmingDate);
        return Result.success(farmingRecordService.list(wrapper));
    }

    /**
     * 新增农事记录
     */
    @PostMapping("/farming/add")
    public Result<String> addFarming(@RequestBody FarmingRecord record) {
        if (record == null || record.getFarmingDate() == null
                || record.getContent() == null || record.getContent().trim().isEmpty()) {
            return Result.fail("农事日期和内容不能为空");
        }
        boolean save = farmingRecordService.save(record);
        if (save) {
            return Result.success("保存成功");
        }
        return Result.fail("保存失败");
    }

    /**
     * 系统配置列表
     */
    @GetMapping("/config/list")
    public Result<List<SysConfig>> getConfig() {
        return Result.success(sysConfigService.list());
    }

    /**
     * 保存配置（不存在则插入，存在则更新）
     */
    @PostMapping("/config/save")
    @Transactional(rollbackFor = Exception.class)
    public Result<String> saveConfig(@RequestBody List<SysConfig> configList) {
        if (configList == null || configList.isEmpty()) {
            return Result.fail("配置不能为空");
        }
        for (SysConfig cfg : configList) {
            SysConfig exist = sysConfigService.getOne(
                    new LambdaQueryWrapper<SysConfig>().eq(SysConfig::getConfigKey, cfg.getConfigKey()),
                    false
            );
            if (exist != null) {
                exist.setConfigValue(cfg.getConfigValue());
                exist.setRemark(cfg.getRemark());
                sysConfigService.updateById(exist);
            } else {
                sysConfigService.save(cfg);
            }
        }
        return Result.success("保存成功");
    }

    /**
     * 最新告警，最多12条
     */
    @GetMapping("/alarm/latest")
    public Result<List<AlarmLog>> getLatestAlarm() {
        Page<AlarmLog> page = alarmLogService.page(
                new Page<>(1, 12),
                new LambdaQueryWrapper<AlarmLog>().orderByDesc(AlarmLog::getCreateTime)
        );
        return Result.success(page.getRecords());
    }

    /**
     * 清除告警：清空所有告警记录
     */
    @PostMapping("/alarm/clear")
    public Result<String> clearAlarm() {
        alarmLogService.remove(new LambdaQueryWrapper<>());
        return Result.success("清除成功");
    }
}
