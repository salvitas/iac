resource "aws_appsync_graphql_api" "appsync" {
  authentication_type = "AMAZON_COGNITO_USER_POOLS"
  name = var.api_name

  user_pool_config {
    aws_region = var.global_region
    user_pool_id = var.cognito_pool_id
    default_action = "ALLOW" //DENY
  }

  schema = file("${path.module}/data/schema.graphql")
  log_config {
    cloudwatch_logs_role_arn = var.role_arn
    field_log_level = "NONE"
  }
}

resource "aws_appsync_datasource" "appsync_dynamodb_ds" {
  for_each = toset(var.table_names)
  api_id = aws_appsync_graphql_api.appsync.id
  name = each.key
  service_role_arn = var.role_arn
  type = "AMAZON_DYNAMODB"

  dynamodb_config {
    table_name = each.key
  }
}

resource "aws_appsync_datasource" "appsync_eks_ds" {
  api_id = aws_appsync_graphql_api.appsync.id
  name = "microservices_${terraform.workspace}"
  type = "HTTP"
  http_config {
    endpoint = var.loadbalancer_url
  }
}


// Resolvers
resource "aws_appsync_resolver" "customers_account_resolver" {
  depends_on = [aws_appsync_datasource.appsync_dynamodb_ds]
  api_id      = aws_appsync_graphql_api.appsync.id
  type        = "Customer"
  field       = "accounts"
  data_source = var.accounts_data_source // TODO: try to make this dynamic aws_appsync_datasource.appsync_dynamodb_ds.name
  request_template = file("${path.module}/data/resolvers/Customers.accounts.request.vtl")
  response_template = file("${path.module}/data/resolvers/Customers.accounts.response.vtl")
}

resource "aws_appsync_resolver" "customers_totalbalance_resolver" {
  depends_on = [aws_appsync_datasource.appsync_dynamodb_ds]
  api_id      = aws_appsync_graphql_api.appsync.id
  type        = "Customer"
  field       = "totalBalance"
  data_source = var.accounts_data_source // TODO: try to make this dynamic aws_appsync_datasource.appsync_dynamodb_ds.name
  request_template = file("${path.module}/data/resolvers/Customers.totalBalance.request.vtl")
  response_template = file("${path.module}/data/resolvers/Customers.totalBalance.response.vtl")
}

resource "aws_appsync_resolver" "accounts_transactions_resolver" {
  depends_on = [aws_appsync_datasource.appsync_dynamodb_ds]
  api_id      = aws_appsync_graphql_api.appsync.id
  type        = "Account"
  field       = "transactions"
  data_source = var.transactions_data_source // TODO: try to make this dynamic aws_appsync_datasource.appsync_dynamodb_ds.name
  request_template = file("${path.module}/data/resolvers/Accounts.transactions.request.vtl")
  response_template = file("${path.module}/data/resolvers/Accounts.transactions.response.vtl")
}

resource "aws_appsync_resolver" "get_customers_resolver" {
  depends_on = [aws_appsync_datasource.appsync_dynamodb_ds]
  api_id      = aws_appsync_graphql_api.appsync.id
  type        = "Query"
  field       = "getCustomer"
  data_source = var.customers_data_source // TODO: try to make this dynamic aws_appsync_datasource.appsync_dynamodb_ds.name
  request_template = file("${path.module}/data/resolvers/Query.getCustomer.request.vtl")
  response_template = file("${path.module}/data/resolvers/Query.getCustomer.response.vtl")
}

resource "aws_appsync_resolver" "get_transactions_by_accountid_resolver" {
  depends_on = [aws_appsync_datasource.appsync_dynamodb_ds]
  api_id      = aws_appsync_graphql_api.appsync.id
  type        = "Query"
  field       = "getTransactionsByAccountIdOrderedByOperationDate"
  data_source = var.transactions_data_source // TODO: try to make this dynamic aws_appsync_datasource.appsync_dynamodb_ds.name
  request_template = file("${path.module}/data/resolvers/Query.getTransactionsByAccountIdOrderedByOperationDate.request.vtl")
  response_template = file("${path.module}/data/resolvers/Query.getTransactionsByAccountIdOrderedByOperationDate.response.vtl")
}

resource "aws_appsync_resolver" "get_transaction_resolver" {
  depends_on = [aws_appsync_datasource.appsync_dynamodb_ds]
  api_id      = aws_appsync_graphql_api.appsync.id
  type        = "Query"
  field       = "getTransaction"
  data_source = var.transactions_data_source // TODO: try to make this dynamic aws_appsync_datasource.appsync_dynamodb_ds.name
  request_template = file("${path.module}/data/resolvers/Query.getTransaction.request.vtl")
  response_template = file("${path.module}/data/resolvers/Query.getTransaction.response.vtl")
}

resource "aws_appsync_resolver" "get_fav_accounts_by_customerid_resolver" {
  depends_on = [aws_appsync_datasource.appsync_dynamodb_ds]
  api_id      = aws_appsync_graphql_api.appsync.id
  type        = "Query"
  field       = "getFavouriteAccountsByCustomerIdOrderedByAlias"
  data_source = var.favourite_account_data_source // TODO: try to make this dynamic aws_appsync_datasource.appsync_dynamodb_ds.name
  request_template = file("${path.module}/data/resolvers/Query.getFavouriteAccountsByCustomerIdOrderedByAlias.request.vtl")
  response_template = file("${path.module}/data/resolvers/Query.getFavouriteAccountsByCustomerIdOrderedByAlias.response.vtl")
}

resource "aws_appsync_resolver" "get_accounts_by_customerid_resolver" {
  depends_on = [aws_appsync_datasource.appsync_dynamodb_ds]
  api_id      = aws_appsync_graphql_api.appsync.id
  type        = "Query"
  field       = "getAccountsByCustomerIdOrderedByAccountType"
  data_source = var.accounts_data_source // TODO: try to make this dynamic aws_appsync_datasource.appsync_dynamodb_ds.name
  request_template = file("${path.module}/data/resolvers/Query.getAccountsByCustomerIdOrderedByAccountType.request.vtl")
  response_template = file("${path.module}/data/resolvers/Query.getAccountsByCustomerIdOrderedByAccountType.response.vtl")
}

resource "aws_appsync_resolver" "get_interest_rate_resolver" {
  depends_on = [aws_appsync_datasource.appsync_eks_ds]
  api_id      = aws_appsync_graphql_api.appsync.id
  type        = "Query"
  field       = "getInterestRate"
  data_source = aws_appsync_datasource.appsync_eks_ds.name
  request_template = file("${path.module}/data/resolvers/Query.getInterestRate.request.vtl")
  response_template = file("${path.module}/data/resolvers/Query.getInterestRate.response.vtl")
}

resource "aws_appsync_resolver" "get_fx_rate_resolver" {
  depends_on = [aws_appsync_datasource.appsync_eks_ds]
  api_id      = aws_appsync_graphql_api.appsync.id
  type        = "Query"
  field       = "getFXRate"
  data_source = aws_appsync_datasource.appsync_eks_ds.name
  request_template = file("${path.module}/data/resolvers/Query.getFXRate.request.vtl")
  response_template = file("${path.module}/data/resolvers/Query.getFXRate.response.vtl")
}

resource "aws_appsync_resolver" "create_transfer_resolver" {
  depends_on = [aws_appsync_datasource.appsync_eks_ds]
  api_id      = aws_appsync_graphql_api.appsync.id
  type        = "Mutation"
  field       = "createTransfer"
  data_source = aws_appsync_datasource.appsync_eks_ds.name
  request_template = file("${path.module}/data/resolvers/Mutation.createTransfer.request.vtl")
  response_template = file("${path.module}/data/resolvers/Mutation.createTransfer.response.vtl")
}

resource "aws_appsync_resolver" "create_fxtransfer_resolver" {
  depends_on = [aws_appsync_datasource.appsync_eks_ds]
  api_id      = aws_appsync_graphql_api.appsync.id
  type        = "Mutation"
  field       = "createFXTransfer"
  data_source = aws_appsync_datasource.appsync_eks_ds.name
  request_template = file("${path.module}/data/resolvers/Mutation.createFXTransfer.request.vtl")
  response_template = file("${path.module}/data/resolvers/Mutation.createFXTransfer.response.vtl")
}

resource "aws_appsync_resolver" "create_loan_resolver" {
  depends_on = [aws_appsync_datasource.appsync_eks_ds]
  api_id      = aws_appsync_graphql_api.appsync.id
  type        = "Mutation"
  field       = "createLoan"
  data_source = aws_appsync_datasource.appsync_eks_ds.name
  request_template = file("${path.module}/data/resolvers/Mutation.createLoan.request.vtl")
  response_template = file("${path.module}/data/resolvers/Mutation.createLoan.response.vtl")
}

resource "aws_appsync_resolver" "sign_operation_resolver" {
  depends_on = [aws_appsync_datasource.appsync_eks_ds]
  api_id      = aws_appsync_graphql_api.appsync.id
  type        = "Mutation"
  field       = "signOperation"
  data_source = aws_appsync_datasource.appsync_eks_ds.name
  request_template = file("${path.module}/data/resolvers/Mutation.signOperation.request.vtl")
  response_template = file("${path.module}/data/resolvers/Mutation.signOperation.response.vtl")
}