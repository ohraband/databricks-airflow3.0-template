FROM apache/airflow:3.2.2-python3.14

COPY ./dags/ /opt/airflow/dags/

COPY ./requirements.txt .

RUN pip install --no-cache-dir -r requirements.txt


# 3.2.2-python3.14
# 3.0.2-python3.11