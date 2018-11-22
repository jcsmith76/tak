# create inventory from AWS
echo "" > tf_inventory.txt
echo "[master]" >> tf_inventory.txt
aws ec2 describe-addresses --filter Name=tag:type,Values=tfk8s --output text |grep ADDRESSES|awk '{print $9}' > /tmp/inv.txt
head -n 1 /tmp/inv.txt >> tf_inventory.txt
echo "[worker]" >> tf_inventory.txt
tail -n 2 /tmp/inv.txt >> tf_inventory.txt

# run playbooks
ANSIBLE_HOST_KEY_CHECKING=False
export ANSIBLE_HOST_KEY_CHECKING
ansible-playbook -i tf_inventory.txt provision.yml
sleep 100
ansible all --inventory-file=tf_inventory.txt -m ping -u ubuntu
sleep 100
ansible-playbook -i tf_inventory.txt k8s.yml


# After this, you should be able to ssh into master and run
# kubectl get nodes
# kubectl get pods --all-namespaces
# kubectl run hello-node --image=gcr.io/hello-minikube-zero-install/hello-node --port=8080
# kubectl get deployments
# kubectl expose deployment hello-node --type=NodePort --name=example-service
# kubectl describe services
# curl http://192.168.171.1:8080

