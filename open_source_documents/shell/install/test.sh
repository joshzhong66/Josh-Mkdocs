setalias(){
cat >>~/.bashrc <<EOF
alias cdnet="cd /etc/sysconfig/network-scripts"
alias vimeth1="vim /etc/sysconfig/network-scripts/ifcfg-eth0"
alias scandisk="echo '- - -' > /sys/class/scsi_host/host0/scan;echo '- - -' > /sys/class/scsi_host/host1/scan;echo '- - -' > /sys/class/scsi_host/host2/scan"
alias yy='yum -y install'
alias ys='yum search'
alias yc='yum clean all'
alias yu='yum -y update'
alias yd='yum -y remove'
alias fd='systemctl stop firewalld.service'
alias fdd='systemctl disable --now firewalld.service'
alias fw='firewall-cmd --state'
alias fo='systemctl start firewalld.service'
alias fr='systemctl restart firewalld.service'
alias net='service network restart'
alias sr='systemctl restart'
alias ss='systemctl start '
alias st='systemctl stop'
alias sd='systemctl daemon-reload'
alias sa='systemctl status'
alias sn='systemctl enable --now'
alias yp='yum provides'
alias ss='netstat'
alias dp='docker pull'
alias dr='docker rmi'
alias ds='docker search'
alias dr='docker restart'
alias de='docker exec -it'
alias da='docker ps -a'
EOF
echo -e "\033[36mcentos`version` 别名设置完成！ \033[0m"
}