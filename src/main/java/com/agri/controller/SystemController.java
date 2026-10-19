package com.agri.controller;

import com.agri.common.Result;
import com.agri.entity.EnvData;
import com.agri.entity.SysLog;
import com.agri.entity.SysUser;
import com.agri.service.EnvDataService;
import com.agri.service.SysLogService;
import com.agri.service.SysUserService;
import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import javax.annotation.Resource;
import java.util.List;

@RestController
@RequestMapping("/system")
public class SystemController {

    @Resource
    private SysUserService sysUserService;

    @Resource
    private SysLogService sysLogService;

    @Resource
    private EnvDataService envDataService;

    /**
     * 用户列表
     */
    @GetMapping("/user/list")
    public Result<List<SysUser>> getUserList() {
        return Result.success(sysUserService.list());
    }

    /**
     * 系统日志列表（最近 50 条）
     */
    @GetMapping("/log/list")
    public Result<List<SysLog>> getLogList() {
        Page<SysLog> page = sysLogService.page(
                new Page<>(1, 50),
                new LambdaQueryWrapper<SysLog>().orderByDesc(SysLog::getCreateTime)
        );
        return Result.success(page.getRecords());
    }

    /**
     * 最新一条环境数据
     */
    @GetMapping("/env/latest")
    public Result<EnvData> getEnvLatest() {
        EnvData latest = envDataService.getOne(
                new LambdaQueryWrapper<EnvData>()
                        .orderByDesc(EnvData::getCollectTime)
                        .last("LIMIT 1"),
                false
        );
        return Result.success(latest);
    }
}
