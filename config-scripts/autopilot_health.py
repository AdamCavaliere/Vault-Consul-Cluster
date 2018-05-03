import json
import requests
import sys
import time

#URL To check health of Consul
ConsulURL = "http://ec2-18-218-78-220.us-east-2.compute.amazonaws.com:8500/v1/operator/autopilot/health"

def pollConsul():
	r = requests.get(ConsulURL)
	results = json.loads(r.text)
	return results

for count in range(0, 40):
	results = pollConsul()
	MainHealth = results['Healthy']
	FailureTolerance = results['FailureTolerance']
	ServerCount = len(results["Servers"])
	HealthCount = 0
	for result in results["Servers"]:
		if result["Healthy"]:
			HealthCount += 1

	if ServerCount == HealthCount and MainHealth and ServerCount >= 2:
		print "We are good to go"
		sys.exit(0)
	else:
		print "Not ready yet: " + str(count)
		time.sleep(15)
	
sys.exit(1)
	


	

