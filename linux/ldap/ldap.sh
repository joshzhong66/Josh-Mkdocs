
mkdir -p /data/openldap/{ldap,ldif,slapd.d}

docker pull osixia/openldap

docker run \
    -d \
    -p 389:389 \
    -p 636:636 \
    -v /data/openldap/ldif:/usr/local/ldif \
    -v /data/openldap/ldap:/var/lib/ldap \
    -v /data/openldap/slapd.d:/etc/ldap/slapd.d \
    --env LDAP_ORGANISATION="joshzhong" \
    --env LDAP_DOMAIN="joshzhong.top" \
    --env LDAP_ADMIN_PASSWORD="Sunline2024" \
    --name openldap \
    --hostname openldap-host\
    --network bridge \
    osixia/openldap


yum -y install openldap-clients
ldapsearch -x -H ldap://10.22.51.66:389 -D "cn=admin,dc=joshzhong,dc=top" -w Sunline2024 -b "dc=joshzhong,dc=top"


# LDAP UI 管理界面（1）
  docker run \
  -p 8080:80 \
  --privileged \
  --name limildap \
  --env PHPLDAPADMIN_HTTPS=false \
  --env PHPLDAPADMIN_LDAP_HOSTS=10.22.51.66 \
  --detach osixia/phpldapadmin


cat > /data/openldap/ldif/create_ou.ldif <<'EOF'
dn: ou=users,dc=joshzhong,dc=top
objectClass: organizationalUnit
ou: users
EOF


docker exec -it openldap ldapadd -x -D "cn=admin,dc=joshzhong,dc=top" -w Sunline2024 -f /usr/local/ldif/create_ou.ldif
docker exec -it openldap ldapsearch -x -D "cn=admin,dc=joshzhong,dc=top" -w Sunline2024 -b "ou=users,dc=joshzhong,dc=top"

# 添加用户

cat > /data/openldap/ldif/user.ldif <<'EOF'
dn: uid=zjl,ou=users,dc=joshzhong,dc=top
objectClass: inetOrgPerson
objectClass: posixAccount
objectClass: top
cn: 锦林
sn: 钟
uid: zjl
uidNumber: 1001
gidNumber: 1001
homeDirectory: /home/zjl
loginShell: /bin/bash
userPassword: Sunline2024
EOF

docker exec -it openldap ldapadd -x -D "cn=admin,dc=joshzhong,dc=top" -w Sunline2024 -f /usr/local/ldif/user.ldif


docker exec -it openldap ldapsearch -x -D "cn=admin,dc=joshzhong,dc=top" -w Sunline2024 -b "uid=zjl,ou=users,dc=joshzhong,dc=top"

