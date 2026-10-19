package com.agri.entity;

import com.baomidou.mybatisplus.annotation.IdType;
import com.baomidou.mybatisplus.annotation.TableId;
import com.baomidou.mybatisplus.annotation.TableName;
import lombok.Data;

import java.time.LocalDateTime;

@Data
@TableName("sys_log")
public class SysLog {
    @TableId(type = IdType.AUTO)
    private Long id;
    private String logType;      // 操作|登录|告警|异常|系统
    private String content;      // 日志内容
    private String operator;     // 操作人
    private LocalDateTime createTime;
}
