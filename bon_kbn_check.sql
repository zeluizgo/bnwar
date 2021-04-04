create or replace package kbn_check as
procedure pbn_approve(
I_PARM_ANNUAL_REF_YR   NUMBER,
I_PARM_ANNUAL_SEQ_NBR  NUMBER,
I_GEN_POOL_SEQ_NBR     NUMBER,
I_STRCT_BONUS_DIV_CODE VARCHAR2
);
procedure pbn_end(
I_PARM_ANNUAL_REF_YR   NUMBER,
I_PARM_ANNUAL_SEQ_NBR  NUMBER,
I_GEN_POOL_SEQ_NBR     NUMBER,
I_STRCT_BONUS_DIV_CODE VARCHAR2
);
procedure pbn_approve_grant(
I_PARM_ANNUAL_REF_YR   NUMBER,
I_PARM_ANNUAL_SEQ_NBR  NUMBER,
I_GEN_POOL_SEQ_NBR     NUMBER,
I_STRCT_BONUS_DIV_CODE VARCHAR2,
I_EMPL_USR_NBR         NUMBER
);
procedure pbn_repprove(
I_PARM_ANNUAL_REF_YR   NUMBER,
I_PARM_ANNUAL_SEQ_NBR  NUMBER,
I_GEN_POOL_SEQ_NBR     NUMBER,
I_POOL_REAS_TEXT       VARCHAR2,
I_STRCT_BONUS_DIV_CODE VARCHAR2
);
procedure pbn_repprove_grant(
I_PARM_ANNUAL_REF_YR   NUMBER,
I_PARM_ANNUAL_SEQ_NBR  NUMBER,
I_GEN_POOL_SEQ_NBR     NUMBER,
I_POOL_REAS_TEXT       VARCHAR2,
I_STRCT_BONUS_DIV_CODE VARCHAR2,
I_EMPL_USR_NBR         NUMBER
);
end kbn_check;
/


create or replace package body kbn_check as
procedure pbn_approve(
I_PARM_ANNUAL_REF_YR   NUMBER,
I_PARM_ANNUAL_SEQ_NBR  NUMBER,
I_GEN_POOL_SEQ_NBR     NUMBER,
I_STRCT_BONUS_DIV_CODE VARCHAR2
) as
begin
declare
W_COUNT number;
begin
  select count(*) into W_COUNT from tbn_pool where
    PARM_ANNUAL_REF_YR   = I_PARM_ANNUAL_REF_YR   and
    PARM_ANNUAL_SEQ_NBR  = I_PARM_ANNUAL_SEQ_NBR  and
    GEN_POOL_SEQ_NBR     = I_GEN_POOL_SEQ_NBR     and
    STRCT_BONUS_DIV_CODE = I_STRCT_BONUS_DIV_CODE;

  if ( W_COUNT = 0 ) then
    insert into tbn_pool (PARM_ANNUAL_REF_YR,PARM_ANNUAL_SEQ_NBR,GEN_POOL_SEQ_NBR,
      STRCT_BONUS_DIV_CODE,POOL_STAT_CODE,POOL_BONUS_AMT,POOL_STKO_AMT) values (
      I_PARM_ANNUAL_REF_YR,I_PARM_ANNUAL_SEQ_NBR ,I_GEN_POOL_SEQ_NBR,
      I_STRCT_BONUS_DIV_CODE,'A',0,0);
  else
    update tbn_pool set POOL_STAT_CODE = 'A' where
      PARM_ANNUAL_REF_YR   = I_PARM_ANNUAL_REF_YR   and
      PARM_ANNUAL_SEQ_NBR  = I_PARM_ANNUAL_SEQ_NBR  and
      GEN_POOL_SEQ_NBR     = I_GEN_POOL_SEQ_NBR     and
      STRCT_BONUS_DIV_CODE = I_STRCT_BONUS_DIV_CODE and
      not exists (
        select 'x' from VBN_POOL_STRUCT where
          PARM_ANNUAL_REF_PARENT_YR   = I_PARM_ANNUAL_REF_YR   and
          PARM_ANNUAL_SEQ_PARENT_NBR  = I_PARM_ANNUAL_SEQ_NBR  and
          STRCT_BONUS_DIV_PARENT_CODE = I_STRCT_BONUS_DIV_CODE and
          (GEN_POOL_SEQ_NBR            = I_GEN_POOL_SEQ_NBR   or
          GEN_POOL_SEQ_NBR is null)  and
          POOL_STAT_CODE not in ('A','E')
      );
  end if;
end;
end pbn_approve;

procedure pbn_end(
I_PARM_ANNUAL_REF_YR   NUMBER,
I_PARM_ANNUAL_SEQ_NBR  NUMBER,
I_GEN_POOL_SEQ_NBR     NUMBER,
I_STRCT_BONUS_DIV_CODE VARCHAR2
)as
begin
declare
W_COUNT number;
begin
  select count(*) into W_COUNT from tbn_pool where
    PARM_ANNUAL_REF_YR   = I_PARM_ANNUAL_REF_YR   and
    PARM_ANNUAL_SEQ_NBR  = I_PARM_ANNUAL_SEQ_NBR  and
    GEN_POOL_SEQ_NBR     = I_GEN_POOL_SEQ_NBR     and
    STRCT_BONUS_DIV_CODE = I_STRCT_BONUS_DIV_CODE;

  if ( W_COUNT = 0 ) then
    insert into tbn_pool (PARM_ANNUAL_REF_YR,PARM_ANNUAL_SEQ_NBR,GEN_POOL_SEQ_NBR,
      STRCT_BONUS_DIV_CODE,POOL_STAT_CODE,POOL_BONUS_AMT,POOL_STKO_AMT) values (
      I_PARM_ANNUAL_REF_YR,I_PARM_ANNUAL_SEQ_NBR ,I_GEN_POOL_SEQ_NBR,
      I_STRCT_BONUS_DIV_CODE,'E',0,0);
  else
    update tbn_pool set POOL_STAT_CODE = 'E' where
      PARM_ANNUAL_REF_YR   = I_PARM_ANNUAL_REF_YR   and
      PARM_ANNUAL_SEQ_NBR  = I_PARM_ANNUAL_SEQ_NBR  and
      GEN_POOL_SEQ_NBR     = I_GEN_POOL_SEQ_NBR     and
      STRCT_BONUS_DIV_CODE = I_STRCT_BONUS_DIV_CODE and
      not exists (
        select 'x' from VBN_POOL_STRUCT where
          PARM_ANNUAL_REF_PARENT_YR   = I_PARM_ANNUAL_REF_YR   and
          PARM_ANNUAL_SEQ_PARENT_NBR  = I_PARM_ANNUAL_SEQ_NBR  and
          STRCT_BONUS_DIV_PARENT_CODE = I_STRCT_BONUS_DIV_CODE and
          (GEN_POOL_SEQ_NBR           = I_GEN_POOL_SEQ_NBR   or
          GEN_POOL_SEQ_NBR is null)    and
          POOL_STAT_CODE not in ('A','E')
      );
  end if;
end;
end pbn_end;
procedure pbn_approve_grant(
I_PARM_ANNUAL_REF_YR   NUMBER,
I_PARM_ANNUAL_SEQ_NBR  NUMBER,
I_GEN_POOL_SEQ_NBR     NUMBER,
I_STRCT_BONUS_DIV_CODE VARCHAR2,
I_EMPL_USR_NBR         NUMBER
)as
begin
declare
cursor C_POOL is select STRCT_BONUS_DIV_CODE from VBN_POOL_STRUCT where
    PARM_ANNUAL_REF_YR          = I_PARM_ANNUAL_REF_YR   and
    PARM_ANNUAL_SEQ_NBR         = I_PARM_ANNUAL_SEQ_NBR  and
    (GEN_POOL_SEQ_NBR            = I_GEN_POOL_SEQ_NBR     or
    GEN_POOL_SEQ_NBR is null )and
    STRCT_BONUS_DIV_PARENT_CODE = I_STRCT_BONUS_DIV_CODE;
W_COUNT_OWN number;
W_COUNT_PARENT number;
begin
  for W_POOL in C_POOL loop
    pbn_approve_grant(
      I_PARM_ANNUAL_REF_YR       ,
      I_PARM_ANNUAL_SEQ_NBR      ,
      I_GEN_POOL_SEQ_NBR         ,
      W_POOL.STRCT_BONUS_DIV_CODE,
      I_EMPL_USR_NBR             );
  end loop;

  select count(*) into W_COUNT_PARENT from VBN_POOL_STRUCT a where
    PARM_ANNUAL_REF_YR   = I_PARM_ANNUAL_REF_YR   and
    PARM_ANNUAL_SEQ_NBR  = I_PARM_ANNUAL_SEQ_NBR  and
    (GEN_POOL_SEQ_NBR     = I_GEN_POOL_SEQ_NBR    or
    GEN_POOL_SEQ_NBR     is null    )and
    STRCT_BONUS_DIV_CODE = I_STRCT_BONUS_DIV_CODE and
    STRCT_BONUS_DIV_PARENT_CODE in ( select STRCT_BONUS_DIV_CODE from
      tbn_historic_bonus_struct where
      PARM_ANNUAL_REF_YR  = a.PARM_ANNUAL_REF_YR  and
      PARM_ANNUAL_SEQ_NBR = a.PARM_ANNUAL_SEQ_NBR and
      (EMPL_USR_MGMT_NBR   = I_EMPL_USR_NBR or
       EMPL_USR_GEN_NBR    = I_EMPL_USR_NBR)
    );
  select count(*) into W_COUNT_OWN from VBN_POOL_STRUCT where
    PARM_ANNUAL_REF_YR   = I_PARM_ANNUAL_REF_YR   and
    PARM_ANNUAL_SEQ_NBR  = I_PARM_ANNUAL_SEQ_NBR  and
    STRCT_BONUS_DIV_CODE = I_STRCT_BONUS_DIV_CODE and
    (GEN_POOL_SEQ_NBR     = I_GEN_POOL_SEQ_NBR     or
    GEN_POOL_SEQ_NBR is null ) and
    (EMPL_USR_MGMT_NBR   = I_EMPL_USR_NBR or
     EMPL_USR_GEN_NBR    = I_EMPL_USR_NBR);

  if W_COUNT_PARENT <> 0 then
    pbn_approve(I_PARM_ANNUAL_REF_YR,I_PARM_ANNUAL_SEQ_NBR,I_GEN_POOL_SEQ_NBR,I_STRCT_BONUS_DIV_CODE);
  else
    if W_COUNT_OWN <> 0 then
      pbn_end(I_PARM_ANNUAL_REF_YR,I_PARM_ANNUAL_SEQ_NBR,I_GEN_POOL_SEQ_NBR,I_STRCT_BONUS_DIV_CODE);
    end if;
  end if;

end;
end pbn_approve_grant;

procedure pbn_repprove(
I_PARM_ANNUAL_REF_YR   NUMBER,
I_PARM_ANNUAL_SEQ_NBR  NUMBER,
I_GEN_POOL_SEQ_NBR     NUMBER,
I_POOL_REAS_TEXT       VARCHAR2,
I_STRCT_BONUS_DIV_CODE VARCHAR2
)as
begin
declare
W_COUNT number;
begin
  select count(*) into W_COUNT from tbn_pool where
    PARM_ANNUAL_REF_YR   = I_PARM_ANNUAL_REF_YR   and
    PARM_ANNUAL_SEQ_NBR  = I_PARM_ANNUAL_SEQ_NBR  and
    GEN_POOL_SEQ_NBR     = I_GEN_POOL_SEQ_NBR     and
    STRCT_BONUS_DIV_CODE = I_STRCT_BONUS_DIV_CODE;

  if ( W_COUNT = 0 ) then
    select count(*) into W_COUNT from tbn_pool where
      PARM_ANNUAL_REF_YR   = I_PARM_ANNUAL_REF_YR   and
      PARM_ANNUAL_SEQ_NBR  = I_PARM_ANNUAL_SEQ_NBR  and
      GEN_POOL_SEQ_NBR     = I_GEN_POOL_SEQ_NBR     and
      POOL_STAT_CODE = 'A' and
      STRCT_BONUS_DIV_CODE in (
        select STRCT_BONUS_DIV_PARENT_CODE from VBN_POOL_STRUCT where
          PARM_ANNUAL_REF_YR   = I_PARM_ANNUAL_REF_YR   and
          PARM_ANNUAL_SEQ_NBR  = I_PARM_ANNUAL_SEQ_NBR  and
          GEN_POOL_SEQ_NBR     = I_GEN_POOL_SEQ_NBR     and
          STRCT_BONUS_DIV_CODE = I_STRCT_BONUS_DIV_CODE
      );
    if ( W_COUNT = 0 ) then
      insert into tbn_pool (
        POOL_STAT_CODE,
        POOL_REAS_TEXT,
        PARM_ANNUAL_REF_YR,
        PARM_ANNUAL_SEQ_NBR,
        GEN_POOL_SEQ_NBR,
        STRCT_BONUS_DIV_CODE
      ) values (
        'R',
        I_POOL_REAS_TEXT,
        I_PARM_ANNUAL_REF_YR,
        I_PARM_ANNUAL_SEQ_NBR,
        I_GEN_POOL_SEQ_NBR,
        I_STRCT_BONUS_DIV_CODE
      );
    end if;
  else
    update tbn_pool set
      POOL_STAT_CODE = 'R' ,
      POOL_REAS_TEXT = I_POOL_REAS_TEXT
    where
      PARM_ANNUAL_REF_YR   = I_PARM_ANNUAL_REF_YR   and
      PARM_ANNUAL_SEQ_NBR  = I_PARM_ANNUAL_SEQ_NBR  and
      GEN_POOL_SEQ_NBR     = I_GEN_POOL_SEQ_NBR     and
      STRCT_BONUS_DIV_CODE = I_STRCT_BONUS_DIV_CODE;
  end if;

end;
end pbn_repprove;

procedure pbn_repprove_grant(
I_PARM_ANNUAL_REF_YR   NUMBER,
I_PARM_ANNUAL_SEQ_NBR  NUMBER,
I_GEN_POOL_SEQ_NBR     NUMBER,
I_POOL_REAS_TEXT       VARCHAR2,
I_STRCT_BONUS_DIV_CODE VARCHAR2,
I_EMPL_USR_NBR         NUMBER
)as
begin
declare
W_COUNT number;
begin
  select count(*) into W_COUNT from tbn_historic_bonus_struct a where
    I_PARM_ANNUAL_REF_YR   = PARM_ANNUAL_REF_YR  and
    I_PARM_ANNUAL_SEQ_NBR  = PARM_ANNUAL_SEQ_NBR and
    I_STRCT_BONUS_DIV_CODE = STRCT_BONUS_DIV_CODE and
    (EMPL_USR_MGMT_NBR <> I_EMPL_USR_NBR or HIST_BONUS_STRCT_LVL_NBR = 4 ) and
    (EMPL_USR_MGMT_NBR not in ( select EMPL_USR_MGMT_NBR from tbn_historic_bonus_struct
      where
        a.PARM_ANNUAL_REF_YR   = PARM_ANNUAL_REF_YR  and
        a.PARM_ANNUAL_SEQ_NBR  = PARM_ANNUAL_SEQ_NBR and
        a.STRCT_BONUS_DIV_PARENT_CODE = STRCT_BONUS_DIV_CODE
    ) or HIST_BONUS_STRCT_LVL_NBR = 4 ) and
    exists ( select 'x' from tbn_historic_bonus_struct where
      I_PARM_ANNUAL_REF_YR   = PARM_ANNUAL_REF_YR  and
      I_PARM_ANNUAL_SEQ_NBR  = PARM_ANNUAL_SEQ_NBR and
      a.STRCT_BONUS_DIV_PARENT_CODE = STRCT_BONUS_DIV_CODE and
      (EMPL_USR_MGMT_NBR = I_EMPL_USR_NBR or
      EMPL_USR_GEN_NBR = I_EMPL_USR_NBR)
    );

  if W_COUNT > 0 then

    pbn_repprove(
    I_PARM_ANNUAL_REF_YR   ,
    I_PARM_ANNUAL_SEQ_NBR  ,
    I_GEN_POOL_SEQ_NBR     ,
    I_POOL_REAS_TEXT       ,
    I_STRCT_BONUS_DIV_CODE
    );
  end if;
end;
end pbn_repprove_grant;

end kbn_check;
/