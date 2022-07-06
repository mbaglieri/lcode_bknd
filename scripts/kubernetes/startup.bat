
echo init statup

echo creating  secrets 
kubectl apply -f secret.yml

echo creating  services
kubectl apply -f service.yml

echo creating  deployments
kubectl apply -f deployment.yml