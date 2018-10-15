connection: "thelook_events_redshift"

# include all the views
include: "*.view"

datagroup: drakew_sandbox_default_datagroup {
  # sql_trigger: SELECT MAX(id) FROM etl_log;;
  max_cache_age: "1 hour"
}

persist_with: drakew_sandbox_default_datagroup

explore: order_items {

  join: users {
  type: left_outer
  sql_on: ${order_items.user_id} = ${users.id} ;;
  relationship: one_to_one
  }

  join: products {
    type: left_outer
    sql_on: ${order_items.product_id} = ${products.id} ;;
    relationship: many_to_one
  }

  join: distribution_centers {
    type: left_outer
    sql_on: ${products.distribution_center_id} = ${distribution_centers.id} ;;
    relationship: many_to_one
  }

}

explore: users {

  join: user_facts_table {
    type: left_outer
    sql_on: ${users.id} = ${user_facts_table.user_id} ;;
    relationship: one_to_one
  }

  join: order_items {
    type:  left_outer
    sql_on:  ${users.id} = ${order_items.user_id} ;;
    relationship:  one_to_many
  }

  join: products {
    type:  left_outer
    sql_on:  ${order_items.product_id} = ${products.id} ;;
    relationship:  many_to_one
  }

  join: distribution_centers {
    type:  left_outer
    sql_on:  ${products.distribution_center_id} = ${distribution_centers.id} ;;
    relationship:  one_to_one
  }

  join: events {
    type: left_outer
    sql_on: ${users.id} = ${events.user_id} ;;
    relationship: one_to_many
  }

}
