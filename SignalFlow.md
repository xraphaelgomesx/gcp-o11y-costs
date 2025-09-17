```python
# Instances — Top 10 (24h)
A = data('gcp.cost.usd',
         filter = filter('service','Compute Engine')
               and filter('window','24h')
               and filter('project_id','<YOUR_PROJECT_ID>')
        ).sum(by=['instance_name'])
A.publish('cost_by_instance_24h')

# Instances — 1h moving average
B = A.mean(over='1h')
B.publish('cost_by_instance_ma1h')

# Services — 24h
S = data('gcp.cost.service.usd',
         filter = filter('window','24h')
               and filter('project_id','<YOUR_PROJECT_ID>')
        ).sum(by=['service'])
S.publish('cost_by_service_24h')

# Services — 1h moving average
T = S.mean(over='1h')
T.publish('cost_by_service_ma1h')
```