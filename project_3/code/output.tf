output "account_id" {
  value = data.aws_caller_identity.acc_id.account_id
}

output "user_names" {
  description = "Find users names from csv using local variable"
  value = [for user in local.users: "${user.first_name} ${user.last_name}"]
}