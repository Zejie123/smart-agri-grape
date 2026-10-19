package com.agri.entity;

import com.baomidou.mybatisplus.annotation.IdType;
import com.baomidou.mybatisplus.annotation.TableId;
import com.baomidou.mybatisplus.annotation.TableName;
import lombok.Data;

import java.time.LocalDateTime;

@Data
@TableName("alarm_log")
public class AlarmLog {
    @TableId(type = IdType.AUTO)
    private Long id;
    private String alarmType;
    private Long deviceId;
    private Integer level;
    private Integer isHandle;
    private String handleUser;
    private LocalDateTime handleTime;
    private LocalDateTime createTime;
}
