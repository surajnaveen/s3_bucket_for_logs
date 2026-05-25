import pandas as pd
import os

def parse_s3_logs(log_dir):
    logs = []
    for file in os.listdir(log_dir):
        with open(os.path.join(log_dir, file)) as f:
            for line in f:
                parts = line.split()
                logs.append({
                    'bucket': parts[1],
                    'time': parts[2],
                    'timestamp': parts[3].strip('[]'),
                    'ip': parts[4],
                    'operation': parts[7],
                    'object_key': parts[8],
                    'status': parts[9],
                    'bytes_sent': parts[10],
                    'bytes_received': parts[11]
                })
    return pd.DataFrame(logs)

df = parse_s3_logs('./logs/')
df.to_csv('s3_logs_parsed.csv', index=False)