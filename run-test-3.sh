#!/bin/sh
BASE=${0##*/}
BASE=${BASE%.*}
LOG=${0##*/}.log

cat <<EOT > ./sql.d/${BASE:?}.1.sql
set echo on
-- バッファ・キャッシュと共有プールにキャッシュされている情報をクリア
alter system flush shared_pool ;
exit 0
EOT

sqlplus / as sysdba @ ./sql.d/${BASE:?}.1.sql | tee ${LOG:?}

# リテラルのSELECT文を10000回連続実行
time ( date ; for i in `seq 1 10000`; do
                echo "variable B1 number"
                echo "execute :B1 := ${i}"
                echo "select * from TAB36 where COL1=:B1 ;"
              done | sqlplus TRY/TRY > /dev/null ; date ) >> ${LOG:?} 2>&1

cat <<EOT > ./sql.d/${BASE:?}.2.sql
set echo on
-- 実行計画が作成されたSQLの合計数
select count(*) from V\$SQL where SQL_TEXT like 'select * from TAB36 where COL1=%' ;
exit 0
EOT

sqlplus / as sysdba @ ./sql.d/${BASE:?}.2.sql | tee -a ${LOG:?}
