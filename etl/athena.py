from pyathena import connect
from pyathena.pandas.cursor import PandasCursor
import subprocess
import json


class ETLPipeline:
    def __init__(self, tf_dir: str = "infra"):
        self.tf_dir = tf_dir
        self.data_location = self._get_terraform_output("athena_location")
        self.results_location = self._get_terraform_output("athena_results_location")

        self.cursor = connect(
            s3_staging_dir=self.results_location,
            region_name="us-east-1",
            cursor_class=PandasCursor,
        ).cursor()

        self.create_table_sql = self._load_sql(
            "sql/create_external_table.sql",
            taxi_bucket_location=self.data_location,
        )
        self.features_sql = self._load_sql("sql/hourly_features.sql")

    def _get_terraform_output(self, name: str) -> str:
        result = subprocess.run(
            ["terraform", f"-chdir={self.tf_dir}", "output", "-json", name],
            capture_output=True, text=True, check=True,
        )
        return json.loads(result.stdout)

    def _load_sql(self, path: str, **kwargs) -> str:
        with open(path, "r") as f:
            template = f.read()
        return template.format(**kwargs) if kwargs else template

    def run(self) -> "pd.DataFrame":
        self.cursor.execute(self.create_table_sql)
        self.df = self.cursor.execute(self.features_sql).as_pandas()
        return self.df