-- 智慧农业平台数据库初始化脚本
CREATE DATABASE IF NOT EXISTS smart_agri_grape DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
USE smart_agri_grape;

-- 1. 用户表
DROP TABLE IF EXISTS `sys_user`;
CREATE TABLE `sys_user` (
  `id` BIGINT NOT NULL AUTO_INCREMENT COMMENT '主键',
  `username` VARCHAR(50) NOT NULL COMMENT '用户名',
  `password` VARCHAR(100) NOT NULL COMMENT '密码(加密)',
  `real_name` VARCHAR(50) DEFAULT NULL COMMENT '真实姓名',
  `role` VARCHAR(30) NOT NULL COMMENT '角色:admin管理员 / operator操作员 / guest访客',
  `status` TINYINT NOT NULL DEFAULT 1 COMMENT '0禁用 1启用',
  `create_time` DATETIME DEFAULT CURRENT_TIMESTAMP,
  `update_time` DATETIME ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `uk_username` (`username`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='系统用户表';

INSERT INTO sys_user(username,password,real_name,role,status) VALUES
('admin','$2a$10$xxx','管理员','admin',1),
('worker1','$2a$10$xxx','操作员1','operator',0),
('worker2','$2a$10$xxx','操作员2','operator',0),
('guest','$2a$10$xxx','访客','guest',0);

-- 2. 系统配置表(阈值告警与显示设置)
DROP TABLE IF EXISTS `sys_config`;
CREATE TABLE `sys_config` (
  `id` BIGINT NOT NULL AUTO_INCREMENT,
  `config_key` VARCHAR(50) NOT NULL COMMENT '配置键',
  `config_value` VARCHAR(200) NOT NULL COMMENT '配置值',
  `remark` VARCHAR(200) DEFAULT NULL,
  `create_time` DATETIME DEFAULT CURRENT_TIMESTAMP,
  `update_time` DATETIME ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `uk_key` (`config_key`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='系统配置&阈值';

INSERT INTO sys_config(config_key,config_value,remark) VALUES
('temp_max','35','温度上限'),
('hum_min','40','湿度下限%'),
('ph_min','5.5','土壤PH下限'),
('ec_max','80','电导率上限'),
('auto_refresh','1','自动刷新1开启0关闭'),
('sound_alarm','1','声音告警'),
('keep_screen','1','屏幕常亮'),
('auto_clear_log','0','自动清除日志'),
('night_mode','0','夜间模式');

-- 3. 系统日志表
DROP TABLE IF EXISTS `sys_log`;
CREATE TABLE `sys_log` (
  `id` BIGINT NOT NULL AUTO_INCREMENT,
  `log_type` VARCHAR(20) NOT NULL COMMENT '操作|登录|告警|异常|系统',
  `content` VARCHAR(500) NOT NULL COMMENT '日志内容',
  `operator` VARCHAR(50) DEFAULT NULL COMMENT '操作人',
  `create_time` DATETIME DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY idx_ctime(`create_time`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='系统日志表';

INSERT INTO sys_log(log_type,content,operator) VALUES
('系统','平台启动成功','admin'),
('设备','摄像头1上线',NULL),
('水肥','启动1号棚灌溉','admin'),
('告警','土壤PH值偏低','system'),
('用户','admin 登录','admin'),
('设备','传感器数据更新',NULL);

-- 4. 告警记录表
DROP TABLE IF EXISTS `alarm_log`;
CREATE TABLE `alarm_log` (
  `id` BIGINT NOT NULL AUTO_INCREMENT,
  `alarm_type` VARCHAR(50) NOT NULL COMMENT '温度告警/湿度告警/土壤PH告警/电导率告警',
  `device_id` BIGINT DEFAULT NULL COMMENT '设备id',
  `level` TINYINT NOT NULL DEFAULT 2 COMMENT '1紧急 2警告 3提示',
  `is_handle` TINYINT NOT NULL DEFAULT 0 COMMENT '0未处理,1已处理',
  `handle_user` VARCHAR(50) DEFAULT NULL COMMENT '处理人',
  `handle_time` DATETIME DEFAULT NULL,
  `create_time` DATETIME DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY idx_ctime(`create_time`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='告警记录';

INSERT INTO alarm_log(alarm_type,device_id,level,is_handle) VALUES
('温度告警',1,1,0),
('湿度告警',2,2,0),
('土壤PH告警',3,2,1),
('电导率告警',4,3,0);

-- 5. 地块信息表
DROP TABLE IF EXISTS `farm_land`;
CREATE TABLE `farm_land` (
  `id` BIGINT NOT NULL AUTO_INCREMENT,
  `land_name` VARCHAR(50) NOT NULL COMMENT '地块名称:1号地/2号地',
  `area` DECIMAL(10,2) DEFAULT NULL COMMENT '面积(亩)',
  `crop` VARCHAR(50) DEFAULT NULL COMMENT '种植作物',
  `create_time` DATETIME DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='地块信息';

INSERT INTO farm_land(land_name,area,crop) VALUES
('1号地',50.00,'阳光玫瑰'),
('2号地',60.00,'夏黑'),
('3号地',40.00,'巨峰');

-- 6. 葡萄品种表
DROP TABLE IF EXISTS `grape_variety`;
CREATE TABLE `grape_variety` (
  `id` BIGINT NOT NULL AUTO_INCREMENT,
  `name` VARCHAR(50) NOT NULL COMMENT '品种名称',
  `sat_area` INT DEFAULT NULL COMMENT '种植面积(亩)',
  `actual_area` INT DEFAULT NULL COMMENT '实际面积(亩)',
  `rate` DOUBLE DEFAULT NULL COMMENT '增长率(%)',
  `note` VARCHAR(200) DEFAULT NULL COMMENT '备注',
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='葡萄品种';

INSERT INTO grape_variety(name,sat_area,actual_area,rate,note) VALUES
('巨峰',950,885,12.3,'全国第一大主栽品种，农户种植基数大，增速平稳'),
('阳光玫瑰',1000,912,4.7,'前期扩种快，2025年回归理性，主产区均值约910亩'),
('夏黑',850,768,8.1,'早熟优势明显，农户稳定种植，增速合理'),
('红提',900,826,2.3,'传统老品种，种植趋于饱和，同比小幅增长'),
('无核白',800,715,5.4,'新疆主产区主流品种，规模稳定，增速平缓'),
('金手指',650,423,-6.8,'小众特色品种，农户种植意愿下降，面积同比缩减'),
('美人指',600,386,-9.2,'管理成本高、落果严重，面积持续下滑'),
('甜蜜蓝宝石',750,572,1.5,'网红品种热度消退，增速近乎停滞'),
('玫瑰香',700,594,7.6,'香型特色品种，需求回升，农户小幅扩种'),
('青提',800,708,3.9,'早熟平价品种，基础种植量大，同比平稳增长');

-- 7. 农事记录表
DROP TABLE IF EXISTS `farming_record`;
CREATE TABLE `farming_record` (
  `id` BIGINT NOT NULL AUTO_INCREMENT,
  `farming_date` DATE DEFAULT NULL COMMENT '农事日期',
  `type` VARCHAR(50) DEFAULT NULL COMMENT '农事类型',
  `content` VARCHAR(500) DEFAULT NULL COMMENT '内容',
  `person` VARCHAR(50) DEFAULT NULL COMMENT '负责人',
  `land` VARCHAR(50) DEFAULT NULL COMMENT '地块',
  `create_time` DATETIME DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY idx_date(`farming_date`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='农事记录';

INSERT INTO farming_record(farming_date,type,content,person,land) VALUES
('2026-09-05','施肥','施用缓释肥 20kg/亩','张三','1号地'),
('2026-09-04','灌溉','滴灌 2 小时','李四','2号地'),
('2026-09-03','修剪','疏枝修剪','王五','3号地');

-- 8. 环境数据表
DROP TABLE IF EXISTS `env_data`;
CREATE TABLE `env_data` (
  `id` BIGINT NOT NULL AUTO_INCREMENT,
  `temp` DECIMAL(6,2) DEFAULT NULL COMMENT '温度',
  `humidity` DECIMAL(6,2) DEFAULT NULL COMMENT '湿度',
  `pm25` INT DEFAULT NULL COMMENT 'PM2.5',
  `pm10` INT DEFAULT NULL COMMENT 'PM10',
  `soil_ph` DECIMAL(6,2) DEFAULT NULL COMMENT '土壤PH',
  `ec` DECIMAL(6,2) DEFAULT NULL COMMENT '电导率',
  `wind_dir` VARCHAR(20) DEFAULT NULL COMMENT '风向',
  `wind_speed` DECIMAL(6,2) DEFAULT NULL COMMENT '风速',
  `device_id` BIGINT DEFAULT NULL COMMENT '设备id',
  `collect_time` DATETIME DEFAULT CURRENT_TIMESTAMP COMMENT '采集时间',
  PRIMARY KEY (`id`),
  KEY idx_ctime(`collect_time`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='环境数据';

INSERT INTO env_data(temp,humidity,pm25,pm10,soil_ph,ec,wind_dir,wind_speed,device_id,collect_time) VALUES
(28.50,65.00,35,60,6.50,55.00,'东南风',2.50,1,'2026-09-07 10:00:00'),
(29.00,62.00,38,65,6.30,58.00,'东风',3.00,1,'2026-09-07 11:00:00'),
(30.00,60.00,40,70,6.40,60.00,'东北风',2.80,1,'2026-09-07 12:00:00');
