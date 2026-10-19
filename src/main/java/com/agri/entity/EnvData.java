package com.agri.entity;

import com.baomidou.mybatisplus.annotation.IdType;
import com.baomidou.mybatisplus.annotation.TableId;
import com.baomidou.mybatisplus.annotation.TableName;
import lombok.Data;

import java.math.BigDecimal;
import java.time.LocalDateTime;

@Data
@TableName("env_data")
public class EnvData {
    @TableId(type = IdType.AUTO)
    private Long id;
    private BigDecimal temp;        // 温度
    private BigDecimal humidity;    // 湿度
    private Integer pm25;
    private Integer pm10;
    private BigDecimal soilPh;      // 土壤PH
    private BigDecimal ec;          // 电导率
    private String windDir;
    private BigDecimal windSpeed;
    private Long deviceId;
    private LocalDateTime collectTime;
}
