view: revenue_per_user {
  derived_table: {
    sql:
    SELECT
      u.id,
      SUM(oi.sale_price) lifetime_revenue,
      SUM(oi.sale_price) - SUM(ii.cost) lifetime_profit,
      SUM(ii.cost) lifetime_cost,
      MIN(DATE(oi.created_at)) first_order,
      MAX(DATE(oi.created_at)) most_recent_order


    FROM users as u
    LEFT JOIN order_items as oi ON(u.id = oi.user_id)
    LEFT JOIN inventory_items as ii ON(ii.id = oi.inventory_item_id)
    GROUP BY 1
  ;;
  }

  dimension: user_id {
    primary_key:  yes
    hidden:  yes
    type: number
    sql:  ${TABLE}.id ;;
  }

  dimension_group: first_order {
    type:  time
    timeframes: [ date, week, month ]
    sql: ${TABLE}.first_order  ;;
  }

  dimension_group: most_recent_order {
    type:  time
    timeframes: [ date, week, month ]
    sql:  ${TABLE}.most_recent_order ;;
  }

  dimension: lifetime_revenue {
    type:  number
    value_format: "0.00"
    sql:  ${TABLE}.lifetime_revenue ;;
  }

  dimension: lifetime_profit {
    type: number
    value_format: "0.00"
    sql:  ${TABLE}.lifetime_profit ;;
  }

  dimension: lifetime_cost {
    type:  number
    value_format: "0.00"
    sql:  ${TABLE}.lifetime_cost ;;
  }

  measure: total_revenue {
    type:  sum
    value_format: "0.00"
    sql:  ${TABLE}.lifetime_revenue ;;
  }

  measure: total_profit {
    type:  sum
    value_format: "0.00"
    sql:  ${TABLE}.lifetime_profit ;;
  }

  measure: total_cost {
    type: sum
    value_format: "0.00"
    sql:  ${TABLE}.lifetime_cost ;;
  }
}
