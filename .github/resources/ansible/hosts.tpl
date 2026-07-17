---
fleet:
  children:
    managers:
      hosts:
        manager:
          ansible_host: $MANAGER_PUBLIC_IP
      vars:
        ansible_user: ec2-user
        ansible_ssh_private_key_file: ~/.ssh/aws_slave.pem
    workers:
      vars:
        ansible_user: ubuntu
        ansible_ssh_private_key_file: ~/.ssh/aws_slave.pem
      hosts:
