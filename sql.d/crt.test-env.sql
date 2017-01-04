-- TBS36表領域と、この表領域をデフォルト表領域とするTRYユーザーの作成
create tablespace TBS36 datafile '/u01/app/oracle/oradata/db11g/tbs36.dbf' size 512M ;
create user TRY identified by TRY default tablespace TBS36 ;
grant connect, resource, dba to TRY ;

connect TRY/TRY

-- TAB36表の作成
create table TAB36 (COL1 number NOT NULL, COL2 number, COL3 char(100)) ;

-- TAB36表へレコード100万件を挿入
declare
  intNum_COL1 number := 0 ;
  intInterval number := 10000 ;
begin
  for i in 1..100 loop
    insert into TAB36 select LEVEL + intNum_COL1, i , rpad('A',100,i)
                        from DUAL connect by LEVEL <= intInterval ;
    commit ;
    intNum_COL1 := intNum_COL1 + intInterval ;
  end loop ;
end ;
/

-- TAB36表のCOL1列にユニーク索引を作成
create unique index IDX_TAB36_COL1 on TAB36(COL1) ;

-- TAB36表に主キー（COL1列）を定義。その際、COL1列のユニーク索引を利用
alter table TAB36 add primary key (COL1) using index ;

-- TAB36表のCOL2列にBツリー索引を作成
create index IDX_TAB36_COL2 on TAB36(COL2);

-- TAB36表のオプティマイザ統計情報を取得
exec DBMS_STATS.GATHER_TABLE_STATS(ownname => 'TRY', tabname => 'TAB36');



