resource "aws_iam_role" "step_functions" {
  name = "${var.name}-step-functions-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Action = "sts:AssumeRole"
      Principal = {
        Service = "states.amazonaws.com"
      }
    }]
  })
}

resource "aws_iam_role_policy" "step_functions_glue" {
  name = "${var.name}-step-functions-glue-policy"
  role = aws_iam_role.step_functions.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Action = [
        "glue:StartJobRun",
        "glue:GetJobRun",
        "glue:GetJobRuns",
        "glue:BatchStopJobRun"
      ]
      Resource = "*"
    }]
  })
}

resource "aws_sfn_state_machine" "extraction" {
  name     = "${var.name}-extraction-workflow"
  role_arn = aws_iam_role.step_functions.arn

  definition = jsonencode({
    Comment = "Run DWH extraction Glue job"
    StartAt = "RunExtractionGlueJob"
    States = {
      RunExtractionGlueJob = {
        Type     = "Task"
        Resource = "arn:aws:states:::glue:startJobRun.sync"
        Parameters = {
          JobName = aws_glue_job.extraction.name
        }
        End = true
      }
    }
  })
}

resource "aws_sfn_state_machine" "loading" {
  name     = "${var.name}-loading-workflow"
  role_arn = aws_iam_role.step_functions.arn

  definition = jsonencode({
    Comment = "Run DWH loading Glue job"
    StartAt = "RunLoadingGlueJob"
    States = {
      RunLoadingGlueJob = {
        Type     = "Task"
        Resource = "arn:aws:states:::glue:startJobRun.sync"
        Parameters = {
          JobName = aws_glue_job.loading.name
        }
        End = true
      }
    }
  })
}
