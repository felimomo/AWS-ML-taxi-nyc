import argparse
import os
import pandas as pd
import xgboost as xgb
from sklearn.model_selection import train_test_split
from sklearn.metrics import root_mean_squared_error, mean_absolute_error, r2_score

def parse_args():
    parser = argparse.ArgumentParser()
    ##
    # Model / training params:
    ##
    parser.add_argument("--n-estimators", type=int, default=200)
    parser.add_argument("--max-depth", type=int, default=6)
    parser.add_argument("--n-jobs", type=int, default=-1)  # -1 = use all cores on the instance
    parser.add_argument("--train-eval-split", type=float, default=0.8)
    ##
    # SageMaker defaults:
    ##
    parser.add_argument(
        "--model-dir", type=str, 
        default=os.environ.get("SM_MODEL_DIR")
    )
    # local directory in container where sagemaker downloaded training data from S3 bucket
    parser.add_argument(
        "--train", type=str, 
        default=os.environ.get("SM_CHANNEL_TRAIN") 
    )
    return parser.parse_args()

def main():
    args = parse_args()

    data_path = os.path.join(args.train, "features.csv")
    df = pd.read_csv(data_path)

    features = [c for c in df.columns if c != "trip_count"]
    X_train, X_eval, y_train, y_eval = train_test_split(
        df[features].to_numpy(), df["trip_count"].to_numpy(),
        train_size=args.train_eval_split, random_state=42,
    )

    model = xgb.XGBRegressor(
        n_estimators=args.n_estimators,
        max_depth=args.max_depth,
        n_jobs=args.n_jobs,
        random_state=42,
    )
    model.fit(X_train, y_train)

    y_pred = model.predict(X_eval)
    print(f"RMSE: {root_mean_squared_error(y_eval, y_pred):.3f}")
    print(f"MAE: {mean_absolute_error(y_eval, y_pred):.3f}")
    print(f"R2: {r2_score(y_eval, y_pred):.3f}")

    model.save_model(os.path.join(args.model_dir, "model.xgb"))

if __name__ == "__main__":
    main()