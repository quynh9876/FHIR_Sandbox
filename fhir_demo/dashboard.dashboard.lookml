- dashboard: 1a__covid_patient_status_original
  title: 1A - COVID Patient Status (Original)
  layout: newspaper
  elements:
  - title: "# Ambulatory Patients"
    name: "# Ambulatory Patients"
    model: fhir_hcls
    explore: final_patient_status_dashboard
    type: single_value
    fields: [final_patient_status_dashboard.snapshot_date, final_patient_status_dashboard.count_patients_status_1_ambulatory,
      final_patient_status_dashboard.percent_patients_status_1_ambulatory]
    fill_fields: [final_patient_status_dashboard.snapshot_date]
    sorts: [final_patient_status_dashboard.snapshot_date desc]
    limit: 500
    dynamic_fields: [{table_calculation: offset, label: offset, expression: 'offset(${final_patient_status_dashboard.count_patients},1)',
        value_format: !!null '', value_format_name: !!null '', _kind_hint: measure,
        _type_hint: number, is_disabled: true}, {table_calculation: vs_yesterday,
        label: "% vs. Yesterday", expression: "(${final_patient_status_dashboard.count_patients}\
          \ - ${offset})/${offset}", value_format: !!null '', value_format_name: percent_1,
        _kind_hint: measure, _type_hint: number, is_disabled: true}]
    custom_color_enabled: true
    show_single_value_title: true
    show_comparison: true
    comparison_type: value
    comparison_reverse_colors: true
    show_comparison_label: true
    enable_conditional_formatting: false
    conditional_formatting_include_totals: false
    conditional_formatting_include_nulls: false
    comparison_label: of Total
    series_types: {}
    defaults_version: 1
    hidden_fields: []
    listen:
      Date: final_patient_status_dashboard.snapshot_date
    row: 2
    col: 4
    width: 4
    height: 4
  - title: Status by Day
    name: Status by Day
    model: fhir_hcls
    explore: final_patient_status_dashboard
    type: looker_column
    fields: [final_patient_status_dashboard.snapshot_date, final_patient_status_dashboard.count_patients,
      final_patient_status_dashboard.patient_status]
    pivots: [final_patient_status_dashboard.patient_status]
    fill_fields: [final_patient_status_dashboard.snapshot_date]
    filters:
      final_patient_status_dashboard.snapshot_date: 90 days
    sorts: [final_patient_status_dashboard.snapshot_date desc, final_patient_status_dashboard.patient_status]
    limit: 500
    dynamic_fields: [{table_calculation: offset, label: offset, expression: 'offset(${final_patient_status_dashboard.count_patients},1)',
        value_format: !!null '', value_format_name: !!null '', _kind_hint: measure,
        _type_hint: number, is_disabled: true}, {table_calculation: vs_yesterday,
        label: "% vs. Yesterday", expression: "(${final_patient_status_dashboard.count_patients}\
          \ - ${offset})/${offset}", value_format: !!null '', value_format_name: percent_1,
        _kind_hint: measure, _type_hint: number, is_disabled: true}]
    x_axis_gridlines: false
    y_axis_gridlines: true
    show_view_names: false
    show_y_axis_labels: true
    show_y_axis_ticks: true
    y_axis_tick_density: default
    y_axis_tick_density_custom: 5
    show_x_axis_label: true
    show_x_axis_ticks: true
    y_axis_scale_mode: linear
    x_axis_reversed: false
    y_axis_reversed: false
    plot_size_by_field: false
    trellis: ''
    stacking: normal
    limit_displayed_rows: false
    legend_position: center
    point_style: none
    show_value_labels: false
    label_density: 25
    x_axis_scale: auto
    y_axis_combined: true
    ordering: none
    show_null_labels: false
    show_totals_labels: false
    show_silhouette: false
    totals_color: "#808080"
    series_types: {}
    custom_color_enabled: true
    show_single_value_title: true
    show_comparison: true
    comparison_type: change
    comparison_reverse_colors: true
    show_comparison_label: true
    enable_conditional_formatting: false
    conditional_formatting_include_totals: false
    conditional_formatting_include_nulls: false
    defaults_version: 1
    hidden_fields: []
    listen: {}
    row: 6
    col: 0
    width: 9
    height: 8
  - title: Inpatient & ICU Beds
    name: Inpatient & ICU Beds
    model: fhir_hcls
    explore: final_patient_status_dashboard
    type: looker_line
    fields: [final_patient_status_dashboard.snapshot_date, final_patient_status_dashboard.count_patients,
      final_patient_status_dashboard.patient_status]
    pivots: [final_patient_status_dashboard.patient_status]
    fill_fields: [final_patient_status_dashboard.snapshot_date]
    filters:
      final_patient_status_dashboard.snapshot_date: 90 days
      final_patient_status_dashboard.patient_status: 3 - Inpatient ICU,2 - Inpatient
    sorts: [final_patient_status_dashboard.snapshot_date desc, final_patient_status_dashboard.patient_status]
    limit: 500
    dynamic_fields: [{table_calculation: offset, label: offset, expression: 'offset(${final_patient_status_dashboard.count_patients},1)',
        value_format: !!null '', value_format_name: !!null '', _kind_hint: measure,
        _type_hint: number, is_disabled: true}, {table_calculation: vs_yesterday,
        label: "% vs. Yesterday", expression: "(${final_patient_status_dashboard.count_patients}\
          \ - ${offset})/${offset}", value_format: !!null '', value_format_name: percent_1,
        _kind_hint: measure, _type_hint: number, is_disabled: true}]
    x_axis_gridlines: false
    y_axis_gridlines: true
    show_view_names: false
    show_y_axis_labels: true
    show_y_axis_ticks: true
    y_axis_tick_density: default
    y_axis_tick_density_custom: 5
    show_x_axis_label: true
    show_x_axis_ticks: true
    y_axis_scale_mode: linear
    x_axis_reversed: false
    y_axis_reversed: false
    plot_size_by_field: false
    trellis: ''
    stacking: ''
    limit_displayed_rows: false
    legend_position: center
    point_style: none
    show_value_labels: false
    label_density: 25
    x_axis_scale: auto
    y_axis_combined: true
    show_null_points: true
    interpolation: linear
    series_types: {}
    series_labels:
      2 - Inpatient - final_patient_status_dashboard.count_patients: Inpatient Beds
      3 - Inpatient ICU - final_patient_status_dashboard.count_patients: ICU Beds
    ordering: none
    show_null_labels: false
    show_totals_labels: false
    show_silhouette: false
    totals_color: "#808080"
    custom_color_enabled: true
    show_single_value_title: true
    show_comparison: true
    comparison_type: change
    comparison_reverse_colors: true
    show_comparison_label: true
    enable_conditional_formatting: false
    conditional_formatting_include_totals: false
    conditional_formatting_include_nulls: false
    defaults_version: 1
    hidden_fields: []
    listen: {}
    row: 6
    col: 9
    width: 9
    height: 8
  - title: Deep Dive
    name: Deep Dive
    model: fhir_hcls
    explore: final_patient_status_dashboard
    type: looker_grid
    fields: [final_patient_status_patient_details_dashboard.pivot_value, final_patient_status_dashboard.count_patients_status_1_ambulatory,
      final_patient_status_dashboard.count_patients_status_2_inpatient, final_patient_status_dashboard.count_patients_status_3_inpatient_icu,
      final_patient_status_dashboard.count_patients_status_4_discharged_snf, final_patient_status_dashboard.count_patients_status_5_discharged_home,
      final_patient_status_dashboard.count_patients_status_6_death]
    filters:
      final_patient_status_patient_details_dashboard.pivot_value: "-NULL"
    sorts: [final_patient_status_dashboard.count_patients_status_1_ambulatory desc]
    limit: 500
    dynamic_fields: [{table_calculation: offset, label: offset, expression: 'offset(${final_patient_status_dashboard.count_patients},1)',
        value_format: !!null '', value_format_name: !!null '', _kind_hint: measure,
        _type_hint: number, is_disabled: true}, {table_calculation: vs_yesterday,
        label: "% vs. Yesterday", expression: "(${final_patient_status_dashboard.count_patients}\
          \ - ${offset})/${offset}", value_format: !!null '', value_format_name: percent_1,
        _kind_hint: measure, _type_hint: number, is_disabled: true}]
    show_view_names: false
    show_row_numbers: true
    transpose: false
    truncate_text: true
    hide_totals: false
    hide_row_totals: false
    size_to_fit: true
    table_theme: white
    limit_displayed_rows: false
    enable_conditional_formatting: false
    header_text_alignment: left
    header_font_size: '12'
    rows_font_size: '12'
    conditional_formatting_include_totals: false
    conditional_formatting_include_nulls: false
    show_sql_query_menu_options: false
    show_totals: true
    show_row_totals: true
    series_labels:
      2 - Inpatient - final_patient_status_dashboard.count_patients: Inpatient Beds
      3 - Inpatient ICU - final_patient_status_dashboard.count_patients: ICU Beds
      final_patient_status_dashboard.count_patients_status_1_ambulatory: "# Ambulatory"
      final_patient_status_dashboard.count_patients_status_2_inpatient: "# Inpatient"
      final_patient_status_dashboard.count_patients_status_3_inpatient_icu: "# Inpatient\
        \ ICU"
      final_patient_status_dashboard.count_patients_status_4_discharged_snf: "# SNF"
      final_patient_status_dashboard.count_patients_status_5_discharged_home: "# Discharged\
        \ Home"
      final_patient_status_dashboard.count_patients_status_6_death: "# Death"
    x_axis_gridlines: false
    y_axis_gridlines: true
    show_y_axis_labels: true
    show_y_axis_ticks: true
    y_axis_tick_density: default
    y_axis_tick_density_custom: 5
    show_x_axis_label: true
    show_x_axis_ticks: true
    y_axis_scale_mode: linear
    x_axis_reversed: false
    y_axis_reversed: false
    plot_size_by_field: false
    trellis: ''
    stacking: normal
    legend_position: center
    point_style: none
    show_value_labels: false
    label_density: 25
    x_axis_scale: auto
    y_axis_combined: true
    show_null_points: true
    interpolation: linear
    series_types: {}
    ordering: none
    show_null_labels: false
    show_totals_labels: false
    show_silhouette: false
    totals_color: "#808080"
    custom_color_enabled: true
    show_single_value_title: true
    show_comparison: true
    comparison_type: change
    comparison_reverse_colors: true
    show_comparison_label: true
    defaults_version: 1
    hidden_fields: []
    listen:
      Pivot: final_patient_status_patient_details_dashboard.pivot
      Date: final_patient_status_dashboard.snapshot_date
    row: 14
    col: 0
    width: 24
    height: 8
  - title: Patient by Age Tier
    name: Patient by Age Tier
    model: fhir_hcls
    explore: final_patient_status_dashboard
    type: looker_column
    fields: [final_patient_status_dashboard.count_patients, final_patient_status_patient_details_dashboard.patient_age_tier]
    fill_fields: [final_patient_status_patient_details_dashboard.patient_age_tier]
    sorts: [final_patient_status_patient_details_dashboard.patient_age_tier]
    limit: 500
    dynamic_fields: [{table_calculation: offset, label: offset, expression: 'offset(${final_patient_status_dashboard.count_patients},1)',
        value_format: !!null '', value_format_name: !!null '', _kind_hint: measure,
        _type_hint: number, is_disabled: true}, {table_calculation: vs_yesterday,
        label: "% vs. Yesterday", expression: "(${final_patient_status_dashboard.count_patients}\
          \ - ${offset})/${offset}", value_format: !!null '', value_format_name: percent_1,
        _kind_hint: measure, _type_hint: number, is_disabled: true}]
    x_axis_gridlines: false
    y_axis_gridlines: true
    show_view_names: false
    show_y_axis_labels: true
    show_y_axis_ticks: true
    y_axis_tick_density: default
    y_axis_tick_density_custom: 5
    show_x_axis_label: true
    show_x_axis_ticks: true
    y_axis_scale_mode: linear
    x_axis_reversed: false
    y_axis_reversed: false
    plot_size_by_field: false
    trellis: ''
    stacking: ''
    limit_displayed_rows: false
    legend_position: center
    point_style: none
    show_value_labels: false
    label_density: 25
    x_axis_scale: auto
    y_axis_combined: true
    ordering: none
    show_null_labels: false
    show_totals_labels: false
    show_silhouette: false
    totals_color: "#808080"
    map_plot_mode: points
    heatmap_gridlines: false
    heatmap_gridlines_empty: false
    heatmap_opacity: 0.5
    show_region_field: true
    draw_map_labels_above_data: true
    map_tile_provider: light
    map_position: fit_data
    map_scale_indicator: 'off'
    map_pannable: true
    map_zoomable: true
    map_marker_type: circle
    map_marker_icon_name: default
    map_marker_radius_mode: proportional_value
    map_marker_units: meters
    map_marker_proportional_scale_type: linear
    map_marker_color_mode: fixed
    show_legend: true
    quantize_map_value_colors: false
    reverse_map_value_colors: false
    custom_color_enabled: true
    show_single_value_title: true
    show_comparison: true
    comparison_type: change
    comparison_reverse_colors: true
    show_comparison_label: true
    enable_conditional_formatting: false
    conditional_formatting_include_totals: false
    conditional_formatting_include_nulls: false
    series_types: {}
    defaults_version: 1
    hidden_fields: []
    listen:
      Date: final_patient_status_dashboard.snapshot_date
    row: 6
    col: 18
    width: 6
    height: 8
  - title: "# Inpatient Patients"
    name: "# Inpatient Patients"
    model: fhir_hcls
    explore: final_patient_status_dashboard
    type: single_value
    fields: [final_patient_status_dashboard.snapshot_date, final_patient_status_dashboard.count_patients_status_2_inpatient,
      final_patient_status_dashboard.percent_patients_status_2_inpatient]
    fill_fields: [final_patient_status_dashboard.snapshot_date]
    sorts: [final_patient_status_dashboard.snapshot_date desc]
    limit: 500
    dynamic_fields: [{table_calculation: offset, label: offset, expression: 'offset(${final_patient_status_dashboard.count_patients},1)',
        value_format: !!null '', value_format_name: !!null '', _kind_hint: measure,
        _type_hint: number, is_disabled: true}, {table_calculation: vs_yesterday,
        label: "% vs. Yesterday", expression: "(${final_patient_status_dashboard.count_patients}\
          \ - ${offset})/${offset}", value_format: !!null '', value_format_name: percent_1,
        _kind_hint: measure, _type_hint: number, is_disabled: true}]
    custom_color_enabled: true
    show_single_value_title: true
    show_comparison: true
    comparison_type: value
    comparison_reverse_colors: true
    show_comparison_label: true
    enable_conditional_formatting: false
    conditional_formatting_include_totals: false
    conditional_formatting_include_nulls: false
    comparison_label: of Total
    series_types: {}
    defaults_version: 1
    hidden_fields: []
    listen:
      Date: final_patient_status_dashboard.snapshot_date
    row: 2
    col: 8
    width: 4
    height: 4
  - title: "# Patients Discharged to SNF"
    name: "# Patients Discharged to SNF"
    model: fhir_hcls
    explore: final_patient_status_dashboard
    type: single_value
    fields: [final_patient_status_dashboard.snapshot_date, final_patient_status_dashboard.count_patients_status_4_discharged_snf,
      final_patient_status_dashboard.percent_patients_status_4_discharged_snf]
    fill_fields: [final_patient_status_dashboard.snapshot_date]
    sorts: [final_patient_status_dashboard.snapshot_date desc]
    limit: 500
    dynamic_fields: [{table_calculation: offset, label: offset, expression: 'offset(${final_patient_status_dashboard.count_patients},1)',
        value_format: !!null '', value_format_name: !!null '', _kind_hint: measure,
        _type_hint: number, is_disabled: true}, {table_calculation: vs_yesterday,
        label: "% vs. Yesterday", expression: "(${final_patient_status_dashboard.count_patients}\
          \ - ${offset})/${offset}", value_format: !!null '', value_format_name: percent_1,
        _kind_hint: measure, _type_hint: number, is_disabled: true}]
    custom_color_enabled: true
    show_single_value_title: true
    show_comparison: true
    comparison_type: value
    comparison_reverse_colors: true
    show_comparison_label: true
    enable_conditional_formatting: false
    conditional_formatting_include_totals: false
    conditional_formatting_include_nulls: false
    comparison_label: of Total
    series_types: {}
    defaults_version: 1
    hidden_fields: []
    listen:
      Date: final_patient_status_dashboard.snapshot_date
    row: 2
    col: 16
    width: 4
    height: 4
  - title: "# Inpatient Patients (ICU)"
    name: "# Inpatient Patients (ICU)"
    model: fhir_hcls
    explore: final_patient_status_dashboard
    type: single_value
    fields: [final_patient_status_dashboard.snapshot_date, final_patient_status_dashboard.count_patients_status_3_inpatient_icu,
      final_patient_status_dashboard.percent_patients_status_3_inpatient_icu]
    fill_fields: [final_patient_status_dashboard.snapshot_date]
    sorts: [final_patient_status_dashboard.snapshot_date desc]
    limit: 500
    dynamic_fields: [{table_calculation: offset, label: offset, expression: 'offset(${final_patient_status_dashboard.count_patients},1)',
        value_format: !!null '', value_format_name: !!null '', _kind_hint: measure,
        _type_hint: number, is_disabled: true}, {table_calculation: vs_yesterday,
        label: "% vs. Yesterday", expression: "(${final_patient_status_dashboard.count_patients}\
          \ - ${offset})/${offset}", value_format: !!null '', value_format_name: percent_1,
        _kind_hint: measure, _type_hint: number, is_disabled: true}]
    custom_color_enabled: true
    show_single_value_title: true
    show_comparison: true
    comparison_type: value
    comparison_reverse_colors: true
    show_comparison_label: true
    enable_conditional_formatting: false
    conditional_formatting_include_totals: false
    conditional_formatting_include_nulls: false
    comparison_label: of Total
    series_types: {}
    defaults_version: 1
    hidden_fields: []
    listen:
      Date: final_patient_status_dashboard.snapshot_date
    row: 2
    col: 12
    width: 4
    height: 4
  - title: "# Patients who Died"
    name: "# Patients who Died"
    model: fhir_hcls
    explore: final_patient_status_dashboard
    type: single_value
    fields: [final_patient_status_dashboard.snapshot_date, final_patient_status_dashboard.count_patients_status_6_death,
      final_patient_status_dashboard.percent_patients_status_6_death]
    fill_fields: [final_patient_status_dashboard.snapshot_date]
    sorts: [final_patient_status_dashboard.snapshot_date desc]
    limit: 500
    dynamic_fields: [{table_calculation: offset, label: offset, expression: 'offset(${final_patient_status_dashboard.count_patients},1)',
        value_format: !!null '', value_format_name: !!null '', _kind_hint: measure,
        _type_hint: number, is_disabled: true}, {table_calculation: vs_yesterday,
        label: "% vs. Yesterday", expression: "(${final_patient_status_dashboard.count_patients}\
          \ - ${offset})/${offset}", value_format: !!null '', value_format_name: percent_1,
        _kind_hint: measure, _type_hint: number, is_disabled: true}]
    custom_color_enabled: true
    show_single_value_title: true
    show_comparison: true
    comparison_type: value
    comparison_reverse_colors: true
    show_comparison_label: true
    enable_conditional_formatting: false
    conditional_formatting_include_totals: false
    conditional_formatting_include_nulls: false
    comparison_label: of Total
    series_types: {}
    defaults_version: 1
    hidden_fields: []
    listen:
      Date: final_patient_status_dashboard.snapshot_date
    row: 2
    col: 20
    width: 4
    height: 4
  - title: Total Patients with COVID
    name: Total Patients with COVID
    model: fhir_hcls
    explore: final_patient_status_dashboard
    type: single_value
    fields: [final_patient_status_dashboard.snapshot_date, final_patient_status_dashboard.count_patients]
    fill_fields: [final_patient_status_dashboard.snapshot_date]
    sorts: [final_patient_status_dashboard.snapshot_date desc]
    limit: 500
    dynamic_fields: [{table_calculation: offset, label: offset, expression: 'offset(${final_patient_status_dashboard.count_patients},1)',
        value_format: !!null '', value_format_name: !!null '', _kind_hint: measure,
        _type_hint: number, is_disabled: true}, {table_calculation: vs_yesterday,
        label: "% vs. Yesterday", expression: "(${final_patient_status_dashboard.count_patients}\
          \ - ${offset})/${offset}", value_format: !!null '', value_format_name: percent_1,
        _kind_hint: measure, _type_hint: number, is_disabled: true}]
    custom_color_enabled: true
    show_single_value_title: true
    show_comparison: false
    comparison_type: value
    comparison_reverse_colors: true
    show_comparison_label: true
    enable_conditional_formatting: false
    conditional_formatting_include_totals: false
    conditional_formatting_include_nulls: false
    comparison_label: of Total
    series_types: {}
    defaults_version: 1
    hidden_fields: []
    listen:
      Date: final_patient_status_dashboard.snapshot_date
    row: 2
    col: 0
    width: 4
    height: 4
  - name: COVID Patient Statuses
    type: text
    title_text: COVID Patient Statuses
    subtitle_text: As of Date Specified
    body_text: ''
    row: 0
    col: 0
    width: 24
    height: 2
  filters:
  - name: Pivot
    title: Pivot
    type: field_filter
    default_value: organization^_name
    allow_multiple_values: true
    required: false
    ui_config:
      type: advanced
      display: popover
    model: fhir_hcls
    explore: final_patient_status_dashboard
    listens_to_filters: []
    field: final_patient_status_patient_details_dashboard.pivot
  - name: Date
    title: Date
    type: field_filter
    default_value: 2020/06/28
    allow_multiple_values: true
    required: false
    model: fhir_hcls
    explore: final_patient_status_dashboard
    listens_to_filters: []
    field: final_patient_status_dashboard.snapshot_date


- dashboard: 2__covid__status_risk_score_over_time
  title: 2 - COVID - Status Risk Score over Time
  layout: newspaper
  elements:
  - title: Status Risk Score over Time
    name: Status Risk Score over Time
    model: fhir_hcls
    explore: final_patient_status_dashboard
    type: looker_line
    fields: [final_patient_status_dashboard.days_since_first_event, final_patient_status_dashboard.average_patient_score,
      final_patient_status_patient_details_dashboard.min_organization_name]
    pivots: [final_patient_status_patient_details_dashboard.min_organization_name]
    filters:
      final_patient_status_dashboard.count_patients: ">10"
    sorts: [final_patient_status_patient_details_dashboard.min_organization_name desc
        0, final_patient_status_dashboard.days_since_first_event]
    limit: 500
    column_limit: 50
    x_axis_gridlines: false
    y_axis_gridlines: true
    show_view_names: false
    show_y_axis_labels: true
    show_y_axis_ticks: true
    y_axis_tick_density: default
    y_axis_tick_density_custom: 5
    show_x_axis_label: true
    show_x_axis_ticks: true
    y_axis_scale_mode: linear
    x_axis_reversed: false
    y_axis_reversed: false
    plot_size_by_field: false
    trellis: ''
    stacking: ''
    limit_displayed_rows: false
    legend_position: center
    point_style: none
    show_value_labels: false
    label_density: 25
    x_axis_scale: auto
    y_axis_combined: true
    show_null_points: true
    interpolation: linear
    y_axes: [{label: Status Risk Score, orientation: left, series: [{axisId: final_patient_status_dashboard.average_patient_score,
            id: final_patient_status_dashboard.average_patient_score, name: Average
              Patient Score}], showLabels: true, showValues: true, unpinAxis: false,
        tickDensity: default, tickDensityCustom: 5, type: linear}]
    defaults_version: 1
    listen:
      Days since COVID Diagnosis: final_patient_status_dashboard.days_since_first_event
      Age: final_patient_status_patient_details_dashboard.patient_age_tier
      Gender: final_patient_status_patient_details_dashboard.min_gender
    row: 0
    col: 0
    width: 19
    height: 11
  filters:
  - name: Days since COVID Diagnosis
    title: Days since COVID Diagnosis
    type: field_filter
    default_value: "[1, 30]"
    allow_multiple_values: true
    required: false
    model: fhir_hcls
    explore: final_patient_status_dashboard
    listens_to_filters: []
    field: final_patient_status_dashboard.days_since_first_event
  - name: Age
    title: Age
    type: field_filter
    default_value: 70 to 79,80 to 89,90 or Above
    allow_multiple_values: true
    required: false
    model: fhir_hcls
    explore: final_patient_status_dashboard
    listens_to_filters: []
    field: final_patient_status_patient_details_dashboard.patient_age_tier
  - name: Gender
    title: Gender
    type: field_filter
    default_value: male
    allow_multiple_values: true
    required: false
    model: fhir_hcls
    explore: final_patient_status_dashboard
    listens_to_filters: []
    field: final_patient_status_patient_details_dashboard.min_gender
