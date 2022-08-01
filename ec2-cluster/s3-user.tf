resource "aws_iam_user" "s3_access" {
  name = "s3_access"
  path = "/system/"
}

resource "aws_iam_access_key" "s3_access" {
  user = aws_iam_user.s3_access.name
}

resource "aws_iam_user_policy" "s3_access" {
  name = "s3_access"
  user = aws_iam_user.s3_access.name

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": [
        "s3:ListBucket"
      ],
      "Effect": "Allow",
      "Resource": [
        "${data.aws_s3_bucket.cluster_snapshots.arn}"
      ]
    },
    {
      "Action": [
        "s3:GetObject",
        "s3:PutObject"
      ],
      "Effect": "Allow",
      "Resource": [
        "${data.aws_s3_bucket.cluster_snapshots.arn}/*"
      ]
    }
  ]
}
EOF
}
