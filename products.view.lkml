view: products {
  sql_table_name: public.products ;;

  dimension: id {
    hidden: yes
    primary_key: yes
    type: number
    sql: ${TABLE}.id ;;
  }

#   dimension: brand {
#     type: string
#     sql: ${TABLE}.brand ;;
#   }

  dimension: category {
    type: string
    sql: ${TABLE}.category ;;
  }

  dimension: cost {
    type: number
    sql: ${TABLE}.cost ;;
  }

  dimension: department {
    type: string
    sql: ${TABLE}.department ;;
  }

  dimension: distribution_center_id {
    type: number
    hidden: yes
    sql: ${TABLE}.distribution_center_id ;;
  }

  dimension: name {
    type: string
    sql: ${TABLE}.name ;;
  }

  dimension: retail_price {
    type: number
    sql: ${TABLE}.retail_price ;;
  }

  dimension: sku {
    type: string
    sql: ${TABLE}.sku ;;
  }

  measure: count {
    type: count
    drill_fields: [id, name, distribution_centers.id, distribution_centers.name, inventory_items.count]
  }

  measure: avg_cost {
    type:  average
    sql:  ${TABLE}.cost ;;
  }

  dimension: brand {
    type: string
    sql: ${TABLE}.brand ;;
    link: {
      label: "Google Search"
      url: "http://www.google.com/search?q={{ value }}+Clothing"
      icon_url: "http://google.com/favicon.ico"
    }
    link: {
      label: "Facebook Search"
      url: "https://www.facebook.com/search?q= {{value}}+Clothing"
      icon_url: "https://www.facebook.com/favicon.ico"
    }
  }
}
