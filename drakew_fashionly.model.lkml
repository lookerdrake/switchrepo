connection: "thelook_events_redshift"

# include all the views
include: "*.view"

access_grant: can_see_age {
  allowed_values: ["ABC"]
  user_attribute: user_country
}


datagroup: drakew_sandbox_default_datagroup {
  # sql_trigger: SELECT MAX(id) FROM etl_log;;
  max_cache_age: "1 hour"
}

persist_with: drakew_sandbox_default_datagroup


explore: users {
  required_access_grants: [can_see_age]

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

#explore: order_items {
#
#  join: users {
#  type: left_outer
#  sql_on: ${order_items.user_id} = ${users.id} ;;
#  relationship: one_to_one
#  }
#
#  join: products {
#    type: left_outer
#    sql_on: ${order_items.product_id} = ${products.id} ;;
#    relationship: many_to_one
#  }
#
#  join: distribution_centers {
#    type: left_outer
#    sql_on: ${products.distribution_center_id} = ${distribution_centers.id} ;;
#    relationship: many_to_one
#  }
#
#}


#explore: sessions {
# join: user_facts_table  {
#   type: left_outer
#   sql_on: ${sessions.session_user_id} = ${user_facts_table.user_id} ;;
#   relationship: many_to_one
#   }
#
# join: users {
#   type: left_outer
#   sql_on: ${user_facts_table.user_id} = ${users.id} ;;
#   relationship: one_to_one
#   }
#
# join: events {
#   view_label: "Landing Event Information"
#   fields: [ip, location, os, browser, traffic_source, user_id, count, unique_visitors_m, count_m]
#   type: left_outer
#   sql_on: ${sessions.landing_event_id} = ${events.event_id} ;;
#   relationship: one_to_one
#   }
#}
