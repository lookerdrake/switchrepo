view: user_facts_table {
  derived_table: {
    sql:
    SELECT
      u.id as user_id,
      u.created_at as user_createdAt,
      CASE WHEN count(DISTINCT oi.order_id) > 0 THEN TRUE ELSE FALSE END as is_customer,
      COUNT(DISTINCT oi.order_id) AS lifetime_orders,
      SUM(oi.sale_price) AS lifetime_revenue,
      SUM(CASE oi.status WHEN 'Returned' THEN 1 ELSE 0 END) as lifetime_returns,
      SUM(CASE oi.status WHEN 'Returned' THEN 0 ELSE oi.sale_price END) lifetime_gross_revenue,
      MIN(NULLIF(oi.created_at,0)) AS first_order,
      MAX(NULLIF(oi.created_at,0)) AS latest_order,
      COUNT(DISTINCT DATE_TRUNC('month', NULLIF(oi.created_at,0))) AS number_of_distinct_months_with_orders,
      DATEDIFF(day, DATE(u.created_at), MIN(DATE(oi.created_at))) days_to_first_order

      FROM users as u
      LEFT JOIN order_items as oi ON(u.id = oi.user_id)
      GROUP BY 1,2
      ;;
  }

######################################
# Basic User Info
######################################
  dimension: user_id {
    type:  string
    primary_key: yes
    sql:  ${TABLE}.user_id ;;
  }

  dimension_group: user_created {
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
    sql: ${TABLE}.user_createdAt ;;
  }

  dimension_group: user_first_order {
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
    sql: ${TABLE}.first_order ;;
  }

  dimension_group: user_most_recent_order  {
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
    sql: ${TABLE}.latest_order ;;
  }

  dimension: is_customer  {
    group_label: "User Information"
    type: yesno
    sql: ${TABLE}.is_customer ;;
  }

  dimension: is_repeat_customer {
    group_label: "User Information"
    description: "Has the customer purchased more than one order?"
    type: yesno
    sql: ${lifetime_orders} > 1 ;;
  }

  dimension: time_to_first_order  {
    group_label: "User Information"
    label: "Time to First Order"
    description: "Time between user creation and purchase of first order"
    type: number
    sql: ${TABLE}.days_to_first_order ;;
    }

  dimension: has_returned {
    group_label: "User Information"
    description: "Has the user returned an item?"
    type: yesno
    sql: ${lifetime_returns} > 0 ;;
    }

  measure: total_users {
    group_label: "Customer Measures"
    type: count_distinct
    sql: ${user_id} ;;
  }

  measure: total_customers  {
    group_label: "Customer Measures"
    type: count_distinct
    sql: ${user_id} ;;
    filters: {
      field: is_customer
      value: "TRUE"
    }
  }

  measure: total_customers_that_have_returned {
    type: count_distinct
    group_label: "Return Information"
    label: "Number of Customers That Have Returned an Item"
    sql: ${user_id} ;;
    filters: {
      field: has_returned
      value: "TRUE"
    }
  }

  measure: pct_customers_that_have_returned {
    type: number
    group_label: "Return Information"
    label: "Percentage of Customers That Have Returned an Item"
    value_format_name: percent_2
    sql: 1.0*${total_customers_that_have_returned} / NULLIF(${total_customers},0) ;;
  }

  measure: pct_customers {
    group_label: "Customer Measures"
    label: "Percent of Users that are Customers"
    type: number
    value_format_name: percent_2
    sql: 1.0*${total_customers} / NULLIF(${total_users},0) ;;
  }

  measure: total_repeat_customers {
    group_label: "Customer Measures"
    type: count_distinct
    sql: ${user_id} ;;
    filters: {
      field: is_repeat_customer
      value: "TRUE"
    }
  }

  measure: pct_repeat_customers {
    group_label: "Customer Measures"
    type: number
    value_format_name: percent_2
    sql: 1.0*${total_repeat_customers} / NULLIF(${total_customers},0) ;;

  }


######################################
# Order Info
######################################
  dimension: lifetime_orders  {
    group_label: "Order Information"
    type: number
    sql: ${TABLE}.lifetime_orders ;;
    }

  dimension: lifetime_orders_tier {
    group_label: "Order Information"
    type: tier
    tiers: [0, 1, 2, 3, 5, 10]
    sql: ${lifetime_orders} ;;
    style: integer
  }

  measure: average_lifetime_orders {
    group_label: "Order Information"
    type: average
    value_format_name: decimal_2
    sql: ${lifetime_orders} ;;
  }

  measure: total_lifetime_orders  {
    group_label: "Order Information"
    type: sum
    sql: ${lifetime_orders} ;;
  }

  dimension: distinct_months_with_orders {
    group_label: "Order Information"
    type: number
    sql: ${TABLE}.number_of_distinct_months_with_orders ;;
  }

  dimension: lifetime_returns {
    group_label: "Order Information"
    type: number
    sql: ${TABLE}.lifetime_returns ;;
  }

  measure: average_lifetime_returns {
    group_label: "Return Information"
    type: average
    sql: ${lifetime_returns} ;;
  }

  measure: total_lifetime_returns {
    group_label: "Return Information"
    type: sum
    sql: ${lifetime_returns} ;;
  }

######################################
# Revenue Information
######################################
  ## Revenue
  dimension: lifetime_revenue {
    group_label: "Revenue Information"
    type: number
    value_format_name: usd
    sql: ${TABLE}.lifetime_revenue ;;
  }

  dimension: lifetime_revenue_tier {
    group_label: "Revenue Information"
    type: tier
    tiers: [0, 25, 50, 100, 200, 500, 1000]
    sql: ${lifetime_revenue} ;;
    style: integer
  }

  measure: average_lifetime_revenue {
    group_label: "Revenue Information"
    type: average
    value_format_name: usd
    sql: ${lifetime_revenue} ;;
  }

  measure: total_lifetime_revenue {
    group_label: "Revenue Information"
    type: sum
    value_format_name: usd
    sql: ${lifetime_revenue} ;;
  }

  ## Gross Revenue
  dimension: lifetime_gross_revenue {
    group_label: "Revenue Information"
    type: number
    value_format_name: usd
    sql: ${TABLE}.lifetime_gross_revenue ;;
  }

  measure: average_lifetime_gross_revenue {
    group_label: "Revenue Information"
    type: average
    value_format_name: usd
    sql: ${lifetime_gross_revenue} ;;
  }

  measure: total_lifetime_gross_revenue {
    group_label: "Revenue Information"
    type: sum
    value_format_name: usd
    sql: ${lifetime_gross_revenue} ;;
  }

  ## Revenue Lost to Returns
  measure: total_revenue_lost_to_returns {
    label: "Total Revenue Lost to Returns"
    group_label: "Revenue Information"
    type: sum
    value_format_name: usd
    sql: ${lifetime_revenue} - ${lifetime_gross_revenue}  ;;
  }

  measure: avg_revenue_lost_to_returns  {
    label: "Average Revenue Lost to Returns"
    group_label: "Revenue Information"
    type: average
    value_format_name: usd
    sql: ${lifetime_revenue} - ${lifetime_gross_revenue}  ;;
  }
}
