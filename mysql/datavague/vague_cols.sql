-- 混淆函数设计
-- 需要参数
-- 库名，表名，列名和混淆规则键值对
-- 逻辑处理  （首先需要先做表备份，以_bak为后缀，然后进行对应混淆处理）
-- 键值对以以下形式出现 col1:C,col2:P...
-- 调用方式： CALL vague_cols('test','erp_finance_request_bill','supplier:C,account:C,total_amount:M,bank_deposit:C');
-- 依赖： 如之前存在_bak同名表则报错

DELIMITER |
DROP PROCEDURE vague_cols|
CREATE PROCEDURE vague_cols(IN sch_name VARCHAR(50),IN tab_name VARCHAR(50),IN col_rule VARCHAR(200))
BEGIN
DECLARE co_num INT;
DECLARE ch_pos INT;
DECLARE need_do VARCHAR(100);
DECLARE col_name VARCHAR(50);
DECLARE va_rule CHAR(1);

-- backup table
 
 SET @sql_create=CONCAT('CREATE TABLE ',sch_name,'.',tab_name,'_bak LIKE ',sch_name,'.',tab_name);
 SELECT @sql_create;
 PREPARE stmt1 FROM @sql_create;
 EXECUTE  stmt1;
 DEALLOCATE PREPARE stmt1;
 
 SET @sql_insert=CONCAT('INSERT INTO ',sch_name,'.',tab_name,'_bak SELECT * FROM ',sch_name,'.',tab_name);
 SELECT @sql_insert;
 PREPARE stmt2 FROM @sql_insert;
 EXECUTE  stmt2;
 DEALLOCATE PREPARE stmt2;


-- 解析col_rule,get the ',' number
SELECT LENGTH(col_rule)-LENGTH(REPLACE(col_rule,',','')) INTO co_num;

WHILE co_num>=0 DO
-- select co_num;
SELECT SUBSTRING_INDEX(col_rule,',',1) INTO need_do ;
SELECT INSTR(col_rule,',') INTO ch_pos;
SELECT SUBSTRING(col_rule FROM ch_pos+1) INTO col_rule;

-- select need_do,col_rule;
SELECT INSTR(need_do,':') INTO ch_pos;
SELECT SUBSTRING(need_do,1,ch_pos-1) INTO col_name;
SELECT SUBSTRING(need_do FROM ch_pos+1) INTO va_rule;
-- SELECT col_name,va_rule;
SET co_num = co_num - 1;

-- 分支混淆处理

CASE va_rule  
            WHEN 'C' THEN 
                -- 字符串替换 目前简单置为SOUNDEX值,如果是NULL设置为'UNKNOWN'
                 SET @sql_update=CONCAT('UPDATE ',tab_name,' SET ',col_name,'=IF(',col_name,' IS NULL,\'UNKNOWN\',SOUNDEX(',col_name,'))');
                 SELECT @sql_update;
                 PREPARE stmt FROM @sql_update;
                 EXECUTE  stmt;
                 DEALLOCATE PREPARE stmt;
            --    update tab_name SET col_name=IF(col_name IS NULL,'UNKNOWN',SOUNDEX(col_name));
            WHEN 'N' THEN 
               -- 姓名字符串--第二位之后都以’某‘替换,如果是NULL设置为‘无名氏’
                 SET @sql_update=CONCAT('UPDATE ',tab_name,' SET ',col_name,'=IF(',col_name,' IS NULL,\'无名氏\',REPLACE(',col_name,',SUBSTRING(',col_name,',2),REPEAT(\'某\',CHAR_LENGTH(',col_name,')-1)))');
                 SELECT @sql_update;
                 PREPARE stmt FROM @sql_update;
                 EXECUTE  stmt;
                 DEALLOCATE PREPARE stmt;
                -- update tab_name set col_name=IF(col_name IS NULL,'无名氏',REPLACE(col_name,SUBSTRING(col_name,2),REPEAT('某', CHAR_LENGTH(col_name)-1))); 
                
            WHEN 'M' THEN 
                -- 金额数字--1-5倍相乘，如果是NULL，设置为100 
                 SET @sql_update=CONCAT('UPDATE ',tab_name,' SET ',col_name,'=IF(',col_name,' IS NULL,100,',col_name,'*FLOOR(RAND()*5+1))');
                 SELECT @sql_update;
                 PREPARE stmt FROM @sql_update;
                 EXECUTE  stmt;
                 DEALLOCATE PREPARE stmt;
               -- UPDATE tab_name set col_name=IF(col_name IS NULL,100,col_name*floor(rand()*5+1));
                
            -- WHEN 'I' THEN  
            -- 账号数字--首尾调换，再翻转 ，如果是NULL，设置为9999 
            -- TODO

            WHEN 'P' THEN
                 -- 电话号码数字--对换开头4位和余下的字符串的位置，如果是NULL，不变
                 SET @sql_update=CONCAT('UPDATE ',tab_name,' SET ',col_name,'=concat(substring(',col_name,' FROM 5),substring(',col_name,',1,4))');
                 SELECT @sql_update;
                 PREPARE stmt FROM @sql_update;
                 EXECUTE  stmt;
                 DEALLOCATE PREPARE stmt;
                 -- UPDATE tab_name SET col_name=concat(substring(col_name FROM 5),substring(col_name,1,4));
        END CASE;         
END WHILE;

END|
DELIMITER ;

