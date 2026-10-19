package com.agri.entity;

import com.baomidou.mybatisplus.annotation.IdType;
import com.baomidou.mybatisplus.annotation.TableId;
import com.baomidou.mybatisplus.annotation.TableName;
import lombok.Data;

@Data
@TableName("grape_variety")
public class GrapeVariety {
    @TableId(type = IdType.AUTO)
    private Long id;
    private String name;
    private Integer satArea;     // 种植面积(亩)
    private Integer actualArea;  // 实际面积(亩)
    private Double rate;         // 增长率(%)
    private String note;         // 备注
}
