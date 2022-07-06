
echo removing statup


echo removing  services 
kubectl delete -f service.yml

echo removing  deployments 
kubectl delete -f deployment.yml --force --grace-period=0

echo removing  secrets 
kubectl delete -f secret.yml