# Adicionada a pasta Lib para o Loader, dispensando configuração da variavel RUBYLIB
$LOAD_PATH << File.expand_path('.', File.join(File.dirname(__FILE__), '../lib'))