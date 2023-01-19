
###########
## Analytics View  ##
###########

view: analytics {

##################
### Encounter Dates & Lenth of Stay
##################

  dimension_group: admission {
    description: "Time when encounter starts"
    label: "Encounter Start"
    type: time
    timeframes: [
      raw,
      time,
      minute,
      hour,
      hour_of_day,
      date,
      day_of_week,
      week,
      month,
      quarter,
      year
    ]
    # sql: ${nested_structs.encounter__period__start_raw} ;;
    # NOTE : Syntheia data only goes to Sept 2019 - update date filter to push that to today
    sql: TIMESTAMP_ADD(cast(${nested_structs.encounter__period__start_raw} as timestamp), INTERVAL DATE_DIFF(current_date(), '2019-09-15', day) day) ;;
  }

  dimension_group: discharge {
    description: "Time when encounter ends"
    label: "Encounter End"
    type: time
    timeframes: [
      raw,
      time,
      hour,
      hour_of_day,
      date,
      day_of_week,
      week,
      month,
      quarter,
      year
    ]
    # sql: ${nested_structs.encounter__period__end_raw} ;;
    # NOTE : Syntheia data only goes to Sept 2019 - update date filter to push that to today
    sql: TIMESTAMP_ADD(cast(${nested_structs.encounter__period__end_raw} as timestamp), INTERVAL DATE_DIFF(current_date(), '2019-09-15', day) day) ;;
  }

  dimension_group: length_of_stay_x {
    hidden: yes
    description: "Length of hospital stay"
    type: duration
    sql_start: ${admission_raw} ;;
    sql_end: ${discharge_raw} ;;
    intervals: [
      minute,
      hour,
      day,
      week,
      month,
      year
    ]
  }

  dimension: length_of_stay_day {
    type: number
    sql: date_diff(${discharge_date},${admission_date},day) ;;
  }

  measure: average_length_of_stay {
    type: average
    sql: ${length_of_stay_day} ;;
  }

##################
### Patient Information
##################

  dimension: patient_age {
    group_label: "Patient Information"
    label: "Patient Age"
    sql: date_diff(current_date, ${patient.birth_date}, year) ;;
    drill_fields: [patient_gender, patient_postal_code]
  }
  dimension: patient_age_color {
    group_label: "Patient Information"
    label: "Patient Age (Color)"
    description: "<50 is green, 50-70 orange, 70+ red"
    sql: ${patient_age} ;;
    drill_fields: [patient_gender, patient_postal_code]
    html:
      {%    if value > 70 %} <font color="red">{{ rendered_value }}</font>
      {% elsif value > 50 %} <font color="orange">{{ rendered_value }}</font>
      {% elsif value > 0 %} <font color="green">{{ rendered_value }}</font>
      {% else %} <font color="black">{{ rendered_value }}</font>
      {% endif %} ;;
  }
  measure: min_age {
    group_label: "Z - Island Hop Exercise"
    type: min
    sql: ${patient_age} ;;
  }
  dimension: patient_age_tier {
    group_label: "Patient Information"
    label: "Patient Age Tier"
    description: "Patients Age - <10 YO, 10-20 YO, 20s, 30s, 40s, 50s, 60s, 70s, 80s, 90s"
    type: tier
    tiers: [10,20,30,40,50,60,70,80,90]
    style: integer
    sql: ${patient_age} ;;
    drill_fields: [patient_age, patient_gender, patient_postal_code]
  }

  dimension: patient_gender {
    group_label: "Patient Information"
    label: "Patient Gender"
    sql: ${patient.gender} ;;
    drill_fields: [patient_age_tier, patient_postal_code]
  }
  measure: min_gender {
    group_label: "Z - Island Hop Exercise"
    type: min
    sql: ${patient_gender} ;;
  }

  dimension: patient_name {
    group_label: "Patient Information"
    label: "Patient Name"
    sql: concat(substr(${patient__name__given.patient__name__given},1,length(${patient__name__given.patient__name__given})-3), ' ',substr(${patient__name.family},1,length(${patient__name.family})-3)) ;;
    link: {
      label: "{{ value }} - Deep Dive"
      url: "/dashboards/15?Patient%20Name={{ value }}"
      icon_url: "http://www.google.com/s2/favicons?domain=www.looker.com"
    }
    action: {
      label: "Text Patient about Appointment"
      url: "https://desolate-refuge-53336.herokuapp.com/posts"
      icon_url: "https://www.google.com/s2/favicons?domain_url=http://www.zappier.com"
      param: {
        name: "some_auth_code"
        value: "abc123456"
      }
      form_param: {
        name: "Phone Number"
        required: yes
        default: "{{ patient_telephone._value }}"
      }
      form_param: {
        name: "Body"
        type: textarea
        required: yes
        default:
        "Hi {{ value }} - You have an appt coming up soon. Reply with 1 to confirm your appt, 2 to cancel your appt.
        - {{ practitioner_name._value }}"
      }
    }
    action: {
      label: "Create Telehealth Ticket"
      url: "https://desolate-refuge-53336.herokuapp.com/posts"
      icon_url: "https://www.google.com/s2/favicons?domain_url=http://www.servicenow.com"
      param: {
        name: "some_auth_code"
        value: "abc123456"
      }
      form_param: {
        type: select
        name: "Team"
        option: {
          name: "Medical Records Error"
        }
        option: {
          name: "Provider Escalation"
        }
        option: {
          name: "Other"
        }
        required: yes
        default: "Provider Escalation"
      }
      form_param: {
        type: select
        name: "Priority"
        option: {
          name: "P1 - High"
        }
        option: {
          name: "P2 - Medium"
        }
        option: {
          name: "P3 - Low"
        }
        required: yes
        default: "P1 - High"
      }
      form_param: {
        name: "Ticket Description"
        type: textarea
        required: yes
        default:
        "Hi team -
        We need to review {{ value }}'s case.
        - {{ practitioner_name._value }}"
      }
    }
  }

  # dimension: covid_status {
  #   type: string
  #   sql: ${asldkfjasdlfkjasdlfkj} ;;
  # }

##################
### Patient Location
##################

  dimension: patient_city {
    group_label: "Patient Location"
    label: "Patient City"
    sql: ${patient__address.city} ;;
    drill_fields: [patient_location]
  }

  dimension: patient_postal_code {
    group_label: "Patient Location"
    label: "Patient Zip"
    sql: ${patient__address.postal_code} ;;
    map_layer_name: us_zipcode_tabulation_areas
    drill_fields: [patient_age_tier, patient_gender, patient_location]
  }

  dimension: patient_location {
    group_label: "Patient Location"
    label: "Patient Location"
    type: location
    sql_latitude: ${nested_structs.patient__address__geolocation__latitude__value__decimal} ;;
    sql_longitude: ${nested_structs.patient__address__geolocation__longitude__value__decimal} ;;
    map_layer_name: us_zipcode_tabulation_areas
  }

  measure: min_postal_code {
    group_label: "Z - Island Hop Exercise"
    type: min
    sql: ${patient_postal_code} ;;
  }

  dimension: patient_state {
    group_label: "Patient Location"
    label: "Patient State"
    sql: ${patient__address.state} ;;
  }

  measure: min_state {
    group_label: "Z - Island Hop Exercise"
    type: min
    sql: ${patient_state} ;;
  }

  dimension: patient_birth_country {
    group_label: "Patient Information"
    label: "Patient Birth Country"
    sql: ${nested_structs.patient__birth_place__value__address__country} ;;
  }

  dimension: patient_language {
    group_label: "Patient Information"
    label: "Patient Language"
    sql: ${patient__communication__language__coding.display} ;;
  }

  dimension: patient_telephone {
    group_label: "Patient Information"
    label: "Patient Telephone"
    sql: ${patient__telecom.value} ;;
    type: string
  }

  dimension: patient_race {
    group_label: "Patient Information"
    label: "Patient Race"
    sql: ${nested_structs.patient__us_core_race__omb_category__value__coding__display} ;;
    type: string
  }

##################
### Patient Status
##################

  dimension: is_married {
    group_label: "Patient Information"
    sql:
      case
        when ${patient__marital_status__coding.display} = 'M' then 'Married'
        when ${patient__marital_status__coding.display} = 'S' then 'Single'
        else ${patient__marital_status__coding.display}
      end
        ;;
  }

##################
### Location
##################

  dimension: organization_name {
    group_label: "Hospital Information"
    label: "Hospital Name"
    description: "Name of hospital where encounter occurrred"
    sql: ${organization.name} ;;
    drill_fields: [practitioner_name, patient_age_tier, patient_postal_code]
    link: {
      label: "{{ value }} - Deep Dive"
      url: "/dashboards/13?Facility%20Name={{ value }}"
      icon_url: "http://www.google.com/s2/favicons?domain=www.looker.com"
    }
    link: {
      label: "{{ value }} - Vulnerability Score & SDOH"
      url: "/dashboards/12?Hospital%20Name={{ value }}"
      icon_url: "http://www.google.com/s2/favicons?domain=www.looker.com"
    }
    link: {
      label: "{{ value }} - Google News Search"
      url: "https://news.google.com/search?q={{ value }}%20cleveland clinic"
      icon_url: "http://www.google.com/s2/favicons?domain=www.news.google.com"
    }
    action: {
      label: "Call Hospital with Question"
      url: "https://desolate-refuge-53336.herokuapp.com/posts"
      icon_url: "https://www.google.com/s2/favicons?domain_url=http://www.zappier.com"
      param: {
        name: "some_auth_code"
        value: "abc123456"
      }
      # form_param: {
      #   name: "Phone Number"
      #   required: yes
      #   default: "{{ organization_telephone._value }}"
      # }
    }
  }
  measure: min_organization_name {
    group_label: "Z - Island Hop Exercise"
    type: min
    sql: ${organization_name} ;;
  }

  dimension: organization_city {
    group_label: "Hospital Information"
    label: "Hospital City"
    sql: ${organization__address.city} ;;
    drill_fields: [patient_location]
  }

  dimension: organization_postal_code {
    group_label: "Hospital Information"
    label: "Hospital Zip"
    sql: ${organization__address.postal_code} ;;
    map_layer_name: us_zipcode_tabulation_areas
    drill_fields: [patient_age_tier, patient_gender, patient_location]
  }

  dimension: organization_telephone {
    group_label: "Hospital Information"
    label: "Hospital Telephone"
    sql: ${organization__telecom.value} ;;
    type: string
  }

##################
### Patient Identifier
##################

##################
### Encounter Infomation
##################

  dimension: encounter_type {
    hidden: yes
    type: string
    sql: ${nested_structs.encounter__class__code} ;;
  }

  dimension: encounter_type_format {
    group_label: "Encounter Information"
    label: "Encounter Type"
    description: "Outpatient, Inpatient, Emergency Department"
    sql:
      case
        when ${encounter_type} = 'AMB' then 'Outpatient'
        when ${encounter_type} = 'EMER' then 'Emergency'
        when ${encounter_type} = 'IMP' then 'Inpatient'
      end ;;
    type: string
  }

  dimension: encounter_code {
    group_label: "Encounter Information"
    label: "Encounter Code"
    description: "SNOMED-CT code for visit"
    sql: ${encounter__type__coding.code};;
    type: string
  }

  dimension: encounter_reason_for_visit {
    group_label: "Encounter Information"
    label: "Encounter Type Detail"
    description: "Name for SNOMED-CT reason for visit code for visit"
    sql: ${encounter__type__coding.display};;
    type: string
  }

##################
### Practitioner Identifier
##################

  dimension: practitioner_name {
    group_label: "Practitioner Identifier"
    sql: concat('Dr. ', substr(${practitioner__name__given.practitioner__name__given},1,length(${practitioner__name__given.practitioner__name__given})-3), ' ', substr(${practitioner__name.family},1,length(${practitioner__name.family})-3))  ;;
    # sql: concat(substr(${patient__name.family},1,length(${patient__name.family})-3), ', ',substr(${patient__name__given.patient__name__given},1,length(${patient__name__given.patient__name__given})-3)) ;;
    link: {
      label: "{{ value }} Deep Dive"
      url: "/dashboards/14?Provider%20Name={{ value }}"
      icon_url: "http://www.google.com/s2/favicons?domain=www.looker.com"
    }
    link: {
      label: "{{ value }} - Google News Search"
      url: "https://news.google.com/search?q={{ value }}%20cleveland clinic"
      icon_url: "http://www.google.com/s2/favicons?domain=www.news.google.com"
    }
  }
  measure: min_practitioner_name {
    group_label: "Z - Island Hop Exercise"
    type: min
    sql: ${practitioner_name} ;;
  }

##################
### Observation Information
##################

##################
### Condition Information
##################

  dimension: comorbidity_code {
    group_label: "Comorbidity Information"
    label: "Comorbidity Code"
    description: "SNOMED-CT code for Comorbidity"
    sql: ${condition__code__coding.code};;
    type: string
  }

  dimension: comorbidity_name {
    group_label: "Comorbidity Information"
    label: "Comorbidity Name"
    description: "Name for SNOMED-CT Comorbidity"
    sql: ${condition__code__coding.display};;
    type: string
  }

##################
### Procedure Information
##################

  dimension: procedure_code {
    group_label: "Procedure Information"
    label: "Procedure Code"
    description: "SNOMED-CT code for Procedure"
    sql: ${procedure__code__coding.code};;
    type: string
  }

  dimension: procedure_name {
    group_label: "Procedure Information"
    label: "Procedure Name"
    description: "Name for SNOMED-CT Procedure"
    sql: ${procedure__code__coding.display};;
    type: string
  }

  dimension: procedure_reason {
    group_label: "Procedure Information"
    label: "Procedure Reason"
    description: "Reason for Procedure"
    sql: ${procedure__reason_reference.display};;
    type: string
  }

##################
### Pivot Value
##################

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
    allowed_value: {
      label: "Patient Age Tier"
      value: "patient_age_tier"
    }
    allowed_value: {
      label: "Patient Race"
      value: "patient_race"
    }
  }

  dimension: pivot_value {
    label: " Pivot Value"
    description: "Choose between selecting hospital name, doctor NPI, patient zip, or patient age tier"
    sql:
    {% if    pivot._parameter_value == 'organization_name' %} ${organization_name}
    {% elsif pivot._parameter_value == 'practitioner_name' %} ${practitioner_name}
    {% elsif pivot._parameter_value == 'patient_postal_code' %} ${patient_postal_code}
    {% elsif pivot._parameter_value == 'patient_age_tier' %} ${patient_age_tier}
    {% elsif pivot._parameter_value == 'patient_race' %} ${patient_race}
    {% else %} ${organization_name}
    {% endif %}
    ;;
  }


##################
### Vitals Readings
##################

  dimension: weight_kg {
    group_label: "Patient Vitals"
    label: "Weight (kg)"
    sql: ${identifier_observation_kg.value} ;;
    value_format_name: decimal_1
    html: {{ rendered_value }} kg ;;
  }
  dimension: weight_lb {
    group_label: "Patient Vitals"
    label: "Weight (lb)"
    type: number
    sql: ${identifier_observation_kg.value} * (2.20462) ;;
    value_format_name: decimal_1
    html: {{ rendered_value }} lb ;;
  }
  dimension: height_cm {
    group_label: "Patient Vitals"
    label: "Height (cm)"
    type: number
    sql: ${identifier_observation_cm.value} ;;
    value_format_name: decimal_1
    html: {{ rendered_value }} cm ;;
  }
  dimension: height_m {
    group_label: "Patient Vitals"
    label: "Height (m)"
    type: number
    sql: ${identifier_observation_cm.value} * (0.01) ;;
    value_format_name: decimal_1
    html: {{ rendered_value }} m ;;
  }
  dimension: height_in {
    group_label: "Patient Vitals"
    label: "Height (in)"
    type: number
    sql: ${identifier_observation_cm.value} * (0.393701) ;;
    value_format_name: decimal_1
    html: {{ rendered_value }} in ;;
  }
  dimension: height_ft {
    group_label: "Patient Vitals"
    label: "Height (ft)"
    type: number
    sql: ${identifier_observation_cm.value} * (0.0328084) ;;
    value_format_name: decimal_1
    html: {{ rendered_value }} ft ;;
  }
  dimension: bmi {
    group_label: "Patient Vitals"
    label: "BMI"
    description: "Weight in kg / (height in m) ^ 2 "
    type: number
    sql: ${identifier_observation_bmi.value} ;;
    value_format_name: decimal_1
    html: {{ rendered_value }} BMI ;;
  }
  measure: min_bmi {
    group_label: "Z - Island Hop Exercise"
    type: average
    sql: ${bmi} ;;
  }
  dimension: bmi_weight_tier {
    group_label: "Patient Vitals"
    label: "BMI (Weight Tier)"
    description: "BMI: <18.5 Underweight, 18.5-25 Normal, 25-30 Overweight, 30-35 Obesity Class 1, 35-40 Obsesity Class 2, >40 Extreme Obesity"
    type: string
    sql:
      CASE
        WHEN ${bmi} < 18.5 then '1 - Underweight'
        WHEN ${bmi} >= 18.5 AND ${bmi} < 25 then '2 - Normal Weight'
        WHEN ${bmi} >= 25 AND ${bmi} < 30 then '3 - Overweight'
        WHEN ${bmi} >= 30 AND ${bmi} < 35 then '4 - Obesity Class 1'
        WHEN ${bmi} >= 35 AND ${bmi} < 40 then '5 - Obesity Class 2'
        WHEN ${bmi} >= 40 then '6 - Extreme Obesity / Class 3'
      END
    ;;
  }
  dimension: bmi_weight_tier_color {
    group_label: "Patient Vitals"
    label: "BMI (Weight Tier) (Color)"
    description: "BMI: <18.5 Underweight, 18.5-25 Normal, 25-30 Overweight, 30-35 Obesity Class 1, 35-40 Obsesity Class 2, >40 Extreme Obesity"
    sql: ${bmi_weight_tier} ;;
    html:
      {%    if value == '6 - Extreme Obesity / Class 3' or value == '5 - Obesity Class 2' or value == '4 - Obesity Class 1' %} <font color="red">{{ rendered_value }}</font>
      {% elsif value == '3 - Overweight' or value == '1 - Underweight' %} <font color="orange">{{ rendered_value }}</font>
      {% elsif value == '2 - Normal Weight' %} <font color="green">{{ rendered_value }}</font>
      {% else %} <font color="black">{{ rendered_value }}</font>
      {% endif %} ;;
  }
  dimension: is_obese {
    group_label: "Patient Vitals"
    label: "Is Obese"
    description: "BMI >30"
    type: yesno
    sql: ${bmi} >= 30 ;;
  }
  dimension: is_known_bmi {
    hidden: yes
    type: yesno
    sql: ${bmi} is not null ;;
  }

  measure: average_weight_kg {
    group_label: "Patient Vitals"
    label: "Average Weight (kg)"
    type: average
    sql: ${weight_kg} ;;
    # sql: ${observation__value__quantity.value} ;;
    # filters: [observation__value__quantity.unit: "kg"]
    value_format_name: decimal_1
    html: {{ rendered_value }} kg ;;
    drill_fields: [drill*]
  }

  measure: average_weight_lb {
    group_label: "Patient Vitals"
    label: "Average Weight (lb)"
    type: average
    sql: ${weight_lb} ;;
    # sql: ${average_weight_kg} * (1/2.20462) ;;
    value_format_name: decimal_1
    html: {{ rendered_value }} lb ;;
    drill_fields: [drill*]
  }

  measure: average_height_cm {
    group_label: "Patient Vitals"
    label: "Average Height (cm)"
    type: average
    sql: ${height_cm} ;;
    # sql: ${observation__value__quantity.value} ;;
    # filters: [observation__value__quantity.unit: "cm"]
    value_format_name: decimal_1
    html: {{ rendered_value }} cm ;;
    drill_fields: [drill*]
  }

  measure: average_height_m {
    group_label: "Patient Vitals"
    label: "Average Height (m)"
    type: average
    sql: ${height_m} ;;
    # sql: ${average_height_cm} * (1/0.01) ;;
    value_format_name: decimal_1
    html: {{ rendered_value }} m ;;
    drill_fields: [drill*]
  }

  measure: average_weight_in {
    group_label: "Patient Vitals"
    label: "Average Height (in)"
    type: average
    sql: ${height_in} ;;
    # sql: ${average_height_cm} * (1/0.393701) ;;
    value_format_name: decimal_1
    html: {{ rendered_value }} in ;;
    drill_fields: [drill*]
  }

  measure: average_weight_ft {
    group_label: "Patient Vitals"
    label: "Average Height (ft)"
    type: average
    sql: ${height_ft} ;;
    # sql: ${average_height_cm} * (1/0.0328084) ;;
    value_format_name: decimal_1
    html: {{ rendered_value }} ft ;;
    drill_fields: [drill*]
  }

  measure: average_bmi {
    group_label: "Patient Vitals"
    label: "Average BMI"
    description: "Average weight in kg / (height in m) ^ 2 "
    type: average
    sql: ${bmi} ;;
    value_format_name: decimal_1
    html: {{ rendered_value }} BMI ;;
    drill_fields: [drill*]
  }

##################
### Overall Counts
##################

  measure: count_total_patients {
    group_label: "Overall Count"
    type: count_distinct
    sql: ${nested_structs.encounter__subject__patient_id} ;;
    drill_fields: [drill*]
  }
  measure: count_total_encounters {
    group_label: "Overall Count"
    type: count_distinct
    sql: ${encounter.id} ;;
    drill_fields: [drill*]
  }
  measure: count_total_practitioners {
    group_label: "Overall Count"
    type: count_distinct
    sql: ${nested_structs.encounter__participant__individual__practitioner_id} ;;
    drill_fields: [drill*]
  }

##################
### Length of Stay (Inpatient)
##################

  # measure: length_of_stay_hours {
  #   group_label: "Duration - Length of Stay (Inpatient)"
  #   label: "Length of Stay (Hours)"
  #   description: "How many hours did an inpatient stay last?"
  #   hidden: yes
  #   type: average
  #   sql: ${hours_length_of_stay} ;;
  #   filters: [encounter_type: "IMP"]
  #   drill_fields: [drill*]
  # }

  # measure: length_of_stay_days {
  #   group_label: "Duration - Length of Stay (Inpatient)"
  #   label: "Length of Stay (Days)"
  #   description: "How many days did an inpatient stay last?"
  #   hidden: yes
  #   type: average
  #   sql: ${days_length_of_stay} ;;
  #   filters: [encounter_type: "IMP"]
  #   drill_fields: [drill*]
  # }

  # measure: length_of_stay_weeks {
  #   group_label: "Duration - Length of Stay (Inpatient)"
  #   label: "Length of Stay (Weeks)"
  #   description: "How many weeks did an inpatient stay last?"
  #   hidden: yes
  #   type: average
  #   sql: ${weeks_length_of_stay} ;;
  #   filters: [encounter_type: "IMP"]
  #   drill_fields: [drill*]
  # }

##################
### Visit Duration (Office Visit)
##################

  # measure: office_visit_minutes {
  #   group_label: "Duration - Visit Duration (Office Visit)"
  #   label: "Visit Duration (Minutes)"
  #   description: "How many minutes did an office visit last?"
  #   hidden: yes
  #   type: average
  #   sql: ${minutes_length_of_stay} ;;
  #   filters: [encounter_type: "AMB"]
  #   drill_fields: [drill*]
  # }

  # measure: office_visit_hours {
  #   group_label: "Duration - Visit Duration (Office Visit)"
  #   label: "Visit Duration (Hours)"
  #   description: "How many hours did an office visit stay last?"
  #   hidden: yes
  #   type: average
  #   sql: ${hours_length_of_stay} ;;
  #   filters: [encounter_type: "AMB"]
  #   drill_fields: [drill*]
  # }

  # measure: office_visit_days {
  #   group_label: "Duration - Visit Duration (Office Visit)"
  #   label: "Visit Duration (Days)"
  #   description: "How many days did an office visit stay last?"
  #   hidden: yes
  #   type: average
  #   sql: ${days_length_of_stay} ;;
  #   filters: [encounter_type: "AMB"]
  #   drill_fields: [drill*]
  # }

##################
### Overall COVID Count
##################

## COVID Filter
#   parameter: covid_status_selector {
#     label: "COVID Status"
#     type: unquoted
#     default_value: "all_patients"
#     allowed_value: { label: "All Patients" value: "all_patients" }
#     # allowed_value: { label: "Confirmed or Suspected" value: "confirmed_or_suspected" }
#     allowed_value: { label: "Confirmed" value: "confirmed" }
#     allowed_value: { label: "Suspected" value: "suspected" }
#   }
#   dimension: covid_suspected_yn_filter {
#     hidden: yes
#     type: yesno
#     sql: ${condition__code__coding.code} in ${covid_suspected_set} ;;
#   }
#   dimension: covid_confirmed_yn_filter {
#     hidden: yes
#     type: yesno
#     sql: ${condition__code__coding.code} in ${covid_confirmed_set} ;;
#   }

## Count Suspected

  dimension: covid_suspected_set {
    hidden: yes
    type: string
    sql: '82423001', '196416002', '10509002', '233604007', '444814009', '195662009', '43878008', '162864005' ;;
  }

  dimension: covid_suspected_yn {
    group_label: "COVID"
    label: "COVID - Suspected"
    # description: "Has a ICD10 condition of Z20.828"
    type: yesno
    sql: ${condition__code__coding.code} in ${covid_suspected_set} ;;
  }

  measure: count_covid_suspected {
    group_label: "COVID"
    label: "# COVID Patients (Suspected)"
    # description: "# Patients suspected of having COVID (w/ ICD10 condition of Z20.828)"
    type: count_distinct
    sql: ${nested_structs.encounter__subject__patient_id} ;;
    filters: [covid_suspected_yn: "Yes"]
    drill_fields: [drill*]
  }

## Count Confirmed

  dimension: covid_confirmed_set {
    hidden: yes
    type: string
    sql: '53741008', '239873007', '428251008', '124171000119105', '72892002', '44465007', '65363002' ;;
  }

  dimension: covid_confirmed_yn {
    group_label: "COVID"
    label: "COVID - Confirmed"
    # description: "Has a ICD10 condition of R68.89 or U07.1"
    type: yesno
    sql: ${condition__code__coding.code} in ${covid_confirmed_set} ;;
  }

  measure: count_covid_confirmed {
    group_label: "COVID"
    label: "# COVID Patients (Confirmed)"
    # description: "# Patients confirmed w/ COVID (w/ ICD10 condition of R68.89 or U07.1)"
    type: count_distinct
    sql: ${nested_structs.encounter__subject__patient_id} ;;
    filters: [covid_confirmed_yn: "Yes"]
    drill_fields: [drill*]
  }

## Count Confirmed or Suspected

  dimension: covid_confirmed_suspected_yn {
    group_label: "COVID"
    label: "COVID - Confirmed or Suspected"
    # description: "Has a ICD10 condition of R68.89 or U07.1 or Z20.828"
    type: yesno
    sql: ${condition__code__coding.code} in ${covid_suspected_set} OR ${condition__code__coding.code} in ${covid_confirmed_set} ;;
  }

  measure: count_covid_confirmed_suspected {
    group_label: "COVID"
    label: "# COVID Patients (Confirmed or Suspected)"
    # description: "# Patients confirmed w/ COVID (w/ ICD10 condition of R68.89 or U07.1 or Z20.828)"
    type: count_distinct
    sql: ${nested_structs.encounter__subject__patient_id} ;;
    filters: [covid_confirmed_suspected_yn: "Yes"]
    drill_fields: [drill*]
  }

## Status

  dimension: covid_status {
    group_label: "COVID"
    label: "COVID Status"
    description: "COVID suspected (Z20.828), confirmed (R68.89 or U07.1) or other"
    type: string
    sql:
      case
        when ${covid_confirmed_yn} then 'Confirmed'
        when ${covid_suspected_yn} then 'Suspected'
        else 'Not Suspected'
      end
        ;;
    html:
    {%    if value == 'Confirmed' %} <font color="red">{{ rendered_value }}</font>
    {% elsif value == 'Suspected' %} <font color="orange">{{ rendered_value }}</font>
    {% else %} <font color="black">{{ rendered_value }}</font>
    {% endif %} ;;
  }

##################
### Encounters
##################

## ED Visits

  measure: count_ed_visits {
    group_label: "Encounters"
    label: "# Encounters - ED Visits"
    # description: "# Encounters to emergency department (contacttype = 553)"
    type: count_distinct
    sql: ${encounter.id} ;;
    filters: [encounter_type: "EMER"]
    drill_fields: [drill*]
  }

## Office visits (outpatient)

  measure: count_office_visit {
    group_label: "Encounters"
    label: "# Encounters - Office Visits"
    # description: "# Encounters to office visits (contacttype = 50, 101, 710, 630)"
    type: count_distinct
    sql: ${encounter.id} ;;
    filters: [encounter_type: "AMB"]
    drill_fields: [drill*]
  }

## of Inpatient Visits

  measure: count_inpatient_visit {
    group_label: "Encounters"
    label: "# Encounters - Inpatient Visits"
    # description: "# Encounters to inpatient visits (class.code = 3, 106)"
    type: count_distinct
    sql: ${encounter.id} ;;
    filters: [encounter_type: "IMP"]
    drill_fields: [drill*]
  }

##################
### Status - Stage
##################

  measure: count_patient_death {
    group_label: "Status - Stage"
    label: "# Patients - Died"
    # description: "# Patients who died (had dischdisposition = 20)"
    type: count_distinct
    sql: ${encounter.id} ;;
    filters: [encounter_code: "308646001, 185347001"]
    drill_fields: [drill*]
  }

  measure: count_patient_home_healthcare {
    group_label: "Status - Stage"
    label: "# Patients - Home Healthcare"
    # description: "# Patients who died (had dischdisposition = 20)"
    type: count_distinct
    sql: ${encounter.id} ;;
    filters: [encounter_code: "308540004, 305408004"]
    drill_fields: [drill*]
  }

  measure: count_patient_snf {
    group_label: "Status - Stage"
    label: "# Patients - SNF"
    # description: "# Patients who died (had dischdisposition = 20)"
    type: count_distinct
    sql: ${encounter.id} ;;
    filters: [encounter_code: "183495009, 183452005, 185347001"]
    drill_fields: [drill*]
  }

  measure: count_staffed_bed_encounters {
    group_label: "Status - Stage"
    label: "# Patients - Staffed Bed"
    # description: "# Patients who died (had dischdisposition = 20)"
    type: count_distinct
    sql: ${encounter.id} ;;
    filters: [encounter_code: "-56876005"]
    drill_fields: [drill*]
  }

  measure: count_icu_bed_encounters {
    group_label: "Status - Stage"
    label: "# Patients - ICU Bed"
    # description: "# Patients who died (had dischdisposition = 20)"
    type: count_distinct
    sql: ${encounter.id} ;;
    filters: [encounter_code: "56876005"]
    drill_fields: [drill*]
  }




##################
### Comorbidities
##################

  dimension: comorbidity_exists {
    hidden: yes
    type: yesno
    sql: ${condition__code__coding.code} is not null ;;
  }

  dimension: comorbidity_asthma_yn {
    hidden: yes
    type: string
    sql: '233678006', '195967001' ;;

  }

  dimension: comorbidity_asthma {
    group_label: "Comorbidities"
    label: "Comorbidity - Has Asthma"
    # description: "Has Asthma (ICD10 code = J44.1, J45.901, J45.21, J45.20, J45.40, J45.41, J45.50, J45.51, J45,52, J45.909"
    type: yesno
    sql: ${condition__code__coding.code} in ${comorbidity_asthma_yn} ;;
    html:
        {%    if value == 'Yes' %} <font color="red">{{ rendered_value }}</font>
        {% else %} <font color="black">{{ rendered_value }}</font>
        {% endif %} ;;
  }

  measure: count_comorbidity_asthma {
    group_label: "Comorbidities"
    label: "# Patients w/ Asthma"
    description: "# Patients confirmed w/ Asthma (w/ ICD10 condition of J44.1, J45.901, J45.21, J45.20, J45.40, J45.41, J45.50, J45.51, J45,52, J45.909)"
    type: count_distinct
    sql: ${nested_structs.encounter__subject__patient_id} ;;
    filters: [comorbidity_asthma: "Yes"]
    drill_fields: [drill*]
  }

  dimension: comorbidity_copd_yn {
    hidden: yes
    type: string
    sql: '87433001', '162573006' ;;
  }

  dimension: comorbidity_copd {
    group_label: "Comorbidities"
    label: "Comorbidity - Has COPD"
    description: "Has COPD (ICD10 code = J44.9, J44.1, J44.0"
    type: yesno
    sql: ${condition__code__coding.code} in ${comorbidity_copd_yn} ;;
    html:
    {%    if value == 'Yes' %} <font color="red">{{ rendered_value }}</font>
    {% else %} <font color="black">{{ rendered_value }}</font>
    {% endif %} ;;
  }

  measure: count_comorbidity_copd {
    group_label: "Comorbidities"
    label: "# Patients w/ COPD"
    description: "# Patients confirmed w/ COPD (w/ ICD10 condition of J44.9, J44.1, J44.0)"
    type: count_distinct
    sql: ${nested_structs.encounter__subject__patient_id} ;;
    filters: [comorbidity_copd: "Yes"]
    drill_fields: [drill*]
  }

  dimension: comorbidity_hypertension_yn {
    hidden: yes
    type: string
    sql: '38341003', '55822004' ;;
  }

  dimension: comorbidity_hypertension {
    group_label: "Comorbidities"
    label: "Comorbidity - Has Hypertension"
    description: "Has Hypertension (ICD10 code = I10"
    type: yesno
    sql: ${condition__code__coding.code} in ${comorbidity_hypertension_yn} ;;
    html:
    {%    if value == 'Yes' %} <font color="red">{{ rendered_value }}</font>
    {% else %} <font color="black">{{ rendered_value }}</font>
    {% endif %} ;;
  }

  measure: count_comorbidity_hypertension {
    group_label: "Comorbidities"
    label: "# Patients w/ Hypertension"
    description: "# Patients confirmed w/ Hypertension (w/ ICD10 condition of I10)"
    type: count_distinct
    sql: ${nested_structs.encounter__subject__patient_id} ;;
    filters: [comorbidity_hypertension: "Yes"]
    drill_fields: [drill*]
  }


  dimension: comorbidity_diabetes_1_yn {
    hidden: yes
    type: string
    sql: '44054006', '427089005' ;;
  }

  dimension: comorbidity_diabetes_1 {
    group_label: "Comorbidities"
    label: "Comorbidity - Has Diabetes Type 1"
    description: "Has Diabetes Type 1 (ICD10 code = E11.9, E10.9"
    type: yesno
    sql: ${condition__code__coding.code} in ${comorbidity_diabetes_1_yn} ;;
    html:
    {%    if value == 'Yes' %} <font color="red">{{ rendered_value }}</font>
    {% else %} <font color="black">{{ rendered_value }}</font>
    {% endif %} ;;
  }

  measure: count_comorbidity_diabetes_1 {
    group_label: "Comorbidities"
    label: "# Patients w/ Diabetes Type 1"
    description: "# Patients confirmed w/ Diabetes Type 1 (w/ ICD10 condition of E11.9, E10.9)"
    type: count_distinct
    sql: ${nested_structs.encounter__subject__patient_id} ;;
    filters: [comorbidity_diabetes_1: "Yes"]
    drill_fields: [drill*]
  }

  dimension: comorbidity_diabetes_2_yn {
    hidden: yes
    type: string
    sql: '15777000', '368581000119106' ;;
  }

  dimension: comorbidity_diabetes_2 {
    group_label: "Comorbidities"
    label: "Comorbidity - Has Diabetes Type 2"
    description: "Has Diabetes Type 2 (ICD10 code = E11.9"
    type: yesno
    sql: ${condition__code__coding.code} in ${comorbidity_diabetes_2_yn} ;;
    html:
    {%    if value == 'Yes' %} <font color="red">{{ rendered_value }}</font>
    {% else %} <font color="black">{{ rendered_value }}</font>
    {% endif %} ;;
  }

  measure: count_comorbidity_diabetes_2 {
    group_label: "Comorbidities"
    label: "# Patients w/ Diabetes Type 2"
    description: "# Patients confirmed w/ Diabetes Type 2 (w/ ICD10 condition of E11.9)"
    type: count_distinct
    sql: ${nested_structs.encounter__subject__patient_id} ;;
    filters: [comorbidity_diabetes_2: "Yes"]
    drill_fields: [drill*]
  }

  dimension: comorbidity_immunocompromised_yn {
    hidden: yes
    type: string
    sql: '254637007', '424132000' ;;
  }

  dimension: comorbidity_immunocompromised {
    group_label: "Comorbidities"
    label: "Comorbidity - Immunocompromised"
    description: "Has Immunocompromised (ICD10 code = D89.9"
    type: yesno
    sql: ${condition__code__coding.code} in ${comorbidity_immunocompromised_yn} ;;
    html:
    {%    if value == 'Yes' %} <font color="red">{{ rendered_value }}</font>
    {% else %} <font color="black">{{ rendered_value }}</font>
    {% endif %} ;;
  }

  measure: count_comorbidity_immunocompromised {
    group_label: "Comorbidities"
    label: "# Patients w/ Immunocompromised"
    description: "# Patients confirmed w/ Immunocompromised (w/ ICD10 condition of D89.9)"
    type: count_distinct
    sql: ${nested_structs.encounter__subject__patient_id} ;;
    filters: [comorbidity_immunocompromised: "Yes"]
    drill_fields: [drill*]
  }

  measure: count_comorbid {
    group_label: "Z - Island Hop Exercise"
    type: number
    sql: ${count_comorbidity_asthma} + ${count_comorbidity_copd} + ${count_comorbidity_hypertension} + ${count_comorbidity_diabetes_1} + ${count_comorbidity_diabetes_2} ;;
  }

##################
### Community COVID Results (NYT / Johns Hopkins Data / COVID Block)
##################

#   measure: confirmed_new {
#     group_label: "Nationwide COVID Results (Johns Hopkins Data)"
#     label: "Confirmed - New Cases"
#     type: number
#     sql: ${covid.confirmed_new} ;;
#     value_format_name: decimal_0
#   }
#
#   measure: confirmed_running_total {
#     group_label: "Nationwide COVID Results (Johns Hopkins Data)"
#     label: "Confirmed - Running Total"
#     type: number
#     sql: ${covid.confirmed_running_total} ;;
#     value_format_name: decimal_0
#   }
#
#   measure: deaths_new {
#     group_label: "Nationwide COVID Results (Johns Hopkins Data)"
#     label: "Deaths - New Cases"
#     type: number
#     sql: ${covid.deaths_new} ;;
#     value_format_name: decimal_0
#   }
#
#   measure: deaths_running_total {
#     group_label: "Nationwide COVID Results (Johns Hopkins Data)"
#     label: "Deatgs - Running Total"
#     type: number
#     sql: ${covid.deaths_running_total} ;;
#     value_format_name: decimal_0
#   }

##################
### Census
##################

  dimension: population_density {
    group_label: "Census / SDOH"
    label: "Population Density"
    description: "# people / per square land mile"
    type: number
    sql: ${acs_zip_codes_2017_5yr.population_density} ;;
    value_format_name: decimal_1
  }

  dimension: zipcode_population_density_tier {
    group_label: "Census / SDOH"
    label: "Population Density (Tier)"
    description: "The population density group - people / square land mile for the zipcode"
    type: tier
    sql: ${population_density} ;;
    tiers: [50,100,500,1000,2000,3000,4000,5000,10000]
    style: integer
  }

  measure: average_population_density {
    group_label: "Census / SDOH"
    label: "Population Density"
    description: "# people / per square land meters"
    type: number
    sql: ${acs_zip_codes_2017_5yr.average_population_density} ;;
    value_format_name: decimal_1
  }

  measure: percent_above_70 {
    group_label: "Census / SDOH"
    label: "% Population >70"
    type: number
    sql: ${acs_zip_codes_2017_5yr.percent_above_70} ;;
    value_format_name: percent_1
  }

  measure: median_income {
    group_label: "Census / SDOH"
    label: "% Poverty"
    description: "% Zip Codes where median income < $30k / year"
    type: number
    sql: ${acs_zip_codes_2017_5yr.average_median_income} ;;
    value_format_name: percent_1
  }

  measure: national_average_population_density {
    group_label: "Census / SDOH"
    label: "Population Density (National Average)"
    description: "# people / per square land meters"
    type: number
    sql: ${national_averages.national_average_population_density} ;;
    value_format_name: decimal_1
  }

  measure: national_percent_above_70 {
    group_label: "Census / SDOH"
    label: "% Population >70 (National Average)"
    type: number
    sql: ${national_averages.national_percent_above_70} ;;
    value_format_name: percent_1
  }

  measure: national_median_income {
    group_label: "Census / SDOH"
    label: "% Poverty (National Average)"
    description: "% Zip Codes where median income < $30k / year"
    type: number
    sql: ${national_averages.national_median_income} ;;
    value_format_name: percent_1
  }

  measure: national_average_population_density_difference {
    group_label: "Census / SDOH"
    label: "Population Density (vs. National Average)"
    description: "# people / per square land meters"
    type: number
    sql: 1.0 * (${average_population_density} - ${national_average_population_density}) / nullif(${national_average_population_density},0) ;;
    value_format_name: percent_1
  }

  measure: national_percent_above_70_difference {
    group_label: "Census / SDOH"
    label: "% Population >70 (vs. National Average)"
    type: number
    sql: 1.0 * (${percent_above_70} - ${national_percent_above_70}) / nullif(${national_percent_above_70},0) ;;
    value_format_name: percent_1
  }

  measure: national_median_income_difference {
    group_label: "Census / SDOH"
    label: "% Poverty (vs. National Average)"
    description: "% Zip Codes where median income < $30k / year"
    type: number
    sql: 1.0 * (${median_income} - ${national_median_income}) / nullif(${national_median_income},0) ;;
    value_format_name: percent_1
  }

##################
### Vulnerability Score
##################

  dimension: vulnerability_is_obese {
    group_label: "Vulnerability Factors"
    label: "Is Obese"
    description: "BMI > 30"
    type: yesno
    sql: ${is_obese} ;;
  }
  dimension: vulnerability_has_comorbidity {
    group_label: "Vulnerability Factors"
    label: "Has Asthma"
    description: "Has Asthma, Diabetes, COPD, or another common comorbidity"
    type: yesno
    sql: ${comorbidity_asthma} OR ${comorbidity_copd} OR ${comorbidity_hypertension} OR ${comorbidity_diabetes_1} OR ${comorbidity_diabetes_2} OR ${comorbidity_immunocompromised} ;;
  }
  dimension: is_over_70 {
    group_label: "Vulnerability Factors"
    label: "Is Over 70"
    type: yesno
    sql: ${patient_age} > 70 ;;
  }

  measure: patients_is_obese {
    group_label: "Vulnerability Factors"
    label: "# Patients - Obese"
    description: "BMI > 30"
    type: count_distinct
    sql: ${nested_structs.encounter__subject__patient_id} ;;
    filters: [vulnerability_is_obese: "Yes"]
    drill_fields: [vulnerability_drill*]
  }

  measure: patients_is_known_bmi {
    hidden: yes
    type: count_distinct
    sql: ${nested_structs.encounter__subject__patient_id} ;;
    filters: [is_known_bmi: "Yes"]
  }
  measure: percent_patients_obese {
    group_label: "Vulnerability Factors"
    label: "% Patients - Obese"
    description: "BMI > 30 (out of total patients with known BMI)"
    type: number
    sql: 1.0*${patients_is_obese} / nullif(${patients_is_known_bmi},0) ;;
    value_format_name: percent_1
    drill_fields: [vulnerability_drill*]
  }

  measure: patients_has_comorbidity {
    group_label: "Vulnerability Factors"
    label: "# Patients - Comorbidity"
    description: "Has Asthma, Diabetes, COPD, or another common comorbidity"
    type: count_distinct
    sql: ${nested_structs.encounter__subject__patient_id} ;;
    filters: [vulnerability_has_comorbidity: "Yes"]
    drill_fields: [vulnerability_drill*]
  }
  measure: patients_has_any_icd10 {
    hidden: yes
    type: count_distinct
    sql: ${nested_structs.encounter__subject__patient_id} ;;
    filters: [comorbidity_exists: "Yes"]
  }
  measure: percent_patients_has_comorbidity {
    group_label: "Vulnerability Factors"
    label: "% Patients - Comorbidity"
    description: "Has Asthma, Diabetes, COPD, or another common comorbidity (out of total patients with any ICD10 code)"
    type: number
    sql: 1.0*${patients_has_comorbidity} / nullif(${patients_has_any_icd10},0) ;;
    value_format_name: percent_1
    drill_fields: [vulnerability_drill*]
  }

  measure: patients_over_70 {
    group_label: "Vulnerability Factors"
    label: "# Patients - Over 70"
    type: count_distinct
    sql: ${nested_structs.encounter__subject__patient_id} ;;
    filters: [is_over_70: "Yes"]
    drill_fields: [vulnerability_drill*]
  }
  measure: percent_patients_over_70 {
    group_label: "Vulnerability Factors"
    label: "% Patients - Over 70"
    type: number
    sql: 1.0*${patients_over_70} / nullif(${count_total_patients},0) ;;
    value_format_name: percent_1
    drill_fields: [vulnerability_drill*]
  }

  parameter: weight_obesity {
    # group_label: "Vulnerability Factors"
    type:  unquoted
    default_value: "2"
  }

  parameter: weight_comorbidity {
    # group_label: "Vulnerability Factors"
    type:  unquoted
    default_value: "4"
  }

  parameter: weight_over_70 {
    # group_label: "Vulnerability Factors"
    type:  unquoted
    default_value: "1"
  }

  measure: vulnerability_score {
    group_label: "Vulnerability Factors"
    label: "Vulnerability Score"
    description: "Weighted average of 3 Vulnerability factors: % population that is obese, % population with a comorbidity, & % population over 70."
    type: number
    value_format_name: percent_1
    sql:
          (
            ${percent_patients_obese} * {% parameter weight_obesity %}
        +   ${percent_patients_has_comorbidity} * {% parameter weight_comorbidity %}
        +   ${percent_patients_over_70} * {% parameter weight_over_70 %}
      ) /   nullif(({% parameter weight_obesity %} + {% parameter weight_comorbidity %} + {% parameter weight_over_70 %}),0)
    ;;
    drill_fields: [vulnerability_drill*]
  }

  set: drill {
    fields: [
      encounter.id,
      practitioner_name,
      patient_name,
      admission_date,
      encounter_type,
      count_total_patients
    ]
  }

  set: vulnerability_drill {
    fields: [
      practitioner_name,
      bmi_weight_tier,
      comorbidity_asthma,
      patient_age
    ]
  }

}

###########
## Fixing nested structs ##
###########

view: nested_structs {

## Encounter

  dimension_group: encounter__period__start {
    group_label: "{{ _view._name }}"
    type: time
    timeframes: [
      raw,
      time,
      date,
      week,
      month,
      quarter,
      year
    ]
    sql: cast(${encounter.period}.start as timestamp) ;;
  }

  dimension_group: encounter__period__end {
    group_label: "{{ _view._name }}"
    type: time
    timeframes: [
      raw,
      time,
      date,
      week,
      month,
      quarter,
      year
    ]
    sql: cast(${encounter.period}.`end` as timestamp) ;;
  }

  dimension: encounter__class__code {
    sql: ${encounter.class}.code ;;
  }

  dimension: encounter__service_provider__organization_id {
    sql: ${encounter.service_provider}.organizationId ;;
  }

  dimension: encounter__subject__patient_id {
    sql: ${encounter.subject}.patientId ;;
  }

  dimension: encounter__identifier__type__coding_code {
    sql: ${encounter__identifier__type.coding}.code ;;
  }

  dimension: encounter__diagnosis__condition__condition_id {
    sql: ${encounter__diagnosis.condition}.conditionID ;;
  }

  dimension: encounter__location__location__location_id {
    sql: ${encounter__location.location}.locationId ;;
  }

  dimension: encounter__participant__individual__practitioner_id {
    sql: ${encounter__participant.individual}.practitionerID ;;
  }
  dimension: encounter__identifier__type__coding {
    sql: ${encounter__identifier.type}.coding ;;
  }

## Condition

  dimension: condition__context__encounter_id {
    hidden: yes
    sql: ${condition.context}.encounterId ;;
  }

  dimension: condition__code__coding {
    sql: ${condition.code}.coding ;;
  }

## Observation

  dimension: observation__context__encounter_id {
    sql: ${observation.context}.encounterId ;;
  }

  dimension: observation__code__coding {
    sql: ${observation.code}.coding ;;
  }

  dimension: observation__value__quantity__value {
    sql: ${observation.value}.quantity.value ;;
  }

  dimension: observation__value__quantity__unit {
    sql: ${observation.value}.quantity.unit ;;
  }

  dimension: observation__value__string {
    sql: ${observation.value}.string ;;
  }

## Patient

  dimension: patient__identifier__type__coding {
    hidden: yes
    sql: ${patient__identifier.type}.coding ;;
  }

  dimension: patient__marital_status__coding {
    hidden: yes
    sql: ${patient.marital_status}.coding ;;
  }

  dimension: patient__deceased__boolean {
    sql: ${patient.deceased}.boolean ;;
  }

  dimension: patient__us_core_race__omb_category__value__coding__display {
    sql: ${patient.us_core_race}.ombCategory.value.coding.display ;;
  }

  dimension: patient__birth_place__value__address__country {
    sql: ${patient.birth_place}.value.address.country ;;
  }

  dimension: patient__communication__language__coding {
    sql: ${patient__communication.language}.coding ;;
  }

  dimension: patient__address__geolocation__latitude__value__decimal {
    sql: ${patient__address.geolocation}.latitude.value.decimal ;;
  }

  dimension: patient__address__geolocation__longitude__value__decimal {
    sql: ${patient__address.geolocation}.longitude.value.decimal ;;
  }

## Practitioner

  dimension: practitioner__identifier__type__coding {
    hidden: yes
    sql: ${practitioner__identifier.type}.coding ;;
  }

## Procedure

  dimension: procedure__context__encounter_id {
    sql: ${procedure.context}.encounterId ;;
  }

  dimension: procedure__code__coding {
    sql: ${procedure.code}.coding ;;
  }

## Organization

}

###########
## Identifer PDTs ##
###########

## Observation

view: identifier_observation_kg {derived_table: {explore_source: fhir_hcls { bind_filters: { from_field: analytics.admission_date to_field: analytics.admission_date } column: id { field: encounter.id } column: value { field: nested_structs.observation__value__quantity__value } filters: {field: observation__code__coding.display value: "Body Weight"}}} dimension: id {} dimension: value {type: number}}
view: identifier_observation_cm {derived_table: {explore_source: fhir_hcls { bind_filters: { from_field: analytics.admission_date to_field: analytics.admission_date } column: id { field: encounter.id } column: value { field: nested_structs.observation__value__quantity__value } filters: {field: observation__code__coding.display value: "Body Height"}}} dimension: id {} dimension: value {type: number}}
view: identifier_observation_bmi {derived_table: {explore_source: fhir_hcls { bind_filters: { from_field: analytics.admission_date to_field: analytics.admission_date } column: id { field: encounter.id } column: value { field: nested_structs.observation__value__quantity__value } filters: {field: observation__code__coding.display value: "Body Mass Index"}}} dimension: id {} dimension: value {type: number}}

###########
## COVID ##
## Source: https://github.com/looker/covid19/blob/master/covid_block/covid_combined.view.lkml
###########

view: covid {
  derived_table: {
    datagroup_trigger: once_daily
    sql:
    WITH covid_zipmapping as (
      SELECT
        b.zcta5 as zip,
        a.province_state as state,
        date,
        sum(confirmed) as confirmed,
        sum(deaths) as deaths,
        sum(recovered) as recovered,
        sum(active) as active
      FROM `bigquery-public-data.covid19_jhu_csse.summary` a
      LEFT JOIN `lookerdata.covid19.zip_to_county_master` b
        ON a.fips = CASE WHEN LENGTH(cast(geoid as string)) = 4 THEN CONCAT('0',geoid) ELSE cast(geoid as string) END
      WHERE country_region = 'US'
      GROUP BY 1,2,3
    )
    SELECT
      zip,
      state,
      date,
      confirmed as confirmed_cumulative,
      confirmed - coalesce(LAG(confirmed, 1) OVER (PARTITION BY concat(coalesce(cast(zip as string),''), coalesce(state,'')) ORDER BY date ASC),0) as confirmed_new_cases,
      deaths as deaths_cumulative,
      deaths - coalesce(LAG(deaths, 1) OVER (PARTITION BY concat(coalesce(cast(zip as string),''), coalesce(state,'')) ORDER BY date ASC),0) as deaths_new_cases,
      recovered as recovered_cumulative,
      recovered - coalesce(LAG(recovered, 1) OVER (PARTITION BY concat(coalesce(cast(zip as string),''), coalesce(state,'')) ORDER BY date ASC),0) as recovered_new_cases,
      active as active_cumulative,
      active - coalesce(LAG(active, 1) OVER (PARTITION BY concat(coalesce(cast(zip as string),''), coalesce(state,'')) ORDER BY date ASC),0) as active_new_cases
    FROM covid_zipmapping
    ;;
  }

####################
#### Original Dimensions ####
####################

  dimension: pk {
    primary_key: yes
    hidden: yes
    type: string
    sql: concat(${zip},${measurement_raw}) ;;
  }

  dimension_group: measurement {
    type: time
    timeframes: [
      raw,
      date,
      week,
      month
    ]
    convert_tz: no
    datatype: date
    sql: ${TABLE}.date ;;
  }

  dimension: zip {
    type: zipcode
    sql: ${TABLE}.zip ;;
    link: {
      label: "{{ value }} - News Search"
      url: "https://news.google.com/search?q={{ value }}%20county%20{{ province_state._value}}%20covid"
      icon_url: "http://www.google.com/s2/favicons?domain_url=http://www.news.google.com"
    }
  }

#### Location ####

  dimension: province_state {
    group_label: "Location"
    description: "Map only configured for US states, but states from other countries are also present in the data"
    label: "State"
    map_layer_name: us_states
    type: string
    sql: ${TABLE}.state ;;
    link: {
      label: "{{ value }} - News Search"
      url: "https://news.google.com/search?q={{ value }}%20covid"
      icon_url: "http://www.google.com/s2/favicons?domain_url=http://www.news.google.com"
    }
  }

#### KPIs ####

  dimension: confirmed_cumulative {
    hidden: yes
    type: number
    sql: ${TABLE}.confirmed_cumulative ;;
  }

  dimension: confirmed_new_cases {
    hidden: yes
    type: number
    sql: ${TABLE}.confirmed_new_cases ;;
  }

  dimension: deaths_cumulative {
    hidden: yes
    type: number
    sql: ${TABLE}.deaths_cumulative ;;
  }

  dimension: deaths_new_cases {
    hidden: yes
    type: number
    sql: ${TABLE}.deaths_new_cases ;;
  }

####################
#### Derived Dimensions ####
####################

  dimension: max_date {
    type: date
    ## Note: if someone picks max date, assume it was 3 days ago
    sql: cast(DATE_ADD(current_date(), INTERVAL -3 day) as timestamp);;
  }

  dimension: is_max_date {
    type: yesno
    sql: ${measurement_raw} = ${max_date} ;;
  }

####################
#### Measures ####
####################

## Let user choose between looking at new cases (active, confirmed, deaths, etc) or running total
  parameter: new_vs_running_total {
    hidden: yes
    description: "Use with the dynamic measures to see either new cases or the running total, can be used to easily toggle between the two on a Look or Dashboard"
    type: unquoted
    default_value: "new_cases"
    allowed_value: {
      label: "New Cases"
      value: "new_cases"
    }
    allowed_value: {
      label: "Running Total"
      value: "running_total"
    }
  }

## Based on new_vs_running_total parameter chosen, return new or running total confirmed cases
  measure: confirmed_cases {
    group_label: "  Dynamic"
    description: "Use with New vs Running Total Filter, can be useful for creating a Look or Dashboard where you toggle between the two"
    label: "Confirmed Cases"
    type: number
    sql:
      {% if new_vs_running_total._parameter_value == 'new_cases' %} ${confirmed_new}
      {% elsif new_vs_running_total._parameter_value == 'running_total' %} ${confirmed_running_total}
      {% endif %} ;;
    drill_fields: [drill*]
    link: {
      label: "Data Source - NYT County Data"
      url: "https://github.com/nytimes/covid-19-data"
      icon_url: "http://www.google.com/s2/favicons?domain_url=http://www.nytimes.com"
    }
    link: {
      label: "Data Source - Johns Hopkins State & Country Data"
      url: "https://github.com/CSSEGISandData/COVID-19"
      icon_url: "http://www.google.com/s2/favicons?domain_url=http://www.jhu.edu"
    }
  }

## Based on new_vs_running_total parameter chosen, return new or running total deaths
  measure: deaths {
    group_label: "  Dynamic"
    description: "Use with New vs Running Total Filter, can be useful for creating a Look or Dashboard where you toggle between the two"
    label: "Deaths"
    type: number
    sql:
      {% if new_vs_running_total._parameter_value == 'new_cases' %} ${deaths_new}
      {% elsif new_vs_running_total._parameter_value == 'running_total' %} ${deaths_running_total}
      {% endif %} ;;
    drill_fields: [drill*]
    link: {
      label: "Data Source - NYT County Data"
      url: "https://github.com/nytimes/covid-19-data"
      icon_url: "http://www.google.com/s2/favicons?domain_url=http://www.nytimes.com"
    }
    link: {
      label: "Data Source - Johns Hopkins State & Country Data"
      url: "https://github.com/CSSEGISandData/COVID-19"
      icon_url: "http://www.google.com/s2/favicons?domain_url=http://www.jhu.edu"
    }
  }

  measure: confirmed_new_option_1 {
    hidden: yes
    type: sum
    sql: ${confirmed_new_cases};;
#     sql: ${confirmed_new_cases}*${puma_conversion_factor} ;;
  }

  measure: confirmed_new_option_2 {
    hidden: yes
    type: sum
    sql: ${confirmed_new_cases};;
#     sql: ${confirmed_new_cases}*${puma_conversion_factor} ;;
    filters: {
      field: is_max_date
      value: "Yes"
    }
  }

  #this field displays the new cases if a date filter has been applied, or else is gives the numbers from the most recent record
  measure: confirmed_new {
    group_label: "  New Cases"
    label: "Confirmed Cases (New)"
    description: "Filter on Measurement Date or Days Since First Outbreak to see the new cases during the selected timeframe, otherwise the sum of all the new cases for each day will be displayed"
    type: number
    sql: ${confirmed_new_option_1};;
# code to instead default to most recenet new confirmed cases:
#       {% if covid_combined.measurement_date._in_query or covid_combined.days_since_first_outbreak._in_query or
#       covid_combined.days_since_max_date._in_query %} ${confirmed_new_option_1}
#        {% else %}  ${confirmed_new_option_2}
#       {% endif %} ;;
    drill_fields: [drill*]
    link: {
      label: "Data Source - NYT County Data"
      url: "https://github.com/nytimes/covid-19-data"
      icon_url: "http://www.google.com/s2/favicons?domain_url=http://www.nytimes.com"
    }
    link: {
      label: "Data Source - Johns Hopkins State & Country Data"
      url: "https://github.com/CSSEGISandData/COVID-19"
      icon_url: "http://www.google.com/s2/favicons?domain_url=http://www.jhu.edu"
    }
  }

  measure: confirmed_option_1 {
    hidden: yes
    type: sum
    sql: ${confirmed_cumulative};;
#     sql: ${confirmed_cumulative}*${puma_conversion_factor} ;;
  }

  measure: confirmed_option_2 {
    hidden: yes
    type: sum
    sql: ${confirmed_cumulative};;
#     sql: ${confirmed_cumulative}*${puma_conversion_factor} ;;
    filters: {
      field: is_max_date
      value: "Yes"
    }
  }

  #this field displays the running total of cases if a date filter has been applied, or else is gives the numbers from the most recent record
  measure: confirmed_running_total {
    group_label: "  Running Total"
    description: "Filter on Measurement Date or Days Since First Outbreak to see the running total on a specific date, don't use with a range of dates or else the results will show the sum of the running totals for each day in that timeframe. If no dates are selected the most recent record will be used."
    label: "Confirmed Cases (Running Total)"
    type: number
    sql:
        {% if covid.measurement_date._in_query or analytics.admission_date._in_query %} ${confirmed_option_1}
        {% else %}  ${confirmed_option_2}
        {% endif %} ;;
    drill_fields: [drill*]
    link: {
      label: "Data Source - NYT County Data"
      url: "https://github.com/nytimes/covid-19-data"
      icon_url: "http://www.google.com/s2/favicons?domain_url=http://www.nytimes.com"
    }
    link: {
      label: "Data Source - Johns Hopkins State & Country Data"
      url: "https://github.com/CSSEGISandData/COVID-19"
      icon_url: "http://www.google.com/s2/favicons?domain_url=http://www.jhu.edu"
    }
  }
  measure: deaths_new_option_1 {
    hidden: yes
    type: sum
    sql: ${deaths_new_cases} ;;
  }

  measure: deaths_new_option_2 {
    hidden: yes
    type: sum
    sql: ${deaths_new_cases} ;;
    filters: {
      field: is_max_date
      value: "Yes"
    }
  }


  #this field displays the new deaths if a date filter has been applied, or else is gives the numbers from the most recent record
  measure: deaths_new {
    group_label: "  New Cases"
    description: "Filter on Measurement Date or Days Since First Outbreak to see the new cases during the selected timeframe, otherwise the sum of all the new cases for each day will be displayed"
    label: "Deaths (New)"
    type: number
    sql:${deaths_new_option_1};;
    # code to instead default to most recenet new confirmed cases:
#       {% if covid_combined.measurement_date._in_query or covid_combined.days_since_first_outbreak._in_query or covid_combined.days_since_max_date._in_query %} ${deaths_new_option_1}
#       {% else %}  ${deaths_new_option_2}
#       {% endif %} ;;
    drill_fields: [drill*]
    link: {
      label: "Data Source - NYT County Data"
      url: "https://github.com/nytimes/covid-19-data"
      icon_url: "http://www.google.com/s2/favicons?domain_url=http://www.nytimes.com"
    }
    link: {
      label: "Data Source - Johns Hopkins State & Country Data"
      url: "https://github.com/CSSEGISandData/COVID-19"
      icon_url: "http://www.google.com/s2/favicons?domain_url=http://www.jhu.edu"
    }
  }

  measure: deaths_option_1 {
    hidden: yes
    type: sum
    sql: ${deaths_cumulative} ;;
  }

  measure: deaths_option_2 {
    hidden: yes
    type: sum
    sql: ${deaths_cumulative} ;;
    filters: {
      field: is_max_date
      value: "Yes"
    }
  }

  #this field displays the running total of deaths if a date filter has been applied, or else is gives the numbers from the most recent record
  measure: deaths_running_total {
    group_label: "  Running Total"
    description: "Filter on Measurement Date or Days Since First Outbreak to see the running total on a specific date, don't use with a range of dates or else the results will show the sum of the running totals for each day in that timeframe. If no dates are selected the most recent record will be used."
    label: "Deaths (Running Total)"
    type: number
    sql:
        {% if covid.measurement_date._in_query or analytics.admission_date._in_query %} ${deaths_option_1}
        {% else %}  ${deaths_option_2}
        {% endif %} ;;
    drill_fields: [drill*]
    link: {
      label: "Data Source - NYT County Data"
      url: "https://github.com/nytimes/covid-19-data"
      icon_url: "http://www.google.com/s2/favicons?domain_url=http://www.nytimes.com"
    }
    link: {
      label: "Data Source - Johns Hopkins State & Country Data"
      url: "https://github.com/CSSEGISandData/COVID-19"
      icon_url: "http://www.google.com/s2/favicons?domain_url=http://www.jhu.edu"
    }
  }

  measure: case_fatality_rate {
    group_label: "  Running Total"
#     description: "What percent of infections have resulted in death?"
    description: "Filter on Measurement Date or Days Since First Outbreak to see the running total on a specific date, don't use with a range of dates or else the results will show the sum of the running totals for each day in that timeframe. If no dates are selected the most recent record will be used."

    type: number
    sql: 1.0 * ${deaths_running_total}/NULLIF(${confirmed_running_total}, 0);;
    value_format_name: percent_1
    drill_fields: [drill*]
    link: {
      label: "Data Source - NYT County Data"
      url: "https://github.com/nytimes/covid-19-data"
      icon_url: "http://www.google.com/s2/favicons?domain_url=http://www.nytimes.com"
    }
    link: {
      label: "Data Source - Johns Hopkins State & Country Data"
      url: "https://github.com/CSSEGISandData/COVID-19"
      icon_url: "http://www.google.com/s2/favicons?domain_url=http://www.jhu.edu"
    }
  }

  measure: count {
    hidden: yes
    type: count
    drill_fields: []
  }

##############
### Drills ###
##############

  set: drill {
    fields: [
      zip,
      province_state,
      confirmed_cases,
      deaths
    ]
  }
}


###########
## Census  ##
## Source: https://github.com/llooker/covid19/blob/master/census_data/acs_zip_2017_5yr.view.lkml
###########

view: acs_zip_codes_2017_5yr {
  sql_table_name:
      (
      SELECT
        acs_zip_codes_2017_5yr.*,
        us_zipcode_boundaries.area_land_meters / 2590000 AS square_land_miles
      FROM `bigquery-public-data.census_bureau_acs.zip_codes_2017_5yr` AS acs_zip_codes_2017_5yr
      LEFT JOIN `bigquery-public-data.geo_us_boundaries.zip_codes` AS us_zipcode_boundaries
        ON acs_zip_codes_2017_5yr.geo_id = us_zipcode_boundaries.zip_code
      )
      ;;

      # sql_table_name: `bigquery-public-data.census_bureau_acs.zip_codes_2017_5yr`;;
    extends: [acs_base_fields]

    dimension: geo_id {
      primary_key: yes
      hidden: yes
      type: zipcode
    }

    dimension: square_land_miles {
      type: number
      sql: ${TABLE}.square_land_miles ;;
    }

    measure: sum_square_land_miles {
      type: sum
      sql: ${square_land_miles} ;;
    }

    dimension: population_density {
      type: number
      sql: ${total_pop_d} / ${square_land_miles}  ;;
      value_format_name: decimal_1
    }

    measure: average_population_density {
      type: number
      sql: 1.0 * ${total_pop} / nullif(${sum_square_land_miles},0) ;;
      value_format_name: decimal_1
    }

#   measure: population_density {
#     description: "Resident per Square Mile"
#     label: "Density (People per Sq Mi)"
#     type: number
#     sql: 1.0*${total_pop}/nullif(${us_zipcode_boundaries.total_area_land_meters}/2590000,0);;
#     value_format_name: decimal_1
#   }

    dimension: is_high_vulnerability_zipcode {
      description: "Zipcode has more than 5000 residents per square mile"
      type: yesno
      sql: ${population_density}>10000 ;;
    }

    measure: residents_in_highvulnerability_zips {
      description: "Number of residents that live in high Vulnerability zipcodes"
      type: sum
      sql: ${acs_zip_codes_2017_5yr.total_pop_d};;
      filters: {
        field: is_high_vulnerability_zipcode
        value: "yes"
      }
    }

    measure: percent_residents_in_highvulnerability_zips {
      description: "Number of residents that live in high Vulnerability zipcodes"
      type: number
      sql: 1.0*${residents_in_highvulnerability_zips}/nullif(${acs_zip_codes_2017_5yr.total_pop},0);;
      value_format_name: percent_2
    }

  }

view: acs_base_fields {
    extension: required

    dimension: geo_id {
      hidden: yes
      primary_key: yes
      type: string
      sql: ${TABLE}.geo_id ;;
    }



    ### Ethnicity / Race Populations ###

    dimension: total_pop_d {
      label: "Total Population"
      hidden: yes
      description: "The total number of all people living in a given geographic area. "
      type: number
      sql: ${TABLE}.total_pop ;;
    }

    measure: total_pop {
      label: "Total Population"
      #group_label: "Total Populations"
      description: "The total number of all people living in a given geographic area. "
      type: sum
      sql: ${total_pop_d} ;;
    }

    dimension: male_pop_d {
      hidden: yes
      label: "Male Population"
      type: number
      sql: ${TABLE}.male_pop ;;
    }

    measure: male_pop {
      group_label: "Total Populations"
      label: "Male Population"
      type: sum
      sql: ${male_pop_d} ;;
    }

    measure: percent_of_population_male {
      group_label: "Percent of Total Populations"
      type: number
      sql: 1.0*${male_pop}/nullif(${total_pop},0) ;;
    }

    dimension: female_pop_d {
      hidden: yes
      label: "Female Population"
      type: number
      sql: ${TABLE}.female_pop ;;
    }

    measure: female_pop {
      group_label: "Total Populations"
      label: "Female Population"
      type: sum
      sql: ${female_pop_d} ;;
    }

    measure: percent_of_population_female {
      group_label: "Percent of Total Populations"
      type: number
      sql: 1.0*${female_pop}/nullif(${total_pop},0) ;;
    }

#   dimension: white_pop_d {
#     hidden: yes
#     label: "White Population"
#     type: number
#     sql: ${TABLE}.white_pop ;;
#   }
#
#   measure: white_pop {
#     group_label: "Total Populations"
#     label: "White Population"
#     type: sum
#     sql: ${white_pop_d} ;;
#   }
#
#   measure: percent_of_population_white {
#     group_label: "Percent of Total Populations"
#     type: number
#     sql: 1.0*${white_pop}/nullif(${total_pop},0) ;;
#   }
#
#   dimension: black_pop_d {
#     hidden: yes
#     label: "Black Population"
#     type: number
#     sql: ${TABLE}.black_pop ;;
#   }
#
#   measure: black_pop {
#     group_label: "Total Populations"
#     label: "Black Population"
#     type: sum
#     sql: ${black_pop_d} ;;
#   }
#
#   measure: percent_of_population_black {
#     group_label: "Percent of Total Populations"
#     type: number
#     sql: 1.0*${black_pop}/nullif(${total_pop},0) ;;
#   }
#
#   dimension: asian_pop_d {
#     hidden: yes
#     label: "Asian Population"
#     type: number
#     sql: ${TABLE}.asian_pop ;;
#   }
#
#   measure: asian_pop {
#     group_label: "Total Populations"
#     label: "Asian Population"
#     type: sum
#     sql: ${asian_pop_d} ;;
#   }
#
#   measure: percent_of_population_asian {
#     group_label: "Percent of Total Populations"
#     type: number
#     sql: 1.0*${asian_pop}/nullif(${total_pop},0) ;;
#   }
#
#   dimension: hispanic_pop_d {
#     hidden: yes
#     label: "Hispanic Population"
#     type: number
#     sql: ${TABLE}.hispanic_pop ;;
#   }
#
#   measure: hispanic_pop {
#     group_label: "Total Populations"
#     label: "Hispanic Population"
#     type: sum
#     sql: ${hispanic_pop_d} ;;
#   }
#
#   measure: percent_of_population_hispanic {
#     group_label: "Percent of Total Populations"
#     type: number
#     sql: 1.0*${hispanic_pop}/nullif(${total_pop},0) ;;
#   }
#
#   dimension: amerindian_pop_d {
#     hidden: yes
#     label: "American Indian Population"
#     type: number
#     sql: ${TABLE}.amerindian_pop ;;
#   }
#
#   measure: amerindian_pop {
#     group_label: "Total Populations"
#     label: "American Indian Population"
#     type: sum
#     sql: ${amerindian_pop_d} ;;
#   }
#
#   measure: percent_of_population_american_indian {
#     group_label: "Percent of Total Populations"
#     type: number
#     sql: 1.0*${amerindian_pop}/nullif(${total_pop},0) ;;
#   }
#
#   dimension: other_race_pop_d {
#     hidden: yes
#     label: "Other Race Population"
#     type: number
#     sql: ${TABLE}.other_race_pop ;;
#   }
#
#   measure: other_race_pop {
#     group_label: "Total Populations"
#     label: "Other Race Population"
#     type: sum
#     sql: ${other_race_pop_d} ;;
#   }
#
#   measure: percent_of_population_other {
#     group_label: "Percent of Total Populations"
#     type: number
#     sql: 1.0*${other_race_pop}/nullif(${total_pop},0) ;;
#   }
#
#   dimension: two_or_more_races_pop_d {
#     hidden: yes
#     label: "Two or More Races Population"
#     type: number
#     sql: ${TABLE}.two_or_more_races_pop ;;
#   }
#
#   measure: two_or_more_races_pop {
#     group_label: "Total Populations"
#     label: "Two or More Races Population"
#     type: sum
#     sql: ${two_or_more_races_pop_d} ;;
#   }
#
#   measure: percent_of_population_two_or_more_races {
#     group_label: "Percent of Total Populations"
#     type: number
#     sql: 1.0*${two_or_more_races_pop}/nullif(${total_pop},0) ;;
#   }
#
#   dimension: not_hispanic_pop_d {
#     hidden: yes
#     label: "Non Hispanic Population"
#     type: number
#     sql: ${TABLE}.not_hispanic_pop ;;
#   }
#
#   measure: not_hispanic_pop {
#     group_label: "Total Populations"
#     label: "Non Hispanic Population"
#     type: sum
#     sql: ${not_hispanic_pop_d} ;;
#   }
#
#   measure: percent_of_population_not_hispanic {
#     group_label: "Percent of Total Populations"
#     type: number
#     sql: 1.0*${not_hispanic_pop}/nullif(${total_pop},0) ;;
#   }

#   dimension: white_including_hispanic {
#     type: number
#     sql: ${TABLE}.white_including_hispanic ;;
#   }
#
#   dimension: black_including_hispanic {
#     type: number
#     sql: ${TABLE}.black_including_hispanic ;;
#   }
#
#   dimension: amerindian_including_hispanic {
#     type: number
#     sql: ${TABLE}.amerindian_including_hispanic ;;
#   }
#
#   dimension: asian_including_hispanic {
#     type: number
#     sql: ${TABLE}.asian_including_hispanic ;;
#   }


    ###### Age groups ####


    dimension: median_age {
      hidden: yes
      type: number
      sql: ${TABLE}.median_age ;;
    }

    measure: average_median_age {
      type: average
      sql: ${median_age} ;;
    }

    dimension: male_under_5 {
      hidden: yes
      type: number
      sql: ${TABLE}.male_under_5 ;;
    }

    dimension: male_5_to_9 {
      hidden: yes
      type: number
      sql: ${TABLE}.male_5_to_9 ;;
    }

    dimension: male_10_to_14 {
      hidden: yes
      type: number
      sql: ${TABLE}.male_10_to_14 ;;
    }

    dimension: male_15_to_17 {
      hidden: yes
      type: number
      sql: ${TABLE}.male_15_to_17 ;;
    }

    dimension: male_18_to_19 {
      hidden: yes
      type: number
      sql: ${TABLE}.male_18_to_19 ;;
    }

    dimension: male_20 {
      hidden: yes
      type: number
      sql: ${TABLE}.male_20 ;;
    }

    dimension: male_21 {
      hidden: yes
      type: number
      sql: ${TABLE}.male_21 ;;
    }

    dimension: male_22_to_24 {
      hidden: yes
      type: number
      sql: ${TABLE}.male_22_to_24 ;;
    }

    dimension: male_25_to_29 {
      hidden: yes
      type: number
      sql: ${TABLE}.male_25_to_29 ;;
    }

    dimension: male_30_to_34 {
      hidden: yes
      type: number
      sql: ${TABLE}.male_30_to_34 ;;
    }

    dimension: male_35_to_39 {
      hidden: yes
      type: number
      sql: ${TABLE}.male_35_to_39 ;;
    }

    dimension: male_40_to_44 {
      hidden: yes
      type: number
      sql: ${TABLE}.male_40_to_44 ;;
    }

    dimension: male_45_to_49 {
      hidden: yes
      type: number
      sql: ${TABLE}.male_45_to_49 ;;
    }

    dimension: male_50_to_54 {
      hidden: yes
      type: number
      sql: ${TABLE}.male_50_to_54 ;;
    }

    dimension: male_55_to_59 {
      hidden: yes
      type: number
      sql: ${TABLE}.male_55_to_59 ;;
    }

    dimension: male_60_61 {
      hidden: yes
      type: number
      sql: ${TABLE}.male_60_61 ;;
    }

    dimension: male_62_64 {
      hidden: yes
      type: number
      sql: ${TABLE}.male_62_64 ;;
    }

    dimension: male_65_to_66 {
      hidden: yes
      type: number
      sql: ${TABLE}.male_65_to_66 ;;
    }

    dimension: male_67_to_69 {
      hidden: yes
      type: number
      sql: ${TABLE}.male_67_to_69 ;;
    }

    dimension: male_70_to_74 {
      hidden: yes
      type: number
      sql: ${TABLE}.male_70_to_74 ;;
    }

    dimension: male_75_to_79 {
      hidden: yes
      type: number
      sql: ${TABLE}.male_75_to_79 ;;
    }

    dimension: male_80_to_84 {
      hidden: yes
      type: number
      sql: ${TABLE}.male_80_to_84 ;;
    }

    dimension: male_85_and_over {
      hidden: yes
      type: number
      sql: ${TABLE}.male_85_and_over ;;
    }

    dimension: male_above_50_d {
      hidden: yes
      type: number
      sql: ${male_50_to_54} + ${male_55_to_59} + ${male_60_61}
        + ${male_62_64} + ${male_above_65_d};;
    }

    measure: male_above_50 {
      group_label: "Males"
      type: sum
      sql: ${male_above_50_d} ;;
    }

    dimension: male_above_65_d {
      hidden: yes
      type: number
      sql: ${male_65_to_66} + ${male_67_to_69} + ${male_70_to_74} + ${male_75_to_79} + ${male_above_80_d};;
    }

    measure: male_above_65 {
      group_label: "Males"
      type: sum
      sql: ${male_above_65_d} ;;
    }

    dimension: male_above_80_d {
      type: number
      sql:${male_80_to_84} + ${male_85_and_over}  ;;
    }

    measure: male_above_80 {
      group_label: "Males"
      type: sum
      sql: ${male_above_80_d} ;;
    }

    dimension: female_under_5 {
      hidden: yes
      type: number
      sql: ${TABLE}.female_under_5 ;;
    }

    dimension: female_5_to_9 {
      hidden: yes
      type: number
      sql: ${TABLE}.female_5_to_9 ;;
    }

    dimension: female_10_to_14 {
      hidden: yes
      type: number
      sql: ${TABLE}.female_10_to_14 ;;
    }

    dimension: female_15_to_17 {
      hidden: yes
      type: number
      sql: ${TABLE}.female_15_to_17 ;;
    }

    dimension: female_18_to_19 {
      hidden: yes
      type: number
      sql: ${TABLE}.female_18_to_19 ;;
    }

    dimension: female_20 {
      hidden: yes
      type: number
      sql: ${TABLE}.female_20 ;;
    }

    dimension: female_21 {
      hidden: yes
      type: number
      sql: ${TABLE}.female_21 ;;
    }

    dimension: female_22_to_24 {
      hidden: yes
      type: number
      sql: ${TABLE}.female_22_to_24 ;;
    }

    dimension: female_25_to_29 {
      hidden: yes
      type: number
      sql: ${TABLE}.female_25_to_29 ;;
    }

    dimension: female_30_to_34 {
      hidden: yes
      type: number
      sql: ${TABLE}.female_30_to_34 ;;
    }

    dimension: female_35_to_39 {
      hidden: yes
      type: number
      sql: ${TABLE}.female_35_to_39 ;;
    }

    dimension: female_40_to_44 {
      hidden: yes
      type: number
      sql: ${TABLE}.female_40_to_44 ;;
    }

    dimension: female_45_to_49 {
      hidden: yes
      type: number
      sql: ${TABLE}.female_45_to_49 ;;
    }

    dimension: female_50_to_54 {
      hidden: yes
      type: number
      sql: ${TABLE}.female_50_to_54 ;;
    }

    dimension: female_55_to_59 {
      hidden: yes
      type: number
      sql: ${TABLE}.female_55_to_59 ;;
    }

    dimension: female_60_to_61 {
      hidden: yes
      type: number
      sql: ${TABLE}.female_60_to_61 ;;
    }

    dimension: female_62_to_64 {
      hidden: yes
      type: number
      sql: ${TABLE}.female_62_to_64 ;;
    }

    dimension: female_65_to_66 {
      hidden: yes
      type: number
      sql: ${TABLE}.female_65_to_66 ;;
    }

    dimension: female_67_to_69 {
      hidden: yes
      type: number
      sql: ${TABLE}.female_67_to_69 ;;
    }

    dimension: female_70_to_74 {
      hidden: yes
      type: number
      sql: ${TABLE}.female_70_to_74 ;;
    }

    dimension: female_75_to_79 {
      hidden: yes
      type: number
      sql: ${TABLE}.female_75_to_79 ;;
    }

    dimension: female_80_to_84 {
      hidden: yes
      type: number
      sql: ${TABLE}.female_80_to_84 ;;
    }

    dimension: female_85_and_over {
      hidden: yes
      type: number
      sql: ${TABLE}.female_85_and_over ;;
    }

    dimension: female_above_50_d {
      hidden: yes
      type: number
      sql: ${female_50_to_54} + ${female_55_to_59} + ${female_60_to_61}
        + ${female_62_to_64} + ${female_above_65_d};;
    }

    measure: female_above_50 {
      group_label: "Females"
      type: sum
      sql: ${female_above_50_d} ;;
    }

    dimension: female_above_65_d {
      hidden: yes
      type: number
      sql: ${female_65_to_66} + ${female_67_to_69} + ${female_70_to_74} + ${female_75_to_79} + ${female_above_80_d};;
    }

    dimension: female_above_70_d {
      hidden: yes
      type: number
      sql: ${female_70_to_74} + ${female_75_to_79} + ${female_above_80_d};;
    }

    dimension: male_above_70_d {
      hidden: yes
      type: number
      sql: ${male_70_to_74} + ${male_75_to_79} + ${male_above_80_d};;
    }

    measure: female_above_65 {
      group_label: "Females"
      type: sum
      sql: ${female_above_65_d} ;;
    }

    dimension: female_above_80_d {
      type: number
      sql:${female_80_to_84} + ${female_85_and_over}  ;;
    }

    measure: female_above_80 {
      group_label: "Females"
      type: sum
      sql: ${female_above_80_d} ;;
    }

    measure: population_above_50 {
      type: number
      sql: ${female_above_50} + ${male_above_50} ;;
    }

    measure: population_above_65 {
      type: number
      sql: ${female_above_65} + ${male_above_65} ;;
    }

    measure: population_above_70 {
      type: sum
      sql: ${female_above_70_d} + ${male_above_70_d} ;;
    }

    measure: population_above_80 {
      type: number
      sql: ${female_above_80} + ${male_above_80} ;;
    }

    measure: percent_above_50 {
      type: number
      sql: 1.0*${population_above_50}/nullif(${total_pop},0) ;;
      value_format_name: percent_2
    }

    measure: percent_above_65 {
      type: number
      sql: 1.0*${population_above_65}/nullif(${total_pop},0);;
      value_format_name: percent_2
    }

    measure: percent_above_70 {
      type: number
      sql: 1.0*${population_above_70}/nullif(${total_pop},0);;
      value_format_name: percent_2
    }

    measure: percent_above_80 {
      type: number
      sql: 1.0*${population_above_80}/nullif(${total_pop},0) ;;
      value_format_name: percent_2
    }


    ####### Commuting ######

    dimension: commuters_by_public_transportation_d {
      hidden: yes
      type: number
      sql: ${TABLE}.commuters_by_public_transportation ;;
    }

    measure:commuters_by_public_transportation {
      sql: ${commuters_by_public_transportation_d} ;;
      type: sum
    }

    measure: percent_public_transport_commuters {
      type: number
      sql: 1.0*${commuters_by_public_transportation}/nullif(${total_pop},0) ;;
      value_format_name: percent_2
    }

    dimension: commute_5_9_mins {
      hidden: yes
      type: number
      sql: ${TABLE}.commute_5_9_mins ;;
    }

    dimension: commute_35_39_mins {
      hidden: yes
      type: number
      sql: ${TABLE}.commute_35_39_mins ;;
    }

    dimension: commute_40_44_mins {
      hidden: yes
      type: number
      sql: ${TABLE}.commute_40_44_mins ;;
    }

    dimension: commute_60_89_mins {
      hidden: yes
      type: number
      sql: ${TABLE}.commute_60_89_mins ;;
    }

    dimension: commute_90_more_mins {
      hidden: yes
      type: number
      sql: ${TABLE}.commute_90_more_mins ;;
    }

    dimension: commute_10_14_mins {
      hidden: yes
      type: number
      sql: ${TABLE}.commute_10_14_mins ;;
    }

    dimension: commute_15_19_mins {
      hidden: yes
      type: number
      sql: ${TABLE}.commute_15_19_mins ;;
    }

    dimension: commute_35_44_mins {
      hidden: yes
      type: number
      sql: ${TABLE}.commute_35_44_mins ;;
    }

    dimension: commute_60_more_mins {
      hidden: yes
      type: number
      sql: ${TABLE}.commute_60_more_mins ;;
    }

    dimension: commute_less_10_mins {
      hidden: yes
      type: number
      sql: ${TABLE}.commute_less_10_mins ;;
    }

    dimension: commuters_16_over {
      hidden: yes
      type: number
      sql: ${TABLE}.commuters_16_over ;;
    }

    dimension: commute_20_24_mins {
      hidden: yes
      type: number
      sql: ${TABLE}.commute_20_24_mins ;;
    }

    dimension: commute_25_29_mins {
      hidden: yes
      type: number
      sql: ${TABLE}.commute_25_29_mins ;;
    }

    dimension: commute_30_34_mins {
      hidden: yes
      type: number
      sql: ${TABLE}.commute_30_34_mins ;;
    }

    dimension: commute_45_59_mins {
      hidden: yes
      type: number
      sql: ${TABLE}.commute_45_59_mins ;;
    }

    dimension: aggregate_travel_time_to_work {
      hidden: yes
      type: number
      sql: ${TABLE}.aggregate_travel_time_to_work ;;
    }

    dimension: commuters_by_bus {
      hidden: yes
      type: number
      sql: ${TABLE}.commuters_by_bus ;;
    }

    dimension: commuters_by_car_truck_van {
      hidden: yes
      type: number
      sql: ${TABLE}.commuters_by_car_truck_van ;;
    }

    dimension: commuters_by_carpool {
      hidden: yes
      type: number
      sql: ${TABLE}.commuters_by_carpool ;;
    }

    dimension: commuters_by_subway_or_elevated {
      hidden: yes
      type: number
      sql: ${TABLE}.commuters_by_subway_or_elevated ;;
    }

    dimension: commuters_drove_alone {
      hidden: yes
      type: number
      sql: ${TABLE}.commuters_drove_alone ;;
    }


    dimension: walked_to_work {
      type: number
      sql: ${TABLE}.walked_to_work ;;
    }

    dimension: worked_at_home {
      type: number
      sql: ${TABLE}.worked_at_home ;;
    }


    #### Household Incomes ###

    dimension: households {
      type: number
      sql: ${TABLE}.households ;;
    }




    ### Family Structures ###

    dimension: families_with_young_children {
      hidden: yes
      type: number
      sql: ${TABLE}.families_with_young_children ;;
    }

    dimension: nonfamily_households {
      hidden: yes
      type: number
      sql: ${TABLE}.nonfamily_households ;;
    }

    dimension: family_households {
      hidden: yes
      sql: ${TABLE}.family_households ;;
    }

#   dimension: children {
#     type: number
#     sql: ${TABLE}.children ;;
#   }
#
#   dimension: children_in_single_female_hh {
#     type: number
#     sql: ${TABLE}.children_in_single_female_hh ;;
#   }
#
#   dimension: married_households {
#     type: number
#     sql: ${TABLE}.married_households ;;
#   }
#
#   dimension: two_parent_families_with_young_children {
#     type: number
#     sql: ${TABLE}.two_parent_families_with_young_children ;;
#   }
#
#   dimension: two_parents_in_labor_force_families_with_young_children {
#     type: number
#     sql: ${TABLE}.two_parents_in_labor_force_families_with_young_children ;;
#   }
#
#   dimension: two_parents_father_in_labor_force_families_with_young_children {
#     type: number
#     sql: ${TABLE}.two_parents_father_in_labor_force_families_with_young_children ;;
#   }
#
#   dimension: two_parents_mother_in_labor_force_families_with_young_children {
#     type: number
#     sql: ${TABLE}.two_parents_mother_in_labor_force_families_with_young_children ;;
#   }
#
#   dimension: two_parents_not_in_labor_force_families_with_young_children {
#     type: number
#     sql: ${TABLE}.two_parents_not_in_labor_force_families_with_young_children ;;
#   }
#
#   dimension: one_parent_families_with_young_children {
#     type: number
#     sql: ${TABLE}.one_parent_families_with_young_children ;;
#   }
#
#   dimension: father_one_parent_families_with_young_children {
#     type: number
#     sql: ${TABLE}.father_one_parent_families_with_young_children ;;
#   }
#
#   dimension: father_in_labor_force_one_parent_families_with_young_children {
#     type: number
#     sql: ${TABLE}.father_in_labor_force_one_parent_families_with_young_children ;;
#   }


    ### Income ###

    dimension: income_less_10000 {
      hidden: yes
      type: number
      sql: ${TABLE}.income_less_10000 ;;
    }

    dimension: income_10000_14999 {
      hidden: yes
      type: number
      sql: ${TABLE}.income_10000_14999 ;;
    }

    dimension: income_15000_19999 {
      hidden: yes
      type: number
      sql: ${TABLE}.income_15000_19999 ;;
    }

    dimension: income_20000_24999 {
      hidden: yes
      type: number
      sql: ${TABLE}.income_20000_24999 ;;
    }

    dimension: income_25000_29999 {
      hidden: yes
      type: number
      sql: ${TABLE}.income_25000_29999 ;;
    }

    dimension: income_30000_34999 {
      hidden: yes
      type: number
      sql: ${TABLE}.income_30000_34999 ;;
    }

    dimension: income_35000_39999 {
      hidden: yes
      type: number
      sql: ${TABLE}.income_35000_39999 ;;
    }

    dimension: income_40000_44999 {
      hidden: yes
      type: number
      sql: ${TABLE}.income_40000_44999 ;;
    }

    dimension: income_45000_49999 {
      hidden: yes
      type: number
      sql: ${TABLE}.income_45000_49999 ;;
    }

    dimension: income_50000_59999 {
      hidden: yes
      type: number
      sql: ${TABLE}.income_50000_59999 ;;
    }

    dimension: income_60000_74999 {
      hidden: yes
      type: number
      sql: ${TABLE}.income_60000_74999 ;;
    }

    dimension: income_75000_99999 {
      hidden: yes
      type: number
      sql: ${TABLE}.income_75000_99999 ;;
    }

    dimension: income_100000_124999 {
      hidden: yes
      type: number
      sql: ${TABLE}.income_100000_124999 ;;
    }

    dimension: income_125000_149999 {
      hidden: yes
      type: number
      sql: ${TABLE}.income_125000_149999 ;;
    }

    dimension: income_150000_199999 {
      hidden: yes
      type: number
      sql: ${TABLE}.income_150000_199999 ;;
    }

    dimension: income_200000_or_more {
      hidden: yes
      type: number
      sql: ${TABLE}.income_200000_or_more ;;
    }

    dimension: median_income {
      type: number
      sql: ${TABLE}.median_income ;;
    }

    dimension: population_in_poverty_income {
      type: number
      sql:
          ${income_less_10000} + ${income_10000_14999} + ${income_15000_19999} + ${income_20000_24999} + ${income_25000_29999} ;;
    }

  dimension: population_total_income {
    type: number
    sql:
          ${income_less_10000} + ${income_10000_14999} + ${income_15000_19999} + ${income_20000_24999} + ${income_25000_29999} + ${income_30000_34999}
        + ${income_35000_39999} + ${income_40000_44999} + ${income_45000_49999} + ${income_50000_59999} + ${income_60000_74999} + ${income_75000_99999}
        + ${income_100000_124999} + ${income_125000_149999} + ${income_150000_199999} + ${income_200000_or_more} ;;
  }

    measure: count_in_poverty_income {
      type: sum
      sql: ${population_in_poverty_income} ;;
    }

    measure: count_total_income {
      type: sum
      sql: ${population_total_income} ;;
    }

    measure: average_median_income {
      type: number
      sql: 1.0 * ${count_in_poverty_income} / nullif(${count_total_income},0) ;;
      value_format_name: usd
    }

    dimension: income_per_capita {
      type: number
      sql: ${TABLE}.income_per_capita ;;
    }

    dimension: poverty {
      type: number
      sql: ${TABLE}.poverty ;;
    }



    #### Housing Units ####

    dimension: occupied_housing_units {
      type: number
      sql: ${TABLE}.occupied_housing_units ;;
    }

    dimension: housing_units_renter_occupied {
      type: number
      sql: ${TABLE}.housing_units_renter_occupied ;;
    }

    dimension: dwellings_1_units_detached {
      hidden: yes
      type: number
      sql: ${TABLE}.dwellings_1_units_detached ;;
    }

    dimension: dwellings_1_units_attached {
      hidden: yes
      type: number
      sql: ${TABLE}.dwellings_1_units_attached ;;
    }

    dimension: dwellings_2_units {
      hidden: yes
      type: number
      sql: ${TABLE}.dwellings_2_units ;;
    }

    dimension: dwellings_3_to_4_units {
      hidden: yes
      type: number
      sql: ${TABLE}.dwellings_3_to_4_units ;;
    }

    dimension: dwellings_5_to_9_units {
      hidden: yes
      type: number
      sql: ${TABLE}.dwellings_5_to_9_units ;;
    }

    dimension: dwellings_10_to_19_units {
      hidden: yes
      type: number
      sql: ${TABLE}.dwellings_10_to_19_units ;;
    }

    dimension: dwellings_20_to_49_units {
      hidden: yes
      type: number
      sql: ${TABLE}.dwellings_20_to_49_units ;;
    }

    dimension: dwellings_50_or_more_units {
      hidden: yes
      type: number
      sql: ${TABLE}.dwellings_50_or_more_units ;;
    }

    dimension: dwellings_5_or_more_units_d {
      hidden: yes
      type: number
      sql:  ${dwellings_5_to_9_units} + ${dwellings_10_to_19_units} + ${dwellings_20_to_49_units} +
        ${dwellings_50_or_more_units};;
    }

    measure: dwellings_5_or_more_units {
      description: "Number of Dwellings with 5 or More Units"
      type: sum
      sql: ${dwellings_5_or_more_units_d} ;;
    }

    measure: total_dwellings {
      type: number
      sql: sum(${dwellings_1_units_detached})+sum(${dwellings_1_units_attached})+
          sum(${dwellings_2_units}) + sum(${dwellings_3_to_4_units}) +  sum(${dwellings_5_to_9_units})
          + sum(${dwellings_10_to_19_units}) + sum(${dwellings_20_to_49_units}) +
          sum(${dwellings_50_or_more_units}) + sum(${mobile_homes});;
    }

    measure: percent_apartment_buildings {
      description: "The percentage of dwellings that have 5 or more units"
      type: number
      sql: 1.0*${dwellings_5_or_more_units}/nullif(${total_dwellings},0) ;;
      value_format_name: percent_2
    }

    dimension: mobile_homes {
      hidden: yes
      type: number
      sql: ${TABLE}.mobile_homes ;;
    }

#   dimension: renter_occupied_housing_units_paying_cash_median_gross_rent {
#     type: number
#     sql: ${TABLE}.renter_occupied_housing_units_paying_cash_median_gross_rent ;;
#   }
#
#   dimension: owner_occupied_housing_units_lower_value_quartile {
#     type: number
#     sql: ${TABLE}.owner_occupied_housing_units_lower_value_quartile ;;
#   }
#
#   dimension: owner_occupied_housing_units_median_value {
#     type: number
#     sql: ${TABLE}.owner_occupied_housing_units_median_value ;;
#   }
#
#   dimension: owner_occupied_housing_units_upper_value_quartile {
#     type: number
#     sql: ${TABLE}.owner_occupied_housing_units_upper_value_quartile ;;
#   }
#
#   dimension: housing_built_2005_or_later {
#     type: number
#     sql: ${TABLE}.housing_built_2005_or_later ;;
#   }
#
#   dimension: housing_built_2000_to_2004 {
#     type: number
#     sql: ${TABLE}.housing_built_2000_to_2004 ;;
#   }
#
#   dimension: housing_built_1939_or_earlier {
#     type: number
#     sql: ${TABLE}.housing_built_1939_or_earlier ;;
#   }

#   dimension: households_retirement_income {
#     type: number
#     sql: ${TABLE}.households_retirement_income ;;
#   }
#
#   dimension: different_house_year_ago_different_city {
#     type: number
#     sql: ${TABLE}.different_house_year_ago_different_city ;;
#   }
#
#   dimension: different_house_year_ago_same_city {
#     type: number
#     sql: ${TABLE}.different_house_year_ago_same_city ;;
#   }


    #### Occupation & Education ###

    dimension: employed_agriculture_forestry_fishing_hunting_mining {
      type: number
      sql: ${TABLE}.employed_agriculture_forestry_fishing_hunting_mining ;;
    }

    dimension: employed_arts_entertainment_recreation_accommodation_food {
      type: number
      sql: ${TABLE}.employed_arts_entertainment_recreation_accommodation_food ;;
    }

    dimension: employed_construction {
      type: number
      sql: ${TABLE}.employed_construction ;;
    }

    dimension: employed_education_health_social {
      hidden: yes
      type: number
      sql: ${TABLE}.employed_education_health_social ;;
    }

    measure: percent_high_vulnerability_employed {
      type: number
      description: "Percent of population that is employed in healthcare, eduacation and social work"
      sql: 1.0*sum(${employed_education_health_social})/nullif(${total_pop},0) ;;
      value_format_name: percent_2
    }

    dimension: employed_finance_insurance_real_estate {
      hidden: yes
      type: number
      sql: ${TABLE}.employed_finance_insurance_real_estate ;;
    }

    dimension: employed_information {
      hidden: yes
      type: number
      sql: ${TABLE}.employed_information ;;
    }

    dimension: employed_manufacturing {
      hidden: yes
      type: number
      sql: ${TABLE}.employed_manufacturing ;;
    }

    dimension: employed_other_services_not_public_admin {
      hidden: yes
      type: number
      sql: ${TABLE}.employed_other_services_not_public_admin ;;
    }

    dimension: employed_public_administration {
      hidden: yes
      type: number
      sql: ${TABLE}.employed_public_administration ;;
    }

    dimension: employed_retail_trade {
      hidden: yes
      type: number
      sql: ${TABLE}.employed_retail_trade ;;
    }

    dimension: employed_science_management_admin_waste {
      hidden: yes
      type: number
      sql: ${TABLE}.employed_science_management_admin_waste ;;
    }

    dimension: employed_transportation_warehousing_utilities {
      hidden: yes
      type: number
      sql: ${TABLE}.employed_transportation_warehousing_utilities ;;
    }

    dimension: employed_wholesale_trade {
      hidden: yes
      type: number
      sql: ${TABLE}.employed_wholesale_trade ;;
    }

    dimension: female_female_households {
      type: number
      sql: ${TABLE}.female_female_households ;;
    }

    dimension: gini_index {
      type: number
      sql: ${TABLE}.gini_index ;;
    }


    dimension: occupation_management_arts {
      hidden: yes
      type: number
      sql: ${TABLE}.occupation_management_arts ;;
    }

    dimension: occupation_natural_resources_construction_maintenance {
      hidden: yes
      type: number
      sql: ${TABLE}.occupation_natural_resources_construction_maintenance ;;
    }

    dimension: occupation_production_transportation_material {
      hidden: yes
      type: number
      sql: ${TABLE}.occupation_production_transportation_material ;;
    }

    dimension: occupation_sales_office {
      hidden: yes
      type: number
      sql: ${TABLE}.occupation_sales_office ;;
    }

    dimension: occupation_services {
      hidden: yes
      type: number
      sql: ${TABLE}.occupation_services ;;
    }


#   dimension: sales_office_employed {
#     type: number
#     sql: ${TABLE}.sales_office_employed ;;
#   }
#
#   dimension: some_college_and_associates_degree {
#     type: number
#     sql: ${TABLE}.some_college_and_associates_degree ;;
#   }

#   dimension: workers_16_and_over {
#     type: number
#     sql: ${TABLE}.workers_16_and_over ;;
#   }
#
#   dimension: associates_degree {
#     type: number
#     sql: ${TABLE}.associates_degree ;;
#   }
#
#   dimension: bachelors_degree {
#     type: number
#     sql: ${TABLE}.bachelors_degree ;;
#   }
#
#   dimension: high_school_diploma {
#     type: number
#     sql: ${TABLE}.high_school_diploma ;;
#   }
#
#   dimension: less_one_year_college {
#     type: number
#     sql: ${TABLE}.less_one_year_college ;;
#   }
#
#   dimension: masters_degree {
#     type: number
#     sql: ${TABLE}.masters_degree ;;
#   }
#
#   dimension: one_year_more_college {
#     type: number
#     sql: ${TABLE}.one_year_more_college ;;
#   }
#
#   dimension: pop_25_years_over {
#     type: number
#     sql: ${TABLE}.pop_25_years_over ;;
#   }
#
#   dimension: hispanic_any_race {
#     type: number
#     sql: ${TABLE}.hispanic_any_race ;;
#   }
#
#   dimension: pop_5_years_over {
#     type: number
#     sql: ${TABLE}.pop_5_years_over ;;
#   }
#
#   dimension: speak_only_english_at_home {
#     type: number
#     sql: ${TABLE}.speak_only_english_at_home ;;
#   }
#
#   dimension: speak_spanish_at_home {
#     type: number
#     sql: ${TABLE}.speak_spanish_at_home ;;
#   }
#
#   dimension: speak_spanish_at_home_low_english {
#     type: number
#     sql: ${TABLE}.speak_spanish_at_home_low_english ;;
#   }
#
#   dimension: pop_15_and_over {
#     type: number
#     sql: ${TABLE}.pop_15_and_over ;;
#   }
#
#   dimension: pop_never_married {
#     type: number
#     sql: ${TABLE}.pop_never_married ;;
#   }
#
#   dimension: pop_now_married {
#     type: number
#     sql: ${TABLE}.pop_now_married ;;
#   }
#
#   dimension: pop_separated {
#     type: number
#     sql: ${TABLE}.pop_separated ;;
#   }
#
#   dimension: pop_widowed {
#     type: number
#     sql: ${TABLE}.pop_widowed ;;
#   }
#
#   dimension: pop_divorced {
#     type: number
#     sql: ${TABLE}.pop_divorced ;;
#   }
#
#   dimension: do_date {
#     type: string
#     sql: ${TABLE}.do_date ;;
#   }
#   dimension: housing_units {
#     type: number
#     sql: ${TABLE}.housing_units ;;
#   }
#
#   dimension: vacant_housing_units {
#     type: number
#     sql: ${TABLE}.vacant_housing_units ;;
#   }
#
#   dimension: vacant_housing_units_for_rent {
#     type: number
#     sql: ${TABLE}.vacant_housing_units_for_rent ;;
#   }
#
#   dimension: vacant_housing_units_for_sale {
#     type: number
#     sql: ${TABLE}.vacant_housing_units_for_sale ;;
#   }
#
#   dimension: median_rent {
#     type: number
#     sql: ${TABLE}.median_rent ;;
#   }
#
#   dimension: percent_income_spent_on_rent {
#     type: number
#     sql: ${TABLE}.percent_income_spent_on_rent ;;
#   }
#
#   dimension: owner_occupied_housing_units {
#     type: number
#     sql: ${TABLE}.owner_occupied_housing_units ;;
#   }
#
#   dimension: million_dollar_housing_units {
#     type: number
#     sql: ${TABLE}.million_dollar_housing_units ;;
#   }
#
#   dimension: mortgaged_housing_units {
#     type: number
#     sql: ${TABLE}.mortgaged_housing_units ;;
#   }
#   dimension: median_year_structure_built {
#     type: number
#     sql: ${TABLE}.median_year_structure_built ;;
#   }


    #### Rent Burdens ###

#   dimension: rent_burden_not_computed {
#     description: "Housing units without rent burden computed. Units for which no rent is paid and units occupied by households
#     that reported no income or a net loss comprise this category"
#     type: number
#     sql: ${TABLE}.rent_burden_not_computed ;;
#   }
#
#   dimension: rent_over_50_percent {
#     type: number
#     sql: ${TABLE}.rent_over_50_percent ;;
#   }
#
#   dimension: rent_40_to_50_percent {
#     hidden: yes
#     type: number
#     sql: ${TABLE}.rent_40_to_50_percent ;;
#   }
#
#   dimension: rent_35_to_40_percent {
#     hidden: yes
#     type: number
#     sql: ${TABLE}.rent_35_to_40_percent ;;
#   }
#
#   dimension: rent_30_to_35_percent {
#     hidden: yes
#     type: number
#     sql: ${TABLE}.rent_30_to_35_percent ;;
#   }
#
#   dimension: rent_25_to_30_percent {
#     hidden: yes
#     type: number
#     sql: ${TABLE}.rent_25_to_30_percent ;;
#   }
#
#   dimension: rent_20_to_25_percent {
#     hidden: yes
#     type: number
#     sql: ${TABLE}.rent_20_to_25_percent ;;
#   }
#
#   dimension: rent_15_to_20_percent {
#     hidden: yes
#     type: number
#     sql: ${TABLE}.rent_15_to_20_percent ;;
#   }
#
#   dimension: rent_10_to_15_percent {
#     hidden: yes
#     type: number
#     sql: ${TABLE}.rent_10_to_15_percent ;;
#   }
#
#   dimension: rent_under_10_percent {
#     hidden: yes
#     type: number
#     sql: ${TABLE}.rent_under_10_percent ;;
#   }

#   dimension: armed_forces {
#     type: number
#     sql: ${TABLE}.armed_forces ;;
#   }
#
#   dimension: civilian_labor_force {
#     type: number
#     sql: ${TABLE}.civilian_labor_force ;;
#   }
#
#   dimension: employed_pop {
#     type: number
#     sql: ${TABLE}.employed_pop ;;
#   }
#
#   dimension: unemployed_pop {
#     type: number
#     sql: ${TABLE}.unemployed_pop ;;
#   }
#
#   dimension: not_in_labor_force {
#     type: number
#     sql: ${TABLE}.not_in_labor_force ;;
#   }
#
#   dimension: pop_16_over {
#     type: number
#     sql: ${TABLE}.pop_16_over ;;
#   }
#
#   dimension: pop_in_labor_force {
#     type: number
#     sql: ${TABLE}.pop_in_labor_force ;;
#   }
#
#   dimension: asian_male_45_54 {
#     type: number
#     sql: ${TABLE}.asian_male_45_54 ;;
#   }
#
#   dimension: asian_male_55_64 {
#     type: number
#     sql: ${TABLE}.asian_male_55_64 ;;
#   }
#
#   dimension: black_male_45_54 {
#     type: number
#     sql: ${TABLE}.black_male_45_54 ;;
#   }
#
#   dimension: black_male_55_64 {
#     type: number
#     sql: ${TABLE}.black_male_55_64 ;;
#   }
#
#   dimension: hispanic_male_45_54 {
#     type: number
#     sql: ${TABLE}.hispanic_male_45_54 ;;
#   }
#
#   dimension: hispanic_male_55_64 {
#     type: number
#     sql: ${TABLE}.hispanic_male_55_64 ;;
#   }
#
#   dimension: white_male_45_54 {
#     type: number
#     sql: ${TABLE}.white_male_45_54 ;;
#   }
#
#   dimension: white_male_55_64 {
#     type: number
#     sql: ${TABLE}.white_male_55_64 ;;
#   }
#
#   dimension: bachelors_degree_2 {
#     type: number
#     sql: ${TABLE}.bachelors_degree_2 ;;
#   }
#
#   dimension: bachelors_degree_or_higher_25_64 {
#     type: number
#     sql: ${TABLE}.bachelors_degree_or_higher_25_64 ;;
#   }
#   dimension: one_car {
#     type: number
#     sql: ${TABLE}.one_car ;;
#   }
#
#   dimension: two_cars {
#     type: number
#     sql: ${TABLE}.two_cars ;;
#   }
#
#   dimension: three_cars {
#     type: number
#     sql: ${TABLE}.three_cars ;;
#   }
#
#   dimension: pop_25_64 {
#     type: number
#     sql: ${TABLE}.pop_25_64 ;;
#   }
#
#   dimension: pop_determined_poverty_status {
#     type: number
#     sql: ${TABLE}.pop_determined_poverty_status ;;
#   }
#
#   dimension: population_1_year_and_over {
#     type: number
#     sql: ${TABLE}.population_1_year_and_over ;;
#   }
#
#   dimension: population_3_years_over {
#     type: number
#     sql: ${TABLE}.population_3_years_over ;;
#   }

#   dimension: four_more_cars {
#     type: number
#     sql: ${TABLE}.four_more_cars ;;
#   }
#
#   dimension: graduate_professional_degree {
#     type: number
#     sql: ${TABLE}.graduate_professional_degree ;;
#   }
#
#   dimension: group_quarters {
#     type: number
#     sql: ${TABLE}.group_quarters ;;
#   }
#
#   dimension: high_school_including_ged {
#     type: number
#     sql: ${TABLE}.high_school_including_ged ;;
#   }
#
#   dimension: households_public_asst_or_food_stamps {
#     type: number
#     sql: ${TABLE}.households_public_asst_or_food_stamps ;;
#   }
#
#   dimension: in_grades_1_to_4 {
#     type: number
#     sql: ${TABLE}.in_grades_1_to_4 ;;
#   }
#
#   dimension: in_grades_5_to_8 {
#     type: number
#     sql: ${TABLE}.in_grades_5_to_8 ;;
#   }
#
#   dimension: in_grades_9_to_12 {
#     type: number
#     sql: ${TABLE}.in_grades_9_to_12 ;;
#   }
#
#   dimension: in_school {
#     type: number
#     sql: ${TABLE}.in_school ;;
#   }
#
#   dimension: in_undergrad_college {
#     type: number
#     sql: ${TABLE}.in_undergrad_college ;;
#   }
#
#   dimension: less_than_high_school_graduate {
#     type: number
#     sql: ${TABLE}.less_than_high_school_graduate ;;
#   }
#
#   dimension: male_45_64_associates_degree {
#     type: number
#     sql: ${TABLE}.male_45_64_associates_degree ;;
#   }
#
#   dimension: male_45_64_bachelors_degree {
#     type: number
#     sql: ${TABLE}.male_45_64_bachelors_degree ;;
#   }
#
#   dimension: male_45_64_graduate_degree {
#     type: number
#     sql: ${TABLE}.male_45_64_graduate_degree ;;
#   }
#
#   dimension: male_45_64_less_than_9_grade {
#     type: number
#     sql: ${TABLE}.male_45_64_less_than_9_grade ;;
#   }
#
#   dimension: male_45_64_grade_9_12 {
#     type: number
#     sql: ${TABLE}.male_45_64_grade_9_12 ;;
#   }
#
#   dimension: male_45_64_high_school {
#     type: number
#     sql: ${TABLE}.male_45_64_high_school ;;
#   }
#
#   dimension: male_45_64_some_college {
#     type: number
#     sql: ${TABLE}.male_45_64_some_college ;;
#   }
#
#   dimension: male_45_to_64 {
#     type: number
#     sql: ${TABLE}.male_45_to_64 ;;
#   }
#
#   dimension: male_male_households {
#     type: number
#     sql: ${TABLE}.male_male_households ;;
#   }
#
#   dimension: management_business_sci_arts_employed {
#     type: number
#     sql: ${TABLE}.management_business_sci_arts_employed ;;
#   }
#
#   dimension: no_car {
#     type: number
#     sql: ${TABLE}.no_car ;;
#   }
#
#   dimension: no_cars {
#     type: number
#     sql: ${TABLE}.no_cars ;;
#   }
#
#   dimension: not_us_citizen_pop {
#     type: number
#     sql: ${TABLE}.not_us_citizen_pop ;;
#   }
  }

view: national_averages {
  derived_table: {
    datagroup_trigger: once_yearly
    explore_source: acs_zip_codes_2017_5yr {
      column: percent_above_70 {}
      column: average_population_density {}
      column: average_median_income {}
      derived_column: x {
        sql: 'x' ;;
      }
    }
  }
  dimension: x { primary_key: yes hidden: yes }
  dimension: percent_above_70 { hidden:yes type: number }
  dimension: average_population_density { hidden:yes type: number }
  dimension: average_median_income { hidden:yes type: number }
  measure: national_percent_above_70 { type: min sql: ${percent_above_70} ;; }
  measure: national_average_population_density { type: min sql: ${average_population_density} ;; }
  measure: national_median_income { type: min sql: ${average_median_income} ;; }
}


###########
## Low Priority  ##
###########

##### Fix date in observations

# view: observation__effective__period {
#   dimension: end {
#     type: string
#     sql: ${TABLE}.`end` ;;
#   }

#   dimension: start {
#     type: string
#     sql: ${TABLE}.start ;;
#   }
# }

# view: observation__effective {
#   label: "Observation"
#   dimension_group: date {
#     group_label: "*Populated {{_view._name | capitalize | replace:'_',' '}}"
#     type: time
#     timeframes: [
#       raw,
#       time,
#       date,
#       week,
#       month,
#       quarter,
#       year
#     ]
#     sql: CAST(${TABLE}.dateTime as timestamp) ;;
#   }

#   dimension: period {
#     hidden: yes
#     sql: ${TABLE}.period ;;
#   }
# }

#   # Uncomment the line starting with observation__effective__period in ccf.model.
#   # If it's not there add this to the observation explore:
#   # join: observation__effective__period { relationship: many_to_one sql: LEFT JOIN UNNEST([${observation__effective.period}]) as observation__effective__period ;; }
#   # Manually re-run tests to see if start and end are populated.


###########
## Add to files  ##
###########

##### Add to observations

#   ## added for FK
#   dimension: value__quantity {
#     hidden: yes
#     sql: ${value}.quantity ;;
#   }
#   dimension: value__quantity_value {
#     hidden: yes
#     sql: ${value__quantity}.value ;;
#   }

# # Added for FK
# dimension: code__coding {
#   hidden: yes
#   sql: ${code}.coding ;;
# }
# dimension: code__coding_code {
#   hidden: yes
#   sql: ${code__coding}.code ;;
# }

##### Add to encounters

## Step 1: Add sql_always_where to encounter explore

# sql_always_where: length(${encounter.id}) < 15 ;;

## Step 2: Set up PK

# dimension: pk {
#   primary_key: yes
#   hidden: yes
#   type: string
#   sql: ${id} ;;
# }

# measure: count_pk {
#   type: count_distinct
#   sql: ${pk} ;;
# }

##### Add to Patients

## Step 1: Add sql_always_where to patient explore - what is correct length?!?!

# sql_always_where: length(${patient.id}) < 15 ;;

## Step 2: Set up PK

# dimension: pk {
#   primary_key: yes
#   hidden: yes
#   type: string
#   sql: ${id} ;;
# }

# measure: count_pk {
#   type: count_distinct
#   sql: ${pk} ;;
# }

###########
## FK ##
###########

# ## Method 1: Build a
#
# view: identifier_condition_fk {derived_table: {explore_source: fhir_hcls { bind_filters: { from_field: analytics.admission_date to_field: analytics.admission_date } column: id { field: encounter.id } column: condition_id { field: encounter__diagnosis__condition.condition_id }}} dimension: id {} dimension: condition_id {}}
#
# explore: shortcut_encounter { hidden: yes }
# explore: shortcut_patient { hidden: yes }
# explore: shortcut_condition { hidden: yes }
# explore: shortcut_observation { hidden: yes }
# explore: shortcut_practitioner { hidden: yes }
# explore: shortcut_location { hidden: yes }
# explore: shortcut_encounter_condition_id {hidden: yes }
#
# view: shortcut_encounter {
#   derived_table: {
#     explore_source: encounter {
#       column: id { field: encounter.id }
#       column: code { field: encounter__identifier__type__coding.code }
#       column: value { field: encounter__identifier.value }
#       column: condition_id { field: encounter__diagnosis__condition.condition_id }
#       column: practitioner_id { field: encounter__participant__individual.practitioner_id }
#       column: location_id { field: encounter__location__location.location_id }
#       column: patient_id { field: encounter__subject.patient_id }
#       filters: {
#         field: encounter__period.start_time
#         value: "60 minutes"
#       }
#     }
#   }
#   dimension: id {}
#   dimension: code {}
#   dimension: value {}
#   dimension: condition_id {}
#   dimension: practitioner_id {}
#   dimension: location_id {}
#   dimension: patient_id {}
# }
# view: shortcut_encounter_condition_id {
#   derived_table: {
#     explore_source: encounter {
#       column: id { field: encounter.id }
#       column: condition_id { field: encounter__diagnosis.diagnosis__condition__condition_id }
#       filters: {
#         field: encounter__period.start_date
#         value: "60 days"
#       }
#     }
#   }
#   dimension: id {}
#   dimension: condition_id {}
# }
#
# view: shortcut_encounter_condition_id_data {
#   sql_table_name: `ccf-cdw-bq-staging.batch_loads.encounter_condition` ;;
#   extends: [shortcut_encounter_condition_id]
# }
#
#
#
# view: shortcut_patient {
#   derived_table: {
#     explore_source: patient {
#       column: id {}
#       column: code { field: patient__identifier__type__coding.code }
#       column: value { field: patient__identifier.value }
#       filters: {
#         field: patient__meta.last_updated_time
#         value: "60 seconds"
#       }
#     }
#   }
#   dimension: id {}
#   dimension: code {}
#   dimension: value {}
# }
#
# view: shortcut_condition {
#   derived_table: {
#     explore_source: condition {
#       column: id {}
#       column: code { field: condition__identifier__type__coding.code }
#       filters: {
#         field: condition__meta.last_updated_time
#         value: "60 minutes"
#       }
#     }
#   }
#   dimension: id {}
#   dimension: code {}
# }
#
# view: shortcut_observation {
#   derived_table: {
#     explore_source: observation {
#       column: id {}
#       column: code { field: observation__code__coding.code }
#       column: value { field: observation__value__quantity.value }
#       column: unit { field: observation__value__quantity.unit }
#       filters: {
#         field: observation__meta.last_updated_time
#         value: "60 minutes"
#       }
#     }
#   }
#   dimension: id {}
#   dimension: code {}
#   dimension: value { type: number }
#   dimension: unit {}
# }
#
# view: shortcut_practitioner {
#   derived_table: {
#     explore_source: practitioner {
#       column: id {}
#       column: code { field: practitioner__identifier__type__coding.code }
#       column: value { field: practitioner__identifier.value }
#       filters: {
#         field: practitioner__meta.last_updated_time
#         value: "60 minutes"
#       }
#     }
#   }
#   dimension: id {}
#   dimension: code {}
#   dimension: value {}
# }
#
# view: shortcut_location {
#   derived_table: {
#     explore_source: location {
#       column: id {}
#       column: code { field: location__physical_type__coding.code }
#       column: name {}
#       filters: {
#         field: location__meta.last_updated_time
#         value: "60 minutes"
#       }
#     }
#   }
#   dimension: id {}
#   dimension: code {}
#   dimension: name {}
# }
#
# # view: fk_normalize {
# #   derived_table: {
# #     datagroup_trigger: once_weekly
# #     explore_source: fhir_hcls {
# #       column: id { field: encounter.id }
# #       column: condition_id { field: encounter__diagnosis__condition.condition_id }
# #       column: practitioner_id { field: encounter__participant__individual.practitioner_id }
# #       column: location_id { field: encounter__location__location.location_id }
# #       column: patient_id { field: encounter__subject.patient_id }
# #     }
# #   }
# #   dimension: id {}
# #   dimension: condition_id {}
# #   dimension: practitioner_id {}
# #   dimension: location_id {}
# #   dimension: patient_id {}
# # }
# #
# # view: encounter_fk {
# #   derived_table: {
# #     datagroup_trigger: once_weekly
# #     sql:
# #
# #         SELECT
# #           a.*,
# #           b.condition_id,
# #           b.practitioner_id,
# #           b.location_id,
# #           b.patient_id
# #         FROM ${encounter.SQL_TABLE_NAME} a
# #         LEFT JOIN ${fk_normalize.SQL_TABLE_NAME} b
# #           ON a.id = b.id
# #         ;;
# #   }
# # }
# #
# # view: encounter__subject_unnest {
# #   sql_table_name: encounter.subject ;;
# #
# #   dimension: patient_id {
# #     group_label: "{{ _view._name }}"
# #     type: string
# #     sql: ${encounter__subject_unnest.SQL_TABLE_NAME}.patientId ;;
# #   }
# # }
