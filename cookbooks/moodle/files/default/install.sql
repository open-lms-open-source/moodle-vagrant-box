-- This is supposed to roughly do the same thing as mysql_secure_installation except
-- that it modifies the root user to have a password and allow connetion from any host.
DELETE FROM mysql.user WHERE user = 'root' and host NOT IN ('127.0.0.1', 'localhost');
DELETE FROM mysql.user WHERE USER LIKE '';
ALTER USER 'root'@'localhost' IDENTIFIED WITH mysql_native_password BY 'root';
RENAME USER 'root'@'localhost' TO 'root'@'%';
FLUSH PRIVILEGES;
DELETE FROM mysql.db WHERE db LIKE 'test%';
DROP DATABASE IF EXISTS test ;
