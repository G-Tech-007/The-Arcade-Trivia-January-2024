
REGION1=${ZONE1::-2}
REGION2=${ZONE2::-2}


PROJECT_ID=$GOOGLE_CLOUD_PROJECT
PROJECT_NUMBER=$(gcloud projects list --filter="qwiklabs-gcp" --format='value(PROJECT_NUMBER)')

gcloud compute networks create vpn-network-1 --subnet-mode custom
gcloud compute networks subnets create subnet-a \
--network vpn-network-1 --range 10.1.1.0/24 --region "$REGION1"
gcloud compute firewall-rules create network-1-allow-custom \
  --network vpn-network-1 \
  --allow tcp:0-65535,udp:0-65535,icmp \
  --source-ranges 10.0.0.0/8
gcloud compute firewall-rules create network-1-allow-ssh-icmp \
    --network vpn-network-1 \
    --allow tcp:22,icmp
gcloud compute instances create server-1 --machine-type=e2-medium --zone $ZONE1 --subnet subnet-a

gcloud compute networks create vpn-network-2 --subnet-mode custom
gcloud compute networks subnets create subnet-b \
--network vpn-network-2 --range 192.168.1.0/24 --region $REGION2
gcloud compute firewall-rules create network-2-allow-custom \
  --network vpn-network-2 \
  --allow tcp:0-65535,udp:0-65535,icmp \
  --source-ranges 192.168.0.0/16
gcloud compute firewall-rules create network-2-allow-ssh-icmp \
    --network vpn-network-2 \
    --allow tcp:22,icmp
gcloud compute instances create server-2 --machine-type=e2-medium --zone $ZONE2 --subnet subnet-b

gcloud compute addresses create vpn-1-static-ip --region=$REGION1
gcloud compute addresses create vpn-2-static-ip --region=$REGION2

VPN_1_STATIC_IP=$(gcloud compute addresses describe vpn-1-static-ip --region=$REGION1 --format="value(address)")
VPN_2_STATIC_IP=$(gcloud compute addresses describe vpn-2-static-ip --region=$REGION2 --format="value(address)")

gcloud compute target-vpn-gateways create vpn-1 --project=$PROJECT_ID --region=$REGION1 --network=vpn-network-1 && gcloud compute forwarding-rules create vpn-1-rule-esp --project=$PROJECT_ID --region=$REGION1 --address=$VPN_1_STATIC_IP --ip-protocol=ESP --target-vpn-gateway=vpn-1 && gcloud compute forwarding-rules create vpn-1-rule-udp500 --project=$PROJECT_ID --region=$REGION1 --address=$VPN_1_STATIC_IP --ip-protocol=UDP --ports=500 --target-vpn-gateway=vpn-1 && gcloud compute forwarding-rules create vpn-1-rule-udp4500 --project=$PROJECT_ID --region=$REGION1 --address=$VPN_1_STATIC_IP --ip-protocol=UDP --ports=4500 --target-vpn-gateway=vpn-1 && gcloud compute vpn-tunnels create tunnel1to2 --project=$PROJECT_ID --region=$REGION1 --peer-address=$VPN_2_STATIC_IP --shared-secret=gcprocks --ike-version=2 --local-traffic-selector=0.0.0.0/0 --remote-traffic-selector=0.0.0.0/0 --target-vpn-gateway=vpn-1 && gcloud compute routes create tunnel1to2-route-1 --project=$PROJECT_ID --network=vpn-network-1 --priority=1000 --destination-range=10.1.3.0/24 --next-hop-vpn-tunnel=tunnel1to2 --next-hop-vpn-tunnel-region=$REGION1


gcloud compute target-vpn-gateways create vpn-2 --project=$PROJECT_ID --region=$REGION2 --network=vpn-network-2 && gcloud compute forwarding-rules create vpn-2-rule-esp --project=$PROJECT_ID --region=$REGION2 --address=$VPN_2_STATIC_IP --ip-protocol=ESP --target-vpn-gateway=vpn-2 && gcloud compute forwarding-rules create vpn-2-rule-udp500 --project=$PROJECT_ID --region=$REGION2 --address=$VPN_2_STATIC_IP --ip-protocol=UDP --ports=500 --target-vpn-gateway=vpn-2 && gcloud compute forwarding-rules create vpn-2-rule-udp4500 --project=$PROJECT_ID --region=$REGION2 --address=$VPN_2_STATIC_IP --ip-protocol=UDP --ports=4500 --target-vpn-gateway=vpn-2 && gcloud compute vpn-tunnels create tunnel2to1 --project=$PROJECT_ID --region=$REGION2 --peer-address=$VPN_1_STATIC_IP --shared-secret=gcprocks --ike-version=2 --local-traffic-selector=0.0.0.0/0 --remote-traffic-selector=0.0.0.0/0 --target-vpn-gateway=vpn-2 && gcloud compute routes create tunnel2to1-route-1 --project=$PROJECT_ID --network=vpn-network-2 --priority=1000 --destination-range=10.5.4.0/24 --next-hop-vpn-tunnel=tunnel2to1 --next-hop-vpn-tunnel-region=$REGION2
