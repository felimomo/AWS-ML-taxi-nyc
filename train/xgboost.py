import xgboost as xgb
from sklearn.model_selection import train_test_split
from sklearn.metrics import (
    root_mean_squared_error, 
    mean_absolute_error, 
    r2_score, 
    mean_absolute_percentage_error
)

class ScalarXGBPipeline:
    """
    Pipeline class for training xgboost on a pandas.DataFrame.
    Args:
        - data: data source
        - features: feature columns in data (predictors)
        - target: label column in data (predicted)
        - train_eval_spl: ratio of training to evaluation data. is =< 1.
    """
    def __init__(
            self, 
            data: "pd.DataFrame", 
            features: list[str], 
            target: str,
            train_eval_spl: float = 0.8,
            n_jobs: int = 2, # parallelization
        ):
        self.features = features
        self.target = target
        self.train_eval_spl = train_eval_spl
        #
        self.X_train, self.X_eval, self.y_train, self.y_eval = (
            train_test_split(
                data[self.features].to_numpy(), 
                data[self.target].to_numpy(),
                train_size=train_eval_spl,
            )
        )
        #
        self.n_jobs = n_jobs
        self.model = xgb.XGBRegressor(n_estimators=200, max_depth=6, n_jobs=self.n_jobs)

    def train(self):
        # Lagged features have NaN values. This is handled internally by xgboost.
        self.model.fit(
            self.X_train, 
            self.y_train,
            eval_set=[(self.X_eval, self.y_eval)],
            verbose=False,
        )

    def eval(self):
        self.y_pred = self.model.predict(self.X_eval)
        self.rmse = root_mean_squared_error(self.y_eval, self.y_pred)
        self.mae = mean_absolute_error(self.y_eval, self.y_pred)
        self.r2 = r2_score(self.y_eval, self.y_pred)
        self.mape = mean_absolute_percentage_error(self.y_eval, self.y_pred)

        # naive baseline: assume this hour = last hour
        baseline_idx = self.features.index("lag_1_trip_count")
        baseline_pred = self.X_eval[:, baseline_idx]
        self.baseline_rmse = root_mean_squared_error(self.y_eval, baseline_pred)
        self.baseline_mae = mean_absolute_error(self.y_eval, baseline_pred)

    def run(self):
        self.train()
        self.eval()
        return {"rmse": self.rmse, "mae": self.mae, "r2": self.r2, "mape": self.mape}
    