view: cohort_selector {
  derived_table: {
    sql:
    SELECT
      oi.user_id as user_id,
      ii.product_brand as product_brand

    FROM public.order_items as oi
    INNER JOIN public.inventory_items as ii ON oi.inventory_item_id = ii.id

    WHERE {% condition _cohort_selector %} ii.product_brand {% endcondition %}

    GROUP BY 1,2 ;;
  }

  filter: _cohort_selector {
    suggest_explore: products
    suggest_dimension: products.brand
    type: string
  }

  dimension: user_id {
    hidden: no
    type: string
    sql: ${TABLE}.user_id ;;
  }
}


#include: "*.view"
#
#explore: products2 {
#  from: products
#  join: cohort_selector {
#    type: inner
#    sql_on: ${order_items.user_id} = ${cohort_selector.user_id} ;;
#  }
#
#  hidden:  no
#  join: inventory_items {
#    type:  left_outer
#    sql_on:  ${inventory_items.product_id} = ${products2.id} ;;
#    relationship: one_to_one
#  }
#
#  join: distribution_centers {
#    type:  left_outer
#    sql_on:  ${inventory_items.product_distribution_center_id} = ${distribution_centers.id} ;;
#    relationship:  one_to_one
#  }
#
#  join: order_items {
#    type:  left_outer
#    sql_on: ${inventory_items.id} = ${order_items.inventory_item_id} ;;
#    relationship: one_to_one
#  }
#
#  join: users {
#    type:  left_outer
#    sql_on:  ${users.id} = ${order_items.user_id} ;;
#    relationship: one_to_one
#  }
#}
#
