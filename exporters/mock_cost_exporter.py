from prometheus_client import start_http_server, Gauge
import random
import time

# Define metrics
cpu_percent = Gauge('mock_system_cpu_percent', 'Mock CPU usage percentage')
mem_percent = Gauge('mock_system_mem_percent', 'Mock Memory usage percentage')
daily_cost = Gauge('mock_cloud_daily_cost_usd', 'Mock Cloud Daily Cost in USD')
ec2_hourly_cost = Gauge('mock_ec2_hourly_cost_usd', 'Mock EC2 Hourly Cost in USD')

# Initialize values
current_cpu = 50.0
current_mem = 40.0
current_daily_cost = 5.0
current_ec2_cost = 0.2

def random_walk(value, step=5, min_val=0, max_val=100):
    """Random walk to simulate dynamic changes"""
    change = random.uniform(-step, step)
    new_value = value + change
    return max(min_val, min(new_value, max_val))

if __name__ == "__main__":
    # Start HTTP server on port 8000
    start_http_server(8000)
    print("Mock Exporter running on http://localhost:8000/metrics")

    while True:
        # Update metrics with random walk
        current_cpu = random_walk(current_cpu, step=5, min_val=0, max_val=100)
        current_mem = random_walk(current_mem, step=5, min_val=0, max_val=100)
        current_daily_cost = random_walk(current_daily_cost, step=1, min_val=0, max_val=500)
        current_ec2_cost = random_walk(current_ec2_cost, step=0.05, min_val=0.1, max_val=2)

        # Set values
        cpu_percent.set(current_cpu)
        mem_percent.set(current_mem)
        daily_cost.set(current_daily_cost)
        ec2_hourly_cost.set(current_ec2_cost)

        time.sleep(5)  # Update every 5 seconds
