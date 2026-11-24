# import time
# import datetime
# from airflow.sdk import DAG,task

# with DAG(
#     dag_id="example_dag",
#     start_date=datetime.datetime(2021,1,1),
#     schedule="@daily"
# ):

#     @task
#     def hello_world():
#         time.sleep(5)
#         print("Hello world, from Airflow!")

#     hello_world()


import time
from datetime import datetime, timezone

from airflow.sdk import dag, task


@dag(
    dag_id="example_dag",
    start_date=datetime(2025, 1, 1, tzinfo=timezone.utc),
    schedule="@daily",
    catchup=False,
)
def example_dag():
    @task
    def hello_world():
        time.sleep(5)
        print("Hello world, from Airflow!")

    @task
    def goobye_worls():
        time.sleep(5)
        print("Goodbye world, from Airflow!")

    hello_world()


example_dag()
