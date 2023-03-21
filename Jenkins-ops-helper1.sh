  #!/bin/bash

  #Function to create Jenkins backups

  create_jenkins_backup () {
    #Set the backup directory name to today's date
    backup_dir=$(date +%Y-%m-%d)

    #Create the backup directory
    sudo mkdir -p /var/backup/jenkins/$backup_dir

    #Backup Jenkins working directory
    sudo tar -czf /var/backup/jenkins/$backup_dir/working_dir_backup.tar.gz -C /var/lib/jenkins .

    #Backup Jenkins pipeline configuration
    sudo tar -czf /var/backup/jenkins/$backup_dir/pipeline_config_backup.tar.gz -C /var/lib/jenkins/jobs .

    #Delete backup folders older then 7 days
    sudo find /var/backup/jenkins/* -mtime +7 -exec rm -rf {} \;
  }

  #Check if the script is being run with the correct arguments
  if [[ "$1" == "--action" && "$2" == "backup" ]]; then
    #Call the backup function
    create_jenkins_backup
    echo "Jenkins backup created successfully."

  #Output Jenkins installation information
  jenkins_version=$(sudo cat /var/lib/jenkins/config.xml | grep -oP '(?<=<version>)[^<]+')
  jenkins_home=$(grep "JENKINS_HOME" /etc/default/jenkins | awk -F'=' '{print $2}' | sed 's/\$NAME/jenkins/')
  admin_user=$(sudo cat /var/lib/jenkins/users/users.xml | grep -oP -m1 '(?<=<string>)[^<]+')
  admin_password=$(sudo cat /var/lib/jenkins/secrets/initialAdminPassword)

  echo ""
  echo "Jenkins Installed"
  echo "Version: $jenkins_version"
  echo "Home Dir: $jenkins_home"
  echo "Admin User: $admin_user"
  echo "Admin Password: $admin_password"

  else
    echo "Invalid action. Please try: bash Jenkins-ops-helper1.sh --action backup"
  fi

  #To run the script automatically once per day

  (sudo crontab -l 2>/dev/null; echo "0 0 * * * sh /home/marii/Jenkins-ops-helper1.sh --action backup") | crontab -

