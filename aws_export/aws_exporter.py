import boto3
import os
import datetime
from prometheus_client import start_http_server, Gauge
import time

# ================================
# AWS CONFIG
# ================================
AWS_PROFILE = os.getenv("AWS_PROFILE", "Aryan")
REGION = os.getenv("AWS_REGION", "us-east-1")

# Boto3 session
session = boto3.Session(profile_name=AWS_PROFILE, region_name=REGION)
ce = session.client("ce")
s3 = session.client("s3")
ec2 = session.client("ec2")

# ================================
# PROMETHEUS METRICS
# ================================
aws_cost_daily_total_usd = Gauge(
    "aws_cost_daily_total_usd", "Total AWS cost for today in USD"
)
aws_cost_monthly_total_usd = Gauge(
    "aws_cost_monthly_total_usd", "Total AWS cost for this month in USD"
)
aws_s3_total_bytes = Gauge(
    "aws_s3_total_bytes", "Total S3 storage used in bytes"
)
aws_s3_bucket_count = Gauge(
    "aws_s3_bucket_count", "Total number of S3 buckets"
)
aws_ec2_running_instances = Gauge(
    "aws_ec2_running_instances", "Total number of running EC2 instances"
)
aws_ec2_instance_types_running = Gauge(
    "aws_ec2_instance_types_running", "Number of unique EC2 instance types running"
)

# ================================
# METRIC COLLECTION FUNCTIONS
# ================================
def collect_cost_metrics():
    """Fetch AWS cost metrics (daily + month-to-date)."""
    try:
        today = datetime.date.today()
        start_of_month = today.replace(day=1)
        end_date = today + datetime.timedelta(days=1)

        # Daily cost
        daily = ce.get_cost_and_usage(
            TimePeriod={"Start": str(today), "End": str(end_date)},
            Granularity="DAILY",
            Metrics=["UnblendedCost"],
        )
        daily_amount = float(daily["ResultsByTime"][0]["Total"]["UnblendedCost"]["Amount"])
        aws_cost_daily_total_usd.set(daily_amount)

        # Month-to-date cost
        monthly = ce.get_cost_and_usage(
            TimePeriod={"Start": str(start_of_month), "End": str(end_date)},
            Granularity="MONTHLY",
            Metrics=["UnblendedCost"],
        )
        monthly_amount = float(monthly["ResultsByTime"][0]["Total"]["UnblendedCost"]["Amount"])
        aws_cost_monthly_total_usd.set(monthly_amount)

    except Exception as e:
        print(f"[ERROR] Cost metrics: {e}")


def collect_s3_metrics():
    """Fetch S3 bucket count and total object size."""
    try:
        response = s3.list_buckets()
        bucket_names = [b["Name"] for b in response["Buckets"]]
        aws_s3_bucket_count.set(len(bucket_names))

        total_size = 0
        for bucket in bucket_names:
            try:
                resp = s3.list_objects_v2(Bucket=bucket)
                if "Contents" in resp:
                    for obj in resp["Contents"]:
                        total_size += obj["Size"]
            except Exception as e:
                print(f"[WARN] Skipping bucket {bucket}: {e}")
        aws_s3_total_bytes.set(total_size)

    except Exception as e:
        print(f"[ERROR] S3 metrics: {e}")


def collect_ec2_metrics():
    """Fetch running EC2 instance count and instance types."""
    try:
        resp = ec2.describe_instances(
            Filters=[{"Name": "instance-state-name", "Values": ["running"]}]
        )
        instances = []
        types = set()
        for reservation in resp["Reservations"]:
            for inst in reservation["Instances"]:
                instances.append(inst["InstanceId"])
                types.add(inst["InstanceType"])
        aws_ec2_running_instances.set(len(instances))
        aws_ec2_instance_types_running.set(len(types))
    except Exception as e:
        print(f"[ERROR] EC2 metrics: {e}")


# ================================
# MAIN LOOP
# ================================
def main():
    start_http_server(8001)
    print("✅ AWS exporter running on port 8001...")

    while True:
        collect_cost_metrics()
        collect_s3_metrics()
        collect_ec2_metrics()
        time.sleep(300)  # scrape every 5 min


if __name__ == "__main__":
    main()
