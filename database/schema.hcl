table "tasks" {
  schema = schema.public
  column "id" {
    null = false
    type = bigserial
  }
  column "user_id" {
    null = false
    type = bigint
  }
  column "title" {
    null = false
    type = text
  }
  column "description" {
    null = true
    type = text
  }
  column "due_date" {
    null = true
    type = date
  }
  column "status" {
    null    = false
    type    = enum.task_status
    default = "Not_started"
  }
  column "created_at" {
    null    = true
    type    = timestamp
    default = sql("now()")
  }
  column "updated_at" {
    null    = true
    type    = timestamp
    default = sql("now()")
  }
  primary_key {
    columns = [column.id]
  }
  foreign_key "tasks_user_id_fkey" {
    columns     = [column.user_id]
    ref_columns = [table.users.column.id]
    on_update   = NO_ACTION
    on_delete   = CASCADE
  }
}
table "users" {
  schema = schema.public
  column "id" {
    null = false
    type = bigserial
  }
  column "name" {
    null = false
    type = text
  }
  column "email" {
    null = false
    type = text
  }
  column "password" {
    null = false
    type = text
  }
  column "created_at" {
    null    = true
    type    = timestamp
    default = sql("now()")
  }
  column "updated_at" {
    null    = true
    type    = timestamp
    default = sql("now()")
  }
  primary_key {
    columns = [column.id]
  }
  unique "users_email_key" {
    columns = [column.email]
  }
}
enum "task_status" {
  schema = schema.public
  values = ["Not_started", "In_progress", "Done", "Reviewing", "Wait_review"]
}
schema "public" {
  comment = "standard public schema"
}
