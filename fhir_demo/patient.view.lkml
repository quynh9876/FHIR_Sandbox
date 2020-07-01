view: patient {
  label: "Patient"
  sql_table_name: `bigquery-public-data.fhir_synthea.patient`
    ;;
  drill_fields: [id]

  dimension: id {
    group_label: "{{ _view._name }}"
    primary_key: yes
    type: string
    sql: ${TABLE}.id ;;
  }

  dimension: active {
    group_label: "{{ _view._name }}"
    type: yesno
    sql: ${TABLE}.active ;;
  }

  dimension: address {
    group_label: "{{ _view._name }}"
    hidden: yes
    sql: ${TABLE}.address ;;
  }

  dimension: animal {
    group_label: "{{ _view._name }}"
    hidden: yes
    sql: ${TABLE}.animal ;;
  }

  dimension_group: birth {
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
    sql: ${TABLE}.birthDate ;;
  }

  dimension: age {
    type: number
    sql: date_diff(current_date, ${birth_date}, year) ;;
  }

  dimension: age_tiers {
    type: tier
    tiers: [10,20,30,40,50,60,70,80,90]
    style: integer
    sql: ${age} ;;
  }

  dimension: birth_place {
    group_label: "{{ _view._name }}"
    hidden: yes
    sql: ${TABLE}.birthPlace ;;
  }

  dimension: communication {
    group_label: "{{ _view._name }}"
    hidden: yes
    sql: ${TABLE}.communication ;;
  }

  dimension: contact {
    group_label: "{{ _view._name }}"
    hidden: yes
    sql: ${TABLE}.contact ;;
  }

  dimension: deceased {
    group_label: "{{ _view._name }}"
    hidden: yes
    sql: ${TABLE}.deceased ;;
  }

  dimension: disability_adjusted_life_years {
    group_label: "{{ _view._name }}"
    hidden: yes
    sql: ${TABLE}.disability_adjusted_life_years ;;
  }

  dimension: gender {
    group_label: "{{ _view._name }}"
    type: string
    sql: ${TABLE}.gender ;;
  }

  dimension: general_practitioner {
    group_label: "{{ _view._name }}"
    hidden: yes
    sql: ${TABLE}.generalPractitioner ;;
  }

#   ## FK
#   dimension: general_practitioner__organization_id {
#     group_label: "{{ _view._name }}"
#     hidden: yes
#     sql: ${general_practitioner}.generalPractitioner ;;
#   }

  dimension: identifier {
    group_label: "{{ _view._name }}"
    hidden: yes
    sql: ${TABLE}.identifier ;;
  }

  dimension: implicit_rules {
    group_label: "{{ _view._name }}"
    type: string
    sql: ${TABLE}.implicitRules ;;
  }

  dimension: language {
    group_label: "{{ _view._name }}"
    type: string
    sql: ${TABLE}.language ;;
  }

  dimension: link {
    group_label: "{{ _view._name }}"
    hidden: yes
    sql: ${TABLE}.link ;;
  }

  dimension: managing_organization {
    group_label: "{{ _view._name }}"
    hidden: yes
    sql: ${TABLE}.managingOrganization ;;
  }

  dimension: marital_status {
    group_label: "{{ _view._name }}"
    hidden: yes
    sql: ${TABLE}.maritalStatus ;;
  }

  dimension: meta {
    group_label: "{{ _view._name }}"
    hidden: yes
    sql: ${TABLE}.meta ;;
  }

  dimension: multiple_birth {
    group_label: "{{ _view._name }}"
    hidden: yes
    sql: ${TABLE}.multipleBirth ;;
  }

  dimension: name {
    group_label: "{{ _view._name }}"
    hidden: yes
    sql: ${TABLE}.name ;;
  }

  dimension: patient_mothers_maiden_name {
    group_label: "{{ _view._name }}"
    hidden: yes
    sql: ${TABLE}.patient_mothersMaidenName ;;
  }

  dimension: photo {
    group_label: "{{ _view._name }}"
    hidden: yes
    sql: ${TABLE}.photo ;;
  }

  dimension: quality_adjusted_life_years {
    group_label: "{{ _view._name }}"
    hidden: yes
    sql: ${TABLE}.quality_adjusted_life_years ;;
  }

  dimension: shr_actor_fictional_person_extension {
    group_label: "{{ _view._name }}"
    hidden: yes
    sql: ${TABLE}.shr_actor_FictionalPerson_extension ;;
  }

  dimension: shr_demographics_social_security_number_extension {
    group_label: "{{ _view._name }}"
    hidden: yes
    sql: ${TABLE}.shr_demographics_SocialSecurityNumber_extension ;;
  }

  dimension: shr_entity_fathers_name_extension {
    group_label: "{{ _view._name }}"
    hidden: yes
    sql: ${TABLE}.shr_entity_FathersName_extension ;;
  }

  dimension: shr_entity_person_extension {
    group_label: "{{ _view._name }}"
    hidden: yes
    sql: ${TABLE}.shr_entity_Person_extension ;;
  }

  dimension: telecom {
    group_label: "{{ _view._name }}"
    hidden: yes
    sql: ${TABLE}.telecom ;;
  }

  dimension: text {
    group_label: "{{ _view._name }}"
    hidden: yes
    sql: ${TABLE}.text ;;
  }

  dimension: us_core_birthsex {
    group_label: "{{ _view._name }}"
    hidden: yes
    sql: ${TABLE}.us_core_birthsex ;;
  }

  dimension: us_core_ethnicity {
    group_label: "{{ _view._name }}"
    hidden: yes
    sql: ${TABLE}.us_core_ethnicity ;;
  }

  dimension: us_core_race {
    group_label: "{{ _view._name }}"
    hidden: yes
    sql: ${TABLE}.us_core_race ;;
  }

  measure: count {
    type: count
    drill_fields: [id, name, patient_mothers_maiden_name]
  }
}

view: patient__deceased {
  label: "Patient"
  dimension: boolean {
    group_label: "{{ _view._name }}"
    type: yesno
    sql: ${TABLE}.boolean ;;
  }

  dimension: date_time {
    group_label: "{{ _view._name }}"
    type: string
    sql: ${TABLE}.dateTime ;;
  }
}

view: patient__shr_actor_fictional_person_extension__value {
  label: "Patient"
  dimension: boolean {
    group_label: "{{ _view._name }}"
    type: yesno
    sql: ${TABLE}.boolean ;;
  }
}

view: patient__us_core_race__text__value {
  label: "Patient"
  dimension: string {
    group_label: "{{ _view._name }}"
    type: string
    sql: ${TABLE}.string ;;
  }
}

view: patient__us_core_race__omb_category__value__coding {
  label: "Patient"
  dimension: code {
    group_label: "{{ _view._name }}"
    type: string
    sql: ${TABLE}.code ;;
  }

  dimension: display {
    group_label: "{{ _view._name }}"
    type: string
    sql: ${TABLE}.display ;;
  }

  dimension: system {
    group_label: "{{ _view._name }}"
    type: string
    sql: ${TABLE}.system ;;
  }
}

view: patient__link__other {
  label: "Patient"
  dimension: display {
    group_label: "{{ _view._name }}"
    type: string
    sql: ${TABLE}.display ;;
  }

  dimension: identifier {
    group_label: "{{ _view._name }}"
    hidden: yes
    sql: ${TABLE}.identifier ;;
  }

  dimension: patient_id {
    group_label: "{{ _view._name }}"
    type: string
    sql: ${TABLE}.patientId ;;
  }

  dimension: reference {
    group_label: "{{ _view._name }}"
    type: string
    sql: ${TABLE}.reference ;;
  }

  dimension: related_person_id {
    group_label: "{{ _view._name }}"
    type: string
    sql: ${TABLE}.relatedPersonId ;;
  }
}

view: patient__link__other__identifier__period {
  label: "Patient"
  dimension: end {
    group_label: "{{ _view._name }}"
    type: string
    sql: ${TABLE}.`end` ;;
  }

  dimension: start {
    group_label: "{{ _view._name }}"
    type: string
    sql: ${TABLE}.start ;;
  }
}

view: patient__link__other__identifier {
  label: "Patient"
  dimension: assigner {
    group_label: "{{ _view._name }}"
    hidden: yes
    sql: ${TABLE}.assigner ;;
  }

  dimension: period {
    group_label: "{{ _view._name }}"
    hidden: yes
    sql: ${TABLE}.period ;;
  }

  dimension: system {
    group_label: "{{ _view._name }}"
    type: string
    sql: ${TABLE}.system ;;
  }

  dimension: type {
    group_label: "{{ _view._name }}"
    hidden: yes
    sql: ${TABLE}.type ;;
  }

  dimension: use {
    group_label: "{{ _view._name }}"
    type: string
    sql: ${TABLE}.use ;;
  }

  dimension: value {
    group_label: "{{ _view._name }}"
    type: string
    sql: ${TABLE}.value ;;
  }
}

view: patient__link__other__identifier__assigner {
  label: "Patient"
  dimension: display {
    group_label: "{{ _view._name }}"
    type: string
    sql: ${TABLE}.display ;;
  }

  dimension: identifier {
    group_label: "{{ _view._name }}"
    hidden: yes
    sql: ${TABLE}.identifier ;;
  }

  dimension: organization_id {
    group_label: "{{ _view._name }}"
    type: string
    sql: ${TABLE}.organizationId ;;
  }

  dimension: reference {
    group_label: "{{ _view._name }}"
    type: string
    sql: ${TABLE}.reference ;;
  }
}

view: patient__link__other__identifier__assigner__identifier__period {
  label: "Patient"
  dimension: end {
    group_label: "{{ _view._name }}"
    type: string
    sql: ${TABLE}.`end` ;;
  }

  dimension: start {
    group_label: "{{ _view._name }}"
    type: string
    sql: ${TABLE}.start ;;
  }
}

view: patient__link__other__identifier__assigner__identifier {
  label: "Patient"
  dimension: assigner {
    group_label: "{{ _view._name }}"
    hidden: yes
    sql: ${TABLE}.assigner ;;
  }

  dimension: period {
    group_label: "{{ _view._name }}"
    hidden: yes
    sql: ${TABLE}.period ;;
  }

  dimension: system {
    group_label: "{{ _view._name }}"
    type: string
    sql: ${TABLE}.system ;;
  }

  dimension: type {
    group_label: "{{ _view._name }}"
    hidden: yes
    sql: ${TABLE}.type ;;
  }

  dimension: use {
    group_label: "{{ _view._name }}"
    type: string
    sql: ${TABLE}.use ;;
  }

  dimension: value {
    group_label: "{{ _view._name }}"
    type: string
    sql: ${TABLE}.value ;;
  }
}

view: patient__link__other__identifier__assigner__identifier__assigner {
  label: "Patient"
  dimension: display {
    group_label: "{{ _view._name }}"
    type: string
    sql: ${TABLE}.display ;;
  }

  dimension: organization_id {
    group_label: "{{ _view._name }}"
    type: string
    sql: ${TABLE}.organizationId ;;
  }

  dimension: reference {
    group_label: "{{ _view._name }}"
    type: string
    sql: ${TABLE}.reference ;;
  }
}

view: patient__link__other__identifier__assigner__identifier__type__coding {
  label: "Patient"
  dimension: code {
    group_label: "{{ _view._name }}"
    type: string
    sql: ${TABLE}.code ;;
  }

  dimension: display {
    group_label: "{{ _view._name }}"
    type: string
    sql: ${TABLE}.display ;;
  }

  dimension: system {
    group_label: "{{ _view._name }}"
    type: string
    sql: ${TABLE}.system ;;
  }

  dimension: user_selected {
    group_label: "{{ _view._name }}"
    type: yesno
    sql: ${TABLE}.userSelected ;;
  }

  dimension: version {
    group_label: "{{ _view._name }}"
    type: string
    sql: ${TABLE}.version ;;
  }
}

view: patient__link__other__identifier__assigner__identifier__type {
  label: "Patient"
  dimension: coding {
    group_label: "{{ _view._name }}"
    hidden: yes
    sql: ${TABLE}.coding ;;
  }

  dimension: text {
    group_label: "{{ _view._name }}"
    type: string
    sql: ${TABLE}.text ;;
  }
}

view: patient__link__other__identifier__type__coding {
  label: "Patient"
  dimension: code {
    group_label: "{{ _view._name }}"
    type: string
    sql: ${TABLE}.code ;;
  }

  dimension: display {
    group_label: "{{ _view._name }}"
    type: string
    sql: ${TABLE}.display ;;
  }

  dimension: system {
    group_label: "{{ _view._name }}"
    type: string
    sql: ${TABLE}.system ;;
  }

  dimension: user_selected {
    group_label: "{{ _view._name }}"
    type: yesno
    sql: ${TABLE}.userSelected ;;
  }

  dimension: version {
    group_label: "{{ _view._name }}"
    type: string
    sql: ${TABLE}.version ;;
  }
}

view: patient__link__other__identifier__type {
  label: "Patient"
  dimension: coding {
    group_label: "{{ _view._name }}"
    hidden: yes
    sql: ${TABLE}.coding ;;
  }

  dimension: text {
    group_label: "{{ _view._name }}"
    type: string
    sql: ${TABLE}.text ;;
  }
}

view: patient__link {
  label: "Patient"
  dimension: other {
    group_label: "{{ _view._name }}"
    hidden: yes
    sql: ${TABLE}.other ;;
  }

  dimension: type {
    group_label: "{{ _view._name }}"
    type: string
    sql: ${TABLE}.type ;;
  }
}

view: patient__disability_adjusted_life_years__value {
  label: "Patient"
  dimension: decimal {
    group_label: "{{ _view._name }}"
    type: number
    sql: ${TABLE}.decimal ;;
  }
}

view: patient__shr_entity_person_extension__value__reference {
  label: "Patient"
  dimension: basic_id {
    group_label: "{{ _view._name }}"
    type: string
    sql: ${TABLE}.basicId ;;
  }
}

view: patient__birth_place__value__address {
  label: "Patient"
  dimension: city {
    group_label: "{{ _view._name }}"
    type: string
    sql: ${TABLE}.city ;;
  }

  dimension: country {
    group_label: "{{ _view._name }}"
    type: string
    map_layer_name: countries
    sql: ${TABLE}.country ;;
  }

  dimension: state {
    group_label: "{{ _view._name }}"
    type: string
    sql: ${TABLE}.state ;;
  }
}

view: patient__contact__period {
  label: "Patient"
  dimension: end {
    group_label: "{{ _view._name }}"
    type: string
    sql: ${TABLE}.`end` ;;
  }

  dimension: start {
    group_label: "{{ _view._name }}"
    type: string
    sql: ${TABLE}.start ;;
  }
}

view: patient__contact__address {
  label: "Patient"
  dimension: city {
    group_label: "{{ _view._name }}"
    type: string
    sql: ${TABLE}.city ;;
  }

  dimension: country {
    group_label: "{{ _view._name }}"
    type: string
    map_layer_name: countries
    sql: ${TABLE}.country ;;
  }

  dimension: district {
    group_label: "{{ _view._name }}"
    type: string
    sql: ${TABLE}.district ;;
  }

  dimension: line {
    group_label: "{{ _view._name }}"
    type: string
    sql: ${TABLE}.line ;;
  }

  dimension: period {
    group_label: "{{ _view._name }}"
    hidden: yes
    sql: ${TABLE}.period ;;
  }

  dimension: postal_code {
    group_label: "{{ _view._name }}"
    type: string
    sql: ${TABLE}.postalCode ;;
  }

  dimension: state {
    group_label: "{{ _view._name }}"
    type: string
    sql: ${TABLE}.state ;;
  }

  dimension: text {
    group_label: "{{ _view._name }}"
    type: string
    sql: ${TABLE}.text ;;
  }

  dimension: type {
    group_label: "{{ _view._name }}"
    type: string
    sql: ${TABLE}.type ;;
  }

  dimension: use {
    group_label: "{{ _view._name }}"
    type: string
    sql: ${TABLE}.use ;;
  }
}

view: patient__contact__address__period {
  label: "Patient"
  dimension: end {
    group_label: "{{ _view._name }}"
    type: string
    sql: ${TABLE}.`end` ;;
  }

  dimension: start {
    group_label: "{{ _view._name }}"
    type: string
    sql: ${TABLE}.start ;;
  }
}

view: patient__contact {
  label: "Patient"
  dimension: address {
    group_label: "{{ _view._name }}"
    hidden: yes
    sql: ${TABLE}.address ;;
  }

  dimension: gender {
    group_label: "{{ _view._name }}"
    type: string
    sql: ${TABLE}.gender ;;
  }

  dimension: name {
    group_label: "{{ _view._name }}"
    hidden: yes
    sql: ${TABLE}.name ;;
  }

  dimension: organization {
    group_label: "{{ _view._name }}"
    hidden: yes
    sql: ${TABLE}.organization ;;
  }

  dimension: period {
    group_label: "{{ _view._name }}"
    hidden: yes
    sql: ${TABLE}.period ;;
  }

  dimension: relationship {
    group_label: "{{ _view._name }}"
    hidden: yes
    sql: ${TABLE}.relationship ;;
  }

  dimension: telecom {
    group_label: "{{ _view._name }}"
    hidden: yes
    sql: ${TABLE}.telecom ;;
  }
}

view: patient__contact__organization {
  label: "Patient"
  dimension: display {
    group_label: "{{ _view._name }}"
    type: string
    sql: ${TABLE}.display ;;
  }

  dimension: identifier {
    group_label: "{{ _view._name }}"
    hidden: yes
    sql: ${TABLE}.identifier ;;
  }

  dimension: organization_id {
    group_label: "{{ _view._name }}"
    type: string
    sql: ${TABLE}.organizationId ;;
  }

  dimension: reference {
    group_label: "{{ _view._name }}"
    type: string
    sql: ${TABLE}.reference ;;
  }
}

view: patient__contact__organization__identifier__period {
  label: "Patient"
  dimension: end {
    group_label: "{{ _view._name }}"
    type: string
    sql: ${TABLE}.`end` ;;
  }

  dimension: start {
    group_label: "{{ _view._name }}"
    type: string
    sql: ${TABLE}.start ;;
  }
}

view: patient__contact__organization__identifier {
  label: "Patient"
  dimension: assigner {
    group_label: "{{ _view._name }}"
    hidden: yes
    sql: ${TABLE}.assigner ;;
  }

  dimension: period {
    group_label: "{{ _view._name }}"
    hidden: yes
    sql: ${TABLE}.period ;;
  }

  dimension: system {
    group_label: "{{ _view._name }}"
    type: string
    sql: ${TABLE}.system ;;
  }

  dimension: type {
    group_label: "{{ _view._name }}"
    hidden: yes
    sql: ${TABLE}.type ;;
  }

  dimension: use {
    group_label: "{{ _view._name }}"
    type: string
    sql: ${TABLE}.use ;;
  }

  dimension: value {
    group_label: "{{ _view._name }}"
    type: string
    sql: ${TABLE}.value ;;
  }
}

view: patient__contact__organization__identifier__assigner {
  label: "Patient"
  dimension: display {
    group_label: "{{ _view._name }}"
    type: string
    sql: ${TABLE}.display ;;
  }

  dimension: identifier {
    group_label: "{{ _view._name }}"
    hidden: yes
    sql: ${TABLE}.identifier ;;
  }

  dimension: organization_id {
    group_label: "{{ _view._name }}"
    type: string
    sql: ${TABLE}.organizationId ;;
  }

  dimension: reference {
    group_label: "{{ _view._name }}"
    type: string
    sql: ${TABLE}.reference ;;
  }
}

view: patient__contact__organization__identifier__assigner__identifier__period {
  label: "Patient"
  dimension: end {
    group_label: "{{ _view._name }}"
    type: string
    sql: ${TABLE}.`end` ;;
  }

  dimension: start {
    group_label: "{{ _view._name }}"
    type: string
    sql: ${TABLE}.start ;;
  }
}

view: patient__contact__organization__identifier__assigner__identifier {
  label: "Patient"
  dimension: assigner {
    group_label: "{{ _view._name }}"
    hidden: yes
    sql: ${TABLE}.assigner ;;
  }

  dimension: period {
    group_label: "{{ _view._name }}"
    hidden: yes
    sql: ${TABLE}.period ;;
  }

  dimension: system {
    group_label: "{{ _view._name }}"
    type: string
    sql: ${TABLE}.system ;;
  }

  dimension: type {
    group_label: "{{ _view._name }}"
    hidden: yes
    sql: ${TABLE}.type ;;
  }

  dimension: use {
    group_label: "{{ _view._name }}"
    type: string
    sql: ${TABLE}.use ;;
  }

  dimension: value {
    group_label: "{{ _view._name }}"
    type: string
    sql: ${TABLE}.value ;;
  }
}

view: patient__contact__organization__identifier__assigner__identifier__assigner {
  label: "Patient"
  dimension: display {
    group_label: "{{ _view._name }}"
    type: string
    sql: ${TABLE}.display ;;
  }

  dimension: organization_id {
    group_label: "{{ _view._name }}"
    type: string
    sql: ${TABLE}.organizationId ;;
  }

  dimension: reference {
    group_label: "{{ _view._name }}"
    type: string
    sql: ${TABLE}.reference ;;
  }
}

view: patient__contact__organization__identifier__assigner__identifier__type__coding {
  label: "Patient"
  dimension: code {
    group_label: "{{ _view._name }}"
    type: string
    sql: ${TABLE}.code ;;
  }

  dimension: display {
    group_label: "{{ _view._name }}"
    type: string
    sql: ${TABLE}.display ;;
  }

  dimension: system {
    group_label: "{{ _view._name }}"
    type: string
    sql: ${TABLE}.system ;;
  }

  dimension: user_selected {
    group_label: "{{ _view._name }}"
    type: yesno
    sql: ${TABLE}.userSelected ;;
  }

  dimension: version {
    group_label: "{{ _view._name }}"
    type: string
    sql: ${TABLE}.version ;;
  }
}

view: patient__contact__organization__identifier__assigner__identifier__type {
  label: "Patient"
  dimension: coding {
    group_label: "{{ _view._name }}"
    hidden: yes
    sql: ${TABLE}.coding ;;
  }

  dimension: text {
    group_label: "{{ _view._name }}"
    type: string
    sql: ${TABLE}.text ;;
  }
}

view: patient__contact__organization__identifier__type__coding {
  label: "Patient"
  dimension: code {
    group_label: "{{ _view._name }}"
    type: string
    sql: ${TABLE}.code ;;
  }

  dimension: display {
    group_label: "{{ _view._name }}"
    type: string
    sql: ${TABLE}.display ;;
  }

  dimension: system {
    group_label: "{{ _view._name }}"
    type: string
    sql: ${TABLE}.system ;;
  }

  dimension: user_selected {
    group_label: "{{ _view._name }}"
    type: yesno
    sql: ${TABLE}.userSelected ;;
  }

  dimension: version {
    group_label: "{{ _view._name }}"
    type: string
    sql: ${TABLE}.version ;;
  }
}

view: patient__contact__organization__identifier__type {
  label: "Patient"
  dimension: coding {
    group_label: "{{ _view._name }}"
    hidden: yes
    sql: ${TABLE}.coding ;;
  }

  dimension: text {
    group_label: "{{ _view._name }}"
    type: string
    sql: ${TABLE}.text ;;
  }
}

view: patient__contact__name {
  label: "Patient"
  dimension: family {
    group_label: "{{ _view._name }}"
    type: string
    sql: ${TABLE}.family ;;
  }

  dimension: given {
    group_label: "{{ _view._name }}"
    type: string
    sql: ${TABLE}.given ;;
  }

  dimension: period {
    group_label: "{{ _view._name }}"
    hidden: yes
    sql: ${TABLE}.period ;;
  }

  dimension: prefix {
    group_label: "{{ _view._name }}"
    type: string
    sql: ${TABLE}.prefix ;;
  }

  dimension: suffix {
    group_label: "{{ _view._name }}"
    type: string
    sql: ${TABLE}.suffix ;;
  }

  dimension: text {
    group_label: "{{ _view._name }}"
    type: string
    sql: ${TABLE}.text ;;
  }

  dimension: use {
    group_label: "{{ _view._name }}"
    type: string
    sql: ${TABLE}.use ;;
  }
}

view: patient__contact__name__period {
  label: "Patient"
  dimension: end {
    group_label: "{{ _view._name }}"
    type: string
    sql: ${TABLE}.`end` ;;
  }

  dimension: start {
    group_label: "{{ _view._name }}"
    type: string
    sql: ${TABLE}.start ;;
  }
}

view: patient__contact__telecom__period {
  label: "Patient"
  dimension: end {
    group_label: "{{ _view._name }}"
    type: string
    sql: ${TABLE}.`end` ;;
  }

  dimension: start {
    group_label: "{{ _view._name }}"
    type: string
    sql: ${TABLE}.start ;;
  }
}

view: patient__contact__telecom {
  label: "Patient"
  dimension: period {
    group_label: "{{ _view._name }}"
    hidden: yes
    sql: ${TABLE}.period ;;
  }

  dimension: rank {
    group_label: "{{ _view._name }}"
    type: number
    sql: ${TABLE}.rank ;;
  }

  dimension: system {
    group_label: "{{ _view._name }}"
    type: string
    sql: ${TABLE}.system ;;
  }

  dimension: use {
    group_label: "{{ _view._name }}"
    type: string
    sql: ${TABLE}.use ;;
  }

  dimension: value {
    group_label: "{{ _view._name }}"
    type: string
    sql: ${TABLE}.value ;;
  }
}

view: patient__contact__relationship__coding {
  label: "Patient"
  dimension: code {
    group_label: "{{ _view._name }}"
    type: string
    sql: ${TABLE}.code ;;
  }

  dimension: display {
    group_label: "{{ _view._name }}"
    type: string
    sql: ${TABLE}.display ;;
  }

  dimension: system {
    group_label: "{{ _view._name }}"
    type: string
    sql: ${TABLE}.system ;;
  }

  dimension: user_selected {
    group_label: "{{ _view._name }}"
    type: yesno
    sql: ${TABLE}.userSelected ;;
  }

  dimension: version {
    group_label: "{{ _view._name }}"
    type: string
    sql: ${TABLE}.version ;;
  }
}

view: patient__contact__relationship {
  label: "Patient"
  dimension: coding {
    group_label: "{{ _view._name }}"
    hidden: yes
    sql: ${TABLE}.coding ;;
  }

  dimension: text {
    group_label: "{{ _view._name }}"
    type: string
    sql: ${TABLE}.text ;;
  }
}

view: patient__general_practitioner {
  label: "Patient"
  dimension: display {
    group_label: "{{ _view._name }}"
    type: string
    sql: ${TABLE}.display ;;
  }

  dimension: identifier {
    group_label: "{{ _view._name }}"
    hidden: yes
    sql: ${TABLE}.identifier ;;
  }

  dimension: organization_id {
    group_label: "{{ _view._name }}"
    type: string
    sql: ${TABLE}.organizationId ;;
  }

  dimension: practitioner_id {
    group_label: "{{ _view._name }}"
    type: string
    sql: ${TABLE}.practitionerId ;;
  }

  dimension: reference {
    group_label: "{{ _view._name }}"
    type: string
    sql: ${TABLE}.reference ;;
  }
}

view: patient__general_practitioner__identifier__period {
  label: "Patient"
  dimension: end {
    group_label: "{{ _view._name }}"
    type: string
    sql: ${TABLE}.`end` ;;
  }

  dimension: start {
    group_label: "{{ _view._name }}"
    type: string
    sql: ${TABLE}.start ;;
  }
}

view: patient__general_practitioner__identifier {
  label: "Patient"
  dimension: assigner {
    group_label: "{{ _view._name }}"
    hidden: yes
    sql: ${TABLE}.assigner ;;
  }

  dimension: period {
    group_label: "{{ _view._name }}"
    hidden: yes
    sql: ${TABLE}.period ;;
  }

  dimension: system {
    group_label: "{{ _view._name }}"
    type: string
    sql: ${TABLE}.system ;;
  }

  dimension: type {
    group_label: "{{ _view._name }}"
    hidden: yes
    sql: ${TABLE}.type ;;
  }

  dimension: use {
    group_label: "{{ _view._name }}"
    type: string
    sql: ${TABLE}.use ;;
  }

  dimension: value {
    group_label: "{{ _view._name }}"
    type: string
    sql: ${TABLE}.value ;;
  }
}

view: patient__general_practitioner__identifier__assigner {
  label: "Patient"
  dimension: display {
    group_label: "{{ _view._name }}"
    type: string
    sql: ${TABLE}.display ;;
  }

  dimension: identifier {
    group_label: "{{ _view._name }}"
    hidden: yes
    sql: ${TABLE}.identifier ;;
  }

  dimension: organization_id {
    group_label: "{{ _view._name }}"
    type: string
    sql: ${TABLE}.organizationId ;;
  }

  dimension: reference {
    group_label: "{{ _view._name }}"
    type: string
    sql: ${TABLE}.reference ;;
  }
}

view: patient__general_practitioner__identifier__assigner__identifier__period {
  label: "Patient"
  dimension: end {
    group_label: "{{ _view._name }}"
    type: string
    sql: ${TABLE}.`end` ;;
  }

  dimension: start {
    group_label: "{{ _view._name }}"
    type: string
    sql: ${TABLE}.start ;;
  }
}

view: patient__general_practitioner__identifier__assigner__identifier {
  label: "Patient"
  dimension: assigner {
    group_label: "{{ _view._name }}"
    hidden: yes
    sql: ${TABLE}.assigner ;;
  }

  dimension: period {
    group_label: "{{ _view._name }}"
    hidden: yes
    sql: ${TABLE}.period ;;
  }

  dimension: system {
    group_label: "{{ _view._name }}"
    type: string
    sql: ${TABLE}.system ;;
  }

  dimension: type {
    group_label: "{{ _view._name }}"
    hidden: yes
    sql: ${TABLE}.type ;;
  }

  dimension: use {
    group_label: "{{ _view._name }}"
    type: string
    sql: ${TABLE}.use ;;
  }

  dimension: value {
    group_label: "{{ _view._name }}"
    type: string
    sql: ${TABLE}.value ;;
  }
}

view: patient__general_practitioner__identifier__assigner__identifier__assigner {
  label: "Patient"
  dimension: display {
    group_label: "{{ _view._name }}"
    type: string
    sql: ${TABLE}.display ;;
  }

  dimension: organization_id {
    group_label: "{{ _view._name }}"
    type: string
    sql: ${TABLE}.organizationId ;;
  }

  dimension: reference {
    group_label: "{{ _view._name }}"
    type: string
    sql: ${TABLE}.reference ;;
  }
}

view: patient__general_practitioner__identifier__assigner__identifier__type__coding {
  label: "Patient"
  dimension: code {
    group_label: "{{ _view._name }}"
    type: string
    sql: ${TABLE}.code ;;
  }

  dimension: display {
    group_label: "{{ _view._name }}"
    type: string
    sql: ${TABLE}.display ;;
  }

  dimension: system {
    group_label: "{{ _view._name }}"
    type: string
    sql: ${TABLE}.system ;;
  }

  dimension: user_selected {
    group_label: "{{ _view._name }}"
    type: yesno
    sql: ${TABLE}.userSelected ;;
  }

  dimension: version {
    group_label: "{{ _view._name }}"
    type: string
    sql: ${TABLE}.version ;;
  }
}

view: patient__general_practitioner__identifier__assigner__identifier__type {
  label: "Patient"
  dimension: coding {
    group_label: "{{ _view._name }}"
    hidden: yes
    sql: ${TABLE}.coding ;;
  }

  dimension: text {
    group_label: "{{ _view._name }}"
    type: string
    sql: ${TABLE}.text ;;
  }
}

view: patient__general_practitioner__identifier__type__coding {
  label: "Patient"
  dimension: code {
    group_label: "{{ _view._name }}"
    type: string
    sql: ${TABLE}.code ;;
  }

  dimension: display {
    group_label: "{{ _view._name }}"
    type: string
    sql: ${TABLE}.display ;;
  }

  dimension: system {
    group_label: "{{ _view._name }}"
    type: string
    sql: ${TABLE}.system ;;
  }

  dimension: user_selected {
    group_label: "{{ _view._name }}"
    type: yesno
    sql: ${TABLE}.userSelected ;;
  }

  dimension: version {
    group_label: "{{ _view._name }}"
    type: string
    sql: ${TABLE}.version ;;
  }
}

view: patient__general_practitioner__identifier__type {
  label: "Patient"
  dimension: coding {
    group_label: "{{ _view._name }}"
    hidden: yes
    sql: ${TABLE}.coding ;;
  }

  dimension: text {
    group_label: "{{ _view._name }}"
    type: string
    sql: ${TABLE}.text ;;
  }
}

view: patient__telecom__period {
  label: "Patient"
  dimension: end {
    group_label: "{{ _view._name }}"
    type: string
    sql: ${TABLE}.`end` ;;
  }

  dimension: start {
    group_label: "{{ _view._name }}"
    type: string
    sql: ${TABLE}.start ;;
  }
}

view: patient__telecom {
  label: "Patient"
  dimension: period {
    group_label: "{{ _view._name }}"
    hidden: yes
    sql: ${TABLE}.period ;;
  }

  dimension: rank {
    group_label: "{{ _view._name }}"
    type: number
    sql: ${TABLE}.rank ;;
  }

  dimension: system {
    group_label: "{{ _view._name }}"
    type: string
    sql: ${TABLE}.system ;;
  }

  dimension: use {
    group_label: "{{ _view._name }}"
    type: string
    sql: ${TABLE}.use ;;
  }

  dimension: value {
    group_label: "{{ _view._name }}"
    type: string
    sql: ${TABLE}.value ;;
  }
}

view: patient__text {
  label: "Patient"
  dimension: div {
    group_label: "{{ _view._name }}"
    type: string
    sql: ${TABLE}.div ;;
  }

  dimension: status {
    group_label: "{{ _view._name }}"
    type: string
    sql: ${TABLE}.status ;;
  }
}

view: patient__communication__language__coding {
  label: "Patient"
  dimension: code {
    group_label: "{{ _view._name }}"
    type: string
    sql: ${TABLE}.code ;;
  }

  dimension: display {
    group_label: "{{ _view._name }}"
    type: string
    sql: ${TABLE}.display ;;
  }

  dimension: system {
    group_label: "{{ _view._name }}"
    type: string
    sql: ${TABLE}.system ;;
  }

  dimension: user_selected {
    group_label: "{{ _view._name }}"
    type: yesno
    sql: ${TABLE}.userSelected ;;
  }

  dimension: version {
    group_label: "{{ _view._name }}"
    type: string
    sql: ${TABLE}.version ;;
  }
}

view: patient__communication__language {
  label: "Patient"
  dimension: coding {
    group_label: "{{ _view._name }}"
    hidden: yes
    sql: ${TABLE}.coding ;;
  }

  dimension: text {
    group_label: "{{ _view._name }}"
    type: string
    sql: ${TABLE}.text ;;
  }
}

view: patient__communication {
  label: "Patient"
  dimension: language {
    group_label: "{{ _view._name }}"
    hidden: yes
    sql: ${TABLE}.language ;;
  }

  dimension: preferred {
    group_label: "{{ _view._name }}"
    type: yesno
    sql: ${TABLE}.preferred ;;
  }
}

view: patient__us_core_ethnicity__text__value {
  label: "Patient"
  dimension: string {
    group_label: "{{ _view._name }}"
    type: string
    sql: ${TABLE}.string ;;
  }
}

view: patient__us_core_ethnicity__omb_category__value__coding {
  label: "Patient"
  dimension: code {
    group_label: "{{ _view._name }}"
    type: string
    sql: ${TABLE}.code ;;
  }

  dimension: display {
    group_label: "{{ _view._name }}"
    type: string
    sql: ${TABLE}.display ;;
  }

  dimension: system {
    group_label: "{{ _view._name }}"
    type: string
    sql: ${TABLE}.system ;;
  }
}

view: patient__identifier__period {
  label: "Patient"
  dimension: end {
    group_label: "{{ _view._name }}"
    type: string
    sql: ${TABLE}.`end` ;;
  }

  dimension: start {
    group_label: "{{ _view._name }}"
    type: string
    sql: ${TABLE}.start ;;
  }
}

view: patient__identifier {
  label: "Patient"
  dimension: assigner {
    group_label: "{{ _view._name }}"
    hidden: yes
    sql: ${TABLE}.assigner ;;
  }

  dimension: period {
    group_label: "{{ _view._name }}"
    hidden: yes
    sql: ${TABLE}.period ;;
  }

  dimension: system {
    group_label: "{{ _view._name }}"
    type: string
    sql: ${TABLE}.system ;;
  }

  dimension: type {
    group_label: "{{ _view._name }}"
    hidden: yes
    sql: ${TABLE}.type ;;
  }

  dimension: use {
    group_label: "{{ _view._name }}"
    type: string
    sql: ${TABLE}.use ;;
  }

  dimension: value {
    group_label: "{{ _view._name }}"
    type: string
    sql: ${TABLE}.value ;;
  }
}

view: patient__identifier__assigner {
  label: "Patient"
  dimension: display {
    group_label: "{{ _view._name }}"
    type: string
    sql: ${TABLE}.display ;;
  }

  dimension: identifier {
    group_label: "{{ _view._name }}"
    hidden: yes
    sql: ${TABLE}.identifier ;;
  }

  dimension: organization_id {
    group_label: "{{ _view._name }}"
    type: string
    sql: ${TABLE}.organizationId ;;
  }

  dimension: reference {
    group_label: "{{ _view._name }}"
    type: string
    sql: ${TABLE}.reference ;;
  }
}

view: patient__identifier__assigner__identifier__period {
  label: "Patient"
  dimension: end {
    group_label: "{{ _view._name }}"
    type: string
    sql: ${TABLE}.`end` ;;
  }

  dimension: start {
    group_label: "{{ _view._name }}"
    type: string
    sql: ${TABLE}.start ;;
  }
}

view: patient__identifier__assigner__identifier {
  label: "Patient"
  dimension: assigner {
    group_label: "{{ _view._name }}"
    hidden: yes
    sql: ${TABLE}.assigner ;;
  }

  dimension: period {
    group_label: "{{ _view._name }}"
    hidden: yes
    sql: ${TABLE}.period ;;
  }

  dimension: system {
    group_label: "{{ _view._name }}"
    type: string
    sql: ${TABLE}.system ;;
  }

  dimension: type {
    group_label: "{{ _view._name }}"
    hidden: yes
    sql: ${TABLE}.type ;;
  }

  dimension: use {
    group_label: "{{ _view._name }}"
    type: string
    sql: ${TABLE}.use ;;
  }

  dimension: value {
    group_label: "{{ _view._name }}"
    type: string
    sql: ${TABLE}.value ;;
  }
}

view: patient__identifier__assigner__identifier__assigner {
  label: "Patient"
  dimension: display {
    group_label: "{{ _view._name }}"
    type: string
    sql: ${TABLE}.display ;;
  }

  dimension: organization_id {
    group_label: "{{ _view._name }}"
    type: string
    sql: ${TABLE}.organizationId ;;
  }

  dimension: reference {
    group_label: "{{ _view._name }}"
    type: string
    sql: ${TABLE}.reference ;;
  }
}

view: patient__identifier__assigner__identifier__type__coding {
  label: "Patient"
  dimension: code {
    group_label: "{{ _view._name }}"
    type: string
    sql: ${TABLE}.code ;;
  }

  dimension: display {
    group_label: "{{ _view._name }}"
    type: string
    sql: ${TABLE}.display ;;
  }

  dimension: system {
    group_label: "{{ _view._name }}"
    type: string
    sql: ${TABLE}.system ;;
  }

  dimension: user_selected {
    group_label: "{{ _view._name }}"
    type: yesno
    sql: ${TABLE}.userSelected ;;
  }

  dimension: version {
    group_label: "{{ _view._name }}"
    type: string
    sql: ${TABLE}.version ;;
  }
}

view: patient__identifier__assigner__identifier__type {
  label: "Patient"
  dimension: coding {
    group_label: "{{ _view._name }}"
    hidden: yes
    sql: ${TABLE}.coding ;;
  }

  dimension: text {
    group_label: "{{ _view._name }}"
    type: string
    sql: ${TABLE}.text ;;
  }
}

view: patient__identifier__type__coding {
  label: "Patient"
  dimension: code {
    group_label: "{{ _view._name }}"
    type: string
    sql: ${TABLE}.code ;;
  }

  dimension: display {
    group_label: "{{ _view._name }}"
    type: string
    sql: ${TABLE}.display ;;
  }

  dimension: system {
    group_label: "{{ _view._name }}"
    type: string
    sql: ${TABLE}.system ;;
  }

  dimension: user_selected {
    group_label: "{{ _view._name }}"
    type: yesno
    sql: ${TABLE}.userSelected ;;
  }

  dimension: version {
    group_label: "{{ _view._name }}"
    type: string
    sql: ${TABLE}.version ;;
  }
}

view: patient__identifier__type {
  label: "Patient"
  dimension: coding {
    group_label: "{{ _view._name }}"
    hidden: yes
    sql: ${TABLE}.coding ;;
  }

  dimension: text {
    group_label: "{{ _view._name }}"
    type: string
    sql: ${TABLE}.text ;;
  }
}

view: patient__address {
  label: "Patient"
  dimension: city {
    group_label: "{{ _view._name }}"
    type: string
    sql: ${TABLE}.city ;;
  }

  dimension: country {
    group_label: "{{ _view._name }}"
    type: string
    map_layer_name: countries
    sql: ${TABLE}.country ;;
  }

  dimension: district {
    group_label: "{{ _view._name }}"
    type: string
    sql: ${TABLE}.district ;;
  }

  dimension: geolocation {
    group_label: "{{ _view._name }}"
    hidden: yes
    sql: ${TABLE}.geolocation ;;
  }

  dimension: line {
    group_label: "{{ _view._name }}"
    type: string
    sql: ${TABLE}.line ;;
  }

  dimension: period {
    group_label: "{{ _view._name }}"
    hidden: yes
    sql: ${TABLE}.period ;;
  }

  dimension: postal_code {
    group_label: "{{ _view._name }}"
    type: string
    sql: ${TABLE}.postalCode ;;
  }

  dimension: state {
    group_label: "{{ _view._name }}"
    type: string
    sql: ${TABLE}.state ;;
  }

  dimension: text {
    group_label: "{{ _view._name }}"
    type: string
    sql: ${TABLE}.text ;;
  }

  dimension: type {
    group_label: "{{ _view._name }}"
    type: string
    sql: ${TABLE}.type ;;
  }

  dimension: use {
    group_label: "{{ _view._name }}"
    type: string
    sql: ${TABLE}.use ;;
  }
}

view: patient__address__period {
  label: "Patient"
  dimension: end {
    group_label: "{{ _view._name }}"
    type: string
    sql: ${TABLE}.`end` ;;
  }

  dimension: start {
    group_label: "{{ _view._name }}"
    type: string
    sql: ${TABLE}.start ;;
  }
}

view: patient__address__geolocation__latitude__value {
  label: "Patient"
  dimension: decimal {
    group_label: "{{ _view._name }}"
    type: number
    sql: ${TABLE}.decimal ;;
  }
}

view: patient__address__geolocation__longitude__value {
  label: "Patient"
  dimension: decimal {
    group_label: "{{ _view._name }}"
    type: number
    sql: ${TABLE}.decimal ;;
  }
}

view: patient__shr_demographics_social_security_number_extension__value {
  label: "Patient"
  dimension: string {
    group_label: "{{ _view._name }}"
    type: string
    sql: ${TABLE}.string ;;
  }
}

view: patient__photo {
  label: "Patient"
  dimension: content_type {
    group_label: "{{ _view._name }}"
    type: string
    sql: ${TABLE}.contentType ;;
  }

  dimension: creation {
    group_label: "{{ _view._name }}"
    type: string
    sql: ${TABLE}.creation ;;
  }

  dimension: data {
    group_label: "{{ _view._name }}"
    type: string
    sql: ${TABLE}.data ;;
  }

  dimension: hash {
    group_label: "{{ _view._name }}"
    type: string
    sql: ${TABLE}.`hash` ;;
  }

  dimension: language {
    group_label: "{{ _view._name }}"
    type: string
    sql: ${TABLE}.language ;;
  }

  dimension: size {
    group_label: "{{ _view._name }}"
    type: number
    sql: ${TABLE}.size ;;
  }

  dimension: title {
    group_label: "{{ _view._name }}"
    type: string
    sql: ${TABLE}.title ;;
  }

  dimension: url {
    group_label: "{{ _view._name }}"
    type: string
    sql: ${TABLE}.url ;;
  }
}

view: patient__shr_entity_fathers_name_extension__value__human_name {
  label: "Patient"
  dimension: text {
    group_label: "{{ _view._name }}"
    type: string
    sql: ${TABLE}.text ;;
  }
}

view: patient__us_core_birthsex__value {
  label: "Patient"
  dimension: code {
    group_label: "{{ _view._name }}"
    type: string
    sql: ${TABLE}.code ;;
  }
}

view: patient__multiple_birth {
  label: "Patient"
  dimension: boolean {
    group_label: "{{ _view._name }}"
    type: yesno
    sql: ${TABLE}.boolean ;;
  }

  dimension: integer {
    group_label: "{{ _view._name }}"
    type: number
    sql: ${TABLE}.integer ;;
  }
}

view: patient__managing_organization {
  label: "Patient"
  dimension: display {
    group_label: "{{ _view._name }}"
    type: string
    sql: ${TABLE}.display ;;
  }

  dimension: identifier {
    group_label: "{{ _view._name }}"
    hidden: yes
    sql: ${TABLE}.identifier ;;
  }

  dimension: organization_id {
    group_label: "{{ _view._name }}"
    type: string
    sql: ${TABLE}.organizationId ;;
  }

  dimension: reference {
    group_label: "{{ _view._name }}"
    type: string
    sql: ${TABLE}.reference ;;
  }
}

view: patient__managing_organization__identifier__period {
  label: "Patient"
  dimension: end {
    group_label: "{{ _view._name }}"
    type: string
    sql: ${TABLE}.`end` ;;
  }

  dimension: start {
    group_label: "{{ _view._name }}"
    type: string
    sql: ${TABLE}.start ;;
  }
}

view: patient__managing_organization__identifier {
  label: "Patient"
  dimension: assigner {
    group_label: "{{ _view._name }}"
    hidden: yes
    sql: ${TABLE}.assigner ;;
  }

  dimension: period {
    group_label: "{{ _view._name }}"
    hidden: yes
    sql: ${TABLE}.period ;;
  }

  dimension: system {
    group_label: "{{ _view._name }}"
    type: string
    sql: ${TABLE}.system ;;
  }

  dimension: type {
    group_label: "{{ _view._name }}"
    hidden: yes
    sql: ${TABLE}.type ;;
  }

  dimension: use {
    group_label: "{{ _view._name }}"
    type: string
    sql: ${TABLE}.use ;;
  }

  dimension: value {
    group_label: "{{ _view._name }}"
    type: string
    sql: ${TABLE}.value ;;
  }
}

view: patient__managing_organization__identifier__assigner {
  label: "Patient"
  dimension: display {
    group_label: "{{ _view._name }}"
    type: string
    sql: ${TABLE}.display ;;
  }

  dimension: identifier {
    group_label: "{{ _view._name }}"
    hidden: yes
    sql: ${TABLE}.identifier ;;
  }

  dimension: organization_id {
    group_label: "{{ _view._name }}"
    type: string
    sql: ${TABLE}.organizationId ;;
  }

  dimension: reference {
    group_label: "{{ _view._name }}"
    type: string
    sql: ${TABLE}.reference ;;
  }
}

view: patient__managing_organization__identifier__assigner__identifier__period {
  label: "Patient"
  dimension: end {
    group_label: "{{ _view._name }}"
    type: string
    sql: ${TABLE}.`end` ;;
  }

  dimension: start {
    group_label: "{{ _view._name }}"
    type: string
    sql: ${TABLE}.start ;;
  }
}

view: patient__managing_organization__identifier__assigner__identifier {
  label: "Patient"
  dimension: assigner {
    group_label: "{{ _view._name }}"
    hidden: yes
    sql: ${TABLE}.assigner ;;
  }

  dimension: period {
    group_label: "{{ _view._name }}"
    hidden: yes
    sql: ${TABLE}.period ;;
  }

  dimension: system {
    group_label: "{{ _view._name }}"
    type: string
    sql: ${TABLE}.system ;;
  }

  dimension: type {
    group_label: "{{ _view._name }}"
    hidden: yes
    sql: ${TABLE}.type ;;
  }

  dimension: use {
    group_label: "{{ _view._name }}"
    type: string
    sql: ${TABLE}.use ;;
  }

  dimension: value {
    group_label: "{{ _view._name }}"
    type: string
    sql: ${TABLE}.value ;;
  }
}

view: patient__managing_organization__identifier__assigner__identifier__assigner {
  label: "Patient"
  dimension: display {
    group_label: "{{ _view._name }}"
    type: string
    sql: ${TABLE}.display ;;
  }

  dimension: organization_id {
    group_label: "{{ _view._name }}"
    type: string
    sql: ${TABLE}.organizationId ;;
  }

  dimension: reference {
    group_label: "{{ _view._name }}"
    type: string
    sql: ${TABLE}.reference ;;
  }
}

view: patient__managing_organization__identifier__assigner__identifier__type__coding {
  label: "Patient"
  dimension: code {
    group_label: "{{ _view._name }}"
    type: string
    sql: ${TABLE}.code ;;
  }

  dimension: display {
    group_label: "{{ _view._name }}"
    type: string
    sql: ${TABLE}.display ;;
  }

  dimension: system {
    group_label: "{{ _view._name }}"
    type: string
    sql: ${TABLE}.system ;;
  }

  dimension: user_selected {
    group_label: "{{ _view._name }}"
    type: yesno
    sql: ${TABLE}.userSelected ;;
  }

  dimension: version {
    group_label: "{{ _view._name }}"
    type: string
    sql: ${TABLE}.version ;;
  }
}

view: patient__managing_organization__identifier__assigner__identifier__type {
  label: "Patient"
  dimension: coding {
    group_label: "{{ _view._name }}"
    hidden: yes
    sql: ${TABLE}.coding ;;
  }

  dimension: text {
    group_label: "{{ _view._name }}"
    type: string
    sql: ${TABLE}.text ;;
  }
}

view: patient__managing_organization__identifier__type__coding {
  label: "Patient"
  dimension: code {
    group_label: "{{ _view._name }}"
    type: string
    sql: ${TABLE}.code ;;
  }

  dimension: display {
    group_label: "{{ _view._name }}"
    type: string
    sql: ${TABLE}.display ;;
  }

  dimension: system {
    group_label: "{{ _view._name }}"
    type: string
    sql: ${TABLE}.system ;;
  }

  dimension: user_selected {
    group_label: "{{ _view._name }}"
    type: yesno
    sql: ${TABLE}.userSelected ;;
  }

  dimension: version {
    group_label: "{{ _view._name }}"
    type: string
    sql: ${TABLE}.version ;;
  }
}

view: patient__managing_organization__identifier__type {
  label: "Patient"
  dimension: coding {
    group_label: "{{ _view._name }}"
    hidden: yes
    sql: ${TABLE}.coding ;;
  }

  dimension: text {
    group_label: "{{ _view._name }}"
    type: string
    sql: ${TABLE}.text ;;
  }
}

view: patient__meta {
  label: "Patient"
  dimension_group: last_updated {
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
    sql: ${TABLE}.lastUpdated ;;
  }

  dimension: profile {
    group_label: "{{ _view._name }}"
    type: string
    sql: ${TABLE}.profile ;;
  }

  dimension: security {
    group_label: "{{ _view._name }}"
    hidden: yes
    sql: ${TABLE}.security ;;
  }

  dimension: tag {
    group_label: "{{ _view._name }}"
    hidden: yes
    sql: ${TABLE}.tag ;;
  }

  dimension: version_id {
    group_label: "{{ _view._name }}"
    type: string
    sql: ${TABLE}.versionId ;;
  }
}

view: patient__meta__security {
  label: "Patient"
  dimension: code {
    group_label: "{{ _view._name }}"
    type: string
    sql: ${TABLE}.code ;;
  }

  dimension: display {
    group_label: "{{ _view._name }}"
    type: string
    sql: ${TABLE}.display ;;
  }

  dimension: system {
    group_label: "{{ _view._name }}"
    type: string
    sql: ${TABLE}.system ;;
  }

  dimension: user_selected {
    group_label: "{{ _view._name }}"
    type: yesno
    sql: ${TABLE}.userSelected ;;
  }

  dimension: version {
    group_label: "{{ _view._name }}"
    type: string
    sql: ${TABLE}.version ;;
  }
}

view: patient__meta__tag {
  label: "Patient"
  dimension: code {
    group_label: "{{ _view._name }}"
    type: string
    sql: ${TABLE}.code ;;
  }

  dimension: display {
    group_label: "{{ _view._name }}"
    type: string
    sql: ${TABLE}.display ;;
  }

  dimension: system {
    group_label: "{{ _view._name }}"
    type: string
    sql: ${TABLE}.system ;;
  }

  dimension: user_selected {
    group_label: "{{ _view._name }}"
    type: yesno
    sql: ${TABLE}.userSelected ;;
  }

  dimension: version {
    group_label: "{{ _view._name }}"
    type: string
    sql: ${TABLE}.version ;;
  }
}

view: patient__name {
  label: "Patient"
  dimension: family {
    group_label: "{{ _view._name }}"
    type: string
    sql: ${TABLE}.family ;;
  }

  dimension: given {
    group_label: "{{ _view._name }}"
    type: string
    sql: ${TABLE}.given ;;
  }

  dimension: period {
    group_label: "{{ _view._name }}"
    hidden: yes
    sql: ${TABLE}.period ;;
  }

  dimension: prefix {
    group_label: "{{ _view._name }}"
    type: string
    sql: ${TABLE}.prefix ;;
  }

  dimension: suffix {
    group_label: "{{ _view._name }}"
    type: string
    sql: ${TABLE}.suffix ;;
  }

  dimension: text {
    group_label: "{{ _view._name }}"
    type: string
    sql: ${TABLE}.text ;;
  }

  dimension: use {
    group_label: "{{ _view._name }}"
    type: string
    sql: ${TABLE}.use ;;
  }
}

view: patient__name__period {
  label: "Patient"
  dimension: end {
    group_label: "{{ _view._name }}"
    type: string
    sql: ${TABLE}.`end` ;;
  }

  dimension: start {
    group_label: "{{ _view._name }}"
    type: string
    sql: ${TABLE}.start ;;
  }
}

view: patient__animal__species__coding {
  label: "Patient"
  dimension: code {
    group_label: "{{ _view._name }}"
    type: string
    sql: ${TABLE}.code ;;
  }

  dimension: display {
    group_label: "{{ _view._name }}"
    type: string
    sql: ${TABLE}.display ;;
  }

  dimension: system {
    group_label: "{{ _view._name }}"
    type: string
    sql: ${TABLE}.system ;;
  }

  dimension: user_selected {
    group_label: "{{ _view._name }}"
    type: yesno
    sql: ${TABLE}.userSelected ;;
  }

  dimension: version {
    group_label: "{{ _view._name }}"
    type: string
    sql: ${TABLE}.version ;;
  }
}

view: patient__animal__species {
  label: "Patient"
  dimension: coding {
    group_label: "{{ _view._name }}"
    hidden: yes
    sql: ${TABLE}.coding ;;
  }

  dimension: text {
    group_label: "{{ _view._name }}"
    type: string
    sql: ${TABLE}.text ;;
  }
}

view: patient__animal__breed__coding {
  label: "Patient"
  dimension: code {
    group_label: "{{ _view._name }}"
    type: string
    sql: ${TABLE}.code ;;
  }

  dimension: display {
    group_label: "{{ _view._name }}"
    type: string
    sql: ${TABLE}.display ;;
  }

  dimension: system {
    group_label: "{{ _view._name }}"
    type: string
    sql: ${TABLE}.system ;;
  }

  dimension: user_selected {
    group_label: "{{ _view._name }}"
    type: yesno
    sql: ${TABLE}.userSelected ;;
  }

  dimension: version {
    group_label: "{{ _view._name }}"
    type: string
    sql: ${TABLE}.version ;;
  }
}

view: patient__animal__breed {
  label: "Patient"
  dimension: coding {
    group_label: "{{ _view._name }}"
    hidden: yes
    sql: ${TABLE}.coding ;;
  }

  dimension: text {
    group_label: "{{ _view._name }}"
    type: string
    sql: ${TABLE}.text ;;
  }
}

view: patient__animal__gender_status__coding {
  label: "Patient"
  dimension: code {
    group_label: "{{ _view._name }}"
    type: string
    sql: ${TABLE}.code ;;
  }

  dimension: display {
    group_label: "{{ _view._name }}"
    type: string
    sql: ${TABLE}.display ;;
  }

  dimension: system {
    group_label: "{{ _view._name }}"
    type: string
    sql: ${TABLE}.system ;;
  }

  dimension: user_selected {
    group_label: "{{ _view._name }}"
    type: yesno
    sql: ${TABLE}.userSelected ;;
  }

  dimension: version {
    group_label: "{{ _view._name }}"
    type: string
    sql: ${TABLE}.version ;;
  }
}

view: patient__animal__gender_status {
  label: "Patient"
  dimension: coding {
    group_label: "{{ _view._name }}"
    hidden: yes
    sql: ${TABLE}.coding ;;
  }

  dimension: text {
    group_label: "{{ _view._name }}"
    type: string
    sql: ${TABLE}.text ;;
  }
}

view: patient__patient_mothers_maiden_name__value {
  label: "Patient"
  dimension: string {
    group_label: "{{ _view._name }}"
    type: string
    sql: ${TABLE}.string ;;
  }
}

view: patient__marital_status__coding {
  label: "Patient"
  dimension: code {
    group_label: "{{ _view._name }}"
    type: string
    sql: ${TABLE}.code ;;
  }

  dimension: display {
    group_label: "{{ _view._name }}"
    type: string
    sql: ${TABLE}.display ;;
  }

  dimension: system {
    group_label: "{{ _view._name }}"
    type: string
    sql: ${TABLE}.system ;;
  }

  dimension: user_selected {
    group_label: "{{ _view._name }}"
    type: yesno
    sql: ${TABLE}.userSelected ;;
  }

  dimension: version {
    group_label: "{{ _view._name }}"
    type: string
    sql: ${TABLE}.version ;;
  }
}

view: patient__marital_status {
  label: "Patient"
  dimension: coding {
    group_label: "{{ _view._name }}"
    hidden: yes
    sql: ${TABLE}.coding ;;
  }

  dimension: text {
    group_label: "{{ _view._name }}"
    type: string
    sql: ${TABLE}.text ;;
  }
}

view: patient__quality_adjusted_life_years__value {
  label: "Patient"
  dimension: decimal {
    group_label: "{{ _view._name }}"
    type: number
    sql: ${TABLE}.decimal ;;
  }
}

view: patient__shr_actor_fictional_person_extension {
  label: "Patient"
  dimension: value {
    group_label: "{{ _view._name }}"
    hidden: yes
    sql: ${TABLE}.value ;;
  }
}

view: patient__us_core_race__text {
  label: "Patient"
  dimension: value {
    group_label: "{{ _view._name }}"
    hidden: yes
    sql: ${TABLE}.value ;;
  }
}

view: patient__us_core_race__omb_category__value {
  label: "Patient"
  dimension: coding {
    group_label: "{{ _view._name }}"
    hidden: yes
    sql: ${TABLE}.coding ;;
  }
}

view: patient__disability_adjusted_life_years {
  label: "Patient"
  dimension: value {
    group_label: "{{ _view._name }}"
    hidden: yes
    sql: ${TABLE}.value ;;
  }
}

view: patient__shr_entity_person_extension__value {
  label: "Patient"
  dimension: reference {
    group_label: "{{ _view._name }}"
    hidden: yes
    sql: ${TABLE}.reference ;;
  }
}

view: patient__birth_place__value {
  label: "Patient"
  dimension: address {
    group_label: "{{ _view._name }}"
    hidden: yes
    sql: ${TABLE}.address ;;
  }
}

view: patient__us_core_ethnicity__text {
  label: "Patient"
  dimension: value {
    group_label: "{{ _view._name }}"
    hidden: yes
    sql: ${TABLE}.value ;;
  }
}

view: patient__us_core_ethnicity__omb_category__value {
  label: "Patient"
  dimension: coding {
    group_label: "{{ _view._name }}"
    hidden: yes
    sql: ${TABLE}.coding ;;
  }
}

view: patient__address__geolocation__latitude {
  label: "Patient"
  dimension: value {
    group_label: "{{ _view._name }}"
    hidden: yes
    sql: ${TABLE}.value ;;
  }
}

view: patient__address__geolocation__longitude {
  label: "Patient"
  dimension: value {
    group_label: "{{ _view._name }}"
    hidden: yes
    sql: ${TABLE}.value ;;
  }
}

view: patient__shr_demographics_social_security_number_extension {
  label: "Patient"
  dimension: value {
    group_label: "{{ _view._name }}"
    hidden: yes
    sql: ${TABLE}.value ;;
  }
}

view: patient__shr_entity_fathers_name_extension__value {
  label: "Patient"
  dimension: human_name {
    group_label: "{{ _view._name }}"
    hidden: yes
    sql: ${TABLE}.humanName ;;
  }
}

view: patient__us_core_birthsex {
  label: "Patient"
  dimension: value {
    group_label: "{{ _view._name }}"
    hidden: yes
    sql: ${TABLE}.value ;;
  }
}

view: patient__animal {
  label: "Patient"
  dimension: breed {
    group_label: "{{ _view._name }}"
    hidden: yes
    sql: ${TABLE}.breed ;;
  }

  dimension: gender_status {
    group_label: "{{ _view._name }}"
    hidden: yes
    sql: ${TABLE}.genderStatus ;;
  }

  dimension: species {
    group_label: "{{ _view._name }}"
    hidden: yes
    sql: ${TABLE}.species ;;
  }
}

view: patient__patient_mothers_maiden_name {
  label: "Patient"
  dimension: value {
    group_label: "{{ _view._name }}"
    hidden: yes
    sql: ${TABLE}.value ;;
  }
}

view: patient__quality_adjusted_life_years {
  label: "Patient"
  dimension: value {
    group_label: "{{ _view._name }}"
    hidden: yes
    sql: ${TABLE}.value ;;
  }
}

view: patient__us_core_race {
  label: "Patient"
  dimension: omb_category {
    group_label: "{{ _view._name }}"
    hidden: yes
    sql: ${TABLE}.ombCategory ;;
  }

  dimension: text {
    group_label: "{{ _view._name }}"
    hidden: yes
    sql: ${TABLE}.text ;;
  }
}

view: patient__us_core_race__omb_category {
  label: "Patient"
  dimension: value {
    group_label: "{{ _view._name }}"
    hidden: yes
    sql: ${TABLE}.value ;;
  }
}

view: patient__shr_entity_person_extension {
  label: "Patient"
  dimension: value {
    group_label: "{{ _view._name }}"
    hidden: yes
    sql: ${TABLE}.value ;;
  }
}

view: patient__birth_place {
  label: "Patient"
  dimension: value {
    group_label: "{{ _view._name }}"
    hidden: yes
    sql: ${TABLE}.value ;;
  }
}

view: patient__us_core_ethnicity {
  label: "Patient"
  dimension: omb_category {
    group_label: "{{ _view._name }}"
    hidden: yes
    sql: ${TABLE}.ombCategory ;;
  }

  dimension: text {
    group_label: "{{ _view._name }}"
    hidden: yes
    sql: ${TABLE}.text ;;
  }
}

view: patient__us_core_ethnicity__omb_category {
  label: "Patient"
  dimension: value {
    group_label: "{{ _view._name }}"
    hidden: yes
    sql: ${TABLE}.value ;;
  }
}

view: patient__address__geolocation {
  label: "Patient"
  dimension: latitude {
    group_label: "{{ _view._name }}"
    hidden: yes
    sql: ${TABLE}.latitude ;;
  }

  dimension: longitude {
    group_label: "{{ _view._name }}"
    hidden: yes
    sql: ${TABLE}.longitude ;;
  }
}

view: patient__shr_entity_fathers_name_extension {
  label: "Patient"
  dimension: value {
    group_label: "{{ _view._name }}"
    hidden: yes
    sql: ${TABLE}.value ;;
  }
}
