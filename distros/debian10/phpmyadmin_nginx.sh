#---------------------------------------------------------------------
# Function: Confi_phpMyAdmin_nginx
#    Configure phpMyAdmin for nginx
#---------------------------------------------------------------------
config_phpMyAdmin_nginx() {
    touch /etc/nginx/phpmyadmin.vhost
    # Write default ngnix  vhost configuration file for phpmyadmin - to be included in all other hosts
    # to include phpmyadmin configuration in ISPConfig control panel- sites - website - options 
    # under nginx Directives add :
    # include phpmyadmin.vhost;
    cat > /etc/nginx/phpmyadmin.vhost <<EOF

## phpMyAdmin default nginx configuration

   location /phpmyadmin {
               root /usr/share/;
               index index.php index.html index.htm;
               location ~ ^/phpmyadmin/(.+\.php)$ {
                       try_files $uri =404;
                       root /usr/share/;
                       fastcgi_pass unix:/var/run/php/php7.3-fpm.sock;
                       fastcgi_param HTTPS $https;
                       fastcgi_index index.php;
                       fastcgi_param SCRIPT_FILENAME $request_filename;
                       include /etc/nginx/fastcgi_params;
                       fastcgi_param PATH_INFO $fastcgi_script_name;
                       fastcgi_buffer_size 128k;
                       fastcgi_buffers 256 4k;
                       fastcgi_busy_buffers_size 256k;
                       fastcgi_temp_file_write_size 256k;
                       fastcgi_intercept_errors on;
               }
               ## Images and static content is treated different
               location ~* ^/phpmyadmin/(.+\.(jpg|jpeg|gif|css|png|js|ico|html|xml|txt))$ {
                       root /usr/share/;
               }
        }
        location /phpMyAdmin {
               rewrite ^/* /phpmyadmin last;
        }
   location / {
      index index.php;
   }

EOF

    systemctl restart nginx
    systemctl restart php7.3-fpm
}
