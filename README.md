# Roadmap.sh-004

### Create CI/CD for Multi-container application

You need:
 - A remote server. I chose AWS free-tier but can be any that is supported as a Terraform provider.
 - A local machine to use terraform and ansible applications to manage your server/deployments. Preferrably a linux environment.

Get started:

Install `terraform` and `ansible-core` on your host machine.

### Part One: Choose cloud server and create user to use terraform with
I will not focus on the details of how to create an account with a cloud provider and which one is best for this purpose. 
This guide made use of [AWS free-tier](https://aws.amazon.com/free) and as such all assumptions are made using this fact. The resources used therein are validated to work without issue as of 5/Nov/2024.

Inside AWS Console search `IAM` and create a `user`. Assuming you have already created a user, make sure they have `AdministratorAccess` policy permission and proceed to generate `access key` for them.  
AWS also provides you with a handy csv file to download the keys.

### Part Two: Get this code
```
git clone https://github.com/jammie-jelly/Roadmap.sh-004.git
```

```cd Roadmap.sh-004```

Make sure the following steps below are carried out only in the `Roadmap.sh-004` directory.

### Part Three: Provision the server
Check `.env.example` you will need to populate those values with the 2 keys:
```
AWS_ACCESS_KEY_ID=""
AWS_SECRET_ACCESS_KEY=""
````
With that done, rename file to `.env` and continue.


On a terminal:
```
export $(grep -v '^#' .env | xargs)
```

```
terraform init
```

```
terraform apply
```


After successful provision of the server, Terraform will respond with an IP address for the server. Copy this we will need it to ssh to the server.

### Part Four: Setup ansible

Generate the ssh key we will use for `ansible`.

```
ssh-keygen -f ~/.ssh/roadmap
```
Add the IP address above to `ansible/inv.ini` second line `ansible_host=IP`

Now let's do a test to make sure ansible can talk to the remote server.

```
ansible -i ansible/inv.ini roadmap -m ping
```

You should see in green some SUCCESS text with "ping": "pong". If you see something else, then you need to trace back your steps and fix the issue before continuing.

### Part Five: Prepare remote server and deploy our application

```ansible-playbook -i ansible/inv.ini ansible/setup-run-docker.yml```

This will download docker to the server and deploy using `docker compose` our `todo` application.

We will be using [tunnelmole](https://github.com/robbie-cahill/tunnelmole-client) to make our application available from any network.

After building and running the docker containers, ansible will return logs for the `ci-app-1` container using ```sudo docker logs ci-app-1``` which will show us the random subdomain assigned to the application.

Example will look like this:
```
example:
ok: [roadmap] => {
    "log_output.stdout": "Server running on http://localhost:3000\nConnected to MongoDB\nhttp://x4hxaq-ip-13-60-170-252.tunnelmole.net is forwarding to localhost:3000\nhttps://x4hxaq-ip-13-60-170-252.tunnelmole.net is forwarding to localhost:3000\n\n\n\n ....."
}
```

If you see this after running the ansible playbook, you made it! You can test the `todo` app:

### Part Six: Access the todo api
### Create todo
```
curl -X POST https://x4hxaq-ip-13-60-170-252.tunnelmole.net/todos \                                                                                         
     -H "Content-Type: application/json" \
     -d '{"title": "Buy coffee", "completed": true}'
```

### Fetch todo(s)
```
curl -X GET https://x4hxaq-ip-13-60-170-252.tunnelmole.net/todos
```
### Part Seven: Ansible CI/CD using Github Actions

Take a look at file ```.github/workflows/ansible-ci-cd.yml```

We are repeating the same process we did in step 5 everytime a commit is made to the main branch on the github repository.

We added the private key from `~/.ssh/roadmap` as a repository secret ```SSH_PRIVATE_KEY``` and now ansible has the necessary authentication to do the CI/CD on our remote server.

To get the `tunnelmole` urls for the application, click on the specific github action workflow run it will appear in the logs after application has successfully deployed.

Now you have a working CI/CD for your development!



### If you made it this far, thank yourself for completing the journey.

Part of this challenge: https://roadmap.sh/projects/multi-container-service



