#!/usr/bin/env bash

echo "policy with OR (using two podSelectors) - expected 200"
cat <<EOF | kubectl create -f -
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: default.postgres
  namespace: default
spec:
  ingress:
  - from:
    - podSelector:
        matchLabels:
          run: curl1
    - podSelector:
        matchLabels:
          run: curl2
  podSelector:
    matchLabels:
      app: hello
  policyTypes:
  - Ingress
EOF
kubectl run -it --rm --restart=Never curl1 --image=appropriate/curl --command -- curl --max-time 3 -s -o /dev/null -w "%{http_code}" hello:8080
success1=$?

kubectl run -it --rm --restart=Never curl2 --image=appropriate/curl --command -- curl --max-time 3 -s -o /dev/null -w "%{http_code}" hello:8080
success2=$?

kubectl delete networkpolicy default.postgres

[[ $success1 = 0 ]] && [[ $success2 = 0 ]] ; success=$?
exit $success