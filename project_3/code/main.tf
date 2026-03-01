resource "aws_iam_user" "users" {
  for_each = { for user in local.users: user.first_name => user }  
  
  name = lower("${substr(each.value.first_name, 0, 1)}_${each.value.last_name}")
  path = "/users/"

  tags = {
    Environment = var.env
    DisplayName = "${each.value.first_name} ${each.value.last_name}"
    Department = each.value.department
    JobTitle = each.value.job_title
  }
}