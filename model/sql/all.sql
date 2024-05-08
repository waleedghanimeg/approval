select
    *
from
    AUTHORISATIONS_MASTER am
where
    am.amend_last_date >= :P_FROM_DATE
    AND am.amend_last_date <= :P_TO_DATE