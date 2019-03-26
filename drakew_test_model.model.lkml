connection: "thelook_events_redshift"

include: "*.view.lkml"                       # include all views in this project

# }
datagroup: drakew_sandbox_default_datagroup {
  # sql_trigger: SELECT MAX(id) FROM etl_log;;
  max_cache_age: "1 hour"
}

persist_with: drakew_sandbox_default_datagroup

#explore: products {
#  hidden:  yes
#  join: inventory_items {
#    type:  left_outer
#    sql_on:  ${inventory_items.product_id} = ${products.id} ;;
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
#      }
#  }


explore: users {
  hidden:  yes
  join: revenue_per_user {
  sql_on:  ${users.id} = ${revenue_per_user.user_id} ;;
  relationship:  one_to_one
  }

  join: order_items {
    type:  left_outer
    sql_on:  ${users.id} = ${order_items.user_id} ;;
    relationship:  one_to_many
  }
}
