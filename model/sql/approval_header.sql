  SELECT *
    FROM (  SELECT /*+all_rows*/
                  am.patient_id
                  ,NVL (am.episode_no, 0) episode_no
                  ,SUBSTR ( get_medical_file (am.patient_id), 1, 10) mrn
                  ,requests
                  ,posted_request
                  ,sent_request
                  ,approved_request_Delayed
                  ,approved_requestd
                  ,rejected_request
                  ,hold_request
                  ,cancelled_request
                  ,Open_request
                  ,SENT_DELAYED_counter
                  ,GIVE_PRIORITY_counte
                  ,Information_Requested
                  ,Information_Sent
                  ,error_coun
                  ,MAX (am.amend_last_date) amend_last_date
                  ,get_patient_identity_no (am.patient_id) ID_NUMBER
                  ,MAX (INITCAP (pat_name_1) || ' ' || INITCAP (pat_name_2) || ' ' || UPPER (pat_name_family)) patient_name
                  ,MAX (pm.mobile_no) mobile_no
                  ,MAX (am.assigned_staff_id) assigned_staff_id
                  ,get_staff_name (MAX (am.assigned_staff_id)) assigned_staff_id_name
              FROM authorisations_master am
                   JOIN authorisations a ON a.request_no = am.request_no
                   JOIN patient_master pm ON pm.patient_id = am.patient_id
                   JOIN (  SELECT am2.patient_id
                                 ,am2.episode_no
                                 ,COUNT (*) requests
                                 ,COUNT (DECODE (am2.status, 'P', a2.authorisation_no)) posted_request
                                 ,COUNT (CASE
                                            WHEN     am2.status = 'S'
                                                 AND a2.authorised_flag = 'N'
                                            THEN
                                               a2.authorisation_no
                                         END)
                                     sent_request
                                 ,COUNT (CASE
                                            WHEN     am2.status = 'P'
                                                 AND a2.authorised_flag = 'Y'
                                                 AND am2.AMEND_LAST_DATE <= :P_POSTED_OFFSET
                                            THEN
                                               a2.authorisation_no
                                         END)
                                     approved_request_Delayed
                                 ,COUNT (CASE
                                            WHEN     am2.status = 'S'
                                                 AND a2.authorised_flag = 'Y'
                                            THEN
                                               a2.authorisation_no
                                         END)
                                     approved_requestd
                                 ,COUNT (CASE
                                            WHEN     am2.status = 'S'
                                                 AND a2.authorised_flag = 'R'
                                            THEN
                                               a2.authorisation_no
                                         END)
                                     rejected_request
                                 ,COUNT (CASE
                                            WHEN     am2.status = 'S'
                                                 AND a2.authorised_flag = 'H'
                                            THEN
                                               a2.authorisation_no
                                         END)
                                     hold_request
                                 ,COUNT (CASE
                                            WHEN     am2.status = 'S'
                                                 AND a2.authorised_flag = 'C'
                                            THEN
                                               a2.authorisation_no
                                         END)
                                     cancelled_request
                                 ,COUNT (CASE
                                            WHEN     am2.status = 'O'
                                                 AND a2.authorised_flag = 'N'
                                            THEN
                                               a2.authorisation_no
                                         END)
                                     Open_request
                                 ,COUNT (CASE
                                            WHEN     am2.status = 'S'
                                                 AND a2.authorised_flag IN ('Y', 'N')
                                                 AND am2.AMEND_LAST_DATE <= :P_SENT_OFFSET
                                            THEN
                                               a2.authorisation_no
                                         END)
                                     SENT_DELAYED_counter
                                 ,COUNT (DISTINCT CASE
                                                     WHEN     am2.priority_date IS NOT NULL
                                                          AND a2.authorised_flag = 'N'
                                                     THEN
                                                        a2.AUTHORISATION_NO
                                                  END)
                                     GIVE_PRIORITY_counte
                                 ,COUNT (DISTINCT DECODE (am2.online_status, 'IR', Am2.online_status)) Information_Requested
                                 ,COUNT (DISTINCT DECODE (am2.online_status, 'IS', Am2.online_status)) Information_Sent
                                 ,COUNT (DISTINCT DECODE (am2.online_status, 'E', Am2.online_status)) error_coun
                             FROM authorisations_master am2 JOIN authorisations a2 ON a2.request_no = am2.request_no
                         GROUP BY am2.patient_id, am2.episode_no) ast
                      ON     am.patient_id = ast.patient_id
                         AND am.episode_no = ast.episode_no
             WHERE     1 = 1
                   AND am.amend_last_date >= :P_FROM_DATE
                   AND am.amend_last_date <= :P_TO_DATE
                   AND am.status = NVL (:P_STATUS, am.status)
                   AND a.authorised_flag = NVL (:p_authorised_flag, a.authorised_flag)
                   AND (   :P_Right_filter IS NULL
                        OR (    am.priority_date IS NOT NULL
                            AND a.authorised_flag = 'N'
                            AND :P_Right_filter = '6'))
                   AND (   :P_Right_filter IS NULL
                        OR (    A.PULL_RESPONSE_ID IS NOT NULL
                            AND :P_Right_filter = '13')) --HasResponse
                   AND (   :P_Right_filter IS NULL
                        OR (    EXISTS
                                   (SELECT 1
                                      FROM API_COMMUNICATION_REQUEST b
                                     WHERE B.ABOUT_API_TRANS_ID = a.API_LAST_TRANS_ID)
                            AND NOT EXISTS
                                   (SELECT 1
                                      FROM API_COMMUNICATION b
                                     WHERE B.ABOUT_API_TRANS_ID = a.API_LAST_TRANS_ID)
                            AND :P_Right_filter = '14'))
                   AND (   NVL (:pIsFacility, 'N') = 'N'
                        OR (    NVL (am.facility_id, :pCurrentFacility) = NVL (:pFACILITY_ID, :pCurrentFacility)
                            AND :pIsFacility = 'Y'))
          GROUP BY am.patient_id
                  ,am.episode_no
                  ,requests
                  ,posted_request
                  ,sent_request
                  ,approved_request_Delayed
                  ,approved_requestd
                  ,rejected_request
                  ,hold_request
                  ,cancelled_request
                  ,Open_request
                  ,SENT_DELAYED_counter
                  ,GIVE_PRIORITY_counte
                  ,Information_Requested
                  ,Information_Sent
                  ,error_coun
          ORDER BY am.patient_id, am.episode_no DESC) QRSLT
ORDER BY AMEND_LAST_DATE DESC