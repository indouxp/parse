#!/bin/sh

cat <<EOT > run-test-3.1.sql
-- バッファ・キャッシュと共有プールにキャッシュされている情報をクリア
alter system flush shared_pool ;
exit 0
EOT

sqlplus / as sysdba @ ./run-test-3.1.sql

# リテラルのSELECT文を10000回連続実行
time ( date ; for i in `seq 1 10000`; do
                echo "select * from TAB36 where COL1=${i} ;"
              done | sqlplus TRY/TRY > /dev/null ; date )

cat <<EOT > run-test-3.2.sql
-- 実行計画が作成されたSQLの合計数
select count(*) from V\$SQL where SQL_TEXT like 'select * from TAB36 where COL1=%' ;
exit 0
EOT

sqlplus / as sysdba @ ./run-test-3.2.sql