# check cluster status
# returns status 0=not existing, 1=stopped, 2=running
function minikube_cluster_status {
    cluster_entry=$(minikube status -p $1 | awk '/host:/ {print $2}')
    if [[ $cluster_entry = "Stopped" ]];then
        echo 1
        exit
    elif [[ $cluster_entry = "Running" ]];then
        echo 2
        exit
    else
        echo 0
        exit
    fi
}