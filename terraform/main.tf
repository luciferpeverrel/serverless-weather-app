provider "aws" {
  region = "ap-south-1"
}

resource "aws_s3_bucket" "weather" {
  bucket = "weatherapp973468"
}

resource "aws_iam_role" "lambda_exec" {
  name = "lambda-exec-role-973468"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "lambda.amazonaws.com"
        }
      }
    ]
  })
}

resource "aws_iam_policy_attachment" "lambda_basic_execution" {
  name       = "lambda-basic-execution"
  roles      = [aws_iam_role.lambda_exec.name]
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

resource "aws_lambda_function" "weather-app" {
  function_name    = "serverless-weather-app"
  filename        = "../lambda/Lambda.zip"
  source_code_hash = filebase64sha256("../lambda/Lambda.zip")
  role            = aws_iam_role.lambda_exec.arn
  handler         = "index.handler"
  runtime         = "nodejs22.x"
  environment {
    variables = {
      LOG_LEVEL = "info"
      WEATHER_API_KEY = var.weather_api_key
    }
  }
}
