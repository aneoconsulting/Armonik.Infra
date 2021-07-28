# Copyright 2021 Amazon.com, Inc. or its affiliates. All Rights Reserved.
# SPDX-License-Identifier: Apache-2.0
# Licensed under the Apache License, Version 2.0 https://aws.amazon.com/apache-2-0/


resource "aws_api_gateway_rest_api" "htc_grid_private_rest_api" {
  depends_on = [
    kubernetes_service.local_services
  ]
  name        = "${var.cluster_name}-private"
  description = "Private API Gateway for HTC Grid"
  endpoint_configuration {
    types = ["PRIVATE"]
  }
  policy = data.aws_iam_policy_document.private_api_policy_document.json
}

resource "aws_api_gateway_resource" "htc_grid_private_submit_proxy" {
  depends_on = [
    kubernetes_service.local_services
  ]
  path_part   = "submit"
  rest_api_id = aws_api_gateway_rest_api.htc_grid_private_rest_api.id
  parent_id   = aws_api_gateway_rest_api.htc_grid_private_rest_api.root_resource_id
}

resource "aws_api_gateway_integration" "htc_grid_private_submit_proxy_integration" {
  depends_on = [
    kubernetes_service.local_services
  ]
  rest_api_id              = aws_api_gateway_rest_api.htc_grid_private_rest_api.id
  resource_id              = aws_api_gateway_resource.htc_grid_private_submit_proxy.id
  http_method              = aws_api_gateway_method.htc_grid_private_submit_proxy_method.http_method
  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  #uri                     = module.submit_task.this_lambda_function_invoke_arn
  uri                     = module.submit_task.lambda_function_invoke_arn
}


resource "aws_api_gateway_method" "htc_grid_private_submit_proxy_method" {
  depends_on = [
    kubernetes_service.local_services
  ]
  rest_api_id                   = aws_api_gateway_rest_api.htc_grid_private_rest_api.id
  resource_id                   = aws_api_gateway_resource.htc_grid_private_submit_proxy.id
  http_method                   = "POST"
  authorization                 = "NONE"
}

resource "aws_api_gateway_method_settings" "htc_grid_private_submit_method_setting" {
  depends_on = [
    kubernetes_service.local_services
  ]
  rest_api_id = aws_api_gateway_rest_api.htc_grid_private_rest_api.id
  stage_name  = aws_api_gateway_deployment.htc_grid_private_deployment.stage_name
  method_path = "${aws_api_gateway_resource.htc_grid_private_submit_proxy.path_part}/${aws_api_gateway_method.htc_grid_private_submit_proxy_method.http_method}"

  settings {
    metrics_enabled = true
    logging_level   = "INFO"
  }
}



resource "aws_api_gateway_resource" "htc_grid_private_result_proxy" {
  depends_on = [
    kubernetes_service.local_services
  ]
  path_part   = "result"
  rest_api_id = aws_api_gateway_rest_api.htc_grid_private_rest_api.id
  parent_id   = aws_api_gateway_rest_api.htc_grid_private_rest_api.root_resource_id
}

resource "aws_api_gateway_integration" "htc_grid_private_result_proxy_integration" {
  depends_on = [
    kubernetes_service.local_services
  ]
  rest_api_id              = aws_api_gateway_rest_api.htc_grid_private_rest_api.id
  resource_id              = aws_api_gateway_resource.htc_grid_private_result_proxy.id
  http_method              = aws_api_gateway_method.htc_grid_private_result_proxy_method.http_method
  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  #uri                     = module.get_results.this_lambda_function_invoke_arn
  uri                     = module.get_results.lambda_function_invoke_arn
}


resource "aws_api_gateway_method" "htc_grid_private_result_proxy_method" {
  depends_on = [
    kubernetes_service.local_services
  ]
  rest_api_id                   = aws_api_gateway_rest_api.htc_grid_private_rest_api.id
  resource_id                   = aws_api_gateway_resource.htc_grid_private_result_proxy.id
  http_method                   = "GET"
  authorization                 = "NONE"
}

resource "aws_api_gateway_method_settings" "htc_grid_private_result_method_setting" {
  depends_on = [
    kubernetes_service.local_services
  ]
  rest_api_id = aws_api_gateway_rest_api.htc_grid_private_rest_api.id
  stage_name  = aws_api_gateway_deployment.htc_grid_private_deployment.stage_name
  method_path = "${aws_api_gateway_resource.htc_grid_private_result_proxy.path_part}/${aws_api_gateway_method.htc_grid_private_result_proxy_method.http_method}"

  settings {
    metrics_enabled = true
    logging_level   = "INFO"
  }
}


resource "aws_api_gateway_resource" "htc_grid_private_cancel_proxy" {
  depends_on = [
    kubernetes_service.local_services
  ]
  path_part   = "cancel"
  rest_api_id = aws_api_gateway_rest_api.htc_grid_private_rest_api.id
  parent_id   = aws_api_gateway_rest_api.htc_grid_private_rest_api.root_resource_id
}

resource "aws_api_gateway_integration" "htc_grid_private_cancel_proxy_integration" {
  depends_on = [
    kubernetes_service.local_services
  ]
  rest_api_id              = aws_api_gateway_rest_api.htc_grid_private_rest_api.id
  resource_id              = aws_api_gateway_resource.htc_grid_private_cancel_proxy.id
  http_method              = aws_api_gateway_method.htc_grid_private_cancel_proxy_method.http_method
  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  #uri                     = module.cancel_tasks.this_lambda_function_invoke_arn
  uri                     = module.cancel_tasks.lambda_function_invoke_arn
}


resource "aws_api_gateway_method" "htc_grid_private_cancel_proxy_method" {
  depends_on = [
    kubernetes_service.local_services
  ]
  rest_api_id                   = aws_api_gateway_rest_api.htc_grid_private_rest_api.id
  resource_id                   = aws_api_gateway_resource.htc_grid_private_cancel_proxy.id
  http_method                   = "POST"
  authorization                 = "NONE"
}

resource "aws_api_gateway_method_settings" "htc_grid_private_cancel_method_setting" {
  depends_on = [
    kubernetes_service.local_services
  ]
  rest_api_id = aws_api_gateway_rest_api.htc_grid_private_rest_api.id
  stage_name  = aws_api_gateway_deployment.htc_grid_private_deployment.stage_name
  method_path = "${aws_api_gateway_resource.htc_grid_private_cancel_proxy.path_part}/${aws_api_gateway_method.htc_grid_private_cancel_proxy_method.http_method}"

  settings {
    metrics_enabled = true
    logging_level   = "INFO"
  }
}




resource "aws_api_gateway_deployment" "htc_grid_private_deployment" {
  depends_on = [
    aws_api_gateway_method.htc_grid_private_submit_proxy_method,
    aws_api_gateway_method.htc_grid_private_result_proxy_method,
    kubernetes_service.local_services
  ]
  rest_api_id = aws_api_gateway_rest_api.htc_grid_private_rest_api.id
  triggers = {
    redeployment = sha1(join(",", tolist([
    jsonencode(aws_api_gateway_integration.htc_grid_private_submit_proxy_integration),
    jsonencode(aws_api_gateway_integration.htc_grid_private_result_proxy_integration),
    jsonencode(aws_api_gateway_integration.htc_grid_private_cancel_proxy_integration)
    ])))
  }

  stage_name = var.api_gateway_version

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_api_gateway_usage_plan" "htc_grid_usage_plan" {
  depends_on = [kubernetes_service.local_services]
  name = var.cluster_name

  api_stages {
    api_id = aws_api_gateway_rest_api.htc_grid_private_rest_api.id
    stage  = aws_api_gateway_deployment.htc_grid_private_deployment.stage_name
  }
}

resource "aws_api_gateway_api_key" "htc_grid_api_key" {
  depends_on = [kubernetes_service.local_services]
  name = var.cluster_name
}

resource "aws_api_gateway_usage_plan_key" "htc_grid_usage_plan_key" {
  depends_on = [kubernetes_service.local_services]
  key_id        = aws_api_gateway_api_key.htc_grid_api_key.id
  key_type      = "API_KEY"
  usage_plan_id = aws_api_gateway_usage_plan.htc_grid_usage_plan.id
}



resource "aws_lambda_permission" "htc_grid_apigw_private_lambda_permission_submit" {
  depends_on = [kubernetes_service.local_services]
  statement_id  = "AllowPrivateSubmitAPIGatewayInvoke-${local.suffix}"
  action        = "lambda:InvokeFunction"
  #function_name = module.submit_task.this_lambda_function_name
  function_name = module.submit_task.lambda_function_name
  principal     = "apigateway.amazonaws.com"

  # The "/*/*" portion grants access from any method on any resource
  # within the API Gateway REST API.
  source_arn = "${aws_api_gateway_rest_api.htc_grid_private_rest_api.execution_arn}/*/*"
}

resource "aws_lambda_permission" "htc_grid_private_apigw_lambda_permission_result" {
  depends_on = [kubernetes_service.local_services]
  statement_id  = "AllowPrivateResultAPIGatewayInvoke-${local.suffix}"
  action        = "lambda:InvokeFunction"
  #function_name = module.get_results.this_lambda_function_name
  function_name = module.get_results.lambda_function_name
  principal     = "apigateway.amazonaws.com"

  # The "/*/*" portion grants access from any method on any resource
  # within the API Gateway REST API.
  source_arn = "${aws_api_gateway_rest_api.htc_grid_private_rest_api.execution_arn}/*/*"
}

resource "aws_lambda_permission" "htc_grid_apigw_private_lambda_permission_cancel" {
  depends_on = [kubernetes_service.local_services]
  statement_id  = "AllowPrivateCancelAPIGatewayInvoke-${local.suffix}"
  action        = "lambda:InvokeFunction"
  #function_name = module.cancel_tasks.this_lambda_function_name
  function_name = module.cancel_tasks.lambda_function_name
  principal     = "apigateway.amazonaws.com"

  # The "/*/*" portion grants access from any method on any resource
  # within the API Gateway REST API.
  source_arn = "${aws_api_gateway_rest_api.htc_grid_private_rest_api.execution_arn}/*/*"
}

data "aws_iam_policy_document" "private_api_policy_document" {
  statement {
    effect =  "Allow"
    actions = ["execute-api:Invoke"]
    resources = [
      "execute-api:/*"
    ]
    principals {
      identifiers = ["*"]
      type = "AWS"
    }
  }

}

