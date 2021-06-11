resource "aws_cognito_user_pool" "iam" {
  name = var.pool_name

  auto_verified_attributes = [
    "email"
  ]
  alias_attributes = [
    "email"
  ]

  account_recovery_setting {
    recovery_mechanism {
      name = "verified_email"
      priority = 1
    }

  }

  admin_create_user_config {
    allow_admin_create_user_only = false
    invite_message_template {
      email_message = "Your username is {username} and temporary password is {####}. "
      email_subject = "Your BankStart temporary password"
      sms_message = "Your username is {username} and temporary password is {####}. "
    }
  }

  password_policy {
    minimum_length = 8
    require_lowercase = true
    require_numbers = true
    require_uppercase = true
    require_symbols = false
    temporary_password_validity_days = 7
  }

  //  ONLY with SES configuration
  //  email_configuration {
  //    from_email_address = "John Smith <john@example.com>"
  //  }

  email_verification_message = "Welcome {username}, here is your temporary password {####}"
  email_verification_subject = "Welcome to BankStart"

  //  verification_message_template {
  //    default_email_option = "CONFIRM_WITH_CODE"
  //    email_message_by_link = "Welcome {username}, please confirm your email using following link: {##Click Here##}"
  //    email_subject_by_link = "Welcome to BankStart"
  //    email_message = "Welcome {username}, here is your temporary password {####}"
  //    email_subject = "Welcome to BankStart"
  //  }

  schema {
    name = "customerId"
    attribute_data_type = "String"
    developer_only_attribute = false
    mutable = true
    required = false
    string_attribute_constraints {
      min_length = 1
      max_length = 255
    }
  }
}
resource "aws_cognito_user_pool_client" "client" {
  name = "app-client"
  user_pool_id = aws_cognito_user_pool.iam.id
  generate_secret = true
  allowed_oauth_flows_user_pool_client = true
  allowed_oauth_flows = [
    "code"
  ]
  allowed_oauth_scopes = [
    "openid"
  ]
  callback_urls = [
    "http://localhost:8080"
  ]
  default_redirect_uri = "http://localhost:8080"
  logout_urls = [
    "http://localhost:8080/logout"
  ]
  supported_identity_providers = [
    "COGNITO"
  ]
  prevent_user_existence_errors = "ENABLED"
}

resource "aws_cognito_user_pool_domain" "domain" {
  domain = "bankstart-${terraform.workspace}"
  user_pool_id = aws_cognito_user_pool.iam.id
}