import boto3
import sagemaker
from sagemaker.xgboost.estimator import XGBoost

def stage_training_data(df, bucket_uri: str) -> str:
    local_path = "features.csv"
    df.to_csv(local_path, index=False)
    s3_path = f"{bucket_uri}train/features.csv"
    boto3.client("s3").upload_file(local_path, bucket_uri.split("/")[2], "train/features.csv")
    return f"{bucket_uri}train/"

def launch_training_job(train_data_s3_uri: str, role_arn: str, use_spot: bool = True):
    estimator = XGBoost(
        entry_point="train.py",
        source_dir="training",
        framework_version="1.7-1",
        instance_type="sc.t3.medium",
        instance_count=1,
        role=role_arn,
        hyperparameters={
            "n-estimators": 200,
            "max-depth": 6,
        },
        use_spot_instances=use_spot,
        max_wait=3600 if use_spot else None,   # required when use_spot_instances=True
        max_run=1800,
    )
    estimator.fit({"train": train_data_s3_uri})
    return estimator