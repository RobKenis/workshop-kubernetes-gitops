resource "aws_ecr_repository" "default" {
  name                 = "workshop-kubernetes-gitops"
  image_tag_mutability = "MUTABLE"

  image_scanning_configuration {
    scan_on_push = true
  }
}

// Can't be bothered with OIDC
resource "aws_iam_user" "bitbucket" {
  name = "bitbucket"
}

data "aws_iam_policy_document" "push_to_ecr" {
  statement {
    effect = "Allow"
    actions = [
      "ecr:GetDownloadUrlForLayer",
      "ecr:BatchGetImage",
      "ecr:BatchCheckLayerAvailability",
      "ecr:PutImage",
      "ecr:InitiateLayerUpload",
      "ecr:UploadLayerPart",
      "ecr:CompleteLayerUpload",
    ]
    resources = [aws_ecr_repository.default.arn]
  }
  statement {
    effect = "Allow"
    actions = ["ecr:GetAuthorizationToken"]
    resources = ["*"]
  }
}

resource "aws_iam_user_policy" "push_to_ecr" {
  name   = "push-to-ecr"
  user   = aws_iam_user.bitbucket.name
  policy = data.aws_iam_policy_document.push_to_ecr.json
}
