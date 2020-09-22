# cd ~/Documents/b1_task/broker/ec2_emq/emqx-rel
# make emqx-pkg
# sudo emqx stop && sudo dpkg -P emqx
# cd ~/Documents/b1_task/broker/ec2_emq/emqx-rel/_packages/emqx
# sudo apt install ./emqx-ubuntu20.04-4.2.0-x86_64.deb && sudo emqx start
# cd ~/Documents/b1_task/iot-client
# npm run start:custom


cd ~/Documents/b1_task/broker/ec2_emq/emqx-rel && make emqx-pkg && sudo emqx stop && sudo dpkg -P emqx && cd ~/Documents/b1_task/broker/ec2_emq/emqx-rel/_packages/emqx && sudo apt install ./emqx-ubuntu20.04-4.2.0-x86_64.deb && sudo emqx start && cd ~/Documents/b1_task/iot-client && npm run start:custom


# cat /var/log/emqx/erlang.log.1
