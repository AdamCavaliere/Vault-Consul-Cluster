data "aws_iam_policy_document" "hashistack" {
  statement {
    sid       = "AllowSelfAssembly"
    effect    = "Allow"
    resources = ["*"]

    actions = [
      "autoscaling:DescribeAutoScalingGroups",
      "autoscaling:DescribeAutoScalingInstances",
      "ec2:DescribeAvailabilityZones",
      "ec2:DescribeInstanceAttribute",
      "ec2:DescribeInstanceStatus",
      "ec2:DescribeInstances",
      "ec2:DescribeSubnets",
      "ec2:DescribeVpcs",
      "ec2:DescribeTags",
      "iam:GetInstanceProfile",
      "iam:GetUser",
      "iam:GetRole",
    ]
  }
}

resource "aws_iam_role" "hashistack" {
  name               = "hashistack-${var.environment_name}"
  assume_role_policy = "${data.aws_iam_policy_document.assume_role.json}"
}

resource "aws_iam_role_policy" "hashistack" {
  name   = "hashistack-${var.environment_name}-SelfAssembly"
  role   = "${aws_iam_role.hashistack.id}"
  policy = "${data.aws_iam_policy_document.hashistack.json}"
}

resource "aws_iam_instance_profile" "hashistack" {
  name = "hashistack-${var.environment_name}"
  role = "${aws_iam_role.hashistack.name}"
}
