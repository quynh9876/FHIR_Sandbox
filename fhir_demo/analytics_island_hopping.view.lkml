###########
## EPIC Event Data for COVID Events  ##
###########{


## Patients with Confirmed COVID  ##

view: patient_condition_covid {

#   derived_table: {
#     sql: SELECT patient_id, date as event_date, null as organization_id, 'positive_test' as event_type FROM `lookerdata.alminton_fhir.status_patient_covid_positive_status`;;
#   }

  derived_table: {
    explore_source: fhir_hcls {
      column: patient_id { field: analytics_island_hopping.patient_ccf }
      column: event_date { field: analytics_island_hopping.admission_date }
      column: organization_id { field: analytics_island_hopping.organization_name }
      derived_column: event_type { sql: 'positive_test' ;;}
      filters: {
        field: analytics.admission_date
        value: "365 days"
      }
      filters: {
        field: analytics_island_hopping.count_covid_confirmed
        value: ">0"
      }
    }
  }

  dimension: patient_id {
    type: string
    sql: ${TABLE}.patient_id ;;
  }

  dimension: event_date {
    type: date
    sql: ${TABLE}.event_date ;;
  }

  dimension: organization_id {
    type: string
    sql: ${TABLE}.organization_id ;;
  }

  dimension: event_type {
    type: string
    sql: ${TABLE}.event_type ;;
  }

}

## Patients with Suspected COVID  ##

view: patient_condition_covid_suspected {

#   derived_table: {
#     sql: SELECT CAST(patient_id as string) as patient_id, date as event_date, null as organization_id, 'suspected_covid' as event_type FROM `lookerdata.alminton_fhir.status_patient_covid_suspected`;;
#   }

  derived_table: {
    explore_source: fhir_hcls {
      column: patient_id { field: analytics_island_hopping.patient_ccf }
      column: event_date { field: analytics_island_hopping.admission_date }
      column: organization_id { field: analytics_island_hopping.organization_name }
      derived_column: event_type { sql: 'suspected_covid' ;;}
      filters: {
        field: analytics.admission_date
        value: "365 days"
      }
      filters: {
        field: analytics_island_hopping.count_covid_suspected
        value: ">0"
      }
    }
  }

  dimension: patient_id {
    type: string
    sql: ${TABLE}.patient_id ;;
  }

  dimension: event_date {
    type: date
    sql: ${TABLE}.event_date ;;
  }

  dimension: organization_id {
    type: string
    sql: ${TABLE}.organization_id ;;
  }

  dimension: event_type {
    type: string
    sql: ${TABLE}.event_type ;;
  }

}

## Patients who Died  ##

view: patient_condition_death {

#   derived_table: {
#     sql: SELECT patient_id, date as event_date, organization_id, 'death' as event_type FROM `lookerdata.alminton_fhir.status_patient_death`;;
#   }

  derived_table: {
    explore_source: fhir_hcls {
      column: patient_id { field: analytics_island_hopping.patient_ccf }
      column: event_date { field: analytics_island_hopping.admission_date }
      column: organization_id { field: analytics_island_hopping.organization_name }
      derived_column: event_type { sql: 'death' ;;}
      filters: {
        field: analytics.admission_date
        value: "365 days"
      }
      filters: {
        field: analytics_island_hopping.count_patient_death
        value: ">0"
      }
    }
  }

  dimension: patient_id {
    type: string
    sql: ${TABLE}.patient_id ;;
  }

  dimension: event_date {
    type: date
    sql: ${TABLE}.event_date ;;
  }

  dimension: organization_id {
    type: string
    sql: ${TABLE}.organization_id ;;
  }

  dimension: event_type {
    type: string
    sql: ${TABLE}.event_type ;;
  }

}

## Patients who are on Home Monitoring  ##

view: patient_home_monitor {

#   derived_table: {
#     sql: SELECT patient_id, date as event_date, null as organization_id, 'monitor' as event_type FROM `lookerdata.alminton_fhir.status_home_monitor` ;;
#   }

  derived_table: {
    explore_source: fhir_hcls {
      column: patient_id { field: analytics_island_hopping.patient_ccf }
      column: event_date { field: analytics_island_hopping.admission_date }
      column: organization_id { field: analytics_island_hopping.organization_name }
      derived_column: event_type { sql: 'monitor' ;;}
      filters: {
        field: analytics.admission_date
        value: "365 days"
      }
      filters: {
        field: analytics_island_hopping.count_patient_home_healthcare
        value: ">0"
      }
    }
  }

  dimension: patient_id {
    type: string
    sql: ${TABLE}.patient_id ;;
  }

  dimension: event_date {
    type: date
    sql: ${TABLE}.event_date ;;
  }

  dimension: organization_id {
    type: string
    sql: ${TABLE}.organization_id ;;
  }

  dimension: event_type {
    type: string
    sql: ${TABLE}.event_type ;;
  }

}

## Patients who are Admitted to a Hospital  ##

view: patient_hospital_admission {

#   derived_table: {
#     sql: SELECT patient_id, date as event_date, organization_id, 'admission' as event_type FROM `lookerdata.alminton_fhir.status_hospital_admissions`;;
#   }

  derived_table: {
    explore_source: fhir_hcls {
      column: patient_id { field: analytics_island_hopping.patient_ccf }
      column: event_date { field: analytics_island_hopping.admission_date }
      column: organization_id { field: analytics_island_hopping.organization_name }
      derived_column: event_type { sql: 'admission' ;;}
      filters: {
        field: analytics.admission_date
        value: "365 days"
      }
      filters: {
        field: analytics_island_hopping.count_inpatient_visit
        value: ">0"
      }
    }
  }

  dimension: patient_id {
    type: string
    sql: ${TABLE}.patient_id ;;
  }

  dimension: event_date {
    type: date
    sql: ${TABLE}.event_date ;;
  }

  dimension: organization_id {
    type: string
    sql: ${TABLE}.organization_id ;;
  }

  dimension: event_type {
    type: string
    sql: ${TABLE}.event_type ;;
  }

}

## Patients who are Discharged from a Hospital  ##

view: patient_hospital_discharge {

#   derived_table: {
#     sql: SELECT patient_id, date as event_date, organization_id, 'discharge' as event_type FROM `lookerdata.alminton_fhir.status_hospital_discharge`;;
#   }

  derived_table: {
    explore_source: fhir_hcls {
      column: patient_id { field: analytics_island_hopping.patient_ccf }
      column: event_date { field: analytics_island_hopping.discharge_date }
      column: organization_id { field: analytics_island_hopping.organization_name }
      derived_column: event_type { sql: 'discharge' ;;}
      filters: {
        field: analytics.admission_date
        value: "365 days"
      }
      filters: {
        field: analytics_island_hopping.count_inpatient_visit
        value: ">0"
      }
    }
  }

  dimension: patient_id {
    type: string
    sql: ${TABLE}.patient_id ;;
  }

  dimension: event_date {
    type: date
    sql: ${TABLE}.event_date ;;
  }

  dimension: organization_id {
    type: string
    sql: ${TABLE}.organization_id ;;
  }

  dimension: event_type {
    type: string
    sql: ${TABLE}.event_type ;;
  }

}

## Patients who are in a staffed bed ##

view: patient_location_bed {

#   derived_table: {
#     sql: SELECT patient_id, date as event_date, null as organization_id, 'staffed_bed' as event_type FROM `lookerdata.alminton_fhir.patient_location_bed`;;
#   }

  derived_table: {
    explore_source: fhir_hcls {
      column: patient_id { field: analytics_island_hopping.patient_ccf }
      column: event_date { field: analytics_island_hopping.admission_date }
      column: organization_id { field: analytics_island_hopping.organization_name }
      derived_column: event_type { sql: 'staffed_bed' ;;}
      filters: {
        field: analytics.admission_date
        value: "365 days"
      }
      filters: {
        field: analytics_island_hopping.count_staffed_bed_encounters
        value: ">0"
      }
    }
  }

  dimension: patient_id {
    type: string
    sql: ${TABLE}.patient_id ;;
  }

  dimension: event_date {
    type: date
    sql: ${TABLE}.event_date ;;
  }

  dimension: organization_id {
    type: string
    sql: ${TABLE}.organization_id ;;
  }

  dimension: event_type {
    type: string
    sql: ${TABLE}.event_type ;;
  }

}

## Patients who are in an ICU bed ##

view: patient_location_icu {

#   derived_table: {
#     sql: SELECT patient_id, date as event_date, null as organization_id, 'icu_bed' as event_type FROM `lookerdata.alminton_fhir.patient_location_icu`;;
#   }

  derived_table: {
    explore_source: fhir_hcls {
      column: patient_id { field: analytics_island_hopping.patient_ccf }
      column: event_date { field: analytics_island_hopping.admission_date }
      column: organization_id { field: analytics_island_hopping.organization_name }
      derived_column: event_type { sql: 'icu_bed' ;;}
      filters: {
        field: analytics.admission_date
        value: "365 days"
      }
      filters: {
        field: analytics_island_hopping.count_icu_bed_encounters
        value: ">0"
      }
    }
  }

  dimension: patient_id {
    type: string
    sql: ${TABLE}.patient_id ;;
  }

  dimension: event_date {
    type: date
    sql: ${TABLE}.event_date ;;
  }

  dimension: organization_id {
    type: string
    sql: ${TABLE}.organization_id ;;
  }

  dimension: event_type {
    type: string
    sql: ${TABLE}.event_type ;;
  }

}


## Patients who are admissted to an SNF ##

view: patient_snf_admission {

#   derived_table: {
#     sql: SELECT patient_id, date as event_date, null as organization_id, 'snf' as event_type FROM `lookerdata.alminton_fhir.status_snf`;;
#   }

  derived_table: {
    explore_source: fhir_hcls {
      column: patient_id { field: analytics_island_hopping.patient_ccf }
      column: organization_id { field: analytics_island_hopping.organization_name }
      column: event_date { field: analytics_island_hopping.admission_date }
      derived_column: event_type { sql: 'snf' ;;}
      filters: {
        field: analytics.admission_date
        value: "365 days"
      }
      filters: {
        field: analytics_island_hopping.count_patient_snf
        value: ">0"
      }
    }
  }

  dimension: patient_id {
    type: string
    sql: ${TABLE}.patient_id ;;
  }

  dimension: event_date {
    type: date
    sql: ${TABLE}.event_date ;;
  }

  dimension: organization_id {
    type: string
    sql: ${TABLE}.organization_id ;;
  }

  dimension: event_type {
    type: string
    sql: ${TABLE}.event_type ;;
  }

}

###########}

###########
## Operational Tables for Data Manipulation on Final Status  ##
###########{

## Date Generator ##

view: date_generator {
  derived_table: {
    sql: SELECT cast(generated as timestamp) as generated FROM UNNEST(GENERATE_DATE_ARRAY(DATE('2019-01-01'), CURRENT_DATE(),INTERVAL 1 DAY)) AS generated ;;
  }

  dimension_group: generated {
    type: time
    timeframes: [raw,date]
    sql: ${TABLE}.generated ;;
  }

}


## Creates a table bringing together the positive patients encounter data together from the EPIC Event Data ##

view: patient_events_covid_positive {

  derived_table: {
    persist_for: "10 minutes"
    sql:
    SELECT patient_id, event_date, organization_id, event_type
    FROM (
    SELECT *
    FROM (
    SELECT CAST(patient_id as string) as patient_id, CAST(event_date as timestamp) as event_date, cast(organization_id as string) as organization_id, event_type FROM ${patient_condition_covid.SQL_TABLE_NAME}
    UNION ALL
    SELECT CAST(patient_id as string) as patient_id, CAST(event_date as timestamp) as event_date, cast(organization_id as string) as organization_id, event_type FROM ${patient_condition_death.SQL_TABLE_NAME}
    UNION ALL
    SELECT CAST(patient_id as string) as patient_id, CAST(event_date as timestamp) as event_date, cast(organization_id as string) as organization_id, event_type FROM ${patient_home_monitor.SQL_TABLE_NAME}
    UNION ALL
    SELECT CAST(patient_id as string) as patient_id, CAST(event_date as timestamp) as event_date, cast(organization_id as string) as organization_id, event_type FROM ${patient_hospital_admission.SQL_TABLE_NAME}
    UNION ALL
    SELECT CAST(patient_id as string) as patient_id, CAST(event_date as timestamp) as event_date, cast(organization_id as string) as organization_id, event_type FROM ${patient_hospital_discharge.SQL_TABLE_NAME}
    UNION ALL
    SELECT CAST(patient_id as string) as patient_id, CAST(event_date as timestamp) as event_date, cast(organization_id as string) as organization_id, event_type FROM ${patient_snf_admission.SQL_TABLE_NAME}
    UNION ALL
    SELECT CAST(patient_id as string) as patient_id, CAST(event_date as timestamp) as event_date, cast(organization_id as string) as organization_id, event_type FROM ${patient_condition_covid_suspected.SQL_TABLE_NAME}
    UNION ALL
    SELECT CAST(patient_id as string) as patient_id, CAST(event_date as timestamp) as event_date, cast(organization_id as string) as organization_id, event_type FROM ${patient_location_bed.SQL_TABLE_NAME}
    UNION ALL
    SELECT CAST(patient_id as string) as patient_id, CAST(event_date as timestamp) as event_date, cast(organization_id as string) as organization_id, event_type FROM ${patient_location_icu.SQL_TABLE_NAME}
    ) as events
    WHERE patient_id IS NOT NULL
    AND ( patient_id in (SELECT distinct CAST(patient_id as string) as patient_id FROM ${patient_condition_covid.SQL_TABLE_NAME}) OR patient_id in (SELECT distinct CAST(patient_id as string) as patient_id FROM ${patient_condition_covid_suspected.SQL_TABLE_NAME}) )
    )  as filtered_events
    GROUP BY 1,2,3,4;;
  }

  dimension: patient_id {
    type: string
    sql: ${TABLE}.patient_id ;;
  }

  dimension: event_date {
    type: date
    sql: ${TABLE}.event_date ;;
  }

  dimension: organization_id {
    type: string
    sql: ${TABLE}.organization_id ;;
  }

  dimension: event_type {
    type: string
    sql: ${TABLE}.event_type ;;
  }

}

## Creates base data of positive patients on every single day since the beginning of the year ##

view: patient_events_by_calendar_date {

  derived_table: {
    sql:
    SELECT patient_id, generated as snapshot_date
    FROM (Select distinct patient_id from ${patient_events_covid_positive.SQL_TABLE_NAME}) as  patients
      CROSS JOIN (Select generated from ${date_generator.SQL_TABLE_NAME}) as calendar;;
  }

  dimension: patient_id {
    type: string
    sql: ${TABLE}.patient_id ;;
  }

  dimension_group: snapshot {
    type: time
    timeframes: [raw,date]
    sql: ${TABLE}.snapshot_date ;;
  }

}

###########}

###########
## Final Status of Patients by Day by COVID, Location, and Bed Usage  ##
###########{

## Patient Status by Day by Location ##

view: patient_status_location {

  derived_table: {
    sql:
    WITH ordered_patient_key_events as (
      SELECT patient_id, event_date, event_type as event, organization_id,
        row_number() OVER (partition by patient_id order by event_date desc) as event_order_desc,
        row_number() OVER (partition by patient_id order by event_date asc) as event_order_asc
      FROM (
        SELECT patient_id, event_date as event_date, organization_id, event_type, ROW_NUMBER() OVER (PARTITION BY patient_id, event_date ORDER BY case when event_type = 'death' then 1 when event_type = 'snf' then 2 when event_type = 'admission' then 4 when event_type = 'discharge' then 3 when event_type = 'monitor' then 5 else 6 end asc) as ranking
          FROM ${patient_events_covid_positive.SQL_TABLE_NAME}
          WHERE event_type IN ('admission','discharge','death','snf','monitor')
      ) as union_patient_key_events
      WHERE union_patient_key_events.ranking = 1
    ),
    unique_patient_by_date as (
      SELECT unique_patients.patient_id as patient_id, calendar_dates.generated as generated_date
      FROM (SELECT patient_id FROM ordered_patient_key_events GROUP BY 1) as unique_patients
        CROSS JOIN (SELECT generated FROM ${date_generator.SQL_TABLE_NAME}) as calendar_dates
    ),
   ordered_event as (
    SELECT current_event.patient_id, current_event.event_date, current_event.event, next_event.event as next_event, coalesce(timestamp_sub(next_event.event_date, interval 1 day),timestamp(current_date)) as next_event_date, current_event.organization_id --, unique_patient_by_date.generated_date
    FROM ordered_patient_key_events as current_event
      LEFT JOIN ordered_patient_key_events as next_event
        ON current_event.patient_id = next_event.patient_id
          and current_event.event_order_asc = next_event.event_order_asc - 1
   ),
   product as (
   SELECT ordered_event.*, unique_patient_by_date.generated_date as snapshot_date
   FROM unique_patient_by_date INNER JOIN ordered_event
   ON ordered_event.patient_id = unique_patient_by_date.patient_id
      AND  unique_patient_by_date.generated_date BETWEEN ordered_event.event_date and ordered_event.next_event_date
   )
   Select distinct unique_patient_by_date.generated_date, unique_patient_by_date.patient_id, coalesce(product.event,'Home') as location_status, product.next_event, product.organization_id
   FROM product
    FULL OUTER JOIN unique_patient_by_date on product.patient_id = unique_patient_by_date.patient_id and product.snapshot_date = unique_patient_by_date.generated_date;;
  }

  dimension: patient_id {
    label: "CCF Identifier"
    type: string
    sql: ${TABLE}.patient_id ;;
  }

  dimension: organization_id {
    label: "Organization Name"
    type: string
    sql: ${TABLE}.organization_id ;;
  }

  dimension_group: snapshot {
    type: time
    timeframes: [date,week,month,quarter,year]
    sql: ${TABLE}.generated_date ;;
    convert_tz: no
  }

  dimension: location_status_original {
    hidden: yes
    type: string
    sql: ${TABLE}.location_status ;;
  }

  dimension: location_status {
    type: string
    sql: CASE WHEN ${location_status_original} = 'admission' then 'Hospital'
          WHEN ${location_status_original} = 'discharge' then 'Home Recovering'
          WHEN ${location_status_original} = 'monitor' then 'Home Monitoring'
          WHEN ${location_status_original} = 'death' then 'Death'
          WHEN ${location_status_original} = 'snf' then 'SNF'
          ELSE 'Home'
          END
          ;;
  }

  measure: count_of_patients {
    type: count_distinct
    sql: ${patient_id} ;;
  }

}

## Patient Status by Day by COVID Status ##

view: patient_status_covid {

  derived_table: {
    sql:
    WITH covid_tests AS (SELECT patient_id, event_date, timestamp_add(event_date, INTERVAL 30 DAY) as expiration_date FROM ${patient_events_covid_positive.SQL_TABLE_NAME} WHERE event_type = 'positive_test'),
    covid_tests_flag AS (SELECT patient_id, generated FROM ${date_generator.SQL_TABLE_NAME} as calendar CROSS JOIN covid_tests WHERE calendar.generated BETWEEN covid_tests.event_date and covid_tests.expiration_date),
    first_covid_positive_test AS (SELECT patient_id, MIN(event_date) as first_date FROM covid_tests GROUP BY 1),
    covid_suspected AS (SELECT patient_id, event_date, timestamp_add(event_date, INTERVAL 30 DAY) as expiration_date FROM ${patient_events_covid_positive.SQL_TABLE_NAME} WHERE event_type = 'suspected_covid'),
    covid_suspected_flag AS (SELECT patient_id, generated FROM ${date_generator.SQL_TABLE_NAME} as calendar CROSS JOIN covid_suspected WHERE calendar.generated BETWEEN covid_suspected.event_date and covid_suspected.expiration_date)
    SELECT distinct full_set.patient_id, full_set.snapshot_date,
      CASE
        WHEN covid_tests_flag.patient_id is not null then 'Positive'
        WHEN full_set.snapshot_date >= first_covid_positive_test.first_date then 'Recovered'
        ELSE 'Negative' END AS covid_status,
      CASE
        WHEN covid_suspected_flag.patient_id is not null then 'Suspected' else 'Not Suspected' END as covid_suspected_status
    FROM ${patient_events_by_calendar_date.SQL_TABLE_NAME} as full_set
      LEFT OUTER JOIN covid_tests_flag ON full_set.patient_id = covid_tests_flag.patient_id
        AND full_set.snapshot_date = covid_tests_flag.generated
      LEFT OUTER JOIN first_covid_positive_test ON full_set.patient_id = first_covid_positive_test.patient_id
      LEFT OUTER JOIN covid_suspected_flag ON full_set.patient_id = covid_suspected_flag.patient_id
        AND full_set.snapshot_date = covid_suspected_flag.generated
      ;;
  }

  dimension: patient_id {
    hidden: yes
    type: string
    sql: ${TABLE}.patient_id ;;
  }

  dimension: snapshot_date {
    hidden: yes
    type: date
    sql: ${TABLE}.snapshot_date ;;
    convert_tz: no
  }

  dimension: covid_status {
    label: "COVID Status"
    type: string
    sql: ${TABLE}.covid_status ;;
  }

  dimension: covid_suspected_status {
    label: "COVID Suspected Status"
    type: string
    sql: ${TABLE}.covid_suspected_status ;;
  }

}

## Patient Status by Day by Bed Status ##

view: patient_status_bed {

  derived_table: {
    sql:
    WITH ordered_patient_key_events as (
      SELECT patient_id, event_date, event_type as event, organization_id,
        row_number() OVER (partition by patient_id order by event_date desc) as event_order_desc,
        row_number() OVER (partition by patient_id order by event_date asc) as event_order_asc
      FROM (
        SELECT patient_id, event_date as event_date, organization_id, event_type, ROW_NUMBER() OVER (PARTITION BY patient_id, date(event_date) ORDER BY event_date desc) as ranking
        FROM ${patient_events_covid_positive.SQL_TABLE_NAME}
        WHERE event_type IN ('staffed_bed','icu_bed')
      ) as union_patient_key_events
      WHERE union_patient_key_events.ranking = 1
    ),
    unique_patient_by_date as (
      SELECT unique_patients.patient_id as patient_id, calendar_dates.generated as generated_date
      FROM (SELECT patient_id FROM ordered_patient_key_events GROUP BY 1) as unique_patients
        CROSS JOIN (SELECT generated FROM ${date_generator.SQL_TABLE_NAME}) as calendar_dates
    ),
   ordered_event as (
    SELECT current_event.patient_id, current_event.event_date, current_event.event, next_event.event as next_event, coalesce(timestamp_sub(next_event.event_date, interval 1 day),timestamp(current_date)) as next_event_date, current_event.organization_id --, unique_patient_by_date.generated_date
    FROM ordered_patient_key_events as current_event
      LEFT JOIN ordered_patient_key_events as next_event
        ON current_event.patient_id = next_event.patient_id
          and current_event.event_order_asc = next_event.event_order_asc - 1
   ),
   product as (
   SELECT ordered_event.*, unique_patient_by_date.generated_date as snapshot_date
   FROM unique_patient_by_date INNER JOIN ordered_event
   ON ordered_event.patient_id = unique_patient_by_date.patient_id
      AND  unique_patient_by_date.generated_date BETWEEN ordered_event.event_date and ordered_event.next_event_date
   )
   Select DISTINCT unique_patient_by_date.generated_date, unique_patient_by_date.patient_id, coalesce(product.event,'staffed_bed') as bed_status, product.next_event, product.organization_id
   FROM product
    FULL OUTER JOIN unique_patient_by_date on product.patient_id = unique_patient_by_date.patient_id and product.snapshot_date = unique_patient_by_date.generated_date
   ;;
  }

  dimension: patient_id {
    hidden: yes
    type: string
    sql: ${TABLE}.patient_id ;;
  }

  dimension_group: snapshot {
    hidden: yes
    type: time
    timeframes: [date,week,month,quarter,year]
    sql: ${TABLE}.generated_date ;;
    convert_tz: no
  }

  dimension: bed_status_original {
    hidden: yes
    type: string
    sql: CASE WHEN ${TABLE}.bed_status = 'icu_bed' THEN 'ICU' ELSE 'Staffed Bed' END ;;
  }

  dimension: bed_status {
    type: string
    sql: CASE WHEN ${patient_status_location.location_status} = 'Hospital' then ${bed_status_original} ELSE NULL END;;
  }

}

###########}


view: final_patient_status {
  derived_table: {
    publish_as_db_view: yes
    datagroup_trigger: once_daily
    create_process: {
      sql_step:
      CREATE TABLE ${SQL_TABLE_NAME}
        (
          snapshot_date TIMESTAMP,
          ccf_identifier STRING,
          organization_name STRING,
          location_status STRING,
          covid_status STRING,
          covid_suspected_status STRING,
          bed_status STRING,
          days_since_first_event INT64
        );;

      sql_step:
      INSERT INTO ${SQL_TABLE_NAME} (snapshot_date, ccf_identifier)
      SELECT snapshot_date, patient_id as ccf_identifier FROM ${patient_events_by_calendar_date.SQL_TABLE_NAME}
      ;;

      sql_step:
      UPDATE ${SQL_TABLE_NAME} i
      SET location_status = n.location_status
      FROM (
      SELECT patient_id as ccf_identifier, generated_date as snapshot_date, location_status
      FROM ${patient_status_location.SQL_TABLE_NAME}
      ) n
      WHERE i.ccf_identifier = n.ccf_identifier
      AND i.snapshot_date = n.snapshot_date
      ;;

      sql_step:
      UPDATE ${SQL_TABLE_NAME} i
        SET covid_status = n.covid_status, covid_suspected_status = n.covid_suspected_status
      FROM (
        SELECT patient_id as ccf_identifier, snapshot_date, covid_status, covid_suspected_status
        FROM ${patient_status_covid.SQL_TABLE_NAME}
      ) n
      WHERE i.ccf_identifier = n.ccf_identifier
      AND i.snapshot_date = n.snapshot_date
      ;;

      sql_step:
      UPDATE ${SQL_TABLE_NAME} i
        SET bed_status = n.bed_status
      FROM (
        SELECT patient_id as ccf_identifier, generated_date as snapshot_date, bed_status
        FROM ${patient_status_bed.SQL_TABLE_NAME}
      ) n
      WHERE i.ccf_identifier = n.ccf_identifier
      AND i.snapshot_date = n.snapshot_date
      AND i.location_status = 'admission'
      ;;

      sql_step:
      UPDATE ${SQL_TABLE_NAME} i
         SET days_since_first_event = n.days_since_first_event
      FROM (
      SELECT patient_first_event.ccf_identifier, patient_calendar.snapshot_date
      , ROW_NUMBER() OVER (PARTITION BY patient_first_event.ccf_identifier order by patient_calendar.snapshot_date asc) as days_since_first_event
      FROM ${patient_events_by_calendar_date.SQL_TABLE_NAME} as patient_calendar
      INNER JOIN
      (
        SELECT patient_id as ccf_identifier, MIN(event_date) as date_of_first_event
        FROM ${patient_events_covid_positive.SQL_TABLE_NAME}
        WHERE event_type in ('positive_test','suspected_covid')
        GROUP BY 1
      ) AS patient_first_event ON patient_calendar.patient_id =  patient_first_event.ccf_identifier
      AND patient_calendar.snapshot_date >= date_of_first_event
      ) n
      WHERE i.ccf_identifier = n.ccf_identifier
      AND i.snapshot_date = n.snapshot_date
      ;;
      # WHERE event_type = 'positive_test'
    }
  }
  dimension: patient_ccf { html: x ;; }
}

view: final_patient_status_patient_details {
  derived_table: {
    publish_as_db_view: yes
    datagroup_trigger: once_daily
    explore_source: fhir_hcls {
      column: patient_ccf { field: analytics_island_hopping.patient_ccf }
      column: min_organization_name { field: analytics.min_organization_name }
      column: min_practitioner_name { field: analytics.min_practitioner_name }
      column: min_postal_code { field: analytics.min_postal_code }
      column: min_state { field: analytics.min_state }
      # column: count_comorbid { field: analytics.count_comorbid }
      column: min_age { field: analytics.min_age }
      column: min_gender { field: analytics.min_gender }
      filters: {
        field: analytics.admission_date
        value: "365 days"
      }
    }
  }
  dimension: patient_ccf { html: x ;; }

}

view: final_patient_status_dashboard {
  sql_table_name: `@{view_status_details}` ;;

  dimension: ccf_identifier {
    label: "CCF Identifier"
    type: string
    sql: ${TABLE}.ccf_identifier ;;
  }

  dimension_group: snapshot {
    type: time
    timeframes: [date,week,month,quarter,year]
    sql: ${TABLE}.snapshot_date ;;
    convert_tz: no
  }

  dimension: location_status_original {
    hidden: yes
    type: string
    sql: ${TABLE}.location_status ;;
  }

  dimension: location_status {
    group_label: "Status"
    type: string
    sql: CASE WHEN ${location_status_original} = 'admission' then 'Hospital'
          WHEN ${location_status_original} = 'discharge' then 'Home Recovering'
          WHEN ${location_status_original} = 'monitor' then 'Home Monitoring'
          WHEN ${location_status_original} = 'death' then 'Death'
          WHEN ${location_status_original} = 'snf' then 'SNF'
          ELSE 'Home'
          END;;
  }

  dimension: covid_suspected_status {
    hidden: yes
    type: string
    sql: ${TABLE}.covid_suspected_status ;;
  }

  dimension: covid_status {
    hidden: yes
    type: string
    sql: ${TABLE}.covid_status ;;
  }

  dimension: days_since_first_event {
    type: number
    sql: ${TABLE}.days_since_first_event ;;
  }

  dimension: covid_consolidated_status {
    group_label: "Status"
    type: string
    sql: CASE WHEN ${covid_suspected_status} = 'Suspected' AND ${covid_status} = 'Negative' THEN 'Suspected'
          WHEN ${covid_suspected_status} = 'Suspected' AND ${covid_status} = 'Positive' THEN 'Positive'
          WHEN ${covid_suspected_status} = 'Not Suspected' AND ${covid_status} = 'Negative' THEN 'Not Suspected'
          WHEN ${covid_suspected_status} = 'Not Suspected' AND ${covid_status} = 'Positive' THEN 'Positive'
          WHEN ${location_status} = 'Death' THEN 'Positive'
          ELSE ${covid_status}
          END;;
  }

  dimension: bed_status {
    group_label: "Status"
    type: string
    sql: CASE WHEN ${location_status_original} = 'admission' AND ${TABLE}.bed_status IS NULL THEN 'Staffed Bed' ELSE CASE WHEN ${TABLE}.bed_status = 'staffed_bed' THEN 'Staffed Bed' WHEN ${TABLE}.bed_status = 'icu_bed' THEN 'ICU Bed' ELSE ${TABLE}.bed_status END  END  ;;
  }

  dimension: patient_status {
    group_label: "Patient Status"
    description: "Ambulatory, Inpatient, Inpatient ICU, Discharged SNF, Discharged Home, Death"
    type: string
    sql:
      CASE
        WHEN ${location_status} in ('Home Monitoring', 'Home') then '1 - Ambulatory'
        WHEN ${location_status} = 'Hospital' and ${bed_status} = 'Staffed Bed' then '2 - Inpatient'
        WHEN ${location_status} = 'Hospital' and ${bed_status} = 'ICU Bed' then '3 - Inpatient ICU'
        WHEN ${location_status} = 'SNF' then '4 - Discharged to SNF'
        WHEN ${location_status} = 'Home Recovering' then '5 - Discharged to Home'
        WHEN ${location_status} = 'Death' then '6 - Death'
        ELSE '99 - Other'
      END
      ;;
  }

  dimension: patient_risk_score {
    group_label: "Patient Status"
    description: "Score for risk status of patient - Ambulatory Not Suspected (5), Ambulatory Suspected (10), Ambulatory Confirmed (20), Inpatient (60), Inpatient ICU (80), Discharged SNF (90), Discharged Home (30), Death (100)"
    type: number
    sql:
      CASE
        WHEN ${location_status} in ('Home Monitoring', 'Home') and ${covid_status} = 'Not Suspected' then 5
        WHEN ${location_status} in ('Home Monitoring', 'Home') and ${covid_status} = 'Suspected' then 10
        WHEN ${location_status} in ('Home Monitoring', 'Home') and ${covid_status} = 'Confirmed' then 20
        WHEN ${location_status} = 'Hospital' and ${bed_status} = 'Staffed Bed' then 175
        WHEN ${location_status} = 'Hospital' and ${bed_status} = 'ICU Bed' then 200
        WHEN ${location_status} = 'SNF' then 225
        WHEN ${location_status} = 'Home Recovering' then 20
        WHEN ${location_status} = 'Death' then 250
        ELSE NULL
      END
      ;;
  }

  measure: count_patients {
    type: count_distinct
    sql: ${ccf_identifier} ;;
    drill_fields: [ccf_identifier]
  }

  measure: average_patient_score {
    type: average
    sql: ${patient_risk_score} ;;
    value_format_name: decimal_1
  }

## Location Counts

  measure: count_patients_location_hospital { group_label: "Location Counts" type: count_distinct sql: ${ccf_identifier} ;; filters: [location_status: "Hospital"] }
  measure: count_patients_location_ambulatory { group_label: "Location Counts" type: count_distinct sql: ${ccf_identifier} ;; filters: [location_status: "Home Monitoring, Home Recovering, Home"] }
  measure: count_patients_location_death { group_label: "Location Counts" type: count_distinct sql: ${ccf_identifier} ;; filters: [location_status: "Death"] }
  measure: count_patients_location_snf { group_label: "Location Counts" type: count_distinct sql: ${ccf_identifier} ;; filters: [location_status: "SNF"] }

## COVID Counts

  measure: count_patients_covid_suspected { group_label: "COVID Counts" type: count_distinct sql: ${ccf_identifier} ;; filters: [covid_consolidated_status: "Suspected"] }
  measure: count_patients_covid_confirmed { group_label: "COVID Counts" type: count_distinct sql: ${ccf_identifier} ;; filters: [covid_consolidated_status: "Positive"] }
  measure: count_patients_covid_not_suspected { group_label: "COVID Counts" type: count_distinct sql: ${ccf_identifier} ;; filters: [covid_consolidated_status: "Not Suspected"] }

## Patient Status Counts

  measure: count_patients_status_1_ambulatory { group_label: "Patient Status Counts" type: count_distinct sql: ${ccf_identifier} ;; filters: [patient_status: "1 - Ambulatory"] }
  measure: count_patients_status_2_inpatient { group_label: "Patient Status Counts" type: count_distinct sql: ${ccf_identifier} ;; filters: [patient_status: "2 - Inpatient"] }
  measure: count_patients_status_3_inpatient_icu { group_label: "Patient Status Counts" type: count_distinct sql: ${ccf_identifier} ;; filters: [patient_status: "3 - Inpatient ICU"] }
  measure: count_patients_status_4_discharged_snf { group_label: "Patient Status Counts" type: count_distinct sql: ${ccf_identifier} ;; filters: [patient_status: "4 - Discharged to SNF"] }
  measure: count_patients_status_5_discharged_home { group_label: "Patient Status Counts" type: count_distinct sql: ${ccf_identifier} ;; filters: [patient_status: "5 - Discharged to Home"] }
  measure: count_patients_status_6_death { group_label: "Patient Status Counts" type: count_distinct sql: ${ccf_identifier} ;; filters: [patient_status: "6 - Death"] }
  measure: count_patients_status_99_other { group_label: "Patient Status Counts" type: count_distinct sql: ${ccf_identifier} ;; filters: [patient_status: "99 - Other"] }

  measure: percent_patients_status_1_ambulatory { group_label: "Patient Status % of Total" type: number sql: 1.0 * ${count_patients_status_1_ambulatory} / nullif(${count_patients},0) ;; value_format_name: percent_1}
  measure: percent_patients_status_2_inpatient { group_label: "Patient Status % of Total" type: number sql: 1.0 * ${count_patients_status_2_inpatient} / nullif(${count_patients},0) ;; value_format_name: percent_1}
  measure: percent_patients_status_3_inpatient_icu { group_label: "Patient Status % of Total" type: number sql: 1.0 * ${count_patients_status_3_inpatient_icu} / nullif(${count_patients},0) ;; value_format_name: percent_1}
  measure: percent_patients_status_4_discharged_snf { group_label: "Patient Status % of Total" type: number sql: 1.0 * ${count_patients_status_4_discharged_snf} / nullif(${count_patients},0) ;; value_format_name: percent_1}
  measure: percent_patients_status_5_discharged_home { group_label: "Patient Status % of Total" type: number sql: 1.0 * ${count_patients_status_5_discharged_home} / nullif(${count_patients},0) ;; value_format_name: percent_1}
  measure: percent_patients_status_6_death { group_label: "Patient Status % of Total" type: number sql: 1.0 * ${count_patients_status_6_death} / nullif(${count_patients},0) ;; value_format_name: percent_1}

}
view: final_patient_status_patient_details_dashboard {
  sql_table_name: `@{view_status_details_patient_view}` ;;
  dimension: patient_ccf {
    primary_key: yes
    hidden: yes
  }
  dimension: min_organization_name {
    label: "Hospital Name"
    drill_fields: [patient_age_tier, min_gender, min_state, min_practitioner_name]
  }
  dimension: min_practitioner_name {
    label: "Provider Name"
    drill_fields: [patient_age_tier, min_gender, min_state, min_organization_name]
  }
  dimension: min_postal_code {
    map_layer_name: us_counties_fips
    type: number
    label: "Postal Code"
    drill_fields: [patient_age_tier, min_gender, min_practitioner_name, min_organization_name]
  }
  dimension: min_state {
    map_layer_name: us_states
    label: "State"
    type: string
    drill_fields: [min_postal_code]
  }
#   dimension: count_comorbid {
#     type: number
#     label: "# Comorbidities"
#   }
  dimension: min_age {
    type: number
    label: "Age"
  }
  dimension: patient_age_tier {
    label: "Age Tier"
    description: "Patients Age - <10 YO, 10-20 YO, 20s, 30s, 40s, 50s, 60s, 70s, 80s, 90s"
    type: tier
    tiers: [10,20,30,40,50,60,70,80,90]
    style: integer
    sql: ${min_age} ;;
    drill_fields: [min_age, min_gender, min_state, min_organization_name, min_practitioner_name]
  }
  dimension: patient_age_tier_limited {
    label: "Age Tier (Limited)"
    description: "Patients Age - 0-40, 40-60, 60+"
    type: tier
    tiers: [40,60]
    style: integer
    sql: ${min_age} ;;
    drill_fields: [min_age, min_gender, min_state, min_organization_name, min_practitioner_name]
  }
  dimension: min_gender {
    type: string
    label: "Gender"
    drill_fields: [patient_age_tier, min_state, min_practitioner_name, min_organization_name]
  }
  parameter: pivot {
    type: unquoted
    default_value: "organization_name"
    allowed_value: {
      label: "Hospital Name"
      value: "organization_name"
    }
    allowed_value: {
      label: "Provider Name"
      value: "practitioner_name"
    }
    allowed_value: {
      label: "Patient Zipcode"
      value: "patient_postal_code"
    }
#     allowed_value: {
#       label: "Count Comorbidities"
#       value: "count_comorbid"
#     }
    allowed_value: {
      label: "Patient Age Tier"
      value: "patient_age_tier"
    }
    allowed_value: {
      label: "Patient Gender"
      value: "patient_gender"
    }
  }

  dimension: pivot_value {
    label: " Pivot Value"
    description: "Choose between selecting hospital name, doctor NPI, patient zip, or patient age tier"
    sql:
    {% if    pivot._parameter_value == 'organization_name' %} ${min_organization_name}
    {% elsif pivot._parameter_value == 'practitioner_name' %} ${min_practitioner_name}
    {% elsif pivot._parameter_value == 'patient_postal_code' %} ${min_postal_code}
    {% elsif pivot._parameter_value == 'patient_age_tier' %} ${min_age}
    {% elsif pivot._parameter_value == 'patient_gender' %} ${min_gender}
    {% else %} ${min_organization_name}
    {% endif %}
    ;;
    # {% elsif pivot._parameter_value == 'count_comorbid' %} ${count_comorbid}
    }
}
