view: customer_facts {
  derived_table: {
    sql:
      SELECT
        id,
        count(id) as total_visits
      FROM
        public.users
      WHERE
        {% condition country %} users.country {% endcondition %} OR
        {% condition zip_code %} users.zip_code {% endcondition %}
      GROUP BY 1
    ;;
  }

  dimension: user_id {
    type: string
    sql: ${TABLE}.id ;;
  }


  dimension: total_visits {
    type: string
    sql: ${TABLE}.total_visits ;;
  }

  measure: sum_visits {
    type: sum
    sql: ${total_visits} ;;
  }

  filter: country {
    type: string
  }

  filter: zip_code {
    type: string
  }
}
