view: users {
  sql_table_name: public.users ;;

  parameter: metric_selector {
    type: unquoted
    allowed_value: {
      label: "Youngest Age"
      value: "MIN"
    }
    allowed_value: {
      label: "Oldest Age"
      value: "MAX"
    }
    allowed_value: {
      label: "Median Age"
      value: "MEDIAN"
    }
  }

  measure: metric_choser {
    type: number
    value_format_name: percent_2
    sql:
      {% parameter metric_selector %}(${age})
      ;;
  }

  dimension: id {
    hidden: yes
    primary_key: yes
    type: number
    sql: ${TABLE}.id ;;
  }

  dimension: user_attribute_test {
    type: string
    sql: {{ _user_attributes['user_country'] }} ;;
  }


  dimension: age {
    group_label: "User Demographics"
    type: number
    sql: ${TABLE}.age ;;
  }

  dimension: str_a {
    group_label: "User Location"
    type: string
    sql: ${TABLE}.city ;;
  }

  parameter: string_checker {
    default_value: "foo"
  }

  dimension: str_b {
    sql: 'foo' ;;
  }

  dimension: comparision_a_B {
    sql: CASE WHEN ${str_a} IN ${str_b} ;;
  }



  parameter: target_goal {
    type: number
  }

  measure: pct_to_goal {
    type: number
    value_format_name: percent_2
    sql: 1.0*${count} / NULLIF({% parameter target_goal %}, 0) ;;
  }

  dimension: country {
    group_label: "User Location"
    type: string
    map_layer_name: countries
    sql: ${TABLE}.country ;;
  }



  dimension_group: created {
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
    sql: ${TABLE}.created_at ;;
  }

  dimension: email {
    type: string
    sql: ${TABLE}.email ;;
  }

  dimension: first_name {
    group_label: "User Name"
    type: string
    sql: ${TABLE}.first_name ;;
  }

  dimension: gender {
    group_label: "User Demographics"
    type: string
    sql: ${TABLE}.gender ;;
  }

  dimension: last_name {
    group_label: "User Name"
    type: string
    sql: ${TABLE}.last_name ;;
  }

  dimension: latitude {
    group_label: "User Location"
    type: number
    sql: ${TABLE}.latitude ;;
  }

  dimension: longitude {
    group_label: "User Location"
    type: number
    sql: ${TABLE}.longitude ;;
  }

  #dimension: state {
  #  group_label: "User Location"
  #  map_layer_name: us_states
  #  type: string
  #  sql: ${TABLE}.state ;;
  #}

  dimension: traffic_source {
    type: string
    sql: ${TABLE}.traffic_source ;;
  }

  dimension: zip {
    group_label: "User Location"
    type: zipcode
    sql: ${TABLE}.zip ;;
  }

  measure: count {
    type: count
    drill_fields: [id, first_name, last_name, events.count, order_items.count]
  }

  measure: distinct_users {
    type: count_distinct
    drill_fields: [id, first_name, last_name, events.count, order_items.count]
    sql: ${id} ;;
  }

  dimension: full_name {
    group_label: "User Name"
    type:  string
    sql:(( ${TABLE}.first_name || ' ') || ${TABLE}.last_name) ;;
  }

  dimension: age_tier {
    group_label: "User Demographics"
    type: tier
    tiers: [15, 25, 35, 50, 65]
    style: integer
    sql: ${age} ;;
  }

  dimension: is_new_user {
    type: yesno
    sql: CASE WHEN ${created_date} >= DATE_ADD('day', -90, GETDATE()) THEN TRUE ELSE FALSE END ;;
  }

##################################################
######       Measures relating to Age      #######
##################################################
  measure: median_age {
    group_label: "Age Measures"
    description: "Median age of a user who purchased an item"
    type:  median
    sql:  ${age} ;;
  }

  measure: average_age {
    group_label: "Age Measures"
    description: "Average age of a user who purchased an item"
    type:  median
    sql:  ${age} ;;
  }

  measure: max_age {
    group_label: "Age Measures"
    label: "Oldest User"
    description: "Age of the oldest user who purchased an item"
    type:  max
    sql:  ${age} ;;
  }

  measure: min_age {
    group_label: "Age Measures"
    label: "Youngest User"
    description: "Age of the youngest user who purchased an item"
    type:  min
    sql:  ${age} ;;
  }

  measure: total_users_yesterday {
    label: "New Users Created Yesterday"
    type: count_distinct
    sql: ${id} ;;
    filters: {
      field: created_date
      value: "yesterday"
    }
  }

  measure: total_users_MTD  {
    label: "New Users Month-to-Date"
    type: count_distinct
    ## When the Month+Year = Current Timestamp, then count all users
    ## Else, only count users who were created before this day of month
    sql: CASE
      WHEN extract(month from ${created_raw}) = extract(month from GETDATE()) AND extract(year from ${created_raw}) = extract(year from GETDATE())
        THEN ${id}
      ELSE NULL
      END ;;
    }

  measure: total_users_QTD  {
    label: "New Users Quarter-to-Date"
    type: count_distinct
    ## When the Month+Year = Current Timestamp, then count all users
    ## Else, only count users who were created before this day of month
    sql: CASE
      WHEN extract(quarter from ${created_raw}) = extract(quarter from GETDATE()) AND extract(year from ${created_raw}) = extract(year from GETDATE())
        THEN ${id}
      ELSE NULL
      END ;;
  }

}
