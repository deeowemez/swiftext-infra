# resource "postgresql_role" "swiftext" {
#   name            = var.postgresql_role_name
#   login           = true
#   password        = var.postgresql_role_name
#   superuser       = true
#   create_database = true
#   create_role     = true
# }

# resource "postgresql_database" "file_uploads_db" {
#   provider          = postgresql
#   name              = "file_uploads"
#   owner             = "swiftext"
#   template          = "template0"
#   lc_collate        = "C"
#   connection_limit  = -1
#   allow_connections = true
# }

# resource "postgresql_grant" "grant_priv" {
#   database    = "file_uploads"
#   role        = "swiftext"
#   object_type = "database"
#   privileges  = ["SELECT", "INSERT", "UPDATE", "DELETE", "CREATE"]
# }
