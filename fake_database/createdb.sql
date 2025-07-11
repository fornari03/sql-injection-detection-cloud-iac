\c postgres;

DROP DATABASE IF EXISTS web_server_db;

CREATE DATABASE web_server_db;

\c web_server_db;

CREATE TABLE users (
    id SERIAL PRIMARY KEY,
    username VARCHAR(50) UNIQUE NOT NULL,
    password VARCHAR(255) NOT NULL,
    role VARCHAR(50) NOT NULL
);

INSERT INTO users (username, password, role) VALUES
('admin', 'password123', 'admin'),
('enzo.teles', 'az4eL?', 'user'),
('lorena.borges', 'awes0me_t3ach3r', 'user'),
('gui.fornari', 'kek123%', 'user');
