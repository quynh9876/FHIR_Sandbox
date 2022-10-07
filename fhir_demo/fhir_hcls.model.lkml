connection: "lookerdata"

include: "/fhir_demo/*.view.lkml"                # include all views in the views/ folder in this project
# include: "/**/view.lkml"                   # include all views in this project
include: "/fhir_demo/*.dashboard.lookml"   # include a LookML dashboard called my_dashboard
# include: "my_dashboard.dashboard.lookml"   # include a LookML dashboard called my_dashboard

label: "FHIR Block (HCLS)"

#### CCF Model ####

explore: fhir_hcls_erd {
  extends: [fhir_hcls]
  label: "FHIR - ERD Test"
  fields: [
        encounter.id
      , patient.id
      , observation.id
      , condition.id
      , organization.id
      , practitioner.id
      , procedure.id
      , analytics.admission_date
      , nested_structs.condition__context__encounter_id
      , nested_structs.encounter__subject__patient_id
      , nested_structs.observation__context__encounter_id
      , nested_structs.encounter__service_provider__organization_id
      , nested_structs.encounter__participant__individual__practitioner_id
      , nested_structs.procedure__context__encounter_id
  ]
}

explore: fhir_hcls_simple {
  extends: [fhir_hcls]
  label: "*FHIR (HCLS - Simple)"
  fields: [
      analytics.admission_date
    , analytics.admission_week
    , analytics.admission_month
    , analytics.patient_age
    , analytics.patient_age_tier
    , analytics.patient_gender
    , analytics.patient_postal_code
    , analytics.patient_state
    , analytics.organization_name
    , analytics.bmi
    , analytics.bmi_weight_tier
    , analytics.count_total_patients
    , analytics.count_total_encounters
    , analytics.covid_status
    , analytics.encounter_type
  ]
}
explore: fhir_hcls {
  label: "*FHIR (HCLS)"
  hidden: no
  extends: [encounter,patient,observation,condition,organization,practitioner,procedure]
  from: encounter
  view_name: encounter

  always_filter: {
    filters: [analytics.admission_date: "7 days"]
  }

### Nested Structs

  join: nested_structs { relationship: one_to_one sql:  ;; }
  join: encounter__identifier__type__coding { relationship: one_to_many sql: LEFT JOIN UNNEST(${nested_structs.encounter__identifier__type__coding}) as encounter__identifier__type__coding ;; }
  join: condition__code__coding { relationship: one_to_many sql: LEFT JOIN UNNEST(${nested_structs.condition__code__coding}) as condition__code__coding ;; }
  join: observation__code__coding { relationship: one_to_many sql: LEFT JOIN UNNEST(${nested_structs.observation__code__coding}) as observation__code__coding ;; }
  join: patient__identifier__type__coding { relationship: one_to_many sql: LEFT JOIN UNNEST(${nested_structs.patient__identifier__type__coding}) as patient__identifier__type__coding ;; }
  join: patient__marital_status__coding { relationship: one_to_many sql: LEFT JOIN UNNEST(${nested_structs.patient__marital_status__coding}) as patient__marital_status__coding ;; }
  join: patient__communication__language__coding { relationship: one_to_many sql: LEFT JOIN UNNEST(${nested_structs.patient__communication__language__coding}) as patient__communication__language__coding ;; }
  join: practitioner__identifier__type__coding { relationship: one_to_many sql: LEFT JOIN UNNEST(${nested_structs.practitioner__identifier__type__coding}) as practitioner__identifier__type__coding ;; }
  join: procedure__code__coding { relationship: one_to_many sql: LEFT JOIN UNNEST(${nested_structs.procedure__code__coding}) as procedure__code__coding ;; }

### Main Joins

  join: condition {
    relationship: one_to_many
    sql_on: ${encounter.id} = ${nested_structs.condition__context__encounter_id} ;;
  }
  join: patient {
    relationship: many_to_one
    sql_on: ${nested_structs.encounter__subject__patient_id} = ${patient.id} ;;
  }
  join: observation {
    relationship: one_to_many
    sql_on: ${encounter.id} = ${nested_structs.observation__context__encounter_id} ;;
  }
  join: organization {
    relationship: many_to_one
    sql_on: ${nested_structs.encounter__service_provider__organization_id} = ${organization.id} ;;
  }
  join: practitioner {
    relationship: many_to_one
    sql_on: ${nested_structs.encounter__participant__individual__practitioner_id} = ${practitioner.id}  ;;
  }
  join: procedure {
    relationship: one_to_many
    sql_on: ${encounter.id} = ${nested_structs.procedure__context__encounter_id} ;;
  }

### Identifier Joins

  join: identifier_observation_kg { fields: [] relationship: one_to_one sql_on: ${encounter.id} = ${identifier_observation_kg.id};;}
  join: identifier_observation_cm { fields: [] relationship: one_to_one sql_on: ${encounter.id} = ${identifier_observation_cm.id};;}
  join: identifier_observation_bmi { fields: [] relationship: one_to_one sql_on: ${encounter.id} = ${identifier_observation_bmi.id};;}

### Join to analytics view

  join: analytics { relationship: one_to_one sql:  ;; }

### Join to COVID & census data

# join: covid {
#   view_label: "Outside Data - COVID (Johns Hopkins)"
#   relationship: many_to_one
#   sql_on:
#                 ${nested_structs.encounter__period__start_raw} = ${covid.measurement_raw}
#                 ${patient__address.postal_code} = cast(${covid.zip} as string)
#             ;;
# }

join: acs_zip_codes_2017_5yr {
  view_label: "Outside Data - Census (ACS)"
  relationship: many_to_one
  sql_on: ${patient__address.postal_code} = ${acs_zip_codes_2017_5yr.geo_id} ;;
}

join: national_averages {
  view_label: "Outside Data - Census (ACS)"
  relationship: many_to_one
  sql_on: 1 = 1 ;;
}

}
explore: acs_zip_codes_2017_5yr { hidden: yes }

##Island Hopping
explore: patient_status {
  from: patient_status_covid
  join: patient_status_location {
    view_label: "Patient Status"
    type: left_outer
    relationship: one_to_one
    sql_on: ${patient_status.patient_id} = ${patient_status_location.patient_id}
      AND ${patient_status.snapshot_date} = ${patient_status_location.snapshot_date};;
  }

  join: patient_status_bed {
    view_label: "Patient Status"
    type: left_outer
    relationship: one_to_one
    sql_on: ${patient_status.patient_id} = ${patient_status_bed.patient_id}
      AND ${patient_status.snapshot_date} = ${patient_status_bed.snapshot_date};;
  }
}
explore: final_patient_status{ hidden: yes }
explore: final_patient_status_patient_details{ hidden: yes }

explore: final_patient_status_dashboard {
  sql_always_where: ${days_since_first_event} IS NOT NULL ;;
  label: "*FHIR (HCLS) - Status-Based"

  join: final_patient_status_patient_details_dashboard {
    view_label: "Patient Details"
    relationship: many_to_one
    sql_on: ${final_patient_status_dashboard.patient_id} = ${final_patient_status_patient_details_dashboard.patient_id} ;;
  }
}










######## END #################

# explore: fhir_ccf_pre {
#   hidden: yes
#   extends: [encounter,patient,observation,condition,organization,practitioner,location]
#   from: encounter
#   view_name: encounter
#   label: "FHIR (CCF) - Pre-Work"

#   sql_always_where: length(${encounter.id}) > 15 ;;

# ### Nested Structs

#   join: nested_structs { relationship: one_to_one sql:  ;; }
# join: encounter__identifier__type__coding { relationship: many_to_one sql: LEFT JOIN UNNEST(${nested_structs.encounter__identifier__type__coding}) as encounter__identifier__type__coding ;; }
# join: condition__code__coding { relationship: many_to_one sql: LEFT JOIN UNNEST(${nested_structs.condition__code__coding}) as condition__code__coding ;; }
# join: location__physical_type__coding { relationship: many_to_one sql: LEFT JOIN UNNEST(${nested_structs.location__physical_type__coding}) as location__physical_type__coding ;; }
# join: observation__code__coding { relationship: many_to_one sql: LEFT JOIN UNNEST(${nested_structs.observation__code__coding}) as observation__code__coding ;; }
# join: patient__identifier__type__coding { relationship: many_to_one sql: LEFT JOIN UNNEST(${nested_structs.patient__identifier__type__coding}) as patient__identifier__type__coding ;; }
# join: patient__marital_status__coding { relationship: many_to_one sql: LEFT JOIN UNNEST(${nested_structs.patient__marital_status__coding}) as patient__marital_status__coding ;; }
# join: practitioner__identifier__type__coding { relationship: many_to_one sql: LEFT JOIN UNNEST(${nested_structs.practitioner__identifier__type__coding}) as practitioner__identifier__type__coding ;; }

# ### Main Joins

# join: condition {
#   relationship: many_to_one
#   sql_on: ${nested_structs.encounter__diagnosis__condition__condition_id} = ${condition.id} ;;
# }
# join: location {
#   relationship: many_to_one
#   sql_on: ${nested_structs.encounter__location__location__location_id} = ${location.id} ;;
# }
# join: patient {
#   relationship: many_to_one
#   sql_on: ${nested_structs.encounter__subject__patient_id} = ${patient.id} ;;
# }
# join: observation {
#   relationship: many_to_one
#   sql_on: ${nested_structs.encounter__subject__patient_id} = ${observation.subject__patient_id} ;;
# }
# join: organization {
#   relationship: many_to_one
#   sql_on: ${patient__general_practitioner.organization_id} = ${organization.id} ;;
# }
# join: practitioner {
#   relationship: many_to_one
#   sql_on: ${nested_structs.encounter__participant__individual__practitioner_id} = ${practitioner.id}  ;;
# }

# ### Bring in ICD 10 codes

# join: icd10_codes_by_ccf_id { fields: [] relationship: one_to_one sql_on: ${patient__identifier.value} = ${icd10_codes_by_ccf_id.value} ;; }
# }


#### Explores on Base Tables ####

explore: condition {
  join: condition__abatement { relationship: one_to_many sql: LEFT JOIN UNNEST([${condition.abatement}]) as condition__abatement ;; }
  join: condition__abatement__age { relationship: one_to_many sql: LEFT JOIN UNNEST([${condition__abatement.age}]) as condition__abatement__age ;; }
  join: condition__abatement__period { relationship: one_to_many sql: LEFT JOIN UNNEST([${condition__abatement.period}]) as condition__abatement__period ;; }
  join: condition__abatement__range { relationship: one_to_many sql: LEFT JOIN UNNEST([${condition__abatement.range}]) as condition__abatement__range ;; }
  join: condition__abatement__range__high { relationship: one_to_many sql: LEFT JOIN UNNEST([${condition__abatement__range.high}]) as condition__abatement__range__high ;; }
  join: condition__abatement__range__low { relationship: one_to_many sql: LEFT JOIN UNNEST([${condition__abatement__range.low}]) as condition__abatement__range__low ;; }
  join: condition__asserter { relationship: one_to_many sql: LEFT JOIN UNNEST([${condition.asserter}]) as condition__asserter ;; }
  join: condition__asserter__identifier { relationship: one_to_many sql: LEFT JOIN UNNEST([${condition__asserter.identifier}]) as condition__asserter__identifier ;; }
  join: condition__asserter__identifier__assigner { relationship: one_to_many sql: LEFT JOIN UNNEST([${condition__asserter__identifier.assigner}]) as condition__asserter__identifier__assigner ;; }
  join: condition__asserter__identifier__period { relationship: one_to_many sql: LEFT JOIN UNNEST([${condition__asserter__identifier.period}]) as condition__asserter__identifier__period ;; }
  join: condition__asserter__identifier__type { relationship: one_to_many sql: LEFT JOIN UNNEST([${condition__asserter__identifier.type}]) as condition__asserter__identifier__type ;; }
  join: condition__asserter__identifier__assigner__identifier { relationship: one_to_many sql: LEFT JOIN UNNEST([${condition__asserter__identifier__assigner.identifier}]) as condition__asserter__identifier__assigner__identifier ;; }
  join: condition__asserter__identifier__assigner__identifier__assigner { relationship: one_to_many sql: LEFT JOIN UNNEST([${condition__asserter__identifier__assigner__identifier.assigner}]) as condition__asserter__identifier__assigner__identifier__assigner ;; }
  join: condition__asserter__identifier__assigner__identifier__period { relationship: one_to_many sql: LEFT JOIN UNNEST([${condition__asserter__identifier__assigner__identifier.period}]) as condition__asserter__identifier__assigner__identifier__period ;; }
  join: condition__asserter__identifier__assigner__identifier__type { relationship: one_to_many sql: LEFT JOIN UNNEST([${condition__asserter__identifier__assigner__identifier.type}]) as condition__asserter__identifier__assigner__identifier__type ;; }
  join: condition__asserter__identifier__assigner__identifier__type__coding { relationship: one_to_many sql: LEFT JOIN UNNEST(${condition__asserter__identifier__assigner__identifier__type.coding}) as condition__asserter__identifier__assigner__identifier__type__coding ;; }
  join: condition__asserter__identifier__type__coding { relationship: one_to_many sql: LEFT JOIN UNNEST(${condition__asserter__identifier__type.coding}) as condition__asserter__identifier__type__coding ;; }
  join: condition__body_site { relationship: one_to_many sql: LEFT JOIN UNNEST(${condition.body_site}) as condition__body_site ;; }
  join: condition__body_site__coding { relationship: one_to_many sql: LEFT JOIN UNNEST(${condition__body_site.coding}) as condition__body_site__coding ;; }
  join: condition__category { relationship: one_to_many sql: LEFT JOIN UNNEST(${condition.category}) as condition__category ;; }
  join: condition__category__coding { relationship: one_to_many sql: LEFT JOIN UNNEST(${condition__category.coding}) as condition__category__coding ;; }
  join: condition__code { relationship: one_to_many sql: LEFT JOIN UNNEST([${condition.code}]) as condition__code ;; }
  join: condition__code__coding { relationship: one_to_many sql: LEFT JOIN UNNEST(${condition__code.coding}) as condition__code__coding ;; }
  join: condition__context { relationship: one_to_many sql: LEFT JOIN UNNEST([${condition.context}]) as condition__context ;; }
  join: condition__context__identifier { relationship: one_to_many sql: LEFT JOIN UNNEST([${condition__context.identifier}]) as condition__context__identifier ;; }
  join: condition__context__identifier__assigner { relationship: one_to_many sql: LEFT JOIN UNNEST([${condition__context__identifier.assigner}]) as condition__context__identifier__assigner ;; }
  join: condition__context__identifier__period { relationship: one_to_many sql: LEFT JOIN UNNEST([${condition__context__identifier.period}]) as condition__context__identifier__period ;; }
  join: condition__context__identifier__type { relationship: one_to_many sql: LEFT JOIN UNNEST([${condition__context__identifier.type}]) as condition__context__identifier__type ;; }
  join: condition__context__identifier__assigner__identifier { relationship: one_to_many sql: LEFT JOIN UNNEST([${condition__context__identifier__assigner.identifier}]) as condition__context__identifier__assigner__identifier ;; }
  join: condition__context__identifier__assigner__identifier__assigner { relationship: one_to_many sql: LEFT JOIN UNNEST([${condition__context__identifier__assigner__identifier.assigner}]) as condition__context__identifier__assigner__identifier__assigner ;; }
  join: condition__context__identifier__assigner__identifier__period { relationship: one_to_many sql: LEFT JOIN UNNEST([${condition__context__identifier__assigner__identifier.period}]) as condition__context__identifier__assigner__identifier__period ;; }
  join: condition__context__identifier__assigner__identifier__type { relationship: one_to_many sql: LEFT JOIN UNNEST([${condition__context__identifier__assigner__identifier.type}]) as condition__context__identifier__assigner__identifier__type ;; }
  join: condition__context__identifier__assigner__identifier__type__coding { relationship: one_to_many sql: LEFT JOIN UNNEST(${condition__context__identifier__assigner__identifier__type.coding}) as condition__context__identifier__assigner__identifier__type__coding ;; }
  join: condition__context__identifier__type__coding { relationship: one_to_many sql: LEFT JOIN UNNEST(${condition__context__identifier__type.coding}) as condition__context__identifier__type__coding ;; }
  join: condition__evidence { relationship: one_to_many sql: LEFT JOIN UNNEST(${condition.evidence}) as condition__evidence ;; }
  join: condition__evidence__code { relationship: one_to_many sql: LEFT JOIN UNNEST(${condition__evidence.code}) as condition__evidence__code ;; }
  join: condition__evidence__detail { relationship: one_to_many sql: LEFT JOIN UNNEST(${condition__evidence.detail}) as condition__evidence__detail ;; }
  join: condition__evidence__code__coding { relationship: one_to_many sql: LEFT JOIN UNNEST(${condition__evidence__code.coding}) as condition__evidence__code__coding ;; }
  join: condition__evidence__detail__identifier { relationship: one_to_many sql: LEFT JOIN UNNEST([${condition__evidence__detail.identifier}]) as condition__evidence__detail__identifier ;; }
  join: condition__evidence__detail__identifier__assigner { relationship: one_to_many sql: LEFT JOIN UNNEST([${condition__evidence__detail__identifier.assigner}]) as condition__evidence__detail__identifier__assigner ;; }
  join: condition__evidence__detail__identifier__period { relationship: one_to_many sql: LEFT JOIN UNNEST([${condition__evidence__detail__identifier.period}]) as condition__evidence__detail__identifier__period ;; }
  join: condition__evidence__detail__identifier__type { relationship: one_to_many sql: LEFT JOIN UNNEST([${condition__evidence__detail__identifier.type}]) as condition__evidence__detail__identifier__type ;; }
  join: condition__evidence__detail__identifier__assigner__identifier { relationship: one_to_many sql: LEFT JOIN UNNEST([${condition__evidence__detail__identifier__assigner.identifier}]) as condition__evidence__detail__identifier__assigner__identifier ;; }
  join: condition__evidence__detail__identifier__assigner__identifier__assigner { relationship: one_to_many sql: LEFT JOIN UNNEST([${condition__evidence__detail__identifier__assigner__identifier.assigner}]) as condition__evidence__detail__identifier__assigner__identifier__assigner ;; }
  join: condition__evidence__detail__identifier__assigner__identifier__period { relationship: one_to_many sql: LEFT JOIN UNNEST([${condition__evidence__detail__identifier__assigner__identifier.period}]) as condition__evidence__detail__identifier__assigner__identifier__period ;; }
  join: condition__evidence__detail__identifier__assigner__identifier__type { relationship: one_to_many sql: LEFT JOIN UNNEST([${condition__evidence__detail__identifier__assigner__identifier.type}]) as condition__evidence__detail__identifier__assigner__identifier__type ;; }
  join: condition__evidence__detail__identifier__assigner__identifier__type__coding { relationship: one_to_many sql: LEFT JOIN UNNEST(${condition__evidence__detail__identifier__assigner__identifier__type.coding}) as condition__evidence__detail__identifier__assigner__identifier__type__coding ;; }
  join: condition__evidence__detail__identifier__type__coding { relationship: one_to_many sql: LEFT JOIN UNNEST(${condition__evidence__detail__identifier__type.coding}) as condition__evidence__detail__identifier__type__coding ;; }
  join: condition__identifier { relationship: one_to_many sql: LEFT JOIN UNNEST(${condition.identifier}) as condition__identifier ;; }
  join: condition__identifier__assigner { relationship: one_to_many sql: LEFT JOIN UNNEST([${condition__identifier.assigner}]) as condition__identifier__assigner ;; }
  join: condition__identifier__period { relationship: one_to_many sql: LEFT JOIN UNNEST([${condition__identifier.period}]) as condition__identifier__period ;; }
  join: condition__identifier__type { relationship: one_to_many sql: LEFT JOIN UNNEST([${condition__identifier.type}]) as condition__identifier__type ;; }
  join: condition__identifier__assigner__identifier { relationship: one_to_many sql: LEFT JOIN UNNEST([${condition__identifier__assigner.identifier}]) as condition__identifier__assigner__identifier ;; }
  join: condition__identifier__assigner__identifier__assigner { relationship: one_to_many sql: LEFT JOIN UNNEST([${condition__identifier__assigner__identifier.assigner}]) as condition__identifier__assigner__identifier__assigner ;; }
  join: condition__identifier__assigner__identifier__period { relationship: one_to_many sql: LEFT JOIN UNNEST([${condition__identifier__assigner__identifier.period}]) as condition__identifier__assigner__identifier__period ;; }
  join: condition__identifier__assigner__identifier__type { relationship: one_to_many sql: LEFT JOIN UNNEST([${condition__identifier__assigner__identifier.type}]) as condition__identifier__assigner__identifier__type ;; }
  join: condition__identifier__assigner__identifier__type__coding { relationship: one_to_many sql: LEFT JOIN UNNEST(${condition__identifier__assigner__identifier__type.coding}) as condition__identifier__assigner__identifier__type__coding ;; }
  join: condition__identifier__type__coding { relationship: one_to_many sql: LEFT JOIN UNNEST(${condition__identifier__type.coding}) as condition__identifier__type__coding ;; }
  join: condition__meta { relationship: one_to_many sql: LEFT JOIN UNNEST([${condition.meta}]) as condition__meta ;; }
  join: condition__meta__security { relationship: one_to_many sql: LEFT JOIN UNNEST(${condition__meta.security}) as condition__meta__security ;; }
  join: condition__meta__tag { relationship: one_to_many sql: LEFT JOIN UNNEST(${condition__meta.tag}) as condition__meta__tag ;; }
  join: condition__note { relationship: one_to_many sql: LEFT JOIN UNNEST(${condition.note}) as condition__note ;; }
  join: condition__note__author { relationship: one_to_many sql: LEFT JOIN UNNEST([${condition__note.author}]) as condition__note__author ;; }
  join: condition__note__author__reference { relationship: one_to_many sql: LEFT JOIN UNNEST([${condition__note__author.reference}]) as condition__note__author__reference ;; }
  join: condition__note__author__reference__identifier { relationship: one_to_many sql: LEFT JOIN UNNEST([${condition__note__author__reference.identifier}]) as condition__note__author__reference__identifier ;; }
  join: condition__note__author__reference__identifier__assigner { relationship: one_to_many sql: LEFT JOIN UNNEST([${condition__note__author__reference__identifier.assigner}]) as condition__note__author__reference__identifier__assigner ;; }
  join: condition__note__author__reference__identifier__period { relationship: one_to_many sql: LEFT JOIN UNNEST([${condition__note__author__reference__identifier.period}]) as condition__note__author__reference__identifier__period ;; }
  join: condition__note__author__reference__identifier__type { relationship: one_to_many sql: LEFT JOIN UNNEST([${condition__note__author__reference__identifier.type}]) as condition__note__author__reference__identifier__type ;; }
  join: condition__note__author__reference__identifier__assigner__identifier { relationship: one_to_many sql: LEFT JOIN UNNEST([${condition__note__author__reference__identifier__assigner.identifier}]) as condition__note__author__reference__identifier__assigner__identifier ;; }
  join: condition__note__author__reference__identifier__assigner__identifier__assigner { relationship: one_to_many sql: LEFT JOIN UNNEST([${condition__note__author__reference__identifier__assigner__identifier.assigner}]) as condition__note__author__reference__identifier__assigner__identifier__assigner ;; }
  join: condition__note__author__reference__identifier__assigner__identifier__period { relationship: one_to_many sql: LEFT JOIN UNNEST([${condition__note__author__reference__identifier__assigner__identifier.period}]) as condition__note__author__reference__identifier__assigner__identifier__period ;; }
  join: condition__note__author__reference__identifier__assigner__identifier__type { relationship: one_to_many sql: LEFT JOIN UNNEST([${condition__note__author__reference__identifier__assigner__identifier.type}]) as condition__note__author__reference__identifier__assigner__identifier__type ;; }
  join: condition__note__author__reference__identifier__assigner__identifier__type__coding { relationship: one_to_many sql: LEFT JOIN UNNEST(${condition__note__author__reference__identifier__assigner__identifier__type.coding}) as condition__note__author__reference__identifier__assigner__identifier__type__coding ;; }
  join: condition__note__author__reference__identifier__type__coding { relationship: one_to_many sql: LEFT JOIN UNNEST(${condition__note__author__reference__identifier__type.coding}) as condition__note__author__reference__identifier__type__coding ;; }
  join: condition__onset { relationship: one_to_many sql: LEFT JOIN UNNEST([${condition.onset}]) as condition__onset ;; }
  join: condition__severity { relationship: one_to_many sql: LEFT JOIN UNNEST([${condition.severity}]) as condition__severity ;; }
  join: condition__severity__coding { relationship: one_to_many sql: LEFT JOIN UNNEST(${condition__severity.coding}) as condition__severity__coding ;; }
  join: condition__stage { relationship: one_to_many sql: LEFT JOIN UNNEST([${condition.stage}]) as condition__stage ;; }
  join: condition__stage__assessment { relationship: one_to_many sql: LEFT JOIN UNNEST(${condition__stage.assessment}) as condition__stage__assessment ;; }
  join: condition__stage__summary { relationship: one_to_many sql: LEFT JOIN UNNEST([${condition__stage.summary}]) as condition__stage__summary ;; }
  join: condition__stage__assessment__identifier { relationship: one_to_many sql: LEFT JOIN UNNEST([${condition__stage__assessment.identifier}]) as condition__stage__assessment__identifier ;; }
  join: condition__stage__assessment__identifier__assigner { relationship: one_to_many sql: LEFT JOIN UNNEST([${condition__stage__assessment__identifier.assigner}]) as condition__stage__assessment__identifier__assigner ;; }
  join: condition__stage__assessment__identifier__period { relationship: one_to_many sql: LEFT JOIN UNNEST([${condition__stage__assessment__identifier.period}]) as condition__stage__assessment__identifier__period ;; }
  join: condition__stage__assessment__identifier__type { relationship: one_to_many sql: LEFT JOIN UNNEST([${condition__stage__assessment__identifier.type}]) as condition__stage__assessment__identifier__type ;; }
  join: condition__stage__assessment__identifier__assigner__identifier { relationship: one_to_many sql: LEFT JOIN UNNEST([${condition__stage__assessment__identifier__assigner.identifier}]) as condition__stage__assessment__identifier__assigner__identifier ;; }
  join: condition__stage__assessment__identifier__assigner__identifier__assigner { relationship: one_to_many sql: LEFT JOIN UNNEST([${condition__stage__assessment__identifier__assigner__identifier.assigner}]) as condition__stage__assessment__identifier__assigner__identifier__assigner ;; }
  join: condition__stage__assessment__identifier__assigner__identifier__period { relationship: one_to_many sql: LEFT JOIN UNNEST([${condition__stage__assessment__identifier__assigner__identifier.period}]) as condition__stage__assessment__identifier__assigner__identifier__period ;; }
  join: condition__stage__assessment__identifier__assigner__identifier__type { relationship: one_to_many sql: LEFT JOIN UNNEST([${condition__stage__assessment__identifier__assigner__identifier.type}]) as condition__stage__assessment__identifier__assigner__identifier__type ;; }
  join: condition__stage__assessment__identifier__assigner__identifier__type__coding { relationship: one_to_many sql: LEFT JOIN UNNEST(${condition__stage__assessment__identifier__assigner__identifier__type.coding}) as condition__stage__assessment__identifier__assigner__identifier__type__coding ;; }
  join: condition__stage__assessment__identifier__type__coding { relationship: one_to_many sql: LEFT JOIN UNNEST(${condition__stage__assessment__identifier__type.coding}) as condition__stage__assessment__identifier__type__coding ;; }
  join: condition__stage__summary__coding { relationship: one_to_many sql: LEFT JOIN UNNEST(${condition__stage__summary.coding}) as condition__stage__summary__coding ;; }
  join: condition__subject { relationship: one_to_many sql: LEFT JOIN UNNEST([${condition.subject}]) as condition__subject ;; }
  join: condition__subject__identifier { relationship: one_to_many sql: LEFT JOIN UNNEST([${condition__subject.identifier}]) as condition__subject__identifier ;; }
  join: condition__subject__identifier__assigner { relationship: one_to_many sql: LEFT JOIN UNNEST([${condition__subject__identifier.assigner}]) as condition__subject__identifier__assigner ;; }
  join: condition__subject__identifier__period { relationship: one_to_many sql: LEFT JOIN UNNEST([${condition__subject__identifier.period}]) as condition__subject__identifier__period ;; }
  join: condition__subject__identifier__type { relationship: one_to_many sql: LEFT JOIN UNNEST([${condition__subject__identifier.type}]) as condition__subject__identifier__type ;; }
  join: condition__subject__identifier__assigner__identifier { relationship: one_to_many sql: LEFT JOIN UNNEST([${condition__subject__identifier__assigner.identifier}]) as condition__subject__identifier__assigner__identifier ;; }
  join: condition__subject__identifier__assigner__identifier__assigner { relationship: one_to_many sql: LEFT JOIN UNNEST([${condition__subject__identifier__assigner__identifier.assigner}]) as condition__subject__identifier__assigner__identifier__assigner ;; }
  join: condition__subject__identifier__assigner__identifier__period { relationship: one_to_many sql: LEFT JOIN UNNEST([${condition__subject__identifier__assigner__identifier.period}]) as condition__subject__identifier__assigner__identifier__period ;; }
  join: condition__subject__identifier__assigner__identifier__type { relationship: one_to_many sql: LEFT JOIN UNNEST([${condition__subject__identifier__assigner__identifier.type}]) as condition__subject__identifier__assigner__identifier__type ;; }
  join: condition__subject__identifier__assigner__identifier__type__coding { relationship: one_to_many sql: LEFT JOIN UNNEST(${condition__subject__identifier__assigner__identifier__type.coding}) as condition__subject__identifier__assigner__identifier__type__coding ;; }
  join: condition__subject__identifier__type__coding { relationship: one_to_many sql: LEFT JOIN UNNEST(${condition__subject__identifier__type.coding}) as condition__subject__identifier__type__coding ;; }
  join: condition__text { relationship: one_to_many sql: LEFT JOIN UNNEST([${condition.text}]) as condition__text ;; }
}

explore: diagnosticreport {
  join: diagnosticreport__based_on { relationship: one_to_many sql: LEFT JOIN UNNEST(${diagnosticreport.based_on}) as diagnosticreport__based_on ;; }
  join: diagnosticreport__based_on__identifier { relationship: one_to_many sql: LEFT JOIN UNNEST([${diagnosticreport__based_on.identifier}]) as diagnosticreport__based_on__identifier ;; }
  join: diagnosticreport__based_on__identifier__assigner { relationship: one_to_many sql: LEFT JOIN UNNEST([${diagnosticreport__based_on__identifier.assigner}]) as diagnosticreport__based_on__identifier__assigner ;; }
  join: diagnosticreport__based_on__identifier__period { relationship: one_to_many sql: LEFT JOIN UNNEST([${diagnosticreport__based_on__identifier.period}]) as diagnosticreport__based_on__identifier__period ;; }
  join: diagnosticreport__based_on__identifier__type { relationship: one_to_many sql: LEFT JOIN UNNEST([${diagnosticreport__based_on__identifier.type}]) as diagnosticreport__based_on__identifier__type ;; }
  join: diagnosticreport__based_on__identifier__assigner__identifier { relationship: one_to_many sql: LEFT JOIN UNNEST([${diagnosticreport__based_on__identifier__assigner.identifier}]) as diagnosticreport__based_on__identifier__assigner__identifier ;; }
  join: diagnosticreport__based_on__identifier__assigner__identifier__assigner { relationship: one_to_many sql: LEFT JOIN UNNEST([${diagnosticreport__based_on__identifier__assigner__identifier.assigner}]) as diagnosticreport__based_on__identifier__assigner__identifier__assigner ;; }
  join: diagnosticreport__based_on__identifier__assigner__identifier__period { relationship: one_to_many sql: LEFT JOIN UNNEST([${diagnosticreport__based_on__identifier__assigner__identifier.period}]) as diagnosticreport__based_on__identifier__assigner__identifier__period ;; }
  join: diagnosticreport__based_on__identifier__assigner__identifier__type { relationship: one_to_many sql: LEFT JOIN UNNEST([${diagnosticreport__based_on__identifier__assigner__identifier.type}]) as diagnosticreport__based_on__identifier__assigner__identifier__type ;; }
  join: diagnosticreport__based_on__identifier__assigner__identifier__type__coding { relationship: one_to_many sql: LEFT JOIN UNNEST(${diagnosticreport__based_on__identifier__assigner__identifier__type.coding}) as diagnosticreport__based_on__identifier__assigner__identifier__type__coding ;; }
  join: diagnosticreport__based_on__identifier__type__coding { relationship: one_to_many sql: LEFT JOIN UNNEST(${diagnosticreport__based_on__identifier__type.coding}) as diagnosticreport__based_on__identifier__type__coding ;; }
  join: diagnosticreport__category { relationship: one_to_many sql: LEFT JOIN UNNEST([${diagnosticreport.category}]) as diagnosticreport__category ;; }
  join: diagnosticreport__category__coding { relationship: one_to_many sql: LEFT JOIN UNNEST(${diagnosticreport__category.coding}) as diagnosticreport__category__coding ;; }
  join: diagnosticreport__code { relationship: one_to_many sql: LEFT JOIN UNNEST([${diagnosticreport.code}]) as diagnosticreport__code ;; }
  join: diagnosticreport__code__coding { relationship: one_to_many sql: LEFT JOIN UNNEST(${diagnosticreport__code.coding}) as diagnosticreport__code__coding ;; }
  join: diagnosticreport__coded_diagnosis { relationship: one_to_many sql: LEFT JOIN UNNEST(${diagnosticreport.coded_diagnosis}) as diagnosticreport__coded_diagnosis ;; }
  join: diagnosticreport__coded_diagnosis__coding { relationship: one_to_many sql: LEFT JOIN UNNEST(${diagnosticreport__coded_diagnosis.coding}) as diagnosticreport__coded_diagnosis__coding ;; }
  join: diagnosticreport__context { relationship: one_to_many sql: LEFT JOIN UNNEST([${diagnosticreport.context}]) as diagnosticreport__context ;; }
  join: diagnosticreport__context__identifier { relationship: one_to_many sql: LEFT JOIN UNNEST([${diagnosticreport__context.identifier}]) as diagnosticreport__context__identifier ;; }
  join: diagnosticreport__context__identifier__assigner { relationship: one_to_many sql: LEFT JOIN UNNEST([${diagnosticreport__context__identifier.assigner}]) as diagnosticreport__context__identifier__assigner ;; }
  join: diagnosticreport__context__identifier__period { relationship: one_to_many sql: LEFT JOIN UNNEST([${diagnosticreport__context__identifier.period}]) as diagnosticreport__context__identifier__period ;; }
  join: diagnosticreport__context__identifier__type { relationship: one_to_many sql: LEFT JOIN UNNEST([${diagnosticreport__context__identifier.type}]) as diagnosticreport__context__identifier__type ;; }
  join: diagnosticreport__context__identifier__assigner__identifier { relationship: one_to_many sql: LEFT JOIN UNNEST([${diagnosticreport__context__identifier__assigner.identifier}]) as diagnosticreport__context__identifier__assigner__identifier ;; }
  join: diagnosticreport__context__identifier__assigner__identifier__assigner { relationship: one_to_many sql: LEFT JOIN UNNEST([${diagnosticreport__context__identifier__assigner__identifier.assigner}]) as diagnosticreport__context__identifier__assigner__identifier__assigner ;; }
  join: diagnosticreport__context__identifier__assigner__identifier__period { relationship: one_to_many sql: LEFT JOIN UNNEST([${diagnosticreport__context__identifier__assigner__identifier.period}]) as diagnosticreport__context__identifier__assigner__identifier__period ;; }
  join: diagnosticreport__context__identifier__assigner__identifier__type { relationship: one_to_many sql: LEFT JOIN UNNEST([${diagnosticreport__context__identifier__assigner__identifier.type}]) as diagnosticreport__context__identifier__assigner__identifier__type ;; }
  join: diagnosticreport__context__identifier__assigner__identifier__type__coding { relationship: one_to_many sql: LEFT JOIN UNNEST(${diagnosticreport__context__identifier__assigner__identifier__type.coding}) as diagnosticreport__context__identifier__assigner__identifier__type__coding ;; }
  join: diagnosticreport__context__identifier__type__coding { relationship: one_to_many sql: LEFT JOIN UNNEST(${diagnosticreport__context__identifier__type.coding}) as diagnosticreport__context__identifier__type__coding ;; }
  join: diagnosticreport__effective { relationship: one_to_many sql: LEFT JOIN UNNEST([${diagnosticreport.effective}]) as diagnosticreport__effective ;; }
  join: diagnosticreport__identifier { relationship: one_to_many sql: LEFT JOIN UNNEST(${diagnosticreport.identifier}) as diagnosticreport__identifier ;; }
  join: diagnosticreport__identifier__assigner { relationship: one_to_many sql: LEFT JOIN UNNEST([${diagnosticreport__identifier.assigner}]) as diagnosticreport__identifier__assigner ;; }
  join: diagnosticreport__identifier__period { relationship: one_to_many sql: LEFT JOIN UNNEST([${diagnosticreport__identifier.period}]) as diagnosticreport__identifier__period ;; }
  join: diagnosticreport__identifier__type { relationship: one_to_many sql: LEFT JOIN UNNEST([${diagnosticreport__identifier.type}]) as diagnosticreport__identifier__type ;; }
  join: diagnosticreport__identifier__assigner__identifier { relationship: one_to_many sql: LEFT JOIN UNNEST([${diagnosticreport__identifier__assigner.identifier}]) as diagnosticreport__identifier__assigner__identifier ;; }
  join: diagnosticreport__identifier__assigner__identifier__assigner { relationship: one_to_many sql: LEFT JOIN UNNEST([${diagnosticreport__identifier__assigner__identifier.assigner}]) as diagnosticreport__identifier__assigner__identifier__assigner ;; }
  join: diagnosticreport__identifier__assigner__identifier__period { relationship: one_to_many sql: LEFT JOIN UNNEST([${diagnosticreport__identifier__assigner__identifier.period}]) as diagnosticreport__identifier__assigner__identifier__period ;; }
  join: diagnosticreport__identifier__assigner__identifier__type { relationship: one_to_many sql: LEFT JOIN UNNEST([${diagnosticreport__identifier__assigner__identifier.type}]) as diagnosticreport__identifier__assigner__identifier__type ;; }
  join: diagnosticreport__identifier__assigner__identifier__type__coding { relationship: one_to_many sql: LEFT JOIN UNNEST(${diagnosticreport__identifier__assigner__identifier__type.coding}) as diagnosticreport__identifier__assigner__identifier__type__coding ;; }
  join: diagnosticreport__identifier__type__coding { relationship: one_to_many sql: LEFT JOIN UNNEST(${diagnosticreport__identifier__type.coding}) as diagnosticreport__identifier__type__coding ;; }
  join: diagnosticreport__image { relationship: one_to_many sql: LEFT JOIN UNNEST(${diagnosticreport.image}) as diagnosticreport__image ;; }
  join: diagnosticreport__image__link { relationship: one_to_many sql: LEFT JOIN UNNEST([${diagnosticreport__image.link}]) as diagnosticreport__image__link ;; }
  join: diagnosticreport__image__link__identifier { relationship: one_to_many sql: LEFT JOIN UNNEST([${diagnosticreport__image__link.identifier}]) as diagnosticreport__image__link__identifier ;; }
  join: diagnosticreport__image__link__identifier__assigner { relationship: one_to_many sql: LEFT JOIN UNNEST([${diagnosticreport__image__link__identifier.assigner}]) as diagnosticreport__image__link__identifier__assigner ;; }
  join: diagnosticreport__image__link__identifier__period { relationship: one_to_many sql: LEFT JOIN UNNEST([${diagnosticreport__image__link__identifier.period}]) as diagnosticreport__image__link__identifier__period ;; }
  join: diagnosticreport__image__link__identifier__type { relationship: one_to_many sql: LEFT JOIN UNNEST([${diagnosticreport__image__link__identifier.type}]) as diagnosticreport__image__link__identifier__type ;; }
  join: diagnosticreport__image__link__identifier__assigner__identifier { relationship: one_to_many sql: LEFT JOIN UNNEST([${diagnosticreport__image__link__identifier__assigner.identifier}]) as diagnosticreport__image__link__identifier__assigner__identifier ;; }
  join: diagnosticreport__image__link__identifier__assigner__identifier__assigner { relationship: one_to_many sql: LEFT JOIN UNNEST([${diagnosticreport__image__link__identifier__assigner__identifier.assigner}]) as diagnosticreport__image__link__identifier__assigner__identifier__assigner ;; }
  join: diagnosticreport__image__link__identifier__assigner__identifier__period { relationship: one_to_many sql: LEFT JOIN UNNEST([${diagnosticreport__image__link__identifier__assigner__identifier.period}]) as diagnosticreport__image__link__identifier__assigner__identifier__period ;; }
  join: diagnosticreport__image__link__identifier__assigner__identifier__type { relationship: one_to_many sql: LEFT JOIN UNNEST([${diagnosticreport__image__link__identifier__assigner__identifier.type}]) as diagnosticreport__image__link__identifier__assigner__identifier__type ;; }
  join: diagnosticreport__image__link__identifier__assigner__identifier__type__coding { relationship: one_to_many sql: LEFT JOIN UNNEST(${diagnosticreport__image__link__identifier__assigner__identifier__type.coding}) as diagnosticreport__image__link__identifier__assigner__identifier__type__coding ;; }
  join: diagnosticreport__image__link__identifier__type__coding { relationship: one_to_many sql: LEFT JOIN UNNEST(${diagnosticreport__image__link__identifier__type.coding}) as diagnosticreport__image__link__identifier__type__coding ;; }
  join: diagnosticreport__imaging_study { relationship: one_to_many sql: LEFT JOIN UNNEST(${diagnosticreport.imaging_study}) as diagnosticreport__imaging_study ;; }
  join: diagnosticreport__imaging_study__identifier { relationship: one_to_many sql: LEFT JOIN UNNEST([${diagnosticreport__imaging_study.identifier}]) as diagnosticreport__imaging_study__identifier ;; }
  join: diagnosticreport__imaging_study__identifier__assigner { relationship: one_to_many sql: LEFT JOIN UNNEST([${diagnosticreport__imaging_study__identifier.assigner}]) as diagnosticreport__imaging_study__identifier__assigner ;; }
  join: diagnosticreport__imaging_study__identifier__period { relationship: one_to_many sql: LEFT JOIN UNNEST([${diagnosticreport__imaging_study__identifier.period}]) as diagnosticreport__imaging_study__identifier__period ;; }
  join: diagnosticreport__imaging_study__identifier__type { relationship: one_to_many sql: LEFT JOIN UNNEST([${diagnosticreport__imaging_study__identifier.type}]) as diagnosticreport__imaging_study__identifier__type ;; }
  join: diagnosticreport__imaging_study__identifier__assigner__identifier { relationship: one_to_many sql: LEFT JOIN UNNEST([${diagnosticreport__imaging_study__identifier__assigner.identifier}]) as diagnosticreport__imaging_study__identifier__assigner__identifier ;; }
  join: diagnosticreport__imaging_study__identifier__assigner__identifier__assigner { relationship: one_to_many sql: LEFT JOIN UNNEST([${diagnosticreport__imaging_study__identifier__assigner__identifier.assigner}]) as diagnosticreport__imaging_study__identifier__assigner__identifier__assigner ;; }
  join: diagnosticreport__imaging_study__identifier__assigner__identifier__period { relationship: one_to_many sql: LEFT JOIN UNNEST([${diagnosticreport__imaging_study__identifier__assigner__identifier.period}]) as diagnosticreport__imaging_study__identifier__assigner__identifier__period ;; }
  join: diagnosticreport__imaging_study__identifier__assigner__identifier__type { relationship: one_to_many sql: LEFT JOIN UNNEST([${diagnosticreport__imaging_study__identifier__assigner__identifier.type}]) as diagnosticreport__imaging_study__identifier__assigner__identifier__type ;; }
  join: diagnosticreport__imaging_study__identifier__assigner__identifier__type__coding { relationship: one_to_many sql: LEFT JOIN UNNEST(${diagnosticreport__imaging_study__identifier__assigner__identifier__type.coding}) as diagnosticreport__imaging_study__identifier__assigner__identifier__type__coding ;; }
  join: diagnosticreport__imaging_study__identifier__type__coding { relationship: one_to_many sql: LEFT JOIN UNNEST(${diagnosticreport__imaging_study__identifier__type.coding}) as diagnosticreport__imaging_study__identifier__type__coding ;; }
  join: diagnosticreport__meta { relationship: one_to_many sql: LEFT JOIN UNNEST([${diagnosticreport.meta}]) as diagnosticreport__meta ;; }
  join: diagnosticreport__meta__security { relationship: one_to_many sql: LEFT JOIN UNNEST(${diagnosticreport__meta.security}) as diagnosticreport__meta__security ;; }
  join: diagnosticreport__meta__tag { relationship: one_to_many sql: LEFT JOIN UNNEST(${diagnosticreport__meta.tag}) as diagnosticreport__meta__tag ;; }
  join: diagnosticreport__performer { relationship: one_to_many sql: LEFT JOIN UNNEST(${diagnosticreport.performer}) as diagnosticreport__performer ;; }
  join: diagnosticreport__performer__actor { relationship: one_to_many sql: LEFT JOIN UNNEST([${diagnosticreport__performer.actor}]) as diagnosticreport__performer__actor ;; }
  join: diagnosticreport__performer__role { relationship: one_to_many sql: LEFT JOIN UNNEST([${diagnosticreport__performer.role}]) as diagnosticreport__performer__role ;; }
  join: diagnosticreport__performer__actor__identifier { relationship: one_to_many sql: LEFT JOIN UNNEST([${diagnosticreport__performer__actor.identifier}]) as diagnosticreport__performer__actor__identifier ;; }
  join: diagnosticreport__performer__actor__identifier__assigner { relationship: one_to_many sql: LEFT JOIN UNNEST([${diagnosticreport__performer__actor__identifier.assigner}]) as diagnosticreport__performer__actor__identifier__assigner ;; }
  join: diagnosticreport__performer__actor__identifier__period { relationship: one_to_many sql: LEFT JOIN UNNEST([${diagnosticreport__performer__actor__identifier.period}]) as diagnosticreport__performer__actor__identifier__period ;; }
  join: diagnosticreport__performer__actor__identifier__type { relationship: one_to_many sql: LEFT JOIN UNNEST([${diagnosticreport__performer__actor__identifier.type}]) as diagnosticreport__performer__actor__identifier__type ;; }
  join: diagnosticreport__performer__actor__identifier__assigner__identifier { relationship: one_to_many sql: LEFT JOIN UNNEST([${diagnosticreport__performer__actor__identifier__assigner.identifier}]) as diagnosticreport__performer__actor__identifier__assigner__identifier ;; }
  join: diagnosticreport__performer__actor__identifier__assigner__identifier__assigner { relationship: one_to_many sql: LEFT JOIN UNNEST([${diagnosticreport__performer__actor__identifier__assigner__identifier.assigner}]) as diagnosticreport__performer__actor__identifier__assigner__identifier__assigner ;; }
  join: diagnosticreport__performer__actor__identifier__assigner__identifier__period { relationship: one_to_many sql: LEFT JOIN UNNEST([${diagnosticreport__performer__actor__identifier__assigner__identifier.period}]) as diagnosticreport__performer__actor__identifier__assigner__identifier__period ;; }
  join: diagnosticreport__performer__actor__identifier__assigner__identifier__type { relationship: one_to_many sql: LEFT JOIN UNNEST([${diagnosticreport__performer__actor__identifier__assigner__identifier.type}]) as diagnosticreport__performer__actor__identifier__assigner__identifier__type ;; }
  join: diagnosticreport__performer__actor__identifier__assigner__identifier__type__coding { relationship: one_to_many sql: LEFT JOIN UNNEST(${diagnosticreport__performer__actor__identifier__assigner__identifier__type.coding}) as diagnosticreport__performer__actor__identifier__assigner__identifier__type__coding ;; }
  join: diagnosticreport__performer__actor__identifier__type__coding { relationship: one_to_many sql: LEFT JOIN UNNEST(${diagnosticreport__performer__actor__identifier__type.coding}) as diagnosticreport__performer__actor__identifier__type__coding ;; }
  join: diagnosticreport__performer__role__coding { relationship: one_to_many sql: LEFT JOIN UNNEST(${diagnosticreport__performer__role.coding}) as diagnosticreport__performer__role__coding ;; }
  join: diagnosticreport__presented_form { relationship: one_to_many sql: LEFT JOIN UNNEST(${diagnosticreport.presented_form}) as diagnosticreport__presented_form ;; }
  join: diagnosticreport__result { relationship: one_to_many sql: LEFT JOIN UNNEST(${diagnosticreport.result}) as diagnosticreport__result ;; }
  join: diagnosticreport__result__identifier { relationship: one_to_many sql: LEFT JOIN UNNEST([${diagnosticreport__result.identifier}]) as diagnosticreport__result__identifier ;; }
  join: diagnosticreport__result__identifier__assigner { relationship: one_to_many sql: LEFT JOIN UNNEST([${diagnosticreport__result__identifier.assigner}]) as diagnosticreport__result__identifier__assigner ;; }
  join: diagnosticreport__result__identifier__period { relationship: one_to_many sql: LEFT JOIN UNNEST([${diagnosticreport__result__identifier.period}]) as diagnosticreport__result__identifier__period ;; }
  join: diagnosticreport__result__identifier__type { relationship: one_to_many sql: LEFT JOIN UNNEST([${diagnosticreport__result__identifier.type}]) as diagnosticreport__result__identifier__type ;; }
  join: diagnosticreport__result__identifier__assigner__identifier { relationship: one_to_many sql: LEFT JOIN UNNEST([${diagnosticreport__result__identifier__assigner.identifier}]) as diagnosticreport__result__identifier__assigner__identifier ;; }
  join: diagnosticreport__result__identifier__assigner__identifier__assigner { relationship: one_to_many sql: LEFT JOIN UNNEST([${diagnosticreport__result__identifier__assigner__identifier.assigner}]) as diagnosticreport__result__identifier__assigner__identifier__assigner ;; }
  join: diagnosticreport__result__identifier__assigner__identifier__period { relationship: one_to_many sql: LEFT JOIN UNNEST([${diagnosticreport__result__identifier__assigner__identifier.period}]) as diagnosticreport__result__identifier__assigner__identifier__period ;; }
  join: diagnosticreport__result__identifier__assigner__identifier__type { relationship: one_to_many sql: LEFT JOIN UNNEST([${diagnosticreport__result__identifier__assigner__identifier.type}]) as diagnosticreport__result__identifier__assigner__identifier__type ;; }
  join: diagnosticreport__result__identifier__assigner__identifier__type__coding { relationship: one_to_many sql: LEFT JOIN UNNEST(${diagnosticreport__result__identifier__assigner__identifier__type.coding}) as diagnosticreport__result__identifier__assigner__identifier__type__coding ;; }
  join: diagnosticreport__result__identifier__type__coding { relationship: one_to_many sql: LEFT JOIN UNNEST(${diagnosticreport__result__identifier__type.coding}) as diagnosticreport__result__identifier__type__coding ;; }
  join: diagnosticreport__specimen { relationship: one_to_many sql: LEFT JOIN UNNEST(${diagnosticreport.specimen}) as diagnosticreport__specimen ;; }
  join: diagnosticreport__specimen__identifier { relationship: one_to_many sql: LEFT JOIN UNNEST([${diagnosticreport__specimen.identifier}]) as diagnosticreport__specimen__identifier ;; }
  join: diagnosticreport__specimen__identifier__assigner { relationship: one_to_many sql: LEFT JOIN UNNEST([${diagnosticreport__specimen__identifier.assigner}]) as diagnosticreport__specimen__identifier__assigner ;; }
  join: diagnosticreport__specimen__identifier__period { relationship: one_to_many sql: LEFT JOIN UNNEST([${diagnosticreport__specimen__identifier.period}]) as diagnosticreport__specimen__identifier__period ;; }
  join: diagnosticreport__specimen__identifier__type { relationship: one_to_many sql: LEFT JOIN UNNEST([${diagnosticreport__specimen__identifier.type}]) as diagnosticreport__specimen__identifier__type ;; }
  join: diagnosticreport__specimen__identifier__assigner__identifier { relationship: one_to_many sql: LEFT JOIN UNNEST([${diagnosticreport__specimen__identifier__assigner.identifier}]) as diagnosticreport__specimen__identifier__assigner__identifier ;; }
  join: diagnosticreport__specimen__identifier__assigner__identifier__assigner { relationship: one_to_many sql: LEFT JOIN UNNEST([${diagnosticreport__specimen__identifier__assigner__identifier.assigner}]) as diagnosticreport__specimen__identifier__assigner__identifier__assigner ;; }
  join: diagnosticreport__specimen__identifier__assigner__identifier__period { relationship: one_to_many sql: LEFT JOIN UNNEST([${diagnosticreport__specimen__identifier__assigner__identifier.period}]) as diagnosticreport__specimen__identifier__assigner__identifier__period ;; }
  join: diagnosticreport__specimen__identifier__assigner__identifier__type { relationship: one_to_many sql: LEFT JOIN UNNEST([${diagnosticreport__specimen__identifier__assigner__identifier.type}]) as diagnosticreport__specimen__identifier__assigner__identifier__type ;; }
  join: diagnosticreport__specimen__identifier__assigner__identifier__type__coding { relationship: one_to_many sql: LEFT JOIN UNNEST(${diagnosticreport__specimen__identifier__assigner__identifier__type.coding}) as diagnosticreport__specimen__identifier__assigner__identifier__type__coding ;; }
  join: diagnosticreport__specimen__identifier__type__coding { relationship: one_to_many sql: LEFT JOIN UNNEST(${diagnosticreport__specimen__identifier__type.coding}) as diagnosticreport__specimen__identifier__type__coding ;; }
  join: diagnosticreport__subject { relationship: one_to_many sql: LEFT JOIN UNNEST([${diagnosticreport.subject}]) as diagnosticreport__subject ;; }
  join: diagnosticreport__subject__identifier { relationship: one_to_many sql: LEFT JOIN UNNEST([${diagnosticreport__subject.identifier}]) as diagnosticreport__subject__identifier ;; }
  join: diagnosticreport__subject__identifier__assigner { relationship: one_to_many sql: LEFT JOIN UNNEST([${diagnosticreport__subject__identifier.assigner}]) as diagnosticreport__subject__identifier__assigner ;; }
  join: diagnosticreport__subject__identifier__period { relationship: one_to_many sql: LEFT JOIN UNNEST([${diagnosticreport__subject__identifier.period}]) as diagnosticreport__subject__identifier__period ;; }
  join: diagnosticreport__subject__identifier__type { relationship: one_to_many sql: LEFT JOIN UNNEST([${diagnosticreport__subject__identifier.type}]) as diagnosticreport__subject__identifier__type ;; }
  join: diagnosticreport__subject__identifier__assigner__identifier { relationship: one_to_many sql: LEFT JOIN UNNEST([${diagnosticreport__subject__identifier__assigner.identifier}]) as diagnosticreport__subject__identifier__assigner__identifier ;; }
  join: diagnosticreport__subject__identifier__assigner__identifier__assigner { relationship: one_to_many sql: LEFT JOIN UNNEST([${diagnosticreport__subject__identifier__assigner__identifier.assigner}]) as diagnosticreport__subject__identifier__assigner__identifier__assigner ;; }
  join: diagnosticreport__subject__identifier__assigner__identifier__period { relationship: one_to_many sql: LEFT JOIN UNNEST([${diagnosticreport__subject__identifier__assigner__identifier.period}]) as diagnosticreport__subject__identifier__assigner__identifier__period ;; }
  join: diagnosticreport__subject__identifier__assigner__identifier__type { relationship: one_to_many sql: LEFT JOIN UNNEST([${diagnosticreport__subject__identifier__assigner__identifier.type}]) as diagnosticreport__subject__identifier__assigner__identifier__type ;; }
  join: diagnosticreport__subject__identifier__assigner__identifier__type__coding { relationship: one_to_many sql: LEFT JOIN UNNEST(${diagnosticreport__subject__identifier__assigner__identifier__type.coding}) as diagnosticreport__subject__identifier__assigner__identifier__type__coding ;; }
  join: diagnosticreport__subject__identifier__type__coding { relationship: one_to_many sql: LEFT JOIN UNNEST(${diagnosticreport__subject__identifier__type.coding}) as diagnosticreport__subject__identifier__type__coding ;; }
  join: diagnosticreport__text { relationship: one_to_many sql: LEFT JOIN UNNEST([${diagnosticreport.text}]) as diagnosticreport__text ;; }
}

explore: encounter {
  join: encounter__account { relationship: one_to_many sql: LEFT JOIN UNNEST(${encounter.account}) as encounter__account ;; }
  join: encounter__account__identifier { relationship: one_to_many sql: LEFT JOIN UNNEST([${encounter__account.identifier}]) as encounter__account__identifier ;; }
  join: encounter__account__identifier__assigner { relationship: one_to_many sql: LEFT JOIN UNNEST([${encounter__account__identifier.assigner}]) as encounter__account__identifier__assigner ;; }
  join: encounter__account__identifier__period { relationship: one_to_many sql: LEFT JOIN UNNEST([${encounter__account__identifier.period}]) as encounter__account__identifier__period ;; }
  join: encounter__account__identifier__type { relationship: one_to_many sql: LEFT JOIN UNNEST([${encounter__account__identifier.type}]) as encounter__account__identifier__type ;; }
  join: encounter__account__identifier__assigner__identifier { relationship: one_to_many sql: LEFT JOIN UNNEST([${encounter__account__identifier__assigner.identifier}]) as encounter__account__identifier__assigner__identifier ;; }
  join: encounter__account__identifier__assigner__identifier__assigner { relationship: one_to_many sql: LEFT JOIN UNNEST([${encounter__account__identifier__assigner__identifier.assigner}]) as encounter__account__identifier__assigner__identifier__assigner ;; }
  join: encounter__account__identifier__assigner__identifier__period { relationship: one_to_many sql: LEFT JOIN UNNEST([${encounter__account__identifier__assigner__identifier.period}]) as encounter__account__identifier__assigner__identifier__period ;; }
  join: encounter__account__identifier__assigner__identifier__type { relationship: one_to_many sql: LEFT JOIN UNNEST([${encounter__account__identifier__assigner__identifier.type}]) as encounter__account__identifier__assigner__identifier__type ;; }
  join: encounter__account__identifier__assigner__identifier__type__coding { relationship: one_to_many sql: LEFT JOIN UNNEST(${encounter__account__identifier__assigner__identifier__type.coding}) as encounter__account__identifier__assigner__identifier__type__coding ;; }
  join: encounter__account__identifier__type__coding { relationship: one_to_many sql: LEFT JOIN UNNEST(${encounter__account__identifier__type.coding}) as encounter__account__identifier__type__coding ;; }
  join: encounter__appointment { relationship: one_to_many sql: LEFT JOIN UNNEST([${encounter.appointment}]) as encounter__appointment ;; }
  join: encounter__appointment__identifier { relationship: one_to_many sql: LEFT JOIN UNNEST([${encounter__appointment.identifier}]) as encounter__appointment__identifier ;; }
  join: encounter__appointment__identifier__assigner { relationship: one_to_many sql: LEFT JOIN UNNEST([${encounter__appointment__identifier.assigner}]) as encounter__appointment__identifier__assigner ;; }
  join: encounter__appointment__identifier__period { relationship: one_to_many sql: LEFT JOIN UNNEST([${encounter__appointment__identifier.period}]) as encounter__appointment__identifier__period ;; }
  join: encounter__appointment__identifier__type { relationship: one_to_many sql: LEFT JOIN UNNEST([${encounter__appointment__identifier.type}]) as encounter__appointment__identifier__type ;; }
  join: encounter__appointment__identifier__assigner__identifier { relationship: one_to_many sql: LEFT JOIN UNNEST([${encounter__appointment__identifier__assigner.identifier}]) as encounter__appointment__identifier__assigner__identifier ;; }
  join: encounter__appointment__identifier__assigner__identifier__assigner { relationship: one_to_many sql: LEFT JOIN UNNEST([${encounter__appointment__identifier__assigner__identifier.assigner}]) as encounter__appointment__identifier__assigner__identifier__assigner ;; }
  join: encounter__appointment__identifier__assigner__identifier__period { relationship: one_to_many sql: LEFT JOIN UNNEST([${encounter__appointment__identifier__assigner__identifier.period}]) as encounter__appointment__identifier__assigner__identifier__period ;; }
  join: encounter__appointment__identifier__assigner__identifier__type { relationship: one_to_many sql: LEFT JOIN UNNEST([${encounter__appointment__identifier__assigner__identifier.type}]) as encounter__appointment__identifier__assigner__identifier__type ;; }
  join: encounter__appointment__identifier__assigner__identifier__type__coding { relationship: one_to_many sql: LEFT JOIN UNNEST(${encounter__appointment__identifier__assigner__identifier__type.coding}) as encounter__appointment__identifier__assigner__identifier__type__coding ;; }
  join: encounter__appointment__identifier__type__coding { relationship: one_to_many sql: LEFT JOIN UNNEST(${encounter__appointment__identifier__type.coding}) as encounter__appointment__identifier__type__coding ;; }
  join: encounter__class { relationship: one_to_many sql: LEFT JOIN UNNEST([${encounter.class}]) as encounter__class ;; }
  join: encounter__class_history { relationship: one_to_many sql: LEFT JOIN UNNEST(${encounter.class_history}) as encounter__class_history ;; }
  join: encounter__class_history__class { relationship: one_to_many sql: LEFT JOIN UNNEST([${encounter__class_history.class}]) as encounter__class_history__class ;; }
  join: encounter__class_history__period { relationship: one_to_many sql: LEFT JOIN UNNEST([${encounter__class_history.period}]) as encounter__class_history__period ;; }
  join: encounter__diagnosis { relationship: one_to_many sql: LEFT JOIN UNNEST(${encounter.diagnosis}) as encounter__diagnosis ;; }
  join: encounter__diagnosis__condition { relationship: one_to_many sql: LEFT JOIN UNNEST([${encounter__diagnosis.condition}]) as encounter__diagnosis__condition ;; }
  join: encounter__diagnosis__role { relationship: one_to_many sql: LEFT JOIN UNNEST([${encounter__diagnosis.role}]) as encounter__diagnosis__role ;; }
  join: encounter__diagnosis__condition__identifier { relationship: one_to_many sql: LEFT JOIN UNNEST([${encounter__diagnosis__condition.identifier}]) as encounter__diagnosis__condition__identifier ;; }
  join: encounter__diagnosis__condition__identifier__assigner { relationship: one_to_many sql: LEFT JOIN UNNEST([${encounter__diagnosis__condition__identifier.assigner}]) as encounter__diagnosis__condition__identifier__assigner ;; }
  join: encounter__diagnosis__condition__identifier__period { relationship: one_to_many sql: LEFT JOIN UNNEST([${encounter__diagnosis__condition__identifier.period}]) as encounter__diagnosis__condition__identifier__period ;; }
  join: encounter__diagnosis__condition__identifier__type { relationship: one_to_many sql: LEFT JOIN UNNEST([${encounter__diagnosis__condition__identifier.type}]) as encounter__diagnosis__condition__identifier__type ;; }
  join: encounter__diagnosis__condition__identifier__assigner__identifier { relationship: one_to_many sql: LEFT JOIN UNNEST([${encounter__diagnosis__condition__identifier__assigner.identifier}]) as encounter__diagnosis__condition__identifier__assigner__identifier ;; }
  join: encounter__diagnosis__condition__identifier__assigner__identifier__assigner { relationship: one_to_many sql: LEFT JOIN UNNEST([${encounter__diagnosis__condition__identifier__assigner__identifier.assigner}]) as encounter__diagnosis__condition__identifier__assigner__identifier__assigner ;; }
  join: encounter__diagnosis__condition__identifier__assigner__identifier__period { relationship: one_to_many sql: LEFT JOIN UNNEST([${encounter__diagnosis__condition__identifier__assigner__identifier.period}]) as encounter__diagnosis__condition__identifier__assigner__identifier__period ;; }
  join: encounter__diagnosis__condition__identifier__assigner__identifier__type { relationship: one_to_many sql: LEFT JOIN UNNEST([${encounter__diagnosis__condition__identifier__assigner__identifier.type}]) as encounter__diagnosis__condition__identifier__assigner__identifier__type ;; }
  join: encounter__diagnosis__condition__identifier__assigner__identifier__type__coding { relationship: one_to_many sql: LEFT JOIN UNNEST(${encounter__diagnosis__condition__identifier__assigner__identifier__type.coding}) as encounter__diagnosis__condition__identifier__assigner__identifier__type__coding ;; }
  join: encounter__diagnosis__condition__identifier__type__coding { relationship: one_to_many sql: LEFT JOIN UNNEST(${encounter__diagnosis__condition__identifier__type.coding}) as encounter__diagnosis__condition__identifier__type__coding ;; }
  join: encounter__diagnosis__role__coding { relationship: one_to_many sql: LEFT JOIN UNNEST(${encounter__diagnosis__role.coding}) as encounter__diagnosis__role__coding ;; }
  join: encounter__episode_of_care { relationship: one_to_many sql: LEFT JOIN UNNEST(${encounter.episode_of_care}) as encounter__episode_of_care ;; }
  join: encounter__episode_of_care__identifier { relationship: one_to_many sql: LEFT JOIN UNNEST([${encounter__episode_of_care.identifier}]) as encounter__episode_of_care__identifier ;; }
  join: encounter__episode_of_care__identifier__assigner { relationship: one_to_many sql: LEFT JOIN UNNEST([${encounter__episode_of_care__identifier.assigner}]) as encounter__episode_of_care__identifier__assigner ;; }
  join: encounter__episode_of_care__identifier__period { relationship: one_to_many sql: LEFT JOIN UNNEST([${encounter__episode_of_care__identifier.period}]) as encounter__episode_of_care__identifier__period ;; }
  join: encounter__episode_of_care__identifier__type { relationship: one_to_many sql: LEFT JOIN UNNEST([${encounter__episode_of_care__identifier.type}]) as encounter__episode_of_care__identifier__type ;; }
  join: encounter__episode_of_care__identifier__assigner__identifier { relationship: one_to_many sql: LEFT JOIN UNNEST([${encounter__episode_of_care__identifier__assigner.identifier}]) as encounter__episode_of_care__identifier__assigner__identifier ;; }
  join: encounter__episode_of_care__identifier__assigner__identifier__assigner { relationship: one_to_many sql: LEFT JOIN UNNEST([${encounter__episode_of_care__identifier__assigner__identifier.assigner}]) as encounter__episode_of_care__identifier__assigner__identifier__assigner ;; }
  join: encounter__episode_of_care__identifier__assigner__identifier__period { relationship: one_to_many sql: LEFT JOIN UNNEST([${encounter__episode_of_care__identifier__assigner__identifier.period}]) as encounter__episode_of_care__identifier__assigner__identifier__period ;; }
  join: encounter__episode_of_care__identifier__assigner__identifier__type { relationship: one_to_many sql: LEFT JOIN UNNEST([${encounter__episode_of_care__identifier__assigner__identifier.type}]) as encounter__episode_of_care__identifier__assigner__identifier__type ;; }
  join: encounter__episode_of_care__identifier__assigner__identifier__type__coding { relationship: one_to_many sql: LEFT JOIN UNNEST(${encounter__episode_of_care__identifier__assigner__identifier__type.coding}) as encounter__episode_of_care__identifier__assigner__identifier__type__coding ;; }
  join: encounter__episode_of_care__identifier__type__coding { relationship: one_to_many sql: LEFT JOIN UNNEST(${encounter__episode_of_care__identifier__type.coding}) as encounter__episode_of_care__identifier__type__coding ;; }
  join: encounter__hospitalization { relationship: one_to_many sql: LEFT JOIN UNNEST([${encounter.hospitalization}]) as encounter__hospitalization ;; }
  join: encounter__hospitalization__admit_source { relationship: one_to_many sql: LEFT JOIN UNNEST([${encounter__hospitalization.admit_source}]) as encounter__hospitalization__admit_source ;; }
  join: encounter__hospitalization__destination { relationship: one_to_many sql: LEFT JOIN UNNEST([${encounter__hospitalization.destination}]) as encounter__hospitalization__destination ;; }
  join: encounter__hospitalization__diet_preference { relationship: one_to_many sql: LEFT JOIN UNNEST(${encounter__hospitalization.diet_preference}) as encounter__hospitalization__diet_preference ;; }
  join: encounter__hospitalization__discharge_disposition { relationship: one_to_many sql: LEFT JOIN UNNEST([${encounter__hospitalization.discharge_disposition}]) as encounter__hospitalization__discharge_disposition ;; }
  join: encounter__hospitalization__origin { relationship: one_to_many sql: LEFT JOIN UNNEST([${encounter__hospitalization.origin}]) as encounter__hospitalization__origin ;; }
  join: encounter__hospitalization__pre_admission_identifier { relationship: one_to_many sql: LEFT JOIN UNNEST([${encounter__hospitalization.pre_admission_identifier}]) as encounter__hospitalization__pre_admission_identifier ;; }
  join: encounter__hospitalization__re_admission { relationship: one_to_many sql: LEFT JOIN UNNEST([${encounter__hospitalization.re_admission}]) as encounter__hospitalization__re_admission ;; }
  join: encounter__hospitalization__special_arrangement { relationship: one_to_many sql: LEFT JOIN UNNEST(${encounter__hospitalization.special_arrangement}) as encounter__hospitalization__special_arrangement ;; }
  join: encounter__hospitalization__special_courtesy { relationship: one_to_many sql: LEFT JOIN UNNEST(${encounter__hospitalization.special_courtesy}) as encounter__hospitalization__special_courtesy ;; }
  join: encounter__hospitalization__admit_source__coding { relationship: one_to_many sql: LEFT JOIN UNNEST(${encounter__hospitalization__admit_source.coding}) as encounter__hospitalization__admit_source__coding ;; }
  join: encounter__hospitalization__destination__identifier { relationship: one_to_many sql: LEFT JOIN UNNEST([${encounter__hospitalization__destination.identifier}]) as encounter__hospitalization__destination__identifier ;; }
  join: encounter__hospitalization__destination__identifier__assigner { relationship: one_to_many sql: LEFT JOIN UNNEST([${encounter__hospitalization__destination__identifier.assigner}]) as encounter__hospitalization__destination__identifier__assigner ;; }
  join: encounter__hospitalization__destination__identifier__period { relationship: one_to_many sql: LEFT JOIN UNNEST([${encounter__hospitalization__destination__identifier.period}]) as encounter__hospitalization__destination__identifier__period ;; }
  join: encounter__hospitalization__destination__identifier__type { relationship: one_to_many sql: LEFT JOIN UNNEST([${encounter__hospitalization__destination__identifier.type}]) as encounter__hospitalization__destination__identifier__type ;; }
  join: encounter__hospitalization__destination__identifier__assigner__identifier { relationship: one_to_many sql: LEFT JOIN UNNEST([${encounter__hospitalization__destination__identifier__assigner.identifier}]) as encounter__hospitalization__destination__identifier__assigner__identifier ;; }
  join: encounter__hospitalization__destination__identifier__assigner__identifier__assigner { relationship: one_to_many sql: LEFT JOIN UNNEST([${encounter__hospitalization__destination__identifier__assigner__identifier.assigner}]) as encounter__hospitalization__destination__identifier__assigner__identifier__assigner ;; }
  join: encounter__hospitalization__destination__identifier__assigner__identifier__period { relationship: one_to_many sql: LEFT JOIN UNNEST([${encounter__hospitalization__destination__identifier__assigner__identifier.period}]) as encounter__hospitalization__destination__identifier__assigner__identifier__period ;; }
  join: encounter__hospitalization__destination__identifier__assigner__identifier__type { relationship: one_to_many sql: LEFT JOIN UNNEST([${encounter__hospitalization__destination__identifier__assigner__identifier.type}]) as encounter__hospitalization__destination__identifier__assigner__identifier__type ;; }
  join: encounter__hospitalization__destination__identifier__assigner__identifier__type__coding { relationship: one_to_many sql: LEFT JOIN UNNEST(${encounter__hospitalization__destination__identifier__assigner__identifier__type.coding}) as encounter__hospitalization__destination__identifier__assigner__identifier__type__coding ;; }
  join: encounter__hospitalization__destination__identifier__type__coding { relationship: one_to_many sql: LEFT JOIN UNNEST(${encounter__hospitalization__destination__identifier__type.coding}) as encounter__hospitalization__destination__identifier__type__coding ;; }
  join: encounter__hospitalization__diet_preference__coding { relationship: one_to_many sql: LEFT JOIN UNNEST(${encounter__hospitalization__diet_preference.coding}) as encounter__hospitalization__diet_preference__coding ;; }
  join: encounter__hospitalization__discharge_disposition__coding { relationship: one_to_many sql: LEFT JOIN UNNEST(${encounter__hospitalization__discharge_disposition.coding}) as encounter__hospitalization__discharge_disposition__coding ;; }
  join: encounter__hospitalization__origin__identifier { relationship: one_to_many sql: LEFT JOIN UNNEST([${encounter__hospitalization__origin.identifier}]) as encounter__hospitalization__origin__identifier ;; }
  join: encounter__hospitalization__origin__identifier__assigner { relationship: one_to_many sql: LEFT JOIN UNNEST([${encounter__hospitalization__origin__identifier.assigner}]) as encounter__hospitalization__origin__identifier__assigner ;; }
  join: encounter__hospitalization__origin__identifier__period { relationship: one_to_many sql: LEFT JOIN UNNEST([${encounter__hospitalization__origin__identifier.period}]) as encounter__hospitalization__origin__identifier__period ;; }
  join: encounter__hospitalization__origin__identifier__type { relationship: one_to_many sql: LEFT JOIN UNNEST([${encounter__hospitalization__origin__identifier.type}]) as encounter__hospitalization__origin__identifier__type ;; }
  join: encounter__hospitalization__origin__identifier__assigner__identifier { relationship: one_to_many sql: LEFT JOIN UNNEST([${encounter__hospitalization__origin__identifier__assigner.identifier}]) as encounter__hospitalization__origin__identifier__assigner__identifier ;; }
  join: encounter__hospitalization__origin__identifier__assigner__identifier__assigner { relationship: one_to_many sql: LEFT JOIN UNNEST([${encounter__hospitalization__origin__identifier__assigner__identifier.assigner}]) as encounter__hospitalization__origin__identifier__assigner__identifier__assigner ;; }
  join: encounter__hospitalization__origin__identifier__assigner__identifier__period { relationship: one_to_many sql: LEFT JOIN UNNEST([${encounter__hospitalization__origin__identifier__assigner__identifier.period}]) as encounter__hospitalization__origin__identifier__assigner__identifier__period ;; }
  join: encounter__hospitalization__origin__identifier__assigner__identifier__type { relationship: one_to_many sql: LEFT JOIN UNNEST([${encounter__hospitalization__origin__identifier__assigner__identifier.type}]) as encounter__hospitalization__origin__identifier__assigner__identifier__type ;; }
  join: encounter__hospitalization__origin__identifier__assigner__identifier__type__coding { relationship: one_to_many sql: LEFT JOIN UNNEST(${encounter__hospitalization__origin__identifier__assigner__identifier__type.coding}) as encounter__hospitalization__origin__identifier__assigner__identifier__type__coding ;; }
  join: encounter__hospitalization__origin__identifier__type__coding { relationship: one_to_many sql: LEFT JOIN UNNEST(${encounter__hospitalization__origin__identifier__type.coding}) as encounter__hospitalization__origin__identifier__type__coding ;; }
  join: encounter__hospitalization__pre_admission_identifier__assigner { relationship: one_to_many sql: LEFT JOIN UNNEST([${encounter__hospitalization__pre_admission_identifier.assigner}]) as encounter__hospitalization__pre_admission_identifier__assigner ;; }
  join: encounter__hospitalization__pre_admission_identifier__period { relationship: one_to_many sql: LEFT JOIN UNNEST([${encounter__hospitalization__pre_admission_identifier.period}]) as encounter__hospitalization__pre_admission_identifier__period ;; }
  join: encounter__hospitalization__pre_admission_identifier__type { relationship: one_to_many sql: LEFT JOIN UNNEST([${encounter__hospitalization__pre_admission_identifier.type}]) as encounter__hospitalization__pre_admission_identifier__type ;; }
  join: encounter__hospitalization__pre_admission_identifier__assigner__identifier { relationship: one_to_many sql: LEFT JOIN UNNEST([${encounter__hospitalization__pre_admission_identifier__assigner.identifier}]) as encounter__hospitalization__pre_admission_identifier__assigner__identifier ;; }
  join: encounter__hospitalization__pre_admission_identifier__assigner__identifier__assigner { relationship: one_to_many sql: LEFT JOIN UNNEST([${encounter__hospitalization__pre_admission_identifier__assigner__identifier.assigner}]) as encounter__hospitalization__pre_admission_identifier__assigner__identifier__assigner ;; }
  join: encounter__hospitalization__pre_admission_identifier__assigner__identifier__period { relationship: one_to_many sql: LEFT JOIN UNNEST([${encounter__hospitalization__pre_admission_identifier__assigner__identifier.period}]) as encounter__hospitalization__pre_admission_identifier__assigner__identifier__period ;; }
  join: encounter__hospitalization__pre_admission_identifier__assigner__identifier__type { relationship: one_to_many sql: LEFT JOIN UNNEST([${encounter__hospitalization__pre_admission_identifier__assigner__identifier.type}]) as encounter__hospitalization__pre_admission_identifier__assigner__identifier__type ;; }
  join: encounter__hospitalization__pre_admission_identifier__assigner__identifier__assigner__identifier { relationship: one_to_many sql: LEFT JOIN UNNEST([${encounter__hospitalization__pre_admission_identifier__assigner__identifier__assigner.identifier}]) as encounter__hospitalization__pre_admission_identifier__assigner__identifier__assigner__identifier ;; }
  join: encounter__hospitalization__pre_admission_identifier__assigner__identifier__assigner__identifier__period { relationship: one_to_many sql: LEFT JOIN UNNEST([${encounter__hospitalization__pre_admission_identifier__assigner__identifier__assigner__identifier.period}]) as encounter__hospitalization__pre_admission_identifier__assigner__identifier__assigner__identifier__period ;; }
  join: encounter__hospitalization__pre_admission_identifier__assigner__identifier__assigner__identifier__type { relationship: one_to_many sql: LEFT JOIN UNNEST([${encounter__hospitalization__pre_admission_identifier__assigner__identifier__assigner__identifier.type}]) as encounter__hospitalization__pre_admission_identifier__assigner__identifier__assigner__identifier__type ;; }
  join: encounter__hospitalization__pre_admission_identifier__assigner__identifier__assigner__identifier__type__coding { relationship: one_to_many sql: LEFT JOIN UNNEST(${encounter__hospitalization__pre_admission_identifier__assigner__identifier__assigner__identifier__type.coding}) as encounter__hospitalization__pre_admission_identifier__assigner__identifier__assigner__identifier__type__coding ;; }
  join: encounter__hospitalization__pre_admission_identifier__assigner__identifier__type__coding { relationship: one_to_many sql: LEFT JOIN UNNEST(${encounter__hospitalization__pre_admission_identifier__assigner__identifier__type.coding}) as encounter__hospitalization__pre_admission_identifier__assigner__identifier__type__coding ;; }
  join: encounter__hospitalization__pre_admission_identifier__type__coding { relationship: one_to_many sql: LEFT JOIN UNNEST(${encounter__hospitalization__pre_admission_identifier__type.coding}) as encounter__hospitalization__pre_admission_identifier__type__coding ;; }
  join: encounter__hospitalization__re_admission__coding { relationship: one_to_many sql: LEFT JOIN UNNEST(${encounter__hospitalization__re_admission.coding}) as encounter__hospitalization__re_admission__coding ;; }
  join: encounter__hospitalization__special_arrangement__coding { relationship: one_to_many sql: LEFT JOIN UNNEST(${encounter__hospitalization__special_arrangement.coding}) as encounter__hospitalization__special_arrangement__coding ;; }
  join: encounter__hospitalization__special_courtesy__coding { relationship: one_to_many sql: LEFT JOIN UNNEST(${encounter__hospitalization__special_courtesy.coding}) as encounter__hospitalization__special_courtesy__coding ;; }
  join: encounter__identifier { relationship: one_to_many sql: LEFT JOIN UNNEST(${encounter.identifier}) as encounter__identifier ;; }
  join: encounter__identifier__assigner { relationship: one_to_many sql: LEFT JOIN UNNEST([${encounter__identifier.assigner}]) as encounter__identifier__assigner ;; }
  join: encounter__identifier__period { relationship: one_to_many sql: LEFT JOIN UNNEST([${encounter__identifier.period}]) as encounter__identifier__period ;; }
  join: encounter__identifier__type { relationship: one_to_many sql: LEFT JOIN UNNEST([${encounter__identifier.type}]) as encounter__identifier__type ;; }
  join: encounter__identifier__assigner__identifier { relationship: one_to_many sql: LEFT JOIN UNNEST([${encounter__identifier__assigner.identifier}]) as encounter__identifier__assigner__identifier ;; }
  join: encounter__identifier__assigner__identifier__assigner { relationship: one_to_many sql: LEFT JOIN UNNEST([${encounter__identifier__assigner__identifier.assigner}]) as encounter__identifier__assigner__identifier__assigner ;; }
  join: encounter__identifier__assigner__identifier__period { relationship: one_to_many sql: LEFT JOIN UNNEST([${encounter__identifier__assigner__identifier.period}]) as encounter__identifier__assigner__identifier__period ;; }
  join: encounter__identifier__assigner__identifier__type { relationship: one_to_many sql: LEFT JOIN UNNEST([${encounter__identifier__assigner__identifier.type}]) as encounter__identifier__assigner__identifier__type ;; }
  join: encounter__identifier__assigner__identifier__type__coding { relationship: one_to_many sql: LEFT JOIN UNNEST(${encounter__identifier__assigner__identifier__type.coding}) as encounter__identifier__assigner__identifier__type__coding ;; }
  join: encounter__identifier__type__coding { relationship: one_to_many sql: LEFT JOIN UNNEST(${encounter__identifier__type.coding}) as encounter__identifier__type__coding ;; }
  join: encounter__incoming_referral { relationship: one_to_many sql: LEFT JOIN UNNEST(${encounter.incoming_referral}) as encounter__incoming_referral ;; }
  join: encounter__incoming_referral__identifier { relationship: one_to_many sql: LEFT JOIN UNNEST([${encounter__incoming_referral.identifier}]) as encounter__incoming_referral__identifier ;; }
  join: encounter__incoming_referral__identifier__assigner { relationship: one_to_many sql: LEFT JOIN UNNEST([${encounter__incoming_referral__identifier.assigner}]) as encounter__incoming_referral__identifier__assigner ;; }
  join: encounter__incoming_referral__identifier__period { relationship: one_to_many sql: LEFT JOIN UNNEST([${encounter__incoming_referral__identifier.period}]) as encounter__incoming_referral__identifier__period ;; }
  join: encounter__incoming_referral__identifier__type { relationship: one_to_many sql: LEFT JOIN UNNEST([${encounter__incoming_referral__identifier.type}]) as encounter__incoming_referral__identifier__type ;; }
  join: encounter__incoming_referral__identifier__assigner__identifier { relationship: one_to_many sql: LEFT JOIN UNNEST([${encounter__incoming_referral__identifier__assigner.identifier}]) as encounter__incoming_referral__identifier__assigner__identifier ;; }
  join: encounter__incoming_referral__identifier__assigner__identifier__assigner { relationship: one_to_many sql: LEFT JOIN UNNEST([${encounter__incoming_referral__identifier__assigner__identifier.assigner}]) as encounter__incoming_referral__identifier__assigner__identifier__assigner ;; }
  join: encounter__incoming_referral__identifier__assigner__identifier__period { relationship: one_to_many sql: LEFT JOIN UNNEST([${encounter__incoming_referral__identifier__assigner__identifier.period}]) as encounter__incoming_referral__identifier__assigner__identifier__period ;; }
  join: encounter__incoming_referral__identifier__assigner__identifier__type { relationship: one_to_many sql: LEFT JOIN UNNEST([${encounter__incoming_referral__identifier__assigner__identifier.type}]) as encounter__incoming_referral__identifier__assigner__identifier__type ;; }
  join: encounter__incoming_referral__identifier__assigner__identifier__type__coding { relationship: one_to_many sql: LEFT JOIN UNNEST(${encounter__incoming_referral__identifier__assigner__identifier__type.coding}) as encounter__incoming_referral__identifier__assigner__identifier__type__coding ;; }
  join: encounter__incoming_referral__identifier__type__coding { relationship: one_to_many sql: LEFT JOIN UNNEST(${encounter__incoming_referral__identifier__type.coding}) as encounter__incoming_referral__identifier__type__coding ;; }
  join: encounter__length { relationship: one_to_many sql: LEFT JOIN UNNEST([${encounter.length}]) as encounter__length ;; }
  join: encounter__location { relationship: one_to_many sql: LEFT JOIN UNNEST(${encounter.location}) as encounter__location ;; }
  join: encounter__location__location { relationship: one_to_many sql: LEFT JOIN UNNEST([${encounter__location.location}]) as encounter__location__location ;; }
  join: encounter__location__period { relationship: one_to_many sql: LEFT JOIN UNNEST([${encounter__location.period}]) as encounter__location__period ;; }
  join: encounter__location__location__identifier { relationship: one_to_many sql: LEFT JOIN UNNEST([${encounter__location__location.identifier}]) as encounter__location__location__identifier ;; }
  join: encounter__location__location__identifier__assigner { relationship: one_to_many sql: LEFT JOIN UNNEST([${encounter__location__location__identifier.assigner}]) as encounter__location__location__identifier__assigner ;; }
  join: encounter__location__location__identifier__period { relationship: one_to_many sql: LEFT JOIN UNNEST([${encounter__location__location__identifier.period}]) as encounter__location__location__identifier__period ;; }
  join: encounter__location__location__identifier__type { relationship: one_to_many sql: LEFT JOIN UNNEST([${encounter__location__location__identifier.type}]) as encounter__location__location__identifier__type ;; }
  join: encounter__location__location__identifier__assigner__identifier { relationship: one_to_many sql: LEFT JOIN UNNEST([${encounter__location__location__identifier__assigner.identifier}]) as encounter__location__location__identifier__assigner__identifier ;; }
  join: encounter__location__location__identifier__assigner__identifier__assigner { relationship: one_to_many sql: LEFT JOIN UNNEST([${encounter__location__location__identifier__assigner__identifier.assigner}]) as encounter__location__location__identifier__assigner__identifier__assigner ;; }
  join: encounter__location__location__identifier__assigner__identifier__period { relationship: one_to_many sql: LEFT JOIN UNNEST([${encounter__location__location__identifier__assigner__identifier.period}]) as encounter__location__location__identifier__assigner__identifier__period ;; }
  join: encounter__location__location__identifier__assigner__identifier__type { relationship: one_to_many sql: LEFT JOIN UNNEST([${encounter__location__location__identifier__assigner__identifier.type}]) as encounter__location__location__identifier__assigner__identifier__type ;; }
  join: encounter__location__location__identifier__assigner__identifier__type__coding { relationship: one_to_many sql: LEFT JOIN UNNEST(${encounter__location__location__identifier__assigner__identifier__type.coding}) as encounter__location__location__identifier__assigner__identifier__type__coding ;; }
  join: encounter__location__location__identifier__type__coding { relationship: one_to_many sql: LEFT JOIN UNNEST(${encounter__location__location__identifier__type.coding}) as encounter__location__location__identifier__type__coding ;; }
  join: encounter__meta { relationship: one_to_many sql: LEFT JOIN UNNEST([${encounter.meta}]) as encounter__meta ;; }
  join: encounter__meta__security { relationship: one_to_many sql: LEFT JOIN UNNEST(${encounter__meta.security}) as encounter__meta__security ;; }
  join: encounter__meta__tag { relationship: one_to_many sql: LEFT JOIN UNNEST(${encounter__meta.tag}) as encounter__meta__tag ;; }
  join: encounter__part_of { relationship: one_to_many sql: LEFT JOIN UNNEST([${encounter.part_of}]) as encounter__part_of ;; }
  join: encounter__part_of__identifier { relationship: one_to_many sql: LEFT JOIN UNNEST([${encounter__part_of.identifier}]) as encounter__part_of__identifier ;; }
  join: encounter__part_of__identifier__assigner { relationship: one_to_many sql: LEFT JOIN UNNEST([${encounter__part_of__identifier.assigner}]) as encounter__part_of__identifier__assigner ;; }
  join: encounter__part_of__identifier__period { relationship: one_to_many sql: LEFT JOIN UNNEST([${encounter__part_of__identifier.period}]) as encounter__part_of__identifier__period ;; }
  join: encounter__part_of__identifier__type { relationship: one_to_many sql: LEFT JOIN UNNEST([${encounter__part_of__identifier.type}]) as encounter__part_of__identifier__type ;; }
  join: encounter__part_of__identifier__assigner__identifier { relationship: one_to_many sql: LEFT JOIN UNNEST([${encounter__part_of__identifier__assigner.identifier}]) as encounter__part_of__identifier__assigner__identifier ;; }
  join: encounter__part_of__identifier__assigner__identifier__assigner { relationship: one_to_many sql: LEFT JOIN UNNEST([${encounter__part_of__identifier__assigner__identifier.assigner}]) as encounter__part_of__identifier__assigner__identifier__assigner ;; }
  join: encounter__part_of__identifier__assigner__identifier__period { relationship: one_to_many sql: LEFT JOIN UNNEST([${encounter__part_of__identifier__assigner__identifier.period}]) as encounter__part_of__identifier__assigner__identifier__period ;; }
  join: encounter__part_of__identifier__assigner__identifier__type { relationship: one_to_many sql: LEFT JOIN UNNEST([${encounter__part_of__identifier__assigner__identifier.type}]) as encounter__part_of__identifier__assigner__identifier__type ;; }
  join: encounter__part_of__identifier__assigner__identifier__type__coding { relationship: one_to_many sql: LEFT JOIN UNNEST(${encounter__part_of__identifier__assigner__identifier__type.coding}) as encounter__part_of__identifier__assigner__identifier__type__coding ;; }
  join: encounter__part_of__identifier__type__coding { relationship: one_to_many sql: LEFT JOIN UNNEST(${encounter__part_of__identifier__type.coding}) as encounter__part_of__identifier__type__coding ;; }
  join: encounter__participant { relationship: one_to_many sql: LEFT JOIN UNNEST(${encounter.participant}) as encounter__participant ;; }
  join: encounter__participant__individual { relationship: one_to_many sql: LEFT JOIN UNNEST([${encounter__participant.individual}]) as encounter__participant__individual ;; }
  join: encounter__participant__period { relationship: one_to_many sql: LEFT JOIN UNNEST([${encounter__participant.period}]) as encounter__participant__period ;; }
  join: encounter__participant__type { relationship: one_to_many sql: LEFT JOIN UNNEST(${encounter__participant.type}) as encounter__participant__type ;; }
  join: encounter__participant__individual__identifier { relationship: one_to_many sql: LEFT JOIN UNNEST([${encounter__participant__individual.identifier}]) as encounter__participant__individual__identifier ;; }
  join: encounter__participant__individual__identifier__assigner { relationship: one_to_many sql: LEFT JOIN UNNEST([${encounter__participant__individual__identifier.assigner}]) as encounter__participant__individual__identifier__assigner ;; }
  join: encounter__participant__individual__identifier__period { relationship: one_to_many sql: LEFT JOIN UNNEST([${encounter__participant__individual__identifier.period}]) as encounter__participant__individual__identifier__period ;; }
  join: encounter__participant__individual__identifier__type { relationship: one_to_many sql: LEFT JOIN UNNEST([${encounter__participant__individual__identifier.type}]) as encounter__participant__individual__identifier__type ;; }
  join: encounter__participant__individual__identifier__assigner__identifier { relationship: one_to_many sql: LEFT JOIN UNNEST([${encounter__participant__individual__identifier__assigner.identifier}]) as encounter__participant__individual__identifier__assigner__identifier ;; }
  join: encounter__participant__individual__identifier__assigner__identifier__assigner { relationship: one_to_many sql: LEFT JOIN UNNEST([${encounter__participant__individual__identifier__assigner__identifier.assigner}]) as encounter__participant__individual__identifier__assigner__identifier__assigner ;; }
  join: encounter__participant__individual__identifier__assigner__identifier__period { relationship: one_to_many sql: LEFT JOIN UNNEST([${encounter__participant__individual__identifier__assigner__identifier.period}]) as encounter__participant__individual__identifier__assigner__identifier__period ;; }
  join: encounter__participant__individual__identifier__assigner__identifier__type { relationship: one_to_many sql: LEFT JOIN UNNEST([${encounter__participant__individual__identifier__assigner__identifier.type}]) as encounter__participant__individual__identifier__assigner__identifier__type ;; }
  join: encounter__participant__individual__identifier__assigner__identifier__type__coding { relationship: one_to_many sql: LEFT JOIN UNNEST(${encounter__participant__individual__identifier__assigner__identifier__type.coding}) as encounter__participant__individual__identifier__assigner__identifier__type__coding ;; }
  join: encounter__participant__individual__identifier__type__coding { relationship: one_to_many sql: LEFT JOIN UNNEST(${encounter__participant__individual__identifier__type.coding}) as encounter__participant__individual__identifier__type__coding ;; }
  join: encounter__participant__type__coding { relationship: one_to_many sql: LEFT JOIN UNNEST(${encounter__participant__type.coding}) as encounter__participant__type__coding ;; }
  join: encounter__period { relationship: one_to_many sql: LEFT JOIN UNNEST([${encounter.period}]) as encounter__period ;; }
  join: encounter__priority { relationship: one_to_many sql: LEFT JOIN UNNEST([${encounter.priority}]) as encounter__priority ;; }
  join: encounter__priority__coding { relationship: one_to_many sql: LEFT JOIN UNNEST(${encounter__priority.coding}) as encounter__priority__coding ;; }
  join: encounter__reason { relationship: one_to_many sql: LEFT JOIN UNNEST(${encounter.reason}) as encounter__reason ;; }
  join: encounter__reason__coding { relationship: one_to_many sql: LEFT JOIN UNNEST(${encounter__reason.coding}) as encounter__reason__coding ;; }
  join: encounter__service_provider { relationship: one_to_many sql: LEFT JOIN UNNEST([${encounter.service_provider}]) as encounter__service_provider ;; }
  join: encounter__service_provider__identifier { relationship: one_to_many sql: LEFT JOIN UNNEST([${encounter__service_provider.identifier}]) as encounter__service_provider__identifier ;; }
  join: encounter__service_provider__identifier__assigner { relationship: one_to_many sql: LEFT JOIN UNNEST([${encounter__service_provider__identifier.assigner}]) as encounter__service_provider__identifier__assigner ;; }
  join: encounter__service_provider__identifier__period { relationship: one_to_many sql: LEFT JOIN UNNEST([${encounter__service_provider__identifier.period}]) as encounter__service_provider__identifier__period ;; }
  join: encounter__service_provider__identifier__type { relationship: one_to_many sql: LEFT JOIN UNNEST([${encounter__service_provider__identifier.type}]) as encounter__service_provider__identifier__type ;; }
  join: encounter__service_provider__identifier__assigner__identifier { relationship: one_to_many sql: LEFT JOIN UNNEST([${encounter__service_provider__identifier__assigner.identifier}]) as encounter__service_provider__identifier__assigner__identifier ;; }
  join: encounter__service_provider__identifier__assigner__identifier__assigner { relationship: one_to_many sql: LEFT JOIN UNNEST([${encounter__service_provider__identifier__assigner__identifier.assigner}]) as encounter__service_provider__identifier__assigner__identifier__assigner ;; }
  join: encounter__service_provider__identifier__assigner__identifier__period { relationship: one_to_many sql: LEFT JOIN UNNEST([${encounter__service_provider__identifier__assigner__identifier.period}]) as encounter__service_provider__identifier__assigner__identifier__period ;; }
  join: encounter__service_provider__identifier__assigner__identifier__type { relationship: one_to_many sql: LEFT JOIN UNNEST([${encounter__service_provider__identifier__assigner__identifier.type}]) as encounter__service_provider__identifier__assigner__identifier__type ;; }
  join: encounter__service_provider__identifier__assigner__identifier__type__coding { relationship: one_to_many sql: LEFT JOIN UNNEST(${encounter__service_provider__identifier__assigner__identifier__type.coding}) as encounter__service_provider__identifier__assigner__identifier__type__coding ;; }
  join: encounter__service_provider__identifier__type__coding { relationship: one_to_many sql: LEFT JOIN UNNEST(${encounter__service_provider__identifier__type.coding}) as encounter__service_provider__identifier__type__coding ;; }
  join: encounter__status_history { relationship: one_to_many sql: LEFT JOIN UNNEST(${encounter.status_history}) as encounter__status_history ;; }
  join: encounter__status_history__period { relationship: one_to_many sql: LEFT JOIN UNNEST([${encounter__status_history.period}]) as encounter__status_history__period ;; }
  join: encounter__subject { relationship: one_to_many sql: LEFT JOIN UNNEST([${encounter.subject}]) as encounter__subject ;; }
  join: encounter__subject__identifier { relationship: one_to_many sql: LEFT JOIN UNNEST([${encounter__subject.identifier}]) as encounter__subject__identifier ;; }
  join: encounter__subject__identifier__assigner { relationship: one_to_many sql: LEFT JOIN UNNEST([${encounter__subject__identifier.assigner}]) as encounter__subject__identifier__assigner ;; }
  join: encounter__subject__identifier__period { relationship: one_to_many sql: LEFT JOIN UNNEST([${encounter__subject__identifier.period}]) as encounter__subject__identifier__period ;; }
  join: encounter__subject__identifier__type { relationship: one_to_many sql: LEFT JOIN UNNEST([${encounter__subject__identifier.type}]) as encounter__subject__identifier__type ;; }
  join: encounter__subject__identifier__assigner__identifier { relationship: one_to_many sql: LEFT JOIN UNNEST([${encounter__subject__identifier__assigner.identifier}]) as encounter__subject__identifier__assigner__identifier ;; }
  join: encounter__subject__identifier__assigner__identifier__assigner { relationship: one_to_many sql: LEFT JOIN UNNEST([${encounter__subject__identifier__assigner__identifier.assigner}]) as encounter__subject__identifier__assigner__identifier__assigner ;; }
  join: encounter__subject__identifier__assigner__identifier__period { relationship: one_to_many sql: LEFT JOIN UNNEST([${encounter__subject__identifier__assigner__identifier.period}]) as encounter__subject__identifier__assigner__identifier__period ;; }
  join: encounter__subject__identifier__assigner__identifier__type { relationship: one_to_many sql: LEFT JOIN UNNEST([${encounter__subject__identifier__assigner__identifier.type}]) as encounter__subject__identifier__assigner__identifier__type ;; }
  join: encounter__subject__identifier__assigner__identifier__type__coding { relationship: one_to_many sql: LEFT JOIN UNNEST(${encounter__subject__identifier__assigner__identifier__type.coding}) as encounter__subject__identifier__assigner__identifier__type__coding ;; }
  join: encounter__subject__identifier__type__coding { relationship: one_to_many sql: LEFT JOIN UNNEST(${encounter__subject__identifier__type.coding}) as encounter__subject__identifier__type__coding ;; }
  join: encounter__text { relationship: one_to_many sql: LEFT JOIN UNNEST([${encounter.text}]) as encounter__text ;; }
  join: encounter__type { relationship: one_to_many sql: LEFT JOIN UNNEST(${encounter.type}) as encounter__type ;; }
  join: encounter__type__coding { relationship: one_to_many sql: LEFT JOIN UNNEST(${encounter__type.coding}) as encounter__type__coding ;; }
}

explore: location {
  join: location__address { relationship: one_to_many sql: LEFT JOIN UNNEST([${location.address}]) as location__address ;; }
  join: location__address__period { relationship: one_to_many sql: LEFT JOIN UNNEST([${location__address.period}]) as location__address__period ;; }
  join: location__endpoint { relationship: one_to_many sql: LEFT JOIN UNNEST(${location.endpoint}) as location__endpoint ;; }
  join: location__endpoint__identifier { relationship: one_to_many sql: LEFT JOIN UNNEST([${location__endpoint.identifier}]) as location__endpoint__identifier ;; }
  join: location__endpoint__identifier__assigner { relationship: one_to_many sql: LEFT JOIN UNNEST([${location__endpoint__identifier.assigner}]) as location__endpoint__identifier__assigner ;; }
  join: location__endpoint__identifier__period { relationship: one_to_many sql: LEFT JOIN UNNEST([${location__endpoint__identifier.period}]) as location__endpoint__identifier__period ;; }
  join: location__endpoint__identifier__type { relationship: one_to_many sql: LEFT JOIN UNNEST([${location__endpoint__identifier.type}]) as location__endpoint__identifier__type ;; }
  join: location__endpoint__identifier__assigner__identifier { relationship: one_to_many sql: LEFT JOIN UNNEST([${location__endpoint__identifier__assigner.identifier}]) as location__endpoint__identifier__assigner__identifier ;; }
  join: location__endpoint__identifier__assigner__identifier__assigner { relationship: one_to_many sql: LEFT JOIN UNNEST([${location__endpoint__identifier__assigner__identifier.assigner}]) as location__endpoint__identifier__assigner__identifier__assigner ;; }
  join: location__endpoint__identifier__assigner__identifier__period { relationship: one_to_many sql: LEFT JOIN UNNEST([${location__endpoint__identifier__assigner__identifier.period}]) as location__endpoint__identifier__assigner__identifier__period ;; }
  join: location__endpoint__identifier__assigner__identifier__type { relationship: one_to_many sql: LEFT JOIN UNNEST([${location__endpoint__identifier__assigner__identifier.type}]) as location__endpoint__identifier__assigner__identifier__type ;; }
  join: location__endpoint__identifier__assigner__identifier__type__coding { relationship: one_to_many sql: LEFT JOIN UNNEST(${location__endpoint__identifier__assigner__identifier__type.coding}) as location__endpoint__identifier__assigner__identifier__type__coding ;; }
  join: location__endpoint__identifier__type__coding { relationship: one_to_many sql: LEFT JOIN UNNEST(${location__endpoint__identifier__type.coding}) as location__endpoint__identifier__type__coding ;; }
  join: location__identifier { relationship: one_to_many sql: LEFT JOIN UNNEST(${location.identifier}) as location__identifier ;; }
  join: location__identifier__assigner { relationship: one_to_many sql: LEFT JOIN UNNEST([${location__identifier.assigner}]) as location__identifier__assigner ;; }
  join: location__identifier__period { relationship: one_to_many sql: LEFT JOIN UNNEST([${location__identifier.period}]) as location__identifier__period ;; }
  join: location__identifier__type { relationship: one_to_many sql: LEFT JOIN UNNEST([${location__identifier.type}]) as location__identifier__type ;; }
  join: location__identifier__assigner__identifier { relationship: one_to_many sql: LEFT JOIN UNNEST([${location__identifier__assigner.identifier}]) as location__identifier__assigner__identifier ;; }
  join: location__identifier__assigner__identifier__assigner { relationship: one_to_many sql: LEFT JOIN UNNEST([${location__identifier__assigner__identifier.assigner}]) as location__identifier__assigner__identifier__assigner ;; }
  join: location__identifier__assigner__identifier__period { relationship: one_to_many sql: LEFT JOIN UNNEST([${location__identifier__assigner__identifier.period}]) as location__identifier__assigner__identifier__period ;; }
  join: location__identifier__assigner__identifier__type { relationship: one_to_many sql: LEFT JOIN UNNEST([${location__identifier__assigner__identifier.type}]) as location__identifier__assigner__identifier__type ;; }
  join: location__identifier__assigner__identifier__type__coding { relationship: one_to_many sql: LEFT JOIN UNNEST(${location__identifier__assigner__identifier__type.coding}) as location__identifier__assigner__identifier__type__coding ;; }
  join: location__identifier__type__coding { relationship: one_to_many sql: LEFT JOIN UNNEST(${location__identifier__type.coding}) as location__identifier__type__coding ;; }
  join: location__managing_organization { relationship: one_to_many sql: LEFT JOIN UNNEST([${location.managing_organization}]) as location__managing_organization ;; }
  join: location__managing_organization__identifier { relationship: one_to_many sql: LEFT JOIN UNNEST([${location__managing_organization.identifier}]) as location__managing_organization__identifier ;; }
  join: location__managing_organization__identifier__assigner { relationship: one_to_many sql: LEFT JOIN UNNEST([${location__managing_organization__identifier.assigner}]) as location__managing_organization__identifier__assigner ;; }
  join: location__managing_organization__identifier__period { relationship: one_to_many sql: LEFT JOIN UNNEST([${location__managing_organization__identifier.period}]) as location__managing_organization__identifier__period ;; }
  join: location__managing_organization__identifier__type { relationship: one_to_many sql: LEFT JOIN UNNEST([${location__managing_organization__identifier.type}]) as location__managing_organization__identifier__type ;; }
  join: location__managing_organization__identifier__assigner__identifier { relationship: one_to_many sql: LEFT JOIN UNNEST([${location__managing_organization__identifier__assigner.identifier}]) as location__managing_organization__identifier__assigner__identifier ;; }
  join: location__managing_organization__identifier__assigner__identifier__assigner { relationship: one_to_many sql: LEFT JOIN UNNEST([${location__managing_organization__identifier__assigner__identifier.assigner}]) as location__managing_organization__identifier__assigner__identifier__assigner ;; }
  join: location__managing_organization__identifier__assigner__identifier__period { relationship: one_to_many sql: LEFT JOIN UNNEST([${location__managing_organization__identifier__assigner__identifier.period}]) as location__managing_organization__identifier__assigner__identifier__period ;; }
  join: location__managing_organization__identifier__assigner__identifier__type { relationship: one_to_many sql: LEFT JOIN UNNEST([${location__managing_organization__identifier__assigner__identifier.type}]) as location__managing_organization__identifier__assigner__identifier__type ;; }
  join: location__managing_organization__identifier__assigner__identifier__type__coding { relationship: one_to_many sql: LEFT JOIN UNNEST(${location__managing_organization__identifier__assigner__identifier__type.coding}) as location__managing_organization__identifier__assigner__identifier__type__coding ;; }
  join: location__managing_organization__identifier__type__coding { relationship: one_to_many sql: LEFT JOIN UNNEST(${location__managing_organization__identifier__type.coding}) as location__managing_organization__identifier__type__coding ;; }
  join: location__meta { relationship: one_to_many sql: LEFT JOIN UNNEST([${location.meta}]) as location__meta ;; }
  join: location__meta__security { relationship: one_to_many sql: LEFT JOIN UNNEST(${location__meta.security}) as location__meta__security ;; }
  join: location__meta__tag { relationship: one_to_many sql: LEFT JOIN UNNEST(${location__meta.tag}) as location__meta__tag ;; }
  join: location__operational_status { relationship: one_to_many sql: LEFT JOIN UNNEST([${location.operational_status}]) as location__operational_status ;; }
  join: location__part_of { relationship: one_to_many sql: LEFT JOIN UNNEST([${location.part_of}]) as location__part_of ;; }
  join: location__part_of__identifier { relationship: one_to_many sql: LEFT JOIN UNNEST([${location__part_of.identifier}]) as location__part_of__identifier ;; }
  join: location__part_of__identifier__assigner { relationship: one_to_many sql: LEFT JOIN UNNEST([${location__part_of__identifier.assigner}]) as location__part_of__identifier__assigner ;; }
  join: location__part_of__identifier__period { relationship: one_to_many sql: LEFT JOIN UNNEST([${location__part_of__identifier.period}]) as location__part_of__identifier__period ;; }
  join: location__part_of__identifier__type { relationship: one_to_many sql: LEFT JOIN UNNEST([${location__part_of__identifier.type}]) as location__part_of__identifier__type ;; }
  join: location__part_of__identifier__assigner__identifier { relationship: one_to_many sql: LEFT JOIN UNNEST([${location__part_of__identifier__assigner.identifier}]) as location__part_of__identifier__assigner__identifier ;; }
  join: location__part_of__identifier__assigner__identifier__assigner { relationship: one_to_many sql: LEFT JOIN UNNEST([${location__part_of__identifier__assigner__identifier.assigner}]) as location__part_of__identifier__assigner__identifier__assigner ;; }
  join: location__part_of__identifier__assigner__identifier__period { relationship: one_to_many sql: LEFT JOIN UNNEST([${location__part_of__identifier__assigner__identifier.period}]) as location__part_of__identifier__assigner__identifier__period ;; }
  join: location__part_of__identifier__assigner__identifier__type { relationship: one_to_many sql: LEFT JOIN UNNEST([${location__part_of__identifier__assigner__identifier.type}]) as location__part_of__identifier__assigner__identifier__type ;; }
  join: location__part_of__identifier__assigner__identifier__type__coding { relationship: one_to_many sql: LEFT JOIN UNNEST(${location__part_of__identifier__assigner__identifier__type.coding}) as location__part_of__identifier__assigner__identifier__type__coding ;; }
  join: location__part_of__identifier__type__coding { relationship: one_to_many sql: LEFT JOIN UNNEST(${location__part_of__identifier__type.coding}) as location__part_of__identifier__type__coding ;; }
  join: location__physical_type { relationship: one_to_many sql: LEFT JOIN UNNEST([${location.physical_type}]) as location__physical_type ;; }
  join: location__physical_type__coding { relationship: one_to_many sql: LEFT JOIN UNNEST(${location__physical_type.coding}) as location__physical_type__coding ;; }
  join: location__position { relationship: one_to_many sql: LEFT JOIN UNNEST([${location.position}]) as location__position ;; }
  join: location__telecom { relationship: one_to_many sql: LEFT JOIN UNNEST(${location.telecom}) as location__telecom ;; }
  join: location__telecom__period { relationship: one_to_many sql: LEFT JOIN UNNEST([${location__telecom.period}]) as location__telecom__period ;; }
  join: location__text { relationship: one_to_many sql: LEFT JOIN UNNEST([${location.text}]) as location__text ;; }
  join: location__type { relationship: one_to_many sql: LEFT JOIN UNNEST([${location.type}]) as location__type ;; }
  join: location__type__coding { relationship: one_to_many sql: LEFT JOIN UNNEST(${location__type.coding}) as location__type__coding ;; }
}

explore: observation {
  join: observation__based_on { relationship: one_to_many sql: LEFT JOIN UNNEST(${observation.based_on}) as observation__based_on ;; }
  join: observation__based_on__identifier { relationship: one_to_many sql: LEFT JOIN UNNEST([${observation__based_on.identifier}]) as observation__based_on__identifier ;; }
  join: observation__based_on__identifier__assigner { relationship: one_to_many sql: LEFT JOIN UNNEST([${observation__based_on__identifier.assigner}]) as observation__based_on__identifier__assigner ;; }
  join: observation__based_on__identifier__period { relationship: one_to_many sql: LEFT JOIN UNNEST([${observation__based_on__identifier.period}]) as observation__based_on__identifier__period ;; }
  join: observation__based_on__identifier__type { relationship: one_to_many sql: LEFT JOIN UNNEST([${observation__based_on__identifier.type}]) as observation__based_on__identifier__type ;; }
  join: observation__based_on__identifier__assigner__identifier { relationship: one_to_many sql: LEFT JOIN UNNEST([${observation__based_on__identifier__assigner.identifier}]) as observation__based_on__identifier__assigner__identifier ;; }
  join: observation__based_on__identifier__assigner__identifier__assigner { relationship: one_to_many sql: LEFT JOIN UNNEST([${observation__based_on__identifier__assigner__identifier.assigner}]) as observation__based_on__identifier__assigner__identifier__assigner ;; }
  join: observation__based_on__identifier__assigner__identifier__period { relationship: one_to_many sql: LEFT JOIN UNNEST([${observation__based_on__identifier__assigner__identifier.period}]) as observation__based_on__identifier__assigner__identifier__period ;; }
  join: observation__based_on__identifier__assigner__identifier__type { relationship: one_to_many sql: LEFT JOIN UNNEST([${observation__based_on__identifier__assigner__identifier.type}]) as observation__based_on__identifier__assigner__identifier__type ;; }
  join: observation__based_on__identifier__assigner__identifier__type__coding { relationship: one_to_many sql: LEFT JOIN UNNEST(${observation__based_on__identifier__assigner__identifier__type.coding}) as observation__based_on__identifier__assigner__identifier__type__coding ;; }
  join: observation__based_on__identifier__type__coding { relationship: one_to_many sql: LEFT JOIN UNNEST(${observation__based_on__identifier__type.coding}) as observation__based_on__identifier__type__coding ;; }
  join: observation__body_site { relationship: one_to_many sql: LEFT JOIN UNNEST([${observation.body_site}]) as observation__body_site ;; }
  join: observation__body_site__coding { relationship: one_to_many sql: LEFT JOIN UNNEST(${observation__body_site.coding}) as observation__body_site__coding ;; }
  join: observation__category { relationship: one_to_many sql: LEFT JOIN UNNEST(${observation.category}) as observation__category ;; }
  join: observation__category__coding { relationship: one_to_many sql: LEFT JOIN UNNEST(${observation__category.coding}) as observation__category__coding ;; }
  join: observation__code { relationship: one_to_many sql: LEFT JOIN UNNEST([${observation.code}]) as observation__code ;; }
  join: observation__code__coding { relationship: one_to_many sql: LEFT JOIN UNNEST(${observation__code.coding}) as observation__code__coding ;; }
  join: observation__component { relationship: one_to_many sql: LEFT JOIN UNNEST(${observation.component}) as observation__component ;; }
  join: observation__component__code { relationship: one_to_many sql: LEFT JOIN UNNEST([${observation__component.code}]) as observation__component__code ;; }
  join: observation__component__data_absent_reason { relationship: one_to_many sql: LEFT JOIN UNNEST([${observation__component.data_absent_reason}]) as observation__component__data_absent_reason ;; }
  join: observation__component__interpretation { relationship: one_to_many sql: LEFT JOIN UNNEST([${observation__component.interpretation}]) as observation__component__interpretation ;; }
  join: observation__component__reference_range { relationship: one_to_many sql: LEFT JOIN UNNEST(${observation__component.reference_range}) as observation__component__reference_range ;; }
  join: observation__component__value { relationship: one_to_many sql: LEFT JOIN UNNEST([${observation__component.value}]) as observation__component__value ;; }
  join: observation__component__code__coding { relationship: one_to_many sql: LEFT JOIN UNNEST(${observation__component__code.coding}) as observation__component__code__coding ;; }
  join: observation__component__data_absent_reason__coding { relationship: one_to_many sql: LEFT JOIN UNNEST(${observation__component__data_absent_reason.coding}) as observation__component__data_absent_reason__coding ;; }
  join: observation__component__interpretation__coding { relationship: one_to_many sql: LEFT JOIN UNNEST(${observation__component__interpretation.coding}) as observation__component__interpretation__coding ;; }
  join: observation__component__reference_range__age { relationship: one_to_many sql: LEFT JOIN UNNEST([${observation__component__reference_range.age}]) as observation__component__reference_range__age ;; }
  join: observation__component__reference_range__applies_to { relationship: one_to_many sql: LEFT JOIN UNNEST(${observation__component__reference_range.applies_to}) as observation__component__reference_range__applies_to ;; }
  join: observation__component__reference_range__high { relationship: one_to_many sql: LEFT JOIN UNNEST([${observation__component__reference_range.high}]) as observation__component__reference_range__high ;; }
  join: observation__component__reference_range__low { relationship: one_to_many sql: LEFT JOIN UNNEST([${observation__component__reference_range.low}]) as observation__component__reference_range__low ;; }
  join: observation__component__reference_range__type { relationship: one_to_many sql: LEFT JOIN UNNEST([${observation__component__reference_range.type}]) as observation__component__reference_range__type ;; }
  join: observation__component__reference_range__age__high { relationship: one_to_many sql: LEFT JOIN UNNEST([${observation__component__reference_range__age.high}]) as observation__component__reference_range__age__high ;; }
  join: observation__component__reference_range__age__low { relationship: one_to_many sql: LEFT JOIN UNNEST([${observation__component__reference_range__age.low}]) as observation__component__reference_range__age__low ;; }
  join: observation__component__reference_range__applies_to__coding { relationship: one_to_many sql: LEFT JOIN UNNEST(${observation__component__reference_range__applies_to.coding}) as observation__component__reference_range__applies_to__coding ;; }
  join: observation__component__reference_range__type__coding { relationship: one_to_many sql: LEFT JOIN UNNEST(${observation__component__reference_range__type.coding}) as observation__component__reference_range__type__coding ;; }
  join: observation__component__value__attachment { relationship: one_to_many sql: LEFT JOIN UNNEST([${observation__component__value.attachment}]) as observation__component__value__attachment ;; }
  join: observation__component__value__codeable_concept { relationship: one_to_many sql: LEFT JOIN UNNEST([${observation__component__value.codeable_concept}]) as observation__component__value__codeable_concept ;; }
  join: observation__component__value__period { relationship: one_to_many sql: LEFT JOIN UNNEST([${observation__component__value.period}]) as observation__component__value__period ;; }
  join: observation__component__value__quantity { relationship: one_to_many sql: LEFT JOIN UNNEST([${observation__component__value.quantity}]) as observation__component__value__quantity ;; }
  join: observation__component__value__range { relationship: one_to_many sql: LEFT JOIN UNNEST([${observation__component__value.range}]) as observation__component__value__range ;; }
  join: observation__component__value__ratio { relationship: one_to_many sql: LEFT JOIN UNNEST([${observation__component__value.ratio}]) as observation__component__value__ratio ;; }
  join: observation__component__value__sampled_data { relationship: one_to_many sql: LEFT JOIN UNNEST([${observation__component__value.sampled_data}]) as observation__component__value__sampled_data ;; }
  join: observation__component__value__codeable_concept__coding { relationship: one_to_many sql: LEFT JOIN UNNEST(${observation__component__value__codeable_concept.coding}) as observation__component__value__codeable_concept__coding ;; }
  join: observation__component__value__range__high { relationship: one_to_many sql: LEFT JOIN UNNEST([${observation__component__value__range.high}]) as observation__component__value__range__high ;; }
  join: observation__component__value__range__low { relationship: one_to_many sql: LEFT JOIN UNNEST([${observation__component__value__range.low}]) as observation__component__value__range__low ;; }
  join: observation__component__value__ratio__denominator { relationship: one_to_many sql: LEFT JOIN UNNEST([${observation__component__value__ratio.denominator}]) as observation__component__value__ratio__denominator ;; }
  join: observation__component__value__ratio__numerator { relationship: one_to_many sql: LEFT JOIN UNNEST([${observation__component__value__ratio.numerator}]) as observation__component__value__ratio__numerator ;; }
  join: observation__component__value__sampled_data__origin { relationship: one_to_many sql: LEFT JOIN UNNEST([${observation__component__value__sampled_data.origin}]) as observation__component__value__sampled_data__origin ;; }
  join: observation__context { relationship: one_to_many sql: LEFT JOIN UNNEST([${observation.context}]) as observation__context ;; }
  join: observation__context__identifier { relationship: one_to_many sql: LEFT JOIN UNNEST([${observation__context.identifier}]) as observation__context__identifier ;; }
  join: observation__context__identifier__assigner { relationship: one_to_many sql: LEFT JOIN UNNEST([${observation__context__identifier.assigner}]) as observation__context__identifier__assigner ;; }
  join: observation__context__identifier__period { relationship: one_to_many sql: LEFT JOIN UNNEST([${observation__context__identifier.period}]) as observation__context__identifier__period ;; }
  join: observation__context__identifier__type { relationship: one_to_many sql: LEFT JOIN UNNEST([${observation__context__identifier.type}]) as observation__context__identifier__type ;; }
  join: observation__context__identifier__assigner__identifier { relationship: one_to_many sql: LEFT JOIN UNNEST([${observation__context__identifier__assigner.identifier}]) as observation__context__identifier__assigner__identifier ;; }
  join: observation__context__identifier__assigner__identifier__assigner { relationship: one_to_many sql: LEFT JOIN UNNEST([${observation__context__identifier__assigner__identifier.assigner}]) as observation__context__identifier__assigner__identifier__assigner ;; }
  join: observation__context__identifier__assigner__identifier__period { relationship: one_to_many sql: LEFT JOIN UNNEST([${observation__context__identifier__assigner__identifier.period}]) as observation__context__identifier__assigner__identifier__period ;; }
  join: observation__context__identifier__assigner__identifier__type { relationship: one_to_many sql: LEFT JOIN UNNEST([${observation__context__identifier__assigner__identifier.type}]) as observation__context__identifier__assigner__identifier__type ;; }
  join: observation__context__identifier__assigner__identifier__type__coding { relationship: one_to_many sql: LEFT JOIN UNNEST(${observation__context__identifier__assigner__identifier__type.coding}) as observation__context__identifier__assigner__identifier__type__coding ;; }
  join: observation__context__identifier__type__coding { relationship: one_to_many sql: LEFT JOIN UNNEST(${observation__context__identifier__type.coding}) as observation__context__identifier__type__coding ;; }
  join: observation__data_absent_reason { relationship: one_to_many sql: LEFT JOIN UNNEST([${observation.data_absent_reason}]) as observation__data_absent_reason ;; }
  join: observation__data_absent_reason__coding { relationship: one_to_many sql: LEFT JOIN UNNEST(${observation__data_absent_reason.coding}) as observation__data_absent_reason__coding ;; }
  join: observation__device { relationship: one_to_many sql: LEFT JOIN UNNEST([${observation.device}]) as observation__device ;; }
  join: observation__device__identifier { relationship: one_to_many sql: LEFT JOIN UNNEST([${observation__device.identifier}]) as observation__device__identifier ;; }
  join: observation__device__identifier__assigner { relationship: one_to_many sql: LEFT JOIN UNNEST([${observation__device__identifier.assigner}]) as observation__device__identifier__assigner ;; }
  join: observation__device__identifier__period { relationship: one_to_many sql: LEFT JOIN UNNEST([${observation__device__identifier.period}]) as observation__device__identifier__period ;; }
  join: observation__device__identifier__type { relationship: one_to_many sql: LEFT JOIN UNNEST([${observation__device__identifier.type}]) as observation__device__identifier__type ;; }
  join: observation__device__identifier__assigner__identifier { relationship: one_to_many sql: LEFT JOIN UNNEST([${observation__device__identifier__assigner.identifier}]) as observation__device__identifier__assigner__identifier ;; }
  join: observation__device__identifier__assigner__identifier__assigner { relationship: one_to_many sql: LEFT JOIN UNNEST([${observation__device__identifier__assigner__identifier.assigner}]) as observation__device__identifier__assigner__identifier__assigner ;; }
  join: observation__device__identifier__assigner__identifier__period { relationship: one_to_many sql: LEFT JOIN UNNEST([${observation__device__identifier__assigner__identifier.period}]) as observation__device__identifier__assigner__identifier__period ;; }
  join: observation__device__identifier__assigner__identifier__type { relationship: one_to_many sql: LEFT JOIN UNNEST([${observation__device__identifier__assigner__identifier.type}]) as observation__device__identifier__assigner__identifier__type ;; }
  join: observation__device__identifier__assigner__identifier__type__coding { relationship: one_to_many sql: LEFT JOIN UNNEST(${observation__device__identifier__assigner__identifier__type.coding}) as observation__device__identifier__assigner__identifier__type__coding ;; }
  join: observation__device__identifier__type__coding { relationship: one_to_many sql: LEFT JOIN UNNEST(${observation__device__identifier__type.coding}) as observation__device__identifier__type__coding ;; }
  join: observation__effective { relationship: one_to_many sql: LEFT JOIN UNNEST([${observation.effective}]) as observation__effective ;; }
  # join: observation__effective__period { relationship: one_to_many sql: LEFT JOIN UNNEST([${observation__effective.period}]) as observation__effective__period ;; }
  join: observation__identifier { relationship: one_to_many sql: LEFT JOIN UNNEST(${observation.identifier}) as observation__identifier ;; }
  join: observation__identifier__assigner { relationship: one_to_many sql: LEFT JOIN UNNEST([${observation__identifier.assigner}]) as observation__identifier__assigner ;; }
  join: observation__identifier__period { relationship: one_to_many sql: LEFT JOIN UNNEST([${observation__identifier.period}]) as observation__identifier__period ;; }
  join: observation__identifier__type { relationship: one_to_many sql: LEFT JOIN UNNEST([${observation__identifier.type}]) as observation__identifier__type ;; }
  join: observation__identifier__assigner__identifier { relationship: one_to_many sql: LEFT JOIN UNNEST([${observation__identifier__assigner.identifier}]) as observation__identifier__assigner__identifier ;; }
  join: observation__identifier__assigner__identifier__assigner { relationship: one_to_many sql: LEFT JOIN UNNEST([${observation__identifier__assigner__identifier.assigner}]) as observation__identifier__assigner__identifier__assigner ;; }
  join: observation__identifier__assigner__identifier__period { relationship: one_to_many sql: LEFT JOIN UNNEST([${observation__identifier__assigner__identifier.period}]) as observation__identifier__assigner__identifier__period ;; }
  join: observation__identifier__assigner__identifier__type { relationship: one_to_many sql: LEFT JOIN UNNEST([${observation__identifier__assigner__identifier.type}]) as observation__identifier__assigner__identifier__type ;; }
  join: observation__identifier__assigner__identifier__type__coding { relationship: one_to_many sql: LEFT JOIN UNNEST(${observation__identifier__assigner__identifier__type.coding}) as observation__identifier__assigner__identifier__type__coding ;; }
  join: observation__identifier__type__coding { relationship: one_to_many sql: LEFT JOIN UNNEST(${observation__identifier__type.coding}) as observation__identifier__type__coding ;; }
  join: observation__interpretation { relationship: one_to_many sql: LEFT JOIN UNNEST([${observation.interpretation}]) as observation__interpretation ;; }
  join: observation__interpretation__coding { relationship: one_to_many sql: LEFT JOIN UNNEST(${observation__interpretation.coding}) as observation__interpretation__coding ;; }
  join: observation__meta { relationship: one_to_many sql: LEFT JOIN UNNEST([${observation.meta}]) as observation__meta ;; }
  join: observation__meta__security { relationship: one_to_many sql: LEFT JOIN UNNEST(${observation__meta.security}) as observation__meta__security ;; }
  join: observation__meta__tag { relationship: one_to_many sql: LEFT JOIN UNNEST(${observation__meta.tag}) as observation__meta__tag ;; }
  join: observation__method { relationship: one_to_many sql: LEFT JOIN UNNEST([${observation.method}]) as observation__method ;; }
  join: observation__method__coding { relationship: one_to_many sql: LEFT JOIN UNNEST(${observation__method.coding}) as observation__method__coding ;; }
  join: observation__performer { relationship: one_to_many sql: LEFT JOIN UNNEST(${observation.performer}) as observation__performer ;; }
  join: observation__performer__identifier { relationship: one_to_many sql: LEFT JOIN UNNEST([${observation__performer.identifier}]) as observation__performer__identifier ;; }
  join: observation__performer__identifier__assigner { relationship: one_to_many sql: LEFT JOIN UNNEST([${observation__performer__identifier.assigner}]) as observation__performer__identifier__assigner ;; }
  join: observation__performer__identifier__period { relationship: one_to_many sql: LEFT JOIN UNNEST([${observation__performer__identifier.period}]) as observation__performer__identifier__period ;; }
  join: observation__performer__identifier__type { relationship: one_to_many sql: LEFT JOIN UNNEST([${observation__performer__identifier.type}]) as observation__performer__identifier__type ;; }
  join: observation__performer__identifier__assigner__identifier { relationship: one_to_many sql: LEFT JOIN UNNEST([${observation__performer__identifier__assigner.identifier}]) as observation__performer__identifier__assigner__identifier ;; }
  join: observation__performer__identifier__assigner__identifier__assigner { relationship: one_to_many sql: LEFT JOIN UNNEST([${observation__performer__identifier__assigner__identifier.assigner}]) as observation__performer__identifier__assigner__identifier__assigner ;; }
  join: observation__performer__identifier__assigner__identifier__period { relationship: one_to_many sql: LEFT JOIN UNNEST([${observation__performer__identifier__assigner__identifier.period}]) as observation__performer__identifier__assigner__identifier__period ;; }
  join: observation__performer__identifier__assigner__identifier__type { relationship: one_to_many sql: LEFT JOIN UNNEST([${observation__performer__identifier__assigner__identifier.type}]) as observation__performer__identifier__assigner__identifier__type ;; }
  join: observation__performer__identifier__assigner__identifier__type__coding { relationship: one_to_many sql: LEFT JOIN UNNEST(${observation__performer__identifier__assigner__identifier__type.coding}) as observation__performer__identifier__assigner__identifier__type__coding ;; }
  join: observation__performer__identifier__type__coding { relationship: one_to_many sql: LEFT JOIN UNNEST(${observation__performer__identifier__type.coding}) as observation__performer__identifier__type__coding ;; }
  join: observation__reference_range { relationship: one_to_many sql: LEFT JOIN UNNEST(${observation.reference_range}) as observation__reference_range ;; }
  join: observation__reference_range__age { relationship: one_to_many sql: LEFT JOIN UNNEST([${observation__reference_range.age}]) as observation__reference_range__age ;; }
  join: observation__reference_range__applies_to { relationship: one_to_many sql: LEFT JOIN UNNEST(${observation__reference_range.applies_to}) as observation__reference_range__applies_to ;; }
  join: observation__reference_range__high { relationship: one_to_many sql: LEFT JOIN UNNEST([${observation__reference_range.high}]) as observation__reference_range__high ;; }
  join: observation__reference_range__low { relationship: one_to_many sql: LEFT JOIN UNNEST([${observation__reference_range.low}]) as observation__reference_range__low ;; }
  join: observation__reference_range__type { relationship: one_to_many sql: LEFT JOIN UNNEST([${observation__reference_range.type}]) as observation__reference_range__type ;; }
  join: observation__reference_range__age__high { relationship: one_to_many sql: LEFT JOIN UNNEST([${observation__reference_range__age.high}]) as observation__reference_range__age__high ;; }
  join: observation__reference_range__age__low { relationship: one_to_many sql: LEFT JOIN UNNEST([${observation__reference_range__age.low}]) as observation__reference_range__age__low ;; }
  join: observation__reference_range__applies_to__coding { relationship: one_to_many sql: LEFT JOIN UNNEST(${observation__reference_range__applies_to.coding}) as observation__reference_range__applies_to__coding ;; }
  join: observation__reference_range__type__coding { relationship: one_to_many sql: LEFT JOIN UNNEST(${observation__reference_range__type.coding}) as observation__reference_range__type__coding ;; }
  join: observation__related { relationship: one_to_many sql: LEFT JOIN UNNEST(${observation.related}) as observation__related ;; }
  join: observation__related__target { relationship: one_to_many sql: LEFT JOIN UNNEST([${observation__related.target}]) as observation__related__target ;; }
  join: observation__related__target__identifier { relationship: one_to_many sql: LEFT JOIN UNNEST([${observation__related__target.identifier}]) as observation__related__target__identifier ;; }
  join: observation__related__target__identifier__assigner { relationship: one_to_many sql: LEFT JOIN UNNEST([${observation__related__target__identifier.assigner}]) as observation__related__target__identifier__assigner ;; }
  join: observation__related__target__identifier__period { relationship: one_to_many sql: LEFT JOIN UNNEST([${observation__related__target__identifier.period}]) as observation__related__target__identifier__period ;; }
  join: observation__related__target__identifier__type { relationship: one_to_many sql: LEFT JOIN UNNEST([${observation__related__target__identifier.type}]) as observation__related__target__identifier__type ;; }
  join: observation__related__target__identifier__assigner__identifier { relationship: one_to_many sql: LEFT JOIN UNNEST([${observation__related__target__identifier__assigner.identifier}]) as observation__related__target__identifier__assigner__identifier ;; }
  join: observation__related__target__identifier__assigner__identifier__assigner { relationship: one_to_many sql: LEFT JOIN UNNEST([${observation__related__target__identifier__assigner__identifier.assigner}]) as observation__related__target__identifier__assigner__identifier__assigner ;; }
  join: observation__related__target__identifier__assigner__identifier__period { relationship: one_to_many sql: LEFT JOIN UNNEST([${observation__related__target__identifier__assigner__identifier.period}]) as observation__related__target__identifier__assigner__identifier__period ;; }
  join: observation__related__target__identifier__assigner__identifier__type { relationship: one_to_many sql: LEFT JOIN UNNEST([${observation__related__target__identifier__assigner__identifier.type}]) as observation__related__target__identifier__assigner__identifier__type ;; }
  join: observation__related__target__identifier__assigner__identifier__type__coding { relationship: one_to_many sql: LEFT JOIN UNNEST(${observation__related__target__identifier__assigner__identifier__type.coding}) as observation__related__target__identifier__assigner__identifier__type__coding ;; }
  join: observation__related__target__identifier__type__coding { relationship: one_to_many sql: LEFT JOIN UNNEST(${observation__related__target__identifier__type.coding}) as observation__related__target__identifier__type__coding ;; }
  join: observation__specimen { relationship: one_to_many sql: LEFT JOIN UNNEST([${observation.specimen}]) as observation__specimen ;; }
  join: observation__specimen__identifier { relationship: one_to_many sql: LEFT JOIN UNNEST([${observation__specimen.identifier}]) as observation__specimen__identifier ;; }
  join: observation__specimen__identifier__assigner { relationship: one_to_many sql: LEFT JOIN UNNEST([${observation__specimen__identifier.assigner}]) as observation__specimen__identifier__assigner ;; }
  join: observation__specimen__identifier__period { relationship: one_to_many sql: LEFT JOIN UNNEST([${observation__specimen__identifier.period}]) as observation__specimen__identifier__period ;; }
  join: observation__specimen__identifier__type { relationship: one_to_many sql: LEFT JOIN UNNEST([${observation__specimen__identifier.type}]) as observation__specimen__identifier__type ;; }
  join: observation__specimen__identifier__assigner__identifier { relationship: one_to_many sql: LEFT JOIN UNNEST([${observation__specimen__identifier__assigner.identifier}]) as observation__specimen__identifier__assigner__identifier ;; }
  join: observation__specimen__identifier__assigner__identifier__assigner { relationship: one_to_many sql: LEFT JOIN UNNEST([${observation__specimen__identifier__assigner__identifier.assigner}]) as observation__specimen__identifier__assigner__identifier__assigner ;; }
  join: observation__specimen__identifier__assigner__identifier__period { relationship: one_to_many sql: LEFT JOIN UNNEST([${observation__specimen__identifier__assigner__identifier.period}]) as observation__specimen__identifier__assigner__identifier__period ;; }
  join: observation__specimen__identifier__assigner__identifier__type { relationship: one_to_many sql: LEFT JOIN UNNEST([${observation__specimen__identifier__assigner__identifier.type}]) as observation__specimen__identifier__assigner__identifier__type ;; }
  join: observation__specimen__identifier__assigner__identifier__type__coding { relationship: one_to_many sql: LEFT JOIN UNNEST(${observation__specimen__identifier__assigner__identifier__type.coding}) as observation__specimen__identifier__assigner__identifier__type__coding ;; }
  join: observation__specimen__identifier__type__coding { relationship: one_to_many sql: LEFT JOIN UNNEST(${observation__specimen__identifier__type.coding}) as observation__specimen__identifier__type__coding ;; }
  join: observation__subject { relationship: one_to_many sql: LEFT JOIN UNNEST([${observation.subject}]) as observation__subject ;; }
  join: observation__subject__identifier { relationship: one_to_many sql: LEFT JOIN UNNEST([${observation__subject.identifier}]) as observation__subject__identifier ;; }
  join: observation__subject__identifier__assigner { relationship: one_to_many sql: LEFT JOIN UNNEST([${observation__subject__identifier.assigner}]) as observation__subject__identifier__assigner ;; }
  join: observation__subject__identifier__period { relationship: one_to_many sql: LEFT JOIN UNNEST([${observation__subject__identifier.period}]) as observation__subject__identifier__period ;; }
  join: observation__subject__identifier__type { relationship: one_to_many sql: LEFT JOIN UNNEST([${observation__subject__identifier.type}]) as observation__subject__identifier__type ;; }
  join: observation__subject__identifier__assigner__identifier { relationship: one_to_many sql: LEFT JOIN UNNEST([${observation__subject__identifier__assigner.identifier}]) as observation__subject__identifier__assigner__identifier ;; }
  join: observation__subject__identifier__assigner__identifier__assigner { relationship: one_to_many sql: LEFT JOIN UNNEST([${observation__subject__identifier__assigner__identifier.assigner}]) as observation__subject__identifier__assigner__identifier__assigner ;; }
  join: observation__subject__identifier__assigner__identifier__period { relationship: one_to_many sql: LEFT JOIN UNNEST([${observation__subject__identifier__assigner__identifier.period}]) as observation__subject__identifier__assigner__identifier__period ;; }
  join: observation__subject__identifier__assigner__identifier__type { relationship: one_to_many sql: LEFT JOIN UNNEST([${observation__subject__identifier__assigner__identifier.type}]) as observation__subject__identifier__assigner__identifier__type ;; }
  join: observation__subject__identifier__assigner__identifier__type__coding { relationship: one_to_many sql: LEFT JOIN UNNEST(${observation__subject__identifier__assigner__identifier__type.coding}) as observation__subject__identifier__assigner__identifier__type__coding ;; }
  join: observation__subject__identifier__type__coding { relationship: one_to_many sql: LEFT JOIN UNNEST(${observation__subject__identifier__type.coding}) as observation__subject__identifier__type__coding ;; }
  join: observation__text { relationship: one_to_many sql: LEFT JOIN UNNEST([${observation.text}]) as observation__text ;; }
  join: observation__value { relationship: one_to_many sql: LEFT JOIN UNNEST([${observation.value}]) as observation__value ;; }
  join: observation__value__attachment { relationship: one_to_many sql: LEFT JOIN UNNEST([${observation__value.attachment}]) as observation__value__attachment ;; }
  join: observation__value__codeable_concept { relationship: one_to_many sql: LEFT JOIN UNNEST([${observation__value.codeable_concept}]) as observation__value__codeable_concept ;; }
  join: observation__value__period { relationship: one_to_many sql: LEFT JOIN UNNEST([${observation__value.period}]) as observation__value__period ;; }
  join: observation__value__quantity { relationship: one_to_many sql: LEFT JOIN UNNEST([${observation__value.quantity}]) as observation__value__quantity ;; }
  join: observation__value__range { relationship: one_to_many sql: LEFT JOIN UNNEST([${observation__value.range}]) as observation__value__range ;; }
  join: observation__value__ratio { relationship: one_to_many sql: LEFT JOIN UNNEST([${observation__value.ratio}]) as observation__value__ratio ;; }
  join: observation__value__sampled_data { relationship: one_to_many sql: LEFT JOIN UNNEST([${observation__value.sampled_data}]) as observation__value__sampled_data ;; }
  join: observation__value__codeable_concept__coding { relationship: one_to_many sql: LEFT JOIN UNNEST(${observation__value__codeable_concept.coding}) as observation__value__codeable_concept__coding ;; }
  join: observation__value__range__high { relationship: one_to_many sql: LEFT JOIN UNNEST([${observation__value__range.high}]) as observation__value__range__high ;; }
  join: observation__value__range__low { relationship: one_to_many sql: LEFT JOIN UNNEST([${observation__value__range.low}]) as observation__value__range__low ;; }
  join: observation__value__ratio__denominator { relationship: one_to_many sql: LEFT JOIN UNNEST([${observation__value__ratio.denominator}]) as observation__value__ratio__denominator ;; }
  join: observation__value__ratio__numerator { relationship: one_to_many sql: LEFT JOIN UNNEST([${observation__value__ratio.numerator}]) as observation__value__ratio__numerator ;; }
  join: observation__value__sampled_data__origin { relationship: one_to_many sql: LEFT JOIN UNNEST([${observation__value__sampled_data.origin}]) as observation__value__sampled_data__origin ;; }
}

explore: organization {
  join: organization__address { relationship: one_to_many sql: LEFT JOIN UNNEST(${organization.address}) as organization__address ;; }
  join: organization__address__period { relationship: one_to_many sql: LEFT JOIN UNNEST([${organization__address.period}]) as organization__address__period ;; }
  join: organization__contact { relationship: one_to_many sql: LEFT JOIN UNNEST(${organization.contact}) as organization__contact ;; }
  join: organization__contact__address { relationship: one_to_many sql: LEFT JOIN UNNEST([${organization__contact.address}]) as organization__contact__address ;; }
  join: organization__contact__name { relationship: one_to_many sql: LEFT JOIN UNNEST([${organization__contact.name}]) as organization__contact__name ;; }
  join: organization__contact__purpose { relationship: one_to_many sql: LEFT JOIN UNNEST([${organization__contact.purpose}]) as organization__contact__purpose ;; }
  join: organization__contact__telecom { relationship: one_to_many sql: LEFT JOIN UNNEST(${organization__contact.telecom}) as organization__contact__telecom ;; }
  join: organization__contact__address__period { relationship: one_to_many sql: LEFT JOIN UNNEST([${organization__contact__address.period}]) as organization__contact__address__period ;; }
  join: organization__contact__name__period { relationship: one_to_many sql: LEFT JOIN UNNEST([${organization__contact__name.period}]) as organization__contact__name__period ;; }
  join: organization__contact__purpose__coding { relationship: one_to_many sql: LEFT JOIN UNNEST(${organization__contact__purpose.coding}) as organization__contact__purpose__coding ;; }
  join: organization__contact__telecom__period { relationship: one_to_many sql: LEFT JOIN UNNEST([${organization__contact__telecom.period}]) as organization__contact__telecom__period ;; }
  join: organization__endpoint { relationship: one_to_many sql: LEFT JOIN UNNEST(${organization.endpoint}) as organization__endpoint ;; }
  join: organization__endpoint__identifier { relationship: one_to_many sql: LEFT JOIN UNNEST([${organization__endpoint.identifier}]) as organization__endpoint__identifier ;; }
  join: organization__endpoint__identifier__assigner { relationship: one_to_many sql: LEFT JOIN UNNEST([${organization__endpoint__identifier.assigner}]) as organization__endpoint__identifier__assigner ;; }
  join: organization__endpoint__identifier__period { relationship: one_to_many sql: LEFT JOIN UNNEST([${organization__endpoint__identifier.period}]) as organization__endpoint__identifier__period ;; }
  join: organization__endpoint__identifier__type { relationship: one_to_many sql: LEFT JOIN UNNEST([${organization__endpoint__identifier.type}]) as organization__endpoint__identifier__type ;; }
  join: organization__endpoint__identifier__assigner__identifier { relationship: one_to_many sql: LEFT JOIN UNNEST([${organization__endpoint__identifier__assigner.identifier}]) as organization__endpoint__identifier__assigner__identifier ;; }
  join: organization__endpoint__identifier__assigner__identifier__assigner { relationship: one_to_many sql: LEFT JOIN UNNEST([${organization__endpoint__identifier__assigner__identifier.assigner}]) as organization__endpoint__identifier__assigner__identifier__assigner ;; }
  join: organization__endpoint__identifier__assigner__identifier__period { relationship: one_to_many sql: LEFT JOIN UNNEST([${organization__endpoint__identifier__assigner__identifier.period}]) as organization__endpoint__identifier__assigner__identifier__period ;; }
  join: organization__endpoint__identifier__assigner__identifier__type { relationship: one_to_many sql: LEFT JOIN UNNEST([${organization__endpoint__identifier__assigner__identifier.type}]) as organization__endpoint__identifier__assigner__identifier__type ;; }
  join: organization__endpoint__identifier__assigner__identifier__type__coding { relationship: one_to_many sql: LEFT JOIN UNNEST(${organization__endpoint__identifier__assigner__identifier__type.coding}) as organization__endpoint__identifier__assigner__identifier__type__coding ;; }
  join: organization__endpoint__identifier__type__coding { relationship: one_to_many sql: LEFT JOIN UNNEST(${organization__endpoint__identifier__type.coding}) as organization__endpoint__identifier__type__coding ;; }
  join: organization__identifier { relationship: one_to_many sql: LEFT JOIN UNNEST(${organization.identifier}) as organization__identifier ;; }
  join: organization__identifier__assigner { relationship: one_to_many sql: LEFT JOIN UNNEST([${organization__identifier.assigner}]) as organization__identifier__assigner ;; }
  join: organization__identifier__period { relationship: one_to_many sql: LEFT JOIN UNNEST([${organization__identifier.period}]) as organization__identifier__period ;; }
  join: organization__identifier__type { relationship: one_to_many sql: LEFT JOIN UNNEST([${organization__identifier.type}]) as organization__identifier__type ;; }
  join: organization__identifier__assigner__identifier { relationship: one_to_many sql: LEFT JOIN UNNEST([${organization__identifier__assigner.identifier}]) as organization__identifier__assigner__identifier ;; }
  join: organization__identifier__assigner__identifier__assigner { relationship: one_to_many sql: LEFT JOIN UNNEST([${organization__identifier__assigner__identifier.assigner}]) as organization__identifier__assigner__identifier__assigner ;; }
  join: organization__identifier__assigner__identifier__period { relationship: one_to_many sql: LEFT JOIN UNNEST([${organization__identifier__assigner__identifier.period}]) as organization__identifier__assigner__identifier__period ;; }
  join: organization__identifier__assigner__identifier__type { relationship: one_to_many sql: LEFT JOIN UNNEST([${organization__identifier__assigner__identifier.type}]) as organization__identifier__assigner__identifier__type ;; }
  join: organization__identifier__assigner__identifier__type__coding { relationship: one_to_many sql: LEFT JOIN UNNEST(${organization__identifier__assigner__identifier__type.coding}) as organization__identifier__assigner__identifier__type__coding ;; }
  join: organization__identifier__type__coding { relationship: one_to_many sql: LEFT JOIN UNNEST(${organization__identifier__type.coding}) as organization__identifier__type__coding ;; }
  join: organization__meta { relationship: one_to_many sql: LEFT JOIN UNNEST([${organization.meta}]) as organization__meta ;; }
  join: organization__meta__security { relationship: one_to_many sql: LEFT JOIN UNNEST(${organization__meta.security}) as organization__meta__security ;; }
  join: organization__meta__tag { relationship: one_to_many sql: LEFT JOIN UNNEST(${organization__meta.tag}) as organization__meta__tag ;; }
  join: organization__part_of { relationship: one_to_many sql: LEFT JOIN UNNEST([${organization.part_of}]) as organization__part_of ;; }
  join: organization__part_of__identifier { relationship: one_to_many sql: LEFT JOIN UNNEST([${organization__part_of.identifier}]) as organization__part_of__identifier ;; }
  join: organization__part_of__identifier__assigner { relationship: one_to_many sql: LEFT JOIN UNNEST([${organization__part_of__identifier.assigner}]) as organization__part_of__identifier__assigner ;; }
  join: organization__part_of__identifier__period { relationship: one_to_many sql: LEFT JOIN UNNEST([${organization__part_of__identifier.period}]) as organization__part_of__identifier__period ;; }
  join: organization__part_of__identifier__type { relationship: one_to_many sql: LEFT JOIN UNNEST([${organization__part_of__identifier.type}]) as organization__part_of__identifier__type ;; }
  join: organization__part_of__identifier__assigner__identifier { relationship: one_to_many sql: LEFT JOIN UNNEST([${organization__part_of__identifier__assigner.identifier}]) as organization__part_of__identifier__assigner__identifier ;; }
  join: organization__part_of__identifier__assigner__identifier__assigner { relationship: one_to_many sql: LEFT JOIN UNNEST([${organization__part_of__identifier__assigner__identifier.assigner}]) as organization__part_of__identifier__assigner__identifier__assigner ;; }
  join: organization__part_of__identifier__assigner__identifier__period { relationship: one_to_many sql: LEFT JOIN UNNEST([${organization__part_of__identifier__assigner__identifier.period}]) as organization__part_of__identifier__assigner__identifier__period ;; }
  join: organization__part_of__identifier__assigner__identifier__type { relationship: one_to_many sql: LEFT JOIN UNNEST([${organization__part_of__identifier__assigner__identifier.type}]) as organization__part_of__identifier__assigner__identifier__type ;; }
  join: organization__part_of__identifier__assigner__identifier__type__coding { relationship: one_to_many sql: LEFT JOIN UNNEST(${organization__part_of__identifier__assigner__identifier__type.coding}) as organization__part_of__identifier__assigner__identifier__type__coding ;; }
  join: organization__part_of__identifier__type__coding { relationship: one_to_many sql: LEFT JOIN UNNEST(${organization__part_of__identifier__type.coding}) as organization__part_of__identifier__type__coding ;; }
  join: organization__telecom { relationship: one_to_many sql: LEFT JOIN UNNEST(${organization.telecom}) as organization__telecom ;; }
  join: organization__telecom__period { relationship: one_to_many sql: LEFT JOIN UNNEST([${organization__telecom.period}]) as organization__telecom__period ;; }
  join: organization__text { relationship: one_to_many sql: LEFT JOIN UNNEST([${organization.text}]) as organization__text ;; }
  join: organization__type { relationship: one_to_many sql: LEFT JOIN UNNEST(${organization.type}) as organization__type ;; }
  join: organization__type__coding { relationship: one_to_many sql: LEFT JOIN UNNEST(${organization__type.coding}) as organization__type__coding ;; }
}

explore: patient {
  join: patient__address { relationship: one_to_many sql: LEFT JOIN UNNEST(${patient.address}) as patient__address ;; }
  join: patient__address__line { relationship: one_to_many sql: LEFT JOIN UNNEST(${patient__address.line}) as patient__address__line ;; }
  join: patient__address__geolocation { relationship: one_to_many sql: LEFT JOIN UNNEST([${patient__address.geolocation}]) as patient__address__geolocation ;; }
  join: patient__address__period { relationship: one_to_many sql: LEFT JOIN UNNEST([${patient__address.period}]) as patient__address__period ;; }
  join: patient__address__geolocation__latitude { relationship: one_to_many sql: LEFT JOIN UNNEST([${patient__address__geolocation.latitude}]) as patient__address__geolocation__latitude ;; }
  join: patient__address__geolocation__longitude { relationship: one_to_many sql: LEFT JOIN UNNEST([${patient__address__geolocation.longitude}]) as patient__address__geolocation__longitude ;; }
  join: patient__address__geolocation__latitude__value { relationship: one_to_many sql: LEFT JOIN UNNEST([${patient__address__geolocation__latitude.value}]) as patient__address__geolocation__latitude__value ;; }
  join: patient__address__geolocation__longitude__value { relationship: one_to_many sql: LEFT JOIN UNNEST([${patient__address__geolocation__longitude.value}]) as patient__address__geolocation__longitude__value ;; }
  join: patient__animal { relationship: one_to_many sql: LEFT JOIN UNNEST([${patient.animal}]) as patient__animal ;; }
  join: patient__animal__breed { relationship: one_to_many sql: LEFT JOIN UNNEST([${patient__animal.breed}]) as patient__animal__breed ;; }
  join: patient__animal__gender_status { relationship: one_to_many sql: LEFT JOIN UNNEST([${patient__animal.gender_status}]) as patient__animal__gender_status ;; }
  join: patient__animal__species { relationship: one_to_many sql: LEFT JOIN UNNEST([${patient__animal.species}]) as patient__animal__species ;; }
  join: patient__animal__breed__coding { relationship: one_to_many sql: LEFT JOIN UNNEST(${patient__animal__breed.coding}) as patient__animal__breed__coding ;; }
  join: patient__animal__gender_status__coding { relationship: one_to_many sql: LEFT JOIN UNNEST(${patient__animal__gender_status.coding}) as patient__animal__gender_status__coding ;; }
  join: patient__animal__species__coding { relationship: one_to_many sql: LEFT JOIN UNNEST(${patient__animal__species.coding}) as patient__animal__species__coding ;; }
  join: patient__birth_place { relationship: one_to_many sql: LEFT JOIN UNNEST([${patient.birth_place}]) as patient__birth_place ;; }
  join: patient__birth_place__value { relationship: one_to_many sql: LEFT JOIN UNNEST([${patient__birth_place.value}]) as patient__birth_place__value ;; }
  join: patient__birth_place__value__address { relationship: one_to_many sql: LEFT JOIN UNNEST([${patient__birth_place__value.address}]) as patient__birth_place__value__address ;; }
  join: patient__communication { relationship: one_to_many sql: LEFT JOIN UNNEST(${patient.communication}) as patient__communication ;; }
  join: patient__communication__language { relationship: one_to_many sql: LEFT JOIN UNNEST([${patient__communication.language}]) as patient__communication__language ;; }
  join: patient__communication__language__coding { relationship: one_to_many sql: LEFT JOIN UNNEST(${patient__communication__language.coding}) as patient__communication__language__coding ;; }
  join: patient__contact { relationship: one_to_many sql: LEFT JOIN UNNEST(${patient.contact}) as patient__contact ;; }
  join: patient__contact__address { relationship: one_to_many sql: LEFT JOIN UNNEST([${patient__contact.address}]) as patient__contact__address ;; }
  join: patient__contact__name { relationship: one_to_many sql: LEFT JOIN UNNEST([${patient__contact.name}]) as patient__contact__name ;; }
  join: patient__contact__organization { relationship: one_to_many sql: LEFT JOIN UNNEST([${patient__contact.organization}]) as patient__contact__organization ;; }
  join: patient__contact__period { relationship: one_to_many sql: LEFT JOIN UNNEST([${patient__contact.period}]) as patient__contact__period ;; }
  join: patient__contact__relationship { relationship: one_to_many sql: LEFT JOIN UNNEST(${patient__contact.relationship}) as patient__contact__relationship ;; }
  join: patient__contact__telecom { relationship: one_to_many sql: LEFT JOIN UNNEST(${patient__contact.telecom}) as patient__contact__telecom ;; }
  join: patient__contact__address__period { relationship: one_to_many sql: LEFT JOIN UNNEST([${patient__contact__address.period}]) as patient__contact__address__period ;; }
  join: patient__contact__name__period { relationship: one_to_many sql: LEFT JOIN UNNEST([${patient__contact__name.period}]) as patient__contact__name__period ;; }
  join: patient__contact__organization__identifier { relationship: one_to_many sql: LEFT JOIN UNNEST([${patient__contact__organization.identifier}]) as patient__contact__organization__identifier ;; }
  join: patient__contact__organization__identifier__assigner { relationship: one_to_many sql: LEFT JOIN UNNEST([${patient__contact__organization__identifier.assigner}]) as patient__contact__organization__identifier__assigner ;; }
  join: patient__contact__organization__identifier__period { relationship: one_to_many sql: LEFT JOIN UNNEST([${patient__contact__organization__identifier.period}]) as patient__contact__organization__identifier__period ;; }
  join: patient__contact__organization__identifier__type { relationship: one_to_many sql: LEFT JOIN UNNEST([${patient__contact__organization__identifier.type}]) as patient__contact__organization__identifier__type ;; }
  join: patient__contact__organization__identifier__assigner__identifier { relationship: one_to_many sql: LEFT JOIN UNNEST([${patient__contact__organization__identifier__assigner.identifier}]) as patient__contact__organization__identifier__assigner__identifier ;; }
  join: patient__contact__organization__identifier__assigner__identifier__assigner { relationship: one_to_many sql: LEFT JOIN UNNEST([${patient__contact__organization__identifier__assigner__identifier.assigner}]) as patient__contact__organization__identifier__assigner__identifier__assigner ;; }
  join: patient__contact__organization__identifier__assigner__identifier__period { relationship: one_to_many sql: LEFT JOIN UNNEST([${patient__contact__organization__identifier__assigner__identifier.period}]) as patient__contact__organization__identifier__assigner__identifier__period ;; }
  join: patient__contact__organization__identifier__assigner__identifier__type { relationship: one_to_many sql: LEFT JOIN UNNEST([${patient__contact__organization__identifier__assigner__identifier.type}]) as patient__contact__organization__identifier__assigner__identifier__type ;; }
  join: patient__contact__organization__identifier__assigner__identifier__type__coding { relationship: one_to_many sql: LEFT JOIN UNNEST(${patient__contact__organization__identifier__assigner__identifier__type.coding}) as patient__contact__organization__identifier__assigner__identifier__type__coding ;; }
  join: patient__contact__organization__identifier__type__coding { relationship: one_to_many sql: LEFT JOIN UNNEST(${patient__contact__organization__identifier__type.coding}) as patient__contact__organization__identifier__type__coding ;; }
  join: patient__contact__relationship__coding { relationship: one_to_many sql: LEFT JOIN UNNEST(${patient__contact__relationship.coding}) as patient__contact__relationship__coding ;; }
  join: patient__contact__telecom__period { relationship: one_to_many sql: LEFT JOIN UNNEST([${patient__contact__telecom.period}]) as patient__contact__telecom__period ;; }
  join: patient__deceased { relationship: one_to_many sql: LEFT JOIN UNNEST([${patient.deceased}]) as patient__deceased ;; }
  join: patient__disability_adjusted_life_years { relationship: one_to_many sql: LEFT JOIN UNNEST([${patient.disability_adjusted_life_years}]) as patient__disability_adjusted_life_years ;; }
  join: patient__disability_adjusted_life_years__value { relationship: one_to_many sql: LEFT JOIN UNNEST([${patient__disability_adjusted_life_years.value}]) as patient__disability_adjusted_life_years__value ;; }
  join: patient__general_practitioner { relationship: one_to_many sql: LEFT JOIN UNNEST(${patient.general_practitioner}) as patient__general_practitioner ;; }
  join: patient__general_practitioner__identifier { relationship: one_to_many sql: LEFT JOIN UNNEST([${patient__general_practitioner.identifier}]) as patient__general_practitioner__identifier ;; }
  join: patient__general_practitioner__identifier__assigner { relationship: one_to_many sql: LEFT JOIN UNNEST([${patient__general_practitioner__identifier.assigner}]) as patient__general_practitioner__identifier__assigner ;; }
  join: patient__general_practitioner__identifier__period { relationship: one_to_many sql: LEFT JOIN UNNEST([${patient__general_practitioner__identifier.period}]) as patient__general_practitioner__identifier__period ;; }
  join: patient__general_practitioner__identifier__type { relationship: one_to_many sql: LEFT JOIN UNNEST([${patient__general_practitioner__identifier.type}]) as patient__general_practitioner__identifier__type ;; }
  join: patient__general_practitioner__identifier__assigner__identifier { relationship: one_to_many sql: LEFT JOIN UNNEST([${patient__general_practitioner__identifier__assigner.identifier}]) as patient__general_practitioner__identifier__assigner__identifier ;; }
  join: patient__general_practitioner__identifier__assigner__identifier__assigner { relationship: one_to_many sql: LEFT JOIN UNNEST([${patient__general_practitioner__identifier__assigner__identifier.assigner}]) as patient__general_practitioner__identifier__assigner__identifier__assigner ;; }
  join: patient__general_practitioner__identifier__assigner__identifier__period { relationship: one_to_many sql: LEFT JOIN UNNEST([${patient__general_practitioner__identifier__assigner__identifier.period}]) as patient__general_practitioner__identifier__assigner__identifier__period ;; }
  join: patient__general_practitioner__identifier__assigner__identifier__type { relationship: one_to_many sql: LEFT JOIN UNNEST([${patient__general_practitioner__identifier__assigner__identifier.type}]) as patient__general_practitioner__identifier__assigner__identifier__type ;; }
  join: patient__general_practitioner__identifier__assigner__identifier__type__coding { relationship: one_to_many sql: LEFT JOIN UNNEST(${patient__general_practitioner__identifier__assigner__identifier__type.coding}) as patient__general_practitioner__identifier__assigner__identifier__type__coding ;; }
  join: patient__general_practitioner__identifier__type__coding { relationship: one_to_many sql: LEFT JOIN UNNEST(${patient__general_practitioner__identifier__type.coding}) as patient__general_practitioner__identifier__type__coding ;; }
  join: patient__identifier { relationship: one_to_many sql: LEFT JOIN UNNEST(${patient.identifier}) as patient__identifier ;; }
  join: patient__identifier__assigner { relationship: one_to_many sql: LEFT JOIN UNNEST([${patient__identifier.assigner}]) as patient__identifier__assigner ;; }
  join: patient__identifier__period { relationship: one_to_many sql: LEFT JOIN UNNEST([${patient__identifier.period}]) as patient__identifier__period ;; }
  join: patient__identifier__type { relationship: one_to_many sql: LEFT JOIN UNNEST([${patient__identifier.type}]) as patient__identifier__type ;; }
  join: patient__identifier__assigner__identifier { relationship: one_to_many sql: LEFT JOIN UNNEST([${patient__identifier__assigner.identifier}]) as patient__identifier__assigner__identifier ;; }
  join: patient__identifier__assigner__identifier__assigner { relationship: one_to_many sql: LEFT JOIN UNNEST([${patient__identifier__assigner__identifier.assigner}]) as patient__identifier__assigner__identifier__assigner ;; }
  join: patient__identifier__assigner__identifier__period { relationship: one_to_many sql: LEFT JOIN UNNEST([${patient__identifier__assigner__identifier.period}]) as patient__identifier__assigner__identifier__period ;; }
  join: patient__identifier__assigner__identifier__type { relationship: one_to_many sql: LEFT JOIN UNNEST([${patient__identifier__assigner__identifier.type}]) as patient__identifier__assigner__identifier__type ;; }
  join: patient__identifier__assigner__identifier__type__coding { relationship: one_to_many sql: LEFT JOIN UNNEST(${patient__identifier__assigner__identifier__type.coding}) as patient__identifier__assigner__identifier__type__coding ;; }
  join: patient__identifier__type__coding { relationship: one_to_many sql: LEFT JOIN UNNEST(${patient__identifier__type.coding}) as patient__identifier__type__coding ;; }
  join: patient__link { relationship: one_to_many sql: LEFT JOIN UNNEST(${patient.link}) as patient__link ;; }
  join: patient__link__other { relationship: one_to_many sql: LEFT JOIN UNNEST([${patient__link.other}]) as patient__link__other ;; }
  join: patient__link__other__identifier { relationship: one_to_many sql: LEFT JOIN UNNEST([${patient__link__other.identifier}]) as patient__link__other__identifier ;; }
  join: patient__link__other__identifier__assigner { relationship: one_to_many sql: LEFT JOIN UNNEST([${patient__link__other__identifier.assigner}]) as patient__link__other__identifier__assigner ;; }
  join: patient__link__other__identifier__period { relationship: one_to_many sql: LEFT JOIN UNNEST([${patient__link__other__identifier.period}]) as patient__link__other__identifier__period ;; }
  join: patient__link__other__identifier__type { relationship: one_to_many sql: LEFT JOIN UNNEST([${patient__link__other__identifier.type}]) as patient__link__other__identifier__type ;; }
  join: patient__link__other__identifier__assigner__identifier { relationship: one_to_many sql: LEFT JOIN UNNEST([${patient__link__other__identifier__assigner.identifier}]) as patient__link__other__identifier__assigner__identifier ;; }
  join: patient__link__other__identifier__assigner__identifier__assigner { relationship: one_to_many sql: LEFT JOIN UNNEST([${patient__link__other__identifier__assigner__identifier.assigner}]) as patient__link__other__identifier__assigner__identifier__assigner ;; }
  join: patient__link__other__identifier__assigner__identifier__period { relationship: one_to_many sql: LEFT JOIN UNNEST([${patient__link__other__identifier__assigner__identifier.period}]) as patient__link__other__identifier__assigner__identifier__period ;; }
  join: patient__link__other__identifier__assigner__identifier__type { relationship: one_to_many sql: LEFT JOIN UNNEST([${patient__link__other__identifier__assigner__identifier.type}]) as patient__link__other__identifier__assigner__identifier__type ;; }
  join: patient__link__other__identifier__assigner__identifier__type__coding { relationship: one_to_many sql: LEFT JOIN UNNEST(${patient__link__other__identifier__assigner__identifier__type.coding}) as patient__link__other__identifier__assigner__identifier__type__coding ;; }
  join: patient__link__other__identifier__type__coding { relationship: one_to_many sql: LEFT JOIN UNNEST(${patient__link__other__identifier__type.coding}) as patient__link__other__identifier__type__coding ;; }
  join: patient__managing_organization { relationship: one_to_many sql: LEFT JOIN UNNEST([${patient.managing_organization}]) as patient__managing_organization ;; }
  join: patient__managing_organization__identifier { relationship: one_to_many sql: LEFT JOIN UNNEST([${patient__managing_organization.identifier}]) as patient__managing_organization__identifier ;; }
  join: patient__managing_organization__identifier__assigner { relationship: one_to_many sql: LEFT JOIN UNNEST([${patient__managing_organization__identifier.assigner}]) as patient__managing_organization__identifier__assigner ;; }
  join: patient__managing_organization__identifier__period { relationship: one_to_many sql: LEFT JOIN UNNEST([${patient__managing_organization__identifier.period}]) as patient__managing_organization__identifier__period ;; }
  join: patient__managing_organization__identifier__type { relationship: one_to_many sql: LEFT JOIN UNNEST([${patient__managing_organization__identifier.type}]) as patient__managing_organization__identifier__type ;; }
  join: patient__managing_organization__identifier__assigner__identifier { relationship: one_to_many sql: LEFT JOIN UNNEST([${patient__managing_organization__identifier__assigner.identifier}]) as patient__managing_organization__identifier__assigner__identifier ;; }
  join: patient__managing_organization__identifier__assigner__identifier__assigner { relationship: one_to_many sql: LEFT JOIN UNNEST([${patient__managing_organization__identifier__assigner__identifier.assigner}]) as patient__managing_organization__identifier__assigner__identifier__assigner ;; }
  join: patient__managing_organization__identifier__assigner__identifier__period { relationship: one_to_many sql: LEFT JOIN UNNEST([${patient__managing_organization__identifier__assigner__identifier.period}]) as patient__managing_organization__identifier__assigner__identifier__period ;; }
  join: patient__managing_organization__identifier__assigner__identifier__type { relationship: one_to_many sql: LEFT JOIN UNNEST([${patient__managing_organization__identifier__assigner__identifier.type}]) as patient__managing_organization__identifier__assigner__identifier__type ;; }
  join: patient__managing_organization__identifier__assigner__identifier__type__coding { relationship: one_to_many sql: LEFT JOIN UNNEST(${patient__managing_organization__identifier__assigner__identifier__type.coding}) as patient__managing_organization__identifier__assigner__identifier__type__coding ;; }
  join: patient__managing_organization__identifier__type__coding { relationship: one_to_many sql: LEFT JOIN UNNEST(${patient__managing_organization__identifier__type.coding}) as patient__managing_organization__identifier__type__coding ;; }
  join: patient__marital_status { relationship: one_to_many sql: LEFT JOIN UNNEST([${patient.marital_status}]) as patient__marital_status ;; }
  join: patient__marital_status__coding { relationship: one_to_many sql: LEFT JOIN UNNEST(${patient__marital_status.coding}) as patient__marital_status__coding ;; }
  join: patient__meta { relationship: one_to_many sql: LEFT JOIN UNNEST([${patient.meta}]) as patient__meta ;; }
  join: patient__meta__security { relationship: one_to_many sql: LEFT JOIN UNNEST(${patient__meta.security}) as patient__meta__security ;; }
  join: patient__meta__tag { relationship: one_to_many sql: LEFT JOIN UNNEST(${patient__meta.tag}) as patient__meta__tag ;; }
  join: patient__multiple_birth { relationship: one_to_many sql: LEFT JOIN UNNEST([${patient.multiple_birth}]) as patient__multiple_birth ;; }
  join: patient__name { relationship: one_to_many sql: LEFT JOIN UNNEST(${patient.name}) as patient__name ;; }
  join: patient__name__given { relationship: one_to_many sql: LEFT JOIN UNNEST(${patient__name.given}) as patient__name__given ;; }
  join: patient__name__period { relationship: one_to_many sql: LEFT JOIN UNNEST([${patient__name.period}]) as patient__name__period ;; }
  join: patient__patient_mothers_maiden_name { relationship: one_to_many sql: LEFT JOIN UNNEST([${patient.patient_mothers_maiden_name}]) as patient__patient_mothers_maiden_name ;; }
  join: patient__patient_mothers_maiden_name__value { relationship: one_to_many sql: LEFT JOIN UNNEST([${patient__patient_mothers_maiden_name.value}]) as patient__patient_mothers_maiden_name__value ;; }
  join: patient__photo { relationship: one_to_many sql: LEFT JOIN UNNEST(${patient.photo}) as patient__photo ;; }
  join: patient__quality_adjusted_life_years { relationship: one_to_many sql: LEFT JOIN UNNEST([${patient.quality_adjusted_life_years}]) as patient__quality_adjusted_life_years ;; }
  join: patient__quality_adjusted_life_years__value { relationship: one_to_many sql: LEFT JOIN UNNEST([${patient__quality_adjusted_life_years.value}]) as patient__quality_adjusted_life_years__value ;; }
  join: patient__shr_actor_fictional_person_extension { relationship: one_to_many sql: LEFT JOIN UNNEST([${patient.shr_actor_fictional_person_extension}]) as patient__shr_actor_fictional_person_extension ;; }
  join: patient__shr_actor_fictional_person_extension__value { relationship: one_to_many sql: LEFT JOIN UNNEST([${patient__shr_actor_fictional_person_extension.value}]) as patient__shr_actor_fictional_person_extension__value ;; }
  join: patient__shr_demographics_social_security_number_extension { relationship: one_to_many sql: LEFT JOIN UNNEST([${patient.shr_demographics_social_security_number_extension}]) as patient__shr_demographics_social_security_number_extension ;; }
  join: patient__shr_demographics_social_security_number_extension__value { relationship: one_to_many sql: LEFT JOIN UNNEST([${patient__shr_demographics_social_security_number_extension.value}]) as patient__shr_demographics_social_security_number_extension__value ;; }
  join: patient__shr_entity_fathers_name_extension { relationship: one_to_many sql: LEFT JOIN UNNEST([${patient.shr_entity_fathers_name_extension}]) as patient__shr_entity_fathers_name_extension ;; }
  join: patient__shr_entity_fathers_name_extension__value { relationship: one_to_many sql: LEFT JOIN UNNEST([${patient__shr_entity_fathers_name_extension.value}]) as patient__shr_entity_fathers_name_extension__value ;; }
  join: patient__shr_entity_fathers_name_extension__value__human_name { relationship: one_to_many sql: LEFT JOIN UNNEST([${patient__shr_entity_fathers_name_extension__value.human_name}]) as patient__shr_entity_fathers_name_extension__value__human_name ;; }
  join: patient__shr_entity_person_extension { relationship: one_to_many sql: LEFT JOIN UNNEST([${patient.shr_entity_person_extension}]) as patient__shr_entity_person_extension ;; }
  join: patient__shr_entity_person_extension__value { relationship: one_to_many sql: LEFT JOIN UNNEST([${patient__shr_entity_person_extension.value}]) as patient__shr_entity_person_extension__value ;; }
  join: patient__shr_entity_person_extension__value__reference { relationship: one_to_many sql: LEFT JOIN UNNEST([${patient__shr_entity_person_extension__value.reference}]) as patient__shr_entity_person_extension__value__reference ;; }
  join: patient__telecom { relationship: one_to_many sql: LEFT JOIN UNNEST(${patient.telecom}) as patient__telecom ;; }
  join: patient__telecom__period { relationship: one_to_many sql: LEFT JOIN UNNEST([${patient__telecom.period}]) as patient__telecom__period ;; }
  join: patient__text { relationship: one_to_many sql: LEFT JOIN UNNEST([${patient.text}]) as patient__text ;; }
  join: patient__us_core_birthsex { relationship: one_to_many sql: LEFT JOIN UNNEST([${patient.us_core_birthsex}]) as patient__us_core_birthsex ;; }
  join: patient__us_core_birthsex__value { relationship: one_to_many sql: LEFT JOIN UNNEST([${patient__us_core_birthsex.value}]) as patient__us_core_birthsex__value ;; }
  join: patient__us_core_ethnicity { relationship: one_to_many sql: LEFT JOIN UNNEST([${patient.us_core_ethnicity}]) as patient__us_core_ethnicity ;; }
  join: patient__us_core_ethnicity__omb_category { relationship: one_to_many sql: LEFT JOIN UNNEST([${patient__us_core_ethnicity.omb_category}]) as patient__us_core_ethnicity__omb_category ;; }
  join: patient__us_core_ethnicity__text { relationship: one_to_many sql: LEFT JOIN UNNEST([${patient__us_core_ethnicity.text}]) as patient__us_core_ethnicity__text ;; }
  join: patient__us_core_ethnicity__omb_category__value { relationship: one_to_many sql: LEFT JOIN UNNEST([${patient__us_core_ethnicity__omb_category.value}]) as patient__us_core_ethnicity__omb_category__value ;; }
  join: patient__us_core_ethnicity__omb_category__value__coding { relationship: one_to_many sql: LEFT JOIN UNNEST([${patient__us_core_ethnicity__omb_category__value.coding}]) as patient__us_core_ethnicity__omb_category__value__coding ;; }
  join: patient__us_core_ethnicity__text__value { relationship: one_to_many sql: LEFT JOIN UNNEST([${patient__us_core_ethnicity__text.value}]) as patient__us_core_ethnicity__text__value ;; }
  join: patient__us_core_race { relationship: one_to_many sql: LEFT JOIN UNNEST([${patient.us_core_race}]) as patient__us_core_race ;; }
  join: patient__us_core_race__omb_category { relationship: one_to_many sql: LEFT JOIN UNNEST([${patient__us_core_race.omb_category}]) as patient__us_core_race__omb_category ;; }
  join: patient__us_core_race__text { relationship: one_to_many sql: LEFT JOIN UNNEST([${patient__us_core_race.text}]) as patient__us_core_race__text ;; }
  join: patient__us_core_race__omb_category__value { relationship: one_to_many sql: LEFT JOIN UNNEST([${patient__us_core_race__omb_category.value}]) as patient__us_core_race__omb_category__value ;; }
  join: patient__us_core_race__omb_category__value__coding { relationship: one_to_many sql: LEFT JOIN UNNEST([${patient__us_core_race__omb_category__value.coding}]) as patient__us_core_race__omb_category__value__coding ;; }
  join: patient__us_core_race__text__value { relationship: one_to_many sql: LEFT JOIN UNNEST([${patient__us_core_race__text.value}]) as patient__us_core_race__text__value ;; }
}

explore: practitioner {
  join: practitioner__address { relationship: one_to_many sql: LEFT JOIN UNNEST(${practitioner.address}) as practitioner__address ;; }
  join: practitioner__address__period { relationship: one_to_many sql: LEFT JOIN UNNEST([${practitioner__address.period}]) as practitioner__address__period ;; }
  join: practitioner__communication { relationship: one_to_many sql: LEFT JOIN UNNEST(${practitioner.communication}) as practitioner__communication ;; }
  join: practitioner__communication__coding { relationship: one_to_many sql: LEFT JOIN UNNEST(${practitioner__communication.coding}) as practitioner__communication__coding ;; }
  join: practitioner__identifier { relationship: one_to_many sql: LEFT JOIN UNNEST(${practitioner.identifier}) as practitioner__identifier ;; }
  join: practitioner__identifier__assigner { relationship: one_to_many sql: LEFT JOIN UNNEST([${practitioner__identifier.assigner}]) as practitioner__identifier__assigner ;; }
  join: practitioner__identifier__period { relationship: one_to_many sql: LEFT JOIN UNNEST([${practitioner__identifier.period}]) as practitioner__identifier__period ;; }
  join: practitioner__identifier__type { relationship: one_to_many sql: LEFT JOIN UNNEST([${practitioner__identifier.type}]) as practitioner__identifier__type ;; }
  join: practitioner__identifier__assigner__identifier { relationship: one_to_many sql: LEFT JOIN UNNEST([${practitioner__identifier__assigner.identifier}]) as practitioner__identifier__assigner__identifier ;; }
  join: practitioner__identifier__assigner__identifier__assigner { relationship: one_to_many sql: LEFT JOIN UNNEST([${practitioner__identifier__assigner__identifier.assigner}]) as practitioner__identifier__assigner__identifier__assigner ;; }
  join: practitioner__identifier__assigner__identifier__period { relationship: one_to_many sql: LEFT JOIN UNNEST([${practitioner__identifier__assigner__identifier.period}]) as practitioner__identifier__assigner__identifier__period ;; }
  join: practitioner__identifier__assigner__identifier__type { relationship: one_to_many sql: LEFT JOIN UNNEST([${practitioner__identifier__assigner__identifier.type}]) as practitioner__identifier__assigner__identifier__type ;; }
  join: practitioner__identifier__assigner__identifier__type__coding { relationship: one_to_many sql: LEFT JOIN UNNEST(${practitioner__identifier__assigner__identifier__type.coding}) as practitioner__identifier__assigner__identifier__type__coding ;; }
  join: practitioner__identifier__type__coding { relationship: one_to_many sql: LEFT JOIN UNNEST(${practitioner__identifier__type.coding}) as practitioner__identifier__type__coding ;; }
  join: practitioner__meta { relationship: one_to_many sql: LEFT JOIN UNNEST([${practitioner.meta}]) as practitioner__meta ;; }
  join: practitioner__meta__security { relationship: one_to_many sql: LEFT JOIN UNNEST(${practitioner__meta.security}) as practitioner__meta__security ;; }
  join: practitioner__meta__tag { relationship: one_to_many sql: LEFT JOIN UNNEST(${practitioner__meta.tag}) as practitioner__meta__tag ;; }
  join: practitioner__name { relationship: one_to_many sql: LEFT JOIN UNNEST(${practitioner.name}) as practitioner__name ;; }
  join: practitioner__name__given { relationship: one_to_many sql: LEFT JOIN UNNEST(${practitioner__name.given}) as practitioner__name__given ;; }
  join: practitioner__name__period { relationship: one_to_many sql: LEFT JOIN UNNEST([${practitioner__name.period}]) as practitioner__name__period ;; }
  join: practitioner__photo { relationship: one_to_many sql: LEFT JOIN UNNEST(${practitioner.photo}) as practitioner__photo ;; }
  join: practitioner__qualification { relationship: one_to_many sql: LEFT JOIN UNNEST(${practitioner.qualification}) as practitioner__qualification ;; }
  join: practitioner__qualification__code { relationship: one_to_many sql: LEFT JOIN UNNEST([${practitioner__qualification.code}]) as practitioner__qualification__code ;; }
  join: practitioner__qualification__identifier { relationship: one_to_many sql: LEFT JOIN UNNEST(${practitioner__qualification.identifier}) as practitioner__qualification__identifier ;; }
  join: practitioner__qualification__issuer { relationship: one_to_many sql: LEFT JOIN UNNEST([${practitioner__qualification.issuer}]) as practitioner__qualification__issuer ;; }
  join: practitioner__qualification__period { relationship: one_to_many sql: LEFT JOIN UNNEST([${practitioner__qualification.period}]) as practitioner__qualification__period ;; }
  join: practitioner__qualification__code__coding { relationship: one_to_many sql: LEFT JOIN UNNEST(${practitioner__qualification__code.coding}) as practitioner__qualification__code__coding ;; }
  join: practitioner__qualification__identifier__assigner { relationship: one_to_many sql: LEFT JOIN UNNEST([${practitioner__qualification__identifier.assigner}]) as practitioner__qualification__identifier__assigner ;; }
  join: practitioner__qualification__identifier__period { relationship: one_to_many sql: LEFT JOIN UNNEST([${practitioner__qualification__identifier.period}]) as practitioner__qualification__identifier__period ;; }
  join: practitioner__qualification__identifier__type { relationship: one_to_many sql: LEFT JOIN UNNEST([${practitioner__qualification__identifier.type}]) as practitioner__qualification__identifier__type ;; }
  join: practitioner__qualification__identifier__assigner__identifier { relationship: one_to_many sql: LEFT JOIN UNNEST([${practitioner__qualification__identifier__assigner.identifier}]) as practitioner__qualification__identifier__assigner__identifier ;; }
  join: practitioner__qualification__identifier__assigner__identifier__assigner { relationship: one_to_many sql: LEFT JOIN UNNEST([${practitioner__qualification__identifier__assigner__identifier.assigner}]) as practitioner__qualification__identifier__assigner__identifier__assigner ;; }
  join: practitioner__qualification__identifier__assigner__identifier__period { relationship: one_to_many sql: LEFT JOIN UNNEST([${practitioner__qualification__identifier__assigner__identifier.period}]) as practitioner__qualification__identifier__assigner__identifier__period ;; }
  join: practitioner__qualification__identifier__assigner__identifier__type { relationship: one_to_many sql: LEFT JOIN UNNEST([${practitioner__qualification__identifier__assigner__identifier.type}]) as practitioner__qualification__identifier__assigner__identifier__type ;; }
  join: practitioner__qualification__identifier__assigner__identifier__type__coding { relationship: one_to_many sql: LEFT JOIN UNNEST(${practitioner__qualification__identifier__assigner__identifier__type.coding}) as practitioner__qualification__identifier__assigner__identifier__type__coding ;; }
  join: practitioner__qualification__identifier__type__coding { relationship: one_to_many sql: LEFT JOIN UNNEST(${practitioner__qualification__identifier__type.coding}) as practitioner__qualification__identifier__type__coding ;; }
  join: practitioner__qualification__issuer__identifier { relationship: one_to_many sql: LEFT JOIN UNNEST([${practitioner__qualification__issuer.identifier}]) as practitioner__qualification__issuer__identifier ;; }
  join: practitioner__qualification__issuer__identifier__assigner { relationship: one_to_many sql: LEFT JOIN UNNEST([${practitioner__qualification__issuer__identifier.assigner}]) as practitioner__qualification__issuer__identifier__assigner ;; }
  join: practitioner__qualification__issuer__identifier__period { relationship: one_to_many sql: LEFT JOIN UNNEST([${practitioner__qualification__issuer__identifier.period}]) as practitioner__qualification__issuer__identifier__period ;; }
  join: practitioner__qualification__issuer__identifier__type { relationship: one_to_many sql: LEFT JOIN UNNEST([${practitioner__qualification__issuer__identifier.type}]) as practitioner__qualification__issuer__identifier__type ;; }
  join: practitioner__qualification__issuer__identifier__assigner__identifier { relationship: one_to_many sql: LEFT JOIN UNNEST([${practitioner__qualification__issuer__identifier__assigner.identifier}]) as practitioner__qualification__issuer__identifier__assigner__identifier ;; }
  join: practitioner__qualification__issuer__identifier__assigner__identifier__assigner { relationship: one_to_many sql: LEFT JOIN UNNEST([${practitioner__qualification__issuer__identifier__assigner__identifier.assigner}]) as practitioner__qualification__issuer__identifier__assigner__identifier__assigner ;; }
  join: practitioner__qualification__issuer__identifier__assigner__identifier__period { relationship: one_to_many sql: LEFT JOIN UNNEST([${practitioner__qualification__issuer__identifier__assigner__identifier.period}]) as practitioner__qualification__issuer__identifier__assigner__identifier__period ;; }
  join: practitioner__qualification__issuer__identifier__assigner__identifier__type { relationship: one_to_many sql: LEFT JOIN UNNEST([${practitioner__qualification__issuer__identifier__assigner__identifier.type}]) as practitioner__qualification__issuer__identifier__assigner__identifier__type ;; }
  join: practitioner__qualification__issuer__identifier__assigner__identifier__type__coding { relationship: one_to_many sql: LEFT JOIN UNNEST(${practitioner__qualification__issuer__identifier__assigner__identifier__type.coding}) as practitioner__qualification__issuer__identifier__assigner__identifier__type__coding ;; }
  join: practitioner__qualification__issuer__identifier__type__coding { relationship: one_to_many sql: LEFT JOIN UNNEST(${practitioner__qualification__issuer__identifier__type.coding}) as practitioner__qualification__issuer__identifier__type__coding ;; }
  join: practitioner__telecom { relationship: one_to_many sql: LEFT JOIN UNNEST(${practitioner.telecom}) as practitioner__telecom ;; }
  join: practitioner__telecom__period { relationship: one_to_many sql: LEFT JOIN UNNEST([${practitioner__telecom.period}]) as practitioner__telecom__period ;; }
  join: practitioner__text { relationship: one_to_many sql: LEFT JOIN UNNEST([${practitioner.text}]) as practitioner__text ;; }
}

explore: procedure {
  join: procedure__based_on { relationship: one_to_many sql: LEFT JOIN UNNEST(${procedure.based_on}) as procedure__based_on ;; }
  join: procedure__based_on__identifier { relationship: one_to_many sql: LEFT JOIN UNNEST([${procedure__based_on.identifier}]) as procedure__based_on__identifier ;; }
  join: procedure__based_on__identifier__assigner { relationship: one_to_many sql: LEFT JOIN UNNEST([${procedure__based_on__identifier.assigner}]) as procedure__based_on__identifier__assigner ;; }
  join: procedure__based_on__identifier__period { relationship: one_to_many sql: LEFT JOIN UNNEST([${procedure__based_on__identifier.period}]) as procedure__based_on__identifier__period ;; }
  join: procedure__based_on__identifier__type { relationship: one_to_many sql: LEFT JOIN UNNEST([${procedure__based_on__identifier.type}]) as procedure__based_on__identifier__type ;; }
  join: procedure__based_on__identifier__assigner__identifier { relationship: one_to_many sql: LEFT JOIN UNNEST([${procedure__based_on__identifier__assigner.identifier}]) as procedure__based_on__identifier__assigner__identifier ;; }
  join: procedure__based_on__identifier__assigner__identifier__assigner { relationship: one_to_many sql: LEFT JOIN UNNEST([${procedure__based_on__identifier__assigner__identifier.assigner}]) as procedure__based_on__identifier__assigner__identifier__assigner ;; }
  join: procedure__based_on__identifier__assigner__identifier__period { relationship: one_to_many sql: LEFT JOIN UNNEST([${procedure__based_on__identifier__assigner__identifier.period}]) as procedure__based_on__identifier__assigner__identifier__period ;; }
  join: procedure__based_on__identifier__assigner__identifier__type { relationship: one_to_many sql: LEFT JOIN UNNEST([${procedure__based_on__identifier__assigner__identifier.type}]) as procedure__based_on__identifier__assigner__identifier__type ;; }
  join: procedure__based_on__identifier__assigner__identifier__type__coding { relationship: one_to_many sql: LEFT JOIN UNNEST(${procedure__based_on__identifier__assigner__identifier__type.coding}) as procedure__based_on__identifier__assigner__identifier__type__coding ;; }
  join: procedure__based_on__identifier__type__coding { relationship: one_to_many sql: LEFT JOIN UNNEST(${procedure__based_on__identifier__type.coding}) as procedure__based_on__identifier__type__coding ;; }
  join: procedure__body_site { relationship: one_to_many sql: LEFT JOIN UNNEST(${procedure.body_site}) as procedure__body_site ;; }
  join: procedure__body_site__coding { relationship: one_to_many sql: LEFT JOIN UNNEST(${procedure__body_site.coding}) as procedure__body_site__coding ;; }
  join: procedure__category { relationship: one_to_many sql: LEFT JOIN UNNEST([${procedure.category}]) as procedure__category ;; }
  join: procedure__category__coding { relationship: one_to_many sql: LEFT JOIN UNNEST(${procedure__category.coding}) as procedure__category__coding ;; }
  join: procedure__code { relationship: one_to_many sql: LEFT JOIN UNNEST([${procedure.code}]) as procedure__code ;; }
  join: procedure__code__coding { relationship: one_to_many sql: LEFT JOIN UNNEST(${procedure__code.coding}) as procedure__code__coding ;; }
  join: procedure__complication { relationship: one_to_many sql: LEFT JOIN UNNEST(${procedure.complication}) as procedure__complication ;; }
  join: procedure__complication__coding { relationship: one_to_many sql: LEFT JOIN UNNEST(${procedure__complication.coding}) as procedure__complication__coding ;; }
  join: procedure__complication_detail { relationship: one_to_many sql: LEFT JOIN UNNEST(${procedure.complication_detail}) as procedure__complication_detail ;; }
  join: procedure__complication_detail__identifier { relationship: one_to_many sql: LEFT JOIN UNNEST([${procedure__complication_detail.identifier}]) as procedure__complication_detail__identifier ;; }
  join: procedure__complication_detail__identifier__assigner { relationship: one_to_many sql: LEFT JOIN UNNEST([${procedure__complication_detail__identifier.assigner}]) as procedure__complication_detail__identifier__assigner ;; }
  join: procedure__complication_detail__identifier__period { relationship: one_to_many sql: LEFT JOIN UNNEST([${procedure__complication_detail__identifier.period}]) as procedure__complication_detail__identifier__period ;; }
  join: procedure__complication_detail__identifier__type { relationship: one_to_many sql: LEFT JOIN UNNEST([${procedure__complication_detail__identifier.type}]) as procedure__complication_detail__identifier__type ;; }
  join: procedure__complication_detail__identifier__assigner__identifier { relationship: one_to_many sql: LEFT JOIN UNNEST([${procedure__complication_detail__identifier__assigner.identifier}]) as procedure__complication_detail__identifier__assigner__identifier ;; }
  join: procedure__complication_detail__identifier__assigner__identifier__assigner { relationship: one_to_many sql: LEFT JOIN UNNEST([${procedure__complication_detail__identifier__assigner__identifier.assigner}]) as procedure__complication_detail__identifier__assigner__identifier__assigner ;; }
  join: procedure__complication_detail__identifier__assigner__identifier__period { relationship: one_to_many sql: LEFT JOIN UNNEST([${procedure__complication_detail__identifier__assigner__identifier.period}]) as procedure__complication_detail__identifier__assigner__identifier__period ;; }
  join: procedure__complication_detail__identifier__assigner__identifier__type { relationship: one_to_many sql: LEFT JOIN UNNEST([${procedure__complication_detail__identifier__assigner__identifier.type}]) as procedure__complication_detail__identifier__assigner__identifier__type ;; }
  join: procedure__complication_detail__identifier__assigner__identifier__type__coding { relationship: one_to_many sql: LEFT JOIN UNNEST(${procedure__complication_detail__identifier__assigner__identifier__type.coding}) as procedure__complication_detail__identifier__assigner__identifier__type__coding ;; }
  join: procedure__complication_detail__identifier__type__coding { relationship: one_to_many sql: LEFT JOIN UNNEST(${procedure__complication_detail__identifier__type.coding}) as procedure__complication_detail__identifier__type__coding ;; }
  join: procedure__context { relationship: one_to_many sql: LEFT JOIN UNNEST([${procedure.context}]) as procedure__context ;; }
  join: procedure__context__identifier { relationship: one_to_many sql: LEFT JOIN UNNEST([${procedure__context.identifier}]) as procedure__context__identifier ;; }
  join: procedure__context__identifier__assigner { relationship: one_to_many sql: LEFT JOIN UNNEST([${procedure__context__identifier.assigner}]) as procedure__context__identifier__assigner ;; }
  join: procedure__context__identifier__period { relationship: one_to_many sql: LEFT JOIN UNNEST([${procedure__context__identifier.period}]) as procedure__context__identifier__period ;; }
  join: procedure__context__identifier__type { relationship: one_to_many sql: LEFT JOIN UNNEST([${procedure__context__identifier.type}]) as procedure__context__identifier__type ;; }
  join: procedure__context__identifier__assigner__identifier { relationship: one_to_many sql: LEFT JOIN UNNEST([${procedure__context__identifier__assigner.identifier}]) as procedure__context__identifier__assigner__identifier ;; }
  join: procedure__context__identifier__assigner__identifier__assigner { relationship: one_to_many sql: LEFT JOIN UNNEST([${procedure__context__identifier__assigner__identifier.assigner}]) as procedure__context__identifier__assigner__identifier__assigner ;; }
  join: procedure__context__identifier__assigner__identifier__period { relationship: one_to_many sql: LEFT JOIN UNNEST([${procedure__context__identifier__assigner__identifier.period}]) as procedure__context__identifier__assigner__identifier__period ;; }
  join: procedure__context__identifier__assigner__identifier__type { relationship: one_to_many sql: LEFT JOIN UNNEST([${procedure__context__identifier__assigner__identifier.type}]) as procedure__context__identifier__assigner__identifier__type ;; }
  join: procedure__context__identifier__assigner__identifier__type__coding { relationship: one_to_many sql: LEFT JOIN UNNEST(${procedure__context__identifier__assigner__identifier__type.coding}) as procedure__context__identifier__assigner__identifier__type__coding ;; }
  join: procedure__context__identifier__type__coding { relationship: one_to_many sql: LEFT JOIN UNNEST(${procedure__context__identifier__type.coding}) as procedure__context__identifier__type__coding ;; }
  join: procedure__definition { relationship: one_to_many sql: LEFT JOIN UNNEST(${procedure.definition}) as procedure__definition ;; }
  join: procedure__definition__identifier { relationship: one_to_many sql: LEFT JOIN UNNEST([${procedure__definition.identifier}]) as procedure__definition__identifier ;; }
  join: procedure__definition__identifier__assigner { relationship: one_to_many sql: LEFT JOIN UNNEST([${procedure__definition__identifier.assigner}]) as procedure__definition__identifier__assigner ;; }
  join: procedure__definition__identifier__period { relationship: one_to_many sql: LEFT JOIN UNNEST([${procedure__definition__identifier.period}]) as procedure__definition__identifier__period ;; }
  join: procedure__definition__identifier__type { relationship: one_to_many sql: LEFT JOIN UNNEST([${procedure__definition__identifier.type}]) as procedure__definition__identifier__type ;; }
  join: procedure__definition__identifier__assigner__identifier { relationship: one_to_many sql: LEFT JOIN UNNEST([${procedure__definition__identifier__assigner.identifier}]) as procedure__definition__identifier__assigner__identifier ;; }
  join: procedure__definition__identifier__assigner__identifier__assigner { relationship: one_to_many sql: LEFT JOIN UNNEST([${procedure__definition__identifier__assigner__identifier.assigner}]) as procedure__definition__identifier__assigner__identifier__assigner ;; }
  join: procedure__definition__identifier__assigner__identifier__period { relationship: one_to_many sql: LEFT JOIN UNNEST([${procedure__definition__identifier__assigner__identifier.period}]) as procedure__definition__identifier__assigner__identifier__period ;; }
  join: procedure__definition__identifier__assigner__identifier__type { relationship: one_to_many sql: LEFT JOIN UNNEST([${procedure__definition__identifier__assigner__identifier.type}]) as procedure__definition__identifier__assigner__identifier__type ;; }
  join: procedure__definition__identifier__assigner__identifier__type__coding { relationship: one_to_many sql: LEFT JOIN UNNEST(${procedure__definition__identifier__assigner__identifier__type.coding}) as procedure__definition__identifier__assigner__identifier__type__coding ;; }
  join: procedure__definition__identifier__type__coding { relationship: one_to_many sql: LEFT JOIN UNNEST(${procedure__definition__identifier__type.coding}) as procedure__definition__identifier__type__coding ;; }
  join: procedure__focal_device { relationship: one_to_many sql: LEFT JOIN UNNEST(${procedure.focal_device}) as procedure__focal_device ;; }
  join: procedure__focal_device__action { relationship: one_to_many sql: LEFT JOIN UNNEST([${procedure__focal_device.action}]) as procedure__focal_device__action ;; }
  join: procedure__focal_device__manipulated { relationship: one_to_many sql: LEFT JOIN UNNEST([${procedure__focal_device.manipulated}]) as procedure__focal_device__manipulated ;; }
  join: procedure__focal_device__action__coding { relationship: one_to_many sql: LEFT JOIN UNNEST(${procedure__focal_device__action.coding}) as procedure__focal_device__action__coding ;; }
  join: procedure__focal_device__manipulated__identifier { relationship: one_to_many sql: LEFT JOIN UNNEST([${procedure__focal_device__manipulated.identifier}]) as procedure__focal_device__manipulated__identifier ;; }
  join: procedure__focal_device__manipulated__identifier__assigner { relationship: one_to_many sql: LEFT JOIN UNNEST([${procedure__focal_device__manipulated__identifier.assigner}]) as procedure__focal_device__manipulated__identifier__assigner ;; }
  join: procedure__focal_device__manipulated__identifier__period { relationship: one_to_many sql: LEFT JOIN UNNEST([${procedure__focal_device__manipulated__identifier.period}]) as procedure__focal_device__manipulated__identifier__period ;; }
  join: procedure__focal_device__manipulated__identifier__type { relationship: one_to_many sql: LEFT JOIN UNNEST([${procedure__focal_device__manipulated__identifier.type}]) as procedure__focal_device__manipulated__identifier__type ;; }
  join: procedure__focal_device__manipulated__identifier__assigner__identifier { relationship: one_to_many sql: LEFT JOIN UNNEST([${procedure__focal_device__manipulated__identifier__assigner.identifier}]) as procedure__focal_device__manipulated__identifier__assigner__identifier ;; }
  join: procedure__focal_device__manipulated__identifier__assigner__identifier__assigner { relationship: one_to_many sql: LEFT JOIN UNNEST([${procedure__focal_device__manipulated__identifier__assigner__identifier.assigner}]) as procedure__focal_device__manipulated__identifier__assigner__identifier__assigner ;; }
  join: procedure__focal_device__manipulated__identifier__assigner__identifier__period { relationship: one_to_many sql: LEFT JOIN UNNEST([${procedure__focal_device__manipulated__identifier__assigner__identifier.period}]) as procedure__focal_device__manipulated__identifier__assigner__identifier__period ;; }
  join: procedure__focal_device__manipulated__identifier__assigner__identifier__type { relationship: one_to_many sql: LEFT JOIN UNNEST([${procedure__focal_device__manipulated__identifier__assigner__identifier.type}]) as procedure__focal_device__manipulated__identifier__assigner__identifier__type ;; }
  join: procedure__focal_device__manipulated__identifier__assigner__identifier__type__coding { relationship: one_to_many sql: LEFT JOIN UNNEST(${procedure__focal_device__manipulated__identifier__assigner__identifier__type.coding}) as procedure__focal_device__manipulated__identifier__assigner__identifier__type__coding ;; }
  join: procedure__focal_device__manipulated__identifier__type__coding { relationship: one_to_many sql: LEFT JOIN UNNEST(${procedure__focal_device__manipulated__identifier__type.coding}) as procedure__focal_device__manipulated__identifier__type__coding ;; }
  join: procedure__follow_up { relationship: one_to_many sql: LEFT JOIN UNNEST(${procedure.follow_up}) as procedure__follow_up ;; }
  join: procedure__follow_up__coding { relationship: one_to_many sql: LEFT JOIN UNNEST(${procedure__follow_up.coding}) as procedure__follow_up__coding ;; }
  join: procedure__identifier { relationship: one_to_many sql: LEFT JOIN UNNEST(${procedure.identifier}) as procedure__identifier ;; }
  join: procedure__identifier__assigner { relationship: one_to_many sql: LEFT JOIN UNNEST([${procedure__identifier.assigner}]) as procedure__identifier__assigner ;; }
  join: procedure__identifier__period { relationship: one_to_many sql: LEFT JOIN UNNEST([${procedure__identifier.period}]) as procedure__identifier__period ;; }
  join: procedure__identifier__type { relationship: one_to_many sql: LEFT JOIN UNNEST([${procedure__identifier.type}]) as procedure__identifier__type ;; }
  join: procedure__identifier__assigner__identifier { relationship: one_to_many sql: LEFT JOIN UNNEST([${procedure__identifier__assigner.identifier}]) as procedure__identifier__assigner__identifier ;; }
  join: procedure__identifier__assigner__identifier__assigner { relationship: one_to_many sql: LEFT JOIN UNNEST([${procedure__identifier__assigner__identifier.assigner}]) as procedure__identifier__assigner__identifier__assigner ;; }
  join: procedure__identifier__assigner__identifier__period { relationship: one_to_many sql: LEFT JOIN UNNEST([${procedure__identifier__assigner__identifier.period}]) as procedure__identifier__assigner__identifier__period ;; }
  join: procedure__identifier__assigner__identifier__type { relationship: one_to_many sql: LEFT JOIN UNNEST([${procedure__identifier__assigner__identifier.type}]) as procedure__identifier__assigner__identifier__type ;; }
  join: procedure__identifier__assigner__identifier__type__coding { relationship: one_to_many sql: LEFT JOIN UNNEST(${procedure__identifier__assigner__identifier__type.coding}) as procedure__identifier__assigner__identifier__type__coding ;; }
  join: procedure__identifier__type__coding { relationship: one_to_many sql: LEFT JOIN UNNEST(${procedure__identifier__type.coding}) as procedure__identifier__type__coding ;; }
  join: procedure__location { relationship: one_to_many sql: LEFT JOIN UNNEST([${procedure.location}]) as procedure__location ;; }
  join: procedure__location__identifier { relationship: one_to_many sql: LEFT JOIN UNNEST([${procedure__location.identifier}]) as procedure__location__identifier ;; }
  join: procedure__location__identifier__assigner { relationship: one_to_many sql: LEFT JOIN UNNEST([${procedure__location__identifier.assigner}]) as procedure__location__identifier__assigner ;; }
  join: procedure__location__identifier__period { relationship: one_to_many sql: LEFT JOIN UNNEST([${procedure__location__identifier.period}]) as procedure__location__identifier__period ;; }
  join: procedure__location__identifier__type { relationship: one_to_many sql: LEFT JOIN UNNEST([${procedure__location__identifier.type}]) as procedure__location__identifier__type ;; }
  join: procedure__location__identifier__assigner__identifier { relationship: one_to_many sql: LEFT JOIN UNNEST([${procedure__location__identifier__assigner.identifier}]) as procedure__location__identifier__assigner__identifier ;; }
  join: procedure__location__identifier__assigner__identifier__assigner { relationship: one_to_many sql: LEFT JOIN UNNEST([${procedure__location__identifier__assigner__identifier.assigner}]) as procedure__location__identifier__assigner__identifier__assigner ;; }
  join: procedure__location__identifier__assigner__identifier__period { relationship: one_to_many sql: LEFT JOIN UNNEST([${procedure__location__identifier__assigner__identifier.period}]) as procedure__location__identifier__assigner__identifier__period ;; }
  join: procedure__location__identifier__assigner__identifier__type { relationship: one_to_many sql: LEFT JOIN UNNEST([${procedure__location__identifier__assigner__identifier.type}]) as procedure__location__identifier__assigner__identifier__type ;; }
  join: procedure__location__identifier__assigner__identifier__type__coding { relationship: one_to_many sql: LEFT JOIN UNNEST(${procedure__location__identifier__assigner__identifier__type.coding}) as procedure__location__identifier__assigner__identifier__type__coding ;; }
  join: procedure__location__identifier__type__coding { relationship: one_to_many sql: LEFT JOIN UNNEST(${procedure__location__identifier__type.coding}) as procedure__location__identifier__type__coding ;; }
  join: procedure__meta { relationship: one_to_many sql: LEFT JOIN UNNEST([${procedure.meta}]) as procedure__meta ;; }
  join: procedure__meta__security { relationship: one_to_many sql: LEFT JOIN UNNEST(${procedure__meta.security}) as procedure__meta__security ;; }
  join: procedure__meta__tag { relationship: one_to_many sql: LEFT JOIN UNNEST(${procedure__meta.tag}) as procedure__meta__tag ;; }
  join: procedure__not_done_reason { relationship: one_to_many sql: LEFT JOIN UNNEST([${procedure.not_done_reason}]) as procedure__not_done_reason ;; }
  join: procedure__not_done_reason__coding { relationship: one_to_many sql: LEFT JOIN UNNEST(${procedure__not_done_reason.coding}) as procedure__not_done_reason__coding ;; }
  join: procedure__note { relationship: one_to_many sql: LEFT JOIN UNNEST(${procedure.note}) as procedure__note ;; }
  join: procedure__note__author { relationship: one_to_many sql: LEFT JOIN UNNEST([${procedure__note.author}]) as procedure__note__author ;; }
  join: procedure__note__author__reference { relationship: one_to_many sql: LEFT JOIN UNNEST([${procedure__note__author.reference}]) as procedure__note__author__reference ;; }
  join: procedure__note__author__reference__identifier { relationship: one_to_many sql: LEFT JOIN UNNEST([${procedure__note__author__reference.identifier}]) as procedure__note__author__reference__identifier ;; }
  join: procedure__note__author__reference__identifier__assigner { relationship: one_to_many sql: LEFT JOIN UNNEST([${procedure__note__author__reference__identifier.assigner}]) as procedure__note__author__reference__identifier__assigner ;; }
  join: procedure__note__author__reference__identifier__period { relationship: one_to_many sql: LEFT JOIN UNNEST([${procedure__note__author__reference__identifier.period}]) as procedure__note__author__reference__identifier__period ;; }
  join: procedure__note__author__reference__identifier__type { relationship: one_to_many sql: LEFT JOIN UNNEST([${procedure__note__author__reference__identifier.type}]) as procedure__note__author__reference__identifier__type ;; }
  join: procedure__note__author__reference__identifier__assigner__identifier { relationship: one_to_many sql: LEFT JOIN UNNEST([${procedure__note__author__reference__identifier__assigner.identifier}]) as procedure__note__author__reference__identifier__assigner__identifier ;; }
  join: procedure__note__author__reference__identifier__assigner__identifier__assigner { relationship: one_to_many sql: LEFT JOIN UNNEST([${procedure__note__author__reference__identifier__assigner__identifier.assigner}]) as procedure__note__author__reference__identifier__assigner__identifier__assigner ;; }
  join: procedure__note__author__reference__identifier__assigner__identifier__period { relationship: one_to_many sql: LEFT JOIN UNNEST([${procedure__note__author__reference__identifier__assigner__identifier.period}]) as procedure__note__author__reference__identifier__assigner__identifier__period ;; }
  join: procedure__note__author__reference__identifier__assigner__identifier__type { relationship: one_to_many sql: LEFT JOIN UNNEST([${procedure__note__author__reference__identifier__assigner__identifier.type}]) as procedure__note__author__reference__identifier__assigner__identifier__type ;; }
  join: procedure__note__author__reference__identifier__assigner__identifier__type__coding { relationship: one_to_many sql: LEFT JOIN UNNEST(${procedure__note__author__reference__identifier__assigner__identifier__type.coding}) as procedure__note__author__reference__identifier__assigner__identifier__type__coding ;; }
  join: procedure__note__author__reference__identifier__type__coding { relationship: one_to_many sql: LEFT JOIN UNNEST(${procedure__note__author__reference__identifier__type.coding}) as procedure__note__author__reference__identifier__type__coding ;; }
  join: procedure__outcome { relationship: one_to_many sql: LEFT JOIN UNNEST([${procedure.outcome}]) as procedure__outcome ;; }
  join: procedure__outcome__coding { relationship: one_to_many sql: LEFT JOIN UNNEST(${procedure__outcome.coding}) as procedure__outcome__coding ;; }
  join: procedure__part_of { relationship: one_to_many sql: LEFT JOIN UNNEST(${procedure.part_of}) as procedure__part_of ;; }
  join: procedure__part_of__identifier { relationship: one_to_many sql: LEFT JOIN UNNEST([${procedure__part_of.identifier}]) as procedure__part_of__identifier ;; }
  join: procedure__part_of__identifier__assigner { relationship: one_to_many sql: LEFT JOIN UNNEST([${procedure__part_of__identifier.assigner}]) as procedure__part_of__identifier__assigner ;; }
  join: procedure__part_of__identifier__period { relationship: one_to_many sql: LEFT JOIN UNNEST([${procedure__part_of__identifier.period}]) as procedure__part_of__identifier__period ;; }
  join: procedure__part_of__identifier__type { relationship: one_to_many sql: LEFT JOIN UNNEST([${procedure__part_of__identifier.type}]) as procedure__part_of__identifier__type ;; }
  join: procedure__part_of__identifier__assigner__identifier { relationship: one_to_many sql: LEFT JOIN UNNEST([${procedure__part_of__identifier__assigner.identifier}]) as procedure__part_of__identifier__assigner__identifier ;; }
  join: procedure__part_of__identifier__assigner__identifier__assigner { relationship: one_to_many sql: LEFT JOIN UNNEST([${procedure__part_of__identifier__assigner__identifier.assigner}]) as procedure__part_of__identifier__assigner__identifier__assigner ;; }
  join: procedure__part_of__identifier__assigner__identifier__period { relationship: one_to_many sql: LEFT JOIN UNNEST([${procedure__part_of__identifier__assigner__identifier.period}]) as procedure__part_of__identifier__assigner__identifier__period ;; }
  join: procedure__part_of__identifier__assigner__identifier__type { relationship: one_to_many sql: LEFT JOIN UNNEST([${procedure__part_of__identifier__assigner__identifier.type}]) as procedure__part_of__identifier__assigner__identifier__type ;; }
  join: procedure__part_of__identifier__assigner__identifier__type__coding { relationship: one_to_many sql: LEFT JOIN UNNEST(${procedure__part_of__identifier__assigner__identifier__type.coding}) as procedure__part_of__identifier__assigner__identifier__type__coding ;; }
  join: procedure__part_of__identifier__type__coding { relationship: one_to_many sql: LEFT JOIN UNNEST(${procedure__part_of__identifier__type.coding}) as procedure__part_of__identifier__type__coding ;; }
  join: procedure__performed { relationship: one_to_many sql: LEFT JOIN UNNEST([${procedure.performed}]) as procedure__performed ;; }
  join: procedure__performed__period { relationship: one_to_many sql: LEFT JOIN UNNEST([${procedure__performed.period}]) as procedure__performed__period ;; }
  join: procedure__performer { relationship: one_to_many sql: LEFT JOIN UNNEST(${procedure.performer}) as procedure__performer ;; }
  join: procedure__performer__actor { relationship: one_to_many sql: LEFT JOIN UNNEST([${procedure__performer.actor}]) as procedure__performer__actor ;; }
  join: procedure__performer__on_behalf_of { relationship: one_to_many sql: LEFT JOIN UNNEST([${procedure__performer.on_behalf_of}]) as procedure__performer__on_behalf_of ;; }
  join: procedure__performer__role { relationship: one_to_many sql: LEFT JOIN UNNEST([${procedure__performer.role}]) as procedure__performer__role ;; }
  join: procedure__performer__actor__identifier { relationship: one_to_many sql: LEFT JOIN UNNEST([${procedure__performer__actor.identifier}]) as procedure__performer__actor__identifier ;; }
  join: procedure__performer__actor__identifier__assigner { relationship: one_to_many sql: LEFT JOIN UNNEST([${procedure__performer__actor__identifier.assigner}]) as procedure__performer__actor__identifier__assigner ;; }
  join: procedure__performer__actor__identifier__period { relationship: one_to_many sql: LEFT JOIN UNNEST([${procedure__performer__actor__identifier.period}]) as procedure__performer__actor__identifier__period ;; }
  join: procedure__performer__actor__identifier__type { relationship: one_to_many sql: LEFT JOIN UNNEST([${procedure__performer__actor__identifier.type}]) as procedure__performer__actor__identifier__type ;; }
  join: procedure__performer__actor__identifier__assigner__identifier { relationship: one_to_many sql: LEFT JOIN UNNEST([${procedure__performer__actor__identifier__assigner.identifier}]) as procedure__performer__actor__identifier__assigner__identifier ;; }
  join: procedure__performer__actor__identifier__assigner__identifier__assigner { relationship: one_to_many sql: LEFT JOIN UNNEST([${procedure__performer__actor__identifier__assigner__identifier.assigner}]) as procedure__performer__actor__identifier__assigner__identifier__assigner ;; }
  join: procedure__performer__actor__identifier__assigner__identifier__period { relationship: one_to_many sql: LEFT JOIN UNNEST([${procedure__performer__actor__identifier__assigner__identifier.period}]) as procedure__performer__actor__identifier__assigner__identifier__period ;; }
  join: procedure__performer__actor__identifier__assigner__identifier__type { relationship: one_to_many sql: LEFT JOIN UNNEST([${procedure__performer__actor__identifier__assigner__identifier.type}]) as procedure__performer__actor__identifier__assigner__identifier__type ;; }
  join: procedure__performer__actor__identifier__assigner__identifier__type__coding { relationship: one_to_many sql: LEFT JOIN UNNEST(${procedure__performer__actor__identifier__assigner__identifier__type.coding}) as procedure__performer__actor__identifier__assigner__identifier__type__coding ;; }
  join: procedure__performer__actor__identifier__type__coding { relationship: one_to_many sql: LEFT JOIN UNNEST(${procedure__performer__actor__identifier__type.coding}) as procedure__performer__actor__identifier__type__coding ;; }
  join: procedure__performer__on_behalf_of__identifier { relationship: one_to_many sql: LEFT JOIN UNNEST([${procedure__performer__on_behalf_of.identifier}]) as procedure__performer__on_behalf_of__identifier ;; }
  join: procedure__performer__on_behalf_of__identifier__assigner { relationship: one_to_many sql: LEFT JOIN UNNEST([${procedure__performer__on_behalf_of__identifier.assigner}]) as procedure__performer__on_behalf_of__identifier__assigner ;; }
  join: procedure__performer__on_behalf_of__identifier__period { relationship: one_to_many sql: LEFT JOIN UNNEST([${procedure__performer__on_behalf_of__identifier.period}]) as procedure__performer__on_behalf_of__identifier__period ;; }
  join: procedure__performer__on_behalf_of__identifier__type { relationship: one_to_many sql: LEFT JOIN UNNEST([${procedure__performer__on_behalf_of__identifier.type}]) as procedure__performer__on_behalf_of__identifier__type ;; }
  join: procedure__performer__on_behalf_of__identifier__assigner__identifier { relationship: one_to_many sql: LEFT JOIN UNNEST([${procedure__performer__on_behalf_of__identifier__assigner.identifier}]) as procedure__performer__on_behalf_of__identifier__assigner__identifier ;; }
  join: procedure__performer__on_behalf_of__identifier__assigner__identifier__assigner { relationship: one_to_many sql: LEFT JOIN UNNEST([${procedure__performer__on_behalf_of__identifier__assigner__identifier.assigner}]) as procedure__performer__on_behalf_of__identifier__assigner__identifier__assigner ;; }
  join: procedure__performer__on_behalf_of__identifier__assigner__identifier__period { relationship: one_to_many sql: LEFT JOIN UNNEST([${procedure__performer__on_behalf_of__identifier__assigner__identifier.period}]) as procedure__performer__on_behalf_of__identifier__assigner__identifier__period ;; }
  join: procedure__performer__on_behalf_of__identifier__assigner__identifier__type { relationship: one_to_many sql: LEFT JOIN UNNEST([${procedure__performer__on_behalf_of__identifier__assigner__identifier.type}]) as procedure__performer__on_behalf_of__identifier__assigner__identifier__type ;; }
  join: procedure__performer__on_behalf_of__identifier__assigner__identifier__type__coding { relationship: one_to_many sql: LEFT JOIN UNNEST(${procedure__performer__on_behalf_of__identifier__assigner__identifier__type.coding}) as procedure__performer__on_behalf_of__identifier__assigner__identifier__type__coding ;; }
  join: procedure__performer__on_behalf_of__identifier__type__coding { relationship: one_to_many sql: LEFT JOIN UNNEST(${procedure__performer__on_behalf_of__identifier__type.coding}) as procedure__performer__on_behalf_of__identifier__type__coding ;; }
  join: procedure__performer__role__coding { relationship: one_to_many sql: LEFT JOIN UNNEST(${procedure__performer__role.coding}) as procedure__performer__role__coding ;; }
  join: procedure__reason_code { relationship: one_to_many sql: LEFT JOIN UNNEST(${procedure.reason_code}) as procedure__reason_code ;; }
  join: procedure__reason_code__coding { relationship: one_to_many sql: LEFT JOIN UNNEST(${procedure__reason_code.coding}) as procedure__reason_code__coding ;; }
  join: procedure__reason_reference { relationship: one_to_many sql: LEFT JOIN UNNEST(${procedure.reason_reference}) as procedure__reason_reference ;; }
  join: procedure__reason_reference__identifier { relationship: one_to_many sql: LEFT JOIN UNNEST([${procedure__reason_reference.identifier}]) as procedure__reason_reference__identifier ;; }
  join: procedure__reason_reference__identifier__assigner { relationship: one_to_many sql: LEFT JOIN UNNEST([${procedure__reason_reference__identifier.assigner}]) as procedure__reason_reference__identifier__assigner ;; }
  join: procedure__reason_reference__identifier__period { relationship: one_to_many sql: LEFT JOIN UNNEST([${procedure__reason_reference__identifier.period}]) as procedure__reason_reference__identifier__period ;; }
  join: procedure__reason_reference__identifier__type { relationship: one_to_many sql: LEFT JOIN UNNEST([${procedure__reason_reference__identifier.type}]) as procedure__reason_reference__identifier__type ;; }
  join: procedure__reason_reference__identifier__assigner__identifier { relationship: one_to_many sql: LEFT JOIN UNNEST([${procedure__reason_reference__identifier__assigner.identifier}]) as procedure__reason_reference__identifier__assigner__identifier ;; }
  join: procedure__reason_reference__identifier__assigner__identifier__assigner { relationship: one_to_many sql: LEFT JOIN UNNEST([${procedure__reason_reference__identifier__assigner__identifier.assigner}]) as procedure__reason_reference__identifier__assigner__identifier__assigner ;; }
  join: procedure__reason_reference__identifier__assigner__identifier__period { relationship: one_to_many sql: LEFT JOIN UNNEST([${procedure__reason_reference__identifier__assigner__identifier.period}]) as procedure__reason_reference__identifier__assigner__identifier__period ;; }
  join: procedure__reason_reference__identifier__assigner__identifier__type { relationship: one_to_many sql: LEFT JOIN UNNEST([${procedure__reason_reference__identifier__assigner__identifier.type}]) as procedure__reason_reference__identifier__assigner__identifier__type ;; }
  join: procedure__reason_reference__identifier__assigner__identifier__type__coding { relationship: one_to_many sql: LEFT JOIN UNNEST(${procedure__reason_reference__identifier__assigner__identifier__type.coding}) as procedure__reason_reference__identifier__assigner__identifier__type__coding ;; }
  join: procedure__reason_reference__identifier__type__coding { relationship: one_to_many sql: LEFT JOIN UNNEST(${procedure__reason_reference__identifier__type.coding}) as procedure__reason_reference__identifier__type__coding ;; }
  join: procedure__report { relationship: one_to_many sql: LEFT JOIN UNNEST(${procedure.report}) as procedure__report ;; }
  join: procedure__report__identifier { relationship: one_to_many sql: LEFT JOIN UNNEST([${procedure__report.identifier}]) as procedure__report__identifier ;; }
  join: procedure__report__identifier__assigner { relationship: one_to_many sql: LEFT JOIN UNNEST([${procedure__report__identifier.assigner}]) as procedure__report__identifier__assigner ;; }
  join: procedure__report__identifier__period { relationship: one_to_many sql: LEFT JOIN UNNEST([${procedure__report__identifier.period}]) as procedure__report__identifier__period ;; }
  join: procedure__report__identifier__type { relationship: one_to_many sql: LEFT JOIN UNNEST([${procedure__report__identifier.type}]) as procedure__report__identifier__type ;; }
  join: procedure__report__identifier__assigner__identifier { relationship: one_to_many sql: LEFT JOIN UNNEST([${procedure__report__identifier__assigner.identifier}]) as procedure__report__identifier__assigner__identifier ;; }
  join: procedure__report__identifier__assigner__identifier__assigner { relationship: one_to_many sql: LEFT JOIN UNNEST([${procedure__report__identifier__assigner__identifier.assigner}]) as procedure__report__identifier__assigner__identifier__assigner ;; }
  join: procedure__report__identifier__assigner__identifier__period { relationship: one_to_many sql: LEFT JOIN UNNEST([${procedure__report__identifier__assigner__identifier.period}]) as procedure__report__identifier__assigner__identifier__period ;; }
  join: procedure__report__identifier__assigner__identifier__type { relationship: one_to_many sql: LEFT JOIN UNNEST([${procedure__report__identifier__assigner__identifier.type}]) as procedure__report__identifier__assigner__identifier__type ;; }
  join: procedure__report__identifier__assigner__identifier__type__coding { relationship: one_to_many sql: LEFT JOIN UNNEST(${procedure__report__identifier__assigner__identifier__type.coding}) as procedure__report__identifier__assigner__identifier__type__coding ;; }
  join: procedure__report__identifier__type__coding { relationship: one_to_many sql: LEFT JOIN UNNEST(${procedure__report__identifier__type.coding}) as procedure__report__identifier__type__coding ;; }
  join: procedure__shr_action_performed_context_extension { relationship: one_to_many sql: LEFT JOIN UNNEST([${procedure.shr_action_performed_context_extension}]) as procedure__shr_action_performed_context_extension ;; }
  join: procedure__shr_action_performed_context_extension__shr_action_status_extension { relationship: one_to_many sql: LEFT JOIN UNNEST([${procedure__shr_action_performed_context_extension.shr_action_status_extension}]) as procedure__shr_action_performed_context_extension__shr_action_status_extension ;; }
  join: procedure__shr_action_performed_context_extension__shr_action_status_extension__value { relationship: one_to_many sql: LEFT JOIN UNNEST([${procedure__shr_action_performed_context_extension__shr_action_status_extension.value}]) as procedure__shr_action_performed_context_extension__shr_action_status_extension__value ;; }
  join: procedure__subject { relationship: one_to_many sql: LEFT JOIN UNNEST([${procedure.subject}]) as procedure__subject ;; }
  join: procedure__subject__identifier { relationship: one_to_many sql: LEFT JOIN UNNEST([${procedure__subject.identifier}]) as procedure__subject__identifier ;; }
  join: procedure__subject__identifier__assigner { relationship: one_to_many sql: LEFT JOIN UNNEST([${procedure__subject__identifier.assigner}]) as procedure__subject__identifier__assigner ;; }
  join: procedure__subject__identifier__period { relationship: one_to_many sql: LEFT JOIN UNNEST([${procedure__subject__identifier.period}]) as procedure__subject__identifier__period ;; }
  join: procedure__subject__identifier__type { relationship: one_to_many sql: LEFT JOIN UNNEST([${procedure__subject__identifier.type}]) as procedure__subject__identifier__type ;; }
  join: procedure__subject__identifier__assigner__identifier { relationship: one_to_many sql: LEFT JOIN UNNEST([${procedure__subject__identifier__assigner.identifier}]) as procedure__subject__identifier__assigner__identifier ;; }
  join: procedure__subject__identifier__assigner__identifier__assigner { relationship: one_to_many sql: LEFT JOIN UNNEST([${procedure__subject__identifier__assigner__identifier.assigner}]) as procedure__subject__identifier__assigner__identifier__assigner ;; }
  join: procedure__subject__identifier__assigner__identifier__period { relationship: one_to_many sql: LEFT JOIN UNNEST([${procedure__subject__identifier__assigner__identifier.period}]) as procedure__subject__identifier__assigner__identifier__period ;; }
  join: procedure__subject__identifier__assigner__identifier__type { relationship: one_to_many sql: LEFT JOIN UNNEST([${procedure__subject__identifier__assigner__identifier.type}]) as procedure__subject__identifier__assigner__identifier__type ;; }
  join: procedure__subject__identifier__assigner__identifier__type__coding { relationship: one_to_many sql: LEFT JOIN UNNEST(${procedure__subject__identifier__assigner__identifier__type.coding}) as procedure__subject__identifier__assigner__identifier__type__coding ;; }
  join: procedure__subject__identifier__type__coding { relationship: one_to_many sql: LEFT JOIN UNNEST(${procedure__subject__identifier__type.coding}) as procedure__subject__identifier__type__coding ;; }
  join: procedure__text { relationship: one_to_many sql: LEFT JOIN UNNEST([${procedure.text}]) as procedure__text ;; }
  join: procedure__used_code { relationship: one_to_many sql: LEFT JOIN UNNEST(${procedure.used_code}) as procedure__used_code ;; }
  join: procedure__used_code__coding { relationship: one_to_many sql: LEFT JOIN UNNEST(${procedure__used_code.coding}) as procedure__used_code__coding ;; }
  join: procedure__used_reference { relationship: one_to_many sql: LEFT JOIN UNNEST(${procedure.used_reference}) as procedure__used_reference ;; }
  join: procedure__used_reference__identifier { relationship: one_to_many sql: LEFT JOIN UNNEST([${procedure__used_reference.identifier}]) as procedure__used_reference__identifier ;; }
  join: procedure__used_reference__identifier__assigner { relationship: one_to_many sql: LEFT JOIN UNNEST([${procedure__used_reference__identifier.assigner}]) as procedure__used_reference__identifier__assigner ;; }
  join: procedure__used_reference__identifier__period { relationship: one_to_many sql: LEFT JOIN UNNEST([${procedure__used_reference__identifier.period}]) as procedure__used_reference__identifier__period ;; }
  join: procedure__used_reference__identifier__type { relationship: one_to_many sql: LEFT JOIN UNNEST([${procedure__used_reference__identifier.type}]) as procedure__used_reference__identifier__type ;; }
  join: procedure__used_reference__identifier__assigner__identifier { relationship: one_to_many sql: LEFT JOIN UNNEST([${procedure__used_reference__identifier__assigner.identifier}]) as procedure__used_reference__identifier__assigner__identifier ;; }
  join: procedure__used_reference__identifier__assigner__identifier__assigner { relationship: one_to_many sql: LEFT JOIN UNNEST([${procedure__used_reference__identifier__assigner__identifier.assigner}]) as procedure__used_reference__identifier__assigner__identifier__assigner ;; }
  join: procedure__used_reference__identifier__assigner__identifier__period { relationship: one_to_many sql: LEFT JOIN UNNEST([${procedure__used_reference__identifier__assigner__identifier.period}]) as procedure__used_reference__identifier__assigner__identifier__period ;; }
  join: procedure__used_reference__identifier__assigner__identifier__type { relationship: one_to_many sql: LEFT JOIN UNNEST([${procedure__used_reference__identifier__assigner__identifier.type}]) as procedure__used_reference__identifier__assigner__identifier__type ;; }
  join: procedure__used_reference__identifier__assigner__identifier__type__coding { relationship: one_to_many sql: LEFT JOIN UNNEST(${procedure__used_reference__identifier__assigner__identifier__type.coding}) as procedure__used_reference__identifier__assigner__identifier__type__coding ;; }
  join: procedure__used_reference__identifier__type__coding { relationship: one_to_many sql: LEFT JOIN UNNEST(${procedure__used_reference__identifier__type.coding}) as procedure__used_reference__identifier__type__coding ;; }
}


#### Caching Logic ####

persist_with: once_weekly

### PDT Timeframes

datagroup: once_daily {
  max_cache_age: "24 hours"
  sql_trigger: SELECT current_date() ;;
}

datagroup: once_weekly {
  max_cache_age: "168 hours"
  sql_trigger: SELECT extract(week from current_date()) ;;
}

datagroup: once_monthly {
  max_cache_age: "720 hours"
  sql_trigger: SELECT extract(month from current_date()) ;;
}

datagroup: once_yearly {
  max_cache_age: "9000 hours"
  sql_trigger: SELECT extract(year from current_date()) ;;
}

#### Additional Base Tables ####

# join: account__active { relationship: many_to_one sql: LEFT JOIN UNNEST([${account.active}]) as account__active ;; }
# join: account__balance { relationship: many_to_one sql: LEFT JOIN UNNEST([${account.balance}]) as account__balance ;; }
# join: account__coverage { relationship: many_to_one sql: LEFT JOIN UNNEST(${account.coverage}) as account__coverage ;; }
# join: account__coverage__coverage { relationship: many_to_one sql: LEFT JOIN UNNEST([${account__coverage.coverage}]) as account__coverage__coverage ;; }
# join: account__coverage__coverage__identifier { relationship: many_to_one sql: LEFT JOIN UNNEST([${account__coverage__coverage.identifier}]) as account__coverage__coverage__identifier ;; }
# join: account__coverage__coverage__identifier__assigner { relationship: many_to_one sql: LEFT JOIN UNNEST([${account__coverage__coverage__identifier.assigner}]) as account__coverage__coverage__identifier__assigner ;; }
# join: account__coverage__coverage__identifier__period { relationship: many_to_one sql: LEFT JOIN UNNEST([${account__coverage__coverage__identifier.period}]) as account__coverage__coverage__identifier__period ;; }
# join: account__coverage__coverage__identifier__type { relationship: many_to_one sql: LEFT JOIN UNNEST([${account__coverage__coverage__identifier.type}]) as account__coverage__coverage__identifier__type ;; }
# join: account__coverage__coverage__identifier__assigner__identifier { relationship: many_to_one sql: LEFT JOIN UNNEST([${account__coverage__coverage__identifier__assigner.identifier}]) as account__coverage__coverage__identifier__assigner__identifier ;; }
# join: account__coverage__coverage__identifier__assigner__identifier__assigner { relationship: many_to_one sql: LEFT JOIN UNNEST([${account__coverage__coverage__identifier__assigner__identifier.assigner}]) as account__coverage__coverage__identifier__assigner__identifier__assigner ;; }
# join: account__coverage__coverage__identifier__assigner__identifier__period { relationship: many_to_one sql: LEFT JOIN UNNEST([${account__coverage__coverage__identifier__assigner__identifier.period}]) as account__coverage__coverage__identifier__assigner__identifier__period ;; }
# join: account__coverage__coverage__identifier__assigner__identifier__type { relationship: many_to_one sql: LEFT JOIN UNNEST([${account__coverage__coverage__identifier__assigner__identifier.type}]) as account__coverage__coverage__identifier__assigner__identifier__type ;; }
# join: account__coverage__coverage__identifier__assigner__identifier__type__coding { relationship: many_to_one sql: LEFT JOIN UNNEST(${account__coverage__coverage__identifier__assigner__identifier__type.coding}) as account__coverage__coverage__identifier__assigner__identifier__type__coding ;; }
# join: account__coverage__coverage__identifier__type__coding { relationship: many_to_one sql: LEFT JOIN UNNEST(${account__coverage__coverage__identifier__type.coding}) as account__coverage__coverage__identifier__type__coding ;; }
# join: account__guarantor { relationship: many_to_one sql: LEFT JOIN UNNEST(${account.guarantor}) as account__guarantor ;; }
# join: account__guarantor__party { relationship: many_to_one sql: LEFT JOIN UNNEST([${account__guarantor.party}]) as account__guarantor__party ;; }
# join: account__guarantor__period { relationship: many_to_one sql: LEFT JOIN UNNEST([${account__guarantor.period}]) as account__guarantor__period ;; }
# join: account__guarantor__party__identifier { relationship: many_to_one sql: LEFT JOIN UNNEST([${account__guarantor__party.identifier}]) as account__guarantor__party__identifier ;; }
# join: account__guarantor__party__identifier__assigner { relationship: many_to_one sql: LEFT JOIN UNNEST([${account__guarantor__party__identifier.assigner}]) as account__guarantor__party__identifier__assigner ;; }
# join: account__guarantor__party__identifier__period { relationship: many_to_one sql: LEFT JOIN UNNEST([${account__guarantor__party__identifier.period}]) as account__guarantor__party__identifier__period ;; }
# join: account__guarantor__party__identifier__type { relationship: many_to_one sql: LEFT JOIN UNNEST([${account__guarantor__party__identifier.type}]) as account__guarantor__party__identifier__type ;; }
# join: account__guarantor__party__identifier__assigner__identifier { relationship: many_to_one sql: LEFT JOIN UNNEST([${account__guarantor__party__identifier__assigner.identifier}]) as account__guarantor__party__identifier__assigner__identifier ;; }
# join: account__guarantor__party__identifier__assigner__identifier__assigner { relationship: many_to_one sql: LEFT JOIN UNNEST([${account__guarantor__party__identifier__assigner__identifier.assigner}]) as account__guarantor__party__identifier__assigner__identifier__assigner ;; }
# join: account__guarantor__party__identifier__assigner__identifier__period { relationship: many_to_one sql: LEFT JOIN UNNEST([${account__guarantor__party__identifier__assigner__identifier.period}]) as account__guarantor__party__identifier__assigner__identifier__period ;; }
# join: account__guarantor__party__identifier__assigner__identifier__type { relationship: many_to_one sql: LEFT JOIN UNNEST([${account__guarantor__party__identifier__assigner__identifier.type}]) as account__guarantor__party__identifier__assigner__identifier__type ;; }
# join: account__guarantor__party__identifier__assigner__identifier__type__coding { relationship: many_to_one sql: LEFT JOIN UNNEST(${account__guarantor__party__identifier__assigner__identifier__type.coding}) as account__guarantor__party__identifier__assigner__identifier__type__coding ;; }
# join: account__guarantor__party__identifier__type__coding { relationship: many_to_one sql: LEFT JOIN UNNEST(${account__guarantor__party__identifier__type.coding}) as account__guarantor__party__identifier__type__coding ;; }
# join: account__identifier { relationship: many_to_one sql: LEFT JOIN UNNEST(${account.identifier}) as account__identifier ;; }
# join: account__identifier__assigner { relationship: many_to_one sql: LEFT JOIN UNNEST([${account__identifier.assigner}]) as account__identifier__assigner ;; }
# join: account__identifier__period { relationship: many_to_one sql: LEFT JOIN UNNEST([${account__identifier.period}]) as account__identifier__period ;; }
# join: account__identifier__type { relationship: many_to_one sql: LEFT JOIN UNNEST([${account__identifier.type}]) as account__identifier__type ;; }
# join: account__identifier__assigner__identifier { relationship: many_to_one sql: LEFT JOIN UNNEST([${account__identifier__assigner.identifier}]) as account__identifier__assigner__identifier ;; }
# join: account__identifier__assigner__identifier__assigner { relationship: many_to_one sql: LEFT JOIN UNNEST([${account__identifier__assigner__identifier.assigner}]) as account__identifier__assigner__identifier__assigner ;; }
# join: account__identifier__assigner__identifier__period { relationship: many_to_one sql: LEFT JOIN UNNEST([${account__identifier__assigner__identifier.period}]) as account__identifier__assigner__identifier__period ;; }
# join: account__identifier__assigner__identifier__type { relationship: many_to_one sql: LEFT JOIN UNNEST([${account__identifier__assigner__identifier.type}]) as account__identifier__assigner__identifier__type ;; }
# join: account__identifier__assigner__identifier__type__coding { relationship: many_to_one sql: LEFT JOIN UNNEST(${account__identifier__assigner__identifier__type.coding}) as account__identifier__assigner__identifier__type__coding ;; }
# join: account__identifier__type__coding { relationship: many_to_one sql: LEFT JOIN UNNEST(${account__identifier__type.coding}) as account__identifier__type__coding ;; }
# join: account__meta { relationship: many_to_one sql: LEFT JOIN UNNEST([${account.meta}]) as account__meta ;; }
# join: account__meta__security { relationship: many_to_one sql: LEFT JOIN UNNEST(${account__meta.security}) as account__meta__security ;; }
# join: account__meta__tag { relationship: many_to_one sql: LEFT JOIN UNNEST(${account__meta.tag}) as account__meta__tag ;; }
# join: account__owner { relationship: many_to_one sql: LEFT JOIN UNNEST([${account.owner}]) as account__owner ;; }
# join: account__owner__identifier { relationship: many_to_one sql: LEFT JOIN UNNEST([${account__owner.identifier}]) as account__owner__identifier ;; }
# join: account__owner__identifier__assigner { relationship: many_to_one sql: LEFT JOIN UNNEST([${account__owner__identifier.assigner}]) as account__owner__identifier__assigner ;; }
# join: account__owner__identifier__period { relationship: many_to_one sql: LEFT JOIN UNNEST([${account__owner__identifier.period}]) as account__owner__identifier__period ;; }
# join: account__owner__identifier__type { relationship: many_to_one sql: LEFT JOIN UNNEST([${account__owner__identifier.type}]) as account__owner__identifier__type ;; }
# join: account__owner__identifier__assigner__identifier { relationship: many_to_one sql: LEFT JOIN UNNEST([${account__owner__identifier__assigner.identifier}]) as account__owner__identifier__assigner__identifier ;; }
# join: account__owner__identifier__assigner__identifier__assigner { relationship: many_to_one sql: LEFT JOIN UNNEST([${account__owner__identifier__assigner__identifier.assigner}]) as account__owner__identifier__assigner__identifier__assigner ;; }
# join: account__owner__identifier__assigner__identifier__period { relationship: many_to_one sql: LEFT JOIN UNNEST([${account__owner__identifier__assigner__identifier.period}]) as account__owner__identifier__assigner__identifier__period ;; }
# join: account__owner__identifier__assigner__identifier__type { relationship: many_to_one sql: LEFT JOIN UNNEST([${account__owner__identifier__assigner__identifier.type}]) as account__owner__identifier__assigner__identifier__type ;; }
# join: account__owner__identifier__assigner__identifier__type__coding { relationship: many_to_one sql: LEFT JOIN UNNEST(${account__owner__identifier__assigner__identifier__type.coding}) as account__owner__identifier__assigner__identifier__type__coding ;; }
# join: account__owner__identifier__type__coding { relationship: many_to_one sql: LEFT JOIN UNNEST(${account__owner__identifier__type.coding}) as account__owner__identifier__type__coding ;; }
# join: account__period { relationship: many_to_one sql: LEFT JOIN UNNEST([${account.period}]) as account__period ;; }
# join: account__subject { relationship: many_to_one sql: LEFT JOIN UNNEST([${account.subject}]) as account__subject ;; }
# join: account__subject__identifier { relationship: many_to_one sql: LEFT JOIN UNNEST([${account__subject.identifier}]) as account__subject__identifier ;; }
# join: account__subject__identifier__assigner { relationship: many_to_one sql: LEFT JOIN UNNEST([${account__subject__identifier.assigner}]) as account__subject__identifier__assigner ;; }
# join: account__subject__identifier__period { relationship: many_to_one sql: LEFT JOIN UNNEST([${account__subject__identifier.period}]) as account__subject__identifier__period ;; }
# join: account__subject__identifier__type { relationship: many_to_one sql: LEFT JOIN UNNEST([${account__subject__identifier.type}]) as account__subject__identifier__type ;; }
# join: account__subject__identifier__assigner__identifier { relationship: many_to_one sql: LEFT JOIN UNNEST([${account__subject__identifier__assigner.identifier}]) as account__subject__identifier__assigner__identifier ;; }
# join: account__subject__identifier__assigner__identifier__assigner { relationship: many_to_one sql: LEFT JOIN UNNEST([${account__subject__identifier__assigner__identifier.assigner}]) as account__subject__identifier__assigner__identifier__assigner ;; }
# join: account__subject__identifier__assigner__identifier__period { relationship: many_to_one sql: LEFT JOIN UNNEST([${account__subject__identifier__assigner__identifier.period}]) as account__subject__identifier__assigner__identifier__period ;; }
# join: account__subject__identifier__assigner__identifier__type { relationship: many_to_one sql: LEFT JOIN UNNEST([${account__subject__identifier__assigner__identifier.type}]) as account__subject__identifier__assigner__identifier__type ;; }
# join: account__subject__identifier__assigner__identifier__type__coding { relationship: many_to_one sql: LEFT JOIN UNNEST(${account__subject__identifier__assigner__identifier__type.coding}) as account__subject__identifier__assigner__identifier__type__coding ;; }
# join: account__subject__identifier__type__coding { relationship: many_to_one sql: LEFT JOIN UNNEST(${account__subject__identifier__type.coding}) as account__subject__identifier__type__coding ;; }
# join: account__text { relationship: many_to_one sql: LEFT JOIN UNNEST([${account.text}]) as account__text ;; }
# join: account__type { relationship: many_to_one sql: LEFT JOIN UNNEST([${account.type}]) as account__type ;; }
# join: account__type__coding { relationship: many_to_one sql: LEFT JOIN UNNEST(${account__type.coding}) as account__type__coding ;; }

# join: episode_of_care__account { relationship: many_to_one sql: LEFT JOIN UNNEST(${episode_of_care.account}) as episode_of_care__account ;; }
# join: episode_of_care__account__identifier { relationship: many_to_one sql: LEFT JOIN UNNEST([${episode_of_care__account.identifier}]) as episode_of_care__account__identifier ;; }
# join: episode_of_care__account__identifier__assigner { relationship: many_to_one sql: LEFT JOIN UNNEST([${episode_of_care__account__identifier.assigner}]) as episode_of_care__account__identifier__assigner ;; }
# join: episode_of_care__account__identifier__period { relationship: many_to_one sql: LEFT JOIN UNNEST([${episode_of_care__account__identifier.period}]) as episode_of_care__account__identifier__period ;; }
# join: episode_of_care__account__identifier__type { relationship: many_to_one sql: LEFT JOIN UNNEST([${episode_of_care__account__identifier.type}]) as episode_of_care__account__identifier__type ;; }
# join: episode_of_care__account__identifier__assigner__identifier { relationship: many_to_one sql: LEFT JOIN UNNEST([${episode_of_care__account__identifier__assigner.identifier}]) as episode_of_care__account__identifier__assigner__identifier ;; }
# join: episode_of_care__account__identifier__assigner__identifier__assigner { relationship: many_to_one sql: LEFT JOIN UNNEST([${episode_of_care__account__identifier__assigner__identifier.assigner}]) as episode_of_care__account__identifier__assigner__identifier__assigner ;; }
# join: episode_of_care__account__identifier__assigner__identifier__period { relationship: many_to_one sql: LEFT JOIN UNNEST([${episode_of_care__account__identifier__assigner__identifier.period}]) as episode_of_care__account__identifier__assigner__identifier__period ;; }
# join: episode_of_care__account__identifier__assigner__identifier__type { relationship: many_to_one sql: LEFT JOIN UNNEST([${episode_of_care__account__identifier__assigner__identifier.type}]) as episode_of_care__account__identifier__assigner__identifier__type ;; }
# join: episode_of_care__account__identifier__assigner__identifier__type__coding { relationship: many_to_one sql: LEFT JOIN UNNEST(${episode_of_care__account__identifier__assigner__identifier__type.coding}) as episode_of_care__account__identifier__assigner__identifier__type__coding ;; }
# join: episode_of_care__account__identifier__type__coding { relationship: many_to_one sql: LEFT JOIN UNNEST(${episode_of_care__account__identifier__type.coding}) as episode_of_care__account__identifier__type__coding ;; }
# join: episode_of_care__care_manager { relationship: many_to_one sql: LEFT JOIN UNNEST([${episode_of_care.care_manager}]) as episode_of_care__care_manager ;; }
# join: episode_of_care__care_manager__identifier { relationship: many_to_one sql: LEFT JOIN UNNEST([${episode_of_care__care_manager.identifier}]) as episode_of_care__care_manager__identifier ;; }
# join: episode_of_care__care_manager__identifier__assigner { relationship: many_to_one sql: LEFT JOIN UNNEST([${episode_of_care__care_manager__identifier.assigner}]) as episode_of_care__care_manager__identifier__assigner ;; }
# join: episode_of_care__care_manager__identifier__period { relationship: many_to_one sql: LEFT JOIN UNNEST([${episode_of_care__care_manager__identifier.period}]) as episode_of_care__care_manager__identifier__period ;; }
# join: episode_of_care__care_manager__identifier__type { relationship: many_to_one sql: LEFT JOIN UNNEST([${episode_of_care__care_manager__identifier.type}]) as episode_of_care__care_manager__identifier__type ;; }
# join: episode_of_care__care_manager__identifier__assigner__identifier { relationship: many_to_one sql: LEFT JOIN UNNEST([${episode_of_care__care_manager__identifier__assigner.identifier}]) as episode_of_care__care_manager__identifier__assigner__identifier ;; }
# join: episode_of_care__care_manager__identifier__assigner__identifier__assigner { relationship: many_to_one sql: LEFT JOIN UNNEST([${episode_of_care__care_manager__identifier__assigner__identifier.assigner}]) as episode_of_care__care_manager__identifier__assigner__identifier__assigner ;; }
# join: episode_of_care__care_manager__identifier__assigner__identifier__period { relationship: many_to_one sql: LEFT JOIN UNNEST([${episode_of_care__care_manager__identifier__assigner__identifier.period}]) as episode_of_care__care_manager__identifier__assigner__identifier__period ;; }
# join: episode_of_care__care_manager__identifier__assigner__identifier__type { relationship: many_to_one sql: LEFT JOIN UNNEST([${episode_of_care__care_manager__identifier__assigner__identifier.type}]) as episode_of_care__care_manager__identifier__assigner__identifier__type ;; }
# join: episode_of_care__care_manager__identifier__assigner__identifier__type__coding { relationship: many_to_one sql: LEFT JOIN UNNEST(${episode_of_care__care_manager__identifier__assigner__identifier__type.coding}) as episode_of_care__care_manager__identifier__assigner__identifier__type__coding ;; }
# join: episode_of_care__care_manager__identifier__type__coding { relationship: many_to_one sql: LEFT JOIN UNNEST(${episode_of_care__care_manager__identifier__type.coding}) as episode_of_care__care_manager__identifier__type__coding ;; }
# join: episode_of_care__diagnosis { relationship: many_to_one sql: LEFT JOIN UNNEST(${episode_of_care.diagnosis}) as episode_of_care__diagnosis ;; }
# join: episode_of_care__diagnosis__condition { relationship: many_to_one sql: LEFT JOIN UNNEST([${episode_of_care__diagnosis.condition}]) as episode_of_care__diagnosis__condition ;; }
# join: episode_of_care__diagnosis__role { relationship: many_to_one sql: LEFT JOIN UNNEST([${episode_of_care__diagnosis.role}]) as episode_of_care__diagnosis__role ;; }
# join: episode_of_care__diagnosis__condition__identifier { relationship: many_to_one sql: LEFT JOIN UNNEST([${episode_of_care__diagnosis__condition.identifier}]) as episode_of_care__diagnosis__condition__identifier ;; }
# join: episode_of_care__diagnosis__condition__identifier__assigner { relationship: many_to_one sql: LEFT JOIN UNNEST([${episode_of_care__diagnosis__condition__identifier.assigner}]) as episode_of_care__diagnosis__condition__identifier__assigner ;; }
# join: episode_of_care__diagnosis__condition__identifier__period { relationship: many_to_one sql: LEFT JOIN UNNEST([${episode_of_care__diagnosis__condition__identifier.period}]) as episode_of_care__diagnosis__condition__identifier__period ;; }
# join: episode_of_care__diagnosis__condition__identifier__type { relationship: many_to_one sql: LEFT JOIN UNNEST([${episode_of_care__diagnosis__condition__identifier.type}]) as episode_of_care__diagnosis__condition__identifier__type ;; }
# join: episode_of_care__diagnosis__condition__identifier__assigner__identifier { relationship: many_to_one sql: LEFT JOIN UNNEST([${episode_of_care__diagnosis__condition__identifier__assigner.identifier}]) as episode_of_care__diagnosis__condition__identifier__assigner__identifier ;; }
# join: episode_of_care__diagnosis__condition__identifier__assigner__identifier__assigner { relationship: many_to_one sql: LEFT JOIN UNNEST([${episode_of_care__diagnosis__condition__identifier__assigner__identifier.assigner}]) as episode_of_care__diagnosis__condition__identifier__assigner__identifier__assigner ;; }
# join: episode_of_care__diagnosis__condition__identifier__assigner__identifier__period { relationship: many_to_one sql: LEFT JOIN UNNEST([${episode_of_care__diagnosis__condition__identifier__assigner__identifier.period}]) as episode_of_care__diagnosis__condition__identifier__assigner__identifier__period ;; }
# join: episode_of_care__diagnosis__condition__identifier__assigner__identifier__type { relationship: many_to_one sql: LEFT JOIN UNNEST([${episode_of_care__diagnosis__condition__identifier__assigner__identifier.type}]) as episode_of_care__diagnosis__condition__identifier__assigner__identifier__type ;; }
# join: episode_of_care__diagnosis__condition__identifier__assigner__identifier__type__coding { relationship: many_to_one sql: LEFT JOIN UNNEST(${episode_of_care__diagnosis__condition__identifier__assigner__identifier__type.coding}) as episode_of_care__diagnosis__condition__identifier__assigner__identifier__type__coding ;; }
# join: episode_of_care__diagnosis__condition__identifier__type__coding { relationship: many_to_one sql: LEFT JOIN UNNEST(${episode_of_care__diagnosis__condition__identifier__type.coding}) as episode_of_care__diagnosis__condition__identifier__type__coding ;; }
# join: episode_of_care__diagnosis__role__coding { relationship: many_to_one sql: LEFT JOIN UNNEST(${episode_of_care__diagnosis__role.coding}) as episode_of_care__diagnosis__role__coding ;; }
# join: episode_of_care__identifier { relationship: many_to_one sql: LEFT JOIN UNNEST(${episode_of_care.identifier}) as episode_of_care__identifier ;; }
# join: episode_of_care__identifier__assigner { relationship: many_to_one sql: LEFT JOIN UNNEST([${episode_of_care__identifier.assigner}]) as episode_of_care__identifier__assigner ;; }
# join: episode_of_care__identifier__period { relationship: many_to_one sql: LEFT JOIN UNNEST([${episode_of_care__identifier.period}]) as episode_of_care__identifier__period ;; }
# join: episode_of_care__identifier__type { relationship: many_to_one sql: LEFT JOIN UNNEST([${episode_of_care__identifier.type}]) as episode_of_care__identifier__type ;; }
# join: episode_of_care__identifier__assigner__identifier { relationship: many_to_one sql: LEFT JOIN UNNEST([${episode_of_care__identifier__assigner.identifier}]) as episode_of_care__identifier__assigner__identifier ;; }
# join: episode_of_care__identifier__assigner__identifier__assigner { relationship: many_to_one sql: LEFT JOIN UNNEST([${episode_of_care__identifier__assigner__identifier.assigner}]) as episode_of_care__identifier__assigner__identifier__assigner ;; }
# join: episode_of_care__identifier__assigner__identifier__period { relationship: many_to_one sql: LEFT JOIN UNNEST([${episode_of_care__identifier__assigner__identifier.period}]) as episode_of_care__identifier__assigner__identifier__period ;; }
# join: episode_of_care__identifier__assigner__identifier__type { relationship: many_to_one sql: LEFT JOIN UNNEST([${episode_of_care__identifier__assigner__identifier.type}]) as episode_of_care__identifier__assigner__identifier__type ;; }
# join: episode_of_care__identifier__assigner__identifier__type__coding { relationship: many_to_one sql: LEFT JOIN UNNEST(${episode_of_care__identifier__assigner__identifier__type.coding}) as episode_of_care__identifier__assigner__identifier__type__coding ;; }
# join: episode_of_care__identifier__type__coding { relationship: many_to_one sql: LEFT JOIN UNNEST(${episode_of_care__identifier__type.coding}) as episode_of_care__identifier__type__coding ;; }
# join: episode_of_care__managing_organization { relationship: many_to_one sql: LEFT JOIN UNNEST([${episode_of_care.managing_organization}]) as episode_of_care__managing_organization ;; }
# join: episode_of_care__managing_organization__identifier { relationship: many_to_one sql: LEFT JOIN UNNEST([${episode_of_care__managing_organization.identifier}]) as episode_of_care__managing_organization__identifier ;; }
# join: episode_of_care__managing_organization__identifier__assigner { relationship: many_to_one sql: LEFT JOIN UNNEST([${episode_of_care__managing_organization__identifier.assigner}]) as episode_of_care__managing_organization__identifier__assigner ;; }
# join: episode_of_care__managing_organization__identifier__period { relationship: many_to_one sql: LEFT JOIN UNNEST([${episode_of_care__managing_organization__identifier.period}]) as episode_of_care__managing_organization__identifier__period ;; }
# join: episode_of_care__managing_organization__identifier__type { relationship: many_to_one sql: LEFT JOIN UNNEST([${episode_of_care__managing_organization__identifier.type}]) as episode_of_care__managing_organization__identifier__type ;; }
# join: episode_of_care__managing_organization__identifier__assigner__identifier { relationship: many_to_one sql: LEFT JOIN UNNEST([${episode_of_care__managing_organization__identifier__assigner.identifier}]) as episode_of_care__managing_organization__identifier__assigner__identifier ;; }
# join: episode_of_care__managing_organization__identifier__assigner__identifier__assigner { relationship: many_to_one sql: LEFT JOIN UNNEST([${episode_of_care__managing_organization__identifier__assigner__identifier.assigner}]) as episode_of_care__managing_organization__identifier__assigner__identifier__assigner ;; }
# join: episode_of_care__managing_organization__identifier__assigner__identifier__period { relationship: many_to_one sql: LEFT JOIN UNNEST([${episode_of_care__managing_organization__identifier__assigner__identifier.period}]) as episode_of_care__managing_organization__identifier__assigner__identifier__period ;; }
# join: episode_of_care__managing_organization__identifier__assigner__identifier__type { relationship: many_to_one sql: LEFT JOIN UNNEST([${episode_of_care__managing_organization__identifier__assigner__identifier.type}]) as episode_of_care__managing_organization__identifier__assigner__identifier__type ;; }
# join: episode_of_care__managing_organization__identifier__assigner__identifier__type__coding { relationship: many_to_one sql: LEFT JOIN UNNEST(${episode_of_care__managing_organization__identifier__assigner__identifier__type.coding}) as episode_of_care__managing_organization__identifier__assigner__identifier__type__coding ;; }
# join: episode_of_care__managing_organization__identifier__type__coding { relationship: many_to_one sql: LEFT JOIN UNNEST(${episode_of_care__managing_organization__identifier__type.coding}) as episode_of_care__managing_organization__identifier__type__coding ;; }
# join: episode_of_care__meta { relationship: many_to_one sql: LEFT JOIN UNNEST([${episode_of_care.meta}]) as episode_of_care__meta ;; }
# join: episode_of_care__meta__security { relationship: many_to_one sql: LEFT JOIN UNNEST(${episode_of_care__meta.security}) as episode_of_care__meta__security ;; }
# join: episode_of_care__meta__tag { relationship: many_to_one sql: LEFT JOIN UNNEST(${episode_of_care__meta.tag}) as episode_of_care__meta__tag ;; }
# join: episode_of_care__patient { relationship: many_to_one sql: LEFT JOIN UNNEST([${episode_of_care.patient}]) as episode_of_care__patient ;; }
# join: episode_of_care__patient__identifier { relationship: many_to_one sql: LEFT JOIN UNNEST([${episode_of_care__patient.identifier}]) as episode_of_care__patient__identifier ;; }
# join: episode_of_care__patient__identifier__assigner { relationship: many_to_one sql: LEFT JOIN UNNEST([${episode_of_care__patient__identifier.assigner}]) as episode_of_care__patient__identifier__assigner ;; }
# join: episode_of_care__patient__identifier__period { relationship: many_to_one sql: LEFT JOIN UNNEST([${episode_of_care__patient__identifier.period}]) as episode_of_care__patient__identifier__period ;; }
# join: episode_of_care__patient__identifier__type { relationship: many_to_one sql: LEFT JOIN UNNEST([${episode_of_care__patient__identifier.type}]) as episode_of_care__patient__identifier__type ;; }
# join: episode_of_care__patient__identifier__assigner__identifier { relationship: many_to_one sql: LEFT JOIN UNNEST([${episode_of_care__patient__identifier__assigner.identifier}]) as episode_of_care__patient__identifier__assigner__identifier ;; }
# join: episode_of_care__patient__identifier__assigner__identifier__assigner { relationship: many_to_one sql: LEFT JOIN UNNEST([${episode_of_care__patient__identifier__assigner__identifier.assigner}]) as episode_of_care__patient__identifier__assigner__identifier__assigner ;; }
# join: episode_of_care__patient__identifier__assigner__identifier__period { relationship: many_to_one sql: LEFT JOIN UNNEST([${episode_of_care__patient__identifier__assigner__identifier.period}]) as episode_of_care__patient__identifier__assigner__identifier__period ;; }
# join: episode_of_care__patient__identifier__assigner__identifier__type { relationship: many_to_one sql: LEFT JOIN UNNEST([${episode_of_care__patient__identifier__assigner__identifier.type}]) as episode_of_care__patient__identifier__assigner__identifier__type ;; }
# join: episode_of_care__patient__identifier__assigner__identifier__type__coding { relationship: many_to_one sql: LEFT JOIN UNNEST(${episode_of_care__patient__identifier__assigner__identifier__type.coding}) as episode_of_care__patient__identifier__assigner__identifier__type__coding ;; }
# join: episode_of_care__patient__identifier__type__coding { relationship: many_to_one sql: LEFT JOIN UNNEST(${episode_of_care__patient__identifier__type.coding}) as episode_of_care__patient__identifier__type__coding ;; }
# join: episode_of_care__period { relationship: many_to_one sql: LEFT JOIN UNNEST([${episode_of_care.period}]) as episode_of_care__period ;; }
# join: episode_of_care__referral_request { relationship: many_to_one sql: LEFT JOIN UNNEST(${episode_of_care.referral_request}) as episode_of_care__referral_request ;; }
# join: episode_of_care__referral_request__identifier { relationship: many_to_one sql: LEFT JOIN UNNEST([${episode_of_care__referral_request.identifier}]) as episode_of_care__referral_request__identifier ;; }
# join: episode_of_care__referral_request__identifier__assigner { relationship: many_to_one sql: LEFT JOIN UNNEST([${episode_of_care__referral_request__identifier.assigner}]) as episode_of_care__referral_request__identifier__assigner ;; }
# join: episode_of_care__referral_request__identifier__period { relationship: many_to_one sql: LEFT JOIN UNNEST([${episode_of_care__referral_request__identifier.period}]) as episode_of_care__referral_request__identifier__period ;; }
# join: episode_of_care__referral_request__identifier__type { relationship: many_to_one sql: LEFT JOIN UNNEST([${episode_of_care__referral_request__identifier.type}]) as episode_of_care__referral_request__identifier__type ;; }
# join: episode_of_care__referral_request__identifier__assigner__identifier { relationship: many_to_one sql: LEFT JOIN UNNEST([${episode_of_care__referral_request__identifier__assigner.identifier}]) as episode_of_care__referral_request__identifier__assigner__identifier ;; }
# join: episode_of_care__referral_request__identifier__assigner__identifier__assigner { relationship: many_to_one sql: LEFT JOIN UNNEST([${episode_of_care__referral_request__identifier__assigner__identifier.assigner}]) as episode_of_care__referral_request__identifier__assigner__identifier__assigner ;; }
# join: episode_of_care__referral_request__identifier__assigner__identifier__period { relationship: many_to_one sql: LEFT JOIN UNNEST([${episode_of_care__referral_request__identifier__assigner__identifier.period}]) as episode_of_care__referral_request__identifier__assigner__identifier__period ;; }
# join: episode_of_care__referral_request__identifier__assigner__identifier__type { relationship: many_to_one sql: LEFT JOIN UNNEST([${episode_of_care__referral_request__identifier__assigner__identifier.type}]) as episode_of_care__referral_request__identifier__assigner__identifier__type ;; }
# join: episode_of_care__referral_request__identifier__assigner__identifier__type__coding { relationship: many_to_one sql: LEFT JOIN UNNEST(${episode_of_care__referral_request__identifier__assigner__identifier__type.coding}) as episode_of_care__referral_request__identifier__assigner__identifier__type__coding ;; }
# join: episode_of_care__referral_request__identifier__type__coding { relationship: many_to_one sql: LEFT JOIN UNNEST(${episode_of_care__referral_request__identifier__type.coding}) as episode_of_care__referral_request__identifier__type__coding ;; }
# join: episode_of_care__status_history { relationship: many_to_one sql: LEFT JOIN UNNEST(${episode_of_care.status_history}) as episode_of_care__status_history ;; }
# join: episode_of_care__status_history__period { relationship: many_to_one sql: LEFT JOIN UNNEST([${episode_of_care__status_history.period}]) as episode_of_care__status_history__period ;; }
# join: episode_of_care__team { relationship: many_to_one sql: LEFT JOIN UNNEST(${episode_of_care.team}) as episode_of_care__team ;; }
# join: episode_of_care__team__identifier { relationship: many_to_one sql: LEFT JOIN UNNEST([${episode_of_care__team.identifier}]) as episode_of_care__team__identifier ;; }
# join: episode_of_care__team__identifier__assigner { relationship: many_to_one sql: LEFT JOIN UNNEST([${episode_of_care__team__identifier.assigner}]) as episode_of_care__team__identifier__assigner ;; }
# join: episode_of_care__team__identifier__period { relationship: many_to_one sql: LEFT JOIN UNNEST([${episode_of_care__team__identifier.period}]) as episode_of_care__team__identifier__period ;; }
# join: episode_of_care__team__identifier__type { relationship: many_to_one sql: LEFT JOIN UNNEST([${episode_of_care__team__identifier.type}]) as episode_of_care__team__identifier__type ;; }
# join: episode_of_care__team__identifier__assigner__identifier { relationship: many_to_one sql: LEFT JOIN UNNEST([${episode_of_care__team__identifier__assigner.identifier}]) as episode_of_care__team__identifier__assigner__identifier ;; }
# join: episode_of_care__team__identifier__assigner__identifier__assigner { relationship: many_to_one sql: LEFT JOIN UNNEST([${episode_of_care__team__identifier__assigner__identifier.assigner}]) as episode_of_care__team__identifier__assigner__identifier__assigner ;; }
# join: episode_of_care__team__identifier__assigner__identifier__period { relationship: many_to_one sql: LEFT JOIN UNNEST([${episode_of_care__team__identifier__assigner__identifier.period}]) as episode_of_care__team__identifier__assigner__identifier__period ;; }
# join: episode_of_care__team__identifier__assigner__identifier__type { relationship: many_to_one sql: LEFT JOIN UNNEST([${episode_of_care__team__identifier__assigner__identifier.type}]) as episode_of_care__team__identifier__assigner__identifier__type ;; }
# join: episode_of_care__team__identifier__assigner__identifier__type__coding { relationship: many_to_one sql: LEFT JOIN UNNEST(${episode_of_care__team__identifier__assigner__identifier__type.coding}) as episode_of_care__team__identifier__assigner__identifier__type__coding ;; }
# join: episode_of_care__team__identifier__type__coding { relationship: many_to_one sql: LEFT JOIN UNNEST(${episode_of_care__team__identifier__type.coding}) as episode_of_care__team__identifier__type__coding ;; }
# join: episode_of_care__text { relationship: many_to_one sql: LEFT JOIN UNNEST([${episode_of_care.text}]) as episode_of_care__text ;; }
# join: episode_of_care__type { relationship: many_to_one sql: LEFT JOIN UNNEST(${episode_of_care.type}) as episode_of_care__type ;; }
# join: episode_of_care__type__coding { relationship: many_to_one sql: LEFT JOIN UNNEST(${episode_of_care__type.coding}) as episode_of_care__type__coding ;; }

# join: location__address { relationship: many_to_one sql: LEFT JOIN UNNEST([${location.address}]) as location__address ;; }
# join: location__address__period { relationship: many_to_one sql: LEFT JOIN UNNEST([${location__address.period}]) as location__address__period ;; }
# join: location__endpoint { relationship: many_to_one sql: LEFT JOIN UNNEST(${location.endpoint}) as location__endpoint ;; }
# join: location__endpoint__identifier { relationship: many_to_one sql: LEFT JOIN UNNEST([${location__endpoint.identifier}]) as location__endpoint__identifier ;; }
# join: location__endpoint__identifier__assigner { relationship: many_to_one sql: LEFT JOIN UNNEST([${location__endpoint__identifier.assigner}]) as location__endpoint__identifier__assigner ;; }
# join: location__endpoint__identifier__period { relationship: many_to_one sql: LEFT JOIN UNNEST([${location__endpoint__identifier.period}]) as location__endpoint__identifier__period ;; }
# join: location__endpoint__identifier__type { relationship: many_to_one sql: LEFT JOIN UNNEST([${location__endpoint__identifier.type}]) as location__endpoint__identifier__type ;; }
# join: location__endpoint__identifier__assigner__identifier { relationship: many_to_one sql: LEFT JOIN UNNEST([${location__endpoint__identifier__assigner.identifier}]) as location__endpoint__identifier__assigner__identifier ;; }
# join: location__endpoint__identifier__assigner__identifier__assigner { relationship: many_to_one sql: LEFT JOIN UNNEST([${location__endpoint__identifier__assigner__identifier.assigner}]) as location__endpoint__identifier__assigner__identifier__assigner ;; }
# join: location__endpoint__identifier__assigner__identifier__period { relationship: many_to_one sql: LEFT JOIN UNNEST([${location__endpoint__identifier__assigner__identifier.period}]) as location__endpoint__identifier__assigner__identifier__period ;; }
# join: location__endpoint__identifier__assigner__identifier__type { relationship: many_to_one sql: LEFT JOIN UNNEST([${location__endpoint__identifier__assigner__identifier.type}]) as location__endpoint__identifier__assigner__identifier__type ;; }
# join: location__endpoint__identifier__assigner__identifier__type__coding { relationship: many_to_one sql: LEFT JOIN UNNEST(${location__endpoint__identifier__assigner__identifier__type.coding}) as location__endpoint__identifier__assigner__identifier__type__coding ;; }
# join: location__endpoint__identifier__type__coding { relationship: many_to_one sql: LEFT JOIN UNNEST(${location__endpoint__identifier__type.coding}) as location__endpoint__identifier__type__coding ;; }
# join: location__identifier { relationship: many_to_one sql: LEFT JOIN UNNEST(${location.identifier}) as location__identifier ;; }
# join: location__identifier__assigner { relationship: many_to_one sql: LEFT JOIN UNNEST([${location__identifier.assigner}]) as location__identifier__assigner ;; }
# join: location__identifier__period { relationship: many_to_one sql: LEFT JOIN UNNEST([${location__identifier.period}]) as location__identifier__period ;; }
# join: location__identifier__type { relationship: many_to_one sql: LEFT JOIN UNNEST([${location__identifier.type}]) as location__identifier__type ;; }
# join: location__identifier__assigner__identifier { relationship: many_to_one sql: LEFT JOIN UNNEST([${location__identifier__assigner.identifier}]) as location__identifier__assigner__identifier ;; }
# join: location__identifier__assigner__identifier__assigner { relationship: many_to_one sql: LEFT JOIN UNNEST([${location__identifier__assigner__identifier.assigner}]) as location__identifier__assigner__identifier__assigner ;; }
# join: location__identifier__assigner__identifier__period { relationship: many_to_one sql: LEFT JOIN UNNEST([${location__identifier__assigner__identifier.period}]) as location__identifier__assigner__identifier__period ;; }
# join: location__identifier__assigner__identifier__type { relationship: many_to_one sql: LEFT JOIN UNNEST([${location__identifier__assigner__identifier.type}]) as location__identifier__assigner__identifier__type ;; }
# join: location__identifier__assigner__identifier__type__coding { relationship: many_to_one sql: LEFT JOIN UNNEST(${location__identifier__assigner__identifier__type.coding}) as location__identifier__assigner__identifier__type__coding ;; }
# join: location__identifier__type__coding { relationship: many_to_one sql: LEFT JOIN UNNEST(${location__identifier__type.coding}) as location__identifier__type__coding ;; }
# join: location__managing_organization { relationship: many_to_one sql: LEFT JOIN UNNEST([${location.managing_organization}]) as location__managing_organization ;; }
# join: location__managing_organization__identifier { relationship: many_to_one sql: LEFT JOIN UNNEST([${location__managing_organization.identifier}]) as location__managing_organization__identifier ;; }
# join: location__managing_organization__identifier__assigner { relationship: many_to_one sql: LEFT JOIN UNNEST([${location__managing_organization__identifier.assigner}]) as location__managing_organization__identifier__assigner ;; }
# join: location__managing_organization__identifier__period { relationship: many_to_one sql: LEFT JOIN UNNEST([${location__managing_organization__identifier.period}]) as location__managing_organization__identifier__period ;; }
# join: location__managing_organization__identifier__type { relationship: many_to_one sql: LEFT JOIN UNNEST([${location__managing_organization__identifier.type}]) as location__managing_organization__identifier__type ;; }
# join: location__managing_organization__identifier__assigner__identifier { relationship: many_to_one sql: LEFT JOIN UNNEST([${location__managing_organization__identifier__assigner.identifier}]) as location__managing_organization__identifier__assigner__identifier ;; }
# join: location__managing_organization__identifier__assigner__identifier__assigner { relationship: many_to_one sql: LEFT JOIN UNNEST([${location__managing_organization__identifier__assigner__identifier.assigner}]) as location__managing_organization__identifier__assigner__identifier__assigner ;; }
# join: location__managing_organization__identifier__assigner__identifier__period { relationship: many_to_one sql: LEFT JOIN UNNEST([${location__managing_organization__identifier__assigner__identifier.period}]) as location__managing_organization__identifier__assigner__identifier__period ;; }
# join: location__managing_organization__identifier__assigner__identifier__type { relationship: many_to_one sql: LEFT JOIN UNNEST([${location__managing_organization__identifier__assigner__identifier.type}]) as location__managing_organization__identifier__assigner__identifier__type ;; }
# join: location__managing_organization__identifier__assigner__identifier__type__coding { relationship: many_to_one sql: LEFT JOIN UNNEST(${location__managing_organization__identifier__assigner__identifier__type.coding}) as location__managing_organization__identifier__assigner__identifier__type__coding ;; }
# join: location__managing_organization__identifier__type__coding { relationship: many_to_one sql: LEFT JOIN UNNEST(${location__managing_organization__identifier__type.coding}) as location__managing_organization__identifier__type__coding ;; }
# join: location__meta { relationship: many_to_one sql: LEFT JOIN UNNEST([${location.meta}]) as location__meta ;; }
# join: location__meta__security { relationship: many_to_one sql: LEFT JOIN UNNEST(${location__meta.security}) as location__meta__security ;; }
# join: location__meta__tag { relationship: many_to_one sql: LEFT JOIN UNNEST(${location__meta.tag}) as location__meta__tag ;; }
# join: location__operational_status { relationship: many_to_one sql: LEFT JOIN UNNEST([${location.operational_status}]) as location__operational_status ;; }
# join: location__part_of { relationship: many_to_one sql: LEFT JOIN UNNEST([${location.part_of}]) as location__part_of ;; }
# join: location__part_of__identifier { relationship: many_to_one sql: LEFT JOIN UNNEST([${location__part_of.identifier}]) as location__part_of__identifier ;; }
# join: location__part_of__identifier__assigner { relationship: many_to_one sql: LEFT JOIN UNNEST([${location__part_of__identifier.assigner}]) as location__part_of__identifier__assigner ;; }
# join: location__part_of__identifier__period { relationship: many_to_one sql: LEFT JOIN UNNEST([${location__part_of__identifier.period}]) as location__part_of__identifier__period ;; }
# join: location__part_of__identifier__type { relationship: many_to_one sql: LEFT JOIN UNNEST([${location__part_of__identifier.type}]) as location__part_of__identifier__type ;; }
# join: location__part_of__identifier__assigner__identifier { relationship: many_to_one sql: LEFT JOIN UNNEST([${location__part_of__identifier__assigner.identifier}]) as location__part_of__identifier__assigner__identifier ;; }
# join: location__part_of__identifier__assigner__identifier__assigner { relationship: many_to_one sql: LEFT JOIN UNNEST([${location__part_of__identifier__assigner__identifier.assigner}]) as location__part_of__identifier__assigner__identifier__assigner ;; }
# join: location__part_of__identifier__assigner__identifier__period { relationship: many_to_one sql: LEFT JOIN UNNEST([${location__part_of__identifier__assigner__identifier.period}]) as location__part_of__identifier__assigner__identifier__period ;; }
# join: location__part_of__identifier__assigner__identifier__type { relationship: many_to_one sql: LEFT JOIN UNNEST([${location__part_of__identifier__assigner__identifier.type}]) as location__part_of__identifier__assigner__identifier__type ;; }
# join: location__part_of__identifier__assigner__identifier__type__coding { relationship: many_to_one sql: LEFT JOIN UNNEST(${location__part_of__identifier__assigner__identifier__type.coding}) as location__part_of__identifier__assigner__identifier__type__coding ;; }
# join: location__part_of__identifier__type__coding { relationship: many_to_one sql: LEFT JOIN UNNEST(${location__part_of__identifier__type.coding}) as location__part_of__identifier__type__coding ;; }
# join: location__physical_type { relationship: many_to_one sql: LEFT JOIN UNNEST([${location.physical_type}]) as location__physical_type ;; }
# join: location__physical_type__coding { relationship: many_to_one sql: LEFT JOIN UNNEST(${location__physical_type.coding}) as location__physical_type__coding ;; }
# join: location__position { relationship: many_to_one sql: LEFT JOIN UNNEST([${location.position}]) as location__position ;; }
# join: location__telecom { relationship: many_to_one sql: LEFT JOIN UNNEST(${location.telecom}) as location__telecom ;; }
# join: location__telecom__period { relationship: many_to_one sql: LEFT JOIN UNNEST([${location__telecom.period}]) as location__telecom__period ;; }
# join: location__text { relationship: many_to_one sql: LEFT JOIN UNNEST([${location.text}]) as location__text ;; }
# join: location__type { relationship: many_to_one sql: LEFT JOIN UNNEST([${location.type}]) as location__type ;; }
# join: location__type__coding { relationship: many_to_one sql: LEFT JOIN UNNEST(${location__type.coding}) as location__type__coding ;; }

# join: medicationrequest__based_on { relationship: many_to_one sql: LEFT JOIN UNNEST(${medicationrequest.based_on}) as medicationrequest__based_on ;; }
# join: medicationrequest__based_on__identifier { relationship: many_to_one sql: LEFT JOIN UNNEST([${medicationrequest__based_on.identifier}]) as medicationrequest__based_on__identifier ;; }
# join: medicationrequest__based_on__identifier__assigner { relationship: many_to_one sql: LEFT JOIN UNNEST([${medicationrequest__based_on__identifier.assigner}]) as medicationrequest__based_on__identifier__assigner ;; }
# join: medicationrequest__based_on__identifier__period { relationship: many_to_one sql: LEFT JOIN UNNEST([${medicationrequest__based_on__identifier.period}]) as medicationrequest__based_on__identifier__period ;; }
# join: medicationrequest__based_on__identifier__type { relationship: many_to_one sql: LEFT JOIN UNNEST([${medicationrequest__based_on__identifier.type}]) as medicationrequest__based_on__identifier__type ;; }
# join: medicationrequest__based_on__identifier__assigner__identifier { relationship: many_to_one sql: LEFT JOIN UNNEST([${medicationrequest__based_on__identifier__assigner.identifier}]) as medicationrequest__based_on__identifier__assigner__identifier ;; }
# join: medicationrequest__based_on__identifier__assigner__identifier__assigner { relationship: many_to_one sql: LEFT JOIN UNNEST([${medicationrequest__based_on__identifier__assigner__identifier.assigner}]) as medicationrequest__based_on__identifier__assigner__identifier__assigner ;; }
# join: medicationrequest__based_on__identifier__assigner__identifier__period { relationship: many_to_one sql: LEFT JOIN UNNEST([${medicationrequest__based_on__identifier__assigner__identifier.period}]) as medicationrequest__based_on__identifier__assigner__identifier__period ;; }
# join: medicationrequest__based_on__identifier__assigner__identifier__type { relationship: many_to_one sql: LEFT JOIN UNNEST([${medicationrequest__based_on__identifier__assigner__identifier.type}]) as medicationrequest__based_on__identifier__assigner__identifier__type ;; }
# join: medicationrequest__based_on__identifier__assigner__identifier__type__coding { relationship: many_to_one sql: LEFT JOIN UNNEST(${medicationrequest__based_on__identifier__assigner__identifier__type.coding}) as medicationrequest__based_on__identifier__assigner__identifier__type__coding ;; }
# join: medicationrequest__based_on__identifier__type__coding { relationship: many_to_one sql: LEFT JOIN UNNEST(${medicationrequest__based_on__identifier__type.coding}) as medicationrequest__based_on__identifier__type__coding ;; }
# join: medicationrequest__category { relationship: many_to_one sql: LEFT JOIN UNNEST([${medicationrequest.category}]) as medicationrequest__category ;; }
# join: medicationrequest__category__coding { relationship: many_to_one sql: LEFT JOIN UNNEST(${medicationrequest__category.coding}) as medicationrequest__category__coding ;; }
# join: medicationrequest__code { relationship: many_to_one sql: LEFT JOIN UNNEST([${medicationrequest.code}]) as medicationrequest__code ;; }
# join: medicationrequest__code__coding { relationship: many_to_one sql: LEFT JOIN UNNEST(${medicationrequest__code.coding}) as medicationrequest__code__coding ;; }
# join: medicationrequest__coded_diagnosis { relationship: many_to_one sql: LEFT JOIN UNNEST(${medicationrequest.coded_diagnosis}) as medicationrequest__coded_diagnosis ;; }
# join: medicationrequest__coded_diagnosis__coding { relationship: many_to_one sql: LEFT JOIN UNNEST(${medicationrequest__coded_diagnosis.coding}) as medicationrequest__coded_diagnosis__coding ;; }
# join: medicationrequest__context { relationship: many_to_one sql: LEFT JOIN UNNEST([${medicationrequest.context}]) as medicationrequest__context ;; }
# join: medicationrequest__context__identifier { relationship: many_to_one sql: LEFT JOIN UNNEST([${medicationrequest__context.identifier}]) as medicationrequest__context__identifier ;; }
# join: medicationrequest__context__identifier__assigner { relationship: many_to_one sql: LEFT JOIN UNNEST([${medicationrequest__context__identifier.assigner}]) as medicationrequest__context__identifier__assigner ;; }
# join: medicationrequest__context__identifier__period { relationship: many_to_one sql: LEFT JOIN UNNEST([${medicationrequest__context__identifier.period}]) as medicationrequest__context__identifier__period ;; }
# join: medicationrequest__context__identifier__type { relationship: many_to_one sql: LEFT JOIN UNNEST([${medicationrequest__context__identifier.type}]) as medicationrequest__context__identifier__type ;; }
# join: medicationrequest__context__identifier__assigner__identifier { relationship: many_to_one sql: LEFT JOIN UNNEST([${medicationrequest__context__identifier__assigner.identifier}]) as medicationrequest__context__identifier__assigner__identifier ;; }
# join: medicationrequest__context__identifier__assigner__identifier__assigner { relationship: many_to_one sql: LEFT JOIN UNNEST([${medicationrequest__context__identifier__assigner__identifier.assigner}]) as medicationrequest__context__identifier__assigner__identifier__assigner ;; }
# join: medicationrequest__context__identifier__assigner__identifier__period { relationship: many_to_one sql: LEFT JOIN UNNEST([${medicationrequest__context__identifier__assigner__identifier.period}]) as medicationrequest__context__identifier__assigner__identifier__period ;; }
# join: medicationrequest__context__identifier__assigner__identifier__type { relationship: many_to_one sql: LEFT JOIN UNNEST([${medicationrequest__context__identifier__assigner__identifier.type}]) as medicationrequest__context__identifier__assigner__identifier__type ;; }
# join: medicationrequest__context__identifier__assigner__identifier__type__coding { relationship: many_to_one sql: LEFT JOIN UNNEST(${medicationrequest__context__identifier__assigner__identifier__type.coding}) as medicationrequest__context__identifier__assigner__identifier__type__coding ;; }
# join: medicationrequest__context__identifier__type__coding { relationship: many_to_one sql: LEFT JOIN UNNEST(${medicationrequest__context__identifier__type.coding}) as medicationrequest__context__identifier__type__coding ;; }
# join: medicationrequest__effective { relationship: many_to_one sql: LEFT JOIN UNNEST([${medicationrequest.effective}]) as medicationrequest__effective ;; }
# join: medicationrequest__identifier { relationship: many_to_one sql: LEFT JOIN UNNEST(${medicationrequest.identifier}) as medicationrequest__identifier ;; }
# join: medicationrequest__identifier__assigner { relationship: many_to_one sql: LEFT JOIN UNNEST([${medicationrequest__identifier.assigner}]) as medicationrequest__identifier__assigner ;; }
# join: medicationrequest__identifier__period { relationship: many_to_one sql: LEFT JOIN UNNEST([${medicationrequest__identifier.period}]) as medicationrequest__identifier__period ;; }
# join: medicationrequest__identifier__type { relationship: many_to_one sql: LEFT JOIN UNNEST([${medicationrequest__identifier.type}]) as medicationrequest__identifier__type ;; }
# join: medicationrequest__identifier__assigner__identifier { relationship: many_to_one sql: LEFT JOIN UNNEST([${medicationrequest__identifier__assigner.identifier}]) as medicationrequest__identifier__assigner__identifier ;; }
# join: medicationrequest__identifier__assigner__identifier__assigner { relationship: many_to_one sql: LEFT JOIN UNNEST([${medicationrequest__identifier__assigner__identifier.assigner}]) as medicationrequest__identifier__assigner__identifier__assigner ;; }
# join: medicationrequest__identifier__assigner__identifier__period { relationship: many_to_one sql: LEFT JOIN UNNEST([${medicationrequest__identifier__assigner__identifier.period}]) as medicationrequest__identifier__assigner__identifier__period ;; }
# join: medicationrequest__identifier__assigner__identifier__type { relationship: many_to_one sql: LEFT JOIN UNNEST([${medicationrequest__identifier__assigner__identifier.type}]) as medicationrequest__identifier__assigner__identifier__type ;; }
# join: medicationrequest__identifier__assigner__identifier__type__coding { relationship: many_to_one sql: LEFT JOIN UNNEST(${medicationrequest__identifier__assigner__identifier__type.coding}) as medicationrequest__identifier__assigner__identifier__type__coding ;; }
# join: medicationrequest__identifier__type__coding { relationship: many_to_one sql: LEFT JOIN UNNEST(${medicationrequest__identifier__type.coding}) as medicationrequest__identifier__type__coding ;; }
# join: medicationrequest__image { relationship: many_to_one sql: LEFT JOIN UNNEST(${medicationrequest.image}) as medicationrequest__image ;; }
# join: medicationrequest__image__link { relationship: many_to_one sql: LEFT JOIN UNNEST([${medicationrequest__image.link}]) as medicationrequest__image__link ;; }
# join: medicationrequest__image__link__identifier { relationship: many_to_one sql: LEFT JOIN UNNEST([${medicationrequest__image__link.identifier}]) as medicationrequest__image__link__identifier ;; }
# join: medicationrequest__image__link__identifier__assigner { relationship: many_to_one sql: LEFT JOIN UNNEST([${medicationrequest__image__link__identifier.assigner}]) as medicationrequest__image__link__identifier__assigner ;; }
# join: medicationrequest__image__link__identifier__period { relationship: many_to_one sql: LEFT JOIN UNNEST([${medicationrequest__image__link__identifier.period}]) as medicationrequest__image__link__identifier__period ;; }
# join: medicationrequest__image__link__identifier__type { relationship: many_to_one sql: LEFT JOIN UNNEST([${medicationrequest__image__link__identifier.type}]) as medicationrequest__image__link__identifier__type ;; }
# join: medicationrequest__image__link__identifier__assigner__identifier { relationship: many_to_one sql: LEFT JOIN UNNEST([${medicationrequest__image__link__identifier__assigner.identifier}]) as medicationrequest__image__link__identifier__assigner__identifier ;; }
# join: medicationrequest__image__link__identifier__assigner__identifier__assigner { relationship: many_to_one sql: LEFT JOIN UNNEST([${medicationrequest__image__link__identifier__assigner__identifier.assigner}]) as medicationrequest__image__link__identifier__assigner__identifier__assigner ;; }
# join: medicationrequest__image__link__identifier__assigner__identifier__period { relationship: many_to_one sql: LEFT JOIN UNNEST([${medicationrequest__image__link__identifier__assigner__identifier.period}]) as medicationrequest__image__link__identifier__assigner__identifier__period ;; }
# join: medicationrequest__image__link__identifier__assigner__identifier__type { relationship: many_to_one sql: LEFT JOIN UNNEST([${medicationrequest__image__link__identifier__assigner__identifier.type}]) as medicationrequest__image__link__identifier__assigner__identifier__type ;; }
# join: medicationrequest__image__link__identifier__assigner__identifier__type__coding { relationship: many_to_one sql: LEFT JOIN UNNEST(${medicationrequest__image__link__identifier__assigner__identifier__type.coding}) as medicationrequest__image__link__identifier__assigner__identifier__type__coding ;; }
# join: medicationrequest__image__link__identifier__type__coding { relationship: many_to_one sql: LEFT JOIN UNNEST(${medicationrequest__image__link__identifier__type.coding}) as medicationrequest__image__link__identifier__type__coding ;; }
# join: medicationrequest__imaging_study { relationship: many_to_one sql: LEFT JOIN UNNEST(${medicationrequest.imaging_study}) as medicationrequest__imaging_study ;; }
# join: medicationrequest__imaging_study__identifier { relationship: many_to_one sql: LEFT JOIN UNNEST([${medicationrequest__imaging_study.identifier}]) as medicationrequest__imaging_study__identifier ;; }
# join: medicationrequest__imaging_study__identifier__assigner { relationship: many_to_one sql: LEFT JOIN UNNEST([${medicationrequest__imaging_study__identifier.assigner}]) as medicationrequest__imaging_study__identifier__assigner ;; }
# join: medicationrequest__imaging_study__identifier__period { relationship: many_to_one sql: LEFT JOIN UNNEST([${medicationrequest__imaging_study__identifier.period}]) as medicationrequest__imaging_study__identifier__period ;; }
# join: medicationrequest__imaging_study__identifier__type { relationship: many_to_one sql: LEFT JOIN UNNEST([${medicationrequest__imaging_study__identifier.type}]) as medicationrequest__imaging_study__identifier__type ;; }
# join: medicationrequest__imaging_study__identifier__assigner__identifier { relationship: many_to_one sql: LEFT JOIN UNNEST([${medicationrequest__imaging_study__identifier__assigner.identifier}]) as medicationrequest__imaging_study__identifier__assigner__identifier ;; }
# join: medicationrequest__imaging_study__identifier__assigner__identifier__assigner { relationship: many_to_one sql: LEFT JOIN UNNEST([${medicationrequest__imaging_study__identifier__assigner__identifier.assigner}]) as medicationrequest__imaging_study__identifier__assigner__identifier__assigner ;; }
# join: medicationrequest__imaging_study__identifier__assigner__identifier__period { relationship: many_to_one sql: LEFT JOIN UNNEST([${medicationrequest__imaging_study__identifier__assigner__identifier.period}]) as medicationrequest__imaging_study__identifier__assigner__identifier__period ;; }
# join: medicationrequest__imaging_study__identifier__assigner__identifier__type { relationship: many_to_one sql: LEFT JOIN UNNEST([${medicationrequest__imaging_study__identifier__assigner__identifier.type}]) as medicationrequest__imaging_study__identifier__assigner__identifier__type ;; }
# join: medicationrequest__imaging_study__identifier__assigner__identifier__type__coding { relationship: many_to_one sql: LEFT JOIN UNNEST(${medicationrequest__imaging_study__identifier__assigner__identifier__type.coding}) as medicationrequest__imaging_study__identifier__assigner__identifier__type__coding ;; }
# join: medicationrequest__imaging_study__identifier__type__coding { relationship: many_to_one sql: LEFT JOIN UNNEST(${medicationrequest__imaging_study__identifier__type.coding}) as medicationrequest__imaging_study__identifier__type__coding ;; }
# join: medicationrequest__meta { relationship: many_to_one sql: LEFT JOIN UNNEST([${medicationrequest.meta}]) as medicationrequest__meta ;; }
# join: medicationrequest__meta__security { relationship: many_to_one sql: LEFT JOIN UNNEST(${medicationrequest__meta.security}) as medicationrequest__meta__security ;; }
# join: medicationrequest__meta__tag { relationship: many_to_one sql: LEFT JOIN UNNEST(${medicationrequest__meta.tag}) as medicationrequest__meta__tag ;; }
# join: medicationrequest__performer { relationship: many_to_one sql: LEFT JOIN UNNEST(${medicationrequest.performer}) as medicationrequest__performer ;; }
# join: medicationrequest__performer__actor { relationship: many_to_one sql: LEFT JOIN UNNEST([${medicationrequest__performer.actor}]) as medicationrequest__performer__actor ;; }
# join: medicationrequest__performer__role { relationship: many_to_one sql: LEFT JOIN UNNEST([${medicationrequest__performer.role}]) as medicationrequest__performer__role ;; }
# join: medicationrequest__performer__actor__identifier { relationship: many_to_one sql: LEFT JOIN UNNEST([${medicationrequest__performer__actor.identifier}]) as medicationrequest__performer__actor__identifier ;; }
# join: medicationrequest__performer__actor__identifier__assigner { relationship: many_to_one sql: LEFT JOIN UNNEST([${medicationrequest__performer__actor__identifier.assigner}]) as medicationrequest__performer__actor__identifier__assigner ;; }
# join: medicationrequest__performer__actor__identifier__period { relationship: many_to_one sql: LEFT JOIN UNNEST([${medicationrequest__performer__actor__identifier.period}]) as medicationrequest__performer__actor__identifier__period ;; }
# join: medicationrequest__performer__actor__identifier__type { relationship: many_to_one sql: LEFT JOIN UNNEST([${medicationrequest__performer__actor__identifier.type}]) as medicationrequest__performer__actor__identifier__type ;; }
# join: medicationrequest__performer__actor__identifier__assigner__identifier { relationship: many_to_one sql: LEFT JOIN UNNEST([${medicationrequest__performer__actor__identifier__assigner.identifier}]) as medicationrequest__performer__actor__identifier__assigner__identifier ;; }
# join: medicationrequest__performer__actor__identifier__assigner__identifier__assigner { relationship: many_to_one sql: LEFT JOIN UNNEST([${medicationrequest__performer__actor__identifier__assigner__identifier.assigner}]) as medicationrequest__performer__actor__identifier__assigner__identifier__assigner ;; }
# join: medicationrequest__performer__actor__identifier__assigner__identifier__period { relationship: many_to_one sql: LEFT JOIN UNNEST([${medicationrequest__performer__actor__identifier__assigner__identifier.period}]) as medicationrequest__performer__actor__identifier__assigner__identifier__period ;; }
# join: medicationrequest__performer__actor__identifier__assigner__identifier__type { relationship: many_to_one sql: LEFT JOIN UNNEST([${medicationrequest__performer__actor__identifier__assigner__identifier.type}]) as medicationrequest__performer__actor__identifier__assigner__identifier__type ;; }
# join: medicationrequest__performer__actor__identifier__assigner__identifier__type__coding { relationship: many_to_one sql: LEFT JOIN UNNEST(${medicationrequest__performer__actor__identifier__assigner__identifier__type.coding}) as medicationrequest__performer__actor__identifier__assigner__identifier__type__coding ;; }
# join: medicationrequest__performer__actor__identifier__type__coding { relationship: many_to_one sql: LEFT JOIN UNNEST(${medicationrequest__performer__actor__identifier__type.coding}) as medicationrequest__performer__actor__identifier__type__coding ;; }
# join: medicationrequest__performer__role__coding { relationship: many_to_one sql: LEFT JOIN UNNEST(${medicationrequest__performer__role.coding}) as medicationrequest__performer__role__coding ;; }
# join: medicationrequest__presented_form { relationship: many_to_one sql: LEFT JOIN UNNEST(${medicationrequest.presented_form}) as medicationrequest__presented_form ;; }
# join: medicationrequest__result { relationship: many_to_one sql: LEFT JOIN UNNEST(${medicationrequest.result}) as medicationrequest__result ;; }
# join: medicationrequest__result__identifier { relationship: many_to_one sql: LEFT JOIN UNNEST([${medicationrequest__result.identifier}]) as medicationrequest__result__identifier ;; }
# join: medicationrequest__result__identifier__assigner { relationship: many_to_one sql: LEFT JOIN UNNEST([${medicationrequest__result__identifier.assigner}]) as medicationrequest__result__identifier__assigner ;; }
# join: medicationrequest__result__identifier__period { relationship: many_to_one sql: LEFT JOIN UNNEST([${medicationrequest__result__identifier.period}]) as medicationrequest__result__identifier__period ;; }
# join: medicationrequest__result__identifier__type { relationship: many_to_one sql: LEFT JOIN UNNEST([${medicationrequest__result__identifier.type}]) as medicationrequest__result__identifier__type ;; }
# join: medicationrequest__result__identifier__assigner__identifier { relationship: many_to_one sql: LEFT JOIN UNNEST([${medicationrequest__result__identifier__assigner.identifier}]) as medicationrequest__result__identifier__assigner__identifier ;; }
# join: medicationrequest__result__identifier__assigner__identifier__assigner { relationship: many_to_one sql: LEFT JOIN UNNEST([${medicationrequest__result__identifier__assigner__identifier.assigner}]) as medicationrequest__result__identifier__assigner__identifier__assigner ;; }
# join: medicationrequest__result__identifier__assigner__identifier__period { relationship: many_to_one sql: LEFT JOIN UNNEST([${medicationrequest__result__identifier__assigner__identifier.period}]) as medicationrequest__result__identifier__assigner__identifier__period ;; }
# join: medicationrequest__result__identifier__assigner__identifier__type { relationship: many_to_one sql: LEFT JOIN UNNEST([${medicationrequest__result__identifier__assigner__identifier.type}]) as medicationrequest__result__identifier__assigner__identifier__type ;; }
# join: medicationrequest__result__identifier__assigner__identifier__type__coding { relationship: many_to_one sql: LEFT JOIN UNNEST(${medicationrequest__result__identifier__assigner__identifier__type.coding}) as medicationrequest__result__identifier__assigner__identifier__type__coding ;; }
# join: medicationrequest__result__identifier__type__coding { relationship: many_to_one sql: LEFT JOIN UNNEST(${medicationrequest__result__identifier__type.coding}) as medicationrequest__result__identifier__type__coding ;; }
# join: medicationrequest__specimen { relationship: many_to_one sql: LEFT JOIN UNNEST(${medicationrequest.specimen}) as medicationrequest__specimen ;; }
# join: medicationrequest__specimen__identifier { relationship: many_to_one sql: LEFT JOIN UNNEST([${medicationrequest__specimen.identifier}]) as medicationrequest__specimen__identifier ;; }
# join: medicationrequest__specimen__identifier__assigner { relationship: many_to_one sql: LEFT JOIN UNNEST([${medicationrequest__specimen__identifier.assigner}]) as medicationrequest__specimen__identifier__assigner ;; }
# join: medicationrequest__specimen__identifier__period { relationship: many_to_one sql: LEFT JOIN UNNEST([${medicationrequest__specimen__identifier.period}]) as medicationrequest__specimen__identifier__period ;; }
# join: medicationrequest__specimen__identifier__type { relationship: many_to_one sql: LEFT JOIN UNNEST([${medicationrequest__specimen__identifier.type}]) as medicationrequest__specimen__identifier__type ;; }
# join: medicationrequest__specimen__identifier__assigner__identifier { relationship: many_to_one sql: LEFT JOIN UNNEST([${medicationrequest__specimen__identifier__assigner.identifier}]) as medicationrequest__specimen__identifier__assigner__identifier ;; }
# join: medicationrequest__specimen__identifier__assigner__identifier__assigner { relationship: many_to_one sql: LEFT JOIN UNNEST([${medicationrequest__specimen__identifier__assigner__identifier.assigner}]) as medicationrequest__specimen__identifier__assigner__identifier__assigner ;; }
# join: medicationrequest__specimen__identifier__assigner__identifier__period { relationship: many_to_one sql: LEFT JOIN UNNEST([${medicationrequest__specimen__identifier__assigner__identifier.period}]) as medicationrequest__specimen__identifier__assigner__identifier__period ;; }
# join: medicationrequest__specimen__identifier__assigner__identifier__type { relationship: many_to_one sql: LEFT JOIN UNNEST([${medicationrequest__specimen__identifier__assigner__identifier.type}]) as medicationrequest__specimen__identifier__assigner__identifier__type ;; }
# join: medicationrequest__specimen__identifier__assigner__identifier__type__coding { relationship: many_to_one sql: LEFT JOIN UNNEST(${medicationrequest__specimen__identifier__assigner__identifier__type.coding}) as medicationrequest__specimen__identifier__assigner__identifier__type__coding ;; }
# join: medicationrequest__specimen__identifier__type__coding { relationship: many_to_one sql: LEFT JOIN UNNEST(${medicationrequest__specimen__identifier__type.coding}) as medicationrequest__specimen__identifier__type__coding ;; }
# join: medicationrequest__subject { relationship: many_to_one sql: LEFT JOIN UNNEST([${medicationrequest.subject}]) as medicationrequest__subject ;; }
# join: medicationrequest__subject__identifier { relationship: many_to_one sql: LEFT JOIN UNNEST([${medicationrequest__subject.identifier}]) as medicationrequest__subject__identifier ;; }
# join: medicationrequest__subject__identifier__assigner { relationship: many_to_one sql: LEFT JOIN UNNEST([${medicationrequest__subject__identifier.assigner}]) as medicationrequest__subject__identifier__assigner ;; }
# join: medicationrequest__subject__identifier__period { relationship: many_to_one sql: LEFT JOIN UNNEST([${medicationrequest__subject__identifier.period}]) as medicationrequest__subject__identifier__period ;; }
# join: medicationrequest__subject__identifier__type { relationship: many_to_one sql: LEFT JOIN UNNEST([${medicationrequest__subject__identifier.type}]) as medicationrequest__subject__identifier__type ;; }
# join: medicationrequest__subject__identifier__assigner__identifier { relationship: many_to_one sql: LEFT JOIN UNNEST([${medicationrequest__subject__identifier__assigner.identifier}]) as medicationrequest__subject__identifier__assigner__identifier ;; }
# join: medicationrequest__subject__identifier__assigner__identifier__assigner { relationship: many_to_one sql: LEFT JOIN UNNEST([${medicationrequest__subject__identifier__assigner__identifier.assigner}]) as medicationrequest__subject__identifier__assigner__identifier__assigner ;; }
# join: medicationrequest__subject__identifier__assigner__identifier__period { relationship: many_to_one sql: LEFT JOIN UNNEST([${medicationrequest__subject__identifier__assigner__identifier.period}]) as medicationrequest__subject__identifier__assigner__identifier__period ;; }
# join: medicationrequest__subject__identifier__assigner__identifier__type { relationship: many_to_one sql: LEFT JOIN UNNEST([${medicationrequest__subject__identifier__assigner__identifier.type}]) as medicationrequest__subject__identifier__assigner__identifier__type ;; }
# join: medicationrequest__subject__identifier__assigner__identifier__type__coding { relationship: many_to_one sql: LEFT JOIN UNNEST(${medicationrequest__subject__identifier__assigner__identifier__type.coding}) as medicationrequest__subject__identifier__assigner__identifier__type__coding ;; }
# join: medicationrequest__subject__identifier__type__coding { relationship: many_to_one sql: LEFT JOIN UNNEST(${medicationrequest__subject__identifier__type.coding}) as medicationrequest__subject__identifier__type__coding ;; }
# join: medicationrequest__text { relationship: many_to_one sql: LEFT JOIN UNNEST([${medicationrequest.text}]) as medicationrequest__text ;; }
