package com.agri.entity;

import com.baomidou.mybatisplus.annotation.IdType;
import com.baomidou.mybatisplus.annotation.TableId;
import com.baomidou.mybatisplus.annotation.TableName;
import lombok.Data;

import java.time.LocalDate;
import java.time.LocalDateTime;

@Data
@TableName("farming_record")
public class FarmingRecord {
    @TableId(type = IdType.AUTO)
    private Long id;
    private LocalDate farmingDate;
    private String type;
    private String content;
    private String person;
    private String land;
    private LocalDateTime createTime;
}
