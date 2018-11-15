SET @density = 10000;
SET @imsi_prefix = '20628'; 

SELECT
       from_imsi           AS 'From', 
       to_imsi             AS 'to',
       priority_percent    AS 'priority IMSIs in range'
FROM (
      SELECT  
             lag(imsi,1) over (order by imsi)    AS from_imsi,
             imsi                                AS to_imsi,
             priority_percent
      FROM (
            SELECT imsi,
                   ((prio_count-prev_prio_count)::decimal/imsis_in_range) AS priority_percent
            FROM (
                  SELECT RPAD('@imsi_prefix', 15, '0') AS imsi, 
                         0 AS prio_count, 
                         1 AS imsis_in_range,
                         0 AS prev_prio_count
                  UNION
                  SELECT imsi, 
                         prio_count,
                         imsis_in_range,
                         nvl(lag(prio_count,1) over (order by imsi), 0)    AS prev_prio_count
                  FROM  (
                        SELECT 
                               CASE imsi WHEN max_imsi THEN RPAD('@imsi_prefix', 15, '9') ELSE imsi END AS imsi, 
                               CASE imsi WHEN max_imsi THEN rowNo%@density ELSE @density END AS imsis_in_range, 
                               prio_count
                        FROM ( 
                              SELECT imsi, 
                                     priority,
                                     SUM(priority) OVER ( ORDER BY imsi rows unbounded preceding)  AS prio_count,
                                     row_number() over (order by imsi asc) as rowNo,
                                     last_value(imsi) over(order by imsi asc rows between unbounded preceding and unbounded following) AS max_imsi
                              FROM (
                                    SELECT imsi, 
                                           CASE WHEN (sim.customer_org_id IN (1, 2, 3, 4, 5)) 
                                                THEN 1 ELSE 0 
                                           END AS priority
                                    FROM (
                                          SELECT DISTINCT imsi.imsi, event.sim_id
                                          FROM   (SELECT imsi_id, imsi
                                                  FROM   imsi
                                                  WHERE  imsi_status_id = 0 
                                                  AND    imsi LIKE '@imsi_prefix%') AS imsi
                                          JOIN event  ON imsi.imsi_id = event.imsi_id
                                          WHERE  event_source_id = 0
                                          AND    timestamp > ( now() - interval 24 hour )
                                          ORDER BY imsi.imsi
                                        ) as active_imsi
                                    JOIN sim ON active_imsi.sim_id = sim.sim_id
                                  )
                              GROUP BY  1,2 
                            )
                        WHERE rowNo%@density = 0
                        OR    imsi = max_imsi
                        )
                  GROUP BY 1,2,3 
            )
            ORDER  BY 1
      )
      GROUP BY 2,3
      ORDER BY 2
  )
WHERE from_imsi IS NOT NULL
ORDER BY 3 DESC, 1;
