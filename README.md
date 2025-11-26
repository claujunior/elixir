# Nome do Projeto

Quebra-cabeça de Blocos Deslizantes

# Descrição Geral

Este projeto implementa um solucionador para um quebra-cabeça de blocos deslizantes.

O programa lê um arquivo de entrada que descreve um tabuleiro, valida se esse tabuleiro segue todas as regras do problema e, em seguida, calcula uma série de movimentos necessários para fazer com que o bloco alvo (bloco “1”) alcance o lado direito do tabuleiro.

# Formato da Entrada

A entrada é feita por um arquivo .txt com a seguinte estrutura:

Primeira linha

ALTURA LARGURA


Define as dimensões do tabuleiro.

Demais linhas
Cada linha representa um bloco no formato:

linha coluna altura largura direção


Onde:

número do bloco

linha / coluna: posição inicial no tabuleiro

altura / largura: tamanho do bloco

direção: caractere indicando para onde o bloco pode se mover

h → horizontal

v → vertical

b → ambos

✔ Exemplo de entrada
6 6
1 1 1 1 2 h
2 3 1 2 1 v
3 4 4 1 1 b

# Saída do Programa

A saída é exibida no terminal.

O programa imprime uma série de comandos de movimento, representando passo a passo como cada bloco deve ser deslocado até que o bloco 1 chegue ao lado direito do tabuleiro.

Exemplo genérico de saída:

Move block 1 EAST, 9 steps
Deu certo!!!
:ok


# O que o sistema faz internamente

Lê o tabuleiro do arquivo .txt

Valida se:

não há blocos sobrepostos

todos estão dentro dos limites

direções são válidas

Processa os movimentos possíveis

Encontra uma solução (caso exista)

Exibe a sequência final de comandos

# Como executar

Abre o interpretador com o comando "iex -S mix"
depois escreve o comando Pf.ler_dados("caminho do arquivo")