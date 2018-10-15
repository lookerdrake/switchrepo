view: order_items {
  derived_table: {
    persist_for: "24 hours"
    distribution_style: all
    sql:
      SELECT
        oi.order_id as order_id,
        oi.id as order_item_id,
        oi.inventory_item_id as inventory_item_id,
        ii.product_id as product_id,
        oi.user_id as user_id,
        oi.status as status,
        CASE
          WHEN oi.returned_at IS NOT NULL THEN TRUE
          ELSE FALSE
        END as was_returned,
        oi.created_at as created,
        oi.shipped_at as shipped,
        oi.delivered_at as delivered,
        oi.returned_at as returned,
        oi.sale_price as order_price,
        ii.cost as order_cost,
        oi.sale_price - ii.cost as gross_margin

        FROM public.order_items as oi
        LEFT JOIN public.inventory_items as ii ON(oi.inventory_item_id = ii.id)
        ;;
  }

  dimension: order_id {
    primary_key:  yes
    type:  number
    sql:${TABLE}.order_id  ;;
  }

  dimension: user_id {
    type: number
    sql: ${TABLE}.user_id ;;
  }

  dimension: inventory_item_id  {
    hidden: yes
    type: number
    sql: ${TABLE}.inventory_item_id ;;
  }

  dimension: product_id {
    hidden: yes
    type: number
    sql: ${TABLE}.product_id ;;
  }

  dimension: order_status {
    type: string
    sql: ${TABLE}.status ;;
  }

  dimension: was_returned {
    type: yesno
    sql: ${TABLE}.was_returned ;;
    label: "Item Returned?"
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
    sql: ${TABLE}.created ;;
  }

  dimension_group: shipped {
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
    sql: ${TABLE}.shipped ;;
  }

  dimension_group: delivered {
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
    sql: ${TABLE}.delivered ;;
  }

  dimension_group: returned {
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
    sql: ${TABLE}.returned ;;
  }

  measure: count {
    type: count
    drill_fields: [user_id,
      created_date,
      shipped_date,
      delivered_date,
      returned_date,
      sale_price,
      order_status,
      products.name
    ]
  }

  dimension: sale_price  {
    label: "Item Sale Price"
    description: "Sale price"
    type: number
    value_format_name: usd
    sql: ${TABLE}.order_price ;;
  }

  measure: avg_sale_price {
    label: "Avg. Sale Price"
    type: average
    value_format_name: usd
    sql: ${TABLE}.order_price ;;
  }

  dimension: item_cost  {
    label: "Item Cost"
    description: "Cost of an item to stock"
    type: number
    value_format_name: usd
    sql: ${TABLE}.order_cost ;;
  }

  measure: cumulative_total_sales {
    label: "Cumulative Total Sales"
    description: "Cumulative total sales from items sold (also known as a running total)"
    type: running_total
    value_format_name: usd
    sql: ${total_revenue} ;;
  }

  measure: total_revenue {
    label: "Total Revenue"
    description: "Total Revenue"
    type: sum
    value_format_name: usd
    sql: ${sale_price} ;;
  }

  measure: total_gross_revenue {
    label: "Total Gross Revenue"
    description: "Total revenue from completed sales (excl. cancelled + returned orders)"
    type: sum
    value_format_name: usd
    sql: ${sale_price} ;;

    filters: {
      field: order_status
      value: "Processing, Complete, Shipped"
      }
    }

  measure: total_cost {
    label: "Total Cost of Items Sold"
    description: "Total cost of all sold items"
    type: sum
    value_format_name: usd
    sql: ${item_cost} ;;
  }

  measure: avg_cost {
    label: "Average Cost of a Sold Item"
    description: "Average cost of a sold item"
    type: average
    value_format_name: usd
    sql: ${item_cost} ;;
  }

  measure: total_gross_margin {
    label: "Total Gross Margin"
    group_label: "Margin Measures"
    description: "Total difference between the total revenue from completed sales the cost of goods that were sold"
    type: sum
    value_format_name: usd
    sql: ${sale_price} - ${item_cost} ;;

    filters: {
      field: order_status
      value: "Processing, Complete, Shipped"
    }
  }

  measure: avg_gross_margin {
    label: "Average Gross Margin"
    group_label: "Margin Measures"
    description: "Avg. difference between the total revenue from completed sales the cost of goods that were sold"
    type: average
    value_format_name: usd
    sql: ${sale_price} - ${item_cost} ;;

  }

  measure: pct_gross_margin {
    label: "Gross Margin Percentage"
    group_label: "Margin Measures"
    description: "Total gross margin amount / total revenue"
    type: number
    value_format: "#.00%"
    sql: ${total_gross_margin} / NULLIF(${total_gross_revenue},0) ;;
    drill_fields: [ products.name, products.category, count, avg_sale_price, avg_cost ]
    }

##################################################
######     Measures relating to Returns   #######
##################################################
  measure: num_items_returned {
    label: "Number of Items Returned"
    group_label: "Return Measures"
    description: "Number of Items Returned"
    type: count_distinct
    value_format: "0.00"
    sql: ${TABLE}.order_item_id  ;;

    filters: {
      field: was_returned
      value: "TRUE"
      }
    }

  measure: item_return_rate {
    label: "Item Return Rate"
    group_label: "Return Measures"
    description: "Percentage of sold items that get returned"
    type: number
    value_format: "#.00%"
    sql: ${num_items_returned} / NULLIF(${num_items_returned}, 0) ;;
    }

  measure: revenue_returned {
    label: "Revenue Lost to Returns"
    group_label: "Return Measures"
    description: "The total revenue of items that have been returned"
    type: sum
    value_format_name: usd
    sql: ${sale_price} ;;

    filters: {
      field: was_returned
      value: "yes"
    }
  }

##################################################
##################################################
##################################################

  dimension: price_range {
    case: {
      when: {
        sql: ${sale_price} < 20 ;;
        label: "Inexpensive"

        }
      when: {
        sql: ${sale_price} > 20 and ${sale_price} <= 100 ;;
        label: "Affordable"

        }
      when: {
        sql: ${sale_price} > 100 ;;
        label: "Expensive"
        }
    }
  }

  measure: max_item {
    label: "Highest Priced Item"
    description: "The most expensive item"
    value_format_name: usd
    type: max
    sql: ${sale_price} ;;
  }

  measure: min_item {
    label: "Lowest Priced Item"
    description: "The least expensive item"
    value_format_name: usd
    type:  min
    sql: ${sale_price} ;;
  }

####### # Orders Over Time #######
  measure: count_orders_this_week {
    label: "Orders This Week"
    group_label: "Orders over Time"
    type: count
    filters: {
      field: created_week
      value: "this week"
    }
  }

  measure: count_orders_this_month {
    label: "Orders This Month"
    group_label: "Orders over Time"
    type: count
    filters: {
      field: created_month
      value: "this month"
    }
  }

  measure: count_orders_this_quarter {
    label: "Orders This Quarter"
    group_label: "Orders over Time"
    type: count
    filters: {
      field: created_quarter
      value: "this quarter"
    }
  }

  measure: count_orders_this_year {
    label: "Orders This Year"
    group_label: "Orders over Time"
    type: count
    filters: {
      field: created_year
      value: "this year"
    }
  }


####### Revenue Over Time #######
  measure: revenue_yesterday {
    label: "Revenue Yesterday"
    group_label: "Revenue over Time"
    type: sum
    value_format_name: usd
    sql: ${sale_price} ;;
    filters: {
      field: created_date
      value: "yesterday"
    }
  }

  measure: revenue_this_week {
    label: "Revenue This Week"
    group_label: "Revenue over Time"
    type: sum
    value_format_name: usd
    sql: ${sale_price} ;;
    filters: {
      field: created_date
      value: "this week"
      }
    }

  measure: revenue_this_month {
    label: "Revenue This Month"
    group_label: "Revenue over Time"
    type: sum
    value_format_name: usd
    sql: ${sale_price} ;;
    filters: {
      field: created_month
      value: "this month"
    }
  }

  measure: revenue_this_quarter {
    label: "Revenue This Quarter"
    group_label: "Revenue over Time"
    type: sum
    value_format_name: usd
    sql: ${sale_price} ;;
    filters: {
      field: created_quarter
      value: "this quarter"
    }
  }

  measure: revenue_this_year {
    label: "Revenue This Year"
    group_label: "Revenue over Time"
    type: sum
    value_format_name: usd
    sql: ${sale_price} ;;
    filters: {
      field: created_year
      value: "this year"
    }
  }

  measure: pct_of_revenue {
    label: "Percent of Total Revenue"
    type: percent_of_total
    sql: ${total_revenue}/10000;;
    value_format_name: percent_2
  }

  measure: avg_time_to_deliver  {
    label: "Average Days to Delivery"
    type: average
    sql: DATEDIFF(day, ${created_date}, ${delivered_date}) ;;
    }

}



###############################
###############################
# Below is the original view ##
###############################
###############################
# view: order_items {
#   sql_table_name: public.order_items ;;
#
#   dimension: id {
#     primary_key: yes
#     type: number
#     sql: ${TABLE}.id ;;
#   }
#
#   dimension_group: created {
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
#     sql: ${TABLE}.created_at ;;
#   }
#
#   dimension_group: delivered {
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
#     sql: ${TABLE}.delivered_at ;;
#   }
#
#   dimension: inventory_item_id {
#     type: number
#     # hidden: yes
#     sql: ${TABLE}.inventory_item_id ;;
#   }
#
#   dimension: order_id {
#     type: number
#     sql: ${TABLE}.order_id ;;
#   }
#
#   dimension_group: returned {
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
#     sql: ${TABLE}.returned_at ;;
#   }
#
#   dimension: sale_price {
#     type: number
#     sql: ${TABLE}.sale_price ;;
#   }
#
#   dimension_group: shipped {
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
#     sql: ${TABLE}.shipped_at ;;
#   }
#
#   dimension: status {
#     type: string
#     sql: ${TABLE}.status ;;
#   }
#
#   dimension: user_id {
#     type: number
#     # hidden: yes
#     sql: ${TABLE}.user_id ;;
#   }
#
#   measure: count {
#     type: count
#     drill_fields: [detail*]
#   }
#
#   # ----- Sets of fields for drilling ------
#   set: detail {
#     fields: [
#       id,
#       users.id,
#       users.first_name,
#       users.last_name,
#       inventory_items.id,
#       inventory_items.product_name
#     ]
#   }
#   }
